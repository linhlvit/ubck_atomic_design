"""
generate_entity_consolidation.py
=================================
Sinh file entity_*.yaml (Level 2 consolidation) cho các Atomic entity
đến từ nhiều source tables.

Luồng:
  1. Đọc DataModel/working/Atomic/lld/manifest.yaml → tìm entity có ≥ 2 sources
  2. Với mỗi multi-source entity: đọc tất cả lld_*.yaml liên quan
  3. Build union attribute list (key = attribute_name + classification_context)
  4. Xây source_mappings và phát hiện inconsistency → consolidation_notes
  5. Ghi DataModel/working/Atomic/lld/entities/entity_{physical_name}.yaml
     - Nếu file đã có với consolidation_status=approved → SKIP
     - Nếu pending/không có → ghi đè

Cách dùng:
  python DataModel/working/Atomic/lld/scripts/generate_entity_consolidation.py
  python DataModel/working/Atomic/lld/scripts/generate_entity_consolidation.py --entity "Securities Practitioner"
  python DataModel/working/Atomic/lld/scripts/generate_entity_consolidation.py --dry-run
"""

import sys
import io
import argparse
import csv
import yaml as _yaml
from pathlib import Path
from collections import OrderedDict
from typing import Optional

# Fix encoding trên Windows terminal
if sys.stdout.encoding and sys.stdout.encoding.lower() not in ("utf-8", "utf-8-sig"):
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
SCRIPT_DIR    = Path(__file__).parent
LLD_DIR       = SCRIPT_DIR.parent
ROOT          = LLD_DIR.parent.parent.parent.parent
MANIFEST_YAML = LLD_DIR / "manifest.yaml"
ENTITIES_DIR  = LLD_DIR / "entities"
ENTITIES_CSV  = ROOT / "DataModel" / "working" / "Atomic" / "hld" / "atomic_entities.csv"

# addr-type schemes — attr có context này được phân biệt theo context (không chỉ tên)
ADDR_SCHEMES = ("IP_ADDR_TYPE=", "IP_ALT_ID_TYPE=", "IP_ELEC_ADDR_TYPE=")

# SOURCE_SYSTEM= dùng để nhận biết Source System Code, không phải addr-type
SOURCE_SYSTEM_SCHEME = "SOURCE_SYSTEM="


# ---------------------------------------------------------------------------
# Loaders
# ---------------------------------------------------------------------------

def load_yaml(path: Path) -> dict:
    return _yaml.safe_load(path.read_text(encoding="utf-8")) or {}


def load_manifest() -> list:
    if not MANIFEST_YAML.exists():
        print(f"[ERROR] Không tìm thấy {MANIFEST_YAML.relative_to(ROOT)}")
        sys.exit(1)
    data = load_yaml(MANIFEST_YAML)
    return data.get("entries", [])


def load_atomic_entities() -> dict:
    """Dict: entity_name → {bcv_core_object, bcv_concept, table_type, etl_pattern, description}"""
    result = {}
    if not ENTITIES_CSV.exists():
        return result
    with open(ENTITIES_CSV, encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            name = row.get("atomic_entity", "").strip()
            if name:
                result[name] = {
                    "bcv_core_object": row.get("bcv_core_object", "").strip(),
                    "bcv_concept":     row.get("bcv_concept", "").strip() or None,
                    "table_type":      row.get("table_type", "Fundamental").strip(),
                    "description":     row.get("description", "").strip() or None,
                }
    return result


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _is_addr_ctx(ctx: Optional[str]) -> bool:
    """True nếu classification_context là addr-type (không phải SOURCE_SYSTEM)."""
    if not ctx:
        return False
    return any(ctx.startswith(s) for s in ADDR_SCHEMES)


def _attr_key(attr: dict) -> tuple:
    """Key để merge attributes: (attribute_name, addr_context_or_None)."""
    name = attr.get("attribute_name", "")
    ctx  = (attr.get("classification_context") or "").strip()
    # Source System Code: context khác nhau mỗi source nhưng là cùng attribute
    if ctx.startswith(SOURCE_SYSTEM_SCHEME):
        return (name, None)
    return (name, ctx if _is_addr_ctx(ctx) else None)


def _first_source_column(attr: dict) -> Optional[str]:
    """Lấy source_column đầu tiên (string) hoặc None."""
    cols = attr.get("source_columns") or []
    if isinstance(cols, list):
        return cols[0] if cols else None
    return str(cols) if cols else None


def _etl_derived(attr: dict) -> Optional[str]:
    v = attr.get("etl_derived_value")
    if v is None or v == "":
        return None
    return str(v)


def _nullable(attr: dict) -> bool:
    v = attr.get("nullable")
    if isinstance(v, bool):
        return v
    return str(v).strip().lower() == "true"


# ---------------------------------------------------------------------------
# Build consolidated attribute list
# ---------------------------------------------------------------------------

def consolidate_attrs(entity_name: str, sources: list) -> tuple:
    """
    Returns: (master_attrs, notes)
      master_attrs: OrderedDict[(attr_name, addr_ctx)] → merged metadata dict
                    với extra key '_source_mappings' và '_missing_in'
      notes: list of str
    """
    # Step 1: load all lld_*.yaml attrs per source
    source_attrs: dict = {}  # (src_sys, src_tbl) → list[attr_dict]
    for src in sources:
        lld_path = LLD_DIR / src["lld_file"]
        if not lld_path.exists():
            print(f"  [WARN] Không tìm thấy {src['lld_file']}")
            source_attrs[(src["source_system"], src["source_table"])] = []
            continue
        data = load_yaml(lld_path)
        source_attrs[(src["source_system"], src["source_table"])] = data.get("attributes", [])

    # Step 2: build master — union theo thứ tự xuất hiện đầu tiên
    master: OrderedDict = OrderedDict()
    # Track which sources define each key
    key_sources: dict = {}  # key → set of (src_sys, src_tbl)

    for src in sources:
        sk = (src["source_system"], src["source_table"])
        for attr in source_attrs.get(sk, []):
            k = _attr_key(attr)
            if k not in master:
                master[k] = dict(attr)
                key_sources[k] = set()
            else:
                existing = master[k]
                # description: chọn dài hơn
                if len(attr.get("description", "") or "") > len(existing.get("description", "") or ""):
                    existing["description"] = attr["description"]
                # nullable: conservative (true wins)
                if _nullable(attr):
                    existing["nullable"] = True
            key_sources[k].add(sk)

    # Step 3: build source_mappings và detect missing
    all_src_keys = [(s["source_system"], s["source_table"]) for s in sources]

    notes = []

    for k, meta in master.items():
        attr_name, addr_ctx = k
        src_map = {}

        for src in sources:
            sk = (src["source_system"], src["source_table"])
            src_label = f"{sk[0]}.{sk[1]}"

            # Find matching attr in this source
            matched = None
            for attr in source_attrs.get(sk, []):
                if _attr_key(attr) == k:
                    matched = attr
                    break

            if matched is None:
                src_map[src_label] = None
                # Mark nullable
                if not _nullable(meta):
                    meta["nullable"] = True
                    notes.append(
                        f"⚠️ {src_label}: thiếu attribute '{attr_name}'"
                        + (f" (ctx={addr_ctx})" if addr_ctx else "")
                        + " — đặt nullable=true"
                    )
            else:
                col = _first_source_column(matched)
                src_map[src_label] = col

        meta["_source_mappings"] = src_map

        # Check domain mismatch between sources that do have this attr
        domains = set()
        for attr in [a for sk_list in source_attrs.values() for a in sk_list
                     if _attr_key(a) == k]:
            d = attr.get("data_domain", "")
            if d:
                domains.add(d)
        if len(domains) > 1:
            notes.append(
                f"⚠️ data_domain mismatch cho '{attr_name}'"
                + (f" (ctx={addr_ctx})" if addr_ctx else "")
                + f": {' vs '.join(sorted(domains))}"
            )

        # Check physical_name mismatch
        phys_names = set()
        for attr in [a for sk_list in source_attrs.values() for a in sk_list
                     if _attr_key(a) == k]:
            p = attr.get("physical_name")
            if p:
                phys_names.add(p)
        if len(phys_names) > 1:
            notes.append(
                f"⚠️ physical_name mismatch cho '{attr_name}'"
                + (f" (ctx={addr_ctx})" if addr_ctx else "")
                + f": {', '.join(sorted(phys_names))}"
            )

    return master, notes


# ---------------------------------------------------------------------------
# YAML builder — minimal serialization
# ---------------------------------------------------------------------------

def _qs(v) -> str:
    """YAML safe scalar."""
    if v is None:
        return "null"
    s = str(v)
    if not s:
        return "null"
    specials = (':', '#', '{', '}', '[', ']', ',', '&', '*', '?', '|',
                '-', '<', '>', '=', '!', '%', '@', '`')
    if any(c in s for c in specials) or s.startswith('"') or "'" in s:
        return '"' + s.replace('\\', '\\\\').replace('"', '\\"') + '"'
    if s.lower() in ("true", "false", "null", "yes", "no", "on", "off"):
        return f'"{s}"'
    return s


def _bool_s(v) -> str:
    if isinstance(v, bool):
        return "true" if v else "false"
    return "true" if str(v).strip().lower() == "true" else "false"


def build_entity_yaml(entity_name: str,
                      physical_name: str,
                      entity_meta: dict,
                      sources: list,
                      master_attrs: OrderedDict,
                      notes: list) -> str:
    lines = []
    lines.append("schema_type: entity_consolidation")
    lines.append('schema_version: "1.0"')
    lines.append("")
    lines.append("entity:")
    lines.append(f"  entity_name: {_qs(entity_name)}")
    lines.append(f"  physical_name: {physical_name}")
    lines.append(f"  bcv_core_object: {_qs(entity_meta.get('bcv_core_object', ''))}")
    lines.append(f"  bcv_concept: {_qs(entity_meta.get('bcv_concept'))}")
    lines.append(f"  table_type: {_qs(entity_meta.get('table_type', 'Fundamental'))}")
    # etl_pattern: derive from table_type
    tt = entity_meta.get("table_type", "Fundamental")
    etl_map = {
        "Fundamental": "SCD4A", "Relative": "SCD2",
        "Fact Append": "Fact Append", "Fact Snapshot": "Fact Snapshot",
        "Classification": "Upsert",
    }
    lines.append(f"  etl_pattern: {etl_map.get(tt, 'SCD4A')}")
    lines.append("  consolidation_status: pending")
    lines.append("  consolidated_by: null")
    lines.append("  consolidated_at: null")
    lines.append("")

    lines.append("sources:")
    for src in sources:
        lines.append(f"  - source_system: {src['source_system']}")
        lines.append(f"    source_table: {src['source_table']}")
        lines.append(f"    lld_file: {src['lld_file']}")
    lines.append("")

    lines.append("consolidation_notes:")
    if notes:
        for n in notes:
            lines.append(f'  - "{n}"')
    else:
        lines.append("  []")
    lines.append("")

    lines.append("attributes:")
    for (attr_name, addr_ctx), meta in master_attrs.items():
        src_map = meta.get("_source_mappings", {})
        ctx     = (meta.get("classification_context") or "").strip()
        # Normalize SOURCE_SYSTEM context to generic marker
        if ctx.startswith(SOURCE_SYSTEM_SCHEME):
            ctx = "SOURCE_SYSTEM=..."

        lines.append(f"  - attribute_name: {_qs(attr_name)}")
        lines.append(f"    physical_name: {_qs(meta.get('physical_name'))}")
        lines.append(f"    description: {_qs(meta.get('description'))}")
        lines.append(f"    data_domain: {_qs(meta.get('data_domain', 'Text'))}")
        lines.append(f"    nullable: {_bool_s(meta.get('nullable', True))}")
        lines.append(f"    is_primary_key: {_bool_s(meta.get('is_primary_key', False))}")
        lines.append(f"    comment: {_qs(meta.get('comment'))}")
        lines.append(f"    classification_context: {_qs(ctx if ctx else None)}")
        lines.append(f"    etl_derived_value: {_qs(_etl_derived(meta))}")
        lines.append("    source_mappings:")
        for src_label, col_val in src_map.items():
            lines.append(f"      {src_label}: {_qs(col_val)}")
        lines.append("")

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Sinh entity_*.yaml cho multi-source entities")
    parser.add_argument("--entity",   help="Chỉ xử lý entity cụ thể, VD: 'Securities Practitioner'")
    parser.add_argument("--dry-run",  action="store_true", help="Preview — không ghi file")
    parser.add_argument("--force",    action="store_true", help="Ghi đè kể cả khi đã approved")
    args = parser.parse_args()

    manifest_entries = load_manifest()
    entity_meta_map  = load_atomic_entities()

    # Group entries theo atomic_entity
    from collections import defaultdict
    entity_groups: dict = defaultdict(list)
    for e in manifest_entries:
        entity_groups[e["atomic_entity"]].append(e)

    if args.entity:
        if args.entity not in entity_groups:
            print(f"[ERROR] Entity '{args.entity}' không có trong manifest.")
            sys.exit(0)
        entity_groups = {args.entity: entity_groups[args.entity]}

    if not entity_groups:
        print("Không tìm thấy entity nào trong manifest.")
        return

    multi_count  = sum(1 for v in entity_groups.values() if len(v) >= 2)
    single_count = len(entity_groups) - multi_count
    print(f"Tìm thấy {len(entity_groups)} entity "
          f"({multi_count} multi-source, {single_count} single-source):\n")
    multi_source = entity_groups

    created = skipped = errors = 0

    for entity_name, sources in sorted(multi_source.items()):
        print(f"  [{entity_name}] — {len(sources)} sources")
        for s in sources:
            print(f"    • {s['source_system']}.{s['source_table']} ({s['lld_file']})")

        # Get physical_name từ lld_*.yaml đầu tiên
        first_lld = LLD_DIR / sources[0]["lld_file"]
        if not first_lld.exists():
            print(f"  [ERROR] Không tìm thấy {sources[0]['lld_file']}")
            errors += 1
            continue
        first_data = load_yaml(first_lld)
        physical_name = first_data.get("metadata", {}).get("entity_physical_name", "")
        if not physical_name:
            print(f"  [ERROR] Không có entity_physical_name trong {sources[0]['lld_file']}")
            errors += 1
            continue

        out_path = ENTITIES_DIR / f"entity_{physical_name}.yaml"

        # Lock check
        if out_path.exists() and not args.force:
            existing = load_yaml(out_path)
            status = existing.get("entity", {}).get("consolidation_status", "pending")
            if status == "approved":
                print(f"  ⛔ SKIP — đã approved: {out_path.relative_to(ROOT)}")
                skipped += 1
                continue

        entity_meta = entity_meta_map.get(entity_name, {})
        master_attrs, notes = consolidate_attrs(entity_name, sources)

        yaml_content = build_entity_yaml(
            entity_name=entity_name,
            physical_name=physical_name,
            entity_meta=entity_meta,
            sources=sources,
            master_attrs=master_attrs,
            notes=notes,
        )

        if dry_run := args.dry_run:
            print(f"  [DRY-RUN] → {out_path.relative_to(ROOT)}")
            print(f"    {len(master_attrs)} attributes, {len(notes)} notes")
        else:
            ENTITIES_DIR.mkdir(parents=True, exist_ok=True)
            out_path.write_text(yaml_content, encoding="utf-8")
            print(f"  ✓ → {out_path.relative_to(ROOT)}")
            print(f"    {len(master_attrs)} attributes, {len(notes)} consolidation notes")

        created += 1
        print()

    tag = "[DRY-RUN] " if args.dry_run else ""
    print(f"{tag}Kết quả: {created} files {'sẽ tạo' if args.dry_run else 'đã tạo'}, "
          f"{skipped} skipped (approved), {errors} lỗi.")


if __name__ == "__main__":
    main()
