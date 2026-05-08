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

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | stk_exg | Sở giao dịch chứng khoán - thành viên thị trường trong hệ thống FIMS (HNX, HOSE). |
| 2 | depst_cntr | Trung tâm lưu ký chứng khoán quốc gia - thành viên thị trường trong hệ thống FIMS (VSD). |
| 3 | fnd_mgt_co | Công ty quản lý quỹ đầu tư chứng khoán trong nước được UBCKNN cấp phép hoạt động. Lưu thông tin pháp lý và hoạt động của công ty. |
| 4 | scr_co | Công ty chứng khoán - thành viên thị trường trong hệ thống FIMS. Quản lý tài khoản và danh mục NĐT nước ngoài. |
| 5 | cstd_bnk | Ngân hàng lưu ký giám sát tài sản quỹ đầu tư chứng khoán được UBCKNN chấp thuận. Chịu trách nhiệm lưu giữ và giám sát tài sản của quỹ. |
| 6 | fnd_mgt_co_ou | Chi nhánh hoặc văn phòng đại diện của công ty quản lý quỹ trong nước. Có địa chỉ và giấy phép hoạt động riêng. |
| 7 | dscl_rprs | Người hoặc tổ chức đại diện thực hiện công bố thông tin trên thị trường chứng khoán. |
| 8 | frgn_ivsr | Danh mục nhà đầu tư đăng ký giao dịch trên thị trường chứng khoán. Bao gồm cá nhân và tổ chức, phân biệt bằng ObjectType. |
| 9 | dscl_rprs_key_psn | Nhân sự thực hiện công bố thông tin tại các tổ chức thành viên thị trường. |
| 10 | rpt_tpl | Biểu mẫu báo cáo đầu vào - khuôn mẫu tờ khai định kỳ mà thành viên thị trường phải nộp theo quy định. |
| 11 | geo | Đơn vị địa lý dùng làm FK tham chiếu: quốc gia/quốc tịch (COUNTRY), vùng/miền (REGION), tỉnh/thành phố mới/cũ (PROVINCE/PROVINCE_OLD), quận/huyện cũ (DISTRICT_OLD), phường/xã mới/cũ (WARD/WARD_OLD). Phân biệt bằng geographic_area_type_code. Hỗ trợ song song bộ danh mục pre- và post-sáp nhập hành chính 2025. |
| 12 | rpt_prd | Kỳ báo cáo định kỳ (ngày/tuần/tháng/quý/bán niên/năm) mà thành viên thị trường phải nộp báo cáo lên UBCKNN. |
| 13 | mbr_reg_rpt | Báo cáo định kỳ của thành viên thị trường nộp lên UBCK. Ghi nhận biểu mẫu, kỳ, trạng thái nộp và thành viên nộp. |
| 14 | mbr_conduct_vln | Vi phạm được ghi nhận từ cảnh báo hệ thống hoặc kiểm tra định kỳ đối với thành viên thị trường. |
| 15 | dscl_ahr | Ủy quyền công bố thông tin của người đại diện CBTT cho nhà đầu tư nước ngoài. Ghi nhận bên được ủy quyền, loại quan hệ và thời hạn hiệu lực. |
| 16 | dscl_ancm | Tin công bố thông tin của thành viên thị trường qua người đại diện CBTT. |
| 17 | frgn_ivsr_scr_ac | Tài khoản giao dịch chứng khoán của nhà đầu tư nước ngoài tại công ty chứng khoán. |
| 18 | frgn_ivsr_stk_prtfl_snpst | Danh mục sở hữu chứng khoán của nhà đầu tư nước ngoài tại từng công ty chứng khoán. |
| 19 | mbr_rpt_val | Giá trị từng chỉ tiêu trong báo cáo định kỳ của thành viên. Mỗi dòng = 1 chỉ tiêu trong 1 báo cáo. |
| 20 | ip_pst_adr | Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn. |
| 21 | ip_elc_adr | Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn. |
| 22 | ip_alt_identn | Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn. |




### 2.{IDX}.2 Bảng stk_exg



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


#### 2.{IDX}.2.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| stk_exg_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| cty_of_rgst_id | geo | geo_id |






### 2.{IDX}.3 Bảng depst_cntr



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


#### 2.{IDX}.3.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| depst_cntr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| cty_of_rgst_id | geo | geo_id |






### 2.{IDX}.4 Bảng fnd_mgt_co



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | fnd_mgt_co_id | BIGINT |  | X | P |  | Khóa đại diện cho công ty quản lý quỹ. |
| 2 | fnd_mgt_co_code | STRING |  |  |  |  | Mã định danh công ty QLQ. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.FUNDCOMPANY' | Mã nguồn dữ liệu. |
| 4 | fnd_mgt_co_nm | STRING |  |  |  |  | Tên công ty QLQ. |
| 5 | fnd_mgt_co_shrt_nm | STRING | X |  |  |  | Tên viết tắt (ghi là Tên tiếng Việt trong nguồn). |
| 6 | fnd_mgt_co_en_nm | STRING | X |  |  |  | Tên tiếng Anh. |
| 7 | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động của công ty QLQ. |
| 8 | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ (VNĐ). |
| 9 | dorf_ind | STRING | X |  |  |  | Loại hình trong/ngoài nước. 1=Trong nước; 0=Nước ngoài. |
| 10 | license_dcsn_nbr | STRING | X |  |  |  | Số quyết định/giấy phép thành lập. |
| 11 | license_dcsn_dt | DATE | X |  |  |  | Ngày cấp phép. |
| 12 | actv_dt | DATE | X |  |  |  | Ngày bắt đầu hoạt động. |
| 13 | stop_dt | DATE | X |  |  |  | Ngày ngừng hoạt động. |
| 14 | bsn_tp_codes | Array<Text> | X |  |  |  | Danh sách mã nghiệp vụ kinh doanh. Từ bảng junction FUNDCOMBUSINES. |
| 15 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 16 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 17 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 18 | cty_of_rgst_id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký của công ty QLQ. |
| 19 | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. |
| 20 | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. |
| 21 | director_nm | STRING | X |  |  |  | Tên Tổng giám đốc (denormalized). |
| 22 | depst_ctf_nbr | STRING | X |  |  |  | Chứng nhận lưu ký — thông tin bổ sung của FIMS không có trong FMS.SECURITIES. |
| 23 | co_tp_codes | Array<Text> | X |  |  |  | Danh sách mã loại hình doanh nghiệp. Từ bảng junction FUNDCOMTYPE. |
| 24 | dsc | STRING | X |  |  |  | Ghi chú. |
| 25 | co_tp_code | STRING | X |  |  |  | Loại hình công ty. |
| 26 | fnd_tp_code | STRING | X |  |  |  | Loại quỹ (áp dụng cho quỹ đầu tư). |
| 27 | bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. |
| 28 | webst | STRING | X |  |  |  | Website chính thức. |


#### 2.{IDX}.4.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| fnd_mgt_co_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| cty_of_rgst_id | geo | geo_id |






### 2.{IDX}.5 Bảng scr_co



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_co_id | BIGINT |  | X | P |  | Khóa đại diện cho công ty chứng khoán. |
| 2 | scr_co_code | STRING |  |  |  |  | Mã định danh công ty chứng khoán. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.SECURITIESCOMPANY' | Mã nguồn dữ liệu. |
| 4 | cty_of_rgst_id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký của công ty chứng khoán. |
| 5 | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. |
| 6 | full_nm | STRING |  |  |  |  | Tên công ty chứng khoán. |
| 7 | en_nm | STRING | X |  |  |  | Tên tiếng Anh. |
| 8 | abr | STRING | X |  |  |  | Tên viết tắt. |
| 9 | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ (VNĐ). |
| 10 | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. |
| 11 | director_nm | STRING | X |  |  |  | Tên Tổng giám đốc (denormalized). |
| 12 | depst_ctf_nbr | STRING | X |  |  |  | Chứng nhận lưu ký. |
| 13 | bsn_tp_codes | Array<Text> | X |  |  |  | Danh sách mã nghiệp vụ kinh doanh. Từ bảng junction SECCOMBUSINES. |
| 14 | co_tp_codes | Array<Text> | X |  |  |  | Danh sách mã loại hình doanh nghiệp. Từ bảng junction SECCOMTYPE. |
| 15 | dsc | STRING | X |  |  |  | Ghi chú. |
| 16 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 17 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 18 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 19 | scr_co_bsn_key | STRING | X |  |  |  | ID duy nhất của CTCK dùng liên thông hệ thống (BK nghiệp vụ). |
| 20 | scr_co_bsn_code | STRING | X |  |  |  | Mã số CTCK (mã nghiệp vụ ngắn). |
| 21 | scr_co_nm | STRING | X |  |  |  | Tên tiếng Việt công ty chứng khoán. |
| 22 | scr_co_en_nm | STRING | X |  |  |  | Tên tiếng Anh công ty chứng khoán. |
| 23 | scr_co_shrt_nm | STRING | X |  |  |  | Tên viết tắt công ty chứng khoán. |
| 24 | tax_code | STRING | X |  |  |  | Mã số thuế. |
| 25 | co_tp_code | STRING | X |  |  |  | Loại hình công ty. |
| 26 | shr_qty | INT | X |  |  |  | Số lượng cổ phần. |
| 27 | bsn_sctr_codes | Array<Text> | X |  |  |  | Danh sách mã ngành nghề kinh doanh. |
| 28 | is_list_ind | STRING | X |  |  |  | Cờ niêm yết: 1-Có niêm yết; 0-Không. |
| 29 | stk_exg_nm | STRING | X |  |  |  | Sàn niêm yết. |
| 30 | scr_code | STRING | X |  |  |  | Mã chứng khoán niêm yết. |
| 31 | rgst_dt | DATE | X |  |  |  | Ngày đăng ký CTDC. |
| 32 | rgst_dcsn_nbr | STRING | X |  |  |  | Số quyết định đăng ký. |
| 33 | tmt_dt | DATE | X |  |  |  | Ngày kết thúc CTDC. |
| 34 | tmt_dcsn_nbr | STRING | X |  |  |  | Số quyết định kết thúc. |
| 35 | co_st_code | STRING | X |  |  |  | Trạng thái hoạt động của CTCK. |
| 36 | is_drft_ind | STRING | X |  |  |  | Cờ bảng tạm: 1-Bảng tạm; 0-Chính thức. |
| 37 | bsn_avy_cgy_id | BIGINT | X |  | F |  | FK đến ngành nghề kinh doanh (DM_NGANH_NGHE_KD). Nullable. |
| 38 | bsn_avy_cgy_code | STRING | X |  |  |  | Mã ngành nghề kinh doanh. |
| 39 | bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. |
| 40 | webst | STRING | X |  |  |  | Website chính thức. |


#### 2.{IDX}.5.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_co_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| cty_of_rgst_id | geo | geo_id |






### 2.{IDX}.6 Bảng cstd_bnk



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | cstd_bnk_id | BIGINT |  | X | P |  | Khóa đại diện cho ngân hàng lưu ký giám sát. |
| 2 | cstd_bnk_code | STRING |  |  |  |  | Mã định danh ngân hàng LKGS. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.BANKMONI' | Mã nguồn dữ liệu. |
| 4 | cstd_bnk_nm | STRING |  |  |  |  | Tên ngân hàng lưu ký giám sát. |
| 5 | cstd_bnk_shrt_nm | STRING | X |  |  |  | Tên viết tắt. |
| 6 | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động. |
| 7 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 8 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 9 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 10 | cty_of_rgst_id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký của ngân hàng LKGS. |
| 11 | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. |
| 12 | cstd_bnk_en_nm | STRING | X |  |  |  | Tên tiếng Anh. |
| 13 | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ (VNĐ). Thông tin bổ sung của FIMS không có trong FMS.BANKMONI. |
| 14 | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. |
| 15 | director_nm | STRING | X |  |  |  | Tên Tổng giám đốc (denormalized). |
| 16 | depst_ctf_nbr | STRING | X |  |  |  | Chứng nhận lưu ký — thông tin bổ sung của FIMS không có trong FMS.BANKMONI. |
| 17 | dsc | STRING | X |  |  |  | Ghi chú. |


#### 2.{IDX}.6.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| cstd_bnk_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| cty_of_rgst_id | geo | geo_id |






### 2.{IDX}.7 Bảng fnd_mgt_co_ou



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | fnd_mgt_co_ou_id | BIGINT |  | X | P |  | Khóa đại diện cho chi nhánh công ty QLQ. |
| 2 | fnd_mgt_co_ou_code | STRING |  |  |  |  | Mã định danh chi nhánh. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.BRANCHS' | Mã nguồn dữ liệu. |
| 4 | fnd_mgt_co_id | BIGINT | X |  | F |  | FK đến công ty QLQ chủ quản. ETL resolve từ CompanyNameParent. |
| 5 | fnd_mgt_co_code | STRING | X |  |  |  | Mã công ty QLQ chủ quản. |
| 6 | fnd_mgt_co_ou_nm | STRING |  |  |  |  | Tên chi nhánh công ty QLQ. |
| 7 | ou_tp_code | STRING | X |  |  |  | Loại đơn vị: CN hoặc VPĐD. |
| 8 | prn_ou_id | BIGINT | X |  | F |  | FK tự thân — CN/VPĐD cha. |
| 9 | prn_ou_code | STRING | X |  |  |  | Mã CN/VPĐD cha. |
| 10 | lgl_rprs_id | BIGINT | X |  | F |  | FK đến người đại diện pháp luật của CN/VPĐD. |
| 11 | lgl_rprs_code | STRING | X |  |  |  | Mã người đại diện pháp luật. |
| 12 | lgl_rprs_nm | STRING | X |  |  |  | Tên người đại diện pháp luật (denormalized). |
| 13 | license_dcsn_nbr | STRING | X |  |  |  | Số quyết định thành lập CN/VPĐD. |
| 14 | license_dcsn_dt | DATE | X |  |  |  | Ngày cấp quyết định thành lập CN/VPĐD. |
| 15 | vchr_nbr | STRING | X |  |  |  | Số chứng từ liên quan. |
| 16 | vchr_dt | DATE | X |  |  |  | Ngày chứng từ. |
| 17 | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động. |
| 18 | stop_dt | DATE | X |  |  |  | Ngày ngừng hoạt động. |
| 19 | chg_dsc | STRING | X |  |  |  | Mô tả nội dung thay đổi. |
| 20 | dsc | STRING | X |  |  |  | Ghi chú. |
| 21 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 22 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 23 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 24 | cty_of_rgst_id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký của công ty mẹ. |
| 25 | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. |
| 26 | en_nm | STRING | X |  |  |  | Tên tiếng Anh. |
| 27 | abr | STRING | X |  |  |  | Tên viết tắt. |
| 28 | tax_code | STRING | X |  |  |  | Mã số thuế. |
| 29 | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn được cấp (VNĐ). |
| 30 | strt_dt | DATE | X |  |  |  | Hoạt động từ ngày. |
| 31 | end_dt | DATE | X |  |  |  | Hoạt động đến ngày. |
| 32 | prn_co_nm | STRING | X |  |  |  | Tên công ty mẹ (denormalized — nguồn ETL resolve FK). |
| 33 | prn_co_rgst_nbr | STRING | X |  |  |  | Số ĐKKD công ty mẹ (denormalized). |
| 34 | prn_co_adr | STRING | X |  |  |  | Địa chỉ công ty mẹ (denormalized). |
| 35 | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. |
| 36 | bsn_tp_codes | Array<Text> | X |  |  |  | Danh sách mã nghiệp vụ kinh doanh. Từ bảng junction BRANCHSBUSINES. |


#### 2.{IDX}.7.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| fnd_mgt_co_ou_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| fnd_mgt_co_id | fnd_mgt_co | fnd_mgt_co_id |
| prn_ou_id | fnd_mgt_co_ou | fnd_mgt_co_ou_id |
| lgl_rprs_id | fnd_mgt_co_key_psn | fnd_mgt_co_key_psn_id |
| cty_of_rgst_id | geo | geo_id |






### 2.{IDX}.8 Bảng dscl_rprs



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | dscl_rprs_id | BIGINT |  | X | P |  | Khóa đại diện cho người/tổ chức đại diện công bố thông tin. |
| 2 | dscl_rprs_code | STRING |  |  |  |  | Mã định danh người đại diện CBTT. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.INFODISCREPRES' | Mã nguồn dữ liệu. |
| 4 | nat_id | BIGINT | X |  | F |  | FK đến quốc tịch của người đại diện CBTT. |
| 5 | nat_code | STRING | X |  |  |  | Mã quốc tịch. |
| 6 | full_nm | STRING |  |  |  |  | Tên người đại diện CBTT. |
| 7 | en_nm | STRING | X |  |  |  | Tên tiếng Anh. |
| 8 | abr | STRING | X |  |  |  | Tên viết tắt. |
| 9 | rprs_tp_code | STRING |  |  |  |  | Loại hình: 1: Cá nhân 2: Tổ chức. Phân biệt cá nhân và tổ chức là đầu mối CBTT. |
| 10 | dob | DATE | X |  |  |  | Ngày sinh (áp dụng khi là cá nhân). |
| 11 | gnd_code | STRING | X |  |  |  | Giới tính: 1: Nam 2: Nữ. |
| 12 | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. |
| 13 | bsn_tp_codes | Array<Text> | X |  |  |  | Danh sách mã nghiệp vụ kinh doanh. Từ bảng junction INDIREBUSINESS. |
| 14 | dsc | STRING | X |  |  |  | Mô tả. |
| 15 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 16 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 17 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### 2.{IDX}.8.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| dscl_rprs_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| nat_id | geo | geo_id |






### 2.{IDX}.9 Bảng frgn_ivsr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | frgn_ivsr_id | BIGINT |  | X | P |  | Khóa đại diện cho nhà đầu tư. |
| 2 | frgn_ivsr_code | STRING |  |  |  |  | Mã định danh nhà đầu tư. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.INVESTOR' | Mã nguồn dữ liệu. |
| 4 | nat_id | BIGINT | X |  | F |  | FK đến quốc tịch của nhà đầu tư. |
| 5 | nat_code | STRING | X |  |  |  | Mã quốc tịch. |
| 6 | scr_co_id | BIGINT | X |  | F |  | FK đến công ty chứng khoán nơi mở tài khoản giao dịch. |
| 7 | scr_co_code | STRING | X |  |  |  | Mã công ty chứng khoán nơi mở tài khoản. |
| 8 | cstd_bnk_id | BIGINT | X |  | F |  | FK đến ngân hàng lưu ký nơi mở tài khoản. |
| 9 | cstd_bnk_code | STRING | X |  |  |  | Mã ngân hàng lưu ký nơi mở tài khoản. |
| 10 | cptl_ac_cstd_bnk_id | BIGINT | X |  | F |  | FK đến ngân hàng lưu ký nơi mở tài khoản vốn đầu tư gián tiếp. |
| 11 | cptl_ac_cstd_bnk_code | STRING | X |  |  |  | Mã ngân hàng lưu ký nơi mở tài khoản vốn đầu tư gián tiếp. |
| 12 | ivsr_tp_code | STRING | X |  |  |  | Loại NĐT. Dữ liệu lấy từ trường ID của bảng INVESTORTYPE. |
| 13 | ivsr_obj_tp_code | STRING |  |  |  |  | Loại hình NĐT: 1: Cá nhân 2: Tổ chức. Phân biệt grain cá nhân/tổ chức trong cùng entity. |
| 14 | co_tp_code | STRING | X |  |  |  | Loại hình doanh nghiệp (áp dụng khi là tổ chức). |
| 15 | ac_opn_obj_tp_code | STRING | X |  |  |  | Đối tượng mở tài khoản: 1: Công ty chứng khoán 2: Ngân hàng lưu ký. Phân biệt SecComAddId và BankAddId. |
| 16 | lcs_code | STRING | X |  |  |  | Trạng thái: 1: Đang hoạt động 0: Dừng hoạt động. |
| 17 | txn_code | STRING | X |  |  |  | Mã số giao dịch trên thị trường chứng khoán. |
| 18 | depst_ac_nbr | STRING | X |  |  |  | Số tài khoản lưu ký. |
| 19 | idr_ivsm_cptl_ac_nbr | STRING | X |  |  |  | Số tài khoản vốn đầu tư gián tiếp. |
| 20 | full_nm | STRING | X |  |  |  | Họ tên nhà đầu tư (áp dụng khi là cá nhân). |
| 21 | en_nm | STRING | X |  |  |  | Tên tiếng Anh. |
| 22 | gnd_code | STRING | X |  |  |  | Giới tính. |
| 23 | dob | DATE | X |  |  |  | Ngày sinh (áp dụng khi là cá nhân). |
| 24 | director_nm | STRING | X |  |  |  | Tên đại diện GD (áp dụng khi là tổ chức — denormalized). |
| 25 | bsn_rgst_nbr | STRING | X |  |  |  | Số GPKD (áp dụng khi là tổ chức). |
| 26 | dsc | STRING | X |  |  |  | Mô tả. |
| 27 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 28 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 29 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### 2.{IDX}.9.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| frgn_ivsr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| nat_id | geo | geo_id |
| scr_co_id | scr_co | scr_co_id |
| cstd_bnk_id | cstd_bnk | cstd_bnk_id |
| cptl_ac_cstd_bnk_id | cstd_bnk | cstd_bnk_id |






### 2.{IDX}.10 Bảng dscl_rprs_key_psn



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | dscl_rprs_key_psn_id | BIGINT |  | X | P |  | Khóa đại diện cho nhân sự thực hiện CBTT. |
| 2 | dscl_rprs_key_psn_code | STRING |  |  |  |  | Mã định danh nhân sự CBTT. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.TLPROFILES' | Mã nguồn dữ liệu. |
| 4 | nat_id | BIGINT | X |  | F |  | FK đến quốc tịch của nhân sự. |
| 5 | nat_code | STRING | X |  |  |  | Mã quốc tịch. |
| 6 | fnd_mgt_co_id | BIGINT | X |  | F |  | FK đến công ty QLQ (nullable — nhân sự có thể gắn với nhiều tổ chức). |
| 7 | fnd_mgt_co_code | STRING | X |  |  |  | Mã công ty QLQ. |
| 8 | scr_co_id | BIGINT | X |  | F |  | FK đến công ty chứng khoán (nullable). |
| 9 | scr_co_code | STRING | X |  |  |  | Mã công ty chứng khoán. |
| 10 | cstd_bnk_id | BIGINT | X |  | F |  | FK đến ngân hàng lưu ký giám sát (nullable). |
| 11 | cstd_bnk_code | STRING | X |  |  |  | Mã ngân hàng lưu ký giám sát. |
| 12 | depst_cntr_id | BIGINT | X |  | F |  | FK đến trung tâm lưu ký (nullable). |
| 13 | depst_cntr_code | STRING | X |  |  |  | Mã trung tâm lưu ký. |
| 14 | stk_exg_id | BIGINT | X |  | F |  | FK đến sở giao dịch chứng khoán (nullable). |
| 15 | stk_exg_code | STRING | X |  |  |  | Mã sở giao dịch chứng khoán. |
| 16 | dscl_rprs_id | BIGINT | X |  | F |  | FK đến người đại diện CBTT (nullable). |
| 17 | dscl_rprs_code | STRING | X |  |  |  | Mã người đại diện CBTT. |
| 18 | dgr_code | STRING | X |  |  |  | ID trình độ. Dữ liệu lấy từ trường ID của bảng DEGREE. |
| 19 | lcs_code | STRING | X |  |  |  | Trạng thái nhân sự: 1: Còn hiệu lực 2: Hết hiệu lực 3: Vô thời hạn. |
| 20 | mbr_obj_tp_code | STRING | X |  |  |  | Loại đối tượng: 1: Công ty QLQ 2: CTCK 3: NHLK 4: TTLK 5: SGDCK 6: Người đại diện CBTT 7: CN công ty QLQ NN tại VN. |
| 21 | full_nm | STRING |  |  |  |  | Họ và tên nhân sự CBTT. |
| 22 | dob | DATE | X |  |  |  | Ngày sinh. |
| 23 | plc_of_brth | STRING | X |  |  |  | Nơi sinh. |
| 24 | gnd_code | STRING | X |  |  |  | Giới tính: 1: Nam 2: Nữ. |
| 25 | is_lgl_rprs_ind | STRING | X |  |  |  | Là người đại diện pháp luật: 1: Có 0: Không. |
| 26 | lgl_rprs_email | STRING | X |  |  |  | Email người đại diện pháp luật. |
| 27 | wrk_strt_dt | DATE | X |  |  |  | Ngày bắt đầu làm việc. |
| 28 | wrk_end_dt | DATE | X |  |  |  | Ngày kết thúc làm việc. |
| 29 | job_tp_codes | Array<Text> | X |  |  |  | Danh sách mã chức vụ. Từ bảng junction TLPROJOB. |
| 30 | stockholder_tp_codes | Array<Text> | X |  |  |  | Danh sách mã loại cổ đông. Từ bảng junction TLPROSTOCKH. |
| 31 | dsc | STRING | X |  |  |  | Mô tả. |
| 32 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 33 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 34 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### 2.{IDX}.10.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| dscl_rprs_key_psn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| nat_id | geo | geo_id |
| fnd_mgt_co_id | fnd_mgt_co | fnd_mgt_co_id |
| scr_co_id | scr_co | scr_co_id |
| cstd_bnk_id | cstd_bnk | cstd_bnk_id |
| depst_cntr_id | depst_cntr | depst_cntr_id |
| stk_exg_id | stk_exg | stk_exg_id |
| dscl_rprs_id | dscl_rprs | dscl_rprs_id |






### 2.{IDX}.11 Bảng rpt_tpl



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rpt_tpl_id | BIGINT |  | X | P |  | Khóa đại diện cho biểu mẫu báo cáo. |
| 2 | rpt_tpl_code | STRING |  |  |  |  | Mã biểu mẫu. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.RPTTEMP' | Mã nguồn dữ liệu. |
| 4 | rpt_tp_code | STRING | X |  |  |  | Loại báo cáo. Dữ liệu lấy từ trường ID của bảng REPORTTYPE. |
| 5 | rpt_tpl_nm | STRING |  |  |  |  | Tên biểu mẫu. |
| 6 | rpt_tpl_bsn_code | STRING | X |  |  |  | Mã biểu mẫu (mã nghiệp vụ — khác với PK). |
| 7 | lgl_bss | STRING | X |  |  |  | Căn cứ pháp lý. |
| 8 | rpt_grp_code | STRING | X |  |  |  | Nhóm báo cáo: 1: Báo cáo CTQLQ 2: CTCK 3: NHLK 4: TTLK 5: SGDCK 6: Người đại diện CBTT 7: CN CTQLQ NN tại VN. |
| 9 | rpt_sbj_code | STRING | X |  |  |  | Đối tượng gửi báo cáo: 1: CTQLQ 2: CTCK 3: NHLK 4: TTLK 5: SGDCK 6: Người đại diện CBTT 7: CN CTQLQ NN tại VN. |
| 10 | vrsn | STRING | X |  |  |  | Version biểu mẫu. |
| 11 | eff_dt | DATE | X |  |  |  | Ngày bắt đầu sử dụng biểu mẫu. |
| 12 | tpl_st_code | STRING | X |  |  |  | Trạng thái: 0: Bản nháp 1: Đang sử dụng 2: Không sử dụng. |
| 13 | is_impr_rqd_ind | STRING | X |  |  |  | Báo cáo có import: 1: Có import 0: Không import. |
| 14 | is_self_prd_setting_ind | STRING | X |  |  |  | Báo cáo do cán bộ UB tự thiết lập kỳ: 1: Có 0: Không. |
| 15 | is_pblc_dscl_ind | STRING | X |  |  |  | Cho phép CBTT: 0: Không CBTT 1: Có CBTT. |
| 16 | dsc | STRING | X |  |  |  | Mô tả. |
| 17 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 18 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 19 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 20 | fcn_cgy_id | BIGINT | X |  | F |  | FK đến danh mục chức năng (QT_CHUC_NANG). Nullable. |
| 21 | fcn_cgy_code | STRING | X |  |  |  | Mã danh mục chức năng. |
| 22 | rpt_drc_tp_code | STRING | X |  |  |  | Chiều báo cáo: 0-Đầu vào; 1-Đầu ra. |
| 23 | vrsn_dt | DATE | X |  |  |  | Ngày thay đổi phiên bản. |
| 24 | is_actv_f | BOOLEAN | X |  |  |  | Trạng thái sử dụng: 1-Sử dụng; 0-Không sử dụng. |
| 25 | is_smy_rqd_ind | STRING | X |  |  |  | Yêu cầu nhập trích yếu: 0-Không bắt buộc; 1-Bắt buộc. |
| 26 | attch_file | STRING | X |  |  |  | Tệp đính kèm mẫu báo cáo. |


#### 2.{IDX}.11.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rpt_tpl_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*





### 2.{IDX}.12 Bảng geo



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | geo_id | BIGINT |  | X | P |  | Khóa đại diện cho khu vực địa lý. |
| 2 | geo_code | STRING |  |  |  |  | Mã quốc tịch/quốc gia. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.NATIONAL' | Mã nguồn dữ liệu. |
| 4 | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. |
| 5 | geo_nm | STRING |  |  |  |  | Tên quốc tịch/quốc gia. |
| 6 | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. |
| 7 | dsc | STRING | X |  |  |  | Mô tả. |
| 8 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 9 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 10 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 11 | geo_tp_code | STRING |  |  |  |  | Loại khu vực địa lý — phân biệt cấp hành chính: COUNTRY/REGION/PROVINCE/PROVINCE_OLD/DISTRICT_OLD/WARD/WARD_OLD. |
| 12 | geo_bsn_code | STRING | X |  |  |  | Mã quốc tịch/quốc gia (mã nghiệp vụ). |
| 13 | note | STRING | X |  |  |  | Ghi chú. |
| 14 | prn_geo_id | BIGINT | X |  | F |  | FK tự tham chiếu đến khu vực cha trong phân cấp hành chính. |
| 15 | prn_geo_code | STRING | X |  |  |  | Mã khu vực cha — denormalized để tiện tra cứu. |


#### 2.{IDX}.12.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| geo_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prn_geo_id | geo | geo_id |






### 2.{IDX}.13 Bảng rpt_prd



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rpt_prd_id | BIGINT |  | X | P |  | Khóa đại diện cho kỳ báo cáo. |
| 2 | rpt_prd_code | STRING |  |  |  |  | Mã kỳ báo cáo. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.RPTPERIOD' | Mã nguồn dữ liệu. |
| 4 | rpt_prd_nm | STRING |  |  |  |  | Tên kỳ báo cáo. |
| 5 | rpt_prd_tp_code | STRING | X |  |  |  | Kỳ báo cáo: 1: Ngày 2: Tuần 3: Nửa tháng 4: Tháng 5: Quý 6: Bán niên 7: Năm. |
| 6 | is_actv_f | BOOLEAN | X |  |  |  | Kỳ báo cáo đang hoạt động. |
| 7 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 8 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 9 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 10 | self-set_prd_id | BIGINT | X |  | F |  | FK đến kỳ báo cáo do cán bộ UB tự thiết lập (SELFSETPD). Nullable. |
| 11 | self-set_prd_code | STRING | X |  |  |  | Mã kỳ báo cáo tự thiết lập. |
| 12 | rpt_tpl_id | BIGINT |  |  | F |  | FK đến biểu mẫu báo cáo áp dụng cho kỳ này. |
| 13 | rpt_tpl_code | STRING |  |  |  |  | Mã biểu mẫu báo cáo. |
| 14 | subm_ddln_dt | DATE | X |  |  |  | Thời hạn gửi báo cáo muộn nhất (áp dụng cho kỳ ngày/tuần). |
| 15 | subm_ddln_wk | INT | X |  |  |  | Thời hạn gửi báo cáo muộn nhất (tuần). |
| 16 | repeat_itrv | INT | X |  |  |  | Lặp lại sau bao nhiêu đơn vị kỳ. |
| 17 | counting_strt_dt | DATE | X |  |  |  | Ngày bắt đầu tính hạn nộp báo cáo. |
| 18 | is_wrk_day_ind | STRING | X |  |  |  | Đơn vị tính hạn nộp: 0: Ngày lịch 1: Ngày làm việc. |
| 19 | submit_wi_dys | INT | X |  |  |  | Số ngày/ngày làm việc được phép gửi báo cáo. |
| 20 | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. |
| 21 | dsc | STRING | X |  |  |  | Ghi chú. |


#### 2.{IDX}.13.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rpt_prd_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rpt_tpl_id | rpt_tpl | rpt_tpl_id |






### 2.{IDX}.14 Bảng mbr_reg_rpt



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mbr_reg_rpt_id | BIGINT |  | X | P |  | Khóa đại diện cho lần nộp báo cáo của thành viên. |
| 2 | mbr_reg_rpt_code | STRING |  |  |  |  | Mã lần nộp báo cáo. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.RPTMEMBER' | Mã nguồn dữ liệu. |
| 4 | rpt_tpl_id | BIGINT |  |  | F |  | FK đến biểu mẫu báo cáo. |
| 5 | rpt_tpl_code | STRING |  |  |  |  | Mã biểu mẫu báo cáo. |
| 6 | rpt_prd_id | BIGINT |  |  | F |  | FK đến kỳ báo cáo. |
| 7 | rpt_prd_code | STRING |  |  |  |  | Mã kỳ báo cáo. |
| 8 | fnd_mgt_co_id | BIGINT | X |  | F |  | FK đến công ty QLQ nộp báo cáo (ngữ cảnh nộp). |
| 9 | fnd_mgt_co_code | STRING | X |  |  |  | Mã công ty QLQ nộp báo cáo. |
| 10 | scr_co_id | BIGINT | X |  | F |  | FK đến công ty chứng khoán nộp báo cáo (ngữ cảnh nộp). |
| 11 | scr_co_code | STRING | X |  |  |  | Mã công ty chứng khoán nộp báo cáo. |
| 12 | cstd_bnk_id | BIGINT | X |  | F |  | FK đến ngân hàng lưu ký nộp báo cáo (ngữ cảnh nộp). |
| 13 | cstd_bnk_code | STRING | X |  |  |  | Mã ngân hàng lưu ký nộp báo cáo. |
| 14 | depst_cntr_id | BIGINT | X |  | F |  | FK đến trung tâm lưu ký nộp báo cáo (ngữ cảnh nộp). |
| 15 | depst_cntr_code | STRING | X |  |  |  | Mã trung tâm lưu ký nộp báo cáo. |
| 16 | stk_exg_id | BIGINT | X |  | F |  | FK đến sở giao dịch chứng khoán nộp báo cáo (ngữ cảnh nộp). |
| 17 | stk_exg_code | STRING | X |  |  |  | Mã sở giao dịch chứng khoán nộp báo cáo. |
| 18 | frgn_ivsr_id | BIGINT | X |  | F |  | FK đến nhà đầu tư nước ngoài nộp báo cáo (ngữ cảnh nộp). |
| 19 | frgn_ivsr_code | STRING | X |  |  |  | Mã nhà đầu tư nước ngoài nộp báo cáo. |
| 20 | fnd_mgt_co_ou_id | BIGINT | X |  | F |  | FK đến chi nhánh công ty QLQ NN nộp báo cáo (ngữ cảnh nộp). |
| 21 | fnd_mgt_co_ou_code | STRING | X |  |  |  | Mã chi nhánh công ty QLQ NN nộp báo cáo. |
| 22 | rpt_tp_code | STRING | X |  |  |  | Loại báo cáo. Dữ liệu lấy từ trường ID của bảng REPORTTYPE. |
| 23 | mbr_obj_tp_code | STRING | X |  |  |  | Loại đối tượng nộp báo cáo: 1: Công ty QLQ 2: CTCK 3: NHLK 4: TTLK 5: SGDCK 6: Người đại diện CBTT 7: CN CTQLQ NN tại VN. |
| 24 | is_impr_ind | STRING | X |  |  |  | Là báo cáo có import: 0: Không import 1: Có import. |
| 25 | rpt_nm | STRING | X |  |  |  | Tên báo cáo. |
| 26 | rpt_yr | INT | X |  |  |  | Năm báo cáo. |
| 27 | prd_val | INT | X |  |  |  | Giá trị kỳ báo cáo (số thứ tự kỳ trong năm). |
| 28 | rpt_dt | DATE | X |  |  |  | Ngày báo cáo. |
| 29 | subm_ddln_dt | DATE | X |  |  |  | Thời hạn gửi báo cáo. |
| 30 | subm_st_code | STRING | X |  |  |  | Trạng thái nộp: 1: Chưa gửi 2: Đã gửi 3: Gửi muộn 4: Bị hủy 5: Đã gửi lại. |
| 31 | subm_dt | DATE | X |  |  |  | Ngày gửi báo cáo thực tế. |
| 32 | cntnt_smy | STRING | X |  |  |  | Nội dung trích yếu. |
| 33 | note | STRING | X |  |  |  | Ghi chú. |
| 34 | rpt_prd_tp_code | STRING | X |  |  |  | Kỳ báo cáo: 1: Ngày 2: Tuần 3: Nửa tháng 4: Tháng 5: Quý 6: Bán niên 7: Năm. |
| 35 | is_wrk_day_ind | STRING | X |  |  |  | Là ngày làm việc: 1: Ngày làm việc 0: Ngày. |
| 36 | submit_wi_dys | INT | X |  |  |  | Số ngày được phép gửi báo cáo. |
| 37 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 38 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 39 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### 2.{IDX}.14.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mbr_reg_rpt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rpt_tpl_id | rpt_tpl | rpt_tpl_id |
| rpt_prd_id | rpt_prd | rpt_prd_id |
| fnd_mgt_co_id | fnd_mgt_co | fnd_mgt_co_id |
| scr_co_id | scr_co | scr_co_id |
| cstd_bnk_id | cstd_bnk | cstd_bnk_id |
| depst_cntr_id | depst_cntr | depst_cntr_id |
| stk_exg_id | stk_exg | stk_exg_id |
| frgn_ivsr_id | frgn_ivsr | frgn_ivsr_id |
| fnd_mgt_co_ou_id | fnd_mgt_co_ou | fnd_mgt_co_ou_id |






### 2.{IDX}.15 Bảng mbr_conduct_vln



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mbr_conduct_vln_id | BIGINT |  | X | P |  | Khóa đại diện cho vi phạm. |
| 2 | mbr_conduct_vln_code | STRING |  |  |  |  | Mã vi phạm. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.VIOLT' | Mã nguồn dữ liệu. |
| 4 | fnd_mgt_co_id | BIGINT | X |  | F |  | FK đến công ty QLQ vi phạm (nullable — chỉ 1 trong các FK thành viên có giá trị). |
| 5 | fnd_mgt_co_code | STRING | X |  |  |  | Mã công ty QLQ vi phạm. |
| 6 | scr_co_id | BIGINT | X |  | F |  | FK đến công ty chứng khoán vi phạm. |
| 7 | scr_co_code | STRING | X |  |  |  | Mã công ty chứng khoán vi phạm. |
| 8 | cstd_bnk_id | BIGINT | X |  | F |  | FK đến ngân hàng lưu ký vi phạm. |
| 9 | cstd_bnk_code | STRING | X |  |  |  | Mã ngân hàng lưu ký vi phạm. |
| 10 | depst_cntr_id | BIGINT | X |  | F |  | FK đến trung tâm lưu ký vi phạm. |
| 11 | depst_cntr_code | STRING | X |  |  |  | Mã trung tâm lưu ký vi phạm. |
| 12 | stk_exg_id | BIGINT | X |  | F |  | FK đến sở giao dịch chứng khoán vi phạm. |
| 13 | stk_exg_code | STRING | X |  |  |  | Mã sở giao dịch chứng khoán vi phạm. |
| 14 | dscl_rprs_id | BIGINT | X |  | F |  | FK đến người đại diện CBTT vi phạm. |
| 15 | dscl_rprs_code | STRING | X |  |  |  | Mã người đại diện CBTT vi phạm. |
| 16 | fnd_mgt_co_ou_id | BIGINT | X |  | F |  | FK đến chi nhánh công ty QLQ NN vi phạm. |
| 17 | fnd_mgt_co_ou_code | STRING | X |  |  |  | Mã chi nhánh công ty QLQ NN vi phạm. |
| 18 | wrn_parm_id | BIGINT | X |  | F |  | FK đến tham số cảnh báo (PARAWARN). Nullable. |
| 19 | wrn_parm_code | STRING | X |  |  |  | Mã tham số cảnh báo. |
| 20 | wrn_cd_id | BIGINT | X |  | F |  | FK đến điều kiện cảnh báo (CDTWARN). Nullable. |
| 21 | wrn_cd_code | STRING | X |  |  |  | Mã điều kiện cảnh báo. |
| 22 | mbr_obj_tp_code | STRING | X |  |  |  | Loại đối tượng vi phạm: 1: Công ty QLQ 2: CTCK 3: NHLK 4: TTLK 5: SGDCK 6: Người đại diện CBTT 7: CN CTQLQ NN tại VN. |
| 23 | ivsr_nm | STRING | X |  |  |  | Nhà đầu tư liên quan (denormalized). |
| 24 | vln_yr | INT | X |  |  |  | Năm cảnh báo vi phạm. |
| 25 | vln_prd_tp_code | STRING | X |  |  |  | Kỳ cảnh báo: 1: Ngày 2: Tuần 3: Nửa tháng 4: Tháng 5: Quý 6: Bán niên 7: Năm. |
| 26 | vln_prd_val | INT | X |  |  |  | Giá trị kỳ cảnh báo. |
| 27 | vln_st_code | STRING | X |  |  |  | Trạng thái xử lý: 0: Chưa khắc phục 1: Khắc phục. |
| 28 | vln_val | STRING | X |  |  |  | Giá trị vi phạm. |
| 29 | vln_dt | DATE | X |  |  |  | Ngày phát sinh cảnh báo vi phạm. |
| 30 | cmpr_prd_tp_code | STRING | X |  |  |  | Kỳ tham số so sánh. |
| 31 | cmpr_prd_val | INT | X |  |  |  | Giá trị kỳ tham số so sánh. |
| 32 | cmpr_val | STRING | X |  |  |  | Giá trị tham số so sánh. |


#### 2.{IDX}.15.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mbr_conduct_vln_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| fnd_mgt_co_id | fnd_mgt_co | fnd_mgt_co_id |
| scr_co_id | scr_co | scr_co_id |
| cstd_bnk_id | cstd_bnk | cstd_bnk_id |
| depst_cntr_id | depst_cntr | depst_cntr_id |
| stk_exg_id | stk_exg | stk_exg_id |
| dscl_rprs_id | dscl_rprs | dscl_rprs_id |
| fnd_mgt_co_ou_id | fnd_mgt_co_ou | fnd_mgt_co_ou_id |






### 2.{IDX}.16 Bảng dscl_ahr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | dscl_ahr_id | BIGINT |  | X | P |  | Khóa đại diện cho ủy quyền CBTT. |
| 2 | dscl_ahr_code | STRING |  |  |  |  | Mã ủy quyền CBTT. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.AUTHOANNOUNCE' | Mã nguồn dữ liệu. |
| 4 | dscl_rprs_id | BIGINT |  |  | F |  | FK đến người đại diện CBTT được ủy quyền. |
| 5 | dscl_rprs_code | STRING |  |  |  |  | Mã người đại diện CBTT được ủy quyền. |
| 6 | rltnp_tp_code | STRING | X |  |  |  | Loại quan hệ ủy quyền. Dữ liệu lấy từ trường ID của bảng RELATIONSHIP. |
| 7 | rel_properties_code | STRING | X |  |  |  | Hình thức liên quan trong ủy quyền. Dữ liệu lấy từ trường ID của bảng RELATEDPROPERTIES. |
| 8 | eff_strt_dt | DATE | X |  |  |  | Ngày bắt đầu có hiệu lực ủy quyền. |
| 9 | eff_end_dt | DATE | X |  |  |  | Ngày kết thúc hiệu lực ủy quyền. |
| 10 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 11 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 12 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### 2.{IDX}.16.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| dscl_ahr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| dscl_rprs_id | dscl_rprs | dscl_rprs_id |






### 2.{IDX}.17 Bảng dscl_ancm



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | dscl_ancm_id | BIGINT |  | X | P |  | Khóa đại diện cho tin công bố thông tin. |
| 2 | dscl_ancm_code | STRING |  |  |  |  | Mã tin công bố. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.ANNOUNCE' | Mã nguồn dữ liệu. |
| 4 | dscl_rprs_id | BIGINT |  |  | F |  | FK đến người đại diện CBTT gửi tin. |
| 5 | dscl_rprs_code | STRING |  |  |  |  | Mã người đại diện CBTT gửi tin. |
| 6 | ancm_tp_code | STRING | X |  |  |  | Loại CBTT. Dữ liệu lấy từ trường ID của bảng ANNOUNCETYPE. |
| 7 | ancm_ttl | STRING | X |  |  |  | Tiêu đề tin công bố. |
| 8 | cntnt_smy | STRING | X |  |  |  | Nội dung trích yếu. |
| 9 | ancm_dt | DATE | X |  |  |  | Ngày công bố thông tin. |
| 10 | ancm_st_code | STRING | X |  |  |  | Trạng thái CBTT: 0: Chưa gửi 1: Đã CBTT. |
| 11 | ancm_yr | INT | X |  |  |  | Năm báo cáo liên quan. |
| 12 | ancm_prd_tp_code | STRING | X |  |  |  | Kỳ báo cáo liên quan: 1: Ngày 2: Tuần 3: Nửa tháng 4: Tháng 5: Quý 6: Bán niên 7: Năm. |
| 13 | ancm_prd_val | INT | X |  |  |  | Giá trị kỳ báo cáo liên quan. |
| 14 | snd_by | STRING | X |  |  |  | Người gửi tin CBTT (denormalized). |
| 15 | dsc | STRING | X |  |  |  | Ghi chú. |
| 16 | frgn_ivsr_ids | Array<Struct> | X |  |  |  | Danh sách nhà đầu tư nước ngoài liên quan đến tin CBTT. InvesId → FK đến INVESTOR. |
| 17 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 18 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 19 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### 2.{IDX}.17.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| dscl_ancm_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| dscl_rprs_id | dscl_rprs | dscl_rprs_id |






### 2.{IDX}.18 Bảng frgn_ivsr_scr_ac



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | frgn_ivsr_scr_ac_id | BIGINT |  | X | P |  | Khóa đại diện cho tài khoản giao dịch chứng khoán. |
| 2 | frgn_ivsr_scr_ac_code | STRING |  |  |  |  | Mã tài khoản. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.SECURITIESACCOUNT' | Mã nguồn dữ liệu. |
| 4 | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán nơi mở tài khoản. |
| 5 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán nơi mở tài khoản. |
| 6 | frgn_ivsr_id | BIGINT |  |  | F |  | FK đến nhà đầu tư nước ngoài chủ tài khoản. |
| 7 | frgn_ivsr_code | STRING |  |  |  |  | Mã nhà đầu tư nước ngoài chủ tài khoản. |
| 8 | ac_nbr | STRING |  |  |  |  | Số tài khoản giao dịch chứng khoán. |


#### 2.{IDX}.18.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| frgn_ivsr_scr_ac_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_co_id | scr_co | scr_co_id |
| frgn_ivsr_id | frgn_ivsr | frgn_ivsr_id |






### 2.{IDX}.19 Bảng frgn_ivsr_stk_prtfl_snpst



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | frgn_ivsr_stk_prtfl_snpst_id | BIGINT |  | X | P |  | Khóa đại diện cho vị thế sở hữu chứng khoán. |
| 2 | frgn_ivsr_stk_prtfl_snpst_code | STRING |  |  |  |  | Mã vị thế. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.CATEGORIESSTOCK' | Mã nguồn dữ liệu. |
| 4 | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán lưu giữ danh mục. |
| 5 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán lưu giữ danh mục. |
| 6 | frgn_ivsr_id | BIGINT |  |  | F |  | FK đến nhà đầu tư nước ngoài sở hữu danh mục. |
| 7 | frgn_ivsr_code | STRING |  |  |  |  | Mã nhà đầu tư nước ngoài sở hữu danh mục. |
| 8 | qty | INT | X |  |  |  | Số lượng chứng khoán sở hữu. |
| 9 | own_rate | DECIMAL(9,6) | X |  |  |  | Tỷ lệ % sở hữu chứng khoán. |


#### 2.{IDX}.19.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| frgn_ivsr_stk_prtfl_snpst_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_co_id | scr_co | scr_co_id |
| frgn_ivsr_id | frgn_ivsr | frgn_ivsr_id |






### 2.{IDX}.20 Bảng mbr_rpt_val



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mbr_rpt_val_id | BIGINT |  | X | P |  | Khóa đại diện cho giá trị chỉ tiêu báo cáo. |
| 2 | mbr_rpt_val_code | STRING |  |  |  |  | Mã giá trị chỉ tiêu. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.RPTVALUES' | Mã nguồn dữ liệu. |
| 4 | mbr_reg_rpt_id | BIGINT |  |  | F |  | FK đến lần nộp báo cáo của thành viên. |
| 5 | mbr_reg_rpt_code | STRING |  |  |  |  | Mã lần nộp báo cáo. |
| 6 | rpt_prd_id | BIGINT |  |  | F |  | FK đến kỳ báo cáo. |
| 7 | rpt_prd_code | STRING |  |  |  |  | Mã kỳ báo cáo. |
| 8 | rpt_tpl_id | BIGINT |  |  | F |  | FK đến biểu mẫu báo cáo. |
| 9 | rpt_tpl_code | STRING |  |  |  |  | Mã biểu mẫu báo cáo. |
| 10 | rpt_shet_code | STRING | X |  |  |  | Mã sheet báo cáo. Dữ liệu lấy từ trường ID của bảng SHEET. |
| 11 | cell_id | STRING | X |  |  |  | UID ô dữ liệu trong sheet ẩn — định vị chỉ tiêu. |
| 12 | cell_code | STRING | X |  |  |  | Mã chỉ tiêu báo cáo. |
| 13 | fnd_mgt_co_id | BIGINT | X |  | F |  | FK đến công ty QLQ gửi báo cáo (nullable — chỉ 1 trong 7 FK thành viên có giá trị). |
| 14 | fnd_mgt_co_code | STRING | X |  |  |  | Mã công ty QLQ gửi báo cáo. |
| 15 | scr_co_id | BIGINT | X |  | F |  | FK đến công ty chứng khoán gửi báo cáo. |
| 16 | scr_co_code | STRING | X |  |  |  | Mã công ty chứng khoán gửi báo cáo. |
| 17 | cstd_bnk_id | BIGINT | X |  | F |  | FK đến ngân hàng lưu ký gửi báo cáo. |
| 18 | cstd_bnk_code | STRING | X |  |  |  | Mã ngân hàng lưu ký gửi báo cáo. |
| 19 | depst_cntr_id | BIGINT | X |  | F |  | FK đến trung tâm lưu ký gửi báo cáo. |
| 20 | depst_cntr_code | STRING | X |  |  |  | Mã trung tâm lưu ký gửi báo cáo. |
| 21 | stk_exg_id | BIGINT | X |  | F |  | FK đến sở giao dịch chứng khoán gửi báo cáo. |
| 22 | stk_exg_code | STRING | X |  |  |  | Mã sở giao dịch chứng khoán gửi báo cáo. |
| 23 | dscl_rprs_id | BIGINT | X |  | F |  | FK đến người đại diện CBTT gửi báo cáo. |
| 24 | dscl_rprs_code | STRING | X |  |  |  | Mã người đại diện CBTT gửi báo cáo. |
| 25 | fnd_mgt_co_ou_id | BIGINT | X |  | F |  | FK đến chi nhánh công ty QLQ NN tại VN gửi báo cáo. |
| 26 | fnd_mgt_co_ou_code | STRING | X |  |  |  | Mã chi nhánh công ty QLQ NN tại VN gửi báo cáo. |
| 27 | mbr_obj_tp_code | STRING | X |  |  |  | Loại đối tượng gửi báo cáo: 1: Công ty QLQ 2: CTCK 3: NHLK 4: TTLK 5: SGDCK 6: Người đại diện CBTT 7: CN CTQLQ NN tại VN. |
| 28 | rpt_prd_tp_code | STRING | X |  |  |  | Kỳ báo cáo: 1: Ngày 2: Tuần 3: Nửa tháng 4: Tháng 5: Quý 6: Bán niên 7: Năm. |
| 29 | prd_val | INT | X |  |  |  | Giá trị kỳ báo cáo. |
| 30 | rpt_yr | INT | X |  |  |  | Năm báo cáo. |
| 31 | cell_val | STRING | X |  |  |  | Giá trị ô chỉ tiêu báo cáo. |
| 32 | cell_data_tp_code | STRING | X |  |  |  | Định dạng dữ liệu ô: kiểu số hoặc kiểu ký tự. |
| 33 | is_dynamic_row_ind | STRING | X |  |  |  | Là dòng động: 0: Không 1: Có. |
| 34 | dynamic_row_indx | INT | X |  |  |  | Chỉ số dòng động. |
| 35 | src_tbl_nm | STRING | X |  |  |  | Tên bảng RPTVALUES nguồn (mỗi năm sinh 1 bảng riêng). |
| 36 | fld_nm | STRING | X |  |  |  | Tên file đính kèm (nếu có). |
| 37 | sel_data | STRING | X |  |  |  | Dữ liệu dạng ô cho phép chọn. |
| 38 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 39 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 40 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### 2.{IDX}.20.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mbr_rpt_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| mbr_reg_rpt_id | mbr_reg_rpt | mbr_reg_rpt_id |
| rpt_prd_id | rpt_prd | rpt_prd_id |
| rpt_tpl_id | rpt_tpl | rpt_tpl_id |
| fnd_mgt_co_id | fnd_mgt_co | fnd_mgt_co_id |
| scr_co_id | scr_co | scr_co_id |
| cstd_bnk_id | cstd_bnk | cstd_bnk_id |
| depst_cntr_id | depst_cntr | depst_cntr_id |
| stk_exg_id | stk_exg | stk_exg_id |
| dscl_rprs_id | dscl_rprs | dscl_rprs_id |
| fnd_mgt_co_ou_id | fnd_mgt_co_ou | fnd_mgt_co_ou_id |






### 2.{IDX}.21 Bảng ip_pst_adr



#### Từ FIMS.BANKMONI

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Custodian Bank. |
| 2 | ip_code | STRING |  |  |  |  | Mã ngân hàng lưu ký giám sát. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.BANKMONI' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở chính. |
| 6 | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. |
| 7 | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). |
| 8 | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. |
| 9 | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. |
| 10 | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. |
| 11 | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. |
| 12 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | cstd_bnk | cstd_bnk_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |




#### Từ FIMS.BRANCHS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company Organization Unit. |
| 2 | ip_code | STRING |  |  |  |  | Mã chi nhánh công ty quản lý quỹ. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.BRANCHS' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở. |
| 6 | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. |
| 7 | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). |
| 8 | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. |
| 9 | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. |
| 10 | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. |
| 11 | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. |
| 12 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | fnd_mgt_co_ou | fnd_mgt_co_ou_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |




#### Từ FIMS.DEPOSITORYCENTER

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Depository Center. |
| 2 | ip_code | STRING |  |  |  |  | Mã Trung tâm lưu ký. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.DEPOSITORYCENTER' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở. |
| 6 | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. |
| 7 | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). |
| 8 | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. |
| 9 | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. |
| 10 | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. |
| 11 | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. |
| 12 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | depst_cntr | depst_cntr_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |




#### Từ FIMS.FUNDCOMPANY

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.FUNDCOMPANY' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở. |
| 6 | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. |
| 7 | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). |
| 8 | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. |
| 9 | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. |
| 10 | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. |
| 11 | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. |
| 12 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | fnd_mgt_co | fnd_mgt_co_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |




#### Từ FIMS.INFODISCREPRES

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative. |
| 2 | ip_code | STRING |  |  |  |  | Mã người/tổ chức đại diện CBTT. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.INFODISCREPRES' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  | 'ADDRESS' | Loại địa chỉ — địa chỉ chung. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ. |
| 6 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | dscl_rprs | dscl_rprs_id |




#### Từ FIMS.INVESTOR

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Foreign Investor. |
| 2 | ip_code | STRING |  |  |  |  | Mã nhà đầu tư nước ngoài. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.INVESTOR' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  | 'ADDRESS' | Loại địa chỉ — địa chỉ chung. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ nhà đầu tư. |
| 6 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | frgn_ivsr | frgn_ivsr_id |




#### Từ FIMS.SECURITIESCOMPANY

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Securities Company. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.SECURITIESCOMPANY' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở. |
| 6 | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. |
| 7 | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). |
| 8 | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. |
| 9 | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. |
| 10 | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. |
| 11 | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. |
| 12 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_co | scr_co_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |




#### Từ FIMS.STOCKEXCHANGE

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Stock Exchange. |
| 2 | ip_code | STRING |  |  |  |  | Mã Sở giao dịch chứng khoán. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.STOCKEXCHANGE' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở. |
| 6 | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. |
| 7 | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). |
| 8 | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. |
| 9 | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. |
| 10 | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. |
| 11 | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. |
| 12 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | stk_exg | stk_exg_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |




#### Từ FIMS.TLPROFILES

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative Key Person. |
| 2 | ip_code | STRING |  |  |  |  | Mã nhân sự CBTT. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.TLPROFILES' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  | 'ADDRESS' | Loại địa chỉ — địa chỉ chung. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ nhân sự. |
| 6 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | dscl_rprs_key_psn | dscl_rprs_key_psn_id |







### 2.{IDX}.22 Bảng ip_elc_adr



#### Từ FIMS.BANKMONI

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Custodian Bank. |
| 2 | ip_code | STRING |  |  |  |  | Mã ngân hàng lưu ký giám sát. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.BANKMONI' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Email. |
| 6 | ip_id | BIGINT |  |  | F |  | FK đến Custodian Bank. |
| 7 | ip_code | STRING |  |  |  |  | Mã ngân hàng lưu ký giám sát. |
| 8 | src_stm_code | STRING |  |  |  | 'FIMS.BANKMONI' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số fax. |
| 11 | ip_id | BIGINT |  |  | F |  | FK đến Custodian Bank. |
| 12 | ip_code | STRING |  |  |  |  | Mã ngân hàng lưu ký giám sát. |
| 13 | src_stm_code | STRING |  |  |  | 'FIMS.BANKMONI' | Mã nguồn dữ liệu. |
| 14 | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. |
| 15 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |
| 16 | ip_id | BIGINT |  |  | F |  | FK đến Custodian Bank. |
| 17 | ip_code | STRING |  |  |  |  | Mã ngân hàng lưu ký giám sát. |
| 18 | src_stm_code | STRING |  |  |  | 'FIMS.BANKMONI' | Mã nguồn dữ liệu. |
| 19 | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. |
| 20 | elc_adr_val | STRING | X |  |  |  | Website. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | cstd_bnk | cstd_bnk_id |




#### Từ FIMS.BRANCHS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company Organization Unit. |
| 2 | ip_code | STRING |  |  |  |  | Mã chi nhánh công ty quản lý quỹ. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.BRANCHS' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Email. |
| 6 | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company Organization Unit. |
| 7 | ip_code | STRING |  |  |  |  | Mã chi nhánh công ty quản lý quỹ. |
| 8 | src_stm_code | STRING |  |  |  | 'FIMS.BRANCHS' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số fax. |
| 11 | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company Organization Unit. |
| 12 | ip_code | STRING |  |  |  |  | Mã chi nhánh công ty quản lý quỹ. |
| 13 | src_stm_code | STRING |  |  |  | 'FIMS.BRANCHS' | Mã nguồn dữ liệu. |
| 14 | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. |
| 15 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |
| 16 | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company Organization Unit. |
| 17 | ip_code | STRING |  |  |  |  | Mã chi nhánh công ty quản lý quỹ. |
| 18 | src_stm_code | STRING |  |  |  | 'FIMS.BRANCHS' | Mã nguồn dữ liệu. |
| 19 | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. |
| 20 | elc_adr_val | STRING | X |  |  |  | Website. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | fnd_mgt_co_ou | fnd_mgt_co_ou_id |




#### Từ FIMS.DEPOSITORYCENTER

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Depository Center. |
| 2 | ip_code | STRING |  |  |  |  | Mã Trung tâm lưu ký. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.DEPOSITORYCENTER' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Email. |
| 6 | ip_id | BIGINT |  |  | F |  | FK đến Depository Center. |
| 7 | ip_code | STRING |  |  |  |  | Mã Trung tâm lưu ký. |
| 8 | src_stm_code | STRING |  |  |  | 'FIMS.DEPOSITORYCENTER' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số fax. |
| 11 | ip_id | BIGINT |  |  | F |  | FK đến Depository Center. |
| 12 | ip_code | STRING |  |  |  |  | Mã Trung tâm lưu ký. |
| 13 | src_stm_code | STRING |  |  |  | 'FIMS.DEPOSITORYCENTER' | Mã nguồn dữ liệu. |
| 14 | elc_adr_tp_code | STRING |  |  |  | 'HOTLINE' | Loại kênh liên lạc — hotline. |
| 15 | elc_adr_val | STRING | X |  |  |  | Số hotline. |
| 16 | ip_id | BIGINT |  |  | F |  | FK đến Depository Center. |
| 17 | ip_code | STRING |  |  |  |  | Mã Trung tâm lưu ký. |
| 18 | src_stm_code | STRING |  |  |  | 'FIMS.DEPOSITORYCENTER' | Mã nguồn dữ liệu. |
| 19 | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. |
| 20 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |
| 21 | ip_id | BIGINT |  |  | F |  | FK đến Depository Center. |
| 22 | ip_code | STRING |  |  |  |  | Mã Trung tâm lưu ký. |
| 23 | src_stm_code | STRING |  |  |  | 'FIMS.DEPOSITORYCENTER' | Mã nguồn dữ liệu. |
| 24 | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. |
| 25 | elc_adr_val | STRING | X |  |  |  | Website. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | depst_cntr | depst_cntr_id |




#### Từ FIMS.FUNDCOMPANY

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.FUNDCOMPANY' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Email. |
| 6 | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. |
| 7 | ip_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. |
| 8 | src_stm_code | STRING |  |  |  | 'FIMS.FUNDCOMPANY' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số fax. |
| 11 | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. |
| 12 | ip_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. |
| 13 | src_stm_code | STRING |  |  |  | 'FIMS.FUNDCOMPANY' | Mã nguồn dữ liệu. |
| 14 | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. |
| 15 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |
| 16 | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. |
| 17 | ip_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. |
| 18 | src_stm_code | STRING |  |  |  | 'FIMS.FUNDCOMPANY' | Mã nguồn dữ liệu. |
| 19 | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. |
| 20 | elc_adr_val | STRING | X |  |  |  | Website. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | fnd_mgt_co | fnd_mgt_co_id |




#### Từ FIMS.INFODISCREPRES

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative. |
| 2 | ip_code | STRING |  |  |  |  | Mã người/tổ chức đại diện CBTT. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.INFODISCREPRES' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Email. |
| 6 | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative. |
| 7 | ip_code | STRING |  |  |  |  | Mã người/tổ chức đại diện CBTT. |
| 8 | src_stm_code | STRING |  |  |  | 'FIMS.INFODISCREPRES' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số fax. |
| 11 | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative. |
| 12 | ip_code | STRING |  |  |  |  | Mã người/tổ chức đại diện CBTT. |
| 13 | src_stm_code | STRING |  |  |  | 'FIMS.INFODISCREPRES' | Mã nguồn dữ liệu. |
| 14 | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. |
| 15 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |
| 16 | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative. |
| 17 | ip_code | STRING |  |  |  |  | Mã người/tổ chức đại diện CBTT. |
| 18 | src_stm_code | STRING |  |  |  | 'FIMS.INFODISCREPRES' | Mã nguồn dữ liệu. |
| 19 | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. |
| 20 | elc_adr_val | STRING | X |  |  |  | Website. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | dscl_rprs | dscl_rprs_id |




#### Từ FIMS.INVESTOR

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Foreign Investor. |
| 2 | ip_code | STRING |  |  |  |  | Mã nhà đầu tư nước ngoài. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.INVESTOR' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Email. |
| 6 | ip_id | BIGINT |  |  | F |  | FK đến Foreign Investor. |
| 7 | ip_code | STRING |  |  |  |  | Mã nhà đầu tư nước ngoài. |
| 8 | src_stm_code | STRING |  |  |  | 'FIMS.INVESTOR' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số fax. |
| 11 | ip_id | BIGINT |  |  | F |  | FK đến Foreign Investor. |
| 12 | ip_code | STRING |  |  |  |  | Mã nhà đầu tư nước ngoài. |
| 13 | src_stm_code | STRING |  |  |  | 'FIMS.INVESTOR' | Mã nguồn dữ liệu. |
| 14 | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. |
| 15 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |
| 16 | ip_id | BIGINT |  |  | F |  | FK đến Foreign Investor. |
| 17 | ip_code | STRING |  |  |  |  | Mã nhà đầu tư nước ngoài. |
| 18 | src_stm_code | STRING |  |  |  | 'FIMS.INVESTOR' | Mã nguồn dữ liệu. |
| 19 | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. |
| 20 | elc_adr_val | STRING | X |  |  |  | Website. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | frgn_ivsr | frgn_ivsr_id |




#### Từ FIMS.SECURITIESCOMPANY

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Securities Company. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.SECURITIESCOMPANY' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Email. |
| 6 | ip_id | BIGINT |  |  | F |  | FK đến Securities Company. |
| 7 | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 8 | src_stm_code | STRING |  |  |  | 'FIMS.SECURITIESCOMPANY' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số fax. |
| 11 | ip_id | BIGINT |  |  | F |  | FK đến Securities Company. |
| 12 | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 13 | src_stm_code | STRING |  |  |  | 'FIMS.SECURITIESCOMPANY' | Mã nguồn dữ liệu. |
| 14 | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. |
| 15 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |
| 16 | ip_id | BIGINT |  |  | F |  | FK đến Securities Company. |
| 17 | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 18 | src_stm_code | STRING |  |  |  | 'FIMS.SECURITIESCOMPANY' | Mã nguồn dữ liệu. |
| 19 | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. |
| 20 | elc_adr_val | STRING | X |  |  |  | Website. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_co | scr_co_id |




#### Từ FIMS.STOCKEXCHANGE

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Stock Exchange. |
| 2 | ip_code | STRING |  |  |  |  | Mã Sở giao dịch chứng khoán. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.STOCKEXCHANGE' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Email. |
| 6 | ip_id | BIGINT |  |  | F |  | FK đến Stock Exchange. |
| 7 | ip_code | STRING |  |  |  |  | Mã Sở giao dịch chứng khoán. |
| 8 | src_stm_code | STRING |  |  |  | 'FIMS.STOCKEXCHANGE' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số fax. |
| 11 | ip_id | BIGINT |  |  | F |  | FK đến Stock Exchange. |
| 12 | ip_code | STRING |  |  |  |  | Mã Sở giao dịch chứng khoán. |
| 13 | src_stm_code | STRING |  |  |  | 'FIMS.STOCKEXCHANGE' | Mã nguồn dữ liệu. |
| 14 | elc_adr_tp_code | STRING |  |  |  | 'HOTLINE' | Loại kênh liên lạc — hotline. |
| 15 | elc_adr_val | STRING | X |  |  |  | Số hotline. |
| 16 | ip_id | BIGINT |  |  | F |  | FK đến Stock Exchange. |
| 17 | ip_code | STRING |  |  |  |  | Mã Sở giao dịch chứng khoán. |
| 18 | src_stm_code | STRING |  |  |  | 'FIMS.STOCKEXCHANGE' | Mã nguồn dữ liệu. |
| 19 | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. |
| 20 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |
| 21 | ip_id | BIGINT |  |  | F |  | FK đến Stock Exchange. |
| 22 | ip_code | STRING |  |  |  |  | Mã Sở giao dịch chứng khoán. |
| 23 | src_stm_code | STRING |  |  |  | 'FIMS.STOCKEXCHANGE' | Mã nguồn dữ liệu. |
| 24 | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. |
| 25 | elc_adr_val | STRING | X |  |  |  | Website. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | stk_exg | stk_exg_id |




#### Từ FIMS.TLPROFILES

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative Key Person. |
| 2 | ip_code | STRING |  |  |  |  | Mã nhân sự CBTT. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.TLPROFILES' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Email. |
| 6 | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative Key Person. |
| 7 | ip_code | STRING |  |  |  |  | Mã nhân sự CBTT. |
| 8 | src_stm_code | STRING |  |  |  | 'FIMS.TLPROFILES' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | dscl_rprs_key_psn | dscl_rprs_key_psn_id |







### 2.{IDX}.23 Bảng ip_alt_identn



#### Từ FIMS.BANKMONI

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Custodian Bank. |
| 2 | ip_code | STRING |  |  |  |  | Mã ngân hàng lưu ký giám sát. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.BANKMONI' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  | 'BUSINESS_LICENSE' | Loại giấy tờ: giấy phép kinh doanh. |
| 5 | identn_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép kinh doanh. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy phép kinh doanh. |
| 8 | ip_id | BIGINT |  |  | F |  | FK đến Custodian Bank. |
| 9 | ip_code | STRING |  |  |  |  | Mã ngân hàng lưu ký giám sát. |
| 10 | src_stm_code | STRING |  |  |  | 'FIMS.BANKMONI' | Mã nguồn dữ liệu. |
| 11 | identn_tp_code | STRING |  |  |  | 'OPERATING_LICENSE' | Loại giấy tờ: giấy phép đăng ký/hoạt động. |
| 12 | identn_nbr | STRING | X |  |  |  | Số giấy phép đăng ký/hoạt động. |
| 13 | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép đăng ký/hoạt động. |
| 14 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy phép đăng ký/hoạt động. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | cstd_bnk | cstd_bnk_id |




#### Từ FIMS.BRANCHS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company Organization Unit. |
| 2 | ip_code | STRING |  |  |  |  | Mã chi nhánh công ty quản lý quỹ. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.BRANCHS' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  | 'BUSINESS_LICENSE' | Loại giấy tờ: giấy phép kinh doanh. |
| 5 | identn_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép kinh doanh. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy phép kinh doanh. |
| 8 | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company Organization Unit. |
| 9 | ip_code | STRING |  |  |  |  | Mã chi nhánh công ty quản lý quỹ. |
| 10 | src_stm_code | STRING |  |  |  | 'FIMS.BRANCHS' | Mã nguồn dữ liệu. |
| 11 | identn_tp_code | STRING |  |  |  | 'OPERATING_LICENSE' | Loại giấy tờ: giấy phép hoạt động. |
| 12 | identn_nbr | STRING | X |  |  |  | Số giấy phép hoạt động. |
| 13 | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép hoạt động. |
| 14 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy phép hoạt động. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | fnd_mgt_co_ou | fnd_mgt_co_ou_id |




#### Từ FIMS.FUNDCOMPANY

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.FUNDCOMPANY' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  | 'BUSINESS_LICENSE' | Loại giấy tờ: giấy phép kinh doanh. |
| 5 | identn_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép kinh doanh. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy phép kinh doanh. |
| 8 | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. |
| 9 | ip_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. |
| 10 | src_stm_code | STRING |  |  |  | 'FIMS.FUNDCOMPANY' | Mã nguồn dữ liệu. |
| 11 | identn_tp_code | STRING |  |  |  | 'OPERATING_LICENSE' | Loại giấy tờ: giấy phép đăng ký/hoạt động. |
| 12 | identn_nbr | STRING | X |  |  |  | Số giấy phép đăng ký/hoạt động. |
| 13 | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép đăng ký/hoạt động. |
| 14 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy phép đăng ký/hoạt động. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | fnd_mgt_co | fnd_mgt_co_id |




#### Từ FIMS.SECURITIESCOMPANY

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Securities Company. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.SECURITIESCOMPANY' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  | 'BUSINESS_LICENSE' | Loại giấy tờ: giấy phép kinh doanh. |
| 5 | identn_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép kinh doanh. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy phép kinh doanh. |
| 8 | ip_id | BIGINT |  |  | F |  | FK đến Securities Company. |
| 9 | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 10 | src_stm_code | STRING |  |  |  | 'FIMS.SECURITIESCOMPANY' | Mã nguồn dữ liệu. |
| 11 | identn_tp_code | STRING |  |  |  | 'OPERATING_LICENSE' | Loại giấy tờ: giấy phép đăng ký/hoạt động. |
| 12 | identn_nbr | STRING | X |  |  |  | Số giấy phép đăng ký/hoạt động. |
| 13 | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép đăng ký/hoạt động. |
| 14 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy phép đăng ký/hoạt động. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_co | scr_co_id |




#### Từ FIMS.INVESTOR

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Foreign Investor. |
| 2 | ip_code | STRING |  |  |  |  | Mã nhà đầu tư nước ngoài. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.INVESTOR' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  | 'CITIZEN_ID' | Loại giấy tờ: CCCD/Hộ chiếu. |
| 5 | identn_nbr | STRING | X |  |  |  | Số CCCD/Hộ chiếu. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp CCCD/Hộ chiếu. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp CCCD/Hộ chiếu. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | frgn_ivsr | frgn_ivsr_id |




#### Từ FIMS.TLPROFILES

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative Key Person. |
| 2 | ip_code | STRING |  |  |  |  | Mã nhân sự CBTT. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.TLPROFILES' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  | 'CITIZEN_ID' | Loại giấy tờ: CCCD/Hộ chiếu. |
| 5 | identn_nbr | STRING | X |  |  |  | Số CCCD/Hộ chiếu. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp CCCD/Hộ chiếu. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp CCCD/Hộ chiếu. |
| 8 | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative Key Person. |
| 9 | ip_code | STRING |  |  |  |  | Mã nhân sự CBTT. |
| 10 | src_stm_code | STRING |  |  |  | 'FIMS.TLPROFILES' | Mã nguồn dữ liệu. |
| 11 | identn_tp_code | STRING |  |  |  | 'PRACTITIONER_LICENSE' | Loại giấy tờ: chứng chỉ hành nghề. |
| 12 | identn_nbr | STRING | X |  |  |  | Số chứng chỉ hành nghề. |
| 13 | issu_dt | DATE | X |  |  |  | Ngày cấp chứng chỉ hành nghề. |
| 14 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp chứng chỉ hành nghề. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | dscl_rprs_key_psn | dscl_rprs_key_psn_id |




#### Từ FIMS.INFODISCREPRES

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative. |
| 2 | ip_code | STRING |  |  |  |  | Mã người/tổ chức đại diện CBTT. |
| 3 | src_stm_code | STRING |  |  |  | 'FIMS.INFODISCREPRES' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  | 'BUSINESS_LICENSE' | Loại giấy tờ: giấy phép đăng ký kinh doanh. |
| 5 | identn_nbr | STRING | X |  |  |  | Số giấy phép đăng ký kinh doanh. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép điều chỉnh. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Cơ quan cấp giấy phép thành lập |
| 8 | ip_id | BIGINT |  |  | F |  | FK đến Disclosure Representative. |
| 9 | ip_code | STRING |  |  |  |  | Mã người/tổ chức đại diện CBTT. |
| 10 | src_stm_code | STRING |  |  |  | 'FIMS.INFODISCREPRES' | Mã nguồn dữ liệu. |
| 11 | identn_tp_code | STRING |  |  |  | 'CITIZEN_ID' | Loại giấy tờ: CCCD. |
| 12 | identn_nbr | STRING | X |  |  |  | Số CCCD. |
| 13 | issu_dt | DATE | X |  |  |  | Ngày cấp CCCD. |
| 14 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp CCCD. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | dscl_rprs | dscl_rprs_id |






