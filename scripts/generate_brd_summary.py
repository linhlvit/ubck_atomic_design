# -*- coding: utf-8 -*-
"""
generate_brd_summary.py — Generate BRD/Source/_summary.csv

Usage:
    python scripts/generate_brd_summary.py          # generate
    python scripts/generate_brd_summary.py --check  # counts only
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
BRD_DIR = ROOT / "BRD" / "Source"
OUTPUT_PATH = BRD_DIR / "_summary.csv"

COLUMNS = [
    "source", "brd_id", "table", "functional_group",
    "scope_status", "scope_reason", "table_meaning", "notes",
    "ba_email", "steward_email",
]


def collect_rows():
    pattern = str(BRD_DIR / "brd_*.yaml")
    rows, skipped_files = [], []

    for filepath in sorted(glob.glob(pattern)):
        p = Path(filepath)
        try:
            with open(filepath, encoding="utf-8") as f:
                doc = yaml.safe_load(f)
        except Exception as e:
            skipped_files.append((p.name, f"parse error: {e}"))
            continue

        if not isinstance(doc, dict):
            skipped_files.append((p.name, "not a dict"))
            continue

        source = doc.get("source", "")
        entries = doc.get("brd_entries") or []

        for entry in entries:
            content = entry.get("content") or {}
            rows.append({
                "source":           source,
                "brd_id":           entry.get("brd_id", ""),
                "table":            content.get("table", ""),
                "functional_group": content.get("functional_group", ""),
                "scope_status":     content.get("scope_status", ""),
                "scope_reason":     content.get("scope_reason") or "",
                "table_meaning":    content.get("table_meaning", ""),
                "notes":            content.get("notes") or "",
                "ba_email":         entry.get("ba_email", ""),
                "steward_email":    entry.get("steward_email", ""),
            })

    rows.sort(key=lambda r: (r["source"], r["brd_id"]))
    return rows, skipped_files


def write_csv(rows):
    with open(OUTPUT_PATH, "w", encoding="utf-8-sig", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=COLUMNS)
        writer.writeheader()
        writer.writerows(rows)
    rel_path = OUTPUT_PATH.relative_to(ROOT)
    print(f"  Written {len(rows)} rows to {rel_path}")


def print_check(rows):
    from collections import Counter
    by_source = Counter(r["source"] for r in rows)
    in_scope = sum(1 for r in rows if r["scope_status"] == "in_scope")
    print(f"\n{'Source':<16} {'Entries':>7}")
    print("-" * 26)
    for k in sorted(by_source):
        print(f"  {k:<14} {by_source[k]:>7}")
    print(f"  {'TOTAL':<14} {len(rows):>7}")
    print(f"\n  in_scope={in_scope}, out_of_scope={len(rows)-in_scope}\n")


def main():
    parser = argparse.ArgumentParser(description="Generate BRD/Source/_summary.csv")
    parser.add_argument("--check", action="store_true", help="Print counts only; no write")
    args = parser.parse_args()

    print(f"[generate_brd_summary] Scanning {BRD_DIR.relative_to(ROOT)} ...")
    rows, skipped = collect_rows()
    print(f"  Found {len(rows)} brd_entries.")

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
