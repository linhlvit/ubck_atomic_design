-- ============================================================
-- Module TT (Thanh Tra) — Flat Table POPULATE
-- 9 Fact + 4 Operational = 13 bảng flat
-- Sửa 2026-08-03 (audit Case 3): 7 Fact là transaction log theo ngày (Decision
-- Date/Issued Date), ETL filter WHERE cdr_dt = :etl_date — DELETE-scoped theo
-- ngày (không TRUNCATE) để giữ nguyên lịch sử các ngày khác. 4 Operational là
-- danh sách hồ sơ hiện hành (không có filter ngày, full-scan mỗi lần) — giữ
-- TRUNCATE, đúng bản chất "current state list".
-- ============================================================

-- ------------------------------------------------------------
-- 1. Fact Inspection Team Activity
-- ------------------------------------------------------------
DELETE FROM datamart.tt_fct_inspection_team_activity_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.tt_fct_inspection_team_activity_flat
SELECT
    cal.cdr_dt                          AS cdr_dt,
    dim.inspection_team_code,
    dim.start_dt,
    dim.end_dt,
    dim.content,
    dim.src_stm_code                    AS inspection_team_src_stm_code
FROM datamart.fct_inspection_team_activity f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.calendar_dt_dim_id
JOIN datamart.inspection_team_dim dim
    ON dim.inspection_team_dim_id = f.inspection_team_dim_id
WHERE cal.cdr_dt = :etl_date
;

-- ------------------------------------------------------------
-- 2. Fact Examination Team Activity
-- ------------------------------------------------------------
DELETE FROM datamart.tt_fct_examination_team_activity_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.tt_fct_examination_team_activity_flat
SELECT
    cal.cdr_dt                          AS cdr_dt,
    dim.examination_team_code,
    dim.start_dt,
    dim.end_dt,
    dim.content,
    dim.src_stm_code                    AS examination_team_src_stm_code
FROM datamart.fct_examination_team_activity f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.calendar_dt_dim_id
JOIN datamart.examination_team_dim dim
    ON dim.examination_team_dim_id = f.examination_team_dim_id
WHERE cal.cdr_dt = :etl_date
;

-- ------------------------------------------------------------
-- 3. Fact Inspection Team Target Activity
-- ------------------------------------------------------------
DELETE FROM datamart.tt_fct_inspection_team_target_activity_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.tt_fct_inspection_team_target_activity_flat
SELECT
    cal.cdr_dt                          AS cdr_dt,
    target_dim.inspection_team_target_code,
    target_dim.target_tp_code,
    target_dim.src_stm_code             AS inspection_team_target_src_stm_code,
    team_dim.inspection_team_code,
    team_dim.start_dt,
    team_dim.end_dt,
    team_dim.content,
    team_dim.src_stm_code               AS inspection_team_src_stm_code
FROM datamart.fct_inspection_team_target_activity f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.calendar_dt_dim_id
JOIN datamart.inspection_team_target_dim target_dim
    ON target_dim.inspection_team_target_dim_id = f.inspection_team_target_dim_id
JOIN datamart.inspection_team_dim team_dim
    ON team_dim.inspection_team_dim_id = f.inspection_team_dim_id
WHERE cal.cdr_dt = :etl_date
;

-- ------------------------------------------------------------
-- 4. Fact Examination Team Target Activity
-- ------------------------------------------------------------
DELETE FROM datamart.tt_fct_examination_team_target_activity_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.tt_fct_examination_team_target_activity_flat
SELECT
    cal.cdr_dt                          AS cdr_dt,
    target_dim.examination_team_target_code,
    target_dim.target_tp_code,
    target_dim.src_stm_code             AS examination_team_target_src_stm_code,
    team_dim.examination_team_code,
    team_dim.start_dt,
    team_dim.end_dt,
    team_dim.content,
    team_dim.src_stm_code               AS examination_team_src_stm_code
FROM datamart.fct_examination_team_target_activity f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.calendar_dt_dim_id
JOIN datamart.examination_team_target_dim target_dim
    ON target_dim.examination_team_target_dim_id = f.examination_team_target_dim_id
JOIN datamart.examination_team_dim team_dim
    ON team_dim.examination_team_dim_id = f.examination_team_dim_id
WHERE cal.cdr_dt = :etl_date
;

-- ------------------------------------------------------------
-- 5. Fact Penalty Decision
-- ------------------------------------------------------------
DELETE FROM datamart.tt_fct_penalty_decision_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.tt_fct_penalty_decision_flat
SELECT
    f.total_fine_amt,
    cal.cdr_dt                          AS cdr_dt,
    dim.penalty_decision_code,
    dim.src_stm_code                    AS penalty_decision_src_stm_code
FROM datamart.fct_penalty_decision f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.calendar_dt_dim_id
JOIN datamart.penalty_decision_dim dim
    ON dim.penalty_decision_dim_id = f.penalty_decision_dim_id
WHERE cal.cdr_dt = :etl_date
;

-- ------------------------------------------------------------
-- 6. Fact Penalty Decision Subject Behavior
-- ------------------------------------------------------------
DELETE FROM datamart.tt_fct_penalty_decision_subject_behavior_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.tt_fct_penalty_decision_subject_behavior_flat
SELECT
    f.applied_fine_amt,
    cal.cdr_dt                          AS cdr_dt,
    behavior_dim.penalty_decision_subject_behavior_code,
    behavior_dim.violation_behavior_nm,
    behavior_dim.src_stm_code           AS penalty_decision_subject_behavior_src_stm_code,
    decision_dim.penalty_decision_code,
    decision_dim.src_stm_code           AS penalty_decision_src_stm_code,
    subject_dim.penalty_decision_subject_code,
    subject_dim.subject_tp_code,
    subject_dim.src_stm_code            AS penalty_decision_subject_src_stm_code
FROM datamart.fct_penalty_decision_subject_behavior f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.calendar_dt_dim_id
JOIN datamart.penalty_decision_subject_behavior_dim behavior_dim
    ON behavior_dim.penalty_decision_subject_behavior_dim_id = f.penalty_decision_subject_behavior_dim_id
JOIN datamart.penalty_decision_dim decision_dim
    ON decision_dim.penalty_decision_dim_id = f.penalty_decision_dim_id
JOIN datamart.penalty_decision_subject_dim subject_dim
    ON subject_dim.penalty_decision_subject_dim_id = f.penalty_decision_subject_dim_id
WHERE cal.cdr_dt = :etl_date
;

-- ------------------------------------------------------------
-- 7. Fact Penalty Decision Subject
-- ------------------------------------------------------------
DELETE FROM datamart.tt_fct_penalty_decision_subject_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.tt_fct_penalty_decision_subject_flat
SELECT
    cal.cdr_dt                          AS cdr_dt,
    subject_dim.penalty_decision_subject_code,
    subject_dim.subject_tp_code,
    subject_dim.src_stm_code            AS penalty_decision_subject_src_stm_code,
    decision_dim.penalty_decision_code,
    decision_dim.src_stm_code           AS penalty_decision_src_stm_code
FROM datamart.fct_penalty_decision_subject f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.calendar_dt_dim_id
JOIN datamart.penalty_decision_subject_dim subject_dim
    ON subject_dim.penalty_decision_subject_dim_id = f.penalty_decision_subject_dim_id
JOIN datamart.penalty_decision_dim decision_dim
    ON decision_dim.penalty_decision_dim_id = f.penalty_decision_dim_id
WHERE cal.cdr_dt = :etl_date
;

-- ------------------------------------------------------------
-- 8. Operational Inspection Case List
-- ------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.tt_opr_inspection_case_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tt_opr_inspection_case_list_flat
SELECT
    o.inspection_team_target_code,
    o.inspection_team_code,
    o.target_nm,
    o.target_tp_code,
    o.form_tp_code,
    o.status_code,
    o.decision_dt,
    o.decision_year,
    o.src_stm_code
FROM datamart.opr_inspection_case_list o
;

-- ------------------------------------------------------------
-- 9. Operational Examination Case List
-- ------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.tt_opr_examination_case_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tt_opr_examination_case_list_flat
SELECT
    o.examination_team_target_code,
    o.examination_team_code,
    o.target_nm,
    o.target_tp_code,
    o.form_tp_code,
    o.status_code,
    o.decision_dt,
    o.decision_year,
    o.src_stm_code
FROM datamart.opr_examination_case_list o
;

-- ------------------------------------------------------------
-- 10. Operational Penalty Decision List
-- ------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.tt_opr_penalty_decision_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tt_opr_penalty_decision_list_flat
SELECT
    o.pd_subject_code,
    o.violation_case_code,
    o.subject_nm,
    o.subject_tp_code,
    o.form_tp_code,
    o.life_cycle_status_code,
    o.issued_dt,
    o.issued_year,
    o.total_fine_amt,
    o.src_stm_code
FROM datamart.opr_penalty_decision_list o
;

-- ------------------------------------------------------------
-- 11. Operational Petition List
-- ------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.tt_opr_petition_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tt_opr_petition_list_flat
SELECT
    o.petition_code,
    o.petition_category_code,
    o.content,
    o.life_cycle_status_code,
    o.received_dt,
    o.received_year,
    o.src_stm_code
FROM datamart.opr_petition_list o
;

-- ------------------------------------------------------------
-- 12. Fact Inspection Team Violation Behavior
-- ------------------------------------------------------------
DELETE FROM datamart.tt_fct_inspection_team_violation_behavior_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.tt_fct_inspection_team_violation_behavior_flat
SELECT
    cal.cdr_dt                          AS cdr_dt,
    behavior_dim.violation_record_behavior_code,
    behavior_dim.violation_behavior_nm,
    behavior_dim.src_stm_code           AS inspection_team_violation_behavior_src_stm_code,
    team_dim.inspection_team_code,
    team_dim.start_dt,
    team_dim.end_dt,
    team_dim.content,
    team_dim.src_stm_code               AS inspection_team_src_stm_code
FROM datamart.fct_inspection_team_violation_behavior f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.calendar_dt_dim_id
JOIN datamart.inspection_team_violation_behavior_dim behavior_dim
    ON behavior_dim.inspection_team_violation_behavior_dim_id = f.inspection_team_violation_behavior_dim_id
JOIN datamart.inspection_team_dim team_dim
    ON team_dim.inspection_team_dim_id = f.inspection_team_dim_id
WHERE cal.cdr_dt = :etl_date
;

-- ------------------------------------------------------------
-- 13. Fact Examination Team Violation Behavior
-- ------------------------------------------------------------
DELETE FROM datamart.tt_fct_examination_team_violation_behavior_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.tt_fct_examination_team_violation_behavior_flat
SELECT
    cal.cdr_dt                          AS cdr_dt,
    behavior_dim.violation_record_behavior_code,
    behavior_dim.violation_behavior_nm,
    behavior_dim.src_stm_code           AS examination_team_violation_behavior_src_stm_code,
    team_dim.examination_team_code,
    team_dim.start_dt,
    team_dim.end_dt,
    team_dim.content,
    team_dim.src_stm_code               AS examination_team_src_stm_code
FROM datamart.fct_examination_team_violation_behavior f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.calendar_dt_dim_id
JOIN datamart.examination_team_violation_behavior_dim behavior_dim
    ON behavior_dim.examination_team_violation_behavior_dim_id = f.examination_team_violation_behavior_dim_id
JOIN datamart.examination_team_dim team_dim
    ON team_dim.examination_team_dim_id = f.examination_team_dim_id
WHERE cal.cdr_dt = :etl_date
;
