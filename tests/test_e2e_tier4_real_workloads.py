# -*- coding: utf-8 -*-
"""
tests/test_e2e_tier4_real_workloads.py
Tier 4: Real-World Workloads & Empirical Repository Baselines

Validates against actual repository artifacts across Datamart/hld/, Datamart/lld/,
Datamart/flat-table/, and Datamart/lld/datamart_attributes.csv:

1. TKNB (Thống kê Nội bộ) - Benchmark Gold Standard (Negative Control):
   - 22 HLD operational entities map 1:1:1 to 22 LLD CSVs and 22 ClickHouse flat tables.
   - 159 total attributes in module files match 159 attributes in datamart_attributes.csv.
   - 0 orphan entities, 0 missing attributes in master, 0 etl_logic diffs, 0 Date FK violations.

2. GSTT (Giám sát Thị trường) - Positive Control for Branch B Orphan & Master Desync:
   - Branch B Orphan: 'Fact Public Company Shareholding' and 'Legal Entity Dimension'
     exist in DTM_GSTT_Entities.csv but were deprecated on 2026-08-03 (01_create_gstt_flat_tables.sql
     lines 266-274) and are omitted from LLD and Flat Table SQL.
   - Master Registry Desync: 'fct_stock_portfolio_snpst.free_float_share_quantity' added
     2026-09-07 in module file & flat table SQL, but missing in datamart_attributes.csv
     (102 rows in module vs 101 rows in master).
   - Date FK Violations: Generic cdr_dt_dim_id on Fact tables.

3. QLCB (Quản lý Chào bán) - Positive Control for Suffix Normalization & ETL Logic Divergence:
   - Entity Normalization: HLD Entities.csv omits 'Snapshot' suffix for 3 fact tables,
     whereas LLD and Flat Table use '_snpst' / 'Snapshot'.
   - ETL Logic Divergence: opr_securities_offering_360_profile.classification_business_line_nm
     uses 'JOIN public_company' in module CSV vs 'LEFT JOIN public_company' in master registry.
   - Date FK: 0 violations.
"""

from __future__ import annotations

import csv
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import unittest

# Ensure paths
REPO_ROOT = Path(__file__).resolve().parents[1]
SKILL_SCRIPTS_DIR = REPO_ROOT / ".claude" / "skills" / "datamart-review" / "scripts"
ROOT_SCRIPTS_DIR = REPO_ROOT / "scripts"

for p in [str(SKILL_SCRIPTS_DIR), str(ROOT_SCRIPTS_DIR)]:
    if p not in sys.path:
        sys.path.insert(0, p)

from datamart_common import csv_utils, encoding, module_resolver

# Tool paths
DATE_FK_SCRIPT = None
for candidate in [
    SKILL_SCRIPTS_DIR / "datamart_date_fk_checker.py",
    ROOT_SCRIPTS_DIR / "datamart_date_fk_checker.py",
]:
    if candidate.exists():
        DATE_FK_SCRIPT = candidate
        break

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


class TestTier4TKNBBenchmark(unittest.TestCase):
    """Tier 4: TKNB serves as the 100% clean negative control benchmark."""

    def setUp(self):
        self.hld_csv = REPO_ROOT / "Datamart" / "hld" / "DTM_TKNB_Entities.csv"
        self.lld_dir = REPO_ROOT / "Datamart" / "lld" / "TKNB"
        self.flat_sql = REPO_ROOT / "Datamart" / "flat-table" / "TKNB" / "01_create_tknb_flat_tables.sql"
        self.master_csv = REPO_ROOT / "Datamart" / "lld" / "datamart_attributes.csv"

    def test_01_tknb_ground_truth_3way_alignment(self):
        """Tier 4 Ground Truth: TKNB has exactly 22 HLD entities, 22 LLD CSVs, 22 Flat Tables."""
        self.assertTrue(self.hld_csv.exists(), "DTM_TKNB_Entities.csv must exist")
        self.assertTrue(self.lld_dir.exists(), "Datamart/lld/TKNB/ must exist")
        self.assertTrue(self.flat_sql.exists(), "01_create_tknb_flat_tables.sql must exist")

        # 1. HLD Entities
        _, _, hld_rows = csv_utils.read_csv_dynamic(self.hld_csv)
        self.assertEqual(len(hld_rows), 22, f"TKNB HLD must have exactly 22 entities, got {len(hld_rows)}")

        # 2. LLD CSV files
        lld_files = list(self.lld_dir.glob("*.csv"))
        self.assertEqual(len(lld_files), 22, f"TKNB LLD must have exactly 22 CSV files, got {len(lld_files)}")

        # 3. Flat Table DDL
        sql_text = encoding.read_file_safe(self.flat_sql)
        created_tables = re.findall(r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(?:datamart\.)?([a-zA-Z0-9_]+)", sql_text, re.IGNORECASE)
        self.assertEqual(len(created_tables), 22, f"TKNB SQL must create exactly 22 flat tables, got {len(created_tables)}")

    def test_02_tknb_ground_truth_master_registry_parity(self):
        """Tier 4 Ground Truth: TKNB has 159 attributes in module files, perfectly matching master registry."""
        self.assertTrue(self.master_csv.exists())

        # Count module attributes
        total_mod_attrs = 0
        mod_col_keys = set()
        for f in self.lld_dir.glob("*.csv"):
            _, _, rows = csv_utils.read_csv_dynamic(f)
            total_mod_attrs += len(rows)
            for r in rows:
                mod_col_keys.add((r.get("datamart_table"), r.get("datamart_column")))

        self.assertEqual(total_mod_attrs, 159, f"TKNB module files must have 159 attributes, got {total_mod_attrs}")

        # Count master attributes for TKNB tables
        _, _, master_rows = csv_utils.read_csv_dynamic(self.master_csv)
        tknb_tables = {k[0] for k in mod_col_keys}
        master_tknb_cols = {
            (r.get("datamart_table"), r.get("datamart_column"))
            for r in master_rows
            if r.get("datamart_table") in tknb_tables
        }

        self.assertEqual(len(master_tknb_cols), 159, f"TKNB in master registry must have 159 attributes, got {len(master_tknb_cols)}")
        self.assertEqual(mod_col_keys, master_tknb_cols, "TKNB module attributes and master attributes must be identical")

    def test_03_tknb_date_fk_checker_clean(self):
        """Tier 4: Date FK Checker produces 0 violations on TKNB."""
        self.assertIsNotNone(DATE_FK_SCRIPT)
        cmd = [
            sys.executable,
            str(DATE_FK_SCRIPT),
            "-m", "TKNB",
            "--root", str(REPO_ROOT),
            "--strict",
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(result.returncode, 0, f"TKNB Date FK check must pass with code 0: {result.stdout}")

    @unittest.skipUnless(HAS_ORPHAN_CHECKER, "M2 datamart_orphan_checker not yet implemented")
    def test_04_tknb_orphan_checker_clean(self):
        """Tier 4: 3-Way Orphan Checker produces status PASS on TKNB."""
        cmd = [
            sys.executable,
            str(ORPHAN_CHECKER_CLI),
            "-m", "TKNB",
            "--root", str(REPO_ROOT),
            "--strict",
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(result.returncode, 0, f"TKNB orphan check must pass with code 0: {result.stdout}")

    @unittest.skipUnless(HAS_PARITY_CHECKER, "M2 datamart_parity_checker not yet implemented")
    def test_05_tknb_parity_checker_clean(self):
        """Tier 4: Parity Checker produces status PASS on TKNB."""
        cmd = [
            sys.executable,
            str(PARITY_CHECKER_CLI),
            "-m", "TKNB",
            "--root", str(REPO_ROOT),
            "--strict",
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(result.returncode, 0, f"TKNB parity check must pass with code 0: {result.stdout}")


class TestTier4GSTTPositiveControl(unittest.TestCase):
    """Tier 4: GSTT serves as the positive control for Branch B orphans & master registry desync."""

    def setUp(self):
        self.hld_csv = REPO_ROOT / "Datamart" / "hld" / "DTM_GSTT_Entities.csv"
        self.lld_dir = REPO_ROOT / "Datamart" / "lld" / "GSTT"
        self.flat_sql = REPO_ROOT / "Datamart" / "flat-table" / "GSTT" / "01_create_gstt_flat_tables.sql"
        self.master_csv = REPO_ROOT / "Datamart" / "lld" / "datamart_attributes.csv"

    def test_06_gstt_ground_truth_branch_b_orphans(self):
        """Tier 4 Ground Truth: DTM_GSTT_Entities.csv retains deprecated entities omitted from LLD & Flat Table."""
        self.assertTrue(self.hld_csv.exists())
        _, _, hld_rows = csv_utils.read_csv_dynamic(self.hld_csv)
        entity_names = {r.get("datamart_entity") for r in hld_rows}

        # 'Fact Public Company Shareholding' is present in HLD Entities.csv
        self.assertIn("Fact Public Company Shareholding", entity_names)
        self.assertIn("Legal Entity Dimension", entity_names)

        # Neither entity has a corresponding LLD CSV in Datamart/lld/GSTT/
        lld_files = [f.name.lower() for f in self.lld_dir.glob("*.csv")]
        shareholding_lld = [f for f in lld_files if "shareholding" in f]
        self.assertEqual(len(shareholding_lld), 0, "Fact Public Company Shareholding must not exist in LLD")

        # Flat Table SQL explicitly records deprecation of these entities
        sql_text = encoding.read_file_safe(self.flat_sql)
        self.assertIn("Fact Public Company Shareholding", sql_text)
        self.assertIn("loại khỏi HLD", sql_text)

    def test_07_gstt_ground_truth_master_registry_desync(self):
        """Tier 4 Ground Truth: free_float_share_quantity is present in GSTT LLD file but MISSING in master registry."""
        portfolio_lld = self.lld_dir / "DTM_GSTT_fct_stock_portfolio_snpst.csv"
        self.assertTrue(portfolio_lld.exists())

        _, _, lld_rows = csv_utils.read_csv_dynamic(portfolio_lld)
        lld_cols = {r.get("datamart_column") for r in lld_rows}
        self.assertIn("free_float_share_quantity", lld_cols, "free_float_share_quantity must exist in module file")

        # Check master registry
        _, _, master_rows = csv_utils.read_csv_dynamic(self.master_csv)
        master_gstt_portfolio_cols = {
            r.get("datamart_column")
            for r in master_rows
            if r.get("datamart_table") == "fct_stock_portfolio_snpst"
        }
        self.assertNotIn(
            "free_float_share_quantity",
            master_gstt_portfolio_cols,
            "free_float_share_quantity must be MISSING in datamart_attributes.csv (desync positive control)",
        )

    def test_08_gstt_date_fk_violations_detected(self):
        """Tier 4: Date FK Checker detects cdr_dt_dim_id violations on GSTT Fact tables."""
        self.assertIsNotNone(DATE_FK_SCRIPT)
        cmd = [
            sys.executable,
            str(DATE_FK_SCRIPT),
            "-m", "GSTT",
            "--root", str(REPO_ROOT),
            "--strict",
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        # Must return exit code 1 due to cdr_dt_dim_id on Fact tables
        self.assertEqual(result.returncode, 1, "GSTT must trigger Date FK violations under --strict")
        self.assertIn("cdr_dt_dim_id", result.stdout)

    @unittest.skipUnless(HAS_ORPHAN_CHECKER, "M2 datamart_orphan_checker not yet implemented")
    def test_09_gstt_orphan_checker_flags_branch_b(self):
        """Tier 4: 3-Way Orphan Checker detects Branch B orphan entities in GSTT."""
        cmd = [
            sys.executable,
            str(ORPHAN_CHECKER_CLI),
            "-m", "GSTT",
            "--root", str(REPO_ROOT),
            "--json",
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        data = json.loads(result.stdout)
        branch_b = data.get("branch_b_orphans", [])
        found = any("Shareholding" in str(item) for item in branch_b)
        self.assertTrue(found, f"Expected Fact Public Company Shareholding in Branch B: {branch_b}")

    @unittest.skipUnless(HAS_PARITY_CHECKER, "M2 datamart_parity_checker not yet implemented")
    def test_10_gstt_parity_checker_flags_missing_master(self):
        """Tier 4: Parity Checker detects free_float_share_quantity missing in master registry."""
        cmd = [
            sys.executable,
            str(PARITY_CHECKER_CLI),
            "-m", "GSTT",
            "--root", str(REPO_ROOT),
            "--json",
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        data = json.loads(result.stdout)
        missing_in_master = data.get("missing_in_master", [])
        found = any("free_float_share_quantity" in str(item) for item in missing_in_master)
        self.assertTrue(found, f"Expected free_float_share_quantity in missing_in_master: {missing_in_master}")


class TestTier4QLCBPositiveControl(unittest.TestCase):
    """Tier 4: QLCB serves as positive control for entity suffix normalization and etl_logic diff."""

    def setUp(self):
        self.hld_csv = REPO_ROOT / "Datamart" / "hld" / "DTM_QLCB_Entities.csv"
        self.lld_dir = REPO_ROOT / "Datamart" / "lld" / "QLCB"
        self.master_csv = REPO_ROOT / "Datamart" / "lld" / "datamart_attributes.csv"

    def test_11_qlcb_ground_truth_entity_naming_suffix(self):
        """Tier 4 Ground Truth: DTM_QLCB_Entities.csv lacks 'Snapshot' for 3 fact tables."""
        self.assertTrue(self.hld_csv.exists())
        _, _, hld_rows = csv_utils.read_csv_dynamic(self.hld_csv)
        entity_names = {r.get("datamart_entity") for r in hld_rows}

        self.assertIn("Fact Securities Offering", entity_names)
        self.assertIn("Fact Securities Offering Plan", entity_names)
        self.assertIn("Fact Securities Offering Result", entity_names)

        # But in LLD files, physical names use '_snpst'
        lld_files = [f.name for f in self.lld_dir.glob("*.csv")]
        self.assertTrue(any("fct_securities_offering_snpst" in f for f in lld_files))
        self.assertTrue(any("fct_securities_offering_plan_snpst" in f for f in lld_files))
        self.assertTrue(any("fct_securities_offering_result_snpst" in f for f in lld_files))

    def test_12_qlcb_ground_truth_etl_logic_divergence(self):
        """Tier 4 Ground Truth: classification_business_line_nm has 'JOIN' in module vs 'LEFT JOIN' in master."""
        profile_lld = self.lld_dir / "DTM_QLCB_opr_securities_offering_360_profile_IDS_SECURITIES_OFFERING.csv"
        self.assertTrue(profile_lld.exists())

        _, _, lld_rows = csv_utils.read_csv_dynamic(profile_lld)
        mod_logic = None
        for r in lld_rows:
            if r.get("datamart_column") == "classification_business_line_nm":
                mod_logic = r.get("etl_logic")
                break
        self.assertIsNotNone(mod_logic)
        self.assertTrue(mod_logic.startswith("JOIN public_company"))

        # In master registry
        _, _, master_rows = csv_utils.read_csv_dynamic(self.master_csv)
        master_logic = None
        for r in master_rows:
            if (
                r.get("datamart_table") == "opr_securities_offering_360_profile"
                and r.get("datamart_column") == "classification_business_line_nm"
            ):
                master_logic = r.get("etl_logic")
                break
        self.assertIsNotNone(master_logic)
        self.assertTrue(master_logic.startswith("LEFT JOIN public_company"))

    def test_13_qlcb_date_fk_checker_clean(self):
        """Tier 4: Date FK Checker produces 0 violations on QLCB."""
        self.assertIsNotNone(DATE_FK_SCRIPT)
        cmd = [
            sys.executable,
            str(DATE_FK_SCRIPT),
            "-m", "QLCB",
            "--root", str(REPO_ROOT),
            "--strict",
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(result.returncode, 0, f"QLCB Date FK check must pass with code 0: {result.stdout}")

    @unittest.skipUnless(HAS_PARITY_CHECKER, "M2 datamart_parity_checker not yet implemented")
    def test_14_qlcb_parity_checker_flags_logic_divergence(self):
        """Tier 4: Parity Checker detects JOIN vs LEFT JOIN divergence on QLCB."""
        cmd = [
            sys.executable,
            str(PARITY_CHECKER_CLI),
            "-m", "QLCB",
            "--root", str(REPO_ROOT),
            "--json",
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        data = json.loads(result.stdout)
        mismatches = data.get("logic_mismatches", [])
        found = any("classification_business_line_nm" in str(item) for item in mismatches)
        self.assertTrue(found, f"Expected classification_business_line_nm in mismatches: {mismatches}")


if __name__ == "__main__":
    unittest.main()
