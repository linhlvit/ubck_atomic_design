# -*- coding: utf-8 -*-
"""
refactor_logical_name.py — Refactor ldm.logical_name va them ldm.layer trong DataModel/Atomic/

Thay doi moi file:
1. logical_name: "Atomic - {Name} – source {SRC}.{TBL}"  →  "{Name}"
2. Them dong `  layer: Atomic` ngay sau dong `  physical_name: ...`

Usage:
    python scripts/refactor_logical_name.py          # ap dung thay doi
    python scripts/refactor_logical_name.py --dry-run  # xem truoc, khong ghi
"""

import argparse
import glob
import re
import sys
from pathlib import Path

ROOT = Path(__file__).parent.parent
ATOMIC_DIR = ROOT / "DataModel" / "Atomic"

# Pattern de extract entity name tu logical_name hien tai
# "Atomic - {Name} – source {SRC}.{TBL}"
# Em-dash: U+2013
LOGICAL_NAME_RE = re.compile(r'^(\s*logical_name:\s*["\']?)Atomic - (.+?) – source .+?(["\']?\s*)$')

# Pattern de detect dong physical_name
PHYSICAL_NAME_RE = re.compile(r'^(\s*)physical_name:\s*.+$')


def process_file(filepath: Path, dry_run: bool) -> tuple[bool, str]:
    """Process 1 file. Returns (changed, reason)."""
    text = filepath.read_text(encoding="utf-8")
    lines = text.splitlines(keepends=True)

    new_lines = []
    changed = False
    layer_added = False

    for line in lines:
        # 1. Transform logical_name
        m_ln = LOGICAL_NAME_RE.match(line)
        if m_ln:
            prefix = m_ln.group(1)
            entity_name = m_ln.group(2)
            suffix = m_ln.group(3)
            new_line = f"{prefix}{entity_name}{suffix}\n"
            new_lines.append(new_line)
            changed = True
            continue

        # 2. Sau physical_name: them layer
        m_pn = PHYSICAL_NAME_RE.match(line)
        if m_pn and not layer_added:
            indent = m_pn.group(1)
            new_lines.append(line)
            new_lines.append(f"{indent}layer: Atomic\n")
            layer_added = True
            changed = True
            continue

        new_lines.append(line)

    if not layer_added:
        return False, "WARNING: physical_name line not found — layer not added"

    if changed and not dry_run:
        filepath.write_text("".join(new_lines), encoding="utf-8")

    return changed, "ok"


def main():
    parser = argparse.ArgumentParser(
        description="Refactor ldm.logical_name va them ldm.layer trong DataModel/Atomic/"
    )
    parser.add_argument("--dry-run", action="store_true", help="Preview only, no write")
    args = parser.parse_args()

    pattern = str(ATOMIC_DIR / "**" / "*.yaml")
    files = sorted(glob.glob(pattern, recursive=True))

    processed = skipped = errors = 0
    for filepath in files:
        p = Path(filepath)
        # Only process data_model files (quick check: file name starts with dm_atm_)
        if not p.name.startswith("dm_atm_"):
            skipped += 1
            continue

        changed, reason = process_file(p, args.dry_run)
        if reason.startswith("WARNING"):
            print(f"  WARN {p.name}: {reason}")
            errors += 1
        elif changed:
            processed += 1

    action = "Would update" if args.dry_run else "Updated"
    print(f"\n[refactor_logical_name] {action} {processed} files. Skipped={skipped}, Errors={errors}")


if __name__ == "__main__":
    main()
