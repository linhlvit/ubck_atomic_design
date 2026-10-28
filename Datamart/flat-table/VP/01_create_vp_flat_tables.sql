-- ============================================================
-- VP Flat Tables — CREATE
-- Module: Thống kê thị trường chứng khoán (VP)
-- Generated: Phase 3 LLD Datamart
-- 6 bảng:
--   1. vp_fct_derivative_contract_snpst_flat (Nhóm 3, 4, 5)
--   2. vp_fct_investor_group_trading_snpst_flat (Nhóm 1, 2, 3, 5, 6)
--   3. vp_fct_listed_corporate_bond_snpst_flat (Nhóm 7, 8, 9, 10)
--   4. vp_fct_private_corporate_bond_trading_snpst_flat (Nhóm 9, 11, 12, 13)
--   5. vp_fct_government_bond_trading_snpst_flat (Nhóm 14, 15, 16)
--   6. vp_fct_private_corporate_bond_registration_snpst_flat (Nhóm 11)
-- Ghi chú: Fact Market Index Snapshot (reuse QLKD) dùng bảng flat của QLKD; lịch ngày dùng datamart.cdr_dt_flat (Datamart/flat-table/Common).
--   Lô 1 (Nhóm 7-10, 2026-10-25): thêm 2 flat TPDN; Industry Dimension (GSDC) chỉ denormalize industry_code, industry_nm vào flat Fact TPDN niêm yết.
--   Lô 2 (Nhóm 11-16, 2026-10-25): thêm 2 flat — TPCP (Bond Order Book HNX, OUTRIGHT/REPO) và TPDN riêng lẻ đăng ký giao dịch (báo cáo tháng HNX); flat TPDN riêng lẻ HNX09 của Lô 1 dùng thêm cho Nhóm 11-13 (không đổi cột).
-- Thiết kế lại VP 2026-10-25: bỏ 2 flat cũ vp_fact_otc_bond_snapshot_flat, vp_fact_share_auction_snapshot_flat (DEPRECATED, HLD Section 4).
-- ============================================================


-- ==========================================================
-- 1. FACT: vp_fct_derivative_contract_snpst_flat
--    fct_derivative_contract_snpst — sinh tự động từ master registry + Entities.csv
--    Joins: Calendar Date Dimension, Security Trading Snapshot Dimension, Industry Dimension
-- ==========================================================
CREATE TABLE IF NOT EXISTS datamart.vp_fct_derivative_contract_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FCT_DERIVATIVE_CONTRACT_SNPST
    derivative_contract_snpst_id                 String                  COMMENT 'PK — hash(snpst_dt_dim_id, ticker_symbol). Grain = 1 mã hợp đồng phái sinh × 1 ngày giao dịch; mã hợp đồng lấy',
    snpst_dt_dim_id                              String                  COMMENT 'FK tới Calendar Date Dimension — ngày giao dịch (ngày báo cáo của OI VSDC).',
    security_trading_snpst_dim_id                Nullable(String)        COMMENT 'FK tới Security Trading Snapshot Dimension — hồ sơ hợp đồng phái sinh; để trống khi hợp đồng có OI VSDC nhưng ',
    ticker_symbol                                String                  COMMENT 'Mã hợp đồng phái sinh (CONTRACT_CODE của VSDC = Symbol của MDDS). Định danh dòng khi khóa ngoại dimension để t',
    open_interest_quantity                       Nullable(Int64)         COMMENT 'Khối lượng hợp đồng mở (open interest) cuối ngày của mã hợp đồng, theo báo cáo VSDC.',
    close_price                                  Nullable(Decimal(23,2)) COMMENT 'Giá đóng cửa của mã hợp đồng phái sinh theo bản tin cuối ngày MDDS.',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                       Nullable(Date)          COMMENT 'NK — ngày lịch dùng để join từ Fact — từ Calendar Date Dimension',
    year                                         Nullable(Int64)         COMMENT 'Năm (YYYY) — từ Calendar Date Dimension',
    quarter                                      Nullable(Int64)         COMMENT 'Quý (1–4) — từ Calendar Date Dimension',
    month                                        Nullable(Int64)         COMMENT 'Tháng (1–12) — từ Calendar Date Dimension',
    day_of_week                                  Nullable(Int64)         COMMENT 'Thứ trong tuần (1=Chủ nhật, 7=Thứ bảy) — từ Calendar Date Dimension',
    is_weekend                                   Nullable(String)        COMMENT '(Sửa 2026-07-17) Y nếu là ngày cuối tuần (thứ 7 hoặc CN), N nếu không — từ Calendar Date Dimension',
    holiday_flag                                 Nullable(String)        COMMENT '(Sửa 2026-07-20) Cờ đánh dấu ngày nghỉ — Y nếu là ngày nghỉ, N nếu không. Chỉ đánh dấu nghỉ/không nghỉ, không  — từ Calendar Date Dimension',
    is_trading_date                              Nullable(String)        COMMENT '(Sửa 2026-10-12, BA đổi rule lần 2 — thay rule 2026-10-09 "cả hai nguồn") Y nếu ngày lịch có bản ghi ở ÍT NHẤT — từ Calendar Date Dimension',

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    symbol                                       Nullable(String)        COMMENT 'Khóa nghiệp vụ — mã chứng khoán — từ Security Trading Snapshot Dimension',
    security_full_nm                             Nullable(String)        COMMENT 'Tên chứng khoán (tiếng Việt) — từ Security Trading Snapshot Dimension',
    floor_code                                   Nullable(String)        COMMENT 'Mã sàn — scheme MDDS_FLOOR_CODE (10-HOSE, 02-HNX, 04-UPCOM, 03-FDS) — từ Security Trading Snapshot Dimension',
    stock_tp_code                                Nullable(String)        COMMENT 'Loại chứng khoán — scheme MDDS_STOCK_TYPE — từ Security Trading Snapshot Dimension',
    stock_tp_nm                                  Nullable(String)        COMMENT '[SỬA 2026-10-08, BA GSTT cập nhật CASE] Loại chứng khoán — dẫn xuất theo mã sàn (`10` HOSE; `02` HNX, `03` DVX — từ Security Trading Snapshot Dimension',
    underlying_symbol                            Nullable(String)        COMMENT 'Chứng khoán cơ sở — dành cho CW/phái sinh — từ Security Trading Snapshot Dimension',
    isin_code                                    Nullable(String)        COMMENT 'Mã ISIN của CK — từ Security Trading Snapshot Dimension',
    issuer_nm                                    Nullable(String)        COMMENT 'Tổ chức phát hành — từ Security Trading Snapshot Dimension',
    listed_share_count                           Nullable(Int64)         COMMENT 'Khối lượng CK niêm yết — từ Security Trading Snapshot Dimension',
    first_trading_dt                             Nullable(Date)          COMMENT 'Ngày giao dịch đầu tiên — dành cho phái sinh/CW — từ Security Trading Snapshot Dimension',
    last_trading_dt                              Nullable(Date)          COMMENT 'Ngày giao dịch cuối cùng — dành cho phái sinh/CW — từ Security Trading Snapshot Dimension',
    issue_dt                                     Nullable(Date)          COMMENT 'Ngày phát hành — từ Security Trading Snapshot Dimension',
    maturity_dt                                  Nullable(Date)          COMMENT 'Ngày đáo hạn — từ Security Trading Snapshot Dimension',
    fund_tp_code                                 Nullable(String)        COMMENT 'Loại quỹ — chỉ có giá trị khi Stock Type Code = MF — từ Security Trading Snapshot Dimension',
    covered_warrant_tp_code                      Nullable(String)        COMMENT 'Kiểu chứng quyền — scheme MDDS_COVERED_WARRANT_TYPE — từ Security Trading Snapshot Dimension',
    exercise_price                               Nullable(Decimal(23,2)) COMMENT 'Giá thực hiện CW — từ Security Trading Snapshot Dimension',
    exercise_ratio                               Nullable(String)        COMMENT 'Tỉ lệ thực hiện CW — từ Security Trading Snapshot Dimension',
    exercise_style_code                          Nullable(String)        COMMENT 'Kiểu thực hiện phái sinh — scheme MDDS_EXERCISE_STYLE (A/E/B/Z) — từ Security Trading Snapshot Dimension',
    put_or_call_code                             Nullable(String)        COMMENT 'Loại quyền phái sinh — scheme MDDS_PUT_OR_CALL (P/C) — từ Security Trading Snapshot Dimension',
    contract_multiplier                          Nullable(String)        COMMENT 'Hệ số nhân HĐTL — chỉ có giá trị khi Stock Type Code = FU — từ Security Trading Snapshot Dimension',
    maturity_month_year                          Nullable(String)        COMMENT 'Năm tháng đáo hạn HĐTL — từ Security Trading Snapshot Dimension',
    coupon_rate                                  Nullable(Decimal(8,5))  COMMENT 'Lãi suất trái phiếu — từ Security Trading Snapshot Dimension',
    yield                                        Nullable(Decimal(8,5))  COMMENT 'YTM (Yield to Maturity) — từ Security Trading Snapshot Dimension',
    open_price                                   Nullable(Decimal(23,2)) COMMENT 'Giá mở cửa — từ Security Trading Snapshot Dimension',
    high_price                                   Nullable(Decimal(23,2)) COMMENT 'Giá cao nhất — từ Security Trading Snapshot Dimension',
    low_price                                    Nullable(Decimal(23,2)) COMMENT 'Giá thấp nhất — từ Security Trading Snapshot Dimension',
    ceiling_price                                Nullable(Decimal(23,2)) COMMENT '[MOI 2026-09-22, BA bo sung gap STT 23] Gia tran — từ Security Trading Snapshot Dimension',
    floor_price                                  Nullable(Decimal(23,2)) COMMENT '[MOI 2026-09-22, BA bo sung gap STT 23] Gia san — từ Security Trading Snapshot Dimension',
    reference_price                              Nullable(Decimal(23,2)) COMMENT 'Giá tham chiếu — từ Security Trading Snapshot Dimension',
    close_price                                  Nullable(Decimal(23,2)) COMMENT 'Giá khớp gần nhất (giá đóng cửa) — từ Security Trading Snapshot Dimension',
    price_change                                 Nullable(Decimal(23,2)) COMMENT 'Thay đổi giữa giá khớp gần nhất và giá tham chiếu — từ Security Trading Snapshot Dimension',
    product_group_id                             Nullable(String)        COMMENT 'Mã nhóm sản phẩm của chứng khoán theo Sở (VD FBX = hợp đồng tương lai trái phiếu Chính phủ) — dùng nhận diện s — từ Security Trading Snapshot Dimension',
    sts_dim_src_stm_code                         Nullable(String)        COMMENT 'Mã hệ thống nguồn dữ liệu — từ Security Trading Snapshot Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), derivative_contract_snpst_id)
COMMENT 'Flat table — fct_derivative_contract_snpst — sinh tự động từ master registry + Entities.csv'
;


-- ==========================================================
-- 2. FACT: vp_fct_investor_group_trading_snpst_flat
--    fct_investor_group_trading_snpst — sinh tự động từ master registry + Entities.csv
--    Joins: Calendar Date Dimension, Security Trading Snapshot Dimension
-- ==========================================================
CREATE TABLE IF NOT EXISTS datamart.vp_fct_investor_group_trading_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FCT_INVESTOR_GROUP_TRADING_SNPST
    investor_group_trading_snpst_id              String                  COMMENT 'PK — hash(snpst_dt_dim_id, security_symbol_code, market_id_code, investor_group_code). Grain = 1 mã chứng khoá',
    snpst_dt_dim_id                              String                  COMMENT 'FK tới Calendar Date Dimension — ngày giao dịch.',
    security_trading_snpst_dim_id                Nullable(String)        COMMENT 'FK tới Security Trading Snapshot Dimension — hồ sơ mã chứng khoán/hợp đồng phái sinh; để trống khi mã chưa từn',
    industry_dim_id                              Nullable(String)        COMMENT 'FK tới Industry Dimension — ngành nghề kinh tế cấp 1 của CỔ PHIẾU (BA Nhóm 35: jad_stockinfor stocktype = 2 → hồ sơ công ty đại chúng IDS `company_profiles.category_l1_id` → `categories`); CTCK/CTQLQ là công ty đại chúng nên mặc định ngành 07000; để trống với mọi dòng không phải cổ phiếu (chứng chỉ quỹ, chứng quyền, phái sinh), mã chưa có hồ sơ công ty hoặc không xác định được ngành (nhóm NA). [MỚI 2026-10-28, O_VP_37] Cột phụ thuộc hàm vào mã chứng khoán nên KHÔNG đổi grain/khóa.',
    security_symbol_code                         String                  COMMENT 'Mã chứng khoán/hợp đồng theo sổ lệnh: HOSE = mã giao dịch (Symbol), HNX = Issue Code (ISIN). Định danh dòng kh',
    market_id_code                               String                  COMMENT 'Mã thị trường của giao dịch: STK = HOSE, STX = HNX, UPX = UPCoM, DVX = phái sinh (scheme ORDERTRADE_MARKET_ID)',
    investor_group_code                          String                  COMMENT 'Nhóm nhà đầu tư: ALL = mọi giao dịch khớp; FOREIGN = NĐTNN (ký tự thứ 4 số tài khoản thuộc E, F); PROPRIETARY ',
    buy_vol                                      Nullable(Int64)         COMMENT 'Khối lượng phía mua theo nhóm nhà đầu tư (nhóm nhà đầu tư không loại trừ nhau (tài khoản loại E thuộc cả NĐTNN',
    buy_val                                      Nullable(Decimal(23,2)) COMMENT 'Giá trị phía mua theo nhóm nhà đầu tư (nhóm nhà đầu tư không loại trừ nhau (tài khoản loại E thuộc cả NĐTNN và',
    sell_vol                                     Nullable(Int64)         COMMENT 'Khối lượng phía bán theo nhóm nhà đầu tư (nhóm nhà đầu tư không loại trừ nhau (tài khoản loại E thuộc cả NĐTNN',
    sell_val                                     Nullable(Decimal(23,2)) COMMENT 'Giá trị phía bán theo nhóm nhà đầu tư (nhóm nhà đầu tư không loại trừ nhau (tài khoản loại E thuộc cả NĐTNN và',
    src_stm_code                                 String                  COMMENT 'Mã hệ thống nguồn dữ liệu; cùng tham gia khóa PK (hash) để các nguồn khác nhau không trùng khóa.',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                       Nullable(Date)          COMMENT 'NK — ngày lịch dùng để join từ Fact — từ Calendar Date Dimension',
    year                                         Nullable(Int64)         COMMENT 'Năm (YYYY) — từ Calendar Date Dimension',
    quarter                                      Nullable(Int64)         COMMENT 'Quý (1–4) — từ Calendar Date Dimension',
    month                                        Nullable(Int64)         COMMENT 'Tháng (1–12) — từ Calendar Date Dimension',
    day_of_week                                  Nullable(Int64)         COMMENT 'Thứ trong tuần (1=Chủ nhật, 7=Thứ bảy) — từ Calendar Date Dimension',
    is_weekend                                   Nullable(String)        COMMENT '(Sửa 2026-07-17) Y nếu là ngày cuối tuần (thứ 7 hoặc CN), N nếu không — từ Calendar Date Dimension',
    holiday_flag                                 Nullable(String)        COMMENT '(Sửa 2026-07-20) Cờ đánh dấu ngày nghỉ — Y nếu là ngày nghỉ, N nếu không. Chỉ đánh dấu nghỉ/không nghỉ, không  — từ Calendar Date Dimension',
    is_trading_date                              Nullable(String)        COMMENT '(Sửa 2026-10-12, BA đổi rule lần 2 — thay rule 2026-10-09 "cả hai nguồn") Y nếu ngày lịch có bản ghi ở ÍT NHẤT — từ Calendar Date Dimension',

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    symbol                                       Nullable(String)        COMMENT 'Khóa nghiệp vụ — mã chứng khoán — từ Security Trading Snapshot Dimension',
    security_full_nm                             Nullable(String)        COMMENT 'Tên chứng khoán (tiếng Việt) — từ Security Trading Snapshot Dimension',
    floor_code                                   Nullable(String)        COMMENT 'Mã sàn — scheme MDDS_FLOOR_CODE (10-HOSE, 02-HNX, 04-UPCOM, 03-FDS) — từ Security Trading Snapshot Dimension',
    stock_tp_code                                Nullable(String)        COMMENT 'Loại chứng khoán — scheme MDDS_STOCK_TYPE — từ Security Trading Snapshot Dimension',
    stock_tp_nm                                  Nullable(String)        COMMENT '[SỬA 2026-10-08, BA GSTT cập nhật CASE] Loại chứng khoán — dẫn xuất theo mã sàn (`10` HOSE; `02` HNX, `03` DVX — từ Security Trading Snapshot Dimension',
    underlying_symbol                            Nullable(String)        COMMENT 'Chứng khoán cơ sở — dành cho CW/phái sinh — từ Security Trading Snapshot Dimension',
    isin_code                                    Nullable(String)        COMMENT 'Mã ISIN của CK — từ Security Trading Snapshot Dimension',
    issuer_nm                                    Nullable(String)        COMMENT 'Tổ chức phát hành — từ Security Trading Snapshot Dimension',
    listed_share_count                           Nullable(Int64)         COMMENT 'Khối lượng CK niêm yết — từ Security Trading Snapshot Dimension',
    first_trading_dt                             Nullable(Date)          COMMENT 'Ngày giao dịch đầu tiên — dành cho phái sinh/CW — từ Security Trading Snapshot Dimension',
    last_trading_dt                              Nullable(Date)          COMMENT 'Ngày giao dịch cuối cùng — dành cho phái sinh/CW — từ Security Trading Snapshot Dimension',
    issue_dt                                     Nullable(Date)          COMMENT 'Ngày phát hành — từ Security Trading Snapshot Dimension',
    maturity_dt                                  Nullable(Date)          COMMENT 'Ngày đáo hạn — từ Security Trading Snapshot Dimension',
    fund_tp_code                                 Nullable(String)        COMMENT 'Loại quỹ — chỉ có giá trị khi Stock Type Code = MF — từ Security Trading Snapshot Dimension',
    covered_warrant_tp_code                      Nullable(String)        COMMENT 'Kiểu chứng quyền — scheme MDDS_COVERED_WARRANT_TYPE — từ Security Trading Snapshot Dimension',
    exercise_price                               Nullable(Decimal(23,2)) COMMENT 'Giá thực hiện CW — từ Security Trading Snapshot Dimension',
    exercise_ratio                               Nullable(String)        COMMENT 'Tỉ lệ thực hiện CW — từ Security Trading Snapshot Dimension',
    exercise_style_code                          Nullable(String)        COMMENT 'Kiểu thực hiện phái sinh — scheme MDDS_EXERCISE_STYLE (A/E/B/Z) — từ Security Trading Snapshot Dimension',
    put_or_call_code                             Nullable(String)        COMMENT 'Loại quyền phái sinh — scheme MDDS_PUT_OR_CALL (P/C) — từ Security Trading Snapshot Dimension',
    contract_multiplier                          Nullable(String)        COMMENT 'Hệ số nhân HĐTL — chỉ có giá trị khi Stock Type Code = FU — từ Security Trading Snapshot Dimension',
    maturity_month_year                          Nullable(String)        COMMENT 'Năm tháng đáo hạn HĐTL — từ Security Trading Snapshot Dimension',
    coupon_rate                                  Nullable(Decimal(8,5))  COMMENT 'Lãi suất trái phiếu — từ Security Trading Snapshot Dimension',
    yield                                        Nullable(Decimal(8,5))  COMMENT 'YTM (Yield to Maturity) — từ Security Trading Snapshot Dimension',
    open_price                                   Nullable(Decimal(23,2)) COMMENT 'Giá mở cửa — từ Security Trading Snapshot Dimension',
    high_price                                   Nullable(Decimal(23,2)) COMMENT 'Giá cao nhất — từ Security Trading Snapshot Dimension',
    low_price                                    Nullable(Decimal(23,2)) COMMENT 'Giá thấp nhất — từ Security Trading Snapshot Dimension',
    ceiling_price                                Nullable(Decimal(23,2)) COMMENT '[MOI 2026-09-22, BA bo sung gap STT 23] Gia tran — từ Security Trading Snapshot Dimension',
    floor_price                                  Nullable(Decimal(23,2)) COMMENT '[MOI 2026-09-22, BA bo sung gap STT 23] Gia san — từ Security Trading Snapshot Dimension',
    reference_price                              Nullable(Decimal(23,2)) COMMENT 'Giá tham chiếu — từ Security Trading Snapshot Dimension',
    close_price                                  Nullable(Decimal(23,2)) COMMENT 'Giá khớp gần nhất (giá đóng cửa) — từ Security Trading Snapshot Dimension',
    price_change                                 Nullable(Decimal(23,2)) COMMENT 'Thay đổi giữa giá khớp gần nhất và giá tham chiếu — từ Security Trading Snapshot Dimension',
    product_group_id                             Nullable(String)        COMMENT 'Mã nhóm sản phẩm của chứng khoán theo Sở (VD FBX = hợp đồng tương lai trái phiếu Chính phủ) — dùng nhận diện s — từ Security Trading Snapshot Dimension',
    sts_dim_src_stm_code                         Nullable(String)        COMMENT 'Mã hệ thống nguồn dữ liệu — từ Security Trading Snapshot Dimension',

    -- From: INDUSTRY DIMENSION
    industry_code                                Nullable(String)        COMMENT 'BK — mã ngành nghề cấp 1 (Classification IDS Business Line Code). Chỉ lấy ngành cấp 1 hiện hành (parent_cl_ids — từ Industry Dimension',
    industry_nm                                  Nullable(String)        COMMENT 'Tên ngành nghề cấp 1 — từ Industry Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), investor_group_trading_snpst_id)
COMMENT 'Flat table — fct_investor_group_trading_snpst — sinh tự động từ master registry + Entities.csv'
;


-- ==========================================================
-- 3. FACT: vp_fct_listed_corporate_bond_snpst_flat
--    fct_listed_corporate_bond_snpst — Grain: 1 mã trái phiếu (ISIN) × 1 ngày giao dịch; PK listed_corporate_bond_snpst_id = hash(snpst_dt_dim_id, security_symbol_code)
--    Joins: Calendar Date Dimension, Industry Dimension
-- ==========================================================
CREATE TABLE IF NOT EXISTS datamart.vp_fct_listed_corporate_bond_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FCT_LISTED_CORPORATE_BOND_SNPST
    listed_corporate_bond_snpst_id               String                  COMMENT 'PK — hash(snpst_dt_dim_id, security_symbol_code). Grain = 1 mã trái phiếu (ISIN) × 1 ngày giao dịch; dòng là m',
    snpst_dt_dim_id                              String                  COMMENT 'FK tới Calendar Date Dimension — ngày giao dịch.',
    industry_dim_id                              Nullable(String)        COMMENT 'FK tới Industry Dimension — ngành nghề kinh tế cấp 1 của tổ chức phát hành (3 ký tự đầu mã trái phiếu = mã cổ ',
    security_symbol_code                         String                  COMMENT 'Mã trái phiếu theo ISIN (Issue Code của Sổ lệnh HNX = ISIN Code của bản tin MDDS). Khóa nghiệp vụ của dòng cùn',
    listed_indicator                             UInt8                   COMMENT 'Cờ mã trái phiếu có bản tin cuối ngày MDDS (Stock Type Code = 1) trong ngày; TRUE khi có bản tin, FALSE khi ch',
    issue_term_years                             Nullable(Decimal(23,2)) COMMENT 'Kỳ hạn phát hành (năm) = làm tròn 2 chữ số của số tháng giữa ngày phát hành và ngày đáo hạn chia 12, theo bản ',
    remaining_term_years                         Nullable(Decimal(23,6)) COMMENT 'Kỳ hạn còn lại (năm) tại ngày giao dịch = số tháng từ ngày giao dịch đến ngày đáo hạn chia 12, không làm tròn;',
    trading_vol                                  Nullable(Int64)         COMMENT 'Khối lượng giao dịch TPDN niêm yết trong ngày theo mã (Sổ lệnh HNX, Market Id Code = HCX); để trống khi mã khô',
    trading_val                                  Nullable(Decimal(23,2)) COMMENT 'Giá trị giao dịch TPDN niêm yết trong ngày theo mã = Σ giá trị khớp của Sổ lệnh HNX (Market Id Code = HCX); để',
    foreign_buy_val                              Nullable(Decimal(23,2)) COMMENT 'Giá trị mua của nhà đầu tư nước ngoài trong ngày theo mã: giá trị khớp của giao dịch có ký tự thứ 4 của số tài',
    foreign_sell_val                             Nullable(Decimal(23,2)) COMMENT 'Giá trị bán của nhà đầu tư nước ngoài trong ngày theo mã: giá trị khớp của giao dịch có ký tự thứ 4 của số tài',
    outstanding_bond_quantity                    Nullable(Int64)         COMMENT 'Khối lượng trái phiếu đang lưu hành tại ngày của bản tin theo danh mục chứng khoán niêm yết HNX (nối theo mã v',
    bond_outstanding_val                         Nullable(Decimal(23,2)) COMMENT 'Dư nợ trái phiếu = khối lượng lưu hành × mệnh giá. Mệnh giá không có ở nguồn nên tính ngược từ giá tham chiếu ',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                       Nullable(Date)          COMMENT 'NK — ngày lịch dùng để join từ Fact — từ Calendar Date Dimension',
    year                                         Nullable(Int64)         COMMENT 'Năm (YYYY) — từ Calendar Date Dimension',
    quarter                                      Nullable(Int64)         COMMENT 'Quý (1–4) — từ Calendar Date Dimension',
    month                                        Nullable(Int64)         COMMENT 'Tháng (1–12) — từ Calendar Date Dimension',
    day_of_week                                  Nullable(Int64)         COMMENT 'Thứ trong tuần (1=Chủ nhật, 7=Thứ bảy) — từ Calendar Date Dimension',
    is_weekend                                   Nullable(String)        COMMENT '(Sửa 2026-07-17) Y nếu là ngày cuối tuần (thứ 7 hoặc CN), N nếu không — từ Calendar Date Dimension',
    holiday_flag                                 Nullable(String)        COMMENT '(Sửa 2026-07-20) Cờ đánh dấu ngày nghỉ — Y nếu là ngày nghỉ, N nếu không. Chỉ đánh dấu nghỉ/không nghỉ, không  — từ Calendar Date Dimension',
    is_trading_date                              Nullable(String)        COMMENT '(Sửa 2026-10-12, BA đổi rule lần 2 — thay rule 2026-10-09 "cả hai nguồn") Y nếu ngày lịch có bản ghi ở ÍT NHẤT — từ Calendar Date Dimension',

    -- From: INDUSTRY DIMENSION
    industry_code                                Nullable(String)        COMMENT 'BK — mã ngành nghề cấp 1 (Classification IDS Business Line Code). Chỉ lấy ngành cấp 1 hiện hành (parent_cl_ids — từ Industry Dimension',
    industry_nm                                  Nullable(String)        COMMENT 'Tên ngành nghề cấp 1 — từ Industry Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), listed_corporate_bond_snpst_id)
COMMENT 'Flat table — fct_listed_corporate_bond_snpst × Calendar Date × Industry; grain 1 mã trái phiếu (ISIN) × 1 ngày, PK listed_corporate_bond_snpst_id'
;


-- ==========================================================
-- 4. FACT: vp_fct_private_corporate_bond_trading_snpst_flat
--    fct_private_corporate_bond_trading_snpst — Grain: 1 ngày báo cáo HNX09 (toàn thị trường TPDN riêng lẻ); PK private_corporate_bond_trading_snpst_id = hash(snpst_dt_dim_id)
--    Joins: Calendar Date Dimension
-- ==========================================================
CREATE TABLE IF NOT EXISTS datamart.vp_fct_private_corporate_bond_trading_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FCT_PRIVATE_CORPORATE_BOND_TRADING_SNPST
    private_corporate_bond_trading_snpst_id      String                  COMMENT 'PK — hash(snpst_dt_dim_id). Grain = 1 ngày báo cáo HNX09 (báo cáo ngày TPDN riêng lẻ, nguồn nộp ICP đã nộp), t',
    snpst_dt_dim_id                              String                  COMMENT 'FK tới Calendar Date Dimension — ngày báo cáo (ghép từ năm, tháng, ngày báo cáo).',
    trading_val                                  Nullable(Decimal(23,2)) COMMENT 'Giá trị giao dịch TPDN riêng lẻ trong ngày báo cáo = ô GIÁ TRỊ GIAO DỊCH của báo cáo HNX09; để trống khi ngày ',
    foreign_buy_val                              Nullable(Decimal(23,2)) COMMENT 'Giá trị giao dịch mua của nhà đầu tư nước ngoài trong ngày báo cáo = ô GIÁ TRỊ GIAO DỊCH NHÀ ĐẦU TƯ NƯỚC NGOÀI',
    foreign_sell_val                             Nullable(Decimal(23,2)) COMMENT 'Giá trị giao dịch bán của nhà đầu tư nước ngoài trong ngày báo cáo = ô GIÁ TRỊ GIAO DỊCH NHÀ ĐẦU TƯ NƯỚC NGOÀI',
    src_stm_code                                 String                  COMMENT 'Mã hệ thống nguồn dữ liệu; cùng tham gia khóa PK (hash) để các nguồn khác nhau không trùng khóa.',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                       Nullable(Date)          COMMENT 'NK — ngày lịch dùng để join từ Fact — từ Calendar Date Dimension',
    year                                         Nullable(Int64)         COMMENT 'Năm (YYYY) — từ Calendar Date Dimension',
    quarter                                      Nullable(Int64)         COMMENT 'Quý (1–4) — từ Calendar Date Dimension',
    month                                        Nullable(Int64)         COMMENT 'Tháng (1–12) — từ Calendar Date Dimension',
    day_of_week                                  Nullable(Int64)         COMMENT 'Thứ trong tuần (1=Chủ nhật, 7=Thứ bảy) — từ Calendar Date Dimension',
    is_weekend                                   Nullable(String)        COMMENT '(Sửa 2026-07-17) Y nếu là ngày cuối tuần (thứ 7 hoặc CN), N nếu không — từ Calendar Date Dimension',
    holiday_flag                                 Nullable(String)        COMMENT '(Sửa 2026-07-20) Cờ đánh dấu ngày nghỉ — Y nếu là ngày nghỉ, N nếu không. Chỉ đánh dấu nghỉ/không nghỉ, không  — từ Calendar Date Dimension',
    is_trading_date                              Nullable(String)        COMMENT '(Sửa 2026-10-12, BA đổi rule lần 2 — thay rule 2026-10-09 "cả hai nguồn") Y nếu ngày lịch có bản ghi ở ÍT NHẤT — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), private_corporate_bond_trading_snpst_id)
COMMENT 'Flat table — fct_private_corporate_bond_trading_snpst × Calendar Date; grain 1 ngày báo cáo HNX09, PK private_corporate_bond_trading_snpst_id'
;


-- ==========================================================
-- 5. FACT: vp_fct_government_bond_trading_snpst_flat
--    fct_government_bond_trading_snpst — Grain: 1 ngày giao dịch × 1 loại sổ lệnh (OUTRIGHT / REPO), chỉ lệnh đã thực hiện (ĐTH); PK government_bond_trading_snpst_id = hash(snpst_dt_dim_id, order_book_tp)
--    Joins: Calendar Date Dimension
-- ==========================================================
CREATE TABLE IF NOT EXISTS datamart.vp_fct_government_bond_trading_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FCT_GOVERNMENT_BOND_TRADING_SNPST
    government_bond_trading_snpst_id             String                  COMMENT 'PK — hash(snpst_dt_dim_id, order_book_tp). Grain = 1 ngày giao dịch × 1 loại sổ lệnh (OUTRIGHT hoặc REPO) của ',
    snpst_dt_dim_id                              String                  COMMENT 'FK tới Calendar Date Dimension — ngày giao dịch của lệnh đã thực hiện.',
    order_book_tp                                String                  COMMENT 'Loại sổ lệnh trái phiếu: OUTRIGHT (mua bán thẳng) hoặc REPO; sổ lệnh REPO2 không đưa vào Fact. Tách được khi c',
    trading_vol                                  Nullable(Int64)         COMMENT 'Khối lượng giao dịch (số trái phiếu) của các lệnh đã thực hiện trong ngày theo loại sổ lệnh.',
    trading_val                                  Nullable(Decimal(23,2)) COMMENT 'Giá trị giao dịch của các lệnh đã thực hiện trong ngày theo loại sổ lệnh: giá trị giao dịch với OUTRIGHT, giá ',
    foreign_buy_val                              Nullable(Decimal(23,2)) COMMENT 'Giá trị mua của nhà đầu tư nước ngoài trong ngày theo loại sổ lệnh: giá trị các lệnh đã thực hiện có ký tự thứ',
    foreign_sell_val                             Nullable(Decimal(23,2)) COMMENT 'Giá trị bán của nhà đầu tư nước ngoài trong ngày theo loại sổ lệnh: giá trị các lệnh đã thực hiện có ký tự thứ',
    src_stm_code                                 String                  COMMENT 'Mã hệ thống nguồn dữ liệu; cùng tham gia khóa PK (hash) để các nguồn khác nhau không trùng khóa.',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                       Nullable(Date)          COMMENT 'NK — ngày lịch dùng để join từ Fact — từ Calendar Date Dimension',
    year                                         Nullable(Int64)         COMMENT 'Năm (YYYY) — từ Calendar Date Dimension',
    quarter                                      Nullable(Int64)         COMMENT 'Quý (1–4) — từ Calendar Date Dimension',
    month                                        Nullable(Int64)         COMMENT 'Tháng (1–12) — từ Calendar Date Dimension',
    day_of_week                                  Nullable(Int64)         COMMENT 'Thứ trong tuần (1=Chủ nhật, 7=Thứ bảy) — từ Calendar Date Dimension',
    is_weekend                                   Nullable(String)        COMMENT '(Sửa 2026-07-17) Y nếu là ngày cuối tuần (thứ 7 hoặc CN), N nếu không — từ Calendar Date Dimension',
    holiday_flag                                 Nullable(String)        COMMENT '(Sửa 2026-07-20) Cờ đánh dấu ngày nghỉ — Y nếu là ngày nghỉ, N nếu không. Chỉ đánh dấu nghỉ/không nghỉ, không  — từ Calendar Date Dimension',
    is_trading_date                              Nullable(String)        COMMENT '(Sửa 2026-10-12, BA đổi rule lần 2 — thay rule 2026-10-09 "cả hai nguồn") Y nếu ngày lịch có bản ghi ở ÍT NHẤT — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), government_bond_trading_snpst_id)
COMMENT 'Flat table — fct_government_bond_trading_snpst × Calendar Date; grain 1 ngày giao dịch × 1 loại sổ lệnh (OUTRIGHT / REPO), PK government_bond_trading_snpst_id'
;


-- ==========================================================
-- 6. FACT: vp_fct_private_corporate_bond_registration_snpst_flat
--    fct_private_corporate_bond_registration_snpst — Grain: 1 mã trái phiếu (Bond Code) × 1 tháng báo cáo HNX, factless; FK ngày = ngày cuối tháng báo cáo; PK private_corporate_bond_registration_snpst_id = hash(bond_code, rpt_year, rpt_month)
--    Joins: Calendar Date Dimension
-- ==========================================================
CREATE TABLE IF NOT EXISTS datamart.vp_fct_private_corporate_bond_registration_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FCT_PRIVATE_CORPORATE_BOND_REGISTRATION_SNPST
    private_corporate_bond_registration_snpst_id String                  COMMENT 'PK — hash(bond_code, rpt_year, rpt_month). Grain = 1 mã trái phiếu doanh nghiệp riêng lẻ đăng ký giao dịch × 1',
    snpst_dt_dim_id                              String                  COMMENT 'FK tới Calendar Date Dimension — ngày cuối tháng của tháng báo cáo (suy ra từ năm và tháng báo cáo của HNX).',
    bond_code                                    String                  COMMENT 'Mã trái phiếu doanh nghiệp riêng lẻ đăng ký giao dịch theo báo cáo tháng của HNX; cùng với năm và tháng báo cá',
    rpt_year                                     String                  COMMENT 'Năm báo cáo của báo cáo tháng HNX, giữ nguyên dạng chuỗi của nguồn (chưa kiểm có đệm số 0).',
    rpt_month                                    String                  COMMENT 'Tháng báo cáo (1–12) của báo cáo tháng HNX, giữ nguyên dạng chuỗi của nguồn (chưa kiểm có đệm số 0); ngày cuối',
    maturity_dt                                  Nullable(Date)          COMMENT 'Ngày đáo hạn của trái phiếu; chỉ đếm mã có ngày đáo hạn sau ngày cuối kỳ khi tính số mã đăng ký giao dịch. Để ',
    src_stm_code                                 String                  COMMENT 'Mã hệ thống nguồn dữ liệu; cùng tham gia khóa PK (hash) để các nguồn khác nhau không trùng khóa.',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                       Nullable(Date)          COMMENT 'NK — ngày lịch dùng để join từ Fact — từ Calendar Date Dimension',
    year                                         Nullable(Int64)         COMMENT 'Năm (YYYY) — từ Calendar Date Dimension',
    quarter                                      Nullable(Int64)         COMMENT 'Quý (1–4) — từ Calendar Date Dimension',
    month                                        Nullable(Int64)         COMMENT 'Tháng (1–12) — từ Calendar Date Dimension',
    day_of_week                                  Nullable(Int64)         COMMENT 'Thứ trong tuần (1=Chủ nhật, 7=Thứ bảy) — từ Calendar Date Dimension',
    is_weekend                                   Nullable(String)        COMMENT '(Sửa 2026-07-17) Y nếu là ngày cuối tuần (thứ 7 hoặc CN), N nếu không — từ Calendar Date Dimension',
    holiday_flag                                 Nullable(String)        COMMENT '(Sửa 2026-07-20) Cờ đánh dấu ngày nghỉ — Y nếu là ngày nghỉ, N nếu không. Chỉ đánh dấu nghỉ/không nghỉ, không  — từ Calendar Date Dimension',
    is_trading_date                              Nullable(String)        COMMENT '(Sửa 2026-10-12, BA đổi rule lần 2 — thay rule 2026-10-09 "cả hai nguồn") Y nếu ngày lịch có bản ghi ở ÍT NHẤT — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), private_corporate_bond_registration_snpst_id)
COMMENT 'Flat table — fct_private_corporate_bond_registration_snpst × Calendar Date; grain 1 mã trái phiếu × 1 tháng báo cáo (FK ngày = ngày cuối tháng), PK private_corporate_bond_registration_snpst_id'
;


-- ==========================================================
-- 7. FACT: vp_fct_listed_equity_snpst_flat
--    fct_listed_equity_snpst — sinh tự động từ master registry + Entities.csv
--    Joins: Calendar Date Dimension
-- ==========================================================
CREATE TABLE IF NOT EXISTS datamart.vp_fct_listed_equity_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FCT_LISTED_EQUITY_SNPST
    listed_equity_snpst_id                       String                  COMMENT 'PK — hash(snpst_dt_dim_id, ticker_symbol, src_stm_code). Grain = 1 mã cổ phiếu/chứng chỉ quỹ (stock_tp_code 2/',
    snpst_dt_dim_id                              String                  COMMENT 'FK tới Calendar Date Dimension — ngày giao dịch của bản tin cuối ngày (BA: Vốn hóa/số mã/giá trị niêm yết tính',
    ticker_symbol                                String                  COMMENT 'Mã chứng khoán (SYMBOL của MDDS) — định danh dòng. Fact KHÔNG có khóa ngoại tới Security Trading Snapshot Dime',
    floor_code                                   String                  COMMENT 'Mã sàn của mã tại ngày giao dịch: 02 = HNX, 10 = HOSE, 04 = UPCoM (BA Nhóm 55: floorcode IN (02,04,10)). Lưu T',
    stock_tp_code                                String                  COMMENT 'Loại chứng khoán tại ngày giao dịch: 2 = cổ phiếu, 3/6 = chứng chỉ quỹ (gồm ETF) — Fact chỉ nạp loại 2, 3, 6 (',
    outstanding_share_quantity                   Nullable(Int64)         COMMENT 'Khối lượng cổ phiếu đang lưu hành cuối ngày (VSDC OUTSTANDING_SHARES) — nối ĐÚNG ngày: BA `os.transaction_date',
    listed_share_quantity                        Nullable(Int64)         COMMENT 'Khối lượng niêm yết/đăng ký giao dịch cuối ngày giao dịch (LISTEDSHARE của MDDS) — dùng đếm quy mô niêm yết và tính giá trị niêm yết.',
    listed_share_val                             Nullable(Decimal(23,2)) COMMENT 'Giá trị niêm yết/đăng ký giao dịch (VND) = khối lượng niêm yết × mệnh giá 10.000 đồng (mệnh giá cổ phiếu, chứng chỉ quỹ).',
    close_price                                  Nullable(Decimal(23,2)) COMMENT 'Giá đóng cửa cuối ngày giao dịch (VND) — giá tính vốn hóa HOSE/HNX theo BA Nhóm 55.',
    reference_price                              Nullable(Decimal(23,2)) COMMENT 'Giá tham chiếu cuối ngày giao dịch (VND) — thay cho VWAP khi VWAP ngày T+1 bằng 0 (mã UPCoM không có giao dịch',
    next_day_vol_weighted_average_price          Nullable(Int64)         COMMENT 'VWAP của ngày giao dịch T do Sở gửi trong bản tin MDDS của ngày giao dịch LIỀN SAU (T+1) — BA Nhóm 55: VWAP ng',
    market_price                                 Nullable(Decimal(23,2)) COMMENT 'Giá tính vốn hóa (VND) theo BA Nhóm 55: HOSE/HNX = giá đóng cửa; UPCoM (floor_code = 04) = VWAP ngày T (lấy ở ',
    market_cap_val                               Nullable(Decimal(23,2)) COMMENT 'Vốn hóa cổ phiếu (VND) = giá tính vốn hóa × khối lượng lưu hành; chỉ tính cho cổ phiếu (stock_tp_code = 2), ch',
    src_stm_code                                 String                  COMMENT 'Mã hệ thống nguồn dữ liệu: MDDS_JAD_STOCKINFOR (bản tin cuối ngày, ghép thêm VSDC OUTSTANDING_SHARES cho khối ',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                       Nullable(Date)          COMMENT 'NK — ngày lịch dùng để join từ Fact — từ Calendar Date Dimension',
    year                                         Nullable(Int64)         COMMENT 'Năm (YYYY) — từ Calendar Date Dimension',
    quarter                                      Nullable(Int64)         COMMENT 'Quý (1–4) — từ Calendar Date Dimension',
    month                                        Nullable(Int64)         COMMENT 'Tháng (1–12) — từ Calendar Date Dimension',
    day_of_week                                  Nullable(Int64)         COMMENT 'Thứ trong tuần (1=Chủ nhật, 7=Thứ bảy) — từ Calendar Date Dimension',
    is_weekend                                   Nullable(String)        COMMENT '(Sửa 2026-07-17) Y nếu là ngày cuối tuần (thứ 7 hoặc CN), N nếu không — từ Calendar Date Dimension',
    holiday_flag                                 Nullable(String)        COMMENT '(Sửa 2026-07-20) Cờ đánh dấu ngày nghỉ — Y nếu là ngày nghỉ, N nếu không. Chỉ đánh dấu nghỉ/không nghỉ, không  — từ Calendar Date Dimension',
    is_trading_date                              Nullable(String)        COMMENT '(Sửa 2026-10-12, BA đổi rule lần 2 — thay rule 2026-10-09 "cả hai nguồn") Y nếu ngày lịch có bản ghi ở ÍT NHẤT — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), listed_equity_snpst_id)
COMMENT 'Flat table — fct_listed_equity_snpst — sinh tự động từ master registry + Entities.csv'
;


-- ==========================================================
-- 8. FACT: vp_fct_listing_status_change_snpst_flat
--    fct_listing_status_change_snpst — sinh tự động từ master registry + Entities.csv
--    Joins: Calendar Date Dimension, Security Trading Snapshot Dimension
-- ==========================================================
CREATE TABLE IF NOT EXISTS datamart.vp_fct_listing_status_change_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FCT_LISTING_STATUS_CHANGE_SNPST
    listing_status_change_snpst_id               String                  COMMENT 'PK — id dòng Atomic `listing_status_change_id` (hash DECISION_NO + DECISION_DATE + TICKER_SYMBOL của từng Sở).',
    snpst_dt_dim_id                              Nullable(String)        COMMENT 'FK tới Calendar Date Dimension — NGÀY GIAO DỊCH CUỐI CÙNG của chứng khoán bị thay đổi niêm yết (BA Nhóm 51 lọc',
    security_trading_snpst_dim_id                Nullable(String)        COMMENT 'FK tới Security Trading Snapshot Dimension — hồ sơ mã chứng khoán (loại chứng khoán, mã sàn). BA lấy loại chứn',
    ticker_symbol                                String                  COMMENT 'Mã chứng khoán bị thay đổi niêm yết (TICKER_SYMBOL của Sở). Định danh dòng khi khóa ngoại dimension để trống.',
    decision_nbr                                 Nullable(String)        COMMENT 'Số quyết định thay đổi niêm yết của Sở giao dịch (DECISION_NO).',
    decision_dt                                  Nullable(Date)          COMMENT 'Ngày ra quyết định thay đổi niêm yết (DECISION_DATE).',
    effective_dt                                 Nullable(Date)          COMMENT 'Ngày quyết định có hiệu lực (EFFECTIVE_DATE).',
    listing_last_trading_dt                      Nullable(Date)          COMMENT 'Ngày giao dịch cuối cùng của chứng khoán (LAST_TRADING_DATE) — là ngày dùng cho khóa `snpst_dt_dim_id` và cho ',
    delisted_share_quantity                      Nullable(Int64)         COMMENT 'Khối lượng cổ phiếu bị hủy niêm yết/hủy đăng ký giao dịch (DELISTED_SHARES). BA lọc `delisted_shares > 0` để c',
    delisted_share_val                           Nullable(Decimal(23,2)) COMMENT 'Giá trị chứng khoán bị hủy niêm yết (DELISTED_VALUE).',
    exchange_transfer                            Nullable(String)        COMMENT 'Cờ/diễn giải chuyển sàn của quyết định (EXCHANGE_TRANSFER): giá trị bắt đầu bằng Có = chuyển sàn (không tính l',
    delist_transfer_reason                       Nullable(String)        COMMENT 'Lý do hủy niêm yết/chuyển sàn (DELIST_TRANSFER_REASON).',
    src_stm_code                                 String                  COMMENT 'Mã hệ thống nguồn dữ liệu: HNX_LISTING_STATUS_CHANGE (HNX và UPCoM) hoặc HOSE_LISTING_STATUS_CHANGE (HOSE) — p',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                       Nullable(Date)          COMMENT 'NK — ngày lịch dùng để join từ Fact — từ Calendar Date Dimension',
    year                                         Nullable(Int64)         COMMENT 'Năm (YYYY) — từ Calendar Date Dimension',
    quarter                                      Nullable(Int64)         COMMENT 'Quý (1–4) — từ Calendar Date Dimension',
    month                                        Nullable(Int64)         COMMENT 'Tháng (1–12) — từ Calendar Date Dimension',
    day_of_week                                  Nullable(Int64)         COMMENT 'Thứ trong tuần (1=Chủ nhật, 7=Thứ bảy) — từ Calendar Date Dimension',
    is_weekend                                   Nullable(String)        COMMENT '(Sửa 2026-07-17) Y nếu là ngày cuối tuần (thứ 7 hoặc CN), N nếu không — từ Calendar Date Dimension',
    holiday_flag                                 Nullable(String)        COMMENT '(Sửa 2026-07-20) Cờ đánh dấu ngày nghỉ — Y nếu là ngày nghỉ, N nếu không. Chỉ đánh dấu nghỉ/không nghỉ, không  — từ Calendar Date Dimension',
    is_trading_date                              Nullable(String)        COMMENT '(Sửa 2026-10-12, BA đổi rule lần 2 — thay rule 2026-10-09 "cả hai nguồn") Y nếu ngày lịch có bản ghi ở ÍT NHẤT — từ Calendar Date Dimension',

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    symbol                                       Nullable(String)        COMMENT 'Khóa nghiệp vụ — mã chứng khoán — từ Security Trading Snapshot Dimension',
    security_full_nm                             Nullable(String)        COMMENT 'Tên chứng khoán (tiếng Việt) — từ Security Trading Snapshot Dimension',
    floor_code                                   Nullable(String)        COMMENT 'Mã sàn — scheme MDDS_FLOOR_CODE (10-HOSE, 02-HNX, 04-UPCOM, 03-FDS) — từ Security Trading Snapshot Dimension',
    stock_tp_code                                Nullable(String)        COMMENT 'Loại chứng khoán — scheme MDDS_STOCK_TYPE — từ Security Trading Snapshot Dimension',
    stock_tp_nm                                  Nullable(String)        COMMENT '[SỬA 2026-10-08, BA GSTT cập nhật CASE] Loại chứng khoán — dẫn xuất theo mã sàn (`10` HOSE; `02` HNX, `03` DVX — từ Security Trading Snapshot Dimension',
    underlying_symbol                            Nullable(String)        COMMENT 'Chứng khoán cơ sở — dành cho CW/phái sinh — từ Security Trading Snapshot Dimension',
    isin_code                                    Nullable(String)        COMMENT 'Mã ISIN của CK — từ Security Trading Snapshot Dimension',
    issuer_nm                                    Nullable(String)        COMMENT 'Tổ chức phát hành — từ Security Trading Snapshot Dimension',
    listed_share_count                           Nullable(Int64)         COMMENT 'Khối lượng CK niêm yết — từ Security Trading Snapshot Dimension',
    first_trading_dt                             Nullable(Date)          COMMENT 'Ngày giao dịch đầu tiên — dành cho phái sinh/CW — từ Security Trading Snapshot Dimension',
    last_trading_dt                              Nullable(Date)          COMMENT 'Ngày giao dịch cuối cùng — dành cho phái sinh/CW — từ Security Trading Snapshot Dimension',
    issue_dt                                     Nullable(Date)          COMMENT 'Ngày phát hành — từ Security Trading Snapshot Dimension',
    maturity_dt                                  Nullable(Date)          COMMENT 'Ngày đáo hạn — từ Security Trading Snapshot Dimension',
    fund_tp_code                                 Nullable(String)        COMMENT 'Loại quỹ — chỉ có giá trị khi Stock Type Code = MF — từ Security Trading Snapshot Dimension',
    covered_warrant_tp_code                      Nullable(String)        COMMENT 'Kiểu chứng quyền — scheme MDDS_COVERED_WARRANT_TYPE — từ Security Trading Snapshot Dimension',
    exercise_price                               Nullable(Decimal(23,2)) COMMENT 'Giá thực hiện CW — từ Security Trading Snapshot Dimension',
    exercise_ratio                               Nullable(String)        COMMENT 'Tỉ lệ thực hiện CW — từ Security Trading Snapshot Dimension',
    exercise_style_code                          Nullable(String)        COMMENT 'Kiểu thực hiện phái sinh — scheme MDDS_EXERCISE_STYLE (A/E/B/Z) — từ Security Trading Snapshot Dimension',
    put_or_call_code                             Nullable(String)        COMMENT 'Loại quyền phái sinh — scheme MDDS_PUT_OR_CALL (P/C) — từ Security Trading Snapshot Dimension',
    contract_multiplier                          Nullable(String)        COMMENT 'Hệ số nhân HĐTL — chỉ có giá trị khi Stock Type Code = FU — từ Security Trading Snapshot Dimension',
    maturity_month_year                          Nullable(String)        COMMENT 'Năm tháng đáo hạn HĐTL — từ Security Trading Snapshot Dimension',
    coupon_rate                                  Nullable(Decimal(8,5))  COMMENT 'Lãi suất trái phiếu — từ Security Trading Snapshot Dimension',
    yield                                        Nullable(Decimal(8,5))  COMMENT 'YTM (Yield to Maturity) — từ Security Trading Snapshot Dimension',
    open_price                                   Nullable(Decimal(23,2)) COMMENT 'Giá mở cửa — từ Security Trading Snapshot Dimension',
    high_price                                   Nullable(Decimal(23,2)) COMMENT 'Giá cao nhất — từ Security Trading Snapshot Dimension',
    low_price                                    Nullable(Decimal(23,2)) COMMENT 'Giá thấp nhất — từ Security Trading Snapshot Dimension',
    ceiling_price                                Nullable(Decimal(23,2)) COMMENT '[MOI 2026-09-22, BA bo sung gap STT 23] Gia tran — từ Security Trading Snapshot Dimension',
    floor_price                                  Nullable(Decimal(23,2)) COMMENT '[MOI 2026-09-22, BA bo sung gap STT 23] Gia san — từ Security Trading Snapshot Dimension',
    reference_price                              Nullable(Decimal(23,2)) COMMENT 'Giá tham chiếu — từ Security Trading Snapshot Dimension',
    close_price                                  Nullable(Decimal(23,2)) COMMENT 'Giá khớp gần nhất (giá đóng cửa) — từ Security Trading Snapshot Dimension',
    price_change                                 Nullable(Decimal(23,2)) COMMENT 'Thay đổi giữa giá khớp gần nhất và giá tham chiếu — từ Security Trading Snapshot Dimension',
    product_group_id                             Nullable(String)        COMMENT 'Mã nhóm sản phẩm của chứng khoán theo Sở (VD FBX = hợp đồng tương lai trái phiếu Chính phủ) — dùng nhận diện s — từ Security Trading Snapshot Dimension',
    sts_dim_src_stm_code                         Nullable(String)        COMMENT 'Mã hệ thống nguồn dữ liệu — từ Security Trading Snapshot Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), listing_status_change_snpst_id)
COMMENT 'Flat table — fct_listing_status_change_snpst — sinh tự động từ master registry + Entities.csv'
;
