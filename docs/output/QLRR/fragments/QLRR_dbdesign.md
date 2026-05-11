## QLRR — Phần hệ quản lý rủi ro

### Các mô hình quan hệ dữ liệu

![Mô hình quan hệ dữ liệu QLRR](QLRR/fragments/QLRR_diagram.png)

**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | rsk_alert_rsl | Bản ghi xử lý chi tiết cho cảnh báo rủi ro (giải trình hoặc không). Grain: 1 lần xử lý. Append-only. FK → Risk Alert. |
| 2 | rsk_rpt_upload_btch | Đợt upload file báo cáo rủi ro định kỳ. Grain: 1 đợt upload. FK → Risk Report Type. |
| 3 | rsk_alert_notf | Thông báo cảnh báo gửi từng kênh (Toast/Bell/Email) đến từng người nhận. Grain: 1 thông báo / 1 người. Append-only. FK → Risk Alert. |
| 4 | rsk_alert_config | Cấu hình ngưỡng và quy tắc kích hoạt cảnh báo cho từng chỉ tiêu rủi ro. Grain: 1 cấu hình / 1 chỉ tiêu. FK → Risk Indicator. |
| 5 | rsk_ind_shd | Cấu hình lịch chạy job đồng bộ chỉ tiêu rủi ro (frequency_type/cron_expression). Grain: 1-1 với Risk Indicator. FK → Risk Indicator. |
| 6 | rsk_alert_rsl_file | File đính kèm giải trình cho bản ghi xử lý cảnh báo. Grain: 1 file. FK → Risk Alert Resolution. |
| 7 | rsk_rpt_file | Metadata file đính kèm báo cáo rủi ro trong đợt upload. Grain: 1 file. FK → Risk Report Upload Batch. |
| 8 | rsk_rpt_tp | Danh mục loại báo cáo rủi ro (Báo cáo nhanh hàng tháng v.v.). Master entity có lifecycle. FK từ Risk Report Upload Batch. |
| 9 | rsk_alert | Bản ghi cảnh báo rủi ro phát sinh khi chỉ tiêu vượt ngưỡng cấu hình. Grain: 1 lần kích hoạt. Append-only. FK → Risk Alert Config + Risk Indicator. |
| 10 | rsk_alert_hist | Dòng thời gian sự kiện trong vòng đời cảnh báo (phát sinh / xử lý). Grain: 1 sự kiện nghiệp vụ. Append-only. FK → Risk Alert. |
| 11 | rsk_ind_val | Giá trị thực tế của chỉ tiêu rủi ro theo từng kỳ (ngày/tháng/quý/năm). Grain: chỉ tiêu × kỳ. Append-only. FK → Risk Indicator. |
| 12 | rsk_ind_val_chg | Lịch sử từng lần thay đổi giá trị chỉ tiêu (SYNC tự động / UPDATE thủ công). Grain: 1 lần thay đổi. Append-only. FK → Risk Indicator. |
| 13 | rsk_ind | Danh mục chỉ tiêu tài chính rủi ro — gộp chỉ tiêu hệ thống (risk_indicator) và tự tạo (risk_indicator_custom). Phân biệt bằng indicator_type_code. indicator_category_id nullable (chỉ tiêu tự tạo không có category). |
| 14 | rsk_ind_cgy | Nhóm phân loại chỉ tiêu tài chính rủi ro theo bộ (trong nước/quốc tế) và nhóm nghiệp vụ (vĩ mô/tiền tệ/thị trường CK). FK nguồn cho Risk Indicator. |




### Bảng rsk_alert_rsl



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rsk_alert_rsl_id | STRING |  | X | P |  | Khóa đại diện cho bản ghi xử lý cảnh báo. |
| 2 | rsk_alert_rsl_code | STRING |  |  |  |  | Mã định danh bản ghi xử lý. BK. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'QLRR.risk_alert_resolution' | Mã hệ thống nguồn. |
| 4 | rsk_alert_id | STRING |  |  | F |  | FK đến cảnh báo liên quan. |
| 5 | rsk_alert_code | STRING |  |  |  |  | Mã cảnh báo liên quan. |
| 6 | rsl_tp_code | STRING |  |  |  |  | Loại xử lý cảnh báo: 1=Quick (không giải trình), 2=Detailed (có giải trình). |
| 7 | explanation_cntnt | STRING | X |  |  |  | Nội dung giải trình chi tiết (chỉ khi resolution_type=2). |
| 8 | rslv_at | TIMESTAMP |  |  |  |  | Thời điểm xử lý cảnh báo. |
| 9 | rslv_by_id | STRING |  |  |  |  | User ID người xử lý cảnh báo (denormalized). |
| 10 | rslv_by_nm | STRING |  |  |  |  | Tên người xử lý cảnh báo (denormalized). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rsk_alert_rsl_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rsk_alert_id | rsk_alert | rsk_alert_id |



#### Index

N/A

#### Trigger

N/A




### Bảng rsk_rpt_upload_btch



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rsk_rpt_upload_btch_id | STRING |  | X | P |  | Khóa đại diện cho đợt upload báo cáo. |
| 2 | rsk_rpt_upload_btch_code | STRING |  |  |  |  | Mã định danh đợt upload. BK. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'QLRR.risk_report_upload_batch' | Mã hệ thống nguồn. |
| 4 | rsk_rpt_tp_id | STRING |  |  | F |  | FK đến loại báo cáo. |
| 5 | rsk_rpt_tp_code | STRING |  |  |  |  | Mã loại báo cáo. |
| 6 | rpt_dt | DATE |  |  |  |  | Thời gian báo cáo (do người dùng chọn khi upload). |
| 7 | file_cnt | INT |  |  |  |  | Số lượng file trong đợt upload. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rsk_rpt_upload_btch_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rsk_rpt_tp_id | rsk_rpt_tp | rsk_rpt_tp_id |



#### Index

N/A

#### Trigger

N/A




### Bảng rsk_alert_notf



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rsk_alert_notf_id | STRING |  | X | P |  | Khóa đại diện cho bản ghi thông báo cảnh báo. |
| 2 | rsk_alert_notf_code | STRING |  |  |  |  | Mã định danh thông báo. BK. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'QLRR.risk_notification' | Mã hệ thống nguồn. |
| 4 | rsk_alert_id | STRING |  |  | F |  | FK đến cảnh báo liên quan. |
| 5 | rsk_alert_code | STRING |  |  |  |  | Mã cảnh báo liên quan. |
| 6 | notf_tp_code | STRING |  |  |  |  | Kênh thông báo: 1=Toast, 2=Bell, 3=Email. |
| 7 | rcpnt_usr_id | STRING | X |  |  |  | User ID người nhận thông báo (cho type=Toast/Bell, denormalized). |
| 8 | rcpnt_email | STRING | X |  |  |  | Địa chỉ email người nhận (cho type=Email). |
| 9 | snd_at | TIMESTAMP | X |  |  |  | Thời điểm gửi thông báo. |
| 10 | snd_st_code | STRING |  |  |  |  | Trạng thái gửi: 1=SENT, 2=FAILED. |
| 11 | snd_err | STRING | X |  |  |  | Thông tin lỗi khi gửi thông báo thất bại (nếu có). |
| 12 | rd_st_code | STRING |  |  |  |  | Trạng thái đọc: 0=Chưa đọc, 1=Đã đọc. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rsk_alert_notf_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rsk_alert_id | rsk_alert | rsk_alert_id |



#### Index

N/A

#### Trigger

N/A




### Bảng rsk_alert_config



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rsk_alert_config_id | STRING |  | X | P |  | Khóa đại diện cho cấu hình ngưỡng cảnh báo chỉ tiêu rủi ro. |
| 2 | rsk_alert_config_code | STRING |  |  |  |  | Mã định danh cấu hình cảnh báo. BK. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'QLRR.risk_alert_config' | Mã hệ thống nguồn. |
| 4 | rsk_ind_id | STRING |  |  | F |  | FK đến chỉ tiêu rủi ro (hệ thống hoặc tự tạo) sau gộp. |
| 5 | rsk_ind_code | STRING |  |  |  |  | Mã chỉ tiêu rủi ro. |
| 6 | thrs_drc_code | STRING |  |  |  |  | Chiều ngưỡng cảnh báo: 1=Tăng, 2=Giảm, 3=Tăng/Giảm. |
| 7 | thrs_unit_code | STRING | X |  |  |  | Đơn vị ngưỡng: 1=%, 2=Điểm, 3=Tỷ VND, 4=Triệu USD, 5=Hợp đồng, 6=Cổ phiếu, 7=Công ty, 8=VND, 9=Số tài khoản, 10=Đơn vị tính. |
| 8 | thrs_val | STRING |  |  |  |  | Giá trị ngưỡng kích hoạt cảnh báo. |
| 9 | cmpr_prd_cnt | INT | X |  |  |  | Số kỳ cần so sánh để đánh giá ngưỡng. |
| 10 | alert_msg_tpl | STRING | X |  |  |  | Nội dung mẫu thông báo cảnh báo. |
| 11 | handler_usr_id | STRING | X |  |  |  | User ID người xử lý chính (denormalized — không có User entity trên Atomic). |
| 12 | handler_usr_nm | STRING | X |  |  |  | Tên người xử lý chính (denormalized). |
| 13 | notf_bell_f | BOOLEAN |  |  |  |  | Hiển thị thông báo chuông: 0=Không, 1=Có. |
| 14 | notf_email_f | BOOLEAN |  |  |  |  | Gửi email cảnh báo: 0=Không, 1=Có. |
| 15 | notf_toast_f | BOOLEAN |  |  |  |  | Thông báo toast: 0=Không, 1=Có. |
| 16 | dspl_ordr | INT | X |  |  |  | Thứ tự hiển thị của cấu hình cảnh báo. |
| 17 | actv_f | BOOLEAN |  |  |  |  | Trạng thái: 0=Không hoạt động, 1=Đang hoạt động. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rsk_alert_config_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rsk_ind_id | rsk_ind | rsk_ind_id |



#### Index

N/A

#### Trigger

N/A




### Bảng rsk_ind_shd



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rsk_ind_shd_id | STRING |  | X | P |  | Khóa đại diện cho lịch đồng bộ chỉ tiêu rủi ro. |
| 2 | rsk_ind_shd_code | STRING |  |  |  |  | Mã định danh lịch đồng bộ. BK. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'QLRR.risk_indicator_schedule' | Mã hệ thống nguồn. |
| 4 | rsk_ind_id | STRING |  |  | F |  | FK đến chỉ tiêu rủi ro. |
| 5 | rsk_ind_code | STRING |  |  |  |  | Mã chỉ tiêu rủi ro. |
| 6 | frq_tp_code | STRING |  |  |  |  | Tần suất chạy job: 1=Giờ, 2=Ngày, 3=Tháng, 4=Quý, 5=Năm. |
| 7 | frq_val | INT | X |  |  |  | Mỗi bao nhiêu đơn vị (VD: mỗi 2 ngày). |
| 8 | strt_tm | TIMESTAMP | X |  |  |  | Ngày giờ bắt đầu chạy job. |
| 9 | nxt_run_tm | TIMESTAMP | X |  |  |  | Lịch chạy tiếp theo (auto-calculated). |
| 10 | last_run_tm | TIMESTAMP | X |  |  |  | Lần chạy gần nhất. |
| 11 | cron_expression | STRING | X |  |  |  | Quartz cron expression định nghĩa lịch chạy. |
| 12 | enabled_f | BOOLEAN |  |  |  |  | Trạng thái kích hoạt job: 0=Không hoạt động, 1=Hoạt động. |
| 13 | tot_run_cnt | INT | X |  |  |  | Số lần job đã chạy (thống kê tích lũy). |
| 14 | last_run_st_code | STRING | X |  |  |  | Kết quả lần chạy gần nhất: SUCCESS, FAILED. |
| 15 | last_err | STRING | X |  |  |  | Thông tin lỗi lần chạy gần nhất (nếu có). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rsk_ind_shd_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rsk_ind_id | rsk_ind | rsk_ind_id |



#### Index

N/A

#### Trigger

N/A




### Bảng rsk_alert_rsl_file



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rsk_alert_rsl_file_id | STRING |  | X | P |  | Khóa đại diện cho file đính kèm giải trình cảnh báo. |
| 2 | rsk_alert_rsl_file_code | STRING |  |  |  |  | Mã định danh file giải trình. BK. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'QLRR.risk_alert_resolution_file' | Mã hệ thống nguồn. |
| 4 | rsk_alert_rsl_id | STRING |  |  | F |  | FK đến bản ghi xử lý giải trình. |
| 5 | rsk_alert_rsl_code | STRING |  |  |  |  | Mã bản ghi xử lý giải trình. |
| 6 | file_nm | STRING |  |  |  |  | Tên file giải trình. |
| 7 | file_path | STRING |  |  |  |  | Đường dẫn lưu file giải trình trên hệ thống. |
| 8 | file_sz_bytes | INT | X |  |  |  | Dung lượng file tính bằng bytes. |
| 9 | file_tp_code | STRING | X |  |  |  | Loại file giải trình: PDF, DOCX, XLSX, PNG, JPG, … |
| 10 | uploaded_at | TIMESTAMP |  |  |  |  | Thời điểm upload file giải trình. |
| 11 | uploaded_by_id | STRING | X |  |  |  | User ID người upload file giải trình (denormalized). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rsk_alert_rsl_file_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rsk_alert_rsl_id | rsk_alert_rsl | rsk_alert_rsl_id |



#### Index

N/A

#### Trigger

N/A




### Bảng rsk_rpt_file



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rsk_rpt_file_id | STRING |  | X | P |  | Khóa đại diện cho file báo cáo đính kèm. |
| 2 | rsk_rpt_file_code | STRING |  |  |  |  | Mã định danh file báo cáo. BK. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'QLRR.risk_report_file' | Mã hệ thống nguồn. |
| 4 | rsk_rpt_upload_btch_id | STRING |  |  | F |  | FK đến đợt upload báo cáo. |
| 5 | rsk_rpt_upload_btch_code | STRING |  |  |  |  | Mã đợt upload báo cáo. |
| 6 | file_nm | STRING |  |  |  |  | Tên file hiển thị (VD: Báo cáo TTCK Q4-2025.docx). |
| 7 | file_path | STRING |  |  |  |  | Đường dẫn lưu file trên hệ thống (filesystem hoặc object storage). |
| 8 | file_sz_bytes | INT | X |  |  |  | Dung lượng file tính bằng bytes. |
| 9 | file_tp_code | STRING | X |  |  |  | Loại file: DOCX, XLSX, PDF, … |
| 10 | uploaded_at | TIMESTAMP |  |  |  |  | Thời điểm upload file. |
| 11 | uploaded_by_id | STRING | X |  |  |  | User ID người nộp file (denormalized). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rsk_rpt_file_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rsk_rpt_upload_btch_id | rsk_rpt_upload_btch | rsk_rpt_upload_btch_id |



#### Index

N/A

#### Trigger

N/A




### Bảng rsk_rpt_tp



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rsk_rpt_tp_id | STRING |  | X | P |  | Khóa đại diện cho loại báo cáo rủi ro. |
| 2 | rsk_rpt_tp_code | STRING |  |  |  |  | Mã loại báo cáo. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'QLRR.risk_report_type' | Mã hệ thống nguồn. |
| 4 | rpt_tp_nm | STRING |  |  |  |  | Tên loại báo cáo. |
| 5 | dsc | STRING | X |  |  |  | Mô tả loại báo cáo. |
| 6 | dspl_ordr | INT | X |  |  |  | Thứ tự hiển thị. |
| 7 | actv_f | BOOLEAN |  |  |  |  | Trạng thái: 0=Không hoạt động, 1=Hoạt động. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rsk_rpt_tp_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng rsk_alert



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rsk_alert_id | STRING |  | X | P |  | Khóa đại diện cho bản ghi cảnh báo rủi ro. |
| 2 | rsk_alert_code | STRING |  |  |  |  | Mã định danh cảnh báo. BK. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'QLRR.risk_alert' | Mã hệ thống nguồn. |
| 4 | rsk_alert_config_id | STRING |  |  | F |  | FK đến cấu hình ngưỡng cảnh báo. |
| 5 | rsk_alert_config_code | STRING |  |  |  |  | Mã cấu hình cảnh báo. |
| 6 | rsk_ind_id | STRING |  |  | F |  | FK đến chỉ tiêu rủi ro (hệ thống lẫn tự tạo sau gộp). |
| 7 | rsk_ind_code | STRING |  |  |  |  | Mã chỉ tiêu rủi ro. |
| 8 | prd_dt | DATE |  |  |  |  | Kỳ dữ liệu bị cảnh báo. |
| 9 | crn_val | STRING |  |  |  |  | Giá trị chỉ tiêu tại kỳ bị cảnh báo. |
| 10 | prev_val | STRING | X |  |  |  | Giá trị kỳ trước (dùng để hiển thị, null nếu không xác định). |
| 11 | chg_amt | STRING | X |  |  |  | Giá trị chênh lệch tuyệt đối. |
| 12 | chg_pct | STRING | X |  |  |  | Chênh lệch phần trăm. |
| 13 | thrs_drc_code | STRING |  |  |  |  | Chiều ngưỡng tại thời điểm phát cảnh báo: 1=Tăng, 2=Giảm, 3=Tăng/Giảm. |
| 14 | thrs_unit_code | STRING | X |  |  |  | Đơn vị ngưỡng tại thời điểm phát cảnh báo: 1=%, 2=Điểm, … |
| 15 | thrs_val | STRING |  |  |  |  | Giá trị ngưỡng tại thời điểm phát cảnh báo. |
| 16 | cmpr_prd_cnt | INT | X |  |  |  | Số kỳ so sánh tại thời điểm phát cảnh báo. |
| 17 | alert_msg | STRING | X |  |  |  | Nội dung thông báo cảnh báo (đã render từ template). |
| 18 | triggered_at | TIMESTAMP |  |  |  |  | Thời điểm phát sinh cảnh báo. |
| 19 | triggered_by_shd_id | STRING | X |  | F |  | FK đến lịch đồng bộ đã kích hoạt cảnh báo. Nullable khi alert thủ công. |
| 20 | triggered_by_shd_code | STRING | X |  |  |  | Mã lịch đồng bộ đã kích hoạt cảnh báo. |
| 21 | handler_usr_id | STRING | X |  |  |  | User ID người được giao xử lý cảnh báo (denormalized). |
| 22 | handler_usr_nm | STRING | X |  |  |  | Tên người được giao xử lý cảnh báo (denormalized). |
| 23 | alert_st_code | STRING |  |  |  |  | Trạng thái cảnh báo: 0=Chưa xử lý, 1=Đang xử lý, 2=Đã xử lý, 3=Đã huỷ/Đã bỏ qua. |
| 24 | asgn_at | TIMESTAMP | X |  |  |  | Thời điểm phân công xử lý cảnh báo. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rsk_alert_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rsk_alert_config_id | rsk_alert_config | rsk_alert_config_id |
| rsk_ind_id | rsk_ind | rsk_ind_id |
| triggered_by_shd_id | rsk_ind_shd | rsk_ind_shd_id |



#### Index

N/A

#### Trigger

N/A




### Bảng rsk_alert_hist



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rsk_alert_hist_id | STRING |  | X | P |  | Khóa đại diện cho bản ghi lịch sử sự kiện cảnh báo. |
| 2 | rsk_alert_hist_code | STRING |  |  |  |  | Mã định danh bản ghi lịch sử. BK. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'QLRR.risk_alert_history' | Mã hệ thống nguồn. |
| 4 | rsk_alert_id | STRING |  |  | F |  | FK đến cảnh báo liên quan. |
| 5 | rsk_alert_code | STRING |  |  |  |  | Mã cảnh báo liên quan. |
| 6 | rsk_alert_rsl_id | STRING | X |  | F |  | FK đến bản ghi xử lý liên quan. Nullable — event_type=1 (phát sinh cảnh báo) chưa có resolution. |
| 7 | rsk_alert_rsl_code | STRING | X |  |  |  | Mã bản ghi xử lý liên quan. |
| 8 | ev_tp_code | STRING |  |  |  |  | Loại sự kiện: 1=Xảy ra cảnh báo, 2=Xử lý không giải trình, 3=Xử lý có giải trình. |
| 9 | ev_tm | TIMESTAMP |  |  |  |  | Thời gian xảy ra sự kiện trong vòng đời cảnh báo. |
| 10 | ev_ttl | STRING | X |  |  |  | Tiêu đề sự kiện. |
| 11 | ev_dsc | STRING | X |  |  |  | Mô tả chi tiết sự kiện. |
| 12 | ev_usr_id | STRING | X |  |  |  | User ID người thực hiện sự kiện (denormalized). |
| 13 | ev_usr_nm | STRING | X |  |  |  | Tên người thực hiện sự kiện (denormalized). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rsk_alert_hist_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rsk_alert_id | rsk_alert | rsk_alert_id |
| rsk_alert_rsl_id | rsk_alert_rsl | rsk_alert_rsl_id |



#### Index

N/A

#### Trigger

N/A




### Bảng rsk_ind_val



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rsk_ind_val_id | STRING |  | X | P |  | Khóa đại diện cho giá trị chỉ tiêu rủi ro theo kỳ. |
| 2 | rsk_ind_val_code | STRING |  |  |  |  | Mã định danh giá trị chỉ tiêu. BK. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'QLRR.risk_indicator_value' | Mã hệ thống nguồn. |
| 4 | rsk_ind_id | STRING |  |  | F |  | FK đến chỉ tiêu rủi ro (hệ thống lẫn tự tạo — QLRR-P01 confirmed). |
| 5 | rsk_ind_code | STRING |  |  |  |  | Mã chỉ tiêu rủi ro. |
| 6 | prd_tp_code | STRING |  |  |  |  | Kỳ dữ liệu: 1=Ngày, 2=Tháng, 3=Quý, 4=Năm. |
| 7 | prd_val | INT | X |  |  |  | Số thứ tự kỳ trong năm. VD: period_type=Tháng, period_date=12/03/2026 → period_value=3; period_type=Quý, period_date=12/03/2026 → period_value=1. |
| 8 | prd_yr | INT |  |  |  |  | Năm của kỳ dữ liệu. |
| 9 | prd_dt | DATE |  |  |  |  | Ngày đại diện cho kỳ dữ liệu. |
| 10 | prd_lbl | STRING | X |  |  |  | Chuỗi hiển thị kỳ (VD: 2024-01, 2024-Q1, 2024). |
| 11 | val | STRING |  |  |  |  | Giá trị chỉ tiêu tại kỳ này. |
| 12 | unit_code | STRING | X |  |  |  | Đơn vị đo lường: 1=%, 2=Điểm, 3=Tỷ VND, 4=Triệu USD, 5=Hợp đồng, 6=Cổ phiếu, 7=Công ty, 8=VND, 9=Số tài khoản, 10=Đơn vị tính. |
| 13 | data_src_code | STRING | X |  |  |  | Nguồn dữ liệu: 1=Investing, 2=Tổng cục Thống kê, 3=Ngân hàng Nhà nước, 4=Nội bộ, 5=HNX, 6=VSDC. |
| 14 | data_orig_code | STRING |  |  |  |  | Nguồn gốc giá trị: 1=API CSDL tập trung, 2=User chỉnh sửa. |
| 15 | cmlv_val | STRING | X |  |  |  | Giá trị luỹ kế. [QLRR-P02 Open]: cơ sở luỹ kế chưa xác định (từ đầu năm hay từ đầu kỳ). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rsk_ind_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rsk_ind_id | rsk_ind | rsk_ind_id |



#### Index

N/A

#### Trigger

N/A




### Bảng rsk_ind_val_chg



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rsk_ind_val_chg_id | STRING |  | X | P |  | Khóa đại diện cho bản ghi thay đổi giá trị chỉ tiêu. |
| 2 | rsk_ind_val_chg_code | STRING |  |  |  |  | Mã định danh bản ghi thay đổi. BK. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'QLRR.risk_indicator_value_history' | Mã hệ thống nguồn. |
| 4 | rsk_ind_id | STRING |  |  | F |  | FK đến chỉ tiêu rủi ro. |
| 5 | rsk_ind_code | STRING |  |  |  |  | Mã chỉ tiêu rủi ro. |
| 6 | old_val | STRING | X |  |  |  | Giá trị cũ trước thay đổi (null nếu là lần tạo mới). |
| 7 | new_val | STRING | X |  |  |  | Giá trị mới sau thay đổi (null nếu là xóa). |
| 8 | unit_code | STRING | X |  |  |  | Đơn vị đo lường tại thời điểm thay đổi: 1=%, 2=Điểm, 3=Tỷ VND, … |
| 9 | data_src_code | STRING | X |  |  |  | Nguồn dữ liệu sau thay đổi: 1=Investing, 2=Tổng cục Thống kê, 3=Ngân hàng Nhà nước, 4=Nội bộ, 5=HNX, 6=VSDC. |
| 10 | data_orig_code | STRING |  |  |  |  | Nguồn gốc dữ liệu sau thay đổi: 1=API CSDL tập trung, 2=User chỉnh sửa. |
| 11 | chg_tp_code | STRING |  |  |  |  | Loại thay đổi: SYNC=đồng bộ tự động, UPDATE=chỉnh sửa thủ công. |
| 12 | chg_by_id | STRING | X |  |  |  | User ID người thực hiện thay đổi (denormalized). |
| 13 | chg_by_nm | STRING | X |  |  |  | Tên người thực hiện thay đổi (denormalized). |
| 14 | chg_at | TIMESTAMP |  |  |  |  | Thời điểm ghi nhận thay đổi. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rsk_ind_val_chg_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rsk_ind_id | rsk_ind | rsk_ind_id |



#### Index

N/A

#### Trigger

N/A




### Bảng rsk_ind



#### Từ QLRR.risk_indicator

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rsk_ind_id | STRING |  | X | P |  | Khóa đại diện cho chỉ tiêu rủi ro (hệ thống hoặc tự tạo). |
| 2 | rsk_ind_code | STRING |  |  |  |  | Mã định danh duy nhất của chỉ tiêu. BK. Hệ thống: map từ risk_indicator.id; Tự tạo: map từ risk_indicator_custom.id với prefix 'CUS_'. |
| 3 | src_stm_code | STRING |  |  |  | 'QLRR.risk_indicator' | Mã hệ thống nguồn. |
| 4 | ind_tp_code | STRING |  |  |  |  | Phân loại chỉ tiêu sau gộp: 1=Hệ thống (risk_indicator), 2=Tự tạo (risk_indicator_custom). |
| 5 | ind_nm | STRING |  |  |  |  | Tên chỉ tiêu (VD: GDP, CPI, Chỉ số VNIndex, Lạm phát Mỹ). |
| 6 | ind_set_code | STRING | X |  |  |  | Bộ chỉ tiêu: 1=Trong nước, 2=Quốc tế. Chỉ áp dụng cho chỉ tiêu hệ thống. |
| 7 | bsn_key | STRING | X |  |  |  | Mã nghiệp vụ chỉ tiêu hệ thống (VD: GDP_VN, CPI_VN). Chỉ có ở chỉ tiêu hệ thống. |
| 8 | rsk_ind_cgy_id | STRING | X |  | F |  | FK đến nhóm chỉ tiêu rủi ro. |
| 9 | rsk_ind_cgy_code | STRING | X |  |  |  | Mã nhóm chỉ tiêu rủi ro. |
| 10 | unit_code | STRING | X |  |  |  | Đơn vị mặc định: 1=%, 2=Điểm, 3=Tỷ VND, 4=Triệu USD, 5=Hợp đồng, 6=Cổ phiếu, 7=Công ty, 8=VND, 9=Số tài khoản, 10=Đơn vị tính. |
| 11 | data_src_code | STRING | X |  |  |  | Nguồn dữ liệu mặc định: 1=Investing, 2=Tổng cục Thống kê, 3=Ngân hàng Nhà nước, 4=Nội bộ, 5=HNX, 6=VSDC. |
| 12 | prd_tp_code | STRING | X |  |  |  | Tần suất chỉ tiêu: 1=Ngày, 2=Tháng, 3=Quý, 4=Năm. |
| 13 | last_sync_tm | TIMESTAMP | X |  |  |  | Thời điểm đồng bộ dữ liệu gần nhất. Chỉ áp dụng cho chỉ tiêu hệ thống. |
| 14 | dspl_ordr | INT | X |  |  |  | Thứ tự hiển thị của chỉ tiêu trên màn hình. |
| 15 | dspl_f | BOOLEAN | X |  |  |  | Có hiển thị trên màn hình không: 0=Không, 1=Có. Chỉ áp dụng cho chỉ tiêu hệ thống. |
| 16 | actv_f | BOOLEAN |  |  |  |  | Trạng thái hoạt động: 0=Không hoạt động, 1=Hoạt động. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rsk_ind_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rsk_ind_cgy_id | rsk_ind_cgy | rsk_ind_cgy_id |



**Index:** N/A

**Trigger:** N/A


#### Từ QLRR.risk_indicator_custom

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rsk_ind_id | STRING |  | X | P |  | Khóa đại diện cho chỉ tiêu rủi ro (hệ thống hoặc tự tạo). |
| 2 | rsk_ind_code | STRING |  |  |  |  | Mã định danh duy nhất của chỉ tiêu. BK. Hệ thống: map từ risk_indicator.id; Tự tạo: map từ risk_indicator_custom.id với prefix 'CUS_'. |
| 3 | src_stm_code | STRING |  |  |  | 'QLRR.risk_indicator_custom' | Mã hệ thống nguồn. |
| 4 | ind_tp_code | STRING |  |  |  |  | Phân loại chỉ tiêu sau gộp: 1=Hệ thống (risk_indicator), 2=Tự tạo (risk_indicator_custom). |
| 5 | ind_nm | STRING |  |  |  |  | Tên chỉ tiêu (VD: GDP, CPI, Chỉ số VNIndex, Lạm phát Mỹ). |
| 6 | ind_set_code | STRING | X |  |  |  | Bộ chỉ tiêu: 1=Trong nước, 2=Quốc tế. Chỉ áp dụng cho chỉ tiêu hệ thống. |
| 7 | bsn_key | STRING | X |  |  |  | Mã nghiệp vụ chỉ tiêu hệ thống (VD: GDP_VN, CPI_VN). Chỉ có ở chỉ tiêu hệ thống. |
| 8 | rsk_ind_cgy_id | STRING | X |  | F |  | FK đến nhóm chỉ tiêu rủi ro. |
| 9 | rsk_ind_cgy_code | STRING | X |  |  |  | Mã nhóm chỉ tiêu rủi ro. |
| 10 | unit_code | STRING | X |  |  |  | Đơn vị mặc định: 1=%, 2=Điểm, 3=Tỷ VND, 4=Triệu USD, 5=Hợp đồng, 6=Cổ phiếu, 7=Công ty, 8=VND, 9=Số tài khoản, 10=Đơn vị tính. |
| 11 | data_src_code | STRING | X |  |  |  | Nguồn dữ liệu mặc định: 1=Investing, 2=Tổng cục Thống kê, 3=Ngân hàng Nhà nước, 4=Nội bộ, 5=HNX, 6=VSDC. |
| 12 | prd_tp_code | STRING | X |  |  |  | Tần suất chỉ tiêu: 1=Ngày, 2=Tháng, 3=Quý, 4=Năm. |
| 13 | last_sync_tm | TIMESTAMP | X |  |  |  | Thời điểm đồng bộ dữ liệu gần nhất. Chỉ áp dụng cho chỉ tiêu hệ thống. |
| 14 | dspl_ordr | INT | X |  |  |  | Thứ tự hiển thị của chỉ tiêu trên màn hình. |
| 15 | dspl_f | BOOLEAN | X |  |  |  | Có hiển thị trên màn hình không: 0=Không, 1=Có. Chỉ áp dụng cho chỉ tiêu hệ thống. |
| 16 | actv_f | BOOLEAN |  |  |  |  | Trạng thái hoạt động: 0=Không hoạt động, 1=Hoạt động. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rsk_ind_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rsk_ind_cgy_id | rsk_ind_cgy | rsk_ind_cgy_id |



**Index:** N/A

**Trigger:** N/A





### Bảng rsk_ind_cgy



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rsk_ind_cgy_id | STRING |  | X | P |  | Khóa đại diện cho nhóm chỉ tiêu rủi ro. |
| 2 | rsk_ind_cgy_code | STRING |  |  |  |  | Mã nhóm chỉ tiêu (VD: MACRO, MONETARY, STOCK_MARKET). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'QLRR.risk_indicator_category' | Mã hệ thống nguồn. |
| 4 | ind_set_code | STRING |  |  |  |  | Bộ chỉ tiêu: 1=Trong nước, 2=Quốc tế. Attribute bổ sung — không phân biệt entity. |
| 5 | cgy_nm | STRING |  |  |  |  | Tên nhóm chỉ tiêu (VD: Yếu tố vĩ mô). |
| 6 | actv_f | BOOLEAN |  |  |  |  | Trạng thái hoạt động: 0=Không hoạt động, 1=Hoạt động. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rsk_ind_cgy_id |



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
