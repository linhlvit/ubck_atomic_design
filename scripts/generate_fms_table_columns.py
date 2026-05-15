# -*- coding: utf-8 -*-
"""
generate_fms_table_columns.py — Sinh BRD/Source/FMS/*.yaml từ Source/FMS_Columns.csv

Usage:
    python scripts/generate_fms_table_columns.py
    python scripts/generate_fms_table_columns.py --dry-run
"""
import argparse
import csv
import sys
from pathlib import Path
from collections import defaultdict

try:
    import yaml
except ImportError:
    print("ERROR: pip install pyyaml")
    sys.exit(1)

ROOT = Path(__file__).parent.parent
CSV_PATH = ROOT / "Source" / "FMS_Columns.csv"
OUT_DIR = ROOT / "BRD" / "Source" / "FMS"

KEY_MAP = {"PK": "PK", "FK": "FK", "PK/FK": "PK/FK"}


def load_csv():
    tables = defaultdict(list)
    with open(CSV_PATH, encoding="utf-8-sig") as f:
        for row in csv.DictReader(f):
            tbl = row["Tên bảng"].strip()
            tables[tbl].append({
                "name": row["Tên trường"].strip(),
                "data_type": row["Kiểu dữ liệu"].strip(),
                "description": row["Mô tả"].strip(),
                "key": KEY_MAP.get(row["Khóa"].strip()) or None,
                "fk_note": row["Ghi chú (FK suy luận)"].strip() or None,
            })
    return tables


def build_doc(source, table, columns):
    return {
        "schema_type": "brd_source_columns",
        "schema_version": "1.0",
        "source": source,
        "table": table,
        "brd_ref": f"BRD-SRC-{source}-{table}",
        "columns": columns,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    tables = load_csv()
    if not args.dry_run:
        OUT_DIR.mkdir(parents=True, exist_ok=True)

    for tbl, cols in sorted(tables.items()):
        doc = build_doc("FMS", tbl, cols)
        out_path = OUT_DIR / f"brd_FMS_{tbl}.yaml"
        if not args.dry_run:
            with open(out_path, "w", encoding="utf-8") as f:
                yaml.dump(doc, f, allow_unicode=True,
                          default_flow_style=False, sort_keys=False)
        print(f"  {'[DRY]' if args.dry_run else '[OK] '} {out_path.name} ({len(cols)} cols)")

    action = "Would create" if args.dry_run else "Created"
    print(f"\n[generate_fms_table_columns] {action} {len(tables)} files in BRD/Source/FMS/ (brd_FMS_*.yaml)")


if __name__ == "__main__":
    main()
