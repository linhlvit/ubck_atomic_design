"""Jinja2 custom filters dùng trong template silver_dbdesign*.md.

Quy ước UBCK template:
- Nullable / Unique: 'X' nếu Yes, '' (rỗng) nếu No
- P/F Key: 'P' (primary), 'F' (foreign), '' (rỗng) nếu không phải key
- Mặc định: lấy từ etl_derived_value, hoặc hardcode '<SOURCE>' cho source_system_code
"""

from __future__ import annotations

# Map BCV Data Domain → kiểu SQL/Spark hiển thị trong tài liệu thiết kế CSDL.
# Quy ước MVP — refine khi DBA chốt physical schema.
DATA_DOMAIN_SQL_MAP = {
    "Text": "STRING",
    "Date": "DATE",
    "Timestamp": "TIMESTAMP",
    "Currency Amount": "DECIMAL(18,2)",
    "Interest Rate": "DECIMAL(9,6)",
    "Exchange Rate": "DECIMAL(18,6)",
    "Percentage": "DECIMAL(9,6)",
    "Surrogate Key": "BIGINT",
    "Classification Value": "STRING",
    "Indicator": "STRING",
    "Boolean": "BOOLEAN",
    "Small Counter": "INT",
}


def data_domain_to_sql(domain: str) -> str:
    """Map BCV data domain → kiểu SQL display."""
    if not domain:
        return ""
    return DATA_DOMAIN_SQL_MAP.get(domain.strip(), domain.strip())


def x_or_blank(value) -> str:
    """True → 'X', False → ''."""
    if isinstance(value, bool):
        return "X" if value else ""
    return "X" if str(value).strip().lower() in ("true", "yes", "y", "1") else ""


def pk_fk_label(attr: dict) -> str:
    """Đoán nhãn P/F Key từ attribute dict.

    Quy ước UBCK template chỉ chấp nhận 'P', 'F' hoặc rỗng.

    - is_primary_key=True → 'P'
    - data_domain=Surrogate Key (không PK) → 'F' (nhánh thường: surrogate FK)
    - comment chứa 'FK' → 'F'
    - default '' (rỗng)
    """
    domain = attr.get("data_domain", "").strip()
    is_pk = attr.get("is_primary_key", False)
    comment = attr.get("comment", "").upper()

    if is_pk:
        return "P"
    if domain == "Surrogate Key":
        return "F"
    if "FK TARGET" in comment or " FK " in f" {comment} ":
        return "F"
    return ""


def default_value(attr: dict, source: str) -> str:
    """Tính giá trị mặc định cho cột Mặc định.

    Quy tắc:
    - attribute_name = 'Source System Code' → '<SOURCE>'
    - etl_derived_value non-empty → trích value sau dấu '='. Vd: 'POSTAL_TYPE=HEAD_OFFICE' → 'HEAD_OFFICE'
    - default rỗng
    """
    name = attr.get("attribute_name", "").strip().lower()
    if name == "source system code":
        return f"'{source}'"

    etl = (attr.get("etl_derived_value") or "").strip()
    if etl:
        if "=" in etl:
            return f"'{etl.split('=', 1)[1].strip()}'"
        return f"'{etl}'"
    return ""
