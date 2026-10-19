# -*- coding: utf-8 -*-
"""
build_flat_tables.py — RFC Đ4: sinh khối DDL/DML flat table ClickHouse từ registry + Entities.csv

Flat table là hàm thuần của:
  (cột trong master registry) × (FK trong Entities.csv) × (quy tắc ánh xạ kiểu sang ClickHouse)
Viết tay sinh ra Gate 4 chỉ để canh lỗi chép tay. Script này biến Gate 4 thành regression test
của generator.

Mặc định chỉ **bổ sung** khối cho bảng chưa có trong file SQL (an toàn với SQL đã curate).
  --check          : chỉ báo cáo thiếu hụt (bảng thiếu khối + cột LLD thiếu trong DDL), không ghi
                     (exit 1 nếu thiếu). Ngữ nghĩa cột-thiếu GIỐNG HỆT Gate 4 (cột nghiệp vụ trong
                     LLD per-table, trừ cột kỹ thuật) — hai bên không được lệch nhau.
  --sync-columns   : với bảng flat ĐÃ CÓ, chèn cột LLD còn thiếu vào CẢ DDL lẫn DML (đúng thứ tự LLD,
                     vì SELECT của DML khớp theo vị trí). Mặc định chỉ in kế hoạch (exit 1 nếu còn
                     việc); thêm --apply để ghi (sao lưu vào Datamart/context/.backup/).

Lý do có --sync-columns (QLQ 2026-10-14): 29 cột `opr_*` đã có trong LLD + Detail Mapping + 29 KPI READY
nhưng không bao giờ lên flat DDL/DML, vì bước "bổ sung khối bảng mới" không thêm cột vào bảng đã tồn
tại, còn `apply_kpi_patch.py` chỉ patch HLD/DM/Attributes. Gate 4 vẫn báo FAIL qua nhiều phiên nhưng
bị xếp vào "tồn đọng" vì không có công cụ sửa.

Usage:
    python scripts/build_flat_tables.py --module QLKD --check
    python scripts/build_flat_tables.py --module QLKD
    python scripts/build_flat_tables.py --module QLQ --sync-columns            # dry-run
    python scripts/build_flat_tables.py --module QLQ --sync-columns --apply
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
from datamart_flat_table_checker import TECH_AUDIT_COLUMNS  # noqa: E402  (cùng quy tắc loại trừ với Gate 4)

MASTER_REL = "Datamart/lld/datamart_attributes.csv"


# --------------------------------------------------------------------------
def ch_type(dt: str, nullable: bool) -> str:
    dt = (dt or "").strip().lower()
    if dt.startswith("decimal("):
        base = "Decimal(%s)" % dt[len("decimal("):-1]
    elif dt == "decimal":
        base = "Decimal(23,2)"
    elif dt in ("int", "bigint"):
        base = "Int64"
    elif dt == "float":
        base = "Float64"
    elif dt == "date":
        base = "Date"
    elif dt in ("timestamp", "datetime"):
        base = "DateTime"
    elif dt == "boolean":
        base = "UInt8"
    elif dt == "array<string>":
        return "Array(String)"  # ClickHouse không cho Nullable(Array)
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


# --------------------------------------------------------------------------
# Đồng bộ cột LLD -> flat đã tồn tại (--sync-columns)
# --------------------------------------------------------------------------
_DDL_COL = re.compile(r"^\s+([A-Za-z_][A-Za-z0-9_]*)\s+\S")
# projection đơn giản: [alias.]col [AS name] [,] [-- ghi chú]; biểu thức phức tạp không khớp -> bỏ qua
_DML_PROJ = re.compile(r"^(\s*)(?:(\w+)\.)?(\w+)(?:\s+AS\s+(\w+))?\s*,?\s*(?:--.*)?$", re.I)
_SELECT_KW = re.compile(r"^\s*SELECT\s*(?:--.*)?$", re.I)


def load_lld_business_columns(lld_dir: Path) -> dict:
    """{datamart_table: [(col, data_type, nullable, description)]} theo LLD per-table, bỏ cột kỹ thuật.

    Cùng nguồn + cùng quy tắc loại trừ (TECH_AUDIT_COLUMNS) với Gate 4 `_check_column_coverage`.
    """
    out: dict = {}
    if not lld_dir.is_dir():
        return out
    for f in sorted(lld_dir.glob("*.csv")):
        t = read_design_csv(f, strict=False)
        if not t.header or "datamart_table" not in t.ix:
            continue
        for r in t.rows:
            tb = r[t.ix["datamart_table"]].strip()
            col = r[t.ix["datamart_column"]].strip()
            if not tb or not col or col.lower() in TECH_AUDIT_COLUMNS:
                continue
            bucket = out.setdefault(tb, [])
            if col not in [c[0] for c in bucket]:
                bucket.append((col, r[t.ix["data_type"]], r[t.ix["nullable"]].strip().lower() == "true",
                               " ".join(r[t.ix["description"]].replace("'", "").split())))
    return out


def _flat_block(lines: list, kind: str, flat: str):
    """(start, end) của khối CREATE (end = dòng ')' đầu cột 0) hoặc INSERT (end = dòng 'FROM' đầu cột 0).

    Neo theo câu lệnh CREATE/INSERT thật, KHÔNG theo lần xuất hiện đầu tiên của tên bảng trong file
    (tên bảng còn xuất hiện trong comment tiêu đề — cách cũ đọc nhầm khối và báo 94 cột thiếu giả cho QLQ).
    """
    if kind == "ddl":
        s_pat = re.compile(rf"^\s*CREATE TABLE IF NOT EXISTS datamart\.{re.escape(flat)}\b")
        e_pat = re.compile(r"^\)")
    else:
        s_pat = re.compile(rf"^\s*INSERT INTO datamart\.{re.escape(flat)}\b")
        e_pat = re.compile(r"^FROM\b", re.I)
    s = next((i for i, ln in enumerate(lines) if s_pat.search(ln)), None)
    if s is None:
        return None
    e = next((i for i in range(s + 1, len(lines)) if e_pat.search(lines[i])), None)
    return (s, e) if e is not None else None


def ddl_columns(lines: list, flat: str):
    """Tập tên cột của khối CREATE flat; None nếu không có khối."""
    b = _flat_block(lines, "ddl", flat)
    if not b:
        return None
    return {m.group(1) for ln in lines[b[0] + 1:b[1]]
            if not ln.strip().startswith("--") and (m := _DDL_COL.match(ln))}


def flat_gap(root: Path, module: str, pairs: list) -> list:
    """[(flat_table, column)] trong `pairs` [(datamart_table, datamart_column)] mà flat DDL của module chưa có.

    Dùng bởi apply_kpi_patch.py để cảnh báo NGAY khi thêm cột. Bảng không có flat (Dimension) hoặc cột
    kỹ thuật thì bỏ qua.
    """
    from datamart_common.module_resolver import strip_accents
    mod = normalize_module_name(module)
    ft_root = root / "Datamart" / "flat-table"
    slug = next((c for c in (mod, strip_accents(mod)) if (ft_root / c).is_dir()), None)
    if not slug:
        return []
    ddl_p = ft_root / slug / f"01_create_{strip_accents(slug).lower()}_flat_tables.sql"
    if not ddl_p.is_file():
        return []
    lines = ddl_p.read_text(encoding="utf-8").split("\n")
    prefix = strip_accents(mod).lower()
    gap = []
    for t, c in pairs:
        if not t or not c or c.lower() in TECH_AUDIT_COLUMNS:
            continue
        have = ddl_columns(lines, f"{prefix}_{t}_flat")
        if have is not None and c not in have:
            gap.append((f"{prefix}_{t}_flat", c))
    return gap


def _split_keep_nl(text: str):
    nl = "\r\n" if "\r\n" in text else "\n"
    return text.split(nl), nl


def sync_columns(ddl_txt: str, dml_txt: str, flat_prefix: str, lld_cols: dict, tables: list):
    """Chèn cột LLD thiếu vào flat đã có (DDL + DML cùng vị trí). Trả (ddl, dml, added, skipped)."""
    dl, nl_d = _split_keep_nl(ddl_txt)
    ml, nl_m = _split_keep_nl(dml_txt)
    added, skipped = [], []
    for t in tables:
        flat = f"{flat_prefix}_{t}_flat"
        have = ddl_columns(dl, flat)
        if have is None or _flat_block(ml, "dml", flat) is None:
            continue
        cols = lld_cols.get(t, [])
        order = [c[0] for c in cols]
        meta = {c[0]: c for c in cols}
        for c in [x for x in order if x not in have]:
            i = order.index(c)
            prev = next((p for p in reversed(order[:i]) if p in have), None)
            s, e = _flat_block(dl, "ddl", flat)
            ms, me = _flat_block(ml, "dml", flat)

            # --- vị trí DDL
            ddl_lines = [(k, _DDL_COL.match(dl[k])) for k in range(s + 1, e) if not dl[k].strip().startswith("--")]
            ddl_lines = [(k, m.group(1)) for k, m in ddl_lines if m]
            d_idx = next((k for k, n in ddl_lines if n == prev), None) if prev else (ddl_lines[0][0] if ddl_lines else None)
            # --- vị trí DML
            projs = []
            sel_k = None  # dòng từ khóa SELECT — KHÔNG phải projection (regex _DML_PROJ khớp nhầm 'SELECT' như 1 cột)
            for k in range(ms + 1, me):
                if sel_k is None:
                    if _SELECT_KW.match(ml[k]):
                        sel_k = k
                    continue
                m = _DML_PROJ.match(ml[k])
                if m and not ml[k].strip().startswith("--"):
                    projs.append((k, m.group(2), m.group(4) or m.group(3)))
            if prev:
                m_pos = next(((k, a) for k, a, n in projs if n == prev), None)
            else:
                # đầu bảng: chèn vào dòng đầu tiên sau SELECT (bỏ qua dòng trống/comment '-- From:'), khớp vị trí DDL.
                # Dòng đầu có thể là biểu thức phức tạp (không khớp regex) -> alias lấy từ projection đơn giản đầu tiên.
                first = next((k for k in range((sel_k or ms) + 1, me)
                              if ml[k].strip() and not ml[k].strip().startswith("--")), None)
                m_pos = (first, next((a for _, a, _ in projs if a), None)) if first is not None and sel_k is not None else None
            if d_idx is None or m_pos is None:
                skipped.append((flat, c, f"không định vị được cột liền trước '{prev}' trong "
                                         f"{'DDL' if d_idx is None else 'DML'} (projection phức tạp?) — chèn tay"))
                continue
            _, dt, nu, de = meta[c]
            ty = ch_type(dt, nu)
            alias = m_pos[1]
            new_d = f"    {c:<44} {ty:<23} COMMENT '{de}'"
            new_m = f"    {alias + '.' if alias else ''}{c}"
            if prev:
                # DDL: chèn SAU cột trước; nếu cột trước là dòng cuối (không dấu phẩy) thì chuyển dấu phẩy xuống
                tail = not dl[d_idx].rstrip().endswith(",")
                if tail:
                    dl[d_idx] = dl[d_idx].rstrip() + ","
                dl.insert(d_idx + 1, new_d + ("" if tail else ","))
                tail_m = not re.sub(r"\s*--.*$", "", ml[m_pos[0]]).rstrip().endswith(",")
                if tail_m:
                    ml[m_pos[0]] = re.sub(r"(\s*--.*)?$", lambda mm: "," + (mm.group(1) or ""), ml[m_pos[0]].rstrip(), count=1)
                ml.insert(m_pos[0] + 1, new_m + ("" if tail_m else ","))
            else:
                dl.insert(d_idx, new_d + ",")
                ml.insert(m_pos[0], new_m + ",")
            have.add(c)
            added.append((flat, c, prev))
    return nl_d.join(dl), nl_m.join(ml), added, skipped


def main() -> None:
    ap = argparse.ArgumentParser(description="RFC Đ4 — sinh flat table SQL còn thiếu")
    ap.add_argument("-m", "--module", required=True)
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--sync-columns", action="store_true",
                    help="chèn cột LLD còn thiếu vào bảng flat ĐÃ CÓ (DDL + DML); mặc định chỉ in kế hoạch")
    ap.add_argument("--apply", action="store_true", help="chỉ với --sync-columns: ghi thật (có sao lưu)")
    ap.add_argument("--root", default=None)
    args = ap.parse_args()
    if args.apply and not args.sync_columns:
        ap.error("--apply chỉ dùng cùng --sync-columns")

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

    prefix = strip_accents(mod).lower()
    ddl_lines = ddl_txt.split("\n")
    # khối CREATE thật (không dùng "tên bảng xuất hiện trong file" — comment tiêu đề cũng chứa tên bảng)
    missing = [t for t in mine if _flat_block(ddl_lines, "ddl", f"{prefix}_{t}_flat") is None]
    lld_cols = load_lld_business_columns(lld_dir)
    drift = []
    for t in mine:
        have = ddl_columns(ddl_lines, f"{prefix}_{t}_flat")
        if have is None:
            continue
        drift += [(t, c) for c, *_ in lld_cols.get(t, []) if c not in have]

    print(f"=== Flat table coverage: {mod} ===")
    print(f"  Bảng LLD của module : {len(mine)}")
    print(f"  Thiếu khối SQL      : {len(missing)} {missing if missing else ''}")
    print(f"  Cột thiếu trong DDL : {len(drift)}   (cột nghiệp vụ LLD per-table, trừ cột kỹ thuật — như Gate 4)")
    for t, c in drift[:40]:
        print(f"      - {t}.{c}")
    if drift:
        print("  → Sửa: python .claude/skills/datamart-review/scripts/build_flat_tables.py "
              f"--module {args.module} --sync-columns [--apply]")

    if args.sync_columns:
        if missing:
            print(f"\n⚠️  Còn {len(missing)} bảng thiếu khối SQL — chạy KHÔNG kèm --sync-columns để sinh khối trước.")
        raw_d = ddl_p.read_bytes().decode("utf-8")
        raw_m = dml_p.read_bytes().decode("utf-8")
        new_d, new_m, added, skipped = sync_columns(raw_d, raw_m, prefix, lld_cols, mine)
        print(f"\n=== --sync-columns: {len(added)} cột sẽ chèn, {len(skipped)} cột phải chèn tay ===")
        for flat, c, prev in added:
            print(f"  + {flat}.{c}   (sau {prev or '— đầu bảng —'})")
        for flat, c, why in skipped:
            print(f"  ! {flat}.{c}: {why}")
        if not added:
            sys.exit(1 if (skipped or missing) else 0)
        if not args.apply:
            print("\nⓘ dry-run: chưa ghi gì. Duyệt kế hoạch rồi chạy lại với --apply.")
            sys.exit(1)
        sys.path.insert(0, str(_script_dir))
        import apply_patch  # noqa: E402  (dùng chung cơ chế sao lưu)
        b1, b2 = apply_patch.backup(root, ddl_p), apply_patch.backup(root, dml_p)
        ddl_p.write_bytes(new_d.encode("utf-8"))
        dml_p.write_bytes(new_m.encode("utf-8"))
        left = []
        chk = new_d.split("\n")
        for t in mine:
            have = ddl_columns(chk, f"{prefix}_{t}_flat")
            if have is not None:
                left += [(t, c) for c, *_ in lld_cols.get(t, []) if c not in have]
        print(f"\n✅ Đã ghi DDL + DML. Sao lưu: {b1.relative_to(root).as_posix()}, {b2.relative_to(root).as_posix()}")
        print("→ Chạy tiếp: check_flat_table.py --module " + args.module + " --strict")
        sys.exit(1 if (left or skipped) else 0)

    if args.check:
        sys.exit(1 if (missing or drift) else 0)
    if not missing:
        print("\n✅ Không có bảng nào thiếu khối SQL."
              + ("\n⚠️  Còn cột thiếu trong DDL — chạy lại với --sync-columns [--apply]." if drift else ""))
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
