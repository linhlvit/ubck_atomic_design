# 2. CƠ SỞ DỮ LIỆU (OLTP)


## 2.1 ECAT — 

### 2.1.1 Các mô hình quan hệ dữ liệu

- DBML tổng hợp (tất cả bảng): [`ECAT.dbml`](ECAT.dbml) — paste vào https://dbdiagram.io để render.
- Diagram theo mảng nghiệp vụ:
  - **UID01 — Danh mục địa lý hành chính**: [`ECAT_UID01.dbml`](ECAT_UID01.dbml)
  - **UID03 — Danh mục tiền tệ**: [`ECAT_UID03.dbml`](ECAT_UID03.dbml)
  - **UID04 — Danh mục chứng khoán & thị trường**: [`ECAT_UID04.dbml`](ECAT_UID04.dbml)
  - **UID08 — Danh mục lịch & ngày nghỉ**: [`ECAT_UID08.dbml`](ECAT_UID08.dbml)


**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | geo | Đơn vị địa lý dùng làm FK tham chiếu: quốc gia/quốc tịch (COUNTRY), vùng/miền (REGION), tỉnh/thành phố mới/cũ (PROVINCE/PROVINCE_OLD), quận/huyện cũ (DISTRICT_OLD), phường/xã mới/cũ (WARD/WARD_OLD). Phân biệt bằng geographic_area_type_code. Hỗ trợ song song bộ danh mục pre- và post-sáp nhập hành chính 2025. |
| 2 | ccy | Đơn vị tiền tệ theo chuẩn ISO 4217. ECAT là source chuẩn (authoritative). Currency là data domain riêng theo quy tắc #4 — không có surrogate key, BK = currency_code 3 ký tự. |
| 3 | scr | Danh mục chứng khoán đang/đã lưu hành trên thị trường Việt Nam (cổ phiếu, trái phiếu, chứng chỉ quỹ, chứng quyền...). ECAT là source chuẩn cho Code + Name. Các source khác (GSGD/FIMS/IDS) sẽ mở rộng attribute sau. |
| 4 | cdr_dt | Ngày dương lịch dense (ETL tự sinh mọi ngày trong phạm vi hệ thống). ECAT_29_HolidayInfo bổ sung cờ ngày nghỉ lễ công cộng (holiday_flag) và tên ngày lễ. PK dạng yyyymmdd. |




### 2.1.2 Bảng geo



#### Từ ECAT.ECAT_01_Country

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | geo_id | STRING |  | X | P |  | Khóa đại diện cho khu vực địa lý. |
| 2 | geo_code | STRING |  |  |  |  | Mã khu vực địa lý. Map từ PK bảng nguồn (cột code/id tùy bảng). Dùng chung cho mọi cấp hành chính. |
| 3 | src_stm_code | STRING |  |  |  | 'ECAT.ECAT_01_Country' | Mã hệ thống nguồn. |
| 4 | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. |
| 5 | geo_nm | STRING |  |  |  |  | Tên khu vực địa lý (tên đầy đủ tiếng Việt). |
| 6 | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. |
| 7 | dsc | STRING | X |  |  |  | Mô tả. |
| 8 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 9 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 10 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 11 | geo_tp_code | STRING |  |  |  | 'ETL derives từ bảng nguồn (ECAT_01→COUNTRY; ECAT_02→REGION; ECAT_03→PROVINCE_OLD; ECAT_04→PROVINCE; ECAT_05→DISTRICT_OLD; ECAT_06→WARD_OLD; ECAT_07→WARD)' | Loại khu vực địa lý — phân biệt cấp hành chính: COUNTRY/REGION/PROVINCE/PROVINCE_OLD/DISTRICT_OLD/WARD/WARD_OLD. |
| 12 | geo_bsn_code | STRING | X |  |  |  | Mã quốc tịch/quốc gia (mã nghiệp vụ). |
| 13 | note | STRING | X |  |  |  | Ghi chú. |
| 14 | prn_geo_id | STRING | X |  | F |  | FK tự tham chiếu đến khu vực cha trong phân cấp hành chính. |
| 15 | prn_geo_code | STRING | X |  |  |  | Mã khu vực cha — denormalized để tiện tra cứu. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| geo_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prn_geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ ECAT.ECAT_02_Region

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | geo_id | STRING |  | X | P |  | Khóa đại diện cho khu vực địa lý. |
| 2 | geo_code | STRING |  |  |  |  | Mã khu vực địa lý. Map từ PK bảng nguồn (cột code/id tùy bảng). Dùng chung cho mọi cấp hành chính. |
| 3 | src_stm_code | STRING |  |  |  | 'ECAT.ECAT_02_Region' | Mã hệ thống nguồn. |
| 4 | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. |
| 5 | geo_nm | STRING |  |  |  |  | Tên khu vực địa lý (tên đầy đủ tiếng Việt). |
| 6 | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. |
| 7 | dsc | STRING | X |  |  |  | Mô tả. |
| 8 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 9 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 10 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 11 | geo_tp_code | STRING |  |  |  | 'ETL derives từ bảng nguồn (ECAT_01→COUNTRY; ECAT_02→REGION; ECAT_03→PROVINCE_OLD; ECAT_04→PROVINCE; ECAT_05→DISTRICT_OLD; ECAT_06→WARD_OLD; ECAT_07→WARD)' | Loại khu vực địa lý — phân biệt cấp hành chính: COUNTRY/REGION/PROVINCE/PROVINCE_OLD/DISTRICT_OLD/WARD/WARD_OLD. |
| 12 | geo_bsn_code | STRING | X |  |  |  | Mã quốc tịch/quốc gia (mã nghiệp vụ). |
| 13 | note | STRING | X |  |  |  | Ghi chú. |
| 14 | prn_geo_id | STRING | X |  | F |  | FK tự tham chiếu đến khu vực cha trong phân cấp hành chính. |
| 15 | prn_geo_code | STRING | X |  |  |  | Mã khu vực cha — denormalized để tiện tra cứu. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| geo_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prn_geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ ECAT.ECAT_03_ProvinceOld

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | geo_id | STRING |  | X | P |  | Khóa đại diện cho khu vực địa lý. |
| 2 | geo_code | STRING |  |  |  |  | Mã khu vực địa lý. Map từ PK bảng nguồn (cột code/id tùy bảng). Dùng chung cho mọi cấp hành chính. |
| 3 | src_stm_code | STRING |  |  |  | 'ECAT.ECAT_03_ProvinceOld' | Mã hệ thống nguồn. |
| 4 | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. |
| 5 | geo_nm | STRING |  |  |  |  | Tên khu vực địa lý (tên đầy đủ tiếng Việt). |
| 6 | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. |
| 7 | dsc | STRING | X |  |  |  | Mô tả. |
| 8 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 9 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 10 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 11 | geo_tp_code | STRING |  |  |  | 'ETL derives từ bảng nguồn (ECAT_01→COUNTRY; ECAT_02→REGION; ECAT_03→PROVINCE_OLD; ECAT_04→PROVINCE; ECAT_05→DISTRICT_OLD; ECAT_06→WARD_OLD; ECAT_07→WARD)' | Loại khu vực địa lý — phân biệt cấp hành chính: COUNTRY/REGION/PROVINCE/PROVINCE_OLD/DISTRICT_OLD/WARD/WARD_OLD. |
| 12 | geo_bsn_code | STRING | X |  |  |  | Mã quốc tịch/quốc gia (mã nghiệp vụ). |
| 13 | note | STRING | X |  |  |  | Ghi chú. |
| 14 | prn_geo_id | STRING | X |  | F |  | FK tự tham chiếu đến khu vực cha trong phân cấp hành chính. |
| 15 | prn_geo_code | STRING | X |  |  |  | Mã khu vực cha — denormalized để tiện tra cứu. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| geo_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prn_geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ ECAT.ECAT_04_Province

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | geo_id | STRING |  | X | P |  | Khóa đại diện cho khu vực địa lý. |
| 2 | geo_code | STRING |  |  |  |  | Mã khu vực địa lý. Map từ PK bảng nguồn (cột code/id tùy bảng). Dùng chung cho mọi cấp hành chính. |
| 3 | src_stm_code | STRING |  |  |  | 'ECAT.ECAT_04_Province' | Mã hệ thống nguồn. |
| 4 | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. |
| 5 | geo_nm | STRING |  |  |  |  | Tên khu vực địa lý (tên đầy đủ tiếng Việt). |
| 6 | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. |
| 7 | dsc | STRING | X |  |  |  | Mô tả. |
| 8 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 9 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 10 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 11 | geo_tp_code | STRING |  |  |  | 'ETL derives từ bảng nguồn (ECAT_01→COUNTRY; ECAT_02→REGION; ECAT_03→PROVINCE_OLD; ECAT_04→PROVINCE; ECAT_05→DISTRICT_OLD; ECAT_06→WARD_OLD; ECAT_07→WARD)' | Loại khu vực địa lý — phân biệt cấp hành chính: COUNTRY/REGION/PROVINCE/PROVINCE_OLD/DISTRICT_OLD/WARD/WARD_OLD. |
| 12 | geo_bsn_code | STRING | X |  |  |  | Mã quốc tịch/quốc gia (mã nghiệp vụ). |
| 13 | note | STRING | X |  |  |  | Ghi chú. |
| 14 | prn_geo_id | STRING | X |  | F |  | FK tự tham chiếu đến khu vực cha trong phân cấp hành chính. |
| 15 | prn_geo_code | STRING | X |  |  |  | Mã khu vực cha — denormalized để tiện tra cứu. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| geo_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prn_geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ ECAT.ECAT_05_DistrictOld

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | geo_id | STRING |  | X | P |  | Khóa đại diện cho khu vực địa lý. |
| 2 | geo_code | STRING |  |  |  |  | Mã khu vực địa lý. Map từ PK bảng nguồn (cột code/id tùy bảng). Dùng chung cho mọi cấp hành chính. |
| 3 | src_stm_code | STRING |  |  |  | 'ECAT.ECAT_05_DistrictOld' | Mã hệ thống nguồn. |
| 4 | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. |
| 5 | geo_nm | STRING |  |  |  |  | Tên khu vực địa lý (tên đầy đủ tiếng Việt). |
| 6 | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. |
| 7 | dsc | STRING | X |  |  |  | Mô tả. |
| 8 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 9 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 10 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 11 | geo_tp_code | STRING |  |  |  | 'ETL derives từ bảng nguồn (ECAT_01→COUNTRY; ECAT_02→REGION; ECAT_03→PROVINCE_OLD; ECAT_04→PROVINCE; ECAT_05→DISTRICT_OLD; ECAT_06→WARD_OLD; ECAT_07→WARD)' | Loại khu vực địa lý — phân biệt cấp hành chính: COUNTRY/REGION/PROVINCE/PROVINCE_OLD/DISTRICT_OLD/WARD/WARD_OLD. |
| 12 | geo_bsn_code | STRING | X |  |  |  | Mã quốc tịch/quốc gia (mã nghiệp vụ). |
| 13 | note | STRING | X |  |  |  | Ghi chú. |
| 14 | prn_geo_id | STRING | X |  | F |  | FK tự tham chiếu đến khu vực cha trong phân cấp hành chính. |
| 15 | prn_geo_code | STRING | X |  |  |  | Mã khu vực cha — denormalized để tiện tra cứu. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| geo_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prn_geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ ECAT.ECAT_06_WardOld

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | geo_id | STRING |  | X | P |  | Khóa đại diện cho khu vực địa lý. |
| 2 | geo_code | STRING |  |  |  |  | Mã khu vực địa lý. Map từ PK bảng nguồn (cột code/id tùy bảng). Dùng chung cho mọi cấp hành chính. |
| 3 | src_stm_code | STRING |  |  |  | 'ECAT.ECAT_06_WardOld' | Mã hệ thống nguồn. |
| 4 | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. |
| 5 | geo_nm | STRING |  |  |  |  | Tên khu vực địa lý (tên đầy đủ tiếng Việt). |
| 6 | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. |
| 7 | dsc | STRING | X |  |  |  | Mô tả. |
| 8 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 9 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 10 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 11 | geo_tp_code | STRING |  |  |  | 'ETL derives từ bảng nguồn (ECAT_01→COUNTRY; ECAT_02→REGION; ECAT_03→PROVINCE_OLD; ECAT_04→PROVINCE; ECAT_05→DISTRICT_OLD; ECAT_06→WARD_OLD; ECAT_07→WARD)' | Loại khu vực địa lý — phân biệt cấp hành chính: COUNTRY/REGION/PROVINCE/PROVINCE_OLD/DISTRICT_OLD/WARD/WARD_OLD. |
| 12 | geo_bsn_code | STRING | X |  |  |  | Mã quốc tịch/quốc gia (mã nghiệp vụ). |
| 13 | note | STRING | X |  |  |  | Ghi chú. |
| 14 | prn_geo_id | STRING | X |  | F |  | FK tự tham chiếu đến khu vực cha trong phân cấp hành chính. |
| 15 | prn_geo_code | STRING | X |  |  |  | Mã khu vực cha — denormalized để tiện tra cứu. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| geo_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prn_geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ ECAT.ECAT_07_Ward

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | geo_id | STRING |  | X | P |  | Khóa đại diện cho khu vực địa lý. |
| 2 | geo_code | STRING |  |  |  |  | Mã khu vực địa lý. Map từ PK bảng nguồn (cột code/id tùy bảng). Dùng chung cho mọi cấp hành chính. |
| 3 | src_stm_code | STRING |  |  |  | 'ECAT.ECAT_07_Ward' | Mã hệ thống nguồn. |
| 4 | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. |
| 5 | geo_nm | STRING |  |  |  |  | Tên khu vực địa lý (tên đầy đủ tiếng Việt). |
| 6 | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. |
| 7 | dsc | STRING | X |  |  |  | Mô tả. |
| 8 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 9 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 10 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 11 | geo_tp_code | STRING |  |  |  | 'ETL derives từ bảng nguồn (ECAT_01→COUNTRY; ECAT_02→REGION; ECAT_03→PROVINCE_OLD; ECAT_04→PROVINCE; ECAT_05→DISTRICT_OLD; ECAT_06→WARD_OLD; ECAT_07→WARD)' | Loại khu vực địa lý — phân biệt cấp hành chính: COUNTRY/REGION/PROVINCE/PROVINCE_OLD/DISTRICT_OLD/WARD/WARD_OLD. |
| 12 | geo_bsn_code | STRING | X |  |  |  | Mã quốc tịch/quốc gia (mã nghiệp vụ). |
| 13 | note | STRING | X |  |  |  | Ghi chú. |
| 14 | prn_geo_id | STRING | X |  | F |  | FK tự tham chiếu đến khu vực cha trong phân cấp hành chính. |
| 15 | prn_geo_code | STRING | X |  |  |  | Mã khu vực cha — denormalized để tiện tra cứu. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| geo_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prn_geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A





### 2.1.3 Bảng ccy



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ccy_code | STRING |  | X | P |  | Mã tiền tệ theo chuẩn ISO 4217 (3 ký tự: VND, USD, EUR...). Map từ PK bảng nguồn. |
| 2 | src_stm_code | STRING |  |  |  | 'ECAT.ECAT_11_Currency' | Mã hệ thống nguồn. |
| 3 | ccy_nm | STRING |  |  |  |  | Tên tiền tệ đầy đủ. |


#### 2.1.3.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ccy_code |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### 2.1.3.2 Index

N/A

#### 2.1.3.3 Trigger

N/A




### 2.1.4 Bảng scr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_id | STRING |  | X | P |  | Khóa đại diện cho chứng khoán. |
| 2 | scr_code | STRING |  |  |  |  | Mã chứng khoán (ví dụ: VIC, VCB, VN30F1M). Map từ PK bảng nguồn. Unique toàn thị trường. |
| 3 | src_stm_code | STRING |  |  |  | 'ECAT.ECAT_14_Security' | Mã hệ thống nguồn. |
| 4 | scr_nm | STRING |  |  |  |  | Tên chứng khoán đầy đủ. |
| 5 | scr_tp_code | STRING | X |  |  |  | Loại chứng khoán (cổ phiếu, trái phiếu, chứng chỉ quỹ, chứng quyền...). |
| 6 | mkt_code | STRING | X |  |  |  | Mã thị trường niêm yết/giao dịch (HOSE, HNX, UPCOM, OTC...). |


#### 2.1.4.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### 2.1.4.2 Index

N/A

#### 2.1.4.3 Trigger

N/A




### 2.1.5 Bảng cdr_dt



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | cdr_dt_id | INT |  | X | P |  | Khóa ngày dương lịch dạng số nguyên yyyymmdd (ví dụ: 20250429). ETL sinh dense cho toàn bộ khoảng thời gian hệ thống theo dõi. |
| 2 | cdr_dt | DATE |  |  |  | 'ETL generated (dense)' | Ngày dương lịch (duy nhất). BK của entity. |
| 3 | src_stm_code | STRING |  |  |  | 'ECAT.ECAT_29_HolidayInfo' | Mã hệ thống nguồn. |
| 4 | hol_f | BOOLEAN |  |  |  | 'false' | Cờ ngày nghỉ lễ công cộng. Mặc định = false; set = true nếu ngày có trong ECAT_29_HolidayInfo. |
| 5 | hol_nm | STRING | X |  |  |  | Tên ngày lễ (ví dụ: Tết Dương lịch, Quốc khánh). NULL nếu không phải ngày nghỉ công cộng. |


#### 2.1.5.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| cdr_dt_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### 2.1.5.2 Index

N/A

#### 2.1.5.3 Trigger

N/A




### 2.1.6 Stored Procedure/Function

N/A

### 2.1.7 Package

N/A


