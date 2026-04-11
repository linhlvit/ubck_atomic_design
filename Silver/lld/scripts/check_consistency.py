"""
check_consistency.py
====================
Kiểm tra tính nhất quán giữa HLD Markdown files và silver_entities.csv.

Phát hiện xung đột: entity name trong HLD file khác với tên trong silver_entities.csv
(source of truth cho entity-level attributes).
Dùng sau khi re-run thiết kế HLD để đảm bảo tên reviewed không bị ghi đè.

Cách dùng:
  python check_consistency.py              # kiểm tra toàn bộ
  python check_consistency.py --source FMS # chỉ kiểm tra source system FMS
  python check_consistency.py --fix-hints  # in gợi ý câu lệnh sửa (không tự sửa)

Output:
  - CONFLICT: entity trong HLD có tên khác silver_entities.csv
  - OK: không có xung đột
  - WARN: entity trong silver_entities.csv không tìm thấy trong bất kỳ HLD file nào
"""

import csv
import re
import sys
import io
import argparse
from pathlib import Path

# Fix encoding trên Windows terminal
if sys.stdout.encoding and sys.stdout.encoding.lower() not in ("utf-8", "utf-8-sig"):
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
if sys.stderr.encoding and sys.stderr.encoding.lower() not in ("utf-8", "utf-8-sig"):
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
SCRIPT_DIR   = Path(__file__).parent
LLD_DIR      = SCRIPT_DIR.parent
HLD_DIR      = LLD_DIR.parent / "hld"
MANIFEST     = LLD_DIR / "manifest.csv"
OUT_ENTITIES = HLD_DIR / "silver_entities.csv"


# ---------------------------------------------------------------------------
# Đọc silver_entities.csv → danh sách entities (source of truth)
# Nếu source_filter: lọc theo source_table prefix (e.g. "FMS.")
# Returns: list of {"silver_entity", "source_table", "status"}
# ---------------------------------------------------------------------------
def load_reviewed_entities(source_filter: str | None = None) -> list[dict]:
    entities = []
    if not OUT_ENTITIES.exists():
        return entities
    with open(OUT_ENTITIES, encoding="utf-8", newline="") as f:
        for row in csv.DictReader(f):
            silver_entity = row["silver_entity"].strip()
            source_table  = row.get("source_table", "")
            # Filter theo source system: kiểm tra source_table chứa prefix "FMS."
            if source_filter:
                sources = [s.strip() for s in source_table.split(",")]
                if not any(s.upper().startswith(source_filter.upper() + ".") for s in sources):
                    continue
            entities.append({
                "silver_entity": silver_entity,
                "source_table":  source_table,
                "status":        row.get("status", "draft"),
            })
    return entities


# ---------------------------------------------------------------------------
# Đọc HLD Markdown files → tập hợp tất cả entity name xuất hiện
# Tìm trong: section headings, 6a/7a table cells, Mermaid node labels
# Returns: dict { md_filename: set of entity name strings }
# ---------------------------------------------------------------------------
def extract_entities_from_hld(md_path: Path) -> set[str]:
    """Trích xuất tên entity từ 1 HLD Markdown file."""
    text = md_path.read_text(encoding="utf-8")
    found = set()

    # Pattern 1: Section heading "### N. Entity Name" hoặc "## Entity Name"
    for m in re.finditer(r"^#{2,4}\s+(?:\d+\.\s+)?(.+)$", text, re.MULTILINE):
        name = m.group(1).strip()
        # Bỏ các heading hệ thống (có chứa số thứ tự mục lớn như "6a", "7b")
        if not re.match(r"^6[a-f]|^7[a-f]|^Tier\s+\d|^HLD|^Overview|^Source|^Silver", name, re.IGNORECASE):
            found.add(name)

    # Pattern 2: Ô bảng Markdown "| Entity Name |" — cột đầu tiên của bảng 6a/7a
    # Tìm dòng có ít nhất 2 ký tự | và nội dung không phải header row
    for m in re.finditer(r"^\|\s*([^|]+?)\s*\|", text, re.MULTILINE):
        cell = m.group(1).strip()
        # Bỏ header separator (---) và header label ngắn
        if re.match(r"^-+$|^Entity|^Silver Entity|^Tier|^Bảng|^Source|^BCV|^Loại|^Mục|^Mermaid", cell, re.IGNORECASE):
            continue
        if len(cell) > 5:
            found.add(cell)

    # Pattern 3: Mermaid node label — dạng `[**Entity Name**]` hoặc `"**Entity Name**`
    for m in re.finditer(r'\*\*([^*\n]+?)\*\*', text):
        name = m.group(1).strip()
        if len(name) > 5:
            found.add(name)

    return found


def load_all_hld_entities(source_filter: str | None = None) -> dict[str, set[str]]:
    """
    Trả về {md_filename: set_of_entity_names}.
    Nếu source_filter không None, chỉ đọc file có prefix matching (VD: "FMS_HLD_").
    """
    result = {}
    pattern = f"{source_filter.upper()}_HLD_*.md" if source_filter else "*_HLD_*.md"
    for md_path in sorted(HLD_DIR.glob(pattern)):
        result[md_path.name] = extract_entities_from_hld(md_path)
    return result


# ---------------------------------------------------------------------------
# Kiểm tra: với mỗi reviewed entity, tìm trong HLD entities
# ---------------------------------------------------------------------------
def check(reviewed: list[dict],
          hld_entities: dict[str, set[str]],
          show_hints: bool) -> int:
    """
    So sánh reviewed entities với những gì xuất hiện trong HLD files.
    Trả về số lượng xung đột tìm thấy.
    """
    conflicts = 0
    not_found_warnings = 0

    # Tập tất cả entity names xuất hiện trong bất kỳ HLD file nào
    all_hld_names: set[str] = set()
    for names in hld_entities.values():
        all_hld_names.update(names)

    # Với mỗi reviewed entity, kiểm tra xem có entity nào trong HLD
    # là "gần giống" (similar prefix) nhưng khác tên chính xác không
    reviewed_names = {r["silver_entity"] for r in reviewed}

    print(f"\n{'='*65}")
    print(f"  CHECK CONSISTENCY — silver_entities.csv vs HLD files")
    print(f"{'='*65}")
    print(f"  Entities trong silver_entities.csv : {len(reviewed_names)}")
    print(f"  HLD files được kiểm tra            : {len(hld_entities)}")
    print()

    for entity in sorted(reviewed_names):
        if entity in all_hld_names:
            # Tìm thấy chính xác — OK
            continue

        # Không tìm thấy chính xác — tìm xem có tên "gần giống" không
        similar: list[tuple[str, str]] = []  # (md_file, similar_name)
        words = set(entity.lower().split())

        for md_file, names in hld_entities.items():
            for name in names:
                name_words = set(name.lower().split())
                if len(words) == 0:
                    continue
                overlap = len(words & name_words) / max(len(words), len(name_words))
                if overlap >= 0.6 and name != entity:
                    similar.append((md_file, name))

        if similar:
            conflicts += 1
            print(f"  CONFLICT  '{entity}'")
            print(f"            silver_entities.csv  : '{entity}'")
            for md_file, sim_name in similar[:3]:
                print(f"            HLD [{md_file}]     : '{sim_name}'")
            if show_hints:
                print(f"            Gợi ý: cập nhật HLD để dùng tên từ silver_entities.csv, hoặc")
                print(f"                   chạy rename_entity.py nếu đây là rename mới")
            print()
        else:
            not_found_warnings += 1
            print(f"  WARN  '{entity}' — không tìm thấy trong bất kỳ HLD file nào")

    if conflicts == 0 and not_found_warnings == 0:
        print("  OK — Tất cả reviewed entities nhất quán với HLD files.")
    else:
        if conflicts > 0:
            print(f"  Tổng xung đột: {conflicts}")
        if not_found_warnings > 0:
            print(f"  Tổng WARN (không tìm thấy trong HLD): {not_found_warnings}")

    print(f"{'='*65}\n")
    return conflicts


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(
        description="Kiểm tra nhất quán entity names giữa HLD Markdown files và silver_entities.csv."
    )
    parser.add_argument("--source", metavar="SYSTEM",
                        help="Chỉ kiểm tra source system (VD: FMS, DCST, NHNCK)")
    parser.add_argument("--fix-hints", action="store_true",
                        help="In gợi ý câu lệnh sửa khi phát hiện xung đột")
    args = parser.parse_args()

    source = args.source.upper() if args.source else None

    print("Đọc silver_entities.csv...", file=sys.stderr)
    reviewed = load_reviewed_entities(source_filter=source)

    if not reviewed:
        print(f"Không tìm thấy entity nào{' cho ' + source if source else ''} trong silver_entities.csv. Kết thúc.", file=sys.stderr)
        return

    print(f"Đọc HLD Markdown files...", file=sys.stderr)
    hld_entities = load_all_hld_entities(source_filter=source)

    if not hld_entities:
        print(f"Không tìm thấy HLD file nào{' cho ' + source if source else ''} trong {HLD_DIR}.", file=sys.stderr)
        return

    n_conflicts = check(reviewed, hld_entities, show_hints=args.fix_hints)

    sys.exit(1 if n_conflicts > 0 else 0)


if __name__ == "__main__":
    main()
