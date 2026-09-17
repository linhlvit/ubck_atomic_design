-- ============================================================
-- Common Flat Tables — POPULATE
-- Module: Common / Shared Dimensions (Toàn kho dữ liệu Datamart)
-- Generated: Phase 3 LLD Datamart — ClickHouse DML
-- Bảng đích: datamart.cdr_dt_flat
-- Bảng nguồn: datamart.cdr_dt_dim
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
