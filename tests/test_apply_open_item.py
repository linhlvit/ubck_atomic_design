# -*- coding: utf-8 -*-
"""apply_open_item.py — đường ghi chính thức cho bảng Open Items (Section 5) HLD; trước đây phải sửa tay / script ad-hoc."""
from __future__ import annotations

import sys
import unittest
from pathlib import Path

_S = Path(__file__).resolve().parents[1] / ".claude" / "skills" / "datamart-review" / "scripts"
sys.path.insert(0, str(_S))

import apply_open_item as A  # noqa: E402

LINES = [
    "## 5. Open Items",
    "| ID | Vấn đề | KPI | Trạng thái |",
    "|---|---|---|---|",
    "| O_QLKD_48 | (3) mã sheet chưa lọc được (AQ-03). | K_1 | Open |",
    "| O_QLKD_61 | (a) chưa lọc được mã sheet II.2; (b) mã sheet chưa lọc được khác | K_2 | Open |",
    "",
]


class ReplaceRow(unittest.TestCase):
    def test_replaces_exactly_one_line(self):
        out, at = A.plan_replace(LINES, "O_QLKD_48", "chưa lọc được (AQ-03)", "[ĐÃ ĐÓNG] đã lọc")
        self.assertEqual(at, 3)
        self.assertIn("[ĐÃ ĐÓNG] đã lọc", out[3])
        self.assertEqual(out[:3] + out[4:], LINES[:3] + LINES[4:])

    def test_old_must_be_unique_in_row(self):
        with self.assertRaises(ValueError):
            A.plan_replace(LINES, "O_QLKD_61", "chưa lọc được", "x")

    def test_old_ambiguous_across_rows_without_id(self):
        with self.assertRaises(ValueError):
            A.plan_replace(LINES, None, "chưa lọc được", "x")

    def test_pipe_count_must_match(self):
        with self.assertRaises(ValueError):
            A.plan_replace(LINES, "O_QLKD_48", "(AQ-03)", "(AQ-03) | thêm ô")

    def test_not_found(self):
        with self.assertRaises(ValueError):
            A.plan_replace(LINES, "O_QLKD_48", "KHÔNG CÓ", "x")

    def test_only_open_item_rows_touched(self):
        # cùng đoạn văn bản ở dòng ngoài bảng Open Items thì không đụng
        lines = LINES + ["Đoạn mô tả: mã sheet chưa lọc được (AQ-03)."]
        out, at = A.plan_replace(lines, "O_QLKD_48", "chưa lọc được (AQ-03)", "đã lọc")
        self.assertEqual(out[-1], lines[-1])


class AddRow(unittest.TestCase):
    ROW = "| O_QLKD_62 | mới | K_3 | Open |"

    def test_append_after_last_open_item(self):
        out, at = A.plan_add_row(LINES, self.ROW, None)
        self.assertEqual(at, 5)
        self.assertEqual(out[5], self.ROW)

    def test_insert_after_given_id(self):
        out, at = A.plan_add_row(LINES, self.ROW, "O_QLKD_48")
        self.assertEqual(at, 4)

    def test_duplicate_id_rejected(self):
        with self.assertRaises(ValueError):
            A.plan_add_row(LINES, "| O_QLKD_48 | x | y | z |", None)

    def test_bad_row_rejected(self):
        with self.assertRaises(ValueError):
            A.plan_add_row(LINES, "O_QLKD_62 không có dấu gạch", None)


if __name__ == "__main__":
    unittest.main()
