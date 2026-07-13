"""
remove_ids_audit_block.py
==========================
Loai bo audit block Created/Updated Timestamp + Created/Updated By User Id/Code
khoi toan bo lld_IDS_*.yaml (quyet dinh thiet ke cua Data Modeler, mirror dung
quyet dinh da ap dung cho SCMS — xem remove_scms_audit_block.py).

Xoa 6 attribute chuan (neu ton tai trong file):
  Created Timestamp, Updated Timestamp,
  Created By User Id, Created By User Code,
  Updated By User Id, Updated By User Code

KHONG dong den Deleted Indicator (DELETE_FLG / IS_DELETED) — giu nguyen, day la
du lieu nghiep vu (soft-delete flag), khong thuoc quyet dinh nay.

In ra danh sach file/attribute se xoa + entry pending_design.yaml se them (dang text,
KHONG tu ghi pending_design.yaml — dung append_ids_audit_pending.py cho buoc do).

Cach dung:
  python DataModel/working/Atomic/lld/scripts/remove_ids_audit_block.py --dry-run
  python DataModel/working/Atomic/lld/scripts/remove_ids_audit_block.py
"""

import argparse
import io
import sys
from pathlib import Path

import yaml

if sys.stdout.encoding and sys.stdout.encoding.lower() not in ("utf-8", "utf-8-sig"):
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
if sys.stderr.encoding and sys.stderr.encoding.lower() not in ("utf-8", "utf-8-sig"):
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")


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

SCRIPT_DIR = Path(__file__).resolve().parent
IDS_DIR = SCRIPT_DIR.parent / "IDS"

TARGET_ATTR_TO_COLUMN = {
    "Created Timestamp": "CREATED_DATE",
    "Updated Timestamp": "UPDATED_DATE",
    "Created By User Id": "CREATED_BY",
    "Created By User Code": "CREATED_BY",
    "Updated By User Id": "UPDATED_BY",
    "Updated By User Code": "UPDATED_BY",
}
COLUMN_ORDER = ["CREATED_DATE", "UPDATED_DATE", "CREATED_BY", "UPDATED_BY"]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    files = sorted(IDS_DIR.glob("lld_IDS_*.yaml"))
    total_removed = 0
    pending_entries_text = []

    for path in files:
        data = yaml.safe_load(path.read_text(encoding="utf-8"))
        if (data or {}).get("schema_type") != "lld_source_table":
            continue
        meta = data.get("metadata", {}) or {}
        table = meta.get("source_table", "")

        attrs = data.get("attributes", [])
        kept = []
        removed_names = []
        removed_columns = set()
        for a in attrs:
            name = a.get("attribute_name", "")
            if name in TARGET_ATTR_TO_COLUMN:
                removed_names.append(name)
                removed_columns.add(TARGET_ATTR_TO_COLUMN[name])
            else:
                kept.append(a)

        if not removed_names:
            continue

        total_removed += len(removed_names)
        cols_ordered = [c for c in COLUMN_ORDER if c in removed_columns]
        print(f"{path.relative_to(SCRIPT_DIR.parent.parent.parent.parent)}: xoa {len(removed_names)} attribute -> {removed_names}", file=sys.stderr)

        pending_entries_text.append(
            "  - source_system: \"IDS\"\n"
            f"    source_table: \"{table}\"\n"
            f"    source_column: \"{', '.join(cols_ordered)}\"\n"
            "    description: \"Audit block created/updated by-at\"\n"
            "    reason: \"Quyet dinh thiet ke: loai bo audit block khoi Atomic entity phan he IDS, "
            "mirror quyet dinh da ap dung cho SCMS. Created By/Updated By von pending do FK cross-source "
            "sang Identity and Access Management User (IAM.USERS) chua resolve crosswalk "
            "(IDS.LOGINS.ID NUMBER tu tang vs IAM.USERS.ID VARCHAR2(36) GUID); Created/Updated Timestamp "
            "loai bo dong bo theo cung quyet dinh.\"\n"
            "    action: \"Excluded - da xoa Created/Updated Timestamp va Created/Updated By User "
            f"Id/Code khoi lld_IDS_{table}.yaml.\"\n"
        )

        if not args.dry_run:
            data["attributes"] = kept
            with open(path, "w", encoding="utf-8") as f:
                yaml.dump(data, f, Dumper=DQDumper, allow_unicode=True, sort_keys=False, default_flow_style=False)

    print(f"\nTong so file bi anh huong: {len(pending_entries_text)}", file=sys.stderr)
    print(f"Tong so attribute bi xoa: {total_removed}", file=sys.stderr)
    print("\n--- pending_design.yaml entries can them (copy thu cong) ---\n")
    print("\n".join(pending_entries_text))


if __name__ == "__main__":
    main()
