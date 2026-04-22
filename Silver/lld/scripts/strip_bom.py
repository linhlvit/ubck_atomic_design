"""
strip_bom.py
============
Remove UTF-8 BOM (0xEF 0xBB 0xBF) from a file in-place.

Use case:
  Các file csv được đọc bởi script aggregate với encoding="utf-8" (không strip BOM).
  Nếu Windows tool/Excel write file với BOM → script aggregate fail KeyError.
  Chạy script này trước khi gọi aggregate để đảm bảo file UTF-8 không BOM.

Usage:
  python Silver/lld/scripts/strip_bom.py <path>

  python Silver/lld/scripts/strip_bom.py Silver/lld/manifest.csv
  python Silver/lld/scripts/strip_bom.py Silver/hld/silver_out_of_scope.csv

Exit codes:
  0 — file OK (đã strip BOM hoặc không có BOM)
  1 — usage error (thiếu argument hoặc file không tồn tại)
"""

import sys
from pathlib import Path

BOM = b"\xef\xbb\xbf"


def strip_bom(path: Path) -> bool:
    """Strip BOM from file in-place. Returns True nếu BOM bị remove."""
    data = path.read_bytes()
    if data.startswith(BOM):
        path.write_bytes(data[len(BOM):])
        return True
    return False


def main() -> int:
    if len(sys.argv) != 2:
        print(f"Usage: python {sys.argv[0]} <path>", file=sys.stderr)
        return 1

    path = Path(sys.argv[1])
    if not path.exists():
        print(f"File không tồn tại: {path}", file=sys.stderr)
        return 1

    if strip_bom(path):
        print(f"BOM removed: {path}")
    else:
        print(f"No BOM: {path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
