-- ============================================================
-- QLKD Flat Tables — POPULATE
-- Module: Quản lý kinh doanh (Hoạt động CTCK) — QLKD
-- Generated: Phase 3 LLD Datamart
-- 14 bảng: 5 fact + 9 operational
-- ETL daily: fact lọc theo WHERE cal.cdr_dt = :etl_date
-- ============================================================


-- ============================================================
-- 1. FACT: qlkd_fct_securities_company_status_snpst_flat
--    cal: JOIN + WHERE cdr_dt = :etl_date
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_fct_securities_company_status_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_fct_securities_company_status_snpst_flat
SELECT
    -- From: FACT Fact Securities Company Status Snapshot
    f.snpst_dt_dim_id,
    f.securities_company_dim_id,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt                      AS cdr_dt,

    -- From: SECURITIES COMPANY DIMENSION
    sc_dim.sc_id                       AS sc_id,
    sc_dim.sc_code                     AS sc_code,
    sc_dim.sc_nm                       AS sc_nm,
    sc_dim.company_tp_code             AS company_tp_code,
    sc_dim.company_status_code         AS company_status_code,
    sc_dim.is_listed_indicator         AS is_listed_indicator,
    sc_dim.stock_exchange_nm           AS stock_exchange_nm

FROM datamart.fct_securities_company_status_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.securities_company_dim sc_dim
    ON sc_dim.securities_company_dim_id = f.securities_company_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ============================================================
-- 2. FACT: qlkd_fct_securities_company_service_registration_flat
--    cal: JOIN + WHERE cdr_dt = :etl_date
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_fct_securities_company_service_registration_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_fct_securities_company_service_registration_flat
SELECT
    -- From: FACT Fact Securities Company Service Registration
    f.registration_dt_dim_id,
    f.securities_company_dim_id,
    f.service_tp_dim_id,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt                      AS cdr_dt,

    -- From: SECURITIES COMPANY DIMENSION
    sc_dim.sc_id                       AS sc_id,
    sc_dim.sc_code                     AS sc_code,
    sc_dim.sc_nm                       AS sc_nm,
    sc_dim.company_tp_code             AS company_tp_code,
    sc_dim.company_status_code         AS company_status_code,
    sc_dim.is_listed_indicator         AS is_listed_indicator,
    sc_dim.stock_exchange_nm           AS stock_exchange_nm,

    -- From: SERVICE TYPE DIMENSION
    svc_dim.cl_service_code             AS cl_service_code,
    svc_dim.cl_service_nm               AS cl_service_nm

FROM datamart.fct_securities_company_service_registration f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.registration_dt_dim_id
LEFT JOIN datamart.securities_company_dim sc_dim
    ON sc_dim.securities_company_dim_id = f.securities_company_dim_id
LEFT JOIN datamart.service_tp_dim svc_dim
    ON svc_dim.service_tp_dim_id = f.service_tp_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ============================================================
-- 3. FACT: qlkd_fct_securities_company_license_condition_snpst_flat
--    cal: JOIN + WHERE cdr_dt = :etl_date
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_fct_securities_company_license_condition_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_fct_securities_company_license_condition_snpst_flat
SELECT
    -- From: FACT Fact Securities Company License Condition Snapshot
    f.snpst_dt_dim_id,
    f.securities_company_dim_id,
    f.indicator_code,
    f.severity_level,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt                      AS cdr_dt,

    -- From: SECURITIES COMPANY DIMENSION
    sc_dim.sc_id                       AS sc_id,
    sc_dim.sc_code                     AS sc_code,
    sc_dim.sc_nm                       AS sc_nm,
    sc_dim.company_tp_code             AS company_tp_code,
    sc_dim.company_status_code         AS company_status_code,
    sc_dim.is_listed_indicator         AS is_listed_indicator,
    sc_dim.stock_exchange_nm           AS stock_exchange_nm

FROM datamart.fct_securities_company_license_condition_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.securities_company_dim sc_dim
    ON sc_dim.securities_company_dim_id = f.securities_company_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ============================================================
-- 4. FACT: qlkd_fct_securities_company_capital_raising_event_flat
--    cal: JOIN + WHERE cdr_dt = :etl_date
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_fct_securities_company_capital_raising_event_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_fct_securities_company_capital_raising_event_flat
SELECT
    -- From: FACT Fact Securities Company Capital Raising Event
    f.event_dt_dim_id,
    f.offering_form_dim_id,
    f.proceeds_collected_amt,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt                      AS cdr_dt,

    -- From: OFFERING FORM DIMENSION
    offer_dim.capital_raising_form_code   AS capital_raising_form_code,
    offer_dim.capital_raising_form_nm     AS capital_raising_form_nm

FROM datamart.fct_securities_company_capital_raising_event f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.event_dt_dim_id
LEFT JOIN datamart.offering_form_dim offer_dim
    ON offer_dim.offering_form_dim_id = f.offering_form_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ============================================================
-- 5. FACT: qlkd_fct_market_index_snpst_flat
--    Sửa 2026-07-24 (datamart-review): Fact nguồn `fct_market_index_snpst` nay populate
--    grain 1 chỉ số × 1 ngày (dùng chung QLKD/NDTNN, trước đây 1 chỉ số × 1 tháng).
--    QLKD (cần số liệu cuối tháng, K_QLKD_88-91) tự filter đúng ngày cuối tháng của
--    :etl_month trên Fact grain-ngày này — không còn nhận nguyên mọi ngày trong tháng.
--    cal: JOIN + WHERE cdr_dt = LAST_DAY(:etl_month)
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_fct_market_index_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_fct_market_index_snpst_flat
SELECT
    -- From: FACT Market Index Snapshot
    f.snpst_dt_dim_id,
    f.market_index_dim_id,
    f.market_index_val,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt                      AS cdr_dt,

    -- From: MARKET INDEX DIMENSION
    idx_dim.market_id               AS market_id,
    idx_dim.market_code             AS market_code

FROM datamart.fct_market_index_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.market_index_dim idx_dim
    ON idx_dim.market_index_dim_id = f.market_index_dim_id
WHERE cal.cdr_dt = LAST_DAY(:etl_month)
;


-- ============================================================
-- 6. OPERATIONAL: qlkd_opr_securities_company_personnel_profile_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_securities_company_personnel_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_securities_company_personnel_profile_flat
SELECT
    -- From: OPERATIONAL Securities Company Personnel Profile
    o.sc_senior_personnel_code,
    o.sc_code,
    o.full_nm,
    o.department,
    o.position_nm,
    o.email,
    o.phone,
    o.work_start_dt,
    o.dismissal_dt,
    o.personnel_status_code,
    o.src_stm_code

FROM datamart.opr_securities_company_personnel_profile o
;


-- ============================================================
-- 7. OPERATIONAL: qlkd_opr_securities_company_organization_unit_profile_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_securities_company_organization_unit_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_securities_company_organization_unit_profile_flat
SELECT
    -- From: OPERATIONAL Securities Company Organization Unit Profile
    o.sc_ou_code,
    o.sc_code,
    o.ou_tp_code,
    o.ou_nm,
    o.adr_val,
    o.decision_dt,
    o.director_nm,
    o.cl_firm_status_code,
    o.src_stm_code

FROM datamart.opr_securities_company_organization_unit_profile o
;


-- ============================================================
-- 8. OPERATIONAL: qlkd_opr_securities_company_compliance_hist_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_securities_company_compliance_hist_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_securities_company_compliance_hist_flat
SELECT
    -- From: OPERATIONAL Securities Company Compliance History
    o.pd_code,
    o.event_tp_code,
    o.form_tp_code,
    o.insp_decision_dt,
    o.decision_nbr,
    o.issued_dt,
    o.violation_behavior_nm,
    o.supplementary_penalty_nm,
    o.remedial_measure_nm,
    o.sc_code,
    o.src_stm_code

FROM datamart.opr_securities_company_compliance_hist o
;


-- ============================================================
-- 9. OPERATIONAL: qlkd_opr_individual_profile_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_individual_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_individual_profile_flat
SELECT
    -- From: OPERATIONAL Individual Profile
    o.sc_senior_personnel_code,
    o.sc_code,
    o.full_nm,
    o.position_nm,
    o.identification_nbr,
    o.license_certificate_nbr,
    o.src_stm_code

FROM datamart.opr_individual_profile o
;


-- ============================================================
-- 10. OPERATIONAL: qlkd_opr_individual_related_party_network_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_individual_related_party_network_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_individual_related_party_network_flat
SELECT
    -- From: OPERATIONAL Individual Related Party Network
    o.sc_insider_related_person_code,
    o.sc_senior_personnel_code,
    o.related_person_full_nm,
    o.rltnp,
    o.representative_position,
    o.identification_nbr,
    o.shares_count,
    o.ownership_ratio,
    o.src_stm_code

FROM datamart.opr_individual_related_party_network o
;


-- ============================================================
-- 11. OPERATIONAL: qlkd_opr_individual_listed_company_role_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_individual_listed_company_role_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_individual_listed_company_role_flat
SELECT
    -- From: OPERATIONAL Individual Listed Company Role
    o.sc_insider_related_person_code,
    o.sc_senior_personnel_code,
    o.sc_code,
    o.representative_position,
    o.shares_count,
    o.src_stm_code

FROM datamart.opr_individual_listed_company_role o
;


-- ============================================================
-- 12. OPERATIONAL: qlkd_opr_individual_trading_account_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_individual_trading_account_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_individual_trading_account_flat
SELECT
    -- From: OPERATIONAL Individual Trading Account
    o.sc_shareholder_code,
    o.sc_code,
    o.trading_account,
    o.shareholder_nm,
    o.src_stm_code

FROM datamart.opr_individual_trading_account o
;


-- ============================================================
-- 13. OPERATIONAL: qlkd_opr_individual_work_hist_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_individual_work_hist_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_individual_work_hist_flat
SELECT
    -- From: OPERATIONAL Individual Work History
    o.sc_senior_personnel_code,
    o.sc_code,
    o.position_nm,
    o.work_start_dt,
    o.resignation_dt,
    o.employment_status_code,
    o.src_stm_code

FROM datamart.opr_individual_work_hist o
;


-- ============================================================
-- 14. OPERATIONAL: qlkd_opr_individual_violation_hist_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_individual_violation_hist_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_individual_violation_hist_flat
SELECT
    -- From: OPERATIONAL Individual Violation History
    o.pd_code,
    o.identification_nbr,
    o.decision_nbr,
    o.issued_dt,
    o.violation_behavior_nm,
    o.penalty_tp_nm,
    o.decision_status_code,
    o.src_stm_code

FROM datamart.opr_individual_violation_hist o
;

