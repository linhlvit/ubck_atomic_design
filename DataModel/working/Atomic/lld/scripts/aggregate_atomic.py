"""
aggregate_atomic.py
===================
Tổng hợp atomic_entities.yaml và atomic_attributes.yaml từ các LLD files.

Nguồn dữ liệu:
  - DataModel/working/Atomic/lld/manifest.yaml
  - DataModel/working/Atomic/lld/{SOURCE}/lld_*.yaml
  - atomic_entities.yaml   : source of truth entity-level
  - {SOURCE}_HLD_Overview.md: parse **Description:**

Output:
  - atomic_attributes.yaml : mapping detail — 1 dòng per (entity × attribute × source × context)

Grain của atomic_attributes.yaml:
  1 entry = 1 (atomic_entity, atomic_attribute, source_system, source_table,
               classification_context)

classification_context format (output):
  Field Name = 'value' — mỗi condition cách nhau " | "

Cách dùng:
  python aggregate_atomic.py                   # rebuild toàn bộ
  python aggregate_atomic.py --dry-run         # in ra stdout, không ghi file
  python aggregate_atomic.py --skip-entities   # bỏ qua rebuild atomic_entities.yaml
  python aggregate_atomic.py --skip-attributes # bỏ qua rebuild atomic_attributes.yaml
"""

import csv
import re
import argparse
import sys
import io
import yaml
from pathlib import Path
from collections import defaultdict, OrderedDict
from typing import Optional


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

# Fix encoding trên Windows terminal
if sys.stdout.encoding and sys.stdout.encoding.lower() not in ("utf-8", "utf-8-sig"):
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
if sys.stderr.encoding and sys.stderr.encoding.lower() not in ("utf-8", "utf-8-sig"):
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
SCRIPT_DIR    = Path(__file__).parent
LLD_DIR       = SCRIPT_DIR.parent                                 # DataModel/working/Atomic/lld/
ROOT          = LLD_DIR.parent.parent.parent.parent               # project root
HLD_DIR       = ROOT / "DataModel" / "working" / "Atomic" / "hld"
YAML_MANIFEST = LLD_DIR / "manifest.yaml"
OUT_ATTRS     = LLD_DIR.parent / "aggregate" / "atomic_attributes.yaml"
OUT_ENTITIES  = HLD_DIR / "atomic_entities.yaml"

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
SHARED_ENTITIES = {
    "Involved Party Postal Address",
    "Involved Party Electronic Address",
    "Involved Party Alternative Identification",
}

ADDR_SCHEMES = ("IP_ADDR_TYPE=", "IP_ALT_ID_TYPE=", "IP_ELEC_ADDR_TYPE=")

SCHEME_TO_FIELD = {
    "SOURCE_SYSTEM":     "Source System Code",
    "IP_ALT_ID_TYPE":    "Identification Type Code",
    "IP_ADDR_TYPE":      "Address Type Code",
    "IP_ELEC_ADDR_TYPE": "Electronic Address Type Code",
}

BCO_ORDER = [
    "Arrangement",
    "Business Activity",
    "Communication",
    "Condition",
    "Documentation",
    "Event",
    "Involved Party",
    "Location",
    "Transaction",
]

ATTR_FIELDS = [
    "bcv_core_object", "atomic_entity",
    "atomic_attribute", "description", "data_domain",
    "nullable", "is_primary_key",
    "source_system", "source_table", "source_column",
    "comment", "classification_context", "etl_derived_value",
]

ENTITY_FIELDS = [
    "bcv_core_object", "bcv_concept", "atomic_entity",
    "table_type", "domain_prefix", "entity_physical_name",
    "status", "description", "source_table",
]


# ---------------------------------------------------------------------------
# Parse **Description:** và **Domain Prefix:** từ section "## Entities" trong HLD Overview file
# Source of truth: {SOURCE}_HLD_Overview.md → ## Entities → ### N. {Entity Name}
# Returns: dict { atomic_entity_name → {"description":..., "domain_prefix":...} }
# ---------------------------------------------------------------------------
def parse_hld_descriptions(source_system: str) -> dict[str, dict]:
    result: dict[str, dict] = {}
    overview_path = HLD_DIR / f"{source_system}_HLD_Overview.md"
    if not overview_path.exists():
        return result

    text = overview_path.read_text(encoding="utf-8")

    # Tìm section "## Entities" (từ heading đến heading ## tiếp theo hoặc EOF)
    section_match = re.search(
        r"^##\s+Entities\s*\n(.+?)(?=^##\s|\Z)",
        text, re.MULTILINE | re.DOTALL
    )
    if not section_match:
        return result

    section = section_match.group(1)

    # Tìm tất cả entity headings trong section: "### N. Entity Name"
    for m in re.finditer(r"^###\s+\d+\.\s+(.+)$", section, re.MULTILINE):
        entity_name = m.group(1).strip()
        rest = section[m.end():]
        window = rest[:500]
        desc_match = re.search(r"^\*\*Description:\*\*\s*(.+)$", window, re.MULTILINE)
        prefix_match = re.search(r"^\*\*Domain Prefix:\*\*\s*(.+)$", window, re.MULTILINE)
        if entity_name in result:
            continue
        meta = {}
        if desc_match:
            meta["description"] = desc_match.group(1).strip()
        if prefix_match:
            dp = prefix_match.group(1).strip()
            meta["domain_prefix"] = "" if dp.lower() in ("(none)", "none", "rỗng") else dp
        if meta:
            result[entity_name] = meta

    return result


def bco_sort_key(bco: str) -> int:
    try:
        return BCO_ORDER.index(bco)
    except ValueError:
        return len(BCO_ORDER)


# ---------------------------------------------------------------------------
# IO helpers
# ---------------------------------------------------------------------------
def load_atomic_entities() -> dict[str, dict]:
    result = {}
    if not OUT_ENTITIES.exists():
        return result
    data = yaml.safe_load(OUT_ENTITIES.read_text(encoding="utf-8")) or {}
    for row in data.get("entities", []):
        result[row["atomic_entity"]] = row
    return result


def load_yaml_attr_rows(path: Path) -> list[dict]:
    """Đọc lld_*.yaml → trả về list dict cùng format với CSV attr rows."""
    data = yaml.safe_load(path.read_text(encoding="utf-8"))
    rows = []
    for a in (data or {}).get("attributes", []):
        src_cols = a.get("source_columns") or []
        if isinstance(src_cols, list):
            source_columns = ", ".join(c for c in src_cols if c)
        else:
            source_columns = str(src_cols) if src_cols else ""
        rows.append({
            "attribute_name":         a.get("attribute_name", ""),
            "description":            a.get("description", "") or "",
            "data_domain":            a.get("data_domain", ""),
            "nullable":               str(a.get("nullable", True)).lower(),
            "is_primary_key":         str(a.get("is_primary_key", False)).lower(),
            "status":                 a.get("status", "draft"),
            "source_columns":         source_columns,
            "comment":                a.get("comment", "") or "",
            "classification_context": a.get("classification_context", "") or "",
            "etl_derived_value":      a.get("etl_derived_value", "") or "",
        })
    return rows


def load_manifest(filter_source=None, filter_group=None) -> list[dict]:
    if not YAML_MANIFEST.exists():
        print(f"  [ERROR] Không tìm thấy {YAML_MANIFEST}", file=sys.stderr)
        sys.exit(1)
    data = yaml.safe_load(YAML_MANIFEST.read_text(encoding="utf-8"))
    rows = []
    for e in (data or {}).get("entries", []):
        lld_file = e.get("lld_file", "").strip()
        group    = e.get("group", "").strip()
        if not lld_file or group == "pending":
            continue
        rows.append({
            "source_system": e.get("source_system", "").strip(),
            "source_table":  e.get("source_table", "").strip(),
            "atomic_entity": e.get("atomic_entity", "").strip(),
            "group":         group,
            "lld_file":      lld_file,
        })
    return [
        r for r in rows
        if (not filter_source or r["source_system"] == filter_source)
        and (not filter_group or r["group"] == filter_group)
    ]


_warned_missing: set = set()

def load_attr_file(source_system: str, lld_file: str) -> list[dict]:
    yaml_path = LLD_DIR / lld_file
    if yaml_path.exists():
        return load_yaml_attr_rows(yaml_path)
    # Try with explicit source_system prefix (lld_file may omit it)
    yaml_path2 = LLD_DIR / source_system / Path(lld_file).name
    if yaml_path2.exists():
        return load_yaml_attr_rows(yaml_path2)
    if yaml_path not in _warned_missing:
        print(f"  [WARN] File không tồn tại: {yaml_path}", file=sys.stderr)
        _warned_missing.add(yaml_path)
    return []


def write_csv(path: Path, fields: list[str], rows: list[dict], dry_run: bool = False):
    if dry_run:
        out = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", newline="")
        writer = csv.DictWriter(out, fieldnames=fields, lineterminator="\n", extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)
        out.flush()
    else:
        with open(path, "w", encoding="utf-8-sig", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=fields, lineterminator="\n", extrasaction="ignore")
            writer.writeheader()
            writer.writerows(rows)
        print(f"  Ghi: {path}", file=sys.stderr)


def write_entities_yaml(path: Path, rows: list[dict], dry_run: bool = False):
    doc = {
        "schema_type":    "atomic_entities",
        "schema_version": "1.0",
        "entities":       [dict(r) for r in rows],
    }
    if dry_run:
        yaml.dump(doc, sys.stdout, Dumper=DQDumper, allow_unicode=True,
                  sort_keys=False, default_flow_style=False)
    else:
        with open(path, "w", encoding="utf-8") as f:
            yaml.dump(doc, f, Dumper=DQDumper, allow_unicode=True,
                      sort_keys=False, default_flow_style=False)
        print(f"  Ghi: {path}", file=sys.stderr)


def write_attrs_yaml(path: Path, rows: list[dict], dry_run: bool = False):
    """Ghi atomic_attributes.yaml từ list of flat dicts."""
    # Chuẩn hóa: boolean-like strings → native bool/null
    def _coerce(v):
        if v is None or v == "":
            return None
        if isinstance(v, str):
            if v.lower() == "true":
                return True
            if v.lower() == "false":
                return False
        return v

    entries = []
    for r in rows:
        entries.append({f: _coerce(r.get(f)) for f in ATTR_FIELDS})

    doc = {"schema_type": "atomic_attributes", "schema_version": "1.0", "attributes": entries}

    if dry_run:
        print(yaml.dump(doc, Dumper=DQDumper, allow_unicode=True, sort_keys=False, default_flow_style=False))
    else:
        with open(path, "w", encoding="utf-8") as f:
            yaml.dump(doc, f, Dumper=DQDumper, allow_unicode=True, sort_keys=False, default_flow_style=False)
        print(f"  Ghi: {path}", file=sys.stderr)


# ---------------------------------------------------------------------------
# Sort helpers
# ---------------------------------------------------------------------------
def sort_entity_groups(entity_groups: dict) -> list:
    non_shared = sorted(
        [k for k in entity_groups if k[1] not in SHARED_ENTITIES],
        key=lambda k: (bco_sort_key(k[0]), k[1])
    )
    shared = sorted(
        [k for k in entity_groups if k[1] in SHARED_ENTITIES],
        key=lambda k: (bco_sort_key(k[0]), k[1])
    )
    result = []
    for key in non_shared + shared:
        result.extend(entity_groups[key])
    return result


# ---------------------------------------------------------------------------
# Context key helpers
# ---------------------------------------------------------------------------
def _extract_addr_part(ctx_str: str) -> Optional[str]:
    """Lấy phần addr_type từ classification_context (không phải SOURCE_SYSTEM).
    Đọc format cũ trong attr_*.csv: IP_ADDR_TYPE=X, IP_ALT_ID_TYPE=X, IP_ELEC_ADDR_TYPE=X
    """
    for part in ctx_str.split("|"):
        part = part.strip()
        if any(part.startswith(s) for s in ADDR_SCHEMES):
            return part
    return None


def build_ctx_string(source_system: str, source_table: str, addr_part: Optional[str]) -> str:
    """Build classification_context string theo format: Field Name = 'value' | ...

    Ví dụ:
      source_system=FIMS, source_table=AUTHOANNOUNCE, addr_part=None
        → "Source System Code = 'FIMS_AUTHOANNOUNCE'"
      source_system=FIMS, source_table=FUNDCOMPANY, addr_part="IP_ADDR_TYPE=HEAD_OFFICE"
        → "Source System Code = 'FIMS_FUNDCOMPANY' | Address Type Code = 'HEAD_OFFICE'"
    """
    src_val = f"{source_system}_{source_table}"
    src_ctx = f"Source System Code = '{src_val}'"
    if addr_part:
        scheme, _, value = addr_part.partition("=")
        field = SCHEME_TO_FIELD.get(scheme, scheme)
        return src_ctx + " | " + f"{field} = '{value}'"
    return src_ctx


def get_distinct_context_keys(attr_rows: list[dict], source_system: str, source_table: str) -> list[str]:
    """Trả về list context strings riêng biệt có trong attr file.

    Chỉ tạo context từ các dòng CÓ addr_type (IP_ADDR_TYPE=, IP_ALT_ID_TYPE=, ...).
    Nếu không có dòng nào có addr_type → trả về 1 context bare (SOURCE_SYSTEM only).
    Dòng không có addr_type = dùng chung mọi context, không tạo context riêng.
    """
    addr_types: set = set()
    for ar in attr_rows:
        ctx = (ar.get("classification_context") or "").strip()
        addr = _extract_addr_part(ctx)
        if addr:
            addr_types.add(addr)

    if not addr_types:
        return [build_ctx_string(source_system, source_table, None)]

    return [build_ctx_string(source_system, source_table, addr) for addr in sorted(addr_types)]


def find_attr_in_ctx(attr_rows: list[dict], attr_name: str, ctx_key: str,
                     source_system: str, source_table: str) -> Optional[dict]:
    """Tìm attr row khớp tên + context key. Trả về None nếu không tìm thấy.

    Ưu tiên: dòng có addr_type khớp chính xác trước,
    rồi đến dòng không có addr_type (fallback — dùng chung mọi context).
    """
    fallback = None

    for ar in attr_rows:
        if ar["attribute_name"] != attr_name:
            continue
        raw_ctx   = (ar.get("classification_context") or "").strip()
        addr_part = _extract_addr_part(raw_ctx)
        ar_ctx    = build_ctx_string(source_system, source_table, addr_part)

        if addr_part:
            if ar_ctx == ctx_key:
                return ar  # exact match
        elif fallback is None:
            fallback = ar  # candidate fallback cho bất kỳ context nào

    return fallback


# ---------------------------------------------------------------------------
# Build master attribute list cho 1 entity từ tất cả sources trong manifest
# Returns: OrderedDict { (attr_name, addr_part_or_None) → best metadata row }
#
# Dùng (attr_name, addr_part) làm key thay vì chỉ attr_name vì cùng tên attr
# có thể xuất hiện nhiều lần trong 1 file với các context khác nhau
# (VD: Identification Number cho BUSINESS_LICENSE và OPERATING_LICENSE).
# "Best" = description dài nhất; nullable conservative (true wins)
# ---------------------------------------------------------------------------
def build_master_attrs(entity_manifest_rows: list) -> OrderedDict:
    master: OrderedDict[tuple, dict] = OrderedDict()

    for m in entity_manifest_rows:
        attr_rows = load_attr_file(m["source_system"], m["lld_file"])
        for ar in attr_rows:
            name     = ar["attribute_name"]
            raw_ctx  = (ar.get("classification_context") or "").strip()
            addr_part = _extract_addr_part(raw_ctx)
            key = (name, addr_part)

            if key not in master:
                master[key] = dict(ar)
            else:
                existing = master[key]
                # description: chọn dài hơn
                if len(ar.get("description", "")) > len(existing.get("description", "")):
                    existing["description"] = ar["description"]
                # nullable: conservative
                if ar.get("nullable", "false").strip().lower() == "true":
                    existing["nullable"] = "true"
                # comment: ghép nếu mới
                new_c = ar.get("comment", "").strip()
                old_c = existing.get("comment", "").strip()
                if new_c and new_c not in old_c:
                    existing["comment"] = (old_c + " // " + new_c).strip(" /")

    # Dedup: nếu đã có (attr_name, addr_part) với addr_part != None,
    # xóa key (attr_name, None) tương ứng để tránh emit duplicate row
    # (xảy ra khi shared entity được gộp từ nhiều source, 1 source dùng context
    # cụ thể còn source khác để context trống cho cùng tên attr).
    attr_names_with_addr = {name for (name, addr) in master if addr is not None}
    keys_to_remove = [(name, None) for (name, addr) in list(master) if addr is None and name in attr_names_with_addr]
    for k in keys_to_remove:
        master.pop(k, None)

    return master


# ---------------------------------------------------------------------------
# Build atomic_attributes rows
# Grain: 1 dòng = 1 (atomic_entity × atomic_attribute × source × context)
# Master attribute list per entity lấy từ union tất cả attr files (qua manifest)
# ---------------------------------------------------------------------------
def build_attributes(manifest_rows: list[dict],
                     entity_lookup: dict[str, dict]) -> list[dict]:
    # Group manifest theo entity
    entity_manifest: dict[str, list[dict]] = defaultdict(list)
    for m in manifest_rows:
        entity_manifest[m["atomic_entity"]].append(m)

    # Precompute master attr list per entity (1 lần, dùng lại cho mọi source)
    entity_masters: dict[str, OrderedDict] = {}
    for entity, rows in entity_manifest.items():
        entity_masters[entity] = build_master_attrs(rows)

    all_rows: list[dict] = []

    for m in manifest_rows:
        atomic_entity = m["atomic_entity"]
        source_system = m["source_system"]
        source_table  = m["source_table"]

        entity_meta     = entity_lookup.get(atomic_entity, {})
        bcv_core_object = entity_meta.get("bcv_core_object", "")
        bcv_concept     = entity_meta.get("bcv_concept", "")

        master_attrs = entity_masters.get(atomic_entity, OrderedDict())

        attr_rows = load_attr_file(source_system, m["lld_file"])
        if not attr_rows:
            continue

        context_keys = get_distinct_context_keys(attr_rows, source_system, source_table)

        for ctx_key in context_keys:
            for (attr_name, master_addr_part), master_row in master_attrs.items():
                # ctx_key được build từ (source_system, source_table, addr_part của source này).
                # Với shared entity, master_addr_part là addr_part từ file LLD đầu tiên định nghĩa
                # attr này. Nếu master_addr_part không None, chỉ emit dòng này khi ctx_key
                # chứa cùng addr value — tránh emit Identification Number/BUSINESS_LICENSE
                # vào context OPERATING_LICENSE.
                if master_addr_part is not None:
                    # So sánh scheme=value trong ctx_key với master_addr_part
                    scheme_m, _, value_m = master_addr_part.partition("=")
                    field_m = SCHEME_TO_FIELD.get(scheme_m, scheme_m)
                    ctx_tag = f"{field_m} = '{value_m}'"
                    if ctx_tag not in ctx_key:
                        # Không phải context này — bỏ qua
                        continue

                matched = find_attr_in_ctx(attr_rows, attr_name, ctx_key, source_system, source_table)

                if matched:
                    all_rows.append({
                        "bcv_core_object":        bcv_core_object,
                        "bcv_concept":            bcv_concept,
                        "atomic_entity":          atomic_entity,
                        "atomic_attribute":       attr_name,
                        "description":            matched.get("description", ""),
                        "data_domain":            matched.get("data_domain", ""),
                        "nullable":               matched.get("nullable", ""),
                        "is_primary_key":         matched.get("is_primary_key", ""),
                        "source_system":          source_system,
                        "source_table":           source_table,
                        "source_column":          matched.get("source_columns", ""),
                        "comment":                matched.get("comment", ""),
                        "classification_context": ctx_key,
                        "etl_derived_value":      matched.get("etl_derived_value", ""),
                    })
                else:
                    # NULL row — attribute không có trong source/context này
                    # Metadata lấy từ master (best across all sources)
                    all_rows.append({
                        "bcv_core_object":        bcv_core_object,
                        "bcv_concept":            bcv_concept,
                        "atomic_entity":          atomic_entity,
                        "atomic_attribute":       attr_name,
                        "description":            master_row.get("description", ""),
                        "data_domain":            master_row.get("data_domain", ""),
                        "nullable":               master_row.get("nullable", ""),
                        "is_primary_key":         master_row.get("is_primary_key", ""),
                        "source_system":          source_system,
                        "source_table":           source_table,
                        "source_column":          "",
                        "comment":                master_row.get("comment", ""),
                        "classification_context": ctx_key,
                        "etl_derived_value":      "",
                    })

    # Sort: bco → entity; non-shared trước, shared sau
    entity_groups: dict[tuple, list] = defaultdict(list)
    for row in all_rows:
        k = (row["bcv_core_object"], row["atomic_entity"])
        entity_groups[k].append(row)

    return sort_entity_groups(entity_groups)


# ---------------------------------------------------------------------------
# Build atomic_entities rows
# Ưu tiên description: (1) existing atomic_entities.yaml, (2) HLD Tier **Description:**
# ---------------------------------------------------------------------------
def build_entities(manifest_rows: list[dict],
                   existing_entities: dict[str, dict],
                   hld_descriptions: Optional[dict] = None) -> list[dict]:
    entity_map: dict[str, dict] = {}
    hld_desc = hld_descriptions or {}

    for m in manifest_rows:
        atomic_entity = m["atomic_entity"]
        source_table  = f"{m['source_system']}.{m['source_table']}"

        if atomic_entity not in entity_map:
            existing = existing_entities.get(atomic_entity, {})
            hld_meta = hld_desc.get(atomic_entity, {})
            # Description priority: existing file > HLD Tier > empty
            existing_desc = existing.get("description", "").strip()
            description = existing_desc or hld_meta.get("description", "")
            # Domain Prefix priority: existing file > HLD Tier > empty
            domain_prefix = existing.get("domain_prefix", "").strip() or hld_meta.get("domain_prefix", "")

            entity_map[atomic_entity] = {
                "bcv_core_object":      existing.get("bcv_core_object", ""),
                "bcv_concept":          existing.get("bcv_concept", ""),
                "atomic_entity":        atomic_entity,
                "table_type":           existing.get("table_type", ""),
                "domain_prefix":        domain_prefix,
                # entity_physical_name không bao giờ tự derive — chỉ preserve giá trị đã có
                # (AI/Data Modeler ghi trực tiếp vào atomic_entities.yaml theo Bước 8 của
                # atomic-hld-design/SKILL.md).
                "entity_physical_name": existing.get("entity_physical_name", ""),
                "description":          description,
                "source_table":         source_table,
                "status":               existing.get("status", "draft"),
            }
            existing_st = existing.get("source_table", "")
            if existing.get("status", "draft") == "approved" and source_table not in [s.strip() for s in existing_st.split(",")]:
                print(f"  [WARN] Entity approved '{atomic_entity}' có source_table mới từ manifest: {source_table}", file=sys.stderr)
        else:
            existing_st = entity_map[atomic_entity]["source_table"]
            if source_table not in existing_st.split(", "):
                entity_map[atomic_entity]["source_table"] = existing_st + ", " + source_table

    rows = sorted(
        entity_map.values(),
        key=lambda r: (bco_sort_key(r.get("bcv_core_object", "")), r["atomic_entity"])
    )
    return rows


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="Aggregate Atomic LLD CSVs")
    parser.add_argument("--dry-run",         action="store_true", help="In ra stdout thay vì ghi file")
    parser.add_argument("--skip-entities",   action="store_true", help="Bỏ qua rebuild atomic_entities.yaml")
    parser.add_argument("--skip-attributes", action="store_true", help="Bỏ qua rebuild atomic_attributes.csv")
    args = parser.parse_args()

    print("Đọc atomic_entities.yaml (source of truth)...", file=sys.stderr)
    entity_lookup = load_atomic_entities()
    print(f"  {len(entity_lookup)} entities", file=sys.stderr)

    print("Đọc manifest...", file=sys.stderr)
    all_manifest = load_manifest()
    print(f"  {len(all_manifest)} entries", file=sys.stderr)

    # --- Parse HLD descriptions từ tất cả source systems có trong manifest ---
    source_systems = {m["source_system"] for m in all_manifest}
    hld_descriptions = {}
    for src in sorted(source_systems):
        found = parse_hld_descriptions(src)
        hld_descriptions.update(found)
    if hld_descriptions:
        print(f"  HLD descriptions tìm được: {len(hld_descriptions)}", file=sys.stderr)

    # --- Build entities ---
    if not args.skip_entities:
        print("Build atomic_entities...", file=sys.stderr)
        ent_rows = build_entities(all_manifest, entity_lookup, hld_descriptions)
        print(f"  {len(ent_rows)} entity rows", file=sys.stderr)
        write_entities_yaml(OUT_ENTITIES, ent_rows, dry_run=args.dry_run)

    # --- Build attributes ---
    if not args.skip_attributes:
        print("Build atomic_attributes...", file=sys.stderr)
        attr_rows = build_attributes(all_manifest, entity_lookup)
        print(f"  {len(attr_rows)} attribute rows", file=sys.stderr)
        write_attrs_yaml(OUT_ATTRS, attr_rows, dry_run=args.dry_run)

        # Tự động bổ sung physical names ngay sau khi ghi file
        if not args.dry_run:
            print("Sinh physical names (atomic_table, atomic_column, data_type)...", file=sys.stderr)
            import importlib.util as _ilu
            _tfn_path = SCRIPT_DIR / "transform_physical_names.py"
            _spec = _ilu.spec_from_file_location("transform_physical_names", _tfn_path)
            _tfn = _ilu.module_from_spec(_spec)
            _spec.loader.exec_module(_tfn)
            _entries = _tfn.load_dict(_tfn.EXCEPTIONS_PATH)
            _domain_map = _tfn.load_data_type_rules(_tfn.DATA_TYPE_PATH)
            _registry = _tfn.load_entity_registry(_tfn.ATOMIC_ENTITIES)
            _entries = _tfn.merge_column_dict(_entries, _registry)
            n = _tfn.patch_atomic_attributes(_entries, _domain_map, _registry, dry_run=False)
            print(f"  Physical names: {n} dong", file=sys.stderr)

    print("Hoàn thành.", file=sys.stderr)


if __name__ == "__main__":
    main()
