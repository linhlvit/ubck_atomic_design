"""
post_check_silver.py
Đọc silver_attributes.csv, kiểm tra 5 tiêu chí chất lượng, in báo cáo.
Không sửa file nào.
Cách dùng: python Silver/lld/scripts/post_check_silver.py
"""
import csv
import sys
import io
from pathlib import Path
from collections import defaultdict

# Fix encoding trên Windows terminal
if sys.stdout.encoding and sys.stdout.encoding.lower() not in ("utf-8", "utf-8-sig"):
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

SCRIPT_DIR = Path(__file__).parent
ATTRS_FILE = SCRIPT_DIR.parent / "silver_attributes.csv"

CONTACT_KEYWORDS = [
    "phone", "email", "fax", "address", "postal", "district",
    "ward", "street", "dien thoai", "dia chi", "phuong", "quan huyen",
]
SHARED_ENTITIES = {
    "Involved Party Postal Address",
    "Involved Party Electronic Address",
    "Involved Party Alternative Identification",
}


def load(path):
    with open(path, encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def check_empty_context(rows):
    """C1: source có source_column rỗng cho mọi attr → nguồn không map được gì."""
    by_src = defaultdict(list)
    for r in rows:
        key = (r["silver_entity"], r["source_system"], r["source_table"])
        by_src[key].append(r["source_column"])
    issues = []
    for (ent, ss, st), cols in sorted(by_src.items()):
        if all(c == "" for c in cols):
            issues.append(f"  {ent} <- {ss}.{st}  (0/{len(cols)} attrs mapped)")
    return issues


def check_contact_in_main(rows):
    """C2: attr tên chứa từ khóa liên lạc/địa chỉ nằm trong entity không phải shared."""
    seen = set()
    issues = []
    for r in rows:
        ent = r["silver_entity"]
        attr = r["silver_attribute"].lower()
        if ent in SHARED_ENTITIES:
            continue
        for kw in CONTACT_KEYWORDS:
            if kw in attr and (ent, r["silver_attribute"]) not in seen:
                seen.add((ent, r["silver_attribute"]))
                issues.append(f"  {ent}.{r['silver_attribute']}")
                break
    return issues


def check_domain_inconsistency(rows):
    """C3: cùng tên attr, data_domain khác nhau giữa các entity khác nhau."""
    attr_domains = defaultdict(set)
    for r in rows:
        if r["data_domain"]:
            attr_domains[r["silver_attribute"]].add(r["data_domain"])
    issues = []
    for attr, domains in sorted(attr_domains.items()):
        if len(domains) > 1:
            issues.append(f"  '{attr}': {', '.join(sorted(domains))}")
    return issues


def check_pk_nullable(rows):
    """C4: is_primary_key=true AND nullable=true → mâu thuẫn."""
    seen = set()
    issues = []
    for r in rows:
        key = (r["silver_entity"], r["silver_attribute"])
        if (r.get("is_primary_key", "").lower() == "true"
                and r.get("nullable", "").lower() == "true"
                and key not in seen):
            seen.add(key)
            issues.append(f"  {r['silver_entity']}.{r['silver_attribute']}")
    return issues


def check_source_column_format(rows):
    """C5: source_column không rỗng nhưng không đúng 3 phần SOURCE.table.column (cần đúng 2 dấu chấm)."""
    seen = set()
    issues = []
    for r in rows:
        col = r.get("source_column", "").strip()
        if not col:
            continue
        key = (r["silver_entity"], r["source_system"], r["source_table"], col)
        if key in seen:
            continue
        seen.add(key)
        if col.count(".") != 2:
            issues.append(f"  {r['silver_entity']}.{r['silver_attribute']} <- '{col}'")
    return issues


def report(title, issues, ok_msg):
    print(f"\n{'=' * 60}")
    print(f"[CHECK] {title}")
    if issues:
        print(f"  ⚠  {len(issues)} vấn đề:")
        for i in issues:
            print(i)
    else:
        print(f"  ✓  {ok_msg}")


def main():
    if not ATTRS_FILE.exists():
        print(f"[ERROR] Không tìm thấy {ATTRS_FILE}. Chạy aggregate_silver.py trước.")
        sys.exit(1)
    rows = load(ATTRS_FILE)
    print(f"Đọc {ATTRS_FILE.name}: {len(rows)} dòng")

    report("C1 – Source không map được attr nào",
           check_empty_context(rows),
           "Mọi source đều có ít nhất 1 attr mapped.")

    report("C2 – Thông tin liên lạc/địa chỉ trong entity chính (nghi ngờ cần tách shared)",
           check_contact_in_main(rows),
           "Không phát hiện attr liên lạc/địa chỉ ngoài shared entity.")

    report("C3 – Cùng tên attr nhưng data_domain khác nhau giữa các entity",
           check_domain_inconsistency(rows),
           "Mọi attr cùng tên đều có data_domain nhất quán.")

    report("C4 – PK nullable=true (mâu thuẫn)",
           check_pk_nullable(rows),
           "Không có PK nào nullable=true.")

    report("C5 – source_column không đúng định dạng SOURCE.table.column",
           check_source_column_format(rows),
           "Mọi source_column đều đúng 3 phần.")

    print(f"\n{'=' * 60}")
    print("Hoàn thành post-check.")


if __name__ == "__main__":
    main()
