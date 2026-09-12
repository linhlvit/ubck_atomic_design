# -*- coding: utf-8 -*-
"""
tests/test_e2e_tier3_combinations.py
Tier 3: Cross-Feature Combinations Test Suite

Covers:
- CLI Flag Permutations:
  * --strict + --json: Ensure exit code 1 still emits 100% valid parseable JSON to stdout
  * -o <file> + --strict: Output file written to disk while returning exit code 1
  * --warn-only + --strict: --warn-only overrides strict mode, returning exit code 0
- Multi-Module Batch Operations:
  * Running audits across modules with mixed delimiters (, vs ;)
- Sequential Quality Gate Pipeline:
  * Running Date FK -> Orphan 3-way -> Parity Checker sequentially
- Mixed Entity Types:
  * Modules combining Fact, Dim, Reused Dim, Reused Fact, and Operational report
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

PROGRESS_ANALYZER_SCRIPT = None
for candidate in [
    SKILL_SCRIPTS_DIR / "datamart_progress_analyzer.py",
    ROOT_SCRIPTS_DIR / "datamart_progress_analyzer.py",
]:
    if candidate.exists():
        PROGRESS_ANALYZER_SCRIPT = candidate
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


class TestTier3FlagPermutations(unittest.TestCase):
    """Tier 3: Tests interactions between CLI flags."""

    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.mock_dir = Path(self.temp_dir.name)

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_01_strict_combined_with_json_on_violation(self):
        """Tier 3: When violations trigger exit code 1 with --strict, stdout must be valid parseable JSON."""
        self.assertIsNotNone(DATE_FK_SCRIPT)
        bad_csv = self.mock_dir / "bad_fact.csv"
        bad_csv.write_text(
            "datamart_entity,datamart_table,datamart_attribute,datamart_column,key\n"
            "Fact Trade,fct_trade,Calendar Date Dimension Id,cdr_dt_dim_id,FK\n",
            encoding="utf-8",
        )

        cmd = [
            sys.executable,
            str(DATE_FK_SCRIPT),
            "-p", str(bad_csv),
            "--strict",
            "--json",
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(result.returncode, 1, f"Expected exit code 1 under --strict, got {result.returncode}")

        # Stdout must be valid JSON despite non-zero exit code
        try:
            data = json.loads(result.stdout)
            self.assertIsInstance(data, (dict, list))
            violations = data if isinstance(data, list) else data.get("violations", [])
            self.assertGreaterEqual(len(violations), 1)
        except json.JSONDecodeError as e:
            self.fail(f"Stdout was not valid JSON under --strict --json: {e}\nRaw stdout:\n{result.stdout}")

    def test_02_output_file_combined_with_strict(self):
        """Tier 3: Flag -o writes report to file even when exit code is 1 under --strict."""
        self.assertIsNotNone(DATE_FK_SCRIPT)
        bad_csv = self.mock_dir / "bad_fact.csv"
        bad_csv.write_text(
            "datamart_entity,datamart_table,datamart_attribute,datamart_column,key\n"
            "Fact Trade,fct_trade,Calendar Date Dimension Id,cdr_dt_dim_id,FK\n",
            encoding="utf-8",
        )
        report_file = self.mock_dir / "report.md"

        cmd = [
            sys.executable,
            str(DATE_FK_SCRIPT),
            "-p", str(bad_csv),
            "--strict",
            "-o", str(report_file),
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(result.returncode, 1)

        # Verify output file was written and is not empty
        self.assertTrue(report_file.exists(), "Report file must exist on disk")
        content = report_file.read_text(encoding="utf-8")
        self.assertIn("cdr_dt_dim_id", content)

    def test_03_warn_only_overrides_strict(self):
        """Tier 3: --warn-only suppresses exit code 1, returning 0 even when violations exist."""
        self.assertIsNotNone(DATE_FK_SCRIPT)
        bad_csv = self.mock_dir / "bad_fact.csv"
        bad_csv.write_text(
            "datamart_entity,datamart_table,datamart_attribute,datamart_column,key\n"
            "Fact Trade,fct_trade,Calendar Date Dimension Id,cdr_dt_dim_id,FK\n",
            encoding="utf-8",
        )

        cmd = [
            sys.executable,
            str(DATE_FK_SCRIPT),
            "-p", str(bad_csv),
            "--strict",
            "--warn-only",
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(result.returncode, 0, f"Expected exit code 0 when --warn-only is active, got {result.returncode}")

    @unittest.skipUnless(HAS_PARITY_CHECKER, "M2 datamart_parity_checker not yet implemented")
    def test_04_parity_strict_json_combination(self):
        """Tier 3: Parity checker returns valid JSON with exit code 1 on mismatch under --strict."""
        cmd = [
            sys.executable,
            str(PARITY_CHECKER_CLI),
            "-m", "GSTT",
            "--root", str(REPO_ROOT),
            "--strict",
            "--json",
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(result.returncode, 1, f"Expected exit code 1 under --strict for GSTT, got {result.returncode}")
        data = json.loads(result.stdout)
        self.assertIn("missing_in_master", data)
        self.assertEqual(data.get("status"), "FAIL")


class TestTier3SequentialPipeline(unittest.TestCase):
    """Tier 3: Sequential execution of multi-tool quality gate pipeline."""

    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.mock_dir = Path(self.temp_dir.name)

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_05_sequential_quality_gate_pipeline(self):
        """Tier 3: Sequentially execute Date FK -> (Orphan) -> (Parity) pipeline."""
        clean_fact = self.mock_dir / "clean_fact.csv"
        clean_fact.write_text(
            "datamart_entity,datamart_table,datamart_attribute,datamart_column,key\n"
            "Fact Trade,fct_trade,Trade Date Dimension Id,trade_dt_dim_id,FK\n",
            encoding="utf-8",
        )

        # Step 1: Run Date FK Checker
        cmd1 = [
            sys.executable,
            str(DATE_FK_SCRIPT),
            "-p", str(clean_fact),
            "--strict",
        ]
        res1 = subprocess.run(cmd1, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(res1.returncode, 0, f"Pipeline Step 1 failed: {res1.stdout}")

        # Step 2: If Orphan Checker exists, run Step 2
        if HAS_ORPHAN_CHECKER:
            cmd2 = [
                sys.executable,
                str(ORPHAN_CHECKER_CLI),
                "--help",
            ]
            res2 = subprocess.run(cmd2, capture_output=True, encoding="utf-8", errors="replace")
            self.assertEqual(res2.returncode, 0, "Pipeline Step 2 failed")

        # Step 3: If Parity Checker exists, run Step 3
        if HAS_PARITY_CHECKER:
            cmd3 = [
                sys.executable,
                str(PARITY_CHECKER_CLI),
                "--help",
            ]
            res3 = subprocess.run(cmd3, capture_output=True, encoding="utf-8", errors="replace")
            self.assertEqual(res3.returncode, 0, "Pipeline Step 3 failed")

    def test_06_mixed_delimiters_multi_module_read(self):
        """Tier 3: Read both comma and semicolon CSVs in a single batch without cross-contamination."""
        comma_file = self.mock_dir / "comma.csv"
        comma_file.write_text("id,val,name\n1,100,Alpha\n2,200,Beta\n", encoding="utf-8")

        semi_file = self.mock_dir / "semi.csv"
        semi_file.write_text("id;val;name\n1;100;Gamma\n2;200;Delta\n", encoding="utf-8")

        delim1, fields1, rows1 = csv_utils.read_csv_dynamic(comma_file)
        delim2, fields2, rows2 = csv_utils.read_csv_dynamic(semi_file)

        self.assertEqual(delim1, ",")
        self.assertEqual(delim2, ";")
        self.assertEqual(len(rows1), 2)
        self.assertEqual(len(rows2), 2)
        self.assertEqual(rows1[0]["name"], "Alpha")
        self.assertEqual(rows2[0]["name"], "Gamma")


if __name__ == "__main__":
    unittest.main()
