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
