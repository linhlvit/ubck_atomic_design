-- ============================================================
-- TKNB Flat Tables — POPULATE
-- Module: Thống kê nội bộ (TKNB)
-- Generated: Phase 3 LLD Datamart
-- 21 bảng operational — KHÔNG JOIN, KHÔNG lọc ngày (toàn bộ dữ liệu mỗi lần populate)
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
-- 2. OPERATIONAL: hnx03_derivative_trading_rpt
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
-- 3. OPERATIONAL: hnx04_market_scale_rpt
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
-- 4. OPERATIONAL: hnx07_corp_bond_trading_rpt
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
-- 5. OPERATIONAL: hsx01_stock_trading_rpt
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
-- 6. OPERATIONAL: hsx02_listing_trading_rpt
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
-- 7. OPERATIONAL: hsx04_proprietary_trading_rpt
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
-- 8. OPERATIONAL: ttlk10_cw_outstanding_rpt
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
-- 9. OPERATIONAL: 0513hubckqg_offering_result_rpt
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
-- 10. OPERATIONAL: tk04btc_market_summary_rpt
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
-- 11. OPERATIONAL: tkniengiam_market_annual_rpt
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
-- 12. OPERATIONAL: bm030amss_market_trading_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_bm030amss_market_trading_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_bm030amss_market_trading_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.item_code,
    o.item_stt,
    o.item_unit,
    o.item_value,
    o.src_stm_code
FROM datamart.bm030amss_market_trading_rpt o
;


-- ============================================================
-- 13. OPERATIONAL: bm030cmss_corp_bond_trading_rpt
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
-- 14. OPERATIONAL: bm030emss_fund_cert_etf_cw_trading_rpt
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
-- 15. OPERATIONAL: bm031amss_foreign_proprietary_trading_rpt
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_bm031amss_foreign_proprietary_trading_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_bm031amss_foreign_proprietary_trading_rpt_flat
SELECT
    o.report_code,
    o.report_period_dt,
    o.item_code,
    o.item_stt,
    o.item_unit,
    o.item_value,
    o.src_stm_code
FROM datamart.bm031amss_foreign_proprietary_trading_rpt o
;


-- ============================================================
-- 16. OPERATIONAL: bm031bmss_gov_bond_foreign_proprietary_trading_rpt
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
-- 17. OPERATIONAL: bm031cmss_corp_bond_foreign_proprietary_trading_rpt
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
-- 18. OPERATIONAL: bm031dmss_fund_cert_etf_cw_foreign_proprietary_trading_rpt
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
-- 19. OPERATIONAL: bm031fmss_derivatives_foreign_proprietary_trading_rpt
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
-- 20. OPERATIONAL: bm035mss_security_trading_detail_rpt
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
-- 21. OPERATIONAL: bm043mss_derivatives_security_detail_rpt
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


