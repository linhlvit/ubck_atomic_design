"""Back-fill nullable + FK Code comment cho toàn bộ attr_*.csv trong Silver/lld/.

Theo quy tắc mới (silver-lld-design SKILL.md Bước 3.5 và Bước 5):

1. **Nullable rule:**
   - PK Surrogate Key (`{Entity} Id` với `is_primary_key=true`) → `nullable=false`
   - BK Code (`{Entity} Code` với `is_primary_key=true`) → `nullable=false`
   - `Source System Code` → `nullable=false`
   - Classification Value có `etl_derived_value` non-empty (hardcode) → `nullable=false`
   - Cặp Id+Code (FK): nếu mismatch nullable → flag (không tự sửa)

2. **FK comment Code:**
   - Row có `attribute_name` kết thúc bằng "Code" + comment chứa "Pair with"
   - Đổi prefix `FK target:` → `Lookup pair:` (chỉ Id mới giữ `FK target:`)

Usage:
    python backfill_nullable_and_fk_comments.py                    # dry-run
    python backfill_nullable_and_fk_comments.py --apply            # ghi thay đổi
    python backfill_nullable_and_fk_comments.py --source FIMS      # chỉ 1 source
    python backfill_nullable_and_fk_comments.py --source FIMS --apply
"""

from __future__ import annotations

import argparse
import csv
import io
import sys
from pathlib import Path

# Windows console default cp1252 → ép UTF-8 cho stdout/stderr
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")

REPO_ROOT = Path(__file__).resolve().parents[3]
LLD_DIR = REPO_ROOT / "Silver" / "lld"


def is_pk_id_or_code(row: dict) -> bool:
    return (row.get("is_primary_key") or "").strip().lower() == "true"


def is_source_system_code(row: dict) -> bool:
    return (row.get("attribute_name") or "").strip() == "Source System Code"


def is_classification_hardcode(row: dict) -> bool:
    return (
        (row.get("data_domain") or "").strip() == "Classification Value"
        and bool((row.get("etl_derived_value") or "").strip())
    )


def should_force_not_null(row: dict) -> tuple[bool, str]:
    """Return (force_not_null, reason)."""
    if is_pk_id_or_code(row):
        return True, "PK"
    if is_source_system_code(row):
        return True, "Source System Code"
    if is_classification_hardcode(row):
        return True, f"Classification hardcode ({row.get('etl_derived_value', '').strip()})"
    return False, ""


def fix_fk_code_comment(row: dict) -> tuple[str, bool]:
    """Đổi 'FK target:' → 'Lookup pair:' nếu attribute là Code và có 'Pair with' trong comment.

    Return (new_comment, changed).
    """
    name = (row.get("attribute_name") or "").strip()
    comment = row.get("comment") or ""
    if not name.endswith("Code"):
        return comment, False
    if "Pair with" not in comment:
        return comment, False
    if not comment.startswith("FK target:"):
        return comment, False
    new_comment = "Lookup pair:" + comment[len("FK target:"):]
    return new_comment, True


def process_file(path: Path, apply: bool) -> dict:
    """Process 1 attr_*.csv. Return stats."""
    with path.open(encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        fieldnames = reader.fieldnames
        rows = list(reader)

    if not rows or not fieldnames:
        return {"file": str(path.relative_to(REPO_ROOT)), "nullable_fixes": 0, "fk_fixes": 0, "pair_mismatches": []}

    nullable_fixes = []
    fk_fixes = []

    for row in rows:
        # Nullable
        force_nn, reason = should_force_not_null(row)
        if force_nn and (row.get("nullable") or "").strip().lower() == "true":
            nullable_fixes.append((row["attribute_name"], reason))
            row["nullable"] = "false"

        # FK Code comment
        new_comment, changed = fix_fk_code_comment(row)
        if changed:
            fk_fixes.append(row["attribute_name"])
            row["comment"] = new_comment

    # Pair mismatches: detect cặp Id/Code có nullable khác nhau
    pair_mismatches = _detect_pair_mismatches(rows)

    if apply and (nullable_fixes or fk_fixes):
        # Drop None key (gây ra bởi cell extra) — chỉ giữ field hợp lệ
        clean_rows = [{k: v for k, v in r.items() if k in fieldnames} for r in rows]
        with path.open("w", encoding="utf-8-sig", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames, lineterminator="\n")
            writer.writeheader()
            writer.writerows(clean_rows)

    return {
        "file": str(path.relative_to(REPO_ROOT)),
        "nullable_fixes": nullable_fixes,
        "fk_fixes": fk_fixes,
        "pair_mismatches": pair_mismatches,
    }


def _detect_pair_mismatches(rows: list[dict]) -> list[tuple[str, str]]:
    """Detect cặp Id/Code có nullable khác nhau (sau khi đã fix nullable cho PK).

    Cách: với mỗi row có attribute kết thúc 'Id', tìm row 'Pair with {Id field}' trong comment
    của row khác — đó là Code cùng cặp. So sánh nullable.
    """
    out = []
    by_name = {(r.get("attribute_name") or "").strip(): r for r in rows if r.get("attribute_name")}
    for r in rows:
        name = (r.get("attribute_name") or "").strip()
        if not name.endswith("Code"):
            continue
        comment = r.get("comment") or ""
        if "Pair with" not in comment:
            continue
        # Tìm tên Id trong "Pair with X Id"
        idx = comment.find("Pair with")
        rest = comment[idx + len("Pair with"):].strip()
        # Tách đến dấu "." hoặc cuối câu
        end = rest.find(".")
        id_field = rest[:end].strip() if end > 0 else rest.strip()
        if id_field not in by_name:
            continue
        id_row = by_name[id_field]
        if (id_row.get("nullable") or "").strip() != (r.get("nullable") or "").strip():
            out.append((name, id_field))
    return out


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--apply", action="store_true", help="Ghi thay đổi vào file. Mặc định dry-run.")
    parser.add_argument("--source", help="Chỉ xử lý 1 source (vd: FIMS). Mặc định: tất cả.")
    args = parser.parse_args()

    if args.source:
        targets = [LLD_DIR / args.source]
        if not targets[0].exists():
            sys.exit(f"ERROR: {targets[0]} không tồn tại")
    else:
        targets = [d for d in LLD_DIR.iterdir() if d.is_dir() and d.name not in ("scripts", "__pycache__")]

    total_nullable = 0
    total_fk = 0
    total_mismatch = 0
    files_changed = 0

    for src_dir in sorted(targets):
        for csv_file in sorted(src_dir.glob("attr_*.csv")):
            stats = process_file(csv_file, args.apply)
            n = len(stats["nullable_fixes"])
            f = len(stats["fk_fixes"])
            m = len(stats["pair_mismatches"])
            if n or f or m:
                print(f"\n{stats['file']}")
                if n:
                    files_changed += 1
                    total_nullable += n
                    for attr, reason in stats["nullable_fixes"]:
                        print(f"  NULLABLE  {attr:50s} → false  ({reason})")
                if f:
                    if n == 0:
                        files_changed += 1
                    total_fk += f
                    for attr in stats["fk_fixes"]:
                        print(f"  FK COMMENT {attr:50s} → Lookup pair:")
                if m:
                    total_mismatch += m
                    for code, id_ in stats["pair_mismatches"]:
                        print(f"  WARN PAIR  {code} <-> {id_} có nullable khác nhau (cần sửa thủ công)")

    print(f"\n{'='*60}")
    print(f"Files có thay đổi: {files_changed}")
    print(f"Nullable fixes: {total_nullable}")
    print(f"FK comment fixes: {total_fk}")
    print(f"Pair mismatch warnings: {total_mismatch}")
    if args.apply:
        print("ĐÃ GHI thay đổi vào file.")
        print("Nhớ chạy aggregate_silver.py + post_check_silver.py sau khi back-fill.")
    else:
        print("DRY RUN — chưa ghi. Thêm --apply để ghi.")


if __name__ == "__main__":
    main()
