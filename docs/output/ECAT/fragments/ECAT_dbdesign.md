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
| 1 | Geographic Area | geo | Đơn vị địa lý dùng làm FK tham chiếu: quốc gia/quốc tịch (COUNTRY), vùng/miền (REGION), tỉnh/thành phố mới/cũ (PROVINCE/PROVINCE_OLD), quận/huyện cũ (DISTRICT_OLD), phường/xã mới/cũ (WARD/WARD_OLD). Phân biệt bằng geographic_area_type_code. Hỗ trợ song song bộ danh mục pre- và post-sáp nhập hành chính 2025. |
| 2 | Currency | ccy |  |
| 3 | Security | scr |  |
| 4 | Calendar Date | cdr_dt |  |



### 2.{IDX}.2 Bảng Geographic Area — ECAT.ECAT_01_Country

- **Mô tả:** Đơn vị địa lý dùng làm FK tham chiếu: quốc gia/quốc tịch (COUNTRY), vùng/miền (REGION), tỉnh/thành phố mới/cũ (PROVINCE/PROVINCE_OLD), quận/huyện cũ (DISTRICT_OLD), phường/xã mới/cũ (WARD/WARD_OLD). Phân biệt bằng geographic_area_type_code. Hỗ trợ song song bộ danh mục pre- và post-sáp nhập hành chính 2025.
- **Tên vật lý:** geo
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Geographic Area Id | geo_id | BIGINT |  | X | P |  | Khóa đại diện cho khu vực địa lý. | ECAT.ECAT_01_Country |  | PK surrogate. |
| 2 | Geographic Area Code | geo_code | STRING |  |  |  |  | Mã khu vực địa lý. Map từ PK bảng nguồn (cột code/id tùy bảng). Dùng chung cho mọi cấp hành chính. | ECAT.ECAT_01_Country | code | BK của entity. Mã được gán bởi HTTT/ECAT — unique trong từng cấp hành chính. ETL cần namespace nếu trùng code giữa các cấp. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ECAT.ECAT_01_Country' | Mã hệ thống nguồn. | ECAT.ECAT_01_Country |  |  |
| 4 | Geographic Area Short Code | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. | ECAT.ECAT_01_Country |  |  |
| 5 | Geographic Area Name | geo_nm | STRING |  |  |  |  | Tên khu vực địa lý (tên đầy đủ tiếng Việt). | ECAT.ECAT_01_Country | name |  |
| 6 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. | ECAT.ECAT_01_Country |  | Scheme: LIFE_CYCLE_STATUS. |
| 7 | Description | dsc | STRING | X |  |  |  | Mô tả. | ECAT.ECAT_01_Country |  |  |
| 8 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | ECAT.ECAT_01_Country |  |  |
| 9 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | ECAT.ECAT_01_Country |  |  |
| 10 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | ECAT.ECAT_01_Country |  |  |
| 11 | Geographic Area Type Code | geo_tp_code | STRING |  |  |  | 'ETL derives từ bảng nguồn (ECAT_01→COUNTRY; ECAT_02→REGION; ECAT_03→PROVINCE_OLD; ECAT_04→PROVINCE; ECAT_05→DISTRICT_OLD; ECAT_06→WARD_OLD; ECAT_07→WARD)' | Loại khu vực địa lý — phân biệt cấp hành chính: COUNTRY/REGION/PROVINCE/PROVINCE_OLD/DISTRICT_OLD/WARD/WARD_OLD. | ECAT.ECAT_01_Country |  |  |
| 12 | Geographic Area Business Code | geo_bsn_code | STRING | X |  |  |  | Mã quốc tịch/quốc gia (mã nghiệp vụ). | ECAT.ECAT_01_Country |  |  |
| 13 | Note | note | STRING | X |  |  |  | Ghi chú. | ECAT.ECAT_01_Country |  |  |
| 14 | Parent Geographic Area Id | prn_geo_id | BIGINT | X |  | F |  | FK tự tham chiếu đến khu vực cha trong phân cấp hành chính. | ECAT.ECAT_01_Country |  |  |
| 15 | Parent Geographic Area Code | prn_geo_code | STRING | X |  |  |  | Mã khu vực cha — denormalized để tiện tra cứu. | ECAT.ECAT_01_Country | parent_code |  |


#### 2.{IDX}.2.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Geographic Area Id | geo_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Parent Geographic Area Id | prn_geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.3 Bảng Geographic Area — ECAT.ECAT_02_Region

- **Mô tả:** Đơn vị địa lý dùng làm FK tham chiếu: quốc gia/quốc tịch (COUNTRY), vùng/miền (REGION), tỉnh/thành phố mới/cũ (PROVINCE/PROVINCE_OLD), quận/huyện cũ (DISTRICT_OLD), phường/xã mới/cũ (WARD/WARD_OLD). Phân biệt bằng geographic_area_type_code. Hỗ trợ song song bộ danh mục pre- và post-sáp nhập hành chính 2025.
- **Tên vật lý:** geo
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Geographic Area Id | geo_id | BIGINT |  | X | P |  | Khóa đại diện cho khu vực địa lý. | ECAT.ECAT_02_Region |  | PK surrogate. |
| 2 | Geographic Area Code | geo_code | STRING |  |  |  |  | Mã khu vực địa lý. Map từ PK bảng nguồn (cột code/id tùy bảng). Dùng chung cho mọi cấp hành chính. | ECAT.ECAT_02_Region | code | BK của entity. Mã được gán bởi HTTT/ECAT — unique trong từng cấp hành chính. ETL cần namespace nếu trùng code giữa các cấp. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ECAT.ECAT_02_Region' | Mã hệ thống nguồn. | ECAT.ECAT_02_Region |  |  |
| 4 | Geographic Area Short Code | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. | ECAT.ECAT_02_Region |  |  |
| 5 | Geographic Area Name | geo_nm | STRING |  |  |  |  | Tên khu vực địa lý (tên đầy đủ tiếng Việt). | ECAT.ECAT_02_Region | name |  |
| 6 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. | ECAT.ECAT_02_Region |  | Scheme: LIFE_CYCLE_STATUS. |
| 7 | Description | dsc | STRING | X |  |  |  | Mô tả. | ECAT.ECAT_02_Region |  |  |
| 8 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | ECAT.ECAT_02_Region |  |  |
| 9 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | ECAT.ECAT_02_Region |  |  |
| 10 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | ECAT.ECAT_02_Region |  |  |
| 11 | Geographic Area Type Code | geo_tp_code | STRING |  |  |  | 'ETL derives từ bảng nguồn (ECAT_01→COUNTRY; ECAT_02→REGION; ECAT_03→PROVINCE_OLD; ECAT_04→PROVINCE; ECAT_05→DISTRICT_OLD; ECAT_06→WARD_OLD; ECAT_07→WARD)' | Loại khu vực địa lý — phân biệt cấp hành chính: COUNTRY/REGION/PROVINCE/PROVINCE_OLD/DISTRICT_OLD/WARD/WARD_OLD. | ECAT.ECAT_02_Region |  |  |
| 12 | Geographic Area Business Code | geo_bsn_code | STRING | X |  |  |  | Mã quốc tịch/quốc gia (mã nghiệp vụ). | ECAT.ECAT_02_Region |  |  |
| 13 | Note | note | STRING | X |  |  |  | Ghi chú. | ECAT.ECAT_02_Region |  |  |
| 14 | Parent Geographic Area Id | prn_geo_id | BIGINT | X |  | F |  | FK tự tham chiếu đến khu vực cha trong phân cấp hành chính. | ECAT.ECAT_02_Region |  |  |
| 15 | Parent Geographic Area Code | prn_geo_code | STRING | X |  |  |  | Mã khu vực cha — denormalized để tiện tra cứu. | ECAT.ECAT_02_Region | parent_code |  |


#### 2.{IDX}.3.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Geographic Area Id | geo_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Parent Geographic Area Id | prn_geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.4 Bảng Geographic Area — ECAT.ECAT_03_ProvinceOld

- **Mô tả:** Đơn vị địa lý dùng làm FK tham chiếu: quốc gia/quốc tịch (COUNTRY), vùng/miền (REGION), tỉnh/thành phố mới/cũ (PROVINCE/PROVINCE_OLD), quận/huyện cũ (DISTRICT_OLD), phường/xã mới/cũ (WARD/WARD_OLD). Phân biệt bằng geographic_area_type_code. Hỗ trợ song song bộ danh mục pre- và post-sáp nhập hành chính 2025.
- **Tên vật lý:** geo
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Geographic Area Id | geo_id | BIGINT |  | X | P |  | Khóa đại diện cho khu vực địa lý. | ECAT.ECAT_03_ProvinceOld |  | PK surrogate. |
| 2 | Geographic Area Code | geo_code | STRING |  |  |  |  | Mã khu vực địa lý. Map từ PK bảng nguồn (cột code/id tùy bảng). Dùng chung cho mọi cấp hành chính. | ECAT.ECAT_03_ProvinceOld | code | BK của entity. Mã được gán bởi HTTT/ECAT — unique trong từng cấp hành chính. ETL cần namespace nếu trùng code giữa các cấp. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ECAT.ECAT_03_ProvinceOld' | Mã hệ thống nguồn. | ECAT.ECAT_03_ProvinceOld |  |  |
| 4 | Geographic Area Short Code | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. | ECAT.ECAT_03_ProvinceOld |  |  |
| 5 | Geographic Area Name | geo_nm | STRING |  |  |  |  | Tên khu vực địa lý (tên đầy đủ tiếng Việt). | ECAT.ECAT_03_ProvinceOld | name |  |
| 6 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. | ECAT.ECAT_03_ProvinceOld |  | Scheme: LIFE_CYCLE_STATUS. |
| 7 | Description | dsc | STRING | X |  |  |  | Mô tả. | ECAT.ECAT_03_ProvinceOld |  |  |
| 8 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | ECAT.ECAT_03_ProvinceOld |  |  |
| 9 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | ECAT.ECAT_03_ProvinceOld |  |  |
| 10 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | ECAT.ECAT_03_ProvinceOld |  |  |
| 11 | Geographic Area Type Code | geo_tp_code | STRING |  |  |  | 'ETL derives từ bảng nguồn (ECAT_01→COUNTRY; ECAT_02→REGION; ECAT_03→PROVINCE_OLD; ECAT_04→PROVINCE; ECAT_05→DISTRICT_OLD; ECAT_06→WARD_OLD; ECAT_07→WARD)' | Loại khu vực địa lý — phân biệt cấp hành chính: COUNTRY/REGION/PROVINCE/PROVINCE_OLD/DISTRICT_OLD/WARD/WARD_OLD. | ECAT.ECAT_03_ProvinceOld |  |  |
| 12 | Geographic Area Business Code | geo_bsn_code | STRING | X |  |  |  | Mã quốc tịch/quốc gia (mã nghiệp vụ). | ECAT.ECAT_03_ProvinceOld |  |  |
| 13 | Note | note | STRING | X |  |  |  | Ghi chú. | ECAT.ECAT_03_ProvinceOld |  |  |
| 14 | Parent Geographic Area Id | prn_geo_id | BIGINT | X |  | F |  | FK tự tham chiếu đến khu vực cha trong phân cấp hành chính. | ECAT.ECAT_03_ProvinceOld |  |  |
| 15 | Parent Geographic Area Code | prn_geo_code | STRING | X |  |  |  | Mã khu vực cha — denormalized để tiện tra cứu. | ECAT.ECAT_03_ProvinceOld | parent_code |  |


#### 2.{IDX}.4.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Geographic Area Id | geo_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Parent Geographic Area Id | prn_geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.5 Bảng Geographic Area — ECAT.ECAT_04_Province

- **Mô tả:** Đơn vị địa lý dùng làm FK tham chiếu: quốc gia/quốc tịch (COUNTRY), vùng/miền (REGION), tỉnh/thành phố mới/cũ (PROVINCE/PROVINCE_OLD), quận/huyện cũ (DISTRICT_OLD), phường/xã mới/cũ (WARD/WARD_OLD). Phân biệt bằng geographic_area_type_code. Hỗ trợ song song bộ danh mục pre- và post-sáp nhập hành chính 2025.
- **Tên vật lý:** geo
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Geographic Area Id | geo_id | BIGINT |  | X | P |  | Khóa đại diện cho khu vực địa lý. | ECAT.ECAT_04_Province |  | PK surrogate. |
| 2 | Geographic Area Code | geo_code | STRING |  |  |  |  | Mã khu vực địa lý. Map từ PK bảng nguồn (cột code/id tùy bảng). Dùng chung cho mọi cấp hành chính. | ECAT.ECAT_04_Province | code | BK của entity. Mã được gán bởi HTTT/ECAT — unique trong từng cấp hành chính. ETL cần namespace nếu trùng code giữa các cấp. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ECAT.ECAT_04_Province' | Mã hệ thống nguồn. | ECAT.ECAT_04_Province |  |  |
| 4 | Geographic Area Short Code | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. | ECAT.ECAT_04_Province |  |  |
| 5 | Geographic Area Name | geo_nm | STRING |  |  |  |  | Tên khu vực địa lý (tên đầy đủ tiếng Việt). | ECAT.ECAT_04_Province | name |  |
| 6 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. | ECAT.ECAT_04_Province |  | Scheme: LIFE_CYCLE_STATUS. |
| 7 | Description | dsc | STRING | X |  |  |  | Mô tả. | ECAT.ECAT_04_Province |  |  |
| 8 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | ECAT.ECAT_04_Province |  |  |
| 9 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | ECAT.ECAT_04_Province |  |  |
| 10 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | ECAT.ECAT_04_Province |  |  |
| 11 | Geographic Area Type Code | geo_tp_code | STRING |  |  |  | 'ETL derives từ bảng nguồn (ECAT_01→COUNTRY; ECAT_02→REGION; ECAT_03→PROVINCE_OLD; ECAT_04→PROVINCE; ECAT_05→DISTRICT_OLD; ECAT_06→WARD_OLD; ECAT_07→WARD)' | Loại khu vực địa lý — phân biệt cấp hành chính: COUNTRY/REGION/PROVINCE/PROVINCE_OLD/DISTRICT_OLD/WARD/WARD_OLD. | ECAT.ECAT_04_Province |  |  |
| 12 | Geographic Area Business Code | geo_bsn_code | STRING | X |  |  |  | Mã quốc tịch/quốc gia (mã nghiệp vụ). | ECAT.ECAT_04_Province |  |  |
| 13 | Note | note | STRING | X |  |  |  | Ghi chú. | ECAT.ECAT_04_Province |  |  |
| 14 | Parent Geographic Area Id | prn_geo_id | BIGINT | X |  | F |  | FK tự tham chiếu đến khu vực cha trong phân cấp hành chính. | ECAT.ECAT_04_Province |  |  |
| 15 | Parent Geographic Area Code | prn_geo_code | STRING | X |  |  |  | Mã khu vực cha — denormalized để tiện tra cứu. | ECAT.ECAT_04_Province | parent_code |  |


#### 2.{IDX}.5.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Geographic Area Id | geo_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Parent Geographic Area Id | prn_geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.6 Bảng Geographic Area — ECAT.ECAT_05_DistrictOld

- **Mô tả:** Đơn vị địa lý dùng làm FK tham chiếu: quốc gia/quốc tịch (COUNTRY), vùng/miền (REGION), tỉnh/thành phố mới/cũ (PROVINCE/PROVINCE_OLD), quận/huyện cũ (DISTRICT_OLD), phường/xã mới/cũ (WARD/WARD_OLD). Phân biệt bằng geographic_area_type_code. Hỗ trợ song song bộ danh mục pre- và post-sáp nhập hành chính 2025.
- **Tên vật lý:** geo
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Geographic Area Id | geo_id | BIGINT |  | X | P |  | Khóa đại diện cho khu vực địa lý. | ECAT.ECAT_05_DistrictOld |  | PK surrogate. |
| 2 | Geographic Area Code | geo_code | STRING |  |  |  |  | Mã khu vực địa lý. Map từ PK bảng nguồn (cột code/id tùy bảng). Dùng chung cho mọi cấp hành chính. | ECAT.ECAT_05_DistrictOld | code | BK của entity. Mã được gán bởi HTTT/ECAT — unique trong từng cấp hành chính. ETL cần namespace nếu trùng code giữa các cấp. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ECAT.ECAT_05_DistrictOld' | Mã hệ thống nguồn. | ECAT.ECAT_05_DistrictOld |  |  |
| 4 | Geographic Area Short Code | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. | ECAT.ECAT_05_DistrictOld |  |  |
| 5 | Geographic Area Name | geo_nm | STRING |  |  |  |  | Tên khu vực địa lý (tên đầy đủ tiếng Việt). | ECAT.ECAT_05_DistrictOld | name |  |
| 6 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. | ECAT.ECAT_05_DistrictOld |  | Scheme: LIFE_CYCLE_STATUS. |
| 7 | Description | dsc | STRING | X |  |  |  | Mô tả. | ECAT.ECAT_05_DistrictOld |  |  |
| 8 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | ECAT.ECAT_05_DistrictOld |  |  |
| 9 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | ECAT.ECAT_05_DistrictOld |  |  |
| 10 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | ECAT.ECAT_05_DistrictOld |  |  |
| 11 | Geographic Area Type Code | geo_tp_code | STRING |  |  |  | 'ETL derives từ bảng nguồn (ECAT_01→COUNTRY; ECAT_02→REGION; ECAT_03→PROVINCE_OLD; ECAT_04→PROVINCE; ECAT_05→DISTRICT_OLD; ECAT_06→WARD_OLD; ECAT_07→WARD)' | Loại khu vực địa lý — phân biệt cấp hành chính: COUNTRY/REGION/PROVINCE/PROVINCE_OLD/DISTRICT_OLD/WARD/WARD_OLD. | ECAT.ECAT_05_DistrictOld |  |  |
| 12 | Geographic Area Business Code | geo_bsn_code | STRING | X |  |  |  | Mã quốc tịch/quốc gia (mã nghiệp vụ). | ECAT.ECAT_05_DistrictOld |  |  |
| 13 | Note | note | STRING | X |  |  |  | Ghi chú. | ECAT.ECAT_05_DistrictOld |  |  |
| 14 | Parent Geographic Area Id | prn_geo_id | BIGINT | X |  | F |  | FK tự tham chiếu đến khu vực cha trong phân cấp hành chính. | ECAT.ECAT_05_DistrictOld |  |  |
| 15 | Parent Geographic Area Code | prn_geo_code | STRING | X |  |  |  | Mã khu vực cha — denormalized để tiện tra cứu. | ECAT.ECAT_05_DistrictOld | parent_code |  |


#### 2.{IDX}.6.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Geographic Area Id | geo_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Parent Geographic Area Id | prn_geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.7 Bảng Geographic Area — ECAT.ECAT_06_WardOld

- **Mô tả:** Đơn vị địa lý dùng làm FK tham chiếu: quốc gia/quốc tịch (COUNTRY), vùng/miền (REGION), tỉnh/thành phố mới/cũ (PROVINCE/PROVINCE_OLD), quận/huyện cũ (DISTRICT_OLD), phường/xã mới/cũ (WARD/WARD_OLD). Phân biệt bằng geographic_area_type_code. Hỗ trợ song song bộ danh mục pre- và post-sáp nhập hành chính 2025.
- **Tên vật lý:** geo
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Geographic Area Id | geo_id | BIGINT |  | X | P |  | Khóa đại diện cho khu vực địa lý. | ECAT.ECAT_06_WardOld |  | PK surrogate. |
| 2 | Geographic Area Code | geo_code | STRING |  |  |  |  | Mã khu vực địa lý. Map từ PK bảng nguồn (cột code/id tùy bảng). Dùng chung cho mọi cấp hành chính. | ECAT.ECAT_06_WardOld | code | BK của entity. Mã được gán bởi HTTT/ECAT — unique trong từng cấp hành chính. ETL cần namespace nếu trùng code giữa các cấp. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ECAT.ECAT_06_WardOld' | Mã hệ thống nguồn. | ECAT.ECAT_06_WardOld |  |  |
| 4 | Geographic Area Short Code | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. | ECAT.ECAT_06_WardOld |  |  |
| 5 | Geographic Area Name | geo_nm | STRING |  |  |  |  | Tên khu vực địa lý (tên đầy đủ tiếng Việt). | ECAT.ECAT_06_WardOld | name |  |
| 6 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. | ECAT.ECAT_06_WardOld |  | Scheme: LIFE_CYCLE_STATUS. |
| 7 | Description | dsc | STRING | X |  |  |  | Mô tả. | ECAT.ECAT_06_WardOld |  |  |
| 8 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | ECAT.ECAT_06_WardOld |  |  |
| 9 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | ECAT.ECAT_06_WardOld |  |  |
| 10 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | ECAT.ECAT_06_WardOld |  |  |
| 11 | Geographic Area Type Code | geo_tp_code | STRING |  |  |  | 'ETL derives từ bảng nguồn (ECAT_01→COUNTRY; ECAT_02→REGION; ECAT_03→PROVINCE_OLD; ECAT_04→PROVINCE; ECAT_05→DISTRICT_OLD; ECAT_06→WARD_OLD; ECAT_07→WARD)' | Loại khu vực địa lý — phân biệt cấp hành chính: COUNTRY/REGION/PROVINCE/PROVINCE_OLD/DISTRICT_OLD/WARD/WARD_OLD. | ECAT.ECAT_06_WardOld |  |  |
| 12 | Geographic Area Business Code | geo_bsn_code | STRING | X |  |  |  | Mã quốc tịch/quốc gia (mã nghiệp vụ). | ECAT.ECAT_06_WardOld |  |  |
| 13 | Note | note | STRING | X |  |  |  | Ghi chú. | ECAT.ECAT_06_WardOld |  |  |
| 14 | Parent Geographic Area Id | prn_geo_id | BIGINT | X |  | F |  | FK tự tham chiếu đến khu vực cha trong phân cấp hành chính. | ECAT.ECAT_06_WardOld |  |  |
| 15 | Parent Geographic Area Code | prn_geo_code | STRING | X |  |  |  | Mã khu vực cha — denormalized để tiện tra cứu. | ECAT.ECAT_06_WardOld | parent_code |  |


#### 2.{IDX}.7.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Geographic Area Id | geo_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Parent Geographic Area Id | prn_geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.8 Bảng Geographic Area — ECAT.ECAT_07_Ward

- **Mô tả:** Đơn vị địa lý dùng làm FK tham chiếu: quốc gia/quốc tịch (COUNTRY), vùng/miền (REGION), tỉnh/thành phố mới/cũ (PROVINCE/PROVINCE_OLD), quận/huyện cũ (DISTRICT_OLD), phường/xã mới/cũ (WARD/WARD_OLD). Phân biệt bằng geographic_area_type_code. Hỗ trợ song song bộ danh mục pre- và post-sáp nhập hành chính 2025.
- **Tên vật lý:** geo
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Geographic Area Id | geo_id | BIGINT |  | X | P |  | Khóa đại diện cho khu vực địa lý. | ECAT.ECAT_07_Ward |  | PK surrogate. |
| 2 | Geographic Area Code | geo_code | STRING |  |  |  |  | Mã khu vực địa lý. Map từ PK bảng nguồn (cột code/id tùy bảng). Dùng chung cho mọi cấp hành chính. | ECAT.ECAT_07_Ward | code | BK của entity. Mã được gán bởi HTTT/ECAT — unique trong từng cấp hành chính. ETL cần namespace nếu trùng code giữa các cấp. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ECAT.ECAT_07_Ward' | Mã hệ thống nguồn. | ECAT.ECAT_07_Ward |  |  |
| 4 | Geographic Area Short Code | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. | ECAT.ECAT_07_Ward |  |  |
| 5 | Geographic Area Name | geo_nm | STRING |  |  |  |  | Tên khu vực địa lý (tên đầy đủ tiếng Việt). | ECAT.ECAT_07_Ward | name |  |
| 6 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. | ECAT.ECAT_07_Ward |  | Scheme: LIFE_CYCLE_STATUS. |
| 7 | Description | dsc | STRING | X |  |  |  | Mô tả. | ECAT.ECAT_07_Ward |  |  |
| 8 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | ECAT.ECAT_07_Ward |  |  |
| 9 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | ECAT.ECAT_07_Ward |  |  |
| 10 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | ECAT.ECAT_07_Ward |  |  |
| 11 | Geographic Area Type Code | geo_tp_code | STRING |  |  |  | 'ETL derives từ bảng nguồn (ECAT_01→COUNTRY; ECAT_02→REGION; ECAT_03→PROVINCE_OLD; ECAT_04→PROVINCE; ECAT_05→DISTRICT_OLD; ECAT_06→WARD_OLD; ECAT_07→WARD)' | Loại khu vực địa lý — phân biệt cấp hành chính: COUNTRY/REGION/PROVINCE/PROVINCE_OLD/DISTRICT_OLD/WARD/WARD_OLD. | ECAT.ECAT_07_Ward |  |  |
| 12 | Geographic Area Business Code | geo_bsn_code | STRING | X |  |  |  | Mã quốc tịch/quốc gia (mã nghiệp vụ). | ECAT.ECAT_07_Ward |  |  |
| 13 | Note | note | STRING | X |  |  |  | Ghi chú. | ECAT.ECAT_07_Ward |  |  |
| 14 | Parent Geographic Area Id | prn_geo_id | BIGINT | X |  | F |  | FK tự tham chiếu đến khu vực cha trong phân cấp hành chính. | ECAT.ECAT_07_Ward |  |  |
| 15 | Parent Geographic Area Code | prn_geo_code | STRING | X |  |  |  | Mã khu vực cha — denormalized để tiện tra cứu. | ECAT.ECAT_07_Ward | parent_code |  |


#### 2.{IDX}.8.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Geographic Area Id | geo_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Parent Geographic Area Id | prn_geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.9 Bảng Currency

- **Mô tả:** 
- **Tên vật lý:** ccy
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Currency Id | ccy_id | BIGINT |  | X | P |  | Khóa đại diện cho đơn vị tiền tệ. | ECAT.ECAT_11_Currency |  | PK surrogate. |
| 2 | Currency Code | ccy_code | STRING |  |  |  |  | Mã tiền tệ theo chuẩn ISO 4217 (3 ký tự: VND, USD, EUR...). Map từ PK bảng nguồn. | ECAT.ECAT_11_Currency | code | BK của entity. ECAT đảm bảo tuân thủ ISO 4217 — không cần mapping nội bộ (D-06 HLD Overview). BCV Term: Currency. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ECAT.ECAT_11_Currency' | Mã hệ thống nguồn. | ECAT.ECAT_11_Currency |  |  |
| 4 | Currency Name | ccy_nm | STRING |  |  |  |  | Tên tiền tệ đầy đủ. | ECAT.ECAT_11_Currency | name |  |


#### 2.{IDX}.9.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Currency Id | ccy_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.10 Bảng Security

- **Mô tả:** 
- **Tên vật lý:** scr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Security Id | scr_id | BIGINT |  | X | P |  | Khóa đại diện cho chứng khoán. | ECAT.ECAT_14_Security |  | PK surrogate. |
| 2 | Security Code | scr_code | STRING |  |  |  |  | Mã chứng khoán (ví dụ: VIC, VCB, VN30F1M). Map từ PK bảng nguồn. Unique toàn thị trường. | ECAT.ECAT_14_Security | code | BK của entity. Unique toàn thị trường — không cần kết hợp với market_code (D-07 HLD Overview). BCV Term: Security Instrument Identifier. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ECAT.ECAT_14_Security' | Mã hệ thống nguồn. | ECAT.ECAT_14_Security |  |  |
| 4 | Security Name | scr_nm | STRING |  |  |  |  | Tên chứng khoán đầy đủ. | ECAT.ECAT_14_Security | name |  |
| 5 | Security Type Code | scr_tp_code | STRING | X |  |  |  | Loại chứng khoán (cổ phiếu, trái phiếu, chứng chỉ quỹ, chứng quyền...). | ECAT.ECAT_14_Security | security_type_code | Scheme: ECAT_SECURITY_TYPE. Values load từ ECAT_12_SecurityType. |
| 6 | Market Code | mkt_code | STRING | X |  |  |  | Mã thị trường niêm yết/giao dịch (HOSE, HNX, UPCOM, OTC...). | ECAT.ECAT_14_Security | market_code | Scheme: ECAT_MARKET. Values load từ ECAT_13_Market. |


#### 2.{IDX}.10.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Security Id | scr_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.11 Bảng Calendar Date

- **Mô tả:** 
- **Tên vật lý:** cdr_dt
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Calendar Date Id | cdr_dt_id | BIGINT |  | X | P |  | Khóa đại diện cho ngày dương lịch. | ECAT.ECAT_29_HolidayInfo |  | PK surrogate. ETL sinh dense cho toàn bộ khoảng thời gian hệ thống theo dõi. |
| 2 | Calendar Date | cdr_dt | DATE |  |  |  | 'ETL generated (dense)' | Ngày dương lịch (duy nhất). BK của entity. | ECAT.ECAT_29_HolidayInfo |  | BK nghiệp vụ — unique. ETL tự sinh mọi ngày. Không phụ thuộc ECAT_29 về danh sách ngày. BCV Term: Day Of Calendar Year (Time Period). |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ECAT.ECAT_29_HolidayInfo' | Mã hệ thống nguồn. | ECAT.ECAT_29_HolidayInfo |  |  |
| 4 | Holiday Flag | hol_f | BOOLEAN |  |  |  | 'false' | Cờ ngày nghỉ lễ công cộng. Mặc định = false; set = true nếu ngày có trong ECAT_29_HolidayInfo. | ECAT.ECAT_29_HolidayInfo | calendar_date |  |
| 5 | Holiday Name | hol_nm | STRING | X |  |  |  | Tên ngày lễ (ví dụ: Tết Dương lịch, Quốc khánh). NULL nếu không phải ngày nghỉ công cộng. | ECAT.ECAT_29_HolidayInfo | holiday_name |  |


#### 2.{IDX}.11.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Calendar Date Id | cdr_dt_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



