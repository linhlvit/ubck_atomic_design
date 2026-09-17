-- ============================================================
-- Common Flat Tables — CREATE
-- Module: Common / Shared Dimensions (Toàn kho dữ liệu Datamart)
-- Generated: Phase 3 LLD Datamart — ClickHouse DDL
-- Thực thể: Calendar Date Dimension (lấy nguồn từ datamart.cdr_dt_dim)
-- Tên bảng ClickHouse: datamart.cdr_dt_flat
-- Mục đích: Khai thác trực tiếp chiều ngày lịch trên ClickHouse,
--          phục vụ truy vấn lịch thị trường, lọc ngày giao dịch is_trading_date,
--          tính lookback phiên và JOIN tối ưu với các bảng Fact phẳng.
-- ============================================================


-- ============================================================
-- 1. FLAT TABLE: datamart.cdr_dt_flat
--    Nguồn dữ liệu: datamart.cdr_dt_dim
--    Grain: Day (1 row / ngày lịch, đầy đủ 365/366 ngày/năm)
--    Cờ is_trading_date: 'Y' nếu là ngày mở cửa giao dịch thị trường CK, 'N' nếu không.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.cdr_dt_flat ON CLUSTER 'my_cluster'
(
    cdr_dt_dim_id       String                  COMMENT 'PK — Surrogate Key từ datamart.cdr_dt_dim',
    cdr_dt              Date                    COMMENT 'NK — Ngày lịch chuẩn (YYYY-MM-DD)',
    year                Int32                   COMMENT 'Năm (YYYY)',
    quarter             Int8                    COMMENT 'Quý (1–4)',
    month               Int8                    COMMENT 'Tháng (1–12)',
    day_of_week         Int8                    COMMENT 'Thứ trong tuần (1=Chủ nhật, 7=Thứ bảy)',
    is_weekend          String                  COMMENT 'Cờ Y/N — ngày cuối tuần (thứ 7 hoặc CN)',
    holiday_flag        Nullable(String)        COMMENT 'Cờ Y/N — ngày nghỉ lễ nhà nước',
    is_trading_date     String                  COMMENT 'Cờ Y/N — ngày giao dịch thực tế thị trường chứng khoán (có bản ghi trên Market Index Snapshot)'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYY(cdr_dt)
ORDER BY (cdr_dt, cdr_dt_dim_id)
COMMENT 'Bảng phẳng chiều Ngày lịch trên ClickHouse (nguồn từ datamart.cdr_dt_dim, phục vụ khai thác trực tiếp và join với các fact flat)'
;
