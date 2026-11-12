-- ============================================================
-- NHNCK Flat Tables — POPULATE
-- Module: Người Hành Nghề Chứng Khoán (NHNCK)
-- Generated: Phase 3 LLD Datamart
-- 12 bảng: 2 fact + 10 operational
-- (Sửa 2026-11-03) NHNCK Nhóm 7/13: xem ghi chú file 01_create — list_company_role đổi cột/PK, thêm account_holding; (Sửa 2026-11-07) khôi phục data_explorer 1-1 từ bảng mart Gold-to-Gold (khối 12, O_NHNCK_47)
-- ETL daily: fact lọc theo WHERE cal.cdr_dt = :etl_date
-- Grain 2 fact Snapshot (license_certificate_snpst, daily_snpst) = APPEND
-- theo Snapshot_Date (HLD: "ETL append 1 row per NHN mỗi ngày") — phục vụ
-- KPI YoY/so sánh 31/12/Y các năm quá khứ. KHÔNG TRUNCATE — chỉ DELETE đúng
-- ngày :etl_date (idempotent re-run) rồi INSERT lại, giữ nguyên lịch sử
-- các ngày snapshot khác.
-- ============================================================


-- ============================================================
-- 1. FACT: nhnck_fct_practitioner_license_certificate_snpst_flat
--    Grain APPEND — DELETE đúng ngày :etl_date (không TRUNCATE) rồi INSERT
--    issu_cal:  LEFT JOIN (lịch sử — không lọc ngày)
-- ============================================================
DELETE FROM datamart.nhnck_fct_practitioner_license_certificate_snpst_flat ON CLUSTER 'my_cluster'
WHERE snpst_cdr_dt = :etl_date;
INSERT INTO datamart.nhnck_fct_practitioner_license_certificate_snpst_flat
SELECT
    -- From: FACT Practitioner License Certificate Snapshot
    f.practitioner_dim_id,
    f.issue_dt_dim_id,
    f.snpst_dt_dim_id,
    f.certificate_tp_dim_id,
    f.license_certificate_document_code,
    f.certificate_nbr,
    f.is_reissue_indicator,
    f.certificate_issue_dt,
    f.revocation_dt,
    f.certificate_status_code,
    f.decision_tp_code,
    f.decision_signed_dt,

    -- From: CALENDAR DATE DIMENSION (Snapshot Date)
    snpst_cal.cdr_dt            AS snpst_cdr_dt,

    -- From: CALENDAR DATE DIMENSION (Issue Date)
    issu_cal.cdr_dt             AS issue_cdr_dt,

    -- From: SECURITIES PRACTITIONER DIMENSION
    prac_dim.practitioner_code          AS practitioner_code,
    fn_pii_encrypt(prac_dim.full_nm, :aes_key_hex) AS practitioner_full_nm,
    prac_dim.education_level_code       AS practitioner_education_level_code,
    prac_dim.education_level_nm         AS practitioner_education_level_nm,
    prac_dim.nationality_code           AS practitioner_nationality_code,
    prac_dim.birth_dt                   AS practitioner_birth_dt,
    prac_dim.practice_status_code       AS practitioner_practice_status_code,
    prac_dim.practice_status_nm         AS practitioner_practice_status_nm,
    prac_dim.src_stm_code               AS practitioner_src_stm_code,

    -- From: SP LICENSE CERTIFICATE TYPE DIMENSION
    certificate_tp_dim.certificate_tp_code   AS certificate_tp_dim_code,
    certificate_tp_dim.certificate_tp_nm     AS certificate_tp_dim_nm,
    certificate_tp_dim.src_stm_code          AS certificate_tp_src_stm_code

FROM datamart.fct_practitioner_license_certificate_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.cdr_dt_dim issu_cal
    ON issu_cal.cdr_dt_dim_id = f.issue_dt_dim_id
LEFT JOIN datamart.securities_practitioner_dim prac_dim
    ON prac_dim.securities_practitioner_dim_id = f.practitioner_dim_id
LEFT JOIN datamart.sp_license_certificate_type_dim certificate_tp_dim
    ON certificate_tp_dim.certificate_tp_dim_id = f.certificate_tp_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 2. FACT: nhnck_fct_practitioner_daily_snpst_flat
--    Grain APPEND — DELETE đúng ngày :etl_date (không TRUNCATE) rồi INSERT
-- ============================================================
DELETE FROM datamart.nhnck_fct_practitioner_daily_snpst_flat ON CLUSTER 'my_cluster'
WHERE snpst_cdr_dt = :etl_date;
INSERT INTO datamart.nhnck_fct_practitioner_daily_snpst_flat
SELECT
    -- From: FACT Practitioner Daily Snapshot
    f.practitioner_dim_id,
    f.snpst_dt_dim_id,
    f.age,
    f.has_active_violation,
    f.first_license_dt,
    f.practicing_indicator,
    f.concurrent_employment_indicator,
    f.insufficient_training_indicator,
    f.no_practice_3_years_indicator,

    -- From: CALENDAR DATE DIMENSION (Snapshot Date)
    snpst_cal.cdr_dt            AS snpst_cdr_dt,

    -- From: SECURITIES PRACTITIONER DIMENSION
    prac_dim.practitioner_code          AS practitioner_code,
    fn_pii_encrypt(prac_dim.full_nm, :aes_key_hex) AS practitioner_full_nm,
    prac_dim.education_level_code        AS practitioner_education_level_code,
    prac_dim.education_level_nm          AS practitioner_education_level_nm,
    prac_dim.nationality_code           AS practitioner_nationality_code,
    prac_dim.birth_dt            AS practitioner_birth_dt,
    prac_dim.practice_status_code   AS practitioner_practice_status_code,
    prac_dim.practice_status_nm     AS practitioner_practice_status_nm,
    prac_dim.src_stm_code           AS practitioner_src_stm_code

FROM datamart.fct_practitioner_daily_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.securities_practitioner_dim prac_dim
    ON prac_dim.securities_practitioner_dim_id = f.practitioner_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 3. OPERATIONAL: opr_practitioner_360_profile_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.nhnck_opr_practitioner_360_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.nhnck_opr_practitioner_360_profile_flat
SELECT
    o.practitioner_code,
    fn_pii_encrypt(o.full_nm, :aes_key_hex) AS full_nm,
    o.birth_dt,
    o.age,
    o.nationality_code,
    o.nationality_nm,
    fn_pii_encrypt(o.identification_nbr, :aes_key_hex) AS identification_nbr,
    o.identification_tp_code,
    o.education_level_code,
    o.education_level_nm,
    o.workplace_nm,
    o.practice_status_code,
    o.practice_status_nm,
    o.active_certificate_tp_code,
    o.active_certificate_tp_nm,
    o.active_certificate_nbr,
    o.src_stm_code
FROM datamart.opr_practitioner_360_profile o
;


-- ============================================================
-- 4. OPERATIONAL: opr_practitioner_related_party_profile_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.nhnck_opr_practitioner_related_party_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.nhnck_opr_practitioner_related_party_profile_flat
SELECT
    o.practitioner_code,
    o.related_party_code,
    fn_pii_encrypt(o.related_individual_full_nm, :aes_key_hex) AS related_individual_full_nm,
    o.rltnp_tp_code,
    o.rltnp_tp_nm,
    o.related_individual_occupation,
    o.related_individual_workplace,
    fn_pii_encrypt(o.related_individual_identity_nbr, :aes_key_hex) AS related_individual_identity_nbr,
    o.country_code,
    o.country_nm,
    fn_pii_encrypt(o.related_individual_adr, :aes_key_hex) AS related_individual_adr,
    o.src_stm_code
FROM datamart.opr_practitioner_related_party_profile o
;


-- ============================================================
-- 5. OPERATIONAL: opr_practitioner_list_company_role_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.nhnck_opr_practitioner_list_company_role_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.nhnck_opr_practitioner_list_company_role_flat
SELECT
    o.practitioner_code,
    o.sc_shareholder_code,
    o.securities_company_code,
    o.securities_company_short_nm,
    o.representative_position,
    o.practice_status_code,
    o.practice_status_nm,
    o.shares_held,
    o.src_stm_code
FROM datamart.opr_practitioner_list_company_role o
;


-- ============================================================
-- 6. OPERATIONAL: opr_practitioner_certificate_hist_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.nhnck_opr_practitioner_certificate_hist_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.nhnck_opr_practitioner_certificate_hist_flat
SELECT
    o.practitioner_code,
    o.license_certificate_document_code,
    o.certificate_nbr,
    o.certificate_tp_code,
    o.certificate_tp_nm,
    o.issue_dt,
    o.revocation_dt,
    o.issue_decision_nbr,
    o.revocation_decision_nbr,
    o.certificate_status_code,
    o.certificate_status_nm,
    o.src_stm_code,
    o.cancellation_dt,
    o.cancellation_decision_nbr
FROM datamart.opr_practitioner_certificate_hist o
;


-- ============================================================
-- 7. OPERATIONAL: opr_practitioner_employment_hist_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.nhnck_opr_practitioner_employment_hist_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.nhnck_opr_practitioner_employment_hist_flat
SELECT
    o.practitioner_code,
    o.organization_employment_rpt_code,
    o.securities_organization_reference_code,
    o.securities_organization_reference_nm,
    o.organization_tp_code,
    o.organization_tp_nm,
    o.practitioner_workplace_at_rpt,
    o.practitioner_position_at_rpt,
    o.practitioner_department_at_rpt,
    o.hire_dt,
    o.termination_dt,
    o.src_stm_code
FROM datamart.opr_practitioner_employment_hist o
;


-- ============================================================
-- 8. OPERATIONAL: opr_practitioner_violation_hist_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.nhnck_opr_practitioner_violation_hist_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.nhnck_opr_practitioner_violation_hist_flat
SELECT
    o.practitioner_code,
    o.conduct_violation_code,
    o.violation_tp_code,
    o.violation_tp_nm,
    o.note,
    o.violation_status_code,
    o.violation_status_nm,
    o.decision_nbr,
    o.decision_signed_dt,
    o.src_stm_code
FROM datamart.opr_practitioner_violation_hist o
;


-- ============================================================
-- 9. OPERATIONAL: opr_practitioner_exam_hist_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.nhnck_opr_practitioner_exam_hist_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.nhnck_opr_practitioner_exam_hist_flat
SELECT
    o.practitioner_code,
    o.examination_assessment_result_code,
    o.assessment_nm,
    o.rpt_year,
    o.examination_session_nbr,
    o.examination_period,
    o.examination_start_dt,
    o.examination_end_dt,
    o.law_score,
    o.specialization_score,
    o.law_result_code,
    o.law_result_nm,
    o.specialization_result_code,
    o.specialization_result_nm,
    o.overall_result_code,
    o.overall_result_nm,
    o.decision_nbr,
    o.decision_signed_dt,
    o.src_stm_code
FROM datamart.opr_practitioner_exam_hist o
;


-- ============================================================
-- 10. OPERATIONAL: opr_practitioner_training_hist_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.nhnck_opr_practitioner_training_hist_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.nhnck_opr_practitioner_training_hist_flat
SELECT
    o.practitioner_code,
    o.training_result_code,
    o.training_class_code,
    o.training_class_nm,
    o.training_start_dt,
    o.training_end_dt,
    o.training_hours,
    o.hours_sufficiency_indicator,
    o.exam_result_code,
    o.exam_result_nm,
    o.src_stm_code
FROM datamart.opr_practitioner_training_hist o
;


-- ==========================================================
-- 11. OPERATIONAL: nhnck_opr_practitioner_account_holding_flat
-- ==========================================================
TRUNCATE TABLE IF EXISTS datamart.nhnck_opr_practitioner_account_holding_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.nhnck_opr_practitioner_account_holding_flat
SELECT
    -- From: OPR_PRACTITIONER_ACCOUNT_HOLDING
    f.practitioner_account_holding_id,
    f.practitioner_code,
    fn_pii_encrypt(f.account_nbr, :aes_key_hex) AS account_nbr,
    fn_pii_encrypt(f.account_holder_nm, :aes_key_hex) AS account_holder_nm,
    f.main_held_securities_code,
    f.vsdc_held_securities_vol,
    f.src_stm_code

FROM datamart.opr_practitioner_account_holding f
;


-- ==========================================================
-- 12. OPERATIONAL: nhnck_opr_practitioner_data_explorer_flat
-- ==========================================================
TRUNCATE TABLE IF EXISTS datamart.nhnck_opr_practitioner_data_explorer_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.nhnck_opr_practitioner_data_explorer_flat
SELECT
    -- From: OPR_PRACTITIONER_DATA_EXPLORER
    f.practitioner_data_explorer_id,
    f.practitioner_code,
    f.license_certificate_document_code,
    f.examination_assessment_result_code,
    f.conduct_violation_code,
    fn_pii_encrypt(f.full_nm, :aes_key_hex) AS full_nm,
    f.birth_dt,
    f.age,
    f.nationality_nm,
    fn_pii_encrypt(f.identification_nbr, :aes_key_hex) AS identification_nbr,
    f.identification_tp_code,
    f.education_level_nm,
    f.practice_status_code,
    f.practice_status_nm,
    f.certificate_nbr,
    f.certificate_tp_code,
    f.certificate_tp_nm,
    f.issue_dt,
    f.current_organization_nm,
    f.concurrent_employment_indicator,
    f.insufficient_training_indicator,
    f.no_practice_3_years_indicator,
    f.exam_assessment_nm,
    f.exam_examination_period,
    f.exam_examination_start_dt,
    f.exam_examination_end_dt,
    f.exam_overall_result_nm,
    f.violation_decision_nbr,
    f.violation_decision_signed_dt,
    f.violation_note,
    f.src_stm_code

FROM datamart.opr_practitioner_data_explorer f
;
