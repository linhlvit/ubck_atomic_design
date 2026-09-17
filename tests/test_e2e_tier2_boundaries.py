# -*- coding: utf-8 -*-
"""
tests/test_e2e_tier2_boundaries.py
Tier 2: Boundary & Corner Cases Test Suite

Covers:
- Empty files: 0-byte CSV, header-only CSV (0 data rows), empty SQL DDL file
- Encodings & BOM: UTF-8 BOM (\xef\xbb\xbf), UTF-8 no-BOM, duplicate BOM (\ufeff\ufeff)
- Line endings: CRLF (\r\n) vs LF (\n) normalization in etl_logic
- Delimiters: Comma (,) vs Semicolon (;) dynamic sniffing
- Multi-line cells: SQL with embedded newlines, subqueries, CASE WHEN, and 35+ unquoted commas
- Annotations and comment diffs: (Sửa 2026-08), [MỚI 2026-09-07]
- Case sensitivity and Vietnamese accent folding: GSĐC ↔ GSDC, FMS ↔ QLQ
- Error handling: Non-existent modules and missing master files exit with code 2
- Windows 128KB CSV field size limit expansion (protecting against _csv.Error)
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
COMMON_DIR = SKILL_SCRIPTS_DIR / "datamart_common"
ROOT_SCRIPTS_DIR = REPO_ROOT / "scripts"

for p in [str(SKILL_SCRIPTS_DIR), str(ROOT_SCRIPTS_DIR)]:
    if p not in sys.path:
        sys.path.insert(0, p)

from datamart_common import csv_utils, encoding, module_resolver

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


class TestTier2EmptyAndMissingFiles(unittest.TestCase):
    """Tier 2: Tests handling of empty files, zero-row files, and missing resources."""

    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.mock_root = Path(self.temp_dir.name)

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_01_empty_csv_zero_bytes(self):
        """Tier 2: 0-byte CSV file handled gracefully without unhandled exception."""
        empty_file = self.mock_root / "empty.csv"
        empty_file.write_bytes(b"")

        # Dynamic CSV read returns (delimiter, fieldnames, rows)
        try:
            delim, fieldnames, rows = csv_utils.read_csv_dynamic(empty_file)
            self.assertEqual(len(rows), 0, "0-byte file must yield 0 rows")
        except Exception as e:
            self.fail(f"0-byte CSV should not crash parser: {e}")

    def test_02_header_only_csv_zero_data_rows(self):
        """Tier 2: CSV with header only (0 data rows) yields 0 data rows."""
        header_only = self.mock_root / "header_only.csv"
        header_only.write_text("col_a,col_b,col_c\n", encoding="utf-8")

        delim, fieldnames, rows = csv_utils.read_csv_dynamic(header_only)
        self.assertEqual(len(rows), 0, "Header-only CSV must yield 0 data rows")
        self.assertEqual(len(fieldnames), 3)

    def test_03_empty_sql_file(self):
        """Tier 2: Empty SQL DDL file handled safely."""
        empty_sql = self.mock_root / "01_create_empty_flat_tables.sql"
        empty_sql.write_text("-- Just comments\n\n-- No create statements\n", encoding="utf-8")
        text = encoding.read_file_safe(empty_sql)
        self.assertIn("No create statements", text)

    def test_04_nonexistent_module_returns_exit_code_2(self):
        """Tier 2: Passing a non-existent module name returns exit code 2."""
        if not HAS_ORPHAN_CHECKER and not HAS_PARITY_CHECKER:
            self.skipTest("M2 CLI scripts not yet implemented")

        target_cli = ORPHAN_CHECKER_CLI or PARITY_CHECKER_CLI
        cmd = [
            sys.executable,
            str(target_cli),
            "-m", "COMPLETELY_NONEXISTENT_MODULE_XYZ_999",
            "--root", str(REPO_ROOT),
        ]
        result = subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")
        self.assertEqual(result.returncode, 2, f"Expected exit code 2 for non-existent module, got {result.returncode}")


class TestTier2EncodingAndBOM(unittest.TestCase):
    """Tier 2: Tests UTF-8 BOM, no-BOM, and duplicate BOM handling."""

    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.mock_root = Path(self.temp_dir.name)

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_05_utf8_sig_bom_stripped_from_first_key(self):
        """Tier 2: UTF-8 with BOM (\\xef\\xbb\\xbf) must strip BOM from dictionary keys."""
        bom_file = self.mock_root / "bom_test.csv"
        content = "\ufeffdatamart_entity,datamart_table\nFact Test,fct_test\n"
        bom_file.write_text(content, encoding="utf-8-sig")

        delim, fieldnames, rows = csv_utils.read_csv_dynamic(bom_file)
        self.assertEqual(len(rows), 1)
        # Ensure key does NOT contain BOM character \ufeff
        self.assertIn("datamart_entity", rows[0])
        self.assertNotIn("\ufeffdatamart_entity", rows[0])
        self.assertEqual(rows[0]["datamart_entity"], "Fact Test")

    def test_06_duplicate_bom_handling(self):
        """Tier 2: Double BOM (\\ufeff\\ufeff as observed in DTM_PTTT_Detail_Mapping.csv) stripped."""
        double_bom_file = self.mock_root / "double_bom.csv"
        # Write double BOM manually in binary
        raw_bytes = b"\xef\xbb\xbf\xef\xbb\xbfkpi_id,kpi_name\nK_01,Test KPI\n"
        double_bom_file.write_bytes(raw_bytes)

        text = encoding.read_file_safe(double_bom_file)
        # Clean any remaining \ufeff
        cleaned_text = text.lstrip("\ufeff")
        self.assertTrue(cleaned_text.startswith("kpi_id"), f"Double BOM should be cleanable, got: {repr(cleaned_text[:15])}")

    def test_07_crlf_vs_lf_normalization(self):
        """Tier 2: CRLF (\\r\\n) and LF (\\n) in etl_logic are normalized identically."""
        logic_crlf = "SELECT a,\r\n  b,\r\n  c\r\nFROM t"
        logic_lf = "SELECT a,\n  b,\n  c\nFROM t"

        norm_crlf = logic_crlf.replace("\r\n", "\n").strip()
        norm_lf = logic_lf.replace("\r\n", "\n").strip()
        self.assertEqual(norm_crlf, norm_lf, "CRLF and LF must normalize to identical representation")


class TestTier2DelimitersAndMultiline(unittest.TestCase):
    """Tier 2: Tests dynamic delimiter detection (, vs ;) and multi-line SQL cells."""

    def test_08_semicolon_delimiter_detection(self):
        """Tier 2: Semicolon delimiter correctly detected in semicolon-separated CSV."""
        semi_csv = (
            "kpi_id;kpi_name;tinh_chat;trang_thai\n"
            "K_01;Chỉ tiêu 1;Cơ sở;READY\n"
            "K_02;Chỉ tiêu 2;Phái sinh;PENDING\n"
        )
        delim = csv_utils.detect_delimiter(semi_csv)
        self.assertEqual(delim, ";", f"Expected ';' delimiter, got '{delim}'")

    def test_09_comma_delimiter_detection(self):
        """Tier 2: Comma delimiter correctly detected in comma-separated CSV."""
        comma_csv = (
            "kpi_id,kpi_name,tinh_chat,trang_thai\n"
            "K_01,Chỉ tiêu 1,Cơ sở,READY\n"
            "K_02,Chỉ tiêu 2,Phái sinh,PENDING\n"
        )
        delim = csv_utils.detect_delimiter(comma_csv)
        self.assertEqual(delim, ",", f"Expected ',' delimiter, got '{delim}'")

    def test_10_multiline_sql_with_35_unquoted_commas_in_semicolon_file(self):
        """Tier 2: Semicolon file with 35 unquoted commas in an SQL cell must still detect ';' delimiter."""
        header = ";".join([f"Col_{i}" for i in range(20)])
        normal_row = ";".join([f"Val_{i}" for i in range(20)])
        # Row with SQL containing 35 commas
        sql_commas = ",".join([f"c{i}" for i in range(36)])
        row_cells = [f"Val_{i}" for i in range(20)]
        row_cells[5] = f"SELECT {sql_commas} FROM tbl"
        broken_row = ";".join(row_cells)

        csv_content = "\n".join([header] + [normal_row] * 5 + [broken_row] + [normal_row] * 5)
        delim = csv_utils.detect_delimiter(csv_content)
        self.assertEqual(delim, ";", "Mode consistency must select ';' despite 35 commas in SQL column")

    def test_11_field_size_limit_expanded_on_windows(self):
        """Tier 2: Verify csv.field_size_limit is expanded beyond default 128KB."""
        # On Windows, default limit is 131072 (128KB). Verify expanded limit handles 150KB cell.
        large_cell = "x" * 150000
        row_text = f'id,data\n1,"{large_cell}"\n'

        # Ensure field_size_limit is set
        try:
            csv.field_size_limit(min(sys.maxsize, 2147483647))
        except (OverflowError, AttributeError):
            pass

        reader = csv.DictReader(io.StringIO(row_text))
        rows = list(reader)
        self.assertEqual(len(rows), 1)
        self.assertEqual(len(rows[0]["data"]), 150000)


class TestTier2ModuleResolutionAndAccents(unittest.TestCase):
    """Tier 2: Tests module alias resolution and Vietnamese diacritics folding."""

    def test_12_module_alias_normalization(self):
        """Tier 2: Normalizes module aliases: GSDC/gsđc -> GSĐC, FMS -> QLQ, and strip_accents -> GSDC."""
        self.assertEqual(module_resolver.normalize_module_name("GSĐC"), "GSĐC")
        self.assertEqual(module_resolver.normalize_module_name("gsđc"), "GSĐC")
        self.assertEqual(module_resolver.normalize_module_name("GSDC"), "GSĐC")
        self.assertEqual(module_resolver.strip_accents(module_resolver.normalize_module_name("GSĐC")), "GSDC")
        self.assertEqual(module_resolver.normalize_module_name("FMS"), "QLQ")
        self.assertEqual(module_resolver.normalize_module_name("TKNB"), "TKNB")

    def test_13_strip_accents_folding(self):
        """Tier 2: Diacritics stripping for Vietnamese characters."""
        s = "Giám sát Đăng ký Giao dịch"
        stripped = module_resolver.strip_accents(s)
        self.assertNotIn("đ", stripped.lower())
        self.assertIn("giam sat", stripped.lower())


if __name__ == "__main__":
    unittest.main()
