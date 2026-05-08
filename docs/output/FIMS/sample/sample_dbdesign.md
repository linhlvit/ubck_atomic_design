## 2.1 FIMS — Hệ thống quản lý giám sát nhà đầu tư nước ngoài

### 2.1.1 Các mô hình quan hệ dữ liệu

- DBML tổng hợp (tất cả bảng): [`FIMS.dbml`](FIMS.dbml) — paste vào https://dbdiagram.io để render.
- Diagram theo mảng nghiệp vụ:
  - **UID03 — Đối tượng gửi báo cáo**: [`FIMS_UID03.dbml`](FIMS_UID03.dbml)


**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | stk_exg | Sở giao dịch chứng khoán - thành viên thị trường trong hệ thống FIMS (HNX, HOSE). |
| 2 | depst_cntr | Trung tâm lưu ký chứng khoán quốc gia - thành viên thị trường trong hệ thống FIMS (VSD). |




### 2.1.2 Bảng stk_exg



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | stk_exg_id | BIGINT |  | X | P |  | Khóa đại diện cho Sở giao dịch chứng khoán. |
| 2 | stk_exg_code | STRING |  |  |  |  | Mã định danh Sở giao dịch. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.STOCKEXCHANGE' | Mã nguồn dữ liệu. |
| 4 | cty_of_rgst_id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký của Sở giao dịch. |
| 5 | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. |
| 6 | full_nm | STRING |  |  |  |  | Tên Sở giao dịch. |
| 7 | en_nm | STRING | X |  |  |  | Tên tiếng Anh. |
| 8 | abr | STRING | X |  |  |  | Tên viết tắt. |
| 9 | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. |
| 10 | dsc | STRING | X |  |  |  | Ghi chú. |
| 11 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 12 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 13 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### 2.1.2.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| stk_exg_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| cty_of_rgst_id | geo | geo_id |






### 2.1.3 Bảng depst_cntr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | depst_cntr_id | BIGINT |  | X | P |  | Khóa đại diện cho Trung tâm lưu ký chứng khoán. |
| 2 | depst_cntr_code | STRING |  |  |  |  | Mã định danh Trung tâm lưu ký. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.DEPOSITORYCENTER' | Mã nguồn dữ liệu. |
| 4 | cty_of_rgst_id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký của Trung tâm lưu ký. |
| 5 | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. |
| 6 | full_nm | STRING |  |  |  |  | Tên Trung tâm lưu ký. |
| 7 | en_nm | STRING | X |  |  |  | Tên tiếng Anh. |
| 8 | abr | STRING | X |  |  |  | Tên viết tắt. |
| 9 | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. |
| 10 | dsc | STRING | X |  |  |  | Ghi chú. |
| 11 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 12 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 13 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### 2.1.3.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| depst_cntr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| cty_of_rgst_id | geo | geo_id |





