# -*- coding: utf-8 -*-
"""
build_kpi_index.py — RFC Đ7: sinh `Datamart/index/kpi_index.csv`

Cho phép tra "KPI này nằm ở đâu, trạng thái gì, map vào cột nào" bằng một lần grep
thay vì nạp cả file HLD 3.000+ dòng vào context.

Cột: kpi_id, module, tab, nhom, kpi_name, hld_status, hld_line, mart_table, mart_column,
     column_role, dm_line

Usage:
    python scripts/build_kpi_index.py
    python scripts/build_kpi_index.py --check
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

from datamart_common import find_project_root, get_available_modules, resolve_module_path  # noqa: E402
from datamart_common.csv_io import DesignCsv, read_design_csv, write_design_csv  # noqa: E402
from datamart_common.module_resolver import normalize_module_name  # noqa: E402

OUT_REL = "Datamart/index/kpi_index.csv"
HEADER = ["kpi_id", "module", "tab", "nhom", "kpi_name", "hld_status", "hld_line",
          "mart_table", "mart_column", "column_role", "dm_line"]

_RE_KPI = re.compile(r"^\|\s*(K_[A-ZĐ]+_\d+)\s*\|(.*)$")


def scan_hld(path: Path):
    """{kpi_id: (status, line_no, tab, nhom, name)} — lấy lần khai sinh đầu tiên."""
    out = {}
    tab = nhom = ""
    for i, line in enumerate(path.read_text(encoding="utf-8").split("\n"), 1):
        if line.startswith("### Tab"):
            tab = line[8:].strip()
        elif line.startswith("#### Nhóm"):
            nhom = line[5:].strip()
        m = _RE_KPI.match(line.rstrip())
        if not m:
            continue
        kpi = m.group(1)
        cells = [c.strip() for c in line.split("|")]
        status = cells[-2] if len(cells) >= 3 else ""
        if status not in ("READY", "PENDING"):
            status = ""
        if kpi not in out:
            out[kpi] = (status, i, tab, nhom, cells[2] if len(cells) > 2 else "")
    return out


def scan_dm(path: Path):
    """{kpi_id: (mart_table, mart_column, role, line_no)} — dòng đầu có mapping."""
    out = {}
    t = read_design_csv(path, strict=False)
    if not t.header:
        return out
    ix = t.ix
    for i, r in enumerate(t.rows, start=2):
        kpi = r[ix["kpi_id"]].strip()
        mt = r[ix["mart_table"]].strip() if "mart_table" in ix else ""
        mc = r[ix["mart_column"]].strip() if "mart_column" in ix else ""
        role = r[ix["column_role"]].strip() if "column_role" in ix else ""
        if kpi in out and not mt:
            continue
        if kpi not in out or mt:
            out[kpi] = (mt, mc, role, i)
    return out


def main() -> None:
    ap = argparse.ArgumentParser(description="RFC Đ7 — sinh chỉ mục KPI")
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--root", default=None)
    args = ap.parse_args()

    root = find_project_root(args.root) if args.root else find_project_root()
    rows = []
    for mod in get_available_modules(root):
        m = normalize_module_name(mod)
        hld_p = resolve_module_path(root, mod, "hld")
        dm_p = resolve_module_path(root, mod, "detail_mapping")
        hld = scan_hld(Path(hld_p)) if hld_p and Path(hld_p).is_file() else {}
        dm = scan_dm(Path(dm_p)) if dm_p and Path(dm_p).is_file() else {}
        for kpi in sorted(set(hld) | set(dm), key=lambda k: (len(k), k)):
            st, ln, tab, nhom, name = hld.get(kpi, ("", "", "", "", ""))
            mt, mc, role, dl = dm.get(kpi, ("", "", "", ""))
            rows.append([kpi, m, tab, nhom, name, st, str(ln), mt, mc, role, str(dl)])

    out_p = root / OUT_REL
    out_p.parent.mkdir(parents=True, exist_ok=True)
    new = DesignCsv(header=HEADER, rows=rows, quote_all=False, path=out_p)

    if args.check:
        if out_p.is_file() and read_design_csv(out_p, strict=False).rows == rows:
            print(f"✅ kpi_index.csv khớp ({len(rows)} KPI).")
            sys.exit(0)
        print(f"❌ kpi_index.csv lệch — chạy: python scripts/build_kpi_index.py")
        sys.exit(1)

    write_design_csv(out_p, new, quote_all=False)
    nready = sum(1 for r in rows if r[5] == "READY")
    npend = sum(1 for r in rows if r[5] == "PENDING")
    print(f"✅ Đã sinh {OUT_REL}: {len(rows)} KPI "
          f"({nready} READY / {npend} PENDING / {len(rows) - nready - npend} chưa rõ) "
          f"trên {len(set(r[1] for r in rows))} module.")


if __name__ == "__main__":
    main()
