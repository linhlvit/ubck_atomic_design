## 2.{IDX} FMS — Thiết kế CSDL FMS — Phân hệ quản lý giám sát công ty chứng khoán và quỹ đầu tư chứng khoán

### 2.{IDX}.1 Các mô hình quan hệ dữ liệu

- DBML tổng hợp (tất cả bảng): [`FMS.dbml`](FMS.dbml) — paste vào https://dbdiagram.io để render.
- Diagram theo mảng nghiệp vụ:
  - **UID03 — Thông tin thành viên — Công ty QLQ**: [`FMS_UID03.dbml`](FMS_UID03.dbml)
  - **UID04 — Quỹ đầu tư chứng khoán**: [`FMS_UID04.dbml`](FMS_UID04.dbml)
  - **UID05 — Quản lý báo cáo**: [`FMS_UID05.dbml`](FMS_UID05.dbml)
  - **UID06 — Đánh giá xếp loại và cảnh báo**: [`FMS_UID06.dbml`](FMS_UID06.dbml)
  - **UID07 — Tiện ích và hệ thống**: [`FMS_UID07.dbml`](FMS_UID07.dbml)


**Danh sách bảng:**

| STT | Thực thể | Tên bảng | Mô tả |
|---|---|---|---|
| 1 | Fund Management Company | fnd_mgt_co | Công ty quản lý quỹ đầu tư chứng khoán trong nước được UBCKNN cấp phép hoạt động. Lưu thông tin pháp lý và hoạt động của công ty. |
| 2 | Involved Party Postal Address | ip_pst_adr | Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn. |
| 3 | Involved Party Electronic Address | ip_elc_adr | Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn. |
| 4 | Involved Party Alternative Identification | ip_alt_identn | Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn. |
| 5 | Foreign Fund Management Organization Unit | frgn_fnd_mgt_ou | Văn phòng đại diện hoặc chi nhánh của công ty quản lý quỹ nước ngoài tại Việt Nam được UBCKNN chấp thuận hoạt động. |
| 6 | Custodian Bank | cstd_bnk | Ngân hàng lưu ký giám sát tài sản quỹ đầu tư chứng khoán được UBCKNN chấp thuận. Chịu trách nhiệm lưu giữ và giám sát tài sản của quỹ. |
| 7 | Fund Distribution Agent | fnd_dstr_agnt | Tổ chức đại lý được ủy quyền phân phối chứng chỉ quỹ đầu tư cho nhà đầu tư. |
| 8 | Discretionary Investment Investor | dscr_ivsm_ivsr | Nhà đầu tư ủy thác — cá nhân hoặc tổ chức giao tài sản cho công ty quản lý quỹ quản lý theo hợp đồng ủy thác đầu tư. |
| 9 | Reporting Period | rpt_prd | Kỳ báo cáo định kỳ (ngày/tuần/tháng/quý/bán niên/năm) mà thành viên thị trường phải nộp báo cáo lên UBCKNN. |
| 10 | Member Rating Period | mbr_rtg_prd | Kỳ đánh giá xếp loại định kỳ cho các thành viên thị trường (công ty quản lý quỹ). Xác định phạm vi thời gian áp dụng tiêu chí chấm điểm. |
| 11 | Investment Fund | ivsm_fnd | Quỹ đầu tư chứng khoán — pháp nhân độc lập do công ty quản lý quỹ thành lập và quản lý. Lưu thông tin pháp lý và vốn của quỹ. |
| 12 | Fund Management Company Key Person | fnd_mgt_co_key_psn | Nhân sự chủ chốt của công ty quản lý quỹ (giám đốc/chuyên gia đầu tư/người được ủy quyền). Lưu thông tin cá nhân và chứng chỉ hành nghề. |
| 13 | Fund Management Company Organization Unit | fnd_mgt_co_ou | Chi nhánh hoặc văn phòng đại diện của công ty quản lý quỹ trong nước. Có địa chỉ và giấy phép hoạt động riêng. |
| 14 | Fund Distribution Agent Organization Unit | fnd_dstr_agnt_ou | Chi nhánh hoặc phòng giao dịch của tổ chức đại lý phân phối quỹ đầu tư. |
| 15 | Discretionary Investment Account | dscr_ivsm_ac | Tài khoản đầu tư ủy thác — hợp đồng dịch vụ quản lý danh mục tài chính giữa nhà đầu tư ủy thác và công ty quản lý quỹ. |
| 16 | Member Rating | mbr_rtg | Kết quả xếp loại của một công ty quản lý quỹ trong một kỳ đánh giá. Ghi nhận điểm tổng hợp và hạng xếp loại. |
| 17 | Rating Criterion | rtg_criterion | Tiêu chí chấm điểm đánh giá xếp loại thành viên thị trường. Lưu tên tiêu chí và điểm tối đa/trọng số. Có cấu trúc cha/con. |
| 18 | Investment Fund Investor Membership | ivsm_fnd_ivsr_mbr | Quan hệ thành viên của nhà đầu tư trong một quỹ đầu tư. Lưu tỷ lệ vốn góp và trạng thái tham gia. |
| 19 | Investment Fund Representative Board Member | ivsm_fnd_representative_board_mbr | Thành viên ban đại diện hoặc hội đồng quản trị của quỹ đầu tư. Cá nhân đảm nhận vai trò quản trị trong cơ cấu tổ chức quỹ. |
| 20 | Foreign Fund Management Organization Unit Staff | frgn_fnd_mgt_ou_stff | Nhân sự đảm nhận chức vụ tại văn phòng đại diện/chi nhánh công ty quản lý quỹ nước ngoài. Ghi nhận vai trò và tư cách pháp lý. |
| 21 | Member Periodic Report | mbr_prd_rpt | Báo cáo định kỳ do thành viên thị trường nộp lên UBCKNN theo từng kỳ báo cáo. Ghi nhận trạng thái nộp và thời hạn. |
| 22 | Fund Management Company Share Transfer | fnd_mgt_co_shr_tfr | Giao dịch chuyển nhượng cổ phần của công ty quản lý quỹ. Ghi nhận bên chuyển nhượng/nhận nhượng và giá trị giao dịch. |
| 23 | Fund Management Conduct Violation | fnd_mgt_conduct_vln | Vi phạm pháp luật hoặc hành chính của công ty quản lý quỹ hoặc quỹ đầu tư. Ghi nhận loại vi phạm và trạng thái xử lý. |
| 24 | Investment Fund Certificate Transfer | ivsm_fnd_ctf_tfr | Giao dịch mua/bán chứng chỉ quỹ của nhà đầu tư thành viên. Ghi nhận số lượng và giá giao dịch theo từng quỹ. |
| 25 | Investment Fund Investor Capital Change Log | ivsm_fnd_ivsr_cptl_chg_log | Lịch sử thay đổi phần vốn góp của nhà đầu tư trong quỹ đầu tư. Ghi nhận vốn trước/sau và lý do thay đổi. |
| 26 | Member Periodic Report Status Log | mbr_prd_rpt_st_log | Nhật ký thay đổi trạng thái của báo cáo định kỳ thành viên. Mỗi dòng ghi nhận một lần thay đổi trạng thái kèm nội dung tóm tắt. |
| 27 | Report Import Value | rpt_impr_val | Dữ liệu giá trị từng ô chỉ tiêu trong sheet báo cáo được import vào hệ thống FMS. Grain ở mức cell-level. |



### 2.{IDX}.2 Bảng Fund Management Company

- **Mô tả:** Công ty quản lý quỹ đầu tư chứng khoán trong nước được UBCKNN cấp phép hoạt động. Lưu thông tin pháp lý và hoạt động của công ty.
- **Tên vật lý:** fnd_mgt_co
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Fund Management Company Id | fnd_mgt_co_id | BIGINT |  | X | P |  | Khóa đại diện cho công ty quản lý quỹ trong nước. | FMS.SECURITIES |  | PK surrogate. |
| 2 | Fund Management Company Code | fnd_mgt_co_code | STRING |  |  |  |  | Mã định danh công ty QLQ. Map từ PK bảng nguồn. | FMS.SECURITIES | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.SECURITIES' | Mã nguồn dữ liệu. | FMS.SECURITIES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Fund Management Company Name | fnd_mgt_co_nm | STRING |  |  |  |  | Tên đầy đủ công ty QLQ trong nước. | FMS.SECURITIES | Name |  |
| 5 | Fund Management Company Short Name | fnd_mgt_co_shrt_nm | STRING | X |  |  |  | Tên viết tắt công ty QLQ. | FMS.SECURITIES | ShortName |  |
| 6 | Fund Management Company English Name | fnd_mgt_co_english_nm | STRING | X |  |  |  | Tên tiếng Anh công ty QLQ. | FMS.SECURITIES | EnName |  |
| 7 | Practice Status Code | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động của công ty QLQ. | FMS.SECURITIES | Status | Scheme: FMS_OPERATION_STATUS. |
| 8 | Charter Capital Amount | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ công ty QLQ (VNĐ). | FMS.SECURITIES | SecCapital |  |
| 9 | Dorf Indicator | dorf_ind | STRING | X |  |  |  | Loại hình trong/ngoài nước. 1=Trong nước; 0=Nước ngoài. | FMS.SECURITIES | Dorf |  |
| 10 | License Decision Number | license_dcsn_nbr | STRING | X |  |  |  | Số quyết định/giấy phép thành lập. | FMS.SECURITIES | Decision |  |
| 11 | License Decision Date | license_dcsn_dt | DATE | X |  |  |  | Ngày cấp phép. | FMS.SECURITIES | DecisionDate |  |
| 12 | Active Date | actv_dt | DATE | X |  |  |  | Ngày bắt đầu hoạt động. | FMS.SECURITIES | ActiveDate |  |
| 13 | Stop Date | stop_dt | DATE | X |  |  |  | Ngày ngừng hoạt động. | FMS.SECURITIES | StopDate |  |
| 14 | Business Type Codes | bsn_tp_codes | Array<Text> | X |  |  |  | Danh sách mã ngành nghề kinh doanh. | FMS.SECURITIES | BuId |  |
| 15 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FMS.SECURITIES | CreatedBy |  |
| 16 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.SECURITIES | DateCreated |  |
| 17 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.SECURITIES | DateModified |  |
| 18 | Country of Registration Id | cty_of_rgst_id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký của công ty QLQ. | FMS.SECURITIES |  |  |
| 19 | Country of Registration Code | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. | FMS.SECURITIES |  |  |
| 20 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. | FMS.SECURITIES |  | Scheme: LIFE_CYCLE_STATUS. |
| 21 | Director Name | director_nm | STRING | X |  |  |  | Tên Tổng giám đốc (denormalized). | FMS.SECURITIES |  |  |
| 22 | Depository Certificate Number | depst_ctf_nbr | STRING | X |  |  |  | Chứng nhận lưu ký — thông tin bổ sung của FIMS không có trong FMS.SECURITIES. | FMS.SECURITIES |  |  |
| 23 | Company Type Codes | co_tp_codes | Array<Text> | X |  |  |  | Danh sách mã loại hình doanh nghiệp. Từ bảng junction FUNDCOMTYPE. | FMS.SECURITIES |  |  |
| 24 | Description | dsc | STRING | X |  |  |  | Ghi chú. | FMS.SECURITIES |  |  |
| 25 | Company Type Code | co_tp_code | STRING | X |  |  |  | Loại hình công ty. | FMS.SECURITIES |  | Scheme: TT_COMPANY_TYPE. |
| 26 | Fund Type Code | fnd_tp_code | STRING | X |  |  |  | Loại quỹ (áp dụng cho quỹ đầu tư). | FMS.SECURITIES |  | Scheme: TT_FUND_TYPE. |
| 27 | Business License Number | bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. | FMS.SECURITIES |  |  |
| 28 | Website | webst | STRING | X |  |  |  | Website chính thức. | FMS.SECURITIES |  |  |


#### 2.{IDX}.2.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Fund Management Company Id | fnd_mgt_co_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Country of Registration Id | cty_of_rgst_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.3 Bảng Involved Party Postal Address — FMS.SECURITIES

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. | FMS.SECURITIES | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty QLQ. | FMS.SECURITIES | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.SECURITIES' | Mã nguồn dữ liệu. | FMS.SECURITIES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ. | FMS.SECURITIES |  | Scheme: IP_ADDR_TYPE. |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở chính công ty QLQ. | FMS.SECURITIES | Address |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | FMS.SECURITIES |  |  |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). | FMS.SECURITIES |  |  |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. | FMS.SECURITIES |  |  |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. | FMS.SECURITIES |  |  |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | FMS.SECURITIES |  |  |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | FMS.SECURITIES |  |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | FMS.SECURITIES |  |  |


#### 2.{IDX}.3.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Fund Management Company | Fund Management Company Id | fnd_mgt_co_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.4 Bảng Involved Party Electronic Address — FMS.SECURITIES

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. | FMS.SECURITIES | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty QLQ. | FMS.SECURITIES | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.SECURITIES' | Mã nguồn dữ liệu. | FMS.SECURITIES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại liên lạc — email. | FMS.SECURITIES |  | Scheme: IP_ELEC_ADDR_TYPE. |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Địa chỉ email. | FMS.SECURITIES | Email |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. | FMS.SECURITIES | Id |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty QLQ. | FMS.SECURITIES | Id |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.SECURITIES' | Mã nguồn dữ liệu. | FMS.SECURITIES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại liên lạc — fax. | FMS.SECURITIES |  | Scheme: IP_ELEC_ADDR_TYPE. |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số fax trụ sở chính. | FMS.SECURITIES | Fax |  |
| 11 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. | FMS.SECURITIES | Id |  |
| 12 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty QLQ. | FMS.SECURITIES | Id |  |
| 13 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.SECURITIES' | Mã nguồn dữ liệu. | FMS.SECURITIES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 14 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại liên lạc — điện thoại. | FMS.SECURITIES |  | Scheme: IP_ELEC_ADDR_TYPE. |
| 15 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại trụ sở chính. | FMS.SECURITIES | Telephone |  |
| 16 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. | FMS.SECURITIES | Id |  |
| 17 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty QLQ. | FMS.SECURITIES | Id |  |
| 18 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.SECURITIES' | Mã nguồn dữ liệu. | FMS.SECURITIES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 19 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại liên lạc — website. | FMS.SECURITIES |  | Scheme: IP_ELEC_ADDR_TYPE. |
| 20 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Địa chỉ website. | FMS.SECURITIES | Website |  |


#### 2.{IDX}.4.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Fund Management Company | Fund Management Company Id | fnd_mgt_co_id |




### 2.{IDX}.5 Bảng Involved Party Alternative Identification — FMS.SECURITIES

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company. | FMS.SECURITIES | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã công ty QLQ. | FMS.SECURITIES | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.SECURITIES' | Mã nguồn dữ liệu. | FMS.SECURITIES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ — giấy phép thành lập. | FMS.SECURITIES |  | Scheme: IP_ALT_ID_TYPE. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số quyết định/giấy phép thành lập. | FMS.SECURITIES | Decision |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp phép thành lập. | FMS.SECURITIES | DecisionDate |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Cơ quan cấp giấy phép thành lập | FMS.SECURITIES |  |  |


#### 2.{IDX}.5.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Fund Management Company | Fund Management Company Id | fnd_mgt_co_id |




### 2.{IDX}.6 Bảng Foreign Fund Management Organization Unit

- **Mô tả:** Văn phòng đại diện hoặc chi nhánh của công ty quản lý quỹ nước ngoài tại Việt Nam được UBCKNN chấp thuận hoạt động.
- **Tên vật lý:** frgn_fnd_mgt_ou
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Foreign Fund Management Organization Unit Id | frgn_fnd_mgt_ou_id | BIGINT |  | X | P |  | Khóa đại diện cho VPĐD/CN công ty QLQ nước ngoài tại VN. | FMS.FORBRCH |  | PK surrogate. |
| 2 | Foreign Fund Management Organization Unit Code | frgn_fnd_mgt_ou_code | STRING |  |  |  |  | Mã định danh VPĐD/CN QLQ NN. Map từ PK bảng nguồn. | FMS.FORBRCH | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.FORBRCH' | Mã nguồn dữ liệu. | FMS.FORBRCH |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Foreign Fund Management Organization Unit Name | frgn_fnd_mgt_ou_nm | STRING |  |  |  |  | Tên VPĐD/CN công ty QLQ nước ngoài tại VN. | FMS.FORBRCH | Name |  |
| 5 | Foreign Fund Management Organization Unit English Name | frgn_fnd_mgt_ou_english_nm | STRING | X |  |  |  | Tên tiếng Anh VPĐD/CN. | FMS.FORBRCH | EnName |  |
| 6 | Practice Status Code | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động. | FMS.FORBRCH | Status | Scheme: FMS_OPERATION_STATUS. |
| 7 | End Date | end_dt | DATE | X |  |  |  | Ngày chấm dứt hoạt động. | FMS.FORBRCH | EndDate |  |
| 8 | Change License Number | chg_license_nbr | STRING | X |  |  |  | Số giấy phép điều chỉnh gần nhất. | FMS.FORBRCH | ChangeLicense |  |
| 9 | Change License Date | chg_license_dt | DATE | X |  |  |  | Ngày cấp giấy phép điều chỉnh. | FMS.FORBRCH | ChangeLicenseDate |  |
| 10 | Change Note | chg_note | STRING | X |  |  |  | Nội dung thay đổi theo giấy phép điều chỉnh. | FMS.FORBRCH | ChangeNote |  |
| 11 | Business Type Codes | bsn_tp_codes | Array<Text> | X |  |  |  | Danh sách mã ngành nghề kinh doanh. | FMS.FORBRCH | BuId |  |
| 12 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FMS.FORBRCH | CreatedBy |  |
| 13 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.FORBRCH | DateCreated |  |
| 14 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.FORBRCH | DateModified |  |


#### 2.{IDX}.6.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Foreign Fund Management Organization Unit Id | frgn_fnd_mgt_ou_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.7 Bảng Involved Party Postal Address — FMS.FORBRCH

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Foreign Fund Management Organization Unit. | FMS.FORBRCH | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã VPĐD/CN QLQ NN. | FMS.FORBRCH | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.FORBRCH' | Mã nguồn dữ liệu. | FMS.FORBRCH |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ. | FMS.FORBRCH |  | Scheme: IP_ADDR_TYPE. |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ VPĐD/CN tại VN. | FMS.FORBRCH | Address |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | FMS.FORBRCH |  |  |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). | FMS.FORBRCH |  |  |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. | FMS.FORBRCH |  |  |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. | FMS.FORBRCH |  |  |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | FMS.FORBRCH |  |  |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | FMS.FORBRCH |  |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | FMS.FORBRCH |  |  |


#### 2.{IDX}.7.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Foreign Fund Management Organization Unit | Foreign Fund Management Organization Unit Id | frgn_fnd_mgt_ou_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.8 Bảng Involved Party Electronic Address — FMS.FORBRCH

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Foreign Fund Management Organization Unit. | FMS.FORBRCH | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã VPĐD/CN QLQ NN. | FMS.FORBRCH | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.FORBRCH' | Mã nguồn dữ liệu. | FMS.FORBRCH |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại liên lạc — email. | FMS.FORBRCH |  | Scheme: IP_ELEC_ADDR_TYPE. |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Địa chỉ email. | FMS.FORBRCH | Email |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Foreign Fund Management Organization Unit. | FMS.FORBRCH | Id |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã VPĐD/CN QLQ NN. | FMS.FORBRCH | Id |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.FORBRCH' | Mã nguồn dữ liệu. | FMS.FORBRCH |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại liên lạc — fax. | FMS.FORBRCH |  | Scheme: IP_ELEC_ADDR_TYPE. |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số fax. | FMS.FORBRCH | Fax |  |


#### 2.{IDX}.8.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Foreign Fund Management Organization Unit | Foreign Fund Management Organization Unit Id | frgn_fnd_mgt_ou_id |




### 2.{IDX}.9 Bảng Involved Party Alternative Identification — FMS.FORBRCH

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Foreign Fund Management Organization Unit. | FMS.FORBRCH | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã VPĐD/CN QLQ NN. | FMS.FORBRCH | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.FORBRCH' | Mã nguồn dữ liệu. | FMS.FORBRCH |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ — giấy phép điều chỉnh. | FMS.FORBRCH |  | Scheme: IP_ALT_ID_TYPE. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số giấy phép điều chỉnh gần nhất. | FMS.FORBRCH | ChangeLicense |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép điều chỉnh. | FMS.FORBRCH | ChangeLicenseDate |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Cơ quan cấp giấy phép thành lập | FMS.FORBRCH |  |  |


#### 2.{IDX}.9.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Foreign Fund Management Organization Unit | Foreign Fund Management Organization Unit Id | frgn_fnd_mgt_ou_id |




### 2.{IDX}.10 Bảng Custodian Bank

- **Mô tả:** Ngân hàng lưu ký giám sát tài sản quỹ đầu tư chứng khoán được UBCKNN chấp thuận. Chịu trách nhiệm lưu giữ và giám sát tài sản của quỹ.
- **Tên vật lý:** cstd_bnk
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Custodian Bank Id | cstd_bnk_id | BIGINT |  | X | P |  | Khóa đại diện cho ngân hàng lưu ký giám sát. | FMS.BANKMONI |  | PK surrogate. |
| 2 | Custodian Bank Code | cstd_bnk_code | STRING |  |  |  |  | Mã định danh ngân hàng LKGS. Map từ PK bảng nguồn. | FMS.BANKMONI | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.BANKMONI' | Mã nguồn dữ liệu. | FMS.BANKMONI |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Custodian Bank Name | cstd_bnk_nm | STRING |  |  |  |  | Tên đầy đủ ngân hàng lưu ký giám sát. | FMS.BANKMONI | Name |  |
| 5 | Custodian Bank Short Name | cstd_bnk_shrt_nm | STRING | X |  |  |  | Tên viết tắt ngân hàng LKGS. | FMS.BANKMONI | ShortName |  |
| 6 | Practice Status Code | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động. | FMS.BANKMONI | Status | Scheme: FMS_OPERATION_STATUS. |
| 7 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FMS.BANKMONI | CreatedBy |  |
| 8 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.BANKMONI | DateCreated |  |
| 9 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.BANKMONI | DateModified |  |
| 10 | Country of Registration Id | cty_of_rgst_id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký của ngân hàng LKGS. | FMS.BANKMONI |  |  |
| 11 | Country of Registration Code | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. | FMS.BANKMONI |  |  |
| 12 | Custodian Bank English Name | cstd_bnk_english_nm | STRING | X |  |  |  | Tên tiếng Anh. | FMS.BANKMONI |  |  |
| 13 | Charter Capital Amount | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ (VNĐ). Thông tin bổ sung của FIMS không có trong FMS.BANKMONI. | FMS.BANKMONI |  |  |
| 14 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. | FMS.BANKMONI |  | Scheme: LIFE_CYCLE_STATUS. |
| 15 | Director Name | director_nm | STRING | X |  |  |  | Tên Tổng giám đốc (denormalized). | FMS.BANKMONI |  |  |
| 16 | Depository Certificate Number | depst_ctf_nbr | STRING | X |  |  |  | Chứng nhận lưu ký — thông tin bổ sung của FIMS không có trong FMS.BANKMONI. | FMS.BANKMONI |  |  |
| 17 | Description | dsc | STRING | X |  |  |  | Ghi chú. | FMS.BANKMONI |  |  |


#### 2.{IDX}.10.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Custodian Bank Id | cstd_bnk_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Country of Registration Id | cty_of_rgst_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.11 Bảng Involved Party Postal Address — FMS.BANKMONI

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Custodian Bank. | FMS.BANKMONI | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã ngân hàng LKGS. | FMS.BANKMONI | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.BANKMONI' | Mã nguồn dữ liệu. | FMS.BANKMONI |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ. | FMS.BANKMONI |  | Scheme: IP_ADDR_TYPE. |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở ngân hàng LKGS. | FMS.BANKMONI | Address |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | FMS.BANKMONI |  |  |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). | FMS.BANKMONI |  |  |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. | FMS.BANKMONI |  |  |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. | FMS.BANKMONI |  |  |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | FMS.BANKMONI |  |  |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | FMS.BANKMONI |  |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | FMS.BANKMONI |  |  |


#### 2.{IDX}.11.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Custodian Bank | Custodian Bank Id | cstd_bnk_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.12 Bảng Involved Party Electronic Address — FMS.BANKMONI

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Custodian Bank. | FMS.BANKMONI | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã ngân hàng LKGS. | FMS.BANKMONI | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.BANKMONI' | Mã nguồn dữ liệu. | FMS.BANKMONI |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại liên lạc — email. | FMS.BANKMONI |  | Scheme: IP_ELEC_ADDR_TYPE. |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Địa chỉ email. | FMS.BANKMONI | Email |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Custodian Bank. | FMS.BANKMONI | Id |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã ngân hàng LKGS. | FMS.BANKMONI | Id |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.BANKMONI' | Mã nguồn dữ liệu. | FMS.BANKMONI |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại liên lạc — điện thoại. | FMS.BANKMONI |  | Scheme: IP_ELEC_ADDR_TYPE. |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại. | FMS.BANKMONI | Telephone |  |


#### 2.{IDX}.12.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Custodian Bank | Custodian Bank Id | cstd_bnk_id |




### 2.{IDX}.13 Bảng Fund Distribution Agent

- **Mô tả:** Tổ chức đại lý được ủy quyền phân phối chứng chỉ quỹ đầu tư cho nhà đầu tư.
- **Tên vật lý:** fnd_dstr_agnt
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Fund Distribution Agent Id | fnd_dstr_agnt_id | BIGINT |  | X | P |  | Khóa đại diện cho tổ chức đại lý phân phối quỹ. | FMS.AGENCIES |  | PK surrogate. |
| 2 | Fund Distribution Agent Code | fnd_dstr_agnt_code | STRING |  |  |  |  | Mã định danh đại lý phân phối quỹ. Map từ PK bảng nguồn. | FMS.AGENCIES | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.AGENCIES' | Mã nguồn dữ liệu. | FMS.AGENCIES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Fund Distribution Agent Name | fnd_dstr_agnt_nm | STRING |  |  |  |  | Tên đầy đủ đại lý phân phối quỹ. | FMS.AGENCIES | Name |  |
| 5 | Fund Distribution Agent Short Name | fnd_dstr_agnt_shrt_nm | STRING | X |  |  |  | Tên viết tắt đại lý. | FMS.AGENCIES | ShortName |  |
| 6 | Agency Type Code | agnc_tp_code | STRING | X |  |  |  | Loại đại lý phân phối quỹ. | FMS.AGENCIES | AgencyTypeId | Scheme: FMS_AGENCY_TYPE. |
| 7 | Practice Status Code | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động. | FMS.AGENCIES | Status | Scheme: FMS_OPERATION_STATUS. |
| 8 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FMS.AGENCIES | CreatedBy |  |
| 9 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.AGENCIES | DateCreated |  |
| 10 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.AGENCIES | DateModified |  |


#### 2.{IDX}.13.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Fund Distribution Agent Id | fnd_dstr_agnt_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.14 Bảng Involved Party Postal Address — FMS.AGENCIES

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Distribution Agent. | FMS.AGENCIES | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã đại lý phân phối quỹ. | FMS.AGENCIES | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.AGENCIES' | Mã nguồn dữ liệu. | FMS.AGENCIES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ. | FMS.AGENCIES |  | Scheme: IP_ADDR_TYPE. |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở đại lý phân phối quỹ. | FMS.AGENCIES | Address |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | FMS.AGENCIES |  |  |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). | FMS.AGENCIES |  |  |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. | FMS.AGENCIES |  |  |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. | FMS.AGENCIES |  |  |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | FMS.AGENCIES |  |  |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | FMS.AGENCIES |  |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | FMS.AGENCIES |  |  |


#### 2.{IDX}.14.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Fund Distribution Agent | Fund Distribution Agent Id | fnd_dstr_agnt_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.15 Bảng Discretionary Investment Investor

- **Mô tả:** Nhà đầu tư ủy thác — cá nhân hoặc tổ chức giao tài sản cho công ty quản lý quỹ quản lý theo hợp đồng ủy thác đầu tư.
- **Tên vật lý:** dscr_ivsm_ivsr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Discretionary Investment Investor Id | dscr_ivsm_ivsr_id | BIGINT |  | X | P |  | Khóa đại diện cho nhà đầu tư ủy thác. | FMS.INVES |  | PK surrogate. |
| 2 | Discretionary Investment Investor Code | dscr_ivsm_ivsr_code | STRING |  |  |  |  | Mã định danh nhà đầu tư ủy thác. Map từ PK bảng nguồn. | FMS.INVES | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.INVES' | Mã nguồn dữ liệu. | FMS.INVES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Investor Name | ivsr_nm | STRING |  |  |  |  | Tên nhà đầu tư ủy thác (cá nhân hoặc tổ chức). | FMS.INVES | Name |  |
| 5 | Dorf Indicator | dorf_ind | STRING | X |  |  |  | Loại hình trong/ngoài nước. 1=Trong nước; 0=Nước ngoài. | FMS.INVES | Dorf |  |
| 6 | Nationality Code | nationality_code | STRING | X |  |  |  | Quốc tịch nhà đầu tư. | FMS.INVES | NatId | Scheme: FMS_NATIONAL. |
| 7 | Stockholder Type Code | stockholder_tp_code | STRING | X |  |  |  | Loại hình nhà đầu tư/cổ đông. | FMS.INVES | StoId | Scheme: FMS_STOCKHOLDER_TYPE. |
| 8 | Relationship Type Code | rltnp_tp_code | STRING | X |  |  |  | Mối quan hệ cổ đông với tổ chức liên quan. | FMS.INVES | RelationShip | Scheme: FMS_RELATION_TYPE. |
| 9 | Fund Management Company Id | fnd_mgt_co_id | BIGINT | X |  | F |  | FK đến công ty QLQ đang nhận ủy thác. | FMS.INVES | SecId |  |
| 10 | Fund Management Company Code | fnd_mgt_co_code | STRING | X |  |  |  | Mã công ty QLQ đang nhận ủy thác. | FMS.INVES | SecId |  |
| 11 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FMS.INVES | CreatedBy |  |
| 12 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.INVES | DateCreated |  |
| 13 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.INVES | DateModified |  |


#### 2.{IDX}.15.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Discretionary Investment Investor Id | dscr_ivsm_ivsr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Fund Management Company Id | fnd_mgt_co_id | Fund Management Company | Fund Management Company Id | fnd_mgt_co_id |




### 2.{IDX}.16 Bảng Involved Party Alternative Identification — FMS.INVES

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Discretionary Investment Investor. | FMS.INVES | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã nhà đầu tư ủy thác. | FMS.INVES | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.INVES' | Mã nguồn dữ liệu. | FMS.INVES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ định danh. | FMS.INVES | IdType | Scheme: IP_ALT_ID_TYPE. IdType xác định loại giấy tờ (CMND/CCCD/Hộ chiếu/ĐKKD). |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số giấy tờ định danh. | FMS.INVES | IdNo |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp giấy tờ định danh. | FMS.INVES | IdDate |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy tờ. | FMS.INVES |  |  |


#### 2.{IDX}.16.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Discretionary Investment Investor | Discretionary Investment Investor Id | dscr_ivsm_ivsr_id |




### 2.{IDX}.17 Bảng Reporting Period

- **Mô tả:** Kỳ báo cáo định kỳ (ngày/tuần/tháng/quý/bán niên/năm) mà thành viên thị trường phải nộp báo cáo lên UBCKNN.
- **Tên vật lý:** rpt_prd
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Reporting Period Id | rpt_prd_id | BIGINT |  | X | P |  | Khóa đại diện cho kỳ báo cáo. | FMS.RPTPERIOD |  | PK surrogate. |
| 2 | Reporting Period Code | rpt_prd_code | STRING |  |  |  |  | Mã định danh kỳ báo cáo. Map từ PK bảng nguồn. | FMS.RPTPERIOD | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.RPTPERIOD' | Mã nguồn dữ liệu. | FMS.RPTPERIOD |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Reporting Period Name | rpt_prd_nm | STRING |  |  |  |  | Tên kỳ báo cáo. | FMS.RPTPERIOD | PeriodName |  |
| 5 | Reporting Period Type Code | rpt_prd_tp_code | STRING | X |  |  |  | Kiểu kỳ báo cáo (tháng/quý/năm...). | FMS.RPTPERIOD | PeriodType | Scheme: FMS_REPORTING_PERIOD_TYPE. |
| 6 | Is Active Flag | is_actv_f | BOOLEAN | X |  |  |  | Kỳ báo cáo đang hoạt động. | FMS.RPTPERIOD | IsActive |  |
| 7 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FMS.RPTPERIOD | CreatedBy |  |
| 8 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.RPTPERIOD | DateCreated |  |
| 9 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.RPTPERIOD | DateModified |  |
| 10 | Self-set Period Id | self-set_prd_id | BIGINT | X |  | F |  | FK đến kỳ báo cáo do cán bộ UB tự thiết lập (SELFSETPD). Nullable. | FMS.RPTPERIOD |  |  |
| 11 | Self-set Period Code | self-set_prd_code | STRING | X |  |  |  | Mã kỳ báo cáo tự thiết lập. | FMS.RPTPERIOD |  |  |
| 12 | Report Template Id | rpt_tpl_id | BIGINT |  |  | F |  | FK đến biểu mẫu báo cáo áp dụng cho kỳ này. | FMS.RPTPERIOD |  |  |
| 13 | Report Template Code | rpt_tpl_code | STRING |  |  |  |  | Mã biểu mẫu báo cáo. | FMS.RPTPERIOD |  |  |
| 14 | Submission Deadline Date | submission_ddln_dt | DATE | X |  |  |  | Thời hạn gửi báo cáo muộn nhất (áp dụng cho kỳ ngày/tuần). | FMS.RPTPERIOD |  |  |
| 15 | Submission Deadline Week | submission_ddln_wk | INT | X |  |  |  | Thời hạn gửi báo cáo muộn nhất (tuần). | FMS.RPTPERIOD |  |  |
| 16 | Repeat Interval | repeat_itrv | INT | X |  |  |  | Lặp lại sau bao nhiêu đơn vị kỳ. | FMS.RPTPERIOD |  |  |
| 17 | Counting Start Date | counting_strt_dt | DATE | X |  |  |  | Ngày bắt đầu tính hạn nộp báo cáo. | FMS.RPTPERIOD |  |  |
| 18 | Is Working Day Indicator | is_wrk_day_ind | STRING | X |  |  |  | Đơn vị tính hạn nộp: 0: Ngày lịch 1: Ngày làm việc. | FMS.RPTPERIOD |  |  |
| 19 | Submit Within Days | submit_wi_dys | INT | X |  |  |  | Số ngày/ngày làm việc được phép gửi báo cáo. | FMS.RPTPERIOD |  |  |
| 20 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. | FMS.RPTPERIOD |  | Scheme: LIFE_CYCLE_STATUS. |
| 21 | Description | dsc | STRING | X |  |  |  | Ghi chú. | FMS.RPTPERIOD |  |  |


#### 2.{IDX}.17.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Reporting Period Id | rpt_prd_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Report Template Id | rpt_tpl_id | Report Template | Report Template Id | rpt_tpl_id |




### 2.{IDX}.18 Bảng Member Rating Period

- **Mô tả:** Kỳ đánh giá xếp loại định kỳ cho các thành viên thị trường (công ty quản lý quỹ). Xác định phạm vi thời gian áp dụng tiêu chí chấm điểm.
- **Tên vật lý:** mbr_rtg_prd
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Member Rating Period Id | mbr_rtg_prd_id | BIGINT |  | X | P |  | Khóa đại diện cho kỳ đánh giá xếp loại. | FMS.RATINGPD |  | PK surrogate. |
| 2 | Member Rating Period Code | mbr_rtg_prd_code | STRING |  |  |  |  | Mã định danh kỳ đánh giá. Map từ PK bảng nguồn. | FMS.RATINGPD | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.RATINGPD' | Mã nguồn dữ liệu. | FMS.RATINGPD |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Member Rating Period Name | mbr_rtg_prd_nm | STRING |  |  |  |  | Tên kỳ đánh giá xếp loại. | FMS.RATINGPD | PeriodName |  |
| 5 | Rating Period Start Date | rtg_prd_strt_dt | DATE | X |  |  |  | Ngày bắt đầu kỳ đánh giá. | FMS.RATINGPD | StartDate |  |
| 6 | Rating Period End Date | rtg_prd_end_dt | DATE | X |  |  |  | Ngày kết thúc kỳ đánh giá. | FMS.RATINGPD | EndDate |  |
| 7 | Is Active Flag | is_actv_f | BOOLEAN | X |  |  |  | Kỳ đánh giá đang hoạt động. | FMS.RATINGPD | IsActive |  |
| 8 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.RATINGPD | DateCreated |  |
| 9 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.RATINGPD | DateModified |  |


#### 2.{IDX}.18.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Member Rating Period Id | mbr_rtg_prd_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.19 Bảng Investment Fund

- **Mô tả:** Quỹ đầu tư chứng khoán — pháp nhân độc lập do công ty quản lý quỹ thành lập và quản lý. Lưu thông tin pháp lý và vốn của quỹ.
- **Tên vật lý:** ivsm_fnd
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Investment Fund Id | ivsm_fnd_id | BIGINT |  | X | P |  | Khóa đại diện cho quỹ đầu tư chứng khoán. | FMS.FUNDS |  | PK surrogate. |
| 2 | Investment Fund Code | ivsm_fnd_code | STRING |  |  |  |  | Mã định danh quỹ đầu tư. Map từ PK bảng nguồn. | FMS.FUNDS | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.FUNDS' | Mã nguồn dữ liệu. | FMS.FUNDS |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Investment Fund Name | ivsm_fnd_nm | STRING |  |  |  |  | Tên đầy đủ quỹ đầu tư. | FMS.FUNDS | FundName |  |
| 5 | Investment Fund Short Name | ivsm_fnd_shrt_nm | STRING | X |  |  |  | Tên viết tắt quỹ đầu tư. | FMS.FUNDS | FundShortName |  |
| 6 | Investment Fund English Name | ivsm_fnd_english_nm | STRING | X |  |  |  | Tên tiếng Anh quỹ đầu tư. | FMS.FUNDS | FundEnName |  |
| 7 | Fund Management Company Id | fnd_mgt_co_id | BIGINT |  |  | F |  | FK đến công ty QLQ quản lý quỹ. | FMS.FUNDS | SecId |  |
| 8 | Fund Management Company Code | fnd_mgt_co_code | STRING |  |  |  |  | Mã công ty QLQ quản lý quỹ. | FMS.FUNDS | SecId |  |
| 9 | Fund Capital Amount | fnd_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ quỹ đầu tư (VNĐ). | FMS.FUNDS | FundCapital |  |
| 10 | Fund Type Code | fnd_tp_code | STRING | X |  |  |  | Loại hình quỹ đầu tư. | FMS.FUNDS | FundType | Scheme: FMS_FUND_TYPE. |
| 11 | Practice Status Code | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động quỹ. | FMS.FUNDS | Status | Scheme: FMS_OPERATION_STATUS. |
| 12 | License Decision Date | license_dcsn_dt | DATE | X |  |  |  | Ngày cấp phép thành lập quỹ. | FMS.FUNDS | DecisionDate |  |
| 13 | Active Date | actv_dt | DATE | X |  |  |  | Ngày bắt đầu hoạt động. | FMS.FUNDS | ActiveDate |  |
| 14 | Stop Date | stop_dt | DATE | X |  |  |  | Ngày ngừng hoạt động. | FMS.FUNDS | StopDate |  |
| 15 | Distribution Agent Ids | dstr_agnt_ids | Array<Struct> | X |  |  |  | Danh sách đại lý phân phối quỹ (SK + mã nghiệp vụ). | FMS.FUNDS | AgnId |  |
| 16 | Custodian Bank Ids | cstd_bnk_ids | Array<Struct> | X |  |  |  | Danh sách ngân hàng lưu ký giám sát (SK + mã nghiệp vụ). | FMS.FUNDS | BmnId |  |
| 17 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FMS.FUNDS | CreatedBy |  |
| 18 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.FUNDS | DateCreated |  |
| 19 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.FUNDS | DateModified |  |


#### 2.{IDX}.19.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Investment Fund Id | ivsm_fnd_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Fund Management Company Id | fnd_mgt_co_id | Fund Management Company | Fund Management Company Id | fnd_mgt_co_id |




### 2.{IDX}.20 Bảng Involved Party Alternative Identification — FMS.FUNDS

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Investment Fund. | FMS.FUNDS | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã quỹ đầu tư. | FMS.FUNDS | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.FUNDS' | Mã nguồn dữ liệu. | FMS.FUNDS |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ — quyết định thành lập quỹ. | FMS.FUNDS |  | Scheme: IP_ALT_ID_TYPE. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số quyết định thành lập CN/VPĐD. | FMS.FUNDS |  |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp quyết định thành lập quỹ. | FMS.FUNDS | DecisionDate |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Cơ quan ban hành quyết định thành lập | FMS.FUNDS |  |  |


#### 2.{IDX}.20.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Investment Fund | Investment Fund Id | ivsm_fnd_id |




### 2.{IDX}.21 Bảng Fund Management Company Key Person

- **Mô tả:** Nhân sự chủ chốt của công ty quản lý quỹ (giám đốc/chuyên gia đầu tư/người được ủy quyền). Lưu thông tin cá nhân và chứng chỉ hành nghề.
- **Tên vật lý:** fnd_mgt_co_key_psn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Fund Management Company Key Person Id | fnd_mgt_co_key_psn_id | BIGINT |  | X | P |  | Khóa đại diện cho nhân sự chủ chốt công ty QLQ. | FMS.TLProfiles |  | PK surrogate. |
| 2 | Fund Management Company Key Person Code | fnd_mgt_co_key_psn_code | STRING |  |  |  |  | Mã định danh nhân sự. Map từ PK bảng nguồn. | FMS.TLProfiles | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.TLProfiles' | Mã nguồn dữ liệu. | FMS.TLProfiles |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Fund Management Company Id | fnd_mgt_co_id | BIGINT |  |  | F |  | FK đến công ty QLQ. | FMS.TLProfiles | SecId |  |
| 5 | Fund Management Company Code | fnd_mgt_co_code | STRING |  |  |  |  | Mã công ty QLQ. | FMS.TLProfiles | SecId |  |
| 6 | Full Name | full_nm | STRING |  |  |  |  | Họ và tên đầy đủ nhân sự. | FMS.TLProfiles | FullName |  |
| 7 | Birth Date | brth_dt | DATE | X |  |  |  | Ngày sinh. | FMS.TLProfiles | BirthDate |  |
| 8 | Nationality Code | nationality_code | STRING | X |  |  |  | Quốc tịch. | FMS.TLProfiles | NatId | Scheme: FMS_NATIONAL. |
| 9 | Job Type Code | job_tp_code | STRING | X |  |  |  | Loại chức vụ. | FMS.TLProfiles | JobTypeId | Scheme: FMS_JOB_TYPE. |
| 10 | Is Legal Representative Indicator | is_lgl_representative_ind | STRING | X |  |  |  | Cờ đánh dấu người đại diện pháp luật. | FMS.TLProfiles | IsLegal |  |
| 11 | Is Disclosure Representative Indicator | is_dscl_representative_ind | STRING | X |  |  |  | Cờ đánh dấu đại diện công bố thông tin (CBTT). | FMS.TLProfiles | IsCBTT |  |
| 12 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FMS.TLProfiles | CreatedBy |  |
| 13 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.TLProfiles | DateCreated |  |
| 14 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.TLProfiles | DateModified |  |


#### 2.{IDX}.21.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Fund Management Company Key Person Id | fnd_mgt_co_key_psn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Fund Management Company Id | fnd_mgt_co_id | Fund Management Company | Fund Management Company Id | fnd_mgt_co_id |




### 2.{IDX}.22 Bảng Involved Party Alternative Identification — FMS.TLProfiles

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company Key Person. | FMS.TLProfiles | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã nhân sự công ty QLQ. | FMS.TLProfiles | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.TLProfiles' | Mã nguồn dữ liệu. | FMS.TLProfiles |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ định danh cá nhân. | FMS.TLProfiles |  | Scheme: IP_ALT_ID_TYPE. Giá trị: CITIZEN_ID (CCCD) hoặc PASSPORT (Hộ chiếu). |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số giấy tờ định danh. | FMS.TLProfiles | IdNo |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp CCCD/Hộ chiếu. | FMS.TLProfiles |  |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp CCCD/Hộ chiếu. | FMS.TLProfiles |  |  |


#### 2.{IDX}.22.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Fund Management Company Key Person | Fund Management Company Key Person Id | fnd_mgt_co_key_psn_id |




### 2.{IDX}.23 Bảng Fund Management Company Organization Unit

- **Mô tả:** Chi nhánh hoặc văn phòng đại diện của công ty quản lý quỹ trong nước. Có địa chỉ và giấy phép hoạt động riêng.
- **Tên vật lý:** fnd_mgt_co_ou
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Fund Management Company Organization Unit Id | fnd_mgt_co_ou_id | BIGINT |  | X | P |  | Khóa đại diện cho CN/VPĐD công ty QLQ trong nước. | FMS.BRANCHES |  | PK surrogate. |
| 2 | Fund Management Company Organization Unit Code | fnd_mgt_co_ou_code | STRING |  |  |  |  | Mã định danh CN/VPĐD. Map từ PK bảng nguồn. | FMS.BRANCHES | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.BRANCHES' | Mã nguồn dữ liệu. | FMS.BRANCHES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Fund Management Company Id | fnd_mgt_co_id | BIGINT |  |  | F |  | FK đến công ty QLQ trong nước. | FMS.BRANCHES | SecId |  |
| 5 | Fund Management Company Code | fnd_mgt_co_code | STRING |  |  |  |  | Mã công ty QLQ trong nước. | FMS.BRANCHES | SecId |  |
| 6 | Fund Management Company Organization Unit Name | fnd_mgt_co_ou_nm | STRING |  |  |  |  | Tên CN/VPĐD công ty QLQ. | FMS.BRANCHES | Name |  |
| 7 | Organization Unit Type Code | ou_tp_code | STRING | X |  |  |  | Loại đơn vị: CN hoặc VPĐD. | FMS.BRANCHES | BrType | Scheme: FMS_ORGANIZATION_UNIT_TYPE. |
| 8 | Parent Organization Unit Id | prn_ou_id | BIGINT | X |  | F |  | FK tự thân — CN/VPĐD cha. | FMS.BRANCHES | BrIdowner |  |
| 9 | Parent Organization Unit Code | prn_ou_code | STRING | X |  |  |  | Mã CN/VPĐD cha. | FMS.BRANCHES | BrIdowner |  |
| 10 | Legal Representative Id | lgl_representative_id | BIGINT | X |  | F |  | FK đến người đại diện pháp luật của CN/VPĐD. | FMS.BRANCHES | TLId |  |
| 11 | Legal Representative Code | lgl_representative_code | STRING | X |  |  |  | Mã người đại diện pháp luật. | FMS.BRANCHES | TLId |  |
| 12 | Legal Representative Name | lgl_representative_nm | STRING | X |  |  |  | Tên người đại diện pháp luật (denormalized). | FMS.BRANCHES | TLName |  |
| 13 | License Decision Number | license_dcsn_nbr | STRING | X |  |  |  | Số quyết định thành lập CN/VPĐD. | FMS.BRANCHES | Decision |  |
| 14 | License Decision Date | license_dcsn_dt | DATE | X |  |  |  | Ngày cấp quyết định thành lập CN/VPĐD. | FMS.BRANCHES | DecisionDate |  |
| 15 | Voucher Number | vchr_nbr | STRING | X |  |  |  | Số chứng từ liên quan. | FMS.BRANCHES | VoucherNo |  |
| 16 | Voucher Date | vchr_dt | DATE | X |  |  |  | Ngày chứng từ. | FMS.BRANCHES | VoucherDate |  |
| 17 | Practice Status Code | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động. | FMS.BRANCHES | Status | Scheme: FMS_OPERATION_STATUS. |
| 18 | Stop Date | stop_dt | DATE | X |  |  |  | Ngày ngừng hoạt động. | FMS.BRANCHES | StopDate |  |
| 19 | Change Description | chg_dsc | STRING | X |  |  |  | Mô tả nội dung thay đổi. | FMS.BRANCHES | DesChange |  |
| 20 | Description | dsc | STRING | X |  |  |  | Mô tả bổ sung. | FMS.BRANCHES | Description |  |
| 21 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FMS.BRANCHES | CreatedBy |  |
| 22 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.BRANCHES | DateCreated |  |
| 23 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.BRANCHES | DateModified |  |
| 24 | Country of Registration Id | cty_of_rgst_id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký của công ty mẹ. | FMS.BRANCHES |  |  |
| 25 | Country of Registration Code | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. | FMS.BRANCHES |  |  |
| 26 | English Name | english_nm | STRING | X |  |  |  | Tên tiếng Anh. | FMS.BRANCHES |  |  |
| 27 | Abbreviation | abr | STRING | X |  |  |  | Tên viết tắt. | FMS.BRANCHES |  |  |
| 28 | Tax Code | tax_code | STRING | X |  |  |  | Mã số thuế. | FMS.BRANCHES |  |  |
| 29 | Charter Capital Amount | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn được cấp (VNĐ). | FMS.BRANCHES |  |  |
| 30 | Start Date | strt_dt | DATE | X |  |  |  | Hoạt động từ ngày. | FMS.BRANCHES |  |  |
| 31 | End Date | end_dt | DATE | X |  |  |  | Hoạt động đến ngày. | FMS.BRANCHES |  |  |
| 32 | Parent Company Name | prn_co_nm | STRING | X |  |  |  | Tên công ty mẹ (denormalized — nguồn ETL resolve FK). | FMS.BRANCHES |  |  |
| 33 | Parent Company Registration Number | prn_co_rgst_nbr | STRING | X |  |  |  | Số ĐKKD công ty mẹ (denormalized). | FMS.BRANCHES |  |  |
| 34 | Parent Company Address | prn_co_adr | STRING | X |  |  |  | Địa chỉ công ty mẹ (denormalized). | FMS.BRANCHES |  |  |
| 35 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. | FMS.BRANCHES |  | Scheme: LIFE_CYCLE_STATUS. |
| 36 | Business Type Codes | bsn_tp_codes | Array<Text> | X |  |  |  | Danh sách mã nghiệp vụ kinh doanh. Từ bảng junction BRANCHSBUSINES. | FMS.BRANCHES |  |  |


#### 2.{IDX}.23.1 Constraint

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




### 2.{IDX}.24 Bảng Involved Party Postal Address — FMS.BRANCHES

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company Organization Unit. | FMS.BRANCHES | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã CN/VPĐD công ty QLQ. | FMS.BRANCHES | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.BRANCHES' | Mã nguồn dữ liệu. | FMS.BRANCHES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ. | FMS.BRANCHES |  | Scheme: IP_ADDR_TYPE. |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ CN/VPĐD. | FMS.BRANCHES | Address |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | FMS.BRANCHES |  |  |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). | FMS.BRANCHES |  |  |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. | FMS.BRANCHES |  |  |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. | FMS.BRANCHES |  |  |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | FMS.BRANCHES |  |  |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | FMS.BRANCHES |  |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | FMS.BRANCHES |  |  |


#### 2.{IDX}.24.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Fund Management Company Organization Unit | Fund Management Company Organization Unit Id | fnd_mgt_co_ou_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.25 Bảng Involved Party Electronic Address — FMS.BRANCHES

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company Organization Unit. | FMS.BRANCHES | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã CN/VPĐD công ty QLQ. | FMS.BRANCHES | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.BRANCHES' | Mã nguồn dữ liệu. | FMS.BRANCHES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại liên lạc — fax. | FMS.BRANCHES |  | Scheme: IP_ELEC_ADDR_TYPE. |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số fax CN/VPĐD. | FMS.BRANCHES | Fax |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company Organization Unit. | FMS.BRANCHES | Id |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã CN/VPĐD công ty QLQ. | FMS.BRANCHES | Id |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.BRANCHES' | Mã nguồn dữ liệu. | FMS.BRANCHES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại liên lạc — điện thoại. | FMS.BRANCHES |  | Scheme: IP_ELEC_ADDR_TYPE. |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại CN/VPĐD. | FMS.BRANCHES | Telephone |  |


#### 2.{IDX}.25.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Fund Management Company Organization Unit | Fund Management Company Organization Unit Id | fnd_mgt_co_ou_id |




### 2.{IDX}.26 Bảng Involved Party Alternative Identification — FMS.BRANCHES

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Management Company Organization Unit. | FMS.BRANCHES | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã CN/VPĐD công ty QLQ. | FMS.BRANCHES | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.BRANCHES' | Mã nguồn dữ liệu. | FMS.BRANCHES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ — quyết định thành lập CN/VPĐD. | FMS.BRANCHES |  | Scheme: IP_ALT_ID_TYPE. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số quyết định thành lập CN/VPĐD. | FMS.BRANCHES | Decision |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp quyết định thành lập. | FMS.BRANCHES | DecisionDate |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Cơ quan ban hành quyết định thành lập | FMS.BRANCHES |  |  |


#### 2.{IDX}.26.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Fund Management Company Organization Unit | Fund Management Company Organization Unit Id | fnd_mgt_co_ou_id |




### 2.{IDX}.27 Bảng Fund Distribution Agent Organization Unit

- **Mô tả:** Chi nhánh hoặc phòng giao dịch của tổ chức đại lý phân phối quỹ đầu tư.
- **Tên vật lý:** fnd_dstr_agnt_ou
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Fund Distribution Agent Organization Unit Id | fnd_dstr_agnt_ou_id | BIGINT |  | X | P |  | Khóa đại diện cho CN/PGD của đại lý phân phối quỹ. | FMS.AGENCIESBRA |  | PK surrogate. |
| 2 | Fund Distribution Agent Organization Unit Code | fnd_dstr_agnt_ou_code | STRING |  |  |  |  | Mã định danh CN/PGD đại lý. Map từ PK bảng nguồn. | FMS.AGENCIESBRA | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.AGENCIESBRA' | Mã nguồn dữ liệu. | FMS.AGENCIESBRA |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Fund Distribution Agent Id | fnd_dstr_agnt_id | BIGINT |  |  | F |  | FK đến đại lý phân phối quỹ. | FMS.AGENCIESBRA | AgnId |  |
| 5 | Fund Distribution Agent Code | fnd_dstr_agnt_code | STRING |  |  |  |  | Mã đại lý phân phối quỹ. | FMS.AGENCIESBRA | AgnId |  |
| 6 | Fund Distribution Agent Organization Unit Name | fnd_dstr_agnt_ou_nm | STRING |  |  |  |  | Tên CN/PGD đại lý phân phối quỹ. | FMS.AGENCIESBRA | Name |  |
| 7 | Practice Status Code | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động. | FMS.AGENCIESBRA | Status | Scheme: FMS_OPERATION_STATUS. |
| 8 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.AGENCIESBRA | DateCreated |  |
| 9 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.AGENCIESBRA | DateModified |  |


#### 2.{IDX}.27.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Fund Distribution Agent Organization Unit Id | fnd_dstr_agnt_ou_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Fund Distribution Agent Id | fnd_dstr_agnt_id | Fund Distribution Agent | Fund Distribution Agent Id | fnd_dstr_agnt_id |




### 2.{IDX}.28 Bảng Involved Party Postal Address — FMS.AGENCIESBRA

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Fund Distribution Agent Organization Unit. | FMS.AGENCIESBRA | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã CN/PGD đại lý phân phối quỹ. | FMS.AGENCIESBRA | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.AGENCIESBRA' | Mã nguồn dữ liệu. | FMS.AGENCIESBRA |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ. | FMS.AGENCIESBRA |  | Scheme: IP_ADDR_TYPE. |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ CN/PGD đại lý phân phối quỹ. | FMS.AGENCIESBRA | Address |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | FMS.AGENCIESBRA |  |  |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). | FMS.AGENCIESBRA |  |  |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. | FMS.AGENCIESBRA |  |  |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. | FMS.AGENCIESBRA |  |  |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | FMS.AGENCIESBRA |  |  |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | FMS.AGENCIESBRA |  |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | FMS.AGENCIESBRA |  |  |


#### 2.{IDX}.28.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Fund Distribution Agent Organization Unit | Fund Distribution Agent Organization Unit Id | fnd_dstr_agnt_ou_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.29 Bảng Discretionary Investment Account

- **Mô tả:** Tài khoản đầu tư ủy thác — hợp đồng dịch vụ quản lý danh mục tài chính giữa nhà đầu tư ủy thác và công ty quản lý quỹ.
- **Tên vật lý:** dscr_ivsm_ac
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Discretionary Investment Account Id | dscr_ivsm_ac_id | BIGINT |  | X | P |  | Khóa đại diện cho hợp đồng ủy thác quản lý danh mục. | FMS.INVESACC |  | PK surrogate. |
| 2 | Discretionary Investment Account Code | dscr_ivsm_ac_code | STRING |  |  |  |  | Mã định danh tài khoản ủy thác. Map từ PK bảng nguồn. | FMS.INVESACC | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.INVESACC' | Mã nguồn dữ liệu. | FMS.INVESACC |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Discretionary Investment Investor Id | dscr_ivsm_ivsr_id | BIGINT |  |  | F |  | FK đến nhà đầu tư ủy thác. | FMS.INVESACC | InvesId |  |
| 5 | Discretionary Investment Investor Code | dscr_ivsm_ivsr_code | STRING |  |  |  |  | Mã nhà đầu tư ủy thác. | FMS.INVESACC | InvesId |  |
| 6 | Account Number | ac_nbr | STRING | X |  |  |  | Số tài khoản ủy thác. | FMS.INVESACC | Account |  |
| 7 | Account Place | ac_plc | STRING | X |  | F |  | Nơi lưu ký tài khoản. | FMS.INVESACC | AccPlace |  |
| 8 | Contract Number | ctr_nbr | STRING | X |  |  |  | Số hợp đồng ủy thác quản lý danh mục. | FMS.INVESACC | ContractNo |  |
| 9 | Committed Capital Amount | cmmt_cptl_amt | DECIMAL(18,2) | X |  |  |  | Quy mô vốn ủy thác cam kết (VNĐ). | FMS.INVESACC | ActScale |  |
| 10 | Actual Capital Amount | act_cptl_amt | DECIMAL(18,2) | X |  |  |  | Quy mô vốn ủy thác thực tế (VNĐ). | FMS.INVESACC | AdScale |  |
| 11 | Management Fee Rate | mgt_fee_rate | DECIMAL(9,6) | X |  |  |  | Phí quản lý theo điều khoản hợp đồng (%). | FMS.INVESACC | ManagerFee |  |
| 12 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái hợp đồng ủy thác. | FMS.INVESACC | Status | Scheme: LIFE_CYCLE_STATUS. |
| 13 | Report Date | rpt_dt | DATE | X |  |  |  | Ngày báo cáo. | FMS.INVESACC | DateReport |  |
| 14 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FMS.INVESACC | CreatedBy |  |
| 15 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.INVESACC | DateCreated |  |
| 16 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.INVESACC | DateModified |  |


#### 2.{IDX}.29.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Discretionary Investment Account Id | dscr_ivsm_ac_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Discretionary Investment Investor Id | dscr_ivsm_ivsr_id | Discretionary Investment Investor | Discretionary Investment Investor Id | dscr_ivsm_ivsr_id |




### 2.{IDX}.30 Bảng Member Rating

- **Mô tả:** Kết quả xếp loại của một công ty quản lý quỹ trong một kỳ đánh giá. Ghi nhận điểm tổng hợp và hạng xếp loại.
- **Tên vật lý:** mbr_rtg
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Member Rating Id | mbr_rtg_id | BIGINT |  | X | P |  | Khóa đại diện cho kết quả xếp hạng thành viên. | FMS.RANK |  | PK surrogate. |
| 2 | Member Rating Code | mbr_rtg_code | STRING |  |  |  |  | Mã định danh kết quả xếp hạng. Map từ PK bảng nguồn. | FMS.RANK | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.RANK' | Mã nguồn dữ liệu. | FMS.RANK |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Fund Management Company Id | fnd_mgt_co_id | BIGINT |  |  | F |  | FK đến công ty QLQ được xếp hạng. | FMS.RANK | SecId |  |
| 5 | Fund Management Company Code | fnd_mgt_co_code | STRING |  |  |  |  | Mã công ty QLQ được xếp hạng. | FMS.RANK | SecId |  |
| 6 | Member Rating Period Id | mbr_rtg_prd_id | BIGINT |  |  | F |  | FK đến kỳ đánh giá xếp loại. | FMS.RANK | RatingPdId |  |
| 7 | Member Rating Period Code | mbr_rtg_prd_code | STRING |  |  |  |  | Mã kỳ đánh giá xếp loại. | FMS.RANK | RatingPdId |  |
| 8 | Total Score | tot_scor | DECIMAL(9,6) | X |  |  |  | Tổng điểm đánh giá. | FMS.RANK | TotalScore |  |
| 9 | Rank Value | rank_val | INT | X |  |  |  | Giá trị xếp hạng (thứ tự). | FMS.RANK | RankValue |  |
| 10 | Rank Class Code | rank_clss_code | STRING | X |  |  |  | Xếp loại kết quả đánh giá. | FMS.RANK | RankClass | Scheme: FMS_RATING_CLASS. |
| 11 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.RANK | DateCreated |  |
| 12 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.RANK | DateModified |  |


#### 2.{IDX}.30.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Member Rating Id | mbr_rtg_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Fund Management Company Id | fnd_mgt_co_id | Fund Management Company | Fund Management Company Id | fnd_mgt_co_id |
| Member Rating Period Id | mbr_rtg_prd_id | Member Rating Period | Member Rating Period Id | mbr_rtg_prd_id |




### 2.{IDX}.31 Bảng Rating Criterion

- **Mô tả:** Tiêu chí chấm điểm đánh giá xếp loại thành viên thị trường. Lưu tên tiêu chí và điểm tối đa/trọng số. Có cấu trúc cha/con.
- **Tên vật lý:** rtg_criterion
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Rating Criterion Id | rtg_criterion_id | BIGINT |  | X | P |  | Khóa đại diện cho nhân tố chấm điểm đánh giá. | FMS.RNKFACTOR |  | PK surrogate. |
| 2 | Rating Criterion Code | rtg_criterion_code | STRING |  |  |  |  | Mã định danh nhân tố. Map từ PK bảng nguồn. | FMS.RNKFACTOR | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.RNKFACTOR' | Mã nguồn dữ liệu. | FMS.RNKFACTOR |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Rating Criterion Name | rtg_criterion_nm | STRING |  |  |  |  | Tên nhân tố chấm điểm. | FMS.RNKFACTOR | Name |  |
| 5 | Parent Rating Criterion Id | prn_rtg_criterion_id | BIGINT | X |  | F |  | FK tự thân — nhân tố cha. | FMS.RNKFACTOR | ParentId |  |
| 6 | Parent Rating Criterion Code | prn_rtg_criterion_code | STRING | X |  |  |  | Mã nhân tố cha. | FMS.RNKFACTOR | ParentId |  |
| 7 | Max Score | max_scor | DECIMAL(9,6) | X |  |  |  | Điểm tối đa của nhân tố. | FMS.RNKFACTOR | MaxScore |  |
| 8 | Weight | wght | DECIMAL(9,6) | X |  |  |  | Trọng số của nhân tố trong tổng điểm. | FMS.RNKFACTOR | Weight |  |
| 9 | Is Active Flag | is_actv_f | BOOLEAN | X |  |  |  | Nhân tố đang được áp dụng. | FMS.RNKFACTOR | IsActive |  |
| 10 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.RNKFACTOR | DateCreated |  |
| 11 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.RNKFACTOR | DateModified |  |


#### 2.{IDX}.31.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Rating Criterion Id | rtg_criterion_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Parent Rating Criterion Id | prn_rtg_criterion_id | Rating Criterion | Rating Criterion Id | rtg_criterion_id |




### 2.{IDX}.32 Bảng Investment Fund Investor Membership

- **Mô tả:** Quan hệ thành viên của nhà đầu tư trong một quỹ đầu tư. Lưu tỷ lệ vốn góp và trạng thái tham gia.
- **Tên vật lý:** ivsm_fnd_ivsr_mbr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Investment Fund Investor Membership Id | ivsm_fnd_ivsr_mbr_id | BIGINT |  | X | P |  | Khóa đại diện cho quan hệ góp vốn của NĐT vào quỹ. | FMS.MBFUND |  | PK surrogate. |
| 2 | Investment Fund Investor Membership Code | ivsm_fnd_ivsr_mbr_code | STRING |  |  |  |  | Mã định danh quan hệ góp vốn. Map từ PK bảng nguồn. | FMS.MBFUND | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.MBFUND' | Mã nguồn dữ liệu. | FMS.MBFUND |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Investment Fund Id | ivsm_fnd_id | BIGINT |  |  | F |  | FK đến quỹ đầu tư. | FMS.MBFUND | FndId |  |
| 5 | Investment Fund Code | ivsm_fnd_code | STRING |  |  |  |  | Mã quỹ đầu tư. | FMS.MBFUND | FndId |  |
| 6 | Discretionary Investment Investor Id | dscr_ivsm_ivsr_id | BIGINT |  |  | F |  | FK đến nhà đầu tư. | FMS.MBFUND | InvesId |  |
| 7 | Discretionary Investment Investor Code | dscr_ivsm_ivsr_code | STRING |  |  |  |  | Mã nhà đầu tư. | FMS.MBFUND | InvesId |  |
| 8 | Capital Amount | cptl_amt | DECIMAL(18,2) | X |  |  |  | Số vốn góp của NĐT vào quỹ (VNĐ). | FMS.MBFUND | Capital |  |
| 9 | Ownership Ratio | own_rto | DECIMAL(9,6) | X |  |  |  | Tỷ lệ sở hữu của NĐT trong quỹ (%). | FMS.MBFUND | Ratio |  |
| 10 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.MBFUND | DateCreated |  |
| 11 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.MBFUND | DateModified |  |


#### 2.{IDX}.32.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Investment Fund Investor Membership Id | ivsm_fnd_ivsr_mbr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Investment Fund Id | ivsm_fnd_id | Investment Fund | Investment Fund Id | ivsm_fnd_id |
| Discretionary Investment Investor Id | dscr_ivsm_ivsr_id | Discretionary Investment Investor | Discretionary Investment Investor Id | dscr_ivsm_ivsr_id |




### 2.{IDX}.33 Bảng Investment Fund Representative Board Member

- **Mô tả:** Thành viên ban đại diện hoặc hội đồng quản trị của quỹ đầu tư. Cá nhân đảm nhận vai trò quản trị trong cơ cấu tổ chức quỹ.
- **Tên vật lý:** ivsm_fnd_representative_board_mbr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Investment Fund Representative Board Member Id | ivsm_fnd_representative_board_mbr_id | BIGINT |  | X | P |  | Khóa đại diện cho thành viên ban đại diện quỹ. | FMS.REPRESENT |  | PK surrogate. |
| 2 | Investment Fund Representative Board Member Code | ivsm_fnd_representative_board_mbr_code | STRING |  |  |  |  | Mã định danh thành viên ban đại diện. Map từ PK bảng nguồn. | FMS.REPRESENT | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.REPRESENT' | Mã nguồn dữ liệu. | FMS.REPRESENT |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Investment Fund Id | ivsm_fnd_id | BIGINT |  |  | F |  | FK đến quỹ đầu tư. | FMS.REPRESENT | FndId |  |
| 5 | Investment Fund Code | ivsm_fnd_code | STRING |  |  |  |  | Mã quỹ đầu tư. | FMS.REPRESENT | FndId |  |
| 6 | Fund Management Company Key Person Id | fnd_mgt_co_key_psn_id | BIGINT |  |  | F |  | FK đến nhân sự giữ vai trò thành viên ban đại diện. | FMS.REPRESENT | TLId |  |
| 7 | Fund Management Company Key Person Code | fnd_mgt_co_key_psn_code | STRING |  |  |  |  | Mã nhân sự. | FMS.REPRESENT | TLId |  |
| 8 | Is Chair Indicator | is_chair_ind | STRING | X |  |  |  | Cờ đánh dấu trưởng ban đại diện. | FMS.REPRESENT | IsChair |  |
| 9 | Practice Status Code | practice_st_code | STRING | X |  |  |  | Trạng thái tham gia ban đại diện. | FMS.REPRESENT | Status | Scheme: FMS_REPRESENT_STATUS. |
| 10 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.REPRESENT | DateCreated |  |
| 11 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.REPRESENT | DateModified |  |


#### 2.{IDX}.33.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Investment Fund Representative Board Member Id | ivsm_fnd_representative_board_mbr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Investment Fund Id | ivsm_fnd_id | Investment Fund | Investment Fund Id | ivsm_fnd_id |
| Fund Management Company Key Person Id | fnd_mgt_co_key_psn_id | Fund Management Company Key Person | Fund Management Company Key Person Id | fnd_mgt_co_key_psn_id |




### 2.{IDX}.34 Bảng Foreign Fund Management Organization Unit Staff

- **Mô tả:** Nhân sự đảm nhận chức vụ tại văn phòng đại diện/chi nhánh công ty quản lý quỹ nước ngoài. Ghi nhận vai trò và tư cách pháp lý.
- **Tên vật lý:** frgn_fnd_mgt_ou_stff
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Foreign Fund Management Organization Unit Staff Id | frgn_fnd_mgt_ou_stff_id | BIGINT |  | X | P |  | Khóa đại diện cho nhân sự tại VPĐD/CN QLQ nước ngoài. | FMS.STFFGBRCH |  | PK surrogate. |
| 2 | Foreign Fund Management Organization Unit Staff Code | frgn_fnd_mgt_ou_stff_code | STRING |  |  |  |  | Mã định danh nhân sự VPĐD/CN QLQ NN. Map từ PK bảng nguồn. | FMS.STFFGBRCH | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.STFFGBRCH' | Mã nguồn dữ liệu. | FMS.STFFGBRCH |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Foreign Fund Management Organization Unit Id | frgn_fnd_mgt_ou_id | BIGINT |  |  | F |  | FK đến VPĐD/CN QLQ nước ngoài. | FMS.STFFGBRCH | FgBrId |  |
| 5 | Foreign Fund Management Organization Unit Code | frgn_fnd_mgt_ou_code | STRING |  |  |  |  | Mã VPĐD/CN QLQ nước ngoài. | FMS.STFFGBRCH | FgBrId |  |
| 6 | Fund Management Company Key Person Id | fnd_mgt_co_key_psn_id | BIGINT |  |  | F |  | FK đến nhân sự giữ vai trò tại VPĐD/CN QLQ NN. | FMS.STFFGBRCH | TLId |  |
| 7 | Fund Management Company Key Person Code | fnd_mgt_co_key_psn_code | STRING |  |  |  |  | Mã nhân sự. | FMS.STFFGBRCH | TLId |  |
| 8 | Organization Unit Type Code | ou_tp_code | STRING | X |  |  |  | Loại đơn vị: VPĐD hoặc CN NN. | FMS.STFFGBRCH | FnType | Scheme: FMS_FOREIGN_OU_TYPE. |
| 9 | Is Legal Representative Indicator | is_lgl_representative_ind | STRING | X |  |  |  | Cờ đánh dấu người đại diện pháp luật tại VPĐD/CN. | FMS.STFFGBRCH | Isr |  |
| 10 | Is Disclosure Representative Indicator | is_dscl_representative_ind | STRING | X |  |  |  | Cờ đánh dấu đại diện công bố thông tin. | FMS.STFFGBRCH | Isp |  |
| 11 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.STFFGBRCH | DateCreated |  |
| 12 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.STFFGBRCH | DateModified |  |


#### 2.{IDX}.34.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Foreign Fund Management Organization Unit Staff Id | frgn_fnd_mgt_ou_stff_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Foreign Fund Management Organization Unit Id | frgn_fnd_mgt_ou_id | Foreign Fund Management Organization Unit | Foreign Fund Management Organization Unit Id | frgn_fnd_mgt_ou_id |
| Fund Management Company Key Person Id | fnd_mgt_co_key_psn_id | Fund Management Company Key Person | Fund Management Company Key Person Id | fnd_mgt_co_key_psn_id |




### 2.{IDX}.35 Bảng Member Periodic Report

- **Mô tả:** Báo cáo định kỳ do thành viên thị trường nộp lên UBCKNN theo từng kỳ báo cáo. Ghi nhận trạng thái nộp và thời hạn.
- **Tên vật lý:** mbr_prd_rpt
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Member Periodic Report Id | mbr_prd_rpt_id | BIGINT |  | X | P |  | Khóa đại diện cho báo cáo định kỳ thành viên. | FMS.RPTMEMBER |  | PK surrogate. |
| 2 | Member Periodic Report Code | mbr_prd_rpt_code | STRING |  |  |  |  | Mã định danh báo cáo. Map từ PK bảng nguồn. | FMS.RPTMEMBER | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.RPTMEMBER' | Mã nguồn dữ liệu. | FMS.RPTMEMBER |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Fund Management Company Id | fnd_mgt_co_id | BIGINT | X |  | F |  | FK đến công ty QLQ nộp báo cáo (nullable). | FMS.RPTMEMBER | SecId |  |
| 5 | Fund Management Company Code | fnd_mgt_co_code | STRING | X |  |  |  | Mã công ty QLQ. | FMS.RPTMEMBER | SecId |  |
| 6 | Investment Fund Id | ivsm_fnd_id | BIGINT | X |  | F |  | FK đến quỹ đầu tư nộp báo cáo (nullable). | FMS.RPTMEMBER | FndId |  |
| 7 | Investment Fund Code | ivsm_fnd_code | STRING | X |  |  |  | Mã quỹ đầu tư. | FMS.RPTMEMBER | FndId |  |
| 8 | Custodian Bank Id | cstd_bnk_id | BIGINT | X |  | F |  | FK đến ngân hàng LKGS nộp báo cáo (nullable). | FMS.RPTMEMBER | BkMId |  |
| 9 | Custodian Bank Code | cstd_bnk_code | STRING | X |  |  |  | Mã ngân hàng LKGS. | FMS.RPTMEMBER | BkMId |  |
| 10 | Foreign Fund Management Organization Unit Id | frgn_fnd_mgt_ou_id | BIGINT | X |  | F |  | FK đến VPĐD/CN QLQ NN nộp báo cáo (nullable). | FMS.RPTMEMBER | FrBrId |  |
| 11 | Foreign Fund Management Organization Unit Code | frgn_fnd_mgt_ou_code | STRING | X |  |  |  | Mã VPĐD/CN QLQ NN. | FMS.RPTMEMBER | FrBrId |  |
| 12 | Report Template Id | rpt_tpl_id | BIGINT | X |  | F |  | FK đến biểu mẫu báo cáo. | FMS.RPTMEMBER | RptId |  |
| 13 | Report Template Code | rpt_tpl_code | STRING | X |  |  |  | Mã biểu mẫu báo cáo. | FMS.RPTMEMBER | RptId |  |
| 14 | Reporting Period Id | rpt_prd_id | BIGINT |  |  | F |  | FK đến kỳ báo cáo. | FMS.RPTMEMBER | PrdId |  |
| 15 | Reporting Period Code | rpt_prd_code | STRING |  |  |  |  | Mã kỳ báo cáo. | FMS.RPTMEMBER | PrdId |  |
| 16 | Is Import Indicator | is_impr_ind | STRING | X |  |  |  | Là báo cáo có import: 1-Có; 2-Không. | FMS.RPTMEMBER | IsImport |  |
| 17 | Report Name | rpt_nm | STRING | X |  |  |  | Tên báo cáo. | FMS.RPTMEMBER | RptName |  |
| 18 | Content Summary | cntnt_smy | STRING | X |  |  |  | Tóm tắt nội dung báo cáo. | FMS.RPTMEMBER | ContentSummary |  |
| 19 | Report Type Code | rpt_tp_code | STRING | X |  |  |  | Loại báo cáo: định kỳ hoặc bất thường. | FMS.RPTMEMBER | ReportType | Scheme: FMS_REPORT_TYPE. |
| 20 | Reporting Member Type Code | rpt_mbr_tp_code | STRING | X |  |  |  | Loại thành viên nộp báo cáo. | FMS.RPTMEMBER | Type | Scheme: FMS_REPORTING_MEMBER_TYPE. |
| 21 | Reporting Period Type Code | rpt_prd_tp_code | STRING | X |  |  |  | Kiểu kỳ báo cáo (tháng/quý/năm). | FMS.RPTMEMBER | PeriodType | Scheme: FMS_REPORTING_PERIOD_TYPE. |
| 22 | Year Value | yr_val | STRING | X |  |  |  | Năm báo cáo. | FMS.RPTMEMBER | YearValue |  |
| 23 | Day Report | day_rpt | INT | X |  |  |  | Ngày trong kỳ báo cáo. | FMS.RPTMEMBER | DayReport |  |
| 24 | Submission Deadline Date | submission_ddln_dt | DATE | X |  |  |  | Thời hạn nộp báo cáo. | FMS.RPTMEMBER | DeadlineSend |  |
| 25 | Submission Date | submission_dt | DATE | X |  |  |  | Ngày nộp báo cáo thực tế. | FMS.RPTMEMBER | DateSubmitted |  |
| 26 | Report Submission Status Code | rpt_submission_st_code | STRING | X |  |  |  | Trạng thái nộp báo cáo. | FMS.RPTMEMBER | Status | Scheme: FMS_REPORT_SUBMISSION_STATUS. |
| 27 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FMS.RPTMEMBER | CreatedBy |  |
| 28 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.RPTMEMBER | DateCreated |  |
| 29 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.RPTMEMBER | DateModified |  |
| 30 | Securities Company Id | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán gửi báo cáo. | FMS.RPTMEMBER |  |  |
| 31 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. | FMS.RPTMEMBER |  |  |
| 32 | Report Submission Schedule Id | rpt_submission_shd_id | BIGINT | X |  | F |  | FK đến định kỳ gửi báo cáo. | FMS.RPTMEMBER |  |  |
| 33 | Report Submission Schedule Code | rpt_submission_shd_code | STRING | X |  |  |  | Mã định kỳ gửi báo cáo. | FMS.RPTMEMBER |  |  |
| 34 | Description | dsc | STRING | X |  |  |  | Mô tả lần gửi. | FMS.RPTMEMBER |  |  |
| 35 | Reason | rsn | STRING | X |  |  |  | Lý do gửi (áp dụng gửi lại). | FMS.RPTMEMBER |  |  |
| 36 | Re Submission Reason | re_submission_rsn | STRING | X |  |  |  | Lý do gửi lại. | FMS.RPTMEMBER |  |  |
| 37 | Attachment File | attachment_file | STRING | X |  |  |  | Tệp đính kèm. | FMS.RPTMEMBER |  |  |
| 38 | Report Date | rpt_dt | DATE | X |  |  |  | Ngày số liệu báo cáo. | FMS.RPTMEMBER |  |  |
| 39 | Submission Timestamp | submission_tms | TIMESTAMP | X |  |  |  | Thời điểm gửi chính xác. | FMS.RPTMEMBER |  |  |
| 40 | Is Deleted Indicator | is_del_ind | STRING | X |  |  |  | Cờ xóa tạm: 1-Xóa; 0-Không xóa. | FMS.RPTMEMBER |  |  |
| 41 | Submission Status Code | submission_st_code | STRING | X |  |  |  | Trạng thái lần gửi: 4-Đã gửi; 5-Yêu cầu gửi lại; 6-Đã gửi lại. | FMS.RPTMEMBER |  | Scheme: SCMS_REPORT_SUBMISSION_STATUS. |
| 42 | Version | vrsn | STRING | X |  |  |  | Phiên bản báo cáo. | FMS.RPTMEMBER |  |  |


#### 2.{IDX}.35.1 Constraint

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




### 2.{IDX}.36 Bảng Fund Management Company Share Transfer

- **Mô tả:** Giao dịch chuyển nhượng cổ phần của công ty quản lý quỹ. Ghi nhận bên chuyển nhượng/nhận nhượng và giá trị giao dịch.
- **Tên vật lý:** fnd_mgt_co_shr_tfr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Fund Management Company Share Transfer Id | fnd_mgt_co_shr_tfr_id | BIGINT |  | X | P |  | Khóa đại diện cho giao dịch chuyển nhượng cổ phần QLQ. | FMS.TRSFERINDER |  | PK surrogate. |
| 2 | Fund Management Company Share Transfer Code | fnd_mgt_co_shr_tfr_code | STRING |  |  |  |  | Mã định danh giao dịch. Map từ PK bảng nguồn. | FMS.TRSFERINDER | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.TRSFERINDER' | Mã nguồn dữ liệu. | FMS.TRSFERINDER |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Fund Management Company Id | fnd_mgt_co_id | BIGINT |  |  | F |  | FK đến công ty QLQ có cổ phần được chuyển nhượng. | FMS.TRSFERINDER | SecId |  |
| 5 | Fund Management Company Code | fnd_mgt_co_code | STRING |  |  |  |  | Mã công ty QLQ. | FMS.TRSFERINDER | SecId |  |
| 6 | Transfer Date | tfr_dt | DATE |  |  |  |  | Ngày thực hiện giao dịch chuyển nhượng. | FMS.TRSFERINDER | TransDate |  |
| 7 | Share Quantity | shr_qty | INT | X |  |  |  | Số lượng cổ phần chuyển nhượng. | FMS.TRSFERINDER | Quantity |  |
| 8 | Transfer Price | tfr_prc | DECIMAL(18,2) | X |  |  |  | Giá giao dịch chuyển nhượng (VNĐ/cổ phần). | FMS.TRSFERINDER | Price |  |
| 9 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.TRSFERINDER | DateCreated |  |
| 10 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.TRSFERINDER | DateModified |  |


#### 2.{IDX}.36.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Fund Management Company Share Transfer Id | fnd_mgt_co_shr_tfr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Fund Management Company Id | fnd_mgt_co_id | Fund Management Company | Fund Management Company Id | fnd_mgt_co_id |




### 2.{IDX}.37 Bảng Fund Management Conduct Violation

- **Mô tả:** Vi phạm pháp luật hoặc hành chính của công ty quản lý quỹ hoặc quỹ đầu tư. Ghi nhận loại vi phạm và trạng thái xử lý.
- **Tên vật lý:** fnd_mgt_conduct_vln
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Fund Management Conduct Violation Id | fnd_mgt_conduct_vln_id | BIGINT |  | X | P |  | Khóa đại diện cho hành vi vi phạm quản lý quỹ. | FMS.VIOLT |  | PK surrogate. |
| 2 | Fund Management Conduct Violation Code | fnd_mgt_conduct_vln_code | STRING |  |  |  |  | Mã định danh vi phạm. Map từ PK bảng nguồn. | FMS.VIOLT | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.VIOLT' | Mã nguồn dữ liệu. | FMS.VIOLT |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Fund Management Company Id | fnd_mgt_co_id | BIGINT | X |  | F |  | FK đến công ty QLQ vi phạm (nullable). | FMS.VIOLT | SecId |  |
| 5 | Fund Management Company Code | fnd_mgt_co_code | STRING | X |  |  |  | Mã công ty QLQ. | FMS.VIOLT | SecId |  |
| 6 | Investment Fund Id | ivsm_fnd_id | BIGINT | X |  | F |  | FK đến quỹ đầu tư liên quan vi phạm (nullable). | FMS.VIOLT | FndId |  |
| 7 | Investment Fund Code | ivsm_fnd_code | STRING | X |  |  |  | Mã quỹ đầu tư. | FMS.VIOLT | FndId |  |
| 8 | Violation Type Code | vln_tp_code | STRING | X |  |  |  | Loại vi phạm. | FMS.VIOLT | ViolType | Scheme: FMS_VIOLATION_TYPE. |
| 9 | Violation Content | vln_cntnt | STRING | X |  |  |  | Nội dung mô tả vi phạm. | FMS.VIOLT | ViolContent |  |
| 10 | Violation Date | vln_dt | DATE | X |  |  |  | Ngày xác định vi phạm. | FMS.VIOLT | ViolDate |  |
| 11 | Violation Status Code | vln_st_code | STRING | X |  |  |  | Trạng thái xử lý vi phạm. | FMS.VIOLT | ViolStatus | Scheme: FMS_VIOLATION_STATUS. |
| 12 | Note | note | STRING | X |  |  |  | Ghi chú bổ sung về vi phạm. | FMS.VIOLT | Note |  |
| 13 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.VIOLT | DateCreated |  |
| 14 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.VIOLT | DateModified |  |


#### 2.{IDX}.37.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Fund Management Conduct Violation Id | fnd_mgt_conduct_vln_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Fund Management Company Id | fnd_mgt_co_id | Fund Management Company | Fund Management Company Id | fnd_mgt_co_id |
| Investment Fund Id | ivsm_fnd_id | Investment Fund | Investment Fund Id | ivsm_fnd_id |




### 2.{IDX}.38 Bảng Investment Fund Certificate Transfer

- **Mô tả:** Giao dịch mua/bán chứng chỉ quỹ của nhà đầu tư thành viên. Ghi nhận số lượng và giá giao dịch theo từng quỹ.
- **Tên vật lý:** ivsm_fnd_ctf_tfr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Investment Fund Investor Capital Transfer Id | ivsm_fnd_ivsr_cptl_tfr_id | BIGINT |  | X | P |  | Khóa đại diện cho giao dịch chuyển nhượng phần vốn góp quỹ. | FMS.TRANSFERMBF |  | PK surrogate. |
| 2 | Investment Fund Investor Capital Transfer Code | ivsm_fnd_ivsr_cptl_tfr_code | STRING |  |  |  |  | Mã định danh giao dịch. Map từ PK bảng nguồn. | FMS.TRANSFERMBF | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.TRANSFERMBF' | Mã nguồn dữ liệu. | FMS.TRANSFERMBF |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Investment Fund Id | ivsm_fnd_id | BIGINT |  |  | F |  | FK đến quỹ đầu tư có phần vốn chuyển nhượng. | FMS.TRANSFERMBF | FndId |  |
| 5 | Investment Fund Code | ivsm_fnd_code | STRING |  |  |  |  | Mã quỹ đầu tư. | FMS.TRANSFERMBF | FndId |  |
| 6 | Investment Fund Investor Membership Id | ivsm_fnd_ivsr_mbr_id | BIGINT |  |  | F |  | FK đến quan hệ góp vốn của NĐT trong quỹ. | FMS.TRANSFERMBF | MBFId |  |
| 7 | Investment Fund Investor Membership Code | ivsm_fnd_ivsr_mbr_code | STRING |  |  |  |  | Mã quan hệ góp vốn. | FMS.TRANSFERMBF | MBFId |  |
| 8 | Transfer Date | tfr_dt | DATE | X |  |  |  | Ngày thực hiện chuyển nhượng phần vốn. | FMS.TRANSFERMBF | TransDate |  |
| 9 | Transfer Quantity | tfr_qty | DECIMAL(18,2) | X |  |  |  | Số lượng phần vốn chuyển nhượng. | FMS.TRANSFERMBF | Quantity |  |
| 10 | Transfer Price | tfr_prc | DECIMAL(18,2) | X |  |  |  | Giá chuyển nhượng (VNĐ/phần vốn). | FMS.TRANSFERMBF | Price |  |
| 11 | Transfer Type Code | tfr_tp_code | STRING | X |  |  |  | Loại giao dịch chuyển nhượng. | FMS.TRANSFERMBF | TransType | Scheme: FMS_TRANSFER_TYPE. |
| 12 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.TRANSFERMBF | DateCreated |  |
| 13 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.TRANSFERMBF | DateModified |  |


#### 2.{IDX}.38.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Investment Fund Investor Capital Transfer Id | ivsm_fnd_ivsr_cptl_tfr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Investment Fund Id | ivsm_fnd_id | Investment Fund | Investment Fund Id | ivsm_fnd_id |
| Investment Fund Investor Membership Id | ivsm_fnd_ivsr_mbr_id | Investment Fund Investor Membership | Investment Fund Investor Membership Id | ivsm_fnd_ivsr_mbr_id |




### 2.{IDX}.39 Bảng Investment Fund Investor Capital Change Log

- **Mô tả:** Lịch sử thay đổi phần vốn góp của nhà đầu tư trong quỹ đầu tư. Ghi nhận vốn trước/sau và lý do thay đổi.
- **Tên vật lý:** ivsm_fnd_ivsr_cptl_chg_log
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Investment Fund Investor Capital Change Log Id | ivsm_fnd_ivsr_cptl_chg_log_id | BIGINT |  | X | P |  | Khóa đại diện cho bản ghi thay đổi vốn góp NĐT. | FMS.MBCHANGE |  | PK surrogate. |
| 2 | Investment Fund Investor Capital Change Log Code | ivsm_fnd_ivsr_cptl_chg_log_code | STRING |  |  |  |  | Mã định danh bản ghi thay đổi. Map từ PK bảng nguồn. | FMS.MBCHANGE | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.MBCHANGE' | Mã nguồn dữ liệu. | FMS.MBCHANGE |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Investment Fund Investor Membership Id | ivsm_fnd_ivsr_mbr_id | BIGINT |  |  | F |  | FK đến quan hệ góp vốn của NĐT trong quỹ. | FMS.MBCHANGE | MBFId |  |
| 5 | Investment Fund Investor Membership Code | ivsm_fnd_ivsr_mbr_code | STRING |  |  |  |  | Mã quan hệ góp vốn. | FMS.MBCHANGE | MBFId |  |
| 6 | Old Capital Amount | old_cptl_amt | DECIMAL(18,2) | X |  |  |  | Số vốn góp trước khi thay đổi (VNĐ). | FMS.MBCHANGE | OldCapital |  |
| 7 | New Capital Amount | new_cptl_amt | DECIMAL(18,2) | X |  |  |  | Số vốn góp sau khi thay đổi (VNĐ). | FMS.MBCHANGE | NewCapital |  |
| 8 | Change Date | chg_dt | DATE | X |  |  |  | Ngày thực hiện thay đổi vốn góp. | FMS.MBCHANGE | ChangeDate |  |
| 9 | Change Reason | chg_rsn | STRING | X |  |  |  | Lý do thay đổi vốn góp. | FMS.MBCHANGE | Reason |  |
| 10 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FMS.MBCHANGE | CreatedBy |  |
| 11 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.MBCHANGE | DateCreated |  |
| 12 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.MBCHANGE | DateModified |  |


#### 2.{IDX}.39.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Investment Fund Investor Capital Change Log Id | ivsm_fnd_ivsr_cptl_chg_log_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Investment Fund Investor Membership Id | ivsm_fnd_ivsr_mbr_id | Investment Fund Investor Membership | Investment Fund Investor Membership Id | ivsm_fnd_ivsr_mbr_id |




### 2.{IDX}.40 Bảng Member Periodic Report Status Log

- **Mô tả:** Nhật ký thay đổi trạng thái của báo cáo định kỳ thành viên. Mỗi dòng ghi nhận một lần thay đổi trạng thái kèm nội dung tóm tắt.
- **Tên vật lý:** mbr_prd_rpt_st_log
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Member Periodic Report History Id | mbr_prd_rpt_hist_id | BIGINT |  | X | P |  | Khóa đại diện cho lịch sử nộp báo cáo định kỳ thành viên. | FMS.RPTMBHS |  | PK surrogate. |
| 2 | Member Periodic Report History Code | mbr_prd_rpt_hist_code | STRING |  |  |  |  | Mã định danh bản ghi lịch sử. Map từ PK bảng nguồn. | FMS.RPTMBHS | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.RPTMBHS' | Mã nguồn dữ liệu. | FMS.RPTMBHS |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Member Periodic Report Id | mbr_prd_rpt_id | BIGINT |  |  | F |  | FK đến báo cáo định kỳ thành viên. | FMS.RPTMBHS | RptMbId |  |
| 5 | Member Periodic Report Code | mbr_prd_rpt_code | STRING |  |  |  |  | Mã báo cáo định kỳ. | FMS.RPTMBHS | RptMbId |  |
| 6 | Report Submission Status Code | rpt_submission_st_code | STRING | X |  |  |  | Trạng thái nộp báo cáo tại thời điểm lịch sử. | FMS.RPTMBHS | Status | Scheme: FMS_REPORT_SUBMISSION_STATUS. |
| 7 | Changed By Officer Id | changed_by_ofcr_id | BIGINT | X |  | F |  | FK đến nhân sự thực hiện thay đổi trạng thái. | FMS.RPTMBHS | ChgById |  |
| 8 | Changed By Officer Code | changed_by_ofcr_code | STRING | X |  |  |  | Mã nhân sự thực hiện thay đổi. | FMS.RPTMBHS | ChgById |  |
| 9 | Content Summary | cntnt_smy | STRING | X |  |  |  | Tóm tắt nội dung báo cáo tại thời điểm lịch sử. | FMS.RPTMBHS | ContentSummary |  |
| 10 | Note | note | STRING | X |  |  |  | Ghi chú bổ sung. | FMS.RPTMBHS | Note |  |
| 11 | Report Name | rpt_nm | STRING | X |  |  |  | Tên báo cáo tại thời điểm lịch sử. | FMS.RPTMBHS | RptName |  |


#### 2.{IDX}.40.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Member Periodic Report History Id | mbr_prd_rpt_hist_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Member Periodic Report Id | mbr_prd_rpt_id | Member Periodic Report | Member Periodic Report Id | mbr_prd_rpt_id |
| Changed By Officer Id | changed_by_ofcr_id | Fund Management Company Key Person | Fund Management Company Key Person Id | fnd_mgt_co_key_psn_id |




### 2.{IDX}.41 Bảng Report Import Value

- **Mô tả:** Dữ liệu giá trị từng ô chỉ tiêu trong sheet báo cáo được import vào hệ thống FMS. Grain ở mức cell-level.
- **Tên vật lý:** rpt_impr_val
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Member Report Value Id | mbr_rpt_val_id | BIGINT |  | X | P |  | Khóa đại diện cho giá trị chỉ tiêu trong báo cáo thành viên. | FMS.RPTVALUES |  | PK surrogate. |
| 2 | Member Report Value Code | mbr_rpt_val_code | STRING |  |  |  |  | Mã định danh giá trị chỉ tiêu. Map từ PK bảng nguồn. | FMS.RPTVALUES | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'FMS.RPTVALUES' | Mã nguồn dữ liệu. | FMS.RPTVALUES |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Member Periodic Report Id | mbr_prd_rpt_id | BIGINT |  |  | F |  | FK đến báo cáo định kỳ thành viên. | FMS.RPTVALUES | MebId |  |
| 5 | Member Periodic Report Code | mbr_prd_rpt_code | STRING |  |  |  |  | Mã báo cáo định kỳ. | FMS.RPTVALUES | MebId |  |
| 6 | Fund Management Company Id | fnd_mgt_co_id | BIGINT | X |  | F |  | FK đến công ty QLQ nộp báo cáo (nullable). | FMS.RPTVALUES | SecId |  |
| 7 | Fund Management Company Code | fnd_mgt_co_code | STRING | X |  |  |  | Mã công ty QLQ. | FMS.RPTVALUES | SecId |  |
| 8 | Investment Fund Id | ivsm_fnd_id | BIGINT | X |  | F |  | FK đến quỹ đầu tư nộp báo cáo (nullable). | FMS.RPTVALUES | FndId |  |
| 9 | Investment Fund Code | ivsm_fnd_code | STRING | X |  |  |  | Mã quỹ đầu tư. | FMS.RPTVALUES | FndId |  |
| 10 | Custodian Bank Id | cstd_bnk_id | BIGINT | X |  | F |  | FK đến ngân hàng LKGS nộp báo cáo (nullable). | FMS.RPTVALUES | BkMId |  |
| 11 | Custodian Bank Code | cstd_bnk_code | STRING | X |  |  |  | Mã ngân hàng LKGS. | FMS.RPTVALUES | BkMId |  |
| 12 | Foreign Fund Management Organization Unit Id | frgn_fnd_mgt_ou_id | BIGINT | X |  | F |  | FK đến VPĐD/CN QLQ NN nộp báo cáo (nullable). | FMS.RPTVALUES | FrBrId |  |
| 13 | Foreign Fund Management Organization Unit Code | frgn_fnd_mgt_ou_code | STRING | X |  |  |  | Mã VPĐD/CN QLQ NN. | FMS.RPTVALUES | FrBrId |  |
| 14 | Reporting Period Id | rpt_prd_id | BIGINT | X |  | F |  | FK đến kỳ báo cáo. | FMS.RPTVALUES | PrdId |  |
| 15 | Reporting Period Code | rpt_prd_code | STRING | X |  |  |  | Mã kỳ báo cáo. | FMS.RPTVALUES | PrdId |  |
| 16 | Report Sheet Id | rpt_shet_id | STRING | X |  |  |  | Mã trang/sheet trong biểu mẫu báo cáo. | FMS.RPTVALUES | SheetId |  |
| 17 | Report Target Id | rpt_trgt_id | STRING | X |  |  |  | Mã chỉ tiêu trong sheet báo cáo. | FMS.RPTVALUES | TgtId |  |
| 18 | Report Id | rpt_id | STRING | X |  |  |  | Mã biểu mẫu báo cáo. | FMS.RPTVALUES | RptId |  |
| 19 | Value | val | STRING | X |  |  |  | Giá trị chỉ tiêu (text để chứa mọi kiểu dữ liệu). | FMS.RPTVALUES | Values |  |
| 20 | Accumulated Value | acm_val | STRING | X |  |  |  | Giá trị lũy kế của chỉ tiêu. | FMS.RPTVALUES | AccValues |  |
| 21 | Format Data Type Code | fmt_data_tp_code | STRING | X |  |  |  | Kiểu dữ liệu định dạng của chỉ tiêu. | FMS.RPTVALUES | FormatDataType | Scheme: FMS_CELL_DATA_TYPE. |
| 22 | Is Dynamic Indicator | is_dynamic_ind | STRING | X |  |  |  | Cờ đánh dấu chỉ tiêu động (người dùng tự thêm). | FMS.RPTVALUES | IsDynamic |  |
| 23 | Reporting Period Type Code | rpt_prd_tp_code | STRING | X |  |  |  | Kiểu kỳ báo cáo (tháng/quý/năm). | FMS.RPTVALUES | PeriodType | Scheme: FMS_REPORTING_PERIOD_TYPE. |
| 24 | Value Type Code | val_tp_code | STRING | X |  |  |  | Loại giá trị trong báo cáo. | FMS.RPTVALUES | Type | Scheme: FMS_REPORT_VALUE_TYPE. |
| 25 | Created By | crt_by | STRING | X |  |  |  | Người tạo bản ghi. | FMS.RPTVALUES | CreatedBy |  |
| 26 | Modified By | mod_by | STRING | X |  |  |  | Người cập nhật bản ghi lần cuối. | FMS.RPTVALUES | ModifyBy |  |
| 27 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. | FMS.RPTVALUES | DateCreated |  |
| 28 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. | FMS.RPTVALUES | DateModified |  |


#### 2.{IDX}.41.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Member Report Value Id | mbr_rpt_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Member Periodic Report Id | mbr_prd_rpt_id | Member Periodic Report | Member Periodic Report Id | mbr_prd_rpt_id |
| Fund Management Company Id | fnd_mgt_co_id | Fund Management Company | Fund Management Company Id | fnd_mgt_co_id |
| Investment Fund Id | ivsm_fnd_id | Investment Fund | Investment Fund Id | ivsm_fnd_id |
| Custodian Bank Id | cstd_bnk_id | Custodian Bank | Custodian Bank Id | cstd_bnk_id |
| Foreign Fund Management Organization Unit Id | frgn_fnd_mgt_ou_id | Foreign Fund Management Organization Unit | Foreign Fund Management Organization Unit Id | frgn_fnd_mgt_ou_id |
| Reporting Period Id | rpt_prd_id | Reporting Period | Reporting Period Id | rpt_prd_id |




