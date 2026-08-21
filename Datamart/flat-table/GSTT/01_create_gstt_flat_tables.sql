-- ============================================================
-- GSTT Flat Tables — CREATE
-- Module: Giám sát Thị trường (GSTT)
-- Generated: Phase 3 LLD Datamart
-- 2 bảng: 2 fact
-- (Fact Market Index Snapshot dùng chung QLKD — flat table đã có ở QLKD, không CREATE lại)
-- Sửa 2026-08-03: bảng #3 cũ (Fact Public Company Shareholding) đã bị loại bỏ —
-- xem ghi chú chi tiết cuối file
-- ============================================================


-- ============================================================
-- 1. FACT: gstt_fct_stock_portfolio_snpst_flat
--    Danh mục chứng khoán tổng hợp — 1 row / mã CK / rổ chỉ số (FK nullable) / ngày giao dịch
--    Grain: Periodic Snapshot theo ngày (transaction log — mỗi ngày phiên phát sinh
--    đồng bộ dữ liệu cho toàn bộ mã CK giao dịch)
--    Joins: Calendar Date (cdr_dt_dim_id JOIN) × Security Trading Snapshot Dimension ×
--           Public Company Dimension × Index Constituent Dimension (LEFT JOIN, nullable)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_fct_stock_portfolio_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Stock Portfolio Snapshot
    security_trading_snpst_dim_id       String                  COMMENT 'FK → Security Trading Snapshot Dimension',
    public_company_dim_id               String                  COMMENT 'FK → Public Company Dimension',
    cdr_dt_dim_id                       String                  COMMENT 'FK → Calendar Date Dimension',
    index_constituent_dim_id            Nullable(String)        COMMENT 'FK → Index Constituent Dimension — nullable khi mã CK không thuộc rổ chỉ số nào',
    total_vol                           Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch khớp lệnh cổ phiếu/CCQ 3 sàn, loại trừ phái sinh và trái phiếu',
    total_val                           Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch khớp lệnh cổ phiếu/CCQ 3 sàn, loại trừ phái sinh và trái phiếu',
    total_derivative_vol                Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch phái sinh',
    total_derivative_val                Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch phái sinh',
    total_negotiated_vol                Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch thỏa thuận',
    total_negotiated_val                Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch thỏa thuận',
    foreign_net_vol                     Nullable(Int64)         COMMENT 'Khối lượng mua ròng của nhà đầu tư nước ngoài',
    outstanding_share_quantity          Nullable(Int64)         COMMENT 'Số cổ phiếu đang lưu hành — PENDING, chưa có nguồn Atomic',
    net_profit_after_tax                Nullable(Decimal(23,2)) COMMENT 'Lợi nhuận sau thuế — PENDING, chưa có nguồn Atomic',
    owner_equity                        Nullable(Decimal(23,2)) COMMENT 'Vốn chủ sở hữu — PENDING, chưa có nguồn Atomic',
    foreign_buy_vol                     Nullable(Int64)         COMMENT 'Khối lượng mua của nhà đầu tư nước ngoài',
    foreign_sell_vol                    Nullable(Int64)         COMMENT 'Khối lượng bán của nhà đầu tư nước ngoài',
    foreign_buy_val                     Nullable(Decimal(23,2)) COMMENT 'Giá trị mua của nhà đầu tư nước ngoài',
    foreign_sell_val                    Nullable(Decimal(23,2)) COMMENT 'Giá trị bán của nhà đầu tư nước ngoài',
    proprietary_buy_val                 Nullable(Decimal(23,2)) COMMENT 'Giá trị mua tự doanh',
    proprietary_sell_val                Nullable(Decimal(23,2)) COMMENT 'Giá trị bán tự doanh',
    individual_net_val                  Nullable(Decimal(23,2)) COMMENT 'Giá trị mua-bán ròng của nhà đầu tư cá nhân trong nước',
    domestic_institution_net_val        Nullable(Decimal(23,2)) COMMENT 'Giá trị mua-bán ròng của tổ chức trong nước',
    proprietary_buy_vol                 Nullable(Int64)         COMMENT 'Khối lượng mua tự doanh',
    proprietary_sell_vol                Nullable(Int64)         COMMENT 'Khối lượng bán tự doanh',
    bond_trading_vol                    Nullable(Int64)         COMMENT 'Khối lượng giao dịch trái phiếu (loại trừ lô lẻ)',
    bond_trading_val                    Nullable(Decimal(23,2)) COMMENT 'Giá trị giao dịch trái phiếu (loại trừ lô lẻ)',
    individual_buy_val                  Nullable(Decimal(23,2)) COMMENT 'Giá trị mua của nhà đầu tư cá nhân trong nước',
    individual_sell_val                 Nullable(Decimal(23,2)) COMMENT 'Giá trị bán của nhà đầu tư cá nhân trong nước',
    individual_buy_vol                  Nullable(Int64)         COMMENT 'Khối lượng mua của nhà đầu tư cá nhân trong nước',
    individual_sell_vol                 Nullable(Int64)         COMMENT 'Khối lượng bán của nhà đầu tư cá nhân trong nước',
    domestic_institution_buy_val        Nullable(Decimal(23,2)) COMMENT 'Giá trị mua của tổ chức trong nước',
    domestic_institution_sell_val       Nullable(Decimal(23,2)) COMMENT 'Giá trị bán của tổ chức trong nước',
    domestic_institution_buy_vol        Nullable(Int64)         COMMENT 'Khối lượng mua của tổ chức trong nước',
    domestic_institution_sell_vol       Nullable(Int64)         COMMENT 'Khối lượng bán của tổ chức trong nước',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)          COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    symbol                               Nullable(String)        COMMENT 'Mã chứng khoán — từ Security Trading Snapshot Dimension',
    security_full_nm                    Nullable(String)        COMMENT 'Tên chứng khoán — từ Security Trading Snapshot Dimension',
    floor_code                          Nullable(String)        COMMENT 'Mã sàn — từ Security Trading Snapshot Dimension',
    stock_tp_code                       Nullable(String)        COMMENT 'Loại chứng khoán — từ Security Trading Snapshot Dimension',
    stock_tp_nm                         Nullable(String)        COMMENT 'Tên loại chứng khoán (dẫn xuất theo sàn) — từ Security Trading Snapshot Dimension',
    underlying_symbol                   Nullable(String)        COMMENT 'Chứng khoán cơ sở (CW/phái sinh) — từ Security Trading Snapshot Dimension',
    isin_code                           Nullable(String)        COMMENT 'Mã ISIN — từ Security Trading Snapshot Dimension',
    issuer_nm                           Nullable(String)        COMMENT 'Tổ chức phát hành — từ Security Trading Snapshot Dimension',
    listed_share_count                  Nullable(Int64)         COMMENT 'Khối lượng CK niêm yết — từ Security Trading Snapshot Dimension',
    first_trading_dt                    Nullable(Date)          COMMENT 'Ngày giao dịch đầu tiên — từ Security Trading Snapshot Dimension',
    last_trading_dt                     Nullable(Date)          COMMENT 'Ngày giao dịch cuối cùng — từ Security Trading Snapshot Dimension',
    issue_dt                            Nullable(Date)          COMMENT 'Ngày phát hành — từ Security Trading Snapshot Dimension',
    maturity_dt                         Nullable(Date)          COMMENT 'Ngày đáo hạn — từ Security Trading Snapshot Dimension',
    fund_tp_code                        Nullable(String)        COMMENT 'Loại quỹ (CCQ) — từ Security Trading Snapshot Dimension',
    covered_warrant_tp_code             Nullable(String)        COMMENT 'Loại chứng quyền — từ Security Trading Snapshot Dimension',
    exercise_price                      Nullable(Decimal(23,2)) COMMENT 'Giá thực hiện (CW/phái sinh) — từ Security Trading Snapshot Dimension',
    exercise_ratio                      Nullable(Decimal(10,2)) COMMENT 'Tỷ lệ chuyển đổi — từ Security Trading Snapshot Dimension',
    exercise_style_code                 Nullable(String)        COMMENT 'Kiểu thực hiện quyền — từ Security Trading Snapshot Dimension',
    put_or_call_code                    Nullable(String)        COMMENT 'Quyền chọn mua/bán — từ Security Trading Snapshot Dimension',
    contract_multiplier                 Nullable(Decimal(10,2)) COMMENT 'Hệ số hợp đồng (phái sinh) — từ Security Trading Snapshot Dimension',
    maturity_month_year                 Nullable(String)        COMMENT 'Tháng/năm đáo hạn (phái sinh) — từ Security Trading Snapshot Dimension',
    coupon_rate                         Nullable(Decimal(7,4))  COMMENT 'Lãi suất coupon (trái phiếu) — từ Security Trading Snapshot Dimension',
    yield                                Nullable(Decimal(7,4))  COMMENT 'Lợi suất (trái phiếu) — từ Security Trading Snapshot Dimension',
    open_price                           Nullable(Decimal(23,2)) COMMENT 'Giá mở cửa — từ Security Trading Snapshot Dimension',
    high_price                           Nullable(Decimal(23,2)) COMMENT 'Giá cao nhất — từ Security Trading Snapshot Dimension',
    low_price                            Nullable(Decimal(23,2)) COMMENT 'Giá thấp nhất — từ Security Trading Snapshot Dimension',
    reference_price                     Nullable(Decimal(23,2)) COMMENT 'Giá tham chiếu — từ Security Trading Snapshot Dimension',
    close_price                         Nullable(Decimal(23,2)) COMMENT 'Giá đóng cửa — từ Security Trading Snapshot Dimension',
    price_change                        Nullable(Decimal(23,2)) COMMENT 'Thay đổi giá — từ Security Trading Snapshot Dimension',
    security_trading_snpst_src_stm_code Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Security Trading Snapshot Dimension',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code                 Nullable(String)        COMMENT 'Mã CTĐC — từ Public Company Dimension',
    equity_ticker_symbol                 Nullable(String)        COMMENT 'Mã cổ phiếu — từ Public Company Dimension',
    public_company_nm                    Nullable(String)        COMMENT 'Tên doanh nghiệp — từ Public Company Dimension',
    equity_listing_exchange_code         Nullable(String)        COMMENT 'Sàn niêm yết — từ Public Company Dimension',
    business_line_level_1_code           Nullable(String)        COMMENT 'Ngành kinh tế cấp 1 — từ Public Company Dimension',
    ids_registration_dt                  Nullable(Date)          COMMENT 'Ngày đăng ký IDS — từ Public Company Dimension',
    public_company_status_code           Nullable(String)        COMMENT 'Trạng thái công ty — từ Public Company Dimension',
    classification_business_line_nm      Nullable(String)        COMMENT 'Tên ngành (đệm sẵn) — từ Public Company Dimension',
    public_company_english_nm            Nullable(String)        COMMENT 'Tên công ty tiếng Anh — từ Public Company Dimension',
    enterprise_tp_code                   Nullable(String)        COMMENT 'Loại hình doanh nghiệp — từ Public Company Dimension',
    public_company_tp_code               Nullable(String)        COMMENT 'Loại công ty đại chúng — từ Public Company Dimension',
    head_office_province_nm              Nullable(String)        COMMENT 'Tỉnh/TP trụ sở chính — từ Public Company Dimension',
    operating_status_code                Nullable(String)        COMMENT 'Trạng thái hoạt động doanh nghiệp — từ Public Company Dimension',
    has_state_ownership_indicator        Nullable(Int64)         COMMENT 'Cờ có vốn nhà nước — từ Public Company Dimension',
    charter_capital_amt                  Nullable(Decimal(23,2)) COMMENT 'Vốn điều lệ — từ Public Company Dimension',
    first_registration_dt                Nullable(Date)          COMMENT 'Ngày đăng ký lần đầu — từ Public Company Dimension',
    latest_registration_dt               Nullable(Date)          COMMENT 'Ngày đăng ký thay đổi gần nhất — từ Public Company Dimension',
    latest_registration_province_nm      Nullable(String)        COMMENT 'Tỉnh/TP đăng ký thay đổi gần nhất — từ Public Company Dimension',
    ids_registration_indicator           Nullable(Int64)         COMMENT 'Trạng thái đăng ký IDS — từ Public Company Dimension',
    public_company_form_code             Nullable(String)        COMMENT 'Hình thức trở thành công ty đại chúng — từ Public Company Dimension',
    former_state_owned_indicator         Nullable(Int64)         COMMENT 'Doanh nghiệp nhà nước (trước đây) — từ Public Company Dimension',
    foreign_direct_investment_indicator  Nullable(Int64)         COMMENT 'Doanh nghiệp FDI — từ Public Company Dimension',
    has_parent_company_indicator         Nullable(Int64)         COMMENT 'Có công ty mẹ — từ Public Company Dimension',
    has_subsidiary_indicator             Nullable(Int64)         COMMENT 'Có công ty con — từ Public Company Dimension',
    has_joint_venture_indicator          Nullable(Int64)         COMMENT 'Có liên doanh — từ Public Company Dimension',
    ipo_company_indicator                Nullable(Int64)         COMMENT '1-Công ty đang IPO, 0-Công ty đại chúng — từ Public Company Dimension',
    public_company_src_stm_code          Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Public Company Dimension',

    -- From: INDEX CONSTITUENT DIMENSION
    index_code                          Nullable(String)        COMMENT 'Mã rổ chỉ số — từ Index Constituent Dimension',
    index_id                            Nullable(String)        COMMENT 'Id chỉ số — từ Index Constituent Dimension',
    index_constituent_floor_code        Nullable(String)        COMMENT 'Mã sàn (rổ chỉ số) — từ Index Constituent Dimension',
    add_dt                              Nullable(Date)          COMMENT 'Ngày thêm vào rổ chỉ số — từ Index Constituent Dimension',
    index_constituent_src_stm_code      Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Index Constituent Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), security_trading_snpst_dim_id)
COMMENT 'Flat table — Fact Stock Portfolio Snapshot × Calendar Date × Security Trading Snapshot Dimension × Public Company Dimension × Index Constituent Dimension'
;


-- ============================================================
-- 2. FACT: gstt_fct_market_index_intraday_flat
--    Diễn biến chỉ số thị trường realtime trong ngày — 1 row / chỉ số thị trường
--    (market_code) / Index Time — KHÔNG lọc rn=1 (khác Fact EOD fct_market_index_snpst)
--    Grain: Transaction/Tick log — nhiều dòng/ngày theo Index Time, có thể append
--    thêm tick mới trong cùng ngày khi ETL chạy nhiều lần/ngày
--    Joins: Calendar Date (cdr_dt_dim_id JOIN) × Market Index Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_fct_market_index_intraday_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Market Index Intraday
    market_index_dim_id                 String                  COMMENT 'FK → Market Index Dimension',
    cdr_dt_dim_id                       String                  COMMENT 'FK → Calendar Date Dimension',
    index_time                          Nullable(String)        COMMENT 'Thời gian ghi nhận chỉ số trong ngày (DD — grain component)',
    market_index_val_at_time            Nullable(Decimal(23,2)) COMMENT 'Điểm chỉ số tại thời điểm ghi nhận',
    total_val_at_time                   Nullable(Decimal(23,2)) COMMENT 'Giá trị giao dịch phát sinh tại thời điểm ghi nhận',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)          COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',

    -- From: MARKET INDEX DIMENSION
    market_id                           Nullable(String)        COMMENT 'Mã thị trường — từ Market Index Dimension',
    market_code                         Nullable(String)        COMMENT 'Mã sàn/chỉ số (HOSE/HNX/UPCOM/30) — từ Market Index Dimension',
    index_tp_code                       Nullable(String)        COMMENT 'Loại chỉ số — từ Market Index Dimension',
    tsc_product_group_id                Nullable(String)        COMMENT 'Mã sản phẩm giao dịch (HOSE/HNX/UPCOM) — từ Market Index Dimension',
    market_status_code                  Nullable(String)        COMMENT 'Trạng thái phiên (current-state SCD4A) — từ Market Index Dimension',
    market_index_src_stm_code           Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Market Index Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), market_index_dim_id, index_time)
COMMENT 'Flat table — Fact Market Index Intraday × Calendar Date Dimension × Market Index Dimension'
;


-- ============================================================
-- Sửa 2026-08-03 (redesign Nhóm 45/48): `Fact Public Company Shareholding` và
-- `Legal Entity Dimension` đã loại khỏi HLD — 6/8 KPI Nhóm 45 PENDING theo gating
-- "Chưa có CSDL - Map biểu mẫu" (BM8/BM70), không còn measure nào READY thuộc Fact.
-- 2 KPI READY còn lại (K_GSTT_100, K_GSTT_104) đều là thuộc tính Dimension thuần,
-- không qua Fact — flat table chỉ tạo cho Fact/Operational, KHÔNG tạo bảng flat
-- riêng cho Dimension độc lập. Do đó Nhóm 45/48 KHÔNG có bảng flat nào ở giai đoạn
-- này (K_GSTT_100 dùng trực tiếp `public_company_dim` qua Nhóm 1; K_GSTT_104 dùng
-- trực tiếp `legal_entity_position_dim` — không có flat riêng).
-- ============================================================
