# Phase 3 — Flat Table SQL Reference

## Mục đích

Sinh 2 file SQL ClickHouse tạo và populate bảng flat (denormalized) cho phân hệ. Flat table = fact/operational table join với tất cả dim liên quan, đưa toàn bộ cột vào 1 bảng phục vụ truy vấn trực tiếp.

## Input

- `Datamart/hld/DTM_{MODULE}_Entities.csv` — danh sách entity + FKs
- `Datamart/lld/DTM_{MODULE}_Attributes.csv` — tên bảng vật lý (`datamart_table`) + tên cột vật lý (`datamart_column`) + data type + key + nullable

## Output

```
Datamart/flat-table/{MODULE}/01_create_{module}_flat_tables.sql
Datamart/flat-table/{MODULE}/02_populate_{module}_flat_tables.sql
```

`{MODULE}` viết HOA trong tên thư mục (ví dụ `PTTT`); `{module}` viết thường trong tên file và tên bảng SQL (ví dụ `pttt`).

---

## Quy tắc xác định bảng flat

Chỉ sinh flat table cho bảng **`fact`** và **`operational`** — không sinh cho `dim`.

**Đếm trước khi sinh:** Báo cáo cho user: "Phân hệ {MODULE} có X fact + Y operational = Z bảng flat." Chờ xác nhận trước khi sinh file.

---

## Quy tắc đặt tên

| Loại | Pattern | Ví dụ |
|------|---------|-------|
| `fact` | `datamart.{module}_{datamart_table}_flat` | `datamart.pttt_fct_mkt_rsk_snpst_flat` |
| `operational` | `datamart.{datamart_table}_flat` | `datamart.opr_corp_bond_issuer_credit_flat` |

`{datamart_table}` lấy trực tiếp từ cột `datamart_table` trong Attributes.csv — không đặt lại.

---

## Cấu trúc cột flat table (fact)

```
-- From: FACT {ENTITY NAME}
<tất cả cột của fact> (theo thứ tự trong Attributes.csv)

-- From: CALENDAR DATE DIMENSION  (nếu fact có FK → Calendar Date)
full_date, day_of_week, day_of_week_num, week_of_year,
month_num, month_name, quarter_num, year_num, is_trading_day

-- From: {DIM ENTITY NAME}  (lặp lại cho mỗi dim FK khác Calendar Date)
<cột giá trị nghiệp vụ của dim> (bỏ PK surrogate và src_stm_code)

-- Technical metadata
ds_batch_date               Date      COMMENT 'ETL batch date'
ds_population_timestamp     DateTime  COMMENT 'Population timestamp'
```

## Cấu trúc cột flat table (operational)

```
-- From: OPERATIONAL {ENTITY NAME}
<tất cả cột của operational> (theo thứ tự trong Attributes.csv)

-- Technical metadata
ds_batch_date               Date      COMMENT 'ETL batch date'
ds_population_timestamp     DateTime  COMMENT 'Population timestamp'
```

**Operational KHÔNG join Calendar Date và KHÔNG join bất kỳ dim nào.**

---

## Xác định dim join

Đọc cột `FKs` trong Entities.csv — format: `{Dim Entity}.{FK column name}`.

Mỗi FK = 1 LEFT JOIN trong file populate. FK → Calendar Date Dimension dùng tên bảng `datamart.{module}_calendar_date_dimension`, join key `date_dimension_id = f.{fk_column}`.

## Cột lấy từ dim (ngoài Calendar Date)

Đọc Attributes.csv của bảng dim tương ứng, lấy **toàn bộ cột trừ**:
- Cột PK surrogate (`data_domain = Surrogate Key`)
- Cột `src_stm_code` (`data_domain = Classification Value`, `datamart_column = src_stm_code`)

---

## Data type mapping sang ClickHouse

| data_type trong Attributes | ClickHouse type |
|---------------------------|-----------------|
| `string` (nullable=false) | `String` |
| `string` (nullable=true) | `Nullable(String)` |
| `date` (nullable=false) | `Date` |
| `date` (nullable=true) | `Nullable(Date)` |
| `decimal(5,2)` (nullable=true) | `Nullable(Decimal(5,2))` |
| `decimal(23,2)` (nullable=true) | `Nullable(Decimal(23,2))` |
| `decimal(7,4)` (nullable=true) | `Nullable(Decimal(7,4))` |
| `decimal(7,6)` (nullable=true) | `Nullable(Decimal(7,6))` |
| `decimal(10,2)` (nullable=true) | `Nullable(Decimal(10,2))` |
| `int` (nullable=false) | `Int64` |
| `int` (nullable=true) | `Nullable(Int64)` |

Calendar Date columns cố định:

```sql
full_date           Nullable(Date)    COMMENT 'Ngày đầy đủ — từ Calendar Date Dimension',
day_of_week         Nullable(String)  COMMENT 'Thứ trong tuần',
day_of_week_num     Nullable(Int32)   COMMENT 'Số thứ tự ngày trong tuần (1=Mon)',
week_of_year        Nullable(Int32)   COMMENT 'Tuần trong năm',
month_num           Nullable(Int32)   COMMENT 'Tháng',
month_name          Nullable(String)  COMMENT 'Tên tháng',
quarter_num         Nullable(Int32)   COMMENT 'Quý',
year_num            Nullable(Int32)   COMMENT 'Năm',
is_trading_day      Nullable(UInt8)   COMMENT 'Cờ ngày giao dịch',
```

---

## ENGINE / PARTITION / ORDER BY

```sql
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(<driving_date_col>)
ORDER BY (<driving_date_col>, <grain_key>)
```

- `<driving_date_col>`: cột `date` có `key = DD` trong Attributes.csv của bảng fact/operational
- `<grain_key>`: cột BK hoặc FK dim (không phải Calendar Date FK) — nếu nhiều grain key thì liệt kê đủ

---

## Pattern file 01 — CREATE TABLE

```sql
CREATE TABLE IF NOT EXISTS datamart.{flat_table_name} ON CLUSTER 'my_cluster'
(
    -- From: FACT/OPERATIONAL {ENTITY NAME}
    col1    Type    COMMENT '...',
    ...
    -- From: CALENDAR DATE DIMENSION
    full_date   Nullable(Date)  COMMENT '...',
    ...
    -- From: {DIM ENTITY NAME}
    col_x   Nullable(String)    COMMENT '... — từ {Dim Entity Name}',
    ...
    -- Technical metadata
    ds_batch_date               Date      COMMENT 'ETL batch date',
    ds_population_timestamp     DateTime  COMMENT 'Population timestamp'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(<driving_date_col>)
ORDER BY (<driving_date_col>, <grain_key>)
COMMENT 'Flat table — {Entity Name} × {Dim1} × {Dim2}'
;
```

## Pattern file 02 — POPULATE

```sql
TRUNCATE TABLE IF EXISTS datamart.{flat_table_name} ON CLUSTER 'my_cluster';
INSERT INTO datamart.{flat_table_name}
SELECT
    f.col1,
    f.col2,
    ...
    calendar_date.full_date,
    ...
    dim_alias.col_x,
    ...
    today()  AS ds_batch_date,
    now()    AS ds_population_timestamp
FROM datamart.{source_fact_table} f
LEFT JOIN datamart.{module}_calendar_date_dimension calendar_date
    ON calendar_date.date_dimension_id = f.{snpst_dt_dim_id}
LEFT JOIN datamart.{dim_table} dim_alias
    ON dim_alias.{dim_pk} = f.{fk_col}
;
```

Operational table: chỉ `FROM datamart.{source_operational_table} o` + SELECT các cột + 2 technical metadata — không có LEFT JOIN.
