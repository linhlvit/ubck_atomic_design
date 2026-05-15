## TTHC — Quản lý thủ tục hành chính

### Các mô hình quan hệ dữ liệu

![Mô hình quan hệ dữ liệu TTHC](TTHC/fragments/TTHC_diagram.png)

**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | ap_rvw_workflow | Workflow instance xét duyệt hồ sơ đăng ký chào bán — ghi nhận từng lần chạy quy trình (WorkflowId, WorkflowStatus, CreatedUtc) gắn với hồ sơ qua CorrelationId. |
| 2 | ap_eform_fld_val | Toàn bộ giá trị field của tờ khai Eform đã index — UNION ALL 11 bảng *FieldIndex. Grain: 1 dòng = 1 giá trị field của 1 ContentItem. field_data_type_code phân biệt loại dữ liệu; string_value lưu universal TEXT. |
| 3 | scr_ofrg_ap | Hồ sơ đăng ký chào bán / phát hành chứng khoán do tổ chức nộp qua portal TTHC — tờ khai Eform (Latest=1, Published=1) phân biệt 11 loại hình chào bán. |




### Bảng ap_rvw_workflow



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ap_rvw_workflow_id | STRING |  | X | P |  | Khóa đại diện cho workflow instance xét duyệt hồ sơ. |
| 2 | ap_rvw_workflow_code | STRING |  |  |  |  | Mã workflow instance (WorkflowId). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'TTHC.WorkflowIndex' | Mã nguồn dữ liệu. |
| 4 | scr_ofrg_ap_id | STRING | X |  | F |  | FK đến hồ sơ chào bán gắn với workflow. ETL derived từ CorrelationId (chờ xác nhận T2-01 — cột chưa có trong Columns.csv). |
| 5 | scr_ofrg_ap_code | STRING | X |  |  |  | Mã ContentItemId hồ sơ. ETL derived từ CorrelationId (chờ xác nhận T2-01). |
| 6 | workflow_tp_code | STRING |  |  |  |  | Mã loại workflow (WorkflowTypeId). FK đến Classification Value scheme TTHC_WORKFLOW_TYPE. |
| 7 | workflow_st_code | STRING |  |  |  |  | Trạng thái workflow instance (Idle/Executing/Faulted/Finished/Aborted). |
| 8 | crt_tms | TIMESTAMP |  |  |  |  | Ngày giờ tạo workflow instance (CreatedUtc). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ap_rvw_workflow_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_ofrg_ap_id | scr_ofrg_ap | scr_ofrg_ap_id |



#### Index

N/A

#### Trigger

N/A




### Bảng ap_eform_fld_val



#### Từ TTHC.EformFieldValues

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ap_eform_fld_val_id | STRING |  | X | P |  | Khóa đại diện cho bộ giá trị Eform của một ContentItem. |
| 2 | scr_ofrg_ap_code | STRING |  |  |  |  | Mã ContentItemId của hồ sơ Eform. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'TTHC.EformFieldValues' | Mã nguồn dữ liệu. |
| 4 | scr_ofrg_ap_id | STRING |  |  | F |  | FK đến hồ sơ chào bán. |
| 5 | cntnt_tp_code | STRING |  |  |  |  | Loại Eform (ContentType) — phân biệt 11 loại hồ sơ chào bán. |
| 6 | tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng văn bản (TextFieldIndex) của ContentItem. Mỗi phần tử = 1 field. |
| 7 | html_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng HTML (HtmlFieldIndex) của ContentItem. |
| 8 | multi_tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đa văn bản (MultiTextFieldIndex) của ContentItem. |
| 9 | link_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng liên kết (LinkFieldIndex) của ContentItem. |
| 10 | num_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng số (NumericFieldIndex) của ContentItem. |
| 11 | dt_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày (DateFieldIndex) của ContentItem. |
| 12 | dttm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày giờ (DateTimeFieldIndex) của ContentItem. |
| 13 | tm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng giờ (TimeFieldIndex) của ContentItem. |
| 14 | booln_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đúng/sai (BooleanFieldIndex) của ContentItem. |
| 15 | cntnt_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng content picker (ContentPickerFieldIndex) của ContentItem. |
| 16 | usr_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng user picker (UserPickerFieldIndex) của ContentItem. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ap_eform_fld_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_ofrg_ap_id | scr_ofrg_ap | scr_ofrg_ap_id |



**Index:** N/A

**Trigger:** N/A


#### Từ TTHC.TextFieldIndex

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ap_eform_fld_val_id | STRING |  | X | P |  | Khóa đại diện cho bộ giá trị Eform của một ContentItem. |
| 2 | scr_ofrg_ap_code | STRING |  |  |  |  | Mã ContentItemId của hồ sơ Eform. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'TTHC.TextFieldIndex' | Mã nguồn dữ liệu. |
| 4 | scr_ofrg_ap_id | STRING |  |  | F |  | FK đến hồ sơ chào bán. |
| 5 | cntnt_tp_code | STRING |  |  |  |  | Loại Eform (ContentType) — phân biệt 11 loại hồ sơ chào bán. |
| 6 | tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng văn bản (TextFieldIndex) của ContentItem. Mỗi phần tử = 1 field. |
| 7 | html_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng HTML (HtmlFieldIndex) của ContentItem. |
| 8 | multi_tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đa văn bản (MultiTextFieldIndex) của ContentItem. |
| 9 | link_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng liên kết (LinkFieldIndex) của ContentItem. |
| 10 | num_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng số (NumericFieldIndex) của ContentItem. |
| 11 | dt_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày (DateFieldIndex) của ContentItem. |
| 12 | dttm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày giờ (DateTimeFieldIndex) của ContentItem. |
| 13 | tm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng giờ (TimeFieldIndex) của ContentItem. |
| 14 | booln_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đúng/sai (BooleanFieldIndex) của ContentItem. |
| 15 | cntnt_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng content picker (ContentPickerFieldIndex) của ContentItem. |
| 16 | usr_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng user picker (UserPickerFieldIndex) của ContentItem. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ap_eform_fld_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_ofrg_ap_id | scr_ofrg_ap | scr_ofrg_ap_id |



**Index:** N/A

**Trigger:** N/A


#### Từ TTHC.HtmlFieldIndex

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ap_eform_fld_val_id | STRING |  | X | P |  | Khóa đại diện cho bộ giá trị Eform của một ContentItem. |
| 2 | scr_ofrg_ap_code | STRING |  |  |  |  | Mã ContentItemId của hồ sơ Eform. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'TTHC.HtmlFieldIndex' | Mã nguồn dữ liệu. |
| 4 | scr_ofrg_ap_id | STRING |  |  | F |  | FK đến hồ sơ chào bán. |
| 5 | cntnt_tp_code | STRING |  |  |  |  | Loại Eform (ContentType) — phân biệt 11 loại hồ sơ chào bán. |
| 6 | tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng văn bản (TextFieldIndex) của ContentItem. Mỗi phần tử = 1 field. |
| 7 | html_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng HTML (HtmlFieldIndex) của ContentItem. |
| 8 | multi_tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đa văn bản (MultiTextFieldIndex) của ContentItem. |
| 9 | link_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng liên kết (LinkFieldIndex) của ContentItem. |
| 10 | num_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng số (NumericFieldIndex) của ContentItem. |
| 11 | dt_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày (DateFieldIndex) của ContentItem. |
| 12 | dttm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày giờ (DateTimeFieldIndex) của ContentItem. |
| 13 | tm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng giờ (TimeFieldIndex) của ContentItem. |
| 14 | booln_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đúng/sai (BooleanFieldIndex) của ContentItem. |
| 15 | cntnt_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng content picker (ContentPickerFieldIndex) của ContentItem. |
| 16 | usr_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng user picker (UserPickerFieldIndex) của ContentItem. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ap_eform_fld_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_ofrg_ap_id | scr_ofrg_ap | scr_ofrg_ap_id |



**Index:** N/A

**Trigger:** N/A


#### Từ TTHC.MultiTextFieldIndex

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ap_eform_fld_val_id | STRING |  | X | P |  | Khóa đại diện cho bộ giá trị Eform của một ContentItem. |
| 2 | scr_ofrg_ap_code | STRING |  |  |  |  | Mã ContentItemId của hồ sơ Eform. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'TTHC.MultiTextFieldIndex' | Mã nguồn dữ liệu. |
| 4 | scr_ofrg_ap_id | STRING |  |  | F |  | FK đến hồ sơ chào bán. |
| 5 | cntnt_tp_code | STRING |  |  |  |  | Loại Eform (ContentType) — phân biệt 11 loại hồ sơ chào bán. |
| 6 | tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng văn bản (TextFieldIndex) của ContentItem. Mỗi phần tử = 1 field. |
| 7 | html_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng HTML (HtmlFieldIndex) của ContentItem. |
| 8 | multi_tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đa văn bản (MultiTextFieldIndex) của ContentItem. |
| 9 | link_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng liên kết (LinkFieldIndex) của ContentItem. |
| 10 | num_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng số (NumericFieldIndex) của ContentItem. |
| 11 | dt_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày (DateFieldIndex) của ContentItem. |
| 12 | dttm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày giờ (DateTimeFieldIndex) của ContentItem. |
| 13 | tm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng giờ (TimeFieldIndex) của ContentItem. |
| 14 | booln_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đúng/sai (BooleanFieldIndex) của ContentItem. |
| 15 | cntnt_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng content picker (ContentPickerFieldIndex) của ContentItem. |
| 16 | usr_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng user picker (UserPickerFieldIndex) của ContentItem. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ap_eform_fld_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_ofrg_ap_id | scr_ofrg_ap | scr_ofrg_ap_id |



**Index:** N/A

**Trigger:** N/A


#### Từ TTHC.LinkFieldIndex

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ap_eform_fld_val_id | STRING |  | X | P |  | Khóa đại diện cho bộ giá trị Eform của một ContentItem. |
| 2 | scr_ofrg_ap_code | STRING |  |  |  |  | Mã ContentItemId của hồ sơ Eform. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'TTHC.LinkFieldIndex' | Mã nguồn dữ liệu. |
| 4 | scr_ofrg_ap_id | STRING |  |  | F |  | FK đến hồ sơ chào bán. |
| 5 | cntnt_tp_code | STRING |  |  |  |  | Loại Eform (ContentType) — phân biệt 11 loại hồ sơ chào bán. |
| 6 | tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng văn bản (TextFieldIndex) của ContentItem. Mỗi phần tử = 1 field. |
| 7 | html_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng HTML (HtmlFieldIndex) của ContentItem. |
| 8 | multi_tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đa văn bản (MultiTextFieldIndex) của ContentItem. |
| 9 | link_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng liên kết (LinkFieldIndex) của ContentItem. |
| 10 | num_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng số (NumericFieldIndex) của ContentItem. |
| 11 | dt_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày (DateFieldIndex) của ContentItem. |
| 12 | dttm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày giờ (DateTimeFieldIndex) của ContentItem. |
| 13 | tm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng giờ (TimeFieldIndex) của ContentItem. |
| 14 | booln_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đúng/sai (BooleanFieldIndex) của ContentItem. |
| 15 | cntnt_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng content picker (ContentPickerFieldIndex) của ContentItem. |
| 16 | usr_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng user picker (UserPickerFieldIndex) của ContentItem. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ap_eform_fld_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_ofrg_ap_id | scr_ofrg_ap | scr_ofrg_ap_id |



**Index:** N/A

**Trigger:** N/A


#### Từ TTHC.NumericFieldIndex

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ap_eform_fld_val_id | STRING |  | X | P |  | Khóa đại diện cho bộ giá trị Eform của một ContentItem. |
| 2 | scr_ofrg_ap_code | STRING |  |  |  |  | Mã ContentItemId của hồ sơ Eform. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'TTHC.NumericFieldIndex' | Mã nguồn dữ liệu. |
| 4 | scr_ofrg_ap_id | STRING |  |  | F |  | FK đến hồ sơ chào bán. |
| 5 | cntnt_tp_code | STRING |  |  |  |  | Loại Eform (ContentType) — phân biệt 11 loại hồ sơ chào bán. |
| 6 | tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng văn bản (TextFieldIndex) của ContentItem. Mỗi phần tử = 1 field. |
| 7 | html_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng HTML (HtmlFieldIndex) của ContentItem. |
| 8 | multi_tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đa văn bản (MultiTextFieldIndex) của ContentItem. |
| 9 | link_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng liên kết (LinkFieldIndex) của ContentItem. |
| 10 | num_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng số (NumericFieldIndex) của ContentItem. |
| 11 | dt_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày (DateFieldIndex) của ContentItem. |
| 12 | dttm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày giờ (DateTimeFieldIndex) của ContentItem. |
| 13 | tm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng giờ (TimeFieldIndex) của ContentItem. |
| 14 | booln_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đúng/sai (BooleanFieldIndex) của ContentItem. |
| 15 | cntnt_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng content picker (ContentPickerFieldIndex) của ContentItem. |
| 16 | usr_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng user picker (UserPickerFieldIndex) của ContentItem. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ap_eform_fld_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_ofrg_ap_id | scr_ofrg_ap | scr_ofrg_ap_id |



**Index:** N/A

**Trigger:** N/A


#### Từ TTHC.DateFieldIndex

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ap_eform_fld_val_id | STRING |  | X | P |  | Khóa đại diện cho bộ giá trị Eform của một ContentItem. |
| 2 | scr_ofrg_ap_code | STRING |  |  |  |  | Mã ContentItemId của hồ sơ Eform. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'TTHC.DateFieldIndex' | Mã nguồn dữ liệu. |
| 4 | scr_ofrg_ap_id | STRING |  |  | F |  | FK đến hồ sơ chào bán. |
| 5 | cntnt_tp_code | STRING |  |  |  |  | Loại Eform (ContentType) — phân biệt 11 loại hồ sơ chào bán. |
| 6 | tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng văn bản (TextFieldIndex) của ContentItem. Mỗi phần tử = 1 field. |
| 7 | html_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng HTML (HtmlFieldIndex) của ContentItem. |
| 8 | multi_tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đa văn bản (MultiTextFieldIndex) của ContentItem. |
| 9 | link_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng liên kết (LinkFieldIndex) của ContentItem. |
| 10 | num_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng số (NumericFieldIndex) của ContentItem. |
| 11 | dt_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày (DateFieldIndex) của ContentItem. |
| 12 | dttm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày giờ (DateTimeFieldIndex) của ContentItem. |
| 13 | tm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng giờ (TimeFieldIndex) của ContentItem. |
| 14 | booln_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đúng/sai (BooleanFieldIndex) của ContentItem. |
| 15 | cntnt_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng content picker (ContentPickerFieldIndex) của ContentItem. |
| 16 | usr_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng user picker (UserPickerFieldIndex) của ContentItem. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ap_eform_fld_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_ofrg_ap_id | scr_ofrg_ap | scr_ofrg_ap_id |



**Index:** N/A

**Trigger:** N/A


#### Từ TTHC.DateTimeFieldIndex

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ap_eform_fld_val_id | STRING |  | X | P |  | Khóa đại diện cho bộ giá trị Eform của một ContentItem. |
| 2 | scr_ofrg_ap_code | STRING |  |  |  |  | Mã ContentItemId của hồ sơ Eform. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'TTHC.DateTimeFieldIndex' | Mã nguồn dữ liệu. |
| 4 | scr_ofrg_ap_id | STRING |  |  | F |  | FK đến hồ sơ chào bán. |
| 5 | cntnt_tp_code | STRING |  |  |  |  | Loại Eform (ContentType) — phân biệt 11 loại hồ sơ chào bán. |
| 6 | tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng văn bản (TextFieldIndex) của ContentItem. Mỗi phần tử = 1 field. |
| 7 | html_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng HTML (HtmlFieldIndex) của ContentItem. |
| 8 | multi_tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đa văn bản (MultiTextFieldIndex) của ContentItem. |
| 9 | link_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng liên kết (LinkFieldIndex) của ContentItem. |
| 10 | num_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng số (NumericFieldIndex) của ContentItem. |
| 11 | dt_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày (DateFieldIndex) của ContentItem. |
| 12 | dttm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày giờ (DateTimeFieldIndex) của ContentItem. |
| 13 | tm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng giờ (TimeFieldIndex) của ContentItem. |
| 14 | booln_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đúng/sai (BooleanFieldIndex) của ContentItem. |
| 15 | cntnt_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng content picker (ContentPickerFieldIndex) của ContentItem. |
| 16 | usr_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng user picker (UserPickerFieldIndex) của ContentItem. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ap_eform_fld_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_ofrg_ap_id | scr_ofrg_ap | scr_ofrg_ap_id |



**Index:** N/A

**Trigger:** N/A


#### Từ TTHC.TimeFieldIndex

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ap_eform_fld_val_id | STRING |  | X | P |  | Khóa đại diện cho bộ giá trị Eform của một ContentItem. |
| 2 | scr_ofrg_ap_code | STRING |  |  |  |  | Mã ContentItemId của hồ sơ Eform. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'TTHC.TimeFieldIndex' | Mã nguồn dữ liệu. |
| 4 | scr_ofrg_ap_id | STRING |  |  | F |  | FK đến hồ sơ chào bán. |
| 5 | cntnt_tp_code | STRING |  |  |  |  | Loại Eform (ContentType) — phân biệt 11 loại hồ sơ chào bán. |
| 6 | tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng văn bản (TextFieldIndex) của ContentItem. Mỗi phần tử = 1 field. |
| 7 | html_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng HTML (HtmlFieldIndex) của ContentItem. |
| 8 | multi_tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đa văn bản (MultiTextFieldIndex) của ContentItem. |
| 9 | link_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng liên kết (LinkFieldIndex) của ContentItem. |
| 10 | num_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng số (NumericFieldIndex) của ContentItem. |
| 11 | dt_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày (DateFieldIndex) của ContentItem. |
| 12 | dttm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày giờ (DateTimeFieldIndex) của ContentItem. |
| 13 | tm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng giờ (TimeFieldIndex) của ContentItem. |
| 14 | booln_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đúng/sai (BooleanFieldIndex) của ContentItem. |
| 15 | cntnt_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng content picker (ContentPickerFieldIndex) của ContentItem. |
| 16 | usr_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng user picker (UserPickerFieldIndex) của ContentItem. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ap_eform_fld_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_ofrg_ap_id | scr_ofrg_ap | scr_ofrg_ap_id |



**Index:** N/A

**Trigger:** N/A


#### Từ TTHC.BooleanFieldIndex

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ap_eform_fld_val_id | STRING |  | X | P |  | Khóa đại diện cho bộ giá trị Eform của một ContentItem. |
| 2 | scr_ofrg_ap_code | STRING |  |  |  |  | Mã ContentItemId của hồ sơ Eform. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'TTHC.BooleanFieldIndex' | Mã nguồn dữ liệu. |
| 4 | scr_ofrg_ap_id | STRING |  |  | F |  | FK đến hồ sơ chào bán. |
| 5 | cntnt_tp_code | STRING |  |  |  |  | Loại Eform (ContentType) — phân biệt 11 loại hồ sơ chào bán. |
| 6 | tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng văn bản (TextFieldIndex) của ContentItem. Mỗi phần tử = 1 field. |
| 7 | html_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng HTML (HtmlFieldIndex) của ContentItem. |
| 8 | multi_tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đa văn bản (MultiTextFieldIndex) của ContentItem. |
| 9 | link_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng liên kết (LinkFieldIndex) của ContentItem. |
| 10 | num_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng số (NumericFieldIndex) của ContentItem. |
| 11 | dt_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày (DateFieldIndex) của ContentItem. |
| 12 | dttm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày giờ (DateTimeFieldIndex) của ContentItem. |
| 13 | tm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng giờ (TimeFieldIndex) của ContentItem. |
| 14 | booln_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đúng/sai (BooleanFieldIndex) của ContentItem. |
| 15 | cntnt_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng content picker (ContentPickerFieldIndex) của ContentItem. |
| 16 | usr_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng user picker (UserPickerFieldIndex) của ContentItem. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ap_eform_fld_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_ofrg_ap_id | scr_ofrg_ap | scr_ofrg_ap_id |



**Index:** N/A

**Trigger:** N/A


#### Từ TTHC.ContentPickerFieldIndex

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ap_eform_fld_val_id | STRING |  | X | P |  | Khóa đại diện cho bộ giá trị Eform của một ContentItem. |
| 2 | scr_ofrg_ap_code | STRING |  |  |  |  | Mã ContentItemId của hồ sơ Eform. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'TTHC.ContentPickerFieldIndex' | Mã nguồn dữ liệu. |
| 4 | scr_ofrg_ap_id | STRING |  |  | F |  | FK đến hồ sơ chào bán. |
| 5 | cntnt_tp_code | STRING |  |  |  |  | Loại Eform (ContentType) — phân biệt 11 loại hồ sơ chào bán. |
| 6 | tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng văn bản (TextFieldIndex) của ContentItem. Mỗi phần tử = 1 field. |
| 7 | html_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng HTML (HtmlFieldIndex) của ContentItem. |
| 8 | multi_tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đa văn bản (MultiTextFieldIndex) của ContentItem. |
| 9 | link_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng liên kết (LinkFieldIndex) của ContentItem. |
| 10 | num_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng số (NumericFieldIndex) của ContentItem. |
| 11 | dt_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày (DateFieldIndex) của ContentItem. |
| 12 | dttm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày giờ (DateTimeFieldIndex) của ContentItem. |
| 13 | tm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng giờ (TimeFieldIndex) của ContentItem. |
| 14 | booln_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đúng/sai (BooleanFieldIndex) của ContentItem. |
| 15 | cntnt_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng content picker (ContentPickerFieldIndex) của ContentItem. |
| 16 | usr_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng user picker (UserPickerFieldIndex) của ContentItem. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ap_eform_fld_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_ofrg_ap_id | scr_ofrg_ap | scr_ofrg_ap_id |



**Index:** N/A

**Trigger:** N/A


#### Từ TTHC.UserPickerFieldIndex

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ap_eform_fld_val_id | STRING |  | X | P |  | Khóa đại diện cho bộ giá trị Eform của một ContentItem. |
| 2 | scr_ofrg_ap_code | STRING |  |  |  |  | Mã ContentItemId của hồ sơ Eform. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'TTHC.UserPickerFieldIndex' | Mã nguồn dữ liệu. |
| 4 | scr_ofrg_ap_id | STRING |  |  | F |  | FK đến hồ sơ chào bán. |
| 5 | cntnt_tp_code | STRING |  |  |  |  | Loại Eform (ContentType) — phân biệt 11 loại hồ sơ chào bán. |
| 6 | tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng văn bản (TextFieldIndex) của ContentItem. Mỗi phần tử = 1 field. |
| 7 | html_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng HTML (HtmlFieldIndex) của ContentItem. |
| 8 | multi_tx_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đa văn bản (MultiTextFieldIndex) của ContentItem. |
| 9 | link_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng liên kết (LinkFieldIndex) của ContentItem. |
| 10 | num_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng số (NumericFieldIndex) của ContentItem. |
| 11 | dt_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày (DateFieldIndex) của ContentItem. |
| 12 | dttm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng ngày giờ (DateTimeFieldIndex) của ContentItem. |
| 13 | tm_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng giờ (TimeFieldIndex) của ContentItem. |
| 14 | booln_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng đúng/sai (BooleanFieldIndex) của ContentItem. |
| 15 | cntnt_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng content picker (ContentPickerFieldIndex) của ContentItem. |
| 16 | usr_picker_fields | ARRAY<STRUCT<...>> | X |  |  |  | Tập hợp các field dạng user picker (UserPickerFieldIndex) của ContentItem. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ap_eform_fld_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_ofrg_ap_id | scr_ofrg_ap | scr_ofrg_ap_id |



**Index:** N/A

**Trigger:** N/A





### Bảng scr_ofrg_ap



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_ofrg_ap_id | STRING |  | X | P |  | Khóa đại diện cho hồ sơ chào bán / kết quả xét duyệt. |
| 2 | scr_ofrg_ap_code | STRING |  |  |  |  | Mã định danh nội dung (ContentItemId). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'TTHC.ContentItemIndex' | Mã nguồn dữ liệu. |
| 4 | cntnt_itm_vrsn_id | STRING | X |  |  |  | Phiên bản nội dung (ContentItemVersionId). Dùng phân biệt các draft/phiên bản lịch sử. |
| 5 | cntnt_tp_code | STRING |  |  |  |  | Loại nội dung — phân biệt 11 loại hồ sơ Eform chào bán và các loại kết quả (GCN / từ chối). |
| 6 | dspl_tx | STRING | X |  |  |  | Tiêu đề hiển thị của hồ sơ (DisplayText). |
| 7 | ap_st_code | STRING |  |  |  |  | Trạng thái nghiệp vụ tổng hợp: Chờ xử lý / Đang xử lý / Đã cấp phép / Bị từ chối. |
| 8 | own_usr_nm | STRING | X |  |  |  | Tên người dùng sở hữu hồ sơ (Owner). Denormalized — UserIndex out-of-scope. |
| 9 | ahr_usr_nm | STRING | X |  |  |  | Tên tác giả tạo hồ sơ (Author). Denormalized — UserIndex out-of-scope. |
| 10 | crt_tms | TIMESTAMP | X |  |  |  | Ngày giờ tạo hồ sơ (CreatedUtc). |
| 11 | published_tms | TIMESTAMP | X |  |  |  | Ngày giờ xuất bản hồ sơ (PublishedUtc). |
| 12 | mod_tms | TIMESTAMP | X |  |  |  | Ngày giờ cập nhật gần nhất (ModifiedUtc). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_ofrg_ap_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Stored Procedure/Function

N/A

### Package

N/A
