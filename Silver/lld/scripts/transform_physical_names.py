"""
transform_physical_names.py
============================
Bổ sung cột physical name và data type vào 2 file output LLD:
  - silver_attributes.csv : thêm silver_table (sau silver_entity),
                            silver_column và data_type (sau silver_attribute)
  - attr_Classification_Value.csv : thêm silver_column và data_type (sau attribute_name)

Nguồn dữ liệu:
  - system/rules/rule_transform_logical_name.csv  — dictionary logical -> physical
  - system/rules/rule_map_data_type.csv           — mapping data_domain -> data_type

Idempotent: nếu cột đã tồn tại thì tính lại, không duplicate.

Cách dùng:
  python transform_physical_names.py              # update cả 2 file
  python transform_physical_names.py --dry-run   # in ra stdout, không ghi file
  python transform_physical_names.py --name "Fund Management Company Code"
"""

import argparse
import csv
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
SCRIPT_DIR   = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent.parent

DICT_PATH       = PROJECT_ROOT / "system" / "rules" / "rule_transform_logical_name.csv"
DATA_TYPE_PATH  = PROJECT_ROOT / "system" / "rules" / "rule_map_data_type.csv"
SILVER_ATTRS    = PROJECT_ROOT / "Silver" / "lld" / "silver_attributes.csv"
CLASSVAL_ATTRS  = PROJECT_ROOT / "Silver" / "lld" / "attr_Classification_Value.csv"

# Tên cột mới trong silver_attributes.csv
COL_ENTITY_PHYS = "silver_table"
COL_ATTR_PHYS   = "silver_column"
COL_DATA_TYPE   = "data_type"

# Tên cột mới trong attr_Classification_Value.csv
CLASSVAL_ENTITY_NAME = "Classification Value"
COL_CV_ENTITY   = "silver_entity"
COL_CV_TABLE    = "silver_table"
COL_CV_PHYS     = "silver_column"


# ---------------------------------------------------------------------------
# Dictionary (logical name -> physical name)
# ---------------------------------------------------------------------------
def load_dict(path: Path) -> list[tuple[str, str]]:
    """Đọc CSV dictionary, trả về list (phrase_lower, abbreviation) dài nhất trước."""
    entries: list[tuple[str, str]] = []
    with open(path, encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            name = row["Name"].strip()
            abbr = row["Abbreviation"].strip()
            if name and abbr:
                entries.append((name.lower(), abbr))
    entries.sort(key=lambda x: (-len(x[0]), x[0]))
    return entries


# ---------------------------------------------------------------------------
# Data type rules (data_domain -> data_type)
# ---------------------------------------------------------------------------
def load_data_type_rules(path: Path) -> dict[str, str]:
    """Đọc rule_map_data_type.csv, trả về {data_domain_lower -> data_type}."""
    domain_map: dict[str, str] = {}
    with open(path, encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            domain = row["Data Domain"].strip()
            dt     = row["Data Type"].strip()
            if domain and dt:
                domain_map[domain.lower()] = dt
    return domain_map


def resolve_data_type(data_domain: str, domain_map: dict[str, str]) -> str:
    return domain_map.get(data_domain.lower(), "")


# ---------------------------------------------------------------------------
# Transform engine (logical name -> physical name)
# ---------------------------------------------------------------------------
def transform(logical_name: str, entries: list[tuple[str, str]]) -> str:
    """
    Chuyển logical_name -> physical_name (snake_case viết thường).
    Longest-match-first; match chỉ tại word boundary.
    Token không match -> giữ nguyên word gốc (lowercase).
    """
    text = logical_name.strip().lower()
    tokens: list[str] = []
    i = 0
    while i < len(text):
        if text[i] == " ":
            i += 1
            continue
        matched = False
        for phrase, abbr in entries:
            end = i + len(phrase)
            if text[i:end] == phrase and (end == len(text) or text[end] == " "):
                tokens.append(abbr.lower())
                i = end
                matched = True
                break
        if not matched:
            j = text.find(" ", i)
            j = j if j != -1 else len(text)
            tokens.append(text[i:j])
            i = j
    return "_".join(t for t in tokens if t)


# ---------------------------------------------------------------------------
# CSV helpers
# ---------------------------------------------------------------------------
def read_csv(path: Path) -> tuple[list[str], list[dict]]:
    with open(path, encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        fieldnames = list(reader.fieldnames or [])
        rows = list(reader)
    return fieldnames, rows


def write_csv(path: Path, fieldnames: list[str], rows: list[dict]) -> None:
    with open(path, "w", encoding="utf-8-sig", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def print_csv(fieldnames: list[str], rows: list[dict]) -> None:
    writer = csv.DictWriter(sys.stdout, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(rows)


def remove_cols(fieldnames: list[str], rows: list[dict], *cols: str) -> list[str]:
    """Xóa các cột khỏi fieldnames và rows (dùng để dọn tên cột cũ)."""
    for col in cols:
        if col in fieldnames:
            fieldnames = [f for f in fieldnames if f != col]
            for row in rows:
                row.pop(col, None)
    return fieldnames


def insert_after(fieldnames: list[str], after: str, new_col: str) -> list[str]:
    """Chèn new_col vào fieldnames ngay sau cột 'after'. Idempotent."""
    if new_col in fieldnames:
        return fieldnames
    idx = fieldnames.index(after)
    return fieldnames[: idx + 1] + [new_col] + fieldnames[idx + 1 :]


# ---------------------------------------------------------------------------
# Patch silver_attributes.csv
# ---------------------------------------------------------------------------
def patch_silver_attributes(
    entries: list[tuple[str, str]],
    domain_map: dict[str, str],
    dry_run: bool,
) -> int:
    if not SILVER_ATTRS.exists():
        print(f"[SKIP] Khong tim thay {SILVER_ATTRS}", file=sys.stderr)
        return 0

    fields, rows = read_csv(SILVER_ATTRS)

    # Dọn tên cột cũ
    fields = remove_cols(fields, rows, "silver_entity_physical_name", "silver_attribute_physical_name", COL_DATA_TYPE)

    # Chèn cột physical name
    fields = insert_after(fields, "silver_entity",    COL_ENTITY_PHYS)
    fields = insert_after(fields, "silver_attribute", COL_ATTR_PHYS)

    # Chèn data_type ngay sau silver_column
    fields = insert_after(fields, "data_domain", COL_DATA_TYPE)

    entity_cache: dict[str, str] = {}
    attr_cache:   dict[str, str] = {}

    for row in rows:
        entity = row.get("silver_entity", "")
        attr   = row.get("silver_attribute", "")
        domain = row.get("data_domain", "")

        if entity not in entity_cache:
            entity_cache[entity] = transform(entity, entries)
        if attr not in attr_cache:
            attr_cache[attr] = transform(attr, entries)

        row[COL_ENTITY_PHYS] = entity_cache[entity]
        row[COL_ATTR_PHYS]   = attr_cache[attr]
        row[COL_DATA_TYPE]   = resolve_data_type(domain, domain_map)

    if dry_run:
        print_csv(fields, rows)
    else:
        write_csv(SILVER_ATTRS, fields, rows)
        print(f"Da cap nhat: {SILVER_ATTRS}", file=sys.stderr)

    return len(rows)


# ---------------------------------------------------------------------------
# Patch attr_Classification_Value.csv
# ---------------------------------------------------------------------------
def patch_classval(
    entries: list[tuple[str, str]],
    domain_map: dict[str, str],
    dry_run: bool,
) -> int:
    if not CLASSVAL_ATTRS.exists():
        print(f"[SKIP] Khong tim thay {CLASSVAL_ATTRS}", file=sys.stderr)
        return 0

    fields, rows = read_csv(CLASSVAL_ATTRS)

    # Dọn tên cột cũ
    fields = remove_cols(fields, rows, "physical_name", COL_DATA_TYPE)

    # Thêm silver_entity + silver_table trước attribute_name (nếu chưa có)
    if COL_CV_ENTITY not in fields:
        fields = [COL_CV_ENTITY, COL_CV_TABLE] + fields

    fields = insert_after(fields, "attribute_name", COL_CV_PHYS)
    fields = insert_after(fields, "data_domain", COL_DATA_TYPE)

    cv_table = transform(CLASSVAL_ENTITY_NAME, entries)
    for row in rows:
        attr   = row.get("attribute_name", "")
        domain = row.get("data_domain", "")
        row[COL_CV_ENTITY] = CLASSVAL_ENTITY_NAME
        row[COL_CV_TABLE]  = cv_table
        row[COL_CV_PHYS]   = transform(attr, entries)
        row[COL_DATA_TYPE] = resolve_data_type(domain, domain_map)

    if dry_run:
        print_csv(fields, rows)
    else:
        write_csv(CLASSVAL_ATTRS, fields, rows)
        print(f"Da cap nhat: {CLASSVAL_ATTRS}", file=sys.stderr)

    return len(rows)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> None:
    parser = argparse.ArgumentParser(
        description="Bo sung silver_table, silver_column, data_type vao silver_attributes.csv va attr_Classification_Value.csv"
    )
    parser.add_argument("--dry-run", action="store_true", help="In ra stdout, khong ghi file")
    parser.add_argument("--name", metavar="LOGICAL_NAME", help="Tra 1 ten cu the (in ket qua ra stdout)")
    args = parser.parse_args()

    print("Doc dictionary...", file=sys.stderr)
    entries = load_dict(DICT_PATH)
    print(f"  {len(entries)} entries", file=sys.stderr)

    print("Doc data type rules...", file=sys.stderr)
    domain_map = load_data_type_rules(DATA_TYPE_PATH)
    print(f"  {len(domain_map)} domain rules", file=sys.stderr)

    # --- Chế độ tra 1 tên ---
    if args.name:
        result = transform(args.name, entries)
        print(f"{args.name}  ->  {result}")
        return

    # --- Chế độ batch ---
    n1 = patch_silver_attributes(entries, domain_map, dry_run=args.dry_run)
    print(f"  silver_attributes: {n1} dong", file=sys.stderr)

    n2 = patch_classval(entries, domain_map, dry_run=args.dry_run)
    print(f"  attr_Classification_Value: {n2} dong", file=sys.stderr)

    print("Hoan thanh.", file=sys.stderr)


if __name__ == "__main__":
    main()
