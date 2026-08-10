"""
fix_etl_derived_value_format.py

Sửa format `etl_derived_value` theo rule mới (2026-08-10):
  - Source System Code (SRC.TABLE)      -> SRC_TABLE (gạch dưới, không dùng dấu chấm)
  - Expression mapping CODE=VALUE;...   -> null (mapping đã có trong classification_schemes.yaml / bảng cl_value)
  - Literal VALUE cố định (VD PHONE)    -> giữ nguyên

Xử lý line-based (không round-trip qua YAML parser) để giữ nguyên format/thứ tự key
của file gốc. Áp dụng cho scalar và block-list array (`etl_derived_value:` + `- item`).

Cách dùng:
    python fix_etl_derived_value_format.py            # dry-run, chỉ in báo cáo
    python fix_etl_derived_value_format.py --apply     # ghi thay đổi vào file
"""
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[5]

TARGET_ROOTS = [
    REPO_ROOT / "DataModel" / "working" / "Atomic" / "lld",
    REPO_ROOT / "DataModel" / "working" / "Atomic" / "aggregate" / "atomic_attributes.yaml",
    REPO_ROOT / "DataModel" / "Atomic",
    REPO_ROOT / "DataModel" / "atomic_model.yaml",
]

EXCLUDE_DIR_PARTS = {"Atomic_LinhLV", "scripts", "reference", "templates"}
EXCLUDE_FILENAMES = {"classification_schemes.yaml", "dm_manifest.yaml"}

SCALAR_RE = re.compile(r'^(?P<indent>\s*)etl_derived_value:\s*(?P<val>.*)$')
ARRAY_HEADER_RE = re.compile(r'^(?P<indent>\s*)etl_derived_value:\s*$')
ITEM_RE = re.compile(r'^(?P<indent>\s*)-\s*(?P<val>.*)$')


def iter_target_files():
    seen = set()
    for root in TARGET_ROOTS:
        if root.is_file():
            paths = [root]
        else:
            paths = root.rglob("*.yaml")
        for p in paths:
            if p in seen:
                continue
            parts = set(p.parts)
            if parts & EXCLUDE_DIR_PARTS:
                continue
            if p.name in EXCLUDE_FILENAMES:
                continue
            seen.add(p)
            yield p


def strip_quotes(raw):
    s = raw.strip()
    if len(s) >= 2 and s[0] == s[-1] and s[0] in ("'", '"'):
        return s[1:-1], s[0]
    return s, None


def classify_and_transform(raw_val):
    """Return (new_raw_value, changed, case_label)."""
    val, quote = strip_quotes(raw_val)
    if val == "" or val.lower() == "null":
        return raw_val, False, "empty"
    if "=" in val:
        return "null", True, "expr_mapping"
    if "." in val and re.fullmatch(r"[A-Za-z0-9_]+\.[A-Za-z0-9_.]+", val):
        new_val = val.replace(".", "_")
        new_raw = f"{quote}{new_val}{quote}" if quote else new_val
        return new_raw, True, "src_table"
    return raw_val, False, "literal"


def process_lines(lines):
    """lines: list[str] (no line-ending chars). Returns (new_lines, counts dict)."""
    counts = {"src_table": 0, "expr_mapping": 0, "array_dropped_all": 0}
    out = []
    i = 0
    n = len(lines)
    while i < n:
        line = lines[i]

        m_scalar = SCALAR_RE.match(line)
        m_header = ARRAY_HEADER_RE.match(line)

        if m_header:
            # Block-list array form: collect following "- item" lines.
            indent = m_header.group("indent")
            j = i + 1
            item_idxs = []
            while j < n:
                im = ITEM_RE.match(lines[j])
                if not im:
                    break
                item_idxs.append(j)
                j += 1

            if not item_idxs:
                # Empty header with no items (shouldn't normally happen) — leave as-is.
                out.append(line)
                i += 1
                continue

            new_items = []
            for idx in item_idxs:
                im = ITEM_RE.match(lines[idx])
                ind = im.group("indent")
                val_raw = im.group("val")
                new_val, changed, case = classify_and_transform(val_raw)
                if case == "expr_mapping":
                    counts["expr_mapping"] += 1
                    continue  # drop this item entirely
                if changed:
                    counts["src_table"] += 1
                new_items.append(f"{ind}- {new_val}")

            if new_items:
                out.append(line)  # header unchanged
                out.extend(new_items)
            else:
                counts["array_dropped_all"] += 1
                out.append(f"{indent}etl_derived_value: null")

            i = j
            continue

        if m_scalar and m_scalar.group("val").strip() != "":
            indent = m_scalar.group("indent")
            val_raw = m_scalar.group("val")
            new_val, changed, case = classify_and_transform(val_raw)
            if changed:
                out.append(f"{indent}etl_derived_value: {new_val}")
                counts[case] += 1
            else:
                out.append(line)
            i += 1
            continue

        out.append(line)
        i += 1

    return out, counts


def process_file(path, apply_changes):
    raw = path.read_text(encoding="utf-8")
    eol = "\r\n" if "\r\n" in raw else "\n"
    had_trailing_newline = raw.endswith(eol)
    lines = raw.split(eol)
    if had_trailing_newline:
        lines = lines[:-1]

    new_lines, counts = process_lines(lines)

    total_changed = counts["src_table"] + counts["expr_mapping"] + counts["array_dropped_all"]
    if total_changed == 0:
        return counts

    if apply_changes:
        new_text = eol.join(new_lines) + (eol if had_trailing_newline else "")
        path.write_text(new_text, encoding="utf-8")

    return counts


def main():
    apply_changes = "--apply" in sys.argv[1:]
    grand_total = {"src_table": 0, "expr_mapping": 0, "array_dropped_all": 0}
    files_changed = 0

    for path in sorted(iter_target_files()):
        counts = process_file(path, apply_changes)
        file_total = counts["src_table"] + counts["expr_mapping"] + counts["array_dropped_all"]
        if file_total:
            files_changed += 1
            rel = path.relative_to(REPO_ROOT)
            print(f"{rel}  src_table={counts['src_table']}  expr_mapping={counts['expr_mapping']}  array_dropped_all={counts['array_dropped_all']}")
            for k in grand_total:
                grand_total[k] += counts[k]

    print("=" * 60)
    mode = "APPLIED" if apply_changes else "DRY-RUN (dùng --apply để ghi file)"
    print(f"[{mode}] Files changed: {files_changed}")
    print(f"  Source System Code (dot -> underscore): {grand_total['src_table']}")
    print(f"  Expression mapping removed (-> null):   {grand_total['expr_mapping']}")
    print(f"  Array fields fully emptied (-> null):    {grand_total['array_dropped_all']}")


if __name__ == "__main__":
    main()
