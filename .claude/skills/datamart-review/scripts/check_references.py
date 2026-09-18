# -*- coding: utf-8 -*-
"""
check_references.py — Gate 0: Reference Integrity Audit

Kiểm mọi tham chiếu trong thiết kế có trỏ tới thứ tồn tại thật hay không:
  R1 cột Atomic  (L0-ATOMIC-COLUMN-NOT-FOUND)
  R2 cột Mart    (L0-MART-COLUMN-NOT-FOUND)
  R3 cấu trúc CSV(L0-CSV-STRUCTURE-BROKEN)
  R4 đồng bộ trạng thái HLD ↔ Detail Mapping (L0-HLD-LLD-STATUS-DESYNC)

Usage:
    python scripts/check_references.py --module PTTT
    python scripts/check_references.py --module ALL --strict
Exit: 0 PASS | 1 FAIL (có CRITICAL, hoặc --strict và có WARNING)
"""
from __future__ import annotations

import argparse
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
from datamart_common.reference_checker import (  # noqa: E402
    audit_module_references,
    render_report,
)


def main() -> None:
    ap = argparse.ArgumentParser(description="Gate 0 — Reference Integrity Audit")
    ap.add_argument("-m", "--module", required=True, help="Tên module hoặc ALL")
    ap.add_argument("--strict", action="store_true", help="Coi WARNING là lỗi")
    ap.add_argument("--root", default=None, help="Thư mục gốc repo (tự dò nếu bỏ trống)")
    args = ap.parse_args()

    root = find_project_root(args.root) if args.root else find_project_root()
    modules = get_available_modules(root) if args.module.upper() == "ALL" else [args.module]

    failed = False
    for mod in modules:
        res = audit_module_references(root, mod)
        print(render_report(res))
        print()
        if res.critical or (args.strict and res.issues):
            failed = True
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
