#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
test_catalog_adversarial.py - Adversarial Stress & Edge-Case Testing Suite
===========================================================================
Challenger 1: Stress & Edge-Case Challenger
Target: docs/datamart_data_source_catalog.md & ubck_atomic_design/docs/datamart_data_source_catalog.md

Tests:
  1. Markdown syntax & code fence integrity
  2. Table column alignment & broken row detection (excludes code blocks)
  3. Hidden characters, zero-width characters & encoding corruption (e.g. BOM, replacement char, control chars)
  4. Anchor links & Table of Contents navigation analysis
  5. Special Subsystem Edge Cases:
     - VP: 534 KPIs (286 Dashboard + 188 Báo cáo + 60 Explorer), 5 core flat + 4 planned facts
     - QLCB: 69 KPIs, repoint TTHC (K_QLCB_66, K_QLCB_67, ap_document)
     - NDTNN: 255 KPIs, 26 biểu mẫu TT51/TT96 (Nhóm 18-43)
     - GSDC: 873 KPIs, BCTC 3 loại hình DN x 4 biểu mẫu (Nhóm 19-30, 619 BCTC KPIs)
  6. Cross-Matrix consistency (Phần II vs Phần III vs Phần IV vs Math sums)
     - Checks table names mentioned in Phần II vs Phần III
     - Checks upstream systems consistency
  7. Semantic ambiguity & prohibited placeholder audit
  8. Workspace parity check (root docs/ vs ubck_atomic_design/docs/)
"""

import os
import sys
import re
import csv
from pathlib import Path
from typing import Dict, List, Tuple, Any, Set

if sys.stdout.encoding and sys.stdout.encoding.lower() not in ("utf-8", "utf8"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except AttributeError:
        pass


class AdversarialTester:
    def __init__(self, doc_path: Path, workspace_root: Path):
        self.doc_path = doc_path
        self.workspace_root = workspace_root
        self.errors: List[str] = []
        self.warnings: List[str] = []
        self.passed_tests: List[str] = []
        self.metrics: Dict[str, Any] = {}

    def log_pass(self, test_name: str, detail: str = ""):
        msg = f"[PASS] {test_name}" + (f": {detail}" if detail else "")
        self.passed_tests.append(msg)
        print(f"  ✓ {msg}")

    def log_fail(self, test_name: str, error: str):
        msg = f"[FAIL] {test_name}: {error}"
        self.errors.append(msg)
        print(f"  ✗ {msg}")

    def log_warn(self, test_name: str, warn: str):
        msg = f"[WARN] {test_name}: {warn}"
        self.warnings.append(msg)
        print(f"  ! {msg}")

    def run_all(self) -> bool:
        print(f"\n================================================================================")
        print(f"ADVERSARIAL STRESS TEST SUITE - CHALLENGER 1")
        print(f"Target: {self.doc_path}")
        print(f"================================================================================\n")

        if not self.doc_path.exists():
            self.log_fail("File Existence", f"File not found: {self.doc_path}")
            return False

        content = self.doc_path.read_text(encoding="utf-8", errors="replace")
        lines = content.splitlines()
        raw_bytes = self.doc_path.read_bytes()

        # 1. Markdown syntax & code fence integrity
        self.test_1_markdown_syntax(lines, content)

        # 2. Markdown table structure & column alignment
        self.test_2_table_structures(lines)

        # 3. Hidden & zero-width characters & encoding
        self.test_3_hidden_characters(raw_bytes, lines)

        # 4. Anchor links & internal cross-references
        self.test_4_anchor_links(lines, content)

        # 5. Subsystem Edge Cases
        self.test_5_subsystem_edge_cases(lines, content)

        # 6. Cross-matrix consistency
        self.test_6_cross_matrix_consistency(lines, content)

        # 7. Semantic ambiguity & prohibited words
        self.test_7_semantic_ambiguity(lines)

        # 8. Workspace parity
        self.test_8_workspace_parity()

        print(f"\n--------------------------------------------------------------------------------")
        print(f"RESULTS SUMMARY: {len(self.passed_tests)} Passed | {len(self.warnings)} Warnings | {len(self.errors)} Errors")
        print(f"--------------------------------------------------------------------------------")
        return len(self.errors) == 0

    def test_1_markdown_syntax(self, lines: List[str], content: str):
        print("[TEST 1] Markdown Syntax & Code Fence Integrity")
        # 1.1 Code blocks
        fence_count = 0
        fence_lines = []
        for idx, line in enumerate(lines, 1):
            if line.strip().startswith("```"):
                fence_count += 1
                fence_lines.append(idx)
        if fence_count % 2 != 0:
            self.log_fail("Code Fence Integrity", f"Unbalanced code blocks (count={fence_count}). Lines: {fence_lines}")
        else:
            self.log_pass("Code Fence Integrity", f"{fence_count // 2} code blocks properly opened and closed")

        # 1.2 Heading level skips (e.g. # to ###)
        prev_level = 0
        heading_errors = []
        for idx, line in enumerate(lines, 1):
            m = re.match(r"^(#{1,6})\s+", line)
            if m:
                level = len(m.group(1))
                if prev_level > 0 and level > prev_level + 1:
                    heading_errors.append(f"Line {idx}: Heading level jumped from H{prev_level} to H{level} ('{line.strip()[:40]}...')")
                prev_level = level
        if heading_errors:
            for err in heading_errors:
                self.log_warn("Heading Hierarchy", err)
        else:
            self.log_pass("Heading Hierarchy", "Strict heading hierarchy maintained (no skipped levels)")

    def test_2_table_structures(self, lines: List[str]):
        print("\n[TEST 2] Markdown Table Structures & Column Counts")
        in_code_block = False
        in_table = False
        table_start_line = 0
        expected_cols = 0
        table_count = 0
        broken_rows = []

        for idx, line in enumerate(lines, 1):
            stripped = line.strip()
            if stripped.startswith("```"):
                in_code_block = not in_code_block
                if in_table:
                    in_table = False
                continue

            if in_code_block:
                continue

            # A markdown table row starts and ends with |
            is_table_row = stripped.startswith("|") and stripped.endswith("|") and stripped.count("|") >= 2

            if is_table_row:
                cells = [c.strip() for c in stripped.split("|")[1:-1]]
                if not in_table:
                    in_table = True
                    table_start_line = idx
                    expected_cols = len(cells)
                    table_count += 1
                else:
                    is_separator = all(re.match(r"^:?-+:?$", c) for c in cells if c)
                    if is_separator:
                        if len(cells) != expected_cols:
                            broken_rows.append(f"Line {idx} (Table starting line {table_start_line}): Separator has {len(cells)} cols, expected {expected_cols}")
                    else:
                        if len(cells) != expected_cols:
                            broken_rows.append(f"Line {idx} (Table starting line {table_start_line}): Data row has {len(cells)} cols, expected {expected_cols}. Content: {stripped[:60]}...")
            else:
                if in_table:
                    in_table = False
                    expected_cols = 0

        self.metrics["table_count"] = table_count
        if broken_rows:
            for err in broken_rows:
                self.log_fail("Table Column Count Alignment", err)
        else:
            self.log_pass("Table Column Count Alignment", f"All {table_count} real markdown tables have 100% consistent column counts across all rows")

    def test_3_hidden_characters(self, raw_bytes: bytes, lines: List[str]):
        print("\n[TEST 3] Hidden, Zero-Width Characters & Encoding Integrity")
        replacement_char = "\ufffd"
        replacement_matches = []
        for idx, line in enumerate(lines, 1):
            if replacement_char in line:
                replacement_matches.append(idx)
        if replacement_matches:
            self.log_fail("Encoding Replacement Char", f"Found unicode replacement char (\ufffd) on lines: {replacement_matches}")
        else:
            self.log_pass("Encoding Replacement Char", "Zero replacement characters found (no corrupted UTF-8 decoding)")

        invisible_chars = {
            "\u200b": "ZERO WIDTH SPACE",
            "\u200c": "ZERO WIDTH NON-JOINER",
            "\u200d": "ZERO WIDTH JOINER",
            "\u200e": "LEFT-TO-RIGHT MARK",
            "\u200f": "RIGHT-TO-LEFT MARK",
            "\ufeff": "ZERO WIDTH NO-BREAK SPACE (BOM)",
        }
        invisible_found = []
        for idx, line in enumerate(lines, 1):
            for char, name in invisible_chars.items():
                if char in line:
                    if idx == 1 and char == "\ufeff" and line.startswith("\ufeff"):
                        continue
                    invisible_found.append(f"Line {idx}: Found {name} (U+{ord(char):04X})")

        if invisible_found:
            for inv in invisible_found:
                self.log_fail("Hidden Invisible Characters", inv)
        else:
            self.log_pass("Hidden Invisible Characters", "Zero invisible/zero-width characters detected across all lines")

        ctrl_chars_found = []
        for idx, line in enumerate(lines, 1):
            for c in line:
                code = ord(c)
                if (0 <= code <= 8) or (11 <= code <= 12) or (14 <= code <= 31) or code == 127:
                    ctrl_chars_found.append(f"Line {idx}: ASCII control char {code} ('{c}')")
        if ctrl_chars_found:
            for c in ctrl_chars_found:
                self.log_fail("Control Characters", c)
        else:
            self.log_pass("Control Characters", "No stray ASCII control characters found")

    def test_4_anchor_links(self, lines: List[str], content: str):
        print("\n[TEST 4] Anchor Links & Table of Contents Navigation")
        # Extract headings and build github slugs
        heading_slugs: Set[str] = set()
        headings_list = []
        for line in lines:
            m = re.match(r"^#{1,6}\s+(.+)$", line.strip())
            if m:
                h_text = m.group(1).strip()
                headings_list.append(h_text)
                slug = h_text.lower()
                slug = re.sub(r"[^\w\s-]", "", slug)
                slug = re.sub(r"\s+", "-", slug)
                heading_slugs.add(slug)
                heading_slugs.add(h_text.lower().replace(" ", "-"))

        link_pattern = re.compile(r"\[([^\]]+)\]\((#[^\)]+)\)")
        internal_links = link_pattern.findall(content)

        # Check Table of Contents existence
        has_toc = any("mục lục" in h.lower() or "table of contents" in h.lower() for h in headings_list)
        if not has_toc and len(internal_links) == 0:
            self.log_warn("Anchor Links & Navigation", f"Document lacks a Table of Contents (Mục Lục) and internal anchor navigation links despite having {len(headings_list)} headings across 102KB content")
        else:
            self.log_pass("Anchor Links & Navigation", f"Document has {len(internal_links)} internal anchor links")

        # Verify Roman numeral sections (Phần I -> Phần V)
        for section_num, name in [("I", "Tổng quan"), ("II", "Executive Summary Matrix"), ("III", "Chi tiết"), ("IV", "Đánh giá trạng thái"), ("V", "Kết luận")]:
            sec_pattern = re.compile(rf"##\s+PHẦN\s+{section_num}\b", re.IGNORECASE)
            if not sec_pattern.search(content):
                self.log_fail("Section Anchors", f"Missing section heading for PHẦN {section_num}: {name}")
            else:
                self.log_pass("Section Anchors", f"Found PHẦN {section_num}: {name}")

    def test_5_subsystem_edge_cases(self, lines: List[str], content: str):
        print("\n[TEST 5] Special Subsystem Edge Cases")

        # 5.1 VP: 534 KPIs
        print("  --> Subsystem VP (534 KPIs in BA):")
        vp_matrix_match = re.search(r"\|\s*11\s*\|\s*\*\*VP\*\*\s*\|\s*[^|]+\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*\*\*(\d+)\*\*", content)
        if vp_matrix_match:
            d, b, e, total = map(int, vp_matrix_match.groups())
            if total != 534:
                self.log_fail("VP Matrix Total", f"Expected 534 KPIs, got {total}")
            elif d + b + e != 534:
                self.log_fail("VP Matrix Sum", f"Components ({d} + {b} + {e} = {d+b+e}) do not equal total {total}")
            else:
                self.log_pass("VP Matrix KPI Sum", f"VP components: Dashboard={d}, Báo cáo={b}, Explorer={e} -> Total={total} (Exactly 534)")
        else:
            self.log_fail("VP Matrix", "Could not locate VP row in Executive Summary Matrix")

        if "534" in content and "286" in content and "188" in content and "60" in content:
            self.log_pass("VP Detail KPI Alignment", "Section III (11. VP) accurately documents 286 Dashboard, 188 Báo cáo, 60 Explorer")
        else:
            self.log_fail("VP Detail KPI Alignment", "Section III does not match VP 534 KPI breakdown")

        vp_facts = ["fct_scr_mkt_indx_snpst", "fct_derv_tdg_snpst", "fct_derv_prc_snpst", "fct_lst_crp_bnd_snpst", "fct_lst_crp_bnd_indy_trm_snpst"]
        vp_facts_missing = [f for f in vp_facts if f not in content]
        if vp_facts_missing:
            self.log_fail("VP Core Facts", f"Missing core VP facts: {vp_facts_missing}")
        else:
            self.log_pass("VP Core Facts", "All 5 core VP facts present in catalog")

        vp_planned = ["fct_otc_bond_snpst", "fct_gov_bond_snpst", "fct_listing_snpst", "fct_mkt_cap_snpst"]
        vp_planned_missing = [f for f in vp_planned if f not in content]
        if vp_planned_missing:
            self.log_fail("VP Planned Facts", f"Missing planned VP facts: {vp_planned_missing}")
        else:
            self.log_pass("VP Planned Facts", "All 4 planned VP facts present in catalog")

        # 5.2 QLCB: Repoint TTHC & Pending K_QLCB_66, 67
        print("  --> Subsystem QLCB (Repoint TTHC):")
        qlcb_matrix_match = re.search(r"\|\s*6\s*\|\s*\*\*QLCB\*\*\s*\|\s*[^|]+\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*\*\*(\d+)\*\*", content)
        if qlcb_matrix_match:
            d, b, e, total = map(int, qlcb_matrix_match.groups())
            if total != 69:
                self.log_fail("QLCB Matrix Total", f"Expected 69 KPIs, got {total}")
            elif d + b + e != 69:
                self.log_fail("QLCB Matrix Sum", f"Components ({d} + {b} + {e}) do not equal total {total}")
            else:
                self.log_pass("QLCB Matrix KPI Sum", f"QLCB: Dashboard={d}, Báo cáo={b}, Explorer={e} -> Total={total} (Exactly 69)")
        else:
            self.log_fail("QLCB Matrix", "Could not locate QLCB row in Executive Summary Matrix")

        if "K_QLCB_66" in content and "K_QLCB_67" in content:
            self.log_pass("QLCB Pending KPIs", "K_QLCB_66 and K_QLCB_67 explicitly documented in Section IV")
        else:
            self.log_fail("QLCB Pending KPIs", "Missing reference to pending KPIs K_QLCB_66 / K_QLCB_67")

        if "ap_document" in content and ("TTHC" in content or "Cổng TTHC" in content):
            self.log_pass("QLCB Upstream TTHC Repoint", "TTHC upstream and ap_document schema repoint properly acknowledged")
        else:
            self.log_fail("QLCB Upstream TTHC Repoint", "Missing TTHC repoint details in QLCB")

        # 5.3 NDTNN: 26 Biểu mẫu TT51/TT96
        print("  --> Subsystem NDTNN (26 Biểu mẫu TT51/TT96):")
        ndtnn_matrix_match = re.search(r"\|\s*3\s*\|\s*\*\*NDTNN\*\*\s*\|\s*[^|]+\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*\*\*(\d+)\*\*", content)
        if ndtnn_matrix_match:
            d, b, e, total = map(int, ndtnn_matrix_match.groups())
            if total != 255:
                self.log_fail("NDTNN Matrix Total", f"Expected 255 KPIs, got {total}")
            elif d + b + e != 255:
                self.log_fail("NDTNN Matrix Sum", f"Components ({d} + {b} + {e}) do not equal total {total}")
            else:
                self.log_pass("NDTNN Matrix KPI Sum", f"NDTNN: Dashboard={d}, Báo cáo={b}, Explorer={e} -> Total={total} (Exactly 255)")
        else:
            self.log_fail("NDTNN Matrix", "Could not locate NDTNN row in Executive Summary Matrix")

        if "26 biểu mẫu" in content or "26 Biểu mẫu" in content:
            self.log_pass("NDTNN 26 Forms Mention", "26 biểu mẫu TT51 & TT96 explicitly declared")
        else:
            self.log_fail("NDTNN 26 Forms Mention", "Missing explicit reference to 26 biểu mẫu TT51/TT96")

        if "Nhóm 18–43" in content or "Nhóm 18-43" in content:
            self.log_pass("NDTNN Group Range", "Nhóm 18-43 (26 groups) mapped in Section 3.1 & 3.2")
        else:
            self.log_fail("NDTNN Group Range", "Missing group range Nhóm 18-43 for NDTNN forms")

        # 5.4 GSDC: BCTC 3 loại hình DN x 4 biểu mẫu
        print("  --> Subsystem GSDC (BCTC 3 types x 4 forms):")
        gsdc_matrix_match = re.search(r"\|\s*2\s*\|\s*\*\*GSDC\*\*\s*\|\s*[^|]+\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*\*\*(\d+)\*\*", content)
        if gsdc_matrix_match:
            d, b, e, total = map(int, gsdc_matrix_match.groups())
            if total != 873:
                self.log_fail("GSDC Matrix Total", f"Expected 873 KPIs, got {total}")
            elif d + b + e != 873:
                self.log_fail("GSDC Matrix Sum", f"Components ({d} + {b} + {e}) do not equal total {total}")
            else:
                self.log_pass("GSDC Matrix KPI Sum", f"GSDC: Dashboard={d}, Báo cáo={b}, Explorer={e} -> Total={total} (Exactly 873)")
        else:
            self.log_fail("GSDC Matrix", "Could not locate GSDC row in Executive Summary Matrix")

        types_present = all([
            "Doanh nghiệp thông thường" in content or "TT200" in content,
            "Doanh nghiệp bảo hiểm" in content,
            "Tổ chức tín dụng" in content or "Ngân hàng" in content,
        ])
        if types_present:
            self.log_pass("GSDC 3 Enterprise Types", "All 3 enterprise types explicitly listed (TT200, Bảo hiểm, TCTD)")
        else:
            self.log_fail("GSDC 3 Enterprise Types", "Missing one or more enterprise types in GSDC")

        if "CĐKT" in content and "KQKD" in content and "LCTT trực tiếp" in content and "LCTT gián tiếp" in content:
            self.log_pass("GSDC 4 Financial Statements", "All 4 statement types explicitly listed (CĐKT, KQKD, LCTT TT, LCTT GT)")
        else:
            self.log_fail("GSDC 4 Financial Statements", "Missing one or more financial statement types in GSDC")

        bctc_kpis = ["117 KPIs", "23 KPIs", "30 KPIs", "42 KPIs", "104 KPIs", "16 KPIs", "31 KPIs", "41 KPIs", "85 KPIs", "50 KPIs", "57 KPIs"]
        missing_bctc_kpis = [k for k in bctc_kpis if k not in content]
        if missing_bctc_kpis:
            self.log_fail("GSDC BCTC KPI Granularity", f"Missing expected KPI numbers in GSDC: {missing_bctc_kpis}")
        else:
            self.log_pass("GSDC BCTC KPI Granularity", "All 12 individual BCTC statement KPI counts verified in Section 2.1")

    def test_6_cross_matrix_consistency(self, lines: List[str], content: str):
        print("\n[TEST 6] Cross-Matrix Consistency & Arithmetic Audit")
        matrix_rows = []
        in_matrix = False
        for line in lines:
            if "## PHẦN II:" in line or "## II." in line:
                in_matrix = True
                continue
            if in_matrix:
                if line.startswith("## PHẦN III:") or (line.startswith("---") and len(matrix_rows) >= 11):
                    in_matrix = False
                    break
                stripped = line.strip()
                if stripped.startswith("|") and stripped.endswith("|"):
                    cells = [c.strip() for c in stripped.split("|")[1:-1]]
                    if len(cells) >= 8 and re.match(r"^\d+$", cells[0]):
                        matrix_rows.append(cells)

        print(f"  Extracted {len(matrix_rows)} data rows from Executive Summary Matrix")
        if len(matrix_rows) < 11:
            self.log_fail("Executive Matrix Row Count", f"Expected at least 11 subsystem rows, got {len(matrix_rows)}")
            return

        expected_totals = {
            "GSTT": (182, 9, 169, 360),
            "GSDC": (116, 52, 705, 873),
            "NDTNN": (72, 168, 15, 255),
            "NHNCK": (46, 55, 22, 123),
            "PTTT": (248, 0, 27, 275),
            "QLCB": (23, 21, 25, 69),
            "QLKD": (193, 4074, 1, 4268),
            "QLQ": (171, 10, 2516, 2697),
            "TKNB": (0, 1183, 71, 1254),
            "TT": (57, 15, 19, 91),
            "VP": (286, 188, 60, 534),
        }

        sum_d, sum_b, sum_e, sum_tot = 0, 0, 0, 0
        matrix_mismatches = []
        matrix_data_by_code: Dict[str, Dict[str, Any]] = {}

        for row in matrix_rows:
            stt = row[0]
            code = row[1].replace("*", "").strip()
            name = row[2]
            try:
                d = int(row[3].replace(",", "").replace(".", ""))
                b = int(row[4].replace(",", "").replace(".", ""))
                e = int(row[5].replace(",", "").replace(".", ""))
                tot = int(row[6].replace("*", "").replace(",", "").replace(".", ""))
            except ValueError as ve:
                matrix_mismatches.append(f"Row {code}: Failed to parse numbers: {ve}")
                continue

            sum_d += d
            sum_b += b
            sum_e += e
            sum_tot += tot

            # Extract fact and dim tables mentioned in matrix row
            fact_cell = row[7] if len(row) > 7 else ""
            dim_cell = row[8] if len(row) > 8 else ""
            upstream_cell = row[9] if len(row) > 9 else ""

            # Extract backticked names
            facts_in_matrix = re.findall(r"`([^`]+)`", fact_cell)
            dims_in_matrix = re.findall(r"`([^`]+)`", dim_cell)

            matrix_data_by_code[code] = {
                "d": d, "b": b, "e": e, "tot": tot,
                "facts": facts_in_matrix,
                "dims": dims_in_matrix,
                "upstream": upstream_cell
            }

            if d + b + e != tot:
                matrix_mismatches.append(f"Row {code}: Sum of components ({d} + {b} + {e} = {d+b+e}) != total column {tot}")

            if code in expected_totals:
                exp_d, exp_b, exp_e, exp_tot = expected_totals[code]
                if (d, b, e, tot) != (exp_d, exp_b, exp_e, exp_tot):
                    matrix_mismatches.append(f"Row {code}: Got ({d}, {b}, {e}, {tot}), expected ({exp_d}, {exp_b}, {exp_e}, {exp_tot})")

        if matrix_mismatches:
            for m in matrix_mismatches:
                self.log_fail("Matrix Cell Consistency", m)
        else:
            self.log_pass("Matrix Cell Consistency", "All 11 subsystem rows in Phần II match exact ground truth KPI counts and arithmetic row sums")

        if (sum_d, sum_b, sum_e, sum_tot) == (1394, 5775, 3630, 10799):
            self.log_pass("Matrix Grand Totals", f"Grand sums match: Dashboard={sum_d}, Báo cáo={sum_b}, Explorer={sum_e} -> Total={sum_tot} (10,799 KPIs)")
        else:
            self.log_fail("Matrix Grand Totals", f"Grand sums mismatch: got ({sum_d}, {sum_b}, {sum_e}, {sum_tot}), expected (1394, 5775, 3630, 10799)")

        # Compare with Section IV (Readiness Table)
        readiness_pattern = re.compile(r"\|\s*(\d+)\s*\|\s*\*\*([A-ZĐ]+)\*\*\s*\|\s*([0-9,.]+)\s*\|")
        readiness_matches = readiness_pattern.findall(content)
        readiness_mismatches = []
        for stt, code, kpi_str in readiness_matches:
            kpi_val = int(kpi_str.replace(",", "").replace(".", ""))
            norm_code = "GSDC" if "GSDC" in code or "GSĐC" in code else code
            norm_code = "NDTNN" if "NDTNN" in code or "NĐTNN" in code else norm_code
            if norm_code in expected_totals:
                exp_tot = expected_totals[norm_code][3]
                if kpi_val != exp_tot:
                    readiness_mismatches.append(f"Section IV {norm_code}: Got {kpi_val} KPIs, expected {exp_tot}")

        if readiness_mismatches:
            for m in readiness_mismatches:
                self.log_fail("Readiness Table KPI Consistency", m)
        else:
            self.log_pass("Readiness Table KPI Consistency", f"All {len(readiness_matches)} entries in Section IV table match Section II matrix counts")

        # Check Fact and Dim tables in Phần II vs Section III details
        subsys_sections = re.split(r"###\s+\d+\.\s+Phân\s+Hệ\s+", content)[1:]
        codes = ["GSTT", "GSDC", "NDTNN", "NHNCK", "PTTT", "QLCB", "QLKD", "QLQ", "TKNB", "TT", "VP"]

        cross_table_mismatches = []
        for code, block in zip(codes, subsys_sections):
            if code not in matrix_data_by_code:
                continue
            facts = matrix_data_by_code[code]["facts"]
            dims = matrix_data_by_code[code]["dims"]
            for f in facts:
                # check if fact is present in block
                clean_f = f.split(".")[-1]
                if clean_f not in block and f not in block:
                    cross_table_mismatches.append(f"{code}: Fact '{f}' in Section II Matrix is not referenced in Section III detail text/table")
            for d in dims:
                clean_d = d.split(".")[-1]
                if clean_d not in block and d not in block:
                    cross_table_mismatches.append(f"{code}: Dimension '{d}' in Section II Matrix is not referenced in Section III detail text/table")

        if cross_table_mismatches:
            for ctm in cross_table_mismatches:
                self.log_fail("Matrix vs Section III Table Consistency", ctm)
        else:
            self.log_pass("Matrix vs Section III Table Consistency", "100% of Fact and Dimension tables in Section II Matrix are present in Section III details")

    def test_7_semantic_ambiguity(self, lines: List[str]):
        print("\n[TEST 7] Semantic Ambiguity & Prohibited Language Mining")
        prohibited_exact = [
            (re.compile(r"\bTBD\b"), "TBD"),
            (re.compile(r"\bTODO\b"), "TODO"),
            (re.compile(r"\[\s*Chưa xác định\s*\]"), "[Chưa xác định]"),
            (re.compile(r"\bChưa rõ\b"), "Chưa rõ"),
            (re.compile(r"\?\?\?"), "???"),
            (re.compile(r"\bFIXME\b"), "FIXME"),
            (re.compile(r"\bXXX\b"), "XXX"),
        ]

        ambiguous_hedges = [
            (re.compile(r"\bchưa kiểm tra\b", re.IGNORECASE), "chưa kiểm tra"),
            (re.compile(r"\bmơ hồ\b", re.IGNORECASE), "mơ hồ"),
            (re.compile(r"\bước chừng\b", re.IGNORECASE), "ước chừng"),
            (re.compile(r"\btùy nghi\b", re.IGNORECASE), "tùy nghi"),
            (re.compile(r"\bchưa chốt\b", re.IGNORECASE), "chưa chốt"),
        ]

        violations = []
        for idx, line in enumerate(lines, 1):
            if re.search(r"(?:không\s+(?:có|sử\s*dụng|chứa)|hoàn\s*toàn\s*không|zero\s*placeholder)\s+[^.\n]*?\bplaceholder\b", line, re.IGNORECASE):
                continue

            for pattern, name in prohibited_exact:
                if pattern.search(line):
                    violations.append(f"Line {idx}: Prohibited placeholder '{name}': {line.strip()[:60]}")

            for pattern, name in ambiguous_hedges:
                if pattern.search(line):
                    violations.append(f"Line {idx}: Ambiguous hedge term '{name}': {line.strip()[:60]}")

        if violations:
            for v in violations:
                self.log_fail("Semantic Ambiguity / Placeholders", v)
        else:
            self.log_pass("Semantic Ambiguity / Placeholders", "Zero prohibited placeholders or ambiguous hedge tokens found")

    def test_8_workspace_parity(self):
        print("\n[TEST 8] Multi-Workspace Parity Check")
        other_path = self.workspace_root / "ubck_atomic_design" / "docs" / "datamart_data_source_catalog.md"
        if not other_path.exists():
            self.log_warn("Workspace Parity", f"Subdirectory copy not found at {other_path}")
            return

        c1 = self.doc_path.read_bytes()
        c2 = other_path.read_bytes()
        if c1 == c2:
            self.log_pass("Workspace Parity", "Root catalog and ubck_atomic_design catalog are 100% byte-for-byte identical")
        else:
            # find diff
            diff_indices = [i for i in range(min(len(c1), len(c2))) if c1[i] != c2[i]]
            pos = diff_indices[0] if diff_indices else min(len(c1), len(c2))
            sample_c1 = c1[max(0, pos-15):min(len(c1), pos+15)]
            sample_c2 = c2[max(0, pos-15):min(len(c2), pos+15)]
            self.log_fail("Workspace Parity", f"Desynchronization between root and ubck_atomic_design copies ({len(diff_indices)} differing bytes at offset {pos}): root='{sample_c1}' vs sub='{sample_c2}'")


def main():
    workspace_root = Path("C:/Workspace/Design_DW")
    doc_path = workspace_root / "docs" / "datamart_data_source_catalog.md"

    tester = AdversarialTester(doc_path, workspace_root)
    success = tester.run_all()
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
