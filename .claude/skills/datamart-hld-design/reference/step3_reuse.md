# Bước 3 — Check reuse (Datamart model) — HLD Datamart

Kiểm 4 lớp reuse, GATE xác nhận `reuse_status`, format Section 4 và giao thức bãi bỏ bảng 5 tầng.

## Mục lục

- BƯỚC 3 — CHECK REUSE (DATAMART MODEL)
  - Lớp 1 — Conformed Dimension Whitelist (không phụ thuộc source match)
  - Lớp 2 — Classification Value → cl_dim (filter theo scheme)
  - Lớp 3 — Source Match (cùng nguồn Atomic)
  - Lớp 4 — Fact/Dim Partial (thêm cột vào bảng hiện có)
  - Tổng hợp và hỏi human (GATE — bắt buộc dừng)
  - Áp dụng reuse khi thiết kế từng nhóm (Section 2)
  - Section 4 — Reuse Analysis & Quy Chuẩn Tái Sử Dụng / Bãi Bỏ Bảng

## BƯỚC 3 — CHECK REUSE (DATAMART MODEL)

**Mục tiêu:** Tối đa hóa tái sử dụng bảng đã có trong `datamart_model.yaml` trước khi đề xuất bảng mới. Thực hiện theo 4 lớp kiểm tra theo thứ tự — **dừng ngay khi đã xác định được reuse_status**, không kiểm tra lớp tiếp theo.

**Thực hiện:** Đọc toàn bộ `Datamart/datamart_model.yaml` một lần duy nhất trước khi bắt đầu phân tích — không đọc lại từng lần.

---

### Lớp 1 — Conformed Dimension Whitelist (không phụ thuộc source match)

Một số Dimension được thiết kế dùng chung toàn hệ thống. **Bất kể module nào, bất kể BA ghi nguồn gì** — nếu nhóm thông tin cần các chiều dưới đây thì **luôn reuse**, không tạo mới:

| Datamart table | Logical name | Khi nào reuse |
|---|---|---|
| `cdr_dt_dim` | Calendar Date Dimension | Mọi Fact có chiều thời gian |
| `cl_dim` | Classification Dimension | Mọi chiều phân loại có nguồn từ Classification Value (CV) Atomic — xem Lớp 2 |

> ❌ **KHÔNG tạo `Calendar Date Dimension` mới** dù không tìm thấy trong source match. Luôn reuse `cdr_dt_dim`.

---

### Lớp 2 — Classification Value → cl_dim (filter theo scheme)

**Áp dụng khi:** Nhóm thông tin cần một chiều phân loại dạng danh mục (ngành nghề, loại hình, trạng thái...) mà nguồn Atomic là `Classification Value` (bảng `cv`).

**Quy trình:**
1. Xác định scheme CV cần dùng (VD: `IDS_INDUSTRY_CATEGORY`, `CERTIFICATE_TYPE`...)
2. **Kiểm tra `ldm.physical_name` trong YAML Atomic entity nguồn:**
   - `physical_name = cv` → dữ liệu phân loại lưu trong bảng CV → **reuse `cl_dim`**
   - `physical_name ≠ cv` (entity riêng) → Atomic thiết kế entity này độc lập → **tạo Dimension riêng**, KHÔNG reuse `cl_dim`
3. Trong thiết kế reuse `cl_dim`: ghi rõ FK tên `Classification Dimension Id` + ghi chú scheme trong cột Ghi chú / Bảng grain

**Lý do quan trọng:** `cl_dim` chỉ là projection của bảng `cv` Atomic. Nếu Atomic không lưu thông tin đó trong `cv` thì `cl_dim` không có dữ liệu đó — không thể reuse.

> ❌ **KHÔNG tạo Dimension mới** khi `cl_dim` đã tồn tại và Atomic lưu dữ liệu trong `cv`.
> ❌ **KHÔNG reuse `cl_dim`** khi Atomic lưu dữ liệu trong entity riêng (`physical_name ≠ cv`) — dù tên scheme nghe có vẻ là "phân loại".

**Ví dụ đúng:**
- BA cần chiều "Ngành nghề kinh tế cấp 1" từ `IDS.categories` → tra YAML → `physical_name = cv` (scheme `IDS_INDUSTRY_CATEGORY`) → reuse `cl_dim`
- BA cần chiều "Loại CCHN" từ `NHNCK.CERTIFICATES` → tra YAML → `physical_name = sp_license_certificate_type` → tạo `sp_license_ctf_tp_dim` mới, KHÔNG reuse `cl_dim`

---

### Lớp 3 — Source Match (cùng nguồn Atomic)

**Áp dụng khi:** Bảng đích không thuộc Lớp 1 hoặc Lớp 2.

**Bước 3a — Xác định Atomic source** từ BA analyst (cột Nguồn):
- Đọc cột Nguồn tại từng nhóm thông tin → tra `dm_manifest.yaml` lấy `physical_name` (= `atomic_table` vật lý)
- Nếu BA ghi tên nguồn chung (VD: "NHNCK") → đọc tất cả entry trong manifest có `source` khớp, lấy tất cả `physical_name` liên quan

**Bước 3b — Tìm trong `datamart_model.yaml`** theo `source_atomic`:
- Duyệt qua `entities` → tìm entry có `source_atomic` chứa `physical_name` đang xét
- Không tìm thấy → `new`, chuyển sang Lớp 4 để kiểm tra Fact partial

**Bước 3c — Nếu tìm thấy** (cùng nguồn Atomic đã được dùng):
- Lấy `datamart_table` + `table_type` + số cột hiện có (`columns` list) từ model
- So sánh `table_type` + grain mục đích:

| Điều kiện | Hành xử |
|---|---|
| `table_type` khác nhau | `new` |
| `table_type` giống, grain/mục đích giống | → Lớp 4 kiểm tra partial |
| `table_type` giống, grain/mục đích khác hẳn | `new` |

---

### Lớp 4 — Fact/Dim Partial (thêm cột vào bảng hiện có)

**Áp dụng khi:** Đã tìm thấy bảng cùng loại + cùng grain từ Lớp 3, hoặc cần bổ sung measure/attribute vào Fact đã có.

**Câu hỏi kiểm tra:**
- Fact hiện có đủ các measure/FK cần thiết cho nhóm này chưa?
- Nếu thiếu measure → `partial` (thêm cột, không tạo Fact mới)
- Nếu thiếu FK đến Dimension mới → vẫn `partial` (thêm FK + Dimension)
- Nếu grain thực sự khác → `new`

**Báo cáo human khi phát hiện khả năng reuse (Lớp 3 hoặc 4):**

```
Phát hiện khả năng reuse:
  Nguồn Atomic: [atomic_table]
  Bảng đã có trong datamart_model.yaml: [datamart_table] (table_type: dim/fact/operational, N cột hiện có)
  Bảng đang thiết kế: [tên mới đề xuất]
  Grain hiện tại: [grain bảng đã có]
  Grain cần thiết: [grain nhóm này]

Đề xuất:
  (a) reuse — tái sử dụng toàn bộ [datamart_table] hiện có (không thêm cột)
  (b) partial — thêm cột/FK vào [datamart_table] hiện có
  (c) new — tạo bảng mới (grain/mục đích thực sự khác)

→ Human chọn phương án
```

---

### Tổng hợp và hỏi human (GATE — bắt buộc dừng)

Sau khi chạy qua 4 lớp cho **tất cả bảng** trong module, trình bày bảng tóm tắt:

```
Kết quả phân tích reuse (4 lớp):

| Datamart Entity | datamart_table | Lớp phát hiện | reuse_status đề xuất | Lý do |
|---|---|---|---|---|
| Calendar Date Dimension | cdr_dt_dim | L1 — Whitelist | reuse | Conformed Dim toàn hệ thống |
| Classification Dimension | cl_dim | L2 — CV scheme | reuse | scheme IDS_INDUSTRY_CATEGORY đã có trong cl_dim |
| Fact Listed Bond Snapshot | fct_lst_bnd_snpst | L3 — source match | partial | Cùng nguồn scr_trd, cần thêm cột OTC_Bond_Trading_Value |
| Fact New Fact | fct_new | L3 — source match | new | Chưa có trong master |

→ Xác nhận reuse_status từng bảng để tiến hành thiết kế?
```

> ❌ **KHÔNG được tự tiếp tục thiết kế** khi chưa có xác nhận của human — dù toàn bộ bảng đều là `new`.

**Ghi kết quả vào Section 4 HLD.md** (xem format bên dưới)

> **Lưu ý:** `datamart_model.yaml` rỗng (`entities: []`, module đầu tiên) → toàn bộ bảng là `new`, vẫn phải trình bày bảng tóm tắt và chờ human xác nhận.

---

### Áp dụng reuse khi thiết kế từng nhóm (Section 2)

**Bước kiểm tra bắt buộc TRƯỚC KHI đề xuất bảng đích cho mỗi nhóm:**

1. Chiều thời gian → Lớp 1: luôn là `cdr_dt_dim`
2. Chiều phân loại/danh mục → Lớp 2: kiểm tra CV scheme → nếu có thì `cl_dim`
3. Fact/Dim khác → Lớp 3: match source → Lớp 4: kiểm tra partial

**Trong bảng KPI (cột Ghi chú) và Bảng grain:** ghi rõ reuse_status và scheme/filter khi áp dụng Lớp 1 hoặc Lớp 2. Ví dụ:
- `Calendar Date Dimension — reuse (cdr_dt_dim)`
- `Classification Dimension — reuse cl_dim, filter scheme = 'IDS_INDUSTRY_CATEGORY'`

### Section 4 — Reuse Analysis & Quy Chuẩn Tái Sử Dụng / Bãi Bỏ Bảng

Thêm section này vào cuối file HLD, sau Section 3. Section 4 là nguồn sự thật cho Phase 2 — Entities (`Entities.csv` đọc trực tiếp từ đây):

```markdown
## Section 4 — Reuse Analysis

| Datamart Entity | datamart_table | reuse_status | Ghi chú |
|---|---|---|---|
| Calendar Date Dimension | cdr_dt_dim | reuse | Conformed Dim toàn hệ thống — không thêm nguồn mới |
| Branch Dimension | dim_branch | partial | Đã có nguồn FLEX. Module này thêm nguồn NHNCK |
| Fact ATM Transaction | fct_atm_txn | new | Chưa có trong master |
| Fact Old Draft Snapshot | fct_old_draft_snpst | DEPRECATED | Đã bãi bỏ theo biên bản thống nhất với BA ngày 2026-09-08 |
```

#### 1. Phân Định Rõ Hai Trường Hợp Reuse (Reuse Analysis Protocol)
Khi một chỉ tiêu hoặc bảng được tái sử dụng giữa các nhóm, bắt buộc phân định rạch ròi:
- **Case 1 (Physical Measure/Dim Reuse — Tái sử dụng Measure/Dim Vật Lý Đã Có):**
  + *Bản chất:* Chỉ tiêu sử dụng trực tiếp measure hoặc attribute đã được thiết kế và lưu trữ vật lý trên Fact hoặc Dimension ở nhóm trước.
  + *Hành xử:* Ghi rõ tên bảng logical (`datamart_entity`) và physical (`datamart_table`), cột đích. Bắt buộc đồng bộ vào `Entities.csv` và `datamart_model.yaml`. Trong Detail Mapping LLD bắt buộc điền đủ `mart_table` và `mart_column`.
  + *Ghi chú:* `Reuse từ Nhóm X (K_{MODULE}_Y) — measure vật lý có sẵn trên Fact/Dim <Table>`.
- **Case 2 (Presentation / Derived Reuse — Tái sử dụng Hiển Thị BI / Phái Sinh):**
  + *Bản chất:* Chỉ tiêu hiển thị lại thuần túy qua BI layer hoặc công thức phái sinh mà không có cột vật lý riêng trên Fact/Dim.
  + *Hành xử:* Trong Section 2 ghi rõ công thức tính và nguồn gốc. Không tạo cột vật lý trùng lặp trên Fact. Trong Detail Mapping LLD đánh dấu `column_role = 'DERIVED'`, **bắt buộc để trống** `mart_table` và `mart_column`.
  + *Ghi chú:* `Reuse từ Nhóm X (K_{MODULE}_Y) — tính toán tại presentation layer, không lưu cột riêng trên Fact`.

#### 2. Giao Thức Bãi Bỏ Bảng Đồng Bộ 5 Tầng (All-Tier Table Deprecation Protocol)
Khi một bảng Fact/Dim draft sau khi thiết kế được xác định **không còn cần nữa** (bị bãi bỏ, sáp nhập, hoặc chuyển thành Dimension thuần theo thống nhất với BA):
> ⛔ **CẤM TUYỆT ĐỐI:** Chỉ xóa bảng ở một tầng đơn lẻ (như xóa file Flat Table SQL mà để sót LLD hoặc HLD). Bắt buộc thực hiện đồng bộ trên cả **5 tầng kiến trúc**:
1. **Tầng 1 (LLD Chi tiết Module):** Xóa file CSV bảng trong `Datamart/lld/{MODULE}/DTM_{MODULE}_{datamart_table}.csv`.
2. **Tầng 2 (Master Registry):** `Datamart/lld/datamart_attributes.csv` — sinh lại bằng `build_registry.py` sau khi xóa file LLD; `--allow-drop` chỉ khi human đã duyệt và danh sách "không còn file LLD per-module" của `--check` chỉ gồm bảng đang bỏ (`--allow-drop` xóa mọi bảng mồ côi cùng lúc). Không xóa dòng trong master bằng tay.
3. **Tầng 3 (Detail Mapping):** Cập nhật `DTM_{MODULE}_Detail_Mapping.csv`: nếu bãi bỏ thì chuyển `column_role = 'DEPRECATED'`, để trống `mart_table`/`mart_column`, `logic = 'Đã loại bỏ — không tạo cột/slicer'`; nếu sáp nhập thì đổi tên `mart_table`/`mart_column` sang bảng mới.
4. **Tầng 4 (Model Registry):** Xóa triệt để block entity `- id: "DTM-{datamart_table}"` khỏi `Datamart/datamart_model.yaml` (trừ khi là Conformed/Shared Dimension dùng chung cho module khác).
5. **Tầng 5 (HLD & Flat Table SQL):**
   - HLD: Đánh dấu `DEPRECATED` trong Section 3 và Section 4; cập nhật `Entities.csv/.md` (loại bỏ khỏi active entities);
   - Flat Table: Xóa khối DDL trong `01_create_{module}_flat_tables.sql` và khối DML trong `02_populate_{module}_flat_tables.sql`.
- **Phân định Orphan Check 3 Chiều (`check_orphan.py --strict`):**
  + **Nhánh A (Incomplete — Bảng còn $\ge 1$ KPI READY):** Gán mã `L2-ORPHAN-3WAY-INCOMPLETE`. Bắt buộc hoàn tất các tầng còn thiếu (Entities.csv, DDL/DML Flat Table). CẤM XÓA BẢNG!
  + **Nhánh B (Abandoned — Bảng 0 KPI READY / Đã bãi bỏ):** Gán mã `L2-ORPHAN-3WAY-ABANDONED`. Kích hoạt ngay Giao thức dọn dẹp 5 tầng nêu trên.

