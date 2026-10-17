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
    # 0. (2026-10-15) Ghi chú nội bộ dạng ngoặc vuông + mã truy vết — đo thực tế: 238/2449 mô tả LLD
    #    vẫn lọt ra tài liệu sau bản clean cũ. Ghi chú [SỬA ...] luôn kéo dài tới hết chuỗi.
    #    - ở ĐẦU chuỗi "[MỚI 2026-09-24, ...] Nội dung" → chỉ bỏ khối ngoặc, giữ nội dung phía sau
    #    - ở GIỮA/CUỐI "Nội dung [SỬA 2026-10-08] lý do..." → bỏ từ khối ngoặc tới hết chuỗi
    #    - khối mở ngoặc không đóng "[SỬA 2026-09-19, review..." → bỏ tới hết chuỗi
    re.compile(r"^\s*\[\s*(?:SỬA|SUA|MỚI|MOI|THIẾT\s+KẾ\s+LẠI|BỔ\s+SUNG|THÊM|CẬP\s+NHẬT|UPDATE|FIX|NOTE|GHI\s+CHÚ|TODO|PENDING|PII|v\d+(?:\.\d+)*|\d{4}-\d{2})\b[^\]\n]*\]\s*", re.IGNORECASE),
    re.compile(r"\s*\[\s*(?:SỬA|SUA|MỚI|MOI|THIẾT\s+KẾ\s+LẠI|BỔ\s+SUNG|THÊM|CẬP\s+NHẬT|UPDATE|FIX|NOTE|GHI\s+CHÚ|TODO|PENDING|v\d+(?:\.\d+)*|\d{4}-\d{2})\b.*$", re.IGNORECASE | re.DOTALL),
    re.compile(r"\s*\(\s*(?:BA\s+SQL|SQL\s+BA|BA)\s*[:`][^()]*(?:\([^()]*\)[^()]*)*\)", re.IGNORECASE),
    #    khối ngoặc vuông bất kỳ có ngày "2026-10-08" ([TÁCH …], [GIẢ ĐỊNH …]) = ghi chú thay đổi
    re.compile(r"^\s*\[[^\]\n]*\b\d{4}-\d{2}(?:-\d{2})?\b[^\]\n]*\]\s*"),
    re.compile(r"\s*\[[^\]\n]*\b\d{4}-\d{2}(?:-\d{2})?\b.*$", re.DOTALL),
    re.compile(r"\s*\(\s*(?:[Xx]em\s+)?[KO]_[A-ZĐ0-9]+_\d+[^)]*\)"),
    re.compile(r"\s*(?:[—\-,;/]\s*)?\b(?:[Xx]em\s+)?[KO]_[A-ZĐ0-9]+_\d+\b(?:\s*(?:Resolved|Closed|Open|đã\s+xử\s+lý))?", re.IGNORECASE),
    re.compile(r"\s*(?:[—\-;,]\s*)?\bSQL\s+(?:tham\s+khảo\s+)?BA\b.*?(?=(?:\.\s+[A-ZÀ-ỹ]|$|\n))(?:\.|\s+|$)", re.IGNORECASE),

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
    re.compile(r"(?:\s*|\b)(?:THANHTRA|IDS|FIMS|FMS|TMS|NHNCK|SCMS|MRMS|DCST|TTHC|ECAT|MDDS|[A-Z]{2,10})\.[A-Z0-9_]+(?:\.[A-Za-z0-9_]+)*\.?", re.IGNORECASE),
]

_TRAILING_DASH = re.compile(
    r"\s*[—-]\s*(?:ETL|Driving:|lookup|1\s+row\s+per|IDS\.|FIMS\.|FMS\.|TMS\.|NHNCK\.|SCMS\.|MRMS\.|DCST\.|TTHC\.|ECAT\.|MDDS\.|THANHTRA\.|[A-Z]{2,10}\.[A-Z0-9_]|[A-Za-z0-9_]+\.[A-Za-z0-9_]+\.[A-Za-z0-9_]|xem\s+O_|Xem\s+O_|PK|BK|FK|DD|Surrogate|Foreign\s+Key|Business\s+Key|Natural\s+Key|Primary\s+Key|SCD|Shared\s+entity|không\s+có\s+PK).*$",
    re.IGNORECASE
)

_TRAILING_DOT_SOURCE = re.compile(
    r"\.\s+(?:THANHTRA|IDS|FIMS|FMS|TMS|NHNCK|SCMS|MRMS|DCST|TTHC|ECAT|MDDS|[A-Z]{2,10})\.[A-Z0-9_].*$",
    re.IGNORECASE
)


# Câu/đoạn chứa dấu hiệu GHI CHÚ QUY TRÌNH nội bộ → bỏ nguyên câu/đoạn (lọc theo câu, sau regex).
# Đo 2026-10-15 trên QLQ: "Câu lệnh tham khảo BA (dòng 5) lọc thêm … cần Atomic team bổ sung", "CHƯA xác minh (TBD)".
_INTERNAL_SENTENCE = re.compile(
    r"tham\s+khảo\s+BA|BA\s+SQL|SQL\s+BA|Câu\s+lệnh|\bTBD\b|Open\s+Issue|Atomic\s+team|team\s+Atomic|chưa\s+xác\s+minh|"
    r"\bgrep\b|Data\s+Modeler|\breview\b|BA\s+dòng|dòng\s+\d+\s+BA|\bBA\s+(?:ghi|yêu\s+cầu|cập\s+nhật|chưa)|"
    r"chưa\s+(?:được\s+)?map|chờ\s+(?:Atomic|BA|xác\s+nhận)|\btạm\s+(?:dùng|đếm|lấy|thời|map)|"
    r"\bwhitelist\b|\bGate\s+\d|\bNhóm\s+\d+\b|:etl_date|\bLLD\b|\bHLD\b",
    re.IGNORECASE)
_FK_ARROW = re.compile(r"^\s*(?:FK|Khóa\s+ngoại)\s*(?:→|->|—>|=>)\s*", re.IGNORECASE)


def _split_top_level(s: str) -> list:
    """Tách câu/đoạn tại '. ' / '; ' / ' — ' NHƯNG không tách bên trong ngoặc (), [] hay `code`."""
    parts, buf, depth, tick, i = [], [], 0, False, 0
    while i < len(s):
        ch = s[i]
        if ch == "`":
            tick = not tick
        elif not tick and ch in "([":
            depth += 1
        elif not tick and ch in ")]" and depth:
            depth -= 1
        if depth == 0 and not tick:
            if ch in ".;" and i + 1 < len(s) and s[i + 1] == " ":
                buf.append(ch)
                parts.append("".join(buf))
                buf, i = [], i + 2
                continue
            if s.startswith(" — ", i):
                parts.append("".join(buf))
                buf, i = ["— "], i + 3
                continue
        buf.append(ch)
        i += 1
    parts.append("".join(buf))
    return [p for p in parts if p.strip()]


def _drop_internal_sentences(s: str) -> str:
    parts = _split_top_level(s)
    kept = [p for p in parts if not _INTERNAL_SENTENCE.search(p)]
    if len(kept) == len(parts):
        return s
    if kept and kept[0].startswith("— "):
        kept[0] = kept[0][2:]
    return " ".join(p.strip() for p in kept)


def clean(desc: str) -> str:
    """Strip tất cả nội dung kỹ thuật từ chuỗi mô tả, chuẩn hóa văn phong tiếng Việt."""
    if not desc:
        return ""
    s = desc.strip()

    # Bước 0: "FK → Calendar Date Dimension (vai trò …)" → "Khóa ngoại tới Calendar Date Dimension (vai trò …)"
    s = _FK_ARROW.sub("Khóa ngoại tới ", s)

    # Bước 1: Bỏ phần sau dấu gạch ngang nếu là nội dung kỹ thuật / tham chiếu nguồn
    s = _TRAILING_DASH.sub("", s)

    # Bước 2: Bỏ phần sau dấu chấm nếu là tham chiếu bảng nguồn
    s = _TRAILING_DOT_SOURCE.sub("", s)

    # Bước 3: Áp dụng danh sách regex patterns
    for pat in _PATTERNS:
        s = pat.sub("", s)

    # Bước 3b: Bỏ nguyên câu/đoạn là ghi chú quy trình nội bộ
    s = _drop_internal_sentences(s)

    # Bước 4: Làm sạch dấu câu ở đầu và cuối chuỗi
    s = re.sub(r"^[\s.—\-:,;]+", "", s)
    s = re.sub(r"[\s.—\-:,;]+$", "", s)
    s = re.sub(r"\s{2,}", " ", s).strip()

    # Bước 5: Viết hoa chữ cái đầu tiên nếu chuỗi hợp lệ
    if s and s[0].islower():
        s = s[0].upper() + s[1:]

    return s


# Dấu hiệu nội dung nội bộ KHÔNG được phép xuất hiện trong tài liệu gửi UBCKNN (sau khi clean).
# Dùng chung cho Gate 8 (check_design_lint.py, luật DESC-LEAK) và render_datamart_md.py.
LEAK_PATTERNS = [
    ("trace_code", re.compile(r"\b[KO]_[A-ZĐ0-9]+_\d+\b")),
    ("change_note", re.compile(r"\[\s*(?:SỬA|SUA|MỚI|THIẾT\s+KẾ\s+LẠI|BỔ\s+SUNG|THÊM|CẬP\s+NHẬT|UPDATE|FIX|NOTE|TODO|v\d+\.\d+)\b", re.IGNORECASE)),
    ("ba_sql_note", re.compile(r"\bSQL\s+(?:tham\s+khảo\s+)?BA\b|\bBA\s+SQL\b|\bBA\s*`", re.IGNORECASE)),
    ("pending", re.compile(r"\bPENDING\b")),
    ("grain_driving", re.compile(r"\b(?:Grain|Driving)\s*[:(]", re.IGNORECASE)),
    ("process_note", _INTERNAL_SENTENCE),
]


def find_leaks(text: str) -> list:
    """Trả danh sách nhãn rò rỉ còn trong chuỗi (đã clean). Rỗng = sạch."""
    return [name for name, rx in LEAK_PATTERNS if rx.search(text or "")]


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
