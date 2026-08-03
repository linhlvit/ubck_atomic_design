-- ============================================================
-- QLKD Flat Tables — CREATE
-- Module: Quản lý kinh doanh (Hoạt động CTCK) — QLKD
-- Generated: Phase 3 LLD Datamart
-- 14 bảng: 5 fact + 9 operational
-- ============================================================

-- ============================================================
-- 1. FACT: qlkd_fct_securities_company_status_snpst_flat
--    Fact Securities Company Status Snapshot
--    Grain: 1 CTCK × 1 ngày snapshot D (Periodic Snapshot APPEND, driving
--    table = Securities Company). License Issue Date là Chiều riêng, không
--    phải grain.
--    Joins: Calendar Date (snpst_dt_dim_id, license_issue_dt_dim_id) × Securities Company Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_fct_securities_company_status_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Securities Company Status Snapshot
    snpst_dt_dim_id                 String                  COMMENT 'FK ngày snapshot D — ETL runtime date, full-scan Securities Company Dimension mỗi lần chạy',
    securities_company_dim_id       String                  COMMENT 'FK CTCK — driving table',
    license_issue_dt_dim_id          Nullable(String)        COMMENT 'FK ngày cấp phép hoạt động — Chiều riêng, không phải grain',

    -- From: CALENDAR DATE DIMENSION (Snapshot Date)
    cdr_dt                          Nullable(Date)          COMMENT 'Ngày snapshot D — từ Calendar Date Dimension',

    -- From: CALENDAR DATE DIMENSION (License Issue Date)
    license_issue_cdr_dt             Nullable(Date)          COMMENT 'Ngày cấp phép hoạt động — từ Calendar Date Dimension (Chiều/thuộc tính riêng)',

    -- From: SECURITIES COMPANY DIMENSION
    sc_id                           Nullable(String)        COMMENT 'Business Id CTCK (Atomic surrogate) — từ Securities Company Dimension',
    sc_code                         Nullable(String)        COMMENT 'Mã định danh CTCK — từ Securities Company Dimension',
    sc_nm                           Nullable(String)        COMMENT 'Tên đầy đủ CTCK bằng tiếng Việt — từ Securities Company Dimension',
    company_tp_code                 Nullable(String)        COMMENT 'Loại hình doanh nghiệp CTCK — từ Securities Company Dimension',
    company_status_code             Nullable(String)        COMMENT '7 nhóm trạng thái CTCK — derive CASE/LIKE trên Classification Firm Status Name — LEFT JOIN cl_firm_status — từ Securities Company Dimension',
    is_listed_indicator             Nullable(UInt8)         COMMENT 'Cờ niêm yết trên sàn — từ Securities Company Dimension',
    stock_exchange_nm               Nullable(String)        COMMENT 'Sàn niêm yết (HOSE/HNX/UPCOM) — từ Securities Company Dimension',
    securities_company_src_stm_code Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Securities Company Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), securities_company_dim_id)
COMMENT 'Flat table — Fact Securities Company Status Snapshot × Calendar Date × Securities Company Dimension'
;


-- ============================================================
-- 2. FACT: qlkd_fct_securities_company_service_registration_flat
--    Fact Securities Company Service Registration
--    Joins: Calendar Date × Securities Company Dimension × Service Type Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_fct_securities_company_service_registration_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Securities Company Service Registration
    registration_dt_dim_id          String                  COMMENT 'FK ngày đăng ký dịch vụ',
    securities_company_dim_id       String                  COMMENT 'FK CTCK',
    service_tp_dim_id             String                  COMMENT 'FK dịch vụ',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                          Nullable(Date)          COMMENT 'FK ngày đăng ký dịch vụ — từ Calendar Date Dimension',

    -- From: SECURITIES COMPANY DIMENSION
    sc_id                           Nullable(String)        COMMENT 'Business Id CTCK (Atomic surrogate) — từ Securities Company Dimension',
    sc_code                         Nullable(String)        COMMENT 'Mã định danh CTCK — từ Securities Company Dimension',
    sc_nm                           Nullable(String)        COMMENT 'Tên đầy đủ CTCK bằng tiếng Việt — từ Securities Company Dimension',
    company_tp_code                 Nullable(String)        COMMENT 'Loại hình doanh nghiệp CTCK — từ Securities Company Dimension',
    company_status_code             Nullable(String)        COMMENT '7 nhóm trạng thái CTCK — derive CASE/LIKE trên Classification Firm Status Name — LEFT JOIN cl_firm_status — từ Securities Company Dimension',
    is_listed_indicator             Nullable(UInt8)         COMMENT 'Cờ niêm yết trên sàn — từ Securities Company Dimension',
    stock_exchange_nm               Nullable(String)        COMMENT 'Sàn niêm yết (HOSE/HNX/UPCOM) — từ Securities Company Dimension',
    securities_company_src_stm_code Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Securities Company Dimension',

    -- From: SERVICE TYPE DIMENSION
    cl_service_code                 Nullable(String)        COMMENT 'Mã dịch vụ chứng khoán — từ Service Type Dimension',
    cl_service_nm                   Nullable(String)        COMMENT 'Tên dịch vụ chứng khoán — dùng CASE/LIKE phân loại tại tầng báo cáo — từ Service Type Dimension',
    service_tp_src_stm_code         Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Service Type Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), securities_company_dim_id, service_tp_dim_id)
COMMENT 'Flat table — Fact Securities Company Service Registration × Calendar Date × Securities Company Dimension × Service Type Dimension'
;


-- ============================================================
-- 3. FACT: qlkd_fct_securities_company_license_condition_snpst_flat
--    Fact Securities Company License Condition Snapshot
--    Joins: Calendar Date × Securities Company Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_fct_securities_company_license_condition_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Securities Company License Condition Snapshot
    snpst_dt_dim_id                 String                  COMMENT 'FK ngày snapshot D (Processing Date)',
    securities_company_dim_id       String                  COMMENT 'FK CTCK',
    indicator_code                  String        COMMENT 'Loại giấy phép — phân biệt Nhóm 5/6/7 trên cùng 1 Fact — JOIN sc_alert_indicator',
    severity_level                  Nullable(String)        COMMENT 'Mức duy trì điều kiện cấp phép (1/2/3)',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                          Nullable(Date)          COMMENT 'FK ngày snapshot D (Processing Date) — từ Calendar Date Dimension',

    -- From: SECURITIES COMPANY DIMENSION
    sc_id                           Nullable(String)        COMMENT 'Business Id CTCK (Atomic surrogate) — từ Securities Company Dimension',
    sc_code                         Nullable(String)        COMMENT 'Mã định danh CTCK — từ Securities Company Dimension',
    sc_nm                           Nullable(String)        COMMENT 'Tên đầy đủ CTCK bằng tiếng Việt — từ Securities Company Dimension',
    company_tp_code                 Nullable(String)        COMMENT 'Loại hình doanh nghiệp CTCK — từ Securities Company Dimension',
    company_status_code             Nullable(String)        COMMENT '7 nhóm trạng thái CTCK — derive CASE/LIKE trên Classification Firm Status Name — LEFT JOIN cl_firm_status — từ Securities Company Dimension',
    is_listed_indicator             Nullable(UInt8)         COMMENT 'Cờ niêm yết trên sàn — từ Securities Company Dimension',
    stock_exchange_nm               Nullable(String)        COMMENT 'Sàn niêm yết (HOSE/HNX/UPCOM) — từ Securities Company Dimension',
    securities_company_src_stm_code Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Securities Company Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), securities_company_dim_id, indicator_code)
COMMENT 'Flat table — Fact Securities Company License Condition Snapshot × Calendar Date × Securities Company Dimension'
;


-- ============================================================
-- 4. FACT: qlkd_fct_securities_company_capital_raising_event_flat
--    Fact Securities Company Capital Raising Event
--    Joins: Calendar Date × Offering Form Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_fct_securities_company_capital_raising_event_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Securities Company Capital Raising Event
    event_dt_dim_id                 String                  COMMENT 'FK tháng của đợt chào bán/phát hành (Result Report Date)',
    offering_form_dim_id            String                  COMMENT 'FK hình thức tăng vốn',
    proceeds_collected_amt          Nullable(Decimal(23,2)) COMMENT 'Tổng tiền thực tế thu được (SUM theo tháng x hình thức tăng vốn)',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                          Nullable(Date)          COMMENT 'FK tháng của đợt chào bán/phát hành (Result Report Date) — từ Calendar Date Dimension',

    -- From: OFFERING FORM DIMENSION
    capital_raising_form_code       Nullable(String)        COMMENT 'Mã hình thức tăng vốn — ETL-derived CASE WHEN Item Category Code + Offering Method — từ Offering Form Dimension',
    capital_raising_form_nm         Nullable(String)        COMMENT 'Tên hình thức tăng vốn (5 nhóm) — từ Offering Form Dimension',
    offering_form_src_stm_code      Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Offering Form Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), offering_form_dim_id)
COMMENT 'Flat table — Fact Securities Company Capital Raising Event × Calendar Date × Offering Form Dimension'
;


-- ============================================================
-- 5. FACT: qlkd_fct_market_index_snpst_flat
--    Fact Market Index Snapshot (sở hữu QLKD, reuse NDTNN) — grain vật lý nguồn 1 ngày,
--    flat table QLKD lọc lấy đúng ngày cuối tháng (sửa 2026-07-24, datamart-review)
--    Joins: Calendar Date × Market Index Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_fct_market_index_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Market Index Snapshot
    snpst_dt_dim_id                 String                  COMMENT 'FK ngày (populate lấy đúng ngày cuối tháng)',
    market_index_dim_id             String                  COMMENT 'FK Market Index Dimension',
    market_index_val                Nullable(Decimal(23,2)) COMMENT 'Giá trị chỉ số (bản ghi cuối phiên, ngày cuối tháng)',
    open_index                      Nullable(Decimal(23,2)) COMMENT '[GSTT delta] Index mở cửa tại bản ghi cuối phiên',
    high_index                      Nullable(Decimal(23,2)) COMMENT '[GSTT delta] Index cao nhất tại bản ghi cuối phiên',
    low_index                       Nullable(Decimal(23,2)) COMMENT '[GSTT delta] Index thấp nhất tại bản ghi cuối phiên',
    prior_index                     Nullable(Decimal(23,2)) COMMENT '[GSTT delta] Index cuối cùng của phiên trước đó',
    index_change                    Nullable(Decimal(23,2)) COMMENT '[GSTT delta] Giá trị index thay đổi so với phiên trước',
    index_percent_change            Nullable(Decimal(5,2))  COMMENT '[GSTT delta] % index thay đổi so với phiên trước',
    advances_count                  Nullable(Int64)         COMMENT '[GSTT delta] Số lượng mã tăng',
    declines_count                  Nullable(Int64)         COMMENT '[GSTT delta] Số lượng mã giảm',
    no_change_count                 Nullable(Int64)         COMMENT '[GSTT delta] Số lượng mã không tăng/giảm',
    ceiling_count                   Nullable(Int64)         COMMENT '[GSTT delta] Số lượng mã đang trần',
    floor_count                     Nullable(Int64)         COMMENT '[GSTT delta] Số lượng mã đang sàn',
    odd_lot_total_vol                Nullable(Int64)         COMMENT '[GSTT delta] Khối lượng khớp lô lẻ',
    odd_lot_total_val                Nullable(Decimal(23,2)) COMMENT '[GSTT delta] Giá trị khớp lô lẻ',
    pt_total_vol                    Nullable(Int64)         COMMENT '[GSTT delta] Tổng khối lượng giao dịch thỏa thuận',
    pt_total_val                    Nullable(Decimal(23,2)) COMMENT '[GSTT delta] Tổng giá trị giao dịch thỏa thuận',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                          Nullable(Date)          COMMENT 'Ngày cuối tháng (LAST_DAY) — từ Calendar Date Dimension',

    -- From: MARKET INDEX DIMENSION
    market_id                       Nullable(String)        COMMENT 'Mã thị trường — từ Market Index Dimension',
    market_code                     Nullable(String)        COMMENT 'Mã sàn/chỉ số (HOSE/HNX/UPCOM/30) — từ Market Index Dimension',
    index_tp_code                   Nullable(String)        COMMENT 'Loại chỉ số — từ Market Index Dimension',
    tsc_product_group_id             Nullable(String)        COMMENT 'Mã sản phẩm giao dịch (HOSE/HNX/UPCOM) — từ Market Index Dimension',
    market_status_code              Nullable(String)        COMMENT 'Trạng thái phiên (current-state SCD4A) — từ Market Index Dimension',
    market_index_src_stm_code       Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Market Index Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), market_index_dim_id)
COMMENT 'Flat table — Fact Market Index Snapshot × Calendar Date × Market Index Dimension'
;


-- ============================================================
-- 6. OPERATIONAL: qlkd_opr_securities_company_personnel_profile_flat
--    Operational Securities Company Personnel Profile
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_securities_company_personnel_profile_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Securities Company Personnel Profile
    sc_senior_personnel_code        String                  COMMENT 'PK — mã nhân sự cao cấp (Bảng Tác nghiệp)',
    sc_code                         String                  COMMENT 'Mã CTCK nơi nhân sự công tác',
    full_nm                         Nullable(String)        COMMENT 'Họ và tên đầy đủ nhân sự',
    department                      Nullable(String)        COMMENT 'Phòng/Ban — dùng CASE/LIKE phân nhóm tại tầng báo cáo',
    position_nm                     Nullable(String)        COMMENT 'Chức vụ',
    email                           Nullable(String)        COMMENT 'Email nhân sự — JOIN ip_electronic_address filter EMAIL',
    phone                           Nullable(String)        COMMENT 'Số điện thoại nhân sự — JOIN ip_electronic_address filter PHONE',
    work_start_dt                   Nullable(Date)          COMMENT 'Ngày bắt đầu làm việc tại CTCK',
    dismissal_dt                    Nullable(Date)          COMMENT 'Ngày miễn nhiệm (NULL = đương nhiệm)',
    personnel_status_code           Nullable(String)        COMMENT 'Trạng thái nhân sự',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(work_start_dt))
ORDER BY (assumeNotNull(work_start_dt), sc_senior_personnel_code)
COMMENT 'Flat table — Operational Securities Company Personnel Profile'
;


-- ============================================================
-- 7. OPERATIONAL: qlkd_opr_securities_company_organization_unit_profile_flat
--    Operational Securities Company Organization Unit Profile
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_securities_company_organization_unit_profile_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Securities Company Organization Unit Profile
    sc_ou_code                      String                  COMMENT 'PK — mã đơn vị (Bảng Tác nghiệp)',
    sc_code                         String                  COMMENT 'Mã CTCK',
    ou_tp_code                      String                  COMMENT 'Loại đơn vị (BRANCH/TRANSACTION_OFFICE/REP_OFFICE)',
    ou_nm                           Nullable(String)        COMMENT 'Tên đơn vị',
    adr_val                         Nullable(String)        COMMENT 'Địa chỉ đơn vị — JOIN ip_postal_address',
    decision_dt                     Nullable(Date)          COMMENT 'Ngày thành lập',
    director_nm                     Nullable(String)        COMMENT 'Giám đốc/Trưởng đơn vị — BRANCH dùng Director Name, TRANSACTION_OFFICE/REP_OFFICE dùng Representative Name',
    cl_firm_status_code             Nullable(String)        COMMENT 'Trạng thái pháp lý đơn vị',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn — 3 giá trị khác nhau theo bộ (SC_FIRM_BRANCH/SC_FIRM_TRANSACTION_OFFICE/SC_FIRM_REP_OFFICE)'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(decision_dt))
ORDER BY (assumeNotNull(decision_dt), sc_ou_code)
COMMENT 'Flat table — Operational Securities Company Organization Unit Profile'
;


-- ============================================================
-- 8. OPERATIONAL: qlkd_opr_securities_company_compliance_hist_flat
--    Operational Securities Company Compliance History
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_securities_company_compliance_hist_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Securities Company Compliance History
    compliance_event_code           String                  COMMENT 'PK — mã sự kiện tuân thủ (Bảng Tác nghiệp), thống nhất cho cả 3 nhánh UNION (Admin Penalty/Inspection/Examination)',
    event_tp_code                   String                  COMMENT 'Loại sự kiện tuân thủ (ADMIN_PENALTY_DECISION/INSPECTION/EXAMINATION) — ETL hardcode theo bộ',
    form_tp_code                    Nullable(String)        COMMENT 'Loại thanh tra/kiểm tra (PERIODIC/UNSCHEDULED) — JOIN qua Team Target text match. NULL cho bộ Admin Penalty Decision.',
    insp_decision_dt                Nullable(Date)          COMMENT 'Ngày ban hành quyết định thanh tra/kiểm tra. NULL cho bộ Admin Penalty Decision.',
    decision_nbr                    Nullable(String)        COMMENT 'Số quyết định xử phạt',
    issued_dt                       Nullable(Date)          COMMENT 'Ngày ban hành quyết định xử phạt',
    violation_behavior_nm           Nullable(String)        COMMENT 'Hành vi vi phạm. NULL cho bộ Admin Penalty Decision.',
    supplementary_penalty_nm        Nullable(String)        COMMENT 'Hình thức xử phạt bổ sung (nếu có). NULL cho bộ Admin Penalty Decision.',
    remedial_measure_nm             Nullable(String)        COMMENT 'Biện pháp khắc phục (nếu có). NULL cho bộ Admin Penalty Decision.',
    sc_code                         Nullable(String)        COMMENT 'Mã CTCK. Bộ Admin Penalty Decision: direct. Bộ Inspection/Examination: GAP — text-match qua Team Target.target_reference_id, chưa có FK surrogate chính thức, có thể NULL.',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn — 3 giá trị khác nhau theo bộ'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(issued_dt))
ORDER BY (assumeNotNull(issued_dt), compliance_event_code)
COMMENT 'Flat table — Operational Securities Company Compliance History'
;


-- ============================================================
-- 9. OPERATIONAL: qlkd_opr_individual_profile_flat
--    Operational Individual Profile
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_individual_profile_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Individual Profile
    sc_senior_personnel_code        String                  COMMENT 'PK — mã cá nhân (Bảng Tác nghiệp)',
    sc_code                         Nullable(String)        COMMENT 'Mã CTCK — chỉ áp dụng nguồn SCMS',
    full_nm                         Nullable(String)        COMMENT 'Họ và tên đầy đủ',
    position_nm                     Nullable(String)        COMMENT 'Vai trò/chức vụ',
    identification_nbr              Nullable(String)        COMMENT 'Số CCCD — merge key với nguồn còn lại (ETL, không phải FK Atomic)',
    license_certificate_nbr         Nullable(String)        COMMENT 'Số GCN hành nghề — chỉ áp dụng nguồn NHNCK',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn — 2 giá trị khác nhau theo bộ (SC_FIRM_SENIOR_PERSONNEL/NHNCK.PROFESSIONALS)'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (sc_senior_personnel_code)
COMMENT 'Flat table — Operational Individual Profile'
;


-- ============================================================
-- 10. OPERATIONAL: qlkd_opr_individual_related_party_network_flat
--    Operational Individual Related Party Network
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_individual_related_party_network_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Individual Related Party Network
    sc_insider_related_person_code  String                  COMMENT 'PK — mã người liên quan (self-join)',
    sc_senior_personnel_code        Nullable(String)        COMMENT 'Mã nhân sự cao cấp chính — join key self-join',
    related_person_full_nm          Nullable(String)        COMMENT 'Tên người có liên quan',
    rltnp                           Nullable(String)        COMMENT 'Mối quan hệ của người có liên quan',
    representative_position         Nullable(String)        COMMENT 'Vai trò/chức vụ của người có liên quan',
    identification_nbr              Nullable(String)        COMMENT 'CCCD người liên quan',
    shares_count                    Nullable(Int64)         COMMENT 'Số cổ phần người liên quan nắm giữ',
    ownership_ratio                 Nullable(Decimal(5,2))  COMMENT 'Tỷ lệ sở hữu cổ phần người liên quan',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (sc_insider_related_person_code)
COMMENT 'Flat table — Operational Individual Related Party Network'
;


-- ============================================================
-- 11. OPERATIONAL: qlkd_opr_individual_listed_company_role_flat
--    Operational Individual Listed Company Role
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_individual_listed_company_role_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Individual Listed Company Role
    sc_insider_related_person_code  String                  COMMENT 'PK — mã vai trò tại tổ chức (Bảng Tác nghiệp)',
    sc_senior_personnel_code        Nullable(String)        COMMENT 'Mã cá nhân — join key với Operational Individual Profile',
    sc_code                         Nullable(String)        COMMENT 'Mã tổ chức (CTCK)',
    representative_position         Nullable(String)        COMMENT 'Vai trò tại tổ chức',
    shares_count                    Nullable(Int64)         COMMENT 'Số cổ phần nắm giữ',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (sc_insider_related_person_code)
COMMENT 'Flat table — Operational Individual Listed Company Role'
;


-- ============================================================
-- 12. OPERATIONAL: qlkd_opr_individual_trading_account_flat
--    Operational Individual Trading Account
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_individual_trading_account_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Individual Trading Account
    sc_shareholder_code             String                  COMMENT 'PK — mã cổ đông/chủ TK (Bảng Tác nghiệp)',
    sc_code                         String                  COMMENT 'Mã CTCK nơi mở tài khoản',
    trading_account                 Nullable(String)        COMMENT 'Số tài khoản giao dịch',
    shareholder_nm                  Nullable(String)        COMMENT 'Tên chủ tài khoản',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (sc_shareholder_code)
COMMENT 'Flat table — Operational Individual Trading Account'
;


-- ============================================================
-- 13. OPERATIONAL: qlkd_opr_individual_work_hist_flat
--    Operational Individual Work History
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_individual_work_hist_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Individual Work History
    sc_senior_personnel_code        String                  COMMENT 'PK — mã lần bổ nhiệm (Bảng Tác nghiệp)',
    sc_code                         String                  COMMENT 'Mã CTCK công tác',
    position_nm                     Nullable(String)        COMMENT 'Chức vụ tại công ty',
    work_start_dt                   Nullable(Date)          COMMENT 'Ngày bắt đầu làm việc',
    resignation_dt                  Nullable(Date)          COMMENT 'Ngày nghỉ việc (NULL = hiện tại)',
    employment_status_code          Nullable(String)        COMMENT 'Trạng thái công tác (CURRENT/PAST) — derive từ Resignation Date',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(work_start_dt))
ORDER BY (assumeNotNull(work_start_dt), sc_senior_personnel_code)
COMMENT 'Flat table — Operational Individual Work History'
;


-- ============================================================
-- 14. OPERATIONAL: qlkd_opr_individual_violation_hist_flat
--    Operational Individual Violation History
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_individual_violation_hist_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Individual Violation History
    pd_code                         String                  COMMENT 'PK — mã quyết định xử phạt cá nhân (Bảng Tác nghiệp)',
    identification_nbr              Nullable(String)        COMMENT 'Số định danh cá nhân bị xử phạt — merge key với Operational Individual Profile',
    decision_nbr                    Nullable(String)        COMMENT 'Số quyết định xử phạt',
    issued_dt                       Nullable(Date)          COMMENT 'Ngày ban hành quyết định xử phạt',
    violation_behavior_nm           Nullable(String)        COMMENT 'Nội dung vi phạm',
    penalty_tp_nm                   Nullable(String)        COMMENT 'Hình thức xử phạt chính',
    decision_status_code            Nullable(String)        COMMENT 'Trạng thái quyết định — LEFT JOIN Violation Case',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(issued_dt))
ORDER BY (assumeNotNull(issued_dt), pd_code)
COMMENT 'Flat table — Operational Individual Violation History'
;

