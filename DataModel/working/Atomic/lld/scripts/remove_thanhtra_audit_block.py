"""
remove_thanhtra_audit_block.py
================================
Loai bo audit block Created/Updated Timestamp + Created/Updated By Officer Id/Code
khoi toan bo lld_ThanhTra_*.yaml (quyet dinh thiet ke cua Data Modeler, mirror dung
quyet dinh da ap dung cho SCMS/IDS — xem remove_scms_audit_block.py,
remove_ids_audit_block.py).

Xoa 6 attribute chuan (neu ton tai trong file):
  Created Timestamp, Updated Timestamp,
  Created By Officer Id, Created By Officer Code,
  Updated By Officer Id, Updated By Officer Code

Column nguon duoc lay truc tiep tu source_columns cua tung attribute (khong
hardcode) de tu dong dung voi moi bien the ten cot.

Tu dong append entry pending_design.yaml (khong can script rieng nhu SCMS/IDS
vi doc du lieu GOC ngay truoc khi xoa, khong can doc lai tu git).

Cach dung:
  python DataModel/working/Atomic/lld/scripts/remove_thanhtra_audit_block.py --dry-run
  python DataModel/working/Atomic/lld/scripts/remove_thanhtra_audit_block.py
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
THANHTRA_DIR = SCRIPT_DIR.parent / "THANHTRA"
PENDING_PATH = SCRIPT_DIR.parent / "pending_design.yaml"

TARGET_ATTR_NAMES = [
    "Created Timestamp",
    "Updated Timestamp",
    "Created By Officer Id",
    "Created By Officer Code",
    "Updated By Officer Id",
    "Updated By Officer Code",
]

REASON = (
    "Quyet dinh thiet ke: loai bo audit block khoi Atomic entity phan he ThanhTra, "
    "mirror quyet dinh da ap dung cho SCMS/IDS. Created By/Updated By Officer Id/Code "
    "la FK cross-source den NHNCK.USERS (Regulatory Authority Officer) — loai bo theo "
    "yeu cau Data Modeler de don gian hoa, khong phu thuoc FK cross-source chua duoc "
    "xac nhan on dinh. Created/Updated Timestamp loai bo dong bo theo cung quyet dinh."
)


def col_name(source_columns) -> str:
    if not source_columns:
        return ""
    return source_columns[0].rsplit(".", 1)[-1]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    files = sorted(THANHTRA_DIR.glob("lld_ThanhTra_*.yaml"))
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
        removed_columns = []
        seen_cols = set()
        for a in attrs:
            name = a.get("attribute_name", "")
            if name in TARGET_ATTR_NAMES:
                removed_names.append(name)
                c = col_name(a.get("source_columns"))
                if c and c not in seen_cols:
                    seen_cols.add(c)
                    removed_columns.append(c)
            else:
                kept.append(a)

        if not removed_names:
            continue

        total_removed += len(removed_names)
        print(
            f"{path.relative_to(SCRIPT_DIR.parent.parent.parent.parent)}: xoa {len(removed_names)} attribute -> {removed_names}",
            file=sys.stderr,
        )

        pending_entries_text.append(
            "  - source_system: \"ThanhTra\"\n"
            f"    source_table: \"{table}\"\n"
            f"    source_column: \"{', '.join(removed_columns)}\"\n"
            "    description: \"Audit block created/updated by-at\"\n"
            f"    reason: \"{REASON}\"\n"
            "    action: \"Excluded — da xoa Created/Updated Timestamp va Created/Updated By Officer "
            f"Id/Code khoi lld_ThanhTra_{table}.yaml.\"\n"
        )

        if not args.dry_run:
            data["attributes"] = kept
            with open(path, "w", encoding="utf-8") as f:
                yaml.dump(data, f, Dumper=DQDumper, allow_unicode=True, sort_keys=False, default_flow_style=False)

    print(f"\nTong so file bi anh huong: {len(pending_entries_text)}", file=sys.stderr)
    print(f"Tong so attribute bi xoa: {total_removed}", file=sys.stderr)

    block = "\n".join(pending_entries_text)
    if not args.dry_run and block:
        with open(PENDING_PATH, "r", encoding="utf-8") as f:
            current = f.read()
        if not current.endswith("\n"):
            current += "\n"
        current += "\n" + block
        with open(PENDING_PATH, "w", encoding="utf-8") as f:
            f.write(current)
        print(f"Da append {len(pending_entries_text)} entry vao {PENDING_PATH}", file=sys.stderr)
    else:
        print("\n--- pending_design.yaml entries se them (dry-run, chua ghi) ---\n")
        print(block)


if __name__ == "__main__":
    main()
