## 2.{IDX} SCMS — 

### 2.{IDX}.1 Các mô hình quan hệ dữ liệu

- DBML tổng hợp (tất cả bảng): [`SCMS.dbml`](SCMS.dbml) — paste vào https://dbdiagram.io để render.
- Diagram theo mảng nghiệp vụ:
  - **UID01 — Quản lý CTCK**: [`SCMS_UID01.dbml`](SCMS_UID01.dbml)
  - **UID02 — Quản lý CN CTCK nước ngoài tại VN**: [`SCMS_UID02.dbml`](SCMS_UID02.dbml)
  - **UID03 — Quản lý VPDD CTCK nước ngoài tại VN**: [`SCMS_UID03.dbml`](SCMS_UID03.dbml)
  - **UID04 — Quản lý ngân hàng thanh toán, lưu ký**: [`SCMS_UID04.dbml`](SCMS_UID04.dbml)
  - **UID05 — Khai thác công ty kiểm toán và kiểm toán viên**: [`SCMS_UID05.dbml`](SCMS_UID05.dbml)
  - **UID06 — Cảnh báo vi phạm**: [`SCMS_UID06.dbml`](SCMS_UID06.dbml)
  - **UID08 — Quản trị phân hệ**: [`SCMS_UID08.dbml`](SCMS_UID08.dbml)


**Danh sách bảng:**

| STT | Thực thể | Tên bảng | Mô tả |
|---|---|---|---|
| 1 | Securities Company | scr_co | Công ty chứng khoán - thành viên thị trường trong hệ thống FIMS. Quản lý tài khoản và danh mục NĐT nước ngoài. |
| 2 | Audit Firm | audt_firm | Công ty kiểm toán được UBCKNN chấp thuận. Ghi nhận thông tin pháp lý và trạng thái hoạt động. |
| 3 | Involved Party Alternative Identification | ip_alt_identn | Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn. |
| 4 | Foreign Representative Office | frgn_representative_offc | Văn phòng đại diện của công ty chứng khoán nước ngoài tại Việt Nam. Pháp nhân độc lập, không FK đến CTCK trong nước. |
| 5 | Geographic Area | geo | Đơn vị địa lý dùng làm FK tham chiếu: quốc gia/quốc tịch (COUNTRY), vùng/miền (REGION), tỉnh/thành phố mới/cũ (PROVINCE/PROVINCE_OLD), quận/huyện cũ (DISTRICT_OLD), phường/xã mới/cũ (WARD/WARD_OLD). Phân biệt bằng geographic_area_type_code. Hỗ trợ song song bộ danh mục pre- và post-sáp nhập hành chính 2025. |
| 6 | Report Template | rpt_tpl | Biểu mẫu báo cáo đầu vào - khuôn mẫu tờ khai định kỳ mà thành viên thị trường phải nộp theo quy định. |
| 7 | Involved Party Postal Address | ip_pst_adr | Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn. |
| 8 | Involved Party Electronic Address | ip_elc_adr | Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn. |
| 9 | Securities Company Organization Unit | scr_co_ou | Đơn vị trực thuộc CTCK: chi nhánh, văn phòng đại diện, phòng giao dịch. Cấu trúc self-join qua parent_org_unit_id. |
| 10 | Securities Practitioner | scr_practitioner | Người hành nghề chứng khoán được UBCKNN cấp phép. Ghi nhận thông tin cá nhân và trạng thái hành nghề. Attribute chi tiết (BirthDate full |
| 11 | Securities Company Senior Personnel | scr_co_snr_psn | Nhân sự cao cấp của CTCK (Chủ tịch HĐQT, Tổng Giám đốc, Kế toán trưởng...). Ghi nhận chức vụ và thời gian đảm nhận. |
| 12 | Securities Company Shareholder | scr_co_shrhlr | Cổ đông của CTCK - cá nhân hoặc tổ chức. Ghi nhận tỷ lệ sở hữu và số lượng cổ phần. |
| 13 | Audit Firm Practitioner | audt_firm_practitioner | Kiểm toán viên thuộc công ty kiểm toán. Ghi nhận chứng chỉ kiểm toán và trạng thái hành nghề. |
| 14 | Report Template Sheet | report_template_sheet |  |
| 15 | Report Template Row | report_template_row |  |
| 16 | Report Template Column | report_template_column |  |
| 17 | Report Submission Schedule | rpt_submission_shd | Lịch định kỳ gửi báo cáo theo biểu mẫu (hàng ngày/tuần/tháng/quý/năm). Xác định tần suất nghĩa vụ nộp báo cáo. |
| 18 | Report Indicator | report_indicator |  |
| 19 | Report Template Indicator | report_template_indicator |  |
| 20 | Report Submission Obligation | rpt_submission_oblg | Nghĩa vụ gửi báo cáo của từng CTCK theo định kỳ cụ thể. Xác định đơn vị nào phải nộp biểu mẫu nào theo lịch nào. |
| 21 | Member Periodic Report | mbr_prd_rpt | Báo cáo định kỳ do thành viên thị trường nộp lên UBCKNN theo từng kỳ báo cáo. Ghi nhận trạng thái nộp và thời hạn. |
| 22 | Securities Company Report Violation | scr_co_rpt_vln | Vi phạm nộp báo cáo định kỳ của CTCK. Ghi nhận loại vi phạm và thông tin xử lý. |
| 23 | Securities Company Administrative Penalty | scr_co_admn_pny | Quyết định xử lý hành chính đối với CTCK. Ghi nhận hành vi vi phạm và quyết định xử phạt. |
| 24 | Disclosure Report Submission | dscl_rpt_submission | Báo cáo công bố thông tin do CTCK nộp lên UBCKNN theo yêu cầu minh bạch thị trường. |
| 25 | Disclosure Securities Offering | dscl_scr_ofrg | Thông tin chào bán chứng khoán được công bố bởi CTCK. Ghi nhận loại chứng khoán và điều kiện chào bán. |
| 26 | Disclosure Shareholder Change | dscl_shrhlr_chg | Thông tin thay đổi cổ đông được công bố bởi CTCK. Ghi nhận cổ đông và tỷ lệ sở hữu thay đổi. |
| 27 | Member Report Indicator Value | mbr_rpt_ind_val | Giá trị từng chỉ tiêu trong một lần nộp báo cáo định kỳ. Grain = 1 giá trị cell-level (submission x template_indicator x row). FK đến Member Periodic Report. |
| 28 | Securities Company Shareholder Transfer | scr_co_shrhlr_tfr | Giao dịch chuyển nhượng cổ phần giữa hai cổ đông của CTCK. Ghi nhận bên chuyển/nhận, số lượng và tỷ lệ chuyển nhượng. |
| 29 | Securities Company Shareholder Representative | scr_co_shrhlr_representative | Người đại diện được ủy quyền bởi cổ đông của CTCK. Ghi nhận chức vụ và số lượng cổ phần đại diện. |
| 30 | Securities Company Shareholder Related Party | scr_co_shrhlr_rel_p | Người có quan hệ gia đình hoặc công tác với cổ đông của CTCK. Ghi nhận loại quan hệ và nơi làm việc. |



### 2.{IDX}.2 Bảng Securities Company

- **Mô tả:** Công ty chứng khoán - thành viên thị trường trong hệ thống FIMS. Quản lý tài khoản và danh mục NĐT nước ngoài.
- **Tên vật lý:** scr_co
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Securities Company Id | scr_co_id | BIGINT |  | X | P |  | Khóa đại diện cho công ty chứng khoán. | SCMS.CTCK_THONG_TIN |  | PK surrogate. Shared entity với FIMS.SECURITIESCOMPANY. |
| 2 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã định danh CTCK (tự động tăng). BK kỹ thuật. | SCMS.CTCK_THONG_TIN | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_THONG_TIN' | Mã nguồn dữ liệu. | SCMS.CTCK_THONG_TIN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Country of Registration Id | cty_of_rgst_id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký. | SCMS.CTCK_THONG_TIN | QUOC_GIA_ID |  |
| 5 | Country of Registration Code | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. | SCMS.CTCK_THONG_TIN | QUOC_GIA_ID |  |
| 6 | Full Name | full_nm | STRING |  |  |  |  | Tên công ty chứng khoán. | SCMS.CTCK_THONG_TIN |  |  |
| 7 | English Name | english_nm | STRING | X |  |  |  | Tên tiếng Anh. | SCMS.CTCK_THONG_TIN |  |  |
| 8 | Abbreviation | abr | STRING | X |  |  |  | Tên viết tắt. | SCMS.CTCK_THONG_TIN |  |  |
| 9 | Charter Capital Amount | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ. | SCMS.CTCK_THONG_TIN | VON_DIEU_LE |  |
| 10 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. | SCMS.CTCK_THONG_TIN |  | Scheme: LIFE_CYCLE_STATUS. |
| 11 | Director Name | director_nm | STRING | X |  |  |  | Tên Tổng giám đốc (denormalized). | SCMS.CTCK_THONG_TIN |  |  |
| 12 | Depository Certificate Number | depst_ctf_nbr | STRING | X |  |  |  | Chứng nhận lưu ký. | SCMS.CTCK_THONG_TIN |  |  |
| 13 | Business Type Codes | bsn_tp_codes | Array<Text> | X |  |  |  | Danh sách mã nghiệp vụ kinh doanh. Từ bảng junction SECCOMBUSINES. | SCMS.CTCK_THONG_TIN |  |  |
| 14 | Company Type Codes | co_tp_codes | Array<Text> | X |  |  |  | Danh sách mã loại hình doanh nghiệp. Từ bảng junction SECCOMTYPE. | SCMS.CTCK_THONG_TIN |  |  |
| 15 | Description | dsc | STRING | X |  |  |  | Ghi chú. | SCMS.CTCK_THONG_TIN |  |  |
| 16 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | SCMS.CTCK_THONG_TIN |  |  |
| 17 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.CTCK_THONG_TIN | NGAY_TAO |  |
| 18 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. | SCMS.CTCK_THONG_TIN | NGAY_CAP_NHAT |  |
| 19 | Securities Company Business Key | scr_co_bsn_key | STRING | X |  |  |  | ID duy nhất của CTCK dùng liên thông hệ thống (BK nghiệp vụ). | SCMS.CTCK_THONG_TIN | CTCK_THONG_TIN_ID |  |
| 20 | Securities Company Business Code | scr_co_bsn_code | STRING | X |  |  |  | Mã số CTCK (mã nghiệp vụ ngắn). | SCMS.CTCK_THONG_TIN | MA_SO |  |
| 21 | Securities Company Name | scr_co_nm | STRING | X |  |  |  | Tên tiếng Việt. | SCMS.CTCK_THONG_TIN | TEN_TIENG_VIET |  |
| 22 | Securities Company English Name | scr_co_english_nm | STRING | X |  |  |  | Tên tiếng Anh. | SCMS.CTCK_THONG_TIN | TEN_TIENG_ANH |  |
| 23 | Securities Company Short Name | scr_co_shrt_nm | STRING | X |  |  |  | Tên viết tắt. | SCMS.CTCK_THONG_TIN | TEN_VIET_TAT |  |
| 24 | Tax Code | tax_code | STRING | X |  |  |  | Mã số thuế. | SCMS.CTCK_THONG_TIN | MA_SO_THUE |  |
| 25 | Company Type Code | co_tp_code | STRING | X |  |  |  | Loại hình công ty. | SCMS.CTCK_THONG_TIN | LOAI_CONG_TY_ID | Scheme: SCMS_COMPANY_TYPE. |
| 26 | Share Quantity | shr_qty | INT | X |  |  |  | Số lượng cổ phần. | SCMS.CTCK_THONG_TIN | SO_LUONG_CO_PHAN |  |
| 27 | Business Sector Codes | bsn_sctr_codes | Array<Text> | X |  |  |  | Danh sách mã ngành nghề kinh doanh. | SCMS.CTCK_THONG_TIN | NGANH_NGHE_KD_ID |  |
| 28 | Is Listed Indicator | is_list_ind | STRING | X |  |  |  | Cờ niêm yết: 1-Có niêm yết; 0-Không. | SCMS.CTCK_THONG_TIN | NIEM_YET |  |
| 29 | Stock Exchange Name | stk_exg_nm | STRING | X |  |  |  | Sàn niêm yết. | SCMS.CTCK_THONG_TIN | SAN_NIEM_YET |  |
| 30 | Securities Code | scr_code | STRING | X |  |  |  | Mã chứng khoán niêm yết. | SCMS.CTCK_THONG_TIN | MA_CHUNG_KHOAN |  |
| 31 | Registration Date | rgst_dt | DATE | X |  |  |  | Ngày đăng ký CTDC. | SCMS.CTCK_THONG_TIN | NGAY_DANG_KY_CTDC |  |
| 32 | Registration Decision Number | rgst_dcsn_nbr | STRING | X |  |  |  | Số quyết định đăng ký. | SCMS.CTCK_THONG_TIN | SO_QUYET_DINH |  |
| 33 | Termination Date | tmt_dt | DATE | X |  |  |  | Ngày kết thúc CTDC. | SCMS.CTCK_THONG_TIN | NGAY_KET_THUC_CTDC |  |
| 34 | Termination Decision Number | tmt_dcsn_nbr | STRING | X |  |  |  | Số quyết định kết thúc. | SCMS.CTCK_THONG_TIN | SO_QUYET_DINH_KET_THUC |  |
| 35 | Company Status Code | co_st_code | STRING | X |  |  |  | Trạng thái hoạt động của CTCK. | SCMS.CTCK_THONG_TIN | TRANG_THAI | Scheme: SCMS_COMPANY_STATUS. |
| 36 | Is Draft Indicator | is_drft_ind | STRING | X |  |  |  | Cờ bảng tạm: 1-Bảng tạm; 0-Chính thức. | SCMS.CTCK_THONG_TIN | IS_BANG_TAM |  |
| 37 | Business Activity Category Id | bsn_avy_cgy_id | BIGINT | X |  | F |  | FK đến ngành nghề kinh doanh (DM_NGANH_NGHE_KD). Nullable. | SCMS.CTCK_THONG_TIN | NGANH_NGHE_KINH_DOANH |  |
| 38 | Business Activity Category Code | bsn_avy_cgy_code | STRING | X |  |  |  | Mã ngành nghề kinh doanh. | SCMS.CTCK_THONG_TIN | NGANH_NGHE_KINH_DOANH |  |
| 39 | Business License Number | bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. | SCMS.CTCK_THONG_TIN |  |  |
| 40 | Website | webst | STRING | X |  |  |  | Website chính thức. | SCMS.CTCK_THONG_TIN |  |  |


#### 2.{IDX}.2.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Securities Company Id | scr_co_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Country of Registration Id | cty_of_rgst_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.3 Bảng Audit Firm

- **Mô tả:** Công ty kiểm toán được UBCKNN chấp thuận. Ghi nhận thông tin pháp lý và trạng thái hoạt động.
- **Tên vật lý:** audt_firm
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Audit Firm Id | audt_firm_id | BIGINT |  | X | P |  | Khóa đại diện cho công ty kiểm toán. | SCMS.CT_KIEM_TOAN |  | PK surrogate. |
| 2 | Audit Firm Code | audt_firm_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.CT_KIEM_TOAN | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CT_KIEM_TOAN' | Mã nguồn dữ liệu. | SCMS.CT_KIEM_TOAN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Audit Firm Business Code | audt_firm_bsn_code | STRING | X |  |  |  | Mã số công ty kiểm toán (mã nghiệp vụ). | SCMS.CT_KIEM_TOAN | MA_SO |  |
| 5 | Audit Firm Name | audt_firm_nm | STRING | X |  |  |  | Tên tiếng Việt. | SCMS.CT_KIEM_TOAN | TEN_TIENG_VIET |  |
| 6 | Audit Firm English Name | audt_firm_english_nm | STRING | X |  |  |  | Tên tiếng Anh. | SCMS.CT_KIEM_TOAN | TEN_TIENG_ANH |  |
| 7 | Audit Firm Short Name | audt_firm_shrt_nm | STRING | X |  |  |  | Tên viết tắt. | SCMS.CT_KIEM_TOAN | TEN_VIET_TAT |  |
| 8 | Charter Capital Amount | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ. | SCMS.CT_KIEM_TOAN | VON_DIEU_LE |  |
| 9 | Approval Decision Number | aprv_dcsn_nbr | STRING | X |  |  |  | Số quyết định chấp thuận của UBCKNN. | SCMS.CT_KIEM_TOAN | SO_QUYET_DINH |  |
| 10 | Note | note | STRING | X |  |  |  | Ghi chú. | SCMS.CT_KIEM_TOAN | GHI_CHU |  |
| 11 | Audit Firm Status Code | audt_firm_st_code | STRING | X |  |  |  | Trạng thái hoạt động. | SCMS.CT_KIEM_TOAN | TRANG_THAI | Scheme: SCMS_COMPANY_STATUS. |
| 12 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.CT_KIEM_TOAN | NGAY_TAO |  |
| 13 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. | SCMS.CT_KIEM_TOAN | NGAY_CAP_NHAT |  |
| 14 | Business Registration Number | bsn_rgst_nbr | STRING | X |  |  |  | Giấy chứng nhận đăng ký kinh doanh. | SCMS.CT_KIEM_TOAN |  |  |
| 15 | Eligibility Certificate Number | elig_ctf_nbr | STRING | X |  |  |  | Giấy chứng nhận đủ điều kiện kinh doanh dịch vụ kiểm toán. | SCMS.CT_KIEM_TOAN |  |  |
| 16 | Approval Date | aprv_dt | DATE | X |  |  |  | Ngày chấp thuận. | SCMS.CT_KIEM_TOAN |  |  |
| 17 | Foreign Audit Member Flag | frgn_audt_mbr_f | BOOLEAN | X |  |  |  | Là thành viên hãng kiểm toán quốc tế (1=có / 0=không). | SCMS.CT_KIEM_TOAN |  |  |
| 18 | Membership Start Date | mbr_strt_dt | DATE | X |  |  |  | Ngày trở thành thành viên hãng kiểm toán quốc tế. | SCMS.CT_KIEM_TOAN |  |  |
| 19 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | SCMS.CT_KIEM_TOAN |  |  |
| 20 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | SCMS.CT_KIEM_TOAN |  |  |
| 21 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. | SCMS.CT_KIEM_TOAN |  |  |


#### 2.{IDX}.3.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Audit Firm Id | audt_firm_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.4 Bảng Involved Party Alternative Identification — SCMS.CT_KIEM_TOAN

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến công ty kiểm toán. | SCMS.CT_KIEM_TOAN | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty kiểm toán. | SCMS.CT_KIEM_TOAN | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CT_KIEM_TOAN' | Mã nguồn dữ liệu. | SCMS.CT_KIEM_TOAN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'BUSINESS_LICENSE' | Loại giấy tờ định danh: giấy phép kinh doanh. | SCMS.CT_KIEM_TOAN |  | Scheme: IP_ALT_ID_TYPE. ETL-derived. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. | SCMS.CT_KIEM_TOAN | GIAY_PHEP_KINH_DOANH |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép kinh doanh. | SCMS.CT_KIEM_TOAN | NGAY_CAP_GPKD |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy phép kinh doanh. | SCMS.CT_KIEM_TOAN | NOI_CAP_GPKD |  |


#### 2.{IDX}.4.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Audit Firm | Audit Firm Id | audt_firm_id |




### 2.{IDX}.5 Bảng Foreign Representative Office

- **Mô tả:** Văn phòng đại diện của công ty chứng khoán nước ngoài tại Việt Nam. Pháp nhân độc lập, không FK đến CTCK trong nước.
- **Tên vật lý:** frgn_representative_offc
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Foreign Representative Office Id | frgn_representative_offc_id | BIGINT |  | X | P |  | Khóa đại diện cho văn phòng đại diện nước ngoài. | SCMS.CTCK_VP_DAI_DIEN_NN |  | PK surrogate. |
| 2 | Foreign Representative Office Code | frgn_representative_offc_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.CTCK_VP_DAI_DIEN_NN | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_VP_DAI_DIEN_NN' | Mã nguồn dữ liệu. | SCMS.CTCK_VP_DAI_DIEN_NN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Parent Company Name | prn_co_nm | STRING | X |  |  |  | Tên công ty mẹ (công ty chứng khoán nước ngoài). | SCMS.CTCK_VP_DAI_DIEN_NN | TEN_CONG_TY_ME |  |
| 5 | Parent Company Address | prn_co_adr | STRING | X |  |  |  | Địa chỉ trụ sở công ty mẹ. | SCMS.CTCK_VP_DAI_DIEN_NN | DIA_CHI |  |
| 6 | Parent Company License Number | prn_co_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh công ty mẹ. | SCMS.CTCK_VP_DAI_DIEN_NN | GIAY_PHEP_KINH_DOANH |  |
| 7 | Parent Company License Date | prn_co_license_dt | DATE | X |  |  |  | Ngày cấp giấy phép kinh doanh công ty mẹ. | SCMS.CTCK_VP_DAI_DIEN_NN | NGAY_CAP_GPKD |  |
| 8 | Parent Company License Issuer | prn_co_license_issur | STRING | X |  |  |  | Nơi cấp giấy phép kinh doanh công ty mẹ. | SCMS.CTCK_VP_DAI_DIEN_NN | NOI_CAP_GPKD |  |
| 9 | Office Name | offc_nm | STRING | X |  |  |  | Tên văn phòng đại diện tại Việt Nam. | SCMS.CTCK_VP_DAI_DIEN_NN | TEN_VAN_PHONG_DAI_DIEN |  |
| 10 | Office Address | offc_adr | STRING | X |  |  |  | Địa chỉ văn phòng đại diện tại Việt Nam. | SCMS.CTCK_VP_DAI_DIEN_NN | DIA_CHI_VAN_PHONG |  |
| 11 | Office License Number | offc_license_nbr | STRING | X |  |  |  | Số giấy phép hoạt động văn phòng đại diện tại VN. | SCMS.CTCK_VP_DAI_DIEN_NN | GIAY_PHEP_KINH_DOANH_VP |  |
| 12 | Office License Date | offc_license_dt | DATE | X |  |  |  | Ngày cấp giấy phép văn phòng đại diện. | SCMS.CTCK_VP_DAI_DIEN_NN | NGAY_CAP_GPKD_VP |  |
| 13 | Office License Issuer | offc_license_issur | STRING | X |  |  |  | Nơi cấp giấy phép văn phòng đại diện. | SCMS.CTCK_VP_DAI_DIEN_NN | NOI_CAP_GPKD_VP |  |
| 14 | Representative Name | representative_nm | STRING | X |  |  |  | Trưởng văn phòng đại diện. | SCMS.CTCK_VP_DAI_DIEN_NN | TRUONG_DAI_DIEN |  |
| 15 | Nationality Id | nationality_id | BIGINT | X |  | F |  | FK đến quốc tịch trưởng đại diện. | SCMS.CTCK_VP_DAI_DIEN_NN | QUOC_TICH_ID |  |
| 16 | Nationality Code | nationality_code | STRING | X |  |  |  | Mã quốc tịch trưởng đại diện. | SCMS.CTCK_VP_DAI_DIEN_NN | QUOC_TICH_ID |  |
| 17 | Note | note | STRING | X |  |  |  | Ghi chú. | SCMS.CTCK_VP_DAI_DIEN_NN | GHI_CHU |  |
| 18 | Foreign Representative Office Status Code | frgn_representative_offc_st_code | STRING | X |  |  |  | Trạng thái hoạt động. | SCMS.CTCK_VP_DAI_DIEN_NN | TRANG_THAI | Scheme: SCMS_COMPANY_STATUS. |
| 19 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.CTCK_VP_DAI_DIEN_NN | NGAY_TAO |  |
| 20 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. | SCMS.CTCK_VP_DAI_DIEN_NN | NGAY_CAP_NHAT |  |


#### 2.{IDX}.5.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Foreign Representative Office Id | frgn_representative_offc_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Nationality Id | nationality_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.6 Bảng Geographic Area — SCMS.DM_TINH_THANH

- **Mô tả:** Đơn vị địa lý dùng làm FK tham chiếu: quốc gia/quốc tịch (COUNTRY), vùng/miền (REGION), tỉnh/thành phố mới/cũ (PROVINCE/PROVINCE_OLD), quận/huyện cũ (DISTRICT_OLD), phường/xã mới/cũ (WARD/WARD_OLD). Phân biệt bằng geographic_area_type_code. Hỗ trợ song song bộ danh mục pre- và post-sáp nhập hành chính 2025.
- **Tên vật lý:** geo
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Geographic Area Id | geo_id | BIGINT |  | X | P |  | Khóa đại diện cho khu vực địa lý. | SCMS.DM_TINH_THANH |  | PK surrogate. Shared entity — dùng chung với FIMS.NATIONAL và SCMS.DM_QUOC_TICH. |
| 2 | Geographic Area Code | geo_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.DM_TINH_THANH | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.DM_TINH_THANH' | Mã nguồn dữ liệu. | SCMS.DM_TINH_THANH |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Geographic Area Short Code | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. | SCMS.DM_TINH_THANH |  |  |
| 5 | Geographic Area Name | geo_nm | STRING |  |  |  |  | Tên tỉnh/thành phố. | SCMS.DM_TINH_THANH | TEN_TINH_THANH |  |
| 6 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái sử dụng. | SCMS.DM_TINH_THANH | TRANG_THAI | Scheme: LIFE_CYCLE_STATUS. |
| 7 | Description | dsc | STRING | X |  |  |  | Mô tả. | SCMS.DM_TINH_THANH |  |  |
| 8 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | SCMS.DM_TINH_THANH |  |  |
| 9 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.DM_TINH_THANH | NGAY_TAO |  |
| 10 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | SCMS.DM_TINH_THANH |  |  |
| 11 | Geographic Area Type Code | geo_tp_code | STRING |  |  |  | 'PROVINCE' | Loại khu vực địa lý: PROVINCE — tỉnh/thành phố. | SCMS.DM_TINH_THANH |  | Scheme: GEOGRAPHIC_AREA_TYPE. ETL-derived: hardcode PROVINCE cho bảng này. |
| 12 | Geographic Area Business Code | geo_bsn_code | STRING | X |  |  |  | Mã tỉnh/thành phố (mã nghiệp vụ). | SCMS.DM_TINH_THANH | MA_TINH_THANH |  |
| 13 | Note | note | STRING | X |  |  |  | Ghi chú. | SCMS.DM_TINH_THANH | GHI_CHU |  |


#### 2.{IDX}.6.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Geographic Area Id | geo_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.7 Bảng Geographic Area — SCMS.DM_QUOC_TICH

- **Mô tả:** Đơn vị địa lý dùng làm FK tham chiếu: quốc gia/quốc tịch (COUNTRY), vùng/miền (REGION), tỉnh/thành phố mới/cũ (PROVINCE/PROVINCE_OLD), quận/huyện cũ (DISTRICT_OLD), phường/xã mới/cũ (WARD/WARD_OLD). Phân biệt bằng geographic_area_type_code. Hỗ trợ song song bộ danh mục pre- và post-sáp nhập hành chính 2025.
- **Tên vật lý:** geo
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Geographic Area Id | geo_id | BIGINT |  | X | P |  | Khóa đại diện cho khu vực địa lý. | SCMS.DM_QUOC_TICH |  | PK surrogate. Shared entity — dùng chung với FIMS.NATIONAL và SCMS.DM_TINH_THANH. |
| 2 | Geographic Area Code | geo_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.DM_QUOC_TICH | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.DM_QUOC_TICH' | Mã nguồn dữ liệu. | SCMS.DM_QUOC_TICH |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Geographic Area Short Code | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. | SCMS.DM_QUOC_TICH |  |  |
| 5 | Geographic Area Name | geo_nm | STRING |  |  |  |  | Tên quốc tịch/quốc gia. | SCMS.DM_QUOC_TICH | TEN_QUOC_TICH |  |
| 6 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái sử dụng. | SCMS.DM_QUOC_TICH | TRANG_THAI | Scheme: LIFE_CYCLE_STATUS. |
| 7 | Description | dsc | STRING | X |  |  |  | Mô tả. | SCMS.DM_QUOC_TICH |  |  |
| 8 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | SCMS.DM_QUOC_TICH |  |  |
| 9 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.DM_QUOC_TICH | NGAY_TAO |  |
| 10 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | SCMS.DM_QUOC_TICH |  |  |
| 11 | Geographic Area Type Code | geo_tp_code | STRING |  |  |  | 'COUNTRY' | Loại khu vực địa lý: COUNTRY — quốc gia/quốc tịch. | SCMS.DM_QUOC_TICH |  | Scheme: GEOGRAPHIC_AREA_TYPE. ETL-derived: hardcode COUNTRY cho bảng này. |
| 12 | Geographic Area Business Code | geo_bsn_code | STRING | X |  |  |  | Mã quốc tịch/quốc gia (mã nghiệp vụ). | SCMS.DM_QUOC_TICH | MA_QUOC_TICH |  |
| 13 | Note | note | STRING | X |  |  |  | Ghi chú. | SCMS.DM_QUOC_TICH | GHI_CHU |  |


#### 2.{IDX}.7.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Geographic Area Id | geo_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.8 Bảng Report Template

- **Mô tả:** Biểu mẫu báo cáo đầu vào - khuôn mẫu tờ khai định kỳ mà thành viên thị trường phải nộp theo quy định.
- **Tên vật lý:** rpt_tpl
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Report Template Id | rpt_tpl_id | BIGINT |  | X | P |  | Khóa đại diện cho biểu mẫu báo cáo. | SCMS.BM_BAO_CAO |  | PK surrogate. Shared entity với FIMS.RPTTEMP. |
| 2 | Report Template Code | rpt_tpl_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.BM_BAO_CAO | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.BM_BAO_CAO' | Mã nguồn dữ liệu. | SCMS.BM_BAO_CAO |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Report Type Code | rpt_tp_code | STRING | X |  |  |  | Loại báo cáo. Dữ liệu lấy từ trường ID của bảng REPORTTYPE. | SCMS.BM_BAO_CAO |  | Scheme: FIMS_REPORT_TYPE. |
| 5 | Report Template Name | rpt_tpl_nm | STRING |  |  |  |  | Tên báo cáo. | SCMS.BM_BAO_CAO | TEN_BAO_CAO |  |
| 6 | Report Template Business Code | rpt_tpl_bsn_code | STRING | X |  |  |  | Mã báo cáo (mã nghiệp vụ). | SCMS.BM_BAO_CAO | MA_BAO_CAO |  |
| 7 | Legal Basis | lgl_bss | STRING | X |  |  |  | Căn cứ pháp lý. | SCMS.BM_BAO_CAO | CAN_CU_PHAP_LY |  |
| 8 | Report Group Code | rpt_grp_code | STRING | X |  |  |  | Nhóm báo cáo: 1: Báo cáo CTQLQ 2: CTCK 3: NHLK 4: TTLK 5: SGDCK 6: Người đại diện CBTT 7: CN CTQLQ NN tại VN. | SCMS.BM_BAO_CAO |  | Scheme: FIMS_REPORT_GROUP. modeler_defined — 7 giá trị enum. |
| 9 | Reporting Subject Code | rpt_sbj_code | STRING | X |  |  |  | Đối tượng gửi báo cáo: 1: CTQLQ 2: CTCK 3: NHLK 4: TTLK 5: SGDCK 6: Người đại diện CBTT 7: CN CTQLQ NN tại VN. | SCMS.BM_BAO_CAO |  | Scheme: FIMS_MEMBER_TYPE. 7 giá trị enum — cùng tập với TLPROFILES.SystemObject. |
| 10 | Version | vrsn | STRING | X |  |  |  | Phiên bản biểu mẫu. | SCMS.BM_BAO_CAO | PHIEN_BAN |  |
| 11 | Effective Date | eff_dt | DATE | X |  |  |  | Ngày bắt đầu sử dụng biểu mẫu. | SCMS.BM_BAO_CAO |  |  |
| 12 | Template Status Code | tpl_st_code | STRING | X |  |  |  | Trạng thái: 0: Bản nháp 1: Đang sử dụng 2: Không sử dụng. | SCMS.BM_BAO_CAO |  | Scheme: FIMS_TEMPLATE_STATUS. modeler_defined — 3 giá trị: 0=DRAFT 1=ACTIVE 2=INACTIVE. |
| 13 | Is Import Required Indicator | is_impr_rqd_ind | STRING | X |  |  |  | Báo cáo có import: 1: Có import 0: Không import. | SCMS.BM_BAO_CAO |  |  |
| 14 | Is Self Period Setting Indicator | is_self_prd_setting_ind | STRING | X |  |  |  | Báo cáo do cán bộ UB tự thiết lập kỳ: 1: Có 0: Không. | SCMS.BM_BAO_CAO |  |  |
| 15 | Is Public Disclosure Indicator | is_pblc_dscl_ind | STRING | X |  |  |  | Cho phép CBTT: 0: Không CBTT 1: Có CBTT. | SCMS.BM_BAO_CAO |  |  |
| 16 | Description | dsc | STRING | X |  |  |  | Mô tả biểu mẫu. | SCMS.BM_BAO_CAO | MO_TA |  |
| 17 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | SCMS.BM_BAO_CAO |  |  |
| 18 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.BM_BAO_CAO | NGAY_TAO |  |
| 19 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. | SCMS.BM_BAO_CAO | NGAY_CAP_NHAT |  |
| 20 | Function Category Id | fcn_cgy_id | BIGINT | X |  | F |  | FK đến danh mục chức năng (QT_CHUC_NANG). Nullable. | SCMS.BM_BAO_CAO | QT_CHUC_NANG_ID |  |
| 21 | Function Category Code | fcn_cgy_code | STRING | X |  |  |  | Mã danh mục chức năng. | SCMS.BM_BAO_CAO | QT_CHUC_NANG_ID |  |
| 22 | Report Direction Type Code | rpt_drc_tp_code | STRING | X |  |  |  | Chiều báo cáo: 0-Đầu vào; 1-Đầu ra. | SCMS.BM_BAO_CAO | LOAI_BAO_CAO | Scheme: SCMS_REPORT_DIRECTION_TYPE. |
| 23 | Version Date | vrsn_dt | DATE | X |  |  |  | Ngày thay đổi phiên bản. | SCMS.BM_BAO_CAO | NGAY_PHIEN_BAN |  |
| 24 | Is Active Flag | is_actv_f | BOOLEAN | X |  |  |  | Trạng thái sử dụng: 1-Sử dụng; 0-Không sử dụng. | SCMS.BM_BAO_CAO | SU_DUNG |  |
| 25 | Is Summary Required Indicator | is_smy_rqd_ind | STRING | X |  |  |  | Yêu cầu nhập trích yếu: 0-Không bắt buộc; 1-Bắt buộc. | SCMS.BM_BAO_CAO | TRICH_YEU |  |
| 26 | Attachment File | attachment_file | STRING | X |  |  |  | Tệp đính kèm mẫu báo cáo. | SCMS.BM_BAO_CAO | TEP_DINH_KEM |  |


#### 2.{IDX}.8.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Report Template Id | rpt_tpl_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.9 Bảng Involved Party Postal Address — SCMS.CTCK_THONG_TIN

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán. | SCMS.CTCK_THONG_TIN | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.CTCK_THONG_TIN | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_THONG_TIN' | Mã nguồn dữ liệu. | SCMS.CTCK_THONG_TIN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. | SCMS.CTCK_THONG_TIN |  | Scheme: IP_ADDR_TYPE. ETL-derived: hardcode HEAD_OFFICE. |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở chính. | SCMS.CTCK_THONG_TIN | DIA_CHI |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | SCMS.CTCK_THONG_TIN | TINH_THANH_ID |  |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành phố trụ sở. | SCMS.CTCK_THONG_TIN | TINH_THANH_ID |  |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. | SCMS.CTCK_THONG_TIN | QUAN_HUYEN |  |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. | SCMS.CTCK_THONG_TIN | PHUONG_XA |  |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | SCMS.CTCK_THONG_TIN |  |  |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | SCMS.CTCK_THONG_TIN |  |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | SCMS.CTCK_THONG_TIN |  |  |


#### 2.{IDX}.9.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Company | Securities Company Id | scr_co_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.10 Bảng Involved Party Electronic Address — SCMS.CTCK_THONG_TIN

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán. | SCMS.CTCK_THONG_TIN | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.CTCK_THONG_TIN | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_THONG_TIN' | Mã nguồn dữ liệu. | SCMS.CTCK_THONG_TIN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. | SCMS.CTCK_THONG_TIN |  | Scheme: IP_ELEC_ADDR_TYPE. ETL-derived. |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Email. | SCMS.CTCK_THONG_TIN | EMAIL |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán. | SCMS.CTCK_THONG_TIN | ID |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.CTCK_THONG_TIN | ID |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_THONG_TIN' | Mã nguồn dữ liệu. | SCMS.CTCK_THONG_TIN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. | SCMS.CTCK_THONG_TIN |  | Scheme: IP_ELEC_ADDR_TYPE. ETL-derived. |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số fax. | SCMS.CTCK_THONG_TIN | FAX |  |
| 11 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán. | SCMS.CTCK_THONG_TIN | ID |  |
| 12 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.CTCK_THONG_TIN | ID |  |
| 13 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_THONG_TIN' | Mã nguồn dữ liệu. | SCMS.CTCK_THONG_TIN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 14 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. | SCMS.CTCK_THONG_TIN |  | Scheme: IP_ELEC_ADDR_TYPE. ETL-derived. |
| 15 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | SCMS.CTCK_THONG_TIN | DIEN_THOAI |  |
| 16 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán. | SCMS.CTCK_THONG_TIN | ID |  |
| 17 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.CTCK_THONG_TIN | ID |  |
| 18 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_THONG_TIN' | Mã nguồn dữ liệu. | SCMS.CTCK_THONG_TIN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 19 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. | SCMS.CTCK_THONG_TIN |  | Scheme: IP_ELEC_ADDR_TYPE. ETL-derived: hardcode WEBSITE. |
| 20 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Địa chỉ website. | SCMS.CTCK_THONG_TIN | WEBSITE |  |


#### 2.{IDX}.10.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Company | Securities Company Id | scr_co_id |




### 2.{IDX}.11 Bảng Securities Company Organization Unit — SCMS.CTCK_CHI_NHANH

- **Mô tả:** Đơn vị trực thuộc CTCK: chi nhánh, văn phòng đại diện, phòng giao dịch. Cấu trúc self-join qua parent_org_unit_id.
- **Tên vật lý:** scr_co_ou
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Securities Company Organization Unit Id | scr_co_ou_id | BIGINT |  | X | P |  | Khóa đại diện cho đơn vị trực thuộc CTCK. | SCMS.CTCK_CHI_NHANH |  | PK surrogate. |
| 2 | Securities Company Organization Unit Code | scr_co_ou_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.CTCK_CHI_NHANH | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CHI_NHANH' | Mã nguồn dữ liệu. | SCMS.CTCK_CHI_NHANH |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Organization Unit Type Code | ou_tp_code | STRING |  |  |  | 'BRANCH' | Loại đơn vị trực thuộc: BRANCH — chi nhánh. | SCMS.CTCK_CHI_NHANH |  | Scheme: SCMS_ORG_UNIT_TYPE. ETL-derived: hardcode BRANCH cho bảng này. |
| 5 | Securities Company Id | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán. | SCMS.CTCK_CHI_NHANH | CTCK_THONG_TIN_ID |  |
| 6 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.CTCK_CHI_NHANH | CTCK_THONG_TIN_ID |  |
| 7 | Organization Unit Name | ou_nm | STRING | X |  |  |  | Tên đầy đủ chi nhánh. | SCMS.CTCK_CHI_NHANH | TEN_DAY_DU |  |
| 8 | Decision Number | dcsn_nbr | STRING | X |  |  |  | Số quyết định thành lập/hoạt động. | SCMS.CTCK_CHI_NHANH | SO_QUYET_DINH |  |
| 9 | Decision Date | dcsn_dt | DATE | X |  |  |  | Ngày quyết định. | SCMS.CTCK_CHI_NHANH | NGAY_QUYET_DINH |  |
| 10 | Valid Document Date | vld_doc_dt | DATE | X |  |  |  | Ngày hồ sơ hợp lệ. | SCMS.CTCK_CHI_NHANH | NGAY_HS_HOP_LE |  |
| 11 | Director Name | director_nm | STRING | X |  |  |  | Giám đốc chi nhánh. | SCMS.CTCK_CHI_NHANH | GIAM_DOC |  |
| 12 | Business Sector Name | bsn_sctr_nm | STRING | X |  |  |  | Ngành nghề kinh doanh. | SCMS.CTCK_CHI_NHANH | NGANH_NGHE_KINH_DOANH |  |
| 13 | Organization Unit Status Code | ou_st_code | STRING | X |  |  |  | Trạng thái chi nhánh. | SCMS.CTCK_CHI_NHANH | TRANG_THAI_CHI_NHANH | Scheme: SCMS_ORG_UNIT_STATUS. |
| 14 | Note | note | STRING | X |  |  |  | Ghi chú. | SCMS.CTCK_CHI_NHANH | GHI_CHU |  |
| 15 | Is Draft Indicator | is_drft_ind | STRING | X |  |  |  | Cờ bảng tạm: 1-Bảng tạm; 0-Chính thức. | SCMS.CTCK_CHI_NHANH | IS_BANG_TAM |  |
| 16 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.CTCK_CHI_NHANH | NGAY_TAO |  |
| 17 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. | SCMS.CTCK_CHI_NHANH | NGAY_CAP_NHAT |  |
| 18 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái bản ghi chung. | SCMS.CTCK_CHI_NHANH | TRANG_THAI | Scheme: LIFE_CYCLE_STATUS. Cần profile data để xác định giá trị. |
| 19 | Parent Organization Unit Id | prn_ou_id | BIGINT | X |  | F |  | FK đến chi nhánh quản lý (cấp cha). | SCMS.CTCK_CHI_NHANH |  |  |
| 20 | Parent Organization Unit Code | prn_ou_code | STRING | X |  |  |  | Mã chi nhánh quản lý. | SCMS.CTCK_CHI_NHANH |  |  |
| 21 | Representative Name | representative_nm | STRING | X |  |  |  | Người đại diện phòng giao dịch. | SCMS.CTCK_CHI_NHANH |  |  |


#### 2.{IDX}.11.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Securities Company Organization Unit Id | scr_co_ou_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |
| Parent Organization Unit Id | prn_ou_id | Securities Company Organization Unit | Securities Company Organization Unit Id | scr_co_ou_id |




### 2.{IDX}.12 Bảng Involved Party Postal Address — SCMS.CTCK_CHI_NHANH

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến đơn vị trực thuộc CTCK. | SCMS.CTCK_CHI_NHANH | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã đơn vị trực thuộc. | SCMS.CTCK_CHI_NHANH | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CHI_NHANH' | Mã nguồn dữ liệu. | SCMS.CTCK_CHI_NHANH |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. | SCMS.CTCK_CHI_NHANH |  | Scheme: IP_ADDR_TYPE. ETL-derived: hardcode HEAD_OFFICE. |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ chi nhánh. | SCMS.CTCK_CHI_NHANH | DIA_CHI |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | SCMS.CTCK_CHI_NHANH |  |  |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). | SCMS.CTCK_CHI_NHANH |  |  |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện. | SCMS.CTCK_CHI_NHANH | QUAN_HUYEN |  |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã. | SCMS.CTCK_CHI_NHANH | PHUONG_XA |  |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | SCMS.CTCK_CHI_NHANH | TINH_THANH_ID |  |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | SCMS.CTCK_CHI_NHANH | TINH_THANH_ID |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | SCMS.CTCK_CHI_NHANH |  |  |


#### 2.{IDX}.12.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Company Organization Unit | Securities Company Organization Unit Id | scr_co_ou_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.13 Bảng Involved Party Electronic Address — SCMS.CTCK_CHI_NHANH

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến đơn vị trực thuộc CTCK. | SCMS.CTCK_CHI_NHANH | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã đơn vị trực thuộc. | SCMS.CTCK_CHI_NHANH | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CHI_NHANH' | Mã nguồn dữ liệu. | SCMS.CTCK_CHI_NHANH |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. | SCMS.CTCK_CHI_NHANH |  | Scheme: IP_ELEC_ADDR_TYPE. ETL-derived: hardcode FAX. |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số fax. | SCMS.CTCK_CHI_NHANH | FAX |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến đơn vị trực thuộc CTCK. | SCMS.CTCK_CHI_NHANH | ID |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã đơn vị trực thuộc. | SCMS.CTCK_CHI_NHANH | ID |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CHI_NHANH' | Mã nguồn dữ liệu. | SCMS.CTCK_CHI_NHANH |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. | SCMS.CTCK_CHI_NHANH |  | Scheme: IP_ELEC_ADDR_TYPE. ETL-derived: hardcode PHONE. |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | SCMS.CTCK_CHI_NHANH | DIEN_THOAI |  |


#### 2.{IDX}.13.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Company Organization Unit | Securities Company Organization Unit Id | scr_co_ou_id |




### 2.{IDX}.14 Bảng Securities Company Organization Unit — SCMS.CTCK_VP_DAI_DIEN

- **Mô tả:** Đơn vị trực thuộc CTCK: chi nhánh, văn phòng đại diện, phòng giao dịch. Cấu trúc self-join qua parent_org_unit_id.
- **Tên vật lý:** scr_co_ou
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Securities Company Organization Unit Id | scr_co_ou_id | BIGINT |  | X | P |  | Khóa đại diện cho đơn vị trực thuộc CTCK. | SCMS.CTCK_VP_DAI_DIEN |  | PK surrogate. |
| 2 | Securities Company Organization Unit Code | scr_co_ou_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.CTCK_VP_DAI_DIEN | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_VP_DAI_DIEN' | Mã nguồn dữ liệu. | SCMS.CTCK_VP_DAI_DIEN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Organization Unit Type Code | ou_tp_code | STRING |  |  |  | 'REPRESENTATIVE_OFFICE' | Loại đơn vị trực thuộc: REPRESENTATIVE_OFFICE — văn phòng đại diện. | SCMS.CTCK_VP_DAI_DIEN |  | Scheme: SCMS_ORG_UNIT_TYPE. ETL-derived: hardcode REPRESENTATIVE_OFFICE cho bảng này. |
| 5 | Securities Company Id | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán. | SCMS.CTCK_VP_DAI_DIEN | CTCK_THONG_TIN_ID |  |
| 6 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.CTCK_VP_DAI_DIEN | CTCK_THONG_TIN_ID |  |
| 7 | Organization Unit Name | ou_nm | STRING | X |  |  |  | Tên đầy đủ văn phòng đại diện. | SCMS.CTCK_VP_DAI_DIEN | TEN_DAY_DU |  |
| 8 | Decision Number | dcsn_nbr | STRING | X |  |  |  | Số quyết định thành lập/hoạt động. | SCMS.CTCK_VP_DAI_DIEN | SO_QUYET_DINH |  |
| 9 | Decision Date | dcsn_dt | DATE | X |  |  |  | Ngày quyết định. | SCMS.CTCK_VP_DAI_DIEN | NGAY_QUYET_DINH |  |
| 10 | Valid Document Date | vld_doc_dt | DATE | X |  |  |  | Ngày hồ sơ hợp lệ. | SCMS.CTCK_VP_DAI_DIEN | NGAY_HS_HOP_LE |  |
| 11 | Director Name | director_nm | STRING | X |  |  |  | Giám đốc chi nhánh. | SCMS.CTCK_VP_DAI_DIEN |  |  |
| 12 | Business Sector Name | bsn_sctr_nm | STRING | X |  |  |  | Ngành nghề kinh doanh. | SCMS.CTCK_VP_DAI_DIEN |  |  |
| 13 | Organization Unit Status Code | ou_st_code | STRING | X |  |  |  | Trạng thái văn phòng đại diện. | SCMS.CTCK_VP_DAI_DIEN | TRANG_THAI_VPDD | Scheme: SCMS_ORG_UNIT_STATUS. |
| 14 | Note | note | STRING | X |  |  |  | Ghi chú. | SCMS.CTCK_VP_DAI_DIEN | GHI_CHU |  |
| 15 | Is Draft Indicator | is_drft_ind | STRING | X |  |  |  | Cờ bảng tạm: 1-Bảng tạm; 0-Chính thức. | SCMS.CTCK_VP_DAI_DIEN | IS_BANG_TAM |  |
| 16 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.CTCK_VP_DAI_DIEN | NGAY_TAO |  |
| 17 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. | SCMS.CTCK_VP_DAI_DIEN | NGAY_CAP_NHAT |  |
| 18 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái bản ghi chung. | SCMS.CTCK_VP_DAI_DIEN | TRANG_THAI | Scheme: LIFE_CYCLE_STATUS. Cần profile data để xác định giá trị. |
| 19 | Parent Organization Unit Id | prn_ou_id | BIGINT | X |  | F |  | FK đến chi nhánh quản lý (cấp cha). | SCMS.CTCK_VP_DAI_DIEN | CTCK_CHI_NHANH_ID |  |
| 20 | Parent Organization Unit Code | prn_ou_code | STRING | X |  |  |  | Mã chi nhánh quản lý. | SCMS.CTCK_VP_DAI_DIEN | CTCK_CHI_NHANH_ID |  |
| 21 | Representative Name | representative_nm | STRING | X |  |  |  | Người đại diện văn phòng. | SCMS.CTCK_VP_DAI_DIEN | NGUOI_DAI_DIEN |  |


#### 2.{IDX}.14.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Securities Company Organization Unit Id | scr_co_ou_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |
| Parent Organization Unit Id | prn_ou_id | Securities Company Organization Unit | Securities Company Organization Unit Id | scr_co_ou_id |




### 2.{IDX}.15 Bảng Securities Company Organization Unit — SCMS.CTCK_PHONG_GIAO_DICH

- **Mô tả:** Đơn vị trực thuộc CTCK: chi nhánh, văn phòng đại diện, phòng giao dịch. Cấu trúc self-join qua parent_org_unit_id.
- **Tên vật lý:** scr_co_ou
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Securities Company Organization Unit Id | scr_co_ou_id | BIGINT |  | X | P |  | Khóa đại diện cho đơn vị trực thuộc CTCK. | SCMS.CTCK_PHONG_GIAO_DICH |  | PK surrogate. |
| 2 | Securities Company Organization Unit Code | scr_co_ou_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.CTCK_PHONG_GIAO_DICH | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_PHONG_GIAO_DICH' | Mã nguồn dữ liệu. | SCMS.CTCK_PHONG_GIAO_DICH |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Organization Unit Type Code | ou_tp_code | STRING |  |  |  | 'TRANSACTION_OFFICE' | Loại đơn vị trực thuộc: TRANSACTION_OFFICE — phòng giao dịch. | SCMS.CTCK_PHONG_GIAO_DICH |  | Scheme: SCMS_ORG_UNIT_TYPE. ETL-derived: hardcode TRANSACTION_OFFICE cho bảng này. |
| 5 | Securities Company Id | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán. | SCMS.CTCK_PHONG_GIAO_DICH | CTCK_THONG_TIN_ID |  |
| 6 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.CTCK_PHONG_GIAO_DICH | CTCK_THONG_TIN_ID |  |
| 7 | Organization Unit Name | ou_nm | STRING | X |  |  |  | Tên đầy đủ phòng giao dịch. | SCMS.CTCK_PHONG_GIAO_DICH | TEN_DAY_DU |  |
| 8 | Decision Number | dcsn_nbr | STRING | X |  |  |  | Số quyết định thành lập/hoạt động. | SCMS.CTCK_PHONG_GIAO_DICH | SO_QUYET_DINH |  |
| 9 | Decision Date | dcsn_dt | DATE | X |  |  |  | Ngày quyết định. | SCMS.CTCK_PHONG_GIAO_DICH | NGAY_QUYET_DINH |  |
| 10 | Valid Document Date | vld_doc_dt | DATE | X |  |  |  | Ngày hồ sơ hợp lệ. | SCMS.CTCK_PHONG_GIAO_DICH | NGAY_HS_HOP_LE |  |
| 11 | Director Name | director_nm | STRING | X |  |  |  | Giám đốc chi nhánh. | SCMS.CTCK_PHONG_GIAO_DICH |  |  |
| 12 | Business Sector Name | bsn_sctr_nm | STRING | X |  |  |  | Ngành nghề kinh doanh. | SCMS.CTCK_PHONG_GIAO_DICH |  |  |
| 13 | Organization Unit Status Code | ou_st_code | STRING | X |  |  |  | Trạng thái phòng giao dịch. | SCMS.CTCK_PHONG_GIAO_DICH | TRANG_THAI_PGD | Scheme: SCMS_ORG_UNIT_STATUS. |
| 14 | Note | note | STRING | X |  |  |  | Ghi chú. | SCMS.CTCK_PHONG_GIAO_DICH | GHI_CHU |  |
| 15 | Is Draft Indicator | is_drft_ind | STRING | X |  |  |  | Cờ bảng tạm: 1-Bảng tạm; 0-Chính thức. | SCMS.CTCK_PHONG_GIAO_DICH | IS_BANG_TAM |  |
| 16 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.CTCK_PHONG_GIAO_DICH | NGAY_TAO |  |
| 17 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. | SCMS.CTCK_PHONG_GIAO_DICH | NGAY_CAP_NHAT |  |
| 18 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái bản ghi chung. | SCMS.CTCK_PHONG_GIAO_DICH | TRANG_THAI | Scheme: LIFE_CYCLE_STATUS. Cần profile data để xác định giá trị. |
| 19 | Parent Organization Unit Id | prn_ou_id | BIGINT | X |  | F |  | FK đến chi nhánh quản lý (cấp cha). | SCMS.CTCK_PHONG_GIAO_DICH | CTCK_CHI_NHANH_ID |  |
| 20 | Parent Organization Unit Code | prn_ou_code | STRING | X |  |  |  | Mã chi nhánh quản lý. | SCMS.CTCK_PHONG_GIAO_DICH | CTCK_CHI_NHANH_ID |  |
| 21 | Representative Name | representative_nm | STRING | X |  |  |  | Người đại diện phòng giao dịch. | SCMS.CTCK_PHONG_GIAO_DICH | NGUOI_DAI_DIEN |  |


#### 2.{IDX}.15.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Securities Company Organization Unit Id | scr_co_ou_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |
| Parent Organization Unit Id | prn_ou_id | Securities Company Organization Unit | Securities Company Organization Unit Id | scr_co_ou_id |




### 2.{IDX}.16 Bảng Securities Practitioner

- **Mô tả:** Người hành nghề chứng khoán được UBCKNN cấp phép. Ghi nhận thông tin cá nhân và trạng thái hành nghề. Attribute chi tiết (BirthDate full
- **Tên vật lý:** scr_practitioner
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Practitioner Id | practitioner_id | BIGINT |  | X | P |  | Khóa đại diện cho người hành nghề chứng khoán. | SCMS.CTCK_NGUOI_HANH_NGHE_CK |  | PK surrogate. Shared entity với NHNCK.Professionals. |
| 2 | Practitioner Code | practitioner_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.CTCK_NGUOI_HANH_NGHE_CK | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_NGUOI_HANH_NGHE_CK' | Mã nguồn dữ liệu. | SCMS.CTCK_NGUOI_HANH_NGHE_CK |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Full Name | full_nm | STRING | X |  |  |  | Họ và tên người hành nghề. | SCMS.CTCK_NGUOI_HANH_NGHE_CK | HO_TEN |  |
| 5 | Birth Year | brth_yr | STRING | X |  |  |  | Năm sinh | SCMS.CTCK_NGUOI_HANH_NGHE_CK |  |  |
| 6 | Date Of Birth | dob | DATE | X |  |  |  | Ngày sinh. | SCMS.CTCK_NGUOI_HANH_NGHE_CK | NGAY_SINH |  |
| 7 | Individual Gender Code | idv_gnd_code | STRING | X |  |  |  | Giới tính | SCMS.CTCK_NGUOI_HANH_NGHE_CK |  | Scheme: INDIVIDUAL_GENDER. Lấy từ bản mới nhất ProfessionalHistories. |
| 8 | Nationality Code | nationality_code | STRING | X |  |  |  | Quốc tịch | SCMS.CTCK_NGUOI_HANH_NGHE_CK |  | Scheme: NATIONALITY. Lấy từ bản mới nhất ProfessionalHistories. Thay thế Country Code từ Professionals.CountryId (cùng ngữ nghĩa quốc tịch). |
| 9 | Education Level Code | ed_lvl_code | STRING | X |  |  |  | Trình độ học vấn | SCMS.CTCK_NGUOI_HANH_NGHE_CK |  | Scheme: EDUCATION_LEVEL. Lấy từ bản mới nhất ProfessionalHistories. Professionals không có trường này. |
| 10 | Birth Place | brth_plc | STRING | X |  |  |  | Nơi sinh | SCMS.CTCK_NGUOI_HANH_NGHE_CK |  |  |
| 11 | Practitioner Registration Type Code | practitioner_rgst_tp_code | STRING | X |  |  |  | Hình thức đăng ký người hành nghề vào hệ thống | SCMS.CTCK_NGUOI_HANH_NGHE_CK |  | Scheme: PRACTITIONER_REGISTRATION_TYPE. Lấy từ bản mới nhất ProfessionalHistories. Khác với Applications.RegistrationType (loại đăng ký hồ sơ CCHN). |
| 12 | Practice Status Code | practice_st_code | STRING | X |  |  |  | Trạng thái hành nghề | SCMS.CTCK_NGUOI_HANH_NGHE_CK |  | Scheme: PRACTICE_STATUS. Lấy từ bản mới nhất ProfessionalHistories. 5 giá trị: 0=Chưa hành nghề; 1=Hành nghề; 2=Thu hồi cho cấp lại; 3=Thu hồi không cấp lại; 4=Hành nghề có thời hạn. |
| 13 | Country of Residence Geographic Area Id | cty_of_rsdnc_geo_id | BIGINT | X |  | F |  | FK đến quốc gia cư trú. | SCMS.CTCK_NGUOI_HANH_NGHE_CK |  |  |
| 14 | Country of Residence Geographic Area Code | cty_of_rsdnc_geo_code | STRING | X |  |  |  | Mã quốc gia cư trú. | SCMS.CTCK_NGUOI_HANH_NGHE_CK |  |  |
| 15 | Identity Reference Code | identity_refr_code | STRING | X |  |  |  | Mã định danh giấy tờ tùy thân (FK bảng identity riêng) | SCMS.CTCK_NGUOI_HANH_NGHE_CK |  |  |
| 16 | Relationship Type Code | rltnp_tp_code | STRING | X |  |  |  | Loại quan hệ người hành nghề | SCMS.CTCK_NGUOI_HANH_NGHE_CK |  | Scheme: PRACTITIONER_RELATIONSHIP_TYPE. |
| 17 | Occupation Name | ocp_nm | STRING | X |  |  |  | Nghề nghiệp | SCMS.CTCK_NGUOI_HANH_NGHE_CK |  |  |
| 18 | Workplace Name | workplace_nm | STRING | X |  |  |  | Nơi làm việc | SCMS.CTCK_NGUOI_HANH_NGHE_CK |  |  |
| 19 | Practitioner Note | practitioner_note | STRING | X |  |  |  | Ghi chú | SCMS.CTCK_NGUOI_HANH_NGHE_CK |  |  |
| 20 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.CTCK_NGUOI_HANH_NGHE_CK | NGAY_TAO |  |
| 21 | Securities Company Id | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán nơi hành nghề. | SCMS.CTCK_NGUOI_HANH_NGHE_CK | CTCK_THONG_TIN_ID |  |
| 22 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.CTCK_NGUOI_HANH_NGHE_CK | CTCK_THONG_TIN_ID |  |
| 23 | Employee Code | empe_code | STRING | X |  |  |  | Mã nhân viên nội bộ CTCK. | SCMS.CTCK_NGUOI_HANH_NGHE_CK | MA_NHAN_VIEN |  |
| 24 | License Number | license_nbr | STRING | X |  |  |  | Số chứng chỉ hành nghề chứng khoán. | SCMS.CTCK_NGUOI_HANH_NGHE_CK | SO_CHUNG_CHI_HNCK |  |
| 25 | Employment Start Date | emp_strt_dt | DATE | X |  |  |  | Ngày bắt đầu làm việc tại CTCK. | SCMS.CTCK_NGUOI_HANH_NGHE_CK | NGAY_BAT_DAU_LAM |  |
| 26 | Employment End Date | emp_end_dt | DATE | X |  |  |  | Ngày nghỉ việc. | SCMS.CTCK_NGUOI_HANH_NGHE_CK | NGAY_NGHI_VIEC |  |
| 27 | Note | note | STRING | X |  |  |  | Ghi chú. | SCMS.CTCK_NGUOI_HANH_NGHE_CK | GHI_CHU |  |
| 28 | Practitioner Status Code | practitioner_st_code | STRING | X |  |  |  | Trạng thái người hành nghề tại CTCK. | SCMS.CTCK_NGUOI_HANH_NGHE_CK | TRANG_THAI | Scheme: SCMS_COMPANY_STATUS. |


#### 2.{IDX}.16.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Practitioner Id | practitioner_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Country of Residence Geographic Area Id | cty_of_rsdnc_geo_id | Geographic Area | Geographic Area Id | geo_id |
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |




### 2.{IDX}.17 Bảng Involved Party Alternative Identification — SCMS.CTCK_NGUOI_HANH_NGHE_CK

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến người hành nghề chứng khoán. | SCMS.CTCK_NGUOI_HANH_NGHE_CK | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người hành nghề chứng khoán. | SCMS.CTCK_NGUOI_HANH_NGHE_CK | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_NGUOI_HANH_NGHE_CK' | Mã nguồn dữ liệu. | SCMS.CTCK_NGUOI_HANH_NGHE_CK |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'NATIONAL_ID' | Loại định danh — giấy tờ tùy thân. | SCMS.CTCK_NGUOI_HANH_NGHE_CK |  | Scheme: IP_ALT_ID_TYPE. ETL-derived: hardcode NATIONAL_ID. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số giấy tờ tùy thân. | SCMS.CTCK_NGUOI_HANH_NGHE_CK | SO_GIAY_TO |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp CMND/CCCD. | SCMS.CTCK_NGUOI_HANH_NGHE_CK |  |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp CMND/CCCD. | SCMS.CTCK_NGUOI_HANH_NGHE_CK |  |  |


#### 2.{IDX}.17.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Practitioner | Practitioner Id |  |




### 2.{IDX}.18 Bảng Securities Company Senior Personnel

- **Mô tả:** Nhân sự cao cấp của CTCK (Chủ tịch HĐQT, Tổng Giám đốc, Kế toán trưởng...). Ghi nhận chức vụ và thời gian đảm nhận.
- **Tên vật lý:** scr_co_snr_psn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Securities Company Senior Personnel Id | scr_co_snr_psn_id | BIGINT |  | X | P |  | Khóa đại diện cho nhân sự cao cấp CTCK. | SCMS.CTCK_NHAN_SU_CAO_CAP |  | PK surrogate. |
| 2 | Securities Company Senior Personnel Code | scr_co_snr_psn_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.CTCK_NHAN_SU_CAO_CAP | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_NHAN_SU_CAO_CAP' | Mã nguồn dữ liệu. | SCMS.CTCK_NHAN_SU_CAO_CAP |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Securities Company Id | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán. | SCMS.CTCK_NHAN_SU_CAO_CAP | CTCK_THONG_TIN_ID |  |
| 5 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.CTCK_NHAN_SU_CAO_CAP | CTCK_THONG_TIN_ID |  |
| 6 | Organization Unit Id | ou_id | BIGINT | X |  | F |  | FK đến chi nhánh trực thuộc (nếu có). | SCMS.CTCK_NHAN_SU_CAO_CAP | CTCK_CHI_NHANH_ID |  |
| 7 | Organization Unit Code | ou_code | STRING | X |  |  |  | Mã chi nhánh trực thuộc. | SCMS.CTCK_NHAN_SU_CAO_CAP | CTCK_CHI_NHANH_ID |  |
| 8 | Full Name | full_nm | STRING | X |  |  |  | Họ và tên nhân sự cao cấp. | SCMS.CTCK_NHAN_SU_CAO_CAP | HO_TEN |  |
| 9 | Individual Gender Code | idv_gnd_code | STRING | X |  |  |  | Giới tính. | SCMS.CTCK_NHAN_SU_CAO_CAP | GIOI_TINH | Scheme: INDIVIDUAL_GENDER. |
| 10 | Date Of Birth | dob | DATE | X |  |  |  | Ngày sinh. | SCMS.CTCK_NHAN_SU_CAO_CAP | NGAY_SINH |  |
| 11 | Birth Place | brth_plc | STRING | X |  |  |  | Nơi sinh. | SCMS.CTCK_NHAN_SU_CAO_CAP | NOI_SINH |  |
| 12 | Nationality Id | nationality_id | BIGINT | X |  | F |  | FK đến quốc tịch nhân sự. | SCMS.CTCK_NHAN_SU_CAO_CAP | DM_QUOC_TICH_ID |  |
| 13 | Nationality Code | nationality_code | STRING | X |  |  |  | Mã quốc tịch nhân sự. | SCMS.CTCK_NHAN_SU_CAO_CAP | DM_QUOC_TICH_ID |  |
| 14 | Position Type Code | pos_tp_code | STRING | X |  | F |  | Chức vụ đảm nhận. | SCMS.CTCK_NHAN_SU_CAO_CAP | CHUC_VU_ID | Scheme: SCMS_POSITION_TYPE. FK đến bảng danh mục DM_CHUC_VU — lưu dạng Classification Value. |
| 15 | Shareholder Type Code | shrhlr_tp_code | STRING | X |  |  |  | Loại cổ đông nếu đồng thời là cổ đông. | SCMS.CTCK_NHAN_SU_CAO_CAP | LOAI_CO_DONG | Scheme: SCMS_SHAREHOLDER_RELATION_TYPE. Ghi nhận khi nhân sự cao cấp đồng thời là cổ đông. |
| 16 | Resignation Date | resignation_dt | DATE | X |  |  |  | Ngày thôi việc. | SCMS.CTCK_NHAN_SU_CAO_CAP | NGAY_THOI_VIEC |  |
| 17 | Note | note | STRING | X |  |  |  | Ghi chú. | SCMS.CTCK_NHAN_SU_CAO_CAP | GHI_CHU |  |
| 18 | Personnel Status Code | psn_st_code | STRING | X |  |  |  | Trạng thái nhân sự. | SCMS.CTCK_NHAN_SU_CAO_CAP | TRANG_THAI_NHAN_SU | Scheme: SCMS_PERSONNEL_STATUS. |
| 19 | Is Draft Indicator | is_drft_ind | STRING | X |  |  |  | Cờ bảng tạm: 0-Bảng tạm; 1-Chính thức. | SCMS.CTCK_NHAN_SU_CAO_CAP | IS_BANG_TAM |  |
| 20 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.CTCK_NHAN_SU_CAO_CAP | NGAY_TAO |  |
| 21 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. | SCMS.CTCK_NHAN_SU_CAO_CAP | NGAY_CAP_NHAT |  |
| 22 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái bản ghi chung. | SCMS.CTCK_NHAN_SU_CAO_CAP | TRANG_THAI | Scheme: LIFE_CYCLE_STATUS. Cần profile data để xác định giá trị. |


#### 2.{IDX}.18.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Securities Company Senior Personnel Id | scr_co_snr_psn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |
| Organization Unit Id | ou_id | Securities Company Organization Unit | Securities Company Organization Unit Id | scr_co_ou_id |
| Nationality Id | nationality_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.19 Bảng Involved Party Postal Address — SCMS.CTCK_NHAN_SU_CAO_CAP

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến nhân sự cao cấp CTCK. | SCMS.CTCK_NHAN_SU_CAO_CAP | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã nhân sự cao cấp. | SCMS.CTCK_NHAN_SU_CAO_CAP | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_NHAN_SU_CAO_CAP' | Mã nguồn dữ liệu. | SCMS.CTCK_NHAN_SU_CAO_CAP |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  | 'PERMANENT' | Loại địa chỉ — thường trú. | SCMS.CTCK_NHAN_SU_CAO_CAP |  | Scheme: IP_ADDR_TYPE. ETL-derived: hardcode PERMANENT. |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ thường trú. | SCMS.CTCK_NHAN_SU_CAO_CAP | DIA_CHI |  |
| 6 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | SCMS.CTCK_NHAN_SU_CAO_CAP |  |  |


#### 2.{IDX}.19.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Company Senior Personnel | Securities Company Senior Personnel Id | scr_co_snr_psn_id |




### 2.{IDX}.20 Bảng Involved Party Electronic Address — SCMS.CTCK_NHAN_SU_CAO_CAP

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến nhân sự cao cấp CTCK. | SCMS.CTCK_NHAN_SU_CAO_CAP | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã nhân sự cao cấp. | SCMS.CTCK_NHAN_SU_CAO_CAP | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_NHAN_SU_CAO_CAP' | Mã nguồn dữ liệu. | SCMS.CTCK_NHAN_SU_CAO_CAP |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. | SCMS.CTCK_NHAN_SU_CAO_CAP |  | Scheme: IP_ELEC_ADDR_TYPE. ETL-derived: hardcode EMAIL. |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Địa chỉ email. | SCMS.CTCK_NHAN_SU_CAO_CAP | EMAIL |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến nhân sự cao cấp CTCK. | SCMS.CTCK_NHAN_SU_CAO_CAP | ID |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã nhân sự cao cấp. | SCMS.CTCK_NHAN_SU_CAO_CAP | ID |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_NHAN_SU_CAO_CAP' | Mã nguồn dữ liệu. | SCMS.CTCK_NHAN_SU_CAO_CAP |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'EMAIL_DISCLOSURE' | Loại kênh liên lạc — email công bố thông tin. | SCMS.CTCK_NHAN_SU_CAO_CAP |  | Scheme: IP_ELEC_ADDR_TYPE. ETL-derived: hardcode EMAIL_DISCLOSURE. |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Email dùng riêng cho công bố thông tin. | SCMS.CTCK_NHAN_SU_CAO_CAP | EMAIL_CONG_BO_TT |  |
| 11 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến nhân sự cao cấp CTCK. | SCMS.CTCK_NHAN_SU_CAO_CAP | ID |  |
| 12 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã nhân sự cao cấp. | SCMS.CTCK_NHAN_SU_CAO_CAP | ID |  |
| 13 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_NHAN_SU_CAO_CAP' | Mã nguồn dữ liệu. | SCMS.CTCK_NHAN_SU_CAO_CAP |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 14 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. | SCMS.CTCK_NHAN_SU_CAO_CAP |  | Scheme: IP_ELEC_ADDR_TYPE. ETL-derived: hardcode FAX. |
| 15 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số fax. | SCMS.CTCK_NHAN_SU_CAO_CAP | FAX |  |
| 16 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến nhân sự cao cấp CTCK. | SCMS.CTCK_NHAN_SU_CAO_CAP | ID |  |
| 17 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã nhân sự cao cấp. | SCMS.CTCK_NHAN_SU_CAO_CAP | ID |  |
| 18 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_NHAN_SU_CAO_CAP' | Mã nguồn dữ liệu. | SCMS.CTCK_NHAN_SU_CAO_CAP |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 19 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. | SCMS.CTCK_NHAN_SU_CAO_CAP |  | Scheme: IP_ELEC_ADDR_TYPE. ETL-derived: hardcode PHONE. |
| 20 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | SCMS.CTCK_NHAN_SU_CAO_CAP | DIEN_THOAI |  |


#### 2.{IDX}.20.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Company Senior Personnel | Securities Company Senior Personnel Id | scr_co_snr_psn_id |




### 2.{IDX}.21 Bảng Involved Party Alternative Identification — SCMS.CTCK_NHAN_SU_CAO_CAP

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến nhân sự cao cấp. | SCMS.CTCK_NHAN_SU_CAO_CAP | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã nhân sự cao cấp. | SCMS.CTCK_NHAN_SU_CAO_CAP | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_NHAN_SU_CAO_CAP' | Mã nguồn dữ liệu. | SCMS.CTCK_NHAN_SU_CAO_CAP |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'NATIONAL_ID' | Loại định danh — CMND/CCCD. | SCMS.CTCK_NHAN_SU_CAO_CAP |  | Scheme: IP_ALT_ID_TYPE. ETL-derived: hardcode NATIONAL_ID. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số CMND/CCCD. | SCMS.CTCK_NHAN_SU_CAO_CAP | SO_CMND |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp CMND/CCCD. | SCMS.CTCK_NHAN_SU_CAO_CAP | NGAY_CAP |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp CMND/CCCD. | SCMS.CTCK_NHAN_SU_CAO_CAP | NOI_CAP |  |


#### 2.{IDX}.21.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Company Senior Personnel | Securities Company Senior Personnel Id | scr_co_snr_psn_id |




### 2.{IDX}.22 Bảng Securities Company Shareholder

- **Mô tả:** Cổ đông của CTCK - cá nhân hoặc tổ chức. Ghi nhận tỷ lệ sở hữu và số lượng cổ phần.
- **Tên vật lý:** scr_co_shrhlr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Securities Company Shareholder Id | scr_co_shrhlr_id | BIGINT |  | X | P |  | Khóa đại diện cho cổ đông CTCK. | SCMS.CTCK_CO_DONG |  | PK surrogate. |
| 2 | Securities Company Shareholder Code | scr_co_shrhlr_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.CTCK_CO_DONG | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CO_DONG' | Mã nguồn dữ liệu. | SCMS.CTCK_CO_DONG |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Securities Company Id | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán. | SCMS.CTCK_CO_DONG | CTCK_THONG_TIN_ID |  |
| 5 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.CTCK_CO_DONG | CTCK_THONG_TIN_ID |  |
| 6 | Shareholder Name | shrhlr_nm | STRING | X |  |  |  | Tên cổ đông (cá nhân hoặc tổ chức). | SCMS.CTCK_CO_DONG | TEN_CO_DONG |  |
| 7 | Is Individual Indicator | is_idv_ind | STRING | X |  |  |  | Loại chủ thể: 1-Cá nhân; 0-Tổ chức. | SCMS.CTCK_CO_DONG | IS_CA_NHAN |  |
| 8 | Date Of Birth | dob | DATE | X |  |  |  | Ngày sinh (áp dụng cho cá nhân). | SCMS.CTCK_CO_DONG | NGAY_SINH |  |
| 9 | Birth Place | brth_plc | STRING | X |  |  |  | Nơi sinh. | SCMS.CTCK_CO_DONG | NOI_SINH |  |
| 10 | Nationality Id | nationality_id | BIGINT | X |  | F |  | FK đến quốc tịch cổ đông. | SCMS.CTCK_CO_DONG | QUOC_TICH_ID |  |
| 11 | Nationality Code | nationality_code | STRING | X |  |  |  | Mã quốc tịch cổ đông. | SCMS.CTCK_CO_DONG | QUOC_TICH_ID |  |
| 12 | Is Party Member Indicator | is_p_mbr_ind | STRING | X |  |  |  | Cờ đảng viên: 1-Là đảng viên; 0-Không phải. | SCMS.CTCK_CO_DONG | IS_DANG_VIEN |  |
| 13 | Education Level Name | ed_lvl_nm | STRING | X |  |  |  | Trình độ học vấn. | SCMS.CTCK_CO_DONG | TRINH_DO |  |
| 14 | Occupation Name | ocp_nm | STRING | X |  |  |  | Nghề nghiệp. | SCMS.CTCK_CO_DONG | NGHE_NGHIEP |  |
| 15 | Degree Name | dgr_nm | STRING | X |  |  |  | Bằng cấp. | SCMS.CTCK_CO_DONG | BANG_CAP |  |
| 16 | Is Legal Representative Indicator | is_lgl_representative_ind | STRING | X |  |  |  | Cờ đại diện pháp nhân. | SCMS.CTCK_CO_DONG | IS_DAI_DIEN_PHAP_NHAN |  |
| 17 | Workplace Name | workplace_nm | STRING | X |  |  |  | Nơi làm việc. | SCMS.CTCK_CO_DONG | NOI_LAM_VIEC |  |
| 18 | Job Position Name | job_pos_nm | STRING | X |  |  |  | Vị trí công việc. | SCMS.CTCK_CO_DONG | VI_TRI_CONG_VIEC |  |
| 19 | Is Employee Indicator | is_empe_ind | STRING | X |  |  |  | Cờ nhân viên CTCK: cổ đông đồng thời là nhân viên. | SCMS.CTCK_CO_DONG | IS_NHAN_VIEN_CT |  |
| 20 | Trading Account Number | tdg_ac_nbr | STRING | X |  |  |  | Số tài khoản giao dịch. | SCMS.CTCK_CO_DONG | TAI_KHOAN_GD |  |
| 21 | Shareholder Type Code | shrhlr_tp_code | STRING | X |  |  |  | Loại cổ đông. | SCMS.CTCK_CO_DONG | LOAI_CO_DONG | Scheme: SCMS_SHAREHOLDER_RELATION_TYPE. |
| 22 | Share Quantity | shr_qty | INT | X |  |  |  | Số lượng cổ phần đang nắm giữ. | SCMS.CTCK_CO_DONG | SO_LUONG_NAM_GIU |  |
| 23 | Share Ratio | shr_rto | DECIMAL(9,6) | X |  |  |  | Tỷ lệ sở hữu cổ phần (%). | SCMS.CTCK_CO_DONG | TY_LE_NAM_GIU |  |
| 24 | Significant Shareholder Date | sig_shrhlr_dt | DATE | X |  |  |  | Ngày đạt tỷ lệ sở hữu đáng kể. | SCMS.CTCK_CO_DONG | NGAY_DAT_TLSH |  |
| 25 | Note | note | STRING | X |  |  |  | Ghi chú. | SCMS.CTCK_CO_DONG | GHI_CHU |  |
| 26 | Shareholder Status Code | shrhlr_st_code | STRING | X |  |  |  | Trạng thái cổ đông. | SCMS.CTCK_CO_DONG | TRANG_THAI | Scheme: SCMS_COMPANY_STATUS. |
| 27 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.CTCK_CO_DONG | NGAY_TAO |  |
| 28 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. | SCMS.CTCK_CO_DONG | NGAY_CAP_NHAT |  |


#### 2.{IDX}.22.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Securities Company Shareholder Id | scr_co_shrhlr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |
| Nationality Id | nationality_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.23 Bảng Involved Party Postal Address — SCMS.CTCK_CO_DONG

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến cổ đông CTCK. | SCMS.CTCK_CO_DONG | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã cổ đông. | SCMS.CTCK_CO_DONG | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CO_DONG' | Mã nguồn dữ liệu. | SCMS.CTCK_CO_DONG |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  | 'CURRENT' | Loại địa chỉ — nơi ở hiện tại. | SCMS.CTCK_CO_DONG |  | Scheme: IP_ADDR_TYPE. ETL-derived: hardcode CURRENT. |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ hiện tại. | SCMS.CTCK_CO_DONG | DIA_CHI_HIEN_TAI |  |
| 6 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | SCMS.CTCK_CO_DONG |  |  |
| 7 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến cổ đông CTCK. | SCMS.CTCK_CO_DONG | ID |  |
| 8 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã cổ đông. | SCMS.CTCK_CO_DONG | ID |  |
| 9 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CO_DONG' | Mã nguồn dữ liệu. | SCMS.CTCK_CO_DONG |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 10 | Address Type Code | adr_tp_code | STRING |  |  |  | 'PERMANENT' | Loại địa chỉ — hộ khẩu thường trú. | SCMS.CTCK_CO_DONG |  | Scheme: IP_ADDR_TYPE. ETL-derived: hardcode PERMANENT. |
| 11 | Address Value | adr_val | STRING | X |  |  |  | Hộ khẩu thường trú. | SCMS.CTCK_CO_DONG | HO_KHAU_THUONG_TRU |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | SCMS.CTCK_CO_DONG |  |  |


#### 2.{IDX}.23.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Company Shareholder | Securities Company Shareholder Id | scr_co_shrhlr_id |




### 2.{IDX}.24 Bảng Involved Party Alternative Identification — SCMS.CTCK_CO_DONG

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến cổ đông. | SCMS.CTCK_CO_DONG | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã cổ đông. | SCMS.CTCK_CO_DONG | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CO_DONG' | Mã nguồn dữ liệu. | SCMS.CTCK_CO_DONG |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'NATIONAL_ID' | Loại định danh — CMND/CCCD/đăng ký kinh doanh. | SCMS.CTCK_CO_DONG |  | Scheme: IP_ALT_ID_TYPE. ETL-derived: hardcode NATIONAL_ID (cá nhân) hoặc BUSINESS_LICENSE (tổ chức) — phụ thuộc IS_CA_NHAN. Thiết kế chung 1 row per party. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số CMND/CCCD hoặc đăng ký kinh doanh. | SCMS.CTCK_CO_DONG | SO_CMND |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp. | SCMS.CTCK_CO_DONG | NGAY_CAP |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp. | SCMS.CTCK_CO_DONG | NOI_CAP |  |


#### 2.{IDX}.24.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Company Shareholder | Securities Company Shareholder Id | scr_co_shrhlr_id |




### 2.{IDX}.25 Bảng Audit Firm Practitioner

- **Mô tả:** Kiểm toán viên thuộc công ty kiểm toán. Ghi nhận chứng chỉ kiểm toán và trạng thái hành nghề.
- **Tên vật lý:** audt_firm_practitioner
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Audit Firm Practitioner Id | audt_firm_practitioner_id | BIGINT |  | X | P |  | Khóa đại diện cho kiểm toán viên. | SCMS.CT_KIEM_TOAN_VIEN |  | PK surrogate. |
| 2 | Audit Firm Practitioner Code | audt_firm_practitioner_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.CT_KIEM_TOAN_VIEN | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CT_KIEM_TOAN_VIEN' | Mã nguồn dữ liệu. | SCMS.CT_KIEM_TOAN_VIEN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Audit Firm Id | audt_firm_id | BIGINT |  |  | F |  | FK đến công ty kiểm toán. | SCMS.CT_KIEM_TOAN_VIEN | CT_KIEM_TOAN_ID |  |
| 5 | Audit Firm Code | audt_firm_code | STRING |  |  |  |  | Mã công ty kiểm toán. | SCMS.CT_KIEM_TOAN_VIEN | CT_KIEM_TOAN_ID |  |
| 6 | Full Name | full_nm | STRING | X |  |  |  | Họ và tên kiểm toán viên. | SCMS.CT_KIEM_TOAN_VIEN | HO_TEN |  |
| 7 | Approval Date | aprv_dt | DATE | X |  |  |  | Ngày UBCKNN chấp thuận. | SCMS.CT_KIEM_TOAN_VIEN | NGAY_CHAP_THUAN |  |
| 8 | Revocation Date | revocation_dt | DATE | X |  |  |  | Ngày hủy chấp thuận. | SCMS.CT_KIEM_TOAN_VIEN | NGAY_HUY_CHAP_THUAN |  |
| 9 | Note | note | STRING | X |  |  |  | Ghi chú. | SCMS.CT_KIEM_TOAN_VIEN | GHI_CHU |  |
| 10 | Audit Firm Practitioner Status Code | audt_firm_practitioner_st_code | STRING | X |  |  |  | Trạng thái kiểm toán viên. | SCMS.CT_KIEM_TOAN_VIEN | TRANG_THAI | Scheme: SCMS_AUDIT_FIRM_PRACTITIONER_STATUS. |
| 11 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.CT_KIEM_TOAN_VIEN | NGAY_TAO |  |
| 12 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. | SCMS.CT_KIEM_TOAN_VIEN | NGAY_CAP_NHAT |  |


#### 2.{IDX}.25.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Audit Firm Practitioner Id | audt_firm_practitioner_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Audit Firm Id | audt_firm_id | Audit Firm | Audit Firm Id | audt_firm_id |




### 2.{IDX}.26 Bảng Involved Party Alternative Identification — SCMS.CT_KIEM_TOAN_VIEN

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Audit Firm Practitioner. | SCMS.CT_KIEM_TOAN_VIEN | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã kiểm toán viên. | SCMS.CT_KIEM_TOAN_VIEN | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CT_KIEM_TOAN_VIEN' | Mã nguồn dữ liệu. | SCMS.CT_KIEM_TOAN_VIEN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'PRACTITIONER_LICENSE' | Loại giấy tờ: chứng chỉ hành nghề kiểm toán. | SCMS.CT_KIEM_TOAN_VIEN |  | Scheme: IP_ALT_ID_TYPE. ETL-derived. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số chứng chỉ hành nghề kiểm toán. | SCMS.CT_KIEM_TOAN_VIEN | SO_CHUNG_CHI |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp chứng chỉ hành nghề. | SCMS.CT_KIEM_TOAN_VIEN | NGAY_CAP |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp chứng chỉ hành nghề. | SCMS.CT_KIEM_TOAN_VIEN |  |  |
| 8 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Audit Firm Practitioner. | SCMS.CT_KIEM_TOAN_VIEN | ID |  |
| 9 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã kiểm toán viên. | SCMS.CT_KIEM_TOAN_VIEN | ID |  |
| 10 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CT_KIEM_TOAN_VIEN' | Mã nguồn dữ liệu. | SCMS.CT_KIEM_TOAN_VIEN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 11 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'PRACTITIONER_LICENSE' | Loại giấy tờ: chứng chỉ hành nghề kiểm toán. | SCMS.CT_KIEM_TOAN_VIEN |  | Scheme: IP_ALT_ID_TYPE. ETL-derived. |
| 12 | Identification Number | identn_nbr | STRING | X |  |  |  | Số chứng chỉ hành nghề kiểm toán. | SCMS.CT_KIEM_TOAN_VIEN | SO_CHUNG_CHI |  |
| 13 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp chứng chỉ hành nghề. | SCMS.CT_KIEM_TOAN_VIEN | NGAY_CAP |  |
| 14 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp chứng chỉ hành nghề. | SCMS.CT_KIEM_TOAN_VIEN |  |  |


#### 2.{IDX}.26.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Audit Firm Practitioner | Audit Firm Practitioner Id | audt_firm_practitioner_id |




### 2.{IDX}.27 Bảng Report Template Sheet

- **Mô tả:** 
- **Tên vật lý:** report_template_sheet
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|


#### 2.{IDX}.27.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.28 Bảng Report Template Row

- **Mô tả:** 
- **Tên vật lý:** report_template_row
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|


#### 2.{IDX}.28.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.29 Bảng Report Template Column

- **Mô tả:** 
- **Tên vật lý:** report_template_column
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|


#### 2.{IDX}.29.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.30 Bảng Report Submission Schedule

- **Mô tả:** Lịch định kỳ gửi báo cáo theo biểu mẫu (hàng ngày/tuần/tháng/quý/năm). Xác định tần suất nghĩa vụ nộp báo cáo.
- **Tên vật lý:** rpt_submission_shd
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Report Submission Schedule Id | rpt_submission_shd_id | BIGINT |  | X | P |  | Khóa đại diện cho định kỳ gửi báo cáo. | SCMS.BM_BAO_CAO_DINH_KY |  | PK surrogate. |
| 2 | Report Submission Schedule Code | rpt_submission_shd_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.BM_BAO_CAO_DINH_KY | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.BM_BAO_CAO_DINH_KY' | Mã nguồn dữ liệu. | SCMS.BM_BAO_CAO_DINH_KY |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Report Template Id | rpt_tpl_id | BIGINT |  |  | F |  | FK đến biểu mẫu báo cáo. | SCMS.BM_BAO_CAO_DINH_KY | BM_BAO_CAO_ID |  |
| 5 | Report Template Code | rpt_tpl_code | STRING |  |  |  |  | Mã biểu mẫu báo cáo. | SCMS.BM_BAO_CAO_DINH_KY | BM_BAO_CAO_ID |  |
| 6 | Version | vrsn | STRING | X |  |  |  | Phiên bản định kỳ báo cáo. | SCMS.BM_BAO_CAO_DINH_KY | PHIEN_BAN |  |
| 7 | Reporting Period Type Code | rpt_prd_tp_code | STRING | X |  |  |  | Kỳ báo cáo (tần suất định kỳ). | SCMS.BM_BAO_CAO_DINH_KY | KY_BAO_CAO | Scheme: SCMS_SCHEDULE_STATUS. Giá trị kỳ báo cáo — cần profile data để xác định scheme đầy đủ. |
| 8 | Grace Period Days | grc_prd_dys | INT | X |  |  |  | Khoảng thời gian gia hạn T+ (số ngày). | SCMS.BM_BAO_CAO_DINH_KY | T |  |
| 9 | Submission Deadline | submission_ddln | STRING | X |  |  |  | Thời gian nộp báo cáo. | SCMS.BM_BAO_CAO_DINH_KY | THOI_GIAN |  |
| 10 | Is Active Flag | is_actv_f | BOOLEAN | X |  |  |  | Trạng thái sử dụng: 1-Sử dụng; 0-Không sử dụng. | SCMS.BM_BAO_CAO_DINH_KY | SU_DUNG |  |
| 11 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. | SCMS.BM_BAO_CAO_DINH_KY | NGAY_CAP_NHAT |  |


#### 2.{IDX}.30.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Report Submission Schedule Id | rpt_submission_shd_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Report Template Id | rpt_tpl_id | Report Template | Report Template Id | rpt_tpl_id |




### 2.{IDX}.31 Bảng Report Indicator

- **Mô tả:** 
- **Tên vật lý:** report_indicator
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|


#### 2.{IDX}.31.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.32 Bảng Report Template Indicator

- **Mô tả:** 
- **Tên vật lý:** report_template_indicator
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|


#### 2.{IDX}.32.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.33 Bảng Report Submission Obligation

- **Mô tả:** Nghĩa vụ gửi báo cáo của từng CTCK theo định kỳ cụ thể. Xác định đơn vị nào phải nộp biểu mẫu nào theo lịch nào.
- **Tên vật lý:** rpt_submission_oblg
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Report Submission Obligation Id | rpt_submission_oblg_id | BIGINT |  | X | P |  | Khóa đại diện cho nghĩa vụ gửi báo cáo. | SCMS.BM_BAO_CAO_DINH_KY_DON_VI |  | PK surrogate. |
| 2 | Report Submission Obligation Code | rpt_submission_oblg_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.BM_BAO_CAO_DINH_KY_DON_VI | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.BM_BAO_CAO_DINH_KY_DON_VI' | Mã nguồn dữ liệu. | SCMS.BM_BAO_CAO_DINH_KY_DON_VI |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Report Submission Schedule Id | rpt_submission_shd_id | BIGINT |  |  | F |  | FK đến định kỳ gửi báo cáo. | SCMS.BM_BAO_CAO_DINH_KY_DON_VI | BM_BAO_CAO_DINH_KY_ID |  |
| 5 | Report Submission Schedule Code | rpt_submission_shd_code | STRING |  |  |  |  | Mã định kỳ gửi báo cáo. | SCMS.BM_BAO_CAO_DINH_KY_DON_VI | BM_BAO_CAO_DINH_KY_ID |  |
| 6 | Securities Company Id | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán có nghĩa vụ gửi. | SCMS.BM_BAO_CAO_DINH_KY_DON_VI | CTCK_THONG_TIN_ID |  |
| 7 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.BM_BAO_CAO_DINH_KY_DON_VI | CTCK_THONG_TIN_ID |  |
| 8 | Obligated Companies Reference Code | obligated_companies_refr_code | STRING | X |  | F |  | BK tham chiếu đến bản ghi danh sách thành viên gửi (BM_BAO_CAO_TV). | SCMS.BM_BAO_CAO_DINH_KY_DON_VI | BM_BAO_CAO_TV_ID |  |
| 9 | Version | vrsn | STRING | X |  |  |  | Phiên bản nghĩa vụ. | SCMS.BM_BAO_CAO_DINH_KY_DON_VI | PHIEN_BAN |  |


#### 2.{IDX}.33.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Report Submission Obligation Id | rpt_submission_oblg_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Report Submission Schedule Id | rpt_submission_shd_id | Report Submission Schedule | Report Submission Schedule Id | rpt_submission_shd_id |
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |




### 2.{IDX}.34 Bảng Member Periodic Report

- **Mô tả:** Báo cáo định kỳ do thành viên thị trường nộp lên UBCKNN theo từng kỳ báo cáo. Ghi nhận trạng thái nộp và thời hạn.
- **Tên vật lý:** mbr_prd_rpt
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Member Periodic Report Id | mbr_prd_rpt_id | BIGINT |  | X | P |  | Khóa đại diện cho lần gửi báo cáo định kỳ. | SCMS.BC_THANH_VIEN |  | PK surrogate. Shared entity với FMS.RPTMEMBER. |
| 2 | Member Periodic Report Code | mbr_prd_rpt_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.BC_THANH_VIEN | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.BC_THANH_VIEN' | Mã nguồn dữ liệu. | SCMS.BC_THANH_VIEN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Fund Management Company Id | fnd_mgt_co_id | BIGINT | X |  | F |  | FK đến công ty QLQ nộp báo cáo (nullable). | SCMS.BC_THANH_VIEN |  |  |
| 5 | Fund Management Company Code | fnd_mgt_co_code | STRING | X |  |  |  | Mã công ty QLQ. | SCMS.BC_THANH_VIEN |  |  |
| 6 | Investment Fund Id | ivsm_fnd_id | BIGINT | X |  | F |  | FK đến quỹ đầu tư nộp báo cáo (nullable). | SCMS.BC_THANH_VIEN |  |  |
| 7 | Investment Fund Code | ivsm_fnd_code | STRING | X |  |  |  | Mã quỹ đầu tư. | SCMS.BC_THANH_VIEN |  |  |
| 8 | Custodian Bank Id | cstd_bnk_id | BIGINT | X |  | F |  | FK đến ngân hàng LKGS nộp báo cáo (nullable). | SCMS.BC_THANH_VIEN |  |  |
| 9 | Custodian Bank Code | cstd_bnk_code | STRING | X |  |  |  | Mã ngân hàng LKGS. | SCMS.BC_THANH_VIEN |  |  |
| 10 | Foreign Fund Management Organization Unit Id | frgn_fnd_mgt_ou_id | BIGINT | X |  | F |  | FK đến VPĐD/CN QLQ NN nộp báo cáo (nullable). | SCMS.BC_THANH_VIEN |  |  |
| 11 | Foreign Fund Management Organization Unit Code | frgn_fnd_mgt_ou_code | STRING | X |  |  |  | Mã VPĐD/CN QLQ NN. | SCMS.BC_THANH_VIEN |  |  |
| 12 | Report Template Id | rpt_tpl_id | BIGINT |  |  | F |  | FK đến biểu mẫu báo cáo. | SCMS.BC_THANH_VIEN | BM_BAO_CAO_ID |  |
| 13 | Report Template Code | rpt_tpl_code | STRING |  |  |  |  | Mã biểu mẫu báo cáo. | SCMS.BC_THANH_VIEN | BM_BAO_CAO_ID |  |
| 14 | Reporting Period Id | rpt_prd_id | BIGINT |  |  | F |  | FK đến kỳ báo cáo. | SCMS.BC_THANH_VIEN |  |  |
| 15 | Reporting Period Code | rpt_prd_code | STRING |  |  |  |  | Mã kỳ báo cáo. | SCMS.BC_THANH_VIEN |  |  |
| 16 | Is Import Indicator | is_impr_ind | STRING | X |  |  |  | Là báo cáo có import: 1-Có; 2-Không. | SCMS.BC_THANH_VIEN |  |  |
| 17 | Report Name | rpt_nm | STRING | X |  |  |  | Tên báo cáo. | SCMS.BC_THANH_VIEN |  |  |
| 18 | Content Summary | cntnt_smy | STRING | X |  |  |  | Tóm tắt nội dung báo cáo. | SCMS.BC_THANH_VIEN |  |  |
| 19 | Report Type Code | rpt_tp_code | STRING | X |  |  |  | Loại báo cáo: định kỳ hoặc bất thường. | SCMS.BC_THANH_VIEN |  | Scheme: FMS_REPORT_TYPE. |
| 20 | Reporting Member Type Code | rpt_mbr_tp_code | STRING | X |  |  |  | Loại thành viên nộp báo cáo. | SCMS.BC_THANH_VIEN |  | Scheme: FMS_REPORTING_MEMBER_TYPE. |
| 21 | Reporting Period Type Code | rpt_prd_tp_code | STRING | X |  |  |  | Kiểu kỳ báo cáo (tháng/quý/năm). | SCMS.BC_THANH_VIEN |  | Scheme: FMS_REPORTING_PERIOD_TYPE. |
| 22 | Year Value | yr_val | STRING | X |  |  |  | Năm báo cáo. | SCMS.BC_THANH_VIEN |  |  |
| 23 | Day Report | day_rpt | INT | X |  |  |  | Ngày trong kỳ báo cáo. | SCMS.BC_THANH_VIEN |  |  |
| 24 | Submission Deadline Date | submission_ddln_dt | DATE | X |  |  |  | Thời hạn nộp báo cáo. | SCMS.BC_THANH_VIEN |  |  |
| 25 | Submission Date | submission_dt | DATE | X |  |  |  | Ngày gửi báo cáo. | SCMS.BC_THANH_VIEN | NGAY_GUI |  |
| 26 | Report Submission Status Code | rpt_submission_st_code | STRING | X |  |  |  | Trạng thái nộp báo cáo. | SCMS.BC_THANH_VIEN |  | Scheme: FMS_REPORT_SUBMISSION_STATUS. |
| 27 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | SCMS.BC_THANH_VIEN |  |  |
| 28 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.BC_THANH_VIEN | NGAY_TAO |  |
| 29 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | SCMS.BC_THANH_VIEN |  |  |
| 30 | Securities Company Id | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán gửi báo cáo. | SCMS.BC_THANH_VIEN | CTCK_THONG_TIN_ID |  |
| 31 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.BC_THANH_VIEN | CTCK_THONG_TIN_ID |  |
| 32 | Report Submission Schedule Id | rpt_submission_shd_id | BIGINT | X |  | F |  | FK đến định kỳ gửi báo cáo. | SCMS.BC_THANH_VIEN | BM_BAO_CAO_DINH_KY_ID |  |
| 33 | Report Submission Schedule Code | rpt_submission_shd_code | STRING | X |  |  |  | Mã định kỳ gửi báo cáo. | SCMS.BC_THANH_VIEN | BM_BAO_CAO_DINH_KY_ID |  |
| 34 | Description | dsc | STRING | X |  |  |  | Mô tả lần gửi. | SCMS.BC_THANH_VIEN | MO_TA |  |
| 35 | Reason | rsn | STRING | X |  |  |  | Lý do gửi (áp dụng gửi lại). | SCMS.BC_THANH_VIEN | LY_DO |  |
| 36 | Re Submission Reason | re_submission_rsn | STRING | X |  |  |  | Lý do gửi lại. | SCMS.BC_THANH_VIEN | LY_DO_GUI_LAI |  |
| 37 | Attachment File | attachment_file | STRING | X |  |  |  | Tệp đính kèm. | SCMS.BC_THANH_VIEN | TEP_DINH_KEM |  |
| 38 | Report Date | rpt_dt | DATE | X |  |  |  | Ngày số liệu báo cáo. | SCMS.BC_THANH_VIEN | NGAY_SO_LIEU |  |
| 39 | Submission Timestamp | submission_tms | TIMESTAMP | X |  |  |  | Thời điểm gửi chính xác. | SCMS.BC_THANH_VIEN | THOI_DIEM_GUI |  |
| 40 | Is Deleted Indicator | is_del_ind | STRING | X |  |  |  | Cờ xóa tạm: 1-Xóa; 0-Không xóa. | SCMS.BC_THANH_VIEN | XOA_DU_LIEU |  |
| 41 | Submission Status Code | submission_st_code | STRING | X |  |  |  | Trạng thái lần gửi: 4-Đã gửi; 5-Yêu cầu gửi lại; 6-Đã gửi lại. | SCMS.BC_THANH_VIEN | TRANG_THAI | Scheme: SCMS_REPORT_SUBMISSION_STATUS. |
| 42 | Version | vrsn | STRING | X |  |  |  | Phiên bản báo cáo. | SCMS.BC_THANH_VIEN | PHIEN_BAN |  |


#### 2.{IDX}.34.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Member Periodic Report Id | mbr_prd_rpt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Fund Management Company Id | fnd_mgt_co_id | Fund Management Company | Fund Management Company Id | fnd_mgt_co_id |
| Investment Fund Id | ivsm_fnd_id | Investment Fund | Investment Fund Id | ivsm_fnd_id |
| Custodian Bank Id | cstd_bnk_id | Custodian Bank | Custodian Bank Id | cstd_bnk_id |
| Foreign Fund Management Organization Unit Id | frgn_fnd_mgt_ou_id | Foreign Fund Management Organization Unit | Foreign Fund Management Organization Unit Id | frgn_fnd_mgt_ou_id |
| Report Template Id | rpt_tpl_id | Report Template | Report Template Id | rpt_tpl_id |
| Reporting Period Id | rpt_prd_id | Reporting Period | Reporting Period Id | rpt_prd_id |
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |
| Report Submission Schedule Id | rpt_submission_shd_id | Report Submission Schedule | Report Submission Schedule Id | rpt_submission_shd_id |




### 2.{IDX}.35 Bảng Securities Company Report Violation

- **Mô tả:** Vi phạm nộp báo cáo định kỳ của CTCK. Ghi nhận loại vi phạm và thông tin xử lý.
- **Tên vật lý:** scr_co_rpt_vln
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Securities Company Report Violation Id | scr_co_rpt_vln_id | BIGINT |  | X | P |  | Khóa đại diện cho bản ghi vi phạm báo cáo. | SCMS.BC_VI_PHAM |  | PK surrogate. |
| 2 | Securities Company Report Violation Code | scr_co_rpt_vln_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.BC_VI_PHAM | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.BC_VI_PHAM' | Mã nguồn dữ liệu. | SCMS.BC_VI_PHAM |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Securities Company Id | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán vi phạm. | SCMS.BC_VI_PHAM | CTCK_THONG_TIN_ID |  |
| 5 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.BC_VI_PHAM | CTCK_THONG_TIN_ID |  |
| 6 | Violation Date | vln_dt | DATE | X |  |  |  | Ngày vi phạm. | SCMS.BC_VI_PHAM | NGAY_VI_PHAM |  |
| 7 | Reason | rsn | STRING | X |  |  |  | Lý do vi phạm. | SCMS.BC_VI_PHAM | LY_DO |  |
| 8 | Violation Type Codes | vln_tp_codes | Array<Text> | X |  |  |  | Danh sách mã loại vi phạm. | SCMS.BC_VI_PHAM | DM_LOAI_VI_PHAM_ID |  |
| 9 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. | SCMS.BC_VI_PHAM | NGAY_CAP_NHAT |  |


#### 2.{IDX}.35.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Securities Company Report Violation Id | scr_co_rpt_vln_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |




### 2.{IDX}.36 Bảng Securities Company Administrative Penalty

- **Mô tả:** Quyết định xử lý hành chính đối với CTCK. Ghi nhận hành vi vi phạm và quyết định xử phạt.
- **Tên vật lý:** scr_co_admn_pny
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Securities Company Administrative Penalty Id | scr_co_admn_pny_id | BIGINT |  | X | P |  | Khóa đại diện cho quyết định xử lý hành chính. | SCMS.CTCK_XU_LY_HANH_CHINH |  | PK surrogate. |
| 2 | Securities Company Administrative Penalty Code | scr_co_admn_pny_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.CTCK_XU_LY_HANH_CHINH | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_XU_LY_HANH_CHINH' | Mã nguồn dữ liệu. | SCMS.CTCK_XU_LY_HANH_CHINH |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Securities Company Id | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán bị xử lý. | SCMS.CTCK_XU_LY_HANH_CHINH | CTCK_THONG_TIN_ID |  |
| 5 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.CTCK_XU_LY_HANH_CHINH | CTCK_THONG_TIN_ID |  |
| 6 | Penalty Form Code | pny_form_code | STRING | X |  |  |  | Hình thức xử lý hành chính. | SCMS.CTCK_XU_LY_HANH_CHINH | HINH_THUC | Scheme: SCMS_PENALTY_FORM. |
| 7 | Content | cntnt | STRING | X |  |  |  | Nội dung quyết định xử lý. | SCMS.CTCK_XU_LY_HANH_CHINH | NOI_DUNG |  |
| 8 | Penalty Amount | pny_amt | DECIMAL(18,2) | X |  |  |  | Số tiền phạt. | SCMS.CTCK_XU_LY_HANH_CHINH | SO_TIEN |  |
| 9 | Additional Penalty | adl_pny | STRING | X |  |  |  | Hình phạt bổ sung. | SCMS.CTCK_XU_LY_HANH_CHINH | HINH_PHAT_BO_SUNG |  |
| 10 | Additional Penalty Date | adl_pny_dt | DATE | X |  |  |  | Ngày áp dụng hình phạt bổ sung. | SCMS.CTCK_XU_LY_HANH_CHINH | NGAY_PHAT_BO_SUNG |  |
| 11 | Decision Number | dcsn_nbr | STRING | X |  |  |  | Số quyết định xử lý hành chính. | SCMS.CTCK_XU_LY_HANH_CHINH | QUYET_DINH |  |
| 12 | Decision Date | dcsn_dt | DATE | X |  |  |  | Ngày quyết định. | SCMS.CTCK_XU_LY_HANH_CHINH | NGAY_QUYET_DINH |  |
| 13 | Penalty Status Code | pny_st_code | STRING | X |  |  |  | Trạng thái quyết định xử lý. | SCMS.CTCK_XU_LY_HANH_CHINH | TRANG_THAI | Scheme: SCMS_PENALTY_STATUS. |
| 14 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.CTCK_XU_LY_HANH_CHINH | NGAY_TAO |  |
| 15 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. | SCMS.CTCK_XU_LY_HANH_CHINH | NGAY_CAP_NHAT |  |


#### 2.{IDX}.36.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Securities Company Administrative Penalty Id | scr_co_admn_pny_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |




### 2.{IDX}.37 Bảng Disclosure Report Submission

- **Mô tả:** Báo cáo công bố thông tin do CTCK nộp lên UBCKNN theo yêu cầu minh bạch thị trường.
- **Tên vật lý:** dscl_rpt_submission
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Disclosure Report Submission Id | dscl_rpt_submission_id | BIGINT |  | X | P |  | Khóa đại diện cho lần công bố thông tin báo cáo. | SCMS.CBTT_BAO_CAO |  | PK surrogate. |
| 2 | Disclosure Report Submission Code | dscl_rpt_submission_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.CBTT_BAO_CAO | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CBTT_BAO_CAO' | Mã nguồn dữ liệu. | SCMS.CBTT_BAO_CAO |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Securities Company Id | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán công bố. | SCMS.CBTT_BAO_CAO | CTCK_THONG_TIN_ID |  |
| 5 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.CBTT_BAO_CAO | CTCK_THONG_TIN_ID |  |
| 6 | Disclosure Method Code | dscl_mth_code | STRING | X |  |  |  | Kiểu công bố thông tin. | SCMS.CBTT_BAO_CAO | KIEU_CONG_BO | Scheme: SCMS_DISCLOSURE_METHOD. |
| 7 | Disclosure Type Code | dscl_tp_code | STRING | X |  |  |  | Loại công bố thông tin. | SCMS.CBTT_BAO_CAO | LOAI_CONG_BO | Scheme: SCMS_DISCLOSURE_TYPE. |
| 8 | Reporting Period Code | rpt_prd_code | STRING | X |  |  |  | Kỳ báo cáo. | SCMS.CBTT_BAO_CAO | KY_BAO_CAO |  |
| 9 | Reporting Year | rpt_yr | INT | X |  |  |  | Năm báo cáo. | SCMS.CBTT_BAO_CAO | NAM |  |
| 10 | Title | ttl | STRING | X |  |  |  | Tiêu đề thông tin công bố. | SCMS.CBTT_BAO_CAO | TIEU_DE |  |
| 11 | Description | dsc | STRING | X |  |  |  | Mô tả nội dung. | SCMS.CBTT_BAO_CAO | MO_TA |  |
| 12 | Summary | smy | STRING | X |  |  |  | Nội dung trích yếu. | SCMS.CBTT_BAO_CAO | NOI_DUNG_TRICH_YEU |  |
| 13 | Disclosing Person Name | disclosing_psn_nm | STRING | X |  |  |  | Người công bố thông tin. | SCMS.CBTT_BAO_CAO | NGUOI_CBTT |  |
| 14 | Disclosure Date | dscl_dt | DATE | X |  |  |  | Ngày công bố thông tin. | SCMS.CBTT_BAO_CAO | NGAY_CBTT |  |
| 15 | Submission Date | submission_dt | DATE | X |  |  |  | Ngày gửi lên hệ thống. | SCMS.CBTT_BAO_CAO | NGAY_GUI |  |
| 16 | Attachment File | attachment_file | STRING | X |  |  |  | Tệp đính kèm. | SCMS.CBTT_BAO_CAO | FILE_DINH_KEM |  |
| 17 | Error Description | err_dsc | STRING | X |  |  |  | Mô tả lỗi (nếu có). | SCMS.CBTT_BAO_CAO | MO_TA_LOI |  |
| 18 | Disclosure Status Code | dscl_st_code | STRING | X |  |  |  | Trạng thái công bố thông tin. | SCMS.CBTT_BAO_CAO | TRANG_THAI | Scheme: SCMS_DISCLOSURE_STATUS. |
| 19 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.CBTT_BAO_CAO | NGAY_TAO |  |


#### 2.{IDX}.37.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Disclosure Report Submission Id | dscl_rpt_submission_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |




### 2.{IDX}.38 Bảng Disclosure Securities Offering

- **Mô tả:** Thông tin chào bán chứng khoán được công bố bởi CTCK. Ghi nhận loại chứng khoán và điều kiện chào bán.
- **Tên vật lý:** dscl_scr_ofrg
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Disclosure Securities Offering Id | dscl_scr_ofrg_id | BIGINT |  | X | P |  | Khóa đại diện cho đợt chào bán chứng khoán được công bố. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN |  | PK surrogate. |
| 2 | Disclosure Securities Offering Code | dscl_scr_ofrg_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN' | Mã nguồn dữ liệu. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Securities Company Id | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán chào bán. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN | CTCK_THONG_TIN_ID |  |
| 5 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN | CTCK_THONG_TIN_ID |  |
| 6 | Document Number | doc_nbr | STRING | X |  |  |  | Số văn bản. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN | SO_VAN_BAN |  |
| 7 | Document Date | doc_dt | DATE | X |  |  |  | Ngày văn bản. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN | NGAY_VAN_BAN |  |
| 8 | Effective Date | eff_dt | DATE | X |  |  |  | Ngày hợp lệ hồ sơ. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN | NGAY_HOP_LE |  |
| 9 | Offering Start Date | ofrg_strt_dt | DATE | X |  |  |  | Ngày bắt đầu chào bán. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN | NGAY_CHAO_BAN |  |
| 10 | Offering End Date | ofrg_end_dt | DATE | X |  |  |  | Ngày kết thúc chào bán. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN | NGAY_KET_THUC |  |
| 11 | Offering Form Code | ofrg_form_code | STRING | X |  |  |  | Hình thức chào bán. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN | HINH_THUC_CHAO_BAN | Scheme: SCMS_OFFERING_FORM. |
| 12 | Target Investor Name | trgt_ivsr_nm | STRING | X |  |  |  | Đối tượng chào bán. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN | DOI_TUONG_CHAO_BAN |  |
| 13 | Offering Volume | ofrg_vol | DECIMAL(18,2) | X |  |  |  | Khối lượng chào bán. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN | KHOI_LUONG |  |
| 14 | Offering Value | ofrg_val | DECIMAL(18,2) | X |  |  |  | Giá trị chào bán. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN | GIA_TRI |  |
| 15 | Note | note | STRING | X |  |  |  | Ghi chú. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN | GHI_CHU |  |
| 16 | Disclosing Person Name | disclosing_psn_nm | STRING | X |  |  |  | Người công bố thông tin. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN | NGUOI_CBTT |  |
| 17 | Disclosure Date | dscl_dt | DATE | X |  |  |  | Ngày công bố thông tin. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN | NGAY_CBTT |  |
| 18 | Submission Date | submission_dt | DATE | X |  |  |  | Ngày gửi lên hệ thống. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN | NGAY_GUI |  |
| 19 | Attachment File | attachment_file | STRING | X |  |  |  | Tệp đính kèm. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN | FILE_DINH_KEM |  |
| 20 | Error Description | err_dsc | STRING | X |  |  |  | Mô tả lỗi. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN | MO_TA_LOI |  |
| 21 | Disclosure Status Code | dscl_st_code | STRING | X |  |  |  | Trạng thái công bố. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN | TRANG_THAI | Scheme: SCMS_DISCLOSURE_STATUS. |
| 22 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN | NGAY_TAO |  |
| 23 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. | SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN | NGAY_CAP_NHAT |  |


#### 2.{IDX}.38.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Disclosure Securities Offering Id | dscl_scr_ofrg_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |




### 2.{IDX}.39 Bảng Disclosure Shareholder Change

- **Mô tả:** Thông tin thay đổi cổ đông được công bố bởi CTCK. Ghi nhận cổ đông và tỷ lệ sở hữu thay đổi.
- **Tên vật lý:** dscl_shrhlr_chg
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Disclosure Shareholder Change Id | dscl_shrhlr_chg_id | BIGINT |  | X | P |  | Khóa đại diện cho thông tin cổ đông được công bố. | SCMS.CBTT_CO_DONG |  | PK surrogate. |
| 2 | Disclosure Shareholder Change Code | dscl_shrhlr_chg_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.CBTT_CO_DONG | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CBTT_CO_DONG' | Mã nguồn dữ liệu. | SCMS.CBTT_CO_DONG |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Securities Company Id | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán công bố. | SCMS.CBTT_CO_DONG | CTCK_THONG_TIN_ID |  |
| 5 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.CBTT_CO_DONG | CTCK_THONG_TIN_ID |  |
| 6 | Transaction Type Code | txn_tp_code | STRING | X |  | F |  | Loại giao dịch cổ đông. | SCMS.CBTT_CO_DONG | LOAI_GIAO_DICH_ID | Scheme: SCMS_SHAREHOLDER_TXN_TYPE. FK đến bảng danh mục DM_LOAI_GIAO_DICH_CD — lưu dạng Classification Value. |
| 7 | Disclosure Date | dscl_dt | DATE | X |  |  |  | Ngày công bố thông tin. | SCMS.CBTT_CO_DONG | NGAY_CONG_BO |  |
| 8 | Content | cntnt | STRING | X |  |  |  | Nội dung công bố. | SCMS.CBTT_CO_DONG | NOI_DUNG |  |
| 9 | Attachment File | attachment_file | STRING | X |  |  |  | Tệp đính kèm. | SCMS.CBTT_CO_DONG | FILE_DINH_KEM |  |
| 10 | Disclosure Status Code | dscl_st_code | STRING | X |  |  |  | Trạng thái công bố. | SCMS.CBTT_CO_DONG | TRANG_THAI | Scheme: SCMS_DISCLOSURE_STATUS. |
| 11 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.CBTT_CO_DONG | NGAY_TAO |  |


#### 2.{IDX}.39.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Disclosure Shareholder Change Id | dscl_shrhlr_chg_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |




### 2.{IDX}.40 Bảng Member Report Indicator Value

- **Mô tả:** Giá trị từng chỉ tiêu trong một lần nộp báo cáo định kỳ. Grain = 1 giá trị cell-level (submission x template_indicator x row). FK đến Member Periodic Report.
- **Tên vật lý:** mbr_rpt_ind_val
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Member Report Indicator Value Id | mbr_rpt_ind_val_id | BIGINT |  | X | P |  | Khóa đại diện cho giá trị chỉ tiêu báo cáo. | SCMS.BC_BAO_CAO_GT |  | PK surrogate. Fact Append — không SCD. |
| 2 | Member Report Indicator Value Code | mbr_rpt_ind_val_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.BC_BAO_CAO_GT | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.BC_BAO_CAO_GT' | Mã nguồn dữ liệu. | SCMS.BC_BAO_CAO_GT |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Report Template Id | rpt_tpl_id | BIGINT | X |  | F |  | FK đến biểu mẫu báo cáo. | SCMS.BC_BAO_CAO_GT | BM_BAO_CAO_ID |  |
| 5 | Report Template Code | rpt_tpl_code | STRING | X |  |  |  | Mã biểu mẫu báo cáo. | SCMS.BC_BAO_CAO_GT | BM_BAO_CAO_ID |  |
| 6 | Securities Company Id | scr_co_id | BIGINT | X |  | F |  | FK đến công ty chứng khoán nộp báo cáo. | SCMS.BC_BAO_CAO_GT | CTCK_THONG_TIN_ID |  |
| 7 | Securities Company Code | scr_co_code | STRING | X |  |  |  | Mã công ty chứng khoán. | SCMS.BC_BAO_CAO_GT | CTCK_THONG_TIN_ID |  |
| 8 | Report Template Sheet Id | rpt_tpl_shet_id | BIGINT | X |  | F |  | FK đến sheet báo cáo. | SCMS.BC_BAO_CAO_GT | BM_SHEET_ID |  |
| 9 | Report Template Sheet Code | rpt_tpl_shet_code | STRING | X |  |  |  | Mã sheet báo cáo. | SCMS.BC_BAO_CAO_GT | BM_SHEET_ID |  |
| 10 | Report Template Row Id | rpt_tpl_row_id | BIGINT | X |  | F |  | FK đến hàng báo cáo. | SCMS.BC_BAO_CAO_GT | BM_BAO_CAO_HANG_ID |  |
| 11 | Report Template Row Code | rpt_tpl_row_code | STRING | X |  |  |  | Mã hàng báo cáo. | SCMS.BC_BAO_CAO_GT | BM_BAO_CAO_HANG_ID |  |
| 12 | Report Template Column Id | rpt_tpl_clmn_id | BIGINT | X |  | F |  | FK đến cột báo cáo. | SCMS.BC_BAO_CAO_GT | BM_BAO_CAO_COT_ID |  |
| 13 | Report Template Column Code | rpt_tpl_clmn_code | STRING | X |  |  |  | Mã cột báo cáo. | SCMS.BC_BAO_CAO_GT | BM_BAO_CAO_COT_ID |  |
| 14 | Member Periodic Report Id | mbr_prd_rpt_id | BIGINT |  |  | F |  | FK đến lần nộp báo cáo. | SCMS.BC_BAO_CAO_GT | BC_THANH_VIEN_ID |  |
| 15 | Member Periodic Report Code | mbr_prd_rpt_code | STRING |  |  |  |  | Mã lần nộp báo cáo. | SCMS.BC_BAO_CAO_GT | BC_THANH_VIEN_ID |  |
| 16 | Report Template Indicator Id | rpt_tpl_ind_id | BIGINT | X |  | F |  | FK đến chỉ tiêu trong biểu mẫu. | SCMS.BC_BAO_CAO_GT | BM_BAO_CAO_CT_ID |  |
| 17 | Report Template Indicator Code | rpt_tpl_ind_code | STRING | X |  |  |  | Mã chỉ tiêu trong biểu mẫu. | SCMS.BC_BAO_CAO_GT | BM_BAO_CAO_CT_ID |  |
| 18 | Report Indicator Id | rpt_ind_id | BIGINT | X |  | F |  | FK đến chỉ tiêu danh mục. | SCMS.BC_BAO_CAO_GT | DM_CHI_TIEU_ID |  |
| 19 | Report Indicator Code | rpt_ind_code | STRING | X |  |  |  | Mã chỉ tiêu danh mục. | SCMS.BC_BAO_CAO_GT | DM_CHI_TIEU_ID |  |
| 20 | Sheet Name | shet_nm | STRING | X |  |  |  | Tên sheet báo cáo (denormalized). | SCMS.BC_BAO_CAO_GT | TEN_SHEET |  |
| 21 | Row Name | row_nm | STRING | X |  |  |  | Tên hàng báo cáo (denormalized). | SCMS.BC_BAO_CAO_GT | TEN_HANG |  |
| 22 | Column Name | clmn_nm | STRING | X |  |  |  | Tên cột báo cáo (denormalized). | SCMS.BC_BAO_CAO_GT | TEN_COT |  |
| 23 | Row Sequence | row_seq | INT | X |  | F |  | Số thứ tự dòng dữ liệu (cho chỉ tiêu lặp). | SCMS.BC_BAO_CAO_GT | ROW_ID |  |
| 24 | Catalog Name | ctlg_nm | STRING | X |  |  |  | Tên danh mục tương ứng (nếu chỉ tiêu kiểu danh mục). | SCMS.BC_BAO_CAO_GT | TEN_DANH_MUC |  |
| 25 | Catalog Id Reference | ctlg_id_refr | STRING | X |  | F |  | Khóa danh mục tương ứng. | SCMS.BC_BAO_CAO_GT | ID_DANH_MUC |  |
| 26 | Catalog Display Value | ctlg_dspl_val | STRING | X |  |  |  | Giá trị hiển thị của danh mục. | SCMS.BC_BAO_CAO_GT | TEXT_DANH_MUC |  |
| 27 | Value | val | STRING | X |  |  |  | Giá trị chỉ tiêu. | SCMS.BC_BAO_CAO_GT | GIA_TRI |  |
| 28 | Formula | frml | STRING | X |  |  |  | Công thức tính (nếu có). | SCMS.BC_BAO_CAO_GT | CONG_THUC |  |
| 29 | Aggregate Formula | agrt_frml | STRING | X |  |  |  | Công thức tổng hợp. | SCMS.BC_BAO_CAO_GT | CONG_THUC_TONG |  |
| 30 | Report Date | rpt_dt | DATE | X |  |  |  | Ngày số liệu báo cáo. | SCMS.BC_BAO_CAO_GT | NGAY_SO_LIEU |  |
| 31 | Version | vrsn | STRING | X |  |  |  | Phiên bản báo cáo. | SCMS.BC_BAO_CAO_GT | PHIEN_BAN |  |
| 32 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.BC_BAO_CAO_GT | NGAY_TAO |  |
| 33 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. | SCMS.BC_BAO_CAO_GT | NGAY_CAP_NHAT |  |


#### 2.{IDX}.40.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Member Report Indicator Value Id | mbr_rpt_ind_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Report Template Id | rpt_tpl_id | Report Template | Report Template Id | rpt_tpl_id |
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |
| Report Template Sheet Id | rpt_tpl_shet_id | Report Template Sheet | Report Template Sheet Id |  |
| Report Template Row Id | rpt_tpl_row_id | Report Template Row | Report Template Row Id |  |
| Report Template Column Id | rpt_tpl_clmn_id | Report Template Column | Report Template Column Id |  |
| Member Periodic Report Id | mbr_prd_rpt_id | Member Periodic Report | Member Periodic Report Id | mbr_prd_rpt_id |
| Report Template Indicator Id | rpt_tpl_ind_id | Report Template Indicator | Report Template Indicator Id |  |
| Report Indicator Id | rpt_ind_id | Report Indicator | Report Indicator Id |  |




### 2.{IDX}.41 Bảng Securities Company Shareholder Transfer

- **Mô tả:** Giao dịch chuyển nhượng cổ phần giữa hai cổ đông của CTCK. Ghi nhận bên chuyển/nhận, số lượng và tỷ lệ chuyển nhượng.
- **Tên vật lý:** scr_co_shrhlr_tfr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Securities Company Shareholder Transfer Id | scr_co_shrhlr_tfr_id | BIGINT |  | X | P |  | Khóa đại diện cho giao dịch chuyển nhượng cổ phần. | SCMS.CTCK_CD_CHUYEN_NHUONG |  | PK surrogate. |
| 2 | Securities Company Shareholder Transfer Code | scr_co_shrhlr_tfr_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.CTCK_CD_CHUYEN_NHUONG | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CD_CHUYEN_NHUONG' | Mã nguồn dữ liệu. | SCMS.CTCK_CD_CHUYEN_NHUONG |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Securities Company Id | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán. | SCMS.CTCK_CD_CHUYEN_NHUONG | CTCK_THONG_TIN_ID |  |
| 5 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.CTCK_CD_CHUYEN_NHUONG | CTCK_THONG_TIN_ID |  |
| 6 | From Shareholder Id | fm_shrhlr_id | BIGINT |  |  | F |  | FK đến cổ đông chuyển nhượng. | SCMS.CTCK_CD_CHUYEN_NHUONG | CTCK_CD_CHUYEN |  |
| 7 | From Shareholder Code | fm_shrhlr_code | STRING |  |  |  |  | Mã cổ đông chuyển nhượng. | SCMS.CTCK_CD_CHUYEN_NHUONG | CTCK_CD_CHUYEN |  |
| 8 | To Shareholder Id | to_shrhlr_id | BIGINT |  |  | F |  | FK đến cổ đông nhận chuyển nhượng. | SCMS.CTCK_CD_CHUYEN_NHUONG | CTCK_CD_NHAN |  |
| 9 | To Shareholder Code | to_shrhlr_code | STRING |  |  |  |  | Mã cổ đông nhận chuyển nhượng. | SCMS.CTCK_CD_CHUYEN_NHUONG | CTCK_CD_NHAN |  |
| 10 | Document Number | doc_nbr | STRING | X |  |  |  | Số văn bản chuyển nhượng. | SCMS.CTCK_CD_CHUYEN_NHUONG | SO_VAN_BAN |  |
| 11 | Document Date | doc_dt | DATE | X |  |  |  | Ngày văn bản. | SCMS.CTCK_CD_CHUYEN_NHUONG | NGAY_VAN_BAN |  |
| 12 | Transfer Date | tfr_dt | DATE | X |  |  |  | Ngày chuyển nhượng hiệu lực. | SCMS.CTCK_CD_CHUYEN_NHUONG | NGAY_CHUYEN |  |
| 13 | Transfer Quantity | tfr_qty | DECIMAL(18,2) | X |  |  |  | Số lượng cổ phần chuyển nhượng. | SCMS.CTCK_CD_CHUYEN_NHUONG | SO_LUONG_CHUYEN |  |
| 14 | Transfer Ratio | tfr_rto | DECIMAL(9,6) | X |  |  |  | Tỷ lệ cổ phần chuyển nhượng (%). | SCMS.CTCK_CD_CHUYEN_NHUONG | TY_LE_CHUYEN |  |
| 15 | Attachment File | attachment_file | STRING | X |  |  |  | Tệp đính kèm. | SCMS.CTCK_CD_CHUYEN_NHUONG | FILE_DINH_KEM |  |
| 16 | Note | note | STRING | X |  |  |  | Ghi chú. | SCMS.CTCK_CD_CHUYEN_NHUONG | GHI_CHU |  |
| 17 | Transfer Status Code | tfr_st_code | STRING | X |  |  |  | Trạng thái chuyển nhượng. | SCMS.CTCK_CD_CHUYEN_NHUONG | TRANG_THAI | Scheme: SCMS_SHAREHOLDER_TRANSFER_STATUS. |
| 18 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.CTCK_CD_CHUYEN_NHUONG | NGAY_TAO |  |
| 19 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. | SCMS.CTCK_CD_CHUYEN_NHUONG | NGAY_CAP_NHAT |  |


#### 2.{IDX}.41.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Securities Company Shareholder Transfer Id | scr_co_shrhlr_tfr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |
| From Shareholder Id | fm_shrhlr_id | Securities Company Shareholder | Securities Company Shareholder Id | scr_co_shrhlr_id |
| To Shareholder Id | to_shrhlr_id | Securities Company Shareholder | Securities Company Shareholder Id | scr_co_shrhlr_id |




### 2.{IDX}.42 Bảng Securities Company Shareholder Representative

- **Mô tả:** Người đại diện được ủy quyền bởi cổ đông của CTCK. Ghi nhận chức vụ và số lượng cổ phần đại diện.
- **Tên vật lý:** scr_co_shrhlr_representative
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Securities Company Shareholder Representative Id | scr_co_shrhlr_representative_id | BIGINT |  | X | P |  | Khóa đại diện cho người đại diện cổ đông. | SCMS.CTCK_CD_DAI_DIEN |  | PK surrogate. |
| 2 | Securities Company Shareholder Representative Code | scr_co_shrhlr_representative_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.CTCK_CD_DAI_DIEN | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CD_DAI_DIEN' | Mã nguồn dữ liệu. | SCMS.CTCK_CD_DAI_DIEN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Securities Company Shareholder Id | scr_co_shrhlr_id | BIGINT |  |  | F |  | FK đến cổ đông được đại diện. | SCMS.CTCK_CD_DAI_DIEN | CTCK_CO_DONG_ID |  |
| 5 | Securities Company Shareholder Code | scr_co_shrhlr_code | STRING |  |  |  |  | Mã cổ đông. | SCMS.CTCK_CD_DAI_DIEN | CTCK_CO_DONG_ID |  |
| 6 | Securities Company Id | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán. | SCMS.CTCK_CD_DAI_DIEN | CTCK_THONG_TIN_ID |  |
| 7 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.CTCK_CD_DAI_DIEN | CTCK_THONG_TIN_ID |  |
| 8 | Representative Name | representative_nm | STRING | X |  |  |  | Họ và tên người đại diện. | SCMS.CTCK_CD_DAI_DIEN | NGUOI_DAI_DIEN |  |
| 9 | Position Name | pos_nm | STRING | X |  |  |  | Chức vụ người đại diện. | SCMS.CTCK_CD_DAI_DIEN | CHUC_VU |  |
| 10 | Share Quantity | shr_qty | INT | X |  |  |  | Số lượng cổ phần được đại diện. | SCMS.CTCK_CD_DAI_DIEN | SO_LUONG_CP |  |
| 11 | Share Ratio | shr_rto | DECIMAL(9,6) | X |  |  |  | Tỷ lệ cổ phần được đại diện (%). | SCMS.CTCK_CD_DAI_DIEN | TY_LE_NAM_GIU |  |
| 12 | Attachment File | attachment_file | STRING | X |  |  |  | Tệp đính kèm. | SCMS.CTCK_CD_DAI_DIEN | FILE_DINH_KEM |  |
| 13 | Note | note | STRING | X |  |  |  | Ghi chú. | SCMS.CTCK_CD_DAI_DIEN | GHI_CHU |  |
| 14 | Representative Status Code | representative_st_code | STRING | X |  |  |  | Trạng thái người đại diện. | SCMS.CTCK_CD_DAI_DIEN | TRANG_THAI | Scheme: SCMS_SHAREHOLDER_REPRESENTATIVE_STATUS. |
| 15 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.CTCK_CD_DAI_DIEN | NGAY_TAO |  |
| 16 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. | SCMS.CTCK_CD_DAI_DIEN | NGAY_CAP_NHAT |  |


#### 2.{IDX}.42.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Securities Company Shareholder Representative Id | scr_co_shrhlr_representative_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Securities Company Shareholder Id | scr_co_shrhlr_id | Securities Company Shareholder | Securities Company Shareholder Id | scr_co_shrhlr_id |
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |




### 2.{IDX}.43 Bảng Involved Party Alternative Identification — SCMS.CTCK_CD_DAI_DIEN

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến người đại diện cổ đông. | SCMS.CTCK_CD_DAI_DIEN | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người đại diện cổ đông. | SCMS.CTCK_CD_DAI_DIEN | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CD_DAI_DIEN' | Mã nguồn dữ liệu. | SCMS.CTCK_CD_DAI_DIEN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'NATIONAL_ID' | Loại định danh — CMND/CCCD. | SCMS.CTCK_CD_DAI_DIEN |  | Scheme: IP_ALT_ID_TYPE. ETL-derived: hardcode NATIONAL_ID. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số CMND/CCCD. | SCMS.CTCK_CD_DAI_DIEN | SO_CMND |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp. | SCMS.CTCK_CD_DAI_DIEN | NGAY_CAP |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp. | SCMS.CTCK_CD_DAI_DIEN | NOI_CAP |  |


#### 2.{IDX}.43.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Company Shareholder Representative | Securities Company Shareholder Representative Id | scr_co_shrhlr_representative_id |




### 2.{IDX}.44 Bảng Securities Company Shareholder Related Party

- **Mô tả:** Người có quan hệ gia đình hoặc công tác với cổ đông của CTCK. Ghi nhận loại quan hệ và nơi làm việc.
- **Tên vật lý:** scr_co_shrhlr_rel_p
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Securities Company Shareholder Related Party Id | scr_co_shrhlr_rel_p_id | BIGINT |  | X | P |  | Khóa đại diện cho người có quan hệ với cổ đông. | SCMS.CTCK_CD_MOI_QUAN_HE |  | PK surrogate. |
| 2 | Securities Company Shareholder Related Party Code | scr_co_shrhlr_rel_p_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | SCMS.CTCK_CD_MOI_QUAN_HE | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CD_MOI_QUAN_HE' | Mã nguồn dữ liệu. | SCMS.CTCK_CD_MOI_QUAN_HE |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Securities Company Shareholder Id | scr_co_shrhlr_id | BIGINT |  |  | F |  | FK đến cổ đông có người liên quan. | SCMS.CTCK_CD_MOI_QUAN_HE | CTCK_CO_DONG_ID |  |
| 5 | Securities Company Shareholder Code | scr_co_shrhlr_code | STRING |  |  |  |  | Mã cổ đông. | SCMS.CTCK_CD_MOI_QUAN_HE | CTCK_CO_DONG_ID |  |
| 6 | Securities Company Id | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán. | SCMS.CTCK_CD_MOI_QUAN_HE | CTCK_THONG_TIN_ID |  |
| 7 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.CTCK_CD_MOI_QUAN_HE | CTCK_THONG_TIN_ID |  |
| 8 | Related Party Full Name | rel_p_full_nm | STRING | X |  |  |  | Họ và tên người có quan hệ. | SCMS.CTCK_CD_MOI_QUAN_HE | HO_TEN |  |
| 9 | Relationship Type Code | rltnp_tp_code | STRING | X |  |  |  | Loại mối quan hệ với cổ đông. | SCMS.CTCK_CD_MOI_QUAN_HE | MOI_QUAN_HE | Scheme: SCMS_RELATED_PARTY_RELATIONSHIP. |
| 10 | Related Party Workplace Name | rel_p_workplace_nm | STRING | X |  |  |  | Nơi làm việc. | SCMS.CTCK_CD_MOI_QUAN_HE | NOI_LAM_VIEC |  |
| 11 | Related Party Job Position Name | rel_p_job_pos_nm | STRING | X |  |  |  | Vị trí công việc. | SCMS.CTCK_CD_MOI_QUAN_HE | VI_TRI_CONG_VIEC |  |
| 12 | Related Securities Company Name | rel_scr_co_nm | STRING | X |  | F |  | Tên CTCK có liên quan (nếu người liên quan cũng là cổ đông CTCK khác). | SCMS.CTCK_CD_MOI_QUAN_HE | TEN_CTCK_CO_CP |  |
| 13 | Share Quantity | shr_qty | INT | X |  |  |  | Số lượng cổ phần người liên quan nắm giữ tại CTCK. | SCMS.CTCK_CD_MOI_QUAN_HE | SO_LUONG_CP |  |
| 14 | Share Ratio | shr_rto | DECIMAL(9,6) | X |  |  |  | Tỷ lệ cổ phần người liên quan nắm giữ (%). | SCMS.CTCK_CD_MOI_QUAN_HE | TY_LE_NAM_GIU |  |
| 15 | Attachment File | attachment_file | STRING | X |  |  |  | Tệp đính kèm. | SCMS.CTCK_CD_MOI_QUAN_HE | FILE_DINH_KEM |  |
| 16 | Note | note | STRING | X |  |  |  | Ghi chú. | SCMS.CTCK_CD_MOI_QUAN_HE | GHI_CHU |  |
| 17 | Related Party Status Code | rel_p_st_code | STRING | X |  |  |  | Trạng thái bản ghi người liên quan. | SCMS.CTCK_CD_MOI_QUAN_HE | TRANG_THAI | Scheme: SCMS_SHAREHOLDER_RELATED_PARTY_STATUS. |
| 18 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | SCMS.CTCK_CD_MOI_QUAN_HE | NGAY_TAO |  |
| 19 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. | SCMS.CTCK_CD_MOI_QUAN_HE | NGAY_CAP_NHAT |  |


#### 2.{IDX}.44.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Securities Company Shareholder Related Party Id | scr_co_shrhlr_rel_p_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Securities Company Shareholder Id | scr_co_shrhlr_id | Securities Company Shareholder | Securities Company Shareholder Id | scr_co_shrhlr_id |
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |




### 2.{IDX}.45 Bảng Involved Party Alternative Identification — SCMS.CTCK_CD_MOI_QUAN_HE

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến người có quan hệ với cổ đông. | SCMS.CTCK_CD_MOI_QUAN_HE | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người có quan hệ với cổ đông. | SCMS.CTCK_CD_MOI_QUAN_HE | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CD_MOI_QUAN_HE' | Mã nguồn dữ liệu. | SCMS.CTCK_CD_MOI_QUAN_HE |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'NATIONAL_ID' | Loại định danh — CMND/CCCD. | SCMS.CTCK_CD_MOI_QUAN_HE |  | Scheme: IP_ALT_ID_TYPE. ETL-derived: hardcode NATIONAL_ID. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số CMND/CCCD. | SCMS.CTCK_CD_MOI_QUAN_HE | SO_CMND |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp. | SCMS.CTCK_CD_MOI_QUAN_HE | NGAY_CAP |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp. | SCMS.CTCK_CD_MOI_QUAN_HE | NOI_CAP |  |


#### 2.{IDX}.45.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Company Shareholder Related Party | Securities Company Shareholder Related Party Id | scr_co_shrhlr_rel_p_id |




### 2.{IDX}.46 Bảng Involved Party Postal Address — SCMS.CT_KIEM_TOAN

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Audit Firm. | SCMS.CT_KIEM_TOAN | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty kiểm toán. | SCMS.CT_KIEM_TOAN | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CT_KIEM_TOAN' | Mã nguồn dữ liệu. | SCMS.CT_KIEM_TOAN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. | SCMS.CT_KIEM_TOAN |  |  |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở chính. | SCMS.CT_KIEM_TOAN | DIA_CHI |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | SCMS.CT_KIEM_TOAN |  |  |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). | SCMS.CT_KIEM_TOAN |  |  |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. | SCMS.CT_KIEM_TOAN |  |  |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. | SCMS.CT_KIEM_TOAN |  |  |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | SCMS.CT_KIEM_TOAN |  |  |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | SCMS.CT_KIEM_TOAN |  |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | SCMS.CT_KIEM_TOAN |  |  |


#### 2.{IDX}.46.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Audit Firm | Audit Firm Id | audt_firm_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.47 Bảng Involved Party Electronic Address — SCMS.CT_KIEM_TOAN

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Audit Firm. | SCMS.CT_KIEM_TOAN | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty kiểm toán. | SCMS.CT_KIEM_TOAN | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CT_KIEM_TOAN' | Mã nguồn dữ liệu. | SCMS.CT_KIEM_TOAN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. | SCMS.CT_KIEM_TOAN |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Email. | SCMS.CT_KIEM_TOAN | EMAIL |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Audit Firm. | SCMS.CT_KIEM_TOAN | ID |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty kiểm toán. | SCMS.CT_KIEM_TOAN | ID |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CT_KIEM_TOAN' | Mã nguồn dữ liệu. | SCMS.CT_KIEM_TOAN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. | SCMS.CT_KIEM_TOAN |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số fax. | SCMS.CT_KIEM_TOAN | FAX |  |
| 11 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Audit Firm. | SCMS.CT_KIEM_TOAN | ID |  |
| 12 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty kiểm toán. | SCMS.CT_KIEM_TOAN | ID |  |
| 13 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CT_KIEM_TOAN' | Mã nguồn dữ liệu. | SCMS.CT_KIEM_TOAN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 14 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. | SCMS.CT_KIEM_TOAN |  |  |
| 15 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | SCMS.CT_KIEM_TOAN | DIEN_THOAI |  |
| 16 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Audit Firm. | SCMS.CT_KIEM_TOAN | ID |  |
| 17 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty kiểm toán. | SCMS.CT_KIEM_TOAN | ID |  |
| 18 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CT_KIEM_TOAN' | Mã nguồn dữ liệu. | SCMS.CT_KIEM_TOAN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 19 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. | SCMS.CT_KIEM_TOAN |  |  |
| 20 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Website. | SCMS.CT_KIEM_TOAN | WEBSITE |  |


#### 2.{IDX}.47.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Audit Firm | Audit Firm Id | audt_firm_id |




### 2.{IDX}.48 Bảng Involved Party Alternative Identification — SCMS.CTCK_THONG_TIN

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán. | SCMS.CTCK_THONG_TIN | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. | SCMS.CTCK_THONG_TIN | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_THONG_TIN' | Mã nguồn dữ liệu. | SCMS.CTCK_THONG_TIN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'BUSINESS_LICENSE' | Loại định danh — giấy phép kinh doanh. | SCMS.CTCK_THONG_TIN |  | Scheme: IP_ALT_ID_TYPE. ETL-derived: hardcode BUSINESS_LICENSE. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. | SCMS.CTCK_THONG_TIN | GIAY_PHEP_KINH_DOANH |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép kinh doanh. | SCMS.CTCK_THONG_TIN | NGAY_CAP_GPKD |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy phép kinh doanh. | SCMS.CTCK_THONG_TIN | NOI_CAP_GPKD |  |


#### 2.{IDX}.48.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Company | Securities Company Id | scr_co_id |




### 2.{IDX}.49 Bảng Involved Party Postal Address — SCMS.CTCK_PHONG_GIAO_DICH

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến phòng giao dịch. | SCMS.CTCK_PHONG_GIAO_DICH | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã phòng giao dịch. | SCMS.CTCK_PHONG_GIAO_DICH | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_PHONG_GIAO_DICH' | Mã nguồn dữ liệu. | SCMS.CTCK_PHONG_GIAO_DICH |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. | SCMS.CTCK_PHONG_GIAO_DICH |  | Scheme: IP_ADDR_TYPE. ETL-derived: hardcode HEAD_OFFICE. |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở đại lý phân phối quỹ. | SCMS.CTCK_PHONG_GIAO_DICH |  |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố. | SCMS.CTCK_PHONG_GIAO_DICH | TINH_THANH_ID |  |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành phố. | SCMS.CTCK_PHONG_GIAO_DICH | TINH_THANH_ID |  |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện. | SCMS.CTCK_PHONG_GIAO_DICH | QUAN_HUYEN |  |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã. | SCMS.CTCK_PHONG_GIAO_DICH | PHUONG_XA |  |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | SCMS.CTCK_PHONG_GIAO_DICH |  |  |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | SCMS.CTCK_PHONG_GIAO_DICH |  |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ phòng giao dịch. | SCMS.CTCK_PHONG_GIAO_DICH | DIA_CHI |  |


#### 2.{IDX}.49.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Company Organization Unit | Securities Company Organization Unit Id | scr_co_ou_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.50 Bảng Involved Party Electronic Address — SCMS.CTCK_PHONG_GIAO_DICH

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến phòng giao dịch. | SCMS.CTCK_PHONG_GIAO_DICH | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã phòng giao dịch. | SCMS.CTCK_PHONG_GIAO_DICH | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_PHONG_GIAO_DICH' | Mã nguồn dữ liệu. | SCMS.CTCK_PHONG_GIAO_DICH |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. | SCMS.CTCK_PHONG_GIAO_DICH |  | Scheme: IP_ELEC_ADDR_TYPE. ETL-derived. |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số fax. | SCMS.CTCK_PHONG_GIAO_DICH | FAX |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến phòng giao dịch. | SCMS.CTCK_PHONG_GIAO_DICH | ID |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã phòng giao dịch. | SCMS.CTCK_PHONG_GIAO_DICH | ID |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_PHONG_GIAO_DICH' | Mã nguồn dữ liệu. | SCMS.CTCK_PHONG_GIAO_DICH |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. | SCMS.CTCK_PHONG_GIAO_DICH |  | Scheme: IP_ELEC_ADDR_TYPE. ETL-derived. |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | SCMS.CTCK_PHONG_GIAO_DICH | DIEN_THOAI |  |


#### 2.{IDX}.50.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Company Organization Unit | Securities Company Organization Unit Id | scr_co_ou_id |




### 2.{IDX}.51 Bảng Involved Party Postal Address — SCMS.CTCK_VP_DAI_DIEN

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến văn phòng đại diện. | SCMS.CTCK_VP_DAI_DIEN | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã văn phòng đại diện. | SCMS.CTCK_VP_DAI_DIEN | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_VP_DAI_DIEN' | Mã nguồn dữ liệu. | SCMS.CTCK_VP_DAI_DIEN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. | SCMS.CTCK_VP_DAI_DIEN |  | Scheme: IP_ADDR_TYPE. ETL-derived: hardcode HEAD_OFFICE. |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở đại lý phân phối quỹ. | SCMS.CTCK_VP_DAI_DIEN |  |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố. | SCMS.CTCK_VP_DAI_DIEN | TINH_THANH_ID |  |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành phố. | SCMS.CTCK_VP_DAI_DIEN | TINH_THANH_ID |  |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện. | SCMS.CTCK_VP_DAI_DIEN | QUAN_HUYEN |  |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã. | SCMS.CTCK_VP_DAI_DIEN | PHUONG_XA |  |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | SCMS.CTCK_VP_DAI_DIEN |  |  |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | SCMS.CTCK_VP_DAI_DIEN |  |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | SCMS.CTCK_VP_DAI_DIEN | DIA_CHI |  |


#### 2.{IDX}.51.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Company Organization Unit | Securities Company Organization Unit Id | scr_co_ou_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.52 Bảng Involved Party Electronic Address — SCMS.CTCK_VP_DAI_DIEN

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến văn phòng đại diện. | SCMS.CTCK_VP_DAI_DIEN | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã văn phòng đại diện. | SCMS.CTCK_VP_DAI_DIEN | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_VP_DAI_DIEN' | Mã nguồn dữ liệu. | SCMS.CTCK_VP_DAI_DIEN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. | SCMS.CTCK_VP_DAI_DIEN |  | Scheme: IP_ELEC_ADDR_TYPE. ETL-derived. |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số fax. | SCMS.CTCK_VP_DAI_DIEN | FAX |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến văn phòng đại diện. | SCMS.CTCK_VP_DAI_DIEN | ID |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã văn phòng đại diện. | SCMS.CTCK_VP_DAI_DIEN | ID |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_VP_DAI_DIEN' | Mã nguồn dữ liệu. | SCMS.CTCK_VP_DAI_DIEN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. | SCMS.CTCK_VP_DAI_DIEN |  | Scheme: IP_ELEC_ADDR_TYPE. ETL-derived. |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | SCMS.CTCK_VP_DAI_DIEN | DIEN_THOAI |  |


#### 2.{IDX}.52.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Company Organization Unit | Securities Company Organization Unit Id | scr_co_ou_id |




