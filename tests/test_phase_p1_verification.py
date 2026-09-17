# -*- coding: utf-8 -*-
"""
tests/test_phase_p1_verification.py — Comprehensive Verification Suite for Phase P1 Fixes
Covers:
- Item 6 (PA-04): Regex for HLD Group headers supporting multi-level BRD prefixes (3.2.2.x), dots, and varied separators
- Item 6 (PA-07): Empty/blank/None/whitespace BA status classified as Branch 1 (BA Pending)
- Item 7 (PA-05): Branch 6 decoupled from has_count_mismatch flag so Branch 5 is not swallowed
- Item 8: Mandatory Delete / DELETED / Xóa handling across BAParser, analyzer cross-status matrix, and violation detection
- Item 9 & Documentation: SCD4A (ds_rcrd_st = 'ACTIVE'), SHARED Dimension protection, and Delete rules in SKILL.md and issue_classification.md
"""
from __future__ import annotations

import io
import sys
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = REPO_ROOT / "scripts"
SKILL_DIR = REPO_ROOT / ".claude" / "skills" / "datamart-review"
SKILL_SCRIPTS_DIR = SKILL_DIR / "scripts"

if str(SKILL_SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SKILL_SCRIPTS_DIR))

import datamart_progress_analyzer as pa_skill
sys.path.insert(0, str(SCRIPTS_DIR))
import datamart_progress_analyzer as pa_root


class TestPhaseP1Verification(unittest.TestCase):
    """Unit tests verifying Phase P1 implementation requirements."""

    def test_pa_04_hld_group_header_regex_multi_level_numbering_and_dots(self):
        """PA-04: Group header regex must support multi-level numbering (3.2.2.x), dots, and various separators."""
        test_headers = [
            ("### Nhóm 1 - Giám sát giao dịch nội bộ", 1, "Giám sát giao dịch nội bộ"),
            ("### 3.2.2.1 Nhóm 2 - Quản lý tài khoản", 2, "Quản lý tài khoản"),
            ("### Nhóm 3. Thống kê thị trường", 3, "Thống kê thị trường"),
            ("### Nhóm 4", 4, "Nhóm 4"),
            ("### 3.2.2.5. Nhóm 5: Báo cáo tài chính", 5, "Báo cáo tài chính"),
            ("## Group 6 - Danh mục rủi ro", 6, "Danh mục rủi ro"),
            ("### 3.1.1 Group 7", 7, "Nhóm 7"),
            ("### Nhóm 8A - Quản lý cổ phiếu", 8, "Quản lý cổ phiếu"),
            ("#### 3.2.1 Nhóm 9 – Giám sát margin", 9, "Giám sát margin"),
        ]

        for analyzer in (pa_skill, pa_root):
            for raw_header, expected_num, expected_name in test_headers:
                hld_text = f"{raw_header}\n| KPI_ID | Tên chỉ tiêu | ĐVT | Tính chất | Công thức | Ghi chú | Trạng thái |\n|---|---|---|---|---|---|---|\n| K_TEST_01 | Chỉ tiêu A | % | Cơ sở | f1 | n1 | READY |\n"
                items = analyzer.HLDParser.parse_text(hld_text, module="TEST")
                self.assertEqual(len(items), 1, f"Failed on header '{raw_header}' with {analyzer.__file__}")
                item = items[0]
                self.assertEqual(item.group_num, expected_num, f"Group num mismatch for '{raw_header}'")
                self.assertEqual(item.group_name, expected_name, f"Group name mismatch for '{raw_header}'")

    def test_pa_07_empty_blank_ba_status_classified_as_branch_1(self):
        """PA-07: Empty/blank/None/whitespace BA status must classify as Branch 1 (BA Pending)."""
        for classifier in (pa_skill.PendingClassifier, pa_root.PendingClassifier):
            # Test empty string
            res_empty = classifier.classify(
                kpi_name="Chỉ tiêu test",
                ba_status="",
                ba_source="IDS.firm_info",
                ba_data_type="decimal",
            )
            self.assertEqual(res_empty, classifier.REASON_BA_PENDING, "Empty status must be Branch 1")

            # Test whitespace string
            res_ws = classifier.classify(
                kpi_name="Chỉ tiêu test",
                ba_status="   ",
                ba_source="IDS.firm_info",
                ba_data_type="decimal",
            )
            self.assertEqual(res_ws, classifier.REASON_BA_PENDING, "Whitespace status must be Branch 1")

            # Test None status
            res_none = classifier.classify(
                kpi_name="Chỉ tiêu test",
                ba_status=None,
                ba_source="IDS.firm_info",
                ba_data_type="decimal",
            )
            self.assertEqual(res_none, classifier.REASON_BA_PENDING, "None status must be Branch 1")

            # Test standard pending
            res_pending = classifier.classify(
                kpi_name="Chỉ tiêu test",
                ba_status="Pending",
                ba_source="IDS.firm_info",
                ba_data_type="decimal",
            )
            self.assertEqual(res_pending, classifier.REASON_BA_PENDING, "Pending status must be Branch 1")

            # Test Done status proceeds to Branch 5 (Datamart Pending) when internal source is present
            res_done = classifier.classify(
                kpi_name="Chỉ tiêu test",
                ba_status="Done",
                ba_source="IDS.firm_info",
                ba_data_type="decimal",
            )
            self.assertEqual(res_done, classifier.REASON_DATAMART_PENDING, "Done status must proceed to Branch 5")

            # Test 'Không tìm thấy trong BA' proceeds to Branch 5
            res_not_found = classifier.classify(
                kpi_name="Chỉ tiêu test",
                ba_status="Không tìm thấy trong BA",
                ba_source="IDS.firm_info",
                ba_data_type="decimal",
            )
            self.assertEqual(res_not_found, classifier.REASON_DATAMART_PENDING, "Not-in-BA must not be Branch 1")

    def test_pa_05_disconnect_branch_6_from_has_count_mismatch(self):
        """PA-05: Group count mismatch alone must not force Branch 6; Branch 5 must be preserved."""
        for classifier in (pa_skill.PendingClassifier, pa_root.PendingClassifier):
            # Indicator has Done status, internal source, but group has count mismatch
            res_mismatch_no_note = classifier.classify(
                kpi_name="Dư nợ cho vay",
                ba_status="Done",
                ba_source="dwh_atomic.fct_loan",
                ba_data_type="decimal",
                group_name="Nhóm 5",
                ghi_chu="Đang chờ thiết kế bảng Fact",
                has_count_mismatch=True,
            )
            self.assertEqual(
                res_mismatch_no_note,
                classifier.REASON_DATAMART_PENDING,
                "PA-05: Group count mismatch must NOT swallow Branch 5 (Datamart Pending)",
            )

            # Indicator with explicit schema/atomic out-of-sync note correctly goes to Branch 6
            res_schema_note = classifier.classify(
                kpi_name="Dư nợ cho vay",
                ba_status="Done",
                ba_source="dwh_atomic.fct_loan",
                ba_data_type="decimal",
                group_name="Nhóm 5",
                ghi_chu="Schema out of sync: atomic table chưa approved trong YAML",
                has_count_mismatch=False,
            )
            self.assertEqual(
                res_schema_note,
                classifier.REASON_SCHEMA_OUT_OF_SYNC,
                "Explicit schema note must trigger Branch 6",
            )

    def test_item_8_delete_deleted_status_handling(self):
        """Item 8: Indicators marked Delete/DELETED/Xóa from BA must be excluded from active design scope and detected as violations if in Datamart."""
        for analyzer in (pa_skill, pa_root):
            ba_csv = (
                "STT,Mã,Dashboard/báo cáo,Thông tin,Phân loại,Trạng thái mapping,Bảng nguồn\n"
                "1,1,Dashboard 1,Chỉ tiêu Active,Chỉ tiêu cơ sở,Done,IDS.ACTIVE_TBL\n"
                "2,1,Dashboard 1,Chỉ tiêu Đã Xóa 1,Chỉ tiêu cơ sở,Delete,IDS.DEL_TBL\n"
                "3,1,Dashboard 1,Chỉ tiêu Đã Xóa 2,Chỉ tiêu cơ sở,DELETED,IDS.DEL_TBL\n"
                "4,1,Dashboard 1,Chỉ tiêu Đã Xóa 3,Chỉ tiêu cơ sở,Xóa,IDS.DEL_TBL\n"
            )

            with tempfile.TemporaryDirectory() as td:
                ba_file = Path(td) / "BA_test.csv"
                ba_file.write_text(ba_csv, encoding="utf-8-sig")

                # Default parse_file excludes deleted items
                active_items = analyzer.BAParser.parse_file(ba_file, include_deleted=False)
                self.assertEqual(len(active_items), 1, "Only active indicator should be returned")
                self.assertEqual(active_items[0].name, "Chỉ tiêu Active")

                # parse_file with include_deleted=True returns all
                all_items = analyzer.BAParser.parse_file(ba_file, include_deleted=True)
                self.assertEqual(len(all_items), 4, "All 4 items should be parsed when include_deleted=True")

                # get_deleted_items returns exactly the 3 deleted items
                del_items = analyzer.BAParser.get_deleted_items(ba_file)
                self.assertEqual(len(del_items), 3, "Exactly 3 deleted items should be extracted")
                del_names = {d.name for d in del_items}
                self.assertIn("Chỉ tiêu Đã Xóa 1", del_names)
                self.assertIn("Chỉ tiêu Đã Xóa 2", del_names)
                self.assertIn("Chỉ tiêu Đã Xóa 3", del_names)

    def test_item_8_deleted_indicator_violation_in_datamart(self):
        """Item 8: If a deleted BA item is designed in HLD/LLD, analyzer must flag it as a Critical violation in matrix and report."""
        for analyzer in (pa_skill, pa_root):
            with tempfile.TemporaryDirectory() as td:
                root_path = Path(td)
                ba_dir = root_path / "BRD" / "BA"
                ba_dir.mkdir(parents=True)
                hld_dir = root_path / "Datamart" / "hld"
                hld_dir.mkdir(parents=True)
                lld_dir = root_path / "Datamart" / "lld"
                lld_dir.mkdir(parents=True)

                ba_csv = (
                    "STT,Mã,Dashboard/báo cáo,Thông tin,Phân loại,Trạng thái mapping,Bảng nguồn\n"
                    "1,1,Dashboard 1,Chỉ tiêu Hợp Lệ,Chỉ tiêu cơ sở,Done,IDS.TBL_1\n"
                    "2,1,Dashboard 1,Chỉ tiêu Bị Bãi Bỏ,Chỉ tiêu cơ sở,DELETED,IDS.TBL_2\n"
                )
                (ba_dir / "BA_analyst_TEST.csv").write_text(ba_csv, encoding="utf-8-sig")

                hld_md = (
                    "# DTM_TEST_HLD\n\n"
                    "### Nhóm 1 - Dashboard 1\n"
                    "| KPI_ID | Tên chỉ tiêu | ĐVT | Tính chất | Công thức | Ghi chú | Trạng thái |\n"
                    "|---|---|---|---|---|---|---|\n"
                    "| K_TEST_01 | Chỉ tiêu Hợp Lệ | % | Cơ sở | col1 | note1 | READY |\n"
                    "| K_TEST_02 | Chỉ tiêu Bị Bãi Bỏ | % | Cơ sở | col2 | note2 | READY |\n"
                )
                (hld_dir / "DTM_TEST_HLD.md").write_text(hld_md, encoding="utf-8-sig")

                dm_analyzer = analyzer.DatamartProgressAnalyzer(root_path)
                analysis = dm_analyzer.analyze_module("TEST")

                # The deleted indicator K_TEST_02 should be detected in matrix under Delete -> READY
                matrix = analysis["cross_status_matrix"]
                self.assertEqual(matrix["Delete"]["READY"], 1, "Deleted indicator designed as READY must be counted in Delete matrix row")
                self.assertEqual(len(analysis["deleted_violations"]), 1, "Must produce 1 deleted violation")
                self.assertEqual(analysis["deleted_violations"][0]["kpi_id"], "K_TEST_02")

                # Verify markdown report contains warning
                report_md = dm_analyzer.generate_markdown_report(analysis)
                self.assertIn("CẢNH BÁO VI PHẠM: Chỉ tiêu BA bị XÓA", report_md)
                self.assertIn("K_TEST_02", report_md)

    def test_item_8_and_9_documentation_completeness(self):
        """Item 8 & 9: Verify SKILL.md and issue_classification.md contain all mandatory rules."""
        skill_path = SKILL_DIR / "SKILL.md"
        issue_path = SKILL_DIR / "reference" / "issue_classification.md"

        self.assertTrue(skill_path.exists(), "SKILL.md must exist")
        self.assertTrue(issue_path.exists(), "issue_classification.md must exist")

        skill_text = skill_path.read_text(encoding="utf-8")
        issue_text = issue_path.read_text(encoding="utf-8")

        # Check Item 8 in SKILL.md
        self.assertIn("Chỉ tiêu bị XÓA", skill_text)
        self.assertIn("DEPRECATED / RETIRED", skill_text)
        self.assertIn("BA Status:** `Done` / `Doing` / `Pending` / `Delete`", skill_text)

        # Check Item 9 in SKILL.md
        self.assertIn("L2-SCD4A-TECH-FIELD", skill_text)
        self.assertIn("L2-SCD4A-JOIN-FILTER", skill_text)
        self.assertIn("ds_rcrd_st = 'ACTIVE'", skill_text)
        self.assertIn("Bảo vệ SHARED Dimension", skill_text)
        self.assertIn("Bảo vệ SHARED Dimension trong Registry", skill_text)
        self.assertIn("Trường kỹ thuật SCD4A trong Registry", skill_text)

        # Check Item 8 in issue_classification.md
        self.assertIn("5. Quy tắc Kiểm tra và Xử lý Chỉ tiêu Bị XÓA", issue_text)
        self.assertIn("Retirement Protocol", issue_text)
        self.assertIn("DEPRECATED / RETIRED", issue_text)
        self.assertIn("Tuyệt đối KHÔNG thiết kế mới", issue_text)


if __name__ == "__main__":
    unittest.main()
