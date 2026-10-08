-- =====================================================================
-- GSDC — Flat Tables (CREATE)
-- 19 bảng: 5 Evaluation Snapshot + Financial Report Value + Violation Report
--          Snapshot + Financial Summary + 3 Listing (Listed Share/Foreign Holding/State Capital)
--          + 6 Fact-report (Nhóm 38-41, không FK Dimension) + 2 Dimension flat (1-1, theo code dev — O_GSDC_35)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Fact Public Company Risk Evaluation Snapshot
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_public_company_risk_evaluation_snpst_flat ON CLUSTER 'my_cluster'
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
    credit_rating_assessment          Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `credit_rating_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `evaluation_r',
    credit_rating_tp_code             Nullable(String)        COMMENT 'Xếp loại doanh nghiệp A/B/C/D (A>90, B>80, C>70, D còn lại — theo tổng điểm) — carry-forward từ kỳ đánh giá gần nhất.',

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
COMMENT 'Flat table — Fact Public Company Risk Evaluation Snapshot × Calendar Date × Public Company Dimension'
;

-- ---------------------------------------------------------------------
-- 2. Fact Public Company Compliance Evaluation Snapshot
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_public_company_compliance_evaluation_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT PUBLIC COMPANY COMPLIANCE SCORE SNAPSHOT
    public_company_dim_id      String              COMMENT 'FK sang Public Company Dimension (surrogate key, full-scan toàn bộ CTĐC mỗi ngày ETL).',
    snpst_dt_dim_id             String              COMMENT 'FK tới Calendar Date Dimension — ngày chạy ETL (snapshot date).',
    evaluation_dt_dim_id        Nullable(String)    COMMENT 'FK tới Calendar Date Dimension — carry-forward: ngày kỳ đánh giá gần nhất.',
    evaluation_year             Nullable(String)    COMMENT 'Năm của kỳ đánh giá gần nhất được carry-forward.',
    evaluation_month            Nullable(String)    COMMENT 'Tháng của kỳ đánh giá gần nhất được carry-forward.',
    disclosure_bctc_score        Nullable(Int64)     COMMENT 'Công bố BCTC.',
    disclosure_bctc_assessment        Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `disclosure_bctc_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `evaluation',
    disclosure_bctn_score        Nullable(Int64)     COMMENT 'Công bố BCTN.',
    disclosure_bctn_assessment        Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `disclosure_bctn_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `evaluation',
    disclosure_governance_report_score Nullable(Int64) COMMENT 'Công bố báo cáo tình hình quản trị.',
    disclosure_governance_report_assessment Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `disclosure_governance_report_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nố',
    disclosure_ceo_change_score  Nullable(Int64)     COMMENT 'Công bố thông tin Thay đổi TGĐ/CTHĐQT.',
    disclosure_ceo_change_assessment  Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `disclosure_ceo_change_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `eval',
    violation_ubck_score         Nullable(Int64)     COMMENT 'Vi phạm từ UBCKNN.',
    violation_ubck_assessment         Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `violation_ubck_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `evaluation_',
    violation_other_score        Nullable(Int64)     COMMENT 'Vi phạm từ các đơn vị khác.',
    violation_other_assessment        Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `violation_other_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `evaluation',
    charter_regulation_score     Nullable(Int64)     COMMENT 'Điều lệ Công ty và Các Quy chế hoạt động.',
    charter_regulation_assessment     Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `charter_regulation_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `evaluat',
    annual_meeting_count_score   Nullable(Int64)     COMMENT 'Số lượng ĐHĐCĐ thường niên trong 6 tháng đầu năm.',
    annual_meeting_count_assessment   Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `annual_meeting_count_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `evalu',
    independent_board_member_count_score Nullable(Int64) COMMENT 'Số lượng thành viên HĐQT độc lập.',
    independent_board_member_count_assessment Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `independent_board_member_count_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, ',
    non_executive_board_member_count_score Nullable(Int64) COMMENT 'Số lượng thành viên HĐQT không điều hành.',
    non_executive_board_member_count_assessment Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `non_executive_board_member_count_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro',
    board_member_qualification_score Nullable(Int64) COMMENT 'Tư cách thành viên HĐQT/BKS/Kế toán trưởng.',
    board_member_qualification_assessment Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `board_member_qualification_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối ',
    supervisory_board_count_score Nullable(Int64)    COMMENT 'Số lượng thành viên BKS hoặc Ủy ban kiểm toán.',
    supervisory_board_count_assessment Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `supervisory_board_count_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `ev',
    capital_use_progress_report_score Nullable(Int64) COMMENT 'Báo cáo tiến độ sử dụng vốn.',
    capital_use_progress_report_assessment Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `capital_use_progress_report_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối',
    capital_use_plan_change_score Nullable(Int64)    COMMENT 'Thay đổi phương án sử dụng vốn.',
    capital_use_plan_change_assessment Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `capital_use_plan_change_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `ev',
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
COMMENT 'Flat table — Fact Public Company Compliance Evaluation Snapshot × Calendar Date × Public Company Dimension'
;

-- ---------------------------------------------------------------------
-- 3. Fact Public Company Issuance Evaluation Snapshot
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_public_company_issuance_evaluation_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT PUBLIC COMPANY ISSUANCE SCORE SNAPSHOT
    public_company_dim_id      String              COMMENT 'FK sang Public Company Dimension (surrogate key, full-scan toàn bộ CTĐC mỗi ngày ETL).',
    snpst_dt_dim_id             String              COMMENT 'FK tới Calendar Date Dimension — ngày chạy ETL (snapshot date).',
    evaluation_dt_dim_id        Nullable(String)    COMMENT 'FK tới Calendar Date Dimension — carry-forward: ngày kỳ đánh giá gần nhất.',
    evaluation_year             Nullable(String)    COMMENT 'Năm của kỳ đánh giá gần nhất được carry-forward.',
    evaluation_month            Nullable(String)    COMMENT 'Tháng của kỳ đánh giá gần nhất được carry-forward.',
    rapid_capital_increase_score Nullable(Int64)    COMMENT 'Phát hành tăng vốn nhanh.',
    rapid_capital_increase_assessment Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `rapid_capital_increase_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `eva',
    private_placement_count_score Nullable(Int64)   COMMENT 'Số lần chào bán cổ phiếu riêng lẻ.',
    private_placement_count_assessment Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `private_placement_count_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `ev',
    public_offering_count_score  Nullable(Int64)     COMMENT 'Số lần chào bán ra công chúng.',
    public_offering_count_assessment  Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `public_offering_count_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `eval',
    esop_issuance_count_score    Nullable(Int64)     COMMENT 'Số lần phát hành ESOP.',
    esop_issuance_count_assessment    Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `esop_issuance_count_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `evalua',
    unsecured_bond_ratio_score   Nullable(Int64)     COMMENT 'Tỷ lệ phát hành trái phiếu không có TSBĐ.',
    unsecured_bond_ratio_assessment   Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `unsecured_bond_ratio_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `evalu',
    credit_rating_score_issuance Nullable(Int64)    COMMENT 'Xếp hạng tín nhiệm.',
    credit_rating_issuance_assessment Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `credit_rating_score_issuance` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `eva',
    bond_debt_to_equity_score    Nullable(Int64)     COMMENT 'Dư nợ trái phiếu / Tổng VCSH.',
    bond_debt_to_equity_assessment    Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `bond_debt_to_equity_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `evalua',
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
COMMENT 'Flat table — Fact Public Company Issuance Evaluation Snapshot × Calendar Date × Public Company Dimension'
;

-- ---------------------------------------------------------------------
-- 4. Fact Public Company Financial Evaluation Snapshot
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_public_company_financial_evaluation_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT PUBLIC COMPANY FINANCIAL SCORE SNAPSHOT
    public_company_dim_id      String              COMMENT 'FK sang Public Company Dimension (surrogate key, full-scan toàn bộ CTĐC mỗi ngày ETL).',
    snpst_dt_dim_id             String              COMMENT 'FK tới Calendar Date Dimension — ngày chạy ETL (snapshot date).',
    evaluation_dt_dim_id        Nullable(String)    COMMENT 'FK tới Calendar Date Dimension — carry-forward: ngày kỳ đánh giá gần nhất.',
    evaluation_year             Nullable(String)    COMMENT 'Năm của kỳ đánh giá gần nhất được carry-forward.',
    evaluation_month            Nullable(String)    COMMENT 'Tháng của kỳ đánh giá gần nhất được carry-forward.',
    audit_opinion_score          Nullable(Int64)     COMMENT 'Kiểm toán — Ý kiến kiểm toán.',
    audit_opinion_assessment          Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `audit_opinion_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `evaluation_r',
    roa_score                    Nullable(Int64)     COMMENT 'ROA.',
    roa_assessment                    Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `roa_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `evaluation_result_text',
    operating_cash_flow_score    Nullable(Int64)     COMMENT 'Dòng tiền từ hoạt động kinh doanh.',
    operating_cash_flow_assessment    Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `operating_cash_flow_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `evalua',
    current_ratio_score          Nullable(Int64)     COMMENT 'Khả năng thanh toán hiện thời.',
    current_ratio_assessment          Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `current_ratio_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `evaluation_r',
    ebit_interest_coverage_score Nullable(Int64)     COMMENT 'EBIT / Lãi vay.',
    ebit_interest_coverage_assessment Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `ebit_interest_coverage_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `eva',
    debt_to_equity_score         Nullable(Int64)     COMMENT 'Nợ / VCSH.',
    debt_to_equity_assessment         Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `debt_to_equity_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `evaluation_',
    equity_score                 Nullable(Int64)     COMMENT 'VCSH.',
    equity_assessment                 Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `equity_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `evaluation_result_t',
    roe_score                    Nullable(Int64)     COMMENT 'ROE.',
    roe_assessment                    Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `roe_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `evaluation_result_text',
    financial_revenue_to_profit_score Nullable(Int64) COMMENT 'Doanh thu từ HĐ tài chính / Lợi nhuận sau thuế.',
    financial_revenue_to_profit_assessment Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `financial_revenue_to_profit_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối',
    other_revenue_to_profit_score Nullable(Int64)    COMMENT 'Doanh thu từ hoạt động khác / Lợi nhuận sau thuế.',
    other_revenue_to_profit_assessment Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `other_revenue_to_profit_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `ev',
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
COMMENT 'Flat table — Fact Public Company Financial Evaluation Snapshot × Calendar Date × Public Company Dimension'
;

-- ---------------------------------------------------------------------
-- 5. Fact Public Company Non-Financial Evaluation Snapshot
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_public_company_nonfinancial_evaluation_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT PUBLIC COMPANY NON-FINANCIAL SCORE SNAPSHOT
    public_company_dim_id      String              COMMENT 'FK sang Public Company Dimension (surrogate key, full-scan toàn bộ CTĐC mỗi ngày ETL).',
    snpst_dt_dim_id             String              COMMENT 'FK tới Calendar Date Dimension — ngày chạy ETL (snapshot date).',
    evaluation_dt_dim_id        Nullable(String)    COMMENT 'FK tới Calendar Date Dimension — carry-forward: ngày kỳ đánh giá gần nhất.',
    evaluation_year             Nullable(String)    COMMENT 'Năm của kỳ đánh giá gần nhất được carry-forward.',
    evaluation_month            Nullable(String)    COMMENT 'Tháng của kỳ đánh giá gần nhất được carry-forward.',
    business_registration_status_score Nullable(Int64) COMMENT 'Tình trạng DN từ Cục Đăng ký kinh doanh.',
    business_registration_status_assessment Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `business_registration_status_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nố',
    m_score                       Nullable(Int64)     COMMENT 'M-Score.',
    m_score_assessment                Nullable(String)        COMMENT 'Nhận xét/đánh giá dạng text đi cặp với `m_score` — định dạng `<mức đánh giá>: <kết quả định tính>` (`cl_nm` của `evaluation_level_code`, scheme IDS.EVALUATION_LEVEL: 1-Bình thường/2-Cảnh báo/3-Rủi ro, nối `evaluation_result_text`)',
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
COMMENT 'Flat table — Fact Public Company Non-Financial Evaluation Snapshot × Calendar Date × Public Company Dimension'
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
    industry_dim_id                 Nullable(String)    COMMENT 'FK sang Industry Dimension — ngành kinh tế của công ty đại chúng phát sinh dòng báo cáo này.',
    rpt_year                       Int64               COMMENT 'Năm báo cáo tài chính — 1 phần grain key.',
    rpt_quarter                    Nullable(Int64)     COMMENT 'Quý báo cáo tài chính — 1 phần grain key.',
    row_code                       String              COMMENT 'Mã kỹ thuật dòng — 1 phần grain key.',
    column_code                    String              COMMENT 'Mã kỹ thuật cột — 1 phần grain key.',
    data_val                       Nullable(Decimal(38,8)) COMMENT 'Giá trị dữ liệu tại ô báo cáo (Row Code × Column Code).',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                   Nullable(Date)      COMMENT 'Ngày snapshot ETL — từ Calendar Date Dimension.',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code               String              COMMENT 'Khóa nghiệp vụ — Mã CTĐC — từ Public Company Dimension.',
    equity_ticker_symbol               Nullable(String)    COMMENT 'Mã cổ phiếu — từ Public Company Dimension.',
    public_company_nm                  Nullable(String)    COMMENT 'Tên công ty (tiếng Việt) — từ Public Company Dimension.',
    equity_listing_exchange_code       Nullable(String)    COMMENT 'Sàn niêm yết — từ Public Company Dimension.',
    ids_registration_dt                Nullable(Date)      COMMENT 'Ngày đăng ký IDS — từ Public Company Dimension.',
    public_company_status_code         Nullable(String)    COMMENT 'Trạng thái công ty — từ Public Company Dimension.',
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
    business_line_level_1_code         Nullable(String)    COMMENT 'Mã ngành cấp 1 — từ Industry Dimension.',
    classification_business_line_nm    Nullable(String)    COMMENT 'Tên ngành cấp 1 — từ Industry Dimension.',

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
    company_due_count                   Nullable(Int64)     COMMENT 'Số lượng BCTC đến hạn nộp trong kỳ theo sàn.',
    company_submitted_count             Nullable(Int64)     COMMENT 'Số báo cáo (BCTC) đã nộp trong kỳ theo sàn.',
    profitable_company_count_year  Nullable(Int64)     COMMENT 'Số CTĐC báo lãi Năm N theo sàn.',
    profitable_company_count_ytd      Nullable(Int64)         COMMENT 'Số CTĐC báo lãi TÍNH TỪ ĐẦU NĂM (LNST lũy kế `net_profit_ytd` > 0) theo sàn — tập con của công ty đã nộp.',
    large_scale_company_count         Nullable(Int64)         COMMENT 'Số công ty quy mô lớn (UPCOM/OTC, vốn góp ≥ 120 tỷ) theo sàn.',
    src_stm_code                    String              COMMENT 'Mã hệ thống nguồn dữ liệu.',
    rpt_dt                           String              COMMENT 'Ngày chạy ETL populate bảng (format yyyyMMdd) — audit column, không thuộc grain/PK.'
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
    rpt_quarter                       Int64                   COMMENT 'Quý báo cáo — grain đổi từ năm sang năm + quý.',
    net_revenue_amt_year_n           Nullable(Decimal(38,8)) COMMENT 'Doanh thu thuần Năm N theo ngành.',
    net_profit_amt_year_n            Nullable(Decimal(38,8)) COMMENT 'Lợi nhuận sau thuế Năm N theo ngành.',
    roa_percentage_year_n            Nullable(Decimal(30,6))  COMMENT 'ROA Năm N theo ngành.',
    roe_percentage_year_n            Nullable(Decimal(30,6))  COMMENT 'ROE Năm N theo ngành.',
    net_revenue_amt_year_n1          Nullable(Decimal(38,8)) COMMENT 'Doanh thu thuần Năm N-1 theo ngành.',
    net_profit_amt_year_n1           Nullable(Decimal(38,8)) COMMENT 'Lợi nhuận sau thuế Năm N-1 theo ngành.',
    roa_percentage_year_n1           Nullable(Decimal(30,6))  COMMENT 'ROA Năm N-1 theo ngành.',
    roe_percentage_year_n1           Nullable(Decimal(30,6))  COMMENT 'ROE Năm N-1 theo ngành.',
    total_asset_amt_year_n            Nullable(Decimal(38,8)) COMMENT 'Total Asset năm N theo ngành.',
    total_liability_amt_year_n        Nullable(Decimal(38,8)) COMMENT 'Total Liability năm N theo ngành.',
    equity_amt_year_n                 Nullable(Decimal(38,8)) COMMENT 'Equity năm N theo ngành.',
    contributed_capital_amt_year_n    Nullable(Decimal(38,8)) COMMENT 'Contributed Capital năm N theo ngành.',
    pre_tax_profit_amt_year_n         Nullable(Decimal(38,8)) COMMENT 'Pre Tax Profit năm N theo ngành.',
    pre_tax_profit_ytd_amt_year_n     Nullable(Decimal(38,8)) COMMENT 'Pre Tax Profit YTD năm N theo ngành.',
    inventory_amt_year_n              Nullable(Decimal(38,8)) COMMENT 'Inventory năm N theo ngành.',
    undistributed_profit_amt_year_n   Nullable(Decimal(38,8)) COMMENT 'Undistributed Profit năm N theo ngành.',
    receivable_amt_year_n             Nullable(Decimal(38,8)) COMMENT 'Receivable năm N theo ngành.',
    cash_and_equivalent_amt_year_n    Nullable(Decimal(38,8)) COMMENT 'Cash And Equivalent năm N theo ngành.',
    debt_to_equity_year_n             Nullable(Decimal(30,6)) COMMENT 'Nợ phải trả / Vốn chủ sở hữu năm N theo ngành.',
    net_revenue_ytd_amt_year_n        Nullable(Decimal(38,8)) COMMENT 'Net Revenue lũy kế từ đầu năm (year_n) theo ngành.',
    net_profit_ytd_amt_year_n         Nullable(Decimal(38,8)) COMMENT 'Net Profit lũy kế từ đầu năm (year_n) theo ngành.',
    roa_ytd_percentage_year_n         Nullable(Decimal(30,6)) COMMENT 'ROA theo LNST lũy kế (year_n) theo ngành.',
    roe_ytd_percentage_year_n         Nullable(Decimal(30,6)) COMMENT 'ROE theo LNST lũy kế (year_n) theo ngành.',
    net_revenue_ytd_amt_year_n1       Nullable(Decimal(38,8)) COMMENT 'Net Revenue lũy kế từ đầu năm (year_n1) theo ngành.',
    net_profit_ytd_amt_year_n1        Nullable(Decimal(38,8)) COMMENT 'Net Profit lũy kế từ đầu năm (year_n1) theo ngành.',
    roa_ytd_percentage_year_n1        Nullable(Decimal(30,6)) COMMENT 'ROA theo LNST lũy kế (year_n1) theo ngành.',
    roe_ytd_percentage_year_n1        Nullable(Decimal(30,6)) COMMENT 'ROE theo LNST lũy kế (year_n1) theo ngành.',
    src_stm_code                     String              COMMENT 'Mã hệ thống nguồn dữ liệu.',
    rpt_dt                           String              COMMENT 'Ngày chạy ETL populate bảng (format yyyyMMdd) — audit column, không thuộc grain/PK.'
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
    rpt_quarter                       Int64                   COMMENT 'Quý báo cáo — grain đổi sang năm + quý.',
    total_asset_amt_year_n              Nullable(Decimal(38,8)) COMMENT 'Tổng tài sản Năm N toàn thị trường.',
    total_liability_amt_year_n          Nullable(Decimal(38,8)) COMMENT 'Nợ phải trả Năm N toàn thị trường.',
    equity_amt_year_n                   Nullable(Decimal(38,8)) COMMENT 'Vốn chủ sở hữu Năm N toàn thị trường.',
    charter_capital_amt_year_n          Nullable(Decimal(38,8)) COMMENT 'Vốn điều lệ Năm N toàn thị trường.',
    net_profit_amt_year_n               Nullable(Decimal(38,8)) COMMENT 'LNST Năm N toàn thị trường.',
    roa_percentage_year_n               Nullable(Decimal(30,6))  COMMENT 'ROA Năm N toàn thị trường.',
    roe_percentage_year_n               Nullable(Decimal(30,6))  COMMENT 'ROE Năm N toàn thị trường.',
    total_asset_amt_year_n1             Nullable(Decimal(38,8)) COMMENT 'Tổng tài sản Năm N-1 toàn thị trường.',
    total_liability_amt_year_n1         Nullable(Decimal(38,8)) COMMENT 'Nợ phải trả Năm N-1 toàn thị trường.',
    equity_amt_year_n1                  Nullable(Decimal(38,8)) COMMENT 'Vốn chủ sở hữu Năm N-1 toàn thị trường.',
    charter_capital_amt_year_n1         Nullable(Decimal(38,8)) COMMENT 'Vốn điều lệ Năm N-1 toàn thị trường.',
    net_profit_amt_year_n1              Nullable(Decimal(38,8)) COMMENT 'LNST Năm N-1 toàn thị trường.',
    roa_percentage_year_n1              Nullable(Decimal(30,6))  COMMENT 'ROA Năm N-1 toàn thị trường.',
    roe_percentage_year_n1              Nullable(Decimal(30,6))  COMMENT 'ROE Năm N-1 toàn thị trường.',
    total_asset_amt_year_n2             Nullable(Decimal(38,8)) COMMENT 'Tổng tài sản Năm N-2 toàn thị trường.',
    total_liability_amt_year_n2         Nullable(Decimal(38,8)) COMMENT 'Nợ phải trả Năm N-2 toàn thị trường.',
    equity_amt_year_n2                  Nullable(Decimal(38,8)) COMMENT 'Vốn chủ sở hữu Năm N-2 toàn thị trường.',
    charter_capital_amt_year_n2         Nullable(Decimal(38,8)) COMMENT 'Vốn điều lệ Năm N-2 toàn thị trường.',
    net_profit_amt_year_n2              Nullable(Decimal(38,8)) COMMENT 'LNST Năm N-2 toàn thị trường.',
    roa_percentage_year_n2              Nullable(Decimal(30,6))  COMMENT 'ROA Năm N-2 toàn thị trường.',
    roe_percentage_year_n2              Nullable(Decimal(30,6))  COMMENT 'ROE Năm N-2 toàn thị trường.',
    net_profit_ytd_amt_year_n         Nullable(Decimal(38,8)) COMMENT 'LNST lũy kế (year_n).',
    roa_ytd_percentage_year_n         Nullable(Decimal(30,6)) COMMENT 'ROA theo LNST lũy kế (year_n).',
    roe_ytd_percentage_year_n         Nullable(Decimal(30,6)) COMMENT 'ROE theo LNST lũy kế (year_n).',
    net_profit_ytd_amt_year_n1        Nullable(Decimal(38,8)) COMMENT 'LNST lũy kế (year_n1).',
    roa_ytd_percentage_year_n1        Nullable(Decimal(30,6)) COMMENT 'ROA theo LNST lũy kế (year_n1).',
    roe_ytd_percentage_year_n1        Nullable(Decimal(30,6)) COMMENT 'ROE theo LNST lũy kế (year_n1).',
    net_profit_ytd_amt_year_n2        Nullable(Decimal(38,8)) COMMENT 'LNST lũy kế (year_n2).',
    roa_ytd_percentage_year_n2        Nullable(Decimal(30,6)) COMMENT 'ROA theo LNST lũy kế (year_n2).',
    roe_ytd_percentage_year_n2        Nullable(Decimal(30,6)) COMMENT 'ROE theo LNST lũy kế (year_n2).',
    src_stm_code                        String              COMMENT 'Mã hệ thống nguồn dữ liệu.',
    rpt_dt                               String              COMMENT 'Ngày chạy ETL populate bảng (format yyyyMMdd) — audit column, không thuộc grain/PK.'
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
    total_asset_amt                      Nullable(Decimal(38,8)) COMMENT 'Tổng tài sản theo sàn.',
    total_asset_yoy           Nullable(Decimal(30,6))  COMMENT 'Tổng tài sản — YoY theo sàn.',
    inventory_amt                        Nullable(Decimal(38,8)) COMMENT 'Hàng tồn kho theo sàn.',
    inventory_yoy             Nullable(Decimal(30,6))  COMMENT 'Hàng tồn kho — YoY theo sàn.',
    total_liability_amt                  Nullable(Decimal(38,8)) COMMENT 'Nợ phải trả theo sàn.',
    total_liability_yoy       Nullable(Decimal(30,6))  COMMENT 'Nợ phải trả — YoY theo sàn.',
    equity_amt                           Nullable(Decimal(38,8)) COMMENT 'Vốn chủ sở hữu theo sàn.',
    equity_yoy                Nullable(Decimal(30,6))  COMMENT 'Vốn chủ sở hữu — YoY theo sàn.',
    contributed_capital_amt              Nullable(Decimal(38,8)) COMMENT 'Vốn góp của chủ sở hữu theo sàn.',
    contributed_capital_yoy   Nullable(Decimal(30,6))  COMMENT 'Vốn góp của chủ sở hữu — YoY theo sàn.',
    undistributed_profit_amt             Nullable(Decimal(38,8)) COMMENT 'LNST chưa phân phối theo sàn.',
    undistributed_profit_yoy  Nullable(Decimal(30,6))  COMMENT 'LNST chưa phân phối — YoY theo sàn.',
    net_revenue_amt                      Nullable(Decimal(38,8)) COMMENT 'Doanh thu thuần theo sàn.',
    net_revenue_yoy           Nullable(Decimal(30,6))  COMMENT 'Doanh thu thuần — YoY theo sàn.',
    pre_tax_profit_amt                   Nullable(Decimal(38,8)) COMMENT 'LNKT trước thuế theo sàn.',
    pre_tax_profit_yoy        Nullable(Decimal(30,6))  COMMENT 'LNKT trước thuế — YoY theo sàn.',
    net_profit_amt                       Nullable(Decimal(38,8)) COMMENT 'LNST theo sàn.',
    net_profit_yoy            Nullable(Decimal(30,6))  COMMENT 'LNST — YoY theo sàn.',
    roa_percentage                       Nullable(Decimal(30,6))  COMMENT 'ROA theo sàn.',
    roa_yoy_percentage                   Nullable(Decimal(30,6))  COMMENT 'ROA — YoY theo sàn (% tăng/giảm tương đối).',
    roe_percentage                       Nullable(Decimal(30,6))  COMMENT 'ROE theo sàn.',
    roe_yoy_percentage                   Nullable(Decimal(30,6))  COMMENT 'ROE — YoY theo sàn (% tăng/giảm tương đối).',
    receivable_amt                    Nullable(Decimal(38,8)) COMMENT 'Receivable theo sàn.',
    receivable_yoy                    Nullable(Decimal(30,6)) COMMENT 'Receivable — YoY %.',
    cash_and_equivalent_amt           Nullable(Decimal(38,8)) COMMENT 'Cash And Equivalent theo sàn.',
    cash_and_equivalent_yoy           Nullable(Decimal(30,6)) COMMENT 'Cash And Equivalent — YoY %.',
    debt_to_equity_percentage         Nullable(Decimal(30,6)) COMMENT 'Nợ phải trả / Vốn chủ sở hữu theo sàn.',
    debt_to_equity_yoy_percentage     Nullable(Decimal(30,6)) COMMENT 'Nợ/VCSH — YoY.',
    net_revenue_ytd_amt               Nullable(Decimal(38,8)) COMMENT 'Net Revenue lũy kế từ đầu năm theo sàn.',
    net_revenue_ytd_yoy               Nullable(Decimal(30,6)) COMMENT 'Net Revenue lũy kế — YoY.',
    pre_tax_profit_ytd_amt            Nullable(Decimal(38,8)) COMMENT 'Pre Tax Profit lũy kế từ đầu năm theo sàn.',
    pre_tax_profit_ytd_yoy            Nullable(Decimal(30,6)) COMMENT 'Pre Tax Profit lũy kế — YoY.',
    net_profit_ytd_amt                Nullable(Decimal(38,8)) COMMENT 'Net Profit lũy kế từ đầu năm theo sàn.',
    net_profit_ytd_yoy                Nullable(Decimal(30,6)) COMMENT 'Net Profit lũy kế — YoY.',
    roa_ytd_percentage                Nullable(Decimal(30,6)) COMMENT 'ROA theo LNST lũy kế, theo sàn.',
    roa_ytd_yoy_percentage            Nullable(Decimal(30,6)) COMMENT 'ROA lũy kế — YoY.',
    roe_ytd_percentage                Nullable(Decimal(30,6)) COMMENT 'ROE theo LNST lũy kế, theo sàn.',
    roe_ytd_yoy_percentage            Nullable(Decimal(30,6)) COMMENT 'ROE lũy kế — YoY.',
    total_asset_ytd_chg               Nullable(Decimal(30,6)) COMMENT 'Biến động `total_asset` so với đầu năm (YTD change) theo sàn — copy từ `public_company_financial_ytd_chg_rpt`.',
    total_liability_ytd_chg           Nullable(Decimal(30,6)) COMMENT 'Biến động `total_liability` so với đầu năm (YTD change) theo sàn — copy từ `public_company_financial_ytd_chg_rpt`.',
    equity_ytd_chg                    Nullable(Decimal(30,6)) COMMENT 'Biến động `equity` so với đầu năm (YTD change) theo sàn — copy từ `public_company_financial_ytd_chg_rpt`.',
    contributed_capital_ytd_chg       Nullable(Decimal(30,6)) COMMENT 'Biến động `contributed_capital` so với đầu năm (YTD change) theo sàn — copy từ `public_company_financial_ytd_chg_rpt`.',
    inventory_ytd_chg                 Nullable(Decimal(30,6)) COMMENT 'Biến động `inventory` so với đầu năm (YTD change) theo sàn — copy từ `public_company_financial_ytd_chg_rpt`.',
    undistributed_profit_ytd_chg      Nullable(Decimal(30,6)) COMMENT 'Biến động `undistributed_profit` so với đầu năm (YTD change) theo sàn — copy từ `public_company_financial_ytd_chg_rpt`.',
    receivable_ytd_chg                Nullable(Decimal(30,6)) COMMENT 'Biến động `receivable` so với đầu năm (YTD change) theo sàn — copy từ `public_company_financial_ytd_chg_rpt`.',
    cash_and_equivalent_ytd_chg       Nullable(Decimal(30,6)) COMMENT 'Biến động `cash_and_equivalent` so với đầu năm (YTD change) theo sàn — copy từ `public_company_financial_ytd_chg_rpt`.',
    debt_to_equity_ytd_chg            Nullable(Decimal(30,6)) COMMENT 'Biến động `debt_to_equity` so với đầu năm (YTD change) theo sàn — copy từ `public_company_financial_ytd_chg_rpt`.',
    src_stm_code                         String              COMMENT 'Mã hệ thống nguồn dữ liệu.',
    rpt_dt                               String              COMMENT 'Ngày chạy ETL populate bảng (format yyyyMMdd) — audit column, không thuộc grain/PK.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(toDate(concat(toString(rpt_year), '-01-01')))
ORDER BY (rpt_year, equity_listing_exchange_code)
COMMENT 'Flat table — Public Company Exchange Financial Summary Report (Fact-report, no FK Dimension)'
;

-- ---------------------------------------------------------------------
-- 12. Public Company Financial YoY Report (Fact-report, Nhóm 7/11/13/15/17 — không FK Dimension)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_public_company_financial_yoy_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: PUBLIC COMPANY FINANCIAL YOY REPORT
    equity_listing_exchange_code        String              COMMENT 'Sàn niêm yết/đăng ký giao dịch — grain key của báo cáo. Giá trị ALL đại diện toàn thị trường.',
    business_line_level_1_code        String                  COMMENT 'Mã ngành cấp 1 — grain key mới: báo cáo chuyển thành cross-tab sàn × ngành.',
    business_line_level_1_name        String                  COMMENT 'Tên ngành cấp 1 — grain key mới: báo cáo chuyển thành cross-tab sàn × ngành.',
    rpt_year                             Int64               COMMENT 'Năm báo cáo — grain key theo kỳ.',
    rpt_quarter                          Nullable(Int64)     COMMENT 'Quý báo cáo — grain key theo kỳ.',
    total_asset_yoy                      Nullable(Decimal(30,6)) COMMENT 'Tổng tài sản — YoY, % tăng/giảm so cùng kỳ năm trước.',
    total_liability_yoy                  Nullable(Decimal(30,6)) COMMENT 'Nợ phải trả — YoY, % tăng/giảm so cùng kỳ năm trước.',
    equity_yoy                           Nullable(Decimal(30,6)) COMMENT 'Vốn chủ sở hữu — YoY, % tăng/giảm so cùng kỳ năm trước.',
    contributed_capital_yoy              Nullable(Decimal(30,6)) COMMENT 'Vốn điều lệ — YoY, % tăng/giảm so cùng kỳ năm trước.',
    net_profit_yoy                       Nullable(Decimal(30,6)) COMMENT 'Lợi nhuận sau thuế — YoY, % tăng/giảm so cùng kỳ năm trước.',
    pre_tax_profit_yoy                Nullable(Decimal(30,6)) COMMENT 'Lợi nhuận kế toán trước thuế — YoY, % tăng/giảm tương đối so cùng kỳ năm trước.',
    inventory_yoy                        Nullable(Decimal(30,6)) COMMENT 'Hàng tồn kho — YoY, % tăng/giảm so cùng kỳ năm trước.',
    net_revenue_yoy                      Nullable(Decimal(30,6)) COMMENT 'Doanh thu thuần — YoY, % tăng/giảm so cùng kỳ năm trước.',
    undistributed_profit_yoy             Nullable(Decimal(30,6)) COMMENT 'Lợi nhuận dồn tích YTD — YoY, % tăng/giảm so cùng kỳ năm trước.',
    receivable_yoy                       Nullable(Decimal(30,6)) COMMENT 'Phải thu — YoY, % tăng/giảm so cùng kỳ năm trước.',
    cash_and_equivalent_yoy              Nullable(Decimal(30,6)) COMMENT 'Tiền và tương đương tiền — YoY, % tăng/giảm so cùng kỳ năm trước.',
    roa_yoy                              Nullable(Decimal(30,6)) COMMENT 'ROA — YoY, % tăng/giảm so cùng kỳ năm trước (áp dụng trên giá trị ROA đã tính của từng kỳ).',
    roe_yoy                              Nullable(Decimal(30,6)) COMMENT 'ROE — YoY, % tăng/giảm so cùng kỳ năm trước (áp dụng trên giá trị ROE đã tính của từng kỳ).',
    debt_to_equity_yoy                   Nullable(Decimal(30,6)) COMMENT 'Nợ / Vốn CSH — YoY, % tăng/giảm so cùng kỳ năm trước (áp dụng trên tỷ số Nợ/Vốn CSH đã tính của từng kỳ).',
    net_profit_ytd_yoy                Nullable(Decimal(30,6)) COMMENT 'Lợi nhuận sau thuế — theo chỉ tiêu lũy kế từ đầu năm (YTD).',
    pre_tax_profit_ytd_yoy            Nullable(Decimal(30,6)) COMMENT 'Lợi nhuận kế toán trước thuế — theo chỉ tiêu lũy kế từ đầu năm (YTD).',
    net_revenue_ytd_yoy               Nullable(Decimal(30,6)) COMMENT 'Doanh thu thuần — theo chỉ tiêu lũy kế từ đầu năm (YTD).',
    roa_ytd_yoy                       Nullable(Decimal(30,6)) COMMENT 'ROA — theo chỉ tiêu lũy kế từ đầu năm (YTD).',
    roe_ytd_yoy                       Nullable(Decimal(30,6)) COMMENT 'ROE — theo chỉ tiêu lũy kế từ đầu năm (YTD).',
    src_stm_code                         String              COMMENT 'Mã hệ thống nguồn dữ liệu tính toán báo cáo tổng hợp tài chính YoY.',
    rpt_dt                               String              COMMENT 'Ngày chạy ETL populate bảng (format yyyyMMdd) — audit column, không thuộc grain/PK.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(toDate(concat(toString(rpt_year), '-01-01')))
ORDER BY (rpt_year, equity_listing_exchange_code)
COMMENT 'Flat table — Public Company Financial YoY Report (Fact-report, no FK Dimension, phục vụ Nhóm 7/11/13/15/17)'
;

-- ---------------------------------------------------------------------
-- 13. Fact Public Company Financial Summary Snapshot (Nhóm 7 Khối A/8/11/13/15/17/37)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_public_company_financial_smy_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT PUBLIC COMPANY FINANCIAL SUMMARY SNAPSHOT
    public_company_dim_id        String              COMMENT 'FK sang Public Company Dimension (surrogate key) — công ty đại chúng phát sinh dòng báo cáo, grain key.',
    snpst_dt_dim_id                String              COMMENT 'FK tới Calendar Date Dimension — ngày chạy ETL (snapshot date).',
    industry_dim_id                 Nullable(String)    COMMENT 'FK sang Industry Dimension — ngành kinh tế cấp 1 của công ty đại chúng phát sinh dòng báo cáo này.',
    rpt_year                       Int64               COMMENT 'Năm báo cáo — grain key theo kỳ.',
    rpt_quarter                    Int64               COMMENT 'Quý báo cáo — grain key theo kỳ.',
    total_asset                    Nullable(Decimal(38,8)) COMMENT 'Tổng tài sản — giá trị tại kỳ báo cáo.',
    total_liability                Nullable(Decimal(38,8)) COMMENT 'Nợ phải trả — giá trị tại kỳ báo cáo.',
    equity                          Nullable(Decimal(38,8)) COMMENT 'Vốn chủ sở hữu — giá trị tại kỳ báo cáo.',
    contributed_capital             Nullable(Decimal(38,8)) COMMENT 'Vốn điều lệ — giá trị tại kỳ báo cáo.',
    net_profit                      Nullable(Decimal(38,8)) COMMENT 'Lợi nhuận sau thuế — giá trị tại kỳ báo cáo.',
    pre_tax_profit                  Nullable(Decimal(38,8)) COMMENT 'Lợi nhuận kế toán trước thuế — giá trị tại kỳ báo cáo.',
    total_asset_beginning           Nullable(Decimal(38,8)) COMMENT 'Tổng tài sản đầu kỳ — input tính ROA (TSBQ).',
    equity_beginning                 Nullable(Decimal(38,8)) COMMENT 'Vốn chủ sở hữu đầu kỳ — input tính ROE (VCSHBQ).',
    total_liability_beginning         Nullable(Decimal(38,8)) COMMENT '[SỬA 2026-09-14, dev report qua module GSTT — cùng bug tại nguồn rule GSĐC] Sửa khóa nối fr_row/fr_column — dùng row_code/column_code (mã nghiệp vụ) thay vì fr_row_template_code/fr_column_template_code (mã hash nội bộ khác miền gi',
    contributed_capital_beginning     Nullable(Decimal(38,8)) COMMENT '[SỬA 2026-09-14, dev report qua module GSTT — cùng bug tại nguồn rule GSĐC] Sửa khóa nối fr_row/fr_column — dùng row_code/column_code (mã nghiệp vụ) thay vì fr_row_template_code/fr_column_template_code (mã hash nội bộ khác miền gi',
    inventory_beginning               Nullable(Decimal(38,8)) COMMENT '[SỬA 2026-09-14, dev report qua module GSTT — cùng bug tại nguồn rule GSĐC] Sửa khóa nối fr_row/fr_column — dùng row_code/column_code (mã nghiệp vụ) thay vì fr_row_template_code/fr_column_template_code (mã hash nội bộ khác miền gi',
    undistributed_profit_beginning    Nullable(Decimal(38,8)) COMMENT '[SỬA 2026-09-14, dev report qua module GSTT — cùng bug tại nguồn rule GSĐC] Sửa khóa nối fr_row/fr_column — dùng row_code/column_code (mã nghiệp vụ) thay vì fr_row_template_code/fr_column_template_code (mã hash nội bộ khác miền gi',
    receivable_beginning              Nullable(Decimal(38,8)) COMMENT '[SỬA 2026-09-14, dev report qua module GSTT — cùng bug tại nguồn rule GSĐC] Sửa khóa nối fr_row/fr_column — dùng row_code/column_code (mã nghiệp vụ) thay vì fr_row_template_code/fr_column_template_code (mã hash nội bộ khác miền gi',
    cash_and_equivalent_beginning     Nullable(Decimal(38,8)) COMMENT '[SỬA 2026-09-14, dev report qua module GSTT — cùng bug tại nguồn rule GSĐC] Sửa khóa nối fr_row/fr_column — dùng row_code/column_code (mã nghiệp vụ) thay vì fr_row_template_code/fr_column_template_code (mã hash nội bộ khác miền gi',
    inventory                        Nullable(Decimal(38,8)) COMMENT 'Hàng tồn kho — giá trị tại kỳ báo cáo (DN/BH — TD không có chỉ tiêu này, luôn NULL).',
    net_revenue                      Nullable(Decimal(38,8)) COMMENT 'Doanh thu thuần — giá trị tại kỳ báo cáo.',
    undistributed_profit             Nullable(Decimal(38,8)) COMMENT 'Lợi nhuận sau thuế chưa phân phối lũy kế — giá trị tại kỳ báo cáo (DN/BH — TD không có chỉ tiêu này, luôn NULL).',
    receivable                       Nullable(Decimal(38,8)) COMMENT 'Phải thu — giá trị tại kỳ báo cáo.',
    cash_and_equivalent              Nullable(Decimal(38,8)) COMMENT 'Tiền và tương đương tiền — giá trị tại kỳ báo cáo.',
    roa                              Nullable(Decimal(30,6))  COMMENT 'ROA = LNST / bình quân (Tổng tài sản đầu kỳ, cuối kỳ) × 100.',
    roe                              Nullable(Decimal(30,6))  COMMENT 'ROE = LNST / bình quân (Vốn chủ sở hữu đầu kỳ, cuối kỳ) × 100.',
    debt_to_equity                   Nullable(Decimal(30,6))  COMMENT 'Tỷ lệ Nợ phải trả / Vốn chủ sở hữu.',
    debt_to_equity_beginning          Nullable(Decimal(30,6)) COMMENT 'Tỷ lệ Nợ phải trả / Vốn chủ sở hữu ĐẦU KỲ.',
    net_profit_ytd                    Nullable(Decimal(38,8)) COMMENT 'Lợi nhuận sau thuế lũy kế từ đầu năm (YTD).',
    net_revenue_ytd                   Nullable(Decimal(38,8)) COMMENT 'Doanh thu thuần lũy kế từ đầu năm (YTD).',
    pre_tax_profit_ytd                Nullable(Decimal(38,8)) COMMENT 'Lợi nhuận trước thuế lũy kế từ đầu năm (YTD).',
    roa_ytd                           Nullable(Decimal(30,6)) COMMENT 'ROA = LNST / bình quân (Tổng tài sản đầu kỳ, Tổng tài sản cuối kỳ) × 100. — theo LNST lũy kế (YTD).',
    roe_ytd                           Nullable(Decimal(30,6)) COMMENT 'ROE = LNST / bình quân (Vốn chủ sở hữu đầu kỳ, Vốn chủ sở hữu cuối kỳ) × 100. — theo LNST lũy kế (YTD).',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                   Nullable(Date)      COMMENT 'Ngày snapshot ETL — từ Calendar Date Dimension.',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code               String              COMMENT 'Khóa nghiệp vụ — Mã CTĐC — từ Public Company Dimension.',
    equity_ticker_symbol               Nullable(String)    COMMENT 'Mã cổ phiếu — từ Public Company Dimension.',
    public_company_nm                  Nullable(String)    COMMENT 'Tên công ty (tiếng Việt) — từ Public Company Dimension.',
    equity_listing_exchange_code       Nullable(String)    COMMENT 'Sàn niêm yết — từ Public Company Dimension.',
    ids_registration_dt                Nullable(Date)      COMMENT 'Ngày đăng ký IDS — từ Public Company Dimension.',
    public_company_status_code         Nullable(String)    COMMENT 'Trạng thái công ty — từ Public Company Dimension.',
    public_company_english_nm          Nullable(String)    COMMENT 'Tên công ty (tiếng Anh) — từ Public Company Dimension.',
    enterprise_tp_code                 Nullable(String)    COMMENT 'Loại hình doanh nghiệp — từ Public Company Dimension.',
    enterprise_tp_nm                   Nullable(String)    COMMENT 'Tên loại hình doanh nghiệp — từ Public Company Dimension.',
    public_company_tp_code             Nullable(String)    COMMENT 'Loại công ty đại chúng — từ Public Company Dimension.',
    head_office_province_nm            Nullable(String)    COMMENT 'Tỉnh/TP trụ sở chính — từ Public Company Dimension.',
    operating_status_code              Nullable(String)    COMMENT 'Trạng thái hoạt động doanh nghiệp — từ Public Company Dimension.',
    has_state_ownership_indicator      Nullable(Int64)     COMMENT 'Cờ có vốn nhà nước — từ Public Company Dimension.',
    charter_capital_amt                Nullable(Decimal(23,2)) COMMENT 'Vốn điều lệ (Public Company Dimension) — từ Public Company Dimension.',
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
    business_line_level_1_code         Nullable(String)    COMMENT 'Mã ngành cấp 1 — từ Public Company Dimension (đồng bộ cách lấy ngành với Fact Public Company Financial Report Value, không JOIN riêng Industry Dimension).',
    classification_business_line_nm    Nullable(String)    COMMENT 'Tên ngành cấp 1 — từ Public Company Dimension.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), public_company_dim_id)
COMMENT 'Flat table — Fact Public Company Financial Summary Snapshot × Calendar Date × Public Company Dimension'
;

-- ---------------------------------------------------------------------
-- 14. Fact Public Company Listed Share Snapshot
--     [TÁCH 2026-10-08] Tách từ gsdc_fct_public_company_listing_info_snpst_flat theo code dev (DDL 20261005_gsdc_split_listing_info): K_GSDC_1381-1384; nguồn VSDC listed_share_info.
--     Grain: 1 row / mã CK (CTDC) / ngày snapshot; tầng khai thác lọc MAX(snpst_dt) ≤ ngày chặn độc lập cho từng nhóm chỉ số. Cột số lượng là Int64 (bigint).
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_public_company_listed_share_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT PUBLIC COMPANY LISTED SHARE SNAPSHOT
    public_company_dim_id              String                  COMMENT 'FK sang Public Company Dimension (surrogate key, join qua equity_ticker_symbol).',
    snpst_dt_dim_id                    String                  COMMENT 'FK tới Calendar Date Dimension — ngày snapshot (kỳ tháng).',
    outstanding_share_quantity         Nullable(Int64)         COMMENT 'Khối lượng cổ phiếu đang lưu hành (K_GSDC_1381).',
    total_issued_share_quantity        Nullable(Int64)         COMMENT 'Khối lượng cổ phiếu niêm yết (K_GSDC_1382).',
    treasury_share_quantity            Nullable(Int64)         COMMENT 'Khối lượng cổ phiếu quỹ (K_GSDC_1383).',
    free_float_share_quantity          Nullable(Int64)         COMMENT 'Khối lượng cổ phiếu tự do chuyển nhượng — Free Float (K_GSDC_1384).',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                       Nullable(Date)          COMMENT 'Ngày snapshot (kỳ tháng) — từ Calendar Date Dimension.',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code                String                  COMMENT 'Khóa nghiệp vụ — Mã CTĐC — từ Public Company Dimension.',
    equity_ticker_symbol               Nullable(String)        COMMENT 'Mã cổ phiếu — từ Public Company Dimension.',
    public_company_nm                  Nullable(String)        COMMENT 'Tên công ty (tiếng Việt) — từ Public Company Dimension.',
    equity_listing_exchange_code       Nullable(String)        COMMENT 'Sàn niêm yết — từ Public Company Dimension.',
    business_line_level_1_code         Nullable(String)        COMMENT 'Mã ngành cấp 1 — từ Public Company Dimension.',
    classification_business_line_nm    Nullable(String)        COMMENT 'Tên ngành cấp 1 — từ Public Company Dimension.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), public_company_dim_id)
COMMENT 'Flat table — Fact Public Company Listed Share Snapshot × Calendar Date × Public Company Dimension'
;

-- ---------------------------------------------------------------------
-- 15. Fact Public Company Foreign Holding Snapshot
--     [TÁCH 2026-10-08] Tách từ gsdc_fct_public_company_listing_info_snpst_flat theo code dev (DDL 20261005_gsdc_split_listing_info): K_GSDC_1385-1388 + foreign_holding_value (K_NDTNN_51); nguồn VSDC foreign_ownership_info + MDDS security_trading_snapshot.
--     Grain: 1 row / mã CK (CTDC) / ngày snapshot; tầng khai thác lọc MAX(snpst_dt) ≤ ngày chặn độc lập cho từng nhóm chỉ số. Cột số lượng là Int64 (bigint).
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_public_company_foreign_holding_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT PUBLIC COMPANY FOREIGN HOLDING SNAPSHOT
    public_company_dim_id              String                  COMMENT 'FK sang Public Company Dimension (surrogate key, join qua equity_ticker_symbol).',
    snpst_dt_dim_id                    String                  COMMENT 'FK tới Calendar Date Dimension — ngày snapshot (kỳ tháng).',
    current_foreign_holding_quantity   Nullable(Int64)         COMMENT 'Khối lượng cổ phiếu khối ngoại sở hữu (K_GSDC_1385).',
    foreign_ownership_ratio            Nullable(Decimal(5,2))  COMMENT 'Tỷ lệ sở hữu nước ngoài hiện tại (K_GSDC_1386).',
    max_foreign_ownership_ratio        Nullable(Decimal(5,2))  COMMENT 'Tỷ lệ sở hữu nước ngoài tối đa — FOL (K_GSDC_1387).',
    remaining_foreign_holding_quantity Nullable(Int64)         COMMENT 'Room ngoại còn lại (K_GSDC_1388).',
    foreign_holding_value              Nullable(Decimal(23,2)) COMMENT 'Giá trị cổ phiếu khối ngoại đang sở hữu = Current Foreign Holding Quantity x giá đóng cửa gần nhất <= ngày snapshot (K_NDTNN_51, module NDTNN, xem O_NDTNN_12 Resolved một phần 2026-09-18).',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                       Nullable(Date)          COMMENT 'Ngày snapshot (kỳ tháng) — từ Calendar Date Dimension.',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code                String                  COMMENT 'Khóa nghiệp vụ — Mã CTĐC — từ Public Company Dimension.',
    equity_ticker_symbol               Nullable(String)        COMMENT 'Mã cổ phiếu — từ Public Company Dimension.',
    public_company_nm                  Nullable(String)        COMMENT 'Tên công ty (tiếng Việt) — từ Public Company Dimension.',
    equity_listing_exchange_code       Nullable(String)        COMMENT 'Sàn niêm yết — từ Public Company Dimension.',
    business_line_level_1_code         Nullable(String)        COMMENT 'Mã ngành cấp 1 — từ Public Company Dimension.',
    classification_business_line_nm    Nullable(String)        COMMENT 'Tên ngành cấp 1 — từ Public Company Dimension.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), public_company_dim_id)
COMMENT 'Flat table — Fact Public Company Foreign Holding Snapshot × Calendar Date × Public Company Dimension'
;

-- ---------------------------------------------------------------------
-- 16. Fact Public Company State Capital Snapshot
--     [TÁCH 2026-10-08] Tách từ gsdc_fct_public_company_listing_info_snpst_flat theo code dev (DDL 20261005_gsdc_split_listing_info): K_GSDC_1389-1390; nguồn IDS pc_state_capital (driving group by công ty).
--     Grain: 1 row / mã CK (CTDC) / ngày snapshot; tầng khai thác lọc MAX(snpst_dt) ≤ ngày chặn độc lập cho từng nhóm chỉ số. Cột số lượng là Int64 (bigint).
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_fct_public_company_state_capital_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT PUBLIC COMPANY STATE CAPITAL SNAPSHOT
    public_company_dim_id              String                  COMMENT 'FK sang Public Company Dimension (surrogate key, join qua equity_ticker_symbol).',
    snpst_dt_dim_id                    String                  COMMENT 'FK tới Calendar Date Dimension — ngày snapshot (kỳ tháng).',
    state_owned_share_quantity         Nullable(Int64)         COMMENT 'Khối lượng cổ phiếu sở hữu nhà nước — SUM theo công ty/tháng (K_GSDC_1389).',
    state_ownership_ratio_percentage   Nullable(Decimal(5,2))  COMMENT 'Tỷ lệ sở hữu nhà nước — SUM theo công ty/tháng (K_GSDC_1390).',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                       Nullable(Date)          COMMENT 'Ngày snapshot (kỳ tháng) — từ Calendar Date Dimension.',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code                String                  COMMENT 'Khóa nghiệp vụ — Mã CTĐC — từ Public Company Dimension.',
    equity_ticker_symbol               Nullable(String)        COMMENT 'Mã cổ phiếu — từ Public Company Dimension.',
    public_company_nm                  Nullable(String)        COMMENT 'Tên công ty (tiếng Việt) — từ Public Company Dimension.',
    equity_listing_exchange_code       Nullable(String)        COMMENT 'Sàn niêm yết — từ Public Company Dimension.',
    business_line_level_1_code         Nullable(String)        COMMENT 'Mã ngành cấp 1 — từ Public Company Dimension.',
    classification_business_line_nm    Nullable(String)        COMMENT 'Tên ngành cấp 1 — từ Public Company Dimension.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), public_company_dim_id)
COMMENT 'Flat table — Fact Public Company State Capital Snapshot × Calendar Date × Public Company Dimension'
;

-- ---------------------------------------------------------------------
-- 17. Public Company Exchange Industry Financial Report (Fact-report, cross-tab sàn × ngành — không FK Dimension)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_public_company_exchange_industry_financial_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: PUBLIC COMPANY EXCHANGE INDUSTRY FINANCIAL REPORT
    equity_listing_exchange_code        String                  COMMENT 'Sàn niêm yết/đăng ký giao dịch — grain key.',
    business_line_level_1_code          String                  COMMENT 'Mã ngành cấp 1 — grain key (cross-tab sàn × ngành, có dòng ALL).',
    business_line_level_1_name          String                  COMMENT 'Tên ngành cấp 1 — grain key (cross-tab sàn × ngành, có dòng ALL).',
    rpt_year                            Int64                   COMMENT 'Năm báo cáo — grain key theo kỳ.',
    rpt_quarter                         Nullable(Int64)         COMMENT 'Quý báo cáo — grain key theo kỳ.',
    total_asset_amt                     Nullable(Decimal(38,8)) COMMENT 'Tổng tài sản theo sàn — ETL populate 2 tầng (Gold-to-Gold) từ Fact Public Company Financial Summary Snapshot (đã dedup form ưu tiên HN>TH>ME>RI sẵn), GROUP BY sàn.',
    total_asset_yoy                     Nullable(Decimal(30,6)) COMMENT 'Total Asset — YoY, % tăng/giảm tương đối so cùng kỳ năm trước. ETL populate: copy trực tiếp từ Public Company Financial YoY Report theo sàn khớp, không tính lại.',
    inventory_amt                       Nullable(Decimal(38,8)) COMMENT 'Hàng tồn kho theo sàn — ETL populate 2 tầng (Gold-to-Gold) từ Fact Public Company Financial Summary Snapshot (đã dedup form ưu tiên HN>TH>ME>RI sẵn), GROUP BY sàn.',
    inventory_yoy                       Nullable(Decimal(30,6)) COMMENT 'Inventory — YoY, % tăng/giảm tương đối so cùng kỳ năm trước. ETL populate: copy trực tiếp từ Public Company Financial YoY Report theo sàn khớp, không tính lại.',
    total_liability_amt                 Nullable(Decimal(38,8)) COMMENT 'Nợ phải trả theo sàn — ETL populate 2 tầng (Gold-to-Gold) từ Fact Public Company Financial Summary Snapshot (đã dedup form ưu tiên HN>TH>ME>RI sẵn), GROUP BY sàn.',
    total_liability_yoy                 Nullable(Decimal(30,6)) COMMENT 'Total Liability — YoY, % tăng/giảm tương đối so cùng kỳ năm trước. ETL populate: copy trực tiếp từ Public Company Financial YoY Report theo sàn khớp, không tính lại.',
    equity_amt                          Nullable(Decimal(38,8)) COMMENT 'Vốn chủ sở hữu theo sàn — ETL populate 2 tầng (Gold-to-Gold) từ Fact Public Company Financial Summary Snapshot (đã dedup form ưu tiên HN>TH>ME>RI sẵn), GROUP BY sàn.',
    equity_yoy                          Nullable(Decimal(30,6)) COMMENT 'Equity — YoY, % tăng/giảm tương đối so cùng kỳ năm trước. ETL populate: copy trực tiếp từ Public Company Financial YoY Report theo sàn khớp, không tính lại.',
    contributed_capital_amt             Nullable(Decimal(38,8)) COMMENT 'Vốn góp của chủ sở hữu (cùng khái niệm Vốn điều lệ) theo sàn — ETL populate 2 tầng (Gold-to-Gold) từ Fact Public Company Financial Summary Snapshot (đã dedup form ưu tiên HN>TH>ME>RI sẵn), GROUP BY sàn.',
    contributed_capital_yoy             Nullable(Decimal(30,6)) COMMENT 'Contributed Capital — YoY, % tăng/giảm tương đối so cùng kỳ năm trước. ETL populate: copy trực tiếp từ Public Company Financial YoY Report theo sàn khớp, không tính lại.',
    undistributed_profit_amt            Nullable(Decimal(38,8)) COMMENT 'Lợi nhuận sau thuế chưa phân phối theo sàn — ETL populate 2 tầng (Gold-to-Gold) từ Fact Public Company Financial Summary Snapshot (đã dedup form ưu tiên HN>TH>ME>RI sẵn), GROUP BY sàn.',
    undistributed_profit_yoy            Nullable(Decimal(30,6)) COMMENT 'Undistributed Profit — YoY, % tăng/giảm tương đối so cùng kỳ năm trước. ETL populate: copy trực tiếp từ Public Company Financial YoY Report theo sàn khớp, không tính lại.',
    net_revenue_amt                     Nullable(Decimal(38,8)) COMMENT 'Doanh thu thuần theo sàn — ETL populate 2 tầng (Gold-to-Gold) từ Fact Public Company Financial Summary Snapshot (đã dedup form ưu tiên HN>TH>ME>RI sẵn), GROUP BY sàn.',
    net_revenue_yoy                     Nullable(Decimal(30,6)) COMMENT 'Net Revenue — YoY, % tăng/giảm tương đối so cùng kỳ năm trước. ETL populate: copy trực tiếp từ Public Company Financial YoY Report theo sàn khớp, không tính lại.',
    pre_tax_profit_amt                  Nullable(Decimal(38,8)) COMMENT 'Lợi nhuận kế toán trước thuế theo sàn — ETL populate 2 tầng (Gold-to-Gold) từ Fact Public Company Financial Summary Snapshot (đã dedup form ưu tiên HN>TH>ME>RI sẵn), GROUP BY sàn.',
    pre_tax_profit_yoy                  Nullable(Decimal(30,6)) COMMENT 'Pre Tax Profit — YoY, % tăng/giảm tương đối so cùng kỳ năm trước. ETL populate: copy trực tiếp từ Public Company Financial YoY Report theo sàn khớp, không tính lại.',
    net_profit_amt                      Nullable(Decimal(38,8)) COMMENT 'Lợi nhuận sau thuế theo sàn — ETL populate 2 tầng (Gold-to-Gold) từ Fact Public Company Financial Summary Snapshot (đã dedup form ưu tiên HN>TH>ME>RI sẵn), GROUP BY sàn.',
    net_profit_yoy                      Nullable(Decimal(30,6)) COMMENT 'Net Profit — YoY, % tăng/giảm tương đối so cùng kỳ năm trước. ETL populate: copy trực tiếp từ Public Company Financial YoY Report theo sàn khớp, không tính lại.',
    roa_percentage                      Nullable(Decimal(30,6)) COMMENT 'ROA theo sàn — tính lại ở mức sàn trong bước ETL populate, KHÔNG copy cột roa per-company có sẵn trên Fact.',
    roa_yoy_percentage                  Nullable(Decimal(30,6)) COMMENT 'ROA — YoY, % tăng/giảm TƯƠNG ĐỐI so cùng kỳ năm trước (không phải hiệu số điểm %). ETL populate: copy trực tiếp từ Public Company Financial YoY Report.',
    roe_percentage                      Nullable(Decimal(30,6)) COMMENT 'ROE theo sàn — tính lại ở mức sàn trong bước ETL populate, KHÔNG copy cột roe per-company có sẵn trên Fact.',
    roe_yoy_percentage                  Nullable(Decimal(30,6)) COMMENT 'ROE — YoY, % tăng/giảm TƯƠNG ĐỐI so cùng kỳ năm trước (không phải hiệu số điểm %). ETL populate: copy trực tiếp từ Public Company Financial YoY Report.',
    receivable_amt                      Nullable(Decimal(38,8)) COMMENT 'Receivable theo sàn.',
    receivable_yoy                      Nullable(Decimal(30,6)) COMMENT 'Receivable — YoY %.',
    cash_and_equivalent_amt             Nullable(Decimal(38,8)) COMMENT 'Cash And Equivalent theo sàn.',
    cash_and_equivalent_yoy             Nullable(Decimal(30,6)) COMMENT 'Cash And Equivalent — YoY %.',
    debt_to_equity_percentage           Nullable(Decimal(30,6)) COMMENT 'Nợ phải trả / Vốn chủ sở hữu theo sàn.',
    debt_to_equity_yoy_percentage       Nullable(Decimal(30,6)) COMMENT 'Nợ/VCSH — YoY.',
    net_revenue_ytd_amt                 Nullable(Decimal(38,8)) COMMENT 'Net Revenue lũy kế từ đầu năm theo sàn.',
    net_revenue_ytd_yoy                 Nullable(Decimal(30,6)) COMMENT 'Net Revenue lũy kế — YoY.',
    pre_tax_profit_ytd_amt              Nullable(Decimal(38,8)) COMMENT 'Pre Tax Profit lũy kế từ đầu năm theo sàn.',
    pre_tax_profit_ytd_yoy              Nullable(Decimal(30,6)) COMMENT 'Pre Tax Profit lũy kế — YoY.',
    net_profit_ytd_amt                  Nullable(Decimal(38,8)) COMMENT 'Net Profit lũy kế từ đầu năm theo sàn.',
    net_profit_ytd_yoy                  Nullable(Decimal(30,6)) COMMENT 'Net Profit lũy kế — YoY.',
    roa_ytd_percentage                  Nullable(Decimal(30,6)) COMMENT 'ROA theo LNST lũy kế, theo sàn.',
    roa_ytd_yoy_percentage              Nullable(Decimal(30,6)) COMMENT 'ROA lũy kế — YoY.',
    roe_ytd_percentage                  Nullable(Decimal(30,6)) COMMENT 'ROE theo LNST lũy kế, theo sàn.',
    roe_ytd_yoy_percentage              Nullable(Decimal(30,6)) COMMENT 'ROE lũy kế — YoY.',
    total_asset_ytd_chg                 Nullable(Decimal(30,6)) COMMENT 'Biến động `total_asset` so với đầu năm (YTD change) theo sàn — copy từ `public_company_financial_ytd_chg_rpt`.',
    total_liability_ytd_chg             Nullable(Decimal(30,6)) COMMENT 'Biến động `total_liability` so với đầu năm (YTD change) theo sàn — copy từ `public_company_financial_ytd_chg_rpt`.',
    equity_ytd_chg                      Nullable(Decimal(30,6)) COMMENT 'Biến động `equity` so với đầu năm (YTD change) theo sàn — copy từ `public_company_financial_ytd_chg_rpt`.',
    contributed_capital_ytd_chg         Nullable(Decimal(30,6)) COMMENT 'Biến động `contributed_capital` so với đầu năm (YTD change) theo sàn — copy từ `public_company_financial_ytd_chg_rpt`.',
    inventory_ytd_chg                   Nullable(Decimal(30,6)) COMMENT 'Biến động `inventory` so với đầu năm (YTD change) theo sàn — copy từ `public_company_financial_ytd_chg_rpt`.',
    undistributed_profit_ytd_chg        Nullable(Decimal(30,6)) COMMENT 'Biến động `undistributed_profit` so với đầu năm (YTD change) theo sàn — copy từ `public_company_financial_ytd_chg_rpt`.',
    receivable_ytd_chg                  Nullable(Decimal(30,6)) COMMENT 'Biến động `receivable` so với đầu năm (YTD change) theo sàn — copy từ `public_company_financial_ytd_chg_rpt`.',
    cash_and_equivalent_ytd_chg         Nullable(Decimal(30,6)) COMMENT 'Biến động `cash_and_equivalent` so với đầu năm (YTD change) theo sàn — copy từ `public_company_financial_ytd_chg_rpt`.',
    debt_to_equity_ytd_chg              Nullable(Decimal(30,6)) COMMENT 'Biến động `debt_to_equity` so với đầu năm (YTD change) theo sàn — copy từ `public_company_financial_ytd_chg_rpt`.',
    src_stm_code                        String                  COMMENT 'Nguồn hệ thống tính toán báo cáo tổng hợp tài chính theo sàn.',
    rpt_dt                              String                  COMMENT 'Ngày chạy ETL populate bảng (format yyyyMMdd) — audit column phục vụ downstream lọc lát cắt dữ liệu mới của ngày, không thuộc grain/PK báo cáo.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(toDate(concat(toString(rpt_year), '-01-01')))
ORDER BY (rpt_year, equity_listing_exchange_code, business_line_level_1_code)
COMMENT 'Flat table — Public Company Exchange Industry Financial Report (Fact-report, no FK Dimension)'
;

-- ---------------------------------------------------------------------
-- 18. Public Company Dimension (1-1 từ Datamart dimension, full refresh) — [THEO CODE DEV, ngoại lệ quy tắc Phase 3: O_GSDC_35]
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_public_company_flat ON CLUSTER 'my_cluster'
(
    -- From: PUBLIC COMPANY DIMENSION
    public_company_dim_id               String                  COMMENT 'PK — Driving: Public Company (public_company).',
    public_company_code                 String                  COMMENT 'Khóa nghiệp vụ — map từ Public Company Code.',
    equity_ticker_symbol                Nullable(String)        COMMENT 'Mã cổ phiếu.',
    public_company_nm                   Nullable(String)        COMMENT 'Tên công ty (tiếng Việt).',
    equity_listing_exchange_code        Nullable(String)        COMMENT 'Sàn niêm yết.',
    equity_listing_exchange_name        Nullable(String)        COMMENT 'Tên sàn niêm yết (HOSE/HNX/UPCOM…) — BA muốn hiển thị tên sàn thay vì chỉ mã.',
    business_line_level_1_code          Nullable(String)        COMMENT 'Mã ngành cấp 1. Scheme: IDS_INDUSTRY_CATEGORY.',
    ids_registration_dt                 Nullable(Date)          COMMENT 'Ngày đăng ký IDS.',
    public_company_status_code          Nullable(String)        COMMENT 'Trạng thái công ty.',
    src_stm_code                        String                  COMMENT 'Mã hệ thống nguồn dữ liệu.',
    classification_business_line_nm     Nullable(String)        COMMENT 'Tên ngành nghề kinh doanh cấp 1 của công ty đại chúng.',
    public_company_english_nm           Nullable(String)        COMMENT 'Tên công ty (tiếng Anh) — dùng cho báo cáo/dashboard song ngữ',
    enterprise_tp_code                  Nullable(String)        COMMENT 'Loại hình doanh nghiệp (TNHH/CP/...) — Atomic khai domain Text, chưa chuẩn hoá thành Classification Value',
    enterprise_tp_nm                    Nullable(String)        COMMENT 'Tên loại hình doanh nghiệp — LEFT JOIN cl_value; hiện trả NULL toàn bộ do Atomic public_company.enterprise_tp_code chưa có FK/lookup annotation tới scheme ENTERPRISE_TYPE (chỉ có IDS_ENTERPRISE_TYPE tồn tại, values rỗng, gán cho F',
    public_company_tp_code              Nullable(String)        COMMENT 'Loại công ty đại chúng — Atomic khai domain Text, chưa chuẩn hoá thành Classification Value',
    head_office_province_nm             Nullable(String)        COMMENT 'Tỉnh/TP trụ sở chính — slicer địa lý',
    operating_status_code               Nullable(String)        COMMENT 'Trạng thái hoạt động doanh nghiệp — khác Public Company Status Code (trạng thái hồ sơ IDS). Atomic khai domain Text',
    has_state_ownership_indicator       Nullable(Int64)         COMMENT 'Cờ có vốn nhà nước — slicer báo cáo giám sát TTCK. Atomic khai domain Small Counter/int (không phải Boolean)',
    charter_capital_amt                 Nullable(Decimal(23,2)) COMMENT 'Vốn điều lệ — measure/slicer quy mô doanh nghiệp',
    first_registration_dt               Nullable(Date)          COMMENT 'Ngày đăng ký lần đầu',
    latest_registration_dt              Nullable(Date)          COMMENT 'Ngày đăng ký thay đổi gần nhất',
    latest_registration_province_nm     Nullable(String)        COMMENT 'Tỉnh/TP đăng ký thay đổi gần nhất',
    ids_registration_indicator          Nullable(Int64)         COMMENT 'Trạng thái đăng ký IDS — Atomic khai domain Small Counter/int',
    public_company_form_code            Nullable(String)        COMMENT 'Hình thức trở thành công ty đại chúng',
    former_state_owned_indicator        Nullable(Int64)         COMMENT 'Doanh nghiệp nhà nước (trước đây) — Atomic khai domain Small Counter/int',
    foreign_direct_investment_indicator Nullable(Int64)         COMMENT 'Doanh nghiệp FDI — Atomic khai domain Small Counter/int',
    has_parent_company_indicator        Nullable(Int64)         COMMENT 'Có công ty mẹ — Atomic khai domain Small Counter/int',
    has_subsidiary_indicator            Nullable(Int64)         COMMENT 'Có công ty con — Atomic khai domain Small Counter/int',
    has_joint_venture_indicator         Nullable(Int64)         COMMENT 'Có liên doanh — Atomic khai domain Small Counter/int',
    ipo_company_indicator               Nullable(Int64)         COMMENT '1-Công ty đang IPO, 0-Công ty đại chúng — Atomic khai domain Small Counter/int'
)
ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (public_company_dim_id)
COMMENT 'Flat table — Public Company Dimension (1-1)'
;

-- ---------------------------------------------------------------------
-- 19. Industry Dimension (1-1 từ Datamart dimension, full refresh) — [THEO CODE DEV, ngoại lệ quy tắc Phase 3: O_GSDC_35]
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS datamart.gsdc_industry_flat ON CLUSTER 'my_cluster'
(
    -- From: INDUSTRY DIMENSION
    industry_dim_id                     String                  COMMENT 'PK — Driving: cl_business_line',
    industry_code                       String                  COMMENT 'BK — mã ngành nghề cấp 1 (Classification Business Line Code). Chỉ lấy ngành đang hiệu lực sử dụng (Active Indicator = 1) — filter áp dụng ở tầng driving table (WHERE), không lọc theo Effective/Deleted Indicator.',
    industry_nm                         String                  COMMENT 'Tên ngành nghề cấp 1',
    src_stm_code                        String                  COMMENT 'src_stm_code — Driving: cl_business_line, current-state SCD4A lấy bản ghi mới nhất theo Industry Code'
)
ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (industry_dim_id)
COMMENT 'Flat table — Industry Dimension (1-1)'
;
