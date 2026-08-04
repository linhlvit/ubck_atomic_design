-- ============================================================
-- NDTNN Flat Tables — CREATE
-- Module: Nhà Đầu Tư Nước Ngoài — NDTNN
-- Generated: Phase 3 LLD Datamart
-- 5 bảng: 3 fact + 2 operational
-- (Fact Market Index Snapshot dùng chung QLKD — flat table đã có ở QLKD, không CREATE lại)
-- ============================================================

-- ============================================================
-- 1. FACT: ndtnn_fct_securities_foreign_trading_snpst_flat
--    Fact Securities Foreign Trading Snapshot
--    Joins: Calendar Date × Securities Dimension × Public Company Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.ndtnn_fct_securities_foreign_trading_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Securities Foreign Trading Snapshot
    trade_dt_dim_id                 String                  COMMENT 'FK ngày giao dịch',
    securities_dim_id               String                  COMMENT 'FK mã chứng khoán',
    public_company_dim_id           Nullable(String)        COMMENT 'FK công ty đại chúng — nullable, không phải mọi mã CK đều là công ty đại chúng',
    foreign_buy_val                 Decimal(23,2)           COMMENT 'GT mua của NĐTNN',
    foreign_sell_val                Decimal(23,2)           COMMENT 'GT bán của NĐTNN',
    total_market_val                Decimal(23,2)           COMMENT 'Tổng GT giao dịch toàn thị trường',

    -- From: CALENDAR DATE DIMENSION
    trade_cdr_dt                    Nullable(Date)           COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',

    -- From: SECURITIES DIMENSION
    symbol                          Nullable(String)         COMMENT 'Mã chứng khoán — từ Securities Dimension',
    security_full_nm                Nullable(String)         COMMENT 'Tên chứng khoán — từ Securities Dimension',
    stock_tp_code                   Nullable(String)         COMMENT 'Loại chứng khoán — từ Securities Dimension',
    floor_code                      Nullable(String)         COMMENT 'Mã sàn — từ Securities Dimension',
    listed_share_count              Nullable(Int64)          COMMENT 'Khối lượng CK niêm yết — từ Securities Dimension',
    total_listing_vol               Nullable(Int64)          COMMENT 'Tổng khối lượng CK niêm yết — từ Securities Dimension',
    underlying_symbol               Nullable(String)         COMMENT 'Chứng khoán cơ sở — từ Securities Dimension',
    issuer_nm                       Nullable(String)         COMMENT 'Tổ chức phát hành — từ Securities Dimension',
    listing_dt                      Nullable(Date)           COMMENT 'Ngày niêm yết — từ Securities Dimension',
    symbol_status_code              Nullable(String)         COMMENT 'Trạng thái mã CK — từ Securities Dimension',
    securities_src_stm_code         Nullable(String)         COMMENT 'Mã hệ thống nguồn — từ Securities Dimension',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code             Nullable(String)         COMMENT 'Mã công ty đại chúng — từ Public Company Dimension',
    equity_ticker_symbol            Nullable(String)         COMMENT 'Mã cổ phiếu — từ Public Company Dimension',
    public_company_nm               Nullable(String)         COMMENT 'Tên công ty — từ Public Company Dimension',
    equity_listing_exchange_code    Nullable(String)         COMMENT 'Sàn niêm yết — từ Public Company Dimension',
    business_line_level_1_code      Nullable(String)         COMMENT 'Mã ngành cấp 1 — từ Public Company Dimension',
    ids_registration_dt             Nullable(Date)           COMMENT 'Ngày đăng ký IDS — từ Public Company Dimension',
    public_company_status_code      Nullable(String)         COMMENT 'Trạng thái công ty — từ Public Company Dimension',
    classification_business_line_nm Nullable(String)         COMMENT 'Tên ngành (đệm sẵn) — từ Public Company Dimension',
    public_company_english_nm       Nullable(String)         COMMENT 'Tên công ty tiếng Anh — từ Public Company Dimension',
    enterprise_tp_code               Nullable(String)         COMMENT 'Loại hình doanh nghiệp — từ Public Company Dimension',
    public_company_tp_code          Nullable(String)         COMMENT 'Loại công ty đại chúng — từ Public Company Dimension',
    head_office_province_nm         Nullable(String)         COMMENT 'Tỉnh/TP trụ sở chính — từ Public Company Dimension',
    operating_status_code           Nullable(String)         COMMENT 'Trạng thái hoạt động doanh nghiệp — từ Public Company Dimension',
    has_state_ownership_indicator   Nullable(Int64)          COMMENT 'Cờ có vốn nhà nước — từ Public Company Dimension',
    charter_capital_amt             Nullable(Decimal(23,2))  COMMENT 'Vốn điều lệ — từ Public Company Dimension',
    first_registration_dt           Nullable(Date)           COMMENT 'Ngày đăng ký lần đầu — từ Public Company Dimension',
    latest_registration_dt          Nullable(Date)           COMMENT 'Ngày đăng ký thay đổi gần nhất — từ Public Company Dimension',
    latest_registration_province_nm Nullable(String)         COMMENT 'Tỉnh/TP đăng ký thay đổi gần nhất — từ Public Company Dimension',
    ids_registration_indicator      Nullable(Int64)          COMMENT 'Trạng thái đăng ký IDS — từ Public Company Dimension',
    public_company_form_code        Nullable(String)         COMMENT 'Hình thức trở thành công ty đại chúng — từ Public Company Dimension',
    former_state_owned_indicator    Nullable(Int64)          COMMENT 'Doanh nghiệp nhà nước (trước đây) — từ Public Company Dimension',
    foreign_direct_investment_indicator Nullable(Int64)      COMMENT 'Doanh nghiệp FDI — từ Public Company Dimension',
    has_parent_company_indicator    Nullable(Int64)          COMMENT 'Có công ty mẹ — từ Public Company Dimension',
    has_subsidiary_indicator        Nullable(Int64)          COMMENT 'Có công ty con — từ Public Company Dimension',
    has_joint_venture_indicator     Nullable(Int64)          COMMENT 'Có liên doanh — từ Public Company Dimension',
    ipo_company_indicator           Nullable(Int64)          COMMENT '1-Công ty đang IPO, 0-Công ty đại chúng — từ Public Company Dimension',
    public_company_src_stm_code     Nullable(String)         COMMENT 'Mã hệ thống nguồn — từ Public Company Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(trade_cdr_dt))
ORDER BY (assumeNotNull(trade_cdr_dt), securities_dim_id)
COMMENT 'Flat table — Fact Securities Foreign Trading Snapshot × Calendar Date × Securities Dimension × Public Company Dimension'
;


-- ============================================================
-- 2. FACT (report): ndtnn_foreign_investor_trading_statistics_rpt_flat
--    Foreign Investor Trading Statistics Report
--    Joins: không có — denormalize hoàn toàn, không FK Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.ndtnn_foreign_investor_trading_statistics_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Foreign Investor Trading Statistics Report
    report_dt                       Date                    COMMENT 'Ngày báo cáo',
    security_tp_group               String                  COMMENT 'Nhóm loại CK — Classification Value nội bộ Datamart: STOCK/BOND/FUND_CERT/TOTAL',
    buy_val                         Decimal(23,2)            COMMENT 'GT NĐTNN mua chứng khoán',
    sell_val                        Decimal(23,2)            COMMENT 'GT NĐTNN bán chứng khoán',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(report_dt))
ORDER BY (assumeNotNull(report_dt), security_tp_group)
COMMENT 'Flat table — Foreign Investor Trading Statistics Report (denormalize, không FK Dimension)'
;


-- ============================================================
-- 3. FACT (report): ndtnn_foreign_investor_trading_detail_rpt_flat
--    Foreign Investor Trading Detail Report
--    Joins: không có — denormalize hoàn toàn, không FK Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.ndtnn_foreign_investor_trading_detail_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Foreign Investor Trading Detail Report
    report_dt                       Date                    COMMENT 'Ngày báo cáo',
    account_nbr                     String                  COMMENT 'Tài khoản giao dịch NĐTNN',
    symbol                          String                  COMMENT 'Mã CK — denormalize text trực tiếp',
    trade_direction_code            String                  COMMENT 'Chiều mua/bán (BUY/SELL)',
    account_holder_nm               Nullable(String)        COMMENT 'Tên chủ tài khoản (đệm sẵn)',
    execution_vol                   Int64                   COMMENT 'KL mua/bán CK',
    execution_val                   Decimal(23,2)           COMMENT 'GT mua/bán CK',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(report_dt))
ORDER BY (assumeNotNull(report_dt), account_nbr, symbol, trade_direction_code)
COMMENT 'Flat table — Foreign Investor Trading Detail Report (denormalize, không FK Dimension)'
;


-- ============================================================
-- 4. OPERATIONAL: opr_foreign_investor_360_profile_flat
--    Operational Foreign Investor 360 Profile
--    Joins: không có
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.ndtnn_opr_foreign_investor_360_profile_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Operational Foreign Investor 360 Profile
    investor_code                   String                  COMMENT 'PK — Mã số giao dịch NĐTNN (VSDC cấp)',
    investor_nm                     String                  COMMENT 'Tên đầy đủ NĐT',
    nationality_code                Nullable(String)        COMMENT 'Mã quốc tịch',
    investor_tp_code                Nullable(String)        COMMENT 'Loại hình NĐT',
    director_nm                     Nullable(String)        COMMENT 'Đại diện giao dịch',
    custodian_bank_nm               Nullable(String)        COMMENT 'Tên ngân hàng lưu ký (denormalize)',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (investor_code)
COMMENT 'Flat table — Operational Foreign Investor 360 Profile'
;


-- ============================================================
-- 5. OPERATIONAL: opr_investor_compliance_hist_flat
--    Operational Investor Compliance History
--    Joins: không có
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.ndtnn_opr_investor_compliance_hist_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Operational Investor Compliance History
    investor_compliance_hist_code   String                  COMMENT 'PK — 1 hành vi vi phạm × 1 đối tượng bị xử phạt',
    subject_nm                      String                  COMMENT 'Thông tin nhà đầu tư (tên/MSGD NĐTNN)',
    issued_dt                       Date                    COMMENT 'Ngày quyết định',
    penalty_tp_nm                   Nullable(String)        COMMENT 'Phân loại hình thức xử lý',
    description                     Nullable(String)        COMMENT 'Nội dung/Trích yếu',
    life_cycle_status_code          Nullable(String)        COMMENT 'Trạng thái xử lý',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (investor_compliance_hist_code)
COMMENT 'Flat table — Operational Investor Compliance History'
;
