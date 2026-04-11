"""
aggregate_silver.py
===================
Tổng hợp silver_entities.csv và silver_attributes.csv từ các LLD attr files.

Nguồn dữ liệu:
  - manifest.csv          : danh sách đầy đủ các entity, file LLD, bcv_core_object
  - <SOURCE>/<lld_file>   : từng file attr CSV
  - silver_entities.csv   : (output) danh sách entity — tạo/ghi đè hoàn toàn
  - silver_attributes.csv : (output) mapping attribute × source — tạo/ghi đè hoàn toàn

Grain của silver_attributes.csv (Hướng A):
  - 1 dòng = 1 (silver_entity, silver_attribute, source_system, source_table, classification_context)
  - Shared entities KHÔNG gộp cross-source — mỗi source giữ dòng riêng.
  - classification_context = giá trị cột classification_context trong attr file (SCHEME=VALUE).

Cách dùng:
  python aggregate_silver.py                   # rebuild toàn bộ
  python aggregate_silver.py --source DCST     # chỉ nguồn DCST (rebuild toàn bộ output)
  python aggregate_silver.py --group T2        # chỉ group T2
  python aggregate_silver.py --dry-run         # in ra stdout, không ghi file
"""

import csv
import argparse
import sys
from pathlib import Path
from collections import defaultdict

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
# Đọc manifest
# ---------------------------------------------------------------------------
def load_manifest(filter_source=None, filter_group=None):
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
# Build silver_attributes rows — Hướng A
# 1 dòng = 1 (silver_entity, silver_attribute, source_system, source_table,
#              classification_context)
# ---------------------------------------------------------------------------
def build_attributes(manifest_rows: list[dict]) -> list[dict]:
    all_rows: list[dict] = []

    for m in manifest_rows:
        silver_entity   = m["silver_entity"]
        bcv_core_object = m["bcv_core_object"]
        bcv_concept     = m["bcv_concept"]
        lld_file        = m["lld_file"]
        source_system   = m["source_system"]
        source_table    = m["source_table"]

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
                "classification_context": ar.get("classification_context", ""),
                "etl_derived_value":      ar.get("etl_derived_value", ""),
            })

    # Sort: bco → silver_entity (giữ thứ tự attribute + source trong entity)
    # Group by (bco, silver_entity) để sort entity, giữ thứ tự rows bên trong
    entity_groups: dict[tuple, list] = defaultdict(list)
    for row in all_rows:
        key = (row["bcv_core_object"], row["silver_entity"])
        entity_groups[key].append(row)

    # Non-shared trước, shared sau — giữ đúng thứ tự thiết kế
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
# ---------------------------------------------------------------------------
def build_entities(manifest_rows: list[dict]) -> list[dict]:
    """
    Trả về list các row cho silver_entities.csv.
    Mỗi silver_entity xuất hiện 1 lần (dedup).
    source_table = join các source_table khác nhau.
    """
    entity_map: dict[str, dict] = {}

    for m in manifest_rows:
        silver_entity   = m["silver_entity"]
        source_table    = f"{m['source_system']}.{m['source_table']}"
        bcv_core_object = m["bcv_core_object"]
        bcv_concept     = m["bcv_concept"]

        if silver_entity not in entity_map:
            entity_map[silver_entity] = {
                "bcv_core_object": bcv_core_object,
                "bcv_concept":     bcv_concept,
                "silver_entity":   silver_entity,
                "description":     "",
                "source_table":    source_table,
            }
        else:
            existing = entity_map[silver_entity]["source_table"]
            if source_table not in existing.split(", "):
                entity_map[silver_entity]["source_table"] = existing + ", " + source_table

    rows = sorted(
        entity_map.values(),
        key=lambda r: (bco_sort_key(r["bcv_core_object"]), r["silver_entity"])
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

    print("Đọc manifest...", file=sys.stderr)
    all_manifest = load_manifest()
    filtered = load_manifest(filter_source=args.source, filter_group=args.group)
    if args.source or args.group:
        label = f"source={args.source or '*'}, group={args.group or '*'}"
        print(f"  Filter: {label} — {len(filtered)} entries (nhưng build từ toàn bộ {len(all_manifest)} entries)", file=sys.stderr)

    # --- Build attributes ---
    print("Build silver_attributes...", file=sys.stderr)
    attr_rows = build_attributes(all_manifest)
    print(f"  {len(attr_rows)} attribute rows", file=sys.stderr)

    ATTR_FIELDS = [
        "bcv_core_object", "bcv_concept", "silver_entity",
        "silver_attribute", "description", "data_domain",
        "nullable", "is_primary_key",
        "source_system", "source_table", "source_column",
        "classification_context", "etl_derived_value",
    ]

    if args.dry_run:
        import io
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
        ent_rows = build_entities(all_manifest)
        print(f"  {len(ent_rows)} entity rows", file=sys.stderr)

        ENTITY_FIELDS = ["bcv_core_object", "bcv_concept", "silver_entity",
                         "description", "source_table"]

        existing_desc: dict[str, str] = {}
        if OUT_ENTITIES.exists():
            with open(OUT_ENTITIES, encoding="utf-8", newline="") as f:
                for row in csv.DictReader(f):
                    if row.get("description"):
                        existing_desc[row["silver_entity"]] = row["description"]
        for row in ent_rows:
            if not row["description"] and row["silver_entity"] in existing_desc:
                row["description"] = existing_desc[row["silver_entity"]]

        if args.dry_run:
            import io
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
