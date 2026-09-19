-- ============================================================
-- GSTT Flat Tables — CREATE
-- Module: Giám sát Thị trường (GSTT)
-- Generated: Phase 3 LLD Datamart
-- 6 bảng: 5 fact + 1 operational
-- Sửa 2026-09-14: bổ sung bảng #1b (Fact Index Constituent Snapshot, Bridge Factless) —
-- tách khỏi Fact Stock Portfolio Snapshot để hết fan-out theo rổ chỉ số (xem HLD v4.13)
-- (Fact Market Index Snapshot dùng chung QLKD — flat table đã có ở QLKD, không CREATE lại)
-- Sửa 2026-08-03: bảng cũ (Fact Public Company Shareholding) đã bị loại bỏ —
-- xem ghi chú chi tiết cuối file
-- Sửa 2026-08-26: bổ sung bảng #3 (Fact Security Trading Intraday, Nhóm 44 —
-- Biểu đồ phân tích kỹ thuật, K_GSTT_95-99 chuyển PENDING → READY)
-- Sửa 2026-09-11: bổ sung bảng #4 (Fact Foreign Trading Minute Snapshot, Nhóm 25 —
-- K_GSTT_78-80, Resolved 2026-09-04/O_GSTT_8 nhưng bị bỏ sót khỏi Phase 3 tới nay;
-- phát hiện qua rà soát sau khi sửa join-key sổ lệnh↔MDDS/filter thỏa thuận)
-- Sửa 2026-09-12: bổ sung bảng #5 (Operational Public Company Shareholding, Nhóm 31/34 —
-- đảo ngược O_GSTT_9, thay thế hoàn toàn ghi chú "không có bảng flat" cũ bên dưới)
-- ============================================================


-- ============================================================
-- 1. FACT: gstt_fct_stock_portfolio_snpst_flat
--    Danh mục chứng khoán tổng hợp — 1 row / mã CK / rổ chỉ số (FK nullable) / ngày giao dịch
--    Grain: Periodic Snapshot theo ngày (transaction log — mỗi ngày phiên phát sinh
--    đồng bộ dữ liệu cho toàn bộ mã CK giao dịch)
--    Joins: Calendar Date (snpst_dt_dim_id JOIN) × Security Trading Snapshot Dimension ×
--           Public Company Dimension
--    [SỬA 2026-09-14] Không còn join Index Constituent Dimension — tách sang
--    gstt_fct_index_constituent_snpst_flat riêng (Bridge, xem bảng #1b bên dưới)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_fct_stock_portfolio_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Stock Portfolio Snapshot
    security_trading_snpst_dim_id       String                  COMMENT 'FK → Security Trading Snapshot Dimension',
    public_company_dim_id               String                  COMMENT 'FK → Public Company Dimension',
    snpst_dt_dim_id                       String                  COMMENT 'FK → Calendar Date Dimension',
    fr_period_end_dt_dim_id             Nullable(String)        COMMENT 'FK → Calendar Date Dimension (Role-Playing: Financial Report Period End Date) — bổ sung 2026-09-08 theo rule GSĐC',
    total_vol                           Nullable(Int64)         COMMENT '[SỬA COMMENT 2026-09-16, không đổi giá trị/ETL] Tổng khối lượng giao dịch cổ phiếu/CCQ 3 sàn — GỘP CẢ khớp lệnh VÀ thỏa thuận, loại trừ phái sinh và trái phiếu. Comment cũ ghi nhầm "khớp lệnh" — phục vụ K_GSTT_146 (Nhóm 33), không phải K_GSTT_13 (đã chuyển sang total_matched_vol)',
    total_val                           Nullable(Decimal(23,2)) COMMENT '[SỬA COMMENT 2026-09-16, không đổi giá trị/ETL] Tổng giá trị giao dịch cổ phiếu/CCQ 3 sàn — GỘP CẢ khớp lệnh VÀ thỏa thuận, loại trừ phái sinh và trái phiếu. Comment cũ ghi nhầm "khớp lệnh" — phục vụ K_GSTT_147 (Nhóm 33), không phải K_GSTT_14 (đã chuyển sang total_matched_val)',
    total_matched_vol                   Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch khớp lệnh thuần (loại trừ thỏa thuận) cổ phiếu/CCQ 3 sàn, loại trừ phái sinh và trái phiếu. [CẬP NHẬT 2026-09-16] Nay là nguồn của K_GSTT_13 (Nhóm 1 và các Nhóm reuse 3/9/10/23/24/29/30)',
    total_matched_val                   Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch khớp lệnh thuần (loại trừ thỏa thuận) cổ phiếu/CCQ 3 sàn, loại trừ phái sinh và trái phiếu. [CẬP NHẬT 2026-09-16] Nay là nguồn của K_GSTT_14 (Nhóm 1 và các Nhóm reuse 3/9/10/23/24/29/30)',
    total_derivative_vol                Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch phái sinh',

    total_derivative_val                Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch phái sinh',
    total_negotiated_vol                Nullable(Int64)         COMMENT '[SỬA FILTER 2026-09-11] Tổng khối lượng giao dịch thỏa thuận — filter Market Id Code IN (UPX,STX,STK) AND Board Type Code IN (T1-T4,T6,R1), đóng O_GSTT_20',
    total_negotiated_val                Nullable(Decimal(23,2)) COMMENT '[SỬA FILTER 2026-09-11] Tổng giá trị giao dịch thỏa thuận — filter Market Id Code IN (UPX,STX,STK) AND Board Type Code IN (T1-T4,T6,R1), đóng O_GSTT_20',
    foreign_net_vol                     Nullable(Int64)         COMMENT 'Khối lượng mua ròng của nhà đầu tư nước ngoài',
    foreign_net_negotiated_vol          Nullable(Int64)         COMMENT '[MỚI 2026-09-09, SỬA FILTER 2026-09-11] Khối lượng mua ròng của NĐT nước ngoài, giao dịch thỏa thuận (Market Id Code IN (UPX,STX,STK) AND Board Type IN T1-T4,T6,R1) — khác foreign_net_vol (khớp lệnh). BA STT 1 dòng con 21, K_GSTT_144, đóng O_GSTT_20',
    foreign_net_derivative_vol          Nullable(Int64)         COMMENT '[MỚI 2026-09-17] Khối lượng mua ròng của NĐT nước ngoài trên thị trường phái sinh (Market ID = DVX, khớp lệnh). K_GSTT_148, bổ sung KPI thiếu phát hiện qua rà soát BA↔KPI toàn diện',
    outstanding_share_quantity          Nullable(Int64)         COMMENT 'Số cổ phiếu đang lưu hành — nguồn VSDC listed_share_info (outstanding_shares), bản ghi gần nhất <= ngày GD (lookback, sửa 2026-09-16)',
    revenue                             Nullable(Decimal(23,2)) COMMENT 'Doanh thu — point-in-time theo Ky_bao_cao (rule GSĐC, cập nhật 2026-09-08)',
    net_profit_after_tax                Nullable(Decimal(23,2)) COMMENT 'Lợi nhuận sau thuế — point-in-time theo Ky_bao_cao (rule GSĐC, cập nhật 2026-09-08)',
    net_profit_after_tax_ttm            Nullable(Decimal(23,2)) COMMENT 'LNST TTM 4 quý gần nhất có ngay_ket_thuc <= ngày GD, NULL nếu không đủ 4 kỳ — dùng cho P/E, EPS (rule GSĐC, cập nhật 2026-09-08)',
    owner_equity                        Nullable(Decimal(23,2)) COMMENT 'Vốn chủ sở hữu — quý gần nhất đã công bố có ngay_ket_thuc <= ngày GD (rule GSĐC, cập nhật 2026-09-08)',
    fr_period_end_dt                    Nullable(Date)          COMMENT 'Ngày kết thúc của kỳ báo cáo tài chính gần nhất — làm phẳng từ fr_period_end_dt_dim_id (bổ sung 2026-09-08, rule GSĐC)',
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
    fct_close_price                     Nullable(Decimal(23,2)) COMMENT '[SỬA 2026-09-07] Giá đóng cửa theo ngày lưu trên Fact (khác close_price ở Security Trading Snapshot Dimension — SCD4A current-state) — bổ sung 2026-09-04, thiếu sót trong flat table trước đây, nay bổ sung để phục vụ window function K_GSTT_106/107/140-143 (Đỉnh/Đáy cũ)',
    fct_high_price                      Nullable(Decimal(23,2)) COMMENT '[SỬA 2026-09-19, lần 4] Giá cao nhất theo ngày lưu trên Fact (khác high_price ở Security Trading Snapshot Dimension — SCD4A current-state) — phục vụ window function K_GSTT_106/140/141 (Đỉnh cũ/Giá cao nhất N tháng), đổi lại từ close_price sau khi đối chiếu lại BA (Nhóm 15/17/32)',
    fct_low_price                       Nullable(Decimal(23,2)) COMMENT '[SỬA 2026-09-19, lần 4] Giá thấp nhất theo ngày lưu trên Fact — phục vụ window function K_GSTT_107/142/143 (Đáy cũ/Giá thấp nhất N tháng)',
    fct_reference_price                 Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-14, đóng O_GSTT_21 — đơn giản hóa theo góp ý Data Modeler] Giá tham chiếu theo ngày lưu trên Fact — đã do sàn tính đúng theo quy tắc riêng từng sàn (HOSE/HNX = Close Price phiên trước, UPCOM = VWAP phiên trước). Phục vụ K_GSTT_145: lấy thẳng dòng tại Từ ngày, không cần self-join/CASE floor',
    prior_market_cap                    Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-19, review Nhóm 24, xem O_GSTT_25] Vốn hóa mã CK tại phiên LIỀN TRƯỚC (T-1) — LAG(Close Price × Outstanding Share Quantity), lưu sẵn trên dòng T. Phục vụ K_GSTT_74 (trọng số w_i đúng ngày T-1, sửa bug lấy nhầm vốn hóa ngày T)',
    prior_free_float_market_cap         Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-19, review Nhóm 24, xem O_GSTT_25] Vốn hóa tự do chuyển nhượng mã CK tại phiên LIỀN TRƯỚC (T-1) — LAG(Close Price × Free Float Share Quantity). Phục vụ K_GSTT_76 (trọng số w_ff_i đúng ngày T-1)',
    free_float_share_quantity           Nullable(Int64)         COMMENT '[SỬA 2026-09-14] Khối lượng cổ phiếu tự do chuyển nhượng — nguồn VSDC listed_share_info (outstanding_shares), phục vụ K_GSTT_76/125 (Nhóm 24)',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)          COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',
    is_trading_date                     Nullable(String)        COMMENT 'Cờ Y/N — ngày lịch có phải ngày thị trường thực sự mở cửa giao dịch hay không (bổ sung 2026-09-05, partial trên cdr_dt_dim, yêu cầu trực tiếp từ user). Dùng suy ra ngày giao dịch gần nhất = MAX(cdr_dt) WHERE is_trading_date=\'Y\' — tham số lọc mặc định dashboard/báo cáo GSTT (K_GSTT_128)',

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
    public_company_src_stm_code          Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Public Company Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), security_trading_snpst_dim_id)
COMMENT 'Flat table — Fact Stock Portfolio Snapshot × Calendar Date × Security Trading Snapshot Dimension × Public Company Dimension'
;


-- ============================================================
-- 1b. FACT: gstt_fct_index_constituent_snpst_flat
--    [SỬA 2026-09-14] Bridge (3 FK) — thành viên rổ chỉ số theo ngày,
--    1 row / mã CK / rổ chỉ số / ngày giao dịch. Tách khỏi
--    gstt_fct_stock_portfolio_snpst_flat để hết fan-out theo rổ chỉ số
--    (xem HLD v4.13, Cụm 1b). Dùng để lọc/SUM mã CK theo rổ chỉ số —
--    JOIN sang gstt_fct_stock_portfolio_snpst_flat qua symbol + cdr_dt khi cần measure
--    riêng theo mã CK. [SỬA 2026-09-14, theo yêu cầu Design] Bổ sung 8 measure tính sẵn
--    theo Index+Date (idx_*) — giá trị LẶP LẠI trên mọi dòng symbol cùng index_code+cdr_dt,
--    dùng MAX()/DISTINCT khi truy vấn, KHÔNG SUM lại.
--    Joins: Calendar Date (snpst_dt_dim_id JOIN) × Security Trading Snapshot Dimension ×
--           Index Constituent Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_fct_index_constituent_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Index Constituent Snapshot
    security_trading_snpst_dim_id       String                  COMMENT 'FK → Security Trading Snapshot Dimension',
    index_constituent_dim_id            String                  COMMENT 'FK → Index Constituent Dimension',
    snpst_dt_dim_id                     String                  COMMENT 'FK → Calendar Date Dimension',
    idx_total_matched_vol                Nullable(Int64)         COMMENT '[SỬA 2026-09-14, review sheet Tổng hợp công thức] Tổng KLGD khớp lệnh thuần (loại thỏa thuận) toàn rổ chỉ số theo Index+Date — lặp lại trên mọi dòng symbol cùng rổ, không SUM lại',
    idx_total_matched_val                Nullable(Decimal(23,2)) COMMENT '[SỬA 2026-09-14, review sheet Tổng hợp công thức] Tổng GTGD khớp lệnh thuần (loại thỏa thuận) toàn rổ chỉ số theo Index+Date — lặp lại trên mọi dòng symbol cùng rổ, không SUM lại',
    idx_foreign_net_vol                 Nullable(Int64)         COMMENT '[MỚI 2026-09-14] KLNN ròng toàn rổ chỉ số theo Index+Date — lặp lại trên mọi dòng symbol cùng rổ, không SUM lại',
    idx_foreign_net_val                 Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-14] GTNN ròng toàn rổ chỉ số theo Index+Date — lặp lại trên mọi dòng symbol cùng rổ, không SUM lại',
    idx_total_negotiated_vol            Nullable(Int64)         COMMENT '[MỚI 2026-09-14] Tổng KLGD thỏa thuận toàn rổ chỉ số theo Index+Date — lặp lại trên mọi dòng symbol cùng rổ, không SUM lại',
    idx_total_negotiated_val            Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-14] Tổng GTGD thỏa thuận toàn rổ chỉ số theo Index+Date — lặp lại trên mọi dòng symbol cùng rổ, không SUM lại',
    idx_market_cap                      Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-14, SỬA 2026-09-16] Vốn hóa thị trường toàn rổ chỉ số theo Index+Date (nguồn VSDC listed_share_info) — lặp lại trên mọi dòng symbol cùng rổ, không SUM lại',
    idx_free_float_market_cap           Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-14] Vốn hóa tự do chuyển nhượng toàn rổ chỉ số theo Index+Date — lặp lại trên mọi dòng symbol cùng rổ, không SUM lại',
    idx_pe                               Nullable(Decimal(10,2)) COMMENT '[MỚI 2026-09-19, review Nhóm 6] P/E CỦA CHỈ SỐ = SUM(Vốn hóa mã có LNST TTM)/SUM(LNST TTM) theo Index+Date — khác K_GSTT_58 (P/E từng mã, trên fct_stock_portfolio_snpst). Lặp lại trên mọi dòng symbol cùng rổ, không SUM/AVG lại',
    idx_pb                               Nullable(Decimal(10,2)) COMMENT '[MỚI 2026-09-19, review Nhóm 6] P/B CỦA CHỈ SỐ = SUM(Vốn hóa mã có VCSH)/SUM(VCSH) theo Index+Date — khác K_GSTT_59 (P/B từng mã). Lặp lại trên mọi dòng symbol cùng rổ, không SUM/AVG lại',
    idx_eps                             Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-19, review Nhóm 6] EPS CỦA CHỈ SỐ = SUM(LNST TTM)/SUM(Số CP lưu hành) theo Index+Date — khác K_GSTT_60 (EPS từng mã); xem O_GSTT_24 về lọc mẫu số. Lặp lại trên mọi dòng symbol cùng rổ, không SUM/AVG lại',
    idx_prior_market_cap                Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-19, review Nhóm 24, xem O_GSTT_25] LAG(idx_market_cap) 1 phiên theo Index Code — Tổng vốn hóa rổ chỉ số tại T-1. Phục vụ K_GSTT_74 (mẫu số trọng số w_i đúng ngày T-1)',
    idx_prior_free_float_market_cap     Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-19, review Nhóm 24, xem O_GSTT_25] LAG(idx_free_float_market_cap) 1 phiên theo Index Code — Tổng vốn hóa tự do chuyển nhượng rổ tại T-1. Phục vụ K_GSTT_76 (mẫu số w_ff_i)',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)          COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',
    is_trading_date                     Nullable(String)        COMMENT '[BỔ SUNG 2026-09-14] Cờ Y/N — ngày lịch có phải ngày thị trường thực sự mở cửa giao dịch hay không — từ Calendar Date Dimension',

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    symbol                              Nullable(String)        COMMENT 'Mã chứng khoán — từ Security Trading Snapshot Dimension',

    -- From: INDEX CONSTITUENT DIMENSION
    index_code                          Nullable(String)        COMMENT 'Mã rổ chỉ số — từ Index Constituent Dimension',
    index_id                            Nullable(String)        COMMENT 'Id chỉ số — từ Index Constituent Dimension',
    index_nm                            Nullable(String)        COMMENT '[MỚI 2026-09-15] Tên chuẩn của chỉ số (VN-Index/HNX-Index/UPCoM-Index/VN30...) — từ Index Constituent Dimension, JOIN sang Market Index Snapshot theo Market Code = Index Code (không CASE WHEN), cùng nguồn Index Name dùng ở Market Index Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), security_trading_snpst_dim_id, index_constituent_dim_id)
COMMENT 'Flat table — Fact Index Constituent Snapshot (Bridge) × Calendar Date × Security Trading Snapshot Dimension × Index Constituent Dimension'
;


-- ============================================================
-- 2. FACT: gstt_fct_market_index_intraday_flat
--    Diễn biến chỉ số thị trường realtime trong ngày — 1 row / chỉ số thị trường
--    (market_code) / Index Time — KHÔNG lọc rn=1 (khác Fact EOD fct_market_index_snpst)
--    Grain: Transaction/Tick log — nhiều dòng/ngày theo Index Time, có thể append
--    thêm tick mới trong cùng ngày khi ETL chạy nhiều lần/ngày
--    Joins: Calendar Date (trade_dt_dim_id JOIN) × Market Index Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_fct_market_index_intraday_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Market Index Intraday
    market_index_dim_id                 String                  COMMENT 'FK → Market Index Dimension',
    trade_dt_dim_id                       String                  COMMENT 'FK → Calendar Date Dimension',
    index_time                          Nullable(String)        COMMENT 'Thời gian ghi nhận chỉ số trong ngày (DD — grain component)',
    market_index_val_at_time            Nullable(Decimal(23,2)) COMMENT 'Điểm chỉ số tại thời điểm ghi nhận',
    total_val_at_time                   Nullable(Decimal(23,2)) COMMENT 'Giá trị giao dịch phát sinh tại thời điểm ghi nhận',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)          COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',
    is_trading_date                     Nullable(String)        COMMENT '[BỔ SUNG 2026-09-14] Cờ Y/N — ngày lịch có phải ngày thị trường thực sự mở cửa giao dịch hay không — từ Calendar Date Dimension',

    -- From: MARKET INDEX DIMENSION
    market_id                           Nullable(String)        COMMENT 'Mã thị trường — từ Market Index Dimension',
    market_code                         Nullable(String)        COMMENT 'Mã sàn/chỉ số (HOSE/HNX/UPCOM/30) — từ Market Index Dimension',
    index_nm                            Nullable(String)        COMMENT 'Tên chuẩn của chỉ số (VN-Index/HNX-Index/UPCoM-Index/VN30...) theo MDDS.JAD_MARKETINFOR.INDEXNAME — từ Market Index Dimension, dùng hiển thị thay market_code',
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
-- 3. FACT: gstt_fct_security_trading_intraday_flat
--    Biểu đồ phân tích kỹ thuật — 1 row / mã CK (Symbol) / Trading Timestamp —
--    [SỬA 2026-09-07] Nguồn Atomic đổi sang Market Price Snapshot (nến OHLCV
--    thật theo phút, MDDS.JAD_TRADINGVIEWHISTORY1MIN, filter
--    src_stm_code='MDDS_JAD_TRADINGVIEWHISTORY1MIN'), thay workaround trading_tms
--    cũ (nối trading_dt+trading_time trên Security Trading Snapshot, giá trị
--    lũy kế-tick sai bản chất nến — xem O_GSTT_11). trading_tms nay = nối
--    market_price_snapshot.trading_dt + processing_time.
--    Grain: 1 row / Symbol / (Trading Date, Processing Time) — 1 nến/phút,
--    KHÔNG lọc rn=1 (khác Fact EOD security_trading_snpst_dim)
--    Joins: Calendar Date (trade_dt_dim_id JOIN) × Security Trading Snapshot Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_fct_security_trading_intraday_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Security Trading Intraday
    security_trading_snpst_dim_id       String                  COMMENT 'FK → Security Trading Snapshot Dimension',
    trade_dt_dim_id                       String                  COMMENT 'FK → Calendar Date Dimension',
    trading_tms                         Nullable(DateTime)      COMMENT 'Thời điểm ghi nhận nến trong ngày (DD — grain component, nối Market Price Snapshot trading_dt + processing_time)',
    open_price_at_time                  Nullable(Decimal(23,2)) COMMENT 'Giá mở cửa tại thời điểm ghi nhận',
    high_price_at_time                  Nullable(Decimal(23,2)) COMMENT 'Giá cao nhất tại thời điểm ghi nhận',
    low_price_at_time                   Nullable(Decimal(23,2)) COMMENT 'Giá thấp nhất tại thời điểm ghi nhận',
    close_price_at_time                 Nullable(Decimal(23,2)) COMMENT 'Giá đóng cửa (khớp gần nhất) tại thời điểm ghi nhận',
    cumulative_vol_at_time              Nullable(Int64)         COMMENT 'Khối lượng khớp lũy kế từ đầu ngày tại thời điểm ghi nhận — không phải KL phát sinh riêng tại thời điểm đó',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)          COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',
    is_trading_date                     Nullable(String)        COMMENT '[BỔ SUNG 2026-09-14] Cờ Y/N — ngày lịch có phải ngày thị trường thực sự mở cửa giao dịch hay không — từ Calendar Date Dimension',

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    symbol                               Nullable(String)        COMMENT 'Mã chứng khoán — từ Security Trading Snapshot Dimension',
    security_full_nm                    Nullable(String)        COMMENT 'Tên chứng khoán — từ Security Trading Snapshot Dimension',
    floor_code                          Nullable(String)        COMMENT 'Mã sàn — từ Security Trading Snapshot Dimension',
    stock_tp_code                       Nullable(String)        COMMENT 'Loại chứng khoán — từ Security Trading Snapshot Dimension',
    stock_tp_nm                         Nullable(String)        COMMENT 'Tên loại chứng khoán — từ Security Trading Snapshot Dimension',
    security_trading_src_stm_code       Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Security Trading Snapshot Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), security_trading_snpst_dim_id, trading_tms)
COMMENT 'Flat table — Fact Security Trading Intraday × Calendar Date Dimension × Security Trading Snapshot Dimension'
;


-- ============================================================
-- 4. FACT: gstt_fct_foreign_trading_min_snpst_flat
--    [BỔ SUNG 2026-09-11] Thiết kế thật đã Resolved 2026-09-04 (O_GSTT_8, K_GSTT_78-80)
--    nhưng bị bỏ sót khỏi Phase 3 — bổ sung lại cho khớp Attributes/Detail Mapping/HLD
--    đã có sẵn từ trước, không phải thiết kế mới.
--    Dòng tiền NĐT nước ngoài theo phút — 1 row / mã CK (Symbol) / Trade Minute
--    Grain: nguồn Securities Trade (per-trade, GROUP BY phút) — khác Fact Security
--    Trading Intraday (nguồn Security Trading Snapshot, per-tick MDDS)
--    Joins: Calendar Date (snpst_dt_dim_id JOIN) × Security Trading Snapshot Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_fct_foreign_trading_min_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Foreign Trading Minute Snapshot
    security_trading_snpst_dim_id       String                  COMMENT 'FK → Security Trading Snapshot Dimension',
    snpst_dt_dim_id                       String                  COMMENT 'FK → Calendar Date Dimension',
    trade_minute_tms                    Nullable(DateTime)      COMMENT 'Mốc phút xác định grain (DD — grain component), DATE_TRUNC(minute, Trade Timestamp)',
    foreign_buy_val_at_min              Nullable(Decimal(23,2)) COMMENT 'Giá trị mua của NĐT nước ngoài trong phút (K_GSTT_78)',
    foreign_sell_val_at_min             Nullable(Decimal(23,2)) COMMENT 'Giá trị bán của NĐT nước ngoài trong phút (K_GSTT_79)',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)          COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',
    is_trading_date                     Nullable(String)        COMMENT '[BỔ SUNG 2026-09-14] Cờ Y/N — ngày lịch có phải ngày thị trường thực sự mở cửa giao dịch hay không — từ Calendar Date Dimension',

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    symbol                               Nullable(String)        COMMENT 'Mã chứng khoán — từ Security Trading Snapshot Dimension',
    security_full_nm                    Nullable(String)        COMMENT 'Tên chứng khoán — từ Security Trading Snapshot Dimension',
    floor_code                          Nullable(String)        COMMENT 'Mã sàn — từ Security Trading Snapshot Dimension',
    stock_tp_code                       Nullable(String)        COMMENT 'Loại chứng khoán — từ Security Trading Snapshot Dimension',
    stock_tp_nm                         Nullable(String)        COMMENT 'Tên loại chứng khoán — từ Security Trading Snapshot Dimension',
    foreign_trading_min_src_stm_code    Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Security Trading Snapshot Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), security_trading_snpst_dim_id, trade_minute_tms)
COMMENT 'Flat table — Fact Foreign Trading Minute Snapshot × Calendar Date Dimension × Security Trading Snapshot Dimension'
;


-- ============================================================
-- 5. OPERATIONAL: gstt_opr_public_company_shareholding_flat
--    [SỬA 2026-09-12, đảo ngược O_GSTT_9] Sở hữu cổ đông + chức vụ người nội bộ
--    + sở hữu NN/trong nước — 1 row / (Public Company × Legal Entity/cổ đông).
--    Gộp 3 nguồn Atomic: pc_shareholding (IDS.COMPANY_SHAREHOLDING), legal_entity
--    (IDS.LEGAL_ENTITIES), foreign_ownership_info (VSDC, mapping doc). Đồng thời
--    denormalize Position Code từ Legal Entity Position (K_GSTT_104 vẫn dùng
--    `legal_entity_position_dim` độc lập, không đổi). Phục vụ Nhóm 31 (8/8 KPI
--    READY) và Nhóm 34 (Data Explorer, reuse 6/8 KPI). Không FK Star Schema —
--    Operational denormalized hoàn toàn, K_GSTT_100 (Mã cổ phiếu) vẫn dùng riêng
--    `public_company_dim` (Nhóm 1), không phải cột của bảng này.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_opr_public_company_shareholding_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Public Company Shareholding
    public_company_shareholding_code    String                  COMMENT 'PK — mã sở hữu cổ đông (Bảng Tác nghiệp)',
    public_company_code                 String                  COMMENT 'Mã công ty đại chúng',
    legal_entity_code                   String                  COMMENT 'Mã cổ đông',
    legal_entity_nm                     Nullable(String)        COMMENT 'Tên cổ đông hoặc người nội bộ hoặc người liên quan (K_GSTT_101)',
    ownership_quantity                  Nullable(Int64)         COMMENT 'Số lượng cổ phiếu nắm giữ (K_GSTT_102)',
    ownership_ratio_percentage          Nullable(Decimal(5,2))  COMMENT 'Phần trăm nắm giữ (K_GSTT_103, K_GSTT_103b filter Insider)',
    ownership_dt                        Nullable(Date)          COMMENT 'Ngày đạt tỷ lệ sở hữu',
    major_shareholder_ind               String                  COMMENT 'Là cổ đông lớn — Y/N',
    insider_shareholder_ind             String                  COMMENT 'Là cổ đông nội bộ — Y/N (dùng filter K_GSTT_103b)',
    shareholder_tp_code                 Array(String)           COMMENT 'Loại cổ đông (có thể nhiều loại cùng lúc) — scheme IDS_SHAREHOLDER_TYPE',
    position_code                       Array(String)           COMMENT '[SỬA 2026-09-16] Chức vụ người nội bộ (có thể nhiều chức vụ ACTIVE cùng lúc) — denormalize từ Legal Entity Position (K_GSTT_104), populate bằng groupUniqArray(). Đổi từ Nullable(String) sang Array(String) — 1 legal_entity có thể giữ nhiều chức vụ tại cùng công ty, tránh nhân dòng bảng cổ phần. Khai thác: loc theo 1 chuc vu dung has(position_code, X) KHONG dung = X; hien thi dung arrayStringConcat(position_code, , ). Da bo appointment_dt/dismissal_dt — khong luu chuc vu theo thoi gian tren bang current-state nay, can lay tu Legal Entity Position Dimension neu can',
    current_foreign_holding_ratio       Nullable(Decimal(5,2))  COMMENT 'Tỷ lệ sở hữu NĐT nước ngoài (K_GSTT_120) — cấp công ty, lặp lại theo mọi dòng cổ đông cùng công ty',
    src_stm_code                        String                  COMMENT 'Mã hệ thống nguồn — IDS_COMPANY_SHAREHOLDING'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(ownership_dt))
ORDER BY (assumeNotNull(ownership_dt), public_company_shareholding_code)
COMMENT 'Flat table — Operational Public Company Shareholding (latest state per cổ đông × công ty)'
;
