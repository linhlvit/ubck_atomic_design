"""
transform_physical_names.py
============================
Bổ sung physical name và data type vào atomic_attributes.yaml:
  - atomic_table, atomic_column, data_type cho mỗi attribute entry
Và patch entity_physical_name + physical_name (per-attribute) vào từng lld_*.yaml.

Thuật toán (xem `.claude/skills/atomic-lld-design/SKILL.md` mục
"QUY TẮC ĐẶT physical_name"):
  - TABLE (entity):  entity_physical_name = abbreviate_domain_prefix(domain_prefix) + "_" + full_words(bcv_term)
    abbreviate_domain_prefix() chỉ viết tắt cụm từ có trong
    system/rules/rule_domain_prefix_abbreviations.csv (longest-match-first, curated list, KHÔNG
    lấy initials mù quáng của mọi từ) — cụm không có trong list giữ nguyên full word.
    Domain Prefix + entity_physical_name đã chuẩn hóa lấy từ
    DataModel/working/Atomic/hld/atomic_entities.yaml (nguồn chuẩn duy nhất — script
    KHÔNG tự transform lại tên entity, chỉ lookup).
  - COLUMN (attribute): attribute logical name luôn bắt đầu bằng đúng tên đầy đủ 1 atomic_entity
    đã đăng ký (pattern "[Entity] Id"/"[Entity] Code"/"[Entity] Name"...). Nếu khớp, thay prefix đó
    bằng entity_physical_name của entity đó (đúng giá trị dùng cho table — tái sử dụng rule A thay
    vì spelled-out lại), rồi mới nối phần từ còn lại bằng "_", viết thường, trừ từ có trong
    system/rules/rule_physical_name_exceptions.csv (longest-match-first). Chỉ entity nào thực sự bị
    viết tắt (entity_physical_name khác full_words(atomic_entity)) mới được đưa vào dictionary này —
    entity "root" (VD "Securities Practitioner") vẫn giữ full word như cũ.

Idempotent: luôn recompute (không còn "chỉ điền khi trống").

Cách dùng:
  python DataModel/working/Atomic/lld/scripts/transform_physical_names.py
  python DataModel/working/Atomic/lld/scripts/transform_physical_names.py --dry-run
  python DataModel/working/Atomic/lld/scripts/transform_physical_names.py --name "Fund Management Company Code"
  python DataModel/working/Atomic/lld/scripts/transform_physical_names.py --table "Securities Company|Securities Company Practitioner"
"""

import argparse
import csv
import io
import re
import sys
import yaml
from pathlib import Path

# Fix encoding tren Windows terminal (console mac dinh cp1252 khong encode duoc Unicode VN)
if sys.stdout.encoding and sys.stdout.encoding.lower() not in ("utf-8", "utf-8-sig"):
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
if sys.stderr.encoding and sys.stderr.encoding.lower() not in ("utf-8", "utf-8-sig"):
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")


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

EXCEPTIONS_PATH  = PROJECT_ROOT / "system" / "rules" / "rule_physical_name_exceptions.csv"
DOMAIN_PREFIX_ABBR_PATH = PROJECT_ROOT / "system" / "rules" / "rule_domain_prefix_abbreviations.csv"
DATA_TYPE_PATH   = PROJECT_ROOT / "system" / "rules" / "rule_map_data_type.csv"
ATOMIC_ATTRS    = LLD_DIR.parent / "aggregate" / "atomic_attributes.yaml"
ATOMIC_ENTITIES = LLD_DIR.parent / "hld" / "atomic_entities.yaml"
ENTITIES_DIR    = LLD_DIR / "entities"

COL_ENTITY_PHYS = "atomic_table"
COL_ATTR_PHYS   = "atomic_column"
COL_DATA_TYPE   = "data_type"


# ---------------------------------------------------------------------------
# Dictionary (logical name -> physical name) — dùng cho COLUMN name (quy tắc B)
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
# Sanitize: chỉ giữ [a-z0-9_] — loại bỏ dấu ngoặc, dấu câu... không hợp lệ trong
# physical name (VD "Number (Secondary)" -> "number_secondary").
# ---------------------------------------------------------------------------
def _sanitize(text: str) -> str:
    text = re.sub(r"[^a-z0-9_]+", "_", text.lower())
    text = re.sub(r"_+", "_", text)
    return text.strip("_")


# ---------------------------------------------------------------------------
# Longest-match-first tokenizer dùng chung — cụm có trong dictionary -> viết
# tắt, cụm không có -> giữ nguyên word gốc đầy đủ (lowercase). Dùng cho cả
# COLUMN name (quy tắc B, exceptions CSV) và TABLE domain prefix (quy tắc A,
# domain-prefix-abbreviations CSV).
# ---------------------------------------------------------------------------
def apply_dictionary(text: str, dictionary: list[tuple[str, str]]) -> str:
    text = text.strip().lower()
    tokens: list[str] = []
    i = 0
    while i < len(text):
        if text[i] == " ":
            i += 1
            continue
        matched = False
        for phrase, abbr in dictionary:
            end = i + len(phrase)
            if text[i:end] == phrase and (end == len(text) or text[end] == " "):
                tokens.append(abbr.lower())
                i = end
                matched = True
                break
        if not matched:
            j = text.find(" ", i)
            j = j if j != -1 else len(text)
            tokens.append(_sanitize(text[i:j]))
            i = j
    return _sanitize("_".join(t for t in tokens if t))


# ---------------------------------------------------------------------------
# COLUMN name transform (quy tắc B)
# ---------------------------------------------------------------------------
def transform_column_name(logical_name: str, exceptions: list[tuple[str, str]]) -> str:
    """Chuyển logical_name -> physical_name (snake_case viết thường)."""
    return apply_dictionary(logical_name, exceptions)


# ---------------------------------------------------------------------------
# TABLE name transform (quy tắc A) — abbreviate_domain_prefix(domain_prefix) + "_" + full_words(bcv_term)
# ---------------------------------------------------------------------------
_domain_prefix_dict_cache: list[tuple[str, str]] | None = None


def _domain_prefix_dict() -> list[tuple[str, str]]:
    """Lazy-load + cache system/rules/rule_domain_prefix_abbreviations.csv."""
    global _domain_prefix_dict_cache
    if _domain_prefix_dict_cache is None:
        _domain_prefix_dict_cache = load_dict(DOMAIN_PREFIX_ABBR_PATH)
    return _domain_prefix_dict_cache


def abbreviate_domain_prefix(domain_prefix: str) -> str:
    """
    Viết tắt Domain Prefix theo curated list (longest-match-first).
    Cụm KHÔNG có trong system/rules/rule_domain_prefix_abbreviations.csv -> giữ
    nguyên full word (KHÔNG lấy initials mù quáng của mọi từ).
    """
    return apply_dictionary(domain_prefix, _domain_prefix_dict())


def full_words(text: str) -> str:
    return _sanitize("_".join(text.strip().lower().split()))


def transform_table_name(domain_prefix: str, atomic_entity: str) -> str:
    dp = (domain_prefix or "").strip()
    entity = atomic_entity.strip()
    if not dp:
        return full_words(entity)
    if not entity.lower().startswith(dp.lower()):
        raise ValueError(
            f"domain_prefix '{dp}' khong phai leading substring cua atomic_entity '{entity}'"
        )
    bcv_term = entity[len(dp):].strip()
    if not bcv_term:
        return full_words(dp)
    return f"{abbreviate_domain_prefix(dp)}_{full_words(bcv_term)}"


# ---------------------------------------------------------------------------
# atomic_entities.yaml — nguồn chuẩn domain_prefix / entity_physical_name
# ---------------------------------------------------------------------------
def load_entity_registry(path: Path) -> dict[str, dict]:
    """Trả về {atomic_entity: {"domain_prefix":..., "entity_physical_name":...}}."""
    if not path.exists():
        return {}
    data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
    registry: dict[str, dict] = {}
    for e in data.get("entities", []):
        name = e.get("atomic_entity")
        if name:
            registry[name] = {
                "domain_prefix": e.get("domain_prefix", ""),
                "entity_physical_name": e.get("entity_physical_name", ""),
            }
    return registry


def resolve_table_name(atomic_entity: str, registry: dict[str, dict]) -> tuple[str, bool]:
    """
    Trả về (entity_physical_name, from_registry).
    Ưu tiên entity_physical_name có sẵn trong atomic_entities.yaml (nguồn chuẩn, không tự tính lại).
    Nếu entity chưa đăng ký hoặc thiếu entity_physical_name -> tự tính tạm với domain_prefix rỗng,
    from_registry=False để caller in WARN.
    """
    entry = registry.get(atomic_entity)
    if entry and entry.get("entity_physical_name"):
        return entry["entity_physical_name"], True
    domain_prefix = entry.get("domain_prefix", "") if entry else ""
    return transform_table_name(domain_prefix, atomic_entity), False


def build_entity_prefix_dict(registry: dict[str, dict]) -> list[tuple[str, str]]:
    """
    Dictionary bo sung cho rule B (COLUMN name): {atomic_entity (lower) -> entity_physical_name},
    chi cho entity thuc su bi viet tat (entity_physical_name != full_words(atomic_entity)).
    Attribute logical name luon bat dau bang day du ten mot Atomic Entity da dang ky (pattern
    "[Entity] Id" + "[Entity] Code" bat buoc o Buoc 3c) — khi khop, apply_dictionary() se thay
    prefix do bang entity_physical_name (tai su dung rule A) truoc khi ap exceptions cho phan
    con lai. Entity "root" (entity_physical_name da la full word) khong dua vao day de tranh
    no-op/nhieu.
    """
    entries: list[tuple[str, str]] = []
    for name, info in registry.items():
        phys = info.get("entity_physical_name", "")
        if phys and phys != full_words(name):
            entries.append((name.lower(), phys))
    return entries


def merge_column_dict(
    exceptions: list[tuple[str, str]], registry: dict[str, dict]
) -> list[tuple[str, str]]:
    """Hop nhat exceptions (rule B) + entity-prefix dict, sap xep longest-match-first."""
    merged = exceptions + build_entity_prefix_dict(registry)
    merged.sort(key=lambda x: (-len(x[0]), x[0]))
    return merged


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
# Patch lld_*.yaml — thêm entity_physical_name + physical_name + data_type
# ---------------------------------------------------------------------------
def patch_lld_files(
    exceptions: list[tuple[str, str]],
    domain_map: dict[str, str],
    registry: dict[str, dict],
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

        meta = (data or {}).get("metadata", {}) or {}
        entity = meta.get("atomic_entity", "") or ""
        if entity:
            new_table_name, from_registry = resolve_table_name(entity, registry)
            if not from_registry:
                print(
                    f"  [WARN] '{entity}' chua co entity_physical_name trong atomic_entities.yaml"
                    f" — tam tinh '{new_table_name}' (domain_prefix rong). Dang ky lai sau khi review.",
                    file=sys.stderr,
                )
            if meta.get("entity_physical_name") != new_table_name:
                meta["entity_physical_name"] = new_table_name
                changed += 1

        for a in (data or {}).get("attributes", []):
            attr   = a.get("attribute_name", "") or ""
            domain = a.get("data_domain", "") or ""
            new_physical = transform_column_name(attr, exceptions)
            if a.get("physical_name") != new_physical:
                a["physical_name"] = new_physical
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
# Patch entity_*.yaml — normalize double-quote format
# ---------------------------------------------------------------------------
def patch_entity_files(dry_run: bool) -> int:
    entity_files = sorted(ENTITIES_DIR.glob("entity_*.yaml"))
    total = 0
    for path in entity_files:
        data = yaml.safe_load(path.read_text(encoding="utf-8"))
        if not data:
            continue
        if dry_run:
            print(f"[DRY-RUN] {path.relative_to(PROJECT_ROOT)}: normalize")
        else:
            with open(path, "w", encoding="utf-8") as f:
                yaml.dump(data, f, Dumper=DQDumper, allow_unicode=True,
                          sort_keys=False, default_flow_style=False)
        total += 1
    return total


# ---------------------------------------------------------------------------
# Patch atomic_attributes.yaml
# ---------------------------------------------------------------------------
def patch_atomic_attributes(
    exceptions: list[tuple[str, str]],
    domain_map: dict[str, str],
    registry: dict[str, dict],
    dry_run: bool,
) -> int:
    if not ATOMIC_ATTRS.exists():
        print(f"[SKIP] Khong tim thay {ATOMIC_ATTRS}", file=sys.stderr)
        return 0

    data = yaml.safe_load(ATOMIC_ATTRS.read_text(encoding="utf-8"))
    attrs = (data or {}).get("attributes", [])

    entity_cache: dict[str, str] = {}
    attr_cache:   dict[str, str] = {}
    warned: set[str] = set()

    for a in attrs:
        entity = a.get("atomic_entity", "") or ""
        attr   = a.get("atomic_attribute", "") or ""
        domain = a.get("data_domain", "") or ""

        if entity not in entity_cache:
            table_name, from_registry = resolve_table_name(entity, registry)
            if not from_registry and entity not in warned:
                print(
                    f"  [WARN] '{entity}' chua co entity_physical_name trong atomic_entities.yaml"
                    f" — tam tinh '{table_name}' (domain_prefix rong).",
                    file=sys.stderr,
                )
                warned.add(entity)
            entity_cache[entity] = table_name
        if attr not in attr_cache:
            attr_cache[attr] = transform_column_name(attr, exceptions)

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
        description="Tinh entity_physical_name/physical_name/data_type cho lld_*.yaml va "
                     "atomic_table/atomic_column/data_type cho atomic_attributes.yaml"
    )
    parser.add_argument("--dry-run", action="store_true", help="In ra stdout, khong ghi file")
    parser.add_argument("--name", metavar="LOGICAL_NAME", help="Tra 1 ten column cu the (in ket qua ra stdout)")
    parser.add_argument(
        "--table", metavar="DOMAIN_PREFIX|ATOMIC_ENTITY",
        help="Tra 1 ten table cu the, dang 'Domain Prefix|Atomic Entity' (domain prefix co the de rong)",
    )
    args = parser.parse_args()

    print("Doc bang ngoai le column name...", file=sys.stderr)
    exceptions = load_dict(EXCEPTIONS_PATH)
    print(f"  {len(exceptions)} entries", file=sys.stderr)

    print("Doc curated list domain prefix abbreviation...", file=sys.stderr)
    print(f"  {len(_domain_prefix_dict())} entries", file=sys.stderr)

    print("Doc data type rules...", file=sys.stderr)
    domain_map = load_data_type_rules(DATA_TYPE_PATH)
    print(f"  {len(domain_map)} domain rules", file=sys.stderr)

    print("Doc atomic_entities.yaml (domain_prefix/entity_physical_name registry)...", file=sys.stderr)
    registry = load_entity_registry(ATOMIC_ENTITIES)
    print(f"  {len(registry)} entities dang ky", file=sys.stderr)

    exceptions = merge_column_dict(exceptions, registry)
    print(f"  {len(exceptions)} entries sau khi merge entity-prefix dictionary", file=sys.stderr)

    # --- Che do tra 1 ten column ---
    if args.name:
        result = transform_column_name(args.name, exceptions)
        print(f"{args.name}  ->  {result}")
        return

    # --- Che do tra 1 ten table ---
    if args.table:
        domain_prefix, atomic_entity = args.table.split("|", 1)
        result = transform_table_name(domain_prefix, atomic_entity)
        print(f"[{domain_prefix}] + [{atomic_entity}]  ->  {result}")
        return

    # --- Che do batch ---
    n1 = patch_lld_files(exceptions, domain_map, registry, dry_run=args.dry_run)
    print(f"  lld_*.yaml: {n1} thay doi", file=sys.stderr)

    n_entity = patch_entity_files(dry_run=args.dry_run)
    print(f"  entity_*.yaml: {n_entity} files normalized", file=sys.stderr)

    n2 = patch_atomic_attributes(exceptions, domain_map, registry, dry_run=args.dry_run)
    print(f"  atomic_attributes.yaml: {n2} entries", file=sys.stderr)

    print("Hoan thanh.", file=sys.stderr)


if __name__ == "__main__":
    main()
