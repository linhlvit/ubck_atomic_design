"""
aggregate_silver.py
===================
Tổng hợp silver_entities.csv và silver_attributes.csv từ các LLD attr files.

Nguồn dữ liệu:
  - silver_entities.csv    : source of truth cho entity-level attributes
                             (bcv_core_object, bcv_concept, table_type, description)
  - manifest.csv           : mapping source → entity (source_system, source_table,
                             silver_entity, group, lld_file)
  - <SOURCE>/<lld_file>    : từng file attr CSV

Output:
  - silver_attributes.csv  : mapping detail — 1 dòng per (entity × attribute × source × context)

Luồng:
  manifest.csv + attr_*.csv → build_attributes() → silver_attributes.csv

Grain của silver_attributes.csv:
  1 dòng = 1 (silver_entity, silver_attribute, source_system, source_table,
               classification_context)

Master attribute list per entity được xác định từ union tất cả attr_*.csv
của entity đó (qua manifest), giữ thứ tự xuất hiện đầu tiên.

classification_context format (output):
  Field Name = 'value' — mỗi condition cách nhau " | "
  VD: "Source System Code = 'FIMS_AUTHOANNOUNCE'"
      "Source System Code = 'FIMS_FUNDCOMPANY' | Address Type Code = 'HEAD_OFFICE'"

attr_*.csv dùng format cũ (SOURCE_SYSTEM=X.Y, IP_ADDR_TYPE=X) — script convert khi build.

Dòng không có addr_type trong attr file = dùng chung mọi context (fallback).
Attribute không có mapping trong context cụ thể → emit NULL row (source_column="").

Cách dùng:
  python aggregate_silver.py                   # rebuild toàn bộ
  python aggregate_silver.py --dry-run         # in ra stdout, không ghi file
  python aggregate_silver.py --skip-entities   # bỏ qua rebuild silver_entities.csv
  python aggregate_silver.py --skip-attributes # bỏ qua rebuild silver_attributes.csv
"""

import csv
import argparse
import sys
import io
from pathlib import Path
from collections import defaultdict, OrderedDict

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
    "bcv_core_object", "silver_entity",
    "silver_attribute", "description", "data_domain",
    "nullable", "is_primary_key",
    "source_system", "source_table", "source_column",
    "comment", "classification_context", "etl_derived_value",
]

ENTITY_FIELDS = [
    "bcv_core_object", "bcv_concept", "silver_entity",
    "table_type", "status", "description", "source_table",
]


def bco_sort_key(bco: str) -> int:
    try:
        return BCO_ORDER.index(bco)
    except ValueError:
        return len(BCO_ORDER)


# ---------------------------------------------------------------------------
# IO helpers
# ---------------------------------------------------------------------------
def load_silver_entities() -> dict[str, dict]:
    result = {}
    if not OUT_ENTITIES.exists():
        return result
    with open(OUT_ENTITIES, encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            result[row["silver_entity"]] = row
    return result


def load_manifest(filter_source=None, filter_group=None) -> list[dict]:
    rows = []
    with open(MANIFEST, encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            if row.get("group", "").strip() == "pending":
                continue
            if not row.get("lld_file", "").strip():
                continue
            if filter_source and row["source_system"] != filter_source:
                continue
            if filter_group and row["group"] != filter_group:
                continue
            rows.append(row)
    return rows


_warned_missing: set = set()

def load_attr_file(source_system: str, lld_file: str) -> list[dict]:
    candidate = LLD_DIR / source_system / lld_file
    if not candidate.exists():
        if candidate not in _warned_missing:
            print(f"  [WARN] File không tồn tại: {candidate}", file=sys.stderr)
            _warned_missing.add(candidate)
        return []
    with open(candidate, encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


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
def _extract_addr_part(ctx_str: str) -> str | None:
    """Lấy phần addr_type từ classification_context (không phải SOURCE_SYSTEM).
    Đọc format cũ trong attr_*.csv: IP_ADDR_TYPE=X, IP_ALT_ID_TYPE=X, IP_ELEC_ADDR_TYPE=X
    """
    for part in ctx_str.split("|"):
        part = part.strip()
        if any(part.startswith(s) for s in ADDR_SCHEMES):
            return part
    return None


def build_ctx_string(source_system: str, source_table: str, addr_part: str | None) -> str:
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
        ctx = ar.get("classification_context", "").strip()
        addr = _extract_addr_part(ctx)
        if addr:
            addr_types.add(addr)

    if not addr_types:
        return [build_ctx_string(source_system, source_table, None)]

    return [build_ctx_string(source_system, source_table, addr) for addr in sorted(addr_types)]


def find_attr_in_ctx(attr_rows: list[dict], attr_name: str, ctx_key: str,
                     source_system: str, source_table: str) -> dict | None:
    """Tìm attr row khớp tên + context key. Trả về None nếu không tìm thấy.

    Ưu tiên: dòng có addr_type khớp chính xác trước,
    rồi đến dòng không có addr_type (fallback — dùng chung mọi context).
    """
    fallback = None

    for ar in attr_rows:
        if ar["attribute_name"] != attr_name:
            continue
        raw_ctx   = ar.get("classification_context", "").strip()
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
def build_master_attrs(entity_manifest_rows: list[dict]) -> "OrderedDict[tuple, dict]":
    master: OrderedDict[tuple, dict] = OrderedDict()

    for m in entity_manifest_rows:
        attr_rows = load_attr_file(m["source_system"], m["lld_file"])
        for ar in attr_rows:
            name     = ar["attribute_name"]
            raw_ctx  = ar.get("classification_context", "").strip()
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
# Build silver_attributes rows
# Grain: 1 dòng = 1 (silver_entity × silver_attribute × source × context)
# Master attribute list per entity lấy từ union tất cả attr files (qua manifest)
# ---------------------------------------------------------------------------
def build_attributes(manifest_rows: list[dict],
                     entity_lookup: dict[str, dict]) -> list[dict]:
    # Group manifest theo entity
    entity_manifest: dict[str, list[dict]] = defaultdict(list)
    for m in manifest_rows:
        entity_manifest[m["silver_entity"]].append(m)

    # Precompute master attr list per entity (1 lần, dùng lại cho mọi source)
    entity_masters: dict[str, OrderedDict] = {}
    for entity, rows in entity_manifest.items():
        entity_masters[entity] = build_master_attrs(rows)

    all_rows: list[dict] = []

    for m in manifest_rows:
        silver_entity = m["silver_entity"]
        source_system = m["source_system"]
        source_table  = m["source_table"]

        entity_meta     = entity_lookup.get(silver_entity, {})
        bcv_core_object = entity_meta.get("bcv_core_object", "")
        bcv_concept     = entity_meta.get("bcv_concept", "")

        master_attrs = entity_masters.get(silver_entity, OrderedDict())

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
                        "silver_entity":          silver_entity,
                        "silver_attribute":       attr_name,
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
                        "silver_entity":          silver_entity,
                        "silver_attribute":       attr_name,
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
        k = (row["bcv_core_object"], row["silver_entity"])
        entity_groups[k].append(row)

    return sort_entity_groups(entity_groups)


# ---------------------------------------------------------------------------
# Build silver_entities rows (giữ nguyên logic)
# ---------------------------------------------------------------------------
def build_entities(manifest_rows: list[dict],
                   existing_entities: dict[str, dict]) -> list[dict]:
    entity_map: dict[str, dict] = {}

    for m in manifest_rows:
        silver_entity = m["silver_entity"]
        source_table  = f"{m['source_system']}.{m['source_table']}"

        if silver_entity not in entity_map:
            existing = existing_entities.get(silver_entity, {})
            entity_map[silver_entity] = {
                "bcv_core_object": existing.get("bcv_core_object", ""),
                "bcv_concept":     existing.get("bcv_concept", ""),
                "silver_entity":   silver_entity,
                "table_type":      existing.get("table_type", ""),
                "description":     existing.get("description", ""),
                "source_table":    source_table,
                "status":          existing.get("status", "draft"),
            }
            existing_st = existing.get("source_table", "")
            if existing.get("status", "draft") == "approved" and source_table not in [s.strip() for s in existing_st.split(",")]:
                print(f"  [WARN] Entity approved '{silver_entity}' có source_table mới từ manifest: {source_table}", file=sys.stderr)
        else:
            existing_st = entity_map[silver_entity]["source_table"]
            if source_table not in existing_st.split(", "):
                entity_map[silver_entity]["source_table"] = existing_st + ", " + source_table

    rows = sorted(
        entity_map.values(),
        key=lambda r: (bco_sort_key(r.get("bcv_core_object", "")), r["silver_entity"])
    )
    return rows


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="Aggregate Silver LLD CSVs")
    parser.add_argument("--dry-run",         action="store_true", help="In ra stdout thay vì ghi file")
    parser.add_argument("--skip-entities",   action="store_true", help="Bỏ qua rebuild silver_entities.csv")
    parser.add_argument("--skip-attributes", action="store_true", help="Bỏ qua rebuild silver_attributes.csv")
    args = parser.parse_args()

    print("Đọc silver_entities.csv (source of truth)...", file=sys.stderr)
    entity_lookup = load_silver_entities()
    print(f"  {len(entity_lookup)} entities", file=sys.stderr)

    print("Đọc manifest...", file=sys.stderr)
    all_manifest = load_manifest()
    print(f"  {len(all_manifest)} entries", file=sys.stderr)

    # --- Build entities ---
    if not args.skip_entities:
        print("Build silver_entities...", file=sys.stderr)
        ent_rows = build_entities(all_manifest, entity_lookup)
        print(f"  {len(ent_rows)} entity rows", file=sys.stderr)
        write_csv(OUT_ENTITIES, ENTITY_FIELDS, ent_rows, dry_run=args.dry_run)

    # --- Build attributes ---
    if not args.skip_attributes:
        print("Build silver_attributes...", file=sys.stderr)
        attr_rows = build_attributes(all_manifest, entity_lookup)
        print(f"  {len(attr_rows)} attribute rows", file=sys.stderr)
        write_csv(OUT_ATTRS, ATTR_FIELDS, attr_rows, dry_run=args.dry_run)

    print("Hoàn thành.", file=sys.stderr)


if __name__ == "__main__":
    main()
