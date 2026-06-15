-- =============================================================================
-- PTTT (Phân tích thị trường) — Populate Flat Tables
-- Pattern: TRUNCATE + INSERT INTO SELECT ... LEFT JOIN
-- Calendar Date Dimension: datamart.pttt_calendar_date_dimension
-- =============================================================================


-- =============================================================================
-- 1. pttt_fct_mkt_rsk_snpst_flat
-- =============================================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_mkt_rsk_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_mkt_rsk_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.snpst_dt,
    f.vol_30d,
    f.z_scr_vol,
    f.z_scr_lqdt,
    f.z_scr_mrgn,
    f.z_scr_ir,
    f.z_scr_frgn_flw,
    f.mcap_total_bil_vnd,
    f.mrgn_mcap_rto_pct,
    f.wgt_vol,
    f.wgt_lqdt,
    f.wgt_mrgn,
    f.wgt_ir,
    f.wgt_frgn_flw,
    f.wgt_eqty_rse,
    f.sentmnt_indx,
    f.sentmnt_st,
    f.mrgn_tntn_pct,
    f.mrgn_tntn_st,
    f.systmc_vol_pct,
    f.systmc_vol_st,
    f.tdg_val_bil_vnd,
    f.tdg_val_prev_dy_bil_vnd,
    f.tdg_val_pct_chg,
    f.tdg_val_prd_tot_bil_vnd,
    f.mrgn_dbt_total_bil_vnd,
    f.avg_ordr_sz_mil_vnd,
    f.tot_mtch_vol,
    f.tdg_val_ma50_bil_vnd,
    f.mrgn_dbt_cur_bil_vnd,
    f.mrgn_dbt_prev_bil_vnd,
    f.mrgn_dlt_bil_vnd,
    f.avg_tdg_val_n_dy_bil_vnd,
    f.mrgn_strs_pct,
    f.mrgn_strs_st,
    f.z_scr_eqty_rse,
    f.rsk_indx,
    f.indx_code,
    f.corr_vni_ir,
    f.corr_vni_dxy,
    f.corr_vni_ir_st,
    f.corr_vni_dxy_st,
    f.vnidx_cls,
    f.ir_val,
    f.vnidx_mo_avg,
    f.ir_mo_avg,
    calendar_date.full_date,
    calendar_date.day_of_week,
    calendar_date.day_of_week_num,
    calendar_date.week_of_year,
    calendar_date.month_num,
    calendar_date.month_name,
    calendar_date.quarter_num,
    calendar_date.year_num,
    calendar_date.is_trading_day,
    today()     AS ds_batch_date,
    now()       AS ds_population_timestamp
FROM datamart.pttt_fct_mkt_rsk_snpst f
LEFT JOIN datamart.pttt_calendar_date_dimension calendar_date
    ON calendar_date.date_dimension_id = f.snpst_dt_dim_id
;


-- =============================================================================
-- 2. pttt_fct_mcr_ind_snpst_flat
-- =============================================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_mcr_ind_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_mcr_ind_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.ind_code,
    f.ind_nm,
    f.val,
    f.prd_dt,
    f.prd_tp_code,
    calendar_date.full_date,
    calendar_date.day_of_week,
    calendar_date.day_of_week_num,
    calendar_date.week_of_year,
    calendar_date.month_num,
    calendar_date.month_name,
    calendar_date.quarter_num,
    calendar_date.year_num,
    calendar_date.is_trading_day,
    today()     AS ds_batch_date,
    now()       AS ds_population_timestamp
FROM datamart.pttt_fct_mcr_ind_snpst f
LEFT JOIN datamart.pttt_calendar_date_dimension calendar_date
    ON calendar_date.date_dimension_id = f.snpst_dt_dim_id
;


-- =============================================================================
-- 3. pttt_fct_sctr_rsk_snpst_flat
-- =============================================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_sctr_rsk_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_sctr_rsk_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.sctr_dim_id,
    f.snpst_dt,
    f.sctr_avg_pdrwdwn,
    f.sctr_avg_pvol,
    f.sctr_avg_pslng,
    f.sctr_avg_strs_scr,
    f.sctr_tot_val,
    f.sctr_dbt_scr,
    f.sctr_strs_scr_wgtd,
    f.sctr_strs_dlt,
    f.sctr_rtg,
    calendar_date.full_date,
    calendar_date.day_of_week,
    calendar_date.day_of_week_num,
    calendar_date.week_of_year,
    calendar_date.month_num,
    calendar_date.month_name,
    calendar_date.quarter_num,
    calendar_date.year_num,
    calendar_date.is_trading_day,
    sector_dim.sctr_code,
    sector_dim.sctr_nm,
    today()     AS ds_batch_date,
    now()       AS ds_population_timestamp
FROM datamart.pttt_fct_sctr_rsk_snpst f
LEFT JOIN datamart.pttt_calendar_date_dimension calendar_date
    ON calendar_date.date_dimension_id = f.snpst_dt_dim_id
LEFT JOIN datamart.sctr_dim sector_dim
    ON sector_dim.sctr_dim_id = f.sctr_dim_id
;


-- =============================================================================
-- 4. pttt_fct_ordr_sz_snpst_flat
-- =============================================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_ordr_sz_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_ordr_sz_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.snpst_dt,
    f.scr_code,
    f.tdg_val_bil_vnd,
    f.ordr_sz_bnd,
    f.mtch_vol,
    calendar_date.full_date,
    calendar_date.day_of_week,
    calendar_date.day_of_week_num,
    calendar_date.week_of_year,
    calendar_date.month_num,
    calendar_date.month_name,
    calendar_date.quarter_num,
    calendar_date.year_num,
    calendar_date.is_trading_day,
    today()     AS ds_batch_date,
    now()       AS ds_population_timestamp
FROM datamart.pttt_fct_ordr_sz_snpst f
LEFT JOIN datamart.pttt_calendar_date_dimension calendar_date
    ON calendar_date.date_dimension_id = f.snpst_dt_dim_id
;


-- =============================================================================
-- 5. pttt_fct_ivsr_flw_snpst_flat
-- =============================================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_ivsr_flw_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_ivsr_flw_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.ivsr_grp_dim_id,
    f.snpst_dt,
    f.ivsr_grp_code,
    f.buy_val_bil_vnd,
    f.sell_val_bil_vnd,
    f.net_flw_bil_vnd,
    f.net_flw_ma30_bil_vnd,
    f.net_flw_corr_30d,
    f.tdg_val_bil_vnd,
    f.tdg_val_rto_pct,
    calendar_date.full_date,
    calendar_date.day_of_week,
    calendar_date.day_of_week_num,
    calendar_date.week_of_year,
    calendar_date.month_num,
    calendar_date.month_name,
    calendar_date.quarter_num,
    calendar_date.year_num,
    calendar_date.is_trading_day,
    investor_group.ivsr_grp_nm,
    today()     AS ds_batch_date,
    now()       AS ds_population_timestamp
FROM datamart.pttt_fct_ivsr_flw_snpst f
LEFT JOIN datamart.pttt_calendar_date_dimension calendar_date
    ON calendar_date.date_dimension_id = f.snpst_dt_dim_id
LEFT JOIN datamart.ivsr_grp_dim investor_group
    ON investor_group.ivsr_grp_dim_id = f.ivsr_grp_dim_id
;


-- =============================================================================
-- 6. pttt_fct_frgn_net_trd_snpst_flat
-- =============================================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_frgn_net_trd_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_frgn_net_trd_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.snpst_dt,
    f.scr_code,
    f.frgn_buy_val_bil_vnd,
    f.frgn_sell_val_bil_vnd,
    f.frgn_net_val_bil_vnd,
    calendar_date.full_date,
    calendar_date.day_of_week,
    calendar_date.day_of_week_num,
    calendar_date.week_of_year,
    calendar_date.month_num,
    calendar_date.month_name,
    calendar_date.quarter_num,
    calendar_date.year_num,
    calendar_date.is_trading_day,
    today()     AS ds_batch_date,
    now()       AS ds_population_timestamp
FROM datamart.pttt_fct_frgn_net_trd_snpst f
LEFT JOIN datamart.pttt_calendar_date_dimension calendar_date
    ON calendar_date.date_dimension_id = f.snpst_dt_dim_id
;


-- =============================================================================
-- 7. pttt_fct_prpty_net_trd_snpst_flat
-- =============================================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_prpty_net_trd_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_prpty_net_trd_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.snpst_dt,
    f.scr_code,
    f.prpty_buy_val_bil_vnd,
    f.prpty_sell_val_bil_vnd,
    f.prpty_net_val_bil_vnd,
    calendar_date.full_date,
    calendar_date.day_of_week,
    calendar_date.day_of_week_num,
    calendar_date.week_of_year,
    calendar_date.month_num,
    calendar_date.month_name,
    calendar_date.quarter_num,
    calendar_date.year_num,
    calendar_date.is_trading_day,
    today()     AS ds_batch_date,
    now()       AS ds_population_timestamp
FROM datamart.pttt_fct_prpty_net_trd_snpst f
LEFT JOIN datamart.pttt_calendar_date_dimension calendar_date
    ON calendar_date.date_dimension_id = f.snpst_dt_dim_id
;


-- =============================================================================
-- 8. pttt_fct_corp_bond_sctr_snpst_flat
-- =============================================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_corp_bond_sctr_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_corp_bond_sctr_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.sctr_dim_id,
    f.snpst_dt,
    f.bond_tdg_val_bil_vnd,
    f.bond_tdg_val_tot_bil_vnd,
    f.bond_tdg_val_rto_pct,
    f.bond_oustndg_sctr_bil_vnd,
    calendar_date.full_date,
    calendar_date.day_of_week,
    calendar_date.day_of_week_num,
    calendar_date.week_of_year,
    calendar_date.month_num,
    calendar_date.month_name,
    calendar_date.quarter_num,
    calendar_date.year_num,
    calendar_date.is_trading_day,
    corp_bond_sector.sctr_code,
    corp_bond_sector.sctr_nm,
    today()     AS ds_batch_date,
    now()       AS ds_population_timestamp
FROM datamart.pttt_fct_corp_bond_sctr_snpst f
LEFT JOIN datamart.pttt_calendar_date_dimension calendar_date
    ON calendar_date.date_dimension_id = f.snpst_dt_dim_id
LEFT JOIN datamart.corp_bond_sctr_dim corp_bond_sector
    ON corp_bond_sector.corp_bond_sctr_dim_id = f.sctr_dim_id
;


-- =============================================================================
-- 9. pttt_fct_mbr_sfty_snpst_flat
-- =============================================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_mbr_sfty_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_mbr_sfty_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.snpst_dt,
    f.mrgn_dbt_total_bil_vnd,
    f.tot_eqty_bil_vnd,
    f.tot_dbt_bil_vnd,
    f.avg_mrgn_eqty_rto_pct,
    f.de_rto_avg,
    f.mbr_ctrl_cnt,
    f.mbr_cnt_high,
    f.mbr_cnt_med,
    f.mbr_cnt_low,
    calendar_date.full_date,
    calendar_date.day_of_week,
    calendar_date.day_of_week_num,
    calendar_date.week_of_year,
    calendar_date.month_num,
    calendar_date.month_name,
    calendar_date.quarter_num,
    calendar_date.year_num,
    calendar_date.is_trading_day,
    today()     AS ds_batch_date,
    now()       AS ds_population_timestamp
FROM datamart.pttt_fct_mbr_sfty_snpst f
LEFT JOIN datamart.pttt_calendar_date_dimension calendar_date
    ON calendar_date.date_dimension_id = f.snpst_dt_dim_id
;


-- =============================================================================
-- 10. pttt_fct_mbr_sfty_per_mbr_snpst_flat
-- =============================================================================
TRUNCATE TABLE IF EXISTS datamart.pttt_fct_mbr_sfty_per_mbr_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.pttt_fct_mbr_sfty_per_mbr_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.scr_co_dim_id,
    f.snpst_dt,
    f.eqty_bil_vnd,
    f.mrgn_dbt_bil_vnd,
    f.mrgn_eqty_rto_pct,
    f.attc_rtg,
    calendar_date.full_date,
    calendar_date.day_of_week,
    calendar_date.day_of_week_num,
    calendar_date.week_of_year,
    calendar_date.month_num,
    calendar_date.month_name,
    calendar_date.quarter_num,
    calendar_date.year_num,
    calendar_date.is_trading_day,
    securities_company.mbr_code,
    securities_company.mbr_nm,
    today()     AS ds_batch_date,
    now()       AS ds_population_timestamp
FROM datamart.pttt_fct_mbr_sfty_per_mbr_snpst f
LEFT JOIN datamart.pttt_calendar_date_dimension calendar_date
    ON calendar_date.date_dimension_id = f.snpst_dt_dim_id
LEFT JOIN datamart.scr_co_dim securities_company
    ON securities_company.scr_co_dim_id = f.scr_co_dim_id
;


-- =============================================================================
-- 11. opr_corp_bond_issuer_credit_flat
-- =============================================================================
TRUNCATE TABLE IF EXISTS datamart.opr_corp_bond_issuer_credit_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.opr_corp_bond_issuer_credit_flat
SELECT
    o.issuer_credit_monitor_id,
    o.bond_ticker_code,
    o.issuer_nm,
    o.snpst_dt,
    o.mat_dt,
    o.sctr_code,
    o.tot_dbt_bil_vnd,
    o.eqty_bil_vnd,
    o.de_rto,
    o.net_prft_bil_vnd,
    o.roe_pct,
    o.bond_oustndg_bil_vnd,
    o.audit_opnn,
    o.credit_rtg,
    o.rsk_lvl,
    o.src_stm_code,
    today()     AS ds_batch_date,
    now()       AS ds_population_timestamp
FROM datamart.opr_corp_bond_issuer_credit o
;


-- =============================================================================
-- 12. opr_mbr_sfty_monitor_flat
-- =============================================================================
TRUNCATE TABLE IF EXISTS datamart.opr_mbr_sfty_monitor_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.opr_mbr_sfty_monitor_flat
SELECT
    o.mbr_sfty_monitor_id,
    o.mbr_code,
    o.rpt_dt,
    o.mbr_nm,
    o.eqty_bil_vnd,
    o.mrgn_dbt_bil_vnd,
    o.mrgn_eqty_rto_pct,
    o.attc_rtg,
    o.src_stm_code,
    today()     AS ds_batch_date,
    now()       AS ds_population_timestamp
FROM datamart.opr_mbr_sfty_monitor o
;
