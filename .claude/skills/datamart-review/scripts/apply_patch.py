# -*- coding: utf-8 -*-
"""
apply_patch.py — ghi khối Nhóm đã soạn ngược vào HLD / Detail Mapping gốc.

VÌ SAO
    Không có bước này thì agent phải Read cả `DTM_QLKD_Detail_Mapping.csv` (552K token)
    chỉ để sửa vài dòng. SKILL.md hiện mô tả đường ghi là "append block" — đúng khi viết
    mới, SAI khi sửa lại một Nhóm đã có (sinh ra Nhóm trùng, phá thứ tự TC6).
    Script này thay thế ĐÚNG khối/đúng các dòng của Nhóm N, giữ nguyên phần còn lại.

AN TOÀN
    - `--dry-run` in diff, không ghi gì.
    - Mỗi lần ghi thật đều sao lưu vào `Datamart/context/.backup/` kèm dấu thời gian.
    - Ghi CSV qua `csv_io.write_design_csv` (giữ QUOTE_ALL + UTF-8 BOM + đọc lại xác minh).
    - Chèn Nhóm mới vào Detail Mapping đặt đúng vị trí theo SỐ nhóm tăng dần để không
      phá TC6 (`lld_selfcheck.py --tc 6`).

DÙNG
    # soạn: ctx_slice.py -m PTTT --nhom 8  ->  sửa file  ->  ghi ngược:
    python apply_patch.py -m PTTT --target hld --nhom 8 --from khoi_moi.md --dry-run
    python apply_patch.py -m PTTT --target hld --nhom 8 --from khoi_moi.md

    python apply_patch.py -m PTTT --target dm --nhom 8 --from rows_moi.csv --dry-run
    python apply_patch.py -m PTTT --target dm --nhom 8 --from rows_moi.csv

    # Nhóm chưa tồn tại trong HLD -> phải nói rõ chèn sau Nhóm nào
    python apply_patch.py -m PTTT --target hld --nhom 35 --from moi.md --insert-after 34
"""
from __future__ import annotations

import argparse
import difflib
import re
import shutil
import sys
from datetime import datetime
from pathlib import Path
from typing import List, Optional, Tuple

_script_dir = Path(__file__).resolve().parent
if str(_script_dir) not in sys.path:
    sys.path.insert(0, str(_script_dir))

for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from datamart_common import find_project_root, resolve_module_path  # noqa: E402
from datamart_common.csv_io import DesignCsv, read_design_csv, write_design_csv  # noqa: E402

BACKUP_REL = "Datamart/context/.backup"
_RE_NHOM_NUM = re.compile(r"(?:Nhóm|Nhom|Group)\s*(\d+)", re.IGNORECASE)


def _nhom_re(n: str) -> re.Pattern:
    return re.compile(rf"^####\s*(?:Nhóm|Nhom|Group)\s*0*{re.escape(str(n))}\b", re.IGNORECASE)


def backup(root: Path, p: Path) -> Path:
    d = root / BACKUP_REL
    d.mkdir(parents=True, exist_ok=True)
    out = d / f"{p.stem}.{datetime.now():%Y%m%d-%H%M%S}{p.suffix}"
    shutil.copy2(p, out)
    return out


def show_diff(old: List[str], new: List[str], name: str) -> bool:
    diff = list(difflib.unified_diff(old, new, fromfile=f"a/{name}", tofile=f"b/{name}",
                                     lineterm="", n=2))
    if not diff:
        print("ⓘ Không có thay đổi nào — nội dung mới trùng nội dung hiện tại.")
        return False
    for line in diff[:400]:
        print(line)
    if len(diff) > 400:
        print(f"… (còn {len(diff) - 400} dòng diff)")
    adds = sum(1 for x in diff if x.startswith("+") and not x.startswith("+++"))
    dels = sum(1 for x in diff if x.startswith("-") and not x.startswith("---"))
    print(f"\n→ {adds} dòng thêm, {dels} dòng bớt.")
    return True


# ---------------------------------------------------------------------------
# HLD
# ---------------------------------------------------------------------------
def clean_payload(text: str) -> str:
    """Bỏ phần ctx_slice.py thêm vào (comment nguồn + dòng `### Tab` bao ngoài)."""
    lines = text.replace("\r\n", "\n").split("\n")
    while lines and (lines[0].strip().startswith("<!--") or not lines[0].strip()):
        lines.pop(0)
    if lines and lines[0].startswith("### "):
        lines.pop(0)
        while lines and not lines[0].strip():
            lines.pop(0)
    return "\n".join(lines).rstrip()


def patch_hld(root: Path, path: Path, nhom: str, payload: str,
              insert_after: Optional[str]) -> Tuple[List[str], List[str]]:
    lines = path.read_text(encoding="utf-8").split("\n")
    body = clean_payload(payload)
    if not _nhom_re(nhom).match(body.split("\n")[0] if body else ""):
        raise SystemExit(f"❌ Nội dung mới phải bắt đầu bằng `#### Nhóm {nhom} …`, "
                         f"hiện bắt đầu bằng: {body.split(chr(10))[0][:80]!r}")

    pat = _nhom_re(nhom)
    start = next((i for i, l in enumerate(lines) if pat.match(l)), None)

    if start is not None:
        end = len(lines)
        for i in range(start + 1, len(lines)):
            if lines[i].startswith("#### ") or lines[i].startswith("### ") \
                    or lines[i].startswith("## "):
                end = i
                break
        new = lines[:start] + body.split("\n") + [""] + lines[end:]
        return lines, new

    if insert_after is None:
        raise SystemExit(f"❌ HLD chưa có `#### Nhóm {nhom}`. Nếu muốn chèn mới, "
                         f"nói rõ vị trí bằng `--insert-after <số Nhóm>`.")
    apat = _nhom_re(insert_after)
    astart = next((i for i, l in enumerate(lines) if apat.match(l)), None)
    if astart is None:
        raise SystemExit(f"❌ Không thấy `#### Nhóm {insert_after}` để chèn sau.")
    aend = len(lines)
    for i in range(astart + 1, len(lines)):
        if lines[i].startswith("#### ") or lines[i].startswith("### ") or lines[i].startswith("## "):
            aend = i
            break
    new = lines[:aend] + body.split("\n") + [""] + lines[aend:]
    return lines, new


# ---------------------------------------------------------------------------
# Detail Mapping
# ---------------------------------------------------------------------------
def patch_dm(path: Path, nhom: str, src: Path) -> Tuple[DesignCsv, DesignCsv]:
    cur = read_design_csv(path, strict=False)
    inc = read_design_csv(src, strict=False)
    if [h.strip() for h in inc.header] != [h.strip() for h in cur.header]:
        raise SystemExit("❌ Header file nguồn khác header Detail Mapping.\n"
                         f"   nguồn: {inc.header}\n   đích  : {cur.header}")
    j = cur.ix["nhom"]
    pat = re.compile(rf"^\s*(?:Nhóm|Nhom|Group)?\s*0*{re.escape(str(nhom))}\b", re.IGNORECASE)

    bad = [n for n, r in enumerate(inc.rows, start=2)
           if not (j < len(r) and pat.match(r[j]))]
    if bad:
        raise SystemExit(f"❌ File nguồn có {len(bad)} dòng KHÔNG thuộc Nhóm {nhom} "
                         f"(dòng {bad[:10]}). Mỗi lần patch chỉ xử lý đúng một Nhóm.")

    keep_before, keep_after, hit = [], [], False
    for r in cur.rows:
        if j < len(r) and pat.match(r[j]):
            hit = True
            continue
        (keep_after if hit else keep_before).append(r)

    if hit:
        rows = keep_before + inc.rows + keep_after
    else:
        # Nhóm mới -> chèn đúng vị trí theo SỐ nhóm tăng dần, giữ TC6 luôn PASS.
        target = int(nhom) if str(nhom).isdigit() else None
        pos = len(cur.rows)
        if target is not None:
            for k, r in enumerate(cur.rows):
                m = _RE_NHOM_NUM.search(r[j]) if j < len(r) else None
                if m and int(m.group(1)) > target:
                    pos = k
                    break
        rows = cur.rows[:pos] + inc.rows + cur.rows[pos:]

    return cur, DesignCsv(header=cur.header, rows=rows, quote_all=cur.quote_all, path=path)


def main() -> None:
    ap = argparse.ArgumentParser(description="Ghi khối Nhóm ngược vào HLD / Detail Mapping gốc")
    ap.add_argument("-m", "--module", required=True)
    ap.add_argument("--target", required=True, choices=["hld", "dm"])
    ap.add_argument("--nhom", required=True)
    ap.add_argument("--from", dest="src", required=True, help="File chứa nội dung mới")
    ap.add_argument("--insert-after", help="Chỉ với --target hld: chèn sau Nhóm này nếu chưa tồn tại")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--root", default=None)
    args = ap.parse_args()

    root = find_project_root(args.root) if args.root else find_project_root()
    src = Path(args.src)
    if not src.is_file():
        raise SystemExit(f"❌ Không thấy file nguồn: {src}")

    kind = "hld" if args.target == "hld" else "detail_mapping"
    tp = resolve_module_path(root, args.module, kind)
    if not tp:
        raise SystemExit(f"❌ Không thấy {kind} của module {args.module}")
    tp = Path(tp)
    rel = tp.relative_to(root).as_posix()

    if args.target == "hld":
        old, new = patch_hld(root, tp, args.nhom, src.read_text(encoding="utf-8"),
                             args.insert_after)
        if not show_diff(old, new, rel):
            return
        if args.dry_run:
            print("\nⓘ --dry-run: chưa ghi gì.")
            return
        b = backup(root, tp)
        tp.write_text("\n".join(new), encoding="utf-8", newline="\n")
        print(f"\n✅ Đã ghi {rel} (Nhóm {args.nhom}). Sao lưu: {b.relative_to(root).as_posix()}")
    else:
        cur, new = patch_dm(tp, args.nhom, src)
        fmt = lambda t: [",".join(r) for r in t.rows]  # noqa: E731
        if not show_diff(fmt(cur), fmt(new), rel):
            return
        if args.dry_run:
            print("\nⓘ --dry-run: chưa ghi gì.")
            return
        b = backup(root, tp)
        write_design_csv(tp, new, quote_all=cur.quote_all)
        chk = read_design_csv(tp, strict=False)
        if len(chk.rows) != len(new.rows) or chk.header != new.header:
            raise SystemExit(f"❌ Xác minh sau ghi THẤT BẠI. Khôi phục từ {b}")
        print(f"\n✅ Đã ghi {rel}: {len(cur.rows)} → {len(new.rows)} dòng (Nhóm {args.nhom}). "
              f"Sao lưu: {b.relative_to(root).as_posix()}")
    print("→ Chạy lại kiểm tra: "
          f"python .claude/skills/datamart-review/scripts/run_quality_gates.py -m {args.module}")


if __name__ == "__main__":
    main()
