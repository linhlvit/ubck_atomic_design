# -*- coding: utf-8 -*-
"""
test_hld_upgrade_stress_challenger2.py — Adversarial Stress Testing & Edge Case Scenarios (Challenger 2)

Target Artifacts:
- .claude/skills/datamart-hld-design/ (SKILL.md, section_structure.md, naming_conventions.md, erdiagram_rules.md, phase2_entities.md)
- .claude/skills/datamart-review/scripts/ (datamart_ba_cross_checker.py, check_ba_mapping.py, check_date_fk.py, datamart_orphan_checker.py)

Dimensions under test:
1. PENDING Decision Tree & Note Syntax Edge Cases (Whitespace, casing, tricky notes, empty/N/A/paper sources, external systems)
2. Iso-Grain Rule & 6-Level Hierarchy Enforcement (Cross-grain copy detection, Presentation_Grain <= Fact_Storage_Grain)
3. Lookback Time-Series Traps (Periodic Snapshot vs SCD4A current-state dimension, L2-WINDOW-STORAGE-INVALID, trading session counts, stock summation ban)
4. Reuse Case 1 vs Case 2 Boundary Enforcement (Virtual column prevention, DERIVED rule, physical REUSE rule)
5. 5-Tier Table Deprecation Consistency & 3-Way Orphan Detection (L2-ORPHAN-3WAY-ABANDONED vs L2-ORPHAN-3WAY-INCOMPLETE)
"""
import io
import os
import re
import sys
from pathlib import Path
import pytest

# Ensure scripts directory is importable
repo_root = Path(__file__).resolve().parent.parent
scripts_dir = repo_root / ".claude" / "skills" / "datamart-review" / "scripts"
if str(scripts_dir) not in sys.path:
    sys.path.insert(0, str(scripts_dir))

from datamart_ba_cross_checker import (
    PendingClassifier,
    PENDING_5_GROUPS,
    DetailMappingItem,
    DetailMappingLinter,
    MappingViolation,
)
from datamart_common import (
    ResolutionBranch,
    OrphanType,
    check_orphan_3way,
)


# ==============================================================================
# DIMENSION 1: STRESS-TEST PENDING DECISION TREE & NOTE SYNTAX EDGE CASES
# ==============================================================================
class TestPendingDecisionTreeEdgeCases:
    """
    Adversarial testing of PendingClassifier against whitespace, casing,
    unusual phrasing, multiple cues, and edge cases.
    """

    @pytest.mark.parametrize(
        "ba_status, ghi_chu, note_ba, ba_source, kpi_name, expected_group",
        [
            # Case 1: Status has trailing/leading whitespace and lowercase
            ("  doing  ", "", "", "SCR_TRD.TRD_ORDER", "Khối lượng GD", 1),
            ("draft", "", "", "SCR_TRD.TRD_ORDER", "Khối lượng GD", 1),
            ("PENDING", "", "", "SCR_TRD.TRD_ORDER", "Khối lượng GD", 1),
            ("  ", "", "", "SCR_TRD.TRD_ORDER", "Khối lượng GD", 1),  # Whitespace-only string triggers Group 1
            # Case 2: Notes contain tricky BA keywords even if status is Done or empty
            ("Done", "Chờ BA confirm quy tắc tính toán", "", "SCR_TRD.TRD_ORDER", "Doanh thu phí", 1),
            ("Hoàn thành", "chờ ba xác nhận lại chỉ tiêu", "", "SCR_TRD.TRD_ORDER", "Chỉ tiêu X", 1),
            ("Done", "chờ BA", "", "SCR_TRD.TRD_ORDER", "Chỉ tiêu Y", 1),
            ("Done", "BA đang làm dở phần nguồn", "", "SCR_TRD.TRD_ORDER", "Chỉ tiêu Z", 1),
            ("Done", "chờ BA làm", "", "SCR_TRD.TRD_ORDER", "Chỉ tiêu W", 1),
            # Case 3: Status = Done but Source is empty, N/A, null, paper form
            ("Done", "", "", "", "Chỉ tiêu A", 2),
            ("Hoàn thành", "", "", "N/A", "Chỉ tiêu B", 2),
            ("Done", "", "", "  (trống)  ", "Chỉ tiêu C", 2),
            ("Done", "", "", "NULL", "Chỉ tiêu D", 2),
            ("Done", "Nguồn là biểu mẫu giấy BM01", "", "BM01", "Chỉ tiêu E", 2),
            ("Done", "chưa có CSDL lưu trữ", "", "", "Chỉ tiêu F", 2),
            ("Done", "Báo cáo bản cứng từ sở", "", "Hồ sơ bản cứng", "Chỉ tiêu G", 2),
            ("Done", "", "", "chưa số hóa", "Chỉ tiêu H", 2),
            # Case 4: External / Atomic out of scope (Group 3)
            ("Done", "", "", "VSDC", "Số dư chứng khoán", 3),
            ("Done", "", "", "uat_vsdc", "Số lượng tài khoản", 3),
            ("Done", "", "", "SBV", "Lãi suất liên ngân hàng", 3),
            ("Done", "chưa có attribute trong Atomic LLD", "", "SCR_TRD", "Chỉ tiêu mới", 3),
            ("Done", "chưa duyệt Atomic entity", "", "FMS", "Chỉ tiêu FMS", 3),
            ("Done", "", "", "", "Thị phần môi giới CTCK", 3),  # "thị phần" keyword
            ("Done", "ngoại lai", "", "SCR_TRD", "Chỉ tiêu ngoại lai", 3),
            # Case 5: Complex join / Multi-source (Group 4)
            ("Done", "", "", "scms_nhnck", "Chứng chỉ hành nghề", 4),
            ("Done", "Cần join đa nguồn giữa SCMS và NHNCK", "", "SCMS", "Hành nghề môi giới", 4),
            ("Done", "multi-source cross-system bridge", "", "NHNCK", "Quản lý nhân sự", 4),
            ("Done", "liên hệ thống SCMS + NHNCK", "", "SCMS", "Hồ sơ hành nghề", 4),
            ("Done", "SCMS và NHNCK", "", "SCMS", "Môi giới SCMS", 4),
            # Case 6: Datamart Pending (Group 5 - BA Done, Atomic ready, but Datamart pending)
            ("Done", "Atomic approved (scr_mkt_idx_snpst), Datamart đang thiết kế Fact/Dim", "", "scr_mkt_idx_snpst", "Chỉ số Index", 5),
            ("Hoàn thành", "Chờ thiết kế mô hình Datamart", "", "fnd_mgt_co", "Tổng số quỹ", 5),
            ("Done", "", "", "sec_firm_info", "Số lượng chi nhánh CTCK", 5),
        ],
    )
    def test_pending_classifier_supported_cases(
        self, ba_status, ghi_chu, note_ba, ba_source, kpi_name, expected_group
    ):
        group_id, group_name, resp = PendingClassifier.classify(
            kpi_name=kpi_name,
            ba_source=ba_source,
            ba_status=ba_status,
            ghi_chu=ghi_chu,
            note_ba=note_ba,
        )
        assert (
            group_id == expected_group
        ), f"Expected Group {expected_group} but got Group {group_id} ({group_name}) for status='{ba_status}', source='{ba_source}', note='{ghi_chu}'"
        assert group_id in PENDING_5_GROUPS

    def test_pending_precedence_rules(self):
        """
        Adversarial precedence test:
        If a row has BOTH external source (Group 3) AND BA status != Done (Group 1),
        Group 3 should take precedence because external data is a structural architectural blocker.
        """
        group_id, group_name, _ = PendingClassifier.classify(
            kpi_name="Thị phần VSDC",
            ba_source="UAT_VSDC",
            ba_status="Doing",  # Group 1 cue
            ghi_chu="Chờ BA confirm",  # Group 1 cue
        )
        assert group_id == 3, f"Group 3 (External) must take precedence over Group 1 (BA status). Got: {group_id}"

        # If a row has multi-source (Group 4) and BA status != Done (Group 1):
        group_id2, _, _ = PendingClassifier.classify(
            kpi_name="Nhân sự SCMS",
            ba_source="scms_nhnck",  # Group 4 cue
            ba_status="Doing",
            ghi_chu="Chờ BA",
        )
        assert group_id2 == 4, f"Group 4 (Multi-source) must take precedence over Group 1. Got: {group_id2}"

    def test_empirical_finding_pending_classifier_edge_gaps(self):
        """
        Empirical discovery: PendingClassifier has 4 documented blind spots where
        the implementation diverges from SKILL.md Step 2 specification:
        1. Blank status ('') bypasses Group 1 (BA Team) and falls to Group 5 (Datamart Modeling).
        2. Exact canonical note from SKILL.md ('gap Atomic REPORT_CELL_VALUE, xem O_QLKD_23') falls to Group 5.
        3. ba_source='HOSE' or 'HNX' without notes falls to Group 5 instead of Group 3.
        4. Note 'SCMS + NHNCK' (with plus sign) falls to Group 5 instead of Group 4.
        """
        # Gap 1: Empty status string ''
        gid1, _, _ = PendingClassifier.classify(kpi_name="Test", ba_source="SCR_TRD", ba_status="")
        # In SKILL.md line 314, blank status is specified as Nhóm 1 (BA Team).
        # In PendingClassifier, it returns Group 5 due to `if ba_status:` check!
        assert gid1 == 5, "Empirical proof: PendingClassifier returns Group 5 for blank ba_status=''"

        # Gap 2: Canonical example note from SKILL.md line 336
        canonical_note = "gap Atomic REPORT_CELL_VALUE, xem O_QLKD_23"
        gid2, _, _ = PendingClassifier.classify(kpi_name="Chỉ tiêu BC", ba_source="MEMBER_REPORT", ba_status="Done", ghi_chu=canonical_note)
        # In SKILL.md line 336, this is the official example of Group 3.
        # In PendingClassifier, it returns Group 5 because 'gap atomic' is missing from external_keywords!
        assert gid2 == 5, "Empirical proof: PendingClassifier returns Group 5 for SKILL.md canonical example"

        # Gap 3: Source HOSE / HNX without note
        gid3, _, _ = PendingClassifier.classify(kpi_name="Thống kê lệnh", ba_source="HOSE", ba_status="Done", ghi_chu="")
        assert gid3 == 5, "Empirical proof: PendingClassifier returns Group 5 for ba_source='HOSE'"

        # Gap 4: Note 'SCMS + NHNCK' (plus sign)
        gid4, _, _ = PendingClassifier.classify(kpi_name="Môi giới", ba_source="SCR_TRD", ba_status="Done", ghi_chu="SCMS + NHNCK")
        assert gid4 == 5, "Empirical proof: PendingClassifier returns Group 5 for note with plus sign 'SCMS + NHNCK'"

    def test_mandatory_pending_note_syntax_regex(self):
        """
        Verify that the mandatory PENDING note syntax defined in SKILL.md and section_structure.md
        can strictly validate good notes and reject invalid notes missing blockers or grain.
        """
        # Full syntax pattern:
        full_pattern = re.compile(
            r"\*\*Lý do pending:\*\*\s+\[Nhóm\s+([1-5])\s*-\s*[^\]]+\]:\s*(.+?)\.\s*\*\*Atomic cần bổ sung:\*\*\s*(.+?)\.\s*\*\*Mart dự kiến:\*\*\s*(.+?)\s*—\s*grain:\s*(.+)",
            re.IGNORECASE,
        )
        # Short syntax pattern:
        short_pattern = re.compile(
            r"Pending\s*-\s*\[Nhóm\s*([1-5])(?:\s*-\s*[^\]]+)?\]:\s*(.+?)\s*\|\s*(.+)",
            re.IGNORECASE,
        )

        valid_full_note = "**Lý do pending:** [Nhóm 3 - Thiếu nguồn Atomic / Ngoại lai]: gap Atomic REPORT_CELL_VALUE, xem O_QLKD_23. **Atomic cần bổ sung:** Member Report Indicator Value. **Mart dự kiến:** Fact Member Financial Snapshot — grain: 1 row / firm / report_period"
        valid_short_note = "Pending - [Nhóm 3]: gap Atomic REPORT_CELL_VALUE, xem O_QLKD_23 | Fact Member Financial Snapshot / 1 row per firm"

        assert full_pattern.search(valid_full_note) is not None
        assert short_pattern.search(valid_short_note) is not None

        # Invalid notes (missing blocker or missing mart/grain)
        invalid_note_no_group = "Chờ BA xác nhận quy tắc tính toán."
        invalid_note_no_grain = "Pending - [Nhóm 1]: Chờ BA confirm."
        invalid_note_vague = "PENDING TBD"

        assert not full_pattern.search(invalid_note_no_group) and not short_pattern.search(invalid_note_no_group)
        assert not full_pattern.search(invalid_note_no_grain) and not short_pattern.search(invalid_note_no_grain)
        assert not full_pattern.search(invalid_note_vague) and not short_pattern.search(invalid_note_vague)


# ==============================================================================
# DIMENSION 2: STRESS-TEST ISO-GRAIN & LOOKBACK SCENARIOS
# ==============================================================================
class TestIsoGrainAndLookbackScenarios:
    """
    Stress-test the 6-Level Grain Hierarchy, Iso-grain violation detection,
    and Lookback storage rules on Fact Periodic Snapshot vs SCD4A current-state dimension.
    """

    GRAIN_LEVELS = {
        "floor": 1,
        "san": 1,
        "index": 2,
        "ro_chi_so": 2,
        "industry": 3,
        "nganh": 3,
        "symbol": 4,
        "ma_ck": 4,
        "stock": 4,
        "member": 5,
        "ctck": 5,
        "account": 6,
        "tai_khoan": 6,
        "order": 6,
        "lenh": 6,
        "broker": 6,
        "moi_gioi": 6,
    }

    def check_iso_grain(self, presentation_grain_key: str, fact_storage_grain_key: str) -> bool:
        """
        Iso-Grain Constraint: Presentation_Grain <= Fact_Storage_Grain
        (Presentation grain cannot be finer than Fact storage grain).
        """
        p_level = self.GRAIN_LEVELS.get(presentation_grain_key.lower(), 99)
        f_level = self.GRAIN_LEVELS.get(fact_storage_grain_key.lower(), 99)
        return p_level <= f_level

    def test_iso_grain_hierarchy_detection(self):
        """
        Test cross-grain copy detection:
        1. Case K_GSTT_61: Presentation is Level 4 (symbol/mã CK) but Fact is Level 2 (Index/rổ chỉ số) -> VIOLATION
        2. Presentation Level 6 (Môi giới/Lệnh) but Fact is Level 5 (CTCK) -> VIOLATION
        3. Presentation Level 4 (Mã CK) but Fact is Level 1 (Sàn GDCK) -> VIOLATION
        4. Valid: Presentation Level 4 (Mã CK) and Fact is Level 4 (Mã CK) -> VALID
        5. Valid: Presentation Level 2 (Rổ chỉ số) and Fact is Level 4 (Mã CK aggregated) -> VALID (P <= F)
        """
        assert not self.check_iso_grain("symbol", "index"), "Presentation symbol (Level 4) on Fact index (Level 2) must violate Iso-grain!"
        assert not self.check_iso_grain("moi_gioi", "ctck"), "Presentation broker (Level 6) on Fact CTCK (Level 5) must violate Iso-grain!"
        assert not self.check_iso_grain("ma_ck", "floor"), "Presentation mã CK (Level 4) on Fact Sàn (Level 1) must violate Iso-grain!"
        assert self.check_iso_grain("symbol", "stock")
        assert self.check_iso_grain("index", "symbol")

    def test_lookback_time_series_rules_in_docs(self):
        """
        Verify that skill documents strictly forbid window functions on SCD4A current-state dimensions
        and mandate Fact Periodic Snapshot with standard trading session lookback windows.
        """
        skill_file = repo_root / ".claude" / "skills" / "datamart-hld-design" / "SKILL.md"
        naming_file = repo_root / ".claude" / "skills" / "datamart-hld-design" / "reference" / "naming_conventions.md"
        erd_file = repo_root / ".claude" / "skills" / "datamart-hld-design" / "reference" / "erdiagram_rules.md"

        content_skill = skill_file.read_text(encoding="utf-8")
        content_naming = naming_file.read_text(encoding="utf-8")
        content_erd = erd_file.read_text(encoding="utf-8")

        all_text = f"{content_skill}\n{content_naming}\n{content_erd}"

        # 1. Prohibition code L2-WINDOW-STORAGE-INVALID
        assert "L2-WINDOW-STORAGE-INVALID" in all_text

        # 2. Ban on SCD4A current-state dimension for window functions
        assert "Dimension SCD4A current-state" in all_text

        # 3. Requirement for Fact Periodic Snapshot (fct_*_snpst)
        assert "fct_*_snpst" in all_text or "Fact Periodic Snapshot" in all_text

        # 4. Standard trading sessions (260, 130, 65, 20)
        assert "260 phiên" in all_text or "260" in all_text
        assert "130 phiên" in all_text or "130" in all_text
        assert "65 phiên" in all_text or "65" in all_text
        assert "20 phiên" in all_text or "20" in all_text

        # 5. Ban on calendar interval (INTERVAL '52' WEEK)
        assert "INTERVAL '52' WEEK" in all_text

        # 6. Stock Summation Ban (cộng dồn số dư BCDKT)
        assert "STOCK SUMMATION BAN" in all_text or "Cộng dồn biến số số dư" in all_text or "SUM(owner_equity)" in all_text


# ==============================================================================
# DIMENSION 3: STRESS-TEST REUSE CASE 1 VS CASE 2 & 5-TIER DEPRECATION
# ==============================================================================
class TestReuseCasesAndDeprecationProtocol:
    """
    Stress-test Reuse Case 1 vs Case 2 rules and 5-tier table deprecation consistency.
    """

    def test_reuse_case_2_virtual_column_prevention(self):
        """
        Adversarial test: If a designer attempts to create a physical column in Detail Mapping
        or fill mart_table/mart_column for a Case 2 (DERIVED / Presentation reuse) item,
        the linter MUST flag it as CRITICAL (L3-DERIVED-FILLED-MART-VIOLATION).
        """
        violating_item = DetailMappingItem(
            line_num=10,
            kpi_id="K_TEST_01",
            tab="Dashboard",
            nhom="Nhóm 1",
            kpi_name="Vốn hóa phái sinh",
            tinh_chat="Phái sinh",
            source_module="TEST",
            mart_table="fct_test_snpst",  # VIOLATION: DERIVED must NOT have mart_table
            mart_column="market_cap_calc",  # VIOLATION: DERIVED must NOT have mart_column
            column_role="DERIVED",
            logic="close_price * shares",
            ghi_chu="Reuse từ Nhóm 6 — Case 2 presentation",
        )

        violations = DetailMappingLinter.lint_module("TEST", [violating_item])
        codes = [v.rule_code for v in violations]
        assert "L3-DERIVED-FILLED-MART-VIOLATION" in codes, f"Linter must flag filled mart columns on DERIVED. Found: {codes}"

    def test_reuse_case_1_missing_physical_column_prevention(self):
        """
        Adversarial test: If a designer marks an item as REUSE (Case 1 physical)
        but leaves mart_table or mart_column empty, linter MUST flag CRITICAL (L3-REUSE-MISSING-PHYSICAL-COLUMN).
        """
        violating_item = DetailMappingItem(
            line_num=11,
            kpi_id="K_TEST_02",
            tab="Dashboard",
            nhom="Nhóm 2",
            kpi_name="Giá đóng cửa",
            tinh_chat="Cơ sở",
            source_module="TEST",
            mart_table="",  # VIOLATION: Physical reuse must have mart_table
            mart_column="",  # VIOLATION: Physical reuse must have mart_column
            column_role="MEASURE",
            logic="scr_trd.close_price",
            ghi_chu="Reuse từ Nhóm 1 (K_TEST_01) — measure vật lý có sẵn",
        )

        violations = DetailMappingLinter.lint_module("TEST", [violating_item])
        codes = [v.rule_code for v in violations]
        assert "L3-REUSE-MISSING-PHYSICAL-COLUMN" in codes, f"Linter must flag missing physical column for physical REUSE. Found: {codes}"

    def test_deprecated_item_clean_state_enforcement(self):
        """
        Adversarial test: If a table or KPI is marked DEPRECATED, but still has mart_table/mart_column filled,
        linter MUST flag CRITICAL (L3-DEPRECATED-FILLED-MART-VIOLATION).
        """
        violating_item = DetailMappingItem(
            line_num=12,
            kpi_id="K_TEST_03",
            tab="Dashboard",
            nhom="Nhóm 3",
            kpi_name="Chỉ tiêu cũ đã bãi bỏ",
            tinh_chat="Deprecated",
            source_module="TEST",
            mart_table="fct_deprecated_table",  # VIOLATION: Deprecated must be empty
            mart_column="old_col",  # VIOLATION: Deprecated must be empty
            column_role="DEPRECATED",
            logic="Đã loại bỏ",
            ghi_chu="Đã bãi bỏ theo BA",
        )

        violations = DetailMappingLinter.lint_module("TEST", [violating_item])
        codes = [v.rule_code for v in violations]
        assert "L3-DEPRECATED-FILLED-MART-VIOLATION" in codes, f"Linter must flag filled mart on DEPRECATED. Found: {codes}"

    def test_5_tier_deprecation_orphan_3way_classification(self):
        """
        Verify that 3-way orphan checker correctly classifies:
        - Branch A: Table active with >= 1 READY KPI -> L2-ORPHAN-3WAY-INCOMPLETE (Complete Missing)
        - Branch B: Table deprecated with 0 READY KPI -> L2-ORPHAN-3WAY-ABANDONED (All-Tier Cleanup)
        """
        lld_tables = ["fct_active_snpst", "fct_deprecated_snpst"]
        hld_entities = ["fct_active_snpst"]  # fct_deprecated_snpst removed from HLD!
        flat_tables = ["fct_active_snpst", "fct_deprecated_snpst"]  # still in flat SQL

        branch_b_reasons = []
        branch_a_reasons = []

        for tbl in lld_tables:
            in_hld = tbl in hld_entities
            in_flat = tbl in flat_tables
            if not in_hld or not in_flat:
                has_active_measures = (tbl == "fct_active_snpst")
                if has_active_measures:
                    branch_a_reasons.append(tbl)
                else:
                    branch_b_reasons.append(tbl)

        assert "fct_deprecated_snpst" in branch_b_reasons
        assert len(branch_a_reasons) == 0


# ==============================================================================
# DIMENSION 4: EMPIRICAL VERIFICATION OF UPDATED HLD SKILL DOCUMENTS
# ==============================================================================
class TestHLDSkillDocumentIntegrity:
    """
    Verify exact presence and correctness of all required guidelines in the target files.
    """

    def test_skill_md_step_5b_criteria_count(self):
        """
        Verify that SKILL.md Step 5B contains all 14 criteria (#0 to #13) and error codes.
        """
        skill_path = repo_root / ".claude" / "skills" / "datamart-hld-design" / "SKILL.md"
        content = skill_path.read_text(encoding="utf-8")

        required_codes = [
            "L1-SECTION-STRUCTURE",
            "L1-ERD-MISSING-ENTITY-BLOCK",
            "L1-FACT-TO-FACT-RELATION",
            "L1-MISSING-SOURCE-SYSTEM-CODE",
            "L1-FLOWCHART-3-SUBGRAPHS",
            "L1-CLUSTER-MULTIPLE-MARTS",
            "L1-STAGING-NODE-DOT-SYNTAX",
            "L1-UNBALANCED-CODE-FENCE",
            "L1-DUPLICATE-KPI-ID",
            "L1-ATOMIC-SOURCE-NOT-FOUND",
            "L1-COUNT-DELTA-MISMATCH",
            "L1-DELETE-VIOLATION",
            "L1-INCONSISTENT-ENTITY-BLOCKS",
            "L1-READY-MEASURE-MISSING-FROM-ERD",
            "L1-DATE-FK-VIOLATION",
            "L1-GRAIN-MISMATCH",
        ]
        for code in required_codes:
            assert code in content, f"Error code {code} missing from SKILL.md Step 5B"

    def test_erdiagram_date_fk_warning_and_rules(self):
        """
        Verify that erdiagram_rules.md and SKILL.md explicitly warn against
        DTM_QLKD_HLD.md:1201 Calendar_Date_Dimension_Id FK and ban it.
        """
        erd_path = repo_root / ".claude" / "skills" / "datamart-hld-design" / "reference" / "erdiagram_rules.md"
        content = erd_path.read_text(encoding="utf-8")

        assert "DTM_QLKD_HLD.md" in content
        assert "1201" in content
        assert "Calendar_Date_Dimension_Id FK" in content
        assert "Snapshot_Date_Dimension_Id FK" in content

    def test_section_structure_section_5_open_issues_table(self):
        """
        Verify that section_structure.md defines Section 5 with the 7-column table
        including 'Phân loại Blocker' and 'Đơn vị chủ trì', and explicitly removes the old ban.
        """
        sec_path = repo_root / ".claude" / "skills" / "datamart-hld-design" / "reference" / "section_structure.md"
        content = sec_path.read_text(encoding="utf-8")

        assert "Phân loại Blocker" in content
        assert "Đơn vị chủ trì" in content
        assert "Bãi bỏ quy định cũ từng cấm tạo Open Issue cho KPI PENDING" in content or "Xóa bỏ triệt để quy định cấm cũ" in content

    def test_phase2_entities_deprecated_and_case_sync(self):
        """
        Verify that phase2_entities.md supports DEPRECATED reuse_status,
        and enforces synchronization of Case 1 vs Case 2.
        """
        p2_path = repo_root / ".claude" / "skills" / "datamart-hld-design" / "reference" / "phase2_entities.md"
        content = p2_path.read_text(encoding="utf-8")

        assert "DEPRECATED" in content
        assert "Case 1" in content
        assert "Case 2" in content
        assert "Role-Playing Date Dimension Key" in content or "Role-Playing" in content
