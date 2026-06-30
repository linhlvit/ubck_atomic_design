"""
Script sinh BRD YAML cho nguồn FIMS từ 2 file CSV:
- Source/FIMS_Tables.csv
- Source/FIMS_Columns.csv

Output:
- BRD/Source/brd_FIMS.yaml
- BRD/Source/FIMS/brd_FIMS_{TABLE}.yaml  (1 file / bảng)
"""
import csv
import os
import re
from pathlib import Path

BASE_DIR = Path(__file__).parent.parent
TABLES_CSV = BASE_DIR / "Source" / "FIMS_Tables.csv"
COLUMNS_CSV = BASE_DIR / "Source" / "FIMS_Columns.csv"
OUT_DIR = BASE_DIR / "BRD" / "Source" / "FIMS"
MAIN_YAML = BASE_DIR / "BRD" / "Source" / "brd_FIMS.yaml"

OUT_DIR.mkdir(parents=True, exist_ok=True)

# ─── Bảng loại trừ ────────────────────────────────────────────────────────────
SKIP_TABLES = {"flyway_schema_history"}

def is_rptvalues_partition(name: str) -> bool:
    """RPTVALUES12016, RPTVALUES32024... là partition tự động — bỏ qua"""
    return bool(re.match(r'^RPTVALUES[1-9]\d*20\d{2}$', name.upper()))

# ─── Đọc Tables.csv ───────────────────────────────────────────────────────────
tables_order = []   # giữ thứ tự gốc
table_meaning = {}

with open(TABLES_CSV, encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    for row in reader:
        name = row["Tên bảng"].strip()
        meaning = row["Ý nghĩa bảng"].strip()
        if name in SKIP_TABLES or is_rptvalues_partition(name):
            continue
        tables_order.append(name)
        table_meaning[name] = meaning

print(f"Tổng bảng (sau lọc): {len(tables_order)}")

# ─── Đọc Columns.csv ──────────────────────────────────────────────────────────
table_columns = {}  # {TABLE: [col_dict, ...]}

def extract_fk_from_desc(desc: str) -> str | None:
    """Extract FK note từ Mô tả khi cột Ghi chú trống.
    VD: 'FK -> NATIONAL: Quốc gia/quốc tịch' → 'FK → NATIONAL'
    """
    if not desc:
        return None
    m = re.search(r'FK\s*[-–→>]+\s*([A-Z][A-Z0-9_]*)', desc, re.I)
    if m:
        ref = m.group(1).upper()
        return f"FK → {ref}"
    return None

with open(COLUMNS_CSV, encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    for row in reader:
        tbl = row["Tên bảng"].strip()
        if tbl in SKIP_TABLES or is_rptvalues_partition(tbl):
            continue
        if tbl not in table_columns:
            table_columns[tbl] = []
        raw_key   = row["Khóa"].strip() or None
        raw_note  = row["Ghi chú (FK suy luận)"].strip() or None
        raw_desc  = row["Mô tả"].strip()

        # Chuẩn hoá key: chỉ nhận PK / FK / PK/FK / null
        if raw_key not in ("PK", "FK", "PK/FK"):
            raw_key = None

        # Nếu không có FK note nhưng mô tả chứa "FK ->" → suy luận
        if raw_note is None and raw_key is None:
            inferred = extract_fk_from_desc(raw_desc)
            if inferred:
                raw_key  = "FK"
                raw_note = inferred

        col = {
            "name":        row["Tên trường"].strip(),
            "data_type":   row["Kiểu dữ liệu"].strip(),
            "description": raw_desc,
            "key":         raw_key,
            "fk_note":     raw_note,
        }
        table_columns[tbl] = table_columns.get(tbl, []) + [col]

# ─── Functional group mapping ─────────────────────────────────────────────────
FUNC_GROUPS = {
    "FIMS.1 Quản trị phân hệ": {
        "USERS","USERSMENUS","USERSMENUS_CLONE","USERRPTI","USERRPTO","REFRESHTOKEN",
        "GROUPS","GROUPUSERS","GROUPROLES","ROLES","ROLESMENUS","MENUS","MENUS_BU",
        "MENU_CLONE","MODULES","PERMISSIONS","CERTFCATE","ERRORLOG","USERSESSIONS",
        "AUDIT_LOGS","USER_DATA_PERMISSION","API_MAPPINGS","SHEDLOCK",
    },
    "FIMS.2 Biểu mẫu báo cáo đầu vào": {
        "RPTTEMP","SHEET","RPTPERIOD","RPTPDSHT","RPTHTORY","FORM_SCHEMAS",
        "FORM_SCHEMA_VERSIONS","RPT_FIELD_CATALOG","RPT_FIELD_CATALOG_USAGE",
        "RPT_VALUE_CATALOG","REPORT_TEMPLATES","SELFSETPD",
    },
    "FIMS.3 Biểu mẫu báo cáo đầu ra": {
        "RPTTPOUT","SHEETOUT","TPOUTHTORY","RPTOUTMANAGEMENT","RPTOUTFILESAVE",
    },
    "FIMS.4 Hệ thống động (Dynamic)": {
        "DYNAMICCOLUMNS","DYNAMICCONNECTIONS","DYNAMICTABLES",
    },
    "FIMS.5 Danh mục dùng chung": {
        "LOCATION","NATIONAL","STATUS","JOBTYPE","SECURITIESTYPE","SECURITIES",
        "STOCKHOLDERTYPE","COMPANYTYPE","BUSINESS","CURRENCY","DEGREE","UNIT",
        "DEPARTMENT","VIOLATIONTYPE","REPORTTYPE","INVESTORTYPE","RELATEDPROPERTIES",
        "RELATIONSHIP","ANNOUNCETYPE","CALENDAR","CALENDARMANAGERMENT","SYSVAR",
        "CLOSING_PRICE_SECURITIES",
    },
    "FIMS.6 Nhà đầu tư nước ngoài": {
        "INVESTOR","INVESTORHIS","SECURITIESACCOUNT","SECURITIESACCOUNTHIS",
        "CATEGORIESSTOCK","CATEGORIESSTOCKHIS","TRADINGREPRESENTATIVE",
    },
    "FIMS.7 Thành viên thị trường": {
        "STOCKEXCHANGE","DEPOSITORYCENTER","FUNDCOMPANY","FUNDCOMBUSINES","FUNDCOMTYPE",
        "SECURITIESCOMPANY","SECCOMBUSINES","SECCOMTYPE","BANKMONI","BRANCHS",
        "BRANCHSBUSINES","INFODISCREPRES","INDIREBUSINESS","TLPROFILES","TLPROJOB",
        "TLPROSTOCKH",
    },
    "FIMS.8 Báo cáo thành viên": {
        "RPTMEMBER","RPTVALUESMANAGERMENT","RPTVALUES","RPTPROCESS",
        "RPT_EVENT_TYPE","RPT_EVENT_TYPE_LEGAL_BASIS","RPT_EVENT_TYPE_SCHEDULE",
        "RPT_EVENT_TYPE_STATUS_LINK",
    },
    "FIMS.9 Cảnh báo và vi phạm": {
        "PARAWARN","CDTWARN","VIOLT",
    },
    "FIMS.10 Ủy quyền CBTT và giao dịch": {
        "AUTHOANNOUNCE","AUTHOANNOUNCEHIS","ANNOUNCEINVES","ANNOUNCEINVESHIS",
        "ANNOUNCE","TRADINGAUTHORIZATION","TRADINGAUTHORIZATIONHIS",
        "TRADINGAUTHORIZATIONINVES","TRADINGAUTHORIZATIONINVESHIS",
    },
    "FIMS.11 Trao đổi thông tin": {
        "NOTIFICATION","EMAILSENTSYSTEM","SYSEMAIL","DOCUMENT",
    },
    "FIMS.12 Tích hợp hệ thống": {
        "SYSTEMINTEGRATIONCONFIG","SYSTEMINTEGRATIONDATA",
    },
}

TABLE_TO_GROUP = {}
for group, tbls in FUNC_GROUPS.items():
    for t in tbls:
        TABLE_TO_GROUP[t] = group

def get_group(name: str) -> str:
    return TABLE_TO_GROUP.get(name.upper(), "FIMS.99 Khác")

# ─── scope_status logic ───────────────────────────────────────────────────────
SYSTEM_TABLES = {
    "SHEDLOCK","AUDIT_LOGS","ERRORLOG","USERSMENUS_CLONE","MENU_CLONE",
    "API_MAPPINGS","MODULES","PERMISSIONS","MENUS_BU","USER_DATA_PERMISSION",
    "REFRESHTOKEN","USERSESSIONS","CERTFCATE",
}
IT_INFRA_GROUPS = {"FIMS.1 Quản trị phân hệ", "FIMS.4 Hệ thống động (Dynamic)"}

def get_scope(name: str, group: str):
    if name.upper() in SYSTEM_TABLES:
        return "out_of_scope", "Operational/system data — không thiết kế Atomic"
    if group in IT_INFRA_GROUPS:
        return "out_of_scope", "Operational/system data — hạ tầng IT ứng dụng"
    return "out_of_scope", "Chờ thiết kế LLD"

# ─── ingestion logic ──────────────────────────────────────────────────────────
UPDATE_KEYWORDS = {"datemodified","modifyby","updated_at","updatedat","date_modified","modify_by"}
CREATE_KEYWORDS = {"datecreated","createdat","created_at","date_created"}

def get_ingestion(name: str) -> dict:
    cols = [c["name"].lower().replace("_","") for c in table_columns.get(name, [])]
    has_update = any(any(k in c for k in UPDATE_KEYWORDS) for c in cols)
    has_create = any(any(k in c for k in CREATE_KEYWORDS) for c in cols)

    if has_update:
        return {"data_change_mode": "Update", "filter_logic": None, "filter_note": None}
    if has_create:
        # Tìm tên cột thực tế
        actual_col = None
        for c in table_columns.get(name, []):
            cn = c["name"].lower().replace("_","")
            if any(k in cn for k in CREATE_KEYWORDS):
                actual_col = c["name"]
                break
        if actual_col:
            fc = actual_col.lower()
            return {
                "data_change_mode": "Append",
                "filter_logic": f"{fc} >= {{{{etl_date}}}} AND {fc} < {{{{etl_date}}}} + 1",
                "filter_note": f"Lọc theo cột {actual_col} — bảng chỉ append, không cập nhật dòng cũ",
            }
    return {"data_change_mode": "Update", "filter_logic": None, "filter_note": None}

# ─── related_tables: xây dựng từ FK trong columns ────────────────────────────
def get_related(name: str) -> list:
    """
    Chiều 1: bảng hiện tại có cột FK trỏ ra ngoài.
    Chiều 2: bảng khác có FK trỏ vào bảng này (reverse lookup).
    """
    rels = {}  # table -> relation string

    # Chiều 1: FK ra ngoài
    for col in table_columns.get(name, []):
        note = col.get("fk_note") or ""
        # "FK -> TABLE_NAME: ..." hoặc "FK → TABLE_NAME.COL"
        m = re.search(r'FK\s*[-–→>]+\s*([A-Z_][A-Z0-9_]*)', note, re.I)
        if m:
            ref = m.group(1).upper()
            if ref != name.upper() and ref not in rels:
                rels[ref] = f"FK cha — {table_meaning.get(ref, ref)}"

    # Chiều 2: bảng con trỏ vào bảng này
    for other_name, other_cols in table_columns.items():
        if other_name == name:
            continue
        for col in other_cols:
            note = col.get("fk_note") or ""
            m = re.search(r'FK\s*[-–→>]+\s*([A-Z_][A-Z0-9_]*)', note, re.I)
            if m and m.group(1).upper() == name.upper():
                if other_name not in rels:
                    rels[other_name] = f"1-N — {table_meaning.get(other_name, other_name)}"

    if not rels:
        return None
    return [{"table": t, "relation": r} for t, r in sorted(rels.items())]

# ─── YAML helpers ─────────────────────────────────────────────────────────────
def esc(s: str) -> str:
    """Escape double-quotes, wrap in double-quotes."""
    if s is None:
        return "null"
    s = str(s).replace('"', '\\"')
    return f'"{s}"'

def yaml_val(v) -> str:
    if v is None:
        return "null"
    return esc(v)

# ─── Sinh file cột ────────────────────────────────────────────────────────────
def write_column_file(name: str):
    cols = table_columns.get(name, [])
    lines = [
        "schema_type: brd_source_columns",
        "schema_version: '1.0'",
        f"source: FIMS",
        f"table: {name}",
        f"brd_ref: BRD-SRC-FIMS-{name}",
        "columns:",
    ]
    for col in cols:
        key_val = col["key"] if col["key"] else "null"
        lines.append(f"- name: {col['name']}")
        lines.append(f"  data_type: {esc(col['data_type'])}")
        lines.append(f"  description: {esc(col['description'])}")
        lines.append(f"  key: {key_val}")
        fk = col["fk_note"]
        lines.append(f"  fk_note: {yaml_val(fk)}")
    out_path = OUT_DIR / f"brd_FIMS_{name}.yaml"
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

# ─── Sinh file tổng hợp ───────────────────────────────────────────────────────
def write_main_yaml():
    # Nhóm bảng theo group, giữ thứ tự gốc trong CSV
    from collections import OrderedDict
    group_tables = OrderedDict()
    for name in tables_order:
        g = get_group(name)
        group_tables.setdefault(g, []).append(name)

    lines = [
        "schema_type: brd_source",
        "schema_version: '1.0'",
        "source: FIMS",
        'description: "Hệ thống quản lý giám sát và công bố thông tin thành viên thị trường (FIMS)"',
        "brd_entries:",
    ]

    for group, tbls in group_tables.items():
        sep = "─" * (70 - len(group) - 6)
        lines.append(f"  # ─── {group} {sep}")
        lines.append("")
        for name in tbls:
            scope_status, scope_reason = get_scope(name, group)
            ingestion = get_ingestion(name)
            rels = get_related(name)

            lines.append(f"  - brd_id: BRD-SRC-FIMS-{name}")
            lines.append(f'    brd_name: "Design Atomic từ nguồn FIMS bảng {name}"')
            lines.append("    type: Theo Source")
            lines.append("    ba_email: huy.pham@fssc.com.vn")
            lines.append("    steward_email: username@ubck.com.vn")
            lines.append("    content:")
            lines.append(f"      table_meaning: {esc(table_meaning.get(name, ''))}")
            lines.append(f"      functional_group: {esc(group)}")
            lines.append(f"      scope_status: {scope_status}")
            lines.append(f"      scope_reason: {yaml_val(scope_reason)}")
            lines.append(f"      table: {name}")

            # related_tables
            if rels is None:
                lines.append("      related_tables: null")
            else:
                lines.append("      related_tables:")
                for r in rels:
                    lines.append(f"        - table: {r['table']}")
                    lines.append(f"          relation: {esc(r['relation'])}")

            lines.append("      notes: null")
            lines.append("      data_volume_hint: null")
            lines.append("      refresh_frequency: null")
            lines.append("      ingestion:")
            lines.append(f"        data_change_mode: {ingestion['data_change_mode']}")
            fl = ingestion["filter_logic"]
            fn = ingestion["filter_note"]
            lines.append(f"        filter_logic: {yaml_val(fl)}")
            lines.append(f"        filter_note: {yaml_val(fn)}")
            lines.append("")

    MAIN_YAML.write_text("\n".join(lines), encoding="utf-8")

# ─── Main ─────────────────────────────────────────────────────────────────────
print("Sinh brd_FIMS.yaml ...")
write_main_yaml()
print(f"  -> {MAIN_YAML}")

print("Sinh files cột ...")
for name in tables_order:
    write_column_file(name)

col_files = list(OUT_DIR.glob("brd_FIMS_*.yaml"))
print(f"  -> {len(col_files)} files trong {OUT_DIR}")
print("Done.")
