# -*- coding: utf-8 -*-
"""
build_flat_tables.py — RFC Đ4: sinh khối DDL/DML flat table ClickHouse từ registry + Entities.csv

Flat table là hàm thuần của:
  (cột trong master registry) × (FK trong Entities.csv) × (quy tắc ánh xạ kiểu sang ClickHouse)
Viết tay sinh ra Gate 4 chỉ để canh lỗi chép tay. Script này biến Gate 4 thành regression test
của generator.

Mặc định chỉ **bổ sung** khối cho bảng chưa có trong file SQL (an toàn với SQL đã curate).
  --check : chỉ báo cáo thiếu hụt, không ghi (exit 1 nếu thiếu)

Usage:
    python scripts/build_flat_tables.py --module QLKD --check
    python scripts/build_flat_tables.py --module QLKD
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

_script_dir = Path(__file__).resolve().parent
if str(_script_dir) not in sys.path:
    sys.path.insert(0, str(_script_dir))

for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from datamart_common import find_project_root, resolve_entities_csv  # noqa: E402
from datamart_common.csv_io import read_design_csv  # noqa: E402
from datamart_common.module_resolver import normalize_module_name  # noqa: E402

MASTER_REL = "Datamart/lld/datamart_attributes.csv"


# --------------------------------------------------------------------------
def ch_type(dt: str, nullable: bool) -> str:
    dt = (dt or "").strip().lower()
    if dt.startswith("decimal("):
        base = "Decimal(%s)" % dt[len("decimal("):-1]
    elif dt == "decimal":
        base = "Decimal(23,2)"
    elif dt == "int":
        base = "Int64"
    elif dt == "date":
        base = "Date"
    elif dt in ("timestamp", "datetime"):
        base = "DateTime"
    elif dt == "boolean":
        base = "UInt8"
    else:
        base = "String"
    return "Nullable(%s)" % base if nullable else base


def load_registry(root: Path):
    """Trả (cols_by_table, logical2physical, table_type_hint)."""
    t = read_design_csv(root / MASTER_REL, strict=True)
    ix = t.ix
    cols, l2p = {}, {}
    for r in t.rows:
        tbl = r[ix["datamart_table"]].strip()
        ent = r[ix["datamart_entity"]].strip()
        l2p.setdefault(ent, tbl)
        col = r[ix["datamart_column"]].strip()
        bucket = cols.setdefault(tbl, [])
        if col in [c[0] for c in bucket]:
            continue
        bucket.append((col, r[ix["data_type"]], r[ix["nullable"]].strip().lower() == "true",
                       r[ix["description"]].replace("'", "").replace("\n", " ").strip()[:110]))
    return cols, l2p


def alias_for(dim_table: str) -> str:
    if dim_table == "cdr_dt_dim":
        return "cal"
    base = dim_table[:-4] if dim_table.endswith("_dim") else dim_table
    parts = [p for p in base.split("_") if p]
    return ("".join(p[0] for p in parts) + "_dim") if len(parts) > 2 else base[:12] + "_dim"


def parse_entities(root: Path, module: str, l2p: dict):
    """Trả {physical_table: (table_type, [(alias, dim_phys, fk_col, dim_logical)])}."""
    p = resolve_entities_csv(root, module)
    out = {}
    if not p or not Path(p).is_file():
        return out
    t = read_design_csv(Path(p), strict=False)
    ix = t.ix
    for r in t.rows:
        ent = r[ix["datamart_entity"]].strip()
        phys = l2p.get(ent)
        if not phys:
            continue
        dims = []
        fks = r[ix["FKs"]].strip() if "FKs" in ix else ""
        for part in [x.strip() for x in fks.split("|") if x.strip()]:
            if "." not in part:
                continue
            dim_logical, fk_attr = part.split(".", 1)
            dim_phys = l2p.get(dim_logical.strip())
            if not dim_phys:
                continue
            fk_col = re.sub(r"[^a-z0-9]+", "_", fk_attr.strip().lower()).strip("_")
            dims.append((alias_for(dim_phys), dim_phys, fk_col, dim_logical.strip()))
        out[phys] = (r[ix["table_type"]].strip(), dims)
    return out


def gen_blocks(no: int, module: str, tbl: str, ttype: str, dims, cols, desc: str):
    flat = f"{module}_{tbl}_flat"
    kind = {"fact": "FACT", "dim": "DIMENSION"}.get(ttype, "OPERATIONAL")
    has_cal = any(d[0] == "cal" for d in dims)

    ddl = ["-- " + "=" * 58,
           f"-- {no}. {kind}: {flat}",
           f"--    {desc}",
           f"--    Joins: {', '.join(d[3] for d in dims) if dims else 'không JOIN dimension'}",
           "-- " + "=" * 58,
           f"CREATE TABLE IF NOT EXISTS datamart.{flat} ON CLUSTER 'my_cluster'", "(",
           f"    -- From: {tbl.upper()}"]
    sel = []
    order_key = None
    for c, dt, nu, de in cols.get(tbl, []):
        ddl.append(f"    {c:<44} {ch_type(dt, nu):<23} COMMENT '{de}',")
        sel.append(f"    f.{c},")
        if order_key is None and c.endswith("_dim_id"):
            order_key = c
    for alias, dphys, fk, dlog in dims:
        ddl.append("")
        ddl.append(f"    -- From: {dlog.upper()}")
        sel.append("")
        sel.append(f"    -- From: {dlog.upper()}")
        for c, dt, nu, de in cols.get(dphys, []):
            if c.endswith("_dim_id"):
                continue
            out = f"{alias}_{c}" if c == "src_stm_code" else c
            ddl.append(f"    {out:<44} {ch_type(dt, True):<23} COMMENT '{de} — từ {dlog}',")
            sel.append(f"    {alias}.{c} AS {out},")
    ddl[-1] = ddl[-1].rstrip(",")
    while sel and (not sel[-1].strip() or sel[-1].strip().startswith("-- From")):
        sel.pop()
    sel[-1] = sel[-1].rstrip(",")
    ddl.append(")")
    ddl.append("ENGINE = ReplicatedReplacingMergeTree()")
    if has_cal:
        ddl.append("PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))")
        ddl.append(f"ORDER BY (assumeNotNull(cdr_dt), {order_key or 'tuple()'})")
    else:
        ddl.append(f"ORDER BY ({order_key or (cols.get(tbl) or [('tuple()',)])[0][0]})")
    ddl.append(f"COMMENT 'Flat table — {desc}'")
    ddl.append(";")

    dml = ["-- " + "=" * 58, f"-- {no}. {kind}: {flat}", "-- " + "=" * 58]
    if has_cal:
        dml.append(f"DELETE FROM datamart.{flat} ON CLUSTER 'my_cluster'")
        dml.append("WHERE cdr_dt = :etl_date;")
    else:
        dml.append(f"TRUNCATE TABLE IF EXISTS datamart.{flat} ON CLUSTER 'my_cluster';")
    dml += [f"INSERT INTO datamart.{flat}", "SELECT", f"    -- From: {tbl.upper()}"]
    dml += sel
    dml.append("")
    dml.append(f"FROM datamart.{tbl} f")
    for alias, dphys, fk, dlog in dims:
        dml.append(f"{'JOIN' if alias == 'cal' else 'LEFT JOIN'} datamart.{dphys} {alias}")
        dml.append(f"    ON {alias}.{dphys}_id = f.{fk}")
    if has_cal:
        dml.append("WHERE cal.cdr_dt = :etl_date")
    dml.append(";")
    return "\n".join(ddl), "\n".join(dml)


def main() -> None:
    ap = argparse.ArgumentParser(description="RFC Đ4 — sinh flat table SQL còn thiếu")
    ap.add_argument("-m", "--module", required=True)
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--root", default=None)
    args = ap.parse_args()

    root = find_project_root(args.root) if args.root else find_project_root()
    mod = normalize_module_name(args.module)
    cols, l2p = load_registry(root)
    ents = parse_entities(root, mod, l2p)

    from datamart_common.module_resolver import strip_accents
    ft_root = root / "Datamart" / "flat-table"
    cand = [mod, strip_accents(mod)]
    slug = next((c for c in cand if (ft_root / c).is_dir()), mod)
    ddl_p = ft_root / slug / f"01_create_{strip_accents(slug).lower()}_flat_tables.sql"
    dml_p = ft_root / slug / f"02_populate_{strip_accents(slug).lower()}_flat_tables.sql"
    if not ddl_p.is_file():
        print(f"❌ Không thấy {ddl_p}")
        sys.exit(1)
    ddl_txt = ddl_p.read_text(encoding="utf-8").rstrip("\n")
    dml_txt = dml_p.read_text(encoding="utf-8").rstrip("\n")

    lld_cand = [mod, strip_accents(mod)]
    lld_dir = next((root / "Datamart" / "lld" / c for c in lld_cand
                     if (root / "Datamart" / "lld" / c).is_dir()), root / "Datamart" / "lld" / mod)
    mine = []
    if lld_dir.is_dir():
        for f in sorted(lld_dir.glob("*.csv")):
            t = read_design_csv(f, strict=False)
            if t.header:
                for r in t.rows:
                    tb = r[t.ix["datamart_table"]].strip()
                    if tb not in mine:
                        mine.append(tb)
    # Dimension không có flat table riêng — được denormalize vào flat của Fact
    mine = [t for t in mine
            if (ents.get(t, ("", []))[0] or "").lower() != "dim" and not t.endswith("_dim")]

    missing = [t for t in mine if f"{strip_accents(mod).lower()}_{t}_flat" not in ddl_txt]
    drift = []
    for t in mine:
        flat = f"{strip_accents(mod).lower()}_{t}_flat"
        if flat not in ddl_txt:
            continue
        blk = ddl_txt.split(flat, 1)[1].split("\n;", 1)[0]
        drift += [(t, c) for c, *_ in cols.get(t, []) if not re.search(rf"^\s+{re.escape(c)}\s", blk, re.M)]

    print(f"=== Flat table coverage: {mod} ===")
    print(f"  Bảng LLD của module : {len(mine)}")
    print(f"  Thiếu khối SQL      : {len(missing)} {missing if missing else ''}")
    print(f"  Cột thiếu trong DDL : {len(drift)}")
    for t, c in drift[:20]:
        print(f"      - {t}.{c}")

    if args.check:
        sys.exit(1 if (missing or drift) else 0)
    if not missing:
        print("\n✅ Không có bảng nào thiếu khối SQL."
              + ("\n⚠️  Còn cột drift — bổ sung thủ công vào đúng khối." if drift else ""))
        sys.exit(1 if drift else 0)

    no = len(re.findall(r"^CREATE TABLE IF NOT EXISTS", ddl_txt, re.M))
    for t in missing:
        no += 1
        ttype, dims = ents.get(t, ("operational", []))
        desc = f"{t} — sinh tự động từ master registry + Entities.csv"
        d, m = gen_blocks(no, strip_accents(mod).lower(), t, ttype, dims, cols, desc)
        ddl_txt += "\n\n\n" + d
        dml_txt += "\n\n\n" + m
        print(f"  + {strip_accents(mod).lower()}_{t}_flat ({len(cols.get(t, []))} cột, {len(dims)} dim)")
    ddl_p.write_text(ddl_txt + "\n", encoding="utf-8", newline="\n")
    dml_p.write_text(dml_txt + "\n", encoding="utf-8", newline="\n")
    print("✅ Đã ghi DDL + DML.")


if __name__ == "__main__":
    main()
