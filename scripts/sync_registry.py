# -*- coding: utf-8 -*-
# PYTHONIOENCODING=utf-8 python scripts/sync_registry.py  (Windows)
"""
sync_registry.py — Sync BRD/DM/Mapping YAML files → spec-registry/registry.csv

Usage:
    python scripts/sync_registry.py              # sync toàn bộ
    python scripts/sync_registry.py --source FIMS  # chỉ source FIMS
    python scripts/sync_registry.py --summary      # in tiến độ theo source

Output: spec-registry/registry.csv
"""

import argparse
import csv
import glob
import os
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("ERROR: PyYAML chưa cài. Chạy: pip install pyyaml")
    sys.exit(1)

ROOT = Path(__file__).parent.parent
REGISTRY_PATH = ROOT / "spec-registry" / "registry.csv"

COLUMNS = [
    "brd_id",
    "source",
    "table_name",
    "functional_group",
    "scope_status",
    "scope_reason",
    "data_volume_hint",
    "refresh_frequency",
    "dm_status",       # none | draft | approved
    "mapping_status",  # none | done
    "etl_status",      # none | dev | done
    "test_status",     # none | written | passed
    "deployed",        # yes | no
    "dm_files",        # số DM file cho BRD này
    "mapping_files",   # số Mapping file cho BRD này
]


def load_brd_entries(source_filter=None):
    """Đọc tất cả BRD YAML → dict[brd_id] = row dict."""
    entries = {}
    pattern = str(ROOT / "BRD" / "Source" / "brd_*.yaml")
    for filepath in sorted(glob.glob(pattern)):
        try:
            with open(filepath, encoding="utf-8") as f:
                doc = yaml.safe_load(f)
        except Exception as e:
            print(f"  WARN: Không đọc được {filepath}: {e}")
            continue

        source = doc.get("source", "")
        if source_filter and source != source_filter:
            continue

        for entry in doc.get("brd_entries", []):
            brd_id = entry.get("brd_id", "")
            if not brd_id:
                continue
            content = entry.get("content", {}) or {}
            table_name = brd_id.split("-")[-1] if brd_id else ""
            entries[brd_id] = {
                "brd_id": brd_id,
                "source": source,
                "table_name": table_name,
                "functional_group": content.get("functional_group", ""),
                "scope_status": content.get("scope_status", ""),
                "scope_reason": content.get("scope_reason", "") or "",
                "data_volume_hint": content.get("data_volume_hint", "") or "",
                "refresh_frequency": content.get("refresh_frequency", "") or "",
                "dm_status": "none",
                "mapping_status": "none",
                "etl_status": "none",
                "test_status": "none",
                "deployed": "no",
                "dm_files": 0,
                "mapping_files": 0,
            }
    return entries


def index_dm_files():
    """Index DM YAML: brd_ref → (best_status, file_count)."""
    index = {}  # brd_ref -> {"status": ..., "count": ...}
    pattern = str(ROOT / "DataModel" / "Atomic" / "**" / "*.yaml")
    for filepath in glob.glob(pattern, recursive=True):
        try:
            with open(filepath, encoding="utf-8") as f:
                doc = yaml.safe_load(f)
        except Exception:
            continue
        if doc.get("schema_type") != "data_model":
            continue
        ldm = doc.get("ldm", {}) or {}
        brd_ref = (ldm.get("references") or {}).get("brd", "")
        status = ldm.get("status", "draft")
        if not brd_ref:
            continue
        if brd_ref not in index:
            index[brd_ref] = {"status": status, "count": 1}
        else:
            index[brd_ref]["count"] += 1
            # Escalate: draft → approved
            if status == "approved":
                index[brd_ref]["status"] = "approved"
    return index


def index_mapping_files():
    """Index Mapping YAML: brd_ref → file_count."""
    index = {}
    pattern = str(ROOT / "Mapping" / "Atomic" / "**" / "*.yaml")
    for filepath in glob.glob(pattern, recursive=True):
        try:
            with open(filepath, encoding="utf-8") as f:
                doc = yaml.safe_load(f)
        except Exception:
            continue
        if doc.get("schema_type") != "mapping":
            continue
        mapping = doc.get("mapping", {}) or {}
        brd_ref = mapping.get("brd_ref", "")
        if not brd_ref:
            continue
        index[brd_ref] = index.get(brd_ref, 0) + 1
    return index


def load_existing_registry():
    """Đọc registry.csv hiện có → dict[brd_id] = row (để preserve etl/test/deployed)."""
    existing = {}
    if not REGISTRY_PATH.exists():
        return existing
    with open(REGISTRY_PATH, encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            existing[row["brd_id"]] = row
    return existing


def merge_rows(brd_entries, dm_index, map_index, existing):
    """Merge BRD + DM + Mapping + existing manual fields → final rows."""
    rows = []
    for brd_id, row in brd_entries.items():
        # Preserve manually-managed fields từ registry cũ
        prev = existing.get(brd_id, {})
        row["etl_status"] = prev.get("etl_status", "none") or "none"
        row["test_status"] = prev.get("test_status", "none") or "none"
        row["deployed"] = prev.get("deployed", "no") or "no"

        # Cập nhật DM status từ YAML
        if brd_id in dm_index:
            row["dm_status"] = dm_index[brd_id]["status"]
            row["dm_files"] = dm_index[brd_id]["count"]
        else:
            row["dm_status"] = "none"
            row["dm_files"] = 0

        # Cập nhật Mapping status từ YAML
        if brd_id in map_index:
            row["mapping_status"] = "done"
            row["mapping_files"] = map_index[brd_id]
        else:
            row["mapping_status"] = "none"
            row["mapping_files"] = 0

        rows.append(row)

    # Sắp xếp: source A-Z, brd_id A-Z
    rows.sort(key=lambda r: (r["source"], r["brd_id"]))
    return rows


def write_registry(rows):
    REGISTRY_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(REGISTRY_PATH, "w", encoding="utf-8-sig", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=COLUMNS)
        writer.writeheader()
        writer.writerows(rows)
    print(f"  Đã ghi {len(rows)} dòng → {REGISTRY_PATH.relative_to(ROOT)}")


def print_summary(rows):
    from collections import defaultdict

    by_source = defaultdict(lambda: {
        "total": 0, "in_scope": 0,
        "dm_approved": 0, "dm_draft": 0,
        "mapping_done": 0,
        "etl_done": 0, "test_passed": 0, "deployed": 0,
    })

    for r in rows:
        s = r["source"]
        by_source[s]["total"] += 1
        if r["scope_status"] == "in_scope":
            by_source[s]["in_scope"] += 1
        if r["dm_status"] == "approved":
            by_source[s]["dm_approved"] += 1
        elif r["dm_status"] == "draft":
            by_source[s]["dm_draft"] += 1
        if r["mapping_status"] == "done":
            by_source[s]["mapping_done"] += 1
        if r["etl_status"] == "done":
            by_source[s]["etl_done"] += 1
        if r["test_status"] == "passed":
            by_source[s]["test_passed"] += 1
        if r["deployed"] == "yes":
            by_source[s]["deployed"] += 1

    header = f"{'Source':<14} {'Total':>5} {'InScope':>7} {'DM✓':>5} {'DM~':>5} {'Map✓':>6} {'ETL✓':>5} {'Test✓':>6} {'Deploy':>6}"
    print()
    print("=" * len(header))
    print(header)
    print("-" * len(header))
    totals = {k: 0 for k in ["total", "in_scope", "dm_approved", "dm_draft", "mapping_done", "etl_done", "test_passed", "deployed"]}
    for src in sorted(by_source):
        d = by_source[src]
        print(f"{src:<14} {d['total']:>5} {d['in_scope']:>7} {d['dm_approved']:>5} {d['dm_draft']:>5} {d['mapping_done']:>6} {d['etl_done']:>5} {d['test_passed']:>6} {d['deployed']:>6}")
        for k in totals:
            totals[k] += d[k]
    print("-" * len(header))
    print(f"{'TOTAL':<14} {totals['total']:>5} {totals['in_scope']:>7} {totals['dm_approved']:>5} {totals['dm_draft']:>5} {totals['mapping_done']:>6} {totals['etl_done']:>5} {totals['test_passed']:>6} {totals['deployed']:>6}")
    print("=" * len(header))
    print("  DM✓=approved  DM~=draft  Map✓=mapping done")
    print()


def main():
    parser = argparse.ArgumentParser(description="Sync BRD/DM/Mapping YAML → spec-registry/registry.csv")
    parser.add_argument("--source", help="Chỉ sync 1 source (VD: FIMS)")
    parser.add_argument("--summary", action="store_true", help="In bảng tiến độ sau khi sync")
    args = parser.parse_args()

    print(f"[sync_registry] Root: {ROOT}")
    print(f"  Đọc BRD entries{'  (filter: ' + args.source + ')' if args.source else ''}...")
    brd_entries = load_brd_entries(source_filter=args.source)
    print(f"  → {len(brd_entries)} BRD entries")

    print("  Index DM files...")
    dm_index = index_dm_files()
    print(f"  → {len(dm_index)} DM brd_ref")

    print("  Index Mapping files...")
    map_index = index_mapping_files()
    print(f"  → {len(map_index)} Mapping brd_ref")

    print("  Đọc registry hiện tại (preserve etl/test/deployed)...")
    existing = load_existing_registry()
    print(f"  → {len(existing)} dòng hiện có")

    rows = merge_rows(brd_entries, dm_index, map_index, existing)
    write_registry(rows)

    if args.summary or not args.source:
        # Reload toàn bộ để summary đầy đủ nếu đã filter
        all_rows = rows
        if args.source:
            all_existing = load_existing_registry()
            all_rows = list(all_existing.values()) if all_existing else rows
        print_summary(all_rows)


if __name__ == "__main__":
    main()
