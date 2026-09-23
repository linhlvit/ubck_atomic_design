-- ============================================================
-- TKNB Flat Tables — POPULATE
-- Module: Thống kê nội bộ (TKNB)
-- Generated: Phase 3 LLD Datamart
-- 23 bảng — operational: KHÔNG JOIN, KHÔNG lọc ngày; FACT (#13/#16/#23): JOIN dim, lọc :etl_date
-- ============================================================

-- ============================================================
-- 1. OPERATIONAL: hnx01_stock_trading_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_hnx01_stock_trading_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_hnx01_stock_trading_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.item_code,
    o.item_stt,
    o.item_unit,
    o.item_value,
    o.src_stm_code
FROM datamart.hnx01_stock_trading_rpt o
;


-- ============================================================
-- 2. OPERATIONAL: hnx02_gov_bond_otc_trading_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_hnx02_gov_bond_otc_trading_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_hnx02_gov_bond_otc_trading_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.item_code,
    o.item_stt,
    o.item_unit,
    o.item_value,
    o.src_stm_code
FROM datamart.hnx02_gov_bond_otc_trading_rpt o
;


-- ============================================================
-- 3. OPERATIONAL: hnx03_derivative_trading_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_hnx03_derivative_trading_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_hnx03_derivative_trading_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.item_code,
    o.item_stt,
    o.item_unit,
    o.item_value,
    o.src_stm_code
FROM datamart.hnx03_derivative_trading_rpt o
;


-- ============================================================
-- 4. OPERATIONAL: hnx04_market_scale_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_hnx04_market_scale_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_hnx04_market_scale_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.item_code,
    o.period_type,
    o.item_stt,
    o.item_unit,
    o.item_value,
    o.src_stm_code
FROM datamart.hnx04_market_scale_rpt o
;


-- ============================================================
-- 5. OPERATIONAL: hnx07_corp_bond_trading_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_hnx07_corp_bond_trading_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_hnx07_corp_bond_trading_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.item_code,
    o.item_stt,
    o.item_unit,
    o.item_value,
    o.src_stm_code
FROM datamart.hnx07_corp_bond_trading_rpt o
;


-- ============================================================
-- 6. OPERATIONAL: hsx01_stock_trading_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_hsx01_stock_trading_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_hsx01_stock_trading_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.item_code,
    o.item_stt,
    o.item_unit,
    o.item_value,
    o.src_stm_code
FROM datamart.hsx01_stock_trading_rpt o
;


-- ============================================================
-- 7. OPERATIONAL: hsx02_listing_trading_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_hsx02_listing_trading_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_hsx02_listing_trading_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.item_code,
    o.period_type,
    o.item_stt,
    o.item_unit,
    o.item_value,
    o.src_stm_code
FROM datamart.hsx02_listing_trading_rpt o
;


-- ============================================================
-- 8. OPERATIONAL: hsx04_proprietary_trading_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_hsx04_proprietary_trading_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_hsx04_proprietary_trading_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.item_code,
    o.item_stt,
    o.item_unit,
    o.item_value,
    o.src_stm_code
FROM datamart.hsx04_proprietary_trading_rpt o
;


-- ============================================================
-- 9. OPERATIONAL: ttlk10_cw_outstanding_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_ttlk10_cw_outstanding_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_ttlk10_cw_outstanding_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.listed_cw_code,
    o.covered_warrant_nm,
    o.outstanding_quantity,
    o.src_stm_code
FROM datamart.ttlk10_cw_outstanding_rpt o
;


-- ============================================================
-- 10. OPERATIONAL: 0513hubckqg_offering_result_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_0513hubckqg_offering_result_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_0513hubckqg_offering_result_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.item_code,
    o.item_stt,
    o.item_unit,
    o.item_value,
    o.src_stm_code
FROM datamart.0513hubckqg_offering_result_rpt o
;


-- ============================================================
-- 11. OPERATIONAL: tk04btc_market_summary_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_tk04btc_market_summary_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_tk04btc_market_summary_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.item_code,
    o.period_marker,
    o.measure_type,
    o.item_stt,
    o.item_unit,
    o.item_value,
    o.src_stm_code
FROM datamart.tk04btc_market_summary_rpt o
;


-- ============================================================
-- 12. OPERATIONAL: tkniengiam_market_annual_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_tkniengiam_market_annual_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_tkniengiam_market_annual_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.item_code,
    o.item_stt,
    o.item_unit,
    o.item_value,
    o.src_stm_code
FROM datamart.tkniengiam_market_annual_rpt o
;


-- ============================================================
-- 13. FACT: fct_market_trading_snpst
--    [SỬA 2026-09-22, datamart-review — Kịch bản D] Thay thế bm030amss_market_trading_rpt (DEPRECATED)
--    trade_cal: JOIN + WHERE cdr_dt = :etl_date
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_fct_market_trading_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_fct_market_trading_snpst_flat
SELECT
    -- From: FACT Fact Market Trading Snapshot
    f.snpst_dt_dim_id,
    f.total_trading_val,
    f.total_trading_vol,
    f.matched_trading_val,
    f.matched_trading_vol,
    f.negotiated_trading_val,
    f.negotiated_trading_vol,
    f.odd_lot_trading_val,
    f.odd_lot_trading_vol,
    f.src_stm_code,

    -- From: CALENDAR DATE DIMENSION
    trade_cal.cdr_dt                   AS trade_cdr_dt

FROM datamart.fct_market_trading_snpst f
JOIN datamart.cdr_dt_dim trade_cal
    ON trade_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE trade_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 14. OPERATIONAL: bm030cmss_corp_bond_trading_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_bm030cmss_corp_bond_trading_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_bm030cmss_corp_bond_trading_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.item_code,
    o.item_stt,
    o.item_unit,
    o.item_value,
    o.src_stm_code
FROM datamart.bm030cmss_corp_bond_trading_rpt o
;


-- ============================================================
-- 15. OPERATIONAL: bm030emss_fund_cert_etf_cw_trading_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_bm030emss_fund_cert_etf_cw_trading_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_bm030emss_fund_cert_etf_cw_trading_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.item_code,
    o.item_stt,
    o.item_unit,
    o.item_value,
    o.src_stm_code
FROM datamart.bm030emss_fund_cert_etf_cw_trading_rpt o
;


-- ============================================================
-- 16. FACT: fct_foreign_proprietary_trading_index_snpst
--    [SỬA 2026-09-22, datamart-review — Kịch bản D] Thay thế bm031amss_foreign_proprietary_trading_rpt (DEPRECATED)
--    trade_cal: JOIN theo ngày giao dịch. idx_dim: LEFT JOIN qua Index Constituent Dimension Id
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_fct_foreign_proprietary_trading_index_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_fct_foreign_proprietary_trading_index_snpst_flat
SELECT
    -- From: FACT Fact Foreign Proprietary Trading Index Snapshot
    f.snpst_dt_dim_id,
    f.index_constituent_dim_id,
    f.foreign_investor_total_buy_vol,
    f.foreign_investor_total_sell_vol,
    f.foreign_investor_total_buy_val,
    f.foreign_investor_total_sell_val,
    f.foreign_investor_negotiated_buy_vol,
    f.foreign_investor_negotiated_sell_vol,
    f.foreign_investor_negotiated_buy_val,
    f.foreign_investor_negotiated_sell_val,
    f.foreign_investor_matched_buy_vol,
    f.foreign_investor_matched_sell_vol,
    f.foreign_investor_matched_buy_val,
    f.foreign_investor_matched_sell_val,
    f.proprietary_total_buy_vol,
    f.proprietary_total_sell_vol,
    f.proprietary_total_buy_val,
    f.proprietary_total_sell_val,
    f.proprietary_negotiated_buy_vol,
    f.proprietary_negotiated_sell_vol,
    f.proprietary_negotiated_buy_val,
    f.proprietary_negotiated_sell_val,
    f.proprietary_matched_buy_vol,
    f.proprietary_matched_sell_vol,
    f.proprietary_matched_buy_val,
    f.proprietary_matched_sell_val,
    f.src_stm_code,

    -- From: CALENDAR DATE DIMENSION
    trade_cal.cdr_dt                   AS trade_cdr_dt,

    -- From: INDEX CONSTITUENT DIMENSION
    idx_dim.index_code                 AS index_code,
    idx_dim.index_id                   AS index_id,
    idx_dim.index_nm                   AS index_nm

FROM datamart.fct_foreign_proprietary_trading_index_snpst f
JOIN datamart.cdr_dt_dim trade_cal
    ON trade_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.index_constituent_dim idx_dim
    ON idx_dim.index_constituent_dim_id = f.index_constituent_dim_id
WHERE trade_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 17. OPERATIONAL: bm031bmss_gov_bond_foreign_proprietary_trading_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_bm031bmss_gov_bond_foreign_proprietary_trading_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_bm031bmss_gov_bond_foreign_proprietary_trading_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.item_code,
    o.item_stt,
    o.item_unit,
    o.item_value,
    o.src_stm_code
FROM datamart.bm031bmss_gov_bond_foreign_proprietary_trading_rpt o
;


-- ============================================================
-- 18. OPERATIONAL: bm031cmss_corp_bond_foreign_proprietary_trading_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_bm031cmss_corp_bond_foreign_proprietary_trading_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_bm031cmss_corp_bond_foreign_proprietary_trading_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.item_code,
    o.item_stt,
    o.item_unit,
    o.item_value,
    o.src_stm_code
FROM datamart.bm031cmss_corp_bond_foreign_proprietary_trading_rpt o
;


-- ============================================================
-- 19. OPERATIONAL: bm031dmss_fund_cert_etf_cw_foreign_proprietary_trading_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_bm031dmss_fund_cert_etf_cw_foreign_proprietary_trading_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_bm031dmss_fund_cert_etf_cw_foreign_proprietary_trading_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.item_code,
    o.item_stt,
    o.item_unit,
    o.item_value,
    o.src_stm_code
FROM datamart.bm031dmss_fund_cert_etf_cw_foreign_proprietary_trading_rpt o
;


-- ============================================================
-- 20. OPERATIONAL: bm031fmss_derivatives_foreign_proprietary_trading_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_bm031fmss_derivatives_foreign_proprietary_trading_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_bm031fmss_derivatives_foreign_proprietary_trading_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.item_code,
    o.item_stt,
    o.item_unit,
    o.item_value,
    o.src_stm_code
FROM datamart.bm031fmss_derivatives_foreign_proprietary_trading_rpt o
;


-- ============================================================
-- 21. OPERATIONAL: bm035mss_security_trading_detail_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_bm035mss_security_trading_detail_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_bm035mss_security_trading_detail_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.item_code,
    o.security_symbol_code,
    o.item_stt,
    o.item_unit,
    o.item_value,
    o.src_stm_code
FROM datamart.bm035mss_security_trading_detail_rpt o
;


-- ============================================================
-- 22. OPERATIONAL: bm043mss_derivatives_security_detail_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_bm043mss_derivatives_security_detail_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_bm043mss_derivatives_security_detail_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.item_code,
    o.security_symbol_code,
    o.item_stt,
    o.item_unit,
    o.item_value,
    o.src_stm_code
FROM datamart.bm043mss_derivatives_security_detail_rpt o
;

-- ============================================================
-- 23. FACT: fct_market_index_snpst (reuse — sở hữu QLKD) — [MỚI 2026-09-23] Nhóm 18 K_TKNB_1013/1014
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_fct_market_index_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_fct_market_index_snpst_flat
SELECT
    -- From: FACT Market Index Snapshot
    f.snpst_dt_dim_id,
    f.market_index_dim_id,
    f.market_index_val,

    -- From: CALENDAR DATE DIMENSION
    trade_cal.cdr_dt                    AS trade_cdr_dt,

    -- From: MARKET INDEX DIMENSION
    mi.market_code,

    -- From: INDEX CONSTITUENT DIMENSION
    idx_dim.index_constituent_dim_id,
    idx_dim.index_code,
    idx_dim.index_nm

FROM datamart.fct_market_index_snpst f
JOIN datamart.cdr_dt_dim trade_cal
    ON trade_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
JOIN datamart.market_index_dim mi
    ON mi.market_index_dim_id = f.market_index_dim_id
JOIN datamart.index_constituent_dim idx_dim
    ON idx_dim.index_code = mi.market_code
WHERE trade_cal.cdr_dt = :etl_date
  AND idx_dim.index_code IN ('HOSE','HNX','UPCOM','30','HNX30','100')
;
