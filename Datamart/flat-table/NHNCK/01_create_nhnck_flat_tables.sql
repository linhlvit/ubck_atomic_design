-- ============================================================
-- NHNCK Flat Tables — CREATE
-- Module: Người Hành Nghề Chứng Khoán (NHNCK)
-- Generated: Phase 3 LLD Datamart
-- 11 bảng: 2 fact + 9 operational
-- ============================================================


-- ============================================================
-- 1. FACT: nhnck_fct_practitioner_license_certificate_snpst_flat
--    Periodic Snapshot CCHN × tháng
--    Joins: Calendar Date (snpst_dt JOIN + issue_dt LEFT JOIN) × securities_practitioner_dim × sp_license_certificate_type_dim
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.nhnck_fct_practitioner_license_certificate_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Practitioner License Certificate Snapshot
    practitioner_dim_id             String              COMMENT 'FK → Securities Practitioner Dimension',
    issue_dt_dim_id                 String              COMMENT 'FK → Calendar Date Dimension (ngày cấp)',
    snpst_dt_dim_id                 String              COMMENT 'FK → Calendar Date Dimension (ngày snapshot)',
    certificate_tp_dim_id           String              COMMENT 'FK → SP License Certificate Type Dimension',
    license_certificate_document_code    String              COMMENT 'DD — BK CCHN',
    certificate_tp_code             String              COMMENT 'Mã loại CCHN — dư thừa để filter/display nhanh',
    is_reissue_indicator            String              COMMENT 'Là CCHN cấp lại (Y/N)',
    certificate_issue_dt            Nullable(Date)      COMMENT 'Ngày cấp CCHN',
    revocation_dt                   Nullable(Date)      COMMENT 'Ngày thu hồi CCHN — NULL nếu chưa thu hồi',
    decision_tp_code                Nullable(String)    COMMENT 'Loại quyết định — scheme: LICENSE_CERTIFICATE_DECISION_TYPE',

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

    -- From: SP LICENSE CERTIFICATE TYPE DIMENSION
    certificate_tp_dim_code         Nullable(String)    COMMENT 'Mã loại CCHN — từ SP License Certificate Type Dimension',
    certificate_tp_dim_nm           Nullable(String)    COMMENT 'Tên loại CCHN — từ SP License Certificate Type Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), license_certificate_document_code)
COMMENT 'Flat table — Fact Practitioner License Certificate Snapshot × Calendar Date × Securities Practitioner Dimension × SP License Certificate Type Dimension'
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
    practice_status_code    Nullable(String)    COMMENT 'Trạng thái hành nghề — scheme: PRACTITIONER_PRACTICE_STATUS',
    practice_status_nm      Nullable(String)    COMMENT 'Tên trạng thái hành nghề',
    active_certificate_tp_code    Nullable(String)    COMMENT 'Loại CCHN hiện tại — SP License Certificate Type (Fundamental entity, không phải Classification)',
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
    shares_held              Nullable(Int64)     COMMENT 'Số lượng cổ phiếu sở hữu (K_NHNCK_85) — nguồn thật SCMS, không phải NHNCK; NULL nếu không phải cổ đông/người nội bộ',
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
    certificate_tp_code             Nullable(String)    COMMENT 'Loại CCHN — SP License Certificate Type (Fundamental entity, không phải Classification)',
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
    training_result_code    Nullable(String)        COMMENT 'Kết quả thi — scheme: EXAM_RESULT',
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
--    (Sửa 2026-07-22) Tái cấu trúc theo yêu cầu BA bổ sung — JOIN thêm
--    Practitioner 360 Profile (1-1) + Exam History (1-N) + Violation History (1-N).
--    Grain: 1 CCHN × 1 đợt thi × 1 vi phạm — chấp nhận cartesian khi 1 NHN
--    vừa có nhiều đợt thi vừa có nhiều vi phạm đồng thời (theo xác nhận người thiết kế).
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.nhnck_opr_practitioner_data_explorer_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner Data Explorer
    practitioner_code               String              COMMENT 'PK (1/2) — Mã NHN',
    license_certificate_document_code    String              COMMENT 'PK (2/2) — Mã CCHN',
    full_nm                 Nullable(String)    COMMENT 'Họ tên NHN',
    certificate_nbr                 Nullable(String)    COMMENT 'Số CCHN',
    certificate_tp_code             Nullable(String)    COMMENT 'Loại hình hành nghề — SP License Certificate Type (Fundamental entity, không phải Classification)',
    certificate_tp_nm               Nullable(String)    COMMENT 'Tên loại hình hành nghề',
    practice_status_code        Nullable(String)    COMMENT 'Trạng thái hành nghề — scheme: PRACTITIONER_PRACTICE_STATUS',
    practice_status_nm          Nullable(String)    COMMENT '(Sửa 2026-07-22) Tên trạng thái hành nghề — K_NHNCK_109',
    issue_dt                 Nullable(Date)      COMMENT 'Ngày cấp CCHN',
    current_organization_nm          Nullable(String)    COMMENT 'Tên tổ chức công tác hiện tại',
    identification_tp_code          Nullable(String)    COMMENT 'Loại giấy tờ định danh — scheme: IP_ALT_ID_TYPE',
    src_stm_code            String              COMMENT 'Mã hệ thống nguồn',

    -- From: OPERATIONAL Practitioner 360 Profile (Sửa 2026-07-22 — LEFT JOIN theo practitioner_code, 1-1)
    birth_dt                     Nullable(Date)      COMMENT '(Sửa 2026-07-22) Ngày sinh NHN — K_NHNCK_104, từ Practitioner 360 Profile',
    identification_nbr           Nullable(String)    COMMENT '(Sửa 2026-07-22) Số CCCD/Hộ chiếu — K_NHNCK_105, từ Practitioner 360 Profile',
    education_level_nm           Nullable(String)    COMMENT '(Sửa 2026-07-22) Trình độ học vấn — K_NHNCK_106, từ Practitioner 360 Profile',
    age                          Nullable(Int64)     COMMENT '(Sửa 2026-07-22) Tuổi NHN — K_NHNCK_107, từ Practitioner 360 Profile',
    nationality_nm                Nullable(String)    COMMENT '(Sửa 2026-07-22) Quốc tịch — K_NHNCK_108, từ Practitioner 360 Profile',

    -- From: OPERATIONAL Practitioner Exam History (Sửa 2026-07-22 — LEFT JOIN theo practitioner_code, 1-N — fan-out)
    exam_assessment_nm           Nullable(String)    COMMENT '(Sửa 2026-07-22) Đợt thi — K_NHNCK_110, từ Practitioner Exam History',
    exam_examination_period      Nullable(String)    COMMENT '(Sửa 2026-07-22) Kỳ thi — K_NHNCK_111, từ Practitioner Exam History',
    exam_examination_start_dt    Nullable(Date)      COMMENT '(Sửa 2026-07-22) Ngày bắt đầu thi — K_NHNCK_112, từ Practitioner Exam History',
    exam_examination_end_dt      Nullable(Date)      COMMENT '(Sửa 2026-07-22) Ngày kết thúc thi — K_NHNCK_113, từ Practitioner Exam History',
    exam_overall_result_nm       Nullable(String)    COMMENT '(Sửa 2026-07-22) Kết quả thi — K_NHNCK_114, từ Practitioner Exam History',

    -- From: OPERATIONAL Practitioner Violation History (Sửa 2026-07-22 — LEFT JOIN theo practitioner_code, 1-N — fan-out)
    violation_decision_nbr       Nullable(String)    COMMENT '(Sửa 2026-07-22) Số QĐ vi phạm — K_NHNCK_115, từ Practitioner Violation History',
    violation_decision_signed_dt Nullable(Date)      COMMENT '(Sửa 2026-07-22) Ngày QĐ vi phạm — K_NHNCK_116, từ Practitioner Violation History',
    violation_note                Nullable(String)    COMMENT '(Sửa 2026-07-22) Nội dung vi phạm — K_NHNCK_117, từ Practitioner Violation History'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(issue_dt))
ORDER BY (assumeNotNull(issue_dt), practitioner_code, license_certificate_document_code)
COMMENT 'Flat table — Practitioner Data Explorer × Practitioner 360 Profile × Practitioner Exam History × Practitioner Violation History (Sửa 2026-07-22: grain mở rộng 1 CCHN × 1 đợt thi × 1 vi phạm, chấp nhận cartesian)'
;
