# So sánh cấu trúc 3 bảng ODS: FMS v2 ↔ SCMS

*Ngày lập: 07/11/2026. Bản nháp, cần review trước khi chốt.*

## Phạm vi và nguồn đối chiếu

| Bảng | FMS v2 | SCMS |
|---|---|---|
| Danh mục chỉ tiêu | `ods_fms_item_list_v2` | `uat_scms_ods.item_list` |
| Lần nộp báo cáo | `ods_fms_report_history_v2` | `uat_scms_ods.report_history` |
| Giá trị chỉ tiêu | `ods_fms_item_value_v2` | `uat_scms_ods.item_value` |

- **FMS:** `etl-chi-tieu-job/fms_dags/fms_staging_to_ods_v2/` (`ddl.py`, `transform_item_list.py`, `transform_report_history.py`, `transform_item_value.py`)
- **SCMS:** `etl-chi-tieu-job/spark/spark_job/main_scms_staging_to_ods.py`

> Ý nghĩa các cột trong tài liệu này được suy từ code ETL, chưa đối chiếu trên dữ liệu thật. Những điểm cần xác minh được gom ở mục 6.

## 1. Cùng tên, cùng ý nghĩa

| Bảng | Cột | Ghi chú |
|---|---|---|
| item_list | `item_id` | Cả hai đều là md5 của đường dẫn ô. SCMS băm thêm `form_report_id` (xem mục 2). |
| item_list | `report_code`, `report_name`, `legal_basis`, `sheet_name`, `row_path`, `column_path` | Khớp cả tên lẫn nghĩa. |
| report_history | `report_log_id` | Mã lần nộp. FMS lấy từ `rpt_member.id`, SCMS lấy từ `report_input_submission.id`. |
| report_history | `report_code`, `object_name` | Khớp. |
| item_value | `report_log_id`, `item_id`, `entity_code`, `value` | Khớp. Với dòng động nhiều cấp, `entity_code` của SCMS có dạng `'cha > con'`. |
| cả 3 bảng | `_source_system`, `_loaded_at` | Khớp. |

## 2. Cùng tên nhưng khác nghĩa hoặc khác miền giá trị

Đây là nhóm dễ hiểu nhầm nhất khi gộp dữ liệu hai phân hệ.

| Cột | FMS | SCMS |
|---|---|---|
| `item_id` | `md5(report_name\|sheet\|row_path\|col_path)`. Mọi phiên bản template của một báo cáo dùng chung một `item_id`. | `md5(form_report_id\|report_name\|sheet\|row_path\|col_path)`. **Mỗi phiên bản template có `item_id` riêng**, nên không join thẳng bằng `item_id` để theo dõi một chỉ tiêu qua nhiều phiên bản. |
| `row_order` (item_value) | Lấy từ `row_dynamic` của nguồn: số thứ tự dòng động, dòng tĩnh = 0. FMS đánh lại từ 0 cho từng sheet. Sheet nhiều khối (ví dụ `@QLDMDT`) có giá trị dạng `số khối × 1000 + số dòng` (giả thuyết, xem mục 6). | `rowIndex + (row_no - 1) × số dòng của khối`: vị trí dòng trên sheet, áp dụng cả cho ô tĩnh. |
| `row_order` (item_list) | Không có cột này. FMS lưu vị trí ô ở hai cột `_row` và `_col`. | `sheetIndex × 100000 + rowIndex × 100 + colIndex`: vị trí ô, dùng để sắp xếp. Tương ứng với `_row`/`_col` của FMS, **không phải** `row_order` của item_value. |
| `object_type` | Nhãn suy từ `record_type` (`RECORD_TYPE_LABELS`). | Mã suy từ `REF_TYPE`: `CTCK_TN`, `CTCK_CN_NN`, `CTCK_VPDD_NN`, `NGAN_HANG`. Cùng nghĩa "loại đối tượng" nhưng **khác bộ mã**. |
| `object_id` | UUID của thực thể (quỹ, CTQLQ…). | ID của bảng đơn vị (`sc_firm_info`, branch, bank…). Docstring đầu file ETL ghi `object_id = SHORT_NAME`, nhưng code ghi ID, còn SHORT_NAME nằm ở `object_code`. Docstring cần sửa cho khớp code. |
| `is_dynamic`, `data_type` | Nằm ở **item_value** (xem mục 5). | Nằm ở **item_list**. Nghĩa giống FMS: ô thuộc dòng động; kiểu dữ liệu. Miền giá trị `data_type` có thể khác nhau, vì FMS lấy từ `format_data_type` còn SCMS lấy từ `metricType`. |

Ở cả hai hệ, `row_order` của item_value đều dùng để phân biệt các dòng động trong khoá. Tuy vậy, **giá trị của hai bên không so sánh được với nhau**.

## 3. Khác tên nhưng cùng ý nghĩa

| FMS | SCMS | Ghi chú |
|---|---|---|
| `submission_date` | `submission_dt` | Ngày nộp. Cả hai đều là cột partition. |
| `period_type` | `report_period` | Loại kỳ. Bộ mã khác nhau (SCMS dùng `NGAY`, `NAM`…), cần bảng quy đổi. |
| `period_value` (chuỗi đã định dạng, ví dụ `TU12/2026`) | `report_year` + `period` | SCMS tách năm và số kỳ thành hai cột. Riêng kỳ `NGAY`, `period` là ngày dạng `YYYY-MM-DD`. |
| `_row` + `_col` (item_list) | `row_order` (item_list) | Xem mục 2. |
| `rpt_version` (report_history) | `version` (item_list) / `form_report_id` | Đều chỉ phiên bản template. FMS gắn phiên bản vào lần nộp, SCMS gắn vào template. **Cần xác minh.** |

## 4. Chỉ có ở một bên

| Bảng | Chỉ có ở FMS | Chỉ có ở SCMS |
|---|---|---|
| item_list | `uid_cell`, `is_label_col`, `label_item_id` | `form_report_id`, `record_status` (1 = template đang dùng, 2 = không dùng) |
| report_history | `audit`, `object_subtype`, `report_type`, `late_status`, `late_duration`, `due_date` | `form_report_id`, `object_code`, `listing_exchange`, `business_lines` |
| item_value | `row_path`, `is_label_col`, `acc_value_num`, `acc_value` | — |

`object_subtype` của FMS và `business_lines` của SCMS đều phân loại đối tượng, nhưng khác nghĩa: một bên là loại quỹ, một bên là ngành nghề kinh doanh của CTCK. Không gộp hai cột này.

## 5. Vì sao FMS để `is_dynamic`, `data_type` ở item_value

Nguồn FMS lưu hai thông tin này **theo từng giá trị đã nộp** (`rpt_values.dynamic_value`, `rpt_values.format_data_type`), không lưu theo mẫu biểu. SCMS lấy chúng từ cấu hình mẫu (`SHEETS_JSON`).

- **`is_dynamic`:** dữ liệu FMS có trường hợp lệch cờ, tức ô thuộc vùng động nhưng giá trị nộp lên có `dynamic_value = 0`. ETL phải map được cả hai trường hợp về cùng một `item_id`. Nếu đưa cột này lên item_list sẽ mất thông tin "lần nộp này gửi theo cờ nào", nên nên giữ ở item_value.
- **`data_type`:** về nghiệp vụ là thuộc tính của ô. Có thể chuyển sang item_list như SCMS nếu dữ liệu xác nhận mỗi `item_id` chỉ có một kiểu (SQL ở phụ lục B).

## 6. Hệ quả cho business key

| Bảng | Khoá FMS | Khoá SCMS |
|---|---|---|
| item_list | `item_id` | `item_id` (đã gồm `form_report_id`) |
| report_history | `report_log_id` | `report_log_id` |
| item_value | `report_log_id + item_id + row_order` | `report_log_id + item_id + row_order` |

- **Không dùng `entity_code` hay `acc_value` thay cho `row_order`:**
  - `entity_code` để rỗng khi chưa cấu hình cột nhãn, và có thể trùng hoặc trống do người nộp nhập.
  - `acc_value` là giá trị số đo, thường NULL.
- **FMS item_value có thể trùng khoá do nguồn:** ODS FMS giữ nguyên mọi dòng của nguồn, không dedup. Khi lên datamart cần quy tắc chọn một dòng cho mỗi khoá.
- **SCMS:** code ghi rằng khối lặp nhiều dòng trước đây bị trùng khoá `(item, entity, row_order)`. Công thức `row_order` đã được sửa để tránh trường hợp này.
- **Gộp hai phân hệ ở tầng trên:** khoá phải thêm `_source_system`, vì `item_id` và `report_log_id` của hai hệ được sinh độc lập.
- **Cần bảng chuẩn hoá** cho ba nhóm cột:
  - `object_type`
  - loại kỳ: `period_type` ↔ `report_period`
  - giá trị kỳ: `period_value` ↔ `report_year` + `period`





