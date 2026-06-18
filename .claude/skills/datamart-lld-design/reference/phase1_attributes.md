# Phase 1 — Attributes CSV Reference

## Output và Naming

### Cấu trúc thư mục

```
Datamart/lld/{MODULE}/
    DTM_{MODULE}_{mart_table}.csv                        (fact — không có src_stm_code)
    DTM_{MODULE}_{mart_table}_{src_stm_code}.csv         (dim, operational — mỗi nguồn 1 file)

Datamart/lld/datamart_attributes.csv                     (master — append sau human approve)
```

- `{MODULE}` viết HOA (ví dụ `NHNCK`)
- `{mart_table}` lấy từ cột `datamart_table` trong Entities.csv — không đặt lại
- File `DTM_{MODULE}_Attributes.csv` tổng hợp theo module **không còn tồn tại**

### Quy tắc src_stm_code cho dim và operational

`src_stm_code` xác định từ **driving table** của bảng:
1. Xác định driving table (bảng Atomic chính của grain — có PK/BK trong Attributes)
2. Tra `DataModel/Atomic/dm_manifest.yaml` → tìm entry có `physical_name` = driving table
3. Mở file YAML tương ứng → đọc attribute `Source System Code` → trích giá trị từ `classification_context`:
   - Format: `"Source System Code = 'NHNCK_VIOLATIONS'"` → value = `NHNCK_VIOLATIONS`
4. Dùng giá trị này làm suffix tên file

Ví dụ: `scr_prac_conduct_vln` → manifest → entity YAML → `classification_context = "Source System Code = 'NHNCK_VIOLATIONS'"` → file = `DTM_NHNCK_scr_prac_conduct_vln_NHNCK_VIOLATIONS.csv`

> **Nhiều source table cùng physical_name:** Đọc TẤT CẢ entry cùng `physical_name` trong manifest — mỗi entry có `classification_context` riêng → mỗi value = 1 file LLD riêng.

### Flow Phase 1 theo reuse_status

Đọc `Datamart/hld/DTM_{MODULE}_Entities.csv` → xử lý theo `reuse_status` từng bảng:

| reuse_status | Hành động |
|---|---|
| `reuse` | **Không sinh file** — ghi note: "Bảng [datamart_table] reuse từ master, không cần thiết kế mới" |
| `new` | Sinh file đầy đủ theo naming rule |
| `partial` | Sinh file đầy đủ (toàn bộ cột bảng) — xem quy trình partial bên dưới |

### Quy trình partial — thêm nguồn mới vào bảng đã có

Khi `reuse_status = partial`:
1. Đọc master `datamart_attributes.csv` — lấy tất cả cột hiện tại của `datamart_table` đó
2. So sánh cột hiện có (master) với cột cần thiết kế cho nguồn mới
3. Nếu có cột mới (delta) → **báo cáo human**:

```
Bảng [datamart_table] hiện có X cột từ nguồn [src cũ].
Nguồn mới [src mới] cần thêm Y cột: [col_a, col_b, ...].

Đề xuất:
  - Cập nhật file nguồn cũ DTM_..._[src cũ].csv để map thêm Y cột (nếu có dữ liệu từ nguồn cũ)
  - Sinh file mới DTM_..._[src mới].csv với đầy đủ X+Y cột

→ Xin phê duyệt trước khi tiến hành
```

4. Sau human approve → **mọi file nguồn của bảng này phải chứa đầy đủ số cột hiện tại** (không có file nào thiếu cột so với schema bảng)

### Merge vào master datamart_attributes.csv

Sau khi human approve từng file:
```
"Merge file [tên file] vào datamart_attributes.csv không?"
```

- Nếu đồng ý → check trùng `(datamart_table, datamart_column)` trước khi append
- Nếu trùng → bỏ qua dòng đó (không ghi đè)
- Chỉ append rows mới (chưa có trong master)

---

## Header 15 cột

```
datamart_entity, datamart_table, datamart_attribute, datamart_column,
nullable, data_domain, data_type, key, description, etl_logic,
etl_logic_type, source_entity, atomic_table, source_attribute, atomic_column
```

---

## Data Domain → Data Type

| data_domain | data_type |
|---|---|
| `Boolean` | `boolean` |
| `Classification Value` | `string` |
| `Currency Amount` | `decimal(23,2)` |
| `Date` | `date` |
| `Exchange Rate` | `decimal(12,7)` |
| `Indicator` | `string` |
| `Interest Rate` | `decimal(8,5)` |
| `Percentage` | `decimal(5,2)` |
| `Small Counter` | `int` |
| `Surrogate Key` | `string` |
| `Surrogate Dimension Key` | `string` |
| `Text` | `string` |
| `Timestamp` | `timestamp` |
| `Array<Text>` | `array<string>` |
| `Array<Struct>` | `array<struct<...>>` |

---

## Cột `key` — ràng buộc theo loại bảng

| key | Chỉ dùng trên | Không dùng trên |
|---|---|---|
| `PK` | Dimension, Operational | Fact |
| `NK` | Dimension | Fact, Operational |
| `FK → <Dim>` | Fact | Dimension, Operational |
| `DD` | Fact | — |
| (trống) | Mọi loại | — |

> **Operational:** trường `_code` đóng vai trò PK (`key = PK`) — không dùng `key = BK`, không tạo surrogate key `_id`.

❌ `nullable = true` cho PK / BK / NK / FK.
❌ `data_domain = Classification Value` mà `key` không trống.
❌ `data_domain = Surrogate Dimension Key` mà `key` không phải `FK → <Dim>`.
❌ `data_domain = Surrogate Key` trên Fact table.
❌ `key = FK → Classification Dimension (scheme: X)` — không hợp lệ ở bất kỳ đâu.
❌ `key = DD` trên Operational — DD chỉ hợp lệ trên Fact. Branch key của pivot trên Operational dùng `key` trống.

---

## etl_logic_type — Bảng đầy đủ

| `etl_logic_type` | Khi nào dùng | `etl_logic` format |
|---|---|---|
| `direct` | Map thẳng 1 Atomic col **có trong driving table** | `atomic_table.atomic_column` |
| `computed` | Arithmetic từ nhiều Atomic cols | `atomic_table.col_a * atomic_table.col_b` |
| `lookup_date` | FK → Calendar Date Dimension | `LOOKUP cdr_dt_dim ON cdr_dt_dim.dt = atomic_table.date_col` |
| `lookup_dim` | FK → SCD2 Dimension qua NK + date range | `LOOKUP dim ON dim.nk_col = driving.bk_col AND driving.rpt_dt BETWEEN dim.eff_dt AND dim.expiry_dt` |
| `join_atomic` | Cột từ Atomic table **khác** driving table | `JOIN atomic_b ON atomic_b.fk_col = driving.join_col → atomic_b.target_col` |
| `pivot` | ETL fanout 1 row thành nhiều rows theo branch key | Xem mục Pivot bên dưới |
| `pending` | Chưa có Atomic source | *(để trống)* |

❌ `etl_logic_type = framework` — không tồn tại.
❌ `etl_logic` để trống cho attribute READY không phải PK/NK/BK.
❌ `etl_logic_type = direct` mà `etl_logic` bắt đầu bằng `=`.
❌ `join_atomic` tham chiếu Dimension entity — phải là Atomic entity.

**Decision rule `direct` vs `join_atomic`:**
- Cột có sẵn trong driving Atomic table → `direct`
- Cột trong Atomic table khác, phải join → `join_atomic`
- Test: nếu `etl_logic` dạng self-join → sai, đổi về `direct`

**Quy tắc bắt buộc `table_name.column_name`:** Mọi column reference trong `etl_logic` phải có đủ prefix.
Ngoại lệ không cần prefix: literal values, SQL functions (`YEAR(...)`, `COUNT(...)`), ETL runtime parameter, keyword `NULL`.

---

## INNER JOIN vs LEFT JOIN

| Điều kiện join | Loại join |
|---|---|
| Join vào `cv` (danh mục) | INNER JOIN |
| Join qua surrogate FK unique (1-1) | INNER JOIN |
| Hop 2+ trong chain, FK unique | INNER JOIN |
| Join qua `entity_id` (1-N, bảng con có thể 0 record) | LEFT JOIN |
| Join có filter `AND <condition>` thu về 1 record optional | LEFT JOIN |
| Hop đầu trong multi-hop chain là optional | LEFT JOIN |

❌ Cột từ `LEFT JOIN` phải có `nullable = true`.

---

## Quy tắc NK

`NK` = trường ETL dùng để join từ driving table vào Dimension.
- Chỉ dùng trên **Dimension** — bắt buộc ít nhất 1 NK mỗi Dimension
- Join từ Fact sang Dimension luôn qua business code (NK), không qua Atomic surrogate Id

---

## Quy tắc Pivot

Dùng khi ETL fanout 1 Atomic row thành nhiều output rows. Mọi cột tham gia pivot dùng `etl_logic_type = pivot`.

```
-- Cột branch key:
'PUBLIC' UNION ALL 'PRIVATE' UNION ALL 'ESOP' UNION ALL 'OTHER'

-- Cột value:
tbl.plan_shareholder_qty -- PUBLIC
UNION ALL tbl.plan_single_qty -- PRIVATE
UNION ALL tbl.plan_esop_qty -- ESOP
UNION ALL tbl.planned_qty - (tbl.plan_shareholder_qty + tbl.plan_single_qty + tbl.plan_esop_qty) -- OTHER
```

❌ Số branch và thứ tự phải đồng nhất giữa branch-key col và mọi value col.
❌ Branch `NULL` phải ghi rõ `NULL -- BRANCH_NAME`.
❌ Branch residual (`OTHER`) phải flatten hoàn toàn xuống Atomic — không tham chiếu mart col khác.

`source_attribute` và `atomic_column` của pivot col dùng ` / ` liệt kê tất cả Atomic cols tham gia.

---

## Multi-hop Join Chain

```
JOIN <table_b> ON <table_b>.<fk> = <driving>.<col>
→ JOIN <table_c> ON <table_c>.<fk> = <table_b>.<col>
→ <table_c>.<target_col>
```

`source_entity` / `atomic_table` / `source_attribute` / `atomic_column` phản ánh bảng **cuối cùng** trong chain.

---

## Quy tắc mapping Atomic

**`source_entity = Generated`** — chỉ dùng cho Surrogate Key (PK Dimension/Operational) và Surrogate Dimension Key (FK Fact).

**Multi-source** — dùng separator ` / `:

| Loại | source_entity | atomic_table | source_attribute | atomic_column |
|---|---|---|---|---|
| 1 entity | Atomic entity | atomic_table | Atomic attribute | atomic_column |
| Nhiều cols cùng bảng | Atomic entity | atomic_table | `AttrA / AttrB` | `col_a / col_b` |
| 2 entity khác bảng | `EntityA / EntityB` | `table_a / table_b` | `EntityA.AttrA / EntityB.AttrB` | `table_a.col_a / table_b.col_b` |

**Classification Value (`cv`):**

| Datamart attribute | source_entity | atomic_table | source_attribute | atomic_column |
|---|---|---|---|---|
| `<X> Code` | `Classification Value` | `cv` | `Classification Code` | `cl_code` |
| `<X> Name` | `Classification Value` | `cv` | `Classification Name` | `cl_nm` |

`description` ghi rõ scheme: `<Tên nghiệp vụ> — Classification Value (scheme: <SCHEME_CODE>)`.

❌ `source_entity = Classification Value` mà `atomic_table ≠ cv`.
❌ `source_entity = Generated` cho `<X> Name` khi danh mục có scheme trong `cv`.

**FK lookup_dim/lookup_date:** `source_entity / atomic_table / source_attribute / atomic_column` phản ánh join key của driving table.

**Bảng Tác nghiệp:**
- Business Key (`_code`) → `key = PK` — đây là PK duy nhất của bảng operational
- Không tạo surrogate key (`_id`) cho bảng operational
- `source_entity` phải là Atomic entity — không phải Dimension entity

**Operational table có ≥2 BK từ 2 entity:**
- Driving = entity con (entity định nghĩa grain của bảng)
- Cột từ entity cha: lấy `direct` từ FK có sẵn trong entity con — không LEFT JOIN ngược

---

## Calendar Date Dimension — quy tắc mapping

| Attribute | etl_logic_type | etl_logic |
|---|---|---|
| PK (`cdr_dt_dim_id`) | `direct` | `cdr_dt.cdr_dt_id` |
| NK (`Calendar Date`) | `direct` | `cdr_dt.cdr_dt` |
| `Year` | `computed` | `YEAR(cdr_dt.cdr_dt)` |
| `Quarter` | `computed` | `QUARTER(cdr_dt.cdr_dt)` |
| `Month` | `computed` | `MONTH(cdr_dt.cdr_dt)` |
| `Day Of Week` | `computed` | `DAYOFWEEK(cdr_dt.cdr_dt)` |
| `Is Weekend` | `computed` | `DAYOFWEEK(cdr_dt.cdr_dt) IN (1,7)` |
| `Holiday Flag` | `direct` | `cdr_dt.hol_f` |
| `Holiday Name` | `direct` | `cdr_dt.hol_nm` |

❌ Không thiết kế `Month Name` — không có trong Atomic `cdr_dt`.
