# -*- coding: utf-8 -*-
"""
check_hld_5b.py — Gate 5: Bước 5B self-check cấu trúc HLD (14 mục #0–#13)

Usage:
    python scripts/check_hld_5b.py --module PTTT
    python scripts/check_hld_5b.py --module ALL --strict
Exit: 0 PASS | 1 FAIL
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

from datamart_common import find_project_root, get_available_modules, resolve_module_path  # noqa: E402
from datamart_common.hld_5b_checker import audit_hld_5b, render_5b_report  # noqa: E402
from datamart_common.module_resolver import normalize_module_name  # noqa: E402


def main() -> None:
    ap = argparse.ArgumentParser(description="Gate 5 — Bước 5B HLD structure self-check")
    ap.add_argument("-m", "--module", required=True, help="Tên module hoặc ALL")
    ap.add_argument("--strict", action="store_true")
    ap.add_argument("--root", default=None, help="Thư mục gốc repo (tự dò nếu bỏ trống)")
    args = ap.parse_args()

    root = find_project_root(args.root) if args.root else find_project_root()
    modules = get_available_modules(root) if args.module.upper() == "ALL" else [args.module]

    failed = False
    for mod in modules:
        hld = resolve_module_path(root, mod, "hld")
        if not hld or not Path(hld).is_file():
            print(f"[SKIP] {mod}: không tìm thấy file HLD")
            continue
        res = audit_hld_5b(Path(hld), normalize_module_name(mod))
        print(render_5b_report(res))
        print()
        if res.failed:
            failed = True
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
