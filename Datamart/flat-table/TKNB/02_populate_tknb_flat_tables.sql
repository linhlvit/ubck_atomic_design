-- ============================================================
-- TKNB Flat Tables — POPULATE
-- Module: Thống kê nội bộ (TKNB)
-- Generated: Phase 3 LLD Datamart
-- 8 bảng FACT (2026-11-06: 6 bảng operational EAV HNX04/HSX02/0513/TK-04.BTC/TK_NienGiam/BM031d gộp vào `item_value` — không còn flat riêng ở file này; TTLK01/TTLK10 đã chuyển Operational → Fact 2026-11-04). `item_value` KHÔNG có flat gộp (Data Modeler bỏ 2026-10-25): 20 flat ClickHouse theo báo cáo (IV1–IV20) nằm ở file 03_clickhouse_per_report_flat_from_item_value.sql
-- ============================================================

-- ============================================================
-- 9. FACT: fct_covered_warrant_outstanding_snpst
--    Nạp theo ngày snapshot :etl_date (DELETE + INSERT)
-- ============================================================
DELETE FROM datamart.tknb_fct_covered_warrant_outstanding_snpst_flat ON CLUSTER 'my_cluster'
WHERE snpst_cdr_dt = :etl_date;
INSERT INTO datamart.tknb_fct_covered_warrant_outstanding_snpst_flat
SELECT
    -- From: FACT Fact Covered Warrant Outstanding Snapshot
    f.covered_warrant_outstanding_snpst_id,
    f.snpst_dt_dim_id,
    f.security_trading_snpst_dim_id,
    f.outstanding_quantity,
    f.src_stm_code,

    -- From: CALENDAR DATE DIMENSION
    snpst_cal.cdr_dt                   AS snpst_cdr_dt,

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    sd.symbol                          AS symbol,
    sd.security_full_nm                AS security_full_nm

FROM datamart.fct_covered_warrant_outstanding_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.security_trading_snpst_dim sd
    ON sd.security_trading_snpst_dim_id = f.security_trading_snpst_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
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
    f.market_trading_snpst_id,
    f.snpst_dt_dim_id,
    f.index_constituent_dim_id,
    f.total_trading_val,
    f.total_trading_vol,
    f.matched_trading_val,
    f.matched_trading_vol,
    f.negotiated_trading_val,
    f.negotiated_trading_vol,
    f.odd_lot_trading_val,
    f.odd_lot_trading_vol,
    f.market_index_val,
    f.src_stm_code,

    -- From: CALENDAR DATE DIMENSION
    trade_cal.cdr_dt                   AS trade_cdr_dt,

    -- From: INDEX CONSTITUENT DIMENSION
    idx_dim.index_code,
    idx_dim.index_nm

FROM datamart.fct_market_trading_snpst f
JOIN datamart.cdr_dt_dim trade_cal
    ON trade_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.index_constituent_dim idx_dim
    ON idx_dim.index_constituent_dim_id = f.index_constituent_dim_id
WHERE trade_cal.cdr_dt = :etl_date
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
    f.foreign_proprietary_trading_index_snpst_id,
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
-- 21. FACT: fct_private_corporate_bond_international_offering_snpst
--    snpst_cal: JOIN + lọc cdr_dt theo ngày chạy ETL; chuỗi kỳ báo cáo — DELETE đúng ngày rồi INSERT (giữ lịch sử)
-- ============================================================
DELETE FROM datamart.tknb_fct_private_corporate_bond_international_offering_snpst_flat ON CLUSTER 'my_cluster'
WHERE snpst_cdr_dt = :etl_date;
INSERT INTO datamart.tknb_fct_private_corporate_bond_international_offering_snpst_flat
SELECT
    -- From: FACT Fact Private Corporate Bond International Offering Snapshot
    f.private_corporate_bond_international_offering_snpst_id,
    f.snpst_dt_dim_id,
    f.private_corporate_bond_dim_id,
    f.rpt_year,
    f.rpt_month,
    f.market_tp,
    f.currency_code,
    f.offering_bond_quantity,
    f.posting_dt,
    f.src_stm_code,

    -- From: CALENDAR DATE DIMENSION
    snpst_cal.cdr_dt                   AS snpst_cdr_dt,

    -- From: PRIVATE CORPORATE BOND DIMENSION
    bd.bond_code                       AS bond_code,
    bd.issuer_nm                       AS issuer_nm,
    bd.enterprise_tp                   AS enterprise_tp,
    bd.business_sector                 AS business_sector,
    bd.bond_term_unit                  AS bond_term_unit,
    bd.bond_term                       AS bond_term,
    bd.interest_rate_tp                AS interest_rate_tp,
    bd.issue_interest_rate             AS issue_interest_rate,
    bd.issue_dt                        AS issue_dt,
    bd.maturity_dt                     AS maturity_dt,
    bd.interest_payment_method         AS interest_payment_method,
    bd.convertible_bond_ind            AS convertible_bond_ind,
    bd.warrant_linked_bond_ind         AS warrant_linked_bond_ind,
    bd.secured_bond_ind                AS secured_bond_ind,
    bd.src_stm_code                    AS bond_src_stm_code

FROM datamart.fct_private_corporate_bond_international_offering_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.private_corporate_bond_dim bd
    ON bd.private_corporate_bond_dim_id = f.private_corporate_bond_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;

-- ============================================================
-- 22. FACT: fct_private_corporate_bond_issuance_snpst
--    snpst_cal: JOIN + lọc cdr_dt theo ngày chạy ETL; chuỗi kỳ báo cáo — DELETE đúng ngày rồi INSERT (giữ lịch sử)
-- ============================================================
DELETE FROM datamart.tknb_fct_private_corporate_bond_issuance_snpst_flat ON CLUSTER 'my_cluster'
WHERE snpst_cdr_dt = :etl_date;
INSERT INTO datamart.tknb_fct_private_corporate_bond_issuance_snpst_flat
SELECT
    -- From: FACT Fact Private Corporate Bond Issuance Snapshot
    f.private_corporate_bond_issuance_snpst_id,
    f.snpst_dt_dim_id,
    f.private_corporate_bond_dim_id,
    f.rpt_year,
    f.rpt_month,
    f.issued_bond_quantity,
    f.par_value,
    f.issued_bond_val_amt,
    f.src_stm_code,

    -- From: CALENDAR DATE DIMENSION
    snpst_cal.cdr_dt                   AS snpst_cdr_dt,

    -- From: PRIVATE CORPORATE BOND DIMENSION
    bd.bond_code                      AS bond_code,
    bd.issuer_nm                      AS issuer_nm,
    bd.enterprise_tp                  AS enterprise_tp,
    bd.business_sector                AS business_sector,
    bd.bond_term_unit                 AS bond_term_unit,
    bd.bond_term                      AS bond_term,
    bd.interest_rate_tp               AS interest_rate_tp,
    bd.issue_interest_rate            AS issue_interest_rate,
    bd.issue_dt                       AS issue_dt,
    bd.maturity_dt                    AS maturity_dt,
    bd.interest_payment_method        AS interest_payment_method,
    bd.convertible_bond_ind           AS convertible_bond_ind,
    bd.warrant_linked_bond_ind        AS warrant_linked_bond_ind,
    bd.secured_bond_ind               AS secured_bond_ind,
    bd.src_stm_code                    AS bond_src_stm_code

FROM datamart.fct_private_corporate_bond_issuance_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.private_corporate_bond_dim bd
    ON bd.private_corporate_bond_dim_id = f.private_corporate_bond_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 23. FACT: fct_security_trading_detail_snpst
--    snpst_cal: JOIN + lọc cdr_dt theo ngày chạy ETL; chuỗi theo ngày — DELETE đúng ngày rồi INSERT (giữ lịch sử)
-- ============================================================
DELETE FROM datamart.tknb_fct_security_trading_detail_snpst_flat ON CLUSTER 'my_cluster'
WHERE snpst_cdr_dt = :etl_date;
INSERT INTO datamart.tknb_fct_security_trading_detail_snpst_flat
SELECT
    -- From: FACT Fact Security Trading Detail Snapshot
    f.security_trading_detail_snpst_id,
    f.snpst_dt_dim_id,
    f.security_trading_snpst_dim_id,
    f.trading_status_code,
    f.reference_price,
    f.ceiling_price,
    f.floor_price,
    f.close_price,
    f.average_price,
    f.high_price,
    f.low_price,
    f.buy_order_cnt,
    f.buy_order_vol,
    f.sell_order_cnt,
    f.sell_order_vol,
    f.matched_trading_vol,
    f.matched_trading_val,
    f.negotiated_trading_vol,
    f.negotiated_trading_val,
    f.odd_lot_trading_vol,
    f.odd_lot_trading_val,
    f.total_trading_vol,
    f.total_trading_val,
    f.max_foreign_ownership_ratio,
    f.remaining_foreign_ownership_ratio,
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
    snpst_cal.cdr_dt                   AS snpst_cdr_dt,

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    sd.symbol                            AS symbol,
    sd.security_full_nm                  AS security_full_nm,
    sd.floor_code                        AS floor_code,
    sd.stock_tp_code                     AS stock_tp_code,
    sd.isin_code                         AS isin_code

FROM datamart.fct_security_trading_detail_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.security_trading_snpst_dim sd
    ON sd.security_trading_snpst_dim_id = f.security_trading_snpst_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 24. FACT: fct_derivatives_security_detail_snpst
--    snpst_cal: JOIN + lọc cdr_dt theo ngày chạy ETL; chuỗi theo ngày — DELETE đúng ngày rồi INSERT (giữ lịch sử)
-- ============================================================
DELETE FROM datamart.tknb_fct_derivatives_security_detail_snpst_flat ON CLUSTER 'my_cluster'
WHERE snpst_cdr_dt = :etl_date;
INSERT INTO datamart.tknb_fct_derivatives_security_detail_snpst_flat
SELECT
    -- From: FACT Fact Derivatives Security Detail Snapshot
    f.derivatives_security_detail_snpst_id,
    f.snpst_dt_dim_id,
    f.security_trading_snpst_dim_id,
    f.open_interest_quantity,
    f.trading_vol,
    f.trading_val,
    f.foreign_investor_buy_vol,
    f.foreign_investor_sell_vol,
    f.foreign_investor_buy_val,
    f.foreign_investor_sell_val,
    f.proprietary_buy_vol,
    f.proprietary_sell_vol,
    f.proprietary_buy_val,
    f.proprietary_sell_val,
    f.src_stm_code,

    -- From: CALENDAR DATE DIMENSION
    snpst_cal.cdr_dt                   AS snpst_cdr_dt,

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    sd.symbol                            AS symbol,
    sd.security_full_nm                  AS security_full_nm,
    sd.floor_code                        AS floor_code,
    sd.isin_code                         AS isin_code,
    sd.maturity_dt                       AS maturity_dt,
    sd.contract_multiplier               AS contract_multiplier

FROM datamart.fct_derivatives_security_detail_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.security_trading_snpst_dim sd
    ON sd.security_trading_snpst_dim_id = f.security_trading_snpst_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 25. FACT: fct_custody_account_open_close_snpst
--    Nạp lại toàn bộ từ Fact (Fact nạp lại mọi tháng <= :etl_date theo PK) — không lọc ngày
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.tknb_fct_custody_account_open_close_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tknb_fct_custody_account_open_close_snpst_flat
SELECT
    -- From: FACT Fact Custody Account Open Close Snapshot
    f.custody_account_open_close_snpst_id,
    f.snpst_dt_dim_id,
    f.depository_member_dim_id,
    f.row_nbr,
    f.opening_domestic_individual_account_quantity,
    f.opening_domestic_institution_account_quantity,
    f.opening_foreign_individual_account_quantity,
    f.opening_foreign_institution_account_quantity,
    f.opened_domestic_individual_account_quantity,
    f.opened_domestic_institution_account_quantity,
    f.opened_foreign_individual_account_quantity,
    f.opened_foreign_institution_account_quantity,
    f.closed_domestic_individual_account_quantity,
    f.closed_domestic_institution_account_quantity,
    f.closed_foreign_individual_account_quantity,
    f.closed_foreign_institution_account_quantity,
    f.closing_domestic_individual_account_quantity,
    f.closing_domestic_institution_account_quantity,
    f.closing_foreign_individual_account_quantity,
    f.closing_foreign_institution_account_quantity,
    f.total_account_quantity,
    f.src_stm_code,

    -- From: CALENDAR DATE DIMENSION
    snpst_cal.cdr_dt                   AS snpst_cdr_dt,

    -- From: DEPOSITORY MEMBER DIMENSION
    dm.depository_member_nm            AS depository_member_nm

FROM datamart.fct_custody_account_open_close_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.depository_member_dim dm
    ON dm.depository_member_dim_id = f.depository_member_dim_id AND dm.ds_rcrd_st = 'ACTIVE'
;
