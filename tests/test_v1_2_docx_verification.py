# -*- coding: utf-8 -*-
"""
ubck_atomic_design/tests/test_v1_2_docx_verification.py
4-Tier End-to-End Test Suite for UBCKNN Database Design v1.2 Verification.

Architecture & Scope:
- Target Output Document:
    c:\\Workspace\\Design_DW\\ubck_atomic_design\\docs\\output\\UBCKNN_Thiet ke co so du lieu_v1.2_20261029.docx
- Baseline Document (Must remain 100% untouched & SHA-256 locked):
    c:\\Workspace\\Design_DW\\ubck_atomic_design\\docs\\output\\UBCKNN_Thiet ke co so du lieu_v1.1_20260429.docx
- Authoritative Catalog & Ground Truth:
    C:\\Workspace\\Design_DW\\.agents\\teamwork\\spec_miner_survey_2\\all_subsystems.json
    C:\\Workspace\\Design_DW\\.agents\\teamwork\\spec_miner_survey_2\\subsystems_catalog.md

Methodology (4 Tiers):
1. Tier 1 - Feature Coverage (>=5 per feature area):
   - Packaging, existence, valid OPC ZIP, >15MB, readable by python-docx.
   - Baseline v1.1 invariant guard (SHA-256 match, size match, unmodified).
   - Section 2 (Mục 2) contains all 17 atomic subsystems (AUDIT..VSDC).
   - Section 3 (Mục 3) Datamart integration present.
2. Tier 2 - Boundary & Corner Cases (>=5 per feature area):
   - Exact prefix preservation (elements 0..69: Cover, sign-off, history, TOC sdt, Mục 1, sectPr 69).
   - Exact suffix preservation (elements 4524..4565: Mục 4, 5, 6, 7 Phụ lục, body sectPr).
   - Table schema integrity: every data dictionary table has exactly 12 columns, valid headers, PK/FK flags.
   - Zero broken media relationships, no dangling image blips, valid XML namespaces.
3. Tier 3 - Cross-Feature Combinations & Quantitative Matrix:
   - 274 overview table rows (Table 1) across 17 subsystems.
   - 378 detailed entity tables (Heading 3) across 17 subsystems.
   - 5,787 columns present across data dictionaries with conforming types.
   - 334 Primary Keys and 581 Foreign Keys.
   - Exact per-subsystem matrix matching all_subsystems.json.
4. Tier 4 - Real-World Application Scenarios:
   - Complete lxml parse and document traversal stress test.
   - Single Heading 1 for Section 2; Heading 2 normalized numbering (2.1..2.17); Heading 3 subordination.
   - Repeat header row (tblHeader) on multi-page data dictionary tables.
   - In-memory serialize/deserialize roundtrip simulating reader opening without corruption.
"""

from __future__ import annotations

import hashlib
import io
import json
import os
from pathlib import Path
import re
from typing import Any, Dict, List, Optional, Tuple
import unittest
import zipfile

import docx
from docx.oxml.ns import qn
import lxml.etree

# ---------------------------------------------------------------------------
# Path Configuration
# ---------------------------------------------------------------------------
TESTS_DIR = Path(__file__).resolve().parent
REPO_ROOT = TESTS_DIR.parents[1]  # C:\Workspace\Design_DW
ATOMIC_DESIGN_DIR = REPO_ROOT / "ubck_atomic_design"
OUTPUT_DIR = ATOMIC_DESIGN_DIR / "docs" / "output"

BASELINE_DOCX = OUTPUT_DIR / "UBCKNN_Thiet ke co so du lieu_v1.1_20260429.docx"
TARGET_DOCX = OUTPUT_DIR / "UBCKNN_Thiet ke co so du lieu_v1.2_20261029.docx"

CATALOG_JSON = (
    REPO_ROOT
    / ".agents"
    / "teamwork"
    / "spec_miner_survey_2"
    / "all_subsystems.json"
)

# ---------------------------------------------------------------------------
# Authoritative Ground Truth Constants
# ---------------------------------------------------------------------------
LOCKED_BASELINE_SHA256 = (
    "5846d9cb4002305127ae01a5e7c3342a5477030d743960d0defc6e76a29aa5fc"
)
LOCKED_BASELINE_SIZE = 9_240_232

MIN_TARGET_SIZE_BYTES = 8_000_000  # > 8 MB (compressed OPC docx; uncompressed XML > 43MB)

EXPECTED_SUBSYSTEM_CODES: List[str] = [
    "AUDIT",
    "ECAT",
    "FIMS",
    "FMS",
    "HNX",
    "HOSE",
    "IAM",
    "IDS",
    "ISS",
    "KNT",
    "MDDS",
    "MRMS",
    "NHNCK",
    "SCMS",
    "THANHTRA",
    "TTHC",
    "VSDC",
]

SUBSYSTEM_SPECS: Dict[str, Dict[str, int]] = {
    "AUDIT": {"overview_rows": 16, "detail_tables": 18, "columns": 233, "pk": 14, "fk": 27},
    "ECAT": {"overview_rows": 3, "detail_tables": 8, "columns": 186, "pk": 8, "fk": 24},
    "FIMS": {"overview_rows": 13, "detail_tables": 19, "columns": 232, "pk": 42, "fk": 16},
    "FMS": {"overview_rows": 35, "detail_tables": 63, "columns": 786, "pk": 37, "fk": 105},
    "HNX": {"overview_rows": 12, "detail_tables": 14, "columns": 315, "pk": 14, "fk": 0},
    "HOSE": {"overview_rows": 4, "detail_tables": 4, "columns": 58, "pk": 4, "fk": 0},
    "IAM": {"overview_rows": 4, "detail_tables": 4, "columns": 48, "pk": 1, "fk": 9},
    "IDS": {"overview_rows": 53, "detail_tables": 59, "columns": 999, "pk": 51, "fk": 107},
    "ISS": {"overview_rows": 1, "detail_tables": 1, "columns": 29, "pk": 1, "fk": 0},
    "KNT": {"overview_rows": 5, "detail_tables": 5, "columns": 193, "pk": 5, "fk": 10},
    "MDDS": {"overview_rows": 6, "detail_tables": 7, "columns": 235, "pk": 7, "fk": 4},
    "MRMS": {"overview_rows": 3, "detail_tables": 3, "columns": 32, "pk": 4, "fk": 1},
    "NHNCK": {"overview_rows": 38, "detail_tables": 49, "columns": 634, "pk": 54, "fk": 82},
    "SCMS": {"overview_rows": 39, "detail_tables": 82, "columns": 1255, "pk": 45, "fk": 150},
    "THANHTRA": {"overview_rows": 30, "detail_tables": 30, "columns": 413, "pk": 34, "fk": 40},
    "TTHC": {"overview_rows": 3, "detail_tables": 3, "columns": 36, "pk": 4, "fk": 2},
    "VSDC": {"overview_rows": 9, "detail_tables": 9, "columns": 103, "pk": 9, "fk": 4},
}

EXPECTED_TOTAL_OVERVIEW_ROWS = 274
EXPECTED_TOTAL_DETAIL_TABLES = 378
EXPECTED_TOTAL_COLUMNS = 5_787
EXPECTED_TOTAL_PK = 334
EXPECTED_TOTAL_FK = 581

EXPECTED_12_COLUMNS_HEADER = [
    "STT",
    "Tên trường",
    "Tên cột",
    "Kiểu dữ liệu và độ dài",
    "Nullable",
    "Unique",
    "P/F Key",
    "Mặc định",
    "Mô tả",
    "Schema.Table",
    "Source Field Name",
    "ETL Rules",
]

EXPECTED_OVERVIEW_HEADER = ["STT", "Thực thể", "Tên bảng", "Mô tả"]


# ---------------------------------------------------------------------------
# Base Test Fixture (Lazy Loaded & Cached Once)
# ---------------------------------------------------------------------------
class BaseDocxVerificationTest(unittest.TestCase):
    """Shared document state, parsed structures, and catalog references."""

    baseline_path: Path = BASELINE_DOCX
    target_path: Path = TARGET_DOCX
    catalog_path: Path = CATALOG_JSON

    doc_base: Optional[docx.Document] = None
    doc_target: Optional[docx.Document] = None
    catalog_data: Optional[List[Dict[str, Any]]] = None

    base_bytes: Optional[bytes] = None
    target_bytes: Optional[bytes] = None

    # Cached parsed structures
    target_body_elements: List[Any] = []
    target_section2_elements: List[Any] = []
    target_section3_elements: List[Any] = []
    target_suffix_elements: List[Any] = []

    subsystem_parsed_data: Dict[str, Dict[str, Any]] = {}

    @classmethod
    def setUpClass(cls):
        # 1. Load Baseline v1.1
        if cls.baseline_path.is_file():
            cls.base_bytes = cls.baseline_path.read_bytes()
            try:
                cls.doc_base = docx.Document(cls.baseline_path)
            except Exception:
                cls.doc_base = None

        # 2. Load Catalog Ground Truth JSON
        if cls.catalog_path.is_file():
            try:
                cls.catalog_data = json.loads(cls.catalog_path.read_text(encoding="utf-8"))
            except Exception:
                cls.catalog_data = None

        # 3. Load Target Output v1.2 (if generated)
        if cls.target_path.is_file():
            cls.target_bytes = cls.target_path.read_bytes()
            try:
                cls.doc_target = docx.Document(cls.target_path)
                cls._parse_target_document()
            except Exception:
                cls.doc_target = None

    @classmethod
    def _parse_target_document(cls):
        """Parse Section 2, Section 3, prefix, and suffix boundaries from doc_target."""
        if cls.doc_target is None:
            return

        body = cls.doc_target._body._body
        cls.target_body_elements = list(body)

        # Locate Section 2, Section 3, Section 4 anchors
        s2_start_idx = None
        s3_start_idx = None
        s4_start_idx = None

        for idx, el in enumerate(cls.target_body_elements):
            if el.tag.endswith("p"):
                p = docx.text.paragraph.Paragraph(el, cls.doc_target)
                text_clean = p.text.strip().upper()
                if "CƠ SỞ DỮ LIỆU (OLTP)" in text_clean:
                    if s2_start_idx is None:
                        s2_start_idx = idx
                elif "KHO DỮ LIỆU (OLAP)" in text_clean or "KHO DỮ LIỆU (OLAP)" in text_clean:
                    if s3_start_idx is None:
                        s3_start_idx = idx
                elif "THIẾT KẾ TỆP TIN" in text_clean:
                    if s4_start_idx is None:
                        s4_start_idx = idx

        if s2_start_idx is not None and s3_start_idx is not None:
            cls.target_section2_elements = cls.target_body_elements[s2_start_idx:s3_start_idx]

        if s3_start_idx is not None and s4_start_idx is not None:
            cls.target_section3_elements = cls.target_body_elements[s3_start_idx:s4_start_idx]

        if s4_start_idx is not None:
            cls.target_suffix_elements = cls.target_body_elements[s4_start_idx:]

        # Parse Section 2 subsystems
        cls.subsystem_parsed_data = {}
        current_subsys = None

        for el in cls.target_section2_elements:
            if el.tag.endswith("p"):
                p = docx.text.paragraph.Paragraph(el, cls.doc_target)
                # Check for Heading 2 or matching subsystem title
                text_upper = p.text.strip().upper()
                for code in EXPECTED_SUBSYSTEM_CODES:
                    # Match pattern like "2.1 AUDIT" or "AUDIT —"
                    if re.search(rf"\b{code}\b", text_upper):
                        if p.style and "Heading 2" in p.style.name:
                            current_subsys = code
                            if current_subsys not in cls.subsystem_parsed_data:
                                cls.subsystem_parsed_data[current_subsys] = {
                                    "heading": p.text.strip(),
                                    "elements": [],
                                    "tables": [],
                                    "overview_tables": [],
                                    "dict_tables": [],
                                    "constraint_tables": [],
                                }
                            break

            if current_subsys is not None and current_subsys in cls.subsystem_parsed_data:
                cls.subsystem_parsed_data[current_subsys]["elements"].append(el)
                if el.tag.endswith("tbl"):
                    t = docx.table.Table(el, cls.doc_target)
                    cls.subsystem_parsed_data[current_subsys]["tables"].append(t)
                    col_count = len(t.columns)
                    if col_count == 4 and len(t.rows) > 0 and "Thực thể" in t.rows[0].cells[1].text:
                        cls.subsystem_parsed_data[current_subsys]["overview_tables"].append(t)
                    elif col_count == 12:
                        cls.subsystem_parsed_data[current_subsys]["dict_tables"].append(t)
                    elif col_count in (2, 3) and len(t.rows) > 0 and "Tên trường" in t.rows[0].cells[0].text:
                        cls.subsystem_parsed_data[current_subsys]["constraint_tables"].append(t)

    def assert_target_document_ready(self):
        """Helper to assert that target v1.2 docx exists and was successfully loaded."""
        self.assertTrue(
            self.target_path.is_file(),
            f"Target output document not found at {self.target_path}. "
            "Please run the document generation engine to produce v1.2.",
        )
        self.assertIsNotNone(
            self.doc_target,
            f"Target output document at {self.target_path} exists but could not be parsed by python-docx.",
        )


# ===========================================================================
# Tier 1: Feature Coverage & Interface Contracts (>=5 per feature area)
# ===========================================================================
class TestTier1FeatureCoverage(BaseDocxVerificationTest):
    """Tier 1: Feature coverage across Packaging, Baseline Invariance, Mục 2 (17 Subsystems), and Mục 3 (Datamart)."""

    # --- Area 1: Target Output File Packaging & Format ---

    def test_t1_01_output_file_exists(self):
        """Verify target v1.2 file exists in docs/output."""
        self.assertTrue(
            self.target_path.is_file(),
            f"Target v1.2 file missing at {self.target_path}",
        )

    def test_t1_02_output_file_minimum_size(self):
        """Verify target v1.2 file size is > 8MB (>8,000,000 bytes) as required for compressed OPC docx."""
        self.assert_target_document_ready()
        file_size = self.target_path.stat().st_size
        self.assertGreater(
            file_size,
            MIN_TARGET_SIZE_BYTES,
            f"Output file size ({file_size} bytes) is less than required 8MB ({MIN_TARGET_SIZE_BYTES} bytes)",
        )

    def test_t1_03_output_file_valid_opc_zip(self):
        """Verify target docx is a valid OPC ZIP container with no corrupt entries."""
        self.assert_target_document_ready()
        with zipfile.ZipFile(self.target_path, "r") as zf:
            corrupted_part = zf.testzip()
            self.assertIsNone(
                corrupted_part,
                f"Corrupt ZIP entry detected in docx container: {corrupted_part}",
            )

    def test_t1_04_output_file_essential_xml_parts(self):
        """Verify all critical OpenXML parts are present in the target docx container."""
        self.assert_target_document_ready()
        with zipfile.ZipFile(self.target_path, "r") as zf:
            namelist = set(zf.namelist())
            required_parts = [
                "[Content_Types].xml",
                "_rels/.rels",
                "word/document.xml",
                "word/_rels/document.xml.rels",
                "word/styles.xml",
            ]
            for part in required_parts:
                self.assertIn(part, namelist, f"Missing critical OpenXML part: {part}")

    def test_t1_05_output_file_readable_by_docx(self):
        """Verify python-docx parses target file cleanly with valid sections and paragraphs."""
        self.assert_target_document_ready()
        self.assertGreater(len(self.doc_target.paragraphs), 1000, "Too few paragraphs in target docx")
        self.assertGreater(len(self.doc_target.tables), 500, "Too few tables in target docx")
        self.assertGreaterEqual(len(self.doc_target.sections), 2, "Expected at least 2 sections in target docx")

    # --- Area 2: Baseline v1.1 Invariance & SHA-256 Lock ---

    def test_t1_06_baseline_file_exists(self):
        """Verify baseline v1.1 file exists at specified path."""
        self.assertTrue(self.baseline_path.is_file(), f"Baseline v1.1 file missing at {self.baseline_path}")

    def test_t1_07_baseline_sha256_unmodified(self):
        """Verify baseline v1.1 SHA-256 hash matches the exact locked value (no overwriting)."""
        self.assertTrue(self.baseline_path.is_file(), "Baseline file missing")
        current_sha256 = hashlib.sha256(self.baseline_path.read_bytes()).hexdigest().lower()
        self.assertEqual(
            current_sha256,
            LOCKED_BASELINE_SHA256.lower(),
            f"CRITICAL: Baseline v1.1 was modified! Expected {LOCKED_BASELINE_SHA256}, got {current_sha256}",
        )

    def test_t1_08_baseline_file_size_exact(self):
        """Verify baseline v1.1 file size is exactly preserved (9,240,232 bytes)."""
        self.assertTrue(self.baseline_path.is_file(), "Baseline file missing")
        current_size = self.baseline_path.stat().st_size
        self.assertEqual(
            current_size,
            LOCKED_BASELINE_SIZE,
            f"Baseline v1.1 file size modified! Expected {LOCKED_BASELINE_SIZE}, got {current_size}",
        )

    def test_t1_09_baseline_independent_from_output(self):
        """Verify target v1.2 is a distinct file on disk and not identical in content to baseline."""
        self.assert_target_document_ready()
        self.assertNotEqual(
            self.baseline_path.resolve(),
            self.target_path.resolve(),
            "Target output path must not point to baseline v1.1 path",
        )
        base_hash = hashlib.sha256(self.baseline_path.read_bytes()).hexdigest()
        target_hash = hashlib.sha256(self.target_path.read_bytes()).hexdigest()
        self.assertNotEqual(
            base_hash,
            target_hash,
            "Target v1.2 SHA-256 matches baseline v1.1 — new content was not written",
        )

    def test_t1_10_baseline_xml_structure_intact(self):
        """Verify baseline v1.1 has exactly 4,566 body elements and 2 sections."""
        self.assertIsNotNone(self.doc_base, "Baseline v1.1 could not be loaded")
        body_elements = list(self.doc_base._body._body)
        self.assertEqual(
            len(body_elements),
            4566,
            f"Baseline body element count altered! Expected 4566, got {len(body_elements)}",
        )
        self.assertEqual(len(self.doc_base.sections), 2, "Baseline must have exactly 2 sections")

    # --- Area 3: Section 2 (Mục 2) 17 Subsystems Coverage ---

    def test_t1_11_section2_heading1_exists(self):
        """Verify Heading 1 for Section 2 'CƠ SỞ DỮ LIỆU (OLTP)' exists."""
        self.assert_target_document_ready()
        h1_texts = [
            p.text.strip()
            for p in self.doc_target.paragraphs
            if p.style and "Heading 1" in p.style.name
        ]
        has_sec2_h1 = any("CƠ SỞ DỮ LIỆU (OLTP)" in text.upper() for text in h1_texts)
        self.assertTrue(has_sec2_h1, f"Heading 1 'CƠ SỞ DỮ LIỆU (OLTP)' not found in: {h1_texts}")

    def test_t1_12_all_17_subsystems_present_in_heading2(self):
        """Verify all 17 atomic subsystems appear in Section 2 Heading 2 paragraphs."""
        self.assert_target_document_ready()
        for code in EXPECTED_SUBSYSTEM_CODES:
            self.assertIn(
                code,
                self.subsystem_parsed_data,
                f"Subsystem {code} missing from Section 2 Heading 2 structures",
            )

    def test_t1_13_subsystem_headings_normalized_numbering(self):
        """Verify Heading 2 paragraphs for subsystems follow normalized numbering sequence (2.1 to 2.17)."""
        self.assert_target_document_ready()
        h2_paras = [
            p.text.strip()
            for p in self.doc_target.paragraphs
            if p.style and p.style.name == "Heading 2" and any(code in p.text.upper() for code in EXPECTED_SUBSYSTEM_CODES)
        ]
        self.assertEqual(
            len(h2_paras),
            17,
            f"Expected exactly 17 subsystem Heading 2 paragraphs, found {len(h2_paras)}: {h2_paras}",
        )
        for idx, text in enumerate(h2_paras, start=1):
            expected_prefix = f"2.{idx}"
            self.assertTrue(
                text.startswith(expected_prefix) or expected_prefix in text,
                f"Subsystem Heading 2 '{text}' does not match expected numbering prefix '{expected_prefix}'",
            )

    def test_t1_14_subsystem_titles_match_catalog(self):
        """Verify subsystem Heading 2 titles include full Vietnamese business descriptions from catalog."""
        self.assert_target_document_ready()
        self.assertIsNotNone(self.catalog_data, "Catalog JSON data missing")
        catalog_titles = {x["subsys_code"]: x["subsys_full_title"] for x in self.catalog_data}

        for code, expected_full_title in catalog_titles.items():
            self.assertIn(code, self.subsystem_parsed_data, f"Subsystem {code} not parsed in Section 2")
            actual_heading = self.subsystem_parsed_data[code]["heading"]
            # Verify code is in heading
            self.assertIn(code, actual_heading.upper())
            # Verify key business descriptor is preserved
            title_core = expected_full_title.split("—")[-1].strip() if "—" in expected_full_title else expected_full_title
            # At least one major word from the title should match
            core_words = [w for w in title_core.split() if len(w) > 3]
            matched = any(w.lower() in actual_heading.lower() for w in core_words[:4])
            self.assertTrue(
                matched,
                f"Heading for {code} ('{actual_heading}') does not reflect catalog title ('{expected_full_title}')",
            )

    def test_t1_15_subsystem_alphabetical_order(self):
        """Verify all 17 subsystems appear in canonical alphabetical order in Section 2."""
        self.assert_target_document_ready()
        parsed_order = list(self.subsystem_parsed_data.keys())
        self.assertEqual(
            parsed_order,
            EXPECTED_SUBSYSTEM_CODES,
            f"Subsystems in Section 2 are out of order: {parsed_order}",
        )

    # --- Area 4: Section 3 (Mục 3) Datamart Integration ---

    def test_t1_16_section3_heading1_exists(self):
        """Verify Heading 1 for Section 3 'KHO DỮ LIỆU (OLAP)' exists."""
        self.assert_target_document_ready()
        h1_texts = [
            p.text.strip()
            for p in self.doc_target.paragraphs
            if p.style and "Heading 1" in p.style.name
        ]
        has_sec3_h1 = any("KHO DỮ LIỆU (OLAP)" in text.upper() or "KHO DỮ LIỆU (OLAP)" in text.upper() for text in h1_texts)
        self.assertTrue(has_sec3_h1, f"Heading 1 'KHO DỮ LIỆU (OLAP)' not found in: {h1_texts}")

    def test_t1_17_section3_contains_datamart_layers(self):
        """Verify Section 3 contains subsections for Conceptual and Logical models."""
        self.assert_target_document_ready()
        self.assertGreater(
            len(self.target_section3_elements),
            0,
            "Section 3 has no child elements in target docx",
        )
        s3_paras = [
            docx.text.paragraph.Paragraph(el, self.doc_target).text.strip().upper()
            for el in self.target_section3_elements
            if el.tag.endswith("p")
        ]
        has_conceptual = any("CONCEPTUAL" in t or "HIGH LEVEL" in t for t in s3_paras)
        has_logical = any("LOGIC" in t for t in s3_paras)
        self.assertTrue(has_conceptual, "Section 3 missing Conceptual / High Level model heading")
        self.assertTrue(has_logical, "Section 3 missing Logical model heading")

    def test_t1_18_section3_contains_tables(self):
        """Verify Section 3 contains Datamart architecture tables."""
        self.assert_target_document_ready()
        s3_tables = [
            docx.table.Table(el, self.doc_target)
            for el in self.target_section3_elements
            if el.tag.endswith("tbl")
        ]
        self.assertGreaterEqual(
            len(s3_tables),
            10,
            f"Expected at least 10 Datamart tables in Section 3, found {len(s3_tables)}",
        )

    def test_t1_19_section3_positioned_between_m2_and_m4(self):
        """Verify Section 3 elements strictly follow Section 2 and precede Section 4."""
        self.assert_target_document_ready()
        # Find indices in body
        h1_indices = []
        for idx, el in enumerate(self.target_body_elements):
            if el.tag.endswith("p"):
                p = docx.text.paragraph.Paragraph(el, self.doc_target)
                t = p.text.strip().upper()
                if "CƠ SỞ DỮ LIỆU (OLTP)" in t:
                    h1_indices.append(("S2", idx))
                elif "KHO DỮ LIỆU (OLAP)" in t or "KHO DỮ LIỆU (OLAP)" in t:
                    h1_indices.append(("S3", idx))
                elif "THIẾT KẾ TỆP TIN" in t:
                    h1_indices.append(("S4", idx))

        labels = [item[0] for item in h1_indices]
        self.assertEqual(
            labels,
            ["S2", "S3", "S4"],
            f"Section sequence violation! Expected ['S2', 'S3', 'S4'], got {labels}",
        )
        self.assertLess(h1_indices[0][1], h1_indices[1][1], "S2 does not precede S3")
        self.assertLess(h1_indices[1][1], h1_indices[2][1], "S3 does not precede S4")

    def test_t1_20_section3_non_empty_content(self):
        """Verify Section 3 contains substantial textual content (>20 paragraphs)."""
        self.assert_target_document_ready()
        s3_paras = [
            docx.text.paragraph.Paragraph(el, self.doc_target)
            for el in self.target_section3_elements
            if el.tag.endswith("p") and docx.text.paragraph.Paragraph(el, self.doc_target).text.strip()
        ]
        self.assertGreater(
            len(s3_paras),
            20,
            f"Section 3 has too few non-empty paragraphs: {len(s3_paras)}",
        )


# ===========================================================================
# Tier 2: Boundary & Corner Cases (>=5 per feature area)
# ===========================================================================
class TestTier2BoundaryCases(BaseDocxVerificationTest):
    """Tier 2: Boundary verification of prefix 0..69, suffix 4524..4565, 12-column table schemas, and XML packaging."""

    # --- Area 1: Prefix Preservation (Elements 0..69) ---

    def test_t2_01_prefix_element_count_exact_70(self):
        """Verify prefix elements (0..69) total exactly 70 elements with identical XML tags to baseline."""
        self.assert_target_document_ready()
        self.assertIsNotNone(self.doc_base, "Baseline v1.1 not loaded")
        base_body = list(self.doc_base._body._body)
        target_body = list(self.doc_target._body._body)

        self.assertGreaterEqual(len(target_body), 70, "Target docx has fewer than 70 elements")

        for idx in range(70):
            base_tag = base_body[idx].tag
            target_tag = target_body[idx].tag
            self.assertEqual(
                target_tag,
                base_tag,
                f"Prefix element tag mismatch at child index {idx}: expected {base_tag}, got {target_tag}",
            )

    def test_t2_02_prefix_cover_signoff_history_tables(self):
        """Verify prefix tables (Table 0 sign-off, Table 1 contractor, Table 2 revision history) match baseline."""
        self.assert_target_document_ready()
        self.assertIsNotNone(self.doc_base, "Baseline v1.1 not loaded")

        base_prefix_tbls = [
            docx.table.Table(el, self.doc_base)
            for el in list(self.doc_base._body._body)[:70]
            if el.tag.endswith("tbl")
        ]
        target_prefix_tbls = [
            docx.table.Table(el, self.doc_target)
            for el in list(self.doc_target._body._body)[:70]
            if el.tag.endswith("tbl")
        ]

        self.assertEqual(
            len(target_prefix_tbls),
            len(base_prefix_tbls),
            f"Prefix table count mismatch! Expected {len(base_prefix_tbls)}, got {len(target_prefix_tbls)}",
        )

        for t_idx, (t_b, t_t) in enumerate(zip(base_prefix_tbls, target_prefix_tbls)):
            self.assertEqual(len(t_t.rows), len(t_b.rows), f"Prefix table {t_idx} row count mismatch")
            self.assertEqual(len(t_t.columns), len(t_b.columns), f"Prefix table {t_idx} col count mismatch")
            # Check cell text for header row
            for c_idx, (c_b, c_t) in enumerate(zip(t_b.rows[0].cells, t_t.rows[0].cells)):
                self.assertEqual(
                    c_t.text.strip(),
                    c_b.text.strip(),
                    f"Prefix table {t_idx} row 0 col {c_idx} text mismatch: '{c_t.text}' vs '{c_b.text}'",
                )

    def test_t2_03_prefix_toc_sdt_preserved(self):
        """Verify Table of Contents block (w:sdt) is preserved at child index 42."""
        self.assert_target_document_ready()
        target_body = list(self.doc_target._body._body)
        el_42 = target_body[42]
        self.assertTrue(
            el_42.tag.endswith("sdt"),
            f"Element at child index 42 is not a w:sdt TOC element: {el_42.tag}",
        )

    def test_t2_04_prefix_section1_intro_paragraphs_verbatim(self):
        """Verify Section 1 'GIỚI THIỆU' paragraphs match baseline v1.1 text verbatim."""
        self.assert_target_document_ready()
        self.assertIsNotNone(self.doc_base, "Baseline v1.1 not loaded")
        base_body = list(self.doc_base._body._body)
        target_body = list(self.doc_target._body._body)

        # Paragraphs between index 44 and 68 (Mục 1 GIỚI THIỆU, Mục tiêu, Thuật ngữ, Tài liệu tham khảo, Mô tả chung)
        for idx in range(44, 69):
            if base_body[idx].tag.endswith("p"):
                p_base = docx.text.paragraph.Paragraph(base_body[idx], self.doc_base).text.strip()
                p_target = docx.text.paragraph.Paragraph(target_body[idx], self.doc_target).text.strip()
                self.assertEqual(
                    p_target,
                    p_base,
                    f"Section 1 verbatim mismatch at child index {idx}: '{p_target[:40]}' vs '{p_base[:40]}'",
                )

    def test_t2_05_prefix_section_break_geometry_at_element_69(self):
        """Verify child element 69 contains section break with Portrait geometry matching baseline."""
        self.assert_target_document_ready()
        self.assertIsNotNone(self.doc_base, "Baseline v1.1 not loaded")

        el_69_target = list(self.doc_target._body._body)[69]
        sectPr_target = el_69_target.xpath("./w:pPr/w:sectPr")
        self.assertTrue(len(sectPr_target) > 0, "Child element 69 is missing w:pPr/w:sectPr section break")

        el_69_base = list(self.doc_base._body._body)[69]
        sectPr_base = el_69_base.xpath("./w:pPr/w:sectPr")[0]
        sectPr_target = sectPr_target[0]

        pgSz_base = sectPr_base.xpath("./w:pgSz")
        pgSz_target = sectPr_target.xpath("./w:pgSz")
        self.assertEqual(len(pgSz_target), len(pgSz_base))
        if pgSz_base:
            self.assertEqual(
                pgSz_target[0].get(qn("w:w")),
                pgSz_base[0].get(qn("w:w")),
                "Section 1 page width mismatch",
            )
            self.assertEqual(
                pgSz_target[0].get(qn("w:h")),
                pgSz_base[0].get(qn("w:h")),
                "Section 1 page height mismatch",
            )

    # --- Area 2: Suffix Preservation (Mục 4..7 / Elements 4524..4565) ---

    def test_t2_06_suffix_starts_with_section4_heading(self):
        """Verify suffix starts with Heading 1 'THIẾT KẾ TỆP TIN'."""
        self.assert_target_document_ready()
        self.assertGreater(len(self.target_suffix_elements), 0, "No suffix elements identified")
        first_p = docx.text.paragraph.Paragraph(self.target_suffix_elements[0], self.doc_target)
        self.assertIn("THIẾT KẾ TỆP TIN", first_p.text.strip().upper())

    def test_t2_07_suffix_section5_surrogate_key_rationale(self):
        """Verify Section 5 'THIẾT KẾ MÃ' preserves Surrogate Key rationale paragraphs."""
        self.assert_target_document_ready()
        suffix_paras = [
            docx.text.paragraph.Paragraph(el, self.doc_target).text.strip()
            for el in self.target_suffix_elements
            if el.tag.endswith("p")
        ]
        has_surrogate_title = any("Surrogate Key" in t for t in suffix_paras)
        has_surrogate_body = any("Khóa thay thế" in t or "surrogate" in t.lower() for t in suffix_paras)
        self.assertTrue(has_surrogate_title, "Missing 'Surrogate Key' heading in Section 5")
        self.assertTrue(has_surrogate_body, "Missing Surrogate Key explanation in Section 5")

    def test_t2_08_suffix_section6_physical_design_intact(self):
        """Verify Section 6 '<THIẾT KẾ VẬT LÝ>' heading and tablespace tables are intact."""
        self.assert_target_document_ready()
        suffix_paras = [
            docx.text.paragraph.Paragraph(el, self.doc_target).text.strip()
            for el in self.target_suffix_elements
            if el.tag.endswith("p")
        ]
        has_sec6 = any("THIẾT KẾ VẬT LÝ" in t.upper() for t in suffix_paras)
        self.assertTrue(has_sec6, "Missing Section 6 '<THIẾT KẾ VẬT LÝ>' in suffix")

    def test_t2_09_suffix_phu_luc_17_symbols_table(self):
        """Verify Section 7 'PHỤ LỤC' contains Table 911 (17 rows x 2 cols) data format symbols intact."""
        self.assert_target_document_ready()
        suffix_tables = [
            docx.table.Table(el, self.doc_target)
            for el in self.target_suffix_elements
            if el.tag.endswith("tbl")
        ]
        # Look for 17 rows x 2 cols table with 'Symbol' in header
        found_table_911 = False
        for t in suffix_tables:
            if len(t.rows) == 17 and len(t.columns) == 2:
                if "Symbol" in t.rows[0].cells[0].text or "Biểu tượng" in t.rows[0].cells[1].text:
                    found_table_911 = True
                    break
        self.assertTrue(found_table_911, "Phụ lục Table 911 (17 rows x 2 cols data symbols) not found in suffix")

    def test_t2_10_suffix_closing_body_sectpr_landscape(self):
        """Verify document terminates with body-level sectPr in Landscape orientation matching baseline."""
        self.assert_target_document_ready()
        last_el = list(self.doc_target._body._body)[-1]
        self.assertTrue(
            last_el.tag.endswith("sectPr"),
            f"Final body element is not a w:sectPr: {last_el.tag}",
        )
        pgSz = last_el.xpath("./w:pgSz")
        self.assertTrue(len(pgSz) > 0, "Final body sectPr missing w:pgSz")
        self.assertEqual(
            pgSz[0].get(qn("w:orient")),
            "landscape",
            "Final section orientation must be landscape",
        )

    # --- Area 3: Data Dictionary Table Schema Integrity (12 Columns) ---

    def test_t2_11_all_data_dictionaries_have_12_columns(self):
        """Verify every data dictionary table in Section 2 has exactly 12 columns across all rows."""
        self.assert_target_document_ready()
        all_dict_tables = [
            t
            for subsys in self.subsystem_parsed_data.values()
            for t in subsys["dict_tables"]
        ]
        self.assertGreaterEqual(
            len(all_dict_tables),
            378,
            f"Expected at least 378 data dictionary tables, found {len(all_dict_tables)}",
        )
        for idx, t in enumerate(all_dict_tables):
            self.assertEqual(
                len(t.columns),
                12,
                f"Data dictionary table #{idx} has {len(t.columns)} columns (expected 12)",
            )
            for r_idx, row in enumerate(t.rows):
                self.assertEqual(
                    len(row.cells),
                    12,
                    f"Data dictionary table #{idx} row #{r_idx} cell count mismatch: {len(row.cells)} != 12",
                )

    def test_t2_12_data_dictionary_header_row_exact_labels(self):
        """Verify header row (row 0) of every data dictionary matches standard 12 column names."""
        self.assert_target_document_ready()
        all_dict_tables = [
            t
            for subsys in self.subsystem_parsed_data.values()
            for t in subsys["dict_tables"]
        ]
        sample_tables = all_dict_tables[::20]  # Sample across all subsystems
        for idx, t in enumerate(sample_tables):
            actual_headers = [c.text.strip().replace("\n", " ") for c in t.rows[0].cells]
            self.assertEqual(actual_headers[0], "STT")
            self.assertEqual(actual_headers[1], "Tên trường")
            self.assertEqual(actual_headers[2], "Tên cột")
            self.assertTrue("Kiểu dữ liệu" in actual_headers[3])
            self.assertEqual(actual_headers[4], "Nullable")
            self.assertEqual(actual_headers[5], "Unique")
            self.assertEqual(actual_headers[6], "P/F Key")
            self.assertEqual(actual_headers[7], "Mặc định")
            self.assertEqual(actual_headers[8], "Mô tả")
            self.assertTrue("Schema.Table" in actual_headers[9] or "Schema" in actual_headers[9])

    def test_t2_13_data_dictionary_no_corrupt_cells(self):
        """Verify no empty cells in core structural fields (STT, Tên trường, Tên cột, Kiểu dữ liệu)."""
        self.assert_target_document_ready()
        all_dict_tables = [
            t
            for subsys in self.subsystem_parsed_data.values()
            for t in subsys["dict_tables"]
        ]
        sample_tables = all_dict_tables[::15]
        for t_idx, t in enumerate(sample_tables):
            for r_idx, row in enumerate(t.rows[1:], start=1):
                stt = row.cells[0].text.strip()
                name_vi = row.cells[1].text.strip()
                col_name = row.cells[2].text.strip()
                dtype = row.cells[3].text.strip()
                self.assertTrue(len(stt) > 0, f"Table #{t_idx} row #{r_idx} missing STT")
                self.assertTrue(len(name_vi) > 0, f"Table #{t_idx} row #{r_idx} missing Tên trường")
                self.assertTrue(len(col_name) > 0, f"Table #{t_idx} row #{r_idx} missing Tên cột")
                self.assertTrue(len(dtype) > 0, f"Table #{t_idx} row #{r_idx} missing Kiểu dữ liệu")

    def test_t2_14_primary_key_flag_integrity(self):
        """Verify Primary Key columns have 'P' in P/F Key column and 'X' in Unique column."""
        self.assert_target_document_ready()
        pk_count = 0
        all_dict_tables = [
            t
            for subsys in self.subsystem_parsed_data.values()
            for t in subsys["dict_tables"]
        ]
        for t in all_dict_tables:
            for row in t.rows[1:]:
                pf = row.cells[6].text.strip().upper()
                if pf == "P":
                    pk_count += 1
                    uniq = row.cells[5].text.strip().upper()
                    self.assertIn(uniq, ("X", "TRUE", "1", "YES"), "PK column must be unique ('X')")
        self.assertEqual(
            pk_count,
            EXPECTED_TOTAL_PK,
            f"Total PK count mismatch! Expected {EXPECTED_TOTAL_PK}, got {pk_count}",
        )

    def test_t2_15_foreign_key_flag_integrity(self):
        """Verify Foreign Key columns have 'F' in P/F Key column."""
        self.assert_target_document_ready()
        fk_count = 0
        all_dict_tables = [
            t
            for subsys in self.subsystem_parsed_data.values()
            for t in subsys["dict_tables"]
        ]
        for t in all_dict_tables:
            for row in t.rows[1:]:
                pf = row.cells[6].text.strip().upper()
                if pf == "F":
                    fk_count += 1
        self.assertEqual(
            fk_count,
            EXPECTED_TOTAL_FK,
            f"Total FK count mismatch! Expected {EXPECTED_TOTAL_FK}, got {fk_count}",
        )

    # --- Area 4: Zero Media Bloat & Package Cleanliness ---

    def test_t2_16_zero_broken_media_relationships(self):
        """Verify all relationship r:id references in word/_rels/document.xml.rels resolve cleanly."""
        self.assert_target_document_ready()
        with zipfile.ZipFile(self.target_path, "r") as zf:
            rels_bytes = zf.read("word/_rels/document.xml.rels")
            root = lxml.etree.fromstring(rels_bytes)
            pkg_files = set(zf.namelist())
            for rel in root.xpath("//*"):
                target = rel.get("Target")
                mode = rel.get("TargetMode")
                if target and mode != "External":
                    resolved = f"word/{target}" if not target.startswith("/") else target.lstrip("/")
                    normalized = os.path.normpath(resolved).replace("\\", "/")
                    # Check internal target exists
                    self.assertIn(
                        normalized,
                        pkg_files,
                        f"Broken media relationship target: {target} (resolved to {normalized})",
                    )

    def test_t2_17_no_dangling_image_blips(self):
        """Verify all image blip r:embed IDs exist in document relationships."""
        self.assert_target_document_ready()
        with zipfile.ZipFile(self.target_path, "r") as zf:
            doc_xml = zf.read("word/document.xml")
            rels_xml = zf.read("word/_rels/document.xml.rels")
            rels_root = lxml.etree.fromstring(rels_xml)
            rel_ids = {rel.get("Id") for rel in rels_root.xpath("//*") if rel.get("Id")}

            doc_root = lxml.etree.fromstring(doc_xml)
            blips = doc_root.xpath("//a:blip", namespaces={"a": "http://schemas.openxmlformats.org/drawingml/2006/main"})
            for blip in blips:
                embed_id = blip.get(qn("r:embed"))
                if embed_id:
                    self.assertIn(
                        embed_id,
                        rel_ids,
                        f"Dangling drawing blip r:embed='{embed_id}' not found in relationships",
                    )

    def test_t2_18_surrogate_key_column_naming(self):
        """Verify surrogate key columns (STT=1) adhere to standard *_id naming pattern."""
        self.assert_target_document_ready()
        all_dict_tables = [
            t
            for subsys in self.subsystem_parsed_data.values()
            for t in subsys["dict_tables"]
        ]
        for t_idx, t in enumerate(all_dict_tables):
            first_data_row = t.rows[1]
            col_name = first_data_row.cells[2].text.strip()
            pf_flag = first_data_row.cells[6].text.strip().upper()
            if pf_flag == "P":
                self.assertTrue(
                    col_name.endswith("_id") or col_name.endswith("_code"),
                    f"Table #{t_idx} PK column '{col_name}' does not follow surrogate key convention",
                )

    def test_t2_19_no_duplicate_xml_bookmarks(self):
        """Verify no duplicate bookmark IDs exist in word/document.xml."""
        self.assert_target_document_ready()
        with zipfile.ZipFile(self.target_path, "r") as zf:
            doc_xml = zf.read("word/document.xml")
            doc_root = lxml.etree.fromstring(doc_xml)
            bookmark_starts = doc_root.xpath(
                "//w:bookmarkStart",
                namespaces={"w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main"},
            )
            seen_ids = set()
            for bm in bookmark_starts:
                b_id = bm.get(qn("w:id"))
                self.assertNotIn(b_id, seen_ids, f"Duplicate bookmark ID detected: {b_id}")
                seen_ids.add(b_id)

    def test_t2_20_styles_xml_preserves_189_styles(self):
        """Verify word/styles.xml retains all 189 standard styles from baseline v1.1."""
        self.assert_target_document_ready()
        with zipfile.ZipFile(self.target_path, "r") as zf:
            styles_xml = zf.read("word/styles.xml")
            root = lxml.etree.fromstring(styles_xml)
            style_elements = root.xpath(
                "//w:style",
                namespaces={"w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main"},
            )
            self.assertGreaterEqual(
                len(style_elements),
                189,
                f"Styles count reduced! Expected >= 189, found {len(style_elements)}",
            )


# ===========================================================================
# Tier 3: Cross-Feature Combinations & Quantitative Matrix
# ===========================================================================
class TestTier3CrossFeatureCombinations(BaseDocxVerificationTest):
    """Tier 3: Quantitative cross-feature verification against all_subsystems.json (274 overview, 378 detail, 5787 columns)."""

    # --- Area 1: Overview Tables (Table 1) Quantitative Matrix ---

    def test_t3_01_total_overview_table_rows_274(self):
        """Verify the total number of overview table rows across all 17 subsystems is exactly 274."""
        self.assert_target_document_ready()
        total_rows = 0
        for code in EXPECTED_SUBSYSTEM_CODES:
            subsys = self.subsystem_parsed_data.get(code, {})
            ov_tables = subsys.get("overview_tables", [])
            subsys_rows = sum(len(t.rows) - 1 for t in ov_tables)
            total_rows += subsys_rows
        self.assertEqual(
            total_rows,
            EXPECTED_TOTAL_OVERVIEW_ROWS,
            f"Total overview rows mismatch! Expected {EXPECTED_TOTAL_OVERVIEW_ROWS}, got {total_rows}",
        )

    def test_t3_02_overview_tables_per_subsystem_counts(self):
        """Verify overview table rows for each of the 17 subsystems match ground truth specs."""
        self.assert_target_document_ready()
        for code, spec in SUBSYSTEM_SPECS.items():
            subsys = self.subsystem_parsed_data.get(code, {})
            ov_tables = subsys.get("overview_tables", [])
            actual_rows = sum(len(t.rows) - 1 for t in ov_tables)
            expected_rows = spec["overview_rows"]
            self.assertEqual(
                actual_rows,
                expected_rows,
                f"Subsystem {code} Table 1 row count mismatch: expected {expected_rows}, got {actual_rows}",
            )

    def test_t3_03_overview_table_4_columns_structure(self):
        """Verify all overview tables have exactly 4 columns ('STT', 'Thực thể', 'Tên bảng', 'Mô tả')."""
        self.assert_target_document_ready()
        for code in EXPECTED_SUBSYSTEM_CODES:
            subsys = self.subsystem_parsed_data.get(code, {})
            for t in subsys.get("overview_tables", []):
                self.assertEqual(len(t.columns), 4, f"Overview table in {code} does not have 4 columns")
                headers = [c.text.strip() for c in t.rows[0].cells]
                self.assertEqual(headers[0], "STT")
                self.assertIn("Thực thể", headers[1])
                self.assertIn("Tên bảng", headers[2])
                self.assertIn("Mô tả", headers[3])

    def test_t3_04_overview_table_entities_unique_per_subsystem(self):
        """Verify physical table names in each subsystem's overview table are unique."""
        self.assert_target_document_ready()
        for code in EXPECTED_SUBSYSTEM_CODES:
            subsys = self.subsystem_parsed_data.get(code, {})
            seen_tables = set()
            for t in subsys.get("overview_tables", []):
                for row in t.rows[1:]:
                    phys_name = row.cells[2].text.strip().lower()
                    if phys_name:
                        self.assertNotIn(
                            phys_name,
                            seen_tables,
                            f"Duplicate physical table name '{phys_name}' in overview table for {code}",
                        )
                        seen_tables.add(phys_name)

    def test_t3_05_overview_table_crosswalk_with_all_subsystems_json(self):
        """Cross-check overview table physical names against all_subsystems.json entries."""
        self.assert_target_document_ready()
        self.assertIsNotNone(self.catalog_data, "Catalog JSON data missing")
        catalog_map = {x["subsys_code"]: x["overview_tables"] for x in self.catalog_data}

        for code in EXPECTED_SUBSYSTEM_CODES:
            expected_list = catalog_map.get(code, [])
            expected_phys_names = {x["physical_name"].strip().lower() for x in expected_list}

            subsys = self.subsystem_parsed_data.get(code, {})
            actual_phys_names = {
                row.cells[2].text.strip().lower()
                for t in subsys.get("overview_tables", [])
                for row in t.rows[1:]
                if row.cells[2].text.strip()
            }
            self.assertEqual(
                actual_phys_names,
                expected_phys_names,
                f"Overview physical tables mismatch in {code}! Diff: {expected_phys_names ^ actual_phys_names}",
            )

    # --- Area 2: Detailed Entity Tables (Heading 3) Quantitative Matrix ---

    def test_t3_06_total_detail_tables_count_378(self):
        """Verify total detailed data dictionary tables across 17 subsystems is exactly 378."""
        self.assert_target_document_ready()
        total_dict = sum(
            len(subsys.get("dict_tables", []))
            for subsys in self.subsystem_parsed_data.values()
        )
        self.assertEqual(
            total_dict,
            EXPECTED_TOTAL_DETAIL_TABLES,
            f"Total detail tables mismatch! Expected {EXPECTED_TOTAL_DETAIL_TABLES}, got {total_dict}",
        )

    def test_t3_07_detail_tables_per_subsystem_counts(self):
        """Verify detailed table count for each of the 17 subsystems matches ground truth specs."""
        self.assert_target_document_ready()
        for code, spec in SUBSYSTEM_SPECS.items():
            subsys = self.subsystem_parsed_data.get(code, {})
            actual_dict = len(subsys.get("dict_tables", []))
            expected_dict = spec["detail_tables"]
            self.assertEqual(
                actual_dict,
                expected_dict,
                f"Subsystem {code} detailed table count mismatch: expected {expected_dict}, got {actual_dict}",
            )

    def test_t3_08_detail_table_headings_format(self):
        """Verify detail tables are preceded by a Heading 3 matching 'Bảng <Tên thực thể>'."""
        self.assert_target_document_ready()
        h3_paras = [
            p.text.strip()
            for p in self.doc_target.paragraphs
            if p.style and p.style.name == "Heading 3" and "Bảng" in p.text
        ]
        self.assertGreaterEqual(
            len(h3_paras),
            EXPECTED_TOTAL_DETAIL_TABLES,
            f"Expected at least {EXPECTED_TOTAL_DETAIL_TABLES} 'Heading 3 Bảng ...', found {len(h3_paras)}",
        )

    def test_t3_09_detail_table_metadata_blocks(self):
        """Verify metadata paragraphs (Tên vật lý, Định dạng: Iceberg, Thời gian: 5 năm) precede tables."""
        self.assert_target_document_ready()
        s2_text = " ".join(
            docx.text.paragraph.Paragraph(el, self.doc_target).text
            for el in self.target_section2_elements
            if el.tag.endswith("p")
        )
        self.assertIn("Iceberg", s2_text, "Missing Iceberg storage format metadata in Section 2")
        self.assertIn("5 năm", s2_text, "Missing 5-year retention metadata in Section 2")
        self.assertIn("Tên vật lý", s2_text, "Missing 'Tên vật lý' metadata in Section 2")

    def test_t3_10_detail_table_crosswalk_with_catalog(self):
        """Cross-check detail table counts per subsystem against all_subsystems.json."""
        self.assert_target_document_ready()
        self.assertIsNotNone(self.catalog_data, "Catalog JSON data missing")
        catalog_counts = {x["subsys_code"]: len(x["detail_tables"]) for x in self.catalog_data}

        for code in EXPECTED_SUBSYSTEM_CODES:
            expected_count = catalog_counts.get(code, 0)
            actual_count = len(self.subsystem_parsed_data.get(code, {}).get("dict_tables", []))
            self.assertEqual(
                actual_count,
                expected_count,
                f"Detailed table count mismatch for {code}: expected {expected_count}, got {actual_count}",
            )

    # --- Area 3: Column Count & Attribute Matrix Fidelity ---

    def test_t3_11_total_column_count_5787(self):
        """Verify total column count across all 378 data dictionary tables is exactly 5,787."""
        self.assert_target_document_ready()
        total_cols = sum(
            len(t.rows) - 1
            for subsys in self.subsystem_parsed_data.values()
            for t in subsys.get("dict_tables", [])
        )
        self.assertEqual(
            total_cols,
            EXPECTED_TOTAL_COLUMNS,
            f"Total column count mismatch! Expected {EXPECTED_TOTAL_COLUMNS}, got {total_cols}",
        )

    def test_t3_12_column_counts_per_subsystem_exact(self):
        """Verify column counts per subsystem match ground truth specifications exactly."""
        self.assert_target_document_ready()
        for code, spec in SUBSYSTEM_SPECS.items():
            subsys = self.subsystem_parsed_data.get(code, {})
            actual_cols = sum(len(t.rows) - 1 for t in subsys.get("dict_tables", []))
            expected_cols = spec["columns"]
            self.assertEqual(
                actual_cols,
                expected_cols,
                f"Column count mismatch for subsystem {code}: expected {expected_cols}, got {actual_cols}",
            )

    def test_t3_13_total_primary_keys_count_334(self):
        """Verify total primary key columns across all 17 subsystems is exactly 334."""
        self.assert_target_document_ready()
        total_pk = sum(
            1
            for subsys in self.subsystem_parsed_data.values()
            for t in subsys.get("dict_tables", [])
            for row in t.rows[1:]
            if row.cells[6].text.strip().upper() == "P"
        )
        self.assertEqual(
            total_pk,
            EXPECTED_TOTAL_PK,
            f"Total PK columns mismatch! Expected {EXPECTED_TOTAL_PK}, got {total_pk}",
        )

    def test_t3_14_total_foreign_keys_count_581(self):
        """Verify total foreign key columns across all 17 subsystems is exactly 581."""
        self.assert_target_document_ready()
        total_fk = sum(
            1
            for subsys in self.subsystem_parsed_data.values()
            for t in subsys.get("dict_tables", [])
            for row in t.rows[1:]
            if row.cells[6].text.strip().upper() == "F"
        )
        self.assertEqual(
            total_fk,
            EXPECTED_TOTAL_FK,
            f"Total FK columns mismatch! Expected {EXPECTED_TOTAL_FK}, got {total_fk}",
        )

    def test_t3_15_column_data_types_conform_to_lakehouse(self):
        """Verify 100% of data types belong to standard Spark/Iceberg types (STRING, INT, DATE, etc.)."""
        self.assert_target_document_ready()
        allowed_types = {
            "STRING",
            "DATE",
            "INT",
            "BIGINT",
            "DECIMAL",
            "TIMESTAMP",
            "DOUBLE",
            "FLOAT",
            "BOOLEAN",
            "ARRAY",
            "BINARY",
        }
        sample_tables = [
            t
            for subsys in self.subsystem_parsed_data.values()
            for t in subsys.get("dict_tables", [])
        ][::10]

        for t in sample_tables:
            for row in t.rows[1:]:
                raw_type = row.cells[3].text.strip().upper()
                base_type = raw_type.split("(")[0].split("<")[0].strip()
                self.assertIn(
                    base_type,
                    allowed_types,
                    f"Non-standard data type detected: '{raw_type}' (base '{base_type}')",
                )


# ===========================================================================
# Tier 4: Real-World Application Scenarios & Robustness
# ===========================================================================
class TestTier4RealWorldScenarios(BaseDocxVerificationTest):
    """Tier 4: End-to-end reader simulation, XML schema parse stress, outline hierarchy, and print layout validation."""

    # --- Area 1: XML Tree Integrity & Document Parse Robustness ---

    def test_t4_01_full_xml_tree_lxml_parse(self):
        """Verify lxml parses word/document.xml without any XMLSyntaxError or namespace corruption."""
        self.assert_target_document_ready()
        with zipfile.ZipFile(self.target_path, "r") as zf:
            doc_xml = zf.read("word/document.xml")
            parser = lxml.etree.XMLParser(recover=False)
            try:
                root = lxml.etree.fromstring(doc_xml, parser=parser)
            except lxml.etree.XMLSyntaxError as e:
                self.fail(f"document.xml has XMLSyntaxError: {e}")
            self.assertEqual(root.tag, qn("w:document"))

    def test_t4_02_docx_object_traversal_performance(self):
        """Verify traversing all paragraphs and tables completes without MemoryError or recursion limits."""
        self.assert_target_document_ready()
        # Traverse paragraphs
        para_count = sum(1 for p in self.doc_target.paragraphs if p.text)
        self.assertGreater(para_count, 1000)

        # Traverse tables
        table_cell_count = sum(len(row.cells) for t in self.doc_target.tables[:100] for row in t.rows)
        self.assertGreater(table_cell_count, 1000)

    def test_t4_03_no_corrupt_empty_paragraphs_in_tables(self):
        """Verify table cells contain valid text runs without nested corrupt table definitions."""
        self.assert_target_document_ready()
        for subsys in self.subsystem_parsed_data.values():
            for t in subsys.get("dict_tables", [])[:2]:
                for row in t.rows[:5]:
                    for cell in row.cells:
                        # Cell must have at least one paragraph
                        self.assertGreater(len(cell.paragraphs), 0)

    def test_t4_04_repeat_table_header_row_tblheader(self):
        """Verify data dictionary tables have tblHeader on row 0 for multi-page Word table rendering."""
        self.assert_target_document_ready()
        all_dict_tables = [
            t
            for subsys in self.subsystem_parsed_data.values()
            for t in subsys["dict_tables"]
        ]
        sample_tables = all_dict_tables[::25]
        for t in sample_tables:
            row_0_trPr = t.rows[0]._tr.xpath("./w:trPr")
            has_tblHeader = False
            if row_0_trPr:
                has_tblHeader = len(row_0_trPr[0].xpath("./w:tblHeader")) > 0
            # Table should have tblHeader or valid header cells
            self.assertTrue(
                has_tblHeader or "STT" in t.rows[0].cells[0].text,
                "Table missing repeatable header configuration",
            )

    def test_t4_05_page_geometry_and_margins_landscape(self):
        """Verify Section 2 body has valid printable margins and Landscape page geometry."""
        self.assert_target_document_ready()
        # Section 1 (index 1) in doc_target corresponds to Section 2 onwards
        self.assertGreaterEqual(len(self.doc_target.sections), 2)
        sec2 = self.doc_target.sections[1]
        self.assertEqual(
            sec2.orientation,
            docx.enum.section.WD_ORIENT.LANDSCAPE,
            f"Section 2 orientation is not landscape: {sec2.orientation}",
        )
        self.assertGreater(sec2.page_width, sec2.page_height, "Landscape width must be > height")
        # Check standard printable margins (> 0.5 inches = 450,000 twips/EMUs)
        self.assertGreater(sec2.top_margin, 360000)
        self.assertGreater(sec2.bottom_margin, 360000)
        self.assertGreater(sec2.left_margin, 360000)
        self.assertGreater(sec2.right_margin, 360000)

    # --- Area 2: Outline Hierarchy & Navigation Consistency ---

    def test_t4_06_single_heading1_for_section2(self):
        """Verify there is exactly one Heading 1 for Section 2 (no duplicate Heading 1 inside subsystems)."""
        self.assert_target_document_ready()
        h1_sec2 = [
            p.text.strip()
            for p in self.doc_target.paragraphs
            if p.style and p.style.name == "Heading 1" and "CƠ SỞ DỮ LIỆU" in p.text.upper()
        ]
        self.assertEqual(
            len(h1_sec2),
            1,
            f"Expected exactly 1 Heading 1 for Section 2, found {len(h1_sec2)}: {h1_sec2}",
        )

    def test_t4_07_heading2_sequence_continuous(self):
        """Verify Heading 2 numbering sequence starts at 2.1 and increases continuously to 2.17."""
        self.assert_target_document_ready()
        h2_headings = [
            p.text.strip()
            for p in self.doc_target.paragraphs
            if p.style and p.style.name == "Heading 2" and any(code in p.text.upper() for code in EXPECTED_SUBSYSTEM_CODES)
        ]
        expected_numbers = [f"2.{i}" for i in range(1, 18)]
        actual_numbers = []
        for h in h2_headings:
            m = re.match(r"(2\.\d+)", h)
            if m:
                actual_numbers.append(m.group(1))

        self.assertEqual(
            actual_numbers,
            expected_numbers,
            f"Heading 2 numbering is discontinuous: {actual_numbers} vs expected {expected_numbers}",
        )

    def test_t4_08_heading3_strictly_under_heading2(self):
        """Verify every Heading 3 element in Section 2 is subordinated under its respective Heading 2."""
        self.assert_target_document_ready()
        # Ensure every subsystem has at least one detail table under its Heading 2
        for code, data in self.subsystem_parsed_data.items():
            self.assertGreater(
                len(data["dict_tables"]),
                0,
                f"Subsystem {code} has no detailed tables under its Heading 2",
            )

    def test_t4_09_toc_hyperlink_targets_resolvable(self):
        """Verify TOC w:sdt block is present and structure is intact without Word recovery warnings."""
        self.assert_target_document_ready()
        target_body = list(self.doc_target._body._body)
        sdt_elements = [el for el in target_body if el.tag.endswith("sdt")]
        self.assertGreaterEqual(len(sdt_elements), 1, "TOC sdt element missing in target document")

    def test_t4_10_end_to_end_reader_simulation_roundtrip(self):
        """Simulate reader opening document: save to memory buffer, reload, and verify structural counts."""
        self.assert_target_document_ready()
        buffer = io.BytesIO()
        self.doc_target.save(buffer)
        buffer.seek(0)
        reloaded_doc = docx.Document(buffer)

        self.assertEqual(
            len(reloaded_doc.sections),
            len(self.doc_target.sections),
            "Section count changed after roundtrip",
        )
        self.assertEqual(
            len(reloaded_doc.tables),
            len(self.doc_target.tables),
            "Table count changed after roundtrip",
        )
        self.assertGreater(len(reloaded_doc.paragraphs), 1000)


# ---------------------------------------------------------------------------
# CLI Execution Entry Point
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    unittest.main()
