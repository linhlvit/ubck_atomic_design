-- ============================================================
-- TKNB Flat Tables — CREATE
-- Module: Thống kê nội bộ (TKNB)
-- Generated: Phase 3 LLD Datamart
-- 24 bảng (bảng #13/#16/#23/#24 là FACT, còn lại operational EAV báo cáo phẳng — 1 báo cáo = 1 bảng phẳng)
-- Toàn bộ bảng operational — KHÔNG JOIN Calendar Date, KHÔNG JOIN dim nào khác
-- ============================================================

-- ============================================================
-- 1. OPERATIONAL: hnx01_stock_trading_rpt
--    Stock Trading Report (HNX01)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_hnx01_stock_trading_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Stock Trading Report (HNX01)
    report_code         String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt    Date                     COMMENT 'BK — kỳ báo cáo (ngày giao dịch)',
    item_code           String                   COMMENT 'PK — Driving: securities_trade — mã chỉ tiêu EAV, gán theo danh mục cố định của mẫu biểu HNX01',
    item_stt            Int64                    COMMENT 'Số thứ tự hiển thị của chỉ tiêu theo đúng layout mẫu biểu gốc',
    item_unit           Nullable(String)         COMMENT 'Đơn vị tính của chỉ tiêu',
    item_value          Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu — populate theo item_code, mỗi chỉ tiêu lấy nguồn nghiệp vụ tương ứng (giá trị giao dịch, chỉ số thị trường, hoặc phân loại chứng khoán)',
    src_stm_code        String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, item_code)
COMMENT 'Flat table — Stock Trading Report (HNX01)'
;


-- ============================================================
-- 2. OPERATIONAL: hnx02_gov_bond_otc_trading_rpt
--    Gov Bond OTC Trading Report (HNX02)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_hnx02_gov_bond_otc_trading_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Gov Bond OTC Trading Report (HNX02)
    report_code         String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt    Date                     COMMENT 'BK — kỳ báo cáo (ngày giao dịch)',
    item_code           String                   COMMENT 'PK — Driving: bond_order_book — mã chỉ tiêu EAV, gán theo danh mục cố định của mẫu biểu HNX02',
    item_stt            Int64                    COMMENT 'Số thứ tự hiển thị của chỉ tiêu theo đúng layout mẫu biểu gốc',
    item_unit           Nullable(String)         COMMENT 'Đơn vị tính của chỉ tiêu',
    item_value          Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu — populate theo item_code, mỗi chỉ tiêu lấy nguồn nghiệp vụ tương ứng (khối lượng/giá trị/lợi suất giao dịch trái phiếu OTC theo loại hình)',
    src_stm_code        String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, item_code)
COMMENT 'Flat table — Gov Bond OTC Trading Report (HNX02)'
;


-- ============================================================
-- 3. OPERATIONAL: hnx03_derivative_trading_rpt
--    Derivative Trading Report (HNX03)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_hnx03_derivative_trading_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Derivative Trading Report (HNX03)
    report_code         String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt    Date                     COMMENT 'BK — kỳ báo cáo (ngày giao dịch)',
    item_code           String                   COMMENT 'PK — mã chỉ tiêu EAV, gán theo danh mục cố định của mẫu biểu TK-HNX03',
    item_stt            Int64                    COMMENT 'Số thứ tự hiển thị của chỉ tiêu theo đúng layout mẫu biểu gốc',
    item_unit           Nullable(String)         COMMENT 'Đơn vị tính của chỉ tiêu',
    item_value          Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu — populate theo item_code, mỗi chỉ tiêu lấy nguồn nghiệp vụ tương ứng (khối lượng/giá trị giao dịch CKPS, hoặc ngày đáo hạn/hệ số nhân hợp đồng)',
    src_stm_code        String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, item_code)
COMMENT 'Flat table — Derivative Trading Report (HNX03)'
;


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
-- 5. OPERATIONAL: hnx07_corp_bond_trading_rpt
--    Corp Bond Trading Report (HNX07)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_hnx07_corp_bond_trading_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Corp Bond Trading Report (HNX07)
    report_code         String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt    Date                     COMMENT 'BK — kỳ báo cáo',
    item_code           String                   COMMENT 'PK — mã chỉ tiêu EAV, gán theo danh mục cố định của mẫu biểu TK-HNX07',
    item_stt            Int64                    COMMENT 'Số thứ tự hiển thị của chỉ tiêu theo đúng layout mẫu biểu gốc',
    item_unit           Nullable(String)         COMMENT 'Đơn vị tính của chỉ tiêu',
    item_value          Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu — populate theo item_code, giá trị/khối lượng giao dịch TPDN niêm yết sàn HNX',
    src_stm_code        String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, item_code)
COMMENT 'Flat table — Corp Bond Trading Report (HNX07)'
;


-- ============================================================
-- 6. OPERATIONAL: hsx01_stock_trading_rpt
--    Stock Trading Report (HSX01)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_hsx01_stock_trading_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Stock Trading Report (HSX01)
    report_code         String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt    Date                     COMMENT 'BK — kỳ báo cáo',
    item_code           String                   COMMENT 'PK — mã chỉ tiêu EAV, gán theo danh mục cố định của mẫu biểu TK-HSX01',
    item_stt            Int64                    COMMENT 'Số thứ tự hiển thị của chỉ tiêu theo đúng layout mẫu biểu gốc',
    item_unit           Nullable(String)         COMMENT 'Đơn vị tính của chỉ tiêu',
    item_value          Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu — populate theo item_code, mỗi chỉ tiêu lấy nguồn nghiệp vụ tương ứng (giá trị/khối lượng giao dịch, chỉ số thị trường, vốn hóa, phân loại chứng khoán) trên sàn HOSE',
    src_stm_code        String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, item_code)
COMMENT 'Flat table — Stock Trading Report (HSX01)'
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
-- 8. OPERATIONAL: hsx04_proprietary_trading_rpt
--    Proprietary Trading Report (HSX04)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_hsx04_proprietary_trading_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Proprietary Trading Report (HSX04)
    report_code         String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt    Date                     COMMENT 'BK — kỳ báo cáo',
    item_code           String                   COMMENT 'PK — mã chỉ tiêu EAV, gán theo danh mục cố định của mẫu biểu TK-HSX04',
    item_stt            Int64                    COMMENT 'Số thứ tự hiển thị của chỉ tiêu theo đúng layout mẫu biểu gốc',
    item_unit           Nullable(String)         COMMENT 'Đơn vị tính của chỉ tiêu',
    item_value          Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu — populate theo item_code, khối lượng/giá trị giao dịch tự doanh CTCK trên sàn HOSE',
    src_stm_code        String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, item_code)
COMMENT 'Flat table — Proprietary Trading Report (HSX04)'
;


-- ============================================================
-- 9. OPERATIONAL: ttlk10_cw_outstanding_rpt
--    CW Outstanding Report (TTLK10)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_ttlk10_cw_outstanding_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL CW Outstanding Report (TTLK10)
    report_code             String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt        Date                     COMMENT 'BK — kỳ báo cáo',
    listed_cw_code          String                   COMMENT 'PK — mã chứng quyền niêm yết, khóa nghiệp vụ danh sách (không dùng item_code vì đây là bảng danh sách, không phải EAV)',
    covered_warrant_nm      String                   COMMENT 'Tên chứng quyền',
    outstanding_quantity    Nullable(Int64)          COMMENT 'Khối lượng chứng quyền đang lưu hành (KL cho phép phát hành trừ KL đã phân phối)',
    src_stm_code            String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, listed_cw_code)
COMMENT 'Flat table — CW Outstanding Report (TTLK10)'
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
--    Fact Market Trading Snapshot
--    [SỬA 2026-09-22, datamart-review — Kịch bản D] Thay thế bm030amss_market_trading_rpt
--    (EAV, DEPRECATED — đã gộp sai 2 grain khác nhau) bằng Fact chuẩn Star Schema.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_fct_market_trading_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Market Trading Snapshot
    snpst_dt_dim_id         String      COMMENT 'FK tới Calendar Date Dimension theo ngày giao dịch',
    index_constituent_dim_id String     COMMENT '[SỬA 2026-09-23] FK tới Index Constituent Dimension — Loại chỉ số K_TKNB_1013 (grain Trade Date × Index Code)',
    total_trading_val       Decimal(23,2) COMMENT 'Tổng giá trị giao dịch cổ phiếu toàn thị trường (cộng gộp HOSE+HNX+UPCoM) trong ngày',
    total_trading_vol       Int64       COMMENT 'Tổng khối lượng giao dịch cổ phiếu toàn thị trường trong ngày',
    matched_trading_val     Decimal(23,2) COMMENT 'Giá trị giao dịch khớp lệnh toàn thị trường trong ngày',
    matched_trading_vol     Int64       COMMENT 'Khối lượng giao dịch khớp lệnh toàn thị trường trong ngày',
    negotiated_trading_val  Decimal(23,2) COMMENT 'Giá trị giao dịch thỏa thuận toàn thị trường trong ngày',
    negotiated_trading_vol  Int64       COMMENT 'Khối lượng giao dịch thỏa thuận toàn thị trường trong ngày',
    odd_lot_trading_val     Decimal(23,2) COMMENT 'Giá trị giao dịch lô lẻ toàn thị trường trong ngày',
    odd_lot_trading_vol     Int64       COMMENT 'Khối lượng giao dịch lô lẻ toàn thị trường trong ngày',
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
ORDER BY (assumeNotNull(trade_cdr_dt), index_constituent_dim_id)
COMMENT 'Flat table — Fact Market Trading Snapshot × Calendar Date × Index Constituent Dimension'
;


-- ============================================================
-- 14. OPERATIONAL: bm030cmss_corp_bond_trading_rpt
--    Corp Bond Trading Report (BM030c)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_bm030cmss_corp_bond_trading_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Corp Bond Trading Report (BM030c)
    report_code         String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt    Date                     COMMENT 'BK — kỳ báo cáo',
    item_code           String                   COMMENT 'PK — mã chỉ tiêu EAV, gán theo danh mục cố định của mẫu biểu BM030c_MSS',
    item_stt            Int64                    COMMENT 'Số thứ tự hiển thị của chỉ tiêu theo đúng layout mẫu biểu gốc',
    item_unit           Nullable(String)         COMMENT 'Đơn vị tính của chỉ tiêu',
    item_value          Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu — populate theo item_code, khối lượng/giá trị giao dịch TPDN niêm yết toàn thị trường (cộng gộp HOSE+HNX)',
    src_stm_code        String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, item_code)
COMMENT 'Flat table — Corp Bond Trading Report (BM030c)'
;


-- ============================================================
-- 15. OPERATIONAL: bm030emss_fund_cert_etf_cw_trading_rpt
--    Fund Cert ETF CW Trading Report (BM030e)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_bm030emss_fund_cert_etf_cw_trading_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Fund Cert ETF CW Trading Report (BM030e)
    report_code         String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt    Date                     COMMENT 'BK — kỳ báo cáo',
    item_code           String                   COMMENT 'PK — mã chỉ tiêu EAV, gán theo danh mục cố định của mẫu biểu BM030e_MSS',
    item_stt            Int64                    COMMENT 'Số thứ tự hiển thị của chỉ tiêu theo đúng layout mẫu biểu gốc',
    item_unit           Nullable(String)         COMMENT 'Đơn vị tính của chỉ tiêu',
    item_value          Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu — populate theo item_code, khối lượng/giá trị giao dịch CCQ/ETF/CW toàn thị trường (cộng gộp HOSE+HNX)',
    src_stm_code        String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, item_code)
COMMENT 'Flat table — Fund Cert ETF CW Trading Report (BM030e)'
;


-- ============================================================
-- 16. FACT: fct_foreign_proprietary_trading_index_snpst
--    Fact Foreign Proprietary Trading Index Snapshot
--    [SỬA 2026-09-22, datamart-review — Kịch bản D] Thay thế bm031amss_foreign_proprietary_trading_rpt
--    (EAV, DEPRECATED) bằng Fact chuẩn Star Schema, reuse Index Constituent Dimension (GSTT).
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_fct_foreign_proprietary_trading_index_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Foreign Proprietary Trading Index Snapshot
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
ORDER BY (assumeNotNull(trade_cdr_dt), index_constituent_dim_id)
COMMENT 'Flat table — Fact Foreign Proprietary Trading Index Snapshot'
;


-- ============================================================
-- 17. OPERATIONAL: bm031bmss_gov_bond_foreign_proprietary_trading_rpt
--    Gov Bond Foreign Proprietary Trading Report (BM031b)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_bm031bmss_gov_bond_foreign_proprietary_trading_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Gov Bond Foreign Proprietary Trading Report (BM031b)
    report_code         String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt    Date                     COMMENT 'BK — kỳ báo cáo',
    item_code           String                   COMMENT 'PK — mã chỉ tiêu EAV, gán theo danh mục cố định của mẫu biểu BM031b_MSS',
    item_stt            Int64                    COMMENT 'Số thứ tự hiển thị của chỉ tiêu theo đúng layout mẫu biểu gốc',
    item_unit           Nullable(String)         COMMENT 'Đơn vị tính của chỉ tiêu',
    item_value          Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu — populate theo item_code, khối lượng/giá trị giao dịch NĐTNN/tự doanh thị trường TPCP (chỉ HNX)',
    src_stm_code        String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, item_code)
COMMENT 'Flat table — Gov Bond Foreign Proprietary Trading Report (BM031b)'
;


-- ============================================================
-- 18. OPERATIONAL: bm031cmss_corp_bond_foreign_proprietary_trading_rpt
--    Corp Bond Foreign Proprietary Trading Report (BM031c)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_bm031cmss_corp_bond_foreign_proprietary_trading_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Corp Bond Foreign Proprietary Trading Report (BM031c)
    report_code         String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt    Date                     COMMENT 'BK — kỳ báo cáo',
    item_code           String                   COMMENT 'PK — mã chỉ tiêu EAV, gán theo danh mục cố định của mẫu biểu BM031C_MSS',
    item_stt            Int64                    COMMENT 'Số thứ tự hiển thị của chỉ tiêu theo đúng layout mẫu biểu gốc',
    item_unit           Nullable(String)         COMMENT 'Đơn vị tính của chỉ tiêu',
    item_value          Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu — populate theo item_code, khối lượng/giá trị giao dịch NĐTNN/tự doanh thị trường TPDN niêm yết (chỉ HNX)',
    src_stm_code        String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, item_code)
COMMENT 'Flat table — Corp Bond Foreign Proprietary Trading Report (BM031c)'
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
-- 20. OPERATIONAL: bm031fmss_derivatives_foreign_proprietary_trading_rpt
--    Derivatives Foreign Proprietary Trading Report (BM031f)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_bm031fmss_derivatives_foreign_proprietary_trading_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Derivatives Foreign Proprietary Trading Report (BM031f)
    report_code         String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt    Date                     COMMENT 'BK — kỳ báo cáo',
    item_code           String                   COMMENT 'PK — mã chỉ tiêu EAV, gán theo danh mục cố định của mẫu biểu BM031f_MSS',
    item_stt            Int64                    COMMENT 'Số thứ tự hiển thị của chỉ tiêu theo đúng layout mẫu biểu gốc',
    item_unit           Nullable(String)         COMMENT 'Đơn vị tính của chỉ tiêu',
    item_value          Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu — populate theo item_code, số lượng mã/khối lượng/giá trị giao dịch CKPS toàn thị trường và NĐTNN/tự doanh',
    src_stm_code        String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, item_code)
COMMENT 'Flat table — Derivatives Foreign Proprietary Trading Report (BM031f)'
;


-- ============================================================
-- 21. FACT: fct_private_corporate_bond_international_offering_snpst
--    Fact Private Corporate Bond International Offering Snapshot (HNX12 — Nhóm 9)
--    Joins: Calendar Date × Private Corporate Bond Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_fct_private_corporate_bond_international_offering_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Private Corporate Bond International Offering Snapshot
    snpst_dt_dim_id                 String                  COMMENT 'FK ngày chụp dữ liệu biểu mẫu',
    private_corporate_bond_dim_id   String                  COMMENT 'FK mã trái phiếu',
    rpt_month                       String                  COMMENT 'Tháng báo cáo (số lũy kế từ đầu năm) — Quý = 03/06/09/12',
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
ORDER BY (assumeNotNull(snpst_cdr_dt), private_corporate_bond_dim_id, market_tp, rpt_month)
COMMENT 'Flat table — Fact Private Corporate Bond International Offering Snapshot × Calendar Date × Private Corporate Bond Dimension'
;


-- ============================================================
-- 22. FACT: fct_private_corporate_bond_issuance_snpst
--    Fact Private Corporate Bond Issuance Snapshot (HNX11 — Nhóm 8)
--    Joins: Calendar Date × Private Corporate Bond Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_fct_private_corporate_bond_issuance_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Private Corporate Bond Issuance Snapshot
    snpst_dt_dim_id                 String                  COMMENT 'FK ngày chụp dữ liệu biểu mẫu',
    private_corporate_bond_dim_id   String                  COMMENT 'FK mã trái phiếu',
    rpt_month                       String                  COMMENT 'Tháng báo cáo (số lũy kế từ đầu năm) — Quý = 03/06/09/12',
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
ORDER BY (assumeNotNull(snpst_cdr_dt), private_corporate_bond_dim_id, rpt_month)
COMMENT 'Flat table — Fact Private Corporate Bond Issuance Snapshot × Calendar Date × Private Corporate Bond Dimension'
;


-- ============================================================
-- 23. FACT: fct_security_trading_detail_snpst
--    Fact Security Trading Detail Snapshot (Nhóm 28 — BM035_MSS)
--    Joins: Calendar Date × Security Trading Snapshot Dimension (reuse GSTT)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_fct_security_trading_detail_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Security Trading Detail Snapshot
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
ORDER BY (assumeNotNull(snpst_cdr_dt), security_trading_snpst_dim_id)
COMMENT 'Flat table — Fact Security Trading Detail Snapshot × Calendar Date × Security Trading Snapshot Dimension'
;



-- ============================================================
-- 24. FACT: fct_derivatives_security_detail_snpst
--    Fact Derivatives Security Detail Snapshot (Nhóm 29 — BM043_MSS)
--    Joins: Calendar Date × Security Trading Snapshot Dimension (reuse GSTT)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_fct_derivatives_security_detail_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Derivatives Security Detail Snapshot
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
ORDER BY (assumeNotNull(snpst_cdr_dt), security_trading_snpst_dim_id)
COMMENT 'Flat table — Fact Derivatives Security Detail Snapshot × Calendar Date × Security Trading Snapshot Dimension'
;
