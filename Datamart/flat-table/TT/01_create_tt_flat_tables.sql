-- ============================================================
-- Module TT (Thanh Tra) — Flat Table CREATE
-- 9 Fact + 4 Operational = 13 bảng flat
-- ============================================================

-- ------------------------------------------------------------
-- 1. Fact Inspection Team Activity
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_fct_inspection_team_activity_flat ON CLUSTER 'my_cluster'
(
    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)      COMMENT 'Ngày quyết định thanh tra — từ Calendar Date Dimension',

    -- From: INSPECTION TEAM DIMENSION
    inspection_team_code                String              COMMENT 'BK — mã hồ sơ đoàn thanh tra — từ Inspection Team Dimension',
    start_dt                            Nullable(Date)       COMMENT 'Ngày bắt đầu đoàn thanh tra — từ Inspection Team Dimension',
    end_dt                               Nullable(Date)       COMMENT 'Ngày kết thúc đoàn thanh tra — từ Inspection Team Dimension',
    content                             Nullable(String)    COMMENT 'Nội dung tổng quát cuộc thanh tra — từ Inspection Team Dimension',
    inspection_team_src_stm_code        Nullable(String)    COMMENT 'Mã hệ thống nguồn — từ Inspection Team Dimension'
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
    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)      COMMENT 'Ngày quyết định kiểm tra — từ Calendar Date Dimension',

    -- From: EXAMINATION TEAM DIMENSION
    examination_team_code               String              COMMENT 'BK — mã hồ sơ đoàn kiểm tra — từ Examination Team Dimension',
    start_dt                            Nullable(Date)       COMMENT 'Ngày bắt đầu đoàn kiểm tra — từ Examination Team Dimension',
    end_dt                               Nullable(Date)       COMMENT 'Ngày kết thúc đoàn kiểm tra — từ Examination Team Dimension',
    content                             Nullable(String)    COMMENT 'Nội dung kiểm tra tổng quát — từ Examination Team Dimension',
    examination_team_src_stm_code       Nullable(String)    COMMENT 'Mã hệ thống nguồn — từ Examination Team Dimension'
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
    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                   Nullable(Date)  COMMENT 'Ngày quyết định thanh tra (join qua Inspection Team) — từ Calendar Date Dimension',

    -- From: INSPECTION TEAM TARGET DIMENSION
    inspection_team_target_code             String           COMMENT 'BK per-row unique — từ Inspection Team Target Dimension',
    target_tp_code                          Nullable(String) COMMENT 'Loại đối tượng — từ Inspection Team Target Dimension',
    inspection_team_target_src_stm_code     Nullable(String) COMMENT 'Mã hệ thống nguồn — từ Inspection Team Target Dimension',

    -- From: INSPECTION TEAM DIMENSION (Dimension cha)
    inspection_team_code                    String           COMMENT 'BK — mã hồ sơ đoàn thanh tra — từ Inspection Team Dimension',
    start_dt                                Nullable(Date)   COMMENT 'Ngày bắt đầu đoàn thanh tra — từ Inspection Team Dimension',
    end_dt                                    Nullable(Date)   COMMENT 'Ngày kết thúc đoàn thanh tra — từ Inspection Team Dimension',
    content                                 Nullable(String) COMMENT 'Nội dung tổng quát cuộc thanh tra — từ Inspection Team Dimension',
    inspection_team_src_stm_code            Nullable(String) COMMENT 'Mã hệ thống nguồn — từ Inspection Team Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), inspection_team_target_code)
COMMENT 'Flat table — Fact Inspection Team Target Activity × Calendar Date Dimension × Inspection Team Target Dimension × Inspection Team Dimension'
;

-- ------------------------------------------------------------
-- 4. Fact Examination Team Target Activity
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_fct_examination_team_target_activity_flat ON CLUSTER 'my_cluster'
(
    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                    Nullable(Date)  COMMENT 'Ngày quyết định kiểm tra (join qua Examination Team) — từ Calendar Date Dimension',

    -- From: EXAMINATION TEAM TARGET DIMENSION
    examination_team_target_code             String           COMMENT 'BK per-row unique — từ Examination Team Target Dimension',
    target_tp_code                           Nullable(String) COMMENT 'Loại đối tượng — từ Examination Team Target Dimension',
    examination_team_target_src_stm_code     Nullable(String) COMMENT 'Mã hệ thống nguồn — từ Examination Team Target Dimension',

    -- From: EXAMINATION TEAM DIMENSION (Dimension cha)
    examination_team_code                    String           COMMENT 'BK — mã hồ sơ đoàn kiểm tra — từ Examination Team Dimension',
    start_dt                                 Nullable(Date)   COMMENT 'Ngày bắt đầu đoàn kiểm tra — từ Examination Team Dimension',
    end_dt                                     Nullable(Date)   COMMENT 'Ngày kết thúc đoàn kiểm tra — từ Examination Team Dimension',
    content                                  Nullable(String) COMMENT 'Nội dung kiểm tra tổng quát — từ Examination Team Dimension',
    examination_team_src_stm_code            Nullable(String) COMMENT 'Mã hệ thống nguồn — từ Examination Team Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), examination_team_target_code)
COMMENT 'Flat table — Fact Examination Team Target Activity × Calendar Date Dimension × Examination Team Target Dimension × Examination Team Dimension'
;

-- ------------------------------------------------------------
-- 5. Fact Penalty Decision
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_fct_penalty_decision_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT PENALTY DECISION
    total_fine_amt                      Nullable(Decimal(23,2))     COMMENT 'Tổng mức phạt tiền — measure',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)              COMMENT 'Ngày ban hành quyết định xử phạt — từ Calendar Date Dimension',

    -- From: PENALTY DECISION DIMENSION
    penalty_decision_code               String                      COMMENT 'BK — mã quyết định xử phạt — từ Penalty Decision Dimension',
    penalty_decision_src_stm_code       Nullable(String)            COMMENT 'Mã hệ thống nguồn — từ Penalty Decision Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), penalty_decision_code)
COMMENT 'Flat table — Fact Penalty Decision × Calendar Date Dimension × Penalty Decision Dimension'
;

-- ------------------------------------------------------------
-- 6. Fact Penalty Decision Subject Behavior
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_fct_penalty_decision_subject_behavior_flat ON CLUSTER 'my_cluster'
(
    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                     Nullable(Date)   COMMENT 'Ngày ban hành quyết định xử phạt (join qua Penalty Decision Subject → Penalty Decision) — từ Calendar Date Dimension',

    -- From: PENALTY DECISION SUBJECT BEHAVIOR DIMENSION
    penalty_decision_subject_behavior_code    String           COMMENT 'BK per-row unique — từ Penalty Decision Subject Behavior Dimension',
    violation_behavior_nm                     Nullable(String) COMMENT 'Tên hành vi vi phạm — từ Penalty Decision Subject Behavior Dimension',
    penalty_decision_subject_behavior_src_stm_code Nullable(String) COMMENT 'Mã hệ thống nguồn — từ Penalty Decision Subject Behavior Dimension',

    -- From: PENALTY DECISION DIMENSION
    penalty_decision_code                     String           COMMENT 'BK — mã quyết định xử phạt — từ Penalty Decision Dimension',
    penalty_decision_src_stm_code             Nullable(String) COMMENT 'Mã hệ thống nguồn — từ Penalty Decision Dimension',

    -- From: PENALTY DECISION SUBJECT DIMENSION
    penalty_decision_subject_code             String           COMMENT 'BK per-row unique — từ Penalty Decision Subject Dimension',
    subject_tp_code                           Nullable(String) COMMENT 'Loại đối tượng — từ Penalty Decision Subject Dimension',
    penalty_decision_subject_src_stm_code     Nullable(String) COMMENT 'Mã hệ thống nguồn — từ Penalty Decision Subject Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), penalty_decision_subject_behavior_code)
COMMENT 'Flat table — Fact Penalty Decision Subject Behavior × Calendar Date Dimension × Penalty Decision Subject Behavior Dimension × Penalty Decision Dimension × Penalty Decision Subject Dimension'
;

-- ------------------------------------------------------------
-- 7. Fact Penalty Decision Subject
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_fct_penalty_decision_subject_flat ON CLUSTER 'my_cluster'
(
    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                Nullable(Date)    COMMENT 'Ngày ban hành quyết định xử phạt (join qua Penalty Decision) — từ Calendar Date Dimension',

    -- From: PENALTY DECISION SUBJECT DIMENSION
    penalty_decision_subject_code        String            COMMENT 'BK per-row unique — từ Penalty Decision Subject Dimension',
    subject_tp_code                      Nullable(String)  COMMENT 'Loại đối tượng — từ Penalty Decision Subject Dimension',
    penalty_decision_subject_src_stm_code Nullable(String) COMMENT 'Mã hệ thống nguồn — từ Penalty Decision Subject Dimension',

    -- From: PENALTY DECISION DIMENSION
    penalty_decision_code                String            COMMENT 'BK — mã quyết định xử phạt — từ Penalty Decision Dimension',
    penalty_decision_src_stm_code        Nullable(String)  COMMENT 'Mã hệ thống nguồn — từ Penalty Decision Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), penalty_decision_subject_code)
COMMENT 'Flat table — Fact Penalty Decision Subject × Calendar Date Dimension × Penalty Decision Subject Dimension × Penalty Decision Dimension'
;

-- ------------------------------------------------------------
-- 8. Operational Inspection Case List
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_opr_inspection_case_list_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL INSPECTION CASE LIST
    inspection_team_target_code   String              COMMENT 'PK — mã lượt đoàn×đối tượng, unique per dòng',
    inspection_team_code          String              COMMENT 'Mã vụ việc — mã đoàn thanh tra',
    target_nm                     Nullable(String)    COMMENT 'Tên đối tượng được thanh tra',
    target_tp_code                Nullable(String)    COMMENT 'Phân loại đối tượng',
    form_tp_code                  Nullable(String)    COMMENT 'Loại hình — scheme TT_REVIEW_FORM_TYPE',
    status_code                   Nullable(String)    COMMENT 'Trạng thái — ETL-derived từ Start_Date/End_Date',
    decision_dt                   Nullable(Date)      COMMENT 'Ngày ban hành quyết định thanh tra',
    decision_year                 Nullable(Int64)     COMMENT 'Năm ban hành quyết định — slicer',
    src_stm_code                  String              COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(decision_dt))
ORDER BY (assumeNotNull(decision_dt), inspection_team_target_code)
COMMENT 'Flat table — Operational Inspection Case List'
;

-- ------------------------------------------------------------
-- 9. Operational Examination Case List
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_opr_examination_case_list_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL EXAMINATION CASE LIST
    examination_team_target_code   String              COMMENT 'PK — mã lượt vụ×đối tượng, unique per dòng',
    examination_team_code          String              COMMENT 'Mã vụ việc — mã đoàn kiểm tra',
    target_nm                      Nullable(String)    COMMENT 'Tên đối tượng được kiểm tra',
    target_tp_code                 Nullable(String)    COMMENT 'Phân loại đối tượng',
    form_tp_code                   Nullable(String)    COMMENT 'Loại hình — scheme TT_REVIEW_FORM_TYPE',
    status_code                    Nullable(String)    COMMENT 'Trạng thái — ETL-derived từ Start_Date/End_Date',
    decision_dt                    Nullable(Date)      COMMENT 'Ngày ban hành quyết định kiểm tra',
    decision_year                  Nullable(Int64)     COMMENT 'Năm ban hành quyết định — slicer',
    src_stm_code                   String              COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(decision_dt))
ORDER BY (assumeNotNull(decision_dt), examination_team_target_code)
COMMENT 'Flat table — Operational Examination Case List'
;

-- ------------------------------------------------------------
-- 10. Operational Penalty Decision List
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_opr_penalty_decision_list_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL PENALTY DECISION LIST
    pd_subject_code            String                      COMMENT 'PK — mã lượt QĐ×đối tượng, unique per dòng',
    violation_case_code         Nullable(String)            COMMENT 'Mã vụ việc — mã hồ sơ thanh tra/kiểm tra gốc phát sinh quyết định xử phạt',
    subject_nm                 Nullable(String)            COMMENT 'Tên đối tượng bị xử phạt',
    subject_tp_code            Nullable(String)            COMMENT 'Phân loại đối tượng (INDIVIDUAL/ORGANIZATION)',
    form_tp_code                Nullable(String)            COMMENT 'Loại hình — ETL-derived qua Violation Case → Inspection/Examination Team, nullable nếu không từ đoàn TT/KT',
    life_cycle_status_code     String                      COMMENT 'Trạng thái — scheme PENALTY_DECISION_STATUS (7 giá trị)',
    issued_dt                  Nullable(Date)              COMMENT 'Ngày ban hành quyết định',
    issued_year                Nullable(Int64)             COMMENT 'Năm ban hành quyết định — slicer',
    total_fine_amt              Nullable(Decimal(23,2))     COMMENT 'Tổng mức phạt tiền đối với đối tượng này',
    src_stm_code                String                      COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(issued_dt))
ORDER BY (assumeNotNull(issued_dt), pd_subject_code)
COMMENT 'Flat table — Operational Penalty Decision List'
;

-- ------------------------------------------------------------
-- 11. Operational Petition List
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_opr_petition_list_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL PETITION LIST
    petition_code            String              COMMENT 'BK — mã đơn thư tự sinh UNIQUE',
    petition_category_code   Nullable(String)    COMMENT 'Loại đơn — 3 giá trị FEEDBACK_SUGGESTION/COMPLAINT/DENUNCIATION',
    content                  Nullable(String)    COMMENT 'Nội dung tóm tắt đơn thư',
    life_cycle_status_code   Nullable(String)    COMMENT 'Trạng thái — 2 giá trị RECEIVED/PROCESSED',
    received_dt              Nullable(Date)      COMMENT 'Ngày tiếp nhận đơn thư',
    received_year            Nullable(Int64)     COMMENT 'Năm tiếp nhận — slicer',
    src_stm_code              String              COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(received_dt))
ORDER BY (assumeNotNull(received_dt), petition_code)
COMMENT 'Flat table — Operational Petition List'
;

-- ------------------------------------------------------------
-- 12. Fact Inspection Team Violation Behavior
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_fct_inspection_team_violation_behavior_flat ON CLUSTER 'my_cluster'
(
    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                          Nullable(Date)   COMMENT 'Ngày quyết định thanh tra (join qua Inspection Team) — từ Calendar Date Dimension',

    -- From: INSPECTION TEAM VIOLATION BEHAVIOR DIMENSION
    violation_record_behavior_code                  String           COMMENT 'BK per-row unique — từ Inspection Team Violation Behavior Dimension',
    violation_behavior_nm                           Nullable(String) COMMENT 'Tên hành vi vi phạm — từ Inspection Team Violation Behavior Dimension',
    inspection_team_violation_behavior_src_stm_code Nullable(String) COMMENT 'Mã hệ thống nguồn — từ Inspection Team Violation Behavior Dimension',

    -- From: INSPECTION TEAM DIMENSION (Dimension cha)
    inspection_team_code                            String           COMMENT 'BK — mã hồ sơ đoàn thanh tra — từ Inspection Team Dimension',
    start_dt                                        Nullable(Date)   COMMENT 'Ngày bắt đầu đoàn thanh tra — từ Inspection Team Dimension',
    end_dt                                          Nullable(Date)   COMMENT 'Ngày kết thúc đoàn thanh tra — từ Inspection Team Dimension',
    content                                         Nullable(String) COMMENT 'Nội dung tổng quát cuộc thanh tra — từ Inspection Team Dimension',
    inspection_team_src_stm_code                    Nullable(String) COMMENT 'Mã hệ thống nguồn — từ Inspection Team Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), violation_record_behavior_code)
COMMENT 'Flat table — Fact Inspection Team Violation Behavior × Calendar Date Dimension × Inspection Team Violation Behavior Dimension × Inspection Team Dimension'
;

-- ------------------------------------------------------------
-- 13. Fact Examination Team Violation Behavior
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.tt_fct_examination_team_violation_behavior_flat ON CLUSTER 'my_cluster'
(
    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                          Nullable(Date)   COMMENT 'Ngày quyết định kiểm tra (join qua Examination Team) — từ Calendar Date Dimension',

    -- From: EXAMINATION TEAM VIOLATION BEHAVIOR DIMENSION
    violation_record_behavior_code                  String           COMMENT 'BK per-row unique — từ Examination Team Violation Behavior Dimension',
    violation_behavior_nm                           Nullable(String) COMMENT 'Tên hành vi vi phạm — từ Examination Team Violation Behavior Dimension',
    examination_team_violation_behavior_src_stm_code Nullable(String) COMMENT 'Mã hệ thống nguồn — từ Examination Team Violation Behavior Dimension',

    -- From: EXAMINATION TEAM DIMENSION (Dimension cha)
    examination_team_code                           String           COMMENT 'BK — mã hồ sơ đoàn kiểm tra — từ Examination Team Dimension',
    start_dt                                        Nullable(Date)   COMMENT 'Ngày bắt đầu đoàn kiểm tra — từ Examination Team Dimension',
    end_dt                                          Nullable(Date)   COMMENT 'Ngày kết thúc đoàn kiểm tra — từ Examination Team Dimension',
    content                                         Nullable(String) COMMENT 'Nội dung kiểm tra tổng quát — từ Examination Team Dimension',
    examination_team_src_stm_code                   Nullable(String) COMMENT 'Mã hệ thống nguồn — từ Examination Team Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), violation_record_behavior_code)
COMMENT 'Flat table — Fact Examination Team Violation Behavior × Calendar Date Dimension × Examination Team Violation Behavior Dimension × Examination Team Dimension'
;
