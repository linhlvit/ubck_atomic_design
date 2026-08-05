-- ============================================================
-- PTTT Flat Tables — POPULATE
-- Module: Phân tích thị trường (PTTT)
-- Generated: Phase 3 LLD Datamart
-- 13 bảng: 12 fact (snapshot) + 1 operational
-- ETL daily — TRUNCATE + INSERT toàn bộ (SCD4A current-state, không giữ lịch sử nhiều bản)
-- ============================================================


-- ============================================================
-- 1. FACT: pttt_fct_market_risk_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_market_risk_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_market_risk_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.volatility_30_days,
    f.z_score_volatility,
    f.z_score_liquidity,
    f.z_score_margin_balance,
    f.z_score_interbank_rate,
    f.z_score_foreign_net_flow,
    f.total_market_cap,
    f.margin_to_market_cap_ratio,
    f.beta_volatility,
    f.beta_liquidity,
    f.beta_margin_balance,
    f.beta_interbank_rate,
    f.beta_foreign_net_flow,
    f.beta_equity_capital_raising,
    f.beta_intercept,
    f.epsilon_error_term,
    f.risk_index,
    f.z_score_equity_capital_raising,
    f.equity_capital_raising_amt,
    f.z_score_margin_balance_current,
    f.margin_to_cap_ratio_stddev,
    f.margin_to_cap_ratio_current,
    f.margin_to_cap_ratio_avg,
    f.index_log_return,
    f.illiquidity_ratio,
    f.foreign_net_flow,
    f.vnindex_val,
    f.weight_liquidity,
    f.weight_stability,
    f.sentiment_index,
    f.sentiment_index_status,
    f.margin_tension,
    f.margin_tension_status,
    f.vnindex_daily_return,
    f.systemic_vol_current,
    f.systemic_vol_max,
    f.systemic_vol,
    f.systemic_vol_status,
    f.vnindex_val_previous_day,
    f.vnindex_daily_return_average,
    f.index_val_monthly_average,
    f.total_trading_val_matched,
    f.total_trading_val_matched_previous_day,
    f.total_order_count_matched,
    f.average_order_size,
    f.total_trading_vol_matched,
    f.total_trading_val_matched_average_50_days,
    f.total_trading_val_matched_average_n_days,
    f.net_flow_foreign_average_30_days,
    f.net_flow_proprietary_average_30_days,
    f.net_flow_correlation_foreign_proprietary,

    snpst_cal.cdr_dt AS snpst_cdr_dt
FROM datamart.fct_market_risk_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
;


-- ============================================================
-- 2. FACT: pttt_fct_investor_flow_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_investor_flow_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_investor_flow_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.investor_group_dim_id,
    f.buy_val,
    f.sell_val,
    f.net_flow_val,
    f.trading_val_ratio,

    snpst_cal.cdr_dt AS snpst_cdr_dt,

    ig.investor_group_code,
    ig.investor_group_nm
FROM datamart.fct_investor_flow_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.investor_group_dim ig
    ON ig.investor_group_dim_id = f.investor_group_dim_id
;


-- ============================================================
-- 3. FACT: pttt_fct_sector_risk_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_sector_risk_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_sector_risk_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.industry_dim_id,
    f.total_val_sector,

    snpst_cal.cdr_dt AS snpst_cdr_dt,

    sd.industry_code,
    sd.industry_nm
FROM datamart.fct_sector_risk_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.industry_dim sd
    ON sd.industry_dim_id = f.industry_dim_id
;


-- ============================================================
-- 4. FACT: pttt_fct_order_size_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_order_size_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_order_size_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.security_symbol_code,
    f.total_trading_val_matched,
    f.order_size_band,
    f.total_trading_vol_matched,

    snpst_cal.cdr_dt AS snpst_cdr_dt
FROM datamart.fct_order_size_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
;


-- ============================================================
-- 5. FACT: pttt_fct_foreign_net_trade_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_foreign_net_trade_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_foreign_net_trade_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.security_symbol_code,
    f.foreign_buy_val,
    f.foreign_sell_val,
    f.foreign_net_val,

    snpst_cal.cdr_dt AS snpst_cdr_dt
FROM datamart.fct_foreign_net_trade_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
;


-- ============================================================
-- 6. FACT: pttt_fct_proprietary_net_trade_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_proprietary_net_trade_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_proprietary_net_trade_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.security_symbol_code,
    f.proprietary_buy_val,
    f.proprietary_sell_val,
    f.proprietary_net_val,

    snpst_cal.cdr_dt AS snpst_cdr_dt
FROM datamart.fct_proprietary_net_trade_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
;


-- ============================================================
-- 7. FACT: pttt_fct_corporate_bond_market_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_corporate_bond_market_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_corporate_bond_market_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.par_val,
    f.outstanding_vol,
    f.bond_outstanding_val,
    f.maturity_pressure_12_months,
    f.maturity_pressure_12_months_previous,
    f.maturity_pressure_growth_percentage,

    snpst_cal.cdr_dt AS snpst_cdr_dt
FROM datamart.fct_corporate_bond_market_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
;


-- ============================================================
-- 8. FACT: pttt_fct_corporate_bond_maturity_wall_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_corporate_bond_maturity_wall_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_corporate_bond_maturity_wall_flat
SELECT
    f.snpst_dt_dim_id,
    f.securities_dim_id,
    f.ranking_code,

    snpst_cal.cdr_dt AS snpst_cdr_dt,

    sec.symbol,
    sec.security_full_nm,
    sec.stock_tp_code,
    sec.floor_code,
    sec.listed_share_count,
    sec.total_listing_vol,
    sec.underlying_symbol,
    sec.issuer_nm,
    sec.listing_dt,
    sec.symbol_status_code
FROM datamart.fct_corporate_bond_maturity_wall f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.securities_dim sec
    ON sec.securities_dim_id = f.securities_dim_id
;


-- ============================================================
-- 9. FACT: pttt_fct_corporate_bond_sector_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_corporate_bond_sector_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_corporate_bond_sector_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.corp_bond_industry_dim_id,
    f.bond_outstanding_val,
    f.bond_outstanding_val_total,
    f.bond_outstanding_ratio,

    snpst_cal.cdr_dt AS snpst_cdr_dt,

    cbs.industry_code,
    cbs.industry_nm
FROM datamart.fct_corporate_bond_sector_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.corp_bond_industry_dim cbs
    ON cbs.corp_bond_industry_dim_id = f.corp_bond_industry_dim_id
;


-- ============================================================
-- 10. FACT: pttt_fct_futures_intraday_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_futures_intraday_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_futures_intraday_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.security_symbol_code,
    f.underlying_symbol,
    f.maturity_month_year,
    f.close_price,
    f.reference_price,
    f.price_change_percentage,
    f.total_trading_vol_matched,
    f.total_trading_vol_matched_average_50_days,
    f.liquidity_spike_ratio,

    snpst_cal.cdr_dt AS snpst_cdr_dt
FROM datamart.fct_futures_intraday_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
;


-- ============================================================
-- 11. FACT: pttt_fct_futures_investor_flow_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_futures_investor_flow_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_futures_investor_flow_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.security_symbol_code,
    f.underlying_symbol,
    f.foreign_buy_vol,
    f.foreign_sell_vol,
    f.foreign_net_vol,
    f.proprietary_buy_vol,
    f.proprietary_sell_vol,
    f.proprietary_net_vol,

    snpst_cal.cdr_dt AS snpst_cdr_dt
FROM datamart.fct_futures_investor_flow_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
;


-- ============================================================
-- 12. FACT: pttt_fct_market_statistics_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_market_statistics_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_market_statistics_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.market_code,
    f.total_trading_vol_matched,
    f.close_price,
    f.close_price_previous_day,
    f.price_change_percentage,
    f.total_trading_val_matched,
    f.total_trading_val_matched_average_50_days,

    snpst_cal.cdr_dt AS snpst_cdr_dt
FROM datamart.fct_market_statistics_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
;


-- ============================================================
-- 13. OPERATIONAL: pttt_opr_corporate_bond_issuer_credit_monitor_flat
--     Không JOIN, không lọc ngày
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_opr_corporate_bond_issuer_credit_monitor_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_opr_corporate_bond_issuer_credit_monitor_flat
SELECT
    o.issuer_symbol_code,
    o.snpst_dt,
    o.bond_outstanding_val,
    o.par_val,
    o.outstanding_vol,
    o.audit_opinion_text,
    o.ranking_code,
    o.risk_rating_text
FROM datamart.opr_corporate_bond_issuer_credit_monitor o
;
