"""
aggregate_silver.py
===================
Tổng hợp silver_entities.csv và silver_attributes.csv từ các LLD attr files.

Nguồn dữ liệu:
  - manifest.csv          : danh sách đầy đủ các entity, file LLD, bcv_core_object
  - <SOURCE>/<lld_file>   : từng file attr CSV
  - silver_entities.csv   : (output) danh sách entity — tạo/ghi đè hoàn toàn
  - silver_attributes.csv : (output) danh sách attribute — tạo/ghi đè hoàn toàn

Shared entities (IP Alt Identification, IP Postal Address, IP Electronic Address):
  - Được gộp thành 1 dòng duy nhất mỗi attribute.
  - source_column = join các giá trị khác rỗng từ mọi nguồn, phân cách ", ".

Cách dùng:
  python aggregate_silver.py                   # rebuild toàn bộ
  python aggregate_silver.py --source DCST     # chỉ nguồn DCST (rebuild toàn bộ output)
  python aggregate_silver.py --group T2        # chỉ group T2
  python aggregate_silver.py --dry-run         # in ra stdout, không ghi file

Lưu ý: --source và --group chỉ là filter để kiểm tra output; output file vẫn
chứa toàn bộ dữ liệu từ mọi nguồn (vì shared entities cần merge cross-source).
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
# Shared entity names — gộp source_column cross-source
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
# Đọc 1 attr file → list of dicts với key: attribute_name, description,
#   data_domain, nullable, is_primary_key, status, source_columns, comment
# ---------------------------------------------------------------------------
def load_attr_file(source_system: str, lld_file: str) -> list[dict]:
    # Tìm file trong thư mục con tương ứng với source_system
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
# ---------------------------------------------------------------------------
def build_attributes(manifest_rows: list[dict]) -> list[dict]:
    """
    Trả về list các row cho silver_attributes.csv.
    Mỗi row: bcv_core_object, bcv_concept, silver_entity,
              silver_attribute, description, data_domain, source_column

    Shared entities được gộp: mỗi attribute_name chỉ xuất hiện 1 lần,
    source_column = union của mọi nguồn.
    """

    # --- Pass 1: Thu thập dữ liệu cho non-shared entities ---
    non_shared: list[dict] = []

    # Shared entity buffer: {silver_entity: {attribute_name: merged_row}}
    shared_buffer: dict[str, dict[str, dict]] = defaultdict(dict)

    # Metadata cho shared entities (bcv_core_object, bcv_concept cần lấy từ manifest)
    shared_meta: dict[str, dict] = {}

    for m in manifest_rows:
        silver_entity  = m["silver_entity"]
        bcv_core_object = m["bcv_core_object"]
        bcv_concept    = m["bcv_concept"]
        lld_file       = m["lld_file"]
        source_system  = m["source_system"]

        attr_rows = load_attr_file(source_system, lld_file)
        if not attr_rows:
            continue

        is_shared = silver_entity in SHARED_ENTITIES

        if is_shared:
            shared_meta[silver_entity] = {
                "bcv_core_object": bcv_core_object,
                "bcv_concept": bcv_concept,
            }
            for ar in attr_rows:
                attr_name = ar["attribute_name"]
                src_col   = ar.get("source_columns", "").strip()

                if attr_name not in shared_buffer[silver_entity]:
                    # Khởi tạo lần đầu gặp attribute này
                    shared_buffer[silver_entity][attr_name] = {
                        "attribute_name": attr_name,
                        "description":    ar.get("description", ""),
                        "data_domain":    ar.get("data_domain", ""),
                        "nullable":       ar.get("nullable", ""),
                        "is_primary_key": ar.get("is_primary_key", ""),
                        "source_columns": [src_col] if src_col else [],
                    }
                else:
                    # Merge source_column
                    if src_col and src_col not in shared_buffer[silver_entity][attr_name]["source_columns"]:
                        shared_buffer[silver_entity][attr_name]["source_columns"].append(src_col)
        else:
            for ar in attr_rows:
                non_shared.append({
                    "bcv_core_object":  bcv_core_object,
                    "bcv_concept":      bcv_concept,
                    "silver_entity":    silver_entity,
                    "silver_attribute": ar["attribute_name"],
                    "description":      ar.get("description", ""),
                    "data_domain":      ar.get("data_domain", ""),
                    "nullable":         ar.get("nullable", ""),
                    "is_primary_key":   ar.get("is_primary_key", ""),
                    "source_column":    ar.get("source_columns", ""),
                })

    # --- Pass 2: Flatten shared buffer ---
    shared_rows: list[dict] = []
    for silver_entity, attr_map in shared_buffer.items():
        meta = shared_meta.get(silver_entity, {
            "bcv_core_object": "Involved Party",
            "bcv_concept": "Shared Entity",
        })
        for attr_name, data in attr_map.items():
            merged_src = ", ".join(data["source_columns"])
            shared_rows.append({
                "bcv_core_object":  meta["bcv_core_object"],
                "bcv_concept":      meta["bcv_concept"],
                "silver_entity":    silver_entity,
                "silver_attribute": attr_name,
                "description":      data["description"],
                "data_domain":      data.get("data_domain", ""),
                "nullable":         data.get("nullable", ""),
                "is_primary_key":   data.get("is_primary_key", ""),
                "source_column":    merged_src,
            })

    # --- Pass 3: Sort ---
    # Non-shared: giữ thứ tự attribute trong entity, sort entity theo bco + name
    # Group non_shared by (bco, entity)
    entity_groups: dict[tuple, list] = defaultdict(list)
    entity_bco: dict[str, str] = {}
    for row in non_shared:
        key = (row["bcv_core_object"], row["silver_entity"])
        entity_groups[key].append(row)
        entity_bco[row["silver_entity"]] = row["bcv_core_object"]

    sorted_keys = sorted(
        entity_groups.keys(),
        key=lambda k: (bco_sort_key(k[0]), k[1])
    )

    result: list[dict] = []
    for key in sorted_keys:
        result.extend(entity_groups[key])

    # Shared: sort by bco + entity name
    shared_entity_groups: dict[tuple, list] = defaultdict(list)
    for row in shared_rows:
        key = (row["bcv_core_object"], row["silver_entity"])
        shared_entity_groups[key].append(row)

    shared_sorted_keys = sorted(
        shared_entity_groups.keys(),
        key=lambda k: (bco_sort_key(k[0]), k[1])
    )
    for key in shared_sorted_keys:
        result.extend(shared_entity_groups[key])

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
    # {silver_entity: merged_row}
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
                "description":     "",   # mô tả điền thủ công trong HLD — giữ rỗng nếu chưa có
                "source_table":    source_table,
            }
        else:
            # Merge source_table
            existing = entity_map[silver_entity]["source_table"]
            if source_table not in existing.split(", "):
                entity_map[silver_entity]["source_table"] = existing + ", " + source_table

    # Sort: bco → silver_entity
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
    # Luôn load toàn bộ manifest để shared entities merge đúng
    all_manifest = load_manifest()
    # Filter chỉ dùng để in thông báo, không filter khi build
    filtered = load_manifest(filter_source=args.source, filter_group=args.group)
    if args.source or args.group:
        label = f"source={args.source or '*'}, group={args.group or '*'}"
        print(f"  Filter: {label} — {len(filtered)} entries (nhưng build từ toàn bộ {len(all_manifest)} entries)", file=sys.stderr)

    # --- Build attributes ---
    print("Build silver_attributes...", file=sys.stderr)
    attr_rows = build_attributes(all_manifest)
    print(f"  {len(attr_rows)} attribute rows", file=sys.stderr)

    ATTR_FIELDS = ["bcv_core_object", "bcv_concept", "silver_entity",
                   "silver_attribute", "description", "data_domain",
                   "nullable", "is_primary_key", "source_column"]

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

        # Merge description từ file hiện có (không xóa mô tả đã điền thủ công)
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
