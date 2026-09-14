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

**Đồng bộ tuyệt đối LLD ↔ Flat Table (Tránh Orphan Draft Artifacts):**
- Danh sách bảng fact và operational sinh flat table PHẢI khớp 100% với danh sách bảng fact/operational trong `Datamart/lld/{MODULE}/` và `datamart_model.yaml`.
- Nếu có bảng fact draft nào từng được tạo ở LLD nhưng quá trình cập nhật thiết kế xác định **không cần nữa** (bị hủy bỏ hoặc sáp nhập, không tạo flat table), BẮT BUỘC phải thực hiện ngay **All-Tier Cleanup Protocol**:
  1. Xóa file detail `Datamart/lld/{MODULE}/DTM_{MODULE}_{table}.csv`.
  2. Xóa các dòng của bảng đó khỏi master `Datamart/lld/datamart_attributes.csv`.
  3. Cập nhật lại `DTM_{MODULE}_Detail_Mapping.csv` (re-map hoặc chuyển PENDING).
  4. Xóa block entity khỏi `Datamart/datamart_model.yaml`.
  5. Tuyệt đối không để xảy ra tình trạng flat-table đã bỏ bảng mà LLD vẫn còn lưu file draft mồ côi!


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
- Các trường kỹ thuật audit SCD4A (`ds_rcrd_st`, `ds_rcrd_isrt_dt`, `ds_rcrd_udt_dt`, `ds_etl_pcs_tms`, `ds_snpst_dt`) — flat table phục vụ BI trực tiếp, không đưa các trường audit kỹ thuật của dim vào flat table.

**Điều kiện lọc SCD4A khi JOIN Dimension:**
- Khi viết câu lệnh `POPULATE` (file 02), nếu Dimension là bảng SCD4A, bắt buộc phải có điều kiện `AND dim_alias.ds_rcrd_st = 'ACTIVE'` trong mệnh đề JOIN để chỉ đưa dữ liệu đang hoạt động vào flat table.

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

---

## Quy trình đồng bộ khép kín LLD ↔ Flat Table (Closed-Loop Synchronization Workflow)

Flat Table là lớp denormalized tối ưu hóa cho truy vấn phân tích và BI trực tiếp. Cấu trúc bảng Flat Table phụ thuộc 100% vào các cột của bảng Fact/Operational và các trường nghiệp vụ mở rộng từ Dimension liên kết qua Foreign Keys.

Mọi sự thay đổi về schema, logic tính toán, hoặc danh mục bảng tại tầng LLD (Attributes, Detail Mapping) đều tác động trực tiếp đến mã DDL và DML của Flat Table. Do đó, quy trình thiết kế và duy trì Flat Table phải tuân thủ nghiêm ngặt mô hình **Closed-Loop Synchronization 3 Pha**:

```
[Thay đổi thiết kế: Thêm/Sửa Cột, Bảng, Formula, Grain]
                      │
                      ▼
[PHA 1: LLD Attributes & Detail Mapping Update]
  - Cập nhật DTM_{MODULE}_{table}.csv (Attributes module)
  - Cập nhật DTM_{MODULE}_Detail_Mapping.csv (Detail Mapping)
  - Đồng bộ master Datamart/lld/datamart_attributes.csv
  - Cập nhật Datamart/datamart_model.yaml
                      │
                      ▼
[PHA 2: Flat Table DDL / DML Synchronization]
  - 01_create_{module}_flat_tables.sql (DDL: thêm/sửa cột + kiểu dữ liệu ClickHouse + COMMENT)
  - 02_populate_{module}_flat_tables.sql (DML: thêm/sửa SELECT projection + JOIN + WHERE :etl_date)
  - flat_table_mapping.md (Cập nhật ánh xạ bảng, FKs, KPI groups)
                      │
                      ▼
[PHA 3: Reviewer Quality Gate Review & Verification]
  - Check Parity: Attributes module == Master datamart_attributes.csv (check_parity.py --strict)
  - Check Orphan: 3-Way Tier A (LLD) == Tier B (HLD) == Tier C (Flat Table) (check_orphan.py --strict)
  - Check Detail Mapping Linter: Không vi phạm REUSE / PENDING / DERIVED / DEPRECATED
  - Check Column Sync & Alignment: Khớp 100% cột Fact/Dim và 1-1 Projection giữa DDL và DML
```

---

## Ma trận 4 Trigger và Hành động đồng bộ (Sync Triggers & Actions Matrix)

Khi có bất kỳ thay đổi nào trong quá trình thiết kế hoặc tinh chỉnh LLD, Data Modeler / Designer bắt buộc đối chiếu theo 4 Trigger dưới đây để thực hiện đồng bộ đầy đủ:

| # | Trigger Thay Đổi | Hành động tại LLD Detail Mapping & Attributes | Hành động tại Flat Table DDL (`01_create_*.sql`) | Hành động tại Flat Table DML (`02_populate_*.sql`) | Cập nhật Tài liệu & Registry |
|---|---|---|---|---|---|
| **1** | **Thêm cột mới vào Fact/Dim**<br>*(VD: Bổ sung `total_matched_vol` vào Fact hoặc `free_float_share_quantity` vào Dimension)* | 1. Thêm dòng thuộc tính vào `DTM_{MODULE}_{table}.csv`.<br>2. Đồng bộ ngay dòng mới vào master `Datamart/lld/datamart_attributes.csv`.<br>3. Cập nhật `columns` trong `datamart_model.yaml`.<br>4. Cập nhật `logic` hoặc thêm dòng mapping trong `DTM_{MODULE}_Detail_Mapping.csv`. | Bổ sung khai báo cột tương ứng trong khối `CREATE TABLE datamart.{module}_{table}_flat`: đặt đúng kiểu ClickHouse (`Nullable(...)`), vị trí nhóm cột (Fact hoặc Dim tương ứng), kèm `COMMENT` rõ nguồn gốc. | Bổ sung tên cột vào danh sách chiếu `SELECT` của câu lệnh `INSERT INTO`: dùng đúng alias nguồn (`f.new_col` nếu từ Fact, `dim_alias.new_col` nếu từ Dimension). | Cập nhật mục mô tả bảng và danh sách cột trong `Datamart/flat-table/flat_table_mapping.md`. |
| **2** | **Sửa công thức / Thay thế cột**<br>*(VD: Đổi tên cột từ `total_vol` → `total_matched_vol`, hoặc sửa biểu thức aggregate)* | 1. Cập nhật `mart_column` và biểu thức `logic` trong Detail Mapping.<br>2. Đổi tên `datamart_column` / sửa `etl_logic` trong file Attributes module.<br>3. Đồng bộ ngay sang master `datamart_attributes.csv`.<br>4. Cập nhật `datamart_model.yaml`. | Sửa tên cột cũ thành tên cột mới trong định nghĩa `CREATE TABLE` (giữ nguyên kiểu dữ liệu ClickHouse hoặc cập nhật nếu thay đổi). | Sửa tên cột hoặc biểu thức projection trong mệnh đề `SELECT` của câu lệnh `INSERT INTO ... SELECT`. | Ghi chú log thay đổi vào header của cả 2 file SQL (`-- Sửa YYYY-MM-DD: [Lý do thay đổi]`) và cập nhật `flat_table_mapping.md`. |
| **3** | **Thêm Bảng Fact / Operational mới**<br>*(VD: Tách Fact 1b `fct_index_constituent_snpst` để tránh fan-out)* | 1. Tạo file Attributes mới `DTM_{MODULE}_{table}.csv`.<br>2. Append toàn bộ thuộc tính vào master `datamart_attributes.csv`.<br>3. Đăng ký entity mới vào `Datamart/datamart_model.yaml`.<br>4. Bổ sung entity vào `DTM_{MODULE}_Entities.csv` và HLD.<br>5. Ánh xạ các KPI liên quan trong Detail Mapping. | Thêm một khối lệnh `CREATE TABLE IF NOT EXISTS datamart.{module}_{table}_flat` hoàn chỉnh với cấu trúc cột (Fact + Calendar Date + Dim JOINs), `ENGINE = ReplicatedReplacingMergeTree()`, `PARTITION BY`, `ORDER BY`. | Thêm một khối lệnh ETL hoàn chỉnh: `TRUNCATE TABLE IF EXISTS ...` (hoặc `DELETE WHERE cdr_dt = :etl_date`) kèm `INSERT INTO ... SELECT` có đầy đủ mệnh đề `JOIN cdr_dt_dim` và các dimension liên quan. | Thêm mục bảng mới vào `Datamart/flat-table/flat_table_mapping.md` (mô tả Fact, FKs, Dimension joins, KPI áp dụng). |
| **4** | **Bãi bỏ Bảng (Deprecation / Cleanup)**<br>*(VD: Bãi bỏ bảng Fact/Opr không còn sử dụng hoặc gộp bảng)* | Thực hiện nghiêm ngặt **All-Tier Cleanup Protocol** (5 bước):<br>1. Xóa file `DTM_{MODULE}_{table}.csv`.<br>2. Xóa toàn bộ dòng thuộc tính của bảng khỏi master `datamart_attributes.csv`.<br>3. Đánh dấu KPI liên quan sang `DEPRECATED` hoặc re-map sang bảng mới.<br>4. Xóa block entity khỏi `datamart_model.yaml`.<br>5. Xóa khỏi `DTM_{MODULE}_Entities.csv` và HLD Section 4. | Xóa bỏ khối lệnh `CREATE TABLE` của bảng flat tương ứng, hoặc chuyển thành khối comment ghi rõ: `-- DEPRECATED YYYY-MM-DD: [Lý do và biên bản bãi bỏ]`. | Xóa bỏ toàn bộ khối lệnh `TRUNCATE / DELETE` và `INSERT INTO ... SELECT` của bảng đã bãi bỏ. | Xóa mục bảng tương ứng khỏi `Datamart/flat-table/flat_table_mapping.md`. |

---

## Designer Pre-delivery Checklist (Kiểm tra bắt buộc trước khi bàn giao Flat Table)

Trước khi bàn giao kết quả Phase 3 cho QA/Reviewer hoặc người dùng, Designer bắt buộc phải tự đối soát 4 tiêu chí kỹ thuật cốt lõi sau:

### 1. Flat Table Column Coverage Check (Độ bao phủ cột 100%)
- **Fact / Operational Columns:** 100% cột trong file Attributes module (`DTM_{MODULE}_{table}.csv`), trừ các trường kỹ thuật audit hệ thống (`ds_batch_date`, `ds_population_timestamp`), PHẢI có mặt đầy đủ trong khối `CREATE TABLE` của file `01_create_*.sql`. Tuyệt đối không được bỏ sót cột measure hay attribute nào.
- **Dimension Joined Columns:** 100% cột giá trị nghiệp vụ của các Dimension có tham gia JOIN (theo khóa ngoại FK có trong Fact Attributes) PHẢI có mặt trong khối `CREATE TABLE`. Bỏ qua PK surrogate và `src_stm_code` của Dim, bỏ qua các trường kỹ thuật audit SCD4A (`ds_rcrd_st`, `ds_eff_start_dt`, `ds_eff_end_dt`, `ds_cdc_opr_cd`, `ds_load_ts`, `ds_snpst_dt`).
- **Calendar Date Columns:** Đảm bảo có mặt cột `cdr_dt` (hoặc các alias theo vai trò ngày: `snpst_cdr_dt`, `issue_cdr_dt`, `trade_cdr_dt`...) từ `cdr_dt_dim`.

### 2. 1-1 Projection Alignment Check (Khớp 1-1 giữa DDL và DML)
- **Số lượng cột:** Tổng số cột khai báo trong `CREATE TABLE` (`01_create_*.sql`) PHẢI bằng chính xác tổng số biểu thức cột được chiếu trong mệnh đề `SELECT` của câu lệnh `INSERT INTO` (`02_populate_*.sql`).
- **Thứ tự cột:** Thứ tự các cột trong câu lệnh `CREATE TABLE` phải khớp tuần tự 1-1 với thứ tự trong mệnh đề `SELECT`:
  1. Khối Fact / Operational columns.
  2. Khối Calendar Date columns (`snpst_cdr_dt`, ...).
  3. Khối Dimension columns theo thứ tự từng Dimension được JOIN.
- **Alias đối soát:** Tên alias trong `SELECT ... AS <col>` phải khớp chính xác với tên cột định nghĩa trong `CREATE TABLE`.

### 3. Parameter Consistency Check (Tính nhất quán của tham số ETL)
- **Chuẩn tham số ngày:** Toàn bộ các mệnh đề lọc ngày chạy ETL hàng ngày trong file `02_populate_*.sql` PHẢI sử dụng thống nhất biến tham số `:etl_date`.
  - Fact Snapshot: `WHERE snpst_cal.cdr_dt = :etl_date`
  - Fact Event: `WHERE evnt_cal.cdr_dt = :etl_date`
- **Cấm sai khác cú pháp:** Tuyệt đối không dùng `{etl_date}`, `$etl_date`, `?`, hoặc hardcode chuỗi ngày cụ thể như `'2026-09-14'`.

### 4. Column Drift Check (Chống trôi lệch cột)
- **Chống cột ma trong SQL:** Không có bất kỳ cột nào xuất hiện trong khối `CREATE TABLE` (phần Fact/Operational) mà thiếu trong file module Attributes CSV và master registry `datamart_attributes.csv`. Toàn bộ các cột mồ côi hoặc cột thừa do copy-paste từ bảng khác PHẢI BỊ XÓA BỎ.
- **Chống bỏ sót cột khai thác:** Không có bất kỳ cột Fact nào có KPI khai thác trong Detail Mapping mà bị bỏ sót khỏi Flat Table.
- **Đồng bộ Attributes trước:** Tuyệt đối không được thêm cột mới vào Flat Table SQL khi cột đó chưa được định nghĩa trong Attributes CSV và chưa đồng bộ vào master `datamart_attributes.csv`.
