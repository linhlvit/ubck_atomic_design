"""
post_check_source_coverage.py
=============================================================================
Kiểm tra các cột nguồn chưa được map vào Silver, và ngược lại.

Logic:
  CHECK A — Cột nguồn chưa map:
  1. Đọc manifest.csv → biết (source_system, source_table) nào đã được thiết kế
     lên Silver (bỏ qua group=pending).
  2. Đọc silver_attributes.csv → tập hợp cột đã map:
       source_column = "SOURCE.table.column" → (source_system, source_table, column)
  3. Đọc Source/<SOURCE>_Columns.csv → tất cả cột của từng bảng nguồn.
  4. Đọc pending_design.csv → tập hợp cột đang chờ thiết kế (pending).
  5. Với mỗi (source_system, source_table) đã thiết kế:
       - Lấy danh sách cột từ Columns file
       - Trừ đi cột đã map trong silver_attributes
       - Trừ đi cột trong pending_design.csv → in vào section [PENDING] riêng
       - Báo cáo cột còn thiếu (unmapped và không pending)

  CHECK B — source_column trong Silver trỏ đến cột không tồn tại trong nguồn:
  6. Với mỗi source_column trong silver_attributes.csv (đủ 3 phần):
       - Kiểm tra (source_system, source_table, column) có trong SOURCE_Columns.csv không
       - Nếu không → báo lỗi ghost mapping

Cột bỏ qua (không cần map):
  - Cột kỹ thuật / audit thông thường: NGAY_TAO, NGAY_CAP_NHAT, IS_BANG_TAM,
    NGUOI_TAO, NGUOI_CAP_NHAT, CREATED_AT, UPDATED_AT, CREATED_BY, UPDATED_BY,
    DATE_CREATED, DATE_MODIFIED, MODIFIED_BY, CREATED_DATE, MODIFIED_DATE,
    RECORD_STATUS, CURR_NO, INPUTTER, AUTHORISER, DATE_TIME, CO_CODE, DEPT_CODE,
    DELETED, IS_DELETED, ROWVERSION, ROW_VERSION, TIMESTAMP

Cách dùng:
  python Silver/lld/scripts/post_check_source_coverage.py
  python Silver/lld/scripts/post_check_source_coverage.py --source SCMS
  python Silver/lld/scripts/post_check_source_coverage.py --table CTCK_THONG_TIN
"""

import csv
import sys
import io
import argparse
from pathlib import Path
from collections import defaultdict

# Fix encoding trên Windows terminal
if sys.stdout.encoding and sys.stdout.encoding.lower() not in ("utf-8", "utf-8-sig"):
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

SCRIPT_DIR    = Path(__file__).parent
LLD_DIR       = SCRIPT_DIR.parent
SOURCE_DIR    = LLD_DIR.parent.parent / "Source"
MANIFEST      = LLD_DIR / "manifest.csv"
ATTRS_FILE    = LLD_DIR / "silver_attributes.csv"
PENDING_FILE  = LLD_DIR / "pending_design.csv"

# Cột kỹ thuật/audit bỏ qua
SKIP_COLUMNS = {
    c.upper() for c in [
        "NGAY_TAO", "NGAY_CAP_NHAT", "IS_BANG_TAM",
        "NGUOI_TAO", "NGUOI_CAP_NHAT",
        "CREATED_AT", "UPDATED_AT", "CREATED_BY", "UPDATED_BY",
        "DATE_CREATED", "DATE_MODIFIED", "MODIFIED_BY",
        "CREATED_DATE", "MODIFIED_DATE",
        "RECORD_STATUS", "CURR_NO", "INPUTTER", "AUTHORISER",
        "DATE_TIME", "CO_CODE", "DEPT_CODE",
        "DELETED", "IS_DELETED",
        "ROWVERSION", "ROW_VERSION", "TIMESTAMP",
        # SCMS / FIMS audit user IDs
        "NGUOI_TAO_ID", "NGUOI_CAP_NHAT_ID", "NGUOI_DUNG_ID",
        "USER_ID", "CREATED_USER_ID", "UPDATED_USER_ID",
        # FMS / FIMS audit/migration fields
        "MODIFYBY", "ISDATAMIGRATION", "IDOLD",
        "ISDELETE", "ISDELETED",
        # Binary/file attachment fields — không lưu Silver
        "FILEDATA", "FILEIMPORT", "DATAFILEIMPORT",
        # File attachment name/data fields — không lưu Silver
        "FILENAME", "FILE_DINH_KEM",
        # Internal sync flags
        "IS_SYNC", "THOI_GIAN_SYNC",
        # Migration / legacy IDs
        "IDSCMSOLD",
        # FIMS internal user FK — không phải Involved Party
        "USERID",
        # FIMS BRANCHS FK đến tổ chức cha — chưa map, out-of-scope T1
        "IDNOPARENT",
        # DCST internal messaging / integration fields — không phải data nghiệp vụ
        "GOI_TIN_ID", "OBJID", "GUID",
    ]
}


def load_pending_columns():
    """Trả về dict: (source_system, source_table, column_upper) → reason."""
    pending = {}
    if not PENDING_FILE.exists():
        return pending
    with open(PENDING_FILE, encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            ss  = row.get("source_system", "").strip()
            st  = row.get("source_table", "").strip()
            col = row.get("source_column", "").strip()
            reason = row.get("reason", "").strip()
            if ss and st and col:
                pending[(ss, st, col.upper())] = reason
    return pending


def load_manifest(filter_source=None, filter_table=None):
    """Trả về dict: (source_system, source_table) → group — bỏ qua pending."""
    result = {}
    with open(MANIFEST, encoding="utf-8", newline="") as f:
        for row in csv.DictReader(f):
            if row["group"] == "pending":
                continue
            ss = row["source_system"]
            st = row["source_table"]
            if filter_source and ss != filter_source:
                continue
            if filter_table and st != filter_table:
                continue
            result[(ss, st)] = row["group"]
    return result


def load_mapped_columns():
    """Trả về set (source_system, source_table, column_upper) đã map."""
    mapped = set()
    if not ATTRS_FILE.exists():
        return mapped
    with open(ATTRS_FILE, encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            col = row.get("source_column", "").strip()
            if not col:
                continue
            parts = col.split(".")
            if len(parts) == 3:
                mapped.add((parts[0], parts[1], parts[2].upper()))
    return mapped


def load_source_columns(source_system):
    """Trả về dict: source_table → list[column_upper]."""
    path = SOURCE_DIR / f"{source_system}_Columns.csv"
    if not path.exists():
        return None
    result = defaultdict(list)
    with open(path, encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            table = row.get("Tên bảng", "").strip()
            col   = row.get("Tên trường", "").strip()
            if table and col:
                result[table].append(col)
    return result


def load_all_source_columns():
    """Trả về set (source_system, source_table, column_upper) từ tất cả *_Columns.csv."""
    known = set()
    known_tables: dict[tuple, set] = defaultdict(set)  # (ss, st) → set of col_upper
    for path in SOURCE_DIR.glob("*_Columns.csv"):
        ss = path.stem.replace("_Columns", "")
        with open(path, encoding="utf-8-sig", newline="") as f:
            for row in csv.DictReader(f):
                table = row.get("Tên bảng", "").strip()
                col   = row.get("Tên trường", "").strip()
                if table and col:
                    known.add((ss, table, col.upper()))
                    known_tables[(ss, table)].add(col.upper())
    return known, known_tables


def load_silver_source_columns(filter_source=None, filter_table=None):
    """Trả về list (source_system, source_table, col_orig, silver_entity, silver_attr)
    cho mọi source_column trong silver_attributes.csv có đủ 3 phần."""
    rows = []
    if not ATTRS_FILE.exists():
        return rows
    with open(ATTRS_FILE, encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            col = row.get("source_column", "").strip()
            if not col:
                continue
            parts = col.split(".")
            if len(parts) != 3:
                continue
            ss, st, c = parts[0], parts[1], parts[2]
            if filter_source and ss != filter_source:
                continue
            if filter_table and st != filter_table:
                continue
            rows.append((ss, st, c, row.get("silver_entity", ""), row.get("silver_attribute", "")))
    return rows


def main():
    parser = argparse.ArgumentParser(description="Check unmapped source columns")
    parser.add_argument("--source", help="Chỉ kiểm tra 1 source system (VD: SCMS)")
    parser.add_argument("--table",  help="Chỉ kiểm tra 1 source table (VD: CTCK_THONG_TIN)")
    args = parser.parse_args()

    designed  = load_manifest(filter_source=args.source, filter_table=args.table)
    mapped    = load_mapped_columns()
    pending   = load_pending_columns()

    # Group theo source_system
    by_source = defaultdict(list)
    for (ss, st) in designed:
        by_source[ss].append(st)

    total_unmapped = 0
    total_pending  = 0

    for ss in sorted(by_source):
        src_cols = load_source_columns(ss)
        if src_cols is None:
            print(f"\n[WARN] Không tìm thấy Source/{ss}_Columns.csv — bỏ qua {ss}")
            continue

        source_unmapped = []
        source_pending  = []

        for st in sorted(by_source[ss]):
            if st not in src_cols:
                source_unmapped.append(f"  [WARN] Bảng '{st}' không có trong {ss}_Columns.csv")
                continue

            all_cols = src_cols[st]
            unmapped = []
            pend     = []
            for c in all_cols:
                cu = c.upper()
                if cu in SKIP_COLUMNS:
                    continue
                if (ss, st, cu) in mapped:
                    continue
                if (ss, st, cu) in pending:
                    pend.append((c, pending[(ss, st, cu)]))
                else:
                    unmapped.append(c)

            if unmapped:
                source_unmapped.append(f"\n  {ss}.{st}  ({len(unmapped)} cột chưa map):")
                for c in unmapped:
                    source_unmapped.append(f"    - {c}")
                total_unmapped += len(unmapped)

            if pend:
                source_pending.append(f"\n  {ss}.{st}  ({len(pend)} cột pending):")
                for c, reason in pend:
                    source_pending.append(f"    ~ {c}  [{reason}]")
                total_pending += len(pend)

        if source_unmapped:
            print(f"\n{'=' * 60}")
            print(f"[UNMAPPED] {ss}")
            for line in source_unmapped:
                print(line)

        if source_pending:
            print(f"\n{'=' * 60}")
            print(f"[PENDING] {ss}")
            for line in source_pending:
                print(line)

    print(f"\n{'=' * 60}")
    if total_unmapped == 0:
        print("✓  CHECK A: Mọi cột nguồn đã được thiết kế đều có mapping trong Silver.")
    else:
        print(f"⚠  CHECK A: Tổng {total_unmapped} cột nguồn chưa map.")
    if total_pending > 0:
        print(f"~  CHECK A: Tổng {total_pending} cột đang pending (xem pending_design.csv).")

    # ── CHECK B: source_column trong Silver trỏ đến cột không tồn tại trong nguồn ──
    known_cols, known_tables = load_all_source_columns()
    silver_src_rows = load_silver_source_columns(
        filter_source=args.source, filter_table=args.table
    )

    ghost_by_source: dict[str, list] = defaultdict(list)
    seen_ghost: set = set()
    for ss, st, col, ent, attr in silver_src_rows:
        key = (ss, st, col.upper())
        if key in seen_ghost:
            continue
        seen_ghost.add(key)
        # Nếu source file không tồn tại → không thể kiểm tra, bỏ qua
        if not (SOURCE_DIR / f"{ss}_Columns.csv").exists():
            continue
        if key not in known_cols:
            # Phân biệt: bảng tồn tại nhưng cột không tồn tại vs bảng không tồn tại
            if (ss, st) in known_tables or any(t == st for (s, t) in [(k[0], k[1]) for k in known_cols if k[0] == ss]):
                ghost_by_source[ss].append(
                    f"  {ss}.{st}.{col}  →  {ent}.{attr}"
                )
            else:
                ghost_by_source[ss].append(
                    f"  {ss}.{st}.{col}  →  {ent}.{attr}  [bảng '{st}' không có trong Columns file]"
                )

    total_ghost = sum(len(v) for v in ghost_by_source.values())
    if ghost_by_source:
        for ss in sorted(ghost_by_source):
            print(f"\n{'=' * 60}")
            print(f"[GHOST] {ss}  — source_column trỏ đến cột không tồn tại trong nguồn:")
            for line in ghost_by_source[ss]:
                print(line)

    print(f"\n{'=' * 60}")
    if total_ghost == 0:
        print("✓  CHECK B: Mọi source_column trong Silver đều tồn tại trong nguồn.")
    else:
        print(f"⚠  CHECK B: Tổng {total_ghost} source_column trỏ đến cột không tồn tại.")

    print("\nGhi chú: Cột kỹ thuật/audit (NGAY_TAO, NGAY_CAP_NHAT...) được bỏ qua tự động.")
    print("Nếu cột cố ý không map (out-of-scope), thêm vào SKIP_COLUMNS hoặc ghi chú trong attr file.")


if __name__ == "__main__":
    main()
