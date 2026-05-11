## SCMS — Phần hệ quản lý giám sát công ty chứng khoán

### Các mô hình quan hệ dữ liệu

![Mô hình quan hệ dữ liệu SCMS](SCMS/fragments/SCMS_diagram.png)

**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | dscl_rpt_subm | Báo cáo công bố thông tin do CTCK nộp lên UBCKNN theo yêu cầu minh bạch thị trường. |
| 2 | dscl_scr_ofrg | Thông tin chào bán chứng khoán được công bố bởi CTCK. Ghi nhận loại chứng khoán và điều kiện chào bán. |
| 3 | dscl_shrhlr_chg | Thông tin thay đổi cổ đông được công bố bởi CTCK. Ghi nhận cổ đông và tỷ lệ sở hữu thay đổi. |
| 4 | scr_co_admn_pny | Quyết định xử lý hành chính đối với CTCK. Ghi nhận hành vi vi phạm và quyết định xử phạt. |
| 5 | scr_co_rpt_vln | Vi phạm nộp báo cáo định kỳ của CTCK. Ghi nhận loại vi phạm và thông tin xử lý. |
| 6 | mbr_prd_rpt | Báo cáo định kỳ do thành viên thị trường nộp lên UBCKNN theo từng kỳ báo cáo. Ghi nhận trạng thái nộp và thời hạn. |
| 7 | rpt_subm_oblg | Nghĩa vụ gửi báo cáo của từng CTCK theo định kỳ cụ thể. Xác định đơn vị nào phải nộp biểu mẫu nào theo lịch nào. |
| 8 | rpt_subm_shd | Lịch định kỳ gửi báo cáo theo biểu mẫu (hàng ngày/tuần/tháng/quý/năm). Xác định tần suất nghĩa vụ nộp báo cáo. |
| 9 | mbr_rpt_ind_val | Giá trị từng chỉ tiêu trong một lần nộp báo cáo định kỳ. Grain = 1 giá trị cell-level (submission x template_indicator x row). FK đến Member Periodic Report. |
| 10 | rpt_tpl | Biểu mẫu báo cáo đầu vào - khuôn mẫu tờ khai định kỳ mà thành viên thị trường phải nộp theo quy định. |
| 11 | audt_firm | Công ty kiểm toán được UBCKNN chấp thuận. Ghi nhận thông tin pháp lý và trạng thái hoạt động. |
| 12 | audt_firm_prac | Kiểm toán viên thuộc công ty kiểm toán. Ghi nhận chứng chỉ kiểm toán và trạng thái hành nghề. |
| 13 | frgn_rprs_offc | Văn phòng đại diện của công ty chứng khoán nước ngoài tại Việt Nam. Pháp nhân độc lập, không FK đến CTCK trong nước. |
| 14 | scr_co | Công ty chứng khoán - thành viên thị trường trong hệ thống FIMS. Quản lý tài khoản và danh mục NĐT nước ngoài. |
| 15 | scr_co_ou | Đơn vị trực thuộc CTCK: chi nhánh, văn phòng đại diện, phòng giao dịch. Cấu trúc self-join qua parent_org_unit_id. |
| 16 | scr_co_snr_psn | Nhân sự cao cấp của CTCK (Chủ tịch HĐQT, Tổng Giám đốc, Kế toán trưởng...). Ghi nhận chức vụ và thời gian đảm nhận. |
| 17 | scr_co_svc_rgst | Đăng ký dịch vụ của CTCK tại UBCKNN. Grain: 1 dòng = 1 dịch vụ x 1 CTCK. Ghi nhận loại dịch vụ — số văn bản và ngày đăng ký/kết thúc — trạng thái hiệu lực. |
| 18 | scr_co_shrhlr | Cổ đông của CTCK - cá nhân hoặc tổ chức. Ghi nhận tỷ lệ sở hữu và số lượng cổ phần. |
| 19 | scr_co_shrhlr_rel_p | Người có quan hệ gia đình hoặc công tác với cổ đông của CTCK. Ghi nhận loại quan hệ và nơi làm việc. |
| 20 | scr_co_shrhlr_rprs | Người đại diện được ủy quyền bởi cổ đông của CTCK. Ghi nhận chức vụ và số lượng cổ phần đại diện. |
| 21 | scr_prac | Người hành nghề chứng khoán được UBCKNN cấp phép. Ghi nhận thông tin cá nhân và trạng thái hành nghề. Attribute chi tiết (BirthDate full |
| 22 | geo | Đơn vị địa lý dùng làm FK tham chiếu: quốc gia/quốc tịch (COUNTRY), vùng/miền (REGION), tỉnh/thành phố mới/cũ (PROVINCE/PROVINCE_OLD), quận/huyện cũ (DISTRICT_OLD), phường/xã mới/cũ (WARD/WARD_OLD). Phân biệt bằng geographic_area_type_code. Hỗ trợ song song bộ danh mục pre- và post-sáp nhập hành chính 2025. |
| 23 | scr_co_shrhlr_tfr | Giao dịch chuyển nhượng cổ phần giữa hai cổ đông của CTCK. Ghi nhận bên chuyển/nhận, số lượng và tỷ lệ chuyển nhượng. |
| 24 | ip_alt_identn | Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn. |
| 25 | ip_elc_adr | Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn. |
| 26 | ip_pst_adr | Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn. |




### Bảng dscl_rpt_subm



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | dscl_rpt_subm_id | STRING |  | X | P |  | Khóa đại diện cho lần công bố thông tin báo cáo. |
| 2 | dscl_rpt_subm_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CBTT_BAO_CAO' | Mã nguồn dữ liệu. |
| 4 | scr_co_id | STRING |  |  | F |  | FK đến công ty chứng khoán công bố. |
| 5 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 6 | dscl_mth_code | STRING | X |  |  |  | Kiểu công bố thông tin. |
| 7 | dscl_tp_code | STRING | X |  |  |  | Loại công bố thông tin. |
| 8 | rpt_prd_code | STRING | X |  |  |  | Kỳ báo cáo. |
| 9 | rpt_yr | INT | X |  |  |  | Năm báo cáo. |
| 10 | ttl | STRING | X |  |  |  | Tiêu đề thông tin công bố. |
| 11 | dsc | STRING | X |  |  |  | Mô tả nội dung. |
| 12 | smy | STRING | X |  |  |  | Nội dung trích yếu. |
| 13 | disclosing_psn_nm | STRING | X |  |  |  | Người công bố thông tin. |
| 14 | dscl_dt | DATE | X |  |  |  | Ngày công bố thông tin. |
| 15 | subm_dt | DATE | X |  |  |  | Ngày gửi lên hệ thống. |
| 16 | attch_file | STRING | X |  |  |  | Tệp đính kèm. |
| 17 | err_dsc | STRING | X |  |  |  | Mô tả lỗi (nếu có). |
| 18 | dscl_st_code | STRING | X |  |  |  | Trạng thái công bố thông tin. |
| 19 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| dscl_rpt_subm_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_co_id | scr_co | scr_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng dscl_scr_ofrg



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | dscl_scr_ofrg_id | STRING |  | X | P |  | Khóa đại diện cho đợt chào bán chứng khoán được công bố. |
| 2 | dscl_scr_ofrg_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CBTT_CHAO_BAN_CHUNG_KHOAN' | Mã nguồn dữ liệu. |
| 4 | scr_co_id | STRING |  |  | F |  | FK đến công ty chứng khoán chào bán. |
| 5 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 6 | doc_nbr | STRING | X |  |  |  | Số văn bản. |
| 7 | doc_dt | DATE | X |  |  |  | Ngày văn bản. |
| 8 | eff_dt | DATE | X |  |  |  | Ngày hợp lệ hồ sơ. |
| 9 | ofrg_strt_dt | DATE | X |  |  |  | Ngày bắt đầu chào bán. |
| 10 | ofrg_end_dt | DATE | X |  |  |  | Ngày kết thúc chào bán. |
| 11 | ofrg_form_code | STRING | X |  |  |  | Hình thức chào bán. |
| 12 | trgt_ivsr_nm | STRING | X |  |  |  | Đối tượng chào bán. |
| 13 | ofrg_vol | DECIMAL(23,2) | X |  |  |  | Khối lượng chào bán. |
| 14 | ofrg_val | DECIMAL(23,2) | X |  |  |  | Giá trị chào bán. |
| 15 | note | STRING | X |  |  |  | Ghi chú. |
| 16 | disclosing_psn_nm | STRING | X |  |  |  | Người công bố thông tin. |
| 17 | dscl_dt | DATE | X |  |  |  | Ngày công bố thông tin. |
| 18 | subm_dt | DATE | X |  |  |  | Ngày gửi lên hệ thống. |
| 19 | attch_file | STRING | X |  |  |  | Tệp đính kèm. |
| 20 | err_dsc | STRING | X |  |  |  | Mô tả lỗi. |
| 21 | dscl_st_code | STRING | X |  |  |  | Trạng thái công bố. |
| 22 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 23 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| dscl_scr_ofrg_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_co_id | scr_co | scr_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng dscl_shrhlr_chg



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | dscl_shrhlr_chg_id | STRING |  | X | P |  | Khóa đại diện cho thông tin cổ đông được công bố. |
| 2 | dscl_shrhlr_chg_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CBTT_CO_DONG' | Mã nguồn dữ liệu. |
| 4 | scr_co_id | STRING |  |  | F |  | FK đến công ty chứng khoán công bố. |
| 5 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 6 | txn_tp_code | STRING | X |  | F |  | Loại giao dịch cổ đông. |
| 7 | dscl_dt | DATE | X |  |  |  | Ngày công bố thông tin. |
| 8 | cntnt | STRING | X |  |  |  | Nội dung công bố. |
| 9 | attch_file | STRING | X |  |  |  | Tệp đính kèm. |
| 10 | dscl_st_code | STRING | X |  |  |  | Trạng thái công bố. |
| 11 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| dscl_shrhlr_chg_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_co_id | scr_co | scr_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_co_admn_pny



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_co_admn_pny_id | STRING |  | X | P |  | Khóa đại diện cho quyết định xử lý hành chính. |
| 2 | scr_co_admn_pny_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_XU_LY_HANH_CHINH' | Mã nguồn dữ liệu. |
| 4 | scr_co_id | STRING |  |  | F |  | FK đến công ty chứng khoán bị xử lý. |
| 5 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 6 | pny_form_code | STRING | X |  |  |  | Hình thức xử lý hành chính. |
| 7 | cntnt | STRING | X |  |  |  | Nội dung quyết định xử lý. |
| 8 | pny_amt | DECIMAL(23,2) | X |  |  |  | Số tiền phạt. |
| 9 | adl_pny | STRING | X |  |  |  | Hình phạt bổ sung. |
| 10 | adl_pny_dt | DATE | X |  |  |  | Ngày áp dụng hình phạt bổ sung. |
| 11 | dcsn_nbr | STRING | X |  |  |  | Số quyết định xử lý hành chính. |
| 12 | dcsn_dt | DATE | X |  |  |  | Ngày quyết định. |
| 13 | pny_st_code | STRING | X |  |  |  | Trạng thái quyết định xử lý. |
| 14 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 15 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_co_admn_pny_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_co_id | scr_co | scr_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_co_rpt_vln



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_co_rpt_vln_id | STRING |  | X | P |  | Khóa đại diện cho bản ghi vi phạm báo cáo. |
| 2 | scr_co_rpt_vln_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.BC_VI_PHAM' | Mã nguồn dữ liệu. |
| 4 | scr_co_id | STRING |  |  | F |  | FK đến công ty chứng khoán vi phạm. |
| 5 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 6 | vln_dt | DATE | X |  |  |  | Ngày vi phạm. |
| 7 | rsn | STRING | X |  |  |  | Lý do vi phạm. |
| 8 | vln_tp_codes | ARRAY<STRING> | X |  |  |  | Danh sách mã loại vi phạm. |
| 9 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_co_rpt_vln_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_co_id | scr_co | scr_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mbr_prd_rpt



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mbr_prd_rpt_id | STRING |  | X | P |  | Khóa đại diện cho lần gửi báo cáo định kỳ. |
| 2 | mbr_prd_rpt_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.BC_THANH_VIEN' | Mã nguồn dữ liệu. |
| 4 | fnd_mgt_co_id | STRING | X |  | F |  | FK đến công ty QLQ nộp báo cáo (nullable). |
| 5 | fnd_mgt_co_code | STRING | X |  |  |  | Mã công ty QLQ. |
| 6 | ivsm_fnd_id | STRING | X |  | F |  | FK đến quỹ đầu tư nộp báo cáo (nullable). |
| 7 | ivsm_fnd_code | STRING | X |  |  |  | Mã quỹ đầu tư. |
| 8 | cstd_bnk_id | STRING | X |  | F |  | FK đến ngân hàng LKGS nộp báo cáo (nullable). |
| 9 | cstd_bnk_code | STRING | X |  |  |  | Mã ngân hàng LKGS. |
| 10 | frgn_fnd_mgt_ou_id | STRING | X |  | F |  | FK đến VPĐD/CN QLQ NN nộp báo cáo (nullable). |
| 11 | frgn_fnd_mgt_ou_code | STRING | X |  |  |  | Mã VPĐD/CN QLQ NN. |
| 12 | rpt_tpl_id | STRING |  |  | F |  | FK đến biểu mẫu báo cáo. |
| 13 | rpt_tpl_code | STRING |  |  |  |  | Mã biểu mẫu báo cáo. |
| 14 | rpt_prd_id | STRING |  |  | F |  | FK đến kỳ báo cáo. |
| 15 | rpt_prd_code | STRING |  |  |  |  | Mã kỳ báo cáo. |
| 16 | is_impr_ind | STRING | X |  |  |  | Là báo cáo có import: 1-Có; 2-Không. |
| 17 | rpt_nm | STRING | X |  |  |  | Tên báo cáo. |
| 18 | cntnt_smy | STRING | X |  |  |  | Tóm tắt nội dung báo cáo. |
| 19 | rpt_tp_code | STRING | X |  |  |  | Loại báo cáo: định kỳ hoặc bất thường. |
| 20 | rpt_mbr_tp_code | STRING | X |  |  |  | Loại thành viên nộp báo cáo. |
| 21 | rpt_prd_tp_code | STRING | X |  |  |  | Kiểu kỳ báo cáo (tháng/quý/năm). |
| 22 | yr_val | STRING | X |  |  |  | Năm báo cáo. |
| 23 | day_rpt | INT | X |  |  |  | Ngày trong kỳ báo cáo. |
| 24 | subm_ddln_dt | DATE | X |  |  |  | Thời hạn nộp báo cáo. |
| 25 | subm_dt | DATE | X |  |  |  | Ngày gửi báo cáo. |
| 26 | rpt_subm_st_code | STRING | X |  |  |  | Trạng thái nộp báo cáo. |
| 27 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 28 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 29 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 30 | scr_co_id | STRING |  |  | F |  | FK đến công ty chứng khoán gửi báo cáo. |
| 31 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 32 | rpt_subm_shd_id | STRING | X |  | F |  | FK đến định kỳ gửi báo cáo. |
| 33 | rpt_subm_shd_code | STRING | X |  |  |  | Mã định kỳ gửi báo cáo. |
| 34 | dsc | STRING | X |  |  |  | Mô tả lần gửi. |
| 35 | rsn | STRING | X |  |  |  | Lý do gửi (áp dụng gửi lại). |
| 36 | re_subm_rsn | STRING | X |  |  |  | Lý do gửi lại. |
| 37 | attch_file | STRING | X |  |  |  | Tệp đính kèm. |
| 38 | rpt_dt | DATE | X |  |  |  | Ngày số liệu báo cáo. |
| 39 | subm_tms | TIMESTAMP | X |  |  |  | Thời điểm gửi chính xác. |
| 40 | is_del_ind | STRING | X |  |  |  | Cờ xóa tạm: 1-Xóa; 0-Không xóa. |
| 41 | subm_st_code | STRING | X |  |  |  | Trạng thái lần gửi: 4-Đã gửi; 5-Yêu cầu gửi lại; 6-Đã gửi lại. |
| 42 | vrsn | STRING | X |  |  |  | Phiên bản báo cáo. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mbr_prd_rpt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| fnd_mgt_co_id | fnd_mgt_co | fnd_mgt_co_id |
| ivsm_fnd_id | ivsm_fnd | ivsm_fnd_id |
| cstd_bnk_id | cstd_bnk | cstd_bnk_id |
| frgn_fnd_mgt_ou_id | frgn_fnd_mgt_ou | frgn_fnd_mgt_ou_id |
| rpt_tpl_id | rpt_tpl | rpt_tpl_id |
| rpt_prd_id | rpt_prd | rpt_prd_id |
| scr_co_id | scr_co | scr_co_id |
| rpt_subm_shd_id | rpt_subm_shd | rpt_subm_shd_id |



#### Index

N/A

#### Trigger

N/A




### Bảng rpt_subm_oblg



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rpt_subm_oblg_id | STRING |  | X | P |  | Khóa đại diện cho nghĩa vụ gửi báo cáo. |
| 2 | rpt_subm_oblg_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.BM_BAO_CAO_DINH_KY_DON_VI' | Mã nguồn dữ liệu. |
| 4 | rpt_subm_shd_id | STRING |  |  | F |  | FK đến định kỳ gửi báo cáo. |
| 5 | rpt_subm_shd_code | STRING |  |  |  |  | Mã định kỳ gửi báo cáo. |
| 6 | scr_co_id | STRING |  |  | F |  | FK đến công ty chứng khoán có nghĩa vụ gửi. |
| 7 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 8 | obligated_companies_refr_code | STRING | X |  | F |  | BK tham chiếu đến bản ghi danh sách thành viên gửi (BM_BAO_CAO_TV). |
| 9 | vrsn | STRING | X |  |  |  | Phiên bản nghĩa vụ. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rpt_subm_oblg_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rpt_subm_shd_id | rpt_subm_shd | rpt_subm_shd_id |
| scr_co_id | scr_co | scr_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng rpt_subm_shd



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rpt_subm_shd_id | STRING |  | X | P |  | Khóa đại diện cho định kỳ gửi báo cáo. |
| 2 | rpt_subm_shd_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.BM_BAO_CAO_DINH_KY' | Mã nguồn dữ liệu. |
| 4 | rpt_tpl_id | STRING |  |  | F |  | FK đến biểu mẫu báo cáo. |
| 5 | rpt_tpl_code | STRING |  |  |  |  | Mã biểu mẫu báo cáo. |
| 6 | vrsn | STRING | X |  |  |  | Phiên bản định kỳ báo cáo. |
| 7 | rpt_prd_tp_code | STRING | X |  |  |  | Kỳ báo cáo (tần suất định kỳ). |
| 8 | grc_prd_dys | INT | X |  |  |  | Khoảng thời gian gia hạn T+ (số ngày). |
| 9 | subm_ddln | STRING | X |  |  |  | Thời gian nộp báo cáo. |
| 10 | is_actv_f | BOOLEAN | X |  |  |  | Trạng thái sử dụng: 1-Sử dụng; 0-Không sử dụng. |
| 11 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rpt_subm_shd_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rpt_tpl_id | rpt_tpl | rpt_tpl_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mbr_rpt_ind_val



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mbr_rpt_ind_val_id | STRING |  | X | P |  | Khóa đại diện cho giá trị chỉ tiêu báo cáo. |
| 2 | mbr_rpt_ind_val_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.BC_BAO_CAO_GT' | Mã nguồn dữ liệu. |
| 4 | rpt_tpl_id | STRING | X |  | F |  | FK đến biểu mẫu báo cáo. |
| 5 | rpt_tpl_code | STRING | X |  |  |  | Mã biểu mẫu báo cáo. |
| 6 | scr_co_id | STRING | X |  | F |  | FK đến công ty chứng khoán nộp báo cáo. |
| 7 | scr_co_code | STRING | X |  |  |  | Mã công ty chứng khoán. |
| 8 | rpt_tpl_shet_id | STRING | X |  | F |  | FK đến sheet báo cáo. |
| 9 | rpt_tpl_shet_code | STRING | X |  |  |  | Mã sheet báo cáo. |
| 10 | rpt_tpl_row_id | STRING | X |  | F |  | FK đến hàng báo cáo. |
| 11 | rpt_tpl_row_code | STRING | X |  |  |  | Mã hàng báo cáo. |
| 12 | rpt_tpl_clmn_id | STRING | X |  | F |  | FK đến cột báo cáo. |
| 13 | rpt_tpl_clmn_code | STRING | X |  |  |  | Mã cột báo cáo. |
| 14 | mbr_prd_rpt_id | STRING |  |  | F |  | FK đến lần nộp báo cáo. |
| 15 | mbr_prd_rpt_code | STRING |  |  |  |  | Mã lần nộp báo cáo. |
| 16 | rpt_tpl_ind_id | STRING | X |  | F |  | FK đến chỉ tiêu trong biểu mẫu. |
| 17 | rpt_tpl_ind_code | STRING | X |  |  |  | Mã chỉ tiêu trong biểu mẫu. |
| 18 | rpt_ind_id | STRING | X |  | F |  | FK đến chỉ tiêu danh mục. |
| 19 | rpt_ind_code | STRING | X |  |  |  | Mã chỉ tiêu danh mục. |
| 20 | shet_nm | STRING | X |  |  |  | Tên sheet báo cáo (denormalized). |
| 21 | row_nm | STRING | X |  |  |  | Tên hàng báo cáo (denormalized). |
| 22 | clmn_nm | STRING | X |  |  |  | Tên cột báo cáo (denormalized). |
| 23 | row_seq | INT | X |  | F |  | Số thứ tự dòng dữ liệu (cho chỉ tiêu lặp). |
| 24 | ctlg_nm | STRING | X |  |  |  | Tên danh mục tương ứng (nếu chỉ tiêu kiểu danh mục). |
| 25 | ctlg_id_refr | STRING | X |  | F |  | Khóa danh mục tương ứng. |
| 26 | ctlg_dspl_val | STRING | X |  |  |  | Giá trị hiển thị của danh mục. |
| 27 | val | STRING | X |  |  |  | Giá trị chỉ tiêu. |
| 28 | frml | STRING | X |  |  |  | Công thức tính (nếu có). |
| 29 | agrt_frml | STRING | X |  |  |  | Công thức tổng hợp. |
| 30 | rpt_dt | DATE | X |  |  |  | Ngày số liệu báo cáo. |
| 31 | vrsn | STRING | X |  |  |  | Phiên bản báo cáo. |
| 32 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 33 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mbr_rpt_ind_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rpt_tpl_id | rpt_tpl | rpt_tpl_id |
| scr_co_id | scr_co | scr_co_id |
| rpt_tpl_shet_id |  |  |
| rpt_tpl_row_id |  |  |
| rpt_tpl_clmn_id |  |  |
| mbr_prd_rpt_id | mbr_prd_rpt | mbr_prd_rpt_id |
| rpt_tpl_ind_id |  |  |
| rpt_ind_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng rpt_tpl



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rpt_tpl_id | STRING |  | X | P |  | Khóa đại diện cho biểu mẫu báo cáo. |
| 2 | rpt_tpl_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.BM_BAO_CAO' | Mã nguồn dữ liệu. |
| 4 | rpt_tp_code | STRING | X |  |  |  | Loại báo cáo. Dữ liệu lấy từ trường ID của bảng REPORTTYPE. |
| 5 | rpt_tpl_nm | STRING |  |  |  |  | Tên báo cáo. |
| 6 | rpt_tpl_bsn_code | STRING | X |  |  |  | Mã báo cáo (mã nghiệp vụ). |
| 7 | lgl_bss | STRING | X |  |  |  | Căn cứ pháp lý. |
| 8 | rpt_grp_code | STRING | X |  |  |  | Nhóm báo cáo: 1: Báo cáo CTQLQ 2: CTCK 3: NHLK 4: TTLK 5: SGDCK 6: Người đại diện CBTT 7: CN CTQLQ NN tại VN. |
| 9 | rpt_sbj_code | STRING | X |  |  |  | Đối tượng gửi báo cáo: 1: CTQLQ 2: CTCK 3: NHLK 4: TTLK 5: SGDCK 6: Người đại diện CBTT 7: CN CTQLQ NN tại VN. |
| 10 | vrsn | STRING | X |  |  |  | Phiên bản biểu mẫu. |
| 11 | eff_dt | DATE | X |  |  |  | Ngày bắt đầu sử dụng biểu mẫu. |
| 12 | tpl_st_code | STRING | X |  |  |  | Trạng thái: 0: Bản nháp 1: Đang sử dụng 2: Không sử dụng. |
| 13 | is_impr_rqd_ind | STRING | X |  |  |  | Báo cáo có import: 1: Có import 0: Không import. |
| 14 | is_self_prd_setting_ind | STRING | X |  |  |  | Báo cáo do cán bộ UB tự thiết lập kỳ: 1: Có 0: Không. |
| 15 | is_pblc_dscl_ind | STRING | X |  |  |  | Cho phép CBTT: 0: Không CBTT 1: Có CBTT. |
| 16 | dsc | STRING | X |  |  |  | Mô tả biểu mẫu. |
| 17 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 18 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 19 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. |
| 20 | fcn_cgy_id | STRING | X |  | F |  | FK đến danh mục chức năng (QT_CHUC_NANG). Nullable. |
| 21 | fcn_cgy_code | STRING | X |  |  |  | Mã danh mục chức năng. |
| 22 | rpt_drc_tp_code | STRING | X |  |  |  | Chiều báo cáo: 0-Đầu vào; 1-Đầu ra. |
| 23 | vrsn_dt | DATE | X |  |  |  | Ngày thay đổi phiên bản. |
| 24 | is_actv_f | BOOLEAN | X |  |  |  | Trạng thái sử dụng: 1-Sử dụng; 0-Không sử dụng. |
| 25 | is_smy_rqd_ind | STRING | X |  |  |  | Yêu cầu nhập trích yếu: 0-Không bắt buộc; 1-Bắt buộc. |
| 26 | attch_file | STRING | X |  |  |  | Tệp đính kèm mẫu báo cáo. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rpt_tpl_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng audt_firm



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | audt_firm_id | STRING |  | X | P |  | Khóa đại diện cho công ty kiểm toán. |
| 2 | audt_firm_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CT_KIEM_TOAN' | Mã nguồn dữ liệu. |
| 4 | audt_firm_bsn_code | STRING | X |  |  |  | Mã số công ty kiểm toán (mã nghiệp vụ). |
| 5 | audt_firm_nm | STRING | X |  |  |  | Tên tiếng Việt. |
| 6 | audt_firm_en_nm | STRING | X |  |  |  | Tên tiếng Anh. |
| 7 | audt_firm_shrt_nm | STRING | X |  |  |  | Tên viết tắt. |
| 8 | charter_cptl_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ. |
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




### Bảng audt_firm_prac



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | audt_firm_prac_id | STRING |  | X | P |  | Khóa đại diện cho kiểm toán viên. |
| 2 | audt_firm_prac_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CT_KIEM_TOAN_VIEN' | Mã nguồn dữ liệu. |
| 4 | audt_firm_id | STRING |  |  | F |  | FK đến công ty kiểm toán. |
| 5 | audt_firm_code | STRING |  |  |  |  | Mã công ty kiểm toán. |
| 6 | full_nm | STRING | X |  |  |  | Họ và tên kiểm toán viên. |
| 7 | aprv_dt | DATE | X |  |  |  | Ngày UBCKNN chấp thuận. |
| 8 | revocation_dt | DATE | X |  |  |  | Ngày hủy chấp thuận. |
| 9 | note | STRING | X |  |  |  | Ghi chú. |
| 10 | audt_firm_prac_st_code | STRING | X |  |  |  | Trạng thái kiểm toán viên. |
| 11 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 12 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| audt_firm_prac_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| audt_firm_id | audt_firm | audt_firm_id |



#### Index

N/A

#### Trigger

N/A




### Bảng frgn_rprs_offc



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | frgn_rprs_offc_id | STRING |  | X | P |  | Khóa đại diện cho văn phòng đại diện nước ngoài. |
| 2 | frgn_rprs_offc_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_VP_DAI_DIEN_NN' | Mã nguồn dữ liệu. |
| 4 | prn_co_nm | STRING | X |  |  |  | Tên công ty mẹ (công ty chứng khoán nước ngoài). |
| 5 | prn_co_adr | STRING | X |  |  |  | Địa chỉ trụ sở công ty mẹ. |
| 6 | prn_co_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh công ty mẹ. |
| 7 | prn_co_license_dt | DATE | X |  |  |  | Ngày cấp giấy phép kinh doanh công ty mẹ. |
| 8 | prn_co_license_issur | STRING | X |  |  |  | Nơi cấp giấy phép kinh doanh công ty mẹ. |
| 9 | offc_nm | STRING | X |  |  |  | Tên văn phòng đại diện tại Việt Nam. |
| 10 | offc_adr | STRING | X |  |  |  | Địa chỉ văn phòng đại diện tại Việt Nam. |
| 11 | offc_license_nbr | STRING | X |  |  |  | Số giấy phép hoạt động văn phòng đại diện tại VN. |
| 12 | offc_license_dt | DATE | X |  |  |  | Ngày cấp giấy phép văn phòng đại diện. |
| 13 | offc_license_issur | STRING | X |  |  |  | Nơi cấp giấy phép văn phòng đại diện. |
| 14 | rprs_nm | STRING | X |  |  |  | Trưởng văn phòng đại diện. |
| 15 | nat_id | STRING | X |  | F |  | FK đến quốc tịch trưởng đại diện. |
| 16 | nat_code | STRING | X |  |  |  | Mã quốc tịch trưởng đại diện. |
| 17 | note | STRING | X |  |  |  | Ghi chú. |
| 18 | frgn_rprs_offc_st_code | STRING | X |  |  |  | Trạng thái hoạt động. |
| 19 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 20 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| frgn_rprs_offc_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| nat_id | geo | geo_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_co



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_co_id | STRING |  | X | P |  | Khóa đại diện cho công ty chứng khoán. |
| 2 | scr_co_code | STRING |  |  |  |  | Mã định danh CTCK (tự động tăng). BK kỹ thuật. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_THONG_TIN' | Mã nguồn dữ liệu. |
| 4 | cty_of_rgst_id | STRING | X |  | F |  | FK đến quốc gia đăng ký. |
| 5 | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. |
| 6 | full_nm | STRING |  |  |  |  | Tên công ty chứng khoán. |
| 7 | en_nm | STRING | X |  |  |  | Tên tiếng Anh. |
| 8 | abr | STRING | X |  |  |  | Tên viết tắt. |
| 9 | charter_cptl_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ. |
| 10 | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. |
| 11 | director_nm | STRING | X |  |  |  | Tên Tổng giám đốc (denormalized). |
| 12 | depst_ctf_nbr | STRING | X |  |  |  | Chứng nhận lưu ký. |
| 13 | bsn_tp_codes | ARRAY<STRING> | X |  |  |  | Danh sách mã nghiệp vụ kinh doanh. Từ bảng junction SECCOMBUSINES. |
| 14 | co_tp_codes | ARRAY<STRING> | X |  |  |  | Danh sách mã loại hình doanh nghiệp. Từ bảng junction SECCOMTYPE. |
| 15 | dsc | STRING | X |  |  |  | Ghi chú. |
| 16 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 17 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 18 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. |
| 19 | scr_co_bsn_key | STRING | X |  |  |  | ID duy nhất của CTCK dùng liên thông hệ thống (BK nghiệp vụ). |
| 20 | scr_co_bsn_code | STRING | X |  |  |  | Mã số CTCK (mã nghiệp vụ ngắn). |
| 21 | scr_co_nm | STRING | X |  |  |  | Tên tiếng Việt. |
| 22 | scr_co_en_nm | STRING | X |  |  |  | Tên tiếng Anh. |
| 23 | scr_co_shrt_nm | STRING | X |  |  |  | Tên viết tắt. |
| 24 | tax_code | STRING | X |  |  |  | Mã số thuế. |
| 25 | co_tp_code | STRING | X |  |  |  | Loại hình công ty. |
| 26 | shr_qty | INT | X |  |  |  | Số lượng cổ phần. |
| 27 | bsn_sctr_codes | ARRAY<STRING> | X |  |  |  | Danh sách mã ngành nghề kinh doanh. |
| 28 | is_list_ind | STRING | X |  |  |  | Cờ niêm yết: 1-Có niêm yết; 0-Không. |
| 29 | stk_exg_nm | STRING | X |  |  |  | Sàn niêm yết. |
| 30 | scr_code | STRING | X |  |  |  | Mã chứng khoán niêm yết. |
| 31 | rgst_dt | DATE | X |  |  |  | Ngày đăng ký CTDC. |
| 32 | rgst_dcsn_nbr | STRING | X |  |  |  | Số quyết định đăng ký. |
| 33 | tmt_dt | DATE | X |  |  |  | Ngày kết thúc CTDC. |
| 34 | tmt_dcsn_nbr | STRING | X |  |  |  | Số quyết định kết thúc. |
| 35 | co_st_code | STRING | X |  |  |  | Trạng thái hoạt động của CTCK. |
| 36 | is_drft_ind | STRING | X |  |  |  | Cờ bảng tạm: 1-Bảng tạm; 0-Chính thức. |
| 37 | bsn_avy_cgy_id | STRING | X |  | F |  | FK đến ngành nghề kinh doanh (DM_NGANH_NGHE_KD). Nullable. |
| 38 | bsn_avy_cgy_code | STRING | X |  |  |  | Mã ngành nghề kinh doanh. |
| 39 | bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. |
| 40 | webst | STRING | X |  |  |  | Website chính thức. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_co_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| cty_of_rgst_id | geo | geo_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_co_ou



#### Từ SCMS.CTCK_CHI_NHANH

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_co_ou_id | STRING |  | X | P |  | Khóa đại diện cho đơn vị trực thuộc CTCK. |
| 2 | scr_co_ou_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CHI_NHANH' | Mã nguồn dữ liệu. |
| 4 | ou_tp_code | STRING |  |  |  | 'BRANCH' | Loại đơn vị trực thuộc: BRANCH — chi nhánh. |
| 5 | scr_co_id | STRING |  |  | F |  | FK đến công ty chứng khoán. |
| 6 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 7 | ou_nm | STRING | X |  |  |  | Tên đầy đủ chi nhánh. |
| 8 | dcsn_nbr | STRING | X |  |  |  | Số quyết định thành lập/hoạt động. |
| 9 | dcsn_dt | DATE | X |  |  |  | Ngày quyết định. |
| 10 | vld_doc_dt | DATE | X |  |  |  | Ngày hồ sơ hợp lệ. |
| 11 | director_nm | STRING | X |  |  |  | Giám đốc chi nhánh. |
| 12 | bsn_sctr_nm | STRING | X |  |  |  | Ngành nghề kinh doanh. |
| 13 | ou_st_code | STRING | X |  |  |  | Trạng thái chi nhánh. |
| 14 | note | STRING | X |  |  |  | Ghi chú. |
| 15 | is_drft_ind | STRING | X |  |  |  | Cờ bảng tạm: 1-Bảng tạm; 0-Chính thức. |
| 16 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 17 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. |
| 18 | lcs_code | STRING | X |  |  |  | Trạng thái bản ghi chung. |
| 19 | prn_ou_id | STRING | X |  | F |  | FK đến chi nhánh quản lý (cấp cha). |
| 20 | prn_ou_code | STRING | X |  |  |  | Mã chi nhánh quản lý. |
| 21 | rprs_nm | STRING | X |  |  |  | Người đại diện phòng giao dịch. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_co_ou_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_co_id | scr_co | scr_co_id |
| prn_ou_id | scr_co_ou | scr_co_ou_id |



**Index:** N/A

**Trigger:** N/A


#### Từ SCMS.CTCK_VP_DAI_DIEN

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_co_ou_id | STRING |  | X | P |  | Khóa đại diện cho đơn vị trực thuộc CTCK. |
| 2 | scr_co_ou_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_VP_DAI_DIEN' | Mã nguồn dữ liệu. |
| 4 | ou_tp_code | STRING |  |  |  | 'REPRESENTATIVE_OFFICE' | Loại đơn vị trực thuộc: REPRESENTATIVE_OFFICE — văn phòng đại diện. |
| 5 | scr_co_id | STRING |  |  | F |  | FK đến công ty chứng khoán. |
| 6 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 7 | ou_nm | STRING | X |  |  |  | Tên đầy đủ văn phòng đại diện. |
| 8 | dcsn_nbr | STRING | X |  |  |  | Số quyết định thành lập/hoạt động. |
| 9 | dcsn_dt | DATE | X |  |  |  | Ngày quyết định. |
| 10 | vld_doc_dt | DATE | X |  |  |  | Ngày hồ sơ hợp lệ. |
| 11 | director_nm | STRING | X |  |  |  | Giám đốc chi nhánh. |
| 12 | bsn_sctr_nm | STRING | X |  |  |  | Ngành nghề kinh doanh. |
| 13 | ou_st_code | STRING | X |  |  |  | Trạng thái văn phòng đại diện. |
| 14 | note | STRING | X |  |  |  | Ghi chú. |
| 15 | is_drft_ind | STRING | X |  |  |  | Cờ bảng tạm: 1-Bảng tạm; 0-Chính thức. |
| 16 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 17 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. |
| 18 | lcs_code | STRING | X |  |  |  | Trạng thái bản ghi chung. |
| 19 | prn_ou_id | STRING | X |  | F |  | FK đến chi nhánh quản lý (cấp cha). |
| 20 | prn_ou_code | STRING | X |  |  |  | Mã chi nhánh quản lý. |
| 21 | rprs_nm | STRING | X |  |  |  | Người đại diện văn phòng. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_co_ou_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_co_id | scr_co | scr_co_id |
| prn_ou_id | scr_co_ou | scr_co_ou_id |



**Index:** N/A

**Trigger:** N/A


#### Từ SCMS.CTCK_PHONG_GIAO_DICH

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_co_ou_id | STRING |  | X | P |  | Khóa đại diện cho đơn vị trực thuộc CTCK. |
| 2 | scr_co_ou_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_PHONG_GIAO_DICH' | Mã nguồn dữ liệu. |
| 4 | ou_tp_code | STRING |  |  |  | 'TRANSACTION_OFFICE' | Loại đơn vị trực thuộc: TRANSACTION_OFFICE — phòng giao dịch. |
| 5 | scr_co_id | STRING |  |  | F |  | FK đến công ty chứng khoán. |
| 6 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 7 | ou_nm | STRING | X |  |  |  | Tên đầy đủ phòng giao dịch. |
| 8 | dcsn_nbr | STRING | X |  |  |  | Số quyết định thành lập/hoạt động. |
| 9 | dcsn_dt | DATE | X |  |  |  | Ngày quyết định. |
| 10 | vld_doc_dt | DATE | X |  |  |  | Ngày hồ sơ hợp lệ. |
| 11 | director_nm | STRING | X |  |  |  | Giám đốc chi nhánh. |
| 12 | bsn_sctr_nm | STRING | X |  |  |  | Ngành nghề kinh doanh. |
| 13 | ou_st_code | STRING | X |  |  |  | Trạng thái phòng giao dịch. |
| 14 | note | STRING | X |  |  |  | Ghi chú. |
| 15 | is_drft_ind | STRING | X |  |  |  | Cờ bảng tạm: 1-Bảng tạm; 0-Chính thức. |
| 16 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 17 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. |
| 18 | lcs_code | STRING | X |  |  |  | Trạng thái bản ghi chung. |
| 19 | prn_ou_id | STRING | X |  | F |  | FK đến chi nhánh quản lý (cấp cha). |
| 20 | prn_ou_code | STRING | X |  |  |  | Mã chi nhánh quản lý. |
| 21 | rprs_nm | STRING | X |  |  |  | Người đại diện phòng giao dịch. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_co_ou_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_co_id | scr_co | scr_co_id |
| prn_ou_id | scr_co_ou | scr_co_ou_id |



**Index:** N/A

**Trigger:** N/A





### Bảng scr_co_snr_psn



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_co_snr_psn_id | STRING |  | X | P |  | Khóa đại diện cho nhân sự cao cấp CTCK. |
| 2 | scr_co_snr_psn_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_NHAN_SU_CAO_CAP' | Mã nguồn dữ liệu. |
| 4 | scr_co_id | STRING |  |  | F |  | FK đến công ty chứng khoán. |
| 5 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 6 | ou_id | STRING | X |  | F |  | FK đến chi nhánh trực thuộc (nếu có). |
| 7 | ou_code | STRING | X |  |  |  | Mã chi nhánh trực thuộc. |
| 8 | full_nm | STRING | X |  |  |  | Họ và tên nhân sự cao cấp. |
| 9 | idv_gnd_code | STRING | X |  |  |  | Giới tính. |
| 10 | dob | DATE | X |  |  |  | Ngày sinh. |
| 11 | brth_plc | STRING | X |  |  |  | Nơi sinh. |
| 12 | nat_id | STRING | X |  | F |  | FK đến quốc tịch nhân sự. |
| 13 | nat_code | STRING | X |  |  |  | Mã quốc tịch nhân sự. |
| 14 | pos_tp_code | STRING | X |  | F |  | Chức vụ đảm nhận. |
| 15 | shrhlr_tp_code | STRING | X |  |  |  | Loại cổ đông nếu đồng thời là cổ đông. |
| 16 | resignation_dt | DATE | X |  |  |  | Ngày thôi việc. |
| 17 | note | STRING | X |  |  |  | Ghi chú. |
| 18 | psn_st_code | STRING | X |  |  |  | Trạng thái nhân sự. |
| 19 | is_drft_ind | STRING | X |  |  |  | Cờ bảng tạm: 0-Bảng tạm; 1-Chính thức. |
| 20 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 21 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. |
| 22 | lcs_code | STRING | X |  |  |  | Trạng thái bản ghi chung. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_co_snr_psn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_co_id | scr_co | scr_co_id |
| ou_id | scr_co_ou | scr_co_ou_id |
| nat_id | geo | geo_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_co_svc_rgst



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_co_svc_rgst_id | STRING |  | X | P |  | Khóa đại diện cho đăng ký dịch vụ của CTCK. |
| 2 | scr_co_svc_rgst_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK kỹ thuật. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_DICH_VU' | Mã nguồn dữ liệu. |
| 4 | scr_co_id | STRING |  |  | F |  | FK đến công ty chứng khoán. |
| 5 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 6 | svc_tp_code | STRING |  |  |  |  | Loại dịch vụ đăng ký. |
| 7 | rgst_doc_nbr | STRING | X |  |  |  | Số văn bản đăng ký dịch vụ. |
| 8 | rgst_dt | DATE | X |  |  |  | Ngày đăng ký dịch vụ. |
| 9 | tmt_doc_nbr | STRING | X |  |  |  | Số văn bản kết thúc đăng ký. |
| 10 | tmt_dt | DATE | X |  |  |  | Ngày kết thúc đăng ký. |
| 11 | vld_doc_dt | DATE | X |  |  |  | Ngày hồ sơ hợp lệ. |
| 12 | svc_st_code | STRING | X |  |  |  | Trạng thái đăng ký dịch vụ. |
| 13 | remark | STRING | X |  |  |  | Ghi chú. |
| 14 | is_drft_ind | STRING | X |  |  |  | Cờ bảng tạm: 0-Chính thức; 1-Bảng tạm. |
| 15 | crt_tms | TIMESTAMP | X |  |  |  | Thời điểm tạo bản ghi. |
| 16 | udt_tms | TIMESTAMP | X |  |  |  | Thời điểm cập nhật gần nhất. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_co_svc_rgst_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_co_id | scr_co | scr_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_co_shrhlr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_co_shrhlr_id | STRING |  | X | P |  | Khóa đại diện cho cổ đông CTCK. |
| 2 | scr_co_shrhlr_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CO_DONG' | Mã nguồn dữ liệu. |
| 4 | scr_co_id | STRING |  |  | F |  | FK đến công ty chứng khoán. |
| 5 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 6 | shrhlr_nm | STRING | X |  |  |  | Tên cổ đông (cá nhân hoặc tổ chức). |
| 7 | is_idv_ind | STRING | X |  |  |  | Loại chủ thể: 1-Cá nhân; 0-Tổ chức. |
| 8 | dob | DATE | X |  |  |  | Ngày sinh (áp dụng cho cá nhân). |
| 9 | brth_plc | STRING | X |  |  |  | Nơi sinh. |
| 10 | nat_id | STRING | X |  | F |  | FK đến quốc tịch cổ đông. |
| 11 | nat_code | STRING | X |  |  |  | Mã quốc tịch cổ đông. |
| 12 | is_p_mbr_ind | STRING | X |  |  |  | Cờ đảng viên: 1-Là đảng viên; 0-Không phải. |
| 13 | ed_lvl_nm | STRING | X |  |  |  | Trình độ học vấn. |
| 14 | ocp_nm | STRING | X |  |  |  | Nghề nghiệp. |
| 15 | dgr_nm | STRING | X |  |  |  | Bằng cấp. |
| 16 | is_lgl_rprs_ind | STRING | X |  |  |  | Cờ đại diện pháp nhân. |
| 17 | workplace_nm | STRING | X |  |  |  | Nơi làm việc. |
| 18 | job_pos_nm | STRING | X |  |  |  | Vị trí công việc. |
| 19 | is_empe_ind | STRING | X |  |  |  | Cờ nhân viên CTCK: cổ đông đồng thời là nhân viên. |
| 20 | tdg_ac_nbr | STRING | X |  |  |  | Số tài khoản giao dịch. |
| 21 | shrhlr_tp_code | STRING | X |  |  |  | Loại cổ đông. |
| 22 | shr_qty | INT | X |  |  |  | Số lượng cổ phần đang nắm giữ. |
| 23 | shr_rto | DECIMAL(5,2) | X |  |  |  | Tỷ lệ sở hữu cổ phần (%). |
| 24 | sig_shrhlr_dt | DATE | X |  |  |  | Ngày đạt tỷ lệ sở hữu đáng kể. |
| 25 | note | STRING | X |  |  |  | Ghi chú. |
| 26 | shrhlr_st_code | STRING | X |  |  |  | Trạng thái cổ đông. |
| 27 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 28 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_co_shrhlr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_co_id | scr_co | scr_co_id |
| nat_id | geo | geo_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_co_shrhlr_rel_p



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_co_shrhlr_rel_p_id | STRING |  | X | P |  | Khóa đại diện cho người có quan hệ với cổ đông. |
| 2 | scr_co_shrhlr_rel_p_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CD_MOI_QUAN_HE' | Mã nguồn dữ liệu. |
| 4 | scr_co_shrhlr_id | STRING |  |  | F |  | FK đến cổ đông có người liên quan. |
| 5 | scr_co_shrhlr_code | STRING |  |  |  |  | Mã cổ đông. |
| 6 | scr_co_id | STRING |  |  | F |  | FK đến công ty chứng khoán. |
| 7 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 8 | rel_p_full_nm | STRING | X |  |  |  | Họ và tên người có quan hệ. |
| 9 | rltnp_tp_code | STRING | X |  |  |  | Loại mối quan hệ với cổ đông. |
| 10 | rel_p_workplace_nm | STRING | X |  |  |  | Nơi làm việc. |
| 11 | rel_p_job_pos_nm | STRING | X |  |  |  | Vị trí công việc. |
| 12 | rel_scr_co_nm | STRING | X |  | F |  | Tên CTCK có liên quan (nếu người liên quan cũng là cổ đông CTCK khác). |
| 13 | shr_qty | INT | X |  |  |  | Số lượng cổ phần người liên quan nắm giữ tại CTCK. |
| 14 | shr_rto | DECIMAL(5,2) | X |  |  |  | Tỷ lệ cổ phần người liên quan nắm giữ (%). |
| 15 | attch_file | STRING | X |  |  |  | Tệp đính kèm. |
| 16 | note | STRING | X |  |  |  | Ghi chú. |
| 17 | rel_p_st_code | STRING | X |  |  |  | Trạng thái bản ghi người liên quan. |
| 18 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 19 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_co_shrhlr_rel_p_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_co_shrhlr_id | scr_co_shrhlr | scr_co_shrhlr_id |
| scr_co_id | scr_co | scr_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_co_shrhlr_rprs



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_co_shrhlr_rprs_id | STRING |  | X | P |  | Khóa đại diện cho người đại diện cổ đông. |
| 2 | scr_co_shrhlr_rprs_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CD_DAI_DIEN' | Mã nguồn dữ liệu. |
| 4 | scr_co_shrhlr_id | STRING |  |  | F |  | FK đến cổ đông được đại diện. |
| 5 | scr_co_shrhlr_code | STRING |  |  |  |  | Mã cổ đông. |
| 6 | scr_co_id | STRING |  |  | F |  | FK đến công ty chứng khoán. |
| 7 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 8 | rprs_nm | STRING | X |  |  |  | Họ và tên người đại diện. |
| 9 | pos_nm | STRING | X |  |  |  | Chức vụ người đại diện. |
| 10 | shr_qty | INT | X |  |  |  | Số lượng cổ phần được đại diện. |
| 11 | shr_rto | DECIMAL(5,2) | X |  |  |  | Tỷ lệ cổ phần được đại diện (%). |
| 12 | attch_file | STRING | X |  |  |  | Tệp đính kèm. |
| 13 | note | STRING | X |  |  |  | Ghi chú. |
| 14 | rprs_st_code | STRING | X |  |  |  | Trạng thái người đại diện. |
| 15 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 16 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_co_shrhlr_rprs_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_co_shrhlr_id | scr_co_shrhlr | scr_co_shrhlr_id |
| scr_co_id | scr_co | scr_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | prac_id | STRING |  | X | P |  | Khóa đại diện cho người hành nghề chứng khoán. |
| 2 | prac_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_NGUOI_HANH_NGHE_CK' | Mã nguồn dữ liệu. |
| 4 | full_nm | STRING | X |  |  |  | Họ và tên người hành nghề. |
| 5 | brth_yr | STRING | X |  |  |  | Năm sinh |
| 6 | dob | DATE | X |  |  |  | Ngày sinh. |
| 7 | idv_gnd_code | STRING | X |  |  |  | Giới tính |
| 8 | nat_code | STRING | X |  |  |  | Quốc tịch |
| 9 | ed_lvl_code | STRING | X |  |  |  | Trình độ học vấn |
| 10 | brth_plc | STRING | X |  |  |  | Nơi sinh |
| 11 | prac_rgst_tp_code | STRING | X |  |  |  | Hình thức đăng ký người hành nghề vào hệ thống |
| 12 | practice_st_code | STRING | X |  |  |  | Trạng thái hành nghề |
| 13 | cty_of_rsdnc_geo_id | STRING | X |  | F |  | FK đến quốc gia cư trú. |
| 14 | cty_of_rsdnc_geo_code | STRING | X |  |  |  | Mã quốc gia cư trú. |
| 15 | id_refr_code | STRING | X |  |  |  | Mã định danh giấy tờ tùy thân (FK bảng identity riêng) |
| 16 | rltnp_tp_code | STRING | X |  |  |  | Loại quan hệ người hành nghề |
| 17 | ocp_nm | STRING | X |  |  |  | Nghề nghiệp |
| 18 | workplace_nm | STRING | X |  |  |  | Nơi làm việc |
| 19 | prac_note | STRING | X |  |  |  | Ghi chú |
| 20 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 21 | scr_co_id | STRING |  |  | F |  | FK đến công ty chứng khoán nơi hành nghề. |
| 22 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 23 | empe_code | STRING | X |  |  |  | Mã nhân viên nội bộ CTCK. |
| 24 | license_nbr | STRING | X |  |  |  | Số chứng chỉ hành nghề chứng khoán. |
| 25 | emp_strt_dt | DATE | X |  |  |  | Ngày bắt đầu làm việc tại CTCK. |
| 26 | emp_end_dt | DATE | X |  |  |  | Ngày nghỉ việc. |
| 27 | note | STRING | X |  |  |  | Ghi chú. |
| 28 | prac_st_code | STRING | X |  |  |  | Trạng thái người hành nghề tại CTCK. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| prac_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| cty_of_rsdnc_geo_id | geo | geo_id |
| scr_co_id | scr_co | scr_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng geo



#### Từ SCMS.DM_TINH_THANH

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | geo_id | STRING |  | X | P |  | Khóa đại diện cho khu vực địa lý. |
| 2 | geo_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.DM_TINH_THANH' | Mã nguồn dữ liệu. |
| 4 | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. |
| 5 | geo_nm | STRING |  |  |  |  | Tên tỉnh/thành phố. |
| 6 | lcs_code | STRING | X |  |  |  | Trạng thái sử dụng. |
| 7 | dsc | STRING | X |  |  |  | Mô tả. |
| 8 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 9 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 10 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 11 | geo_tp_code | STRING |  |  |  | 'PROVINCE' | Loại khu vực địa lý: PROVINCE — tỉnh/thành phố. |
| 12 | geo_bsn_code | STRING | X |  |  |  | Mã tỉnh/thành phố (mã nghiệp vụ). |
| 13 | note | STRING | X |  |  |  | Ghi chú. |
| 14 | prn_geo_id | STRING | X |  | F |  | FK tự tham chiếu đến khu vực cha trong phân cấp hành chính. |
| 15 | prn_geo_code | STRING | X |  |  |  | Mã khu vực cha — denormalized để tiện tra cứu. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| geo_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prn_geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ SCMS.DM_QUOC_TICH

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | geo_id | STRING |  | X | P |  | Khóa đại diện cho khu vực địa lý. |
| 2 | geo_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.DM_QUOC_TICH' | Mã nguồn dữ liệu. |
| 4 | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. |
| 5 | geo_nm | STRING |  |  |  |  | Tên quốc tịch/quốc gia. |
| 6 | lcs_code | STRING | X |  |  |  | Trạng thái sử dụng. |
| 7 | dsc | STRING | X |  |  |  | Mô tả. |
| 8 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 9 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 10 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 11 | geo_tp_code | STRING |  |  |  | 'COUNTRY' | Loại khu vực địa lý: COUNTRY — quốc gia/quốc tịch. |
| 12 | geo_bsn_code | STRING | X |  |  |  | Mã quốc tịch/quốc gia (mã nghiệp vụ). |
| 13 | note | STRING | X |  |  |  | Ghi chú. |
| 14 | prn_geo_id | STRING | X |  | F |  | FK tự tham chiếu đến khu vực cha trong phân cấp hành chính. |
| 15 | prn_geo_code | STRING | X |  |  |  | Mã khu vực cha — denormalized để tiện tra cứu. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| geo_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prn_geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A





### Bảng scr_co_shrhlr_tfr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_co_shrhlr_tfr_id | STRING |  | X | P |  | Khóa đại diện cho giao dịch chuyển nhượng cổ phần. |
| 2 | scr_co_shrhlr_tfr_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CD_CHUYEN_NHUONG' | Mã nguồn dữ liệu. |
| 4 | scr_co_id | STRING |  |  | F |  | FK đến công ty chứng khoán. |
| 5 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 6 | fm_shrhlr_id | STRING |  |  | F |  | FK đến cổ đông chuyển nhượng. |
| 7 | fm_shrhlr_code | STRING |  |  |  |  | Mã cổ đông chuyển nhượng. |
| 8 | to_shrhlr_id | STRING |  |  | F |  | FK đến cổ đông nhận chuyển nhượng. |
| 9 | to_shrhlr_code | STRING |  |  |  |  | Mã cổ đông nhận chuyển nhượng. |
| 10 | doc_nbr | STRING | X |  |  |  | Số văn bản chuyển nhượng. |
| 11 | doc_dt | DATE | X |  |  |  | Ngày văn bản. |
| 12 | tfr_dt | DATE | X |  |  |  | Ngày chuyển nhượng hiệu lực. |
| 13 | tfr_qty | DECIMAL(23,2) | X |  |  |  | Số lượng cổ phần chuyển nhượng. |
| 14 | tfr_rto | DECIMAL(5,2) | X |  |  |  | Tỷ lệ cổ phần chuyển nhượng (%). |
| 15 | attch_file | STRING | X |  |  |  | Tệp đính kèm. |
| 16 | note | STRING | X |  |  |  | Ghi chú. |
| 17 | tfr_st_code | STRING | X |  |  |  | Trạng thái chuyển nhượng. |
| 18 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 19 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_co_shrhlr_tfr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_co_id | scr_co | scr_co_id |
| fm_shrhlr_id | scr_co_shrhlr | scr_co_shrhlr_id |
| to_shrhlr_id | scr_co_shrhlr | scr_co_shrhlr_id |



#### Index

N/A

#### Trigger

N/A




### Bảng ip_alt_identn



#### Từ SCMS.CT_KIEM_TOAN

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến công ty kiểm toán. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty kiểm toán. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CT_KIEM_TOAN' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  | 'BUSINESS_LICENSE' | Loại giấy tờ định danh: giấy phép kinh doanh. |
| 5 | identn_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép kinh doanh. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy phép kinh doanh. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | audt_firm | audt_firm_id |



**Index:** N/A

**Trigger:** N/A


#### Từ SCMS.CTCK_NGUOI_HANH_NGHE_CK

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến người hành nghề chứng khoán. |
| 2 | ip_code | STRING |  |  |  |  | Mã người hành nghề chứng khoán. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_NGUOI_HANH_NGHE_CK' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  | 'NATIONAL_ID' | Loại định danh — giấy tờ tùy thân. |
| 5 | identn_nbr | STRING | X |  |  |  | Số giấy tờ tùy thân. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp CMND/CCCD. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp CMND/CCCD. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id |  |  |



**Index:** N/A

**Trigger:** N/A


#### Từ SCMS.CTCK_NHAN_SU_CAO_CAP

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến nhân sự cao cấp. |
| 2 | ip_code | STRING |  |  |  |  | Mã nhân sự cao cấp. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_NHAN_SU_CAO_CAP' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  | 'NATIONAL_ID' | Loại định danh — CMND/CCCD. |
| 5 | identn_nbr | STRING | X |  |  |  | Số CMND/CCCD. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp CMND/CCCD. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp CMND/CCCD. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_co_snr_psn | scr_co_snr_psn_id |



**Index:** N/A

**Trigger:** N/A


#### Từ SCMS.CTCK_CO_DONG

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến cổ đông. |
| 2 | ip_code | STRING |  |  |  |  | Mã cổ đông. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CO_DONG' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  | 'NATIONAL_ID' | Loại định danh — CMND/CCCD/đăng ký kinh doanh. |
| 5 | identn_nbr | STRING | X |  |  |  | Số CMND/CCCD hoặc đăng ký kinh doanh. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_co_shrhlr | scr_co_shrhlr_id |



**Index:** N/A

**Trigger:** N/A


#### Từ SCMS.CT_KIEM_TOAN_VIEN

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Audit Firm Practitioner. |
| 2 | ip_code | STRING |  |  |  |  | Mã kiểm toán viên. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CT_KIEM_TOAN_VIEN' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  | 'PRACTITIONER_LICENSE' | Loại giấy tờ: chứng chỉ hành nghề kiểm toán. |
| 5 | identn_nbr | STRING | X |  |  |  | Số chứng chỉ hành nghề kiểm toán. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp chứng chỉ hành nghề. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp chứng chỉ hành nghề. |
| 8 | ip_id | STRING |  |  | F |  | FK đến Audit Firm Practitioner. |
| 9 | ip_code | STRING |  |  |  |  | Mã kiểm toán viên. |
| 10 | src_stm_code | STRING |  |  |  | 'SCMS.CT_KIEM_TOAN_VIEN' | Mã nguồn dữ liệu. |
| 11 | identn_tp_code | STRING |  |  |  | 'PRACTITIONER_LICENSE' | Loại giấy tờ: chứng chỉ hành nghề kiểm toán. |
| 12 | identn_nbr | STRING | X |  |  |  | Số chứng chỉ hành nghề kiểm toán. |
| 13 | issu_dt | DATE | X |  |  |  | Ngày cấp chứng chỉ hành nghề. |
| 14 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp chứng chỉ hành nghề. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | audt_firm_prac | audt_firm_prac_id |



**Index:** N/A

**Trigger:** N/A


#### Từ SCMS.CTCK_CD_DAI_DIEN

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến người đại diện cổ đông. |
| 2 | ip_code | STRING |  |  |  |  | Mã người đại diện cổ đông. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CD_DAI_DIEN' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  | 'NATIONAL_ID' | Loại định danh — CMND/CCCD. |
| 5 | identn_nbr | STRING | X |  |  |  | Số CMND/CCCD. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_co_shrhlr_rprs | scr_co_shrhlr_rprs_id |



**Index:** N/A

**Trigger:** N/A


#### Từ SCMS.CTCK_CD_MOI_QUAN_HE

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến người có quan hệ với cổ đông. |
| 2 | ip_code | STRING |  |  |  |  | Mã người có quan hệ với cổ đông. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CD_MOI_QUAN_HE' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  | 'NATIONAL_ID' | Loại định danh — CMND/CCCD. |
| 5 | identn_nbr | STRING | X |  |  |  | Số CMND/CCCD. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_co_shrhlr_rel_p | scr_co_shrhlr_rel_p_id |



**Index:** N/A

**Trigger:** N/A


#### Từ SCMS.CTCK_THONG_TIN

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến công ty chứng khoán. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_THONG_TIN' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  | 'BUSINESS_LICENSE' | Loại định danh — giấy phép kinh doanh. |
| 5 | identn_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép kinh doanh. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy phép kinh doanh. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_co | scr_co_id |



**Index:** N/A

**Trigger:** N/A





### Bảng ip_elc_adr



#### Từ SCMS.CTCK_THONG_TIN

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến công ty chứng khoán. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_THONG_TIN' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Email. |
| 6 | ip_id | STRING |  |  | F |  | FK đến công ty chứng khoán. |
| 7 | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 8 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_THONG_TIN' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số fax. |
| 11 | ip_id | STRING |  |  | F |  | FK đến công ty chứng khoán. |
| 12 | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 13 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_THONG_TIN' | Mã nguồn dữ liệu. |
| 14 | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. |
| 15 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |
| 16 | ip_id | STRING |  |  | F |  | FK đến công ty chứng khoán. |
| 17 | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 18 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_THONG_TIN' | Mã nguồn dữ liệu. |
| 19 | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. |
| 20 | elc_adr_val | STRING | X |  |  |  | Địa chỉ website. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_co | scr_co_id |



**Index:** N/A

**Trigger:** N/A


#### Từ SCMS.CTCK_CHI_NHANH

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến đơn vị trực thuộc CTCK. |
| 2 | ip_code | STRING |  |  |  |  | Mã đơn vị trực thuộc. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CHI_NHANH' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. |
| 5 | elc_adr_val | STRING | X |  |  |  | Số fax. |
| 6 | ip_id | STRING |  |  | F |  | FK đến đơn vị trực thuộc CTCK. |
| 7 | ip_code | STRING |  |  |  |  | Mã đơn vị trực thuộc. |
| 8 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CHI_NHANH' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_co_ou | scr_co_ou_id |



**Index:** N/A

**Trigger:** N/A


#### Từ SCMS.CTCK_NHAN_SU_CAO_CAP

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến nhân sự cao cấp CTCK. |
| 2 | ip_code | STRING |  |  |  |  | Mã nhân sự cao cấp. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_NHAN_SU_CAO_CAP' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Địa chỉ email. |
| 6 | ip_id | STRING |  |  | F |  | FK đến nhân sự cao cấp CTCK. |
| 7 | ip_code | STRING |  |  |  |  | Mã nhân sự cao cấp. |
| 8 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_NHAN_SU_CAO_CAP' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  | 'EMAIL_DISCLOSURE' | Loại kênh liên lạc — email công bố thông tin. |
| 10 | elc_adr_val | STRING | X |  |  |  | Email dùng riêng cho công bố thông tin. |
| 11 | ip_id | STRING |  |  | F |  | FK đến nhân sự cao cấp CTCK. |
| 12 | ip_code | STRING |  |  |  |  | Mã nhân sự cao cấp. |
| 13 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_NHAN_SU_CAO_CAP' | Mã nguồn dữ liệu. |
| 14 | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. |
| 15 | elc_adr_val | STRING | X |  |  |  | Số fax. |
| 16 | ip_id | STRING |  |  | F |  | FK đến nhân sự cao cấp CTCK. |
| 17 | ip_code | STRING |  |  |  |  | Mã nhân sự cao cấp. |
| 18 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_NHAN_SU_CAO_CAP' | Mã nguồn dữ liệu. |
| 19 | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. |
| 20 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_co_snr_psn | scr_co_snr_psn_id |



**Index:** N/A

**Trigger:** N/A


#### Từ SCMS.CT_KIEM_TOAN

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Audit Firm. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty kiểm toán. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CT_KIEM_TOAN' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Email. |
| 6 | ip_id | STRING |  |  | F |  | FK đến Audit Firm. |
| 7 | ip_code | STRING |  |  |  |  | Mã công ty kiểm toán. |
| 8 | src_stm_code | STRING |  |  |  | 'SCMS.CT_KIEM_TOAN' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số fax. |
| 11 | ip_id | STRING |  |  | F |  | FK đến Audit Firm. |
| 12 | ip_code | STRING |  |  |  |  | Mã công ty kiểm toán. |
| 13 | src_stm_code | STRING |  |  |  | 'SCMS.CT_KIEM_TOAN' | Mã nguồn dữ liệu. |
| 14 | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. |
| 15 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |
| 16 | ip_id | STRING |  |  | F |  | FK đến Audit Firm. |
| 17 | ip_code | STRING |  |  |  |  | Mã công ty kiểm toán. |
| 18 | src_stm_code | STRING |  |  |  | 'SCMS.CT_KIEM_TOAN' | Mã nguồn dữ liệu. |
| 19 | elc_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. |
| 20 | elc_adr_val | STRING | X |  |  |  | Website. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | audt_firm | audt_firm_id |



**Index:** N/A

**Trigger:** N/A


#### Từ SCMS.CTCK_PHONG_GIAO_DICH

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến phòng giao dịch. |
| 2 | ip_code | STRING |  |  |  |  | Mã phòng giao dịch. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_PHONG_GIAO_DICH' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. |
| 5 | elc_adr_val | STRING | X |  |  |  | Số fax. |
| 6 | ip_id | STRING |  |  | F |  | FK đến phòng giao dịch. |
| 7 | ip_code | STRING |  |  |  |  | Mã phòng giao dịch. |
| 8 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_PHONG_GIAO_DICH' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_co_ou | scr_co_ou_id |



**Index:** N/A

**Trigger:** N/A


#### Từ SCMS.CTCK_VP_DAI_DIEN

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến văn phòng đại diện. |
| 2 | ip_code | STRING |  |  |  |  | Mã văn phòng đại diện. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_VP_DAI_DIEN' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. |
| 5 | elc_adr_val | STRING | X |  |  |  | Số fax. |
| 6 | ip_id | STRING |  |  | F |  | FK đến văn phòng đại diện. |
| 7 | ip_code | STRING |  |  |  |  | Mã văn phòng đại diện. |
| 8 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_VP_DAI_DIEN' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_co_ou | scr_co_ou_id |



**Index:** N/A

**Trigger:** N/A





### Bảng ip_pst_adr



#### Từ SCMS.CTCK_THONG_TIN

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến công ty chứng khoán. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_THONG_TIN' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở chính. |
| 6 | prov_id | STRING | X |  | F |  | FK đến tỉnh/thành phố trụ sở. |
| 7 | prov_code | STRING | X |  |  |  | Mã tỉnh/thành phố trụ sở. |
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
| ip_id | scr_co | scr_co_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ SCMS.CTCK_CHI_NHANH

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến đơn vị trực thuộc CTCK. |
| 2 | ip_code | STRING |  |  |  |  | Mã đơn vị trực thuộc. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CHI_NHANH' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ chi nhánh. |
| 6 | prov_id | STRING | X |  | F |  | FK đến tỉnh/thành phố trụ sở. |
| 7 | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). |
| 8 | dstc_nm | STRING | X |  |  |  | Quận/huyện. |
| 9 | ward_nm | STRING | X |  |  |  | Phường/xã. |
| 10 | geo_id | STRING | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. |
| 11 | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. |
| 12 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_co_ou | scr_co_ou_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ SCMS.CTCK_NHAN_SU_CAO_CAP

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến nhân sự cao cấp CTCK. |
| 2 | ip_code | STRING |  |  |  |  | Mã nhân sự cao cấp. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_NHAN_SU_CAO_CAP' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  | 'PERMANENT' | Loại địa chỉ — thường trú. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ thường trú. |
| 6 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_co_snr_psn | scr_co_snr_psn_id |



**Index:** N/A

**Trigger:** N/A


#### Từ SCMS.CTCK_CO_DONG

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến cổ đông CTCK. |
| 2 | ip_code | STRING |  |  |  |  | Mã cổ đông. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CO_DONG' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  | 'CURRENT' | Loại địa chỉ — nơi ở hiện tại. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ hiện tại. |
| 6 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |
| 7 | ip_id | STRING |  |  | F |  | FK đến cổ đông CTCK. |
| 8 | ip_code | STRING |  |  |  |  | Mã cổ đông. |
| 9 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_CO_DONG' | Mã nguồn dữ liệu. |
| 10 | adr_tp_code | STRING |  |  |  | 'PERMANENT' | Loại địa chỉ — hộ khẩu thường trú. |
| 11 | adr_val | STRING | X |  |  |  | Hộ khẩu thường trú. |
| 12 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_co_shrhlr | scr_co_shrhlr_id |



**Index:** N/A

**Trigger:** N/A


#### Từ SCMS.CT_KIEM_TOAN

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Audit Firm. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty kiểm toán. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CT_KIEM_TOAN' | Mã nguồn dữ liệu. |
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


#### Từ SCMS.CTCK_PHONG_GIAO_DICH

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến phòng giao dịch. |
| 2 | ip_code | STRING |  |  |  |  | Mã phòng giao dịch. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_PHONG_GIAO_DICH' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở đại lý phân phối quỹ. |
| 6 | prov_id | STRING | X |  | F |  | FK đến tỉnh/thành phố. |
| 7 | prov_code | STRING | X |  |  |  | Mã tỉnh/thành phố. |
| 8 | dstc_nm | STRING | X |  |  |  | Quận/huyện. |
| 9 | ward_nm | STRING | X |  |  |  | Phường/xã. |
| 10 | geo_id | STRING | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. |
| 11 | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. |
| 12 | adr_dtl | STRING | X |  |  |  | Địa chỉ phòng giao dịch. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_co_ou | scr_co_ou_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ SCMS.CTCK_VP_DAI_DIEN

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến văn phòng đại diện. |
| 2 | ip_code | STRING |  |  |  |  | Mã văn phòng đại diện. |
| 3 | src_stm_code | STRING |  |  |  | 'SCMS.CTCK_VP_DAI_DIEN' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở đại lý phân phối quỹ. |
| 6 | prov_id | STRING | X |  | F |  | FK đến tỉnh/thành phố. |
| 7 | prov_code | STRING | X |  |  |  | Mã tỉnh/thành phố. |
| 8 | dstc_nm | STRING | X |  |  |  | Quận/huyện. |
| 9 | ward_nm | STRING | X |  |  |  | Phường/xã. |
| 10 | geo_id | STRING | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. |
| 11 | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. |
| 12 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_co_ou | scr_co_ou_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A





### Stored Procedure/Function

N/A

### Package

N/A
