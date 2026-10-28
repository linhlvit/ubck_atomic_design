"""Adversarial Verification & Stress-Testing Suite for Q5 Document (Milestone 2 Challenger 1).

Oracles & Stress Tests:
1. Template Immutability: SHA-256, byte count, distinctness from output.
2. Non-3.1 Paragraph Invariance: Byte-for-byte XML DOM string equality across all 682 non-3.1 paragraphs.
3. Table Invariance: Byte-for-byte XML DOM string equality across all 37 tables + exact body child placement.
4. Page Setup & Section Breaks: Margins, landscape/portrait geometry, exact sectPr XML matching.
5. OPC Package Integrity: Zip CRC32 verification, XML well-formedness across all package parts.
6. Relationship Graph Integrity: Zero orphan r:ids in document.xml, zero missing targets in document.xml.rels.
7. DrawingML Integrity: Zero docPr id collisions, unique integer drawing IDs.
8. Media & PNG Oracle: 8-byte PNG magic header, IHDR dimension checks (>0), size > 10KB, 21 non-3.1 media byte equality.
9. Full DOM Traversal: Complete exception-free traversal of paragraphs, runs, shapes, tables, cells, headers, footers.
10. Section 3.1 Structural Quality: 10 H3, 20 H4, 90 H5, 90 centered flowcharts, Times New Roman, hanging indent w:hanging="280".
11. Monotonic Numbering & Module Partitioning: Strict 1-based sequential numbering across all 10 modules and 90 flows.
12. Zero Placeholder & Leakage Oracle: Scans for [TBD], TODO, FIXME, NaN, null, undefined in Section 3.1.
13. DrawingML Geometry & EMU Bounds: Valid positive extents (cx > 0, cy > 0) on all 111 drawings.
14. Content Types Complete Coverage: Every part in zip has an explicit or default MIME mapping in [Content_Types].xml.
"""

from __future__ import annotations

import hashlib
import posixpath
import struct
import unittest
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path

import docx
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn

REPO_ROOT = Path(__file__).resolve().parents[1]
TEMPLATE_DOCX = REPO_ROOT / "docs" / "templates" / "sample" / "UBCKNN_Q5_Tai_lieu_phan_tich_thiet_ke_v1.1_20260828.docx"
OUTPUT_DOCX = REPO_ROOT / "docs" / "output" / "UBCKNN_Q5_Tai_lieu_phan_tich_thiet_ke_v1.2_20261028.docx"

EXPECTED_TEMPLATE_SHA256 = "324257ee221bc7f341e70f97b6a57ba1663295e474d8f083bb1393384b7dd5a9"
EXPECTED_TEMPLATE_SIZE = 16_325_406

EXPECTED_MODULES = [
    ("TT", "1", "HOẠT ĐỘNG THANH TRA", 5),
    ("NHNCK", "2", "NGƯỜI HÀNH NGHỀ CHỨNG KHOÁN", 10),
    ("NDTNN", "3", "NHÀ ĐẦU TƯ NƯỚC NGOÀI", 7),
    ("QLCB", "4", "QUẢN LÝ CHÀO BÁN", 3),
    ("GSDC", "5", "GIÁM SÁT CÔNG TY ĐẠI CHÚNG", 2),
    ("GSTT", "6", "GIÁM SÁT THỊ TRƯỜNG", 3),
    ("QLQ", "7", "CÔNG TY QUẢN LÝ QUỸ (AMC)", 11),
    ("QLKD", "8", "HOẠT ĐỘNG CÔNG TY CHỨNG KHOÁN", 18),
    ("PTTT", "9", "PHÂN TÍCH THỊ TRƯỜNG", 10),
    ("TKNB", "10", "THỐNG KÊ THỊ TRƯỜNG", 21),
]


class TestChallenger1Q5Adversarial(unittest.TestCase):
    """Adversarial stress harness for Q5 document update and content preservation."""

    @classmethod
    def setUpClass(cls):
        cls.tmpl_path = TEMPLATE_DOCX
        cls.out_path = OUTPUT_DOCX

        cls.doc_tmpl = docx.Document(cls.tmpl_path)
        cls.doc_out = docx.Document(cls.out_path)

        with open(cls.tmpl_path, "rb") as f:
            cls.tmpl_bytes = f.read()
        with open(cls.out_path, "rb") as f:
            cls.out_bytes = f.read()

    def test_01_template_immutability_and_distinct_output(self):
        """Oracle 1: Template SHA-256 and byte size must be 100% immutable; output must be distinct."""
        self.assertTrue(self.tmpl_path.is_file(), "Original template file must exist")
        self.assertEqual(
            len(self.tmpl_bytes),
            EXPECTED_TEMPLATE_SIZE,
            f"Original template size mutated: expected {EXPECTED_TEMPLATE_SIZE}, got {len(self.tmpl_bytes)}"
        )
        current_tmpl_sha = hashlib.sha256(self.tmpl_bytes).hexdigest()
        self.assertEqual(
            current_tmpl_sha,
            EXPECTED_TEMPLATE_SHA256,
            f"Original template SHA-256 mutated: {current_tmpl_sha}"
        )

        # Output file checks
        self.assertTrue(self.out_path.is_file(), "Output docx file must exist")
        out_sha = hashlib.sha256(self.out_bytes).hexdigest()
        self.assertNotEqual(
            out_sha,
            EXPECTED_TEMPLATE_SHA256,
            "Adversarial alert: Output SHA-256 is identical to template; update did not occur!"
        )
        self.assertGreater(len(self.out_bytes), 10_000_000, "Output file suspiciously small")

    def test_02_non_31_paragraphs_byte_for_byte_xml_equality(self):
        """Oracle 2: Deep byte-for-byte XML DOM string equality across all 682 non-3.1 paragraphs."""
        # 1. Pre-3.1 paragraphs: index 0 to 210 (211 paragraphs total)
        for i in range(211):
            p_t = self.doc_tmpl.paragraphs[i]
            p_o = self.doc_out.paragraphs[i]
            self.assertEqual(
                p_o.text,
                p_t.text,
                f"Text mismatch in pre-3.1 paragraph {i}: '{p_o.text[:40]}' vs '{p_t.text[:40]}'"
            )
            xml_t = ET.tostring(p_t._p, encoding="utf-8")
            xml_o = ET.tostring(p_o._p, encoding="utf-8")
            self.assertEqual(
                xml_o,
                xml_t,
                f"XML DOM mismatch in pre-3.1 paragraph {i} ('{p_t.text[:30]}')"
            )

        # Paragraph 210 is specifically Section 3.1 anchor header
        self.assertEqual(self.doc_out.paragraphs[210].text.strip(), "Phân hệ ETL")

        # Paragraph 1255 is specifically Section 3.2 anchor header
        self.assertEqual(
            self.doc_out.paragraphs[1255].text.strip(),
            "Phân hệ tích hợp dữ liệu ( API )"
        )

        # 2. Post-3.1 paragraphs: index 1255 to 1725 (471 paragraphs total)
        self.assertEqual(len(self.doc_out.paragraphs), len(self.doc_tmpl.paragraphs))
        for i in range(1255, len(self.doc_tmpl.paragraphs)):
            p_t = self.doc_tmpl.paragraphs[i]
            p_o = self.doc_out.paragraphs[i]
            self.assertEqual(
                p_o.text,
                p_t.text,
                f"Text mismatch in post-3.1 paragraph {i}: '{p_o.text[:40]}' vs '{p_t.text[:40]}'"
            )
            xml_t = ET.tostring(p_t._p, encoding="utf-8")
            xml_o = ET.tostring(p_o._p, encoding="utf-8")
            self.assertEqual(
                xml_o,
                xml_t,
                f"XML DOM mismatch in post-3.1 paragraph {i} ('{p_t.text[:30]}')"
            )

    def test_03_all_37_tables_byte_for_byte_xml_and_placement_invariance(self):
        """Oracle 3: All 37 tables must have identical XML trees and exact same child indices in body."""
        self.assertEqual(len(self.doc_out.tables), 37, "Expected exactly 37 tables in output document")
        self.assertEqual(len(self.doc_tmpl.tables), 37, "Expected exactly 37 tables in template document")

        # Table XML byte equality
        for idx in range(37):
            t_t = self.doc_tmpl.tables[idx]
            t_o = self.doc_out.tables[idx]
            xml_t = ET.tostring(t_t._tbl, encoding="utf-8")
            xml_o = ET.tostring(t_o._tbl, encoding="utf-8")
            self.assertEqual(
                xml_o,
                xml_t,
                f"XML DOM mismatch in table {idx}"
            )

        # Position invariance in body element sequence
        body_t = self.doc_tmpl._element.body
        body_o = self.doc_out._element.body
        tbl_indices_t = [idx for idx, c in enumerate(body_t) if c.tag.endswith("tbl")]
        tbl_indices_o = [idx for idx, c in enumerate(body_o) if c.tag.endswith("tbl")]
        self.assertEqual(
            tbl_indices_o,
            tbl_indices_t,
            f"Table positions shifted in body: {tbl_indices_o} vs {tbl_indices_t}"
        )

        # Assert 0 tables exist in Section 3.1
        p_etl = self.doc_out.paragraphs[210]._p
        p_api = self.doc_out.paragraphs[1255]._p
        etl_child = list(body_o).index(p_etl)
        api_child = list(body_o).index(p_api)
        tables_in_31 = sum(1 for i in range(etl_child + 1, api_child) if body_o[i].tag.endswith("tbl"))
        self.assertEqual(tables_in_31, 0, f"Found {tables_in_31} tables inside Section 3.1")

    def test_04_section_breaks_geometry_and_xml_invariance(self):
        """Oracle 4: Section breaks, portrait/landscape orientation and XML sectPr preserved 100%."""
        self.assertEqual(len(self.doc_out.sections), 2, "Expected exactly 2 sections")
        self.assertEqual(len(self.doc_tmpl.sections), 2, "Expected exactly 2 sections")

        for i in range(2):
            s_t = self.doc_tmpl.sections[i]
            s_o = self.doc_out.sections[i]
            self.assertEqual(s_o.orientation, s_t.orientation, f"Section {i} orientation mismatch")
            self.assertEqual(s_o.page_width, s_t.page_width, f"Section {i} page_width mismatch")
            self.assertEqual(s_o.page_height, s_t.page_height, f"Section {i} page_height mismatch")
            self.assertEqual(s_o.left_margin, s_t.left_margin, f"Section {i} left_margin mismatch")
            self.assertEqual(s_o.right_margin, s_t.right_margin, f"Section {i} right_margin mismatch")
            self.assertEqual(s_o.top_margin, s_t.top_margin, f"Section {i} top_margin mismatch")
            self.assertEqual(s_o.bottom_margin, s_t.bottom_margin, f"Section {i} bottom_margin mismatch")
            self.assertEqual(
                s_o.different_first_page_header_footer,
                s_t.different_first_page_header_footer,
                f"Section {i} different_first_page mismatch"
            )

        # XML sectPr element check
        body_t = self.doc_tmpl._element.body
        body_o = self.doc_out._element.body

        def extract_sect_pr(body):
            res = []
            for idx, elem in enumerate(body):
                if elem.tag.endswith("sectPr"):
                    res.append((idx, ET.tostring(elem, encoding="utf-8")))
                pPr = elem.find(qn("w:pPr"))
                if pPr is not None:
                    sectPr = pPr.find(qn("w:sectPr"))
                    if sectPr is not None:
                        res.append((idx, ET.tostring(sectPr, encoding="utf-8")))
            return res

        sect_t = extract_sect_pr(body_t)
        sect_o = extract_sect_pr(body_o)
        self.assertEqual(len(sect_o), 2)
        self.assertEqual(sect_o[0][0], 212, "Section break 0 must be at child 212")
        self.assertEqual(sect_o[1][0], 1764, "Final section break must be at child 1764")
        self.assertEqual(sect_o[0][1], sect_t[0][1], "Section break 0 XML mismatch")
        self.assertEqual(sect_o[1][1], sect_t[1][1], "Final section break XML mismatch")

    def test_05_opc_zip_integrity_and_xml_well_formedness(self):
        """Oracle 5: ZIP CRC32 integrity check and XML parse verification on every package part."""
        with zipfile.ZipFile(self.out_path, "r") as zf:
            bad_file = zf.testzip()
            self.assertIsNone(bad_file, f"Corrupted file inside docx ZIP: {bad_file}")

            # Parse all XML / rels files
            for name in zf.namelist():
                if name.endswith(".xml") or name.endswith(".rels"):
                    content = zf.read(name)
                    try:
                        ET.fromstring(content)
                    except Exception as e:
                        self.fail(f"XML parse failure in part {name}: {e}")

    def test_06_relationship_graph_and_orphan_detection(self):
        """Oracle 6: Relationship graph verification - 0 orphan rIds, 0 missing targets, 0 orphan media."""
        with zipfile.ZipFile(self.out_path, "r") as zf:
            # Parse document.xml.rels
            rels_root = ET.fromstring(zf.read("word/_rels/document.xml.rels"))
            rel_ids = {}
            for rel in rels_root:
                r_id = rel.attrib.get("Id")
                target = rel.attrib.get("Target")
                rel_ids[r_id] = target

            # 1. Every internal relationship target must exist in ZIP
            for r_id, target in rel_ids.items():
                if not target.startswith("http://") and not target.startswith("https://") and not target.startswith("mailto:"):
                    norm_target = posixpath.normpath(posixpath.join("word", target))
                    self.assertIn(
                        norm_target,
                        zf.namelist(),
                        f"Relationship {r_id} points to non-existent target in zip: {norm_target}"
                    )

            # 2. Every r:id, r:embed, r:link in document.xml must exist in document.xml.rels
            doc_root = ET.fromstring(zf.read("word/document.xml"))
            for elem in doc_root.iter():
                for attr_k, attr_v in elem.attrib.items():
                    if "relationships" in attr_k or attr_k.endswith("}id") or attr_k.endswith("}embed") or attr_k.endswith("}link"):
                        if attr_v.startswith("rId"):
                            self.assertIn(
                                attr_v,
                                rel_ids,
                                f"Orphan r:id found in document.xml element <{elem.tag}>: {attr_v}"
                            )

            # 3. Every media file in word/media/ must have a relationship pointing to it
            media_files = [f for f in zf.namelist() if f.startswith("word/media/")]
            self.assertEqual(len(media_files), 111, f"Expected 111 media files, got {len(media_files)}")
            all_rel_norm_targets = {
                posixpath.normpath(posixpath.join("word", t))
                for t in rel_ids.values()
                if not t.startswith("http")
            }
            for m in media_files:
                self.assertIn(m, all_rel_norm_targets, f"Orphan media file in zip without relationship: {m}")

    def test_07_drawingml_docpr_unique_id_stress_test(self):
        """Oracle 7: All DrawingML wp:docPr IDs must be unique positive integers."""
        with zipfile.ZipFile(self.out_path, "r") as zf:
            doc_root = ET.fromstring(zf.read("word/document.xml"))
            docpr_ids = []
            for docpr in doc_root.iter("{http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing}docPr"):
                d_id = docpr.attrib.get("id")
                self.assertIsNotNone(d_id, "Found wp:docPr without id attribute")
                self.assertTrue(d_id.isdigit(), f"wp:docPr id is not a valid integer: {d_id}")
                docpr_ids.append(int(d_id))

            self.assertEqual(len(docpr_ids), 111, f"Expected 111 drawing docPr elements, got {len(docpr_ids)}")
            self.assertEqual(len(set(docpr_ids)), 111, f"Duplicate drawing docPr IDs found! {len(docpr_ids) - len(set(docpr_ids))} collisions")

    def test_08_media_png_headers_and_non_31_media_invariance(self):
        """Oracle 8: Verify valid PNG binary headers, dimensions > 0, and non-3.1 image invariance."""
        with zipfile.ZipFile(self.out_path, "r") as zf_o, zipfile.ZipFile(self.tmpl_path, "r") as zf_t:
            # 1. Non-3.1 images (21 images) must be byte-for-byte identical to template
            for idx in range(1, 22):
                img_name = f"word/media/image{idx}.png"
                self.assertIn(img_name, zf_o.namelist())
                self.assertIn(img_name, zf_t.namelist())
                hash_o = hashlib.sha256(zf_o.read(img_name)).hexdigest()
                hash_t = hashlib.sha256(zf_t.read(img_name)).hexdigest()
                self.assertEqual(
                    hash_o,
                    hash_t,
                    f"Non-3.1 media image {img_name} modified! SHA-256 differs"
                )

            # 2. Section 3.1 images (90 images: image22.png to image111.png)
            png_magic = b"\x89PNG\r\n\x1a\n"
            for idx in range(22, 112):
                img_name = f"word/media/image{idx}.png"
                data = zf_o.read(img_name)
                self.assertGreater(len(data), 10_000, f"Flowchart {img_name} too small ({len(data)} bytes)")
                self.assertEqual(data[:8], png_magic, f"{img_name} does not have valid PNG magic header")

                # Verify IHDR chunk
                ihdr_type = data[12:16]
                self.assertEqual(ihdr_type, b"IHDR", f"{img_name} missing IHDR chunk")
                width, height = struct.unpack(">II", data[16:24])
                self.assertGreater(width, 0, f"{img_name} has invalid width: {width}")
                self.assertGreater(height, 0, f"{img_name} has invalid height: {height}")

    def test_09_full_dom_traversal_oracle(self):
        """Oracle 9: Comprehensive exception-free traversal of paragraphs, runs, tables, cells, headers."""
        # Traverse all paragraphs and runs
        para_count = 0
        run_count = 0
        for p in self.doc_out.paragraphs:
            para_count += 1
            for r in p.runs:
                run_count += 1
                _ = r.text
        self.assertEqual(para_count, 1726)
        self.assertGreater(run_count, 3000)

        # Traverse all tables, rows, cells
        table_count = 0
        cell_count = 0
        for t in self.doc_out.tables:
            table_count += 1
            for row in t.rows:
                for cell in row.cells:
                    cell_count += 1
                    _ = cell.text
        self.assertEqual(table_count, 37)
        self.assertGreater(cell_count, 500)

        # Traverse sections, headers, footers
        for s in self.doc_out.sections:
            _ = s.header.paragraphs
            _ = s.footer.paragraphs

    def test_10_section_31_structural_quality_and_styling(self):
        """Oracle 10: Section 3.1 contains 10 H3, 20 H4, 90 H5, 90 centered flowcharts, Times New Roman, hanging indent."""
        sec_31_p = self.doc_out.paragraphs[211:1255]
        self.assertEqual(len(sec_31_p), 1044, f"Expected 1044 paragraphs in 3.1, got {len(sec_31_p)}")

        # Heading 3 verification (10 modules in exact order)
        h3_paragraphs = [p for p in sec_31_p if p.style.name == "Heading 3"]
        self.assertEqual(len(h3_paragraphs), 10, f"Expected 10 Heading 3, got {len(h3_paragraphs)}")
        for (code, idx, name, _count), p in zip(EXPECTED_MODULES, h3_paragraphs):
            expected_title = f"3.1.{idx}  LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO {name}"
            self.assertEqual(p.text, expected_title, f"Heading 3 mismatch for module {code}")

        # Heading 4 verification (20 headers: 2 per module)
        h4_paragraphs = [p for p in sec_31_p if p.style.name == "Heading 4"]
        self.assertEqual(len(h4_paragraphs), 20, f"Expected 20 Heading 4, got {len(h4_paragraphs)}")

        # Heading 5 verification (90 headers: business flows)
        h5_paragraphs = [p for p in sec_31_p if p.style.name == "Heading 5"]
        self.assertEqual(len(h5_paragraphs), 90, f"Expected 90 Heading 5, got {len(h5_paragraphs)}")

        # 90 Centered Diagrams
        image_paragraphs = []
        for p in sec_31_p:
            if any(len(r._r.xpath(".//a:blip")) > 0 for r in p.runs):
                image_paragraphs.append(p)
        self.assertEqual(len(image_paragraphs), 90, f"Expected 90 diagram paragraphs, got {len(image_paragraphs)}")
        for idx, p in enumerate(image_paragraphs):
            self.assertEqual(
                p.alignment,
                WD_ALIGN_PARAGRAPH.CENTER,
                f"Diagram paragraph {idx} is not centered"
            )

        # Hanging indent on bullets
        bullet_paragraphs = [p for p in sec_31_p if p.text.startswith("•  ")]
        self.assertGreater(len(bullet_paragraphs), 400)
        for idx, p in enumerate(bullet_paragraphs[:30]):
            pPr = p._p.find(qn("w:pPr"))
            self.assertIsNotNone(pPr, f"Bullet {idx} missing pPr")
            ind = pPr.find(qn("w:ind"))
            self.assertIsNotNone(ind, f"Bullet {idx} missing w:ind element")
            self.assertEqual(ind.get(qn("w:left")), "360")
            self.assertEqual(ind.get(qn("w:hanging")), "280")

    def test_11_monotonic_heading_numbering_and_partitioning(self):
        """Oracle 11: Strict 1-based sequential numbering across all 10 modules and 90 flows."""
        sec_31_p = self.doc_out.paragraphs[211:1255]
        h5_paragraphs = [p.text for p in sec_31_p if p.style.name == "Heading 5"]
        self.assertEqual(len(h5_paragraphs), 90)

        # Verify exact counts per module
        h5_iter = iter(h5_paragraphs)
        for code, mod_idx, name, flow_count in EXPECTED_MODULES:
            for f_idx in range(1, flow_count + 1):
                expected_prefix = f"3.1.{mod_idx}.2.{f_idx} "
                h5_text = next(h5_iter)
                self.assertTrue(
                    h5_text.startswith(expected_prefix),
                    f"Heading 5 numbering sequence broken for module {code}: expected {expected_prefix}, got {h5_text[:30]}"
                )

    def test_12_zero_placeholder_and_leakage_oracle(self):
        """Oracle 12: Ensure no draft placeholders or unrendered tokens in Section 3.1."""
        sec_31_p = self.doc_out.paragraphs[211:1255]
        forbidden_tokens = ["[TBD]", "TODO", "FIXME", "NaN", "null", "undefined", "chưa có mô tả"]
        for idx, p in enumerate(sec_31_p):
            for token in forbidden_tokens:
                self.assertNotIn(
                    token,
                    p.text,
                    f"Forbidden placeholder token '{token}' leaked into Section 3.1 paragraph {idx + 211}: '{p.text[:60]}'"
                )

    def test_13_drawingml_extents_geometry_validity(self):
        """Oracle 13: All 111 drawings must have strictly positive EMUs (cx > 0, cy > 0)."""
        with zipfile.ZipFile(self.out_path, "r") as zf:
            doc_root = ET.fromstring(zf.read("word/document.xml"))
            extents = []
            for extent in doc_root.iter("{http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing}extent"):
                cx = int(extent.attrib.get("cx", "0"))
                cy = int(extent.attrib.get("cy", "0"))
                self.assertGreater(cx, 0, f"Found non-positive cx in drawing extent: {cx}")
                self.assertGreater(cy, 0, f"Found non-positive cy in drawing extent: {cy}")
                extents.append((cx, cy))
            self.assertEqual(len(extents), 111, f"Expected 111 drawing extents, got {len(extents)}")

    def test_14_content_types_complete_coverage(self):
        """Oracle 14: Every single file in the zip must have a valid MIME mapping in [Content_Types].xml."""
        with zipfile.ZipFile(self.out_path, "r") as zf:
            ct_root = ET.fromstring(zf.read("[Content_Types].xml"))
            defaults = {d.attrib.get("Extension"): d.attrib.get("ContentType") for d in ct_root.findall("{http://schemas.openxmlformats.org/package/2006/content-types}Default")}
            overrides = {o.attrib.get("PartName"): o.attrib.get("ContentType") for o in ct_root.findall("{http://schemas.openxmlformats.org/package/2006/content-types}Override")}

            for name in zf.namelist():
                if name == "[Content_Types].xml":
                    continue
                part_name = "/" + name
                ext = name.split(".")[-1] if "." in name else ""
                has_mapping = (part_name in overrides) or (ext in defaults)
                self.assertTrue(
                    has_mapping,
                    f"Zip part {name} lacks ContentType mapping in [Content_Types].xml"
                )


if __name__ == "__main__":
    unittest.main(verbosity=2)
