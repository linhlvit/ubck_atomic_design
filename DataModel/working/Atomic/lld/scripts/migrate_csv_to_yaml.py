"""
migrate_csv_to_yaml.py
======================
Convert attr_*.csv (Atomic/lld/{SOURCE}/) sang lld_*.yaml (DataModel/working/Atomic/lld/{SOURCE}/)
Đồng thời tạo manifest.yaml từ manifest.csv.

Dùng khi:
  Chuyển đổi thiết kế LLD hiện có từ CSV (format cũ) sang YAML (format mới).

Logic:
  1. Đọc Atomic/lld/manifest.csv
  2. Đọc atomic_attributes.csv → lấy entity_physical_name + attribute physical_name
  3. Đọc DataModel/working/Atomic/hld/atomic_entities.csv → bcv_core_object, bcv_concept, table_type
  4. Với mỗi entry trong manifest: đọc attr_*.csv → build lld_*.yaml
  5. Ghi DataModel/working/Atomic/lld/{SOURCE}/lld_*.yaml (design_status: approved)
  6. Ghi DataModel/working/Atomic/lld/manifest.yaml
  7. Backup CSV gốc → Atomic/lld/{SOURCE}/archive/ (khi không --dry-run)

Source columns trong attr_*.csv là single string, trong lld_*.yaml là list.
  Empty string → []
  "SOURCE.schema.TABLE.COLUMN" → ["SOURCE.schema.TABLE.COLUMN"]

Cách dùng:
  python Atomic/lld/scripts/migrate_csv_to_yaml.py --source NHNCK --dry-run
  python Atomic/lld/scripts/migrate_csv_to_yaml.py --source NHNCK
  python Atomic/lld/scripts/migrate_csv_to_yaml.py  # migrate toàn bộ source
"""

import csv
import os
import sys
import io
import argparse
import shutil
from pathlib import Path
from collections import defaultdict

# Fix encoding trên Windows terminal
if sys.stdout.encoding and sys.stdout.encoding.lower() not in ("utf-8", "utf-8-sig"):
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

SCRIPT_DIR   = Path(__file__).parent
LLD_DIR      = SCRIPT_DIR.parent                               # Atomic/lld/
ROOT         = LLD_DIR.parent.parent                           # project root
MANIFEST_CSV = LLD_DIR / "manifest.csv"
ATTRS_CSV    = LLD_DIR / "atomic_attributes.csv"
ENTITIES_CSV = ROOT / "DataModel" / "working" / "Atomic" / "hld" / "atomic_entities.csv"
OUT_LLD_DIR  = ROOT / "DataModel" / "working" / "Atomic" / "lld"
OUT_MANIFEST = OUT_LLD_DIR / "manifest.yaml"


# ---------------------------------------------------------------------------
# Loaders
# ---------------------------------------------------------------------------

def load_csv(path, encoding="utf-8-sig"):
    with open(path, encoding=encoding, newline="") as f:
        return list(csv.DictReader(f))


def load_entities(path):
    """Dict: entity_name → {bcv_core_object, bcv_concept, table_type, description}"""
    result = {}
    if not path.exists():
        return result
    for row in load_csv(path):
        name = row.get("atomic_entity", "").strip()
        if name:
            result[name] = {
                "bcv_core_object": row.get("bcv_core_object", "Common").strip(),
                "bcv_concept":     row.get("bcv_concept", "").strip() or None,
                "table_type":      row.get("table_type", "Fundamental").strip(),
                "description":     row.get("description", "").strip() or None,
            }
    return result


def load_physical_names(path):
    """Dict: (atomic_entity, attribute_name) → (entity_physical, attr_physical)"""
    result = {}
    entity_physicals = {}  # entity_name → entity_physical_name
    if not path.exists():
        return result, entity_physicals
    for row in load_csv(path):
        ename = row.get("atomic_entity", "").strip()
        aname = row.get("atomic_attribute", "").strip()
        etbl  = row.get("atomic_table", "").strip()
        acol  = row.get("atomic_column", "").strip()
        if ename and aname:
            result[(ename, aname)] = (etbl, acol)
        if ename and etbl:
            entity_physicals.setdefault(ename, etbl)
    return result, entity_physicals


# ---------------------------------------------------------------------------
# YAML helpers
# ---------------------------------------------------------------------------

def yaml_str_value(v):
    """Return a properly quoted YAML scalar for string values."""
    if v is None:
        return "null"
    v = str(v)
    if not v:
        return "null"
    # Characters needing quoting in YAML
    specials = (':', '#', '{', '}', '[', ']', ',', '&', '*', '?', '|',
                '-', '<', '>', '=', '!', '%', '@', '`')
    if any(c in v for c in specials) or v.startswith('"') or "'" in v:
        escaped = v.replace('"', '\\"')
        return f'"{escaped}"'
    # Bare words that need quoting
    if v.lower() in ("true", "false", "null", "yes", "no", "on", "off"):
        return f'"{v}"'
    return v


def bool_yaml(v):
    if isinstance(v, bool):
        return "true" if v else "false"
    return "true" if str(v).strip().lower() == "true" else "false"


def source_cols_yaml(raw_val, indent="    "):
    """Convert single source_columns string → YAML list lines."""
    val = (raw_val or "").strip()
    if not val:
        return "[]"
    # Might have comma-separated (shouldn't, but guard)
    cols = [c.strip() for c in val.split(",") if c.strip()]
    if len(cols) == 1:
        return f"\n{indent}  - {cols[0]}"
    lines = ""
    for c in cols:
        lines += f"\n{indent}  - {c}"
    return lines


def build_lld_yaml(metadata, attrs_rows):
    """
    Build YAML string for lld_*.yaml from:
      metadata: dict with entity info
      attrs_rows: list of dicts from attr_*.csv
    """
    m = metadata
    lines = []
    lines.append("schema_type: lld_source_table")
    lines.append('schema_version: "2.0"')
    lines.append("")
    lines.append("metadata:")
    lines.append(f"  source_system: {m['source_system']}")
    lines.append(f"  source_table: {m['source_table']}")
    lines.append(f"  atomic_entity: {yaml_str_value(m['atomic_entity'])}")
    lines.append(f"  entity_physical_name: {m['entity_physical_name']}")
    lines.append(f"  bcv_core_object: {yaml_str_value(m['bcv_core_object'])}")
    lines.append(f"  bcv_concept: {yaml_str_value(m.get('bcv_concept'))}")
    lines.append(f"  table_type: {yaml_str_value(m.get('table_type'))}")
    lines.append(f"  group: {m['group']}")
    lines.append(f"  design_status: {m['design_status']}")
    lines.append('  version: "1.0"')
    lines.append("  designed_by: null")
    lines.append("  designed_at: null")
    lines.append("  reviewed_by: null")
    lines.append("  reviewed_at: null")
    lines.append("  approved_by: null")
    lines.append("  approved_at: null")
    lines.append("  notes: null")
    lines.append("")
    lines.append("attributes:")

    for row in attrs_rows:
        attr_name = row.get("attribute_name", "").strip()
        desc      = row.get("description", "").strip()
        domain    = row.get("data_domain", "Text").strip()
        nullable  = row.get("nullable", "true").strip()
        is_pk     = row.get("is_primary_key", "false").strip()
        status    = row.get("status", "draft").strip() or "draft"
        src_cols  = row.get("source_columns", "").strip()
        comment   = row.get("comment", "").strip() or None
        ctx       = row.get("classification_context", "").strip() or None
        derived   = row.get("etl_derived_value", "").strip() or None
        phys_name = row.get("_physical_name", None)  # injected by caller

        lines.append(f"  - attribute_name: {yaml_str_value(attr_name)}")
        if phys_name:
            lines.append(f"    physical_name: {phys_name}")
        else:
            lines.append("    physical_name: null")
        lines.append(f"    description: {yaml_str_value(desc) if desc else 'null'}")
        lines.append(f"    data_domain: {yaml_str_value(domain)}")
        lines.append(f"    nullable: {bool_yaml(nullable)}")
        lines.append(f"    is_primary_key: {bool_yaml(is_pk)}")
        lines.append(f"    status: {status if status in ('draft','reviewed','approved','pending') else 'draft'}")

        cols_yaml = source_cols_yaml(src_cols)
        if cols_yaml == "[]":
            lines.append("    source_columns: []")
        else:
            lines.append(f"    source_columns:{cols_yaml}")

        lines.append(f"    comment: {yaml_str_value(comment)}")
        lines.append(f"    classification_context: {yaml_str_value(ctx)}")
        lines.append(f"    etl_derived_value: {yaml_str_value(derived)}")
        lines.append("")

    return "\n".join(lines)


def build_manifest_yaml(entries):
    """Build manifest.yaml content from list of entry dicts."""
    lines = []
    lines.append("schema_type: lld_manifest")
    lines.append('schema_version: "1.0"')
    lines.append("")
    lines.append("entries:")
    for e in entries:
        lines.append(f"  - source_system: {e['source_system']}")
        lines.append(f"    source_table: {e['source_table']}")
        lines.append(f"    atomic_entity: {yaml_str_value(e['atomic_entity'])}")
        lines.append(f"    group: {e['group']}")
        lines.append(f"    lld_file: {e['lld_file']}")
        lines.append(f"    design_status: {e.get('design_status', 'approved')}")
        lines.append("")
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Main migration
# ---------------------------------------------------------------------------

def migrate(source_filter=None, dry_run=False):
    if not MANIFEST_CSV.exists():
        print(f"[ERROR] Không tìm thấy {MANIFEST_CSV}")
        sys.exit(1)

    manifest_rows = load_csv(MANIFEST_CSV)
    entities_meta = load_entities(ENTITIES_CSV)
    phys_map, entity_phys = load_physical_names(ATTRS_CSV)

    if source_filter:
        manifest_rows = [r for r in manifest_rows if r["source_system"].strip() == source_filter]
        if not manifest_rows:
            print(f"[WARN] Không tìm thấy entry nào cho source '{source_filter}' trong manifest.csv")
            return

    manifest_yaml_entries = []
    ok = skipped = err = 0

    for row in manifest_rows:
        source_sys = row["source_system"].strip()
        source_tbl = row["source_table"].strip()
        entity     = row["atomic_entity"].strip()
        group      = row["group"].strip()
        lld_file   = row["lld_file"].strip()

        csv_path = LLD_DIR / source_sys / lld_file
        if not csv_path.exists():
            print(f"[WARN] Không tìm thấy {csv_path.relative_to(ROOT)} — bỏ qua")
            err += 1
            continue

        # Load CSV attributes
        attr_rows = load_csv(csv_path)

        # Inject physical_name from atomic_attributes.csv lookup
        for attr in attr_rows:
            aname = attr.get("attribute_name", "").strip()
            key   = (entity, aname)
            if key in phys_map:
                attr["_physical_name"] = phys_map[key][1]  # atomic_column
            else:
                attr["_physical_name"] = None

        # Entity metadata
        ent_meta   = entities_meta.get(entity, {})
        ent_phys   = entity_phys.get(entity, "")
        bcv_core   = ent_meta.get("bcv_core_object", "Common")
        bcv_concept= ent_meta.get("bcv_concept") or None
        table_type = ent_meta.get("table_type") or "Fundamental"

        if not ent_phys:
            # Derive from lld_file name as fallback (attr_NHNCK_TABLE.csv → from TABLE)
            ent_phys = "unknown"
            print(f"  [WARN] Không tìm được entity_physical_name cho '{entity}' — dùng 'unknown'")

        metadata = {
            "source_system":      source_sys,
            "source_table":       source_tbl,
            "atomic_entity":      entity,
            "entity_physical_name": ent_phys,
            "bcv_core_object":    bcv_core,
            "bcv_concept":        bcv_concept,
            "table_type":         table_type,
            "group":              group,
            "design_status":      "approved",
        }

        yaml_content = build_lld_yaml(metadata, attr_rows)

        # Output file naming:
        # - For shared entity files (IP_Postal, IP_Electronic, IP_Alt_Id):
        #   lld_file has a descriptive suffix → use it directly
        # - For regular files: use source_table as name (avoids duplicate when
        #   two manifest entries share the same attr_*.csv e.g. PROFESSIONALS / PROFESSIONAL_HISTORIES)
        is_shared = any(tag in lld_file for tag in (
            "_IP_Postal_Address", "_IP_Electronic_Address", "_IP_Alt_Identification"
        ))
        if is_shared:
            stem = lld_file.replace("attr_", "lld_").replace(".csv", ".yaml")
        else:
            stem = f"lld_{source_sys}_{source_tbl}.yaml"

        out_file = OUT_LLD_DIR / source_sys / stem

        manifest_yaml_entries.append({
            "source_system": source_sys,
            "source_table":  source_tbl,
            "atomic_entity": entity,
            "group":         group,
            "lld_file":      f"{source_sys}/{stem}",
            "design_status": "approved",
        })

        if dry_run:
            print(f"  [DRY-RUN] {out_file.relative_to(ROOT)}")
            ok += 1
            continue

        # Create output directory
        out_file.parent.mkdir(parents=True, exist_ok=True)

        with open(out_file, "w", encoding="utf-8") as f:
            f.write(yaml_content)

        ok += 1

    # Write manifest.yaml
    manifest_content = build_manifest_yaml(manifest_yaml_entries)
    if dry_run:
        print(f"\n  [DRY-RUN] {OUT_MANIFEST.relative_to(ROOT)}")
        print(f"  [DRY-RUN] {len(manifest_yaml_entries)} entries")
    else:
        OUT_MANIFEST.parent.mkdir(parents=True, exist_ok=True)
        with open(OUT_MANIFEST, "w", encoding="utf-8") as f:
            f.write(manifest_content)
        print(f"\n✓ manifest.yaml: {len(manifest_yaml_entries)} entries → {OUT_MANIFEST.relative_to(ROOT)}")

    # Backup CSV files
    if not dry_run and ok > 0:
        sources_done = set(r["source_system"].strip() for r in manifest_rows)
        for src in sources_done:
            src_dir = LLD_DIR / src
            archive_dir = src_dir / "archive"
            archive_dir.mkdir(exist_ok=True)
            csv_files = list(src_dir.glob("attr_*.csv"))
            for f in csv_files:
                dest = archive_dir / f.name
                if not dest.exists():
                    shutil.copy2(f, dest)
            if csv_files:
                print(f"✓ Backup {len(csv_files)} CSV → {archive_dir.relative_to(ROOT)}/")

    tag = "[DRY-RUN] " if dry_run else ""
    print(f"\n{tag}Kết quả: {ok} files {'sẽ tạo' if dry_run else 'đã tạo'}, {err} bỏ qua.")


def main():
    parser = argparse.ArgumentParser(
        description="Convert attr_*.csv → lld_*.yaml (DataModel/working/Atomic/lld/)"
    )
    parser.add_argument("--source", help="Chỉ migrate source này, VD: NHNCK")
    parser.add_argument("--dry-run", action="store_true", help="Preview — không ghi file")
    args = parser.parse_args()

    print("=" * 60)
    print("migrate_csv_to_yaml.py")
    if args.dry_run:
        print("[DRY-RUN MODE] Không ghi file thực tế")
    print(f"Source filter: {args.source or 'ALL'}")
    print("=" * 60)

    migrate(source_filter=args.source, dry_run=args.dry_run)


if __name__ == "__main__":
    main()
