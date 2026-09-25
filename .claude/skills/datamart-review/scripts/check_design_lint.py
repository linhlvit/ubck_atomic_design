# -*- coding: utf-8 -*-
"""
check_design_lint.py — Gate 8: Design Lint (các lỗi thực tế không Gate 0–7 nào bắt được).

Bổ sung 2026-09-25 sau phiên NDTNN/PTTT/TKNB/GSTT:
  D1 [L1-HLD-KPI-ROW-CELLS]   Dòng bảng KPI HLD không đúng 7 cột (VD chèn ghi chú thành ô riêng → 8 cột).
                              check_hld_5b chỉ đếm SỐ BẢNG 7 cột, không soi từng dòng.
  D2 [L2-TABLE-ZERO-USAGE]    Bảng Datamart có LLD nhưng 0 dòng Detail Mapping tham chiếu (mart_table hoặc
                              physical name trong logic). check_orphan PASS nếu bảng còn đủ 3 tầng
                              LLD/Entities/Flat, dù không còn KPI nào dùng → phải chạy All-Tier Cleanup.
  D3 [L4-FLAT-COMMENT-PARAM]  Dòng comment flat SQL có ':etl_date' dính ký tự khác khoảng trắng/xuống dòng
                              (VD ':etl_date.') — check_flat_table hiểu nhầm là tham số lạ → Gate 4 FAIL giả.

Mức độ: D1, D3 = ERROR; D2 = WARNING (dimension có thể được dùng qua JOIN của module khác — xác nhận tay).
Exit 1 nếu có ERROR, hoặc có WARNING khi --strict.

Usage:
    python scripts/check_design_lint.py --module GSTT
    python scripts/check_design_lint.py --module ALL --strict
"""
from __future__ import annotations

import argparse
import csv
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

from datamart_common import find_project_root, get_available_modules  # noqa: E402
from datamart_common.module_resolver import resolve_module_path  # noqa: E402

KPI_HEADER = re.compile(r"^\|\s*KPI ID\s*\|.*\|\s*Trạng thái\s*\|\s*$")


def cells(line: str) -> int:
    # bỏ nội dung trong backtick để '|' trong công thức không bị đếm nhầm
    s = re.sub(r"`[^`]*`", "``", line.strip())
    s = s.replace("\\|", "")
    return s.count("|") - 1


def check_hld(hld: Path):
    out = []
    lines = hld.read_text(encoding="utf-8-sig").splitlines()
    in_tbl, want = False, 0
    for i, ln in enumerate(lines, 1):
        if KPI_HEADER.match(ln):
            in_tbl, want = True, cells(ln)
            continue
        if in_tbl:
            if not ln.startswith("|"):
                in_tbl = False
                continue
            if re.match(r"^\|\s*-{3,}", ln):
                continue
            n = cells(ln)
            if n != want:
                kid = ln.split("|")[1].strip()
                out.append(("ERROR", "L1-HLD-KPI-ROW-CELLS", f"{hld.name}:{i} {kid} có {n} cột, bảng KPI yêu cầu {want}"))
    return out


def lld_tables(root: Path, module: str):
    d = root / "Datamart" / "lld" / module
    res = {}
    if not d.exists():
        return res
    for f in sorted(d.glob("*.csv")):
        try:
            with open(f, encoding="utf-8-sig", newline="") as fh:
                for r in csv.DictReader(fh):
                    t = (r.get("datamart_table") or "").strip()
                    e = (r.get("datamart_entity") or "").strip()
                    if t:
                        res.setdefault(t, (e, f.name))
                        break
        except Exception:
            continue
    return res


def check_usage(root: Path, module: str):
    out = []
    dm = resolve_module_path(root, module, "detail_mapping")
    if not dm or not Path(dm).exists():
        return out
    with open(dm, encoding="utf-8-sig", newline="") as fh:
        rows = list(csv.DictReader(fh))
    blob_logic = "\n".join((r.get("logic") or "") for r in rows)
    ents = {(r.get("mart_table") or "").strip() for r in rows}
    for t, (e, fname) in lld_tables(root, module).items():
        if e in ents or re.search(r"\b" + re.escape(t) + r"\b", blob_logic):
            continue
        out.append(("WARNING", "L2-TABLE-ZERO-USAGE",
                    f"{t} ({e}, {fname}) — 0 dòng Detail Mapping {module} tham chiếu. Nếu không module nào dùng → All-Tier Cleanup (Nhánh B); nếu là Dimension dùng qua JOIN module khác → ghi rõ ở Section 4 HLD"))
    return out


def check_flat(root: Path, module: str):
    out = []
    d = root / "Datamart" / "flat-table" / module
    if not d.exists():
        return out
    for f in sorted(d.glob("*.sql")):
        for i, ln in enumerate(f.read_text(encoding="utf-8-sig").splitlines(), 1):
            if ln.lstrip().startswith("--") and re.search(r":etl_date[^\s;)]", ln):
                out.append(("ERROR", "L4-FLAT-COMMENT-PARAM", f"{f.name}:{i} comment chứa ':etl_date' dính ký tự — Gate 4 sẽ báo tham số lạ; viết lại comment"))
    return out


def run(root: Path, module: str):
    issues = []
    hld = resolve_module_path(root, module, "hld")
    if hld and Path(hld).exists():
        issues += check_hld(Path(hld))
    issues += check_usage(root, module)
    issues += check_flat(root, module)
    return issues


def main():
    ap = argparse.ArgumentParser(description="Gate 8 — Design Lint")
    ap.add_argument("-m", "--module", required=True)
    ap.add_argument("--strict", action="store_true")
    ap.add_argument("--root", default=None)
    a = ap.parse_args()
    root = Path(a.root) if a.root else find_project_root()
    mods = get_available_modules(root) if a.module.upper() == "ALL" else [a.module]
    err = warn = 0
    for m in mods:
        iss = run(root, m)
        e = sum(1 for x in iss if x[0] == "ERROR"); w = len(iss) - e
        err += e; warn += w
        print(f"== Design Lint {m}: {e} ERROR, {w} WARNING")
        for lvl, code, msg in iss:
            print(f"  [{'X' if lvl == 'ERROR' else '!'}] [{code}] {msg}")
    ok = err == 0 and (warn == 0 or not a.strict)
    print("PASS" if ok else "FAIL")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
