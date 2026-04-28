## 2.1 FIMS — Hệ thống quản lý giám sát nhà đầu tư nước ngoài

### 2.1.1 Các mô hình quan hệ dữ liệu

- DBML tổng hợp (tất cả bảng): [`FIMS.dbml`](FIMS.dbml) — paste vào https://dbdiagram.io để render.
- Diagram theo mảng nghiệp vụ:
  - **UID03 — Đối tượng gửi báo cáo**: [`FIMS_UID03.dbml`](FIMS_UID03.dbml)


**Danh sách bảng:**

| STT | Thực thể | Tên bảng | Mô tả |
|---|---|---|---|
| 1 | Stock Exchange | stk_exg | So giao dich chung khoan - thanh vien thi truong trong he thong FIMS (HNX, HOSE). |
| 2 | Depository Center | depst_cntr | Trung tam luu ky chung khoan quoc gia - thanh vien thi truong trong he thong FIMS (VSD). |



### 2.1.2 Bảng Stock Exchange

- **Mô tả:** So giao dich chung khoan - thanh vien thi truong trong he thong FIMS (HNX, HOSE).
- **Tên vật lý:** stk_exg
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Stock Exchange Id | stk_exg_id | BIGINT |  | X | P |  | Khóa đại diện cho Sở giao dịch chứng khoán. | FIMS | STOCKEXCHANGE |  | PK surrogate. |
| 2 | Stock Exchange Code | stk_exg_code | STRING |  |  |  |  | Mã định danh Sở giao dịch. Map từ PK bảng nguồn. | FIMS | STOCKEXCHANGE | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS' | Mã nguồn dữ liệu. | FIMS | STOCKEXCHANGE |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Country of Registration Id | cty_of_rgst_id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký của Sở giao dịch. | FIMS | STOCKEXCHANGE | NaId | FK target: Geographic Area.Geographic Area Id. ID quốc gia lấy từ bảng NATIONAL. |
| 5 | Country of Registration Code | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. | FIMS | STOCKEXCHANGE | NaId | Lookup pair: Geographic Area.Geographic Area Code. Pair with Country of Registration Id. |
| 6 | Full Name | full_nm | STRING |  |  |  |  | Tên Sở giao dịch. | FIMS | STOCKEXCHANGE | Name |  |
| 7 | English Name | english_nm | STRING | X |  |  |  | Tên tiếng Anh. | FIMS | STOCKEXCHANGE | EName |  |
| 8 | Abbreviation | abr | STRING | X |  |  |  | Tên viết tắt. | FIMS | STOCKEXCHANGE | ShortName |  |
| 9 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. | FIMS | STOCKEXCHANGE | StatusId | Scheme: LIFE_CYCLE_STATUS. |
| 10 | Description | dsc | STRING | X |  |  |  | Ghi chú. | FIMS | STOCKEXCHANGE | Description |  |
| 11 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FIMS | STOCKEXCHANGE | CreatedBy | Mã người dùng hệ thống — denormalized. |
| 12 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FIMS | STOCKEXCHANGE | DateCreated |  |
| 13 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FIMS | STOCKEXCHANGE | DateModified |  |


#### 2.1.2.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Stock Exchange Id | stk_exg_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Country of Registration Id | cty_of_rgst_id | Geographic Area | Geographic Area Id | geo_id |




### 2.1.3 Bảng Depository Center

- **Mô tả:** Trung tam luu ky chung khoan quoc gia - thanh vien thi truong trong he thong FIMS (VSD).
- **Tên vật lý:** depst_cntr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Depository Center Id | depst_cntr_id | BIGINT |  | X | P |  | Khóa đại diện cho Trung tâm lưu ký chứng khoán. | FIMS | DEPOSITORYCENTER |  | PK surrogate. |
| 2 | Depository Center Code | depst_cntr_code | STRING |  |  |  |  | Mã định danh Trung tâm lưu ký. Map từ PK bảng nguồn. | FIMS | DEPOSITORYCENTER | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS' | Mã nguồn dữ liệu. | FIMS | DEPOSITORYCENTER |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Country of Registration Id | cty_of_rgst_id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký của Trung tâm lưu ký. | FIMS | DEPOSITORYCENTER | NaId | FK target: Geographic Area.Geographic Area Id. ID quốc gia lấy từ bảng NATIONAL. |
| 5 | Country of Registration Code | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. | FIMS | DEPOSITORYCENTER | NaId | Lookup pair: Geographic Area.Geographic Area Code. Pair with Country of Registration Id. |
| 6 | Full Name | full_nm | STRING |  |  |  |  | Tên Trung tâm lưu ký. | FIMS | DEPOSITORYCENTER | Name |  |
| 7 | English Name | english_nm | STRING | X |  |  |  | Tên tiếng Anh. | FIMS | DEPOSITORYCENTER | EName |  |
| 8 | Abbreviation | abr | STRING | X |  |  |  | Tên viết tắt. | FIMS | DEPOSITORYCENTER | ShortName |  |
| 9 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. | FIMS | DEPOSITORYCENTER | StatusId | Scheme: LIFE_CYCLE_STATUS. |
| 10 | Description | dsc | STRING | X |  |  |  | Ghi chú. | FIMS | DEPOSITORYCENTER | Description |  |
| 11 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FIMS | DEPOSITORYCENTER | CreatedBy | Mã người dùng hệ thống — denormalized. |
| 12 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FIMS | DEPOSITORYCENTER | DateCreated |  |
| 13 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FIMS | DEPOSITORYCENTER | DateModified |  |


#### 2.1.3.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Depository Center Id | depst_cntr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Country of Registration Id | cty_of_rgst_id | Geographic Area | Geographic Area Id | geo_id |




