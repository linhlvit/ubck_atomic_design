"""
fix_ordertrade_source_columns.py

Fix LLD YAML files trong thư mục ORDERTRADE:
- source_columns item dạng:
    - ORDERTRADE.TABLE.COL    comment: "text"
  → tách thành:
    - "ORDERTRADE.TABLE.COL"
  + thêm field comment: "text" ngay sau block source_columns

Chạy từ thư mục DataModel/working/Atomic/lld/
  python3.11 scripts/fix_ordertrade_source_columns.py [--dry-run]
"""

import re
import sys
import pathlib

DRY_RUN = "--dry-run" in sys.argv

# Match dòng source_columns item có embedded comment
# Group 1: indent spaces
# Group 2: col path (SOURCE.TABLE.COL)
# Group 3: comment value (quoted string hoặc null)
ITEM_PAT = re.compile(
    r'^( +)- ((?:[A-Za-z0-9_]+\.){2}[A-Za-z0-9_]+) +comment: (.+)$'
)


def fix_text(text: str, filename: str) -> tuple[str, int]:
    """Fix raw YAML text. Returns (fixed_text, n_fixes)."""
    lines = text.splitlines(keepends=True)
    result = []
    fixes = 0
    i = 0
    while i < len(lines):
        line = lines[i]
        m = ITEM_PAT.match(line.rstrip('\n'))
        if m:
            indent, col_path, comment_val = m.groups()
            # Build fixed item line
            fixed_item = f'{indent}- "{col_path}"\n'
            result.append(fixed_item)
            fixes += 1

            # Look ahead: next non-empty line — should be classification_context or etl_derived_value
            # We need to insert comment: field AFTER this list item block
            # Check if comment_val is not null
            if comment_val.strip() != 'null':
                # comment_val may be quoted: "text" → strip outer quotes
                cmt = comment_val.strip()
                # Insert comment: field at same indent level as source_columns items minus 2
                # source_columns: is at indent-2 spaces, comment: should be at same level
                # indent for list item is e.g. "      " (6 spaces), source_columns is at 4 spaces
                # comment field should be at 4 spaces
                field_indent = indent[:-2]  # remove 2 spaces (list indent)
                comment_line = f'{field_indent}comment: {cmt}\n'
                # Check if next meaningful line already has comment: field
                j = i + 1
                while j < len(lines) and lines[j].strip() == '':
                    j += 1
                next_line = lines[j].strip() if j < len(lines) else ''
                if not next_line.startswith('comment:'):
                    result.append(comment_line)
            i += 1
        else:
            result.append(line)
            i += 1

    return ''.join(result), fixes


def main():
    lld_root = pathlib.Path('.')
    if not (lld_root / 'scripts').exists():
        print("ERROR: Chạy từ thư mục DataModel/working/Atomic/lld/")
        sys.exit(1)

    total_fixes = 0
    all_files = [f for f in sorted(lld_root.glob('**/*.yaml'))
                 if 'scripts' not in str(f) and 'aggregate' not in str(f)]
    for fp in all_files:
        text = fp.read_text(encoding='utf-8')
        fixed, n = fix_text(text, fp.name)
        total_fixes += n
        if n > 0:
            print(f'{fp.name}: {n} fixes')
            if not DRY_RUN:
                fp.write_text(fixed, encoding='utf-8')
                print(f'  → Đã ghi')
            else:
                print(f'  → [dry-run] không ghi')
        else:
            print(f'{fp.name}: OK (không có fix)')

    print(f'\nTổng: {total_fixes} fixes trên {len(all_files)} files')
    if DRY_RUN:
        print('[dry-run mode — không ghi file]')


if __name__ == '__main__':
    main()
