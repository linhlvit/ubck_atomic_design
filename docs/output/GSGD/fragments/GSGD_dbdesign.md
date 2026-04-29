## 2.{IDX} GSGD — 

### 2.{IDX}.1 Các mô hình quan hệ dữ liệu

- DBML tổng hợp (tất cả bảng): [`GSGD.dbml`](GSGD.dbml) — paste vào https://dbdiagram.io để render.
- Diagram theo mảng nghiệp vụ:
  - **UID01 — Nhóm chức năng: Quản lý thông tin**: [`GSGD_UID01.dbml`](GSGD_UID01.dbml)
  - **UID02 — Nhóm chức năng: Phân tích chuyên sâu vụ việc**: [`GSGD_UID02.dbml`](GSGD_UID02.dbml)


**Danh sách bảng:**

| STT | Thực thể | Tên bảng | Mô tả |
|---|---|---|---|
| 1 | Investor Trading Account | ivsr_tdg_ac | Tài khoản giao dịch chứng khoán của nhà đầu tư trong hệ thống GSGD. Grain: 1 dòng = 1 tài khoản (phân biệt theo account_code từ VSDC). Bao gồm cá nhân và tổ chức, trong nước và nước ngoài. |
| 2 | Account Investor Group | ac_ivsr_grp | Nhóm tài khoản nhà đầu tư do nghiệp vụ giám sát xác định theo tiêu chí quan hệ (Danh tính / IP / MAC / Tiền). Grain: 1 dòng = 1 nhóm. |
| 3 | Securities Watchlist Group | scr_watchlist_grp | Nhóm chứng khoán do nghiệp vụ giám sát tạo ra (thường hoặc theo ngành). Danh sách mã CK denormalize thành ARRAY. |
| 4 | Market Surveillance Case | mkt_surveillance_case | Vụ việc giám sát giao dịch chứng khoán bất thường. Ghi nhận loại vụ việc, mã CK liên quan, nguồn thông tin và trạng thái xử lý. |
| 5 | Market Surveillance Analysis Criterion | mkt_surveillance_anl_criterion | Định nghĩa tiêu chí/công thức phân tích vụ việc giám sát (ngưỡng tỷ lệ, số phiên, v.v.). Grain: 1 dòng = 1 tiêu chí. |
| 6 | Abnormal Trading Report | abnormal_tdg_rpt | Báo cáo giao dịch bất thường do tổ chức thành viên nộp lên UBCKNN. Grain: 1 dòng = 1 báo cáo. |
| 7 | Market Surveillance Compliance Report Template | mkt_surveillance_cmpln_rpt_tpl | Định nghĩa loại báo cáo tuân thủ trong hệ thống GSGD (tên báo cáo, kỳ báo cáo). Grain: 1 dòng = 1 loại báo cáo. |
| 8 | Investor Trading Account Financial Service | ivsr_tdg_ac_fnc_svc | Dịch vụ tài chính đăng ký trên tài khoản giao dịch (ký quỹ / ứng trước tiền bán / HĐ tài chính khác). FK Investor Trading Account. |
| 9 | Investor Trading Account Authorization | ivsr_tdg_ac_ahr | Ủy quyền giao dịch chứng khoán trên tài khoản nhà đầu tư. FK Investor Trading Account. |
| 10 | Account Investor Group Member | ac_ivsr_grp_mbr | Quan hệ thành viên giữa tài khoản nhà đầu tư và nhóm giám sát. Ghi nhận loại quan hệ và trạng thái. FK Account Investor Group + Investor Trading Account. |
| 11 | Investor Account Relationship | ivsr_ac_rltnp | Quan hệ giữa 2 tài khoản nhà đầu tư trong giám sát (IP address, MAC address, chuyển tiền). Ghi nhận độ mạnh quan hệ. FK Investor Trading Account (x2) + Account Investor Group. |
| 12 | Listed Company Corporate Event | list_co_corp_ev | Sự kiện liên quan đến tổ chức niêm yết trong phạm vi giám sát GSGD. Grain: 1 dòng = 1 sự kiện. |
| 13 | Market Surveillance Case Document Attachment | mkt_surveillance_case_doc_attachment | File đính kèm vụ việc giám sát (tài liệu hồ sơ, danh sách TK nghi vấn). FK Market Surveillance Case. |
| 14 | Market Surveillance Case Workflow Step | mkt_surveillance_case_workflow_step | Từng bước quy trình xử lý vụ việc giám sát. Append-only. FK Market Surveillance Case. |
| 15 | Market Surveillance Case Approval Step Log | mkt_surveillance_case_aprv_step_log | Nhật ký phê duyệt từng bước xử lý vụ việc giám sát. Ghi nhận người duyệt, vai trò, trạng thái và thời điểm. FK Market Surveillance Case. |
| 16 | Market Surveillance Suspicious Account | mkt_surveillance_sspcs_ac | Tài khoản nghi vấn được xác định trong vụ việc giám sát. FK Market Surveillance Case + Investor Trading Account. |
| 17 | Market Surveillance Suspicious Account Group | mkt_surveillance_sspcs_ac_grp | Nhóm tài khoản nghi vấn trong phạm vi 1 vụ việc giám sát cụ thể. FK Market Surveillance Case. |
| 18 | Market Surveillance Analysis Criterion Value | mkt_surveillance_anl_criterion_val | Giá trị cụ thể của tiêu chí phân tích theo từng quy trình. FK Market Surveillance Analysis Criterion. |
| 19 | Market Surveillance Compliance Report Column Config | mkt_surveillance_cmpln_rpt_clmn_config | Định nghĩa cấu trúc cột của từng loại báo cáo tuân thủ GSGD. FK Market Surveillance Compliance Report Template. |
| 20 | Market Surveillance Compliance Report Instance | mkt_surveillance_cmpln_rpt_instn | Instance báo cáo tuân thủ theo từng kỳ. FK Market Surveillance Compliance Report Template. |
| 21 | Abnormal Trading Report File Attachment | abnormal_tdg_rpt_file_attachment | File đính kèm báo cáo giao dịch bất thường (có chữ ký số). FK Abnormal Trading Report. |
| 22 | Market Surveillance Compliance Report Row Data | mkt_surveillance_cmpln_rpt_row_data | Dữ liệu từng dòng trong báo cáo tuân thủ GSGD (lưu dạng JSON). Grain: 1 dòng = 1 row x 1 kỳ. FK Market Surveillance Compliance Report Instance. |
| 23 | Market Surveillance Analysis Execution Log | mkt_surveillance_anl_exec_log | Log thực thi phân tích từng biểu mẫu trong vụ việc giám sát. FK Market Surveillance Case. |
| 24 | Market Surveillance Analysis Suspicious Account Snapshot | mkt_surveillance_anl_sspcs_ac_snpst | Snapshot thông tin tài khoản nghi vấn tại thời điểm phân tích biểu mẫu. FK Market Surveillance Case. |
| 25 | Market Surveillance Suspicious Account Analysis Result | mkt_surveillance_sspcs_ac_anl_rslt | Kết quả phân tích/kiểm tra tài khoản nghi vấn trong vụ việc giám sát. FK Market Surveillance Case. |
| 26 | Market Surveillance Account Relationship Analysis Result | mkt_surveillance_ac_rltnp_anl_rslt | Kết quả phân tích quan hệ giữa tài khoản nghi vấn. FK Market Surveillance Case + Investor Account Relationship. |
| 27 | Market Surveillance Account Group Analysis Result | mkt_surveillance_ac_grp_anl_rslt | Kết quả phân tích nhóm tài khoản nghi vấn. FK Market Surveillance Case. |
| 28 | Market Surveillance Account Group Member Analysis Result | mkt_surveillance_ac_grp_mbr_anl_rslt | Thành viên nhóm tài khoản trong kết quả phân tích. FK Market Surveillance Case + Investor Account Relationship. |
| 29 | Market Surveillance Analysis Report | mkt_surveillance_anl_rpt | Báo cáo output của quá trình phân tích vụ việc giám sát (report_type |



### 2.{IDX}.2 Bảng Investor Trading Account

- **Mô tả:** Tài khoản giao dịch chứng khoán của nhà đầu tư trong hệ thống GSGD. Grain: 1 dòng = 1 tài khoản (phân biệt theo account_code từ VSDC). Bao gồm cá nhân và tổ chức, trong nước và nước ngoài.
- **Tên vật lý:** ivsr_tdg_ac
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Investor Trading Account Id | ivsr_tdg_ac_id | BIGINT |  | X | P |  | Khóa đại diện cho tài khoản giao dịch chứng khoán. | GSGD.investor_account |  |  |
| 2 | Investor Trading Account Code | ivsr_tdg_ac_code | STRING |  |  |  |  | Số tài khoản (từ VSDC). BK. | GSGD.investor_account | account_code | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.investor_account' | Mã nguồn dữ liệu. | GSGD.investor_account |  |  |
| 4 | Account Name | ac_nm | STRING | X |  |  |  | Họ và tên nhà đầu tư. | GSGD.investor_account | account_name |  |
| 5 | Investor Type Code | ivsr_tp_code | STRING | X |  |  |  | Loại hình NĐT: 1=Cá nhân, 2=Tổ chức. | GSGD.investor_account | investor_type | Scheme: GSGD_INVESTOR_TYPE. |
| 6 | Open Date | opn_dt | DATE | X |  |  |  | Ngày mở tài khoản. | GSGD.investor_account | open_date |  |
| 7 | Close Date | cls_dt | DATE | X |  |  |  | Ngày đóng tài khoản. | GSGD.investor_account | close_date |  |
| 8 | Account Status Code | ac_st_code | STRING | X |  |  |  | Trạng thái: 0=Đóng, 1=Mở. | GSGD.investor_account | account_status | Scheme: GSGD_ACCOUNT_STATUS. |
| 9 | Domestic Foreign Flag | dmst_frgn_f | STRING | X |  |  |  | Trong nước/Nước ngoài: 0=Trong nước, 1=Nước ngoài. | GSGD.investor_account | domestic_foreign_flag | Scheme: GSGD_DOMESTIC_FOREIGN_FLAG. |
| 10 | Nationality | nationality | STRING | X |  |  |  | Quốc tịch. Lưu dạng text denormalized — không có bảng lookup địa lý trong scope GSGD. | GSGD.investor_account | nationality |  |
| 11 | Date of Birth | dob | DATE | X |  |  |  | Ngày tháng năm sinh/ngày thành lập DN (từ CTCK, có thể sửa). | GSGD.investor_account | date_of_birth |  |
| 12 | Legal Representative | lgl_representative | STRING | X |  |  |  | Người đại diện theo pháp luật (từ CTCK, có thể sửa). | GSGD.investor_account | legal_representative |  |
| 13 | Identity Number | identity_nbr | STRING | X |  |  |  | Số CCCD/Số đăng ký sở hữu. Denormalized — grain = 1 tài khoản. | GSGD.investor_account | identity_number |  |
| 14 | Identity Issue Date | identity_issu_dt | DATE | X |  |  |  | Ngày cấp giấy tờ định danh. | GSGD.investor_account | identity_issue_date |  |
| 15 | Identity Issue Place | identity_issu_plc | STRING | X |  |  |  | Nơi cấp giấy tờ định danh. | GSGD.investor_account | identity_issue_place |  |
| 16 | Contact Address | ctc_adr | STRING | X |  |  |  | Địa chỉ liên lạc (từ CTCK, có thể sửa). Denormalized — grain = 1 tài khoản. | GSGD.investor_account | contact_address |  |
| 17 | Permanent Address | perm_adr | STRING | X |  |  |  | Địa chỉ thường trú (từ CTCK, có thể sửa). Denormalized — grain = 1 tài khoản. | GSGD.investor_account | permanent_address |  |
| 18 | Phone Number | ph_nbr | STRING | X |  |  |  | Số điện thoại (từ CTCK, có thể sửa). Denormalized — grain = 1 tài khoản. | GSGD.investor_account | phone_number |  |
| 19 | Email | email | STRING | X |  |  |  | Email (từ CTCK, có thể sửa). Denormalized — grain = 1 tài khoản. | GSGD.investor_account | email |  |
| 20 | Bank Account Holder Name | bnk_ac_hldr_nm | STRING | X |  |  |  | Tên chủ tài khoản ngân hàng (từ CTCK, có thể sửa). | GSGD.investor_account | bank_account_holder_name |  |
| 21 | Bank Account Number | bnk_ac_nbr | STRING | X |  |  |  | Số tài khoản ngân hàng (từ CTCK, có thể sửa). | GSGD.investor_account | bank_account_number |  |
| 22 | Bank Account Name | bnk_ac_nm | STRING | X |  |  |  | Tên ngân hàng (từ CTCK, có thể sửa). | GSGD.investor_account | bank_account_name |  |
| 23 | Margin Account Open Date | mrgn_ac_opn_dt | DATE | X |  |  |  | Ngày mở tài khoản ký quỹ. | GSGD.investor_account | margin_account_open_date |  |
| 24 | Margin Service Enabled | mrgn_svc_enabled | BOOLEAN | X |  |  |  | Dịch vụ tài chính sử dụng — Ký quỹ. | GSGD.investor_account | margin_service_enabled |  |
| 25 | Advance Payment Service Enabled | advnc_pymt_svc_enabled | BOOLEAN | X |  |  |  | Dịch vụ tài chính sử dụng — Ứng trước tiền bán. | GSGD.investor_account | advance_payment_service_enabled |  |
| 26 | Account Authorization Enabled | ac_ahr_enabled | BOOLEAN | X |  |  |  | Dịch vụ tài chính sử dụng — Hợp đồng tài chính khác. | GSGD.investor_account | account_authorization_enabled |  |
| 27 | Authorized Person Name | authorized_psn_nm | STRING | X |  |  |  | Người nhận ủy quyền (denormalized từ account_authorization). | GSGD.investor_account | authorized_person_name |  |
| 28 | Authorization Date | ahr_dt | DATE | X |  |  |  | Ngày nhận ủy quyền (denormalized từ account_authorization). | GSGD.investor_account | authorization_date |  |
| 29 | Approval Status Code | aprv_st_code | STRING | X |  |  |  | Trạng thái phê duyệt tài khoản. | GSGD.investor_account | approval_status | Scheme: GSGD_APPROVAL_STATUS. |
| 30 | Data Source Code | data_src_code | STRING | X |  |  |  | Nguồn dữ liệu chính: VSDC, CTCK. | GSGD.investor_account | data_source | Scheme: GSGD_DATA_SOURCE. Cần profile giá trị thực tế. |
| 31 | Last Modified Date | last_mod_dt | DATE | X |  |  |  | Ngày thay đổi thông tin lần cuối. | GSGD.investor_account | last_modified_date |  |


#### 2.{IDX}.2.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Investor Trading Account Id | ivsr_tdg_ac_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.3 Bảng Account Investor Group

- **Mô tả:** Nhóm tài khoản nhà đầu tư do nghiệp vụ giám sát xác định theo tiêu chí quan hệ (Danh tính / IP / MAC / Tiền). Grain: 1 dòng = 1 nhóm.
- **Tên vật lý:** ac_ivsr_grp
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Account Investor Group Id | ac_ivsr_grp_id | BIGINT |  | X | P |  | Khóa đại diện cho nhóm tài khoản nhà đầu tư. | GSGD.account_group |  |  |
| 2 | Account Investor Group Code | ac_ivsr_grp_code | STRING |  |  |  |  | Mã nhóm (hệ thống tự sinh). BK. | GSGD.account_group | group_code | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.account_group' | Mã nguồn dữ liệu. | GSGD.account_group |  |  |
| 4 | Group Name | grp_nm | STRING | X |  |  |  | Tên nhóm. | GSGD.account_group | group_name |  |
| 5 | Group Type Code | grp_tp_code | STRING | X |  |  |  | Loại nhóm: 1=Thường, 2=Nghi vấn. | GSGD.account_group | group_type | Scheme: GSGD_ACCOUNT_GROUP_TYPE. |


#### 2.{IDX}.3.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Account Investor Group Id | ac_ivsr_grp_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.4 Bảng Securities Watchlist Group

- **Mô tả:** Nhóm chứng khoán do nghiệp vụ giám sát tạo ra (thường hoặc theo ngành). Danh sách mã CK denormalize thành ARRAY.
- **Tên vật lý:** scr_watchlist_grp
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Securities Watchlist Group Id | scr_watchlist_grp_id | BIGINT |  | X | P |  | Khóa đại diện cho nhóm chứng khoán giám sát. | GSGD.securities_group |  |  |
| 2 | Securities Watchlist Group Code | scr_watchlist_grp_code | STRING |  |  |  |  | Mã nhóm (hệ thống tự sinh). BK. | GSGD.securities_group | group_code | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.securities_group' | Mã nguồn dữ liệu. | GSGD.securities_group |  |  |
| 4 | Group Name | grp_nm | STRING | X |  |  |  | Tên nhóm chứng khoán. | GSGD.securities_group | group_name |  |
| 5 | Group Type Code | grp_tp_code | STRING | X |  |  |  | Loại nhóm: 1=Thường, 2=Theo ngành. | GSGD.securities_group | group_type | Scheme: GSGD_SECURITIES_GROUP_TYPE. |
| 6 | Description | dsc | STRING | X |  |  |  | Mô tả nhóm. | GSGD.securities_group | description |  |
| 7 | Group Status Code | grp_st_code | STRING | X |  |  |  | Trạng thái: 1=Chờ duyệt, 2=Phê duyệt, 3=Từ chối. | GSGD.securities_group | status | Scheme: GSGD_GROUP_STATUS. Cần profile giá trị thực tế. |
| 8 | Securities Codes | scr_codes | Array<Text> | X |  |  |  | Danh sách mã chứng khoán trong nhóm. Denormalized từ bảng junction securities_group_member. | GSGD.securities_group | securities_code_id |  |


#### 2.{IDX}.4.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Securities Watchlist Group Id | scr_watchlist_grp_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.5 Bảng Market Surveillance Case

- **Mô tả:** Vụ việc giám sát giao dịch chứng khoán bất thường. Ghi nhận loại vụ việc, mã CK liên quan, nguồn thông tin và trạng thái xử lý.
- **Tên vật lý:** mkt_surveillance_case
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Market Surveillance Case Id | mkt_surveillance_case_id | BIGINT |  | X | P |  | Khóa đại diện cho vụ việc giám sát giao dịch. | GSGD.case_file |  |  |
| 2 | Market Surveillance Case Code | mkt_surveillance_case_code | STRING |  |  |  |  | Mã vụ việc (tự sinh: MãCK+DDMMYYYY). BK. | GSGD.case_file | case_file_code | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.case_file' | Mã nguồn dữ liệu. | GSGD.case_file |  |  |
| 4 | Case Type Code | case_tp_code | STRING | X |  |  |  | Loại vụ việc (Sơ bộ / Thao túng / Nội gián / Liên thị trường). | GSGD.case_file | case_file_type | Scheme: GSGD_CASE_TYPE. |
| 5 | Securities Code | scr_code | STRING | X |  |  |  | Mã chứng khoán liên quan. Denormalized — bảng securities_code ngoài scope GSGD. | GSGD.case_file | securities_code |  |
| 6 | Information Source Code | inf_src_code | STRING | X |  |  |  | Nguồn thông tin vụ việc. | GSGD.case_file | information_source | Scheme: GSGD_INFORMATION_SOURCE. |
| 7 | Information Source Detail | inf_src_dtl | STRING | X |  |  |  | Nguồn thông tin chi tiết. | GSGD.case_file | information_source_detail |  |
| 8 | Start Date | strt_dt | DATE | X |  |  |  | Ngày bắt đầu vụ việc. | GSGD.case_file | start_date |  |
| 9 | End Date | end_dt | DATE | X |  |  |  | Ngày kết thúc vụ việc. | GSGD.case_file | end_date |  |
| 10 | Completion Date | compl_dt | DATE | X |  |  |  | Thời gian hoàn thành vụ việc. | GSGD.case_file | completion_date |  |
| 11 | Assigned To | asgn_to | STRING | X |  |  |  | Người được phân công xử lý vụ việc. | GSGD.case_file | assigned_to |  |
| 12 | Case Status Code | case_st_code | STRING | X |  |  |  | Trạng thái vụ việc. | GSGD.case_file | case_file_status | Scheme: GSGD_CASE_STATUS. |
| 13 | Notes | notes | STRING | X |  |  |  | Ghi chú vụ việc. | GSGD.case_file | notes |  |


#### 2.{IDX}.5.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Market Surveillance Case Id | mkt_surveillance_case_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.6 Bảng Market Surveillance Analysis Criterion

- **Mô tả:** Định nghĩa tiêu chí/công thức phân tích vụ việc giám sát (ngưỡng tỷ lệ, số phiên, v.v.). Grain: 1 dòng = 1 tiêu chí.
- **Tên vật lý:** mkt_surveillance_anl_criterion
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Market Surveillance Analysis Criterion Id | mkt_surveillance_anl_criterion_id | BIGINT |  | X | P |  | Khóa đại diện cho tiêu chí phân tích giám sát. | GSGD.analysis_attribute_define |  |  |
| 2 | Market Surveillance Analysis Criterion Code | mkt_surveillance_anl_criterion_code | STRING |  |  |  |  | Mã tiêu chí (ví dụ: CT_01_THRESHOLD_A). BK. | GSGD.analysis_attribute_define | attribute_code | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.analysis_attribute_define' | Mã nguồn dữ liệu. | GSGD.analysis_attribute_define |  |  |
| 4 | Criterion Name | criterion_nm | STRING |  |  |  |  | Tên hiển thị tiêu chí (ví dụ: Tỷ trọng đặt/khớp lệnh > A% trong X ngày). | GSGD.analysis_attribute_define | attribute_name |  |
| 5 | Description | dsc | STRING | X |  |  |  | Mô tả chi tiết tiêu chí, dùng cho BA/SA. | GSGD.analysis_attribute_define | description |  |
| 6 | Workflow Type Code | workflow_tp_code | STRING | X |  |  |  | Quy trình áp dụng: 1=Sơ bộ, 2=Thao túng, 3=Nội gián, 4=Liên thị trường. | GSGD.analysis_attribute_define | workflow_type | Scheme: GSGD_WORKFLOW_TYPE. |
| 7 | Data Type Code | data_tp_code | STRING | X |  |  |  | Kiểu dữ liệu: NUMBER, STRING, DATE, BOOLEAN. | GSGD.analysis_attribute_define | data_type | Scheme: GSGD_DATA_TYPE. |
| 8 | Default Value | dflt_val | STRING | X |  |  |  | Giá trị mặc định (lưu dạng text, parse theo data_type). | GSGD.analysis_attribute_define | default_value |  |
| 9 | Min Value | min_val | STRING | X |  |  |  | Giá trị tối thiểu (nếu là NUMBER/DATE). | GSGD.analysis_attribute_define | min_value |  |
| 10 | Max Value | max_val | STRING | X |  |  |  | Giá trị tối đa (nếu là NUMBER/DATE). | GSGD.analysis_attribute_define | max_value |  |
| 11 | Unit | unit | STRING | X |  |  |  | Đơn vị: %, ngày, phiên,... | GSGD.analysis_attribute_define | unit |  |
| 12 | Step | step | STRING | X |  |  |  | Bước nhảy cho slider (nếu áp dụng). | GSGD.analysis_attribute_define | step |  |
| 13 | Display Group | dspl_grp | STRING | X |  |  |  | Nhóm hiển thị trên màn hình (ví dụ: Tham số cấu hình báo cáo). | GSGD.analysis_attribute_define | display_group |  |
| 14 | Display Order | dspl_ordr | INT | X |  |  |  | Thứ tự hiển thị. | GSGD.analysis_attribute_define | display_order |  |
| 15 | Active Flag | actv_f | BOOLEAN | X |  |  |  | Trạng thái sử dụng: 0=Không dùng, 1=Đang dùng. | GSGD.analysis_attribute_define | active_flag |  |


#### 2.{IDX}.6.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Market Surveillance Analysis Criterion Id | mkt_surveillance_anl_criterion_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.7 Bảng Abnormal Trading Report

- **Mô tả:** Báo cáo giao dịch bất thường do tổ chức thành viên nộp lên UBCKNN. Grain: 1 dòng = 1 báo cáo.
- **Tên vật lý:** abnormal_tdg_rpt
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Abnormal Trading Report Id | abnormal_tdg_rpt_id | BIGINT |  | X | P |  | Khóa đại diện cho báo cáo giao dịch bất thường. | GSGD.abnormal_report |  |  |
| 2 | Abnormal Trading Report Code | abnormal_tdg_rpt_code | STRING |  |  |  |  | Mã báo cáo. BK. | GSGD.abnormal_report | report_code | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.abnormal_report' | Mã nguồn dữ liệu. | GSGD.abnormal_report |  |  |
| 4 | Report Name | rpt_nm | STRING | X |  |  |  | Tên báo cáo. | GSGD.abnormal_report | report_name |  |
| 5 | Report Type Code | rpt_tp_code | STRING | X |  |  |  | Loại báo cáo bất thường. | GSGD.abnormal_report | report_type | Scheme: GSGD_ABNORMAL_REPORT_TYPE. |
| 6 | Period Type Code | prd_tp_code | STRING | X |  |  |  | Loại kỳ báo cáo. | GSGD.abnormal_report | period_type | Scheme: GSGD_PERIOD_TYPE. |
| 7 | Period Value | prd_val | STRING | X |  |  |  | Giá trị kỳ báo cáo (ví dụ: tháng 1 = 1). | GSGD.abnormal_report | period_value |  |
| 8 | Period Year | prd_yr | INT | X |  |  |  | Năm kỳ báo cáo. | GSGD.abnormal_report | period_year |  |
| 9 | Submitter Type Code | submitter_tp_code | STRING | X |  |  |  | Loại người nộp (Tổ chức / Cá nhân). | GSGD.abnormal_report | submitter_type | Scheme: GSGD_SUBMITTER_TYPE. |
| 10 | Submitter Id | submitter_id | STRING | X |  |  |  | Mã người/tổ chức nộp báo cáo. Denormalized — không có FK tường minh đến entity Silver. | GSGD.abnormal_report | submitter_id |  |
| 11 | Submitter Name | submitter_nm | STRING | X |  |  |  | Tên người/tổ chức nộp báo cáo. | GSGD.abnormal_report | submitter_name |  |
| 12 | Submission Date | submission_dt | DATE | X |  |  |  | Ngày nộp báo cáo. | GSGD.abnormal_report | submission_date |  |
| 13 | Approval Status Code | aprv_st_code | STRING | X |  |  |  | Trạng thái: 0=Chờ duyệt, 1=Đã duyệt, 2=Từ chối, 3=Yêu cầu nộp lại. | GSGD.abnormal_report | approval_status | Scheme: GSGD_APPROVAL_STATUS. |
| 14 | Approval Date | aprv_dt | DATE | X |  |  |  | Ngày duyệt báo cáo. | GSGD.abnormal_report | approval_date |  |
| 15 | Approver | approver | STRING | X |  |  |  | Người duyệt. | GSGD.abnormal_report | approver |  |
| 16 | Rejection Reason | rejection_rsn | STRING | X |  |  |  | Lý do từ chối. | GSGD.abnormal_report | rejection_reason |  |


#### 2.{IDX}.7.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Abnormal Trading Report Id | abnormal_tdg_rpt_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.8 Bảng Market Surveillance Compliance Report Template

- **Mô tả:** Định nghĩa loại báo cáo tuân thủ trong hệ thống GSGD (tên báo cáo, kỳ báo cáo). Grain: 1 dòng = 1 loại báo cáo.
- **Tên vật lý:** mkt_surveillance_cmpln_rpt_tpl
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Market Surveillance Compliance Report Template Id | mkt_surveillance_cmpln_rpt_tpl_id | BIGINT |  | X | P |  | Khóa đại diện cho mẫu báo cáo tuân thủ giám sát. | GSGD.compliance_report_template |  |  |
| 2 | Market Surveillance Compliance Report Template Code | mkt_surveillance_cmpln_rpt_tpl_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.compliance_report_template | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.compliance_report_template' | Mã nguồn dữ liệu. | GSGD.compliance_report_template |  |  |
| 4 | Template Name | tpl_nm | STRING |  |  |  |  | Tên báo cáo tuân thủ. | GSGD.compliance_report_template | template_name |  |
| 5 | Period Type Code | prd_tp_code | STRING | X |  |  |  | Loại kỳ báo cáo. | GSGD.compliance_report_template | period_type | Scheme: GSGD_PERIOD_TYPE. |


#### 2.{IDX}.8.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Market Surveillance Compliance Report Template Id | mkt_surveillance_cmpln_rpt_tpl_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.9 Bảng Investor Trading Account Financial Service

- **Mô tả:** Dịch vụ tài chính đăng ký trên tài khoản giao dịch (ký quỹ / ứng trước tiền bán / HĐ tài chính khác). FK Investor Trading Account.
- **Tên vật lý:** ivsr_tdg_ac_fnc_svc
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Investor Trading Account Financial Service Id | ivsr_tdg_ac_fnc_svc_id | BIGINT |  | X | P |  | Khóa đại diện cho dịch vụ tài chính của tài khoản. | GSGD.account_financial_service |  |  |
| 2 | Investor Trading Account Financial Service Code | ivsr_tdg_ac_fnc_svc_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.account_financial_service | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.account_financial_service' | Mã nguồn dữ liệu. | GSGD.account_financial_service |  |  |
| 4 | Investor Trading Account Id | ivsr_tdg_ac_id | BIGINT |  |  | F |  | FK đến tài khoản giao dịch chứng khoán. | GSGD.account_financial_service | account_id |  |
| 5 | Investor Trading Account Code | ivsr_tdg_ac_code | STRING |  |  |  |  | Mã tài khoản giao dịch. Denormalized. | GSGD.account_financial_service | account_id |  |
| 6 | Service Type Code | svc_tp_code | STRING |  |  |  |  | Loại dịch vụ: 1=Ký quỹ, 2=Ứng trước tiền bán, 3=HĐ tài chính khác. | GSGD.account_financial_service | service_type | Scheme: GSGD_FINANCIAL_SERVICE_TYPE. |
| 7 | Contract Number | ctr_nbr | STRING | X |  |  |  | Số hợp đồng. | GSGD.account_financial_service | contract_number |  |
| 8 | Contract Date | ctr_dt | DATE | X |  |  |  | Ngày ký hợp đồng. | GSGD.account_financial_service | contract_date |  |


#### 2.{IDX}.9.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Investor Trading Account Financial Service Id | ivsr_tdg_ac_fnc_svc_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Investor Trading Account Id | ivsr_tdg_ac_id | Investor Trading Account | Investor Trading Account Id | ivsr_tdg_ac_id |




### 2.{IDX}.10 Bảng Investor Trading Account Authorization

- **Mô tả:** Ủy quyền giao dịch chứng khoán trên tài khoản nhà đầu tư. FK Investor Trading Account.
- **Tên vật lý:** ivsr_tdg_ac_ahr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Investor Trading Account Authorization Id | ivsr_tdg_ac_ahr_id | BIGINT |  | X | P |  | Khóa đại diện cho ủy quyền tài khoản giao dịch. | GSGD.account_authorization |  |  |
| 2 | Investor Trading Account Authorization Code | ivsr_tdg_ac_ahr_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.account_authorization | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.account_authorization' | Mã nguồn dữ liệu. | GSGD.account_authorization |  |  |
| 4 | Investor Trading Account Id | ivsr_tdg_ac_id | BIGINT |  |  | F |  | FK đến tài khoản giao dịch chứng khoán. | GSGD.account_authorization | account_id |  |
| 5 | Investor Trading Account Code | ivsr_tdg_ac_code | STRING |  |  |  |  | Mã tài khoản giao dịch. Denormalized. | GSGD.account_authorization | account_id |  |
| 6 | Authorized Person Name | authorized_psn_nm | STRING | X |  |  |  | Người nhận ủy quyền. | GSGD.account_authorization | authorized_person_name |  |
| 7 | Authorization Date | ahr_dt | DATE | X |  |  |  | Ngày nhận ủy quyền. | GSGD.account_authorization | authorization_date |  |


#### 2.{IDX}.10.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Investor Trading Account Authorization Id | ivsr_tdg_ac_ahr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Investor Trading Account Id | ivsr_tdg_ac_id | Investor Trading Account | Investor Trading Account Id | ivsr_tdg_ac_id |




### 2.{IDX}.11 Bảng Account Investor Group Member

- **Mô tả:** Quan hệ thành viên giữa tài khoản nhà đầu tư và nhóm giám sát. Ghi nhận loại quan hệ và trạng thái. FK Account Investor Group + Investor Trading Account.
- **Tên vật lý:** ac_ivsr_grp_mbr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Account Investor Group Member Id | ac_ivsr_grp_mbr_id | BIGINT |  | X | P |  | Khóa đại diện cho thành viên nhóm tài khoản. | GSGD.account_group_member |  |  |
| 2 | Account Investor Group Member Code | ac_ivsr_grp_mbr_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.account_group_member | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.account_group_member' | Mã nguồn dữ liệu. | GSGD.account_group_member |  |  |
| 4 | Account Investor Group Id | ac_ivsr_grp_id | BIGINT |  |  | F |  | FK đến nhóm tài khoản. | GSGD.account_group_member | group_id |  |
| 5 | Account Investor Group Code | ac_ivsr_grp_code | STRING |  |  |  |  | Mã nhóm tài khoản. Denormalized. | GSGD.account_group_member | group_id |  |
| 6 | Investor Trading Account Id | ivsr_tdg_ac_id | BIGINT |  |  | F |  | FK đến tài khoản giao dịch chứng khoán. | GSGD.account_group_member | account_id |  |
| 7 | Investor Trading Account Code | ivsr_tdg_ac_code | STRING |  |  |  |  | Mã tài khoản giao dịch. Denormalized. | GSGD.account_group_member | account_id |  |
| 8 | Member Status Code | mbr_st_code | STRING | X |  |  |  | Trạng thái tài khoản trong nhóm. | GSGD.account_group_member | status | Scheme: GSGD_ACCOUNT_STATUS. |
| 9 | Relationship Type | rltnp_tp | STRING | X |  |  |  | Mối quan hệ: Danh tính, IP, MAC, Tiền. | GSGD.account_group_member | relationship_type |  |


#### 2.{IDX}.11.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Account Investor Group Member Id | ac_ivsr_grp_mbr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Account Investor Group Id | ac_ivsr_grp_id | Account Investor Group | Account Investor Group Id | ac_ivsr_grp_id |
| Investor Trading Account Id | ivsr_tdg_ac_id | Investor Trading Account | Investor Trading Account Id | ivsr_tdg_ac_id |




### 2.{IDX}.12 Bảng Investor Account Relationship

- **Mô tả:** Quan hệ giữa 2 tài khoản nhà đầu tư trong giám sát (IP address, MAC address, chuyển tiền). Ghi nhận độ mạnh quan hệ. FK Investor Trading Account (x2) + Account Investor Group.
- **Tên vật lý:** ivsr_ac_rltnp
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Investor Account Relationship Id | ivsr_ac_rltnp_id | BIGINT |  | X | P |  | Khóa đại diện cho mối quan hệ giữa các tài khoản nhà đầu tư. | GSGD.account_relationship |  |  |
| 2 | Investor Account Relationship Code | ivsr_ac_rltnp_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.account_relationship | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.account_relationship' | Mã nguồn dữ liệu. | GSGD.account_relationship |  |  |
| 4 | First Investor Trading Account Id | frst_ivsr_tdg_ac_id | BIGINT |  |  | F |  | FK đến tài khoản giao dịch thứ nhất. | GSGD.account_relationship | account_id_1 |  |
| 5 | First Investor Trading Account Code | frst_ivsr_tdg_ac_code | STRING |  |  |  |  | Mã tài khoản giao dịch thứ nhất. Denormalized. | GSGD.account_relationship | account_id_1 |  |
| 6 | Second Investor Trading Account Id | scd_ivsr_tdg_ac_id | BIGINT |  |  | F |  | FK đến tài khoản giao dịch thứ hai. | GSGD.account_relationship | account_id_2 |  |
| 7 | Second Investor Trading Account Code | scd_ivsr_tdg_ac_code | STRING |  |  |  |  | Mã tài khoản giao dịch thứ hai. Denormalized. | GSGD.account_relationship | account_id_2 |  |
| 8 | Account Investor Group Id | ac_ivsr_grp_id | BIGINT | X |  | F |  | FK đến nhóm tài khoản. | GSGD.account_relationship | account_group_id |  |
| 9 | Account Investor Group Code | ac_ivsr_grp_code | STRING | X |  |  |  | Mã nhóm tài khoản. Denormalized. | GSGD.account_relationship | account_group_id |  |
| 10 | Relation Type Code | relation_tp_code | STRING | X |  | F |  | Loại quan hệ (Danh tính / IP / MAC / Tiền). | GSGD.account_relationship | category_item_id | Scheme: GSGD_ACCOUNT_RELATION_TYPE. FK suy luận → category_item. |
| 11 | Relationship Value | rltnp_val | STRING | X |  |  |  | Giá trị quan hệ (IP address, MAC address, etc.). | GSGD.account_relationship | relationship_value |  |
| 12 | Strength | strength | INT | X |  |  |  | Độ mạnh quan hệ (1-100). Điểm tính — không phải %. | GSGD.account_relationship | strength |  |


#### 2.{IDX}.12.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Investor Account Relationship Id | ivsr_ac_rltnp_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| First Investor Trading Account Id | frst_ivsr_tdg_ac_id | Investor Trading Account | Investor Trading Account Id | ivsr_tdg_ac_id |
| Second Investor Trading Account Id | scd_ivsr_tdg_ac_id | Investor Trading Account | Investor Trading Account Id | ivsr_tdg_ac_id |
| Account Investor Group Id | ac_ivsr_grp_id | Account Investor Group | Account Investor Group Id | ac_ivsr_grp_id |




### 2.{IDX}.13 Bảng Listed Company Corporate Event

- **Mô tả:** Sự kiện liên quan đến tổ chức niêm yết trong phạm vi giám sát GSGD. Grain: 1 dòng = 1 sự kiện.
- **Tên vật lý:** list_co_corp_ev
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Listed Company Corporate Event Id | list_co_corp_ev_id | BIGINT |  | X | P |  | Khóa đại diện cho sự kiện tổ chức niêm yết. | GSGD.company_event |  |  |
| 2 | Listed Company Corporate Event Code | list_co_corp_ev_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.company_event | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.company_event' | Mã nguồn dữ liệu. | GSGD.company_event |  |  |
| 4 | Company Name | co_nm | STRING | X |  |  |  | Tên tổ chức niêm yết. Denormalized — không có FK tường minh đến entity niêm yết. | GSGD.company_event | company_name |  |
| 5 | Stock Code | stk_code | STRING | X |  |  |  | Mã chứng khoán. Denormalized — không có FK tường minh. | GSGD.company_event | stock_code |  |
| 6 | Event Type Code | ev_tp_code | STRING | X |  | F |  | Loại sự kiện tổ chức niêm yết. | GSGD.company_event | event_type_id | Scheme: GSGD_COMPANY_EVENT_TYPE. FK suy luận → category_item. |
| 7 | Event Id | ev_id | STRING | X |  |  |  | Định danh sự kiện. Denormalized — không rõ FK đến đâu. | GSGD.company_event | event_id |  |
| 8 | Event Date | ev_dt | DATE | X |  |  |  | Ngày sự kiện. | GSGD.company_event | event_date |  |
| 9 | Approval Status Code | aprv_st_code | STRING | X |  |  |  | Trạng thái phê duyệt. | GSGD.company_event | approval_status | Scheme: GSGD_APPROVAL_STATUS. |


#### 2.{IDX}.13.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Listed Company Corporate Event Id | list_co_corp_ev_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.14 Bảng Market Surveillance Case Document Attachment

- **Mô tả:** File đính kèm vụ việc giám sát (tài liệu hồ sơ, danh sách TK nghi vấn). FK Market Surveillance Case.
- **Tên vật lý:** mkt_surveillance_case_doc_attachment
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Market Surveillance Case Document Attachment Id | mkt_surveillance_case_doc_attachment_id | BIGINT |  | X | P |  | Khóa đại diện cho file đính kèm vụ việc giám sát. | GSGD.case_attach_file |  |  |
| 2 | Market Surveillance Case Document Attachment Code | mkt_surveillance_case_doc_attachment_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.case_attach_file | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.case_attach_file' | Mã nguồn dữ liệu. | GSGD.case_attach_file |  |  |
| 4 | Market Surveillance Case Id | mkt_surveillance_case_id | BIGINT |  |  | F |  | FK đến vụ việc giám sát. | GSGD.case_attach_file | case_file_id |  |
| 5 | Market Surveillance Case Code | mkt_surveillance_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. | GSGD.case_attach_file | case_file_id |  |
| 6 | File Name | file_nm | STRING | X |  |  |  | Tên file đính kèm. | GSGD.case_attach_file | file_name |  |
| 7 | File Path | file_path | STRING | X |  |  |  | Đường dẫn file. | GSGD.case_attach_file | file_path |  |
| 8 | File Size | file_sz | STRING | X |  |  |  | Kích thước file (bytes). | GSGD.case_attach_file | file_size |  |
| 9 | File Type Code | file_tp_code | STRING | X |  |  |  | Loại file: CSV, XLSX, PDF. | GSGD.case_attach_file | file_type | Scheme: GSGD_FILE_TYPE. |
| 10 | File Group Code | file_grp_code | STRING | X |  |  |  | Nhóm file: 1=Hồ sơ của Sở, 2=Danh sách tài khoản nghi vấn. | GSGD.case_attach_file | file_group | Scheme: GSGD_FILE_GROUP. |


#### 2.{IDX}.14.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Market Surveillance Case Document Attachment Id | mkt_surveillance_case_doc_attachment_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Market Surveillance Case Id | mkt_surveillance_case_id | Market Surveillance Case | Market Surveillance Case Id | mkt_surveillance_case_id |




### 2.{IDX}.15 Bảng Market Surveillance Case Workflow Step

- **Mô tả:** Từng bước quy trình xử lý vụ việc giám sát. Append-only. FK Market Surveillance Case.
- **Tên vật lý:** mkt_surveillance_case_workflow_step
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Market Surveillance Case Workflow Step Id | mkt_surveillance_case_workflow_step_id | BIGINT |  | X | P |  | Khóa đại diện cho bước quy trình xử lý vụ việc. | GSGD.case_file_workflow |  |  |
| 2 | Market Surveillance Case Workflow Step Code | mkt_surveillance_case_workflow_step_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.case_file_workflow | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.case_file_workflow' | Mã nguồn dữ liệu. | GSGD.case_file_workflow |  |  |
| 4 | Market Surveillance Case Id | mkt_surveillance_case_id | BIGINT |  |  | F |  | FK đến vụ việc giám sát. | GSGD.case_file_workflow | case_file_id |  |
| 5 | Market Surveillance Case Code | mkt_surveillance_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. | GSGD.case_file_workflow | case_file_id |  |
| 6 | Workflow Type Code | workflow_tp_code | STRING |  |  |  |  | Loại quy trình: 1=Sơ bộ, 2=Thao túng, 3=Nội gián, 4=Liên thị trường. | GSGD.case_file_workflow | workflow_type | Scheme: GSGD_WORKFLOW_TYPE. |
| 7 | Step Order | step_ordr | INT | X |  |  |  | Thứ tự bước trong quy trình. | GSGD.case_file_workflow | step_order |  |
| 8 | Step Name | step_nm | STRING | X |  |  |  | Tên bước quy trình. | GSGD.case_file_workflow | step_name |  |
| 9 | Step Status Code | step_st_code | STRING | X |  |  |  | Trạng thái bước: 0=Chưa thực hiện, 1=Đang thực hiện, 2=Hoàn thành. | GSGD.case_file_workflow | status | Scheme: GSGD_APPROVAL_STEP_STATUS. |


#### 2.{IDX}.15.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Market Surveillance Case Workflow Step Id | mkt_surveillance_case_workflow_step_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Market Surveillance Case Id | mkt_surveillance_case_id | Market Surveillance Case | Market Surveillance Case Id | mkt_surveillance_case_id |




### 2.{IDX}.16 Bảng Market Surveillance Case Approval Step Log

- **Mô tả:** Nhật ký phê duyệt từng bước xử lý vụ việc giám sát. Ghi nhận người duyệt, vai trò, trạng thái và thời điểm. FK Market Surveillance Case.
- **Tên vật lý:** mkt_surveillance_case_aprv_step_log
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Market Surveillance Case Approval Step Log Id | mkt_surveillance_case_aprv_step_log_id | BIGINT |  | X | P |  | Khóa đại diện cho bước phê duyệt vụ việc giám sát. | GSGD.case_approval_step |  |  |
| 2 | Market Surveillance Case Approval Step Log Code | mkt_surveillance_case_aprv_step_log_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.case_approval_step | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.case_approval_step' | Mã nguồn dữ liệu. | GSGD.case_approval_step |  |  |
| 4 | Market Surveillance Case Id | mkt_surveillance_case_id | BIGINT |  |  | F |  | FK đến vụ việc giám sát. | GSGD.case_approval_step | case_file_id |  |
| 5 | Market Surveillance Case Code | mkt_surveillance_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. | GSGD.case_approval_step | case_file_id |  |
| 6 | Step Code | step_code | STRING |  |  |  |  | Mã bước: 1=Chuyên viên khởi tạo, 2=Trưởng ban phê duyệt, 3=Phó Trưởng ban phân công, 4=Chuyên viên xử lý. | GSGD.case_approval_step | step_code | Scheme: GSGD_APPROVAL_STEP_CODE. |
| 7 | Step Name | step_nm | STRING | X |  |  |  | Tên bước (phục vụ hiển thị). | GSGD.case_approval_step | step_name |  |
| 8 | Assigned Role | asgn_rl | STRING | X |  |  |  | Chức vụ/nhóm duyệt (ví dụ: TRUONG_BAN, PHO_TRUONG_BAN, CHUYEN_VIEN). | GSGD.case_approval_step | assigned_role |  |
| 9 | Step Status Code | step_st_code | STRING | X |  |  |  | Trạng thái: 0=Chưa xử lý, 1=Đang xử lý, 2=Đã duyệt/Hoàn thành, 3=Từ chối. | GSGD.case_approval_step | status | Scheme: GSGD_APPROVAL_STEP_STATUS. |
| 10 | Action At | actn_at | TIMESTAMP | X |  |  |  | Thời điểm duyệt/xử lý. | GSGD.case_approval_step | action_at |  |
| 11 | Action Note | actn_note | STRING | X |  |  |  | Ghi chú khi duyệt/từ chối. | GSGD.case_approval_step | action_note |  |
| 12 | Next Step Code | nxt_step_code | STRING | X |  |  |  | Bước tiếp theo. Nullable nếu là bước cuối. | GSGD.case_approval_step | next_step_code | Scheme: GSGD_APPROVAL_STEP_CODE. |
| 13 | Next Assigned Role | nxt_asgn_rl | STRING | X |  |  |  | Chức vụ/nhóm của người duyệt tiếp theo. | GSGD.case_approval_step | next_assigned_role |  |
| 14 | Due Date | due_dt | DATE | X |  |  |  | Hạn xử lý (nếu cần SLA). | GSGD.case_approval_step | due_date |  |


#### 2.{IDX}.16.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Market Surveillance Case Approval Step Log Id | mkt_surveillance_case_aprv_step_log_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Market Surveillance Case Id | mkt_surveillance_case_id | Market Surveillance Case | Market Surveillance Case Id | mkt_surveillance_case_id |




### 2.{IDX}.17 Bảng Market Surveillance Suspicious Account

- **Mô tả:** Tài khoản nghi vấn được xác định trong vụ việc giám sát. FK Market Surveillance Case + Investor Trading Account.
- **Tên vật lý:** mkt_surveillance_sspcs_ac
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Market Surveillance Suspicious Account Id | mkt_surveillance_sspcs_ac_id | BIGINT |  | X | P |  | Khóa đại diện cho tài khoản nghi vấn trong vụ việc. | GSGD.suspicious_account |  |  |
| 2 | Market Surveillance Suspicious Account Code | mkt_surveillance_sspcs_ac_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.suspicious_account | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.suspicious_account' | Mã nguồn dữ liệu. | GSGD.suspicious_account |  |  |
| 4 | Market Surveillance Case Id | mkt_surveillance_case_id | BIGINT |  |  | F |  | FK đến vụ việc giám sát. | GSGD.suspicious_account | case_file_id |  |
| 5 | Market Surveillance Case Code | mkt_surveillance_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. | GSGD.suspicious_account | case_file_id |  |
| 6 | Investor Trading Account Id | ivsr_tdg_ac_id | BIGINT |  |  | F |  | FK đến tài khoản giao dịch nghi vấn. | GSGD.suspicious_account | account_id |  |
| 7 | Investor Trading Account Code | ivsr_tdg_ac_code | STRING |  |  |  |  | Mã tài khoản nghi vấn. Denormalized. | GSGD.suspicious_account | account_id |  |
| 8 | Criteria Flags | crit_flags | STRING | X |  |  |  | Các tiêu chí đánh giá (JSON hoặc comma-separated). | GSGD.suspicious_account | criteria_flags |  |
| 9 | Suspicious Source Code | sspcs_src_code | STRING | X |  |  |  | Nguồn xác định TK nghi vấn: 1=Hệ thống tự động, 2=User thêm. | GSGD.suspicious_account | source | Scheme: GSGD_SUSPICIOUS_SOURCE. |


#### 2.{IDX}.17.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Market Surveillance Suspicious Account Id | mkt_surveillance_sspcs_ac_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Market Surveillance Case Id | mkt_surveillance_case_id | Market Surveillance Case | Market Surveillance Case Id | mkt_surveillance_case_id |
| Investor Trading Account Id | ivsr_tdg_ac_id | Investor Trading Account | Investor Trading Account Id | ivsr_tdg_ac_id |




### 2.{IDX}.18 Bảng Market Surveillance Suspicious Account Group

- **Mô tả:** Nhóm tài khoản nghi vấn trong phạm vi 1 vụ việc giám sát cụ thể. FK Market Surveillance Case.
- **Tên vật lý:** mkt_surveillance_sspcs_ac_grp
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Market Surveillance Suspicious Account Group Id | mkt_surveillance_sspcs_ac_grp_id | BIGINT |  | X | P |  | Khóa đại diện cho nhóm tài khoản nghi vấn trong vụ việc. | GSGD.suspicious_account_group |  |  |
| 2 | Market Surveillance Suspicious Account Group Code | mkt_surveillance_sspcs_ac_grp_code | STRING |  |  |  |  | Mã nhóm tài khoản nghi vấn. BK. | GSGD.suspicious_account_group | group_code | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.suspicious_account_group' | Mã nguồn dữ liệu. | GSGD.suspicious_account_group |  |  |
| 4 | Market Surveillance Case Id | mkt_surveillance_case_id | BIGINT |  |  | F |  | FK đến vụ việc giám sát. | GSGD.suspicious_account_group | case_file_id |  |
| 5 | Market Surveillance Case Code | mkt_surveillance_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. | GSGD.suspicious_account_group | case_file_id |  |
| 6 | Group Name | grp_nm | STRING | X |  |  |  | Tên nhóm tài khoản nghi vấn. | GSGD.suspicious_account_group | group_name |  |
| 7 | Description | dsc | STRING | X |  |  |  | Mô tả nhóm. | GSGD.suspicious_account_group | description |  |
| 8 | Relationship Criteria Code | rltnp_crit_code | STRING | X |  |  |  | Tiêu chí phân nhóm: Danh tính, IP, MAC, Tiền. | GSGD.suspicious_account_group | relationship_criteria | Scheme: GSGD_RELATIONSHIP_CRITERIA. |


#### 2.{IDX}.18.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Market Surveillance Suspicious Account Group Id | mkt_surveillance_sspcs_ac_grp_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Market Surveillance Case Id | mkt_surveillance_case_id | Market Surveillance Case | Market Surveillance Case Id | mkt_surveillance_case_id |




### 2.{IDX}.19 Bảng Market Surveillance Analysis Criterion Value

- **Mô tả:** Giá trị cụ thể của tiêu chí phân tích theo từng quy trình. FK Market Surveillance Analysis Criterion.
- **Tên vật lý:** mkt_surveillance_anl_criterion_val
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Market Surveillance Analysis Criterion Value Id | mkt_surveillance_anl_criterion_val_id | BIGINT |  | X | P |  | Khóa đại diện cho giá trị tiêu chí phân tích. | GSGD.analysis_attribute_value |  |  |
| 2 | Market Surveillance Analysis Criterion Value Code | mkt_surveillance_anl_criterion_val_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.analysis_attribute_value | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.analysis_attribute_value' | Mã nguồn dữ liệu. | GSGD.analysis_attribute_value |  |  |
| 4 | Market Surveillance Analysis Criterion Id | mkt_surveillance_anl_criterion_id | BIGINT |  |  | F |  | FK đến tiêu chí phân tích. | GSGD.analysis_attribute_value | attribute_id |  |
| 5 | Market Surveillance Analysis Criterion Code | mkt_surveillance_anl_criterion_code | STRING |  |  |  |  | Mã tiêu chí phân tích. Denormalized. | GSGD.analysis_attribute_value | attribute_id |  |
| 6 | Workflow Type Code | workflow_tp_code | STRING |  |  |  |  | Quy trình: 1=Sơ bộ, 2=Thao túng, 3=Nội gián, 4=Liên thị trường. | GSGD.analysis_attribute_value | workflow_type | Scheme: GSGD_WORKFLOW_TYPE. |
| 7 | Value Number | val_nbr | STRING | X |  |  |  | Giá trị số (nếu data_type = NUMBER). | GSGD.analysis_attribute_value | value_number |  |
| 8 | Value String | val_strg | STRING | X |  |  |  | Giá trị chuỗi (nếu data_type = STRING hoặc mô tả mở rộng). | GSGD.analysis_attribute_value | value_string |  |
| 9 | Value Date | val_dt | DATE | X |  |  |  | Giá trị ngày (nếu data_type = DATE). | GSGD.analysis_attribute_value | value_date |  |
| 10 | Value Boolean | val_booln | BOOLEAN | X |  |  |  | Giá trị boolean: 0/1 (nếu data_type = BOOLEAN). | GSGD.analysis_attribute_value | value_boolean |  |


#### 2.{IDX}.19.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Market Surveillance Analysis Criterion Value Id | mkt_surveillance_anl_criterion_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Market Surveillance Analysis Criterion Id | mkt_surveillance_anl_criterion_id | Market Surveillance Analysis Criterion | Market Surveillance Analysis Criterion Id | mkt_surveillance_anl_criterion_id |




### 2.{IDX}.20 Bảng Market Surveillance Compliance Report Column Config

- **Mô tả:** Định nghĩa cấu trúc cột của từng loại báo cáo tuân thủ GSGD. FK Market Surveillance Compliance Report Template.
- **Tên vật lý:** mkt_surveillance_cmpln_rpt_clmn_config
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Market Surveillance Compliance Report Column Config Id | mkt_surveillance_cmpln_rpt_clmn_config_id | BIGINT |  | X | P |  | Khóa đại diện cho cấu hình cột báo cáo tuân thủ. | GSGD.compliance_report_config |  |  |
| 2 | Market Surveillance Compliance Report Column Config Code | mkt_surveillance_cmpln_rpt_clmn_config_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.compliance_report_config | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.compliance_report_config' | Mã nguồn dữ liệu. | GSGD.compliance_report_config |  |  |
| 4 | Market Surveillance Compliance Report Template Id | mkt_surveillance_cmpln_rpt_tpl_id | BIGINT |  |  | F |  | FK đến mẫu báo cáo tuân thủ. | GSGD.compliance_report_config | template_id |  |
| 5 | Market Surveillance Compliance Report Template Code | mkt_surveillance_cmpln_rpt_tpl_code | STRING |  |  |  |  | Mã mẫu báo cáo tuân thủ. Denormalized. | GSGD.compliance_report_config | template_id |  |
| 6 | Column Label | clmn_lbl | STRING | X |  |  |  | Nhãn cột trong báo cáo. | GSGD.compliance_report_config | column_label |  |
| 7 | Display Order | dspl_ordr | INT | X |  |  |  | Thứ tự hiển thị cột. | GSGD.compliance_report_config | display_order |  |
| 8 | Data Type Code | data_tp_code | STRING | X |  |  |  | Kiểu dữ liệu của cột. | GSGD.compliance_report_config | data_type | Scheme: GSGD_DATA_TYPE. |
| 9 | Is Visible | is_visible | BOOLEAN | X |  |  |  | Cờ hiển thị cột. | GSGD.compliance_report_config | is_visible |  |


#### 2.{IDX}.20.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Market Surveillance Compliance Report Column Config Id | mkt_surveillance_cmpln_rpt_clmn_config_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Market Surveillance Compliance Report Template Id | mkt_surveillance_cmpln_rpt_tpl_id | Market Surveillance Compliance Report Template | Market Surveillance Compliance Report Template Id | mkt_surveillance_cmpln_rpt_tpl_id |




### 2.{IDX}.21 Bảng Market Surveillance Compliance Report Instance

- **Mô tả:** Instance báo cáo tuân thủ theo từng kỳ. FK Market Surveillance Compliance Report Template.
- **Tên vật lý:** mkt_surveillance_cmpln_rpt_instn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Market Surveillance Compliance Report Instance Id | mkt_surveillance_cmpln_rpt_instn_id | BIGINT |  | X | P |  | Khóa đại diện cho instance báo cáo tuân thủ theo kỳ. | GSGD.compliance_report_master |  |  |
| 2 | Market Surveillance Compliance Report Instance Code | mkt_surveillance_cmpln_rpt_instn_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.compliance_report_master | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.compliance_report_master' | Mã nguồn dữ liệu. | GSGD.compliance_report_master |  |  |
| 4 | Market Surveillance Compliance Report Template Id | mkt_surveillance_cmpln_rpt_tpl_id | BIGINT |  |  | F |  | FK đến mẫu báo cáo tuân thủ. | GSGD.compliance_report_master | template_id |  |
| 5 | Market Surveillance Compliance Report Template Code | mkt_surveillance_cmpln_rpt_tpl_code | STRING |  |  |  |  | Mã mẫu báo cáo tuân thủ. Denormalized. | GSGD.compliance_report_master | template_id |  |
| 6 | Period Type Code | prd_tp_code | STRING | X |  |  |  | Loại kỳ báo cáo. | GSGD.compliance_report_master | period_type | Scheme: GSGD_PERIOD_TYPE. |
| 7 | Period Value | prd_val | STRING | X |  |  |  | Giá trị kỳ báo cáo (ví dụ: tháng 1 = 1). | GSGD.compliance_report_master | period_value |  |
| 8 | Period Year | prd_yr | INT | X |  |  |  | Năm kỳ báo cáo. | GSGD.compliance_report_master | period_year |  |
| 9 | Instance Status Code | instn_st_code | STRING | X |  |  |  | Trạng thái instance báo cáo. | GSGD.compliance_report_master | status | Scheme: GSGD_APPROVAL_STATUS. |


#### 2.{IDX}.21.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Market Surveillance Compliance Report Instance Id | mkt_surveillance_cmpln_rpt_instn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Market Surveillance Compliance Report Template Id | mkt_surveillance_cmpln_rpt_tpl_id | Market Surveillance Compliance Report Template | Market Surveillance Compliance Report Template Id | mkt_surveillance_cmpln_rpt_tpl_id |




### 2.{IDX}.22 Bảng Abnormal Trading Report File Attachment

- **Mô tả:** File đính kèm báo cáo giao dịch bất thường (có chữ ký số). FK Abnormal Trading Report.
- **Tên vật lý:** abnormal_tdg_rpt_file_attachment
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Abnormal Trading Report File Attachment Id | abnormal_tdg_rpt_file_attachment_id | BIGINT |  | X | P |  | Khóa đại diện cho file đính kèm báo cáo bất thường. | GSGD.abnormal_report_file |  |  |
| 2 | Abnormal Trading Report File Attachment Code | abnormal_tdg_rpt_file_attachment_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.abnormal_report_file | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.abnormal_report_file' | Mã nguồn dữ liệu. | GSGD.abnormal_report_file |  |  |
| 4 | Abnormal Trading Report Id | abnormal_tdg_rpt_id | BIGINT |  |  | F |  | FK đến báo cáo giao dịch bất thường. | GSGD.abnormal_report_file | report_id |  |
| 5 | Abnormal Trading Report Code | abnormal_tdg_rpt_code | STRING |  |  |  |  | Mã báo cáo bất thường. Denormalized. | GSGD.abnormal_report_file | report_id |  |
| 6 | File Name | file_nm | STRING | X |  |  |  | Tên file đính kèm. | GSGD.abnormal_report_file | file_name |  |
| 7 | File Path | file_path | STRING | X |  |  |  | Đường dẫn file. | GSGD.abnormal_report_file | file_path |  |
| 8 | File Size | file_sz | STRING | X |  |  |  | Kích thước file (bytes). | GSGD.abnormal_report_file | file_size |  |
| 9 | File Type Code | file_tp_code | STRING | X |  |  |  | Loại file: CSV, XLSX, PDF. | GSGD.abnormal_report_file | file_type | Scheme: GSGD_FILE_TYPE. |
| 10 | Digital Signature | digital_sgn | STRING | X |  |  |  | Chữ ký số của file. | GSGD.abnormal_report_file | digital_signature |  |


#### 2.{IDX}.22.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Abnormal Trading Report File Attachment Id | abnormal_tdg_rpt_file_attachment_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Abnormal Trading Report Id | abnormal_tdg_rpt_id | Abnormal Trading Report | Abnormal Trading Report Id | abnormal_tdg_rpt_id |




### 2.{IDX}.23 Bảng Market Surveillance Compliance Report Row Data

- **Mô tả:** Dữ liệu từng dòng trong báo cáo tuân thủ GSGD (lưu dạng JSON). Grain: 1 dòng = 1 row x 1 kỳ. FK Market Surveillance Compliance Report Instance.
- **Tên vật lý:** mkt_surveillance_cmpln_rpt_row_data
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Market Surveillance Compliance Report Row Data Id | mkt_surveillance_cmpln_rpt_row_data_id | BIGINT |  | X | P |  | Khóa đại diện cho dòng dữ liệu báo cáo tuân thủ. | GSGD.compliance_report_data |  |  |
| 2 | Market Surveillance Compliance Report Row Data Code | mkt_surveillance_cmpln_rpt_row_data_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.compliance_report_data | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.compliance_report_data' | Mã nguồn dữ liệu. | GSGD.compliance_report_data |  |  |
| 4 | Market Surveillance Compliance Report Instance Id | mkt_surveillance_cmpln_rpt_instn_id | BIGINT |  |  | F |  | FK đến instance báo cáo tuân thủ. | GSGD.compliance_report_data | report_master_id |  |
| 5 | Market Surveillance Compliance Report Instance Code | mkt_surveillance_cmpln_rpt_instn_code | STRING |  |  |  |  | Mã instance báo cáo tuân thủ. Denormalized. | GSGD.compliance_report_data | report_master_id |  |
| 6 | Row Data | row_data | STRING | X |  |  |  | Dữ liệu một dòng trong báo cáo tuân thủ (JSON/text raw). Schema không ổn định — không parse. | GSGD.compliance_report_data | row_data |  |


#### 2.{IDX}.23.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Market Surveillance Compliance Report Row Data Id | mkt_surveillance_cmpln_rpt_row_data_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Market Surveillance Compliance Report Instance Id | mkt_surveillance_cmpln_rpt_instn_id | Market Surveillance Compliance Report Instance | Market Surveillance Compliance Report Instance Id | mkt_surveillance_cmpln_rpt_instn_id |




### 2.{IDX}.24 Bảng Market Surveillance Analysis Execution Log

- **Mô tả:** Log thực thi phân tích từng biểu mẫu trong vụ việc giám sát. FK Market Surveillance Case.
- **Tên vật lý:** mkt_surveillance_anl_exec_log
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Market Surveillance Analysis Execution Log Id | mkt_surveillance_anl_exec_log_id | BIGINT |  | X | P |  | Khóa đại diện cho log thực thi phân tích biểu mẫu. | GSGD.analysis_execution_log |  |  |
| 2 | Market Surveillance Analysis Execution Log Code | mkt_surveillance_anl_exec_log_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.analysis_execution_log | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.analysis_execution_log' | Mã nguồn dữ liệu. | GSGD.analysis_execution_log |  |  |
| 4 | Market Surveillance Case Id | mkt_surveillance_case_id | BIGINT |  |  | F |  | FK đến vụ việc giám sát. | GSGD.analysis_execution_log | case_file_id |  |
| 5 | Market Surveillance Case Code | mkt_surveillance_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. | GSGD.analysis_execution_log | case_file_id |  |
| 6 | Analysis Name | anl_nm | STRING | X |  |  |  | Tên phân tích biểu mẫu. | GSGD.analysis_execution_log | analysis _name |  |
| 7 | Workflow Type Code | workflow_tp_code | STRING | X |  |  |  | Loại quy trình: 1=Sơ bộ, 2=Thao túng, 3=Nội gián, 4=Liên thị trường. | GSGD.analysis_execution_log | workflow_type | Scheme: GSGD_WORKFLOW_TYPE. |
| 8 | Template Type Code | tpl_tp_code | STRING | X |  |  |  | Loại biểu mẫu: 1=Báo cáo tổng hợp, 2=Báo cáo phân tích. | GSGD.analysis_execution_log | template_type | Scheme: GSGD_TEMPLATE_TYPE. |
| 9 | Start Time | strt_tm | TIMESTAMP | X |  |  |  | Thời gian bắt đầu phân tích. | GSGD.analysis_execution_log | start_time |  |
| 10 | End Time | end_tm | TIMESTAMP | X |  |  |  | Thời gian kết thúc phân tích. | GSGD.analysis_execution_log | end_time |  |
| 11 | Execution Status Code | exec_st_code | STRING | X |  |  |  | Trạng thái thực thi: 0=Inactive, 1=Active. | GSGD.analysis_execution_log | status | Scheme: GSGD_EXECUTION_STATUS. |
| 12 | Request Param | rqs_param | STRING | X |  |  |  | Thông tin parameters đầu vào. | GSGD.analysis_execution_log | request_param |  |
| 13 | Error Message | err_msg | STRING | X |  |  |  | Thông báo lỗi (nếu có). | GSGD.analysis_execution_log | error_message |  |
| 14 | File Path | file_path | STRING | X |  |  |  | Đường dẫn file output phân tích. | GSGD.analysis_execution_log | path |  |
| 15 | File Name | file_nm | STRING | X |  |  |  | Tên file output phân tích. | GSGD.analysis_execution_log | file_name |  |


#### 2.{IDX}.24.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Market Surveillance Analysis Execution Log Id | mkt_surveillance_anl_exec_log_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Market Surveillance Case Id | mkt_surveillance_case_id | Market Surveillance Case | Market Surveillance Case Id | mkt_surveillance_case_id |




### 2.{IDX}.25 Bảng Market Surveillance Analysis Suspicious Account Snapshot

- **Mô tả:** Snapshot thông tin tài khoản nghi vấn tại thời điểm phân tích biểu mẫu. FK Market Surveillance Case.
- **Tên vật lý:** mkt_surveillance_anl_sspcs_ac_snpst
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Market Surveillance Analysis Suspicious Account Snapshot Id | mkt_surveillance_anl_sspcs_ac_snpst_id | BIGINT |  | X | P |  | Khóa đại diện cho snapshot thông tin tài khoản nghi vấn theo biểu mẫu phân tích. | GSGD.analysis_suspicious_account_code |  |  |
| 2 | Market Surveillance Analysis Suspicious Account Snapshot Code | mkt_surveillance_anl_sspcs_ac_snpst_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.analysis_suspicious_account_code | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.analysis_suspicious_account_code' | Mã nguồn dữ liệu. | GSGD.analysis_suspicious_account_code |  |  |
| 4 | Market Surveillance Case Id | mkt_surveillance_case_id | BIGINT |  |  | F |  | FK đến vụ việc giám sát. | GSGD.analysis_suspicious_account_code | case_file_id |  |
| 5 | Market Surveillance Case Code | mkt_surveillance_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. | GSGD.analysis_suspicious_account_code | case_file_id |  |
| 6 | Workflow Type Code | workflow_tp_code | STRING |  |  |  |  | Loại quy trình: 1=Sơ bộ, 2=Thao túng, 3=Nội gián, 4=Liên thị trường. | GSGD.analysis_suspicious_account_code | workflow_type | Scheme: GSGD_WORKFLOW_TYPE. |
| 7 | Account Code | ac_code | STRING |  |  |  |  | Mã tài khoản nghi vấn tại thời điểm phân tích. Snapshot — không FK đến Investor Trading Account. | GSGD.analysis_suspicious_account_code | account_code |  |
| 8 | Account Name | ac_nm | STRING | X |  |  |  | Họ và tên tại thời điểm phân tích. Snapshot. | GSGD.analysis_suspicious_account_code | account_name |  |
| 9 | Account Type Code | ac_tp_code | STRING | X |  |  |  | Loại tài khoản. Snapshot. | GSGD.analysis_suspicious_account_code | account_type | Scheme: GSGD_INVESTOR_TYPE. |
| 10 | Identity Number | identity_nbr | STRING | X |  |  |  | Số CCCD/Số đăng ký sở hữu tại thời điểm phân tích. Snapshot. | GSGD.analysis_suspicious_account_code | identity_number |  |
| 11 | Identity Issue Date | identity_issu_dt | DATE | X |  |  |  | Ngày cấp giấy tờ. Snapshot. | GSGD.analysis_suspicious_account_code | identity_issue_date |  |
| 12 | Identity Issue Place | identity_issu_plc | STRING | X |  |  |  | Nơi cấp giấy tờ. Snapshot. | GSGD.analysis_suspicious_account_code | identity_issue_place |  |
| 13 | Contact Address | ctc_adr | STRING | X |  |  |  | Địa chỉ liên lạc tại thời điểm phân tích. Snapshot — không tách shared entity. | GSGD.analysis_suspicious_account_code | contact_address |  |
| 14 | Domestic Foreign Flag | dmst_frgn_f | STRING | X |  |  |  | Trong nước/Nước ngoài. Snapshot. | GSGD.analysis_suspicious_account_code | domestic_foreign_flag | Scheme: GSGD_DOMESTIC_FOREIGN_FLAG. |
| 15 | Phone Number | ph_nbr | STRING | X |  |  |  | Số điện thoại tại thời điểm phân tích. Snapshot. | GSGD.analysis_suspicious_account_code | phone_number |  |
| 16 | Email | email | STRING | X |  |  |  | Email tại thời điểm phân tích. Snapshot. | GSGD.analysis_suspicious_account_code | email |  |
| 17 | Account Status Code | ac_st_code | STRING | X |  |  |  | Trạng thái tài khoản: 0=Đóng, 1=Mở. Snapshot. | GSGD.analysis_suspicious_account_code | account_status | Scheme: GSGD_ACCOUNT_STATUS. |


#### 2.{IDX}.25.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Market Surveillance Analysis Suspicious Account Snapshot Id | mkt_surveillance_anl_sspcs_ac_snpst_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Market Surveillance Case Id | mkt_surveillance_case_id | Market Surveillance Case | Market Surveillance Case Id | mkt_surveillance_case_id |




### 2.{IDX}.26 Bảng Market Surveillance Suspicious Account Analysis Result

- **Mô tả:** Kết quả phân tích/kiểm tra tài khoản nghi vấn trong vụ việc giám sát. FK Market Surveillance Case.
- **Tên vật lý:** mkt_surveillance_sspcs_ac_anl_rslt
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Market Surveillance Suspicious Account Analysis Result Id | mkt_surveillance_sspcs_ac_anl_rslt_id | BIGINT |  | X | P |  | Khóa đại diện cho kết quả phân tích tài khoản nghi vấn. | GSGD.analysis_suspicious_account |  |  |
| 2 | Market Surveillance Suspicious Account Analysis Result Code | mkt_surveillance_sspcs_ac_anl_rslt_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.analysis_suspicious_account | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.analysis_suspicious_account' | Mã nguồn dữ liệu. | GSGD.analysis_suspicious_account |  |  |
| 4 | Market Surveillance Case Id | mkt_surveillance_case_id | BIGINT |  |  | F |  | FK đến vụ việc giám sát. | GSGD.analysis_suspicious_account | case_file_id |  |
| 5 | Market Surveillance Case Code | mkt_surveillance_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. | GSGD.analysis_suspicious_account | case_file_id |  |
| 6 | Workflow Type Code | workflow_tp_code | STRING |  |  |  |  | Loại quy trình: 1=Sơ bộ, 2=Thao túng, 3=Nội gián, 4=Liên thị trường. | GSGD.analysis_suspicious_account | workflow_type | Scheme: GSGD_WORKFLOW_TYPE. |
| 7 | Result Type Code | rslt_tp_code | STRING |  |  |  |  | Loại kết quả: 1=Kết quả phân tích, 2=Kết quả kiểm tra. | GSGD.analysis_suspicious_account | result_type | Scheme: GSGD_RESULT_TYPE. |
| 8 | Account Code | ac_code | STRING |  |  |  |  | Mã tài khoản nghi vấn. | GSGD.analysis_suspicious_account | account_code |  |
| 9 | Analysis Date | anl_dt | DATE |  |  |  |  | Ngày phân tích. | GSGD.analysis_suspicious_account | analysis_date |  |


#### 2.{IDX}.26.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Market Surveillance Suspicious Account Analysis Result Id | mkt_surveillance_sspcs_ac_anl_rslt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Market Surveillance Case Id | mkt_surveillance_case_id | Market Surveillance Case | Market Surveillance Case Id | mkt_surveillance_case_id |




### 2.{IDX}.27 Bảng Market Surveillance Account Relationship Analysis Result

- **Mô tả:** Kết quả phân tích quan hệ giữa tài khoản nghi vấn. FK Market Surveillance Case + Investor Account Relationship.
- **Tên vật lý:** mkt_surveillance_ac_rltnp_anl_rslt
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Market Surveillance Account Relationship Analysis Result Id | mkt_surveillance_ac_rltnp_anl_rslt_id | BIGINT |  | X | P |  | Khóa đại diện cho kết quả phân tích quan hệ tài khoản. | GSGD.analysis_account_relationship |  |  |
| 2 | Market Surveillance Account Relationship Analysis Result Code | mkt_surveillance_ac_rltnp_anl_rslt_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.analysis_account_relationship | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.analysis_account_relationship' | Mã nguồn dữ liệu. | GSGD.analysis_account_relationship |  |  |
| 4 | Market Surveillance Case Id | mkt_surveillance_case_id | BIGINT |  |  | F |  | FK đến vụ việc giám sát. | GSGD.analysis_account_relationship | case_file_id |  |
| 5 | Market Surveillance Case Code | mkt_surveillance_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. | GSGD.analysis_account_relationship | case_file_id |  |
| 6 | Investor Account Relationship Id | ivsr_ac_rltnp_id | BIGINT | X |  | F |  | FK đến mối quan hệ tài khoản nghi vấn. | GSGD.analysis_account_relationship | relationship_id |  |
| 7 | Investor Account Relationship Code | ivsr_ac_rltnp_code | STRING | X |  |  |  | Mã mối quan hệ tài khoản. Denormalized. | GSGD.analysis_account_relationship | relationship_id |  |
| 8 | Workflow Type Code | workflow_tp_code | STRING |  |  |  |  | Loại quy trình: 1=Sơ bộ, 2=Thao túng, 3=Nội gián, 4=Liên thị trường. | GSGD.analysis_account_relationship | workflow_type | Scheme: GSGD_WORKFLOW_TYPE. |
| 9 | Result Type Code | rslt_tp_code | STRING |  |  |  |  | Loại kết quả: 1=Kết quả phân tích, 2=Kết quả kiểm tra. | GSGD.analysis_account_relationship | result_type | Scheme: GSGD_RESULT_TYPE. |
| 10 | Analysis Date | anl_dt | DATE |  |  |  |  | Ngày phân tích. | GSGD.analysis_account_relationship | analysis_date |  |


#### 2.{IDX}.27.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Market Surveillance Account Relationship Analysis Result Id | mkt_surveillance_ac_rltnp_anl_rslt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Market Surveillance Case Id | mkt_surveillance_case_id | Market Surveillance Case | Market Surveillance Case Id | mkt_surveillance_case_id |
| Investor Account Relationship Id | ivsr_ac_rltnp_id | Investor Account Relationship | Investor Account Relationship Id | ivsr_ac_rltnp_id |




### 2.{IDX}.28 Bảng Market Surveillance Account Group Analysis Result

- **Mô tả:** Kết quả phân tích nhóm tài khoản nghi vấn. FK Market Surveillance Case.
- **Tên vật lý:** mkt_surveillance_ac_grp_anl_rslt
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Market Surveillance Account Group Analysis Result Id | mkt_surveillance_ac_grp_anl_rslt_id | BIGINT |  | X | P |  | Khóa đại diện cho kết quả phân tích nhóm tài khoản. | GSGD.analysis_account_group |  |  |
| 2 | Market Surveillance Account Group Analysis Result Code | mkt_surveillance_ac_grp_anl_rslt_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.analysis_account_group | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.analysis_account_group' | Mã nguồn dữ liệu. | GSGD.analysis_account_group |  |  |
| 4 | Market Surveillance Case Id | mkt_surveillance_case_id | BIGINT |  |  | F |  | FK đến vụ việc giám sát. | GSGD.analysis_account_group | case_file_id |  |
| 5 | Market Surveillance Case Code | mkt_surveillance_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. | GSGD.analysis_account_group | case_file_id |  |
| 6 | Workflow Type Code | workflow_tp_code | STRING |  |  |  |  | Loại quy trình: 1=Sơ bộ, 2=Thao túng, 3=Nội gián, 4=Liên thị trường. | GSGD.analysis_account_group | workflow_type | Scheme: GSGD_WORKFLOW_TYPE. |
| 7 | Result Type Code | rslt_tp_code | STRING |  |  |  |  | Loại kết quả: 1=Kết quả phân tích, 2=Kết quả kiểm tra. | GSGD.analysis_account_group | result_type | Scheme: GSGD_RESULT_TYPE. |
| 8 | Group Code | grp_code | STRING | X |  |  |  | Mã nhóm tài khoản trong kết quả phân tích. | GSGD.analysis_account_group | group_code |  |
| 9 | Group Name | grp_nm | STRING | X |  |  |  | Tên nhóm tài khoản trong kết quả phân tích. | GSGD.analysis_account_group | group_name |  |
| 10 | Analysis Date | anl_dt | DATE |  |  |  |  | Ngày phân tích. | GSGD.analysis_account_group | analysis_date |  |


#### 2.{IDX}.28.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Market Surveillance Account Group Analysis Result Id | mkt_surveillance_ac_grp_anl_rslt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Market Surveillance Case Id | mkt_surveillance_case_id | Market Surveillance Case | Market Surveillance Case Id | mkt_surveillance_case_id |




### 2.{IDX}.29 Bảng Market Surveillance Account Group Member Analysis Result

- **Mô tả:** Thành viên nhóm tài khoản trong kết quả phân tích. FK Market Surveillance Case + Investor Account Relationship.
- **Tên vật lý:** mkt_surveillance_ac_grp_mbr_anl_rslt
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Market Surveillance Account Group Member Analysis Result Id | mkt_surveillance_ac_grp_mbr_anl_rslt_id | BIGINT |  | X | P |  | Khóa đại diện cho kết quả phân tích thành viên nhóm tài khoản. | GSGD.analysis_account_group_member |  |  |
| 2 | Market Surveillance Account Group Member Analysis Result Code | mkt_surveillance_ac_grp_mbr_anl_rslt_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.analysis_account_group_member | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.analysis_account_group_member' | Mã nguồn dữ liệu. | GSGD.analysis_account_group_member |  |  |
| 4 | Market Surveillance Case Id | mkt_surveillance_case_id | BIGINT |  |  | F |  | FK đến vụ việc giám sát. | GSGD.analysis_account_group_member | case_file_id |  |
| 5 | Market Surveillance Case Code | mkt_surveillance_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. | GSGD.analysis_account_group_member | case_file_id |  |
| 6 | Account Investor Group Id | ac_ivsr_grp_id | BIGINT | X |  | F |  | FK đến nhóm tài khoản. FK suy luận đã xác nhận. | GSGD.analysis_account_group_member | account_group_id |  |
| 7 | Account Investor Group Code | ac_ivsr_grp_code | STRING | X |  |  |  | Mã nhóm tài khoản. Denormalized. | GSGD.analysis_account_group_member | account_group_id |  |
| 8 | Investor Account Relationship Id | ivsr_ac_rltnp_id | BIGINT | X |  | F |  | FK đến mối quan hệ tài khoản. | GSGD.analysis_account_group_member | relationship_id |  |
| 9 | Investor Account Relationship Code | ivsr_ac_rltnp_code | STRING | X |  |  |  | Mã mối quan hệ tài khoản. Denormalized. | GSGD.analysis_account_group_member | relationship_id |  |
| 10 | Workflow Type Code | workflow_tp_code | STRING |  |  |  |  | Loại quy trình: 1=Sơ bộ, 2=Thao túng, 3=Nội gián, 4=Liên thị trường. | GSGD.analysis_account_group_member | workflow_type | Scheme: GSGD_WORKFLOW_TYPE. |
| 11 | Result Type Code | rslt_tp_code | STRING |  |  |  |  | Loại kết quả: 1=Kết quả phân tích, 2=Kết quả kiểm tra. | GSGD.analysis_account_group_member | result_type | Scheme: GSGD_RESULT_TYPE. |
| 12 | Account Code | ac_code | STRING | X |  |  |  | Mã tài khoản thành viên trong kết quả phân tích. | GSGD.analysis_account_group_member | account_code |  |
| 13 | Account Name | ac_nm | STRING | X |  |  |  | Tên tài khoản thành viên. | GSGD.analysis_account_group_member | account_name |  |
| 14 | Description | dsc | STRING | X |  |  |  | Mô tả. | GSGD.analysis_account_group_member | description |  |
| 15 | Analysis Date | anl_dt | DATE |  |  |  |  | Ngày phân tích. | GSGD.analysis_account_group_member | analysis_date |  |


#### 2.{IDX}.29.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Market Surveillance Account Group Member Analysis Result Id | mkt_surveillance_ac_grp_mbr_anl_rslt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Market Surveillance Case Id | mkt_surveillance_case_id | Market Surveillance Case | Market Surveillance Case Id | mkt_surveillance_case_id |
| Account Investor Group Id | ac_ivsr_grp_id | Account Investor Group | Account Investor Group Id | ac_ivsr_grp_id |
| Investor Account Relationship Id | ivsr_ac_rltnp_id | Investor Account Relationship | Investor Account Relationship Id | ivsr_ac_rltnp_id |




### 2.{IDX}.30 Bảng Market Surveillance Analysis Report

- **Mô tả:** Báo cáo output của quá trình phân tích vụ việc giám sát (report_type
- **Tên vật lý:** mkt_surveillance_anl_rpt
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Market Surveillance Analysis Report Id | mkt_surveillance_anl_rpt_id | BIGINT |  | X | P |  | Khóa đại diện cho báo cáo kết quả phân tích vụ việc. | GSGD.analysis_report |  |  |
| 2 | Market Surveillance Analysis Report Code | mkt_surveillance_anl_rpt_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. | GSGD.analysis_report | id | BK chính. Map từ PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'GSGD.analysis_report' | Mã nguồn dữ liệu. | GSGD.analysis_report |  |  |
| 4 | Market Surveillance Case Id | mkt_surveillance_case_id | BIGINT |  |  | F |  | FK đến vụ việc giám sát. | GSGD.analysis_report | case_file_id |  |
| 5 | Market Surveillance Case Code | mkt_surveillance_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. | GSGD.analysis_report | case_file_id |  |
| 6 | Report Type Code | rpt_tp_code | STRING | X |  |  |  | Loại báo cáo phân tích vụ việc. | GSGD.analysis_report | report_type | Scheme: GSGD_ANALYSIS_REPORT_TYPE. |
| 7 | Report Date | rpt_dt | DATE | X |  |  |  | Ngày lập báo cáo. | GSGD.analysis_report | report_date |  |
| 8 | Report Data | rpt_data | STRING | X |  |  |  | Dữ liệu báo cáo (JSON hoặc XML). Lưu raw — không parse. | GSGD.analysis_report | report_data |  |
| 9 | Report File Path | rpt_file_path | STRING | X |  |  |  | Đường dẫn file báo cáo. | GSGD.analysis_report | report_file_path |  |
| 10 | Analysis Execution Log Id | anl_exec_log_id | BIGINT | X |  | F |  | ID phân tích biểu mẫu. Denormalized — không tạo FK tường minh để tránh cross-tier dependency. | GSGD.analysis_report | analysis_execution_log |  |


#### 2.{IDX}.30.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Market Surveillance Analysis Report Id | mkt_surveillance_anl_rpt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Market Surveillance Case Id | mkt_surveillance_case_id | Market Surveillance Case | Market Surveillance Case Id | mkt_surveillance_case_id |




