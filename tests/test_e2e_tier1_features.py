# -*- coding: utf-8 -*-
"""
tests/test_e2e_tier1_features.py
Tier 1: Feature Coverage & Interface Contracts Test Suite

Covers:
- Feature 5 & 7: 3-Way Orphan Checker Engine & CLI
  * Happy path clean fact table matching LLD ↔ HLD ↔ Flat Table SQL
  * Dimension filtering (Dimensions do not require flat tables)
  * Conformed / Reused entity handling (reuse_status in ('reuse', 'partial', 'conformed'))
  * Branch A detection (Incomplete active entity needing LLD/Flat Table)
  * Branch B detection (Deprecated orphan entity needing all-tier cleanup)
  * CLI arguments: -m, --strict, --json, -o, -v, --root
- Feature 6 & 8: ETL Logic Parity Checker Engine & CLI
  * Happy path clean attribute match between module CSV and master registry
  * Missing in master detection (attribute in module CSV missing from master)
  * Missing in module detection (attribute in master missing from module CSV)
  * Content mismatch detection (differing etl_logic expressions)
  * CLI arguments: -m, --strict, --json, -o, -v, --root
- Feature 9: Backward Compatibility
  * datamart_date_fk_checker.py argument preservation and role-playing rules
  * datamart_progress_analyzer.py argument preservation
- Feature 1 & 2: Documentation & Reference Standards
"""

from __future__ import annotations

import csv
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

# Ensure repo and scripts directories are in sys.path
REPO_ROOT = Path(__file__).resolve().parents[1]
SKILL_DIR = REPO_ROOT / ".claude" / "skills" / "datamart-review"
SKILL_SCRIPTS_DIR = SKILL_DIR / "scripts"
COMMON_DIR = SKILL_SCRIPTS_DIR / "datamart_common"
ROOT_SCRIPTS_DIR = REPO_ROOT / "scripts"

for p in [str(SKILL_SCRIPTS_DIR), str(COMMON_DIR), str(ROOT_SCRIPTS_DIR)]:
    if p not in sys.path:
        sys.path.insert(0, p)

# Check availability of M2 scripts
ORPHAN_CHECKER_CLI = None
for candidate in [
    SKILL_SCRIPTS_DIR / "datamart_orphan_checker.py",
    ROOT_SCRIPTS_DIR / "datamart_orphan_checker.py",
]:
    if candidate.exists():
        ORPHAN_CHECKER_CLI = candidate
        break

PARITY_CHECKER_CLI = None
for candidate in [
    SKILL_SCRIPTS_DIR / "datamart_parity_checker.py",
    ROOT_SCRIPTS_DIR / "datamart_parity_checker.py",
]:
    if candidate.exists():
        PARITY_CHECKER_CLI = candidate
        break

HAS_ORPHAN_CHECKER = ORPHAN_CHECKER_CLI is not None
HAS_PARITY_CHECKER = PARITY_CHECKER_CLI is not None

# Existing M0 scripts
DATE_FK_SCRIPT = None
for candidate in [
    SKILL_SCRIPTS_DIR / "datamart_date_fk_checker.py",
    ROOT_SCRIPTS_DIR / "datamart_date_fk_checker.py",
]:
    if candidate.exists():
        DATE_FK_SCRIPT = candidate
        break

PROGRESS_ANALYZER_SCRIPT = None
for candidate in [
    SKILL_SCRIPTS_DIR / "datamart_progress_analyzer.py",
    ROOT_SCRIPTS_DIR / "datamart_progress_analyzer.py",
]:
    if candidate.exists():
        PROGRESS_ANALYZER_SCRIPT = candidate
        break


class TestTier1OrphanChecker(unittest.TestCase):
    """Tier 1 tests for 3-Way Orphan Entity Checker."""

    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.mock_root = Path(self.temp_dir.name)

        # Create mock directory structure
        self.hld_dir = self.mock_root / "Datamart" / "hld"
        self.lld_dir = self.mock_root / "Datamart" / "lld" / "TESTMOD"
        self.flat_dir = self.mock_root / "Datamart" / "flat-table" / "TESTMOD"
        self.hld_dir.mkdir(parents=True, exist_ok=True)
        self.lld_dir.mkdir(parents=True, exist_ok=True)
        self.flat_dir.mkdir(parents=True, exist_ok=True)

    def tearDown(self):
        self.temp_dir.cleanup()

    def _create_clean_mock_environment(self):
        """Creates a mock module with 1 fact table, 1 dim table, and matching flat table."""
        # HLD Entities
        hld_csv = self.hld_dir / "DTM_TESTMOD_Entities.csv"
        with open(hld_csv, "w", encoding="utf-8", newline="") as f:
            writer = csv.writer(f)
            writer.writerow([
                "datamart_entity", "table_type", "reuse_status", "status",
                "description", "source_table", "FKs"
            ])
            writer.writerow([
                "Fact Test Snapshot", "fact", "new", "ready",
                "Fact table description", "atomic_test", "Calendar Date Dimension.Calendar Date Dimension Id"
            ])
            writer.writerow([
                "Test Dimension", "dim", "new", "ready",
                "Dim table description", "atomic_dim", ""
            ])
            writer.writerow([
                "Calendar Date Dimension", "dim", "reuse", "ready",
                "Common date dimension", "cdr_dt_dim", ""
            ])

        # LLD Module files
        fact_lld = self.lld_dir / "DTM_TESTMOD_fct_test_snpst.csv"
        with open(fact_lld, "w", encoding="utf-8", newline="") as f:
            writer = csv.writer(f)
            writer.writerow([
                "datamart_entity", "datamart_table", "datamart_attribute", "datamart_column",
                "nullable", "data_domain", "data_type", "key", "description", "etl_logic",
                "etl_logic_type", "source_entity", "atomic_table", "source_attribute", "atomic_column"
            ])
            writer.writerow([
                "Fact Test Snapshot", "fct_test_snpst", "Snapshot Date Dimension Id", "snpst_dt_dim_id",
                "false", "General", "bigint", "FK", "Date FK", "direct", "direct", "Date", "cdr_dt_dim", "Id", "id"
            ])

        dim_lld = self.lld_dir / "DTM_TESTMOD_test_dim.csv"
        with open(dim_lld, "w", encoding="utf-8", newline="") as f:
            writer = csv.writer(f)
            writer.writerow([
                "datamart_entity", "datamart_table", "datamart_attribute", "datamart_column",
                "nullable", "data_domain", "data_type", "key", "description", "etl_logic",
                "etl_logic_type", "source_entity", "atomic_table", "source_attribute", "atomic_column"
            ])
            writer.writerow([
                "Test Dimension", "test_dim", "Test Dim Id", "test_dim_id",
                "false", "General", "bigint", "PK", "Dim PK", "direct", "direct", "Dim", "atomic_dim", "Id", "id"
            ])

        # Flat Table SQL
        flat_sql = self.flat_dir / "01_create_testmod_flat_tables.sql"
        flat_sql.write_text(
            """
            -- DDL for testmod flat tables
            CREATE TABLE IF NOT EXISTS datamart.testmod_fct_test_snpst_flat (
                snpst_dt_dim_id Int64,
                test_col String
            ) ENGINE = MergeTree();
            """,
            encoding="utf-8",
        )

    @unittest.skipUnless(HAS_ORPHAN_CHECKER, "M2 datamart_orphan_checker not yet implemented")
    def test_01_orphan_clean_fact_table_happy_path(self):
        """Tier 1: Clean fact table matching 3-way across HLD, LLD, and Flat Table -> status PASS."""
        self._create_clean_mock_environment()
        cmd = [
            sys.executable,
            str(ORPHAN_CHECKER_CLI),
            "-m", "TESTMOD",
            "--root", str(self.mock_root),
            "--strict",
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(result.returncode, 0, f"Expected 0 on clean mock, got {result.returncode}. Output: {result.stdout}")

    @unittest.skipUnless(HAS_ORPHAN_CHECKER, "M2 datamart_orphan_checker not yet implemented")
    def test_02_orphan_dimension_exclusion(self):
        """Tier 1: Dimension tables do NOT require flat tables and must not trigger false orphans."""
        self._create_clean_mock_environment()
        cmd = [
            sys.executable,
            str(ORPHAN_CHECKER_CLI),
            "-m", "TESTMOD",
            "--root", str(self.mock_root),
            "--json",
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(result.returncode, 0)
        data = json.loads(result.stdout)
        # Verify Test Dimension is NOT in missing_flat_tables
        missing_flat = data.get("missing_flat_tables", [])
        dim_missing = [t for t in missing_flat if "test_dim" in t]
        self.assertEqual(len(dim_missing), 0, "Dimensions must be excluded from flat table requirements")

    @unittest.skipUnless(HAS_ORPHAN_CHECKER, "M2 datamart_orphan_checker not yet implemented")
    def test_03_orphan_conformed_reuse_handling(self):
        """Tier 1: Reused / conformed entities are not flagged as missing."""
        self._create_clean_mock_environment()
        cmd = [
            sys.executable,
            str(ORPHAN_CHECKER_CLI),
            "-m", "TESTMOD",
            "--root", str(self.mock_root),
            "--json",
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        data = json.loads(result.stdout)
        missing = data.get("branch_a_missing", []) + data.get("branch_b_orphans", [])
        reused_missing = [t for t in missing if "Calendar Date Dimension" in str(t)]
        self.assertEqual(len(reused_missing), 0, "Reused entities must not be flagged as missing")

    @unittest.skipUnless(HAS_ORPHAN_CHECKER, "M2 datamart_orphan_checker not yet implemented")
    def test_04_orphan_branch_a_incomplete_detection(self):
        """Tier 1: Table in LLD and Flat Table SQL but omitted from HLD Entities -> BRANCH A."""
        self._create_clean_mock_environment()
        # Add a table to LLD and Flat Table SQL, but omit it from HLD Entities.csv
        fact_lld = self.lld_dir / "DTM_TESTMOD_fct_active_missing_hld.csv"
        with open(fact_lld, "w", encoding="utf-8", newline="") as f:
            writer = csv.writer(f)
            writer.writerow([
                "datamart_entity", "datamart_table", "datamart_attribute", "datamart_column",
                "nullable", "data_domain", "data_type", "key", "description", "etl_logic",
                "etl_logic_type", "source_entity", "atomic_table", "source_attribute", "atomic_column"
            ])
            writer.writerow([
                "Fact Active Missing HLD", "fct_active_missing_hld", "Col Id", "col_id",
                "false", "General", "bigint", "PK", "Col PK", "direct", "direct", "Ent", "atomic_tbl", "Id", "id"
            ])

        flat_sql = self.flat_dir / "01_create_testmod_flat_tables.sql"
        flat_sql.write_text(
            flat_sql.read_text(encoding="utf-8") + """
            CREATE TABLE IF NOT EXISTS datamart.testmod_fct_active_missing_hld_flat (
                col_id Int64
            ) ENGINE = MergeTree();
            """,
            encoding="utf-8",
        )

        cmd = [
            sys.executable,
            str(ORPHAN_CHECKER_CLI),
            "-m", "TESTMOD",
            "--root", str(self.mock_root),
            "--json",
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        data = json.loads(result.stdout)
        branch_a = data.get("branch_a_missing", [])
        found = any("fct_active_missing_hld" in str(item) or "Fact Active Missing HLD" in str(item) for item in branch_a)
        self.assertTrue(found, f"Expected fct_active_missing_hld in Branch A, got: {branch_a}")

    @unittest.skipUnless(HAS_ORPHAN_CHECKER, "M2 datamart_orphan_checker not yet implemented")
    def test_05_orphan_branch_b_deprecated_detection(self):
        """Tier 1: Deprecated entity in HLD with 0 active KPIs -> BRANCH B (cleanup)."""
        self._create_clean_mock_environment()
        # Add a deprecated entity in HLD
        hld_csv = self.hld_dir / "DTM_TESTMOD_Entities.csv"
        with open(hld_csv, "a", encoding="utf-8", newline="") as f:
            writer = csv.writer(f)
            writer.writerow([
                "Fact Deprecated Ghost", "fact", "new", "pending",
                "[Deprecated 2026-08-01] Cancelled fact", "atomic_ghost", ""
            ])

        cmd = [
            sys.executable,
            str(ORPHAN_CHECKER_CLI),
            "-m", "TESTMOD",
            "--root", str(self.mock_root),
            "--json",
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        data = json.loads(result.stdout)
        branch_b = data.get("branch_b_orphans", [])
        found = any("Fact Deprecated Ghost" in str(item) for item in branch_b)
        self.assertTrue(found, f"Expected Fact Deprecated Ghost in Branch B, got: {branch_b}")


class TestTier1ParityChecker(unittest.TestCase):
    """Tier 1 tests for ETL Logic Parity Checker."""

    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.mock_root = Path(self.temp_dir.name)

        self.lld_dir = self.mock_root / "Datamart" / "lld" / "TESTMOD"
        self.lld_dir.mkdir(parents=True, exist_ok=True)
        self.master_csv = self.mock_root / "Datamart" / "lld" / "datamart_attributes.csv"

    def tearDown(self):
        self.temp_dir.cleanup()

    def _create_mock_parity_environment(self, master_logic="JOIN atomic_t1 ON t1.id = t2.id", module_logic=None):
        if module_logic is None:
            module_logic = master_logic

        # Master CSV
        with open(self.master_csv, "w", encoding="utf-8", newline="") as f:
            writer = csv.writer(f)
            writer.writerow([
                "datamart_entity", "datamart_table", "datamart_attribute", "datamart_column",
                "nullable", "data_domain", "data_type", "key", "description", "etl_logic",
                "etl_logic_type", "source_entity", "atomic_table", "source_attribute", "atomic_column"
            ])
            writer.writerow([
                "Fact Test", "fct_test", "Test Measure", "test_measure",
                "true", "Domain", "int", "", "Test description", master_logic,
                "direct", "Atomic", "atomic_t1", "Val", "val"
            ])

        # Module CSV
        module_csv = self.lld_dir / "DTM_TESTMOD_fct_test.csv"
        with open(module_csv, "w", encoding="utf-8", newline="") as f:
            writer = csv.writer(f)
            writer.writerow([
                "datamart_entity", "datamart_table", "datamart_attribute", "datamart_column",
                "nullable", "data_domain", "data_type", "key", "description", "etl_logic",
                "etl_logic_type", "source_entity", "atomic_table", "source_attribute", "atomic_column"
            ])
            writer.writerow([
                "Fact Test", "fct_test", "Test Measure", "test_measure",
                "true", "Domain", "int", "", "Test description", module_logic,
                "direct", "Atomic", "atomic_t1", "Val", "val"
            ])

    @unittest.skipUnless(HAS_PARITY_CHECKER, "M2 datamart_parity_checker not yet implemented")
    def test_06_parity_clean_match_happy_path(self):
        """Tier 1: 100% identical attribute and etl_logic -> status PASS."""
        self._create_mock_parity_environment()
        cmd = [
            sys.executable,
            str(PARITY_CHECKER_CLI),
            "-m", "TESTMOD",
            "--root", str(self.mock_root),
            "--strict",
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(result.returncode, 0, f"Expected 0 on parity match, got: {result.stdout}")

    @unittest.skipUnless(HAS_PARITY_CHECKER, "M2 datamart_parity_checker not yet implemented")
    def test_07_parity_missing_in_master_detection(self):
        """Tier 1: Attribute present in module file but missing in master registry."""
        self._create_mock_parity_environment()
        # Add extra attribute to module file only
        module_csv = self.lld_dir / "DTM_TESTMOD_fct_test.csv"
        with open(module_csv, "a", encoding="utf-8", newline="") as f:
            writer = csv.writer(f)
            writer.writerow([
                "Fact Test", "fct_test", "New Module Only", "new_module_only",
                "true", "Domain", "int", "", "New col", "direct",
                "direct", "Atomic", "atomic_t1", "Val2", "val2"
            ])

        cmd = [
            sys.executable,
            str(PARITY_CHECKER_CLI),
            "-m", "TESTMOD",
            "--root", str(self.mock_root),
            "--json",
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        data = json.loads(result.stdout)
        missing_in_master = data.get("missing_in_master", [])
        found = any("new_module_only" in str(item) for item in missing_in_master)
        self.assertTrue(found, f"Expected new_module_only in missing_in_master: {missing_in_master}")

    @unittest.skipUnless(HAS_PARITY_CHECKER, "M2 datamart_parity_checker not yet implemented")
    def test_08_parity_missing_in_module_detection(self):
        """Tier 1: Attribute present in master registry but missing in module file."""
        self._create_mock_parity_environment()
        # Add extra attribute to master file only
        with open(self.master_csv, "a", encoding="utf-8", newline="") as f:
            writer = csv.writer(f)
            writer.writerow([
                "Fact Test", "fct_test", "Master Only Col", "master_only_col",
                "true", "Domain", "int", "", "Master only", "direct",
                "direct", "Atomic", "atomic_t1", "Val3", "val3"
            ])

        cmd = [
            sys.executable,
            str(PARITY_CHECKER_CLI),
            "-m", "TESTMOD",
            "--root", str(self.mock_root),
            "--json",
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        data = json.loads(result.stdout)
        missing_in_mod = data.get("missing_in_module", [])
        found = any("master_only_col" in str(item) for item in missing_in_mod)
        self.assertTrue(found, f"Expected master_only_col in missing_in_module: {missing_in_mod}")

    @unittest.skipUnless(HAS_PARITY_CHECKER, "M2 datamart_parity_checker not yet implemented")
    def test_09_parity_content_mismatch_detection(self):
        """Tier 1: Differing etl_logic expression between module and master."""
        self._create_mock_parity_environment(
            master_logic="LEFT JOIN atomic_company ON company_id = id",
            module_logic="JOIN atomic_company ON company_id = id",
        )
        cmd = [
            sys.executable,
            str(PARITY_CHECKER_CLI),
            "-m", "TESTMOD",
            "--root", str(self.mock_root),
            "--json",
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        data = json.loads(result.stdout)
        mismatches = data.get("logic_mismatches", [])
        found = any("test_measure" in str(item) for item in mismatches)
        self.assertTrue(found, f"Expected test_measure in logic_mismatches: {mismatches}")


class TestTier1BackwardCompatibility(unittest.TestCase):
    """Tier 1 tests for existing scripts (Feature 9 Backward Compatibility)."""

    def test_10_date_fk_checker_clean_table_and_whitelist(self):
        """Tier 1: Date FK checker passes clean role-playing FK and ignores cdr_dt_dim."""
        self.assertIsNotNone(DATE_FK_SCRIPT, "datamart_date_fk_checker.py must exist")

        clean_csv = (
            "datamart_entity,datamart_table,datamart_attribute,datamart_column,key\n"
            "Fact Trade,fct_trade,Trade Date Dimension Id,trade_dt_dim_id,FK\n"
            "Fact Snapshot,fct_snapshot_snpst,Snapshot Date Dimension Id,snpst_dt_dim_id,FK\n"
        )
        with tempfile.NamedTemporaryFile("w", encoding="utf-8", suffix=".csv", delete=False) as f:
            f.write(clean_csv)
            f.flush()
            temp_path = f.name

        try:
            cmd = [
                sys.executable,
                str(DATE_FK_SCRIPT),
                "-p", temp_path,
                "--strict",
            ]
            result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
            self.assertEqual(result.returncode, 0, f"Expected 0 for clean Date FKs, got: {result.stdout}")
        finally:
            os.unlink(temp_path)

    def test_11_date_fk_checker_violation_triggers_strict_exit(self):
        """Tier 1: Date FK checker exits with 1 under --strict when cdr_dt_dim_id is used on Fact."""
        self.assertIsNotNone(DATE_FK_SCRIPT)

        bad_csv = (
            "datamart_entity,datamart_table,datamart_attribute,datamart_column,key\n"
            "Fact Trade,fct_trade,Calendar Date Dimension Id,cdr_dt_dim_id,FK\n"
        )
        with tempfile.NamedTemporaryFile("w", encoding="utf-8", suffix=".csv", delete=False) as f:
            f.write(bad_csv)
            f.flush()
            temp_path = f.name

        try:
            cmd = [
                sys.executable,
                str(DATE_FK_SCRIPT),
                "-p", temp_path,
                "--strict",
            ]
            result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
            self.assertEqual(result.returncode, 1, f"Expected exit code 1 under --strict, got: {result.returncode}")
        finally:
            os.unlink(temp_path)

    def test_12_progress_analyzer_help_and_execution(self):
        """Tier 1: Progress Analyzer runs with --help without syntax or runtime error."""
        self.assertIsNotNone(PROGRESS_ANALYZER_SCRIPT, "datamart_progress_analyzer.py must exist")
        cmd = [
            sys.executable,
            str(PROGRESS_ANALYZER_SCRIPT),
            "--help",
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(result.returncode, 0)
        self.assertIn("usage", result.stdout.lower())


class TestTier1DocumentationStandards(unittest.TestCase):
    """Tier 1 tests verifying existence and UTF-8 validity of documentation."""

    def test_13_skill_md_and_references_exist_and_utf8(self):
        """Tier 1: SKILL.md and reference documents exist and are valid UTF-8."""
        skill_md = SKILL_DIR / "SKILL.md"
        self.assertTrue(skill_md.exists(), "SKILL.md must exist in skill directory")

        content = skill_md.read_text(encoding="utf-8-sig")
        self.assertGreater(len(content), 100, "SKILL.md must not be empty")

        ref_dir = SKILL_DIR / "reference"
        self.assertTrue(ref_dir.exists(), "reference/ directory must exist")
        ref_files = list(ref_dir.glob("*.md"))
        self.assertGreaterEqual(len(ref_files), 3, "At least 3 reference documents must exist")
        for rf in ref_files:
            text = rf.read_text(encoding="utf-8-sig")
            self.assertGreater(len(text), 10, f"{rf.name} must contain valid content")


if __name__ == "__main__":
    unittest.main()
