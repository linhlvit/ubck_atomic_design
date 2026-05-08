"""
rename_entity.py
================
Phát hiện rename Atomic entity từ atomic_entities.csv (source of truth)
so sánh với manifest.csv (chứa tên cũ chưa sync) và propagate tên mới
ra tất cả file liên quan.

atomic_entities.csv là source of truth:
  - Người review sửa cột atomic_entity trực tiếp trong atomic_entities.csv
  - Chạy script này để propagate
  - Nếu entity đang status=approved → script dừng + báo lỗi
    → Cần đổi status → draft trước khi rename

Approved lock:
  - Entity status=approved → tên đã confirmed và LOCKED
  - Không thể rename entity đang approved
  - Quy trình: approved → draft → sửa tên → chạy script → approved lại

Cách dùng:
  python rename_entity.py              # apply rename thật sự
  python rename_entity.py --dry-run    # in diff, không ghi file

Phát hiện rename: atomic_entity trong atomic_entities.csv
  khác với atomic_entity tương ứng trong manifest.csv (match theo source_table).
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
OUT_ATTRS    = LLD_DIR / "atomic_attributes.csv"
OUT_ENTITIES = HLD_DIR / "atomic_entities.csv"
REF_SHARED   = LLD_DIR / "ref_shared_entity_classifications.csv"


# ---------------------------------------------------------------------------
# Đọc atomic_entities.csv → {atomic_entity: row} cho TẤT CẢ entity
# (không filter theo status)
# ---------------------------------------------------------------------------
def load_all_entities() -> dict[str, dict]:
    """
    Trả về {atomic_entity: row_dict} cho tất cả entity trong atomic_entities.csv.
    Dùng để detect rename (diff vs manifest) và check approved lock.
    """
    result = {}
    if not OUT_ENTITIES.exists():
        return result
    with open(OUT_ENTITIES, encoding="utf-8", newline="") as f:
        for row in csv.DictReader(f):
            result[row["atomic_entity"]] = row
    return result


# ---------------------------------------------------------------------------
# Đọc manifest → list of dicts (tên cũ)
# ---------------------------------------------------------------------------
def load_manifest() -> list[dict]:
    with open(MANIFEST, encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


# ---------------------------------------------------------------------------
# Phát hiện rename: so sánh atomic_entities.csv (tên mới)
# với manifest.csv (tên cũ — chưa sync)
# Returns: list of (old_name, new_name, source_system, lld_file)
# ---------------------------------------------------------------------------
def detect_renames(all_entities: dict[str, dict],
                   manifest_rows: list[dict]) -> list[tuple[str, str, str, str]]:
    """
    all_entities: {atomic_entity → row} từ atomic_entities.csv (tên mới)
    manifest_rows: danh sách rows từ manifest.csv (chứa tên cũ)

    Detect: dòng manifest có atomic_entity không có trong atomic_entities
    nhưng source_table match với 1 entity khác trong atomic_entities.
    """
    # Build: {source_table_fqn → new_name} từ atomic_entities
    fqn_to_new: dict[str, str] = {}
    for new_name, row in all_entities.items():
        for st in row.get("source_table", "").split(", "):
            st = st.strip()
            if st:
                fqn_to_new[st] = new_name

    renames = []
    seen_pairs: set = set()

    for row in manifest_rows:
        fqn = f"{row['source_system']}.{row['source_table']}"
        old_name = row["atomic_entity"].strip()
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
# Kiểm tra approved lock: entity nào đang approved mà bị rename → block
# Returns: list of old_name bị block
# ---------------------------------------------------------------------------
def check_approved_lock(all_entities: dict[str, dict],
                        renames: list[tuple[str, str, str, str]]) -> list[str]:
    """
    Với mỗi rename pair, kiểm tra entity (tên mới) có status=approved không.
    Nếu approved → block rename đó.
    Returns: list of (old_name, new_name) bị block.
    """
    # Build lookup cả theo new_name và old_name
    # old_name có thể không còn trong all_entities nếu đã rename
    # → tìm theo source_table match (đã làm trong detect_renames)
    # Ở đây: new_name chắc chắn có trong all_entities
    blocked = []
    for old_name, new_name, sys_name, lld_file in renames:
        entity_row = all_entities.get(new_name)
        if entity_row and entity_row.get("status", "draft").strip().lower() == "approved":
            blocked.append(old_name)
    return blocked


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

    # 1. atomic_entities.csv — cập nhật source_table column nếu có reference
    cnt = patch_csv_columns(OUT_ENTITIES, old, new,
                            columns=["source_table"],
                            dry_run=dry_run)
    if cnt:
        print(f"  {prefix}atomic_entities.csv          : {cnt} thay thế")
    total_changes += cnt

    # 2. atomic_attributes.csv
    cnt = patch_csv_columns(OUT_ATTRS, old, new,
                            columns=["atomic_entity", "atomic_attribute",
                                     "description", "source_column"],
                            dry_run=dry_run)
    if cnt:
        print(f"  {prefix}atomic_attributes.csv        : {cnt} thay thế")
    total_changes += cnt

    # 3. manifest.csv — cập nhật atomic_entity để giữ sync
    cnt = patch_csv_columns(MANIFEST, old, new,
                            columns=["atomic_entity"],
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
        description="Propagate Atomic entity rename từ atomic_entities.csv ra tất cả file liên quan."
    )
    parser.add_argument("--dry-run", action="store_true",
                        help="In diff ra stdout, không ghi file")
    args = parser.parse_args()

    print("Đọc atomic_entities.csv (tất cả entity)...", file=sys.stderr)
    all_entities = load_all_entities()

    if not all_entities:
        print("Không tìm thấy entity nào trong atomic_entities.csv.", file=sys.stderr)
        return

    print(f"  {len(all_entities)} entities", file=sys.stderr)

    print("Đọc manifest.csv (tên cũ)...", file=sys.stderr)
    manifest_rows = load_manifest()

    renames = detect_renames(all_entities, manifest_rows)

    if not renames:
        print("\nKhông phát hiện rename nào.")
        print("Gợi ý: đảm bảo atomic_entity trong atomic_entities.csv đã sửa khác với manifest,")
        print("        và source_table trong atomic_entities.csv khớp với fqn trong manifest.")
        return

    print(f"\nPhát hiện {len(renames)} rename:")
    for old, new, sys_name, lld in renames:
        print(f"  '{old}' → '{new}'  [{sys_name}]")

    # Kiểm tra approved lock
    blocked = check_approved_lock(all_entities, renames)
    if blocked:
        print(f"\nERROR: Các entity sau đang status=approved — không thể rename:")
        for name in blocked:
            print(f"  '{name}'")
        print("\nGợi ý: đổi status → draft trong atomic_entities.csv trước khi rename.")
        sys.exit(1)

    for old, new, sys_name, lld in renames:
        propagate_rename(old, new, sys_name, lld,
                         manifest_rows, dry_run=args.dry_run)

    print("\n" + "="*60)
    if args.dry_run:
        print("Dry-run hoàn thành. Chạy lại không có --dry-run để apply.")
    else:
        print("Hoàn thành. Các file đã được cập nhật.")
        print("Chạy aggregate_atomic.py để refresh atomic_attributes.csv.")


if __name__ == "__main__":
    main()
