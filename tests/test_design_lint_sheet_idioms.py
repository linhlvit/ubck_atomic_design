# -*- coding: utf-8 -*-
"""Gate 8 D19–D22 (2026-10-28) — 4 loại lỗi mà Gate 0–10 PASS nhưng user phải tự phát hiện:
D19 KPI lọc cell_id không lọc sheet_code (QLKD K_QLKD_12/13/102/107, N31),
D20/D21 idiom ClickHouse sai (LOWER + chữ có dấu; so khớp chính xác nhãn cột — QLQ BCTaiSan chỉ lấy 18/131 quỹ),
D22 ghi chú cũ 'chưa lọc được theo mã sheet' còn sót cạnh thiết kế mới."""
from __future__ import annotations

import sys
import unittest
from pathlib import Path

_S = Path(__file__).resolve().parents[1] / ".claude" / "skills" / "datamart-review" / "scripts"
sys.path.insert(0, str(_S))

import check_design_lint as L  # noqa: E402

FACT = "fct_securities_company_financial_structure_snpst"
# Logic K_QLKD_12 TRƯỚC khi sửa 2026-10-28 (thiếu sheet_code)
K12_BEFORE = (f"SUM({FACT}.indicator_val_amt) WHERE {FACT}.rpt_code = 'BCTHHD_CTCK' AND report_indicator_dim.cell_id = 'TS046' "
              f"AND {FACT}.rpt_period_tp_code = 'QUY' AND {FACT}.submission_status_code IN ('1','2')")
K12_AFTER = K12_BEFORE.replace("cell_id = 'TS046' AND", "cell_id = 'TS046' AND report_indicator_dim.sheet_code = 'II.4' AND")


class D19SheetCode(unittest.TestCase):
    def codes(self, logic, has=True):
        return [c for _, c, _ in L.sheet_code_issues({"K_QLKD_12": [logic]}, has)]

    def test_missing_sheet_code_is_error(self):
        out = L.sheet_code_issues({"K_QLKD_12": [K12_BEFORE]}, True)
        self.assertEqual([(lv, c) for lv, c, _ in out], [("ERROR", "L3-CELL-ID-NO-SHEET-CODE")])

    def test_with_sheet_code_ok(self):
        self.assertEqual(self.codes(K12_AFTER), [])

    def test_module_without_sheet_code_column_not_checked(self):
        self.assertEqual(self.codes(K12_BEFORE, has=False), [])

    def test_sheet_code_on_any_row_of_kpi_counts(self):
        # N31: SLICER chỉ có cell_id, FILTER cùng kpi_id mang sheet_code → KPI đạt
        out = L.sheet_code_issues({"K_QLKD_4283": ["x.item_val WHERE x.cell_id = 'KT001'", "x.rpt_code = 'BCTHHD_CTCK' AND x.sheet_code = 'II.2'"]}, True)
        self.assertEqual(out, [])

    def test_in_list_form_detected(self):
        self.assertEqual(self.codes("d.cell_id IN ('TS359','TS223') AND d.rpt_code = 'BCTCHN'"), ["L3-CELL-ID-NO-SHEET-CODE"])

    def test_kpi_without_cell_id_ignored(self):
        self.assertEqual(self.codes("SUM(x.val) WHERE x.rpt_code = 'BCTHHD_CTCK'"), [])


class D20D21ClickHouseIdioms(unittest.TestCase):
    CH = "toLastDayOfMonth(:selected_dt)"

    def codes(self, logics):
        return [c for _, c, _ in L.ch_idiom_issues(logics)]

    def test_lower_nonascii_flagged_in_clickhouse_module(self):
        lg = f"SUM(x) WHERE LOWER(d.fmr_nm) LIKE '%hoạt động%' AND rpt_period_end_cdr_dt = {self.CH}"
        self.assertEqual(self.codes({"K_QLQ_3": [lg]}), ["L3-CH-LOWER-NONASCII"])

    def test_lowerutf8_ok(self):
        lg = f"WHERE lowerUTF8(fmr_nm) LIKE '%hoạt động%' AND d = {self.CH}"
        self.assertEqual(self.codes({"K_QLQ_46": [lg]}), [])

    def test_lower_ascii_pattern_ok(self):
        lg = f"WHERE LOWER(code) LIKE '%abc%' AND d = {self.CH}"
        self.assertEqual(self.codes({"K_X_1": [lg]}), [])

    def test_exact_label_flagged(self):
        lg = f"WHERE column_label_nm = 'Kỳ báo cáo' AND d = {self.CH}"
        self.assertEqual(self.codes({"K_QLQ_3": [lg]}), ["L3-CH-LABEL-EXACT"])

    def test_prefix_label_ok(self):
        lg = f"WHERE trimBoth(splitByString(' >> ', ifNull(column_label_nm, ''))[1]) = 'Kỳ báo cáo' AND d = {self.CH}"
        self.assertEqual(self.codes({"K_QLQ_46": [lg]}), [])

    def test_oracle_style_module_not_checked(self):
        # không có dấu hiệu ClickHouse trong cả module → LOWER của Oracle xử lý Unicode đúng
        lg = "WHERE LOWER(rt.ITEM_NAME) LIKE '%hoạt động%' AND LAST_DAY(x) <= y"
        self.assertEqual(self.codes({"K_Y_1": [lg]}), [])

    def test_clickhouse_marker_elsewhere_in_module_activates_rule(self):
        out = self.codes({"K_QLQ_1": [f"x = {self.CH}"], "K_QLQ_2": ["WHERE LOWER(fmr_nm) LIKE '%hoạt động%'"]})
        self.assertEqual(out, ["L3-CH-LOWER-NONASCII"])


class D22StaleSheetClaim(unittest.TestCase):
    def test_stale_claim_flagged(self):
        h = L.stale_sheet_claims([("DM K_QLKD_107", "Chưa lọc được theo mã sheet (06620/06608): sheet_id là id gốc eForm")])
        self.assertEqual(len(h), 1)

    def test_mart_only_has_sheet_id_flagged(self):
        self.assertEqual(len(L.stale_sheet_claims([("HLD dòng 1693", "Mart chỉ có `sheet_id` (O_QLKD_34/42)")])), 1)

    def test_history_label_exempt(self):
        t = "[SỬA 2026-10-28] trước đây ghi 'chưa lọc được theo mã sheet' vì Mart chỉ có sheet_id — nay đã có sheet_code"
        self.assertEqual(L.stale_sheet_claims([("DM K_1", t)]), [])

    def test_closed_label_exempt(self):
        self.assertEqual(L.stale_sheet_claims([("DM K_1", "(1) [ĐÃ ĐÓNG phần sheet] chưa lọc được mã sheet II.4")]), [])

    def test_unrelated_text_ignored(self):
        self.assertEqual(L.stale_sheet_claims([("DM K_1", "chưa lọc được theo kỳ; sheet II.4 đã lọc bằng sheet_code")]), [])


if __name__ == "__main__":
    unittest.main()
