-- ============================================================
-- NHNCK Flat Tables — POPULATE
-- Module: Người Hành Nghề Chứng Khoán (NHNCK)
-- Generated: Phase 3 LLD Datamart
-- 11 bảng: 2 fact + 9 operational
-- ETL daily: fact lọc theo WHERE cal.cdr_dt = :etl_date
-- ============================================================


-- ============================================================
-- 1. FACT: nhnck_fct_prac_license_ctf_snpst_flat
--    snpst_cal: JOIN + WHERE cdr_dt = :etl_date
--    issu_cal:  LEFT JOIN (lịch sử — không lọc ngày)
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.nhnck_fct_prac_license_ctf_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.nhnck_fct_prac_license_ctf_snpst_flat
SELECT
    -- From: FACT Practitioner License Certificate Snapshot
    f.prac_dim_id,
    f.issu_dt_dim_id,
    f.snpst_dt_dim_id,
    f.ctf_tp_cl_dim_id,
    f.ctf_st_cl_dim_id,
    f.license_ctf_doc_code,
    f.ctf_tp_code,
    f.ctf_st_code,
    f.alw_reissue_ind,
    f.is_reissue_ind,
    f.ctf_issu_dt,
    f.revocation_dt,
    f.dcsn_tp_code,

    -- From: CALENDAR DATE DIMENSION (Snapshot Date)
    snpst_cal.full_date         AS snpst_full_date,
    snpst_cal.day_of_week       AS snpst_day_of_week,
    snpst_cal.day_of_week_num   AS snpst_day_of_week_num,
    snpst_cal.week_of_year      AS snpst_week_of_year,
    snpst_cal.month_num         AS snpst_month_num,
    snpst_cal.month_name        AS snpst_month_name,
    snpst_cal.quarter_num       AS snpst_quarter_num,
    snpst_cal.year_num          AS snpst_year_num,
    snpst_cal.is_trading_day    AS snpst_is_trading_day,

    -- From: CALENDAR DATE DIMENSION (Issue Date)
    issu_cal.full_date          AS issu_full_date,
    issu_cal.day_of_week        AS issu_day_of_week,
    issu_cal.day_of_week_num    AS issu_day_of_week_num,
    issu_cal.week_of_year       AS issu_week_of_year,
    issu_cal.month_num          AS issu_month_num,
    issu_cal.month_name         AS issu_month_name,
    issu_cal.quarter_num        AS issu_quarter_num,
    issu_cal.year_num           AS issu_year_num,
    issu_cal.is_trading_day     AS issu_is_trading_day,

    -- From: SECURITIES PRACTITIONER DIMENSION
    prac_dim.prac_code          AS prac_code,
    prac_dim.full_nm            AS prac_full_nm,
    prac_dim.ed_lvl_code        AS prac_ed_lvl_code,
    prac_dim.nat_code           AS prac_nat_code,
    prac_dim.brth_dt            AS prac_brth_dt,
    prac_dim.practice_st_code   AS prac_practice_st_code,

    -- From: CLASSIFICATION DIMENSION (Certificate Type)
    ctf_tp_cls.scm_code         AS ctf_tp_scm_code,
    ctf_tp_cls.scm_nm           AS ctf_tp_scm_nm,
    ctf_tp_cls.cl_code          AS ctf_tp_cl_code,
    ctf_tp_cls.cl_nm            AS ctf_tp_cl_nm,

    -- From: CLASSIFICATION DIMENSION (Certificate Status)
    ctf_st_cls.scm_code         AS ctf_st_scm_code,
    ctf_st_cls.scm_nm           AS ctf_st_scm_nm,
    ctf_st_cls.cl_code          AS ctf_st_cl_code,
    ctf_st_cls.cl_nm            AS ctf_st_cl_nm

FROM datamart.nhnck_fct_prac_license_ctf_snpst f
JOIN datamart.nhnck_calendar_date_dimension snpst_cal
    ON snpst_cal.date_dimension_id = f.snpst_dt_dim_id
LEFT JOIN datamart.nhnck_calendar_date_dimension issu_cal
    ON issu_cal.date_dimension_id = f.issu_dt_dim_id
LEFT JOIN datamart.nhnck_scr_prac_dim prac_dim
    ON prac_dim.scr_prac_dim_id = f.prac_dim_id
LEFT JOIN datamart.nhnck_cls_dim ctf_tp_cls
    ON ctf_tp_cls.cl_dim_id = f.ctf_tp_cl_dim_id
LEFT JOIN datamart.nhnck_cls_dim ctf_st_cls
    ON ctf_st_cls.cl_dim_id = f.ctf_st_cl_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 2. FACT: nhnck_fct_prac_dly_snpst_flat
--    snpst_cal: JOIN + WHERE cdr_dt = :etl_date
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.nhnck_fct_prac_dly_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.nhnck_fct_prac_dly_snpst_flat
SELECT
    -- From: FACT Practitioner Daily Snapshot
    f.prac_dim_id,
    f.snpst_dt_dim_id,
    f.age,
    f.has_actv_ctf,
    f.has_actv_vln,

    -- From: CALENDAR DATE DIMENSION (Snapshot Date)
    snpst_cal.full_date         AS snpst_full_date,
    snpst_cal.day_of_week       AS snpst_day_of_week,
    snpst_cal.day_of_week_num   AS snpst_day_of_week_num,
    snpst_cal.week_of_year      AS snpst_week_of_year,
    snpst_cal.month_num         AS snpst_month_num,
    snpst_cal.month_name        AS snpst_month_name,
    snpst_cal.quarter_num       AS snpst_quarter_num,
    snpst_cal.year_num          AS snpst_year_num,
    snpst_cal.is_trading_day    AS snpst_is_trading_day,

    -- From: SECURITIES PRACTITIONER DIMENSION
    prac_dim.prac_code          AS prac_code,
    prac_dim.full_nm            AS prac_full_nm,
    prac_dim.ed_lvl_code        AS prac_ed_lvl_code,
    prac_dim.nat_code           AS prac_nat_code,
    prac_dim.brth_dt            AS prac_brth_dt,
    prac_dim.practice_st_code   AS prac_practice_st_code

FROM datamart.nhnck_fct_prac_dly_snpst f
JOIN datamart.nhnck_calendar_date_dimension snpst_cal
    ON snpst_cal.date_dimension_id = f.snpst_dt_dim_id
LEFT JOIN datamart.nhnck_scr_prac_dim prac_dim
    ON prac_dim.scr_prac_dim_id = f.prac_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 3. OPERATIONAL: opr_prac_360_profile_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.opr_prac_360_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.opr_prac_360_profile_flat
SELECT
    o.prac_code,
    o.full_nm,
    o.brth_dt,
    o.age,
    o.nat_code,
    o.nat_nm,
    o.identn_nbr,
    o.workplace_nm,
    o.practice_st_code,
    o.practice_st_nm,
    o.actv_ctf_tp_code,
    o.actv_ctf_tp_nm,
    o.actv_ctf_nbr,
    o.src_stm_code
FROM datamart.opr_prac_360_profile o
;


-- ============================================================
-- 4. OPERATIONAL: opr_prac_rel_p_profile_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.opr_prac_rel_p_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.opr_prac_rel_p_profile_flat
SELECT
    o.prac_code,
    o.rel_p_code,
    o.rel_idv_full_nm,
    o.rltnp_tp_code,
    o.rltnp_tp_nm,
    o.rel_idv_ocp,
    o.rel_idv_workplace,
    o.rel_idv_id_nbr,
    o.cty_code,
    o.cty_nm,
    o.rel_idv_adr,
    o.src_stm_code
FROM datamart.opr_prac_rel_p_profile o
;


-- ============================================================
-- 5. OPERATIONAL: opr_prac_lst_co_role_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.opr_prac_lst_co_role_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.opr_prac_lst_co_role_flat
SELECT
    o.prac_code,
    o.org_emp_rpt_code,
    o.prac_workplace_at_rpt,
    o.prac_pos_at_rpt,
    o.org_tp_code,
    o.scr_org_refr_code,
    o.employment_st,
    o.hire_dt,
    o.tmt_dt,
    o.src_stm_code
FROM datamart.opr_prac_lst_co_role o
;


-- ============================================================
-- 6. OPERATIONAL: opr_prac_ctf_hist_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.opr_prac_ctf_hist_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.opr_prac_ctf_hist_flat
SELECT
    o.prac_code,
    o.license_ctf_doc_code,
    o.ctf_nbr,
    o.ctf_tp_code,
    o.ctf_tp_nm,
    o.issu_dt,
    o.revocation_dt,
    o.issu_dcsn_nbr,
    o.revocation_dcsn_nbr,
    o.pcs_st_code,
    o.pcs_st_nm,
    o.src_stm_code
FROM datamart.opr_prac_ctf_hist o
;


-- ============================================================
-- 7. OPERATIONAL: opr_prac_emp_hist_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.opr_prac_emp_hist_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.opr_prac_emp_hist_flat
SELECT
    o.prac_code,
    o.org_emp_rpt_code,
    o.scr_org_refr_code,
    o.scr_org_refr_nm,
    o.org_tp_code,
    o.org_tp_nm,
    o.prac_pos_at_rpt,
    o.prac_dept_at_rpt,
    o.hire_dt,
    o.tmt_dt,
    o.src_stm_code
FROM datamart.opr_prac_emp_hist o
;


-- ============================================================
-- 8. OPERATIONAL: opr_prac_vln_hist_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.opr_prac_vln_hist_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.opr_prac_vln_hist_flat
SELECT
    o.prac_code,
    o.conduct_vln_code,
    o.rcrd_tp_code,
    o.rcrd_tp_nm,
    o.note,
    o.rcrd_st_code,
    o.rcrd_st_nm,
    o.dcsn_nbr,
    o.dcsn_signed_dt,
    o.src_stm_code
FROM datamart.opr_prac_vln_hist o
;


-- ============================================================
-- 9. OPERATIONAL: opr_prac_exam_hist_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.opr_prac_exam_hist_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.opr_prac_exam_hist_flat
SELECT
    o.prac_code,
    o.exam_ases_rslt_code,
    o.ases_nm,
    o.rpt_yr,
    o.exam_ssn_nbr,
    o.exam_period,
    o.exam_strt_dt,
    o.law_scor,
    o.specialization_scor,
    o.law_rslt_code,
    o.law_rslt_nm,
    o.specialization_rslt_code,
    o.specialization_rslt_nm,
    o.ovrl_rslt_code,
    o.ovrl_rslt_nm,
    o.dcsn_nbr,
    o.dcsn_signed_dt,
    o.src_stm_code
FROM datamart.opr_prac_exam_hist o
;


-- ============================================================
-- 10. OPERATIONAL: opr_prac_trn_hist_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.opr_prac_trn_hist_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.opr_prac_trn_hist_flat
SELECT
    o.prac_code,
    o.enrollment_code,
    o.trn_clss_code,
    o.trn_clss_nm,
    o.academic_yr,
    o.exam_strt_dt,
    o.exam_end_dt,
    o.exam_scor,
    o.trn_rslt_code,
    o.trn_rslt_nm,
    o.src_stm_code
FROM datamart.opr_prac_trn_hist o
;


-- ============================================================
-- 11. OPERATIONAL: opr_prac_data_explr_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.opr_prac_data_explr_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.opr_prac_data_explr_flat
SELECT
    o.prac_code,
    o.license_ctf_doc_code,
    o.full_nm,
    o.ctf_nbr,
    o.ctf_tp_code,
    o.ctf_tp_nm,
    o.practice_st_code,
    o.issu_dt,
    o.current_org_nm,
    o.identn_tp_code,
    o.src_stm_code
FROM datamart.opr_prac_data_explr o
;
