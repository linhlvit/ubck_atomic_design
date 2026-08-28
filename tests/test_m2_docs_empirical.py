"""Empirical Challenger Test Suite for Milestone 2:
- PTTK Level 2 Header regex compliance across all 10 modules
- PTTK Section 3.1.X.1 bullet list capitalization
- Mermaid syntax, node ID, subgraph and edge validation across all 10 PTTK + 10 TKCSLD files
- TKCSLD 12-column physical table integrity, ATM. prefix on Schema.Table, description cleanliness
- Multi-module docx build compilation test
"""

from __future__ import annotations

import os
import re
import sys
import unittest
import subprocess
import shutil
import zipfile
import tempfile
from pathlib import Path

# Paths
REPO_ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = REPO_ROOT / "docs" / "output" / "datamart"
SKILL_DIR = REPO_ROOT / ".claude" / "skills" / "datamart-gen-docs"
SCRIPTS_DIR = SKILL_DIR / "scripts"
sys.path.insert(0, str(SCRIPTS_DIR))

# Ensure Pandoc in PATH if present in local appdata
pandoc_appdata = Path(os.environ.get("LOCALAPPDATA", "C:/Users/ADMIN/AppData/Local")) / "Pandoc"
if pandoc_appdata.exists() and str(pandoc_appdata) not in os.environ.get("PATH", ""):
    os.environ["PATH"] = str(pandoc_appdata) + os.pathsep + os.environ.get("PATH", "")

# Expected Modules and metadata
MODULE_SPEC = [
    {"code": "TT", "index": "1", "name": "Hoạt động Thanh tra"},
    {"code": "NHNCK", "index": "2", "name": "Người hành nghề"},
    {"code": "NDTNN", "index": "3", "name": "Quản lý NĐTNN"},
    {"code": "QLCB", "index": "4", "name": "Quản lý chào bán"},
    {"code": "GSDC", "index": "5", "name": "Giám sát Công ty Đại chúng"},
    {"code": "GSTT", "index": "6", "name": "Giám sát Thị trường"},
    {"code": "QLQ", "index": "7", "name": "Công ty Quản lý Quỹ (AMC)"},
    {"code": "QLKD", "index": "8", "name": "Hoạt động Công ty Chứng khoán"},
    {"code": "PTTT", "index": "9", "name": "Phân tích thị trường"},
    {"code": "TKNB", "index": "10", "name": "Thống kê Thị trường"},
]

PTTK_H2_PATTERN = re.compile(r"^## 3\.1\.(?:[1-9]|10) LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO .+$")


class TestPTTKLevel2Headers(unittest.TestCase):
    """Checks that all 10 PTTK files exist and their Level 2 headers strictly follow Q5 spec."""

    def test_01_all_10_pttk_files_exist(self):
        for mod in MODULE_SPEC:
            code = mod["code"]
            pttk_path = OUTPUT_DIR / code / f"DTM_{code}_PTTK.md"
            self.assertTrue(pttk_path.is_file(), f"Missing PTTK file: {pttk_path}")

    def test_02_level_2_header_regex_and_numbering(self):
        for mod in MODULE_SPEC:
            code = mod["code"]
            idx = mod["index"]
            pttk_path = OUTPUT_DIR / code / f"DTM_{code}_PTTK.md"
            content = pttk_path.read_text(encoding="utf-8")

            h2_matches = [line.strip() for line in content.splitlines() if line.startswith("## ")]
            self.assertGreater(len(h2_matches), 0, f"{code}: No Level 2 header (## ) found")

            # Check primary Level 2 header
            top_h2 = h2_matches[0]
            self.assertRegex(
                top_h2,
                PTTK_H2_PATTERN,
                f"{code}: Level 2 header '{top_h2}' does NOT match pattern '^## 3\\.1\\.(?:[1-9]|10) LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO .+$'"
            )

            # Check exact expected prefix
            expected_prefix = f"## 3.1.{idx} LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO"
            self.assertTrue(
                top_h2.startswith(expected_prefix),
                f"{code}: Expected header starting with '{expected_prefix}', got '{top_h2}'"
            )

            # Check that GSDC does NOT contain "doanh nghiệp chứng khoán"
            if code == "GSDC":
                self.assertNotIn(
                    "doanh nghiệp chứng khoán",
                    top_h2.lower(),
                    "GSDC PTTK header must be 'Giám sát Công ty Đại chúng', not 'doanh nghiệp chứng khoán'"
                )
                self.assertIn("Giám sát Công ty Đại chúng", top_h2)


class TestPTTKSectionBullets(unittest.TestCase):
    """Checks that every Section 3.1.X.1 bullet list starts with uppercase."""

    def test_section_3_1_x_1_bullet_capitalization(self):
        for mod in MODULE_SPEC:
            code = mod["code"]
            idx = mod["index"]
            pttk_path = OUTPUT_DIR / code / f"DTM_{code}_PTTK.md"
            content = pttk_path.read_text(encoding="utf-8")

            # Match Section 3.1.X.1 content
            sec_header = f"### 3.1.{idx}.1"
            next_sec_header = f"### 3.1.{idx}.2"

            self.assertIn(sec_header, content, f"{code}: Missing section header '{sec_header}'")

            start_idx = content.find(sec_header)
            end_idx = content.find(next_sec_header, start_idx)
            if end_idx == -1:
                sec_text = content[start_idx:]
            else:
                sec_text = content[start_idx:end_idx]

            bullet_lines = []
            for line in sec_text.splitlines():
                stripped = line.strip()
                if stripped.startswith("- ") or stripped.startswith("* "):
                    bullet_lines.append(stripped)

            self.assertGreater(
                len(bullet_lines),
                0,
                f"{code}: Section {sec_header} contains no bullet list items"
            )

            for b_line in bullet_lines:
                # Strip leading '- ' or '* '
                raw_text = re.sub(r"^[-*]\s+", "", b_line).strip()
                # Strip markdown bold/italic if any, e.g. **Tên job:** -> Tên job:
                cleaned_text = re.sub(r"^[*_`]+", "", raw_text).strip()

                first_char = cleaned_text[0]
                self.assertTrue(
                    first_char.isupper() or not first_char.isalpha(),
                    f"{code} Section {sec_header}: Bullet item '{b_line}' does NOT start with uppercase! (starts with '{first_char}')"
                )

                # Also verify standard keys are capitalized if present
                lower_clean = cleaned_text.lower()
                if "tên job:" in lower_clean:
                    self.assertTrue(cleaned_text.startswith("Tên job:"), f"{code}: 'Tên job:' not properly capitalized in '{cleaned_text}'")
                if "nguồn dữ liệu" in lower_clean:
                    self.assertTrue(cleaned_text.startswith("Nguồn dữ liệu"), f"{code}: 'Nguồn dữ liệu' not properly capitalized in '{cleaned_text}'")


class TestMermaidSyntaxAndStructure(unittest.TestCase):
    """Stress-tests and validates syntax of all Mermaid diagrams in 10 PTTK and 10 TKCSLD files."""

    def _extract_mermaid_blocks(self, filepath: Path) -> list[dict]:
        content = filepath.read_text(encoding="utf-8")
        blocks = []
        pattern = re.compile(r"```mermaid\s*\n(.*?)```", re.DOTALL)
        for i, match in enumerate(pattern.finditer(content), 1):
            blocks.append({
                "index": i,
                "file": filepath.name,
                "code": match.group(1).strip()
            })
        return blocks

    def _validate_mermaid_syntax(self, code: str, filename: str, block_idx: int) -> list[str]:
        errors = []
        lines = [line.strip() for line in code.splitlines() if line.strip() and not line.strip().startswith("%%")]
        if not lines:
            errors.append(f"{filename} block #{block_idx}: Empty mermaid block")
            return errors

        first_line = lines[0]
        valid_diagram_types = (
            "flowchart", "graph", "erDiagram", "classDiagram",
            "sequenceDiagram", "gantt", "pie", "stateDiagram", "gitGraph", "C4Context"
        )
        if not any(first_line.startswith(t) for t in valid_diagram_types):
            errors.append(f"{filename} block #{block_idx}: Invalid diagram header: '{first_line}'")

        # Check bracket balancing across the diagram
        open_sq = code.count("[")
        close_sq = code.count("]")
        if open_sq != close_sq:
            errors.append(f"{filename} block #{block_idx}: Unbalanced square brackets: {open_sq} '[' vs {close_sq} ']'")

        open_paren = code.count("(")
        close_paren = code.count(")")
        if open_paren != close_paren:
            errors.append(f"{filename} block #{block_idx}: Unbalanced parentheses: {open_paren} '(' vs {close_paren} ')'")

        # Subgraph and end matching for flowcharts
        if first_line.startswith("flowchart") or first_line.startswith("graph"):
            subgraphs_count = 0
            ends_count = 0
            for line in lines:
                if re.match(r"^subgraph\b", line):
                    subgraphs_count += 1
                elif line == "end":
                    ends_count += 1

            if subgraphs_count != ends_count:
                errors.append(
                    f"{filename} block #{block_idx}: Mismatched subgraphs ({subgraphs_count}) and ends ({ends_count})"
                )

            # Node ID and quote validation
            for line_no, line in enumerate(lines, 1):
                if line.startswith("subgraph") or line == "end" or line.startswith("classDef") or line.startswith("class ") or line.startswith("style "):
                    continue
                if any(first_line.startswith(t) for t in ["flowchart", "graph"]):
                    dot_node_match = re.search(r"\b([a-zA-Z0-9_]+\.[a-zA-Z0-9_]+)\s*(\[|\(|\{)", line)
                    if dot_node_match:
                        errors.append(
                            f"{filename} block #{block_idx} line {line_no}: Unquoted dot in node ID '{dot_node_match.group(1)}' in '{line}'"
                        )
                    bad_id_match = re.search(r"^\s*([a-zA-Z0-9_]+-[a-zA-Z0-9_-]+)\s*(\[|\(|\{)", line)
                    if bad_id_match:
                        errors.append(
                            f"{filename} block #{block_idx} line {line_no}: Invalid hyphen in node ID '{bad_id_match.group(1)}'"
                        )

        # Check erDiagram syntax if applicable
        if first_line.startswith("erDiagram"):
            for line_no, line in enumerate(lines[1:], 2):
                if "{" in line or "}" in line:
                    continue
                if "--" in line or ".." in line:
                    if not re.search(r"(\||o|\{|\})\s*(-|\.)+\s*(\||o|\{|\})", line):
                        errors.append(
                            f"{filename} block #{block_idx} line {line_no}: Malformed erDiagram relationship: '{line}'"
                        )

        return errors

    def test_01_pttk_mermaid_diagrams_syntax(self):
        total_pttk_blocks = 0
        all_errors = []
        for mod in MODULE_SPEC:
            code = mod["code"]
            pttk_path = OUTPUT_DIR / code / f"DTM_{code}_PTTK.md"
            blocks = self._extract_mermaid_blocks(pttk_path)
            self.assertGreater(len(blocks), 0, f"{code} PTTK has no Mermaid diagrams")
            total_pttk_blocks += len(blocks)
            for b in blocks:
                errs = self._validate_mermaid_syntax(b["code"], b["file"], b["index"])
                if errs:
                    all_errors.extend(errs)

        self.assertEqual(all_errors, [], f"Mermaid syntax errors found in PTTK:\n" + "\n".join(all_errors))
        print(f"\n[INFO] Validated {total_pttk_blocks} Mermaid diagram blocks across 10 PTTK files: ALL VALID")

    def test_02_tkcsld_mermaid_diagrams_syntax(self):
        total_tkcsld_blocks = 0
        all_errors = []
        for mod in MODULE_SPEC:
            code = mod["code"]
            tkcsld_path = OUTPUT_DIR / code / f"DTM_{code}_TKCSLD.md"
            blocks = self._extract_mermaid_blocks(tkcsld_path)
            self.assertGreater(len(blocks), 0, f"{code} TKCSLD has no Mermaid diagrams")
            total_tkcsld_blocks += len(blocks)
            for b in blocks:
                errs = self._validate_mermaid_syntax(b["code"], b["file"], b["index"])
                if errs:
                    all_errors.extend(errs)

        self.assertEqual(all_errors, [], f"Mermaid syntax errors found in TKCSLD:\n" + "\n".join(all_errors))
        print(f"\n[INFO] Validated {total_tkcsld_blocks} Mermaid diagram blocks across 10 TKCSLD files: ALL VALID")

    def test_03_no_placeholder_node_ids_in_pttk(self):
        """Ensure no raw placeholder node IDs like S1, SV1, G1, A1, D1 are used as main node definitions."""
        placeholder_pattern = re.compile(r"^\s*(S\d+|SV\d+|G\d+|A\d+|D\d+)\s*\[", re.MULTILINE)
        for mod in MODULE_SPEC:
            code = mod["code"]
            pttk_path = OUTPUT_DIR / code / f"DTM_{code}_PTTK.md"
            blocks = self._extract_mermaid_blocks(pttk_path)
            for b in blocks:
                matches = placeholder_pattern.findall(b["code"])
                self.assertEqual(
                    matches,
                    [],
                    f"{code} PTTK block #{b['index']} contains un-refactored placeholder node IDs: {matches}"
                )


class TestTKCSLDTableIntegrity(unittest.TestCase):
    """Stress-tests the structure, 12 columns, ATM. prefix, and description cleanliness of TKCSLD files."""

    TECHNICAL_NOISE_PATTERNS = [
        r"\(PK surrogate\)",
        r"\bBCV:",
        r"\bHash:",
        r"\bNguồn thực:",
        r"\bDedup\b",
        r"\bFilter:",
        r"\bjoin_anchor\b",
        r"Surrogate key ETL sinh tự động",
        r"\bScheme:\b",
        r"←\s*[A-Z]+",
    ]

    def test_01_all_10_tkcsld_files_exist_and_h1(self):
        for mod in MODULE_SPEC:
            code = mod["code"]
            tkcsld_path = OUTPUT_DIR / code / f"DTM_{code}_TKCSLD.md"
            self.assertTrue(tkcsld_path.is_file(), f"Missing TKCSLD file: {tkcsld_path}")
            content = tkcsld_path.read_text(encoding="utf-8")
            h1_line = [l.strip() for l in content.splitlines() if l.startswith("# ")][0]
            self.assertRegex(
                h1_line,
                r"^# 3\.\s+KHO DỮ LIỆU \(OLAP\)\s+—\s+.+$",
                f"{code}: TKCSLD H1 '{h1_line}' does not match '# 3. KHO DỮ LIỆU (OLAP) — <Name>'"
            )
            if code == "GSDC":
                self.assertIn("Giám sát Công ty Đại chúng", h1_line)
                self.assertNotIn("doanh nghiệp chứng khoán", h1_line.lower())

    def test_02_physical_tables_12_columns(self):
        total_tables = 0
        for mod in MODULE_SPEC:
            code = mod["code"]
            tkcsld_path = OUTPUT_DIR / code / f"DTM_{code}_TKCSLD.md"
            content = tkcsld_path.read_text(encoding="utf-8")

            sec_3_3_idx = content.find("## 3.3 Physical")
            if sec_3_3_idx == -1:
                sec_3_3_idx = content.find("## 3.3")
            self.assertNotEqual(sec_3_3_idx, -1, f"{code}: Missing Section 3.3 Physical")

            sec_3_3_text = content[sec_3_3_idx:]
            table_header_re = re.compile(
                r"\|\s*STT\s*\|\s*Tên trường\s*\|\s*Kiểu dữ liệu và độ dài\s*\|\s*Nullable\s*\|\s*Unique\s*\|\s*P/F Key\s*\|\s*Giá trị mặc định\s*\|\s*Mô tả\s*\|\s*Hệ thống nguồn\s*\|\s*Schema\.Table\s*\|\s*Source Field Name\s*\|\s*ETL Rules\s*\|"
            )
            headers_found = table_header_re.findall(sec_3_3_text)
            self.assertGreater(len(headers_found), 0, f"{code}: No 12-column physical tables found in Section 3.3")
            total_tables += len(headers_found)

        print(f"\n[INFO] Validated {total_tables} Physical tables with 12 columns across 10 TKCSLD files")

    def test_03_schema_table_atm_prefix(self):
        """Verify that every mapped table row in Physical tables has Schema.Table starting with ATM."""
        invalid_entries = []
        for mod in MODULE_SPEC:
            code = mod["code"]
            tkcsld_path = OUTPUT_DIR / code / f"DTM_{code}_TKCSLD.md"
            content = tkcsld_path.read_text(encoding="utf-8")

            sec_3_3_idx = content.find("## 3.3")
            sec_3_3_text = content[sec_3_3_idx:]

            for line in sec_3_3_text.splitlines():
                if not line.startswith("|") or "STT" in line or "---" in line:
                    continue
                cols = [c.strip() for c in line.split("|")[1:-1]]
                if len(cols) == 12:
                    schema_table = cols[9]
                    if schema_table and schema_table != "-" and schema_table != "N/A":
                        if not schema_table.startswith("ATM."):
                            invalid_entries.append(f"{code} row: Schema.Table='{schema_table}' (col: {cols[1]})")

        self.assertEqual(invalid_entries, [], f"Found Schema.Table entries without ATM. prefix:\n" + "\n".join(invalid_entries[:20]))

    def test_04_zero_technical_noise_in_attribute_descriptions(self):
        """Verify 0 technical noise strings in Section 3.2 (Logic) and Section 3.3 (Physical) tables."""
        noise_findings = []
        for mod in MODULE_SPEC:
            code = mod["code"]
            tkcsld_path = OUTPUT_DIR / code / f"DTM_{code}_TKCSLD.md"
            content = tkcsld_path.read_text(encoding="utf-8")

            # Check Section 3.2 and 3.3
            sec_3_2_idx = content.find("## 3.2")
            if sec_3_2_idx != -1:
                sec_tables_text = content[sec_3_2_idx:]
                for line_no, line in enumerate(sec_tables_text.splitlines(), 1):
                    if not line.startswith("|") or "STT" in line or "---" in line:
                        continue
                    cols = [c.strip() for c in line.split("|")[1:-1]]
                    desc_texts = []
                    if len(cols) == 12:
                        desc_texts.append(cols[7])
                    elif len(cols) == 8:
                        desc_texts.append(cols[6])

                    for desc in desc_texts:
                        for pat in self.TECHNICAL_NOISE_PATTERNS:
                            if re.search(pat, desc, re.IGNORECASE):
                                noise_findings.append(
                                    f"{code} Section 3.2/3.3 line {line_no}: Pattern '{pat}' found in description: '{desc}'"
                                )

        self.assertEqual(noise_findings, [], f"Technical noise found in attribute descriptions:\n" + "\n".join(noise_findings[:20]))


class TestDocxCompilation(unittest.TestCase):
    """Tests docx compilation on multiple modules."""

    def test_multi_module_tkcsld_docx_compilation(self):
        test_modules = ["TT", "GSDC", "PTTT", "QLQ", "TKNB"]
        pandoc_bin = shutil.which("pandoc")
        if not pandoc_bin:
            self.skipTest("Pandoc is not available in PATH on this system; skipping docx compilation integration")

        for mod in test_modules:
            cmd = [
                sys.executable,
                str(SCRIPTS_DIR / "build_docx.py"),
                "--module", mod,
                "--type", "tkcsld"
            ]
            res = subprocess.run(cmd, capture_output=True, text=True, cwd=str(REPO_ROOT))
            self.assertEqual(
                res.returncode,
                0,
                f"build_docx failed for {mod} tkcsld:\nSTDOUT: {res.stdout}\nSTDERR: {res.stderr}"
            )
            docx_out = OUTPUT_DIR / mod / f"DTM_{mod}_TKCSLD.docx"
            self.assertTrue(docx_out.exists(), f"Expected docx file {docx_out} was not generated")
            self.assertGreater(docx_out.stat().st_size, 1000, f"Generated docx file {docx_out} is too small")


if __name__ == "__main__":
    unittest.main(verbosity=2)
