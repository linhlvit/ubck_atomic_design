# -*- coding: utf-8 -*-
"""
render_datamart_md.py — sinh TKCSLD Markdown 100% bằng code từ thiết kế đã duyệt (0 token LLM cho bảng).

VÌ SAO (2026-10-15)
    Trước đây Phase 1 của datamart-gen-docs để Claude tự gõ ~14 bảng 8/12 cột + 3 ERD cho mỗi module:
    tốn hàng chục nghìn token, lệch tên với LLD (tài liệu cũ còn tên viết tắt `fnd_mgt_co_dim` trong khi
    LLD đã đổi sang `fund_management_company_dim`), Source Field Name lấy nhầm cột nguồn thay cột Atomic,
    và rò rỉ ghi chú nội bộ (PENDING O_QLQ_1, [SỬA ...]) ra tài liệu gửi UBCKNN.
    TKCSLD hoàn toàn suy ra được từ dữ liệu thiết kế → script sinh, LLM chỉ còn viết lời dẫn PTTK.

NGUỒN (chỉ ĐỌC)
    Datamart/hld/DTM_{M}_Entities.csv          — danh sách + thứ tự thực thể, loại bảng, mô tả, FKs
    Datamart/lld/*/DTM_*.csv                   — cột (per-table; thực thể reuse lấy từ module sở hữu)
    DataModel/working/Atomic/aggregate/atomic_attributes.yaml — tra Hệ thống nguồn theo (atomic_table, atomic_column)
    reference/module_names_vi.md               — tên module tiếng Việt cho tiêu đề

QUY TẮC (code hóa reference/column_rules.md, data_domain_mapping.md, SKILL.md C.4–C.9)
    P/F Key: PK→P | FK…→F | BK/DD/NK/rỗng→rỗng.  Unique: PK→X.  Nullable: PK/FK→rỗng, nullable=true→X.
    Mặc định: luôn rỗng.  Mô tả: clean_description.clean() (+ mô tả dự phòng nếu clean xong rỗng).
    Trường kỹ thuật (ds_*, eff_dt, expr_dt, ppl_dt) hoặc Generated: nguồn rỗng, ETL Rules = "ETL sinh tự động".
    Schema.Table: ATM.{bảng} nếu bảng là Atomic; DTM.{bảng} nếu là bảng Datamart (MinIO) (lineage mart→mart);
                  bảng không tra được ở cả hai → vẫn ghi ATM.{bảng} và liệt kê trong báo cáo LINEAGE.
    Bảng multi-source (cùng cột, nhiều nguồn): gộp nguồn bằng "; ", ETL Rules ghi "[NGUỒN] logic; …".
    --with-tech-cols: nối 4 cột SCD4A còn thiếu (+ ds_snpst_dt cho bảng *_snpst) vào cuối bảng Physical.
    Mặc định KHÔNG nối — tài liệu đã duyệt hiện không có các dòng này; chỉ bật khi Data Modeler quyết.

DÙNG
    python render_datamart_md.py -m QLQ                 # sinh, KHÔNG ghi đè bản đã có (ghi *.rendered.md)
    python render_datamart_md.py -m QLQ --overwrite     # ghi đè DTM_QLQ_TKCSLD.md (sao lưu .bak-<ts>)
    python render_datamart_md.py -m QLQ --report-only   # chỉ in báo cáo chất lượng, không ghi file
    python render_datamart_md.py -m ALL --report-only
Exit: 0 OK / 1 có lỗi chặn (thực thể không có LLD, mô tả còn rò rỉ sau clean)
"""
from __future__ import annotations

import argparse
import csv
import re
import shutil
import sys
from collections import OrderedDict, defaultdict
from datetime import datetime
from functools import lru_cache
from pathlib import Path

for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

_HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(_HERE))
from clean_description import clean, find_leaks  # noqa: E402

TECH_COLS = ["ds_rcrd_st", "ds_rcrd_isrt_dt", "ds_rcrd_udt_dt", "ds_etl_pcs_tms", "ds_snpst_dt"]
LEGACY_AUDIT = {"eff_dt", "expr_dt", "ppl_dt"}
TECH_DEF = {
    "ds_rcrd_st": ("Record Status", "string", "Trạng thái bản ghi"),
    "ds_rcrd_isrt_dt": ("Record Insert Date", "timestamp", "Ngày ghi nhận bản ghi lần đầu"),
    "ds_rcrd_udt_dt": ("Record Update Date", "timestamp", "Ngày cập nhật bản ghi gần nhất"),
    "ds_etl_pcs_tms": ("ETL Process Timestamp", "timestamp", "Thời điểm xử lý ETL"),
    "ds_snpst_dt": ("Snapshot Date", "date", "Ngày chụp dữ liệu"),
}
DOMAIN_TYPE = {
    "boolean": "boolean", "classification value": "string", "currency amount": "decimal(23,2)",
    "date": "date", "exchange rate": "decimal(12,7)", "indicator": "string", "interest rate": "decimal(8,5)",
    "percentage": "decimal(5,2)", "small counter": "int", "large counter": "bigint", "surrogate key": "string",
    "surrogate dimension key": "string", "text": "string", "timestamp": "timestamp",
}
TYPE_ORDER = {"dim": 0, "fact": 1, "operational": 2}
SECTION = {"dim": ("3.3.2", "Danh sách bảng Dimension"),
           "fact": ("3.3.3", "Danh sách bảng Detail Fact"),
           "operational": ("3.3.4", "Danh sách bảng tác nghiệp (Operational)")}
EXEC = "ETL sinh tự động"


def find_root(start: Path) -> Path:
    for p in [start, *start.parents]:
        if (p / "Datamart").is_dir() and (p / "CLAUDE.md").is_file():
            return p
    raise SystemExit("❌ Không tìm thấy project root (thư mục có Datamart/ + CLAUDE.md)")


def read_csv(path: Path):
    with path.open(encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def cell(s: str) -> str:
    """Giá trị an toàn cho ô bảng Markdown (pandoc pipe table): 1 dòng, escape `|`."""
    s = re.sub(r"\s*\n\s*", " ", (s or "").strip())
    return s.replace("|", "\\|")


def upper_id(name: str) -> str:
    return re.sub(r"[^A-Za-z0-9]+", "_", name).strip("_").upper()


def erd_type(t: str) -> str:
    t = (t or "string").lower()
    if t.startswith("decimal") or t in ("float", "double"):
        return "float"
    if t.startswith("array") or t.startswith("struct") or t == "boolean":
        return "string"
    if t in ("int", "bigint", "date", "timestamp", "string"):
        return t
    return "string"


def module_vi(root: Path, module: str) -> str:
    p = _HERE.parent / "reference" / "module_names_vi.md"
    if p.is_file():
        for line in p.read_text(encoding="utf-8").splitlines():
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            if len(cells) >= 3 and module.upper() in [x.strip().upper() for x in cells[0].split("/")]:
                return cells[2] or cells[1]
    return module


@lru_cache(maxsize=None)
def load_atomic(root: Path):
    import yaml
    p = root / "DataModel/working/Atomic/aggregate/atomic_attributes.yaml"
    by_col, by_tbl = defaultdict(set), defaultdict(set)
    if not p.is_file():
        return by_col, by_tbl
    for a in yaml.safe_load(p.read_text(encoding="utf-8")).get("attributes", []):
        t, c, s = a.get("atomic_table"), a.get("atomic_column"), a.get("source_system")
        if t and s:
            by_tbl[t].add(s)
            if c:
                by_col[(t, c)].add(s)
    return by_col, by_tbl


@lru_cache(maxsize=None)
def load_lld(root: Path):
    """{datamart_entity: [(module_dir, row), ...]} theo thứ tự file/dòng."""
    out = defaultdict(list)
    for p in sorted((root / "Datamart/lld").glob("*/DTM_*.csv")):
        for r in read_csv(p):
            out[r.get("datamart_entity", "").strip()].append((p.parent.name, r))
    return out


def key_kind(key: str) -> str:
    k = (key or "").strip().upper()
    if k.startswith("PK"):
        return "PK"
    if k.startswith("FK"):
        return "FK"
    return ""


def fallback_desc(attr: str, key: str) -> str:
    kk = key_kind(key)
    if kk == "PK":
        return "Khóa đại diện"
    if kk == "FK":
        m = re.search(r"(?:→|->|đến|to)\s*([A-Z][\w ]+?)(?:\s*[.(—]|$)", key or "")
        return f"Khóa ngoại tới {m.group(1).strip()}" if m else "Khóa ngoại"
    return attr


class Report:
    def __init__(self):
        self.blocking, self.warn = [], []

    def b(self, msg):
        self.blocking.append(msg)

    def w(self, msg):
        self.warn.append(msg)


def build_columns(rows, mart_tables, atm_by_col, atm_by_tbl, rep: Report, table: str):
    """Gộp dòng LLD (có thể multi-source) thành danh sách cột theo thứ tự xuất hiện."""
    cols: "OrderedDict[str, list]" = OrderedDict()
    for _, r in rows:
        cols.setdefault(r["datamart_column"].strip(), []).append(r)
    out = []
    for name, rs in cols.items():
        r0 = rs[0]
        dtype = (r0.get("data_type") or "").strip() or DOMAIN_TYPE.get((r0.get("data_domain") or "").strip().lower(), "string")
        kk = key_kind(r0.get("key", ""))
        nullable = "" if kk else ("X" if (r0.get("nullable") or "").strip().lower() == "true" else "")
        raw_desc = next((x["description"] for x in rs if (x.get("description") or "").strip()), "")
        desc = clean(raw_desc)
        if not desc:
            desc = fallback_desc(r0.get("datamart_attribute", name), r0.get("key", ""))
            if raw_desc:
                rep.w(f"MÔ TẢ RỖNG SAU CLEAN  {table}.{name}: '{raw_desc[:70]}…' → dự phòng '{desc}'")
        leaks = find_leaks(desc)
        if leaks:
            rep.b(f"RÒ RỈ MÔ TẢ  {table}.{name}: {leaks} — '{desc[:80]}'")
        tech = name in TECH_COLS or name in LEGACY_AUDIT
        systems, schemas, fields, etls = [], [], [], []
        if not tech:
            for x in rs:
                gen = (x.get("source_entity") or "").strip() in ("", "Generated") or \
                      (x.get("etl_logic_type") or "").strip() == "Generated"
                if gen:
                    continue
                tbls = [t.strip() for t in (x.get("atomic_table") or "").split("/") if t.strip() and t.strip() != "—"]
                acols = [c.strip() for c in (x.get("atomic_column") or "").split("/") if c.strip()]
                sys_here = set()
                for i, t in enumerate(tbls):
                    if t in mart_tables and t not in atm_by_tbl:
                        sch, sy = f"DTM.{t}", {"Datamart"}
                    else:
                        sch = f"ATM.{t}"
                        c = acols[i] if len(acols) == len(tbls) else None
                        sy = (atm_by_col.get((t, c)) if c else None) or atm_by_tbl.get(t, set())
                        if not sy:
                            rep.w(f"LINEAGE  {table}.{name}: bảng '{t}' không có trong atomic_attributes.yaml "
                                  f"lẫn Datamart — Hệ thống nguồn để trống")
                    if sch not in schemas:
                        schemas.append(sch)
                    sys_here |= sy
                for s in sorted(sys_here):
                    if s not in systems:
                        systems.append(s)
                f = (x.get("atomic_column") or "").strip()
                if f and f not in fields:
                    fields.append(f)
                logic = (x.get("etl_logic") or "").strip()
                if logic:
                    tag = f"[{'/'.join(sorted(sys_here))}] " if len(rs) > 1 and sys_here else ""
                    if tag + logic not in etls:
                        etls.append(tag + logic)
        etl = "; ".join(etls) if etls else EXEC
        out.append({
            "logical": r0.get("datamart_attribute", name).strip(), "physical": name, "type": dtype,
            "nullable": nullable, "unique": "X" if kk == "PK" else "", "pf": "P" if kk == "PK" else "F" if kk == "FK" else "",
            "desc": desc, "system": "; ".join(systems), "schema": "; ".join(schemas),
            "field": "; ".join(fields), "etl": etl, "kk": kk,
        })
    return out


def tech_rows(existing: set, table: str):
    out = []
    for c in TECH_COLS:
        if c in existing or (c == "ds_snpst_dt" and "snpst" not in table):
            continue
        lg, ty, de = TECH_DEF[c]
        out.append({"logical": lg, "physical": c, "type": ty, "nullable": "", "unique": "", "pf": "", "desc": de,
                    "system": "", "schema": "", "field": "", "etl": EXEC, "kk": ""})
    return out


def parse_fks(fks: str):
    """'Public Company Dimension.Public Company Dimension Id | Calendar Date Dimension.…' → [entity cha]."""
    out = []
    for part in (fks or "").split("|"):
        part = part.strip()
        if not part:
            continue
        ent = part.rsplit(".", 1)[0].strip() if "." in part else part
        if ent and ent not in out:
            out.append(ent)
    return out


def render(root: Path, module: str, with_tech: bool, rep: Report) -> str:
    ents_p = root / f"Datamart/hld/DTM_{module}_Entities.csv"
    if not ents_p.is_file():
        raise SystemExit(f"❌ Không thấy {ents_p.relative_to(root)} — cần HLD Phase 2 (Entities) đã duyệt.")
    ents = read_csv(ents_p)
    lld = load_lld(root)
    mart_tables = {r["datamart_table"].strip() for rows in lld.values() for _, r in rows}
    atm_by_col, atm_by_tbl = load_atomic(root)

    model = []
    for e in ents:
        name = e["datamart_entity"].strip()
        rows = lld.get(name, [])
        own = [x for x in rows if x[0].upper() == module.upper()]
        rows = own or rows
        if not rows:
            rep.b(f"THIẾU LLD  thực thể '{name}' có trong Entities.csv nhưng không có file LLD per-table nào")
            continue
        table = rows[0][1]["datamart_table"].strip()
        rows = [x for x in rows if x[1]["datamart_table"].strip() == table]
        cols = build_columns(rows, mart_tables, atm_by_col, atm_by_tbl, rep, table)
        if with_tech:
            cols += tech_rows({c["physical"] for c in cols}, table)
        ttype = (e.get("table_type") or "").strip().lower()
        if ttype not in TYPE_ORDER:
            rep.w(f"LOẠI BẢNG  '{name}': table_type='{ttype}' không thuộc dim/fact/operational — xếp vào operational")
            ttype = "operational"
        model.append({"entity": name, "table": table, "type": ttype, "desc": clean(e.get("description", "")),
                      "parents": parse_fks(e.get("FKs", "")), "cols": cols})

    names = {m["entity"] for m in model}
    rels = [(p, m["entity"]) for m in model for p in m["parents"] if p in names and p != m["entity"]]
    for m in model:
        for p in m["parents"]:
            if p not in names:
                rep.w(f"QUAN HỆ  '{m['entity']}' tham chiếu '{p}' không có trong Entities.csv của module — bỏ khỏi ERD")
    in_rel = {x for r in rels for x in r}
    ordered = sorted(model, key=lambda m: TYPE_ORDER[m["type"]])

    L = [f"# 3. KHO DỮ LIỆU (OLAP) — {module_vi(root, module)}", "",
         f"<!-- Sinh tự động bởi render_datamart_md.py lúc {datetime.now():%Y-%m-%d %H:%M}. "
         f"Không sửa tay bảng/ERD — sửa LLD/Entities rồi sinh lại. -->", "",
         "## 3.1 Mô hình dữ liệu mức High Level / Conceptual", "", "### 3.1.1 Sơ đồ ERD", "",
         "```mermaid", "erDiagram"]
    L += [f"    {upper_id(p)} ||--o{{ {upper_id(c)} : \" \"" for p, c in rels]
    L += [f"    {upper_id(m['entity'])}" for m in model if m["entity"] not in in_rel]
    L += ["```", "", "### 3.1.2 Danh sách thực thể", "", "| STT | Thực thể | Tên bảng | Mô tả |", "|---|---|---|---|"]
    L += [f"| {i} | {cell(m['entity'])} | {m['table']} | {cell(m['desc'])} |" for i, m in enumerate(model, 1)]

    def erd(level: str):
        out = ["```mermaid", "erDiagram"]
        for m in ordered:
            alias = m["entity"] if level == "logic" else m["table"]
            out.append(f"    {upper_id(m['entity'])}[\"{alias}\"] {{")
            for c in m["cols"]:
                nm = re.sub(r"[^A-Za-z0-9_]+", "_", c["logical"]).strip("_") if level == "logic" else c["physical"]
                ann = f" {c['kk']}" if c["kk"] else ""
                out.append(f"        {erd_type(c['type'])} {nm}{ann}")
            out.append("    }")
        out += [f"    {upper_id(p)} ||--o{{ {upper_id(c)} : \" \"" for p, c in rels]
        return out + ["```"]

    L += ["", "## 3.2 Mô hình dữ liệu mức Logic", "", "### 3.2.1 Sơ đồ ERD", ""] + erd("logic")
    L += ["", "### 3.2.2 Danh sách các bảng và thuộc tính", ""]
    for i, m in enumerate(model, 1):
        L += [f"#### 3.2.2.{i} Bảng {m['entity']}", "",
              "| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |",
              "|---|---|---|---|---|---|---|---|"]
        L += [f"| {j} | {cell(c['logical'])} | {c['type']} | {c['nullable']} | {c['unique']} | {c['pf']} |  | {cell(c['desc'])} |"
              for j, c in enumerate(m["cols"], 1)]
        L.append("")

    L += ["## 3.3 Mô hình dữ liệu mức vật lý", "", "### 3.3.1 Sơ đồ ERD", ""] + erd("physical") + [""]
    for t in ("dim", "fact", "operational"):
        group = [m for m in ordered if m["type"] == t]
        if not group:
            continue
        sec, title = SECTION[t]
        L += [f"### {sec} {title}", ""]
        for i, m in enumerate(group, 1):
            L += [f"#### {sec}.{i} Bảng {m['entity']} ({m['table']})", "",
                  f"*Mô tả bảng:* {cell(m['desc'])}", "*Đường dẫn trên kho dữ liệu:*", "*Các trường Partition:*",
                  "*Thời gian lưu trữ:*", "*Định dạng lưu trữ:*", "",
                  "| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Giá trị mặc định | Mô tả "
                  "| Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |",
                  "|---|---|---|---|---|---|---|---|---|---|---|---|"]
            L += [f"| {j} | {c['physical']} | {c['type']} | {c['nullable']} | {c['unique']} | {c['pf']} |  | "
                  f"{cell(c['desc'])} | {cell(c['system'])} | {cell(c['schema'])} | {cell(c['field'])} | {cell(c['etl'])} |"
                  for j, c in enumerate(m["cols"], 1)]
            L.append("")
    return "\n".join(L).rstrip() + "\n"


def modules(root: Path):
    return sorted(p.name.split("_")[1] for p in (root / "Datamart/hld").glob("DTM_*_Entities.csv"))


def main() -> None:
    ap = argparse.ArgumentParser(description="Sinh TKCSLD Markdown từ Entities + LLD + Atomic (0 token LLM)")
    ap.add_argument("-m", "--module", required=True, help="Mã module (QLQ, TT, …) hoặc ALL")
    ap.add_argument("--with-tech-cols", action="store_true", help="Nối các cột kỹ thuật SCD4A còn thiếu")
    ap.add_argument("--overwrite", action="store_true", help="Ghi đè DTM_{M}_TKCSLD.md (có sao lưu .bak-<ts>)")
    ap.add_argument("--report-only", action="store_true", help="Chỉ in báo cáo chất lượng, không ghi file")
    ap.add_argument("--verbose", action="store_true", help="In đủ mọi cảnh báo (mặc định gộp theo loại)")
    ap.add_argument("--root", default=None)
    args = ap.parse_args()

    root = Path(args.root).resolve() if args.root else find_root(Path.cwd().resolve())
    mods = modules(root) if args.module.upper() == "ALL" else [args.module.upper()]
    rc = 0
    for mod in mods:
        rep = Report()
        text = render(root, mod, args.with_tech_cols, rep)
        print(f"=== {mod}: {text.count(chr(10))} dòng MD, {len(rep.blocking)} lỗi chặn, {len(rep.warn)} cảnh báo")
        for msg in rep.blocking:
            print(f"  ❌ {msg}")
        if args.verbose:
            for msg in rep.warn:
                print(f"  ⚠ {msg}")
        else:
            kinds = defaultdict(list)
            for msg in rep.warn:
                kinds[msg.split("  ")[0]].append(msg)
            for k, v in kinds.items():
                print(f"  ⚠ {k}: {len(v)} (VD: {v[0].split('  ', 1)[1][:110]})")
        if rep.blocking:
            rc = 1
        if args.report_only:
            continue
        out_dir = root / "docs/output/datamart" / mod
        out_dir.mkdir(parents=True, exist_ok=True)
        target = out_dir / f"DTM_{mod}_TKCSLD.md"
        if target.exists() and not args.overwrite:
            target = out_dir / f"DTM_{mod}_TKCSLD.rendered.md"
        elif target.exists():
            bak = target.with_name(target.name + f".bak-{datetime.now():%Y%m%d-%H%M%S}")
            shutil.copy2(target, bak)
            print(f"  ↺ sao lưu bản cũ: {bak.relative_to(root).as_posix()}")
        target.write_text(text, encoding="utf-8", newline="\n")
        print(f"  ✅ ghi {target.relative_to(root).as_posix()}")
    sys.exit(rc)


if __name__ == "__main__":
    main()
