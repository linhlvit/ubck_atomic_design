## 2.{IDX} FIMS — Hệ thống quản lý giám sát nhà đầu tư nước ngoài

### 2.{IDX}.1 Các mô hình quan hệ dữ liệu

- DBML tổng hợp (tất cả bảng): [`FIMS.dbml`](FIMS.dbml) — paste vào https://dbdiagram.io để render.
- Diagram theo mảng nghiệp vụ:
  - **UID01 — Quản trị phân hệ**: [`FIMS_UID01.dbml`](FIMS_UID01.dbml)
  - **UID03 — Đối tượng gửi báo cáo**: [`FIMS_UID03.dbml`](FIMS_UID03.dbml)
  - **UID04 — Nhà đầu tư nước ngoài**: [`FIMS_UID04.dbml`](FIMS_UID04.dbml)
  - **UID05 — Báo cáo thành viên**: [`FIMS_UID05.dbml`](FIMS_UID05.dbml)
  - **UID07 — Ủy quyền**: [`FIMS_UID07.dbml`](FIMS_UID07.dbml)
  - **UID08 — Công bố thông tin**: [`FIMS_UID08.dbml`](FIMS_UID08.dbml)
  - **UID09 — Cảnh báo**: [`FIMS_UID09.dbml`](FIMS_UID09.dbml)
  - **UID10 — Tiện ích**: [`FIMS_UID10.dbml`](FIMS_UID10.dbml)


**Danh sách bảng:**

| STT | Thực thể | Tên bảng | Mô tả |
|---|---|---|---|
| 1 | Stock Exchange | stk_exg | Sở giao dịch chứng khoán - thành viên thị trường trong hệ thống FIMS (HNX, HOSE). |
| 2 | Depository Center | depst_cntr | Trung tâm lưu ký chứng khoán quốc gia - thành viên thị trường trong hệ thống FIMS (VSD). |
| 3 | Fund Management Company | fnd_mgt_co | Công ty quản lý quỹ đầu tư chứng khoán trong nước được UBCKNN cấp phép hoạt động. Lưu thông tin pháp lý và hoạt động của công ty. |
| 4 | Securities Company | scr_co | Công ty chứng khoán - thành viên thị trường trong hệ thống FIMS. Quản lý tài khoản và danh mục NĐT nước ngoài. |
| 5 | Custodian Bank | cstd_bnk | Ngân hàng lưu ký giám sát tài sản quỹ đầu tư chứng khoán được UBCKNN chấp thuận. Chịu trách nhiệm lưu giữ và giám sát tài sản của quỹ. |
| 6 | Fund Management Company Organization Unit | fnd_mgt_co_ou | Chi nhánh hoặc văn phòng đại diện của công ty quản lý quỹ trong nước. Có địa chỉ và giấy phép hoạt động riêng. |
| 7 | Disclosure Representative | dscl_representative | Người hoặc tổ chức đại diện thực hiện công bố thông tin trên thị trường chứng khoán. |
| 8 | Foreign Investor | frgn_ivsr | Danh mục nhà đầu tư đăng ký giao dịch trên thị trường chứng khoán. Bao gồm cá nhân và tổ chức, phân biệt bằng ObjectType. |
| 9 | Disclosure Representative Key Person | dscl_representative_key_psn | Nhân sự thực hiện công bố thông tin tại các tổ chức thành viên thị trường. |
| 10 | Report Template | rpt_tpl | Biểu mẫu báo cáo đầu vào - khuôn mẫu tờ khai định kỳ mà thành viên thị trường phải nộp theo quy định. |
| 11 | Geographic Area | geo | Đơn vị địa lý dùng làm FK tham chiếu: quốc gia/quốc tịch (COUNTRY), vùng/miền (REGION), tỉnh/thành phố mới/cũ (PROVINCE/PROVINCE_OLD), quận/huyện cũ (DISTRICT_OLD), phường/xã mới/cũ (WARD/WARD_OLD). Phân biệt bằng geographic_area_type_code. Hỗ trợ song song bộ danh mục pre- và post-sáp nhập hành chính 2025. |
| 12 | Reporting Period | rpt_prd | Kỳ báo cáo định kỳ (ngày/tuần/tháng/quý/bán niên/năm) mà thành viên thị trường phải nộp báo cáo lên UBCKNN. |
| 13 | Member Regulatory Report | mbr_reg_rpt | Báo cáo định kỳ của thành viên thị trường nộp lên UBCK. Ghi nhận biểu mẫu, kỳ, trạng thái nộp và thành viên nộp. |
| 14 | Member Conduct Violation | mbr_conduct_vln | Vi phạm được ghi nhận từ cảnh báo hệ thống hoặc kiểm tra định kỳ đối với thành viên thị trường. |
| 15 | Disclosure Authorization | dscl_ahr | Ủy quyền công bố thông tin của người đại diện CBTT cho nhà đầu tư nước ngoài. Ghi nhận bên được ủy quyền, loại quan hệ và thời hạn hiệu lực. |
| 16 | Disclosure Announcement | dscl_ancm | Tin công bố thông tin của thành viên thị trường qua người đại diện CBTT. |
| 17 | Foreign Investor Securities Account | frgn_ivsr_scr_ac | Tài khoản giao dịch chứng khoán của nhà đầu tư nước ngoài tại công ty chứng khoán. |
| 18 | Foreign Investor Stock Portfolio Snapshot | frgn_ivsr_stk_prtfl_snpst | Danh mục sở hữu chứng khoán của nhà đầu tư nước ngoài tại từng công ty chứng khoán. |
| 19 | Member Report Value | mbr_rpt_val | Giá trị từng chỉ tiêu trong báo cáo định kỳ của thành viên. Mỗi dòng = 1 chỉ tiêu trong 1 báo cáo. |
| 20 | Involved Party Postal Address | ip_pst_adr | Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn. |
| 21 | Involved Party Electronic Address | ip_elc_adr | Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn. |
| 22 | Involved Party Alternative Identification | ip_alt_identn | Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn. |



### 2.{IDX}.2 Bảng Stock Exchange

- **Mô tả:** Sở giao dịch chứng khoán - thành viên thị trường trong hệ thống FIMS (HNX, HOSE).
- **Tên vật lý:** stk_exg
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Stock Exchange Id | stk_exg_id | BIGINT |  | X | P |  | Khóa đại diện cho Sở giao dịch chứng khoán. | FIMS.STOCKEXCHANGE |  | PK surrogate. |
| 2 | Stock Exchange Code | stk_exg_code | STRING |  |  |  |  | Mã định danh Sở giao dịch. Map từ PK bảng nguồn. | FIMS.STOCKEXCHANGE | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.STOCKEXCHANGE' | Mã nguồn dữ liệu. | FIMS.STOCKEXCHANGE |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Country of Registration Id | cty_of_rgst_id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký của Sở giao dịch. | FIMS.STOCKEXCHANGE | NaId |  |
| 5 | Country of Registration Code | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. | FIMS.STOCKEXCHANGE | NaId |  |
| 6 | Full Name | full_nm | STRING |  |  |  |  | Tên Sở giao dịch. | FIMS.STOCKEXCHANGE | Name |  |
| 7 | English Name | english_nm | STRING | X |  |  |  | Tên tiếng Anh. | FIMS.STOCKEXCHANGE | EName |  |
| 8 | Abbreviation | abr | STRING | X |  |  |  | Tên viết tắt. | FIMS.STOCKEXCHANGE | ShortName |  |
| 9 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. | FIMS.STOCKEXCHANGE | StatusId | Scheme: LIFE_CYCLE_STATUS. |
| 10 | Description | dsc | STRING | X |  |  |  | Ghi chú. | FIMS.STOCKEXCHANGE | Description |  |
| 11 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FIMS.STOCKEXCHANGE | CreatedBy |  |
| 12 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FIMS.STOCKEXCHANGE | DateCreated |  |
| 13 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FIMS.STOCKEXCHANGE | DateModified |  |


#### 2.{IDX}.2.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Stock Exchange Id | stk_exg_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Country of Registration Id | cty_of_rgst_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.3 Bảng Depository Center

- **Mô tả:** Trung tâm lưu ký chứng khoán quốc gia - thành viên thị trường trong hệ thống FIMS (VSD).
- **Tên vật lý:** depst_cntr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Depository Center Id | depst_cntr_id | BIGINT |  | X | P |  | Khóa đại diện cho Trung tâm lưu ký chứng khoán. | FIMS.DEPOSITORYCENTER |  | PK surrogate. |
| 2 | Depository Center Code | depst_cntr_code | STRING |  |  |  |  | Mã định danh Trung tâm lưu ký. Map từ PK bảng nguồn. | FIMS.DEPOSITORYCENTER | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.DEPOSITORYCENTER' | Mã nguồn dữ liệu. | FIMS.DEPOSITORYCENTER |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Country of Registration Id | cty_of_rgst_id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký của Trung tâm lưu ký. | FIMS.DEPOSITORYCENTER | NaId |  |
| 5 | Country of Registration Code | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. | FIMS.DEPOSITORYCENTER | NaId |  |
| 6 | Full Name | full_nm | STRING |  |  |  |  | Tên Trung tâm lưu ký. | FIMS.DEPOSITORYCENTER | Name |  |
| 7 | English Name | english_nm | STRING | X |  |  |  | Tên tiếng Anh. | FIMS.DEPOSITORYCENTER | EName |  |
| 8 | Abbreviation | abr | STRING | X |  |  |  | Tên viết tắt. | FIMS.DEPOSITORYCENTER | ShortName |  |
| 9 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. | FIMS.DEPOSITORYCENTER | StatusId | Scheme: LIFE_CYCLE_STATUS. |
| 10 | Description | dsc | STRING | X |  |  |  | Ghi chú. | FIMS.DEPOSITORYCENTER | Description |  |
| 11 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FIMS.DEPOSITORYCENTER | CreatedBy |  |
| 12 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FIMS.DEPOSITORYCENTER | DateCreated |  |
| 13 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FIMS.DEPOSITORYCENTER | DateModified |  |


#### 2.{IDX}.3.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Depository Center Id | depst_cntr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Country of Registration Id | cty_of_rgst_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.4 Bảng Fund Management Company

- **Mô tả:** Công ty quản lý quỹ đầu tư chứng khoán trong nước được UBCKNN cấp phép hoạt động. Lưu thông tin pháp lý và hoạt động của công ty.
- **Tên vật lý:** fnd_mgt_co
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Fund Management Company Id | fnd_mgt_co_id | BIGINT |  | X | P |  | Khóa đại diện cho công ty quản lý quỹ. | FIMS.FUNDCOMPANY |  | PK surrogate. Entity dùng chung với FMS.SECURITIES — ETL merge theo business key. |
| 2 | Fund Management Company Code | fnd_mgt_co_code | STRING |  |  |  |  | Mã định danh công ty QLQ. Map từ PK bảng nguồn. | FIMS.FUNDCOMPANY | Id | BK chính trong scope FIMS. ETL cần resolve sang surrogate của entity dùng chung. Pair với Source System Code để tạo composite BK. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.FUNDCOMPANY' | Mã nguồn dữ liệu. | FIMS.FUNDCOMPANY |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Fund Management Company Name | fnd_mgt_co_nm | STRING |  |  |  |  | Tên công ty QLQ. | FIMS.FUNDCOMPANY | Name |  |
| 5 | Fund Management Company Short Name | fnd_mgt_co_shrt_nm | STRING | X |  |  |  | Tên viết tắt (ghi là Tên tiếng Việt trong nguồn). | FIMS.FUNDCOMPANY | ShortName |  |
| 6 | Fund Management Company English Name | fnd_mgt_co_english_nm | STRING | X |  |  |  | Tên tiếng Anh. | FIMS.FUNDCOMPANY | EName |  |
| 7 | Practice Status Code | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động của công ty QLQ. | FIMS.FUNDCOMPANY |  | Scheme: FMS_OPERATION_STATUS. |
| 8 | Charter Capital Amount | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ (VNĐ). | FIMS.FUNDCOMPANY | Capital |  |
| 9 | Dorf Indicator | dorf_ind | STRING | X |  |  |  | Loại hình trong/ngoài nước. 1=Trong nước; 0=Nước ngoài. | FIMS.FUNDCOMPANY |  |  |
| 10 | License Decision Number | license_dcsn_nbr | STRING | X |  |  |  | Số quyết định/giấy phép thành lập. | FIMS.FUNDCOMPANY |  |  |
| 11 | License Decision Date | license_dcsn_dt | DATE | X |  |  |  | Ngày cấp phép. | FIMS.FUNDCOMPANY |  |  |
| 12 | Active Date | actv_dt | DATE | X |  |  |  | Ngày bắt đầu hoạt động. | FIMS.FUNDCOMPANY |  |  |
| 13 | Stop Date | stop_dt | DATE | X |  |  |  | Ngày ngừng hoạt động. | FIMS.FUNDCOMPANY |  |  |
| 14 | Business Type Codes | bsn_tp_codes | Array<Text> | X |  |  |  | Danh sách mã nghiệp vụ kinh doanh. Từ bảng junction FUNDCOMBUSINES. | FIMS.FUNDCOMPANY | BuId |  |
| 15 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FIMS.FUNDCOMPANY | CreatedBy |  |
| 16 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FIMS.FUNDCOMPANY | DateCreated |  |
| 17 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FIMS.FUNDCOMPANY | DateModified |  |
| 18 | Country of Registration Id | cty_of_rgst_id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký của công ty QLQ. | FIMS.FUNDCOMPANY | NaId |  |
| 19 | Country of Registration Code | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. | FIMS.FUNDCOMPANY | NaId |  |
| 20 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. | FIMS.FUNDCOMPANY | StatusId | Scheme: LIFE_CYCLE_STATUS. |
| 21 | Director Name | director_nm | STRING | X |  |  |  | Tên Tổng giám đốc (denormalized). | FIMS.FUNDCOMPANY | Director |  |
| 22 | Depository Certificate Number | depst_ctf_nbr | STRING | X |  |  |  | Chứng nhận lưu ký — thông tin bổ sung của FIMS không có trong FMS.SECURITIES. | FIMS.FUNDCOMPANY | DepCert |  |
| 23 | Company Type Codes | co_tp_codes | Array<Text> | X |  |  |  | Danh sách mã loại hình doanh nghiệp. Từ bảng junction FUNDCOMTYPE. | FIMS.FUNDCOMPANY | ComTypeId |  |
| 24 | Description | dsc | STRING | X |  |  |  | Ghi chú. | FIMS.FUNDCOMPANY | Description |  |
| 25 | Company Type Code | co_tp_code | STRING | X |  |  |  | Loại hình công ty. | FIMS.FUNDCOMPANY |  | Scheme: TT_COMPANY_TYPE. |
| 26 | Fund Type Code | fnd_tp_code | STRING | X |  |  |  | Loại quỹ (áp dụng cho quỹ đầu tư). | FIMS.FUNDCOMPANY |  | Scheme: TT_FUND_TYPE. |
| 27 | Business License Number | bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. | FIMS.FUNDCOMPANY |  |  |
| 28 | Website | webst | STRING | X |  |  |  | Website chính thức. | FIMS.FUNDCOMPANY |  |  |


#### 2.{IDX}.4.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Fund Management Company Id | fnd_mgt_co_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Country of Registration Id | cty_of_rgst_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.5 Bảng Securities Company

- **Mô tả:** Công ty chứng khoán - thành viên thị trường trong hệ thống FIMS. Quản lý tài khoản và danh mục NĐT nước ngoài.
- **Tên vật lý:** scr_co
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Securities Company Id | scr_co_id | BIGINT |  | X | P |  | Khóa đại diện cho công ty chứng khoán. | FIMS.SECURITIESCOMPANY |  | PK surrogate. |
| 2 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã định danh công ty chứng khoán. Map từ PK bảng nguồn. | FIMS.SECURITIESCOMPANY | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.SECURITIESCOMPANY' | Mã nguồn dữ liệu. | FIMS.SECURITIESCOMPANY |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Country of Registration Id | cty_of_rgst_id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký của công ty chứng khoán. | FIMS.SECURITIESCOMPANY | NaId |  |
| 5 | Country of Registration Code | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. | FIMS.SECURITIESCOMPANY | NaId |  |
| 6 | Full Name | full_nm | STRING |  |  |  |  | Tên công ty chứng khoán. | FIMS.SECURITIESCOMPANY | Name |  |
| 7 | English Name | english_nm | STRING | X |  |  |  | Tên tiếng Anh. | FIMS.SECURITIESCOMPANY | EName |  |
| 8 | Abbreviation | abr | STRING | X |  |  |  | Tên viết tắt. | FIMS.SECURITIESCOMPANY | ShortName |  |
| 9 | Charter Capital Amount | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ (VNĐ). | FIMS.SECURITIESCOMPANY | Capital |  |
| 10 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. | FIMS.SECURITIESCOMPANY | StatusId | Scheme: LIFE_CYCLE_STATUS. |
| 11 | Director Name | director_nm | STRING | X |  |  |  | Tên Tổng giám đốc (denormalized). | FIMS.SECURITIESCOMPANY | Director |  |
| 12 | Depository Certificate Number | depst_ctf_nbr | STRING | X |  |  |  | Chứng nhận lưu ký. | FIMS.SECURITIESCOMPANY | DepCert |  |
| 13 | Business Type Codes | bsn_tp_codes | Array<Text> | X |  |  |  | Danh sách mã nghiệp vụ kinh doanh. Từ bảng junction SECCOMBUSINES. | FIMS.SECURITIESCOMPANY | BuId |  |
| 14 | Company Type Codes | co_tp_codes | Array<Text> | X |  |  |  | Danh sách mã loại hình doanh nghiệp. Từ bảng junction SECCOMTYPE. | FIMS.SECURITIESCOMPANY | ComTypeId |  |
| 15 | Description | dsc | STRING | X |  |  |  | Ghi chú. | FIMS.SECURITIESCOMPANY | Description |  |
| 16 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FIMS.SECURITIESCOMPANY | CreatedBy |  |
| 17 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FIMS.SECURITIESCOMPANY | DateCreated |  |
| 18 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FIMS.SECURITIESCOMPANY | DateModified |  |
| 19 | Securities Company Business Key | scr_co_bsn_key | STRING | X |  |  |  | ID duy nhất của CTCK dùng liên thông hệ thống (BK nghiệp vụ). | FIMS.SECURITIESCOMPANY |  |  |
| 20 | Securities Company Business Code | scr_co_bsn_code | STRING | X |  |  |  | Mã số CTCK (mã nghiệp vụ ngắn). | FIMS.SECURITIESCOMPANY |  |  |
| 21 | Securities Company Name | scr_co_nm | STRING | X |  |  |  | Tên tiếng Việt công ty chứng khoán. | FIMS.SECURITIESCOMPANY |  |  |
| 22 | Securities Company English Name | scr_co_english_nm | STRING | X |  |  |  | Tên tiếng Anh công ty chứng khoán. | FIMS.SECURITIESCOMPANY |  |  |
| 23 | Securities Company Short Name | scr_co_shrt_nm | STRING | X |  |  |  | Tên viết tắt công ty chứng khoán. | FIMS.SECURITIESCOMPANY |  |  |
| 24 | Tax Code | tax_code | STRING | X |  |  |  | Mã số thuế. | FIMS.SECURITIESCOMPANY |  |  |
| 25 | Company Type Code | co_tp_code | STRING | X |  |  |  | Loại hình công ty. | FIMS.SECURITIESCOMPANY |  | Scheme: SCMS_COMPANY_TYPE. // Scheme: TT_COMPANY_TYPE. |
| 26 | Share Quantity | shr_qty | INT | X |  |  |  | Số lượng cổ phần. | FIMS.SECURITIESCOMPANY |  |  |
| 27 | Business Sector Codes | bsn_sctr_codes | Array<Text> | X |  |  |  | Danh sách mã ngành nghề kinh doanh. | FIMS.SECURITIESCOMPANY |  |  |
| 28 | Is Listed Indicator | is_list_ind | STRING | X |  |  |  | Cờ niêm yết: 1-Có niêm yết; 0-Không. | FIMS.SECURITIESCOMPANY |  |  |
| 29 | Stock Exchange Name | stk_exg_nm | STRING | X |  |  |  | Sàn niêm yết. | FIMS.SECURITIESCOMPANY |  |  |
| 30 | Securities Code | scr_code | STRING | X |  |  |  | Mã chứng khoán niêm yết. | FIMS.SECURITIESCOMPANY |  |  |
| 31 | Registration Date | rgst_dt | DATE | X |  |  |  | Ngày đăng ký CTDC. | FIMS.SECURITIESCOMPANY |  |  |
| 32 | Registration Decision Number | rgst_dcsn_nbr | STRING | X |  |  |  | Số quyết định đăng ký. | FIMS.SECURITIESCOMPANY |  |  |
| 33 | Termination Date | tmt_dt | DATE | X |  |  |  | Ngày kết thúc CTDC. | FIMS.SECURITIESCOMPANY |  |  |
| 34 | Termination Decision Number | tmt_dcsn_nbr | STRING | X |  |  |  | Số quyết định kết thúc. | FIMS.SECURITIESCOMPANY |  |  |
| 35 | Company Status Code | co_st_code | STRING | X |  |  |  | Trạng thái hoạt động của CTCK. | FIMS.SECURITIESCOMPANY |  | Scheme: SCMS_COMPANY_STATUS. |
| 36 | Is Draft Indicator | is_drft_ind | STRING | X |  |  |  | Cờ bảng tạm: 1-Bảng tạm; 0-Chính thức. | FIMS.SECURITIESCOMPANY |  |  |
| 37 | Business Activity Category Id | bsn_avy_cgy_id | BIGINT | X |  | F |  | FK đến ngành nghề kinh doanh (DM_NGANH_NGHE_KD). Nullable. | FIMS.SECURITIESCOMPANY |  |  |
| 38 | Business Activity Category Code | bsn_avy_cgy_code | STRING | X |  |  |  | Mã ngành nghề kinh doanh. | FIMS.SECURITIESCOMPANY |  |  |
| 39 | Business License Number | bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. | FIMS.SECURITIESCOMPANY |  |  |
| 40 | Website | webst | STRING | X |  |  |  | Website chính thức. | FIMS.SECURITIESCOMPANY |  |  |


#### 2.{IDX}.5.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Securities Company Id | scr_co_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Country of Registration Id | cty_of_rgst_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.6 Bảng Custodian Bank

- **Mô tả:** Ngân hàng lưu ký giám sát tài sản quỹ đầu tư chứng khoán được UBCKNN chấp thuận. Chịu trách nhiệm lưu giữ và giám sát tài sản của quỹ.
- **Tên vật lý:** cstd_bnk
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Custodian Bank Id | cstd_bnk_id | BIGINT |  | X | P |  | Khóa đại diện cho ngân hàng lưu ký giám sát. | FIMS.BANKMONI |  | PK surrogate. Entity dùng chung với FMS.BANKMONI — ETL merge theo business key. |
| 2 | Custodian Bank Code | cstd_bnk_code | STRING |  |  |  |  | Mã định danh ngân hàng LKGS. Map từ PK bảng nguồn. | FIMS.BANKMONI | Id | BK chính trong scope FIMS. ETL cần resolve sang surrogate của entity dùng chung. Pair với Source System Code để tạo composite BK. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.BANKMONI' | Mã nguồn dữ liệu. | FIMS.BANKMONI |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Custodian Bank Name | cstd_bnk_nm | STRING |  |  |  |  | Tên ngân hàng lưu ký giám sát. | FIMS.BANKMONI | Name |  |
| 5 | Custodian Bank Short Name | cstd_bnk_shrt_nm | STRING | X |  |  |  | Tên viết tắt. | FIMS.BANKMONI | ShortName |  |
| 6 | Practice Status Code | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động. | FIMS.BANKMONI |  | Scheme: FMS_OPERATION_STATUS. |
| 7 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FIMS.BANKMONI | CreatedBy |  |
| 8 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FIMS.BANKMONI | DateCreated |  |
| 9 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FIMS.BANKMONI | DateModified |  |
| 10 | Country of Registration Id | cty_of_rgst_id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký của ngân hàng LKGS. | FIMS.BANKMONI | NaId |  |
| 11 | Country of Registration Code | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. | FIMS.BANKMONI | NaId |  |
| 12 | Custodian Bank English Name | cstd_bnk_english_nm | STRING | X |  |  |  | Tên tiếng Anh. | FIMS.BANKMONI | EName |  |
| 13 | Charter Capital Amount | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ (VNĐ). Thông tin bổ sung của FIMS không có trong FMS.BANKMONI. | FIMS.BANKMONI | Capital |  |
| 14 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. | FIMS.BANKMONI | StatusId | Scheme: LIFE_CYCLE_STATUS. |
| 15 | Director Name | director_nm | STRING | X |  |  |  | Tên Tổng giám đốc (denormalized). | FIMS.BANKMONI | Director |  |
| 16 | Depository Certificate Number | depst_ctf_nbr | STRING | X |  |  |  | Chứng nhận lưu ký — thông tin bổ sung của FIMS không có trong FMS.BANKMONI. | FIMS.BANKMONI | DepCert |  |
| 17 | Description | dsc | STRING | X |  |  |  | Ghi chú. | FIMS.BANKMONI | Description |  |


#### 2.{IDX}.6.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Custodian Bank Id | cstd_bnk_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Country of Registration Id | cty_of_rgst_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.7 Bảng Fund Management Company Organization Unit

- **Mô tả:** Chi nhánh hoặc văn phòng đại diện của công ty quản lý quỹ trong nước. Có địa chỉ và giấy phép hoạt động riêng.
- **Tên vật lý:** fnd_mgt_co_ou
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Fund Management Company Organization Unit Id | fnd_mgt_co_ou_id | BIGINT |  | X | P |  | Khóa đại diện cho chi nhánh công ty QLQ. | FIMS.BRANCHS |  | PK surrogate. |
| 2 | Fund Management Company Organization Unit Code | fnd_mgt_co_ou_code | STRING |  |  |  |  | Mã định danh chi nhánh. Map từ PK bảng nguồn. | FIMS.BRANCHS | id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.BRANCHS' | Mã nguồn dữ liệu. | FIMS.BRANCHS |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Fund Management Company Id | fnd_mgt_co_id | BIGINT | X |  | F |  | FK đến công ty QLQ chủ quản. ETL resolve từ CompanyNameParent. | FIMS.BRANCHS | CompanyNameParent |  |
| 5 | Fund Management Company Code | fnd_mgt_co_code | STRING | X |  |  |  | Mã công ty QLQ chủ quản. | FIMS.BRANCHS | CompanyNameParent |  |
| 6 | Fund Management Company Organization Unit Name | fnd_mgt_co_ou_nm | STRING |  |  |  |  | Tên chi nhánh công ty QLQ. | FIMS.BRANCHS | name |  |
| 7 | Organization Unit Type Code | ou_tp_code | STRING | X |  |  |  | Loại đơn vị: CN hoặc VPĐD. | FIMS.BRANCHS |  | Scheme: FMS_ORGANIZATION_UNIT_TYPE. |
| 8 | Parent Organization Unit Id | prn_ou_id | BIGINT | X |  | F |  | FK tự thân — CN/VPĐD cha. | FIMS.BRANCHS |  |  |
| 9 | Parent Organization Unit Code | prn_ou_code | STRING | X |  |  |  | Mã CN/VPĐD cha. | FIMS.BRANCHS |  |  |
| 10 | Legal Representative Id | lgl_representative_id | BIGINT | X |  | F |  | FK đến người đại diện pháp luật của CN/VPĐD. | FIMS.BRANCHS |  |  |
| 11 | Legal Representative Code | lgl_representative_code | STRING | X |  |  |  | Mã người đại diện pháp luật. | FIMS.BRANCHS |  |  |
| 12 | Legal Representative Name | lgl_representative_nm | STRING | X |  |  |  | Tên người đại diện pháp luật (denormalized). | FIMS.BRANCHS |  |  |
| 13 | License Decision Number | license_dcsn_nbr | STRING | X |  |  |  | Số quyết định thành lập CN/VPĐD. | FIMS.BRANCHS |  |  |
| 14 | License Decision Date | license_dcsn_dt | DATE | X |  |  |  | Ngày cấp quyết định thành lập CN/VPĐD. | FIMS.BRANCHS |  |  |
| 15 | Voucher Number | vchr_nbr | STRING | X |  |  |  | Số chứng từ liên quan. | FIMS.BRANCHS |  |  |
| 16 | Voucher Date | vchr_dt | DATE | X |  |  |  | Ngày chứng từ. | FIMS.BRANCHS |  |  |
| 17 | Practice Status Code | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động. | FIMS.BRANCHS |  | Scheme: FMS_OPERATION_STATUS. |
| 18 | Stop Date | stop_dt | DATE | X |  |  |  | Ngày ngừng hoạt động. | FIMS.BRANCHS |  |  |
| 19 | Change Description | chg_dsc | STRING | X |  |  |  | Mô tả nội dung thay đổi. | FIMS.BRANCHS |  |  |
| 20 | Description | dsc | STRING | X |  |  |  | Ghi chú. | FIMS.BRANCHS | Description |  |
| 21 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FIMS.BRANCHS | CreatedBy |  |
| 22 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FIMS.BRANCHS | DateCreated |  |
| 23 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FIMS.BRANCHS | DateModified |  |
| 24 | Country of Registration Id | cty_of_rgst_id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký của công ty mẹ. | FIMS.BRANCHS | NaId |  |
| 25 | Country of Registration Code | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. | FIMS.BRANCHS | NaId |  |
| 26 | English Name | english_nm | STRING | X |  |  |  | Tên tiếng Anh. | FIMS.BRANCHS | ename |  |
| 27 | Abbreviation | abr | STRING | X |  |  |  | Tên viết tắt. | FIMS.BRANCHS | ShortName |  |
| 28 | Tax Code | tax_code | STRING | X |  |  |  | Mã số thuế. | FIMS.BRANCHS | CodeTax |  |
| 29 | Charter Capital Amount | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn được cấp (VNĐ). | FIMS.BRANCHS | Capital |  |
| 30 | Start Date | strt_dt | DATE | X |  |  |  | Hoạt động từ ngày. | FIMS.BRANCHS | StartDate |  |
| 31 | End Date | end_dt | DATE | X |  |  |  | Hoạt động đến ngày. | FIMS.BRANCHS | EndDate |  |
| 32 | Parent Company Name | prn_co_nm | STRING | X |  |  |  | Tên công ty mẹ (denormalized — nguồn ETL resolve FK). | FIMS.BRANCHS | CompanyNameParent |  |
| 33 | Parent Company Registration Number | prn_co_rgst_nbr | STRING | X |  |  |  | Số ĐKKD công ty mẹ (denormalized). | FIMS.BRANCHS | CertNoParent |  |
| 34 | Parent Company Address | prn_co_adr | STRING | X |  |  |  | Địa chỉ công ty mẹ (denormalized). | FIMS.BRANCHS | AddParent |  |
| 35 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. | FIMS.BRANCHS | StatusId | Scheme: LIFE_CYCLE_STATUS. |
| 36 | Business Type Codes | bsn_tp_codes | Array<Text> | X |  |  |  | Danh sách mã nghiệp vụ kinh doanh. Từ bảng junction BRANCHSBUSINES. | FIMS.BRANCHS | BuId |  |


#### 2.{IDX}.7.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Fund Management Company Organization Unit Id | fnd_mgt_co_ou_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Fund Management Company Id | fnd_mgt_co_id | Fund Management Company | Fund Management Company Id | fnd_mgt_co_id |
| Parent Organization Unit Id | prn_ou_id | Fund Management Company Organization Unit | Fund Management Company Organization Unit Id | fnd_mgt_co_ou_id |
| Legal Representative Id | lgl_representative_id | Fund Management Company Key Person | Fund Management Company Key Person Id | fnd_mgt_co_key_psn_id |
| Country of Registration Id | cty_of_rgst_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.8 Bảng Disclosure Representative

- **Mô tả:** Người hoặc tổ chức đại diện thực hiện công bố thông tin trên thị trường chứng khoán.
- **Tên vật lý:** dscl_representative
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Disclosure Representative Id | dscl_representative_id | BIGINT |  | X | P |  | Khóa đại diện cho người/tổ chức đại diện công bố thông tin. | FIMS.INFODISCREPRES |  | PK surrogate. |
| 2 | Disclosure Representative Code | dscl_representative_code | STRING |  |  |  |  | Mã định danh người đại diện CBTT. Map từ PK bảng nguồn. | FIMS.INFODISCREPRES | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.INFODISCREPRES' | Mã nguồn dữ liệu. | FIMS.INFODISCREPRES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Nationality Id | nationality_id | BIGINT | X |  | F |  | FK đến quốc tịch của người đại diện CBTT. | FIMS.INFODISCREPRES | NaId |  |
| 5 | Nationality Code | nationality_code | STRING | X |  |  |  | Mã quốc tịch. | FIMS.INFODISCREPRES | NaId |  |
| 6 | Full Name | full_nm | STRING |  |  |  |  | Tên người đại diện CBTT. | FIMS.INFODISCREPRES | Name |  |
| 7 | English Name | english_nm | STRING | X |  |  |  | Tên tiếng Anh. | FIMS.INFODISCREPRES | EName |  |
| 8 | Abbreviation | abr | STRING | X |  |  |  | Tên viết tắt. | FIMS.INFODISCREPRES | ShortName |  |
| 9 | Representative Type Code | representative_tp_code | STRING |  |  |  |  | Loại hình: 1: Cá nhân 2: Tổ chức. Phân biệt cá nhân và tổ chức là đầu mối CBTT. | FIMS.INFODISCREPRES | ObjectType | Scheme: FIMS_MEMBER_STATUS. Lưu ý: ObjectType dùng chung scheme hay riêng — kiểm tra với FIMS_CBTT_OBJECT_TYPE nếu cần tách. |
| 10 | Date Of Birth | dob | DATE | X |  |  |  | Ngày sinh (áp dụng khi là cá nhân). | FIMS.INFODISCREPRES | DateOfBirth |  |
| 11 | Gender Code | gnd_code | STRING | X |  |  |  | Giới tính: 1: Nam 2: Nữ. | FIMS.INFODISCREPRES | Sex | Scheme: IP_GENDER. modeler_defined nếu chưa có scheme. |
| 12 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. | FIMS.INFODISCREPRES | StatusId | Scheme: LIFE_CYCLE_STATUS. |
| 13 | Business Type Codes | bsn_tp_codes | Array<Text> | X |  |  |  | Danh sách mã nghiệp vụ kinh doanh. Từ bảng junction INDIREBUSINESS. | FIMS.INFODISCREPRES | BuId |  |
| 14 | Description | dsc | STRING | X |  |  |  | Mô tả. | FIMS.INFODISCREPRES | Description |  |
| 15 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FIMS.INFODISCREPRES | CreatedBy |  |
| 16 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FIMS.INFODISCREPRES | DateCreated |  |
| 17 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FIMS.INFODISCREPRES | DateModified |  |


#### 2.{IDX}.8.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Disclosure Representative Id | dscl_representative_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Nationality Id | nationality_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.9 Bảng Foreign Investor

- **Mô tả:** Danh mục nhà đầu tư đăng ký giao dịch trên thị trường chứng khoán. Bao gồm cá nhân và tổ chức, phân biệt bằng ObjectType.
- **Tên vật lý:** frgn_ivsr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Foreign Investor Id | frgn_ivsr_id | BIGINT |  | X | P |  | Khóa đại diện cho nhà đầu tư. | FIMS.INVESTOR |  | PK surrogate. |
| 2 | Foreign Investor Code | frgn_ivsr_code | STRING |  |  |  |  | Mã định danh nhà đầu tư. Map từ PK bảng nguồn. | FIMS.INVESTOR | id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.INVESTOR' | Mã nguồn dữ liệu. | FIMS.INVESTOR |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Nationality Id | nationality_id | BIGINT | X |  | F |  | FK đến quốc tịch của nhà đầu tư. | FIMS.INVESTOR | NaId |  |
| 5 | Nationality Code | nationality_code | STRING | X |  |  |  | Mã quốc tịch. | FIMS.INVESTOR | NaId |  |
| 6 | Securities Company Id | scr_co_id | BIGINT | X |  | F |  | FK đến công ty chứng khoán nơi mở tài khoản giao dịch. | FIMS.INVESTOR | SecComAddId |  |
| 7 | Securities Company Code | scr_co_code | STRING | X |  |  |  | Mã công ty chứng khoán nơi mở tài khoản. | FIMS.INVESTOR | SecComAddId |  |
| 8 | Custodian Bank Id | cstd_bnk_id | BIGINT | X |  | F |  | FK đến ngân hàng lưu ký nơi mở tài khoản. | FIMS.INVESTOR | BankAddId |  |
| 9 | Custodian Bank Code | cstd_bnk_code | STRING | X |  |  |  | Mã ngân hàng lưu ký nơi mở tài khoản. | FIMS.INVESTOR | BankAddId |  |
| 10 | Capital Account Custodian Bank Id | cptl_ac_cstd_bnk_id | BIGINT | X |  | F |  | FK đến ngân hàng lưu ký nơi mở tài khoản vốn đầu tư gián tiếp. | FIMS.INVESTOR | BankAddCapId |  |
| 11 | Capital Account Custodian Bank Code | cptl_ac_cstd_bnk_code | STRING | X |  |  |  | Mã ngân hàng lưu ký nơi mở tài khoản vốn đầu tư gián tiếp. | FIMS.INVESTOR | BankAddCapId |  |
| 12 | Investor Type Code | ivsr_tp_code | STRING | X |  |  |  | Loại NĐT. Dữ liệu lấy từ trường ID của bảng INVESTORTYPE. | FIMS.INVESTOR | InvestorTypeId | Scheme: FIMS_INVESTOR_TYPE. |
| 13 | Investor Object Type Code | ivsr_obj_tp_code | STRING |  |  |  |  | Loại hình NĐT: 1: Cá nhân 2: Tổ chức. Phân biệt grain cá nhân/tổ chức trong cùng entity. | FIMS.INVESTOR | ObjectType | Scheme: FIMS_COMPANY_TYPE. Lưu ý: xem có cần scheme riêng FIMS_INVESTOR_OBJECT_TYPE không. |
| 14 | Company Type Code | co_tp_code | STRING | X |  |  |  | Loại hình doanh nghiệp (áp dụng khi là tổ chức). | FIMS.INVESTOR | CompanyTypeId | Scheme: FIMS_COMPANY_TYPE. |
| 15 | Account Opening Object Type Code | ac_opn_obj_tp_code | STRING | X |  |  |  | Đối tượng mở tài khoản: 1: Công ty chứng khoán 2: Ngân hàng lưu ký. Phân biệt SecComAddId và BankAddId. | FIMS.INVESTOR | SysObjectType | Scheme: FIMS_INVESTOR_ACCOUNT_TYPE. modeler_defined — 2 giá trị: 1=CTCK 2=NHLK. |
| 16 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái: 1: Đang hoạt động 0: Dừng hoạt động. | FIMS.INVESTOR | StatusId | Scheme: LIFE_CYCLE_STATUS. |
| 17 | Transaction Code | txn_code | STRING | X |  |  |  | Mã số giao dịch trên thị trường chứng khoán. | FIMS.INVESTOR | TransactionCode |  |
| 18 | Depository Account Number | depst_ac_nbr | STRING | X |  |  |  | Số tài khoản lưu ký. | FIMS.INVESTOR | DepAccountNumber |  |
| 19 | Indirect Investment Capital Account Number | idr_ivsm_cptl_ac_nbr | STRING | X |  |  |  | Số tài khoản vốn đầu tư gián tiếp. | FIMS.INVESTOR | AccountInvesCapital |  |
| 20 | Full Name | full_nm | STRING | X |  |  |  | Họ tên nhà đầu tư (áp dụng khi là cá nhân). | FIMS.INVESTOR | name |  |
| 21 | English Name | english_nm | STRING | X |  |  |  | Tên tiếng Anh. | FIMS.INVESTOR | ename |  |
| 22 | Gender Code | gnd_code | STRING | X |  |  |  | Giới tính. | FIMS.INVESTOR | Sex | Scheme: IP_GENDER. |
| 23 | Date Of Birth | dob | DATE | X |  |  |  | Ngày sinh (áp dụng khi là cá nhân). | FIMS.INVESTOR | DateOfBirth |  |
| 24 | Director Name | director_nm | STRING | X |  |  |  | Tên đại diện GD (áp dụng khi là tổ chức — denormalized). | FIMS.INVESTOR | Director |  |
| 25 | Business Registration Number | bsn_rgst_nbr | STRING | X |  |  |  | Số GPKD (áp dụng khi là tổ chức). | FIMS.INVESTOR | BusinessNumber |  |
| 26 | Description | dsc | STRING | X |  |  |  | Mô tả. | FIMS.INVESTOR | Description |  |
| 27 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FIMS.INVESTOR | CreatedBy |  |
| 28 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FIMS.INVESTOR | DateCreated |  |
| 29 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FIMS.INVESTOR | DateModified |  |


#### 2.{IDX}.9.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Foreign Investor Id | frgn_ivsr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Nationality Id | nationality_id | Geographic Area | Geographic Area Id | geo_id |
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |
| Custodian Bank Id | cstd_bnk_id | Custodian Bank | Custodian Bank Id | cstd_bnk_id |
| Capital Account Custodian Bank Id | cptl_ac_cstd_bnk_id | Custodian Bank | Custodian Bank Id | cstd_bnk_id |




### 2.{IDX}.10 Bảng Disclosure Representative Key Person

- **Mô tả:** Nhân sự thực hiện công bố thông tin tại các tổ chức thành viên thị trường.
- **Tên vật lý:** dscl_representative_key_psn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Disclosure Representative Key Person Id | dscl_representative_key_psn_id | BIGINT |  | X | P |  | Khóa đại diện cho nhân sự thực hiện CBTT. | FIMS.TLPROFILES |  | PK surrogate. |
| 2 | Disclosure Representative Key Person Code | dscl_representative_key_psn_code | STRING |  |  |  |  | Mã định danh nhân sự CBTT. Map từ PK bảng nguồn. | FIMS.TLPROFILES | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.TLPROFILES' | Mã nguồn dữ liệu. | FIMS.TLPROFILES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Nationality Id | nationality_id | BIGINT | X |  | F |  | FK đến quốc tịch của nhân sự. | FIMS.TLPROFILES | NaId |  |
| 5 | Nationality Code | nationality_code | STRING | X |  |  |  | Mã quốc tịch. | FIMS.TLPROFILES | NaId |  |
| 6 | Fund Management Company Id | fnd_mgt_co_id | BIGINT | X |  | F |  | FK đến công ty QLQ (nullable — nhân sự có thể gắn với nhiều tổ chức). | FIMS.TLPROFILES | FundComId |  |
| 7 | Fund Management Company Code | fnd_mgt_co_code | STRING | X |  |  |  | Mã công ty QLQ. | FIMS.TLPROFILES | FundComId |  |
| 8 | Securities Company Id | scr_co_id | BIGINT | X |  | F |  | FK đến công ty chứng khoán (nullable). | FIMS.TLPROFILES | SecComId |  |
| 9 | Securities Company Code | scr_co_code | STRING | X |  |  |  | Mã công ty chứng khoán. | FIMS.TLPROFILES | SecComId |  |
| 10 | Custodian Bank Id | cstd_bnk_id | BIGINT | X |  | F |  | FK đến ngân hàng lưu ký giám sát (nullable). | FIMS.TLPROFILES | BankId |  |
| 11 | Custodian Bank Code | cstd_bnk_code | STRING | X |  |  |  | Mã ngân hàng lưu ký giám sát. | FIMS.TLPROFILES | BankId |  |
| 12 | Depository Center Id | depst_cntr_id | BIGINT | X |  | F |  | FK đến trung tâm lưu ký (nullable). | FIMS.TLPROFILES | DepCenId |  |
| 13 | Depository Center Code | depst_cntr_code | STRING | X |  |  |  | Mã trung tâm lưu ký. | FIMS.TLPROFILES | DepCenId |  |
| 14 | Stock Exchange Id | stk_exg_id | BIGINT | X |  | F |  | FK đến sở giao dịch chứng khoán (nullable). | FIMS.TLPROFILES | StockCenId |  |
| 15 | Stock Exchange Code | stk_exg_code | STRING | X |  |  |  | Mã sở giao dịch chứng khoán. | FIMS.TLPROFILES | StockCenId |  |
| 16 | Disclosure Representative Id | dscl_representative_id | BIGINT | X |  | F |  | FK đến người đại diện CBTT (nullable). | FIMS.TLPROFILES | InDiRepCenId |  |
| 17 | Disclosure Representative Code | dscl_representative_code | STRING | X |  |  |  | Mã người đại diện CBTT. | FIMS.TLPROFILES | InDiRepCenId |  |
| 18 | Degree Code | dgr_code | STRING | X |  |  |  | ID trình độ. Dữ liệu lấy từ trường ID của bảng DEGREE. | FIMS.TLPROFILES | DegreeId | Scheme: FIMS_DEGREE. |
| 19 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái nhân sự: 1: Còn hiệu lực 2: Hết hiệu lực 3: Vô thời hạn. | FIMS.TLPROFILES | StatusId | Scheme: LIFE_CYCLE_STATUS. |
| 20 | Member Object Type Code | mbr_obj_tp_code | STRING | X |  |  |  | Loại đối tượng: 1: Công ty QLQ 2: CTCK 3: NHLK 4: TTLK 5: SGDCK 6: Người đại diện CBTT 7: CN công ty QLQ NN tại VN. | FIMS.TLPROFILES | SystemObject | Scheme: FIMS_MEMBER_TYPE. modeler_defined — 7 giá trị enum. |
| 21 | Full Name | full_nm | STRING |  |  |  |  | Họ và tên nhân sự CBTT. | FIMS.TLPROFILES | Name |  |
| 22 | Date Of Birth | dob | DATE | X |  |  |  | Ngày sinh. | FIMS.TLPROFILES | DateOfBirth |  |
| 23 | Place Of Birth | plc_of_brth | STRING | X |  |  |  | Nơi sinh. | FIMS.TLPROFILES | PlaceOfBirth |  |
| 24 | Gender Code | gnd_code | STRING | X |  |  |  | Giới tính: 1: Nam 2: Nữ. | FIMS.TLPROFILES | Sex | Scheme: IP_GENDER. |
| 25 | Is Legal Representative Indicator | is_lgl_representative_ind | STRING | X |  |  |  | Là người đại diện pháp luật: 1: Có 0: Không. | FIMS.TLPROFILES | IsRepresentative |  |
| 26 | Legal Representative Email | lgl_representative_email | STRING | X |  |  |  | Email người đại diện pháp luật. | FIMS.TLPROFILES | EmailRepresentative |  |
| 27 | Work Start Date | wrk_strt_dt | DATE | X |  |  |  | Ngày bắt đầu làm việc. | FIMS.TLPROFILES | SWorkDTE |  |
| 28 | Work End Date | wrk_end_dt | DATE | X |  |  |  | Ngày kết thúc làm việc. | FIMS.TLPROFILES | FWorkDTE |  |
| 29 | Job Type Codes | job_tp_codes | Array<Text> | X |  |  |  | Danh sách mã chức vụ. Từ bảng junction TLPROJOB. | FIMS.TLPROFILES | JobId |  |
| 30 | Stockholder Type Codes | stockholder_tp_codes | Array<Text> | X |  |  |  | Danh sách mã loại cổ đông. Từ bảng junction TLPROSTOCKH. | FIMS.TLPROFILES | StockId |  |
| 31 | Description | dsc | STRING | X |  |  |  | Mô tả. | FIMS.TLPROFILES | Description |  |
| 32 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FIMS.TLPROFILES | CreatedBy |  |
| 33 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FIMS.TLPROFILES | DateCreated |  |
| 34 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FIMS.TLPROFILES | DateModified |  |


#### 2.{IDX}.10.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Disclosure Representative Key Person Id | dscl_representative_key_psn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Nationality Id | nationality_id | Geographic Area | Geographic Area Id | geo_id |
| Fund Management Company Id | fnd_mgt_co_id | Fund Management Company | Fund Management Company Id | fnd_mgt_co_id |
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |
| Custodian Bank Id | cstd_bnk_id | Custodian Bank | Custodian Bank Id | cstd_bnk_id |
| Depository Center Id | depst_cntr_id | Depository Center | Depository Center Id | depst_cntr_id |
| Stock Exchange Id | stk_exg_id | Stock Exchange | Stock Exchange Id | stk_exg_id |
| Disclosure Representative Id | dscl_representative_id | Disclosure Representative | Disclosure Representative Id | dscl_representative_id |




### 2.{IDX}.11 Bảng Report Template

- **Mô tả:** Biểu mẫu báo cáo đầu vào - khuôn mẫu tờ khai định kỳ mà thành viên thị trường phải nộp theo quy định.
- **Tên vật lý:** rpt_tpl
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Report Template Id | rpt_tpl_id | BIGINT |  | X | P |  | Khóa đại diện cho biểu mẫu báo cáo. | FIMS.RPTTEMP |  | PK surrogate. |
| 2 | Report Template Code | rpt_tpl_code | STRING |  |  |  |  | Mã biểu mẫu. Map từ PK bảng nguồn. | FIMS.RPTTEMP | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.RPTTEMP' | Mã nguồn dữ liệu. | FIMS.RPTTEMP |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Report Type Code | rpt_tp_code | STRING | X |  |  |  | Loại báo cáo. Dữ liệu lấy từ trường ID của bảng REPORTTYPE. | FIMS.RPTTEMP | ReportTypeId | Scheme: FIMS_REPORT_TYPE. |
| 5 | Report Template Name | rpt_tpl_nm | STRING |  |  |  |  | Tên biểu mẫu. | FIMS.RPTTEMP | Name |  |
| 6 | Report Template Business Code | rpt_tpl_bsn_code | STRING | X |  |  |  | Mã biểu mẫu (mã nghiệp vụ — khác với PK). | FIMS.RPTTEMP | Code |  |
| 7 | Legal Basis | lgl_bss | STRING | X |  |  |  | Căn cứ pháp lý. | FIMS.RPTTEMP | LegalBasis |  |
| 8 | Report Group Code | rpt_grp_code | STRING | X |  |  |  | Nhóm báo cáo: 1: Báo cáo CTQLQ 2: CTCK 3: NHLK 4: TTLK 5: SGDCK 6: Người đại diện CBTT 7: CN CTQLQ NN tại VN. | FIMS.RPTTEMP | ReportGroup | Scheme: FIMS_REPORT_GROUP. modeler_defined — 7 giá trị enum. |
| 9 | Reporting Subject Code | rpt_sbj_code | STRING | X |  |  |  | Đối tượng gửi báo cáo: 1: CTQLQ 2: CTCK 3: NHLK 4: TTLK 5: SGDCK 6: Người đại diện CBTT 7: CN CTQLQ NN tại VN. | FIMS.RPTTEMP | SystemObjects | Scheme: FIMS_MEMBER_TYPE. 7 giá trị enum — cùng tập với TLPROFILES.SystemObject. |
| 10 | Version | vrsn | STRING | X |  |  |  | Version biểu mẫu. | FIMS.RPTTEMP | Version |  |
| 11 | Effective Date | eff_dt | DATE | X |  |  |  | Ngày bắt đầu sử dụng biểu mẫu. | FIMS.RPTTEMP | DateUsed |  |
| 12 | Template Status Code | tpl_st_code | STRING | X |  |  |  | Trạng thái: 0: Bản nháp 1: Đang sử dụng 2: Không sử dụng. | FIMS.RPTTEMP | Status | Scheme: FIMS_TEMPLATE_STATUS. modeler_defined — 3 giá trị: 0=DRAFT 1=ACTIVE 2=INACTIVE. |
| 13 | Is Import Required Indicator | is_impr_rqd_ind | STRING | X |  |  |  | Báo cáo có import: 1: Có import 0: Không import. | FIMS.RPTTEMP | IsNeedImport |  |
| 14 | Is Self Period Setting Indicator | is_self_prd_setting_ind | STRING | X |  |  |  | Báo cáo do cán bộ UB tự thiết lập kỳ: 1: Có 0: Không. | FIMS.RPTTEMP | IsSelfMemberSetting |  |
| 15 | Is Public Disclosure Indicator | is_pblc_dscl_ind | STRING | X |  |  |  | Cho phép CBTT: 0: Không CBTT 1: Có CBTT. | FIMS.RPTTEMP | IsNeedPublic |  |
| 16 | Description | dsc | STRING | X |  |  |  | Mô tả. | FIMS.RPTTEMP | Description |  |
| 17 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FIMS.RPTTEMP | CreatedBy |  |
| 18 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FIMS.RPTTEMP | DateCreated |  |
| 19 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FIMS.RPTTEMP | DateModified |  |
| 20 | Function Category Id | fcn_cgy_id | BIGINT | X |  | F |  | FK đến danh mục chức năng (QT_CHUC_NANG). Nullable. | FIMS.RPTTEMP |  |  |
| 21 | Function Category Code | fcn_cgy_code | STRING | X |  |  |  | Mã danh mục chức năng. | FIMS.RPTTEMP |  |  |
| 22 | Report Direction Type Code | rpt_drc_tp_code | STRING | X |  |  |  | Chiều báo cáo: 0-Đầu vào; 1-Đầu ra. | FIMS.RPTTEMP |  | Scheme: SCMS_REPORT_DIRECTION_TYPE. |
| 23 | Version Date | vrsn_dt | DATE | X |  |  |  | Ngày thay đổi phiên bản. | FIMS.RPTTEMP |  |  |
| 24 | Is Active Flag | is_actv_f | BOOLEAN | X |  |  |  | Trạng thái sử dụng: 1-Sử dụng; 0-Không sử dụng. | FIMS.RPTTEMP |  |  |
| 25 | Is Summary Required Indicator | is_smy_rqd_ind | STRING | X |  |  |  | Yêu cầu nhập trích yếu: 0-Không bắt buộc; 1-Bắt buộc. | FIMS.RPTTEMP |  |  |
| 26 | Attachment File | attachment_file | STRING | X |  |  |  | Tệp đính kèm mẫu báo cáo. | FIMS.RPTTEMP |  |  |


#### 2.{IDX}.11.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Report Template Id | rpt_tpl_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.12 Bảng Geographic Area

- **Mô tả:** Đơn vị địa lý dùng làm FK tham chiếu: quốc gia/quốc tịch (COUNTRY), vùng/miền (REGION), tỉnh/thành phố mới/cũ (PROVINCE/PROVINCE_OLD), quận/huyện cũ (DISTRICT_OLD), phường/xã mới/cũ (WARD/WARD_OLD). Phân biệt bằng geographic_area_type_code. Hỗ trợ song song bộ danh mục pre- và post-sáp nhập hành chính 2025.
- **Tên vật lý:** geo
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Geographic Area Id | geo_id | BIGINT |  | X | P |  | Khóa đại diện cho khu vực địa lý. | FIMS.NATIONAL |  | PK surrogate. |
| 2 | Geographic Area Code | geo_code | STRING |  |  |  |  | Mã quốc tịch/quốc gia. Map từ PK bảng nguồn. | FIMS.NATIONAL | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.NATIONAL' | Mã nguồn dữ liệu. | FIMS.NATIONAL |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Geographic Area Short Code | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. | FIMS.NATIONAL | SName |  |
| 5 | Geographic Area Name | geo_nm | STRING |  |  |  |  | Tên quốc tịch/quốc gia. | FIMS.NATIONAL | Name |  |
| 6 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. | FIMS.NATIONAL | Status | Scheme: LIFE_CYCLE_STATUS. |
| 7 | Description | dsc | STRING | X |  |  |  | Mô tả. | FIMS.NATIONAL | Description |  |
| 8 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FIMS.NATIONAL | CreatedBy |  |
| 9 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FIMS.NATIONAL | DateCreated |  |
| 10 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FIMS.NATIONAL | DateModified |  |
| 11 | Geographic Area Type Code | geo_tp_code | STRING |  |  |  |  | Loại khu vực địa lý: COUNTRY — quốc gia/quốc tịch. | FIMS.NATIONAL |  | Scheme: GEOGRAPHIC_AREA_TYPE. ETL-derived: hardcode PROVINCE cho bảng này. // Scheme: GEOGRAPHIC_AREA_TYPE. ETL-derived: hardcode COUNTRY cho bảng này. |
| 12 | Geographic Area Business Code | geo_bsn_code | STRING | X |  |  |  | Mã quốc tịch/quốc gia (mã nghiệp vụ). | FIMS.NATIONAL |  |  |
| 13 | Note | note | STRING | X |  |  |  | Ghi chú. | FIMS.NATIONAL |  |  |


#### 2.{IDX}.12.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Geographic Area Id | geo_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.13 Bảng Reporting Period

- **Mô tả:** Kỳ báo cáo định kỳ (ngày/tuần/tháng/quý/bán niên/năm) mà thành viên thị trường phải nộp báo cáo lên UBCKNN.
- **Tên vật lý:** rpt_prd
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Reporting Period Id | rpt_prd_id | BIGINT |  | X | P |  | Khóa đại diện cho kỳ báo cáo. | FIMS.RPTPERIOD |  | PK surrogate. |
| 2 | Reporting Period Code | rpt_prd_code | STRING |  |  |  |  | Mã kỳ báo cáo. Map từ PK bảng nguồn. | FIMS.RPTPERIOD | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.RPTPERIOD' | Mã nguồn dữ liệu. | FIMS.RPTPERIOD |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Reporting Period Name | rpt_prd_nm | STRING |  |  |  |  | Tên kỳ báo cáo. | FIMS.RPTPERIOD |  |  |
| 5 | Reporting Period Type Code | rpt_prd_tp_code | STRING | X |  |  |  | Kỳ báo cáo: 1: Ngày 2: Tuần 3: Nửa tháng 4: Tháng 5: Quý 6: Bán niên 7: Năm. | FIMS.RPTPERIOD | PeriodType | Scheme: FIMS_PERIOD_TYPE. modeler_defined — 7 giá trị enum. |
| 6 | Is Active Flag | is_actv_f | BOOLEAN | X |  |  |  | Kỳ báo cáo đang hoạt động. | FIMS.RPTPERIOD |  |  |
| 7 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FIMS.RPTPERIOD | CreatedBy |  |
| 8 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FIMS.RPTPERIOD | DateCreated |  |
| 9 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FIMS.RPTPERIOD | DateModified |  |
| 10 | Self-set Period Id | self-set_prd_id | BIGINT | X |  | F |  | FK đến kỳ báo cáo do cán bộ UB tự thiết lập (SELFSETPD). Nullable. | FIMS.RPTPERIOD | SfPdId |  |
| 11 | Self-set Period Code | self-set_prd_code | STRING | X |  |  |  | Mã kỳ báo cáo tự thiết lập. | FIMS.RPTPERIOD | SfPdId |  |
| 12 | Report Template Id | rpt_tpl_id | BIGINT |  |  | F |  | FK đến biểu mẫu báo cáo áp dụng cho kỳ này. | FIMS.RPTPERIOD | RptId |  |
| 13 | Report Template Code | rpt_tpl_code | STRING |  |  |  |  | Mã biểu mẫu báo cáo. | FIMS.RPTPERIOD | RptId |  |
| 14 | Submission Deadline Date | submission_ddln_dt | DATE | X |  |  |  | Thời hạn gửi báo cáo muộn nhất (áp dụng cho kỳ ngày/tuần). | FIMS.RPTPERIOD | LatestSendDate |  |
| 15 | Submission Deadline Week | submission_ddln_wk | INT | X |  |  |  | Thời hạn gửi báo cáo muộn nhất (tuần). | FIMS.RPTPERIOD | LatestSendWeek |  |
| 16 | Repeat Interval | repeat_itrv | INT | X |  |  |  | Lặp lại sau bao nhiêu đơn vị kỳ. | FIMS.RPTPERIOD | RepeatTime |  |
| 17 | Counting Start Date | counting_strt_dt | DATE | X |  |  |  | Ngày bắt đầu tính hạn nộp báo cáo. | FIMS.RPTPERIOD | DateStartCount |  |
| 18 | Is Working Day Indicator | is_wrk_day_ind | STRING | X |  |  |  | Đơn vị tính hạn nộp: 0: Ngày lịch 1: Ngày làm việc. | FIMS.RPTPERIOD | IsWorkingDay |  |
| 19 | Submit Within Days | submit_wi_dys | INT | X |  |  |  | Số ngày/ngày làm việc được phép gửi báo cáo. | FIMS.RPTPERIOD | SendInDay |  |
| 20 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. | FIMS.RPTPERIOD | Status | Scheme: LIFE_CYCLE_STATUS. |
| 21 | Description | dsc | STRING | X |  |  |  | Ghi chú. | FIMS.RPTPERIOD | Description |  |


#### 2.{IDX}.13.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Reporting Period Id | rpt_prd_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Report Template Id | rpt_tpl_id | Report Template | Report Template Id | rpt_tpl_id |




### 2.{IDX}.14 Bảng Member Regulatory Report

- **Mô tả:** Báo cáo định kỳ của thành viên thị trường nộp lên UBCK. Ghi nhận biểu mẫu, kỳ, trạng thái nộp và thành viên nộp.
- **Tên vật lý:** mbr_reg_rpt
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Member Regulatory Report Id | mbr_reg_rpt_id | BIGINT |  | X | P |  | Khóa đại diện cho lần nộp báo cáo của thành viên. | FIMS.RPTMEMBER |  | PK surrogate. |
| 2 | Member Regulatory Report Code | mbr_reg_rpt_code | STRING |  |  |  |  | Mã lần nộp báo cáo. Map từ PK bảng nguồn. | FIMS.RPTMEMBER | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.RPTMEMBER' | Mã nguồn dữ liệu. | FIMS.RPTMEMBER |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Report Template Id | rpt_tpl_id | BIGINT |  |  | F |  | FK đến biểu mẫu báo cáo. | FIMS.RPTMEMBER | RptId |  |
| 5 | Report Template Code | rpt_tpl_code | STRING |  |  |  |  | Mã biểu mẫu báo cáo. | FIMS.RPTMEMBER | RptId |  |
| 6 | Reporting Period Id | rpt_prd_id | BIGINT |  |  | F |  | FK đến kỳ báo cáo. | FIMS.RPTMEMBER | PrdId |  |
| 7 | Reporting Period Code | rpt_prd_code | STRING |  |  |  |  | Mã kỳ báo cáo. | FIMS.RPTMEMBER | PrdId |  |
| 8 | Fund Management Company Id | fnd_mgt_co_id | BIGINT | X |  | F |  | FK đến công ty QLQ nộp báo cáo (ngữ cảnh nộp). | FIMS.RPTMEMBER | FundId |  |
| 9 | Fund Management Company Code | fnd_mgt_co_code | STRING | X |  |  |  | Mã công ty QLQ nộp báo cáo. | FIMS.RPTMEMBER | FundId |  |
| 10 | Securities Company Id | scr_co_id | BIGINT | X |  | F |  | FK đến công ty chứng khoán nộp báo cáo (ngữ cảnh nộp). | FIMS.RPTMEMBER | SecId |  |
| 11 | Securities Company Code | scr_co_code | STRING | X |  |  |  | Mã công ty chứng khoán nộp báo cáo. | FIMS.RPTMEMBER | SecId |  |
| 12 | Custodian Bank Id | cstd_bnk_id | BIGINT | X |  | F |  | FK đến ngân hàng lưu ký nộp báo cáo (ngữ cảnh nộp). | FIMS.RPTMEMBER | BankId |  |
| 13 | Custodian Bank Code | cstd_bnk_code | STRING | X |  |  |  | Mã ngân hàng lưu ký nộp báo cáo. | FIMS.RPTMEMBER | BankId |  |
| 14 | Depository Center Id | depst_cntr_id | BIGINT | X |  | F |  | FK đến trung tâm lưu ký nộp báo cáo (ngữ cảnh nộp). | FIMS.RPTMEMBER | DepId |  |
| 15 | Depository Center Code | depst_cntr_code | STRING | X |  |  |  | Mã trung tâm lưu ký nộp báo cáo. | FIMS.RPTMEMBER | DepId |  |
| 16 | Stock Exchange Id | stk_exg_id | BIGINT | X |  | F |  | FK đến sở giao dịch chứng khoán nộp báo cáo (ngữ cảnh nộp). | FIMS.RPTMEMBER | StockId |  |
| 17 | Stock Exchange Code | stk_exg_code | STRING | X |  |  |  | Mã sở giao dịch chứng khoán nộp báo cáo. | FIMS.RPTMEMBER | StockId |  |
| 18 | Foreign Investor Id | frgn_ivsr_id | BIGINT | X |  | F |  | FK đến nhà đầu tư nước ngoài nộp báo cáo (ngữ cảnh nộp). | FIMS.RPTMEMBER | InId |  |
| 19 | Foreign Investor Code | frgn_ivsr_code | STRING | X |  |  |  | Mã nhà đầu tư nước ngoài nộp báo cáo. | FIMS.RPTMEMBER | InId |  |
| 20 | Fund Management Company Organization Unit Id | fnd_mgt_co_ou_id | BIGINT | X |  | F |  | FK đến chi nhánh công ty QLQ NN nộp báo cáo (ngữ cảnh nộp). | FIMS.RPTMEMBER | BranId |  |
| 21 | Fund Management Company Organization Unit Code | fnd_mgt_co_ou_code | STRING | X |  |  |  | Mã chi nhánh công ty QLQ NN nộp báo cáo. | FIMS.RPTMEMBER | BranId |  |
| 22 | Report Type Code | rpt_tp_code | STRING | X |  |  |  | Loại báo cáo. Dữ liệu lấy từ trường ID của bảng REPORTTYPE. | FIMS.RPTMEMBER | ReportTypeId | Scheme: FIMS_REPORT_TYPE. |
| 23 | Member Object Type Code | mbr_obj_tp_code | STRING | X |  |  |  | Loại đối tượng nộp báo cáo: 1: Công ty QLQ 2: CTCK 3: NHLK 4: TTLK 5: SGDCK 6: Người đại diện CBTT 7: CN CTQLQ NN tại VN. | FIMS.RPTMEMBER | ObjectType | Scheme: FIMS_MEMBER_TYPE. |
| 24 | Is Import Indicator | is_impr_ind | STRING | X |  |  |  | Là báo cáo có import: 0: Không import 1: Có import. | FIMS.RPTMEMBER | IsImport |  |
| 25 | Report Name | rpt_nm | STRING | X |  |  |  | Tên báo cáo. | FIMS.RPTMEMBER | RptName |  |
| 26 | Report Year | rpt_yr | INT | X |  |  |  | Năm báo cáo. | FIMS.RPTMEMBER | YearValue |  |
| 27 | Period Value | prd_val | INT | X |  |  |  | Giá trị kỳ báo cáo (số thứ tự kỳ trong năm). | FIMS.RPTMEMBER | PeriodValue |  |
| 28 | Report Date | rpt_dt | DATE | X |  |  |  | Ngày báo cáo. | FIMS.RPTMEMBER | DayReport |  |
| 29 | Submission Deadline Date | submission_ddln_dt | DATE | X |  |  |  | Thời hạn gửi báo cáo. | FIMS.RPTMEMBER | DeadlineSend |  |
| 30 | Submission Status Code | submission_st_code | STRING | X |  |  |  | Trạng thái nộp: 1: Chưa gửi 2: Đã gửi 3: Gửi muộn 4: Bị hủy 5: Đã gửi lại. | FIMS.RPTMEMBER | Status | Scheme: FIMS_REPORT_SUBMISSION_STATUS. modeler_defined — 5 giá trị enum. |
| 31 | Submission Date | submission_dt | DATE | X |  |  |  | Ngày gửi báo cáo thực tế. | FIMS.RPTMEMBER | DateSubmitted |  |
| 32 | Content Summary | cntnt_smy | STRING | X |  |  |  | Nội dung trích yếu. | FIMS.RPTMEMBER | ContentSummary |  |
| 33 | Note | note | STRING | X |  |  |  | Ghi chú. | FIMS.RPTMEMBER | Note |  |
| 34 | Reporting Period Type Code | rpt_prd_tp_code | STRING | X |  |  |  | Kỳ báo cáo: 1: Ngày 2: Tuần 3: Nửa tháng 4: Tháng 5: Quý 6: Bán niên 7: Năm. | FIMS.RPTMEMBER | PeriodType | Scheme: FIMS_PERIOD_TYPE. Lưu lại kỳ tại thời điểm nộp — có thể khác RPTPERIOD nếu cấu hình thay đổi. |
| 35 | Is Working Day Indicator | is_wrk_day_ind | STRING | X |  |  |  | Là ngày làm việc: 1: Ngày làm việc 0: Ngày. | FIMS.RPTMEMBER | isWorkingDay |  |
| 36 | Submit Within Days | submit_wi_dys | INT | X |  |  |  | Số ngày được phép gửi báo cáo. | FIMS.RPTMEMBER | SendInDay |  |
| 37 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FIMS.RPTMEMBER | CreatedBy |  |
| 38 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FIMS.RPTMEMBER | DateCreated |  |
| 39 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FIMS.RPTMEMBER | DateModified |  |


#### 2.{IDX}.14.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Member Regulatory Report Id | mbr_reg_rpt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Report Template Id | rpt_tpl_id | Report Template | Report Template Id | rpt_tpl_id |
| Reporting Period Id | rpt_prd_id | Reporting Period | Reporting Period Id | rpt_prd_id |
| Fund Management Company Id | fnd_mgt_co_id | Fund Management Company | Fund Management Company Id | fnd_mgt_co_id |
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |
| Custodian Bank Id | cstd_bnk_id | Custodian Bank | Custodian Bank Id | cstd_bnk_id |
| Depository Center Id | depst_cntr_id | Depository Center | Depository Center Id | depst_cntr_id |
| Stock Exchange Id | stk_exg_id | Stock Exchange | Stock Exchange Id | stk_exg_id |
| Foreign Investor Id | frgn_ivsr_id | Foreign Investor | Foreign Investor Id | frgn_ivsr_id |
| Fund Management Company Organization Unit Id | fnd_mgt_co_ou_id | Fund Management Company Organization Unit | Fund Management Company Organization Unit Id | fnd_mgt_co_ou_id |




### 2.{IDX}.15 Bảng Member Conduct Violation

- **Mô tả:** Vi phạm được ghi nhận từ cảnh báo hệ thống hoặc kiểm tra định kỳ đối với thành viên thị trường.
- **Tên vật lý:** mbr_conduct_vln
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Member Conduct Violation Id | mbr_conduct_vln_id | BIGINT |  | X | P |  | Khóa đại diện cho vi phạm. | FIMS.VIOLT |  | PK surrogate. |
| 2 | Member Conduct Violation Code | mbr_conduct_vln_code | STRING |  |  |  |  | Mã vi phạm. Map từ PK bảng nguồn. | FIMS.VIOLT | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.VIOLT' | Mã nguồn dữ liệu. | FIMS.VIOLT |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Fund Management Company Id | fnd_mgt_co_id | BIGINT | X |  | F |  | FK đến công ty QLQ vi phạm (nullable — chỉ 1 trong các FK thành viên có giá trị). | FIMS.VIOLT | FundComId |  |
| 5 | Fund Management Company Code | fnd_mgt_co_code | STRING | X |  |  |  | Mã công ty QLQ vi phạm. | FIMS.VIOLT | FundComId |  |
| 6 | Securities Company Id | scr_co_id | BIGINT | X |  | F |  | FK đến công ty chứng khoán vi phạm. | FIMS.VIOLT | SecComId |  |
| 7 | Securities Company Code | scr_co_code | STRING | X |  |  |  | Mã công ty chứng khoán vi phạm. | FIMS.VIOLT | SecComId |  |
| 8 | Custodian Bank Id | cstd_bnk_id | BIGINT | X |  | F |  | FK đến ngân hàng lưu ký vi phạm. | FIMS.VIOLT | BankId |  |
| 9 | Custodian Bank Code | cstd_bnk_code | STRING | X |  |  |  | Mã ngân hàng lưu ký vi phạm. | FIMS.VIOLT | BankId |  |
| 10 | Depository Center Id | depst_cntr_id | BIGINT | X |  | F |  | FK đến trung tâm lưu ký vi phạm. | FIMS.VIOLT | DepCenId |  |
| 11 | Depository Center Code | depst_cntr_code | STRING | X |  |  |  | Mã trung tâm lưu ký vi phạm. | FIMS.VIOLT | DepCenId |  |
| 12 | Stock Exchange Id | stk_exg_id | BIGINT | X |  | F |  | FK đến sở giao dịch chứng khoán vi phạm. | FIMS.VIOLT | StockCenId |  |
| 13 | Stock Exchange Code | stk_exg_code | STRING | X |  |  |  | Mã sở giao dịch chứng khoán vi phạm. | FIMS.VIOLT | StockCenId |  |
| 14 | Disclosure Representative Id | dscl_representative_id | BIGINT | X |  | F |  | FK đến người đại diện CBTT vi phạm. | FIMS.VIOLT | InDiRepCenId |  |
| 15 | Disclosure Representative Code | dscl_representative_code | STRING | X |  |  |  | Mã người đại diện CBTT vi phạm. | FIMS.VIOLT | InDiRepCenId |  |
| 16 | Fund Management Company Organization Unit Id | fnd_mgt_co_ou_id | BIGINT | X |  | F |  | FK đến chi nhánh công ty QLQ NN vi phạm. | FIMS.VIOLT | BranchsId |  |
| 17 | Fund Management Company Organization Unit Code | fnd_mgt_co_ou_code | STRING | X |  |  |  | Mã chi nhánh công ty QLQ NN vi phạm. | FIMS.VIOLT | BranchsId |  |
| 18 | Warning Parameter Id | wrn_parm_id | BIGINT | X |  | F |  | FK đến tham số cảnh báo (PARAWARN). Nullable. | FIMS.VIOLT | PrWId |  |
| 19 | Warning Parameter Code | wrn_parm_code | STRING | X |  |  |  | Mã tham số cảnh báo. | FIMS.VIOLT | PrWId |  |
| 20 | Warning Condition Id | wrn_cd_id | BIGINT | X |  | F |  | FK đến điều kiện cảnh báo (CDTWARN). Nullable. | FIMS.VIOLT | CdtWId |  |
| 21 | Warning Condition Code | wrn_cd_code | STRING | X |  |  |  | Mã điều kiện cảnh báo. | FIMS.VIOLT | CdtWId |  |
| 22 | Member Object Type Code | mbr_obj_tp_code | STRING | X |  |  |  | Loại đối tượng vi phạm: 1: Công ty QLQ 2: CTCK 3: NHLK 4: TTLK 5: SGDCK 6: Người đại diện CBTT 7: CN CTQLQ NN tại VN. | FIMS.VIOLT | SystemObject | Scheme: FIMS_MEMBER_TYPE. |
| 23 | Investor Name | ivsr_nm | STRING | X |  |  |  | Nhà đầu tư liên quan (denormalized). | FIMS.VIOLT | InvestorName |  |
| 24 | Violation Year | vln_yr | INT | X |  |  |  | Năm cảnh báo vi phạm. | FIMS.VIOLT | YearValue |  |
| 25 | Violation Period Type Code | vln_prd_tp_code | STRING | X |  |  |  | Kỳ cảnh báo: 1: Ngày 2: Tuần 3: Nửa tháng 4: Tháng 5: Quý 6: Bán niên 7: Năm. | FIMS.VIOLT | PeriodType | Scheme: FIMS_PERIOD_TYPE. |
| 26 | Violation Period Value | vln_prd_val | INT | X |  |  |  | Giá trị kỳ cảnh báo. | FIMS.VIOLT | PeriodValue |  |
| 27 | Violation Status Code | vln_st_code | STRING | X |  |  |  | Trạng thái xử lý: 0: Chưa khắc phục 1: Khắc phục. | FIMS.VIOLT | Status | Scheme: FIMS_VIOLATION_STATUS. modeler_defined — 2 giá trị: 0=OPEN 1=RESOLVED. |
| 28 | Violation Value | vln_val | STRING | X |  |  |  | Giá trị vi phạm. | FIMS.VIOLT | Value |  |
| 29 | Violation Date | vln_dt | DATE | X |  |  |  | Ngày phát sinh cảnh báo vi phạm. | FIMS.VIOLT | DateCreatedViolt |  |
| 30 | Comparison Period Type Code | cmpr_prd_tp_code | STRING | X |  |  |  | Kỳ tham số so sánh. | FIMS.VIOLT | PeriodTypeOther | Scheme: FIMS_PERIOD_TYPE. Kỳ tham số dùng để so sánh với giá trị vi phạm. |
| 31 | Comparison Period Value | cmpr_prd_val | INT | X |  |  |  | Giá trị kỳ tham số so sánh. | FIMS.VIOLT | PeriodValueOther |  |
| 32 | Comparison Value | cmpr_val | STRING | X |  |  |  | Giá trị tham số so sánh. | FIMS.VIOLT | ValueOther |  |


#### 2.{IDX}.15.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Member Conduct Violation Id | mbr_conduct_vln_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Fund Management Company Id | fnd_mgt_co_id | Fund Management Company | Fund Management Company Id | fnd_mgt_co_id |
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |
| Custodian Bank Id | cstd_bnk_id | Custodian Bank | Custodian Bank Id | cstd_bnk_id |
| Depository Center Id | depst_cntr_id | Depository Center | Depository Center Id | depst_cntr_id |
| Stock Exchange Id | stk_exg_id | Stock Exchange | Stock Exchange Id | stk_exg_id |
| Disclosure Representative Id | dscl_representative_id | Disclosure Representative | Disclosure Representative Id | dscl_representative_id |
| Fund Management Company Organization Unit Id | fnd_mgt_co_ou_id | Fund Management Company Organization Unit | Fund Management Company Organization Unit Id | fnd_mgt_co_ou_id |




### 2.{IDX}.16 Bảng Disclosure Authorization

- **Mô tả:** Ủy quyền công bố thông tin của người đại diện CBTT cho nhà đầu tư nước ngoài. Ghi nhận bên được ủy quyền, loại quan hệ và thời hạn hiệu lực.
- **Tên vật lý:** dscl_ahr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Disclosure Authorization Id | dscl_ahr_id | BIGINT |  | X | P |  | Khóa đại diện cho ủy quyền CBTT. | FIMS.AUTHOANNOUNCE |  | PK surrogate. |
| 2 | Disclosure Authorization Code | dscl_ahr_code | STRING |  |  |  |  | Mã ủy quyền CBTT. Map từ PK bảng nguồn. | FIMS.AUTHOANNOUNCE | id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.AUTHOANNOUNCE' | Mã nguồn dữ liệu. | FIMS.AUTHOANNOUNCE |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Disclosure Representative Id | dscl_representative_id | BIGINT |  |  | F |  | FK đến người đại diện CBTT được ủy quyền. | FIMS.AUTHOANNOUNCE | InfoDiscRepresId |  |
| 5 | Disclosure Representative Code | dscl_representative_code | STRING |  |  |  |  | Mã người đại diện CBTT được ủy quyền. | FIMS.AUTHOANNOUNCE | InfoDiscRepresId |  |
| 6 | Relationship Type Code | rltnp_tp_code | STRING | X |  |  |  | Loại quan hệ ủy quyền. Dữ liệu lấy từ trường ID của bảng RELATIONSHIP. | FIMS.AUTHOANNOUNCE | RelationshipId | Scheme: FIMS_RELATIONSHIP_TYPE. Bảng RELATIONSHIP chỉ có cột Id — cần bổ sung cấu trúc. |
| 7 | Related Properties Code | rel_properties_code | STRING | X |  |  |  | Hình thức liên quan trong ủy quyền. Dữ liệu lấy từ trường ID của bảng RELATEDPROPERTIES. | FIMS.AUTHOANNOUNCE | RelatedPropertiesId | Scheme: FIMS_RELATED_PROPERTIES. |
| 8 | Effective Start Date | eff_strt_dt | DATE | X |  |  |  | Ngày bắt đầu có hiệu lực ủy quyền. | FIMS.AUTHOANNOUNCE | SDate |  |
| 9 | Effective End Date | eff_end_dt | DATE | X |  |  |  | Ngày kết thúc hiệu lực ủy quyền. | FIMS.AUTHOANNOUNCE | EDate |  |
| 10 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FIMS.AUTHOANNOUNCE | CreatedBy |  |
| 11 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FIMS.AUTHOANNOUNCE | DateCreated |  |
| 12 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FIMS.AUTHOANNOUNCE | DateModified |  |


#### 2.{IDX}.16.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Disclosure Authorization Id | dscl_ahr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Disclosure Representative Id | dscl_representative_id | Disclosure Representative | Disclosure Representative Id | dscl_representative_id |




### 2.{IDX}.17 Bảng Disclosure Announcement

- **Mô tả:** Tin công bố thông tin của thành viên thị trường qua người đại diện CBTT.
- **Tên vật lý:** dscl_ancm
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Disclosure Announcement Id | dscl_ancm_id | BIGINT |  | X | P |  | Khóa đại diện cho tin công bố thông tin. | FIMS.ANNOUNCE |  | PK surrogate. |
| 2 | Disclosure Announcement Code | dscl_ancm_code | STRING |  |  |  |  | Mã tin công bố. Map từ PK bảng nguồn. | FIMS.ANNOUNCE | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.ANNOUNCE' | Mã nguồn dữ liệu. | FIMS.ANNOUNCE |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Disclosure Representative Id | dscl_representative_id | BIGINT |  |  | F |  | FK đến người đại diện CBTT gửi tin. | FIMS.ANNOUNCE | InRepId |  |
| 5 | Disclosure Representative Code | dscl_representative_code | STRING |  |  |  |  | Mã người đại diện CBTT gửi tin. | FIMS.ANNOUNCE | InRepId |  |
| 6 | Announcement Type Code | ancm_tp_code | STRING | X |  |  |  | Loại CBTT. Dữ liệu lấy từ trường ID của bảng ANNOUNCETYPE. | FIMS.ANNOUNCE | AnnounceTypeId | Scheme: FIMS_ANNOUNCE_TYPE. |
| 7 | Announcement Title | ancm_ttl | STRING | X |  |  |  | Tiêu đề tin công bố. | FIMS.ANNOUNCE | Name |  |
| 8 | Content Summary | cntnt_smy | STRING | X |  |  |  | Nội dung trích yếu. | FIMS.ANNOUNCE | contentSummary |  |
| 9 | Announcement Date | ancm_dt | DATE | X |  |  |  | Ngày công bố thông tin. | FIMS.ANNOUNCE | DateAnnounce |  |
| 10 | Announcement Status Code | ancm_st_code | STRING | X |  |  |  | Trạng thái CBTT: 0: Chưa gửi 1: Đã CBTT. | FIMS.ANNOUNCE | Status | Scheme: FIMS_ANNOUNCEMENT_STATUS. modeler_defined — 2 giá trị: 0=PENDING 1=PUBLISHED. |
| 11 | Announcement Year | ancm_yr | INT | X |  |  |  | Năm báo cáo liên quan. | FIMS.ANNOUNCE | YearValue |  |
| 12 | Announcement Period Type Code | ancm_prd_tp_code | STRING | X |  |  |  | Kỳ báo cáo liên quan: 1: Ngày 2: Tuần 3: Nửa tháng 4: Tháng 5: Quý 6: Bán niên 7: Năm. | FIMS.ANNOUNCE | PeriodType | Scheme: FIMS_PERIOD_TYPE. |
| 13 | Announcement Period Value | ancm_prd_val | INT | X |  |  |  | Giá trị kỳ báo cáo liên quan. | FIMS.ANNOUNCE | PeriodValue |  |
| 14 | Sent By | snd_by | STRING | X |  |  |  | Người gửi tin CBTT (denormalized). | FIMS.ANNOUNCE | SendAnnounceBy |  |
| 15 | Description | dsc | STRING | X |  |  |  | Ghi chú. | FIMS.ANNOUNCE | Description |  |
| 16 | Foreign Investor Ids | frgn_ivsr_ids | Array<Struct> | X |  |  |  | Danh sách nhà đầu tư nước ngoài liên quan đến tin CBTT. InvesId → FK đến INVESTOR. | FIMS.ANNOUNCE | InvesId |  |
| 17 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FIMS.ANNOUNCE | CreatedBy |  |
| 18 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FIMS.ANNOUNCE | DateCreated |  |
| 19 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FIMS.ANNOUNCE | DateModified |  |


#### 2.{IDX}.17.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Disclosure Announcement Id | dscl_ancm_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Disclosure Representative Id | dscl_representative_id | Disclosure Representative | Disclosure Representative Id | dscl_representative_id |




### 2.{IDX}.18 Bảng Foreign Investor Securities Account

- **Mô tả:** Tài khoản giao dịch chứng khoán của nhà đầu tư nước ngoài tại công ty chứng khoán.
- **Tên vật lý:** frgn_ivsr_scr_ac
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Foreign Investor Securities Account Id | frgn_ivsr_scr_ac_id | BIGINT |  | X | P |  | Khóa đại diện cho tài khoản giao dịch chứng khoán. | FIMS.SECURITIESACCOUNT |  | PK surrogate. |
| 2 | Foreign Investor Securities Account Code | frgn_ivsr_scr_ac_code | STRING |  |  |  |  | Mã tài khoản. Map từ PK bảng nguồn. | FIMS.SECURITIESACCOUNT | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.SECURITIESACCOUNT' | Mã nguồn dữ liệu. | FIMS.SECURITIESACCOUNT |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Securities Company Id | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán nơi mở tài khoản. | FIMS.SECURITIESACCOUNT | SecId |  |
| 5 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán nơi mở tài khoản. | FIMS.SECURITIESACCOUNT | SecId |  |
| 6 | Foreign Investor Id | frgn_ivsr_id | BIGINT |  |  | F |  | FK đến nhà đầu tư nước ngoài chủ tài khoản. | FIMS.SECURITIESACCOUNT | InvesId |  |
| 7 | Foreign Investor Code | frgn_ivsr_code | STRING |  |  |  |  | Mã nhà đầu tư nước ngoài chủ tài khoản. | FIMS.SECURITIESACCOUNT | InvesId |  |
| 8 | Account Number | ac_nbr | STRING |  |  |  |  | Số tài khoản giao dịch chứng khoán. | FIMS.SECURITIESACCOUNT | Account |  |


#### 2.{IDX}.18.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Foreign Investor Securities Account Id | frgn_ivsr_scr_ac_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |
| Foreign Investor Id | frgn_ivsr_id | Foreign Investor | Foreign Investor Id | frgn_ivsr_id |




### 2.{IDX}.19 Bảng Foreign Investor Stock Portfolio Snapshot

- **Mô tả:** Danh mục sở hữu chứng khoán của nhà đầu tư nước ngoài tại từng công ty chứng khoán.
- **Tên vật lý:** frgn_ivsr_stk_prtfl_snpst
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Foreign Investor Stock Portfolio Snapshot Id | frgn_ivsr_stk_prtfl_snpst_id | BIGINT |  | X | P |  | Khóa đại diện cho vị thế sở hữu chứng khoán. | FIMS.CATEGORIESSTOCK |  | PK surrogate. |
| 2 | Foreign Investor Stock Portfolio Snapshot Code | frgn_ivsr_stk_prtfl_snpst_code | STRING |  |  |  |  | Mã vị thế. Map từ PK bảng nguồn. | FIMS.CATEGORIESSTOCK | id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.CATEGORIESSTOCK' | Mã nguồn dữ liệu. | FIMS.CATEGORIESSTOCK |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Securities Company Id | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán lưu giữ danh mục. | FIMS.CATEGORIESSTOCK | SecId |  |
| 5 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán lưu giữ danh mục. | FIMS.CATEGORIESSTOCK | SecId |  |
| 6 | Foreign Investor Id | frgn_ivsr_id | BIGINT |  |  | F |  | FK đến nhà đầu tư nước ngoài sở hữu danh mục. | FIMS.CATEGORIESSTOCK | InvesId |  |
| 7 | Foreign Investor Code | frgn_ivsr_code | STRING |  |  |  |  | Mã nhà đầu tư nước ngoài sở hữu danh mục. | FIMS.CATEGORIESSTOCK | InvesId |  |
| 8 | Quantity | qty | INT | X |  |  |  | Số lượng chứng khoán sở hữu. | FIMS.CATEGORIESSTOCK | Quantity |  |
| 9 | Ownership Rate | own_rate | DECIMAL(9,6) | X |  |  |  | Tỷ lệ % sở hữu chứng khoán. | FIMS.CATEGORIESSTOCK | Rate |  |


#### 2.{IDX}.19.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Foreign Investor Stock Portfolio Snapshot Id | frgn_ivsr_stk_prtfl_snpst_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |
| Foreign Investor Id | frgn_ivsr_id | Foreign Investor | Foreign Investor Id | frgn_ivsr_id |




### 2.{IDX}.20 Bảng Member Report Value

- **Mô tả:** Giá trị từng chỉ tiêu trong báo cáo định kỳ của thành viên. Mỗi dòng = 1 chỉ tiêu trong 1 báo cáo.
- **Tên vật lý:** mbr_rpt_val
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Member Report Value Id | mbr_rpt_val_id | BIGINT |  | X | P |  | Khóa đại diện cho giá trị chỉ tiêu báo cáo. | FIMS.RPTVALUES |  | PK surrogate. |
| 2 | Member Report Value Code | mbr_rpt_val_code | STRING |  |  |  |  | Mã giá trị chỉ tiêu. Map từ PK bảng nguồn. | FIMS.RPTVALUES | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.RPTVALUES' | Mã nguồn dữ liệu. | FIMS.RPTVALUES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Member Regulatory Report Id | mbr_reg_rpt_id | BIGINT |  |  | F |  | FK đến lần nộp báo cáo của thành viên. | FIMS.RPTVALUES | MebId |  |
| 5 | Member Regulatory Report Code | mbr_reg_rpt_code | STRING |  |  |  |  | Mã lần nộp báo cáo. | FIMS.RPTVALUES | MebId |  |
| 6 | Reporting Period Id | rpt_prd_id | BIGINT |  |  | F |  | FK đến kỳ báo cáo. | FIMS.RPTVALUES | PrdId |  |
| 7 | Reporting Period Code | rpt_prd_code | STRING |  |  |  |  | Mã kỳ báo cáo. | FIMS.RPTVALUES | PrdId |  |
| 8 | Report Template Id | rpt_tpl_id | BIGINT |  |  | F |  | FK đến biểu mẫu báo cáo. | FIMS.RPTVALUES | RptId |  |
| 9 | Report Template Code | rpt_tpl_code | STRING |  |  |  |  | Mã biểu mẫu báo cáo. | FIMS.RPTVALUES | RptId |  |
| 10 | Report Sheet Code | rpt_shet_code | STRING | X |  |  |  | Mã sheet báo cáo. Dữ liệu lấy từ trường ID của bảng SHEET. | FIMS.RPTVALUES | SheetId | Scheme: FIMS_REPORT_SHEET. |
| 11 | Cell Identifier | cell_id | STRING | X |  |  |  | UID ô dữ liệu trong sheet ẩn — định vị chỉ tiêu. | FIMS.RPTVALUES | TgtId |  |
| 12 | Cell Code | cell_code | STRING | X |  |  |  | Mã chỉ tiêu báo cáo. | FIMS.RPTVALUES | Code |  |
| 13 | Fund Management Company Id | fnd_mgt_co_id | BIGINT | X |  | F |  | FK đến công ty QLQ gửi báo cáo (nullable — chỉ 1 trong 7 FK thành viên có giá trị). | FIMS.RPTVALUES | FundId |  |
| 14 | Fund Management Company Code | fnd_mgt_co_code | STRING | X |  |  |  | Mã công ty QLQ gửi báo cáo. | FIMS.RPTVALUES | FundId |  |
| 15 | Securities Company Id | scr_co_id | BIGINT | X |  | F |  | FK đến công ty chứng khoán gửi báo cáo. | FIMS.RPTVALUES | SecId |  |
| 16 | Securities Company Code | scr_co_code | STRING | X |  |  |  | Mã công ty chứng khoán gửi báo cáo. | FIMS.RPTVALUES | SecId |  |
| 17 | Custodian Bank Id | cstd_bnk_id | BIGINT | X |  | F |  | FK đến ngân hàng lưu ký gửi báo cáo. | FIMS.RPTVALUES | BankId |  |
| 18 | Custodian Bank Code | cstd_bnk_code | STRING | X |  |  |  | Mã ngân hàng lưu ký gửi báo cáo. | FIMS.RPTVALUES | BankId |  |
| 19 | Depository Center Id | depst_cntr_id | BIGINT | X |  | F |  | FK đến trung tâm lưu ký gửi báo cáo. | FIMS.RPTVALUES | DepId |  |
| 20 | Depository Center Code | depst_cntr_code | STRING | X |  |  |  | Mã trung tâm lưu ký gửi báo cáo. | FIMS.RPTVALUES | DepId |  |
| 21 | Stock Exchange Id | stk_exg_id | BIGINT | X |  | F |  | FK đến sở giao dịch chứng khoán gửi báo cáo. | FIMS.RPTVALUES | StockId |  |
| 22 | Stock Exchange Code | stk_exg_code | STRING | X |  |  |  | Mã sở giao dịch chứng khoán gửi báo cáo. | FIMS.RPTVALUES | StockId |  |
| 23 | Disclosure Representative Id | dscl_representative_id | BIGINT | X |  | F |  | FK đến người đại diện CBTT gửi báo cáo. | FIMS.RPTVALUES | InId |  |
| 24 | Disclosure Representative Code | dscl_representative_code | STRING | X |  |  |  | Mã người đại diện CBTT gửi báo cáo. | FIMS.RPTVALUES | InId |  |
| 25 | Fund Management Company Organization Unit Id | fnd_mgt_co_ou_id | BIGINT | X |  | F |  | FK đến chi nhánh công ty QLQ NN tại VN gửi báo cáo. | FIMS.RPTVALUES | BranId |  |
| 26 | Fund Management Company Organization Unit Code | fnd_mgt_co_ou_code | STRING | X |  |  |  | Mã chi nhánh công ty QLQ NN tại VN gửi báo cáo. | FIMS.RPTVALUES | BranId |  |
| 27 | Member Object Type Code | mbr_obj_tp_code | STRING | X |  |  |  | Loại đối tượng gửi báo cáo: 1: Công ty QLQ 2: CTCK 3: NHLK 4: TTLK 5: SGDCK 6: Người đại diện CBTT 7: CN CTQLQ NN tại VN. | FIMS.RPTVALUES | Type | Scheme: FIMS_MEMBER_TYPE. Lưu lại tại thời điểm ghi giá trị — denormalized từ RPTMEMBER. |
| 28 | Reporting Period Type Code | rpt_prd_tp_code | STRING | X |  |  |  | Kỳ báo cáo: 1: Ngày 2: Tuần 3: Nửa tháng 4: Tháng 5: Quý 6: Bán niên 7: Năm. | FIMS.RPTVALUES | PeriodType | Scheme: FIMS_PERIOD_TYPE. Denormalized từ RPTMEMBER. |
| 29 | Period Value | prd_val | INT | X |  |  |  | Giá trị kỳ báo cáo. | FIMS.RPTVALUES | PeriodValue |  |
| 30 | Report Year | rpt_yr | INT | X |  |  |  | Năm báo cáo. | FIMS.RPTVALUES | YearValue |  |
| 31 | Cell Value | cell_val | STRING | X |  |  |  | Giá trị ô chỉ tiêu báo cáo. | FIMS.RPTVALUES | Values |  |
| 32 | Cell Data Type Code | cell_data_tp_code | STRING | X |  |  |  | Định dạng dữ liệu ô: kiểu số hoặc kiểu ký tự. | FIMS.RPTVALUES | FormatDataType | Scheme: FIMS_CELL_DATA_TYPE. |
| 33 | Is Dynamic Row Indicator | is_dynamic_row_ind | STRING | X |  |  |  | Là dòng động: 0: Không 1: Có. | FIMS.RPTVALUES | IsDynamic |  |
| 34 | Dynamic Row Index | dynamic_row_indx | INT | X |  |  |  | Chỉ số dòng động. | FIMS.RPTVALUES | RowDynamic |  |
| 35 | Source Table Name | src_tbl_nm | STRING | X |  |  |  | Tên bảng RPTVALUES nguồn (mỗi năm sinh 1 bảng riêng). | FIMS.RPTVALUES | TableName |  |
| 36 | Field Name | fld_nm | STRING | X |  |  |  | Tên file đính kèm (nếu có). | FIMS.RPTVALUES | FieldName |  |
| 37 | Selection Data | sel_data | STRING | X |  |  |  | Dữ liệu dạng ô cho phép chọn. | FIMS.RPTVALUES | Identification |  |
| 38 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FIMS.RPTVALUES | CreatedBy |  |
| 39 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FIMS.RPTVALUES | DateCreated |  |
| 40 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FIMS.RPTVALUES | DateModified |  |


#### 2.{IDX}.20.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Member Report Value Id | mbr_rpt_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Member Regulatory Report Id | mbr_reg_rpt_id | Member Regulatory Report | Member Regulatory Report Id | mbr_reg_rpt_id |
| Reporting Period Id | rpt_prd_id | Reporting Period | Reporting Period Id | rpt_prd_id |
| Report Template Id | rpt_tpl_id | Report Template | Report Template Id | rpt_tpl_id |
| Fund Management Company Id | fnd_mgt_co_id | Fund Management Company | Fund Management Company Id | fnd_mgt_co_id |
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |
| Custodian Bank Id | cstd_bnk_id | Custodian Bank | Custodian Bank Id | cstd_bnk_id |
| Depository Center Id | depst_cntr_id | Depository Center | Depository Center Id | depst_cntr_id |
| Stock Exchange Id | stk_exg_id | Stock Exchange | Stock Exchange Id | stk_exg_id |
| Disclosure Representative Id | dscl_representative_id | Disclosure Representative | Disclosure Representative Id | dscl_representative_id |
| Fund Management Company Organization Unit Id | fnd_mgt_co_ou_id | Fund Management Company Organization Unit | Fund Management Company Organization Unit Id | fnd_mgt_co_ou_id |




### 2.{IDX}.21 Bảng Involved Party Postal Address — FIMS.BANKMONI

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Custodian Bank. | FIMS.BANKMONI | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã ngân hàng lưu ký giám sát. | FIMS.BANKMONI | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.BANKMONI' | Mã nguồn dữ liệu. | FIMS.BANKMONI |  |  |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. | FIMS.BANKMONI |  |  |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở chính. | FIMS.BANKMONI | Address |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | FIMS.BANKMONI |  |  |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). | FIMS.BANKMONI |  |  |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. | FIMS.BANKMONI |  |  |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. | FIMS.BANKMONI |  |  |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | FIMS.BANKMONI |  |  |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | FIMS.BANKMONI |  |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | FIMS.BANKMONI |  |  |


#### 2.{IDX}.21.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Custodian Bank | Custodian Bank Id | cstd_bnk_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.22 Bảng Involved Party Electronic Address — FIMS.BANKMONI

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Custodian Bank. | FIMS.BANKMONI | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã ngân hàng lưu ký giám sát. | FIMS.BANKMONI | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.BANKMONI' | Mã nguồn dữ liệu. | FIMS.BANKMONI |  |  |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. | FIMS.BANKMONI |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Email. | FIMS.BANKMONI | Email |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Custodian Bank. | FIMS.BANKMONI | Id |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã ngân hàng lưu ký giám sát. | FIMS.BANKMONI | Id |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.BANKMONI' | Mã nguồn dữ liệu. | FIMS.BANKMONI |  |  |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. | FIMS.BANKMONI |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số fax. | FIMS.BANKMONI | Fax |  |
| 11 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Custodian Bank. | FIMS.BANKMONI | Id |  |
| 12 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã ngân hàng lưu ký giám sát. | FIMS.BANKMONI | Id |  |
| 13 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.BANKMONI' | Mã nguồn dữ liệu. | FIMS.BANKMONI |  |  |
| 14 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. | FIMS.BANKMONI |  |  |
| 15 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | FIMS.BANKMONI | Telephone |  |
| 16 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Custodian Bank. | FIMS.BANKMONI | Id |  |
| 17 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã ngân hàng lưu ký giám sát. | FIMS.BANKMONI | Id |  |
| 18 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.BANKMONI' | Mã nguồn dữ liệu. | FIMS.BANKMONI |  |  |
| 19 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. | FIMS.BANKMONI |  |  |
| 20 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Website. | FIMS.BANKMONI | Website |  |


#### 2.{IDX}.22.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Custodian Bank | Custodian Bank Id | cstd_bnk_id |




### 2.{IDX}.23 Bảng Involved Party Postal Address — FIMS.BRANCHS

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company Organization Unit. | FIMS.BRANCHS | id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã chi nhánh công ty quản lý quỹ. | FIMS.BRANCHS | id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.BRANCHS' | Mã nguồn dữ liệu. | FIMS.BRANCHS |  |  |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. | FIMS.BRANCHS |  |  |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở. | FIMS.BRANCHS | Address |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | FIMS.BRANCHS |  |  |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). | FIMS.BRANCHS |  |  |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. | FIMS.BRANCHS |  |  |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. | FIMS.BRANCHS |  |  |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | FIMS.BRANCHS |  |  |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | FIMS.BRANCHS |  |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | FIMS.BRANCHS |  |  |


#### 2.{IDX}.23.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Fund Management Company Organization Unit | Fund Management Company Organization Unit Id | fnd_mgt_co_ou_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.24 Bảng Involved Party Electronic Address — FIMS.BRANCHS

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company Organization Unit. | FIMS.BRANCHS | id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã chi nhánh công ty quản lý quỹ. | FIMS.BRANCHS | id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.BRANCHS' | Mã nguồn dữ liệu. | FIMS.BRANCHS |  |  |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. | FIMS.BRANCHS |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Email. | FIMS.BRANCHS | Email |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company Organization Unit. | FIMS.BRANCHS | id |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã chi nhánh công ty quản lý quỹ. | FIMS.BRANCHS | id |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.BRANCHS' | Mã nguồn dữ liệu. | FIMS.BRANCHS |  |  |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. | FIMS.BRANCHS |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số fax. | FIMS.BRANCHS | Fax |  |
| 11 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company Organization Unit. | FIMS.BRANCHS | id |  |
| 12 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã chi nhánh công ty quản lý quỹ. | FIMS.BRANCHS | id |  |
| 13 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.BRANCHS' | Mã nguồn dữ liệu. | FIMS.BRANCHS |  |  |
| 14 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. | FIMS.BRANCHS |  |  |
| 15 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | FIMS.BRANCHS | Telephone |  |
| 16 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company Organization Unit. | FIMS.BRANCHS | id |  |
| 17 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã chi nhánh công ty quản lý quỹ. | FIMS.BRANCHS | id |  |
| 18 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.BRANCHS' | Mã nguồn dữ liệu. | FIMS.BRANCHS |  |  |
| 19 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. | FIMS.BRANCHS |  |  |
| 20 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Website. | FIMS.BRANCHS | Website |  |


#### 2.{IDX}.24.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Fund Management Company Organization Unit | Fund Management Company Organization Unit Id | fnd_mgt_co_ou_id |




### 2.{IDX}.25 Bảng Involved Party Postal Address — FIMS.DEPOSITORYCENTER

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Depository Center. | FIMS.DEPOSITORYCENTER | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã Trung tâm lưu ký. | FIMS.DEPOSITORYCENTER | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.DEPOSITORYCENTER' | Mã nguồn dữ liệu. | FIMS.DEPOSITORYCENTER |  |  |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. | FIMS.DEPOSITORYCENTER |  |  |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở. | FIMS.DEPOSITORYCENTER | Address |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | FIMS.DEPOSITORYCENTER |  |  |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). | FIMS.DEPOSITORYCENTER |  |  |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. | FIMS.DEPOSITORYCENTER |  |  |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. | FIMS.DEPOSITORYCENTER |  |  |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | FIMS.DEPOSITORYCENTER |  |  |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | FIMS.DEPOSITORYCENTER |  |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | FIMS.DEPOSITORYCENTER |  |  |


#### 2.{IDX}.25.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Depository Center | Depository Center Id | depst_cntr_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.26 Bảng Involved Party Electronic Address — FIMS.DEPOSITORYCENTER

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Depository Center. | FIMS.DEPOSITORYCENTER | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã Trung tâm lưu ký. | FIMS.DEPOSITORYCENTER | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.DEPOSITORYCENTER' | Mã nguồn dữ liệu. | FIMS.DEPOSITORYCENTER |  |  |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. | FIMS.DEPOSITORYCENTER |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Email. | FIMS.DEPOSITORYCENTER | Email |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Depository Center. | FIMS.DEPOSITORYCENTER | Id |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã Trung tâm lưu ký. | FIMS.DEPOSITORYCENTER | Id |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.DEPOSITORYCENTER' | Mã nguồn dữ liệu. | FIMS.DEPOSITORYCENTER |  |  |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. | FIMS.DEPOSITORYCENTER |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số fax. | FIMS.DEPOSITORYCENTER | Fax |  |
| 11 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Depository Center. | FIMS.DEPOSITORYCENTER | Id |  |
| 12 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã Trung tâm lưu ký. | FIMS.DEPOSITORYCENTER | Id |  |
| 13 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.DEPOSITORYCENTER' | Mã nguồn dữ liệu. | FIMS.DEPOSITORYCENTER |  |  |
| 14 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'HOTLINE' | Loại kênh liên lạc — hotline. | FIMS.DEPOSITORYCENTER |  |  |
| 15 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số hotline. | FIMS.DEPOSITORYCENTER | Hotline |  |
| 16 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Depository Center. | FIMS.DEPOSITORYCENTER | Id |  |
| 17 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã Trung tâm lưu ký. | FIMS.DEPOSITORYCENTER | Id |  |
| 18 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.DEPOSITORYCENTER' | Mã nguồn dữ liệu. | FIMS.DEPOSITORYCENTER |  |  |
| 19 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. | FIMS.DEPOSITORYCENTER |  |  |
| 20 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | FIMS.DEPOSITORYCENTER | Telephone |  |
| 21 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Depository Center. | FIMS.DEPOSITORYCENTER | Id |  |
| 22 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã Trung tâm lưu ký. | FIMS.DEPOSITORYCENTER | Id |  |
| 23 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.DEPOSITORYCENTER' | Mã nguồn dữ liệu. | FIMS.DEPOSITORYCENTER |  |  |
| 24 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. | FIMS.DEPOSITORYCENTER |  |  |
| 25 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Website. | FIMS.DEPOSITORYCENTER | Website |  |


#### 2.{IDX}.26.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Depository Center | Depository Center Id | depst_cntr_id |




### 2.{IDX}.27 Bảng Involved Party Postal Address — FIMS.FUNDCOMPANY

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. | FIMS.FUNDCOMPANY | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. | FIMS.FUNDCOMPANY | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.FUNDCOMPANY' | Mã nguồn dữ liệu. | FIMS.FUNDCOMPANY |  |  |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. | FIMS.FUNDCOMPANY |  |  |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở. | FIMS.FUNDCOMPANY | Address |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | FIMS.FUNDCOMPANY |  |  |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). | FIMS.FUNDCOMPANY |  |  |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. | FIMS.FUNDCOMPANY |  |  |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. | FIMS.FUNDCOMPANY |  |  |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | FIMS.FUNDCOMPANY |  |  |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | FIMS.FUNDCOMPANY |  |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | FIMS.FUNDCOMPANY |  |  |


#### 2.{IDX}.27.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Fund Management Company | Fund Management Company Id | fnd_mgt_co_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.28 Bảng Involved Party Electronic Address — FIMS.FUNDCOMPANY

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. | FIMS.FUNDCOMPANY | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. | FIMS.FUNDCOMPANY | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.FUNDCOMPANY' | Mã nguồn dữ liệu. | FIMS.FUNDCOMPANY |  |  |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. | FIMS.FUNDCOMPANY |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Email. | FIMS.FUNDCOMPANY | Email |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. | FIMS.FUNDCOMPANY | Id |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. | FIMS.FUNDCOMPANY | Id |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.FUNDCOMPANY' | Mã nguồn dữ liệu. | FIMS.FUNDCOMPANY |  |  |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. | FIMS.FUNDCOMPANY |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số fax. | FIMS.FUNDCOMPANY | Fax |  |
| 11 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. | FIMS.FUNDCOMPANY | Id |  |
| 12 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. | FIMS.FUNDCOMPANY | Id |  |
| 13 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.FUNDCOMPANY' | Mã nguồn dữ liệu. | FIMS.FUNDCOMPANY |  |  |
| 14 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. | FIMS.FUNDCOMPANY |  |  |
| 15 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | FIMS.FUNDCOMPANY | Telephone |  |
| 16 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. | FIMS.FUNDCOMPANY | Id |  |
| 17 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. | FIMS.FUNDCOMPANY | Id |  |
| 18 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.FUNDCOMPANY' | Mã nguồn dữ liệu. | FIMS.FUNDCOMPANY |  |  |
| 19 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. | FIMS.FUNDCOMPANY |  |  |
| 20 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Website. | FIMS.FUNDCOMPANY | Website |  |


#### 2.{IDX}.28.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Fund Management Company | Fund Management Company Id | fnd_mgt_co_id |




### 2.{IDX}.29 Bảng Involved Party Postal Address — FIMS.INFODISCREPRES

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative. | FIMS.INFODISCREPRES | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người/tổ chức đại diện CBTT. | FIMS.INFODISCREPRES | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.INFODISCREPRES' | Mã nguồn dữ liệu. | FIMS.INFODISCREPRES |  |  |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  | 'ADDRESS' | Loại địa chỉ — địa chỉ chung. | FIMS.INFODISCREPRES |  |  |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ. | FIMS.INFODISCREPRES | Address |  |
| 6 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | FIMS.INFODISCREPRES |  |  |


#### 2.{IDX}.29.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Disclosure Representative | Disclosure Representative Id | dscl_representative_id |




### 2.{IDX}.30 Bảng Involved Party Electronic Address — FIMS.INFODISCREPRES

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative. | FIMS.INFODISCREPRES | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người/tổ chức đại diện CBTT. | FIMS.INFODISCREPRES | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.INFODISCREPRES' | Mã nguồn dữ liệu. | FIMS.INFODISCREPRES |  |  |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. | FIMS.INFODISCREPRES |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Email. | FIMS.INFODISCREPRES | Email |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative. | FIMS.INFODISCREPRES | Id |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người/tổ chức đại diện CBTT. | FIMS.INFODISCREPRES | Id |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.INFODISCREPRES' | Mã nguồn dữ liệu. | FIMS.INFODISCREPRES |  |  |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. | FIMS.INFODISCREPRES |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số fax. | FIMS.INFODISCREPRES | Fax |  |
| 11 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative. | FIMS.INFODISCREPRES | Id |  |
| 12 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người/tổ chức đại diện CBTT. | FIMS.INFODISCREPRES | Id |  |
| 13 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.INFODISCREPRES' | Mã nguồn dữ liệu. | FIMS.INFODISCREPRES |  |  |
| 14 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. | FIMS.INFODISCREPRES |  |  |
| 15 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | FIMS.INFODISCREPRES | Telephone |  |
| 16 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative. | FIMS.INFODISCREPRES | Id |  |
| 17 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người/tổ chức đại diện CBTT. | FIMS.INFODISCREPRES | Id |  |
| 18 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.INFODISCREPRES' | Mã nguồn dữ liệu. | FIMS.INFODISCREPRES |  |  |
| 19 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. | FIMS.INFODISCREPRES |  |  |
| 20 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Website. | FIMS.INFODISCREPRES | Website |  |


#### 2.{IDX}.30.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Disclosure Representative | Disclosure Representative Id | dscl_representative_id |




### 2.{IDX}.31 Bảng Involved Party Postal Address — FIMS.INVESTOR

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Foreign Investor. | FIMS.INVESTOR | id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã nhà đầu tư nước ngoài. | FIMS.INVESTOR | id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.INVESTOR' | Mã nguồn dữ liệu. | FIMS.INVESTOR |  |  |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  | 'ADDRESS' | Loại địa chỉ — địa chỉ chung. | FIMS.INVESTOR |  |  |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ nhà đầu tư. | FIMS.INVESTOR | Address |  |
| 6 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | FIMS.INVESTOR |  |  |


#### 2.{IDX}.31.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Foreign Investor | Foreign Investor Id | frgn_ivsr_id |




### 2.{IDX}.32 Bảng Involved Party Electronic Address — FIMS.INVESTOR

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Foreign Investor. | FIMS.INVESTOR | id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã nhà đầu tư nước ngoài. | FIMS.INVESTOR | id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.INVESTOR' | Mã nguồn dữ liệu. | FIMS.INVESTOR |  |  |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. | FIMS.INVESTOR |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Email. | FIMS.INVESTOR | Email |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Foreign Investor. | FIMS.INVESTOR | id |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã nhà đầu tư nước ngoài. | FIMS.INVESTOR | id |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.INVESTOR' | Mã nguồn dữ liệu. | FIMS.INVESTOR |  |  |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. | FIMS.INVESTOR |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số fax. | FIMS.INVESTOR | Fax |  |
| 11 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Foreign Investor. | FIMS.INVESTOR | id |  |
| 12 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã nhà đầu tư nước ngoài. | FIMS.INVESTOR | id |  |
| 13 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.INVESTOR' | Mã nguồn dữ liệu. | FIMS.INVESTOR |  |  |
| 14 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. | FIMS.INVESTOR |  |  |
| 15 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | FIMS.INVESTOR | Telephone |  |
| 16 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Foreign Investor. | FIMS.INVESTOR | id |  |
| 17 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã nhà đầu tư nước ngoài. | FIMS.INVESTOR | id |  |
| 18 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.INVESTOR' | Mã nguồn dữ liệu. | FIMS.INVESTOR |  |  |
| 19 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. | FIMS.INVESTOR |  |  |
| 20 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Website. | FIMS.INVESTOR | Website |  |


#### 2.{IDX}.32.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Foreign Investor | Foreign Investor Id | frgn_ivsr_id |




### 2.{IDX}.33 Bảng Involved Party Postal Address — FIMS.SECURITIESCOMPANY

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Securities Company. | FIMS.SECURITIESCOMPANY | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. | FIMS.SECURITIESCOMPANY | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.SECURITIESCOMPANY' | Mã nguồn dữ liệu. | FIMS.SECURITIESCOMPANY |  |  |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. | FIMS.SECURITIESCOMPANY |  |  |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở. | FIMS.SECURITIESCOMPANY | Address |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | FIMS.SECURITIESCOMPANY |  |  |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). | FIMS.SECURITIESCOMPANY |  |  |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. | FIMS.SECURITIESCOMPANY |  |  |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. | FIMS.SECURITIESCOMPANY |  |  |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | FIMS.SECURITIESCOMPANY |  |  |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | FIMS.SECURITIESCOMPANY |  |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | FIMS.SECURITIESCOMPANY |  |  |


#### 2.{IDX}.33.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Company | Securities Company Id | scr_co_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.34 Bảng Involved Party Electronic Address — FIMS.SECURITIESCOMPANY

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Securities Company. | FIMS.SECURITIESCOMPANY | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. | FIMS.SECURITIESCOMPANY | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.SECURITIESCOMPANY' | Mã nguồn dữ liệu. | FIMS.SECURITIESCOMPANY |  |  |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. | FIMS.SECURITIESCOMPANY |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Email. | FIMS.SECURITIESCOMPANY | Email |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Securities Company. | FIMS.SECURITIESCOMPANY | Id |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. | FIMS.SECURITIESCOMPANY | Id |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.SECURITIESCOMPANY' | Mã nguồn dữ liệu. | FIMS.SECURITIESCOMPANY |  |  |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. | FIMS.SECURITIESCOMPANY |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số fax. | FIMS.SECURITIESCOMPANY | Fax |  |
| 11 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Securities Company. | FIMS.SECURITIESCOMPANY | Id |  |
| 12 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. | FIMS.SECURITIESCOMPANY | Id |  |
| 13 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.SECURITIESCOMPANY' | Mã nguồn dữ liệu. | FIMS.SECURITIESCOMPANY |  |  |
| 14 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. | FIMS.SECURITIESCOMPANY |  |  |
| 15 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | FIMS.SECURITIESCOMPANY | Telephone |  |
| 16 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Securities Company. | FIMS.SECURITIESCOMPANY | Id |  |
| 17 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. | FIMS.SECURITIESCOMPANY | Id |  |
| 18 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.SECURITIESCOMPANY' | Mã nguồn dữ liệu. | FIMS.SECURITIESCOMPANY |  |  |
| 19 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. | FIMS.SECURITIESCOMPANY |  |  |
| 20 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Website. | FIMS.SECURITIESCOMPANY | Website |  |


#### 2.{IDX}.34.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Company | Securities Company Id | scr_co_id |




### 2.{IDX}.35 Bảng Involved Party Postal Address — FIMS.STOCKEXCHANGE

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Stock Exchange. | FIMS.STOCKEXCHANGE | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã Sở giao dịch chứng khoán. | FIMS.STOCKEXCHANGE | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.STOCKEXCHANGE' | Mã nguồn dữ liệu. | FIMS.STOCKEXCHANGE |  |  |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. | FIMS.STOCKEXCHANGE |  |  |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở. | FIMS.STOCKEXCHANGE | Address |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | FIMS.STOCKEXCHANGE |  |  |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). | FIMS.STOCKEXCHANGE |  |  |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. | FIMS.STOCKEXCHANGE |  |  |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. | FIMS.STOCKEXCHANGE |  |  |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | FIMS.STOCKEXCHANGE |  |  |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | FIMS.STOCKEXCHANGE |  |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | FIMS.STOCKEXCHANGE |  |  |


#### 2.{IDX}.35.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Stock Exchange | Stock Exchange Id | stk_exg_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.36 Bảng Involved Party Electronic Address — FIMS.STOCKEXCHANGE

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Stock Exchange. | FIMS.STOCKEXCHANGE | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã Sở giao dịch chứng khoán. | FIMS.STOCKEXCHANGE | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.STOCKEXCHANGE' | Mã nguồn dữ liệu. | FIMS.STOCKEXCHANGE |  |  |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. | FIMS.STOCKEXCHANGE |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Email. | FIMS.STOCKEXCHANGE | Email |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Stock Exchange. | FIMS.STOCKEXCHANGE | Id |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã Sở giao dịch chứng khoán. | FIMS.STOCKEXCHANGE | Id |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.STOCKEXCHANGE' | Mã nguồn dữ liệu. | FIMS.STOCKEXCHANGE |  |  |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. | FIMS.STOCKEXCHANGE |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số fax. | FIMS.STOCKEXCHANGE | Fax |  |
| 11 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Stock Exchange. | FIMS.STOCKEXCHANGE | Id |  |
| 12 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã Sở giao dịch chứng khoán. | FIMS.STOCKEXCHANGE | Id |  |
| 13 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.STOCKEXCHANGE' | Mã nguồn dữ liệu. | FIMS.STOCKEXCHANGE |  |  |
| 14 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'HOTLINE' | Loại kênh liên lạc — hotline. | FIMS.STOCKEXCHANGE |  |  |
| 15 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số hotline. | FIMS.STOCKEXCHANGE | Hotline |  |
| 16 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Stock Exchange. | FIMS.STOCKEXCHANGE | Id |  |
| 17 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã Sở giao dịch chứng khoán. | FIMS.STOCKEXCHANGE | Id |  |
| 18 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.STOCKEXCHANGE' | Mã nguồn dữ liệu. | FIMS.STOCKEXCHANGE |  |  |
| 19 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. | FIMS.STOCKEXCHANGE |  |  |
| 20 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | FIMS.STOCKEXCHANGE | Telephone |  |
| 21 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Stock Exchange. | FIMS.STOCKEXCHANGE | Id |  |
| 22 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã Sở giao dịch chứng khoán. | FIMS.STOCKEXCHANGE | Id |  |
| 23 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.STOCKEXCHANGE' | Mã nguồn dữ liệu. | FIMS.STOCKEXCHANGE |  |  |
| 24 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. | FIMS.STOCKEXCHANGE |  |  |
| 25 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Website. | FIMS.STOCKEXCHANGE | Website |  |


#### 2.{IDX}.36.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Stock Exchange | Stock Exchange Id | stk_exg_id |




### 2.{IDX}.37 Bảng Involved Party Postal Address — FIMS.TLPROFILES

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative Key Person. | FIMS.TLPROFILES | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã nhân sự CBTT. | FIMS.TLPROFILES | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.TLPROFILES' | Mã nguồn dữ liệu. | FIMS.TLPROFILES |  |  |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  | 'ADDRESS' | Loại địa chỉ — địa chỉ chung. | FIMS.TLPROFILES |  |  |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ nhân sự. | FIMS.TLPROFILES | Address |  |
| 6 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | FIMS.TLPROFILES |  |  |


#### 2.{IDX}.37.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Disclosure Representative Key Person | Disclosure Representative Key Person Id | dscl_representative_key_psn_id |




### 2.{IDX}.38 Bảng Involved Party Electronic Address — FIMS.TLPROFILES

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative Key Person. | FIMS.TLPROFILES | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã nhân sự CBTT. | FIMS.TLPROFILES | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.TLPROFILES' | Mã nguồn dữ liệu. | FIMS.TLPROFILES |  |  |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. | FIMS.TLPROFILES |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Email. | FIMS.TLPROFILES | Email |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative Key Person. | FIMS.TLPROFILES | Id |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã nhân sự CBTT. | FIMS.TLPROFILES | Id |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.TLPROFILES' | Mã nguồn dữ liệu. | FIMS.TLPROFILES |  |  |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. | FIMS.TLPROFILES |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | FIMS.TLPROFILES | Telephone |  |


#### 2.{IDX}.38.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Disclosure Representative Key Person | Disclosure Representative Key Person Id | dscl_representative_key_psn_id |




### 2.{IDX}.39 Bảng Involved Party Alternative Identification — FIMS.BANKMONI

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Custodian Bank. | FIMS.BANKMONI | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã ngân hàng lưu ký giám sát. | FIMS.BANKMONI | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.BANKMONI' | Mã nguồn dữ liệu. | FIMS.BANKMONI |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'BUSINESS_LICENSE' | Loại giấy tờ: giấy phép kinh doanh. | FIMS.BANKMONI |  | Scheme: IP_ALT_ID_TYPE. ETL-derived. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. | FIMS.BANKMONI | IdNo |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép kinh doanh. | FIMS.BANKMONI | IdDate |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy phép kinh doanh. | FIMS.BANKMONI | IdAdd |  |
| 8 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Custodian Bank. | FIMS.BANKMONI | Id |  |
| 9 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã ngân hàng lưu ký giám sát. | FIMS.BANKMONI | Id |  |
| 10 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.BANKMONI' | Mã nguồn dữ liệu. | FIMS.BANKMONI |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 11 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'OPERATING_LICENSE' | Loại giấy tờ: giấy phép đăng ký/hoạt động. | FIMS.BANKMONI |  | Scheme: IP_ALT_ID_TYPE. ETL-derived. |
| 12 | Identification Number | identn_nbr | STRING | X |  |  |  | Số giấy phép đăng ký/hoạt động. | FIMS.BANKMONI | RegNo |  |
| 13 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép đăng ký/hoạt động. | FIMS.BANKMONI | RegDate |  |
| 14 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy phép đăng ký/hoạt động. | FIMS.BANKMONI | RegAdd |  |


#### 2.{IDX}.39.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Custodian Bank | Custodian Bank Id | cstd_bnk_id |




### 2.{IDX}.40 Bảng Involved Party Alternative Identification — FIMS.BRANCHS

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company Organization Unit. | FIMS.BRANCHS | id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã chi nhánh công ty quản lý quỹ. | FIMS.BRANCHS | id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.BRANCHS' | Mã nguồn dữ liệu. | FIMS.BRANCHS |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'BUSINESS_LICENSE' | Loại giấy tờ: giấy phép kinh doanh. | FIMS.BRANCHS |  | Scheme: IP_ALT_ID_TYPE. ETL-derived. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. | FIMS.BRANCHS | IdNo |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép kinh doanh. | FIMS.BRANCHS | IdDate |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy phép kinh doanh. | FIMS.BRANCHS | IdAdd |  |
| 8 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company Organization Unit. | FIMS.BRANCHS | id |  |
| 9 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã chi nhánh công ty quản lý quỹ. | FIMS.BRANCHS | id |  |
| 10 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.BRANCHS' | Mã nguồn dữ liệu. | FIMS.BRANCHS |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 11 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'OPERATING_LICENSE' | Loại giấy tờ: giấy phép hoạt động. | FIMS.BRANCHS |  | Scheme: IP_ALT_ID_TYPE. ETL-derived. |
| 12 | Identification Number | identn_nbr | STRING | X |  |  |  | Số giấy phép hoạt động. | FIMS.BRANCHS | RegNo |  |
| 13 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép hoạt động. | FIMS.BRANCHS | RegDate |  |
| 14 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy phép hoạt động. | FIMS.BRANCHS | RegAdd |  |


#### 2.{IDX}.40.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Fund Management Company Organization Unit | Fund Management Company Organization Unit Id | fnd_mgt_co_ou_id |




### 2.{IDX}.41 Bảng Involved Party Alternative Identification — FIMS.FUNDCOMPANY

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. | FIMS.FUNDCOMPANY | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. | FIMS.FUNDCOMPANY | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.FUNDCOMPANY' | Mã nguồn dữ liệu. | FIMS.FUNDCOMPANY |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'BUSINESS_LICENSE' | Loại giấy tờ: giấy phép kinh doanh. | FIMS.FUNDCOMPANY |  | Scheme: IP_ALT_ID_TYPE. ETL-derived. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. | FIMS.FUNDCOMPANY | IdNo |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép kinh doanh. | FIMS.FUNDCOMPANY | IdDate |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy phép kinh doanh. | FIMS.FUNDCOMPANY | IdAdd |  |
| 8 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. | FIMS.FUNDCOMPANY | Id |  |
| 9 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. | FIMS.FUNDCOMPANY | Id |  |
| 10 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.FUNDCOMPANY' | Mã nguồn dữ liệu. | FIMS.FUNDCOMPANY |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 11 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'OPERATING_LICENSE' | Loại giấy tờ: giấy phép đăng ký/hoạt động. | FIMS.FUNDCOMPANY |  | Scheme: IP_ALT_ID_TYPE. ETL-derived. |
| 12 | Identification Number | identn_nbr | STRING | X |  |  |  | Số giấy phép đăng ký/hoạt động. | FIMS.FUNDCOMPANY | RegNo |  |
| 13 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép đăng ký/hoạt động. | FIMS.FUNDCOMPANY | RegDate |  |
| 14 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy phép đăng ký/hoạt động. | FIMS.FUNDCOMPANY | RegAdd |  |


#### 2.{IDX}.41.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Fund Management Company | Fund Management Company Id | fnd_mgt_co_id |




### 2.{IDX}.42 Bảng Involved Party Alternative Identification — FIMS.SECURITIESCOMPANY

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Securities Company. | FIMS.SECURITIESCOMPANY | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. | FIMS.SECURITIESCOMPANY | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.SECURITIESCOMPANY' | Mã nguồn dữ liệu. | FIMS.SECURITIESCOMPANY |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'BUSINESS_LICENSE' | Loại giấy tờ: giấy phép kinh doanh. | FIMS.SECURITIESCOMPANY |  | Scheme: IP_ALT_ID_TYPE. ETL-derived. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. | FIMS.SECURITIESCOMPANY | IdNo |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép kinh doanh. | FIMS.SECURITIESCOMPANY | IdDate |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy phép kinh doanh. | FIMS.SECURITIESCOMPANY | IdAdd |  |
| 8 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Securities Company. | FIMS.SECURITIESCOMPANY | Id |  |
| 9 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. | FIMS.SECURITIESCOMPANY | Id |  |
| 10 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.SECURITIESCOMPANY' | Mã nguồn dữ liệu. | FIMS.SECURITIESCOMPANY |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 11 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'OPERATING_LICENSE' | Loại giấy tờ: giấy phép đăng ký/hoạt động. | FIMS.SECURITIESCOMPANY |  | Scheme: IP_ALT_ID_TYPE. ETL-derived. |
| 12 | Identification Number | identn_nbr | STRING | X |  |  |  | Số giấy phép đăng ký/hoạt động. | FIMS.SECURITIESCOMPANY | RegNo |  |
| 13 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép đăng ký/hoạt động. | FIMS.SECURITIESCOMPANY | RegDate |  |
| 14 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy phép đăng ký/hoạt động. | FIMS.SECURITIESCOMPANY | RegAdd |  |


#### 2.{IDX}.42.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Company | Securities Company Id | scr_co_id |




### 2.{IDX}.43 Bảng Involved Party Alternative Identification — FIMS.INVESTOR

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Foreign Investor. | FIMS.INVESTOR | id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã nhà đầu tư nước ngoài. | FIMS.INVESTOR | id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.INVESTOR' | Mã nguồn dữ liệu. | FIMS.INVESTOR |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'CITIZEN_ID' | Loại giấy tờ: CCCD/Hộ chiếu. | FIMS.INVESTOR |  | Scheme: IP_ALT_ID_TYPE. ETL-derived — cần profile thêm để phân biệt CITIZEN_ID vs PASSPORT. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số CCCD/Hộ chiếu. | FIMS.INVESTOR | IdNo |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp CCCD/Hộ chiếu. | FIMS.INVESTOR | IdDate |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp CCCD/Hộ chiếu. | FIMS.INVESTOR | IdAdd |  |


#### 2.{IDX}.43.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Foreign Investor | Foreign Investor Id | frgn_ivsr_id |




### 2.{IDX}.44 Bảng Involved Party Alternative Identification — FIMS.TLPROFILES

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative Key Person. | FIMS.TLPROFILES | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã nhân sự CBTT. | FIMS.TLPROFILES | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.TLPROFILES' | Mã nguồn dữ liệu. | FIMS.TLPROFILES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'CITIZEN_ID' | Loại giấy tờ: CCCD/Hộ chiếu. | FIMS.TLPROFILES |  | Scheme: IP_ALT_ID_TYPE. ETL-derived — cần profile thêm để phân biệt CITIZEN_ID vs PASSPORT. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số CCCD/Hộ chiếu. | FIMS.TLPROFILES | IdNo |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp CCCD/Hộ chiếu. | FIMS.TLPROFILES | IdDate |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp CCCD/Hộ chiếu. | FIMS.TLPROFILES | IdAdd |  |
| 8 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative Key Person. | FIMS.TLPROFILES | Id |  |
| 9 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã nhân sự CBTT. | FIMS.TLPROFILES | Id |  |
| 10 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.TLPROFILES' | Mã nguồn dữ liệu. | FIMS.TLPROFILES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 11 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'PRACTITIONER_LICENSE' | Loại giấy tờ: chứng chỉ hành nghề. | FIMS.TLPROFILES |  | Scheme: IP_ALT_ID_TYPE. ETL-derived. |
| 12 | Identification Number | identn_nbr | STRING | X |  |  |  | Số chứng chỉ hành nghề. | FIMS.TLPROFILES | CertNo |  |
| 13 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp chứng chỉ hành nghề. | FIMS.TLPROFILES | CertDate |  |
| 14 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp chứng chỉ hành nghề. | FIMS.TLPROFILES | CertAdd |  |


#### 2.{IDX}.44.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Disclosure Representative Key Person | Disclosure Representative Key Person Id | dscl_representative_key_psn_id |




### 2.{IDX}.45 Bảng Involved Party Alternative Identification — FIMS.INFODISCREPRES

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative. | FIMS.INFODISCREPRES | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người/tổ chức đại diện CBTT. | FIMS.INFODISCREPRES | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.INFODISCREPRES' | Mã nguồn dữ liệu. | FIMS.INFODISCREPRES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'BUSINESS_LICENSE' | Loại giấy tờ: giấy phép đăng ký kinh doanh. | FIMS.INFODISCREPRES |  | Scheme: IP_ALT_ID_TYPE. ETL-derived. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số giấy phép đăng ký kinh doanh. | FIMS.INFODISCREPRES | CertNo |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép điều chỉnh. | FIMS.INFODISCREPRES |  |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Cơ quan cấp giấy phép thành lập | FIMS.INFODISCREPRES |  |  |
| 8 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative. | FIMS.INFODISCREPRES | Id |  |
| 9 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người/tổ chức đại diện CBTT. | FIMS.INFODISCREPRES | Id |  |
| 10 | Source System Code | src_stm_code | STRING |  |  |  | 'FIMS.INFODISCREPRES' | Mã nguồn dữ liệu. | FIMS.INFODISCREPRES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 11 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'CITIZEN_ID' | Loại giấy tờ: CCCD. | FIMS.INFODISCREPRES |  | Scheme: IP_ALT_ID_TYPE. ETL-derived. |
| 12 | Identification Number | identn_nbr | STRING | X |  |  |  | Số CCCD. | FIMS.INFODISCREPRES | IdAdd |  |
| 13 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp CCCD. | FIMS.INFODISCREPRES | IdDate |  |
| 14 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp CCCD. | FIMS.INFODISCREPRES | IdNo |  |


#### 2.{IDX}.45.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Disclosure Representative | Disclosure Representative Id | dscl_representative_id |




