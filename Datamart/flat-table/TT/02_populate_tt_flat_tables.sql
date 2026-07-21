-- ============================================================
-- Module TT (Thanh Tra) — Flat Table POPULATE
-- 7 Fact + 4 Operational = 11 bảng flat
-- ============================================================

-- ------------------------------------------------------------
-- 1. Fact Inspection Team Activity
-- ------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.tt_fct_inspection_team_activity_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tt_fct_inspection_team_activity_flat
SELECT
    f.fct_inspection_team_activity_id,
    cal.cdr_dt                         AS cdr_dt,
    dim.inspection_team_code,
    dim.start_dt,
    dim.end_dt,
    dim.content
FROM datamart.tt_fct_inspection_team_activity f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.calendar_dt_dim_id
LEFT JOIN datamart.inspection_team_dim dim
    ON dim.inspection_team_dim_id = f.inspection_team_dim_id
WHERE cal.cdr_dt = :etl_date
;

-- ------------------------------------------------------------
-- 2. Fact Examination Team Activity
-- ------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.tt_fct_examination_team_activity_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tt_fct_examination_team_activity_flat
SELECT
    f.fct_examination_team_activity_id,
    cal.cdr_dt                         AS cdr_dt,
    dim.examination_team_code,
    dim.start_dt,
    dim.end_dt,
    dim.content
FROM datamart.tt_fct_examination_team_activity f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.calendar_dt_dim_id
LEFT JOIN datamart.examination_team_dim dim
    ON dim.examination_team_dim_id = f.examination_team_dim_id
WHERE cal.cdr_dt = :etl_date
;

-- ------------------------------------------------------------
-- 3. Fact Inspection Team Target Activity
-- ------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.tt_fct_inspection_team_target_activity_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tt_fct_inspection_team_target_activity_flat
SELECT
    f.fct_inspection_team_target_activity_id,
    f.inspection_team_code,
    f.target_tp_code,
    cal.cdr_dt                         AS cdr_dt
FROM datamart.tt_fct_inspection_team_target_activity f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.calendar_dt_dim_id
WHERE cal.cdr_dt = :etl_date
;

-- ------------------------------------------------------------
-- 4. Fact Examination Team Target Activity
-- ------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.tt_fct_examination_team_target_activity_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tt_fct_examination_team_target_activity_flat
SELECT
    f.fct_examination_team_target_activity_id,
    f.examination_team_code,
    f.target_tp_code,
    cal.cdr_dt                         AS cdr_dt
FROM datamart.tt_fct_examination_team_target_activity f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.calendar_dt_dim_id
WHERE cal.cdr_dt = :etl_date
;

-- ------------------------------------------------------------
-- 5. Fact Penalty Decision
-- ------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.tt_fct_penalty_decision_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tt_fct_penalty_decision_flat
SELECT
    f.fct_penalty_decision_id,
    f.pd_code,
    f.total_fine_amt,
    cal.cdr_dt                         AS cdr_dt
FROM datamart.tt_fct_penalty_decision f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.calendar_dt_dim_id
WHERE cal.cdr_dt = :etl_date
;

-- ------------------------------------------------------------
-- 6. Fact Penalty Decision Subject Behavior
-- ------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.tt_fct_penalty_decision_subject_behavior_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tt_fct_penalty_decision_subject_behavior_flat
SELECT
    f.fct_penalty_decision_subject_behavior_id,
    f.pd_code,
    f.pd_subject_code,
    f.violation_behavior_nm,
    f.total_fine_amt,
    cal.cdr_dt                         AS cdr_dt
FROM datamart.tt_fct_penalty_decision_subject_behavior f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.calendar_dt_dim_id
WHERE cal.cdr_dt = :etl_date
;

-- ------------------------------------------------------------
-- 7. Fact Penalty Decision Subject
-- ------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.tt_fct_penalty_decision_subject_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tt_fct_penalty_decision_subject_flat
SELECT
    f.fct_penalty_decision_subject_id,
    f.pd_code,
    f.subject_tp_code,
    cal.cdr_dt                         AS cdr_dt
FROM datamart.tt_fct_penalty_decision_subject f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.calendar_dt_dim_id
WHERE cal.cdr_dt = :etl_date
;

-- ------------------------------------------------------------
-- 8. Inspection Case List (Operational)
-- ------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.tt_opr_inspection_case_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tt_opr_inspection_case_list_flat
SELECT
    o.opr_inspection_case_list_id,
    o.inspection_team_target_code,
    o.inspection_team_code,
    o.target_nm,
    o.target_tp_code,
    o.form_tp_code,
    o.status_code,
    o.decision_dt,
    o.decision_year
FROM datamart.opr_inspection_case_list o
;

-- ------------------------------------------------------------
-- 9. Examination Case List (Operational)
-- ------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.tt_opr_examination_case_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tt_opr_examination_case_list_flat
SELECT
    o.opr_examination_case_list_id,
    o.examination_team_target_code,
    o.examination_team_code,
    o.target_nm,
    o.target_tp_code,
    o.form_tp_code,
    o.status_code,
    o.decision_dt,
    o.decision_year
FROM datamart.opr_examination_case_list o
;

-- ------------------------------------------------------------
-- 10. Penalty Decision List (Operational)
-- ------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.tt_opr_penalty_decision_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tt_opr_penalty_decision_list_flat
SELECT
    o.opr_penalty_decision_list_id,
    o.pd_subject_code,
    o.pd_code,
    o.subject_nm,
    o.subject_tp_code,
    o.form_tp_code,
    o.life_cycle_status_code,
    o.issued_dt,
    o.issued_year,
    o.total_fine_amt
FROM datamart.opr_penalty_decision_list o
;

-- ------------------------------------------------------------
-- 11. Petition List (Operational)
-- ------------------------------------------------------------
TRUNCATE TABLE IF EXISTS datamart.tt_opr_petition_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.tt_opr_petition_list_flat
SELECT
    o.petition_code,
    o.petition_category_code,
    o.content,
    o.life_cycle_status_code,
    o.received_dt,
    o.received_year
FROM datamart.opr_petition_list o
;
