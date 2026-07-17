-- ============================================================
-- QLCB Flat Tables — POPULATE
-- Module: Quản lý Chào bán (QLCB)
-- Generated: Phase 3 LLD Datamart
-- 5 bảng: 4 fact + 1 operational
-- ============================================================


-- ============================================================
-- 1. FACT: qlcb_fct_securities_offering_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlcb_fct_securities_offering_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlcb_fct_securities_offering_flat
SELECT
    f.securities_offering_code,
    f.official_letter_dt_dim_id,
    f.public_company_dim_id,
    f.total_expected_amt,
    f.total_collected_amt,
    f.certificate_dt,
    f.official_letter_dt,

    cal.cdr_dt                          AS cdr_dt,

    pc.public_company_code,
    pc.equity_ticker_symbol,
    pc.public_company_nm,
    pc.equity_listing_exchange_code,
    pc.business_line_level_1_code,
    pc.ids_registration_dt,
    pc.public_company_status_code
FROM datamart.fct_securities_offering f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.official_letter_dt_dim_id
LEFT JOIN datamart.public_company_dim pc
    ON pc.public_company_dim_id = f.public_company_dim_id
;


-- ============================================================
-- 2. FACT: qlcb_fct_securities_offering_plan_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlcb_fct_securities_offering_plan_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlcb_fct_securities_offering_plan_flat
SELECT
    f.securities_offering_code,
    f.official_letter_dt_dim_id,
    f.public_company_dim_id,
    f.offering_method_dim_id,
    f.total_expected_amt_snpst,

    cal.cdr_dt                          AS cdr_dt,

    pc.public_company_code,
    pc.equity_ticker_symbol,
    pc.public_company_nm,
    pc.equity_listing_exchange_code,
    pc.business_line_level_1_code,
    pc.ids_registration_dt,
    pc.public_company_status_code,

    om.offering_method_code,
    om.offering_method_nm
FROM datamart.fct_securities_offering_plan f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.official_letter_dt_dim_id
LEFT JOIN datamart.public_company_dim pc
    ON pc.public_company_dim_id = f.public_company_dim_id
LEFT JOIN datamart.offering_method_dim om
    ON om.offering_method_dim_id = f.offering_method_dim_id
;


-- ============================================================
-- 3. FACT: qlcb_fct_securities_offering_result_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlcb_fct_securities_offering_result_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlcb_fct_securities_offering_result_flat
SELECT
    f.securities_offering_code,
    f.official_letter_dt_dim_id,
    f.public_company_dim_id,
    f.offering_method_dim_id,
    f.total_collected_amt,

    cal.cdr_dt                          AS cdr_dt,

    pc.public_company_code,
    pc.equity_ticker_symbol,
    pc.public_company_nm,
    pc.equity_listing_exchange_code,
    pc.business_line_level_1_code,
    pc.ids_registration_dt,
    pc.public_company_status_code,

    om.offering_method_code,
    om.offering_method_nm
FROM datamart.fct_securities_offering_result f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.official_letter_dt_dim_id
LEFT JOIN datamart.public_company_dim pc
    ON pc.public_company_dim_id = f.public_company_dim_id
LEFT JOIN datamart.offering_method_dim om
    ON om.offering_method_dim_id = f.offering_method_dim_id
;


-- ============================================================
-- 4. FACT: qlcb_fct_securities_offering_application_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlcb_fct_securities_offering_application_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlcb_fct_securities_offering_application_flat
SELECT
    f.securities_offering_code,
    f.official_letter_dt_dim_id,
    f.application_status_code,
    f.offering_method_dim_id,

    cal.cdr_dt                          AS cdr_dt,

    om.offering_method_code,
    om.offering_method_nm
FROM datamart.fct_securities_offering_application f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.official_letter_dt_dim_id
LEFT JOIN datamart.offering_method_dim om
    ON om.offering_method_dim_id = f.offering_method_dim_id
;


-- ============================================================
-- 5. OPERATIONAL: qlcb_securities_offering_360_profile_flat
--    Không JOIN dim, không lọc theo ngày (bảng tác nghiệp)
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlcb_securities_offering_360_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlcb_securities_offering_360_profile_flat
SELECT
    o.securities_offering_code,
    o.offering_method_code,
    o.public_company_code,
    o.public_company_nm,
    o.equity_ticker_symbol,
    o.securities_tp_code,
    o.total_registered_quantity,
    o.total_expected_amt,
    o.total_successful_quantity,
    o.total_collected_amt,
    o.certificate_nbr,
    o.certificate_dt,
    o.official_letter_nbr,
    o.official_letter_dt,
    o.capital_usage_plan,
    o.business_line_level_1_code,
    o.equity_listing_exchange_code,
    o.consulting_organization_nm,
    o.audit_organization_nm,
    o.underwriting_organization_nm,
    o.credit_rating_organization_nm,
    o.processor_user_nm_snpst,
    o.successful_ratio_percentage,
    o.offering_price,
    o.employee_quantity,
    o.swap_target,
    o.actual_offering_price,
    o.employee_quantity_result,
    o.capital_src,
    o.src_stm_code
FROM datamart.securities_offering_360_profile o
;
