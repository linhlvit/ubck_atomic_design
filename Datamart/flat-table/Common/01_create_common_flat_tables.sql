-- ============================================================
-- Common Flat Tables — CREATE
-- Module: Common / Shared Dimensions (Toàn kho dữ liệu Datamart)
-- Generated: Phase 3 LLD Datamart — ClickHouse DDL
-- Thực thể: Calendar Date Dimension (lấy nguồn từ datamart.cdr_dt_dim)
-- Tên bảng ClickHouse: datamart.cdr_dt_flat
-- Thực thể: Classification Dimension (lấy nguồn từ datamart.cl_dim — Atomic cl_value)
-- Tên bảng ClickHouse: datamart.cl_flat
-- Mục đích: Khai thác trực tiếp chiều ngày lịch trên ClickHouse,
--          phục vụ truy vấn lịch thị trường, lọc ngày giao dịch is_trading_date,
--          tính lookback phiên và JOIN tối ưu với các bảng Fact phẳng.
-- ============================================================


-- ============================================================
-- 1. FLAT TABLE: datamart.cdr_dt_flat
--    Nguồn dữ liệu: datamart.cdr_dt_dim
--    Grain: Day (1 row / ngày lịch, đầy đủ 365/366 ngày/năm)
--    Cờ is_trading_date: 'Y' nếu là ngày mở cửa giao dịch thị trường CK, 'N' nếu không — rule BA 2026-10-09: ngày phải có bản ghi
--    ở CẢ Market Index Snapshot (JAD_MARKETINFOR) VÀ Security Trading Snapshot (JAD_STOCKINFOR); logic tính tại datamart.cdr_dt_dim.
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
    is_trading_date     String                  COMMENT 'Cờ Y/N — ngày giao dịch thực tế thị trường chứng khoán (có bản ghi ở cả Market Index Snapshot và Security Trading Snapshot — rule BA 2026-10-09)'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYY(cdr_dt)
ORDER BY (cdr_dt, cdr_dt_dim_id)
COMMENT 'Bảng phẳng chiều Ngày lịch trên ClickHouse (nguồn từ datamart.cdr_dt_dim, phục vụ khai thác trực tiếp và join với các fact flat)'
;

-- ============================================================
-- 2. FLAT TABLE: datamart.cl_flat
--    Nguồn dữ liệu: datamart.cl_dim (Classification Dimension — toàn bộ Classification Value Atomic cl_value)
--    Grain: 1 row / giá trị phân loại / scheme (BK: schema_code + cl_code)
--    Mục đích: tra cứu mã → tên (cl_nm, cl_nm_english) trực tiếp trên ClickHouse, JOIN với các bảng Fact phẳng
--             qua (schema_code, cl_code) hoặc qua FK *_cl_dim_id = cl_dim_id.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.cl_flat ON CLUSTER 'my_cluster'
(
    cl_dim_id           String              COMMENT 'PK — Surrogate Key từ datamart.cl_dim',
    schema_code         String              COMMENT 'NK — Mã scheme phân loại; BK: (schema_code, cl_code)',
    schema_nm           Nullable(String)    COMMENT 'Tên scheme phân loại',
    cl_code             String              COMMENT 'NK — Mã giá trị phân loại; BK: (schema_code, cl_code)',
    cl_nm               Nullable(String)    COMMENT 'Tên giá trị phân loại',
    cl_nm_english       Nullable(String)    COMMENT 'Tên giá trị phân loại (tiếng Anh)',
    cl_description      Nullable(String)    COMMENT 'Diễn giải chi tiết ý nghĩa giá trị phân loại',
    src_stm_code        String              COMMENT 'Mã hệ thống nguồn — từ datamart.cl_dim'
)
ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (schema_code, cl_code)
COMMENT 'Bảng phẳng Classification Value trên ClickHouse (nguồn từ datamart.cl_dim, phục vụ tra cứu mã → tên và join với các fact flat)'
;
