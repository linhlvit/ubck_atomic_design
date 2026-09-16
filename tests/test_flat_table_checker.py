# -*- coding: utf-8 -*-
"""
tests/test_flat_table_checker.py — Comprehensive Test Suite for Gate 4 Flat Table Checker

Tests Gate 4 ClickHouse Flat Table Quality Gate:
  1. Positive Controls:
     - Real-world audit of GSTT (check_flat_table.py -m GSTT --strict) returns exit code 0, 0 violations.
     - Real-world audit of Common (check_flat_table.py -m Common --strict) returns exit code 0, 0 violations.
  2. Negative Controls (isolated temporary fixtures):
     - Criterion 1 (L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING): Missing Fact column in DDL, missing date columns.
     - Criterion 2 (L4-FLAT-TABLE-PROJECTION-MISALIGNMENT): Count mismatch, order mismatch, alias mismatch.
     - Criterion 3 (L4-FLAT-TABLE-COLUMN-DRIFT): Unapproved columns not in master registry.
     - Criterion 4 (L4-FLAT-TABLE-PARAMETER-INCONSISTENT): Date filter using :business_date instead of :etl_date.
     - Criterion 5 (L4-COMMON-DIM-CLICKHOUSE-MISSING): Missing is_trading_date or missing DDL/DML.
  3. CLI Flags Tests:
     - -m / --module (case-insensitivity, nonexistent module).
     - --root (custom path).
     - --strict (exit code 1 on issues vs exit code 0 when clean).
     - --json (valid structured output).
"""
from __future__ import annotations

import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

REPO_ROOT = Path(__file__).resolve().parents[1]
SKILL_SCRIPTS_DIR = REPO_ROOT / ".claude" / "skills" / "datamart-review" / "scripts"
ROOT_SCRIPTS_DIR = REPO_ROOT / "scripts"

for p in [str(SKILL_SCRIPTS_DIR), str(ROOT_SCRIPTS_DIR)]:
    if p not in sys.path:
        sys.path.insert(0, p)

from datamart_flat_table_checker import (
    CDR_DT_FLAT_REQUIRED_COLS,
    FlatTableCheckResult,
    FlatTableIssue,
    audit_all_flat_tables,
    audit_module_flat_table,
    check_common_dimensions,
)

CHECK_FLAT_TABLE_SCRIPT = SKILL_SCRIPTS_DIR / "check_flat_table.py"
if not CHECK_FLAT_TABLE_SCRIPT.exists():
    CHECK_FLAT_TABLE_SCRIPT = ROOT_SCRIPTS_DIR / "check_flat_table.py"


class TestFlatTableCheckerPositiveControls(unittest.TestCase):
    """Positive controls verifying real-world benchmarks GSTT and Common pass Gate 4 with 0 violations."""

    def test_01_real_repo_gstt_programmatic_audit_passes(self):
        """GSTT audit via audit_module_flat_table returns PASS with 0 critical and 0 warning issues."""
        result = audit_module_flat_table(REPO_ROOT, "GSTT")
        self.assertEqual(result.module, "GSTT")
        self.assertEqual(result.status, "PASS")
        self.assertEqual(result.critical_count, 0, f"Unexpected critical issues in GSTT: {result.issues}")
        self.assertEqual(result.warning_count, 0)
        self.assertEqual(len(result.issues), 0)
        self.assertGreater(result.total_tables_ddl, 0)
        self.assertEqual(result.total_tables_ddl, result.total_tables_dml)

    def test_02_real_repo_common_programmatic_audit_passes(self):
        """Common audit via audit_module_flat_table returns PASS with 0 critical and 0 warning issues."""
        result = audit_module_flat_table(REPO_ROOT, "Common")
        self.assertEqual(result.module, "COMMON")
        self.assertEqual(result.status, "PASS")
        self.assertEqual(result.critical_count, 0, f"Unexpected critical issues in Common: {result.issues}")
        self.assertEqual(result.warning_count, 0)
        self.assertEqual(len(result.issues), 0)
        self.assertEqual(result.total_tables_ddl, 1)
        self.assertEqual(result.total_tables_dml, 1)

    def test_03_real_repo_gstt_cli_strict_exit_code_0(self):
        """check_flat_table.py -m GSTT --strict exits with code 0 and reports [PASS]."""
        cmd = [
            sys.executable,
            str(CHECK_FLAT_TABLE_SCRIPT),
            "-m", "GSTT",
            "--root", str(REPO_ROOT),
            "--strict",
        ]
        proc = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(proc.returncode, 0, f"GSTT Gate 4 check failed with code {proc.returncode}: {proc.stderr or proc.stdout}")
        self.assertIn("GSTT [PASS]", proc.stdout)
        self.assertIn("Critical Issues:         0", proc.stdout)

    def test_04_real_repo_common_cli_strict_exit_code_0(self):
        """check_flat_table.py -m Common --strict exits with code 0 and reports [PASS]."""
        cmd = [
            sys.executable,
            str(CHECK_FLAT_TABLE_SCRIPT),
            "-m", "Common",
            "--root", str(REPO_ROOT),
            "--strict",
        ]
        proc = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(proc.returncode, 0, f"Common Gate 4 check failed with code {proc.returncode}: {proc.stderr or proc.stdout}")
        self.assertIn("COMMON [PASS]", proc.stdout)
        self.assertIn("Critical Issues:         0", proc.stdout)

    def test_05_real_repo_case_insensitive_module_arg(self):
        """check_flat_table.py supports lowercase -m gstt and -m common."""
        for mod in ["gstt", "common"]:
            cmd = [
                sys.executable,
                str(CHECK_FLAT_TABLE_SCRIPT),
                "-m", mod,
                "--root", str(REPO_ROOT),
                "--strict",
            ]
            proc = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
            self.assertEqual(proc.returncode, 0, f"Module {mod} failed: {proc.stdout}")


class BaseMockWorkspaceFixture(unittest.TestCase):
    """Base fixture creating an isolated mock repository layout for negative control tests."""

    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.mock_root = Path(self.temp_dir.name)

        # Standard directories
        self.lld_dir = self.mock_root / "Datamart" / "lld" / "TEST_MOD"
        self.lld_dir.mkdir(parents=True, exist_ok=True)
        self.ft_dir = self.mock_root / "Datamart" / "flat-table" / "TEST_MOD"
        self.ft_dir.mkdir(parents=True, exist_ok=True)
        self.common_dir = self.mock_root / "Datamart" / "flat-table" / "Common"
        self.common_dir.mkdir(parents=True, exist_ok=True)

        # Populate valid Common flat dimension so Common checks pass by default
        self._write_valid_common_dimension()

        # Populate master datamart_attributes.csv
        self.master_csv = self.mock_root / "Datamart" / "lld" / "datamart_attributes.csv"
        self.master_csv.write_text(
            "datamart_table,datamart_column,datamart_attribute,key,data_type,description,etl_logic\n"
            "fct_test,fct_test_id,Test ID,PK,Int64,Primary Key,IDENTITY\n"
            "fct_test,snpst_dt_dim_id,Snapshot Date Dimension Id,FK,Int32,Snapshot date key,LOOKUP cdr_dt_dim\n"
            "fct_test,security_code,Security Code,,String,Stock ticker,src.code\n"
            "fct_test,trade_vol,Trade Volume,,Int64,Trading volume,src.volume\n"
            "fct_test,trade_val,Trade Value,,Decimal(18,2),Trading value,src.value\n",
            encoding="utf-8",
        )

        # Populate valid LLD CSV
        self.lld_csv = self.lld_dir / "DTM_TEST_MOD_fct_test.csv"
        self.lld_csv.write_text(
            "datamart_table,datamart_column,datamart_attribute,key,data_type,description,etl_logic\n"
            "fct_test,fct_test_id,Test ID,PK,Int64,Primary Key,IDENTITY\n"
            "fct_test,snpst_dt_dim_id,Snapshot Date Dimension Id,FK,Int32,Snapshot date key,LOOKUP cdr_dt_dim\n"
            "fct_test,security_code,Security Code,,String,Stock ticker,src.code\n"
            "fct_test,trade_vol,Trade Volume,,Int64,Trading volume,src.volume\n"
            "fct_test,trade_val,Trade Value,,Decimal(18,2),Trading value,src.value\n"
            "fct_test,ds_batch_date,Batch Date,,Date,Audit field,BATCH_DATE\n",
            encoding="utf-8",
        )

        # Populate default valid DDL and DML
        self.ddl_sql = self.ft_dir / "01_create_test_mod_flat_tables.sql"
        self.dml_sql = self.ft_dir / "02_populate_test_mod_flat_tables.sql"
        self._write_valid_module_flat_tables()

    def tearDown(self):
        self.temp_dir.cleanup()

    def _write_valid_common_dimension(self):
        ddl = self.common_dir / "01_create_common_flat_tables.sql"
        ddl.write_text(
            "CREATE TABLE IF NOT EXISTS datamart.cdr_dt_flat (\n"
            "    cdr_dt_dim_id Int32,\n"
            "    cdr_dt Date,\n"
            "    year Int32,\n"
            "    quarter Int8,\n"
            "    month Int8,\n"
            "    day_of_week Int8,\n"
            "    is_weekend UInt8,\n"
            "    holiday_flag UInt8,\n"
            "    is_trading_date UInt8\n"
            ") ENGINE = MergeTree() ORDER BY (cdr_dt_dim_id);\n",
            encoding="utf-8",
        )
        dml = self.common_dir / "02_populate_common_flat_tables.sql"
        dml.write_text(
            "INSERT INTO datamart.cdr_dt_flat (\n"
            "    cdr_dt_dim_id,\n"
            "    cdr_dt,\n"
            "    year,\n"
            "    quarter,\n"
            "    month,\n"
            "    day_of_week,\n"
            "    is_weekend,\n"
            "    holiday_flag,\n"
            "    is_trading_date\n"
            ")\n"
            "SELECT\n"
            "    cdr_dt_dim_id,\n"
            "    cdr_dt,\n"
            "    year,\n"
            "    quarter,\n"
            "    month,\n"
            "    day_of_week,\n"
            "    is_weekend,\n"
            "    holiday_flag,\n"
            "    is_trading_date\n"
            "FROM datamart.cdr_dt_dim;\n",
            encoding="utf-8",
        )

    def _write_valid_module_flat_tables(self):
        self.ddl_sql.write_text(
            "CREATE TABLE IF NOT EXISTS datamart.test_mod_fct_test_flat (\n"
            "    fct_test_id Int64,\n"
            "    snpst_dt_dim_id Int32,\n"
            "    cdr_dt Date,\n"
            "    is_trading_date UInt8,\n"
            "    security_code String,\n"
            "    trade_vol Int64,\n"
            "    trade_val Decimal(18,2)\n"
            ") ENGINE = MergeTree() ORDER BY (fct_test_id);\n",
            encoding="utf-8",
        )
        self.dml_sql.write_text(
            "INSERT INTO datamart.test_mod_fct_test_flat\n"
            "SELECT\n"
            "    f.fct_test_id,\n"
            "    f.snpst_dt_dim_id,\n"
            "    d.cdr_dt,\n"
            "    d.is_trading_date,\n"
            "    f.security_code,\n"
            "    f.trade_vol,\n"
            "    f.trade_val\n"
            "FROM datamart.fct_test f\n"
            "JOIN datamart.cdr_dt_dim d ON f.snpst_dt_dim_id = d.cdr_dt_dim_id\n"
            "WHERE d.cdr_dt = :etl_date;\n",
            encoding="utf-8",
        )


class TestFlatTableCheckerNegativeControls(BaseMockWorkspaceFixture):
    """Negative controls verifying that defects in each of the 5 Gate 4 criteria are strictly caught."""

    # -------------------------------------------------------------------------
    # Criterion 1: L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING
    # -------------------------------------------------------------------------
    def test_06_criterion_1_missing_fact_column_detected(self):
        """Criterion 1: Omitted Fact column in DDL triggers L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING."""
        # DDL omits 'trade_val'
        self.ddl_sql.write_text(
            "CREATE TABLE IF NOT EXISTS datamart.test_mod_fct_test_flat (\n"
            "    fct_test_id Int64,\n"
            "    snpst_dt_dim_id Int32,\n"
            "    cdr_dt Date,\n"
            "    is_trading_date UInt8,\n"
            "    security_code String,\n"
            "    trade_vol Int64\n"
            ") ENGINE = MergeTree() ORDER BY (fct_test_id);\n",
            encoding="utf-8",
        )
        self.dml_sql.write_text(
            "INSERT INTO datamart.test_mod_fct_test_flat\n"
            "SELECT\n"
            "    f.fct_test_id,\n"
            "    f.snpst_dt_dim_id,\n"
            "    d.cdr_dt,\n"
            "    d.is_trading_date,\n"
            "    f.security_code,\n"
            "    f.trade_vol\n"
            "FROM datamart.fct_test f\n"
            "JOIN datamart.cdr_dt_dim d ON f.snpst_dt_dim_id = d.cdr_dt_dim_id\n"
            "WHERE d.cdr_dt = :etl_date;\n",
            encoding="utf-8",
        )
        result = audit_module_flat_table(self.mock_root, "TEST_MOD")
        self.assertEqual(result.status, "FAIL")
        self.assertGreaterEqual(result.critical_count, 1)
        coverage_issues = [i for i in result.issues if i.error_code == "L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING"]
        self.assertGreaterEqual(len(coverage_issues), 1)
        self.assertTrue(any("trade_val" in i.message for i in coverage_issues))

    def test_07_criterion_1_missing_calendar_date_columns_detected(self):
        """Criterion 1: Fact with Date FK lacking cdr_dt in DDL triggers L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING."""
        # DDL omits cdr_dt and is_trading_date
        self.ddl_sql.write_text(
            "CREATE TABLE IF NOT EXISTS datamart.test_mod_fct_test_flat (\n"
            "    fct_test_id Int64,\n"
            "    snpst_dt_dim_id Int32,\n"
            "    security_code String,\n"
            "    trade_vol Int64,\n"
            "    trade_val Decimal(18,2)\n"
            ") ENGINE = MergeTree() ORDER BY (fct_test_id);\n",
            encoding="utf-8",
        )
        self.dml_sql.write_text(
            "INSERT INTO datamart.test_mod_fct_test_flat\n"
            "SELECT\n"
            "    f.fct_test_id,\n"
            "    f.snpst_dt_dim_id,\n"
            "    f.security_code,\n"
            "    f.trade_vol,\n"
            "    f.trade_val\n"
            "FROM datamart.fct_test f\n"
            "WHERE f.snpst_dt_dim_id = :etl_date;\n",
            encoding="utf-8",
        )
        result = audit_module_flat_table(self.mock_root, "TEST_MOD")
        self.assertEqual(result.status, "FAIL")
        coverage_issues = [i for i in result.issues if i.error_code == "L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING"]
        self.assertTrue(any("missing calendar date columns" in i.message for i in coverage_issues))

    def test_08_criterion_1_tech_audit_columns_excluded_from_missing_check(self):
        """Criterion 1: Tech audit columns (ds_batch_date, ds_rcrd_st, etc.) do not cause false positives."""
        # Default setup already has ds_batch_date in LLD CSV, omitted in DDL
        result = audit_module_flat_table(self.mock_root, "TEST_MOD")
        coverage_issues = [i for i in result.issues if i.error_code == "L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING"]
        self.assertEqual(len(coverage_issues), 0, "Tech audit fields must not trigger missing coverage")

    # -------------------------------------------------------------------------
    # Criterion 2: L4-FLAT-TABLE-PROJECTION-MISALIGNMENT
    # -------------------------------------------------------------------------
    def test_09_criterion_2_column_count_mismatch_detected(self):
        """Criterion 2: Column count mismatch between DDL and DML triggers L4-FLAT-TABLE-PROJECTION-MISALIGNMENT."""
        # DDL has 7 columns, but DML SELECT has 6 columns (omits trade_val in SELECT)
        self.dml_sql.write_text(
            "INSERT INTO datamart.test_mod_fct_test_flat\n"
            "SELECT\n"
            "    f.fct_test_id,\n"
            "    f.snpst_dt_dim_id,\n"
            "    d.cdr_dt,\n"
            "    d.is_trading_date,\n"
            "    f.security_code,\n"
            "    f.trade_vol\n"
            "FROM datamart.fct_test f\n"
            "JOIN datamart.cdr_dt_dim d ON f.snpst_dt_dim_id = d.cdr_dt_dim_id\n"
            "WHERE d.cdr_dt = :etl_date;\n",
            encoding="utf-8",
        )
        result = audit_module_flat_table(self.mock_root, "TEST_MOD")
        self.assertEqual(result.status, "FAIL")
        align_issues = [i for i in result.issues if i.error_code == "L4-FLAT-TABLE-PROJECTION-MISALIGNMENT"]
        self.assertGreaterEqual(len(align_issues), 1)
        self.assertTrue(any("Column count mismatch" in i.message for i in align_issues))

    def test_10_criterion_2_column_order_mismatch_detected(self):
        """Criterion 2: Column order inversion between DDL and DML triggers L4-FLAT-TABLE-PROJECTION-MISALIGNMENT."""
        # DDL order: trade_vol then trade_val. DML inverts: trade_val then trade_vol
        self.dml_sql.write_text(
            "INSERT INTO datamart.test_mod_fct_test_flat\n"
            "SELECT\n"
            "    f.fct_test_id,\n"
            "    f.snpst_dt_dim_id,\n"
            "    d.cdr_dt,\n"
            "    d.is_trading_date,\n"
            "    f.security_code,\n"
            "    f.trade_val,\n"
            "    f.trade_vol\n"
            "FROM datamart.fct_test f\n"
            "JOIN datamart.cdr_dt_dim d ON f.snpst_dt_dim_id = d.cdr_dt_dim_id\n"
            "WHERE d.cdr_dt = :etl_date;\n",
            encoding="utf-8",
        )
        result = audit_module_flat_table(self.mock_root, "TEST_MOD")
        self.assertEqual(result.status, "FAIL")
        align_issues = [i for i in result.issues if i.error_code == "L4-FLAT-TABLE-PROJECTION-MISALIGNMENT"]
        self.assertGreaterEqual(len(align_issues), 1)
        self.assertTrue(any("Column name mismatch at position" in i.message for i in align_issues))

    def test_11_criterion_2_table_set_mismatch_detected(self):
        """Criterion 2: Target table in DDL missing in DML triggers L4-FLAT-TABLE-PROJECTION-MISALIGNMENT."""
        # DDL creates table_a and table_b, DML only inserts into table_a
        self.ddl_sql.write_text(
            "CREATE TABLE IF NOT EXISTS datamart.test_mod_fct_test_flat (\n"
            "    fct_test_id Int64,\n"
            "    snpst_dt_dim_id Int32,\n"
            "    cdr_dt Date,\n"
            "    is_trading_date UInt8,\n"
            "    security_code String,\n"
            "    trade_vol Int64,\n"
            "    trade_val Decimal(18,2)\n"
            ") ENGINE = MergeTree() ORDER BY (fct_test_id);\n\n"
            "CREATE TABLE IF NOT EXISTS datamart.test_mod_unpopulated_flat (\n"
            "    id Int64\n"
            ") ENGINE = MergeTree() ORDER BY (id);\n",
            encoding="utf-8",
        )
        result = audit_module_flat_table(self.mock_root, "TEST_MOD")
        self.assertEqual(result.status, "FAIL")
        align_issues = [i for i in result.issues if i.error_code == "L4-FLAT-TABLE-PROJECTION-MISALIGNMENT"]
        self.assertTrue(any("not found in DML INSERT INTO" in i.message for i in align_issues))

    # -------------------------------------------------------------------------
    # Criterion 3: L4-FLAT-TABLE-COLUMN-DRIFT
    # -------------------------------------------------------------------------
    def test_12_criterion_3_unapproved_column_drift_detected(self):
        """Criterion 3: Injected rogue column in DDL triggers L4-FLAT-TABLE-COLUMN-DRIFT."""
        self.ddl_sql.write_text(
            "CREATE TABLE IF NOT EXISTS datamart.test_mod_fct_test_flat (\n"
            "    fct_test_id Int64,\n"
            "    snpst_dt_dim_id Int32,\n"
            "    cdr_dt Date,\n"
            "    is_trading_date UInt8,\n"
            "    security_code String,\n"
            "    trade_vol Int64,\n"
            "    trade_val Decimal(18,2),\n"
            "    unapproved_rogue_column String\n"
            ") ENGINE = MergeTree() ORDER BY (fct_test_id);\n",
            encoding="utf-8",
        )
        self.dml_sql.write_text(
            "INSERT INTO datamart.test_mod_fct_test_flat\n"
            "SELECT\n"
            "    f.fct_test_id,\n"
            "    f.snpst_dt_dim_id,\n"
            "    d.cdr_dt,\n"
            "    d.is_trading_date,\n"
            "    f.security_code,\n"
            "    f.trade_vol,\n"
            "    f.trade_val,\n"
            "    'rogue' AS unapproved_rogue_column\n"
            "FROM datamart.fct_test f\n"
            "JOIN datamart.cdr_dt_dim d ON f.snpst_dt_dim_id = d.cdr_dt_dim_id\n"
            "WHERE d.cdr_dt = :etl_date;\n",
            encoding="utf-8",
        )
        result = audit_module_flat_table(self.mock_root, "TEST_MOD")
        self.assertEqual(result.status, "FAIL")
        drift_issues = [i for i in result.issues if i.error_code == "L4-FLAT-TABLE-COLUMN-DRIFT"]
        self.assertGreaterEqual(len(drift_issues), 1)
        self.assertTrue(any("unapproved_rogue_column" in i.message for i in drift_issues))

    def test_13_criterion_3_standard_calendar_and_prefixes_permitted(self):
        """Criterion 3: Permitted suffixes (_src_stm_code, _cdr_dt) and prefixes (fct_) do not trigger drift."""
        # Add permissible column variants
        self.ddl_sql.write_text(
            "CREATE TABLE IF NOT EXISTS datamart.test_mod_fct_test_flat (\n"
            "    fct_test_id Int64,\n"
            "    snpst_dt_dim_id Int32,\n"
            "    cdr_dt Date,\n"
            "    is_trading_date UInt8,\n"
            "    security_code String,\n"
            "    trade_vol Int64,\n"
            "    trade_val Decimal(18,2),\n"
            "    fct_trade_vol Int64,\n"
            "    custom_src_stm_code String,\n"
            "    effective_cdr_dt Date\n"
            ") ENGINE = MergeTree() ORDER BY (fct_test_id);\n",
            encoding="utf-8",
        )
        self.dml_sql.write_text(
            "INSERT INTO datamart.test_mod_fct_test_flat\n"
            "SELECT\n"
            "    f.fct_test_id,\n"
            "    f.snpst_dt_dim_id,\n"
            "    d.cdr_dt,\n"
            "    d.is_trading_date,\n"
            "    f.security_code,\n"
            "    f.trade_vol,\n"
            "    f.trade_val,\n"
            "    f.trade_vol AS fct_trade_vol,\n"
            "    'SCMS' AS custom_src_stm_code,\n"
            "    d.cdr_dt AS effective_cdr_dt\n"
            "FROM datamart.fct_test f\n"
            "JOIN datamart.cdr_dt_dim d ON f.snpst_dt_dim_id = d.cdr_dt_dim_id\n"
            "WHERE d.cdr_dt = :etl_date;\n",
            encoding="utf-8",
        )
        result = audit_module_flat_table(self.mock_root, "TEST_MOD")
        drift_issues = [i for i in result.issues if i.error_code == "L4-FLAT-TABLE-COLUMN-DRIFT"]
        self.assertEqual(len(drift_issues), 0, f"Expected 0 drift issues for standard aliases, got: {drift_issues}")

    # -------------------------------------------------------------------------
    # Criterion 4: L4-FLAT-TABLE-PARAMETER-INCONSISTENT
    # -------------------------------------------------------------------------
    def test_14_criterion_4_inconsistent_etl_parameter_detected(self):
        """Criterion 4: Using :business_date instead of :etl_date triggers L4-FLAT-TABLE-PARAMETER-INCONSISTENT."""
        self.dml_sql.write_text(
            "INSERT INTO datamart.test_mod_fct_test_flat\n"
            "SELECT\n"
            "    f.fct_test_id,\n"
            "    f.snpst_dt_dim_id,\n"
            "    d.cdr_dt,\n"
            "    d.is_trading_date,\n"
            "    f.security_code,\n"
            "    f.trade_vol,\n"
            "    f.trade_val\n"
            "FROM datamart.fct_test f\n"
            "JOIN datamart.cdr_dt_dim d ON f.snpst_dt_dim_id = d.cdr_dt_dim_id\n"
            "WHERE d.cdr_dt = :business_date;\n",
            encoding="utf-8",
        )
        result = audit_module_flat_table(self.mock_root, "TEST_MOD")
        self.assertEqual(result.status, "FAIL")
        param_issues = [i for i in result.issues if i.error_code == "L4-FLAT-TABLE-PARAMETER-INCONSISTENT"]
        self.assertGreaterEqual(len(param_issues), 1)
        self.assertTrue(any(":business_date" in i.message for i in param_issues))

    def test_15_criterion_4_hardcoded_literal_or_braced_date_detected(self):
        """Criterion 4: Hardcoded date string '2026-09-15' or {etl_date} triggers L4-FLAT-TABLE-PARAMETER-INCONSISTENT."""
        self.dml_sql.write_text(
            "INSERT INTO datamart.test_mod_fct_test_flat\n"
            "SELECT\n"
            "    f.fct_test_id,\n"
            "    f.snpst_dt_dim_id,\n"
            "    d.cdr_dt,\n"
            "    d.is_trading_date,\n"
            "    f.security_code,\n"
            "    f.trade_vol,\n"
            "    f.trade_val\n"
            "FROM datamart.fct_test f\n"
            "JOIN datamart.cdr_dt_dim d ON f.snpst_dt_dim_id = d.cdr_dt_dim_id\n"
            "WHERE d.cdr_dt = '2026-09-15';\n",
            encoding="utf-8",
        )
        result = audit_module_flat_table(self.mock_root, "TEST_MOD")
        self.assertEqual(result.status, "FAIL")
        param_issues = [i for i in result.issues if i.error_code == "L4-FLAT-TABLE-PARAMETER-INCONSISTENT"]
        self.assertGreaterEqual(len(param_issues), 1)

    # -------------------------------------------------------------------------
    # Criterion 5: L4-COMMON-DIM-CLICKHOUSE-MISSING
    # -------------------------------------------------------------------------
    def test_16_criterion_5_omitted_is_trading_date_detected(self):
        """Criterion 5: Omitted is_trading_date in Common cdr_dt_flat triggers L4-COMMON-DIM-CLICKHOUSE-MISSING."""
        common_ddl = self.common_dir / "01_create_common_flat_tables.sql"
        # Omit is_trading_date
        common_ddl.write_text(
            "CREATE TABLE IF NOT EXISTS datamart.cdr_dt_flat (\n"
            "    cdr_dt_dim_id Int32,\n"
            "    cdr_dt Date,\n"
            "    year Int32,\n"
            "    quarter Int8,\n"
            "    month Int8,\n"
            "    day_of_week Int8,\n"
            "    is_weekend UInt8,\n"
            "    holiday_flag UInt8\n"
            ") ENGINE = MergeTree() ORDER BY (cdr_dt_dim_id);\n",
            encoding="utf-8",
        )
        issues = check_common_dimensions(self.mock_root)
        self.assertGreaterEqual(len(issues), 1)
        common_issues = [i for i in issues if i.error_code == "L4-COMMON-DIM-CLICKHOUSE-MISSING"]
        self.assertTrue(any("is_trading_date" in i.message for i in common_issues))

    def test_17_criterion_5_missing_common_dml_detected(self):
        """Criterion 5: Missing 02_populate_common_flat_tables.sql triggers L4-COMMON-DIM-CLICKHOUSE-MISSING."""
        dml_file = self.common_dir / "02_populate_common_flat_tables.sql"
        if dml_file.exists():
            dml_file.unlink()
        issues = check_common_dimensions(self.mock_root)
        self.assertGreaterEqual(len(issues), 1)
        common_issues = [i for i in issues if i.error_code == "L4-COMMON-DIM-CLICKHOUSE-MISSING"]
        self.assertTrue(any("Missing DML file" in i.message for i in common_issues))


class TestFlatTableCheckerCLIFlags(BaseMockWorkspaceFixture):
    """Subprocess CLI tests verifying flags -m/--module, --root, --strict, --json."""

    def test_18_cli_strict_exit_code_1_on_failure(self):
        """CLI under --strict returns exit code 1 when negative control is injected."""
        # Inject bad param
        self.dml_sql.write_text(
            "INSERT INTO datamart.test_mod_fct_test_flat\n"
            "SELECT\n"
            "    f.fct_test_id,\n"
            "    f.snpst_dt_dim_id,\n"
            "    d.cdr_dt,\n"
            "    d.is_trading_date,\n"
            "    f.security_code,\n"
            "    f.trade_vol,\n"
            "    f.trade_val\n"
            "FROM datamart.fct_test f\n"
            "JOIN datamart.cdr_dt_dim d ON f.snpst_dt_dim_id = d.cdr_dt_dim_id\n"
            "WHERE d.cdr_dt = :business_date;\n",
            encoding="utf-8",
        )
        cmd = [
            sys.executable,
            str(CHECK_FLAT_TABLE_SCRIPT),
            "-m", "TEST_MOD",
            "--root", str(self.mock_root),
            "--strict",
        ]
        proc = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(proc.returncode, 1, "Must exit with 1 on critical issue under --strict")
        self.assertIn("TEST_MOD [FAIL]", proc.stdout)
        self.assertIn("L4-FLAT-TABLE-PARAMETER-INCONSISTENT", proc.stdout)

    def test_19_cli_json_flag_structure(self):
        """CLI with --json produces valid JSON document containing overall_status and modules list."""
        cmd = [
            sys.executable,
            str(CHECK_FLAT_TABLE_SCRIPT),
            "-m", "TEST_MOD",
            "--root", str(self.mock_root),
            "--json",
        ]
        proc = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(proc.returncode, 0)
        data = json.loads(proc.stdout)
        self.assertIn("overall_status", data)
        self.assertEqual(data["overall_status"], "PASS")
        self.assertIn("modules", data)
        self.assertEqual(len(data["modules"]), 1)
        mod_data = data["modules"][0]
        self.assertEqual(mod_data["module"], "TEST_MOD")
        self.assertEqual(mod_data["status"], "PASS")
        self.assertEqual(mod_data["critical_count"], 0)
        self.assertEqual(mod_data["warning_count"], 0)

    def test_20_cli_missing_module_handled_gracefully(self):
        """CLI returns exit code 1 when target module has no flat table DDL file."""
        cmd = [
            sys.executable,
            str(CHECK_FLAT_TABLE_SCRIPT),
            "-m", "NONEXISTENT_XYZ",
            "--root", str(self.mock_root),
            "--strict",
        ]
        proc = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(proc.returncode, 1)
        self.assertIn("No DDL file found for module", proc.stdout)


if __name__ == "__main__":
    unittest.main()
