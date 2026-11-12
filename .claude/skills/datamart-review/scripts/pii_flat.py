# -*- coding: utf-8 -*-
"""
pii_flat.py — mã hóa cột PII ở bước nạp flat (Datamart MinIO -> flat ClickHouse).

Registry: system/rules/pii_columns.yaml (tên cột flat -> nhóm PII). Luật: mọi cột flat có tên trong registry phải được bọc
    fn_pii_encrypt(<biểu thức>, :aes_key_hex) AS <tên cột>
trong khối INSERT ... SELECT của 02_populate_*.sql. Hàm là SQL UDF AES-256-CBC deterministic, Base64(IV | ciphertext), IV suy ra
từ khóa + giá trị gốc theo macro dbt `encrypt_cbc_deterministic`
(Datamart/flat-table/Common/00_create_pii_encryption_function.sql). Khóa là tham số runtime, KHÔNG nằm trong repo.
Cú pháp cũ 3 tham số `fn_pii_encrypt(<biểu thức>, :aes_key_hex, :aes_iv_hex)` (IV cố định) đã bị thay: CLI tự chuyển về 2 tham số,
Gate 8 D28 báo ERROR nếu còn sót.

Dùng chung bởi:
  - check_design_lint.py  D28 [L4-FLAT-PII-NOT-ENCRYPTED] / [L4-FLAT-PII-LEGACY-IV] / [L4-FLAT-PII-COLUMN-TYPE]
  - CLI này: sửa populate + gắn nhãn COMMENT DDL cho 1 module (idempotent, mặc định dry-run).

    python pii_flat.py -m GSTT            # dry-run: in kế hoạch
    python pii_flat.py -m GSTT --apply    # ghi 02_populate_* và 01_create_* (giữ nguyên BOM / CRLF)
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

FUNC = "fn_pii_encrypt"
TAG_MARK = "[PII mã hóa AES-256-CBC"
LEGACY_IV_PARAM = ":aes_iv_hex"   # tham số IV của bản UDF cũ (IV cố định); bản hiện hành không còn tham số này
_LEGACY_CALL_TAIL = re.compile(r",\s*(:aes_key_hex)\s*,\s*:aes_iv_hex\s*\)")

_INSERT = re.compile(
    r"INSERT\s+INTO\s+([\w.]+)(?:\s+ON\s+CLUSTER\s+(?:'[^']*'|\"[^\"]*\"|\S+))?\s+SELECT\b", re.I)
_CREATE = re.compile(r"^\s*CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?([\w.]+)", re.I)
_STRING_TYPES = {"String", "Nullable(String)", "LowCardinality(String)", "LowCardinality(Nullable(String))"}


# ----------------------------------------------------------------------------------------------
# Registry
# ----------------------------------------------------------------------------------------------
def load_registry(root: Path) -> dict:
    import yaml
    p = Path(root) / "system" / "rules" / "pii_columns.yaml"
    data = yaml.safe_load(p.read_text(encoding="utf-8")) or {}
    pa2 = data.get("pa2") or {}
    return {
        "columns": dict(data.get("columns") or {}),
        "exclude": {str(x).strip() for x in (data.get("exclude") or [])},
        "params": list(data.get("params") or [":aes_key_hex"]),
        "pa2_tables": set(pa2.get("tables") or []),
        "pa2_columns": set(pa2.get("columns") or []),
    }


def _base(flat_table: str) -> str:
    t = flat_table.split(".")[-1]
    return t[:-4] if t.endswith("_stg") else t


def is_pii(reg: dict, flat_table: str, col: str) -> bool:
    return col in reg["columns"] and f"{_base(flat_table)}.{col}" not in reg["exclude"]


def pa_of(reg: dict, flat_table: str, col: str) -> str:
    return "PA2" if (_base(flat_table) in reg["pa2_tables"] and col in reg["pa2_columns"]) else "PA1"


# ----------------------------------------------------------------------------------------------
# Quét projection của INSERT ... SELECT trên text gốc (giữ nguyên comment/định dạng)
# ----------------------------------------------------------------------------------------------
def _scan_projection(text: str, start: int):
    """start = vị trí ngay sau SELECT. Trả về ([(seg_start, seg_end)], vị trí FROM cấp 0)."""
    segs, seg_start, i, n, depth, q = [], start, start, len(text), 0, None
    while i < n:
        ch = text[i]
        if q:
            if ch == "\\" and q == "'":
                i += 2
                continue
            if ch == q:
                if q == "'" and text[i + 1:i + 2] == "'":
                    i += 2
                    continue
                q = None
            i += 1
            continue
        if ch == "-" and text[i:i + 2] == "--":
            j = text.find("\n", i)
            i = n if j < 0 else j
            continue
        if ch == "/" and text[i:i + 2] == "/*":
            j = text.find("*/", i + 2)
            i = n if j < 0 else j + 2
            continue
        if ch in "'\"`":
            q = ch
            i += 1
            continue
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        elif depth == 0:
            if ch == ",":
                segs.append((seg_start, i))
                seg_start = i + 1
            elif (text[i:i + 4].upper() == "FROM"
                  and (i == 0 or not (text[i - 1].isalnum() or text[i - 1] == "_"))
                  and not (text[i + 4:i + 5].isalnum() or text[i + 4:i + 5] == "_")):
                segs.append((seg_start, i))
                return segs, i
        i += 1
    segs.append((seg_start, n))
    return segs, n


def _strip_comments(s: str) -> str:
    out, i, n, q = [], 0, len(s), None
    while i < n:
        ch = s[i]
        if q:
            out.append(ch)
            if ch == q:
                q = None
            i += 1
            continue
        if ch in "'\"`":
            q = ch
            out.append(ch)
            i += 1
            continue
        if ch == "-" and s[i:i + 2] == "--":
            while i < n and s[i] != "\n":
                i += 1
            continue
        out.append(ch)
        i += 1
    return "".join(out)


def _split_segment(seg: str):
    """(prefix, code, suffix): prefix = dòng trống/comment + thụt lề đứng trước biểu thức; suffix = khoảng trắng cuối."""
    off = 0
    for ln in seg.split("\n"):
        s = ln.strip()
        if s == "" or s.startswith("--"):
            off += len(ln) + 1
        else:
            break
    else:
        return None
    rest = seg[off:]
    indent = re.match(r"[ \t]*", rest).group(0)
    body = rest[len(indent):]
    code = body.rstrip()
    return seg[:off] + indent, code, body[len(code):]


def _alias_expr(code: str):
    m = re.search(r"\bAS\s+(\w+)\s*$", code, re.I)
    if m:
        return m.group(1), code[:m.start()].rstrip()
    m = re.search(r"(\w+)\s*$", code)
    return (m.group(1), code) if m else (None, code)


def iter_projections(text: str):
    """Mỗi phần tử: dict(table, seg=(s, e), prefix, code, suffix, alias, expr, inline_comment)."""
    for m in _INSERT.finditer(text):
        segs, _ = _scan_projection(text, m.end())
        for s, e in segs:
            parts = _split_segment(text[s:e])
            if not parts:
                continue
            prefix, code, suffix = parts
            clean = _strip_comments(code).rstrip()   # alias tính trên chuỗi đã bỏ comment (không lấy nhầm chữ cuối của comment)
            alias, expr = _alias_expr(clean)
            yield {"table": m.group(1), "seg": (s, e), "prefix": prefix, "code": code, "suffix": suffix,
                   "alias": alias, "expr": expr, "inline_comment": clean != code}


def is_wrapped(code: str) -> bool:
    return re.match(r"\s*" + FUNC + r"\s*\(", code) is not None


def unencrypted(text: str, reg: dict):
    """[(flat_table, alias)] — cột PII chưa bọc fn_pii_encrypt trong khối INSERT ... SELECT."""
    out = []
    for p in iter_projections(text):
        if p["alias"] and is_pii(reg, p["table"], p["alias"]) and not is_wrapped(p["code"]):
            out.append((p["table"], p["alias"]))
    return out


def legacy_iv_calls(text: str):
    """[(flat_table, alias)] — cột đã bọc fn_pii_encrypt theo cú pháp cũ (còn tham số :aes_iv_hex). UDF mới không nhận 3 tham số."""
    return [(p["table"], p["alias"]) for p in iter_projections(text)
            if p["alias"] and is_wrapped(p["code"]) and LEGACY_IV_PARAM in p["code"]]


def drop_legacy_iv(text: str):
    """Chuyển `fn_pii_encrypt(x, :aes_key_hex, :aes_iv_hex)` về `fn_pii_encrypt(x, :aes_key_hex)`. Trả về (text mới, số chỗ). Idempotent."""
    return _LEGACY_CALL_TAIL.subn(r", \1)", text)


def encrypt_populate(text: str, reg: dict):
    """Trả về (text mới, [đã bọc], [bỏ qua + lý do]). Idempotent."""
    wrapped, skipped, edits = [], [], []
    args = ", ".join(reg["params"])
    for p in iter_projections(text):
        a = p["alias"]
        if not a or not is_pii(reg, p["table"], a) or is_wrapped(p["code"]):
            continue
        if p["inline_comment"]:
            skipped.append((p["table"], a, "biểu thức có comment nội dòng — bọc tay"))
            continue
        new = f"{FUNC}({p['expr']}, {args}) AS {a}"
        edits.append((p["seg"], p["prefix"] + new + p["suffix"]))
        wrapped.append((p["table"], a, p["expr"]))
    for (s, e), repl in sorted(edits, key=lambda x: x[0][0], reverse=True):
        text = text[:s] + repl + text[e:]
    return text, wrapped, skipped


# ----------------------------------------------------------------------------------------------
# DDL: kiểu cột + nhãn COMMENT
# ----------------------------------------------------------------------------------------------
_COL_COMMENT = re.compile(r"^(\s+)(\w+)(\s+)(.+?)(\s+COMMENT\s+')(.*)('\s*,?\s*)$")
_COL_NOCOMMENT = re.compile(r"^(\s+)(\w+)(\s+)([A-Za-z][\w(), ]*?)(\s*,?)\s*$")


def _tag(reg: dict, table: str, col: str) -> str:
    return f" {TAG_MARK} Base64 - {pa_of(reg, table, col)}]"


def ddl_column_types(text: str):
    """[(table, col, type)] của cột nằm trong khối CREATE TABLE (trước ENGINE)."""
    res, cur = [], None
    for ln in text.split("\n"):
        m = _CREATE.match(ln)
        if m:
            cur = m.group(1)
            continue
        if cur is None:
            continue
        if re.match(r"^\s*(\)|ENGINE\b)", ln, re.I):
            cur = None
            continue
        c = _COL_COMMENT.match(ln.rstrip("\r"))
        if c:
            res.append((cur, c.group(2), c.group(4).strip()))
    return res


def tag_ddl(text: str, reg: dict):
    """Gắn nhãn [PII mã hóa ...] vào COMMENT của cột PII. Trả về (text mới, [(table, col)])."""
    out, tagged, cur = [], [], None
    for raw in text.split("\n"):
        cr = "\r" if raw.endswith("\r") else ""
        ln = raw[:-1] if cr else raw
        m = _CREATE.match(ln)
        if m:
            cur = m.group(1)
        elif cur and re.match(r"^\s*(\)|ENGINE\b)", ln, re.I):
            cur = None
        elif cur:
            c = _COL_COMMENT.match(ln)
            if c and is_pii(reg, cur, c.group(2)) and TAG_MARK not in ln:
                ln = c.group(1) + c.group(2) + c.group(3) + c.group(4) + c.group(5) + c.group(6) \
                    + _tag(reg, cur, c.group(2)) + c.group(7)
                tagged.append((cur, c.group(2)))
            elif not c:
                n = _COL_NOCOMMENT.match(ln)
                if n and is_pii(reg, cur, n.group(2)) and TAG_MARK not in ln:
                    ln = (n.group(1) + n.group(2) + n.group(3) + n.group(4).rstrip()
                          + f" COMMENT '{_tag(reg, cur, n.group(2)).strip()}'" + n.group(5))
                    tagged.append((cur, n.group(2)))
        out.append(ln + cr)
    return "\n".join(out), tagged


def non_string_pii(text: str, reg: dict):
    return [(t, c, ty) for t, c, ty in ddl_column_types(text)
            if is_pii(reg, t, c) and ty not in _STRING_TYPES]


# ----------------------------------------------------------------------------------------------
# CLI
# ----------------------------------------------------------------------------------------------
def _read(p: Path):
    b = p.read_bytes()
    bom = b.startswith(b"\xef\xbb\xbf")
    return b[3:].decode("utf-8") if bom else b.decode("utf-8"), bom


def _write(p: Path, text: str, bom: bool):
    p.write_bytes((b"\xef\xbb\xbf" if bom else b"") + text.encode("utf-8"))


def find_root() -> Path:
    here = Path(__file__).resolve()
    for a in here.parents:
        if (a / "Datamart").is_dir() and (a / "system").is_dir():
            return a
    raise SystemExit("Không tìm thấy root dự án")


def module_files(root: Path, module: str):
    d = root / "Datamart" / "flat-table" / module
    return sorted(d.glob("02_populate_*.sql")), sorted(d.glob("01_create_*.sql"))


def main():
    ap = argparse.ArgumentParser(description="Mã hóa cột PII ở flat (populate + nhãn COMMENT DDL)")
    ap.add_argument("-m", "--module", required=True)
    ap.add_argument("--apply", action="store_true", help="ghi thật (mặc định dry-run)")
    a = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8")
    root = find_root()
    reg = load_registry(root)
    pops, ddls = module_files(root, a.module)
    if not pops:
        raise SystemExit(f"Không có 02_populate_*.sql của {a.module}")
    total = 0
    for p in pops:
        text, bom = _read(p)
        text_new, migrated = drop_legacy_iv(text)
        new, wrapped, skipped = encrypt_populate(text_new, reg)
        print(f"== {p.relative_to(root).as_posix()}: bọc {len(wrapped)} cột, chuyển cú pháp cũ (bỏ :aes_iv_hex) {migrated} cột, "
              f"bỏ qua {len(skipped)}")
        for t, c, e in wrapped:
            print(f"   + {t.split('.')[-1]}.{c}  <= {e[:70]}")
        for t, c, why in skipped:
            print(f"   ! {t.split('.')[-1]}.{c}: {why}")
        total += len(wrapped)
        if a.apply and new != text:
            _write(p, new, bom)
    for d in ddls:
        text, bom = _read(d)
        new, tagged = tag_ddl(text, reg)
        bad = non_string_pii(text, reg)
        print(f"== {d.relative_to(root).as_posix()}: gắn nhãn COMMENT {len(tagged)} cột")
        for t, c, ty in bad:
            print(f"   ! KIỂU KHÔNG PHẢI String: {t}.{c} {ty} — ciphertext Base64 là chuỗi, đổi kiểu cột")
        if a.apply and new != text:
            _write(d, new, bom)
    print(("✅ Đã ghi." if a.apply else "ⓘ dry-run: chưa ghi gì (thêm --apply)."), f"Tổng cột bọc: {total}")


if __name__ == "__main__":
    main()
