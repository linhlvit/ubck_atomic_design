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
import json
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
    issue_key,
    render_report,
    render_report_delta,
)

DEFAULT_BASELINE_DIR = "Datamart/context/.gate_baseline"


def _default_baseline_path(root: Path, module: str) -> Path:
    return root / DEFAULT_BASELINE_DIR / f"references_{module}.json"


def main() -> None:
    ap = argparse.ArgumentParser(description="Gate 0 — Reference Integrity Audit")
    ap.add_argument("-m", "--module", required=True, help="Tên module hoặc ALL")
    ap.add_argument("--strict", action="store_true", help="Coi WARNING là lỗi")
    ap.add_argument("--root", default=None, help="Thư mục gốc repo (tự dò nếu bỏ trống)")
    ap.add_argument("--baseline", nargs="?", const="__default__", default=None,
                     help="So sánh với snapshot lần chạy trước, chỉ in DELTA (mới/đã hết) thay vì "
                          "lặp lại toàn bộ danh sách issue — dùng cho các lần chạy LẶP LẠI trong "
                          "cùng 1 phiên marathon nhiều Nhóm (xem context_window_analysis 2026-09-21). "
                          "Bỏ trống giá trị để dùng đường dẫn mặc định theo module.")
    ap.add_argument("--save-baseline", nargs="?", const="__default__", default=None,
                     help="Ghi snapshot issue hiện tại làm baseline cho lần sau (không ảnh hưởng exit code). "
                          "Thường dùng 1 lần đầu phiên: --save-baseline, các lần sau: --baseline.")
    args = ap.parse_args()

    root = find_project_root(args.root) if args.root else find_project_root()
    modules = get_available_modules(root) if args.module.upper() == "ALL" else [args.module]

    failed = False
    for mod in modules:
        res = audit_module_references(root, mod)

        baseline_path = None
        if args.baseline is not None:
            baseline_path = (Path(args.baseline) if args.baseline != "__default__"
                              else _default_baseline_path(root, mod))
        if baseline_path is not None and baseline_path.is_file():
            baseline_keys = set(json.loads(baseline_path.read_text(encoding="utf-8")))
            print(render_report_delta(res, baseline_keys))
        else:
            if baseline_path is not None:
                print(f"ⓘ Không thấy baseline tại {baseline_path} — in đầy đủ lần này, "
                      f"dùng --save-baseline để tạo snapshot cho lần sau.\n")
            print(render_report(res))
        print()

        if args.save_baseline is not None:
            save_path = (Path(args.save_baseline) if args.save_baseline != "__default__"
                          else _default_baseline_path(root, mod))
            save_path.parent.mkdir(parents=True, exist_ok=True)
            save_path.write_text(json.dumps(sorted({issue_key(i) for i in res.issues}),
                                             ensure_ascii=False, indent=2), encoding="utf-8")
            print(f"💾 Đã lưu baseline: {save_path.relative_to(root).as_posix()} "
                  f"({len(res.issues)} issue)\n")

        if res.critical or (args.strict and res.issues):
            failed = True
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
