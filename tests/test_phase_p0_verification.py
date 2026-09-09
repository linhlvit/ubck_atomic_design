# -*- coding: utf-8 -*-
"""
tests/test_phase_p0_verification.py — Comprehensive Verification Suite for Phase P0 Fixes
Covers:
- PA-01: Semicolon BA CSV with SQL cell containing 35+ unquoted commas
- PA-03: HLD Markdown table where KPI formula contains pipe '|' or logic OR '||'
- DFK-01: Low-level design CSV with comma-bearing comment in line 1 and semicolon data
- DFK-02: Module filter isolation on master datamart_attributes.csv
- DFK-03: Periodic snapshot table completely missing date FK columns (Severity.ERROR)
- SKILL.md: Verification of conflict resolutions (Items 4 & 5)
"""
from __future__ import annotations

import sys
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = REPO_ROOT / "scripts"
SKILL_DIR = REPO_ROOT / ".claude" / "skills" / "datamart-review"
SKILL_SCRIPTS_DIR = SKILL_DIR / "scripts"

if str(SKILL_SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SKILL_SCRIPTS_DIR))

import datamart_date_fk_checker as date_checker
import datamart_progress_analyzer as progress_analyzer


class TestPhaseP0Bugs(unittest.TestCase):
    """Verifies all Phase P0 bug fixes with edge-case scenarios."""

    def test_pa_01_delimiter_mode_consistency_with_comma_heavy_sql(self):
        """PA-01: Semicolon BA file with 26 columns where one row has 35 unquoted commas in SQL."""
        # 10 rows of 26 semicolon-separated columns
        header = ";".join([f"Col_{i}" for i in range(26)])
        normal_row = ";".join([f"Val_{i}" for i in range(26)])
        
        # Row 3 contains SQL with 35 commas
        sql_with_commas = "SELECT col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12, col13, col14, col15, col16, col17, col18, col19, col20, col21, col22, col23, col24, col25, col26, col27, col28, col29, col30, col31, col32, col33, col34, col35 FROM tbl"
        broken_row_cells = [f"Val_{i}" for i in range(26)]
        broken_row_cells[4] = sql_with_commas
        broken_row = ";".join(broken_row_cells)

        csv_content = "\n".join([header, normal_row, broken_row] + [normal_row] * 8)

        # Test skill copy
        delim_skill, _, _, _ = progress_analyzer.BAParser.detect_delimiter_and_header(csv_content)
        self.assertEqual(delim_skill, ";", "PA-01: Semicolon delimiter must be correctly identified despite SQL commas")

    def test_pa_03_markdown_table_pipe_in_formula(self):
        """PA-03: Formula containing pipe '|' or '||' must not break status extraction."""
        hld_content = """
### Nhóm 1 - Giám sát giao dịch
| KPI_ID | Tên chỉ tiêu | ĐVT | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_TEST_01 | Chỉ tiêu bình thường | % | Cơ sở | a + b | ghi chú bình thường | READY |
| K_TEST_02 | Tỷ lệ cảnh báo pipe | % | Phái sinh | CASE WHEN a || b | c THEN 1 ELSE 0 END | Điều kiện đặc biệt | PENDING |
| K_TEST_03 | Chỉ tiêu không ghi chú | VNĐ | Cơ sở | x * y | | READY |
"""
        items = progress_analyzer.HLDParser.parse_text(hld_content, module="TEST")
        self.assertEqual(len(items), 3)

        k_02 = next((it for it in items if it.kpi_id == "K_TEST_02"), None)
        self.assertIsNotNone(k_02)
        self.assertEqual(k_02.status, "PENDING", "PA-03: Status must be extracted from the end as PENDING")
        self.assertEqual(k_02.note, "Điều kiện đặc biệt")
        self.assertIn("CASE WHEN", k_02.formula)

    def test_dfk_01_delimiter_mode_consistency_with_comment_line(self):
        """DFK-01: Line 1 comment with comma, data lines 15 columns with semicolon."""
        csv_content = (
            "# Datamart Attributes Definition, Module GSTT\n"
            + "\n".join([";".join([f"Col_{i}" for i in range(15)]) for _ in range(10)])
        )
        delim = date_checker.detect_delimiter(csv_content)
        self.assertEqual(delim, ";", "DFK-01: Semicolon delimiter must be detected even when line 1 comment has commas")

    def test_dfk_02_module_isolation_in_master_attributes(self):
        """DFK-02: Reading master datamart_attributes.csv with module_filter must isolate module tables."""
        # Mock master attributes CSV containing tables from multiple modules
        master_csv = (
            "datamart_entity,datamart_table,datamart_attribute,datamart_column,key\n"
            "Fact GSTT,fct_gstt_trade_snpst,Snapshot Date Dimension Id,snpst_dt_dim_id,FK\n"
            "Fact QLKD,fct_qlkd_company_snpst,Calendar Date Dimension Id,cdr_dt_dim_id,FK\n"
            "Fact TT,fct_tt_inspection,Calendar Date Dimension Id,calendar_dt_dim_id,FK\n"
        )
        # Audit directory with mock file named datamart_attributes.csv
        import tempfile
        with tempfile.TemporaryDirectory() as td:
            temp_master = Path(td) / "datamart_attributes.csv"
            temp_master.write_text(master_csv, encoding="utf-8")

            summary = date_checker.audit_directory(temp_master, module_filter="GSTT")
            # Only fct_gstt_trade_snpst should be scanned, not QLKD or TT
            self.assertEqual(summary.scanned_tables_count, 1, "DFK-02: Only GSTT table should be scanned from master file")
            self.assertEqual(summary.total_violations_count, 0, "GSTT table is clean with snpst_dt_dim_id")

    def test_dfk_03_snapshot_fact_completely_missing_date_fk(self):
        """DFK-03: Snapshot fact table with no date FK must trigger RULE_2_MISSING_SNPST_DT with Severity.ERROR."""
        csv_content = (
            "datamart_entity,datamart_table,datamart_attribute,datamart_column,key,description,etl_logic\n"
            "Fact Company Snapshot,fct_public_company_financial_snpst,Company Id,company_dim_id,FK,Company ID,direct\n"
            "Fact Company Snapshot,fct_public_company_financial_snpst,Revenue,revenue,,Total Revenue,direct\n"
        )
        violations = date_checker.audit_csv_content(csv_content, file_name="mock_snpst_no_date.csv")
        self.assertEqual(len(violations), 1, "DFK-03: Snapshot fact missing date FK must trigger exactly 1 violation")
        self.assertEqual(violations[0].violation_type, date_checker.ViolationType.RULE_2_MISSING_SNPST_DT)
        self.assertEqual(violations[0].severity, date_checker.Severity.ERROR, "DFK-03: Missing date FK must be ERROR (blocker)")
        self.assertEqual(violations[0].column_name, "(missing)")
        self.assertEqual(violations[0].suggested_column, "snpst_dt_dim_id")

    def test_skill_md_conflict_fixes(self):
        """Item 4 & 5: Verify SKILL.md resolutions for Conflicts 1, 2, and 5."""
        skill_file = SKILL_DIR / "SKILL.md"
        content = skill_file.read_text(encoding="utf-8")

        # Conflict 1: No hardcoded delimiter=';' in Step 1
        self.assertNotIn("reader = csv.reader(f, delimiter=';')", content)
        self.assertIn("TUYỆT ĐỐI KHÔNG gán cứng delimiter=';' hay delimiter=','", content)

        # Conflict 2: Uniform Row 1 header
        self.assertNotIn("dòng 0 với GSDC", content)
        self.assertIn("dòng 1 với TOÀN BỘ 11 file hiện hành", content)

        # Conflict 5: Lock direct Edit at Layer 4
        self.assertNotIn("Bước D: Sửa registry theo Attributes", content)
        self.assertIn("Reviewer TUYỆT ĐỐI KHÔNG tự sửa file registry", content)
        self.assertIn("Sau khi datamart-lld-design hoàn tất cập nhật registry", content)


if __name__ == "__main__":
    unittest.main()
