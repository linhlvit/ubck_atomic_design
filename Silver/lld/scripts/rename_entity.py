"""
rename_entity.py
================
Phát hiện rename Silver entity từ manifest.csv (so sánh với silver_entities.csv hiện tại)
và propagate tên mới ra tất cả file liên quan.

Quy trình người review:
  1. Sửa silver_entity trong manifest.csv
  2. Đổi status: draft -> reviewed
  3. Chạy: python rename_entity.py
  4. Kiểm tra log output
  5. (Optional) python aggregate_silver.py để refresh aggregate CSVs

Cách dùng:
  python rename_entity.py              # apply rename thật sự
  python rename_entity.py --dry-run    # in diff, không ghi file

Lock mechanism:
  - Dòng manifest có status=reviewed → tên entity là confirmed value
  - Script chỉ propagate RENAME (old→new), không bao giờ overwrite ngược lại
  - aggregate_silver.py đọc trực tiếp từ manifest → tự generate đúng tên reviewed
"""

import csv
import sys
import argparse
import io
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
OUT_ATTRS    = LLD_DIR / "silver_attributes.csv"
OUT_ENTITIES = HLD_DIR / "silver_entities.csv"
REF_SHARED   = LLD_DIR / "ref_shared_entity_classifications.csv"


# ---------------------------------------------------------------------------
# Đọc manifest → {source_table: {silver_entity, source_system, lld_file, status}}
# ---------------------------------------------------------------------------
def load_manifest() -> list[dict]:
    with open(MANIFEST, encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


# ---------------------------------------------------------------------------
# Đọc silver_entities.csv → {source_table: old_entity_name}
# Dùng để phát hiện rename (so sánh với manifest hiện tại)
# ---------------------------------------------------------------------------
def load_existing_entities() -> dict[str, str]:
    """Trả về {source_table_fqn: silver_entity} từ silver_entities.csv."""
    result = {}
    if not OUT_ENTITIES.exists():
        return result
    with open(OUT_ENTITIES, encoding="utf-8", newline="") as f:
        for row in csv.DictReader(f):
            # source_table dạng "FMS.FUNDS" hoặc "FMS.FUNDS, DCST.XYZ"
            for st in row["source_table"].split(", "):
                result[st.strip()] = row["silver_entity"]
    return result


# ---------------------------------------------------------------------------
# Phát hiện các rename pair: (old_name, new_name, source_system, lld_file)
# Chỉ detect dòng manifest có status=reviewed VÀ tên khác với snapshot cũ
# ---------------------------------------------------------------------------
def detect_renames(manifest_rows: list[dict],
                   existing: dict[str, str]) -> list[tuple[str, str, str, str]]:
    """
    Trả về list of (old_name, new_name, source_system, lld_file).
    Chỉ include dòng status=reviewed có tên mới khác tên cũ trong silver_entities.csv.
    """
    renames = []
    seen_pairs = set()  # tránh duplicate nếu 1 entity map nhiều source_table

    for row in manifest_rows:
        if row.get("status", "").strip().lower() != "reviewed":
            continue
        new_name = row["silver_entity"].strip()
        fqn = f"{row['source_system']}.{row['source_table']}"
        old_name = existing.get(fqn, "").strip()

        if not old_name or old_name == new_name:
            continue

        pair = (old_name, new_name)
        if pair in seen_pairs:
            continue
        seen_pairs.add(pair)
        renames.append((old_name, new_name, row["source_system"], row["lld_file"]))

    return renames


# ---------------------------------------------------------------------------
# Helper: replace exact word/phrase (không dùng regex word boundary vì tên
# entity có thể chứa dấu cách và ký tự đặc biệt)
# Dùng plain string replace — an toàn cho tên tiếng Anh có space
# ---------------------------------------------------------------------------
def replace_in_text(text: str, old: str, new: str) -> tuple[str, int]:
    """Thay thế tất cả occurrence của old trong text. Trả về (new_text, count)."""
    count = text.count(old)
    if count:
        text = text.replace(old, new)
    return text, count


# ---------------------------------------------------------------------------
# Sửa CSV file: thay trong cột được chỉ định
# ---------------------------------------------------------------------------
def patch_csv_columns(path: Path, old: str, new: str,
                      columns: list[str], dry_run: bool) -> int:
    """
    Đọc CSV, replace old→new trong các cột được chỉ định.
    Trả về tổng số lần replace.
    """
    if not path.exists():
        return 0

    with open(path, encoding="utf-8", newline="") as f:
        rows = list(csv.DictReader(f))
        fieldnames = csv.DictReader(open(path, encoding="utf-8")).fieldnames

    total = 0
    changed_rows = []
    for row in rows:
        for col in columns:
            if col in row:
                new_val, cnt = replace_in_text(row[col], old, new)
                if cnt:
                    row[col] = new_val
                    total += cnt
        changed_rows.append(row)

    if total and not dry_run:
        with open(path, "w", encoding="utf-8", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames, lineterminator="\n",
                                    extrasaction="ignore")
            writer.writeheader()
            writer.writerows(changed_rows)

    return total


# ---------------------------------------------------------------------------
# Sửa Markdown file: replace toàn bộ text (tất cả context)
# ---------------------------------------------------------------------------
def patch_markdown(path: Path, old: str, new: str, dry_run: bool) -> int:
    if not path.exists():
        return 0
    text = path.read_text(encoding="utf-8")
    new_text, count = replace_in_text(text, old, new)
    if count and not dry_run:
        path.write_text(new_text, encoding="utf-8")
    return count


# ---------------------------------------------------------------------------
# Sửa attr CSV file: replace trong attribute_name, description, comment
# ---------------------------------------------------------------------------
def patch_attr_file(source_system: str, lld_file: str,
                    old: str, new: str, dry_run: bool) -> int:
    path = LLD_DIR / source_system / lld_file
    return patch_csv_columns(
        path, old, new,
        columns=["attribute_name", "description", "comment"],
        dry_run=dry_run
    )


# ---------------------------------------------------------------------------
# Main propagate logic
# ---------------------------------------------------------------------------
def propagate_rename(old: str, new: str,
                     source_system: str, lld_file: str,
                     manifest_rows: list[dict],
                     dry_run: bool) -> None:
    prefix = "[DRY-RUN] " if dry_run else ""
    print(f"\n{'='*60}")
    print(f"{prefix}RENAME: '{old}' → '{new}'")
    print(f"{'='*60}")

    total_changes = 0

    # 1. silver_entities.csv
    cnt = patch_csv_columns(OUT_ENTITIES, old, new,
                            columns=["silver_entity", "description", "source_table"],
                            dry_run=dry_run)
    if cnt:
        print(f"  {prefix}silver_entities.csv          : {cnt} thay thế")
    total_changes += cnt

    # 2. silver_attributes.csv
    cnt = patch_csv_columns(OUT_ATTRS, old, new,
                            columns=["silver_entity", "silver_attribute",
                                     "description", "source_column"],
                            dry_run=dry_run)
    if cnt:
        print(f"  {prefix}silver_attributes.csv        : {cnt} thay thế")
    total_changes += cnt

    # 3. Attr CSV file của entity này
    cnt = patch_attr_file(source_system, lld_file, old, new, dry_run)
    if cnt:
        print(f"  {prefix}{source_system}/{lld_file:<35}: {cnt} thay thế")
    total_changes += cnt

    # 3b. Các attr file của entity KHÁC (có thể tham chiếu entity này trong description/comment)
    for row in manifest_rows:
        other_lld = row["lld_file"]
        other_sys = row["source_system"]
        if other_lld == lld_file and other_sys == source_system:
            continue
        path = LLD_DIR / other_sys / other_lld
        cnt = patch_csv_columns(path, old, new,
                                columns=["attribute_name", "description", "comment"],
                                dry_run=dry_run)
        if cnt:
            print(f"  {prefix}{other_sys}/{other_lld:<35}: {cnt} thay thế")
        total_changes += cnt

    # 4. HLD Markdown files
    md_files = sorted(HLD_DIR.glob("*.md"))
    for md_path in md_files:
        cnt = patch_markdown(md_path, old, new, dry_run)
        if cnt:
            print(f"  {prefix}hld/{md_path.name:<42}: {cnt} thay thế")
        total_changes += cnt

    # 5. ref_shared_entity_classifications.csv
    cnt = patch_csv_columns(REF_SHARED, old, new,
                            columns=list(
                                csv.DictReader(open(REF_SHARED, encoding="utf-8")).fieldnames
                            ) if REF_SHARED.exists() else [],
                            dry_run=dry_run)
    if cnt:
        print(f"  {prefix}ref_shared_entity_classifications.csv: {cnt} thay thế")
    total_changes += cnt

    print(f"\n  Tổng cộng: {total_changes} thay thế")
    if dry_run:
        print("  (Dry-run: không ghi file)")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(
        description="Propagate Silver entity rename từ manifest.csv ra tất cả file liên quan."
    )
    parser.add_argument("--dry-run", action="store_true",
                        help="In diff ra stdout, không ghi file")
    args = parser.parse_args()

    print("Đọc manifest.csv...", file=sys.stderr)
    manifest_rows = load_manifest()

    print("Đọc silver_entities.csv (snapshot cũ)...", file=sys.stderr)
    existing = load_existing_entities()

    if not existing:
        print("WARN: silver_entities.csv trống hoặc không tồn tại. "
              "Chạy aggregate_silver.py trước để tạo snapshot.", file=sys.stderr)

    renames = detect_renames(manifest_rows, existing)

    if not renames:
        print("\nKhông phát hiện rename nào.")
        print("Gợi ý: đảm bảo dòng manifest đã đổi silver_entity VÀ status=reviewed,")
        print("        và silver_entities.csv còn chứa tên cũ (chưa aggregate lại).")
        return

    print(f"\nPhát hiện {len(renames)} rename:")
    for old, new, sys_name, lld in renames:
        print(f"  '{old}' → '{new}'  [{sys_name}]")

    for old, new, sys_name, lld in renames:
        propagate_rename(old, new, sys_name, lld,
                         manifest_rows, dry_run=args.dry_run)

    print("\n" + "="*60)
    if args.dry_run:
        print("Dry-run hoàn thành. Chạy lại không có --dry-run để apply.")
    else:
        print("Hoàn thành. Các file đã được cập nhật.")
        print("Chạy aggregate_silver.py để refresh silver_entities.csv và silver_attributes.csv.")


if __name__ == "__main__":
    main()
