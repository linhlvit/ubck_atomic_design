## 2.{IDX} IDS — 

### 2.{IDX}.1 Các mô hình quan hệ dữ liệu

- DBML tổng hợp (tất cả bảng): [`IDS.dbml`](IDS.dbml) — paste vào https://dbdiagram.io để render.
- Diagram theo mảng nghiệp vụ:
  - **UID01 — Quản lý hồ sơ công ty đại chúng**: [`IDS_UID01.dbml`](IDS_UID01.dbml)
  - **UID02 — Hoạt động kinh doanh / Corporate Actions của CTĐC**: [`IDS_UID02.dbml`](IDS_UID02.dbml)
  - **UID03 — Giám sát và xử phạt CTĐC**: [`IDS_UID03.dbml`](IDS_UID03.dbml)
  - **UID04 — Quản lý cổ đông giao dịch**: [`IDS_UID04.dbml`](IDS_UID04.dbml)
  - **UID05 — Công bố thông tin và thông báo**: [`IDS_UID05.dbml`](IDS_UID05.dbml)
  - **UID06 — Báo cáo tài chính và báo cáo định kỳ**: [`IDS_UID06.dbml`](IDS_UID06.dbml)
  - **UID07 — Quản lý công ty kiểm toán**: [`IDS_UID07.dbml`](IDS_UID07.dbml)
  - **UID08 — Lịch sử thay đổi (SCD2 kỹ thuật)**: [`IDS_UID08.dbml`](IDS_UID08.dbml)


**Danh sách bảng:**

| STT | Thực thể | Tên bảng | Mô tả |
|---|---|---|---|
| 1 | Audit Firm | audt_firm | Công ty kiểm toán được UBCKNN chấp thuận. Ghi nhận thông tin pháp lý và trạng thái hoạt động. |
| 2 | Involved Party Electronic Address | ip_elc_adr | Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn. |
| 3 | Involved Party Postal Address | ip_pst_adr | Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn. |
| 4 | Financial Report Catalog | fnc_rpt_ctlg | Danh mục báo cáo tài chính — loại báo cáo/năm/scope hợp nhất/loại hình doanh nghiệp. Master entity FK từ Financial Report Row/Column Template. |
| 5 | Financial Report Row Template | fnc_rpt_row_tpl | Định nghĩa hàng trong biểu mẫu BCTC — mã hàng/tên/công thức/thứ tự. FK to Financial Report Catalog. |
| 6 | Financial Report Column Template | fnc_rpt_clmn_tpl | Định nghĩa cột trong biểu mẫu BCTC — mã cột/tên/công thức/thứ tự. FK to Financial Report Catalog. |
| 7 | Periodic Report Form | prd_rpt_form | Biểu mẫu báo cáo định kỳ (thường niên/quý/tháng) cho CBTT. Master entity FK từ Periodic Report Form Row/Column Template. |
| 8 | Periodic Report Form Row Template | prd_rpt_form_row_tpl | Định nghĩa hàng trong biểu mẫu báo cáo định kỳ — tên/thứ tự/kiểu dữ liệu. FK to Periodic Report Form. |
| 9 | Periodic Report Form Column Template | prd_rpt_form_clmn_tpl | Định nghĩa cột trong biểu mẫu báo cáo định kỳ — tên/thứ tự/công thức. FK to Periodic Report Form. |
| 10 | Disclosure Notification | dscl_notf | Instance thông báo CBTT gửi đi — nội dung/tiêu đề/ngày gửi/trạng thái. Grain: 1 lần gửi thông báo. FK to Disclosure Form Definition. |
| 11 | Disclosure Form Definition | dscl_form_defn | Định nghĩa loại hồ sơ/tin CBTT — loại form/quy trình duyệt/nghiệp vụ. Master entity của vòng đời CBTT. Self-join parent_form_id. |
| 12 | Public Company | pblc_co | Công ty đại chúng được UBCKNN quản lý. Lưu thông tin pháp lý và trạng thái hoạt động. |
| 13 | Stock Holder | stk_hldr | Cổ đông giao dịch — cá nhân hoặc tổ chức nắm giữ cổ phần công ty đại chúng. Grain: cổ đông x công ty. FK to Public Company. |
| 14 | Audit Firm Legal Representative | audt_firm_lgl_representative | Người đại diện pháp luật của công ty kiểm toán — chức vụ và ngày bổ nhiệm/kết thúc nhiệm kỳ. FK to Audit Firm. |
| 15 | Involved Party Alternative Identification | ip_alt_identn | Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn. |
| 16 | Audit Firm Approval | audt_firm_aprv | Quyết định chấp thuận/đình chỉ công ty kiểm toán từ BTC và UBCKNN — số văn bản/ngày/nội dung. Gộp 2 cơ quan. FK to Audit Firm. |
| 17 | Auditor Approval | auditor_aprv | Quyết định chấp thuận/đình chỉ kiểm toán viên từ BTC và UBCKNN — chứng chỉ hành nghề/năm chấp thuận. FK to Audit Firm. |
| 18 | Disclosure Notification Config | dscl_notf_config | Cấu hình thông báo CBTT — kênh gửi/hệ thống nhận/người quản lý. FK to Disclosure Notification. |
| 19 | Public Company Legal Representative | pblc_co_lgl_representative | Người đại diện pháp luật và người CBTT của công ty đại chúng — representative_role_code phân biệt 2 vai trò. FK to Public Company. |
| 20 | Public Company Related Entity | pblc_co_rel_ent | Công ty mẹ/con/liên kết của công ty đại chúng — tên/MST/vốn/tỷ lệ sở hữu/thời hạn hiệu lực. FK to Public Company. |
| 21 | Public Company State Capital | pblc_co_ste_cptl | Thông tin sở hữu nhà nước trong công ty đại chúng — tên đại diện nhà nước và tỷ lệ sở hữu. FK to Public Company. |
| 22 | Public Company Foreign Ownership Limit | pblc_co_frgn_own_lmt | Giới hạn tỷ lệ sở hữu nước ngoài của công ty đại chúng — max_owner_rate và khoảng thời gian áp dụng. FK to Public Company. |
| 23 | Stock Holder Trading Account | stk_hldr_tdg_ac | Tài khoản giao dịch chứng khoán của cổ đông tại CTCK — số tài khoản và trạng thái. FK to Stock Holder. |
| 24 | Stock Holder Relationship | stk_hldr_rltnp | Quan hệ giữa các cổ đông giao dịch — loại quan hệ/thời hạn/trạng thái. FK to Stock Holder x 2. |
| 25 | Stock Control | stk_cntl | Hạn chế chuyển nhượng cổ phiếu của cổ đông — số lượng bị hạn chế/thời gian/loại hạn chế. FK to Stock Holder. |
| 26 | Audit Firm Warning | audt_firm_wrn | Nhắc nhở từ BTC hoặc UBCKNN đến công ty kiểm toán hoặc kiểm toán viên — số văn bản và nội dung. FK nullable: Audit Firm Approval hoặc Auditor Approval. |
| 27 | Audit Firm Sanction | audt_firm_sanction | Xử phạt hành chính đối với công ty kiểm toán hoặc kiểm toán viên — quyết định và nội dung xử phạt. FK nullable: Audit Firm Approval hoặc Auditor Approval. |
| 28 | Public Company Capital Mobilization | pblc_co_cptl_mobilization | Tăng vốn trước khi thành công ty đại chúng — tổng vốn cuối năm và hình thức tăng. Grain: 1 năm x 1 công ty. FK to Public Company. |
| 29 | Public Company Capital Increase | pblc_co_cptl_incr | Tăng vốn điều lệ sau khi thành công ty đại chúng — vốn cuối năm tài chính và số đợt tăng. FK to Public Company. |
| 30 | Public Company Securities Offering | pblc_co_scr_ofrg | Hoạt động chào bán/phát hành chứng khoán — loại CK/kế hoạch/kết quả thực tế theo từng hình thức. FK to Public Company. |
| 31 | Public Company Tender Offer | pblc_co_tender_ofr | Chào mua công khai — bên chào mua/số lượng dự kiến/kết quả/tỷ lệ sở hữu trước-sau. FK to Public Company. |
| 32 | Public Company Treasury Stock Activity | pblc_co_trsr_stk_avy | Giao dịch cổ phiếu quỹ theo năm — số lượng mua/bán và số đợt. FK to Public Company. |
| 33 | Public Company Inspection | pblc_co_inspection | Thanh tra/kiểm tra công ty đại chúng — loại/số quyết định/đơn vị chủ trì/biên bản. FK to Public Company. |
| 34 | Public Company Penalty | pblc_co_pny | Xử phạt hành chính công ty đại chúng hoặc nhà đầu tư liên quan — hành vi vi phạm và quyết định xử phạt. FK to Public Company. |



### 2.{IDX}.2 Bảng Audit Firm

- **Mô tả:** Công ty kiểm toán được UBCKNN chấp thuận. Ghi nhận thông tin pháp lý và trạng thái hoạt động.
- **Tên vật lý:** audt_firm
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Audit Firm Id | audt_firm_id | BIGINT |  | X | P |  | Khóa đại diện cho công ty kiểm toán. | IDS.af_profiles |  | PK surrogate. Shared entity với SCMS.CT_KIEM_TOAN. |
| 2 | Audit Firm Code | audt_firm_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.af_profiles | id | BK chính. PK nguồn. Shared entity với SCMS.CT_KIEM_TOAN.ID. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.af_profiles' | Mã nguồn dữ liệu. | IDS.af_profiles |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Audit Firm Business Code | audt_firm_bsn_code | STRING | X |  |  |  | Mã công ty kiểm toán (mã nghiệp vụ). | IDS.af_profiles | audit_firm_cd |  |
| 5 | Audit Firm Name | audt_firm_nm | STRING | X |  |  |  | Tên tiếng Việt. | IDS.af_profiles | full_name_vi |  |
| 6 | Audit Firm English Name | audt_firm_english_nm | STRING | X |  |  |  | Tên tiếng Anh. | IDS.af_profiles | full_name_en |  |
| 7 | Audit Firm Short Name | audt_firm_shrt_nm | STRING | X |  |  |  | Tên viết tắt. | IDS.af_profiles | short_name |  |
| 8 | Charter Capital Amount | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ thực góp. | IDS.af_profiles | paid_in_capital |  |
| 9 | Approval Decision Number | aprv_dcsn_nbr | STRING | X |  |  |  | Số quyết định chấp thuận của UBCKNN. | IDS.af_profiles | approval_decision_no |  |
| 10 | Note | note | STRING | X |  |  |  | Ghi chú. | IDS.af_profiles |  |  |
| 11 | Audit Firm Status Code | audt_firm_st_code | STRING | X |  |  |  | Trạng thái hoạt động. | IDS.af_profiles |  | Scheme: SCMS_COMPANY_STATUS. |
| 12 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.af_profiles | created_date |  |
| 13 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. | IDS.af_profiles |  |  |
| 14 | Business Registration Number | bsn_rgst_nbr | STRING | X |  |  |  | Giấy chứng nhận đăng ký kinh doanh. | IDS.af_profiles | business_reg_no |  |
| 15 | Eligibility Certificate Number | elig_ctf_nbr | STRING | X |  |  |  | Giấy chứng nhận đủ điều kiện kinh doanh dịch vụ kiểm toán. | IDS.af_profiles | eligibility_cert_no |  |
| 16 | Approval Date | aprv_dt | DATE | X |  |  |  | Ngày chấp thuận. | IDS.af_profiles | approval_date |  |
| 17 | Foreign Audit Member Flag | frgn_audt_mbr_f | BOOLEAN | X |  |  |  | Là thành viên hãng kiểm toán quốc tế (1=có / 0=không). | IDS.af_profiles | foreign_audit_member_flg |  |
| 18 | Membership Start Date | mbr_strt_dt | DATE | X |  |  |  | Ngày trở thành thành viên hãng kiểm toán quốc tế. | IDS.af_profiles | membership_start_date |  |
| 19 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.af_profiles | created_by |  |
| 20 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.af_profiles | last_updated_by |  |
| 21 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. | IDS.af_profiles | last_updated_date |  |


#### 2.{IDX}.2.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Audit Firm Id | audt_firm_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.3 Bảng Involved Party Electronic Address — IDS.af_profiles

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Audit Firm. | IDS.af_profiles | id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty kiểm toán. | IDS.af_profiles | id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.af_profiles' | Mã nguồn dữ liệu. | IDS.af_profiles |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. | IDS.af_profiles |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số fax. | IDS.af_profiles | fax_no |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Audit Firm. | IDS.af_profiles | id |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty kiểm toán. | IDS.af_profiles | id |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.af_profiles' | Mã nguồn dữ liệu. | IDS.af_profiles |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. | IDS.af_profiles |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | IDS.af_profiles | phone_no |  |
| 11 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Audit Firm. | IDS.af_profiles | id |  |
| 12 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty kiểm toán. | IDS.af_profiles | id |  |
| 13 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.af_profiles' | Mã nguồn dữ liệu. | IDS.af_profiles |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 14 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. | IDS.af_profiles |  |  |
| 15 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Website. | IDS.af_profiles | website |  |


#### 2.{IDX}.3.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Audit Firm | Audit Firm Id | audt_firm_id |




### 2.{IDX}.4 Bảng Involved Party Postal Address — IDS.af_profiles

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Audit Firm. | IDS.af_profiles | id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty kiểm toán. | IDS.af_profiles | id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.af_profiles' | Mã nguồn dữ liệu. | IDS.af_profiles |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. | IDS.af_profiles |  |  |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở chính. | IDS.af_profiles | address |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | IDS.af_profiles |  |  |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). | IDS.af_profiles |  |  |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. | IDS.af_profiles |  |  |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. | IDS.af_profiles |  |  |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | IDS.af_profiles |  |  |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | IDS.af_profiles |  |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | IDS.af_profiles |  |  |


#### 2.{IDX}.4.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Audit Firm | Audit Firm Id | audt_firm_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.5 Bảng Financial Report Catalog

- **Mô tả:** Danh mục báo cáo tài chính — loại báo cáo/năm/scope hợp nhất/loại hình doanh nghiệp. Master entity FK từ Financial Report Row/Column Template.
- **Tên vật lý:** fnc_rpt_ctlg
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Financial Report Catalog Id | fnc_rpt_ctlg_id | BIGINT |  | X | P |  | Khóa đại diện cho biểu mẫu BCTC. | IDS.report_catalog |  | PK surrogate. |
| 2 | Financial Report Catalog Code | fnc_rpt_ctlg_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.report_catalog | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.report_catalog' | Mã nguồn dữ liệu. | IDS.report_catalog |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Financial Report Catalog Business Code | fnc_rpt_ctlg_bsn_code | STRING | X |  |  |  | Mã báo cáo (mã nghiệp vụ). | IDS.report_catalog | report_cd |  |
| 5 | Financial Report Catalog Name | fnc_rpt_ctlg_nm | STRING | X |  |  |  | Tên báo cáo (tiếng Việt). | IDS.report_catalog | report_name_vi |  |
| 6 | Financial Report Catalog English Name | fnc_rpt_ctlg_english_nm | STRING | X |  |  |  | Tên báo cáo (tiếng Anh). | IDS.report_catalog | report_name_en |  |
| 7 | Report Direction Type Code | rpt_drc_tp_code | STRING | X |  |  |  | Loại báo cáo: i=báo cáo đầu vào, o=báo cáo đầu ra. | IDS.report_catalog | rc_type_cd | Scheme: IDS_REPORT_CATALOG_TYPE. |
| 8 | Report Year | rpt_yr | INT | X |  |  |  | Năm của báo cáo. | IDS.report_catalog | report_year |  |
| 9 | Report Scope Code | rpt_scop_code | STRING | X |  |  |  | Loại hình báo cáo (hợp nhất, mẹ). | IDS.report_catalog | report_scope_cd | Scheme: IDS_REPORT_SCOPE. |
| 10 | Enterprise Type Code | entp_tp_code | STRING | X |  |  |  | Loại hình doanh nghiệp (dn-doanh nghiệp, bh-bảo hiểm, td-tín dụng, ck-chứng khoán). | IDS.report_catalog | enterprise_type_cd | Scheme: IDS_ENTERPRISE_TYPE. |
| 11 | Consolidated Flag | cnsld_f | BOOLEAN | X |  |  |  | Là báo cáo hợp nhất (1=có / 0=không). | IDS.report_catalog | consolidated_flg |  |
| 12 | Active Flag | actv_f | BOOLEAN | X |  |  |  | Trạng thái sử dụng (1=đang sử dụng / 0=không sử dụng). | IDS.report_catalog | active_flg |  |
| 13 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.report_catalog | created_by |  |
| 14 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.report_catalog | created_date |  |
| 15 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.report_catalog | last_updated_by |  |
| 16 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.report_catalog | last_updated_date |  |


#### 2.{IDX}.5.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Financial Report Catalog Id | fnc_rpt_ctlg_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.6 Bảng Financial Report Row Template

- **Mô tả:** Định nghĩa hàng trong biểu mẫu BCTC — mã hàng/tên/công thức/thứ tự. FK to Financial Report Catalog.
- **Tên vật lý:** fnc_rpt_row_tpl
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Financial Report Row Template Id | fnc_rpt_row_tpl_id | BIGINT |  | X | P |  | Khóa đại diện cho hàng biểu mẫu BCTC. | IDS.rrow |  | PK surrogate. |
| 2 | Financial Report Row Template Code | fnc_rpt_row_tpl_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.rrow | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.rrow' | Mã nguồn dữ liệu. | IDS.rrow |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Financial Report Catalog Id | fnc_rpt_ctlg_id | BIGINT |  |  | F |  | FK đến biểu mẫu BCTC. | IDS.rrow | report_catalog_id |  |
| 5 | Financial Report Catalog Code | fnc_rpt_ctlg_code | STRING |  |  |  |  | Mã biểu mẫu BCTC. | IDS.rrow | report_catalog_id |  |
| 6 | Row Code | row_code | STRING | X |  |  |  | Mã hàng (auto-generated theo quy tắc r+sequence). | IDS.rrow | row_cd |  |
| 7 | Row Name | row_nm | STRING | X |  |  |  | Tên hàng (tiếng Việt). | IDS.rrow | row_name_vi |  |
| 8 | Row English Name | row_english_nm | STRING | X |  |  |  | Tên hàng (tiếng Anh). | IDS.rrow | row_name_en |  |
| 9 | Row Type Code | row_tp_code | STRING | X |  |  |  | Kiểu giá trị của hàng: v=value, f=formula, d=description. | IDS.rrow | row_type_cd | Scheme: IDS_REPORT_ROW_TYPE. |
| 10 | Row Formula | row_frml | STRING | X |  |  |  | Công thức của hàng. | IDS.rrow | row_formula |  |
| 11 | Row Description Column Code | row_dsc_clmn_code | STRING | X |  |  |  | Mô tả nội dung của hàng (hiện đang lưu mã cột). | IDS.rrow | col_cd |  |
| 12 | Row Index | row_indx | INT | X |  |  |  | Thứ tự hàng. | IDS.rrow | row_index |  |
| 13 | Report Year | rpt_yr | INT | X |  |  |  | Năm tạo báo cáo (denormalized từ report_catalog). | IDS.rrow | report_year |  |
| 14 | Report Direction Type Code | rpt_drc_tp_code | STRING | X |  |  |  | Loại báo cáo (denormalized từ report_catalog). | IDS.rrow | rc_type_cd | Scheme: IDS_REPORT_CATALOG_TYPE. Trường lưu dư thừa — đã có Financial Report Catalog Id. |
| 15 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.rrow | created_by |  |
| 16 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.rrow | created_date |  |
| 17 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.rrow | last_updated_by |  |
| 18 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.rrow | last_updated_date |  |


#### 2.{IDX}.6.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Financial Report Row Template Id | fnc_rpt_row_tpl_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Financial Report Catalog Id | fnc_rpt_ctlg_id | Financial Report Catalog | Financial Report Catalog Id | fnc_rpt_ctlg_id |




### 2.{IDX}.7 Bảng Financial Report Column Template

- **Mô tả:** Định nghĩa cột trong biểu mẫu BCTC — mã cột/tên/công thức/thứ tự. FK to Financial Report Catalog.
- **Tên vật lý:** fnc_rpt_clmn_tpl
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Financial Report Column Template Id | fnc_rpt_clmn_tpl_id | BIGINT |  | X | P |  | Khóa đại diện cho cột biểu mẫu BCTC. | IDS.rcol |  | PK surrogate. |
| 2 | Financial Report Column Template Code | fnc_rpt_clmn_tpl_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.rcol | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.rcol' | Mã nguồn dữ liệu. | IDS.rcol |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Financial Report Catalog Id | fnc_rpt_ctlg_id | BIGINT |  |  | F |  | FK đến biểu mẫu BCTC. | IDS.rcol | report_catalog_id |  |
| 5 | Financial Report Catalog Code | fnc_rpt_ctlg_code | STRING |  |  |  |  | Mã biểu mẫu BCTC. | IDS.rcol | report_catalog_id |  |
| 6 | Column Code | clmn_code | STRING | X |  |  |  | Mã cột. | IDS.rcol | col_cd |  |
| 7 | Column Name | clmn_nm | STRING | X |  |  |  | Tên cột (tiếng Việt). | IDS.rcol | col_name_vi |  |
| 8 | Column English Name | clmn_english_nm | STRING | X |  |  |  | Tên cột (tiếng Anh). | IDS.rcol | col_name_en |  |
| 9 | Column Type Code | clmn_tp_code | STRING | X |  |  |  | Loại giá trị của cột. | IDS.rcol | col_type_cd |  |
| 10 | Column Formula | clmn_frml | STRING | X |  |  |  | Công thức cột. | IDS.rcol | col_formula |  |
| 11 | Column Index | clmn_indx | INT | X |  |  |  | Chỉ số (thứ tự) của cột. | IDS.rcol | col_index |  |
| 12 | Report Year | rpt_yr | INT | X |  |  |  | Năm tạo báo cáo (denormalized từ report_catalog). | IDS.rcol | report_year |  |
| 13 | Report Direction Type Code | rpt_drc_tp_code | STRING | X |  |  |  | Loại báo cáo (denormalized từ report_catalog). | IDS.rcol | rc_type_cd | Scheme: IDS_REPORT_CATALOG_TYPE. Trường lưu dư thừa — đã có Financial Report Catalog Id. |
| 14 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.rcol | created_by |  |
| 15 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.rcol | created_date |  |
| 16 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.rcol | last_updated_by |  |
| 17 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.rcol | last_updated_date |  |


#### 2.{IDX}.7.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Financial Report Column Template Id | fnc_rpt_clmn_tpl_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Financial Report Catalog Id | fnc_rpt_ctlg_id | Financial Report Catalog | Financial Report Catalog Id | fnc_rpt_ctlg_id |




### 2.{IDX}.8 Bảng Periodic Report Form

- **Mô tả:** Biểu mẫu báo cáo định kỳ (thường niên/quý/tháng) cho CBTT. Master entity FK từ Periodic Report Form Row/Column Template.
- **Tên vật lý:** prd_rpt_form
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Periodic Report Form Id | prd_rpt_form_id | BIGINT |  | X | P |  | Khóa đại diện cho biểu mẫu báo cáo định kỳ. | IDS.rep_forms |  | PK surrogate. |
| 2 | Periodic Report Form Code | prd_rpt_form_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.rep_forms | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.rep_forms' | Mã nguồn dữ liệu. | IDS.rep_forms |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Periodic Report Form Business Code | prd_rpt_form_bsn_code | STRING | X |  |  |  | Mã form (mã nghiệp vụ). | IDS.rep_forms | report_cd |  |
| 5 | Periodic Report Form Name | prd_rpt_form_nm | STRING | X |  |  |  | Tên form báo cáo (tiếng Việt). | IDS.rep_forms | report_name_vi |  |
| 6 | Periodic Report Form English Name | prd_rpt_form_english_nm | STRING | X |  |  |  | Tên form báo cáo (tiếng Anh). | IDS.rep_forms | report_name_en |  |
| 7 | Report Frequency Type Code | rpt_frq_tp_code | STRING | X |  |  |  | Loại báo cáo định kỳ (0=BC tháng / 1=BC quý / 2=BC năm / 3=BC thường niên / 4=BC trực tuyến 6 tháng đầu năm / 5=BC trực tuyến 6 tháng cuối năm). | IDS.rep_forms | rf_report_type_cd | Scheme: IDS_PERIODIC_REPORT_FREQUENCY. |
| 8 | Published Flag | published_f | BOOLEAN | X |  |  |  | Báo cáo được công bố hay không (1=có / 0=không). | IDS.rep_forms | published_flg |  |
| 9 | Report Configuration Link | rpt_cfg_link | STRING | X |  |  |  | Đường link cấu hình biểu mẫu. | IDS.rep_forms | report_link |  |
| 10 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.rep_forms | created_by |  |
| 11 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.rep_forms | created_date |  |
| 12 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.rep_forms | last_updated_by |  |
| 13 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.rep_forms | last_updated_date |  |


#### 2.{IDX}.8.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Periodic Report Form Id | prd_rpt_form_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.9 Bảng Periodic Report Form Row Template

- **Mô tả:** Định nghĩa hàng trong biểu mẫu báo cáo định kỳ — tên/thứ tự/kiểu dữ liệu. FK to Periodic Report Form.
- **Tên vật lý:** prd_rpt_form_row_tpl
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Periodic Report Form Row Template Id | prd_rpt_form_row_tpl_id | BIGINT |  | X | P |  | Khóa đại diện cho hàng biểu mẫu báo cáo định kỳ. | IDS.rep_row |  | PK surrogate. |
| 2 | Periodic Report Form Row Template Code | prd_rpt_form_row_tpl_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.rep_row | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.rep_row' | Mã nguồn dữ liệu. | IDS.rep_row |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Periodic Report Form Id | prd_rpt_form_id | BIGINT |  |  | F |  | FK đến biểu mẫu báo cáo định kỳ. | IDS.rep_row | rep_form_id |  |
| 5 | Periodic Report Form Code | prd_rpt_form_code | STRING |  |  |  |  | Mã biểu mẫu báo cáo định kỳ. | IDS.rep_row | rep_form_id |  |
| 6 | Row Name | row_nm | STRING | X |  |  |  | Tên dòng (tiếng Việt). | IDS.rep_row | row_name_vi |  |
| 7 | Row English Name | row_english_nm | STRING | X |  |  |  | Tên dòng (tiếng Anh). | IDS.rep_row | row_name_en |  |
| 8 | Row Index | row_indx | INT | X |  |  |  | Thứ tự dòng. | IDS.rep_row | row_index |  |
| 9 | Duplicate Row Flag | dup_row_f | BOOLEAN | X |  |  |  | Có cho phép nhân đôi dòng không (1=có / 0=không). | IDS.rep_row | duplicate_row_flg |  |
| 10 | Row Data Type Code | row_data_tp_code | STRING | X |  |  |  | Kiểu dữ liệu của dòng: v=value, d=description. | IDS.rep_row | data_type_cd | Scheme: IDS_PERIODIC_FORM_ROW_DATA_TYPE. |
| 11 | Allow Column Sum Flag | alw_clmn_sm_f | BOOLEAN | X |  |  |  | Có cho phép cột tính tổng (1=có / 0=không). | IDS.rep_row | allow_col_sum_flg |  |
| 12 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.rep_row | created_by |  |
| 13 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.rep_row | created_date |  |
| 14 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.rep_row | last_updated_by |  |
| 15 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.rep_row | last_updated_date |  |


#### 2.{IDX}.9.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Periodic Report Form Row Template Id | prd_rpt_form_row_tpl_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Periodic Report Form Id | prd_rpt_form_id | Periodic Report Form | Periodic Report Form Id | prd_rpt_form_id |




### 2.{IDX}.10 Bảng Periodic Report Form Column Template

- **Mô tả:** Định nghĩa cột trong biểu mẫu báo cáo định kỳ — tên/thứ tự/công thức. FK to Periodic Report Form.
- **Tên vật lý:** prd_rpt_form_clmn_tpl
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Periodic Report Form Column Template Id | prd_rpt_form_clmn_tpl_id | BIGINT |  | X | P |  | Khóa đại diện cho cột biểu mẫu báo cáo định kỳ. | IDS.rep_column |  | PK surrogate. |
| 2 | Periodic Report Form Column Template Code | prd_rpt_form_clmn_tpl_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.rep_column | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.rep_column' | Mã nguồn dữ liệu. | IDS.rep_column |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Periodic Report Form Id | prd_rpt_form_id | BIGINT |  |  | F |  | FK đến biểu mẫu báo cáo định kỳ. | IDS.rep_column | rep_form_id |  |
| 5 | Periodic Report Form Code | prd_rpt_form_code | STRING |  |  |  |  | Mã biểu mẫu báo cáo định kỳ. | IDS.rep_column | rep_form_id |  |
| 6 | Column Name | clmn_nm | STRING | X |  |  |  | Tên cột (tiếng Việt). | IDS.rep_column | col_name_vi |  |
| 7 | Column English Name | clmn_english_nm | STRING | X |  |  |  | Tên cột (tiếng Anh). | IDS.rep_column | col_name_en |  |
| 8 | Column Index | clmn_indx | INT | X |  |  |  | Thứ tự cột. | IDS.rep_column | col_index |  |
| 9 | Duplicate Column Flag | dup_clmn_f | BOOLEAN | X |  |  |  | Có cho phép nhân đôi cột (1=có / 0=không). | IDS.rep_column | duplicate_col_flg |  |
| 10 | Column Data Type Code | clmn_data_tp_code | STRING | X |  |  |  | Kiểu dữ liệu của cột: n=number, t=text. | IDS.rep_column | data_type_cd | Scheme: IDS_PERIODIC_FORM_COLUMN_DATA_TYPE. |
| 11 | Column Formula | clmn_frml | STRING | X |  |  |  | Công thức tính. | IDS.rep_column | col_formula |  |
| 12 | Use Formula Flag | use_frml_f | BOOLEAN | X |  |  |  | Có sử dụng công thức tính (1=có / 0=không). | IDS.rep_column | use_formula_flg |  |
| 13 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.rep_column | created_by |  |
| 14 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.rep_column | created_date |  |
| 15 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.rep_column | last_updated_by |  |
| 16 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.rep_column | last_updated_date |  |


#### 2.{IDX}.10.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Periodic Report Form Column Template Id | prd_rpt_form_clmn_tpl_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Periodic Report Form Id | prd_rpt_form_id | Periodic Report Form | Periodic Report Form Id | prd_rpt_form_id |




### 2.{IDX}.11 Bảng Disclosure Notification

- **Mô tả:** Instance thông báo CBTT gửi đi — nội dung/tiêu đề/ngày gửi/trạng thái. Grain: 1 lần gửi thông báo. FK to Disclosure Form Definition.
- **Tên vật lý:** dscl_notf
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Disclosure Notification Id | dscl_notf_id | BIGINT |  | X | P |  | Khóa đại diện cho instance thông báo CBTT. | IDS.notifications |  | PK surrogate. |
| 2 | Disclosure Notification Code | dscl_notf_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.notifications | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.notifications' | Mã nguồn dữ liệu. | IDS.notifications |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Notification Business Code | notf_bsn_code | STRING | X |  |  |  | Mã thông báo (mã nghiệp vụ). | IDS.notifications | noti_cd |  |
| 5 | Disclosure Form Definition Id | dscl_form_defn_id | BIGINT | X |  | F |  | FK đến định nghĩa loại hồ sơ/tin CBTT. | IDS.notifications | form_id |  |
| 6 | Disclosure Form Definition Code | dscl_form_defn_code | STRING | X |  |  |  | Mã định nghĩa loại hồ sơ/tin CBTT. | IDS.notifications | form_cd |  |
| 7 | Notification Title | notf_ttl | STRING | X |  |  |  | Tiêu đề thông báo (tiếng Việt). | IDS.notifications | noti_title_vi |  |
| 8 | Notification English Title | notf_english_ttl | STRING | X |  |  |  | Tiêu đề thông báo (tiếng Anh). | IDS.notifications | noti_title_en |  |
| 9 | Notification Content | notf_cntnt | STRING | X |  |  |  | Nội dung thông báo (tiếng Việt). | IDS.notifications | noti_content_vi |  |
| 10 | Notification English Content | notf_english_cntnt | STRING | X |  |  |  | Nội dung thông báo (tiếng Anh). | IDS.notifications | noti_content_en |  |
| 11 | Send Schedule Type Code | snd_shd_tp_code | STRING | X |  |  |  | Lịch gửi tin định kỳ. | IDS.notifications | send_schedule_type_cd | Scheme: IDS_NOTIFICATION_SEND_SCHEDULE. |
| 12 | Monthly Send Day | mo_snd_day | INT | X |  |  |  | Ngày gửi thông báo định kỳ trong tháng. | IDS.notifications | monthly_send_day |  |
| 13 | Monthly Send Month | mo_snd_mo | INT | X |  |  |  | Tháng định kỳ gửi thông báo. | IDS.notifications | monthly_send_month |  |
| 14 | News Status Code | news_st_code | STRING | X |  |  |  | Trạng thái tin thông báo. | IDS.notifications | news_status_cd | Scheme: IDS_NEWS_STATUS. |
| 15 | News Type Code | news_tp_code | STRING | X |  |  |  | Loại tin gốc. | IDS.notifications | news_type_cd | Scheme: IDS_NEWS_TYPE. Dùng chung với forms.news_type_cd. |
| 16 | Sent Date | snd_dt | DATE | X |  |  |  | Ngày gửi tin. | IDS.notifications | sent_date |  |
| 17 | File Url | file_url | STRING | X |  |  |  | Đường dẫn file đính kèm. | IDS.notifications | file_url |  |
| 18 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.notifications | created_by |  |
| 19 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.notifications | created_date |  |
| 20 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.notifications | last_updated_by |  |
| 21 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.notifications | last_updated_date |  |


#### 2.{IDX}.11.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Disclosure Notification Id | dscl_notf_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Disclosure Form Definition Id | dscl_form_defn_id | Disclosure Form Definition | Disclosure Form Definition Id | dscl_form_defn_id |




### 2.{IDX}.12 Bảng Disclosure Form Definition

- **Mô tả:** Định nghĩa loại hồ sơ/tin CBTT — loại form/quy trình duyệt/nghiệp vụ. Master entity của vòng đời CBTT. Self-join parent_form_id.
- **Tên vật lý:** dscl_form_defn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Disclosure Form Definition Id | dscl_form_defn_id | BIGINT |  | X | P |  | Khóa đại diện cho định nghĩa loại hồ sơ/tin CBTT. | IDS.forms |  | PK surrogate. |
| 2 | Disclosure Form Definition Code | dscl_form_defn_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.forms | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.forms' | Mã nguồn dữ liệu. | IDS.forms |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Disclosure Form Definition Business Code | dscl_form_defn_bsn_code | STRING | X |  |  |  | Mã form (mã nghiệp vụ). | IDS.forms | form_cd |  |
| 5 | Disclosure Form Definition Name | dscl_form_defn_nm | STRING | X |  |  |  | Tên form (tiếng Việt). | IDS.forms | form_name_vi |  |
| 6 | Disclosure Form Definition English Name | dscl_form_defn_english_nm | STRING | X |  |  |  | Tên form (tiếng Anh). | IDS.forms | form_name_en |  |
| 7 | Form Type Code | form_tp_code | STRING | X |  |  |  | Loại tin hay hồ sơ (hồ sơ, cbtt). | IDS.forms | form_type_cd | Scheme: IDS_FORM_TYPE. |
| 8 | News Type Code | news_tp_code | STRING | X |  |  |  | Loại tin gốc. | IDS.forms | news_type_cd | Scheme: IDS_NEWS_TYPE. Dùng chung với notifications.news_type_cd. |
| 9 | Sub News Type Code | sub_news_tp_code | STRING | X |  |  |  | Loại tin con. | IDS.forms | sub_news_type_cd | Scheme: IDS_SUB_NEWS_TYPE. |
| 10 | Officer Approval Flag | ofcr_aprv_f | BOOLEAN | X |  |  |  | Chuyên viên tự động duyệt (1=đã duyệt / 0=chưa duyệt). | IDS.forms | officer_approval_flg |  |
| 11 | Post Checked Flag | pst_checked_f | BOOLEAN | X |  |  |  | Hậu kiểm tin (1=đã kiểm tra / 0=chưa kiểm tra). | IDS.forms | post_checked_flg |  |
| 12 | Activated Flag | activated_f | BOOLEAN | X |  |  |  | Kích hoạt (1=đã kích hoạt / 0=chưa kích hoạt). | IDS.forms | activated_flg |  |
| 13 | CA Signed Flag | ca_signed_f | BOOLEAN | X |  |  |  | Ký CA (chứng thư số): 0=bắt buộc / 1=không bắt buộc. | IDS.forms | ca_signed_flg |  |
| 14 | Leader Approval Flag | leader_aprv_f | BOOLEAN | X |  |  |  | Form tự động duyệt cấp lãnh đạo (1=đã duyệt / 0=chưa duyệt). | IDS.forms | leader_approval_flg |  |
| 15 | Published Flag | published_f | BOOLEAN | X |  |  |  | Form được công bố (1=được công bố / 0=chưa công bố). | IDS.forms | published_flg |  |
| 16 | Title Formula | ttl_frml | STRING | X |  |  |  | Công thức cho tiêu đề form tin. | IDS.forms | title_formula |  |
| 17 | Parent Disclosure Form Definition Id | prn_dscl_form_defn_id | BIGINT | X |  | F |  | FK đến form cha (self-join). | IDS.forms | parent_id |  |
| 18 | Parent Disclosure Form Definition Code | prn_dscl_form_defn_code | STRING | X |  |  |  | Mã form cha. | IDS.forms | parent_id |  |
| 19 | Report Type | rpt_tp | STRING | X |  |  |  | Loại báo cáo (tháng, quý, năm, bán niên...). | IDS.forms | report_type |  |
| 20 | Control Unit Code | cntl_unit_code | STRING | X |  | F |  | Đơn vị kiểm soát (Dept_cd của bảng departments). | IDS.forms | control_unit_cd |  |
| 21 | Operating Unit Codes | oprg_unit_codes | STRING | X |  |  |  | Đơn vị sử dụng (nhiều đơn vị cách nhau bằng ";" Dept_cd của bảng departments). | IDS.forms | operating_unit_cd |  |
| 22 | Created User | crt_usr | STRING | X |  |  |  | User khi tạo hồ sơ thuộc (ny/tv). | IDS.forms | created_user |  |
| 23 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.forms | created_by |  |
| 24 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.forms | created_at |  |
| 25 | Created Date | crt_dt | TIMESTAMP | X |  |  |  | Ngày tạo (legacy field). | IDS.forms | created_date |  |
| 26 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.forms | last_updated_by |  |
| 27 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.forms | last_updated_date |  |


#### 2.{IDX}.12.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Disclosure Form Definition Id | dscl_form_defn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Parent Disclosure Form Definition Id | prn_dscl_form_defn_id | Disclosure Form Definition | Disclosure Form Definition Id | dscl_form_defn_id |




### 2.{IDX}.13 Bảng Public Company — IDS.company_profiles

- **Mô tả:** Công ty đại chúng được UBCKNN quản lý. Lưu thông tin pháp lý và trạng thái hoạt động.
- **Tên vật lý:** pblc_co
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Public Company Id | pblc_co_id | BIGINT |  | X | P |  | Khóa đại diện cho công ty đại chúng. | IDS.company_profiles |  | PK surrogate. Shared entity với ThanhTra.DM_CONG_TY_DC. |
| 2 | Public Company Code | pblc_co_code | STRING |  |  |  |  | Mã định danh công ty đại chúng (PK nguồn). BK. | IDS.company_profiles | id | BK chính. PK của company_profiles; cũng = company_detail.company_profile_id (quan hệ 1-1). company_detail.id là PK kỹ thuật riêng — bỏ qua. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.company_profiles' | Mã nguồn dữ liệu. | IDS.company_profiles |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Public Company Name | pblc_co_nm | STRING | X |  |  |  | Tên công ty đại chúng (tiếng Việt). | IDS.company_profiles | company_name_vn |  |
| 5 | Public Company English Name | pblc_co_english_nm | STRING | X |  |  |  | Tên công ty đại chúng (tiếng Anh). | IDS.company_profiles | company_name_en |  |
| 6 | Public Company Short Name | pblc_co_shrt_nm | STRING | X |  |  |  | Tên viết tắt công ty đại chúng. | IDS.company_profiles |  |  |
| 7 | Company Type Code | co_tp_code | STRING | X |  |  |  | Loại hình công ty. | IDS.company_profiles |  | Scheme: TT_COMPANY_TYPE. |
| 8 | Charter Capital Amount | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ. | IDS.company_profiles |  |  |
| 9 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. | IDS.company_profiles |  | Scheme: LIFE_CYCLE_STATUS. |
| 10 | Business License Number | bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. | IDS.company_profiles |  |  |
| 11 | Website | webst | STRING | X |  |  |  | Website chính thức. | IDS.company_profiles |  |  |
| 12 | Business Registration Number | bsn_rgst_nbr | STRING | X |  |  |  | Mã số doanh nghiệp / số ĐKKD. | IDS.company_profiles | business_reg_no |  |
| 13 | First Registration Date | frst_rgst_dt | DATE | X |  |  |  | Ngày đăng ký lần đầu. | IDS.company_profiles | first_reg_date |  |
| 14 | Latest Registration Date | latest_rgst_dt | DATE | X |  |  |  | Ngày cấp gần nhất. | IDS.company_profiles | latest_reg_date |  |
| 15 | Latest Registration Province Code | latest_rgst_prov_code | STRING | X |  |  |  | Tỉnh/thành nơi cấp gần nhất (mã tỉnh từ provinces). | IDS.company_profiles | latest_reg_prov |  |
| 16 | Industry Category Id | idy_cgy_id | BIGINT | X |  | F |  | Id ngành nghề (categories). | IDS.company_profiles | category_id |  |
| 17 | Industry Category Code | idy_cgy_code | STRING | X |  |  |  | Mã ngành nghề (categories). | IDS.company_profiles | category_id | Scheme: IDS_INDUSTRY_CATEGORY. Pair with Industry Category Id. Theo HLD T1-04: categories là Classification Value không phải Silver entity. |
| 18 | Industry Category Level1 Code | idy_cgy_level1_code | STRING | X |  |  |  | Ngành nghề cấp 1 (mã categories cấp 1). | IDS.company_profiles | category_l1_id | Scheme: IDS_INDUSTRY_CATEGORY. Cùng scheme với Industry Category Code — denormalize cấp 1. |
| 19 | Industry Category Level2 Code | idy_cgy_level2_code | STRING | X |  |  |  | Ngành nghề cấp 2 (mã categories cấp 2). | IDS.company_profiles | category_l2_id | Scheme: IDS_INDUSTRY_CATEGORY. Cùng scheme với Industry Category Code — denormalize cấp 2. |
| 20 | IDS Status Code | ids_st_code | STRING | X |  |  |  | Trạng thái niêm yết IDS. | IDS.company_profiles | status_ids_cd | Scheme: IDS_COMPANY_STATUS. |
| 21 | Auto Approval Flag | auto_aprv_f | BOOLEAN | X |  |  |  | Tự động duyệt (1=tự động / 0=không). | IDS.company_profiles | auto_approval_flg |  |
| 22 | Company Login | co_login | STRING | X |  |  |  | User của công ty niêm yết (login_name). | IDS.company_profiles | company_login |  |
| 23 | Approver Comment | approver_cmnt | STRING | X |  |  |  | Ý kiến người duyệt. | IDS.company_profiles | approver_comment |  |
| 24 | Parent Company Flag | prn_co_f | BOOLEAN | X |  |  |  | Là công ty mẹ (1=có / 0=không). | IDS.company_profiles | parent_company_flg |  |
| 25 | Equity Listing Exchange Code | eqty_listing_exg_code | STRING | X |  |  |  | Sàn niêm yết cổ phiếu (HNX/HOSE/UPCoM). | IDS.company_profiles | equity_listing_exch_cd | Scheme: IDS_EQUITY_LISTING_EXCH. Trùng nội dung với company_detail.equity_listing_exch (Text denormalized) — chọn cd làm primary. |
| 26 | Equity Listing Exchange Name | eqty_listing_exg_nm | STRING | X |  |  |  | Sàn niêm yết cổ phiếu (text từ company_detail). | IDS.company_profiles | equity_listing_exch |  |
| 27 | Bond Listing Exchange Name | bond_listing_exg_nm | STRING | X |  |  |  | Sàn niêm yết trái phiếu (text từ company_detail). | IDS.company_profiles | bond_listing_exch |  |
| 28 | Equity Security Flag | eqty_scr_f | BOOLEAN | X |  |  |  | Loại chứng khoán niêm yết là cổ phiếu (1=có / 0=không). | IDS.company_profiles | equity_security_flg |  |
| 29 | Bond Security Flag | bond_scr_f | BOOLEAN | X |  |  |  | Loại chứng khoán niêm yết là trái phiếu (1=có / 0=không). | IDS.company_profiles | bond_security_flg |  |
| 30 | Equity Ticker | eqty_ticker | STRING | X |  |  |  | Mã chứng khoán cổ phiếu. | IDS.company_profiles | equity_ticker |  |
| 31 | Bond Ticker | bond_ticker | STRING | X |  |  |  | Mã chứng khoán trái phiếu. | IDS.company_profiles | bond_ticker |  |
| 32 | Equity Listed Quantity | eqty_list_qty | INT | X |  |  |  | Số lượng cổ phiếu đang niêm yết. | IDS.company_profiles | equity_listed_qty |  |
| 33 | Bond Listed Quantity | bond_list_qty | INT | X |  |  |  | Số lượng trái phiếu đang niêm yết. | IDS.company_profiles | bond_listed_qty |  |
| 34 | International Exchange Name | itnl_exg_nm | STRING | X |  |  |  | Sàn niêm yết quốc tế. | IDS.company_profiles | intl_exch |  |
| 35 | International Ticker | itnl_ticker | STRING | X |  |  |  | Mã chứng quốc tế. | IDS.company_profiles | intl_ticker |  |
| 36 | ISIN Code | isin_code | STRING | X |  |  |  | Mã ISIN. | IDS.company_profiles | isin_cd |  |
| 37 | Securities Type Code | scr_tp_code | STRING | X |  |  |  | Loại chứng khoán phát hành. | IDS.company_profiles | securities_type_cd | Scheme: IDS_SECURITIES_TYPE. |
| 38 | Public Company Form Code | pblc_co_form_code | STRING | X |  |  |  | Hình thức trở thành công ty đại chúng (IPO / nộp hồ sơ trực tiếp). | IDS.company_profiles | public_company_form_cd | Scheme: IDS_PUBLIC_COMPANY_FORM. |
| 39 | Capital Paid Reported Amount | cptl_paid_rpt_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ thực góp (cập nhật theo BCTC năm). | IDS.company_profiles | capital_paid_reported |  |
| 40 | Treasury Shares Quantity | trsr_shr_qty | INT | X |  |  |  | Cổ phiếu quỹ hiện có. | IDS.company_profiles | treasury_shares |  |
| 41 | Fiscal Year Start Date | fyr_strt_dt | DATE | X |  |  |  | Ngày bắt đầu năm tài chính. | IDS.company_profiles | fy_start_date |  |
| 42 | Fiscal Year End Date | fyr_end_dt | DATE | X |  |  |  | Ngày kết thúc năm tài chính. | IDS.company_profiles | fy_end_date |  |
| 43 | Financial Statement Type Code | fnc_stmt_tp_code | STRING | X |  |  |  | Loại báo cáo tài chính (IFRS/VAS...). | IDS.company_profiles | financial_stmt_type_cd | Scheme: IDS_FINANCIAL_STMT_TYPE. |
| 44 | IDS Registration Flag | ids_rgst_f | BOOLEAN | X |  |  |  | Trạng thái đăng ký trên IDS (1=đã đăng ký / 0=chưa). | IDS.company_profiles | ids_reg_status_flg |  |
| 45 | IDS Registration Date | ids_rgst_dt | DATE | X |  |  |  | Ngày đăng ký trên IDS. | IDS.company_profiles | ids_reg_date |  |
| 46 | Public Company Flag | pblc_co_f | BOOLEAN | X |  |  |  | Là công ty đại chúng (1=có / 0=không). | IDS.company_profiles | public_com_flg |  |
| 47 | Public Bond Issuer Flag | pblc_bond_issur_f | BOOLEAN | X |  |  |  | Là tổ chức niêm yết trái phiếu (1=có / 0=không). | IDS.company_profiles | public_bond_issuer_flg |  |
| 48 | Large Public Company Flag | lrg_pblc_co_f | BOOLEAN | X |  |  |  | Là công ty đại chúng quy mô lớn (1=có / 0=không). | IDS.company_profiles | large_public_com_flg |  |
| 49 | Former State Owned Flag | formr_ste_own_f | BOOLEAN | X |  |  |  | Tiền thân là doanh nghiệp nhà nước (1=có / 0=không). | IDS.company_profiles | former_state_owned_flg |  |
| 50 | Equitisation License Date | equitisation_license_dt | DATE | X |  |  |  | Ngày được cấp GPKD sau cổ phần hóa. | IDS.company_profiles | equit_license_date |  |
| 51 | Capital At Equitisation Amount | cptl_at_equitisation_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ thực góp tại thời điểm cổ phần hóa. | IDS.company_profiles | capital_at_equit |  |
| 52 | Has State Own Flag | has_ste_own_f | BOOLEAN | X |  |  |  | Có vốn nhà nước (1=có / 0=không). | IDS.company_profiles | has_state_own_flg |  |
| 53 | FDI Company Flag | fdi_co_f | BOOLEAN | X |  |  |  | Là doanh nghiệp FDI (1=có / 0=không). | IDS.company_profiles | fdi_com_flg |  |
| 54 | Has Parent Company Flag | has_prn_co_f | BOOLEAN | X |  |  |  | Có công ty mẹ (1=có / 0=không). | IDS.company_profiles | has_parent_com_flg |  |
| 55 | Has Subsidiaries Flag | has_subs_f | BOOLEAN | X |  |  |  | Có công ty con (1=có / 0=không). | IDS.company_profiles | has_subsidiaries_flg |  |
| 56 | Has Joint Ventures Flag | has_jnt_ventures_f | BOOLEAN | X |  |  |  | Có công ty liên doanh, liên kết (1=có / 0=không). | IDS.company_profiles | has_joint_ventures_flg |  |
| 57 | Enterprise Type Code | entp_tp_code | STRING | X |  |  |  | Loại hình doanh nghiệp (bh/td/ck/dn). | IDS.company_profiles | report_type_cd | Scheme: IDS_ENTERPRISE_TYPE. company_detail.report_type_cd cùng giá trị (1-1) — map primary từ company_profiles. |
| 58 | Specialist Notes | spcl_notes | STRING | X |  |  |  | Ghi chú của chuyên viên. | IDS.company_profiles | specialist_notes |  |
| 59 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.company_profiles | created_by |  |
| 60 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.company_profiles | created_date |  |
| 61 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.company_profiles | last_updated_by |  |
| 62 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.company_profiles | last_updated_date |  |


#### 2.{IDX}.13.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Public Company Id | pblc_co_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.14 Bảng Public Company — IDS.company_detail

- **Mô tả:** Công ty đại chúng được UBCKNN quản lý. Lưu thông tin pháp lý và trạng thái hoạt động.
- **Tên vật lý:** pblc_co
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Public Company Id | pblc_co_id | BIGINT |  | X | P |  | Khóa đại diện cho công ty đại chúng. | IDS.company_detail |  | PK surrogate. Shared entity với ThanhTra.DM_CONG_TY_DC. |
| 2 | Public Company Code | pblc_co_code | STRING |  |  |  |  | Mã định danh công ty đại chúng (PK nguồn). BK. | IDS.company_detail | id | BK chính. PK của company_profiles; cũng = company_detail.company_profile_id (quan hệ 1-1). company_detail.id là PK kỹ thuật riêng — bỏ qua. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.company_detail' | Mã nguồn dữ liệu. | IDS.company_detail |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Public Company Name | pblc_co_nm | STRING | X |  |  |  | Tên công ty đại chúng (tiếng Việt). | IDS.company_detail | company_name_vn |  |
| 5 | Public Company English Name | pblc_co_english_nm | STRING | X |  |  |  | Tên công ty đại chúng (tiếng Anh). | IDS.company_detail | company_name_en |  |
| 6 | Public Company Short Name | pblc_co_shrt_nm | STRING | X |  |  |  | Tên viết tắt công ty đại chúng. | IDS.company_detail |  |  |
| 7 | Company Type Code | co_tp_code | STRING | X |  |  |  | Loại hình công ty. | IDS.company_detail |  | Scheme: TT_COMPANY_TYPE. |
| 8 | Charter Capital Amount | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ. | IDS.company_detail |  |  |
| 9 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. | IDS.company_detail |  | Scheme: LIFE_CYCLE_STATUS. |
| 10 | Business License Number | bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. | IDS.company_detail |  |  |
| 11 | Website | webst | STRING | X |  |  |  | Website chính thức. | IDS.company_detail |  |  |
| 12 | Business Registration Number | bsn_rgst_nbr | STRING | X |  |  |  | Mã số doanh nghiệp / số ĐKKD. | IDS.company_detail | business_reg_no |  |
| 13 | First Registration Date | frst_rgst_dt | DATE | X |  |  |  | Ngày đăng ký lần đầu. | IDS.company_detail | first_reg_date |  |
| 14 | Latest Registration Date | latest_rgst_dt | DATE | X |  |  |  | Ngày cấp gần nhất. | IDS.company_detail | latest_reg_date |  |
| 15 | Latest Registration Province Code | latest_rgst_prov_code | STRING | X |  |  |  | Tỉnh/thành nơi cấp gần nhất (mã tỉnh từ provinces). | IDS.company_detail | latest_reg_prov |  |
| 16 | Industry Category Id | idy_cgy_id | BIGINT | X |  | F |  | Id ngành nghề (categories). | IDS.company_detail | category_id |  |
| 17 | Industry Category Code | idy_cgy_code | STRING | X |  |  |  | Mã ngành nghề (categories). | IDS.company_detail | category_id | Scheme: IDS_INDUSTRY_CATEGORY. Pair with Industry Category Id. Theo HLD T1-04: categories là Classification Value không phải Silver entity. |
| 18 | Industry Category Level1 Code | idy_cgy_level1_code | STRING | X |  |  |  | Ngành nghề cấp 1 (mã categories cấp 1). | IDS.company_detail | category_l1_id | Scheme: IDS_INDUSTRY_CATEGORY. Cùng scheme với Industry Category Code — denormalize cấp 1. |
| 19 | Industry Category Level2 Code | idy_cgy_level2_code | STRING | X |  |  |  | Ngành nghề cấp 2 (mã categories cấp 2). | IDS.company_detail | category_l2_id | Scheme: IDS_INDUSTRY_CATEGORY. Cùng scheme với Industry Category Code — denormalize cấp 2. |
| 20 | IDS Status Code | ids_st_code | STRING | X |  |  |  | Trạng thái niêm yết IDS. | IDS.company_detail | status_ids_cd | Scheme: IDS_COMPANY_STATUS. |
| 21 | Auto Approval Flag | auto_aprv_f | BOOLEAN | X |  |  |  | Tự động duyệt (1=tự động / 0=không). | IDS.company_detail | auto_approval_flg |  |
| 22 | Company Login | co_login | STRING | X |  |  |  | User của công ty niêm yết (login_name). | IDS.company_detail | company_login |  |
| 23 | Approver Comment | approver_cmnt | STRING | X |  |  |  | Ý kiến người duyệt. | IDS.company_detail | approver_comment |  |
| 24 | Parent Company Flag | prn_co_f | BOOLEAN | X |  |  |  | Là công ty mẹ (1=có / 0=không). | IDS.company_detail | parent_company_flg |  |
| 25 | Equity Listing Exchange Code | eqty_listing_exg_code | STRING | X |  |  |  | Sàn niêm yết cổ phiếu (HNX/HOSE/UPCoM). | IDS.company_detail | equity_listing_exch_cd | Scheme: IDS_EQUITY_LISTING_EXCH. Trùng nội dung với company_detail.equity_listing_exch (Text denormalized) — chọn cd làm primary. |
| 26 | Equity Listing Exchange Name | eqty_listing_exg_nm | STRING | X |  |  |  | Sàn niêm yết cổ phiếu (text từ company_detail). | IDS.company_detail | equity_listing_exch |  |
| 27 | Bond Listing Exchange Name | bond_listing_exg_nm | STRING | X |  |  |  | Sàn niêm yết trái phiếu (text từ company_detail). | IDS.company_detail | bond_listing_exch |  |
| 28 | Equity Security Flag | eqty_scr_f | BOOLEAN | X |  |  |  | Loại chứng khoán niêm yết là cổ phiếu (1=có / 0=không). | IDS.company_detail | equity_security_flg |  |
| 29 | Bond Security Flag | bond_scr_f | BOOLEAN | X |  |  |  | Loại chứng khoán niêm yết là trái phiếu (1=có / 0=không). | IDS.company_detail | bond_security_flg |  |
| 30 | Equity Ticker | eqty_ticker | STRING | X |  |  |  | Mã chứng khoán cổ phiếu. | IDS.company_detail | equity_ticker |  |
| 31 | Bond Ticker | bond_ticker | STRING | X |  |  |  | Mã chứng khoán trái phiếu. | IDS.company_detail | bond_ticker |  |
| 32 | Equity Listed Quantity | eqty_list_qty | INT | X |  |  |  | Số lượng cổ phiếu đang niêm yết. | IDS.company_detail | equity_listed_qty |  |
| 33 | Bond Listed Quantity | bond_list_qty | INT | X |  |  |  | Số lượng trái phiếu đang niêm yết. | IDS.company_detail | bond_listed_qty |  |
| 34 | International Exchange Name | itnl_exg_nm | STRING | X |  |  |  | Sàn niêm yết quốc tế. | IDS.company_detail | intl_exch |  |
| 35 | International Ticker | itnl_ticker | STRING | X |  |  |  | Mã chứng quốc tế. | IDS.company_detail | intl_ticker |  |
| 36 | ISIN Code | isin_code | STRING | X |  |  |  | Mã ISIN. | IDS.company_detail | isin_cd |  |
| 37 | Securities Type Code | scr_tp_code | STRING | X |  |  |  | Loại chứng khoán phát hành. | IDS.company_detail | securities_type_cd | Scheme: IDS_SECURITIES_TYPE. |
| 38 | Public Company Form Code | pblc_co_form_code | STRING | X |  |  |  | Hình thức trở thành công ty đại chúng (IPO / nộp hồ sơ trực tiếp). | IDS.company_detail | public_company_form_cd | Scheme: IDS_PUBLIC_COMPANY_FORM. |
| 39 | Capital Paid Reported Amount | cptl_paid_rpt_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ thực góp (cập nhật theo BCTC năm). | IDS.company_detail | capital_paid_reported |  |
| 40 | Treasury Shares Quantity | trsr_shr_qty | INT | X |  |  |  | Cổ phiếu quỹ hiện có. | IDS.company_detail | treasury_shares |  |
| 41 | Fiscal Year Start Date | fyr_strt_dt | DATE | X |  |  |  | Ngày bắt đầu năm tài chính. | IDS.company_detail | fy_start_date |  |
| 42 | Fiscal Year End Date | fyr_end_dt | DATE | X |  |  |  | Ngày kết thúc năm tài chính. | IDS.company_detail | fy_end_date |  |
| 43 | Financial Statement Type Code | fnc_stmt_tp_code | STRING | X |  |  |  | Loại báo cáo tài chính (IFRS/VAS...). | IDS.company_detail | financial_stmt_type_cd | Scheme: IDS_FINANCIAL_STMT_TYPE. |
| 44 | IDS Registration Flag | ids_rgst_f | BOOLEAN | X |  |  |  | Trạng thái đăng ký trên IDS (1=đã đăng ký / 0=chưa). | IDS.company_detail | ids_reg_status_flg |  |
| 45 | IDS Registration Date | ids_rgst_dt | DATE | X |  |  |  | Ngày đăng ký trên IDS. | IDS.company_detail | ids_reg_date |  |
| 46 | Public Company Flag | pblc_co_f | BOOLEAN | X |  |  |  | Là công ty đại chúng (1=có / 0=không). | IDS.company_detail | public_com_flg |  |
| 47 | Public Bond Issuer Flag | pblc_bond_issur_f | BOOLEAN | X |  |  |  | Là tổ chức niêm yết trái phiếu (1=có / 0=không). | IDS.company_detail | public_bond_issuer_flg |  |
| 48 | Large Public Company Flag | lrg_pblc_co_f | BOOLEAN | X |  |  |  | Là công ty đại chúng quy mô lớn (1=có / 0=không). | IDS.company_detail | large_public_com_flg |  |
| 49 | Former State Owned Flag | formr_ste_own_f | BOOLEAN | X |  |  |  | Tiền thân là doanh nghiệp nhà nước (1=có / 0=không). | IDS.company_detail | former_state_owned_flg |  |
| 50 | Equitisation License Date | equitisation_license_dt | DATE | X |  |  |  | Ngày được cấp GPKD sau cổ phần hóa. | IDS.company_detail | equit_license_date |  |
| 51 | Capital At Equitisation Amount | cptl_at_equitisation_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ thực góp tại thời điểm cổ phần hóa. | IDS.company_detail | capital_at_equit |  |
| 52 | Has State Own Flag | has_ste_own_f | BOOLEAN | X |  |  |  | Có vốn nhà nước (1=có / 0=không). | IDS.company_detail | has_state_own_flg |  |
| 53 | FDI Company Flag | fdi_co_f | BOOLEAN | X |  |  |  | Là doanh nghiệp FDI (1=có / 0=không). | IDS.company_detail | fdi_com_flg |  |
| 54 | Has Parent Company Flag | has_prn_co_f | BOOLEAN | X |  |  |  | Có công ty mẹ (1=có / 0=không). | IDS.company_detail | has_parent_com_flg |  |
| 55 | Has Subsidiaries Flag | has_subs_f | BOOLEAN | X |  |  |  | Có công ty con (1=có / 0=không). | IDS.company_detail | has_subsidiaries_flg |  |
| 56 | Has Joint Ventures Flag | has_jnt_ventures_f | BOOLEAN | X |  |  |  | Có công ty liên doanh, liên kết (1=có / 0=không). | IDS.company_detail | has_joint_ventures_flg |  |
| 57 | Enterprise Type Code | entp_tp_code | STRING | X |  |  |  | Loại hình doanh nghiệp (bh/td/ck/dn). | IDS.company_detail | report_type_cd | Scheme: IDS_ENTERPRISE_TYPE. company_detail.report_type_cd cùng giá trị (1-1) — map primary từ company_profiles. |
| 58 | Specialist Notes | spcl_notes | STRING | X |  |  |  | Ghi chú của chuyên viên. | IDS.company_detail | specialist_notes |  |
| 59 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.company_detail | created_by |  |
| 60 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.company_detail | created_date |  |
| 61 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.company_detail | last_updated_by |  |
| 62 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.company_detail | last_updated_date |  |


#### 2.{IDX}.14.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Public Company Id | pblc_co_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.15 Bảng Involved Party Postal Address — IDS.company_detail

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Public Company. | IDS.company_detail | company_profile_id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty đại chúng. | IDS.company_detail | company_profile_id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.company_detail' | Mã nguồn dữ liệu. | IDS.company_detail |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  | 'BUSINESS' | Loại địa chỉ — văn phòng giao dịch (business). | IDS.company_detail |  |  |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ văn phòng giao dịch. | IDS.company_detail | trading_office_addr |  |
| 6 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh kinh doanh | IDS.company_detail |  |  |
| 7 | Province Name | prov_nm | STRING | X |  |  |  | Tên tỉnh kinh doanh | IDS.company_detail |  |  |
| 8 | District Code | dstc_code | STRING | X |  |  |  | Mã huyện kinh doanh | IDS.company_detail |  |  |
| 9 | District Name | dstc_nm | STRING | X |  |  |  | Tên huyện kinh doanh | IDS.company_detail |  |  |
| 10 | Ward Code | ward_code | STRING | X |  |  |  | Mã xã kinh doanh | IDS.company_detail |  |  |
| 11 | Ward Name | ward_nm | STRING | X |  |  |  | Tên xã kinh doanh | IDS.company_detail |  |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | IDS.company_detail |  |  |
| 13 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Public Company. | IDS.company_detail | company_profile_id |  |
| 14 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty đại chúng. | IDS.company_detail | company_profile_id |  |
| 15 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.company_detail' | Mã nguồn dữ liệu. | IDS.company_detail |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 16 | Address Type Code | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. | IDS.company_detail |  |  |
| 17 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở chính. | IDS.company_detail | head_office_addr |  |
| 18 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | IDS.company_detail |  |  |
| 19 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). | IDS.company_detail | head_office_prov |  |
| 20 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. | IDS.company_detail |  |  |
| 21 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. | IDS.company_detail |  |  |
| 22 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | IDS.company_detail |  |  |
| 23 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | IDS.company_detail |  |  |
| 24 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | IDS.company_detail |  |  |


#### 2.{IDX}.15.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Public Company | Public Company Id | pblc_co_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.16 Bảng Involved Party Electronic Address — IDS.company_detail

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Public Company. | IDS.company_detail | company_profile_id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty đại chúng. | IDS.company_detail | company_profile_id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.company_detail' | Mã nguồn dữ liệu. | IDS.company_detail |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. | IDS.company_detail |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số fax. | IDS.company_detail | fax_no |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Public Company. | IDS.company_detail | company_profile_id |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty đại chúng. | IDS.company_detail | company_profile_id |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.company_detail' | Mã nguồn dữ liệu. | IDS.company_detail |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. | IDS.company_detail |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | IDS.company_detail | phone_no |  |
| 11 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Public Company. | IDS.company_detail | company_profile_id |  |
| 12 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty đại chúng. | IDS.company_detail | company_profile_id |  |
| 13 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.company_detail' | Mã nguồn dữ liệu. | IDS.company_detail |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 14 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. | IDS.company_detail |  |  |
| 15 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Website. | IDS.company_detail | website |  |


#### 2.{IDX}.16.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Public Company | Public Company Id | pblc_co_id |




### 2.{IDX}.17 Bảng Stock Holder

- **Mô tả:** Cổ đông giao dịch — cá nhân hoặc tổ chức nắm giữ cổ phần công ty đại chúng. Grain: cổ đông x công ty. FK to Public Company.
- **Tên vật lý:** stk_hldr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Stock Holder Id | stk_hldr_id | BIGINT |  | X | P |  | Khóa đại diện cho cổ đông giao dịch. | IDS.stock_holders |  | PK surrogate. |
| 2 | Stock Holder Code | stk_hldr_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.stock_holders | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.stock_holders' | Mã nguồn dữ liệu. | IDS.stock_holders |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Public Company Id | pblc_co_id | BIGINT |  |  | F |  | FK đến công ty đại chúng. | IDS.stock_holders | company_profile_id |  |
| 5 | Public Company Code | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. | IDS.stock_holders | company_profile_id |  |
| 6 | Shareholder Name | shrhlr_nm | STRING | X |  |  |  | Tên cổ đông (cá nhân hoặc tổ chức). | IDS.stock_holders | shareholder_name |  |
| 7 | Entity Type Code | ent_tp_code | STRING | X |  |  |  | Loại hình cổ đông (cá nhân, tổ chức). | IDS.stock_holders | entity_type_cd | Scheme: IDS_ENTITY_TYPE. |
| 8 | Identity Type Codes | identity_tp_codes | STRING | X |  |  |  | Danh sách loại giấy tờ (chuỗi cách nhau dấu "," — ví dụ "1,2", FK đến identity.identity_type_cd). | IDS.stock_holders | identity_type_cd |  |
| 9 | Position Codes | pos_codes | STRING | X |  |  |  | Danh sách mã chức vụ (chuỗi cách nhau dấu "," — ví dụ "6,3", FK đến positions.position_cd). | IDS.stock_holders | position_cd |  |
| 10 | Shareholder Type Codes | shrhlr_tp_codes | STRING | X |  |  |  | Danh sách loại cổ đông (chuỗi cách nhau dấu ","). | IDS.stock_holders | shareholder_type |  |
| 11 | Gender Code | gnd_code | STRING | X |  |  |  | Giới tính. | IDS.stock_holders | gender_cd | Scheme: IDS_GENDER. |
| 12 | Education Level Code | ed_lvl_code | STRING | X |  |  |  | Trình độ học vấn. | IDS.stock_holders | education_level_cd | Scheme: IDS_EDUCATION_LEVEL. |
| 13 | Birth Date | brth_dt | DATE | X |  |  |  | Ngày sinh (cá nhân). | IDS.stock_holders | birth_date |  |
| 14 | Nationality Code | nationality_code | STRING | X |  |  |  | Quốc tịch (text từ nguồn). | IDS.stock_holders | nationality |  |
| 15 | Business Registration Number | bsn_rgst_nbr | STRING | X |  |  |  | Mã doanh nghiệp (cổ đông tổ chức). | IDS.stock_holders | business_reg_no |  |
| 16 | Founder Holder Flag | founder_hldr_f | BOOLEAN | X |  |  |  | Cổ đông sáng lập (1=có / 0=không). | IDS.stock_holders | founder_hld_flg |  |
| 17 | Founder Holder Active Date | founder_hldr_actv_dt | DATE | X |  |  |  | Ngày bắt đầu là cổ đông sáng lập. | IDS.stock_holders | founder_hld_active_date |  |
| 18 | Founder Holder Inactive Date | founder_hldr_inact_dt | DATE | X |  |  |  | Ngày kết thúc là cổ đông sáng lập. | IDS.stock_holders | founder_hld_inactive_date |  |
| 19 | Major Holder Flag | major_hldr_f | BOOLEAN | X |  |  |  | Cổ đông lớn (1=có / 0=không). | IDS.stock_holders | major_hld_flg |  |
| 20 | Major Holder Active Date | major_hldr_actv_dt | DATE | X |  |  |  | Ngày bắt đầu là cổ đông lớn. | IDS.stock_holders | major_hld_active_date |  |
| 21 | Major Holder Inactive Date | major_hldr_inact_dt | DATE | X |  |  |  | Ngày kết thúc là cổ đông lớn. | IDS.stock_holders | major_hld_inactive_date |  |
| 22 | Strategic Holder Flag | strtg_hldr_f | BOOLEAN | X |  |  |  | Cổ đông chiến lược (1=có / 0=không). | IDS.stock_holders | strategic_hld_flg |  |
| 23 | Strategic Holder Active Date | strtg_hldr_actv_dt | DATE | X |  |  |  | Ngày bắt đầu là cổ đông chiến lược. | IDS.stock_holders | strategic_hld_active_date |  |
| 24 | Strategic Holder Inactive Date | strtg_hldr_inact_dt | DATE | X |  |  |  | Ngày kết thúc là cổ đông chiến lược. | IDS.stock_holders | strategic_hld_inactive_date |  |
| 25 | Insider Holder Flag | insider_hldr_f | BOOLEAN | X |  |  |  | Cổ đông nội bộ (1=có / 0=không). | IDS.stock_holders | insider_hld_flg |  |
| 26 | Insider Holder Active Date | insider_hldr_actv_dt | DATE | X |  |  |  | Ngày bắt đầu là cổ đông nội bộ. | IDS.stock_holders | insider_hld_active_date |  |
| 27 | Insider Holder Inactive Date | insider_hldr_inact_dt | DATE | X |  |  |  | Ngày kết thúc là cổ đông nội bộ. | IDS.stock_holders | insider_hld_inactive_date |  |
| 28 | Government Holder Flag | govt_hldr_f | BOOLEAN | X |  |  |  | Cổ đông nhà nước (1=có / 0=không). | IDS.stock_holders | government_hld_flg |  |
| 29 | Government Holder Active Date | govt_hldr_actv_dt | DATE | X |  |  |  | Ngày bắt đầu là cổ đông nhà nước. | IDS.stock_holders | government_hld_active_date |  |
| 30 | Government Holder Inactive Date | govt_hldr_inact_dt | DATE | X |  |  |  | Ngày kết thúc là cổ đông nhà nước. | IDS.stock_holders | government_hld_inactive_date |  |
| 31 | Bank Holder Flag | bnk_hldr_f | BOOLEAN | X |  |  |  | Cổ đông ngân hàng (1=có / 0=không). | IDS.stock_holders | bank_hld_flg |  |
| 32 | Bank Holder Active Date | bnk_hldr_actv_dt | DATE | X |  |  |  | Ngày bắt đầu là cổ đông ngân hàng. | IDS.stock_holders | bank_hld_active_date |  |
| 33 | Bank Holder Inactive Date | bnk_hldr_inact_dt | DATE | X |  |  |  | Ngày kết thúc là cổ đông ngân hàng. | IDS.stock_holders | bank_hld_inactive_date |  |
| 34 | Foreign Holder Flag | frgn_hldr_f | BOOLEAN | X |  |  |  | Cổ đông nước ngoài (1=có / 0=không). | IDS.stock_holders | foreign_hld_flg |  |
| 35 | Foreign Holder Active Date | frgn_hldr_actv_dt | DATE | X |  |  |  | Ngày bắt đầu là cổ đông nước ngoài. | IDS.stock_holders | foreign_hld_active_date |  |
| 36 | Foreign Holder Inactive Date | frgn_hldr_inact_dt | DATE | X |  |  |  | Ngày kết thúc là cổ đông nước ngoài. | IDS.stock_holders | foreign_hld_inactive_date |  |
| 37 | Related Holder Flag | rel_hldr_f | BOOLEAN | X |  |  |  | Cổ đông liên quan (1=có / 0=không). | IDS.stock_holders | related_hld_flg |  |
| 38 | Related Holder Active Date | rel_hldr_actv_dt | DATE | X |  |  |  | Ngày bắt đầu là cổ đông liên quan. | IDS.stock_holders | related_hld_active_date |  |
| 39 | Related Holder Inactive Date | rel_hldr_inact_dt | DATE | X |  |  |  | Ngày kết thúc là cổ đông liên quan. | IDS.stock_holders | related_hld_inactive_date |  |
| 40 | Other Holder Flag | othr_hldr_f | BOOLEAN | X |  |  |  | Cổ đông khác (1=có / 0=không). | IDS.stock_holders | other_hld_flg |  |
| 41 | Other Holder Active Date | othr_hldr_actv_dt | DATE | X |  |  |  | Ngày bắt đầu là cổ đông khác. | IDS.stock_holders | other_hld_active_date |  |
| 42 | Other Holder Inactive Date | othr_hldr_inact_dt | DATE | X |  |  |  | Ngày kết thúc là cổ đông khác. | IDS.stock_holders | other_hld_inactive_date |  |
| 43 | Ownership Quantity | own_qty | INT | X |  |  |  | Số lượng cổ phiếu nắm giữ. | IDS.stock_holders | ownership_qty |  |
| 44 | Ownership Ratio | own_rto | DECIMAL(9,6) | X |  |  |  | Tỷ lệ phần trăm cổ phiếu nắm giữ. | IDS.stock_holders | ownership_ratio |  |
| 45 | Tradable Share Quantity | tradable_shr_qty | INT | X |  |  |  | Số lượng cổ phiếu CTCK được phép giao dịch. | IDS.stock_holders | tradable_share_qty |  |
| 46 | Tradable Share Ratio | tradable_shr_rto | DECIMAL(9,6) | X |  |  |  | Tỷ lệ cổ phiếu CTCK được phép giao dịch (= tradable_share_qty / ownership_qty). | IDS.stock_holders | tradable_share_ratio |  |
| 47 | Ownership Date | own_dt | DATE | X |  |  |  | Ngày đặt tỷ lệ sở hữu. | IDS.stock_holders | ownership_date |  |
| 48 | Related Holder Count | rel_hldr_cnt | INT | X |  |  |  | Số người liên quan. | IDS.stock_holders | related_hld_count |  |
| 49 | Description | dsc | STRING | X |  |  |  | Mô tả. | IDS.stock_holders | description |  |
| 50 | Approval Flag | aprv_f | BOOLEAN | X |  |  |  | Trạng thái thông tin cổ đông (1=đã duyệt / 0=chưa duyệt). | IDS.stock_holders | approval_flg |  |
| 51 | Record Status Flag | rcrd_st_f | BOOLEAN | X |  |  |  | Trạng thái bản ghi (1=sửa / 0=mới). | IDS.stock_holders | record_status_flg |  |
| 52 | Reported Flag | rpt_f | BOOLEAN | X |  |  |  | Đã kết xuất ra báo cáo sang bên giám sát (1=đã / 0=chưa). | IDS.stock_holders | reported_flg |  |
| 53 | Export Status Flag | exprt_st_f | STRING | X |  |  |  | Dùng cho giám sát (1=insert / 2=update). | IDS.stock_holders | exp_status_flg |  |
| 54 | VSD Data Flag | vsd_data_f | BOOLEAN | X |  |  |  | Dữ liệu cập nhật từ trung tâm lưu ký. | IDS.stock_holders | vsd_data_flg |  |
| 55 | Reason | rsn | STRING | X |  |  |  | Lý do. | IDS.stock_holders | reason |  |
| 56 | VSD Data Updated Timestamp | vsd_data_udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật dữ liệu từ trung tâm lưu ký. | IDS.stock_holders | vsd_data_updated_date |  |
| 57 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.stock_holders | created_by |  |
| 58 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.stock_holders | created_date |  |
| 59 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.stock_holders | last_updated_by |  |
| 60 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.stock_holders | last_updated_date |  |


#### 2.{IDX}.17.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Stock Holder Id | stk_hldr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Public Company Id | pblc_co_id | Public Company | Public Company Id | pblc_co_id |




### 2.{IDX}.18 Bảng Involved Party Postal Address — IDS.stock_holders

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Stock Holder. | IDS.stock_holders | id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã cổ đông. | IDS.stock_holders | id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.stock_holders' | Mã nguồn dữ liệu. | IDS.stock_holders |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  | 'ADDRESS' | Loại địa chỉ — địa chỉ chung (không phân biệt loại). | IDS.stock_holders |  |  |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ cổ đông. | IDS.stock_holders | address |  |
| 6 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | IDS.stock_holders |  |  |


#### 2.{IDX}.18.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Stock Holder | Stock Holder Id | stk_hldr_id |




### 2.{IDX}.19 Bảng Involved Party Electronic Address — IDS.stock_holders

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Stock Holder. | IDS.stock_holders | id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã cổ đông. | IDS.stock_holders | id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.stock_holders' | Mã nguồn dữ liệu. | IDS.stock_holders |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. | IDS.stock_holders |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số fax. | IDS.stock_holders | fax_no |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Stock Holder. | IDS.stock_holders | id |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã cổ đông. | IDS.stock_holders | id |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.stock_holders' | Mã nguồn dữ liệu. | IDS.stock_holders |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. | IDS.stock_holders |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | IDS.stock_holders | phone_no |  |


#### 2.{IDX}.19.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Stock Holder | Stock Holder Id | stk_hldr_id |




### 2.{IDX}.20 Bảng Audit Firm Legal Representative

- **Mô tả:** Người đại diện pháp luật của công ty kiểm toán — chức vụ và ngày bổ nhiệm/kết thúc nhiệm kỳ. FK to Audit Firm.
- **Tên vật lý:** audt_firm_lgl_representative
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Audit Firm Legal Representative Id | audt_firm_lgl_representative_id | BIGINT |  | X | P |  | Khóa đại diện cho người đại diện pháp luật của công ty kiểm toán. | IDS.af_legal_representative |  | PK surrogate. |
| 2 | Audit Firm Legal Representative Code | audt_firm_lgl_representative_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.af_legal_representative | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.af_legal_representative' | Mã nguồn dữ liệu. | IDS.af_legal_representative |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Audit Firm Id | audt_firm_id | BIGINT |  |  | F |  | FK đến công ty kiểm toán. | IDS.af_legal_representative | af_profile_id |  |
| 5 | Audit Firm Code | audt_firm_code | STRING |  |  |  |  | Mã công ty kiểm toán. | IDS.af_legal_representative | af_profile_id |  |
| 6 | Full Name | full_nm | STRING | X |  |  |  | Họ tên người đại diện pháp luật. | IDS.af_legal_representative | full_name |  |
| 7 | Position Title Code | pos_ttl_code | STRING | X |  |  |  | Chức vụ. | IDS.af_legal_representative | position_title_cd | Scheme: IDS_AF_POSITION_TITLE. Dùng chung với af_auditor_approval. |
| 8 | Appointment Start Date | appointment_strt_dt | DATE | X |  |  |  | Ngày bổ nhiệm. | IDS.af_legal_representative | appointment_start_date |  |
| 9 | Appointment End Date | appointment_end_dt | DATE | X |  |  |  | Ngày kết thúc nhiệm kỳ. | IDS.af_legal_representative | appointment_end_date |  |
| 10 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.af_legal_representative | created_by |  |
| 11 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.af_legal_representative | created_date |  |
| 12 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.af_legal_representative | last_updated_by |  |
| 13 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.af_legal_representative | last_updated_date |  |


#### 2.{IDX}.20.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Audit Firm Legal Representative Id | audt_firm_lgl_representative_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Audit Firm Id | audt_firm_id | Audit Firm | Audit Firm Id | audt_firm_id |




### 2.{IDX}.21 Bảng Involved Party Electronic Address — IDS.af_legal_representative

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Audit Firm Legal Representative. | IDS.af_legal_representative | id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người đại diện pháp luật. | IDS.af_legal_representative | id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.af_legal_representative' | Mã nguồn dữ liệu. | IDS.af_legal_representative |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. | IDS.af_legal_representative |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại liên hệ. | IDS.af_legal_representative | phone_no |  |


#### 2.{IDX}.21.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Audit Firm Legal Representative | Audit Firm Legal Representative Id | audt_firm_lgl_representative_id |




### 2.{IDX}.22 Bảng Involved Party Alternative Identification — IDS.af_legal_representative

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Audit Firm Legal Representative. | IDS.af_legal_representative | id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người đại diện pháp luật. | IDS.af_legal_representative | id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.af_legal_representative' | Mã nguồn dữ liệu. | IDS.af_legal_representative |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'NATIONAL_ID' | Loại giấy tờ — CMND/Hộ chiếu (nguồn không phân biệt rõ). | IDS.af_legal_representative |  | Scheme: IP_ALT_ID_TYPE. Nguồn ghi gộp identity_no không tách CMND/HC — dùng NATIONAL_ID làm default. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số CMND/Hộ chiếu. | IDS.af_legal_representative | identity_no |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp CMND/CCCD. | IDS.af_legal_representative |  |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp CMND/CCCD. | IDS.af_legal_representative |  |  |


#### 2.{IDX}.22.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Audit Firm Legal Representative | Audit Firm Legal Representative Id | audt_firm_lgl_representative_id |




### 2.{IDX}.23 Bảng Audit Firm Approval

- **Mô tả:** Quyết định chấp thuận/đình chỉ công ty kiểm toán từ BTC và UBCKNN — số văn bản/ngày/nội dung. Gộp 2 cơ quan. FK to Audit Firm.
- **Tên vật lý:** audt_firm_aprv
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Audit Firm Approval Id | audt_firm_aprv_id | BIGINT |  | X | P |  | Khóa đại diện cho hồ sơ chấp thuận công ty kiểm toán. | IDS.af_approval |  | PK surrogate. |
| 2 | Audit Firm Approval Code | audt_firm_aprv_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.af_approval | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.af_approval' | Mã nguồn dữ liệu. | IDS.af_approval |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Audit Firm Id | audt_firm_id | BIGINT |  |  | F |  | FK đến công ty kiểm toán. | IDS.af_approval | af_profile_id |  |
| 5 | Audit Firm Code | audt_firm_code | STRING |  |  |  |  | Mã công ty kiểm toán. | IDS.af_approval | af_profile_id |  |
| 6 | MOF Approval Document Number | mof_aprv_doc_nbr | STRING | X |  |  |  | Số văn bản quyết định chấp thuận của Bộ Tài chính. | IDS.af_approval | mof_approval_doc_no |  |
| 7 | MOF Approval Issue Date | mof_aprv_issu_dt | DATE | X |  |  |  | Ngày ban hành quyết định chấp thuận của BTC. | IDS.af_approval | mof_approval_issue_date |  |
| 8 | MOF Approval Start Date | mof_aprv_strt_dt | DATE | X |  |  |  | Ngày bắt đầu hiệu lực quyết định chấp thuận của BTC. | IDS.af_approval | mof_approval_start_date |  |
| 9 | MOF Approval End Date | mof_aprv_end_dt | DATE | X |  |  |  | Ngày kết thúc hiệu lực quyết định chấp thuận của BTC. | IDS.af_approval | mof_approval_end_date |  |
| 10 | MOF Approval Content | mof_aprv_cntnt | STRING | X |  |  |  | Nội dung quyết định chấp thuận của BTC. | IDS.af_approval | mof_approval_content |  |
| 11 | SSC Approval Document Number | ssc_aprv_doc_nbr | STRING | X |  |  |  | Số văn bản quyết định chấp thuận của UBCKNN. | IDS.af_approval | ssc_approval_doc_no |  |
| 12 | SSC Approval Issue Date | ssc_aprv_issu_dt | DATE | X |  |  |  | Ngày ban hành quyết định chấp thuận của UBCKNN. | IDS.af_approval | ssc_approval_issue_date |  |
| 13 | SSC Approval Start Date | ssc_aprv_strt_dt | DATE | X |  |  |  | Ngày bắt đầu hiệu lực quyết định chấp thuận của UBCKNN. | IDS.af_approval | ssc_approval_start_date |  |
| 14 | SSC Approval End Date | ssc_aprv_end_dt | DATE | X |  |  |  | Ngày kết thúc hiệu lực quyết định chấp thuận của UBCKNN. | IDS.af_approval | ssc_approval_end_date |  |
| 15 | SSC Approval Content | ssc_aprv_cntnt | STRING | X |  |  |  | Nội dung quyết định chấp thuận của UBCKNN. | IDS.af_approval | ssc_approval_content |  |
| 16 | MOF Suspension Document Number | mof_susp_doc_nbr | STRING | X |  |  |  | Số văn bản quyết định đình chỉ của BTC. | IDS.af_approval | mof_suspension_doc_no |  |
| 17 | MOF Suspension Issue Date | mof_susp_issu_dt | DATE | X |  |  |  | Ngày ban hành quyết định đình chỉ của BTC. | IDS.af_approval | mof_suspension_issue_date |  |
| 18 | MOF Suspension Start Date | mof_susp_strt_dt | DATE | X |  |  |  | Ngày bắt đầu đình chỉ của BTC. | IDS.af_approval | mof_suspension_start_date |  |
| 19 | MOF Suspension End Date | mof_susp_end_dt | DATE | X |  |  |  | Ngày kết thúc đình chỉ của BTC. | IDS.af_approval | mof_suspension_end_date |  |
| 20 | MOF Suspension Content | mof_susp_cntnt | STRING | X |  |  |  | Nội dung quyết định đình chỉ của BTC. | IDS.af_approval | mof_suspension_content |  |
| 21 | SSC Suspension Document Number | ssc_susp_doc_nbr | STRING | X |  |  |  | Số văn bản quyết định đình chỉ của UBCKNN. | IDS.af_approval | ssc_suspension_doc_no |  |
| 22 | SSC Suspension Issue Date | ssc_susp_issu_dt | DATE | X |  |  |  | Ngày ban hành quyết định đình chỉ của UBCKNN. | IDS.af_approval | ssc_suspension_issue_date |  |
| 23 | SSC Suspension Start Date | ssc_susp_strt_dt | DATE | X |  |  |  | Ngày bắt đầu đình chỉ của UBCKNN. | IDS.af_approval | ssc_suspension_start_date |  |
| 24 | SSC Suspension End Date | ssc_susp_end_dt | DATE | X |  |  |  | Ngày kết thúc đình chỉ của UBCKNN. | IDS.af_approval | ssc_suspension_end_date |  |
| 25 | SSC Suspension Content | ssc_susp_cntnt | STRING | X |  |  |  | Nội dung quyết định đình chỉ của UBCKNN. | IDS.af_approval | ssc_suspension_content |  |
| 26 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.af_approval | created_by |  |
| 27 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.af_approval | created_date |  |
| 28 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.af_approval | last_updated_by |  |
| 29 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.af_approval | last_updated_date |  |


#### 2.{IDX}.23.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Audit Firm Approval Id | audt_firm_aprv_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Audit Firm Id | audt_firm_id | Audit Firm | Audit Firm Id | audt_firm_id |




### 2.{IDX}.24 Bảng Auditor Approval

- **Mô tả:** Quyết định chấp thuận/đình chỉ kiểm toán viên từ BTC và UBCKNN — chứng chỉ hành nghề/năm chấp thuận. FK to Audit Firm.
- **Tên vật lý:** auditor_aprv
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Auditor Approval Id | auditor_aprv_id | BIGINT |  | X | P |  | Khóa đại diện cho hồ sơ chấp thuận kiểm toán viên. | IDS.af_auditor_approval |  | PK surrogate. |
| 2 | Auditor Approval Code | auditor_aprv_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.af_auditor_approval | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.af_auditor_approval' | Mã nguồn dữ liệu. | IDS.af_auditor_approval |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Audit Firm Id | audt_firm_id | BIGINT |  |  | F |  | FK đến công ty kiểm toán. | IDS.af_auditor_approval | af_profile_id |  |
| 5 | Audit Firm Code | audt_firm_code | STRING |  |  |  |  | Mã công ty kiểm toán. | IDS.af_auditor_approval | af_profile_id |  |
| 6 | Auditor Full Name | auditor_full_nm | STRING | X |  |  |  | Họ tên kiểm toán viên. | IDS.af_auditor_approval | full_name |  |
| 7 | Audit Practice Certificate Number | audt_practice_ctf_nbr | STRING | X |  |  |  | Số GCN đăng ký hành nghề kiểm toán. | IDS.af_auditor_approval | audit_practice_cert_no |  |
| 8 | Position Title Code | pos_ttl_code | STRING | X |  |  |  | Chức vụ kiểm toán viên. | IDS.af_auditor_approval | position_title_cd | Scheme: IDS_AF_POSITION_TITLE. Dùng chung với af_legal_representative. |
| 9 | MOF Approval Document Number | mof_aprv_doc_nbr | STRING | X |  |  |  | Số văn bản quyết định chấp thuận của Bộ Tài chính. | IDS.af_auditor_approval | mof_approval_doc_no |  |
| 10 | MOF Approval Issue Date | mof_aprv_issu_dt | DATE | X |  |  |  | Ngày ban hành quyết định chấp thuận của BTC. | IDS.af_auditor_approval | mof_approval_issue_date |  |
| 11 | MOF Approval Start Date | mof_aprv_strt_dt | DATE | X |  |  |  | Ngày bắt đầu hiệu lực chấp thuận của BTC. | IDS.af_auditor_approval | mof_approval_start_date |  |
| 12 | MOF Approval End Date | mof_aprv_end_dt | DATE | X |  |  |  | Ngày kết thúc hiệu lực chấp thuận của BTC. | IDS.af_auditor_approval | mof_approval_end_date |  |
| 13 | MOF Approval Content | mof_aprv_cntnt | STRING | X |  |  |  | Nội dung quyết định chấp thuận của BTC. | IDS.af_auditor_approval | mof_approval_content |  |
| 14 | SSC Approval Document Number | ssc_aprv_doc_nbr | STRING | X |  |  |  | Số văn bản quyết định chấp thuận của UBCKNN. | IDS.af_auditor_approval | ssc_approval_doc_no |  |
| 15 | SSC Approval Issue Date | ssc_aprv_issu_dt | DATE | X |  |  |  | Ngày ban hành quyết định chấp thuận của UBCKNN. | IDS.af_auditor_approval | ssc_approval_issue_date |  |
| 16 | SSC Approval Start Date | ssc_aprv_strt_dt | DATE | X |  |  |  | Ngày bắt đầu hiệu lực chấp thuận của UBCKNN. | IDS.af_auditor_approval | ssc_approval_start_date |  |
| 17 | SSC Approval End Date | ssc_aprv_end_dt | DATE | X |  |  |  | Ngày kết thúc hiệu lực chấp thuận của UBCKNN. | IDS.af_auditor_approval | ssc_approval_end_date |  |
| 18 | SSC Approval Content | ssc_aprv_cntnt | STRING | X |  |  |  | Nội dung quyết định chấp thuận của UBCKNN. | IDS.af_auditor_approval | ssc_approval_content |  |
| 19 | MOF Suspension Document Number | mof_susp_doc_nbr | STRING | X |  |  |  | Số văn bản quyết định đình chỉ của BTC. | IDS.af_auditor_approval | mof_suspension_doc_no |  |
| 20 | MOF Suspension Issue Date | mof_susp_issu_dt | DATE | X |  |  |  | Ngày ban hành quyết định đình chỉ của BTC. | IDS.af_auditor_approval | mof_suspension_issue_date |  |
| 21 | MOF Suspension Start Date | mof_susp_strt_dt | DATE | X |  |  |  | Ngày bắt đầu đình chỉ của BTC. | IDS.af_auditor_approval | mof_suspension_start_date |  |
| 22 | MOF Suspension End Date | mof_susp_end_dt | DATE | X |  |  |  | Ngày kết thúc đình chỉ của BTC. | IDS.af_auditor_approval | mof_suspension_end_date |  |
| 23 | MOF Suspension Content | mof_susp_cntnt | STRING | X |  |  |  | Nội dung quyết định đình chỉ của BTC. | IDS.af_auditor_approval | mof_suspension_content |  |
| 24 | SSC Suspension Document Number | ssc_susp_doc_nbr | STRING | X |  |  |  | Số văn bản quyết định đình chỉ của UBCKNN. | IDS.af_auditor_approval | ssc_suspension_doc_no |  |
| 25 | SSC Suspension Issue Date | ssc_susp_issu_dt | DATE | X |  |  |  | Ngày ban hành quyết định đình chỉ của UBCKNN. | IDS.af_auditor_approval | ssc_suspension_issue_date |  |
| 26 | SSC Suspension Start Date | ssc_susp_strt_dt | DATE | X |  |  |  | Ngày bắt đầu đình chỉ của UBCKNN. | IDS.af_auditor_approval | ssc_suspension_start_date |  |
| 27 | SSC Suspension End Date | ssc_susp_end_dt | DATE | X |  |  |  | Ngày kết thúc đình chỉ của UBCKNN. | IDS.af_auditor_approval | ssc_suspension_end_date |  |
| 28 | SSC Suspension Content | ssc_susp_cntnt | STRING | X |  |  |  | Nội dung quyết định đình chỉ của UBCKNN. | IDS.af_auditor_approval | ssc_suspension_content |  |
| 29 | Accept Year | acpt_yr | INT | X |  |  |  | Năm chấp thuận (dùng cho mục đích báo cáo). | IDS.af_auditor_approval | accept_year |  |
| 30 | Affiliation End Date | affiliation_end_dt | DATE | X |  |  |  | Ngày kiểm toán viên không còn thuộc công ty kiểm toán. | IDS.af_auditor_approval | affiliation_end_date |  |
| 31 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.af_auditor_approval | created_by |  |
| 32 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.af_auditor_approval | created_date |  |
| 33 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.af_auditor_approval | last_updated_by |  |
| 34 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.af_auditor_approval | last_updated_date |  |


#### 2.{IDX}.24.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Auditor Approval Id | auditor_aprv_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Audit Firm Id | audt_firm_id | Audit Firm | Audit Firm Id | audt_firm_id |




### 2.{IDX}.25 Bảng Disclosure Notification Config

- **Mô tả:** Cấu hình thông báo CBTT — kênh gửi/hệ thống nhận/người quản lý. FK to Disclosure Notification.
- **Tên vật lý:** dscl_notf_config
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Disclosure Notification Config Id | dscl_notf_config_id | BIGINT |  | X | P |  | Khóa đại diện cho cấu hình thông báo CBTT. | IDS.noti_config |  | PK surrogate. |
| 2 | Disclosure Notification Config Code | dscl_notf_config_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.noti_config | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.noti_config' | Mã nguồn dữ liệu. | IDS.noti_config |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Disclosure Notification Id | dscl_notf_id | BIGINT |  |  | F |  | FK đến instance thông báo CBTT. | IDS.noti_config | notification_id |  |
| 5 | Disclosure Notification Code | dscl_notf_code | STRING |  |  |  |  | Mã thông báo CBTT. | IDS.noti_config | notification_id |  |
| 6 | Notification Business Code | notf_bsn_code | STRING | X |  |  |  | Mã thông báo (denormalized từ notifications). | IDS.noti_config | noti_cd |  |
| 7 | Notification Title | notf_ttl | STRING | X |  |  |  | Tiêu đề thông báo (tiếng Việt — denormalized từ notifications). | IDS.noti_config | noti_title_vi |  |
| 8 | Notification English Title | notf_english_ttl | STRING | X |  |  |  | Tiêu đề thông báo (tiếng Anh — denormalized từ notifications). | IDS.noti_config | noti_title_en |  |
| 9 | Send Channel Code | snd_cnl_code | STRING | X |  |  |  | Hình thức gửi tin (email/sms/push). | IDS.noti_config | send_channel_cd | Scheme: IDS_NOTIFICATION_SEND_CHANNEL. |
| 10 | Active Flag | actv_f | BOOLEAN | X |  |  |  | Trạng thái kích hoạt (1=kích hoạt / 0=không). | IDS.noti_config | active_flg |  |
| 11 | Target System Code | trgt_stm_code | STRING | X |  |  |  | Hệ thống nhận thông báo. | IDS.noti_config | target_system_cd | Scheme: IDS_NOTIFICATION_TARGET_SYSTEM. |
| 12 | Manager Login Id | mgr_login_id | BIGINT | X |  | F |  | Id người quản lý (logins). | IDS.noti_config | login_id |  |
| 13 | Manager Login Name | mgr_login_nm | STRING | X |  |  |  | Tên đăng nhập người quản lý. | IDS.noti_config | login_name |  |
| 14 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.noti_config | created_by |  |
| 15 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.noti_config | created_date |  |
| 16 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.noti_config | last_updated_by |  |
| 17 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.noti_config | last_updated_date |  |


#### 2.{IDX}.25.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Disclosure Notification Config Id | dscl_notf_config_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Disclosure Notification Id | dscl_notf_id | Disclosure Notification | Disclosure Notification Id | dscl_notf_id |




### 2.{IDX}.26 Bảng Public Company Legal Representative

- **Mô tả:** Người đại diện pháp luật và người CBTT của công ty đại chúng — representative_role_code phân biệt 2 vai trò. FK to Public Company.
- **Tên vật lý:** pblc_co_lgl_representative
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Public Company Legal Representative Id | pblc_co_lgl_representative_id | BIGINT |  | X | P |  | Khóa đại diện cho người đại diện pháp luật/CBTT của công ty đại chúng. | IDS.legal_representative |  | PK surrogate. |
| 2 | Public Company Legal Representative Code | pblc_co_lgl_representative_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.legal_representative | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.legal_representative' | Mã nguồn dữ liệu. | IDS.legal_representative |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Public Company Id | pblc_co_id | BIGINT |  |  | F |  | FK đến công ty đại chúng. | IDS.legal_representative | company_profile_id |  |
| 5 | Public Company Code | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. | IDS.legal_representative | company_profile_id |  |
| 6 | Full Name | full_nm | STRING | X |  |  |  | Họ tên người đại diện. | IDS.legal_representative | name |  |
| 7 | Position Title | pos_ttl | STRING | X |  |  |  | Chức vụ. | IDS.legal_representative | position_title |  |
| 8 | Appointment Date | appointment_dt | DATE | X |  |  |  | Ngày bổ nhiệm. | IDS.legal_representative | appointment_date |  |
| 9 | Representative Role Code | representative_rl_code | STRING | X |  |  |  | Vai trò (0=người đại diện pháp luật, 1=người CBTT). | IDS.legal_representative | representative_role | Scheme: IDS_REPRESENTATIVE_ROLE. |
| 10 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.legal_representative | created_by |  |
| 11 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.legal_representative | created_date |  |
| 12 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.legal_representative | last_updated_by |  |
| 13 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.legal_representative | last_updated_date |  |


#### 2.{IDX}.26.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Public Company Legal Representative Id | pblc_co_lgl_representative_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Public Company Id | pblc_co_id | Public Company | Public Company Id | pblc_co_id |




### 2.{IDX}.27 Bảng Involved Party Electronic Address — IDS.legal_representative

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Public Company Legal Representative. | IDS.legal_representative | id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người đại diện. | IDS.legal_representative | id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.legal_representative' | Mã nguồn dữ liệu. | IDS.legal_representative |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. | IDS.legal_representative |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Email. | IDS.legal_representative | email |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Public Company Legal Representative. | IDS.legal_representative | id |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người đại diện. | IDS.legal_representative | id |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.legal_representative' | Mã nguồn dữ liệu. | IDS.legal_representative |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. | IDS.legal_representative |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | IDS.legal_representative | phone_no |  |


#### 2.{IDX}.27.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Public Company Legal Representative | Public Company Legal Representative Id | pblc_co_lgl_representative_id |




### 2.{IDX}.28 Bảng Involved Party Alternative Identification — IDS.legal_representative

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Public Company Legal Representative. | IDS.legal_representative | id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người đại diện. | IDS.legal_representative | id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.legal_representative' | Mã nguồn dữ liệu. | IDS.legal_representative |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  | 'NATIONAL_ID' | Loại giấy tờ — CMND/CCCD/Hộ chiếu (nguồn không phân biệt rõ). | IDS.legal_representative |  | Scheme: IP_ALT_ID_TYPE. Nguồn mô tả identity_no là CMND/CCCD/Hộ chiếu nhưng không có cột type phân biệt — dùng NATIONAL_ID làm default. Cần profile data nguồn. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số CMND/CCCD/Hộ chiếu. | IDS.legal_representative | identity_no |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp giấy tờ. | IDS.legal_representative | issue_date |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy tờ. | IDS.legal_representative | issue_place |  |


#### 2.{IDX}.28.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Public Company Legal Representative | Public Company Legal Representative Id | pblc_co_lgl_representative_id |




### 2.{IDX}.29 Bảng Public Company Related Entity

- **Mô tả:** Công ty mẹ/con/liên kết của công ty đại chúng — tên/MST/vốn/tỷ lệ sở hữu/thời hạn hiệu lực. FK to Public Company.
- **Tên vật lý:** pblc_co_rel_ent
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Public Company Related Entity Id | pblc_co_rel_ent_id | BIGINT |  | X | P |  | Khóa đại diện cho quan hệ công ty mẹ/con/liên kết của công ty đại chúng. | IDS.company_relationship |  | PK surrogate. |
| 2 | Public Company Related Entity Code | pblc_co_rel_ent_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.company_relationship | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.company_relationship' | Mã nguồn dữ liệu. | IDS.company_relationship |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Public Company Id | pblc_co_id | BIGINT |  |  | F |  | FK đến công ty đại chúng. | IDS.company_relationship | company_profile_id |  |
| 5 | Public Company Code | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. | IDS.company_relationship | company_profile_id |  |
| 6 | Relationship Type Code | rltnp_tp_code | STRING | X |  |  |  | Loại quan hệ (mẹ / con / liên doanh liên kết). | IDS.company_relationship | relationship_type_cd | Scheme: IDS_COMPANY_RELATIONSHIP_TYPE. |
| 7 | Related Entity Name | rel_ent_nm | STRING | X |  |  |  | Tên công ty liên quan (tiếng Việt). | IDS.company_relationship | full_name_vi |  |
| 8 | Related Entity English Name | rel_ent_english_nm | STRING | X |  |  |  | Tên công ty liên quan (tiếng Anh). | IDS.company_relationship | full_name_en |  |
| 9 | Related Entity Business Registration Number | rel_ent_bsn_rgst_nbr | STRING | X |  |  |  | Mã số doanh nghiệp công ty liên quan. | IDS.company_relationship | business_reg_no |  |
| 10 | Related Entity Charter Capital Amount | rel_ent_charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ thực góp công ty liên quan. | IDS.company_relationship | paid_in_capital |  |
| 11 | Owned Share Quantity | own_shr_qty | INT | X |  |  |  | Số cổ phiếu sở hữu trong công ty liên quan. | IDS.company_relationship | owned_share_qty |  |
| 12 | Ownership Ratio | own_rto | DECIMAL(9,6) | X |  |  |  | Tỷ lệ phần trăm sở hữu. | IDS.company_relationship | ownership_ratio |  |
| 13 | Effective From Date | eff_fm_dt | DATE | X |  |  |  | Ngày bắt đầu hiệu lực quan hệ. | IDS.company_relationship | effective_from_date |  |
| 14 | Effective To Date | eff_to_dt | DATE | X |  |  |  | Ngày kết thúc hiệu lực quan hệ. | IDS.company_relationship | effective_to_date |  |
| 15 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.company_relationship | created_by |  |
| 16 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.company_relationship | created_date |  |
| 17 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.company_relationship | last_updated_by |  |
| 18 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.company_relationship | last_updated_date |  |


#### 2.{IDX}.29.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Public Company Related Entity Id | pblc_co_rel_ent_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Public Company Id | pblc_co_id | Public Company | Public Company Id | pblc_co_id |




### 2.{IDX}.30 Bảng Public Company State Capital

- **Mô tả:** Thông tin sở hữu nhà nước trong công ty đại chúng — tên đại diện nhà nước và tỷ lệ sở hữu. FK to Public Company.
- **Tên vật lý:** pblc_co_ste_cptl
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Public Company State Capital Id | pblc_co_ste_cptl_id | BIGINT |  | X | P |  | Khóa đại diện cho bản ghi sở hữu nhà nước trong công ty đại chúng. | IDS.state_capital |  | PK surrogate. |
| 2 | Public Company State Capital Code | pblc_co_ste_cptl_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.state_capital | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.state_capital' | Mã nguồn dữ liệu. | IDS.state_capital |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Public Company Id | pblc_co_id | BIGINT |  |  | F |  | FK đến công ty đại chúng. | IDS.state_capital | company_profile_id |  |
| 5 | Public Company Code | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. | IDS.state_capital | company_profile_id |  |
| 6 | State Representative Name | ste_representative_nm | STRING | X |  |  |  | Tên đại diện nhà nước (tiếng Việt). | IDS.state_capital | state_rep_name_vi |  |
| 7 | State Representative English Name | ste_representative_english_nm | STRING | X |  |  |  | Tên đại diện nhà nước (tiếng Anh). | IDS.state_capital | state_rep_name_en |  |
| 8 | Owned Share Quantity | own_shr_qty | INT | X |  |  |  | Số cổ phiếu sở hữu nhà nước. | IDS.state_capital | owned_share_qty |  |
| 9 | Ownership Ratio | own_rto | DECIMAL(9,6) | X |  |  |  | Tỷ lệ phần trăm sở hữu nhà nước. | IDS.state_capital | ownership_ratio |  |
| 10 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.state_capital | created_by |  |
| 11 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.state_capital | created_date |  |
| 12 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.state_capital | last_updated_by |  |
| 13 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.state_capital | last_updated_date |  |


#### 2.{IDX}.30.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Public Company State Capital Id | pblc_co_ste_cptl_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Public Company Id | pblc_co_id | Public Company | Public Company Id | pblc_co_id |




### 2.{IDX}.31 Bảng Public Company Foreign Ownership Limit

- **Mô tả:** Giới hạn tỷ lệ sở hữu nước ngoài của công ty đại chúng — max_owner_rate và khoảng thời gian áp dụng. FK to Public Company.
- **Tên vật lý:** pblc_co_frgn_own_lmt
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Public Company Foreign Ownership Limit Id | pblc_co_frgn_own_lmt_id | BIGINT |  | X | P |  | Khóa đại diện cho giới hạn sở hữu nước ngoài. | IDS.foreign_owner_limit |  | PK surrogate. |
| 2 | Public Company Foreign Ownership Limit Code | pblc_co_frgn_own_lmt_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.foreign_owner_limit | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.foreign_owner_limit' | Mã nguồn dữ liệu. | IDS.foreign_owner_limit |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Public Company Id | pblc_co_id | BIGINT |  |  | F |  | FK đến công ty đại chúng. | IDS.foreign_owner_limit | company_profile_id |  |
| 5 | Public Company Code | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. | IDS.foreign_owner_limit | company_profile_id |  |
| 6 | Max Ownership Rate | max_own_rate | DECIMAL(9,6) | X |  |  |  | Tỷ lệ sở hữu nước ngoài tối đa. | IDS.foreign_owner_limit | max_owner_rate |  |
| 7 | Effective From Date | eff_fm_dt | DATE | X |  |  |  | Ngày bắt đầu áp dụng. | IDS.foreign_owner_limit | from_date |  |
| 8 | Effective To Date | eff_to_dt | DATE | X |  |  |  | Ngày kết thúc áp dụng. | IDS.foreign_owner_limit | to_date |  |
| 9 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.foreign_owner_limit | created_by |  |
| 10 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.foreign_owner_limit | created_date |  |
| 11 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.foreign_owner_limit | last_updated_by |  |
| 12 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.foreign_owner_limit | last_updated_date |  |


#### 2.{IDX}.31.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Public Company Foreign Ownership Limit Id | pblc_co_frgn_own_lmt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Public Company Id | pblc_co_id | Public Company | Public Company Id | pblc_co_id |




### 2.{IDX}.32 Bảng Involved Party Alternative Identification — IDS.identity

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Stock Holder. | IDS.identity | stock_holder_id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã cổ đông. | IDS.identity | stock_holder_id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.identity' | Mã nguồn dữ liệu. | IDS.identity |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ định danh (CMND/CCCD/Hộ chiếu/GPKD). | IDS.identity | identity_type_cd | Scheme: IP_ALT_ID_TYPE. ETL map identity_type_cd (scheme IDS_IDENTITY_TYPE theo lookup_values) sang scheme chuẩn IP_ALT_ID_TYPE khi ingestion. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số giấy tờ. | IDS.identity | identity_no |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp giấy tờ. | IDS.identity | identity_issued_date |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy tờ. | IDS.identity | identity_issued_place |  |


#### 2.{IDX}.32.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Stock Holder | Stock Holder Id | stk_hldr_id |




### 2.{IDX}.33 Bảng Stock Holder Trading Account

- **Mô tả:** Tài khoản giao dịch chứng khoán của cổ đông tại CTCK — số tài khoản và trạng thái. FK to Stock Holder.
- **Tên vật lý:** stk_hldr_tdg_ac
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Stock Holder Trading Account Id | stk_hldr_tdg_ac_id | BIGINT |  | X | P |  | Khóa đại diện cho tài khoản giao dịch của cổ đông. | IDS.account_numbers |  | PK surrogate. |
| 2 | Stock Holder Trading Account Code | stk_hldr_tdg_ac_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.account_numbers | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.account_numbers' | Mã nguồn dữ liệu. | IDS.account_numbers |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Stock Holder Id | stk_hldr_id | BIGINT |  |  | F |  | FK đến cổ đông. | IDS.account_numbers | stock_holder_id |  |
| 5 | Stock Holder Code | stk_hldr_code | STRING |  |  |  |  | Mã cổ đông. | IDS.account_numbers | stock_holder_id |  |
| 6 | Trading Account Number | tdg_ac_nbr | STRING | X |  |  |  | Số tài khoản giao dịch. | IDS.account_numbers | trading_account_no |  |
| 7 | Securities Company Code | scr_co_code | STRING | X |  | F |  | Mã công ty chứng khoán. | IDS.account_numbers | sec_company_cd |  |
| 8 | Account Open Date | ac_opn_dt | DATE | X |  |  |  | Ngày mở tài khoản. | IDS.account_numbers | account_open_date |  |
| 9 | Active Flag | actv_f | BOOLEAN | X |  |  |  | Trạng thái hoạt động tài khoản (1=active / 0=inactive). | IDS.account_numbers | active_flg |  |
| 10 | Primary Account Flag | prim_ac_f | BOOLEAN | X |  |  |  | Tài khoản chính (1=chính / 0=không chính). | IDS.account_numbers | primary_account_flg |  |
| 11 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.account_numbers | created_by |  |
| 12 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.account_numbers | created_date |  |
| 13 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.account_numbers | last_updated_by |  |
| 14 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.account_numbers | last_updated_date |  |


#### 2.{IDX}.33.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Stock Holder Trading Account Id | stk_hldr_tdg_ac_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Stock Holder Id | stk_hldr_id | Stock Holder | Stock Holder Id | stk_hldr_id |




### 2.{IDX}.34 Bảng Stock Holder Relationship

- **Mô tả:** Quan hệ giữa các cổ đông giao dịch — loại quan hệ/thời hạn/trạng thái. FK to Stock Holder x 2.
- **Tên vật lý:** stk_hldr_rltnp
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Stock Holder Relationship Id | stk_hldr_rltnp_id | BIGINT |  | X | P |  | Khóa đại diện cho quan hệ giữa 2 cổ đông. | IDS.holder_relationship |  | PK surrogate. |
| 2 | Stock Holder Relationship Code | stk_hldr_rltnp_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.holder_relationship | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.holder_relationship' | Mã nguồn dữ liệu. | IDS.holder_relationship |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Stock Holder Id | stk_hldr_id | BIGINT |  |  | F |  | FK đến cổ đông chính. | IDS.holder_relationship | stock_holder_id |  |
| 5 | Stock Holder Code | stk_hldr_code | STRING |  |  |  |  | Mã cổ đông chính. | IDS.holder_relationship | stock_holder_id |  |
| 6 | Related Stock Holder Id | rel_stk_hldr_id | BIGINT |  |  | F |  | FK đến cổ đông liên quan. | IDS.holder_relationship | related_holder_id |  |
| 7 | Related Stock Holder Code | rel_stk_hldr_code | STRING |  |  |  |  | Mã cổ đông liên quan. | IDS.holder_relationship | related_holder_id |  |
| 8 | Relationship Type Code | rltnp_tp_code | STRING | X |  |  |  | Loại quan hệ giữa 2 cổ đông. | IDS.holder_relationship | relationship_type_cd | Scheme: IDS_HOLDER_RELATIONSHIP_TYPE. |
| 9 | Effective Date | eff_dt | DATE | X |  |  |  | Ngày hiệu lực quan hệ. | IDS.holder_relationship | effective_date |  |
| 10 | End Date | end_dt | DATE | X |  |  |  | Ngày hết hiệu lực quan hệ. | IDS.holder_relationship | end_date |  |
| 11 | Active Flag | actv_f | BOOLEAN | X |  |  |  | Trạng thái quan hệ (1=active / 0=inactive). | IDS.holder_relationship | active_flg |  |
| 12 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.holder_relationship | created_by |  |
| 13 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.holder_relationship | created_date |  |
| 14 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.holder_relationship | last_updated_by |  |
| 15 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.holder_relationship | last_updated_date |  |


#### 2.{IDX}.34.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Stock Holder Relationship Id | stk_hldr_rltnp_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Stock Holder Id | stk_hldr_id | Stock Holder | Stock Holder Id | stk_hldr_id |
| Related Stock Holder Id | rel_stk_hldr_id | Stock Holder | Stock Holder Id | stk_hldr_id |




### 2.{IDX}.35 Bảng Stock Control

- **Mô tả:** Hạn chế chuyển nhượng cổ phiếu của cổ đông — số lượng bị hạn chế/thời gian/loại hạn chế. FK to Stock Holder.
- **Tên vật lý:** stk_cntl
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Stock Control Id | stk_cntl_id | BIGINT |  | X | P |  | Khóa đại diện cho bản ghi hạn chế chuyển nhượng cổ phiếu. | IDS.stock_controls |  | PK surrogate. |
| 2 | Stock Control Code | stk_cntl_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.stock_controls | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.stock_controls' | Mã nguồn dữ liệu. | IDS.stock_controls |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Stock Holder Id | stk_hldr_id | BIGINT |  |  | F |  | FK đến cổ đông. | IDS.stock_controls | stock_holder_id |  |
| 5 | Stock Holder Code | stk_hldr_code | STRING |  |  |  |  | Mã cổ đông. | IDS.stock_controls | stock_holder_id |  |
| 6 | Restricted Share Quantity | rstd_shr_qty | INT | X |  |  |  | Số cổ phiếu bị hạn chế chuyển nhượng. | IDS.stock_controls | restricted_share_qty |  |
| 7 | Restriction Start Date | rstn_strt_dt | DATE | X |  |  |  | Ngày bắt đầu hạn chế. | IDS.stock_controls | restriction_start_date |  |
| 8 | Restriction End Date | rstn_end_dt | DATE | X |  |  |  | Ngày hết hạn chế. | IDS.stock_controls | restriction_end_date |  |
| 9 | Restriction Type Code | rstn_tp_code | STRING | X |  |  |  | Loại hạn chế chuyển nhượng. | IDS.stock_controls | restriction_type_cd | Scheme: IDS_STOCK_RESTRICTION_TYPE. |
| 10 | Export Status Flag | exprt_st_f | STRING | X |  |  |  | Dùng cho giám sát (1=insert / 2=update). | IDS.stock_controls | exp_status_flg |  |
| 11 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.stock_controls | created_by |  |
| 12 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.stock_controls | created_date |  |
| 13 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.stock_controls | last_updated_by |  |
| 14 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.stock_controls | last_updated_date |  |


#### 2.{IDX}.35.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Stock Control Id | stk_cntl_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Stock Holder Id | stk_hldr_id | Stock Holder | Stock Holder Id | stk_hldr_id |




### 2.{IDX}.36 Bảng Audit Firm Warning

- **Mô tả:** Nhắc nhở từ BTC hoặc UBCKNN đến công ty kiểm toán hoặc kiểm toán viên — số văn bản và nội dung. FK nullable: Audit Firm Approval hoặc Auditor Approval.
- **Tên vật lý:** audt_firm_wrn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Audit Firm Warning Id | audt_firm_wrn_id | BIGINT |  | X | P |  | Khóa đại diện cho nhắc nhở công ty kiểm toán/kiểm toán viên. | IDS.af_warning |  | PK surrogate. |
| 2 | Audit Firm Warning Code | audt_firm_wrn_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.af_warning | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.af_warning' | Mã nguồn dữ liệu. | IDS.af_warning |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Audit Firm Approval Id | audt_firm_aprv_id | BIGINT | X |  | F |  | FK đến hồ sơ chấp thuận công ty kiểm toán (nullable khi đối tượng là KTV). | IDS.af_warning | af_approval_id |  |
| 5 | Audit Firm Approval Code | audt_firm_aprv_code | STRING | X |  |  |  | Mã hồ sơ chấp thuận công ty kiểm toán. | IDS.af_warning | af_approval_id |  |
| 6 | Auditor Approval Id | auditor_aprv_id | BIGINT | X |  | F |  | FK đến hồ sơ chấp thuận kiểm toán viên (nullable khi đối tượng là công ty KT). | IDS.af_warning | af_auditor_approval_id |  |
| 7 | Auditor Approval Code | auditor_aprv_code | STRING | X |  |  |  | Mã hồ sơ chấp thuận kiểm toán viên. | IDS.af_warning | af_auditor_approval_id |  |
| 8 | Warning Target Type Code | wrn_trgt_tp_code | STRING | X |  |  |  | Đối tượng nhắc nhở (công ty kiểm toán hay kiểm toán viên). | IDS.af_warning | warning_target_type_cd | Scheme: IDS_WARNING_TARGET_TYPE. |
| 9 | Warning Source Type Code | wrn_src_tp_code | STRING | X |  |  |  | Cơ quan nhắc nhở (BTC hay UBCKNN). | IDS.af_warning | warning_source_type_cd | Scheme: IDS_WARNING_SOURCE_TYPE. |
| 10 | Warning Document Number | wrn_doc_nbr | STRING | X |  |  |  | Số văn bản quyết định nhắc nhở. | IDS.af_warning | warning_doc_no |  |
| 11 | Warning Issue Date | wrn_issu_dt | DATE | X |  |  |  | Ngày ban hành văn bản nhắc nhở. | IDS.af_warning | warning_issue_date |  |
| 12 | Warning Start Date | wrn_strt_dt | DATE | X |  |  |  | Ngày bắt đầu hiệu lực nhắc nhở. | IDS.af_warning | warning_start_date |  |
| 13 | Warning End Date | wrn_end_dt | DATE | X |  |  |  | Ngày kết thúc hiệu lực nhắc nhở. | IDS.af_warning | warning_end_date |  |
| 14 | Warning Content | wrn_cntnt | STRING | X |  |  |  | Nội dung quyết định nhắc nhở. | IDS.af_warning | warning_content |  |
| 15 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.af_warning | created_by |  |
| 16 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.af_warning | created_date |  |
| 17 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.af_warning | last_updated_by |  |
| 18 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.af_warning | last_updated_date |  |


#### 2.{IDX}.36.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Audit Firm Warning Id | audt_firm_wrn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Audit Firm Approval Id | audt_firm_aprv_id | Audit Firm Approval | Audit Firm Approval Id | audt_firm_aprv_id |
| Auditor Approval Id | auditor_aprv_id | Auditor Approval | Auditor Approval Id | auditor_aprv_id |




### 2.{IDX}.37 Bảng Audit Firm Sanction

- **Mô tả:** Xử phạt hành chính đối với công ty kiểm toán hoặc kiểm toán viên — quyết định và nội dung xử phạt. FK nullable: Audit Firm Approval hoặc Auditor Approval.
- **Tên vật lý:** audt_firm_sanction
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Audit Firm Sanction Id | audt_firm_sanction_id | BIGINT |  | X | P |  | Khóa đại diện cho xử phạt hành chính công ty kiểm toán/kiểm toán viên. | IDS.af_sanctions |  | PK surrogate. |
| 2 | Audit Firm Sanction Code | audt_firm_sanction_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.af_sanctions | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.af_sanctions' | Mã nguồn dữ liệu. | IDS.af_sanctions |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Audit Firm Approval Id | audt_firm_aprv_id | BIGINT | X |  | F |  | FK đến hồ sơ chấp thuận công ty kiểm toán (nullable khi đối tượng là KTV). | IDS.af_sanctions | af_approval_id |  |
| 5 | Audit Firm Approval Code | audt_firm_aprv_code | STRING | X |  |  |  | Mã hồ sơ chấp thuận công ty kiểm toán. | IDS.af_sanctions | af_approval_id |  |
| 6 | Auditor Approval Id | auditor_aprv_id | BIGINT | X |  | F |  | FK đến hồ sơ chấp thuận kiểm toán viên (nullable khi đối tượng là công ty KT). | IDS.af_sanctions | af_auditor_approval_id |  |
| 7 | Auditor Approval Code | auditor_aprv_code | STRING | X |  |  |  | Mã hồ sơ chấp thuận kiểm toán viên. | IDS.af_sanctions | af_auditor_approval_id |  |
| 8 | Sanction Target Type Code | sanction_trgt_tp_code | STRING | X |  |  |  | Đối tượng xử phạt (công ty kiểm toán hay kiểm toán viên). | IDS.af_sanctions | sanction_target_type_cd | Scheme: IDS_SANCTION_TARGET_TYPE. |
| 9 | Sanction Authority Code | sanction_ahr_code | STRING | X |  |  |  | Đơn vị xử phạt (BTC hay UBCKNN). | IDS.af_sanctions | sanction_authority_cd | Scheme: IDS_SANCTION_AUTHORITY. |
| 10 | Decision Number | dcsn_nbr | STRING | X |  |  |  | Số quyết định xử phạt. | IDS.af_sanctions | decision_no |  |
| 11 | Decision Date | dcsn_dt | DATE | X |  |  |  | Ngày quyết định xử phạt. | IDS.af_sanctions | decision_date |  |
| 12 | Sanction Content | sanction_cntnt | STRING | X |  |  |  | Nội dung quyết định xử phạt. | IDS.af_sanctions | sanction_content |  |
| 13 | Attachment File Url | attachment_file_url | STRING | X |  |  |  | Đường dẫn file đính kèm. | IDS.af_sanctions | attachment_file_url |  |
| 14 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.af_sanctions | created_by |  |
| 15 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.af_sanctions | created_date |  |
| 16 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.af_sanctions | last_updated_by |  |
| 17 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.af_sanctions | last_updated_date |  |


#### 2.{IDX}.37.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Audit Firm Sanction Id | audt_firm_sanction_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Audit Firm Approval Id | audt_firm_aprv_id | Audit Firm Approval | Audit Firm Approval Id | audt_firm_aprv_id |
| Auditor Approval Id | auditor_aprv_id | Auditor Approval | Auditor Approval Id | auditor_aprv_id |




### 2.{IDX}.38 Bảng Public Company Capital Mobilization

- **Mô tả:** Tăng vốn trước khi thành công ty đại chúng — tổng vốn cuối năm và hình thức tăng. Grain: 1 năm x 1 công ty. FK to Public Company.
- **Tên vật lý:** pblc_co_cptl_mobilization
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Public Company Capital Mobilization Id | pblc_co_cptl_mobilization_id | BIGINT |  | X | P |  | Khóa đại diện cho bản ghi tăng vốn trước khi thành công ty đại chúng. | IDS.capital_mobilization |  | PK surrogate. |
| 2 | Public Company Capital Mobilization Code | pblc_co_cptl_mobilization_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.capital_mobilization | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.capital_mobilization' | Mã nguồn dữ liệu. | IDS.capital_mobilization |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Public Company Id | pblc_co_id | BIGINT |  |  | F |  | FK đến công ty đại chúng. | IDS.capital_mobilization | company_profile_id |  |
| 5 | Public Company Code | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. | IDS.capital_mobilization | company_profile_id |  |
| 6 | Report Year | rpt_yr | INT | X |  |  |  | Năm điều chỉnh vốn góp. | IDS.capital_mobilization | report_year |  |
| 7 | Paid In Capital End Of Year Amount | paid_in_cptl_eoy_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ thực góp tính đến thời điểm cuối năm. | IDS.capital_mobilization | paid_in_capital_eoy |  |
| 8 | Capital Increase Count | cptl_incr_cnt | INT | X |  |  |  | Số đợt tăng vốn trong năm. | IDS.capital_mobilization | capital_increase_count |  |
| 9 | Capital Increase Method | cptl_incr_mth | STRING | X |  |  |  | Hình thức tăng vốn. | IDS.capital_mobilization | capital_increase_method |  |
| 10 | Audit Firm Name | audt_firm_nm | STRING | X |  | F |  | Tên công ty kiểm toán xác nhận (tiếng Việt). | IDS.capital_mobilization | audit_firm_name_vi |  |
| 11 | Audit Firm English Name | audt_firm_english_nm | STRING | X |  |  |  | Tên công ty kiểm toán xác nhận (tiếng Anh). | IDS.capital_mobilization | audit_firm_name_en |  |
| 12 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.capital_mobilization | created_by |  |
| 13 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.capital_mobilization | created_date |  |
| 14 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.capital_mobilization | last_updated_by |  |
| 15 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.capital_mobilization | last_updated_date |  |


#### 2.{IDX}.38.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Public Company Capital Mobilization Id | pblc_co_cptl_mobilization_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Public Company Id | pblc_co_id | Public Company | Public Company Id | pblc_co_id |




### 2.{IDX}.39 Bảng Public Company Capital Increase

- **Mô tả:** Tăng vốn điều lệ sau khi thành công ty đại chúng — vốn cuối năm tài chính và số đợt tăng. FK to Public Company.
- **Tên vật lý:** pblc_co_cptl_incr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Public Company Capital Increase Id | pblc_co_cptl_incr_id | BIGINT |  | X | P |  | Khóa đại diện cho bản ghi tăng vốn điều lệ sau khi thành công ty đại chúng. | IDS.company_add_capital |  | PK surrogate. |
| 2 | Public Company Capital Increase Code | pblc_co_cptl_incr_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.company_add_capital | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.company_add_capital' | Mã nguồn dữ liệu. | IDS.company_add_capital |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Public Company Id | pblc_co_id | BIGINT |  |  | F |  | FK đến công ty đại chúng. | IDS.company_add_capital | company_profile_id |  |
| 5 | Public Company Code | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. | IDS.company_add_capital | company_profile_id |  |
| 6 | Report Year | rpt_yr | INT | X |  |  |  | Năm điều chỉnh vốn góp. | IDS.company_add_capital | report_year |  |
| 7 | Paid In Capital End Of Fiscal Year Amount | paid_in_cptl_end_of_fyr_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ thực góp tính đến thời điểm kết thúc năm tài chính. | IDS.company_add_capital | paid_in_capital_eofy |  |
| 8 | Capital Increase Amount | cptl_incr_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ tăng thêm so với năm trước. | IDS.company_add_capital | capital_increase_am |  |
| 9 | Capital Increase Count | cptl_incr_cnt | INT | X |  |  |  | Số đợt tăng vốn trong năm. | IDS.company_add_capital | capital_increase_count |  |
| 10 | Licensing Authority Name | licensing_ahr_nm | STRING | X |  |  |  | Đơn vị cấp phép (tiếng Việt). | IDS.company_add_capital | licensing_authority_vi |  |
| 11 | Licensing Authority English Name | licensing_ahr_english_nm | STRING | X |  |  |  | Đơn vị cấp phép (tiếng Anh). | IDS.company_add_capital | licensing_authority_en |  |
| 12 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.company_add_capital | created_by |  |
| 13 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.company_add_capital | created_date |  |
| 14 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.company_add_capital | last_updated_by |  |
| 15 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.company_add_capital | last_updated_date |  |


#### 2.{IDX}.39.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Public Company Capital Increase Id | pblc_co_cptl_incr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Public Company Id | pblc_co_id | Public Company | Public Company Id | pblc_co_id |




### 2.{IDX}.40 Bảng Public Company Securities Offering

- **Mô tả:** Hoạt động chào bán/phát hành chứng khoán — loại CK/kế hoạch/kết quả thực tế theo từng hình thức. FK to Public Company.
- **Tên vật lý:** pblc_co_scr_ofrg
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Public Company Securities Offering Id | pblc_co_scr_ofrg_id | BIGINT |  | X | P |  | Khóa đại diện cho đợt phát hành chứng khoán. | IDS.company_securities_issuance |  | PK surrogate. |
| 2 | Public Company Securities Offering Code | pblc_co_scr_ofrg_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.company_securities_issuance | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.company_securities_issuance' | Mã nguồn dữ liệu. | IDS.company_securities_issuance |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Public Company Id | pblc_co_id | BIGINT |  |  | F |  | FK đến công ty đại chúng. | IDS.company_securities_issuance | company_profile_id |  |
| 5 | Public Company Code | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. | IDS.company_securities_issuance | company_profile_id |  |
| 6 | Security Type Code | scr_tp_code | STRING | X |  |  |  | Loại chứng khoán phát hành. | IDS.company_securities_issuance | security_type_cd | Scheme: IDS_ISSUANCE_SECURITY_TYPE. |
| 7 | Certificate Number | ctf_nbr | STRING | X |  |  |  | Số giấy chứng nhận chào bán. | IDS.company_securities_issuance | certificate_no |  |
| 8 | Certificate Issue Date | ctf_issu_dt | DATE | X |  |  |  | Ngày cấp giấy chứng nhận. | IDS.company_securities_issuance | certificate_issue_date |  |
| 9 | SSC Official Document Number | ssc_offc_doc_nbr | STRING | X |  |  |  | Số công văn của UBCKNN. | IDS.company_securities_issuance | ssc_official_doc_no |  |
| 10 | SSC Official Document Date | ssc_offc_doc_dt | DATE | X |  |  |  | Ngày công văn của UBCKNN. | IDS.company_securities_issuance | ssc_official_doc_date |  |
| 11 | Multi Offering Flag | multi_ofrg_f | BOOLEAN | X |  |  |  | Có chào bán nhiều đợt (1=có / 0=không). | IDS.company_securities_issuance | multi_offering_flg |  |
| 12 | Planned Security Quantity | pln_scr_qty | INT | X |  |  |  | Tổng số chứng khoán dự kiến chào bán/phát hành. | IDS.company_securities_issuance | planned_security_qty |  |
| 13 | Planned Proceeds Amount | pln_procd_amt | DECIMAL(18,2) | X |  |  |  | Tổng số tiền dự kiến thu được (VNĐ). | IDS.company_securities_issuance | planned_proceeds_am |  |
| 14 | Project Investment Flag | prj_ivsm_f | BOOLEAN | X |  |  |  | Có đầu tư dự án (1=có / 0=không). | IDS.company_securities_issuance | project_investment_flg |  |
| 15 | Proceeds Usage Plan | procd_usg_pln | STRING | X |  |  |  | Phương án sử dụng vốn thu được. | IDS.company_securities_issuance | proceeds_usage_plan |  |
| 16 | Planned Existing Shareholder Offering Quantity | pln_exst_shrhlr_ofrg_qty | INT | X |  |  |  | Chào bán cho cổ đông hiện hữu — số lượng dự kiến. | IDS.company_securities_issuance | plan_shareholder_qty |  |
| 17 | Planned Existing Shareholder Offering Price | pln_exst_shrhlr_ofrg_prc | DECIMAL(18,2) | X |  |  |  | Chào bán cho cổ đông hiện hữu — giá dự kiến. | IDS.company_securities_issuance | plan_shareholder_price |  |
| 18 | Result Existing Shareholder Offering Quantity | rslt_exst_shrhlr_ofrg_qty | INT | X |  |  |  | Chào bán cho cổ đông hiện hữu — số lượng thực tế. | IDS.company_securities_issuance | result_shareholder_qty |  |
| 19 | Result Existing Shareholder Offering Price | rslt_exst_shrhlr_ofrg_prc | DECIMAL(18,2) | X |  |  |  | Chào bán cho cổ đông hiện hữu — giá thực tế. | IDS.company_securities_issuance | result_shareholder_price |  |
| 20 | Planned Auction Offering Quantity | pln_auctn_ofrg_qty | INT | X |  |  |  | Đấu giá — số lượng dự kiến. | IDS.company_securities_issuance | plan_auction_qty |  |
| 21 | Planned Auction Offering Price | pln_auctn_ofrg_prc | DECIMAL(18,2) | X |  |  |  | Đấu giá — giá dự kiến. | IDS.company_securities_issuance | plan_auction_price |  |
| 22 | Result Auction Offering Quantity | rslt_auctn_ofrg_qty | INT | X |  |  |  | Đấu giá — số lượng thực tế. | IDS.company_securities_issuance | result_auction_qty |  |
| 23 | Result Auction Offering Price | rslt_auctn_ofrg_prc | DECIMAL(18,2) | X |  |  |  | Đấu giá — giá thực tế. | IDS.company_securities_issuance | result_auction_price |  |
| 24 | Planned Public Other Offering Quantity | pln_pblc_othr_ofrg_qty | INT | X |  |  |  | Chào bán ra công chúng theo hình thức khác — số lượng dự kiến. | IDS.company_securities_issuance | plan_public_qty |  |
| 25 | Planned Public Other Offering Price | pln_pblc_othr_ofrg_prc | DECIMAL(18,2) | X |  |  |  | Chào bán ra công chúng theo hình thức khác — giá dự kiến. | IDS.company_securities_issuance | plan_public_price |  |
| 26 | Result Public Other Offering Quantity | rslt_pblc_othr_ofrg_qty | INT | X |  |  |  | Chào bán ra công chúng theo hình thức khác — số lượng thực tế. | IDS.company_securities_issuance | result_public_qty |  |
| 27 | Result Public Other Offering Price | rslt_pblc_othr_ofrg_prc | DECIMAL(18,2) | X |  |  |  | Chào bán ra công chúng theo hình thức khác — giá thực tế. | IDS.company_securities_issuance | result_public_price |  |
| 28 | Planned Public Company Offering Quantity | pln_pblc_co_ofrg_qty | INT | X |  |  |  | Chào bán của công ty đại chúng ra công chúng — số lượng dự kiến. | IDS.company_securities_issuance | plan_public_company_qty |  |
| 29 | Planned Public Company Offering Price | pln_pblc_co_ofrg_prc | DECIMAL(18,2) | X |  |  |  | Chào bán của công ty đại chúng ra công chúng — giá dự kiến. | IDS.company_securities_issuance | plan_public_company_price |  |
| 30 | Result Public Company Offering Quantity | rslt_pblc_co_ofrg_qty | INT | X |  |  |  | Chào bán của công ty đại chúng ra công chúng — số lượng thực tế. | IDS.company_securities_issuance | result_public_company_qty |  |
| 31 | Result Public Company Offering Price | rslt_pblc_co_ofrg_prc | DECIMAL(18,2) | X |  |  |  | Chào bán của công ty đại chúng ra công chúng — giá thực tế. | IDS.company_securities_issuance | result_public_company_price |  |
| 32 | Planned Private Placement Offering Quantity | pln_prvt_plcmt_ofrg_qty | INT | X |  |  |  | Chào bán cổ phiếu riêng lẻ — số lượng dự kiến. | IDS.company_securities_issuance | plan_single_qty |  |
| 33 | Planned Private Placement Offering Price | pln_prvt_plcmt_ofrg_prc | DECIMAL(18,2) | X |  |  |  | Chào bán cổ phiếu riêng lẻ — giá dự kiến. | IDS.company_securities_issuance | plan_single_price |  |
| 34 | Planned Private Placement Offering Target | pln_prvt_plcmt_ofrg_trgt | STRING | X |  |  |  | Chào bán cổ phiếu riêng lẻ — đối tượng dự kiến. | IDS.company_securities_issuance | plan_single_obj |  |
| 35 | Result Private Placement Offering Quantity | rslt_prvt_plcmt_ofrg_qty | INT | X |  |  |  | Chào bán cổ phiếu riêng lẻ — số lượng thực tế. | IDS.company_securities_issuance | result_single_qty |  |
| 36 | Result Private Placement Offering Price | rslt_prvt_plcmt_ofrg_prc | DECIMAL(18,2) | X |  |  |  | Chào bán cổ phiếu riêng lẻ — giá thực tế. | IDS.company_securities_issuance | result_single_price |  |
| 37 | Result Private Placement Offering Target | rslt_prvt_plcmt_ofrg_trgt | STRING | X |  |  |  | Chào bán cổ phiếu riêng lẻ — đối tượng thực tế. | IDS.company_securities_issuance | result_single_obj |  |
| 38 | Planned Conversion Offering Quantity | pln_cnvr_ofrg_qty | INT | X |  |  |  | Hoán đổi — số lượng dự kiến. | IDS.company_securities_issuance | plan_convert_qty |  |
| 39 | Planned Conversion Offering Target | pln_cnvr_ofrg_trgt | STRING | X |  |  |  | Hoán đổi — đối tượng dự kiến. | IDS.company_securities_issuance | plan_convert_obj |  |
| 40 | Result Conversion Offering Quantity | rslt_cnvr_ofrg_qty | INT | X |  |  |  | Hoán đổi — số lượng thực tế. | IDS.company_securities_issuance | result_convert_qty |  |
| 41 | Result Conversion Offering Target | rslt_cnvr_ofrg_trgt | STRING | X |  |  |  | Hoán đổi — đối tượng thực tế. | IDS.company_securities_issuance | result_convert_obj |  |
| 42 | Planned Dividend Issuance Quantity | pln_dvdn_issn_qty | INT | X |  |  |  | Phát hành trả cổ tức — số lượng dự kiến. | IDS.company_securities_issuance | plan_dividend_qty |  |
| 43 | Result Dividend Issuance Quantity | rslt_dvdn_issn_qty | INT | X |  |  |  | Phát hành trả cổ tức — số lượng thực tế. | IDS.company_securities_issuance | result_dividend_qty |  |
| 44 | Planned Owner Capital Issuance Quantity | pln_own_cptl_issn_qty | INT | X |  |  |  | Phát hành cổ phiếu từ nguồn vốn chủ sở hữu — số lượng dự kiến. | IDS.company_securities_issuance | plan_owner_qty |  |
| 45 | Planned Owner Capital Issuance Source | pln_own_cptl_issn_src | STRING | X |  |  |  | Phát hành cổ phiếu từ nguồn vốn chủ sở hữu — nguồn dự kiến. | IDS.company_securities_issuance | plan_owner_source |  |
| 46 | Result Owner Capital Issuance Quantity | rslt_own_cptl_issn_qty | INT | X |  |  |  | Phát hành cổ phiếu từ nguồn vốn chủ sở hữu — số lượng thực tế. | IDS.company_securities_issuance | result_owner_qty |  |
| 47 | Result Owner Capital Issuance Source | rslt_own_cptl_issn_src | STRING | X |  |  |  | Phát hành cổ phiếu từ nguồn vốn chủ sở hữu — nguồn thực tế. | IDS.company_securities_issuance | result_owner_source |  |
| 48 | Planned ESOP Issuance Quantity | pln_esop_issn_qty | INT | X |  |  |  | Phát hành cổ phiếu cho người lao động — số lượng dự kiến. | IDS.company_securities_issuance | plan_esop_qty |  |
| 49 | Planned ESOP Issuance Price | pln_esop_issn_prc | DECIMAL(18,2) | X |  |  |  | Phát hành cổ phiếu cho người lao động — giá dự kiến. | IDS.company_securities_issuance | plan_esop_price |  |
| 50 | Planned ESOP Issuance Target | pln_esop_issn_trgt | STRING | X |  |  |  | Phát hành cổ phiếu cho người lao động — đối tượng dự kiến. | IDS.company_securities_issuance | plan_esop_no |  |
| 51 | Result ESOP Issuance Quantity | rslt_esop_issn_qty | INT | X |  |  |  | Phát hành cổ phiếu cho người lao động — số lượng thực tế. | IDS.company_securities_issuance | result_esop_qty |  |
| 52 | Result ESOP Issuance Price | rslt_esop_issn_prc | DECIMAL(18,2) | X |  |  |  | Phát hành cổ phiếu cho người lao động — giá thực tế. | IDS.company_securities_issuance | result_esop_price |  |
| 53 | Result ESOP Issuance Target | rslt_esop_issn_trgt | STRING | X |  |  |  | Phát hành cổ phiếu cho người lao động — đối tượng thực tế. | IDS.company_securities_issuance | result_esop_no |  |
| 54 | Planned Bonus Share Issuance Quantity | pln_bns_shr_issn_qty | INT | X |  |  |  | Phát hành cổ phiếu thưởng cho người lao động — số lượng dự kiến. | IDS.company_securities_issuance | plan_bonus_share_qty |  |
| 55 | Planned Bonus Share Issuance Target | pln_bns_shr_issn_trgt | STRING | X |  |  |  | Phát hành cổ phiếu thưởng cho người lao động — đối tượng dự kiến. | IDS.company_securities_issuance | plan_bonus_share_no |  |
| 56 | Planned Bonus Share Issuance Price | pln_bns_shr_issn_prc | DECIMAL(18,2) | X |  |  |  | Phát hành cổ phiếu thưởng cho người lao động — giá dự kiến. | IDS.company_securities_issuance | plan_bonus_share_price |  |
| 57 | Result Bonus Share Issuance Quantity | rslt_bns_shr_issn_qty | INT | X |  |  |  | Phát hành cổ phiếu thưởng cho người lao động — số lượng thực tế. | IDS.company_securities_issuance | result_bonus_share_qty |  |
| 58 | Result Bonus Share Issuance Target | rslt_bns_shr_issn_trgt | STRING | X |  |  |  | Phát hành cổ phiếu thưởng cho người lao động — đối tượng thực tế. | IDS.company_securities_issuance | result_bonus_share_no |  |
| 59 | Result Bonus Share Issuance Price | rslt_bns_shr_issn_prc | DECIMAL(18,2) | X |  |  |  | Phát hành cổ phiếu thưởng cho người lao động — giá thực tế. | IDS.company_securities_issuance | result_bonus_share_price |  |
| 60 | Planned International Bond Offering Quantity | pln_itnl_bond_ofrg_qty | INT | X |  |  |  | Chào bán trái phiếu giao dịch quốc tế — số lượng dự kiến. | IDS.company_securities_issuance | plan_international_bond_qty |  |
| 61 | Planned International Bond Offering Price | pln_itnl_bond_ofrg_prc | DECIMAL(18,2) | X |  |  |  | Chào bán trái phiếu giao dịch quốc tế — giá dự kiến. | IDS.company_securities_issuance | plan_international_bond_price |  |
| 62 | Result International Bond Offering Quantity | rslt_itnl_bond_ofrg_qty | INT | X |  |  |  | Chào bán trái phiếu giao dịch quốc tế — số lượng thực tế. | IDS.company_securities_issuance | result_international_bond_qty |  |
| 63 | Result International Bond Offering Price | rslt_itnl_bond_ofrg_prc | DECIMAL(18,2) | X |  |  |  | Chào bán trái phiếu giao dịch quốc tế — giá thực tế. | IDS.company_securities_issuance | result_international_bond_price |  |
| 64 | Offering End Date | ofrg_end_dt | DATE | X |  |  |  | Ngày kết thúc đợt chào bán. | IDS.company_securities_issuance | offering_end_date |  |
| 65 | Successful Security Quantity | scss_scr_qty | INT | X |  |  |  | Tổng số chứng khoán chào bán/phát hành thành công. | IDS.company_securities_issuance | successful_security_qty |  |
| 66 | Actual Proceeds Amount | act_procd_amt | DECIMAL(18,2) | X |  |  |  | Tổng số tiền thực thu từ đợt chào bán/phát hành (VNĐ). | IDS.company_securities_issuance | actual_proceeds_am |  |
| 67 | Capital Usage Plan | cptl_usg_pln | STRING | X |  |  |  | Phương án sử dụng vốn. | IDS.company_securities_issuance | capital_usage_plan |  |
| 68 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.company_securities_issuance | created_by |  |
| 69 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.company_securities_issuance | created_date |  |
| 70 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.company_securities_issuance | last_updated_by |  |
| 71 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.company_securities_issuance | last_updated_date |  |


#### 2.{IDX}.40.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Public Company Securities Offering Id | pblc_co_scr_ofrg_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Public Company Id | pblc_co_id | Public Company | Public Company Id | pblc_co_id |




### 2.{IDX}.41 Bảng Public Company Tender Offer

- **Mô tả:** Chào mua công khai — bên chào mua/số lượng dự kiến/kết quả/tỷ lệ sở hữu trước-sau. FK to Public Company.
- **Tên vật lý:** pblc_co_tender_ofr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Public Company Tender Offer Id | pblc_co_tender_ofr_id | BIGINT |  | X | P |  | Khóa đại diện cho đợt chào mua công khai. | IDS.company_tender_offer |  | PK surrogate. |
| 2 | Public Company Tender Offer Code | pblc_co_tender_ofr_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.company_tender_offer | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.company_tender_offer' | Mã nguồn dữ liệu. | IDS.company_tender_offer |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Public Company Id | pblc_co_id | BIGINT |  |  | F |  | FK đến công ty đại chúng (công ty mục tiêu). | IDS.company_tender_offer | company_profile_id |  |
| 5 | Public Company Code | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. | IDS.company_tender_offer | company_profile_id |  |
| 6 | Tender Offeror Name | tender_offeror_nm | STRING | X |  |  |  | Tên tổ chức/cá nhân chào mua công khai (tiếng Việt). | IDS.company_tender_offer | tender_offeror_name_vi |  |
| 7 | Tender Offeror English Name | tender_offeror_english_nm | STRING | X |  |  |  | Tên tổ chức/cá nhân chào mua công khai (tiếng Anh). | IDS.company_tender_offer | tender_offeror_name_en |  |
| 8 | Tender Offeror Identification Number | tender_offeror_identn_nbr | STRING | X |  |  |  | Số CMND/Hộ chiếu/GCN ĐKDN của bên chào mua. | IDS.company_tender_offer | offeror_id_no |  |
| 9 | Tender Offeror Relationship | tender_offeror_rltnp | STRING | X |  |  |  | Mối quan hệ giữa bên chào mua với công ty mục tiêu. | IDS.company_tender_offer | offeror_relationship |  |
| 10 | Securities Agent Name | scr_agnt_nm | STRING | X |  |  |  | Tên công ty chứng khoán làm đại lý (tiếng Việt). | IDS.company_tender_offer | securities_agent_name_vi |  |
| 11 | Securities Agent English Name | scr_agnt_english_nm | STRING | X |  |  |  | Tên công ty chứng khoán làm đại lý (tiếng Anh). | IDS.company_tender_offer | securities_agent_name_en |  |
| 12 | Planned Offer From Date | pln_ofr_fm_dt | DATE | X |  |  |  | Thời gian dự kiến chào mua — từ ngày. | IDS.company_tender_offer | planned_offer_from_date |  |
| 13 | Planned Offer To Date | pln_ofr_to_dt | DATE | X |  |  |  | Thời gian dự kiến chào mua — đến ngày. | IDS.company_tender_offer | planned_offer_to_date |  |
| 14 | Pre Offer Share Quantity | pre_ofr_shr_qty | INT | X |  |  |  | Số cổ phiếu sở hữu trước khi chào mua. | IDS.company_tender_offer | pre_offer_share_qty |  |
| 15 | Pre Offer Share Ratio | pre_ofr_shr_rto | DECIMAL(9,6) | X |  |  |  | Tỷ lệ cổ phiếu sở hữu trước khi chào mua. | IDS.company_tender_offer | pre_offer_share_ratio |  |
| 16 | Planned Offer Share Quantity | pln_ofr_shr_qty | INT | X |  |  |  | Số cổ phiếu dự kiến chào mua. | IDS.company_tender_offer | planned_offer_share_qty |  |
| 17 | Planned Offer Share Ratio | pln_ofr_shr_rto | DECIMAL(9,6) | X |  |  |  | Tỷ lệ cổ phiếu dự kiến chào mua. | IDS.company_tender_offer | planned_offer_share_ratio |  |
| 18 | Planned Offer Price Amount | pln_ofr_prc_amt | DECIMAL(18,2) | X |  |  |  | Giá chào mua. | IDS.company_tender_offer | planned_offer_price |  |
| 19 | Acquired Share Quantity | acq_shr_qty | INT | X |  |  |  | Số cổ phiếu mua được trong đợt chào mua. | IDS.company_tender_offer | acquired_share_qty |  |
| 20 | Acquired Share Ratio | acq_shr_rto | DECIMAL(9,6) | X |  |  |  | Tỷ lệ cổ phiếu mua được trong đợt chào mua. | IDS.company_tender_offer | acquired_share_ratio |  |
| 21 | Post Offer Share Quantity | pst_ofr_shr_qty | INT | X |  |  |  | Số cổ phiếu sở hữu sau khi chào mua. | IDS.company_tender_offer | post_offer_share_qty |  |
| 22 | Post Offer Share Ratio | pst_ofr_shr_rto | DECIMAL(9,6) | X |  |  |  | Tỷ lệ cổ phiếu sở hữu sau khi chào mua. | IDS.company_tender_offer | post_offer_share_ratio |  |
| 23 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.company_tender_offer | created_by |  |
| 24 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.company_tender_offer | created_date |  |
| 25 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.company_tender_offer | last_updated_by |  |
| 26 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.company_tender_offer | last_updated_date |  |


#### 2.{IDX}.41.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Public Company Tender Offer Id | pblc_co_tender_ofr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Public Company Id | pblc_co_id | Public Company | Public Company Id | pblc_co_id |




### 2.{IDX}.42 Bảng Public Company Treasury Stock Activity

- **Mô tả:** Giao dịch cổ phiếu quỹ theo năm — số lượng mua/bán và số đợt. FK to Public Company.
- **Tên vật lý:** pblc_co_trsr_stk_avy
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Public Company Treasury Stock Activity Id | pblc_co_trsr_stk_avy_id | BIGINT |  | X | P |  | Khóa đại diện cho hoạt động cổ phiếu quỹ theo năm. | IDS.company_treasury_stocks |  | PK surrogate. |
| 2 | Public Company Treasury Stock Activity Code | pblc_co_trsr_stk_avy_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.company_treasury_stocks | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.company_treasury_stocks' | Mã nguồn dữ liệu. | IDS.company_treasury_stocks |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Public Company Id | pblc_co_id | BIGINT |  |  | F |  | FK đến công ty đại chúng. | IDS.company_treasury_stocks | company_profile_id |  |
| 5 | Public Company Code | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. | IDS.company_treasury_stocks | company_profile_id |  |
| 6 | Transaction Year | txn_yr | INT | X |  |  |  | Năm giao dịch cổ phiếu quỹ. | IDS.company_treasury_stocks | transaction_year |  |
| 7 | Treasury Buy Quantity | trsr_buy_qty | INT | X |  |  |  | Số lượng cổ phiếu quỹ mua trong năm. | IDS.company_treasury_stocks | treasury_buy_qty |  |
| 8 | Treasury Buy Round Count | trsr_buy_rnd_cnt | INT | X |  |  |  | Số đợt mua cổ phiếu quỹ trong năm. | IDS.company_treasury_stocks | treasury_buy_rc |  |
| 9 | Treasury Sell Quantity | trsr_sell_qty | INT | X |  |  |  | Số lượng cổ phiếu quỹ bán trong năm. | IDS.company_treasury_stocks | treasury_sell_qty |  |
| 10 | Treasury Sell Round Count | trsr_sell_rnd_cnt | INT | X |  |  |  | Số đợt bán cổ phiếu quỹ trong năm. | IDS.company_treasury_stocks | treasury_sell_rc |  |
| 11 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.company_treasury_stocks | created_by |  |
| 12 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.company_treasury_stocks | created_date |  |
| 13 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.company_treasury_stocks | last_updated_by |  |
| 14 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.company_treasury_stocks | last_updated_date |  |


#### 2.{IDX}.42.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Public Company Treasury Stock Activity Id | pblc_co_trsr_stk_avy_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Public Company Id | pblc_co_id | Public Company | Public Company Id | pblc_co_id |




### 2.{IDX}.43 Bảng Public Company Inspection

- **Mô tả:** Thanh tra/kiểm tra công ty đại chúng — loại/số quyết định/đơn vị chủ trì/biên bản. FK to Public Company.
- **Tên vật lý:** pblc_co_inspection
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Public Company Inspection Id | pblc_co_inspection_id | BIGINT |  | X | P |  | Khóa đại diện cho bản ghi thanh tra/kiểm tra công ty đại chúng. | IDS.company_inspection |  | PK surrogate. |
| 2 | Public Company Inspection Code | pblc_co_inspection_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.company_inspection | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.company_inspection' | Mã nguồn dữ liệu. | IDS.company_inspection |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Public Company Id | pblc_co_id | BIGINT |  |  | F |  | FK đến công ty đại chúng. | IDS.company_inspection | company_profile_id |  |
| 5 | Public Company Code | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. | IDS.company_inspection | company_profile_id |  |
| 6 | Inspection Type Code | inspection_tp_code | STRING | X |  |  |  | Loại thanh tra/kiểm tra. | IDS.company_inspection | inspection_type_cd | Scheme: IDS_INSPECTION_TYPE. |
| 7 | Decision Number | dcsn_nbr | STRING | X |  |  |  | Số quyết định thanh tra/kiểm tra. | IDS.company_inspection | decision_no |  |
| 8 | Decision Date | dcsn_dt | DATE | X |  |  |  | Ngày quyết định. | IDS.company_inspection | decision_date |  |
| 9 | Inspection Period | inspection_prd | STRING | X |  |  |  | Thời kỳ thanh tra/kiểm tra. | IDS.company_inspection | inspection_period |  |
| 10 | Inspection Date | inspection_dt | DATE | X |  |  |  | Thời gian thanh tra/kiểm tra. | IDS.company_inspection | inspection_date |  |
| 11 | Inspection Mode Code | inspection_mode_code | STRING | X |  |  |  | Thanh tra định kỳ/bất thường. | IDS.company_inspection | inspection_mode_cd | Scheme: IDS_INSPECTION_MODE. |
| 12 | Inspection Scope | inspection_scop | STRING | X |  |  |  | Nội dung kiểm tra/thanh tra. | IDS.company_inspection | inspection_scope |  |
| 13 | Lead Inspection Unit Name | lead_inspection_unit_nm | STRING | X |  | F |  | Đơn vị chủ trì kiểm tra/thanh tra (tiếng Việt). | IDS.company_inspection | lead_inspection_unit_vi |  |
| 14 | Lead Inspection Unit English Name | lead_inspection_unit_english_nm | STRING | X |  |  |  | Đơn vị chủ trì kiểm tra/thanh tra (tiếng Anh). | IDS.company_inspection | lead_inspection_unit_en |  |
| 15 | Inspection Minutes Name | inspection_mins_nm | STRING | X |  |  |  | Tên biên bản kiểm tra/thanh tra. | IDS.company_inspection | inspection_minutes_name |  |
| 16 | Inspection File Url | inspection_file_url | STRING | X |  |  |  | Đường dẫn biên bản kiểm tra/thanh tra. | IDS.company_inspection | inspection_file_url |  |
| 17 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.company_inspection | created_by |  |
| 18 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.company_inspection | created_date |  |
| 19 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.company_inspection | last_updated_by |  |
| 20 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.company_inspection | last_updated_date |  |


#### 2.{IDX}.43.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Public Company Inspection Id | pblc_co_inspection_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Public Company Id | pblc_co_id | Public Company | Public Company Id | pblc_co_id |




### 2.{IDX}.44 Bảng Public Company Penalty

- **Mô tả:** Xử phạt hành chính công ty đại chúng hoặc nhà đầu tư liên quan — hành vi vi phạm và quyết định xử phạt. FK to Public Company.
- **Tên vật lý:** pblc_co_pny
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Public Company Penalty Id | pblc_co_pny_id | BIGINT |  | X | P |  | Khóa đại diện cho quyết định xử phạt hành chính. | IDS.company_penalize |  | PK surrogate. |
| 2 | Public Company Penalty Code | pblc_co_pny_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. | IDS.company_penalize | id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'IDS.company_penalize' | Mã nguồn dữ liệu. | IDS.company_penalize |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Public Company Id | pblc_co_id | BIGINT |  |  | F |  | FK đến công ty đại chúng. | IDS.company_penalize | company_profile_id |  |
| 5 | Public Company Code | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. | IDS.company_penalize | company_profile_id |  |
| 6 | Penalized Subject Type Code | penalized_sbj_tp_code | STRING | X |  |  |  | Đối tượng bị xử phạt (công ty đại chúng / nhà đầu tư liên quan). | IDS.company_penalize | penalized_subjet_type_cd | Scheme: IDS_PENALIZED_SUBJECT_TYPE. |
| 7 | Investor Name | ivsr_nm | STRING | X |  |  |  | Tên nhà đầu tư bị xử phạt (null khi đối tượng là công ty). | IDS.company_penalize | investor_name |  |
| 8 | Investor Identification Number | ivsr_identn_nbr | STRING | X |  |  |  | Số CCCD/Hộ chiếu của nhà đầu tư. | IDS.company_penalize | investor_id_no |  |
| 9 | Investor Position Title | ivsr_pos_ttl | STRING | X |  |  |  | Chức vụ của nhà đầu tư. | IDS.company_penalize | investor_position_title |  |
| 10 | Penalty Decision Number | pny_dcsn_nbr | STRING | X |  |  |  | Số quyết định xử phạt. | IDS.company_penalize | penalty_decision_no |  |
| 11 | Penalty Decision Date | pny_dcsn_dt | DATE | X |  |  |  | Ngày quyết định xử phạt. | IDS.company_penalize | penalty_decision_date |  |
| 12 | Violation Description | vln_dsc | STRING | X |  |  |  | Mô tả hành vi vi phạm. | IDS.company_penalize | violation_desc |  |
| 13 | Penalty Form | pny_form | STRING | X |  |  |  | Hình thức phạt chính. | IDS.company_penalize | penalty_form |  |
| 14 | Penalty Amount | pny_amt | DECIMAL(18,2) | X |  |  |  | Số tiền phạt. | IDS.company_penalize | penalty_amount |  |
| 15 | Additional Penalty | adl_pny | STRING | X |  |  |  | Hình thức phạt bổ sung. | IDS.company_penalize | additional_penalty |  |
| 16 | Remedial Minutes | remedial_mins | STRING | X |  |  |  | Biên bản khắc phục hậu quả. | IDS.company_penalize | remedial_minutes |  |
| 17 | Created By Login Name | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). | IDS.company_penalize | created_by |  |
| 18 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. | IDS.company_penalize | created_date |  |
| 19 | Last Updated By Login Name | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). | IDS.company_penalize | last_updated_by |  |
| 20 | Last Updated Timestamp | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. | IDS.company_penalize | last_updated_date |  |


#### 2.{IDX}.44.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Public Company Penalty Id | pblc_co_pny_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Public Company Id | pblc_co_id | Public Company | Public Company Id | pblc_co_id |




