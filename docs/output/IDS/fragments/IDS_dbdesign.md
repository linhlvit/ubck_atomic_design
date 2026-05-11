## IDS — Phần hệ quản lý công ty đại chúng & công ty kiểm toán

### Các mô hình quan hệ dữ liệu

![Mô hình quan hệ dữ liệu IDS](IDS/fragments/IDS_diagram.png)

**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | pblc_co_ste_cptl | Thông tin sở hữu nhà nước trong công ty đại chúng — tên đại diện nhà nước và tỷ lệ sở hữu. FK to Public Company. |
| 2 | stk_hldr_tdg_ac | Tài khoản giao dịch chứng khoán của cổ đông tại CTCK — số tài khoản và trạng thái. FK to Stock Holder. |
| 3 | audt_firm_sanction | Xử phạt hành chính đối với công ty kiểm toán hoặc kiểm toán viên — quyết định và nội dung xử phạt. FK nullable: Audit Firm Approval hoặc Auditor Approval. |
| 4 | audt_firm_wrn | Nhắc nhở từ BTC hoặc UBCKNN đến công ty kiểm toán hoặc kiểm toán viên — số văn bản và nội dung. FK nullable: Audit Firm Approval hoặc Auditor Approval. |
| 5 | pblc_co_cptl_incr | Tăng vốn điều lệ sau khi thành công ty đại chúng — vốn cuối năm tài chính và số đợt tăng. FK to Public Company. |
| 6 | pblc_co_cptl_mobilization | Tăng vốn trước khi thành công ty đại chúng — tổng vốn cuối năm và hình thức tăng. Grain: 1 năm x 1 công ty. FK to Public Company. |
| 7 | pblc_co_insp | Thanh tra/kiểm tra công ty đại chúng — loại/số quyết định/đơn vị chủ trì/biên bản. FK to Public Company. |
| 8 | pblc_co_pny | Xử phạt hành chính công ty đại chúng hoặc nhà đầu tư liên quan — hành vi vi phạm và quyết định xử phạt. FK to Public Company. |
| 9 | pblc_co_scr_ofrg | Hoạt động chào bán/phát hành chứng khoán — loại CK/kế hoạch/kết quả thực tế theo từng hình thức. FK to Public Company. |
| 10 | pblc_co_tender_ofr | Chào mua công khai — bên chào mua/số lượng dự kiến/kết quả/tỷ lệ sở hữu trước-sau. FK to Public Company. |
| 11 | dscl_notf | Instance thông báo CBTT gửi đi — nội dung/tiêu đề/ngày gửi/trạng thái. Grain: 1 lần gửi thông báo. FK to Disclosure Form Definition. |
| 12 | dscl_form_defn | Định nghĩa loại hồ sơ/tin CBTT — loại form/quy trình duyệt/nghiệp vụ. Master entity của vòng đời CBTT. Self-join parent_form_id. |
| 13 | dscl_notf_config | Cấu hình thông báo CBTT — kênh gửi/hệ thống nhận/người quản lý. FK to Disclosure Notification. |
| 14 | fnc_rpt_ctlg | Danh mục báo cáo tài chính — loại báo cáo/năm/scope hợp nhất/loại hình doanh nghiệp. Master entity FK từ Financial Report Row/Column Template. |
| 15 | fnc_rpt_clmn_tpl | Định nghĩa cột trong biểu mẫu BCTC — mã cột/tên/công thức/thứ tự. FK to Financial Report Catalog. |
| 16 | fnc_rpt_row_tpl | Định nghĩa hàng trong biểu mẫu BCTC — mã hàng/tên/công thức/thứ tự. FK to Financial Report Catalog. |
| 17 | prd_rpt_form | Biểu mẫu báo cáo định kỳ (thường niên/quý/tháng) cho CBTT. Master entity FK từ Periodic Report Form Row/Column Template. |
| 18 | prd_rpt_form_clmn_tpl | Định nghĩa cột trong biểu mẫu báo cáo định kỳ — tên/thứ tự/công thức. FK to Periodic Report Form. |
| 19 | prd_rpt_form_row_tpl | Định nghĩa hàng trong biểu mẫu báo cáo định kỳ — tên/thứ tự/kiểu dữ liệu. FK to Periodic Report Form. |
| 20 | pblc_co_frgn_own_lmt | Giới hạn tỷ lệ sở hữu nước ngoài của công ty đại chúng — max_owner_rate và khoảng thời gian áp dụng. FK to Public Company. |
| 21 | stk_cntl | Hạn chế chuyển nhượng cổ phiếu của cổ đông — số lượng bị hạn chế/thời gian/loại hạn chế. FK to Stock Holder. |
| 22 | audt_firm_aprv | Quyết định chấp thuận/đình chỉ công ty kiểm toán từ BTC và UBCKNN — số văn bản/ngày/nội dung. Gộp 2 cơ quan. FK to Audit Firm. |
| 23 | auditor_aprv | Quyết định chấp thuận/đình chỉ kiểm toán viên từ BTC và UBCKNN — chứng chỉ hành nghề/năm chấp thuận. FK to Audit Firm. |
| 24 | pblc_co_fnc_rpt_val | Giá trị từng ô BCTC trong một lần nộp báo cáo đã duyệt. Grain: 1 dòng = 1 ô (lần nộp × biểu mẫu × hàng × cột). FK to Public Company Report Submission và Financial Report Catalog. |
| 25 | pblc_co_rpt_subm | Lần nộp báo cáo/tin CBTT của công ty đại chúng đã được phê duyệt (news_status_cd = APPROVED). Grain: 1 dòng = 1 lần nộp. FK to Public Company và Disclosure Form Definition. |
| 26 | audt_firm | Công ty kiểm toán được UBCKNN chấp thuận. Ghi nhận thông tin pháp lý và trạng thái hoạt động. |
| 27 | audt_firm_lgl_rprs | Người đại diện pháp luật của công ty kiểm toán — chức vụ và ngày bổ nhiệm/kết thúc nhiệm kỳ. FK to Audit Firm. |
| 28 | pblc_co | Công ty đại chúng được UBCKNN quản lý. Lưu thông tin pháp lý và trạng thái hoạt động. |
| 29 | pblc_co_lgl_rprs | Người đại diện pháp luật và người CBTT của công ty đại chúng — representative_role_code phân biệt 2 vai trò. FK to Public Company. |
| 30 | pblc_co_rel_ent | Công ty mẹ/con/liên kết của công ty đại chúng — tên/MST/vốn/tỷ lệ sở hữu/thời hạn hiệu lực. FK to Public Company. |
| 31 | stk_hldr | Cổ đông giao dịch — cá nhân hoặc tổ chức nắm giữ cổ phần công ty đại chúng. Grain: cổ đông x công ty. FK to Public Company. |
| 32 | stk_hldr_rltnp | Quan hệ giữa các cổ đông giao dịch — loại quan hệ/thời hạn/trạng thái. FK to Stock Holder x 2. |
| 33 | pblc_co_trsr_stk_avy | Giao dịch cổ phiếu quỹ theo năm — số lượng mua/bán và số đợt. FK to Public Company. |
| 34 | ip_alt_identn | Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn. |
| 35 | ip_elc_adr | Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn. |
| 36 | ip_pst_adr | Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn. |




### Bảng pblc_co_ste_cptl



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | pblc_co_ste_cptl_id | STRING |  | X | P |  | Khóa đại diện cho bản ghi sở hữu nhà nước trong công ty đại chúng. |
| 2 | pblc_co_ste_cptl_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.state_capital' | Mã nguồn dữ liệu. |
| 4 | pblc_co_id | STRING |  |  | F |  | FK đến công ty đại chúng. |
| 5 | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. |
| 6 | ste_rprs_nm | STRING | X |  |  |  | Tên đại diện nhà nước (tiếng Việt). |
| 7 | ste_rprs_en_nm | STRING | X |  |  |  | Tên đại diện nhà nước (tiếng Anh). |
| 8 | own_shr_qty | INT | X |  |  |  | Số cổ phiếu sở hữu nhà nước. |
| 9 | own_rto | DECIMAL(5,2) | X |  |  |  | Tỷ lệ phần trăm sở hữu nhà nước. |
| 10 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 11 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 12 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 13 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| pblc_co_ste_cptl_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| pblc_co_id | pblc_co | pblc_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng stk_hldr_tdg_ac



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | stk_hldr_tdg_ac_id | STRING |  | X | P |  | Khóa đại diện cho tài khoản giao dịch của cổ đông. |
| 2 | stk_hldr_tdg_ac_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.account_numbers' | Mã nguồn dữ liệu. |
| 4 | stk_hldr_id | STRING |  |  | F |  | FK đến cổ đông. |
| 5 | stk_hldr_code | STRING |  |  |  |  | Mã cổ đông. |
| 6 | tdg_ac_nbr | STRING | X |  |  |  | Số tài khoản giao dịch. |
| 7 | scr_co_code | STRING | X |  | F |  | Mã công ty chứng khoán. |
| 8 | ac_opn_dt | DATE | X |  |  |  | Ngày mở tài khoản. |
| 9 | actv_f | BOOLEAN | X |  |  |  | Trạng thái hoạt động tài khoản (1=active / 0=inactive). |
| 10 | prim_ac_f | BOOLEAN | X |  |  |  | Tài khoản chính (1=chính / 0=không chính). |
| 11 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 12 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 13 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 14 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| stk_hldr_tdg_ac_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| stk_hldr_id | stk_hldr | stk_hldr_id |



#### Index

N/A

#### Trigger

N/A




### Bảng audt_firm_sanction



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | audt_firm_sanction_id | STRING |  | X | P |  | Khóa đại diện cho xử phạt hành chính công ty kiểm toán/kiểm toán viên. |
| 2 | audt_firm_sanction_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.af_sanctions' | Mã nguồn dữ liệu. |
| 4 | audt_firm_aprv_id | STRING | X |  | F |  | FK đến hồ sơ chấp thuận công ty kiểm toán (nullable khi đối tượng là KTV). |
| 5 | audt_firm_aprv_code | STRING | X |  |  |  | Mã hồ sơ chấp thuận công ty kiểm toán. |
| 6 | auditor_aprv_id | STRING | X |  | F |  | FK đến hồ sơ chấp thuận kiểm toán viên (nullable khi đối tượng là công ty KT). |
| 7 | auditor_aprv_code | STRING | X |  |  |  | Mã hồ sơ chấp thuận kiểm toán viên. |
| 8 | sanction_trgt_tp_code | STRING | X |  |  |  | Đối tượng xử phạt (công ty kiểm toán hay kiểm toán viên). |
| 9 | sanction_ahr_code | STRING | X |  |  |  | Đơn vị xử phạt (BTC hay UBCKNN). |
| 10 | dcsn_nbr | STRING | X |  |  |  | Số quyết định xử phạt. |
| 11 | dcsn_dt | DATE | X |  |  |  | Ngày quyết định xử phạt. |
| 12 | sanction_cntnt | STRING | X |  |  |  | Nội dung quyết định xử phạt. |
| 13 | attch_file_url | STRING | X |  |  |  | Đường dẫn file đính kèm. |
| 14 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 15 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 16 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 17 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| audt_firm_sanction_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| audt_firm_aprv_id | audt_firm_aprv | audt_firm_aprv_id |
| auditor_aprv_id | auditor_aprv | auditor_aprv_id |



#### Index

N/A

#### Trigger

N/A




### Bảng audt_firm_wrn



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | audt_firm_wrn_id | STRING |  | X | P |  | Khóa đại diện cho nhắc nhở công ty kiểm toán/kiểm toán viên. |
| 2 | audt_firm_wrn_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.af_warning' | Mã nguồn dữ liệu. |
| 4 | audt_firm_aprv_id | STRING | X |  | F |  | FK đến hồ sơ chấp thuận công ty kiểm toán (nullable khi đối tượng là KTV). |
| 5 | audt_firm_aprv_code | STRING | X |  |  |  | Mã hồ sơ chấp thuận công ty kiểm toán. |
| 6 | auditor_aprv_id | STRING | X |  | F |  | FK đến hồ sơ chấp thuận kiểm toán viên (nullable khi đối tượng là công ty KT). |
| 7 | auditor_aprv_code | STRING | X |  |  |  | Mã hồ sơ chấp thuận kiểm toán viên. |
| 8 | wrn_trgt_tp_code | STRING | X |  |  |  | Đối tượng nhắc nhở (công ty kiểm toán hay kiểm toán viên). |
| 9 | wrn_src_tp_code | STRING | X |  |  |  | Cơ quan nhắc nhở (BTC hay UBCKNN). |
| 10 | wrn_doc_nbr | STRING | X |  |  |  | Số văn bản quyết định nhắc nhở. |
| 11 | wrn_issu_dt | DATE | X |  |  |  | Ngày ban hành văn bản nhắc nhở. |
| 12 | wrn_strt_dt | DATE | X |  |  |  | Ngày bắt đầu hiệu lực nhắc nhở. |
| 13 | wrn_end_dt | DATE | X |  |  |  | Ngày kết thúc hiệu lực nhắc nhở. |
| 14 | wrn_cntnt | STRING | X |  |  |  | Nội dung quyết định nhắc nhở. |
| 15 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 16 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 17 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 18 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| audt_firm_wrn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| audt_firm_aprv_id | audt_firm_aprv | audt_firm_aprv_id |
| auditor_aprv_id | auditor_aprv | auditor_aprv_id |



#### Index

N/A

#### Trigger

N/A




### Bảng pblc_co_cptl_incr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | pblc_co_cptl_incr_id | STRING |  | X | P |  | Khóa đại diện cho bản ghi tăng vốn điều lệ sau khi thành công ty đại chúng. |
| 2 | pblc_co_cptl_incr_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.company_add_capital' | Mã nguồn dữ liệu. |
| 4 | pblc_co_id | STRING |  |  | F |  | FK đến công ty đại chúng. |
| 5 | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. |
| 6 | rpt_yr | INT | X |  |  |  | Năm điều chỉnh vốn góp. |
| 7 | paid_in_cptl_end_of_fyr_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ thực góp tính đến thời điểm kết thúc năm tài chính. |
| 8 | cptl_incr_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ tăng thêm so với năm trước. |
| 9 | cptl_incr_cnt | INT | X |  |  |  | Số đợt tăng vốn trong năm. |
| 10 | licensing_ahr_nm | STRING | X |  |  |  | Đơn vị cấp phép (tiếng Việt). |
| 11 | licensing_ahr_en_nm | STRING | X |  |  |  | Đơn vị cấp phép (tiếng Anh). |
| 12 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 13 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 14 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 15 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| pblc_co_cptl_incr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| pblc_co_id | pblc_co | pblc_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng pblc_co_cptl_mobilization



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | pblc_co_cptl_mobilization_id | STRING |  | X | P |  | Khóa đại diện cho bản ghi tăng vốn trước khi thành công ty đại chúng. |
| 2 | pblc_co_cptl_mobilization_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.capital_mobilization' | Mã nguồn dữ liệu. |
| 4 | pblc_co_id | STRING |  |  | F |  | FK đến công ty đại chúng. |
| 5 | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. |
| 6 | rpt_yr | INT | X |  |  |  | Năm điều chỉnh vốn góp. |
| 7 | paid_in_cptl_eoy_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ thực góp tính đến thời điểm cuối năm. |
| 8 | cptl_incr_cnt | INT | X |  |  |  | Số đợt tăng vốn trong năm. |
| 9 | cptl_incr_mth | STRING | X |  |  |  | Hình thức tăng vốn. |
| 10 | audt_firm_nm | STRING | X |  | F |  | Tên công ty kiểm toán xác nhận (tiếng Việt). |
| 11 | audt_firm_en_nm | STRING | X |  |  |  | Tên công ty kiểm toán xác nhận (tiếng Anh). |
| 12 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 13 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 14 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 15 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| pblc_co_cptl_mobilization_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| pblc_co_id | pblc_co | pblc_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng pblc_co_insp



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | pblc_co_insp_id | STRING |  | X | P |  | Khóa đại diện cho bản ghi thanh tra/kiểm tra công ty đại chúng. |
| 2 | pblc_co_insp_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.company_inspection' | Mã nguồn dữ liệu. |
| 4 | pblc_co_id | STRING |  |  | F |  | FK đến công ty đại chúng. |
| 5 | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. |
| 6 | insp_tp_code | STRING | X |  |  |  | Loại thanh tra/kiểm tra. |
| 7 | dcsn_nbr | STRING | X |  |  |  | Số quyết định thanh tra/kiểm tra. |
| 8 | dcsn_dt | DATE | X |  |  |  | Ngày quyết định. |
| 9 | insp_prd | STRING | X |  |  |  | Thời kỳ thanh tra/kiểm tra. |
| 10 | insp_dt | DATE | X |  |  |  | Thời gian thanh tra/kiểm tra. |
| 11 | insp_mode_code | STRING | X |  |  |  | Thanh tra định kỳ/bất thường. |
| 12 | insp_scop | STRING | X |  |  |  | Nội dung kiểm tra/thanh tra. |
| 13 | lead_insp_unit_nm | STRING | X |  | F |  | Đơn vị chủ trì kiểm tra/thanh tra (tiếng Việt). |
| 14 | lead_insp_unit_en_nm | STRING | X |  |  |  | Đơn vị chủ trì kiểm tra/thanh tra (tiếng Anh). |
| 15 | insp_mins_nm | STRING | X |  |  |  | Tên biên bản kiểm tra/thanh tra. |
| 16 | insp_file_url | STRING | X |  |  |  | Đường dẫn biên bản kiểm tra/thanh tra. |
| 17 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 18 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 19 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 20 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| pblc_co_insp_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| pblc_co_id | pblc_co | pblc_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng pblc_co_pny



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | pblc_co_pny_id | STRING |  | X | P |  | Khóa đại diện cho quyết định xử phạt hành chính. |
| 2 | pblc_co_pny_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.company_penalize' | Mã nguồn dữ liệu. |
| 4 | pblc_co_id | STRING |  |  | F |  | FK đến công ty đại chúng. |
| 5 | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. |
| 6 | penalized_sbj_tp_code | STRING | X |  |  |  | Đối tượng bị xử phạt (công ty đại chúng / nhà đầu tư liên quan). |
| 7 | ivsr_nm | STRING | X |  |  |  | Tên nhà đầu tư bị xử phạt (null khi đối tượng là công ty). |
| 8 | ivsr_identn_nbr | STRING | X |  |  |  | Số CCCD/Hộ chiếu của nhà đầu tư. |
| 9 | ivsr_pos_ttl | STRING | X |  |  |  | Chức vụ của nhà đầu tư. |
| 10 | pny_dcsn_nbr | STRING | X |  |  |  | Số quyết định xử phạt. |
| 11 | pny_dcsn_dt | DATE | X |  |  |  | Ngày quyết định xử phạt. |
| 12 | vln_dsc | STRING | X |  |  |  | Mô tả hành vi vi phạm. |
| 13 | pny_form | STRING | X |  |  |  | Hình thức phạt chính. |
| 14 | pny_amt | DECIMAL(23,2) | X |  |  |  | Số tiền phạt. |
| 15 | adl_pny | STRING | X |  |  |  | Hình thức phạt bổ sung. |
| 16 | remedial_mins | STRING | X |  |  |  | Biên bản khắc phục hậu quả. |
| 17 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 18 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 19 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 20 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| pblc_co_pny_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| pblc_co_id | pblc_co | pblc_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng pblc_co_scr_ofrg



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | pblc_co_scr_ofrg_id | STRING |  | X | P |  | Khóa đại diện cho đợt phát hành chứng khoán. |
| 2 | pblc_co_scr_ofrg_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.company_securities_issuance' | Mã nguồn dữ liệu. |
| 4 | pblc_co_id | STRING |  |  | F |  | FK đến công ty đại chúng. |
| 5 | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. |
| 6 | scr_tp_code | STRING | X |  |  |  | Loại chứng khoán phát hành. |
| 7 | ctf_nbr | STRING | X |  |  |  | Số giấy chứng nhận chào bán. |
| 8 | ctf_issu_dt | DATE | X |  |  |  | Ngày cấp giấy chứng nhận. |
| 9 | ssc_offc_doc_nbr | STRING | X |  |  |  | Số công văn của UBCKNN. |
| 10 | ssc_offc_doc_dt | DATE | X |  |  |  | Ngày công văn của UBCKNN. |
| 11 | multi_ofrg_f | BOOLEAN | X |  |  |  | Có chào bán nhiều đợt (1=có / 0=không). |
| 12 | pln_scr_qty | INT | X |  |  |  | Tổng số chứng khoán dự kiến chào bán/phát hành. |
| 13 | pln_procd_amt | DECIMAL(23,2) | X |  |  |  | Tổng số tiền dự kiến thu được (VNĐ). |
| 14 | prj_ivsm_f | BOOLEAN | X |  |  |  | Có đầu tư dự án (1=có / 0=không). |
| 15 | procd_usg_pln | STRING | X |  |  |  | Phương án sử dụng vốn thu được. |
| 16 | pln_exst_shrhlr_ofrg_qty | INT | X |  |  |  | Chào bán cho cổ đông hiện hữu — số lượng dự kiến. |
| 17 | pln_exst_shrhlr_ofrg_prc | DECIMAL(23,2) | X |  |  |  | Chào bán cho cổ đông hiện hữu — giá dự kiến. |
| 18 | rslt_exst_shrhlr_ofrg_qty | INT | X |  |  |  | Chào bán cho cổ đông hiện hữu — số lượng thực tế. |
| 19 | rslt_exst_shrhlr_ofrg_prc | DECIMAL(23,2) | X |  |  |  | Chào bán cho cổ đông hiện hữu — giá thực tế. |
| 20 | pln_auctn_ofrg_qty | INT | X |  |  |  | Đấu giá — số lượng dự kiến. |
| 21 | pln_auctn_ofrg_prc | DECIMAL(23,2) | X |  |  |  | Đấu giá — giá dự kiến. |
| 22 | rslt_auctn_ofrg_qty | INT | X |  |  |  | Đấu giá — số lượng thực tế. |
| 23 | rslt_auctn_ofrg_prc | DECIMAL(23,2) | X |  |  |  | Đấu giá — giá thực tế. |
| 24 | pln_pblc_othr_ofrg_qty | INT | X |  |  |  | Chào bán ra công chúng theo hình thức khác — số lượng dự kiến. |
| 25 | pln_pblc_othr_ofrg_prc | DECIMAL(23,2) | X |  |  |  | Chào bán ra công chúng theo hình thức khác — giá dự kiến. |
| 26 | rslt_pblc_othr_ofrg_qty | INT | X |  |  |  | Chào bán ra công chúng theo hình thức khác — số lượng thực tế. |
| 27 | rslt_pblc_othr_ofrg_prc | DECIMAL(23,2) | X |  |  |  | Chào bán ra công chúng theo hình thức khác — giá thực tế. |
| 28 | pln_pblc_co_ofrg_qty | INT | X |  |  |  | Chào bán của công ty đại chúng ra công chúng — số lượng dự kiến. |
| 29 | pln_pblc_co_ofrg_prc | DECIMAL(23,2) | X |  |  |  | Chào bán của công ty đại chúng ra công chúng — giá dự kiến. |
| 30 | rslt_pblc_co_ofrg_qty | INT | X |  |  |  | Chào bán của công ty đại chúng ra công chúng — số lượng thực tế. |
| 31 | rslt_pblc_co_ofrg_prc | DECIMAL(23,2) | X |  |  |  | Chào bán của công ty đại chúng ra công chúng — giá thực tế. |
| 32 | pln_prvt_plcmt_ofrg_qty | INT | X |  |  |  | Chào bán cổ phiếu riêng lẻ — số lượng dự kiến. |
| 33 | pln_prvt_plcmt_ofrg_prc | DECIMAL(23,2) | X |  |  |  | Chào bán cổ phiếu riêng lẻ — giá dự kiến. |
| 34 | pln_prvt_plcmt_ofrg_trgt | STRING | X |  |  |  | Chào bán cổ phiếu riêng lẻ — đối tượng dự kiến. |
| 35 | rslt_prvt_plcmt_ofrg_qty | INT | X |  |  |  | Chào bán cổ phiếu riêng lẻ — số lượng thực tế. |
| 36 | rslt_prvt_plcmt_ofrg_prc | DECIMAL(23,2) | X |  |  |  | Chào bán cổ phiếu riêng lẻ — giá thực tế. |
| 37 | rslt_prvt_plcmt_ofrg_trgt | STRING | X |  |  |  | Chào bán cổ phiếu riêng lẻ — đối tượng thực tế. |
| 38 | pln_cnvr_ofrg_qty | INT | X |  |  |  | Hoán đổi — số lượng dự kiến. |
| 39 | pln_cnvr_ofrg_trgt | STRING | X |  |  |  | Hoán đổi — đối tượng dự kiến. |
| 40 | rslt_cnvr_ofrg_qty | INT | X |  |  |  | Hoán đổi — số lượng thực tế. |
| 41 | rslt_cnvr_ofrg_trgt | STRING | X |  |  |  | Hoán đổi — đối tượng thực tế. |
| 42 | pln_dvdn_issn_qty | INT | X |  |  |  | Phát hành trả cổ tức — số lượng dự kiến. |
| 43 | rslt_dvdn_issn_qty | INT | X |  |  |  | Phát hành trả cổ tức — số lượng thực tế. |
| 44 | pln_own_cptl_issn_qty | INT | X |  |  |  | Phát hành cổ phiếu từ nguồn vốn chủ sở hữu — số lượng dự kiến. |
| 45 | pln_own_cptl_issn_src | STRING | X |  |  |  | Phát hành cổ phiếu từ nguồn vốn chủ sở hữu — nguồn dự kiến. |
| 46 | rslt_own_cptl_issn_qty | INT | X |  |  |  | Phát hành cổ phiếu từ nguồn vốn chủ sở hữu — số lượng thực tế. |
| 47 | rslt_own_cptl_issn_src | STRING | X |  |  |  | Phát hành cổ phiếu từ nguồn vốn chủ sở hữu — nguồn thực tế. |
| 48 | pln_esop_issn_qty | INT | X |  |  |  | Phát hành cổ phiếu cho người lao động — số lượng dự kiến. |
| 49 | pln_esop_issn_prc | DECIMAL(23,2) | X |  |  |  | Phát hành cổ phiếu cho người lao động — giá dự kiến. |
| 50 | pln_esop_issn_trgt | STRING | X |  |  |  | Phát hành cổ phiếu cho người lao động — đối tượng dự kiến. |
| 51 | rslt_esop_issn_qty | INT | X |  |  |  | Phát hành cổ phiếu cho người lao động — số lượng thực tế. |
| 52 | rslt_esop_issn_prc | DECIMAL(23,2) | X |  |  |  | Phát hành cổ phiếu cho người lao động — giá thực tế. |
| 53 | rslt_esop_issn_trgt | STRING | X |  |  |  | Phát hành cổ phiếu cho người lao động — đối tượng thực tế. |
| 54 | pln_bns_shr_issn_qty | INT | X |  |  |  | Phát hành cổ phiếu thưởng cho người lao động — số lượng dự kiến. |
| 55 | pln_bns_shr_issn_trgt | STRING | X |  |  |  | Phát hành cổ phiếu thưởng cho người lao động — đối tượng dự kiến. |
| 56 | pln_bns_shr_issn_prc | DECIMAL(23,2) | X |  |  |  | Phát hành cổ phiếu thưởng cho người lao động — giá dự kiến. |
| 57 | rslt_bns_shr_issn_qty | INT | X |  |  |  | Phát hành cổ phiếu thưởng cho người lao động — số lượng thực tế. |
| 58 | rslt_bns_shr_issn_trgt | STRING | X |  |  |  | Phát hành cổ phiếu thưởng cho người lao động — đối tượng thực tế. |
| 59 | rslt_bns_shr_issn_prc | DECIMAL(23,2) | X |  |  |  | Phát hành cổ phiếu thưởng cho người lao động — giá thực tế. |
| 60 | pln_itnl_bond_ofrg_qty | INT | X |  |  |  | Chào bán trái phiếu giao dịch quốc tế — số lượng dự kiến. |
| 61 | pln_itnl_bond_ofrg_prc | DECIMAL(23,2) | X |  |  |  | Chào bán trái phiếu giao dịch quốc tế — giá dự kiến. |
| 62 | rslt_itnl_bond_ofrg_qty | INT | X |  |  |  | Chào bán trái phiếu giao dịch quốc tế — số lượng thực tế. |
| 63 | rslt_itnl_bond_ofrg_prc | DECIMAL(23,2) | X |  |  |  | Chào bán trái phiếu giao dịch quốc tế — giá thực tế. |
| 64 | ofrg_end_dt | DATE | X |  |  |  | Ngày kết thúc đợt chào bán. |
| 65 | scss_scr_qty | INT | X |  |  |  | Tổng số chứng khoán chào bán/phát hành thành công. |
| 66 | act_procd_amt | DECIMAL(23,2) | X |  |  |  | Tổng số tiền thực thu từ đợt chào bán/phát hành (VNĐ). |
| 67 | cptl_usg_pln | STRING | X |  |  |  | Phương án sử dụng vốn. |
| 68 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 69 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 70 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 71 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| pblc_co_scr_ofrg_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| pblc_co_id | pblc_co | pblc_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng pblc_co_tender_ofr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | pblc_co_tender_ofr_id | STRING |  | X | P |  | Khóa đại diện cho đợt chào mua công khai. |
| 2 | pblc_co_tender_ofr_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.company_tender_offer' | Mã nguồn dữ liệu. |
| 4 | pblc_co_id | STRING |  |  | F |  | FK đến công ty đại chúng (công ty mục tiêu). |
| 5 | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. |
| 6 | tender_offeror_nm | STRING | X |  |  |  | Tên tổ chức/cá nhân chào mua công khai (tiếng Việt). |
| 7 | tender_offeror_en_nm | STRING | X |  |  |  | Tên tổ chức/cá nhân chào mua công khai (tiếng Anh). |
| 8 | tender_offeror_identn_nbr | STRING | X |  |  |  | Số CMND/Hộ chiếu/GCN ĐKDN của bên chào mua. |
| 9 | tender_offeror_rltnp | STRING | X |  |  |  | Mối quan hệ giữa bên chào mua với công ty mục tiêu. |
| 10 | scr_agnt_nm | STRING | X |  |  |  | Tên công ty chứng khoán làm đại lý (tiếng Việt). |
| 11 | scr_agnt_en_nm | STRING | X |  |  |  | Tên công ty chứng khoán làm đại lý (tiếng Anh). |
| 12 | pln_ofr_fm_dt | DATE | X |  |  |  | Thời gian dự kiến chào mua — từ ngày. |
| 13 | pln_ofr_to_dt | DATE | X |  |  |  | Thời gian dự kiến chào mua — đến ngày. |
| 14 | pre_ofr_shr_qty | INT | X |  |  |  | Số cổ phiếu sở hữu trước khi chào mua. |
| 15 | pre_ofr_shr_rto | DECIMAL(5,2) | X |  |  |  | Tỷ lệ cổ phiếu sở hữu trước khi chào mua. |
| 16 | pln_ofr_shr_qty | INT | X |  |  |  | Số cổ phiếu dự kiến chào mua. |
| 17 | pln_ofr_shr_rto | DECIMAL(5,2) | X |  |  |  | Tỷ lệ cổ phiếu dự kiến chào mua. |
| 18 | pln_ofr_prc_amt | DECIMAL(23,2) | X |  |  |  | Giá chào mua. |
| 19 | acq_shr_qty | INT | X |  |  |  | Số cổ phiếu mua được trong đợt chào mua. |
| 20 | acq_shr_rto | DECIMAL(5,2) | X |  |  |  | Tỷ lệ cổ phiếu mua được trong đợt chào mua. |
| 21 | pst_ofr_shr_qty | INT | X |  |  |  | Số cổ phiếu sở hữu sau khi chào mua. |
| 22 | pst_ofr_shr_rto | DECIMAL(5,2) | X |  |  |  | Tỷ lệ cổ phiếu sở hữu sau khi chào mua. |
| 23 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 24 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 25 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 26 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| pblc_co_tender_ofr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| pblc_co_id | pblc_co | pblc_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng dscl_notf



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | dscl_notf_id | STRING |  | X | P |  | Khóa đại diện cho instance thông báo CBTT. |
| 2 | dscl_notf_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.notifications' | Mã nguồn dữ liệu. |
| 4 | notf_bsn_code | STRING | X |  |  |  | Mã thông báo (mã nghiệp vụ). |
| 5 | dscl_form_defn_id | STRING | X |  | F |  | FK đến định nghĩa loại hồ sơ/tin CBTT. |
| 6 | dscl_form_defn_code | STRING | X |  |  |  | Mã định nghĩa loại hồ sơ/tin CBTT. |
| 7 | notf_ttl | STRING | X |  |  |  | Tiêu đề thông báo (tiếng Việt). |
| 8 | notf_en_ttl | STRING | X |  |  |  | Tiêu đề thông báo (tiếng Anh). |
| 9 | notf_cntnt | STRING | X |  |  |  | Nội dung thông báo (tiếng Việt). |
| 10 | notf_en_cntnt | STRING | X |  |  |  | Nội dung thông báo (tiếng Anh). |
| 11 | snd_shd_tp_code | STRING | X |  |  |  | Lịch gửi tin định kỳ. |
| 12 | mo_snd_day | INT | X |  |  |  | Ngày gửi thông báo định kỳ trong tháng. |
| 13 | mo_snd_mo | INT | X |  |  |  | Tháng định kỳ gửi thông báo. |
| 14 | news_st_code | STRING | X |  |  |  | Trạng thái tin thông báo. |
| 15 | news_tp_code | STRING | X |  |  |  | Loại tin gốc. |
| 16 | snd_dt | DATE | X |  |  |  | Ngày gửi tin. |
| 17 | file_url | STRING | X |  |  |  | Đường dẫn file đính kèm. |
| 18 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 19 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 20 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 21 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| dscl_notf_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| dscl_form_defn_id | dscl_form_defn | dscl_form_defn_id |



#### Index

N/A

#### Trigger

N/A




### Bảng dscl_form_defn



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | dscl_form_defn_id | STRING |  | X | P |  | Khóa đại diện cho định nghĩa loại hồ sơ/tin CBTT. |
| 2 | dscl_form_defn_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.forms' | Mã nguồn dữ liệu. |
| 4 | dscl_form_defn_bsn_code | STRING | X |  |  |  | Mã form (mã nghiệp vụ). |
| 5 | dscl_form_defn_nm | STRING | X |  |  |  | Tên form (tiếng Việt). |
| 6 | dscl_form_defn_en_nm | STRING | X |  |  |  | Tên form (tiếng Anh). |
| 7 | form_tp_code | STRING | X |  |  |  | Loại tin hay hồ sơ (hồ sơ, cbtt). |
| 8 | news_tp_code | STRING | X |  |  |  | Loại tin gốc. |
| 9 | sub_news_tp_code | STRING | X |  |  |  | Loại tin con. |
| 10 | ofcr_aprv_f | BOOLEAN | X |  |  |  | Chuyên viên tự động duyệt (1=đã duyệt / 0=chưa duyệt). |
| 11 | pst_checked_f | BOOLEAN | X |  |  |  | Hậu kiểm tin (1=đã kiểm tra / 0=chưa kiểm tra). |
| 12 | activated_f | BOOLEAN | X |  |  |  | Kích hoạt (1=đã kích hoạt / 0=chưa kích hoạt). |
| 13 | ca_signed_f | BOOLEAN | X |  |  |  | Ký CA (chứng thư số): 0=bắt buộc / 1=không bắt buộc. |
| 14 | leader_aprv_f | BOOLEAN | X |  |  |  | Form tự động duyệt cấp lãnh đạo (1=đã duyệt / 0=chưa duyệt). |
| 15 | published_f | BOOLEAN | X |  |  |  | Form được công bố (1=được công bố / 0=chưa công bố). |
| 16 | ttl_frml | STRING | X |  |  |  | Công thức cho tiêu đề form tin. |
| 17 | prn_dscl_form_defn_id | STRING | X |  | F |  | FK đến form cha (self-join). |
| 18 | prn_dscl_form_defn_code | STRING | X |  |  |  | Mã form cha. |
| 19 | rpt_tp | STRING | X |  |  |  | Loại báo cáo (tháng, quý, năm, bán niên...). |
| 20 | cntl_unit_code | STRING | X |  | F |  | Đơn vị kiểm soát (Dept_cd của bảng departments). |
| 21 | oprg_unit_codes | STRING | X |  |  |  | Đơn vị sử dụng (nhiều đơn vị cách nhau bằng ";" Dept_cd của bảng departments). |
| 22 | crt_usr | STRING | X |  |  |  | User khi tạo hồ sơ thuộc (ny/tv). |
| 23 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 24 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 25 | crt_dt | TIMESTAMP | X |  |  |  | Ngày tạo (legacy field). |
| 26 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 27 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| dscl_form_defn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prn_dscl_form_defn_id | dscl_form_defn | dscl_form_defn_id |



#### Index

N/A

#### Trigger

N/A




### Bảng dscl_notf_config



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | dscl_notf_config_id | STRING |  | X | P |  | Khóa đại diện cho cấu hình thông báo CBTT. |
| 2 | dscl_notf_config_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.noti_config' | Mã nguồn dữ liệu. |
| 4 | dscl_notf_id | STRING |  |  | F |  | FK đến instance thông báo CBTT. |
| 5 | dscl_notf_code | STRING |  |  |  |  | Mã thông báo CBTT. |
| 6 | notf_bsn_code | STRING | X |  |  |  | Mã thông báo (denormalized từ notifications). |
| 7 | notf_ttl | STRING | X |  |  |  | Tiêu đề thông báo (tiếng Việt — denormalized từ notifications). |
| 8 | notf_en_ttl | STRING | X |  |  |  | Tiêu đề thông báo (tiếng Anh — denormalized từ notifications). |
| 9 | snd_cnl_code | STRING | X |  |  |  | Hình thức gửi tin (email/sms/push). |
| 10 | actv_f | BOOLEAN | X |  |  |  | Trạng thái kích hoạt (1=kích hoạt / 0=không). |
| 11 | trgt_stm_code | STRING | X |  |  |  | Hệ thống nhận thông báo. |
| 12 | mgr_login_id | STRING | X |  | F |  | Id người quản lý (logins). |
| 13 | mgr_login_nm | STRING | X |  |  |  | Tên đăng nhập người quản lý. |
| 14 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 15 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 16 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 17 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| dscl_notf_config_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| dscl_notf_id | dscl_notf | dscl_notf_id |



#### Index

N/A

#### Trigger

N/A




### Bảng fnc_rpt_ctlg



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | fnc_rpt_ctlg_id | STRING |  | X | P |  | Khóa đại diện cho biểu mẫu BCTC. |
| 2 | fnc_rpt_ctlg_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.report_catalog' | Mã nguồn dữ liệu. |
| 4 | fnc_rpt_ctlg_bsn_code | STRING | X |  |  |  | Mã báo cáo (mã nghiệp vụ). |
| 5 | fnc_rpt_ctlg_nm | STRING | X |  |  |  | Tên báo cáo (tiếng Việt). |
| 6 | fnc_rpt_ctlg_en_nm | STRING | X |  |  |  | Tên báo cáo (tiếng Anh). |
| 7 | rpt_drc_tp_code | STRING | X |  |  |  | Loại báo cáo: i=báo cáo đầu vào, o=báo cáo đầu ra. |
| 8 | rpt_yr | INT | X |  |  |  | Năm của báo cáo. |
| 9 | rpt_scop_code | STRING | X |  |  |  | Loại hình báo cáo (hợp nhất, mẹ). |
| 10 | entp_tp_code | STRING | X |  |  |  | Loại hình doanh nghiệp (dn-doanh nghiệp, bh-bảo hiểm, td-tín dụng, ck-chứng khoán). |
| 11 | cnsld_f | BOOLEAN | X |  |  |  | Là báo cáo hợp nhất (1=có / 0=không). |
| 12 | actv_f | BOOLEAN | X |  |  |  | Trạng thái sử dụng (1=đang sử dụng / 0=không sử dụng). |
| 13 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 14 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 15 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 16 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| fnc_rpt_ctlg_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng fnc_rpt_clmn_tpl



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | fnc_rpt_clmn_tpl_id | STRING |  | X | P |  | Khóa đại diện cho cột biểu mẫu BCTC. |
| 2 | fnc_rpt_clmn_tpl_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.rcol' | Mã nguồn dữ liệu. |
| 4 | fnc_rpt_ctlg_id | STRING |  |  | F |  | FK đến biểu mẫu BCTC. |
| 5 | fnc_rpt_ctlg_code | STRING |  |  |  |  | Mã biểu mẫu BCTC. |
| 6 | clmn_code | STRING | X |  |  |  | Mã cột. |
| 7 | clmn_nm | STRING | X |  |  |  | Tên cột (tiếng Việt). |
| 8 | clmn_en_nm | STRING | X |  |  |  | Tên cột (tiếng Anh). |
| 9 | clmn_tp_code | STRING | X |  |  |  | Loại giá trị của cột. |
| 10 | clmn_frml | STRING | X |  |  |  | Công thức cột. |
| 11 | clmn_indx | INT | X |  |  |  | Chỉ số (thứ tự) của cột. |
| 12 | rpt_yr | INT | X |  |  |  | Năm tạo báo cáo (denormalized từ report_catalog). |
| 13 | rpt_drc_tp_code | STRING | X |  |  |  | Loại báo cáo (denormalized từ report_catalog). |
| 14 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 15 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 16 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 17 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| fnc_rpt_clmn_tpl_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| fnc_rpt_ctlg_id | fnc_rpt_ctlg | fnc_rpt_ctlg_id |



#### Index

N/A

#### Trigger

N/A




### Bảng fnc_rpt_row_tpl



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | fnc_rpt_row_tpl_id | STRING |  | X | P |  | Khóa đại diện cho hàng biểu mẫu BCTC. |
| 2 | fnc_rpt_row_tpl_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.rrow' | Mã nguồn dữ liệu. |
| 4 | fnc_rpt_ctlg_id | STRING |  |  | F |  | FK đến biểu mẫu BCTC. |
| 5 | fnc_rpt_ctlg_code | STRING |  |  |  |  | Mã biểu mẫu BCTC. |
| 6 | row_code | STRING | X |  |  |  | Mã hàng (auto-generated theo quy tắc r+sequence). |
| 7 | row_nm | STRING | X |  |  |  | Tên hàng (tiếng Việt). |
| 8 | row_en_nm | STRING | X |  |  |  | Tên hàng (tiếng Anh). |
| 9 | row_tp_code | STRING | X |  |  |  | Kiểu giá trị của hàng: v=value, f=formula, d=description. |
| 10 | row_frml | STRING | X |  |  |  | Công thức của hàng. |
| 11 | row_dsc_clmn_code | STRING | X |  |  |  | Mô tả nội dung của hàng (hiện đang lưu mã cột). |
| 12 | row_indx | INT | X |  |  |  | Thứ tự hàng. |
| 13 | rpt_yr | INT | X |  |  |  | Năm tạo báo cáo (denormalized từ report_catalog). |
| 14 | rpt_drc_tp_code | STRING | X |  |  |  | Loại báo cáo (denormalized từ report_catalog). |
| 15 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 16 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 17 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 18 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| fnc_rpt_row_tpl_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| fnc_rpt_ctlg_id | fnc_rpt_ctlg | fnc_rpt_ctlg_id |



#### Index

N/A

#### Trigger

N/A




### Bảng prd_rpt_form



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | prd_rpt_form_id | STRING |  | X | P |  | Khóa đại diện cho biểu mẫu báo cáo định kỳ. |
| 2 | prd_rpt_form_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.rep_forms' | Mã nguồn dữ liệu. |
| 4 | prd_rpt_form_bsn_code | STRING | X |  |  |  | Mã form (mã nghiệp vụ). |
| 5 | prd_rpt_form_nm | STRING | X |  |  |  | Tên form báo cáo (tiếng Việt). |
| 6 | prd_rpt_form_en_nm | STRING | X |  |  |  | Tên form báo cáo (tiếng Anh). |
| 7 | rpt_frq_tp_code | STRING | X |  |  |  | Loại báo cáo định kỳ (0=BC tháng / 1=BC quý / 2=BC năm / 3=BC thường niên / 4=BC trực tuyến 6 tháng đầu năm / 5=BC trực tuyến 6 tháng cuối năm). |
| 8 | published_f | BOOLEAN | X |  |  |  | Báo cáo được công bố hay không (1=có / 0=không). |
| 9 | rpt_cfg_link | STRING | X |  |  |  | Đường link cấu hình biểu mẫu. |
| 10 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 11 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 12 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 13 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| prd_rpt_form_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng prd_rpt_form_clmn_tpl



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | prd_rpt_form_clmn_tpl_id | STRING |  | X | P |  | Khóa đại diện cho cột biểu mẫu báo cáo định kỳ. |
| 2 | prd_rpt_form_clmn_tpl_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.rep_column' | Mã nguồn dữ liệu. |
| 4 | prd_rpt_form_id | STRING |  |  | F |  | FK đến biểu mẫu báo cáo định kỳ. |
| 5 | prd_rpt_form_code | STRING |  |  |  |  | Mã biểu mẫu báo cáo định kỳ. |
| 6 | clmn_nm | STRING | X |  |  |  | Tên cột (tiếng Việt). |
| 7 | clmn_en_nm | STRING | X |  |  |  | Tên cột (tiếng Anh). |
| 8 | clmn_indx | INT | X |  |  |  | Thứ tự cột. |
| 9 | dup_clmn_f | BOOLEAN | X |  |  |  | Có cho phép nhân đôi cột (1=có / 0=không). |
| 10 | clmn_data_tp_code | STRING | X |  |  |  | Kiểu dữ liệu của cột: n=number, t=text. |
| 11 | clmn_frml | STRING | X |  |  |  | Công thức tính. |
| 12 | use_frml_f | BOOLEAN | X |  |  |  | Có sử dụng công thức tính (1=có / 0=không). |
| 13 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 14 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 15 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 16 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| prd_rpt_form_clmn_tpl_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prd_rpt_form_id | prd_rpt_form | prd_rpt_form_id |



#### Index

N/A

#### Trigger

N/A




### Bảng prd_rpt_form_row_tpl



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | prd_rpt_form_row_tpl_id | STRING |  | X | P |  | Khóa đại diện cho hàng biểu mẫu báo cáo định kỳ. |
| 2 | prd_rpt_form_row_tpl_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.rep_row' | Mã nguồn dữ liệu. |
| 4 | prd_rpt_form_id | STRING |  |  | F |  | FK đến biểu mẫu báo cáo định kỳ. |
| 5 | prd_rpt_form_code | STRING |  |  |  |  | Mã biểu mẫu báo cáo định kỳ. |
| 6 | row_nm | STRING | X |  |  |  | Tên dòng (tiếng Việt). |
| 7 | row_en_nm | STRING | X |  |  |  | Tên dòng (tiếng Anh). |
| 8 | row_indx | INT | X |  |  |  | Thứ tự dòng. |
| 9 | dup_row_f | BOOLEAN | X |  |  |  | Có cho phép nhân đôi dòng không (1=có / 0=không). |
| 10 | row_data_tp_code | STRING | X |  |  |  | Kiểu dữ liệu của dòng: v=value, d=description. |
| 11 | alw_clmn_sm_f | BOOLEAN | X |  |  |  | Có cho phép cột tính tổng (1=có / 0=không). |
| 12 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 13 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 14 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 15 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| prd_rpt_form_row_tpl_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prd_rpt_form_id | prd_rpt_form | prd_rpt_form_id |



#### Index

N/A

#### Trigger

N/A




### Bảng pblc_co_frgn_own_lmt



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | pblc_co_frgn_own_lmt_id | STRING |  | X | P |  | Khóa đại diện cho giới hạn sở hữu nước ngoài. |
| 2 | pblc_co_frgn_own_lmt_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.foreign_owner_limit' | Mã nguồn dữ liệu. |
| 4 | pblc_co_id | STRING |  |  | F |  | FK đến công ty đại chúng. |
| 5 | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. |
| 6 | max_own_rate | DECIMAL(5,2) | X |  |  |  | Tỷ lệ sở hữu nước ngoài tối đa. |
| 7 | eff_fm_dt | DATE | X |  |  |  | Ngày bắt đầu áp dụng. |
| 8 | eff_to_dt | DATE | X |  |  |  | Ngày kết thúc áp dụng. |
| 9 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 10 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 11 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 12 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| pblc_co_frgn_own_lmt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| pblc_co_id | pblc_co | pblc_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng stk_cntl



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | stk_cntl_id | STRING |  | X | P |  | Khóa đại diện cho bản ghi hạn chế chuyển nhượng cổ phiếu. |
| 2 | stk_cntl_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.stock_controls' | Mã nguồn dữ liệu. |
| 4 | stk_hldr_id | STRING |  |  | F |  | FK đến cổ đông. |
| 5 | stk_hldr_code | STRING |  |  |  |  | Mã cổ đông. |
| 6 | rstd_shr_qty | INT | X |  |  |  | Số cổ phiếu bị hạn chế chuyển nhượng. |
| 7 | rstn_strt_dt | DATE | X |  |  |  | Ngày bắt đầu hạn chế. |
| 8 | rstn_end_dt | DATE | X |  |  |  | Ngày hết hạn chế. |
| 9 | rstn_tp_code | STRING | X |  |  |  | Loại hạn chế chuyển nhượng. |
| 10 | exprt_st_f | STRING | X |  |  |  | Dùng cho giám sát (1=insert / 2=update). |
| 11 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 12 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 13 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 14 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| stk_cntl_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| stk_hldr_id | stk_hldr | stk_hldr_id |



#### Index

N/A

#### Trigger

N/A




### Bảng audt_firm_aprv



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | audt_firm_aprv_id | STRING |  | X | P |  | Khóa đại diện cho hồ sơ chấp thuận công ty kiểm toán. |
| 2 | audt_firm_aprv_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.af_approval' | Mã nguồn dữ liệu. |
| 4 | audt_firm_id | STRING |  |  | F |  | FK đến công ty kiểm toán. |
| 5 | audt_firm_code | STRING |  |  |  |  | Mã công ty kiểm toán. |
| 6 | mof_aprv_doc_nbr | STRING | X |  |  |  | Số văn bản quyết định chấp thuận của Bộ Tài chính. |
| 7 | mof_aprv_issu_dt | DATE | X |  |  |  | Ngày ban hành quyết định chấp thuận của BTC. |
| 8 | mof_aprv_strt_dt | DATE | X |  |  |  | Ngày bắt đầu hiệu lực quyết định chấp thuận của BTC. |
| 9 | mof_aprv_end_dt | DATE | X |  |  |  | Ngày kết thúc hiệu lực quyết định chấp thuận của BTC. |
| 10 | mof_aprv_cntnt | STRING | X |  |  |  | Nội dung quyết định chấp thuận của BTC. |
| 11 | ssc_aprv_doc_nbr | STRING | X |  |  |  | Số văn bản quyết định chấp thuận của UBCKNN. |
| 12 | ssc_aprv_issu_dt | DATE | X |  |  |  | Ngày ban hành quyết định chấp thuận của UBCKNN. |
| 13 | ssc_aprv_strt_dt | DATE | X |  |  |  | Ngày bắt đầu hiệu lực quyết định chấp thuận của UBCKNN. |
| 14 | ssc_aprv_end_dt | DATE | X |  |  |  | Ngày kết thúc hiệu lực quyết định chấp thuận của UBCKNN. |
| 15 | ssc_aprv_cntnt | STRING | X |  |  |  | Nội dung quyết định chấp thuận của UBCKNN. |
| 16 | mof_susp_doc_nbr | STRING | X |  |  |  | Số văn bản quyết định đình chỉ của BTC. |
| 17 | mof_susp_issu_dt | DATE | X |  |  |  | Ngày ban hành quyết định đình chỉ của BTC. |
| 18 | mof_susp_strt_dt | DATE | X |  |  |  | Ngày bắt đầu đình chỉ của BTC. |
| 19 | mof_susp_end_dt | DATE | X |  |  |  | Ngày kết thúc đình chỉ của BTC. |
| 20 | mof_susp_cntnt | STRING | X |  |  |  | Nội dung quyết định đình chỉ của BTC. |
| 21 | ssc_susp_doc_nbr | STRING | X |  |  |  | Số văn bản quyết định đình chỉ của UBCKNN. |
| 22 | ssc_susp_issu_dt | DATE | X |  |  |  | Ngày ban hành quyết định đình chỉ của UBCKNN. |
| 23 | ssc_susp_strt_dt | DATE | X |  |  |  | Ngày bắt đầu đình chỉ của UBCKNN. |
| 24 | ssc_susp_end_dt | DATE | X |  |  |  | Ngày kết thúc đình chỉ của UBCKNN. |
| 25 | ssc_susp_cntnt | STRING | X |  |  |  | Nội dung quyết định đình chỉ của UBCKNN. |
| 26 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 27 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 28 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 29 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| audt_firm_aprv_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| audt_firm_id | audt_firm | audt_firm_id |



#### Index

N/A

#### Trigger

N/A




### Bảng auditor_aprv



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | auditor_aprv_id | STRING |  | X | P |  | Khóa đại diện cho hồ sơ chấp thuận kiểm toán viên. |
| 2 | auditor_aprv_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.af_auditor_approval' | Mã nguồn dữ liệu. |
| 4 | audt_firm_id | STRING |  |  | F |  | FK đến công ty kiểm toán. |
| 5 | audt_firm_code | STRING |  |  |  |  | Mã công ty kiểm toán. |
| 6 | auditor_full_nm | STRING | X |  |  |  | Họ tên kiểm toán viên. |
| 7 | audt_practice_ctf_nbr | STRING | X |  |  |  | Số GCN đăng ký hành nghề kiểm toán. |
| 8 | pos_ttl_code | STRING | X |  |  |  | Chức vụ kiểm toán viên. |
| 9 | mof_aprv_doc_nbr | STRING | X |  |  |  | Số văn bản quyết định chấp thuận của Bộ Tài chính. |
| 10 | mof_aprv_issu_dt | DATE | X |  |  |  | Ngày ban hành quyết định chấp thuận của BTC. |
| 11 | mof_aprv_strt_dt | DATE | X |  |  |  | Ngày bắt đầu hiệu lực chấp thuận của BTC. |
| 12 | mof_aprv_end_dt | DATE | X |  |  |  | Ngày kết thúc hiệu lực chấp thuận của BTC. |
| 13 | mof_aprv_cntnt | STRING | X |  |  |  | Nội dung quyết định chấp thuận của BTC. |
| 14 | ssc_aprv_doc_nbr | STRING | X |  |  |  | Số văn bản quyết định chấp thuận của UBCKNN. |
| 15 | ssc_aprv_issu_dt | DATE | X |  |  |  | Ngày ban hành quyết định chấp thuận của UBCKNN. |
| 16 | ssc_aprv_strt_dt | DATE | X |  |  |  | Ngày bắt đầu hiệu lực chấp thuận của UBCKNN. |
| 17 | ssc_aprv_end_dt | DATE | X |  |  |  | Ngày kết thúc hiệu lực chấp thuận của UBCKNN. |
| 18 | ssc_aprv_cntnt | STRING | X |  |  |  | Nội dung quyết định chấp thuận của UBCKNN. |
| 19 | mof_susp_doc_nbr | STRING | X |  |  |  | Số văn bản quyết định đình chỉ của BTC. |
| 20 | mof_susp_issu_dt | DATE | X |  |  |  | Ngày ban hành quyết định đình chỉ của BTC. |
| 21 | mof_susp_strt_dt | DATE | X |  |  |  | Ngày bắt đầu đình chỉ của BTC. |
| 22 | mof_susp_end_dt | DATE | X |  |  |  | Ngày kết thúc đình chỉ của BTC. |
| 23 | mof_susp_cntnt | STRING | X |  |  |  | Nội dung quyết định đình chỉ của BTC. |
| 24 | ssc_susp_doc_nbr | STRING | X |  |  |  | Số văn bản quyết định đình chỉ của UBCKNN. |
| 25 | ssc_susp_issu_dt | DATE | X |  |  |  | Ngày ban hành quyết định đình chỉ của UBCKNN. |
| 26 | ssc_susp_strt_dt | DATE | X |  |  |  | Ngày bắt đầu đình chỉ của UBCKNN. |
| 27 | ssc_susp_end_dt | DATE | X |  |  |  | Ngày kết thúc đình chỉ của UBCKNN. |
| 28 | ssc_susp_cntnt | STRING | X |  |  |  | Nội dung quyết định đình chỉ của UBCKNN. |
| 29 | acpt_yr | INT | X |  |  |  | Năm chấp thuận (dùng cho mục đích báo cáo). |
| 30 | affiliation_end_dt | DATE | X |  |  |  | Ngày kiểm toán viên không còn thuộc công ty kiểm toán. |
| 31 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 32 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 33 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 34 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| auditor_aprv_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| audt_firm_id | audt_firm | audt_firm_id |



#### Index

N/A

#### Trigger

N/A




### Bảng pblc_co_fnc_rpt_val



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | pblc_co_fnc_rpt_val_id | STRING |  | X | P |  | Khóa đại diện cho giá trị một ô trong BCTC đã nộp. |
| 2 | pblc_co_fnc_rpt_val_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK kỹ thuật. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.data' | Mã nguồn dữ liệu. |
| 4 | pblc_co_rpt_subm_id | STRING |  |  | F |  | FK đến lần nộp báo cáo của công ty đại chúng. |
| 5 | pblc_co_rpt_subm_code | STRING |  |  |  |  | Mã lần nộp báo cáo. |
| 6 | fnc_rpt_ctlg_id | STRING |  |  | F |  | FK đến biểu mẫu BCTC. |
| 7 | fnc_rpt_ctlg_code | STRING |  |  |  |  | Mã biểu mẫu BCTC. |
| 8 | row_code | STRING |  |  |  |  | Mã hàng của ô trong BCTC. |
| 9 | clmn_code | STRING |  |  |  |  | Mã cột của ô trong BCTC. |
| 10 | data_val | STRING | X |  |  |  | Giá trị của ô BCTC. |
| 11 | rpt_yr | INT | X |  |  |  | Năm báo cáo tài chính. |
| 12 | rpt_qtr | INT | X |  |  |  | Quý báo cáo tài chính. |
| 13 | cell_tp_code | STRING | X |  |  |  | Kiểu ô: i=input (đầu vào), o=output (tính toán). |
| 14 | is_cell_enabled_f | BOOLEAN | X |  |  |  | Ô sẵn sàng nhập liệu (1=enable, 0=disable). |
| 15 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name). |
| 16 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 17 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name). |
| 18 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| pblc_co_fnc_rpt_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| pblc_co_rpt_subm_id | pblc_co_rpt_subm | pblc_co_rpt_subm_id |
| fnc_rpt_ctlg_id | fnc_rpt_ctlg | fnc_rpt_ctlg_id |



#### Index

N/A

#### Trigger

N/A




### Bảng pblc_co_rpt_subm



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | pblc_co_rpt_subm_id | STRING |  | X | P |  | Khóa đại diện cho lần nộp báo cáo/tin CBTT của công ty đại chúng. |
| 2 | pblc_co_rpt_subm_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK kỹ thuật. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.company_data' | Mã nguồn dữ liệu. |
| 4 | pblc_co_id | STRING |  |  | F |  | FK đến công ty đại chúng nộp báo cáo. |
| 5 | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. |
| 6 | dscl_form_defn_id | STRING |  |  | F |  | FK đến loại biểu mẫu/form báo cáo. |
| 7 | dscl_form_defn_code | STRING |  |  |  |  | Mã loại biểu mẫu. |
| 8 | prn_subm_id | STRING | X |  | F |  | FK tự tham chiếu đến lần nộp cha (tin đính chính). |
| 9 | prn_subm_code | STRING | X |  |  |  | Mã lần nộp cha. |
| 10 | corr_refr_id | STRING | X |  | F |  | FK đến lần nộp được đính chính (ref_id). |
| 11 | corr_refr_code | STRING | X |  |  |  | Mã lần nộp được đính chính. |
| 12 | doc_ttl | STRING | X |  |  |  | Tiêu đề tin/hồ sơ. |
| 13 | doc_nbr | STRING | X |  |  |  | Số công văn. |
| 14 | doc_dt | DATE | X |  |  |  | Ngày công văn. |
| 15 | doc_smy | STRING | X |  |  |  | Trích yếu nội dung. |
| 16 | doc_sign_dt | DATE | X |  |  |  | Ngày ký văn bản. |
| 17 | subm_st_code | STRING |  |  |  | ''APPROVED'' | Trạng thái phê duyệt. ETL chỉ load APPROVED. |
| 18 | rpt_yr | INT | X |  |  |  | Năm báo cáo tài chính. |
| 19 | rpt_qtr | INT | X |  |  |  | Quý báo cáo tài chính. |
| 20 | rpt_mo | INT | X |  |  |  | Tháng báo cáo. |
| 21 | subm_dt | DATE | X |  |  |  | Ngày gửi duyệt. |
| 22 | aprv_dt | DATE | X |  |  |  | Ngày phê duyệt. |
| 23 | rejection_dt | DATE | X |  |  |  | Ngày từ chối. |
| 24 | subm_ddln_dt | DATE | X |  |  |  | Ngày deadline nộp. |
| 25 | odue_dys | INT | X |  |  |  | Số ngày quá hạn (0=đúng hạn; >0=quá hạn x ngày). |
| 26 | has_digital_sgn_f | BOOLEAN | X |  |  |  | File đính kèm có chữ ký số. |
| 27 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name). |
| 28 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 29 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name). |
| 30 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| pblc_co_rpt_subm_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| pblc_co_id | pblc_co | pblc_co_id |
| dscl_form_defn_id | dscl_form_defn | dscl_form_defn_id |



#### Index

N/A

#### Trigger

N/A




### Bảng audt_firm



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | audt_firm_id | STRING |  | X | P |  | Khóa đại diện cho công ty kiểm toán. |
| 2 | audt_firm_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.af_profiles' | Mã nguồn dữ liệu. |
| 4 | audt_firm_bsn_code | STRING | X |  |  |  | Mã công ty kiểm toán (mã nghiệp vụ). |
| 5 | audt_firm_nm | STRING | X |  |  |  | Tên tiếng Việt. |
| 6 | audt_firm_en_nm | STRING | X |  |  |  | Tên tiếng Anh. |
| 7 | audt_firm_shrt_nm | STRING | X |  |  |  | Tên viết tắt. |
| 8 | charter_cptl_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ thực góp. |
| 9 | aprv_dcsn_nbr | STRING | X |  |  |  | Số quyết định chấp thuận của UBCKNN. |
| 10 | note | STRING | X |  |  |  | Ghi chú. |
| 11 | audt_firm_st_code | STRING | X |  |  |  | Trạng thái hoạt động. |
| 12 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 13 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. |
| 14 | bsn_rgst_nbr | STRING | X |  |  |  | Giấy chứng nhận đăng ký kinh doanh. |
| 15 | elig_ctf_nbr | STRING | X |  |  |  | Giấy chứng nhận đủ điều kiện kinh doanh dịch vụ kiểm toán. |
| 16 | aprv_dt | DATE | X |  |  |  | Ngày chấp thuận. |
| 17 | frgn_audt_mbr_f | BOOLEAN | X |  |  |  | Là thành viên hãng kiểm toán quốc tế (1=có / 0=không). |
| 18 | mbr_strt_dt | DATE | X |  |  |  | Ngày trở thành thành viên hãng kiểm toán quốc tế. |
| 19 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 20 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 21 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| audt_firm_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng audt_firm_lgl_rprs



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | audt_firm_lgl_rprs_id | STRING |  | X | P |  | Khóa đại diện cho người đại diện pháp luật của công ty kiểm toán. |
| 2 | audt_firm_lgl_rprs_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.af_legal_representative' | Mã nguồn dữ liệu. |
| 4 | audt_firm_id | STRING |  |  | F |  | FK đến công ty kiểm toán. |
| 5 | audt_firm_code | STRING |  |  |  |  | Mã công ty kiểm toán. |
| 6 | full_nm | STRING | X |  |  |  | Họ tên người đại diện pháp luật. |
| 7 | pos_ttl_code | STRING | X |  |  |  | Chức vụ. |
| 8 | appointment_strt_dt | DATE | X |  |  |  | Ngày bổ nhiệm. |
| 9 | appointment_end_dt | DATE | X |  |  |  | Ngày kết thúc nhiệm kỳ. |
| 10 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 11 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 12 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 13 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| audt_firm_lgl_rprs_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| audt_firm_id | audt_firm | audt_firm_id |



#### Index

N/A

#### Trigger

N/A




### Bảng pblc_co



#### Từ IDS.company_profiles

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | pblc_co_id | STRING |  | X | P |  | Khóa đại diện cho công ty đại chúng. |
| 2 | pblc_co_code | STRING |  |  |  |  | Mã định danh công ty đại chúng (PK nguồn). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.company_profiles' | Mã nguồn dữ liệu. |
| 4 | pblc_co_nm | STRING | X |  |  |  | Tên công ty đại chúng (tiếng Việt). |
| 5 | pblc_co_en_nm | STRING | X |  |  |  | Tên công ty đại chúng (tiếng Anh). |
| 6 | pblc_co_shrt_nm | STRING | X |  |  |  | Tên viết tắt công ty đại chúng. |
| 7 | co_tp_code | STRING | X |  |  |  | Loại hình công ty. |
| 8 | charter_cptl_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ. |
| 9 | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. |
| 10 | bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. |
| 11 | webst | STRING | X |  |  |  | Website chính thức. |
| 12 | bsn_rgst_nbr | STRING | X |  |  |  | Mã số doanh nghiệp / số ĐKKD. |
| 13 | frst_rgst_dt | DATE | X |  |  |  | Ngày đăng ký lần đầu. |
| 14 | latest_rgst_dt | DATE | X |  |  |  | Ngày cấp gần nhất. |
| 15 | latest_rgst_prov_code | STRING | X |  |  |  | Tỉnh/thành nơi cấp gần nhất (mã tỉnh từ provinces). |
| 16 | idy_cgy_id | STRING | X |  | F |  | Id ngành nghề (categories). |
| 17 | idy_cgy_code | STRING | X |  |  |  | Mã ngành nghề (categories). |
| 18 | idy_cgy_level1_code | STRING | X |  |  |  | Ngành nghề cấp 1 (mã categories cấp 1). |
| 19 | idy_cgy_level2_code | STRING | X |  |  |  | Ngành nghề cấp 2 (mã categories cấp 2). |
| 20 | ids_st_code | STRING | X |  |  |  | Trạng thái niêm yết IDS. |
| 21 | auto_aprv_f | BOOLEAN | X |  |  |  | Tự động duyệt (1=tự động / 0=không). |
| 22 | co_login | STRING | X |  |  |  | User của công ty niêm yết (login_name). |
| 23 | approver_cmnt | STRING | X |  |  |  | Ý kiến người duyệt. |
| 24 | prn_co_f | BOOLEAN | X |  |  |  | Là công ty mẹ (1=có / 0=không). |
| 25 | eqty_listing_exg_code | STRING | X |  |  |  | Sàn niêm yết cổ phiếu (HNX/HOSE/UPCoM). |
| 26 | eqty_listing_exg_nm | STRING | X |  |  |  | Sàn niêm yết cổ phiếu (text từ company_detail). |
| 27 | bond_listing_exg_nm | STRING | X |  |  |  | Sàn niêm yết trái phiếu (text từ company_detail). |
| 28 | eqty_scr_f | BOOLEAN | X |  |  |  | Loại chứng khoán niêm yết là cổ phiếu (1=có / 0=không). |
| 29 | bond_scr_f | BOOLEAN | X |  |  |  | Loại chứng khoán niêm yết là trái phiếu (1=có / 0=không). |
| 30 | eqty_ticker | STRING | X |  |  |  | Mã chứng khoán cổ phiếu. |
| 31 | bond_ticker | STRING | X |  |  |  | Mã chứng khoán trái phiếu. |
| 32 | eqty_list_qty | INT | X |  |  |  | Số lượng cổ phiếu đang niêm yết. |
| 33 | bond_list_qty | INT | X |  |  |  | Số lượng trái phiếu đang niêm yết. |
| 34 | itnl_exg_nm | STRING | X |  |  |  | Sàn niêm yết quốc tế. |
| 35 | itnl_ticker | STRING | X |  |  |  | Mã chứng quốc tế. |
| 36 | isin_code | STRING | X |  |  |  | Mã ISIN. |
| 37 | scr_tp_code | STRING | X |  |  |  | Loại chứng khoán phát hành. |
| 38 | pblc_co_form_code | STRING | X |  |  |  | Hình thức trở thành công ty đại chúng (IPO / nộp hồ sơ trực tiếp). |
| 39 | cptl_paid_rpt_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ thực góp (cập nhật theo BCTC năm). |
| 40 | trsr_shr_qty | INT | X |  |  |  | Cổ phiếu quỹ hiện có. |
| 41 | fyr_strt_dt | DATE | X |  |  |  | Ngày bắt đầu năm tài chính. |
| 42 | fyr_end_dt | DATE | X |  |  |  | Ngày kết thúc năm tài chính. |
| 43 | fnc_stmt_tp_code | STRING | X |  |  |  | Loại báo cáo tài chính (IFRS/VAS...). |
| 44 | ids_rgst_f | BOOLEAN | X |  |  |  | Trạng thái đăng ký trên IDS (1=đã đăng ký / 0=chưa). |
| 45 | ids_rgst_dt | DATE | X |  |  |  | Ngày đăng ký trên IDS. |
| 46 | pblc_co_f | BOOLEAN | X |  |  |  | Là công ty đại chúng (1=có / 0=không). |
| 47 | pblc_bond_issur_f | BOOLEAN | X |  |  |  | Là tổ chức niêm yết trái phiếu (1=có / 0=không). |
| 48 | lrg_pblc_co_f | BOOLEAN | X |  |  |  | Là công ty đại chúng quy mô lớn (1=có / 0=không). |
| 49 | formr_ste_own_f | BOOLEAN | X |  |  |  | Tiền thân là doanh nghiệp nhà nước (1=có / 0=không). |
| 50 | equitisation_license_dt | DATE | X |  |  |  | Ngày được cấp GPKD sau cổ phần hóa. |
| 51 | cptl_at_equitisation_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ thực góp tại thời điểm cổ phần hóa. |
| 52 | has_ste_own_f | BOOLEAN | X |  |  |  | Có vốn nhà nước (1=có / 0=không). |
| 53 | fdi_co_f | BOOLEAN | X |  |  |  | Là doanh nghiệp FDI (1=có / 0=không). |
| 54 | has_prn_co_f | BOOLEAN | X |  |  |  | Có công ty mẹ (1=có / 0=không). |
| 55 | has_subs_f | BOOLEAN | X |  |  |  | Có công ty con (1=có / 0=không). |
| 56 | has_jnt_ventures_f | BOOLEAN | X |  |  |  | Có công ty liên doanh, liên kết (1=có / 0=không). |
| 57 | entp_tp_code | STRING | X |  |  |  | Loại hình doanh nghiệp (bh/td/ck/dn). |
| 58 | spcl_notes | STRING | X |  |  |  | Ghi chú của chuyên viên. |
| 59 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 60 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 61 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 62 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| pblc_co_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


**Index:** N/A

**Trigger:** N/A


#### Từ IDS.company_detail

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | pblc_co_id | STRING |  | X | P |  | Khóa đại diện cho công ty đại chúng. |
| 2 | pblc_co_code | STRING |  |  |  |  | Mã định danh công ty đại chúng (PK nguồn). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.company_detail' | Mã nguồn dữ liệu. |
| 4 | pblc_co_nm | STRING | X |  |  |  | Tên công ty đại chúng (tiếng Việt). |
| 5 | pblc_co_en_nm | STRING | X |  |  |  | Tên công ty đại chúng (tiếng Anh). |
| 6 | pblc_co_shrt_nm | STRING | X |  |  |  | Tên viết tắt công ty đại chúng. |
| 7 | co_tp_code | STRING | X |  |  |  | Loại hình công ty. |
| 8 | charter_cptl_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ. |
| 9 | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. |
| 10 | bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. |
| 11 | webst | STRING | X |  |  |  | Website chính thức. |
| 12 | bsn_rgst_nbr | STRING | X |  |  |  | Mã số doanh nghiệp / số ĐKKD. |
| 13 | frst_rgst_dt | DATE | X |  |  |  | Ngày đăng ký lần đầu. |
| 14 | latest_rgst_dt | DATE | X |  |  |  | Ngày cấp gần nhất. |
| 15 | latest_rgst_prov_code | STRING | X |  |  |  | Tỉnh/thành nơi cấp gần nhất (mã tỉnh từ provinces). |
| 16 | idy_cgy_id | STRING | X |  | F |  | Id ngành nghề (categories). |
| 17 | idy_cgy_code | STRING | X |  |  |  | Mã ngành nghề (categories). |
| 18 | idy_cgy_level1_code | STRING | X |  |  |  | Ngành nghề cấp 1 (mã categories cấp 1). |
| 19 | idy_cgy_level2_code | STRING | X |  |  |  | Ngành nghề cấp 2 (mã categories cấp 2). |
| 20 | ids_st_code | STRING | X |  |  |  | Trạng thái niêm yết IDS. |
| 21 | auto_aprv_f | BOOLEAN | X |  |  |  | Tự động duyệt (1=tự động / 0=không). |
| 22 | co_login | STRING | X |  |  |  | User của công ty niêm yết (login_name). |
| 23 | approver_cmnt | STRING | X |  |  |  | Ý kiến người duyệt. |
| 24 | prn_co_f | BOOLEAN | X |  |  |  | Là công ty mẹ (1=có / 0=không). |
| 25 | eqty_listing_exg_code | STRING | X |  |  |  | Sàn niêm yết cổ phiếu (HNX/HOSE/UPCoM). |
| 26 | eqty_listing_exg_nm | STRING | X |  |  |  | Sàn niêm yết cổ phiếu (text từ company_detail). |
| 27 | bond_listing_exg_nm | STRING | X |  |  |  | Sàn niêm yết trái phiếu (text từ company_detail). |
| 28 | eqty_scr_f | BOOLEAN | X |  |  |  | Loại chứng khoán niêm yết là cổ phiếu (1=có / 0=không). |
| 29 | bond_scr_f | BOOLEAN | X |  |  |  | Loại chứng khoán niêm yết là trái phiếu (1=có / 0=không). |
| 30 | eqty_ticker | STRING | X |  |  |  | Mã chứng khoán cổ phiếu. |
| 31 | bond_ticker | STRING | X |  |  |  | Mã chứng khoán trái phiếu. |
| 32 | eqty_list_qty | INT | X |  |  |  | Số lượng cổ phiếu đang niêm yết. |
| 33 | bond_list_qty | INT | X |  |  |  | Số lượng trái phiếu đang niêm yết. |
| 34 | itnl_exg_nm | STRING | X |  |  |  | Sàn niêm yết quốc tế. |
| 35 | itnl_ticker | STRING | X |  |  |  | Mã chứng quốc tế. |
| 36 | isin_code | STRING | X |  |  |  | Mã ISIN. |
| 37 | scr_tp_code | STRING | X |  |  |  | Loại chứng khoán phát hành. |
| 38 | pblc_co_form_code | STRING | X |  |  |  | Hình thức trở thành công ty đại chúng (IPO / nộp hồ sơ trực tiếp). |
| 39 | cptl_paid_rpt_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ thực góp (cập nhật theo BCTC năm). |
| 40 | trsr_shr_qty | INT | X |  |  |  | Cổ phiếu quỹ hiện có. |
| 41 | fyr_strt_dt | DATE | X |  |  |  | Ngày bắt đầu năm tài chính. |
| 42 | fyr_end_dt | DATE | X |  |  |  | Ngày kết thúc năm tài chính. |
| 43 | fnc_stmt_tp_code | STRING | X |  |  |  | Loại báo cáo tài chính (IFRS/VAS...). |
| 44 | ids_rgst_f | BOOLEAN | X |  |  |  | Trạng thái đăng ký trên IDS (1=đã đăng ký / 0=chưa). |
| 45 | ids_rgst_dt | DATE | X |  |  |  | Ngày đăng ký trên IDS. |
| 46 | pblc_co_f | BOOLEAN | X |  |  |  | Là công ty đại chúng (1=có / 0=không). |
| 47 | pblc_bond_issur_f | BOOLEAN | X |  |  |  | Là tổ chức niêm yết trái phiếu (1=có / 0=không). |
| 48 | lrg_pblc_co_f | BOOLEAN | X |  |  |  | Là công ty đại chúng quy mô lớn (1=có / 0=không). |
| 49 | formr_ste_own_f | BOOLEAN | X |  |  |  | Tiền thân là doanh nghiệp nhà nước (1=có / 0=không). |
| 50 | equitisation_license_dt | DATE | X |  |  |  | Ngày được cấp GPKD sau cổ phần hóa. |
| 51 | cptl_at_equitisation_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ thực góp tại thời điểm cổ phần hóa. |
| 52 | has_ste_own_f | BOOLEAN | X |  |  |  | Có vốn nhà nước (1=có / 0=không). |
| 53 | fdi_co_f | BOOLEAN | X |  |  |  | Là doanh nghiệp FDI (1=có / 0=không). |
| 54 | has_prn_co_f | BOOLEAN | X |  |  |  | Có công ty mẹ (1=có / 0=không). |
| 55 | has_subs_f | BOOLEAN | X |  |  |  | Có công ty con (1=có / 0=không). |
| 56 | has_jnt_ventures_f | BOOLEAN | X |  |  |  | Có công ty liên doanh, liên kết (1=có / 0=không). |
| 57 | entp_tp_code | STRING | X |  |  |  | Loại hình doanh nghiệp (bh/td/ck/dn). |
| 58 | spcl_notes | STRING | X |  |  |  | Ghi chú của chuyên viên. |
| 59 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 60 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 61 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 62 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| pblc_co_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


**Index:** N/A

**Trigger:** N/A





### Bảng pblc_co_lgl_rprs



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | pblc_co_lgl_rprs_id | STRING |  | X | P |  | Khóa đại diện cho người đại diện pháp luật/CBTT của công ty đại chúng. |
| 2 | pblc_co_lgl_rprs_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.legal_representative' | Mã nguồn dữ liệu. |
| 4 | pblc_co_id | STRING |  |  | F |  | FK đến công ty đại chúng. |
| 5 | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. |
| 6 | full_nm | STRING | X |  |  |  | Họ tên người đại diện. |
| 7 | pos_ttl | STRING | X |  |  |  | Chức vụ. |
| 8 | appointment_dt | DATE | X |  |  |  | Ngày bổ nhiệm. |
| 9 | rprs_rl_code | STRING | X |  |  |  | Vai trò (0=người đại diện pháp luật, 1=người CBTT). |
| 10 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 11 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 12 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 13 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| pblc_co_lgl_rprs_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| pblc_co_id | pblc_co | pblc_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng pblc_co_rel_ent



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | pblc_co_rel_ent_id | STRING |  | X | P |  | Khóa đại diện cho quan hệ công ty mẹ/con/liên kết của công ty đại chúng. |
| 2 | pblc_co_rel_ent_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.company_relationship' | Mã nguồn dữ liệu. |
| 4 | pblc_co_id | STRING |  |  | F |  | FK đến công ty đại chúng. |
| 5 | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. |
| 6 | rltnp_tp_code | STRING | X |  |  |  | Loại quan hệ (mẹ / con / liên doanh liên kết). |
| 7 | rel_ent_nm | STRING | X |  |  |  | Tên công ty liên quan (tiếng Việt). |
| 8 | rel_ent_en_nm | STRING | X |  |  |  | Tên công ty liên quan (tiếng Anh). |
| 9 | rel_ent_bsn_rgst_nbr | STRING | X |  |  |  | Mã số doanh nghiệp công ty liên quan. |
| 10 | rel_ent_charter_cptl_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ thực góp công ty liên quan. |
| 11 | own_shr_qty | INT | X |  |  |  | Số cổ phiếu sở hữu trong công ty liên quan. |
| 12 | own_rto | DECIMAL(5,2) | X |  |  |  | Tỷ lệ phần trăm sở hữu. |
| 13 | eff_fm_dt | DATE | X |  |  |  | Ngày bắt đầu hiệu lực quan hệ. |
| 14 | eff_to_dt | DATE | X |  |  |  | Ngày kết thúc hiệu lực quan hệ. |
| 15 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 16 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 17 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 18 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| pblc_co_rel_ent_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| pblc_co_id | pblc_co | pblc_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng stk_hldr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | stk_hldr_id | STRING |  | X | P |  | Khóa đại diện cho cổ đông giao dịch. |
| 2 | stk_hldr_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.stock_holders' | Mã nguồn dữ liệu. |
| 4 | pblc_co_id | STRING |  |  | F |  | FK đến công ty đại chúng. |
| 5 | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. |
| 6 | shrhlr_nm | STRING | X |  |  |  | Tên cổ đông (cá nhân hoặc tổ chức). |
| 7 | ent_tp_code | STRING | X |  |  |  | Loại hình cổ đông (cá nhân, tổ chức). |
| 8 | id_tp_codes | STRING | X |  |  |  | Danh sách loại giấy tờ (chuỗi cách nhau dấu "," — ví dụ "1,2", FK đến identity.identity_type_cd). |
| 9 | pos_codes | STRING | X |  |  |  | Danh sách mã chức vụ (chuỗi cách nhau dấu "," — ví dụ "6,3", FK đến positions.position_cd). |
| 10 | shrhlr_tp_codes | STRING | X |  |  |  | Danh sách loại cổ đông (chuỗi cách nhau dấu ","). |
| 11 | gnd_code | STRING | X |  |  |  | Giới tính. |
| 12 | ed_lvl_code | STRING | X |  |  |  | Trình độ học vấn. |
| 13 | brth_dt | DATE | X |  |  |  | Ngày sinh (cá nhân). |
| 14 | nat_code | STRING | X |  |  |  | Quốc tịch (text từ nguồn). |
| 15 | bsn_rgst_nbr | STRING | X |  |  |  | Mã doanh nghiệp (cổ đông tổ chức). |
| 16 | founder_hldr_f | BOOLEAN | X |  |  |  | Cổ đông sáng lập (1=có / 0=không). |
| 17 | founder_hldr_actv_dt | DATE | X |  |  |  | Ngày bắt đầu là cổ đông sáng lập. |
| 18 | founder_hldr_inact_dt | DATE | X |  |  |  | Ngày kết thúc là cổ đông sáng lập. |
| 19 | major_hldr_f | BOOLEAN | X |  |  |  | Cổ đông lớn (1=có / 0=không). |
| 20 | major_hldr_actv_dt | DATE | X |  |  |  | Ngày bắt đầu là cổ đông lớn. |
| 21 | major_hldr_inact_dt | DATE | X |  |  |  | Ngày kết thúc là cổ đông lớn. |
| 22 | strtg_hldr_f | BOOLEAN | X |  |  |  | Cổ đông chiến lược (1=có / 0=không). |
| 23 | strtg_hldr_actv_dt | DATE | X |  |  |  | Ngày bắt đầu là cổ đông chiến lược. |
| 24 | strtg_hldr_inact_dt | DATE | X |  |  |  | Ngày kết thúc là cổ đông chiến lược. |
| 25 | insider_hldr_f | BOOLEAN | X |  |  |  | Cổ đông nội bộ (1=có / 0=không). |
| 26 | insider_hldr_actv_dt | DATE | X |  |  |  | Ngày bắt đầu là cổ đông nội bộ. |
| 27 | insider_hldr_inact_dt | DATE | X |  |  |  | Ngày kết thúc là cổ đông nội bộ. |
| 28 | govt_hldr_f | BOOLEAN | X |  |  |  | Cổ đông nhà nước (1=có / 0=không). |
| 29 | govt_hldr_actv_dt | DATE | X |  |  |  | Ngày bắt đầu là cổ đông nhà nước. |
| 30 | govt_hldr_inact_dt | DATE | X |  |  |  | Ngày kết thúc là cổ đông nhà nước. |
| 31 | bnk_hldr_f | BOOLEAN | X |  |  |  | Cổ đông ngân hàng (1=có / 0=không). |
| 32 | bnk_hldr_actv_dt | DATE | X |  |  |  | Ngày bắt đầu là cổ đông ngân hàng. |
| 33 | bnk_hldr_inact_dt | DATE | X |  |  |  | Ngày kết thúc là cổ đông ngân hàng. |
| 34 | frgn_hldr_f | BOOLEAN | X |  |  |  | Cổ đông nước ngoài (1=có / 0=không). |
| 35 | frgn_hldr_actv_dt | DATE | X |  |  |  | Ngày bắt đầu là cổ đông nước ngoài. |
| 36 | frgn_hldr_inact_dt | DATE | X |  |  |  | Ngày kết thúc là cổ đông nước ngoài. |
| 37 | rel_hldr_f | BOOLEAN | X |  |  |  | Cổ đông liên quan (1=có / 0=không). |
| 38 | rel_hldr_actv_dt | DATE | X |  |  |  | Ngày bắt đầu là cổ đông liên quan. |
| 39 | rel_hldr_inact_dt | DATE | X |  |  |  | Ngày kết thúc là cổ đông liên quan. |
| 40 | othr_hldr_f | BOOLEAN | X |  |  |  | Cổ đông khác (1=có / 0=không). |
| 41 | othr_hldr_actv_dt | DATE | X |  |  |  | Ngày bắt đầu là cổ đông khác. |
| 42 | othr_hldr_inact_dt | DATE | X |  |  |  | Ngày kết thúc là cổ đông khác. |
| 43 | own_qty | INT | X |  |  |  | Số lượng cổ phiếu nắm giữ. |
| 44 | own_rto | DECIMAL(5,2) | X |  |  |  | Tỷ lệ phần trăm cổ phiếu nắm giữ. |
| 45 | tradable_shr_qty | INT | X |  |  |  | Số lượng cổ phiếu CTCK được phép giao dịch. |
| 46 | tradable_shr_rto | DECIMAL(5,2) | X |  |  |  | Tỷ lệ cổ phiếu CTCK được phép giao dịch (= tradable_share_qty / ownership_qty). |
| 47 | own_dt | DATE | X |  |  |  | Ngày đặt tỷ lệ sở hữu. |
| 48 | rel_hldr_cnt | INT | X |  |  |  | Số người liên quan. |
| 49 | dsc | STRING | X |  |  |  | Mô tả. |
| 50 | aprv_f | BOOLEAN | X |  |  |  | Trạng thái thông tin cổ đông (1=đã duyệt / 0=chưa duyệt). |
| 51 | rcrd_st_f | BOOLEAN | X |  |  |  | Trạng thái bản ghi (1=sửa / 0=mới). |
| 52 | rpt_f | BOOLEAN | X |  |  |  | Đã kết xuất ra báo cáo sang bên giám sát (1=đã / 0=chưa). |
| 53 | exprt_st_f | STRING | X |  |  |  | Dùng cho giám sát (1=insert / 2=update). |
| 54 | vsd_data_f | BOOLEAN | X |  |  |  | Dữ liệu cập nhật từ trung tâm lưu ký. |
| 55 | rsn | STRING | X |  |  |  | Lý do. |
| 56 | vsd_data_udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật dữ liệu từ trung tâm lưu ký. |
| 57 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 58 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 59 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 60 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| stk_hldr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| pblc_co_id | pblc_co | pblc_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng stk_hldr_rltnp



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | stk_hldr_rltnp_id | STRING |  | X | P |  | Khóa đại diện cho quan hệ giữa 2 cổ đông. |
| 2 | stk_hldr_rltnp_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.holder_relationship' | Mã nguồn dữ liệu. |
| 4 | stk_hldr_id | STRING |  |  | F |  | FK đến cổ đông chính. |
| 5 | stk_hldr_code | STRING |  |  |  |  | Mã cổ đông chính. |
| 6 | rel_stk_hldr_id | STRING |  |  | F |  | FK đến cổ đông liên quan. |
| 7 | rel_stk_hldr_code | STRING |  |  |  |  | Mã cổ đông liên quan. |
| 8 | rltnp_tp_code | STRING | X |  |  |  | Loại quan hệ giữa 2 cổ đông. |
| 9 | eff_dt | DATE | X |  |  |  | Ngày hiệu lực quan hệ. |
| 10 | end_dt | DATE | X |  |  |  | Ngày hết hiệu lực quan hệ. |
| 11 | actv_f | BOOLEAN | X |  |  |  | Trạng thái quan hệ (1=active / 0=inactive). |
| 12 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 13 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 14 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 15 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| stk_hldr_rltnp_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| stk_hldr_id | stk_hldr | stk_hldr_id |
| rel_stk_hldr_id | stk_hldr | stk_hldr_id |



#### Index

N/A

#### Trigger

N/A




### Bảng pblc_co_trsr_stk_avy



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | pblc_co_trsr_stk_avy_id | STRING |  | X | P |  | Khóa đại diện cho hoạt động cổ phiếu quỹ theo năm. |
| 2 | pblc_co_trsr_stk_avy_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.company_treasury_stocks' | Mã nguồn dữ liệu. |
| 4 | pblc_co_id | STRING |  |  | F |  | FK đến công ty đại chúng. |
| 5 | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. |
| 6 | txn_yr | INT | X |  |  |  | Năm giao dịch cổ phiếu quỹ. |
| 7 | trsr_buy_qty | INT | X |  |  |  | Số lượng cổ phiếu quỹ mua trong năm. |
| 8 | trsr_buy_rnd_cnt | INT | X |  |  |  | Số đợt mua cổ phiếu quỹ trong năm. |
| 9 | trsr_sell_qty | INT | X |  |  |  | Số lượng cổ phiếu quỹ bán trong năm. |
| 10 | trsr_sell_rnd_cnt | INT | X |  |  |  | Số đợt bán cổ phiếu quỹ trong năm. |
| 11 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 12 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 13 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 14 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| pblc_co_trsr_stk_avy_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| pblc_co_id | pblc_co | pblc_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng ip_alt_identn



#### Từ IDS.af_legal_representative

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Audit Firm Legal Representative. |
| 2 | ip_code | STRING |  |  |  |  | Mã người đại diện pháp luật. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.af_legal_representative' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  | 'NATIONAL_ID' | Loại giấy tờ — CMND/Hộ chiếu (nguồn không phân biệt rõ). |
| 5 | identn_nbr | STRING | X |  |  |  | Số CMND/Hộ chiếu. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp CMND/CCCD. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp CMND/CCCD. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | audt_firm_lgl_rprs | audt_firm_lgl_rprs_id |



**Index:** N/A

**Trigger:** N/A


#### Từ IDS.legal_representative

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Public Company Legal Representative. |
| 2 | ip_code | STRING |  |  |  |  | Mã người đại diện. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.legal_representative' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  | 'NATIONAL_ID' | Loại giấy tờ — CMND/CCCD/Hộ chiếu (nguồn không phân biệt rõ). |
| 5 | identn_nbr | STRING | X |  |  |  | Số CMND/CCCD/Hộ chiếu. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp giấy tờ. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy tờ. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | pblc_co_lgl_rprs | pblc_co_lgl_rprs_id |



**Index:** N/A

**Trigger:** N/A


#### Từ IDS.identity

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Stock Holder. |
| 2 | ip_code | STRING |  |  |  |  | Mã cổ đông. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.identity' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ định danh (CMND/CCCD/Hộ chiếu/GPKD). |
| 5 | identn_nbr | STRING | X |  |  |  | Số giấy tờ. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp giấy tờ. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy tờ. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | stk_hldr | stk_hldr_id |



**Index:** N/A

**Trigger:** N/A





### Bảng ip_elc_adr



#### Từ IDS.af_profiles

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Audit Firm. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty kiểm toán. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.af_profiles' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. |
| 5 | elc_adr_val | STRING | X |  |  |  | Số fax. |
| 6 | ip_id | STRING |  |  | F |  | FK đến Audit Firm. |
| 7 | ip_code | STRING |  |  |  |  | Mã công ty kiểm toán. |
| 8 | src_stm_code | STRING |  |  |  | 'IDS.af_profiles' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |
| 11 | ip_id | STRING |  |  | F |  | FK đến Audit Firm. |
| 12 | ip_code | STRING |  |  |  |  | Mã công ty kiểm toán. |
| 13 | src_stm_code | STRING |  |  |  | 'IDS.af_profiles' | Mã nguồn dữ liệu. |
| 14 | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. |
| 15 | elc_adr_val | STRING | X |  |  |  | Website. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | audt_firm | audt_firm_id |



**Index:** N/A

**Trigger:** N/A


#### Từ IDS.company_detail

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Public Company. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty đại chúng. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.company_detail' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. |
| 5 | elc_adr_val | STRING | X |  |  |  | Số fax. |
| 6 | ip_id | STRING |  |  | F |  | FK đến Public Company. |
| 7 | ip_code | STRING |  |  |  |  | Mã công ty đại chúng. |
| 8 | src_stm_code | STRING |  |  |  | 'IDS.company_detail' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |
| 11 | ip_id | STRING |  |  | F |  | FK đến Public Company. |
| 12 | ip_code | STRING |  |  |  |  | Mã công ty đại chúng. |
| 13 | src_stm_code | STRING |  |  |  | 'IDS.company_detail' | Mã nguồn dữ liệu. |
| 14 | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. |
| 15 | elc_adr_val | STRING | X |  |  |  | Website. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | pblc_co | pblc_co_id |



**Index:** N/A

**Trigger:** N/A


#### Từ IDS.stock_holders

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Stock Holder. |
| 2 | ip_code | STRING |  |  |  |  | Mã cổ đông. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.stock_holders' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. |
| 5 | elc_adr_val | STRING | X |  |  |  | Số fax. |
| 6 | ip_id | STRING |  |  | F |  | FK đến Stock Holder. |
| 7 | ip_code | STRING |  |  |  |  | Mã cổ đông. |
| 8 | src_stm_code | STRING |  |  |  | 'IDS.stock_holders' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | stk_hldr | stk_hldr_id |



**Index:** N/A

**Trigger:** N/A


#### Từ IDS.af_legal_representative

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Audit Firm Legal Representative. |
| 2 | ip_code | STRING |  |  |  |  | Mã người đại diện pháp luật. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.af_legal_representative' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. |
| 5 | elc_adr_val | STRING | X |  |  |  | Số điện thoại liên hệ. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | audt_firm_lgl_rprs | audt_firm_lgl_rprs_id |



**Index:** N/A

**Trigger:** N/A


#### Từ IDS.legal_representative

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Public Company Legal Representative. |
| 2 | ip_code | STRING |  |  |  |  | Mã người đại diện. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.legal_representative' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Email. |
| 6 | ip_id | STRING |  |  | F |  | FK đến Public Company Legal Representative. |
| 7 | ip_code | STRING |  |  |  |  | Mã người đại diện. |
| 8 | src_stm_code | STRING |  |  |  | 'IDS.legal_representative' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | pblc_co_lgl_rprs | pblc_co_lgl_rprs_id |



**Index:** N/A

**Trigger:** N/A





### Bảng ip_pst_adr



#### Từ IDS.af_profiles

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Audit Firm. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty kiểm toán. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.af_profiles' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở chính. |
| 6 | prov_id | STRING | X |  | F |  | FK đến tỉnh/thành phố trụ sở. |
| 7 | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). |
| 8 | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. |
| 9 | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. |
| 10 | geo_id | STRING | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. |
| 11 | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. |
| 12 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | audt_firm | audt_firm_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ IDS.company_detail

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Public Company. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty đại chúng. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.company_detail' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  | 'BUSINESS' | Loại địa chỉ — văn phòng giao dịch (business). |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ văn phòng giao dịch. |
| 6 | prov_code | STRING | X |  |  |  | Mã tỉnh kinh doanh |
| 7 | prov_nm | STRING | X |  |  |  | Tên tỉnh kinh doanh |
| 8 | dstc_code | STRING | X |  |  |  | Mã huyện kinh doanh |
| 9 | dstc_nm | STRING | X |  |  |  | Tên huyện kinh doanh |
| 10 | ward_code | STRING | X |  |  |  | Mã xã kinh doanh |
| 11 | ward_nm | STRING | X |  |  |  | Tên xã kinh doanh |
| 12 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |
| 13 | ip_id | STRING |  |  | F |  | FK đến Public Company. |
| 14 | ip_code | STRING |  |  |  |  | Mã công ty đại chúng. |
| 15 | src_stm_code | STRING |  |  |  | 'IDS.company_detail' | Mã nguồn dữ liệu. |
| 16 | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. |
| 17 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở chính. |
| 18 | prov_id | STRING | X |  | F |  | FK đến tỉnh/thành phố trụ sở. |
| 19 | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). |
| 20 | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. |
| 21 | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. |
| 22 | geo_id | STRING | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. |
| 23 | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. |
| 24 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | pblc_co | pblc_co_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ IDS.stock_holders

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Stock Holder. |
| 2 | ip_code | STRING |  |  |  |  | Mã cổ đông. |
| 3 | src_stm_code | STRING |  |  |  | 'IDS.stock_holders' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  | 'ADDRESS' | Loại địa chỉ — địa chỉ chung (không phân biệt loại). |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ cổ đông. |
| 6 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | stk_hldr | stk_hldr_id |



**Index:** N/A

**Trigger:** N/A





### Stored Procedure/Function

N/A

### Package

N/A
