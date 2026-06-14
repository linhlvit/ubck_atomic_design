"""
transform_physical_names.py
============================
Bổ sung physical name và data type vào atomic_attributes.yaml:
  - atomic_table, atomic_column, data_type cho mỗi attribute entry

Nguồn dữ liệu:
  - system/rules/rule_transform_logical_name.csv  — dictionary logical -> physical
  - system/rules/rule_map_data_type.csv           — mapping data_domain -> data_type

Idempotent: nếu field đã tồn tại thì tính lại.

Cách dùng:
  python DataModel/working/Atomic/lld/scripts/transform_physical_names.py
  python DataModel/working/Atomic/lld/scripts/transform_physical_names.py --dry-run
  python DataModel/working/Atomic/lld/scripts/transform_physical_names.py --name "Fund Management Company Code"
"""

import argparse
import csv
import sys
import yaml
from pathlib import Path


# ---------------------------------------------------------------------------
# Custom YAML Dumper: double-quote string values, plain keys, native bool/null
# ---------------------------------------------------------------------------
class DQDumper(yaml.Dumper):
    pass

def _str_val_representer(dumper, data):
    return dumper.represent_scalar("tag:yaml.org,2002:str", data, style='"')

def _mapping_representer(dumper, data):
    pairs = []
    for k, v in data.items():
        key_node = dumper.represent_scalar("tag:yaml.org,2002:str", k, style=None)
        val_node = dumper.represent_data(v)
        pairs.append((key_node, val_node))
    return yaml.MappingNode("tag:yaml.org,2002:map", pairs)

DQDumper.add_representer(str, _str_val_representer)
DQDumper.add_representer(dict, _mapping_representer)

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
SCRIPT_DIR   = Path(__file__).resolve().parent
LLD_DIR      = SCRIPT_DIR.parent
PROJECT_ROOT = LLD_DIR.parent.parent.parent.parent

DICT_PATH       = PROJECT_ROOT / "system" / "rules" / "rule_transform_logical_name.csv"
DATA_TYPE_PATH  = PROJECT_ROOT / "system" / "rules" / "rule_map_data_type.csv"
ATOMIC_ATTRS    = LLD_DIR.parent / "aggregate" / "atomic_attributes.yaml"

COL_ENTITY_PHYS = "atomic_table"
COL_ATTR_PHYS   = "atomic_column"
COL_DATA_TYPE   = "data_type"


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
            tokens.append(text[i:j].replace("-", "_"))
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
# Patch lld_*.yaml — thêm physical_name + data_type vào từng attribute
# ---------------------------------------------------------------------------
def patch_lld_files(
    entries: list[tuple[str, str]],
    domain_map: dict[str, str],
    dry_run: bool,
) -> int:
    lld_files = sorted(LLD_DIR.glob("**/*.yaml"))
    lld_files = [f for f in lld_files if f.name.startswith("lld_")]
    total = 0
    for path in lld_files:
        data = yaml.safe_load(path.read_text(encoding="utf-8"))
        if (data or {}).get("schema_type") != "lld_source_table":
            continue
        changed = 0
        for a in (data or {}).get("attributes", []):
            attr   = a.get("attribute_name", "") or ""
            domain = a.get("data_domain", "") or ""
            if not a.get("physical_name"):
                a["physical_name"] = transform(attr, entries)
                changed += 1
            new_dt = resolve_data_type(domain, domain_map) or None
            if a.get("data_type") != new_dt:
                a["data_type"] = new_dt
                changed += 1
        if dry_run:
            if changed:
                print(f"[DRY-RUN] {path.relative_to(LLD_DIR.parent.parent.parent.parent)}: {changed} thay doi")
        else:
            with open(path, "w", encoding="utf-8") as f:
                yaml.dump(data, f, Dumper=DQDumper, allow_unicode=True, sort_keys=False, default_flow_style=False)
        total += changed
    return total


# ---------------------------------------------------------------------------
# Patch atomic_attributes.yaml
# ---------------------------------------------------------------------------
def patch_atomic_attributes(
    entries: list[tuple[str, str]],
    domain_map: dict[str, str],
    dry_run: bool,
) -> int:
    if not ATOMIC_ATTRS.exists():
        print(f"[SKIP] Khong tim thay {ATOMIC_ATTRS}", file=sys.stderr)
        return 0

    data = yaml.safe_load(ATOMIC_ATTRS.read_text(encoding="utf-8"))
    attrs = (data or {}).get("attributes", [])

    entity_cache: dict[str, str] = {}
    attr_cache:   dict[str, str] = {}

    for a in attrs:
        entity = a.get("atomic_entity", "") or ""
        attr   = a.get("atomic_attribute", "") or ""
        domain = a.get("data_domain", "") or ""

        if entity not in entity_cache:
            entity_cache[entity] = transform(entity, entries)
        if attr not in attr_cache:
            attr_cache[attr] = transform(attr, entries)

        a[COL_ENTITY_PHYS] = entity_cache[entity]
        a[COL_ATTR_PHYS]   = attr_cache[attr]
        a[COL_DATA_TYPE]   = resolve_data_type(domain, domain_map)

    if dry_run:
        print(yaml.dump(data, Dumper=DQDumper, allow_unicode=True, sort_keys=False, default_flow_style=False))
    else:
        with open(ATOMIC_ATTRS, "w", encoding="utf-8") as f:
            yaml.dump(data, f, Dumper=DQDumper, allow_unicode=True, sort_keys=False, default_flow_style=False)
        print(f"Da cap nhat: {ATOMIC_ATTRS}", file=sys.stderr)

    return len(attrs)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> None:
    parser = argparse.ArgumentParser(
        description="Bo sung atomic_table, atomic_column, data_type vao atomic_attributes.csv va attr_Classification_Value.csv"
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
    n1 = patch_lld_files(entries, domain_map, dry_run=args.dry_run)
    print(f"  lld_*.yaml: {n1} thay doi", file=sys.stderr)

    n2 = patch_atomic_attributes(entries, domain_map, dry_run=args.dry_run)
    print(f"  atomic_attributes.yaml: {n2} entries", file=sys.stderr)

    print("Hoan thanh.", file=sys.stderr)


if __name__ == "__main__":
    main()
