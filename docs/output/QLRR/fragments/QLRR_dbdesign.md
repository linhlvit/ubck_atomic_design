## 2.{IDX} QLRR — 

### 2.{IDX}.1 Các mô hình quan hệ dữ liệu

- DBML tổng hợp (tất cả bảng): [`QLRR.dbml`](QLRR.dbml) — paste vào https://dbdiagram.io để render.
- Diagram theo mảng nghiệp vụ:
  - **UID001 — Khai thác Dashboard**: [`QLRR_UID001.dbml`](QLRR_UID001.dbml)
  - **UID002 — Khai thác Báo cáo**: [`QLRR_UID002.dbml`](QLRR_UID002.dbml)
  - **UID003 — Khai thác Chỉ tiêu tài chính trong nước**: [`QLRR_UID003.dbml`](QLRR_UID003.dbml)
  - **UID004 — Khai thác Chỉ tiêu tài chính quốc tế**: [`QLRR_UID004.dbml`](QLRR_UID004.dbml)
  - **UID005 — Quản lý Cảnh báo**: [`QLRR_UID005.dbml`](QLRR_UID005.dbml)
  - **UID006 — Khai thác Phân quyền dữ liệu**: [`QLRR_UID006.dbml`](QLRR_UID006.dbml)
  - **UID007 — Quản lý tích hợp**: [`QLRR_UID007.dbml`](QLRR_UID007.dbml)


**Danh sách bảng:**

| STT | Thực thể | Tên bảng | Mô tả |
|---|---|---|---|
| 1 | Risk Indicator Category | rsk_ind_cgy | Nhóm phân loại chỉ tiêu tài chính rủi ro theo bộ (trong nước/quốc tế) và nhóm nghiệp vụ (vĩ mô/tiền tệ/thị trường CK). FK nguồn cho Risk Indicator. |
| 2 | Risk Indicator | rsk_ind | Danh mục chỉ tiêu tài chính rủi ro — gộp chỉ tiêu hệ thống (risk_indicator) và tự tạo (risk_indicator_custom). Phân biệt bằng indicator_type_code. indicator_category_id nullable (chỉ tiêu tự tạo không có category). |
| 3 | Risk Report Type | rsk_rpt_tp | Danh mục loại báo cáo rủi ro (Báo cáo nhanh hàng tháng v.v.). Master entity có lifecycle. FK từ Risk Report Upload Batch. |
| 4 | Risk Indicator Schedule | rsk_ind_shd | Cấu hình lịch chạy job đồng bộ chỉ tiêu rủi ro (frequency_type/cron_expression). Grain: 1-1 với Risk Indicator. FK → Risk Indicator. |
| 5 | Risk Alert Config | rsk_alert_config | Cấu hình ngưỡng và quy tắc kích hoạt cảnh báo cho từng chỉ tiêu rủi ro. Grain: 1 cấu hình / 1 chỉ tiêu. FK → Risk Indicator. |
| 6 | Risk Report Upload Batch | rsk_rpt_upload_btch | Đợt upload file báo cáo rủi ro định kỳ. Grain: 1 đợt upload. FK → Risk Report Type. |
| 7 | Risk Indicator Value | rsk_ind_val | Giá trị thực tế của chỉ tiêu rủi ro theo từng kỳ (ngày/tháng/quý/năm). Grain: chỉ tiêu × kỳ. Append-only. FK → Risk Indicator. |
| 8 | Risk Indicator Value Change | rsk_ind_val_chg | Lịch sử từng lần thay đổi giá trị chỉ tiêu (SYNC tự động / UPDATE thủ công). Grain: 1 lần thay đổi. Append-only. FK → Risk Indicator. |
| 9 | Risk Alert | rsk_alert | Bản ghi cảnh báo rủi ro phát sinh khi chỉ tiêu vượt ngưỡng cấu hình. Grain: 1 lần kích hoạt. Append-only. FK → Risk Alert Config + Risk Indicator. |
| 10 | Risk Report File | rsk_rpt_file | Metadata file đính kèm báo cáo rủi ro trong đợt upload. Grain: 1 file. FK → Risk Report Upload Batch. |
| 11 | Risk Alert Resolution | rsk_alert_rsl | Bản ghi xử lý chi tiết cho cảnh báo rủi ro (giải trình hoặc không). Grain: 1 lần xử lý. Append-only. FK → Risk Alert. |
| 12 | Risk Alert Resolution File | rsk_alert_rsl_file | File đính kèm giải trình cho bản ghi xử lý cảnh báo. Grain: 1 file. FK → Risk Alert Resolution. |
| 13 | Risk Alert History | rsk_alert_hist | Dòng thời gian sự kiện trong vòng đời cảnh báo (phát sinh / xử lý). Grain: 1 sự kiện nghiệp vụ. Append-only. FK → Risk Alert. |
| 14 | Risk Alert Notification | rsk_alert_notf | Thông báo cảnh báo gửi từng kênh (Toast/Bell/Email) đến từng người nhận. Grain: 1 thông báo / 1 người. Append-only. FK → Risk Alert. |



### 2.{IDX}.2 Bảng Risk Indicator Category

- **Mô tả:** Nhóm phân loại chỉ tiêu tài chính rủi ro theo bộ (trong nước/quốc tế) và nhóm nghiệp vụ (vĩ mô/tiền tệ/thị trường CK). FK nguồn cho Risk Indicator.
- **Tên vật lý:** rsk_ind_cgy
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Risk Indicator Category Id | rsk_ind_cgy_id | BIGINT |  | X | P |  | Khóa đại diện cho nhóm chỉ tiêu rủi ro. | QLRR.risk_indicator_category |  |  |
| 2 | Risk Indicator Category Code | rsk_ind_cgy_code | STRING |  |  |  |  | Mã nhóm chỉ tiêu (VD: MACRO, MONETARY, STOCK_MARKET). BK. | QLRR.risk_indicator_category | category_code | BK của entity. Unique globally. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'QLRR.risk_indicator_category' | Mã hệ thống nguồn. | QLRR.risk_indicator_category |  |  |
| 4 | Indicator Set Code | ind_set_code | STRING |  |  |  |  | Bộ chỉ tiêu: 1=Trong nước, 2=Quốc tế. Attribute bổ sung — không phân biệt entity. | QLRR.risk_indicator_category | set_code | Scheme: RISK_INDICATOR_SET. set_code chỉ là thông tin mô tả bổ sung; category_code unique globally. |
| 5 | Category Name | cgy_nm | STRING |  |  |  |  | Tên nhóm chỉ tiêu (VD: Yếu tố vĩ mô). | QLRR.risk_indicator_category | category_name |  |
| 6 | Active Flag | actv_f | BOOLEAN |  |  |  |  | Trạng thái hoạt động: 0=Không hoạt động, 1=Hoạt động. | QLRR.risk_indicator_category | status |  |


#### 2.{IDX}.2.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Risk Indicator Category Id | rsk_ind_cgy_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.3 Bảng Risk Indicator — QLRR.risk_indicator

- **Mô tả:** Danh mục chỉ tiêu tài chính rủi ro — gộp chỉ tiêu hệ thống (risk_indicator) và tự tạo (risk_indicator_custom). Phân biệt bằng indicator_type_code. indicator_category_id nullable (chỉ tiêu tự tạo không có category).
- **Tên vật lý:** rsk_ind
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Risk Indicator Id | rsk_ind_id | BIGINT |  | X | P |  | Khóa đại diện cho chỉ tiêu rủi ro (hệ thống hoặc tự tạo). | QLRR.risk_indicator |  |  |
| 2 | Risk Indicator Code | rsk_ind_code | STRING |  |  |  |  | Mã định danh duy nhất của chỉ tiêu. BK. Hệ thống: map từ risk_indicator.id; Tự tạo: map từ risk_indicator_custom.id với prefix 'CUS_'. | QLRR.risk_indicator | id | BK của entity. Hệ thống dùng risk_indicator.id; tự tạo dùng 'CUS_' + risk_indicator_custom.id để tránh conflict. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'QLRR.risk_indicator' | Mã hệ thống nguồn. | QLRR.risk_indicator |  |  |
| 4 | Indicator Type Code | ind_tp_code | STRING |  |  |  |  | Phân loại chỉ tiêu sau gộp: 1=Hệ thống (risk_indicator), 2=Tự tạo (risk_indicator_custom). | QLRR.risk_indicator |  | ETL-derived. Scheme: RISK_INDICATOR_TYPE. |
| 5 | Indicator Name | ind_nm | STRING |  |  |  |  | Tên chỉ tiêu (VD: GDP, CPI, Chỉ số VNIndex, Lạm phát Mỹ). | QLRR.risk_indicator | indicator_name |  |
| 6 | Indicator Set Code | ind_set_code | STRING | X |  |  |  | Bộ chỉ tiêu: 1=Trong nước, 2=Quốc tế. Chỉ áp dụng cho chỉ tiêu hệ thống. | QLRR.risk_indicator | set_code | Scheme: RISK_INDICATOR_SET. Nullable — chỉ tiêu tự tạo không có set_code. |
| 7 | Business Key | bsn_key | STRING | X |  |  |  | Mã nghiệp vụ chỉ tiêu hệ thống (VD: GDP_VN, CPI_VN). Chỉ có ở chỉ tiêu hệ thống. | QLRR.risk_indicator | indicator_code |  |
| 8 | Risk Indicator Category Id | rsk_ind_cgy_id | BIGINT | X |  | F |  | FK đến nhóm chỉ tiêu rủi ro. | QLRR.risk_indicator | category_id |  |
| 9 | Risk Indicator Category Code | rsk_ind_cgy_code | STRING | X |  |  |  | Mã nhóm chỉ tiêu rủi ro. | QLRR.risk_indicator | category_id |  |
| 10 | Unit Code | unit_code | STRING | X |  |  |  | Đơn vị mặc định: 1=%, 2=Điểm, 3=Tỷ VND, 4=Triệu USD, 5=Hợp đồng, 6=Cổ phiếu, 7=Công ty, 8=VND, 9=Số tài khoản, 10=Đơn vị tính. | QLRR.risk_indicator | unit_code | Scheme: RISK_UNIT. |
| 11 | Data Source Code | data_src_code | STRING | X |  |  |  | Nguồn dữ liệu mặc định: 1=Investing, 2=Tổng cục Thống kê, 3=Ngân hàng Nhà nước, 4=Nội bộ, 5=HNX, 6=VSDC. | QLRR.risk_indicator | source_code | Scheme: RISK_DATA_SOURCE. |
| 12 | Period Type Code | prd_tp_code | STRING | X |  |  |  | Tần suất chỉ tiêu: 1=Ngày, 2=Tháng, 3=Quý, 4=Năm. | QLRR.risk_indicator | period_type | Scheme: RISK_PERIOD_TYPE. |
| 13 | Last Sync Time | last_sync_tm | TIMESTAMP | X |  |  |  | Thời điểm đồng bộ dữ liệu gần nhất. Chỉ áp dụng cho chỉ tiêu hệ thống. | QLRR.risk_indicator | last_sync_time |  |
| 14 | Display Order | dspl_ordr | INT | X |  |  |  | Thứ tự hiển thị của chỉ tiêu trên màn hình. | QLRR.risk_indicator | display_order |  |
| 15 | Display Flag | dspl_f | BOOLEAN | X |  |  |  | Có hiển thị trên màn hình không: 0=Không, 1=Có. Chỉ áp dụng cho chỉ tiêu hệ thống. | QLRR.risk_indicator | is_display |  |
| 16 | Active Flag | actv_f | BOOLEAN |  |  |  |  | Trạng thái hoạt động: 0=Không hoạt động, 1=Hoạt động. | QLRR.risk_indicator | status |  |


#### 2.{IDX}.3.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Risk Indicator Id | rsk_ind_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Risk Indicator Category Id | rsk_ind_cgy_id | Risk Indicator Category | Risk Indicator Category Id | rsk_ind_cgy_id |




### 2.{IDX}.4 Bảng Risk Indicator — QLRR.risk_indicator_custom

- **Mô tả:** Danh mục chỉ tiêu tài chính rủi ro — gộp chỉ tiêu hệ thống (risk_indicator) và tự tạo (risk_indicator_custom). Phân biệt bằng indicator_type_code. indicator_category_id nullable (chỉ tiêu tự tạo không có category).
- **Tên vật lý:** rsk_ind
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Risk Indicator Id | rsk_ind_id | BIGINT |  | X | P |  | Khóa đại diện cho chỉ tiêu rủi ro (hệ thống hoặc tự tạo). | QLRR.risk_indicator_custom |  |  |
| 2 | Risk Indicator Code | rsk_ind_code | STRING |  |  |  |  | Mã định danh duy nhất của chỉ tiêu. BK. Hệ thống: map từ risk_indicator.id; Tự tạo: map từ risk_indicator_custom.id với prefix 'CUS_'. | QLRR.risk_indicator_custom | id | BK của entity. Hệ thống dùng risk_indicator.id; tự tạo dùng 'CUS_' + risk_indicator_custom.id để tránh conflict. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'QLRR.risk_indicator_custom' | Mã hệ thống nguồn. | QLRR.risk_indicator_custom |  |  |
| 4 | Indicator Type Code | ind_tp_code | STRING |  |  |  |  | Phân loại chỉ tiêu sau gộp: 1=Hệ thống (risk_indicator), 2=Tự tạo (risk_indicator_custom). | QLRR.risk_indicator_custom |  | ETL-derived. Scheme: RISK_INDICATOR_TYPE. |
| 5 | Indicator Name | ind_nm | STRING |  |  |  |  | Tên chỉ tiêu (VD: GDP, CPI, Chỉ số VNIndex, Lạm phát Mỹ). | QLRR.risk_indicator_custom | indicator_name |  |
| 6 | Indicator Set Code | ind_set_code | STRING | X |  |  |  | Bộ chỉ tiêu: 1=Trong nước, 2=Quốc tế. Chỉ áp dụng cho chỉ tiêu hệ thống. | QLRR.risk_indicator_custom | set_code | Scheme: RISK_INDICATOR_SET. Nullable — chỉ tiêu tự tạo không có set_code. |
| 7 | Business Key | bsn_key | STRING | X |  |  |  | Mã nghiệp vụ chỉ tiêu hệ thống (VD: GDP_VN, CPI_VN). Chỉ có ở chỉ tiêu hệ thống. | QLRR.risk_indicator_custom | indicator_code |  |
| 8 | Risk Indicator Category Id | rsk_ind_cgy_id | BIGINT | X |  | F |  | FK đến nhóm chỉ tiêu rủi ro. | QLRR.risk_indicator_custom | category_id |  |
| 9 | Risk Indicator Category Code | rsk_ind_cgy_code | STRING | X |  |  |  | Mã nhóm chỉ tiêu rủi ro. | QLRR.risk_indicator_custom | category_id |  |
| 10 | Unit Code | unit_code | STRING | X |  |  |  | Đơn vị mặc định: 1=%, 2=Điểm, 3=Tỷ VND, 4=Triệu USD, 5=Hợp đồng, 6=Cổ phiếu, 7=Công ty, 8=VND, 9=Số tài khoản, 10=Đơn vị tính. | QLRR.risk_indicator_custom | unit_code | Scheme: RISK_UNIT. |
| 11 | Data Source Code | data_src_code | STRING | X |  |  |  | Nguồn dữ liệu mặc định: 1=Investing, 2=Tổng cục Thống kê, 3=Ngân hàng Nhà nước, 4=Nội bộ, 5=HNX, 6=VSDC. | QLRR.risk_indicator_custom | source_code | Scheme: RISK_DATA_SOURCE. |
| 12 | Period Type Code | prd_tp_code | STRING | X |  |  |  | Tần suất chỉ tiêu: 1=Ngày, 2=Tháng, 3=Quý, 4=Năm. | QLRR.risk_indicator_custom | period_type | Scheme: RISK_PERIOD_TYPE. |
| 13 | Last Sync Time | last_sync_tm | TIMESTAMP | X |  |  |  | Thời điểm đồng bộ dữ liệu gần nhất. Chỉ áp dụng cho chỉ tiêu hệ thống. | QLRR.risk_indicator_custom | last_sync_time |  |
| 14 | Display Order | dspl_ordr | INT | X |  |  |  | Thứ tự hiển thị của chỉ tiêu trên màn hình. | QLRR.risk_indicator_custom | display_order |  |
| 15 | Display Flag | dspl_f | BOOLEAN | X |  |  |  | Có hiển thị trên màn hình không: 0=Không, 1=Có. Chỉ áp dụng cho chỉ tiêu hệ thống. | QLRR.risk_indicator_custom | is_display |  |
| 16 | Active Flag | actv_f | BOOLEAN |  |  |  |  | Trạng thái hoạt động: 0=Không hoạt động, 1=Hoạt động. | QLRR.risk_indicator_custom | status |  |


#### 2.{IDX}.4.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Risk Indicator Id | rsk_ind_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Risk Indicator Category Id | rsk_ind_cgy_id | Risk Indicator Category | Risk Indicator Category Id | rsk_ind_cgy_id |




### 2.{IDX}.5 Bảng Risk Report Type

- **Mô tả:** Danh mục loại báo cáo rủi ro (Báo cáo nhanh hàng tháng v.v.). Master entity có lifecycle. FK từ Risk Report Upload Batch.
- **Tên vật lý:** rsk_rpt_tp
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Risk Report Type Id | rsk_rpt_tp_id | BIGINT |  | X | P |  | Khóa đại diện cho loại báo cáo rủi ro. | QLRR.risk_report_type |  |  |
| 2 | Risk Report Type Code | rsk_rpt_tp_code | STRING |  |  |  |  | Mã loại báo cáo. BK. | QLRR.risk_report_type | code | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'QLRR.risk_report_type' | Mã hệ thống nguồn. | QLRR.risk_report_type |  |  |
| 4 | Report Type Name | rpt_tp_nm | STRING |  |  |  |  | Tên loại báo cáo. | QLRR.risk_report_type | name |  |
| 5 | Description | dsc | STRING | X |  |  |  | Mô tả loại báo cáo. | QLRR.risk_report_type | description |  |
| 6 | Display Order | dspl_ordr | INT | X |  |  |  | Thứ tự hiển thị. | QLRR.risk_report_type | display_order |  |
| 7 | Active Flag | actv_f | BOOLEAN |  |  |  |  | Trạng thái: 0=Không hoạt động, 1=Hoạt động. | QLRR.risk_report_type | is_active |  |


#### 2.{IDX}.5.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Risk Report Type Id | rsk_rpt_tp_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.6 Bảng Risk Indicator Schedule

- **Mô tả:** Cấu hình lịch chạy job đồng bộ chỉ tiêu rủi ro (frequency_type/cron_expression). Grain: 1-1 với Risk Indicator. FK → Risk Indicator.
- **Tên vật lý:** rsk_ind_shd
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Risk Indicator Schedule Id | rsk_ind_shd_id | BIGINT |  | X | P |  | Khóa đại diện cho lịch đồng bộ chỉ tiêu rủi ro. | QLRR.risk_indicator_schedule |  |  |
| 2 | Risk Indicator Schedule Code | rsk_ind_shd_code | STRING |  |  |  |  | Mã định danh lịch đồng bộ. BK. Map từ PK bảng nguồn. | QLRR.risk_indicator_schedule | id | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'QLRR.risk_indicator_schedule' | Mã hệ thống nguồn. | QLRR.risk_indicator_schedule |  |  |
| 4 | Risk Indicator Id | rsk_ind_id | BIGINT |  |  | F |  | FK đến chỉ tiêu rủi ro. | QLRR.risk_indicator_schedule | indicator_id |  |
| 5 | Risk Indicator Code | rsk_ind_code | STRING |  |  |  |  | Mã chỉ tiêu rủi ro. | QLRR.risk_indicator_schedule | indicator_id |  |
| 6 | Frequency Type Code | frq_tp_code | STRING |  |  |  |  | Tần suất chạy job: 1=Giờ, 2=Ngày, 3=Tháng, 4=Quý, 5=Năm. | QLRR.risk_indicator_schedule | frequency_type | Scheme: RISK_JOB_FREQUENCY_TYPE. |
| 7 | Frequency Value | frq_val | INT | X |  |  |  | Mỗi bao nhiêu đơn vị (VD: mỗi 2 ngày). | QLRR.risk_indicator_schedule | frequency_value |  |
| 8 | Start Time | strt_tm | TIMESTAMP | X |  |  |  | Ngày giờ bắt đầu chạy job. | QLRR.risk_indicator_schedule | start_time |  |
| 9 | Next Run Time | nxt_run_tm | TIMESTAMP | X |  |  |  | Lịch chạy tiếp theo (auto-calculated). | QLRR.risk_indicator_schedule | next_run_time |  |
| 10 | Last Run Time | last_run_tm | TIMESTAMP | X |  |  |  | Lần chạy gần nhất. | QLRR.risk_indicator_schedule | last_run_time |  |
| 11 | Cron Expression | cron_expression | STRING | X |  |  |  | Quartz cron expression định nghĩa lịch chạy. | QLRR.risk_indicator_schedule | cron_expression |  |
| 12 | Enabled Flag | enabled_f | BOOLEAN |  |  |  |  | Trạng thái kích hoạt job: 0=Không hoạt động, 1=Hoạt động. | QLRR.risk_indicator_schedule | is_enabled |  |
| 13 | Total Run Count | tot_run_cnt | INT | X |  |  |  | Số lần job đã chạy (thống kê tích lũy). | QLRR.risk_indicator_schedule | total_runs |  |
| 14 | Last Run Status Code | last_run_st_code | STRING | X |  |  |  | Kết quả lần chạy gần nhất: SUCCESS, FAILED. | QLRR.risk_indicator_schedule | last_status | Scheme: RISK_JOB_RUN_STATUS. |
| 15 | Last Error | last_err | STRING | X |  |  |  | Thông tin lỗi lần chạy gần nhất (nếu có). | QLRR.risk_indicator_schedule | last_error |  |


#### 2.{IDX}.6.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Risk Indicator Schedule Id | rsk_ind_shd_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Risk Indicator Id | rsk_ind_id | Risk Indicator | Risk Indicator Id | rsk_ind_id |




### 2.{IDX}.7 Bảng Risk Alert Config

- **Mô tả:** Cấu hình ngưỡng và quy tắc kích hoạt cảnh báo cho từng chỉ tiêu rủi ro. Grain: 1 cấu hình / 1 chỉ tiêu. FK → Risk Indicator.
- **Tên vật lý:** rsk_alert_config
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Risk Alert Config Id | rsk_alert_config_id | BIGINT |  | X | P |  | Khóa đại diện cho cấu hình ngưỡng cảnh báo chỉ tiêu rủi ro. | QLRR.risk_alert_config |  |  |
| 2 | Risk Alert Config Code | rsk_alert_config_code | STRING |  |  |  |  | Mã định danh cấu hình cảnh báo. BK. Map từ PK bảng nguồn. | QLRR.risk_alert_config | id | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'QLRR.risk_alert_config' | Mã hệ thống nguồn. | QLRR.risk_alert_config |  |  |
| 4 | Risk Indicator Id | rsk_ind_id | BIGINT |  |  | F |  | FK đến chỉ tiêu rủi ro (hệ thống hoặc tự tạo) sau gộp. | QLRR.risk_alert_config | indicator_id |  |
| 5 | Risk Indicator Code | rsk_ind_code | STRING |  |  |  |  | Mã chỉ tiêu rủi ro. | QLRR.risk_alert_config | indicator_id |  |
| 6 | Threshold Direction Code | thrs_drc_code | STRING |  |  |  |  | Chiều ngưỡng cảnh báo: 1=Tăng, 2=Giảm, 3=Tăng/Giảm. | QLRR.risk_alert_config | threshold_direction | Scheme: RISK_ALERT_THRESHOLD_DIRECTION. |
| 7 | Threshold Unit Code | thrs_unit_code | STRING | X |  |  |  | Đơn vị ngưỡng: 1=%, 2=Điểm, 3=Tỷ VND, 4=Triệu USD, 5=Hợp đồng, 6=Cổ phiếu, 7=Công ty, 8=VND, 9=Số tài khoản, 10=Đơn vị tính. | QLRR.risk_alert_config | threshold_unit_code | Scheme: RISK_UNIT. |
| 8 | Threshold Value | thrs_val | STRING |  |  |  |  | Giá trị ngưỡng kích hoạt cảnh báo. | QLRR.risk_alert_config | threshold_value |  |
| 9 | Compare Period Count | cmpr_prd_cnt | INT | X |  |  |  | Số kỳ cần so sánh để đánh giá ngưỡng. | QLRR.risk_alert_config | compare_period_time |  |
| 10 | Alert Message Template | alert_msg_tpl | STRING | X |  |  |  | Nội dung mẫu thông báo cảnh báo. | QLRR.risk_alert_config | alert_message_template |  |
| 11 | Handler User Id | handler_usr_id | STRING | X |  |  |  | User ID người xử lý chính (denormalized — không có User entity trên Silver). | QLRR.risk_alert_config | handler_user_id |  |
| 12 | Handler User Name | handler_usr_nm | STRING | X |  |  |  | Tên người xử lý chính (denormalized). | QLRR.risk_alert_config | handler_user_name |  |
| 13 | Notify Bell Flag | notf_bell_f | BOOLEAN |  |  |  |  | Hiển thị thông báo chuông: 0=Không, 1=Có. | QLRR.risk_alert_config | notify_bell_flag |  |
| 14 | Notify Email Flag | notf_email_f | BOOLEAN |  |  |  |  | Gửi email cảnh báo: 0=Không, 1=Có. | QLRR.risk_alert_config | notify_email_flag |  |
| 15 | Notify Toast Flag | notf_toast_f | BOOLEAN |  |  |  |  | Thông báo toast: 0=Không, 1=Có. | QLRR.risk_alert_config | notify_toast_flag |  |
| 16 | Display Order | dspl_ordr | INT | X |  |  |  | Thứ tự hiển thị của cấu hình cảnh báo. | QLRR.risk_alert_config | display_order |  |
| 17 | Active Flag | actv_f | BOOLEAN |  |  |  |  | Trạng thái: 0=Không hoạt động, 1=Đang hoạt động. | QLRR.risk_alert_config | is_active |  |


#### 2.{IDX}.7.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Risk Alert Config Id | rsk_alert_config_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Risk Indicator Id | rsk_ind_id | Risk Indicator | Risk Indicator Id | rsk_ind_id |




### 2.{IDX}.8 Bảng Risk Report Upload Batch

- **Mô tả:** Đợt upload file báo cáo rủi ro định kỳ. Grain: 1 đợt upload. FK → Risk Report Type.
- **Tên vật lý:** rsk_rpt_upload_btch
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Risk Report Upload Batch Id | rsk_rpt_upload_btch_id | BIGINT |  | X | P |  | Khóa đại diện cho đợt upload báo cáo. | QLRR.risk_report_upload_batch |  |  |
| 2 | Risk Report Upload Batch Code | rsk_rpt_upload_btch_code | STRING |  |  |  |  | Mã định danh đợt upload. BK. Map từ PK bảng nguồn. | QLRR.risk_report_upload_batch | id | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'QLRR.risk_report_upload_batch' | Mã hệ thống nguồn. | QLRR.risk_report_upload_batch |  |  |
| 4 | Risk Report Type Id | rsk_rpt_tp_id | BIGINT |  |  | F |  | FK đến loại báo cáo. | QLRR.risk_report_upload_batch | report_type_id |  |
| 5 | Risk Report Type Code | rsk_rpt_tp_code | STRING |  |  |  |  | Mã loại báo cáo. | QLRR.risk_report_upload_batch | report_type_id |  |
| 6 | Report Date | rpt_dt | DATE |  |  |  |  | Thời gian báo cáo (do người dùng chọn khi upload). | QLRR.risk_report_upload_batch | report_date |  |
| 7 | File Count | file_cnt | INT |  |  |  |  | Số lượng file trong đợt upload. | QLRR.risk_report_upload_batch | file_count |  |


#### 2.{IDX}.8.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Risk Report Upload Batch Id | rsk_rpt_upload_btch_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Risk Report Type Id | rsk_rpt_tp_id | Risk Report Type | Risk Report Type Id | rsk_rpt_tp_id |




### 2.{IDX}.9 Bảng Risk Indicator Value

- **Mô tả:** Giá trị thực tế của chỉ tiêu rủi ro theo từng kỳ (ngày/tháng/quý/năm). Grain: chỉ tiêu × kỳ. Append-only. FK → Risk Indicator.
- **Tên vật lý:** rsk_ind_val
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Risk Indicator Value Id | rsk_ind_val_id | BIGINT |  | X | P |  | Khóa đại diện cho giá trị chỉ tiêu rủi ro theo kỳ. | QLRR.risk_indicator_value |  |  |
| 2 | Risk Indicator Value Code | rsk_ind_val_code | STRING |  |  |  |  | Mã định danh giá trị chỉ tiêu. BK. Map từ PK bảng nguồn. | QLRR.risk_indicator_value | id | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'QLRR.risk_indicator_value' | Mã hệ thống nguồn. | QLRR.risk_indicator_value |  |  |
| 4 | Risk Indicator Id | rsk_ind_id | BIGINT |  |  | F |  | FK đến chỉ tiêu rủi ro (hệ thống lẫn tự tạo — QLRR-P01 confirmed). | QLRR.risk_indicator_value | indicator_id |  |
| 5 | Risk Indicator Code | rsk_ind_code | STRING |  |  |  |  | Mã chỉ tiêu rủi ro. | QLRR.risk_indicator_value | indicator_id |  |
| 6 | Period Type Code | prd_tp_code | STRING |  |  |  |  | Kỳ dữ liệu: 1=Ngày, 2=Tháng, 3=Quý, 4=Năm. | QLRR.risk_indicator_value | period_type | Scheme: RISK_PERIOD_TYPE. |
| 7 | Period Value | prd_val | INT | X |  |  |  | Số thứ tự kỳ trong năm. VD: period_type=Tháng, period_date=12/03/2026 → period_value=3; period_type=Quý, period_date=12/03/2026 → period_value=1. | QLRR.risk_indicator_value | period_value |  |
| 8 | Period Year | prd_yr | INT |  |  |  |  | Năm của kỳ dữ liệu. | QLRR.risk_indicator_value | period_year |  |
| 9 | Period Date | prd_dt | DATE |  |  |  |  | Ngày đại diện cho kỳ dữ liệu. | QLRR.risk_indicator_value | period_date |  |
| 10 | Period Label | prd_lbl | STRING | X |  |  |  | Chuỗi hiển thị kỳ (VD: 2024-01, 2024-Q1, 2024). | QLRR.risk_indicator_value | period_label |  |
| 11 | Value | val | STRING |  |  |  |  | Giá trị chỉ tiêu tại kỳ này. | QLRR.risk_indicator_value | value |  |
| 12 | Unit Code | unit_code | STRING | X |  |  |  | Đơn vị đo lường: 1=%, 2=Điểm, 3=Tỷ VND, 4=Triệu USD, 5=Hợp đồng, 6=Cổ phiếu, 7=Công ty, 8=VND, 9=Số tài khoản, 10=Đơn vị tính. | QLRR.risk_indicator_value | unit_code | Scheme: RISK_UNIT. |
| 13 | Data Source Code | data_src_code | STRING | X |  |  |  | Nguồn dữ liệu: 1=Investing, 2=Tổng cục Thống kê, 3=Ngân hàng Nhà nước, 4=Nội bộ, 5=HNX, 6=VSDC. | QLRR.risk_indicator_value | source_code | Scheme: RISK_DATA_SOURCE. |
| 14 | Data Origin Code | data_orig_code | STRING |  |  |  |  | Nguồn gốc giá trị: 1=API CSDL tập trung, 2=User chỉnh sửa. | QLRR.risk_indicator_value | data_origin | Scheme: RISK_DATA_ORIGIN. |
| 15 | Cumulative Value | cmlv_val | STRING | X |  |  |  | Giá trị luỹ kế. [QLRR-P02 Open]: cơ sở luỹ kế chưa xác định (từ đầu năm hay từ đầu kỳ). | QLRR.risk_indicator_value | cumulative_value |  |


#### 2.{IDX}.9.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Risk Indicator Value Id | rsk_ind_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Risk Indicator Id | rsk_ind_id | Risk Indicator | Risk Indicator Id | rsk_ind_id |




### 2.{IDX}.10 Bảng Risk Indicator Value Change

- **Mô tả:** Lịch sử từng lần thay đổi giá trị chỉ tiêu (SYNC tự động / UPDATE thủ công). Grain: 1 lần thay đổi. Append-only. FK → Risk Indicator.
- **Tên vật lý:** rsk_ind_val_chg
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Risk Indicator Value Change Id | rsk_ind_val_chg_id | BIGINT |  | X | P |  | Khóa đại diện cho bản ghi thay đổi giá trị chỉ tiêu. | QLRR.risk_indicator_value_history |  |  |
| 2 | Risk Indicator Value Change Code | rsk_ind_val_chg_code | STRING |  |  |  |  | Mã định danh bản ghi thay đổi. BK. Map từ PK bảng nguồn. | QLRR.risk_indicator_value_history | id | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'QLRR.risk_indicator_value_history' | Mã hệ thống nguồn. | QLRR.risk_indicator_value_history |  |  |
| 4 | Risk Indicator Id | rsk_ind_id | BIGINT |  |  | F |  | FK đến chỉ tiêu rủi ro. | QLRR.risk_indicator_value_history | indicator_id |  |
| 5 | Risk Indicator Code | rsk_ind_code | STRING |  |  |  |  | Mã chỉ tiêu rủi ro. | QLRR.risk_indicator_value_history | indicator_id |  |
| 6 | Old Value | old_val | STRING | X |  |  |  | Giá trị cũ trước thay đổi (null nếu là lần tạo mới). | QLRR.risk_indicator_value_history | old_value |  |
| 7 | New Value | new_val | STRING | X |  |  |  | Giá trị mới sau thay đổi (null nếu là xóa). | QLRR.risk_indicator_value_history | new_value |  |
| 8 | Unit Code | unit_code | STRING | X |  |  |  | Đơn vị đo lường tại thời điểm thay đổi: 1=%, 2=Điểm, 3=Tỷ VND, … | QLRR.risk_indicator_value_history | unit_code | Scheme: RISK_UNIT. |
| 9 | Data Source Code | data_src_code | STRING | X |  |  |  | Nguồn dữ liệu sau thay đổi: 1=Investing, 2=Tổng cục Thống kê, 3=Ngân hàng Nhà nước, 4=Nội bộ, 5=HNX, 6=VSDC. | QLRR.risk_indicator_value_history | source_code | Scheme: RISK_DATA_SOURCE. |
| 10 | Data Origin Code | data_orig_code | STRING |  |  |  |  | Nguồn gốc dữ liệu sau thay đổi: 1=API CSDL tập trung, 2=User chỉnh sửa. | QLRR.risk_indicator_value_history | data_origin | Scheme: RISK_DATA_ORIGIN. |
| 11 | Change Type Code | chg_tp_code | STRING |  |  |  |  | Loại thay đổi: SYNC=đồng bộ tự động, UPDATE=chỉnh sửa thủ công. | QLRR.risk_indicator_value_history | change_type | Scheme: RISK_INDICATOR_CHANGE_TYPE. |
| 12 | Change By Id | chg_by_id | STRING | X |  |  |  | User ID người thực hiện thay đổi (denormalized). | QLRR.risk_indicator_value_history | change_by_id |  |
| 13 | Change By Name | chg_by_nm | STRING | X |  |  |  | Tên người thực hiện thay đổi (denormalized). | QLRR.risk_indicator_value_history | change_by_name |  |
| 14 | Change At | chg_at | TIMESTAMP |  |  |  |  | Thời điểm ghi nhận thay đổi. | QLRR.risk_indicator_value_history | change_at |  |


#### 2.{IDX}.10.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Risk Indicator Value Change Id | rsk_ind_val_chg_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Risk Indicator Id | rsk_ind_id | Risk Indicator | Risk Indicator Id | rsk_ind_id |




### 2.{IDX}.11 Bảng Risk Alert

- **Mô tả:** Bản ghi cảnh báo rủi ro phát sinh khi chỉ tiêu vượt ngưỡng cấu hình. Grain: 1 lần kích hoạt. Append-only. FK → Risk Alert Config + Risk Indicator.
- **Tên vật lý:** rsk_alert
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Risk Alert Id | rsk_alert_id | BIGINT |  | X | P |  | Khóa đại diện cho bản ghi cảnh báo rủi ro. | QLRR.risk_alert |  |  |
| 2 | Risk Alert Code | rsk_alert_code | STRING |  |  |  |  | Mã định danh cảnh báo. BK. Map từ PK bảng nguồn. | QLRR.risk_alert | id | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'QLRR.risk_alert' | Mã hệ thống nguồn. | QLRR.risk_alert |  |  |
| 4 | Risk Alert Config Id | rsk_alert_config_id | BIGINT |  |  | F |  | FK đến cấu hình ngưỡng cảnh báo. | QLRR.risk_alert | alert_config_id |  |
| 5 | Risk Alert Config Code | rsk_alert_config_code | STRING |  |  |  |  | Mã cấu hình cảnh báo. | QLRR.risk_alert | alert_config_id |  |
| 6 | Risk Indicator Id | rsk_ind_id | BIGINT |  |  | F |  | FK đến chỉ tiêu rủi ro (hệ thống lẫn tự tạo sau gộp). | QLRR.risk_alert | indicator_id |  |
| 7 | Risk Indicator Code | rsk_ind_code | STRING |  |  |  |  | Mã chỉ tiêu rủi ro. | QLRR.risk_alert | indicator_id |  |
| 8 | Period Date | prd_dt | DATE |  |  |  |  | Kỳ dữ liệu bị cảnh báo. | QLRR.risk_alert | period_date |  |
| 9 | Current Value | crn_val | STRING |  |  |  |  | Giá trị chỉ tiêu tại kỳ bị cảnh báo. | QLRR.risk_alert | current_value |  |
| 10 | Previous Value | prev_val | STRING | X |  |  |  | Giá trị kỳ trước (dùng để hiển thị, null nếu không xác định). | QLRR.risk_alert | previous_value |  |
| 11 | Change Amount | chg_amt | STRING | X |  |  |  | Giá trị chênh lệch tuyệt đối. | QLRR.risk_alert | change_amount |  |
| 12 | Change Percent | chg_pct | STRING | X |  |  |  | Chênh lệch phần trăm. | QLRR.risk_alert | change_percent |  |
| 13 | Threshold Direction Code | thrs_drc_code | STRING |  |  |  |  | Chiều ngưỡng tại thời điểm phát cảnh báo: 1=Tăng, 2=Giảm, 3=Tăng/Giảm. | QLRR.risk_alert | threshold_direction | Scheme: RISK_ALERT_THRESHOLD_DIRECTION. Snapshot ngưỡng tại thời điểm phát cảnh báo. |
| 14 | Threshold Unit Code | thrs_unit_code | STRING | X |  |  |  | Đơn vị ngưỡng tại thời điểm phát cảnh báo: 1=%, 2=Điểm, … | QLRR.risk_alert | threshold_unit_code | Scheme: RISK_UNIT. Snapshot. |
| 15 | Threshold Value | thrs_val | STRING |  |  |  |  | Giá trị ngưỡng tại thời điểm phát cảnh báo. | QLRR.risk_alert | threshold_value |  |
| 16 | Compare Period Count | cmpr_prd_cnt | INT | X |  |  |  | Số kỳ so sánh tại thời điểm phát cảnh báo. | QLRR.risk_alert | compare_period_time |  |
| 17 | Alert Message | alert_msg | STRING | X |  |  |  | Nội dung thông báo cảnh báo (đã render từ template). | QLRR.risk_alert | alert_message |  |
| 18 | Triggered At | triggered_at | TIMESTAMP |  |  |  |  | Thời điểm phát sinh cảnh báo. | QLRR.risk_alert | triggered_at |  |
| 19 | Triggered By Schedule Id | triggered_by_shd_id | BIGINT | X |  | F |  | FK đến lịch đồng bộ đã kích hoạt cảnh báo. Nullable khi alert thủ công. | QLRR.risk_alert | triggered_by_job_id |  |
| 20 | Triggered By Schedule Code | triggered_by_shd_code | STRING | X |  |  |  | Mã lịch đồng bộ đã kích hoạt cảnh báo. | QLRR.risk_alert | triggered_by_job_id |  |
| 21 | Handler User Id | handler_usr_id | STRING | X |  |  |  | User ID người được giao xử lý cảnh báo (denormalized). | QLRR.risk_alert | handler_user_id |  |
| 22 | Handler User Name | handler_usr_nm | STRING | X |  |  |  | Tên người được giao xử lý cảnh báo (denormalized). | QLRR.risk_alert | handler_user_name |  |
| 23 | Alert Status Code | alert_st_code | STRING |  |  |  |  | Trạng thái cảnh báo: 0=Chưa xử lý, 1=Đang xử lý, 2=Đã xử lý, 3=Đã huỷ/Đã bỏ qua. | QLRR.risk_alert | status | Scheme: RISK_ALERT_STATUS. |
| 24 | Assigned At | asgn_at | TIMESTAMP | X |  |  |  | Thời điểm phân công xử lý cảnh báo. | QLRR.risk_alert | assigned_at |  |


#### 2.{IDX}.11.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Risk Alert Id | rsk_alert_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Risk Alert Config Id | rsk_alert_config_id | Risk Alert Config | Risk Alert Config Id | rsk_alert_config_id |
| Risk Indicator Id | rsk_ind_id | Risk Indicator | Risk Indicator Id | rsk_ind_id |
| Triggered By Schedule Id | triggered_by_shd_id | Risk Indicator Schedule | Risk Indicator Schedule Id | rsk_ind_shd_id |




### 2.{IDX}.12 Bảng Risk Report File

- **Mô tả:** Metadata file đính kèm báo cáo rủi ro trong đợt upload. Grain: 1 file. FK → Risk Report Upload Batch.
- **Tên vật lý:** rsk_rpt_file
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Risk Report File Id | rsk_rpt_file_id | BIGINT |  | X | P |  | Khóa đại diện cho file báo cáo đính kèm. | QLRR.risk_report_file |  |  |
| 2 | Risk Report File Code | rsk_rpt_file_code | STRING |  |  |  |  | Mã định danh file báo cáo. BK. Map từ PK bảng nguồn. | QLRR.risk_report_file | id | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'QLRR.risk_report_file' | Mã hệ thống nguồn. | QLRR.risk_report_file |  |  |
| 4 | Risk Report Upload Batch Id | rsk_rpt_upload_btch_id | BIGINT |  |  | F |  | FK đến đợt upload báo cáo. | QLRR.risk_report_file | batch_id |  |
| 5 | Risk Report Upload Batch Code | rsk_rpt_upload_btch_code | STRING |  |  |  |  | Mã đợt upload báo cáo. | QLRR.risk_report_file | batch_id |  |
| 6 | File Name | file_nm | STRING |  |  |  |  | Tên file hiển thị (VD: Báo cáo TTCK Q4-2025.docx). | QLRR.risk_report_file | file_name |  |
| 7 | File Path | file_path | STRING |  |  |  |  | Đường dẫn lưu file trên hệ thống (filesystem hoặc object storage). | QLRR.risk_report_file | file_path |  |
| 8 | File Size Bytes | file_sz_bytes | INT | X |  |  |  | Dung lượng file tính bằng bytes. | QLRR.risk_report_file | file_size |  |
| 9 | File Type Code | file_tp_code | STRING | X |  |  |  | Loại file: DOCX, XLSX, PDF, … | QLRR.risk_report_file | file_type | Scheme: RISK_FILE_TYPE. |
| 10 | Uploaded At | uploaded_at | TIMESTAMP |  |  |  |  | Thời điểm upload file. | QLRR.risk_report_file | uploaded_at |  |
| 11 | Uploaded By Id | uploaded_by_id | STRING | X |  |  |  | User ID người nộp file (denormalized). | QLRR.risk_report_file | uploaded_by_id |  |


#### 2.{IDX}.12.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Risk Report File Id | rsk_rpt_file_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Risk Report Upload Batch Id | rsk_rpt_upload_btch_id | Risk Report Upload Batch | Risk Report Upload Batch Id | rsk_rpt_upload_btch_id |




### 2.{IDX}.13 Bảng Risk Alert Resolution

- **Mô tả:** Bản ghi xử lý chi tiết cho cảnh báo rủi ro (giải trình hoặc không). Grain: 1 lần xử lý. Append-only. FK → Risk Alert.
- **Tên vật lý:** rsk_alert_rsl
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Risk Alert Resolution Id | rsk_alert_rsl_id | BIGINT |  | X | P |  | Khóa đại diện cho bản ghi xử lý cảnh báo. | QLRR.risk_alert_resolution |  |  |
| 2 | Risk Alert Resolution Code | rsk_alert_rsl_code | STRING |  |  |  |  | Mã định danh bản ghi xử lý. BK. Map từ PK bảng nguồn. | QLRR.risk_alert_resolution | id | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'QLRR.risk_alert_resolution' | Mã hệ thống nguồn. | QLRR.risk_alert_resolution |  |  |
| 4 | Risk Alert Id | rsk_alert_id | BIGINT |  |  | F |  | FK đến cảnh báo liên quan. | QLRR.risk_alert_resolution | alert_id |  |
| 5 | Risk Alert Code | rsk_alert_code | STRING |  |  |  |  | Mã cảnh báo liên quan. | QLRR.risk_alert_resolution | alert_id |  |
| 6 | Resolution Type Code | rsl_tp_code | STRING |  |  |  |  | Loại xử lý cảnh báo: 1=Quick (không giải trình), 2=Detailed (có giải trình). | QLRR.risk_alert_resolution | resolution_type | Scheme: RISK_ALERT_RESOLUTION_TYPE. |
| 7 | Explanation Content | explanation_cntnt | STRING | X |  |  |  | Nội dung giải trình chi tiết (chỉ khi resolution_type=2). | QLRR.risk_alert_resolution | explanation_content |  |
| 8 | Resolved At | rslv_at | TIMESTAMP |  |  |  |  | Thời điểm xử lý cảnh báo. | QLRR.risk_alert_resolution | resolved_at |  |
| 9 | Resolved By Id | rslv_by_id | STRING |  |  |  |  | User ID người xử lý cảnh báo (denormalized). | QLRR.risk_alert_resolution | resolved_by_id |  |
| 10 | Resolved By Name | rslv_by_nm | STRING |  |  |  |  | Tên người xử lý cảnh báo (denormalized). | QLRR.risk_alert_resolution | resolved_by_name |  |


#### 2.{IDX}.13.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Risk Alert Resolution Id | rsk_alert_rsl_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Risk Alert Id | rsk_alert_id | Risk Alert | Risk Alert Id | rsk_alert_id |




### 2.{IDX}.14 Bảng Risk Alert Resolution File

- **Mô tả:** File đính kèm giải trình cho bản ghi xử lý cảnh báo. Grain: 1 file. FK → Risk Alert Resolution.
- **Tên vật lý:** rsk_alert_rsl_file
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Risk Alert Resolution File Id | rsk_alert_rsl_file_id | BIGINT |  | X | P |  | Khóa đại diện cho file đính kèm giải trình cảnh báo. | QLRR.risk_alert_resolution_file |  |  |
| 2 | Risk Alert Resolution File Code | rsk_alert_rsl_file_code | STRING |  |  |  |  | Mã định danh file giải trình. BK. Map từ PK bảng nguồn. | QLRR.risk_alert_resolution_file | id | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'QLRR.risk_alert_resolution_file' | Mã hệ thống nguồn. | QLRR.risk_alert_resolution_file |  |  |
| 4 | Risk Alert Resolution Id | rsk_alert_rsl_id | BIGINT |  |  | F |  | FK đến bản ghi xử lý giải trình. | QLRR.risk_alert_resolution_file | resolution_id |  |
| 5 | Risk Alert Resolution Code | rsk_alert_rsl_code | STRING |  |  |  |  | Mã bản ghi xử lý giải trình. | QLRR.risk_alert_resolution_file | resolution_id |  |
| 6 | File Name | file_nm | STRING |  |  |  |  | Tên file giải trình. | QLRR.risk_alert_resolution_file | file_name |  |
| 7 | File Path | file_path | STRING |  |  |  |  | Đường dẫn lưu file giải trình trên hệ thống. | QLRR.risk_alert_resolution_file | file_path |  |
| 8 | File Size Bytes | file_sz_bytes | INT | X |  |  |  | Dung lượng file tính bằng bytes. | QLRR.risk_alert_resolution_file | file_size |  |
| 9 | File Type Code | file_tp_code | STRING | X |  |  |  | Loại file giải trình: PDF, DOCX, XLSX, PNG, JPG, … | QLRR.risk_alert_resolution_file | file_type | Scheme: RISK_FILE_TYPE. Dùng chung với Risk Report File (Tier 3 — HLD Tier 4 note). |
| 10 | Uploaded At | uploaded_at | TIMESTAMP |  |  |  |  | Thời điểm upload file giải trình. | QLRR.risk_alert_resolution_file | uploaded_at |  |
| 11 | Uploaded By Id | uploaded_by_id | STRING | X |  |  |  | User ID người upload file giải trình (denormalized). | QLRR.risk_alert_resolution_file | uploaded_by_id |  |


#### 2.{IDX}.14.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Risk Alert Resolution File Id | rsk_alert_rsl_file_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Risk Alert Resolution Id | rsk_alert_rsl_id | Risk Alert Resolution | Risk Alert Resolution Id | rsk_alert_rsl_id |




### 2.{IDX}.15 Bảng Risk Alert History

- **Mô tả:** Dòng thời gian sự kiện trong vòng đời cảnh báo (phát sinh / xử lý). Grain: 1 sự kiện nghiệp vụ. Append-only. FK → Risk Alert.
- **Tên vật lý:** rsk_alert_hist
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Risk Alert History Id | rsk_alert_hist_id | BIGINT |  | X | P |  | Khóa đại diện cho bản ghi lịch sử sự kiện cảnh báo. | QLRR.risk_alert_history |  |  |
| 2 | Risk Alert History Code | rsk_alert_hist_code | STRING |  |  |  |  | Mã định danh bản ghi lịch sử. BK. Map từ PK bảng nguồn. | QLRR.risk_alert_history | id | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'QLRR.risk_alert_history' | Mã hệ thống nguồn. | QLRR.risk_alert_history |  |  |
| 4 | Risk Alert Id | rsk_alert_id | BIGINT |  |  | F |  | FK đến cảnh báo liên quan. | QLRR.risk_alert_history | alert_id |  |
| 5 | Risk Alert Code | rsk_alert_code | STRING |  |  |  |  | Mã cảnh báo liên quan. | QLRR.risk_alert_history | alert_id |  |
| 6 | Risk Alert Resolution Id | rsk_alert_rsl_id | BIGINT | X |  | F |  | FK đến bản ghi xử lý liên quan. Nullable — event_type=1 (phát sinh cảnh báo) chưa có resolution. | QLRR.risk_alert_history | resolution_id |  |
| 7 | Risk Alert Resolution Code | rsk_alert_rsl_code | STRING | X |  |  |  | Mã bản ghi xử lý liên quan. | QLRR.risk_alert_history | resolution_id |  |
| 8 | Event Type Code | ev_tp_code | STRING |  |  |  |  | Loại sự kiện: 1=Xảy ra cảnh báo, 2=Xử lý không giải trình, 3=Xử lý có giải trình. | QLRR.risk_alert_history | event_type | Scheme: RISK_ALERT_EVENT_TYPE. |
| 9 | Event Time | ev_tm | TIMESTAMP |  |  |  |  | Thời gian xảy ra sự kiện trong vòng đời cảnh báo. | QLRR.risk_alert_history | event_time |  |
| 10 | Event Title | ev_ttl | STRING | X |  |  |  | Tiêu đề sự kiện. | QLRR.risk_alert_history | event_title |  |
| 11 | Event Description | ev_dsc | STRING | X |  |  |  | Mô tả chi tiết sự kiện. | QLRR.risk_alert_history | event_description |  |
| 12 | Event User Id | ev_usr_id | STRING | X |  |  |  | User ID người thực hiện sự kiện (denormalized). | QLRR.risk_alert_history | event_user_id |  |
| 13 | Event User Name | ev_usr_nm | STRING | X |  |  |  | Tên người thực hiện sự kiện (denormalized). | QLRR.risk_alert_history | event_user_name |  |


#### 2.{IDX}.15.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Risk Alert History Id | rsk_alert_hist_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Risk Alert Id | rsk_alert_id | Risk Alert | Risk Alert Id | rsk_alert_id |
| Risk Alert Resolution Id | rsk_alert_rsl_id | Risk Alert Resolution | Risk Alert Resolution Id | rsk_alert_rsl_id |




### 2.{IDX}.16 Bảng Risk Alert Notification

- **Mô tả:** Thông báo cảnh báo gửi từng kênh (Toast/Bell/Email) đến từng người nhận. Grain: 1 thông báo / 1 người. Append-only. FK → Risk Alert.
- **Tên vật lý:** rsk_alert_notf
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Risk Alert Notification Id | rsk_alert_notf_id | BIGINT |  | X | P |  | Khóa đại diện cho bản ghi thông báo cảnh báo. | QLRR.risk_notification |  |  |
| 2 | Risk Alert Notification Code | rsk_alert_notf_code | STRING |  |  |  |  | Mã định danh thông báo. BK. Map từ PK bảng nguồn. | QLRR.risk_notification | id | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'QLRR.risk_notification' | Mã hệ thống nguồn. | QLRR.risk_notification |  |  |
| 4 | Risk Alert Id | rsk_alert_id | BIGINT |  |  | F |  | FK đến cảnh báo liên quan. | QLRR.risk_notification | alert_id |  |
| 5 | Risk Alert Code | rsk_alert_code | STRING |  |  |  |  | Mã cảnh báo liên quan. | QLRR.risk_notification | alert_id |  |
| 6 | Notification Type Code | notf_tp_code | STRING |  |  |  |  | Kênh thông báo: 1=Toast, 2=Bell, 3=Email. | QLRR.risk_notification | notification_type | Scheme: RISK_NOTIFICATION_TYPE. |
| 7 | Recipient User Id | rcpnt_usr_id | STRING | X |  |  |  | User ID người nhận thông báo (cho type=Toast/Bell, denormalized). | QLRR.risk_notification | recipient_user_id |  |
| 8 | Recipient Email | rcpnt_email | STRING | X |  |  |  | Địa chỉ email người nhận (cho type=Email). | QLRR.risk_notification | recipient_email |  |
| 9 | Sent At | snd_at | TIMESTAMP | X |  |  |  | Thời điểm gửi thông báo. | QLRR.risk_notification | sent_at |  |
| 10 | Send Status Code | snd_st_code | STRING |  |  |  |  | Trạng thái gửi: 1=SENT, 2=FAILED. | QLRR.risk_notification | send_status | Scheme: RISK_NOTIFICATION_SEND_STATUS. |
| 11 | Send Error | snd_err | STRING | X |  |  |  | Thông tin lỗi khi gửi thông báo thất bại (nếu có). | QLRR.risk_notification | send_error |  |
| 12 | Read Status Code | rd_st_code | STRING |  |  |  |  | Trạng thái đọc: 0=Chưa đọc, 1=Đã đọc. | QLRR.risk_notification | read_status | Scheme: RISK_NOTIFICATION_READ_STATUS. |


#### 2.{IDX}.16.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Risk Alert Notification Id | rsk_alert_notf_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Risk Alert Id | rsk_alert_id | Risk Alert | Risk Alert Id | rsk_alert_id |




