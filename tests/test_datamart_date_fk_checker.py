# -*- coding: utf-8 -*-
"""
tests/test_datamart_date_fk_checker.py
Comprehensive Test Suite for Datamart Date FK Role-Playing Validator

Covers:
- Unit Tests with Mock CSV content (clean fact, violating fact, snapshot fact, cdr_dt_dim whitelist, heuristic suggester).
- Robust CSV parsing (delimiters, BOM, encodings, multi-line cells).
- Integration Tests against actual repository files:
  * GSTT fact tables fail with cdr_dt_dim_id.
  * QLKD fact tables fail with cdr_dt_dim_id.
  * GSDC fct_public_company_listing_info_snpst PASS (0 violations).
  * cdr_dt_dim PASS (0 false positives).
- Subprocess CLI execution tests (--strict, --json, -o, -m, -p, skill duplicate).
"""

from __future__ import annotations

import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

# Ensure scripts directory is in sys.path
REPO_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = REPO_ROOT / "scripts"
SKILL_SCRIPTS_DIR = REPO_ROOT / ".claude" / "skills" / "datamart-review" / "scripts"

if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import datamart_date_fk_checker as checker


class TestDateFKCheckerParser(unittest.TestCase):
    """Test CSV parser robustness: delimiters, BOM, encodings, multi-line cells."""

    def test_01_delimiter_detection_comma_and_semicolon(self):
        comma_csv = (
            "datamart_entity,datamart_table,datamart_attribute,datamart_column,key\n"
            "Fact Trade,fct_trade,Trade Date Dimension Id,trade_dt_dim_id,FK\n"
        )
        semi_csv = (
            "datamart_entity;datamart_table;datamart_attribute;datamart_column;key\n"
            "Fact Trade;fct_trade;Trade Date Dimension Id;trade_dt_dim_id;FK\n"
        )
        self.assertEqual(checker.detect_delimiter(comma_csv), ",")
        self.assertEqual(checker.detect_delimiter(semi_csv), ";")

        v_comma = checker.audit_csv_content(comma_csv, file_name="test_comma.csv")
        v_semi = checker.audit_csv_content(semi_csv, file_name="test_semi.csv")
        self.assertEqual(len(v_comma), 0)
        self.assertEqual(len(v_semi), 0)

    def test_02_bom_and_utf8_sig_handling(self):
        # UTF-8 with BOM
        bom_bytes = "\ufeffdatamart_entity,datamart_table,datamart_attribute,datamart_column,key\nFact Trade,fct_trade,Calendar Date Dimension Id,cdr_dt_dim_id,FK\n".encode("utf-8")
        violations = checker.audit_csv_content(bom_bytes, file_name="test_bom.csv")
        self.assertEqual(len(violations), 1)
        self.assertEqual(violations[0].column_name, "cdr_dt_dim_id")

    def test_03_multiline_sql_cells(self):
        csv_data = (
            'datamart_entity,datamart_table,datamart_attribute,datamart_column,key,etl_logic\n'
            'Fact Trade,fct_trade,Trade Date Dimension Id,trade_dt_dim_id,FK,"SELECT *\nFROM cdr_dt_dim\nWHERE 1=1"\n'
            'Fact Trade,fct_trade,Calendar Date Dimension Id,cdr_dt_dim_id,FK,"LOOKUP cdr_dt_dim\nON cdr_dt = trading_dt"\n'
        )
        violations = checker.audit_csv_content(csv_data, file_name="test_multiline.csv")
        self.assertEqual(len(violations), 1)
        self.assertEqual(violations[0].column_name, "cdr_dt_dim_id")
        self.assertEqual(violations[0].line_number, 3)

    def test_04_dynamic_header_mapping(self):
        # Case variation and column order permutation
        csv_data = (
            "COLUMN_NAME,TABLE_NAME,ATTRIBUTE_NAME,ENTITY_NAME,KEY\n"
            "cdr_dt_dim_id,fct_custom,Calendar Date Dimension Id,Fact Custom,FK\n"
        )
        violations = checker.audit_csv_content(csv_data, file_name="test_permuted.csv")
        self.assertEqual(len(violations), 1)
        self.assertEqual(violations[0].table_name, "fct_custom")
        self.assertEqual(violations[0].column_name, "cdr_dt_dim_id")


class TestDateFKCheckerRules(unittest.TestCase):
    """Unit tests verifying business rules with mock CSV data."""

    def test_05_clean_fact_table_passes(self):
        csv_data = (
            "datamart_entity,datamart_table,datamart_attribute,datamart_column,key,description,etl_logic\n"
            "Fact Trade,fct_trade,Trade Date Dimension Id,trade_dt_dim_id,FK,FK trade date,LOOKUP cdr_dt_dim\n"
            "Fact Trade,fct_trade,Trade Volume,trade_vol,,Trade Volume,direct\n"
        )
        violations = checker.audit_csv_content(csv_data, file_name="mock_fct_trade.csv")
        self.assertEqual(len(violations), 0, "Clean fact table with trade_dt_dim_id must have 0 violations")

    def test_06_fact_with_cdr_dt_dim_id_violation(self):
        csv_data = (
            "datamart_entity,datamart_table,datamart_attribute,datamart_column,key,description,etl_logic\n"
            "Fact Trade,fct_trade,Calendar Date Dimension Id,cdr_dt_dim_id,FK,FK date,LOOKUP cdr_dt_dim\n"
        )
        violations = checker.audit_csv_content(csv_data, file_name="mock_fct_trade.csv")
        self.assertEqual(len(violations), 1)
        self.assertEqual(violations[0].violation_type, checker.ViolationType.RULE_1_FORBIDDEN_CDR_DT)
        self.assertEqual(violations[0].severity, checker.Severity.ERROR)
        self.assertEqual(violations[0].column_name, "cdr_dt_dim_id")
        self.assertEqual(violations[0].issue_code, "L2-DATE-FK-ROLE-PLAYING")

    def test_07_fact_with_calendar_dt_dim_id_violation(self):
        csv_data = (
            "datamart_entity,datamart_table,datamart_attribute,datamart_column,key,description,etl_logic\n"
            "Fact Inspection Activity,fct_inspection_activity,Calendar Date Dimension Id,calendar_dt_dim_id,FK,FK date,LOOKUP cdr_dt_dim\n"
        )
        violations = checker.audit_csv_content(csv_data, file_name="mock_fct_inspection.csv")
        self.assertEqual(len(violations), 1)
        self.assertEqual(violations[0].violation_type, checker.ViolationType.RULE_1_FORBIDDEN_CDR_DT)
        self.assertEqual(violations[0].column_name, "calendar_dt_dim_id")

    def test_08_fact_with_violating_logical_attribute_name(self):
        csv_data = (
            "datamart_entity,datamart_table,datamart_attribute,datamart_column,key,description,etl_logic\n"
            "Fact Trade,fct_trade,Calendar Date Dimension Id,dim_date_fk,FK,FK date,LOOKUP cdr_dt_dim\n"
        )
        violations = checker.audit_csv_content(csv_data, file_name="mock_fct_trade.csv")
        self.assertEqual(len(violations), 1)
        self.assertEqual(violations[0].attribute_name, "Calendar Date Dimension Id")

    def test_09_cdr_dt_dim_table_is_whitelisted_zero_false_positive(self):
        csv_data = (
            "datamart_entity,datamart_table,datamart_attribute,datamart_column,key,description,etl_logic\n"
            "Calendar Date Dimension,cdr_dt_dim,Calendar Date Dimension Id,cdr_dt_dim_id,PK,Driving: cdr_dt,cdr_dt.cdr_dt_id\n"
            "Calendar Date Dimension,cdr_dt_dim,Calendar Date,cdr_dt,NK,NK date,cdr_dt.cdr_dt\n"
        )
        violations = checker.audit_csv_content(csv_data, file_name="DTM_NHNCK_cdr_dt_dim.csv")
        self.assertEqual(len(violations), 0, "cdr_dt_dim Dimension table MUST NEVER be flagged as violation")

    def test_10_generic_dimension_table_ignored(self):
        csv_data = (
            "datamart_entity,datamart_table,datamart_attribute,datamart_column,key,description,etl_logic\n"
            "Securities Company Dimension,securities_company_dim,Company Id,securities_company_dim_id,PK,PK,direct\n"
        )
        violations = checker.audit_csv_content(csv_data, file_name="DTM_QLKD_securities_company_dim.csv")
        self.assertEqual(len(violations), 0, "Dimension tables are excluded from Fact Date FK checks")

    def test_11_snapshot_fact_clean_with_snpst_dt_dim_id(self):
        csv_data = (
            "datamart_entity,datamart_table,datamart_attribute,datamart_column,key,description,etl_logic\n"
            "Fact Listing Snapshot,fct_listing_snpst,Snapshot Date Dimension Id,snpst_dt_dim_id,FK,Snapshot date,LOOKUP cdr_dt_dim\n"
        )
        violations = checker.audit_csv_content(csv_data, file_name="mock_listing_snpst.csv")
        self.assertEqual(len(violations), 0, "Snapshot fact with snpst_dt_dim_id must PASS with 0 violations")

    def test_12_snapshot_fact_with_cdr_dt_dim_id_suggests_snpst(self):
        csv_data = (
            "datamart_entity,datamart_table,datamart_attribute,datamart_column,key,description,etl_logic\n"
            "Fact Portfolio Snapshot,fct_portfolio_snpst,Calendar Date Dimension Id,cdr_dt_dim_id,FK,FK,LOOKUP cdr_dt_dim\n"
        )
        violations = checker.audit_csv_content(csv_data, file_name="mock_portfolio_snpst.csv")
        self.assertEqual(len(violations), 1)
        self.assertEqual(violations[0].violation_type, checker.ViolationType.RULE_2_MISNAMED_SNPST_DT)
        self.assertEqual(violations[0].suggested_column, "snpst_dt_dim_id")
        self.assertEqual(violations[0].suggested_attribute, "Snapshot Date Dimension Id")

    def test_13_snapshot_fact_missing_standard_snpst_key_warning(self):
        csv_data = (
            "datamart_entity,datamart_table,datamart_attribute,datamart_column,key,description,etl_logic\n"
            "Fact Trading Snapshot,fct_trading_snpst,Trade Date Dimension Id,trade_dt_dim_id,FK,Trade date,LOOKUP cdr_dt_dim\n"
        )
        violations = checker.audit_csv_content(csv_data, file_name="mock_trading_snpst.csv")
        self.assertEqual(len(violations), 1)
        self.assertEqual(violations[0].violation_type, checker.ViolationType.RULE_2_MISSING_SNPST_DT)
        self.assertEqual(violations[0].severity, checker.Severity.WARNING)
        self.assertEqual(violations[0].suggested_column, "snpst_dt_dim_id")

    def test_14_context_aware_suggester_heuristics(self):
        cases = [
            # Snapshot fact
            ("fct_account_snpst", "Fact Account Snapshot", "", "", "", "", "snpst_dt_dim_id", "Snapshot Date Dimension Id"),
            # Trading / Intraday fact
            ("fct_market_index_intraday", "Fact Market Index", "cdr_dt_dim_id", "Calendar Date Dimension Id", "LOOKUP cdr_dt_dim ON trade_dt", "trading_dt", "trade_dt_dim_id", "Trade Date Dimension Id"),
            # Decision fact
            ("fct_inspection_team_activity", "Fact Inspection Team Activity", "calendar_dt_dim_id", "Calendar Date Dimension Id", "decision_dt", "Quyết định thanh tra", "decision_dt_dim_id", "Decision Date Dimension Id"),
            # Licensing / Issuance
            ("fct_penalty_decision", "Fact Penalty Decision", "calendar_dt_dim_id", "Calendar Date Dimension Id", "penalty_decision.issued_dt", "ngày ban hành", "decision_dt_dim_id", "Decision Date Dimension Id"),
            ("fct_practitioner_license", "Fact Practitioner License", "calendar_dt_dim_id", "Calendar Date Dimension Id", "issue_dt", "ngày cấp chứng chỉ", "issue_dt_dim_id", "Issue Date Dimension Id"),
            # Submission
            ("fct_report_submission", "Fact Report Submission", "cdr_dt_dim_id", "Calendar Date Dimension Id", "submission_dt", "ngày nộp báo cáo", "submission_dt_dim_id", "Submission Date Dimension Id"),
            # Evaluation
            ("fct_risk_evaluation", "Fact Risk Evaluation", "cdr_dt_dim_id", "Calendar Date Dimension Id", "evaluation_dt", "ngày đánh giá rủi ro", "evaluation_dt_dim_id", "Evaluation Date Dimension Id"),
            # Effective
            ("fct_contract_effective", "Fact Contract", "cdr_dt_dim_id", "Calendar Date Dimension Id", "effective_dt", "ngày có hiệu lực", "effective_dt_dim_id", "Effective Date Dimension Id"),
        ]
        for tbl, ent, col, attr, etl, desc, exp_col, exp_attr in cases:
            with self.subTest(table=tbl):
                s_col, s_attr, _ = checker.suggest_role_playing_date_column(
                    table_name=tbl,
                    entity_name=ent,
                    current_col=col,
                    current_attr=attr,
                    etl_logic=etl,
                    description=desc,
                )
                self.assertEqual(s_col, exp_col)
                self.assertEqual(s_attr, exp_attr)


class TestDateFKCheckerIntegration(unittest.TestCase):
    """Integration tests running against actual repository CSV files."""

    @classmethod
    def setUpClass(cls):
        cls.checker = checker.DatamartDateFKChecker(root_dir=REPO_ROOT)
        cls.lld_dir = REPO_ROOT / "Datamart" / "lld"
        if not cls.lld_dir.exists():
            raise unittest.SkipTest("Datamart/lld directory not found in repository")

    def test_15_real_repo_gstt_violations_detected(self):
        summary = self.checker.scan_module("GSTT")
        violating_tables = {v.table_name for v in summary.all_violations}
        expected_violations = {
            "fct_foreign_trading_min_snpst",
            "fct_market_index_intraday",
            "fct_security_trading_intraday",
            "fct_stock_portfolio_snpst",
        }
        self.assertTrue(expected_violations.issubset(violating_tables), f"Missing expected GSTT violations: {expected_violations - violating_tables}")
        self.assertEqual(len(summary.all_violations), 4)

        for v in summary.all_violations:
            self.assertEqual(v.column_name, "cdr_dt_dim_id")
            self.assertEqual(v.attribute_name, "Calendar Date Dimension Id")
            self.assertEqual(v.severity, checker.Severity.ERROR)
            self.assertIn(v.suggested_column, ("snpst_dt_dim_id", "trade_dt_dim_id"))

    def test_16_real_repo_qlkd_violations_detected(self):
        summary = self.checker.scan_module("QLKD")
        violating_tables = {v.table_name for v in summary.all_violations}
        expected_violations = {
            "fct_securities_company_compliance_report_snpst",
            "fct_securities_company_financial_snpst",
        }
        self.assertTrue(expected_violations.issubset(violating_tables), f"Missing expected QLKD violations: {expected_violations - violating_tables}")
        self.assertEqual(len(summary.all_violations), 2)

        for v in summary.all_violations:
            self.assertEqual(v.column_name, "cdr_dt_dim_id")
            self.assertEqual(v.suggested_column, "snpst_dt_dim_id")
            self.assertEqual(v.suggested_attribute, "Snapshot Date Dimension Id")

    def test_17_real_repo_tt_violations_detected(self):
        summary = self.checker.scan_module("TT")
        self.assertEqual(len(summary.all_violations), 11)
        for v in summary.all_violations:
            self.assertEqual(v.column_name, "calendar_dt_dim_id")
            self.assertEqual(v.suggested_column, "decision_dt_dim_id")
            self.assertEqual(v.suggested_attribute, "Decision Date Dimension Id")

    def test_18_real_repo_gsdc_listing_info_snpst_passes(self):
        file_path = self.lld_dir / "GSDC" / "DTM_GSDC_fct_public_company_listing_info_snpst.csv"
        violations = checker.audit_file(file_path)
        self.assertEqual(
            len(violations), 0,
            "fct_public_company_listing_info_snpst was standardized to snpst_dt_dim_id; must PASS with 0 violations"
        )

    def test_19_real_repo_cdr_dt_dim_passes_zero_false_positives(self):
        file_path = self.lld_dir / "Common" / "DTM_NHNCK_cdr_dt_dim.csv"
        violations = checker.audit_file(file_path)
        self.assertEqual(
            len(violations), 0,
            "cdr_dt_dim is the Calendar Date Dimension itself; must PASS with 0 false positives"
        )

    def test_20_real_repo_master_datamart_attributes_consistency(self):
        master_file = self.lld_dir / "datamart_attributes.csv"
        self.assertTrue(master_file.exists())
        violations = checker.audit_file(master_file)
        self.assertGreater(len(violations), 0, "Master datamart_attributes.csv must detect violating fact entries")
        violating_cols = {v.column_name for v in violations}
        self.assertTrue({"cdr_dt_dim_id", "calendar_dt_dim_id"}.issubset(violating_cols))


class TestDateFKCheckerCLI(unittest.TestCase):
    """Subprocess tests verifying CLI execution, exit codes, and output formatting."""

    def test_21_cli_strict_exit_code_1_on_violations(self):
        cmd = [sys.executable, str(SCRIPTS_DIR / "datamart_date_fk_checker.py"), "-m", "GSTT", "--strict"]
        proc = subprocess.run(cmd, capture_output=True, text=True, cwd=str(REPO_ROOT))
        self.assertEqual(proc.returncode, 1, "GSTT audit in strict mode must return exit code 1")
        self.assertIn("fct_stock_portfolio_snpst", proc.stdout)
        self.assertIn("cdr_dt_dim_id", proc.stdout)

    def test_22_cli_without_strict_exit_code_0(self):
        cmd = [sys.executable, str(SCRIPTS_DIR / "datamart_date_fk_checker.py"), "-m", "GSTT"]
        proc = subprocess.run(cmd, capture_output=True, text=True, cwd=str(REPO_ROOT))
        self.assertEqual(proc.returncode, 0, "Audit without --strict must return exit code 0")
        self.assertIn("fct_stock_portfolio_snpst", proc.stdout)

    def test_23_cli_strict_exit_code_0_on_clean_target(self):
        target_path = "Datamart/lld/GSDC/DTM_GSDC_fct_public_company_listing_info_snpst.csv"
        cmd = [sys.executable, str(SCRIPTS_DIR / "datamart_date_fk_checker.py"), "-p", target_path, "--strict"]
        proc = subprocess.run(cmd, capture_output=True, text=True, cwd=str(REPO_ROOT))
        self.assertEqual(proc.returncode, 0, "Clean benchmark in strict mode must return exit code 0")
        self.assertIn("ALL CLEAN", proc.stdout)

    def test_24_cli_strict_exit_code_0_on_cdr_dt_dim(self):
        target_path = "Datamart/lld/Common/DTM_NHNCK_cdr_dt_dim.csv"
        cmd = [sys.executable, str(SCRIPTS_DIR / "datamart_date_fk_checker.py"), "-p", target_path, "--strict"]
        proc = subprocess.run(cmd, capture_output=True, text=True, cwd=str(REPO_ROOT))
        self.assertEqual(proc.returncode, 0, "cdr_dt_dim in strict mode must return exit code 0")
        self.assertIn("ALL CLEAN", proc.stdout)

    def test_25_cli_warn_only_flag_overrides_strict(self):
        cmd = [sys.executable, str(SCRIPTS_DIR / "datamart_date_fk_checker.py"), "-m", "GSTT", "--strict", "--warn-only"]
        proc = subprocess.run(cmd, capture_output=True, text=True, cwd=str(REPO_ROOT))
        self.assertEqual(proc.returncode, 0, "--warn-only must override --strict and return exit code 0")

    def test_26_cli_json_output_format(self):
        cmd = [sys.executable, str(SCRIPTS_DIR / "datamart_date_fk_checker.py"), "-m", "GSTT", "--json"]
        proc = subprocess.run(cmd, capture_output=True, text=True, cwd=str(REPO_ROOT))
        self.assertEqual(proc.returncode, 0)
        data = json.loads(proc.stdout)
        self.assertIn("summary", data)
        self.assertIn("violations", data)
        self.assertEqual(data["summary"]["total_violations"], 4)
        self.assertEqual(data["summary"]["status"], "FAILED")

    def test_27_cli_markdown_file_export(self):
        with tempfile.NamedTemporaryFile(suffix=".md", delete=False) as tf:
            temp_path = tf.name

        try:
            cmd = [sys.executable, str(SCRIPTS_DIR / "datamart_date_fk_checker.py"), "-m", "GSTT", "-o", temp_path]
            proc = subprocess.run(cmd, capture_output=True, text=True, cwd=str(REPO_ROOT))
            self.assertEqual(proc.returncode, 0)
            self.assertTrue(os.path.exists(temp_path))
            content = Path(temp_path).read_text(encoding="utf-8")
            self.assertIn("# Datamart Role-Playing Date FK Validation Report", content)
            self.assertIn("fct_stock_portfolio_snpst", content)
            self.assertIn("snpst_dt_dim_id", content)
        finally:
            if os.path.exists(temp_path):
                os.remove(temp_path)

    def test_28_skill_script_duplicate_is_synchronized_and_runnable(self):
        root_script = SCRIPTS_DIR / "datamart_date_fk_checker.py"
        skill_script = SKILL_SCRIPTS_DIR / "datamart_date_fk_checker.py"

        self.assertTrue(root_script.is_file(), "scripts/datamart_date_fk_checker.py must exist")
        self.assertTrue(skill_script.is_file(), ".claude/skills/datamart-review/scripts/datamart_date_fk_checker.py must exist")

        self.assertEqual(
            root_script.read_bytes(),
            skill_script.read_bytes(),
            "Skill script must be an exact duplicate of the root script",
        )

        # Run skill copy via CLI
        cmd = [sys.executable, str(skill_script), "-m", "GSTT", "--strict"]
        proc = subprocess.run(cmd, capture_output=True, text=True, cwd=str(REPO_ROOT))
        self.assertEqual(proc.returncode, 1)
        self.assertIn("fct_stock_portfolio_snpst", proc.stdout)


if __name__ == "__main__":
    unittest.main()
