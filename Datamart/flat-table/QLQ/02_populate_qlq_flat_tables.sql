-- ============================================================
-- QLQ Flat Tables — POPULATE
-- Module: Quản lý Quỹ (Fund Management) — QLQ
-- Generated: Phase 3 LLD Datamart
-- 19 bảng: 6 fact + 13 operational
-- Sửa 2026-10-14: thêm #18 qlq_opr_foreign_fund_management_organization_unit_contract_list_flat (Nhóm 27) và #19 qlq_fund_management_company_staff_trade_rpt_flat (Nhóm 28) — trước đó PENDING
-- Sửa 2026-10-14: thêm #17 qlq_fct_fund_management_rpt_cell_val_flat (Dashboard RPT, 51 KPI READY) — bị bỏ sót ở commit 2f62880d
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
    snpst_cal.cdr_dt              AS snpst_cdr_dt
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
    f.fund_type_id,
    f.fund_count,
    f.src_stm_code,
    snpst_cal.cdr_dt              AS snpst_cdr_dt,
    fund_type_dim.fund_type_code  AS fund_type_code,
    fund_type_dim.fund_type_nm    AS fund_type_nm,
    fund_type_dim.open_fund_indicator AS open_fund_indicator
FROM datamart.fct_investment_fund_count_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.fund_type_dim fund_type_dim
    ON fund_type_dim.fund_type_id = f.fund_type_id
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
    snpst_cal.cdr_dt              AS snpst_cdr_dt
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
    snpst_cal.cdr_dt              AS snpst_cdr_dt
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
    o.operation_status_nm,
    o.legal_representative_nm,
    o.fund_count,
    o.rating_class_code,
    o.total_score_amt,
    o.charter_capital_amt,
    o.certified_practitioner_staff_count,
    o.assets_under_management_amt,
    o.capital_adequacy_ratio,
    o.net_profit_after_tax_amt,
    o.owner_equity_amt,
    o.portfolio_management_contract_count,
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
    o.net_asset_val_amt,
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
    o.investment_fund_short_nm,
    o.fund_tp_code,
    o.fmc_full_nm,
    o.custodian_bank_full_nm,
    o.representative_board_member_count,
    o.manager_count,
    o.outstanding_unit_quantity,
    o.distribution_agent_count,
    o.net_asset_val_amt,
    o.year_to_dt_profit_amt,
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
    o.distributing_fund_count,
    o.trading_account_count,
    o.trading_account_year_to_dt_count,
    o.institution_trading_account_count,
    o.individual_trading_account_count,
    o.foreign_trading_account_count,
    o.institution_holding_account_count,
    o.individual_holding_account_count,
    o.foreign_holding_account_count,
    o.institution_fund_certificate_amt,
    o.individual_fund_certificate_amt,
    o.foreign_fund_certificate_amt,
    o.issued_amt,
    o.issued_year_to_dt_amt,
    o.redeemed_amt,
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
    o.securities_distribution_agent_code,
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
    o.certified_practitioner_staff_count,
    o.capital_adequacy_ratio,
    o.net_profit_after_tax_amt,
    o.owner_equity_amt,
    o.portfolio_management_contract_count,
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

-- ============================================================
-- 15. OPERATIONAL: qlq_opr_investment_fund_distribution_agent_list_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_investment_fund_distribution_agent_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_investment_fund_distribution_agent_list_flat
SELECT
    o.investment_fund_code,
    o.fund_distribution_agent_code,
    o.fund_distribution_agent_full_nm,
    o.src_stm_code
FROM datamart.opr_investment_fund_distribution_agent_list o
;

-- ============================================================
-- 16. OPERATIONAL: qlq_opr_fund_management_company_contract_list_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_fund_management_company_contract_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_fund_management_company_contract_list_flat
SELECT
    o.fmr_submission_code,
    o.dynamic_row_nbr,
    o.investment_fund_code,
    o.fmc_code,
    o.record_tp,
    o.period_tp_code,
    o.period_val,
    o.rpt_year,
    o.version_nbr,
    o.customer_nm,
    o.custody_account_nbr,
    o.contract_market_val_amt,
    o.src_stm_code
FROM datamart.opr_fund_management_company_contract_list o
;


-- ============================================================
-- 17. FACT: qlq_fct_fund_management_rpt_cell_val_flat
--    Nạp tăng dần theo ngày nộp: bản nộp có submitted_dt = ngày chạy ETL (khớp cách nạp Fact ở Gold — O_QLQ_34).
--    Không lọc theo ngày cuối kỳ báo cáo: KPI cần nhiều kỳ và nhiều bản nộp trong cùng bảng (O_QLQ_32).
-- ============================================================
DELETE FROM datamart.qlq_fct_fund_management_rpt_cell_val_flat ON CLUSTER 'my_cluster'
WHERE submitted_dt = :etl_date;
INSERT INTO datamart.qlq_fct_fund_management_rpt_cell_val_flat
SELECT
    f.rpt_period_end_dt_dim_id,
    f.fund_management_rpt_cell_id,
    f.fund_type_id,
    f.open_fund_tp_code,
    f.fund_establishment_license_dt,
    f.fmr_val_code,
    f.fmc_code,
    f.investment_fund_code,
    f.securities_distribution_agent_code,
    f.foreign_fund_management_organization_unit_code,
    f.record_tp,
    f.period_tp_code,
    f.period_val,
    f.rpt_year,
    f.dynamic_row_nbr,
    f.submitted_dt,
    f.cell_val,
    f.cell_numeric_val,
    f.src_stm_code,
    rpt_period_end_cal.cdr_dt     AS rpt_period_end_cdr_dt,
    cell_dim.fmr_sheet_code,
    cell_dim.cell_id,
    cell_dim.fmr_code,
    cell_dim.fmr_nm,
    cell_dim.fmr_tp_code,
    cell_dim.rpt_short_code,
    cell_dim.rpt_group_code,
    cell_dim.stm_object_tp_code,
    cell_dim.cl_fms_fund_tp_code,
    cell_dim.version_nbr,
    cell_dim.legal_basis,
    cell_dim.fmr_sheet_nm,
    cell_dim.sheet_short_code,
    cell_dim.sheet_index,
    cell_dim.investment_portfolio_indicator,
    cell_dim.row_index,
    cell_dim.column_index,
    cell_dim.row_span,
    cell_dim.column_span,
    cell_dim.label_nm,
    cell_dim.row_stt_code,
    cell_dim.row_indicator_code,
    cell_dim.row_indicator_nm,
    cell_dim.row_label_nm,
    cell_dim.column_label_nm,
    fund_type_dim.fund_type_code,
    fund_type_dim.fund_type_nm,
    fund_type_dim.open_fund_indicator
FROM datamart.fct_fund_management_rpt_cell_val f
LEFT JOIN datamart.cdr_dt_dim rpt_period_end_cal
    ON rpt_period_end_cal.cdr_dt_dim_id = f.rpt_period_end_dt_dim_id
LEFT JOIN datamart.fund_management_rpt_cell_dim cell_dim
    ON cell_dim.fund_management_rpt_cell_id = f.fund_management_rpt_cell_id AND cell_dim.ds_rcrd_st = 'ACTIVE'
LEFT JOIN datamart.fund_type_dim fund_type_dim
    ON fund_type_dim.fund_type_id = f.fund_type_id AND fund_type_dim.ds_rcrd_st = 'ACTIVE'
WHERE f.submitted_dt = :etl_date
;


-- ============================================================
-- 18. OPERATIONAL: qlq_opr_foreign_fund_management_organization_unit_contract_list_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_foreign_fund_management_organization_unit_contract_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_foreign_fund_management_organization_unit_contract_list_flat
SELECT
    o.fmr_submission_code,
    o.dynamic_row_nbr,
    o.foreign_fund_management_organization_unit_code,
    o.record_tp,
    o.period_tp_code,
    o.period_val,
    o.rpt_year,
    o.version_nbr,
    o.customer_nm,
    o.custody_account_nbr,
    o.contract_market_val_amt,
    o.src_stm_code
FROM datamart.opr_foreign_fund_management_organization_unit_contract_list o
;


-- ============================================================
-- 19. FACT (report): qlq_fund_management_company_staff_trade_rpt_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_fund_management_company_staff_trade_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_fund_management_company_staff_trade_rpt_flat
SELECT
    o.fmc_employee_code,
    o.trade_dt,
    o.securities_account_nbr,
    o.trade_direction_code,
    o.security_symbol_code,
    o.trade_method_nm,
    o.fmc_code,
    o.identification_nbr,
    o.securities_company_code,
    o.trade_direction_nm,
    o.order_vol,
    o.order_price,
    o.order_amt,
    o.src_stm_code
FROM datamart.fund_management_company_staff_trade_rpt o
;
