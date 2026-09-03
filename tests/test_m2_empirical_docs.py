"""Empirical Test Suite for Milestone 2 - Datamart Documentation Verification.

Author: Challenger 1 (Empirical Verifier)
Date: 2026-08-28
"""

import glob
import os
import re
import sys
import unittest
from typing import Dict, List, Tuple, Any

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8")

MODULES = ["TT", "NHNCK", "NDTNN", "QLCB", "GSDC", "GSTT", "QLQ", "QLKD", "PTTT", "TKNB"]

EXPECTED_PTTK_HEADERS = {
    "TT": "## 3.1.1 LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO Hoạt động Thanh tra",
    "NHNCK": "## 3.1.2 LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO Người hành nghề",
    "NDTNN": "## 3.1.3 LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO Quản lý NĐTNN",
    "QLCB": "## 3.1.4 LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO Quản lý chào bán",
    "GSDC": "## 3.1.5 LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO Giám sát Công ty Đại chúng",
    "GSTT": "## 3.1.6 LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO Giám sát Thị trường",
    "QLQ": "## 3.1.7 LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO Công ty Quản lý Quỹ (AMC)",
    "QLKD": "## 3.1.8 LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO Hoạt động Công ty Chứng khoán",
    "PTTT": "## 3.1.9 LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO Phân tích thị trường",
    "TKNB": "## 3.1.10 LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO Thống kê Thị trường",
}

EXPECTED_TKCSLD_H1 = {
    "TT": "# 3. KHO DỮ LIỆU (OLAP) — Hoạt động Thanh tra",
    "NHNCK": "# 3. KHO DỮ LIỆU (OLAP) — Người hành nghề",
    "NDTNN": "# 3. KHO DỮ LIỆU (OLAP) — Quản lý NĐTNN",
    "QLCB": "# 3. KHO DỮ LIỆU (OLAP) — Quản lý chào bán",
    "GSDC": "# 3. KHO DỮ LIỆU (OLAP) — Giám sát Công ty Đại chúng",
    "GSTT": "# 3. KHO DỮ LIỆU (OLAP) — Giám sát Thị trường",
    "QLQ": "# 3. KHO DỮ LIỆU (OLAP) — Công ty Quản lý Quỹ (AMC)",
    "QLKD": "# 3. KHO DỮ LIỆU (OLAP) — Hoạt động Công ty Chứng khoán",
    "PTTT": "# 3. KHO DỮ LIỆU (OLAP) — Phân tích thị trường",
    "TKNB": "# 3. KHO DỮ LIỆU (OLAP) — Thống kê Thị trường",
}

EXPECTED_PHYS_HEADER = [
    "STT", "Tên trường", "Kiểu dữ liệu và độ dài", "Nullable", "Unique", "P/F Key",
    "Giá trị mặc định", "Mô tả", "Hệ thống nguồn", "Schema.Table", "Source Field Name", "ETL Rules"
]
EXPECTED_LOGIC_HEADER = [
    "STT", "Tên trường", "Kiểu dữ liệu và độ dài", "Nullable", "Unique", "P/F Key", "Mặc định", "Mô tả"
]
EXPECTED_CONCEPT_HEADER = ["STT", "Thực thể", "Tên bảng", "Mô tả"]

NOISE_PATTERNS = [
    (r"\bPK\s+surrogate\b", "PK surrogate"),
    (r"\bFK\s+surrogate\b", "FK surrogate"),
    (r"\(PK\s+surrogate\)", "(PK surrogate)"),
    (r"\bSurrogate\s+PK\b", "Surrogate PK"),
    (r"\bMã\s+surrogate\b", "Mã surrogate"),
    (r"\bSilver\s+surrogate\b", "Silver surrogate"),
    (r"\bSurrogate\s+key\b", "Surrogate key"),
    (r"\bsurrogate\s+key\b", "surrogate key"),
    (r"\bBCV:", "BCV:"),
    (r"\bHash:", "Hash:"),
    (r"\bNguồn\s+thực:", "Nguồn thực:"),
    (r"\bDedup\b", "Dedup"),
    (r"\bROW_NUMBER\b", "ROW_NUMBER"),
    (r"\bQUALIFY\b", "QUALIFY"),
    (r"\bjoin_atomic\b", "join_atomic"),
    (r"\bjoin\s+anchor\b", "join anchor"),
    (r"\bETL-derived\b", "ETL-derived"),
    (r"\bETL\s+derived\b", "ETL derived"),
    (r"\bETL\s+lookup\b", "ETL lookup"),
    (r"\bETL\s+extract\b", "ETL extract"),
    (r"\bETL\s+pick\b", "ETL pick"),
    (r"\bETL\s+join\b", "ETL join"),
    (r"\bScheme:", "Scheme:"),
    (r"←", "Arrow ←"),
    (r"\b1\s+row\s+per\b", "1 row per"),
    (r"\b1\s+dòng\s+per\b", "1 dòng per"),
]

class TestMilestone2Empirical(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.metrics = {
            "pttk_files": 0,
            "tkcsld_files": 0,
            "total_tables": 0,
            "concept_tables": 0,
            "logic_tables": 0,
            "phys_tables": 0,
            "total_rows": 0,
            "concept_rows": 0,
            "logic_rows": 0,
            "phys_rows": 0,
            "total_cells": 0,
            "schema_table_cells_checked": 0,
            "mota_cells_checked": 0,
            "schema_table_errors": [],
            "mota_noise_errors": [],
            "header_errors": [],
            "row_col_errors": [],
            "pttk_header_errors": [],
            "pttk_bullet_errors": [],
            "tkcsld_h1_errors": [],
            "tkcsld_section_errors": []
        }

        for mod in MODULES:
            pttk_path = f"docs/output/datamart/{mod}/DTM_{mod}_PTTK.md"
            if os.path.exists(pttk_path):
                cls.metrics["pttk_files"] += 1
                with open(pttk_path, "r", encoding="utf-8") as f:
                    p_lines = f.readlines()
                p_content = "".join(p_lines)
                top_h = p_lines[0].strip() if p_lines else ""
                if top_h != EXPECTED_PTTK_HEADERS[mod]:
                    cls.metrics["pttk_header_errors"].append((mod, top_h, EXPECTED_PTTK_HEADERS[mod]))
                
                m_sec1 = re.search(r"###\s+3\.1\.\d+\.1\s+Thông tin chung luồng đồng bộ", p_content)
                if m_sec1:
                    sec1_text = p_content.split(m_sec1.group(0))[1].split("### 3.1.")[0]
                    lowers = re.findall(r"^\s*-\s+([a-z\u00E0-\u1EF9][^:\n]+:)", sec1_text, re.MULTILINE)
                    if lowers:
                        cls.metrics["pttk_bullet_errors"].append((mod, lowers))

            tkcsld_path = f"docs/output/datamart/{mod}/DTM_{mod}_TKCSLD.md"
            if os.path.exists(tkcsld_path):
                cls.metrics["tkcsld_files"] += 1
                with open(tkcsld_path, "r", encoding="utf-8") as f:
                    t_lines = f.readlines()
                t_content = "".join(t_lines)
                
                top_h1 = t_lines[0].strip() if t_lines else ""
                if top_h1 != EXPECTED_TKCSLD_H1[mod]:
                    cls.metrics["tkcsld_h1_errors"].append((mod, top_h1, EXPECTED_TKCSLD_H1[mod]))

                if "## 3.1 Mô hình dữ liệu mức High Level / Conceptual" not in t_content:
                    cls.metrics["tkcsld_section_errors"].append((mod, "Missing 3.1 Conceptual"))
                if "## 3.2 Mô hình dữ liệu mức Logic" not in t_content:
                    cls.metrics["tkcsld_section_errors"].append((mod, "Missing 3.2 Logic"))
                if "## 3.3 Mô hình dữ liệu mức vật lý" not in t_content:
                    cls.metrics["tkcsld_section_errors"].append((mod, "Missing 3.3 Physical"))

                current_section = ""
                table_lines = []
                in_table = False
                file_tables = []
                for line_idx, line in enumerate(t_lines, 1):
                    sline = line.strip()
                    if sline.startswith("## 3.1"):
                        current_section = "3.1"
                    elif sline.startswith("## 3.2"):
                        current_section = "3.2"
                    elif sline.startswith("## 3.3"):
                        current_section = "3.3"

                    if sline.startswith("|") and sline.endswith("|"):
                        table_lines.append((line_idx, sline, current_section))
                        in_table = True
                    else:
                        if in_table and table_lines:
                            file_tables.append(table_lines)
                            table_lines = []
                        in_table = False
                if table_lines:
                    file_tables.append(table_lines)

                for tbl in file_tables:
                    cls.metrics["total_tables"] += 1
                    sec = tbl[0][2]
                    header_l_idx, header_raw, _ = tbl[0]
                    header_cols = [c.strip() for c in header_raw.split("|")[1:-1]]

                    if sec == "3.1":
                        cls.metrics["concept_tables"] += 1
                        if header_cols != EXPECTED_CONCEPT_HEADER:
                            cls.metrics["header_errors"].append((mod, "3.1", header_l_idx, header_cols, EXPECTED_CONCEPT_HEADER))
                    elif sec == "3.2":
                        cls.metrics["logic_tables"] += 1
                        if header_cols != EXPECTED_LOGIC_HEADER:
                            cls.metrics["header_errors"].append((mod, "3.2", header_l_idx, header_cols, EXPECTED_LOGIC_HEADER))
                    elif sec == "3.3":
                        cls.metrics["phys_tables"] += 1
                        if header_cols != EXPECTED_PHYS_HEADER:
                            cls.metrics["header_errors"].append((mod, "3.3", header_l_idx, header_cols, EXPECTED_PHYS_HEADER))

                    expected_len = len(header_cols)

                    for r_idx, (l_num, r_raw, _) in enumerate(tbl[2:], 3):
                        cols = [c.strip() for c in r_raw.split("|")[1:-1]]
                        cls.metrics["total_cells"] += len(cols)
                        if len(cols) != expected_len:
                            cls.metrics["row_col_errors"].append((mod, sec, l_num, len(cols), expected_len, r_raw))

                        if sec == "3.1":
                            cls.metrics["concept_rows"] += 1
                            cls.metrics["total_rows"] += 1
                            if len(cols) >= 4:
                                cls.metrics["mota_cells_checked"] += 1
                                mota = cols[3]
                                for pat, label in NOISE_PATTERNS:
                                    if re.search(pat, mota, re.IGNORECASE):
                                        cls.metrics["mota_noise_errors"].append((mod, "3.1 Conceptual", l_num, cols[1] if len(cols)>1 else "", label, mota))

                        elif sec == "3.2":
                            cls.metrics["logic_rows"] += 1
                            cls.metrics["total_rows"] += 1
                            if len(cols) >= 8:
                                cls.metrics["mota_cells_checked"] += 1
                                mota = cols[7]
                                for pat, label in NOISE_PATTERNS:
                                    if re.search(pat, mota, re.IGNORECASE):
                                        cls.metrics["mota_noise_errors"].append((mod, "3.2 Logic", l_num, cols[1] if len(cols)>1 else "", label, mota))

                        elif sec == "3.3":
                            cls.metrics["phys_rows"] += 1
                            cls.metrics["total_rows"] += 1
                            if len(cols) >= 12:
                                field_name = cols[1]
                                mota = cols[7]
                                src_sys = cols[8]
                                schema_table = cols[9]
                                etl_rules = cols[11]

                                cls.metrics["mota_cells_checked"] += 1
                                cls.metrics["schema_table_cells_checked"] += 1

                                is_sys_field = field_name.lower() in ["eff_dt", "expr_dt", "popln_dt", "created_at", "updated_at", "deleted_flag"]
                                if schema_table != "" and schema_table != "-":
                                    if not schema_table.startswith("ATM."):
                                        cls.metrics["schema_table_errors"].append((mod, l_num, field_name, schema_table, "Missing ATM. prefix"))
                                else:
                                    if not is_sys_field and "sinh tự động" not in etl_rules.lower() and src_sys != "" and src_sys != "-":
                                        cls.metrics["schema_table_errors"].append((mod, l_num, field_name, "<EMPTY>", f"Missing schema.table for non-system field (src: {src_sys})"))

                                for pat, label in NOISE_PATTERNS:
                                    if re.search(pat, mota, re.IGNORECASE):
                                        cls.metrics["mota_noise_errors"].append((mod, "3.3 Physical", l_num, field_name, label, mota))

    def test_01_all_files_exist(self):
        """Verify all 10 PTTK and 10 TKCSLD files exist."""
        self.assertEqual(self.metrics["pttk_files"], 10, "Not all 10 PTTK files exist")
        self.assertEqual(self.metrics["tkcsld_files"], 10, "Not all 10 TKCSLD files exist")

    def test_02_pttk_headers_and_bullets(self):
        """Verify PTTK headers match standard and bullet points are capitalized."""
        self.assertEqual(len(self.metrics["pttk_header_errors"]), 0, f"PTTK Header errors: {self.metrics['pttk_header_errors']}")
        self.assertEqual(len(self.metrics["pttk_bullet_errors"]), 0, f"PTTK Bullet errors: {self.metrics['pttk_bullet_errors']}")

    def test_03_tkcsld_h1_and_sections(self):
        """Verify TKCSLD H1 titles and 3 sections exist."""
        self.assertEqual(len(self.metrics["tkcsld_h1_errors"]), 0, f"TKCSLD H1 errors: {self.metrics['tkcsld_h1_errors']}")
        self.assertEqual(len(self.metrics["tkcsld_section_errors"]), 0, f"TKCSLD section errors: {self.metrics['tkcsld_section_errors']}")

    def test_04_table_headers_and_column_counts(self):
        """Verify all tables have exact standard headers and matching column counts."""
        self.assertEqual(self.metrics["phys_tables"], 123, f"Expected 123 physical tables, got {self.metrics['phys_tables']}")
        self.assertEqual(self.metrics["logic_tables"], 123, f"Expected 123 logic tables, got {self.metrics['logic_tables']}")
        self.assertEqual(self.metrics["concept_tables"], 10, f"Expected 10 concept tables, got {self.metrics['concept_tables']}")
        self.assertEqual(len(self.metrics["header_errors"]), 0, f"Header mismatch errors: {self.metrics['header_errors']}")
        self.assertEqual(len(self.metrics["row_col_errors"]), 0, f"Row column count errors: {self.metrics['row_col_errors']}")

    def test_05_schema_table_atm_prefix(self):
        """Verify 100% of non-system Schema.Table cells have ATM. prefix."""
        self.assertEqual(len(self.metrics["schema_table_errors"]), 0, f"Schema.Table prefix errors: {self.metrics['schema_table_errors']}")

    def test_06_mota_technical_noise(self):
        """Verify 0 technical noise strings exist in column Mô tả across all tables."""
        print(f"\n[METRICS SUMMARY]")
        print(f"- PTTK Files: {self.metrics['pttk_files']}/10")
        print(f"- TKCSLD Files: {self.metrics['tkcsld_files']}/10")
        print(f"- Total Tables: {self.metrics['total_tables']} (Concept: {self.metrics['concept_tables']}, Logic: {self.metrics['logic_tables']}, Physical: {self.metrics['phys_tables']})")
        print(f"- Total Rows: {self.metrics['total_rows']} (Concept: {self.metrics['concept_rows']}, Logic: {self.metrics['logic_rows']}, Physical: {self.metrics['phys_rows']})")
        print(f"- Total Cells Checked: {self.metrics['total_cells']}")
        print(f"- Schema.Table Cells Checked: {self.metrics['schema_table_cells_checked']}")
        print(f"- Mô tả Cells Checked: {self.metrics['mota_cells_checked']}")
        print(f"- Schema.Table Errors: {len(self.metrics['schema_table_errors'])}")
        print(f"- Mô tả Technical Noise Violations: {len(self.metrics['mota_noise_errors'])}")

        if self.metrics['mota_noise_errors']:
            print("\n[VIOLATIONS FOUND]:")
            for v in self.metrics['mota_noise_errors']:
                print(f"  [{v[0]}] [{v[1]}] Line {v[2]} ({v[3]}): [{v[4]}] -> \"{v[5]}\"")

        self.assertEqual(len(self.metrics["mota_noise_errors"]), 0, f"Found {len(self.metrics['mota_noise_errors'])} noise violations")

if __name__ == "__main__":
    unittest.main(verbosity=2)