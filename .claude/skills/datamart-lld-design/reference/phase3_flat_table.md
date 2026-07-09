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
| `operational` | `datamart.{module}_{datamart_table}_flat` | `datamart.pttt_opr_corp_bond_issuer_credit_flat` |

`{datamart_table}` lấy trực tiếp từ cột `datamart_table` trong Attributes.csv — không đặt lại.

---

## Cấu trúc cột flat table (fact)

```
-- From: FACT {ENTITY NAME}
<tất cả cột của fact> (theo thứ tự trong Attributes.csv)

-- From: CALENDAR DATE DIMENSION  (nếu fact có FK → Calendar Date)
cdr_dt  -- nếu có nhiều FK date, dùng alias: snpst_cdr_dt, issu_cdr_dt, evnt_cdr_dt, ...

-- From: {DIM ENTITY NAME}  (lặp lại cho mỗi dim FK khác Calendar Date)
<cột giá trị nghiệp vụ của dim> (bỏ PK surrogate và src_stm_code)
```

**Không có technical metadata (ds_batch_date, ds_population_timestamp) trong flat table.**

## Cấu trúc cột flat table (operational)

```
-- From: OPERATIONAL {ENTITY NAME}
<tất cả cột của operational> (theo thứ tự trong Attributes.csv)
```

**Operational KHÔNG join Calendar Date và KHÔNG join bất kỳ dim nào. Không có technical metadata.**

---

## Xác định dim join

Đọc cột `FKs` trong Entities.csv — format: `{Dim Entity}.{FK column name}`.

**Quy tắc JOIN cho fact → Calendar Date Dimension:**
- FK snapshot date (`snpst_dt_dim_id`) → dùng `JOIN` (không LEFT JOIN) — đây là FK chính dùng để lọc ngày ETL
- FK date khác (VD: `issu_dt_dim_id`, `evnt_dt_dim_id`) → dùng `LEFT JOIN` — là dữ liệu lịch sử, không lọc

**Điều kiện lọc ngày (ETL daily):**
- Đặt ở mệnh đề `WHERE`, không đặt trong `ON`
- Fact Snapshot: `WHERE snpst_cal.cdr_dt = :etl_date`
- Fact Event: `WHERE evnt_cal.cdr_dt = :etl_date`
- Operational: không lọc ngày

Các FK → dim khác (không phải Calendar Date) dùng `LEFT JOIN`.

Tên bảng Calendar Date (physical): `datamart.cdr_dt_dim`, join key `cdr_dt_dim_id = f.{fk_column}`.

> **Bắt buộc dùng tên vật lý:** tên bảng và tên cột phải khớp với `datamart_table` và `datamart_column` trong `Datamart/lld/datamart_attributes.csv` — không dùng tên logical.

## Cột lấy từ dim (ngoài Calendar Date)

**Điều kiện tiên quyết:** Chỉ JOIN dim nào có FK tương ứng trong Attributes.csv của bảng fact (cột `data_domain = Surrogate Dimension Key`). Nếu FK không còn trong Attributes → không JOIN dim đó, không lấy cột từ dim đó.

Đọc Attributes.csv của bảng dim tương ứng, lấy **toàn bộ cột trừ**:
- Cột PK surrogate (`data_domain = Surrogate Key`)
- Cột `src_stm_code` (`data_domain = Classification Value`, `datamart_column = src_stm_code`)

**Bắt buộc cross-check sau khi sinh:** Mọi cột trong section `-- From: FACT/OPERATIONAL` của CREATE phải có trong Attributes.csv — không được có cột thừa. Tương tự mọi dim được JOIN phải có FK trong Attributes.csv.

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

Calendar Date — chỉ lấy cột `cdr_dt`:

```sql
-- 1 FK date:
cdr_dt              Nullable(Date)  COMMENT 'Ngày — từ Calendar Date Dimension',

-- Nhiều FK date (dùng alias theo vai trò — phải tuân thủ physical naming rule):
snpst_cdr_dt        Nullable(Date)  COMMENT 'Ngày snapshot — từ Calendar Date Dimension',
issue_cdr_dt        Nullable(Date)  COMMENT 'Ngày cấp — từ Calendar Date Dimension',
event_cdr_dt        Nullable(Date)  COMMENT 'Ngày sự kiện — từ Calendar Date Dimension',
```

---

## ENGINE / PARTITION / ORDER BY

```sql
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(<driving_date_col>))
ORDER BY (assumeNotNull(<driving_date_col>), <grain_key>)
```

- `<driving_date_col>`: cột `date` có `key = DD` trong Attributes.csv của bảng fact/operational
- `<grain_key>`: cột BK hoặc FK dim (không phải Calendar Date FK) — nếu nhiều grain key thì liệt kê đủ
- **`assumeNotNull` bắt buộc:** cột date trong flat table thường là `Nullable(Date)` (do join từ dim hoặc dữ liệu nghiệp vụ có thể NULL). ClickHouse MergeTree không cho phép `Nullable` trong `PARTITION BY` và `ORDER BY` → luôn wrap bằng `assumeNotNull(...)`. NULL sẽ được map về `1970-01-01` khi partition/sort.

---

## Pattern file 01 — CREATE TABLE

```sql
CREATE TABLE IF NOT EXISTS datamart.{flat_table_name} ON CLUSTER 'my_cluster'
(
    -- From: FACT/OPERATIONAL {ENTITY NAME}
    col1    Type    COMMENT '...',
    ...
    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt   Nullable(Date)  COMMENT '... — từ Calendar Date Dimension',
    ...
    -- From: {DIM ENTITY NAME}
    col_x   Nullable(String)    COMMENT '... — từ {Dim Entity Name}',
    ...
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(<driving_date_col>))
ORDER BY (assumeNotNull(<driving_date_col>), <grain_key>)
COMMENT 'Flat table — {Entity Name} × {Dim1} × {Dim2}'
;
```

## Pattern file 02 — POPULATE

**Fact Snapshot:**
```sql
TRUNCATE TABLE IF EXISTS datamart.{flat_table_name} ON CLUSTER 'my_cluster';
INSERT INTO datamart.{flat_table_name}
SELECT
    f.col1,
    f.col2,
    ...
    snpst_cal.cdr_dt            AS snpst_cdr_dt,
    issu_cal.cdr_dt             AS issu_cdr_dt,     -- nếu có FK date phụ
    ...
    dim_alias.col_x,
    ...
FROM datamart.{source_fact_table} f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.cdr_dt_dim issu_cal              -- FK date phụ nếu có
    ON issu_cal.cdr_dt_dim_id = f.{issu_dt_dim_id}
LEFT JOIN datamart.{dim_table} dim_alias
    ON dim_alias.{dim_pk} = f.{fk_col}
WHERE snpst_cal.cdr_dt = :etl_date
;
```

**Fact Event:**
```sql
...
JOIN datamart.cdr_dt_dim evnt_cal
    ON evnt_cal.cdr_dt_dim_id = f.evnt_dt_dim_id
...
WHERE evnt_cal.cdr_dt = :etl_date
;
```

**Operational table:** không có JOIN, không có WHERE lọc ngày.
```sql
TRUNCATE TABLE IF EXISTS datamart.{flat_table_name} ON CLUSTER 'my_cluster';
INSERT INTO datamart.{flat_table_name}
SELECT
    o.col1,
    o.col2,
    ...
FROM datamart.{source_operational_table} o
;
```
