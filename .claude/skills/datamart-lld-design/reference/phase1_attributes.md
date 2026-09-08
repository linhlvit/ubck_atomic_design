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

### Quy trình partial — thêm cột mới vào bảng đã có (dùng chung nhiều module)

> **Nguyên tắc cốt lõi — bắt buộc:** Bảng `partial` là 1 bảng vật lý DUY NHẤT được module gốc sở hữu và các module khác reuse. Cột mới phát sinh khi mở rộng bảng đó (dù module nào yêu cầu) phải được thêm **trực tiếp vào đúng file Attributes gốc của module sở hữu** (`Datamart/lld/{MODULE_SỞ_HỮU}/DTM_{MODULE_SỞ_HỮU}_{datamart_table}_{src}.csv`) — **KHÔNG** tạo file `_delta.csv` hay bất kỳ file Attributes nào riêng trong thư mục của module đang reuse (`Datamart/lld/{MODULE_REUSE}/`). Module sở hữu xác định qua field `module` (không phải `modules_using`) trong entry `datamart_model.yaml` tương ứng.
>
> **Lý do (bài học module NDTNN, 2026-07-24):** Khi NDTNN cần mở rộng `Public Company Dimension` (bảng gốc thuộc module GSDC), lần đầu đã tạo `Datamart/lld/NDTNN/DTM_NDTNN_public_company_dim_..._delta.csv` — sai vì file này ngụ ý các cột đó do NDTNN yêu cầu/sở hữu, trong khi phần lớn là mở rộng coverage chung áp dụng cho mọi module dùng bảng. Gây nhầm lẫn về nguồn gốc/quyền sở hữu cột khi audit sau này, và tạo file rác nằm sai vị trí. Phải dọn lại: merge nội dung vào đúng file gốc `Datamart/lld/GSDC/DTM_GSDC_public_company_dim_....csv`, xóa file trong thư mục NDTNN.

Khi `reuse_status = partial`:
1. Đọc master `datamart_attributes.csv` — lấy tất cả cột hiện tại của `datamart_table` đó
2. Tra `datamart_model.yaml` xác định `module` sở hữu gốc (không phải module đang thiết kế)
3. So sánh cột hiện có (master) với cột cần thiết kế cho nguồn mới
4. Nếu có cột mới (delta) → **báo cáo human**:

```
Bảng [datamart_table] hiện có X cột, sở hữu bởi module [MODULE_SỞ_HỮU] (file: Datamart/lld/[MODULE_SỞ_HỮU]/DTM_..._[datamart_table]_[src cũ].csv).
Module [MODULE_ĐANG_THIẾT_KẾ] cần thêm Y cột: [col_a, col_b, ...].

Đề xuất:
  - Sửa TRỰC TIẾP vào file gốc DTM_[MODULE_SỞ_HỮU]_..._[src cũ].csv để thêm Y cột (append vào cuối, không tạo file mới)
  - KHÔNG tạo file DTM_[MODULE_ĐANG_THIẾT_KẾ]_..._delta.csv trong thư mục module đang thiết kế

→ Xin phê duyệt trước khi tiến hành
```

5. Sau human approve → sửa trực tiếp file gốc của module sở hữu, **mọi cột phải nằm chung 1 file** (không có file nào thiếu cột so với schema bảng, không tách file theo module yêu cầu)
6. Ngoại lệ duy nhất được tạo file riêng trong thư mục module đang thiết kế: khi nguồn dữ liệu (`src_stm_code`) thực sự khác nguồn cũ — lúc đó là multi-source thật (xem quy tắc multi-source ở Bước 1b SKILL.md), không phải trường hợp cùng nguồn Atomic chỉ thêm cột.

### Merge vào master datamart_attributes.csv

Sau khi human approve từng file:
```
"Merge file [tên file] vào datamart_attributes.csv không?"
```

- Nếu đồng ý → check trùng `(datamart_table, datamart_column)` trước khi append
- Nếu trùng → bỏ qua dòng đó (không ghi đè)
- Chỉ append rows mới (chưa có trong master)

### Quy trình Deprecation / Dọn dẹp đồng bộ khi loại bỏ Fact hoặc Dim Draft (All-Tier Cleanup Protocol)

> **BÀI HỌC THỰC TẾ & NGUYÊN TẮC BẮT BUỘC:** Khi một bảng Fact hoặc Dim draft sau khi tạo ra mà quá trình cập nhật thiết kế (hoặc BA tinh gọn) xác định **không còn cần nữa** (bị hủy bỏ, thay thế, hoặc sáp nhập vào bảng khác):
> Tuyệt đối **KHÔNG ĐƯỢC** chỉ sửa SQL script ở `Datamart/flat-table/` mà bỏ quên thư mục `Datamart/lld/`!
> Tình trạng `flat-table` đã loại bỏ bảng nhưng `Datamart/lld/` vẫn còn lưu file detail, master `datamart_attributes.csv` vẫn còn dòng rác, và `datamart_model.yaml` vẫn còn entity mồ côi (orphaned artifacts) là **VI PHẠM TÍNH TOÀN VẸN CỦA DESIGN SYSTEM**.

Khi quyết định loại bỏ hoặc thay thế một bảng Datamart draft, Claude **BẮT BUỘC** thực hiện đồng bộ 5 bước sau:
1. **Xóa file LLD detail:** Xóa file `Datamart/lld/{MODULE}/DTM_{MODULE}_{datamart_table}.csv` (và các file biến thể multi-source nếu có).
2. **Dọn sạch master `datamart_attributes.csv`:** Tìm và xóa TOÀN BỘ các dòng có `datamart_table == {datamart_table}` trong file master `Datamart/lld/datamart_attributes.csv`.
3. **Cập nhật `DTM_{MODULE}_Detail_Mapping.csv`:** Rà soát các KPI từng map vào bảng bị loại bỏ:
   - Nếu sáp nhập sang bảng khác: đổi `mart_table` và `mart_column` sang bảng mới.
   - Nếu không còn bảng đáp ứng: chuyển KPI sang `PENDING`, xóa giá trị `mart_table` và `mart_column`, cập nhật `ghi_chu` nêu rõ lý do.
4. **Xóa khỏi `Datamart/datamart_model.yaml`:** Xóa triệt để block entity `- id: "DTM-{datamart_table}"` khỏi file registry.
5. **Đồng bộ HLD & Flat Table SQL:** Cập nhật `DTM_{MODULE}_HLD.md` (Section 4 Reuse Analysis ghi rõ trạng thái `deprecated/removed`, giải thích lý do) và đảm bảo `01_create_*_flat_tables.sql` + `02_populate_*_flat_tables.sql` không còn DDL/INSERT của bảng đó.

---

## NGUYÊN TẮC CỨNG: TUYỆT ĐỐI CẤM SỬA ATOMIC TỪ SKILL DATAMART

> 🔴 **CẤM TUYỆT ĐỐI:** Mọi skill thiết kế Datamart (`datamart-hld-design`, `datamart-lld-design`, `datamart-review`) chỉ có quyền **READ-ONLY** đối với thư mục `DataModel/Atomic/` và `DataModel/working/Atomic/`.
> - Tuyệt đối **KHÔNG ĐƯỢC** tạo file mới, sửa đổi thuộc tính, thêm cột kỹ thuật, hoặc can thiệp vào bất kỳ file YAML nào trong `DataModel/`.
> - Nếu Atomic thiếu bảng, thiếu cột, hoặc thiếu audit field cần thiết cho Datamart:
>   - Đánh dấu KPI liên quan là **PENDING** (ghi rõ lý do: "Thiếu nguồn Atomic / Chưa có trong Atomic schema").
>   - Ghi nhận vào Section 5 Open Issues (`DTM_{MODULE}_HLD.md`).
>   - DỪNG lại báo cáo human để Data Modeler thuộc luồng Atomic xử lý độc lập. Tuyệt đối không tự ý "tiện tay" sửa Atomic!

> ⛔ **QUY TẮC BẮT BUỘC: LOẠI BỎ CHỈ TIÊU DELETE TỪ BA MAPPING:**
> Mọi chỉ tiêu trong file BA (`BRD/BA/BA_analyst_{MODULE}.csv`) có `Trạng thái mapping` là **`Delete`** (hoặc `DELETE`, `Xóa`, `Xoá`, `DELETED`):
> - **TUYỆT ĐỐI KHÔNG ĐƯỢC ĐƯA VÀO THIẾT KẾ ATTRIBUTES** (không tạo cột trong file Attributes CSV, không tạo Fact/Dim/Operational table phục vụ riêng cho chỉ tiêu Delete).
> - Đây là các yêu cầu đã bị hủy bỏ bởi BA/nghiệp vụ, phải loại trừ hoàn toàn khỏi mọi bảng dữ liệu Datamart.

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

> **Đổi quy ước 2026-07-21:** `NK` và `BK` đã gộp thành **1 token `BK`** dùng chung cho cả Dimension
> và Operational (trước đây tách riêng NK=Dimension / BK=Operational, gây nhầm lẫn description ghi
> "BK" nhưng `key` ghi "NK"). Ý nghĩa join-anchor của NK cũ vẫn giữ nguyên, ghi trong `description`.
> Xem chi tiết [`examples/key_constraints.md`](../examples/key_constraints.md).

> **Đổi quy ước 2026-08-03:** `key` trên Fact chỉ ghi token thuần **`FK`** (không còn `FK → <Dim>`).
> Tên Dimension đích chuyển hoàn toàn vào `description`. Áp dụng cho thiết kế mới; module cũ dùng
> `FK -> <Dim>` chưa hồi tố. Xem chi tiết [`examples/key_constraints.md`](../examples/key_constraints.md).

| key | Chỉ dùng trên | Không dùng trên |
|---|---|---|
| `PK` | Dimension, Operational | Fact |
| `BK` | Dimension, Operational | Fact |
| `FK` | Fact | Dimension, Operational |
| `DD` | Fact | — |
| (trống) | Mọi loại | — |

> **Operational:** trường `_code` đóng vai trò PK (`key = PK`) — không tạo surrogate key `_id` riêng khi `_code` đã unique.
> **Dimension:** bắt buộc ít nhất 1 `BK` mỗi Dimension — đây là join anchor để Fact lookup vào Dimension qua business code (không qua Atomic surrogate Id).

❌ `nullable = true` cho PK / BK / FK.
❌ `data_domain = Classification Value` mà `key` không trống.
❌ `data_domain = Surrogate Dimension Key` mà `key` không phải `FK`.
❌ `data_domain = Surrogate Key` trên Fact table — Fact **không có `key = PK`** dù có cột surrogate id kỹ thuật cho ETL merge/upsert (cột đó để `key` trống).
❌ `key = FK → <bất kỳ tên Dimension/scheme>` — `key` chỉ ghi token thuần `FK`, tên Dimension đích và scheme (nếu có) ghi trong `description`, không nhồi vào `key`.
❌ `key = DD` trên Operational — DD chỉ hợp lệ trên Fact. Branch key của pivot trên Operational dùng `key` trống.
❌ `key = BK` mà `etl_logic`/`etl_logic_type` để trống — BK là business key thật (map từ Atomic), không phải surrogate generated; chỉ `PK` mới hợp lệ để trống (`source_entity = Generated`). Xem Vi phạm 5 trong `key_constraints.md`.
❌ `description` dùng chữ khác với token `key` thực tế của chính dòng đó (VD: `key="BK"` nhưng description viết "NK — ...", hoặc ngược lại) — nhất quán 1 token duy nhất.

---

## Trường kỹ thuật mặc định cho bảng SCD4A (Dimension và Operational)

> **BẮT BUỘC:** Trong kiến trúc Lakehouse Datamart của UBCKNN, các bảng Dimension và Operational (tác nghiệp) tuân theo mô hình **SCD4A** (Slowly Changing Dimension Type 4A). Bảng lưu trạng thái hiện hành (current-state) và có companion snapshot history theo kỳ.
> Mọi bảng Dimension và Operational thuộc pattern SCD4A **BẮT BUỘC PHẢI KHAI BÁO ĐẦY ĐỦ** các trường kỹ thuật mặc định dưới đây trong file Attributes LLD (`DTM_{MODULE}_{mart_table}_{src_stm_code}.csv`):

### Bộ 5 trường kỹ thuật SCD4A chuẩn:

| datamart_column | data_domain | data_type | nullable | key | description | etl_logic | etl_logic_type | source_entity |
|---|---|---|---|---|---|---|---|---|
| `ds_rcrd_st` | `Classification Value` | `string` | `false` | (trống) | Trạng thái bản ghi ('ACTIVE' = Active, 'INACTIVE' = Deleted) — audit field SCD4A | `'ACTIVE'` | `direct` | `Generated` |
| `ds_rcrd_isrt_dt` | `Date` | `date` | `false` | (trống) | Ngày insert bản ghi lần đầu — audit field SCD4A | `:etl_date` | `direct` | `Generated` |
| `ds_rcrd_udt_dt` | `Date` | `date` | `false` | (trống) | Ngày update bản ghi gần nhất — audit field SCD4A | `:etl_date` | `direct` | `Generated` |
| `ds_etl_pcs_tms` | `Timestamp` | `timestamp` | `false` | (trống) | Timestamp xử lý ETL — audit field | `CURRENT_TIMESTAMP()` | `direct` | `Generated` |
| `ds_snpst_dt` | `Date` | `date` | `false` | (trống) | Ngày snapshot kỳ dữ liệu — **chỉ có ở bảng History** | `:etl_date` | `direct` | `Generated` |

**Quy tắc phân bổ:**
- **Bảng Active (Current-state Dimension / Operational):** Khai báo 4 trường đầu: `ds_rcrd_st`, `ds_rcrd_isrt_dt`, `ds_rcrd_udt_dt`, `ds_etl_pcs_tms`. KHÔNG có `ds_snpst_dt` vì bảng chỉ lưu trạng thái hiện hành.
- **Bảng History (Snapshot lịch sử Dimension / Operational companion):** Khai báo đủ 5 trường, bao gồm `ds_snpst_dt` + `ds_etl_pcs_tms` + `ds_rcrd_st` + `ds_rcrd_isrt_dt` + `ds_rcrd_udt_dt`.
- **Cột Atomic nguồn:** Vì đây là các trường kỹ thuật do ETL framework sinh tự động, `source_entity = Generated`, các cột `atomic_table`, `source_attribute`, `atomic_column` để trống.

---

## etl_logic_type — Bảng đầy đủ

| `etl_logic_type` | Khi nào dùng | `etl_logic` format |
|---|---|---|
| `direct` | Map thẳng 1 Atomic col **có trong driving table** | `atomic_table.atomic_column` |
| `computed` | Arithmetic từ nhiều Atomic cols | `atomic_table.col_a * atomic_table.col_b` |
| `lookup_date` | FK → Calendar Date Dimension | `LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt = atomic_table.date_col` |
| `lookup_dim` | FK → SCD4A Dimension qua BK (current state, không dùng date range) | `LOOKUP dim ON dim.bk_col = driving.bk_col` |
| `join_atomic` | Cột từ Atomic table **khác** driving table | `JOIN atomic_b ON atomic_b.fk_col = driving.join_col → atomic_b.target_col` |
| `pivot` | ETL fanout 1 row thành nhiều rows theo branch key | Xem mục Pivot bên dưới |
| `pending` | Chưa có Atomic source | *(để trống)* |

### Phân định Role-Playing Date FK vs Degenerate Date Attribute

| Tiêu chí | Role-Playing Date FK | Degenerate Date Attribute |
|---|---|---|
| **Mục đích** | Trục thời gian phân tích chính (snapshot, giao dịch, sự kiện) | Thuộc tính ngày mô tả nghiệp vụ (pass-through) |
| **Data Domain** | `Surrogate Dimension Key` | `Date` hoặc `Timestamp` |
| **Data Type** | `string` | `date` hoặc `timestamp` |
| **Key** | `FK` | Trống (`""`) — CẤM `FK`, `BK`, `DD` |
| **etl_logic_type** | `lookup_date` | `direct` hoặc `join_atomic` — CẤM `lookup_date` |
| **etl_logic** | `LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt = ...` | `atomic_table.date_column` |
| **Hậu tố tên** | `_dt_dim_id` (VD: `snpst_dt_dim_id`, `trade_dt_dim_id`) | `_dt` (VD: `violation_record_dt`, `birth_dt`) |
| **Cấm kỵ** | Cấm dùng `cdr_dt_dim_id` / `Calendar Date Dimension Id` trên Fact | Cấm thêm `_Dimension_Id`, `_Dim_Id` |

> **Ví dụ thực tế (bài học NHNCK):** Trường `violation_record_dt` từng bị đặt nhầm thành `violation_record_dt_dim_id` (commit 742aede) — đây là Degenerate Date (ngày lập biên bản, chỉ hiển thị), KHÔNG phải trục thời gian phân tích.

**ETL runtime parameter — tên biến chuẩn:**
Mọi tham chiếu đến ngày ETL chạy (snapshot date, population date, runtime date) đều dùng **`:etl_date`** — không dùng `{etl_date}`, `{etl_snapshot_dt}`, `{etl_population_dt}`, hay tên biến tùy ý khác. Đổi quy ước 2026-08-03 (khớp cú pháp binding parameter dùng ở flat-table SQL, tránh 2 hình thức khác nhau giữa LLD và flat-table cho cùng 1 khái niệm).
Ví dụ đúng: `LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt = :etl_date`, `YEAR(:etl_date) - scr_prac.brth_yr`

❌ `etl_logic_type = framework` — không tồn tại.
❌ `etl_logic` để trống cho attribute READY không phải `key = PK` (Surrogate, `Generated`). **`BK` KHÔNG được để trống** — xem mục "Cột `key`" bên trên.
❌ `etl_logic_type = direct` mà `etl_logic` bắt đầu bằng `=`.
❌ `join_atomic` tham chiếu Dimension entity — phải là Atomic entity.

**Decision rule `direct` vs `join_atomic`:**
- Cột có sẵn trong driving Atomic table → `direct`
- Cột trong Atomic table khác, phải join → `join_atomic`
- Test: nếu `etl_logic` dạng self-join → sai, đổi về `direct`

**Lưu ý quan trọng — `computed` từ bảng khác driving:**
Nếu logic tính toán (`computed`) sử dụng cột từ bảng **khác** driving table (kể cả dạng `EXISTS`, `CASE WHEN`, aggregate có điều kiện) → phải dùng `join_atomic`, không phải `computed`. `computed` chỉ dùng khi tất cả input đều từ driving table.

| Logic | atomic_table | etl_logic_type đúng |
|---|---|---|
| `YEAR({etl_date}) - scr_prac.brth_yr` | `scr_prac` (= driving) | `computed` |
| `EXISTS (SELECT 1 FROM scr_prac_license_ctf_doc WHERE ...)` | `scr_prac_license_ctf_doc` (≠ driving) | `join_atomic` |
| `CASE WHEN scr_prac_license_ap.ap_tp_code IN (...) THEN ...` | `scr_prac_license_ap` (≠ driving) | `join_atomic` |

**Quy tắc bắt buộc `table_name.column_name`:** Mọi column reference trong `etl_logic` phải có đủ prefix.
Ngoại lệ không cần prefix: literal values, SQL functions (`YEAR(...)`, `COUNT(...)`), ETL runtime parameter (`{etl_date}`), keyword `NULL`.

**Quy tắc bắt buộc thứ tự JOIN clause trước, giá trị sau `→` (bài học module TT, 2026-07-21):**
Khi `etl_logic_type ∈ {join_atomic, lookup_dim, lookup_date}` và có JOIN clause, `etl_logic` phải viết theo đúng thứ tự:
1. JOIN clause(s) trước — theo đúng thứ tự hop nếu multi-hop
2. Dấu `→`
3. Cột giá trị cuối cùng trả về, sau `→`

```
✅ Đúng: JOIN atomic_b ON atomic_b.fk_col = driving.join_col → atomic_b.target_col
❌ Sai:  atomic_b.target_col JOIN atomic_b ON atomic_b.fk_col = driving.join_col
```

❌ Giá trị đích đặt trước JOIN clause (đọc ngược).
❌ Có JOIN nhưng không có dấu `→` phân tách JOIN clause và cột giá trị.
Xem ví dụ đầy đủ trong [`examples/etl_logic_wrong.md`](../examples/etl_logic_wrong.md) mục "SAI 8".

---

## Quy tắc bắt buộc khi JOIN bảng Atomic SCD4A trong `etl_logic`

> **NGUY CƠ SAI LỆCH DỮ LIỆU & FANOUT:** Trên tầng Atomic, các bảng thuộc `table_type: Fundamental` được vận hành theo cơ chế **SCD4A** (chứa cả bản ghi ACTIVE và INACTIVE/xóa logic). Nếu bảng có companion history (`_hstr`), dữ liệu được lưu theo từng snapshot `ds_snpst_dt`.
> Khi viết `etl_logic` trong Datamart LLD (ở cả Dimension, Fact, và Operational):

1. **JOIN bảng Atomic Fundamental (Current-state SCD4A):**
   - BẮT BUỘC phải kèm điều kiện lọc: `AND <atomic_table>.ds_rcrd_st = 'ACTIVE'` trong mệnh đề JOIN.
   - Ví dụ đúng:
     ```sql
     INNER JOIN public_company ON public_company.equity_ticker_symbol = security_trading_snapshot.symbol AND public_company.src_stm_code = 'IDS_COMPANY_PROFILES' AND public_company.ds_rcrd_st = 'ACTIVE' → public_company.public_company_nm
     ```
   - ❌ **CẤM:** JOIN bảng Atomic SCD4A mà không có `ds_rcrd_st = 'ACTIVE'`, dẫn đến việc lấy nhầm bản ghi đã bị xóa hoặc trùng lặp dữ liệu.

2. **JOIN bảng Atomic History Companion (`_hstr` hoặc Snapshot theo kỳ):**
   - BẮT BUỘC phải so khớp chính xác ngày snapshot và trạng thái:
     `AND <hstr_table>.ds_snpst_dt = :etl_date AND <hstr_table>.ds_rcrd_st = 'ACTIVE'` (hoặc so khớp với trường ngày của driving table, ví dụ `trading_dt`).
   - Ví dụ đúng:
     ```sql
     INNER JOIN pc_share_statistics_hstr ON pc_share_statistics_hstr.pc_id = public_company.pc_id AND pc_share_statistics_hstr.ds_snpst_dt = security_trading_snapshot.trading_dt AND pc_share_statistics_hstr.ds_rcrd_st = 'ACTIVE' → pc_share_statistics_hstr.total_outstanding_share_quantity
     ```

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

## Ưu tiên join qua Surrogate Key trên Atomic

**Quy tắc:** Khi join giữa 2 Atomic table, **ưu tiên dùng surrogate key** (`_id`) thay vì business code (`_code`).

| Trường hợp | Join key đúng | Join key sai |
|---|---|---|
| `ip_alt_identn` ↔ `scr_prac` | `ip_alt_identn.ip_id = scr_prac.scr_prac_id` | `ip_alt_identn.ip_code = scr_prac.scr_prac_code` |
| `scr_prac_license_ctf_doc` ↔ bảng quyết định | `ON xxx_id = yyy_id` | `ON xxx_code = yyy_code` |

**Lý do:** Surrogate key là FK thực sự trong Atomic schema — quan hệ referential integrity đảm bảo đúng. Business code (`_code`) có thể bị reuse hoặc thay đổi theo thời gian. Join qua `_code` dễ gây fanout ngoài ý muốn nếu code không unique.

**Cách tra cứu join key đúng:** Mở entity YAML → đọc comment của FK attribute — thường ghi `"FK target: <table>.<column>"`. Không suy luận từ tên cột.

❌ `ip_alt_identn.ip_code = driving.scr_prac_code` — sai, dùng `ip_alt_identn.ip_id = driving.scr_prac_id`
❌ Join qua business code khi surrogate FK đã có sẵn trong driving table.

---

## Quy tắc BK trên Dimension (join anchor)

`BK` trên **Dimension** = trường ETL dùng để join từ driving table vào Dimension (vai trò trước đây gọi là "NK" — đã gộp vào `BK` từ 2026-07-21, xem `key_constraints.md`).
- Bắt buộc ít nhất 1 `BK` mỗi Dimension
- Join từ Fact sang Dimension luôn qua business code (`BK`), không qua Atomic surrogate Id
- `BK` bắt buộc có `etl_logic`/`etl_logic_type` đầy đủ (thường `direct` từ driving table) — không được để trống dù vai trò là join anchor.

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
| BK (`Calendar Date`) | `direct` | `cdr_dt.cdr_dt` |
| `Year` | `computed` | `YEAR(cdr_dt.cdr_dt)` |
| `Quarter` | `computed` | `QUARTER(cdr_dt.cdr_dt)` |
| `Month` | `computed` | `MONTH(cdr_dt.cdr_dt)` |
| `Day Of Week` | `computed` | `DAYOFWEEK(cdr_dt.cdr_dt)` |
| `Is Weekend` | `computed` | `DAYOFWEEK(cdr_dt.cdr_dt) IN (1,7)` |
| `Holiday Flag` | `direct` | `cdr_dt.hol_f` |
| `Holiday Name` | `direct` | `cdr_dt.hol_nm` |

❌ Không thiết kế `Month Name` — không có trong Atomic `cdr_dt`.

---

## Quy tắc đặt tên Date FK trên Fact Table (Role-Playing Date Dimensions)

> ⛔ **CẤM TUYỆT ĐỐI:** Fact table **KHÔNG BAO GIỜ** được đặt tên cột FK là `cdr_dt_dim_id` hay logical attribute `Calendar Date Dimension Id`.
> - `Calendar Date Dimension Id` (`cdr_dt_dim_id`) **CHỈ là Primary Key của chính bảng Dimension `cdr_dt_dim`**.
> - Trong mô hình Dimensional Modeling (Kimball), khi Fact table kết nối sang Date Dimension, các khóa ngoại đóng các **vai trò nghiệp vụ khác nhau (Role-Playing Dimensions)**.
> - Bắt buộc đặt tên theo vai trò nghiệp vụ của ngày:

| Loại Fact / Vai trò ngày | datamart_attribute (Logical) | datamart_column (Physical) | data_domain | data_type | key | description | etl_logic | etl_logic_type |
|---|---|---|---|---|---|---|---|---|
| **Fact Snapshot (kỳ snapshot)** | `Snapshot Date Dimension Id` | `snpst_dt_dim_id` | `Surrogate Dimension Key` | `string` | `FK` | FK tới Calendar Date Dimension — ngày snapshot | `LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt = driving.ds_snpst_dt` | `lookup_date` |
| **Ngày phát hành / cấp** | `Issue Date Dimension Id` | `issue_dt_dim_id` | `Surrogate Dimension Key` | `string` | `FK` | FK tới Calendar Date Dimension — ngày cấp/phát hành | `LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt = driving.issue_dt` | `lookup_date` |
| **Ngày giao dịch** | `Trade Date Dimension Id` | `trade_dt_dim_id` | `Surrogate Dimension Key` | `string` | `FK` | FK tới Calendar Date Dimension — ngày giao dịch | `LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt = driving.trading_dt` | `lookup_date` |
| **Ngày đánh giá** | `Evaluation Date Dimension Id` | `evaluation_dt_dim_id` | `Surrogate Dimension Key` | `string` | `FK` | FK tới Calendar Date Dimension — ngày đánh giá | `LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt = driving.evaluation_dt` | `lookup_date` |
| **Ngày hiệu lực** | `Effective Date Dimension Id` | `effective_dt_dim_id` | `Surrogate Dimension Key` | `string` | `FK` | FK tới Calendar Date Dimension — ngày hiệu lực | `LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt = driving.effective_dt` | `lookup_date` |
| **Ngày nộp hồ sơ / báo cáo** | `Submission Date Dimension Id` | `submission_dt_dim_id` | `Surrogate Dimension Key` | `string` | `FK` | FK tới Calendar Date Dimension — ngày nộp | `LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt = driving.submission_dt` | `lookup_date` |
| **Ngày vi phạm / quyết định** | `Decision Date Dimension Id` | `decision_dt_dim_id` | `Surrogate Dimension Key` | `string` | `FK` | FK tới Calendar Date Dimension — ngày quyết định | `LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt = driving.decision_dt` | `lookup_date` |
| **Ngày sự kiện** | `Event Date Dimension Id` | `evnt_dt_dim_id` | `Surrogate Dimension Key` | `string` | `FK` | FK tới Calendar Date Dimension — ngày sự kiện | `LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt = driving.event_dt` | `lookup_date` |

> **Bài học GSDC (2026-09-08):** Bảng `fct_public_company_listing_info_snpst` từng bị reviewer Đức reject vì đặt tên cột FK ngày snapshot là `cdr_dt_dim_id`. Đã sửa thành `snpst_dt_dim_id` (Snapshot Date Dimension Id).
