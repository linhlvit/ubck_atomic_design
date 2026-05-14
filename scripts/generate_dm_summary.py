# -*- coding: utf-8 -*-
"""
generate_dm_summary.py — Generate DataModel/Atomic/_summary.csv

Usage:
    python scripts/generate_dm_summary.py          # generate summary
    python scripts/generate_dm_summary.py --check  # print counts only, no write
"""

import argparse
import csv
import glob
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("ERROR: PyYAML not installed. Run: pip install pyyaml")
    sys.exit(1)

ROOT = Path(__file__).parent.parent
ATOMIC_DIR = ROOT / "DataModel" / "Atomic"
OUTPUT_PATH = ATOMIC_DIR / "_summary.csv"

COLUMNS = [
    "subfolder", "file_name", "id", "physical_name", "logical_name",
    "bcv_core_object", "bcv_concept", "table_type", "etl_pattern",
    "source", "status", "attribute_count", "brd_ref",
]


def collect_rows():
    pattern = str(ATOMIC_DIR / "**" / "*.yaml")
    rows, skipped = [], []

    for filepath in sorted(glob.glob(pattern, recursive=True)):
        p = Path(filepath)
        try:
            with open(filepath, encoding="utf-8") as f:
                doc = yaml.safe_load(f)
        except Exception as e:
            skipped.append((p.name, f"parse error: {e}"))
            continue

        if not isinstance(doc, dict) or doc.get("schema_type") != "data_model":
            skipped.append((p.name, f"schema_type={doc.get('schema_type') if isinstance(doc, dict) else '?'}"))
            continue

        ldm = doc.get("ldm") or {}
        refs = ldm.get("references") or {}
        attrs = doc.get("attributes") or []

        rows.append({
            "subfolder":       p.parent.name,
            "file_name":       p.name,
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
        })

    rows.sort(key=lambda r: (r["subfolder"], r["file_name"]))
    return rows, skipped


def write_csv(rows):
    with open(OUTPUT_PATH, "w", encoding="utf-8-sig", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=COLUMNS)
        writer.writeheader()
        writer.writerows(rows)
    rel_path = OUTPUT_PATH.relative_to(ROOT)
    print(f"  Written {len(rows)} rows to {rel_path}")


def print_check(rows):
    from collections import Counter
    by_sub = Counter(r["subfolder"] for r in rows)
    print(f"\n{'Subfolder':<22} {'Count':>5}")
    print("-" * 30)
    for k in sorted(by_sub):
        print(f"  {k:<20} {by_sub[k]:>5}")
    print(f"  {'TOTAL':<20} {len(rows):>5}\n")


def main():
    parser = argparse.ArgumentParser(description="Generate DataModel/Atomic/_summary.csv")
    parser.add_argument("--check", action="store_true", help="Print counts only; no write")
    args = parser.parse_args()

    print(f"[generate_dm_summary] Scanning {ATOMIC_DIR.relative_to(ROOT)} ...")
    rows, skipped = collect_rows()
    print(f"  Found {len(rows)} DM YAML files.")

    if skipped:
        print(f"  WARN: {len(skipped)} files skipped:")
        for name, reason in skipped:
            print(f"    {name}: {reason}")

    print_check(rows)

    if not args.check:
        write_csv(rows)
    else:
        print("  --check mode: CSV not written.")


if __name__ == "__main__":
    main()
