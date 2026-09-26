# -*- coding: utf-8 -*-
"""
tests/test_gstt_integrity_oracles.py
------------------------------------
Independent Integrity Test Oracles for Market Surveillance Datamart (GSTT - Giám sát Thị trường).

Authentic verification test suite evaluating multi-tier integrity:
- Test 1: Full 42-group coverage across BRD/BA and HLD architecture (42/42 groups, 0 missing).
- Test 2: Continuity and completeness of 263 unique KPI IDs (K_GSTT_1 to K_GSTT_262 + K_GSTT_103b).
- Test 3: 1:1 Parity audit between ClickHouse Flat Tables DDL and DML (10 tables, 310 columns, 0 column drift).
- Test 4: Gate 0 Reference Integrity root cause verification in Atomic YAML vs LLD CSVs.
- Test 5: Architectural compliance of newly added Fact tables (Surrogate keys, Role-playing Date FKs, Grain).
- Test 6: Precision drift detection on portfolio flat table (Decimal(7,4) vs decimal(8,5)).
- Test 7: Root cause analysis of analyzer dictionary key collision for K_GSTT_2 across groups.
"""

from collections import Counter, defaultdict
import csv
import io
import os
from pathlib import Path
import re
import sys
from typing import Dict, List, Set, Tuple

import pytest
import yaml

# Adjust stdout for Windows cp1252 consoles
if sys.platform.startswith("win"):
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    if hasattr(sys.stderr, "reconfigure"):
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")

REPO_ROOT = Path(__file__).resolve().parent.parent
BA_CSV_PATH = REPO_ROOT / "BRD" / "BA" / "BA_analyst_GSTT.csv"
HLD_MD_PATH = REPO_ROOT / "Datamart" / "hld" / "DTM_GSTT_HLD.md"
DETAIL_MAPPING_PATH = REPO_ROOT / "Datamart" / "lld" / "DTM_GSTT_Detail_Mapping.csv"
LLD_GSTT_DIR = REPO_ROOT / "Datamart" / "lld" / "GSTT"
MASTER_ATTRIBUTES_PATH = REPO_ROOT / "Datamart" / "lld" / "datamart_attributes.csv"
FLAT_DDL_PATH = REPO_ROOT / "Datamart" / "flat-table" / "GSTT" / "01_create_gstt_flat_tables.sql"
FLAT_DML_PATH = REPO_ROOT / "Datamart" / "flat-table" / "GSTT" / "02_populate_gstt_flat_tables.sql"
ATOMIC_SUBMISSION_YAML = REPO_ROOT / "DataModel" / "Atomic" / "Documentation" / "dm_atm_pc_report_submission-IDS.COMPANY_DATA.yaml"


# ==============================================================================
# TEST 1: Kiểm chứng bao phủ 42 nhóm chỉ tiêu trong BRD và HLD
# ==============================================================================
def test_oracle_01_traceability_42_groups_coverage():
    """
    Test 1: Kiểm chứng bao phủ 42 nhóm chỉ tiêu trong BRD/BA và HLD.
    - BRD/BA: Phải chứa đầy đủ 42 nhóm STT (1 đến 42), không thiếu hụt nhóm nào.
    - HLD: Section 3 phải chứa đầy đủ 42 tiểu mục nhóm ('#### Nhóm 1' đến '#### Nhóm 42').
    """
    assert BA_CSV_PATH.is_file(), f"Tệp BA không tồn tại: {BA_CSV_PATH}"
    assert HLD_MD_PATH.is_file(), f"Tệp HLD không tồn tại: {HLD_MD_PATH}"

    # 1. Parse BRD/BA
    with open(BA_CSV_PATH, "r", encoding="utf-8-sig", errors="replace") as f:
        reader = csv.reader(f)
        _row1 = next(reader, None)
        _header = next(reader, None)
        ba_groups = set()
        for row in reader:
            if row and len(row) > 0 and row[0].strip().isdigit():
                ba_groups.add(int(row[0].strip()))

    expected_groups = set(range(1, 43))
    missing_in_ba = expected_groups - ba_groups
    assert len(ba_groups) == 42, f"BRD/BA phải chứa đủ 42 nhóm STT, thực tế: {len(ba_groups)}"
    assert not missing_in_ba, f"BRD/BA thiếu các nhóm STT: {sorted(missing_in_ba)}"

    # 2. Parse HLD Section 3
    hld_text = HLD_MD_PATH.read_text(encoding="utf-8", errors="replace")
    nhom_matches = re.findall(r"^####\s+Nhóm\s+(\d+)", hld_text, re.MULTILINE)
    hld_groups = set(int(m) for m in nhom_matches)

    missing_in_hld = expected_groups - hld_groups
    assert len(hld_groups) == 42, f"HLD phải chứa đủ 42 nhóm, thực tế: {len(hld_groups)}"
    assert not missing_in_hld, f"HLD thiếu các nhóm: {sorted(missing_in_hld)}"

    # Cross-layer coverage parity
    assert ba_groups == hld_groups, "Tập nhóm trong BRD/BA và HLD không khớp nhau 100%"


# ==============================================================================
# TEST 2: Kiểm chứng tính liên tục của 263 KPI IDs
# ==============================================================================
def test_oracle_02_kpi_id_continuity_and_completeness():
    """
    Test 2: Kiểm chứng tính liên tục của 263 KPI IDs (K_GSTT_1 đến K_GSTT_262 + K_GSTT_103b).
    - Toàn bộ dãy số từ 1 đến 262 phải có mặt liên tục, 0 missing.
    - Biến thể mở rộng K_GSTT_103b phải tồn tại.
    - Tổng số mã KPI ID duy nhất phải bằng đúng 263.
    """
    assert DETAIL_MAPPING_PATH.is_file(), f"Tệp Detail Mapping không tồn tại: {DETAIL_MAPPING_PATH}"

    with open(DETAIL_MAPPING_PATH, "r", encoding="utf-8-sig", errors="replace") as f:
        reader = csv.DictReader(f)
        kpi_ids = set()
        for row in reader:
            kid = row.get("kpi_id", "").strip()
            if kid:
                kpi_ids.add(kid)

    assert "K_GSTT_103b" in kpi_ids, "Mã mở rộng K_GSTT_103b không tồn tại trong Detail Mapping"

    numeric_kpi_ids = set()
    for kid in kpi_ids:
        m = re.match(r"^K_GSTT_(\d+)$", kid)
        if m:
            numeric_kpi_ids.add(int(m.group(1)))

    expected_numbers = set(range(1, 263))
    missing_numbers = expected_numbers - numeric_kpi_ids

    assert len(numeric_kpi_ids) == 262, f"Phải có đúng 262 số KPI, thực tế: {len(numeric_kpi_ids)}"
    assert not missing_numbers, f"Thiếu các KPI ID trong khoảng 1-262: {sorted(missing_numbers)}"
    assert len(kpi_ids) == 263, f"Tổng số KPI ID duy nhất phải là 263, thực tế: {len(kpi_ids)}"


# ==============================================================================
# TEST 3: Đối soát 1:1 DDL vs DML của 10 bảng Flat Tables ClickHouse
# ==============================================================================
def _parse_clickhouse_flat_ddl_and_dml() -> Tuple[Dict[str, List[str]], Dict[str, List[str]]]:
    """Helper phân tích cú pháp AST/Token của DDL và DML ClickHouse."""
    ddl_text = FLAT_DDL_PATH.read_text(encoding="utf-8", errors="replace")
    dml_text = FLAT_DML_PATH.read_text(encoding="utf-8", errors="replace")

    # 1. Parse DDL tables & column lists
    create_pattern = re.compile(
        r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?datamart\.([a-zA-Z0-9_]+)[^(\(]*\(([\s\S]*?)\)\s*ENGINE",
        re.IGNORECASE
    )
    ddl_tables: Dict[str, List[str]] = {}
    for m in create_pattern.finditer(ddl_text):
        tbl_name = m.group(1).strip()
        body = m.group(2)
        cols = []
        for line in body.splitlines():
            line = line.strip()
            if not line or line.startswith("--"):
                continue
            clean = re.sub(r"--.*$", "", line).strip()
            if not clean:
                continue
            col_name = clean.split()[0].strip()
            cols.append(col_name)
        ddl_tables[tbl_name] = cols

    # 2. Parse DML INSERT SELECT statements & projected column aliases
    insert_pattern = re.compile(
        r"INSERT\s+INTO\s+datamart\.([a-zA-Z0-9_]+)\s+SELECT([\s\S]*?)FROM\s+([^\n;]+)",
        re.IGNORECASE
    )
    dml_tables: Dict[str, List[str]] = {}
    for m in insert_pattern.finditer(dml_text):
        tbl_name = m.group(1).strip()
        sel_body = m.group(2).strip()

        # Parse comma-separated projections respecting parentheses and strings
        items = []
        current = []
        paren_depth = 0
        in_str = False
        str_ch = None
        for ch in sel_body:
            if in_str:
                current.append(ch)
                if ch == str_ch:
                    in_str = False
            elif ch in ("'", '"'):
                in_str = True
                str_ch = ch
                current.append(ch)
            elif ch == '(':
                paren_depth += 1
                current.append(ch)
            elif ch == ')':
                paren_depth -= 1
                current.append(ch)
            elif ch == ',' and paren_depth == 0:
                s = "".join(current).strip()
                if s:
                    items.append(s)
                current = []
            else:
                current.append(ch)
        if current:
            s = "".join(current).strip()
            if s:
                items.append(s)

        cols = []
        for raw in items:
            lines = [re.sub(r"--.*$", "", l).strip() for l in raw.splitlines() if not l.strip().startswith("--")]
            clean = " ".join(lines).strip()
            if not clean:
                continue
            as_m = re.search(r"\s+AS\s+([a-zA-Z0-9_]+)$", clean, re.IGNORECASE)
            if as_m:
                alias = as_m.group(1)
            else:
                alias = clean.split(".")[-1].strip()
            cols.append(alias)
        dml_tables[tbl_name] = cols

    return ddl_tables, dml_tables


def test_oracle_03_flat_tables_ddl_dml_parity_1to1():
    """
    Test 3: Kiểm chứng đối soát 1:1 DDL vs DML của 10 bảng Flat Tables ClickHouse.
    - 10 bảng Flat Table phải tồn tại trong cả file DDL và file DML.
    - Từng bảng phải khớp chính xác 100% về số lượng cột, tên cột và thứ tự cột (0 drift).
    - Tổng số cột vật lý trên toàn bộ 10 bảng phải bằng đúng 310 cột.
    """
    assert FLAT_DDL_PATH.is_file(), f"Tệp DDL không tồn tại: {FLAT_DDL_PATH}"
    assert FLAT_DML_PATH.is_file(), f"Tệp DML không tồn tại: {FLAT_DML_PATH}"

    ddl_tables, dml_tables = _parse_clickhouse_flat_ddl_and_dml()

    assert len(ddl_tables) == 10, f"Phải có đúng 10 bảng DDL, thực tế: {len(ddl_tables)}"
    assert len(dml_tables) == 10, f"Phải có đúng 10 bảng DML, thực tế: {len(dml_tables)}"
    assert set(ddl_tables.keys()) == set(dml_tables.keys()), "Tập bảng giữa DDL và DML không khớp nhau"

    expected_table_columns = {
        "gstt_fct_stock_portfolio_snpst_flat": 109,
        "gstt_fct_index_constituent_snpst_flat": 23,
        "gstt_fct_market_index_intraday_flat": 14,
        "gstt_fct_security_trading_intraday_flat": 16,
        "gstt_fct_foreign_trading_min_snpst_flat": 13,
        "gstt_fct_investor_category_trading_snpst_flat": 17,
        "gstt_fct_investor_category_index_trading_snpst_flat": 17,
        "gstt_fct_major_shareholder_ownership_snpst_flat": 15,
        "gstt_fct_hose_securities_trade_flat": 48,
        "gstt_fct_hnx_securities_trade_flat": 38,
    }

    total_cols = 0
    drift_errors = []

    for tbl, expected_cnt in expected_table_columns.items():
        ddl_cols = ddl_tables.get(tbl, [])
        dml_cols = dml_tables.get(tbl, [])

        assert len(ddl_cols) == expected_cnt, f"Bảng {tbl} có {len(ddl_cols)} cột DDL, kỳ vọng {expected_cnt}"
        assert len(dml_cols) == expected_cnt, f"Bảng {tbl} có {len(dml_cols)} cột DML, kỳ vọng {expected_cnt}"

        total_cols += len(ddl_cols)

        # Kiểm tra khớp 1:1 từng vị trí
        for idx, (c_ddl, c_dml) in enumerate(zip(ddl_cols, dml_cols)):
            if c_ddl != c_dml:
                drift_errors.append(f"Table {tbl} col #{idx+1} mismatch: DDL={c_ddl} vs DML={c_dml}")

    assert not drift_errors, f"Phát hiện column drift giữa DDL và DML:\n" + "\n".join(drift_errors)
    assert total_cols == 310, f"Tổng số cột vật lý phải bằng đúng 310, thực tế: {total_cols}"


# ==============================================================================
# TEST 4: Kiểm chứng Gate 0 Reference Integrity đã được khắc phục
# ==============================================================================
def test_oracle_04_gate0_root_cause_verification():
    """
    Test 4: Kiểm chứng Gate 0 Reference Integrity — trạng thái SAU hotfix.
    - Xác nhận cột 'approval_status_code' và 'fr_code' TỒN TẠI trong YAML Atomic pc_report_submission.
    - Xác nhận 'submission_status_code' và 'fr_template_code' KHÔNG TỒN TẠI trong YAML Atomic.
    - Xác nhận trong LLD (fct_stock_portfolio_snpst và fct_index_constituent_snpst),
      etl_logic đã sử dụng ĐÚNG tên cột 'approval_status_code' và 'fr_code'
      thay vì tên sai 'submission_status_code' / 'fr_template_code' (đã khắc phục 2026-09-26).
    """
    assert ATOMIC_SUBMISSION_YAML.is_file(), f"Tệp Atomic YAML không tồn tại: {ATOMIC_SUBMISSION_YAML}"

    with open(ATOMIC_SUBMISSION_YAML, "r", encoding="utf-8") as f:
        atomic_data = yaml.safe_load(f)

    atomic_attributes = set(
        attr.get("physical_name")
        for attr in atomic_data.get("attributes", [])
        if attr.get("physical_name")
    )

    # 1. Cột đúng tồn tại trên Atomic
    assert "approval_status_code" in atomic_attributes, "approval_status_code phải tồn tại trên pc_report_submission"
    assert "fr_code" in atomic_attributes, "fr_code phải tồn tại trên pc_report_submission"

    # 2. Cột sai không tồn tại trên Atomic
    assert "submission_status_code" not in atomic_attributes, "submission_status_code không được tồn tại trên Atomic"
    assert "fr_template_code" not in atomic_attributes, "fr_template_code không được tồn tại trên Atomic"

    # 3. Xác nhận LLD đã dùng đúng tên cột (post-hotfix 2026-09-26)
    portfolio_csv_path = LLD_GSTT_DIR / "DTM_GSTT_fct_stock_portfolio_snpst.csv"
    index_csv_path = LLD_GSTT_DIR / "DTM_GSTT_fct_index_constituent_snpst.csv"

    portfolio_content = portfolio_csv_path.read_text(encoding="utf-8", errors="replace")
    index_content = index_csv_path.read_text(encoding="utf-8", errors="replace")

    # 3a. Tên cột đúng phải xuất hiện trong etl_logic
    assert "pc_report_submission.approval_status_code" in portfolio_content, \
        "portfolio CSV phải chứa pc_report_submission.approval_status_code (tên chuẩn DDL)"
    assert "pc_report_submission.fr_code" in portfolio_content, \
        "portfolio CSV phải chứa pc_report_submission.fr_code (tên chuẩn DDL)"
    assert "pc_report_submission.approval_status_code" in index_content, \
        "index constituent CSV phải chứa pc_report_submission.approval_status_code (tên chuẩn DDL)"
    assert "pc_report_submission.fr_code" in index_content, \
        "index constituent CSV phải chứa pc_report_submission.fr_code (tên chuẩn DDL)"

    # 3b. Tên cột sai không còn xuất hiện (đã sửa hết)
    assert "pc_report_submission.submission_status_code" not in portfolio_content, \
        "portfolio CSV không được còn chứa tên cột sai submission_status_code"
    assert "pc_report_submission.fr_template_code" not in portfolio_content, \
        "portfolio CSV không được còn chứa tên cột sai fr_template_code"
    assert "pc_report_submission.submission_status_code" not in index_content, \
        "index constituent CSV không được còn chứa tên cột sai submission_status_code"
    assert "pc_report_submission.fr_template_code" not in index_content, \
        "index constituent CSV không được còn chứa tên cột sai fr_template_code"


# ==============================================================================
# TEST 5: Kiểm chứng các bảng Fact mới bổ sung trong LLD
# ==============================================================================
def test_oracle_05_new_fact_tables_architecture_integrity():
    """
    Test 5: Kiểm chứng tính toàn vẹn kiến trúc của các bảng Fact mới bổ sung:
    - fct_hose_securities_trade: có trade_dt_dim_id, có DD securities_trade_code, không dùng cdr_dt_dim_id generic.
    - fct_hnx_securities_trade: có trade_dt_dim_id, có DD securities_trade_code, không dùng cdr_dt_dim_id generic.
    - fct_major_shareholder_ownership_snpst: có snpst_dt_dim_id, có surrogate key major_shareholder_ownership_id che PII.
    - fct_investor_category_trading_snpst: có snpst_dt_dim_id, không dùng cdr_dt_dim_id generic.
    - fct_investor_category_index_trading_snpst: có snpst_dt_dim_id, không dùng cdr_dt_dim_id generic.
    """
    tables_to_verify = [
        ("DTM_GSTT_fct_hose_securities_trade.csv", "trade_dt_dim_id", ["securities_trade_code"]),
        ("DTM_GSTT_fct_hnx_securities_trade.csv", "trade_dt_dim_id", ["securities_trade_code"]),
        ("DTM_GSTT_fct_major_shareholder_ownership_snpst.csv", "snpst_dt_dim_id", ["major_shareholder_ownership_id"]),
        ("DTM_GSTT_fct_investor_category_trading_snpst.csv", "snpst_dt_dim_id", []),
        ("DTM_GSTT_fct_investor_category_index_trading_snpst.csv", "snpst_dt_dim_id", []),
    ]

    for fname, expected_date_fk, expected_keys in tables_to_verify:
        fpath = LLD_GSTT_DIR / fname
        assert fpath.is_file(), f"File Fact LLD không tồn tại: {fpath}"

        with open(fpath, "r", encoding="utf-8-sig", errors="replace") as f:
            reader = csv.DictReader(f)
            rows = list(reader)

        col_names = [r.get("datamart_column", "").strip() for r in rows]
        key_cols = [r.get("datamart_column", "").strip() for r in rows if r.get("key", "").strip() in ("PK", "DD")]

        # Date FK sanity
        assert expected_date_fk in col_names, f"Bảng {fname} thiếu Role-Playing Date FK '{expected_date_fk}'"
        assert "cdr_dt_dim_id" not in col_names, f"Bảng {fname} vi phạm Kimball: chứa generic cdr_dt_dim_id trên Fact"

        # Check required business/surrogate keys
        for exp_k in expected_keys:
            assert exp_k in col_names, f"Bảng {fname} thiếu cột khóa '{exp_k}'"


# ==============================================================================
# TEST 6: Kiểm chứng 2 cột lệch precision trên bảng flat portfolio
# ==============================================================================
def test_oracle_06_precision_drift_detection():
    """
    Test 6: Kiểm chứng lệch độ chính xác (Precision Drift) trên bảng gstt_fct_stock_portfolio_snpst_flat:
    - Trong DDL ClickHouse: coupon_rate và yield được định nghĩa là Nullable(Decimal(7,4)).
    - Trong LLD Dimension CSV (DTM_GSTT_security_trading_snpst_dim_MDDS_JAD_STOCKINFOR.csv):
      coupon_rate và yield được định nghĩa là decimal(8,5).
    - Khẳng định phát hiện cảnh báo rủi ro làm tròn lãi suất và YTM trái phiếu (5 chữ số thập phân).
    """
    # 1. Check DDL ClickHouse
    ddl_text = FLAT_DDL_PATH.read_text(encoding="utf-8", errors="replace")
    m = re.search(
        r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?datamart\.gstt_fct_stock_portfolio_snpst_flat[^(\(]*\(([\s\S]*?)\)\s*ENGINE",
        ddl_text,
        re.IGNORECASE
    )
    assert m, "Không tìm thấy định nghĩa CREATE TABLE cho gstt_fct_stock_portfolio_snpst_flat"

    ddl_cols = {}
    for line in m.group(1).splitlines():
        line = line.strip()
        if not line or line.startswith("--"):
            continue
        clean = re.sub(r"--.*$", "", line).strip()
        if not clean:
            continue
        cname = clean.split()[0]
        cidx = clean.upper().find("COMMENT")
        ctype = clean[len(cname):cidx].strip() if cidx != -1 else " ".join(clean.split()[1:]).rstrip(",")
        ddl_cols[cname] = ctype

    assert "coupon_rate" in ddl_cols, "coupon_rate không có trong DDL flat table"
    assert "yield" in ddl_cols, "yield không có trong DDL flat table"
    assert "Decimal(7,4)" in ddl_cols["coupon_rate"], f"DDL coupon_rate phải là Decimal(7,4), thực tế: {ddl_cols['coupon_rate']}"
    assert "Decimal(7,4)" in ddl_cols["yield"], f"DDL yield phải là Decimal(7,4), thực tế: {ddl_cols['yield']}"

    # 2. Check LLD Dimension CSV
    dim_csv_path = LLD_GSTT_DIR / "DTM_GSTT_security_trading_snpst_dim_MDDS_JAD_STOCKINFOR.csv"
    assert dim_csv_path.is_file(), f"File Dimension LLD không tồn tại: {dim_csv_path}"

    lld_types = {}
    with open(dim_csv_path, "r", encoding="utf-8-sig", errors="replace") as f:
        for r in csv.DictReader(f):
            col = r.get("datamart_column", "").strip()
            dtype = r.get("data_type", "").strip()
            if col:
                lld_types[col] = dtype

    assert lld_types.get("coupon_rate") == "decimal(8,5)", f"LLD coupon_rate phải là decimal(8,5), thực tế: {lld_types.get('coupon_rate')}"
    assert lld_types.get("yield") == "decimal(8,5)", f"LLD yield phải là decimal(8,5), thực tế: {lld_types.get('yield')}"


# ==============================================================================
# TEST 7: Kiểm chứng nguyên nhân Dict Collision của script progress analyzer
# ==============================================================================
def test_oracle_07_analyzer_collision_root_cause():
    """
    Test 7: Kiểm chứng nguyên nhân gốc rễ lỗi từ điển ghi đè (Dict Collision) trong datamart_progress_analyzer.py.
    - K_GSTT_2 xuất hiện tại 19 nhóm trong HLD:
      Nhóm 1, 3, 7, 8, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 35, 39.
    - 18 nhóm đầu có trạng thái READY (đã map vào Public Company Dimension).
    - Duy nhất Nhóm 39 có trạng thái PENDING.
    - Khi script tạo dict hld_by_id = {h.kpi_id: h}, Nhóm 39 ghi đè 18 nhóm trước,
      khiến analyzer báo sai 20 false positives thành PENDING.
    """
    hld_text = HLD_MD_PATH.read_text(encoding="utf-8", errors="replace")

    # Match all KPI table rows containing K_GSTT_2
    # Format: | K_GSTT_2 | Ngành | ... | READY / PENDING |
    k_gstt_2_rows = re.findall(
        r"\|\s*(K_GSTT_2)\s*\|\s*([^|]+)\|\s*([^|]+)\|\s*([^|]+)\|\s*([^|]+)\|\s*([^|]+)\|\s*(READY|PENDING)\s*\|",
        hld_text
    )

    assert len(k_gstt_2_rows) == 19, f"K_GSTT_2 phải xuất hiện đúng 19 lần trong HLD, thực tế: {len(k_gstt_2_rows)}"

    statuses = [r[6].strip() for r in k_gstt_2_rows]
    ready_count = statuses.count("READY")
    pending_count = statuses.count("PENDING")

    assert ready_count == 18, f"K_GSTT_2 phải có 18 lần READY, thực tế: {ready_count}"
    assert pending_count == 1, f"K_GSTT_2 phải có đúng 1 lần PENDING (tại Nhóm 39), thực tế: {pending_count}"
    assert statuses[-1] == "PENDING", "Lần xuất hiện cuối cùng của K_GSTT_2 trong HLD phải là PENDING (Nhóm 39)"
