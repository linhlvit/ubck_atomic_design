-- =====================================================================
-- GSDC — Flat Tables (CREATE)
-- 10 bảng: 5 Score Snapshot + Financial Report Value + Violation Report
--          Snapshot + 4 Fact-report (Nhóm 38-41, không FK Dimension)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Fact Public Company Risk Score Snapshot
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_public_company_risk_score_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT PUBLIC COMPANY RISK SCORE SNAPSHOT
    public_company_dim_id      String              COMMENT 'FK sang Public Company Dimension (surrogate key, full-scan toàn bộ CTĐC mỗi ngày ETL).',
    snpst_dt_dim_id             String              COMMENT 'FK tới Calendar Date Dimension — ngày chạy ETL (snapshot date).',
    evaluation_dt_dim_id        Nullable(String)    COMMENT 'FK tới Calendar Date Dimension — carry-forward: ngày kỳ đánh giá gần nhất.',
    evaluation_year             Nullable(String)    COMMENT 'Năm của kỳ đánh giá gần nhất được carry-forward.',
    evaluation_month            Nullable(String)    COMMENT 'Tháng của kỳ đánh giá gần nhất được carry-forward.',
    total_score_percentage      Nullable(Decimal(5,2))  COMMENT 'Điểm tổng hợp — carry-forward từ kỳ đánh giá gần nhất.',
    compliance_score            Nullable(Int64)     COMMENT 'Tuân thủ — carry-forward từ kỳ đánh giá gần nhất.',
    issuance_score               Nullable(Int64)     COMMENT 'Phát hành — carry-forward từ kỳ đánh giá gần nhất.',
    financial_score              Nullable(Int64)     COMMENT 'Tài chính — carry-forward từ kỳ đánh giá gần nhất.',
    non_financial_m_score        Nullable(Int64)     COMMENT 'Phi tài chính & M-Score — carry-forward từ kỳ đánh giá gần nhất.',
    credit_rating_score          Nullable(Int64)     COMMENT 'Xếp hạng tín nhiệm DN — carry-forward từ kỳ đánh giá gần nhất.',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                 Nullable(Date)      COMMENT 'Ngày snapshot ETL — từ Calendar Date Dimension.',
    evaluation_cdr_dt            Nullable(Date)      COMMENT 'Ngày kỳ đánh giá gần nhất (carry-forward) — từ Calendar Date Dimension.',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code               String              COMMENT 'Khóa nghiệp vụ — Mã CTĐC — từ Public Company Dimension.',
    equity_ticker_symbol               Nullable(String)    COMMENT 'Mã cổ phiếu — từ Public Company Dimension.',
    public_company_nm                  Nullable(String)    COMMENT 'Tên công ty (tiếng Việt) — từ Public Company Dimension.',
    equity_listing_exchange_code       Nullable(String)    COMMENT 'Sàn niêm yết — từ Public Company Dimension.',
    business_line_level_1_code         Nullable(String)    COMMENT 'Mã ngành cấp 1 — từ Public Company Dimension.',
    ids_registration_dt                Nullable(Date)      COMMENT 'Ngày đăng ký IDS — từ Public Company Dimension.',
    public_company_status_code         Nullable(String)    COMMENT 'Trạng thái công ty — từ Public Company Dimension.',
    classification_business_line_nm    Nullable(String)    COMMENT 'Tên ngành nghề kinh doanh cấp 1 — từ Public Company Dimension.',
    public_company_english_nm          Nullable(String)    COMMENT 'Tên công ty (tiếng Anh) — từ Public Company Dimension.',
    enterprise_tp_code                 Nullable(String)    COMMENT 'Loại hình doanh nghiệp — từ Public Company Dimension.',
    enterprise_tp_nm                   Nullable(String)    COMMENT 'Tên loại hình doanh nghiệp — LEFT JOIN cl_value (schema_code=''ENTERPRISE_TYPE''); hiện NULL 100% do gap Atomic (chưa có LOOKUP_VALUES cho COMPANY_PROFILES.ENTERPRISE_TYPE_CD) — từ Public Company Dimension.',
    public_company_tp_code             Nullable(String)    COMMENT 'Loại công ty đại chúng — từ Public Company Dimension.',
    head_office_province_nm            Nullable(String)    COMMENT 'Tỉnh/TP trụ sở chính — từ Public Company Dimension.',
    operating_status_code              Nullable(String)    COMMENT 'Trạng thái hoạt động doanh nghiệp — từ Public Company Dimension.',
    has_state_ownership_indicator      Nullable(Int64)     COMMENT 'Cờ có vốn nhà nước — từ Public Company Dimension.',
    charter_capital_amt                Nullable(Decimal(23,2)) COMMENT 'Vốn điều lệ — từ Public Company Dimension.',
    first_registration_dt              Nullable(Date)      COMMENT 'Ngày đăng ký lần đầu — từ Public Company Dimension.',
    latest_registration_dt             Nullable(Date)      COMMENT 'Ngày đăng ký thay đổi gần nhất — từ Public Company Dimension.',
    latest_registration_province_nm    Nullable(String)    COMMENT 'Tỉnh/TP đăng ký thay đổi gần nhất — từ Public Company Dimension.',
    ids_registration_indicator         Nullable(Int64)     COMMENT 'Trạng thái đăng ký IDS — từ Public Company Dimension.',
    public_company_form_code           Nullable(String)    COMMENT 'Hình thức trở thành công ty đại chúng — từ Public Company Dimension.',
    former_state_owned_indicator       Nullable(Int64)     COMMENT 'Doanh nghiệp nhà nước (trước đây) — từ Public Company Dimension.',
    foreign_direct_investment_indicator Nullable(Int64)    COMMENT 'Doanh nghiệp FDI — từ Public Company Dimension.',
    has_parent_company_indicator       Nullable(Int64)     COMMENT 'Có công ty mẹ — từ Public Company Dimension.',
    has_subsidiary_indicator           Nullable(Int64)     COMMENT 'Có công ty con — từ Public Company Dimension.',
    has_joint_venture_indicator        Nullable(Int64)     COMMENT 'Có liên doanh — từ Public Company Dimension.',
    ipo_company_indicator              Nullable(Int64)     COMMENT '1-Công ty đang IPO, 0-Công ty đại chúng — từ Public Company Dimension.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), public_company_dim_id)
COMMENT 'Flat table — Fact Public Company Risk Score Snapshot × Calendar Date × Public Company Dimension'
;

-- ---------------------------------------------------------------------
-- 2. Fact Public Company Compliance Score Snapshot
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_public_company_compliance_score_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT PUBLIC COMPANY COMPLIANCE SCORE SNAPSHOT
    public_company_dim_id      String              COMMENT 'FK sang Public Company Dimension (surrogate key, full-scan toàn bộ CTĐC mỗi ngày ETL).',
    snpst_dt_dim_id             String              COMMENT 'FK tới Calendar Date Dimension — ngày chạy ETL (snapshot date).',
    evaluation_dt_dim_id        Nullable(String)    COMMENT 'FK tới Calendar Date Dimension — carry-forward: ngày kỳ đánh giá gần nhất.',
    evaluation_year             Nullable(String)    COMMENT 'Năm của kỳ đánh giá gần nhất được carry-forward.',
    evaluation_month            Nullable(String)    COMMENT 'Tháng của kỳ đánh giá gần nhất được carry-forward.',
    disclosure_bctc_score        Nullable(Int64)     COMMENT 'Công bố BCTC.',
    disclosure_bctn_score        Nullable(Int64)     COMMENT 'Công bố BCTN.',
    disclosure_governance_report_score Nullable(Int64) COMMENT 'Công bố báo cáo tình hình quản trị.',
    disclosure_ceo_change_score  Nullable(Int64)     COMMENT 'Công bố thông tin Thay đổi TGĐ/CTHĐQT.',
    violation_ubck_score         Nullable(Int64)     COMMENT 'Vi phạm từ UBCKNN.',
    violation_other_score        Nullable(Int64)     COMMENT 'Vi phạm từ các đơn vị khác.',
    charter_regulation_score     Nullable(Int64)     COMMENT 'Điều lệ Công ty và Các Quy chế hoạt động.',
    annual_meeting_count_score   Nullable(Int64)     COMMENT 'Số lượng ĐHĐCĐ thường niên trong 6 tháng đầu năm.',
    independent_board_member_count_score Nullable(Int64) COMMENT 'Số lượng thành viên HĐQT độc lập.',
    non_executive_board_member_count_score Nullable(Int64) COMMENT 'Số lượng thành viên HĐQT không điều hành.',
    board_member_qualification_score Nullable(Int64) COMMENT 'Tư cách thành viên HĐQT/BKS/Kế toán trưởng.',
    supervisory_board_count_score Nullable(Int64)    COMMENT 'Số lượng thành viên BKS hoặc Ủy ban kiểm toán.',
    capital_use_progress_report_score Nullable(Int64) COMMENT 'Báo cáo tiến độ sử dụng vốn.',
    capital_use_plan_change_score Nullable(Int64)    COMMENT 'Thay đổi phương án sử dụng vốn.',
    total_compliance_score       Nullable(Int64)     COMMENT 'Tổng điểm Tuân thủ.',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                 Nullable(Date)      COMMENT 'Ngày snapshot ETL — từ Calendar Date Dimension.',
    evaluation_cdr_dt            Nullable(Date)      COMMENT 'Ngày kỳ đánh giá gần nhất (carry-forward) — từ Calendar Date Dimension.',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code               String              COMMENT 'Khóa nghiệp vụ — Mã CTĐC — từ Public Company Dimension.',
    equity_ticker_symbol               Nullable(String)    COMMENT 'Mã cổ phiếu — từ Public Company Dimension.',
    public_company_nm                  Nullable(String)    COMMENT 'Tên công ty (tiếng Việt) — từ Public Company Dimension.',
    equity_listing_exchange_code       Nullable(String)    COMMENT 'Sàn niêm yết — từ Public Company Dimension.',
    business_line_level_1_code         Nullable(String)    COMMENT 'Mã ngành cấp 1 — từ Public Company Dimension.',
    ids_registration_dt                Nullable(Date)      COMMENT 'Ngày đăng ký IDS — từ Public Company Dimension.',
    public_company_status_code         Nullable(String)    COMMENT 'Trạng thái công ty — từ Public Company Dimension.',
    classification_business_line_nm    Nullable(String)    COMMENT 'Tên ngành nghề kinh doanh cấp 1 — từ Public Company Dimension.',
    public_company_english_nm          Nullable(String)    COMMENT 'Tên công ty (tiếng Anh) — từ Public Company Dimension.',
    enterprise_tp_code                 Nullable(String)    COMMENT 'Loại hình doanh nghiệp — từ Public Company Dimension.',
    enterprise_tp_nm                   Nullable(String)    COMMENT 'Tên loại hình doanh nghiệp — LEFT JOIN cl_value (schema_code=''ENTERPRISE_TYPE''); hiện NULL 100% do gap Atomic (chưa có LOOKUP_VALUES cho COMPANY_PROFILES.ENTERPRISE_TYPE_CD) — từ Public Company Dimension.',
    public_company_tp_code             Nullable(String)    COMMENT 'Loại công ty đại chúng — từ Public Company Dimension.',
    head_office_province_nm            Nullable(String)    COMMENT 'Tỉnh/TP trụ sở chính — từ Public Company Dimension.',
    operating_status_code              Nullable(String)    COMMENT 'Trạng thái hoạt động doanh nghiệp — từ Public Company Dimension.',
    has_state_ownership_indicator      Nullable(Int64)     COMMENT 'Cờ có vốn nhà nước — từ Public Company Dimension.',
    charter_capital_amt                Nullable(Decimal(23,2)) COMMENT 'Vốn điều lệ — từ Public Company Dimension.',
    first_registration_dt              Nullable(Date)      COMMENT 'Ngày đăng ký lần đầu — từ Public Company Dimension.',
    latest_registration_dt             Nullable(Date)      COMMENT 'Ngày đăng ký thay đổi gần nhất — từ Public Company Dimension.',
    latest_registration_province_nm    Nullable(String)    COMMENT 'Tỉnh/TP đăng ký thay đổi gần nhất — từ Public Company Dimension.',
    ids_registration_indicator         Nullable(Int64)     COMMENT 'Trạng thái đăng ký IDS — từ Public Company Dimension.',
    public_company_form_code           Nullable(String)    COMMENT 'Hình thức trở thành công ty đại chúng — từ Public Company Dimension.',
    former_state_owned_indicator       Nullable(Int64)     COMMENT 'Doanh nghiệp nhà nước (trước đây) — từ Public Company Dimension.',
    foreign_direct_investment_indicator Nullable(Int64)    COMMENT 'Doanh nghiệp FDI — từ Public Company Dimension.',
    has_parent_company_indicator       Nullable(Int64)     COMMENT 'Có công ty mẹ — từ Public Company Dimension.',
    has_subsidiary_indicator           Nullable(Int64)     COMMENT 'Có công ty con — từ Public Company Dimension.',
    has_joint_venture_indicator        Nullable(Int64)     COMMENT 'Có liên doanh — từ Public Company Dimension.',
    ipo_company_indicator              Nullable(Int64)     COMMENT '1-Công ty đang IPO, 0-Công ty đại chúng — từ Public Company Dimension.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), public_company_dim_id)
COMMENT 'Flat table — Fact Public Company Compliance Score Snapshot × Calendar Date × Public Company Dimension'
;

-- ---------------------------------------------------------------------
-- 3. Fact Public Company Issuance Score Snapshot
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_public_company_issuance_score_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT PUBLIC COMPANY ISSUANCE SCORE SNAPSHOT
    public_company_dim_id      String              COMMENT 'FK sang Public Company Dimension (surrogate key, full-scan toàn bộ CTĐC mỗi ngày ETL).',
    snpst_dt_dim_id             String              COMMENT 'FK tới Calendar Date Dimension — ngày chạy ETL (snapshot date).',
    evaluation_dt_dim_id        Nullable(String)    COMMENT 'FK tới Calendar Date Dimension — carry-forward: ngày kỳ đánh giá gần nhất.',
    evaluation_year             Nullable(String)    COMMENT 'Năm của kỳ đánh giá gần nhất được carry-forward.',
    evaluation_month            Nullable(String)    COMMENT 'Tháng của kỳ đánh giá gần nhất được carry-forward.',
    rapid_capital_increase_score Nullable(Int64)    COMMENT 'Phát hành tăng vốn nhanh.',
    private_placement_count_score Nullable(Int64)   COMMENT 'Số lần chào bán cổ phiếu riêng lẻ.',
    public_offering_count_score  Nullable(Int64)     COMMENT 'Số lần chào bán ra công chúng.',
    esop_issuance_count_score    Nullable(Int64)     COMMENT 'Số lần phát hành ESOP.',
    unsecured_bond_ratio_score   Nullable(Int64)     COMMENT 'Tỷ lệ phát hành trái phiếu không có TSBĐ.',
    credit_rating_score_issuance Nullable(Int64)    COMMENT 'Xếp hạng tín nhiệm.',
    bond_debt_to_equity_score    Nullable(Int64)     COMMENT 'Dư nợ trái phiếu / Tổng VCSH.',
    total_issuance_score         Nullable(Int64)     COMMENT 'Tổng điểm — SUM(evaluation_score) filter Group Code = PHAT_HANH.',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                 Nullable(Date)      COMMENT 'Ngày snapshot ETL — từ Calendar Date Dimension.',
    evaluation_cdr_dt            Nullable(Date)      COMMENT 'Ngày kỳ đánh giá gần nhất (carry-forward) — từ Calendar Date Dimension.',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code               String              COMMENT 'Khóa nghiệp vụ — Mã CTĐC — từ Public Company Dimension.',
    equity_ticker_symbol               Nullable(String)    COMMENT 'Mã cổ phiếu — từ Public Company Dimension.',
    public_company_nm                  Nullable(String)    COMMENT 'Tên công ty (tiếng Việt) — từ Public Company Dimension.',
    equity_listing_exchange_code       Nullable(String)    COMMENT 'Sàn niêm yết — từ Public Company Dimension.',
    business_line_level_1_code         Nullable(String)    COMMENT 'Mã ngành cấp 1 — từ Public Company Dimension.',
    ids_registration_dt                Nullable(Date)      COMMENT 'Ngày đăng ký IDS — từ Public Company Dimension.',
    public_company_status_code         Nullable(String)    COMMENT 'Trạng thái công ty — từ Public Company Dimension.',
    classification_business_line_nm    Nullable(String)    COMMENT 'Tên ngành nghề kinh doanh cấp 1 — từ Public Company Dimension.',
    public_company_english_nm          Nullable(String)    COMMENT 'Tên công ty (tiếng Anh) — từ Public Company Dimension.',
    enterprise_tp_code                 Nullable(String)    COMMENT 'Loại hình doanh nghiệp — từ Public Company Dimension.',
    enterprise_tp_nm                   Nullable(String)    COMMENT 'Tên loại hình doanh nghiệp — LEFT JOIN cl_value (schema_code=''ENTERPRISE_TYPE''); hiện NULL 100% do gap Atomic (chưa có LOOKUP_VALUES cho COMPANY_PROFILES.ENTERPRISE_TYPE_CD) — từ Public Company Dimension.',
    public_company_tp_code             Nullable(String)    COMMENT 'Loại công ty đại chúng — từ Public Company Dimension.',
    head_office_province_nm            Nullable(String)    COMMENT 'Tỉnh/TP trụ sở chính — từ Public Company Dimension.',
    operating_status_code              Nullable(String)    COMMENT 'Trạng thái hoạt động doanh nghiệp — từ Public Company Dimension.',
    has_state_ownership_indicator      Nullable(Int64)     COMMENT 'Cờ có vốn nhà nước — từ Public Company Dimension.',
    charter_capital_amt                Nullable(Decimal(23,2)) COMMENT 'Vốn điều lệ — từ Public Company Dimension.',
    first_registration_dt              Nullable(Date)      COMMENT 'Ngày đăng ký lần đầu — từ Public Company Dimension.',
    latest_registration_dt             Nullable(Date)      COMMENT 'Ngày đăng ký thay đổi gần nhất — từ Public Company Dimension.',
    latest_registration_province_nm    Nullable(String)    COMMENT 'Tỉnh/TP đăng ký thay đổi gần nhất — từ Public Company Dimension.',
    ids_registration_indicator         Nullable(Int64)     COMMENT 'Trạng thái đăng ký IDS — từ Public Company Dimension.',
    public_company_form_code           Nullable(String)    COMMENT 'Hình thức trở thành công ty đại chúng — từ Public Company Dimension.',
    former_state_owned_indicator       Nullable(Int64)     COMMENT 'Doanh nghiệp nhà nước (trước đây) — từ Public Company Dimension.',
    foreign_direct_investment_indicator Nullable(Int64)    COMMENT 'Doanh nghiệp FDI — từ Public Company Dimension.',
    has_parent_company_indicator       Nullable(Int64)     COMMENT 'Có công ty mẹ — từ Public Company Dimension.',
    has_subsidiary_indicator           Nullable(Int64)     COMMENT 'Có công ty con — từ Public Company Dimension.',
    has_joint_venture_indicator        Nullable(Int64)     COMMENT 'Có liên doanh — từ Public Company Dimension.',
    ipo_company_indicator              Nullable(Int64)     COMMENT '1-Công ty đang IPO, 0-Công ty đại chúng — từ Public Company Dimension.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), public_company_dim_id)
COMMENT 'Flat table — Fact Public Company Issuance Score Snapshot × Calendar Date × Public Company Dimension'
;

-- ---------------------------------------------------------------------
-- 4. Fact Public Company Financial Score Snapshot
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_public_company_financial_score_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT PUBLIC COMPANY FINANCIAL SCORE SNAPSHOT
    public_company_dim_id      String              COMMENT 'FK sang Public Company Dimension (surrogate key, full-scan toàn bộ CTĐC mỗi ngày ETL).',
    snpst_dt_dim_id             String              COMMENT 'FK tới Calendar Date Dimension — ngày chạy ETL (snapshot date).',
    evaluation_dt_dim_id        Nullable(String)    COMMENT 'FK tới Calendar Date Dimension — carry-forward: ngày kỳ đánh giá gần nhất.',
    evaluation_year             Nullable(String)    COMMENT 'Năm của kỳ đánh giá gần nhất được carry-forward.',
    evaluation_month            Nullable(String)    COMMENT 'Tháng của kỳ đánh giá gần nhất được carry-forward.',
    audit_opinion_score          Nullable(Int64)     COMMENT 'Kiểm toán — Ý kiến kiểm toán.',
    roa_score                    Nullable(Int64)     COMMENT 'ROA.',
    operating_cash_flow_score    Nullable(Int64)     COMMENT 'Dòng tiền từ hoạt động kinh doanh.',
    current_ratio_score          Nullable(Int64)     COMMENT 'Khả năng thanh toán hiện thời.',
    ebit_interest_coverage_score Nullable(Int64)     COMMENT 'EBIT / Lãi vay.',
    debt_to_equity_score         Nullable(Int64)     COMMENT 'Nợ / VCSH.',
    equity_score                 Nullable(Int64)     COMMENT 'VCSH.',
    roe_score                    Nullable(Int64)     COMMENT 'ROE.',
    financial_revenue_to_profit_score Nullable(Int64) COMMENT 'Doanh thu từ HĐ tài chính / Lợi nhuận sau thuế.',
    other_revenue_to_profit_score Nullable(Int64)    COMMENT 'Doanh thu từ hoạt động khác / Lợi nhuận sau thuế.',
    total_financial_score        Nullable(Int64)     COMMENT 'Tổng điểm — SUM(evaluation_score) filter Group Code = TAI_CHINH.',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                 Nullable(Date)      COMMENT 'Ngày snapshot ETL — từ Calendar Date Dimension.',
    evaluation_cdr_dt            Nullable(Date)      COMMENT 'Ngày kỳ đánh giá gần nhất (carry-forward) — từ Calendar Date Dimension.',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code               String              COMMENT 'Khóa nghiệp vụ — Mã CTĐC — từ Public Company Dimension.',
    equity_ticker_symbol               Nullable(String)    COMMENT 'Mã cổ phiếu — từ Public Company Dimension.',
    public_company_nm                  Nullable(String)    COMMENT 'Tên công ty (tiếng Việt) — từ Public Company Dimension.',
    equity_listing_exchange_code       Nullable(String)    COMMENT 'Sàn niêm yết — từ Public Company Dimension.',
    business_line_level_1_code         Nullable(String)    COMMENT 'Mã ngành cấp 1 — từ Public Company Dimension.',
    ids_registration_dt                Nullable(Date)      COMMENT 'Ngày đăng ký IDS — từ Public Company Dimension.',
    public_company_status_code         Nullable(String)    COMMENT 'Trạng thái công ty — từ Public Company Dimension.',
    classification_business_line_nm    Nullable(String)    COMMENT 'Tên ngành nghề kinh doanh cấp 1 — từ Public Company Dimension.',
    public_company_english_nm          Nullable(String)    COMMENT 'Tên công ty (tiếng Anh) — từ Public Company Dimension.',
    enterprise_tp_code                 Nullable(String)    COMMENT 'Loại hình doanh nghiệp — từ Public Company Dimension.',
    enterprise_tp_nm                   Nullable(String)    COMMENT 'Tên loại hình doanh nghiệp — LEFT JOIN cl_value (schema_code=''ENTERPRISE_TYPE''); hiện NULL 100% do gap Atomic (chưa có LOOKUP_VALUES cho COMPANY_PROFILES.ENTERPRISE_TYPE_CD) — từ Public Company Dimension.',
    public_company_tp_code             Nullable(String)    COMMENT 'Loại công ty đại chúng — từ Public Company Dimension.',
    head_office_province_nm            Nullable(String)    COMMENT 'Tỉnh/TP trụ sở chính — từ Public Company Dimension.',
    operating_status_code              Nullable(String)    COMMENT 'Trạng thái hoạt động doanh nghiệp — từ Public Company Dimension.',
    has_state_ownership_indicator      Nullable(Int64)     COMMENT 'Cờ có vốn nhà nước — từ Public Company Dimension.',
    charter_capital_amt                Nullable(Decimal(23,2)) COMMENT 'Vốn điều lệ — từ Public Company Dimension.',
    first_registration_dt              Nullable(Date)      COMMENT 'Ngày đăng ký lần đầu — từ Public Company Dimension.',
    latest_registration_dt             Nullable(Date)      COMMENT 'Ngày đăng ký thay đổi gần nhất — từ Public Company Dimension.',
    latest_registration_province_nm    Nullable(String)    COMMENT 'Tỉnh/TP đăng ký thay đổi gần nhất — từ Public Company Dimension.',
    ids_registration_indicator         Nullable(Int64)     COMMENT 'Trạng thái đăng ký IDS — từ Public Company Dimension.',
    public_company_form_code           Nullable(String)    COMMENT 'Hình thức trở thành công ty đại chúng — từ Public Company Dimension.',
    former_state_owned_indicator       Nullable(Int64)     COMMENT 'Doanh nghiệp nhà nước (trước đây) — từ Public Company Dimension.',
    foreign_direct_investment_indicator Nullable(Int64)    COMMENT 'Doanh nghiệp FDI — từ Public Company Dimension.',
    has_parent_company_indicator       Nullable(Int64)     COMMENT 'Có công ty mẹ — từ Public Company Dimension.',
    has_subsidiary_indicator           Nullable(Int64)     COMMENT 'Có công ty con — từ Public Company Dimension.',
    has_joint_venture_indicator        Nullable(Int64)     COMMENT 'Có liên doanh — từ Public Company Dimension.',
    ipo_company_indicator              Nullable(Int64)     COMMENT '1-Công ty đang IPO, 0-Công ty đại chúng — từ Public Company Dimension.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), public_company_dim_id)
COMMENT 'Flat table — Fact Public Company Financial Score Snapshot × Calendar Date × Public Company Dimension'
;

-- ---------------------------------------------------------------------
-- 5. Fact Public Company Non-Financial Score Snapshot
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_public_company_nonfinancial_score_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT PUBLIC COMPANY NON-FINANCIAL SCORE SNAPSHOT
    public_company_dim_id      String              COMMENT 'FK sang Public Company Dimension (surrogate key, full-scan toàn bộ CTĐC mỗi ngày ETL).',
    snpst_dt_dim_id             String              COMMENT 'FK tới Calendar Date Dimension — ngày chạy ETL (snapshot date).',
    evaluation_dt_dim_id        Nullable(String)    COMMENT 'FK tới Calendar Date Dimension — carry-forward: ngày kỳ đánh giá gần nhất.',
    evaluation_year             Nullable(String)    COMMENT 'Năm của kỳ đánh giá gần nhất được carry-forward.',
    evaluation_month            Nullable(String)    COMMENT 'Tháng của kỳ đánh giá gần nhất được carry-forward.',
    business_registration_status_score Nullable(Int64) COMMENT 'Tình trạng DN từ Cục Đăng ký kinh doanh.',
    m_score                       Nullable(Int64)     COMMENT 'M-Score.',
    total_nonfinancial_score     Nullable(Int64)     COMMENT 'Tổng điểm — SUM(evaluation_score) filter Group Code = PHI_TAI_CHINH.',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                 Nullable(Date)      COMMENT 'Ngày snapshot ETL — từ Calendar Date Dimension.',
    evaluation_cdr_dt            Nullable(Date)      COMMENT 'Ngày kỳ đánh giá gần nhất (carry-forward) — từ Calendar Date Dimension.',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code               String              COMMENT 'Khóa nghiệp vụ — Mã CTĐC — từ Public Company Dimension.',
    equity_ticker_symbol               Nullable(String)    COMMENT 'Mã cổ phiếu — từ Public Company Dimension.',
    public_company_nm                  Nullable(String)    COMMENT 'Tên công ty (tiếng Việt) — từ Public Company Dimension.',
    equity_listing_exchange_code       Nullable(String)    COMMENT 'Sàn niêm yết — từ Public Company Dimension.',
    business_line_level_1_code         Nullable(String)    COMMENT 'Mã ngành cấp 1 — từ Public Company Dimension.',
    ids_registration_dt                Nullable(Date)      COMMENT 'Ngày đăng ký IDS — từ Public Company Dimension.',
    public_company_status_code         Nullable(String)    COMMENT 'Trạng thái công ty — từ Public Company Dimension.',
    classification_business_line_nm    Nullable(String)    COMMENT 'Tên ngành nghề kinh doanh cấp 1 — từ Public Company Dimension.',
    public_company_english_nm          Nullable(String)    COMMENT 'Tên công ty (tiếng Anh) — từ Public Company Dimension.',
    enterprise_tp_code                 Nullable(String)    COMMENT 'Loại hình doanh nghiệp — từ Public Company Dimension.',
    enterprise_tp_nm                   Nullable(String)    COMMENT 'Tên loại hình doanh nghiệp — LEFT JOIN cl_value (schema_code=''ENTERPRISE_TYPE''); hiện NULL 100% do gap Atomic (chưa có LOOKUP_VALUES cho COMPANY_PROFILES.ENTERPRISE_TYPE_CD) — từ Public Company Dimension.',
    public_company_tp_code             Nullable(String)    COMMENT 'Loại công ty đại chúng — từ Public Company Dimension.',
    head_office_province_nm            Nullable(String)    COMMENT 'Tỉnh/TP trụ sở chính — từ Public Company Dimension.',
    operating_status_code              Nullable(String)    COMMENT 'Trạng thái hoạt động doanh nghiệp — từ Public Company Dimension.',
    has_state_ownership_indicator      Nullable(Int64)     COMMENT 'Cờ có vốn nhà nước — từ Public Company Dimension.',
    charter_capital_amt                Nullable(Decimal(23,2)) COMMENT 'Vốn điều lệ — từ Public Company Dimension.',
    first_registration_dt              Nullable(Date)      COMMENT 'Ngày đăng ký lần đầu — từ Public Company Dimension.',
    latest_registration_dt             Nullable(Date)      COMMENT 'Ngày đăng ký thay đổi gần nhất — từ Public Company Dimension.',
    latest_registration_province_nm    Nullable(String)    COMMENT 'Tỉnh/TP đăng ký thay đổi gần nhất — từ Public Company Dimension.',
    ids_registration_indicator         Nullable(Int64)     COMMENT 'Trạng thái đăng ký IDS — từ Public Company Dimension.',
    public_company_form_code           Nullable(String)    COMMENT 'Hình thức trở thành công ty đại chúng — từ Public Company Dimension.',
    former_state_owned_indicator       Nullable(Int64)     COMMENT 'Doanh nghiệp nhà nước (trước đây) — từ Public Company Dimension.',
    foreign_direct_investment_indicator Nullable(Int64)    COMMENT 'Doanh nghiệp FDI — từ Public Company Dimension.',
    has_parent_company_indicator       Nullable(Int64)     COMMENT 'Có công ty mẹ — từ Public Company Dimension.',
    has_subsidiary_indicator           Nullable(Int64)     COMMENT 'Có công ty con — từ Public Company Dimension.',
    has_joint_venture_indicator        Nullable(Int64)     COMMENT 'Có liên doanh — từ Public Company Dimension.',
    ipo_company_indicator              Nullable(Int64)     COMMENT '1-Công ty đang IPO, 0-Công ty đại chúng — từ Public Company Dimension.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), public_company_dim_id)
COMMENT 'Flat table — Fact Public Company Non-Financial Score Snapshot × Calendar Date × Public Company Dimension'
;

-- ---------------------------------------------------------------------
-- 6. Fact Violation Report Snapshot
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_violation_rpt_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT VIOLATION REPORT SNAPSHOT
    public_company_dim_id      String              COMMENT 'FK sang Public Company Dimension (surrogate key).',
    snpst_dt_dim_id             String              COMMENT 'FK tới Calendar Date Dimension — ngày chạy ETL (snapshot date).',
    rpt_year                     Nullable(String)    COMMENT 'Năm của kỳ báo cáo nghĩa vụ.',
    rpt_quarter                  Nullable(String)    COMMENT 'Loại kỳ báo cáo: 1-4 = Quý 1-4; 5 = Năm; 6 = Bán niên.',
    rpt_due_count                Nullable(Int64)     COMMENT 'Số hồ sơ báo cáo định kỳ đã đến hạn nộp trong kỳ.',
    rpt_submitted_count          Nullable(Int64)     COMMENT 'Số hồ sơ báo cáo định kỳ đã nộp thực tế trong kỳ.',
    profitable_indicator         Nullable(Int64)     COMMENT 'Công ty có LNST > 0 trong kỳ hay không (1/0).',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                 Nullable(Date)      COMMENT 'Ngày snapshot ETL — từ Calendar Date Dimension.',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code               String              COMMENT 'Khóa nghiệp vụ — Mã CTĐC — từ Public Company Dimension.',
    equity_ticker_symbol               Nullable(String)    COMMENT 'Mã cổ phiếu — từ Public Company Dimension.',
    public_company_nm                  Nullable(String)    COMMENT 'Tên công ty (tiếng Việt) — từ Public Company Dimension.',
    equity_listing_exchange_code       Nullable(String)    COMMENT 'Sàn niêm yết — từ Public Company Dimension.',
    business_line_level_1_code         Nullable(String)    COMMENT 'Mã ngành cấp 1 — từ Public Company Dimension.',
    ids_registration_dt                Nullable(Date)      COMMENT 'Ngày đăng ký IDS — từ Public Company Dimension.',
    public_company_status_code         Nullable(String)    COMMENT 'Trạng thái công ty — từ Public Company Dimension.',
    classification_business_line_nm    Nullable(String)    COMMENT 'Tên ngành nghề kinh doanh cấp 1 — từ Public Company Dimension.',
    public_company_english_nm          Nullable(String)    COMMENT 'Tên công ty (tiếng Anh) — từ Public Company Dimension.',
    enterprise_tp_code                 Nullable(String)    COMMENT 'Loại hình doanh nghiệp — từ Public Company Dimension.',
    enterprise_tp_nm                   Nullable(String)    COMMENT 'Tên loại hình doanh nghiệp — LEFT JOIN cl_value (schema_code=''ENTERPRISE_TYPE''); hiện NULL 100% do gap Atomic (chưa có LOOKUP_VALUES cho COMPANY_PROFILES.ENTERPRISE_TYPE_CD) — từ Public Company Dimension.',
    public_company_tp_code             Nullable(String)    COMMENT 'Loại công ty đại chúng — từ Public Company Dimension.',
    head_office_province_nm            Nullable(String)    COMMENT 'Tỉnh/TP trụ sở chính — từ Public Company Dimension.',
    operating_status_code              Nullable(String)    COMMENT 'Trạng thái hoạt động doanh nghiệp — từ Public Company Dimension.',
    has_state_ownership_indicator      Nullable(Int64)     COMMENT 'Cờ có vốn nhà nước — từ Public Company Dimension.',
    charter_capital_amt                Nullable(Decimal(23,2)) COMMENT 'Vốn điều lệ — từ Public Company Dimension.',
    first_registration_dt              Nullable(Date)      COMMENT 'Ngày đăng ký lần đầu — từ Public Company Dimension.',
    latest_registration_dt             Nullable(Date)      COMMENT 'Ngày đăng ký thay đổi gần nhất — từ Public Company Dimension.',
    latest_registration_province_nm    Nullable(String)    COMMENT 'Tỉnh/TP đăng ký thay đổi gần nhất — từ Public Company Dimension.',
    ids_registration_indicator         Nullable(Int64)     COMMENT 'Trạng thái đăng ký IDS — từ Public Company Dimension.',
    public_company_form_code           Nullable(String)    COMMENT 'Hình thức trở thành công ty đại chúng — từ Public Company Dimension.',
    former_state_owned_indicator       Nullable(Int64)     COMMENT 'Doanh nghiệp nhà nước (trước đây) — từ Public Company Dimension.',
    foreign_direct_investment_indicator Nullable(Int64)    COMMENT 'Doanh nghiệp FDI — từ Public Company Dimension.',
    has_parent_company_indicator       Nullable(Int64)     COMMENT 'Có công ty mẹ — từ Public Company Dimension.',
    has_subsidiary_indicator           Nullable(Int64)     COMMENT 'Có công ty con — từ Public Company Dimension.',
    has_joint_venture_indicator        Nullable(Int64)     COMMENT 'Có liên doanh — từ Public Company Dimension.',
    ipo_company_indicator              Nullable(Int64)     COMMENT '1-Công ty đang IPO, 0-Công ty đại chúng — từ Public Company Dimension.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), public_company_dim_id)
COMMENT 'Flat table — Fact Violation Report Snapshot × Calendar Date × Public Company Dimension'
;

-- ---------------------------------------------------------------------
-- 7. Fact Public Company Financial Report Value
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_public_company_financial_rpt_val_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT PUBLIC COMPANY FINANCIAL REPORT VALUE
    public_company_dim_id        String              COMMENT 'FK sang Public Company Dimension (surrogate key).',
    financial_rpt_catalog_dim_id  String              COMMENT 'FK tới Financial Report Catalog Dimension — khóa composite Catalog Code + Row Code + Column Code.',
    snpst_dt_dim_id                String              COMMENT 'FK tới Calendar Date Dimension — ngày chạy ETL (snapshot date).',
    rpt_year                       Int64               COMMENT 'Năm báo cáo tài chính — 1 phần grain key.',
    rpt_quarter                    Nullable(Int64)     COMMENT 'Quý báo cáo tài chính — 1 phần grain key.',
    row_code                       String              COMMENT 'Mã kỹ thuật dòng — 1 phần grain key.',
    column_code                    String              COMMENT 'Mã kỹ thuật cột — 1 phần grain key.',
    data_val                       Nullable(Decimal(23,2)) COMMENT 'Giá trị dữ liệu tại ô báo cáo (Row Code × Column Code).',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                   Nullable(Date)      COMMENT 'Ngày snapshot ETL — từ Calendar Date Dimension.',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code               String              COMMENT 'Khóa nghiệp vụ — Mã CTĐC — từ Public Company Dimension.',
    equity_ticker_symbol               Nullable(String)    COMMENT 'Mã cổ phiếu — từ Public Company Dimension.',
    public_company_nm                  Nullable(String)    COMMENT 'Tên công ty (tiếng Việt) — từ Public Company Dimension.',
    equity_listing_exchange_code       Nullable(String)    COMMENT 'Sàn niêm yết — từ Public Company Dimension.',
    business_line_level_1_code         Nullable(String)    COMMENT 'Mã ngành cấp 1 — từ Public Company Dimension.',
    ids_registration_dt                Nullable(Date)      COMMENT 'Ngày đăng ký IDS — từ Public Company Dimension.',
    public_company_status_code         Nullable(String)    COMMENT 'Trạng thái công ty — từ Public Company Dimension.',
    classification_business_line_nm    Nullable(String)    COMMENT 'Tên ngành nghề kinh doanh cấp 1 — từ Public Company Dimension.',
    public_company_english_nm          Nullable(String)    COMMENT 'Tên công ty (tiếng Anh) — từ Public Company Dimension.',
    enterprise_tp_code                 Nullable(String)    COMMENT 'Loại hình doanh nghiệp — từ Public Company Dimension.',
    enterprise_tp_nm                   Nullable(String)    COMMENT 'Tên loại hình doanh nghiệp — LEFT JOIN cl_value (schema_code=''ENTERPRISE_TYPE''); hiện NULL 100% do gap Atomic (chưa có LOOKUP_VALUES cho COMPANY_PROFILES.ENTERPRISE_TYPE_CD) — từ Public Company Dimension.',
    public_company_tp_code             Nullable(String)    COMMENT 'Loại công ty đại chúng — từ Public Company Dimension.',
    head_office_province_nm            Nullable(String)    COMMENT 'Tỉnh/TP trụ sở chính — từ Public Company Dimension.',
    operating_status_code              Nullable(String)    COMMENT 'Trạng thái hoạt động doanh nghiệp — từ Public Company Dimension.',
    has_state_ownership_indicator      Nullable(Int64)     COMMENT 'Cờ có vốn nhà nước — từ Public Company Dimension.',
    charter_capital_amt                Nullable(Decimal(23,2)) COMMENT 'Vốn điều lệ — từ Public Company Dimension.',
    first_registration_dt              Nullable(Date)      COMMENT 'Ngày đăng ký lần đầu — từ Public Company Dimension.',
    latest_registration_dt             Nullable(Date)      COMMENT 'Ngày đăng ký thay đổi gần nhất — từ Public Company Dimension.',
    latest_registration_province_nm    Nullable(String)    COMMENT 'Tỉnh/TP đăng ký thay đổi gần nhất — từ Public Company Dimension.',
    ids_registration_indicator         Nullable(Int64)     COMMENT 'Trạng thái đăng ký IDS — từ Public Company Dimension.',
    public_company_form_code           Nullable(String)    COMMENT 'Hình thức trở thành công ty đại chúng — từ Public Company Dimension.',
    former_state_owned_indicator       Nullable(Int64)     COMMENT 'Doanh nghiệp nhà nước (trước đây) — từ Public Company Dimension.',
    foreign_direct_investment_indicator Nullable(Int64)    COMMENT 'Doanh nghiệp FDI — từ Public Company Dimension.',
    has_parent_company_indicator       Nullable(Int64)     COMMENT 'Có công ty mẹ — từ Public Company Dimension.',
    has_subsidiary_indicator           Nullable(Int64)     COMMENT 'Có công ty con — từ Public Company Dimension.',
    has_joint_venture_indicator        Nullable(Int64)     COMMENT 'Có liên doanh — từ Public Company Dimension.',
    ipo_company_indicator              Nullable(Int64)     COMMENT '1-Công ty đang IPO, 0-Công ty đại chúng — từ Public Company Dimension.',

    -- From: FINANCIAL REPORT CATALOG DIMENSION
    financial_rpt_catalog_code    Nullable(String)    COMMENT 'Mã báo cáo — từ Financial Report Catalog Dimension.',
    financial_rpt_catalog_nm      Nullable(String)    COMMENT 'Tên báo cáo (tiếng Việt) — từ Financial Report Catalog Dimension.',
    financial_rpt_catalog_tp_code Nullable(String)    COMMENT 'Loại báo cáo (I/O) — từ Financial Report Catalog Dimension.',
    fr_catalog_enterprise_tp_code  Nullable(String)    COMMENT 'Loại hình doanh nghiệp (DN, BH, TD, CK) — từ Financial Report Catalog Dimension.',
    row_description_reference     Nullable(String)    COMMENT 'Mã dòng hiển thị trên biểu mẫu — từ Financial Report Catalog Dimension.',
    column_description_reference  Nullable(String)    COMMENT 'Mã cột hiển thị trên biểu mẫu — từ Financial Report Catalog Dimension.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), public_company_dim_id, financial_rpt_catalog_dim_id)
COMMENT 'Flat table — Fact Public Company Financial Report Value × Calendar Date × Public Company Dimension × Financial Report Catalog Dimension'
;

-- ---------------------------------------------------------------------
-- 8. Public Company Regulatory Compliance Report (Fact-report, Nhóm 38 — không FK Dimension)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_public_company_regulatory_compliance_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: PUBLIC COMPANY REGULATORY COMPLIANCE REPORT
    equity_listing_exchange_code   String              COMMENT 'Sàn niêm yết/đăng ký giao dịch — grain key của báo cáo.',
    rpt_year                        Int64               COMMENT 'Năm báo cáo — grain key theo kỳ.',
    rpt_quarter                     Nullable(Int64)     COMMENT 'Quý báo cáo — grain key theo kỳ.',
    company_count                   Nullable(Int64)     COMMENT 'Số lượng DN đăng ký theo sàn.',
    rpt_due_count                   Nullable(Int64)     COMMENT 'Số lượng BCTC đến hạn nộp trong kỳ theo sàn.',
    rpt_submitted_count             Nullable(Int64)     COMMENT 'Số báo cáo (BCTC) đã nộp trong kỳ theo sàn.',
    profitable_company_count_year_n  Nullable(Int64)     COMMENT 'Số CTĐC báo lãi Năm N theo sàn.',
    profitable_company_count_year_n1 Nullable(Int64)     COMMENT 'Số CTĐC báo lãi Năm N-1 theo sàn.',
    src_stm_code                    String              COMMENT 'Mã hệ thống nguồn dữ liệu.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(toDate(concat(toString(rpt_year), '-01-01')))
ORDER BY (rpt_year, equity_listing_exchange_code)
COMMENT 'Flat table — Public Company Regulatory Compliance Report (Fact-report, no FK Dimension)'
;

-- ---------------------------------------------------------------------
-- 9. Public Company Industry Financial Report (Fact-report, Nhóm 39 — không FK Dimension)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_public_company_industry_financial_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: PUBLIC COMPANY INDUSTRY FINANCIAL REPORT
    business_line_level_1_code     String              COMMENT 'Mã ngành cấp 1 — grain key của báo cáo.',
    business_line_level_1_name     Nullable(String)    COMMENT 'Tên ngành cấp 1 — denormalize theo tên hiệu lực tại thời điểm chạy ETL.',
    rpt_year                        Int64               COMMENT 'Năm báo cáo (Năm N) — grain key.',
    net_revenue_amt_year_n           Nullable(Decimal(23,2)) COMMENT 'Doanh thu thuần Năm N theo ngành.',
    net_profit_amt_year_n            Nullable(Decimal(23,2)) COMMENT 'Lợi nhuận sau thuế Năm N theo ngành.',
    roa_percentage_year_n            Nullable(Decimal(9,4))  COMMENT 'ROA Năm N theo ngành.',
    roe_percentage_year_n            Nullable(Decimal(9,4))  COMMENT 'ROE Năm N theo ngành.',
    net_revenue_amt_year_n1          Nullable(Decimal(23,2)) COMMENT 'Doanh thu thuần Năm N-1 theo ngành.',
    net_profit_amt_year_n1           Nullable(Decimal(23,2)) COMMENT 'Lợi nhuận sau thuế Năm N-1 theo ngành.',
    roa_percentage_year_n1           Nullable(Decimal(9,4))  COMMENT 'ROA Năm N-1 theo ngành.',
    roe_percentage_year_n1           Nullable(Decimal(9,4))  COMMENT 'ROE Năm N-1 theo ngành.',
    src_stm_code                     String              COMMENT 'Mã hệ thống nguồn dữ liệu.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(toDate(concat(toString(rpt_year), '-01-01')))
ORDER BY (rpt_year, business_line_level_1_code)
COMMENT 'Flat table — Public Company Industry Financial Report (Fact-report, no FK Dimension)'
;

-- ---------------------------------------------------------------------
-- 10. Public Company Multi-Period Financial Report (Fact-report, Nhóm 40 — không FK Dimension)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_public_company_multi_period_financial_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: PUBLIC COMPANY MULTI-PERIOD FINANCIAL REPORT
    rpt_year                          Int64               COMMENT 'Năm báo cáo (Năm N) — PK duy nhất của báo cáo, toàn thị trường không group-by.',
    total_asset_amt_year_n              Nullable(Decimal(23,2)) COMMENT 'Tổng tài sản Năm N toàn thị trường.',
    total_liability_amt_year_n          Nullable(Decimal(23,2)) COMMENT 'Nợ phải trả Năm N toàn thị trường.',
    equity_amt_year_n                   Nullable(Decimal(23,2)) COMMENT 'Vốn chủ sở hữu Năm N toàn thị trường.',
    charter_capital_amt_year_n          Nullable(Decimal(23,2)) COMMENT 'Vốn điều lệ Năm N toàn thị trường.',
    net_profit_amt_year_n               Nullable(Decimal(23,2)) COMMENT 'LNST Năm N toàn thị trường.',
    roa_percentage_year_n               Nullable(Decimal(9,4))  COMMENT 'ROA Năm N toàn thị trường.',
    roe_percentage_year_n               Nullable(Decimal(9,4))  COMMENT 'ROE Năm N toàn thị trường.',
    total_asset_amt_year_n1             Nullable(Decimal(23,2)) COMMENT 'Tổng tài sản Năm N-1 toàn thị trường.',
    total_liability_amt_year_n1         Nullable(Decimal(23,2)) COMMENT 'Nợ phải trả Năm N-1 toàn thị trường.',
    equity_amt_year_n1                  Nullable(Decimal(23,2)) COMMENT 'Vốn chủ sở hữu Năm N-1 toàn thị trường.',
    charter_capital_amt_year_n1         Nullable(Decimal(23,2)) COMMENT 'Vốn điều lệ Năm N-1 toàn thị trường.',
    net_profit_amt_year_n1              Nullable(Decimal(23,2)) COMMENT 'LNST Năm N-1 toàn thị trường.',
    roa_percentage_year_n1              Nullable(Decimal(9,4))  COMMENT 'ROA Năm N-1 toàn thị trường.',
    roe_percentage_year_n1              Nullable(Decimal(9,4))  COMMENT 'ROE Năm N-1 toàn thị trường.',
    total_asset_amt_year_n2             Nullable(Decimal(23,2)) COMMENT 'Tổng tài sản Năm N-2 toàn thị trường.',
    total_liability_amt_year_n2         Nullable(Decimal(23,2)) COMMENT 'Nợ phải trả Năm N-2 toàn thị trường.',
    equity_amt_year_n2                  Nullable(Decimal(23,2)) COMMENT 'Vốn chủ sở hữu Năm N-2 toàn thị trường.',
    charter_capital_amt_year_n2         Nullable(Decimal(23,2)) COMMENT 'Vốn điều lệ Năm N-2 toàn thị trường.',
    net_profit_amt_year_n2              Nullable(Decimal(23,2)) COMMENT 'LNST Năm N-2 toàn thị trường.',
    roa_percentage_year_n2              Nullable(Decimal(9,4))  COMMENT 'ROA Năm N-2 toàn thị trường.',
    roe_percentage_year_n2              Nullable(Decimal(9,4))  COMMENT 'ROE Năm N-2 toàn thị trường.',
    src_stm_code                        String              COMMENT 'Mã hệ thống nguồn dữ liệu.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(toDate(concat(toString(rpt_year), '-01-01')))
ORDER BY (rpt_year)
COMMENT 'Flat table — Public Company Multi-Period Financial Report (Fact-report, no FK Dimension, single-row-per-year grain)'
;

-- ---------------------------------------------------------------------
-- 11. Public Company Exchange Financial Summary Report (Fact-report, Nhóm 41 — không FK Dimension)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_public_company_exchange_financial_summary_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: PUBLIC COMPANY EXCHANGE FINANCIAL SUMMARY REPORT
    equity_listing_exchange_code        String              COMMENT 'Sàn niêm yết/đăng ký giao dịch — grain key của báo cáo.',
    rpt_year                             Int64               COMMENT 'Năm báo cáo — grain key theo kỳ.',
    rpt_quarter                          Nullable(Int64)     COMMENT 'Quý báo cáo — grain key theo kỳ.',
    total_asset_amt                      Nullable(Decimal(23,2)) COMMENT 'Tổng tài sản theo sàn.',
    total_asset_yoy_percentage           Nullable(Decimal(9,4))  COMMENT 'Tổng tài sản — YoY theo sàn.',
    inventory_amt                        Nullable(Decimal(23,2)) COMMENT 'Hàng tồn kho theo sàn.',
    inventory_yoy_percentage             Nullable(Decimal(9,4))  COMMENT 'Hàng tồn kho — YoY theo sàn.',
    total_liability_amt                  Nullable(Decimal(23,2)) COMMENT 'Nợ phải trả theo sàn.',
    total_liability_yoy_percentage       Nullable(Decimal(9,4))  COMMENT 'Nợ phải trả — YoY theo sàn.',
    equity_amt                           Nullable(Decimal(23,2)) COMMENT 'Vốn chủ sở hữu theo sàn.',
    equity_yoy_percentage                Nullable(Decimal(9,4))  COMMENT 'Vốn chủ sở hữu — YoY theo sàn.',
    contributed_capital_amt              Nullable(Decimal(23,2)) COMMENT 'Vốn góp của chủ sở hữu theo sàn.',
    contributed_capital_yoy_percentage   Nullable(Decimal(9,4))  COMMENT 'Vốn góp của chủ sở hữu — YoY theo sàn.',
    undistributed_profit_amt             Nullable(Decimal(23,2)) COMMENT 'LNST chưa phân phối theo sàn.',
    undistributed_profit_yoy_percentage  Nullable(Decimal(9,4))  COMMENT 'LNST chưa phân phối — YoY theo sàn.',
    net_revenue_amt                      Nullable(Decimal(23,2)) COMMENT 'Doanh thu thuần theo sàn.',
    net_revenue_yoy_percentage           Nullable(Decimal(9,4))  COMMENT 'Doanh thu thuần — YoY theo sàn.',
    pre_tax_profit_amt                   Nullable(Decimal(23,2)) COMMENT 'LNKT trước thuế theo sàn.',
    pre_tax_profit_yoy_percentage        Nullable(Decimal(9,4))  COMMENT 'LNKT trước thuế — YoY theo sàn.',
    net_profit_amt                       Nullable(Decimal(23,2)) COMMENT 'LNST theo sàn.',
    net_profit_yoy_percentage            Nullable(Decimal(9,4))  COMMENT 'LNST — YoY theo sàn.',
    roa_percentage                       Nullable(Decimal(9,4))  COMMENT 'ROA theo sàn.',
    roa_yoy_difference                   Nullable(Decimal(9,4))  COMMENT 'ROA — YoY theo sàn (hiệu số percentage point).',
    roe_percentage                       Nullable(Decimal(9,4))  COMMENT 'ROE theo sàn.',
    roe_yoy_difference                   Nullable(Decimal(9,4))  COMMENT 'ROE — YoY theo sàn (hiệu số percentage point).',
    src_stm_code                         String              COMMENT 'Mã hệ thống nguồn dữ liệu.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(toDate(concat(toString(rpt_year), '-01-01')))
ORDER BY (rpt_year, equity_listing_exchange_code)
COMMENT 'Flat table — Public Company Exchange Financial Summary Report (Fact-report, no FK Dimension)'
;
