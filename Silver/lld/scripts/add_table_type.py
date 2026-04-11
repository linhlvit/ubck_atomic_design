"""
add_table_type.py
=================
Script 1 lần dùng: tự động gán cột table_type vào manifest.csv theo rules.

Bộ giá trị:
  Fundamental  — Entity độc lập, Tier 1, surrogate key, SCD2
  Relative     — Entity phụ thuộc, SCD1/SCD2
  Fact Append  — Log/sự kiện, insert-only
  Snapshot     — Full load định kỳ, replace partition

Cách dùng:
  python add_table_type.py            # in bảng preview, không ghi file
  python add_table_type.py --apply    # ghi thẳng vào manifest.csv
"""

import csv
import sys
import io
import argparse
from pathlib import Path

# Fix encoding trên Windows terminal
if sys.stdout.encoding and sys.stdout.encoding.lower() not in ("utf-8", "utf-8-sig"):
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
if sys.stderr.encoding and sys.stderr.encoding.lower() not in ("utf-8", "utf-8-sig"):
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")

SCRIPT_DIR = Path(__file__).parent
MANIFEST   = SCRIPT_DIR.parent / "manifest.csv"

SHARED_ENTITIES = {
    "Involved Party Postal Address",
    "Involved Party Electronic Address",
    "Involved Party Alternative Identification",
}

# Các bcv_concept prefix/substring chỉ Fact Append pattern
FACT_APPEND_CONCEPT_KEYWORDS = [
    "ETL Pattern",
    "Activity Log",
    "Status Log",
    "Status History",
]

# Tên entity chứa các suffix này → Fact Append
FACT_APPEND_ENTITY_KEYWORDS = [
    "Activity Log",
    "Status Log",
    "Status History",
]

FACT_APPEND_BCO = {"Transaction"}

SNAPSHOT_KEYWORDS = ["Snapshot"]


def infer_table_type(row: dict) -> tuple[str, str]:
    """
    Trả về (table_type, reason).
    """
    silver_entity   = row["silver_entity"].strip()
    bcv_concept     = row["bcv_concept"].strip()
    bcv_core_object = row["bcv_core_object"].strip()
    group           = row["group"].strip()

    # 1. Shared entities → Relative
    if silver_entity in SHARED_ENTITIES:
        return "Relative", "Shared entity (IP Address / Electronic / Alt ID)"

    # 2. Snapshot (tên entity chứa "Snapshot") → Snapshot
    if any(kw in silver_entity for kw in SNAPSHOT_KEYWORDS):
        return "Snapshot", f"silver_entity chứa '{[kw for kw in SNAPSHOT_KEYWORDS if kw in silver_entity][0]}'"

    # 3a. bcv_concept chứa ETL Pattern / Activity Log keywords → Fact Append
    matched_kw = [kw for kw in FACT_APPEND_CONCEPT_KEYWORDS if kw in bcv_concept]
    if matched_kw:
        return "Fact Append", f"bcv_concept chứa '{matched_kw[0]}'"

    # 3b. silver_entity chứa Activity Log / Status Log / Status History → Fact Append
    matched_ek = [kw for kw in FACT_APPEND_ENTITY_KEYWORDS if kw in silver_entity]
    if matched_ek:
        return "Fact Append", f"silver_entity chứa '{matched_ek[0]}'"

    # 4. bcv_core_object = Transaction → Fact Append
    if bcv_core_object in FACT_APPEND_BCO:
        return "Fact Append", f"bcv_core_object = {bcv_core_object}"

    # 5. Tier 1 (group=T1) không phải Snapshot/Fact → Fundamental
    if group == "T1":
        return "Fundamental", "group = T1"

    # 6. Default: Relative
    return "Relative", f"group = {group} (default)"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true",
                        help="Ghi vào manifest.csv (mặc định: chỉ preview)")
    args = parser.parse_args()

    with open(MANIFEST, encoding="utf-8", newline="") as f:
        rows = list(csv.DictReader(f))
        original_fields = list(csv.DictReader(open(MANIFEST, encoding="utf-8")).fieldnames)

    # Xác định vị trí chèn: sau silver_entity
    insert_after = "silver_entity"
    if insert_after not in original_fields:
        print(f"ERROR: Không tìm thấy cột '{insert_after}' trong manifest.csv", file=sys.stderr)
        sys.exit(1)

    new_fields = []
    for f in original_fields:
        new_fields.append(f)
        if f == insert_after:
            new_fields.append("table_type")

    # Gán giá trị
    counts = {"Fundamental": 0, "Relative": 0, "Fact Append": 0, "Snapshot": 0}
    print(f"\n{'source_system':<8} {'silver_entity':<55} {'table_type':<14} Lý do")
    print("-" * 120)

    for row in rows:
        tt, reason = infer_table_type(row)
        row["table_type"] = tt
        counts[tt] += 1
        se = row["silver_entity"][:53]
        ss = row["source_system"]
        print(f"  {ss:<8} {se:<55} {tt:<14} {reason}")

    print(f"\n  Tổng: {len(rows)} rows")
    for k, v in counts.items():
        print(f"    {k:<14}: {v}")

    if args.apply:
        with open(MANIFEST, "w", encoding="utf-8", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=new_fields,
                                    lineterminator="\n", extrasaction="ignore")
            writer.writeheader()
            writer.writerows(rows)
        print(f"\n  Đã ghi: {MANIFEST}")
    else:
        print("\n  (Preview only — chạy với --apply để ghi vào manifest.csv)")


if __name__ == "__main__":
    main()
