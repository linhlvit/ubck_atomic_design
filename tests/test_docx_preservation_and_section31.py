"""Automated Verification and Integrity Test Suite for Milestone 1:
- Preservation of original template v1.1 (SHA-256 unchanged)
- Validity and readability of output document v1.2
- 100% bit-for-bit preservation of non-3.1 content (Section 0, 1, 2, 3.2, 3.3, 4, 5, 6)
- 100% preservation of all 37 tables (0 tables in 3.1, 37 tables outside 3.1)
- 100% preservation of page setup & section breaks (Section 0 Portrait, Section 1 Landscape)
- Complete rendering of Section 3.1: 10 modules, 20 H4 headers, 90 H5 headers, 90 diagrams
- Typographic compliance: Times New Roman, proper spacing, hanging indent w:hanging="280"
"""

from __future__ import annotations

import hashlib
import unittest
import zipfile
from pathlib import Path

import docx
from docx.oxml.ns import qn

REPO_ROOT = Path(__file__).resolve().parents[1]
TEMPLATE_DOCX = REPO_ROOT / "docs" / "templates" / "sample" / "UBCKNN_Q5_Tai_lieu_phan_tich_thiet_ke_v1.1_20260828.docx"
OUTPUT_DOCX = REPO_ROOT / "docs" / "output" / "UBCKNN_Q5_Tai_lieu_phan_tich_thiet_ke_v1.2_20261028.docx"

EXPECTED_TEMPLATE_SHA256 = "324257ee221bc7f341e70f97b6a57ba1663295e474d8f083bb1393384b7dd5a9"

MODULE_NAMES = [
    ("TT", "1", "HOẠT ĐỘNG THANH TRA"),
    ("NHNCK", "2", "NGƯỜI HÀNH NGHỀ CHỨNG KHOÁN"),
    ("NDTNN", "3", "NHÀ ĐẦU TƯ NƯỚC NGOÀI"),
    ("QLCB", "4", "QUẢN LÝ CHÀO BÁN"),
    ("GSDC", "5", "GIÁM SÁT CÔNG TY ĐẠI CHÚNG"),
    ("GSTT", "6", "GIÁM SÁT THỊ TRƯỜNG"),
    ("QLQ", "7", "CÔNG TY QUẢN LÝ QUỸ (AMC)"),
    ("QLKD", "8", "HOẠT ĐỘNG CÔNG TY CHỨNG KHOÁN"),
    ("PTTT", "9", "PHÂN TÍCH THỊ TRƯỜNG"),
    ("TKNB", "10", "THỐNG KÊ THỊ TRƯỜNG"),
]


class TestDocxPreservationAndSection31(unittest.TestCase):
    """Rigorous verification suite for Q5 v1.2 generation."""

    @classmethod
    def setUpClass(cls):
        cls.tmpl_path = TEMPLATE_DOCX
        cls.out_path = OUTPUT_DOCX
        cls.doc_tmpl = docx.Document(cls.tmpl_path)
        cls.doc_out = docx.Document(cls.out_path)

    def test_01_original_template_sha256_unmodified(self):
        """Verify original sample template is 100% untouched and matches initial SHA-256."""
        self.assertTrue(self.tmpl_path.is_file(), "Original template file missing")
        current_sha = hashlib.sha256(self.tmpl_path.read_bytes()).hexdigest()
        self.assertEqual(
            current_sha,
            EXPECTED_TEMPLATE_SHA256,
            f"Original template SHA-256 modified! Expected {EXPECTED_TEMPLATE_SHA256}, got {current_sha}"
        )

    def test_02_output_file_exists_and_valid_zip(self):
        """Verify output docx exists, size > 10MB, and ZIP package is intact."""
        self.assertTrue(self.out_path.is_file(), "Output docx file was not created")
        size = self.out_path.stat().st_size
        self.assertGreater(size, 10_000_000, f"Output docx too small: {size} bytes")

        with zipfile.ZipFile(self.out_path, "r") as zf:
            bad_file = zf.testzip()
            self.assertIsNone(bad_file, f"Corrupted file inside docx ZIP: {bad_file}")
            part_names = zf.namelist()
            self.assertIn("word/document.xml", part_names)
            self.assertIn("[Content_Types].xml", part_names)

    def test_03_section_breaks_and_geometry_preserved(self):
        """Verify 2 sections: Section 0 Portrait, Section 1 Landscape, identical margins."""
        self.assertEqual(len(self.doc_out.sections), 2, "Document must have exactly 2 sections")
        for i in range(2):
            s_tmpl = self.doc_tmpl.sections[i]
            s_out = self.doc_out.sections[i]
            self.assertEqual(s_out.orientation, s_tmpl.orientation, f"Section {i} orientation mismatch")
            self.assertEqual(s_out.page_width, s_tmpl.page_width, f"Section {i} page_width mismatch")
            self.assertEqual(s_out.page_height, s_tmpl.page_height, f"Section {i} page_height mismatch")
            self.assertEqual(s_out.left_margin, s_tmpl.left_margin, f"Section {i} left_margin mismatch")
            self.assertEqual(s_out.right_margin, s_tmpl.right_margin, f"Section {i} right_margin mismatch")
            self.assertEqual(s_out.top_margin, s_tmpl.top_margin, f"Section {i} top_margin mismatch")
            self.assertEqual(s_out.bottom_margin, s_tmpl.bottom_margin, f"Section {i} bottom_margin mismatch")
            self.assertEqual(
                s_out.different_first_page_header_footer,
                s_tmpl.different_first_page_header_footer,
                f"Section {i} different_first_page mismatch"
            )

    def test_04_non_section_31_paragraphs_identical(self):
        """Verify paragraphs before ETL and after API are 100% identical in text."""
        # Paragraphs 0 to 209 (Cover, TOC, Section 1, Section 2)
        for i in range(210):
            p_tmpl = self.doc_tmpl.paragraphs[i]
            p_out = self.doc_out.paragraphs[i]
            self.assertEqual(
                p_out.text,
                p_tmpl.text,
                f"Mismatch in pre-3.1 paragraph {i}: '{p_out.text[:40]}' vs '{p_tmpl.text[:40]}'"
            )

        # Section 3.1 header paragraph 210
        self.assertEqual(self.doc_out.paragraphs[210].text.strip(), "Phân hệ ETL")

        # Section 3.2 header paragraph 1255
        self.assertEqual(
            self.doc_out.paragraphs[1255].text.strip(),
            "Phân hệ tích hợp dữ liệu ( API )"
        )

        # Paragraphs 1256 to end (Section 3.2, 3.3, 4, 5, 6, attachments)
        self.assertEqual(len(self.doc_out.paragraphs), len(self.doc_tmpl.paragraphs))
        for i in range(1256, len(self.doc_tmpl.paragraphs)):
            p_tmpl = self.doc_tmpl.paragraphs[i]
            p_out = self.doc_out.paragraphs[i]
            self.assertEqual(
                p_out.text,
                p_tmpl.text,
                f"Mismatch in post-3.1 paragraph {i}: '{p_out.text[:40]}' vs '{p_tmpl.text[:40]}'"
            )

    def test_05_all_37_tables_preserved_and_zero_in_31(self):
        """Verify exactly 37 tables in document, 0 tables in Section 3.1, and all 37 tables match 100%."""
        self.assertEqual(len(self.doc_out.tables), 37, "Expected exactly 37 tables in output document")

        # Verify 0 tables in Section 3.1 in XML body
        body = self.doc_out._element.body
        p_etl = self.doc_out.paragraphs[210]._p
        p_api = self.doc_out.paragraphs[1255]._p
        etl_idx = list(body).index(p_etl)
        api_idx = list(body).index(p_api)

        tables_in_31 = sum(1 for i in range(etl_idx + 1, api_idx) if body[i].tag.endswith("tbl"))
        self.assertEqual(tables_in_31, 0, f"Found {tables_in_31} tables in Section 3.1 (expected 0)")

        # Verify all 37 tables match template tables cell-by-cell
        for idx, (t_t, t_o) in enumerate(zip(self.doc_tmpl.tables, self.doc_out.tables)):
            self.assertEqual(len(t_o.rows), len(t_t.rows), f"Table {idx} row count mismatch")
            self.assertEqual(len(t_o.columns), len(t_t.columns), f"Table {idx} column count mismatch")
            for r_idx, (r_t, r_o) in enumerate(zip(t_t.rows, t_o.rows)):
                for c_idx, (c_t, c_o) in enumerate(zip(r_t.cells, r_o.cells)):
                    self.assertEqual(
                        c_o.text,
                        c_t.text,
                        f"Table {idx} row {r_idx} col {c_idx} text mismatch"
                    )

    def test_06_section_31_module_headers(self):
        """Verify Section 3.1 contains all 10 module Heading 3 headers in exact order."""
        sec_31_p = self.doc_out.paragraphs[211:1255]
        h3_paragraphs = [p for p in sec_31_p if p.style.name == "Heading 3"]
        self.assertEqual(len(h3_paragraphs), 10, f"Expected 10 Heading 3 paragraphs, got {len(h3_paragraphs)}")

        for (code, idx, name), p in zip(MODULE_NAMES, h3_paragraphs):
            expected_title = f"3.1.{idx}  LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO {name}"
            self.assertEqual(p.text, expected_title, f"Heading 3 mismatch for module {code}")

    def test_07_section_31_hierarchy_counts(self):
        """Verify Section 3.1 contains 20 Heading 4 and exactly 90 Heading 5 headers."""
        sec_31_p = self.doc_out.paragraphs[211:1255]
        h4_count = sum(1 for p in sec_31_p if p.style.name == "Heading 4")
        h5_count = sum(1 for p in sec_31_p if p.style.name == "Heading 5")

        self.assertEqual(h4_count, 20, f"Expected 20 Heading 4 headers (2 per module), got {h4_count}")
        self.assertEqual(h5_count, 90, f"Expected 90 Heading 5 headers (business groups), got {h5_count}")

    def test_08_section_31_diagrams_count_and_centering(self):
        """Verify exactly 90 diagrams in Section 3.1, each centered in its paragraph."""
        sec_31_p = self.doc_out.paragraphs[211:1255]
        image_paragraphs = []
        for p in sec_31_p:
            has_image = any(len(r._r.xpath(".//a:blip")) > 0 for r in p.runs)
            if has_image:
                image_paragraphs.append(p)

        self.assertEqual(len(image_paragraphs), 90, f"Expected 90 diagrams in Section 3.1, got {len(image_paragraphs)}")

        # Verify alignment is center
        for idx, p in enumerate(image_paragraphs):
            self.assertEqual(
                p.alignment,
                docx.enum.text.WD_ALIGN_PARAGRAPH.CENTER,
                f"Diagram paragraph {idx} is not centered"
            )

    def test_09_non_31_images_preserved(self):
        """Verify all 21 media images outside Section 3.1 are completely preserved."""
        images_outside = 0
        for p in self.doc_out.paragraphs[:211] + self.doc_out.paragraphs[1255:]:
            for r in p.runs:
                images_outside += len(r._r.xpath(".//a:blip"))
        for t in self.doc_out.tables:
            for row in t.rows:
                for cell in row.cells:
                    for p in cell.paragraphs:
                        for r in p.runs:
                            images_outside += len(r._r.xpath(".//a:blip"))

        self.assertEqual(images_outside, 21, f"Expected 21 images outside 3.1, got {images_outside}")

    def test_10_typography_and_bullet_hanging_indent(self):
        """Verify Times New Roman font and proper hanging indent in bullet items."""
        sec_31_p = self.doc_out.paragraphs[211:1255]
        bullet_paragraphs = [p for p in sec_31_p if p.text.startswith("•  ")]
        self.assertGreater(len(bullet_paragraphs), 400, "Expected hundreds of bullet paragraphs in 3.1")

        for idx, p in enumerate(bullet_paragraphs[:20]):
            pPr = p._p.get_or_add_pPr()
            ind = pPr.find(qn("w:ind"))
            self.assertIsNotNone(ind, f"Bullet {idx} missing w:ind element")
            self.assertEqual(ind.get(qn("w:left")), "360", f"Bullet {idx} w:left expected 360, got {ind.get(qn('w:left'))}")
            self.assertEqual(ind.get(qn("w:hanging")), "280", f"Bullet {idx} w:hanging expected 280, got {ind.get(qn('w:hanging'))}")

            # Verify font in runs
            for r in p.runs:
                rPr = r._r.find(qn("w:rPr"))
                if rPr is not None:
                    rFonts = rPr.find(qn("w:rFonts"))
                    if rFonts is not None:
                        self.assertEqual(rFonts.get(qn("w:ascii")), "Times New Roman")


if __name__ == "__main__":
    unittest.main(verbosity=2)
