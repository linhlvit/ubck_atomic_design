## 2.{IDX} ThanhTra — 

### 2.{IDX}.1 Các mô hình quan hệ dữ liệu

- DBML tổng hợp (tất cả bảng): [`ThanhTra.dbml`](ThanhTra.dbml) — paste vào https://dbdiagram.io để render.
- Diagram theo mảng nghiệp vụ:
  - **UID01 — Hoạt động thanh tra - kiểm tra**: [`ThanhTra_UID01.dbml`](ThanhTra_UID01.dbml)
  - **UID02 — Xử lý vi phạm hành chính**: [`ThanhTra_UID02.dbml`](ThanhTra_UID02.dbml)
  - **UID03 — Tiếp công dân, xử lý đơn thư**: [`ThanhTra_UID03.dbml`](ThanhTra_UID03.dbml)
  - **UID04 — Phòng chống tham nhũng, tiêu cực**: [`ThanhTra_UID04.dbml`](ThanhTra_UID04.dbml)
  - **UID05 — Phòng chống rửa tiền, tài trợ khủng bố**: [`ThanhTra_UID05.dbml`](ThanhTra_UID05.dbml)
  - **UID08 — Quản trị phân hệ**: [`ThanhTra_UID08.dbml`](ThanhTra_UID08.dbml)


**Danh sách bảng:**

| STT | Thực thể | Tên bảng | Mô tả |
|---|---|---|---|
| 1 | Inspection Officer | inspection_ofcr | Cán bộ thanh tra viên thuộc UBCKNN. Ghi nhận thông tin cá nhân và trạng thái công tác. |
| 2 | Involved Party Electronic Address | ip_elc_adr | Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn. |
| 3 | Involved Party Postal Address | ip_pst_adr | Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn. |
| 4 | Public Company | pblc_co | Công ty đại chúng được UBCKNN quản lý. Lưu thông tin pháp lý và trạng thái hoạt động. |
| 5 | Securities Company | scr_co | Công ty chứng khoán - thành viên thị trường trong hệ thống FIMS. Quản lý tài khoản và danh mục NĐT nước ngoài. |
| 6 | Fund Management Company | fnd_mgt_co | Công ty quản lý quỹ đầu tư chứng khoán trong nước được UBCKNN cấp phép hoạt động. Lưu thông tin pháp lý và hoạt động của công ty. |
| 7 | Inspection Subject Other Party | inspection_sbj_othr_p | Đối tượng thanh tra khác (cá nhân hoặc tổ chức) không thuộc danh mục CK/QLQ/ĐC. Phân biệt qua party_type_code. |
| 8 | Inspection Annual Plan | inspection_anul_pln | Kế hoạch thanh tra kiểm tra cấp năm được phê duyệt. Khởi đầu quy trình thanh tra trong năm. |
| 9 | Surveillance Enforcement Case | surveillance_enforcement_case | Hồ sơ xử lý vi phạm từ kết quả giám sát thị trường. Ghi nhận đối tượng và trạng thái xử lý. |
| 10 | Complaint Petition | cpln_petition | Đơn thư khiếu nại/tố cáo/phản ánh/kiến nghị nhận từ công dân hoặc tổ chức. Khởi đầu quy trình giải quyết đơn thư. |
| 11 | AML Enforcement Case | aml_enforcement_case | Hồ sơ xử lý vi phạm phòng chống rửa tiền. Ghi nhận đối tượng vi phạm và trạng thái xử lý. |
| 12 | Anti-Corruption Report | anti-corruption_rpt | Báo cáo tổng hợp định kỳ về hoạt động phòng chống tham nhũng. Mỗi dòng = 1 lần lập báo cáo. |
| 13 | AML Periodic Report | aml_prd_rpt | Báo cáo định kỳ về hoạt động phòng chống rửa tiền. Mỗi dòng = 1 lần lập báo cáo. |
| 14 | Inspection Annual Plan Subject | inspection_anul_pln_sbj | Đối tượng thanh tra được đưa vào kế hoạch năm. Grain: 1 đối tượng × 1 kế hoạch. |
| 15 | Inspection Annual Plan Document Attachment | inspection_anul_pln_doc_attachment | Văn bản đính kèm kế hoạch thanh tra năm. FK → Inspection Annual Plan. |
| 16 | Inspection Decision | inspection_dcsn | Quyết định thanh tra/kiểm tra cụ thể. FK → Inspection Annual Plan (nullable — thanh tra đột xuất không có kế hoạch). |
| 17 | Complaint Processing Case | cpln_pcs_case | Hồ sơ giải quyết đơn thư khiếu nại/tố cáo. FK → Complaint Petition. |
| 18 | Surveillance Case Document Attachment | surveillance_case_doc_attachment | Văn bản đính kèm hồ sơ giám sát. FK → Surveillance Enforcement Case. |
| 19 | Surveillance Enforcement Decision | surveillance_enforcement_dcsn | Văn bản xử lý vi phạm từ giám sát. FK → Surveillance Enforcement Case. |
| 20 | AML Case Document Attachment | aml_case_doc_attachment | Văn bản đính kèm hồ sơ PCRT. FK → AML Enforcement Case. |
| 21 | AML Enforcement Decision | aml_enforcement_dcsn | Văn bản xử lý vi phạm rửa tiền. FK → AML Enforcement Case. |
| 22 | Inspection Decision Subject | inspection_dcsn_sbj | Đối tượng cụ thể được thanh tra theo một quyết định. FK → Inspection Decision. |
| 23 | Inspection Decision Team Member | inspection_dcsn_team_mbr | Thành viên đoàn thanh tra chỉ định theo quyết định. FK → Inspection Decision + FK → Inspection Officer. |
| 24 | Inspection Decision Document Attachment | inspection_dcsn_doc_attachment | Văn bản đính kèm quyết định thanh tra. FK → Inspection Decision. |
| 25 | Inspection Case | inspection_case | Hồ sơ thanh tra cụ thể — tập hợp tài liệu và kết quả 1 cuộc thanh tra. FK → Inspection Decision. Thông tin đối tượng denormalized (snapshot tại thời điểm thanh tra). |
| 26 | Complaint Processing Case Document Attachment | cpln_pcs_case_doc_attachment | Văn bản đính kèm hồ sơ giải quyết đơn thư. FK → Complaint Processing Case. |
| 27 | Complaint Processing Conclusion | cpln_pcs_conclusion | Kết luận giải quyết đơn thư. FK → Complaint Processing Case. |
| 28 | Complaint Enforcement Decision | cpln_enforcement_dcsn | Văn bản xử lý / quyết định xử phạt từ hồ sơ đơn thư. FK → Complaint Processing Case. |
| 29 | Surveillance Enforcement Decision File Attachment | surveillance_enforcement_dcsn_file_attachment | File đính kèm văn bản xử lý giám sát. FK → Surveillance Enforcement Decision. |
| 30 | Surveillance Penalty Announcement | surveillance_pny_ancm | Công bố quyết định xử phạt từ giám sát. FK → Surveillance Enforcement Decision. |
| 31 | Inspection Case Officer Assignment | inspection_case_ofcr_asgnm | Phân công cán bộ phụ trách hồ sơ thanh tra. FK → Inspection Case + FK → Inspection Officer. |
| 32 | Inspection Case Document Attachment | inspection_case_doc_attachment | Văn bản đính kèm hồ sơ thanh tra (biên bản làm việc v.v.). FK → Inspection Case. |
| 33 | Inspection Case Conclusion | inspection_case_conclusion | Kết luận thanh tra kèm thông tin xử lý vi phạm. FK → Inspection Case. |
| 34 | Complaint Penalty Announcement | cpln_pny_ancm | Công bố quyết định xử phạt từ hồ sơ đơn thư. FK → Complaint Enforcement Decision. |
| 35 | Inspection Penalty Announcement | inspection_pny_ancm | Công bố quyết định xử phạt từ kết luận thanh tra. FK → Inspection Case Conclusion. |



### 2.{IDX}.2 Bảng Inspection Officer

- **Mô tả:** Cán bộ thanh tra viên thuộc UBCKNN. Ghi nhận thông tin cá nhân và trạng thái công tác.
- **Tên vật lý:** inspection_ofcr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Inspection Officer Id | inspection_ofcr_id | BIGINT |  | X | P |  | Khóa đại diện cho cán bộ thanh tra. | ThanhTra | DM_CAN_BO |  |  |
| 2 | Inspection Officer Code | inspection_ofcr_code | STRING |  |  |  |  | Mã cán bộ thanh tra. Map từ PK bảng nguồn ThanhTra.DM_CAN_BO.ID. | ThanhTra | DM_CAN_BO | ID | BK của entity. BCV Term: Individual Identifier. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DM_CAN_BO |  |  |
| 4 | Login Name | login_nm | STRING | X |  |  |  | Tên đăng nhập, liên kết tài khoản hệ thống nội bộ. | ThanhTra | DM_CAN_BO | TEN_DANG_NHAP |  |
| 5 | Full Name | full_nm | STRING |  |  |  |  | Họ và tên cán bộ thanh tra. | ThanhTra | DM_CAN_BO | HO_VA_TEN |  |
| 6 | Date of Birth | dob | DATE | X |  |  |  | Ngày sinh cán bộ. | ThanhTra | DM_CAN_BO | NGAY_SINH |  |
| 7 | Gender Code | gnd_code | STRING | X |  |  |  | Giới tính: NAM / NU. | ThanhTra | DM_CAN_BO | GIOI_TINH | Scheme: INDIVIDUAL_GENDER. |
| 8 | Supervised Company Name | supervised_co_nm | STRING | X |  |  |  | Công ty phụ trách (tên công ty — denormalized, không có FK). | ThanhTra | DM_CAN_BO | CONG_TY_PHU_TRACH |  |
| 9 | Officer Status Code | ofcr_st_code | STRING |  |  |  |  | Trạng thái cán bộ: SU_DUNG / KHONG_SU_DUNG. | ThanhTra | DM_CAN_BO | TRANG_THAI | Scheme: TT_OFFICER_STATUS. |


#### 2.{IDX}.2.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Inspection Officer Id | inspection_ofcr_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.3 Bảng Involved Party Electronic Address — ThanhTra.DM_CAN_BO

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Inspection Officer. | ThanhTra | DM_CAN_BO | ID | FK target: Inspection Officer.Inspection Officer Id. |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã cán bộ thanh tra. | ThanhTra | DM_CAN_BO | ID | Lookup pair: Inspection Officer.Inspection Officer Code. Pair with Involved Party Id. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DM_CAN_BO |  |  |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — email. | ThanhTra | DM_CAN_BO |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Email cán bộ. | ThanhTra | DM_CAN_BO | EMAIL |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Inspection Officer. | ThanhTra | DM_CAN_BO | ID | FK target: Inspection Officer.Inspection Officer Id. |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã cán bộ thanh tra. | ThanhTra | DM_CAN_BO | ID | Lookup pair: Inspection Officer.Inspection Officer Code. Pair with Involved Party Id. |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DM_CAN_BO |  |  |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — điện thoại. | ThanhTra | DM_CAN_BO |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại cán bộ. | ThanhTra | DM_CAN_BO | DIEN_THOAI |  |


#### 2.{IDX}.3.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Inspection Officer | Inspection Officer Id | inspection_ofcr_id |




### 2.{IDX}.4 Bảng Involved Party Postal Address — ThanhTra.DM_CAN_BO

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Inspection Officer. | ThanhTra | DM_CAN_BO | ID | FK target: Inspection Officer.Inspection Officer Id. |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã cán bộ thanh tra. | ThanhTra | DM_CAN_BO | ID | Lookup pair: Inspection Officer.Inspection Officer Code. Pair with Involved Party Id. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DM_CAN_BO |  |  |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ — địa chỉ hiện tại. | ThanhTra | DM_CAN_BO |  |  |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ cán bộ. | ThanhTra | DM_CAN_BO | DIA_CHI |  |
| 6 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | ThanhTra | DM_CAN_BO |  | Text tự do — denormalized. |


#### 2.{IDX}.4.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Inspection Officer | Inspection Officer Id | inspection_ofcr_id |




### 2.{IDX}.5 Bảng Public Company

- **Mô tả:** Công ty đại chúng được UBCKNN quản lý. Lưu thông tin pháp lý và trạng thái hoạt động.
- **Tên vật lý:** pblc_co
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Public Company Id | pblc_co_id | BIGINT |  | X | P |  | Khóa đại diện cho công ty đại chúng. | ThanhTra | DM_CONG_TY_DC |  |  |
| 2 | Public Company Code | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. Map từ PK ThanhTra.DM_CONG_TY_DC.ID. | ThanhTra | DM_CONG_TY_DC | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DM_CONG_TY_DC |  |  |
| 4 | Public Company Name | pblc_co_nm | STRING |  |  |  |  | Tên tiếng Việt công ty đại chúng. | ThanhTra | DM_CONG_TY_DC | TEN_TIENG_VIET |  |
| 5 | Public Company English Name | pblc_co_english_nm | STRING | X |  |  |  | Tên tiếng Anh công ty đại chúng. | ThanhTra | DM_CONG_TY_DC | TEN_TIENG_ANH |  |
| 6 | Public Company Short Name | pblc_co_shrt_nm | STRING | X |  |  |  | Tên viết tắt công ty đại chúng. | ThanhTra | DM_CONG_TY_DC | TEN_VIET_TAT |  |
| 7 | Company Type Code | co_tp_code | STRING | X |  |  |  | Loại hình công ty. | ThanhTra | DM_CONG_TY_DC | LOAI_HINH_CONG_TY | Scheme: TT_COMPANY_TYPE. |
| 8 | Charter Capital Amount | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ. | ThanhTra | DM_CONG_TY_DC | VON_DIEU_LE |  |
| 9 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. | ThanhTra | DM_CONG_TY_DC | TRANG_THAI_HOAT_DONG | Scheme: LIFE_CYCLE_STATUS. |
| 10 | Business License Number | bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. | ThanhTra | DM_CONG_TY_DC | GIAY_PHEP_KINH_DOANH |  |
| 11 | Website | webst | STRING | X |  |  |  | Website chính thức. | ThanhTra | DM_CONG_TY_DC | WEBSITE |  |
| 12 | Business Registration Number | bsn_rgst_nbr | STRING | X |  |  |  | Mã số doanh nghiệp / số ĐKKD. | ThanhTra | DM_CONG_TY_DC |  | company_detail.business_reg_no cùng giá trị (1-1) — map primary từ company_profiles. |
| 13 | First Registration Date | frst_rgst_dt | DATE | X |  |  |  | Ngày đăng ký lần đầu. | ThanhTra | DM_CONG_TY_DC |  |  |
| 14 | Latest Registration Date | latest_rgst_dt | DATE | X |  |  |  | Ngày cấp gần nhất. | ThanhTra | DM_CONG_TY_DC |  |  |
| 15 | Latest Registration Province Code | latest_rgst_prov_code | STRING | X |  |  |  | Tỉnh/thành nơi cấp gần nhất (mã tỉnh từ provinces). | ThanhTra | DM_CONG_TY_DC |  | Text denormalized — provinces là reference data set chưa map vào shared Geographic Area trong scope IDS. |
| 16 | Industry Category Id | idy_cgy_id | BIGINT | X |  | F |  | Id ngành nghề (categories). | ThanhTra | DM_CONG_TY_DC |  | FK target: categories — Classification Value scheme IDS_INDUSTRY_CATEGORY (theo HLD). Giữ Id để truy lại categories khi cần. Cặp Id+Code theo pattern. |
| 17 | Industry Category Code | idy_cgy_code | STRING | X |  |  |  | Mã ngành nghề (categories). | ThanhTra | DM_CONG_TY_DC |  | Scheme: IDS_INDUSTRY_CATEGORY. Pair with Industry Category Id. Theo HLD T1-04: categories là Classification Value không phải Silver entity. |
| 18 | Industry Category Level1 Code | idy_cgy_level1_code | STRING | X |  |  |  | Ngành nghề cấp 1 (mã categories cấp 1). | ThanhTra | DM_CONG_TY_DC |  | Scheme: IDS_INDUSTRY_CATEGORY. Cùng scheme với Industry Category Code — denormalize cấp 1. |
| 19 | Industry Category Level2 Code | idy_cgy_level2_code | STRING | X |  |  |  | Ngành nghề cấp 2 (mã categories cấp 2). | ThanhTra | DM_CONG_TY_DC |  | Scheme: IDS_INDUSTRY_CATEGORY. Cùng scheme với Industry Category Code — denormalize cấp 2. |
| 20 | IDS Status Code | ids_st_code | STRING | X |  |  |  | Trạng thái niêm yết IDS. | ThanhTra | DM_CONG_TY_DC |  | Scheme: IDS_COMPANY_STATUS. |
| 21 | Auto Approval Flag | auto_aprv_f | BOOLEAN | X |  |  |  | Tự động duyệt (1=tự động / 0=không). | ThanhTra | DM_CONG_TY_DC |  |  |
| 22 | Company Login | co_login | STRING | X |  |  |  | User của công ty niêm yết (login_name). | ThanhTra | DM_CONG_TY_DC |  | Denormalized text — logins là bảng hệ thống out-of-scope. |
| 23 | Approver Comment | approver_cmnt | STRING | X |  |  |  | Ý kiến người duyệt. | ThanhTra | DM_CONG_TY_DC |  |  |
| 24 | Parent Company Flag | prn_co_f | BOOLEAN | X |  |  |  | Là công ty mẹ (1=có / 0=không). | ThanhTra | DM_CONG_TY_DC |  |  |
| 25 | Equity Listing Exchange Code | eqty_listing_exg_code | STRING | X |  |  |  | Sàn niêm yết cổ phiếu (HNX/HOSE/UPCoM). | ThanhTra | DM_CONG_TY_DC |  | Scheme: IDS_EQUITY_LISTING_EXCH. Trùng nội dung với company_detail.equity_listing_exch (Text denormalized) — chọn cd làm primary. |
| 26 | Equity Listing Exchange Name | eqty_listing_exg_nm | STRING | X |  |  |  | Sàn niêm yết cổ phiếu (text từ company_detail). | ThanhTra | DM_CONG_TY_DC |  | Denormalized text từ company_detail — không có scheme. |
| 27 | Bond Listing Exchange Name | bond_listing_exg_nm | STRING | X |  |  |  | Sàn niêm yết trái phiếu (text từ company_detail). | ThanhTra | DM_CONG_TY_DC |  | Denormalized text từ company_detail — không có scheme. |
| 28 | Equity Security Flag | eqty_scr_f | BOOLEAN | X |  |  |  | Loại chứng khoán niêm yết là cổ phiếu (1=có / 0=không). | ThanhTra | DM_CONG_TY_DC |  |  |
| 29 | Bond Security Flag | bond_scr_f | BOOLEAN | X |  |  |  | Loại chứng khoán niêm yết là trái phiếu (1=có / 0=không). | ThanhTra | DM_CONG_TY_DC |  |  |
| 30 | Equity Ticker | eqty_ticker | STRING | X |  |  |  | Mã chứng khoán cổ phiếu. | ThanhTra | DM_CONG_TY_DC |  | company_detail.equity_ticker cùng giá trị (1-1) — map primary từ company_profiles. |
| 31 | Bond Ticker | bond_ticker | STRING | X |  |  |  | Mã chứng khoán trái phiếu. | ThanhTra | DM_CONG_TY_DC |  |  |
| 32 | Equity Listed Quantity | eqty_list_qty | INT | X |  |  |  | Số lượng cổ phiếu đang niêm yết. | ThanhTra | DM_CONG_TY_DC |  |  |
| 33 | Bond Listed Quantity | bond_list_qty | INT | X |  |  |  | Số lượng trái phiếu đang niêm yết. | ThanhTra | DM_CONG_TY_DC |  |  |
| 34 | International Exchange Name | itnl_exg_nm | STRING | X |  |  |  | Sàn niêm yết quốc tế. | ThanhTra | DM_CONG_TY_DC |  |  |
| 35 | International Ticker | itnl_ticker | STRING | X |  |  |  | Mã chứng quốc tế. | ThanhTra | DM_CONG_TY_DC |  |  |
| 36 | ISIN Code | isin_code | STRING | X |  |  |  | Mã ISIN. | ThanhTra | DM_CONG_TY_DC |  |  |
| 37 | Securities Type Code | scr_tp_code | STRING | X |  |  |  | Loại chứng khoán phát hành. | ThanhTra | DM_CONG_TY_DC |  | Scheme: IDS_SECURITIES_TYPE. |
| 38 | Public Company Form Code | pblc_co_form_code | STRING | X |  |  |  | Hình thức trở thành công ty đại chúng (IPO / nộp hồ sơ trực tiếp). | ThanhTra | DM_CONG_TY_DC |  | Scheme: IDS_PUBLIC_COMPANY_FORM. |
| 39 | Capital Paid Reported Amount | cptl_paid_rpt_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ thực góp (cập nhật theo BCTC năm). | ThanhTra | DM_CONG_TY_DC |  |  |
| 40 | Treasury Shares Quantity | trsr_shr_qty | INT | X |  |  |  | Cổ phiếu quỹ hiện có. | ThanhTra | DM_CONG_TY_DC |  |  |
| 41 | Fiscal Year Start Date | fyr_strt_dt | DATE | X |  |  |  | Ngày bắt đầu năm tài chính. | ThanhTra | DM_CONG_TY_DC |  |  |
| 42 | Fiscal Year End Date | fyr_end_dt | DATE | X |  |  |  | Ngày kết thúc năm tài chính. | ThanhTra | DM_CONG_TY_DC |  |  |
| 43 | Financial Statement Type Code | fnc_stmt_tp_code | STRING | X |  |  |  | Loại báo cáo tài chính (IFRS/VAS...). | ThanhTra | DM_CONG_TY_DC |  | Scheme: IDS_FINANCIAL_STMT_TYPE. |
| 44 | IDS Registration Flag | ids_rgst_f | BOOLEAN | X |  |  |  | Trạng thái đăng ký trên IDS (1=đã đăng ký / 0=chưa). | ThanhTra | DM_CONG_TY_DC |  |  |
| 45 | IDS Registration Date | ids_rgst_dt | DATE | X |  |  |  | Ngày đăng ký trên IDS. | ThanhTra | DM_CONG_TY_DC |  |  |
| 46 | Public Company Flag | pblc_co_f | BOOLEAN | X |  |  |  | Là công ty đại chúng (1=có / 0=không). | ThanhTra | DM_CONG_TY_DC |  |  |
| 47 | Public Bond Issuer Flag | pblc_bond_issur_f | BOOLEAN | X |  |  |  | Là tổ chức niêm yết trái phiếu (1=có / 0=không). | ThanhTra | DM_CONG_TY_DC |  |  |
| 48 | Large Public Company Flag | lrg_pblc_co_f | BOOLEAN | X |  |  |  | Là công ty đại chúng quy mô lớn (1=có / 0=không). | ThanhTra | DM_CONG_TY_DC |  |  |
| 49 | Former State Owned Flag | formr_ste_own_f | BOOLEAN | X |  |  |  | Tiền thân là doanh nghiệp nhà nước (1=có / 0=không). | ThanhTra | DM_CONG_TY_DC |  |  |
| 50 | Equitisation License Date | equitisation_license_dt | DATE | X |  |  |  | Ngày được cấp GPKD sau cổ phần hóa. | ThanhTra | DM_CONG_TY_DC |  |  |
| 51 | Capital At Equitisation Amount | cptl_at_equitisation_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ thực góp tại thời điểm cổ phần hóa. | ThanhTra | DM_CONG_TY_DC |  |  |
| 52 | Has State Own Flag | has_ste_own_f | BOOLEAN | X |  |  |  | Có vốn nhà nước (1=có / 0=không). | ThanhTra | DM_CONG_TY_DC |  |  |
| 53 | FDI Company Flag | fdi_co_f | BOOLEAN | X |  |  |  | Là doanh nghiệp FDI (1=có / 0=không). | ThanhTra | DM_CONG_TY_DC |  |  |
| 54 | Has Parent Company Flag | has_prn_co_f | BOOLEAN | X |  |  |  | Có công ty mẹ (1=có / 0=không). | ThanhTra | DM_CONG_TY_DC |  |  |
| 55 | Has Subsidiaries Flag | has_subs_f | BOOLEAN | X |  |  |  | Có công ty con (1=có / 0=không). | ThanhTra | DM_CONG_TY_DC |  |  |
| 56 | Has Joint Ventures Flag | has_jnt_ventures_f | BOOLEAN | X |  |  |  | Có công ty liên doanh, liên kết (1=có / 0=không). | ThanhTra | DM_CONG_TY_DC |  |  |
| 57 | Enterprise Type Code | entp_tp_code | STRING | X |  |  |  | Loại hình doanh nghiệp (bh/td/ck/dn). | ThanhTra | DM_CONG_TY_DC |  | Scheme: IDS_ENTERPRISE_TYPE. company_detail.report_type_cd cùng giá trị (1-1) — map primary từ company_profiles. |
| 58 | Specialist Notes | spcl_notes | STRING | X |  |  |  | Ghi chú của chuyên viên. | ThanhTra | DM_CONG_TY_DC |  |  |
| 59 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | ThanhTra | DM_CONG_TY_DC |  | Denormalized — logins là bảng hệ thống out-of-scope. Audit từ company_detail là 1-1 với company_profiles. |
| 60 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | ThanhTra | DM_CONG_TY_DC |  | Audit từ company_detail là 1-1 với company_profiles. |
| 61 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | ThanhTra | DM_CONG_TY_DC |  | Denormalized — logins là bảng hệ thống out-of-scope. |
| 62 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | ThanhTra | DM_CONG_TY_DC |  |  |


#### 2.{IDX}.5.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Public Company Id | pblc_co_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.6 Bảng Involved Party Electronic Address — ThanhTra.DM_CONG_TY_DC

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Public Company. | ThanhTra | DM_CONG_TY_DC | ID | FK target: Public Company.Public Company Id. |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty đại chúng. | ThanhTra | DM_CONG_TY_DC | ID | Lookup pair: Public Company.Public Company Code. Pair with Involved Party Id. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DM_CONG_TY_DC |  |  |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — email. | ThanhTra | DM_CONG_TY_DC |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Email. | ThanhTra | DM_CONG_TY_DC | EMAIL |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Public Company. | ThanhTra | DM_CONG_TY_DC | ID | FK target: Public Company.Public Company Id. |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty đại chúng. | ThanhTra | DM_CONG_TY_DC | ID | Lookup pair: Public Company.Public Company Code. Pair with Involved Party Id. |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DM_CONG_TY_DC |  |  |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — điện thoại. | ThanhTra | DM_CONG_TY_DC |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | ThanhTra | DM_CONG_TY_DC | DIEN_THOAI |  |


#### 2.{IDX}.6.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Public Company | Public Company Id | pblc_co_id |




### 2.{IDX}.7 Bảng Involved Party Postal Address — ThanhTra.DM_CONG_TY_DC

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Public Company. | ThanhTra | DM_CONG_TY_DC | ID | FK target: Public Company.Public Company Id. |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty đại chúng. | ThanhTra | DM_CONG_TY_DC | ID | Lookup pair: Public Company.Public Company Code. Pair with Involved Party Id. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DM_CONG_TY_DC |  |  |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ — trụ sở chính. | ThanhTra | DM_CONG_TY_DC |  |  |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở chính. | ThanhTra | DM_CONG_TY_DC | DIA_CHI |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | ThanhTra | DM_CONG_TY_DC |  | FK target: Geographic Area.Geographic Area Id. Lookup: DM_TINH_THANH. |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). | ThanhTra | DM_CONG_TY_DC |  | Lookup pair: Geographic Area.Geographic Area Code. Pair with Province Id. // Text denormalized — provinces là reference data set chưa map vào shared Geographic Area trong scope IDS. |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. | ThanhTra | DM_CONG_TY_DC |  | Text denormalized — không có bảng lookup quận/huyện trong scope. |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. | ThanhTra | DM_CONG_TY_DC |  | Text denormalized. |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | ThanhTra | DM_CONG_TY_DC |  | FK target: Geographic Area.Geographic Area Id. |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | ThanhTra | DM_CONG_TY_DC |  | Lookup pair: Geographic Area.Geographic Area Code. Pair with Geographic Area Id. |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | ThanhTra | DM_CONG_TY_DC |  | Text tự do — denormalized. |


#### 2.{IDX}.7.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Public Company | Public Company Id | pblc_co_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.8 Bảng Securities Company

- **Mô tả:** Công ty chứng khoán - thành viên thị trường trong hệ thống FIMS. Quản lý tài khoản và danh mục NĐT nước ngoài.
- **Tên vật lý:** scr_co
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Securities Company Id | scr_co_id | BIGINT |  | X | P |  | Khóa đại diện cho công ty chứng khoán. | ThanhTra | DM_CONG_TY_CK |  |  |
| 2 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. Map từ PK ThanhTra.DM_CONG_TY_CK.ID. | ThanhTra | DM_CONG_TY_CK | ID | BK của entity — source ThanhTra.DM_CONG_TY_CK. Entity Securities Company cũng có source từ FIMS.SECURITIESCOMPANY và SCMS.CTCK_THONG_TIN. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DM_CONG_TY_CK |  |  |
| 4 | Country of Registration Id | cty_of_rgst_id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký của công ty chứng khoán. | ThanhTra | DM_CONG_TY_CK |  | FK target: Geographic Area.Geographic Area Id. ID quốc gia lấy từ bảng NATIONAL. // FK target: Geographic Area.Geographic Area Id. Lookup: DM_QUOC_TICH. |
| 5 | Country of Registration Code | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. | ThanhTra | DM_CONG_TY_CK |  | Lookup pair: Geographic Area.Geographic Area Code. Pair with Country of Registration Id. |
| 6 | Full Name | full_nm | STRING |  |  |  |  | Tên công ty chứng khoán. | ThanhTra | DM_CONG_TY_CK |  |  |
| 7 | English Name | english_nm | STRING | X |  |  |  | Tên tiếng Anh. | ThanhTra | DM_CONG_TY_CK |  |  |
| 8 | Abbreviation | abr | STRING | X |  |  |  | Tên viết tắt. | ThanhTra | DM_CONG_TY_CK |  |  |
| 9 | Charter Capital Amount | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ. | ThanhTra | DM_CONG_TY_CK | VON_DIEU_LE |  |
| 10 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. | ThanhTra | DM_CONG_TY_CK | TRANG_THAI_HOAT_DONG | Scheme: LIFE_CYCLE_STATUS. |
| 11 | Director Name | director_nm | STRING | X |  |  |  | Tên Tổng giám đốc (denormalized). | ThanhTra | DM_CONG_TY_CK |  | Denormalized snapshot — không dùng để join. |
| 12 | Depository Certificate Number | depst_ctf_nbr | STRING | X |  |  |  | Chứng nhận lưu ký. | ThanhTra | DM_CONG_TY_CK |  |  |
| 13 | Business Type Codes | bsn_tp_codes | Array<Text> | X |  |  |  | Danh sách mã nghiệp vụ kinh doanh. Từ bảng junction SECCOMBUSINES. | ThanhTra | DM_CONG_TY_CK |  | Pure junction SECCOMBUSINES → denormalize thành ARRAY. Scheme: FIMS_BUSINESS_TYPE. HLD decision: FIMS_HLD_Tier1.md. |
| 14 | Company Type Codes | co_tp_codes | Array<Text> | X |  |  |  | Danh sách mã loại hình doanh nghiệp. Từ bảng junction SECCOMTYPE. | ThanhTra | DM_CONG_TY_CK |  | Pure junction SECCOMTYPE → denormalize thành ARRAY. Scheme: FIMS_COMPANY_TYPE. HLD decision: FIMS_HLD_Tier1.md. |
| 15 | Description | dsc | STRING | X |  |  |  | Ghi chú. | ThanhTra | DM_CONG_TY_CK |  |  |
| 16 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | ThanhTra | DM_CONG_TY_CK |  | Mã người dùng hệ thống — denormalized. |
| 17 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | ThanhTra | DM_CONG_TY_CK |  |  |
| 18 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | ThanhTra | DM_CONG_TY_CK |  |  |
| 19 | Securities Company Business Key | scr_co_bsn_key | STRING | X |  |  |  | ID duy nhất của CTCK dùng liên thông hệ thống (BK nghiệp vụ). | ThanhTra | DM_CONG_TY_CK |  | Trường BK nghiệp vụ — khác với PK kỹ thuật. Dùng liên thông giữa hệ thống. |
| 20 | Securities Company Business Code | scr_co_bsn_code | STRING | X |  |  |  | Mã số CTCK (mã nghiệp vụ ngắn). | ThanhTra | DM_CONG_TY_CK |  | Mã nghiệp vụ — khác BK kỹ thuật. |
| 21 | Securities Company Name | scr_co_nm | STRING |  |  |  |  | Tên tiếng Việt công ty chứng khoán. | ThanhTra | DM_CONG_TY_CK | TEN_TIENG_VIET |  |
| 22 | Securities Company English Name | scr_co_english_nm | STRING | X |  |  |  | Tên tiếng Anh công ty chứng khoán. | ThanhTra | DM_CONG_TY_CK | TEN_TIENG_ANH |  |
| 23 | Securities Company Short Name | scr_co_shrt_nm | STRING | X |  |  |  | Tên viết tắt công ty chứng khoán. | ThanhTra | DM_CONG_TY_CK | TEN_VIET_TAT |  |
| 24 | Tax Code | tax_code | STRING | X |  |  |  | Mã số thuế. | ThanhTra | DM_CONG_TY_CK |  | Mã số thuế — trường nghiệp vụ riêng. |
| 25 | Company Type Code | co_tp_code | STRING | X |  |  |  | Loại hình công ty. | ThanhTra | DM_CONG_TY_CK | LOAI_HINH_CONG_TY | Scheme: TT_COMPANY_TYPE. |
| 26 | Share Quantity | shr_qty | INT | X |  |  |  | Số lượng cổ phần. | ThanhTra | DM_CONG_TY_CK |  |  |
| 27 | Business Sector Codes | bsn_sctr_codes | Array<Text> | X |  |  |  | Danh sách mã ngành nghề kinh doanh. | ThanhTra | DM_CONG_TY_CK |  | Pure junction LK_CTCK_NGANH_NGHE_KD → denormalize thành ARRAY. Scheme: SCMS_BUSINESS_SECTOR. HLD decision: SCMS_HLD_Tier1.md. |
| 28 | Is Listed Indicator | is_list_ind | STRING | X |  |  |  | Cờ niêm yết: 1-Có niêm yết; 0-Không. | ThanhTra | DM_CONG_TY_CK |  |  |
| 29 | Stock Exchange Name | stk_exg_nm | STRING | X |  |  |  | Sàn niêm yết. | ThanhTra | DM_CONG_TY_CK |  | Text denormalized — tên sàn. |
| 30 | Securities Code | scr_code | STRING | X |  |  |  | Mã chứng khoán niêm yết. | ThanhTra | DM_CONG_TY_CK |  |  |
| 31 | Registration Date | rgst_dt | DATE | X |  |  |  | Ngày đăng ký CTDC. | ThanhTra | DM_CONG_TY_CK |  |  |
| 32 | Registration Decision Number | rgst_dcsn_nbr | STRING | X |  |  |  | Số quyết định đăng ký. | ThanhTra | DM_CONG_TY_CK |  |  |
| 33 | Termination Date | tmt_dt | DATE | X |  |  |  | Ngày kết thúc CTDC. | ThanhTra | DM_CONG_TY_CK |  |  |
| 34 | Termination Decision Number | tmt_dcsn_nbr | STRING | X |  |  |  | Số quyết định kết thúc. | ThanhTra | DM_CONG_TY_CK |  |  |
| 35 | Company Status Code | co_st_code | STRING | X |  |  |  | Trạng thái hoạt động của CTCK. | ThanhTra | DM_CONG_TY_CK |  | Scheme: SCMS_COMPANY_STATUS. |
| 36 | Is Draft Indicator | is_drft_ind | STRING | X |  |  |  | Cờ bảng tạm: 1-Bảng tạm; 0-Chính thức. | ThanhTra | DM_CONG_TY_CK |  |  |
| 37 | Business Activity Category Id | bsn_avy_cgy_id | BIGINT | X |  | F |  | FK đến ngành nghề kinh doanh (DM_NGANH_NGHE_KD). Nullable. | ThanhTra | DM_CONG_TY_CK |  | FK target: DM_NGANH_NGHE_KD entity — chưa được thiết kế lên Silver. |
| 38 | Business Activity Category Code | bsn_avy_cgy_code | STRING | X |  |  |  | Mã ngành nghề kinh doanh. | ThanhTra | DM_CONG_TY_CK |  | Lookup pair: DM_NGANH_NGHE_KD entity — chưa được thiết kế lên Silver. Pair with Business Activity Category Id. |
| 39 | Business License Number | bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. | ThanhTra | DM_CONG_TY_CK | GIAY_PHEP_KINH_DOANH |  |
| 40 | Website | webst | STRING | X |  |  |  | Website chính thức. | ThanhTra | DM_CONG_TY_CK | WEBSITE |  |


#### 2.{IDX}.8.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Securities Company Id | scr_co_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Country of Registration Id | cty_of_rgst_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.9 Bảng Involved Party Electronic Address — ThanhTra.DM_CONG_TY_CK

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Securities Company. | ThanhTra | DM_CONG_TY_CK | ID | FK target: Securities Company.Securities Company Id. |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. | ThanhTra | DM_CONG_TY_CK | ID | Lookup pair: Securities Company.Securities Company Code. Pair with Involved Party Id. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DM_CONG_TY_CK |  |  |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — email. | ThanhTra | DM_CONG_TY_CK |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Email. | ThanhTra | DM_CONG_TY_CK | EMAIL |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Securities Company. | ThanhTra | DM_CONG_TY_CK | ID | FK target: Securities Company.Securities Company Id. |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. | ThanhTra | DM_CONG_TY_CK | ID | Lookup pair: Securities Company.Securities Company Code. Pair with Involved Party Id. |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DM_CONG_TY_CK |  |  |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — điện thoại. | ThanhTra | DM_CONG_TY_CK |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | ThanhTra | DM_CONG_TY_CK | DIEN_THOAI |  |


#### 2.{IDX}.9.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Company | Securities Company Id | scr_co_id |




### 2.{IDX}.10 Bảng Involved Party Postal Address — ThanhTra.DM_CONG_TY_CK

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Securities Company. | ThanhTra | DM_CONG_TY_CK | ID | FK target: Securities Company.Securities Company Id. |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. | ThanhTra | DM_CONG_TY_CK | ID | Lookup pair: Securities Company.Securities Company Code. Pair with Involved Party Id. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DM_CONG_TY_CK |  |  |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ — trụ sở chính. | ThanhTra | DM_CONG_TY_CK |  |  |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở chính. | ThanhTra | DM_CONG_TY_CK | DIA_CHI |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | ThanhTra | DM_CONG_TY_CK |  | FK target: Geographic Area.Geographic Area Id. Lookup: DM_TINH_THANH. |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). | ThanhTra | DM_CONG_TY_CK |  | Lookup pair: Geographic Area.Geographic Area Code. Pair with Province Id. // Text denormalized — provinces là reference data set chưa map vào shared Geographic Area trong scope IDS. |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. | ThanhTra | DM_CONG_TY_CK |  | Text denormalized — không có bảng lookup quận/huyện trong scope. |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. | ThanhTra | DM_CONG_TY_CK |  | Text denormalized. |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | ThanhTra | DM_CONG_TY_CK |  | FK target: Geographic Area.Geographic Area Id. |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | ThanhTra | DM_CONG_TY_CK |  | Lookup pair: Geographic Area.Geographic Area Code. Pair with Geographic Area Id. |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | ThanhTra | DM_CONG_TY_CK |  | Text tự do — denormalized. |


#### 2.{IDX}.10.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Company | Securities Company Id | scr_co_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.11 Bảng Fund Management Company

- **Mô tả:** Công ty quản lý quỹ đầu tư chứng khoán trong nước được UBCKNN cấp phép hoạt động. Lưu thông tin pháp lý và hoạt động của công ty.
- **Tên vật lý:** fnd_mgt_co
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Fund Management Company Id | fnd_mgt_co_id | BIGINT |  | X | P |  | Khóa đại diện cho công ty quản lý quỹ. | ThanhTra | DM_CONG_TY_QLQ |  |  |
| 2 | Fund Management Company Code | fnd_mgt_co_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. Map từ PK ThanhTra.DM_CONG_TY_QLQ.ID. | ThanhTra | DM_CONG_TY_QLQ | ID | BK của entity — source ThanhTra.DM_CONG_TY_QLQ. Entity Fund Management Company cũng có source từ FMS.SECURITIES và FIMS.FUNDCOMPANY. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DM_CONG_TY_QLQ |  |  |
| 4 | Fund Management Company Name | fnd_mgt_co_nm | STRING |  |  |  |  | Tên tiếng Việt công ty quản lý quỹ. | ThanhTra | DM_CONG_TY_QLQ | TEN_TIENG_VIET |  |
| 5 | Fund Management Company Short Name | fnd_mgt_co_shrt_nm | STRING | X |  |  |  | Tên viết tắt công ty quản lý quỹ. | ThanhTra | DM_CONG_TY_QLQ | TEN_VIET_TAT |  |
| 6 | Fund Management Company English Name | fnd_mgt_co_english_nm | STRING | X |  |  |  | Tên tiếng Anh công ty quản lý quỹ. | ThanhTra | DM_CONG_TY_QLQ | TEN_TIENG_ANH |  |
| 7 | Practice Status Code | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động của công ty QLQ. | ThanhTra | DM_CONG_TY_QLQ |  | Scheme: FMS_OPERATION_STATUS. |
| 8 | Charter Capital Amount | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ. | ThanhTra | DM_CONG_TY_QLQ | VON_DIEU_LE |  |
| 9 | Dorf Indicator | dorf_ind | STRING | X |  |  |  | Loại hình trong/ngoài nước. 1=Trong nước; 0=Nước ngoài. | ThanhTra | DM_CONG_TY_QLQ |  |  |
| 10 | License Decision Number | license_dcsn_nbr | STRING | X |  |  |  | Số quyết định/giấy phép thành lập. | ThanhTra | DM_CONG_TY_QLQ |  | Denormalized — map vào IP Alt Identification. |
| 11 | License Decision Date | license_dcsn_dt | DATE | X |  |  |  | Ngày cấp phép. | ThanhTra | DM_CONG_TY_QLQ |  | Denormalized — map vào IP Alt Identification. |
| 12 | Active Date | actv_dt | DATE | X |  |  |  | Ngày bắt đầu hoạt động. | ThanhTra | DM_CONG_TY_QLQ |  |  |
| 13 | Stop Date | stop_dt | DATE | X |  |  |  | Ngày ngừng hoạt động. | ThanhTra | DM_CONG_TY_QLQ |  |  |
| 14 | Business Type Codes | bsn_tp_codes | Array<Text> | X |  |  |  | Danh sách mã nghiệp vụ kinh doanh. Từ bảng junction FUNDCOMBUSINES. | ThanhTra | DM_CONG_TY_QLQ |  | Pure junction SECBUSINES → denormalize thành ARRAY. HLD decision: FMS_HLD_Tier2.md. // Pure junction FUNDCOMBUSINES → denormalize thành ARRAY. Scheme: FIMS_BUSINESS_TYPE. HLD decision: FIMS_HLD_Tier1.md. |
| 15 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | ThanhTra | DM_CONG_TY_QLQ |  | Mã người dùng hệ thống — denormalized. |
| 16 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | ThanhTra | DM_CONG_TY_QLQ |  |  |
| 17 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | ThanhTra | DM_CONG_TY_QLQ |  |  |
| 18 | Country of Registration Id | cty_of_rgst_id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký của công ty QLQ. | ThanhTra | DM_CONG_TY_QLQ |  | FK target: Geographic Area.Geographic Area Id. ID quốc gia lấy từ bảng NATIONAL. |
| 19 | Country of Registration Code | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. | ThanhTra | DM_CONG_TY_QLQ |  | Lookup pair: Geographic Area.Geographic Area Code. Pair with Country of Registration Id. |
| 20 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. | ThanhTra | DM_CONG_TY_QLQ | TRANG_THAI_HOAT_DONG | Scheme: LIFE_CYCLE_STATUS. |
| 21 | Director Name | director_nm | STRING | X |  |  |  | Tên Tổng giám đốc (denormalized). | ThanhTra | DM_CONG_TY_QLQ |  | Denormalized snapshot — không dùng để join. |
| 22 | Depository Certificate Number | depst_ctf_nbr | STRING | X |  |  |  | Chứng nhận lưu ký — thông tin bổ sung của FIMS không có trong FMS.SECURITIES. | ThanhTra | DM_CONG_TY_QLQ |  | Denormalized — FIMS-specific field. |
| 23 | Company Type Codes | co_tp_codes | Array<Text> | X |  |  |  | Danh sách mã loại hình doanh nghiệp. Từ bảng junction FUNDCOMTYPE. | ThanhTra | DM_CONG_TY_QLQ |  | Pure junction FUNDCOMTYPE → denormalize thành ARRAY. Scheme: FIMS_COMPANY_TYPE. HLD decision: FIMS_HLD_Tier1.md. |
| 24 | Description | dsc | STRING | X |  |  |  | Ghi chú. | ThanhTra | DM_CONG_TY_QLQ |  |  |
| 25 | Company Type Code | co_tp_code | STRING | X |  |  |  | Loại hình công ty. | ThanhTra | DM_CONG_TY_QLQ | LOAI_HINH_CONG_TY | Scheme: TT_COMPANY_TYPE. |
| 26 | Fund Type Code | fnd_tp_code | STRING | X |  |  |  | Loại quỹ (áp dụng cho quỹ đầu tư). | ThanhTra | DM_CONG_TY_QLQ | LOAI_QUY | Scheme: TT_FUND_TYPE. |
| 27 | Business License Number | bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. | ThanhTra | DM_CONG_TY_QLQ | GIAY_PHEP_KINH_DOANH |  |
| 28 | Website | webst | STRING | X |  |  |  | Website chính thức. | ThanhTra | DM_CONG_TY_QLQ | WEBSITE |  |


#### 2.{IDX}.11.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Fund Management Company Id | fnd_mgt_co_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Country of Registration Id | cty_of_rgst_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.12 Bảng Involved Party Electronic Address — ThanhTra.DM_CONG_TY_QLQ

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. | ThanhTra | DM_CONG_TY_QLQ | ID | FK target: Fund Management Company.Fund Management Company Id. |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. | ThanhTra | DM_CONG_TY_QLQ | ID | Lookup pair: Fund Management Company.Fund Management Company Code. Pair with Involved Party Id. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DM_CONG_TY_QLQ |  |  |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — email. | ThanhTra | DM_CONG_TY_QLQ |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Email. | ThanhTra | DM_CONG_TY_QLQ | EMAIL |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. | ThanhTra | DM_CONG_TY_QLQ | ID | FK target: Fund Management Company.Fund Management Company Id. |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. | ThanhTra | DM_CONG_TY_QLQ | ID | Lookup pair: Fund Management Company.Fund Management Company Code. Pair with Involved Party Id. |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DM_CONG_TY_QLQ |  |  |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — điện thoại. | ThanhTra | DM_CONG_TY_QLQ |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | ThanhTra | DM_CONG_TY_QLQ | DIEN_THOAI |  |


#### 2.{IDX}.12.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Fund Management Company | Fund Management Company Id | fnd_mgt_co_id |




### 2.{IDX}.13 Bảng Involved Party Postal Address — ThanhTra.DM_CONG_TY_QLQ

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. | ThanhTra | DM_CONG_TY_QLQ | ID | FK target: Fund Management Company.Fund Management Company Id. |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. | ThanhTra | DM_CONG_TY_QLQ | ID | Lookup pair: Fund Management Company.Fund Management Company Code. Pair with Involved Party Id. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DM_CONG_TY_QLQ |  |  |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ — trụ sở chính. | ThanhTra | DM_CONG_TY_QLQ |  |  |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở chính. | ThanhTra | DM_CONG_TY_QLQ | DIA_CHI |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | ThanhTra | DM_CONG_TY_QLQ |  | FK target: Geographic Area.Geographic Area Id. Lookup: DM_TINH_THANH. |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). | ThanhTra | DM_CONG_TY_QLQ |  | Lookup pair: Geographic Area.Geographic Area Code. Pair with Province Id. // Text denormalized — provinces là reference data set chưa map vào shared Geographic Area trong scope IDS. |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. | ThanhTra | DM_CONG_TY_QLQ |  | Text denormalized — không có bảng lookup quận/huyện trong scope. |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. | ThanhTra | DM_CONG_TY_QLQ |  | Text denormalized. |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | ThanhTra | DM_CONG_TY_QLQ |  | FK target: Geographic Area.Geographic Area Id. |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | ThanhTra | DM_CONG_TY_QLQ |  | Lookup pair: Geographic Area.Geographic Area Code. Pair with Geographic Area Id. |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | ThanhTra | DM_CONG_TY_QLQ |  | Text tự do — denormalized. |


#### 2.{IDX}.13.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Fund Management Company | Fund Management Company Id | fnd_mgt_co_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.14 Bảng Inspection Subject Other Party

- **Mô tả:** Đối tượng thanh tra khác (cá nhân hoặc tổ chức) không thuộc danh mục CK/QLQ/ĐC. Phân biệt qua party_type_code.
- **Tên vật lý:** inspection_sbj_othr_p
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Inspection Subject Other Party Id | inspection_sbj_othr_p_id | BIGINT |  | X | P |  | Khóa đại diện cho đối tượng thanh tra khác. | ThanhTra | DM_DOI_TUONG_KHAC |  |  |
| 2 | Inspection Subject Other Party Code | inspection_sbj_othr_p_code | STRING |  |  |  |  | Mã đối tượng. Map từ PK ThanhTra.DM_DOI_TUONG_KHAC.ID. | ThanhTra | DM_DOI_TUONG_KHAC | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DM_DOI_TUONG_KHAC |  |  |
| 4 | Party Type Code | p_tp_code | STRING |  |  |  |  | Loại đối tượng: CA_NHAN / TO_CHUC. | ThanhTra | DM_DOI_TUONG_KHAC | LOAI_DOI_TUONG | Scheme: TT_PARTY_TYPE. |
| 5 | Name | nm | STRING |  |  |  |  | Tên đối tượng thanh tra. | ThanhTra | DM_DOI_TUONG_KHAC | TEN_DOI_TUONG |  |
| 6 | Short Name | shrt_nm | STRING | X |  |  |  | Tên viết tắt. | ThanhTra | DM_DOI_TUONG_KHAC | TEN_VIET_TAT |  |
| 7 | Representative Name | representative_nm | STRING | X |  |  |  | Người đại diện (cho tổ chức). | ThanhTra | DM_DOI_TUONG_KHAC | NGUOI_DAI_DIEN |  |
| 8 | Business License Number | bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh (cho tổ chức). | ThanhTra | DM_DOI_TUONG_KHAC | SO_GPKD |  |
| 9 | Country of Registration Id | cty_of_rgst_id | BIGINT | X |  | F |  | FK đến Geographic Area — quốc gia đăng ký. | ThanhTra | DM_DOI_TUONG_KHAC | QUOC_GIA_ID | FK target: Geographic Area.Geographic Area Id. Source has lookup via ThanhTra.DM_QUOC_GIA → shared Silver entity Geographic Area (COUNTRY). |
| 10 | Country of Registration Code | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. | ThanhTra | DM_DOI_TUONG_KHAC | QUOC_GIA_ID | Lookup pair: Geographic Area.Geographic Area Code. Pair with Country of Registration Id. |
| 11 | Website | webst | STRING | X |  |  |  | Website. | ThanhTra | DM_DOI_TUONG_KHAC | WEBSITE |  |


#### 2.{IDX}.14.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Inspection Subject Other Party Id | inspection_sbj_othr_p_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Country of Registration Id | cty_of_rgst_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.15 Bảng Involved Party Electronic Address — ThanhTra.DM_DOI_TUONG_KHAC

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Inspection Subject Other Party. | ThanhTra | DM_DOI_TUONG_KHAC | ID | FK target: Inspection Subject Other Party.Inspection Subject Other Party Id. |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã đối tượng thanh tra. | ThanhTra | DM_DOI_TUONG_KHAC | ID | Lookup pair: Inspection Subject Other Party.Inspection Subject Other Party Code. Pair with Involved Party Id. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DM_DOI_TUONG_KHAC |  |  |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — email. | ThanhTra | DM_DOI_TUONG_KHAC |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Email. | ThanhTra | DM_DOI_TUONG_KHAC | EMAIL |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Inspection Subject Other Party. | ThanhTra | DM_DOI_TUONG_KHAC | ID | FK target: Inspection Subject Other Party.Inspection Subject Other Party Id. |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã đối tượng thanh tra. | ThanhTra | DM_DOI_TUONG_KHAC | ID | Lookup pair: Inspection Subject Other Party.Inspection Subject Other Party Code. Pair with Involved Party Id. |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DM_DOI_TUONG_KHAC |  |  |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — fax. | ThanhTra | DM_DOI_TUONG_KHAC |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số fax. | ThanhTra | DM_DOI_TUONG_KHAC | FAX |  |
| 11 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Inspection Subject Other Party. | ThanhTra | DM_DOI_TUONG_KHAC | ID | FK target: Inspection Subject Other Party.Inspection Subject Other Party Id. |
| 12 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã đối tượng thanh tra. | ThanhTra | DM_DOI_TUONG_KHAC | ID | Lookup pair: Inspection Subject Other Party.Inspection Subject Other Party Code. Pair with Involved Party Id. |
| 13 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DM_DOI_TUONG_KHAC |  |  |
| 14 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — số điện thoại. | ThanhTra | DM_DOI_TUONG_KHAC |  |  |
| 15 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | ThanhTra | DM_DOI_TUONG_KHAC | SO_DIEN_THOAI |  |


#### 2.{IDX}.15.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Inspection Subject Other Party | Inspection Subject Other Party Id | inspection_sbj_othr_p_id |




### 2.{IDX}.16 Bảng Involved Party Postal Address — ThanhTra.DM_DOI_TUONG_KHAC

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Inspection Subject Other Party. | ThanhTra | DM_DOI_TUONG_KHAC | ID | FK target: Inspection Subject Other Party.Inspection Subject Other Party Id. |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã đối tượng thanh tra. | ThanhTra | DM_DOI_TUONG_KHAC | ID | Lookup pair: Inspection Subject Other Party.Inspection Subject Other Party Code. Pair with Involved Party Id. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DM_DOI_TUONG_KHAC |  |  |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ — địa chỉ liên hệ. | ThanhTra | DM_DOI_TUONG_KHAC |  |  |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ. | ThanhTra | DM_DOI_TUONG_KHAC | DIA_CHI |  |
| 6 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | ThanhTra | DM_DOI_TUONG_KHAC |  | Text tự do — denormalized. |


#### 2.{IDX}.16.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Inspection Subject Other Party | Inspection Subject Other Party Id | inspection_sbj_othr_p_id |




### 2.{IDX}.17 Bảng Inspection Annual Plan

- **Mô tả:** Kế hoạch thanh tra kiểm tra cấp năm được phê duyệt. Khởi đầu quy trình thanh tra trong năm.
- **Tên vật lý:** inspection_anul_pln
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Inspection Annual Plan Id | inspection_anul_pln_id | BIGINT |  | X | P |  | Khóa đại diện cho kế hoạch thanh tra hàng năm. | ThanhTra | TT_KE_HOACH |  |  |
| 2 | Inspection Annual Plan Code | inspection_anul_pln_code | STRING |  |  |  |  | Mã kế hoạch. Map từ PK ThanhTra.TT_KE_HOACH.ID. | ThanhTra | TT_KE_HOACH | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | TT_KE_HOACH |  |  |
| 4 | Plan Type Code | pln_tp_code | STRING |  |  |  |  | Loại kế hoạch: THANH_TRA / KIEM_TRA. | ThanhTra | TT_KE_HOACH | LOAI_KE_HOACH | Scheme: TT_PLAN_TYPE. |
| 5 | Plan Name | pln_nm | STRING |  |  |  |  | Tên kế hoạch (ví dụ: Kế hoạch thanh tra năm 2025). | ThanhTra | TT_KE_HOACH | TEN_KE_HOACH |  |
| 6 | Approval Decision Number | aprv_dcsn_nbr | STRING | X |  |  |  | Số quyết định phê duyệt kế hoạch. | ThanhTra | TT_KE_HOACH | SO_QD_PHE_DUYET |  |
| 7 | Approval Date | aprv_dt | DATE | X |  |  |  | Ngày ký quyết định phê duyệt. | ThanhTra | TT_KE_HOACH | NGAY_KY_QUYET_DINH |  |
| 8 | Plan Year | pln_yr | INT |  |  |  |  | Năm kế hoạch (ví dụ: 2025). | ThanhTra | TT_KE_HOACH | NAM_KE_HOACH |  |
| 9 | Official Dispatch Number | offc_dispatch_nbr | STRING | X |  |  |  | Số công văn kèm kế hoạch. | ThanhTra | TT_KE_HOACH | SO_CONG_VAN |  |
| 10 | Official Dispatch Date | offc_dispatch_dt | DATE | X |  |  |  | Ngày công văn. | ThanhTra | TT_KE_HOACH | NGAY_CONG_VAN |  |
| 11 | Remark | remark | STRING | X |  |  |  | Ghi chú (tối đa 4000 ký tự). | ThanhTra | TT_KE_HOACH | GHI_CHU |  |
| 12 | Plan Status Code | pln_st_code | STRING |  |  |  |  | Trạng thái: 1-Hoạt động, 0-Đã xóa. | ThanhTra | TT_KE_HOACH | TRANG_THAI | Scheme: TT_RECORD_STATUS. |


#### 2.{IDX}.17.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Inspection Annual Plan Id | inspection_anul_pln_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.18 Bảng Surveillance Enforcement Case

- **Mô tả:** Hồ sơ xử lý vi phạm từ kết quả giám sát thị trường. Ghi nhận đối tượng và trạng thái xử lý.
- **Tên vật lý:** surveillance_enforcement_case
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Surveillance Enforcement Case Id | surveillance_enforcement_case_id | BIGINT |  | X | P |  | Khóa đại diện cho hồ sơ xử lý vi phạm từ giám sát. | ThanhTra | GS_HO_SO |  |  |
| 2 | Surveillance Enforcement Case Code | surveillance_enforcement_case_code | STRING |  |  |  |  | Mã hồ sơ. Map từ PK ThanhTra.GS_HO_SO.ID. | ThanhTra | GS_HO_SO | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | GS_HO_SO |  |  |
| 4 | Case Number | case_nbr | STRING |  |  |  |  | Mã hồ sơ nghiệp vụ (duy nhất trong hệ thống). | ThanhTra | GS_HO_SO | MA_HO_SO |  |
| 5 | Case Name | case_nm | STRING | X |  |  |  | Tên hồ sơ. | ThanhTra | GS_HO_SO | TEN_HO_SO |  |
| 6 | Archive Number | archv_nbr | STRING | X |  |  |  | Mã số lưu trữ. | ThanhTra | GS_HO_SO | MA_SO_LUU_TRU |  |
| 7 | Received Date | rcvd_dt | DATE | X |  |  |  | Ngày nhận hồ sơ. | ThanhTra | GS_HO_SO | NGAY_NHAN_HO_SO |  |
| 8 | Business Sector Code | bsn_sctr_code | STRING | X |  |  |  | Mảng nghiệp vụ liên quan. | ThanhTra | GS_HO_SO | MANG_NGHIEP_VU_ID | Scheme: TT_BUSINESS_SECTOR. |
| 9 | Data Source Description | data_src_dsc | STRING | X |  |  |  | Nguồn cung cấp hồ sơ (nhiều nguồn, lưu text). | ThanhTra | GS_HO_SO | NGUON_CUNG_CAP |  |
| 10 | Case Content | case_cntnt | STRING | X |  |  |  | Nội dung hồ sơ. | ThanhTra | GS_HO_SO | NOI_DUNG |  |
| 11 | Security Level Code | scr_lvl_code | STRING | X |  |  |  | Mức độ bảo mật hồ sơ. | ThanhTra | GS_HO_SO | MUC_DO_BAO_MAT_ID | Scheme: TT_SECURITY_LEVEL. |
| 12 | Subject Name | sbj_nm | STRING | X |  |  |  | Tên đối tượng vi phạm (denormalized). | ThanhTra | GS_HO_SO | TEN_DOI_TUONG |  |
| 13 | Case Status Code | case_st_code | STRING |  |  |  |  | Trạng thái hồ sơ. | ThanhTra | GS_HO_SO | TRANG_THAI_ID | Scheme: TT_CASE_STATUS. |
| 14 | Remark | remark | STRING | X |  |  |  | Ghi chú. | ThanhTra | GS_HO_SO | GHI_CHU |  |
| 15 | Responsible Officer Id | rspl_ofcr_id | BIGINT | X |  | F |  | FK đến Inspection Officer — lãnh đạo phụ trách. | ThanhTra | GS_HO_SO | LANH_DAO_PHU_TRACH | FK target: Inspection Officer.Inspection Officer Id. |
| 16 | Responsible Officer Code | rspl_ofcr_code | STRING | X |  |  |  | Mã cán bộ lãnh đạo phụ trách. | ThanhTra | GS_HO_SO | LANH_DAO_PHU_TRACH | Lookup pair: Inspection Officer.Inspection Officer Code. Pair with Responsible Officer Id. |
| 17 | Processing Officer Id | pcs_ofcr_id | BIGINT | X |  | F |  | FK đến Inspection Officer — chuyên viên xử lý. | ThanhTra | GS_HO_SO | CHUYEN_VIEN_XU_LY | FK target: Inspection Officer.Inspection Officer Id. |
| 18 | Processing Officer Code | pcs_ofcr_code | STRING | X |  |  |  | Mã cán bộ chuyên viên xử lý. | ThanhTra | GS_HO_SO | CHUYEN_VIEN_XU_LY | Lookup pair: Inspection Officer.Inspection Officer Code. Pair with Processing Officer Id. |


#### 2.{IDX}.18.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Surveillance Enforcement Case Id | surveillance_enforcement_case_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Responsible Officer Id | rspl_ofcr_id | Inspection Officer | Inspection Officer Id | inspection_ofcr_id |
| Processing Officer Id | pcs_ofcr_id | Inspection Officer | Inspection Officer Id | inspection_ofcr_id |




### 2.{IDX}.19 Bảng Complaint Petition

- **Mô tả:** Đơn thư khiếu nại/tố cáo/phản ánh/kiến nghị nhận từ công dân hoặc tổ chức. Khởi đầu quy trình giải quyết đơn thư.
- **Tên vật lý:** cpln_petition
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Complaint Petition Id | cpln_petition_id | BIGINT |  | X | P |  | Khóa đại diện cho đơn thư khiếu nại tố cáo. | ThanhTra | DT_DON_THU |  |  |
| 2 | Complaint Petition Code | cpln_petition_code | STRING |  |  |  |  | Mã đơn thư. Map từ PK ThanhTra.DT_DON_THU.ID. | ThanhTra | DT_DON_THU | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DT_DON_THU |  |  |
| 4 | Petition Name | petition_nm | STRING | X |  |  |  | Tên đơn thư. | ThanhTra | DT_DON_THU | TEN_DON_THU |  |
| 5 | Complainant Type Code | complainant_tp_code | STRING |  |  |  |  | Loại đối tượng gửi đơn: CA_NHAN / TO_CHUC. | ThanhTra | DT_DON_THU | LOAI_DOI_TUONG | Scheme: TT_PARTY_TYPE. |
| 6 | Complainant Name | complainant_nm | STRING | X |  |  |  | Tên tổ chức / cá nhân gửi đơn (snapshot tại thời điểm tiếp nhận). | ThanhTra | DT_DON_THU | TEN_TO_CHUC_CA_NHAN |  |
| 7 | Is Anonymous | is_anon | STRING |  |  |  |  | Nặc danh: 1-Có, 0-Không. | ThanhTra | DT_DON_THU | NAC_DANH |  |
| 8 | Complainant Count | complainant_cnt | INT | X |  |  |  | Số người gửi đơn. | ThanhTra | DT_DON_THU | SO_NGUOI |  |
| 9 | Complainant Email | complainant_email | STRING | X |  |  |  | Email người gửi (snapshot — grain là đơn thư không phải IP). | ThanhTra | DT_DON_THU | EMAIL |  |
| 10 | Complainant Address | complainant_adr | STRING | X |  |  |  | Địa chỉ người gửi (snapshot). | ThanhTra | DT_DON_THU | DIA_CHI |  |
| 11 | Has No Address | has_no_adr | STRING |  |  |  |  | Không có địa chỉ: 1-Có / 0-Không. | ThanhTra | DT_DON_THU | KHONG_CO_DIA_CHI |  |
| 12 | Complainant Id Number | complainant_id_nbr | STRING | X |  |  |  | Số CMND/CCCD người gửi (cá nhân — snapshot). | ThanhTra | DT_DON_THU | SO_CMTND |  |
| 13 | Complainant Id Issue Date | complainant_id_issu_dt | DATE | X |  |  |  | Ngày cấp CMND/CCCD (snapshot). | ThanhTra | DT_DON_THU | NGAY_CAP_CMTND |  |
| 14 | Complainant Gender Code | complainant_gnd_code | STRING | X |  |  |  | Giới tính người gửi (cá nhân — snapshot). | ThanhTra | DT_DON_THU | GIOI_TINH | Scheme: INDIVIDUAL_GENDER. |
| 15 | Petition Type Code | petition_tp_code | STRING |  |  |  |  | Loại đơn: KHIEU_NAI / TO_CAO / PHAN_ANH / KIEN_NGHI. | ThanhTra | DT_DON_THU | LOAI_DON | Scheme: TT_PETITION_TYPE. |
| 16 | Written Date | written_dt | DATE | X |  |  |  | Ngày viết đơn. | ThanhTra | DT_DON_THU | NGAY_VIET_DON |  |
| 17 | Petition Content | petition_cntnt | STRING | X |  |  |  | Nội dung đơn thư. | ThanhTra | DT_DON_THU | NOI_DUNG |  |
| 18 | Submission Date | submission_dt | DATE |  |  |  |  | Ngày tiếp nhận đơn. | ThanhTra | DT_DON_THU | NGAY_TIEP_NHAN |  |
| 19 | Receipt Source | recpt_src | STRING | X |  |  |  | Nơi/kênh tiếp nhận đơn. | ThanhTra | DT_DON_THU | NGUON_DON |  |
| 20 | Petition Status Code | petition_st_code | STRING |  |  |  |  | Trạng thái: MOI / DANG_XU_LY / HOAN_THANH / DONG. | ThanhTra | DT_DON_THU | TRANG_THAI | Scheme: TT_PETITION_STATUS. |


#### 2.{IDX}.19.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Complaint Petition Id | cpln_petition_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.20 Bảng AML Enforcement Case

- **Mô tả:** Hồ sơ xử lý vi phạm phòng chống rửa tiền. Ghi nhận đối tượng vi phạm và trạng thái xử lý.
- **Tên vật lý:** aml_enforcement_case
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | AML Enforcement Case Id | aml_enforcement_case_id | BIGINT |  | X | P |  | Khóa đại diện cho hồ sơ phòng chống rửa tiền. | ThanhTra | PCRT_HO_SO |  |  |
| 2 | AML Enforcement Case Code | aml_enforcement_case_code | STRING |  |  |  |  | Mã hồ sơ. Map từ PK ThanhTra.PCRT_HO_SO.ID. | ThanhTra | PCRT_HO_SO | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | PCRT_HO_SO |  |  |
| 4 | Case Number | case_nbr | STRING |  |  |  |  | Mã hồ sơ nghiệp vụ (duy nhất). | ThanhTra | PCRT_HO_SO | MA_HO_SO |  |
| 5 | Case Name | case_nm | STRING | X |  |  |  | Tên hồ sơ. | ThanhTra | PCRT_HO_SO | TEN_HO_SO |  |
| 6 | Subject Type Code | sbj_tp_code | STRING |  |  |  |  | Loại đối tượng: CA_NHAN / TO_CHUC. | ThanhTra | PCRT_HO_SO | LOAI_DOI_TUONG | Scheme: TT_PARTY_TYPE. |
| 7 | Subject Name | sbj_nm | STRING | X |  |  |  | Tên tổ chức/cá nhân liên quan (denormalized). | ThanhTra | PCRT_HO_SO | TEN_DOI_TUONG |  |
| 8 | Received Date | rcvd_dt | DATE | X |  |  |  | Ngày nhận hồ sơ. | ThanhTra | PCRT_HO_SO | NGAY_NHAN_HO_SO |  |
| 9 | Business Sector Code | bsn_sctr_code | STRING | X |  |  |  | Mảng nghiệp vụ liên quan. | ThanhTra | PCRT_HO_SO | MANG_NGHIEP_VU_ID | Scheme: TT_BUSINESS_SECTOR. |
| 10 | Archive Number | archv_nbr | STRING | X |  |  |  | Mã số lưu trữ. | ThanhTra | PCRT_HO_SO | MA_SO_LUU_TRU |  |
| 11 | Case Content | case_cntnt | STRING | X |  |  |  | Nội dung hồ sơ. | ThanhTra | PCRT_HO_SO | NOI_DUNG |  |
| 12 | Case Status Code | case_st_code | STRING |  |  |  |  | Trạng thái hồ sơ. | ThanhTra | PCRT_HO_SO | TRANG_THAI_ID | Scheme: TT_CASE_STATUS. |
| 13 | Responsible Officer Id | rspl_ofcr_id | BIGINT | X |  | F |  | FK đến Inspection Officer — lãnh đạo phụ trách. | ThanhTra | PCRT_HO_SO | LANH_DAO_PHU_TRACH | FK target: Inspection Officer.Inspection Officer Id. |
| 14 | Responsible Officer Code | rspl_ofcr_code | STRING | X |  |  |  | Mã cán bộ lãnh đạo phụ trách. | ThanhTra | PCRT_HO_SO | LANH_DAO_PHU_TRACH | Lookup pair: Inspection Officer.Inspection Officer Code. Pair with Responsible Officer Id. |
| 15 | Processing Officer Id | pcs_ofcr_id | BIGINT | X |  | F |  | FK đến Inspection Officer — chuyên viên xử lý. | ThanhTra | PCRT_HO_SO | CHUYEN_VIEN_XU_LY | FK target: Inspection Officer.Inspection Officer Id. |
| 16 | Processing Officer Code | pcs_ofcr_code | STRING | X |  |  |  | Mã cán bộ chuyên viên xử lý. | ThanhTra | PCRT_HO_SO | CHUYEN_VIEN_XU_LY | Lookup pair: Inspection Officer.Inspection Officer Code. Pair with Processing Officer Id. |


#### 2.{IDX}.20.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| AML Enforcement Case Id | aml_enforcement_case_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Responsible Officer Id | rspl_ofcr_id | Inspection Officer | Inspection Officer Id | inspection_ofcr_id |
| Processing Officer Id | pcs_ofcr_id | Inspection Officer | Inspection Officer Id | inspection_ofcr_id |




### 2.{IDX}.21 Bảng Anti-Corruption Report

- **Mô tả:** Báo cáo tổng hợp định kỳ về hoạt động phòng chống tham nhũng. Mỗi dòng = 1 lần lập báo cáo.
- **Tên vật lý:** anti-corruption_rpt
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Anti-Corruption Report Id | anti-corruption_rpt_id | BIGINT |  | X | P |  | Khóa đại diện cho báo cáo phòng chống tham nhũng. | ThanhTra | PCTN_BAO_CAO |  |  |
| 2 | Anti-Corruption Report Code | anti-corruption_rpt_code | STRING |  |  |  |  | Mã báo cáo PCTN. Map từ PK ThanhTra.PCTN_BAO_CAO.ID. | ThanhTra | PCTN_BAO_CAO | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | PCTN_BAO_CAO |  |  |
| 4 | Report Name | rpt_nm | STRING |  |  |  |  | Tên báo cáo phòng chống tham nhũng. | ThanhTra | PCTN_BAO_CAO | TEN_BAO_CAO |  |
| 5 | Report Date | rpt_dt | DATE | X |  |  |  | Ngày lập báo cáo. | ThanhTra | PCTN_BAO_CAO | NGAY_LAP_BAO_CAO |  |
| 6 | Report Sent Date | rpt_snd_dt | DATE | X |  |  |  | Ngày gửi báo cáo. | ThanhTra | PCTN_BAO_CAO | NGAY_GUI_BAO_CAO |  |
| 7 | Period From Date | prd_fm_dt | DATE | X |  |  |  | Từ ngày tổng hợp. | ThanhTra | PCTN_BAO_CAO | TU_NGAY_TONG_HOP |  |
| 8 | Period To Date | prd_to_dt | DATE | X |  |  |  | Đến ngày tổng hợp. | ThanhTra | PCTN_BAO_CAO | DEN_NGAY_TONG_HOP |  |
| 9 | Citizen Reception Result | citizen_rcptn_rslt | STRING | X |  |  |  | Kết quả tiếp công dân. | ThanhTra | PCTN_BAO_CAO | KET_QUA_TIEP_CONG_DAN |  |
| 10 | Complaint Processing Result | cpln_pcs_rslt | STRING | X |  |  |  | Kết quả xử lý khiếu nại tố cáo. | ThanhTra | PCTN_BAO_CAO | KET_QUA_XU_LY_KNTC |  |
| 11 | Report File URL | rpt_file_url | STRING | X |  |  |  | Đường dẫn file báo cáo. | ThanhTra | PCTN_BAO_CAO | FILE_BAO_CAO |  |


#### 2.{IDX}.21.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Anti-Corruption Report Id | anti-corruption_rpt_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.22 Bảng AML Periodic Report

- **Mô tả:** Báo cáo định kỳ về hoạt động phòng chống rửa tiền. Mỗi dòng = 1 lần lập báo cáo.
- **Tên vật lý:** aml_prd_rpt
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | AML Periodic Report Id | aml_prd_rpt_id | BIGINT |  | X | P |  | Khóa đại diện cho báo cáo phòng chống rửa tiền định kỳ. | ThanhTra | PCRT_BAO_CAO |  |  |
| 2 | AML Periodic Report Code | aml_prd_rpt_code | STRING |  |  |  |  | Mã báo cáo. Map từ ThanhTra.PCRT_BAO_CAO.MA_BAO_CAO (unique). | ThanhTra | PCRT_BAO_CAO | MA_BAO_CAO | BK của entity. |
| 3 | Source Record Id | src_rcrd_id | STRING |  |  |  |  | Khóa chính nội bộ từ bảng nguồn ThanhTra.PCRT_BAO_CAO.ID. | ThanhTra | PCRT_BAO_CAO | ID | Internal source PK — dùng để cross-reference khi MA_BAO_CAO chưa có. |
| 4 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | PCRT_BAO_CAO |  |  |
| 5 | Report Name | rpt_nm | STRING |  |  |  |  | Tên báo cáo phòng chống rửa tiền. | ThanhTra | PCRT_BAO_CAO | TEN_BAO_CAO |  |
| 6 | Report Date | rpt_dt | DATE | X |  |  |  | Ngày lập báo cáo. | ThanhTra | PCRT_BAO_CAO | NGAY_LAP_BAO_CAO |  |
| 7 | Report Sent Date | rpt_snd_dt | DATE | X |  |  |  | Ngày gửi báo cáo. | ThanhTra | PCRT_BAO_CAO | NGAY_GUI_BAO_CAO |  |
| 8 | Period From Date | prd_fm_dt | DATE | X |  |  |  | Từ ngày tổng hợp. | ThanhTra | PCRT_BAO_CAO | TU_NGAY_TONG_HOP |  |
| 9 | Period To Date | prd_to_dt | DATE | X |  |  |  | Đến ngày tổng hợp. | ThanhTra | PCRT_BAO_CAO | DEN_NGAY_TONG_HOP |  |
| 10 | Report Content | rpt_cntnt | STRING | X |  |  |  | Nội dung báo cáo. | ThanhTra | PCRT_BAO_CAO | NOI_DUNG |  |
| 11 | Report File URL | rpt_file_url | STRING | X |  |  |  | Đường dẫn file báo cáo. | ThanhTra | PCRT_BAO_CAO | FILE_BAO_CAO |  |


#### 2.{IDX}.22.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| AML Periodic Report Id | aml_prd_rpt_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.23 Bảng Inspection Annual Plan Subject

- **Mô tả:** Đối tượng thanh tra được đưa vào kế hoạch năm. Grain: 1 đối tượng × 1 kế hoạch.
- **Tên vật lý:** inspection_anul_pln_sbj
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Inspection Annual Plan Subject Id | inspection_anul_pln_sbj_id | BIGINT |  | X | P |  | Khóa đại diện cho đối tượng trong kế hoạch thanh tra. | ThanhTra | TT_KE_HOACH_DOI_TUONG |  |  |
| 2 | Inspection Annual Plan Subject Code | inspection_anul_pln_sbj_code | STRING |  |  |  |  | Mã đối tượng kế hoạch. Map từ PK ThanhTra.TT_KE_HOACH_DOI_TUONG.ID. | ThanhTra | TT_KE_HOACH_DOI_TUONG | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | TT_KE_HOACH_DOI_TUONG |  |  |
| 4 | Inspection Annual Plan Id | inspection_anul_pln_id | BIGINT |  |  | F |  | FK đến Inspection Annual Plan. | ThanhTra | TT_KE_HOACH_DOI_TUONG | KE_HOACH_ID | FK target: Inspection Annual Plan.Inspection Annual Plan Id. |
| 5 | Inspection Annual Plan Code | inspection_anul_pln_code | STRING |  |  |  |  | Mã kế hoạch. | ThanhTra | TT_KE_HOACH_DOI_TUONG | KE_HOACH_ID | Lookup pair: Inspection Annual Plan.Inspection Annual Plan Code. Pair with Inspection Annual Plan Id. |
| 6 | Sequence Number | seq_nbr | INT | X |  |  |  | Số thứ tự đối tượng trong kế hoạch. | ThanhTra | TT_KE_HOACH_DOI_TUONG | STT |  |
| 7 | Subject Name | sbj_nm | STRING |  |  |  |  | Tên đối tượng thanh tra (denormalized — không có DOI_TUONG_ID FK). | ThanhTra | TT_KE_HOACH_DOI_TUONG | TEN_DOI_TUONG |  |
| 8 | Subject Address | sbj_adr | STRING | X |  |  |  | Địa chỉ đối tượng (denormalized). | ThanhTra | TT_KE_HOACH_DOI_TUONG | DIA_CHI |  |
| 9 | Planned Duration | pln_drtn | STRING | X |  |  |  | Thời gian dự kiến thanh tra. | ThanhTra | TT_KE_HOACH_DOI_TUONG | THOI_GIAN_DU_KIEN |  |
| 10 | Lead Unit Name | lead_unit_nm | STRING | X |  |  |  | Đơn vị chủ trì (denormalized theo tên). | ThanhTra | TT_KE_HOACH_DOI_TUONG | DON_VI_CHU_TRI |  |
| 11 | Notification Dispatch Number | notf_dispatch_nbr | STRING | X |  |  |  | Số công văn thông báo. | ThanhTra | TT_KE_HOACH_DOI_TUONG | SO_CVTB |  |
| 12 | Notification Dispatch Date | notf_dispatch_dt | DATE | X |  |  |  | Ngày ký công văn thông báo. | ThanhTra | TT_KE_HOACH_DOI_TUONG | NGAY_KY |  |


#### 2.{IDX}.23.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Inspection Annual Plan Subject Id | inspection_anul_pln_sbj_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Inspection Annual Plan Id | inspection_anul_pln_id | Inspection Annual Plan | Inspection Annual Plan Id | inspection_anul_pln_id |




### 2.{IDX}.24 Bảng Inspection Annual Plan Document Attachment

- **Mô tả:** Văn bản đính kèm kế hoạch thanh tra năm. FK → Inspection Annual Plan.
- **Tên vật lý:** inspection_anul_pln_doc_attachment
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Inspection Annual Plan Document Attachment Id | inspection_anul_pln_doc_attachment_id | BIGINT |  | X | P |  | Khóa đại diện cho văn bản kèm kế hoạch thanh tra. | ThanhTra | TT_KE_HOACH_VAN_BAN |  |  |
| 2 | Inspection Annual Plan Document Attachment Code | inspection_anul_pln_doc_attachment_code | STRING |  |  |  |  | Mã văn bản. Map từ PK ThanhTra.TT_KE_HOACH_VAN_BAN.ID. | ThanhTra | TT_KE_HOACH_VAN_BAN | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | TT_KE_HOACH_VAN_BAN |  |  |
| 4 | Inspection Annual Plan Id | inspection_anul_pln_id | BIGINT |  |  | F |  | FK đến Inspection Annual Plan. | ThanhTra | TT_KE_HOACH_VAN_BAN | KE_HOACH_ID | FK target: Inspection Annual Plan.Inspection Annual Plan Id. |
| 5 | Inspection Annual Plan Code | inspection_anul_pln_code | STRING |  |  |  |  | Mã kế hoạch. | ThanhTra | TT_KE_HOACH_VAN_BAN | KE_HOACH_ID | Lookup pair: Inspection Annual Plan.Inspection Annual Plan Code. Pair with Inspection Annual Plan Id. |
| 6 | Document Number | doc_nbr | STRING | X |  |  |  | Số hiệu văn bản. | ThanhTra | TT_KE_HOACH_VAN_BAN | SO_HIEU |  |
| 7 | Document Name | doc_nm | STRING |  |  |  |  | Tên tài liệu. | ThanhTra | TT_KE_HOACH_VAN_BAN | TEN_TAI_LIEU |  |
| 8 | Page Sequence Number | pg_seq_nbr | INT | X |  |  |  | Số thứ tự trang. | ThanhTra | TT_KE_HOACH_VAN_BAN | SO_THU_TU |  |
| 9 | Page Count | pg_cnt | INT | X |  |  |  | Số trang tài liệu. | ThanhTra | TT_KE_HOACH_VAN_BAN | SO_TRANG |  |
| 10 | Document Source | doc_src | STRING | X |  |  |  | Nguồn gốc tài liệu. | ThanhTra | TT_KE_HOACH_VAN_BAN | NGUON_GOC_TAI_LIEU |  |
| 11 | Attachment File Name | attachment_file_nm | STRING | X |  |  |  | Tên file đính kèm. | ThanhTra | TT_KE_HOACH_VAN_BAN | FILE_NAME |  |
| 12 | Attachment File URL | attachment_file_url | STRING | X |  |  |  | Đường dẫn file lưu trữ. | ThanhTra | TT_KE_HOACH_VAN_BAN | FILE_PATH |  |
| 13 | Attachment File Size | attachment_file_sz | INT | X |  |  |  | Kích thước file (bytes). | ThanhTra | TT_KE_HOACH_VAN_BAN | FILE_SIZE |  |


#### 2.{IDX}.24.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Inspection Annual Plan Document Attachment Id | inspection_anul_pln_doc_attachment_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Inspection Annual Plan Id | inspection_anul_pln_id | Inspection Annual Plan | Inspection Annual Plan Id | inspection_anul_pln_id |




### 2.{IDX}.25 Bảng Inspection Decision

- **Mô tả:** Quyết định thanh tra/kiểm tra cụ thể. FK → Inspection Annual Plan (nullable — thanh tra đột xuất không có kế hoạch).
- **Tên vật lý:** inspection_dcsn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Inspection Decision Id | inspection_dcsn_id | BIGINT |  | X | P |  | Khóa đại diện cho quyết định thanh tra. | ThanhTra | TT_QUYET_DINH |  |  |
| 2 | Inspection Decision Code | inspection_dcsn_code | STRING |  |  |  |  | Mã quyết định. Map từ PK ThanhTra.TT_QUYET_DINH.ID. | ThanhTra | TT_QUYET_DINH | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | TT_QUYET_DINH |  |  |
| 4 | Inspection Annual Plan Id | inspection_anul_pln_id | BIGINT | X |  | F |  | FK đến Inspection Annual Plan (nullable — quyết định đột xuất không có kế hoạch). | ThanhTra | TT_QUYET_DINH | KE_HOACH_ID | FK target: Inspection Annual Plan.Inspection Annual Plan Id. |
| 5 | Inspection Annual Plan Code | inspection_anul_pln_code | STRING | X |  |  |  | Mã kế hoạch. | ThanhTra | TT_QUYET_DINH | KE_HOACH_ID | Lookup pair: Inspection Annual Plan.Inspection Annual Plan Code. Pair with Inspection Annual Plan Id. |
| 6 | Inspection Type Code | inspection_tp_code | STRING |  |  |  |  | Loại hình: THANH_TRA / KIEM_TRA. | ThanhTra | TT_QUYET_DINH | LOAI_HINH | Scheme: TT_PLAN_TYPE. |
| 7 | Document Form Type Code | doc_form_tp_code | STRING | X |  |  |  | Hình thức văn bản. | ThanhTra | TT_QUYET_DINH | HINH_THUC | Scheme: TT_DOCUMENT_FORM_TYPE. |
| 8 | Decision Number | dcsn_nbr | STRING |  |  |  |  | Số quyết định (duy nhất). | ThanhTra | TT_QUYET_DINH | SO_QUYET_DINH |  |
| 9 | Decision Name | dcsn_nm | STRING | X |  |  |  | Tên quyết định. | ThanhTra | TT_QUYET_DINH | TEN_QUYET_DINH |  |
| 10 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày ra quyết định. | ThanhTra | TT_QUYET_DINH | NGAY_RA_QUYET_DINH |  |
| 11 | Announcement Date | ancm_dt | DATE | X |  |  |  | Ngày công bố quyết định. | ThanhTra | TT_QUYET_DINH | NGAY_CONG_BO |  |
| 12 | Business Sector Code | bsn_sctr_code | STRING | X |  |  |  | Mảng nghiệp vụ. | ThanhTra | TT_QUYET_DINH | MANG_NGHIEP_VU_ID | Scheme: TT_BUSINESS_SECTOR. |
| 13 | Legal Basis Type Code | lgl_bss_tp_code | STRING | X |  |  |  | Căn cứ thanh tra (văn bản pháp lý). | ThanhTra | TT_QUYET_DINH | CAN_CU_THANH_TRA_ID | Scheme: TT_LEGAL_BASIS_TYPE. |
| 14 | Decision Content | dcsn_cntnt | STRING | X |  |  |  | Nội dung quyết định. | ThanhTra | TT_QUYET_DINH | NOI_DUNG |  |
| 15 | Remark | remark | STRING | X |  |  |  | Ghi chú. | ThanhTra | TT_QUYET_DINH | GHI_CHU |  |
| 16 | Decision Status Code | dcsn_st_code | STRING |  |  |  |  | Trạng thái: 1-Hoạt động, 0-Đã xóa. | ThanhTra | TT_QUYET_DINH | TRANG_THAI | Scheme: TT_RECORD_STATUS. |


#### 2.{IDX}.25.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Inspection Decision Id | inspection_dcsn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Inspection Annual Plan Id | inspection_anul_pln_id | Inspection Annual Plan | Inspection Annual Plan Id | inspection_anul_pln_id |




### 2.{IDX}.26 Bảng Complaint Processing Case

- **Mô tả:** Hồ sơ giải quyết đơn thư khiếu nại/tố cáo. FK → Complaint Petition.
- **Tên vật lý:** cpln_pcs_case
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Complaint Processing Case Id | cpln_pcs_case_id | BIGINT |  | X | P |  | Khóa đại diện cho hồ sơ giải quyết đơn thư. | ThanhTra | DT_HO_SO |  |  |
| 2 | Complaint Processing Case Code | cpln_pcs_case_code | STRING |  |  |  |  | Mã hồ sơ. Map từ PK ThanhTra.DT_HO_SO.ID. | ThanhTra | DT_HO_SO | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DT_HO_SO |  |  |
| 4 | Complaint Petition Id | cpln_petition_id | BIGINT |  |  | F |  | FK đến Complaint Petition — đơn thư gốc. | ThanhTra | DT_HO_SO | DON_THU_ID | FK target: Complaint Petition.Complaint Petition Id. |
| 5 | Complaint Petition Code | cpln_petition_code | STRING |  |  |  |  | Mã đơn thư gốc. | ThanhTra | DT_HO_SO | DON_THU_ID | Lookup pair: Complaint Petition.Complaint Petition Code. Pair with Complaint Petition Id. |
| 6 | Case Number | case_nbr | STRING | X |  |  |  | Số hồ sơ. | ThanhTra | DT_HO_SO | SO_HO_SO |  |
| 7 | Case Name | case_nm | STRING | X |  |  |  | Tên hồ sơ. | ThanhTra | DT_HO_SO | TEN_HO_SO |  |
| 8 | Archive Number | archv_nbr | STRING | X |  |  |  | Mã số lưu trữ. | ThanhTra | DT_HO_SO | MA_SO_LUU_TRU |  |
| 9 | Transfer Unit Name | tfr_unit_nm | STRING | X |  |  |  | Đơn vị chuyển kết quả rà soát. | ThanhTra | DT_HO_SO | DON_VI_CHUYEN_KQ |  |
| 10 | Case Status Code | case_st_code | STRING |  |  |  |  | Trạng thái: MOI_TIEP_NHAN / DANG_GIAI_QUYET / HOAN_THANH. | ThanhTra | DT_HO_SO | TRANG_THAI | Scheme: TT_CASE_STATUS. |
| 11 | Resolution Date | rsl_dt | DATE | X |  |  |  | Ngày kết thúc giải quyết. | ThanhTra | DT_HO_SO | NGAY_KET_THUC |  |
| 12 | Remark | remark | STRING | X |  |  |  | Ghi chú. | ThanhTra | DT_HO_SO | GHI_CHU |  |


#### 2.{IDX}.26.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Complaint Processing Case Id | cpln_pcs_case_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Complaint Petition Id | cpln_petition_id | Complaint Petition | Complaint Petition Id | cpln_petition_id |




### 2.{IDX}.27 Bảng Surveillance Case Document Attachment

- **Mô tả:** Văn bản đính kèm hồ sơ giám sát. FK → Surveillance Enforcement Case.
- **Tên vật lý:** surveillance_case_doc_attachment
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Surveillance Case Document Attachment Id | surveillance_case_doc_attachment_id | BIGINT |  | X | P |  | Khóa đại diện cho văn bản đính kèm hồ sơ giám sát. | ThanhTra | GS_HO_SO_VAN_BAN |  |  |
| 2 | Surveillance Case Document Attachment Code | surveillance_case_doc_attachment_code | STRING |  |  |  |  | Mã văn bản. Map từ PK ThanhTra.GS_HO_SO_VAN_BAN.ID. | ThanhTra | GS_HO_SO_VAN_BAN | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | GS_HO_SO_VAN_BAN |  |  |
| 4 | Surveillance Enforcement Case Id | surveillance_enforcement_case_id | BIGINT |  |  | F |  | FK đến Surveillance Enforcement Case. | ThanhTra | GS_HO_SO_VAN_BAN | HO_SO_ID | FK target: Surveillance Enforcement Case.Surveillance Enforcement Case Id. |
| 5 | Surveillance Enforcement Case Code | surveillance_enforcement_case_code | STRING |  |  |  |  | Mã hồ sơ giám sát. | ThanhTra | GS_HO_SO_VAN_BAN | HO_SO_ID | Lookup pair: Surveillance Enforcement Case.Surveillance Enforcement Case Code. Pair with Surveillance Enforcement Case Id. |
| 6 | Document Number | doc_nbr | STRING | X |  |  |  | Số hiệu văn bản. | ThanhTra | GS_HO_SO_VAN_BAN | SO_HIEU |  |
| 7 | Document Name | doc_nm | STRING |  |  |  |  | Tên tài liệu. | ThanhTra | GS_HO_SO_VAN_BAN | TEN_TAI_LIEU |  |
| 8 | Sequence Number | seq_nbr | INT | X |  |  |  | Số thứ tự. | ThanhTra | GS_HO_SO_VAN_BAN | SO_THU_TU |  |
| 9 | Page Count | pg_cnt | INT | X |  |  |  | Số trang. | ThanhTra | GS_HO_SO_VAN_BAN | SO_TRANG |  |
| 10 | Document Source | doc_src | STRING | X |  |  |  | Nguồn gốc tài liệu. | ThanhTra | GS_HO_SO_VAN_BAN | NGUON_GOC_TAI_LIEU |  |
| 11 | Attachment File Name | attachment_file_nm | STRING | X |  |  |  | Tên file đính kèm. | ThanhTra | GS_HO_SO_VAN_BAN | FILE_NAME |  |
| 12 | Attachment File URL | attachment_file_url | STRING | X |  |  |  | Đường dẫn file. | ThanhTra | GS_HO_SO_VAN_BAN | FILE_PATH |  |
| 13 | Attachment File Size | attachment_file_sz | INT | X |  |  |  | Kích thước file (bytes). | ThanhTra | GS_HO_SO_VAN_BAN | FILE_SIZE |  |


#### 2.{IDX}.27.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Surveillance Case Document Attachment Id | surveillance_case_doc_attachment_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Surveillance Enforcement Case Id | surveillance_enforcement_case_id | Surveillance Enforcement Case | Surveillance Enforcement Case Id | surveillance_enforcement_case_id |




### 2.{IDX}.28 Bảng Surveillance Enforcement Decision

- **Mô tả:** Văn bản xử lý vi phạm từ giám sát. FK → Surveillance Enforcement Case.
- **Tên vật lý:** surveillance_enforcement_dcsn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Surveillance Enforcement Decision Id | surveillance_enforcement_dcsn_id | BIGINT |  | X | P |  | Khóa đại diện cho quyết định xử phạt từ giám sát. | ThanhTra | GS_VAN_BAN_XU_LY |  |  |
| 2 | Surveillance Enforcement Decision Code | surveillance_enforcement_dcsn_code | STRING |  |  |  |  | Mã quyết định. Map từ PK ThanhTra.GS_VAN_BAN_XU_LY.ID. | ThanhTra | GS_VAN_BAN_XU_LY | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | GS_VAN_BAN_XU_LY |  |  |
| 4 | Surveillance Enforcement Case Id | surveillance_enforcement_case_id | BIGINT |  |  | F |  | FK đến Surveillance Enforcement Case. | ThanhTra | GS_VAN_BAN_XU_LY | HO_SO_ID | FK target: Surveillance Enforcement Case.Surveillance Enforcement Case Id. |
| 5 | Surveillance Enforcement Case Code | surveillance_enforcement_case_code | STRING |  |  |  |  | Mã hồ sơ giám sát. | ThanhTra | GS_VAN_BAN_XU_LY | HO_SO_ID | Lookup pair: Surveillance Enforcement Case.Surveillance Enforcement Case Code. Pair with Surveillance Enforcement Case Id. |
| 6 | Penalty Decision Number | pny_dcsn_nbr | STRING | X |  |  |  | Số quyết định xử phạt / số công văn nhắc nhở. | ThanhTra | GS_VAN_BAN_XU_LY | SO_QD_XU_PHAT |  |
| 7 | Violation Report Number | vln_rpt_nbr | STRING | X |  |  |  | Số biên bản vi phạm hành chính. | ThanhTra | GS_VAN_BAN_XU_LY | SO_BIEN_BAN_VPHC |  |
| 8 | Violation Report Date | vln_rpt_dt | DATE | X |  |  |  | Ngày ký biên bản vi phạm hành chính. | ThanhTra | GS_VAN_BAN_XU_LY | NGAY_BIEN_BAN |  |
| 9 | Penalty Content | pny_cntnt | STRING | X |  |  |  | Nội dung xử phạt. | ThanhTra | GS_VAN_BAN_XU_LY | NOI_DUNG_XU_PHAT |  |
| 10 | Total Penalty Amount | tot_pny_amt | DECIMAL(18,2) | X |  |  |  | Tổng số tiền phạt. | ThanhTra | GS_VAN_BAN_XU_LY | TONG_SO_TIEN_PHAT |  |
| 11 | Decision Status Code | dcsn_st_code | STRING | X |  |  |  | Trạng thái hồ sơ sau xử lý. | ThanhTra | GS_VAN_BAN_XU_LY | TRANG_THAI | Scheme: TT_CASE_STATUS. |
| 12 | Remark | remark | STRING | X |  |  |  | Ghi chú. | ThanhTra | GS_VAN_BAN_XU_LY | GHI_CHU |  |


#### 2.{IDX}.28.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Surveillance Enforcement Decision Id | surveillance_enforcement_dcsn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Surveillance Enforcement Case Id | surveillance_enforcement_case_id | Surveillance Enforcement Case | Surveillance Enforcement Case Id | surveillance_enforcement_case_id |




### 2.{IDX}.29 Bảng AML Case Document Attachment

- **Mô tả:** Văn bản đính kèm hồ sơ PCRT. FK → AML Enforcement Case.
- **Tên vật lý:** aml_case_doc_attachment
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | AML Case Document Attachment Id | aml_case_doc_attachment_id | BIGINT |  | X | P |  | Khóa đại diện cho văn bản đính kèm hồ sơ PCRT. | ThanhTra | PCRT_HO_SO_VAN_BAN |  |  |
| 2 | AML Case Document Attachment Code | aml_case_doc_attachment_code | STRING |  |  |  |  | Mã văn bản. Map từ PK ThanhTra.PCRT_HO_SO_VAN_BAN.ID. | ThanhTra | PCRT_HO_SO_VAN_BAN | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | PCRT_HO_SO_VAN_BAN |  |  |
| 4 | AML Enforcement Case Id | aml_enforcement_case_id | BIGINT |  |  | F |  | FK đến AML Enforcement Case. | ThanhTra | PCRT_HO_SO_VAN_BAN | HO_SO_ID | FK target: AML Enforcement Case.AML Enforcement Case Id. |
| 5 | AML Enforcement Case Code | aml_enforcement_case_code | STRING |  |  |  |  | Mã hồ sơ PCRT. | ThanhTra | PCRT_HO_SO_VAN_BAN | HO_SO_ID | Lookup pair: AML Enforcement Case.AML Enforcement Case Code. Pair with AML Enforcement Case Id. |
| 6 | Document Number | doc_nbr | STRING | X |  |  |  | Số hiệu văn bản. | ThanhTra | PCRT_HO_SO_VAN_BAN | SO_HIEU |  |
| 7 | Document Name | doc_nm | STRING |  |  |  |  | Tên tài liệu. | ThanhTra | PCRT_HO_SO_VAN_BAN | TEN_TAI_LIEU |  |
| 8 | Page Count | pg_cnt | INT | X |  |  |  | Số trang. | ThanhTra | PCRT_HO_SO_VAN_BAN | SO_TRANG |  |
| 9 | Document Source | doc_src | STRING | X |  |  |  | Nguồn gốc tài liệu. | ThanhTra | PCRT_HO_SO_VAN_BAN | NGUON_GOC |  |
| 10 | Attachment File Name | attachment_file_nm | STRING | X |  |  |  | Tên file đính kèm. | ThanhTra | PCRT_HO_SO_VAN_BAN | FILE_NAME |  |
| 11 | Attachment File URL | attachment_file_url | STRING | X |  |  |  | Đường dẫn file. | ThanhTra | PCRT_HO_SO_VAN_BAN | FILE_PATH |  |
| 12 | Attachment File Size | attachment_file_sz | INT | X |  |  |  | Kích thước file (bytes). | ThanhTra | PCRT_HO_SO_VAN_BAN | FILE_SIZE |  |


#### 2.{IDX}.29.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| AML Case Document Attachment Id | aml_case_doc_attachment_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| AML Enforcement Case Id | aml_enforcement_case_id | AML Enforcement Case | AML Enforcement Case Id | aml_enforcement_case_id |




### 2.{IDX}.30 Bảng AML Enforcement Decision

- **Mô tả:** Văn bản xử lý vi phạm rửa tiền. FK → AML Enforcement Case.
- **Tên vật lý:** aml_enforcement_dcsn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | AML Enforcement Decision Id | aml_enforcement_dcsn_id | BIGINT |  | X | P |  | Khóa đại diện cho quyết định xử phạt PCRT. | ThanhTra | PCRT_VAN_BAN_XU_LY |  |  |
| 2 | AML Enforcement Decision Code | aml_enforcement_dcsn_code | STRING |  |  |  |  | Mã quyết định. Map từ PK ThanhTra.PCRT_VAN_BAN_XU_LY.ID. | ThanhTra | PCRT_VAN_BAN_XU_LY | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | PCRT_VAN_BAN_XU_LY |  |  |
| 4 | AML Enforcement Case Id | aml_enforcement_case_id | BIGINT |  |  | F |  | FK đến AML Enforcement Case. | ThanhTra | PCRT_VAN_BAN_XU_LY | HO_SO_ID | FK target: AML Enforcement Case.AML Enforcement Case Id. |
| 5 | AML Enforcement Case Code | aml_enforcement_case_code | STRING |  |  |  |  | Mã hồ sơ PCRT. | ThanhTra | PCRT_VAN_BAN_XU_LY | HO_SO_ID | Lookup pair: AML Enforcement Case.AML Enforcement Case Code. Pair with AML Enforcement Case Id. |
| 6 | Penalty Decision Number | pny_dcsn_nbr | STRING | X |  |  |  | Số quyết định xử phạt / công văn nhắc nhở. | ThanhTra | PCRT_VAN_BAN_XU_LY | SO_QD_XU_PHAT |  |
| 7 | Violation Report Number | vln_rpt_nbr | STRING | X |  |  |  | Số biên bản vi phạm hành chính. | ThanhTra | PCRT_VAN_BAN_XU_LY | SO_BIEN_BAN_VPHC |  |
| 8 | Violation Report Date | vln_rpt_dt | DATE | X |  |  |  | Ngày ký biên bản vi phạm hành chính. | ThanhTra | PCRT_VAN_BAN_XU_LY | NGAY_KY_BIEN_BAN |  |
| 9 | Penalty Content | pny_cntnt | STRING | X |  |  |  | Nội dung xử phạt. | ThanhTra | PCRT_VAN_BAN_XU_LY | NOI_DUNG_XU_PHAT |  |
| 10 | Total Penalty Amount | tot_pny_amt | DECIMAL(18,2) | X |  |  |  | Tổng số tiền phạt. | ThanhTra | PCRT_VAN_BAN_XU_LY | TONG_SO_TIEN_PHAT |  |
| 11 | Decision Status Code | dcsn_st_code | STRING | X |  |  |  | Trạng thái. | ThanhTra | PCRT_VAN_BAN_XU_LY | TRANG_THAI | Scheme: TT_CASE_STATUS. |
| 12 | Remark | remark | STRING | X |  |  |  | Ghi chú. | ThanhTra | PCRT_VAN_BAN_XU_LY | GHI_CHU |  |


#### 2.{IDX}.30.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| AML Enforcement Decision Id | aml_enforcement_dcsn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| AML Enforcement Case Id | aml_enforcement_case_id | AML Enforcement Case | AML Enforcement Case Id | aml_enforcement_case_id |




### 2.{IDX}.31 Bảng Inspection Decision Subject

- **Mô tả:** Đối tượng cụ thể được thanh tra theo một quyết định. FK → Inspection Decision.
- **Tên vật lý:** inspection_dcsn_sbj
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Inspection Decision Subject Id | inspection_dcsn_sbj_id | BIGINT |  | X | P |  | Khóa đại diện cho đối tượng trong quyết định thanh tra. | ThanhTra | TT_QUYET_DINH_DOI_TUONG |  |  |
| 2 | Inspection Decision Subject Code | inspection_dcsn_sbj_code | STRING |  |  |  |  | Mã đối tượng quyết định. Map từ PK ThanhTra.TT_QUYET_DINH_DOI_TUONG.ID. | ThanhTra | TT_QUYET_DINH_DOI_TUONG | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | TT_QUYET_DINH_DOI_TUONG |  |  |
| 4 | Inspection Decision Id | inspection_dcsn_id | BIGINT |  |  | F |  | FK đến Inspection Decision. | ThanhTra | TT_QUYET_DINH_DOI_TUONG | QUYET_DINH_ID | FK target: Inspection Decision.Inspection Decision Id. |
| 5 | Inspection Decision Code | inspection_dcsn_code | STRING |  |  |  |  | Mã quyết định. | ThanhTra | TT_QUYET_DINH_DOI_TUONG | QUYET_DINH_ID | Lookup pair: Inspection Decision.Inspection Decision Code. Pair with Inspection Decision Id. |
| 6 | Sequence Number | seq_nbr | INT | X |  |  |  | Số thứ tự đối tượng trong quyết định. | ThanhTra | TT_QUYET_DINH_DOI_TUONG | STT |  |
| 7 | Subject Type Code | sbj_tp_code | STRING |  |  |  |  | Loại đối tượng: CA_NHAN / TO_CHUC. | ThanhTra | TT_QUYET_DINH_DOI_TUONG | LOAI_DOI_TUONG | Scheme: TT_PARTY_TYPE. |
| 8 | Subject Name | sbj_nm | STRING |  |  |  |  | Tên đối tượng (denormalized — DOI_TUONG_REF_ID là polymorphic FK, không resolve được thành entity duy nhất). | ThanhTra | TT_QUYET_DINH_DOI_TUONG | TEN_DOI_TUONG |  |
| 9 | Subject Reference Id | sbj_refr_id | STRING | X |  | F |  | Tham chiếu đến bảng DM_ tương ứng (polymorphic — giá trị có thể trỏ đến DM_CONG_TY_CK/QLQ/DC/DM_DOI_TUONG_KHAC). | ThanhTra | TT_QUYET_DINH_DOI_TUONG | DOI_TUONG_REF_ID | Denormalized — không map FK do polymorphic. Giữ raw value. |


#### 2.{IDX}.31.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Inspection Decision Subject Id | inspection_dcsn_sbj_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Inspection Decision Id | inspection_dcsn_id | Inspection Decision | Inspection Decision Id | inspection_dcsn_id |




### 2.{IDX}.32 Bảng Inspection Decision Team Member

- **Mô tả:** Thành viên đoàn thanh tra chỉ định theo quyết định. FK → Inspection Decision + FK → Inspection Officer.
- **Tên vật lý:** inspection_dcsn_team_mbr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Inspection Decision Team Member Id | inspection_dcsn_team_mbr_id | BIGINT |  | X | P |  | Khóa đại diện cho thành viên đoàn thanh tra trong quyết định. | ThanhTra | TT_QUYET_DINH_THANH_PHAN |  |  |
| 2 | Inspection Decision Team Member Code | inspection_dcsn_team_mbr_code | STRING |  |  |  |  | Mã thành viên. Map từ PK ThanhTra.TT_QUYET_DINH_THANH_PHAN.ID. | ThanhTra | TT_QUYET_DINH_THANH_PHAN | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | TT_QUYET_DINH_THANH_PHAN |  |  |
| 4 | Inspection Decision Id | inspection_dcsn_id | BIGINT |  |  | F |  | FK đến Inspection Decision. | ThanhTra | TT_QUYET_DINH_THANH_PHAN | QUYET_DINH_ID | FK target: Inspection Decision.Inspection Decision Id. |
| 5 | Inspection Decision Code | inspection_dcsn_code | STRING |  |  |  |  | Mã quyết định. | ThanhTra | TT_QUYET_DINH_THANH_PHAN | QUYET_DINH_ID | Lookup pair: Inspection Decision.Inspection Decision Code. Pair with Inspection Decision Id. |
| 6 | Inspection Officer Id | inspection_ofcr_id | BIGINT |  |  | F |  | FK đến Inspection Officer — cán bộ trong đoàn. | ThanhTra | TT_QUYET_DINH_THANH_PHAN | CAN_BO_ID | FK target: Inspection Officer.Inspection Officer Id. |
| 7 | Inspection Officer Code | inspection_ofcr_code | STRING |  |  |  |  | Mã cán bộ. | ThanhTra | TT_QUYET_DINH_THANH_PHAN | CAN_BO_ID | Lookup pair: Inspection Officer.Inspection Officer Code. Pair with Inspection Officer Id. |
| 8 | Team Role Description | team_rl_dsc | STRING | X |  |  |  | Vai trò trong đoàn (trưởng đoàn, thành viên...). | ThanhTra | TT_QUYET_DINH_THANH_PHAN | VAI_TRO |  |
| 9 | Sequence Number | seq_nbr | INT | X |  |  |  | Số thứ tự trong đoàn. | ThanhTra | TT_QUYET_DINH_THANH_PHAN | STT |  |


#### 2.{IDX}.32.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Inspection Decision Team Member Id | inspection_dcsn_team_mbr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Inspection Decision Id | inspection_dcsn_id | Inspection Decision | Inspection Decision Id | inspection_dcsn_id |
| Inspection Officer Id | inspection_ofcr_id | Inspection Officer | Inspection Officer Id | inspection_ofcr_id |




### 2.{IDX}.33 Bảng Inspection Decision Document Attachment

- **Mô tả:** Văn bản đính kèm quyết định thanh tra. FK → Inspection Decision.
- **Tên vật lý:** inspection_dcsn_doc_attachment
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Inspection Decision Document Attachment Id | inspection_dcsn_doc_attachment_id | BIGINT |  | X | P |  | Khóa đại diện cho văn bản kèm quyết định thanh tra. | ThanhTra | TT_QUYET_DINH_VAN_BAN |  |  |
| 2 | Inspection Decision Document Attachment Code | inspection_dcsn_doc_attachment_code | STRING |  |  |  |  | Mã văn bản. Map từ PK ThanhTra.TT_QUYET_DINH_VAN_BAN.ID. | ThanhTra | TT_QUYET_DINH_VAN_BAN | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | TT_QUYET_DINH_VAN_BAN |  |  |
| 4 | Inspection Decision Id | inspection_dcsn_id | BIGINT |  |  | F |  | FK đến Inspection Decision. | ThanhTra | TT_QUYET_DINH_VAN_BAN | QUYET_DINH_ID | FK target: Inspection Decision.Inspection Decision Id. |
| 5 | Inspection Decision Code | inspection_dcsn_code | STRING |  |  |  |  | Mã quyết định. | ThanhTra | TT_QUYET_DINH_VAN_BAN | QUYET_DINH_ID | Lookup pair: Inspection Decision.Inspection Decision Code. Pair with Inspection Decision Id. |
| 6 | Document Number | doc_nbr | STRING | X |  |  |  | Số hiệu văn bản. | ThanhTra | TT_QUYET_DINH_VAN_BAN | SO_HIEU |  |
| 7 | Document Name | doc_nm | STRING |  |  |  |  | Tên tài liệu. | ThanhTra | TT_QUYET_DINH_VAN_BAN | TEN_TAI_LIEU |  |
| 8 | Page Sequence Number | pg_seq_nbr | INT | X |  |  |  | Số thứ tự. | ThanhTra | TT_QUYET_DINH_VAN_BAN | SO_THU_TU |  |
| 9 | Page Count | pg_cnt | INT | X |  |  |  | Số trang. | ThanhTra | TT_QUYET_DINH_VAN_BAN | SO_TRANG |  |
| 10 | Document Source | doc_src | STRING | X |  |  |  | Nguồn gốc tài liệu. | ThanhTra | TT_QUYET_DINH_VAN_BAN | NGUON_GOC_TAI_LIEU |  |
| 11 | Attachment File Name | attachment_file_nm | STRING | X |  |  |  | Tên file đính kèm. | ThanhTra | TT_QUYET_DINH_VAN_BAN | FILE_NAME |  |
| 12 | Attachment File URL | attachment_file_url | STRING | X |  |  |  | Đường dẫn file. | ThanhTra | TT_QUYET_DINH_VAN_BAN | FILE_PATH |  |
| 13 | Attachment File Size | attachment_file_sz | INT | X |  |  |  | Kích thước file (bytes). | ThanhTra | TT_QUYET_DINH_VAN_BAN | FILE_SIZE |  |


#### 2.{IDX}.33.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Inspection Decision Document Attachment Id | inspection_dcsn_doc_attachment_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Inspection Decision Id | inspection_dcsn_id | Inspection Decision | Inspection Decision Id | inspection_dcsn_id |




### 2.{IDX}.34 Bảng Inspection Case

- **Mô tả:** Hồ sơ thanh tra cụ thể — tập hợp tài liệu và kết quả 1 cuộc thanh tra. FK → Inspection Decision. Thông tin đối tượng denormalized (snapshot tại thời điểm thanh tra).
- **Tên vật lý:** inspection_case
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Inspection Case Id | inspection_case_id | BIGINT |  | X | P |  | Khóa đại diện cho hồ sơ thanh tra. | ThanhTra | TT_HO_SO |  |  |
| 2 | Inspection Case Code | inspection_case_code | STRING |  |  |  |  | Mã hồ sơ. Map từ PK ThanhTra.TT_HO_SO.ID. | ThanhTra | TT_HO_SO | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | TT_HO_SO |  |  |
| 4 | Inspection Decision Id | inspection_dcsn_id | BIGINT |  |  | F |  | FK đến Inspection Decision. | ThanhTra | TT_HO_SO | QUYET_DINH_ID | FK target: Inspection Decision.Inspection Decision Id. |
| 5 | Inspection Decision Code | inspection_dcsn_code | STRING |  |  |  |  | Mã quyết định. | ThanhTra | TT_HO_SO | QUYET_DINH_ID | Lookup pair: Inspection Decision.Inspection Decision Code. Pair with Inspection Decision Id. |
| 6 | Inspection Type Code | inspection_tp_code | STRING |  |  |  |  | Loại hình: THANH_TRA / KIEM_TRA. | ThanhTra | TT_HO_SO | LOAI_HINH | Scheme: TT_PLAN_TYPE. |
| 7 | Business Sector Code | bsn_sctr_code | STRING | X |  |  |  | Mảng nghiệp vụ. | ThanhTra | TT_HO_SO | MANG_NGHIEP_VU_ID | Scheme: TT_BUSINESS_SECTOR. |
| 8 | Case Number | case_nbr | STRING |  |  |  |  | Mã hồ sơ nghiệp vụ (duy nhất). | ThanhTra | TT_HO_SO | MA_HO_SO |  |
| 9 | Case Name | case_nm | STRING | X |  |  |  | Tên hồ sơ. | ThanhTra | TT_HO_SO | TEN_HO_SO |  |
| 10 | Archive Number | archv_nbr | STRING | X |  |  |  | Mã số lưu trữ. | ThanhTra | TT_HO_SO | MA_SO_LUU_TRU |  |
| 11 | Received Date | rcvd_dt | DATE | X |  |  |  | Ngày nhận hồ sơ. | ThanhTra | TT_HO_SO | NGAY_NHAN_HO_SO |  |
| 12 | Data Source Description | data_src_dsc | STRING | X |  |  |  | Nguồn cung cấp thông tin. | ThanhTra | TT_HO_SO | NGUON_CUNG_CAP |  |
| 13 | Case Content | case_cntnt | STRING | X |  |  |  | Nội dung hồ sơ. | ThanhTra | TT_HO_SO | NOI_DUNG |  |
| 14 | Subject Type Code | sbj_tp_code | STRING | X |  |  |  | Loại đối tượng: CA_NHAN / TO_CHUC (snapshot). | ThanhTra | TT_HO_SO | LOAI_DOI_TUONG | Scheme: TT_PARTY_TYPE. |
| 15 | Subject Full Name | sbj_full_nm | STRING | X |  |  |  | Họ tên cá nhân đối tượng (snapshot — grain là hồ sơ không phải IP). | ThanhTra | TT_HO_SO | HO_TEN |  |
| 16 | Subject Date of Birth | sbj_dob | DATE | X |  |  |  | Ngày sinh cá nhân đối tượng (snapshot). | ThanhTra | TT_HO_SO | NGAY_SINH |  |
| 17 | Subject Gender Code | sbj_gnd_code | STRING | X |  |  |  | Giới tính cá nhân đối tượng (snapshot). | ThanhTra | TT_HO_SO | GIOI_TINH | Scheme: INDIVIDUAL_GENDER. |
| 18 | Subject Nationality | sbj_nationality | STRING | X |  |  |  | Quốc tịch đối tượng (snapshot — text tự do). | ThanhTra | TT_HO_SO | QUOC_TICH |  |
| 19 | Subject Account Number | sbj_ac_nbr | STRING | X |  |  |  | Số tài khoản đối tượng (snapshot). | ThanhTra | TT_HO_SO | SO_TAI_KHOAN |  |
| 20 | Subject Account Bank Name | sbj_ac_bnk_nm | STRING | X |  |  |  | Nơi mở tài khoản (snapshot). | ThanhTra | TT_HO_SO | NOI_MO_TAI_KHOAN |  |
| 21 | Subject Id Number | sbj_id_nbr | STRING | X |  |  |  | Số CMND/CCCD đối tượng cá nhân (snapshot). | ThanhTra | TT_HO_SO | SO_CMND |  |
| 22 | Subject Phone Number | sbj_ph_nbr | STRING | X |  |  |  | Số điện thoại đối tượng (snapshot). | ThanhTra | TT_HO_SO | SO_DIEN_THOAI |  |
| 23 | Subject Email | sbj_email | STRING | X |  |  |  | Email đối tượng (snapshot). | ThanhTra | TT_HO_SO | EMAIL |  |
| 24 | Subject Address | sbj_adr | STRING | X |  |  |  | Địa chỉ đối tượng (snapshot). | ThanhTra | TT_HO_SO | DIA_CHI |  |
| 25 | Subject Organization Name | sbj_org_nm | STRING | X |  |  |  | Tên tổ chức đối tượng (snapshot). | ThanhTra | TT_HO_SO | TEN_DOI_TUONG |  |
| 26 | Subject Organization Short Name | sbj_org_shrt_nm | STRING | X |  |  |  | Tên viết tắt tổ chức (snapshot). | ThanhTra | TT_HO_SO | TEN_VIET_TAT |  |
| 27 | Subject Representative Name | sbj_representative_nm | STRING | X |  |  |  | Người đại diện tổ chức (snapshot). | ThanhTra | TT_HO_SO | NGUOI_DAI_DIEN |  |
| 28 | Subject Business License Number | sbj_bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh tổ chức (snapshot). | ThanhTra | TT_HO_SO | SO_GPKD |  |
| 29 | Subject Country | sbj_cty | STRING | X |  |  |  | Quốc gia tổ chức (snapshot — text tự do). | ThanhTra | TT_HO_SO | QUOC_GIA |  |
| 30 | Subject Website | sbj_webst | STRING | X |  |  |  | Website đối tượng (snapshot). | ThanhTra | TT_HO_SO | WEBSITE |  |
| 31 | Subject Fax Number | sbj_fax_nbr | STRING | X |  |  |  | Số fax đối tượng (snapshot). | ThanhTra | TT_HO_SO | FAX |  |
| 32 | Case Status Code | case_st_code | STRING |  |  |  |  | Trạng thái hồ sơ. | ThanhTra | TT_HO_SO | TRANG_THAI_ID | Scheme: TT_CASE_STATUS. |
| 33 | Responsible Officer Id | rspl_ofcr_id | BIGINT | X |  | F |  | FK đến Inspection Officer — lãnh đạo phụ trách. | ThanhTra | TT_HO_SO | LANH_DAO_PHU_TRACH | FK target: Inspection Officer.Inspection Officer Id. |
| 34 | Responsible Officer Code | rspl_ofcr_code | STRING | X |  |  |  | Mã cán bộ lãnh đạo phụ trách. | ThanhTra | TT_HO_SO | LANH_DAO_PHU_TRACH | Lookup pair: Inspection Officer.Inspection Officer Code. Pair with Responsible Officer Id. |
| 35 | Processing Officer Id | pcs_ofcr_id | BIGINT | X |  | F |  | FK đến Inspection Officer — chuyên viên xử lý. | ThanhTra | TT_HO_SO | CHUYEN_VIEN_XU_LY | FK target: Inspection Officer.Inspection Officer Id. |
| 36 | Processing Officer Code | pcs_ofcr_code | STRING | X |  |  |  | Mã cán bộ chuyên viên xử lý. | ThanhTra | TT_HO_SO | CHUYEN_VIEN_XU_LY | Lookup pair: Inspection Officer.Inspection Officer Code. Pair with Processing Officer Id. |


#### 2.{IDX}.34.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Inspection Case Id | inspection_case_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Inspection Decision Id | inspection_dcsn_id | Inspection Decision | Inspection Decision Id | inspection_dcsn_id |
| Responsible Officer Id | rspl_ofcr_id | Inspection Officer | Inspection Officer Id | inspection_ofcr_id |
| Processing Officer Id | pcs_ofcr_id | Inspection Officer | Inspection Officer Id | inspection_ofcr_id |




### 2.{IDX}.35 Bảng Complaint Processing Case Document Attachment

- **Mô tả:** Văn bản đính kèm hồ sơ giải quyết đơn thư. FK → Complaint Processing Case.
- **Tên vật lý:** cpln_pcs_case_doc_attachment
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Complaint Processing Case Document Attachment Id | cpln_pcs_case_doc_attachment_id | BIGINT |  | X | P |  | Khóa đại diện cho văn bản đính kèm hồ sơ đơn thư. | ThanhTra | DT_HO_SO_VAN_BAN |  |  |
| 2 | Complaint Processing Case Document Attachment Code | cpln_pcs_case_doc_attachment_code | STRING |  |  |  |  | Mã văn bản. Map từ PK ThanhTra.DT_HO_SO_VAN_BAN.ID. | ThanhTra | DT_HO_SO_VAN_BAN | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DT_HO_SO_VAN_BAN |  |  |
| 4 | Complaint Processing Case Id | cpln_pcs_case_id | BIGINT |  |  | F |  | FK đến Complaint Processing Case. | ThanhTra | DT_HO_SO_VAN_BAN | HO_SO_ID | FK target: Complaint Processing Case.Complaint Processing Case Id. |
| 5 | Complaint Processing Case Code | cpln_pcs_case_code | STRING |  |  |  |  | Mã hồ sơ đơn thư. | ThanhTra | DT_HO_SO_VAN_BAN | HO_SO_ID | Lookup pair: Complaint Processing Case.Complaint Processing Case Code. Pair with Complaint Processing Case Id. |
| 6 | Document Type Code | doc_tp_code | STRING | X |  |  |  | Loại văn bản: QUYET_DINH_THU_LY / BIEN_BAN_VPHC / CONG_VAN_TB / DON_THU. | ThanhTra | DT_HO_SO_VAN_BAN | LOAI_VAN_BAN | Scheme: TT_CASE_TYPE. |
| 7 | Document Number | doc_nbr | STRING | X |  |  |  | Số hiệu văn bản. | ThanhTra | DT_HO_SO_VAN_BAN | SO_HIEU |  |
| 8 | Document Name | doc_nm | STRING |  |  |  |  | Tên tài liệu. | ThanhTra | DT_HO_SO_VAN_BAN | TEN_TAI_LIEU |  |
| 9 | Page Count | pg_cnt | INT | X |  |  |  | Số trang. | ThanhTra | DT_HO_SO_VAN_BAN | SO_TRANG |  |
| 10 | Document Source | doc_src | STRING | X |  |  |  | Nguồn gốc. | ThanhTra | DT_HO_SO_VAN_BAN | NGUON_GOC |  |
| 11 | Attachment File Name | attachment_file_nm | STRING | X |  |  |  | Tên file đính kèm. | ThanhTra | DT_HO_SO_VAN_BAN | FILE_NAME |  |
| 12 | Attachment File URL | attachment_file_url | STRING | X |  |  |  | Đường dẫn file. | ThanhTra | DT_HO_SO_VAN_BAN | FILE_PATH |  |
| 13 | Attachment File Size | attachment_file_sz | INT | X |  |  |  | Kích thước file (bytes). | ThanhTra | DT_HO_SO_VAN_BAN | FILE_SIZE |  |


#### 2.{IDX}.35.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Complaint Processing Case Document Attachment Id | cpln_pcs_case_doc_attachment_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Complaint Processing Case Id | cpln_pcs_case_id | Complaint Processing Case | Complaint Processing Case Id | cpln_pcs_case_id |




### 2.{IDX}.36 Bảng Complaint Processing Conclusion

- **Mô tả:** Kết luận giải quyết đơn thư. FK → Complaint Processing Case.
- **Tên vật lý:** cpln_pcs_conclusion
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Complaint Processing Conclusion Id | cpln_pcs_conclusion_id | BIGINT |  | X | P |  | Khóa đại diện cho kết luận giải quyết đơn thư. | ThanhTra | DT_KET_LUAN |  |  |
| 2 | Complaint Processing Conclusion Code | cpln_pcs_conclusion_code | STRING |  |  |  |  | Mã kết luận. Map từ PK ThanhTra.DT_KET_LUAN.ID. | ThanhTra | DT_KET_LUAN | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DT_KET_LUAN |  |  |
| 4 | Complaint Processing Case Id | cpln_pcs_case_id | BIGINT |  |  | F |  | FK đến Complaint Processing Case. | ThanhTra | DT_KET_LUAN | HO_SO_ID | FK target: Complaint Processing Case.Complaint Processing Case Id. |
| 5 | Complaint Processing Case Code | cpln_pcs_case_code | STRING |  |  |  |  | Mã hồ sơ đơn thư. | ThanhTra | DT_KET_LUAN | HO_SO_ID | Lookup pair: Complaint Processing Case.Complaint Processing Case Code. Pair with Complaint Processing Case Id. |
| 6 | Conclusion Number | conclusion_nbr | STRING | X |  |  |  | Số kết luận. | ThanhTra | DT_KET_LUAN | SO_KET_LUAN |  |
| 7 | Conclusion Date | conclusion_dt | DATE | X |  |  |  | Ngày kết luận. | ThanhTra | DT_KET_LUAN | NGAY_KET_LUAN |  |
| 8 | Resolution Result Code | rsl_rslt_code | STRING | X |  |  |  | Kết quả giải quyết: DUNG / SAI / DUNG_MOT_PHAN. | ThanhTra | DT_KET_LUAN | KET_QUA | Scheme: TT_RESOLUTION_RESULT. |
| 9 | Conclusion Content | conclusion_cntnt | STRING | X |  |  |  | Nội dung kết luận. | ThanhTra | DT_KET_LUAN | KET_LUAN |  |
| 10 | Official Conclusion Date | offc_conclusion_dt | DATE | X |  |  |  | Ngày ra kết luận chính thức. | ThanhTra | DT_KET_LUAN | NGAY_RA_KET_LUAN |  |
| 11 | Referred to Ministry Date | referred_to_ministry_dt | DATE | X |  |  |  | Ngày chuyển cho thanh tra bộ. | ThanhTra | DT_KET_LUAN | NGAY_CHUYEN_THANH_TRA_BO |  |
| 12 | Conclusion Status Code | conclusion_st_code | STRING |  |  |  |  | Trạng thái: DANG_GIAI_QUYET / DA_HOAN_THANH. | ThanhTra | DT_KET_LUAN | TRANG_THAI | Scheme: TT_CASE_STATUS. |
| 13 | Remark | remark | STRING | X |  |  |  | Ghi chú. | ThanhTra | DT_KET_LUAN | GHI_CHU |  |


#### 2.{IDX}.36.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Complaint Processing Conclusion Id | cpln_pcs_conclusion_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Complaint Processing Case Id | cpln_pcs_case_id | Complaint Processing Case | Complaint Processing Case Id | cpln_pcs_case_id |




### 2.{IDX}.37 Bảng Complaint Enforcement Decision

- **Mô tả:** Văn bản xử lý / quyết định xử phạt từ hồ sơ đơn thư. FK → Complaint Processing Case.
- **Tên vật lý:** cpln_enforcement_dcsn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Complaint Enforcement Decision Id | cpln_enforcement_dcsn_id | BIGINT |  | X | P |  | Khóa đại diện cho quyết định xử phạt từ hồ sơ đơn thư. | ThanhTra | DT_VAN_BAN_XU_LY |  |  |
| 2 | Complaint Enforcement Decision Code | cpln_enforcement_dcsn_code | STRING |  |  |  |  | Mã quyết định xử phạt. Map từ PK ThanhTra.DT_VAN_BAN_XU_LY.ID. | ThanhTra | DT_VAN_BAN_XU_LY | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DT_VAN_BAN_XU_LY |  |  |
| 4 | Complaint Processing Case Id | cpln_pcs_case_id | BIGINT |  |  | F |  | FK đến Complaint Processing Case (OQ-5: DT_VAN_BAN_XU_LY FK → DT_HO_SO). | ThanhTra | DT_VAN_BAN_XU_LY | HO_SO_ID | FK target: Complaint Processing Case.Complaint Processing Case Id. |
| 5 | Complaint Processing Case Code | cpln_pcs_case_code | STRING |  |  |  |  | Mã hồ sơ đơn thư. | ThanhTra | DT_VAN_BAN_XU_LY | HO_SO_ID | Lookup pair: Complaint Processing Case.Complaint Processing Case Code. Pair with Complaint Processing Case Id. |
| 6 | Penalty Decision Number | pny_dcsn_nbr | STRING | X |  |  |  | Số quyết định xử phạt. | ThanhTra | DT_VAN_BAN_XU_LY | SO_QD_XU_PHAT |  |
| 7 | Violation Report Number | vln_rpt_nbr | STRING | X |  |  |  | Số biên bản vi phạm hành chính. | ThanhTra | DT_VAN_BAN_XU_LY | SO_BIEN_BAN_VPHC |  |
| 8 | Violation Report Date | vln_rpt_dt | DATE | X |  |  |  | Ngày biên bản vi phạm hành chính. | ThanhTra | DT_VAN_BAN_XU_LY | NGAY_BIEN_BAN |  |
| 9 | Penalty Content | pny_cntnt | STRING | X |  |  |  | Nội dung xử phạt. | ThanhTra | DT_VAN_BAN_XU_LY | NOI_DUNG_XU_PHAT |  |
| 10 | Decision Status Code | dcsn_st_code | STRING |  |  |  |  | Trạng thái: CHUA_NOP_PHAT / DA_NOP_PHAT / NOP_PHAT_NHIEU_LAN. | ThanhTra | DT_VAN_BAN_XU_LY | TRANG_THAI | Scheme: TT_PENALTY_STATUS. |
| 11 | Remark | remark | STRING | X |  |  |  | Ghi chú. | ThanhTra | DT_VAN_BAN_XU_LY | GHI_CHU |  |


#### 2.{IDX}.37.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Complaint Enforcement Decision Id | cpln_enforcement_dcsn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Complaint Processing Case Id | cpln_pcs_case_id | Complaint Processing Case | Complaint Processing Case Id | cpln_pcs_case_id |




### 2.{IDX}.38 Bảng Surveillance Enforcement Decision File Attachment

- **Mô tả:** File đính kèm văn bản xử lý giám sát. FK → Surveillance Enforcement Decision.
- **Tên vật lý:** surveillance_enforcement_dcsn_file_attachment
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Surveillance Enforcement Decision File Attachment Id | surveillance_enforcement_dcsn_file_attachment_id | BIGINT |  | X | P |  | Khóa đại diện cho file đính kèm quyết định xử phạt giám sát. | ThanhTra | GS_VAN_BAN_XU_LY_FILE |  |  |
| 2 | Surveillance Enforcement Decision File Attachment Code | surveillance_enforcement_dcsn_file_attachment_code | STRING |  |  |  |  | Mã file. Map từ PK ThanhTra.GS_VAN_BAN_XU_LY_FILE.ID. | ThanhTra | GS_VAN_BAN_XU_LY_FILE | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | GS_VAN_BAN_XU_LY_FILE |  |  |
| 4 | Surveillance Enforcement Decision Id | surveillance_enforcement_dcsn_id | BIGINT |  |  | F |  | FK đến Surveillance Enforcement Decision. | ThanhTra | GS_VAN_BAN_XU_LY_FILE | VAN_BAN_XU_LY_ID | FK target: Surveillance Enforcement Decision.Surveillance Enforcement Decision Id. |
| 5 | Surveillance Enforcement Decision Code | surveillance_enforcement_dcsn_code | STRING |  |  |  |  | Mã quyết định xử phạt. | ThanhTra | GS_VAN_BAN_XU_LY_FILE | VAN_BAN_XU_LY_ID | Lookup pair: Surveillance Enforcement Decision.Surveillance Enforcement Decision Code. Pair with Surveillance Enforcement Decision Id. |
| 6 | Document Number | doc_nbr | STRING | X |  |  |  | Số hiệu văn bản. | ThanhTra | GS_VAN_BAN_XU_LY_FILE | SO_HIEU |  |
| 7 | Document Name | doc_nm | STRING |  |  |  |  | Tên tài liệu. | ThanhTra | GS_VAN_BAN_XU_LY_FILE | TEN_TAI_LIEU |  |
| 8 | Page Count | pg_cnt | INT | X |  |  |  | Số trang. | ThanhTra | GS_VAN_BAN_XU_LY_FILE | SO_TRANG |  |
| 9 | Document Source | doc_src | STRING | X |  |  |  | Nguồn gốc tài liệu. | ThanhTra | GS_VAN_BAN_XU_LY_FILE | NGUON_GOC |  |
| 10 | Attachment File Name | attachment_file_nm | STRING | X |  |  |  | Tên file đính kèm. | ThanhTra | GS_VAN_BAN_XU_LY_FILE | FILE_NAME |  |
| 11 | Attachment File URL | attachment_file_url | STRING | X |  |  |  | Đường dẫn file. | ThanhTra | GS_VAN_BAN_XU_LY_FILE | FILE_PATH |  |


#### 2.{IDX}.38.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Surveillance Enforcement Decision File Attachment Id | surveillance_enforcement_dcsn_file_attachment_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Surveillance Enforcement Decision Id | surveillance_enforcement_dcsn_id | Surveillance Enforcement Decision | Surveillance Enforcement Decision Id | surveillance_enforcement_dcsn_id |




### 2.{IDX}.39 Bảng Surveillance Penalty Announcement

- **Mô tả:** Công bố quyết định xử phạt từ giám sát. FK → Surveillance Enforcement Decision.
- **Tên vật lý:** surveillance_pny_ancm
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Surveillance Penalty Announcement Id | surveillance_pny_ancm_id | BIGINT |  | X | P |  | Khóa đại diện cho thông báo công bố xử phạt từ giám sát. | ThanhTra | GS_CONG_BO_XU_PHAT |  |  |
| 2 | Surveillance Penalty Announcement Code | surveillance_pny_ancm_code | STRING |  |  |  |  | Mã công bố. Map từ PK ThanhTra.GS_CONG_BO_XU_PHAT.ID. | ThanhTra | GS_CONG_BO_XU_PHAT | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | GS_CONG_BO_XU_PHAT |  |  |
| 4 | Surveillance Enforcement Case Id | surveillance_enforcement_case_id | BIGINT | X |  | F |  | FK đến Surveillance Enforcement Case (via HO_SO_ID — redundant navigation FK). | ThanhTra | GS_CONG_BO_XU_PHAT | HO_SO_ID | FK target: Surveillance Enforcement Case.Surveillance Enforcement Case Id. |
| 5 | Surveillance Enforcement Case Code | surveillance_enforcement_case_code | STRING | X |  |  |  | Mã hồ sơ giám sát. | ThanhTra | GS_CONG_BO_XU_PHAT | HO_SO_ID | Lookup pair: Surveillance Enforcement Case.Surveillance Enforcement Case Code. Pair with Surveillance Enforcement Case Id. |
| 6 | Surveillance Enforcement Decision Id | surveillance_enforcement_dcsn_id | BIGINT |  |  | F |  | FK đến Surveillance Enforcement Decision (via QUYET_DINH_XU_PHAT_ID). | ThanhTra | GS_CONG_BO_XU_PHAT | QUYET_DINH_XU_PHAT_ID | FK target: Surveillance Enforcement Decision.Surveillance Enforcement Decision Id. |
| 7 | Surveillance Enforcement Decision Code | surveillance_enforcement_dcsn_code | STRING |  |  |  |  | Mã quyết định xử phạt. | ThanhTra | GS_CONG_BO_XU_PHAT | QUYET_DINH_XU_PHAT_ID | Lookup pair: Surveillance Enforcement Decision.Surveillance Enforcement Decision Code. Pair with Surveillance Enforcement Decision Id. |
| 8 | Announcement Channel | ancm_cnl | STRING | X |  |  |  | Chuyên mục / kênh công bố. | ThanhTra | GS_CONG_BO_XU_PHAT | CHUYEN_MUC |  |
| 9 | Announcement Content | ancm_cntnt | STRING | X |  |  |  | Nội dung công bố. | ThanhTra | GS_CONG_BO_XU_PHAT | NOI_DUNG_CONG_BO |  |
| 10 | Announcement Date | ancm_dt | DATE | X |  |  |  | Ngày công bố. | ThanhTra | GS_CONG_BO_XU_PHAT | NGAY_CONG_BO |  |
| 11 | Announcement Status Code | ancm_st_code | STRING |  |  |  |  | Trạng thái: CHO_DUYET / DA_DUYET. | ThanhTra | GS_CONG_BO_XU_PHAT | TRANG_THAI | Scheme: TT_ANNOUNCEMENT_STATUS. |


#### 2.{IDX}.39.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Surveillance Penalty Announcement Id | surveillance_pny_ancm_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Surveillance Enforcement Case Id | surveillance_enforcement_case_id | Surveillance Enforcement Case | Surveillance Enforcement Case Id | surveillance_enforcement_case_id |
| Surveillance Enforcement Decision Id | surveillance_enforcement_dcsn_id | Surveillance Enforcement Decision | Surveillance Enforcement Decision Id | surveillance_enforcement_dcsn_id |




### 2.{IDX}.40 Bảng Inspection Case Officer Assignment

- **Mô tả:** Phân công cán bộ phụ trách hồ sơ thanh tra. FK → Inspection Case + FK → Inspection Officer.
- **Tên vật lý:** inspection_case_ofcr_asgnm
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Inspection Case Officer Assignment Id | inspection_case_ofcr_asgnm_id | BIGINT |  | X | P |  | Khóa đại diện cho phân công cán bộ xử lý hồ sơ thanh tra. | ThanhTra | TT_HO_SO_CAN_BO |  |  |
| 2 | Inspection Case Officer Assignment Code | inspection_case_ofcr_asgnm_code | STRING |  |  |  |  | Mã phân công. Map từ PK ThanhTra.TT_HO_SO_CAN_BO.ID. | ThanhTra | TT_HO_SO_CAN_BO | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | TT_HO_SO_CAN_BO |  |  |
| 4 | Inspection Case Id | inspection_case_id | BIGINT |  |  | F |  | FK đến Inspection Case. | ThanhTra | TT_HO_SO_CAN_BO | HO_SO_ID | FK target: Inspection Case.Inspection Case Id. |
| 5 | Inspection Case Code | inspection_case_code | STRING |  |  |  |  | Mã hồ sơ thanh tra. | ThanhTra | TT_HO_SO_CAN_BO | HO_SO_ID | Lookup pair: Inspection Case.Inspection Case Code. Pair with Inspection Case Id. |
| 6 | Inspection Officer Id | inspection_ofcr_id | BIGINT |  |  | F |  | FK đến Inspection Officer — cán bộ được phân công. | ThanhTra | TT_HO_SO_CAN_BO | CAN_BO_ID | FK target: Inspection Officer.Inspection Officer Id. |
| 7 | Inspection Officer Code | inspection_ofcr_code | STRING |  |  |  |  | Mã cán bộ. | ThanhTra | TT_HO_SO_CAN_BO | CAN_BO_ID | Lookup pair: Inspection Officer.Inspection Officer Code. Pair with Inspection Officer Id. |
| 8 | Officer Role Code | ofcr_rl_code | STRING |  |  |  |  | Loại phân công: LANH_DAO / CHUYEN_VIEN. | ThanhTra | TT_HO_SO_CAN_BO | LOAI_PHAN_CONG | Scheme: TT_OFFICER_ROLE. |
| 9 | Assignment Date | asgnm_dt | DATE | X |  |  |  | Ngày phân công. | ThanhTra | TT_HO_SO_CAN_BO | NGAY_PHAN_CONG |  |
| 10 | Remark | remark | STRING | X |  |  |  | Ghi chú phân công. | ThanhTra | TT_HO_SO_CAN_BO | GHI_CHU |  |


#### 2.{IDX}.40.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Inspection Case Officer Assignment Id | inspection_case_ofcr_asgnm_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Inspection Case Id | inspection_case_id | Inspection Case | Inspection Case Id | inspection_case_id |
| Inspection Officer Id | inspection_ofcr_id | Inspection Officer | Inspection Officer Id | inspection_ofcr_id |




### 2.{IDX}.41 Bảng Inspection Case Document Attachment

- **Mô tả:** Văn bản đính kèm hồ sơ thanh tra (biên bản làm việc v.v.). FK → Inspection Case.
- **Tên vật lý:** inspection_case_doc_attachment
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Inspection Case Document Attachment Id | inspection_case_doc_attachment_id | BIGINT |  | X | P |  | Khóa đại diện cho văn bản đính kèm hồ sơ thanh tra. | ThanhTra | TT_HO_SO_VAN_BAN |  |  |
| 2 | Inspection Case Document Attachment Code | inspection_case_doc_attachment_code | STRING |  |  |  |  | Mã văn bản. Map từ PK ThanhTra.TT_HO_SO_VAN_BAN.ID. | ThanhTra | TT_HO_SO_VAN_BAN | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | TT_HO_SO_VAN_BAN |  |  |
| 4 | Inspection Case Id | inspection_case_id | BIGINT |  |  | F |  | FK đến Inspection Case. | ThanhTra | TT_HO_SO_VAN_BAN | HO_SO_ID | FK target: Inspection Case.Inspection Case Id. |
| 5 | Inspection Case Code | inspection_case_code | STRING |  |  |  |  | Mã hồ sơ thanh tra. | ThanhTra | TT_HO_SO_VAN_BAN | HO_SO_ID | Lookup pair: Inspection Case.Inspection Case Code. Pair with Inspection Case Id. |
| 6 | Document Type Code | doc_tp_code | STRING | X |  |  |  | Loại văn bản: KE_HOACH / QUYET_DINH / BIEN_BAN / KET_LUAN / CONG_VAN / GIAI_TRINH. | ThanhTra | TT_HO_SO_VAN_BAN | LOAI_VAN_BAN | Scheme: TT_CASE_TYPE. |
| 7 | Document Number | doc_nbr | STRING | X |  |  |  | Số hiệu văn bản. | ThanhTra | TT_HO_SO_VAN_BAN | SO_HIEU |  |
| 8 | Document Name | doc_nm | STRING |  |  |  |  | Tên tài liệu. | ThanhTra | TT_HO_SO_VAN_BAN | TEN_TAI_LIEU |  |
| 9 | Page Sequence Number | pg_seq_nbr | INT | X |  |  |  | Số thứ tự. | ThanhTra | TT_HO_SO_VAN_BAN | SO_THU_TU |  |
| 10 | Page Count | pg_cnt | INT | X |  |  |  | Số trang. | ThanhTra | TT_HO_SO_VAN_BAN | SO_TRANG |  |
| 11 | Document Source | doc_src | STRING | X |  |  |  | Nguồn gốc tài liệu. | ThanhTra | TT_HO_SO_VAN_BAN | NGUON_GOC_TAI_LIEU |  |
| 12 | Attachment File Name | attachment_file_nm | STRING | X |  |  |  | Tên file đính kèm. | ThanhTra | TT_HO_SO_VAN_BAN | FILE_NAME |  |
| 13 | Attachment File URL | attachment_file_url | STRING | X |  |  |  | Đường dẫn file. | ThanhTra | TT_HO_SO_VAN_BAN | FILE_PATH |  |
| 14 | Attachment File Size | attachment_file_sz | INT | X |  |  |  | Kích thước file (bytes). | ThanhTra | TT_HO_SO_VAN_BAN | FILE_SIZE |  |


#### 2.{IDX}.41.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Inspection Case Document Attachment Id | inspection_case_doc_attachment_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Inspection Case Id | inspection_case_id | Inspection Case | Inspection Case Id | inspection_case_id |




### 2.{IDX}.42 Bảng Inspection Case Conclusion

- **Mô tả:** Kết luận thanh tra kèm thông tin xử lý vi phạm. FK → Inspection Case.
- **Tên vật lý:** inspection_case_conclusion
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Inspection Case Conclusion Id | inspection_case_conclusion_id | BIGINT |  | X | P |  | Khóa đại diện cho kết luận thanh tra. | ThanhTra | TT_KET_LUAN |  |  |
| 2 | Inspection Case Conclusion Code | inspection_case_conclusion_code | STRING |  |  |  |  | Mã kết luận. Map từ PK ThanhTra.TT_KET_LUAN.ID. | ThanhTra | TT_KET_LUAN | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | TT_KET_LUAN |  |  |
| 4 | Inspection Case Id | inspection_case_id | BIGINT |  |  | F |  | FK đến Inspection Case. | ThanhTra | TT_KET_LUAN | HO_SO_ID | FK target: Inspection Case.Inspection Case Id. |
| 5 | Inspection Case Code | inspection_case_code | STRING |  |  |  |  | Mã hồ sơ thanh tra. | ThanhTra | TT_KET_LUAN | HO_SO_ID | Lookup pair: Inspection Case.Inspection Case Code. Pair with Inspection Case Id. |
| 6 | Conclusion Sequence Number | conclusion_seq_nbr | INT |  |  |  |  | Số thứ tự kết luận trong 1 hồ sơ (1:N — có thể có nhiều kết luận: sơ bộ, chính thức, bổ sung). | ThanhTra | TT_KET_LUAN |  | ETL-derived: tính tự động theo thứ tự NGAY_TAO trong cùng HO_SO_ID. |
| 7 | Document Type Code | doc_tp_code | STRING | X |  |  |  | Loại văn bản: KET_LUAN / VAN_BAN_XU_LY. | ThanhTra | TT_KET_LUAN | LOAI_VAN_BAN | Scheme: TT_CASE_TYPE. |
| 8 | Conclusion Document Number | conclusion_doc_nbr | STRING | X |  |  |  | Số hiệu văn bản kết luận. | ThanhTra | TT_KET_LUAN | SO_HIEU |  |
| 9 | Signing Date | signing_dt | DATE | X |  |  |  | Ngày văn bản. | ThanhTra | TT_KET_LUAN | NGAY_VAN_BAN |  |
| 10 | Conclusion Summary | conclusion_smy | STRING | X |  |  |  | Nội dung văn bản kết luận. | ThanhTra | TT_KET_LUAN | NOI_DUNG |  |
| 11 | Penalty Amount | pny_amt | DECIMAL(18,2) | X |  |  |  | Số tiền phạt. | ThanhTra | TT_KET_LUAN | SO_TIEN_PHAT |  |
| 12 | Violation Clause | vln_claus | STRING | X |  |  |  | Điều khoản hành vi vi phạm. | ThanhTra | TT_KET_LUAN | DIEU_KHOAN_HANH_VI |  |
| 13 | Violation Regulation Document | vln_reg_doc | STRING | X |  |  |  | Văn bản quy định hành vi vi phạm. | ThanhTra | TT_KET_LUAN | VAN_BAN_HANH_VI |  |
| 14 | Penalty Clause | pny_claus | STRING | X |  |  |  | Điều khoản chế tài áp dụng. | ThanhTra | TT_KET_LUAN | DIEU_KHOAN_CHE_TAI |  |
| 15 | Penalty Regulation Document | pny_reg_doc | STRING | X |  |  |  | Văn bản quy định chế tài. | ThanhTra | TT_KET_LUAN | VAN_BAN_CHE_TAI |  |
| 16 | Violation Type Code | vln_tp_code | STRING | X |  |  |  | Danh mục hành vi vi phạm. | ThanhTra | TT_KET_LUAN | HANH_VI_VI_PHAM_ID | Scheme: TT_VIOLATION_TYPE. |
| 17 | Penalty Type Code | pny_tp_code | STRING | X |  |  |  | Danh mục hình thức phạt. | ThanhTra | TT_KET_LUAN | HINH_THUC_PHAT_ID | Scheme: TT_PENALTY_TYPE. |
| 18 | Attachment File Name | attachment_file_nm | STRING | X |  |  |  | Tên file đính kèm kết luận. | ThanhTra | TT_KET_LUAN | FILE_NAME |  |
| 19 | Attachment File URL | attachment_file_url | STRING | X |  |  |  | Đường dẫn file kết luận. | ThanhTra | TT_KET_LUAN | FILE_PATH |  |
| 20 | Conclusion Status Code | conclusion_st_code | STRING | X |  |  |  | Trạng thái văn bản kết luận. | ThanhTra | TT_KET_LUAN | TRANG_THAI | Scheme: TT_CASE_STATUS. |


#### 2.{IDX}.42.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Inspection Case Conclusion Id | inspection_case_conclusion_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Inspection Case Id | inspection_case_id | Inspection Case | Inspection Case Id | inspection_case_id |




### 2.{IDX}.43 Bảng Complaint Penalty Announcement

- **Mô tả:** Công bố quyết định xử phạt từ hồ sơ đơn thư. FK → Complaint Enforcement Decision.
- **Tên vật lý:** cpln_pny_ancm
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Complaint Penalty Announcement Id | cpln_pny_ancm_id | BIGINT |  | X | P |  | Khóa đại diện cho công bố xử phạt từ đơn thư. | ThanhTra | DT_CONG_BO_XU_PHAT |  |  |
| 2 | Complaint Penalty Announcement Code | cpln_pny_ancm_code | STRING |  |  |  |  | Mã công bố. Map từ PK ThanhTra.DT_CONG_BO_XU_PHAT.ID. | ThanhTra | DT_CONG_BO_XU_PHAT | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | DT_CONG_BO_XU_PHAT |  |  |
| 4 | Complaint Processing Case Id | cpln_pcs_case_id | BIGINT | X |  | F |  | FK đến Complaint Processing Case (via HO_SO_ID — redundant navigation FK). | ThanhTra | DT_CONG_BO_XU_PHAT | HO_SO_ID | FK target: Complaint Processing Case.Complaint Processing Case Id. |
| 5 | Complaint Processing Case Code | cpln_pcs_case_code | STRING | X |  |  |  | Mã hồ sơ đơn thư. | ThanhTra | DT_CONG_BO_XU_PHAT | HO_SO_ID | Lookup pair: Complaint Processing Case.Complaint Processing Case Code. Pair with Complaint Processing Case Id. |
| 6 | Complaint Enforcement Decision Id | cpln_enforcement_dcsn_id | BIGINT |  |  | F |  | FK đến Complaint Enforcement Decision. | ThanhTra | DT_CONG_BO_XU_PHAT | QUYET_DINH_XU_PHAT_ID | FK target: Complaint Enforcement Decision.Complaint Enforcement Decision Id. |
| 7 | Complaint Enforcement Decision Code | cpln_enforcement_dcsn_code | STRING |  |  |  |  | Mã quyết định xử phạt đơn thư. | ThanhTra | DT_CONG_BO_XU_PHAT | QUYET_DINH_XU_PHAT_ID | Lookup pair: Complaint Enforcement Decision.Complaint Enforcement Decision Code. Pair with Complaint Enforcement Decision Id. |
| 8 | Announcement Channel | ancm_cnl | STRING | X |  |  |  | Chuyên mục / kênh công bố. | ThanhTra | DT_CONG_BO_XU_PHAT | CHUYEN_MUC |  |
| 9 | Announcement Content | ancm_cntnt | STRING | X |  |  |  | Nội dung công bố. | ThanhTra | DT_CONG_BO_XU_PHAT | NOI_DUNG_CONG_BO |  |
| 10 | Announcement Date | ancm_dt | DATE | X |  |  |  | Ngày công bố. | ThanhTra | DT_CONG_BO_XU_PHAT | NGAY_CONG_BO |  |
| 11 | Announcement Status Code | ancm_st_code | STRING |  |  |  |  | Trạng thái: CHO_DUYET / DA_DUYET. | ThanhTra | DT_CONG_BO_XU_PHAT | TRANG_THAI | Scheme: TT_ANNOUNCEMENT_STATUS. |


#### 2.{IDX}.43.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Complaint Penalty Announcement Id | cpln_pny_ancm_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Complaint Processing Case Id | cpln_pcs_case_id | Complaint Processing Case | Complaint Processing Case Id | cpln_pcs_case_id |
| Complaint Enforcement Decision Id | cpln_enforcement_dcsn_id | Complaint Enforcement Decision | Complaint Enforcement Decision Id | cpln_enforcement_dcsn_id |




### 2.{IDX}.44 Bảng Inspection Penalty Announcement

- **Mô tả:** Công bố quyết định xử phạt từ kết luận thanh tra. FK → Inspection Case Conclusion.
- **Tên vật lý:** inspection_pny_ancm
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Inspection Penalty Announcement Id | inspection_pny_ancm_id | BIGINT |  | X | P |  | Khóa đại diện cho công bố xử phạt từ kết luận thanh tra. | ThanhTra | TT_CONG_BO_XU_PHAT |  |  |
| 2 | Inspection Penalty Announcement Code | inspection_pny_ancm_code | STRING |  |  |  |  | Mã công bố. Map từ PK ThanhTra.TT_CONG_BO_XU_PHAT.ID. | ThanhTra | TT_CONG_BO_XU_PHAT | ID | BK của entity. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'ThanhTra' | Mã hệ thống nguồn. | ThanhTra | TT_CONG_BO_XU_PHAT |  |  |
| 4 | Inspection Case Id | inspection_case_id | BIGINT | X |  | F |  | FK đến Inspection Case (via HO_SO_ID — redundant navigation FK). | ThanhTra | TT_CONG_BO_XU_PHAT | HO_SO_ID | FK target: Inspection Case.Inspection Case Id. |
| 5 | Inspection Case Code | inspection_case_code | STRING | X |  |  |  | Mã hồ sơ thanh tra. | ThanhTra | TT_CONG_BO_XU_PHAT | HO_SO_ID | Lookup pair: Inspection Case.Inspection Case Code. Pair with Inspection Case Id. |
| 6 | Inspection Case Conclusion Id | inspection_case_conclusion_id | BIGINT |  |  | F |  | FK đến Inspection Case Conclusion. | ThanhTra | TT_CONG_BO_XU_PHAT | QUYET_DINH_XU_PHAT_ID | FK target: Inspection Case Conclusion.Inspection Case Conclusion Id. |
| 7 | Inspection Case Conclusion Code | inspection_case_conclusion_code | STRING |  |  |  |  | Mã kết luận thanh tra. | ThanhTra | TT_CONG_BO_XU_PHAT | QUYET_DINH_XU_PHAT_ID | Lookup pair: Inspection Case Conclusion.Inspection Case Conclusion Code. Pair with Inspection Case Conclusion Id. |
| 8 | Announcement Channel | ancm_cnl | STRING | X |  |  |  | Chuyên mục trên cổng TTĐT. | ThanhTra | TT_CONG_BO_XU_PHAT | CHUYEN_MUC |  |
| 9 | Announcement Content | ancm_cntnt | STRING | X |  |  |  | Nội dung công bố. | ThanhTra | TT_CONG_BO_XU_PHAT | NOI_DUNG_CONG_BO |  |
| 10 | Announcement Date | ancm_dt | DATE | X |  |  |  | Ngày công bố. | ThanhTra | TT_CONG_BO_XU_PHAT | NGAY_CONG_BO |  |
| 11 | Announcement Status Code | ancm_st_code | STRING |  |  |  |  | Trạng thái: CHO_DUYET / DA_DUYET. | ThanhTra | TT_CONG_BO_XU_PHAT | TRANG_THAI | Scheme: TT_ANNOUNCEMENT_STATUS. |


#### 2.{IDX}.44.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Inspection Penalty Announcement Id | inspection_pny_ancm_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Inspection Case Id | inspection_case_id | Inspection Case | Inspection Case Id | inspection_case_id |
| Inspection Case Conclusion Id | inspection_case_conclusion_id | Inspection Case Conclusion | Inspection Case Conclusion Id | inspection_case_conclusion_id |




