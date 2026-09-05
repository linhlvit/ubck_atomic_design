-- ============================================================
-- GSTT Flat Tables — POPULATE
-- Module: Giám sát Thị trường (GSTT)
-- Generated: Phase 3 LLD Datamart
-- 3 bảng: 3 fact + 0 operational
-- ETL daily:
--   Fact 1 (Stock Portfolio Snapshot): transaction log theo ngày —
--     DELETE đúng ngày :etl_date (không TRUNCATE) rồi INSERT
--   Fact 2 (Market Index Intraday): transaction/tick log, nhiều dòng/ngày theo
--     Index Time — DELETE đúng ngày :etl_date (không TRUNCATE) rồi INSERT, cho
--     phép append thêm tick mới khi ETL chạy nhiều lần/ngày mà không mất tick cũ
--   Fact 3 (Security Trading Intraday, bổ sung 2026-08-26): transaction/tick log,
--     nhiều dòng/ngày theo Trading Timestamp (trading_tms) — cùng pattern DELETE
--     + INSERT theo :etl_date như Fact 2
--   Bảng cũ (Fact Public Company Shareholding) đã bị loại bỏ — xem ghi chú
--   chi tiết cuối file
-- ============================================================


-- ============================================================
-- 1. FACT: gstt_fct_stock_portfolio_snpst_flat
--    cal: JOIN + DELETE-scoped theo cdr_dt = :etl_date
-- ============================================================
DELETE FROM datamart.gstt_fct_stock_portfolio_snpst_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.gstt_fct_stock_portfolio_snpst_flat
SELECT
    -- From: FACT Stock Portfolio Snapshot
    f.security_trading_snpst_dim_id,
    f.public_company_dim_id,
    f.cdr_dt_dim_id,
    f.index_constituent_dim_id,
    f.total_vol,
    f.total_val,
    f.total_derivative_vol,
    f.total_derivative_val,
    f.total_negotiated_vol,
    f.total_negotiated_val,
    f.foreign_net_vol,
    f.outstanding_share_quantity,
    f.revenue,
    f.net_profit_after_tax,
    f.net_profit_after_tax_ttm,
    f.owner_equity,
    f.foreign_buy_vol,
    f.foreign_sell_vol,
    f.foreign_buy_val,
    f.foreign_sell_val,
    f.proprietary_buy_val,
    f.proprietary_sell_val,
    f.individual_net_val,
    f.domestic_institution_net_val,
    f.proprietary_buy_vol,
    f.proprietary_sell_vol,
    f.bond_trading_vol,
    f.bond_trading_val,
    f.individual_buy_val,
    f.individual_sell_val,
    f.individual_buy_vol,
    f.individual_sell_vol,
    f.domestic_institution_buy_val,
    f.domestic_institution_sell_val,
    f.domestic_institution_buy_vol,
    f.domestic_institution_sell_vol,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt                                     AS cdr_dt,
    cal.is_trading_date                            AS is_trading_date,

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    sec_dim.symbol                                 AS symbol,
    sec_dim.security_full_nm                       AS security_full_nm,
    sec_dim.floor_code                             AS floor_code,
    sec_dim.stock_tp_code                          AS stock_tp_code,
    sec_dim.stock_tp_nm                            AS stock_tp_nm,
    sec_dim.underlying_symbol                      AS underlying_symbol,
    sec_dim.isin_code                              AS isin_code,
    sec_dim.issuer_nm                              AS issuer_nm,
    sec_dim.listed_share_count                     AS listed_share_count,
    sec_dim.first_trading_dt                       AS first_trading_dt,
    sec_dim.last_trading_dt                        AS last_trading_dt,
    sec_dim.issue_dt                               AS issue_dt,
    sec_dim.maturity_dt                            AS maturity_dt,
    sec_dim.fund_tp_code                           AS fund_tp_code,
    sec_dim.covered_warrant_tp_code                AS covered_warrant_tp_code,
    sec_dim.exercise_price                         AS exercise_price,
    sec_dim.exercise_ratio                         AS exercise_ratio,
    sec_dim.exercise_style_code                    AS exercise_style_code,
    sec_dim.put_or_call_code                       AS put_or_call_code,
    sec_dim.contract_multiplier                    AS contract_multiplier,
    sec_dim.maturity_month_year                    AS maturity_month_year,
    sec_dim.coupon_rate                            AS coupon_rate,
    sec_dim.yield                                  AS yield,
    sec_dim.open_price                             AS open_price,
    sec_dim.high_price                             AS high_price,
    sec_dim.low_price                              AS low_price,
    sec_dim.reference_price                        AS reference_price,
    sec_dim.close_price                            AS close_price,
    sec_dim.price_change                           AS price_change,
    sec_dim.src_stm_code                           AS security_trading_snpst_src_stm_code,

    -- From: PUBLIC COMPANY DIMENSION
    pc_dim.public_company_code                     AS public_company_code,
    pc_dim.equity_ticker_symbol                    AS equity_ticker_symbol,
    pc_dim.public_company_nm                       AS public_company_nm,
    pc_dim.equity_listing_exchange_code            AS equity_listing_exchange_code,
    pc_dim.business_line_level_1_code              AS business_line_level_1_code,
    pc_dim.ids_registration_dt                     AS ids_registration_dt,
    pc_dim.public_company_status_code              AS public_company_status_code,
    pc_dim.classification_business_line_nm         AS classification_business_line_nm,
    pc_dim.public_company_english_nm               AS public_company_english_nm,
    pc_dim.enterprise_tp_code                      AS enterprise_tp_code,
    pc_dim.public_company_tp_code                  AS public_company_tp_code,
    pc_dim.head_office_province_nm                 AS head_office_province_nm,
    pc_dim.operating_status_code                   AS operating_status_code,
    pc_dim.has_state_ownership_indicator           AS has_state_ownership_indicator,
    pc_dim.charter_capital_amt                     AS charter_capital_amt,
    pc_dim.first_registration_dt                   AS first_registration_dt,
    pc_dim.latest_registration_dt                  AS latest_registration_dt,
    pc_dim.latest_registration_province_nm         AS latest_registration_province_nm,
    pc_dim.ids_registration_indicator              AS ids_registration_indicator,
    pc_dim.public_company_form_code                AS public_company_form_code,
    pc_dim.former_state_owned_indicator             AS former_state_owned_indicator,
    pc_dim.foreign_direct_investment_indicator     AS foreign_direct_investment_indicator,
    pc_dim.has_parent_company_indicator            AS has_parent_company_indicator,
    pc_dim.has_subsidiary_indicator                AS has_subsidiary_indicator,
    pc_dim.has_joint_venture_indicator              AS has_joint_venture_indicator,
    pc_dim.ipo_company_indicator                   AS ipo_company_indicator,
    pc_dim.src_stm_code                            AS public_company_src_stm_code,

    -- From: INDEX CONSTITUENT DIMENSION
    idx_cons_dim.index_code                        AS index_code,
    idx_cons_dim.index_id                          AS index_id,
    idx_cons_dim.floor_code                        AS index_constituent_floor_code,
    idx_cons_dim.add_dt                            AS add_dt,
    idx_cons_dim.src_stm_code                      AS index_constituent_src_stm_code

FROM datamart.fct_stock_portfolio_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.cdr_dt_dim_id
LEFT JOIN datamart.security_trading_snpst_dim sec_dim
    ON sec_dim.security_trading_snpst_dim_id = f.security_trading_snpst_dim_id
LEFT JOIN datamart.public_company_dim pc_dim
    ON pc_dim.public_company_dim_id = f.public_company_dim_id
LEFT JOIN datamart.index_constituent_dim idx_cons_dim
    ON idx_cons_dim.index_constituent_dim_id = f.index_constituent_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ============================================================
-- 2. FACT: gstt_fct_market_index_intraday_flat
--    cal: JOIN + DELETE-scoped theo cdr_dt = :etl_date (nhiều dòng/ngày theo Index Time)
-- ============================================================
DELETE FROM datamart.gstt_fct_market_index_intraday_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.gstt_fct_market_index_intraday_flat
SELECT
    -- From: FACT Market Index Intraday
    f.market_index_dim_id,
    f.cdr_dt_dim_id,
    f.index_time,
    f.market_index_val_at_time,
    f.total_val_at_time,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt                          AS cdr_dt,

    -- From: MARKET INDEX DIMENSION
    idx_dim.market_id                   AS market_id,
    idx_dim.market_code                 AS market_code,
    idx_dim.index_tp_code               AS index_tp_code,
    idx_dim.tsc_product_group_id        AS tsc_product_group_id,
    idx_dim.market_status_code          AS market_status_code,
    idx_dim.src_stm_code                AS market_index_src_stm_code

FROM datamart.fct_market_index_intraday f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.cdr_dt_dim_id
LEFT JOIN datamart.market_index_dim idx_dim
    ON idx_dim.market_index_dim_id = f.market_index_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ============================================================
-- 3. FACT: gstt_fct_security_trading_intraday_flat
--    cal: JOIN + DELETE-scoped theo cdr_dt = :etl_date (nhiều dòng/ngày theo Trading Timestamp)
-- ============================================================
DELETE FROM datamart.gstt_fct_security_trading_intraday_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.gstt_fct_security_trading_intraday_flat
SELECT
    -- From: FACT Security Trading Intraday
    f.security_trading_snpst_dim_id,
    f.cdr_dt_dim_id,
    f.trading_tms,
    f.open_price_at_time,
    f.high_price_at_time,
    f.low_price_at_time,
    f.close_price_at_time,
    f.cumulative_vol_at_time,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt                          AS cdr_dt,

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    scr_dim.symbol                      AS symbol,
    scr_dim.security_full_nm            AS security_full_nm,
    scr_dim.floor_code                  AS floor_code,
    scr_dim.stock_tp_code               AS stock_tp_code,
    scr_dim.stock_tp_nm                 AS stock_tp_nm,
    scr_dim.src_stm_code                AS security_trading_src_stm_code

FROM datamart.fct_security_trading_intraday f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.cdr_dt_dim_id
LEFT JOIN datamart.security_trading_snpst_dim scr_dim
    ON scr_dim.security_trading_snpst_dim_id = f.security_trading_snpst_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ============================================================
-- Sửa 2026-08-03 (redesign Nhóm 45/48): `Fact Public Company Shareholding` đã loại
-- khỏi HLD — 6/8 KPI Nhóm 45 PENDING theo gating "Chưa có CSDL - Map biểu mẫu".
-- 2 KPI READY còn lại (K_GSTT_100, K_GSTT_104) là thuộc tính Dimension thuần,
-- không qua Fact — flat table chỉ tạo cho Fact/Operational, không tạo riêng cho
-- Dimension độc lập. Nhóm 45/48 không có bảng flat nào ở giai đoạn này.
-- ============================================================
