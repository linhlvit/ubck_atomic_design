"""
gen_summary_and_model.py
------------------------
Phase 5: Consolidate DataModel YAML files into:
  - DataModel/Atomic/_summary.csv   (13-column index, UTF-8 with BOM)
  - DataModel/atomic_model.yaml     (consolidated, all sources)

Usage:
  python DataModel/gen_summary_and_model.py [--source NHNCK]

  --source: optional filter for _summary.csv rows (atomic_model.yaml always
            includes all sources found in DataModel/Atomic/)
"""

import argparse
import csv
import os
import sys
from pathlib import Path

import yaml

ROOT       = Path(__file__).resolve().parent.parent
ATOMIC_DIR = ROOT / "DataModel" / "Atomic"
SUMMARY_OUT = ATOMIC_DIR / "_summary.csv"
MODEL_OUT   = ROOT / "DataModel" / "atomic_model.yaml"

SUMMARY_COLS = [
    "subfolder", "file_name", "id", "physical_name", "logical_name",
    "bcv_core_object", "bcv_concept", "table_type", "etl_pattern",
    "source", "status", "attribute_count", "brd_ref",
]


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--source", help="Filter _summary.csv rows to this source only")
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


def main():
    args = parse_args()

    all_rows   = []
    all_docs   = []

    for subdir_name, yf, doc in load_yaml_files():
        all_rows.append(build_summary_row(subdir_name, yf, doc))
        all_docs.append(doc)

    # Filter summary rows by source if requested
    summary_rows = all_rows
    if args.source:
        summary_rows = [r for r in all_rows if r["source"] == args.source]

    print(f"Total YAML files  : {len(all_docs)}")
    print(f"_summary.csv rows : {len(summary_rows)}"
          + (f" (source={args.source})" if args.source else ""))
    print(f"atomic_model.yaml : {len(all_docs)} entities")

    if args.dry_run:
        print("(dry-run — nothing written)")
        return

    # Write _summary.csv (UTF-8 with BOM)
    with open(SUMMARY_OUT, "w", encoding="utf-8-sig", newline="") as f:
        w = csv.DictWriter(f, fieldnames=SUMMARY_COLS)
        w.writeheader()
        w.writerows(summary_rows)
    print(f"Written: {SUMMARY_OUT.relative_to(ROOT)}")

    # Write atomic_model.yaml (all sources)
    model = {
        "schema_type":    "atomic_model",
        "schema_version": "1.0",
        "entities":       all_docs,
    }
    with open(MODEL_OUT, "w", encoding="utf-8") as f:
        yaml.dump(model, f, allow_unicode=True, sort_keys=False, default_flow_style=False)
    print(f"Written: {MODEL_OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
