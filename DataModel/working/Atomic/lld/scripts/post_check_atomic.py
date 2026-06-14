"""
post_check_atomic.py
Đọc atomic_attributes.yaml, kiểm tra tiêu chí chất lượng, in báo cáo.
Không sửa file nào.
Cách dùng: python DataModel/working/Atomic/lld/scripts/post_check_atomic.py
"""
import sys
import io
import yaml
from pathlib import Path
from collections import defaultdict

# Fix encoding trên Windows terminal
if sys.stdout.encoding and sys.stdout.encoding.lower() not in ("utf-8", "utf-8-sig"):
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

SCRIPT_DIR = Path(__file__).parent
ATTRS_FILE = SCRIPT_DIR.parent.parent / "aggregate" / "atomic_attributes.yaml"

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
    data = yaml.safe_load(Path(path).read_text(encoding="utf-8"))
    raw = (data or {}).get("attributes", [])
    # Chuẩn hóa: bool → string để logic check không thay đổi
    rows = []
    for a in raw:
        r = dict(a)
        for k in ("nullable", "is_primary_key"):
            v = r.get(k)
            if isinstance(v, bool):
                r[k] = "true" if v else "false"
            elif v is None:
                r[k] = ""
        for k in ("source_column", "comment", "classification_context", "etl_derived_value",
                  "bcv_core_object", "atomic_entity", "atomic_attribute", "atomic_table",
                  "atomic_column", "data_domain", "data_type", "source_system", "source_table"):
            if r.get(k) is None:
                r[k] = ""
        rows.append(r)
    return rows


def check_empty_context(rows):
    """C1: source có source_column rỗng cho mọi attr → nguồn không map được gì."""
    by_src = defaultdict(list)
    for r in rows:
        key = (r["atomic_entity"], r["source_system"], r["source_table"])
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
        ent = r["atomic_entity"]
        attr = r["atomic_attribute"].lower()
        if ent in SHARED_ENTITIES:
            continue
        for kw in CONTACT_KEYWORDS:
            if kw in attr and (ent, r["atomic_attribute"]) not in seen:
                seen.add((ent, r["atomic_attribute"]))
                issues.append(f"  {ent}.{r['atomic_attribute']}")
                break
    return issues


def check_domain_inconsistency(rows):
    """C3: cùng tên attr, data_domain khác nhau giữa các entity khác nhau."""
    attr_domains = defaultdict(set)
    for r in rows:
        if r["data_domain"]:
            attr_domains[r["atomic_attribute"]].add(r["data_domain"])
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
        key = (r["atomic_entity"], r["atomic_attribute"])
        if (r.get("is_primary_key", "").lower() == "true"
                and r.get("nullable", "").lower() == "true"
                and key not in seen):
            seen.add(key)
            issues.append(f"  {r['atomic_entity']}.{r['atomic_attribute']}")
    return issues


def check_source_column_format(rows):
    """C5: source_column không rỗng nhưng không đúng 3 phần SOURCE.table.column (cần đúng 2 dấu chấm)."""
    seen = set()
    issues = []
    for r in rows:
        col = r.get("source_column", "").strip()
        if not col:
            continue
        key = (r["atomic_entity"], r["source_system"], r["source_table"], col)
        if key in seen:
            continue
        seen.add(key)
        if col.count(".") != 2:
            issues.append(f"  {r['atomic_entity']}.{r['atomic_attribute']} <- '{col}'")
    return issues


def check_physical_name_chars(rows):
    """C6: atomic_table hoặc atomic_column chứa ký tự không hợp lệ (ngoài a-z, 0-9, _)."""
    import re
    valid = re.compile(r"^[a-z0-9_]+$")
    seen = set()
    issues = []
    for r in rows:
        for col in ("atomic_table", "atomic_column"):
            val = r.get(col, "").strip()
            if not val or val in seen:
                continue
            seen.add(val)
            if not valid.match(val):
                issues.append(f"  {col}='{val}'  ({r['atomic_entity']})")
    return issues




def check_etl_derived_missing(rows):
    """C7: Classification Value có classification_context dạng SCHEME=VALUE hoặc SOURCE_SYSTEM=...
    nhưng etl_derived_value trống — ETL engineer sẽ không biết giá trị cần hardcode."""
    seen = set()
    issues = []
    for r in rows:
        if r.get("data_domain", "").strip() != "Classification Value":
            continue
        ctx = r.get("classification_context", "").strip()
        etl = r.get("etl_derived_value", "").strip()
        # Chỉ check khi context có dạng SCHEME=VALUE (có dấu =, không phải placeholder =(source))
        if "=" not in ctx or ctx.endswith("=(source)"):
            continue
        key = (r["atomic_entity"], r["source_system"], r["source_table"],
               r["atomic_attribute"], ctx)
        if key in seen:
            continue
        seen.add(key)
        if not etl:
            issues.append(
                f"  {r['atomic_entity']}.{r['atomic_attribute']}"
                f"  [{r['source_system']}.{r['source_table']}]"
                f"  ctx='{ctx}'"
            )
    return issues


def check_source_system_code(rows):
    """C8: Source System Code (src_stm_code) phải có:
    - classification_context = SOURCE_SYSTEM=NHNCK.TABLE (không free-text, không bare, không trống)
    - etl_derived_value = NHNCK.TABLE (không trống)
    """
    seen = set()
    issues = []
    for r in rows:
        if r.get("atomic_attribute", "").strip() != "src_stm_code":
            continue
        key = (r["atomic_entity"], r["source_system"], r["source_table"])
        if key in seen:
            continue
        seen.add(key)
        ctx = r.get("classification_context", "").strip()
        etl = r.get("etl_derived_value", "").strip()
        prefix = f"  {r['atomic_entity']}  [{r['source_system']}.{r['source_table']}]"
        if not ctx.startswith("SOURCE_SYSTEM="):
            issues.append(
                f"{prefix}  classification_context='{ctx}' (phải là SOURCE_SYSTEM=...)"
            )
        elif not etl:
            issues.append(
                f"{prefix}  etl_derived_value trống (phải là '{ctx.split('=', 1)[1]}')"
            )
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
        print(f"[ERROR] Không tìm thấy {ATTRS_FILE}. Chạy aggregate_atomic.py trước.")
        sys.exit(1)
    rows = load(ATTRS_FILE)
    print(f"Đọc {ATTRS_FILE.name}: {len(rows)} entries")

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

    report("C6 – Physical name chứa ký tự không hợp lệ (ngoài a-z, 0-9, _)",
           check_physical_name_chars(rows),
           "Mọi physical name đều hợp lệ.")

    report("C7 – Classification Value có context SCHEME=VALUE nhưng etl_derived_value trống",
           check_etl_derived_missing(rows),
           "Mọi Classification Value với context cố định đều có etl_derived_value.")

    report("C8 – Source System Code: classification_context hoặc etl_derived_value sai/trống",
           check_source_system_code(rows),
           "Mọi src_stm_code đều có classification_context và etl_derived_value chuẩn.")

    print(f"\n{'=' * 60}")
    print("Hoàn thành post-check.")


if __name__ == "__main__":
    main()
