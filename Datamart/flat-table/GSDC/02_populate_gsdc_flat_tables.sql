-- =====================================================================
-- GSDC — Flat Tables (POPULATE)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Fact Public Company Risk Score Snapshot
-- ---------------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.gsdc_fct_public_company_risk_score_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.gsdc_fct_public_company_risk_score_snpst_flat
SELECT
    f.public_company_dim_id,
    f.snpst_dt_dim_id,
    f.evaluation_dt_dim_id,
    f.evaluation_year,
    f.evaluation_month,
    f.total_score_percentage,
    f.compliance_score,
    f.issuance_score,
    f.financial_score,
    f.non_financial_m_score,
    f.credit_rating_score,
    snpst_cal.cdr_dt            AS snpst_cdr_dt,
    evaluation_cal.cdr_dt       AS evaluation_cdr_dt,
    dim.public_company_code,
    dim.equity_ticker_symbol,
    dim.public_company_nm,
    dim.equity_listing_exchange_code,
    dim.business_line_level_1_code,
    dim.ids_registration_dt,
    dim.public_company_status_code,
    dim.classification_business_line_nm,
    dim.public_company_english_nm,
    dim.enterprise_tp_code,
    dim.enterprise_tp_nm,
    dim.public_company_tp_code,
    dim.head_office_province_nm,
    dim.operating_status_code,
    dim.has_state_ownership_indicator,
    dim.charter_capital_amt,
    dim.first_registration_dt,
    dim.latest_registration_dt,
    dim.latest_registration_province_nm,
    dim.ids_registration_indicator,
    dim.public_company_form_code,
    dim.former_state_owned_indicator,
    dim.foreign_direct_investment_indicator,
    dim.has_parent_company_indicator,
    dim.has_subsidiary_indicator,
    dim.has_joint_venture_indicator,
    dim.ipo_company_indicator
FROM datamart.fct_public_company_risk_score_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.cdr_dt_dim evaluation_cal
    ON evaluation_cal.cdr_dt_dim_id = f.evaluation_dt_dim_id
LEFT JOIN datamart.public_company_dim dim
    ON dim.public_company_dim_id = f.public_company_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;

-- ---------------------------------------------------------------------
-- 2. Fact Public Company Compliance Score Snapshot
-- ---------------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.gsdc_fct_public_company_compliance_score_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.gsdc_fct_public_company_compliance_score_snpst_flat
SELECT
    f.public_company_dim_id,
    f.snpst_dt_dim_id,
    f.evaluation_dt_dim_id,
    f.evaluation_year,
    f.evaluation_month,
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
    snpst_cal.cdr_dt            AS snpst_cdr_dt,
    evaluation_cal.cdr_dt       AS evaluation_cdr_dt,
    dim.public_company_code,
    dim.equity_ticker_symbol,
    dim.public_company_nm,
    dim.equity_listing_exchange_code,
    dim.business_line_level_1_code,
    dim.ids_registration_dt,
    dim.public_company_status_code,
    dim.classification_business_line_nm,
    dim.public_company_english_nm,
    dim.enterprise_tp_code,
    dim.enterprise_tp_nm,
    dim.public_company_tp_code,
    dim.head_office_province_nm,
    dim.operating_status_code,
    dim.has_state_ownership_indicator,
    dim.charter_capital_amt,
    dim.first_registration_dt,
    dim.latest_registration_dt,
    dim.latest_registration_province_nm,
    dim.ids_registration_indicator,
    dim.public_company_form_code,
    dim.former_state_owned_indicator,
    dim.foreign_direct_investment_indicator,
    dim.has_parent_company_indicator,
    dim.has_subsidiary_indicator,
    dim.has_joint_venture_indicator,
    dim.ipo_company_indicator
FROM datamart.fct_public_company_compliance_score_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.cdr_dt_dim evaluation_cal
    ON evaluation_cal.cdr_dt_dim_id = f.evaluation_dt_dim_id
LEFT JOIN datamart.public_company_dim dim
    ON dim.public_company_dim_id = f.public_company_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;

-- ---------------------------------------------------------------------
-- 3. Fact Public Company Issuance Score Snapshot
-- ---------------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.gsdc_fct_public_company_issuance_score_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.gsdc_fct_public_company_issuance_score_snpst_flat
SELECT
    f.public_company_dim_id,
    f.snpst_dt_dim_id,
    f.evaluation_dt_dim_id,
    f.evaluation_year,
    f.evaluation_month,
    f.rapid_capital_increase_score,
    f.private_placement_count_score,
    f.public_offering_count_score,
    f.esop_issuance_count_score,
    f.unsecured_bond_ratio_score,
    f.credit_rating_score_issuance,
    f.bond_debt_to_equity_score,
    f.total_issuance_score,
    snpst_cal.cdr_dt            AS snpst_cdr_dt,
    evaluation_cal.cdr_dt       AS evaluation_cdr_dt,
    dim.public_company_code,
    dim.equity_ticker_symbol,
    dim.public_company_nm,
    dim.equity_listing_exchange_code,
    dim.business_line_level_1_code,
    dim.ids_registration_dt,
    dim.public_company_status_code,
    dim.classification_business_line_nm,
    dim.public_company_english_nm,
    dim.enterprise_tp_code,
    dim.enterprise_tp_nm,
    dim.public_company_tp_code,
    dim.head_office_province_nm,
    dim.operating_status_code,
    dim.has_state_ownership_indicator,
    dim.charter_capital_amt,
    dim.first_registration_dt,
    dim.latest_registration_dt,
    dim.latest_registration_province_nm,
    dim.ids_registration_indicator,
    dim.public_company_form_code,
    dim.former_state_owned_indicator,
    dim.foreign_direct_investment_indicator,
    dim.has_parent_company_indicator,
    dim.has_subsidiary_indicator,
    dim.has_joint_venture_indicator,
    dim.ipo_company_indicator
FROM datamart.fct_public_company_issuance_score_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.cdr_dt_dim evaluation_cal
    ON evaluation_cal.cdr_dt_dim_id = f.evaluation_dt_dim_id
LEFT JOIN datamart.public_company_dim dim
    ON dim.public_company_dim_id = f.public_company_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;

-- ---------------------------------------------------------------------
-- 4. Fact Public Company Financial Score Snapshot
-- ---------------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.gsdc_fct_public_company_financial_score_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.gsdc_fct_public_company_financial_score_snpst_flat
SELECT
    f.public_company_dim_id,
    f.snpst_dt_dim_id,
    f.evaluation_dt_dim_id,
    f.evaluation_year,
    f.evaluation_month,
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
    snpst_cal.cdr_dt            AS snpst_cdr_dt,
    evaluation_cal.cdr_dt       AS evaluation_cdr_dt,
    dim.public_company_code,
    dim.equity_ticker_symbol,
    dim.public_company_nm,
    dim.equity_listing_exchange_code,
    dim.business_line_level_1_code,
    dim.ids_registration_dt,
    dim.public_company_status_code,
    dim.classification_business_line_nm,
    dim.public_company_english_nm,
    dim.enterprise_tp_code,
    dim.enterprise_tp_nm,
    dim.public_company_tp_code,
    dim.head_office_province_nm,
    dim.operating_status_code,
    dim.has_state_ownership_indicator,
    dim.charter_capital_amt,
    dim.first_registration_dt,
    dim.latest_registration_dt,
    dim.latest_registration_province_nm,
    dim.ids_registration_indicator,
    dim.public_company_form_code,
    dim.former_state_owned_indicator,
    dim.foreign_direct_investment_indicator,
    dim.has_parent_company_indicator,
    dim.has_subsidiary_indicator,
    dim.has_joint_venture_indicator,
    dim.ipo_company_indicator
FROM datamart.fct_public_company_financial_score_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.cdr_dt_dim evaluation_cal
    ON evaluation_cal.cdr_dt_dim_id = f.evaluation_dt_dim_id
LEFT JOIN datamart.public_company_dim dim
    ON dim.public_company_dim_id = f.public_company_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;

-- ---------------------------------------------------------------------
-- 5. Fact Public Company Non-Financial Score Snapshot
-- ---------------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.gsdc_fct_public_company_nonfinancial_score_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.gsdc_fct_public_company_nonfinancial_score_snpst_flat
SELECT
    f.public_company_dim_id,
    f.snpst_dt_dim_id,
    f.evaluation_dt_dim_id,
    f.evaluation_year,
    f.evaluation_month,
    f.business_registration_status_score,
    f.m_score,
    f.total_nonfinancial_score,
    snpst_cal.cdr_dt            AS snpst_cdr_dt,
    evaluation_cal.cdr_dt       AS evaluation_cdr_dt,
    dim.public_company_code,
    dim.equity_ticker_symbol,
    dim.public_company_nm,
    dim.equity_listing_exchange_code,
    dim.business_line_level_1_code,
    dim.ids_registration_dt,
    dim.public_company_status_code,
    dim.classification_business_line_nm,
    dim.public_company_english_nm,
    dim.enterprise_tp_code,
    dim.enterprise_tp_nm,
    dim.public_company_tp_code,
    dim.head_office_province_nm,
    dim.operating_status_code,
    dim.has_state_ownership_indicator,
    dim.charter_capital_amt,
    dim.first_registration_dt,
    dim.latest_registration_dt,
    dim.latest_registration_province_nm,
    dim.ids_registration_indicator,
    dim.public_company_form_code,
    dim.former_state_owned_indicator,
    dim.foreign_direct_investment_indicator,
    dim.has_parent_company_indicator,
    dim.has_subsidiary_indicator,
    dim.has_joint_venture_indicator,
    dim.ipo_company_indicator
FROM datamart.fct_public_company_nonfinancial_score_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.cdr_dt_dim evaluation_cal
    ON evaluation_cal.cdr_dt_dim_id = f.evaluation_dt_dim_id
LEFT JOIN datamart.public_company_dim dim
    ON dim.public_company_dim_id = f.public_company_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;

-- ---------------------------------------------------------------------
-- 6. Fact Violation Report Snapshot
-- ---------------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.gsdc_fct_violation_rpt_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.gsdc_fct_violation_rpt_snpst_flat
SELECT
    f.public_company_dim_id,
    f.snpst_dt_dim_id,
    f.rpt_year,
    f.rpt_quarter,
    f.rpt_due_count,
    f.rpt_submitted_count,
    snpst_cal.cdr_dt            AS snpst_cdr_dt,
    dim.public_company_code,
    dim.equity_ticker_symbol,
    dim.public_company_nm,
    dim.equity_listing_exchange_code,
    dim.business_line_level_1_code,
    dim.ids_registration_dt,
    dim.public_company_status_code,
    dim.classification_business_line_nm,
    dim.public_company_english_nm,
    dim.enterprise_tp_code,
    dim.enterprise_tp_nm,
    dim.public_company_tp_code,
    dim.head_office_province_nm,
    dim.operating_status_code,
    dim.has_state_ownership_indicator,
    dim.charter_capital_amt,
    dim.first_registration_dt,
    dim.latest_registration_dt,
    dim.latest_registration_province_nm,
    dim.ids_registration_indicator,
    dim.public_company_form_code,
    dim.former_state_owned_indicator,
    dim.foreign_direct_investment_indicator,
    dim.has_parent_company_indicator,
    dim.has_subsidiary_indicator,
    dim.has_joint_venture_indicator,
    dim.ipo_company_indicator
FROM datamart.fct_violation_rpt_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.public_company_dim dim
    ON dim.public_company_dim_id = f.public_company_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;

-- ---------------------------------------------------------------------
-- 7. Fact Public Company Financial Report Value
-- ---------------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.gsdc_fct_public_company_financial_rpt_val_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.gsdc_fct_public_company_financial_rpt_val_flat
SELECT
    f.public_company_dim_id,
    f.financial_rpt_catalog_dim_id,
    f.snpst_dt_dim_id,
    f.industry_dim_id,
    f.rpt_year,
    f.rpt_quarter,
    f.row_code,
    f.column_code,
    f.data_val,
    snpst_cal.cdr_dt            AS snpst_cdr_dt,
    dim.public_company_code,
    dim.equity_ticker_symbol,
    dim.public_company_nm,
    dim.equity_listing_exchange_code,
    dim.ids_registration_dt,
    dim.public_company_status_code,
    dim.public_company_english_nm,
    dim.enterprise_tp_code,
    dim.enterprise_tp_nm,
    dim.public_company_tp_code,
    dim.head_office_province_nm,
    dim.operating_status_code,
    dim.has_state_ownership_indicator,
    dim.charter_capital_amt,
    dim.first_registration_dt,
    dim.latest_registration_dt,
    dim.latest_registration_province_nm,
    dim.ids_registration_indicator,
    dim.public_company_form_code,
    dim.former_state_owned_indicator,
    dim.foreign_direct_investment_indicator,
    dim.has_parent_company_indicator,
    dim.has_subsidiary_indicator,
    dim.has_joint_venture_indicator,
    dim.ipo_company_indicator,
    industry.industry_code,
    industry.industry_nm,
    catalog_dim.financial_rpt_catalog_code,
    catalog_dim.financial_rpt_catalog_nm,
    catalog_dim.financial_rpt_catalog_tp_code,
    catalog_dim.enterprise_tp_code       AS fr_catalog_enterprise_tp_code,
    catalog_dim.row_description_reference,
    catalog_dim.column_description_reference
FROM datamart.fct_public_company_financial_rpt_val f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.public_company_dim dim
    ON dim.public_company_dim_id = f.public_company_dim_id
LEFT JOIN datamart.industry_dim industry
    ON industry.industry_dim_id = f.industry_dim_id
LEFT JOIN datamart.financial_rpt_catalog_dim catalog_dim
    ON catalog_dim.financial_rpt_catalog_dim_id = f.financial_rpt_catalog_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;

-- ---------------------------------------------------------------------
-- 8. Public Company Regulatory Compliance Report (Fact-report, không JOIN, không WHERE lọc ngày)
-- ---------------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.gsdc_public_company_regulatory_compliance_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.gsdc_public_company_regulatory_compliance_rpt_flat
SELECT
    o.equity_listing_exchange_code,
    o.rpt_year,
    o.rpt_quarter,
    o.company_count,
    o.rpt_due_count,
    o.rpt_submitted_count,
    o.profitable_company_count_year_n,
    o.profitable_company_count_year_n1,
    o.src_stm_code
FROM datamart.public_company_regulatory_compliance_rpt o
;

-- ---------------------------------------------------------------------
-- 9. Public Company Industry Financial Report (Fact-report, không JOIN, không WHERE lọc ngày)
-- ---------------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.gsdc_public_company_industry_financial_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.gsdc_public_company_industry_financial_rpt_flat
SELECT
    o.business_line_level_1_code,
    o.business_line_level_1_name,
    o.rpt_year,
    o.net_revenue_amt_year_n,
    o.net_profit_amt_year_n,
    o.roa_percentage_year_n,
    o.roe_percentage_year_n,
    o.net_revenue_amt_year_n1,
    o.net_profit_amt_year_n1,
    o.roa_percentage_year_n1,
    o.roe_percentage_year_n1,
    o.src_stm_code
FROM datamart.public_company_industry_financial_rpt o
;

-- ---------------------------------------------------------------------
-- 10. Public Company Multi-Period Financial Report (Fact-report, không JOIN, không WHERE lọc ngày)
-- ---------------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.gsdc_public_company_multi_period_financial_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.gsdc_public_company_multi_period_financial_rpt_flat
SELECT
    o.rpt_year,
    o.total_asset_amt_year_n,
    o.total_liability_amt_year_n,
    o.equity_amt_year_n,
    o.charter_capital_amt_year_n,
    o.net_profit_amt_year_n,
    o.roa_percentage_year_n,
    o.roe_percentage_year_n,
    o.total_asset_amt_year_n1,
    o.total_liability_amt_year_n1,
    o.equity_amt_year_n1,
    o.charter_capital_amt_year_n1,
    o.net_profit_amt_year_n1,
    o.roa_percentage_year_n1,
    o.roe_percentage_year_n1,
    o.total_asset_amt_year_n2,
    o.total_liability_amt_year_n2,
    o.equity_amt_year_n2,
    o.charter_capital_amt_year_n2,
    o.net_profit_amt_year_n2,
    o.roa_percentage_year_n2,
    o.roe_percentage_year_n2,
    o.src_stm_code
FROM datamart.public_company_multi_period_financial_rpt o
;

-- ---------------------------------------------------------------------
-- 11. Public Company Exchange Financial Summary Report (Fact-report, không JOIN, không WHERE lọc ngày)
-- ---------------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.gsdc_public_company_exchange_financial_summary_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.gsdc_public_company_exchange_financial_summary_rpt_flat
SELECT
    o.equity_listing_exchange_code,
    o.rpt_year,
    o.rpt_quarter,
    o.total_asset_amt,
    o.total_asset_yoy,
    o.inventory_amt,
    o.inventory_yoy,
    o.total_liability_amt,
    o.total_liability_yoy,
    o.equity_amt,
    o.equity_yoy,
    o.contributed_capital_amt,
    o.contributed_capital_yoy,
    o.undistributed_profit_amt,
    o.undistributed_profit_yoy,
    o.net_revenue_amt,
    o.net_revenue_yoy,
    o.pre_tax_profit_amt,
    o.pre_tax_profit_yoy,
    o.net_profit_amt,
    o.net_profit_yoy,
    o.roa_percentage,
    o.roa_yoy_difference,
    o.roe_percentage,
    o.roe_yoy_difference,
    o.src_stm_code
FROM datamart.public_company_exchange_financial_summary_rpt o
;

INSERT INTO datamart.gsdc_public_company_financial_yoy_rpt_flat
SELECT
    o.equity_listing_exchange_code,
    o.rpt_year,
    o.rpt_quarter,
    o.total_asset_yoy,
    o.total_liability_yoy,
    o.equity_yoy,
    o.contributed_capital_yoy,
    o.net_profit_yoy,
    o.inventory_yoy,
    o.net_revenue_yoy,
    o.undistributed_profit_yoy,
    o.receivable_yoy,
    o.cash_and_equivalent_yoy,
    o.roa_yoy,
    o.roe_yoy,
    o.debt_to_equity_yoy,
    o.src_stm_code
FROM datamart.public_company_financial_yoy_rpt o
;
