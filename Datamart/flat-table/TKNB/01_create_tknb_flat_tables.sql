-- ============================================================
-- TKNB Flat Tables — CREATE
-- Module: Thống kê nội bộ (TKNB)
-- Generated: Phase 3 LLD Datamart
-- 21 bảng: 0 fact + 21 operational (EAV báo cáo phẳng, 1 báo cáo = 1 bảng phẳng)
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
-- 2. OPERATIONAL: hnx03_derivative_trading_rpt
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
-- 3. OPERATIONAL: hnx04_market_scale_rpt
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
-- 4. OPERATIONAL: hnx07_corp_bond_trading_rpt
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
-- 5. OPERATIONAL: hsx01_stock_trading_rpt
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
-- 6. OPERATIONAL: hsx02_listing_trading_rpt
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
-- 7. OPERATIONAL: hsx04_proprietary_trading_rpt
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
-- 8. OPERATIONAL: ttlk10_cw_outstanding_rpt
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
-- 9. OPERATIONAL: 0513hubckqg_offering_result_rpt
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
-- 10. OPERATIONAL: tk04btc_market_summary_rpt
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
-- 11. OPERATIONAL: tkniengiam_market_annual_rpt
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
-- 12. OPERATIONAL: bm030amss_market_trading_rpt
--    Market Trading Report (BM030a)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_bm030amss_market_trading_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Market Trading Report (BM030a)
    report_code         String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt    Date                     COMMENT 'BK — kỳ báo cáo',
    item_code           String                   COMMENT 'PK — mã chỉ tiêu EAV, gán theo danh mục cố định của mẫu biểu BM030a_MSS',
    item_stt            Int64                    COMMENT 'Số thứ tự hiển thị của chỉ tiêu theo đúng layout mẫu biểu gốc',
    item_unit           Nullable(String)         COMMENT 'Đơn vị tính của chỉ tiêu',
    item_value          Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu — populate theo item_code, chỉ số thị trường hoặc khối lượng/giá trị giao dịch cổ phiếu toàn thị trường (cộng gộp HOSE+HNX+UPCoM)',
    src_stm_code        String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, item_code)
COMMENT 'Flat table — Market Trading Report (BM030a)'
;


-- ============================================================
-- 13. OPERATIONAL: bm030cmss_corp_bond_trading_rpt
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
-- 14. OPERATIONAL: bm030emss_fund_cert_etf_cw_trading_rpt
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
-- 15. OPERATIONAL: bm031amss_foreign_proprietary_trading_rpt
--    Foreign Proprietary Trading Report (BM031a)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_bm031amss_foreign_proprietary_trading_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Foreign Proprietary Trading Report (BM031a)
    report_code         String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt    Date                     COMMENT 'BK — kỳ báo cáo',
    item_code           String                   COMMENT 'PK — mã chỉ tiêu EAV, gán theo danh mục cố định của mẫu biểu BM031a_MSS',
    item_stt            Int64                    COMMENT 'Số thứ tự hiển thị của chỉ tiêu theo đúng layout mẫu biểu gốc',
    item_unit           Nullable(String)         COMMENT 'Đơn vị tính của chỉ tiêu',
    item_value          Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu — populate theo item_code và chỉ số breakdown, khối lượng/giá trị giao dịch NĐTNN/tự doanh thị trường cổ phiếu theo từng chỉ số (VNIndex/HNXIndex/HNX30/VN30)',
    src_stm_code        String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, item_code)
COMMENT 'Flat table — Foreign Proprietary Trading Report (BM031a)'
;


-- ============================================================
-- 16. OPERATIONAL: bm031bmss_gov_bond_foreign_proprietary_trading_rpt
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
-- 17. OPERATIONAL: bm031cmss_corp_bond_foreign_proprietary_trading_rpt
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
-- 18. OPERATIONAL: bm031dmss_fund_cert_etf_cw_foreign_proprietary_trading_rpt
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
-- 19. OPERATIONAL: bm031fmss_derivatives_foreign_proprietary_trading_rpt
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
-- 20. OPERATIONAL: bm035mss_security_trading_detail_rpt
--    Security Trading Detail Report (BM035)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_bm035mss_security_trading_detail_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Security Trading Detail Report (BM035)
    report_code             String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt        Date                     COMMENT 'BK — kỳ báo cáo',
    item_code               String                   COMMENT 'PK — mã chỉ tiêu EAV, gán theo danh mục cố định của mẫu biểu BM035_MSS',
    security_symbol_code    String                   COMMENT 'BK — mã chứng khoán/hợp đồng, 1 phần composite key (grain chi tiết theo từng mã)',
    item_stt                Int64                    COMMENT 'Số thứ tự hiển thị của chỉ tiêu theo đúng layout mẫu biểu gốc',
    item_unit               Nullable(String)         COMMENT 'Đơn vị tính của chỉ tiêu',
    item_value              Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu — populate theo item_code và mã CK, giá/khối lượng/giá trị giao dịch, GD NĐTNN/tự doanh chi tiết theo từng mã chứng khoán',
    src_stm_code            String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, item_code, security_symbol_code)
COMMENT 'Flat table — Security Trading Detail Report (BM035)'
;


-- ============================================================
-- 21. OPERATIONAL: bm043mss_derivatives_security_detail_rpt
--    Derivatives Security Detail Report (BM043)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.tknb_bm043mss_derivatives_security_detail_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Derivatives Security Detail Report (BM043)
    report_code             String                   COMMENT 'BK — mã báo cáo, hằng số cố định cho mọi dòng bảng này',
    report_period_dt        Date                     COMMENT 'BK — kỳ báo cáo',
    item_code               String                   COMMENT 'PK — mã chỉ tiêu EAV, gán theo danh mục cố định của mẫu biểu BM043_MSS',
    security_symbol_code    String                   COMMENT 'BK — mã chứng khoán/hợp đồng, 1 phần composite key (grain chi tiết theo từng mã)',
    item_stt                Int64                    COMMENT 'Số thứ tự hiển thị của chỉ tiêu theo đúng layout mẫu biểu gốc',
    item_unit               Nullable(String)         COMMENT 'Đơn vị tính của chỉ tiêu',
    item_value              Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu — populate theo item_code và mã hợp đồng, thời gian đáo hạn/khối lượng/giá trị giao dịch, GD NĐTNN/tự doanh chi tiết theo từng mã CKPS',
    src_stm_code            String                   COMMENT 'Mã hệ thống nguồn dữ liệu của báo cáo'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(report_period_dt)
ORDER BY (report_code, report_period_dt, item_code, security_symbol_code)
COMMENT 'Flat table — Derivatives Security Detail Report (BM043)'
;


