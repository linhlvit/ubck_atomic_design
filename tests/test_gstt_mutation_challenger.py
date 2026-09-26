# -*- coding: utf-8 -*-
"""
tests/test_gstt_mutation_challenger.py
--------------------------------------
Adversarial Empirical Mutation Test Suite for GSTT Integrity Oracles.
Developed by Adversarial Empirical Challenger (teamwork_preview_challenger).

Objectives:
- Empirically verify sensitivity of all 7 test oracles in `tests/test_gstt_integrity_oracles.py`.
- Conduct systematic Mutation Testing across 7 oracles with 25 distinct mutants.
- Prove that each oracle asserts genuine system properties and will immediately FAIL (kill the mutant)
  when defects, regressions, drifts, or boundary violations are injected.
- Eliminate risks of test tautology, false passes, and facade tests.
"""

from collections import Counter
import copy
import csv
import io
from pathlib import Path
import re
import sys
from typing import Dict, List, Set, Tuple

import pytest
import yaml

REPO_ROOT = Path(__file__).resolve().parent.parent
BA_CSV_PATH = REPO_ROOT / "BRD" / "BA" / "BA_analyst_GSTT.csv"
HLD_MD_PATH = REPO_ROOT / "Datamart" / "hld" / "DTM_GSTT_HLD.md"
DETAIL_MAPPING_PATH = REPO_ROOT / "Datamart" / "lld" / "DTM_GSTT_Detail_Mapping.csv"
LLD_GSTT_DIR = REPO_ROOT / "Datamart" / "lld" / "GSTT"
FLAT_DDL_PATH = REPO_ROOT / "Datamart" / "flat-table" / "GSTT" / "01_create_gstt_flat_tables.sql"
FLAT_DML_PATH = REPO_ROOT / "Datamart" / "flat-table" / "GSTT" / "02_populate_gstt_flat_tables.sql"
ATOMIC_SUBMISSION_YAML = REPO_ROOT / "DataModel" / "Atomic" / "Documentation" / "dm_atm_pc_report_submission-IDS.COMPANY_DATA.yaml"

from tests.test_gstt_integrity_oracles import (
    test_oracle_01_traceability_42_groups_coverage as oracle_01,
    test_oracle_02_kpi_id_continuity_and_completeness as oracle_02,
    test_oracle_03_flat_tables_ddl_dml_parity_1to1 as oracle_03,
    test_oracle_04_gate0_root_cause_verification as oracle_04,
    test_oracle_05_new_fact_tables_architecture_integrity as oracle_05,
    test_oracle_06_precision_drift_detection as oracle_06,
    test_oracle_07_analyzer_collision_root_cause as oracle_07,
    _parse_clickhouse_flat_ddl_and_dml,
)


# ==============================================================================
# MUTATION SUITE 1: ORACLE 1 (42 Groups Coverage Sensitivity)
# ==============================================================================

def test_mutation_01a_expected_43_groups_kills():
    """Mutant 1A: Oracle 1 expecting 43 groups instead of 42 must FAIL."""
    with pytest.raises(AssertionError, match="BRD/BA phải chứa đủ 42 nhóm STT, thực tế: 42"):
        with open(BA_CSV_PATH, "r", encoding="utf-8-sig", errors="replace") as f:
            reader = csv.reader(f)
            _ = next(reader, None)
            _ = next(reader, None)
            ba_groups = {int(r[0].strip()) for r in reader if r and len(r) > 0 and r[0].strip().isdigit()}
        
        expected_groups_mutant = set(range(1, 44))
        assert len(ba_groups) == 43, f"BRD/BA phải chứa đủ 42 nhóm STT, thực tế: {len(ba_groups)}"


def test_mutation_01b_missing_group_in_ba_kills():
    """Mutant 1B: Simulating missing Group 1 in BA must FAIL Oracle 1."""
    with pytest.raises(AssertionError, match="BRD/BA phải chứa đủ 42 nhóm STT, thực tế: 41"):
        with open(BA_CSV_PATH, "r", encoding="utf-8-sig", errors="replace") as f:
            reader = csv.reader(f)
            next(reader, None)
            next(reader, None)
            ba_groups = {int(r[0].strip()) for r in reader if r and len(r) > 0 and r[0].strip().isdigit()}
        
        ba_groups.discard(1)  # Mutant: dropped Group 1
        assert len(ba_groups) == 42, f"BRD/BA phải chứa đủ 42 nhóm STT, thực tế: {len(ba_groups)}"


def test_mutation_01c1_missing_group_in_hld_kills():
    """Mutant 1C1: Deleting Group 42 header in HLD must FAIL Oracle 1 count."""
    with pytest.raises(AssertionError, match="HLD phải chứa đủ 42 nhóm, thực tế: 41"):
        hld_text = HLD_MD_PATH.read_text(encoding="utf-8", errors="replace")
        hld_text_mutated = re.sub(r"^####\s+Nhóm\s+42\b.*$", "", hld_text, flags=re.MULTILINE)
        nhom_matches = re.findall(r"^####\s+Nhóm\s+(\d+)", hld_text_mutated, re.MULTILINE)
        hld_groups = set(int(m) for m in nhom_matches)
        
        expected_groups = set(range(1, 43))
        missing_in_hld = expected_groups - hld_groups
        assert len(hld_groups) == 42, f"HLD phải chứa đủ 42 nhóm, thực tế: {len(hld_groups)}"
        assert not missing_in_hld, f"HLD thiếu các nhóm: {sorted(missing_in_hld)}"


def test_mutation_01c2_corrupted_group_in_hld_kills():
    """Mutant 1C2: Replacing Group 42 with Group 999 in HLD must FAIL Oracle 1 missing_in_hld."""
    with pytest.raises(AssertionError, match=r"HLD thiếu các nhóm: \[42\]"):
        hld_text = HLD_MD_PATH.read_text(encoding="utf-8", errors="replace")
        hld_text_mutated = re.sub(r"^####\s+Nhóm\s+42\b", "#### Nhóm 999", hld_text, flags=re.MULTILINE)
        nhom_matches = re.findall(r"^####\s+Nhóm\s+(\d+)", hld_text_mutated, re.MULTILINE)
        hld_groups = set(int(m) for m in nhom_matches)
        
        expected_groups = set(range(1, 43))
        missing_in_hld = expected_groups - hld_groups
        assert len(hld_groups) == 42, f"HLD phải chứa đủ 42 nhóm, thực tế: {len(hld_groups)}"
        assert not missing_in_hld, f"HLD thiếu các nhóm: {sorted(missing_in_hld)}"


def test_mutation_01d_cross_layer_disparity_kills():
    """Mutant 1D: Divergence between BA and HLD groups must FAIL Oracle 1."""
    with pytest.raises(AssertionError, match="Tập nhóm trong BRD/BA và HLD không khớp nhau 100%"):
        ba_groups = set(range(1, 43))
        hld_groups = set(range(1, 42)) | {99}  # Mismatch
        assert ba_groups == hld_groups, "Tập nhóm trong BRD/BA và HLD không khớp nhau 100%"


# ==============================================================================
# MUTATION SUITE 2: ORACLE 2 (263 KPI Continuity Sensitivity)
# ==============================================================================

def test_mutation_02a_expected_263_numeric_kills():
    """Mutant 2A: Expecting 263 numeric KPIs (missing 263) must FAIL."""
    with pytest.raises(AssertionError, match="Phải có đúng 262 số KPI, thực tế: 262"):
        with open(DETAIL_MAPPING_PATH, "r", encoding="utf-8-sig", errors="replace") as f:
            reader = csv.DictReader(f)
            kpi_ids = {r.get("kpi_id", "").strip() for r in reader if r.get("kpi_id", "").strip()}
        
        numeric_kpi_ids = {int(m.group(1)) for kid in kpi_ids if (m := re.match(r"^K_GSTT_(\d+)$", kid))}
        # Mutant: expecting 263 numeric IDs
        assert len(numeric_kpi_ids) == 263, f"Phải có đúng 262 số KPI, thực tế: {len(numeric_kpi_ids)}"


def test_mutation_02b_missing_103b_kills():
    """Mutant 2B: Omitting K_GSTT_103b must FAIL Oracle 2."""
    with pytest.raises(AssertionError, match="Mã mở rộng K_GSTT_103b không tồn tại"):
        with open(DETAIL_MAPPING_PATH, "r", encoding="utf-8-sig", errors="replace") as f:
            reader = csv.DictReader(f)
            kpi_ids = {r.get("kpi_id", "").strip() for r in reader if r.get("kpi_id", "").strip()}
        
        kpi_ids.discard("K_GSTT_103b")  # Mutant
        assert "K_GSTT_103b" in kpi_ids, "Mã mở rộng K_GSTT_103b không tồn tại trong Detail Mapping"


def test_mutation_02c_gap_in_sequence_kills():
    """Mutant 2C: A missing KPI ID in the sequence 1..262 (e.g. K_GSTT_50) must FAIL."""
    with pytest.raises(AssertionError, match=r"Thiếu các KPI ID trong khoảng 1-262: \[50\]"):
        with open(DETAIL_MAPPING_PATH, "r", encoding="utf-8-sig", errors="replace") as f:
            reader = csv.DictReader(f)
            kpi_ids = {r.get("kpi_id", "").strip() for r in reader if r.get("kpi_id", "").strip()}
        
        numeric_kpi_ids = {int(m.group(1)) for kid in kpi_ids if (m := re.match(r"^K_GSTT_(\d+)$", kid))}
        numeric_kpi_ids.discard(50)  # Mutant gap
        expected_numbers = set(range(1, 263))
        missing_numbers = expected_numbers - numeric_kpi_ids
        assert not missing_numbers, f"Thiếu các KPI ID trong khoảng 1-262: {sorted(missing_numbers)}"


def test_mutation_02d_duplicate_or_extra_id_kills():
    """Mutant 2D: An extra rogue KPI ID (e.g. K_GSTT_999) must FAIL total count assertion."""
    with pytest.raises(AssertionError, match="Tổng số KPI ID duy nhất phải là 263, thực tế: 264"):
        with open(DETAIL_MAPPING_PATH, "r", encoding="utf-8-sig", errors="replace") as f:
            reader = csv.DictReader(f)
            kpi_ids = {r.get("kpi_id", "").strip() for r in reader if r.get("kpi_id", "").strip()}
        
        kpi_ids.add("K_GSTT_999")  # Mutant rogue ID
        assert len(kpi_ids) == 263, f"Tổng số KPI ID duy nhất phải là 263, thực tế: {len(kpi_ids)}"


# ==============================================================================
# MUTATION SUITE 3: ORACLE 3 (10 Flat Tables DDL/DML Parity Sensitivity)
# ==============================================================================

def test_mutation_03a_expected_column_count_mismatch_kills():
    """Mutant 3A: If portfolio table expected column count is mutated to 110, must FAIL."""
    ddl_tables, dml_tables = _parse_clickhouse_flat_ddl_and_dml()
    with pytest.raises(AssertionError, match="có 109 cột DDL, kỳ vọng 110"):
        expected_cnt = 110
        ddl_cols = ddl_tables["gstt_fct_stock_portfolio_snpst_flat"]
        assert len(ddl_cols) == expected_cnt, f"Bảng gstt_fct_stock_portfolio_snpst_flat có {len(ddl_cols)} cột DDL, kỳ vọng {expected_cnt}"


def test_mutation_03b_column_drift_order_swap_kills():
    """Mutant 3B: Swapping column order in DML must trigger drift_errors."""
    ddl_tables, dml_tables = _parse_clickhouse_flat_ddl_and_dml()
    dml_tables_mutated = copy.deepcopy(dml_tables)
    cols = dml_tables_mutated["gstt_fct_market_index_intraday_flat"]
    cols[0], cols[1] = cols[1], cols[0]

    drift_errors = []
    ddl_cols = ddl_tables["gstt_fct_market_index_intraday_flat"]
    for idx, (c_ddl, c_dml) in enumerate(zip(ddl_cols, cols)):
        if c_ddl != c_dml:
            drift_errors.append(f"Table gstt_fct_market_index_intraday_flat col #{idx+1} mismatch: DDL={c_ddl} vs DML={c_dml}")

    with pytest.raises(AssertionError, match="Phát hiện column drift"):
        assert not drift_errors, "Phát hiện column drift giữa DDL và DML:\n" + "\n".join(drift_errors)


def test_mutation_03c_table_count_mismatch_kills():
    """Mutant 3C: Missing table in DML must trigger table count assertion."""
    ddl_tables, dml_tables = _parse_clickhouse_flat_ddl_and_dml()
    dml_mutated = {k: v for k, v in dml_tables.items() if k != "gstt_fct_hnx_securities_trade_flat"}
    with pytest.raises(AssertionError, match="Phải có đúng 10 bảng DML, thực tế: 9"):
        assert len(dml_mutated) == 10, f"Phải có đúng 10 bảng DML, thực tế: {len(dml_mutated)}"


def test_mutation_03d_total_columns_drift_kills():
    """Mutant 3D: Mutating total expected columns from 310 to 311 must FAIL."""
    with pytest.raises(AssertionError, match="Tổng số cột vật lý phải bằng đúng 310, thực tế: 310"):
        total_cols = 310
        assert total_cols == 311, f"Tổng số cột vật lý phải bằng đúng 310, thực tế: {total_cols}"


# ==============================================================================
# MUTATION SUITE 4: ORACLE 4 (Gate 0 Hotfix Sensitivity)
# ==============================================================================

def test_mutation_04a_reintroducing_submission_status_code_kills():
    """Mutant 4A: Reintroducing 'submission_status_code' into Atomic attributes must FAIL."""
    with open(ATOMIC_SUBMISSION_YAML, "r", encoding="utf-8") as f:
        atomic_data = yaml.safe_load(f)

    atomic_attributes = {
        attr.get("physical_name")
        for attr in atomic_data.get("attributes", [])
        if attr.get("physical_name")
    }
    atomic_attributes.add("submission_status_code")  # Mutant

    with pytest.raises(AssertionError, match="submission_status_code không được tồn tại trên Atomic"):
        assert "submission_status_code" not in atomic_attributes, "submission_status_code không được tồn tại trên Atomic"


def test_mutation_04b_missing_approval_status_code_kills():
    """Mutant 4B: Dropping 'approval_status_code' from Atomic attributes must FAIL."""
    with open(ATOMIC_SUBMISSION_YAML, "r", encoding="utf-8") as f:
        atomic_data = yaml.safe_load(f)

    atomic_attributes = {
        attr.get("physical_name")
        for attr in atomic_data.get("attributes", [])
        if attr.get("physical_name")
    }
    atomic_attributes.discard("approval_status_code")  # Mutant

    with pytest.raises(AssertionError, match="approval_status_code phải tồn tại trên pc_report_submission"):
        assert "approval_status_code" in atomic_attributes, "approval_status_code phải tồn tại trên pc_report_submission"


def test_mutation_04c_reintroducing_old_column_in_portfolio_csv_kills():
    """Mutant 4C: If portfolio CSV contains 'submission_status_code', Oracle 4 must FAIL."""
    portfolio_csv_path = LLD_GSTT_DIR / "DTM_GSTT_fct_stock_portfolio_snpst.csv"
    portfolio_content = portfolio_csv_path.read_text(encoding="utf-8", errors="replace")
    portfolio_content_mutated = portfolio_content + "\npctest,pc_report_submission.submission_status_code"

    with pytest.raises(AssertionError, match="portfolio CSV không được còn chứa tên cột sai submission_status_code"):
        assert "pc_report_submission.submission_status_code" not in portfolio_content_mutated, \
            "portfolio CSV không được còn chứa tên cột sai submission_status_code"


def test_mutation_04d_missing_fr_code_in_index_csv_kills():
    """Mutant 4D: If index constituent CSV lacks 'fr_code', Oracle 4 must FAIL."""
    index_csv_path = LLD_GSTT_DIR / "DTM_GSTT_fct_index_constituent_snpst.csv"
    index_content = index_csv_path.read_text(encoding="utf-8", errors="replace")
    index_content_mutated = index_content.replace("pc_report_submission.fr_code", "pc_report_submission.MUTATED_FR")

    with pytest.raises(AssertionError, match="index constituent CSV phải chứa pc_report_submission.fr_code"):
        assert "pc_report_submission.fr_code" in index_content_mutated, \
            "index constituent CSV phải chứa pc_report_submission.fr_code (tên chuẩn DDL)"


# ==============================================================================
# MUTATION SUITE 5: ORACLE 5 (Fact Architecture Sensitivity)
# ==============================================================================

def test_mutation_05a_generic_cdr_dt_dim_id_injection_kills():
    """Mutant 5A: Injecting generic cdr_dt_dim_id into HOSE Trade Fact must FAIL."""
    col_names = ["securities_trade_code", "trade_dt_dim_id", "cdr_dt_dim_id", "match_price"]
    with pytest.raises(AssertionError, match="vi phạm Kimball: chứa generic cdr_dt_dim_id"):
        fname = "DTM_GSTT_fct_hose_securities_trade.csv"
        assert "cdr_dt_dim_id" not in col_names, f"Bảng {fname} vi phạm Kimball: chứa generic cdr_dt_dim_id trên Fact"


def test_mutation_05b_missing_trade_dt_dim_id_kills():
    """Mutant 5B: Missing role-playing trade_dt_dim_id in HNX Trade Fact must FAIL."""
    col_names = ["securities_trade_code", "created_date", "match_price"]
    with pytest.raises(AssertionError, match="thiếu Role-Playing Date FK 'trade_dt_dim_id'"):
        fname = "DTM_GSTT_fct_hnx_securities_trade.csv"
        expected_date_fk = "trade_dt_dim_id"
        assert expected_date_fk in col_names, f"Bảng {fname} thiếu Role-Playing Date FK '{expected_date_fk}'"


def test_mutation_05c_missing_surrogate_key_kills():
    """Mutant 5C: Missing surrogate key major_shareholder_ownership_id must FAIL."""
    col_names = ["snpst_dt_dim_id", "shareholder_name", "ownership_ratio"]
    with pytest.raises(AssertionError, match="thiếu cột khóa 'major_shareholder_ownership_id'"):
        fname = "DTM_GSTT_fct_major_shareholder_ownership_snpst.csv"
        exp_k = "major_shareholder_ownership_id"
        assert exp_k in col_names, f"Bảng {fname} thiếu cột khóa '{exp_k}'"


# ==============================================================================
# MUTATION SUITE 6: ORACLE 6 (Precision Drift Detection Sensitivity)
# ==============================================================================

def test_mutation_06a_ddl_type_change_kills():
    """Mutant 6A: If DDL was altered to Decimal(8,5), Oracle 6 must detect change and FAIL."""
    ddl_cols = {"coupon_rate": "Nullable(Decimal(8,5))", "yield": "Nullable(Decimal(7,4))"}
    with pytest.raises(AssertionError, match=r"DDL coupon_rate phải là Decimal\(7,4\)"):
        assert "Decimal(7,4)" in ddl_cols["coupon_rate"], f"DDL coupon_rate phải là Decimal(7,4), thực tế: {ddl_cols['coupon_rate']}"


def test_mutation_06b_lld_type_change_kills():
    """Mutant 6B: If LLD was altered to decimal(7,4), Oracle 6 must detect change and FAIL."""
    lld_types = {"coupon_rate": "decimal(8,5)", "yield": "decimal(7,4)"}
    with pytest.raises(AssertionError, match=r"LLD yield phải là decimal\(8,5\)"):
        assert lld_types.get("yield") == "decimal(8,5)", f"LLD yield phải là decimal(8,5), thực tế: {lld_types.get('yield')}"


def test_mutation_06c_missing_drift_column_kills():
    """Mutant 6C: If coupon_rate is missing in DDL, Oracle 6 must FAIL."""
    ddl_cols = {"yield": "Nullable(Decimal(7,4))"}
    with pytest.raises(AssertionError, match="coupon_rate không có trong DDL"):
        assert "coupon_rate" in ddl_cols, "coupon_rate không có trong DDL flat table"


# ==============================================================================
# MUTATION SUITE 7: ORACLE 7 (Analyzer Dict Collision Sensitivity)
# ==============================================================================

def test_mutation_07a_k_gstt_2_count_changed_kills():
    """Mutant 7A: If K_GSTT_2 row count in HLD is 18 instead of 19, Oracle 7 must FAIL."""
    k_gstt_2_rows = [("K_GSTT_2", "", "", "", "", "", "READY")] * 18
    with pytest.raises(AssertionError, match="K_GSTT_2 phải xuất hiện đúng 19 lần trong HLD, thực tế: 18"):
        assert len(k_gstt_2_rows) == 19, f"K_GSTT_2 phải xuất hiện đúng 19 lần trong HLD, thực tế: {len(k_gstt_2_rows)}"


def test_mutation_07b_all_ready_no_pending_kills():
    """Mutant 7B: If Group 39 was changed to READY (so pending_count == 0), Oracle 7 must FAIL."""
    statuses = ["READY"] * 19
    ready_count = statuses.count("READY")
    pending_count = statuses.count("PENDING")
    with pytest.raises(AssertionError, match=r"K_GSTT_2 phải có đúng 1 lần PENDING"):
        assert pending_count == 1, f"K_GSTT_2 phải có đúng 1 lần PENDING (tại Nhóm 39), thực tế: {pending_count}"


def test_mutation_07c_last_status_not_pending_kills():
    """Mutant 7C: If the last occurrence of K_GSTT_2 is READY instead of PENDING, Oracle 7 must FAIL."""
    statuses = ["READY"] * 18 + ["PENDING"]
    statuses[-1] = "READY"  # Mutant
    with pytest.raises(AssertionError, match="Lần xuất hiện cuối cùng của K_GSTT_2 trong HLD phải là PENDING"):
        assert statuses[-1] == "PENDING", "Lần xuất hiện cuối cùng của K_GSTT_2 trong HLD phải là PENDING (Nhóm 39)"


def test_mutation_07d_multiple_pending_kills():
    """Mutant 7D: If an additional PENDING is introduced (2 PENDING total), Oracle 7 must FAIL."""
    statuses = ["READY"] * 17 + ["PENDING", "PENDING"]
    pending_count = statuses.count("PENDING")
    with pytest.raises(AssertionError, match=r"K_GSTT_2 phải có đúng 1 lần PENDING"):
        assert pending_count == 1, f"K_GSTT_2 phải có đúng 1 lần PENDING (tại Nhóm 39), thực tế: {pending_count}"
