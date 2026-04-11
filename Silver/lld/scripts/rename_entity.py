"""
rename_entity.py
================
Phát hiện rename Silver entity từ silver_entities.csv (source of truth)
so sánh với manifest.csv (chứa tên cũ chưa sync) và propagate tên mới
ra tất cả file liên quan.

silver_entities.csv là source of truth:
  - Người review sửa cột silver_entity trực tiếp trong silver_entities.csv
  - Đổi status → reviewed để đánh dấu đã confirm
  - Chạy script này để propagate

Quy trình người review:
  1. Sửa silver_entity (và/hoặc table_type) trong silver_entities.csv
  2. Đổi cột status: draft → reviewed
  3. Chạy: python rename_entity.py
  4. Kiểm tra log output
  5. (Optional) python aggregate_silver.py để refresh silver_attributes.csv

Cách dùng:
  python rename_entity.py              # apply rename thật sự
  python rename_entity.py --dry-run    # in diff, không ghi file

Lock mechanism:
  - Dòng silver_entities.csv có status=reviewed → tên entity là confirmed value
  - Script phát hiện rename bằng cách so sánh silver_entities.csv (tên mới)
    với manifest.csv (tên cũ — chưa được sync)
  - Sau khi propagate, manifest.csv được cập nhật để giữ sync
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
# Đọc silver_entities.csv → {source_table_fqn: silver_entity} cho reviewed rows
# và {silver_entity: lld_file} để biết file nào cần patch
# ---------------------------------------------------------------------------
def load_reviewed_entities() -> dict[str, str]:
    """
    Trả về {silver_entity: silver_entity} cho các dòng status=reviewed.
    Dùng để xác định tên mới đã confirmed.
    """
    result = {}
    if not OUT_ENTITIES.exists():
        return result
    with open(OUT_ENTITIES, encoding="utf-8", newline="") as f:
        for row in csv.DictReader(f):
            if row.get("status", "").strip().lower() == "reviewed":
                result[row["silver_entity"]] = row
    return result


# ---------------------------------------------------------------------------
# Đọc manifest → {source_table_fqn: silver_entity} (tên cũ)
# ---------------------------------------------------------------------------
def load_manifest() -> list[dict]:
    with open(MANIFEST, encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


# ---------------------------------------------------------------------------
# Phát hiện rename: so sánh silver_entities.csv (reviewed, tên mới)
# với manifest.csv (tên cũ — chưa sync)
# Returns: list of (old_name, new_name, source_system, lld_file)
# ---------------------------------------------------------------------------
def detect_renames(reviewed_entities: dict[str, dict],
                   manifest_rows: list[dict]) -> list[tuple[str, str, str, str]]:
    """
    reviewed_entities: {new_silver_entity → row} từ silver_entities.csv status=reviewed
    manifest_rows: danh sách rows từ manifest.csv (chứa tên cũ)

    Detect: dòng manifest có silver_entity không có trong reviewed_entities
    nhưng có 1 reviewed entity khác mà source_table match.
    """
    # Build: {source_table_fqn → new_name} từ silver_entities (reviewed)
    # Dùng cột source_table trong silver_entities.csv để map
    fqn_to_new: dict[str, str] = {}
    for new_name, row in reviewed_entities.items():
        for st in row["source_table"].split(", "):
            fqn_to_new[st.strip()] = new_name

    renames = []
    seen_pairs: set = set()

    for row in manifest_rows:
        fqn = f"{row['source_system']}.{row['source_table']}"
        old_name = row["silver_entity"].strip()
        new_name = fqn_to_new.get(fqn, "")

        if not new_name or new_name == old_name:
            continue

        pair = (old_name, new_name)
        if pair in seen_pairs:
            continue
        seen_pairs.add(pair)
        renames.append((old_name, new_name, row["source_system"], row["lld_file"]))

    return renames


# ---------------------------------------------------------------------------
# Helper: replace exact phrase (plain string, an toàn cho tên có space)
# ---------------------------------------------------------------------------
def replace_in_text(text: str, old: str, new: str) -> tuple[str, int]:
    count = text.count(old)
    if count:
        text = text.replace(old, new)
    return text, count


# ---------------------------------------------------------------------------
# Sửa CSV file: thay trong cột được chỉ định
# ---------------------------------------------------------------------------
def patch_csv_columns(path: Path, old: str, new: str,
                      columns: list[str], dry_run: bool) -> int:
    if not path.exists():
        return 0

    with open(path, encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        fieldnames = reader.fieldnames
        rows = list(reader)

    total = 0
    for row in rows:
        for col in columns:
            if col in row:
                new_val, cnt = replace_in_text(row[col], old, new)
                if cnt:
                    row[col] = new_val
                    total += cnt

    if total and not dry_run:
        with open(path, "w", encoding="utf-8", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames, lineterminator="\n",
                                    extrasaction="ignore")
            writer.writeheader()
            writer.writerows(rows)

    return total


# ---------------------------------------------------------------------------
# Sửa Markdown file: replace toàn bộ text
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

    # 1. silver_entities.csv — cập nhật source_table column nếu có reference
    cnt = patch_csv_columns(OUT_ENTITIES, old, new,
                            columns=["source_table"],
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

    # 3. manifest.csv — cập nhật silver_entity để giữ sync
    cnt = patch_csv_columns(MANIFEST, old, new,
                            columns=["silver_entity"],
                            dry_run=dry_run)
    if cnt:
        print(f"  {prefix}manifest.csv                 : {cnt} thay thế")
    total_changes += cnt

    # 4. Attr CSV file của entity này
    cnt = patch_attr_file(source_system, lld_file, old, new, dry_run)
    if cnt:
        print(f"  {prefix}{source_system}/{lld_file:<35}: {cnt} thay thế")
    total_changes += cnt

    # 4b. Các attr file của entity KHÁC (có thể tham chiếu entity này trong description/comment)
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

    # 5. HLD Markdown files
    md_files = sorted(HLD_DIR.glob("*.md"))
    for md_path in md_files:
        cnt = patch_markdown(md_path, old, new, dry_run)
        if cnt:
            print(f"  {prefix}hld/{md_path.name:<42}: {cnt} thay thế")
        total_changes += cnt

    # 6. ref_shared_entity_classifications.csv
    if REF_SHARED.exists():
        with open(REF_SHARED, encoding="utf-8", newline="") as f:
            ref_fields = csv.DictReader(f).fieldnames or []
        cnt = patch_csv_columns(REF_SHARED, old, new,
                                columns=list(ref_fields),
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
        description="Propagate Silver entity rename từ silver_entities.csv ra tất cả file liên quan."
    )
    parser.add_argument("--dry-run", action="store_true",
                        help="In diff ra stdout, không ghi file")
    args = parser.parse_args()

    print("Đọc silver_entities.csv (reviewed rows)...", file=sys.stderr)
    reviewed_entities = load_reviewed_entities()

    if not reviewed_entities:
        print("Không có dòng nào có status=reviewed trong silver_entities.csv.", file=sys.stderr)
        print("Gợi ý: sửa silver_entity trong silver_entities.csv, đổi status → reviewed, rồi chạy lại.", file=sys.stderr)
        return

    print(f"  {len(reviewed_entities)} reviewed entities", file=sys.stderr)

    print("Đọc manifest.csv (tên cũ)...", file=sys.stderr)
    manifest_rows = load_manifest()

    renames = detect_renames(reviewed_entities, manifest_rows)

    if not renames:
        print("\nKhông phát hiện rename nào.")
        print("Gợi ý: đảm bảo silver_entity trong silver_entities.csv đã sửa khác với manifest,")
        print("        và dòng đó có status=reviewed.")
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
        print("Chạy aggregate_silver.py để refresh silver_attributes.csv.")


if __name__ == "__main__":
    main()
