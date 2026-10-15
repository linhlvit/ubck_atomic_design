# -*- coding: utf-8 -*-
"""
build_registry.py — RFC Đ3: sinh `Datamart/lld/datamart_attributes.csv` từ các file LLD per-module

Nguồn sự thật duy nhất: `Datamart/lld/{MODULE}/*.csv`.
Master registry trở thành **output sinh ra**, không sửa tay nữa — nhờ đó Gate 2 (parity)
luôn PASS thay vì phải canh gác việc quên đồng bộ thủ công.

Usage:
    python scripts/build_registry.py             # sinh lại toàn bộ (bị chặn nếu mất trọn bảng)
    python scripts/build_registry.py --check     # chỉ kiểm tra, không ghi (dùng trong CI / Gate 9)
    python scripts/build_registry.py --allow-drop  # chỉ khi human đã duyệt bỏ các bảng được liệt kê
Exit: 0 khớp / 1 lệch (ở chế độ --check) hoặc lỗi cấu trúc / bị chốt chặn

CHỐT CHẶN MẤT BẢNG (2026-10-15)
    "build_registry làm rơi bảng `_rpt`" (2026-09-29) KHÔNG phải lỗi tìm file: commit 63feed11
    xóa 20 file LLD per-module `_rpt` của TKNB trong khi HLD/flat/model/Detail Mapping vẫn dùng,
    còn VP `fct_derv_*`… chưa từng có file per-module. Master giữ dòng mồ côi; sinh lại từ
    per-module thì đúng hợp đồng nhưng xóa trọn các bảng đó. Vì vậy: bảng có trong master mà
    không còn file per-module → từ chối ghi, liệt kê bảng, chờ human quyết (khôi phục file / bỏ bảng).
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

from datamart_common import find_project_root  # noqa: E402
from datamart_common.csv_io import (  # noqa: E402
    CsvStructureError,
    DesignCsv,
    dropped_groups,
    guard_no_drop,
    guard_shrink,
    read_design_csv,
    write_design_csv,
)

MASTER_REL = "Datamart/lld/datamart_attributes.csv"
KEY = ("datamart_table", "datamart_column")


def collect(root: Path):
    """Đọc mọi file LLD per-module, trả (header, rows, danh sách lỗi)."""
    lld_root = root / "Datamart" / "lld"
    header = None
    rows = []
    seen = {}
    errors = []
    for mod_dir in sorted(p for p in lld_root.iterdir() if p.is_dir()):
        for path in sorted(mod_dir.glob("*.csv")):
            try:
                t = read_design_csv(path, strict=True)
            except CsvStructureError as e:
                errors.append(str(e))
                continue
            if not t.header:
                continue
            if header is None:
                header = t.header
            elif t.header != header:
                errors.append(f"{path}: header khác chuẩn\n  chuẩn: {header}\n  file : {t.header}")
                continue
            ix = t.ix
            for r in t.rows:
                # Một bảng mart có thể nhận dữ liệu từ nhiều source system (UNION) —
                # khi đó cùng (datamart_table, datamart_column) hợp lệ xuất hiện nhiều dòng,
                # mỗi dòng một `atomic_table` + `etl_logic` riêng. Khoá định danh vì vậy
                # gồm cả nguồn; xung đột thật là khi trùng khoá nhưng nội dung khác.
                k = tuple(r)
                if k not in seen:
                    seen[k] = (path, r)
                    rows.append(r)
    return header, rows, errors


def main() -> None:
    ap = argparse.ArgumentParser(description="RFC Đ3 — sinh master registry từ LLD per-module")
    ap.add_argument("--check", action="store_true", help="Chỉ so sánh, không ghi")
    ap.add_argument("--allow-drop", action="store_true",
                    help="Cho phép xóa trọn bảng không còn file per-module (chỉ khi human đã duyệt)")
    ap.add_argument("--root", default=None)
    args = ap.parse_args()

    root = find_project_root(args.root) if args.root else find_project_root()
    master_path = root / MASTER_REL

    header, rows, errors = collect(root)
    if errors:
        print("❌ Không sinh được registry — sửa các lỗi sau trước:\n")
        for e in errors[:30]:
            print(e + "\n")
        sys.exit(1)
    if header is None:
        print("❌ Không tìm thấy file LLD nào.")
        sys.exit(1)

    new = DesignCsv(header=header, rows=rows, quote_all=False, path=master_path)

    old_rows = []
    old_header = header
    if master_path.is_file():
        try:
            old = read_design_csv(master_path, strict=False)
            old_rows, old_header = old.rows, old.header or header
        except Exception:
            old_rows = []

    tix = header.index("datamart_table")
    dropped = dropped_groups(old_rows, rows, old_header.index("datamart_table"))

    if args.check:
        if old_rows == rows:
            print(f"✅ Master registry khớp với LLD per-module ({len(rows)} dòng).")
            sys.exit(0)
        old_set, new_set = set(map(tuple, old_rows)), set(map(tuple, rows))
        print(f"❌ Master registry LỆCH: hiện có {len(old_rows)} dòng, sinh ra {len(rows)} dòng "
              f"(chỉ ở master: {len(old_set - new_set)}, chỉ ở per-module: {len(new_set - old_set)}).")
        if dropped:
            print(f"   ⚠ {len(dropped)} bảng có trong master nhưng KHÔNG còn file LLD per-module "
                  f"(sinh lại sẽ xóa trọn — cần human quyết khôi phục file hay bỏ bảng):")
            for t, n in sorted(dropped.items()):
                print(f"     - {t} ({n} dòng)")
        changed = sorted({r[tix] for r in (new_set - old_set)} - set(dropped))
        if changed:
            print(f"   Bảng có dòng mới/đổi ở per-module chưa lên master: {', '.join(changed[:15])}")
        print("   Chạy: python scripts/build_registry.py  (bị chặn nếu còn bảng mất file per-module)")
        sys.exit(1)

    guard_no_drop(MASTER_REL, dropped, args.allow_drop)
    guard_shrink(MASTER_REL, len(old_rows), len(rows), args.allow_drop, flag="--allow-drop")
    write_design_csv(master_path, new, quote_all=False)
    print(f"✅ Đã sinh {MASTER_REL}: {len(rows)} dòng "
          f"(trước: {len(old_rows)}), từ {len(set(r[new.ix['datamart_table']] for r in rows))} bảng.")


if __name__ == "__main__":
    main()
