-- ============================================================
-- GSDC Flat Tables — CREATE
-- Module: Giám sát Công ty Đại chúng (GSDC)
-- Generated: Phase 3 LLD Datamart
-- 6 bảng: 6 fact + 0 operational
-- ============================================================


-- ============================================================
-- 1. FACT: gsdc_fct_public_company_risk_score_snpst_flat
--    Snapshot điểm chấm phân loại CTDC tổng hợp — 1 row / CTDC / kỳ đánh giá
--    Joins: Calendar Date (cdr_dt_dim_id JOIN) × Public Company Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_public_company_risk_score_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Public Company Risk Score Snapshot
    public_company_dim_id                  String              COMMENT 'FK → Public Company Dimension',
    cdr_dt_dim_id                   String              COMMENT 'FK → Calendar Date Dimension (kỳ đánh giá)',
    total_score_percentage         Nullable(Decimal(5,2))   COMMENT 'Tổng điểm phân loại (%)',
    compliance_score                Nullable(Int64)     COMMENT 'Điểm Tuân thủ',
    issuance_score                  Nullable(Int64)     COMMENT 'Điểm Phát hành',
    financial_score                 Nullable(Int64)     COMMENT 'Điểm Tài chính',
    non_financial_m_score           Nullable(Int64)     COMMENT 'Điểm Phi tài chính & M-Score',
    credit_rating_score              Nullable(Int64)     COMMENT 'Điểm Xếp hạng tín nhiệm DN',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                           Nullable(Date)      COMMENT 'Kỳ đánh giá — từ Calendar Date Dimension',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code                          Nullable(String)    COMMENT 'Mã CTDC — từ Public Company Dimension',
    equity_ticker_symbol            Nullable(String)    COMMENT 'Mã CK doanh nghiệp — từ Public Company Dimension',
    public_company_nm                            Nullable(String)    COMMENT 'Tên doanh nghiệp — từ Public Company Dimension',
    equity_listing_exchange_code    Nullable(String)    COMMENT 'Sàn niêm yết — từ Public Company Dimension',
    business_line_level_1_code      Nullable(String)    COMMENT 'Ngành kinh tế — từ Public Company Dimension',
    ids_registration_dt             Nullable(Date)       COMMENT 'Ngày đăng ký IDS — từ Public Company Dimension',
    public_company_status_code                  Nullable(String)    COMMENT 'Trạng thái CTDC — từ Public Company Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), public_company_dim_id)
COMMENT 'Flat table — Fact Public Company Risk Score Snapshot × Calendar Date Dimension × Public Company Dimension'
;


-- ============================================================
-- 2. FACT: gsdc_fct_public_company_compliance_score_snpst_flat
--    Snapshot điểm chi tiết 15 tiêu chí Tuân thủ + Tổng điểm — 1 row / CTDC / kỳ đánh giá
--    Joins: Calendar Date (cdr_dt_dim_id JOIN) × Public Company Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_public_company_compliance_score_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Public Company Compliance Score Snapshot
    public_company_dim_id                                String              COMMENT 'FK → Public Company Dimension',
    cdr_dt_dim_id                                 String              COMMENT 'FK → Calendar Date Dimension (kỳ đánh giá)',
    disclosure_bctc_score                         Nullable(Int64)     COMMENT 'Công bố BCTC',
    disclosure_bctn_score                         Nullable(Int64)     COMMENT 'Công bố BCTN',
    disclosure_governance_report_score            Nullable(Int64)     COMMENT 'Công bố báo cáo tình hình quản trị',
    disclosure_ceo_change_score                   Nullable(Int64)     COMMENT 'Công bố thông tin Thay đổi TGĐ/CTHĐQT',
    violation_ubck_score                          Nullable(Int64)     COMMENT 'Vi phạm từ UBCKNN',
    violation_other_score                         Nullable(Int64)     COMMENT 'Vi phạm từ các đơn vị khác',
    charter_regulation_score                      Nullable(Int64)     COMMENT 'Điều lệ Công ty và Các Quy chế hoạt động',
    annual_meeting_count_score                    Nullable(Int64)     COMMENT 'Số lượng ĐHĐCĐ thường niên trong 6 tháng đầu năm',
    independent_board_member_count_score          Nullable(Int64)     COMMENT 'Số lượng thành viên HĐQT độc lập',
    non_executive_board_member_count_score        Nullable(Int64)     COMMENT 'Số lượng thành viên HĐQT không điều hành',
    board_member_qualification_score              Nullable(Int64)     COMMENT 'Tư cách thành viên HĐQT/BKS/Kế toán trưởng',
    supervisory_board_count_score                 Nullable(Int64)     COMMENT 'Số lượng thành viên BKS hoặc Ủy ban kiểm toán',
    capital_use_progress_report_score             Nullable(Int64)     COMMENT 'Báo cáo tiến độ sử dụng vốn',
    capital_use_plan_change_score                 Nullable(Int64)     COMMENT 'Thay đổi phương án sử dụng vốn',
    total_compliance_score                        Nullable(Int64)     COMMENT 'Tổng điểm Tuân thủ',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                           Nullable(Date)      COMMENT 'Kỳ đánh giá — từ Calendar Date Dimension',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code                          Nullable(String)    COMMENT 'Mã CTDC — từ Public Company Dimension',
    equity_ticker_symbol            Nullable(String)    COMMENT 'Mã CK doanh nghiệp — từ Public Company Dimension',
    public_company_nm                            Nullable(String)    COMMENT 'Tên doanh nghiệp — từ Public Company Dimension',
    equity_listing_exchange_code    Nullable(String)    COMMENT 'Sàn niêm yết — từ Public Company Dimension',
    business_line_level_1_code      Nullable(String)    COMMENT 'Ngành kinh tế — từ Public Company Dimension',
    ids_registration_dt             Nullable(Date)       COMMENT 'Ngày đăng ký IDS — từ Public Company Dimension',
    public_company_status_code                  Nullable(String)    COMMENT 'Trạng thái CTDC — từ Public Company Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), public_company_dim_id)
COMMENT 'Flat table — Fact Public Company Compliance Score Snapshot × Calendar Date Dimension × Public Company Dimension'
;


-- ============================================================
-- 3. FACT: gsdc_fct_public_company_issuance_score_snpst_flat
--    Snapshot điểm chi tiết 7 tiêu chí Phát hành + Tổng điểm — 1 row / CTDC / kỳ đánh giá
--    Joins: Calendar Date (cdr_dt_dim_id JOIN) × Public Company Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_public_company_issuance_score_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Public Company Issuance Score Snapshot
    public_company_dim_id                       String              COMMENT 'FK → Public Company Dimension',
    cdr_dt_dim_id                        String              COMMENT 'FK → Calendar Date Dimension (kỳ đánh giá)',
    rapid_capital_increase_score         Nullable(Int64)     COMMENT 'Phát hành tăng vốn nhanh',
    private_placement_count_score        Nullable(Int64)     COMMENT 'Số lần chào bán cổ phiếu riêng lẻ',
    public_offering_count_score          Nullable(Int64)     COMMENT 'Số lần chào bán cổ phiếu ra công chúng',
    esop_issuance_count_score            Nullable(Int64)     COMMENT 'Số lần phát hành ESOP',
    unsecured_bond_ratio_score           Nullable(Int64)     COMMENT 'Tỷ lệ trái phiếu không có tài sản đảm bảo',
    credit_rating_score_issuance         Nullable(Int64)     COMMENT 'Điểm xếp hạng tín nhiệm (phát hành)',
    bond_debt_to_equity_score            Nullable(Int64)     COMMENT 'Nợ trái phiếu / VCSH',
    total_issuance_score                 Nullable(Int64)     COMMENT 'Tổng điểm Phát hành',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                           Nullable(Date)      COMMENT 'Kỳ đánh giá — từ Calendar Date Dimension',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code                          Nullable(String)    COMMENT 'Mã CTDC — từ Public Company Dimension',
    equity_ticker_symbol            Nullable(String)    COMMENT 'Mã CK doanh nghiệp — từ Public Company Dimension',
    public_company_nm                            Nullable(String)    COMMENT 'Tên doanh nghiệp — từ Public Company Dimension',
    equity_listing_exchange_code    Nullable(String)    COMMENT 'Sàn niêm yết — từ Public Company Dimension',
    business_line_level_1_code      Nullable(String)    COMMENT 'Ngành kinh tế — từ Public Company Dimension',
    ids_registration_dt             Nullable(Date)       COMMENT 'Ngày đăng ký IDS — từ Public Company Dimension',
    public_company_status_code                  Nullable(String)    COMMENT 'Trạng thái CTDC — từ Public Company Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), public_company_dim_id)
COMMENT 'Flat table — Fact Public Company Issuance Score Snapshot × Calendar Date Dimension × Public Company Dimension'
;


-- ============================================================
-- 4. FACT: gsdc_fct_public_company_financial_score_snpst_flat
--    Snapshot điểm chi tiết 10 tiêu chí Tài chính + Tổng điểm — 1 row / CTDC / kỳ đánh giá
--    Joins: Calendar Date (cdr_dt_dim_id JOIN) × Public Company Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_public_company_financial_score_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Public Company Financial Score Snapshot
    public_company_dim_id                        String              COMMENT 'FK → Public Company Dimension',
    cdr_dt_dim_id                         String              COMMENT 'FK → Calendar Date Dimension (kỳ đánh giá)',
    audit_opinion_score                   Nullable(Int64)     COMMENT 'Kiểm toán — Ý kiến kiểm toán',
    roa_score                             Nullable(Int64)     COMMENT 'ROA',
    operating_cash_flow_score             Nullable(Int64)     COMMENT 'Dòng tiền từ hoạt động kinh doanh',
    current_ratio_score                   Nullable(Int64)     COMMENT 'Khả năng thanh toán hiện thời',
    ebit_interest_coverage_score          Nullable(Int64)     COMMENT 'EBIT / Lãi vay',
    debt_to_equity_score                  Nullable(Int64)     COMMENT 'Nợ / VCSH',
    equity_score                          Nullable(Int64)     COMMENT 'VCSH',
    roe_score                             Nullable(Int64)     COMMENT 'ROE',
    financial_revenue_to_profit_score     Nullable(Int64)     COMMENT 'Doanh thu từ HĐ tài chính / Lợi nhuận sau thuế',
    other_revenue_to_profit_score         Nullable(Int64)     COMMENT 'Doanh thu từ hoạt động khác / Lợi nhuận sau thuế',
    total_financial_score                 Nullable(Int64)     COMMENT 'Tổng điểm Tài chính',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                           Nullable(Date)      COMMENT 'Kỳ đánh giá — từ Calendar Date Dimension',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code                          Nullable(String)    COMMENT 'Mã CTDC — từ Public Company Dimension',
    equity_ticker_symbol            Nullable(String)    COMMENT 'Mã CK doanh nghiệp — từ Public Company Dimension',
    public_company_nm                            Nullable(String)    COMMENT 'Tên doanh nghiệp — từ Public Company Dimension',
    equity_listing_exchange_code    Nullable(String)    COMMENT 'Sàn niêm yết — từ Public Company Dimension',
    business_line_level_1_code      Nullable(String)    COMMENT 'Ngành kinh tế — từ Public Company Dimension',
    ids_registration_dt             Nullable(Date)       COMMENT 'Ngày đăng ký IDS — từ Public Company Dimension',
    public_company_status_code                  Nullable(String)    COMMENT 'Trạng thái CTDC — từ Public Company Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), public_company_dim_id)
COMMENT 'Flat table — Fact Public Company Financial Score Snapshot × Calendar Date Dimension × Public Company Dimension'
;


-- ============================================================
-- 5. FACT: gsdc_fct_public_company_nonfinancial_score_snpst_flat
--    Snapshot điểm chi tiết 2 tiêu chí Phi tài chính & M-Score + Tổng điểm — 1 row / CTDC / kỳ đánh giá
--    Joins: Calendar Date (cdr_dt_dim_id JOIN) × Public Company Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_public_company_nonfinancial_score_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Public Company Non-Financial Score Snapshot
    public_company_dim_id                          String              COMMENT 'FK → Public Company Dimension',
    cdr_dt_dim_id                           String              COMMENT 'FK → Calendar Date Dimension (kỳ đánh giá)',
    business_registration_status_score      Nullable(Int64)     COMMENT 'Trạng thái đăng ký kinh doanh',
    m_score                                 Nullable(Int64)     COMMENT 'M-Score',
    total_nonfinancial_score                Nullable(Int64)     COMMENT 'Tổng điểm Phi tài chính & M-Score',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                           Nullable(Date)      COMMENT 'Kỳ đánh giá — từ Calendar Date Dimension',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code                          Nullable(String)    COMMENT 'Mã CTDC — từ Public Company Dimension',
    equity_ticker_symbol            Nullable(String)    COMMENT 'Mã CK doanh nghiệp — từ Public Company Dimension',
    public_company_nm                            Nullable(String)    COMMENT 'Tên doanh nghiệp — từ Public Company Dimension',
    equity_listing_exchange_code    Nullable(String)    COMMENT 'Sàn niêm yết — từ Public Company Dimension',
    business_line_level_1_code      Nullable(String)    COMMENT 'Ngành kinh tế — từ Public Company Dimension',
    ids_registration_dt             Nullable(Date)       COMMENT 'Ngày đăng ký IDS — từ Public Company Dimension',
    public_company_status_code                  Nullable(String)    COMMENT 'Trạng thái CTDC — từ Public Company Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), public_company_dim_id)
COMMENT 'Flat table — Fact Public Company Non-Financial Score Snapshot × Calendar Date Dimension × Public Company Dimension'
;


-- ============================================================
-- 6. FACT: gsdc_fct_public_company_financial_summary_snpst_flat
--    Snapshot tổng hợp tài chính CTDC theo kỳ báo cáo — 1 row / CTDC / kỳ báo cáo (năm × quý)
--    Joins: Calendar Date (cdr_dt_dim_id JOIN) × Public Company Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_public_company_financial_summary_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Public Company Financial Summary Snapshot
    public_company_dim_id                      String              COMMENT 'FK → Public Company Dimension',
    cdr_dt_dim_id                       String              COMMENT 'FK → Calendar Date Dimension (kỳ báo cáo)',
    submission_deadline_dt              Nullable(Date)      COMMENT 'Ngày hạn nộp BCTC',
    submission_dt                       Nullable(Date)      COMMENT 'Ngày nộp BCTC',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                           Nullable(Date)      COMMENT 'Kỳ báo cáo — từ Calendar Date Dimension',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code                          Nullable(String)    COMMENT 'Mã CTDC — từ Public Company Dimension',
    equity_ticker_symbol            Nullable(String)    COMMENT 'Mã CK doanh nghiệp — từ Public Company Dimension',
    public_company_nm                            Nullable(String)    COMMENT 'Tên doanh nghiệp — từ Public Company Dimension',
    equity_listing_exchange_code    Nullable(String)    COMMENT 'Sàn niêm yết — từ Public Company Dimension',
    business_line_level_1_code      Nullable(String)    COMMENT 'Ngành kinh tế — từ Public Company Dimension',
    ids_registration_dt             Nullable(Date)       COMMENT 'Ngày đăng ký IDS — từ Public Company Dimension',
    public_company_status_code                  Nullable(String)    COMMENT 'Trạng thái CTDC — từ Public Company Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), public_company_dim_id)
COMMENT 'Flat table — Fact Public Company Financial Summary Snapshot × Calendar Date Dimension × Public Company Dimension'
;
