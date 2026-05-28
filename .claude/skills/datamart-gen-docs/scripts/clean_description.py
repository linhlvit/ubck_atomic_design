"""Helper: strip nội dung kỹ thuật khỏi mô tả trường (Phần C.5).

Usage:
    python clean_description.py "FK lịch — ETL lookup từ Inspection Case.Received Date. ThanhTra.TT_HO_SO.X"
    # → "FK lịch"

    python clean_description.py --file DTM_TT_Attributes.csv
    # → in ra CSV với cột description đã clean, kiểm tra trước khi dùng
"""

from __future__ import annotations

import csv
import re
import sys
from pathlib import Path


# ─── Patterns cần bỏ ─────────────────────────────────────────────────────────

_PATTERNS = [
    # Tham chiếu nguồn: "— IDS.table.col", "ThanhTra.TABLE.COL" (prefix UPPERCASE.TABLE.col)
    re.compile(r"\s*[—-]\s*[A-Z][A-Za-z]+\.[A-Z_]+\.[A-Za-z_.]+"),
    re.compile(r"\s*\bThanhTra\.[A-Z_]+\.[A-Z_a-z_.]+"),
    re.compile(r"\s*\b[A-Z]{2,10}\.[A-Z_]{3,}\.[A-Za-z_]+"),   # SOURCE.TABLE.col
    # Open issue: "Xem O_XX_N", "(Closed)", "xem O_TT_4"
    re.compile(r"\s*[—-]?\s*[Xx]em\s+O_[A-Z]+_\d+"),
    re.compile(r"\s*\(Closed\)", re.IGNORECASE),
    # Ghi chú kỹ thuật: "(PK Silver)", "(BK nguồn)", "(PK bảng tác nghiệp)"
    re.compile(r"\s*\(\s*(?:PK|BK|FK)\s+[^)]{0,40}\)"),
    # PENDING ghi chú
    re.compile(r"\s*PENDING\s*\([^)]*\)", re.IGNORECASE),
    # Scheme reference
    re.compile(r"\s*Scheme:\s*[A-Z_]+", re.IGNORECASE),
    # ETL notes (đặt sau — hoặc . hoặc đầu câu)
    re.compile(r"\s*[—\-.]?\s*ETL[-\s](?:lookup|extract|pick|derived|join|sinh)[^.]*", re.IGNORECASE),
    re.compile(r"\s*[—\-.]?\s*ETL\s+[^.]{0,60}", re.IGNORECASE),
    # FK label prefix: "FK lịch — ", "FK phân loại — " — chỉ bỏ phần sau dấu —
    re.compile(r"(FK\s+[^—\n]{0,40})\s*—\s*ETL[^.]*"),
    # Trailing dots và khoảng trắng
    re.compile(r"\s*\.\s*$"),
]

# Bỏ phần sau dấu " — " nếu phần sau bắt đầu bằng ETL hoặc tham chiếu nguồn
_TRAILING_DASH = re.compile(r"\s*[—]\s*(?:ETL|[A-Z][A-Za-z]+\.[A-Z_]+).*$")

# Bỏ phần sau dấu ". " nếu phần sau bắt đầu bằng tên hệ thống nguồn
_TRAILING_DOT_SOURCE = re.compile(
    r"\.\s+(?:ThanhTra|IDS|FIMS|FMS|GSGD|NHNCK|SCMS|QLRR|ThanhTra|DCST|[A-Z]{2,10})\.[A-Z_].*$"
)

# Số đếm/COUNT note
_COUNT_NOTE = re.compile(r"\s*COUNT\([^)]*\)[^.]*", re.IGNORECASE)

# Khoảng trắng thừa và trailing dash/dot
_TRAILING_PUNCT = re.compile(r"[\s.—\-]+$")


def clean(desc: str) -> str:
    """Strip tất cả nội dung kỹ thuật từ chuỗi mô tả."""
    if not desc:
        return ""
    s = desc.strip()

    # Bỏ phần sau — nếu phần sau là ETL / tham chiếu nguồn
    s = _TRAILING_DASH.sub("", s)
    # Bỏ phần sau ". SYSTEM.TABLE..." (dấu chấm sau câu mô tả)
    s = _TRAILING_DOT_SOURCE.sub("", s)
    # COUNT note
    s = _COUNT_NOTE.sub("", s)

    # Apply từng pattern
    for pat in _PATTERNS:
        s = pat.sub("", s)

    # Làm sạch lần cuối
    s = _TRAILING_PUNCT.sub("", s).strip()
    return s


def _process_csv(path: Path) -> None:
    """Đọc CSV, in ra version đã clean để review."""
    rows = []
    with path.open(encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        fieldnames = reader.fieldnames or []
        for row in reader:
            rows.append(row)

    if "description" not in fieldnames:
        print(f"ERROR: Không tìm thấy cột 'description' trong {path}", file=sys.stderr)
        sys.exit(1)

    out_rows = []
    changed = 0
    for row in rows:
        orig = row.get("description", "")
        cleaned = clean(orig)
        if cleaned != orig:
            changed += 1
        out_rows.append({**row, "description": cleaned})

    print(f"Tổng {len(rows)} dòng — {changed} dòng có thay đổi", file=sys.stderr)

    writer = csv.DictWriter(sys.stdout, fieldnames=fieldnames, lineterminator="\n")
    writer.writeheader()
    writer.writerows(out_rows)


def main() -> None:
    import argparse
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("text", nargs="?", help="Chuỗi mô tả cần clean (single string)")
    group.add_argument("--file", type=Path, help="Path tới file Attributes.csv — in ra CSV đã clean")
    args = parser.parse_args()

    if args.file:
        _process_csv(args.file)
    else:
        print(clean(args.text))


if __name__ == "__main__":
    main()
