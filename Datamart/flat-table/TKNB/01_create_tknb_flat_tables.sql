-- ============================================================
-- TKNB Flat Tables — CREATE
-- Module: Thống kê nội bộ (TKNB)
-- Generated: Phase 3 LLD Datamart
-- 14 bảng: 8 FACT + 6 operational EAV/danh sách (2026-11-04: TTLK01/TTLK10 chuyển Operational → Fact). `item_value` KHÔNG có flat gộp (Data Modeler bỏ 2026-10-25): 14 flat ClickHouse theo báo cáo của pipeline dev nằm ở file 03_clickhouse_per_report_flat_from_item_value.sql
-- Operational: KHÔNG JOIN Calendar Date, KHÔNG JOIN dim nào khác; FACT: JOIN dim theo thiết kế
-- ============================================================

-- ============================================================
-- 4. OPERATIONAL: hnx04_market_scale_rpt
--    Market Scale Report (HNX04)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_hnx04_market_scale_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Market Scale Report (HNX04)
    report_code         String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt    Date                     COMMENT 'BK — kỳ báo cáo',
    item_code           String                   COMMENT 'PK — mã chỉ tiêu EAV, gán theo danh mục cố định của mẫu biểu HNX04',
    period_type         String                   COMMENT 'BK — loại kỳ: trong_ky (phát sinh trong tháng) hoặc cong_don (lũy kế từ đầu năm)',
    item_stt            Int64                    COMMENT 'Số thứ tự hiển thị của chỉ tiêu theo đúng layout mẫu biểu gốc',
    item_unit           Nullable(String)         COMMENT 'Đơn vị tính của chỉ tiêu',
    item_value          Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu — populate theo item_code và period_type, mỗi chỉ tiêu lấy nguồn nghiệp vụ tương ứng (giá trị/khối lượng giao dịch, thông tin niêm yết, chỉ số thị trường)',
    src_stm_code        String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, item_code, period_type)
COMMENT 'Flat table — Market Scale Report (HNX04)'
;


-- ============================================================
-- 7. OPERATIONAL: hsx02_listing_trading_rpt
--    Listing Trading Report (HSX02)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_hsx02_listing_trading_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Listing Trading Report (HSX02)
    report_code         String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt    Date                     COMMENT 'BK — kỳ báo cáo',
    item_code           String                   COMMENT 'PK — mã chỉ tiêu EAV, gán theo danh mục cố định của mẫu biểu HSX02',
    period_type         String                   COMMENT 'BK — loại kỳ: trong_ky (phát sinh trong tháng) hoặc cong_don (lũy kế từ đầu năm)',
    item_stt            Int64                    COMMENT 'Số thứ tự hiển thị của chỉ tiêu theo đúng layout mẫu biểu gốc',
    item_unit           Nullable(String)         COMMENT 'Đơn vị tính của chỉ tiêu',
    item_value          Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu — populate theo item_code và period_type, mỗi chỉ tiêu lấy nguồn nghiệp vụ tương ứng (giá trị/khối lượng giao dịch, thông tin niêm yết) trên sàn HOSE',
    src_stm_code        String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, item_code, period_type)
COMMENT 'Flat table — Listing Trading Report (HSX02)'
;


-- ============================================================
-- 9. FACT: fct_covered_warrant_outstanding_snpst
--    Fact Covered Warrant Outstanding Snapshot (Nhóm 14 — TTLK10; grain 1 mã CW × 1 ngày giao dịch, PK covered_warrant_outstanding_snpst_id)
--    Joins: Calendar Date × Security Trading Snapshot Dimension (reuse GSTT)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_fct_covered_warrant_outstanding_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Covered Warrant Outstanding Snapshot
    covered_warrant_outstanding_snpst_id  String                  COMMENT 'PK — hash(snpst_dt_dim_id, security_trading_snpst_dim_id, src_stm_code); grain 1 mã chứng quyền × 1 ngày giao dịch',
    snpst_dt_dim_id                       String                  COMMENT 'Snapshot Date Dimension Id',
    security_trading_snpst_dim_id         String                  COMMENT 'Security Trading Snapshot Dimension Id',
    outstanding_quantity                  Nullable(Int64)         COMMENT 'Outstanding Quantity',
    src_stm_code                          String                  COMMENT 'Source System Code',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                          Nullable(Date)          COMMENT 'Ngày snapshot — từ Calendar Date Dimension',

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    symbol                                Nullable(String)        COMMENT 'Mã chứng khoán/chứng quyền — từ Security Trading Snapshot Dimension',
    security_full_nm                      Nullable(String)        COMMENT 'Tên đầy đủ chứng khoán/chứng quyền — từ Security Trading Snapshot Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), covered_warrant_outstanding_snpst_id)
COMMENT 'Flat table — Fact Covered Warrant Outstanding Snapshot × Calendar Date × Security Trading Snapshot Dimension'
;


-- ============================================================
-- 10. OPERATIONAL: 0513hubckqg_offering_result_rpt
--    Offering Result Report (0513.H.UBCK.QG)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_0513hubckqg_offering_result_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Offering Result Report (0513.H.UBCK.QG)
    report_code         String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt    Date                     COMMENT 'BK — kỳ báo cáo (ngày kết quả phát hành)',
    item_code           String                   COMMENT 'PK — mã chỉ tiêu EAV, gán theo danh mục cố định của mẫu biểu 0513.H.UBCK.QG',
    item_stt            Int64                    COMMENT 'Số thứ tự hiển thị của chỉ tiêu theo đúng layout mẫu biểu gốc',
    item_unit           Nullable(String)         COMMENT 'Đơn vị tính của chỉ tiêu',
    item_value          Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu — populate theo item_code, số lượng hoặc giá trị kết quả phát hành chứng khoán theo hình thức phát hành',
    src_stm_code        String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, item_code)
COMMENT 'Flat table — Offering Result Report (0513.H.UBCK.QG)'
;


-- ============================================================
-- 11. OPERATIONAL: tk04btc_market_summary_rpt
--    Market Summary Report (TK-04.BTC)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_tk04btc_market_summary_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Market Summary Report (TK-04.BTC)
    report_code         String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt    Date                     COMMENT 'BK — kỳ báo cáo',
    item_code           String                   COMMENT 'PK — mã chỉ tiêu EAV, gán theo danh mục cố định của mẫu biểu TK-04.BTC',
    period_marker       String                   COMMENT 'BK — kỳ gốc: Q1, Q2 hoặc Q3 (không lưu H1/9M vật lý, derive lúc đọc theo measure_type)',
    measure_type        String                   COMMENT 'Loại đo lường quyết định cách derive H1/9M ở tầng BI: flow (cộng dồn được, VD KLGD/GTGD) hoặc snapshot (tại 1 thời điểm chốt, VD vốn hóa, OI)',
    item_stt            Int64                    COMMENT 'Số thứ tự hiển thị của chỉ tiêu theo đúng layout mẫu biểu gốc',
    item_unit           Nullable(String)         COMMENT 'Đơn vị tính của chỉ tiêu',
    item_value          Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu — populate theo item_code, period_marker và measure_type, mỗi chỉ tiêu lấy nguồn nghiệp vụ tương ứng (vốn hóa, số TK NĐT, giao dịch, niêm yết, CKPS, cổ phần hóa, huy động vốn, doanh thu CTCK/CTQLQ)',
    src_stm_code        String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, item_code, period_marker)
COMMENT 'Flat table — Market Summary Report (TK-04.BTC)'
;


-- ============================================================
-- 12. OPERATIONAL: tkniengiam_market_annual_rpt
--    Market Annual Report (TK_NienGiam)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_tkniengiam_market_annual_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Market Annual Report (TK_NienGiam)
    report_code         String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt    Date                     COMMENT 'BK — kỳ báo cáo (năm)',
    item_code           String                   COMMENT 'PK — mã chỉ tiêu EAV, gán theo danh mục cố định của mẫu biểu TK_NienGiam',
    item_stt            Int64                    COMMENT 'Số thứ tự hiển thị của chỉ tiêu theo đúng layout mẫu biểu gốc',
    item_unit           Nullable(String)         COMMENT 'Đơn vị tính của chỉ tiêu',
    item_value          Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu — populate theo item_code theo năm báo cáo, mỗi chỉ tiêu lấy nguồn nghiệp vụ tương ứng (chỉ số, vốn hóa, giao dịch, niêm yết, số lượng công ty/CTCK/CTQLQ) breakdown theo sàn',
    src_stm_code        String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, item_code)
COMMENT 'Flat table — Market Annual Report (TK_NienGiam)'
;


-- ============================================================
-- 13. FACT: fct_market_trading_snpst
--    Fact Market Trading Snapshot; grain 1 ngày giao dịch × 1 chỉ số (Index Code), PK market_trading_snpst_id
--    [SỬA 2026-09-22, datamart-review — Kịch bản D] Thay thế bm030amss_market_trading_rpt
--    (EAV, DEPRECATED — đã gộp sai 2 grain khác nhau) bằng Fact chuẩn Star Schema.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_fct_market_trading_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Market Trading Snapshot
    market_trading_snpst_id  String      COMMENT 'PK — hash(snpst_dt_dim_id, index_constituent_dim_id, src_stm_code); grain 1 ngày giao dịch × 1 chỉ số (Index Code)',
    snpst_dt_dim_id         String      COMMENT 'FK tới Calendar Date Dimension theo ngày giao dịch',
    index_constituent_dim_id String     COMMENT '[SỬA 2026-09-23] FK tới Index Constituent Dimension — Loại chỉ số K_TKNB_1013 (grain Trade Date × Index Code)',
    total_trading_val       Decimal(23,2) COMMENT 'Tổng giá trị giao dịch cổ phiếu của các mã thuộc chỉ số (Index Code) trong ngày — BA BM030a 27/10',
    total_trading_vol       Int64       COMMENT 'Tổng khối lượng giao dịch cổ phiếu của các mã thuộc chỉ số (Index Code) trong ngày',
    matched_trading_val     Decimal(23,2) COMMENT 'Giá trị giao dịch khớp lệnh (board G1,G2,G3,G7,G8) của các mã thuộc chỉ số trong ngày',
    matched_trading_vol     Int64       COMMENT 'Khối lượng giao dịch khớp lệnh (board G1,G2,G3,G7,G8) của các mã thuộc chỉ số trong ngày',
    negotiated_trading_val  Decimal(23,2) COMMENT 'Giá trị giao dịch thỏa thuận (board T1,T2,T3,R1) của các mã thuộc chỉ số trong ngày',
    negotiated_trading_vol  Int64       COMMENT 'Khối lượng giao dịch thỏa thuận (board T1,T2,T3,R1) của các mã thuộc chỉ số trong ngày',
    odd_lot_trading_val     Decimal(23,2) COMMENT 'Giá trị giao dịch lô lẻ (board G4,T4,T6) của các mã thuộc chỉ số trong ngày',
    odd_lot_trading_vol     Int64       COMMENT 'Khối lượng giao dịch lô lẻ (board G4,T4,T6) của các mã thuộc chỉ số trong ngày',
    market_index_val        Nullable(Decimal(23,2)) COMMENT '[SỬA 2026-09-23] Giá trị chỉ số — bản ghi cuối ngày (K_TKNB_1014)',
    src_stm_code            String      COMMENT 'Mã hệ thống nguồn dữ liệu',

    -- From: CALENDAR DATE DIMENSION
    trade_cdr_dt             Nullable(Date) COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',

    -- From: INDEX CONSTITUENT DIMENSION
    index_code               Nullable(String) COMMENT 'Loại chỉ số (HOSE/HNX/UPCOM/30/HNX30/100) — từ Index Constituent Dimension',
    index_nm                 Nullable(String) COMMENT 'Tên hiển thị chỉ số — từ Index Constituent Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(trade_cdr_dt))
ORDER BY (assumeNotNull(trade_cdr_dt), index_constituent_dim_id, market_trading_snpst_id)
COMMENT 'Flat table — Fact Market Trading Snapshot × Calendar Date × Index Constituent Dimension'
;


-- ============================================================
-- 16. FACT: fct_foreign_proprietary_trading_index_snpst
--    Fact Foreign Proprietary Trading Index Snapshot; grain 1 ngày giao dịch × 1 chỉ số (Index Code), PK foreign_proprietary_trading_index_snpst_id
--    [SỬA 2026-09-22, datamart-review — Kịch bản D] Thay thế bm031amss_foreign_proprietary_trading_rpt
--    (EAV, DEPRECATED) bằng Fact chuẩn Star Schema, reuse Index Constituent Dimension (GSTT).
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_fct_foreign_proprietary_trading_index_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Foreign Proprietary Trading Index Snapshot
    foreign_proprietary_trading_index_snpst_id  String      COMMENT 'PK — hash(snpst_dt_dim_id, index_constituent_dim_id, src_stm_code); grain 1 ngày giao dịch × 1 chỉ số (Index Code)',
    snpst_dt_dim_id                         String      COMMENT 'FK tới Calendar Date Dimension theo ngày giao dịch',
    index_constituent_dim_id                String      COMMENT 'FK tới Index Constituent Dimension',
    foreign_investor_total_buy_vol          Int64       COMMENT 'Khối lượng mua của NĐTNN theo chỉ số trong ngày',
    foreign_investor_total_sell_vol         Int64       COMMENT 'Khối lượng bán của NĐTNN theo chỉ số trong ngày',
    foreign_investor_total_buy_val          Decimal(23,2) COMMENT 'Giá trị mua của NĐTNN theo chỉ số trong ngày',
    foreign_investor_total_sell_val         Decimal(23,2) COMMENT 'Giá trị bán của NĐTNN theo chỉ số trong ngày',
    foreign_investor_negotiated_buy_vol     Int64       COMMENT 'Khối lượng mua thỏa thuận của NĐTNN theo chỉ số trong ngày',
    foreign_investor_negotiated_sell_vol    Int64       COMMENT 'Khối lượng bán thỏa thuận của NĐTNN theo chỉ số trong ngày',
    foreign_investor_negotiated_buy_val     Decimal(23,2) COMMENT 'Giá trị mua thỏa thuận của NĐTNN theo chỉ số trong ngày',
    foreign_investor_negotiated_sell_val    Decimal(23,2) COMMENT 'Giá trị bán thỏa thuận của NĐTNN theo chỉ số trong ngày',
    foreign_investor_matched_buy_vol        Int64       COMMENT 'Khối lượng mua khớp lệnh của NĐTNN theo chỉ số trong ngày',
    foreign_investor_matched_sell_vol       Int64       COMMENT 'Khối lượng bán khớp lệnh của NĐTNN theo chỉ số trong ngày',
    foreign_investor_matched_buy_val        Decimal(23,2) COMMENT 'Giá trị mua khớp lệnh của NĐTNN theo chỉ số trong ngày',
    foreign_investor_matched_sell_val       Decimal(23,2) COMMENT 'Giá trị bán khớp lệnh của NĐTNN theo chỉ số trong ngày',
    proprietary_total_buy_vol               Int64       COMMENT 'Khối lượng mua của khối tự doanh theo chỉ số trong ngày',
    proprietary_total_sell_vol              Int64       COMMENT 'Khối lượng bán của khối tự doanh theo chỉ số trong ngày',
    proprietary_total_buy_val               Decimal(23,2) COMMENT 'Giá trị mua của khối tự doanh theo chỉ số trong ngày',
    proprietary_total_sell_val              Decimal(23,2) COMMENT 'Giá trị bán của khối tự doanh theo chỉ số trong ngày',
    proprietary_negotiated_buy_vol          Int64       COMMENT 'Khối lượng mua thỏa thuận của khối tự doanh theo chỉ số trong ngày',
    proprietary_negotiated_sell_vol         Int64       COMMENT 'Khối lượng bán thỏa thuận của khối tự doanh theo chỉ số trong ngày',
    proprietary_negotiated_buy_val          Decimal(23,2) COMMENT 'Giá trị mua thỏa thuận của khối tự doanh theo chỉ số trong ngày',
    proprietary_negotiated_sell_val         Decimal(23,2) COMMENT 'Giá trị bán thỏa thuận của khối tự doanh theo chỉ số trong ngày',
    proprietary_matched_buy_vol             Int64       COMMENT 'Khối lượng mua khớp lệnh của khối tự doanh theo chỉ số trong ngày',
    proprietary_matched_sell_vol            Int64       COMMENT 'Khối lượng bán khớp lệnh của khối tự doanh theo chỉ số trong ngày',
    proprietary_matched_buy_val             Decimal(23,2) COMMENT 'Giá trị mua khớp lệnh của khối tự doanh theo chỉ số trong ngày',
    proprietary_matched_sell_val            Decimal(23,2) COMMENT 'Giá trị bán khớp lệnh của khối tự doanh theo chỉ số trong ngày',
    src_stm_code                            String      COMMENT 'Mã hệ thống nguồn dữ liệu',

    -- From: CALENDAR DATE DIMENSION
    trade_cdr_dt              Nullable(Date) COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',

    -- From: INDEX CONSTITUENT DIMENSION
    index_code                Nullable(String) COMMENT 'Mã chỉ số — từ Index Constituent Dimension',
    index_id                  Nullable(String) COMMENT 'ID nội bộ của chỉ số — từ Index Constituent Dimension',
    index_nm                  Nullable(String) COMMENT 'Tên chỉ số — từ Index Constituent Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(trade_cdr_dt))
ORDER BY (assumeNotNull(trade_cdr_dt), index_constituent_dim_id, foreign_proprietary_trading_index_snpst_id)
COMMENT 'Flat table — Fact Foreign Proprietary Trading Index Snapshot'
;


-- ============================================================
-- 19. OPERATIONAL: bm031dmss_fund_cert_etf_cw_foreign_proprietary_trading_rpt
--    Fund Cert ETF CW Foreign Proprietary Trading Report (BM031d)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_bm031dmss_fund_cert_etf_cw_foreign_proprietary_trading_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Fund Cert ETF CW Foreign Proprietary Trading Report (BM031d)
    report_code         String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt    Date                     COMMENT 'BK — kỳ báo cáo',
    item_code           String                   COMMENT 'PK — mã chỉ tiêu EAV, gán theo danh mục cố định của mẫu biểu BM031d_MSS',
    item_stt            Int64                    COMMENT 'Số thứ tự hiển thị của chỉ tiêu theo đúng layout mẫu biểu gốc',
    item_unit           Nullable(String)         COMMENT 'Đơn vị tính của chỉ tiêu',
    item_value          Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu — populate theo item_code, khối lượng/giá trị giao dịch NĐTNN/tự doanh thị trường CCQ/ETF/CW',
    src_stm_code        String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, item_code)
COMMENT 'Flat table — Fund Cert ETF CW Foreign Proprietary Trading Report (BM031d)'
;


-- ============================================================
-- 21. FACT: fct_private_corporate_bond_international_offering_snpst
--    Fact Private Corporate Bond International Offering Snapshot (HNX12 — Nhóm 9); grain 1 mã trái phiếu × 1 thị trường phát hành × 1 kỳ báo cáo (rpt_year + rpt_month), PK private_corporate_bond_international_offering_snpst_id
--    Joins: Calendar Date × Private Corporate Bond Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_fct_private_corporate_bond_international_offering_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Private Corporate Bond International Offering Snapshot
    private_corporate_bond_international_offering_snpst_id  String                  COMMENT 'PK — hash(private_corporate_bond_dim_id, market_tp, rpt_year, rpt_month, src_stm_code); grain 1 mã trái phiếu × 1 thị trường phát hành × 1 kỳ báo cáo (rpt_year + rpt_month)',
    snpst_dt_dim_id                 String                  COMMENT 'FK ngày chụp dữ liệu biểu mẫu',
    private_corporate_bond_dim_id   String                  COMMENT 'FK mã trái phiếu',
    rpt_year                        Int64                   COMMENT 'Năm báo cáo — cùng rpt_month; khai thác lọc theo rpt_year + rpt_month (không theo ngày snapshot)',
    rpt_month                       Int64                   COMMENT 'Tháng báo cáo 1–12 (số lũy kế từ đầu năm) — Quý = 3/6/9/12',
    market_tp                       String                  COMMENT 'Thị trường phát hành quốc tế',
    currency_code                   Nullable(String)        COMMENT 'Đồng tiền phát hành',
    offering_bond_quantity          Nullable(Int64)         COMMENT 'Khối lượng phát hành (lũy kế tại tháng báo cáo)',
    posting_dt                      Nullable(Date)          COMMENT 'Ngày ghi nhận bản ghi biểu mẫu',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                    Nullable(Date)          COMMENT 'Ngày snapshot — từ Calendar Date Dimension',

    -- From: PRIVATE CORPORATE BOND DIMENSION
    bond_code                       Nullable(String)        COMMENT 'Mã trái phiếu',
    issuer_nm                       Nullable(String)        COMMENT 'Tên DN phát hành',
    enterprise_tp                   Nullable(String)        COMMENT 'Loại hình doanh nghiệp',
    business_sector                 Nullable(String)        COMMENT 'Lĩnh vực hoạt động',
    bond_term_unit                  Nullable(String)        COMMENT 'Đơn vị kỳ hạn',
    bond_term                       Nullable(Int32)         COMMENT 'Kỳ hạn',
    interest_rate_tp                Nullable(String)        COMMENT 'Loại lãi suất',
    issue_interest_rate             Nullable(Decimal(8,5))  COMMENT 'Lãi suất phát hành',
    issue_dt                        Nullable(Date)          COMMENT 'Ngày phát hành',
    maturity_dt                     Nullable(Date)          COMMENT 'Ngày đáo hạn',
    interest_payment_method         Nullable(String)        COMMENT 'Phương thức thanh toán lãi',
    convertible_bond_ind            Nullable(Bool)          COMMENT 'Trái phiếu chuyển đổi',
    warrant_linked_bond_ind         Nullable(Bool)          COMMENT 'Trái phiếu kèm chứng quyền',
    secured_bond_ind                Nullable(Bool)          COMMENT 'Trái phiếu có bảo đảm',
    bond_src_stm_code               Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Private Corporate Bond Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), private_corporate_bond_dim_id, market_tp, rpt_month, rpt_year, private_corporate_bond_international_offering_snpst_id)
COMMENT 'Flat table — Fact Private Corporate Bond International Offering Snapshot × Calendar Date × Private Corporate Bond Dimension'
;


-- ============================================================
-- 22. FACT: fct_private_corporate_bond_issuance_snpst
--    Fact Private Corporate Bond Issuance Snapshot (HNX11 — Nhóm 8); grain 1 mã trái phiếu × 1 kỳ báo cáo (rpt_year + rpt_month), PK private_corporate_bond_issuance_snpst_id
--    Joins: Calendar Date × Private Corporate Bond Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_fct_private_corporate_bond_issuance_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Private Corporate Bond Issuance Snapshot
    private_corporate_bond_issuance_snpst_id                String                  COMMENT 'PK — hash(private_corporate_bond_dim_id, rpt_year, rpt_month, src_stm_code); grain 1 mã trái phiếu × 1 kỳ báo cáo (rpt_year + rpt_month)',
    snpst_dt_dim_id                 String                  COMMENT 'FK ngày chụp dữ liệu biểu mẫu',
    private_corporate_bond_dim_id   String                  COMMENT 'FK mã trái phiếu',
    rpt_year                        Int64                   COMMENT 'Năm báo cáo — cùng rpt_month; khai thác lọc theo rpt_year + rpt_month (không theo ngày snapshot)',
    rpt_month                       Int64                   COMMENT 'Tháng báo cáo 1–12 (số lũy kế từ đầu năm) — Quý = 3/6/9/12',
    issued_bond_quantity            Nullable(Int64)         COMMENT 'Khối lượng phát hành (lũy kế tại tháng báo cáo)',
    par_value                       Nullable(Decimal(23,2)) COMMENT 'Mệnh giá trái phiếu',
    issued_bond_val_amt             Nullable(Decimal(23,2)) COMMENT 'Giá trị phát hành = khối lượng phát hành × mệnh giá',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                    Nullable(Date)          COMMENT 'Ngày snapshot — từ Calendar Date Dimension',

    -- From: PRIVATE CORPORATE BOND DIMENSION
    bond_code                       Nullable(String)        COMMENT 'Mã trái phiếu',
    issuer_nm                       Nullable(String)        COMMENT 'Tên DN phát hành',
    enterprise_tp                   Nullable(String)        COMMENT 'Loại hình doanh nghiệp',
    business_sector                 Nullable(String)        COMMENT 'Lĩnh vực hoạt động',
    bond_term_unit                  Nullable(String)        COMMENT 'Đơn vị kỳ hạn',
    bond_term                       Nullable(Int32)         COMMENT 'Kỳ hạn',
    interest_rate_tp                Nullable(String)        COMMENT 'Loại lãi suất',
    issue_interest_rate             Nullable(Decimal(8,5))  COMMENT 'Lãi suất phát hành',
    issue_dt                        Nullable(Date)          COMMENT 'Ngày phát hành',
    maturity_dt                     Nullable(Date)          COMMENT 'Ngày đáo hạn',
    interest_payment_method         Nullable(String)        COMMENT 'Phương thức thanh toán lãi',
    convertible_bond_ind            Nullable(Bool)          COMMENT 'Trái phiếu chuyển đổi',
    warrant_linked_bond_ind         Nullable(Bool)          COMMENT 'Trái phiếu kèm chứng quyền',
    secured_bond_ind                Nullable(Bool)          COMMENT 'Trái phiếu có bảo đảm',
    bond_src_stm_code               Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Private Corporate Bond Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), private_corporate_bond_dim_id, rpt_month, rpt_year, private_corporate_bond_issuance_snpst_id)
COMMENT 'Flat table — Fact Private Corporate Bond Issuance Snapshot × Calendar Date × Private Corporate Bond Dimension'
;


-- ============================================================
-- 23. FACT: fct_security_trading_detail_snpst
--    Fact Security Trading Detail Snapshot (Nhóm 28 — BM035_MSS); grain 1 mã chứng khoán × 1 ngày giao dịch, PK security_trading_detail_snpst_id
--    Joins: Calendar Date × Security Trading Snapshot Dimension (reuse GSTT)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_fct_security_trading_detail_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Security Trading Detail Snapshot
    security_trading_detail_snpst_id        String                  COMMENT 'PK — hash(snpst_dt_dim_id, security_trading_snpst_dim_id, src_stm_code); grain 1 mã chứng khoán × 1 ngày giao dịch',
    snpst_dt_dim_id                         String                  COMMENT 'Snapshot Date Dimension Id',
    security_trading_snpst_dim_id           String                  COMMENT 'Security Trading Snapshot Dimension Id',
    trading_status_code                     Nullable(String)        COMMENT 'Trading Status Code',
    reference_price                         Nullable(Decimal(23,2)) COMMENT 'Reference Price',
    ceiling_price                           Nullable(Decimal(23,2)) COMMENT 'Ceiling Price',
    floor_price                             Nullable(Decimal(23,2)) COMMENT 'Floor Price',
    close_price                             Nullable(Decimal(23,2)) COMMENT 'Close Price',
    average_price                           Nullable(Decimal(23,2)) COMMENT 'Average Price',
    high_price                              Nullable(Decimal(23,2)) COMMENT 'High Price',
    low_price                               Nullable(Decimal(23,2)) COMMENT 'Low Price',
    buy_order_cnt                           Nullable(Int32)         COMMENT 'Buy Order Count',
    buy_order_vol                           Nullable(Int64)         COMMENT 'Buy Order Volume',
    sell_order_cnt                          Nullable(Int32)         COMMENT 'Sell Order Count',
    sell_order_vol                          Nullable(Int64)         COMMENT 'Sell Order Volume',
    matched_trading_vol                     Nullable(Int64)         COMMENT 'Matched Trading Volume',
    matched_trading_val                     Nullable(Decimal(23,2)) COMMENT 'Matched Trading Value',
    negotiated_trading_vol                  Nullable(Int64)         COMMENT 'Negotiated Trading Volume',
    negotiated_trading_val                  Nullable(Decimal(23,2)) COMMENT 'Negotiated Trading Value',
    odd_lot_trading_vol                     Nullable(Int64)         COMMENT 'Odd Lot Trading Volume',
    odd_lot_trading_val                     Nullable(Decimal(23,2)) COMMENT 'Odd Lot Trading Value',
    total_trading_vol                       Nullable(Int64)         COMMENT 'Total Trading Volume',
    total_trading_val                       Nullable(Decimal(23,2)) COMMENT 'Total Trading Value',
    max_foreign_ownership_ratio             Nullable(Decimal(9,4))  COMMENT 'Max Foreign Ownership Ratio',
    remaining_foreign_ownership_ratio       Nullable(Decimal(9,4))  COMMENT 'Remaining Foreign Ownership Ratio',
    foreign_investor_total_buy_vol          Nullable(Int64)         COMMENT 'Foreign Investor Total Buy Volume',
    foreign_investor_total_sell_vol         Nullable(Int64)         COMMENT 'Foreign Investor Total Sell Volume',
    foreign_investor_total_buy_val          Nullable(Decimal(23,2)) COMMENT 'Foreign Investor Total Buy Value',
    foreign_investor_total_sell_val         Nullable(Decimal(23,2)) COMMENT 'Foreign Investor Total Sell Value',
    foreign_investor_negotiated_buy_vol     Nullable(Int64)         COMMENT 'Foreign Investor Negotiated Buy Volume',
    foreign_investor_negotiated_sell_vol    Nullable(Int64)         COMMENT 'Foreign Investor Negotiated Sell Volume',
    foreign_investor_negotiated_buy_val     Nullable(Decimal(23,2)) COMMENT 'Foreign Investor Negotiated Buy Value',
    foreign_investor_negotiated_sell_val    Nullable(Decimal(23,2)) COMMENT 'Foreign Investor Negotiated Sell Value',
    foreign_investor_matched_buy_vol        Nullable(Int64)         COMMENT 'Foreign Investor Matched Buy Volume',
    foreign_investor_matched_sell_vol       Nullable(Int64)         COMMENT 'Foreign Investor Matched Sell Volume',
    foreign_investor_matched_buy_val        Nullable(Decimal(23,2)) COMMENT 'Foreign Investor Matched Buy Value',
    foreign_investor_matched_sell_val       Nullable(Decimal(23,2)) COMMENT 'Foreign Investor Matched Sell Value',
    proprietary_total_buy_vol               Nullable(Int64)         COMMENT 'Proprietary Total Buy Volume',
    proprietary_total_sell_vol              Nullable(Int64)         COMMENT 'Proprietary Total Sell Volume',
    proprietary_total_buy_val               Nullable(Decimal(23,2)) COMMENT 'Proprietary Total Buy Value',
    proprietary_total_sell_val              Nullable(Decimal(23,2)) COMMENT 'Proprietary Total Sell Value',
    proprietary_negotiated_buy_vol          Nullable(Int64)         COMMENT 'Proprietary Negotiated Buy Volume',
    proprietary_negotiated_sell_vol         Nullable(Int64)         COMMENT 'Proprietary Negotiated Sell Volume',
    proprietary_negotiated_buy_val          Nullable(Decimal(23,2)) COMMENT 'Proprietary Negotiated Buy Value',
    proprietary_negotiated_sell_val         Nullable(Decimal(23,2)) COMMENT 'Proprietary Negotiated Sell Value',
    proprietary_matched_buy_vol             Nullable(Int64)         COMMENT 'Proprietary Matched Buy Volume',
    proprietary_matched_sell_vol            Nullable(Int64)         COMMENT 'Proprietary Matched Sell Volume',
    proprietary_matched_buy_val             Nullable(Decimal(23,2)) COMMENT 'Proprietary Matched Buy Value',
    proprietary_matched_sell_val            Nullable(Decimal(23,2)) COMMENT 'Proprietary Matched Sell Value',
    src_stm_code                            String                  COMMENT 'Source System Code',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                            Nullable(Date)          COMMENT 'Ngày snapshot — từ Calendar Date Dimension',

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    symbol                                  Nullable(String)        COMMENT 'Mã CK/hợp đồng — từ Security Trading Snapshot Dimension',
    security_full_nm                        Nullable(String)        COMMENT 'Tên đầy đủ chứng khoán — từ Security Trading Snapshot Dimension',
    floor_code                              Nullable(String)        COMMENT 'Mã sàn — từ Security Trading Snapshot Dimension',
    stock_tp_code                           Nullable(String)        COMMENT 'Loại chứng khoán — từ Security Trading Snapshot Dimension',
    isin_code                               Nullable(String)        COMMENT 'Mã ISIN — từ Security Trading Snapshot Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), security_trading_snpst_dim_id, security_trading_detail_snpst_id)
COMMENT 'Flat table — Fact Security Trading Detail Snapshot × Calendar Date × Security Trading Snapshot Dimension'
;



-- ============================================================
-- 24. FACT: fct_derivatives_security_detail_snpst
--    Fact Derivatives Security Detail Snapshot (Nhóm 29 — BM043_MSS); grain 1 mã hợp đồng CKPS × 1 ngày giao dịch, PK derivatives_security_detail_snpst_id
--    Joins: Calendar Date × Security Trading Snapshot Dimension (reuse GSTT)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_fct_derivatives_security_detail_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Derivatives Security Detail Snapshot
    derivatives_security_detail_snpst_id    String                  COMMENT 'PK — hash(snpst_dt_dim_id, security_trading_snpst_dim_id, src_stm_code); grain 1 mã hợp đồng CKPS × 1 ngày giao dịch',
    snpst_dt_dim_id                         String                  COMMENT 'Snapshot Date Dimension Id',
    security_trading_snpst_dim_id           String                  COMMENT 'Security Trading Snapshot Dimension Id',
    open_interest_quantity                  Nullable(Int64)         COMMENT 'Open Interest Quantity',
    trading_vol                             Nullable(Int64)         COMMENT 'Trading Volume',
    trading_val                             Nullable(Decimal(23,2)) COMMENT 'Trading Value',
    foreign_investor_buy_vol                Nullable(Int64)         COMMENT 'Foreign Investor Buy Volume',
    foreign_investor_sell_vol               Nullable(Int64)         COMMENT 'Foreign Investor Sell Volume',
    foreign_investor_buy_val                Nullable(Decimal(23,2)) COMMENT 'Foreign Investor Buy Value',
    foreign_investor_sell_val               Nullable(Decimal(23,2)) COMMENT 'Foreign Investor Sell Value',
    proprietary_buy_vol                     Nullable(Int64)         COMMENT 'Proprietary Buy Volume',
    proprietary_sell_vol                    Nullable(Int64)         COMMENT 'Proprietary Sell Volume',
    proprietary_buy_val                     Nullable(Decimal(23,2)) COMMENT 'Proprietary Buy Value',
    proprietary_sell_val                    Nullable(Decimal(23,2)) COMMENT 'Proprietary Sell Value',
    src_stm_code                            String                  COMMENT 'Source System Code',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                            Nullable(Date)          COMMENT 'Ngày snapshot — từ Calendar Date Dimension',

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    symbol                                  Nullable(String)        COMMENT 'Mã CK/hợp đồng — từ Security Trading Snapshot Dimension',
    security_full_nm                        Nullable(String)        COMMENT 'Tên đầy đủ chứng khoán — từ Security Trading Snapshot Dimension',
    floor_code                              Nullable(String)        COMMENT 'Mã sàn — từ Security Trading Snapshot Dimension',
    isin_code                               Nullable(String)        COMMENT 'Mã ISIN — từ Security Trading Snapshot Dimension',
    maturity_dt                             Nullable(Date)          COMMENT 'Ngày đáo hạn — từ Security Trading Snapshot Dimension',
    contract_multiplier                     Nullable(Decimal(23,2)) COMMENT 'Hệ số hợp đồng — từ Security Trading Snapshot Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), security_trading_snpst_dim_id, derivatives_security_detail_snpst_id)
COMMENT 'Flat table — Fact Derivatives Security Detail Snapshot × Calendar Date × Security Trading Snapshot Dimension'
;


-- ============================================================
-- 25. FACT: fct_custody_account_open_close_snpst
--    Fact Custody Account Open Close Snapshot (Nhóm 13 — TTLK01; grain 1 TVLK × 1 tháng báo cáo, PK custody_account_open_close_snpst_id)
--    Joins: Calendar Date × Depository Member Dimension (TKNB)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_fct_custody_account_open_close_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Custody Account Open Close Snapshot
    custody_account_open_close_snpst_id            String                  COMMENT 'PK — hash(snpst_dt_dim_id, depository_member_dim_id, src_stm_code); grain 1 TVLK × 1 tháng báo cáo',
    snpst_dt_dim_id                                String                  COMMENT 'Snapshot Date Dimension Id',
    depository_member_dim_id                       String                  COMMENT 'Depository Member Dimension Id',
    row_nbr                                        Int64                   COMMENT 'Row Number',
    opening_domestic_individual_account_quantity   Nullable(Int64)         COMMENT 'Opening Domestic Individual Account Quantity',
    opening_domestic_institution_account_quantity  Nullable(Int64)         COMMENT 'Opening Domestic Institution Account Quantity',
    opening_foreign_individual_account_quantity    Nullable(Int64)         COMMENT 'Opening Foreign Individual Account Quantity',
    opening_foreign_institution_account_quantity   Nullable(Int64)         COMMENT 'Opening Foreign Institution Account Quantity',
    opened_domestic_individual_account_quantity    Nullable(Int64)         COMMENT 'Opened Domestic Individual Account Quantity',
    opened_domestic_institution_account_quantity   Nullable(Int64)         COMMENT 'Opened Domestic Institution Account Quantity',
    opened_foreign_individual_account_quantity     Nullable(Int64)         COMMENT 'Opened Foreign Individual Account Quantity',
    opened_foreign_institution_account_quantity    Nullable(Int64)         COMMENT 'Opened Foreign Institution Account Quantity',
    closed_domestic_individual_account_quantity    Nullable(Int64)         COMMENT 'Closed Domestic Individual Account Quantity',
    closed_domestic_institution_account_quantity   Nullable(Int64)         COMMENT 'Closed Domestic Institution Account Quantity',
    closed_foreign_individual_account_quantity     Nullable(Int64)         COMMENT 'Closed Foreign Individual Account Quantity',
    closed_foreign_institution_account_quantity    Nullable(Int64)         COMMENT 'Closed Foreign Institution Account Quantity',
    closing_domestic_individual_account_quantity   Nullable(Int64)         COMMENT 'Closing Domestic Individual Account Quantity',
    closing_domestic_institution_account_quantity  Nullable(Int64)         COMMENT 'Closing Domestic Institution Account Quantity',
    closing_foreign_individual_account_quantity    Nullable(Int64)         COMMENT 'Closing Foreign Individual Account Quantity',
    closing_foreign_institution_account_quantity   Nullable(Int64)         COMMENT 'Closing Foreign Institution Account Quantity',
    total_account_quantity                         Nullable(Int64)         COMMENT 'Total Account Quantity',
    src_stm_code                                   String                  COMMENT 'Source System Code',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                                   Nullable(Date)          COMMENT 'Ngày snapshot — từ Calendar Date Dimension',

    -- From: DEPOSITORY MEMBER DIMENSION
    depository_member_nm                           Nullable(String)        COMMENT 'Tên Thành viên lưu ký (TVLK) — từ Depository Member Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), custody_account_open_close_snpst_id)
COMMENT 'Flat table — Fact Custody Account Open Close Snapshot × Calendar Date × Depository Member Dimension'
;
