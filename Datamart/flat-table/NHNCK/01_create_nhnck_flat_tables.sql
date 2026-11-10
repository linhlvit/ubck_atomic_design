-- ============================================================
-- NHNCK Flat Tables — CREATE
-- Module: Người Hành Nghề Chứng Khoán (NHNCK)
-- Generated: Phase 3 LLD Datamart
-- 12 bảng: 2 fact + 10 operational
-- (Sửa 2026-11-03) NHNCK Nhóm 7/13: opr_practitioner_list_company_role đổi driving về SCMS sc_shareholder (PK/ORDER BY và cột đổi — DROP rồi CREATE lại), tách cột VSDC sang bảng mới nhnck_opr_practitioner_account_holding_flat; bãi bỏ tạm nhnck_opr_practitioner_data_explorer_flat (2026-11-03, O_NHNCK_45) — (Sửa 2026-11-07) khôi phục dạng 1-1 từ bảng mart Gold-to-Gold opr_practitioner_data_explorer (O_NHNCK_47, khối 12 bên dưới), JOIN đã chuyển lên ETL Datamart; thêm identification_tp_code (360 Profile), practitioner_workplace_at_rpt (Employment History). Xem O_NHNCK_43/44/45
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
    license_certificate_document_code    String              COMMENT 'DD — BK bản ghi cấp/thu hồi CCHN (degenerate key)',
    certificate_nbr                 String              COMMENT 'DD — business key CCHN thật; đơn vị đếm COUNT(DISTINCT ...)',
    is_reissue_indicator            String              COMMENT 'Là CCHN cấp lại (Y/N)',
    certificate_issue_dt            Nullable(Date)      COMMENT 'Ngày cấp CCHN',
    revocation_dt                   Nullable(Date)      COMMENT 'Ngày thu hồi CCHN — NULL nếu chưa thu hồi',
    certificate_status_code                      Nullable(String)        COMMENT '[MỚI 2026-10-29, BA sau UAT 27/10] Trạng thái CCHN của bản ghi chứng chỉ (NHNCK CERTIFICATE_RECORDS.STATUS): 0 = chưa sử dụng, 1 = đang sử dụng, 2 = thu hồi được cấp lại, 3 = thu hồi không cấp lại, 4 = đã hủy, 5 = hết hiệu lực/hết hạn — phục vụ Thu hồi cấp lại (2), Thu hồi không cấp lại (3), Hủy bỏ (4), Thu hồi (lũy kế) (2 + 3). Thay cho cách suy từ Practice Status Code của NHN và Decision Type Code. O_NHNCK_38',
    decision_tp_code                Nullable(String)    COMMENT 'Loại quyết định — scheme: LICENSE_CERTIFICATE_DECISION_TYPE',
    decision_signed_dt              Nullable(Date)      COMMENT 'Ngày ký quyết định thu hồi/hủy CCHN',

    -- From: CALENDAR DATE DIMENSION (Snapshot Date)
    snpst_cdr_dt                    Nullable(Date)      COMMENT 'Ngày snapshot — từ Calendar Date Dimension',

    -- From: CALENDAR DATE DIMENSION (Issue Date)
    issue_cdr_dt                    Nullable(Date)      COMMENT 'Ngày cấp — từ Calendar Date Dimension',

    -- From: SECURITIES PRACTITIONER DIMENSION
    practitioner_code               Nullable(String)    COMMENT 'Mã NHN — từ Securities Practitioner Dimension',
    practitioner_full_nm            Nullable(String)    COMMENT 'Họ tên NHN — từ Securities Practitioner Dimension',
    practitioner_education_level_code    Nullable(String)    COMMENT 'Trình độ học vấn — từ Securities Practitioner Dimension',
    practitioner_education_level_nm      Nullable(String)    COMMENT '(Bổ sung 2026-08) Tên trình độ học vấn — từ Securities Practitioner Dimension',
    practitioner_nationality_code   Nullable(String)    COMMENT 'Mã quốc tịch — từ Securities Practitioner Dimension',
    practitioner_birth_dt           Nullable(Date)      COMMENT 'Ngày sinh — từ Securities Practitioner Dimension',
    practitioner_practice_status_code    Nullable(String)    COMMENT 'Trạng thái hành nghề — từ Securities Practitioner Dimension',
    practitioner_practice_status_nm      Nullable(String)    COMMENT '(Bổ sung 2026-08) Tên trạng thái hành nghề — từ Securities Practitioner Dimension',
    practitioner_src_stm_code       Nullable(String)    COMMENT 'Mã hệ thống nguồn — từ Securities Practitioner Dimension',

    -- From: SP LICENSE CERTIFICATE TYPE DIMENSION
    certificate_tp_dim_code         Nullable(String)    COMMENT 'Mã loại CCHN — từ SP License Certificate Type Dimension',
    certificate_tp_dim_nm           Nullable(String)    COMMENT 'Tên loại CCHN — từ SP License Certificate Type Dimension',
    certificate_tp_src_stm_code     Nullable(String)    COMMENT 'Mã hệ thống nguồn — từ SP License Certificate Type Dimension'
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
    first_license_dt                Nullable(Date)      COMMENT 'Ngày cấp CCHN đầu tiên của NHN',
    practicing_indicator                         Nullable(String)        COMMENT 'Y nếu NHN đang hành nghề tại ngày snapshot: có báo cáo tổ chức đã xác nhận (Status Code = 2 hoặc Organization Status Code At Report = 2) và (Practice Status Code = 1 hoặc kỳ làm việc đang hiệu lực: Hire Date <= ngày snapshot, Termination Date rỗng hoặc sau ngày snapshot); N nếu không. Phục vụ Tổng NHNCK đang hành nghề (K_NHNCK_126) và chưa hành nghề (K_NHNCK_127). [MỚI 2026-10-29, BA sau UAT 27/10]',
    concurrent_employment_indicator              Nullable(String)        COMMENT 'Y nếu trong cửa sổ lũy kế từ 01/01 của năm snapshot đến ngày snapshot, NHN có ít nhất 2 kỳ làm việc ở 2 tổ chức sử dụng NHN KHÁC NHAU giao nhau về thời gian (ngày vào của kỳ này không sau ngày kết thúc của kỳ kia và ngược lại; kỳ chưa có ngày kết thúc tính đến ngày snapshot); chỉ báo cáo tổ chức đã xác nhận; làm hai đợt ở cùng một công ty không tính. Phục vụ LV đồng thời tại 2 TCSD NHN (K_NHNCK_120) và slicer Loại vi phạm (K_NHNCK_123). [MỚI 2026-10-29, O_NHNCK_35]',
    insufficient_training_indicator              Nullable(String)        COMMENT 'Y nếu NHN chưa đáp ứng cập nhật kiến thức tối thiểu 8 giờ/năm tại ngày snapshot: tổng Training Hours của kết quả tập huấn Hoàn thành (Training Result Status Code = 1) có Training End Date từ 01/01 của năm snapshot đến ngày snapshot < 8; miễn nếu NHN chỉ có đúng một CCHN và được cấp trong chính năm snapshot; chỉ xét NHN đã có CCHN còn hiệu lực để theo dõi (Status Code ∈ 0 chưa sử dụng, 1 đang sử dụng, 2 thu hồi được cấp lại, 5 hết hạn) cấp trước 01/01 của năm snapshot. Phục vụ Không đáp ứng yêu cầu tập huấn tối thiểu (K_NHNCK_121) và slicer Loại vi phạm. [MỚI 2026-10-29, O_NHNCK_35]',
    no_practice_3_years_indicator                Nullable(String)        COMMENT 'Y nếu NHN không hành nghề 3 năm liên tục tại ngày snapshot: không có kỳ làm việc đang hiệu lực (báo cáo tổ chức đã xác nhận) VÀ (đã nghỉ hết và ngày kết thúc gần nhất + 36 tháng <= ngày snapshot, HOẶC khoảng trống giữa hai kỳ làm việc liền nhau đủ 36 tháng, HOẶC chưa từng có báo cáo tổ chức đã xác nhận và ngày cấp CCHN sớm nhất + 36 tháng <= ngày snapshot). Không lọc thêm loại tổ chức (nguồn báo cáo đã là CTCK/CTQLQ). Phục vụ Không hành nghề 3 năm liên tục (K_NHNCK_122) và slicer Loại vi phạm. [MỚI 2026-10-29, O_NHNCK_35]',

    -- From: CALENDAR DATE DIMENSION (Snapshot Date)
    snpst_cdr_dt            Nullable(Date)      COMMENT 'Ngày — từ Calendar Date Dimension',

    -- From: SECURITIES PRACTITIONER DIMENSION
    practitioner_code               Nullable(String)    COMMENT 'Mã NHN — từ Securities Practitioner Dimension',
    practitioner_full_nm            Nullable(String)    COMMENT 'Họ tên NHN — từ Securities Practitioner Dimension',
    practitioner_education_level_code        Nullable(String)    COMMENT 'Trình độ học vấn — từ Securities Practitioner Dimension',
    practitioner_education_level_nm          Nullable(String)    COMMENT '(Bổ sung 2026-08) Tên trình độ học vấn — từ Securities Practitioner Dimension',
    practitioner_nationality_code           Nullable(String)    COMMENT 'Mã quốc tịch — từ Securities Practitioner Dimension',
    practitioner_birth_dt            Nullable(Date)      COMMENT 'Ngày sinh — từ Securities Practitioner Dimension',
    practitioner_practice_status_code   Nullable(String)    COMMENT 'Trạng thái hành nghề — từ Securities Practitioner Dimension',
    practitioner_practice_status_nm     Nullable(String)    COMMENT '(Bổ sung 2026-08) Tên trạng thái hành nghề — từ Securities Practitioner Dimension',
    practitioner_src_stm_code           Nullable(String)    COMMENT 'Mã hệ thống nguồn — từ Securities Practitioner Dimension'
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
    identification_tp_code                       Nullable(String)        COMMENT 'Loại giấy tờ định danh (scheme: IP_ALT_ID_TYPE: NATIONAL_ID=CMND, CITIZEN_ID=CCCD, PASSPORT=Hộ chiếu) — ETL-derived: LEFT JOIN ip_alternative_identification theo sp_id; NULL nếu chưa có giấy tờ (Sửa 2026-11-03) chuyển từ Operational Practitioner Data Explorer (đã bãi bỏ) — phục vụ K_NHNCK_101 Nhóm 13',
    education_level_code        Nullable(String)    COMMENT '(Bổ sung 2026-08-07) Trình độ học vấn — scheme: EDUCATIONAL_LEVEL',
    education_level_nm          Nullable(String)    COMMENT '(Bổ sung 2026-08-07) Tên trình độ học vấn',
    workplace_nm        Nullable(String)    COMMENT 'Nơi công tác hiện tại',
    practice_status_code    Nullable(String)    COMMENT '(Sửa 2026-10-30) Trạng thái hành nghề dẫn xuất tại ngày chạy ETL: 0=Chưa hành nghề, 1=Đang hoạt động, 2=Thu hồi có cấp lại, 3=Thu hồi không cấp lại, 4=Đã nghỉ, 9=Khác',
    practice_status_nm      Nullable(String)    COMMENT '(Sửa 2026-10-30) Tên trạng thái hành nghề — nhãn cố định ứng với practice_status_code',
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
    related_individual_identity_nbr      Nullable(String)    COMMENT '(Sửa 2026-08) Số CMND/CCCD người liên quan — direct từ PROFESSIONAL_RELATIONSHIPS.IDENTITY_ID',
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
-- (Sửa 2026-11-03) Driving sc_shareholder; cột VSDC tách sang nhnck_opr_practitioner_account_holding_flat — O_NHNCK_43
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.nhnck_opr_practitioner_list_company_role_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner Listed Company Role
    practitioner_code                       String              COMMENT 'PK (1/2) — Mã NHN',
    sc_shareholder_code                          String                  COMMENT 'PK (2/2) — BK bản ghi cổ đông SCMS (sc_shareholder_code); 1 NHN có thể có nhiều bản ghi cổ đông, kể cả cùng 1 DN',
    securities_company_code                      Nullable(String)        COMMENT 'Mã DN niêm yết mà NHN là cổ đông cá nhân (SC_FIRM_INFO.CODE) — cột Mã CTCK (K_NHNCK_84) theo SQL BA dòng 61/71; mô tả BA dòng 72 là CTCK mà NHN mở tài khoản nhưng SQL lấy SC_FIRM_INFO.CODE qua cổ đông — O_NHNCK_43',
    securities_company_short_nm                  Nullable(String)        COMMENT 'Tên viết tắt DN niêm yết (SC_FIRM_INFO.SHORT_NAME) — cột Tên DN niêm yết (K_NHNCK_81)',
    representative_position                      Nullable(String)        COMMENT 'Vai trò/chức vụ đại diện của NHN tại DN niêm yết (SC_FIRM_SHAREHOLDER.REPRESENTATIVE_POSITION) — cột Vai trò (K_NHNCK_82)',
    practice_status_code                    Nullable(String)    COMMENT 'Trạng thái hành nghề hiển thị dẫn xuất (K_NHNCK_83): 0=Chưa hành nghề, 1=Đang hoạt động, 2=Thu hồi có cấp lại, 3=Thu hồi không cấp lại, 4=Đã nghỉ, 9=Khác',
    practice_status_nm                      Nullable(String)    COMMENT 'Tên trạng thái hành nghề hiển thị tương ứng practice_status_code',
    shares_held                                  Nullable(Int64)         COMMENT 'Số lượng cổ phiếu NHN sở hữu tại DN niêm yết (K_NHNCK_85) — SC_FIRM_SHAREHOLDER.SHARES_HELD',
    src_stm_code                                 String                  COMMENT 'Mã hệ thống nguồn của driving — SCMS_SC_FIRM_SHAREHOLDER'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (practitioner_code, sc_shareholder_code)
COMMENT 'Flat table — Practitioner Listed Company Role (1 NHN × 1 bản ghi cổ đông cá nhân của DN niêm yết)'
;


-- ============================================================
-- 6. OPERATIONAL: opr_practitioner_certificate_hist_flat
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.nhnck_opr_practitioner_certificate_hist_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner Certificate History
    practitioner_code               String              COMMENT 'PK (1/2) — Mã NHN',
    license_certificate_document_code    String              COMMENT 'PK (2/2) — Mã CCHN',
    certificate_nbr                 Nullable(String)    COMMENT 'Số CCHN (CERTIFICATE_NUMBER)',
    certificate_tp_code             Nullable(String)    COMMENT 'Loại CCHN — SP License Certificate Type (Fundamental entity, không phải Classification)',
    certificate_tp_nm               Nullable(String)    COMMENT 'Tên loại CCHN',
    issue_dt                 Nullable(Date)      COMMENT 'Ngày cấp CCHN',
    revocation_dt           Nullable(Date)      COMMENT 'Ngày thu hồi — chỉ có khi trạng thái CCHN là 2 hoặc 3 (ngày ghi trên bản ghi CCHN, thiếu thì ngày ký quyết định thu hồi); NULL với trạng thái khác',
    issue_decision_nbr           Nullable(String)    COMMENT 'Số quyết định cấp (DECISIONS.DECISION_NUMBER)',
    revocation_decision_nbr     Nullable(String)    COMMENT 'Số quyết định thu hồi (DECISIONS.DECISION_NUMBER)',
    certificate_status_code             Nullable(String)    COMMENT 'Trạng thái CCHN hiện tại của bản ghi (CERTIFICATE_RECORDS.STATUS: 0–5) — scheme: CERTIFICATE_STATUS',
    certificate_status_nm               Nullable(String)    COMMENT 'Tên trạng thái CCHN',
    src_stm_code            String              COMMENT 'Mã hệ thống nguồn',
    cancellation_dt                              Nullable(Date)          COMMENT 'Ngày hủy CCHN — chỉ có khi trạng thái CCHN là 4 (đã hủy): lấy ngày ghi trên bản ghi CCHN (CERTIFICATE_RECORDS không có cột ngày hủy riêng, dùng chung ngày thu hồi), thiếu thì lấy ngày ký quyết định hủy; NULL với trạng thái khác. [MỚI 2026-11-10, O_NHNCK_48]',
    cancellation_decision_nbr                    Nullable(String)        COMMENT 'Số quyết định hủy CCHN — NULL nếu CCHN chưa có quyết định hủy. ETL-derived: join sp_license_decision_document theo cancellation_sp_license_decision_document_id, lấy số hiệu quyết định (DECISIONS.DECISION_NUMBER). [MỚI 2026-11-10, O_NHNCK_48]'
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
    practitioner_workplace_at_rpt                Nullable(String)        COMMENT 'Nơi làm việc của NHN dạng text tự do tại thời điểm báo cáo tổ chức (ORGANIZATION_REPORTS.Workplace) — phục vụ Nhóm 6 Đơn vị công tác (K_NHNCK_132, BA Nhóm 6 dòng 52); khác Securities Organization Name (tên tổ chức theo mã tổ chức)',
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
    violation_tp_code        Nullable(String)    COMMENT '(Sửa 2026-08) Hình thức xử phạt — scheme: VIOLATION_TYPE (đổi tên từ record_tp_code)',
    violation_tp_nm          Nullable(String)    COMMENT 'Tên hình thức xử phạt',
    note                Nullable(String)    COMMENT 'Nội dung vi phạm',
    violation_status_code        String              COMMENT '(Sửa 2026-08) Trạng thái vi phạm — scheme: VIOLATION_STATUS (1=ACTIVE, 0=INACTIVE, -1=DELETED; đổi tên từ record_status_code)',
    violation_status_nm          Nullable(String)    COMMENT 'Tên trạng thái vi phạm',
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
    examination_start_dt                Nullable(Date)      COMMENT '(Sửa 2026-08-07) Ngày bắt đầu thi',
    examination_end_dt                  Nullable(Date)      COMMENT '(Thêm 2026-08-07) Ngày kết thúc thi',
    law_score                    Nullable(String)    COMMENT 'Điểm thi pháp luật',
    specialization_score         Nullable(String)    COMMENT '(Thêm 2026-08-07) Điểm thi chuyên môn',
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
--    (Sửa 2026-08) Driving đổi sang sp_post_certification_training_result
--    (NHNCK.POST_CERT_TRAINING_RESULTS) — grain: 1 lần bồi dưỡng per NHN,
--    không còn 1 enrollment per NHN (SPECIALIZATION_COURSE_DETAILS).
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.nhnck_opr_practitioner_training_hist_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner Training History
    practitioner_code       String                  COMMENT 'PK (1/2) — Mã NHN',
    training_result_code    String                  COMMENT 'PK (2/2) — Mã bản ghi bồi dưỡng (đổi từ enrollment_code)',
    training_class_code   Nullable(String)        COMMENT 'Mã khóa học — nguồn POST_CERT_TRAINING_COURSES (đổi từ SPECIALIZATION_COURSES)',
    training_class_nm     Nullable(String)        COMMENT 'Tên khóa học — nguồn POST_CERT_TRAINING_COURSES',
    training_start_dt       Nullable(Date)          COMMENT 'Ngày bắt đầu bồi dưỡng (đổi từ Exam Start Date)',
    training_end_dt         Nullable(Date)          COMMENT 'Ngày kết thúc bồi dưỡng (đổi từ Exam End Date)',
    training_hours           Nullable(Int64)         COMMENT 'Số giờ đào tạo — K_NHNCK_67',
    hours_sufficiency_indicator Nullable(String)     COMMENT 'Đã đủ 8h (Y/N) — ETL-derived: Training Hours >= 8 — K_NHNCK_67',
    exam_result_code    Nullable(String)        COMMENT '(Sửa 2026-09-09) Kết quả kiểm tra chuyên môn — lấy trực tiếp trên driving row (training_result_status_code), scheme NHNCK_POST_CERT_TRAINING_RESULT_STATUS, không còn JOIN phụ qua sp_code',
    exam_result_nm      Nullable(String)        COMMENT '(Sửa 2026-09-09) Lấy trực tiếp training_cl_result_code trên driving row, scheme NHNCK_POST_CERT_TRAINING_CLASSIFICATION — không còn denormalize qua cl_value; tên cột không còn phản ánh đúng bản chất dữ liệu',
    src_stm_code            String                  COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(training_start_dt))
ORDER BY (assumeNotNull(training_start_dt), practitioner_code, training_result_code)
COMMENT 'Flat table — Practitioner Training History (1 lần bồi dưỡng per NHN, driving sp_post_certification_training_result)'
;


-- ==========================================================
-- 11. OPERATIONAL: nhnck_opr_practitioner_account_holding_flat
--    opr_practitioner_account_holding — sinh tự động từ master registry + Entities.csv
--    Joins: không JOIN dimension
-- ==========================================================
CREATE TABLE IF NOT EXISTS datamart.nhnck_opr_practitioner_account_holding_flat ON CLUSTER 'my_cluster'
(
    -- From: OPR_PRACTITIONER_ACCOUNT_HOLDING
    practitioner_account_holding_id              String                  COMMENT 'PK — Driving: open_investor_account (VSDC.OPEN_INVESTORS, tài khoản cá nhân investor_tp_code IN (3, 4)). Grain',
    practitioner_code                            String                  COMMENT 'BK người hành nghề — join anchor tới các bảng Operational khác của NHN; nối tài khoản VSDC với NHN qua số giấy',
    account_nbr                                  Nullable(String)        COMMENT 'Số tài khoản giao dịch chứng khoán cá nhân của NHN — VSDC (open_investor_account.investor_account_nbr) — K_NHN',
    account_holder_nm                            Nullable(String)        COMMENT 'Tên chủ tài khoản giao dịch chứng khoán của NHN (open_investor_account.investor_nm) — K_NHNCK_88',
    main_held_securities_code                    Nullable(String)        COMMENT 'Mã chứng khoán NHN nắm giữ với tư cách cổ đông lớn VSDC (major_shareholder_ownership.ticker_symbol) — K_NHNCK_',
    vsdc_held_securities_vol                     Nullable(Int64)         COMMENT 'Số lượng chứng khoán NHN sở hữu cuối kỳ theo VSDC (major_shareholder_ownership.closing_share_quantity) — K_NHN',
    src_stm_code                                 String                  COMMENT 'Mã hệ thống nguồn của driving — VSDC_OPEN_INVESTORS'
)
ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (practitioner_account_holding_id)
COMMENT 'Flat table — opr_practitioner_account_holding — sinh tự động từ master registry + Entities.csv'
;


-- ==========================================================
-- 12. OPERATIONAL: nhnck_opr_practitioner_data_explorer_flat
--    opr_practitioner_data_explorer — Gold-to-Gold (Nhóm 13): JOIN 360 Profile x Certificate/Employment/Exam/Violation History x Fact Daily Snapshot
--    đã thực hiện ở ETL Datamart; flat chỉ 1-1 từ bảng mart. Joins: không JOIN dimension ở flat
-- ==========================================================
CREATE TABLE IF NOT EXISTS datamart.nhnck_opr_practitioner_data_explorer_flat ON CLUSTER 'my_cluster'
(
    -- From: OPR_PRACTITIONER_DATA_EXPLORER
    practitioner_data_explorer_id                String                  COMMENT 'PK — Driving: opr_practitioner_360_profile (1 dòng/NHN, kể cả NHN chưa có CCHN nào). Grain: 1 NHN × 1 CCHN × 1',
    practitioner_code                            String                  COMMENT 'BK người hành nghề — join anchor tới các bảng Operational/Fact khác của NHN. Driving: opr_practitioner_360_pro',
    license_certificate_document_code            Nullable(String)        COMMENT 'Mã CCHN của dòng (BK bản ghi CCHN, thành phần grain) — NULL khi NHN chưa có CCHN nào',
    examination_assessment_result_code           Nullable(String)        COMMENT 'Mã kết quả thi sát hạch của dòng (thành phần grain) — NULL khi NHN chưa dự thi lần nào',
    conduct_violation_code                       Nullable(String)        COMMENT 'Mã vi phạm của dòng (thành phần grain) — NULL khi NHN không có vi phạm',
    full_nm                                      Nullable(String)        COMMENT 'Họ tên NHN',
    birth_dt                                     Nullable(Date)          COMMENT 'Ngày sinh NHN',
    age                                          Nullable(Int64)         COMMENT 'Tuổi NHN — lấy từ 360 Profile, không tính lại',
    nationality_nm                               Nullable(String)        COMMENT 'Tên quốc tịch NHN',
    identification_nbr                           Nullable(String)        COMMENT 'Số định danh/Hộ chiếu của NHN',
    identification_tp_code                       Nullable(String)        COMMENT 'Loại giấy tờ định danh (scheme IP_ALT_ID_TYPE: NATIONAL_ID=CMND, CITIZEN_ID=CCCD, PASSPORT=Hộ chiếu)',
    education_level_nm                           Nullable(String)        COMMENT 'Tên trình độ học vấn của NHN',
    practice_status_code                         Nullable(String)        COMMENT 'Trạng thái hành nghề dẫn xuất (0=Chưa hành nghề, 1=Đang hoạt động, 2=Thu hồi có cấp lại, 3=Thu hồi không cấp l',
    practice_status_nm                           Nullable(String)        COMMENT 'Tên trạng thái hành nghề — nhãn cố định ứng với practice_status_code',
    certificate_nbr                              Nullable(String)        COMMENT 'Số CCHN của dòng — NULL khi NHN chưa có CCHN',
    certificate_tp_code                          Nullable(String)        COMMENT 'Mã loại hình hành nghề của CCHN — NULL khi NHN chưa có CCHN',
    certificate_tp_nm                            Nullable(String)        COMMENT 'Tên loại hình hành nghề của CCHN',
    issue_dt                                     Nullable(Date)          COMMENT 'Ngày cấp CCHN — slicer từ ngày … đến ngày … lọc trên cột này',
    current_organization_nm                      Nullable(String)        COMMENT 'Tên tổ chức nơi công tác hiện tại — báo cáo tổ chức đang mở (termination_dt IS NULL) có hire_dt mới nhất của N',
    concurrent_employment_indicator              Nullable(String)        COMMENT 'Y nếu NHN làm việc đồng thời tại 2 tổ chức trở lên tại snapshot ETL — đọc Fact Practitioner Daily Snapshot (cù',
    insufficient_training_indicator              Nullable(String)        COMMENT 'Y nếu NHN chưa đáp ứng yêu cầu tập huấn tối thiểu hàng năm tại snapshot ETL — đọc Fact Practitioner Daily Snap',
    no_practice_3_years_indicator                Nullable(String)        COMMENT 'Y nếu NHN không hành nghề 3 năm liên tục tại snapshot ETL — đọc Fact Practitioner Daily Snapshot',
    exam_assessment_nm                           Nullable(String)        COMMENT 'Tên đợt thi sát hạch (1-N per NHN) — NULL khi NHN chưa dự thi',
    exam_examination_period                      Nullable(String)        COMMENT 'Kỳ thi (năm/đợt) của lần thi',
    exam_examination_start_dt                    Nullable(Date)          COMMENT 'Ngày bắt đầu kỳ thi sát hạch',
    exam_examination_end_dt                      Nullable(Date)          COMMENT 'Ngày kết thúc kỳ thi sát hạch',
    exam_overall_result_nm                       Nullable(String)        COMMENT 'Kết quả thi chung của lần thi',
    violation_decision_nbr                       Nullable(String)        COMMENT 'Số quyết định xử lý vi phạm (1-N per NHN) — NULL khi NHN không có vi phạm',
    violation_decision_signed_dt                 Nullable(Date)          COMMENT 'Ngày ký quyết định xử lý vi phạm',
    violation_note                               Nullable(String)        COMMENT 'Nội dung vi phạm',
    src_stm_code                                 String                  COMMENT 'Mã hệ thống nguồn của driving — NHNCK_PROFESSIONALS'
)
ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (practitioner_data_explorer_id)
COMMENT 'Flat table — opr_practitioner_data_explorer — Nhóm 13 Data Explorer, grain NHN x CCHN x lan thi x vi pham (JOIN o ETL Datamart)'
;
