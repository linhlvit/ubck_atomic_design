#!/usr/bin/env python3
"""
gen_brd_source.py — Sinh / cập nhật BRD Source YAML từ file schema CSDL nguồn.

    BRD/Source/brd_{SOURCE}.yaml                      (1 entry / bảng)
    BRD/Source/{SOURCE}/brd_{SOURCE}_{TABLE}.yaml     (cột của bảng)

Nguồn: file schema khai ở Source/source_systems.csv (cột schema_file), đọc bằng schema_reader.py.
Đây là Giai đoạn 1b + 2 + 4 của skill `source-survey`.

Mặc định chỉ CHẠY THỬ (dry-run): in báo cáo, không ghi. Thêm --apply để ghi.

Nguyên tắc (xem SKILL.md → "Quy tắc nguồn gốc dữ liệu"):
  * Chỉ THÊM / CẬP NHẬT, không bao giờ xoá bảng, cột, entry hay quan hệ.
  * Giá trị curated (vắng *_src) không bị ghi đè. Thứ tự: curated > db/schema > inferred.
  * data_type, PK luôn lấy từ schema.
  * FK: curated > db (cột "Lien ket") > inferred (tên cột *_ID khớp tên bảng).
  * Bảng mới: scope_status=pending; functional_group chờ người thiết kế điền.
  * Chỉ ghi khi nội dung ghi ra không phát sinh lỗi JSON schema MỚI so với bản hiện có.

Dùng:
    python scripts/gen_brd_source.py --source NHNCK                  # chạy thử
    python scripts/gen_brd_source.py --source NHNCK --apply
    python scripts/gen_brd_source.py --source FIMS --exclude "*_BK*,*_BAK_*,FLYWAY*" --apply
    python scripts/gen_brd_source.py --source XXX --description "Mô tả source" --apply   # source mới
"""
from __future__ import annotations

import argparse
import copy
import csv
import fnmatch
import io
import json
import re
import sys
from collections import Counter, OrderedDict, defaultdict
from pathlib import Path

import yaml

sys.path.insert(0, str(Path(__file__).resolve().parent))
import schema_reader as sr  # noqa: E402

REPO = Path(__file__).resolve().parent.parent
SCHEMA_DIR = REPO / "schemas"

DEFAULT_BA = "username@fssc.com.vn"
DEFAULT_STEWARD = "username@ubck.com.vn"
GROUP_PLACEHOLDER = "CHƯA PHÂN NHÓM"
SUSPECT_RE = re.compile(r"(^|_)(BK|BAK|BACKUP|OLD|TMP|TEMP|CLONE|BU)(_|\d|$)|FLYWAY|^DYNAMIC", re.I)
FK_NOTE_RE = re.compile(r"FK\s*→\s*(\S+?)\.(\S+)")

UPDATE_KW = ("updated", "modified", "lastupdate", "lastsync", "syncupdated")
CREATE_KW = ("created", "insert", "create")
LOGLIKE_TOKENS = {"LOG", "LOGS", "HISTORY", "HIS", "HIST", "ARCHIVE", "ARCHIVES", "AUDIT"}
DATE_TYPE_RE = re.compile(r"^(DATE|TIMESTAMP)", re.I)
DATE_NAME_RE = re.compile(r"(date|time|_at$|_dt$|_on$)", re.I)

try:
    _Loader = yaml.CSafeLoader
except AttributeError:
    _Loader = yaml.SafeLoader


# ──────────────────────────────────────────────────────────────────────────────
# YAML I/O — giữ BOM / xuống dòng / độ rộng dòng của file hiện có
# ──────────────────────────────────────────────────────────────────────────────

class YFile:
    """Một file YAML đã đọc: dữ liệu + thông tin định dạng để ghi lại ít diff nhất."""

    def __init__(self, path: Path, data, bom: bool, newline: str, width: int, text: str):
        self.path, self.data, self.bom, self.newline, self.width, self.text = path, data, bom, newline, width, text

    @staticmethod
    def dump(data, width: int) -> str:
        return yaml.dump(data, Dumper=yaml.SafeDumper, allow_unicode=True, sort_keys=False,
                         default_flow_style=False, width=width)

    @classmethod
    def load(cls, path: Path) -> "YFile":
        raw = path.read_bytes()
        bom = raw.startswith(b"\xef\xbb\xbf")
        text = raw.decode("utf-8-sig")
        newline = "\r\n" if "\r\n" in text else "\n"
        norm = text.replace("\r\n", "\n")
        data = yaml.load(norm, Loader=_Loader)
        return cls(path, data, bom, newline, best_width(norm, data), norm)

    def write(self, data) -> None:
        text = self.dump(data, self.width)
        if yaml.load(text, Loader=_Loader) != data:   # chốt an toàn
            raise RuntimeError(f"{self.path.name}: dump không khớp dữ liệu dự kiến — dừng, không ghi")
        self.write_text(text)

    def write_text(self, text: str) -> None:
        out = text.replace("\n", self.newline)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.path.write_bytes((b"\xef\xbb\xbf" if self.bom else b"") + out.encode("utf-8"))


_WIDTHS = (80, 85, 100, 120, 160, 200, 245, 290, 1000, 10 ** 9)


def _difflines(a: str, b: str) -> int:
    import difflib
    return sum(1 for ln in difflib.unified_diff(a.splitlines(), b.splitlines(), lineterm="", n=0)
               if ln[:1] in "+-" and ln[:3] not in ("+++", "---"))


def best_width(norm_text: str, data) -> int:
    """Width cho bản dump giống file gốc nhất (file bị sửa tay nên không phải lúc nào cũng khớp 100%)."""
    best = (None, 80)
    for w in _WIDTHS:
        d = _difflines(norm_text, YFile.dump(data, w))
        if d == 0:
            return w
        if best[0] is None or d < best[0]:
            best = (d, w)
    return best[1]


def patch_top(top: "YFile", data: dict, changed: set, new_entries: list, removed: frozenset = frozenset()) -> str:
    """Vá brd_{SOURCE}.yaml theo khối: chỉ thay entry đổi + nối entry mới; entry khác giữ nguyên từng byte.
    (File tổng hợp bị sửa tay nhiều lần nên dump lại toàn file sẽ rewrap hàng nghìn dòng.)"""
    lines = top.text.split("\n")
    idx = [i for i, ln in enumerate(lines) if ln.startswith("- brd_id:")]
    if not idx:
        return YFile.dump(data, top.width)
    out = ["\n".join(lines[:idx[0]]) + "\n"]
    new_by = {str(e["content"]["table"]).upper(): e for e in data["brd_entries"]}
    for n, i in enumerate(idx):
        j = idx[n + 1] if n + 1 < len(idx) else len(lines)
        block = "\n".join(lines[i:j]).rstrip("\n") + "\n"
        old = yaml.load(block, Loader=_Loader)[0]
        key = str(old["content"]["table"]).upper()
        if key in removed:
            continue
        if key in changed:
            w = min(_WIDTHS, key=lambda w: (_difflines(block, YFile.dump([old], w)), w))
            block = YFile.dump([new_by[key]], w)
        out.append(block)
    for e in new_entries:
        out.append(YFile.dump([e], 80))
    text = "".join(out)
    if yaml.load(text, Loader=_Loader) != data:      # chốt an toàn: nội dung vá phải bằng dữ liệu dự kiến
        raise RuntimeError("patch_top: kết quả không khớp dữ liệu dự kiến — dừng, không ghi")
    return text


# ──────────────────────────────────────────────────────────────────────────────
# JSON schema — chỉ chặn lỗi MỚI
# ──────────────────────────────────────────────────────────────────────────────

def _validators():
    import jsonschema
    s1 = json.loads((SCHEMA_DIR / "brd_source.schema.json").read_text(encoding="utf-8"))
    s2 = json.loads((SCHEMA_DIR / "brd_source_columns.schema.json").read_text(encoding="utf-8"))
    entry_schema = {"$ref": "#/definitions/brd_entry", "definitions": s1["definitions"]}
    return (jsonschema.Draft7Validator(entry_schema), jsonschema.Draft7Validator(s2),
            jsonschema.Draft7Validator({k: v for k, v in s1.items() if k != "brd_entries"} | {
                "properties": {k: v for k, v in s1["properties"].items() if k != "brd_entries"},
                "required": [r for r in s1["required"] if r != "brd_entries"]}))


def _msgs(validator, obj) -> set:
    return {(e.validator, "/".join(str(p) for p in e.path if not isinstance(p, int)), e.message[:90])
            for e in validator.iter_errors(obj)}


# ──────────────────────────────────────────────────────────────────────────────
# Quy tắc nghiệp vụ
# ──────────────────────────────────────────────────────────────────────────────

def to_snake_lower(col: str) -> str:
    return re.sub(r"([a-z\d])([A-Z])", r"\1_\2", col).upper().lower()


def humanize(name: str) -> str:
    return " ".join(w.lower() for w in re.split(r"[_\s]+", name) if w)


def decide_ingestion(table: sr.Table):
    """(ingestion dict, lý do) theo Giai đoạn 4.1 của SKILL."""
    cols = table.columns
    norm = {c.name: c.name.lower().replace("_", "") for c in cols}
    has_update = any(any(k in n for k in UPDATE_KW) for n in norm.values())
    if has_update:
        return {"data_change_mode": "Update", "filter_logic": None, "filter_note": None}, "có cột cập nhật"

    def pick_date(candidates):
        dated = [c for c in candidates if DATE_TYPE_RE.match(c.data_type)]
        named = [c for c in dated if DATE_NAME_RE.search(c.name)]
        return (named or dated or [None])[0]

    created = [c for c in cols if any(k in norm[c.name] for k in CREATE_KW)]
    if created:
        col = pick_date(created)
        if col is not None:
            return _append(col), f"chỉ có cột tạo ({col.name})"
    tokens = set(re.split(r"_+", table.name.upper()))
    if tokens & LOGLIKE_TOKENS:                    # Bước 2: bảng log/lịch sử append-only
        col = pick_date(cols)
        if col is not None:
            return _append(col), f"bảng log/lịch sử, cột ngày {col.name} (đoán — cần duyệt)"
    return {"data_change_mode": "Update", "filter_logic": None, "filter_note": None}, "mặc định Update"


def _append(col: sr.Column):
    c = to_snake_lower(col.name)
    meaning = (col.comment or f"cột ngày {col.name}").strip()
    return {"data_change_mode": "Append",
            "filter_logic": f"{c} >= {{etl_date}} AND {c} < {{etl_date}} + 1",
            "filter_note": f"{meaning} — append theo {col.name.upper()}"}


def fk_note_of(ref_table: str, ref_col: str) -> str:
    return f"FK → {ref_table}.{ref_col}"


def parse_fk_note(note):
    m = FK_NOTE_RE.search(note or "")
    return (m.group(1).upper(), m.group(2).upper()) if m else None


# ──────────────────────────────────────────────────────────────────────────────
# Dựng file cột
# ──────────────────────────────────────────────────────────────────────────────

def build_column_dict(base: dict | None, name: str, dtype: str, desc, key, fk_note, fk_src, extra=None):
    d = OrderedDict()
    d["name"] = name
    d["data_type"] = dtype
    d["description"] = desc
    d["key"] = key
    d["fk_note"] = fk_note
    if fk_src:
        d["fk_src"] = fk_src
    for k, v in (extra or {}).items():             # giữ trường lạ có sẵn (nullable, values…)
        d[k] = v
    return dict(d)


def merge_columns(table: sr.Table, existing: dict | None, fk_db: dict, fk_inf: dict, rep: dict):
    """Trả về dict file cột mới. rep: bộ đếm/ghi chú cho báo cáo."""
    tname = table.name
    old_cols = list((existing or {}).get("columns") or [])
    old_by = {str(c.get("name", "")).upper(): c for c in old_cols}
    schema_by = {c.name.upper(): c for c in table.columns}

    def merged(col: sr.Column, old: dict | None):
        pk = bool(col.key and "PK" in col.key)
        # mô tả
        if old is None:
            desc = col.comment or None
        else:
            desc = old.get("description")
            if not desc and col.comment:              # chỉ điền khi trống — không ghi đè mô tả đã có
                desc = col.comment
                rep["desc_filled"] += 1
        # FK
        fk, fksrc = (old or {}).get("fk_note"), (old or {}).get("fk_src")
        cand_db, cand_inf = fk_db.get((tname, col.name)), fk_inf.get((tname, col.name))
        changed_fk = False
        if fk and fksrc is None:                     # curated — giữ; so với DB để báo conflict
            if cand_db and parse_fk_note(fk) != (cand_db.ref_table.upper(), cand_db.ref_column.upper()):
                rep["fk_conflict"].append(f"{tname}.{col.name}: YAML '{fk}' ≠ DB '{fk_note_of(cand_db.ref_table, cand_db.ref_column)}'")
        elif cand_db:
            new = fk_note_of(cand_db.ref_table, cand_db.ref_column)
            if (fk, fksrc) != (new, "db"):
                changed_fk = True
                rep["fk_db"] += 1
            fk, fksrc = new, "db"
        elif cand_inf and (not fk or fksrc == "inferred"):
            new = fk_note_of(cand_inf.ref_table, cand_inf.ref_column)
            if (fk, fksrc) != (new, "inferred"):
                changed_fk = True
                rep["fk_inferred"] += 1
            fk, fksrc = new, "inferred"
        elif fksrc in ("db", "inferred"):            # không còn căn cứ → bỏ gợi ý
            fk, fksrc, changed_fk = None, None, True
            rep["fk_dropped"].append(f"{tname}.{col.name}")
        # key
        old_key = (old or {}).get("key")
        fk_part = (fk is not None) if (old is None or changed_fk) else ("FK" in (old_key or ""))
        key = "PK/FK" if pk and fk_part else "PK" if pk else "FK" if fk_part else None
        if old is not None and old_key != key:
            if not pk and old_key and "PK" in old_key:
                rep["pk_changed"].append(f"{tname}.{col.name}: {old_key} → {key}")
        extra = {k: v for k, v in (old or {}).items()
                 if k not in ("name", "data_type", "description", "key", "fk_note", "fk_src")}
        dtype = col.data_type.strip()                # data_type luôn theo đúng chuỗi trong file schema
        if old is not None and str(old.get("data_type") or "").strip() != dtype:
            rep["type_changed"] += 1
        return build_column_dict(old, old.get("name", col.name) if old else col.name, dtype,
                                 desc, key, fk, fksrc, extra)

    out = []
    for c in old_cols:                                # giữ thứ tự cũ
        s = schema_by.get(str(c.get("name", "")).upper())
        if s is None:
            if rep["prune"]:                          # --prune: cột không còn trong schema → xoá
                rep["col_pruned"].append(f"{tname}.{c.get('name')}")
                continue
            rep["col_only_yaml"].append(f"{tname}.{c.get('name')}")
            out.append(c)
        else:
            out.append(merged(s, c))
    for col in table.columns:                         # cột mới → cuối
        if col.name.upper() not in old_by:
            out.append(merged(col, None))
            rep["col_new"] += 1
    doc = OrderedDict()
    base = existing or {}
    doc["schema_type"] = base.get("schema_type", "brd_source_columns")
    doc["schema_version"] = base.get("schema_version", "1.0")
    doc["source"] = base.get("source", rep["source"])
    doc["table"] = base.get("table", tname)
    doc["brd_ref"] = base.get("brd_ref", f"BRD-SRC-{rep['source']}-{tname}")
    for k, v in base.items():
        if k not in doc and k != "columns":
            doc[k] = v
    doc["columns"] = out
    return dict(doc)


# ──────────────────────────────────────────────────────────────────────────────
# main
# ──────────────────────────────────────────────────────────────────────────────

def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--source", required=True)
    ap.add_argument("--apply", action="store_true", help="Ghi file (mặc định: chỉ chạy thử)")
    ap.add_argument("--exclude", default="", help="Mẫu tên bảng bỏ qua, ngăn bởi dấu phẩy (fnmatch, không phân biệt hoa/thường)")
    ap.add_argument("--prune", action="store_true",
                    help="XOÁ bảng (entry + file cột) và cột không còn trong schema. Mặc định tắt (chỉ giữ + báo cáo). "
                         "Chỉ dùng khi người thiết kế đã đồng ý xoá cho source đó")
    ap.add_argument("--description", default="", help="Mô tả source (chỉ cần khi tạo brd_{SOURCE}.yaml mới và source_systems.csv trống mô tả)")
    ap.add_argument("--root", default=str(REPO), help=argparse.SUPPRESS)  # dùng cho test
    args = ap.parse_args()
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

    root = Path(args.root)
    S = args.source.upper()
    brd_dir = root / "BRD" / "Source"
    top_path = brd_dir / f"brd_{S}.yaml"
    col_dir = brd_dir / S

    try:
        doc = sr.load_source(S, root)
    except (FileNotFoundError, KeyError) as e:
        print(f"[ERROR] {e}", file=sys.stderr)
        return 2
    for w in doc.warnings:
        print(f"[WARN schema] {w}")

    excl = [p.strip().upper() for p in args.exclude.split(",") if p.strip()]
    tables = {n: t for n, t in doc.tables.items() if not any(fnmatch.fnmatchcase(n.upper(), p) for p in excl)}
    excluded = sorted(set(doc.tables) - set(tables))

    # ── đọc YAML hiện có
    top = YFile.load(top_path) if top_path.exists() else None
    if top:
        top_data = copy.deepcopy(top.data)
    else:
        desc = args.description
        if not desc:
            with open(root / "Source" / "source_systems.csv", encoding="utf-8-sig", newline="") as f:
                desc = next((r["description"] for r in csv.DictReader(f)
                             if r["source_system"].upper() == S), "") or ""
        if len(desc) < 10:
            print("[ERROR] Source mới cần mô tả ≥ 10 ký tự: truyền --description \"...\" "
                  "(hoặc điền description trong Source/source_systems.csv)", file=sys.stderr)
            return 2
        top_data = {"source": S, "description": desc, "brd_entries": []}
    entries = top_data.get("brd_entries") or []
    entry_by = {str(e["content"]["table"]).upper(): e for e in entries}

    colfiles: dict[str, YFile] = {}
    if col_dir.is_dir():
        for p in sorted(col_dir.glob("brd_*.yaml")):
            yf = YFile.load(p)
            if isinstance(yf.data, dict) and yf.data.get("table"):
                colfiles[str(yf.data["table"]).upper()] = yf

    # newline / BOM cho file mới: theo file có sẵn
    sample = top or next(iter(colfiles.values()), None)
    default_nl = sample.newline if sample else "\n"
    top_bom = top.bom if top else True

    ba = Counter(e.get("ba_email") for e in entries if e.get("ba_email")).most_common(1)
    st = Counter(e.get("steward_email") for e in entries if e.get("steward_email")).most_common(1)
    ba_email, steward = (ba[0][0] if ba else DEFAULT_BA), (st[0][0] if st else DEFAULT_STEWARD)

    # ── FK
    fk_db = {(f.table, f.column): f for f in sr.db_fks(doc)}
    fk_inf = {(f.table, f.column): f for f in sr.infer_fks(doc)}

    rep = defaultdict(int)
    for k in ("fk_conflict", "fk_dropped", "pk_changed", "col_only_yaml", "col_pruned"):
        rep[k] = []
    rep["source"] = S
    rep["prune"] = args.prune

    new_tables, matched = [], []
    for n in tables:
        (matched if n.upper() in entry_by else new_tables).append(n)
    only_in_yaml = sorted(k for k in entry_by if k not in {n.upper() for n in doc.tables})

    # ── --prune: xoá bảng không còn trong schema
    removed: set = set()
    removed_files: list = []
    pruned_info: list = []
    dangling = 0
    if args.prune and only_in_yaml:
        n_orig = len(entries)
        if n_orig >= 10 and len(only_in_yaml) > 0.6 * n_orig:
            print(f"[ERROR] --prune sẽ xoá {len(only_in_yaml)}/{n_orig} bảng (>60%) — nghi file schema sai/thiếu. "
                  f"Kiểm tra schema_file của {S} rồi chạy lại.", file=sys.stderr)
            return 2
        removed = set(only_in_yaml)
        lld_dir = root / "DataModel" / "working" / "Atomic" / "lld" / S
        lld_files = {p.name.upper() for p in lld_dir.glob("lld_*.yaml")} if lld_dir.is_dir() else set()
        for k in only_in_yaml:
            c = entry_by[k]["content"]
            has_lld = f"LLD_{S}_{k}.YAML" in lld_files
            pruned_info.append((c["table"], c.get("scope_status"), has_lld))
            if k in colfiles:
                removed_files.append(colfiles[k].path)
        entries[:] = [e for e in entries if str(e["content"]["table"]).upper() not in removed]
        for k in removed:
            entry_by.pop(k, None)
        for e in entries:                              # gỡ tham chiếu related_tables tới bảng đã xoá
            lst = e["content"].get("related_tables")
            if lst:
                keep = [r for r in lst if str(r.get("table", "")).upper() not in removed]
                if len(keep) != len(lst):
                    dangling += len(lst) - len(keep)
                    e["content"]["related_tables"] = keep or None

    # ── file cột
    new_colfiles: dict[str, dict] = {}
    for n, t in tables.items():
        old = colfiles.get(n.upper())
        new_colfiles[n] = merge_columns(t, old.data if old else None, fk_db, fk_inf, rep)

    # ── entry bảng
    ingestion_notes = []
    meaning_of = {}
    for n, t in tables.items():
        e = entry_by.get(n.upper())
        meaning_of[n.upper()] = (e or {}).get("content", {}).get("table_meaning") or t.comment or f"Bảng {humanize(n)}"

    for n in new_tables:
        t = tables[n]
        ing, why = decide_ingestion(t)
        ingestion_notes.append((n, ing["data_change_mode"], why))
        c = OrderedDict()
        c["table_meaning"] = t.comment or None       # nguồn không cung cấp → null (không bịa)
        c["functional_group"] = GROUP_PLACEHOLDER
        c["scope_status"] = "pending"
        c["scope_reason"] = None
        c["table"] = n
        c["related_tables"] = None
        c["notes"] = None
        c["data_volume_hint"] = None
        c["refresh_frequency"] = None
        c["ingestion"] = ing
        e = {"brd_id": f"BRD-SRC-{S}-{n}", "brd_name": f"Design Atomic từ nguồn {S} bảng {n}",
             "type": "Theo Source", "ba_email": ba_email, "steward_email": steward, "content": dict(c)}
        entries.append(e)
        entry_by[n.upper()] = e

    entry_changes = Counter()
    for n in matched:
        e, t = entry_by[n.upper()], tables[n]
        c = e["content"]
        if not c.get("table_meaning") and t.comment:
            c["table_meaning"] = t.comment
            entry_changes["table_meaning"] += 1
        if "ingestion" not in c or c.get("ingestion") is None and c.get("scope_status") != "out_of_scope":
            ing, why = decide_ingestion(t)
            c["ingestion"] = ing
            ingestion_notes.append((n, ing["data_change_mode"], why))
            entry_changes["ingestion"] += 1

    # related_tables — chỉ THÊM
    fk_edges = []
    for n, cd in new_colfiles.items():
        for col in cd["columns"]:
            ref = parse_fk_note(col.get("fk_note"))
            if ref and ref[0] != n.upper() and ref[0] in entry_by:
                fk_edges.append((n, entry_by[ref[0]]["content"]["table"]))
    rel_added = 0
    for child, parent in dict.fromkeys(fk_edges):
        for owner, other, text in ((child, parent, "FK cha — "), (parent, child, "1-N — ")):
            oe = entry_by.get(owner.upper())
            if oe is None:
                continue
            c = oe["content"]
            lst = c.get("related_tables") or []
            if any(str(r.get("table", "")).upper() == other.upper() for r in lst):
                continue
            meaning = meaning_of.get(other.upper()) or humanize(other)
            lst.append({"table": other, "relation": f"{text}{meaning}"})
            c["related_tables"] = lst
            rel_added += 1

    # ── gợi ý đổi tên (bảng chỉ có ở YAML ↔ bảng chỉ có ở schema)
    rename_hints = []
    for oy in only_in_yaml:
        yf = colfiles.get(oy)
        if not yf:
            continue
        ycols = {str(c.get("name", "")).upper() for c in yf.data.get("columns") or []}
        for n in new_tables:
            scols = {c.name.upper() for c in tables[n].columns}
            if ycols and len(ycols & scols) / len(ycols | scols) >= 0.8:
                rename_hints.append((oy, n))

    # ── validate: chỉ chặn lỗi MỚI
    v_entry, v_cols, v_top = _validators()
    bad = []
    changed_entries = []
    orig_entries = {str(e["content"]["table"]).upper(): e for e in (top.data.get("brd_entries") if top else []) or []}
    for k, e in entry_by.items():
        old = orig_entries.get(k)
        if old is None or old != e:
            changed_entries.append(k)
            new_err = _msgs(v_entry, e) - (_msgs(v_entry, old) if old else set())
            if new_err:
                bad.append((f"entry {k}", sorted(new_err)))
    changed_cols = []
    for n, cd in new_colfiles.items():
        old = colfiles.get(n.upper())
        if old is None or old.data != cd:
            changed_cols.append(n)
            new_err = _msgs(v_cols, cd) - (_msgs(v_cols, old.data) if old else set())
            if new_err:
                bad.append((f"file cột {n}", sorted(new_err)))
    if not top:
        new_err = _msgs(v_top, {k: v for k, v in top_data.items() if k != "brd_entries"})
        if new_err:
            bad.append(("brd_" + S + ".yaml (đầu file)", sorted(new_err)))

    # ── báo cáo
    ncols_new = sum(len(d["columns"]) for d in new_colfiles.values())
    print(f"\n=== {S}: {len(doc.tables)} bảng trong schema"
          f"{f' ({len(excluded)} bị loại bởi --exclude)' if excluded else ''} ===")
    print(f"Bảng: {len(matched)} khớp | {len(new_tables)} mới (chỉ có ở schema) | "
          + (f"{len(removed)} XOÁ (không còn trong schema)" if args.prune
             else f"{len(only_in_yaml)} chỉ có ở YAML (giữ nguyên)"))
    print(f"Cột : +{rep['col_new']} mới | "
          + (f"{len(rep['col_pruned'])} XOÁ" if args.prune else f"{len(rep['col_only_yaml'])} chỉ có ở YAML (giữ)") + " | "
          f"{rep['type_changed']} đổi data_type theo schema | "
          f"+{rep['desc_filled']} mô tả lấy từ schema")
    print(f"FK  : +{rep['fk_db']} từ DB | +{rep['fk_inferred']} inferred | {len(rep['fk_conflict'])} conflict | "
          f"{len(rep['fk_dropped'])} gợi ý bị bỏ | +{rel_added} quan hệ related_tables")
    print(f"Ghi : {len(changed_entries)} entry đổi/mới trong brd_{S}.yaml | {len(changed_cols)} file cột đổi/mới "
          f"(trên {len(new_colfiles)} bảng, {ncols_new} cột)")

    def show(title, items, limit=15):
        if items:
            print(f"\n{title} ({len(items)}):")
            for it in items[:limit]:
                print("  - " + str(it))
            if len(items) > limit:
                print(f"  … và {len(items) - limit} mục nữa")

    show("Bảng mới → scope_status=pending, functional_group chưa điền", new_tables, 40)
    suspect = [n for n in new_tables if SUSPECT_RE.search(n)]
    show("  ⚠ nghi bảng backup/hệ thống (cân nhắc --exclude rồi chạy lại)", suspect)
    show("Ingestion quyết định cho bảng mới/thiếu ingestion", [f"{n}: {m} — {w}" for n, m, w in ingestion_notes if m == "Append" or "đoán" in w], 30)
    show("FK conflict (giữ curated — người thiết kế quyết)", rep["fk_conflict"], 30)
    show("PK bị gỡ so với YAML cũ", rep["pk_changed"])
    show("Cột chỉ có ở YAML (nghi bị đổi tên/bỏ trên schema)", rep["col_only_yaml"])
    show("Cột bị XOÁ (không còn trong schema)", rep["col_pruned"], 40)
    if args.prune:
        show("Bảng bị XOÁ (entry + file cột)",
             [f"{t}  [{s}]{'  ⚠ còn file LLD' if l else ''}" for t, s, l in pruned_info], 80)
        inscope = [t for t, s, l in pruned_info if s == "in_scope"]
        withlld = [t for t, s, l in pruned_info if l]
        if inscope or withlld:
            print(f"\n⚠ Trong số bảng xoá: {len(inscope)} bảng in_scope, {len(withlld)} bảng còn file LLD "
                  f"(DataModel/working/Atomic/lld/{S}/) — LLD/manifest/atomic_attributes tham chiếu cần dọn riêng; "
                  f"chạy post_check_source_coverage.py (CHECK B) để thấy ghost mapping.")
        if dangling:
            print(f"Đã gỡ {dangling} dòng related_tables trỏ tới bảng bị xoá.")
    else:
        show("Bảng chỉ có ở YAML", only_in_yaml, 30)
    show("Nghi đổi tên bảng (≥80% cột trùng)", [f"{a} → {b}" for a, b in rename_hints])
    show("Bảng bị loại bởi --exclude", excluded, 30)
    if bad:
        print("\n[LỖI SCHEMA MỚI] — không ghi:")
        for what, errs in bad:
            print(f"  {what}")
            for e in errs[:5]:
                print(f"     {e}")
        return 1

    nothing = not changed_entries and not changed_cols and not removed
    if nothing:
        print("\nKhông có thay đổi nào cần ghi.")
        return 0
    if not args.apply:
        print("\n(chạy thử — thêm --apply để ghi)")
        return 0

    # ── ghi
    n_before = len(top.data.get("brd_entries") or []) if top else 0
    assert len(entries) >= n_before - len(removed), "số entry giảm quá mức dự kiến — dừng"
    top_data["brd_entries"] = entries
    if top:
        keys_in_order = [str(e["content"]["table"]).upper() for e in entries]
        new_keys = set(keys_in_order) - set(orig_entries)
        changed_old = {k for k in changed_entries if k in orig_entries}
        top.write_text(patch_top(top, top_data, changed_old,
                                 [entry_by[k] for k in keys_in_order if k in new_keys], frozenset(removed)))
    else:
        YFile(top_path, None, top_bom, default_nl, 80, "").write(top_data)
    for n in changed_cols:
        old = colfiles.get(n.upper())
        if old:
            if not args.prune:
                assert len(new_colfiles[n]["columns"]) >= len(old.data.get("columns") or []), f"{n}: số cột giảm — dừng"
            old.write(new_colfiles[n])
        else:
            YFile(col_dir / f"brd_{S}_{n}.yaml", None, False, default_nl, 80, "").write(new_colfiles[n])
    for p in removed_files:
        p.unlink()
    if removed:
        print(f"\nĐã xoá {len(removed)} entry và {len(removed_files)} file cột.")
    print(f"\nĐã ghi: brd_{S}.yaml + {len(changed_cols)} file cột. "
          f"Tiếp theo: điền functional_group cho bảng mới, rồi chạy `python scripts/generate_brd_summary.py`.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
