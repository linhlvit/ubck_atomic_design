"""
generate_dm_yaml.py
-------------------
Generate DataModel/Atomic/{BCV_Folder}/dm_atm_{table}-{SOURCE}.{SRC_TABLE}.yaml
for every (atomic_table, source_system, source_table) combination
found in DataModel/working/Atomic/lld/atomic_attributes.yaml.

Sub-folder per BCV Core Object:
  Arrangement, Business Activity, Common, Communication, Condition,
  Documentation, Event, Group, Involved Party, Location, Product, Transaction

etl_pattern mapping from system/rules/rule_map_technical_table_type.csv:
  Fundamental  -> SCD4A
  Relative     -> SCD2       (rule file key: "Relation")
  Fact Append  -> Fact Append
  Fact Snapshot-> Fact Snapshot
  Classification -> Upsert

Usage:
  python DataModel/generate_dm_yaml.py [--source NHNCK] [--dry-run]
"""

import csv
import os
import re
import sys
import argparse
import yaml
from pathlib import Path
from collections import defaultdict

# ---------------------------------------------------------------------------
# Paths (relative to project root)
# ---------------------------------------------------------------------------
ROOT        = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ATTRS_YAML  = os.path.join(ROOT, "DataModel", "working", "Atomic", "aggregate", "atomic_attributes.yaml")
ENTITIES_YAML= os.path.join(ROOT, "DataModel", "working", "Atomic", "hld", "atomic_entities.yaml")
RULE_CSV    = os.path.join(ROOT, "system", "rules", "rule_map_technical_table_type.csv")
OUT_DIR     = os.path.join(ROOT, "DataModel", "Atomic")

# ---------------------------------------------------------------------------
# ETL pattern rule map
# ---------------------------------------------------------------------------
def load_etl_map(path):
    """Returns dict: Model Table Type (lowercase) -> Technical Table Type"""
    mapping = {}
    if os.path.exists(path):
        with open(path, encoding="utf-8-sig") as f:
            for row in csv.DictReader(f):
                mapping[row["Model Table Type"].strip().lower()] = row["Technical Table Type"].strip()
    # Fallback defaults
    defaults = {
        "fundamental":   "SCD4A",
        "relative":      "SCD2",
        "fact append":   "Fact Append",
        "fact snapshot": "Fact Snapshot",
        "classification":"Upsert",
    }
    for k, v in defaults.items():
        mapping.setdefault(k, v)
    # rule file uses "relation" for what CSV calls "relative"
    if "relation" in mapping and "relative" not in mapping:
        mapping["relative"] = mapping["relation"]
    return mapping


# ---------------------------------------------------------------------------
# Load entity metadata
# ---------------------------------------------------------------------------
def load_entities(path):
    """Returns dict: atomic_entity -> {bcv_core_object, bcv_concept, table_type,
                                       status, description}"""
    entities = {}
    if os.path.exists(path):
        data = yaml.safe_load(Path(path).read_text(encoding="utf-8")) or {}
        for row in data.get("entities", []):
            entities[str(row.get("atomic_entity", "")).strip()] = {
                "bcv_core_object": str(row.get("bcv_core_object", "") or "").strip(),
                "bcv_concept":     str(row.get("bcv_concept", "") or "").strip(),
                "table_type":      str(row.get("table_type", "") or "").strip(),
                "status":          str(row.get("status", "") or "").strip(),
                "description":     str(row.get("description", "") or "").strip(),
            }
    return entities


# ---------------------------------------------------------------------------
# BCV folder name → safe directory name
# ---------------------------------------------------------------------------
def bcv_folder(bcv_core_object):
    """Convert BCV Core Object to a valid folder name."""
    return bcv_core_object.replace(" ", "_")


# ---------------------------------------------------------------------------
# Safe YAML string: escape characters that need quoting
# ---------------------------------------------------------------------------
def yaml_str(value, multiline=False):
    """Return a YAML-safe representation of a string value."""
    if value is None or value == "":
        return "null"
    if multiline:
        # Use literal block scalar for long descriptions
        indented = "\n    ".join(value.splitlines())
        return "|\n    " + indented
    # Quote if contains special chars
    needs_quote = any(c in value for c in [':', '#', '{', '}', '[', ']', ',', '&', '*', '?', '|', '-', '<', '>', '=', '!', '%', '@', '`', '"', "'"])
    if needs_quote:
        escaped = value.replace('"', '\\"')
        return f'"{escaped}"'
    return value


def yaml_bool(value):
    """Convert string 'true'/'false' to YAML boolean."""
    if isinstance(value, bool):
        return "true" if value else "false"
    return "true" if str(value).strip().lower() == "true" else "false"


def yaml_nullable_str(value):
    """null if empty, else quoted YAML string."""
    v = value.strip() if value else ""
    if not v:
        return "null"
    return yaml_str(v)


def normalize_comment(comment, name_to_table):
    """Replace logical entity names in FK/Lookup comments with physical table names."""
    if not comment or not name_to_table:
        return comment
    # Sort by length descending to avoid partial-match issues
    for ename in sorted(name_to_table, key=len, reverse=True):
        tname = name_to_table[ename]
        if ename not in comment:
            continue
        comment = comment.replace(
            f"{ename}.{ename} Id", f"{tname}.{tname}_id"
        )
        comment = comment.replace(
            f"{ename}.{ename} Code", f"{tname}.{tname}_code"
        )
    return comment


def normalize_classification_ctx(ctx):
    """Uppercase the value inside single quotes in 'Source System Code = ...' patterns."""
    if not ctx:
        return ctx
    return re.sub(
        r"(=\s*')([^']+)(')",
        lambda m: m.group(1) + m.group(2).upper() + m.group(3),
        ctx
    )


# ---------------------------------------------------------------------------
# Derive BRD reference
# ---------------------------------------------------------------------------
def brd_ref(source_system, source_table):
    """BRD-SRC-{SOURCE}-{TABLE}"""
    # Normalize: strip dots, slashes from table name
    tbl = re.sub(r"[^A-Za-z0-9_]", "_", source_table)
    return f"BRD-SRC-{source_system}-{tbl}"


# ---------------------------------------------------------------------------
# Build YAML content for one (table, source, src_table) group
# ---------------------------------------------------------------------------
def build_yaml(atomic_table, source_system, source_table, attrs, entity_meta, etl_map, name_to_table=None):
    entity_name   = attrs[0]["atomic_entity"].strip()
    bcv_core      = entity_meta.get("bcv_core_object", "")
    bcv_concept   = entity_meta.get("bcv_concept", "")
    table_type    = entity_meta.get("table_type", "Fundamental")
    status        = entity_meta.get("status", "draft")
    description   = entity_meta.get("description", "")
    etl_pattern   = etl_map.get(table_type.lower(), "SCD4A")

    # Build ldm.id: ATM-{physical_name}-{SOURCE}.{SRC_TABLE}
    ldm_id = f"ATM-{atomic_table}-{source_system}.{source_table}"
    logical_name = entity_name
    physical_name = atomic_table

    lines = []
    lines.append("schema_type: data_model")
    lines.append('schema_version: "1.0"')
    lines.append("")
    lines.append("ldm:")
    lines.append(f"  id: {ldm_id}")
    lines.append(f"  logical_name: {yaml_str(logical_name)}")
    lines.append(f"  physical_name: {physical_name}")
    lines.append("  layer: Atomic")
    lines.append('  version: "1.0"')
    lines.append(f"  status: {status if status in ('draft','reviewed','approved') else 'draft'}")
    lines.append(f"  bcv_core_object: {yaml_str(bcv_core)}")
    lines.append(f"  bcv_concept: {yaml_str(bcv_concept)}")
    lines.append(f"  table_type: {yaml_str(table_type)}")
    lines.append(f"  etl_pattern: {yaml_str(etl_pattern)}")
    lines.append(f"  source: {source_system}")
    if description:
        lines.append(f"  description: {yaml_str(description, multiline=len(description) > 80)}")
    else:
        lines.append("  description: null")
    lines.append("  owner:")
    lines.append("    steward: username@ubck.com.vn")
    lines.append("    data_modeler: username@fssc.com.vn")
    lines.append("  references:")
    lines.append(f"    brd: {brd_ref(source_system, source_table)}")
    lines.append("")
    lines.append("attributes:")

    for attr in attrs:
        src_col = attr["source_column"].strip()
        if "," in src_col:
            # Multi-column pivot (ETL chọn 1 trong N cột nguồn tùy context) — dm.schema.json
            # chỉ chấp nhận 1 SYSTEM.TABLE.column hoặc null. Chi tiết mapping từng cột đã có
            # đầy đủ trong comment (ETL pivot: ...), nên không mất thông tin khi để null.
            src_col = ""
        comment = normalize_comment(attr["comment"].strip(), name_to_table)
        ctx     = normalize_classification_ctx(attr["classification_context"].strip())
        derived = attr["etl_derived_value"].strip()

        lines.append(f"  - name: {yaml_str(attr['atomic_attribute'].strip())}")
        lines.append(f"    physical_name: {attr['atomic_column'].strip()}")
        lines.append(f"    business_meaning: {yaml_str(attr['description'].strip())}")
        lines.append(f"    data_domain: {yaml_str(attr['data_domain'].strip())}")
        lines.append(f"    data_type: {attr['data_type'].strip()}")
        lines.append(f"    nullable: {yaml_bool(attr['nullable'])}")
        lines.append(f"    is_primary_key: {yaml_bool(attr['is_primary_key'])}")
        lines.append(f"    source_system: {attr['source_system'].strip()}")
        lines.append(f"    source_table: {attr['source_table'].strip()}")
        lines.append(f"    source_column: {yaml_nullable_str(src_col)}")
        lines.append(f"    comment: {yaml_nullable_str(comment)}")
        lines.append(f"    classification_context: {yaml_nullable_str(ctx)}")
        lines.append(f"    etl_derived_value: {yaml_nullable_str(derived)}")
        lines.append("")

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true", help="Print file list without writing")
    parser.add_argument("--source", help="Only generate files for this source system (e.g. NHNCK)")
    args = parser.parse_args()

    etl_map     = load_etl_map(RULE_CSV)
    entities    = load_entities(ENTITIES_YAML)

    # Load attributes from YAML
    _adata = yaml.safe_load(Path(ATTRS_YAML).read_text(encoding="utf-8"))
    _attrs_raw = (_adata or {}).get("attributes", [])
    # Normalize: bool → string, None → ""
    def _norm(a):
        r = dict(a)
        for k in ("nullable", "is_primary_key"):
            v = r.get(k)
            if isinstance(v, bool):
                r[k] = "true" if v else "false"
            elif v is None:
                r[k] = ""
        for k in ("atomic_entity","atomic_table","atomic_column","atomic_attribute",
                  "source_column","source_system","source_table","comment",
                  "classification_context","etl_derived_value","description",
                  "data_domain","data_type","bcv_core_object"):
            if r.get(k) is None:
                r[k] = ""
        return r
    all_attrs = [_norm(a) for a in _attrs_raw]

    # Build entity_name → atomic_table map from ALL sources
    name_to_table = {}
    for row in all_attrs:
        ename = row["atomic_entity"].strip()
        tname = row["atomic_table"].strip()
        if ename and tname:
            name_to_table.setdefault(ename, tname)

    # Group by (atomic_table, source_system, source_table)
    groups = defaultdict(list)
    for row in all_attrs:
        src = row["source_system"].strip()
        if args.source and src != args.source:
            continue
        key = (row["atomic_table"].strip(), src, row["source_table"].strip())
        groups[key].append(row)

    created = skipped = 0

    for (atomic_table, source_system, source_table), attrs in sorted(groups.items()):
        entity_name = attrs[0]["atomic_entity"].strip()
        meta        = entities.get(entity_name, {})
        bcv_core    = meta.get("bcv_core_object", attrs[0].get("bcv_core_object", "Common")).strip()

        folder      = os.path.join(OUT_DIR, bcv_folder(bcv_core))
        filename    = f"dm_atm_{atomic_table}-{source_system}.{source_table}.yaml"
        filepath    = os.path.join(folder, filename)

        if args.dry_run:
            print(f"[DRY-RUN] {os.path.relpath(filepath, ROOT)}")
            created += 1
            continue

        os.makedirs(folder, exist_ok=True)

        # Skip the already-created sample file for dscl_ahr-FIMS.AUTHOANNOUNCE
        # (overwrite it so it stays consistent)
        content = build_yaml(atomic_table, source_system, source_table, attrs, meta, etl_map, name_to_table)

        with open(filepath, "w", encoding="utf-8") as f:
            f.write(content)

        created += 1

    print(f"{'[DRY-RUN] ' if args.dry_run else ''}Done: {created} files {'would be ' if args.dry_run else ''}written, {skipped} skipped.")


if __name__ == "__main__":
    main()
