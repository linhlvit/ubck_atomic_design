-- ============================================================
-- NHNCK Flat Tables — CREATE
-- Module: Người Hành Nghề Chứng Khoán (NHNCK)
-- Generated: Phase 3 LLD Datamart
-- 11 bảng: 2 fact + 9 operational
-- ============================================================


-- ============================================================
-- 1. FACT: nhnck_fct_prac_license_ctf_snpst_flat
--    Periodic Snapshot CCHN × tháng
--    Joins: Calendar Date (snpst_dt JOIN + issu_dt LEFT JOIN) × scr_prac_dim × cls_dim ×2
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.nhnck_fct_prac_license_ctf_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Practitioner License Certificate Snapshot
    prac_dim_id             String              COMMENT 'FK → Securities Practitioner Dimension',
    issu_dt_dim_id          String              COMMENT 'FK → Calendar Date Dimension (ngày cấp)',
    snpst_dt_dim_id         String              COMMENT 'FK → Calendar Date Dimension (ngày snapshot)',
    ctf_tp_cl_dim_id        String              COMMENT 'FK → Classification Dimension (loại CCHN)',
    ctf_st_cl_dim_id        String              COMMENT 'FK → Classification Dimension (trạng thái CCHN)',
    license_ctf_doc_code    String              COMMENT 'DD — BK CCHN',
    ctf_tp_code             String              COMMENT 'Loại CCHN — scheme: CERTIFICATE_TYPE',
    ctf_st_code             String              COMMENT 'Trạng thái CCHN — scheme: CERTIFICATE_STATUS',
    alw_reissue_ind         String              COMMENT 'Cho phép cấp lại (Y/N)',
    is_reissue_ind          String              COMMENT 'Là CCHN cấp lại (Y/N)',
    ctf_issu_dt             Nullable(Date)      COMMENT 'Ngày cấp CCHN',
    revocation_dt           Nullable(Date)      COMMENT 'Ngày thu hồi CCHN — NULL nếu chưa thu hồi',
    dcsn_tp_code            Nullable(String)    COMMENT 'Loại quyết định — scheme: DECISION_TYPE (2=Thu hồi, 6=Hủy); NULL nếu chưa có quyết định',

    -- From: CALENDAR DATE DIMENSION (Snapshot Date)
    snpst_full_date         Nullable(Date)      COMMENT 'Ngày đầy đủ — từ Calendar Date Dimension (snapshot)',
    snpst_day_of_week       Nullable(String)    COMMENT 'Thứ trong tuần (snapshot)',
    snpst_day_of_week_num   Nullable(Int32)     COMMENT 'Số thứ tự ngày trong tuần 1=Mon (snapshot)',
    snpst_week_of_year      Nullable(Int32)     COMMENT 'Tuần trong năm (snapshot)',
    snpst_month_num         Nullable(Int32)     COMMENT 'Tháng (snapshot)',
    snpst_month_name        Nullable(String)    COMMENT 'Tên tháng (snapshot)',
    snpst_quarter_num       Nullable(Int32)     COMMENT 'Quý (snapshot)',
    snpst_year_num          Nullable(Int32)     COMMENT 'Năm (snapshot)',
    snpst_is_trading_day    Nullable(UInt8)     COMMENT 'Cờ ngày giao dịch (snapshot)',

    -- From: CALENDAR DATE DIMENSION (Issue Date)
    issu_full_date          Nullable(Date)      COMMENT 'Ngày đầy đủ — từ Calendar Date Dimension (cấp)',
    issu_day_of_week        Nullable(String)    COMMENT 'Thứ trong tuần (cấp)',
    issu_day_of_week_num    Nullable(Int32)     COMMENT 'Số thứ tự ngày trong tuần 1=Mon (cấp)',
    issu_week_of_year       Nullable(Int32)     COMMENT 'Tuần trong năm (cấp)',
    issu_month_num          Nullable(Int32)     COMMENT 'Tháng (cấp)',
    issu_month_name         Nullable(String)    COMMENT 'Tên tháng (cấp)',
    issu_quarter_num        Nullable(Int32)     COMMENT 'Quý (cấp)',
    issu_year_num           Nullable(Int32)     COMMENT 'Năm (cấp)',
    issu_is_trading_day     Nullable(UInt8)     COMMENT 'Cờ ngày giao dịch (cấp)',

    -- From: SECURITIES PRACTITIONER DIMENSION
    prac_code               Nullable(String)    COMMENT 'Mã NHN — từ Securities Practitioner Dimension',
    prac_full_nm            Nullable(String)    COMMENT 'Họ tên NHN — từ Securities Practitioner Dimension',
    prac_ed_lvl_code        Nullable(String)    COMMENT 'Trình độ học vấn — từ Securities Practitioner Dimension',
    prac_nat_code           Nullable(String)    COMMENT 'Mã quốc tịch — từ Securities Practitioner Dimension',
    prac_brth_dt            Nullable(Date)      COMMENT 'Ngày sinh — từ Securities Practitioner Dimension',
    prac_practice_st_code   Nullable(String)    COMMENT 'Trạng thái hành nghề — từ Securities Practitioner Dimension',

    -- From: CLASSIFICATION DIMENSION (Certificate Type)
    ctf_tp_scm_code         Nullable(String)    COMMENT 'Mã scheme loại CCHN — từ Classification Dimension',
    ctf_tp_scm_nm           Nullable(String)    COMMENT 'Tên scheme loại CCHN — từ Classification Dimension',
    ctf_tp_cl_code          Nullable(String)    COMMENT 'Mã loại CCHN — từ Classification Dimension',
    ctf_tp_cl_nm            Nullable(String)    COMMENT 'Tên loại CCHN — từ Classification Dimension',

    -- From: CLASSIFICATION DIMENSION (Certificate Status)
    ctf_st_scm_code         Nullable(String)    COMMENT 'Mã scheme trạng thái CCHN — từ Classification Dimension',
    ctf_st_scm_nm           Nullable(String)    COMMENT 'Tên scheme trạng thái CCHN — từ Classification Dimension',
    ctf_st_cl_code          Nullable(String)    COMMENT 'Mã trạng thái CCHN — từ Classification Dimension',
    ctf_st_cl_nm            Nullable(String)    COMMENT 'Tên trạng thái CCHN — từ Classification Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(ctf_issu_dt)
ORDER BY (ctf_issu_dt, license_ctf_doc_code)
COMMENT 'Flat table — Fact Practitioner License Certificate Snapshot × Calendar Date × Securities Practitioner Dimension × Classification Dimension'
;


-- ============================================================
-- 2. FACT: nhnck_fct_prac_dly_snpst_flat
--    Periodic Snapshot NHN × ngày
--    Joins: Calendar Date (snpst_dt JOIN) × scr_prac_dim
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.nhnck_fct_prac_dly_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Practitioner Daily Snapshot
    prac_dim_id             String              COMMENT 'FK → Securities Practitioner Dimension',
    snpst_dt_dim_id         String              COMMENT 'FK → Calendar Date Dimension (ngày snapshot)',
    age                     Nullable(Int64)     COMMENT 'Tuổi NHN tại ngày snapshot',
    has_actv_ctf            String              COMMENT 'TRUE nếu có CCHN đang hoạt động',
    has_actv_vln            String              COMMENT 'TRUE nếu có vi phạm đang hoạt động',

    -- From: CALENDAR DATE DIMENSION (Snapshot Date)
    snpst_full_date         Nullable(Date)      COMMENT 'Ngày đầy đủ — từ Calendar Date Dimension',
    snpst_day_of_week       Nullable(String)    COMMENT 'Thứ trong tuần',
    snpst_day_of_week_num   Nullable(Int32)     COMMENT 'Số thứ tự ngày trong tuần 1=Mon',
    snpst_week_of_year      Nullable(Int32)     COMMENT 'Tuần trong năm',
    snpst_month_num         Nullable(Int32)     COMMENT 'Tháng',
    snpst_month_name        Nullable(String)    COMMENT 'Tên tháng',
    snpst_quarter_num       Nullable(Int32)     COMMENT 'Quý',
    snpst_year_num          Nullable(Int32)     COMMENT 'Năm',
    snpst_is_trading_day    Nullable(UInt8)     COMMENT 'Cờ ngày giao dịch',

    -- From: SECURITIES PRACTITIONER DIMENSION
    prac_code               Nullable(String)    COMMENT 'Mã NHN — từ Securities Practitioner Dimension',
    prac_full_nm            Nullable(String)    COMMENT 'Họ tên NHN — từ Securities Practitioner Dimension',
    prac_ed_lvl_code        Nullable(String)    COMMENT 'Trình độ học vấn — từ Securities Practitioner Dimension',
    prac_nat_code           Nullable(String)    COMMENT 'Mã quốc tịch — từ Securities Practitioner Dimension',
    prac_brth_dt            Nullable(Date)      COMMENT 'Ngày sinh — từ Securities Practitioner Dimension',
    prac_practice_st_code   Nullable(String)    COMMENT 'Trạng thái hành nghề — từ Securities Practitioner Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(snpst_full_date)
ORDER BY (snpst_full_date, prac_dim_id)
COMMENT 'Flat table — Fact Practitioner Daily Snapshot × Calendar Date × Securities Practitioner Dimension'
;


-- ============================================================
-- 3. OPERATIONAL: opr_prac_360_profile_flat
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.opr_prac_360_profile_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner 360 Profile
    prac_code           String              COMMENT 'PK — Mã NHN',
    full_nm             Nullable(String)    COMMENT 'Họ tên đầy đủ NHN',
    brth_dt             Nullable(Date)      COMMENT 'Ngày sinh NHN',
    age                 Nullable(Int64)     COMMENT 'Tuổi NHN tại thời điểm populate',
    nat_code            Nullable(String)    COMMENT 'Mã quốc tịch',
    nat_nm              Nullable(String)    COMMENT 'Tên quốc tịch',
    identn_nbr          Nullable(String)    COMMENT 'Số CCCD/Hộ chiếu',
    workplace_nm        Nullable(String)    COMMENT 'Nơi công tác hiện tại',
    practice_st_code    Nullable(String)    COMMENT 'Trạng thái hành nghề — scheme: PRACTICE_STATUS',
    practice_st_nm      Nullable(String)    COMMENT 'Tên trạng thái hành nghề',
    actv_ctf_tp_code    Nullable(String)    COMMENT 'Loại CCHN hiện tại — scheme: CERTIFICATE_TYPE',
    actv_ctf_tp_nm      Nullable(String)    COMMENT 'Tên loại CCHN hiện tại',
    actv_ctf_nbr        Nullable(String)    COMMENT 'Số CCHN hiện tại',
    src_stm_code        String              COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(brth_dt)
ORDER BY (prac_code)
COMMENT 'Flat table — Practitioner 360 Profile (latest state per NHN)'
;


-- ============================================================
-- 4. OPERATIONAL: opr_prac_rel_p_profile_flat
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.opr_prac_rel_p_profile_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner Related Party Profile
    prac_code           String              COMMENT 'PK (1/2) — Mã NHN',
    rel_p_code          String              COMMENT 'PK (2/2) — Mã người liên quan',
    rel_idv_full_nm     Nullable(String)    COMMENT 'Họ tên người liên quan',
    rltnp_tp_code       String              COMMENT 'Mã loại quan hệ — scheme: RELATIONSHIP_TYPE',
    rltnp_tp_nm         Nullable(String)    COMMENT 'Tên loại quan hệ',
    rel_idv_ocp         Nullable(String)    COMMENT 'Nghề nghiệp người liên quan',
    rel_idv_workplace   Nullable(String)    COMMENT 'Nơi làm việc người liên quan',
    rel_idv_id_nbr      Nullable(String)    COMMENT 'Số CMND/CCCD người liên quan',
    cty_code            Nullable(String)    COMMENT 'Mã quốc gia người liên quan',
    cty_nm              Nullable(String)    COMMENT 'Tên quốc gia',
    rel_idv_adr         Nullable(String)    COMMENT 'Địa chỉ người liên quan',
    src_stm_code        String              COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (prac_code, rel_p_code)
COMMENT 'Flat table — Practitioner Related Party Profile (1 người liên quan per NHN)'
;


-- ============================================================
-- 5. OPERATIONAL: opr_prac_lst_co_role_flat
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.opr_prac_lst_co_role_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner Listed Company Role
    prac_code               String              COMMENT 'PK (1/2) — Mã NHN',
    org_emp_rpt_code        String              COMMENT 'PK (2/2) — Mã báo cáo tổ chức',
    prac_workplace_at_rpt   Nullable(String)    COMMENT 'Tên nơi công tác tại thời điểm báo cáo',
    prac_pos_at_rpt         Nullable(String)    COMMENT 'Vị trí/chức vụ tại thời điểm báo cáo',
    org_tp_code             Nullable(String)    COMMENT 'Loại tổ chức — scheme: ORG_TYPE',
    scr_org_refr_code       Nullable(String)    COMMENT 'Mã tổ chức tham chiếu',
    employment_st           Nullable(String)    COMMENT 'Trạng thái vai trò (Active/Inactive)',
    hire_dt                 Nullable(Date)      COMMENT 'Ngày bắt đầu làm việc',
    tmt_dt                  Nullable(Date)      COMMENT 'Ngày kết thúc làm việc — NULL nếu hiện tại',
    src_stm_code            String              COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (prac_code, org_emp_rpt_code)
COMMENT 'Flat table — Practitioner Listed Company Role (1 báo cáo tổ chức per NHN)'
;


-- ============================================================
-- 6. OPERATIONAL: opr_prac_ctf_hist_flat
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.opr_prac_ctf_hist_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner Certificate History
    prac_code               String              COMMENT 'PK (1/2) — Mã NHN',
    license_ctf_doc_code    String              COMMENT 'PK (2/2) — Mã CCHN',
    ctf_nbr                 Nullable(String)    COMMENT 'Số CCHN',
    ctf_tp_code             Nullable(String)    COMMENT 'Loại CCHN — scheme: CERTIFICATE_TYPE',
    ctf_tp_nm               Nullable(String)    COMMENT 'Tên loại CCHN',
    issu_dt                 Nullable(Date)      COMMENT 'Ngày cấp CCHN',
    revocation_dt           Nullable(Date)      COMMENT 'Ngày thu hồi — NULL nếu chưa thu hồi',
    issu_dcsn_nbr           Nullable(String)    COMMENT 'Số quyết định cấp',
    revocation_dcsn_nbr     Nullable(String)    COMMENT 'Số quyết định thu hồi',
    pcs_st_code             Nullable(String)    COMMENT 'Trạng thái xử lý hồ sơ — scheme: PROCESS_STATUS',
    pcs_st_nm               Nullable(String)    COMMENT 'Tên trạng thái xử lý hồ sơ',
    src_stm_code            String              COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(issu_dt)
ORDER BY (issu_dt, prac_code, license_ctf_doc_code)
COMMENT 'Flat table — Practitioner Certificate History (1 CCHN per NHN)'
;


-- ============================================================
-- 7. OPERATIONAL: opr_prac_emp_hist_flat
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.opr_prac_emp_hist_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner Employment History
    prac_code           String              COMMENT 'PK (1/2) — Mã NHN',
    org_emp_rpt_code    String              COMMENT 'PK (2/2) — Mã báo cáo tổ chức',
    scr_org_refr_code   Nullable(String)    COMMENT 'Mã tổ chức tham chiếu',
    scr_org_refr_nm     Nullable(String)    COMMENT 'Tên tổ chức',
    org_tp_code         Nullable(String)    COMMENT 'Loại tổ chức — scheme: ORG_TYPE',
    org_tp_nm           Nullable(String)    COMMENT 'Tên loại tổ chức',
    prac_pos_at_rpt     Nullable(String)    COMMENT 'Vị trí/chức vụ tại thời điểm báo cáo',
    prac_dept_at_rpt    Nullable(String)    COMMENT 'Phòng ban tại thời điểm báo cáo',
    hire_dt             Nullable(Date)      COMMENT 'Ngày bắt đầu làm việc',
    tmt_dt              Nullable(Date)      COMMENT 'Ngày kết thúc làm việc — NULL nếu hiện tại',
    src_stm_code        String              COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(hire_dt)
ORDER BY (hire_dt, prac_code, org_emp_rpt_code)
COMMENT 'Flat table — Practitioner Employment History (1 lần công tác per NHN)'
;


-- ============================================================
-- 8. OPERATIONAL: opr_prac_vln_hist_flat
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.opr_prac_vln_hist_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner Violation History
    prac_code           String              COMMENT 'PK (1/2) — Mã NHN',
    conduct_vln_code    String              COMMENT 'PK (2/2) — Mã vi phạm',
    rcrd_tp_code        Nullable(String)    COMMENT 'Hình thức xử phạt — scheme: RECORD_TYPE',
    rcrd_tp_nm          Nullable(String)    COMMENT 'Tên hình thức xử phạt',
    note                Nullable(String)    COMMENT 'Nội dung vi phạm',
    rcrd_st_code        String              COMMENT 'Trạng thái vi phạm — scheme: RECORD_STATUS',
    rcrd_st_nm          Nullable(String)    COMMENT 'Tên trạng thái vi phạm',
    dcsn_nbr            Nullable(String)    COMMENT 'Số quyết định xử phạt',
    dcsn_signed_dt      Nullable(Date)      COMMENT 'Ngày quyết định xử phạt',
    src_stm_code        String              COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(dcsn_signed_dt)
ORDER BY (dcsn_signed_dt, prac_code, conduct_vln_code)
COMMENT 'Flat table — Practitioner Violation History (1 vi phạm per NHN)'
;


-- ============================================================
-- 9. OPERATIONAL: opr_prac_exam_hist_flat
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.opr_prac_exam_hist_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner Exam History
    prac_code                   String              COMMENT 'PK (1/2) — Mã NHN',
    exam_ases_rslt_code         String              COMMENT 'PK (2/2) — Mã kết quả thi',
    ases_nm                     Nullable(String)    COMMENT 'Tên đợt thi',
    rpt_yr                      Nullable(Int64)     COMMENT 'Năm báo cáo đợt thi',
    exam_ssn_nbr                Nullable(Int64)     COMMENT 'Kỳ thi trong năm',
    exam_period                 Nullable(String)    COMMENT 'Kỳ thi dạng chuỗi (VD: 2025_1)',
    exam_strt_dt                Nullable(Date)      COMMENT 'Ngày thi',
    law_scor                    Nullable(String)    COMMENT 'Điểm thi pháp luật',
    specialization_scor         Nullable(String)    COMMENT 'Điểm thi chuyên môn',
    law_rslt_code               Nullable(String)    COMMENT 'Kết quả thi pháp luật — scheme: EXAM_RESULT',
    law_rslt_nm                 Nullable(String)    COMMENT 'Tên kết quả thi pháp luật',
    specialization_rslt_code    Nullable(String)    COMMENT 'Kết quả thi chuyên môn — scheme: EXAM_RESULT',
    specialization_rslt_nm      Nullable(String)    COMMENT 'Tên kết quả thi chuyên môn',
    ovrl_rslt_code              Nullable(String)    COMMENT 'Kết quả tổng hợp — scheme: EXAM_RESULT',
    ovrl_rslt_nm                Nullable(String)    COMMENT 'Tên kết quả tổng hợp',
    dcsn_nbr                    Nullable(String)    COMMENT 'Số quyết định công bố kết quả',
    dcsn_signed_dt              Nullable(Date)      COMMENT 'Ngày ký quyết định công bố',
    src_stm_code                String              COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(exam_strt_dt)
ORDER BY (exam_strt_dt, prac_code, exam_ases_rslt_code)
COMMENT 'Flat table — Practitioner Exam History (1 lần thi per NHN)'
;


-- ============================================================
-- 10. OPERATIONAL: opr_prac_trn_hist_flat
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.opr_prac_trn_hist_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner Training History
    prac_code       String                  COMMENT 'PK (1/2) — Mã NHN',
    enrollment_code String                  COMMENT 'PK (2/2) — Mã đăng ký khóa học',
    trn_clss_code   String                  COMMENT 'Mã khóa học',
    trn_clss_nm     Nullable(String)        COMMENT 'Tên khóa học',
    academic_yr     Nullable(Int64)         COMMENT 'Năm học',
    exam_strt_dt    Nullable(Date)          COMMENT 'Ngày bắt đầu thi',
    exam_end_dt     Nullable(String)        COMMENT 'Ngày kết thúc thi (Text — nguồn VARCHAR2(200))',
    exam_scor       Nullable(Decimal(5,2))  COMMENT 'Điểm thi — nullable nếu chưa thi',
    trn_rslt_code   Nullable(String)        COMMENT 'Kết quả thi — scheme: TRAINING_RESULT',
    trn_rslt_nm     Nullable(String)        COMMENT 'Tên kết quả thi',
    src_stm_code    String                  COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(exam_strt_dt)
ORDER BY (exam_strt_dt, prac_code, enrollment_code)
COMMENT 'Flat table — Practitioner Training History (1 enrollment per NHN)'
;


-- ============================================================
-- 11. OPERATIONAL: opr_prac_data_explr_flat
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.opr_prac_data_explr_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Practitioner Data Explorer
    prac_code               String              COMMENT 'PK (1/2) — Mã NHN',
    license_ctf_doc_code    String              COMMENT 'PK (2/2) — Mã CCHN',
    full_nm                 Nullable(String)    COMMENT 'Họ tên NHN',
    ctf_nbr                 Nullable(String)    COMMENT 'Số CCHN',
    ctf_tp_code             Nullable(String)    COMMENT 'Loại hình hành nghề — scheme: CERTIFICATE_TYPE',
    ctf_tp_nm               Nullable(String)    COMMENT 'Tên loại hình hành nghề',
    practice_st_code        Nullable(String)    COMMENT 'Trạng thái hành nghề — scheme: PRACTICE_STATUS',
    issu_dt                 Nullable(Date)      COMMENT 'Ngày cấp CCHN',
    current_org_nm          Nullable(String)    COMMENT 'Tên tổ chức công tác hiện tại',
    identn_tp_code          Nullable(String)    COMMENT 'Loại giấy tờ định danh — scheme: IP_ALT_ID_TYPE',
    src_stm_code            String              COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(issu_dt)
ORDER BY (issu_dt, prac_code, license_ctf_doc_code)
COMMENT 'Flat table — Practitioner Data Explorer (1 CCHN per NHN — toàn bộ trạng thái)'
;
