-- ============================================================
-- TKNB — ClickHouse flat THEO BÁO CÁO từ item_value (pipeline dev)
-- Nguồn: atomic_to_clickhouse_flow.md (dev, 2026-10-10): item_rule → datamart.uat_dtm.item_value → default.tknb_fct_{report_code_lowercase}_snpst_flat
-- 19 bảng (IV1–IV20 trừ IV4), db `default`, cluster `ssc_cluster`, ReplicatedMergeTree, PARTITION BY ds_snpst_dt, ORDER BY (item_code, ds_snpst_dt)
-- [2026-11-06] IV1–IV14 theo pipeline dev (đã có item_rule). IV15–IV20 (HNX04, HSX02, 0513.H.UBCK.QG, TK-04.BTC, TK_NienGiam, BM031d_MSS) là 6 báo cáo trước đây có bảng EAV riêng, nay gộp vào item_value theo Data Modeler (Atomic = item_rule, Datamart = item_value, flat trải theo báo cáo);
--   mã báo cáo/tên bảng flat IV15–IV20 là ĐỀ XUẤT — dev CHƯA có item_rule cho 6 báo cáo này, xem Open Issue 47 trong DTM_TKNB_HLD.md
-- [2026-11-06] IV4 (HNX06) ĐÃ BỎ: HNX06 chuyển Star Schema (Fact Government Bond Bidding Result Snapshot + Government Bond Term Dimension, Open Issue 48 trong DTM_TKNB_HLD.md) — không còn nạp vào item_value; số thứ tự IV4 để trống, không đánh số lại.
-- File này KHÔNG nằm trong luồng Gate 3/4/9 (các Gate đọc 01_/02_ và coi mỗi flat là 1 bảng LLD): 20 flat này là bảng phục vụ riêng từng báo cáo của 1 bảng LLD duy nhất `item_value`;
-- `item_value` không có flat gộp mọi báo cáo (Data Modeler bỏ 2026-10-25): serving chỉ qua 19 flat theo báo cáo dưới đây.
-- Giả định chờ dev xác nhận: report_code có dấu '-' (TK-HNX01) → tên bảng đổi '-' thành '_' (tk_hnx01). Xem Open Issue 41 (6) trong DTM_TKNB_HLD.md.
-- Phần 1: DDL (CREATE). Phần 2: DML (TRUNCATE + nạp lại toàn bộ lịch sử của báo cáo từ item_value).
-- ============================================================

-- ########## PHẦN 1 — DDL ##########

-- ============================================================
-- IV1. ITEM_VALUE: TK-HNX01 → default.tknb_fct_tk_hnx01_snpst_flat
--    Report Item Value — dữ liệu báo cáo TK-HNX01 lấy từ datamart.item_value (report_code = 'TK-HNX01')
-- ============================================================
CREATE TABLE IF NOT EXISTS default.tknb_fct_tk_hnx01_snpst_flat ON CLUSTER 'ssc_cluster'
(
    -- From: OPERATIONAL Report Item Value (item_value)
    item_code           String                   COMMENT 'Mã chỉ tiêu (item_rule.item_code) — BK',
    item_name           Nullable(String)         COMMENT 'Tên chỉ tiêu theo mẫu biểu',
    item_type           Nullable(String)         COMMENT 'Loại chỉ tiêu: Co so / Phai sinh / rỗng (header)',
    ds_snpst_dt         Date                     COMMENT 'Ngày tính chỉ tiêu (item_value.calc_date) — BK',
    value               Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu (item_value.value DECIMAL(23,2) đổi sang Float64 theo dev)',
    ds_etl_pcs_tms      DateTime DEFAULT now()   COMMENT 'ETL process timestamp'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/default/tknb_fct_tk_hnx01_snpst_flat', '{replica}')
PARTITION BY ds_snpst_dt
ORDER BY (item_code, ds_snpst_dt)
COMMENT 'Flat table — TK-HNX01 (Stock Trading Report (HNX01)) — từ item_value, 1 bảng/1 báo cáo theo pipeline dev'
;


-- ============================================================
-- IV2. ITEM_VALUE: HNX02 → default.tknb_fct_hnx02_snpst_flat
--    Report Item Value — dữ liệu báo cáo HNX02 lấy từ datamart.item_value (report_code = 'HNX02')
-- ============================================================
CREATE TABLE IF NOT EXISTS default.tknb_fct_hnx02_snpst_flat ON CLUSTER 'ssc_cluster'
(
    -- From: OPERATIONAL Report Item Value (item_value)
    item_code           String                   COMMENT 'Mã chỉ tiêu (item_rule.item_code) — BK',
    item_name           Nullable(String)         COMMENT 'Tên chỉ tiêu theo mẫu biểu',
    item_type           Nullable(String)         COMMENT 'Loại chỉ tiêu: Co so / Phai sinh / rỗng (header)',
    ds_snpst_dt         Date                     COMMENT 'Ngày tính chỉ tiêu (item_value.calc_date) — BK',
    value               Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu (item_value.value DECIMAL(23,2) đổi sang Float64 theo dev)',
    ds_etl_pcs_tms      DateTime DEFAULT now()   COMMENT 'ETL process timestamp'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/default/tknb_fct_hnx02_snpst_flat', '{replica}')
PARTITION BY ds_snpst_dt
ORDER BY (item_code, ds_snpst_dt)
COMMENT 'Flat table — HNX02 (Gov Bond OTC Trading Report (HNX02)) — từ item_value, 1 bảng/1 báo cáo theo pipeline dev'
;


-- ============================================================
-- IV3. ITEM_VALUE: TK-HNX03 → default.tknb_fct_tk_hnx03_snpst_flat
--    Report Item Value — dữ liệu báo cáo TK-HNX03 lấy từ datamart.item_value (report_code = 'TK-HNX03')
-- ============================================================
CREATE TABLE IF NOT EXISTS default.tknb_fct_tk_hnx03_snpst_flat ON CLUSTER 'ssc_cluster'
(
    -- From: OPERATIONAL Report Item Value (item_value)
    item_code           String                   COMMENT 'Mã chỉ tiêu (item_rule.item_code) — BK',
    item_name           Nullable(String)         COMMENT 'Tên chỉ tiêu theo mẫu biểu',
    item_type           Nullable(String)         COMMENT 'Loại chỉ tiêu: Co so / Phai sinh / rỗng (header)',
    ds_snpst_dt         Date                     COMMENT 'Ngày tính chỉ tiêu (item_value.calc_date) — BK',
    value               Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu (item_value.value DECIMAL(23,2) đổi sang Float64 theo dev)',
    ds_etl_pcs_tms      DateTime DEFAULT now()   COMMENT 'ETL process timestamp'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/default/tknb_fct_tk_hnx03_snpst_flat', '{replica}')
PARTITION BY ds_snpst_dt
ORDER BY (item_code, ds_snpst_dt)
COMMENT 'Flat table — TK-HNX03 (Derivative Trading Report (HNX03)) — từ item_value, 1 bảng/1 báo cáo theo pipeline dev'
;


-- ============================================================
-- IV5. ITEM_VALUE: TK-HNX07 → default.tknb_fct_tk_hnx07_snpst_flat
--    Report Item Value — dữ liệu báo cáo TK-HNX07 lấy từ datamart.item_value (report_code = 'TK-HNX07')
-- ============================================================
CREATE TABLE IF NOT EXISTS default.tknb_fct_tk_hnx07_snpst_flat ON CLUSTER 'ssc_cluster'
(
    -- From: OPERATIONAL Report Item Value (item_value)
    item_code           String                   COMMENT 'Mã chỉ tiêu (item_rule.item_code) — BK',
    item_name           Nullable(String)         COMMENT 'Tên chỉ tiêu theo mẫu biểu',
    item_type           Nullable(String)         COMMENT 'Loại chỉ tiêu: Co so / Phai sinh / rỗng (header)',
    ds_snpst_dt         Date                     COMMENT 'Ngày tính chỉ tiêu (item_value.calc_date) — BK',
    value               Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu (item_value.value DECIMAL(23,2) đổi sang Float64 theo dev)',
    ds_etl_pcs_tms      DateTime DEFAULT now()   COMMENT 'ETL process timestamp'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/default/tknb_fct_tk_hnx07_snpst_flat', '{replica}')
PARTITION BY ds_snpst_dt
ORDER BY (item_code, ds_snpst_dt)
COMMENT 'Flat table — TK-HNX07 (Corp Bond Trading Report (HNX07)) — từ item_value, 1 bảng/1 báo cáo theo pipeline dev'
;


-- ============================================================
-- IV6. ITEM_VALUE: TK-HSX01 → default.tknb_fct_tk_hsx01_snpst_flat
--    Report Item Value — dữ liệu báo cáo TK-HSX01 lấy từ datamart.item_value (report_code = 'TK-HSX01')
-- ============================================================
CREATE TABLE IF NOT EXISTS default.tknb_fct_tk_hsx01_snpst_flat ON CLUSTER 'ssc_cluster'
(
    -- From: OPERATIONAL Report Item Value (item_value)
    item_code           String                   COMMENT 'Mã chỉ tiêu (item_rule.item_code) — BK',
    item_name           Nullable(String)         COMMENT 'Tên chỉ tiêu theo mẫu biểu',
    item_type           Nullable(String)         COMMENT 'Loại chỉ tiêu: Co so / Phai sinh / rỗng (header)',
    ds_snpst_dt         Date                     COMMENT 'Ngày tính chỉ tiêu (item_value.calc_date) — BK',
    value               Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu (item_value.value DECIMAL(23,2) đổi sang Float64 theo dev)',
    ds_etl_pcs_tms      DateTime DEFAULT now()   COMMENT 'ETL process timestamp'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/default/tknb_fct_tk_hsx01_snpst_flat', '{replica}')
PARTITION BY ds_snpst_dt
ORDER BY (item_code, ds_snpst_dt)
COMMENT 'Flat table — TK-HSX01 (Stock Trading Report (HSX01)) — từ item_value, 1 bảng/1 báo cáo theo pipeline dev'
;


-- ============================================================
-- IV7. ITEM_VALUE: TK-HSX04 → default.tknb_fct_tk_hsx04_snpst_flat
--    Report Item Value — dữ liệu báo cáo TK-HSX04 lấy từ datamart.item_value (report_code = 'TK-HSX04')
-- ============================================================
CREATE TABLE IF NOT EXISTS default.tknb_fct_tk_hsx04_snpst_flat ON CLUSTER 'ssc_cluster'
(
    -- From: OPERATIONAL Report Item Value (item_value)
    item_code           String                   COMMENT 'Mã chỉ tiêu (item_rule.item_code) — BK',
    item_name           Nullable(String)         COMMENT 'Tên chỉ tiêu theo mẫu biểu',
    item_type           Nullable(String)         COMMENT 'Loại chỉ tiêu: Co so / Phai sinh / rỗng (header)',
    ds_snpst_dt         Date                     COMMENT 'Ngày tính chỉ tiêu (item_value.calc_date) — BK',
    value               Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu (item_value.value DECIMAL(23,2) đổi sang Float64 theo dev)',
    ds_etl_pcs_tms      DateTime DEFAULT now()   COMMENT 'ETL process timestamp'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/default/tknb_fct_tk_hsx04_snpst_flat', '{replica}')
PARTITION BY ds_snpst_dt
ORDER BY (item_code, ds_snpst_dt)
COMMENT 'Flat table — TK-HSX04 (Proprietary Trading Report (HSX04)) — từ item_value, 1 bảng/1 báo cáo theo pipeline dev'
;


-- ============================================================
-- IV8. ITEM_VALUE: BM030b_MSS → default.tknb_fct_bm030b_mss_snpst_flat
--    Report Item Value — dữ liệu báo cáo BM030b_MSS lấy từ datamart.item_value (report_code = 'BM030b_MSS')
-- ============================================================
CREATE TABLE IF NOT EXISTS default.tknb_fct_bm030b_mss_snpst_flat ON CLUSTER 'ssc_cluster'
(
    -- From: OPERATIONAL Report Item Value (item_value)
    item_code           String                   COMMENT 'Mã chỉ tiêu (item_rule.item_code) — BK',
    item_name           Nullable(String)         COMMENT 'Tên chỉ tiêu theo mẫu biểu',
    item_type           Nullable(String)         COMMENT 'Loại chỉ tiêu: Co so / Phai sinh / rỗng (header)',
    ds_snpst_dt         Date                     COMMENT 'Ngày tính chỉ tiêu (item_value.calc_date) — BK',
    value               Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu (item_value.value DECIMAL(23,2) đổi sang Float64 theo dev)',
    ds_etl_pcs_tms      DateTime DEFAULT now()   COMMENT 'ETL process timestamp'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/default/tknb_fct_bm030b_mss_snpst_flat', '{replica}')
PARTITION BY ds_snpst_dt
ORDER BY (item_code, ds_snpst_dt)
COMMENT 'Flat table — BM030b_MSS (Gov Bond Trading Report (BM030b)) — từ item_value, 1 bảng/1 báo cáo theo pipeline dev'
;


-- ============================================================
-- IV9. ITEM_VALUE: BM030c_MSS → default.tknb_fct_bm030c_mss_snpst_flat
--    Report Item Value — dữ liệu báo cáo BM030c_MSS lấy từ datamart.item_value (report_code = 'BM030c_MSS')
-- ============================================================
CREATE TABLE IF NOT EXISTS default.tknb_fct_bm030c_mss_snpst_flat ON CLUSTER 'ssc_cluster'
(
    -- From: OPERATIONAL Report Item Value (item_value)
    item_code           String                   COMMENT 'Mã chỉ tiêu (item_rule.item_code) — BK',
    item_name           Nullable(String)         COMMENT 'Tên chỉ tiêu theo mẫu biểu',
    item_type           Nullable(String)         COMMENT 'Loại chỉ tiêu: Co so / Phai sinh / rỗng (header)',
    ds_snpst_dt         Date                     COMMENT 'Ngày tính chỉ tiêu (item_value.calc_date) — BK',
    value               Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu (item_value.value DECIMAL(23,2) đổi sang Float64 theo dev)',
    ds_etl_pcs_tms      DateTime DEFAULT now()   COMMENT 'ETL process timestamp'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/default/tknb_fct_bm030c_mss_snpst_flat', '{replica}')
PARTITION BY ds_snpst_dt
ORDER BY (item_code, ds_snpst_dt)
COMMENT 'Flat table — BM030c_MSS (Corp Bond Trading Report (BM030c)) — từ item_value, 1 bảng/1 báo cáo theo pipeline dev'
;


-- ============================================================
-- IV10. ITEM_VALUE: BM030d_MSS → default.tknb_fct_bm030d_mss_snpst_flat
--    Report Item Value — dữ liệu báo cáo BM030d_MSS lấy từ datamart.item_value (report_code = 'BM030d_MSS')
-- ============================================================
CREATE TABLE IF NOT EXISTS default.tknb_fct_bm030d_mss_snpst_flat ON CLUSTER 'ssc_cluster'
(
    -- From: OPERATIONAL Report Item Value (item_value)
    item_code           String                   COMMENT 'Mã chỉ tiêu (item_rule.item_code) — BK',
    item_name           Nullable(String)         COMMENT 'Tên chỉ tiêu theo mẫu biểu',
    item_type           Nullable(String)         COMMENT 'Loại chỉ tiêu: Co so / Phai sinh / rỗng (header)',
    ds_snpst_dt         Date                     COMMENT 'Ngày tính chỉ tiêu (item_value.calc_date) — BK',
    value               Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu (item_value.value DECIMAL(23,2) đổi sang Float64 theo dev)',
    ds_etl_pcs_tms      DateTime DEFAULT now()   COMMENT 'ETL process timestamp'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/default/tknb_fct_bm030d_mss_snpst_flat', '{replica}')
PARTITION BY ds_snpst_dt
ORDER BY (item_code, ds_snpst_dt)
COMMENT 'Flat table — BM030d_MSS (OTC Corp Bond Trading Report (BM030d)) — từ item_value, 1 bảng/1 báo cáo theo pipeline dev'
;


-- ============================================================
-- IV11. ITEM_VALUE: BM030e_MSS → default.tknb_fct_bm030e_mss_snpst_flat
--    Report Item Value — dữ liệu báo cáo BM030e_MSS lấy từ datamart.item_value (report_code = 'BM030e_MSS')
-- ============================================================
CREATE TABLE IF NOT EXISTS default.tknb_fct_bm030e_mss_snpst_flat ON CLUSTER 'ssc_cluster'
(
    -- From: OPERATIONAL Report Item Value (item_value)
    item_code           String                   COMMENT 'Mã chỉ tiêu (item_rule.item_code) — BK',
    item_name           Nullable(String)         COMMENT 'Tên chỉ tiêu theo mẫu biểu',
    item_type           Nullable(String)         COMMENT 'Loại chỉ tiêu: Co so / Phai sinh / rỗng (header)',
    ds_snpst_dt         Date                     COMMENT 'Ngày tính chỉ tiêu (item_value.calc_date) — BK',
    value               Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu (item_value.value DECIMAL(23,2) đổi sang Float64 theo dev)',
    ds_etl_pcs_tms      DateTime DEFAULT now()   COMMENT 'ETL process timestamp'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/default/tknb_fct_bm030e_mss_snpst_flat', '{replica}')
PARTITION BY ds_snpst_dt
ORDER BY (item_code, ds_snpst_dt)
COMMENT 'Flat table — BM030e_MSS (Fund Cert ETF CW Trading Report (BM030e)) — từ item_value, 1 bảng/1 báo cáo theo pipeline dev'
;


-- ============================================================
-- IV12. ITEM_VALUE: BM030f_MSS → default.tknb_fct_bm030f_mss_snpst_flat
--    Report Item Value — dữ liệu báo cáo BM030f_MSS lấy từ datamart.item_value (report_code = 'BM030f_MSS')
-- ============================================================
CREATE TABLE IF NOT EXISTS default.tknb_fct_bm030f_mss_snpst_flat ON CLUSTER 'ssc_cluster'
(
    -- From: OPERATIONAL Report Item Value (item_value)
    item_code           String                   COMMENT 'Mã chỉ tiêu (item_rule.item_code) — BK',
    item_name           Nullable(String)         COMMENT 'Tên chỉ tiêu theo mẫu biểu',
    item_type           Nullable(String)         COMMENT 'Loại chỉ tiêu: Co so / Phai sinh / rỗng (header)',
    ds_snpst_dt         Date                     COMMENT 'Ngày tính chỉ tiêu (item_value.calc_date) — BK',
    value               Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu (item_value.value DECIMAL(23,2) đổi sang Float64 theo dev)',
    ds_etl_pcs_tms      DateTime DEFAULT now()   COMMENT 'ETL process timestamp'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/default/tknb_fct_bm030f_mss_snpst_flat', '{replica}')
PARTITION BY ds_snpst_dt
ORDER BY (item_code, ds_snpst_dt)
COMMENT 'Flat table — BM030f_MSS (Derivatives Trading Report (BM030f)) — từ item_value, 1 bảng/1 báo cáo theo pipeline dev'
;


-- ============================================================
-- IV13. ITEM_VALUE: BM031b_MSS → default.tknb_fct_bm031b_mss_snpst_flat
--    Report Item Value — dữ liệu báo cáo BM031b_MSS lấy từ datamart.item_value (report_code = 'BM031b_MSS')
-- ============================================================
CREATE TABLE IF NOT EXISTS default.tknb_fct_bm031b_mss_snpst_flat ON CLUSTER 'ssc_cluster'
(
    -- From: OPERATIONAL Report Item Value (item_value)
    item_code           String                   COMMENT 'Mã chỉ tiêu (item_rule.item_code) — BK',
    item_name           Nullable(String)         COMMENT 'Tên chỉ tiêu theo mẫu biểu',
    item_type           Nullable(String)         COMMENT 'Loại chỉ tiêu: Co so / Phai sinh / rỗng (header)',
    ds_snpst_dt         Date                     COMMENT 'Ngày tính chỉ tiêu (item_value.calc_date) — BK',
    value               Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu (item_value.value DECIMAL(23,2) đổi sang Float64 theo dev)',
    ds_etl_pcs_tms      DateTime DEFAULT now()   COMMENT 'ETL process timestamp'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/default/tknb_fct_bm031b_mss_snpst_flat', '{replica}')
PARTITION BY ds_snpst_dt
ORDER BY (item_code, ds_snpst_dt)
COMMENT 'Flat table — BM031b_MSS (Gov Bond Foreign Proprietary Trading Report (BM031b)) — từ item_value, 1 bảng/1 báo cáo theo pipeline dev'
;


-- ============================================================
-- IV14. ITEM_VALUE: BM031c_MSS → default.tknb_fct_bm031c_mss_snpst_flat
--    Report Item Value — dữ liệu báo cáo BM031c_MSS lấy từ datamart.item_value (report_code = 'BM031c_MSS')
-- ============================================================
CREATE TABLE IF NOT EXISTS default.tknb_fct_bm031c_mss_snpst_flat ON CLUSTER 'ssc_cluster'
(
    -- From: OPERATIONAL Report Item Value (item_value)
    item_code           String                   COMMENT 'Mã chỉ tiêu (item_rule.item_code) — BK',
    item_name           Nullable(String)         COMMENT 'Tên chỉ tiêu theo mẫu biểu',
    item_type           Nullable(String)         COMMENT 'Loại chỉ tiêu: Co so / Phai sinh / rỗng (header)',
    ds_snpst_dt         Date                     COMMENT 'Ngày tính chỉ tiêu (item_value.calc_date) — BK',
    value               Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu (item_value.value DECIMAL(23,2) đổi sang Float64 theo dev)',
    ds_etl_pcs_tms      DateTime DEFAULT now()   COMMENT 'ETL process timestamp'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/default/tknb_fct_bm031c_mss_snpst_flat', '{replica}')
PARTITION BY ds_snpst_dt
ORDER BY (item_code, ds_snpst_dt)
COMMENT 'Flat table — BM031c_MSS (Corp Bond Foreign Proprietary Trading Report (BM031c)) — từ item_value, 1 bảng/1 báo cáo theo pipeline dev'
;

-- ============================================================
-- IV15. ITEM_VALUE: HNX04 → default.tknb_fct_hnx04_snpst_flat
--    Report Item Value — dữ liệu báo cáo HNX04 lấy từ datamart.item_value (report_code = 'HNX04')
-- ============================================================
CREATE TABLE IF NOT EXISTS default.tknb_fct_hnx04_snpst_flat ON CLUSTER 'ssc_cluster'
(
    -- From: OPERATIONAL Report Item Value (item_value)
    item_code           String                   COMMENT 'Mã chỉ tiêu (item_rule.item_code) — BK',
    item_name           Nullable(String)         COMMENT 'Tên chỉ tiêu theo mẫu biểu',
    item_type           Nullable(String)         COMMENT 'Loại chỉ tiêu: Co so / Phai sinh / rỗng (header)',
    ds_snpst_dt         Date                     COMMENT 'Ngày tính chỉ tiêu (item_value.calc_date) — BK',
    value               Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu (item_value.value DECIMAL(23,2) đổi sang Float64 theo dev)',
    ds_etl_pcs_tms      DateTime DEFAULT now()   COMMENT 'ETL process timestamp'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/default/tknb_fct_hnx04_snpst_flat', '{replica}')
PARTITION BY ds_snpst_dt
ORDER BY (item_code, ds_snpst_dt)
COMMENT 'Flat table — HNX04 (Market Scale Report (HNX04)) — từ item_value, 1 bảng/1 báo cáo theo pipeline dev'
;

-- ============================================================
-- IV16. ITEM_VALUE: HSX02 → default.tknb_fct_hsx02_snpst_flat
--    Report Item Value — dữ liệu báo cáo HSX02 lấy từ datamart.item_value (report_code = 'HSX02')
-- ============================================================
CREATE TABLE IF NOT EXISTS default.tknb_fct_hsx02_snpst_flat ON CLUSTER 'ssc_cluster'
(
    -- From: OPERATIONAL Report Item Value (item_value)
    item_code           String                   COMMENT 'Mã chỉ tiêu (item_rule.item_code) — BK',
    item_name           Nullable(String)         COMMENT 'Tên chỉ tiêu theo mẫu biểu',
    item_type           Nullable(String)         COMMENT 'Loại chỉ tiêu: Co so / Phai sinh / rỗng (header)',
    ds_snpst_dt         Date                     COMMENT 'Ngày tính chỉ tiêu (item_value.calc_date) — BK',
    value               Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu (item_value.value DECIMAL(23,2) đổi sang Float64 theo dev)',
    ds_etl_pcs_tms      DateTime DEFAULT now()   COMMENT 'ETL process timestamp'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/default/tknb_fct_hsx02_snpst_flat', '{replica}')
PARTITION BY ds_snpst_dt
ORDER BY (item_code, ds_snpst_dt)
COMMENT 'Flat table — HSX02 (Listing Trading Report (HSX02)) — từ item_value, 1 bảng/1 báo cáo theo pipeline dev'
;

-- ============================================================
-- IV17. ITEM_VALUE: 0513.H.UBCK.QG → default.tknb_fct_0513_h_ubck_qg_snpst_flat
--    Report Item Value — dữ liệu báo cáo 0513.H.UBCK.QG lấy từ datamart.item_value (report_code = '0513.H.UBCK.QG')
-- ============================================================
CREATE TABLE IF NOT EXISTS default.tknb_fct_0513_h_ubck_qg_snpst_flat ON CLUSTER 'ssc_cluster'
(
    -- From: OPERATIONAL Report Item Value (item_value)
    item_code           String                   COMMENT 'Mã chỉ tiêu (item_rule.item_code) — BK',
    item_name           Nullable(String)         COMMENT 'Tên chỉ tiêu theo mẫu biểu',
    item_type           Nullable(String)         COMMENT 'Loại chỉ tiêu: Co so / Phai sinh / rỗng (header)',
    ds_snpst_dt         Date                     COMMENT 'Ngày tính chỉ tiêu (item_value.calc_date) — BK',
    value               Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu (item_value.value DECIMAL(23,2) đổi sang Float64 theo dev)',
    ds_etl_pcs_tms      DateTime DEFAULT now()   COMMENT 'ETL process timestamp'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/default/tknb_fct_0513_h_ubck_qg_snpst_flat', '{replica}')
PARTITION BY ds_snpst_dt
ORDER BY (item_code, ds_snpst_dt)
COMMENT 'Flat table — 0513.H.UBCK.QG (Offering Result Report (0513.H.UBCK.QG)) — từ item_value, 1 bảng/1 báo cáo theo pipeline dev'
;

-- ============================================================
-- IV18. ITEM_VALUE: TK-04.BTC → default.tknb_fct_tk_04_btc_snpst_flat
--    Report Item Value — dữ liệu báo cáo TK-04.BTC lấy từ datamart.item_value (report_code = 'TK-04.BTC')
-- ============================================================
CREATE TABLE IF NOT EXISTS default.tknb_fct_tk_04_btc_snpst_flat ON CLUSTER 'ssc_cluster'
(
    -- From: OPERATIONAL Report Item Value (item_value)
    item_code           String                   COMMENT 'Mã chỉ tiêu (item_rule.item_code) — BK',
    item_name           Nullable(String)         COMMENT 'Tên chỉ tiêu theo mẫu biểu',
    item_type           Nullable(String)         COMMENT 'Loại chỉ tiêu: Co so / Phai sinh / rỗng (header)',
    ds_snpst_dt         Date                     COMMENT 'Ngày tính chỉ tiêu (item_value.calc_date) — BK',
    value               Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu (item_value.value DECIMAL(23,2) đổi sang Float64 theo dev)',
    ds_etl_pcs_tms      DateTime DEFAULT now()   COMMENT 'ETL process timestamp'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/default/tknb_fct_tk_04_btc_snpst_flat', '{replica}')
PARTITION BY ds_snpst_dt
ORDER BY (item_code, ds_snpst_dt)
COMMENT 'Flat table — TK-04.BTC (Market Summary Report (TK-04.BTC)) — từ item_value, 1 bảng/1 báo cáo theo pipeline dev'
;

-- ============================================================
-- IV19. ITEM_VALUE: TK_NienGiam → default.tknb_fct_tk_niengiam_snpst_flat
--    Report Item Value — dữ liệu báo cáo TK_NienGiam lấy từ datamart.item_value (report_code = 'TK_NienGiam')
-- ============================================================
CREATE TABLE IF NOT EXISTS default.tknb_fct_tk_niengiam_snpst_flat ON CLUSTER 'ssc_cluster'
(
    -- From: OPERATIONAL Report Item Value (item_value)
    item_code           String                   COMMENT 'Mã chỉ tiêu (item_rule.item_code) — BK',
    item_name           Nullable(String)         COMMENT 'Tên chỉ tiêu theo mẫu biểu',
    item_type           Nullable(String)         COMMENT 'Loại chỉ tiêu: Co so / Phai sinh / rỗng (header)',
    ds_snpst_dt         Date                     COMMENT 'Ngày tính chỉ tiêu (item_value.calc_date) — BK',
    value               Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu (item_value.value DECIMAL(23,2) đổi sang Float64 theo dev)',
    ds_etl_pcs_tms      DateTime DEFAULT now()   COMMENT 'ETL process timestamp'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/default/tknb_fct_tk_niengiam_snpst_flat', '{replica}')
PARTITION BY ds_snpst_dt
ORDER BY (item_code, ds_snpst_dt)
COMMENT 'Flat table — TK_NienGiam (Market Annual Report (TK_NienGiam)) — từ item_value, 1 bảng/1 báo cáo theo pipeline dev'
;

-- ============================================================
-- IV20. ITEM_VALUE: BM031d_MSS → default.tknb_fct_bm031d_mss_snpst_flat
--    Report Item Value — dữ liệu báo cáo BM031d_MSS lấy từ datamart.item_value (report_code = 'BM031d_MSS')
-- ============================================================
CREATE TABLE IF NOT EXISTS default.tknb_fct_bm031d_mss_snpst_flat ON CLUSTER 'ssc_cluster'
(
    -- From: OPERATIONAL Report Item Value (item_value)
    item_code           String                   COMMENT 'Mã chỉ tiêu (item_rule.item_code) — BK',
    item_name           Nullable(String)         COMMENT 'Tên chỉ tiêu theo mẫu biểu',
    item_type           Nullable(String)         COMMENT 'Loại chỉ tiêu: Co so / Phai sinh / rỗng (header)',
    ds_snpst_dt         Date                     COMMENT 'Ngày tính chỉ tiêu (item_value.calc_date) — BK',
    value               Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu (item_value.value DECIMAL(23,2) đổi sang Float64 theo dev)',
    ds_etl_pcs_tms      DateTime DEFAULT now()   COMMENT 'ETL process timestamp'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/default/tknb_fct_bm031d_mss_snpst_flat', '{replica}')
PARTITION BY ds_snpst_dt
ORDER BY (item_code, ds_snpst_dt)
COMMENT 'Flat table — BM031d_MSS (Fund Cert ETF CW Foreign Proprietary Trading Report (BM031d)) — từ item_value, 1 bảng/1 báo cáo theo pipeline dev'
;



-- ########## PHẦN 2 — DML ##########

-- ============================================================
-- IV1. ITEM_VALUE: TK-HNX01
-- ============================================================
TRUNCATE TABLE IF EXISTS default.tknb_fct_tk_hnx01_snpst_flat ON CLUSTER 'ssc_cluster';
INSERT INTO default.tknb_fct_tk_hnx01_snpst_flat
SELECT
    o.item_code,
    o.item_name,
    o.item_type,
    o.calc_date AS ds_snpst_dt,
    toFloat64(o.value) AS value,
    o.ds_etl_pcs_tms
FROM datamart.item_value o
WHERE o.report_code = 'TK-HNX01'
;


-- ============================================================
-- IV2. ITEM_VALUE: HNX02
-- ============================================================
TRUNCATE TABLE IF EXISTS default.tknb_fct_hnx02_snpst_flat ON CLUSTER 'ssc_cluster';
INSERT INTO default.tknb_fct_hnx02_snpst_flat
SELECT
    o.item_code,
    o.item_name,
    o.item_type,
    o.calc_date AS ds_snpst_dt,
    toFloat64(o.value) AS value,
    o.ds_etl_pcs_tms
FROM datamart.item_value o
WHERE o.report_code = 'HNX02'
;


-- ============================================================
-- IV3. ITEM_VALUE: TK-HNX03
-- ============================================================
TRUNCATE TABLE IF EXISTS default.tknb_fct_tk_hnx03_snpst_flat ON CLUSTER 'ssc_cluster';
INSERT INTO default.tknb_fct_tk_hnx03_snpst_flat
SELECT
    o.item_code,
    o.item_name,
    o.item_type,
    o.calc_date AS ds_snpst_dt,
    toFloat64(o.value) AS value,
    o.ds_etl_pcs_tms
FROM datamart.item_value o
WHERE o.report_code = 'TK-HNX03'
;


-- ============================================================
-- IV5. ITEM_VALUE: TK-HNX07
-- ============================================================
TRUNCATE TABLE IF EXISTS default.tknb_fct_tk_hnx07_snpst_flat ON CLUSTER 'ssc_cluster';
INSERT INTO default.tknb_fct_tk_hnx07_snpst_flat
SELECT
    o.item_code,
    o.item_name,
    o.item_type,
    o.calc_date AS ds_snpst_dt,
    toFloat64(o.value) AS value,
    o.ds_etl_pcs_tms
FROM datamart.item_value o
WHERE o.report_code = 'TK-HNX07'
;


-- ============================================================
-- IV6. ITEM_VALUE: TK-HSX01
-- ============================================================
TRUNCATE TABLE IF EXISTS default.tknb_fct_tk_hsx01_snpst_flat ON CLUSTER 'ssc_cluster';
INSERT INTO default.tknb_fct_tk_hsx01_snpst_flat
SELECT
    o.item_code,
    o.item_name,
    o.item_type,
    o.calc_date AS ds_snpst_dt,
    toFloat64(o.value) AS value,
    o.ds_etl_pcs_tms
FROM datamart.item_value o
WHERE o.report_code = 'TK-HSX01'
;


-- ============================================================
-- IV7. ITEM_VALUE: TK-HSX04
-- ============================================================
TRUNCATE TABLE IF EXISTS default.tknb_fct_tk_hsx04_snpst_flat ON CLUSTER 'ssc_cluster';
INSERT INTO default.tknb_fct_tk_hsx04_snpst_flat
SELECT
    o.item_code,
    o.item_name,
    o.item_type,
    o.calc_date AS ds_snpst_dt,
    toFloat64(o.value) AS value,
    o.ds_etl_pcs_tms
FROM datamart.item_value o
WHERE o.report_code = 'TK-HSX04'
;


-- ============================================================
-- IV8. ITEM_VALUE: BM030b_MSS
-- ============================================================
TRUNCATE TABLE IF EXISTS default.tknb_fct_bm030b_mss_snpst_flat ON CLUSTER 'ssc_cluster';
INSERT INTO default.tknb_fct_bm030b_mss_snpst_flat
SELECT
    o.item_code,
    o.item_name,
    o.item_type,
    o.calc_date AS ds_snpst_dt,
    toFloat64(o.value) AS value,
    o.ds_etl_pcs_tms
FROM datamart.item_value o
WHERE o.report_code = 'BM030b_MSS'
;


-- ============================================================
-- IV9. ITEM_VALUE: BM030c_MSS
-- ============================================================
TRUNCATE TABLE IF EXISTS default.tknb_fct_bm030c_mss_snpst_flat ON CLUSTER 'ssc_cluster';
INSERT INTO default.tknb_fct_bm030c_mss_snpst_flat
SELECT
    o.item_code,
    o.item_name,
    o.item_type,
    o.calc_date AS ds_snpst_dt,
    toFloat64(o.value) AS value,
    o.ds_etl_pcs_tms
FROM datamart.item_value o
WHERE o.report_code = 'BM030c_MSS'
;


-- ============================================================
-- IV10. ITEM_VALUE: BM030d_MSS
-- ============================================================
TRUNCATE TABLE IF EXISTS default.tknb_fct_bm030d_mss_snpst_flat ON CLUSTER 'ssc_cluster';
INSERT INTO default.tknb_fct_bm030d_mss_snpst_flat
SELECT
    o.item_code,
    o.item_name,
    o.item_type,
    o.calc_date AS ds_snpst_dt,
    toFloat64(o.value) AS value,
    o.ds_etl_pcs_tms
FROM datamart.item_value o
WHERE o.report_code = 'BM030d_MSS'
;


-- ============================================================
-- IV11. ITEM_VALUE: BM030e_MSS
-- ============================================================
TRUNCATE TABLE IF EXISTS default.tknb_fct_bm030e_mss_snpst_flat ON CLUSTER 'ssc_cluster';
INSERT INTO default.tknb_fct_bm030e_mss_snpst_flat
SELECT
    o.item_code,
    o.item_name,
    o.item_type,
    o.calc_date AS ds_snpst_dt,
    toFloat64(o.value) AS value,
    o.ds_etl_pcs_tms
FROM datamart.item_value o
WHERE o.report_code = 'BM030e_MSS'
;


-- ============================================================
-- IV12. ITEM_VALUE: BM030f_MSS
-- ============================================================
TRUNCATE TABLE IF EXISTS default.tknb_fct_bm030f_mss_snpst_flat ON CLUSTER 'ssc_cluster';
INSERT INTO default.tknb_fct_bm030f_mss_snpst_flat
SELECT
    o.item_code,
    o.item_name,
    o.item_type,
    o.calc_date AS ds_snpst_dt,
    toFloat64(o.value) AS value,
    o.ds_etl_pcs_tms
FROM datamart.item_value o
WHERE o.report_code = 'BM030f_MSS'
;


-- ============================================================
-- IV13. ITEM_VALUE: BM031b_MSS
-- ============================================================
TRUNCATE TABLE IF EXISTS default.tknb_fct_bm031b_mss_snpst_flat ON CLUSTER 'ssc_cluster';
INSERT INTO default.tknb_fct_bm031b_mss_snpst_flat
SELECT
    o.item_code,
    o.item_name,
    o.item_type,
    o.calc_date AS ds_snpst_dt,
    toFloat64(o.value) AS value,
    o.ds_etl_pcs_tms
FROM datamart.item_value o
WHERE o.report_code = 'BM031b_MSS'
;


-- ============================================================
-- IV14. ITEM_VALUE: BM031c_MSS
-- ============================================================
TRUNCATE TABLE IF EXISTS default.tknb_fct_bm031c_mss_snpst_flat ON CLUSTER 'ssc_cluster';
INSERT INTO default.tknb_fct_bm031c_mss_snpst_flat
SELECT
    o.item_code,
    o.item_name,
    o.item_type,
    o.calc_date AS ds_snpst_dt,
    toFloat64(o.value) AS value,
    o.ds_etl_pcs_tms
FROM datamart.item_value o
WHERE o.report_code = 'BM031c_MSS'
;


-- ============================================================
-- IV15. ITEM_VALUE: HNX04
-- ============================================================
TRUNCATE TABLE IF EXISTS default.tknb_fct_hnx04_snpst_flat ON CLUSTER 'ssc_cluster';
INSERT INTO default.tknb_fct_hnx04_snpst_flat
SELECT
    o.item_code,
    o.item_name,
    o.item_type,
    o.calc_date AS ds_snpst_dt,
    toFloat64(o.value) AS value,
    o.ds_etl_pcs_tms
FROM datamart.item_value o
WHERE o.report_code = 'HNX04'
;


-- ============================================================
-- IV16. ITEM_VALUE: HSX02
-- ============================================================
TRUNCATE TABLE IF EXISTS default.tknb_fct_hsx02_snpst_flat ON CLUSTER 'ssc_cluster';
INSERT INTO default.tknb_fct_hsx02_snpst_flat
SELECT
    o.item_code,
    o.item_name,
    o.item_type,
    o.calc_date AS ds_snpst_dt,
    toFloat64(o.value) AS value,
    o.ds_etl_pcs_tms
FROM datamart.item_value o
WHERE o.report_code = 'HSX02'
;


-- ============================================================
-- IV17. ITEM_VALUE: 0513.H.UBCK.QG
-- ============================================================
TRUNCATE TABLE IF EXISTS default.tknb_fct_0513_h_ubck_qg_snpst_flat ON CLUSTER 'ssc_cluster';
INSERT INTO default.tknb_fct_0513_h_ubck_qg_snpst_flat
SELECT
    o.item_code,
    o.item_name,
    o.item_type,
    o.calc_date AS ds_snpst_dt,
    toFloat64(o.value) AS value,
    o.ds_etl_pcs_tms
FROM datamart.item_value o
WHERE o.report_code = '0513.H.UBCK.QG'
;


-- ============================================================
-- IV18. ITEM_VALUE: TK-04.BTC
-- ============================================================
TRUNCATE TABLE IF EXISTS default.tknb_fct_tk_04_btc_snpst_flat ON CLUSTER 'ssc_cluster';
INSERT INTO default.tknb_fct_tk_04_btc_snpst_flat
SELECT
    o.item_code,
    o.item_name,
    o.item_type,
    o.calc_date AS ds_snpst_dt,
    toFloat64(o.value) AS value,
    o.ds_etl_pcs_tms
FROM datamart.item_value o
WHERE o.report_code = 'TK-04.BTC'
;


-- ============================================================
-- IV19. ITEM_VALUE: TK_NienGiam
-- ============================================================
TRUNCATE TABLE IF EXISTS default.tknb_fct_tk_niengiam_snpst_flat ON CLUSTER 'ssc_cluster';
INSERT INTO default.tknb_fct_tk_niengiam_snpst_flat
SELECT
    o.item_code,
    o.item_name,
    o.item_type,
    o.calc_date AS ds_snpst_dt,
    toFloat64(o.value) AS value,
    o.ds_etl_pcs_tms
FROM datamart.item_value o
WHERE o.report_code = 'TK_NienGiam'
;


-- ============================================================
-- IV20. ITEM_VALUE: BM031d_MSS
-- ============================================================
TRUNCATE TABLE IF EXISTS default.tknb_fct_bm031d_mss_snpst_flat ON CLUSTER 'ssc_cluster';
INSERT INTO default.tknb_fct_bm031d_mss_snpst_flat
SELECT
    o.item_code,
    o.item_name,
    o.item_type,
    o.calc_date AS ds_snpst_dt,
    toFloat64(o.value) AS value,
    o.ds_etl_pcs_tms
FROM datamart.item_value o
WHERE o.report_code = 'BM031d_MSS'
;
