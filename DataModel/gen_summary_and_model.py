"""
gen_summary_and_model.py
------------------------
Phase 5: Consolidate DataModel YAML files into:
  - DataModel/Atomic/dm_manifest.yaml (13-column index)
  - DataModel/atomic_model.yaml       (consolidated per-entity, all sources)

Usage:
  python DataModel/gen_summary_and_model.py [--source NHNCK] [--dry-run]

  --source: optional filter for dm_manifest.yaml rows only.
            atomic_model.yaml always consolidates ALL sources.
"""

import argparse
import collections
import os
import sys
from pathlib import Path

import yaml

ROOT       = Path(__file__).resolve().parent.parent
ATOMIC_DIR = ROOT / "DataModel" / "Atomic"
SUMMARY_OUT = ATOMIC_DIR / "dm_manifest.yaml"
MODEL_OUT   = ROOT / "DataModel" / "atomic_model.yaml"

SUMMARY_COLS = [
    "subfolder", "file_name", "id", "physical_name", "logical_name",
    "bcv_core_object", "bcv_concept", "table_type", "etl_pattern",
    "source", "status", "attribute_count", "brd_ref",
]

# Entity-level fields reviewed for conflict (excludes description, owner)
ENTITY_CONFLICT_FIELDS = [
    "logical_name", "physical_name", "layer", "version", "status",
    "bcv_core_object", "bcv_concept", "table_type", "etl_pattern",
]

# Attribute-level fields reviewed for conflict (excludes business_meaning, comment)
ATTR_CONFLICT_FIELDS = ["data_domain", "data_type", "nullable", "is_primary_key"]


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--source", help="Filter dm_manifest.yaml rows to this source only")
    p.add_argument("--dry-run", action="store_true", help="Print counts, write nothing")
    return p.parse_args()


def load_yaml_files():
    """Yield (subdir_name, filepath, parsed_doc) for every *.yaml in ATOMIC_DIR subdirs."""
    for subdir in sorted(ATOMIC_DIR.iterdir()):
        if not subdir.is_dir():
            continue
        for yf in sorted(subdir.glob("*.yaml")):
            with open(yf, encoding="utf-8") as f:
                try:
                    doc = yaml.safe_load(f.read())
                except yaml.YAMLError as e:
                    print(f"ERROR parsing {yf.relative_to(ROOT)}: {e}", file=sys.stderr)
                    sys.exit(1)
            yield subdir.name, yf, doc


def build_summary_row(subdir_name, yf, doc):
    ldm   = doc.get("ldm", {})
    attrs = doc.get("attributes", [])
    refs  = ldm.get("references") or {}
    return {
        "subfolder":       subdir_name,
        "file_name":       yf.name,
        "id":              ldm.get("id", ""),
        "physical_name":   ldm.get("physical_name", ""),
        "logical_name":    ldm.get("logical_name", ""),
        "bcv_core_object": ldm.get("bcv_core_object", ""),
        "bcv_concept":     ldm.get("bcv_concept", ""),
        "table_type":      ldm.get("table_type", ""),
        "etl_pattern":     ldm.get("etl_pattern", ""),
        "source":          ldm.get("source", ""),
        "status":          ldm.get("status", ""),
        "attribute_count": len(attrs),
        "brd_ref":         refs.get("brd", ""),
    }


def majority(values):
    """Return the most common non-None value in list; None if all None."""
    counts = collections.Counter(v for v in values if v is not None)
    if not counts:
        return None
    return counts.most_common(1)[0][0]


def conflict_review_entity(ldm_list):
    """
    Compare entity-level technical fields across all source LDM dicts.
    Returns a conflict string if any field has >1 distinct value, else None.
    """
    conflicts = []
    for field in ENTITY_CONFLICT_FIELDS:
        values = list({ldm.get(field) for ldm in ldm_list if ldm.get(field) is not None})
        if len(values) > 1:
            conflicts.append(f"{field}: {values}")
    return "; ".join(conflicts) if conflicts else None


def conflict_review_attr(occurrences):
    """
    Compare attribute-level technical fields across all occurrences.
    occurrences: list of attribute dicts from source yaml files.
    Returns a conflict string if any field has >1 distinct value, else None.
    """
    conflicts = []
    for field in ATTR_CONFLICT_FIELDS:
        values = list({a.get(field) for a in occurrences if a.get(field) is not None})
        if len(values) > 1:
            conflicts.append(f"{field}: {values}")
    return "; ".join(conflicts) if conflicts else None


def consolidate_etl_derived(values):
    """
    Collect all distinct non-null etl_derived_value values from occurrences.
    Returns scalar if 1 value, array if >1, None if all null.
    Converts non-string scalars to string for consistency in array output.
    """
    seen = []
    seen_set = set()
    for v in values:
        if v is None:
            continue
        key = str(v)
        if key not in seen_set:
            seen_set.add(key)
            seen.append(v)
    if not seen:
        return None
    if len(seen) == 1:
        return seen[0]
    # Multiple distinct values → array of strings
    return [str(v) for v in seen]


def build_consolidated_entity(physical_name, docs_for_entity):
    """
    Consolidate multiple dm_atm_*.yaml docs (all sharing the same physical_name)
    into a single entity dict for atomic_model.yaml.

    docs_for_entity: list of (source_system, source_table, ldm_dict, attributes_list)
    """
    ldm_list = [d[2] for d in docs_for_entity]
    first_ldm = ldm_list[0]

    # --- Build ldm ---
    sources = []
    seen_sources = set()
    for source_system, _, _, _ in docs_for_entity:
        if source_system not in seen_sources:
            seen_sources.add(source_system)
            sources.append(source_system)

    # BRD refs: flatten + dedup, preserve order
    brd_refs = []
    seen_brd = set()
    for _, _, ldm, _ in docs_for_entity:
        refs = ldm.get("references") or {}
        brd = refs.get("brd")
        if brd is None:
            continue
        if isinstance(brd, str):
            brd = [brd]
        for ref in brd:
            if ref not in seen_brd:
                seen_brd.add(ref)
                brd_refs.append(ref)

    consolidated_ldm = {
        "id": f"ATM-{physical_name}",
        "logical_name_1st":     first_ldm.get("logical_name"),
        "physical_name_1st":    physical_name,
        "layer_1st":            first_ldm.get("layer", "Atomic"),
        "version_1st":          first_ldm.get("version"),
        "status_1st":           first_ldm.get("status"),
        "description_1st":      (first_ldm.get("description") or "").strip(),
        "owner_1st":            first_ldm.get("owner"),
        "bcv_core_object_most": majority([l.get("bcv_core_object") for l in ldm_list]),
        "bcv_concept_most":     majority([l.get("bcv_concept") for l in ldm_list]),
        "table_type_most":      majority([l.get("table_type") for l in ldm_list]),
        "etl_pattern_most":     majority([l.get("etl_pattern") for l in ldm_list]),
        "conflict_review":      conflict_review_entity(ldm_list),
        "sources":              sources,
    }
    if brd_refs:
        consolidated_ldm["references"] = {"brd": brd_refs}

    # --- Build attributes ---
    # Grain: (name, physical_name) — unique per entity after consolidation.
    # Collect all occurrences keyed by (name, physical_name).
    # Each occurrence carries: source_system, source_table, source_column,
    # business_meaning, comment, data_domain, data_type, nullable,
    # is_primary_key, etl_derived_value.

    # Ordered dict to preserve first-seen order of (name, physical_name)
    attr_occurrences = collections.OrderedDict()  # key → list of occurrence dicts

    for source_system, source_table, _, attributes in docs_for_entity:
        for a in attributes:
            key = (a.get("name", ""), a.get("physical_name", ""))
            if key not in attr_occurrences:
                attr_occurrences[key] = []
            attr_occurrences[key].append({
                "source_system":   source_system,
                "source_table":    source_table,
                "source_column":   a.get("source_column"),
                "business_meaning": a.get("business_meaning"),
                "comment":         a.get("comment"),
                "data_domain":     a.get("data_domain"),
                "data_type":       a.get("data_type"),
                "nullable":        a.get("nullable"),
                "is_primary_key":  a.get("is_primary_key"),
                "etl_derived_value": a.get("etl_derived_value"),
            })

    consolidated_attrs = []
    for (name, phys_name), occs in attr_occurrences.items():
        first = occs[0]

        # Build source_mappings: group by source_system.
        # Dedup by (source_system, source_table, source_column, etl_derived_value) so that:
        # - attributes with multiple source columns per table are preserved (e.g. ip_elc_adr
        #   Electronic Address Value: PHONE_NUMBER, EMAIL, FAX all from UNITS)
        # - Classification Value attributes with source_column=null but different
        #   etl_derived_value are also preserved (e.g. Electronic Address Type Code:
        #   EMAIL, FAX, PHONE all from UNITS with source_column=null)
        sm_dict = collections.OrderedDict()  # source_system → list of entries
        seen_sm = set()                       # dedup key: (ss, st, source_column, etl_derived_value)
        for occ in occs:
            ss = occ["source_system"]
            st = occ["source_table"]
            sc = occ["source_column"]
            dedup_key = (ss, st, sc, occ["etl_derived_value"])
            if dedup_key in seen_sm:
                continue
            seen_sm.add(dedup_key)
            if ss not in sm_dict:
                sm_dict[ss] = []
            sm_dict[ss].append({
                "source_table":     st,
                "source_column":    sc,
                "business_meaning": occ["business_meaning"],
                "comment":          occ["comment"],
            })

        source_mappings = [
            {
                "source_system": ss,
                "source_tables": tables,
            }
            for ss, tables in sm_dict.items()
        ]

        attr_dict = {
            "name":               name,
            "physical_name":      phys_name,
            "business_meaning_1st": first["business_meaning"],
            "comment_1st":        first["comment"],
            "data_domain_most":   majority([o["data_domain"] for o in occs]),
            "data_type_most":     majority([o["data_type"] for o in occs]),
            "nullable_most":      majority([o["nullable"] for o in occs]),
            "is_primary_key_most": majority([o["is_primary_key"] for o in occs]),
            "etl_derived_value":  consolidate_etl_derived([o["etl_derived_value"] for o in occs]),
            "conflict_review":    conflict_review_attr(occs),
            "source_mappings":    source_mappings,
        }
        consolidated_attrs.append(attr_dict)

    return {"ldm": consolidated_ldm, "attributes": consolidated_attrs}


def main():
    args = parse_args()

    all_rows = []
    # group_by_physical: physical_name → list of (source_system, source_table, ldm, attrs)
    group_by_physical = collections.OrderedDict()

    for subdir_name, yf, doc in load_yaml_files():
        all_rows.append(build_summary_row(subdir_name, yf, doc))

        ldm = doc.get("ldm", {})
        physical_name = ldm.get("physical_name", "")
        source_system = ldm.get("source", "")
        # source_table: derive from file name suffix (e.g. "dm_atm_ip_elc_adr-NHNCK.ORGANIZATIONS.yaml")
        stem = yf.stem  # "dm_atm_ip_elc_adr-NHNCK.ORGANIZATIONS"
        if "." in stem:
            source_table = stem.rsplit(".", 1)[-1]
        else:
            source_table = stem

        attrs = doc.get("attributes", [])

        if physical_name not in group_by_physical:
            group_by_physical[physical_name] = []
        group_by_physical[physical_name].append(
            (source_system, source_table, ldm, attrs)
        )

    # Build consolidated entities
    entities = []
    for physical_name, docs_for_entity in group_by_physical.items():
        entities.append(build_consolidated_entity(physical_name, docs_for_entity))

    # Filter summary rows by source if requested
    summary_rows = all_rows
    if args.source:
        summary_rows = [r for r in all_rows if r["source"] == args.source]

    print(f"Total YAML files  : {len(all_rows)}")
    print(f"Distinct entities : {len(entities)}")
    print(f"dm_manifest.yaml rows : {len(summary_rows)}"
          + (f" (source={args.source})" if args.source else ""))

    if args.dry_run:
        print("(dry-run — nothing written)")
        return

    # Write dm_manifest.yaml
    manifest_doc = {
        "schema_type":    "dm_manifest",
        "schema_version": "1.0",
        "entries":        summary_rows,
    }
    with open(SUMMARY_OUT, "w", encoding="utf-8") as f:
        yaml.dump(manifest_doc, f, allow_unicode=True, sort_keys=False, default_flow_style=False)
    print(f"Written: {SUMMARY_OUT.relative_to(ROOT)}")

    # Write atomic_model.yaml (all sources, consolidated)
    model = {
        "schema_type":    "atomic_model",
        "schema_version": "1.0",
        "entities":       entities,
    }
    with open(MODEL_OUT, "w", encoding="utf-8") as f:
        yaml.dump(model, f, allow_unicode=True, sort_keys=False, default_flow_style=False)
    print(f"Written: {MODEL_OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
