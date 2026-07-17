-- ============================================================
-- GSDC Flat Tables — POPULATE
-- Module: Giám sát Công ty Đại chúng (GSDC)
-- Generated: Phase 3 LLD Datamart
-- 6 bảng: 6 fact + 0 operational
-- ETL daily: fact lọc theo WHERE cal.cdr_dt = :etl_date
-- ============================================================


-- ============================================================
-- 1. FACT: gsdc_fct_public_company_risk_score_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.gsdc_fct_public_company_risk_score_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.gsdc_fct_public_company_risk_score_snpst_flat
SELECT
    -- From: FACT Public Company Risk Score Snapshot
    f.fct_public_company_risk_score_snpst_id,
    f.public_company_dim_id,
    f.cdr_dt_dim_id,
    f.total_score_percentage,
    f.compliance_score,
    f.issuance_score,
    f.financial_score,
    f.non_financial_m_score,
    f.credit_rating_score,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt                          AS cdr_dt,

    -- From: PUBLIC COMPANY DIMENSION
    pc_dim.public_company_code                       AS public_company_code,
    pc_dim.equity_ticker_symbol         AS equity_ticker_symbol,
    pc_dim.public_company_nm                        AS public_company_nm,
    pc_dim.equity_listing_exchange_code AS equity_listing_exchange_code,
    pc_dim.business_line_level_1_code   AS business_line_level_1_code,
    pc_dim.ids_registration_dt          AS ids_registration_dt,
    pc_dim.public_company_status_code               AS public_company_status_code
FROM datamart.gsdc_fct_public_company_risk_score_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.cdr_dt_dim_id
LEFT JOIN datamart.public_company_dim pc_dim
    ON pc_dim.public_company_dim_id = f.public_company_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ============================================================
-- 2. FACT: gsdc_fct_public_company_compliance_score_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.gsdc_fct_public_company_compliance_score_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.gsdc_fct_public_company_compliance_score_snpst_flat
SELECT
    -- From: FACT Public Company Compliance Score Snapshot
    f.fct_public_company_compliance_score_snpst_id,
    f.public_company_dim_id,
    f.cdr_dt_dim_id,
    f.disclosure_bctc_score,
    f.disclosure_bctn_score,
    f.disclosure_governance_report_score,
    f.disclosure_ceo_change_score,
    f.violation_ubck_score,
    f.violation_other_score,
    f.charter_regulation_score,
    f.annual_meeting_count_score,
    f.independent_board_member_count_score,
    f.non_executive_board_member_count_score,
    f.board_member_qualification_score,
    f.supervisory_board_count_score,
    f.capital_use_progress_report_score,
    f.capital_use_plan_change_score,
    f.total_compliance_score,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt                          AS cdr_dt,

    -- From: PUBLIC COMPANY DIMENSION
    pc_dim.public_company_code                       AS public_company_code,
    pc_dim.equity_ticker_symbol         AS equity_ticker_symbol,
    pc_dim.public_company_nm                        AS public_company_nm,
    pc_dim.equity_listing_exchange_code AS equity_listing_exchange_code,
    pc_dim.business_line_level_1_code   AS business_line_level_1_code,
    pc_dim.ids_registration_dt          AS ids_registration_dt,
    pc_dim.public_company_status_code               AS public_company_status_code
FROM datamart.gsdc_fct_public_company_compliance_score_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.cdr_dt_dim_id
LEFT JOIN datamart.public_company_dim pc_dim
    ON pc_dim.public_company_dim_id = f.public_company_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ============================================================
-- 3. FACT: gsdc_fct_public_company_issuance_score_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.gsdc_fct_public_company_issuance_score_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.gsdc_fct_public_company_issuance_score_snpst_flat
SELECT
    -- From: FACT Public Company Issuance Score Snapshot
    f.fct_public_company_issuance_score_snpst_id,
    f.public_company_dim_id,
    f.cdr_dt_dim_id,
    f.rapid_capital_increase_score,
    f.private_placement_count_score,
    f.public_offering_count_score,
    f.esop_issuance_count_score,
    f.unsecured_bond_ratio_score,
    f.credit_rating_score_issuance,
    f.bond_debt_to_equity_score,
    f.total_issuance_score,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt                          AS cdr_dt,

    -- From: PUBLIC COMPANY DIMENSION
    pc_dim.public_company_code                       AS public_company_code,
    pc_dim.equity_ticker_symbol         AS equity_ticker_symbol,
    pc_dim.public_company_nm                        AS public_company_nm,
    pc_dim.equity_listing_exchange_code AS equity_listing_exchange_code,
    pc_dim.business_line_level_1_code   AS business_line_level_1_code,
    pc_dim.ids_registration_dt          AS ids_registration_dt,
    pc_dim.public_company_status_code               AS public_company_status_code
FROM datamart.gsdc_fct_public_company_issuance_score_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.cdr_dt_dim_id
LEFT JOIN datamart.public_company_dim pc_dim
    ON pc_dim.public_company_dim_id = f.public_company_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ============================================================
-- 4. FACT: gsdc_fct_public_company_financial_score_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.gsdc_fct_public_company_financial_score_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.gsdc_fct_public_company_financial_score_snpst_flat
SELECT
    -- From: FACT Public Company Financial Score Snapshot
    f.fct_public_company_financial_score_snpst_id,
    f.public_company_dim_id,
    f.cdr_dt_dim_id,
    f.audit_opinion_score,
    f.roa_score,
    f.operating_cash_flow_score,
    f.current_ratio_score,
    f.ebit_interest_coverage_score,
    f.debt_to_equity_score,
    f.equity_score,
    f.roe_score,
    f.financial_revenue_to_profit_score,
    f.other_revenue_to_profit_score,
    f.total_financial_score,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt                          AS cdr_dt,

    -- From: PUBLIC COMPANY DIMENSION
    pc_dim.public_company_code                       AS public_company_code,
    pc_dim.equity_ticker_symbol         AS equity_ticker_symbol,
    pc_dim.public_company_nm                        AS public_company_nm,
    pc_dim.equity_listing_exchange_code AS equity_listing_exchange_code,
    pc_dim.business_line_level_1_code   AS business_line_level_1_code,
    pc_dim.ids_registration_dt          AS ids_registration_dt,
    pc_dim.public_company_status_code               AS public_company_status_code
FROM datamart.gsdc_fct_public_company_financial_score_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.cdr_dt_dim_id
LEFT JOIN datamart.public_company_dim pc_dim
    ON pc_dim.public_company_dim_id = f.public_company_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ============================================================
-- 5. FACT: gsdc_fct_public_company_nonfinancial_score_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.gsdc_fct_public_company_nonfinancial_score_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.gsdc_fct_public_company_nonfinancial_score_snpst_flat
SELECT
    -- From: FACT Public Company Non-Financial Score Snapshot
    f.fct_public_company_nonfinancial_score_snpst_id,
    f.public_company_dim_id,
    f.cdr_dt_dim_id,
    f.business_registration_status_score,
    f.m_score,
    f.total_nonfinancial_score,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt                          AS cdr_dt,

    -- From: PUBLIC COMPANY DIMENSION
    pc_dim.public_company_code                       AS public_company_code,
    pc_dim.equity_ticker_symbol         AS equity_ticker_symbol,
    pc_dim.public_company_nm                        AS public_company_nm,
    pc_dim.equity_listing_exchange_code AS equity_listing_exchange_code,
    pc_dim.business_line_level_1_code   AS business_line_level_1_code,
    pc_dim.ids_registration_dt          AS ids_registration_dt,
    pc_dim.public_company_status_code               AS public_company_status_code
FROM datamart.gsdc_fct_public_company_nonfinancial_score_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.cdr_dt_dim_id
LEFT JOIN datamart.public_company_dim pc_dim
    ON pc_dim.public_company_dim_id = f.public_company_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ============================================================
-- 6. FACT: gsdc_fct_public_company_financial_summary_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.gsdc_fct_public_company_financial_summary_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.gsdc_fct_public_company_financial_summary_snpst_flat
SELECT
    -- From: FACT Public Company Financial Summary Snapshot
    f.fct_public_company_financial_summary_snpst_id,
    f.public_company_dim_id,
    f.cdr_dt_dim_id,
    f.submission_deadline_dt,
    f.submission_dt,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt                          AS cdr_dt,

    -- From: PUBLIC COMPANY DIMENSION
    pc_dim.public_company_code                       AS public_company_code,
    pc_dim.equity_ticker_symbol         AS equity_ticker_symbol,
    pc_dim.public_company_nm                        AS public_company_nm,
    pc_dim.equity_listing_exchange_code AS equity_listing_exchange_code,
    pc_dim.business_line_level_1_code   AS business_line_level_1_code,
    pc_dim.ids_registration_dt          AS ids_registration_dt,
    pc_dim.public_company_status_code               AS public_company_status_code
FROM datamart.gsdc_fct_public_company_financial_summary_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.cdr_dt_dim_id
LEFT JOIN datamart.public_company_dim pc_dim
    ON pc_dim.public_company_dim_id = f.public_company_dim_id
WHERE cal.cdr_dt = :etl_date
;
