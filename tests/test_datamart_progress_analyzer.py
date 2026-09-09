# -*- coding: utf-8 -*-
"""
tests/test_datamart_progress_analyzer.py

Comprehensive Unit Test Suite for datamart_progress_analyzer.py (Phase P2 / Item 12):
- Tests 1-4: Delimiter and header detection, unquoted SQL comma resilience, BAParser parse_file & get_deleted_items.
- Tests 5-7: HLDParser multi-level headings (PA-04: 3.2.2.x, dots), pipe-in-formula resilience, parse_file.
- Test 8: DetailMappingParser for comma and semicolon files.
- Tests 9, 10, 15: PendingClassifier all 6 branches, PA-05 count mismatch decoupling, exhaustive condition coverage.
- Tests 11, 12, 13, 19, 20: DatamartProgressAnalyzer end-to-end integration, deleted violations, markdown report, HLD-only layer, real QLKD module.
- Test 14: Shared datamart_common utilities.
- Tests 16-18: BA matching heuristics, BAParser edge cases, HLDParser advanced coverage.
"""

from __future__ import annotations

import csv
import io
import os
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

def _find_repo_root() -> Path:
    p = Path(__file__).resolve()
    for parent in [p] + list(p.parents):
        if (parent / "BRD" / "BA").exists():
            return parent
    return p.parents[1]

REPO_ROOT = _find_repo_root()
SCRIPTS_DIR = REPO_ROOT / "scripts"

if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

from datamart_progress_analyzer import (
    BAItem,
    BAParser,
    HLDItem,
    HLDParser,
    DetailMappingItem,
    DetailMappingParser,
    PendingClassifier,
    DatamartProgressAnalyzer,
    normalize_module_code,
    clean_kpi_name,
    format_table_cell,
    main,
)

import datamart_common
from datamart_common import (
    detect_file_encoding,
    read_file_safe,
    detect_delimiter,
    detect_delimiter_and_header,
    read_csv_dynamic,
    normalize_module_name,
    resolve_module_path,
    get_module_files,
    load_whitelist,
    is_group_whitelisted,
)


def _make_ba_item(
    stt: str = "1",
    dashboard: str = "Dashboard Test",
    name: str = "Chỉ tiêu test",
    description: str = "Mô tả",
    requirement_group: str = "Nhóm 1",
    classification: str = "Chỉ tiêu cơ sở",
    evaluation: str = "Dễ",
    mapping_status: str = "Done",
    source_table: str = "atomic.trade",
    source_column: str = "trade_id",
    data_type: str = "NUMBER",
    condition: str = "",
    sql: str = "SELECT 1",
    note: str = "",
    raw_row: list = None,
) -> BAItem:
    """Helper to construct BAItem with all 14 required positional arguments."""
    return BAItem(
        stt=stt,
        dashboard=dashboard,
        name=name,
        description=description,
        requirement_group=requirement_group,
        classification=classification,
        evaluation=evaluation,
        mapping_status=mapping_status,
        source_table=source_table,
        source_column=source_column,
        data_type=data_type,
        condition=condition,
        sql=sql,
        note=note,
        raw_row=raw_row or [],
    )


class TestBAParserAndDelimiter(unittest.TestCase):
    """Tests 1-4 & 17: Delimiter detection, BA parsing, and edge-case handling."""

    def test_01_detect_delimiter_and_header_semicolon(self):
        """Test detection on standard semicolon-delimited BA file."""
        content = (
            "STT;Màn hình/Dashboard;Tên chỉ tiêu;Mô tả;Nhóm yêu cầu;Phân loại;Đánh giá;Trạng thái mapping;"
            "Bảng nguồn;Cột nguồn;Loại dữ liệu;Điều kiện;Câu lệnh SQL;Ghi chú\n"
            "1;Dash 1;Chỉ tiêu 1;Mô tả 1;Nhóm 1;Chỉ tiêu cơ sở;Dễ;Done;tbl_src;col_1;VARCHAR;None;SELECT 1;Ghi chú 1\n"
            "2;Dash 1;Chỉ tiêu 2;Mô tả 2;Nhóm 1;Chỉ tiêu cơ sở;Dễ;Pending;tbl_src;col_2;NUMBER;None;SELECT 2;Ghi chú 2\n"
        )
        delim, hdr_idx, header, rows = BAParser.detect_delimiter_and_header(content)
        self.assertEqual(delim, ";")
        self.assertEqual(hdr_idx, 0)
        self.assertGreaterEqual(len(header), 10)
        self.assertEqual(len(rows), 2)
        self.assertIn("STT", header[0].upper())

    def test_02_detect_delimiter_and_header_comma(self):
        """Test detection on standard comma-delimited BA file."""
        content = (
            "STT,Màn hình/Dashboard,Tên chỉ tiêu,Mô tả,Nhóm yêu cầu,Phân loại,Đánh giá,Trạng thái mapping,"
            "Bảng nguồn,Cột nguồn,Loại dữ liệu,Điều kiện,Câu lệnh SQL,Ghi chú\n"
            "1,Dash A,KPI Comma 1,Desc 1,Nhóm 1,Chỉ tiêu cơ sở,Dễ,Done,tbl_a,col_a,VARCHAR,None,SELECT 1,Note 1\n"
            "2,Dash A,KPI Comma 2,Desc 2,Nhóm 1,Chỉ tiêu cơ sở,Dễ,Done,tbl_a,col_b,NUMBER,None,SELECT 2,Note 2\n"
        )
        delim, hdr_idx, header, rows = BAParser.detect_delimiter_and_header(content)
        self.assertEqual(delim, ",")
        self.assertEqual(hdr_idx, 0)
        self.assertGreaterEqual(len(header), 10)
        self.assertEqual(len(rows), 2)

    def test_03_detect_delimiter_resilience_with_unquoted_sql_commas(self):
        """Test resilience when semicolon file has SQL text cells containing many unquoted commas."""
        content = (
            "STT;Dashboard/báo cáo;Tên chỉ tiêu;Mô tả;Nhóm yêu cầu;Phân loại;Đánh giá;Trạng thái mapping;"
            "Bảng nguồn;Cột nguồn;Loại dữ liệu;Điều kiện;Câu lệnh SQL;Ghi chú\n"
            "1;D1;KPI 1;Mô tả;Nhóm 1;Cơ sở;Dễ;Done;tbl;col;INT;;SELECT col1, col2, col3, col4, col5 FROM src;note\n"
            "2;D1;KPI 2;Mô tả;Nhóm 1;Cơ sở;Dễ;Done;tbl;col;INT;;SELECT a, b, c, d, e, f, g FROM src;note\n"
            "3;D1;KPI 3;Mô tả;Nhóm 1;Cơ sở;Dễ;Done;tbl;col;INT;;SELECT x, y, z FROM src;note\n"
        )
        delim, hdr_idx, header, rows = BAParser.detect_delimiter_and_header(content)
        self.assertEqual(delim, ";", "Delimiter detection must not be fooled by unquoted commas in SQL cells")
        self.assertEqual(len(rows), 3)

    def test_04_ba_parser_parse_file_and_get_deleted_items(self):
        """Test BAParser.parse_file with include_deleted flag and get_deleted_items."""
        with tempfile.TemporaryDirectory() as tmpdir:
            file_path = Path(tmpdir) / "BA_test.csv"
            file_path.write_text(
                "STT;Dashboard/báo cáo;Tên chỉ tiêu;Mô tả;Nhóm yêu cầu;Phân loại;Đánh giá;Trạng thái mapping;Bảng nguồn;Cột nguồn;Loại dữ liệu;Điều kiện;Câu lệnh SQL;Ghi chú\n"
                "1;Dash;Chỉ tiêu Active;Mô tả;Nhóm 1;Cơ sở;Dễ;Done;tbl;col;INT;;;\n"
                "2;Dash;Chỉ tiêu Deleted 1;Mô tả;Nhóm 1;Cơ sở;Dễ;Delete;tbl;col;INT;;;\n"
                "3;Dash;Chỉ tiêu Deleted 2;Mô tả;Nhóm 1;Cơ sở;Dễ;DELETED;tbl;col;INT;;;\n"
                "4;Dash;Chỉ tiêu Deleted 3;Mô tả;Nhóm 1;Cơ sở;Dễ;Xóa;tbl;col;INT;;;\n",
                encoding="utf-8",
            )

            active_items = BAParser.parse_file(file_path, include_deleted=False)
            self.assertEqual(len(active_items), 1)
            self.assertEqual(active_items[0].name, "Chỉ tiêu Active")

            all_items = BAParser.parse_file(file_path, include_deleted=True)
            self.assertEqual(len(all_items), 4)

            deleted_items = BAParser.get_deleted_items(file_path)
            self.assertEqual(len(deleted_items), 3)
            del_names = [d.name for d in deleted_items]
            self.assertIn("Chỉ tiêu Deleted 1", del_names)
            self.assertIn("Chỉ tiêu Deleted 2", del_names)
            self.assertIn("Chỉ tiêu Deleted 3", del_names)

    def test_17_ba_parser_advanced_coverage(self):
        """Test BAParser on non-standard rows, missing columns, and empty files."""
        with tempfile.TemporaryDirectory() as tmpdir:
            empty_file = Path(tmpdir) / "empty.csv"
            empty_file.write_text("", encoding="utf-8")
            self.assertEqual(BAParser.parse_file(empty_file), [])

            non_existent = Path(tmpdir) / "not_exist.csv"
            self.assertEqual(BAParser.parse_file(non_existent), [])

            short_csv = Path(tmpdir) / "short.csv"
            short_csv.write_text(
                "STT,Tên chỉ tiêu\n1,KPI Chỉ có 2 cột\n",
                encoding="utf-8",
            )
            parsed = BAParser.parse_file(short_csv)
            self.assertEqual(len(parsed), 0)


class TestHLDParser(unittest.TestCase):
    """Tests 5-7 & 18: HLDParser regex, pipe-in-formula, file parsing, edge cases."""

    def test_05_hld_parser_hierarchical_group_headings(self):
        """Test HLDParser regex supporting BRD numbering (3.2.2.x), dots, and various separators."""
        md_content = """# HLD Design Test
### 3.2.2.1 Nhóm 1: Tên nhóm có tiền tố số
| Mã chỉ tiêu | Tên chỉ tiêu | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| K_TEST_01 | Chỉ tiêu HLD 1 | Đồng | Tiền tệ | sum(amount) | None | READY |

## 3. Nhóm 2. Tên nhóm dùng dấu chấm
| Mã chỉ tiêu | Tên chỉ tiêu | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| K_TEST_02 | Chỉ tiêu HLD 2 | Số | Đếm | count(1) | None | READY |

#### Nhóm 3 - Tên nhóm dùng gạch nối
| Mã chỉ tiêu | Tên chỉ tiêu | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| K_TEST_03 | Chỉ tiêu HLD 3 | % | Tỷ lệ | a / b | None | PENDING |

##### Nhóm 4: Tên nhóm heading cấp 5
| Mã chỉ tiêu | Tên chỉ tiêu | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| K_TEST_04 | Chỉ tiêu HLD 4 | Đơn vị | Số | count(id) | None | READY |
"""
        items = HLDParser.parse_text(md_content, module="TEST")
        self.assertEqual(len(items), 4)
        self.assertEqual(items[0].group_num, 1)
        self.assertEqual(items[1].group_num, 2)
        self.assertEqual(items[2].group_num, 3)
        self.assertEqual(items[3].group_num, 4)

    def test_06_hld_parser_pipe_in_formula_and_missing_notes(self):
        """Test table parsing resilience when formulas contain pipe '|' or '||' and when notes are empty."""
        md_content = """# HLD Table Resiliency
### Nhóm 1: Công thức chứa ký tự ống
| Mã chỉ tiêu | Tên chỉ tiêu | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| K_MOD_01 | KPI Pipe | Mã | Chuỗi | col_a || ' - ' || col_b | Ghi chú đặc biệt | READY |
| K_MOD_02 | KPI 6 Cols | Số | Đếm | count(1) | READY |
| K_MOD_03 | KPI Short | Số | Đếm | val |
"""
        items = HLDParser.parse_text(md_content, module="MOD")
        self.assertIn("col_a", items[0].formula)
        self.assertIn("col_b", items[0].formula)
        self.assertEqual(items[0].status, "READY")
        self.assertEqual(items[1].status, "READY")
        self.assertEqual(items[2].formula, "val")

    def test_07_hld_parser_parse_file(self):
        """Test HLDParser.parse_file from physical disk path."""
        with tempfile.TemporaryDirectory() as tmpdir:
            file_path = Path(tmpdir) / "HLD_test.md"
            file_path.write_text(
                "### Nhóm 1: Quản lý\n"
                "| Mã chỉ tiêu | Tên chỉ tiêu | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |\n"
                "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |\n"
                "| K_TEST_01 | Chỉ tiêu đĩa | Đồng | Số | 1 | | READY |\n",
                encoding="utf-8",
            )
            items = HLDParser.parse_file(file_path, module="TEST")
            self.assertEqual(len(items), 1)
            self.assertEqual(items[0].kpi_id, "K_TEST_01")

    def test_18_hld_parser_advanced_coverage(self):
        """Test HLDParser on non-table lines, missing files, and short rows."""
        with tempfile.TemporaryDirectory() as tmpdir:
            missing_file = Path(tmpdir) / "no_hld.md"
            self.assertEqual(HLDParser.parse_file(missing_file, module="TEST"), [])

            text = (
                "Chỉ là dòng text thông thường\n"
                "| Cột 1 | Cột 2 |\n"
                "|---|---|\n"
                "| text | text |\n"
            )
            self.assertEqual(HLDParser.parse_text(text, module="TEST"), [])


class TestDetailMappingParser(unittest.TestCase):
    """Test 8: DetailMappingParser parsing comma and semicolon CSVs."""

    def test_08_detail_mapping_parse_file_comma_and_semicolon(self):
        """Test DetailMappingParser parsing comma and semicolon CSVs."""
        with tempfile.TemporaryDirectory() as tmpdir:
            comma_file = Path(tmpdir) / "DM_comma.csv"
            comma_file.write_text(
                "kpi_id,tab,nhom,kpi_name,tinh_chat,source_module,mart_table,mart_column,column_role,logic,ghi_chu\n"
                "K_MOD_01,Tab1,Nhóm 1,Tên 1,Tiền tệ,Atomic,fact_trade,amount,MEASURE,sum(amt),Note 1\n",
                encoding="utf-8",
            )
            items_c = DetailMappingParser.parse_file(comma_file)
            self.assertEqual(len(items_c), 1)
            self.assertEqual(items_c[0].kpi_id, "K_MOD_01")
            self.assertEqual(items_c[0].group_num, 1)

            semi_file = Path(tmpdir) / "DM_semi.csv"
            semi_file.write_text(
                "kpi_id;tab;nhom;kpi_name;tinh_chat;source_module;mart_table;mart_column;column_role;logic;ghi_chu\n"
                "K_MOD_02;Tab2;Nhóm 2;Tên 2;Số lượng;Atomic;dim_broker;broker_id;DIMENSION;id;Note 2\n",
                encoding="utf-8",
            )
            items_s = DetailMappingParser.parse_file(semi_file)
            self.assertEqual(len(items_s), 1)
            self.assertEqual(items_s[0].kpi_id, "K_MOD_02")
            self.assertEqual(items_s[0].group_num, 2)

            non_exist = Path(tmpdir) / "no_dm.csv"
            self.assertEqual(DetailMappingParser.parse_file(non_exist), [])


class TestPendingClassifier(unittest.TestCase):
    """Tests 9, 10 & 15: PendingClassifier all 6 branches and exhaustive condition coverage."""

    def test_09_classify_all_six_branches(self):
        """Verify that each of the 6 branches is activated under its distinct criteria."""
        # Branch 1: BA Pending
        b1 = PendingClassifier.classify("KPI 1", "Pending", "tbl", "INT")
        self.assertEqual(b1, PendingClassifier.REASON_BA_PENDING)

        # Branch 2: Chưa có mapping nguồn từ BA
        b2 = PendingClassifier.classify("KPI 2", "Done", "Chưa có CSDL", "VARCHAR")
        self.assertEqual(b2, PendingClassifier.REASON_NO_BA_SOURCE)

        # Branch 3: Thiếu nguồn dữ liệu ngoại lai
        b3 = PendingClassifier.classify("KPI 3", "Done", "UAT_VSDC.tbl_trade", "NUMBER")
        self.assertEqual(b3, PendingClassifier.REASON_EXTERNAL_SOURCE)

        # Branch 4: Join đa nguồn phức tạp
        b4 = PendingClassifier.classify("KPI 4", "Done", "scms_nhnck.tbl_bridge", "VARCHAR")
        self.assertEqual(b4, PendingClassifier.REASON_COMPLEX_JOIN)

        # Branch 5: Datamart Pending
        b5 = PendingClassifier.classify("KPI 5", "Done", "atomic.fact_order", "INT")
        self.assertEqual(b5, PendingClassifier.REASON_DATAMART_PENDING)

        # Branch 6: Lệch số lượng / Schema out of sync
        b6 = PendingClassifier.classify("KPI 6", "Done", "atomic.fact_order", "INT", ghi_chu="mismatch schema atomic")
        self.assertEqual(b6, PendingClassifier.REASON_SCHEMA_OUT_OF_SYNC)

    def test_10_classify_branch_5_preserved_with_group_count_mismatch(self):
        """PA-05: Group count mismatch alone must NOT force Branch 6; Branch 5 must be preserved."""
        res = PendingClassifier.classify(
            kpi_name="Số lượng tài khoản",
            ba_status="Done",
            ba_source="atomic.dim_account",
            ba_data_type="BIGINT",
            group_name="Nhóm 1",
            ghi_chu="",
            has_count_mismatch=True,
        )
        self.assertEqual(
            res,
            PendingClassifier.REASON_DATAMART_PENDING,
            "Count mismatch alone must NOT override Branch 5",
        )

    def test_15_pending_classifier_full_condition_coverage(self):
        """Test all branches, keywords and precedence paths in PendingClassifier."""
        # Branch 1: empty or whitespace status
        self.assertEqual(
            PendingClassifier.classify("KPI", "", "atomic.tbl", "INT"),
            PendingClassifier.REASON_BA_PENDING,
        )
        self.assertEqual(
            PendingClassifier.classify("KPI", "   ", "atomic.tbl", "INT"),
            PendingClassifier.REASON_BA_PENDING,
        )

        # Branch 2 keywords: 'n/a', '(trống)', 'map biểu mẫu'
        self.assertEqual(
            PendingClassifier.classify("KPI", "Done", "N/A", "INT"),
            PendingClassifier.REASON_NO_BA_SOURCE,
        )
        self.assertEqual(
            PendingClassifier.classify("KPI", "Done", "tbl", "map biểu mẫu"),
            PendingClassifier.REASON_NO_BA_SOURCE,
        )
        self.assertEqual(
            PendingClassifier.classify("KPI", "Done", "tbl", "INT", ghi_chu="biểu mẫu giấy"),
            PendingClassifier.REASON_NO_BA_SOURCE,
        )

        # Branch 3 keywords: 'hose', 'hnx', 'sbv', 'thị phần', 'vsd'
        for kw in ["hose", "hnx", "sbv", "vsd", "ngoại lai"]:
            self.assertEqual(
                PendingClassifier.classify("KPI", "Done", f"source_{kw}", "INT"),
                PendingClassifier.REASON_EXTERNAL_SOURCE,
            )
        self.assertEqual(
            PendingClassifier.classify("Thị phần môi giới", "Done", "tbl_market", "INT"),
            PendingClassifier.REASON_EXTERNAL_SOURCE,
        )

        # Branch 4 keywords: 'multi-source', 'scms và nhnck', 'chứng chỉ hành nghề'
        self.assertEqual(
            PendingClassifier.classify("KPI", "Done", "multi-source table", "INT"),
            PendingClassifier.REASON_COMPLEX_JOIN,
        )
        self.assertEqual(
            PendingClassifier.classify("Chứng chỉ hành nghề số 1", "Done", "tbl_cert", "INT"),
            PendingClassifier.REASON_COMPLEX_JOIN,
        )

        # Branch 6 keywords: 'chưa approved', 'out of sync', 'deprecated', and regex (?<!chênh\s)\blệch\b
        for kw in ["chưa approved", "out of sync", "deprecated", "chưa duyệt", "out of date", "atomic chưa"]:
            self.assertEqual(
                PendingClassifier.classify("KPI", "Done", "atomic.tbl", "INT", ghi_chu=f"Lưu ý: {kw}"),
                PendingClassifier.REASON_SCHEMA_OUT_OF_SYNC,
            )
        self.assertEqual(
            PendingClassifier.classify("KPI", "Done", "atomic.tbl", "INT", ghi_chu="bị lệch số dòng"),
            PendingClassifier.REASON_SCHEMA_OUT_OF_SYNC,
        )
        self.assertEqual(
            PendingClassifier.classify("KPI", "Done", "atomic.tbl", "INT", ghi_chu="chênh lệch tự nhiên"),
            PendingClassifier.REASON_DATAMART_PENDING,
        )
        self.assertEqual(
            PendingClassifier.classify("KPI", "Done", "chưa có", "INT"),
            PendingClassifier.REASON_NO_BA_SOURCE,
        )
        self.assertEqual(
            PendingClassifier.classify("KPI", "Done", "null", "INT"),
            PendingClassifier.REASON_NO_BA_SOURCE,
        )


class TestDatamartProgressAnalyzerIntegration(unittest.TestCase):
    """Tests 11, 12, 13, 14, 16, 19, 20: Analyzer integration, heuristics, utilities, and reports."""

    def test_11_analyze_module_end_to_end(self):
        """Test full analyze_module on a mock directory structure."""
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            # Setup folders
            ba_dir = root / "BRD" / "BA"
            hld_dir = root / "Datamart" / "hld"
            dm_dir = root / "Datamart" / "lld"
            ba_dir.mkdir(parents=True)
            hld_dir.mkdir(parents=True)
            dm_dir.mkdir(parents=True)

            # Create mock files
            (ba_dir / "BA_analyst_MOD.csv").write_text(
                "STT;Dashboard/báo cáo;Tên chỉ tiêu;Mô tả;Nhóm yêu cầu;Phân loại;Đánh giá;Trạng thái mapping;Bảng nguồn;Cột nguồn;Loại dữ liệu;Điều kiện;Câu lệnh SQL;Ghi chú\n"
                "1;Dash 1;Chỉ tiêu Đã Xong;Mô tả;Nhóm 1;Cơ sở;Dễ;Done;atomic.trade;trade_id;INT;;;\n"
                "2;Dash 1;Chỉ tiêu Đang Chờ;Mô tả;Nhóm 1;Cơ sở;Dễ;Pending;;;INT;;;\n",
                encoding="utf-8",
            )
            (hld_dir / "DTM_MOD_HLD.md").write_text(
                "### Nhóm 1: Nhóm giao dịch\n"
                "| Mã chỉ tiêu | Tên chỉ tiêu | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |\n"
                "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |\n"
                "| K_MOD_01 | Chỉ tiêu Đã Xong | Số | Đếm | count(trade_id) | | READY |\n"
                "| K_MOD_02 | Chỉ tiêu Đang Chờ | Số | Đếm | count(1) | | PENDING |\n",
                encoding="utf-8",
            )
            (dm_dir / "DTM_MOD_Detail_Mapping.csv").write_text(
                "kpi_id,tab,nhom,kpi_name,tinh_chat,source_module,mart_table,mart_column,column_role,logic,ghi_chu\n"
                "K_MOD_01,Tab1,Nhóm 1,Chỉ tiêu Đã Xong,Tiền tệ,Atomic,fact_trade,trade_id,MEASURE,trade_id,\n"
                "K_MOD_02,Tab1,Nhóm 1,Chỉ tiêu Đang Chờ,Tiền tệ,Atomic,fact_trade,col_pend,MEASURE,,pending\n",
                encoding="utf-8",
            )

            analyzer = DatamartProgressAnalyzer(root)
            results = analyzer.analyze_module("MOD")

            self.assertEqual(results["module"], "MOD")
            self.assertEqual(results["total_ba_rows"], 2)
            self.assertEqual(results["total_dm_rows"], 2)
            self.assertEqual(results["ready_count"], 1)
            self.assertEqual(results["pending_count"], 1)
            self.assertIn("cross_status_matrix", results)

    def test_12_deleted_indicator_violation_in_datamart(self):
        """Item 8: Detect BA deleted indicators that are incorrectly kept in HLD as READY."""
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            ba_dir = root / "BRD" / "BA"
            hld_dir = root / "Datamart" / "hld"
            ba_dir.mkdir(parents=True)
            hld_dir.mkdir(parents=True)

            (ba_dir / "BA_analyst_DEL.csv").write_text(
                "STT;Dashboard/báo cáo;Tên chỉ tiêu;Mô tả;Nhóm yêu cầu;Phân loại;Đánh giá;Trạng thái mapping;Bảng nguồn;Cột nguồn;Loại dữ liệu;Điều kiện;Câu lệnh SQL;Ghi chú\n"
                "1;Dash;Chỉ tiêu đã xóa nhưng vẫn thiết kế;Mô tả;Nhóm 1;Cơ sở;Dễ;Delete;atomic.trade;id;INT;;;\n",
                encoding="utf-8",
            )
            (hld_dir / "DTM_DEL_HLD.md").write_text(
                "### Nhóm 1: Nhóm test delete\n"
                "| Mã chỉ tiêu | Tên chỉ tiêu | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |\n"
                "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |\n"
                "| K_DEL_01 | Chỉ tiêu đã xóa nhưng vẫn thiết kế | Số | Đếm | count(1) | | READY |\n",
                encoding="utf-8",
            )

            analyzer = DatamartProgressAnalyzer(root)
            results = analyzer.analyze_module("DEL")
            self.assertIn("deleted_violations", results)
            self.assertGreaterEqual(len(results["deleted_violations"]), 1)
            self.assertIn("Chỉ tiêu đã xóa nhưng vẫn thiết kế", results["deleted_violations"][0]["kpi_name"])

    def test_13_generate_markdown_report_formatting(self):
        """Test Markdown scorecard report formatting and structure."""
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            analyzer = DatamartProgressAnalyzer(root)
            mock_res = {
                "module": "QLKD",
                "ba_file": "BRD/BA/BA_analyst_QLKD.csv",
                "hld_file": "Datamart/hld/DTM_QLKD_HLD.md",
                "dm_file": "Datamart/lld/DTM_QLKD_Detail_Mapping.csv",
                "total_ba_rows": 10,
                "total_hld_kpis": 8,
                "total_dm_rows": 8,
                "ready_count": 7,
                "pending_count": 1,
                "ready_pct": 87.5,
                "pending_pct": 12.5,
                "evaluated_layer": "LLD",
                "has_dm_file": True,
                "classified_pending": {
                    PendingClassifier.REASON_BA_PENDING: [
                        {
                            "kpi_id": "K_TEST_01",
                            "kpi_name": "KPI Test",
                            "nhom": "Nhóm 1",
                            "ba_source": "tbl_test",
                            "ba_data_type": "INT",
                            "ghi_chu": "",
                        }
                    ]
                },
                "cross_status_matrix": {
                    "Done": {"READY": 7, "PENDING": 1, "Chưa có": 0},
                    "Doing": {"READY": 0, "PENDING": 0, "Chưa có": 0},
                    "Pending": {"READY": 0, "PENDING": 0, "Chưa có": 0},
                    "Chưa xác định": {"READY": 0, "PENDING": 0, "Chưa có": 0},
                    "Delete": {"READY": 0, "PENDING": 0, "Chưa có": 0},
                    "Chưa có trong BA": {"READY": 0, "PENDING": 0, "Chưa có": 0},
                },
                "deleted_violations": [],
                "group_stats": {
                    "1": {
                        "name": "Nhóm 1",
                        "ba_total": 10,
                        "ba_done_doing": 10,
                        "hld_kpis": 8,
                        "dm_rows": 8,
                    }
                },
                "mismatch_groups": [],
            }
            report = analyzer.generate_markdown_report(mock_res)
            self.assertIn("Báo cáo Tiến độ & Đối soát Thiết kế Datamart — Module QLKD", report)
            self.assertIn("1. Tổng quan Trạng thái Thiết kế", report)
            self.assertIn("2. Ma trận Đối soát Tiến độ", report)
            self.assertIn("3. Cây phân loại Chi tiết Nguyên nhân PENDING", report)

    def test_14_datamart_common_utilities(self):
        """Test datamart_common shared functions (encoding, csv_utils, module_resolver)."""
        with tempfile.TemporaryDirectory() as tmpdir:
            fpath = Path(tmpdir) / "sample_utf8.csv"
            fpath.write_text("a,b,c\n1,2,3\n", encoding="utf-8")

            enc = detect_file_encoding(fpath)
            self.assertIn(enc.lower(), ["utf-8", "utf-8-sig", "ascii"])

            text = read_file_safe(fpath)
            self.assertIn("a,b,c", text)

            delim = detect_delimiter(text)
            self.assertEqual(delim, ",")

            d, h_idx, hdr, rows = detect_delimiter_and_header(text)
            self.assertEqual(d, ",")
            self.assertEqual(len(rows), 1)

            delim_out, fields_out, parsed_rows = read_csv_dynamic(fpath)
            self.assertEqual(len(parsed_rows), 1)
            self.assertEqual(parsed_rows[0]["a"], "1")

        self.assertEqual(normalize_module_name("GSDC"), "GSĐC")
        self.assertEqual(normalize_module_name("FMS"), "QLQ")
        resolved = resolve_module_path(REPO_ROOT, "QLKD", "ba")
        self.assertIsNotNone(resolved)

    def test_16_ba_matching_heuristics_full_coverage(self):
        """Test extract_reuse_group and find_ba_match heuristics in DatamartProgressAnalyzer."""
        analyzer = DatamartProgressAnalyzer(REPO_ROOT)

        # extract_reuse_group
        self.assertEqual(analyzer.extract_reuse_group("Chỉ tiêu A (reuse từ Nhóm 2)"), "2")
        self.assertEqual(analyzer.extract_reuse_group("Chỉ tiêu B [reuse từ nhóm 15]"), "15")
        self.assertIsNone(analyzer.extract_reuse_group("Chỉ tiêu không reuse"))

        # find_ba_match
        item1 = _make_ba_item(stt="1", name="Doanh thu môi giới", requirement_group="Nhóm 1")
        item2 = _make_ba_item(stt="2", name="Số lượng tài khoản mở mới", requirement_group="Nhóm 2")
        ba_by_grp = {"1": [item1], "2": [item2]}
        ba_by_name = {item1.name.strip().lower(): [item1], item2.name.strip().lower(): [item2]}
        ba_by_name_clean = {clean_kpi_name(item1.name): [item1], clean_kpi_name(item2.name): [item2]}

        # Exact match
        m1 = analyzer.find_ba_match(
            "Doanh thu môi giới", 1, ba_by_grp=ba_by_grp, ba_by_name=ba_by_name, ba_by_name_clean=ba_by_name_clean
        )
        self.assertIsNotNone(m1)
        self.assertEqual(m1.stt, "1")

        # Cleaned match with filter annotations
        m2 = analyzer.find_ba_match(
            "Doanh thu môi giới (chiều lọc: chi nhánh)", 1, ba_by_grp=ba_by_grp, ba_by_name=ba_by_name, ba_by_name_clean=ba_by_name_clean
        )
        self.assertIsNotNone(m2)
        self.assertEqual(m2.stt, "1")

        # No match
        m3 = analyzer.find_ba_match(
            "Chỉ tiêu hoàn toàn lạ lẫm", 1, ba_by_grp=ba_by_grp, ba_by_name=ba_by_name, ba_by_name_clean=ba_by_name_clean
        )
        self.assertIsNone(m3)

    def test_19_datamart_progress_analyzer_hld_layer_only(self):
        """Test DatamartProgressAnalyzer when no Detail Mapping exists (evaluated_layer = 'HLD')."""
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            ba_dir = root / "BRD" / "BA"
            hld_dir = root / "Datamart" / "hld"
            ba_dir.mkdir(parents=True)
            hld_dir.mkdir(parents=True)

            (ba_dir / "BA_analyst_HLDONLY.csv").write_text(
                "STT;Dashboard/báo cáo;Tên chỉ tiêu;Mô tả;Nhóm yêu cầu;Phân loại;Đánh giá;Trạng thái mapping;Bảng nguồn;Cột nguồn;Loại dữ liệu;Điều kiện;Câu lệnh SQL;Ghi chú\n"
                "1;Dash;Chỉ tiêu HLD Only;Mô tả;Nhóm 1;Cơ sở;Dễ;Done;tbl;col;INT;;;\n",
                encoding="utf-8",
            )
            (hld_dir / "DTM_HLDONLY_HLD.md").write_text(
                "### Nhóm 1: Nhóm HLD Only\n"
                "| Mã chỉ tiêu | Tên chỉ tiêu | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |\n"
                "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |\n"
                "| K_HLDONLY_01 | Chỉ tiêu HLD Only | Số | Đếm | count(1) | | READY |\n",
                encoding="utf-8",
            )

            analyzer = DatamartProgressAnalyzer(root)
            res = analyzer.analyze_module("HLDONLY")
            self.assertEqual(res["evaluated_layer"], "HLD")
            self.assertEqual(res["ready_count"], 1)

    def test_20_datamart_progress_analyzer_real_repo_module_qlkd(self):
        """Integration test on actual repository module QLKD."""
        analyzer = DatamartProgressAnalyzer(REPO_ROOT)
        res = analyzer.analyze_module("QLKD")
        self.assertEqual(res["module"], "QLKD")
        self.assertGreater(res["total_ba_rows"], 0)
        self.assertGreater(res["ready_count"] + res["pending_count"], 0)
        self.assertIn("cross_status_matrix", res)

    def test_21_datamart_progress_analyzer_scan_all_and_show_detail(self):
        """Test scan_all_modules and generate_markdown_report with show_detail=True."""
        analyzer = DatamartProgressAnalyzer(REPO_ROOT)
        mods = analyzer.scan_all_modules()
        self.assertIsInstance(mods, list)
        self.assertIn("QLKD", mods)

        res = analyzer.analyze_module("QLKD")
        detailed_report = analyzer.generate_markdown_report(res, show_detail=True)
        self.assertIn("Báo cáo Tiến độ & Đối soát Thiết kế Datamart — Module QLKD", detailed_report)
        self.assertIn("Danh sách Chi tiết Toàn bộ Chỉ tiêu PENDING", detailed_report)

    def test_22_datamart_progress_analyzer_find_module_files_fallback(self):
        """Test find_module_files both with module_resolver and with fallback paths."""
        analyzer = DatamartProgressAnalyzer(REPO_ROOT)
        ba, hld, dm = analyzer.find_module_files("QLKD")
        self.assertIsNotNone(ba)
        self.assertIsNotNone(hld)
        self.assertIsNotNone(dm)

        # Test fallback when resolve_module_path is temporarily disabled
        import datamart_progress_analyzer as dpa
        orig_resolver = dpa.resolve_module_path
        try:
            dpa.resolve_module_path = None
            ba2, hld2, dm2 = analyzer.find_module_files("QLKD")
            self.assertIsNotNone(ba2)
            self.assertIsNotNone(hld2)
            self.assertIsNotNone(dm2)

            # Test candidate names mapping (GSĐC / GSDC, FMS / QLQ)
            ba_gsdc, _, _ = analyzer.find_module_files("GSDC")
            self.assertIsNotNone(ba_gsdc)

            ba_fms, _, _ = analyzer.find_module_files("FMS")
            self.assertIsNotNone(ba_fms)
        finally:
            dpa.resolve_module_path = orig_resolver

    def test_23_whitelist_loader_and_rule_matching(self):
        """Test loading YAML whitelist and verifying group mismatch exceptions."""
        rules = load_whitelist(REPO_ROOT)
        self.assertIsInstance(rules, list)
        self.assertGreater(len(rules), 0)

        # Test GSĐC enterprise type split (groups 21-30)
        is_wl, desc = is_group_whitelisted("GSDC", "21", 30, 30, 90, rules)
        self.assertTrue(is_wl)
        self.assertIn("3 loại hình", desc)

        # Test GSTT derived YoY metric rule
        is_wl, desc = is_group_whitelisted("GSTT", "2", 10, 15, 15, rules)
        self.assertTrue(is_wl)
        self.assertTrue("YOY" in desc.upper())

        # Test unwhitelisted group
        is_wl, desc = is_group_whitelisted("NONEXISTENT", "99", 10, 20, 20, rules)
        self.assertFalse(is_wl)
        self.assertIsNone(desc)

    def test_24_whitelist_integration_in_analyzer(self):
        """Test that analyze_module tags whitelisted groups and removes them from mismatch_groups."""
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            ba_dir = root / "BRD" / "BA"
            hld_dir = root / "Datamart" / "hld"
            lld_dir = root / "Datamart" / "lld"
            ba_dir.mkdir(parents=True)
            hld_dir.mkdir(parents=True)
            lld_dir.mkdir(parents=True)

            # GSĐC Nhóm 21: 1 BA, 1 HLD, 3 LLD (Tripled for 3 enterprise types)
            (ba_dir / "BA_analyst_GSDC.csv").write_text(
                "STT;Dashboard/báo cáo;Tên chỉ tiêu;Mô tả;Nhóm yêu cầu;Phân loại;Đánh giá;Trạng thái mapping;Bảng nguồn;Cột nguồn;Loại dữ liệu;Điều kiện;Câu lệnh SQL;Ghi chú\n"
                "21;BCTC;Chỉ tiêu BCTC;Mô tả;Nhóm 21;Cơ sở;Dễ;Done;tbl;col;INT;;;\n",
                encoding="utf-8",
            )
            (hld_dir / "DTM_GSDC_HLD.md").write_text(
                "### Nhóm 21: Báo cáo tài chính\n"
                "| Mã chỉ tiêu | Tên chỉ tiêu | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |\n"
                "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |\n"
                "| K_GSDC_01 | Chỉ tiêu BCTC | Số | Đếm | count(1) | | READY |\n",
                encoding="utf-8",
            )
            (lld_dir / "DTM_GSDC_Detail_Mapping.csv").write_text(
                "kpi_id,kpi_name,nhom,tinh_chat,column_role,logic,mart_table,mart_column,ghi_chu\n"
                "K_GSDC_01,Chỉ tiêu BCTC CTNY,Nhóm 21,READY,FACT_COLUMN,c1,fct_bctc,col_ctny,\n"
                "K_GSDC_01,Chỉ tiêu BCTC CTTG,Nhóm 21,READY,FACT_COLUMN,c2,fct_bctc,col_cttg,\n"
                "K_GSDC_01,Chỉ tiêu BCTC CTDC,Nhóm 21,READY,FACT_COLUMN,c3,fct_bctc,col_ctdc,\n",
                encoding="utf-8",
            )

            analyzer = DatamartProgressAnalyzer(root)
            res = analyzer.analyze_module("GSDC")

            self.assertIn("21", res["whitelisted_groups"])
            self.assertNotIn("21", res["mismatch_groups"])
            self.assertTrue(res["group_stats"]["21"]["whitelisted"])

            rep = analyzer.generate_markdown_report(res)
            self.assertIn("Theo Whitelist", rep)

    def test_25_simultaneous_md_and_json_export(self):
        """Test Item 14 dual export functionality (--output-dir and --json-output)."""
        with tempfile.TemporaryDirectory() as tmpdir:
            out_dir = Path(tmpdir) / "reports_out"
            json_file = Path(tmpdir) / "custom_report.json"

            # Test --output-dir simultaneous export
            code1 = main(["-m", "QLKD", "--output-dir", str(out_dir), "--root", str(REPO_ROOT)])
            self.assertIn(code1, (0, 1))
            self.assertTrue((out_dir / "QLKD_progress_report.md").exists())
            self.assertTrue((out_dir / "QLKD_progress_report.json").exists())

            # Test --json-output dedicated file
            code2 = main(["-m", "QLKD", "--json-output", str(json_file), "--root", str(REPO_ROOT)])
            self.assertIn(code2, (0, 1))
            self.assertTrue(json_file.exists())
            import json as json_lib
            content = json_lib.loads(json_file.read_text(encoding="utf-8"))
            self.assertEqual(content[0]["module"], "QLKD")

    def test_26_exit_code_standardization(self):
        """Test Item 14 exit code standardization: 0 (OK), 1 (Warning), 2 (Critical/Error)."""
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            ba_dir = root / "BRD" / "BA"
            hld_dir = root / "Datamart" / "hld"
            lld_dir = root / "Datamart" / "lld"
            ba_dir.mkdir(parents=True)
            hld_dir.mkdir(parents=True)
            lld_dir.mkdir(parents=True)

            # Test Exit Code 2: Missing module
            code_missing = main(["-m", "NONEXISTENT", "--root", str(root)])
            self.assertEqual(code_missing, 2)

            # Test Exit Code 2: Deleted indicator violation
            (ba_dir / "BA_analyst_DELMOD.csv").write_text(
                "STT;Dashboard/báo cáo;Tên chỉ tiêu;Mô tả;Nhóm yêu cầu;Phân loại;Đánh giá;Trạng thái mapping;Bảng nguồn;Cột nguồn;Loại dữ liệu;Điều kiện;Câu lệnh SQL;Ghi chú\n"
                "1;Dash;Chỉ tiêu Xóa;Mô tả;Nhóm 1;Cơ sở;Dễ;Delete;tbl;col;INT;;;\n",
                encoding="utf-8",
            )
            (hld_dir / "DTM_DELMOD_HLD.md").write_text(
                "### Nhóm 1: Nhóm 1\n"
                "| Mã chỉ tiêu | Tên chỉ tiêu | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |\n"
                "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |\n"
                "| K_DELMOD_01 | Chỉ tiêu Xóa | Số | Đếm | count(1) | | READY |\n",
                encoding="utf-8",
            )
            (lld_dir / "DTM_DELMOD_Detail_Mapping.csv").write_text(
                "kpi_id,kpi_name,nhom,tinh_chat,column_role,logic,mart_table,mart_column,ghi_chu\n"
                "K_DELMOD_01,Chỉ tiêu Xóa,Nhóm 1,READY,FACT_COLUMN,c1,fct_t,col1,\n",
                encoding="utf-8",
            )
            code_del_viol = main(["-m", "DELMOD", "--root", str(root)])
            self.assertEqual(code_del_viol, 2)

            # Test Exit Code 0: Fully matched clean module
            (ba_dir / "BA_analyst_CLEAN.csv").write_text(
                "STT;Dashboard/báo cáo;Tên chỉ tiêu;Mô tả;Nhóm yêu cầu;Phân loại;Đánh giá;Trạng thái mapping;Bảng nguồn;Cột nguồn;Loại dữ liệu;Điều kiện;Câu lệnh SQL;Ghi chú\n"
                "1;Dash;Chỉ tiêu Sạch;Mô tả;Nhóm 1;Cơ sở;Dễ;Done;tbl;col;INT;;;\n",
                encoding="utf-8",
            )
            (hld_dir / "DTM_CLEAN_HLD.md").write_text(
                "### Nhóm 1: Nhóm 1\n"
                "| Mã chỉ tiêu | Tên chỉ tiêu | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |\n"
                "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |\n"
                "| K_CLEAN_01 | Chỉ tiêu Sạch | Số | Đếm | count(1) | | READY |\n",
                encoding="utf-8",
            )
            (lld_dir / "DTM_CLEAN_Detail_Mapping.csv").write_text(
                "kpi_id,kpi_name,nhom,tinh_chat,column_role,logic,mart_table,mart_column,ghi_chu\n"
                "K_CLEAN_01,Chỉ tiêu Sạch,Nhóm 1,READY,FACT_COLUMN,c1,fct_clean,col1,\n",
                encoding="utf-8",
            )
            code_clean = main(["-m", "CLEAN", "--root", str(root)])
            self.assertEqual(code_clean, 0)

    def test_27_mixed_carriage_return_newlines_resilience(self):
        """Test BAParser and DetailMappingParser resilience against mixed \\r\\n and \\r newlines."""
        raw_csv = (
            "STT;Dashboard/báo cáo;Tên chỉ tiêu;Mô tả;Nhóm yêu cầu;Phân loại;Đánh giá;Trạng thái mapping;Bảng nguồn;Cột nguồn;Loại dữ liệu;Điều kiện;Câu lệnh SQL;Ghi chú\r\n"
            "1;Dash;Chỉ tiêu 1;Mô tả;Nhóm 1;Chỉ tiêu cơ sở;Dễ;Done;tbl;col;INT;cond;\"SELECT 1\rWHERE a=1\r\nAND b=2\";Note 1\r"
            "2;Dash;Chỉ tiêu 2;Mô tả;Nhóm 1;Chỉ tiêu cơ sở;Dễ;Done;tbl;col;INT;cond;SELECT 2;Note 2\n"
        )
        delim, hdr_idx, header, rows = BAParser.detect_delimiter_and_header(raw_csv)
        self.assertEqual(delim, ";")
        self.assertEqual(len(rows), 2)
        self.assertIn("SELECT 1", rows[0][12])

        with tempfile.TemporaryDirectory() as tmpdir:
            dm_file = Path(tmpdir) / "test_dm.csv"
            dm_file.write_bytes(
                b"kpi_id,kpi_name,nhom,tinh_chat,column_role,logic,mart_table,mart_column,ghi_chu\r\n"
                b"K_01,KPI 1,Nh\xc3\xb3m 1,READY,FACT_COLUMN,\"col1\r\n+\rcol2\",fct_t,col1,note\r"
                b"K_02,KPI 2,Nh\xc3\xb3m 1,READY,FACT_COLUMN,col3,fct_t,col2,note\n"
            )
            items = DetailMappingParser.parse_file(dm_file)
            self.assertEqual(len(items), 2)
            self.assertEqual(items[0].kpi_id, "K_01")

    def test_28_whitelist_fallback_rules_coverage(self):
        """Verify that DEFAULT_FALLBACK_RULES covers all 5 required modules (GSĐC, GSTT, NHNCK, QLKD, TKNB)."""
        from datamart_common.whitelist import DEFAULT_FALLBACK_RULES, is_group_whitelisted

        rule_mods = {r["module"] for r in DEFAULT_FALLBACK_RULES}
        self.assertTrue({"GSĐC", "GSTT", "NHNCK", "QLKD", "TKNB"}.issubset(rule_mods))

        # GSĐC: groups 21-30, 3x multiplication
        ok, reason = is_group_whitelisted("GSĐC", "21", 30, 30, 90, DEFAULT_FALLBACK_RULES)
        self.assertTrue(ok)
        self.assertIn("Nhân bản", reason)

        # GSTT: groups 1-4, YoY
        ok, reason = is_group_whitelisted("GSTT", "1", 21, 26, 30, DEFAULT_FALLBACK_RULES)
        self.assertTrue(ok)
        self.assertIn("_YOY", reason)

        # NHNCK: groups 1, 2, 7, physical measure split
        ok, reason = is_group_whitelisted("NHNCK", "1", 10, 18, 45, DEFAULT_FALLBACK_RULES)
        self.assertTrue(ok)
        self.assertIn("measure", reason.lower())

        # QLKD: groups 1, 19, banner
        ok, reason = is_group_whitelisted("QLKD", "1", 13, 13, 20, DEFAULT_FALLBACK_RULES)
        self.assertTrue(ok)
        self.assertIn("banner", reason.lower())

        # TKNB: groups 1, 2, 3, internal statistics split
        ok, reason = is_group_whitelisted("TKNB", "1", 77, 108, 110, DEFAULT_FALLBACK_RULES)
        self.assertTrue(ok)
        self.assertIn("nội bộ", reason.lower())

    def test_29_analyzer_root_dir_string_and_default_detection(self):
        """Verify that DatamartProgressAnalyzer accepts str root_dir, None default, and load_whitelist accepts str path."""
        # 1. str path input
        analyzer_str = DatamartProgressAnalyzer(str(REPO_ROOT))
        self.assertEqual(analyzer_str.root_dir, REPO_ROOT)
        self.assertTrue(analyzer_str.ba_dir.is_dir())

        # 2. Relative str path '.'
        analyzer_rel = DatamartProgressAnalyzer(".")
        self.assertTrue(analyzer_rel.root_dir.is_dir())
        self.assertTrue(analyzer_rel.ba_dir.is_dir())

        # 3. None default auto-detection
        analyzer_default = DatamartProgressAnalyzer()
        self.assertTrue(analyzer_default.root_dir.is_dir())
        self.assertTrue(analyzer_default.ba_dir.is_dir())

        # 4. load_whitelist with str path
        rules = load_whitelist(str(REPO_ROOT))
        self.assertIsInstance(rules, list)
        self.assertGreaterEqual(len(rules), 5)

        rules_rel = load_whitelist(".")
        self.assertIsInstance(rules_rel, list)
        self.assertGreaterEqual(len(rules_rel), 5)

    def test_30_is_group_whitelisted_with_text_prefix_and_math_env(self):
        """Verify that is_group_whitelisted recognizes text prefixes ('Nhóm 21', 'Group 1') and evaluates math functions."""
        # Text prefix 'Nhóm 21' with GSĐC group range
        ok, reason = is_group_whitelisted("GSĐC", "Nhóm 21", 30, 30, 90)
        self.assertTrue(ok)
        self.assertIn("Nhân bản", reason)

        # Text prefix 'Nhóm 1' with GSTT groups list
        ok, reason = is_group_whitelisted("GSTT", "Nhóm 1", 21, 26, 30)
        self.assertTrue(ok)
        self.assertIn("_YOY", reason)

        # Math functions in condition: round, int, float, min, max, abs
        custom_rule = [{
            "rule_id": "TEST-MATH-01",
            "module": "TEST",
            "groups": ["1"],
            "condition": "round(float(dm_rows) / int(hld_kpis), 1) == 2.5 and min(dm_rows, 50) == 50 and max(ba_done_doing, 10) == 20",
            "status": "APPROVED",
        }]
        ok, _ = is_group_whitelisted("TEST", "1", ba_cnt=20, hld_cnt=20, dm_cnt=50, rules=custom_rule)
        self.assertTrue(ok)


if __name__ == "__main__":
    unittest.main()
