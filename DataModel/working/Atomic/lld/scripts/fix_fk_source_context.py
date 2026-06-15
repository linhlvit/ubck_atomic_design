"""
fix_fk_source_context.py
=========================
Bổ sung thông tin hash vào comment của FK surrogate Id fields trong NHNCK LLD.

FK_SOURCE được xác định từ Source/NHNCK_Columns.csv (cột "Ghi chú (FK suy luận)"),
không dùng heuristic tên column.

Pattern thêm vào cuối comment:
  " Hash: hash_id('<FK_SOURCE>', <BK_COL>)."

Điều kiện áp dụng:
  - data_domain: Surrogate Key
  - is_primary_key: false
  - classification_context: null
  - comment chứa "FK target:" nhưng chưa có "Hash: hash_id("

Cách dùng:
  python3.12 DataModel/working/Atomic/lld/scripts/fix_fk_source_context.py
  python3.12 DataModel/working/Atomic/lld/scripts/fix_fk_source_context.py --dry-run
"""

import argparse
import csv
import re
import sys
import yaml
from pathlib import Path

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
SCRIPT_DIR   = Path(__file__).parent
LLD_DIR      = SCRIPT_DIR.parent
NHNCK_DIR    = LLD_DIR / "NHNCK"
ROOT         = LLD_DIR.parent.parent.parent.parent
COLUMNS_CSV  = ROOT / "Source" / "NHNCK_Columns.csv"


# ---------------------------------------------------------------------------
# Load FK map from NHNCK_Columns.csv
# Returns {(table, column): target_table}
# ---------------------------------------------------------------------------
def load_fk_map() -> dict:
    fk_map = {}
    with open(COLUMNS_CSV, encoding="utf-8-sig") as f:
        for row in csv.DictReader(f):
            note = row.get("Ghi chú (FK suy luận)") or ""
            # Matches: "FK → TARGET.ID" or "FK suy luận → TARGET.ID"
            m = re.search(r"FK(?:\s+suy\s+lu[aậ]n)?\s*→\s*(\w+)\.", note)
            if m:
                tbl = row["Tên bảng"].strip()
                col = row["Tên trường"].strip()
                fk_map[(tbl, col)] = m.group(1)
    return fk_map


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _bk_col(source_columns: list) -> str:
    """Extract column name (after last '.') from first source_column."""
    if not source_columns:
        return ""
    parts = source_columns[0].split(".")
    return parts[-1] if parts else ""


def _parse_fk_entity(comment_text: str) -> str | None:
    m = re.search(r"FK target:\s+(.+?)\.", comment_text)
    if not m:
        return None
    return m.group(1).strip()


# ---------------------------------------------------------------------------
# Text-level comment patcher (handles single-line and multiline YAML fold)
# ---------------------------------------------------------------------------

def _is_continuation(line: str) -> bool:
    return bool(re.match(r'^\s+\\ ', line)) or bool(re.match(r'^\s+\\$', line.rstrip('\n')))


def process_file_text(path: Path, source_table: str, fk_map: dict, dry_run: bool) -> int:
    """
    Patch FK Id field comments in-place using text manipulation.
    Returns number of attributes updated.
    """
    text = path.read_text(encoding="utf-8")

    try:
        data = yaml.safe_load(text)
    except yaml.YAMLError as e:
        print(f"  [ERROR] YAML parse error in {path.name}: {e}", file=sys.stderr)
        return 0

    # Build: attribute_name → hash_suffix
    patches: dict[str, str] = {}

    for attr in data.get("attributes", []):
        if attr.get("data_domain") != "Surrogate Key":
            continue
        if attr.get("is_primary_key"):
            continue
        ctx = attr.get("classification_context") or ""
        # Skip if ctx is SOURCE_SYSTEM= (that field already carries its own ETL info)
        if ctx.startswith("SOURCE_SYSTEM="):
            continue
        comment = attr.get("comment") or ""
        if "FK target:" not in comment:
            continue
        if "Hash: hash_id(" in comment:
            continue  # already patched

        src_cols = attr.get("source_columns") or []
        bk = _bk_col(src_cols)
        attr_name = attr.get("attribute_name", "")

        if not bk:
            # source_columns is empty — FK is always NULL (e.g. COUNTRIES.Parent Geographic Area Id).
            # No hash needed: a NULL value has no hash input.
            continue
        elif bk == "ID":
            # Shared-entity linkage: source_col = NHNCK.PARENT_TABLE.ID (PK of parent).
            # FK_SOURCE = the parent source table (same as metadata.source_table of this file).
            fk_source = f"NHNCK.{source_table}"
        else:
            # Normal FK: lookup target table from CSV.
            target_table = fk_map.get((source_table, bk))
            if target_table:
                fk_source = f"NHNCK.{target_table}"
            else:
                print(f"  [WARN] {path.name}: ({source_table}, {bk}) not in FK map — skipping {attr_name!r}",
                      file=sys.stderr)
                continue

        hash_suffix = f" Hash: hash_id('{fk_source}', {bk or 'ID'})."
        patches[attr_name] = hash_suffix

    if not patches:
        return 0

    # Text-level patch: walk lines, collect comment blocks, replace
    lines = text.splitlines(keepends=True)
    out_lines = []
    current_attr_name: str | None = None
    changed = 0
    i = 0

    while i < len(lines):
        line = lines[i]

        m_attr = re.match(r'^\s*-\s+attribute_name:\s+"?([^"\n]+)"?\s*$', line)
        if m_attr:
            current_attr_name = m_attr.group(1).strip()

        if current_attr_name in patches:
            m_comment = re.match(r'^(?P<indent>\s+)comment:\s+', line)
            if m_comment:
                indent = m_comment.group("indent")

                # Collect full comment block (first line + continuations)
                block_lines = [line]
                j = i + 1
                while j < len(lines) and _is_continuation(lines[j]):
                    block_lines.append(lines[j])
                    j += 1

                # Parse via yaml mini-snippet to get actual string value
                mini = "comment: " + "".join(block_lines).lstrip().split("comment: ", 1)[-1]
                try:
                    value = yaml.safe_load(mini).get("comment", "")
                except Exception:
                    out_lines.extend(block_lines)
                    i = j
                    continue

                if value is None or "Hash: hash_id(" in (value or ""):
                    out_lines.extend(block_lines)
                    i = j
                    continue

                new_value = (value or "").rstrip()
                if new_value.endswith("."):
                    new_value = new_value[:-1]
                new_value = new_value + "." + patches[current_attr_name]

                escaped = new_value.replace("\\", "\\\\").replace('"', '\\"')
                new_line = f'{indent}comment: "{escaped}"\n'

                if dry_run:
                    print(f"  [DRY] {current_attr_name}:")
                    print(f"        {''.join(l.rstrip() for l in block_lines)!r}")
                    print(f"    →   {new_line.rstrip()!r}")

                out_lines.append(new_line)
                changed += 1
                del patches[current_attr_name]
                current_attr_name = None
                i = j
                continue

        out_lines.append(line)
        i += 1

    if changed and not dry_run:
        path.write_text("".join(out_lines), encoding="utf-8")

    return changed


def main():
    parser = argparse.ArgumentParser(
        description="Add hash_id(...) to FK surrogate Id field comments in NHNCK LLD. "
                    "FK_SOURCE derived from Source/NHNCK_Columns.csv."
    )
    parser.add_argument("--dry-run", action="store_true",
                        help="Print changes without writing files")
    args = parser.parse_args()

    print("Loading FK map from NHNCK_Columns.csv...", file=sys.stderr)
    fk_map = load_fk_map()
    print(f"  {len(fk_map)} FK relationships loaded.", file=sys.stderr)

    total_files = 0
    total_attrs = 0

    for path in sorted(NHNCK_DIR.glob("lld_NHNCK_*.yaml")):
        # Extract source_table from file metadata
        try:
            meta_data = yaml.safe_load(path.read_text(encoding="utf-8"))
            source_table = meta_data.get("metadata", {}).get("source_table", "")
        except Exception:
            source_table = ""

        if not source_table:
            print(f"  [WARN] Cannot determine source_table for {path.name}", file=sys.stderr)
            continue

        n = process_file_text(path, source_table, fk_map, dry_run=args.dry_run)
        if n:
            tag = "[DRY] " if args.dry_run else ""
            print(f"  {tag}{path.name}: {n} attribute(s) updated")
            total_files += 1
            total_attrs += n

    prefix = "[DRY-RUN] " if args.dry_run else ""
    print(f"\n{prefix}Kết quả: {total_files} files, {total_attrs} FK Id attributes updated.")


if __name__ == "__main__":
    main()
