-- ============================================================
-- VP Flat Tables — POPULATE
-- Module: Thống kê thị trường chứng khoán (VP)
-- Generated: Phase 3 LLD Datamart
-- 6 bảng:
--   1. vp_fct_derivative_contract_snpst_flat (Nhóm 3, 4, 5)
--   2. vp_fct_investor_group_trading_snpst_flat (Nhóm 1, 2, 3, 5, 6, 32, 33, 34, 36)
--   3. vp_fct_listed_corporate_bond_snpst_flat (Nhóm 7, 8, 9, 10)
--   4. vp_fct_private_corporate_bond_trading_snpst_flat (Nhóm 9, 11, 12, 13)
--   5. vp_fct_government_bond_trading_snpst_flat (Nhóm 14, 15, 16)
--   6. vp_fct_private_corporate_bond_registration_snpst_flat (Nhóm 11)
-- Ghi chú: Fact Market Index Snapshot (reuse QLKD) dùng bảng flat của QLKD; lịch ngày dùng datamart.cdr_dt_flat (Datamart/flat-table/Common).
-- Thiết kế lại VP 2026-10-25: bỏ 2 flat cũ vp_fact_otc_bond_snapshot_flat, vp_fact_share_auction_snapshot_flat (DEPRECATED, HLD Section 4).
-- ============================================================


-- ==========================================================
-- 1. FACT: vp_fct_derivative_contract_snpst_flat
-- ==========================================================
DELETE FROM datamart.vp_fct_derivative_contract_snpst_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.vp_fct_derivative_contract_snpst_flat
SELECT
    -- From: FCT_DERIVATIVE_CONTRACT_SNPST
    f.derivative_contract_snpst_id,
    f.snpst_dt_dim_id,
    f.security_trading_snpst_dim_id,
    f.ticker_symbol,
    f.open_interest_quantity,
    f.close_price,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt AS cdr_dt,
    cal.year AS year,
    cal.quarter AS quarter,
    cal.month AS month,
    cal.day_of_week AS day_of_week,
    cal.is_weekend AS is_weekend,
    cal.holiday_flag AS holiday_flag,
    cal.is_trading_date AS is_trading_date,

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    sts_dim.symbol AS symbol,
    sts_dim.security_full_nm AS security_full_nm,
    sts_dim.floor_code AS floor_code,
    sts_dim.stock_tp_code AS stock_tp_code,
    sts_dim.stock_tp_nm AS stock_tp_nm,
    sts_dim.underlying_symbol AS underlying_symbol,
    sts_dim.isin_code AS isin_code,
    sts_dim.issuer_nm AS issuer_nm,
    sts_dim.listed_share_count AS listed_share_count,
    sts_dim.first_trading_dt AS first_trading_dt,
    sts_dim.last_trading_dt AS last_trading_dt,
    sts_dim.issue_dt AS issue_dt,
    sts_dim.maturity_dt AS maturity_dt,
    sts_dim.fund_tp_code AS fund_tp_code,
    sts_dim.covered_warrant_tp_code AS covered_warrant_tp_code,
    sts_dim.exercise_price AS exercise_price,
    sts_dim.exercise_ratio AS exercise_ratio,
    sts_dim.exercise_style_code AS exercise_style_code,
    sts_dim.put_or_call_code AS put_or_call_code,
    sts_dim.contract_multiplier AS contract_multiplier,
    sts_dim.maturity_month_year AS maturity_month_year,
    sts_dim.coupon_rate AS coupon_rate,
    sts_dim.yield AS yield,
    sts_dim.open_price AS open_price,
    sts_dim.high_price AS high_price,
    sts_dim.low_price AS low_price,
    sts_dim.ceiling_price AS ceiling_price,
    sts_dim.floor_price AS floor_price,
    sts_dim.reference_price AS reference_price,
    sts_dim.close_price AS close_price,
    sts_dim.price_change AS price_change,
    sts_dim.product_group_id AS product_group_id,
    sts_dim.src_stm_code AS sts_dim_src_stm_code

FROM datamart.fct_derivative_contract_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.security_trading_snpst_dim sts_dim
    ON sts_dim.security_trading_snpst_dim_id = f.security_trading_snpst_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ==========================================================
-- 2. FACT: vp_fct_investor_group_trading_snpst_flat
-- ==========================================================
DELETE FROM datamart.vp_fct_investor_group_trading_snpst_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.vp_fct_investor_group_trading_snpst_flat
SELECT
    -- From: FCT_INVESTOR_GROUP_TRADING_SNPST
    f.investor_group_trading_snpst_id,
    f.snpst_dt_dim_id,
    f.security_trading_snpst_dim_id,
    f.industry_dim_id,
    f.security_symbol_code,
    f.market_id_code,
    f.investor_group_code,
    f.buy_vol,
    f.buy_val,
    f.sell_vol,
    f.sell_val,
    f.src_stm_code,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt AS cdr_dt,
    cal.year AS year,
    cal.quarter AS quarter,
    cal.month AS month,
    cal.day_of_week AS day_of_week,
    cal.is_weekend AS is_weekend,
    cal.holiday_flag AS holiday_flag,
    cal.is_trading_date AS is_trading_date,

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    sts_dim.symbol AS symbol,
    sts_dim.security_full_nm AS security_full_nm,
    sts_dim.floor_code AS floor_code,
    sts_dim.stock_tp_code AS stock_tp_code,
    sts_dim.stock_tp_nm AS stock_tp_nm,
    sts_dim.underlying_symbol AS underlying_symbol,
    sts_dim.isin_code AS isin_code,
    sts_dim.issuer_nm AS issuer_nm,
    sts_dim.listed_share_count AS listed_share_count,
    sts_dim.first_trading_dt AS first_trading_dt,
    sts_dim.last_trading_dt AS last_trading_dt,
    sts_dim.issue_dt AS issue_dt,
    sts_dim.maturity_dt AS maturity_dt,
    sts_dim.fund_tp_code AS fund_tp_code,
    sts_dim.covered_warrant_tp_code AS covered_warrant_tp_code,
    sts_dim.exercise_price AS exercise_price,
    sts_dim.exercise_ratio AS exercise_ratio,
    sts_dim.exercise_style_code AS exercise_style_code,
    sts_dim.put_or_call_code AS put_or_call_code,
    sts_dim.contract_multiplier AS contract_multiplier,
    sts_dim.maturity_month_year AS maturity_month_year,
    sts_dim.coupon_rate AS coupon_rate,
    sts_dim.yield AS yield,
    sts_dim.open_price AS open_price,
    sts_dim.high_price AS high_price,
    sts_dim.low_price AS low_price,
    sts_dim.ceiling_price AS ceiling_price,
    sts_dim.floor_price AS floor_price,
    sts_dim.reference_price AS reference_price,
    sts_dim.close_price AS close_price,
    sts_dim.price_change AS price_change,
    sts_dim.product_group_id AS product_group_id,
    sts_dim.src_stm_code AS sts_dim_src_stm_code,

    -- From: INDUSTRY DIMENSION
    ind_dim.industry_code AS industry_code,
    ind_dim.industry_nm AS industry_nm

FROM datamart.fct_investor_group_trading_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.security_trading_snpst_dim sts_dim
    ON sts_dim.security_trading_snpst_dim_id = f.security_trading_snpst_dim_id
LEFT JOIN datamart.industry_dim ind_dim
    ON ind_dim.industry_dim_id = f.industry_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ==========================================================
-- 3. FACT: vp_fct_listed_corporate_bond_snpst_flat
-- ==========================================================
DELETE FROM datamart.vp_fct_listed_corporate_bond_snpst_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.vp_fct_listed_corporate_bond_snpst_flat
SELECT
    -- From: FCT_LISTED_CORPORATE_BOND_SNPST
    f.listed_corporate_bond_snpst_id,
    f.snpst_dt_dim_id,
    f.industry_dim_id,
    f.security_symbol_code,
    f.listed_indicator,
    f.issue_term_years,
    f.remaining_term_years,
    f.trading_vol,
    f.trading_val,
    f.foreign_buy_val,
    f.foreign_sell_val,
    f.outstanding_bond_quantity,
    f.bond_outstanding_val,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt AS cdr_dt,
    cal.year AS year,
    cal.quarter AS quarter,
    cal.month AS month,
    cal.day_of_week AS day_of_week,
    cal.is_weekend AS is_weekend,
    cal.holiday_flag AS holiday_flag,
    cal.is_trading_date AS is_trading_date,

    -- From: INDUSTRY DIMENSION
    ind_dim.industry_code AS industry_code,
    ind_dim.industry_nm AS industry_nm

FROM datamart.fct_listed_corporate_bond_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.industry_dim ind_dim
    ON ind_dim.industry_dim_id = f.industry_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ==========================================================
-- 4. FACT: vp_fct_private_corporate_bond_trading_snpst_flat
-- ==========================================================
DELETE FROM datamart.vp_fct_private_corporate_bond_trading_snpst_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.vp_fct_private_corporate_bond_trading_snpst_flat
SELECT
    -- From: FCT_PRIVATE_CORPORATE_BOND_TRADING_SNPST
    f.private_corporate_bond_trading_snpst_id,
    f.snpst_dt_dim_id,
    f.trading_val,
    f.foreign_buy_val,
    f.foreign_sell_val,
    f.src_stm_code,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt AS cdr_dt,
    cal.year AS year,
    cal.quarter AS quarter,
    cal.month AS month,
    cal.day_of_week AS day_of_week,
    cal.is_weekend AS is_weekend,
    cal.holiday_flag AS holiday_flag,
    cal.is_trading_date AS is_trading_date

FROM datamart.fct_private_corporate_bond_trading_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ==========================================================
-- 5. FACT: vp_fct_government_bond_trading_snpst_flat
-- ==========================================================
DELETE FROM datamart.vp_fct_government_bond_trading_snpst_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.vp_fct_government_bond_trading_snpst_flat
SELECT
    -- From: FCT_GOVERNMENT_BOND_TRADING_SNPST
    f.government_bond_trading_snpst_id,
    f.snpst_dt_dim_id,
    f.order_book_tp,
    f.trading_vol,
    f.trading_val,
    f.foreign_buy_val,
    f.foreign_sell_val,
    f.src_stm_code,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt AS cdr_dt,
    cal.year AS year,
    cal.quarter AS quarter,
    cal.month AS month,
    cal.day_of_week AS day_of_week,
    cal.is_weekend AS is_weekend,
    cal.holiday_flag AS holiday_flag,
    cal.is_trading_date AS is_trading_date

FROM datamart.fct_government_bond_trading_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ==========================================================
-- 6. FACT: vp_fct_private_corporate_bond_registration_snpst_flat
--    Grain tháng báo cáo: FK ngày = ngày cuối tháng báo cáo nên dòng của tháng M chỉ vào flat khi :etl_date = ngày cuối tháng M (khớp ETL Fact, O_VP_27).
-- ==========================================================
DELETE FROM datamart.vp_fct_private_corporate_bond_registration_snpst_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.vp_fct_private_corporate_bond_registration_snpst_flat
SELECT
    -- From: FCT_PRIVATE_CORPORATE_BOND_REGISTRATION_SNPST
    f.private_corporate_bond_registration_snpst_id,
    f.snpst_dt_dim_id,
    f.bond_code,
    f.rpt_year,
    f.rpt_month,
    f.maturity_dt,
    f.src_stm_code,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt AS cdr_dt,
    cal.year AS year,
    cal.quarter AS quarter,
    cal.month AS month,
    cal.day_of_week AS day_of_week,
    cal.is_weekend AS is_weekend,
    cal.holiday_flag AS holiday_flag,
    cal.is_trading_date AS is_trading_date

FROM datamart.fct_private_corporate_bond_registration_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ==========================================================
-- 7. FACT: vp_fct_listed_equity_snpst_flat
-- ==========================================================
DELETE FROM datamart.vp_fct_listed_equity_snpst_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.vp_fct_listed_equity_snpst_flat
SELECT
    -- From: FCT_LISTED_EQUITY_SNPST
    f.listed_equity_snpst_id,
    f.snpst_dt_dim_id,
    f.ticker_symbol,
    f.floor_code,
    f.stock_tp_code,
    f.outstanding_share_quantity,
    f.listed_share_quantity,
    f.listed_share_val,
    f.close_price,
    f.reference_price,
    f.next_day_vol_weighted_average_price,
    f.market_price,
    f.market_cap_val,
    f.src_stm_code,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt AS cdr_dt,
    cal.year AS year,
    cal.quarter AS quarter,
    cal.month AS month,
    cal.day_of_week AS day_of_week,
    cal.is_weekend AS is_weekend,
    cal.holiday_flag AS holiday_flag,
    cal.is_trading_date AS is_trading_date

FROM datamart.fct_listed_equity_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ==========================================================
-- 8. FACT: vp_fct_listing_status_change_snpst_flat
-- ==========================================================
DELETE FROM datamart.vp_fct_listing_status_change_snpst_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.vp_fct_listing_status_change_snpst_flat
SELECT
    -- From: FCT_LISTING_STATUS_CHANGE_SNPST
    f.listing_status_change_snpst_id,
    f.snpst_dt_dim_id,
    f.security_trading_snpst_dim_id,
    f.ticker_symbol,
    f.decision_nbr,
    f.decision_dt,
    f.effective_dt,
    f.listing_last_trading_dt,
    f.delisted_share_quantity,
    f.delisted_share_val,
    f.new_listed_share_quantity,
    f.additional_listed_share_quantity,
    f.listed_share_val,
    f.additional_listed_share_val,
    f.exchange_transfer,
    f.delist_transfer_reason,
    f.src_stm_code,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt AS cdr_dt,
    cal.year AS year,
    cal.quarter AS quarter,
    cal.month AS month,
    cal.day_of_week AS day_of_week,
    cal.is_weekend AS is_weekend,
    cal.holiday_flag AS holiday_flag,
    cal.is_trading_date AS is_trading_date,

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    sts_dim.symbol AS symbol,
    sts_dim.security_full_nm AS security_full_nm,
    sts_dim.floor_code AS floor_code,
    sts_dim.stock_tp_code AS stock_tp_code,
    sts_dim.stock_tp_nm AS stock_tp_nm,
    sts_dim.underlying_symbol AS underlying_symbol,
    sts_dim.isin_code AS isin_code,
    sts_dim.issuer_nm AS issuer_nm,
    sts_dim.listed_share_count AS listed_share_count,
    sts_dim.first_trading_dt AS first_trading_dt,
    sts_dim.last_trading_dt AS last_trading_dt,
    sts_dim.issue_dt AS issue_dt,
    sts_dim.maturity_dt AS maturity_dt,
    sts_dim.fund_tp_code AS fund_tp_code,
    sts_dim.covered_warrant_tp_code AS covered_warrant_tp_code,
    sts_dim.exercise_price AS exercise_price,
    sts_dim.exercise_ratio AS exercise_ratio,
    sts_dim.exercise_style_code AS exercise_style_code,
    sts_dim.put_or_call_code AS put_or_call_code,
    sts_dim.contract_multiplier AS contract_multiplier,
    sts_dim.maturity_month_year AS maturity_month_year,
    sts_dim.coupon_rate AS coupon_rate,
    sts_dim.yield AS yield,
    sts_dim.open_price AS open_price,
    sts_dim.high_price AS high_price,
    sts_dim.low_price AS low_price,
    sts_dim.ceiling_price AS ceiling_price,
    sts_dim.floor_price AS floor_price,
    sts_dim.reference_price AS reference_price,
    sts_dim.close_price AS close_price,
    sts_dim.price_change AS price_change,
    sts_dim.product_group_id AS product_group_id,
    sts_dim.src_stm_code AS sts_dim_src_stm_code

FROM datamart.fct_listing_status_change_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.security_trading_snpst_dim sts_dim
    ON sts_dim.security_trading_snpst_dim_id = f.security_trading_snpst_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ==========================================================
-- 9. FACT: vp_fct_investor_account_movement_snpst_flat
-- ==========================================================
-- [O_VP_46] nạp mọi ngày (TRUNCATE + INSERT), không khóa theo ngày chạy ETL: Fact dựng lại toàn bộ mỗi lần chạy vì sự kiện mở/đóng tài khoản có thể khai báo lùi ngày
TRUNCATE TABLE IF EXISTS datamart.vp_fct_investor_account_movement_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.vp_fct_investor_account_movement_snpst_flat
SELECT
    -- From: FCT_INVESTOR_ACCOUNT_MOVEMENT_SNPST
    f.investor_account_movement_snpst_id,
    f.snpst_dt_dim_id,
    f.investor_tp_code,
    f.open_account_count,
    f.close_account_count,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt AS cdr_dt,
    cal.year AS year,
    cal.quarter AS quarter,
    cal.month AS month,
    cal.day_of_week AS day_of_week,
    cal.is_weekend AS is_weekend,
    cal.holiday_flag AS holiday_flag,
    cal.is_trading_date AS is_trading_date

FROM datamart.fct_investor_account_movement_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
;
