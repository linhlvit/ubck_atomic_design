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
  - silver_attributes.csv  : (output) mapping attribute × source — tạo/ghi đè hoàn toàn

Grain của silver_attributes.csv:
  - 1 dòng = 1 (silver_entity, silver_attribute, source_system, source_table, classification_context)
  - Shared entities KHÔNG gộp cross-source — mỗi source giữ dòng riêng.

Cách dùng:
  python aggregate_silver.py                   # rebuild toàn bộ
  python aggregate_silver.py --source DCST     # chỉ nguồn DCST (rebuild toàn bộ output)
  python aggregate_silver.py --group T2        # chỉ group T2
  python aggregate_silver.py --dry-run         # in ra stdout, không ghi file
  python aggregate_silver.py --skip-entities   # bỏ qua rebuild silver_entities.csv
"""

import csv
import argparse
import sys
import io
from pathlib import Path
from collections import defaultdict

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
# Shared entity names
# ---------------------------------------------------------------------------
SHARED_ENTITIES = {
    "Involved Party Postal Address",
    "Involved Party Electronic Address",
    "Involved Party Alternative Identification",
}

# Sort key cho bcv_core_object
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

def bco_sort_key(bco: str) -> int:
    try:
        return BCO_ORDER.index(bco)
    except ValueError:
        return len(BCO_ORDER)


# ---------------------------------------------------------------------------
# Đọc silver_entities.csv → source of truth cho entity-level attributes
# Returns: dict {silver_entity → row dict}
# ---------------------------------------------------------------------------
def load_silver_entities() -> dict[str, dict]:
    result = {}
    if not OUT_ENTITIES.exists():
        return result
    with open(OUT_ENTITIES, encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            result[row["silver_entity"]] = row
    return result


# ---------------------------------------------------------------------------
# Đọc manifest → chỉ lấy mapping fields
# ---------------------------------------------------------------------------
def load_manifest(filter_source=None, filter_group=None) -> list[dict]:
    rows = []
    with open(MANIFEST, encoding="utf-8", newline="") as f:
        for row in csv.DictReader(f):
            if filter_source and row["source_system"] != filter_source:
                continue
            if filter_group and row["group"] != filter_group:
                continue
            rows.append(row)
    return rows


# ---------------------------------------------------------------------------
# Đọc 1 attr file → list of dicts
# ---------------------------------------------------------------------------
def load_attr_file(source_system: str, lld_file: str) -> list[dict]:
    candidate = LLD_DIR / source_system / lld_file
    if not candidate.exists():
        print(f"  [WARN] File không tồn tại: {candidate}", file=sys.stderr)
        return []
    rows = []
    with open(candidate, encoding="utf-8", newline="") as f:
        for row in csv.DictReader(f):
            rows.append(row)
    return rows


# ---------------------------------------------------------------------------
# Build silver_attributes rows
# 1 dòng = 1 (silver_entity, silver_attribute, source_system, source_table,
#              classification_context)
# bcv_core_object và bcv_concept lấy từ silver_entities.csv (source of truth)
# ---------------------------------------------------------------------------
def build_attributes(manifest_rows: list[dict],
                     entity_lookup: dict[str, dict]) -> list[dict]:
    all_rows: list[dict] = []

    for m in manifest_rows:
        silver_entity = m["silver_entity"]
        lld_file      = m["lld_file"]
        source_system = m["source_system"]
        source_table  = m["source_table"]

        # Lấy bcv fields từ silver_entities.csv (source of truth)
        entity_meta   = entity_lookup.get(silver_entity, {})
        bcv_core_object = entity_meta.get("bcv_core_object", "")
        bcv_concept     = entity_meta.get("bcv_concept", "")

        attr_rows = load_attr_file(source_system, lld_file)
        if not attr_rows:
            continue

        for ar in attr_rows:
            all_rows.append({
                "bcv_core_object":        bcv_core_object,
                "bcv_concept":            bcv_concept,
                "silver_entity":          silver_entity,
                "silver_attribute":       ar["attribute_name"],
                "description":            ar.get("description", ""),
                "data_domain":            ar.get("data_domain", ""),
                "nullable":               ar.get("nullable", ""),
                "is_primary_key":         ar.get("is_primary_key", ""),
                "source_system":          source_system,
                "source_table":           source_table,
                "source_column":          ar.get("source_columns", ""),
                "comment":                ar.get("comment", ""),
                "classification_context": ar.get("classification_context", ""),
                "etl_derived_value":      ar.get("etl_derived_value", ""),
            })

    # Sort: bco → silver_entity; non-shared trước, shared sau
    entity_groups: dict[tuple, list] = defaultdict(list)
    for row in all_rows:
        key = (row["bcv_core_object"], row["silver_entity"])
        entity_groups[key].append(row)

    non_shared_keys = sorted(
        [k for k in entity_groups if k[1] not in SHARED_ENTITIES],
        key=lambda k: (bco_sort_key(k[0]), k[1])
    )
    shared_keys = sorted(
        [k for k in entity_groups if k[1] in SHARED_ENTITIES],
        key=lambda k: (bco_sort_key(k[0]), k[1])
    )

    result: list[dict] = []
    for key in non_shared_keys + shared_keys:
        result.extend(entity_groups[key])

    return result


# ---------------------------------------------------------------------------
# Build silver_entities rows
# Tất cả entity-level attributes (bcv, table_type, description, status) lấy từ
# silver_entities.csv hiện tại. Chỉ cập nhật source_table nếu có source mới.
# Entity mới (chưa có trong silver_entities.csv) → thêm với attributes trống.
# ---------------------------------------------------------------------------
def build_entities(manifest_rows: list[dict],
                   existing_entities: dict[str, dict]) -> list[dict]:
    entity_map: dict[str, dict] = {}

    for m in manifest_rows:
        silver_entity = m["silver_entity"]
        source_table  = f"{m['source_system']}.{m['source_table']}"

        if silver_entity not in entity_map:
            # Lấy toàn bộ attributes từ silver_entities.csv (source of truth)
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
            # Warn nếu entity approved nhưng source_table mới không có trong silver_entities.csv
            existing_st = existing.get("source_table", "")
            if existing.get("status", "draft") == "approved" and source_table not in [s.strip() for s in existing_st.split(",")]:
                print(f"  [WARN] Entity approved '{silver_entity}' có source_table mới từ manifest: {source_table}", file=sys.stderr)
        else:
            # Chỉ cập nhật source_table nếu có source mới
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
    parser.add_argument("--source", help="Filter theo source_system (e.g. DCST)")
    parser.add_argument("--group",  help="Filter theo group (e.g. T2)")
    parser.add_argument("--dry-run", action="store_true",
                        help="In ra stdout thay vì ghi file")
    parser.add_argument("--skip-entities", action="store_true",
                        help="Bỏ qua việc rebuild silver_entities.csv")
    args = parser.parse_args()

    print("Đọc silver_entities.csv (source of truth)...", file=sys.stderr)
    entity_lookup = load_silver_entities()
    print(f"  {len(entity_lookup)} entities", file=sys.stderr)

    print("Đọc manifest...", file=sys.stderr)
    all_manifest = load_manifest()
    if args.source or args.group:
        label = f"source={args.source or '*'}, group={args.group or '*'}"
        filtered = load_manifest(filter_source=args.source, filter_group=args.group)
        print(f"  Filter: {label} — {len(filtered)} entries (build từ toàn bộ {len(all_manifest)} entries)", file=sys.stderr)

    # --- Build attributes ---
    print("Build silver_attributes...", file=sys.stderr)
    attr_rows = build_attributes(all_manifest, entity_lookup)
    print(f"  {len(attr_rows)} attribute rows", file=sys.stderr)

    ATTR_FIELDS = [
        "bcv_core_object", "bcv_concept", "silver_entity",
        "silver_attribute", "description", "data_domain",
        "nullable", "is_primary_key",
        "source_system", "source_table", "source_column",
        "comment", "classification_context", "etl_derived_value",
    ]

    if args.dry_run:
        out = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", newline="")
        writer = csv.DictWriter(out, fieldnames=ATTR_FIELDS,
                                lineterminator="\n", extrasaction="ignore")
        writer.writeheader()
        writer.writerows(attr_rows)
        out.flush()
    else:
        with open(OUT_ATTRS, "w", encoding="utf-8", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=ATTR_FIELDS,
                                    lineterminator="\n", extrasaction="ignore")
            writer.writeheader()
            writer.writerows(attr_rows)
        print(f"  Ghi: {OUT_ATTRS}", file=sys.stderr)

    # --- Build entities ---
    if not args.skip_entities:
        print("Build silver_entities...", file=sys.stderr)
        ent_rows = build_entities(all_manifest, entity_lookup)
        print(f"  {len(ent_rows)} entity rows", file=sys.stderr)

        ENTITY_FIELDS = ["bcv_core_object", "bcv_concept", "silver_entity",
                         "table_type", "status", "description", "source_table"]

        if args.dry_run:
            out = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", newline="")
            writer = csv.DictWriter(out, fieldnames=ENTITY_FIELDS,
                                    lineterminator="\n", extrasaction="ignore")
            writer.writeheader()
            writer.writerows(ent_rows)
            out.flush()
        else:
            with open(OUT_ENTITIES, "w", encoding="utf-8", newline="") as f:
                writer = csv.DictWriter(f, fieldnames=ENTITY_FIELDS,
                                        lineterminator="\n", extrasaction="ignore")
                writer.writeheader()
                writer.writerows(ent_rows)
            print(f"  Ghi: {OUT_ENTITIES}", file=sys.stderr)

    print("Hoàn thành.", file=sys.stderr)


if __name__ == "__main__":
    main()
