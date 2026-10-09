# -*- coding: utf-8 -*-
"""Gate 0 phải kiểm cặp atomic_table / atomic_column của dòng NHIỀU bảng (A16) — trước 2026-10-09 bỏ qua hẳn."""
from __future__ import annotations

import sys
import unittest
from pathlib import Path

_S = Path(__file__).resolve().parents[1] / ".claude" / "skills" / "datamart-review" / "scripts"
sys.path.insert(0, str(_S))

from datamart_common.reference_checker import check_multi_table_pair  # noqa: E402
import build_model_yaml  # noqa: E402

ATOMIC = {
    "security_trading_snapshot": {"close_price", "symbol", "trading_dt"},
    "cl_risk_indicator_value": {"val", "cl_risk_ind_code", "period_dt"},
}


class MultiTablePair(unittest.TestCase):
    def test_prefixed_pair_ok(self):
        self.assertEqual(check_multi_table_pair(
            "security_trading_snapshot / listed_share_info / cl_risk_indicator_value",
            "security_trading_snapshot.close_price / listed_share_info.outstanding_share_quantity / cl_risk_indicator_value.val",
            ATOMIC), [])

    def test_prefixed_column_on_wrong_table_is_critical(self):
        # close_price KHÔNG thuộc cl_risk_indicator_value
        out = check_multi_table_pair("security_trading_snapshot / cl_risk_indicator_value",
                                     "cl_risk_indicator_value.close_price", ATOMIC)
        self.assertEqual([(c, s) for c, s, _ in out], [("L0-ATOMIC-COLUMN-NOT-FOUND", "CRITICAL")])

    def test_prefix_table_not_listed(self):
        out = check_multi_table_pair("security_trading_snapshot / cl_risk_indicator_value",
                                     "securities_trade.execution_val", ATOMIC)
        self.assertEqual(out[0][0], "L0-MULTI-TABLE-PAIR-INVALID")

    def test_bare_column_found_nowhere_is_flagged(self):
        out = check_multi_table_pair("security_trading_snapshot / cl_risk_indicator_value", "no_such_col", ATOMIC)
        self.assertEqual(out[0][0], "L0-MULTI-TABLE-COLUMN-NOT-FOUND")

    def test_bare_column_with_unindexed_table_not_flagged(self):
        # listed_share_info chưa có YAML Atomic → không kết luận được
        self.assertEqual(check_multi_table_pair("security_trading_snapshot / listed_share_info",
                                                "outstanding_share_quantity", ATOMIC), [])


class YamlQualify(unittest.TestCase):
    def test_prefixed_kept_verbatim(self):
        self.assertEqual(build_model_yaml._qualify("a / b", "a.x / b.y"), "a.x / b.y")

    def test_single_table_gets_prefix(self):
        self.assertEqual(build_model_yaml._qualify("a", "x"), "a.x")

    def test_bare_multi_keeps_legacy_form(self):
        self.assertEqual(build_model_yaml._qualify("a / b", "x"), "a / b.x")


class DesignLintEtlPatterns(unittest.TestCase):
    CUM = {"total_trading_val", "total_trading_vol"}

    def _lint(self, etl, desc=""):
        import check_design_lint
        return [c for _, c, _ in check_design_lint.lint_etl_text(etl, self.CUM, desc)]

    def test_hnx_symbol_join_without_isin_flagged(self):
        etl = "JOIN security_trading_snapshot ON security_trading_snapshot.symbol = securities_trade.security_symbol_code"
        self.assertEqual(self._lint(etl), ["L3-HNX-ISSUE-CODE-JOIN"])

    def test_hnx_symbol_join_reviewed_marker_suppresses(self):
        etl = "JOIN security_trading_snapshot ON security_trading_snapshot.symbol = securities_trade.security_symbol_code"
        self.assertEqual(self._lint(etl, "[HNX-KEY-REVIEWED 2026-10-09: BA SQL nối Issue_Code = symbol; O_PTTT_42]"), [])

    def test_hnx_join_with_isin_branch_ok(self):
        etl = ("JOIN security_trading_snapshot ON ((securities_trade.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND security_trading_snapshot.symbol = securities_trade.security_symbol_code) "
               "OR (securities_trade.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND security_trading_snapshot.isin_code = securities_trade.security_symbol_code))")
        self.assertEqual(self._lint(etl), [])

    def test_sum_of_cumulative_column_without_trading_time_flagged(self):
        self.assertEqual(self._lint("SUM(security_trading_snapshot.total_trading_val) GROUP BY x"),
                         ["L3-CUMULATIVE-SNAPSHOT-NOT-DEDUPED"])

    def test_sum_of_cumulative_column_with_latest_row_ok(self):
        etl = ("SUM(security_trading_snapshot.total_trading_val) WHERE security_trading_snapshot.trading_time = "
               "(SELECT MAX(s2.trading_time) FROM security_trading_snapshot s2)")
        self.assertEqual(self._lint(etl), [])


if __name__ == "__main__":
    unittest.main()
