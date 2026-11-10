"""D26 [L3-DM-LITERAL-NOT-IN-BA] — literal điều kiện trong `logic` Detail Mapping phải có xuất xứ BA/Atomic (luật A37).
Tái hiện sự cố QLKD Nhóm 5/6/7/36 2026-11-10: BA lọc `ALERT_INDICATOR.ID IN (450, 451)` nhưng Detail Mapping lọc `indicator_code IN ('DUY_TRI_DKCP_GPKD')`.
"""
from __future__ import annotations

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / ".claude" / "skills" / "datamart-review" / "scripts"))

import check_design_lint as L  # noqa: E402

BA_N5 = """
-- Biểu đồ Duy trì điều kiện cấp phép - Giấy phép hoạt động
WITH param AS (SELECT ai.ID FROM SSC_SCMS_MIG.ALERT_INDICATOR ai WHERE TRIM(ai.ID) IN (450, 451)),
ky AS (SELECT DISTINCT av.ALERT_YEAR FROM SC_FIRM_ALERT_VIOLATION av WHERE av.ALERT_YEAR IS NOT NULL AND av.ENTITY_TYPE = 'CTCK'),
dem AS (SELECT SUM(CASE WHEN av.SEVERITY_LEVEL_ALT = 2 THEN 1 ELSE 0 END) so_vi_pham, SUM(CASE WHEN av.SEVERITY_LEVEL_ALT = 1 THEN 1 ELSE 0 END) so_canh_bao FROM SC_FIRM_ALERT_VIOLATION av)
SELECT CASE WHEN so_vi_pham > 0 THEN 'Không duy trì' WHEN so_canh_bao > 0 THEN 'Gần đến giới hạn' ELSE 'Đang duy trì tốt' END xep_loai FROM dem WHERE NVL(sfi.PROVISIONAL, 0) = 0
""".lower()
ATOMIC = "sc_alert_violation.alert_entity_tp_code\nopr.src_stm_code where opr.src_stm_code = 'SCMS_SC_FIRM_BRANCH'\nou_tp_code = 'BRANCH'".lower()

OLD_LOGIC = ("WITH ky AS (SELECT DISTINCT f.alert_year FROM fct f WHERE f.alert_entity_tp_code = 'CTCK' AND f.alert_year IS NOT NULL), "
             "xep_hang AS (SELECT multiIf(countIf(f.severity_level_alt_code = '2') > 0, 'Không duy trì', countIf(f.severity_level_alt_code = '1') > 0, 'Gần đến giới hạn', 'Đang duy trì tốt') AS xep_loai "
             "FROM ky CROSS JOIN securities_company_dim LEFT JOIN fct f ON f.indicator_code IN ('DUY_TRI_DKCP_GPKD') WHERE ifNull(securities_company_dim.provisional_ind, 0) = 0) "
             "SELECT COUNT(DISTINCT x.securities_company_dim_id) FROM xep_hang x WHERE x.xep_loai = 'Đang duy trì tốt'")
NEW_LOGIC = OLD_LOGIC.replace("f.indicator_code IN ('DUY_TRI_DKCP_GPKD')",
                              "f.securities_company_alert_indicator_dim_id IN (SELECT d.securities_company_alert_indicator_dim_id FROM securities_company_alert_indicator_dim d WHERE d.sc_alert_ind_src_id IN ('450', '451'))")


class ComparisonLiterals(unittest.TestCase):
    def test_only_condition_position_not_then_else(self):
        lits = L.comparison_literals("CASE WHEN x.code = 'A' THEN 'Nhãn A' ELSE 'Không xác định' END")
        self.assertEqual(lits, ["A"])

    def test_in_list_like_has_and_bracket_note_stripped(self):
        lits = L.comparison_literals("t.c IN ('X', 'Y') AND lowerUTF8(t.n) LIKE '%hoạt động%' AND has(t.arr, 'Z') [flat: ghi chú 'bỏ qua']")
        self.assertEqual(lits, ["X", "Y", "%hoạt động%", "Z"])

    def test_in_subquery_has_no_literal(self):
        self.assertEqual(L.comparison_literals("a IN (SELECT b FROM t WHERE c = 1)"), [])

    def test_multiif_output_after_equals_not_taken(self):
        # QLQ K_QLQ_80: `open_fund_tp_code = 'EQUITY', 'mo_cp'` — 'mo_cp' là output, không phải điều kiện
        self.assertEqual(L.comparison_literals("multiIf(f.open_fund_tp_code = 'EQUITY', 'mo_cp', f.open_fund_tp_code = 'BOND', 'mo_tp', 'khac')"), ["EQUITY", "BOND"])

    def test_dashboard_param_comparison_skipped(self):
        # QLKD K_QLKD_156: `:nhom_nhan_su = 'HDTV'` so với tham số dashboard
        self.assertEqual(L.comparison_literals("(:nhom_nhan_su = 'HDTV' AND p.cl_sc_position_code IN ('10', '11'))"), ["10", "11"])

    def test_defined_literals_are_outputs_only(self):
        d = L.defined_literals(["multiIf(x = 'EQUITY', 'mo_cp', 'khac') AS s", "countIf(s = 'mo_cp')"])
        self.assertEqual(d, {"mo_cp", "khac"})


class LiteralProvenance(unittest.TestCase):
    def rows(self, logic, nhom="Nhóm 5 — Duy trì điều kiện cấp phép GPHL", role="MEASURE"):
        return [("K_QLKD_32", nhom, role, logic)]

    def test_qlkd_old_design_invented_code_is_flagged(self):
        iss = L.literal_provenance_issues(self.rows(OLD_LOGIC), {"5": BA_N5}, BA_N5, ATOMIC)
        self.assertEqual(len(iss), 1)
        lvl, code, msg = iss[0]
        self.assertEqual((lvl, code), ("WARNING", "L3-DM-LITERAL-NOT-IN-BA"))
        self.assertIn("duy_tri_dkcp_gpkd", msg)
        self.assertNotIn("'ctck'", msg.lower().replace("duy_tri", ""))

    def test_qlkd_new_design_ids_from_ba_pass(self):
        self.assertEqual(L.literal_provenance_issues(self.rows(NEW_LOGIC), {"5": BA_N5}, BA_N5, ATOMIC), [])

    def test_numeric_literal_matches_unquoted_number_in_ba(self):
        iss = L.literal_provenance_issues(self.rows("f.severity_level_alt_code = '2'"), {"5": BA_N5}, BA_N5, "")
        self.assertEqual(iss, [])

    def test_atomic_literal_allowed(self):
        iss = L.literal_provenance_issues(self.rows("o.ou_tp_code = 'BRANCH' AND o.src_stm_code = 'SCMS_SC_FIRM_BRANCH'"), {"5": BA_N5}, BA_N5, ATOMIC)
        self.assertEqual(iss, [])

    def test_idioms_and_formats_skipped(self):
        iss = L.literal_provenance_issues(self.rows("trimBoth(splitByString(' >> ', x)[1]) = '' AND formatDateTime(d, '%Y-%m') = '2024-01' AND y = '#'"),
                                          {"5": BA_N5}, BA_N5, "")
        self.assertEqual([i[1] for i in iss], ["L3-DM-LITERAL-NOT-IN-BA"])  # chỉ '2024-01' bị báo

    def test_literal_in_other_nhom_not_flagged(self):
        iss = L.literal_provenance_issues(self.rows("f.x = 'KY_HAN_9'"), {"5": BA_N5, "7": "where x = 'KY_HAN_9'"}, BA_N5 + "\nwhere x = 'ky_han_9'", "")
        self.assertEqual(iss, [])

    def test_literal_defined_by_same_nhom_output_not_flagged(self):
        # QLQ K_QLQ_2700 dùng 'mo_khac' do K_QLQ_80 cùng Nhóm sinh ở vị trí output
        rows = [("K_QLQ_80", "Nhóm 12", "GROUP_BY", "multiIf(f.open_fund_tp_code = 'EQUITY', 'mo_cp', 'mo_khac') AS s"),
                ("K_QLQ_2700", "Nhóm 12", "DERIVED", "if(countIf(s = 'mo_khac') = 0, NULL, maxIf(pct, s = 'mo_khac'))")]
        iss = L.literal_provenance_issues(rows, {"12": "open_fund_type ... 'equity'"}, "", "")
        self.assertEqual(iss, [])

    def test_exception_and_deprecated_skipped(self):
        rows = self.rows(OLD_LOGIC) + [("K_QLKD_31", "Nhóm 5", "DEPRECATED", "x = 'BO_QUA'")]
        iss = L.literal_provenance_issues(rows, {"5": BA_N5}, BA_N5, ATOMIC, exceptions={("K_QLKD_32", "duy_tri_dkcp_gpkd")})
        self.assertEqual(iss, [])


if __name__ == "__main__":
    unittest.main()
