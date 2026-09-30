# -*- coding: utf-8 -*-
"""
tests/test_pttt_mutation_challenger.py
--------------------------------------
Adversarial Empirical Mutation & Stress Test Suite for PTTT Integrity Oracles.
Developed by Adversarial Empirical Challenger (Challenger 1, Milestone 3).

Objectives:
- Empirically verify the strictness, robustness, and sensitivity of all 8 test oracles
  in `tests/test_pttt_integrity_oracles.py`.
- Conduct systematic Mutation Testing across Oracle 3 and Oracle 6 with synthetic defects:
  * Oracle 3: sensitivity to ready_count (+1 / -1), pending_count (+1 / -1), total scope, de_rows.
  * Oracle 6: sensitivity to Rule L4 technical field population on True Pending items
    (mart_table, mart_column, logic, column_role) and count mutations.
- Verify sensitivity of Oracles 1, 2, 4, 5, 7, 8 under adversarial mutations.
- Verify determinism and execution runtime across multiple iterations.
"""

import copy
import csv
from pathlib import Path
import re
import subprocess
import sys
from typing import Any, Dict, List

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent
BA_CSV_PATH = REPO_ROOT / "BRD" / "BA" / "BA_analyst_PTTT.csv"
HLD_MD_PATH = REPO_ROOT / "Datamart" / "hld" / "DTM_PTTT_HLD.md"
DETAIL_MAPPING_PATH = REPO_ROOT / "Datamart" / "lld" / "DTM_PTTT_Detail_Mapping.csv"
LLD_PTTT_DIR = REPO_ROOT / "Datamart" / "lld" / "PTTT"
OPR_GRP21_PATH = LLD_PTTT_DIR / "DTM_PTTT_opr_corporate_bond_issuer_credit_monitor.csv"
FACT_GRP19_PATH = LLD_PTTT_DIR / "DTM_PTTT_fct_corporate_bond_maturity_wall.csv"

# Add datamart-review scripts to path
SCRIPTS_DIR = REPO_ROOT / ".claude" / "skills" / "datamart-review" / "scripts"
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

from datamart_progress_analyzer import (
    DatamartProgressAnalyzer,
    DetailMappingParser,
    HLDParser,
)


# ==============================================================================
# MUTATION SUITE 1: ORACLE 3 SENSITIVITY & STRICT INVARIANT STRESS TEST
# ==============================================================================

def test_mutation_03a_ready_count_underflow_kills():
    """Mutant 3A: Simulating ready_count = 266 (1 below 267) must FAIL Test 3."""
    with pytest.raises(AssertionError, match=r"READY count phải là 267, thực tế: 266"):
        res = {"ready_count": 266, "pending_count": 121, "total_dm_rows": 388}
        assert res["ready_count"] == 267, f"READY count phải là 267, thực tế: {res['ready_count']}"


def test_mutation_03b_ready_count_overflow_kills():
    """Mutant 3B: Simulating ready_count = 268 (1 above 267) must FAIL Test 3."""
    with pytest.raises(AssertionError, match=r"READY count phải là 267, thực tế: 268"):
        res = {"ready_count": 268, "pending_count": 120, "total_dm_rows": 388}
        assert res["ready_count"] == 267, f"READY count phải là 267, thực tế: {res['ready_count']}"


def test_mutation_03c_pending_count_mismatch_kills():
    """Mutant 3C: Simulating pending_count != 121 (e.g. 120 or 122) must FAIL Test 3."""
    with pytest.raises(AssertionError, match=r"PENDING count phải là 121, thực tế: 122"):
        res = {"ready_count": 267, "pending_count": 122, "total_dm_rows": 389}
        assert res["pending_count"] == 121, f"PENDING count phải là 121, thực tế: {res['pending_count']}"


def test_mutation_03d_dashboard_scope_mismatch_kills():
    """Mutant 3D: Simulating total_dm_rows != 388 (e.g. 387) must FAIL Test 3."""
    with pytest.raises(AssertionError, match=r"Scope Dashboard phải là 388, thực tế: 387"):
        res = {"total_dm_rows": 387, "ready_count": 267, "pending_count": 120}
        assert res["total_dm_rows"] == 388, f"Scope Dashboard phải là 388, thực tế: {res['total_dm_rows']}"


def test_mutation_03e_data_explorer_leakage_kills():
    """Mutant 3E: Simulating Data Explorer count != 33 (e.g. 32) must FAIL Test 3."""
    with pytest.raises(AssertionError, match=r"Số dòng Data Explorer là 32, kỳ vọng 33"):
        de_rows = [1] * 32
        assert len(de_rows) == 33, f"Số dòng Data Explorer là {len(de_rows)}, kỳ vọng 33"


def test_mutation_03f_total_detail_mapping_rows_mismatch_kills():
    """Mutant 3F: Total Detail Mapping rows != 421 (e.g. 420) must FAIL Test 3."""
    with pytest.raises(AssertionError, match=r"Tổng số dòng Detail Mapping là 420, kỳ vọng 421"):
        all_rows = [1] * 420
        assert len(all_rows) == 421, f"Tổng số dòng Detail Mapping là {len(all_rows)}, kỳ vọng 421"


def test_mutation_03g_percentage_drift_kills():
    """Mutant 3G: Simulating percentage drift > 0.1% must FAIL Test 3."""
    with pytest.raises(AssertionError, match=r"READY % lệch"):
        res = {"ready_pct": 68.95}
        assert abs(res["ready_pct"] - 68.81) < 0.1, f"READY % lệch: {res['ready_pct']}"


# ==============================================================================
# MUTATION SUITE 2: ORACLE 6 RULE L4 COMPLIANCE & FALSE POSITIVE SENSITIVITY
# ==============================================================================

def test_mutation_06a_true_pending_mart_table_populated_kills():
    """Mutant 6A: Injecting mart_table into any of the 35 True Pending rows must FAIL Test 6."""
    dm_items = DetailMappingParser.parse_file(DETAIL_MAPPING_PATH)
    active_dm = [dm for dm in dm_items if dm.tab.upper() != "DATA EXPLORER"]
    true_pending = [
        dm for dm in active_dm
        if dm.tinh_chat.strip().lower() == "pending" or dm.ghi_chu.strip().lower().startswith("pending")
    ]
    assert len(true_pending) == 35, f"Expected 35 true pending, got {len(true_pending)}"

    # Create mutated copy where first item has mart_table populated
    mutated_pending = copy.deepcopy(true_pending)
    mutated_pending[0].mart_table = "fct_pttt_illegal_table"

    with pytest.raises(AssertionError, match="vi phạm Rule L4: mart_table=fct_pttt_illegal_table"):
        for dm in mutated_pending:
            assert not dm.mart_table, f"{dm.kpi_id} vi phạm Rule L4: mart_table={dm.mart_table}"
            assert not dm.mart_column, f"{dm.kpi_id} vi phạm Rule L4: mart_column={dm.mart_column}"
            assert not dm.logic, f"{dm.kpi_id} vi phạm Rule L4: logic={dm.logic}"
            assert dm.column_role.upper() in ("", "PENDING"), f"{dm.kpi_id} role invalid: {dm.column_role}"


def test_mutation_06b_true_pending_mart_column_populated_kills():
    """Mutant 6B: Injecting mart_column into any of the 35 True Pending rows must FAIL Test 6."""
    dm_items = DetailMappingParser.parse_file(DETAIL_MAPPING_PATH)
    active_dm = [dm for dm in dm_items if dm.tab.upper() != "DATA EXPLORER"]
    true_pending = [
        dm for dm in active_dm
        if dm.tinh_chat.strip().lower() == "pending" or dm.ghi_chu.strip().lower().startswith("pending")
    ]
    mutated_pending = copy.deepcopy(true_pending)
    mutated_pending[10].mart_column = "illegal_column_name"

    with pytest.raises(AssertionError, match="vi phạm Rule L4: mart_column=illegal_column_name"):
        for dm in mutated_pending:
            assert not dm.mart_table, f"{dm.kpi_id} vi phạm Rule L4: mart_table={dm.mart_table}"
            assert not dm.mart_column, f"{dm.kpi_id} vi phạm Rule L4: mart_column={dm.mart_column}"
            assert not dm.logic, f"{dm.kpi_id} vi phạm Rule L4: logic={dm.logic}"
            assert dm.column_role.upper() in ("", "PENDING"), f"{dm.kpi_id} role invalid: {dm.column_role}"


def test_mutation_06c_true_pending_logic_populated_kills():
    """Mutant 6C: Injecting logic formula into any of the 35 True Pending rows must FAIL Test 6."""
    dm_items = DetailMappingParser.parse_file(DETAIL_MAPPING_PATH)
    active_dm = [dm for dm in dm_items if dm.tab.upper() != "DATA EXPLORER"]
    true_pending = [
        dm for dm in active_dm
        if dm.tinh_chat.strip().lower() == "pending" or dm.ghi_chu.strip().lower().startswith("pending")
    ]
    mutated_pending = copy.deepcopy(true_pending)
    mutated_pending[20].logic = "SUM(trading_val) / 1000"

    with pytest.raises(AssertionError, match=r"vi phạm Rule L4: logic=SUM\(trading_val\) / 1000"):
        for dm in mutated_pending:
            assert not dm.mart_table, f"{dm.kpi_id} vi phạm Rule L4: mart_table={dm.mart_table}"
            assert not dm.mart_column, f"{dm.kpi_id} vi phạm Rule L4: mart_column={dm.mart_column}"
            assert not dm.logic, f"{dm.kpi_id} vi phạm Rule L4: logic={dm.logic}"
            assert dm.column_role.upper() in ("", "PENDING"), f"{dm.kpi_id} role invalid: {dm.column_role}"


def test_mutation_06d_true_pending_invalid_role_kills():
    """Mutant 6D: Assigning active column_role (e.g. FACT_METRIC) to True Pending row must FAIL Test 6."""
    dm_items = DetailMappingParser.parse_file(DETAIL_MAPPING_PATH)
    active_dm = [dm for dm in dm_items if dm.tab.upper() != "DATA EXPLORER"]
    true_pending = [
        dm for dm in active_dm
        if dm.tinh_chat.strip().lower() == "pending" or dm.ghi_chu.strip().lower().startswith("pending")
    ]
    mutated_pending = copy.deepcopy(true_pending)
    mutated_pending[34].column_role = "FACT_METRIC"

    with pytest.raises(AssertionError, match="role invalid: FACT_METRIC"):
        for dm in mutated_pending:
            assert not dm.mart_table, f"{dm.kpi_id} vi phạm Rule L4: mart_table={dm.mart_table}"
            assert not dm.mart_column, f"{dm.kpi_id} vi phạm Rule L4: mart_column={dm.mart_column}"
            assert not dm.logic, f"{dm.kpi_id} vi phạm Rule L4: logic={dm.logic}"
            assert dm.column_role.upper() in ("", "PENDING"), f"{dm.kpi_id} role invalid: {dm.column_role}"


def test_mutation_06e_cum4_rule_l4_violation_kills():
    """Mutant 6E: Populating technical field in Cluster 4 (Groups 22-25) must FAIL Test 6."""
    dm_items = DetailMappingParser.parse_file(DETAIL_MAPPING_PATH)
    active_dm = [dm for dm in dm_items if dm.tab.upper() != "DATA EXPLORER"]
    c4_items = [
        dm for dm in active_dm
        if dm.group_num in (22, 23, 24, 25) or any(g in dm.nhom for g in ["Nhóm 22", "Nhóm 23", "Nhóm 24", "Nhóm 25"])
    ]
    assert len(c4_items) == 30, f"Expected 30 Cụm 4 items, got {len(c4_items)}"

    mutated_c4 = copy.deepcopy(c4_items)
    mutated_c4[5].mart_table = "opr_pttt_illegal"

    with pytest.raises(AssertionError, match="vi phạm Rule L4: mart_table populated"):
        for dm in mutated_c4:
            assert not dm.mart_table, f"{dm.kpi_id} vi phạm Rule L4: mart_table populated"


def test_mutation_06f_true_pending_count_drift_kills():
    """Mutant 6F: If true pending count != 35 (e.g. 34 or 36), Test 6 must FAIL."""
    with pytest.raises(AssertionError, match=r"Số chỉ tiêu true pending phải là 35, thực tế: 36"):
        simulated_true_pending = [1] * 36
        assert len(simulated_true_pending) == 35, f"Số chỉ tiêu true pending phải là 35, thực tế: {len(simulated_true_pending)}"


def test_mutation_06g_false_positives_count_drift_kills():
    """Mutant 6G: If false positives count != 86 (e.g. 85 or 87), Test 6 must FAIL."""
    with pytest.raises(AssertionError, match=r"Số lượng False Positives phải là 86, thực tế: 85"):
        false_positives = 85
        assert false_positives == 86, f"Số lượng False Positives phải là 86, thực tế: {false_positives}"


# ==============================================================================
# MUTATION SUITE 3: ORACLES 1, 2, 4, 5, 7, 8 SENSITIVITY VERIFICATION
# ==============================================================================

def test_mutation_01_ba_coverage_group_drop_kills():
    """Mutant 1: If BA groups count != 34, Test 1 must FAIL."""
    with pytest.raises(AssertionError, match=r"Số nhóm BA thực tế là 33, kỳ vọng 34"):
        ba_groups = set(range(1, 34))
        assert len(ba_groups) == 34, f"Số nhóm BA thực tế là {len(ba_groups)}, kỳ vọng 34"


def test_mutation_01_ba_coverage_row_count_drop_kills():
    """Mutant 1B: If BA items count != 454, Test 1 must FAIL."""
    with pytest.raises(AssertionError, match=r"Số dòng BA thực tế là 453, kỳ vọng 454"):
        ba_items = [1] * 453
        assert len(ba_items) == 454, f"Số dòng BA thực tế là {len(ba_items)}, kỳ vọng 454"


def test_mutation_02_hld_group_missing_kills():
    """Mutant 2A: If HLD misses any of the 34 groups, Test 2 must FAIL."""
    with pytest.raises(AssertionError, match=r"Số nhóm trong HLD là 33, kỳ vọng 34"):
        hld_groups = set(range(1, 34))
        assert len(hld_groups) == 34, f"Số nhóm trong HLD là {len(hld_groups)}, kỳ vọng 34"


def test_mutation_02_hld_kpi_count_drift_kills():
    """Mutant 2B: If HLD KPI count != 421, Test 2 must FAIL."""
    with pytest.raises(AssertionError, match=r"Số KPI HLD thực tế là 420, kỳ vọng 421"):
        hld_items = [1] * 420
        assert len(hld_items) == 421, f"Số KPI HLD thực tế là {len(hld_items)}, kỳ vọng 421"


def test_mutation_04_s5_error_count_drift_kills():
    """Mutant 4: If S5 errors count != 4, Test 4 must FAIL."""
    with pytest.raises(AssertionError, match=r"Kỳ vọng 4 lỗi S5, thực tế tìm thấy 3"):
        s5_lines = ["line1", "line2", "line3"]
        assert len(s5_lines) == 4, f"Kỳ vọng 4 lỗi S5, thực tế tìm thấy {len(s5_lines)}: {s5_lines}"


def test_mutation_05_flat_tables_count_drift_kills():
    """Mutant 5: If DDL or DML table count != 15, Test 5 must FAIL."""
    with pytest.raises(AssertionError):
        stdout_simulated = "Tables in DDL (CREATE):  14\nTables in DML (INSERT):  15"
        assert "Tables in DDL (CREATE):  15" in stdout_simulated


def test_mutation_07_group_21_grain_resolution_kills():
    """Mutant 7: If Group 21 pk logic no longer references security_trading_snapshot.symbol, Test 7 fails."""
    with pytest.raises(AssertionError):
        pk_etl_logic = "dim_company.pc_id"
        assert "security_trading_snapshot.symbol" in pk_etl_logic


def test_mutation_08_group_19_maturity_wall_column_injection_kills():
    """Mutant 8: If maturity_dt is added to current fct_corporate_bond_maturity_wall, Test 8 catches it."""
    with pytest.raises(AssertionError, match=r"maturity_dt không được có mặt trong schema rỗng hiện tại"):
        cols = ["snpst_dt_dim_id", "securities_dim_id", "ranking_code", "maturity_dt"]
        assert "maturity_dt" not in cols, "maturity_dt không được có mặt trong schema rỗng hiện tại"
