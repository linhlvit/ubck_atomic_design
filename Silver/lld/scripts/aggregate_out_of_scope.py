"""
aggregate_out_of_scope.py
=========================
Tổng hợp bảng ngoài scope từ mục 7f của tất cả HLD Overview files
vào silver_out_of_scope.csv.

Nguồn dữ liệu:
  - <SOURCE>_HLD_Overview.md : đọc mục "## 7f. Bảng ngoài scope"
  - silver_out_of_scope.csv  : (output) rebuild toàn bộ từ HLD files

Grain: 1 dòng = 1 (source_system, source_table)
  Nếu 1 bảng xuất hiện nhiều dòng trong 7f → giữ nguyên (nhiều lý do).

Cách dùng:
  python aggregate_out_of_scope.py            # rebuild toàn bộ
  python aggregate_out_of_scope.py --source FMS   # chỉ source FMS (rebuild toàn bộ output)
  python aggregate_out_of_scope.py --dry-run  # in ra stdout, không ghi file
"""

import csv
import re
import sys
import io
import argparse
from pathlib import Path

# Fix encoding trên Windows terminal
if sys.stdout.encoding and sys.stdout.encoding.lower() not in ("utf-8", "utf-8-sig"):
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
if sys.stderr.encoding and sys.stderr.encoding.lower() not in ("utf-8", "utf-8-sig"):
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
SCRIPT_DIR = Path(__file__).parent
LLD_DIR    = SCRIPT_DIR.parent
HLD_DIR    = LLD_DIR.parent / "hld"
OUT_FILE   = HLD_DIR / "silver_out_of_scope.csv"

FIELDS = ["source_system", "source_table", "description", "group", "reason"]


# ---------------------------------------------------------------------------
# Parse mục 7f từ 1 HLD Overview file
# Returns: list of dict {source_system, source_table, description, group, reason}
# ---------------------------------------------------------------------------
def parse_7f(md_path: Path, source_system: str) -> list[dict]:
    text = md_path.read_text(encoding="utf-8")

    # Tìm section 7f — từ heading đến heading tiếp theo (## hoặc EOF)
    match = re.search(
        r"^#{2,3}\s+7f\b[^\n]*\n(.+?)(?=^#{2,3}\s|\Z)",
        text, re.MULTILINE | re.DOTALL
    )
    if not match:
        print(f"  [WARN] Không tìm thấy mục 7f trong {md_path.name}", file=sys.stderr)
        return []

    section = match.group(1)

    rows = []
    for line in section.splitlines():
        line = line.strip()
        # Chỉ xử lý dòng bảng Markdown có ít nhất 4 cột (| A | B | C | D |)
        if not line.startswith("|"):
            continue
        # Bỏ separator (---|---|...)
        if re.match(r"^\|[\s\-|]+\|$", line):
            continue

        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) < 4:
            continue

        group       = cells[0].strip()
        source_table = cells[1].strip()
        description  = cells[2].strip()
        reason       = cells[3].strip()

        # Bỏ header row
        if group.lower() in ("nhóm", "group") or source_table.lower() in ("source table", "bảng nguồn"):
            continue
        # Bỏ dòng rỗng / placeholder
        if not source_table or source_table in ("-", "—", "..."):
            continue

        rows.append({
            "source_system": source_system,
            "source_table":  source_table,
            "description":   description,
            "group":         group,
            "reason":        reason,
        })

    return rows


# ---------------------------------------------------------------------------
# Đọc tất cả HLD Overview files → tổng hợp
# ---------------------------------------------------------------------------
def build_out_of_scope(filter_source: str | None = None) -> list[dict]:
    all_rows: list[dict] = []

    pattern = f"{filter_source.upper()}_HLD_Overview.md" if filter_source else "*_HLD_Overview.md"
    md_files = sorted(HLD_DIR.glob(pattern))

    if not md_files:
        print(f"  [WARN] Không tìm thấy Overview file nào (pattern: {pattern})", file=sys.stderr)
        return all_rows

    for md_path in md_files:
        # Lấy source_system từ tên file: FMS_HLD_Overview.md → FMS
        source_system = md_path.name.split("_HLD_")[0]
        print(f"  Đọc {md_path.name} ({source_system})...", file=sys.stderr)
        rows = parse_7f(md_path, source_system)
        print(f"    {len(rows)} dòng ngoài scope", file=sys.stderr)
        all_rows.extend(rows)

    # Nếu filter_source: chỉ rebuild output cho source đó, giữ lại các source khác
    if filter_source and OUT_FILE.exists():
        existing = []
        with open(OUT_FILE, encoding="utf-8", newline="") as f:
            for row in csv.DictReader(f):
                if row["source_system"].upper() != filter_source.upper():
                    existing.append(row)
        all_rows = existing + all_rows

    # Sort: source_system → group → source_table
    all_rows.sort(key=lambda r: (r["source_system"], r["group"], r["source_table"]))

    return all_rows


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(
        description="Tổng hợp bảng ngoài scope Silver từ mục 7f của HLD Overview files."
    )
    parser.add_argument("--source", help="Chỉ xử lý source system này (VD: FMS)")
    parser.add_argument("--dry-run", action="store_true",
                        help="In ra stdout, không ghi file")
    args = parser.parse_args()

    print("Build silver_out_of_scope...", file=sys.stderr)
    rows = build_out_of_scope(filter_source=args.source)
    print(f"  {len(rows)} dòng tổng cộng", file=sys.stderr)

    if args.dry_run:
        out = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8-sig", newline="")
        writer = csv.DictWriter(out, fieldnames=FIELDS, lineterminator="\n",
                                extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)
        out.flush()
    else:
        with open(OUT_FILE, "w", encoding="utf-8-sig", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=FIELDS, lineterminator="\n",
                                    extrasaction="ignore")
            writer.writeheader()
            writer.writerows(rows)
        print(f"  Ghi: {OUT_FILE}", file=sys.stderr)

    print("Hoàn thành.", file=sys.stderr)


if __name__ == "__main__":
    main()
