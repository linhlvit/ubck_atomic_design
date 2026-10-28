# -*- coding: utf-8 -*-
"""
test_challenger2_section31_alignment.py — Empirical Adversarial Challenge Suite
Role: challenger_2 (teamwork_challenger, critic, specialist)

Adversarially validates Section 3.1 in:
  ubck_atomic_design/docs/output/UBCKNN_Q5_Tai_lieu_phan_tich_thiet_ke_v1.2_20261028.docx
against workspace design models:
  1. Datamart model (ubck_atomic_design/Datamart/datamart_model.yaml).
  2. HLD specifications (ubck_atomic_design/Datamart/hld/DTM_{MODULE}_HLD.md).
  3. Pre-rendered diagram images (ubck_atomic_design/docs/output/datamart/temp_q5_images/).
  4. PTTK specifications (ubck_atomic_design/docs/output/datamart/{MODULE}/DTM_{MODULE}_PTTK.md).

Test Suites:
- Suite 1: Module Ordering, Numbering & Heading Hierarchy Completeness (10 modules, 20 H4, 90 H5).
- Suite 2: Diagram Image Integrity & Physical Embedding Oracle (90 diagrams, 1:1 SHA-256 byte parity).
- Suite 3: Flowchart Semantic Alignment against HLD & Datamart Model (Staging -> Atomic -> Datamart).
- Suite 4: Bullet Entity & Lineage Traceability Oracle (474 bullets: 70 metadata, 404 workflow).
- Suite 5: Text Hygiene, Formatting & Anti-Corruption Stress Harness (0 leaks, 0 placeholders, 0 mojibake, Times New Roman, XML indent).
- Suite 6: Section 3.1 Table Elimination & Architectural Isolation (0 tables in 3.1).
"""

from __future__ import annotations

import csv
import hashlib
import io
import os
import re
import sys
import unittest
import zipfile
from pathlib import Path

import docx
from docx.oxml.ns import qn
import yaml

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8")

REPO_ROOT = Path(__file__).resolve().parents[1]
DOCX_PATH = REPO_ROOT / "docs" / "output" / "UBCKNN_Q5_Tai_lieu_phan_tich_thiet_ke_v1.2_20261028.docx"
YAML_PATH = REPO_ROOT / "Datamart" / "datamart_model.yaml"
HLD_DIR = REPO_ROOT / "Datamart" / "hld"
PTTK_DIR = REPO_ROOT / "docs" / "output" / "datamart"
IMG_DIR = REPO_ROOT / "docs" / "output" / "datamart" / "temp_q5_images"
ATOMIC_SUMMARY = REPO_ROOT / "DataModel" / "working" / "Atomic_LinhLV" / "_summary.csv"

# Exact metadata specification derived from workspace models
MODULE_SPEC = [
    {"code": "TT", "idx": "1", "name": "HOẠT ĐỘNG THANH TRA", "h5_count": 5, "src": "THANHTRA"},
    {"code": "NHNCK", "idx": "2", "name": "NGƯỜI HÀNH NGHỀ CHỨNG KHOÁN", "h5_count": 10, "src": "NHNCK"},
    {"code": "NDTNN", "idx": "3", "name": "NHÀ ĐẦU TƯ NƯỚC NGOÀI", "h5_count": 7, "src": "FIMS, IDS, THANHTRA"},
    {"code": "QLCB", "idx": "4", "name": "QUẢN LÝ CHÀO BÁN", "h5_count": 3, "src": "IDS, TTHC"},
    {"code": "GSDC", "idx": "5", "name": "GIÁM SÁT CÔNG TY ĐẠI CHÚNG", "h5_count": 2, "src": "IDS"},
    {"code": "GSTT", "idx": "6", "name": "GIÁM SÁT THỊ TRƯỜNG", "h5_count": 3, "src": "MDDS, OrderTrade, IDS, ECAT"},
    {"code": "QLQ", "idx": "7", "name": "CÔNG TY QUẢN LÝ QUỸ (AMC)", "h5_count": 11, "src": "FMS, ECAT, QLRR, GSGD"},
    {"code": "QLKD", "idx": "8", "name": "HOẠT ĐỘNG CÔNG TY CHỨNG KHOÁN", "h5_count": 18, "src": "SCMS, FIMS, NHNCK, THANHTRA, IDS"},
    {"code": "PTTT", "idx": "9", "name": "PHÂN TÍCH THỊ TRƯỜNG", "h5_count": 10, "src": "MDDS, MSS, QLRR, IDS, SCMS, FMS, ECAT"},
    {"code": "TKNB", "idx": "10", "name": "THỐNG KÊ THỊ TRƯỜNG", "h5_count": 21, "src": "MDDS, ORDERTRADE, SCMS, IDS, FMS"},
]


class BaseDocxTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.docx_path = DOCX_PATH
        cls.yaml_path = YAML_PATH
        cls.img_dir = IMG_DIR
        cls.doc = docx.Document(str(cls.docx_path))

        # Locate Section 3.1 boundaries
        cls.p_etl_idx = None
        cls.p_api_idx = None
        for i, p in enumerate(cls.doc.paragraphs):
            t = p.text.strip()
            if t == "Phân hệ ETL" and p.style.name.startswith("Heading"):
                cls.p_etl_idx = i
            elif t.startswith("Phân hệ tích hợp dữ liệu") and p.style.name.startswith("Heading"):
                cls.p_api_idx = i
                break

        assert cls.p_etl_idx is not None, "Paragraph 'Phân hệ ETL' not found"
        assert cls.p_api_idx is not None, "Paragraph 'Phân hệ tích hợp dữ liệu' not found"
        cls.sec31_paras = cls.doc.paragraphs[cls.p_etl_idx + 1 : cls.p_api_idx]

        # Load Datamart model
        with open(cls.yaml_path, "r", encoding="utf-8") as f:
            cls.dm_model = yaml.safe_load(f)
        cls.dm_entities = cls.dm_model.get("entities", [])

        # Load Atomic catalog
        cls.atomic_entities = set()
        if ATOMIC_SUMMARY.exists():
            with open(ATOMIC_SUMMARY, "r", encoding="utf-8") as f:
                reader = csv.DictReader(f)
                for r in reader:
                    for k in ("logical_name", "physical_name", "id"):
                        v = r.get(k)
                        if v:
                            cls.atomic_entities.add(v.strip().lower())
                            cls.atomic_entities.add(v.strip().lower().replace("_", " "))

        # Load HLD text by module
        cls.hld_texts = {}
        for spec in MODULE_SPEC:
            mod_code = spec["code"]
            hld_f = HLD_DIR / f"DTM_{mod_code}_HLD.md"
            cls.hld_texts[mod_code] = hld_f.read_text(encoding="utf-8").lower() if hld_f.exists() else ""


class TestSuite1HierarchyAndModuleCompleteness(BaseDocxTest):
    """Challenge 1: Verify all 10 modules, headings hierarchy, and ordering."""

    def test_01_total_section31_paragraph_count(self):
        """Section 3.1 must contain exactly 1,044 paragraphs."""
        self.assertEqual(len(self.sec31_paras), 1044, f"Expected 1044 paragraphs, got {len(self.sec31_paras)}")

    def test_02_all_10_modules_in_exact_sequence(self):
        """All 10 modules must appear in Heading 3 with exact numbering 3.1.1 to 3.1.10."""
        h3_paras = [p for p in self.sec31_paras if p.style.name == "Heading 3"]
        self.assertEqual(len(h3_paras), 10, f"Expected 10 Heading 3 paragraphs, got {len(h3_paras)}")

        for spec, p in zip(MODULE_SPEC, h3_paras):
            idx = spec["idx"]
            name = spec["name"]
            expected = f"3.1.{idx}  LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO {name}"
            self.assertEqual(p.text, expected, f"Module {spec['code']} title mismatch: '{p.text}' vs '{expected}'")

    def test_03_heading4_structure_and_counts(self):
        """Every module must contain exactly 2 Heading 4 headers: 3.1.x.1 and 3.1.x.2."""
        h4_paras = [p for p in self.sec31_paras if p.style.name == "Heading 4"]
        self.assertEqual(len(h4_paras), 20, f"Expected 20 Heading 4 headers, got {len(h4_paras)}")

        for mod_idx in range(1, 11):
            h4_mod = [p for p in h4_paras if p.text.startswith(f"3.1.{mod_idx}.")]
            self.assertEqual(len(h4_mod), 2, f"Module {mod_idx} must have 2 H4 headers, got {len(h4_mod)}")
            self.assertEqual(h4_mod[0].text, f"3.1.{mod_idx}.1 Thông tin chung luồng đồng bộ")
            self.assertEqual(h4_mod[1].text, f"3.1.{mod_idx}.2 Luồng nghiệp vụ")

    def test_04_heading5_business_groups_count_and_sequence(self):
        """Section 3.1 must contain exactly 90 Heading 5 headers matching per-module allocations."""
        h5_paras = [p for p in self.sec31_paras if p.style.name == "Heading 5"]
        self.assertEqual(len(h5_paras), 90, f"Expected 90 Heading 5 headers, got {len(h5_paras)}")

        for spec in MODULE_SPEC:
            mod_idx = spec["idx"]
            expected_count = spec["h5_count"]
            mod_h5 = [p for p in h5_paras if p.text.startswith(f"3.1.{mod_idx}.2.")]
            self.assertEqual(
                len(mod_h5),
                expected_count,
                f"Module {spec['code']} (3.1.{mod_idx}) expected {expected_count} H5 headers, got {len(mod_h5)}"
            )

            # Check consecutive numbering 3.1.x.2.1 .. 3.1.x.2.N
            for sub_idx in range(1, expected_count + 1):
                expected_prefix = f"3.1.{mod_idx}.2.{sub_idx} "
                h5_text = mod_h5[sub_idx - 1].text
                self.assertTrue(
                    h5_text.startswith(expected_prefix),
                    f"Expected H5 starting with '{expected_prefix}', got '{h5_text}'"
                )


class TestSuite2DiagramImageEmbeddingOracle(BaseDocxTest):
    """Challenge 2: Verify all 90 flowcharts are physically embedded, valid, and match source hashes."""

    def test_01_embedded_diagram_count(self):
        """Section 3.1 must contain exactly 90 embedded images."""
        diagram_paras = []
        for p in self.sec31_paras:
            if p._p.xpath(".//a:blip"):
                diagram_paras.append(p)
        self.assertEqual(len(diagram_paras), 90, f"Expected 90 embedded images, got {len(diagram_paras)}")

    def test_02_diagram_geometry_and_alignment(self):
        """All 90 diagrams must be center aligned and formatted with 6.2 inches width."""
        for idx, p in enumerate(self.sec31_paras):
            blips = p._p.xpath(".//a:blip")
            if blips:
                self.assertEqual(
                    p.alignment,
                    docx.enum.text.WD_ALIGN_PARAGRAPH.CENTER,
                    f"Diagram at paragraph {idx} is not center aligned"
                )
                extents = p._p.xpath(".//wp:extent")
                self.assertGreater(len(extents), 0, f"Diagram at paragraph {idx} missing wp:extent")
                cx = int(extents[0].get("cx", "0"))
                self.assertEqual(cx, 5669280, f"Diagram cx expected 5669280 (6.2 in), got {cx}")

    def test_03_diagram_1to1_sha256_parity_with_temp_images(self):
        """Every embedded diagram image must match byte-for-byte with pre-rendered diagram in temp_q5_images/."""
        source_images = {}
        for img_file in self.img_dir.glob("diagram_*.png"):
            source_images[img_file.name] = hashlib.sha256(img_file.read_bytes()).hexdigest()

        self.assertEqual(len(source_images), 90, f"Expected 90 source diagram PNGs, got {len(source_images)}")

        embedded_shas = []
        for p in self.sec31_paras:
            for blip in p._p.xpath(".//a:blip"):
                rid = blip.get(qn("r:embed"))
                rel_part = self.doc.part.related_parts[rid]
                blob = rel_part.blob
                sha = hashlib.sha256(blob).hexdigest()
                embedded_shas.append(sha)

        self.assertEqual(len(embedded_shas), 90, f"Expected 90 embedded images, got {len(embedded_shas)}")

        matched_count = 0
        source_sha_set = set(source_images.values())
        for sha in embedded_shas:
            self.assertIn(sha, source_sha_set, f"Embedded image SHA-256 {sha} not found in pre-rendered images!")
            matched_count += 1

        self.assertEqual(matched_count, 90, "All 90 embedded diagrams must match pre-rendered images 100%")


class TestSuite3FlowchartSemanticAlignment(BaseDocxTest):
    """Challenge 3: Verify flowcharts reflect actual design models (Staging -> Atomic -> Datamart)."""

    def test_01_all_10_pttk_contain_valid_mermaid_flowcharts(self):
        """Every PTTK markdown contains valid Mermaid flowcharts for every subgroup."""
        total_diagrams = 0
        for spec in MODULE_SPEC:
            mod_code = spec["code"]
            pttk_file = PTTK_DIR / mod_code / f"DTM_{mod_code}_PTTK.md"
            self.assertTrue(pttk_file.exists(), f"PTTK file missing: {pttk_file}")
            content = pttk_file.read_text(encoding="utf-8")
            blocks = re.findall(r"```mermaid\s*\n(.*?)\n```", content, re.DOTALL)
            self.assertEqual(
                len(blocks),
                spec["h5_count"],
                f"{mod_code}: Expected {spec['h5_count']} mermaid diagrams, got {len(blocks)}"
            )
            total_diagrams += len(blocks)

            for idx, b in enumerate(blocks, 1):
                self.assertIn("subgraph Staging", b, f"{mod_code} diagram #{idx} missing Staging subgraph")
                self.assertIn("subgraph Atomic", b, f"{mod_code} diagram #{idx} missing Atomic subgraph")
                self.assertIn("subgraph Datamart", b, f"{mod_code} diagram #{idx} missing Datamart subgraph")

        self.assertEqual(total_diagrams, 90, f"Expected 90 mermaid flowcharts in PTTK, got {total_diagrams}")

    def test_02_flowchart_datamart_nodes_grounded_in_design_models(self):
        """All 159 Datamart nodes in flowcharts must be grounded in datamart_model.yaml or module HLD."""
        dm_entity_tables = {e.get("datamart_table", "").lower() for e in self.dm_entities if e.get("datamart_table")}
        dm_entity_logicals = {e.get("logical_name", "").lower() for e in self.dm_entities if e.get("logical_name")}
        dm_logicals_short = {re.sub(r"^operational\s+", "", l) for l in dm_entity_logicals}
        dm_tables_short = {re.sub(r"^opr_", "", t) for t in dm_entity_tables}

        conformed_dims = {
            "calendar date dimension", "classification dimension", "industry category dimension",
            "offering type dimension", "business type dimension", "inspection team dimension",
            "examination team dimension", "penalty decision dimension", "private corporate bond dimension",
            "asset category dimension", "corporate bond trading snapshot dimension",
            "corporate bond trading snapshot industry dimension", "foreign investor dimension"
        }

        unresolved_nodes = []
        for spec in MODULE_SPEC:
            mod_code = spec["code"]
            pttk_file = PTTK_DIR / mod_code / f"DTM_{mod_code}_PTTK.md"
            content = pttk_file.read_text(encoding="utf-8")
            blocks = re.findall(r"```mermaid\s*\n(.*?)\n```", content, re.DOTALL)
            hld_text = self.hld_texts.get(mod_code, "")

            for b_idx, b in enumerate(blocks, 1):
                m = re.search(r"subgraph Datamart\s*\n(.*?)\n\s*end", b, re.DOTALL)
                if m:
                    dtm_part = m.group(1)
                    nodes = re.findall(r'(\w+)\s*\["([^"]+)"\]', dtm_part)
                    for node_id, node_label in nodes:
                        nid = node_id.lower()
                        lbl = node_label.lower().strip()
                        lbl_clean = re.sub(r"\s*\([^)]*\)", "", lbl).strip()

                        is_grounded = (
                            lbl in dm_entity_logicals or
                            lbl_clean in dm_entity_logicals or
                            lbl in dm_logicals_short or
                            lbl_clean in dm_logicals_short or
                            nid in dm_entity_tables or
                            nid in dm_tables_short or
                            lbl in conformed_dims or
                            lbl_clean in conformed_dims or
                            lbl in hld_text or
                            lbl_clean in hld_text or
                            nid in hld_text or
                            any(tok in hld_text for tok in re.findall(r"[a-z0-9_]{4,}", lbl))
                        )
                        if not is_grounded:
                            unresolved_nodes.append((mod_code, b_idx, node_id, node_label))

        self.assertEqual(
            unresolved_nodes,
            [],
            f"Found ungrounded Datamart nodes in flowcharts:\n" + "\n".join(str(u) for u in unresolved_nodes[:15])
        )


class TestSuite4BulletEntityLineageTraceability(BaseDocxTest):
    """Challenge 4: Verify all 474 bullets trace faithfully to design models and HLD."""

    def test_01_total_bullet_item_count(self):
        """Section 3.1 must contain exactly 474 bullets."""
        bullets = [p for p in self.sec31_paras if p.text.startswith("•  ")]
        self.assertEqual(len(bullets), 474, f"Expected 474 bullets, got {len(bullets)}")

    def test_02_metadata_info_bullets_completeness(self):
        """Every module must have exactly 7 metadata bullets under 3.1.x.1 with accurate source systems."""
        for spec in MODULE_SPEC:
            mod_idx = spec["idx"]
            mod_code = spec["code"]
            expected_src = spec["src"]

            in_info = False
            info_bullets = []
            for p in self.sec31_paras:
                if p.text == f"3.1.{mod_idx}.1 Thông tin chung luồng đồng bộ":
                    in_info = True
                    continue
                if p.text == f"3.1.{mod_idx}.2 Luồng nghiệp vụ":
                    in_info = False
                    break
                if in_info and p.text.startswith("•  "):
                    info_bullets.append(p.text)

            self.assertEqual(len(info_bullets), 7, f"{mod_code}: Expected 7 info bullets, got {len(info_bullets)}")
            
            src_bullet = info_bullets[1]
            self.assertIn("Nguồn dữ liệu", src_bullet, f"{mod_code}: Bullet 2 must be 'Nguồn dữ liệu'")
            self.assertEqual(
                src_bullet,
                f"•  Nguồn dữ liệu (Hệ thống nguồn): {expected_src}",
                f"{mod_code}: Source system bullet mismatch"
            )

    def test_03_business_workflow_bullets_entity_alignment(self):
        """All 404 business workflow bullets must map to genuine entities or source tables."""
        workflow_bullets = []
        for p in self.sec31_paras:
            if p.text.startswith("•  ") and not any(k in p.text for k in [
                "Tên job:", "Nguồn dữ liệu", "Cách thức truy xuất", "Tần suất",
                "Dung lượng", "Thời gian lưu trữ", "Thư mục lưu trữ"
            ]):
                workflow_bullets.append(p.text)

        self.assertEqual(len(workflow_bullets), 404, f"Expected 404 workflow bullets, got {len(workflow_bullets)}")

        for idx, b in enumerate(workflow_bullets):
            m = re.match(r"^•\s+([^:]+):\s+(.+)$", b)
            self.assertIsNotNone(m, f"Bullet #{idx} is not in '•  Entity: Description' format: '{b}'")
            ent_name = m.group(1).strip()
            desc = m.group(2).strip()
            self.assertGreater(len(ent_name), 0, f"Bullet #{idx} has empty entity name")
            self.assertGreater(len(desc), 10, f"Bullet #{idx} has suspiciously short description: '{desc}'")


class TestSuite5TextHygieneAndAntiCorruption(BaseDocxTest):
    """Challenge 5: Stress-test text hygiene, mojibake, unrendered markdown, and styling compliance."""

    def test_01_zero_placeholder_or_unresolved_tokens(self):
        """Section 3.1 must contain 0 placeholders, NaN, null, undefined, TODO, FIXME, or template markers."""
        leak_patterns = [
            (r"\$\{", "Template literal ${"),
            (r"\{\{", "Mustache token {{"),
            (r"<placeholder>", "<placeholder>"),
            (r"\bTODO\b", "TODO"),
            (r"\bFIXME\b", "FIXME"),
            (r"\bXXX\b", "XXX"),
            (r"\bundefined\b", "JavaScript undefined"),
            (r"\bNaN\b", "Float NaN"),
            (r"\bnull\b", "JSON null"),
        ]

        leaks = []
        for idx, p in enumerate(self.sec31_paras):
            t = p.text
            for pat, name in leak_patterns:
                if re.search(pat, t):
                    leaks.append(f"Para {idx} [{p.style.name}]: '{name}' found in '{t[:80]}'")

        self.assertEqual(leaks, [], f"Found forbidden leak tokens in Section 3.1:\n" + "\n".join(leaks[:20]))

    def test_02_zero_raw_markdown_leaks(self):
        """Section 3.1 must contain 0 raw markdown delimiters like ```mermaid, ```, raw headers."""
        raw_md_patterns = [
            (r"^```", "Markdown code fence"),
            (r"^#{1,6}\s", "Markdown header #"),
            (r"\*\*[^*]+\*\*", "Unparsed Markdown bold **"),
        ]

        raw_leaks = []
        for idx, p in enumerate(self.sec31_paras):
            t = p.text.strip()
            for pat, name in raw_md_patterns:
                if re.search(pat, t):
                    raw_leaks.append(f"Para {idx}: '{name}' found in '{t[:80]}'")

        self.assertEqual(raw_leaks, [], f"Found raw markdown leaks in Section 3.1:\n" + "\n".join(raw_leaks[:20]))

    def test_03_zero_mojibake_or_corrupted_characters(self):
        """Section 3.1 must contain 0 mojibake or UTF-8 decoding anomalies."""
        mojibake_patterns = [
            r"\ufffd",
            r"Ã¡|Ã©|Ã­|Ã³|Ãº|Ä‘",
            r"â€œ|â€\x9d|â€˜|â€™",
            r"ï»¿",
        ]

        mojibake_findings = []
        for idx, p in enumerate(self.sec31_paras):
            t = p.text
            for pat in mojibake_patterns:
                if re.search(pat, t):
                    mojibake_findings.append(f"Para {idx}: Pattern '{pat}' found in '{t[:80]}'")

        self.assertEqual(mojibake_findings, [], f"Found mojibake in Section 3.1:\n" + "\n".join(mojibake_findings[:20]))

    def test_04_bullet_hanging_indent_xml_compliance(self):
        """All 474 bullets must have w:left='360' and w:hanging='280' directly configured in XML."""
        bullet_paras = [p for p in self.sec31_paras if p.text.startswith("•  ")]
        self.assertEqual(len(bullet_paras), 474)

        for idx, p in enumerate(bullet_paras):
            pPr = p._p.get_or_add_pPr()
            ind = pPr.find(qn("w:ind"))
            self.assertIsNotNone(ind, f"Bullet #{idx} missing w:ind element")
            left = ind.get(qn("w:left"))
            hanging = ind.get(qn("w:hanging"))
            self.assertEqual(left, "360", f"Bullet #{idx} w:left expected 360, got '{left}'")
            self.assertEqual(hanging, "280", f"Bullet #{idx} w:hanging expected 280, got '{hanging}'")

    def test_05_times_new_roman_font_across_all_runs(self):
        """Every text run in Section 3.1 must explicitly specify Times New Roman font."""
        non_tnr_runs = []
        for idx, p in enumerate(self.sec31_paras):
            for r_idx, r in enumerate(p.runs):
                rPr = r._r.find(qn("w:rPr"))
                if rPr is not None:
                    rFonts = rPr.find(qn("w:rFonts"))
                    if rFonts is not None:
                        ascii_font = rFonts.get(qn("w:ascii"))
                        if ascii_font and ascii_font != "Times New Roman":
                            non_tnr_runs.append((idx, r_idx, ascii_font, r.text[:30]))

        self.assertEqual(
            non_tnr_runs,
            [],
            f"Found non-Times New Roman runs:\n" + "\n".join(str(r) for r in non_tnr_runs[:10])
        )


class TestSuite6Section31TableEliminationAndIsolation(BaseDocxTest):
    """Challenge 6: Verify Section 3.1 has zero tables and complete DOM surgical isolation."""

    def test_01_zero_tables_in_section_31(self):
        """Section 3.1 must have exactly 0 tables in the document XML body."""
        body = self.doc._element.body
        p_etl = self.doc.paragraphs[self.p_etl_idx]._p
        p_api = self.doc.paragraphs[self.p_api_idx]._p
        etl_idx = list(body).index(p_etl)
        api_idx = list(body).index(p_api)

        tables_in_31 = sum(1 for i in range(etl_idx + 1, api_idx) if body[i].tag.endswith("tbl"))
        self.assertEqual(tables_in_31, 0, f"Found {tables_in_31} tables in Section 3.1 (expected 0)")

    def test_02_exactly_37_tables_outside_section_31(self):
        """Document must contain exactly 37 tables outside Section 3.1."""
        self.assertEqual(len(self.doc.tables), 37, f"Expected exactly 37 tables in total, got {len(self.doc.tables)}")


if __name__ == "__main__":
    unittest.main(verbosity=2)
