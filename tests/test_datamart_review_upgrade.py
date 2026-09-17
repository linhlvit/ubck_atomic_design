# -*- coding: utf-8 -*-
"""
tests/test_datamart_review_upgrade.py — Comprehensive Test Suite for Datamart Review Upgrade

Validates:
  1. Unified Quality Gate Runner (run_quality_gates.py):
     - Sequential execution of Gates 1 to 4.
     - Exit code semantics: 0 on PASS, 1 on FAIL.
     - --strict enforcement.
     - --json structured output.
     - -m GSTT passes all 4 gates.
     - -m Common gracefully skips Gates 2 & 3 and passes Gates 1 & 4.
  2. Datamart Progress Analyzer (datamart_progress_analyzer.py):
     - 5 standard PENDING categories returned, Reason 6 eliminated/aliased.
     - Classification decision tree logic across Categories 1 to 5.
  3. Documentation & Reference Matrix Consistency:
     - Zero occurrences of "6 nhánh" or "6 nhóm" across all reference docs.
     - All 21 standardized error codes in issue_classification.md are valid and have detailed specification cards.
"""
from __future__ import annotations

import glob
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import unittest

REPO_ROOT = Path(__file__).resolve().parents[1]
SKILL_DIR = REPO_ROOT / ".claude" / "skills" / "datamart-review"
SKILL_SCRIPTS_DIR = SKILL_DIR / "scripts"
ROOT_SCRIPTS_DIR = REPO_ROOT / "scripts"

for p in [str(SKILL_SCRIPTS_DIR), str(ROOT_SCRIPTS_DIR)]:
    if p not in sys.path:
        sys.path.insert(0, p)

from datamart_progress_analyzer import PendingClassifier
import run_quality_gates

RUN_QUALITY_GATES_SCRIPT = SKILL_SCRIPTS_DIR / "run_quality_gates.py"
if not RUN_QUALITY_GATES_SCRIPT.exists():
    RUN_QUALITY_GATES_SCRIPT = ROOT_SCRIPTS_DIR / "run_quality_gates.py"


class TestUnifiedQualityGateRunner(unittest.TestCase):
    """Verifies the unified Quality Gate Runner (run_quality_gates.py) across Gates 1 to 4."""

    def test_01_gate_specs_sequence_definition(self):
        """GATE_SPECS defines Gates 1 to 4 in strict sequential order."""
        specs = run_quality_gates.GATE_SPECS
        self.assertEqual(len(specs), 4)
        expected_gates = ["Gate 1", "Gate 2", "Gate 3", "Gate 4"]
        actual_gates = [s["gate"] for s in specs]
        self.assertEqual(actual_gates, expected_gates)

        expected_scripts = ["check_date_fk.py", "check_parity.py", "check_orphan.py", "check_flat_table.py"]
        actual_scripts = [s["script"] for s in specs]
        self.assertEqual(actual_scripts, expected_scripts)

    def test_02_gstt_passes_all_four_gates_programmatically(self):
        """run_gate for GSTT returns status PASS and exit_code 0 for all 4 gates."""
        results = []
        for spec in run_quality_gates.GATE_SPECS:
            r = run_quality_gates.run_gate(spec, "GSTT", REPO_ROOT, strict=True, json_output=True)
            results.append(r)
            self.assertEqual(
                r["status"], "PASS",
                f"{spec['gate']} ({spec['name']}) failed on GSTT: {r.get('output')} / {r.get('stderr')}",
            )
            self.assertEqual(r["exit_code"], 0)

        self.assertEqual(len(results), 4)

    def test_03_common_skips_gates_2_3_and_passes_1_4_programmatically(self):
        """run_gate for Common skips Gates 2 & 3 gracefully and passes Gates 1 & 4."""
        gate_map = {}
        for spec in run_quality_gates.GATE_SPECS:
            r = run_quality_gates.run_gate(spec, "Common", REPO_ROOT, strict=True, json_output=True)
            gate_map[spec["gate"]] = r

        # Gate 1: PASS
        self.assertEqual(gate_map["Gate 1"]["status"], "PASS")
        self.assertEqual(gate_map["Gate 1"]["exit_code"], 0)

        # Gate 2: SKIP
        self.assertEqual(gate_map["Gate 2"]["status"], "SKIP")
        self.assertEqual(gate_map["Gate 2"]["exit_code"], 0)
        self.assertIn("N/A", gate_map["Gate 2"]["message"])
        self.assertIn("Common is a shared ClickHouse flat dimension table", gate_map["Gate 2"]["message"])

        # Gate 3: SKIP
        self.assertEqual(gate_map["Gate 3"]["status"], "SKIP")
        self.assertEqual(gate_map["Gate 3"]["exit_code"], 0)
        self.assertIn("N/A", gate_map["Gate 3"]["message"])
        self.assertIn("Common is a shared ClickHouse flat dimension table", gate_map["Gate 3"]["message"])

        # Gate 4: PASS
        self.assertEqual(gate_map["Gate 4"]["status"], "PASS")
        self.assertEqual(gate_map["Gate 4"]["exit_code"], 0)

    def test_04_cli_gstt_all_gates_pass_exit_code_0(self):
        """CLI: run_quality_gates.py -m GSTT returns exit code 0 and reports ALL GATES PASSED."""
        cmd = [
            sys.executable,
            str(RUN_QUALITY_GATES_SCRIPT),
            "-m", "GSTT",
            "--root", str(REPO_ROOT),
        ]
        proc = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(proc.returncode, 0, f"GSTT runner failed: {proc.stderr or proc.stdout}")
        self.assertIn("ALL GATES PASSED", proc.stdout)
        self.assertIn("Gate 1 — Role-Playing Date FK Sanity: PASS", proc.stdout)
        self.assertIn("Gate 2 — Attribute & ETL Logic Parity: PASS", proc.stdout)
        self.assertIn("Gate 3 — 3-Way Orphan Entity: PASS", proc.stdout)
        self.assertIn("Gate 4 — Flat Table Delivery: PASS", proc.stdout)

    def test_05_cli_common_skips_gates_and_passes_exit_code_0(self):
        """CLI: run_quality_gates.py -m Common returns exit code 0, skips Gates 2&3, passes Gates 1&4."""
        cmd = [
            sys.executable,
            str(RUN_QUALITY_GATES_SCRIPT),
            "-m", "Common",
            "--root", str(REPO_ROOT),
        ]
        proc = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(proc.returncode, 0, f"Common runner failed: {proc.stderr or proc.stdout}")
        self.assertIn("ALL GATES PASSED", proc.stdout)
        self.assertIn("Gate 1 — Role-Playing Date FK Sanity: PASS", proc.stdout)
        self.assertIn("Gate 2 — Attribute & ETL Logic Parity: SKIP", proc.stdout)
        self.assertIn("Gate 3 — 3-Way Orphan Entity: SKIP", proc.stdout)
        self.assertIn("Gate 4 — Flat Table Delivery: PASS", proc.stdout)

    def test_06_cli_strict_flag_enforcement_on_clean_modules(self):
        """CLI: --strict flag succeeds with exit code 0 on GSTT and Common."""
        for mod in ["GSTT", "Common"]:
            cmd = [
                sys.executable,
                str(RUN_QUALITY_GATES_SCRIPT),
                "-m", mod,
                "--root", str(REPO_ROOT),
                "--strict",
            ]
            proc = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
            self.assertEqual(proc.returncode, 0, f"Module {mod} failed under --strict: {proc.stdout}")

    def test_07_cli_json_structured_output_gstt(self):
        """CLI: --json flag produces structured JSON with overall_status PASS and 4 gate results for GSTT."""
        cmd = [
            sys.executable,
            str(RUN_QUALITY_GATES_SCRIPT),
            "-m", "GSTT",
            "--root", str(REPO_ROOT),
            "--json",
        ]
        proc = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(proc.returncode, 0)
        data = json.loads(proc.stdout)

        self.assertIn("overall_status", data)
        self.assertEqual(data["overall_status"], "PASS")
        self.assertIn("modules", data)
        self.assertIn("GSTT", data["modules"])

        gstt_gates = data["modules"]["GSTT"]
        self.assertEqual(len(gstt_gates), 4)
        for g in gstt_gates:
            self.assertIn("gate", g)
            self.assertIn("name", g)
            self.assertIn("status", g)
            self.assertIn("exit_code", g)
            self.assertEqual(g["status"], "PASS")
            self.assertEqual(g["exit_code"], 0)

    def test_08_cli_json_structured_output_common(self):
        """CLI: --json flag produces structured JSON with SKIP status for Gates 2 & 3 on Common."""
        cmd = [
            sys.executable,
            str(RUN_QUALITY_GATES_SCRIPT),
            "-m", "Common",
            "--root", str(REPO_ROOT),
            "--json",
        ]
        proc = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(proc.returncode, 0)
        data = json.loads(proc.stdout)

        self.assertEqual(data["overall_status"], "PASS")
        self.assertIn("Common", data["modules"])
        common_gates = {g["gate"]: g for g in data["modules"]["Common"]}

        self.assertEqual(common_gates["Gate 1"]["status"], "PASS")
        self.assertEqual(common_gates["Gate 2"]["status"], "SKIP")
        self.assertEqual(common_gates["Gate 3"]["status"], "SKIP")
        self.assertEqual(common_gates["Gate 4"]["status"], "PASS")

    def test_09_cli_exit_code_1_on_failed_gate(self):
        """CLI: Exits with code 1 when a gate fails (e.g. TT fails Gate 1 Date FK under --strict)."""
        cmd = [
            sys.executable,
            str(RUN_QUALITY_GATES_SCRIPT),
            "-m", "TT",
            "--root", str(REPO_ROOT),
            "--strict",
        ]
        proc = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(proc.returncode, 1, "Must exit with code 1 when a gate fails")
        self.assertIn("ONE OR MORE GATES FAILED", proc.stdout)


class TestPendingClassifierFiveCategories(unittest.TestCase):
    """Verifies that PendingClassifier implements exactly the 5 standardized PENDING categories."""

    def test_10_five_standard_categories_defined(self):
        """PendingClassifier defines exactly the 5 standard categories, and Reason 6 is eliminated/aliased."""
        # Official 5 reasons
        self.assertEqual(PendingClassifier.REASON_BA_PENDING, "1. BA chưa mapping xong")
        self.assertEqual(PendingClassifier.REASON_NO_BA_SOURCE, "2. Chưa có mapping nguồn từ BA")
        self.assertEqual(PendingClassifier.REASON_EXTERNAL_SOURCE, "3. Thiếu nguồn dữ liệu / Atomic entity ngoài scope")
        self.assertEqual(PendingClassifier.REASON_COMPLEX_JOIN, "4. Cần join phức tạp đa nguồn")
        self.assertEqual(PendingClassifier.REASON_DATAMART_PENDING, "5. Datamart chưa thiết kế Fact/Dim")

        # Reason 6 is eliminated and aliases to Reason 3
        self.assertEqual(
            PendingClassifier.REASON_SCHEMA_OUT_OF_SYNC,
            PendingClassifier.REASON_EXTERNAL_SOURCE,
            "Legacy Reason 6 must be an alias resolving to Reason 3",
        )

        all_reasons = [
            PendingClassifier.REASON_BA_PENDING,
            PendingClassifier.REASON_NO_BA_SOURCE,
            PendingClassifier.REASON_EXTERNAL_SOURCE,
            PendingClassifier.REASON_COMPLEX_JOIN,
            PendingClassifier.REASON_DATAMART_PENDING,
        ]
        # Exactly 5 unique strings
        self.assertEqual(len(set(all_reasons)), 5)

    def test_11_category_1_ba_pending_logic(self):
        """Category 1: Any BA status not Done/Hoàn thành is classified as BA chưa mapping xong."""
        test_statuses = ["Pending", "Doing", "Draft", "In Progress", "Failed", "", None, "   "]
        for st in test_statuses:
            res = PendingClassifier.classify(
                kpi_name="K_TEST_1",
                ba_status=st,
                ba_source="some_table",
                ba_data_type="Decimal",
            )
            self.assertEqual(res, PendingClassifier.REASON_BA_PENDING, f"Failed for status: '{st}'")

    def test_12_category_2_no_ba_source_logic(self):
        """Category 2: BA status Done but source is empty, N/A, 'chưa có CSDL', or paper form."""
        test_sources = ["", "N/A", "(trống)", "NULL", "none", "chưa có", "chưa có CSDL", "chưa có nguồn"]
        for src in test_sources:
            res = PendingClassifier.classify(
                kpi_name="K_TEST_2",
                ba_status="Done",
                ba_source=src,
                ba_data_type="Decimal",
            )
            self.assertEqual(res, PendingClassifier.REASON_NO_BA_SOURCE, f"Failed for source: '{src}'")

        # Via ghi_chu or data_type
        res_note = PendingClassifier.classify(
            kpi_name="K_TEST_2B",
            ba_status="Done",
            ba_source="table_x",
            ba_data_type="Decimal",
            ghi_chu="biểu mẫu giấy chưa số hóa",
        )
        self.assertEqual(res_note, PendingClassifier.REASON_NO_BA_SOURCE)

    def test_13_category_3_external_source_and_schema_mismatch_logic(self):
        """Category 3: External sources (VSD, VSDC, SBV, HOSE, HNX) and schema/atomic gap cues."""
        external_sources = ["UAT_VSDC.listed_share", "vsdc_portfolio", "SBV_REPORT", "HOSE_INDEX", "HNX_TRADE"]
        for src in external_sources:
            res = PendingClassifier.classify(
                kpi_name="K_TEST_3",
                ba_status="Done",
                ba_source=src,
                ba_data_type="Decimal",
            )
            self.assertEqual(res, PendingClassifier.REASON_EXTERNAL_SOURCE, f"Failed for source: '{src}'")

        # Schema sync / Atomic unapproved cues merged into Category 3
        schema_notes = [
            "Atomic chưa approved",
            "bảng chưa duyệt",
            "schema out of sync",
            "mismatch giữa BA và Atomic",
            "lệch schema atomic",
        ]
        for note in schema_notes:
            res = PendingClassifier.classify(
                kpi_name="K_TEST_3B",
                ba_status="Done",
                ba_source="internal_tbl",
                ba_data_type="Decimal",
                ghi_chu=note,
            )
            self.assertEqual(res, PendingClassifier.REASON_EXTERNAL_SOURCE, f"Failed for note: '{note}'")

        # PA-05 rule: Group count mismatch alone preserves Category 5, not overriding to Category 3
        res_mismatch = PendingClassifier.classify(
            kpi_name="K_TEST_3C",
            ba_status="Done",
            ba_source="internal_tbl",
            ba_data_type="Decimal",
            has_count_mismatch=True,
        )
        self.assertEqual(res_mismatch, PendingClassifier.REASON_DATAMART_PENDING)

    def test_14_category_4_complex_multi_source_join_logic(self):
        """Category 4: Multi-system join requirements (SCMS + NHNCK, liên hệ thống, join đa nguồn)."""
        complex_joins = ["SCMS + NHNCK", "join đa nguồn", "scms_nhnck.tbl_bridge", "multi-source join", "liên hệ thống"]
        for src in complex_joins:
            res = PendingClassifier.classify(
                kpi_name="K_TEST_4",
                ba_status="Done",
                ba_source=src,
                ba_data_type="Decimal",
            )
            self.assertEqual(res, PendingClassifier.REASON_COMPLEX_JOIN, f"Failed for source: '{src}'")

    def test_15_category_5_datamart_pending_logic(self):
        """Category 5: BA Done, internal approved source available, no blockers -> Datamart pending."""
        res = PendingClassifier.classify(
            kpi_name="K_TEST_5",
            ba_status="Done",
            ba_source="IDS.SECURITIES_TRADE",
            ba_data_type="Decimal",
            ghi_chu="chờ thiết kế bảng Fact",
        )
        self.assertEqual(res, PendingClassifier.REASON_DATAMART_PENDING)


class TestDatamartReviewDocConsistency(unittest.TestCase):
    """Verifies complete documentation parity and integrity of the 21 standardized error codes."""

    EXPECTED_21_ERROR_CODES = [
        # Lớp 1 (HLD)
        "L1-GRAIN-MISMATCH",
        "L1/L2-DELETE-VIOLATION",
        # Lớp 2 (Attributes)
        "L2-DATE-FK-ROLE-PLAYING",
        "L2-ORPHAN-3WAY-INCOMPLETE",
        "L2-ORPHAN-3WAY-ABANDONED",
        "L2-ETL-LOGIC-PARITY-MISMATCH",
        "L2-SCD4A-TECH-FIELD",
        "L2-SCD4A-JOIN-FILTER",
        "L2-WINDOW-STORAGE-INVALID",
        # Lớp 3 (Detail Mapping)
        "L3-GRAIN-MISMATCH",
        "L3-FORMULA-WINDOW-MISMATCH",
        "L3-FINANCIAL-PERIOD-INCONSISTENT",
        "L3-PENDING-RULE-L4-VIOLATION",
        "L3-REUSE-INVALID",
        "L3-DEPRECATED-AS-PENDING",
        # Lớp 4 (Flat Table & Registry)
        "L4-MASTER-REGISTRY-OUT-OF-SYNC",
        "L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING",
        "L4-FLAT-TABLE-PROJECTION-MISALIGNMENT",
        "L4-FLAT-TABLE-COLUMN-DRIFT",
        "L4-FLAT-TABLE-PARAMETER-INCONSISTENT",
        "L4-COMMON-DIM-CLICKHOUSE-MISSING",
    ]

    def test_16_zero_occurrences_of_6_nhanh_or_6_nhom_in_all_docs(self):
        """Zero occurrences of '6 nhánh' or '6 nhóm' across all markdown files in datamart-review."""
        md_files = list(SKILL_DIR.glob("**/*.md"))
        self.assertGreaterEqual(len(md_files), 5, "Must inspect all skill documentation markdown files")

        pattern = re.compile(r"6\s*(?:nhánh|nhóm)", re.IGNORECASE)
        violations = []
        for f in md_files:
            text = f.read_text(encoding="utf-8", errors="replace")
            matches = list(pattern.finditer(text))
            if matches:
                violations.append((str(f.relative_to(REPO_ROOT)), len(matches)))

        self.assertEqual(
            violations, [],
            f"Found legacy '6 nhánh' or '6 nhóm' occurrences in: {violations}",
        )

    def test_17_all_21_standardized_error_codes_in_matrix_table(self):
        """Master matrix table in issue_classification.md contains all 21 standardized error codes."""
        doc_path = SKILL_DIR / "reference" / "issue_classification.md"
        self.assertTrue(doc_path.exists(), "issue_classification.md must exist")

        content = doc_path.read_text(encoding="utf-8", errors="replace")
        missing_in_matrix = []
        for code in self.EXPECTED_21_ERROR_CODES:
            # Code must appear in the markdown table row: | `L...` |
            table_entry = f"`{code}`"
            if table_entry not in content:
                missing_in_matrix.append(code)

        self.assertEqual(
            missing_in_matrix, [],
            f"Missing error codes from issue_classification.md master matrix: {missing_in_matrix}",
        )
        self.assertEqual(len(self.EXPECTED_21_ERROR_CODES), 21)

    def test_18_all_21_error_codes_have_detailed_specification_cards(self):
        """Each of the 21 error codes has a dedicated detailed specification card in Section 3."""
        doc_path = SKILL_DIR / "reference" / "issue_classification.md"
        content = doc_path.read_text(encoding="utf-8", errors="replace")

        missing_spec_cards = []
        for code in self.EXPECTED_21_ERROR_CODES:
            # Card header format: `#### ... [Mã lỗi] ...` or table row: `**Mã lỗi (Error Code)** | ... `code` ...`
            pattern = rf"\*\*Mã lỗi \(Error Code\)\*\*\s*\|[^|\n]*`{re.escape(code)}`"
            if not re.search(pattern, content):
                missing_spec_cards.append(code)

        self.assertEqual(
            missing_spec_cards, [],
            f"Missing detailed specification card for error codes: {missing_spec_cards}",
        )

    def test_19_cross_doc_reference_links_validity(self):
        """All file references across SKILL.md and reference docs point to existing files."""
        key_docs = [
            SKILL_DIR / "SKILL.md",
            SKILL_DIR / "reference" / "review_checklist.md",
            SKILL_DIR / "reference" / "technical_review_rules.md",
            SKILL_DIR / "reference" / "issue_classification.md",
            SKILL_DIR / "reference" / "kpi_reconciliation_rules.md",
        ]
        for doc in key_docs:
            self.assertTrue(doc.exists(), f"Key document missing: {doc}")
            content = doc.read_text(encoding="utf-8", errors="replace")
            # Find relative file paths like reference/... or scripts/...
            ref_matches = re.findall(r"(?:reference|scripts)/[a-zA-Z0-9_\-.]+\.(?:md|py|yaml)", content)
            for ref in ref_matches:
                target = SKILL_DIR / ref
                self.assertTrue(target.exists(), f"Broken reference in {doc.name}: {ref} does not exist at {target}")


if __name__ == "__main__":
    unittest.main()
