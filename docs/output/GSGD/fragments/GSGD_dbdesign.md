## GSGD — Phần hệ giám sát giao dịch

### Các mô hình quan hệ dữ liệu

![Mô hình quan hệ dữ liệu GSGD](GSGD/fragments/GSGD_diagram.png)

**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | ivsr_ac_rltnp | Quan hệ giữa 2 tài khoản nhà đầu tư trong giám sát (IP address, MAC address, chuyển tiền). Ghi nhận độ mạnh quan hệ. FK Investor Trading Account (x2) + Account Investor Group. |
| 2 | ivsr_tdg_ac | Tài khoản giao dịch chứng khoán của nhà đầu tư trong hệ thống GSGD. Grain: 1 dòng = 1 tài khoản (phân biệt theo account_code từ VSDC). Bao gồm cá nhân và tổ chức, trong nước và nước ngoài. |
| 3 | ivsr_tdg_ac_ahr | Ủy quyền giao dịch chứng khoán trên tài khoản nhà đầu tư. FK Investor Trading Account. |
| 4 | ivsr_tdg_ac_fnc_svc | Dịch vụ tài chính đăng ký trên tài khoản giao dịch (ký quỹ / ứng trước tiền bán / HĐ tài chính khác). FK Investor Trading Account. |
| 5 | mkt_surveil_ac_grp_anl_rslt | Kết quả phân tích nhóm tài khoản nghi vấn. FK Market Surveillance Case. |
| 6 | mkt_surveil_ac_grp_mbr_anl_rslt | Thành viên nhóm tài khoản trong kết quả phân tích. FK Market Surveillance Case + Investor Account Relationship. |
| 7 | mkt_surveil_ac_rltnp_anl_rslt | Kết quả phân tích quan hệ giữa tài khoản nghi vấn. FK Market Surveillance Case + Investor Account Relationship. |
| 8 | mkt_surveil_anl_exec_log | Log thực thi phân tích từng biểu mẫu trong vụ việc giám sát. FK Market Surveillance Case. |
| 9 | mkt_surveil_anl_sspcs_ac_snpst | Snapshot thông tin tài khoản nghi vấn tại thời điểm phân tích biểu mẫu. FK Market Surveillance Case. |
| 10 | mkt_surveil_case | Vụ việc giám sát giao dịch chứng khoán bất thường. Ghi nhận loại vụ việc, mã CK liên quan, nguồn thông tin và trạng thái xử lý. |
| 11 | mkt_surveil_case_aprv_step_log | Nhật ký phê duyệt từng bước xử lý vụ việc giám sát. Ghi nhận người duyệt, vai trò, trạng thái và thời điểm. FK Market Surveillance Case. |
| 12 | mkt_surveil_case_workflow_step | Từng bước quy trình xử lý vụ việc giám sát. Append-only. FK Market Surveillance Case. |
| 13 | mkt_surveil_sspcs_ac_anl_rslt | Kết quả phân tích/kiểm tra tài khoản nghi vấn trong vụ việc giám sát. FK Market Surveillance Case. |
| 14 | mkt_surveil_anl_criterion | Định nghĩa tiêu chí/công thức phân tích vụ việc giám sát (ngưỡng tỷ lệ, số phiên, v.v.). Grain: 1 dòng = 1 tiêu chí. |
| 15 | mkt_surveil_anl_criterion_val | Giá trị cụ thể của tiêu chí phân tích theo từng quy trình. FK Market Surveillance Analysis Criterion. |
| 16 | mkt_surveil_cmpln_rpt_tpl | Định nghĩa loại báo cáo tuân thủ trong hệ thống GSGD (tên báo cáo, kỳ báo cáo). Grain: 1 dòng = 1 loại báo cáo. |
| 17 | abnormal_tdg_rpt | Báo cáo giao dịch bất thường do tổ chức thành viên nộp lên UBCKNN. Grain: 1 dòng = 1 báo cáo. |
| 18 | abnormal_tdg_rpt_file_attch | File đính kèm báo cáo giao dịch bất thường (có chữ ký số). FK Abnormal Trading Report. |
| 19 | mkt_surveil_anl_rpt | Báo cáo output của quá trình phân tích vụ việc giám sát (report_type |
| 20 | mkt_surveil_case_doc_attch | File đính kèm vụ việc giám sát (tài liệu hồ sơ, danh sách TK nghi vấn). FK Market Surveillance Case. |
| 21 | mkt_surveil_cmpln_rpt_clmn_config | Định nghĩa cấu trúc cột của từng loại báo cáo tuân thủ GSGD. FK Market Surveillance Compliance Report Template. |
| 22 | mkt_surveil_cmpln_rpt_instn | Instance báo cáo tuân thủ theo từng kỳ. FK Market Surveillance Compliance Report Template. |
| 23 | mkt_surveil_cmpln_rpt_row_data | Dữ liệu từng dòng trong báo cáo tuân thủ GSGD (lưu dạng JSON). Grain: 1 dòng = 1 row x 1 kỳ. FK Market Surveillance Compliance Report Instance. |
| 24 | list_co_corp_ev | Sự kiện liên quan đến tổ chức niêm yết trong phạm vi giám sát GSGD. Grain: 1 dòng = 1 sự kiện. |
| 25 | mkt_surveil_sspcs_ac | Tài khoản nghi vấn được xác định trong vụ việc giám sát. FK Market Surveillance Case + Investor Trading Account. |
| 26 | mkt_surveil_sspcs_ac_grp | Nhóm tài khoản nghi vấn trong phạm vi 1 vụ việc giám sát cụ thể. FK Market Surveillance Case. |
| 27 | ac_ivsr_grp | Nhóm tài khoản nhà đầu tư do nghiệp vụ giám sát xác định theo tiêu chí quan hệ (Danh tính / IP / MAC / Tiền). Grain: 1 dòng = 1 nhóm. |
| 28 | ac_ivsr_grp_mbr | Quan hệ thành viên giữa tài khoản nhà đầu tư và nhóm giám sát. Ghi nhận loại quan hệ và trạng thái. FK Account Investor Group + Investor Trading Account. |
| 29 | scr_watchlist_grp | Nhóm chứng khoán do nghiệp vụ giám sát tạo ra (thường hoặc theo ngành). Danh sách mã CK denormalize thành ARRAY. |




### Bảng ivsr_ac_rltnp



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ivsr_ac_rltnp_id | STRING |  | X | P |  | Khóa đại diện cho mối quan hệ giữa các tài khoản nhà đầu tư. |
| 2 | ivsr_ac_rltnp_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.account_relationship' | Mã nguồn dữ liệu. |
| 4 | frst_ivsr_tdg_ac_id | STRING |  |  | F |  | FK đến tài khoản giao dịch thứ nhất. |
| 5 | frst_ivsr_tdg_ac_code | STRING |  |  |  |  | Mã tài khoản giao dịch thứ nhất. Denormalized. |
| 6 | scd_ivsr_tdg_ac_id | STRING |  |  | F |  | FK đến tài khoản giao dịch thứ hai. |
| 7 | scd_ivsr_tdg_ac_code | STRING |  |  |  |  | Mã tài khoản giao dịch thứ hai. Denormalized. |
| 8 | ac_ivsr_grp_id | STRING | X |  | F |  | FK đến nhóm tài khoản. |
| 9 | ac_ivsr_grp_code | STRING | X |  |  |  | Mã nhóm tài khoản. Denormalized. |
| 10 | relation_tp_code | STRING | X |  | F |  | Loại quan hệ (Danh tính / IP / MAC / Tiền). |
| 11 | rltnp_val | STRING | X |  |  |  | Giá trị quan hệ (IP address, MAC address, etc.). |
| 12 | strength | INT | X |  |  |  | Độ mạnh quan hệ (1-100). Điểm tính — không phải %. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ivsr_ac_rltnp_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| frst_ivsr_tdg_ac_id | ivsr_tdg_ac | ivsr_tdg_ac_id |
| scd_ivsr_tdg_ac_id | ivsr_tdg_ac | ivsr_tdg_ac_id |
| ac_ivsr_grp_id | ac_ivsr_grp | ac_ivsr_grp_id |



#### Index

N/A

#### Trigger

N/A




### Bảng ivsr_tdg_ac



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ivsr_tdg_ac_id | STRING |  | X | P |  | Khóa đại diện cho tài khoản giao dịch chứng khoán. |
| 2 | ivsr_tdg_ac_code | STRING |  |  |  |  | Số tài khoản (từ VSDC). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.investor_account' | Mã nguồn dữ liệu. |
| 4 | ac_nm | STRING | X |  |  |  | Họ và tên nhà đầu tư. |
| 5 | ivsr_tp_code | STRING | X |  |  |  | Loại hình NĐT: 1=Cá nhân, 2=Tổ chức. |
| 6 | opn_dt | DATE | X |  |  |  | Ngày mở tài khoản. |
| 7 | cls_dt | DATE | X |  |  |  | Ngày đóng tài khoản. |
| 8 | ac_st_code | STRING | X |  |  |  | Trạng thái: 0=Đóng, 1=Mở. |
| 9 | dmst_frgn_f | STRING | X |  |  |  | Trong nước/Nước ngoài: 0=Trong nước, 1=Nước ngoài. |
| 10 | nat | STRING | X |  |  |  | Quốc tịch. Lưu dạng text denormalized — không có bảng lookup địa lý trong scope GSGD. |
| 11 | dob | DATE | X |  |  |  | Ngày tháng năm sinh/ngày thành lập DN (từ CTCK, có thể sửa). |
| 12 | lgl_rprs | STRING | X |  |  |  | Người đại diện theo pháp luật (từ CTCK, có thể sửa). |
| 13 | id_nbr | STRING | X |  |  |  | Số CCCD/Số đăng ký sở hữu. Denormalized — grain = 1 tài khoản. |
| 14 | id_issu_dt | DATE | X |  |  |  | Ngày cấp giấy tờ định danh. |
| 15 | id_issu_plc | STRING | X |  |  |  | Nơi cấp giấy tờ định danh. |
| 16 | ctc_adr | STRING | X |  |  |  | Địa chỉ liên lạc (từ CTCK, có thể sửa). Denormalized — grain = 1 tài khoản. |
| 17 | perm_adr | STRING | X |  |  |  | Địa chỉ thường trú (từ CTCK, có thể sửa). Denormalized — grain = 1 tài khoản. |
| 18 | ph_nbr | STRING | X |  |  |  | Số điện thoại (từ CTCK, có thể sửa). Denormalized — grain = 1 tài khoản. |
| 19 | email | STRING | X |  |  |  | Email (từ CTCK, có thể sửa). Denormalized — grain = 1 tài khoản. |
| 20 | bnk_ac_hldr_nm | STRING | X |  |  |  | Tên chủ tài khoản ngân hàng (từ CTCK, có thể sửa). |
| 21 | bnk_ac_nbr | STRING | X |  |  |  | Số tài khoản ngân hàng (từ CTCK, có thể sửa). |
| 22 | bnk_ac_nm | STRING | X |  |  |  | Tên ngân hàng (từ CTCK, có thể sửa). |
| 23 | mrgn_ac_opn_dt | DATE | X |  |  |  | Ngày mở tài khoản ký quỹ. |
| 24 | mrgn_svc_enabled | BOOLEAN | X |  |  |  | Dịch vụ tài chính sử dụng — Ký quỹ. |
| 25 | advnc_pymt_svc_enabled | BOOLEAN | X |  |  |  | Dịch vụ tài chính sử dụng — Ứng trước tiền bán. |
| 26 | ac_ahr_enabled | BOOLEAN | X |  |  |  | Dịch vụ tài chính sử dụng — Hợp đồng tài chính khác. |
| 27 | authorized_psn_nm | STRING | X |  |  |  | Người nhận ủy quyền (denormalized từ account_authorization). |
| 28 | ahr_dt | DATE | X |  |  |  | Ngày nhận ủy quyền (denormalized từ account_authorization). |
| 29 | aprv_st_code | STRING | X |  |  |  | Trạng thái phê duyệt tài khoản. |
| 30 | data_src_code | STRING | X |  |  |  | Nguồn dữ liệu chính: VSDC, CTCK. |
| 31 | last_mod_dt | DATE | X |  |  |  | Ngày thay đổi thông tin lần cuối. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ivsr_tdg_ac_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng ivsr_tdg_ac_ahr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ivsr_tdg_ac_ahr_id | STRING |  | X | P |  | Khóa đại diện cho ủy quyền tài khoản giao dịch. |
| 2 | ivsr_tdg_ac_ahr_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.account_authorization' | Mã nguồn dữ liệu. |
| 4 | ivsr_tdg_ac_id | STRING |  |  | F |  | FK đến tài khoản giao dịch chứng khoán. |
| 5 | ivsr_tdg_ac_code | STRING |  |  |  |  | Mã tài khoản giao dịch. Denormalized. |
| 6 | authorized_psn_nm | STRING | X |  |  |  | Người nhận ủy quyền. |
| 7 | ahr_dt | DATE | X |  |  |  | Ngày nhận ủy quyền. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ivsr_tdg_ac_ahr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ivsr_tdg_ac_id | ivsr_tdg_ac | ivsr_tdg_ac_id |



#### Index

N/A

#### Trigger

N/A




### Bảng ivsr_tdg_ac_fnc_svc



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ivsr_tdg_ac_fnc_svc_id | STRING |  | X | P |  | Khóa đại diện cho dịch vụ tài chính của tài khoản. |
| 2 | ivsr_tdg_ac_fnc_svc_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.account_financial_service' | Mã nguồn dữ liệu. |
| 4 | ivsr_tdg_ac_id | STRING |  |  | F |  | FK đến tài khoản giao dịch chứng khoán. |
| 5 | ivsr_tdg_ac_code | STRING |  |  |  |  | Mã tài khoản giao dịch. Denormalized. |
| 6 | svc_tp_code | STRING |  |  |  |  | Loại dịch vụ: 1=Ký quỹ, 2=Ứng trước tiền bán, 3=HĐ tài chính khác. |
| 7 | ctr_nbr | STRING | X |  |  |  | Số hợp đồng. |
| 8 | ctr_dt | DATE | X |  |  |  | Ngày ký hợp đồng. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ivsr_tdg_ac_fnc_svc_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ivsr_tdg_ac_id | ivsr_tdg_ac | ivsr_tdg_ac_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mkt_surveil_ac_grp_anl_rslt



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mkt_surveil_ac_grp_anl_rslt_id | STRING |  | X | P |  | Khóa đại diện cho kết quả phân tích nhóm tài khoản. |
| 2 | mkt_surveil_ac_grp_anl_rslt_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.analysis_account_group' | Mã nguồn dữ liệu. |
| 4 | mkt_surveil_case_id | STRING |  |  | F |  | FK đến vụ việc giám sát. |
| 5 | mkt_surveil_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. |
| 6 | workflow_tp_code | STRING |  |  |  |  | Loại quy trình: 1=Sơ bộ, 2=Thao túng, 3=Nội gián, 4=Liên thị trường. |
| 7 | rslt_tp_code | STRING |  |  |  |  | Loại kết quả: 1=Kết quả phân tích, 2=Kết quả kiểm tra. |
| 8 | grp_code | STRING | X |  |  |  | Mã nhóm tài khoản trong kết quả phân tích. |
| 9 | grp_nm | STRING | X |  |  |  | Tên nhóm tài khoản trong kết quả phân tích. |
| 10 | anl_dt | DATE |  |  |  |  | Ngày phân tích. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_surveil_ac_grp_anl_rslt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| mkt_surveil_case_id | mkt_surveil_case | mkt_surveil_case_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mkt_surveil_ac_grp_mbr_anl_rslt



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mkt_surveil_ac_grp_mbr_anl_rslt_id | STRING |  | X | P |  | Khóa đại diện cho kết quả phân tích thành viên nhóm tài khoản. |
| 2 | mkt_surveil_ac_grp_mbr_anl_rslt_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.analysis_account_group_member' | Mã nguồn dữ liệu. |
| 4 | mkt_surveil_case_id | STRING |  |  | F |  | FK đến vụ việc giám sát. |
| 5 | mkt_surveil_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. |
| 6 | ac_ivsr_grp_id | STRING | X |  | F |  | FK đến nhóm tài khoản. FK suy luận đã xác nhận. |
| 7 | ac_ivsr_grp_code | STRING | X |  |  |  | Mã nhóm tài khoản. Denormalized. |
| 8 | ivsr_ac_rltnp_id | STRING | X |  | F |  | FK đến mối quan hệ tài khoản. |
| 9 | ivsr_ac_rltnp_code | STRING | X |  |  |  | Mã mối quan hệ tài khoản. Denormalized. |
| 10 | workflow_tp_code | STRING |  |  |  |  | Loại quy trình: 1=Sơ bộ, 2=Thao túng, 3=Nội gián, 4=Liên thị trường. |
| 11 | rslt_tp_code | STRING |  |  |  |  | Loại kết quả: 1=Kết quả phân tích, 2=Kết quả kiểm tra. |
| 12 | ac_code | STRING | X |  |  |  | Mã tài khoản thành viên trong kết quả phân tích. |
| 13 | ac_nm | STRING | X |  |  |  | Tên tài khoản thành viên. |
| 14 | dsc | STRING | X |  |  |  | Mô tả. |
| 15 | anl_dt | DATE |  |  |  |  | Ngày phân tích. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_surveil_ac_grp_mbr_anl_rslt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| mkt_surveil_case_id | mkt_surveil_case | mkt_surveil_case_id |
| ac_ivsr_grp_id | ac_ivsr_grp | ac_ivsr_grp_id |
| ivsr_ac_rltnp_id | ivsr_ac_rltnp | ivsr_ac_rltnp_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mkt_surveil_ac_rltnp_anl_rslt



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mkt_surveil_ac_rltnp_anl_rslt_id | STRING |  | X | P |  | Khóa đại diện cho kết quả phân tích quan hệ tài khoản. |
| 2 | mkt_surveil_ac_rltnp_anl_rslt_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.analysis_account_relationship' | Mã nguồn dữ liệu. |
| 4 | mkt_surveil_case_id | STRING |  |  | F |  | FK đến vụ việc giám sát. |
| 5 | mkt_surveil_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. |
| 6 | ivsr_ac_rltnp_id | STRING | X |  | F |  | FK đến mối quan hệ tài khoản nghi vấn. |
| 7 | ivsr_ac_rltnp_code | STRING | X |  |  |  | Mã mối quan hệ tài khoản. Denormalized. |
| 8 | workflow_tp_code | STRING |  |  |  |  | Loại quy trình: 1=Sơ bộ, 2=Thao túng, 3=Nội gián, 4=Liên thị trường. |
| 9 | rslt_tp_code | STRING |  |  |  |  | Loại kết quả: 1=Kết quả phân tích, 2=Kết quả kiểm tra. |
| 10 | anl_dt | DATE |  |  |  |  | Ngày phân tích. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_surveil_ac_rltnp_anl_rslt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| mkt_surveil_case_id | mkt_surveil_case | mkt_surveil_case_id |
| ivsr_ac_rltnp_id | ivsr_ac_rltnp | ivsr_ac_rltnp_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mkt_surveil_anl_exec_log



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mkt_surveil_anl_exec_log_id | STRING |  | X | P |  | Khóa đại diện cho log thực thi phân tích biểu mẫu. |
| 2 | mkt_surveil_anl_exec_log_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.analysis_execution_log' | Mã nguồn dữ liệu. |
| 4 | mkt_surveil_case_id | STRING |  |  | F |  | FK đến vụ việc giám sát. |
| 5 | mkt_surveil_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. |
| 6 | anl_nm | STRING | X |  |  |  | Tên phân tích biểu mẫu. |
| 7 | workflow_tp_code | STRING | X |  |  |  | Loại quy trình: 1=Sơ bộ, 2=Thao túng, 3=Nội gián, 4=Liên thị trường. |
| 8 | tpl_tp_code | STRING | X |  |  |  | Loại biểu mẫu: 1=Báo cáo tổng hợp, 2=Báo cáo phân tích. |
| 9 | strt_tm | TIMESTAMP | X |  |  |  | Thời gian bắt đầu phân tích. |
| 10 | end_tm | TIMESTAMP | X |  |  |  | Thời gian kết thúc phân tích. |
| 11 | exec_st_code | STRING | X |  |  |  | Trạng thái thực thi: 0=Inactive, 1=Active. |
| 12 | rqs_param | STRING | X |  |  |  | Thông tin parameters đầu vào. |
| 13 | err_msg | STRING | X |  |  |  | Thông báo lỗi (nếu có). |
| 14 | file_path | STRING | X |  |  |  | Đường dẫn file output phân tích. |
| 15 | file_nm | STRING | X |  |  |  | Tên file output phân tích. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_surveil_anl_exec_log_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| mkt_surveil_case_id | mkt_surveil_case | mkt_surveil_case_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mkt_surveil_anl_sspcs_ac_snpst



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mkt_surveil_anl_sspcs_ac_snpst_id | STRING |  | X | P |  | Khóa đại diện cho snapshot thông tin tài khoản nghi vấn theo biểu mẫu phân tích. |
| 2 | mkt_surveil_anl_sspcs_ac_snpst_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.analysis_suspicious_account_code' | Mã nguồn dữ liệu. |
| 4 | mkt_surveil_case_id | STRING |  |  | F |  | FK đến vụ việc giám sát. |
| 5 | mkt_surveil_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. |
| 6 | workflow_tp_code | STRING |  |  |  |  | Loại quy trình: 1=Sơ bộ, 2=Thao túng, 3=Nội gián, 4=Liên thị trường. |
| 7 | ac_code | STRING |  |  |  |  | Mã tài khoản nghi vấn tại thời điểm phân tích. Snapshot — không FK đến Investor Trading Account. |
| 8 | ac_nm | STRING | X |  |  |  | Họ và tên tại thời điểm phân tích. Snapshot. |
| 9 | ac_tp_code | STRING | X |  |  |  | Loại tài khoản. Snapshot. |
| 10 | id_nbr | STRING | X |  |  |  | Số CCCD/Số đăng ký sở hữu tại thời điểm phân tích. Snapshot. |
| 11 | id_issu_dt | DATE | X |  |  |  | Ngày cấp giấy tờ. Snapshot. |
| 12 | id_issu_plc | STRING | X |  |  |  | Nơi cấp giấy tờ. Snapshot. |
| 13 | ctc_adr | STRING | X |  |  |  | Địa chỉ liên lạc tại thời điểm phân tích. Snapshot — không tách shared entity. |
| 14 | dmst_frgn_f | STRING | X |  |  |  | Trong nước/Nước ngoài. Snapshot. |
| 15 | ph_nbr | STRING | X |  |  |  | Số điện thoại tại thời điểm phân tích. Snapshot. |
| 16 | email | STRING | X |  |  |  | Email tại thời điểm phân tích. Snapshot. |
| 17 | ac_st_code | STRING | X |  |  |  | Trạng thái tài khoản: 0=Đóng, 1=Mở. Snapshot. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_surveil_anl_sspcs_ac_snpst_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| mkt_surveil_case_id | mkt_surveil_case | mkt_surveil_case_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mkt_surveil_case



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mkt_surveil_case_id | STRING |  | X | P |  | Khóa đại diện cho vụ việc giám sát giao dịch. |
| 2 | mkt_surveil_case_code | STRING |  |  |  |  | Mã vụ việc (tự sinh: MãCK+DDMMYYYY). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.case_file' | Mã nguồn dữ liệu. |
| 4 | case_tp_code | STRING | X |  |  |  | Loại vụ việc (Sơ bộ / Thao túng / Nội gián / Liên thị trường). |
| 5 | scr_code | STRING | X |  |  |  | Mã chứng khoán liên quan. Denormalized — bảng securities_code ngoài scope GSGD. |
| 6 | inf_src_code | STRING | X |  |  |  | Nguồn thông tin vụ việc. |
| 7 | inf_src_dtl | STRING | X |  |  |  | Nguồn thông tin chi tiết. |
| 8 | strt_dt | DATE | X |  |  |  | Ngày bắt đầu vụ việc. |
| 9 | end_dt | DATE | X |  |  |  | Ngày kết thúc vụ việc. |
| 10 | compl_dt | DATE | X |  |  |  | Thời gian hoàn thành vụ việc. |
| 11 | asgn_to | STRING | X |  |  |  | Người được phân công xử lý vụ việc. |
| 12 | case_st_code | STRING | X |  |  |  | Trạng thái vụ việc. |
| 13 | notes | STRING | X |  |  |  | Ghi chú vụ việc. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_surveil_case_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng mkt_surveil_case_aprv_step_log



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mkt_surveil_case_aprv_step_log_id | STRING |  | X | P |  | Khóa đại diện cho bước phê duyệt vụ việc giám sát. |
| 2 | mkt_surveil_case_aprv_step_log_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.case_approval_step' | Mã nguồn dữ liệu. |
| 4 | mkt_surveil_case_id | STRING |  |  | F |  | FK đến vụ việc giám sát. |
| 5 | mkt_surveil_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. |
| 6 | step_code | STRING |  |  |  |  | Mã bước: 1=Chuyên viên khởi tạo, 2=Trưởng ban phê duyệt, 3=Phó Trưởng ban phân công, 4=Chuyên viên xử lý. |
| 7 | step_nm | STRING | X |  |  |  | Tên bước (phục vụ hiển thị). |
| 8 | asgn_rl | STRING | X |  |  |  | Chức vụ/nhóm duyệt (ví dụ: TRUONG_BAN, PHO_TRUONG_BAN, CHUYEN_VIEN). |
| 9 | step_st_code | STRING | X |  |  |  | Trạng thái: 0=Chưa xử lý, 1=Đang xử lý, 2=Đã duyệt/Hoàn thành, 3=Từ chối. |
| 10 | actn_at | TIMESTAMP | X |  |  |  | Thời điểm duyệt/xử lý. |
| 11 | actn_note | STRING | X |  |  |  | Ghi chú khi duyệt/từ chối. |
| 12 | nxt_step_code | STRING | X |  |  |  | Bước tiếp theo. Nullable nếu là bước cuối. |
| 13 | nxt_asgn_rl | STRING | X |  |  |  | Chức vụ/nhóm của người duyệt tiếp theo. |
| 14 | due_dt | DATE | X |  |  |  | Hạn xử lý (nếu cần SLA). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_surveil_case_aprv_step_log_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| mkt_surveil_case_id | mkt_surveil_case | mkt_surveil_case_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mkt_surveil_case_workflow_step



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mkt_surveil_case_workflow_step_id | STRING |  | X | P |  | Khóa đại diện cho bước quy trình xử lý vụ việc. |
| 2 | mkt_surveil_case_workflow_step_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.case_file_workflow' | Mã nguồn dữ liệu. |
| 4 | mkt_surveil_case_id | STRING |  |  | F |  | FK đến vụ việc giám sát. |
| 5 | mkt_surveil_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. |
| 6 | workflow_tp_code | STRING |  |  |  |  | Loại quy trình: 1=Sơ bộ, 2=Thao túng, 3=Nội gián, 4=Liên thị trường. |
| 7 | step_ordr | INT | X |  |  |  | Thứ tự bước trong quy trình. |
| 8 | step_nm | STRING | X |  |  |  | Tên bước quy trình. |
| 9 | step_st_code | STRING | X |  |  |  | Trạng thái bước: 0=Chưa thực hiện, 1=Đang thực hiện, 2=Hoàn thành. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_surveil_case_workflow_step_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| mkt_surveil_case_id | mkt_surveil_case | mkt_surveil_case_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mkt_surveil_sspcs_ac_anl_rslt



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mkt_surveil_sspcs_ac_anl_rslt_id | STRING |  | X | P |  | Khóa đại diện cho kết quả phân tích tài khoản nghi vấn. |
| 2 | mkt_surveil_sspcs_ac_anl_rslt_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.analysis_suspicious_account' | Mã nguồn dữ liệu. |
| 4 | mkt_surveil_case_id | STRING |  |  | F |  | FK đến vụ việc giám sát. |
| 5 | mkt_surveil_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. |
| 6 | workflow_tp_code | STRING |  |  |  |  | Loại quy trình: 1=Sơ bộ, 2=Thao túng, 3=Nội gián, 4=Liên thị trường. |
| 7 | rslt_tp_code | STRING |  |  |  |  | Loại kết quả: 1=Kết quả phân tích, 2=Kết quả kiểm tra. |
| 8 | ac_code | STRING |  |  |  |  | Mã tài khoản nghi vấn. |
| 9 | anl_dt | DATE |  |  |  |  | Ngày phân tích. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_surveil_sspcs_ac_anl_rslt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| mkt_surveil_case_id | mkt_surveil_case | mkt_surveil_case_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mkt_surveil_anl_criterion



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mkt_surveil_anl_criterion_id | STRING |  | X | P |  | Khóa đại diện cho tiêu chí phân tích giám sát. |
| 2 | mkt_surveil_anl_criterion_code | STRING |  |  |  |  | Mã tiêu chí (ví dụ: CT_01_THRESHOLD_A). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.analysis_attribute_define' | Mã nguồn dữ liệu. |
| 4 | criterion_nm | STRING |  |  |  |  | Tên hiển thị tiêu chí (ví dụ: Tỷ trọng đặt/khớp lệnh > A% trong X ngày). |
| 5 | dsc | STRING | X |  |  |  | Mô tả chi tiết tiêu chí, dùng cho BA/SA. |
| 6 | workflow_tp_code | STRING | X |  |  |  | Quy trình áp dụng: 1=Sơ bộ, 2=Thao túng, 3=Nội gián, 4=Liên thị trường. |
| 7 | data_tp_code | STRING | X |  |  |  | Kiểu dữ liệu: NUMBER, STRING, DATE, BOOLEAN. |
| 8 | dflt_val | STRING | X |  |  |  | Giá trị mặc định (lưu dạng text, parse theo data_type). |
| 9 | min_val | STRING | X |  |  |  | Giá trị tối thiểu (nếu là NUMBER/DATE). |
| 10 | max_val | STRING | X |  |  |  | Giá trị tối đa (nếu là NUMBER/DATE). |
| 11 | unit | STRING | X |  |  |  | Đơn vị: %, ngày, phiên,... |
| 12 | step | STRING | X |  |  |  | Bước nhảy cho slider (nếu áp dụng). |
| 13 | dspl_grp | STRING | X |  |  |  | Nhóm hiển thị trên màn hình (ví dụ: Tham số cấu hình báo cáo). |
| 14 | dspl_ordr | INT | X |  |  |  | Thứ tự hiển thị. |
| 15 | actv_f | BOOLEAN | X |  |  |  | Trạng thái sử dụng: 0=Không dùng, 1=Đang dùng. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_surveil_anl_criterion_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng mkt_surveil_anl_criterion_val



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mkt_surveil_anl_criterion_val_id | STRING |  | X | P |  | Khóa đại diện cho giá trị tiêu chí phân tích. |
| 2 | mkt_surveil_anl_criterion_val_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.analysis_attribute_value' | Mã nguồn dữ liệu. |
| 4 | mkt_surveil_anl_criterion_id | STRING |  |  | F |  | FK đến tiêu chí phân tích. |
| 5 | mkt_surveil_anl_criterion_code | STRING |  |  |  |  | Mã tiêu chí phân tích. Denormalized. |
| 6 | workflow_tp_code | STRING |  |  |  |  | Quy trình: 1=Sơ bộ, 2=Thao túng, 3=Nội gián, 4=Liên thị trường. |
| 7 | val_nbr | STRING | X |  |  |  | Giá trị số (nếu data_type = NUMBER). |
| 8 | val_strg | STRING | X |  |  |  | Giá trị chuỗi (nếu data_type = STRING hoặc mô tả mở rộng). |
| 9 | val_dt | DATE | X |  |  |  | Giá trị ngày (nếu data_type = DATE). |
| 10 | val_booln | BOOLEAN | X |  |  |  | Giá trị boolean: 0/1 (nếu data_type = BOOLEAN). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_surveil_anl_criterion_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| mkt_surveil_anl_criterion_id | mkt_surveil_anl_criterion | mkt_surveil_anl_criterion_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mkt_surveil_cmpln_rpt_tpl



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mkt_surveil_cmpln_rpt_tpl_id | STRING |  | X | P |  | Khóa đại diện cho mẫu báo cáo tuân thủ giám sát. |
| 2 | mkt_surveil_cmpln_rpt_tpl_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.compliance_report_template' | Mã nguồn dữ liệu. |
| 4 | tpl_nm | STRING |  |  |  |  | Tên báo cáo tuân thủ. |
| 5 | prd_tp_code | STRING | X |  |  |  | Loại kỳ báo cáo. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_surveil_cmpln_rpt_tpl_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng abnormal_tdg_rpt



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | abnormal_tdg_rpt_id | STRING |  | X | P |  | Khóa đại diện cho báo cáo giao dịch bất thường. |
| 2 | abnormal_tdg_rpt_code | STRING |  |  |  |  | Mã báo cáo. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.abnormal_report' | Mã nguồn dữ liệu. |
| 4 | rpt_nm | STRING | X |  |  |  | Tên báo cáo. |
| 5 | rpt_tp_code | STRING | X |  |  |  | Loại báo cáo bất thường. |
| 6 | prd_tp_code | STRING | X |  |  |  | Loại kỳ báo cáo. |
| 7 | prd_val | STRING | X |  |  |  | Giá trị kỳ báo cáo (ví dụ: tháng 1 = 1). |
| 8 | prd_yr | INT | X |  |  |  | Năm kỳ báo cáo. |
| 9 | submitter_tp_code | STRING | X |  |  |  | Loại người nộp (Tổ chức / Cá nhân). |
| 10 | submitter_id | STRING | X |  |  |  | Mã người/tổ chức nộp báo cáo. Denormalized — không có FK tường minh đến entity Atomic. |
| 11 | submitter_nm | STRING | X |  |  |  | Tên người/tổ chức nộp báo cáo. |
| 12 | subm_dt | DATE | X |  |  |  | Ngày nộp báo cáo. |
| 13 | aprv_st_code | STRING | X |  |  |  | Trạng thái: 0=Chờ duyệt, 1=Đã duyệt, 2=Từ chối, 3=Yêu cầu nộp lại. |
| 14 | aprv_dt | DATE | X |  |  |  | Ngày duyệt báo cáo. |
| 15 | approver | STRING | X |  |  |  | Người duyệt. |
| 16 | rejection_rsn | STRING | X |  |  |  | Lý do từ chối. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| abnormal_tdg_rpt_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng abnormal_tdg_rpt_file_attch



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | abnormal_tdg_rpt_file_attch_id | STRING |  | X | P |  | Khóa đại diện cho file đính kèm báo cáo bất thường. |
| 2 | abnormal_tdg_rpt_file_attch_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.abnormal_report_file' | Mã nguồn dữ liệu. |
| 4 | abnormal_tdg_rpt_id | STRING |  |  | F |  | FK đến báo cáo giao dịch bất thường. |
| 5 | abnormal_tdg_rpt_code | STRING |  |  |  |  | Mã báo cáo bất thường. Denormalized. |
| 6 | file_nm | STRING | X |  |  |  | Tên file đính kèm. |
| 7 | file_path | STRING | X |  |  |  | Đường dẫn file. |
| 8 | file_sz | STRING | X |  |  |  | Kích thước file (bytes). |
| 9 | file_tp_code | STRING | X |  |  |  | Loại file: CSV, XLSX, PDF. |
| 10 | digital_sgn | STRING | X |  |  |  | Chữ ký số của file. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| abnormal_tdg_rpt_file_attch_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| abnormal_tdg_rpt_id | abnormal_tdg_rpt | abnormal_tdg_rpt_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mkt_surveil_anl_rpt



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mkt_surveil_anl_rpt_id | STRING |  | X | P |  | Khóa đại diện cho báo cáo kết quả phân tích vụ việc. |
| 2 | mkt_surveil_anl_rpt_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.analysis_report' | Mã nguồn dữ liệu. |
| 4 | mkt_surveil_case_id | STRING |  |  | F |  | FK đến vụ việc giám sát. |
| 5 | mkt_surveil_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. |
| 6 | rpt_tp_code | STRING | X |  |  |  | Loại báo cáo phân tích vụ việc. |
| 7 | rpt_dt | DATE | X |  |  |  | Ngày lập báo cáo. |
| 8 | rpt_data | STRING | X |  |  |  | Dữ liệu báo cáo (JSON hoặc XML). Lưu raw — không parse. |
| 9 | rpt_file_path | STRING | X |  |  |  | Đường dẫn file báo cáo. |
| 10 | anl_exec_log_id | STRING | X |  | F |  | ID phân tích biểu mẫu. Denormalized — không tạo FK tường minh để tránh cross-tier dependency. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_surveil_anl_rpt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| mkt_surveil_case_id | mkt_surveil_case | mkt_surveil_case_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mkt_surveil_case_doc_attch



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mkt_surveil_case_doc_attch_id | STRING |  | X | P |  | Khóa đại diện cho file đính kèm vụ việc giám sát. |
| 2 | mkt_surveil_case_doc_attch_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.case_attach_file' | Mã nguồn dữ liệu. |
| 4 | mkt_surveil_case_id | STRING |  |  | F |  | FK đến vụ việc giám sát. |
| 5 | mkt_surveil_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. |
| 6 | file_nm | STRING | X |  |  |  | Tên file đính kèm. |
| 7 | file_path | STRING | X |  |  |  | Đường dẫn file. |
| 8 | file_sz | STRING | X |  |  |  | Kích thước file (bytes). |
| 9 | file_tp_code | STRING | X |  |  |  | Loại file: CSV, XLSX, PDF. |
| 10 | file_grp_code | STRING | X |  |  |  | Nhóm file: 1=Hồ sơ của Sở, 2=Danh sách tài khoản nghi vấn. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_surveil_case_doc_attch_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| mkt_surveil_case_id | mkt_surveil_case | mkt_surveil_case_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mkt_surveil_cmpln_rpt_clmn_config



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mkt_surveil_cmpln_rpt_clmn_config_id | STRING |  | X | P |  | Khóa đại diện cho cấu hình cột báo cáo tuân thủ. |
| 2 | mkt_surveil_cmpln_rpt_clmn_config_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.compliance_report_config' | Mã nguồn dữ liệu. |
| 4 | mkt_surveil_cmpln_rpt_tpl_id | STRING |  |  | F |  | FK đến mẫu báo cáo tuân thủ. |
| 5 | mkt_surveil_cmpln_rpt_tpl_code | STRING |  |  |  |  | Mã mẫu báo cáo tuân thủ. Denormalized. |
| 6 | clmn_lbl | STRING | X |  |  |  | Nhãn cột trong báo cáo. |
| 7 | dspl_ordr | INT | X |  |  |  | Thứ tự hiển thị cột. |
| 8 | data_tp_code | STRING | X |  |  |  | Kiểu dữ liệu của cột. |
| 9 | is_visible | BOOLEAN | X |  |  |  | Cờ hiển thị cột. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_surveil_cmpln_rpt_clmn_config_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| mkt_surveil_cmpln_rpt_tpl_id | mkt_surveil_cmpln_rpt_tpl | mkt_surveil_cmpln_rpt_tpl_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mkt_surveil_cmpln_rpt_instn



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mkt_surveil_cmpln_rpt_instn_id | STRING |  | X | P |  | Khóa đại diện cho instance báo cáo tuân thủ theo kỳ. |
| 2 | mkt_surveil_cmpln_rpt_instn_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.compliance_report_master' | Mã nguồn dữ liệu. |
| 4 | mkt_surveil_cmpln_rpt_tpl_id | STRING |  |  | F |  | FK đến mẫu báo cáo tuân thủ. |
| 5 | mkt_surveil_cmpln_rpt_tpl_code | STRING |  |  |  |  | Mã mẫu báo cáo tuân thủ. Denormalized. |
| 6 | prd_tp_code | STRING | X |  |  |  | Loại kỳ báo cáo. |
| 7 | prd_val | STRING | X |  |  |  | Giá trị kỳ báo cáo (ví dụ: tháng 1 = 1). |
| 8 | prd_yr | INT | X |  |  |  | Năm kỳ báo cáo. |
| 9 | instn_st_code | STRING | X |  |  |  | Trạng thái instance báo cáo. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_surveil_cmpln_rpt_instn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| mkt_surveil_cmpln_rpt_tpl_id | mkt_surveil_cmpln_rpt_tpl | mkt_surveil_cmpln_rpt_tpl_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mkt_surveil_cmpln_rpt_row_data



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mkt_surveil_cmpln_rpt_row_data_id | STRING |  | X | P |  | Khóa đại diện cho dòng dữ liệu báo cáo tuân thủ. |
| 2 | mkt_surveil_cmpln_rpt_row_data_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.compliance_report_data' | Mã nguồn dữ liệu. |
| 4 | mkt_surveil_cmpln_rpt_instn_id | STRING |  |  | F |  | FK đến instance báo cáo tuân thủ. |
| 5 | mkt_surveil_cmpln_rpt_instn_code | STRING |  |  |  |  | Mã instance báo cáo tuân thủ. Denormalized. |
| 6 | row_data | STRING | X |  |  |  | Dữ liệu một dòng trong báo cáo tuân thủ (JSON/text raw). Schema không ổn định — không parse. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_surveil_cmpln_rpt_row_data_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| mkt_surveil_cmpln_rpt_instn_id | mkt_surveil_cmpln_rpt_instn | mkt_surveil_cmpln_rpt_instn_id |



#### Index

N/A

#### Trigger

N/A




### Bảng list_co_corp_ev



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | list_co_corp_ev_id | STRING |  | X | P |  | Khóa đại diện cho sự kiện tổ chức niêm yết. |
| 2 | list_co_corp_ev_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.company_event' | Mã nguồn dữ liệu. |
| 4 | co_nm | STRING | X |  |  |  | Tên tổ chức niêm yết. Denormalized — không có FK tường minh đến entity niêm yết. |
| 5 | stk_code | STRING | X |  |  |  | Mã chứng khoán. Denormalized — không có FK tường minh. |
| 6 | ev_tp_code | STRING | X |  | F |  | Loại sự kiện tổ chức niêm yết. |
| 7 | ev_id | STRING | X |  |  |  | Định danh sự kiện. Denormalized — không rõ FK đến đâu. |
| 8 | ev_dt | DATE | X |  |  |  | Ngày sự kiện. |
| 9 | aprv_st_code | STRING | X |  |  |  | Trạng thái phê duyệt. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| list_co_corp_ev_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng mkt_surveil_sspcs_ac



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mkt_surveil_sspcs_ac_id | STRING |  | X | P |  | Khóa đại diện cho tài khoản nghi vấn trong vụ việc. |
| 2 | mkt_surveil_sspcs_ac_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.suspicious_account' | Mã nguồn dữ liệu. |
| 4 | mkt_surveil_case_id | STRING |  |  | F |  | FK đến vụ việc giám sát. |
| 5 | mkt_surveil_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. |
| 6 | ivsr_tdg_ac_id | STRING |  |  | F |  | FK đến tài khoản giao dịch nghi vấn. |
| 7 | ivsr_tdg_ac_code | STRING |  |  |  |  | Mã tài khoản nghi vấn. Denormalized. |
| 8 | crit_flags | STRING | X |  |  |  | Các tiêu chí đánh giá (JSON hoặc comma-separated). |
| 9 | sspcs_src_code | STRING | X |  |  |  | Nguồn xác định TK nghi vấn: 1=Hệ thống tự động, 2=User thêm. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_surveil_sspcs_ac_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| mkt_surveil_case_id | mkt_surveil_case | mkt_surveil_case_id |
| ivsr_tdg_ac_id | ivsr_tdg_ac | ivsr_tdg_ac_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mkt_surveil_sspcs_ac_grp



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mkt_surveil_sspcs_ac_grp_id | STRING |  | X | P |  | Khóa đại diện cho nhóm tài khoản nghi vấn trong vụ việc. |
| 2 | mkt_surveil_sspcs_ac_grp_code | STRING |  |  |  |  | Mã nhóm tài khoản nghi vấn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.suspicious_account_group' | Mã nguồn dữ liệu. |
| 4 | mkt_surveil_case_id | STRING |  |  | F |  | FK đến vụ việc giám sát. |
| 5 | mkt_surveil_case_code | STRING |  |  |  |  | Mã vụ việc. Denormalized. |
| 6 | grp_nm | STRING | X |  |  |  | Tên nhóm tài khoản nghi vấn. |
| 7 | dsc | STRING | X |  |  |  | Mô tả nhóm. |
| 8 | rltnp_crit_code | STRING | X |  |  |  | Tiêu chí phân nhóm: Danh tính, IP, MAC, Tiền. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_surveil_sspcs_ac_grp_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| mkt_surveil_case_id | mkt_surveil_case | mkt_surveil_case_id |



#### Index

N/A

#### Trigger

N/A




### Bảng ac_ivsr_grp



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ac_ivsr_grp_id | STRING |  | X | P |  | Khóa đại diện cho nhóm tài khoản nhà đầu tư. |
| 2 | ac_ivsr_grp_code | STRING |  |  |  |  | Mã nhóm (hệ thống tự sinh). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.account_group' | Mã nguồn dữ liệu. |
| 4 | grp_nm | STRING | X |  |  |  | Tên nhóm. |
| 5 | grp_tp_code | STRING | X |  |  |  | Loại nhóm: 1=Thường, 2=Nghi vấn. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ac_ivsr_grp_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng ac_ivsr_grp_mbr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ac_ivsr_grp_mbr_id | STRING |  | X | P |  | Khóa đại diện cho thành viên nhóm tài khoản. |
| 2 | ac_ivsr_grp_mbr_code | STRING |  |  |  |  | PK kỹ thuật từ bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.account_group_member' | Mã nguồn dữ liệu. |
| 4 | ac_ivsr_grp_id | STRING |  |  | F |  | FK đến nhóm tài khoản. |
| 5 | ac_ivsr_grp_code | STRING |  |  |  |  | Mã nhóm tài khoản. Denormalized. |
| 6 | ivsr_tdg_ac_id | STRING |  |  | F |  | FK đến tài khoản giao dịch chứng khoán. |
| 7 | ivsr_tdg_ac_code | STRING |  |  |  |  | Mã tài khoản giao dịch. Denormalized. |
| 8 | mbr_st_code | STRING | X |  |  |  | Trạng thái tài khoản trong nhóm. |
| 9 | rltnp_tp | STRING | X |  |  |  | Mối quan hệ: Danh tính, IP, MAC, Tiền. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ac_ivsr_grp_mbr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ac_ivsr_grp_id | ac_ivsr_grp | ac_ivsr_grp_id |
| ivsr_tdg_ac_id | ivsr_tdg_ac | ivsr_tdg_ac_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_watchlist_grp



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_watchlist_grp_id | STRING |  | X | P |  | Khóa đại diện cho nhóm chứng khoán giám sát. |
| 2 | scr_watchlist_grp_code | STRING |  |  |  |  | Mã nhóm (hệ thống tự sinh). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'GSGD.securities_group' | Mã nguồn dữ liệu. |
| 4 | grp_nm | STRING | X |  |  |  | Tên nhóm chứng khoán. |
| 5 | grp_tp_code | STRING | X |  |  |  | Loại nhóm: 1=Thường, 2=Theo ngành. |
| 6 | dsc | STRING | X |  |  |  | Mô tả nhóm. |
| 7 | grp_st_code | STRING | X |  |  |  | Trạng thái: 1=Chờ duyệt, 2=Phê duyệt, 3=Từ chối. |
| 8 | scr_codes | ARRAY<STRING> | X |  |  |  | Danh sách mã chứng khoán trong nhóm. Denormalized từ bảng junction securities_group_member. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_watchlist_grp_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Stored Procedure/Function

N/A

### Package

N/A
