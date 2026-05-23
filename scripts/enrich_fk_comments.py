"""
Bổ sung Classification context vào comment của FK target và Lookup pair
trong các file YAML DataModel/Atomic.

Usage:
  python scripts/enrich_fk_comments.py --source FMS [--dry-run]

Options:
  --source   Chỉ xử lý file có ldm.source = giá trị này (VD: FMS)
  --dry-run  Không ghi file, chỉ xuất report CSV
"""

import re
import sys
import yaml
import csv
import argparse
from pathlib import Path

if sys.stdout.encoding != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

ATOMIC_DIR = Path(__file__).parent.parent / "DataModel" / "Atomic"
REPORT_DIR = Path(__file__).parent.parent / "docs" / "analysis"

# ── Regex để detect và extract entity name từ comment ─────────────────────────
# Khớp: "FK target: Some Entity Name.Some Attribute Name."
# Hoặc: "FK target: Some Entity Name.Some Attribute Name. extra notes"
RE_FK    = re.compile(r'FK target:\s+(.+?)\.[^.]+')
RE_LKUP  = re.compile(r'Lookup pair:\s+(.+?)\.[^.]+')

# Khớp dòng comment trong raw YAML (double hoặc single quote)
# Group 1: indent + 'comment: '
# Group 2: open quote
# Group 3: nội dung comment (không chứa quote đóng)
# Group 4: close quote
RE_COMMENT_LINE = re.compile(
    r'([ \t]+comment:\s*)(["\'])(FK target:|Lookup pair:)([^"\']*?)(\2)'
)


def load_yaml_safe(path: Path):
    try:
        with open(path, encoding="utf-8") as f:
            return yaml.safe_load(f)
    except Exception as e:
        print(f"  [WARN] Cannot parse {path.name}: {e}")
        return None


def build_entity_lookup(yaml_files: list[Path]) -> dict[str, list[str]]:
    """
    Quét toàn bộ file YAML, xây dict: logical_name -> list[classification_context]

    Với mỗi logical_name:
    - Nếu chỉ có 1 file (entity thông thường): lấy classification_context của PK attr
      (fallback attr[0] nếu không có PK — trường hợp Shared Entity single-file)
    - Nếu có nhiều file cùng logical_name (multi-source entity hoặc Shared Entity):
      thu thập tất cả contexts từ tất cả files, deduplicate, giữ thứ tự

    Kết quả: list 1 phần tử nếu unique, list nhiều phần tử nếu có nhiều contexts.
    """
    # logical_name -> list[ctx] (ordered, deduplicated)
    raw: dict[str, list[str]] = {}

    for fpath in sorted(yaml_files):  # sorted để thứ tự deterministic
        doc = load_yaml_safe(fpath)
        if not doc:
            continue
        ldm = doc.get("ldm", {})
        logical_name = ldm.get("logical_name", "").strip()
        if not logical_name:
            continue

        attrs = doc.get("attributes") or []
        pk_attr = next((a for a in attrs if a.get("is_primary_key") is True), None)
        ref_attr = pk_attr if pk_attr else (attrs[0] if attrs else None)
        if not ref_attr:
            continue

        ctx = str(ref_attr.get("classification_context", "")).strip()
        if not ctx:
            continue

        if logical_name not in raw:
            raw[logical_name] = []
        if ctx not in raw[logical_name]:
            raw[logical_name].append(ctx)

    multi = [(name, ctxs) for name, ctxs in raw.items() if len(ctxs) > 1]
    if multi:
        print(f"  [INFO] {len(multi)} entities có nhiều classification_context (sẽ dùng array):")
        for name, ctxs in multi:
            print(f"    - {name}: {ctxs}")

    return raw


def extract_entity_name(comment_body: str) -> str | None:
    """Lấy entity logical name từ nội dung comment (không có quote)."""
    m = RE_FK.match(comment_body) or RE_LKUP.match(comment_body)
    return m.group(1).strip() if m else None


def already_has_classification(comment_body: str) -> bool:
    return "Classification:" in comment_body


SOURCE_FALLBACK: dict[str, list[str]] = {
    "FMS": ["FMS", "FIMS"],
    "FIMS": ["FIMS", "FMS"],
}


def resolve_ctx(ctxs: list[str], file_source: str) -> list[str]:
    """
    Với nhiều contexts, thử từng source trong fallback chain theo thứ tự:
    - Nếu tìm được đúng 1 context khớp → dùng context đó
    - Nếu không tìm thấy ở bất kỳ source nào → giữ nguyên toàn bộ (array)
    """
    if len(ctxs) <= 1:
        return ctxs
    for source in SOURCE_FALLBACK.get(file_source, [file_source]):
        prefix = f"Source System Code = '{source}_"
        matched = [c for c in ctxs if c.startswith(prefix)]
        if len(matched) == 1:
            return matched
    return ctxs


def format_ctx(ctxs: list[str]) -> str:
    """Render contexts: single -> chuỗi thường; nhiều -> dạng array."""
    if len(ctxs) == 1:
        return ctxs[0]
    inner = ", ".join(f'"{c}"' for c in ctxs)
    return f"[{inner}]"


def append_classification(comment_body: str, ctxs: list[str]) -> str:
    """Nối '. Classification: {ctx}.' vào cuối comment, bỏ dấu chấm trailing trước."""
    body = comment_body.rstrip()
    if body.endswith("."):
        body = body[:-1]
    return f"{body}. Classification: {format_ctx(ctxs)}."


def enrich_file(
    fpath: Path,
    lookup: dict[str, list[str]],
    source_filter: str,
    dry_run: bool,
) -> list[dict]:
    """
    Xử lý 1 file. Trả về list các row thay đổi (cho report).
    """
    doc = load_yaml_safe(fpath)
    if not doc:
        return []
    if doc.get("ldm", {}).get("source", "") != source_filter:
        return []

    raw = fpath.read_text(encoding="utf-8")
    new_raw = raw
    report_rows: list[dict] = []
    not_found: set[str] = set()

    for m in RE_COMMENT_LINE.finditer(raw):
        prefix    = m.group(1)   # indent + 'comment: '
        open_q    = m.group(2)   # " hoặc '
        kw        = m.group(3)   # 'FK target:' hoặc 'Lookup pair:'
        body_rest = m.group(4)   # phần còn lại sau keyword
        close_q   = m.group(5)   # quote đóng

        full_body = kw + body_rest   # toàn bộ nội dung comment (trong quote)

        if already_has_classification(full_body):
            continue

        entity_name = extract_entity_name(full_body)
        if not entity_name:
            continue

        if entity_name not in lookup:
            not_found.add(entity_name)
            continue

        ctxs = resolve_ctx(lookup[entity_name], source_filter)
        new_body = append_classification(full_body, ctxs)
        old_line = m.group(0)
        new_line = f"{prefix}{open_q}{new_body}{close_q}"

        report_rows.append({
            "file": fpath.name,
            "source": source_filter,
            "entity": doc.get("ldm", {}).get("logical_name", ""),
            "comment_old": full_body,
            "comment_new": new_body,
        })

        new_raw = new_raw.replace(old_line, new_line, 1)

    if not_found:
        for name in sorted(not_found):
            print(f"  [WARN] Entity not found in lookup: '{name}' (in {fpath.name})")

    if not dry_run and new_raw != raw:
        fpath.write_text(new_raw, encoding="utf-8")

    return report_rows


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", default="FMS", help="Source filter (default: FMS)")
    parser.add_argument("--dry-run", action="store_true", help="Không ghi file, chỉ report")
    args = parser.parse_args()

    yaml_files = sorted(ATOMIC_DIR.rglob("*.yaml"))
    print(f"Tìm thấy {len(yaml_files)} file YAML")
    print(f"Source filter: {args.source}  |  Dry-run: {args.dry_run}\n")

    # Bước 1: build lookup từ toàn bộ files
    print("Bước 1: Xây dựng entity lookup table...")
    lookup = build_entity_lookup(yaml_files)
    print(f"  → {len(lookup)} entities trong lookup table\n")

    # Bước 2 + 3: enrich từng file thuộc source_filter
    print(f"Bước 2: Enrich comments (source={args.source})...")
    all_rows: list[dict] = []
    files_changed = 0

    for fpath in yaml_files:
        rows = enrich_file(fpath, lookup, args.source, args.dry_run)
        if rows:
            files_changed += 1
            all_rows.extend(rows)

    print(f"  → {files_changed} files {'sẽ được' if args.dry_run else 'đã được'} cập nhật")
    print(f"  → {len(all_rows)} comment {'sẽ được' if args.dry_run else 'đã được'} bổ sung\n")

    # Xuất report
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    suffix = "_dryrun" if args.dry_run else ""
    report_path = REPORT_DIR / f"enrich_fk_comments_{args.source}{suffix}.csv"

    with open(report_path, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=["file", "source", "entity", "comment_old", "comment_new"])
        w.writeheader()
        w.writerows(all_rows)

    print(f"Report → {report_path}")

    # In 5 mẫu
    if all_rows:
        print("\nSample (5 mẫu đầu):")
        for r in all_rows[:5]:
            print(f"  [{r['entity']}]")
            print(f"    OLD: {r['comment_old']}")
            print(f"    NEW: {r['comment_new']}")
            print()


if __name__ == "__main__":
    main()
