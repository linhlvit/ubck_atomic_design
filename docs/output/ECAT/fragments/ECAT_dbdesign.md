## 2.{IDX} ECAT — 

### 2.{IDX}.1 Các mô hình quan hệ dữ liệu

- DBML tổng hợp (tất cả bảng): [`ECAT.dbml`](ECAT.dbml) — paste vào https://dbdiagram.io để render.
- Diagram theo mảng nghiệp vụ:
  - **UID01 — Danh mục địa lý hành chính**: [`ECAT_UID01.dbml`](ECAT_UID01.dbml)
  - **UID03 — Danh mục tiền tệ**: [`ECAT_UID03.dbml`](ECAT_UID03.dbml)
  - **UID04 — Danh mục chứng khoán & thị trường**: [`ECAT_UID04.dbml`](ECAT_UID04.dbml)
  - **UID08 — Danh mục lịch & ngày nghỉ**: [`ECAT_UID08.dbml`](ECAT_UID08.dbml)


**Danh sách bảng:**

| STT | Thực thể | Tên bảng | Mô tả |
|---|---|---|---|
| 1 | Geographic Area | geographic_area |  |
| 2 | Currency | currency |  |
| 3 | Security | security |  |
| 4 | Calendar Date | calendar_date |  |



### 2.{IDX}.2 Bảng Geographic Area — ECAT.ECAT_01_Country

- **Mô tả:** 
- **Tên vật lý:** geographic_area
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|


#### 2.{IDX}.2.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.3 Bảng Geographic Area — ECAT.ECAT_02_Region

- **Mô tả:** 
- **Tên vật lý:** geographic_area
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|


#### 2.{IDX}.3.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.4 Bảng Geographic Area — ECAT.ECAT_03_ProvinceOld

- **Mô tả:** 
- **Tên vật lý:** geographic_area
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|


#### 2.{IDX}.4.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.5 Bảng Geographic Area — ECAT.ECAT_04_Province

- **Mô tả:** 
- **Tên vật lý:** geographic_area
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|


#### 2.{IDX}.5.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.6 Bảng Geographic Area — ECAT.ECAT_05_DistrictOld

- **Mô tả:** 
- **Tên vật lý:** geographic_area
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|


#### 2.{IDX}.6.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.7 Bảng Geographic Area — ECAT.ECAT_06_WardOld

- **Mô tả:** 
- **Tên vật lý:** geographic_area
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|


#### 2.{IDX}.7.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.8 Bảng Geographic Area — ECAT.ECAT_07_Ward

- **Mô tả:** 
- **Tên vật lý:** geographic_area
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|


#### 2.{IDX}.8.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.9 Bảng Currency

- **Mô tả:** 
- **Tên vật lý:** currency
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|


#### 2.{IDX}.9.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.10 Bảng Security

- **Mô tả:** 
- **Tên vật lý:** security
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|


#### 2.{IDX}.10.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.11 Bảng Calendar Date

- **Mô tả:** 
- **Tên vật lý:** calendar_date
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|


#### 2.{IDX}.11.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



