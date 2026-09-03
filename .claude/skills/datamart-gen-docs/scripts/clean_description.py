"""Helper: strip nội dung kỹ thuật khỏi mô tả trường (Phần C.5).

Usage:
    python clean_description.py "FK lịch — ETL lookup từ Inspection Case.Received Date. THANHTRA.TT_HO_SO.X"
    # → "FK lịch"

    python clean_description.py --file DTM_TT_Attributes.csv
    # → in ra CSV với cột description đã clean, kiểm tra trước khi dùng
"""

from __future__ import annotations

import csv
import re
import sys
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8")


# ─── Patterns cần loại bỏ tuần tự ─────────────────────────────────────────

_PATTERNS = [
    # 1. Bỏ các tiền tố / hậu tố phiên bản, ngày sửa: "(Sửa 2026-07-17)", "(Bổ sung 2026-08)", v.v.
    re.compile(r"\(\s*(?:Sửa|Bổ sung|Thêm|Cập nhật|Update)\s+[^)]*\)", re.IGNORECASE),

    # 2. Tiền tố kỹ thuật đầu dòng: "PK — Driving: ...", "NK — ...", "BK: (...)"
    re.compile(r"^(?:PK|NK|BK|FK|DD)\s*[—\-:]\s*(?:Driving:[^;\n]*|ngày lịch dùng để join[^;\n]*)?", re.IGNORECASE),
    re.compile(r"^(?:PK|NK|BK|FK|DD)$", re.IGNORECASE),
    re.compile(r";\s*BK:\s*\([^)]*\)", re.IGNORECASE),
    re.compile(r"\s*\bDriving:\s*[^;\n.]*(?:\.|$)?", re.IGNORECASE),

    # 3. Khối metadata kỹ thuật Atomic/ETL
    re.compile(r"\s*\bBCV:\s*(?:\"[^\"]*\"|'[^']*'|[^\.\n]+)(?:\.|$)?", re.IGNORECASE),
    re.compile(r"\s*\bHash:\s*[^\.\n]+(?:\.|$)?", re.IGNORECASE),
    re.compile(r"\s*\bNguồn\s+thực:\s*(?:\"[^\"]*\"|'[^']*'|[\w.]+|\S+)*?(?=(?:\.\s+[A-Z\u00C0-\u1EF9]|\s*(?:FK\s+target|Classification|Pair\s+with|Shared\s+entity|BCV|Hash|ETL|Dedup|Filter|Load\s+strategy|Grain)|[;]|$|\n))(?:\.|\s+|$)", re.IGNORECASE),
    re.compile(r"\s*\bFK\s+target:\s*[^\.\n]+(?:\.|$)?", re.IGNORECASE),
    re.compile(r"\s*\bClassification:\s*[^\.\n]+(?:\.|$)?", re.IGNORECASE),
    re.compile(r"\s*\bPair\s+with\s+[^\.\n]+(?:\.|$)?", re.IGNORECASE),
    re.compile(r"\s*\bShared\s+entity\s*[—\-]?\s*[^.\n]*(?:\.|$)?", re.IGNORECASE),

    # 4. Open issues / PENDING / Scheme reference
    re.compile(r"\s*(?:[—-]\s*)?[Xx]em\s+O_[A-Za-z0-9_]+", re.IGNORECASE),
    re.compile(r"\s*\(Closed\)", re.IGNORECASE),
    re.compile(r"\s*\bPENDING\b(?:\s*\([^)]*\))?\s*[:—\-]?", re.IGNORECASE),
    re.compile(r"\s*\bScheme:\s*[A-Za-z0-9_]+(?:\.|\s+|$)", re.IGNORECASE),

    # 5. Dedup, Filter, Technical field, Load strategy, Grain, join_atomic, COUNT notes
    re.compile(r"\s*\(\s*(?:COUNT|SUM|AVG|MAX|MIN)\b(?:[^()]+|\((?:[^()]+|\([^()]*\))*\))*\)", re.IGNORECASE),
    re.compile(r"\s*\b(?:COUNT|SUM|AVG|MAX|MIN)\([^)]*\)[^.\n]*(?:\.|$)?", re.IGNORECASE),
    re.compile(r"\s*\bDedup\b.*?(?=(?:\.\s+[A-Z\u00C0-\u1EF9]|$|\n))(?:\.|\s+|$)", re.IGNORECASE),
    re.compile(r"\s*\bFilter\b.*?(?=(?:\.\s+[A-Z\u00C0-\u1EF9]|$|\n))(?:\.|\s+|$)", re.IGNORECASE),
    re.compile(r"\s*\bTechnical\s+field\b.*?(?=(?:\.\s+[A-Z\u00C0-\u1EF9]|$|\n))(?:\.|\s+|$)", re.IGNORECASE),
    re.compile(r"\s*\bLoad\s+strategy:\s*[^\.\n]+(?:\.|$)?", re.IGNORECASE),
    re.compile(r"\s*(?:[—\-]\s*)?1\s+row\s+per\b.*?(?=(?:\.\s+[A-Z\u00C0-\u1EF9]|$|\n))(?:\.|\s+|$)", re.IGNORECASE),
    re.compile(r"\s*\bGrain\b.*?(?=(?:\.\s+[A-Z\u00C0-\u1EF9]|$|\n))(?:\.|\s+|$)", re.IGNORECASE),
    re.compile(r"\s*(?:ETL\s+)?(?:join_atomic|join|Join\s+ngược)\b.*?(?=(?:\.\s+[A-Z\u00C0-\u1EF9]|$|\n))(?:\.|\s+|$)", re.IGNORECASE),

    # 6. Ghi chú kỹ thuật trong ngoặc hoặc độc lập
    re.compile(r"\s*\(\s*(?:PK|BK|FK|NK|DD|Surrogate(?:\s+Key)?|Foreign\s+Key|Business\s+Key|Natural\s+Key|Primary\s+Key|Current-state|SCD\w*|Silver|nội bộ|tác nghiệp)\s*[^)]*\)", re.IGNORECASE),
    re.compile(r"\s*\bPK\s+surrogate\b\.?", re.IGNORECASE),
    re.compile(r"\s*\bBK\s+chính\b\.?", re.IGNORECASE),
    re.compile(r"\s*\bBK\s+phụ\b\.?", re.IGNORECASE),
    re.compile(r"\s*\b\(?SCD4A\)?\b", re.IGNORECASE),

    # 7. ETL notes & đuôi ghi chú ETL
    re.compile(r";\s*ETL\s+.*?(?=(?:\.\s+[A-Z\u00C0-\u1EF9]|$|\n))(?:\.|\s+|$)", re.IGNORECASE),
    re.compile(r"\.\s*ETL\s+.*?(?=(?:\.\s+[A-Z\u00C0-\u1EF9]|$|\n))(?:\.|\s+|$)", re.IGNORECASE),
    re.compile(r"\s*(?:[—\-]\s*)?ETL[-\s](?:lookup|extract|pick|derived|join|crosswalk|load|tạm)\b(?:\s+(?:từ|theo|qua|tại|vào|bởi|cho|bằng)\b)?(?:\s+[A-Za-z0-9_ ]+?(?=\.|\s*[A-Z]{2,}\.|$))?", re.IGNORECASE),
    re.compile(r"\s*\bETL\s+load\s+timestamp\b", re.IGNORECASE),
    re.compile(r"\s*\bETL\s+sinh\s+tự\s+động\b", re.IGNORECASE),
    re.compile(r"\s*(?:[,;—\-]\s*)?chờ\s+Atomic\s+bổ\s+sung.*?(?=(?:\.\s+[A-Z\u00C0-\u1EF9]|$|\n))(?:\.|\s+|$)", re.IGNORECASE),

    # 8. Tham chiếu bảng nguồn inline còn sót lại
    re.compile(r"(?:\s*|\b)(?:THANHTRA|IDS|FIMS|FMS|GSGD|NHNCK|SCMS|QLRR|DCST|TTHC|ECAT|MDDS|[A-Z]{2,10})\.[A-Z0-9_]+(?:\.[A-Za-z0-9_]+)*\.?", re.IGNORECASE),
]

_TRAILING_DASH = re.compile(
    r"\s*[—-]\s*(?:ETL|Driving:|lookup|1\s+row\s+per|IDS\.|FIMS\.|FMS\.|GSGD\.|NHNCK\.|SCMS\.|QLRR\.|DCST\.|TTHC\.|ECAT\.|MDDS\.|THANHTRA\.|[A-Z]{2,10}\.[A-Z0-9_]|[A-Za-z0-9_]+\.[A-Za-z0-9_]+\.[A-Za-z0-9_]|xem\s+O_|Xem\s+O_|PK|BK|FK|DD|Surrogate|Foreign\s+Key|Business\s+Key|Natural\s+Key|Primary\s+Key|SCD|Shared\s+entity|không\s+có\s+PK).*$",
    re.IGNORECASE
)

_TRAILING_DOT_SOURCE = re.compile(
    r"\.\s+(?:THANHTRA|IDS|FIMS|FMS|GSGD|NHNCK|SCMS|QLRR|DCST|TTHC|ECAT|MDDS|[A-Z]{2,10})\.[A-Z0-9_].*$",
    re.IGNORECASE
)


def clean(desc: str) -> str:
    """Strip tất cả nội dung kỹ thuật từ chuỗi mô tả, chuẩn hóa văn phong tiếng Việt."""
    if not desc:
        return ""
    s = desc.strip()

    # Bước 1: Bỏ phần sau dấu gạch ngang nếu là nội dung kỹ thuật / tham chiếu nguồn
    s = _TRAILING_DASH.sub("", s)

    # Bước 2: Bỏ phần sau dấu chấm nếu là tham chiếu bảng nguồn
    s = _TRAILING_DOT_SOURCE.sub("", s)

    # Bước 3: Áp dụng danh sách regex patterns
    for pat in _PATTERNS:
        s = pat.sub("", s)

    # Bước 4: Làm sạch dấu câu ở đầu và cuối chuỗi
    s = re.sub(r"^[\s.—\-:,;]+", "", s)
    s = re.sub(r"[\s.—\-:,;]+$", "", s)
    s = re.sub(r"\s{2,}", " ", s).strip()

    # Bước 5: Viết hoa chữ cái đầu tiên nếu chuỗi hợp lệ
    if s and s[0].islower():
        s = s[0].upper() + s[1:]

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
