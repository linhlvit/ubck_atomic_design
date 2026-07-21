-- ============================================================
-- Module TT (Thanh Tra) — Flat Table CREATE
-- 7 Fact + 4 Operational = 11 bảng flat
-- ============================================================

-- ------------------------------------------------------------
-- 1. Fact Inspection Team Activity
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_fct_inspection_team_activity_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT INSPECTION TEAM ACTIVITY
    fct_inspection_team_activity_id    String          COMMENT 'PK',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)  COMMENT 'Ngày quyết định — từ Calendar Date Dimension',

    -- From: INSPECTION TEAM DIMENSION
    inspection_team_code               String          COMMENT 'BK — mã hồ sơ đoàn thanh tra — từ Inspection Team Dimension',
    start_dt                           Nullable(Date)   COMMENT 'Ngày bắt đầu — từ Inspection Team Dimension',
    end_dt                             Nullable(Date)   COMMENT 'Ngày kết thúc — từ Inspection Team Dimension',
    content                            Nullable(String) COMMENT 'Nội dung tổng quát — từ Inspection Team Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), inspection_team_code)
COMMENT 'Flat table — Fact Inspection Team Activity × Calendar Date Dimension × Inspection Team Dimension'
;

-- ------------------------------------------------------------
-- 2. Fact Examination Team Activity
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_fct_examination_team_activity_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT EXAMINATION TEAM ACTIVITY
    fct_examination_team_activity_id   String          COMMENT 'PK',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)  COMMENT 'Ngày quyết định — từ Calendar Date Dimension',

    -- From: EXAMINATION TEAM DIMENSION
    examination_team_code              String          COMMENT 'BK — mã hồ sơ đoàn kiểm tra — từ Examination Team Dimension',
    start_dt                           Nullable(Date)   COMMENT 'Ngày bắt đầu — từ Examination Team Dimension',
    end_dt                             Nullable(Date)   COMMENT 'Ngày kết thúc — từ Examination Team Dimension',
    content                            Nullable(String) COMMENT 'Nội dung tổng quát — từ Examination Team Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), examination_team_code)
COMMENT 'Flat table — Fact Examination Team Activity × Calendar Date Dimension × Examination Team Dimension'
;

-- ------------------------------------------------------------
-- 3. Fact Inspection Team Target Activity
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_fct_inspection_team_target_activity_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT INSPECTION TEAM TARGET ACTIVITY
    fct_inspection_team_target_activity_id  String           COMMENT 'PK',
    inspection_team_code                    String           COMMENT 'Degenerate key — mã đoàn thanh tra',
    target_tp_code                          Nullable(String) COMMENT 'Loại đối tượng — map 1:1 từ nguồn',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                   Nullable(Date)   COMMENT 'Ngày quyết định — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), inspection_team_code, target_tp_code)
COMMENT 'Flat table — Fact Inspection Team Target Activity × Calendar Date Dimension'
;

-- ------------------------------------------------------------
-- 4. Fact Examination Team Target Activity
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_fct_examination_team_target_activity_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT EXAMINATION TEAM TARGET ACTIVITY
    fct_examination_team_target_activity_id String           COMMENT 'PK',
    examination_team_code                   String           COMMENT 'Degenerate key — mã vụ kiểm tra',
    target_tp_code                          Nullable(String) COMMENT 'Loại đối tượng — map 1:1 từ nguồn',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                   Nullable(Date)   COMMENT 'Ngày quyết định — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), examination_team_code, target_tp_code)
COMMENT 'Flat table — Fact Examination Team Target Activity × Calendar Date Dimension'
;

-- ------------------------------------------------------------
-- 5. Fact Penalty Decision
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_fct_penalty_decision_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT PENALTY DECISION
    fct_penalty_decision_id     String                     COMMENT 'PK',
    pd_code                     String                     COMMENT 'Degenerate key — mã quyết định xử phạt',
    total_fine_amt               Nullable(Decimal(23,2))    COMMENT 'Tổng mức phạt tiền',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                       Nullable(Date)             COMMENT 'Ngày ban hành quyết định — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), pd_code)
COMMENT 'Flat table — Fact Penalty Decision × Calendar Date Dimension'
;

-- ------------------------------------------------------------
-- 6. Fact Penalty Decision Subject Behavior
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_fct_penalty_decision_subject_behavior_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT PENALTY DECISION SUBJECT BEHAVIOR
    fct_penalty_decision_subject_behavior_id String                  COMMENT 'PK',
    pd_code                                  String                  COMMENT 'Degenerate key — mã quyết định xử phạt',
    pd_subject_code                          String                  COMMENT 'Degenerate key — mã đối tượng bị xử phạt',
    violation_behavior_nm                    Nullable(String)        COMMENT 'Tên hành vi vi phạm — dùng text-matching phân loại',
    total_fine_amt                            Nullable(Decimal(23,2)) COMMENT 'Tổng mức phạt tiền — từ Penalty Decision',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                    Nullable(Date)          COMMENT 'Ngày ban hành quyết định — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), pd_code, pd_subject_code)
COMMENT 'Flat table — Fact Penalty Decision Subject Behavior × Calendar Date Dimension'
;

-- ------------------------------------------------------------
-- 7. Fact Penalty Decision Subject
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_fct_penalty_decision_subject_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT PENALTY DECISION SUBJECT
    fct_penalty_decision_subject_id  String            COMMENT 'PK',
    pd_code                          String            COMMENT 'Degenerate key — mã quyết định xử phạt',
    subject_tp_code                  Nullable(String)  COMMENT 'Loại đối tượng — INDIVIDUAL/ORGANIZATION',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                            Nullable(Date)    COMMENT 'Ngày ban hành quyết định — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), pd_code)
COMMENT 'Flat table — Fact Penalty Decision Subject × Calendar Date Dimension'
;

-- ------------------------------------------------------------
-- 8. Inspection Case List (Operational)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_opr_inspection_case_list_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL INSPECTION CASE LIST
    opr_inspection_case_list_id    String            COMMENT 'PK',
    inspection_team_target_code    String            COMMENT 'BK — mã lượt đoàn×đối tượng',
    inspection_team_code           String            COMMENT 'Mã vụ việc — mã đoàn thanh tra',
    target_nm                      Nullable(String)  COMMENT 'Tên đối tượng được thanh tra',
    target_tp_code                 Nullable(String)  COMMENT 'Phân loại đối tượng',
    form_tp_code                   Nullable(String)  COMMENT 'Loại hình — scheme TT_REVIEW_FORM_TYPE',
    status_code                    Nullable(String)  COMMENT 'Trạng thái — ETL-derived',
    decision_dt                    Nullable(Date)     COMMENT 'Ngày ban hành quyết định',
    decision_year                  Nullable(Int64)    COMMENT 'Năm ban hành quyết định'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(decision_dt))
ORDER BY (assumeNotNull(decision_dt), inspection_team_target_code)
COMMENT 'Flat table — Inspection Case List (Operational)'
;

-- ------------------------------------------------------------
-- 9. Examination Case List (Operational)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_opr_examination_case_list_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL EXAMINATION CASE LIST
    opr_examination_case_list_id   String            COMMENT 'PK',
    examination_team_target_code   String            COMMENT 'BK — mã lượt vụ×đối tượng',
    examination_team_code          String            COMMENT 'Mã vụ việc — mã đoàn kiểm tra',
    target_nm                      Nullable(String)  COMMENT 'Tên đối tượng được kiểm tra',
    target_tp_code                 Nullable(String)  COMMENT 'Phân loại đối tượng',
    form_tp_code                   Nullable(String)  COMMENT 'Loại hình — scheme TT_REVIEW_FORM_TYPE',
    status_code                    Nullable(String)  COMMENT 'Trạng thái — ETL-derived',
    decision_dt                    Nullable(Date)     COMMENT 'Ngày ban hành quyết định',
    decision_year                  Nullable(Int64)    COMMENT 'Năm ban hành quyết định'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(decision_dt))
ORDER BY (assumeNotNull(decision_dt), examination_team_target_code)
COMMENT 'Flat table — Examination Case List (Operational)'
;

-- ------------------------------------------------------------
-- 10. Penalty Decision List (Operational)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_opr_penalty_decision_list_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL PENALTY DECISION LIST
    opr_penalty_decision_list_id   String                    COMMENT 'PK',
    pd_subject_code                String                    COMMENT 'BK — mã lượt QĐ×đối tượng',
    pd_code                        String                    COMMENT 'Mã vụ việc — mã quyết định xử phạt',
    subject_nm                     Nullable(String)          COMMENT 'Tên đối tượng bị xử phạt',
    subject_tp_code                Nullable(String)          COMMENT 'Phân loại đối tượng',
    form_tp_code                   Nullable(String)          COMMENT 'Loại hình — ETL-derived qua Violation Case',
    life_cycle_status_code         String                    COMMENT 'Trạng thái — scheme PENALTY_DECISION_STATUS',
    issued_dt                      Nullable(Date)             COMMENT 'Ngày ban hành quyết định',
    issued_year                    Nullable(Int64)            COMMENT 'Năm ban hành quyết định',
    total_fine_amt                  Nullable(Decimal(23,2))   COMMENT 'Tổng mức phạt tiền'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(issued_dt))
ORDER BY (assumeNotNull(issued_dt), pd_subject_code)
COMMENT 'Flat table — Penalty Decision List (Operational)'
;

-- ------------------------------------------------------------
-- 11. Petition List (Operational)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_opr_petition_list_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL PETITION LIST
    petition_code                  String            COMMENT 'PK — mã đơn thư',
    petition_category_code         Nullable(String)  COMMENT 'Loại đơn — FEEDBACK_SUGGESTION/COMPLAINT/DENUNCIATION',
    content                        Nullable(String)  COMMENT 'Nội dung tóm tắt đơn thư',
    life_cycle_status_code         Nullable(String)  COMMENT 'Trạng thái — RECEIVED/PROCESSED',
    received_dt                    Nullable(Date)     COMMENT 'Ngày tiếp nhận đơn thư',
    received_year                  Nullable(Int64)    COMMENT 'Năm tiếp nhận'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(received_dt))
ORDER BY (assumeNotNull(received_dt), petition_code)
COMMENT 'Flat table — Petition List (Operational)'
;
