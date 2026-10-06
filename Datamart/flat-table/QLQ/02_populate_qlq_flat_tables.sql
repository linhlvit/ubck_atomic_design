-- ============================================================
-- QLQ Flat Tables — POPULATE
-- Module: Quản lý Quỹ (Fund Management) — QLQ
-- Generated: Phase 3 LLD Datamart
-- 14 bảng: 5 fact + 9 operational
-- Tham số ETL hàng ngày: :etl_date (không dùng {etl_date}/$etl_date/hardcode)
-- ============================================================

-- ============================================================
-- 1. FACT: qlq_fct_fund_management_company_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_fct_fund_management_company_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_fct_fund_management_company_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.investment_fund_count,
    f.active_fund_management_company_count,
    f.foreign_fund_management_organization_unit_count,
    f.active_foreign_fund_management_organization_unit_count,
    f.pending_closure_foreign_fund_management_organization_unit_count,
    f.closed_foreign_fund_management_organization_unit_count,
    f.custodian_bank_count,
    snpst_cal.cdr_dt              AS cdr_dt
FROM datamart.fct_fund_management_company_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 2. FACT: qlq_fct_investment_fund_count_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_fct_investment_fund_count_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_fct_investment_fund_count_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.fund_tp_cl_dim_id,
    f.fund_count,
    f.src_stm_code,
    snpst_cal.cdr_dt              AS cdr_dt,
    fund_tp_dim.schema_code       AS schema_code,
    fund_tp_dim.schema_nm         AS schema_nm,
    fund_tp_dim.cl_code           AS cl_code,
    fund_tp_dim.cl_nm             AS cl_nm,
    fund_tp_dim.cl_nm_english     AS cl_nm_english,
    fund_tp_dim.cl_description    AS cl_description
FROM datamart.fct_investment_fund_count_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.cl_dim fund_tp_dim
    ON fund_tp_dim.cl_dim_id = f.fund_tp_cl_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 3. FACT: qlq_fct_investment_fund_ccq_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_fct_investment_fund_ccq_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_fct_investment_fund_ccq_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.fund_tp_cl_dim_id,
    f.outstanding_unit_quantity,
    f.src_stm_code,
    snpst_cal.cdr_dt              AS cdr_dt,
    fund_tp_dim.schema_code       AS schema_code,
    fund_tp_dim.schema_nm         AS schema_nm,
    fund_tp_dim.cl_code           AS cl_code,
    fund_tp_dim.cl_nm             AS cl_nm,
    fund_tp_dim.cl_nm_english     AS cl_nm_english,
    fund_tp_dim.cl_description    AS cl_description
FROM datamart.fct_investment_fund_ccq_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.cl_dim fund_tp_dim
    ON fund_tp_dim.cl_dim_id = f.fund_tp_cl_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 4. FACT: qlq_fct_fund_distribution_agent_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_fct_fund_distribution_agent_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_fct_fund_distribution_agent_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.distribution_agent_count,
    snpst_cal.cdr_dt              AS cdr_dt
FROM datamart.fct_fund_distribution_agent_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 5. FACT: qlq_fct_foreign_fund_management_organization_unit_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_fct_foreign_fund_management_organization_unit_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_fct_foreign_fund_management_organization_unit_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.branch_count,
    snpst_cal.cdr_dt              AS cdr_dt
FROM datamart.fct_foreign_fund_management_organization_unit_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 6. OPERATIONAL: qlq_opr_fund_management_company_profile_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_fund_management_company_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_fund_management_company_profile_flat
SELECT
    o.fmc_code,
    o.fmc_full_nm,
    o.fmc_short_nm,
    o.fund_count,
    o.rank_index,
    o.total_score_amt,
    o.charter_capital_amt,
    o.src_stm_code
FROM datamart.opr_fund_management_company_profile o
;


-- ============================================================
-- 7. OPERATIONAL: qlq_opr_fund_management_company_fund_list_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_fund_management_company_fund_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_fund_management_company_fund_list_flat
SELECT
    o.investment_fund_code,
    o.fmc_id,
    o.fmc_code,
    o.investment_fund_full_nm,
    o.fund_tp_code,
    o.src_stm_code
FROM datamart.opr_fund_management_company_fund_list o
;


-- ============================================================
-- 8. OPERATIONAL: qlq_opr_investment_fund_profile_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_investment_fund_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_investment_fund_profile_flat
SELECT
    o.investment_fund_code,
    o.investment_fund_full_nm,
    o.fund_tp_code,
    o.fmc_short_nm,
    o.custodian_bank_full_nm,
    o.representative_board_member_count,
    o.manager_count,
    o.outstanding_unit_quantity,
    o.src_stm_code
FROM datamart.opr_investment_fund_profile o
;


-- ============================================================
-- 9. OPERATIONAL: qlq_opr_investment_fund_representative_board_member_list_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_investment_fund_representative_board_member_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_investment_fund_representative_board_member_list_flat
SELECT
    o.investment_fund_representative_board_member_code,
    o.investment_fund_id,
    o.investment_fund_code,
    o.board_member_full_nm,
    o.src_stm_code
FROM datamart.opr_investment_fund_representative_board_member_list o
;


-- ============================================================
-- 10. OPERATIONAL: qlq_opr_investment_fund_manager_list_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_investment_fund_manager_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_investment_fund_manager_list_flat
SELECT
    o.investment_fund_code,
    o.fmc_employee_code,
    o.fmc_employee_full_nm,
    o.src_stm_code
FROM datamart.opr_investment_fund_manager_list o
;


-- ============================================================
-- 11. OPERATIONAL: qlq_opr_fund_distribution_agent_profile_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_fund_distribution_agent_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_fund_distribution_agent_profile_flat
SELECT
    o.securities_distribution_agent_code,
    o.securities_distribution_agent_full_nm,
    o.license_nbr,
    o.license_dt,
    o.address,
    o.active_status_flag,
    o.termination_dt,
    o.src_stm_code
FROM datamart.opr_fund_distribution_agent_profile o
;


-- ============================================================
-- 12. OPERATIONAL: qlq_opr_fund_distribution_agent_fund_list_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_fund_distribution_agent_fund_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_fund_distribution_agent_fund_list_flat
SELECT
    o.fund_distribution_agent_code,
    o.investment_fund_code,
    o.investment_fund_full_nm,
    o.src_stm_code
FROM datamart.opr_fund_distribution_agent_fund_list o
;


-- ============================================================
-- 13. OPERATIONAL: qlq_opr_foreign_fund_management_organization_unit_profile_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_foreign_fund_management_organization_unit_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_foreign_fund_management_organization_unit_profile_flat
SELECT
    o.foreign_fund_management_organization_unit_code,
    o.foreign_fund_management_organization_unit_full_nm,
    o.foreign_fund_management_organization_unit_short_nm,
    o.director_full_nm,
    o.src_stm_code
FROM datamart.opr_foreign_fund_management_organization_unit_profile o
;


-- ============================================================
-- 14. OPERATIONAL: qlq_opr_fund_management_report_sheet_list_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_fund_management_report_sheet_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_fund_management_report_sheet_list_flat
SELECT
    o.fmr_sheet_code,
    o.fmr_code,
    o.fmr_nm,
    o.fmr_tp_code,
    o.rpt_short_code,
    o.fmr_sheet_nm,
    o.sheet_short_code,
    o.src_stm_code
FROM datamart.opr_fund_management_report_sheet_list o
;
