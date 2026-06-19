# Phase 3 — Detail Mapping CSV Reference

## Header

```
kpi_id,tab,nhom,kpi_name,tinh_chat,source_module,mart_table,mart_column,column_role,logic,ghi_chu
```

Export encoding: **UTF-8 BOM** (`utf-8-sig`).

---

## Phạm vi xử lý

**Nguồn sự thật:** `BRD/BA/BA_analyst_{MODULE}.csv`

| Trạng thái BA | Xử lý |
|---|---|
| `Done` | Đưa vào Detail Mapping đầy đủ |
| `Doing` | Đưa vào Detail Mapping, `ghi_chu = "Doing — chờ BA xác nhận"` |
| `Pending` | Đưa vào Detail Mapping đầy đủ |
| `NaN` / trống | Xác nhận với BA trước khi map — không tự điền |

**KPI PENDING từ HLD** (block PENDING Section 2) — cũng đưa vào Detail Mapping:

| Cột | Giá trị |
|---|---|
| `kpi_id` | K_{MODULE}_N — tham chiếu từ HLD |
| `kpi_name` | Tên KPI từ bảng KPI PENDING trong HLD |
| `mart_table` | *(để trống)* |
| `mart_column` | *(để trống)* |
| `column_role` | *(để trống)* |
| `logic` | *(để trống)* |
| `ghi_chu` | `Pending - chưa thiết kế nguồn` |

❌ Không bỏ qua dòng `Phân loại = Chiều`.
❌ Không bỏ qua dòng `Trạng thái = Doing`.
❌ Không bỏ qua chiều lặp lại giữa các nhóm — mỗi nhóm phải có đủ SLICER/FILTER.

---

## column_role

| `column_role` | Khi nào dùng |
|---|---|
| `MEASURE` | KPI Base — phép tính aggregate trực tiếp trên mart |
| `FILTER` | Điều kiện lọc có giá trị cố định |
| `SLICER` | Chiều phân tích — user chọn giá trị tại runtime |
| `GROUP_BY` | Chiều nhóm trong aggregate |
| `JOIN_KEY` | FK dùng để join |
| `DERIVED` | KPI Phái sinh — tính tại presentation layer |

**Mapping từ Phân loại BA / Tính chất HLD:**

| Phân loại BA / Tính chất HLD | column_role |
|---|---|
| `Chiều` | `SLICER` / `FILTER` / `GROUP_BY` |
| `Chỉ tiêu cơ sở` | `MEASURE` |
| `Chỉ tiêu phái sinh` | `DERIVED` (ưu tiên) hoặc `MEASURE` nếu lưu trong mart |
| `Attribute` (KPI tác nghiệp trên Operational) | `SLICER` — column hiển thị / filter trực tiếp, không aggregate |

**Lưu ý `tinh_chat` cho dòng FILTER/SLICER của KPI Base:**
Dòng FILTER/SLICER thuộc cùng KPI Base (cùng `kpi_id`) kế thừa `tinh_chat = "Base"` từ KPI cha — không để trống.

---

## Quy tắc từng column_role

**MEASURE:**
- Chỉ khai báo phép tính thuần: `COUNT`, `SUM`, `AVG`
- Không nhúng `WHERE` condition vào MEASURE — tách thành FILTER/SLICER row riêng
- Ngoại lệ: aggregate nhiều nhánh không thể tách (VD: CASE WHEN trong SUM)

**DERIVED:**
- `mart_table` và `mart_column` để **trống**
- `logic` chứa formula đầy đủ dùng physical name
- ❌ `logic` của DERIVED không được refer KPI ID (`K_{MODULE}_N`) — ngoại lệ duy nhất: YoY không biểu diễn được bằng mart column → `ghi_chu = "Refer KPI ID vì YoY — cần presentation layer resolve"`

**Chỉ số / Bộ chỉ số thị trường:**
- `mart_column = scr_tdg_snpst_dim.idx_codes`
- `column_role = FILTER`
- `logic = ARRAY_CONTAINS(scr_tdg_snpst_dim.idx_codes, :selected_index)`

---

## Quy ước tên cột

| Cột | Kiểu tên | Ví dụ |
|---|---|---|
| `mart_table` | **Logical** | `Fact Fund Management Company Snapshot` |
| `mart_column` | **Logical** | `Investment Fund Count` |
| `logic` | **Physical** — tra từ Attributes CSV | `SUM(fct_fnd_mgt_co_snpst.ivsm_fnd_cnt)` |

❌ `logic` dùng logical name (Title Case) — phải là physical `table.column`.
❌ `tinh_chat` trong Detail Mapping khác với `Tính chất` trong HLD bảng KPI.

---

## Lưu ý từ thực tế review — lỗi tái diễn (bắt buộc kiểm tra trước khi giao file)

Các lỗi dưới đây được tổng hợp từ review module PTTT. Mỗi lỗi có pattern cụ thể để kiểm tra nhanh.

### L1 — K_PTTT_41 / Chiều thời gian bị copy-paste sai bảng

**Pattern:** Nhóm có nhiều bảng Fact/Operational; khi copy SLICER/FILTER của K_PTTT_41 từ nhóm trước, `mart_table` và `logic` vẫn trỏ về bảng của nhóm cũ.

**Kiểm tra:** Với mỗi nhóm, xác nhận SLICER `logic` của K_PTTT_41 (hoặc bất kỳ KPI Chiều thời gian tương đương) trỏ đúng `physical_table` của nhóm đó — không phải bảng nhóm khác.

❌ `fct_mkt_rsk_snpst.snpst_dt` xuất hiện ở nhóm dùng `fct_mbr_sfty_per_mbr_snpst` → sai.

---

### L2 — Cột trong `logic` không tồn tại trong Attributes.csv

**Pattern:** Điền `logic = <table>.<column>` nhưng cột đó không có trong `DTM_{MODULE}_Attributes.csv` — thường do đoán tên hoặc copy từ bảng khác.

**Kiểm tra:** Với mọi `physical_table.physical_column` trong cột `logic`, tra tên cột trong Attributes.csv của bảng tương ứng trước khi giao file.

❌ `scr_co_dim.scr_co_code` → không tồn tại; đúng là `scr_co_dim.mbr_code`.

---

### L3 — Operational table bị gán FILTER `cdr_dt_dim`

**Pattern:** Bảng `opr_*` (Operational) không có FK `snpst_dt_dim_id` → không thể JOIN `cdr_dt_dim`. Dòng FILTER date dim không có nghĩa với Operational.

**Quy tắc:**
- Fact Snapshot → cần SLICER `snpst_dt` + FILTER `JOIN cdr_dt_dim ON ... snpst_dt_dim_id`
- Operational → chỉ SLICER trực tiếp cột date (`rpt_dt`, `snpst_dt`...) — không có FILTER `cdr_dt_dim`

❌ Thêm FILTER `cdr_dt_dim` cho bảng `opr_mbr_sfty_monitor` → sai.

---

### L4 — PENDING rule: nhóm HLD PENDING còn điền `column_role`/`mart_table`/`logic`

**Pattern:** HLD nhóm = PENDING nhưng Detail Mapping vẫn điền đầy đủ column_role, mart_table, mart_column, logic (thường do copy từ nhóm khác hoặc điền dự kiến).

**Quy tắc cứng:** HLD nhóm PENDING → **toàn bộ** dòng của nhóm đó trong Detail Mapping phải để trống `mart_table`/`mart_column`/`column_role`/`logic`. Chỉ được điền `kpi_id`, `kpi_name`, `tab`, `nhom`, `tinh_chat`, `source_module`, `ghi_chu`.

❌ Nhóm 26–37 (HLD PENDING / FDS blocker) còn MEASURE/SLICER/FILTER → vi phạm.

---

### L5 — `kpi_name` sai ngữ cảnh khi nhóm được copy từ nhóm tương tự

**Pattern:** Nhiều nhóm có cùng cấu trúc (VD: nhóm VN30/VN100/TPCP) — khi copy nhóm VN30 sang VN100, `kpi_name` vẫn ghi "VN30" thay vì "VN100".

**Kiểm tra:** Với mọi nhóm được tạo bằng cách copy từ nhóm khác, scan toàn bộ `kpi_name` để đảm bảo không còn tên ngữ cảnh cũ.

❌ `kpi_name = "KLGD HĐTL VN30 ngày t"` trong nhóm VN100 → sai.

---

### L6 — Logic sai nguồn dữ liệu — tham chiếu bảng không thuộc nhóm

**Pattern:** `logic` trong một nhóm tham chiếu `physical_table` của nhóm khác — thường do copy-paste hoặc dùng tên bảng tương tự mà không kiểm tra.

**Kiểm tra:** Với mỗi dòng MEASURE/SLICER/FILTER, xác nhận `physical_table` trong `logic` là bảng được thiết kế cho nhóm đó (có trong HLD section của nhóm và trong Attributes.csv).

❌ `SUM(fct_mbr_sfty_per_mbr_snpst.mrgn_dbt_bil_vnd)` xuất hiện ở nhóm dùng `fct_indx_tdg_snpst` → sai.

---

### L7 — Dòng duplicate FILTER trong nhóm PENDING

**Pattern:** Một KPI_ID có 2 dòng FILTER (do copy từ nhiều nguồn). Với nhóm PENDING, các dòng này đều phải xóa về 1 dòng PENDING duy nhất.

**Kiểm tra:** Với nhóm PENDING, mỗi `kpi_id` chỉ được có 1 dòng trong Detail Mapping.

❌ K_PTTT_111 có 2 dòng trong nhóm 37 PENDING → vi phạm.

---

### L8 — Placeholder `<TBD>` trong cột `logic`

**Pattern:** Điền `logic = fct_xxx.col_<TBD>` khi chưa biết tên cột — placeholder bị để lại trong file giao.

**Quy tắc:** `logic` phải là physical name xác định hoặc để trống. Nếu chưa xác định được → chuyển về PENDING (xóa `column_role`/`mart_table`/`logic`, ghi `ghi_chu` rõ blocker).

❌ `logic = fct_mkt_cap_expl_snpst.gdp_<TBD>` → không hợp lệ.

---

### L9 — Cột `nhom` thiếu tên đầy đủ theo HLD

**Pattern:** Cột `nhom` chỉ ghi `"Nhóm 1a"` thay vì tên đầy đủ theo HLD heading Section 2 — mất ngữ nghĩa khi xem file CSV độc lập.

**Quy tắc:**
- Lấy tên từ heading HLD Section 2: `#### Nhóm Xa — [Phân hệ] — [Tên ngắn]`
- Nếu heading có 3 phần → bỏ phần giữa (phân hệ nghiệp vụ, thường trùng với Tab): `Nhóm Xa — [Tên ngắn]`
- Nếu heading có 2 phần → giữ nguyên: `Nhóm X — [Tên ngắn]`

| HLD heading | `nhom` đúng |
|---|---|
| `Nhóm 1a — Chứng chỉ hành nghề — Thống kê tổng hợp (KPI thẻ CCHN)` | `Nhóm 1a — Thống kê tổng hợp (KPI thẻ CCHN)` |
| `Nhóm 1b — Người hành nghề — Thống kê tổng hợp (KPI thẻ NHN)` | `Nhóm 1b — Thống kê tổng hợp (KPI thẻ NHN)` |
| `Nhóm 2 — Biểu đồ Trình độ chuyên môn` | `Nhóm 2 — Biểu đồ Trình độ chuyên môn` |
| `Nhóm 5 — Dashboard Tra cứu hồ sơ 360° — Thông tin chung của NHNCK` | `Nhóm 5 — Thông tin chung của NHNCK` |

❌ `nhom = "Nhóm 1a"` → thiếu tên ngắn, không hợp lệ.

---

### L10 — DERIVED YoY logic refer KPI_ID thay vì công thức physical

**Pattern:** Ghi `logic = (K_NHNCK_2[Y] - K_NHNCK_2[Y-1]) / K_NHNCK_2[Y-1] * 100` — refer KPI_ID thay vì viết công thức bằng physical column.

**Quy tắc:** DERIVED _YOY phải viết công thức rút gọn theo dạng:
```
( COUNT/SUM(fct_xxx.col | <filter_conditions> | snpst yr=:Y) - COUNT/SUM(fct_xxx.col | <filter_conditions> | snpst yr=:Y-1) ) / NULLIF( COUNT/SUM(fct_xxx.col | <filter_conditions> | snpst yr=:Y-1) , 0) * 100
```

**Ký hiệu `|` trong YoY formula** = ngăn cách điều kiện filter (pseudo-SQL, dùng trong cột `logic` để tránh dấu phẩy phá cấu trúc CSV). `ghi_chu` ghi `"YoY % tăng trưởng — presentation layer resolve 2 năm"`.

Ví dụ K_NHNCK_2_YOY (CCHN cấp mới YTD):
```
( COUNT(DISTINCT fct_prac_license_ctf_snpst.license_ctf_doc_code | ctf_issu_dt IN :Y | snpst yr=:Y) - COUNT(DISTINCT fct_prac_license_ctf_snpst.license_ctf_doc_code | ctf_issu_dt IN :Y-1 | snpst yr=:Y-1) ) / NULLIF( COUNT(DISTINCT fct_prac_license_ctf_snpst.license_ctf_doc_code | ctf_issu_dt IN :Y-1 | snpst yr=:Y-1) , 0) * 100
```

❌ `logic = (K_NHNCK_2[Y] - K_NHNCK_2[Y-1]) / K_NHNCK_2[Y-1] * 100` → refer KPI_ID không hợp lệ.

---

### L11 — Thiếu row FILTER `src_stm_code` cho Operational table

**Pattern:** Bảng `opr_*` (Operational) có `src_stm_code` nhưng Detail Mapping không có dòng FILTER để lọc nguồn — khi Atomic table nhận thêm nguồn mới, presentation layer khai thác dữ liệu lẫn nguồn.

**Quy tắc:**
- **Operational table** có `src_stm_code`: bắt buộc có 1 row `column_role = FILTER` với `logic = "src_stm_code = '<VALUE>'"`, `ghi_chu = 'Forward-compat: lọc đúng nguồn khi bảng có nhiều src_stm_code'`. Đặt ngay sau row `JOIN_KEY` đầu tiên của bảng đó trong Detail Mapping.
- **Dimension table**: KHÔNG cần row FILTER `src_stm_code` — Surrogate Key đã encode nguồn (SK = hash(natural_key + src_stm_code)), JOIN từ Fact sang Dim qua SK đã đảm bảo đúng nguồn.
- Ngoại lệ không áp dụng: `cv` (Classification Value) và `cdr_dt_dim` (Calendar Date) — conformed/shared tables.

**Kiểm tra:** Với mỗi Operational table trong Detail Mapping, tìm row `column_role = FILTER` có `logic` chứa `src_stm_code`. Nếu thiếu → thêm row.

❌ `opr_prac_360_profile` không có FILTER `src_stm_code = 'NHNCK_PROFESSIONALS'` → sai.
✅ `opr_prac_360_profile` có 1 dòng `column_role = FILTER`, `logic = "src_stm_code = 'NHNCK_PROFESSIONALS'"`.

---

### Checklist bổ sung — kiểm tra trước khi giao file Phase 2

```
□ L1: Mọi SLICER/FILTER Chiều thời gian → logic trỏ đúng physical_table của nhóm đó (không phải bảng nhóm khác)
□ L2: Mọi physical_table.physical_column trong logic → tồn tại trong Attributes.csv của bảng tương ứng
□ L3: Operational table → không có dòng FILTER cdr_dt_dim (chỉ SLICER date column trực tiếp)
□ L4: HLD nhóm PENDING → toàn bộ dòng của nhóm: mart_table/mart_column/column_role/logic trống
□ L5: Nhóm copy từ nhóm khác → scan kpi_name kiểm tra không còn tên ngữ cảnh cũ
□ L6: Mọi physical_table trong logic → là bảng thuộc nhóm đó (không phải bảng nhóm khác)
□ L7: Nhóm PENDING → mỗi kpi_id chỉ có 1 dòng (không duplicate)
□ L8: Không có giá trị <TBD> hoặc placeholder chưa xác định trong cột logic
□ L9: Cột nhom → tên đầy đủ theo HLD (không chỉ "Nhóm X" — phải có phần tên ngắn)
□ L10: DERIVED _YOY → logic viết bằng physical column theo template rút gọn (không refer KPI_ID)
□ L11: Mỗi Operational table (opr_*) có src_stm_code → có đúng 1 dòng FILTER logic="src_stm_code = '<VALUE>'" ngay sau JOIN_KEY đầu tiên; Dimension table → không thêm FILTER này
```

---

## Quy trình đối chiếu BA trước khi sinh

**Bước 0 — Cross-check BA ↔ HLD ↔ Detail Mapping (BẮT BUỘC — thực hiện trước bước 1):**

**0.a — Kiểm tra độ phủ BA → HLD:**
1. Với mỗi dòng BA có `Trạng thái mapping ∈ {Done, Doing, Pending}` (kể cả `Phân loại = Chiều`):
   - Tìm KPI_ID tương ứng trong bảng KPI của nhóm đó trong HLD
   - Nếu KPI_ID chưa có trong HLD → **DỪNG**, báo cáo danh sách thiếu theo nhóm
2. ❌ Không tự sinh KPI_ID mới — KPI_ID mới phải được khai sinh trong HLD trước
3. ❌ Không bỏ qua dòng `Phân loại = Chiều` — Chiều cũng cần KPI_ID riêng
4. ❌ Không dùng shorthand "xem nhóm khác" — mỗi nhóm phải có đủ KPI_ID explicit trong output
5. Chỉ tiếp tục bước 0.b khi **tất cả** dòng Done/Doing/Pending từ BA đều đã có KPI_ID trong HLD

**0.b — Kiểm tra số lượng (đếm và báo cáo trước khi sinh):**
1. Đếm **tổng dòng BA** có `Trạng thái ∈ {Done, Doing, Pending}` (kể cả dòng bị đánh dấu trùng trong cột `Đánh giá`) → gọi là **N_BA**
2. Đếm số dòng BA **unique** sau khi loại trùng theo cột `Đánh giá` → gọi là **N_KPI** (= số KPI_ID cần có trong HLD)
3. Báo cáo cho user trước khi sinh:
   > "BA có **N_BA** dòng cần mapping, trong đó **N_KPI** KPI unique (sau loại trùng theo cột Đánh giá). Detail Mapping output sẽ có tối thiểu N_BA dòng và đúng N_KPI KPI_ID unique."
4. Sau khi sinh xong → kiểm tra:
   - Số dòng trong Detail Mapping ≥ N_BA (≥ vì 1 dòng BA có thể sinh nhiều dòng MEASURE/FILTER/SLICER)
   - Nếu có dòng BA nào không tìm thấy trong output → báo danh sách trước khi giao file

**0.c — Kiểm tra tính hợp lệ Detail Mapping → HLD (sau khi sinh):**
1. Lấy danh sách KPI_ID unique trong Detail Mapping output
2. Số KPI_ID unique phải = **N_KPI**
3. Đối chiếu từng KPI_ID với bảng KPI trong HLD — nếu có KPI_ID nào không tìm thấy → **báo cáo danh sách** và yêu cầu khai sinh trong HLD trước khi giao file
4. ❌ Không giao file Detail Mapping khi còn KPI_ID chưa được khai trong HLD

**Bước 1 — Lọc và chuẩn bị:**

1. Lọc Done/Doing/Pending từ BA file
2. Xác định `mart_table` + `mart_column` từ Attributes.csv cho từng dòng
3. Nếu không tìm được → `ghi_chu = "Thiếu cột trong mart — cần bổ sung Attributes"`
4. Tra bảng KPI trong HLD (`Tính chất` + `Công thức`) trước khi điền `column_role`:
   - `Phái sinh` → bắt buộc `DERIVED`; mart_table/mart_column để trống
   - Công thức có `RANK()`, `ROW_NUMBER()`, tham chiếu KPI ID → bắt buộc `DERIVED`

---

## Ví dụ đại diện

```csv
"kpi_id","tab","nhom","kpi_name","tinh_chat","source_module","mart_table","mart_column","column_role","logic","ghi_chu"
"K_FMS_1","TỔNG QUAN","Nhóm 1","Quỹ đầu tư chứng khoán","Base","FMS","Fact Fund Management Company Snapshot","Investment Fund Count","MEASURE","COUNT(fct_fnd_mgt_co_snpst.ivsm_fnd_cnt)",""
"K_FMS_1","TỔNG QUAN","Nhóm 1","Quỹ đầu tư chứng khoán","Base","FMS","Fact Fund Management Company Snapshot","Snapshot Date Dimension Id","FILTER","JOIN cdr_dt_dim ON cdr_dt_dim.cdr_dt_dim_id = fct_fnd_mgt_co_snpst.snpst_dt_dim_id WHERE cdr_dt_dim.yr = :Y AND cdr_dt_dim.mo = :M",""
"K_FMS_2_YOY","TỔNG QUAN","Nhóm 1","Tăng trưởng AUM so cùng kỳ","Phái sinh","FMS","","","DERIVED","(K_FMS_2 kỳ hiện tại - K_FMS_2 cùng kỳ năm trước) / K_FMS_2 cùng kỳ năm trước","Refer KPI ID vì YoY — cần presentation layer resolve"
"K_FMS_5","TỔNG QUAN","Nhóm 2","Loại hình CTQLQ","Base","FMS","Fund Management Company Dimension","Life Cycle Status Code","SLICER","fnd_mgt_co_dim.lcs_code",""
"K_FMS_10","CHI TIẾT","Nhóm 3","Tên quỹ","Base","FMS","","","","","Pending - chưa thiết kế nguồn"
```
