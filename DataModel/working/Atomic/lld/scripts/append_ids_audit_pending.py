"""
append_ids_audit_pending.py
=============================
Sinh + append entries vao pending_design.yaml cho audit block da bi xoa khoi
lld_IDS_*.yaml boi remove_ids_audit_block.py. Doc lai noi dung file GOC tu
git (HEAD) de biet chinh xac attribute/column nao da bi xoa (khong doan lai).

Cach dung:
  python DataModel/working/Atomic/lld/scripts/append_ids_audit_pending.py --dry-run
  python DataModel/working/Atomic/lld/scripts/append_ids_audit_pending.py
"""

import argparse
import io
import subprocess
import sys
from pathlib import Path

import yaml

if sys.stdout.encoding and sys.stdout.encoding.lower() not in ("utf-8", "utf-8-sig"):
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
if sys.stderr.encoding and sys.stderr.encoding.lower() not in ("utf-8", "utf-8-sig"):
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent.parent.parent.parent
IDS_DIR = SCRIPT_DIR.parent / "IDS"
PENDING_PATH = SCRIPT_DIR.parent / "pending_design.yaml"

TARGET_ATTR_TO_COLUMN = {
    "Created Timestamp": "CREATED_DATE",
    "Updated Timestamp": "UPDATED_DATE",
    "Created By User Id": "CREATED_BY",
    "Created By User Code": "CREATED_BY",
    "Updated By User Id": "UPDATED_BY",
    "Updated By User Code": "UPDATED_BY",
}
COLUMN_ORDER = ["CREATED_DATE", "UPDATED_DATE", "CREATED_BY", "UPDATED_BY"]

REASON = (
    "Quyet dinh thiet ke: loai bo audit block khoi Atomic entity phan he IDS, mirror "
    "quyet dinh da ap dung cho SCMS. Created By/Updated By von pending do FK cross-source "
    "sang Identity and Access Management User (IAM.USERS) chua resolve crosswalk "
    "(IDS.LOGINS.ID NUMBER tu tang vs IAM.USERS.ID VARCHAR2(36) GUID); Created/Updated "
    "Timestamp loai bo dong bo theo cung quyet dinh."
)


def git_show(rel_path: str) -> str:
    result = subprocess.run(
        ["git", "show", f"HEAD:{rel_path}"],
        cwd=PROJECT_ROOT,
        capture_output=True,
        check=True,
    )
    return result.stdout.decode("utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    entries_text = []
    for path in sorted(IDS_DIR.glob("lld_IDS_*.yaml")):
        rel = path.relative_to(PROJECT_ROOT).as_posix()
        try:
            original_text = git_show(rel)
        except subprocess.CalledProcessError:
            continue
        data = yaml.safe_load(original_text)
        if (data or {}).get("schema_type") != "lld_source_table":
            continue
        meta = data.get("metadata", {}) or {}
        table = meta.get("source_table", "")

        removed_columns = set()
        for a in data.get("attributes", []):
            name = a.get("attribute_name", "")
            if name in TARGET_ATTR_TO_COLUMN:
                removed_columns.add(TARGET_ATTR_TO_COLUMN[name])

        if not removed_columns:
            continue

        cols_ordered = [c for c in COLUMN_ORDER if c in removed_columns]
        entries_text.append(
            "  - source_system: \"IDS\"\n"
            f"    source_table: \"{table}\"\n"
            f"    source_column: \"{', '.join(cols_ordered)}\"\n"
            "    description: \"Audit block created/updated by-at\"\n"
            f"    reason: \"{REASON}\"\n"
            "    action: \"Excluded — da xoa Created/Updated Timestamp va Created/Updated By User "
            f"Id/Code khoi lld_IDS_{table}.yaml.\"\n"
        )

    block = "\n".join(entries_text)
    print(f"So entry se them: {len(entries_text)}", file=sys.stderr)

    if args.dry_run:
        print(block)
        return

    with open(PENDING_PATH, "r", encoding="utf-8") as f:
        current = f.read()
    if not current.endswith("\n"):
        current += "\n"
    current += "\n" + block
    with open(PENDING_PATH, "w", encoding="utf-8") as f:
        f.write(current)
    print(f"Da append vao {PENDING_PATH}", file=sys.stderr)


if __name__ == "__main__":
    main()
