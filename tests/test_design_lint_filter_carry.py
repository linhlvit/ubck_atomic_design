"""D27 [L3-BA-FILTER-NOT-CARRIED] — điều kiện loại dòng của BA phải có ở mọi đường đọc (luật A38).
Tái hiện sự cố VP Nhóm 17 2026-11-10: BA `WHERE s.floorcode <> '03'` (stock_eod → stock_portfolio); Fact Listed Equity lọc ở ETL nhưng
K_VP_382–389 phân loại sự kiện qua security_trading_snpst_dim.stock_tp_code không có floor_code <> '03'.
"""
from __future__ import annotations

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / ".claude" / "skills" / "datamart-review" / "scripts"))

import check_design_lint as L  # noqa: E402

RULES = [{
    "id": "MDDS-DERIVATIVE-FLOOR-VIA-DIM",
    "ba_pattern": r"floorcode\s*(<>|!=)\s*'03'",
    "reads": ["security_trading_snpst_dim.stock_tp_code", "security_trading_snpst_dim.fund_tp_code"],
    "require_any": ["security_trading_snpst_dim.floor_code"],
    "reason": "loại phái sinh",
}]
BA = {"17": "from uat_mdds_stg.jad_stockinfor s where s.floorcode <> '03' -- không lấy chứng khoán phái sinh"}
OLD = ("COUNT(CASE WHEN fct_listing_status_change_snpst.new_listed_share_quantity > 0 THEN fct_listing_status_change_snpst.ticker_symbol END) "
       "JOIN security_trading_snpst_dim ON 1 = 1 WHERE cdr_dt_dim.cdr_dt BETWEEN :a AND :b [Loại CK theo security_trading_snpst_dim.stock_tp_code/fund_tp_code]")
NEW = OLD.replace("BETWEEN :a AND :b", "BETWEEN :a AND :b AND security_trading_snpst_dim.floor_code <> '03'")
NHOM = "Nhóm 17 - Niêm yết >> Chỉ tiêu tổng hợp"


class FilterCarry(unittest.TestCase):
    def test_old_logic_flagged(self):
        out = L.filter_carry_issues([("K_VP_382", NHOM, "DERIVED", OLD)], BA, RULES)
        self.assertEqual([c for _, c, _ in out], ["L3-BA-FILTER-NOT-CARRIED"])
        self.assertIn("K_VP_382", out[0][2])

    def test_fixed_logic_clean(self):
        self.assertEqual(L.filter_carry_issues([("K_VP_382", NHOM, "DERIVED", NEW)], BA, RULES), [])

    def test_fact_filtered_at_etl_not_in_scope(self):
        lg = "SUM(fct_listed_equity_snpst.listed_share_quantity) WHERE fct_listed_equity_snpst.stock_tp_code IN ('1','2')"
        self.assertEqual(L.filter_carry_issues([("K_VP_378", NHOM, "DERIVED", lg)], BA, RULES), [])

    def test_ba_without_filter_not_flagged(self):
        self.assertEqual(L.filter_carry_issues([("K_X", "Nhóm 50 - x", "SLICER", OLD)], {"50": "select 1 from jad_stockinfor s"}, RULES), [])

    def test_exception_and_deprecated_skipped(self):
        self.assertEqual(L.filter_carry_issues([("K_VP_382", NHOM, "DERIVED", OLD)], BA, RULES, {("MDDS-DERIVATIVE-FLOOR-VIA-DIM", "K_VP_382")}), [])
        self.assertEqual(L.filter_carry_issues([("K_VP_382", NHOM, "DEPRECATED", OLD)], BA, RULES), [])

    def test_repo_rules_file_loads(self):
        rules, _ = L.load_filter_carry_rules()
        self.assertTrue(any(r.get("id") == "MDDS-DERIVATIVE-FLOOR-VIA-DIM" for r in rules))


if __name__ == "__main__":
    unittest.main()
