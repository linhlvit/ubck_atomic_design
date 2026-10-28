# -*- coding: utf-8 -*-
"""dm_edit.py — sửa Detail Mapping theo KPI/role có kiểm soát (thay các script tạm lặp lại ở phiên 2026-10-28)."""
from __future__ import annotations

import sys
import unittest
from pathlib import Path

_S = Path(__file__).resolve().parents[1] / ".claude" / "skills" / "datamart-review" / "scripts"
sys.path.insert(0, str(_S))

import dm_edit as E  # noqa: E402

HDR = ["kpi_id", "nhom", "column_role", "logic", "ghi_chu"]


def rows():
    return [
        ["K_A_1", "Nhóm 1", "MEASURE", "SUM(x) WHERE cell_id = 'TS046' AND rpt_period_tp_code = 'QUY'", "ghi chú 1"],
        ["K_A_1", "Nhóm 1", "FILTER", "rpt_code = 'BCTHHD_CTCK'", ""],
        ["K_A_2", "Nhóm 1", "MEASURE", "SUM(y) WHERE LOWER(d.fmr_nm) LIKE '%hoạt động%'", "ghi chú 2"],
    ]


class SubstituteOnce(unittest.TestCase):
    def test_sub_changes_only_selected_rows(self):
        b = rows()
        ch, err = E.edit_rows(HDR, b, kpis=["K_A_1"], roles=["MEASURE"], field="logic",
                              subs=[("cell_id = 'TS046' AND ", "cell_id = 'TS046' AND sheet_code = 'II.4' AND ")])
        self.assertEqual((ch, err), (["K_A_1/MEASURE"], []))
        self.assertIn("sheet_code = 'II.4'", b[0][3])
        self.assertEqual(b[1], rows()[1])
        self.assertEqual(b[2], rows()[2])

    def test_sub_not_found_aborts_without_writing(self):
        b = rows()
        ch, err = E.edit_rows(HDR, b, kpis=["K_A_1"], roles=["MEASURE"], field="logic", subs=[("KHÔNG CÓ", "x")])
        self.assertEqual(ch, [])
        self.assertEqual(len(err), 1)
        self.assertEqual(b, rows())

    def test_sub_ambiguous_aborts(self):
        b = rows()
        b[0][3] = "a a"
        ch, err = E.edit_rows(HDR, b, kpis=["K_A_1"], roles=["MEASURE"], field="logic", subs=[("a", "b")])
        self.assertTrue(err and not ch)
        ch2, err2 = E.edit_rows(HDR, b, kpis=["K_A_1"], roles=["MEASURE"], field="logic", subs=[("a", "b")], any_count=True)
        self.assertEqual((ch2, err2), (["K_A_1/MEASURE"], []))

    def test_error_in_one_row_leaves_all_rows_untouched(self):
        b = rows()
        ch, err = E.edit_rows(HDR, b, kpis=None, roles=["MEASURE"], field="logic", subs=[("cell_id = 'TS046'", "cell_id = 'TS046' AND z")])
        self.assertTrue(err)  # K_A_2 không có chuỗi này
        self.assertEqual(b, rows())


class RegexAndAppend(unittest.TestCase):
    def test_regex_all_selected_rows(self):
        b = rows()
        ch, err = E.edit_rows(HDR, b, kpis=["K_A_2"], roles=None, field="logic", regexes=[(r"LOWER\((\w+\.fmr_nm)\)", r"lowerUTF8(\1)")])
        self.assertEqual(err, [])
        self.assertIn("lowerUTF8(d.fmr_nm)", b[2][3])

    def test_regex_no_match_is_error(self):
        ch, err = E.edit_rows(HDR, rows(), kpis=["K_A_1"], roles=["MEASURE"], field="logic", regexes=[(r"lowerUTF8", "x")])
        self.assertTrue(err)

    def test_append_is_idempotent(self):
        b = rows()
        E.edit_rows(HDR, b, kpis=["K_A_1"], roles=["MEASURE"], field="ghi_chu", appends=["[SỬA 2026-10-28] thêm"], sep=" | ")
        first = b[0][4]
        self.assertTrue(first.endswith(" | [SỬA 2026-10-28] thêm"))
        ch, err = E.edit_rows(HDR, b, kpis=["K_A_1"], roles=["MEASURE"], field="ghi_chu", appends=["[SỬA 2026-10-28] thêm"], sep=" | ", allow_unchanged=True)
        self.assertEqual(b[0][4], first)
        self.assertEqual(ch, [])

    def test_append_to_empty_field(self):
        b = rows()
        E.edit_rows(HDR, b, kpis=["K_A_1"], roles=["FILTER"], field="ghi_chu", appends=["mới"])
        self.assertEqual(b[1][4], "mới")

    def test_no_selection_is_error(self):
        ch, err = E.edit_rows(HDR, rows(), kpis=["K_KHONG_CO"], roles=None, field="logic", appends=["x"])
        self.assertTrue(err)


if __name__ == "__main__":
    unittest.main()
