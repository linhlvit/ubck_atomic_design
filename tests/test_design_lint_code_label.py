# -*- coding: utf-8 -*-
"""Gate 8 D23–D24 (2026-11-07, luật A36) — TT Nhóm 15: cùng một khái niệm 'nhãn của cột mã' xử lý ở hai tầng.
D23: cột `*_code` bị nhét nhãn trong etl_logic (`life_cycle_status_code` lưu 'Mới tiếp nhận…'; `form_tp_code` trộn mã với 'Không xác định').
D24: cùng cột mã — K_TT_18/K_TT_53 ánh xạ nhãn, K_TT_37 hiển thị mã thô PERIODIC/UNSCHEDULED."""
from __future__ import annotations

import sys
import unittest
from pathlib import Path

_ROOT = Path(__file__).resolve().parents[1]
_S = _ROOT / ".claude" / "skills" / "datamart-review" / "scripts"
sys.path.insert(0, str(_S))

import check_design_lint as L  # noqa: E402

J = ("INNER JOIN penalty_decision ON penalty_decision.pd_id = pd_subject.pd_id "
     "INNER JOIN violation_case ON violation_case.violation_case_id = penalty_decision.violation_case_id")
STATUS_BEFORE = (J + " → CASE WHEN violation_case.life_cycle_status_code = 'NEW' THEN 'Mới tiếp nhận' "
                 "WHEN violation_case.life_cycle_status_code = 'PROCESSING' THEN 'Đang xử lý' ELSE 'Không xác định' END")
STATUS_AFTER = J + " → violation_case.life_cycle_status_code"
FORM_BEFORE = ("→ CASE WHEN violation_case.inspection_team_id IS NOT NULL THEN inspection_team.form_tp_code "
               "WHEN violation_case.examination_team_id IS NOT NULL THEN examination_team.form_tp_code ELSE 'Không xác định' END")
FORM_AFTER = FORM_BEFORE.replace("ELSE 'Không xác định' END", "ELSE NULL END")
CASE_FORM = ("CASE WHEN opr_inspection_case_list.form_tp_code = 'UNSCHEDULED' THEN 'Đột xuất' "
             "WHEN opr_inspection_case_list.form_tp_code = 'PERIODIC' THEN 'Định kỳ' ELSE 'Không xác định' END")


class D23CodeColumnHasLabel(unittest.TestCase):
    def codes(self, col, etl):
        return [(lv, c) for lv, c, _ in L.code_column_label_issues([("x.csv", col, etl)])]

    def test_status_labels_in_code_column_is_error(self):
        self.assertEqual(self.codes("life_cycle_status_code", STATUS_BEFORE), [("ERROR", "L2-CODE-COL-HAS-LABEL")])

    def test_mixed_code_and_label_literal_is_error(self):
        self.assertEqual(self.codes("form_tp_code", FORM_BEFORE), [("ERROR", "L2-CODE-COL-HAS-LABEL")])

    def test_raw_code_and_else_null_ok(self):
        self.assertEqual(self.codes("life_cycle_status_code", STATUS_AFTER), [])
        self.assertEqual(self.codes("form_tp_code", FORM_AFTER), [])

    def test_name_column_with_labels_is_valid(self):
        # QLKD/GSTT/NHNCK: cột `*_nm` lưu nhãn trong ETL là mẫu hợp lệ — D23 chỉ áp cho `*_code`
        self.assertEqual(self.codes("role_nm", "CASE WHEN x.t = 'A' THEN 'Cổ đông lớn' ELSE 'Khác' END"), [])
        self.assertEqual(self.codes("practice_status_nm", "CASE WHEN x.s = '2' THEN 'Thu hồi có cấp lại' END"), [])

    def test_ascii_code_values_in_code_column_ok(self):
        self.assertEqual(self.codes("status_code", "CASE WHEN x.start_dt > :etl_date THEN 'NOT_STARTED' ELSE 'IN_PROGRESS' END"), [])

    def test_message_mentions_rule(self):
        msg = L.code_column_label_issues([("x.csv", "form_tp_code", FORM_BEFORE)])[0][2]
        self.assertIn("A36", msg)
        self.assertIn("ELSE NULL", msg)


class D24CodeLabelInconsistent(unittest.TestCase):
    def issues(self, rows):
        return L.code_label_inconsistency(rows)

    def test_tt_k37_raw_vs_k18_k53_mapped_warns(self):
        out = self.issues([
            ("K_TT_18", "SLICER", CASE_FORM),
            ("K_TT_53", "SLICER", CASE_FORM.replace("opr_inspection_case_list", "opr_penalty_decision_list")),
            ("K_TT_37", "SLICER", "opr_examination_case_list.form_tp_code"),
        ])
        self.assertEqual([(lv, c) for lv, c, _ in out], [("WARNING", "L3-CODE-LABEL-INCONSISTENT")])
        self.assertIn("K_TT_37", out[0][2])
        self.assertIn("K_TT_18", out[0][2])

    def test_all_mapped_ok(self):
        self.assertEqual(self.issues([("K_TT_18", "SLICER", CASE_FORM), ("K_TT_37", "SLICER", CASE_FORM)]), [])

    def test_raw_only_ok(self):
        self.assertEqual(self.issues([("K_TT_37", "SLICER", "opr_examination_case_list.form_tp_code")]), [])

    def test_raw_as_filter_not_counted(self):
        self.assertEqual(self.issues([("K_TT_18", "SLICER", CASE_FORM), ("K_X", "FILTER", "t.form_tp_code")]), [])

    def test_bracket_note_stripped_and_ascii_label_not_counted(self):
        self.assertEqual(self.issues([("K_A", "SLICER", "CASE WHEN t.form_tp_code = 'A' THEN 'Periodic' END"), ("K_B", "SLICER", "t.form_tp_code")]), [])
        self.assertEqual(self.issues([("K_A", "SLICER", f"[ghi chú {CASE_FORM}] t.other_code"), ("K_B", "SLICER", "t.form_tp_code")]), [])


STATUS_DERIVED_ETL = ("CASE WHEN COALESCE(examination_team.start_dt, examination_team.examination_period_from_dt) IS NOT NULL AND COALESCE(examination_team.end_dt, examination_team.examination_period_to_dt) IS NULL THEN 'IN_PROGRESS' "
                      "WHEN COALESCE(examination_team.end_dt, examination_team.examination_period_to_dt) <= :etl_date THEN 'COMPLETED' "
                      "WHEN COALESCE(examination_team.start_dt, examination_team.examination_period_from_dt) IS NULL THEN 'NOT_STARTED' END")
STATUS_MAP = ("CASE WHEN opr_examination_case_list.status_code = 'NOT_STARTED' THEN 'Chưa thực hiện' "
              "WHEN opr_examination_case_list.status_code = 'IN_PROGRESS' THEN 'Đang thực hiện' WHEN opr_examination_case_list.status_code = 'COMPLETED' THEN 'Đã hoàn thành' END")


class D25DerivedCodeShownRaw(unittest.TestCase):
    """TT K_TT_19/K_TT_38: `status_code` ETL tự sinh NOT_STARTED/IN_PROGRESS/COMPLETED, Detail Mapping hiển thị thô trong khi SQL BA xuất nhãn."""
    LLD = [("opr_examination_case_list", "status_code", STATUS_DERIVED_ETL),
           ("opr_examination_case_list", "form_tp_code", "→ examination_team.form_tp_code")]

    def test_derived_columns_detected(self):
        d = L.derived_code_columns(self.LLD)
        self.assertEqual(list(d), [("opr_examination_case_list", "status_code")])
        self.assertEqual(d[("opr_examination_case_list", "status_code")], ["COMPLETED", "IN_PROGRESS", "NOT_STARTED"])

    def test_raw_display_warns(self):
        d = L.derived_code_columns(self.LLD)
        out = L.derived_code_shown_raw(d, [("K_TT_38", "SLICER", "opr_examination_case_list.status_code")])
        self.assertEqual([(lv, c) for lv, c, _ in out], [("WARNING", "L3-ETL-CODE-SHOWN-RAW")])
        self.assertIn("K_TT_38", out[0][2])

    def test_mapped_display_ok(self):
        d = L.derived_code_columns(self.LLD)
        self.assertEqual(L.derived_code_shown_raw(d, [("K_TT_38", "SLICER", STATUS_MAP)]), [])

    def test_filter_role_and_source_code_column_not_counted(self):
        d = L.derived_code_columns(self.LLD)
        self.assertEqual(L.derived_code_shown_raw(d, [("K_X", "FILTER", "opr_examination_case_list.status_code")]), [])
        # form_tp_code là mã nguồn (không do ETL tự sinh) — chuyện của D24, không phải D25
        self.assertEqual(L.derived_code_shown_raw(d, [("K_TT_37", "SLICER", "opr_examination_case_list.form_tp_code")]), [])

    def test_code_name_pair_in_same_kpi_is_valid(self):
        # QLKD K_QLKD_1: cùng KPI có `company_status_code` (lọc) + `company_status_nm` (hiển thị nhãn) — mẫu Code + Name hợp lệ
        etl = "CASE WHEN x.item_code = 'B' THEN 'REVOKED' WHEN x.item_code = 'A' THEN 'ACTIVE' END"
        d = L.derived_code_columns([("securities_company_dim", "company_status_code", etl)])
        rows = [("K_QLKD_1", "SLICER", "securities_company_dim.company_status_code"), ("K_QLKD_1", "SLICER", "securities_company_dim.company_status_nm")]
        self.assertEqual(L.derived_code_shown_raw(d, rows), [])
        # KPI khác chỉ hiển thị mã thô thì vẫn bị bắt
        self.assertEqual(len(L.derived_code_shown_raw(d, rows + [("K_QLKD_9", "SLICER", "securities_company_dim.company_status_code")])), 1)

    def test_single_literal_not_derived(self):
        self.assertEqual(L.derived_code_columns([("t", "x_code", "CASE WHEN a = 1 THEN 'ONLY_ONE' END")]), {})


class RepoInvariant(unittest.TestCase):
    def test_no_code_column_holds_label_anywhere(self):
        """Nợ D23 = 0 trên toàn repo (25 cột nhúng nhãn đều là `*_nm`/`*_text`): thêm vi phạm mới là ERROR, không có baseline."""
        bad = []
        for m in L.get_available_modules(_ROOT):
            bad += [(m, msg[:140]) for lv, c, msg in L.check_code_labels(_ROOT, m) if c == "L2-CODE-COL-HAS-LABEL"]
        self.assertEqual(bad, [])


if __name__ == "__main__":
    unittest.main()
