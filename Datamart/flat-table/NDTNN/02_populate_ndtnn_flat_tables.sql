-- ============================================================
-- NDTNN Flat Tables — POPULATE
-- Module: Nhà Đầu Tư Nước Ngoài — NDTNN
-- Generated: Phase 3 LLD Datamart
-- 5 bảng: 3 fact + 2 operational
-- ETL daily: fact lọc theo WHERE cal.cdr_dt = :etl_date (bảng có FK Calendar Date)
--            fact report lọc trực tiếp theo WHERE f.report_dt = :etl_date (không FK Calendar Date)
-- 2 fact report (statistics_rpt, detail_rpt) là ETL append-only theo Report
-- Date (xem HLD O_NDTNN_31b) — KHÔNG TRUNCATE, chỉ DELETE đúng ngày :etl_date
-- (idempotent re-run) rồi INSERT lại, giữ nguyên lịch sử các ngày report khác.
-- ============================================================


-- ============================================================
-- 1. FACT: ndtnn_fct_securities_foreign_trading_snpst_flat
--    trade_cal: JOIN + WHERE cdr_dt = :etl_date
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.ndtnn_fct_securities_foreign_trading_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.ndtnn_fct_securities_foreign_trading_snpst_flat
SELECT
    -- From: FACT Fact Securities Foreign Trading Snapshot
    f.trade_dt_dim_id,
    f.securities_dim_id,
    f.public_company_dim_id,
    f.foreign_buy_val,
    f.foreign_sell_val,
    f.total_market_val,

    -- From: CALENDAR DATE DIMENSION
    trade_cal.cdr_dt                   AS trade_cdr_dt,

    -- From: SECURITIES DIMENSION
    sec_dim.symbol                     AS symbol,
    sec_dim.security_full_nm           AS security_full_nm,
    sec_dim.stock_tp_code              AS stock_tp_code,
    sec_dim.floor_code                 AS floor_code,
    sec_dim.listed_share_count         AS listed_share_count,
    sec_dim.total_listing_vol          AS total_listing_vol,
    sec_dim.underlying_symbol          AS underlying_symbol,
    sec_dim.issuer_nm                  AS issuer_nm,
    sec_dim.listing_dt                 AS listing_dt,
    sec_dim.symbol_status_code         AS symbol_status_code,
    sec_dim.src_stm_code                AS securities_src_stm_code,

    -- From: PUBLIC COMPANY DIMENSION
    pc_dim.public_company_code             AS public_company_code,
    pc_dim.equity_ticker_symbol            AS equity_ticker_symbol,
    pc_dim.public_company_nm               AS public_company_nm,
    pc_dim.equity_listing_exchange_code    AS equity_listing_exchange_code,
    pc_dim.business_line_level_1_code      AS business_line_level_1_code,
    pc_dim.ids_registration_dt             AS ids_registration_dt,
    pc_dim.public_company_status_code      AS public_company_status_code,
    pc_dim.classification_business_line_nm AS classification_business_line_nm,
    pc_dim.public_company_english_nm       AS public_company_english_nm,
    pc_dim.enterprise_tp_code              AS enterprise_tp_code,
    pc_dim.public_company_tp_code          AS public_company_tp_code,
    pc_dim.head_office_province_nm         AS head_office_province_nm,
    pc_dim.operating_status_code           AS operating_status_code,
    pc_dim.has_state_ownership_indicator   AS has_state_ownership_indicator,
    pc_dim.charter_capital_amt             AS charter_capital_amt,
    pc_dim.first_registration_dt           AS first_registration_dt,
    pc_dim.latest_registration_dt          AS latest_registration_dt,
    pc_dim.latest_registration_province_nm AS latest_registration_province_nm,
    pc_dim.ids_registration_indicator      AS ids_registration_indicator,
    pc_dim.public_company_form_code        AS public_company_form_code,
    pc_dim.former_state_owned_indicator    AS former_state_owned_indicator,
    pc_dim.foreign_direct_investment_indicator AS foreign_direct_investment_indicator,
    pc_dim.has_parent_company_indicator    AS has_parent_company_indicator,
    pc_dim.has_subsidiary_indicator        AS has_subsidiary_indicator,
    pc_dim.has_joint_venture_indicator     AS has_joint_venture_indicator,
    pc_dim.ipo_company_indicator           AS ipo_company_indicator,
    pc_dim.src_stm_code                    AS public_company_src_stm_code

FROM datamart.fct_securities_foreign_trading_snpst f
JOIN datamart.cdr_dt_dim trade_cal
    ON trade_cal.cdr_dt_dim_id = f.trade_dt_dim_id
LEFT JOIN datamart.securities_dim sec_dim
    ON sec_dim.securities_dim_id = f.securities_dim_id
LEFT JOIN datamart.public_company_dim pc_dim
    ON pc_dim.public_company_dim_id = f.public_company_dim_id
WHERE trade_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 2. FACT (report): ndtnn_foreign_investor_trading_statistics_rpt_flat
--    Không FK Calendar Date — lọc trực tiếp trên report_dt
-- ============================================================
DELETE FROM datamart.ndtnn_foreign_investor_trading_statistics_rpt_flat ON CLUSTER 'my_cluster'
WHERE report_dt = :etl_date;
INSERT INTO datamart.ndtnn_foreign_investor_trading_statistics_rpt_flat
SELECT
    -- From: FACT Foreign Investor Trading Statistics Report
    f.report_dt,
    f.security_tp_group,
    f.buy_val,
    f.sell_val,
    f.src_stm_code

FROM datamart.foreign_investor_trading_statistics_rpt f
WHERE f.report_dt = :etl_date
;


-- ============================================================
-- 3. FACT (report): ndtnn_foreign_investor_trading_detail_rpt_flat
--    Không FK Calendar Date — lọc trực tiếp trên report_dt
-- ============================================================
DELETE FROM datamart.ndtnn_foreign_investor_trading_detail_rpt_flat ON CLUSTER 'my_cluster'
WHERE report_dt = :etl_date;
INSERT INTO datamart.ndtnn_foreign_investor_trading_detail_rpt_flat
SELECT
    -- From: FACT Foreign Investor Trading Detail Report
    f.report_dt,
    f.account_nbr,
    f.symbol,
    f.trade_direction_code,
    f.account_holder_nm,
    f.execution_vol,
    f.execution_val,
    f.src_stm_code

FROM datamart.foreign_investor_trading_detail_rpt f
WHERE f.report_dt = :etl_date
;


-- ============================================================
-- 4. OPERATIONAL: ndtnn_opr_foreign_investor_360_profile_flat
--    Không JOIN, không lọc ngày
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.ndtnn_opr_foreign_investor_360_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.ndtnn_opr_foreign_investor_360_profile_flat
SELECT
    -- From: OPERATIONAL Operational Foreign Investor 360 Profile
    o.investor_code,
    o.investor_nm,
    o.nationality_code,
    o.investor_tp_code,
    o.director_nm,
    o.custodian_bank_nm,
    o.src_stm_code

FROM datamart.opr_foreign_investor_360_profile o
;


-- ============================================================
-- 5. OPERATIONAL: ndtnn_opr_investor_compliance_hist_flat
--    Không JOIN, không lọc ngày
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.ndtnn_opr_investor_compliance_hist_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.ndtnn_opr_investor_compliance_hist_flat
SELECT
    -- From: OPERATIONAL Operational Investor Compliance History
    o.investor_compliance_hist_code,
    o.subject_nm,
    o.issued_dt,
    o.penalty_tp_nm,
    o.description,
    o.life_cycle_status_code,
    o.src_stm_code

FROM datamart.opr_investor_compliance_hist o
;
