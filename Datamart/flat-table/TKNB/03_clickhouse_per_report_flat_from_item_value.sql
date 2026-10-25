-- ============================================================
-- TKNB — ClickHouse flat THEO BÁO CÁO từ item_value (pipeline dev)
-- Nguồn: atomic_to_clickhouse_flow.md (dev, 2026-10-10): item_rule → datamart.uat_dtm.item_value → default.tknb_fct_{report_code_lowercase}_snpst_flat
-- 14 bảng (IV1–IV14), db `default`, cluster `ssc_cluster`, ReplicatedMergeTree, PARTITION BY ds_snpst_dt, ORDER BY (item_code, ds_snpst_dt)
-- File này KHÔNG nằm trong luồng Gate 3/4/9 (các Gate đọc 01_/02_ và coi mỗi flat là 1 bảng LLD): 14 flat này là bảng phục vụ riêng từng báo cáo của 1 bảng LLD duy nhất `item_value`;
-- `item_value` không có flat gộp mọi báo cáo (Data Modeler bỏ 2026-10-25): serving chỉ qua 14 flat theo báo cáo dưới đây.
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
-- IV4. ITEM_VALUE: HNX06 → default.tknb_fct_hnx06_snpst_flat
--    Report Item Value — dữ liệu báo cáo HNX06 lấy từ datamart.item_value (report_code = 'HNX06')
-- ============================================================
CREATE TABLE IF NOT EXISTS default.tknb_fct_hnx06_snpst_flat ON CLUSTER 'ssc_cluster'
(
    -- From: OPERATIONAL Report Item Value (item_value)
    item_code           String                   COMMENT 'Mã chỉ tiêu (item_rule.item_code) — BK',
    item_name           Nullable(String)         COMMENT 'Tên chỉ tiêu theo mẫu biểu',
    item_type           Nullable(String)         COMMENT 'Loại chỉ tiêu: Co so / Phai sinh / rỗng (header)',
    ds_snpst_dt         Date                     COMMENT 'Ngày tính chỉ tiêu (item_value.calc_date) — BK',
    value               Nullable(Float64)        COMMENT 'Giá trị chỉ tiêu (item_value.value DECIMAL(23,2) đổi sang Float64 theo dev)',
    ds_etl_pcs_tms      DateTime DEFAULT now()   COMMENT 'ETL process timestamp'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/default/tknb_fct_hnx06_snpst_flat', '{replica}')
PARTITION BY ds_snpst_dt
ORDER BY (item_code, ds_snpst_dt)
COMMENT 'Flat table — HNX06 (Gov Bond Bidding Report (HNX06)) — từ item_value, 1 bảng/1 báo cáo theo pipeline dev'
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
-- IV4. ITEM_VALUE: HNX06
-- ============================================================
TRUNCATE TABLE IF EXISTS default.tknb_fct_hnx06_snpst_flat ON CLUSTER 'ssc_cluster';
INSERT INTO default.tknb_fct_hnx06_snpst_flat
SELECT
    o.item_code,
    o.item_name,
    o.item_type,
    o.calc_date AS ds_snpst_dt,
    toFloat64(o.value) AS value,
    o.ds_etl_pcs_tms
FROM datamart.item_value o
WHERE o.report_code = 'HNX06'
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
