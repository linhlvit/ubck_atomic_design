-- ============================================================
-- NDTNN Flat Tables — CREATE
-- Module: Nhà Đầu Tư Nước Ngoài — NDTNN
-- Generated: Phase 3 LLD Datamart
-- 7 bảng: 5 fact + 2 operational
-- (Nhóm 5 dùng Fact riêng fct_foreign_net_flow_market_index_snpst từ 2026-09-24 — không còn reuse Fact Market Index Snapshot của QLKD)
-- Sửa 2026-10-16: ndtnn_foreign_investor_trading_statistics_rpt_flat thêm giá trị security_tp_group = 'WARRANT' (chỉ đổi COMMENT, không đổi cột);
--   ndtnn_fct_securities_foreign_trading_snpst_flat không đổi cấu trúc (stock_tp_code đã có để BI lọc cổ phiếu '2')
-- Sửa 2026-10-17: ndtnn_fct_securities_foreign_trading_snpst_flat không đổi cấu trúc (Fact bỏ trái phiếu, stock_tp_code còn '2','3','6','4'); ndtnn_foreign_investor_trading_detail_rpt_flat chỉ đổi COMMENT report_dt (Ngày giao dịch — K_NDTNN_266)
-- Sửa 2026-10-20: ndtnn_foreign_investor_trading_detail_rpt_flat thêm dòng TPCP (Bond Order Book HNX OUTRIGHT/REPO/REPO2) — không thêm cột;
--   ORDER BY thêm src_stm_code (grain mới 5 thành phần) → bảng đã deploy phải DROP + CREATE lại rồi nạp lại lịch sử (O_NDTNN_50)
-- Sửa 2026-10-23: ndtnn_foreign_investor_trading_statistics_rpt_flat — chỉ đổi giá trị security_tp_group (bỏ 'BOND', thêm BOND_LISTED/BOND_GOVT/BOND_PRIVATE; 7 giá trị), KHÔNG đổi cột/ORDER BY (O_NDTNN_54);
--   dev phải nạp lại lịch sử (02_populate DELETE theo report_dt rồi INSERT) để xóa dòng 'BOND' cũ và sinh dòng BOND_LISTED/BOND_GOVT/BOND_PRIVATE
-- ============================================================

-- ============================================================
-- 1. FACT: ndtnn_fct_securities_foreign_trading_snpst_flat
--    Fact Securities Foreign Trading Snapshot
--    Joins: Calendar Date × Securities Dimension × Public Company Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.ndtnn_fct_securities_foreign_trading_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Securities Foreign Trading Snapshot
    snpst_dt_dim_id                 String                  COMMENT 'FK ngày giao dịch',
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
    trading_time                    Nullable(String)         COMMENT '[MỚI 2026-09-22] Thời gian ghi nhận snapshot (dùng đối chiếu MAX theo Stock Type Code khi ETL) — từ Securities Dimension',
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
    security_tp_group               String                  COMMENT 'Nhóm loại CK — Classification Value nội bộ Datamart: STOCK/BOND_LISTED/BOND_GOVT/BOND_PRIVATE/FUND_CERT/WARRANT/TOTAL (BOND_* = TPDN niêm yết / TPCP / TPDN riêng lẻ HNX09; K_NDTNN_75-77 = SUM 3 loại BOND_*)',
    buy_val                         Decimal(23,2)            COMMENT 'GT NĐTNN mua chứng khoán',
    sell_val                        Decimal(23,2)            COMMENT 'GT NĐTNN bán chứng khoán',
    total_market_val                             Decimal(23,2)           COMMENT 'Tổng giá trị giao dịch toàn thị trường (mọi nhà đầu tư, KHÔNG lọc NĐTNN) theo từng Security Type Group (7 giá trị) — mẫu số/giá trị thị trường tương ứng với buy_val/sell_val. [MỚI 2026-10-23, BA (Dũng 2026-10-23 Mã 2-4: sửa logic → lấy thêm trái phiếu → final update): K_NDTNN_3 Tổng giá trị giao dịch toàn thị trường (Mã 4) nay gồm cả TPDN niêm yết, TPDN riêng lẻ HNX09 và TPCP nên đọc dòng TOTAL của bảng này — O_NDTNN_55(2)] Phạm vi/nhóm giống buy_val: Securities Trade lấy Execution Value (bỏ điều kiện E/F), Bond Order Book lấy Trading Value (OUTRIGHT) / First Settlement Value (REPO, REPO2) của mọi dòng sổ lệnh, Internal Statistical Report (HNX09) lấy dòng row_path = GIÁ TRỊ GIAO DỊCH (tổng giá trị giao dịch; BA SQL: `tong_gtri`). Đơn vị VND như buy_val/sell_val.',
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
    report_dt                       Date                    COMMENT 'Ngày giao dịch (Ngày báo cáo)',
    account_nbr                     String                  COMMENT 'Tài khoản giao dịch NĐTNN [PII mã hóa AES-256-CBC Base64 - PA1]',
    symbol                          String                  COMMENT 'Mã CK — denormalize text trực tiếp (TPCP: mã trái phiếu bond_code)',
    trade_direction_code            String                  COMMENT 'Chiều mua/bán (BUY/SELL)',
    account_holder_nm               Nullable(String)        COMMENT 'Tên chủ tài khoản (đệm sẵn; NULL với TPCP) [PII mã hóa AES-256-CBC Base64 - PA1]',
    investor_nm                                  Nullable(String)        COMMENT '[MỚI 2026-10-21 — BA STT 15 Mã 101 tên NĐTNN] Tên nhà đầu tư nước ngoài (FIMS INVESTOR.Name) — chiều của báo cáo chi tiết. Nối theo mã số giao dịch (MSGD) = 6 ký tự cuối (UPPER/TRIM) của số tài khoản cùng phía với chiều giao dịch (SQL BA STT 15: SUBSTR(UPPER(TRIM(i.TransactionCode)), -6) = SUBSTR(UPPER(TRIM(tk)), -6)); LEFT JOIN nên NULL nếu không khớp. Khác account_holder_nm (tên chủ tài khoản trên sổ lệnh). Không thuộc grain. Xem O_NDTNN_52 [PII mã hóa AES-256-CBC Base64 - PA1]',
    execution_vol                   Int64                   COMMENT 'KL mua/bán CK',
    execution_val                   Decimal(23,2)           COMMENT 'GT mua/bán CK',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu (HOSE_TRADE_BOOK/HNX_TRADE_BOOK, HNX_OUTRIGHT/REPO/REPO2_ORDER_BOOK) — thuộc grain'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(report_dt))
ORDER BY (assumeNotNull(report_dt), account_nbr, symbol, trade_direction_code, src_stm_code)
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
    investor_nm                     String                  COMMENT 'Tên đầy đủ NĐT [PII mã hóa AES-256-CBC Base64 - PA1]',
    nationality_code                Nullable(String)        COMMENT 'Mã quốc tịch',
    nationality_nm                  Nullable(String)        COMMENT 'Tên quốc tịch (K_NDTNN_59, BA NATIONAL.Name)',
    investor_tp_code                Nullable(String)        COMMENT 'Loại hình NĐT',
    investor_tp_nm                  Nullable(String)        COMMENT 'Tên loại hình NĐT (K_NDTNN_62, BA INVESTORTYPE.Name)',
    director_nm                     Nullable(String)        COMMENT 'Đại diện giao dịch [PII mã hóa AES-256-CBC Base64 - PA1]',
    custodian_bank_nm               Nullable(String)        COMMENT 'Tên ngân hàng lưu ký (denormalize)',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu',
    investor_status_code            Nullable(String)        COMMENT 'Trạng thái hoạt động NĐTNN (proxy hiển thị ở thẻ Đại diện giao dịch)',
    investor_status_nm              Nullable(String)        COMMENT 'Tên trạng thái NĐTNN (K_NDTNN_255, BA STATUS.Name)',
    identification_nbr              Nullable(String)        COMMENT 'Số giấy tờ ĐÃ MASKED (IdNo cá nhân hoặc BusinessNumber tổ chức) — khóa nối kỹ thuật sang Lịch sử tuân thủ (Nhóm 13, so sánh =), không hiển thị [PII mã hóa AES-256-CBC Base64 - PA2]'
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
    investor_compliance_hist_code   String                  COMMENT 'PK — mã hành vi vi phạm (thiếu thì mã đối tượng bị xử phạt) — 1 đối tượng × 1 hành vi',
    subject_nm                      String                  COMMENT 'Thông tin nhà đầu tư (tên/MSGD NĐTNN) [PII mã hóa AES-256-CBC Base64 - PA1]',
    subject_id_nbr                  Nullable(String)        COMMENT 'Số giấy tờ đối tượng ĐÃ MASKED — khóa nối với identification_nbr hồ sơ 360 (Nhóm 11), không hiển thị [PII mã hóa AES-256-CBC Base64 - PA2]',
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

-- ============================================================
-- 6. FACT: ndtnn_fct_public_company_foreign_ownership_snpst_flat
--    Fact Public Company Foreign Ownership Snapshot
--    Joins: Calendar Date × Public Company Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.ndtnn_fct_public_company_foreign_ownership_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Public Company Foreign Ownership Snapshot
    snpst_dt_dim_id                 String                  COMMENT 'FK ngày snapshot',
    public_company_dim_id           Nullable(String)        COMMENT 'FK công ty đại chúng — nullable, không phải mọi mã CK đều là công ty đại chúng',
    ticker_symbol                   String                  COMMENT 'Mã chứng khoán',
    total_issued_share_quantity     Nullable(Int64)         COMMENT 'Tổng số cổ phiếu đã phát hành',
    max_foreign_ownership_ratio     Nullable(Decimal(5,2))  COMMENT 'Tỷ lệ sở hữu tối đa NĐTNN được phép (room tối đa, %)',
    max_foreign_holding_quantity    Nullable(Int64)         COMMENT 'Số lượng CP tối đa NĐTNN được phép nắm giữ',
    current_foreign_holding_quantity Nullable(Int64)        COMMENT 'Số lượng CP NĐTNN đang nắm giữ hiện tại',
    remaining_foreign_holding_quantity Nullable(Int64)      COMMENT 'Số lượng CP còn lại NĐTNN có thể mua thêm (room còn lại)',
    src_stm_code                     String                  COMMENT 'Mã hệ thống nguồn dữ liệu',
    foreign_holding_value                        Nullable(Decimal(23,2)) COMMENT 'Giá trị cổ phiếu NĐTNN đang nắm giữ (VND) = Current Foreign Holding Quantity × giá đóng cửa gần nhất ≤ ngày snapshot — tử số và mẫu số K_NDTNN_51 (tỷ trọng danh mục theo ngành, Nhóm 8). [THÊM 2026-11-03] Đặt tại Fact NDTNN để K_NDTNN_51 không đọc Fact của module GSDC; công thức giữ như cột cùng tên ở Fact Public Company Foreign Holding Snapshot (GSDC), cột đó giữ nguyên. Mã không có giá đóng cửa ≤ ngày snapshot → NULL.',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                    Nullable(Date)           COMMENT 'Ngày snapshot — từ Calendar Date Dimension',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code             Nullable(String)         COMMENT 'Mã công ty đại chúng — từ Public Company Dimension',
    equity_ticker_symbol            Nullable(String)         COMMENT 'Mã cổ phiếu — từ Public Company Dimension',
    public_company_nm               Nullable(String)         COMMENT 'Tên công ty — từ Public Company Dimension',
    equity_listing_exchange_code    Nullable(String)         COMMENT 'Sàn niêm yết — từ Public Company Dimension',
    classification_business_line_nm Nullable(String)         COMMENT 'Tên ngành (đệm sẵn) — từ Public Company Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), ticker_symbol)
COMMENT 'Flat table — Fact Public Company Foreign Ownership Snapshot × Calendar Date × Public Company Dimension'
;

-- ============================================================
-- 7. FACT: ndtnn_fct_foreign_net_flow_market_index_snpst_flat
--    Fact Foreign Net Flow Market Index Snapshot (Nhóm 5 — Tương quan Net Flow & VN-Index)
--    Joins: Calendar Date × Market Index Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.ndtnn_fct_foreign_net_flow_market_index_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Foreign Net Flow Market Index Snapshot
    snpst_dt_dim_id                 String                  COMMENT 'FK ngày giao dịch',
    market_index_dim_id             String                  COMMENT 'FK chỉ số tham chiếu (VN-Index)',
    foreign_buy_val                 Decimal(23,2)           COMMENT 'GT mua NĐTNN toàn thị trường (HOSE+HNX, VND)',
    foreign_sell_val                Decimal(23,2)           COMMENT 'GT bán NĐTNN toàn thị trường (HOSE+HNX, VND)',
    foreign_net_trading_val         Decimal(23,2)           COMMENT 'GT mua/bán ròng NĐTNN (VND) — K_NDTNN_33',
    market_index_close_val          Nullable(Decimal(23,2)) COMMENT 'Điểm đóng cửa VN-Index — K_NDTNN_34',
    foreign_net_capital_flow_mtd_amt Nullable(Decimal(23,2)) COMMENT 'Dòng tiền ròng lũy kế tháng (USD) — K_NDTNN_35, PENDING Atomic (NULL)',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                    Nullable(Date)           COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',

    -- From: MARKET INDEX DIMENSION
    market_id                       Nullable(String)         COMMENT 'Mã thị trường — từ Market Index Dimension',
    market_code                     Nullable(String)         COMMENT 'Mã chỉ số — từ Market Index Dimension',
    index_nm                        Nullable(String)         COMMENT 'Tên chỉ số — từ Market Index Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), market_index_dim_id)
COMMENT 'Flat table — Fact Foreign Net Flow Market Index Snapshot × Calendar Date × Market Index Dimension'
;

-- ============================================================
-- 8. FACT: ndtnn_fct_foreign_investor_report_value_flat
--    Giá trị ô báo cáo động FIMS (EAV) — Nhóm 1/3/5 và Data Explorer 18–43
--    Grain: 1 ô × 1 lần nộp × 1 dòng động
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.ndtnn_fct_foreign_investor_report_value_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Foreign Investor Report Value
    submission_dt_dim_id                       String                     COMMENT 'FK to Calendar Date Dimension — ngày THỰC TẾ nộp báo cáo (BA: ngay_nop), khác kỳ báo cáo',
    foreign_investor_report_structure_dim_id   String                     COMMENT 'FK to Foreign Investor Report Structure Dimension — ô template (báo cáo/sheet/dòng/cột)',
    rpt_log_id                                 Nullable(String)           COMMENT 'Mã LẦN NỘP (REPORT_LOG_ID) — lọc toàn bộ số liệu của 1 lần nộp',
    dynamic_row_order                          Int32                      COMMENT 'Thứ tự dòng trong band động; 0 = ô tĩnh',
    period_tp_code                             Nullable(String)           COMMENT 'Loại kỳ báo cáo (THANG, QUY, NAM…) — BA: Kỳ báo cáo',
    period_val                                 Nullable(String)           COMMENT 'Giá trị kỳ báo cáo (VD T09/2026) — BA: Tháng',
    rpt_year                                   Nullable(Int32)            COMMENT 'Năm báo cáo',
    submission_status_code                     Nullable(String)           COMMENT 'Nhãn nộp đúng hạn/trễ hạn',
    late_duration                              Nullable(Int32)            COMMENT 'Thời lượng nộp trễ',
    total_row_ind                              Nullable(Int32)            COMMENT '1 = ô thuộc dòng TỔNG (BA: is_total_row)',
    section_echo_ind                           Nullable(Int32)            COMMENT '1 = ô lặp lại section (BA: is_section_echo)',
    band_overflow_ind                          Nullable(Int32)            COMMENT '1 = ô tràn band (BA: is_band_overflow)',
    static_copy_ind                            Nullable(Int32)            COMMENT '1 = ô sao chép tĩnh (BA: is_static_copy)',
    rpt_marker_ind                             Nullable(Int32)            COMMENT '1 = ô đánh dấu template (BA: is_template_marker)',
    val_raw                                    Nullable(String)           COMMENT 'Giá trị gốc nguồn nộp (BA: value_raw)',
    src_stm_code                               String                     COMMENT 'Mã hệ thống nguồn',

    -- From: CALENDAR DATE DIMENSION
    submission_cdr_dt                          Nullable(Date)             COMMENT 'Ngày nộp báo cáo — từ Calendar Date Dimension',

    -- From: FOREIGN INVESTOR REPORT STRUCTURE DIMENSION
    structure_code                             Nullable(String)           COMMENT 'Mã ô cấu trúc — từ Foreign Investor Report Structure Dimension',
    rpt_code                                   Nullable(String)           COMMENT 'Mã báo cáo — từ Foreign Investor Report Structure Dimension',
    rpt_nm                                     Nullable(String)           COMMENT 'Tên báo cáo — từ Foreign Investor Report Structure Dimension',
    report_type_nm                             Nullable(String)           COMMENT 'Loại báo cáo (Định kỳ/Bất thường) — từ Foreign Investor Report Structure Dimension',
    legal_basis                                Nullable(String)           COMMENT 'Căn cứ pháp lý — từ Foreign Investor Report Structure Dimension',
    sheet_code                                 Nullable(String)           COMMENT 'Mã sheet — từ Foreign Investor Report Structure Dimension',
    sheet_nm                                   Nullable(String)           COMMENT 'Tên sheet — từ Foreign Investor Report Structure Dimension',
    section_id                                 Nullable(String)           COMMENT 'Mã section — từ Foreign Investor Report Structure Dimension',
    row_path                                   Nullable(String)           COMMENT 'Nhãn dòng — từ Foreign Investor Report Structure Dimension',
    column_path                                Nullable(String)           COMMENT 'Nhãn cột — từ Foreign Investor Report Structure Dimension',
    data_tp                                    Nullable(String)           COMMENT 'Kiểu dữ liệu ô — từ Foreign Investor Report Structure Dimension',

    -- [MỚI 2026-10-05] đặt CUỐI để khớp ALTER TABLE ADD COLUMN; khóa nghiệp vụ SHEET_ID ‖ INDICATOR_UID (structure_code chỉ duy nhất trong 1 sheet)
    fir_structure_code                         Nullable(String)           COMMENT 'Mã ô cấu trúc = SHEET_ID ‖ INDICATOR_UID — từ Foreign Investor Report Structure Dimension',

    -- [MỚI 2026-10-13] Ngày báo cáo (role-playing Calendar Date Dimension, nullable) — đặt CUỐI để khớp ALTER TABLE ADD COLUMN
    rpt_dt_dim_id                              Nullable(String)           COMMENT 'FK to Calendar Date Dimension (Role-Playing: Report Date) — ngày chốt số liệu của báo cáo (FIMS DayReport), khác ngày nộp; NULL khi nguồn không có',
    rpt_cdr_dt                                 Nullable(Date)             COMMENT 'Ngày báo cáo (ngày chốt số liệu) — từ Calendar Date Dimension (role Report Date)'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(submission_cdr_dt))
ORDER BY (assumeNotNull(submission_cdr_dt), assumeNotNull(rpt_log_id), foreign_investor_report_structure_dim_id, dynamic_row_order)
COMMENT 'Flat table — Fact Foreign Investor Report Value × Calendar Date Dimension × Foreign Investor Report Structure Dimension'
;

-- ============================================================
-- 9. FACT: ndtnn_fct_foreign_investor_capital_flow_snpst_flat
--    Dòng vốn ròng theo quốc tịch / nhà đầu tư (PLIV-TT51) — Nhóm 4, 16
--    Grain: 1 dòng báo cáo IBOU9 sheet I
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.ndtnn_fct_foreign_investor_capital_flow_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Foreign Investor Capital Flow Snapshot
    snpst_dt_dim_id                            String                     COMMENT 'FK to Calendar Date Dimension — ngày snapshot = ngày thực tế nộp báo cáo (BA: ngay_nop)',
    rpt_log_id                                 Nullable(String)           COMMENT 'Mã LẦN NỘP (REPORT_LOG_ID)',
    section_id                                 Nullable(String)           COMMENT 'Mã section (band) chứa dòng',
    dynamic_row_order                          Int32                      COMMENT 'Thứ tự dòng trong band động (BA: row_order)',
    period_val                                 Nullable(String)           COMMENT 'Giá trị kỳ báo cáo (VD T09/2026) — BA Data Explorer: Tháng (RPTMEMBER.PeriodValue)',
    nationality_nm                             Nullable(String)           COMMENT 'Quốc tịch NĐTNN (cột Quốc tịch — PLIV-TT51, báo cáo IBOU9 sheet I)',
    investor_nm                                Nullable(String)           COMMENT 'Tên nhà đầu tư (cột Tên nhà đầu tư) [PII mã hóa AES-256-CBC Base64 - PA1]',
    capital_flow_net_val                       Nullable(Decimal(23,2))    COMMENT 'Giá trị dòng vốn vào ròng trong kỳ báo cáo (+/-), đơn vị USD (cột Giá trị dòng vốn vào trong kỳ báo cáo (+/-) (đơn vị USD))',
    src_stm_code                               String                     COMMENT 'Mã hệ thống nguồn',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                               Nullable(Date)             COMMENT 'Ngày nộp báo cáo — từ Calendar Date Dimension',

    -- [MỚI 2026-10-13] đặt CUỐI để khớp ALTER TABLE ADD COLUMN
    rpt_code                                   Nullable(String)           COMMENT 'Mã báo cáo (IBOU9 — PLIV-TT51, sheet I)',
    rpt_dt_dim_id                              Nullable(String)           COMMENT 'FK to Calendar Date Dimension (Role-Playing: Report Date) — ngày chốt số liệu của báo cáo (FIMS DayReport), khác ngày snapshot = ngày nộp; NULL khi nguồn không có',
    rpt_cdr_dt                                 Nullable(Date)             COMMENT 'Ngày báo cáo (ngày chốt số liệu) — từ Calendar Date Dimension (role Report Date)'

)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), assumeNotNull(rpt_log_id), assumeNotNull(section_id), dynamic_row_order)
COMMENT 'Flat table — Fact Foreign Investor Capital Flow Snapshot × Calendar Date Dimension'
;

-- ============================================================
-- 10. FACT: ndtnn_fct_foreign_investor_portfolio_report_snpst_flat
--    Danh mục NĐTNN theo loại tài sản (PLIII-TT51) — Nhóm 4, 6, 7, 17
--    Grain: 1 dòng báo cáo 59WJB/BZ5X4 sheet II
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.ndtnn_fct_foreign_investor_portfolio_report_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Foreign Investor Portfolio Report Snapshot
    snpst_dt_dim_id                            String                     COMMENT 'FK to Calendar Date Dimension — ngày snapshot = ngày thực tế nộp báo cáo (BA: ngay_nop)',
    rpt_log_id                                 Nullable(String)           COMMENT 'Mã LẦN NỘP (REPORT_LOG_ID)',
    section_id                                 Nullable(String)           COMMENT 'Mã section (band) chứa dòng',
    dynamic_row_order                          Int32                      COMMENT 'Thứ tự dòng trong band động (BA: row_order)',
    period_val                                 Nullable(String)           COMMENT 'Giá trị kỳ báo cáo (VD T09/2026) — BA Data Explorer: Tháng (RPTMEMBER.PeriodValue)',
    rpt_code                                   Nullable(String)           COMMENT 'Mã báo cáo (59WJB: CTCK; BZ5X4: ngân hàng lưu ký — PLIII-TT51)',
    investor_group_nm                          Nullable(String)           COMMENT 'Nhóm nhà đầu tư theo nhãn dòng: A-Tổ chức / B-Cá nhân',
    nationality_nm                             Nullable(String)           COMMENT 'Quốc tịch (cột Quốc tịch)',
    investor_type_nm                           Nullable(String)           COMMENT 'Loại hình đối với tổ chức (cột Loại hình đối với tổ chức)',
    investor_nm                                Nullable(String)           COMMENT 'Tên khách hàng (cột Tên khách hàng) [PII mã hóa AES-256-CBC Base64 - PA1]',
    bill_val                                   Nullable(Decimal(23,2))    COMMENT 'Giá trị tín phiếu (cột Tín phiếu > Giá trị)',
    bond_val                                   Nullable(Decimal(23,2))    COMMENT 'Giá trị trái phiếu = tổng 3 kỳ hạn còn lại (<12 tháng, 12–24 tháng, >24 tháng)',
    listed_equity_fund_val                     Nullable(Decimal(23,2))    COMMENT 'Giá trị cổ phiếu niêm yết, chứng chỉ quỹ niêm yết',
    upcom_equity_val                           Nullable(Decimal(23,2))    COMMENT 'Giá trị cổ phiếu công ty đại chúng đăng ký giao dịch (UPCoM)',
    capital_contribution_val                   Nullable(Decimal(23,2))    COMMENT 'Giá trị vốn góp, mua cổ phần, quỹ thành viên và chứng khoán khác',
    cash_equivalent_val                        Nullable(Decimal(23,2))    COMMENT 'Giá trị tiền và các khoản tương đương tiền',
    total_portfolio_val                        Nullable(Decimal(23,2))    COMMENT 'Tổng giá trị danh mục (cột Tổng giá trị danh mục > Giá trị) — không gồm dòng tổng (ETL Fact lọc total_row_ind = 0)',
    individual_ind                             Nullable(Int32)            COMMENT '1 = nhà đầu tư cá nhân (BA: row_path = B-Cá nhân)',
    fund_ind                                   Nullable(Int32)            COMMENT '1 = tổ chức là quỹ (BA: row_path = A-Tổ chức AND loại hình LIKE %Quỹ% AND NOT LIKE %Không phải quỹ%)',
    non_fund_org_ind                           Nullable(Int32)            COMMENT '1 = tổ chức khác quỹ (BA: A-Tổ chức AND loại hình LIKE Công ty/Ngân hàng/Tổ chức/Không phải quỹ/Các loại khác). Điều kiện của BA KHÔNG loại ',
    foreign_bank_branch_ind                      Nullable(Int64)         COMMENT '1 = chi nhánh ngân hàng nước ngoài (BA Mã 47 — chưa có SQL; GIẢ ĐỊNH: A-Tổ chức AND loại hình LIKE %Ngân hàng%). Tập con của non_fund_org_ind — xem O_NDTNN_46',
    transaction_cd                               Nullable(String)        COMMENT 'Mã số giao dịch chứng khoán của NĐT trong báo cáo — 6 ký tự cuối, in hoa (BA Nhóm 12 Mã 74: SUBSTR(UPPER(TRIM(value_raw)), -6), cột Mã số giao dịch chứng khoán). column_path theo SQL BA, chờ xác nhận — O_NDTNN_47',
    src_stm_code                               String                     COMMENT 'Mã hệ thống nguồn',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                               Nullable(Date)             COMMENT 'Ngày nộp báo cáo — từ Calendar Date Dimension',

    -- [MỚI 2026-11-14, O_NDTNN_60] đặt CUỐI để khớp ALTER TABLE ADD COLUMN
    rpt_dt_dim_id                                Nullable(String)        COMMENT 'FK to Calendar Date Dimension (Role-Playing: Report Date) — ngày báo cáo (BA STT 6/7 từ 2026-11-13: day_report = :ngaybc; FIMS RPTMEMBER.DayReport → fir_value.rpt_day), khác ngày nộp (snpst_dt_dim_id) và khác kỳ báo cáo (period_val). Nullable khi lần nộp không có DayReport. Nhóm 6/7 lọc theo cột này; Nhóm 4/12/17 vẫn lọc theo snpst_dt_dim_id. [MỚI 2026-11-14, O_NDTNN_60]',
    asset_class_total_val                        Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị 6 nhóm tài sản của dòng báo cáo = tín phiếu + trái phiếu (3 kỳ hạn) + CP/CCQ niêm yết + UPCoM + vốn góp + tiền (NULL tính 0). SQL BA mới của STT 6/7 (2026-11-13) cộng 8 column_path thành phần (c_gtri_danh_muc) thay vì đọc cột tổng Tổng giá trị danh mục > Giá trị (total_portfolio_val, giữ nguyên cho Nhóm 4/12/17 và K_NDTNN_41/42). [MỚI 2026-11-14, O_NDTNN_60]',
    rpt_cdr_dt                                 Nullable(Date)             COMMENT 'Ngày báo cáo (ngày chốt số liệu) — từ Calendar Date Dimension (role Report Date)'

)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), assumeNotNull(rpt_log_id), assumeNotNull(section_id), dynamic_row_order)
COMMENT 'Flat table — Fact Foreign Investor Portfolio Report Snapshot × Calendar Date Dimension'
;


-- ==========================================================
-- 11. FACT: ndtnn_fct_foreign_bank_branch_portfolio_report_snpst_flat
--    Số dư cuối kỳ danh mục của chi nhánh ngân hàng nước ngoài (sheet III báo cáo PLIII-TT51 59WJB) — Nhóm 6 (K_NDTNN_265), Nhóm 7 (thành phần sheet III)
--    Grain: 1 ô 'Số dư cuối kỳ > Giá trị' của 1 dòng tài sản × 1 lần nộp; PK fir_val_id (Dạng A, id dòng Atomic fir_value)
--    [MỚI 2026-11-14, O_NDTNN_60] BI Nhóm 6/7 lọc theo rpt_cdr_dt (ngày báo cáo, BA day_report), KHÔNG phải snpst_cdr_dt (ngày nộp)
-- ==========================================================
CREATE TABLE IF NOT EXISTS datamart.ndtnn_fct_foreign_bank_branch_portfolio_report_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Foreign Bank Branch Portfolio Report Snapshot
    fir_val_id                                   String                  COMMENT 'PK — id dòng Atomic driving fir_value.fir_val_id (Dạng A, A22). Grain = 1 ô Số dư cuối kỳ > Giá trị của 1 dòng',
    snpst_dt_dim_id                              String                  COMMENT 'FK to Calendar Date Dimension — ngày snapshot = ngày thực tế nộp báo cáo (BA: ngay_nop)',
    rpt_dt_dim_id                                Nullable(String)        COMMENT 'FK to Calendar Date Dimension (Role-Playing: Report Date) — ngày báo cáo (BA STT 6/7: day_report = :ngaybc; FI',
    rpt_log_id                                   Nullable(String)        COMMENT 'Mã LẦN NỘP (REPORT_LOG_ID)',
    period_val                                   Nullable(String)        COMMENT 'Giá trị kỳ báo cáo (VD T09/2026) — BA: Tháng',
    rpt_code                                     Nullable(String)        COMMENT 'Mã báo cáo — luôn 59WJB (PLIII-TT51, báo cáo của CTCK) theo BA STT 6/7: chi nhánh ngân hàng nước ngoài chỉ lấy',
    asset_group_nm                               Nullable(String)        COMMENT 'Đường dẫn dòng tài sản của sheet III (row_path), VD A. Tín phiếu, B. Trái phiếu > B1.…, C. Cổ phiếu niêm yết, ',
    closing_balance_val                          Nullable(Decimal(23,2)) COMMENT 'Số dư cuối kỳ (cột Số dư cuối kỳ > Giá trị) của dòng tài sản — K_NDTNN_265 = SUM toàn bộ dòng (SQL BA STT 6 kh',
    src_stm_code                                 String                  COMMENT 'Mã hệ thống nguồn',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                               Nullable(Date)             COMMENT 'Ngày nộp báo cáo — từ Calendar Date Dimension',
    rpt_cdr_dt                                 Nullable(Date)             COMMENT 'Ngày báo cáo (ngày chốt số liệu) — từ Calendar Date Dimension (role Report Date)'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), fir_val_id)
COMMENT 'Flat table — Fact Foreign Bank Branch Portfolio Report Snapshot × Calendar Date Dimension'
;


-- ==========================================================
-- 12. OPERATIONAL: ndtnn_opr_fir_structure_flat
--    opr_fir_structure — sinh tự động từ master registry + Entities.csv
--    Joins: không JOIN dimension
-- ==========================================================
CREATE TABLE IF NOT EXISTS datamart.ndtnn_opr_fir_structure_flat ON CLUSTER 'my_cluster'
(
    -- From: OPR_FIR_STRUCTURE
    fir_structure_id                             String                  COMMENT 'PK — id Atomic fir_structure.fir_structure_id. Bản sao 1:1 (Operational) của Atomic `fir_structure` (SCD2) phụ',
    fir_structure_code                           String                  COMMENT 'Mã nghiệp vụ ô chỉ tiêu = SHEET_ID || INDICATOR_UID. BK.',
    src_stm_code                                 String                  COMMENT 'Mã hệ thống nguồn dữ liệu.',
    structure_code                               String                  COMMENT 'Mã định danh ô template (INDICATOR_UID) — sinh từ tọa độ ô trong cellsMeta, duy nhất trong 1 sheet.',
    fir_id                                       Nullable(String)        COMMENT 'FK → Foreign Investor Report: sheet chứa ô chỉ tiêu.',
    fir_code                                     Nullable(String)        COMMENT 'Mã sheet (SHEET_ID).',
    rpt_id                                       Nullable(String)        COMMENT 'Mã kỹ thuật mẫu báo cáo nguồn (RPT_ID).',
    row_index                                    Nullable(Int64)         COMMENT 'Vị trí dòng 0-based trong template (SHEET_ROW). Excel_row = Row Index + 1.',
    column_index                                 Nullable(Int64)         COMMENT 'Vị trí cột 0-based trong template (SHEET_COL).',
    data_tp                                      Nullable(String)        COMMENT 'Kiểu dữ liệu nguồn khai cho ô (FORMAT_DATA_TYPE): numberic, percentage, string...',
    row_path                                     Nullable(String)        COMMENT 'Đường dẫn CHA→CON của dòng, nối bằng " > " — tên nhóm chỉ tiêu hiển thị trên Data Explorer.',
    column_path                                  Nullable(String)        COMMENT 'Đường dẫn header của cột (VD "Kỳ báo cáo").',
    section_id                                   Nullable(String)        COMMENT 'Mã vùng dữ liệu (section) chứa ô.',
    section_tp_code                              Nullable(String)        COMMENT 'Loại vùng dữ liệu: DYNAMIC (nhiều dòng) hay NULL (dòng cố định).',
    dynamic_ind                                  Nullable(Int64)         COMMENT '1 = ô thuộc band/slot động (IS_DYNAMIC_SLOT).',
    last_band_ind                                Nullable(Int64)         COMMENT '1 = band động cuối cùng trong nhóm (IS_GROUP_LAST_BAND) — nhận diện dữ liệu thật vs bản sao lỗi nguồn.',
    total_row_ind                                Nullable(Int64)         COMMENT '1 = dòng TỔNG, không phải dòng nhập liệu chi tiết.',
    ordinal_column_ind                           Nullable(Int64)         COMMENT '1 = cột số thứ tự (STT), không phải chỉ tiêu nghiệp vụ.',
    data_explorer_id                             Nullable(String)        COMMENT 'Mã chỉ tiêu dùng trên Data Explorer (ITEM_ID) = MD5(REPORT_CODE + LEGAL_BASIS + SHEET_NAME + ROW_PATH + COLUMN',
    sort_order                                   Nullable(Int64)         COMMENT 'Thứ tự hiển thị trên UI.',
    excluded_by_config_ind                       Nullable(Int64)         COMMENT '1 = dòng bị loại khỏi cây chỉ tiêu do khai drop: true trong file cấu hình đè.',
    override_src                                 Nullable(String)        COMMENT 'Nguồn cấu hình đè đã sửa dòng: "<tên file>.yaml#<excel_row>".',
    ds_rcrd_st                                   String                  COMMENT 'Trạng thái bản ghi — bản sao chỉ chứa bản ghi hiện hành của Atomic nên luôn ACTIVE (job FIMS vẫn lọc ds_rcrd_s',
    ds_rcrd_isrt_dt                              Date                    COMMENT 'Ngày chèn bản ghi vào Datamart',
    ds_rcrd_udt_dt                               Date                    COMMENT 'Ngày cập nhật bản ghi gần nhất trong Datamart',
    ds_rcrd_end_dt                               String                  COMMENT 'Ngày hết hiệu lực bản ghi (SCD2), dạng chuỗi yyyy-mm-dd vì ClickHouse Date không biểu diễn được 2400-01-01 — bản ghi hiện hành luôn 2400-01-01',
    ds_etl_pcs_tms                               DateTime                COMMENT 'Thời điểm ETL ghi dòng'
)
ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (fir_structure_id)
COMMENT 'Flat table — opr_fir_structure — sinh tự động từ master registry + Entities.csv'
;


-- ==========================================================
-- 13. OPERATIONAL: ndtnn_opr_fir_value_flat
--    opr_fir_value — sinh tự động từ master registry + Entities.csv
--    Joins: không JOIN dimension
-- ==========================================================
CREATE TABLE IF NOT EXISTS datamart.ndtnn_opr_fir_value_flat ON CLUSTER 'my_cluster'
(
    -- From: OPR_FIR_VALUE
    fir_val_id                                   String                  COMMENT 'PK — id Atomic fir_value.fir_val_id. Bản sao 1:1 (Operational) của Atomic `fir_value` (Upsert) phục vụ Data Ex',
    fir_val_code                                 String                  COMMENT 'Mã nghiệp vụ ô giá trị = REPORT_LOG_ID || SHEET_ID || INDICATOR_UID || ROW_ORDER. BK.',
    src_stm_code                                 String                  COMMENT 'Mã hệ thống nguồn dữ liệu.',
    fir_structure_id                             Nullable(String)        COMMENT 'FK → Foreign Investor Report Structure: ô chỉ tiêu template tương ứng.',
    fir_structure_code                           Nullable(String)        COMMENT 'Mã ô chỉ tiêu = SHEET_ID || INDICATOR_UID.',
    structure_code                               Nullable(String)        COMMENT 'Mã định danh ô template (INDICATOR_UID).',
    rpt_log_id                                   Nullable(String)        COMMENT 'Mã LẦN NỘP cụ thể (REPORT_LOG_ID = RPTMEMBER.ID) — dùng để lọc toàn bộ số liệu của 1 lần nộp.',
    rpt_id                                       Nullable(String)        COMMENT 'Mã kỹ thuật mẫu báo cáo nguồn (RPT_ID).',
    fir_id                                       Nullable(String)        COMMENT 'FK → Foreign Investor Report: sheet chứa ô chỉ tiêu.',
    fir_code                                     Nullable(String)        COMMENT 'Mã sheet (SHEET_ID).',
    reporting_entity_tp_code                     Nullable(Int64)         COMMENT 'Loại đối tượng đã nộp báo cáo (OBJECT_TYPE).',
    reporting_entity_code                        Nullable(String)        COMMENT 'Mã định danh đối tượng đã nộp báo cáo (OBJECT_ID).',
    period_tp_code                               Nullable(String)        COMMENT 'Loại kỳ báo cáo (THANG, QUY, NAM...).',
    period_val                                   Nullable(String)        COMMENT 'Giá trị kỳ báo cáo (VD T09/2026).',
    rpt_year                                     Nullable(Int64)         COMMENT 'Năm của kỳ báo cáo (YEAR_VALUE).',
    rpt_day                                      Nullable(Date)          COMMENT 'Ngày báo cáo (DAY_REPORT).',
    submission_deadline_tms                      Nullable(DateTime)      COMMENT 'Hạn nộp báo cáo (HAN_NOP).',
    submission_status_code                       Nullable(String)        COMMENT 'Nhãn trạng thái nộp đúng hạn/trễ hạn (LATE_STATUS).',
    submission_status_tp_code                    Nullable(Int64)         COMMENT 'Mã trạng thái nộp đúng hạn/trễ hạn.',
    late_duration                                Nullable(Int64)         COMMENT 'Thời gian nộp trễ so với hạn nộp.',
    total_row_ind                                Nullable(Int64)         COMMENT '1 = ô thuộc dòng TỔNG.',
    ordinal_column_ind                           Nullable(Int64)         COMMENT '1 = ô thuộc cột số thứ tự (STT).',
    section_echo_ind                             Nullable(Int64)         COMMENT '1 = dòng nhãn của một mục bị nguồn ghi lẫn vào như dòng dữ liệu — không lên Data Explorer.',
    band_overflow_ind                            Nullable(Int64)         COMMENT '1 = band động bị tràn (nguồn cắt sai ranh giới) — không lên Data Explorer.',
    static_copy_ind                              Nullable(Int64)         COMMENT '1 = ô tĩnh của band không phải cuối nhóm, giá trị là bản sao nhầm từ band cuối — không lên Data Explorer.',
    rpt_marker_ind                               Nullable(Int64)         COMMENT '1 = ô mang giá trị "..." — chỗ đánh dấu của template, không phải dữ liệu thật.',
    dynamic_ind                                  Nullable(Int64)         COMMENT '1 = ô thuộc dòng động (IS_DYNAMIC).',
    dynamic_row_order                            Int64                   COMMENT 'Thứ tự dòng trong band động (ROW_ORDER) — 0 = ô TĨNH của band.',
    val_raw                                      Nullable(String)        COMMENT 'Giá trị gốc nguồn nộp (VALUE_RAW).',
    submission_dt                                Nullable(Date)          COMMENT 'Ngày THỰC TẾ nộp (NGAY_NOP) — khác kỳ báo cáo; partition ODS.',
    ds_rcrd_st                                   String                  COMMENT 'Trạng thái bản ghi — bản sao chỉ chứa bản ghi hiện hành của Atomic nên luôn ACTIVE (job FIMS vẫn lọc ds_rcrd_s',
    ds_rcrd_isrt_dt                              Date                    COMMENT 'Ngày chèn bản ghi vào Datamart',
    ds_rcrd_udt_dt                               Date                    COMMENT 'Ngày cập nhật bản ghi gần nhất trong Datamart',
    ds_etl_pcs_tms                               DateTime                COMMENT 'Thời điểm ETL ghi dòng'
)
ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (fir_val_id)
COMMENT 'Flat table — opr_fir_value — sinh tự động từ master registry + Entities.csv'
;


-- ==========================================================
-- 14. OPERATIONAL: ndtnn_opr_foreign_investor_report_flat
--    opr_foreign_investor_report — sinh tự động từ master registry + Entities.csv
--    Joins: không JOIN dimension
-- ==========================================================
CREATE TABLE IF NOT EXISTS datamart.ndtnn_opr_foreign_investor_report_flat ON CLUSTER 'my_cluster'
(
    -- From: OPR_FOREIGN_INVESTOR_REPORT
    fir_id                                       String                  COMMENT 'PK — id Atomic foreign_investor_report.fir_id. Bản sao 1:1 (Operational) của Atomic `foreign_investor_report` ',
    fir_code                                     String                  COMMENT 'Mã sheet của mẫu báo cáo (SHEET_ID). BK.',
    src_stm_code                                 String                  COMMENT 'Mã hệ thống nguồn dữ liệu.',
    rpt_id                                       Nullable(String)        COMMENT 'Mã kỹ thuật mẫu báo cáo nguồn (RPT_ID = RPTTEMP.ID).',
    rpt_code                                     Nullable(String)        COMMENT 'Mã mẫu báo cáo — mã KỸ THUẬT do hệ thống tự sinh (VD BZ5X4, H0I8J), không phải tên gọi tắt nghiệp vụ.',
    rpt_nm                                       Nullable(String)        COMMENT 'Tên đầy đủ của mẫu báo cáo (VD "Phụ lục III...").',
    legal_basis                                  Nullable(String)        COMMENT 'Căn cứ pháp lý (thông tư/quyết định) của mẫu báo cáo.',
    rpt_status                                   Nullable(Int64)         COMMENT 'Trạng thái mẫu báo cáo (TEMPLATE_STATUS) — ODS chỉ nạp mẫu Status = 1 (đang dùng).',
    sheet_code                                   Nullable(String)        COMMENT 'Mã sheet/tab trong mẫu báo cáo.',
    sheet_nm                                     Nullable(String)        COMMENT 'Tên sheet/tab trong mẫu (VD "I", "II", "III").',
    sheet_index                                  Nullable(Int64)         COMMENT 'Thứ tự sheet trong mẫu báo cáo.',
    ds_rcrd_st                                   String                  COMMENT 'Trạng thái bản ghi — bản sao chỉ chứa bản ghi hiện hành của Atomic nên luôn ACTIVE (job FIMS vẫn lọc ds_rcrd_s',
    ds_rcrd_isrt_dt                              Date                    COMMENT 'Ngày chèn bản ghi vào Datamart',
    ds_rcrd_udt_dt                               Date                    COMMENT 'Ngày cập nhật bản ghi gần nhất trong Datamart',
    ds_rcrd_end_dt                               String                  COMMENT 'Ngày hết hiệu lực bản ghi (SCD2), dạng chuỗi yyyy-mm-dd vì ClickHouse Date không biểu diễn được 2400-01-01 — bản ghi hiện hành luôn 2400-01-01',
    ds_etl_pcs_tms                               DateTime                COMMENT 'Thời điểm ETL ghi dòng'
)
ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (fir_id)
COMMENT 'Flat table — opr_foreign_investor_report — sinh tự động từ master registry + Entities.csv'
;


-- ==========================================================
-- 15. OPERATIONAL: ndtnn_opr_foreign_investor_reporting_entity_flat
--    opr_foreign_investor_reporting_entity — sinh tự động từ master registry + Entities.csv
--    Joins: không JOIN dimension
-- ==========================================================
CREATE TABLE IF NOT EXISTS datamart.ndtnn_opr_foreign_investor_reporting_entity_flat ON CLUSTER 'my_cluster'
(
    -- From: OPR_FOREIGN_INVESTOR_REPORTING_ENTITY
    cl_foreign_investor_reporting_entity_id      String                  COMMENT 'PK — id Atomic cl_foreign_investor_reporting_entity.cl_foreign_investor_reporting_entity_id. Bản sao 1:1 (Oper',
    cl_foreign_investor_reporting_entity_code    String                  COMMENT 'Mã nghiệp vụ duy nhất của đối tượng nộp báo cáo = OBJECT_ID || OBJECT_TYPE. BK.',
    src_stm_code                                 String                  COMMENT 'Mã hệ thống nguồn dữ liệu.',
    reporting_entity_code                        String                  COMMENT 'Mã định danh đối tượng nộp báo cáo trong hệ thống nguồn (OBJECT_ID).',
    reporting_entity_tp_code                     Nullable(String)        COMMENT 'Loại đối tượng nộp báo cáo: quỹ, công ty chứng khoán, ngân hàng lưu ký, VSDC, Sở GDCK, đại diện CBTT, CN QLQ n',
    reporting_entity_tp_nm                       Nullable(String)        COMMENT 'Tên loại đối tượng nộp báo cáo (OBJECT_TYPE_NAME).',
    entity_reference_nbr                         Nullable(String)        COMMENT 'Mã tra cứu đối tượng (OBJECT_CODE): regno/taxcode/certno/transactioncode tùy loại; riêng "Đại diện giao dịch" ',
    reporting_entity_nm                          Nullable(String)        COMMENT 'Tên đầy đủ đối tượng nộp báo cáo (OBJECT_NAME).',
    reporting_entity_short_nm                    Nullable(String)        COMMENT 'Tên viết tắt đối tượng nộp báo cáo (OBJECT_SHORT_NAME).',
    ds_rcrd_st                                   String                  COMMENT 'Trạng thái bản ghi — bản sao chỉ chứa bản ghi hiện hành của Atomic nên luôn ACTIVE (job FIMS vẫn lọc ds_rcrd_s',
    ds_rcrd_isrt_dt                              Date                    COMMENT 'Ngày chèn bản ghi vào Datamart',
    ds_rcrd_udt_dt                               Date                    COMMENT 'Ngày cập nhật bản ghi gần nhất trong Datamart',
    ds_rcrd_end_dt                               String                  COMMENT 'Ngày hết hiệu lực bản ghi (SCD2), dạng chuỗi yyyy-mm-dd vì ClickHouse Date không biểu diễn được 2400-01-01 — bản ghi hiện hành luôn 2400-01-01',
    ds_etl_pcs_tms                               DateTime                COMMENT 'Thời điểm ETL ghi dòng'
)
ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (cl_foreign_investor_reporting_entity_id)
COMMENT 'Flat table — opr_foreign_investor_reporting_entity — sinh tự động từ master registry + Entities.csv'
;


-- ============================================================
-- 16. OPERATIONAL: ndtnn_opr_foreign_investor_report_explorer_val_flat
--    Bảng dữ liệu khai thác Data Explorer NDTNN (báo cáo động FIMS) — thay default.bc_fims của job fims_ods_to_clickhouse.
--    Nguồn: opr_fir_value ⋈ opr_fir_structure ⋈ opr_foreign_investor_report (INNER) + opr_foreign_investor_reporting_entity (LEFT)
--    — logic theo FIMS_MART_TO_CLICKHOUSE_MAPPING.md §2–§3: không lọc lại (đã lọc ở Atomic), chỉ nối 4 bảng + đổi tên cột; giữ nguyên văn val_raw.
--    Nạp theo ngày nộp: DELETE rồi INSERT lại các dòng có submission_dt = :etl_date — [MỚI 2026-11-14, O_NDTNN_61] (O_NDTNN_61)
--    Bảng đích KHÔNG có cột entity_code (khác bản đề xuất 2026-11-13). Tên cột chung với QLQ để BI Data Explorer dùng chung.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.ndtnn_opr_foreign_investor_report_explorer_val_flat ON CLUSTER 'my_cluster'
(
    period_end_dt                                Date                    COMMENT 'Ngày của dòng dữ liệu = NGÀY BÁO CÁO (opr_fir_value.rpt_day, FIMS DayReport); trống thì lấy ngày nộp (bc_fims.date cũ)',
    object_id                                    String                  COMMENT 'Mã định danh đối tượng nộp báo cáo (reporting_entity_code); trống → rỗng',
    object_nm                                    String                  COMMENT 'Tên đối tượng nộp báo cáo (reporting_entity_nm của danh mục đối tượng nộp); không khớp → rỗng',
    object_tp                                    String                  COMMENT 'Nhãn loại đối tượng nộp báo cáo (reporting_entity_tp_nm); không khớp → rỗng',
    period_tp                                    String                  COMMENT 'Loại kỳ báo cáo (THANG, QUY, NAM, ...); trống → rỗng',
    period_val                                   String                  COMMENT 'Giá trị kỳ báo cáo (VD T09/2026); trống → rỗng',
    dynamic_row_order                            Int64 DEFAULT 0         COMMENT 'Thứ tự dòng trong band động (opr_fir_value.dynamic_row_order); 0 = ô tĩnh; trống → 0',
    indicator_id                                 String                  COMMENT 'Mã chỉ tiêu = opr_fir_structure.data_explorer_id (MD5 do ETL Atomic sinh, giữ nguyên) — khóa nối với bảng chỉ tiêu',
    indicator_val                                String                  COMMENT 'Giá trị ô — NGUYÊN VĂN opr_fir_value.val_raw, không nhân 100, không đổi đơn vị',
    rpt_log_id                                   UInt64                  COMMENT 'Mã LẦN NỘP (opr_fir_value.rpt_log_id ép số) — version column của ReplacingMergeTree: lần nộp có id lớn nhất thắng',
    submission_dt                                Date                    COMMENT 'Ngày THỰC TẾ nộp báo cáo (opr_fir_value.submission_dt) — khóa xóa–ghi lại của job',
    ds_etl_pcs_tms                               DateTime                COMMENT 'Thời điểm ETL ghi dòng'
)
ENGINE = ReplicatedReplacingMergeTree('/clickhouse/tables/{shard}/datamart/ndtnn_opr_foreign_investor_report_explorer_val_flat', '{replica}', rpt_log_id)
ORDER BY (period_end_dt, object_id, object_nm, object_tp, dynamic_row_order, period_tp, period_val, indicator_id)
SETTINGS allow_nullable_key = 1, index_granularity = 8192
COMMENT 'Flat Data Explorer NDTNN — giá trị ô báo cáo FIMS (thay default.bc_fims)'
;


-- ============================================================
-- 17. OPERATIONAL: ndtnn_opr_foreign_investor_report_explorer_indicator_flat
--    Bảng chỉ tiêu (cây chỉ tiêu) Data Explorer NDTNN — thay phần FIMS của default.metadata_etl của job fims_ods_to_clickhouse.
--    Mỗi data_explorer_id một dòng, dựng từ TOÀN BỘ opr_fir_structure hiện hành (kể cả chỉ tiêu chưa có số liệu) — §4 của md.
--    Job chỉ ghi 15 cột; 8 cột còn lại (changed_by_nm, rpt_nm, sheet_nm, row_path, column_path, object_tp_list, object_sub_tp_list, legal_basis)
--    để rỗng như job cũ. Phải chạy SAU khối 16 (đọc bảng dữ liệu để suy unit_nm số/%/chữ). Nạp toàn bộ (TRUNCATE + INSERT) — [MỚI 2026-11-14, O_NDTNN_61]
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.ndtnn_opr_foreign_investor_report_explorer_indicator_flat ON CLUSTER 'my_cluster'
(
    indicator_id                                 String                  COMMENT 'Mã chỉ tiêu (data_explorer_id) — khớp indicator_id của bảng dữ liệu',
    indicator_group_nm                           String                  COMMENT 'Nhóm hiển thị: tên báo cáo [- căn cứ pháp lý] > sheet > nhóm hàng [> Chi tiết]',
    indicator_nm                                 String                  COMMENT 'Tên chỉ tiêu: column_path; rỗng thì lá cuối của row_path',
    indicator_tp                                 Int32                   COMMENT 'Loại chỉ tiêu: luôn 1 = base',
    source_table_nm                              String                  COMMENT 'Bảng nguồn của giá trị chỉ tiêu (datamart.opr_fir_value)',
    target_table_nm                              String                  COMMENT 'Bảng dữ liệu chứa giá trị chỉ tiêu (ndtnn_opr_foreign_investor_report_explorer_val_flat)',
    group_key_list                               String                  COMMENT 'Danh sách cột chiều của bảng dữ liệu, cách nhau dấu phẩy; Data Explorer dựng GROUP BY theo chuỗi này (tên cột MỚI)',
    logic_function                               String                  COMMENT 'Hàm logic tổng hợp — rỗng với chỉ tiêu base',
    indicator_level                              Int32                   COMMENT 'Cấp chỉ tiêu: luôn 1',
    active_ind                                   Int32 DEFAULT 1         COMMENT '1 = chỉ tiêu đang hiệu lực: luôn 1',
    effective_from_dt                            Date                    COMMENT 'Ngày bắt đầu hiệu lực: 2000-01-01',
    effective_to_dt                              Date                    COMMENT 'Ngày hết hiệu lực: 2099-12-31',
    ds_etl_pcs_tms                               DateTime DEFAULT now()  COMMENT 'Thời điểm ETL ghi dòng',
    unit_nm                                      String DEFAULT ''       COMMENT 'Đơn vị: rỗng = số, % = tỷ lệ (chỉ là nhãn, không nhân 100), __text__ = chữ; phụ thuộc dữ liệu khoảng ngày chạy',
    sort_order_nbr                               Int64 DEFAULT 0         COMMENT 'Thứ tự sắp xếp theo mẫu báo cáo (fir_structure.sort_order); trống → 0',
    changed_by_nm                                String DEFAULT ''       COMMENT 'Job FIMS không ghi — để rỗng',
    rpt_nm                                       String DEFAULT ''       COMMENT 'Job FIMS không ghi — để rỗng',
    sheet_nm                                     String DEFAULT ''       COMMENT 'Job FIMS không ghi — để rỗng',
    row_path                                     String DEFAULT ''       COMMENT 'Job FIMS không ghi — để rỗng',
    column_path                                  String DEFAULT ''       COMMENT 'Job FIMS không ghi — để rỗng',
    object_tp_list                               String DEFAULT ''       COMMENT 'Job FIMS không ghi — để rỗng',
    object_sub_tp_list                           String DEFAULT ''       COMMENT 'Job FIMS không ghi — để rỗng',
    legal_basis                                  String DEFAULT ''       COMMENT 'Job FIMS không ghi — để rỗng'
)
ENGINE = ReplicatedMergeTree()
ORDER BY (indicator_level, indicator_id)
COMMENT 'Flat Data Explorer NDTNN — cây chỉ tiêu báo cáo FIMS (thay phần FIMS của default.metadata_etl)'
;
