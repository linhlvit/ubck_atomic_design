-- ============================================================
-- NHNCK Flat Tables — POPULATE
-- Module: Người Hành Nghề Chứng Khoán (NHNCK)
-- Generated: Phase 3 LLD Datamart
-- 11 bảng: 2 fact + 9 operational
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
    f.decision_tp_code,

    -- From: CALENDAR DATE DIMENSION (Snapshot Date)
    snpst_cal.cdr_dt            AS snpst_cdr_dt,

    -- From: CALENDAR DATE DIMENSION (Issue Date)
    issu_cal.cdr_dt             AS issue_cdr_dt,

    -- From: SECURITIES PRACTITIONER DIMENSION
    prac_dim.practitioner_code          AS practitioner_code,
    prac_dim.full_nm                    AS practitioner_full_nm,
    prac_dim.education_level_code       AS practitioner_education_level_code,
    prac_dim.nationality_code           AS practitioner_nationality_code,
    prac_dim.birth_dt                   AS practitioner_birth_dt,
    prac_dim.practice_status_code       AS practitioner_practice_status_code,
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

    -- From: CALENDAR DATE DIMENSION (Snapshot Date)
    snpst_cal.cdr_dt            AS snpst_cdr_dt,

    -- From: SECURITIES PRACTITIONER DIMENSION
    prac_dim.practitioner_code          AS practitioner_code,
    prac_dim.full_nm            AS practitioner_full_nm,
    prac_dim.education_level_code        AS practitioner_education_level_code,
    prac_dim.nationality_code           AS practitioner_nationality_code,
    prac_dim.birth_dt            AS practitioner_birth_dt,
    prac_dim.practice_status_code   AS practitioner_practice_status_code,
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
    o.full_nm,
    o.birth_dt,
    o.age,
    o.nationality_code,
    o.nationality_nm,
    o.identification_nbr,
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
    o.related_individual_full_nm,
    o.rltnp_tp_code,
    o.rltnp_tp_nm,
    o.related_individual_occupation,
    o.related_individual_workplace,
    o.related_individual_identity_nbr,
    o.country_code,
    o.country_nm,
    o.related_individual_adr,
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
    o.organization_employment_rpt_code,
    o.practitioner_workplace_at_rpt,
    o.practitioner_position_at_rpt,
    o.organization_tp_code,
    o.securities_organization_reference_code,
    o.employment_status,
    o.hire_dt,
    o.termination_dt,
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
    o.src_stm_code
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
    o.law_score,
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
    o.exam_score,
    o.exam_result_code,
    o.exam_result_nm,
    o.src_stm_code
FROM datamart.opr_practitioner_training_hist o
;


-- ============================================================
-- 11. OPERATIONAL: opr_practitioner_data_explorer_flat
--    (Sửa 2026-07-22) LEFT JOIN Practitioner 360 Profile (1-1) + Exam History (1-N)
--    + Violation History (1-N) theo practitioner_code — chấp nhận cartesian
--    khi 1 NHN vừa có nhiều đợt thi vừa có nhiều vi phạm đồng thời.
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.nhnck_opr_practitioner_data_explorer_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.nhnck_opr_practitioner_data_explorer_flat
SELECT
    o.practitioner_code,
    o.license_certificate_document_code,
    o.full_nm,
    o.certificate_nbr,
    o.certificate_tp_code,
    o.certificate_tp_nm,
    o.practice_status_code,
    o.practice_status_nm,
    o.issue_dt,
    o.current_organization_nm,
    o.identification_tp_code,
    o.src_stm_code,
    p360.birth_dt                      AS birth_dt,
    p360.identification_nbr            AS identification_nbr,
    p360.education_level_nm            AS education_level_nm,
    p360.age                           AS age,
    p360.nationality_nm                AS nationality_nm,
    exam.assessment_nm                 AS exam_assessment_nm,
    exam.examination_period            AS exam_examination_period,
    exam.examination_start_dt          AS exam_examination_start_dt,
    exam.examination_end_dt            AS exam_examination_end_dt,
    exam.overall_result_nm             AS exam_overall_result_nm,
    viol.decision_nbr                  AS violation_decision_nbr,
    viol.decision_signed_dt            AS violation_decision_signed_dt,
    viol.note                          AS violation_note
FROM datamart.opr_practitioner_data_explorer o
LEFT JOIN datamart.opr_practitioner_360_profile p360
    ON p360.practitioner_code = o.practitioner_code
LEFT JOIN datamart.opr_practitioner_exam_hist exam
    ON exam.practitioner_code = o.practitioner_code
LEFT JOIN datamart.opr_practitioner_violation_hist viol
    ON viol.practitioner_code = o.practitioner_code
;
