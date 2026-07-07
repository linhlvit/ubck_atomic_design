"""
ingest_domain_prefix.py
=========================
Script migration MỘT LẦN: đọc `domain_prefix_review.csv` (đã review/sửa tay bởi Data
Modeler — xem propose_domain_prefix.py) và ghi `domain_prefix` + `entity_physical_name`
vào atomic_entities.yaml cho từng entity.

Cách dùng:
  python DataModel/working/Atomic/lld/scripts/ingest_domain_prefix.py
  python DataModel/working/Atomic/lld/scripts/ingest_domain_prefix.py --dry-run
"""

import argparse
import csv
import sys
from pathlib import Path

import yaml

SCRIPT_DIR   = Path(__file__).resolve().parent
LLD_DIR      = SCRIPT_DIR.parent

ATOMIC_ENTITIES = LLD_DIR.parent / "hld" / "atomic_entities.yaml"
REVIEW_CSV      = LLD_DIR / "domain_prefix_review.csv"


class DQDumper(yaml.Dumper):
    pass

def _str_val_representer(dumper, data):
    return dumper.represent_scalar("tag:yaml.org,2002:str", data, style='"')

def _mapping_representer(dumper, data):
    pairs = []
    for k, v in data.items():
        key_node = dumper.represent_scalar("tag:yaml.org,2002:str", k, style=None)
        val_node = dumper.represent_data(v)
        pairs.append((key_node, val_node))
    return yaml.MappingNode("tag:yaml.org,2002:map", pairs)

DQDumper.add_representer(str, _str_val_representer)
DQDumper.add_representer(dict, _mapping_representer)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    with open(REVIEW_CSV, encoding="utf-8-sig", newline="") as f:
        review_rows = {r["atomic_entity"]: r for r in csv.DictReader(f)}
    print(f"Doc {len(review_rows)} dong tu {REVIEW_CSV}", file=sys.stderr)

    data = yaml.safe_load(ATOMIC_ENTITIES.read_text(encoding="utf-8")) or {}
    entities = data.get("entities", [])

    changed = 0
    missing = []
    for e in entities:
        name = e["atomic_entity"]
        row = review_rows.get(name)
        if not row:
            missing.append(name)
            continue
        dp  = row["proposed_domain_prefix"]
        epn = row["proposed_entity_physical_name"]
        if e.get("domain_prefix") != dp or e.get("entity_physical_name") != epn:
            e["domain_prefix"] = dp
            e["entity_physical_name"] = epn
            changed += 1

    if missing:
        print(f"  [WARN] {len(missing)} entity trong atomic_entities.yaml khong co trong review CSV: {missing}", file=sys.stderr)

    print(f"  {changed} entity duoc cap nhat domain_prefix/entity_physical_name", file=sys.stderr)

    if args.dry_run:
        print(yaml.dump(data, Dumper=DQDumper, allow_unicode=True, sort_keys=False, default_flow_style=False))
    else:
        with open(ATOMIC_ENTITIES, "w", encoding="utf-8") as f:
            yaml.dump(data, f, Dumper=DQDumper, allow_unicode=True, sort_keys=False, default_flow_style=False)
        print(f"Da ghi: {ATOMIC_ENTITIES}", file=sys.stderr)


if __name__ == "__main__":
    main()
