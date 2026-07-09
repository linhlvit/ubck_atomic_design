-- ============================================================
-- NHNCK Flat Tables — CREATE
-- Module: Người Hành Nghề Chứng Khoán (NHNCK)
-- Generated: Phase 3 LLD Datamart
-- 11 bảng: 2 fact + 9 operational
-- ============================================================


-- ============================================================
-- 1. FACT: nhnck_fct_practitioner_license_certificate_snpst_flat
--    Periodic Snapshot CCHN × tháng
--    Joins: Calendar Date (snpst_dt JOIN + issue_dt LEFT JOIN) × securities_practitioner_dim × classification_dim ×2
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.nhnck_fct_practitioner_license_certificate_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Practitioner License Certificate Snapshot
    practitioner_dim_id             String              COMMENT 'FK → Securities Practitioner Dimension',
    issue_dt_dim_id                 String              COMMENT 'FK → Calendar Date Dimension (ngày cấp)',
    snpst_dt_dim_id                 String              COMMENT 'FK → Calendar Date Dimension (ngày snapshot)',
    certificate_tp_dim_id           String              COMMENT 'FK → SP License Certificate Type Dimension',
    license_certificate_document_code    String              COMMENT 'DD — BK CCHN',
    certificate_tp_unique_key       String              COMMENT 'Mã loại CCHN — dư thừa để filter/display nhanh',
    allow_reissue_indicator         String              COMMENT 'Cho phép cấp lại (Y/N)',
    is_reissue_indicator            String              COMMENT 'Là CCHN cấp lại (Y/N)',
    certificate_issue_dt            Nullable(Date)      COMMENT 'Ngày cấp CCHN',
    revocation_dt                   Nullable(Date)      COMMENT 'Ngày thu hồi CCHN — NULL nếu chưa thu hồi',
    decision_tp_code                Nullable(String)    COMMENT 'Loại quyết định — scheme: DECISION_TYPE',

    -- From: CALENDAR DATE DIMENSION (Snapshot Date)
    snpst_cdr_dt                    Nullable(Date)      COMMENT 'Ngày snapshot — từ Calendar Date Dimension',

    -- From: CALENDAR DATE DIMENSION (Issue Date)
    issue_cdr_dt                    Nullable(Date)      COMMENT 'Ngày cấp — từ Calendar Date Dimension',

    -- From: SECURITIES PRACTITIONER DIMENSION
    practitioner_code               Nullable(String)    COMMENT 'Mã NHN — từ Securities Practitioner Dimension',
    practitioner_full_nm            Nullable(String)    COMMENT 'Họ tên NHN — từ Securities Practitioner Dimension',
    practitioner_education_level_code    Nullable(String)    COMMENT 'Trình độ học vấn — từ Securities Practitioner Dimension',
    practitioner_nationality_code   Nullable(String)    COMMENT 'Mã quốc tịch — từ Securities Practitioner Dimension',
    practitioner_birth_dt           Nullable(Date)      COMMENT 'Ngày sinh — từ Securities Practitioner Dimension',
    practitioner_practice_status_code    Nullable(String)    COMMENT 'Trạng thái hành nghề — từ Securities Practitioner Dimension',

    -- From: CLASSIFICATION DIMENSION (Certificate Type)
    certificate_tp_scm_code         Nullable(String)    COMMENT 'Mã scheme loại CCHN — từ Classification Dimension',
    certificate_tp_scm_nm           Nullable(String)    COMMENT 'Tên scheme loại CCHN — từ Classification Dimension',
    certificate_tp_cl_code          Nullable(String)    COMMENT 'Mã loại CCHN — từ Classification Dimension',
    certificate_tp_cl_nm            Nullable(String)    COMMENT 'Tên loại CCHN — từ Classification Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), license_certificate_document_code)
COMMENT 'Flat table — Fact Practitioner License Certificate Snapshot × Calendar Date × Securities Practitioner Dimension × Classification Dimension'
;


-- ============================================================
-- 2. FACT: nhnck_fct_practitioner_daily_snpst_flat
--    Periodic Snapshot NHN × ngày
--    Joins: Calendar Date (snpst_dt JOIN) × securities_practitioner_dim
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.nhnck_fct_practitioner_daily_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Practitioner Daily Snapshot
    practitioner_dim_id             String              COMMENT 'FK → Securities Practitioner Dimension',
    snpst_dt_dim_id         String              COMMENT 'FK → Calendar Date Dimension (ngày snapshot)',
    age                     Nullable(Int64)     COMMENT 'Tuổi NHN tại ngày snapshot',
    has_active_violation            String              COMMENT 'TRUE nếu có vi phạm đang hoạt động',

    -- From: CALENDAR DATE DIMENSION (Snapshot Date)
    snpst_cdr_dt            Nullable(Date)      COMMENT 'Ngày — từ Calendar Date Dimension',

    -- From: SECURITIES PRACTITIONER DIMENSION
    practitioner_code               Nullable(String)    COMMENT 'Mã NHN — từ Securities Practitioner Dimension',
    practitioner_full_nm            Nullable(String)    COMMENT 'Họ tên NHN — từ Securities Practitioner Dimension',
    practitioner_education_level_code        Nullable(String)    COMMENT 'Trình độ học vấn — từ Securities Practitioner Dimension',
    practitioner_nationality_code           Nullable(String)    COMMENT 'Mã quốc tịch — từ Securities Practitioner Dimension',
    practitioner_birth_dt            Nullable(Date)      COMMENT 'Ngày sinh — từ Securities Practitioner Dimension',
    practitioner_practice_status_code   Nullable(String)    COMMENT 'Trạng thái hành nghề — từ Securities Practitioner Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), practitioner_dim_id)
COMMENT 'Flat table — Fact Practitioner Daily Snapshot × Calendar Date × Securities Practitioner Dimension'
;


-- ============================================================
-- 3. OPERATIONAL: opr_practitioner_360_profile_flat
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.nhnck_opr_practitioner_360_profile_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner 360 Profile
    practitioner_code           String              COMMENT 'PK — Mã NHN',
    full_nm             Nullable(String)    COMMENT 'Họ tên đầy đủ NHN',
    birth_dt             Nullable(Date)      COMMENT 'Ngày sinh NHN',
    age                 Nullable(Int64)     COMMENT 'Tuổi NHN tại thời điểm populate',
    nationality_code            Nullable(String)    COMMENT 'Mã quốc tịch',
    nationality_nm              Nullable(String)    COMMENT 'Tên quốc tịch',
    identification_nbr          Nullable(String)    COMMENT 'Số CCCD/Hộ chiếu',
    workplace_nm        Nullable(String)    COMMENT 'Nơi công tác hiện tại',
    practice_status_code    Nullable(String)    COMMENT 'Trạng thái hành nghề — scheme: PRACTICE_STATUS',
    practice_status_nm      Nullable(String)    COMMENT 'Tên trạng thái hành nghề',
    active_certificate_tp_code    Nullable(String)    COMMENT 'Loại CCHN hiện tại — scheme: CERTIFICATE_TYPE',
    active_certificate_tp_nm      Nullable(String)    COMMENT 'Tên loại CCHN hiện tại',
    active_certificate_nbr        Nullable(String)    COMMENT 'Số CCHN hiện tại',
    src_stm_code        String              COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(birth_dt))
ORDER BY (practitioner_code)
COMMENT 'Flat table — Practitioner 360 Profile (latest state per NHN)'
;


-- ============================================================
-- 4. OPERATIONAL: opr_practitioner_related_party_profile_flat
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.nhnck_opr_practitioner_related_party_profile_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner Related Party Profile
    practitioner_code           String              COMMENT 'PK (1/2) — Mã NHN',
    related_party_code          String              COMMENT 'PK (2/2) — Mã người liên quan',
    related_individual_full_nm     Nullable(String)    COMMENT 'Họ tên người liên quan',
    rltnp_tp_code       String              COMMENT 'Mã loại quan hệ — scheme: RELATIONSHIP_TYPE',
    rltnp_tp_nm         Nullable(String)    COMMENT 'Tên loại quan hệ',
    related_individual_occupation         Nullable(String)    COMMENT 'Nghề nghiệp người liên quan',
    related_individual_workplace   Nullable(String)    COMMENT 'Nơi làm việc người liên quan',
    related_individual_identity_nbr      Nullable(String)    COMMENT 'Số CMND/CCCD người liên quan',
    country_code            Nullable(String)    COMMENT 'Mã quốc gia người liên quan',
    country_nm              Nullable(String)    COMMENT 'Tên quốc gia',
    related_individual_adr         Nullable(String)    COMMENT 'Địa chỉ người liên quan',
    src_stm_code        String              COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (practitioner_code, related_party_code)
COMMENT 'Flat table — Practitioner Related Party Profile (1 người liên quan per NHN)'
;


-- ============================================================
-- 5. OPERATIONAL: opr_practitioner_list_company_role_flat
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.nhnck_opr_practitioner_list_company_role_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner Listed Company Role
    practitioner_code               String              COMMENT 'PK (1/2) — Mã NHN',
    organization_employment_rpt_code        String              COMMENT 'PK (2/2) — Mã báo cáo tổ chức',
    practitioner_workplace_at_rpt   Nullable(String)    COMMENT 'Tên nơi công tác tại thời điểm báo cáo',
    practitioner_position_at_rpt         Nullable(String)    COMMENT 'Vị trí/chức vụ tại thời điểm báo cáo',
    organization_tp_code             Nullable(String)    COMMENT 'Loại tổ chức — scheme: ORG_TYPE',
    securities_organization_reference_code       Nullable(String)    COMMENT 'Mã tổ chức tham chiếu',
    employment_status           Nullable(String)    COMMENT 'Trạng thái vai trò (Active/Inactive)',
    hire_dt                 Nullable(Date)      COMMENT 'Ngày bắt đầu làm việc',
    termination_dt                  Nullable(Date)      COMMENT 'Ngày kết thúc làm việc — NULL nếu hiện tại',
    src_stm_code            String              COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (practitioner_code, organization_employment_rpt_code)
COMMENT 'Flat table — Practitioner Listed Company Role (1 báo cáo tổ chức per NHN)'
;


-- ============================================================
-- 6. OPERATIONAL: opr_practitioner_certificate_hist_flat
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.nhnck_opr_practitioner_certificate_hist_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner Certificate History
    practitioner_code               String              COMMENT 'PK (1/2) — Mã NHN',
    license_certificate_document_code    String              COMMENT 'PK (2/2) — Mã CCHN',
    certificate_nbr                 Nullable(String)    COMMENT 'Số CCHN',
    certificate_tp_code             Nullable(String)    COMMENT 'Loại CCHN — scheme: CERTIFICATE_TYPE',
    certificate_tp_nm               Nullable(String)    COMMENT 'Tên loại CCHN',
    issue_dt                 Nullable(Date)      COMMENT 'Ngày cấp CCHN',
    revocation_dt           Nullable(Date)      COMMENT 'Ngày thu hồi — NULL nếu chưa thu hồi',
    issue_decision_nbr           Nullable(String)    COMMENT 'Số quyết định cấp',
    revocation_decision_nbr     Nullable(String)    COMMENT 'Số quyết định thu hồi',
    process_status_code             Nullable(String)    COMMENT 'Trạng thái xử lý hồ sơ — scheme: PROCESS_STATUS',
    process_status_nm               Nullable(String)    COMMENT 'Tên trạng thái xử lý hồ sơ',
    src_stm_code            String              COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(issue_dt))
ORDER BY (assumeNotNull(issue_dt), practitioner_code, license_certificate_document_code)
COMMENT 'Flat table — Practitioner Certificate History (1 CCHN per NHN)'
;


-- ============================================================
-- 7. OPERATIONAL: opr_practitioner_employment_hist_flat
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.nhnck_opr_practitioner_employment_hist_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner Employment History
    practitioner_code           String              COMMENT 'PK (1/2) — Mã NHN',
    organization_employment_rpt_code    String              COMMENT 'PK (2/2) — Mã báo cáo tổ chức',
    securities_organization_reference_code   Nullable(String)    COMMENT 'Mã tổ chức tham chiếu',
    securities_organization_reference_nm     Nullable(String)    COMMENT 'Tên tổ chức',
    organization_tp_code         Nullable(String)    COMMENT 'Loại tổ chức — scheme: ORG_TYPE',
    organization_tp_nm           Nullable(String)    COMMENT 'Tên loại tổ chức',
    practitioner_position_at_rpt     Nullable(String)    COMMENT 'Vị trí/chức vụ tại thời điểm báo cáo',
    practitioner_department_at_rpt    Nullable(String)    COMMENT 'Phòng ban tại thời điểm báo cáo',
    hire_dt             Nullable(Date)      COMMENT 'Ngày bắt đầu làm việc',
    termination_dt              Nullable(Date)      COMMENT 'Ngày kết thúc làm việc — NULL nếu hiện tại',
    src_stm_code        String              COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(hire_dt))
ORDER BY (assumeNotNull(hire_dt), practitioner_code, organization_employment_rpt_code)
COMMENT 'Flat table — Practitioner Employment History (1 lần công tác per NHN)'
;


-- ============================================================
-- 8. OPERATIONAL: opr_practitioner_violation_hist_flat
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.nhnck_opr_practitioner_violation_hist_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner Violation History
    practitioner_code           String              COMMENT 'PK (1/2) — Mã NHN',
    conduct_violation_code    String              COMMENT 'PK (2/2) — Mã vi phạm',
    record_tp_code        Nullable(String)    COMMENT 'Hình thức xử phạt — scheme: RECORD_TYPE',
    record_tp_nm          Nullable(String)    COMMENT 'Tên hình thức xử phạt',
    note                Nullable(String)    COMMENT 'Nội dung vi phạm',
    record_status_code        String              COMMENT 'Trạng thái vi phạm — scheme: RECORD_STATUS',
    record_status_nm          Nullable(String)    COMMENT 'Tên trạng thái vi phạm',
    decision_nbr            Nullable(String)    COMMENT 'Số quyết định xử phạt',
    decision_signed_dt      Nullable(Date)      COMMENT 'Ngày quyết định xử phạt',
    src_stm_code        String              COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(decision_signed_dt))
ORDER BY (assumeNotNull(decision_signed_dt), practitioner_code, conduct_violation_code)
COMMENT 'Flat table — Practitioner Violation History (1 vi phạm per NHN)'
;


-- ============================================================
-- 9. OPERATIONAL: opr_practitioner_exam_hist_flat
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.nhnck_opr_practitioner_exam_hist_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner Exam History
    practitioner_code                   String              COMMENT 'PK (1/2) — Mã NHN',
    examination_assessment_result_code         String              COMMENT 'PK (2/2) — Mã kết quả thi',
    assessment_nm                     Nullable(String)    COMMENT 'Tên đợt thi',
    rpt_year                      Nullable(Int64)     COMMENT 'Năm báo cáo đợt thi',
    examination_session_nbr                Nullable(Int64)     COMMENT 'Kỳ thi trong năm',
    examination_period                 Nullable(String)    COMMENT 'Kỳ thi dạng chuỗi (VD: 2025_1)',
    examination_start_dt                Nullable(Date)      COMMENT 'Ngày thi',
    law_score                    Nullable(String)    COMMENT 'Điểm thi pháp luật',
    specialization_score         Nullable(String)    COMMENT 'Điểm thi chuyên môn',
    law_result_code               Nullable(String)    COMMENT 'Kết quả thi pháp luật — scheme: EXAM_RESULT',
    law_result_nm                 Nullable(String)    COMMENT 'Tên kết quả thi pháp luật',
    specialization_result_code    Nullable(String)    COMMENT 'Kết quả thi chuyên môn — scheme: EXAM_RESULT',
    specialization_result_nm      Nullable(String)    COMMENT 'Tên kết quả thi chuyên môn',
    overall_result_code              Nullable(String)    COMMENT 'Kết quả tổng hợp — scheme: EXAM_RESULT',
    overall_result_nm                Nullable(String)    COMMENT 'Tên kết quả tổng hợp',
    decision_nbr                    Nullable(String)    COMMENT 'Số quyết định công bố kết quả',
    decision_signed_dt              Nullable(Date)      COMMENT 'Ngày ký quyết định công bố',
    src_stm_code                String              COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(examination_start_dt))
ORDER BY (assumeNotNull(examination_start_dt), practitioner_code, examination_assessment_result_code)
COMMENT 'Flat table — Practitioner Exam History (1 lần thi per NHN)'
;


-- ============================================================
-- 10. OPERATIONAL: opr_practitioner_training_hist_flat
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.nhnck_opr_practitioner_training_hist_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner Training History
    practitioner_code       String                  COMMENT 'PK (1/2) — Mã NHN',
    enrollment_code String                  COMMENT 'PK (2/2) — Mã đăng ký khóa học',
    training_class_code   String                  COMMENT 'Mã khóa học',
    training_class_nm     Nullable(String)        COMMENT 'Tên khóa học',
    academic_year     Nullable(Int64)         COMMENT 'Năm học',
    exam_start_dt           Nullable(Date)          COMMENT 'Ngày bắt đầu thi',
    exam_end_dt             Nullable(String)        COMMENT 'Ngày kết thúc thi (Text — nguồn VARCHAR2(200))',
    exam_score              Nullable(Decimal(5,2))  COMMENT 'Điểm thi — nullable nếu chưa thi',
    training_result_code    Nullable(String)        COMMENT 'Kết quả thi — scheme: TRAINING_RESULT',
    training_result_nm      Nullable(String)        COMMENT 'Tên kết quả thi',
    src_stm_code            String                  COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(exam_start_dt))
ORDER BY (assumeNotNull(exam_start_dt), practitioner_code, enrollment_code)
COMMENT 'Flat table — Practitioner Training History (1 enrollment per NHN)'
;


-- ============================================================
-- 11. OPERATIONAL: opr_practitioner_data_explorer_flat
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.nhnck_opr_practitioner_data_explorer_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner Data Explorer
    practitioner_code               String              COMMENT 'PK (1/2) — Mã NHN',
    license_certificate_document_code    String              COMMENT 'PK (2/2) — Mã CCHN',
    full_nm                 Nullable(String)    COMMENT 'Họ tên NHN',
    certificate_nbr                 Nullable(String)    COMMENT 'Số CCHN',
    certificate_tp_code             Nullable(String)    COMMENT 'Loại hình hành nghề — scheme: CERTIFICATE_TYPE',
    certificate_tp_nm               Nullable(String)    COMMENT 'Tên loại hình hành nghề',
    practice_status_code        Nullable(String)    COMMENT 'Trạng thái hành nghề — scheme: PRACTICE_STATUS',
    issue_dt                 Nullable(Date)      COMMENT 'Ngày cấp CCHN',
    current_organization_nm          Nullable(String)    COMMENT 'Tên tổ chức công tác hiện tại',
    identification_tp_code          Nullable(String)    COMMENT 'Loại giấy tờ định danh — scheme: IP_ALT_ID_TYPE',
    src_stm_code            String              COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(issue_dt))
ORDER BY (assumeNotNull(issue_dt), practitioner_code, license_certificate_document_code)
COMMENT 'Flat table — Practitioner Data Explorer (1 CCHN per NHN — toàn bộ trạng thái)'
;
