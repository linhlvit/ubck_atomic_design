-- ============================================================
-- QLCB Flat Tables — CREATE
-- Module: Quản lý Chào bán (QLCB)
-- Generated: Phase 3 LLD Datamart
-- 5 bảng: 4 fact + 1 operational
-- ============================================================


-- ============================================================
-- 1. FACT: qlcb_fct_securities_offering_flat
--    Hồ sơ chào bán/phát hành CK — tổng giá trị cấp phép/huy động theo ngành, kỳ
--    Grain: 1 hồ sơ chào bán
--    Joins: Calendar Date (official_letter_dt_dim_id JOIN) × Public Company Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlcb_fct_securities_offering_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Securities Offering
    securities_offering_code           String                  COMMENT 'BK đợt chào bán (degenerate dimension)',
    official_letter_dt_dim_id          String                  COMMENT 'FK → Calendar Date Dimension',
    public_company_dim_id              String                  COMMENT 'FK → Public Company Dimension',
    total_expected_amt                 Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị dự kiến cấp phép (VNĐ)',
    total_collected_amt                Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị huy động thành công (VNĐ)',
    certificate_dt                     Nullable(Date)          COMMENT 'Ngày giấy chứng nhận',
    official_letter_dt                 Nullable(Date)          COMMENT 'Ngày công văn UBCKNN',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)          COMMENT 'Ngày công văn — từ Calendar Date Dimension',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code                 Nullable(String)        COMMENT 'Mã CTĐC — từ Public Company Dimension',
    equity_ticker_symbol                Nullable(String)        COMMENT 'Mã cổ phiếu — từ Public Company Dimension',
    public_company_nm                   Nullable(String)        COMMENT 'Tên doanh nghiệp — từ Public Company Dimension',
    equity_listing_exchange_code        Nullable(String)        COMMENT 'Sàn niêm yết — từ Public Company Dimension',
    business_line_level_1_code          Nullable(String)        COMMENT 'Ngành kinh tế cấp 1 — từ Public Company Dimension',
    ids_registration_dt                 Nullable(Date)          COMMENT 'Ngày đăng ký IDS — từ Public Company Dimension',
    public_company_status_code          Nullable(String)        COMMENT 'Trạng thái công ty — từ Public Company Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), securities_offering_code)
COMMENT 'Flat table — Fact Securities Offering × Calendar Date Dimension × Public Company Dimension'
;


-- ============================================================
-- 2. FACT: qlcb_fct_securities_offering_plan_flat
--    Giá trị cấp phép theo loại hình chào bán
--    Grain: 1 đợt × 1 loại hình kế hoạch
--    Joins: Calendar Date (official_letter_dt_dim_id JOIN) × Public Company Dimension × Offering Method Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlcb_fct_securities_offering_plan_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Securities Offering Plan
    securities_offering_code            String                  COMMENT 'BK đợt chào bán (degenerate dimension)',
    official_letter_dt_dim_id           String                  COMMENT 'FK → Calendar Date Dimension',
    public_company_dim_id               String                  COMMENT 'FK → Public Company Dimension',
    offering_method_dim_id              String                  COMMENT 'FK → Offering Method Dimension',
    total_expected_amt_snpst            Nullable(Decimal(23,2)) COMMENT 'Giá trị cấp phép theo loại hình (denormalized snapshot từ Offering cha)',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                               Nullable(Date)          COMMENT 'Ngày công văn — từ Calendar Date Dimension',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code                  Nullable(String)        COMMENT 'Mã CTĐC — từ Public Company Dimension',
    equity_ticker_symbol                 Nullable(String)        COMMENT 'Mã cổ phiếu — từ Public Company Dimension',
    public_company_nm                    Nullable(String)        COMMENT 'Tên doanh nghiệp — từ Public Company Dimension',
    equity_listing_exchange_code         Nullable(String)        COMMENT 'Sàn niêm yết — từ Public Company Dimension',
    business_line_level_1_code           Nullable(String)        COMMENT 'Ngành kinh tế cấp 1 — từ Public Company Dimension',
    ids_registration_dt                  Nullable(Date)          COMMENT 'Ngày đăng ký IDS — từ Public Company Dimension',
    public_company_status_code           Nullable(String)        COMMENT 'Trạng thái công ty — từ Public Company Dimension',

    -- From: OFFERING METHOD DIMENSION
    offering_method_code                 Nullable(String)        COMMENT 'Mã hình thức chào bán — từ Offering Method Dimension',
    offering_method_nm                   Nullable(String)        COMMENT 'Tên hiển thị hình thức chào bán — từ Offering Method Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), securities_offering_code, offering_method_dim_id)
COMMENT 'Flat table — Fact Securities Offering Plan × Calendar Date Dimension × Public Company Dimension × Offering Method Dimension'
;


-- ============================================================
-- 3. FACT: qlcb_fct_securities_offering_result_flat
--    Giá trị huy động theo loại hình chào bán
--    Grain: 1 đợt × 1 loại hình kết quả
--    Joins: Calendar Date (official_letter_dt_dim_id JOIN) × Public Company Dimension × Offering Method Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlcb_fct_securities_offering_result_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Securities Offering Result
    securities_offering_code            String                  COMMENT 'BK đợt chào bán (degenerate dimension)',
    official_letter_dt_dim_id           String                  COMMENT 'FK → Calendar Date Dimension',
    public_company_dim_id               String                  COMMENT 'FK → Public Company Dimension',
    offering_method_dim_id              String                  COMMENT 'FK → Offering Method Dimension',
    total_collected_amt                 Nullable(Decimal(23,2)) COMMENT 'Giá trị huy động theo loại hình',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                               Nullable(Date)          COMMENT 'Ngày công văn — từ Calendar Date Dimension',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code                  Nullable(String)        COMMENT 'Mã CTĐC — từ Public Company Dimension',
    equity_ticker_symbol                 Nullable(String)        COMMENT 'Mã cổ phiếu — từ Public Company Dimension',
    public_company_nm                    Nullable(String)        COMMENT 'Tên doanh nghiệp — từ Public Company Dimension',
    equity_listing_exchange_code         Nullable(String)        COMMENT 'Sàn niêm yết — từ Public Company Dimension',
    business_line_level_1_code           Nullable(String)        COMMENT 'Ngành kinh tế cấp 1 — từ Public Company Dimension',
    ids_registration_dt                  Nullable(Date)          COMMENT 'Ngày đăng ký IDS — từ Public Company Dimension',
    public_company_status_code           Nullable(String)        COMMENT 'Trạng thái công ty — từ Public Company Dimension',

    -- From: OFFERING METHOD DIMENSION
    offering_method_code                 Nullable(String)        COMMENT 'Mã hình thức chào bán — từ Offering Method Dimension',
    offering_method_nm                   Nullable(String)        COMMENT 'Tên hiển thị hình thức chào bán — từ Offering Method Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), securities_offering_code, offering_method_dim_id)
COMMENT 'Flat table — Fact Securities Offering Result × Calendar Date Dimension × Public Company Dimension × Offering Method Dimension'
;


-- ============================================================
-- 4. FACT: qlcb_fct_securities_offering_application_flat
--    Hồ sơ đăng ký chào bán nộp lên UBCKNN — đếm/phân tích theo trạng thái xử lý, hình thức, năm
--    Grain: 1 hồ sơ đăng ký chào bán
--    Joins: Calendar Date (official_letter_dt_dim_id JOIN) × Offering Method Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlcb_fct_securities_offering_application_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Securities Offering Application
    securities_offering_code            String                  COMMENT 'BK hồ sơ (degenerate dimension)',
    official_letter_dt_dim_id           String                  COMMENT 'FK → Calendar Date Dimension',
    application_status_code             Nullable(String)        COMMENT 'Trạng thái xử lý hồ sơ',
    offering_method_dim_id              Nullable(String)        COMMENT 'FK → Offering Method Dimension (nullable — join qua Plan)',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                               Nullable(Date)          COMMENT 'Ngày công văn — từ Calendar Date Dimension',

    -- From: OFFERING METHOD DIMENSION
    offering_method_code                 Nullable(String)        COMMENT 'Mã hình thức chào bán — từ Offering Method Dimension',
    offering_method_nm                   Nullable(String)        COMMENT 'Tên hiển thị hình thức chào bán — từ Offering Method Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), securities_offering_code)
COMMENT 'Flat table — Fact Securities Offering Application × Calendar Date Dimension × Offering Method Dimension'
;


-- ============================================================
-- 5. OPERATIONAL: qlcb_opr_securities_offering_360_profile_flat
--    Hồ sơ 360° tra cứu chi tiết từng đợt chào bán — pivot theo loại hình
--    Grain: 1 đợt chào bán × 1 loại hình
--    Không JOIN dim, không lọc theo ngày (bảng tác nghiệp)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlcb_opr_securities_offering_360_profile_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Securities Offering 360 Profile
    securities_offering_code            String                  COMMENT 'Composite BK component 1 — BK đợt chào bán',
    offering_method_code                 String                  COMMENT 'Composite BK component 2 — mã hình thức chào bán',
    public_company_code                  Nullable(String)        COMMENT 'Mã công ty đại chúng',
    public_company_nm                    Nullable(String)        COMMENT 'Tên doanh nghiệp',
    equity_ticker_symbol                 Nullable(String)        COMMENT 'Mã chứng khoán',
    securities_tp_code                   Nullable(String)        COMMENT 'Loại chứng khoán',
    total_registered_quantity            Nullable(Int64)         COMMENT 'Số lượng cấp phép (bảng cha, tổng toàn hồ sơ)',
    total_expected_amt                   Nullable(Decimal(23,2)) COMMENT 'Giá trị cấp phép (bảng cha)',
    total_successful_quantity            Nullable(Int64)         COMMENT 'Số lượng CK chào bán thành công',
    total_collected_amt                  Nullable(Decimal(23,2)) COMMENT 'Giá trị chào bán thành công',
    certificate_nbr                      Nullable(String)        COMMENT 'Số giấy chứng nhận',
    certificate_dt                       Nullable(Date)          COMMENT 'Ngày cấp giấy chứng nhận',
    official_letter_nbr                  Nullable(String)        COMMENT 'Số công văn gửi công ty',
    official_letter_dt                   Nullable(Date)          COMMENT 'Ngày công văn',
    capital_usage_plan                   Nullable(String)        COMMENT 'Mục đích sử dụng vốn',
    business_line_level_1_code           Nullable(String)        COMMENT 'Ngành kinh tế cấp 1',
    equity_listing_exchange_code         Nullable(String)        COMMENT 'Sàn niêm yết',
    consulting_organization_nm           Nullable(String)        COMMENT 'Đơn vị tư vấn',
    audit_organization_nm                Nullable(String)        COMMENT 'Tổ chức kiểm toán',
    underwriting_organization_nm         Nullable(String)        COMMENT 'Đơn vị bảo lãnh',
    credit_rating_organization_nm        Nullable(String)        COMMENT 'Đơn vị xếp hạng tín nhiệm',
    processor_user_nm_snpst              Nullable(String)        COMMENT 'Chuyên viên xử lý (snapshot)',
    successful_ratio_percentage          Nullable(Decimal(7,4))  COMMENT 'Tỷ lệ chào bán thành công',
    offering_price                       Nullable(Decimal(23,2)) COMMENT 'Giá cấp phép (kế hoạch)',
    employee_quantity                    Nullable(Int64)         COMMENT 'Số lượng người lao động (kế hoạch)',
    swap_target                          Nullable(String)        COMMENT 'Đối tượng (kế hoạch)',
    actual_offering_price                Nullable(Decimal(23,2)) COMMENT 'Giá thực tế',
    employee_quantity_result             Nullable(Int64)         COMMENT 'Số lượng người lao động (thực tế)',
    capital_src                          Nullable(String)        COMMENT 'Đối tượng (thực tế)',
    src_stm_code                         String                  COMMENT 'Mã hệ thống nguồn — hardcode IDS.SECURITIES_OFFERING_PLAN'
)
ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (securities_offering_code, offering_method_code)
COMMENT 'Flat table — Operational Securities Offering 360 Profile (tra cứu chi tiết, không join dim)'
;
