-- ============================================================
-- Common Flat Tables — POPULATE
-- Module: Common / Shared Dimensions (Toàn kho dữ liệu Datamart)
-- Generated: Phase 3 LLD Datamart — ClickHouse DML
-- Bảng đích: datamart.cdr_dt_flat
-- Bảng nguồn: datamart.cdr_dt_dim
-- Bảng đích: datamart.cl_flat
-- Bảng nguồn: datamart.cl_dim
-- ETL Strategy: TRUNCATE + INSERT toàn bộ ngày lịch từ datamart.cdr_dt_dim sang ClickHouse datamart.cdr_dt_flat
-- ============================================================

TRUNCATE TABLE datamart.cdr_dt_flat ON CLUSTER 'my_cluster';

INSERT INTO datamart.cdr_dt_flat
(
    cdr_dt_dim_id,
    cdr_dt,
    year,
    quarter,
    month,
    day_of_week,
    is_weekend,
    holiday_flag,
    is_trading_date
)
SELECT
    cdr_dt_dim_id,
    cdr_dt,
    year,
    quarter,
    month,
    day_of_week,
    is_weekend,
    holiday_flag,
    is_trading_date
FROM datamart.cdr_dt_dim
;

-- ============================================================
-- 2. POPULATE: datamart.cl_flat
--    ETL Strategy: TRUNCATE + INSERT toàn bộ giá trị phân loại từ datamart.cl_dim sang ClickHouse datamart.cl_flat
-- ============================================================

TRUNCATE TABLE datamart.cl_flat ON CLUSTER 'my_cluster';

INSERT INTO datamart.cl_flat
(
    cl_dim_id,
    schema_code,
    schema_nm,
    cl_code,
    cl_nm,
    cl_nm_english,
    cl_description,
    src_stm_code
)
SELECT
    cl_dim_id,
    schema_code,
    schema_nm,
    cl_code,
    cl_nm,
    cl_nm_english,
    cl_description,
    src_stm_code
FROM datamart.cl_dim
;
