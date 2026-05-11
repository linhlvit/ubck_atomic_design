## FMS — Phần hệ quản lý giám sát công ty chứng khoán và quỹ đầu tư chứng khoán

### Các mô hình quan hệ dữ liệu

![Mô hình quan hệ dữ liệu FMS](FMS/fragments/FMS_diagram.png)

**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | dscr_ivsm_ac | Tài khoản đầu tư ủy thác — hợp đồng dịch vụ quản lý danh mục tài chính giữa nhà đầu tư ủy thác và công ty quản lý quỹ. |
| 2 | fnd_mgt_conduct_vln | Vi phạm pháp luật hoặc hành chính của công ty quản lý quỹ hoặc quỹ đầu tư. Ghi nhận loại vi phạm và trạng thái xử lý. |
| 3 | ivsm_fnd_ivsr_cptl_chg_log | Lịch sử thay đổi phần vốn góp của nhà đầu tư trong quỹ đầu tư. Ghi nhận vốn trước/sau và lý do thay đổi. |
| 4 | mbr_prd_rpt_st_log | Nhật ký thay đổi trạng thái của báo cáo định kỳ thành viên. Mỗi dòng ghi nhận một lần thay đổi trạng thái kèm nội dung tóm tắt. |
| 5 | mbr_prd_rpt | Báo cáo định kỳ do thành viên thị trường nộp lên UBCKNN theo từng kỳ báo cáo. Ghi nhận trạng thái nộp và thời hạn. |
| 6 | mbr_rtg_prd | Kỳ đánh giá xếp loại định kỳ cho các thành viên thị trường (công ty quản lý quỹ). Xác định phạm vi thời gian áp dụng tiêu chí chấm điểm. |
| 7 | rtg_criterion | Tiêu chí chấm điểm đánh giá xếp loại thành viên thị trường. Lưu tên tiêu chí và điểm tối đa/trọng số. Có cấu trúc cha/con. |
| 8 | rpt_prd | Kỳ báo cáo định kỳ (ngày/tuần/tháng/quý/bán niên/năm) mà thành viên thị trường phải nộp báo cáo lên UBCKNN. |
| 9 | rpt_impr_val | Dữ liệu giá trị từng ô chỉ tiêu trong sheet báo cáo được import vào hệ thống FMS. Grain ở mức cell-level. |
| 10 | cstd_bnk | Ngân hàng lưu ký giám sát tài sản quỹ đầu tư chứng khoán được UBCKNN chấp thuận. Chịu trách nhiệm lưu giữ và giám sát tài sản của quỹ. |
| 11 | dscr_ivsm_ivsr | Nhà đầu tư ủy thác — cá nhân hoặc tổ chức giao tài sản cho công ty quản lý quỹ quản lý theo hợp đồng ủy thác đầu tư. |
| 12 | frgn_fnd_mgt_ou | Văn phòng đại diện hoặc chi nhánh của công ty quản lý quỹ nước ngoài tại Việt Nam được UBCKNN chấp thuận hoạt động. |
| 13 | frgn_fnd_mgt_ou_stff | Nhân sự đảm nhận chức vụ tại văn phòng đại diện/chi nhánh công ty quản lý quỹ nước ngoài. Ghi nhận vai trò và tư cách pháp lý. |
| 14 | fnd_dstr_agnt | Tổ chức đại lý được ủy quyền phân phối chứng chỉ quỹ đầu tư cho nhà đầu tư. |
| 15 | fnd_dstr_agnt_ou | Chi nhánh hoặc phòng giao dịch của tổ chức đại lý phân phối quỹ đầu tư. |
| 16 | fnd_mgt_co | Công ty quản lý quỹ đầu tư chứng khoán trong nước được UBCKNN cấp phép hoạt động. Lưu thông tin pháp lý và hoạt động của công ty. |
| 17 | fnd_mgt_co_key_psn | Nhân sự chủ chốt của công ty quản lý quỹ (giám đốc/chuyên gia đầu tư/người được ủy quyền). Lưu thông tin cá nhân và chứng chỉ hành nghề. |
| 18 | fnd_mgt_co_ou | Chi nhánh hoặc văn phòng đại diện của công ty quản lý quỹ trong nước. Có địa chỉ và giấy phép hoạt động riêng. |
| 19 | ivsm_fnd | Quỹ đầu tư chứng khoán — pháp nhân độc lập do công ty quản lý quỹ thành lập và quản lý. Lưu thông tin pháp lý và vốn của quỹ. |
| 20 | ivsm_fnd_ivsr_mbr | Quan hệ thành viên của nhà đầu tư trong một quỹ đầu tư. Lưu tỷ lệ vốn góp và trạng thái tham gia. |
| 21 | ivsm_fnd_rprs_board_mbr | Thành viên ban đại diện hoặc hội đồng quản trị của quỹ đầu tư. Cá nhân đảm nhận vai trò quản trị trong cơ cấu tổ chức quỹ. |
| 22 | mbr_rtg | Kết quả xếp loại của một công ty quản lý quỹ trong một kỳ đánh giá. Ghi nhận điểm tổng hợp và hạng xếp loại. |
| 23 | fnd_mgt_co_shr_tfr | Giao dịch chuyển nhượng cổ phần của công ty quản lý quỹ. Ghi nhận bên chuyển nhượng/nhận nhượng và giá trị giao dịch. |
| 24 | ivsm_fnd_ctf_tfr | Giao dịch mua/bán chứng chỉ quỹ của nhà đầu tư thành viên. Ghi nhận số lượng và giá giao dịch theo từng quỹ. |
| 25 | ip_alt_identn | Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn. |
| 26 | ip_elc_adr | Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn. |
| 27 | ip_pst_adr | Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn. |




### Bảng dscr_ivsm_ac



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | dscr_ivsm_ac_id | STRING |  | X | P |  | Khóa đại diện cho hợp đồng ủy thác quản lý danh mục. |
| 2 | dscr_ivsm_ac_code | STRING |  |  |  |  | Mã định danh tài khoản ủy thác. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.INVESACC' | Mã nguồn dữ liệu. |
| 4 | dscr_ivsm_ivsr_id | STRING |  |  | F |  | FK đến nhà đầu tư ủy thác. |
| 5 | dscr_ivsm_ivsr_code | STRING |  |  |  |  | Mã nhà đầu tư ủy thác. |
| 6 | ac_nbr | STRING | X |  |  |  | Số tài khoản ủy thác. |
| 7 | ac_plc | STRING | X |  | F |  | Nơi lưu ký tài khoản. |
| 8 | ctr_nbr | STRING | X |  |  |  | Số hợp đồng ủy thác quản lý danh mục. |
| 9 | cmmt_cptl_amt | DECIMAL(23,2) | X |  |  |  | Quy mô vốn ủy thác cam kết (VNĐ). |
| 10 | act_cptl_amt | DECIMAL(23,2) | X |  |  |  | Quy mô vốn ủy thác thực tế (VNĐ). |
| 11 | mgt_fee_rate | DECIMAL(5,2) | X |  |  |  | Phí quản lý theo điều khoản hợp đồng (%). |
| 12 | lcs_code | STRING | X |  |  |  | Trạng thái hợp đồng ủy thác. |
| 13 | rpt_dt | DATE | X |  |  |  | Ngày báo cáo. |
| 14 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 15 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 16 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| dscr_ivsm_ac_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| dscr_ivsm_ivsr_id | dscr_ivsm_ivsr | dscr_ivsm_ivsr_id |



#### Index

N/A

#### Trigger

N/A




### Bảng fnd_mgt_conduct_vln



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | fnd_mgt_conduct_vln_id | STRING |  | X | P |  | Khóa đại diện cho hành vi vi phạm quản lý quỹ. |
| 2 | fnd_mgt_conduct_vln_code | STRING |  |  |  |  | Mã định danh vi phạm. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.VIOLT' | Mã nguồn dữ liệu. |
| 4 | fnd_mgt_co_id | STRING | X |  | F |  | FK đến công ty QLQ vi phạm (nullable). |
| 5 | fnd_mgt_co_code | STRING | X |  |  |  | Mã công ty QLQ. |
| 6 | ivsm_fnd_id | STRING | X |  | F |  | FK đến quỹ đầu tư liên quan vi phạm (nullable). |
| 7 | ivsm_fnd_code | STRING | X |  |  |  | Mã quỹ đầu tư. |
| 8 | vln_tp_code | STRING | X |  |  |  | Loại vi phạm. |
| 9 | vln_cntnt | STRING | X |  |  |  | Nội dung mô tả vi phạm. |
| 10 | vln_dt | DATE | X |  |  |  | Ngày xác định vi phạm. |
| 11 | vln_st_code | STRING | X |  |  |  | Trạng thái xử lý vi phạm. |
| 12 | note | STRING | X |  |  |  | Ghi chú bổ sung về vi phạm. |
| 13 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 14 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| fnd_mgt_conduct_vln_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| fnd_mgt_co_id | fnd_mgt_co | fnd_mgt_co_id |
| ivsm_fnd_id | ivsm_fnd | ivsm_fnd_id |



#### Index

N/A

#### Trigger

N/A




### Bảng ivsm_fnd_ivsr_cptl_chg_log



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ivsm_fnd_ivsr_cptl_chg_log_id | STRING |  | X | P |  | Khóa đại diện cho bản ghi thay đổi vốn góp NĐT. |
| 2 | ivsm_fnd_ivsr_cptl_chg_log_code | STRING |  |  |  |  | Mã định danh bản ghi thay đổi. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.MBCHANGE' | Mã nguồn dữ liệu. |
| 4 | ivsm_fnd_ivsr_mbr_id | STRING |  |  | F |  | FK đến quan hệ góp vốn của NĐT trong quỹ. |
| 5 | ivsm_fnd_ivsr_mbr_code | STRING |  |  |  |  | Mã quan hệ góp vốn. |
| 6 | old_cptl_amt | DECIMAL(23,2) | X |  |  |  | Số vốn góp trước khi thay đổi (VNĐ). |
| 7 | new_cptl_amt | DECIMAL(23,2) | X |  |  |  | Số vốn góp sau khi thay đổi (VNĐ). |
| 8 | chg_dt | DATE | X |  |  |  | Ngày thực hiện thay đổi vốn góp. |
| 9 | chg_rsn | STRING | X |  |  |  | Lý do thay đổi vốn góp. |
| 10 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 11 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 12 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ivsm_fnd_ivsr_cptl_chg_log_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ivsm_fnd_ivsr_mbr_id | ivsm_fnd_ivsr_mbr | ivsm_fnd_ivsr_mbr_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mbr_prd_rpt_st_log



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mbr_prd_rpt_hist_id | STRING |  | X | P |  | Khóa đại diện cho lịch sử nộp báo cáo định kỳ thành viên. |
| 2 | mbr_prd_rpt_hist_code | STRING |  |  |  |  | Mã định danh bản ghi lịch sử. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.RPTMBHS' | Mã nguồn dữ liệu. |
| 4 | mbr_prd_rpt_id | STRING |  |  | F |  | FK đến báo cáo định kỳ thành viên. |
| 5 | mbr_prd_rpt_code | STRING |  |  |  |  | Mã báo cáo định kỳ. |
| 6 | rpt_subm_st_code | STRING | X |  |  |  | Trạng thái nộp báo cáo tại thời điểm lịch sử. |
| 7 | changed_by_ofcr_id | STRING | X |  | F |  | FK đến nhân sự thực hiện thay đổi trạng thái. |
| 8 | changed_by_ofcr_code | STRING | X |  |  |  | Mã nhân sự thực hiện thay đổi. |
| 9 | cntnt_smy | STRING | X |  |  |  | Tóm tắt nội dung báo cáo tại thời điểm lịch sử. |
| 10 | note | STRING | X |  |  |  | Ghi chú bổ sung. |
| 11 | rpt_nm | STRING | X |  |  |  | Tên báo cáo tại thời điểm lịch sử. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mbr_prd_rpt_hist_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| mbr_prd_rpt_id | mbr_prd_rpt | mbr_prd_rpt_id |
| changed_by_ofcr_id | fnd_mgt_co_key_psn | fnd_mgt_co_key_psn_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mbr_prd_rpt



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mbr_prd_rpt_id | STRING |  | X | P |  | Khóa đại diện cho báo cáo định kỳ thành viên. |
| 2 | mbr_prd_rpt_code | STRING |  |  |  |  | Mã định danh báo cáo. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.RPTMEMBER' | Mã nguồn dữ liệu. |
| 4 | fnd_mgt_co_id | STRING | X |  | F |  | FK đến công ty QLQ nộp báo cáo (nullable). |
| 5 | fnd_mgt_co_code | STRING | X |  |  |  | Mã công ty QLQ. |
| 6 | ivsm_fnd_id | STRING | X |  | F |  | FK đến quỹ đầu tư nộp báo cáo (nullable). |
| 7 | ivsm_fnd_code | STRING | X |  |  |  | Mã quỹ đầu tư. |
| 8 | cstd_bnk_id | STRING | X |  | F |  | FK đến ngân hàng LKGS nộp báo cáo (nullable). |
| 9 | cstd_bnk_code | STRING | X |  |  |  | Mã ngân hàng LKGS. |
| 10 | frgn_fnd_mgt_ou_id | STRING | X |  | F |  | FK đến VPĐD/CN QLQ NN nộp báo cáo (nullable). |
| 11 | frgn_fnd_mgt_ou_code | STRING | X |  |  |  | Mã VPĐD/CN QLQ NN. |
| 12 | rpt_tpl_id | STRING | X |  | F |  | FK đến biểu mẫu báo cáo. |
| 13 | rpt_tpl_code | STRING | X |  |  |  | Mã biểu mẫu báo cáo. |
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
| 25 | subm_dt | DATE | X |  |  |  | Ngày nộp báo cáo thực tế. |
| 26 | rpt_subm_st_code | STRING | X |  |  |  | Trạng thái nộp báo cáo. |
| 27 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 28 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
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




### Bảng mbr_rtg_prd



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mbr_rtg_prd_id | STRING |  | X | P |  | Khóa đại diện cho kỳ đánh giá xếp loại. |
| 2 | mbr_rtg_prd_code | STRING |  |  |  |  | Mã định danh kỳ đánh giá. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.RATINGPD' | Mã nguồn dữ liệu. |
| 4 | mbr_rtg_prd_nm | STRING |  |  |  |  | Tên kỳ đánh giá xếp loại. |
| 5 | rtg_prd_strt_dt | DATE | X |  |  |  | Ngày bắt đầu kỳ đánh giá. |
| 6 | rtg_prd_end_dt | DATE | X |  |  |  | Ngày kết thúc kỳ đánh giá. |
| 7 | is_actv_f | BOOLEAN | X |  |  |  | Kỳ đánh giá đang hoạt động. |
| 8 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 9 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mbr_rtg_prd_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng rtg_criterion



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rtg_criterion_id | STRING |  | X | P |  | Khóa đại diện cho nhân tố chấm điểm đánh giá. |
| 2 | rtg_criterion_code | STRING |  |  |  |  | Mã định danh nhân tố. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.RNKFACTOR' | Mã nguồn dữ liệu. |
| 4 | rtg_criterion_nm | STRING |  |  |  |  | Tên nhân tố chấm điểm. |
| 5 | prn_rtg_criterion_id | STRING | X |  | F |  | FK tự thân — nhân tố cha. |
| 6 | prn_rtg_criterion_code | STRING | X |  |  |  | Mã nhân tố cha. |
| 7 | max_scor | DECIMAL(5,2) | X |  |  |  | Điểm tối đa của nhân tố. |
| 8 | wght | DECIMAL(5,2) | X |  |  |  | Trọng số của nhân tố trong tổng điểm. |
| 9 | is_actv_f | BOOLEAN | X |  |  |  | Nhân tố đang được áp dụng. |
| 10 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 11 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rtg_criterion_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prn_rtg_criterion_id | rtg_criterion | rtg_criterion_id |



#### Index

N/A

#### Trigger

N/A




### Bảng rpt_prd



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rpt_prd_id | STRING |  | X | P |  | Khóa đại diện cho kỳ báo cáo. |
| 2 | rpt_prd_code | STRING |  |  |  |  | Mã định danh kỳ báo cáo. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.RPTPERIOD' | Mã nguồn dữ liệu. |
| 4 | rpt_prd_nm | STRING |  |  |  |  | Tên kỳ báo cáo. |
| 5 | rpt_prd_tp_code | STRING | X |  |  |  | Kiểu kỳ báo cáo (tháng/quý/năm...). |
| 6 | is_actv_f | BOOLEAN | X |  |  |  | Kỳ báo cáo đang hoạt động. |
| 7 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 8 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 9 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 10 | self-set_prd_id | STRING | X |  | F |  | FK đến kỳ báo cáo do cán bộ UB tự thiết lập (SELFSETPD). Nullable. |
| 11 | self-set_prd_code | STRING | X |  |  |  | Mã kỳ báo cáo tự thiết lập. |
| 12 | rpt_tpl_id | STRING |  |  | F |  | FK đến biểu mẫu báo cáo áp dụng cho kỳ này. |
| 13 | rpt_tpl_code | STRING |  |  |  |  | Mã biểu mẫu báo cáo. |
| 14 | subm_ddln_dt | DATE | X |  |  |  | Thời hạn gửi báo cáo muộn nhất (áp dụng cho kỳ ngày/tuần). |
| 15 | subm_ddln_wk | INT | X |  |  |  | Thời hạn gửi báo cáo muộn nhất (tuần). |
| 16 | repeat_itrv | INT | X |  |  |  | Lặp lại sau bao nhiêu đơn vị kỳ. |
| 17 | counting_strt_dt | DATE | X |  |  |  | Ngày bắt đầu tính hạn nộp báo cáo. |
| 18 | is_wrk_day_ind | STRING | X |  |  |  | Đơn vị tính hạn nộp: 0: Ngày lịch 1: Ngày làm việc. |
| 19 | submit_wi_dys | INT | X |  |  |  | Số ngày/ngày làm việc được phép gửi báo cáo. |
| 20 | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. |
| 21 | dsc | STRING | X |  |  |  | Ghi chú. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rpt_prd_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rpt_tpl_id | rpt_tpl | rpt_tpl_id |



#### Index

N/A

#### Trigger

N/A




### Bảng rpt_impr_val



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mbr_rpt_val_id | STRING |  | X | P |  | Khóa đại diện cho giá trị chỉ tiêu trong báo cáo thành viên. |
| 2 | mbr_rpt_val_code | STRING |  |  |  |  | Mã định danh giá trị chỉ tiêu. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.RPTVALUES' | Mã nguồn dữ liệu. |
| 4 | mbr_prd_rpt_id | STRING |  |  | F |  | FK đến báo cáo định kỳ thành viên. |
| 5 | mbr_prd_rpt_code | STRING |  |  |  |  | Mã báo cáo định kỳ. |
| 6 | fnd_mgt_co_id | STRING | X |  | F |  | FK đến công ty QLQ nộp báo cáo (nullable). |
| 7 | fnd_mgt_co_code | STRING | X |  |  |  | Mã công ty QLQ. |
| 8 | ivsm_fnd_id | STRING | X |  | F |  | FK đến quỹ đầu tư nộp báo cáo (nullable). |
| 9 | ivsm_fnd_code | STRING | X |  |  |  | Mã quỹ đầu tư. |
| 10 | cstd_bnk_id | STRING | X |  | F |  | FK đến ngân hàng LKGS nộp báo cáo (nullable). |
| 11 | cstd_bnk_code | STRING | X |  |  |  | Mã ngân hàng LKGS. |
| 12 | frgn_fnd_mgt_ou_id | STRING | X |  | F |  | FK đến VPĐD/CN QLQ NN nộp báo cáo (nullable). |
| 13 | frgn_fnd_mgt_ou_code | STRING | X |  |  |  | Mã VPĐD/CN QLQ NN. |
| 14 | rpt_prd_id | STRING | X |  | F |  | FK đến kỳ báo cáo. |
| 15 | rpt_prd_code | STRING | X |  |  |  | Mã kỳ báo cáo. |
| 16 | rpt_shet_id | STRING | X |  |  |  | Mã trang/sheet trong biểu mẫu báo cáo. |
| 17 | rpt_trgt_id | STRING | X |  |  |  | Mã chỉ tiêu trong sheet báo cáo. |
| 18 | rpt_id | STRING | X |  |  |  | Mã biểu mẫu báo cáo. |
| 19 | val | STRING | X |  |  |  | Giá trị chỉ tiêu (text để chứa mọi kiểu dữ liệu). |
| 20 | acm_val | STRING | X |  |  |  | Giá trị lũy kế của chỉ tiêu. |
| 21 | fmt_data_tp_code | STRING | X |  |  |  | Kiểu dữ liệu định dạng của chỉ tiêu. |
| 22 | is_dynamic_ind | STRING | X |  |  |  | Cờ đánh dấu chỉ tiêu động (người dùng tự thêm). |
| 23 | rpt_prd_tp_code | STRING | X |  |  |  | Kiểu kỳ báo cáo (tháng/quý/năm). |
| 24 | val_tp_code | STRING | X |  |  |  | Loại giá trị trong báo cáo. |
| 25 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 26 | mod_by | STRING | X |  |  |  | Người cập nhật bản ghi lần cuối. |
| 27 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 28 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mbr_rpt_val_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| mbr_prd_rpt_id | mbr_prd_rpt | mbr_prd_rpt_id |
| fnd_mgt_co_id | fnd_mgt_co | fnd_mgt_co_id |
| ivsm_fnd_id | ivsm_fnd | ivsm_fnd_id |
| cstd_bnk_id | cstd_bnk | cstd_bnk_id |
| frgn_fnd_mgt_ou_id | frgn_fnd_mgt_ou | frgn_fnd_mgt_ou_id |
| rpt_prd_id | rpt_prd | rpt_prd_id |



#### Index

N/A

#### Trigger

N/A




### Bảng cstd_bnk



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | cstd_bnk_id | STRING |  | X | P |  | Khóa đại diện cho ngân hàng lưu ký giám sát. |
| 2 | cstd_bnk_code | STRING |  |  |  |  | Mã định danh ngân hàng LKGS. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.BANKMONI' | Mã nguồn dữ liệu. |
| 4 | cstd_bnk_nm | STRING |  |  |  |  | Tên đầy đủ ngân hàng lưu ký giám sát. |
| 5 | cstd_bnk_shrt_nm | STRING | X |  |  |  | Tên viết tắt ngân hàng LKGS. |
| 6 | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động. |
| 7 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 8 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 9 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 10 | cty_of_rgst_id | STRING | X |  | F |  | FK đến quốc gia đăng ký của ngân hàng LKGS. |
| 11 | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. |
| 12 | cstd_bnk_en_nm | STRING | X |  |  |  | Tên tiếng Anh. |
| 13 | charter_cptl_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ (VNĐ). Thông tin bổ sung của FIMS không có trong FMS.BANKMONI. |
| 14 | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. |
| 15 | director_nm | STRING | X |  |  |  | Tên Tổng giám đốc (denormalized). |
| 16 | depst_ctf_nbr | STRING | X |  |  |  | Chứng nhận lưu ký — thông tin bổ sung của FIMS không có trong FMS.BANKMONI. |
| 17 | dsc | STRING | X |  |  |  | Ghi chú. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| cstd_bnk_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| cty_of_rgst_id | geo | geo_id |



#### Index

N/A

#### Trigger

N/A




### Bảng dscr_ivsm_ivsr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | dscr_ivsm_ivsr_id | STRING |  | X | P |  | Khóa đại diện cho nhà đầu tư ủy thác. |
| 2 | dscr_ivsm_ivsr_code | STRING |  |  |  |  | Mã định danh nhà đầu tư ủy thác. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.INVES' | Mã nguồn dữ liệu. |
| 4 | ivsr_nm | STRING |  |  |  |  | Tên nhà đầu tư ủy thác (cá nhân hoặc tổ chức). |
| 5 | dorf_ind | STRING | X |  |  |  | Loại hình trong/ngoài nước. 1=Trong nước; 0=Nước ngoài. |
| 6 | nat_code | STRING | X |  |  |  | Quốc tịch nhà đầu tư. |
| 7 | stockholder_tp_code | STRING | X |  |  |  | Loại hình nhà đầu tư/cổ đông. |
| 8 | rltnp_tp_code | STRING | X |  |  |  | Mối quan hệ cổ đông với tổ chức liên quan. |
| 9 | fnd_mgt_co_id | STRING | X |  | F |  | FK đến công ty QLQ đang nhận ủy thác. |
| 10 | fnd_mgt_co_code | STRING | X |  |  |  | Mã công ty QLQ đang nhận ủy thác. |
| 11 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 12 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 13 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| dscr_ivsm_ivsr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| fnd_mgt_co_id | fnd_mgt_co | fnd_mgt_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng frgn_fnd_mgt_ou



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | frgn_fnd_mgt_ou_id | STRING |  | X | P |  | Khóa đại diện cho VPĐD/CN công ty QLQ nước ngoài tại VN. |
| 2 | frgn_fnd_mgt_ou_code | STRING |  |  |  |  | Mã định danh VPĐD/CN QLQ NN. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.FORBRCH' | Mã nguồn dữ liệu. |
| 4 | frgn_fnd_mgt_ou_nm | STRING |  |  |  |  | Tên VPĐD/CN công ty QLQ nước ngoài tại VN. |
| 5 | frgn_fnd_mgt_ou_en_nm | STRING | X |  |  |  | Tên tiếng Anh VPĐD/CN. |
| 6 | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động. |
| 7 | end_dt | DATE | X |  |  |  | Ngày chấm dứt hoạt động. |
| 8 | chg_license_nbr | STRING | X |  |  |  | Số giấy phép điều chỉnh gần nhất. |
| 9 | chg_license_dt | DATE | X |  |  |  | Ngày cấp giấy phép điều chỉnh. |
| 10 | chg_note | STRING | X |  |  |  | Nội dung thay đổi theo giấy phép điều chỉnh. |
| 11 | bsn_tp_codes | ARRAY<STRING> | X |  |  |  | Danh sách mã ngành nghề kinh doanh. |
| 12 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 13 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 14 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| frgn_fnd_mgt_ou_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng frgn_fnd_mgt_ou_stff



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | frgn_fnd_mgt_ou_stff_id | STRING |  | X | P |  | Khóa đại diện cho nhân sự tại VPĐD/CN QLQ nước ngoài. |
| 2 | frgn_fnd_mgt_ou_stff_code | STRING |  |  |  |  | Mã định danh nhân sự VPĐD/CN QLQ NN. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.STFFGBRCH' | Mã nguồn dữ liệu. |
| 4 | frgn_fnd_mgt_ou_id | STRING |  |  | F |  | FK đến VPĐD/CN QLQ nước ngoài. |
| 5 | frgn_fnd_mgt_ou_code | STRING |  |  |  |  | Mã VPĐD/CN QLQ nước ngoài. |
| 6 | fnd_mgt_co_key_psn_id | STRING |  |  | F |  | FK đến nhân sự giữ vai trò tại VPĐD/CN QLQ NN. |
| 7 | fnd_mgt_co_key_psn_code | STRING |  |  |  |  | Mã nhân sự. |
| 8 | ou_tp_code | STRING | X |  |  |  | Loại đơn vị: VPĐD hoặc CN NN. |
| 9 | is_lgl_rprs_ind | STRING | X |  |  |  | Cờ đánh dấu người đại diện pháp luật tại VPĐD/CN. |
| 10 | is_dscl_rprs_ind | STRING | X |  |  |  | Cờ đánh dấu đại diện công bố thông tin. |
| 11 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 12 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| frgn_fnd_mgt_ou_stff_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| frgn_fnd_mgt_ou_id | frgn_fnd_mgt_ou | frgn_fnd_mgt_ou_id |
| fnd_mgt_co_key_psn_id | fnd_mgt_co_key_psn | fnd_mgt_co_key_psn_id |



#### Index

N/A

#### Trigger

N/A




### Bảng fnd_dstr_agnt



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | fnd_dstr_agnt_id | STRING |  | X | P |  | Khóa đại diện cho tổ chức đại lý phân phối quỹ. |
| 2 | fnd_dstr_agnt_code | STRING |  |  |  |  | Mã định danh đại lý phân phối quỹ. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.AGENCIES' | Mã nguồn dữ liệu. |
| 4 | fnd_dstr_agnt_nm | STRING |  |  |  |  | Tên đầy đủ đại lý phân phối quỹ. |
| 5 | fnd_dstr_agnt_shrt_nm | STRING | X |  |  |  | Tên viết tắt đại lý. |
| 6 | agnc_tp_code | STRING | X |  |  |  | Loại đại lý phân phối quỹ. |
| 7 | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động. |
| 8 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 9 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 10 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| fnd_dstr_agnt_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng fnd_dstr_agnt_ou



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | fnd_dstr_agnt_ou_id | STRING |  | X | P |  | Khóa đại diện cho CN/PGD của đại lý phân phối quỹ. |
| 2 | fnd_dstr_agnt_ou_code | STRING |  |  |  |  | Mã định danh CN/PGD đại lý. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.AGENCIESBRA' | Mã nguồn dữ liệu. |
| 4 | fnd_dstr_agnt_id | STRING |  |  | F |  | FK đến đại lý phân phối quỹ. |
| 5 | fnd_dstr_agnt_code | STRING |  |  |  |  | Mã đại lý phân phối quỹ. |
| 6 | fnd_dstr_agnt_ou_nm | STRING |  |  |  |  | Tên CN/PGD đại lý phân phối quỹ. |
| 7 | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động. |
| 8 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 9 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| fnd_dstr_agnt_ou_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| fnd_dstr_agnt_id | fnd_dstr_agnt | fnd_dstr_agnt_id |



#### Index

N/A

#### Trigger

N/A




### Bảng fnd_mgt_co



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | fnd_mgt_co_id | STRING |  | X | P |  | Khóa đại diện cho công ty quản lý quỹ trong nước. |
| 2 | fnd_mgt_co_code | STRING |  |  |  |  | Mã định danh công ty QLQ. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.SECURITIES' | Mã nguồn dữ liệu. |
| 4 | fnd_mgt_co_nm | STRING |  |  |  |  | Tên đầy đủ công ty QLQ trong nước. |
| 5 | fnd_mgt_co_shrt_nm | STRING | X |  |  |  | Tên viết tắt công ty QLQ. |
| 6 | fnd_mgt_co_en_nm | STRING | X |  |  |  | Tên tiếng Anh công ty QLQ. |
| 7 | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động của công ty QLQ. |
| 8 | charter_cptl_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ công ty QLQ (VNĐ). |
| 9 | dorf_ind | STRING | X |  |  |  | Loại hình trong/ngoài nước. 1=Trong nước; 0=Nước ngoài. |
| 10 | license_dcsn_nbr | STRING | X |  |  |  | Số quyết định/giấy phép thành lập. |
| 11 | license_dcsn_dt | DATE | X |  |  |  | Ngày cấp phép. |
| 12 | actv_dt | DATE | X |  |  |  | Ngày bắt đầu hoạt động. |
| 13 | stop_dt | DATE | X |  |  |  | Ngày ngừng hoạt động. |
| 14 | bsn_tp_codes | ARRAY<STRING> | X |  |  |  | Danh sách mã ngành nghề kinh doanh. |
| 15 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 16 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 17 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 18 | cty_of_rgst_id | STRING | X |  | F |  | FK đến quốc gia đăng ký của công ty QLQ. |
| 19 | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. |
| 20 | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. |
| 21 | director_nm | STRING | X |  |  |  | Tên Tổng giám đốc (denormalized). |
| 22 | depst_ctf_nbr | STRING | X |  |  |  | Chứng nhận lưu ký — thông tin bổ sung của FIMS không có trong FMS.SECURITIES. |
| 23 | co_tp_codes | ARRAY<STRING> | X |  |  |  | Danh sách mã loại hình doanh nghiệp. Từ bảng junction FUNDCOMTYPE. |
| 24 | dsc | STRING | X |  |  |  | Ghi chú. |
| 25 | co_tp_code | STRING | X |  |  |  | Loại hình công ty. |
| 26 | fnd_tp_code | STRING | X |  |  |  | Loại quỹ (áp dụng cho quỹ đầu tư). |
| 27 | bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. |
| 28 | webst | STRING | X |  |  |  | Website chính thức. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| fnd_mgt_co_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| cty_of_rgst_id | geo | geo_id |



#### Index

N/A

#### Trigger

N/A




### Bảng fnd_mgt_co_key_psn



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | fnd_mgt_co_key_psn_id | STRING |  | X | P |  | Khóa đại diện cho nhân sự chủ chốt công ty QLQ. |
| 2 | fnd_mgt_co_key_psn_code | STRING |  |  |  |  | Mã định danh nhân sự. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.TLProfiles' | Mã nguồn dữ liệu. |
| 4 | fnd_mgt_co_id | STRING |  |  | F |  | FK đến công ty QLQ. |
| 5 | fnd_mgt_co_code | STRING |  |  |  |  | Mã công ty QLQ. |
| 6 | full_nm | STRING |  |  |  |  | Họ và tên đầy đủ nhân sự. |
| 7 | brth_dt | DATE | X |  |  |  | Ngày sinh. |
| 8 | nat_code | STRING | X |  |  |  | Quốc tịch. |
| 9 | job_tp_code | STRING | X |  |  |  | Loại chức vụ. |
| 10 | is_lgl_rprs_ind | STRING | X |  |  |  | Cờ đánh dấu người đại diện pháp luật. |
| 11 | is_dscl_rprs_ind | STRING | X |  |  |  | Cờ đánh dấu đại diện công bố thông tin (CBTT). |
| 12 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 13 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 14 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| fnd_mgt_co_key_psn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| fnd_mgt_co_id | fnd_mgt_co | fnd_mgt_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng fnd_mgt_co_ou



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | fnd_mgt_co_ou_id | STRING |  | X | P |  | Khóa đại diện cho CN/VPĐD công ty QLQ trong nước. |
| 2 | fnd_mgt_co_ou_code | STRING |  |  |  |  | Mã định danh CN/VPĐD. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.BRANCHES' | Mã nguồn dữ liệu. |
| 4 | fnd_mgt_co_id | STRING |  |  | F |  | FK đến công ty QLQ trong nước. |
| 5 | fnd_mgt_co_code | STRING |  |  |  |  | Mã công ty QLQ trong nước. |
| 6 | fnd_mgt_co_ou_nm | STRING |  |  |  |  | Tên CN/VPĐD công ty QLQ. |
| 7 | ou_tp_code | STRING | X |  |  |  | Loại đơn vị: CN hoặc VPĐD. |
| 8 | prn_ou_id | STRING | X |  | F |  | FK tự thân — CN/VPĐD cha. |
| 9 | prn_ou_code | STRING | X |  |  |  | Mã CN/VPĐD cha. |
| 10 | lgl_rprs_id | STRING | X |  | F |  | FK đến người đại diện pháp luật của CN/VPĐD. |
| 11 | lgl_rprs_code | STRING | X |  |  |  | Mã người đại diện pháp luật. |
| 12 | lgl_rprs_nm | STRING | X |  |  |  | Tên người đại diện pháp luật (denormalized). |
| 13 | license_dcsn_nbr | STRING | X |  |  |  | Số quyết định thành lập CN/VPĐD. |
| 14 | license_dcsn_dt | DATE | X |  |  |  | Ngày cấp quyết định thành lập CN/VPĐD. |
| 15 | vchr_nbr | STRING | X |  |  |  | Số chứng từ liên quan. |
| 16 | vchr_dt | DATE | X |  |  |  | Ngày chứng từ. |
| 17 | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động. |
| 18 | stop_dt | DATE | X |  |  |  | Ngày ngừng hoạt động. |
| 19 | chg_dsc | STRING | X |  |  |  | Mô tả nội dung thay đổi. |
| 20 | dsc | STRING | X |  |  |  | Mô tả bổ sung. |
| 21 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 22 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 23 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 24 | cty_of_rgst_id | STRING | X |  | F |  | FK đến quốc gia đăng ký của công ty mẹ. |
| 25 | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. |
| 26 | en_nm | STRING | X |  |  |  | Tên tiếng Anh. |
| 27 | abr | STRING | X |  |  |  | Tên viết tắt. |
| 28 | tax_code | STRING | X |  |  |  | Mã số thuế. |
| 29 | charter_cptl_amt | DECIMAL(23,2) | X |  |  |  | Vốn được cấp (VNĐ). |
| 30 | strt_dt | DATE | X |  |  |  | Hoạt động từ ngày. |
| 31 | end_dt | DATE | X |  |  |  | Hoạt động đến ngày. |
| 32 | prn_co_nm | STRING | X |  |  |  | Tên công ty mẹ (denormalized — nguồn ETL resolve FK). |
| 33 | prn_co_rgst_nbr | STRING | X |  |  |  | Số ĐKKD công ty mẹ (denormalized). |
| 34 | prn_co_adr | STRING | X |  |  |  | Địa chỉ công ty mẹ (denormalized). |
| 35 | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. |
| 36 | bsn_tp_codes | ARRAY<STRING> | X |  |  |  | Danh sách mã nghiệp vụ kinh doanh. Từ bảng junction BRANCHSBUSINES. |


#### Constraint

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



#### Index

N/A

#### Trigger

N/A




### Bảng ivsm_fnd



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ivsm_fnd_id | STRING |  | X | P |  | Khóa đại diện cho quỹ đầu tư chứng khoán. |
| 2 | ivsm_fnd_code | STRING |  |  |  |  | Mã định danh quỹ đầu tư. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.FUNDS' | Mã nguồn dữ liệu. |
| 4 | ivsm_fnd_nm | STRING |  |  |  |  | Tên đầy đủ quỹ đầu tư. |
| 5 | ivsm_fnd_shrt_nm | STRING | X |  |  |  | Tên viết tắt quỹ đầu tư. |
| 6 | ivsm_fnd_en_nm | STRING | X |  |  |  | Tên tiếng Anh quỹ đầu tư. |
| 7 | fnd_mgt_co_id | STRING |  |  | F |  | FK đến công ty QLQ quản lý quỹ. |
| 8 | fnd_mgt_co_code | STRING |  |  |  |  | Mã công ty QLQ quản lý quỹ. |
| 9 | fnd_cptl_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ quỹ đầu tư (VNĐ). |
| 10 | fnd_tp_code | STRING | X |  |  |  | Loại hình quỹ đầu tư. |
| 11 | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động quỹ. |
| 12 | license_dcsn_dt | DATE | X |  |  |  | Ngày cấp phép thành lập quỹ. |
| 13 | actv_dt | DATE | X |  |  |  | Ngày bắt đầu hoạt động. |
| 14 | stop_dt | DATE | X |  |  |  | Ngày ngừng hoạt động. |
| 15 | dstr_agnt_ids | ARRAY<STRUCT<...>> | X |  |  |  | Danh sách đại lý phân phối quỹ (SK + mã nghiệp vụ). |
| 16 | cstd_bnk_ids | ARRAY<STRUCT<...>> | X |  |  |  | Danh sách ngân hàng lưu ký giám sát (SK + mã nghiệp vụ). |
| 17 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 18 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 19 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ivsm_fnd_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| fnd_mgt_co_id | fnd_mgt_co | fnd_mgt_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng ivsm_fnd_ivsr_mbr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ivsm_fnd_ivsr_mbr_id | STRING |  | X | P |  | Khóa đại diện cho quan hệ góp vốn của NĐT vào quỹ. |
| 2 | ivsm_fnd_ivsr_mbr_code | STRING |  |  |  |  | Mã định danh quan hệ góp vốn. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.MBFUND' | Mã nguồn dữ liệu. |
| 4 | ivsm_fnd_id | STRING |  |  | F |  | FK đến quỹ đầu tư. |
| 5 | ivsm_fnd_code | STRING |  |  |  |  | Mã quỹ đầu tư. |
| 6 | dscr_ivsm_ivsr_id | STRING |  |  | F |  | FK đến nhà đầu tư. |
| 7 | dscr_ivsm_ivsr_code | STRING |  |  |  |  | Mã nhà đầu tư. |
| 8 | cptl_amt | DECIMAL(23,2) | X |  |  |  | Số vốn góp của NĐT vào quỹ (VNĐ). |
| 9 | own_rto | DECIMAL(5,2) | X |  |  |  | Tỷ lệ sở hữu của NĐT trong quỹ (%). |
| 10 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 11 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ivsm_fnd_ivsr_mbr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ivsm_fnd_id | ivsm_fnd | ivsm_fnd_id |
| dscr_ivsm_ivsr_id | dscr_ivsm_ivsr | dscr_ivsm_ivsr_id |



#### Index

N/A

#### Trigger

N/A




### Bảng ivsm_fnd_rprs_board_mbr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ivsm_fnd_rprs_board_mbr_id | STRING |  | X | P |  | Khóa đại diện cho thành viên ban đại diện quỹ. |
| 2 | ivsm_fnd_rprs_board_mbr_code | STRING |  |  |  |  | Mã định danh thành viên ban đại diện. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.REPRESENT' | Mã nguồn dữ liệu. |
| 4 | ivsm_fnd_id | STRING |  |  | F |  | FK đến quỹ đầu tư. |
| 5 | ivsm_fnd_code | STRING |  |  |  |  | Mã quỹ đầu tư. |
| 6 | fnd_mgt_co_key_psn_id | STRING |  |  | F |  | FK đến nhân sự giữ vai trò thành viên ban đại diện. |
| 7 | fnd_mgt_co_key_psn_code | STRING |  |  |  |  | Mã nhân sự. |
| 8 | is_chair_ind | STRING | X |  |  |  | Cờ đánh dấu trưởng ban đại diện. |
| 9 | practice_st_code | STRING | X |  |  |  | Trạng thái tham gia ban đại diện. |
| 10 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 11 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ivsm_fnd_rprs_board_mbr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ivsm_fnd_id | ivsm_fnd | ivsm_fnd_id |
| fnd_mgt_co_key_psn_id | fnd_mgt_co_key_psn | fnd_mgt_co_key_psn_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mbr_rtg



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mbr_rtg_id | STRING |  | X | P |  | Khóa đại diện cho kết quả xếp hạng thành viên. |
| 2 | mbr_rtg_code | STRING |  |  |  |  | Mã định danh kết quả xếp hạng. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.RANK' | Mã nguồn dữ liệu. |
| 4 | fnd_mgt_co_id | STRING |  |  | F |  | FK đến công ty QLQ được xếp hạng. |
| 5 | fnd_mgt_co_code | STRING |  |  |  |  | Mã công ty QLQ được xếp hạng. |
| 6 | mbr_rtg_prd_id | STRING |  |  | F |  | FK đến kỳ đánh giá xếp loại. |
| 7 | mbr_rtg_prd_code | STRING |  |  |  |  | Mã kỳ đánh giá xếp loại. |
| 8 | tot_scor | DECIMAL(5,2) | X |  |  |  | Tổng điểm đánh giá. |
| 9 | rank_val | INT | X |  |  |  | Giá trị xếp hạng (thứ tự). |
| 10 | rank_clss_code | STRING | X |  |  |  | Xếp loại kết quả đánh giá. |
| 11 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 12 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mbr_rtg_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| fnd_mgt_co_id | fnd_mgt_co | fnd_mgt_co_id |
| mbr_rtg_prd_id | mbr_rtg_prd | mbr_rtg_prd_id |



#### Index

N/A

#### Trigger

N/A




### Bảng fnd_mgt_co_shr_tfr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | fnd_mgt_co_shr_tfr_id | STRING |  | X | P |  | Khóa đại diện cho giao dịch chuyển nhượng cổ phần QLQ. |
| 2 | fnd_mgt_co_shr_tfr_code | STRING |  |  |  |  | Mã định danh giao dịch. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.TRSFERINDER' | Mã nguồn dữ liệu. |
| 4 | fnd_mgt_co_id | STRING |  |  | F |  | FK đến công ty QLQ có cổ phần được chuyển nhượng. |
| 5 | fnd_mgt_co_code | STRING |  |  |  |  | Mã công ty QLQ. |
| 6 | tfr_dt | DATE |  |  |  |  | Ngày thực hiện giao dịch chuyển nhượng. |
| 7 | shr_qty | INT | X |  |  |  | Số lượng cổ phần chuyển nhượng. |
| 8 | tfr_prc | DECIMAL(23,2) | X |  |  |  | Giá giao dịch chuyển nhượng (VNĐ/cổ phần). |
| 9 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 10 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| fnd_mgt_co_shr_tfr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| fnd_mgt_co_id | fnd_mgt_co | fnd_mgt_co_id |



#### Index

N/A

#### Trigger

N/A




### Bảng ivsm_fnd_ctf_tfr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ivsm_fnd_ivsr_cptl_tfr_id | STRING |  | X | P |  | Khóa đại diện cho giao dịch chuyển nhượng phần vốn góp quỹ. |
| 2 | ivsm_fnd_ivsr_cptl_tfr_code | STRING |  |  |  |  | Mã định danh giao dịch. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.TRANSFERMBF' | Mã nguồn dữ liệu. |
| 4 | ivsm_fnd_id | STRING |  |  | F |  | FK đến quỹ đầu tư có phần vốn chuyển nhượng. |
| 5 | ivsm_fnd_code | STRING |  |  |  |  | Mã quỹ đầu tư. |
| 6 | ivsm_fnd_ivsr_mbr_id | STRING |  |  | F |  | FK đến quan hệ góp vốn của NĐT trong quỹ. |
| 7 | ivsm_fnd_ivsr_mbr_code | STRING |  |  |  |  | Mã quan hệ góp vốn. |
| 8 | tfr_dt | DATE | X |  |  |  | Ngày thực hiện chuyển nhượng phần vốn. |
| 9 | tfr_qty | DECIMAL(23,2) | X |  |  |  | Số lượng phần vốn chuyển nhượng. |
| 10 | tfr_prc | DECIMAL(23,2) | X |  |  |  | Giá chuyển nhượng (VNĐ/phần vốn). |
| 11 | tfr_tp_code | STRING | X |  |  |  | Loại giao dịch chuyển nhượng. |
| 12 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 13 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ivsm_fnd_ivsr_cptl_tfr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ivsm_fnd_id | ivsm_fnd | ivsm_fnd_id |
| ivsm_fnd_ivsr_mbr_id | ivsm_fnd_ivsr_mbr | ivsm_fnd_ivsr_mbr_id |



#### Index

N/A

#### Trigger

N/A




### Bảng ip_alt_identn



#### Từ FMS.SECURITIES

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Fund Management Company. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty QLQ. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.SECURITIES' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ — giấy phép thành lập. |
| 5 | identn_nbr | STRING | X |  |  |  | Số quyết định/giấy phép thành lập. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp phép thành lập. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Cơ quan cấp giấy phép thành lập |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | fnd_mgt_co | fnd_mgt_co_id |



**Index:** N/A

**Trigger:** N/A


#### Từ FMS.FORBRCH

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Foreign Fund Management Organization Unit. |
| 2 | ip_code | STRING |  |  |  |  | Mã VPĐD/CN QLQ NN. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.FORBRCH' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ — giấy phép điều chỉnh. |
| 5 | identn_nbr | STRING | X |  |  |  | Số giấy phép điều chỉnh gần nhất. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép điều chỉnh. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Cơ quan cấp giấy phép thành lập |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | frgn_fnd_mgt_ou | frgn_fnd_mgt_ou_id |



**Index:** N/A

**Trigger:** N/A


#### Từ FMS.INVES

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Discretionary Investment Investor. |
| 2 | ip_code | STRING |  |  |  |  | Mã nhà đầu tư ủy thác. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.INVES' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ định danh. |
| 5 | identn_nbr | STRING | X |  |  |  | Số giấy tờ định danh. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp giấy tờ định danh. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp giấy tờ. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | dscr_ivsm_ivsr | dscr_ivsm_ivsr_id |



**Index:** N/A

**Trigger:** N/A


#### Từ FMS.FUNDS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Investment Fund. |
| 2 | ip_code | STRING |  |  |  |  | Mã quỹ đầu tư. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.FUNDS' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ — quyết định thành lập quỹ. |
| 5 | identn_nbr | STRING | X |  |  |  | Số quyết định thành lập CN/VPĐD. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp quyết định thành lập quỹ. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Cơ quan ban hành quyết định thành lập |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | ivsm_fnd | ivsm_fnd_id |



**Index:** N/A

**Trigger:** N/A


#### Từ FMS.TLProfiles

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Fund Management Company Key Person. |
| 2 | ip_code | STRING |  |  |  |  | Mã nhân sự công ty QLQ. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.TLProfiles' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ định danh cá nhân. |
| 5 | identn_nbr | STRING | X |  |  |  | Số giấy tờ định danh. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp CCCD/Hộ chiếu. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp CCCD/Hộ chiếu. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | fnd_mgt_co_key_psn | fnd_mgt_co_key_psn_id |



**Index:** N/A

**Trigger:** N/A


#### Từ FMS.BRANCHES

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Fund Management Company Organization Unit. |
| 2 | ip_code | STRING |  |  |  |  | Mã CN/VPĐD công ty QLQ. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.BRANCHES' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ — quyết định thành lập CN/VPĐD. |
| 5 | identn_nbr | STRING | X |  |  |  | Số quyết định thành lập CN/VPĐD. |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp quyết định thành lập. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Cơ quan ban hành quyết định thành lập |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | fnd_mgt_co_ou | fnd_mgt_co_ou_id |



**Index:** N/A

**Trigger:** N/A





### Bảng ip_elc_adr



#### Từ FMS.SECURITIES

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Fund Management Company. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty QLQ. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.SECURITIES' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  |  | Loại liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Địa chỉ email. |
| 6 | ip_id | STRING |  |  | F |  | FK đến Fund Management Company. |
| 7 | ip_code | STRING |  |  |  |  | Mã công ty QLQ. |
| 8 | src_stm_code | STRING |  |  |  | 'FMS.SECURITIES' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  |  | Loại liên lạc — fax. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số fax trụ sở chính. |
| 11 | ip_id | STRING |  |  | F |  | FK đến Fund Management Company. |
| 12 | ip_code | STRING |  |  |  |  | Mã công ty QLQ. |
| 13 | src_stm_code | STRING |  |  |  | 'FMS.SECURITIES' | Mã nguồn dữ liệu. |
| 14 | elc_adr_tp_code | STRING |  |  |  |  | Loại liên lạc — điện thoại. |
| 15 | elc_adr_val | STRING | X |  |  |  | Số điện thoại trụ sở chính. |
| 16 | ip_id | STRING |  |  | F |  | FK đến Fund Management Company. |
| 17 | ip_code | STRING |  |  |  |  | Mã công ty QLQ. |
| 18 | src_stm_code | STRING |  |  |  | 'FMS.SECURITIES' | Mã nguồn dữ liệu. |
| 19 | elc_adr_tp_code | STRING |  |  |  |  | Loại liên lạc — website. |
| 20 | elc_adr_val | STRING | X |  |  |  | Địa chỉ website. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | fnd_mgt_co | fnd_mgt_co_id |



**Index:** N/A

**Trigger:** N/A


#### Từ FMS.FORBRCH

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Foreign Fund Management Organization Unit. |
| 2 | ip_code | STRING |  |  |  |  | Mã VPĐD/CN QLQ NN. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.FORBRCH' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  |  | Loại liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Địa chỉ email. |
| 6 | ip_id | STRING |  |  | F |  | FK đến Foreign Fund Management Organization Unit. |
| 7 | ip_code | STRING |  |  |  |  | Mã VPĐD/CN QLQ NN. |
| 8 | src_stm_code | STRING |  |  |  | 'FMS.FORBRCH' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  |  | Loại liên lạc — fax. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số fax. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | frgn_fnd_mgt_ou | frgn_fnd_mgt_ou_id |



**Index:** N/A

**Trigger:** N/A


#### Từ FMS.BANKMONI

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Custodian Bank. |
| 2 | ip_code | STRING |  |  |  |  | Mã ngân hàng LKGS. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.BANKMONI' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  |  | Loại liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Địa chỉ email. |
| 6 | ip_id | STRING |  |  | F |  | FK đến Custodian Bank. |
| 7 | ip_code | STRING |  |  |  |  | Mã ngân hàng LKGS. |
| 8 | src_stm_code | STRING |  |  |  | 'FMS.BANKMONI' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  |  | Loại liên lạc — điện thoại. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | cstd_bnk | cstd_bnk_id |



**Index:** N/A

**Trigger:** N/A


#### Từ FMS.BRANCHES

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Fund Management Company Organization Unit. |
| 2 | ip_code | STRING |  |  |  |  | Mã CN/VPĐD công ty QLQ. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.BRANCHES' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  |  | Loại liên lạc — fax. |
| 5 | elc_adr_val | STRING | X |  |  |  | Số fax CN/VPĐD. |
| 6 | ip_id | STRING |  |  | F |  | FK đến Fund Management Company Organization Unit. |
| 7 | ip_code | STRING |  |  |  |  | Mã CN/VPĐD công ty QLQ. |
| 8 | src_stm_code | STRING |  |  |  | 'FMS.BRANCHES' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  |  | Loại liên lạc — điện thoại. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số điện thoại CN/VPĐD. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | fnd_mgt_co_ou | fnd_mgt_co_ou_id |



**Index:** N/A

**Trigger:** N/A





### Bảng ip_pst_adr



#### Từ FMS.SECURITIES

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Fund Management Company. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty QLQ. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.SECURITIES' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở chính công ty QLQ. |
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
| ip_id | fnd_mgt_co | fnd_mgt_co_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ FMS.FORBRCH

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Foreign Fund Management Organization Unit. |
| 2 | ip_code | STRING |  |  |  |  | Mã VPĐD/CN QLQ NN. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.FORBRCH' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ VPĐD/CN tại VN. |
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
| ip_id | frgn_fnd_mgt_ou | frgn_fnd_mgt_ou_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ FMS.BANKMONI

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Custodian Bank. |
| 2 | ip_code | STRING |  |  |  |  | Mã ngân hàng LKGS. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.BANKMONI' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở ngân hàng LKGS. |
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
| ip_id | cstd_bnk | cstd_bnk_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ FMS.AGENCIES

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Fund Distribution Agent. |
| 2 | ip_code | STRING |  |  |  |  | Mã đại lý phân phối quỹ. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.AGENCIES' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở đại lý phân phối quỹ. |
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
| ip_id | fnd_dstr_agnt | fnd_dstr_agnt_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ FMS.BRANCHES

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Fund Management Company Organization Unit. |
| 2 | ip_code | STRING |  |  |  |  | Mã CN/VPĐD công ty QLQ. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.BRANCHES' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ CN/VPĐD. |
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
| ip_id | fnd_mgt_co_ou | fnd_mgt_co_ou_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ FMS.AGENCIESBRA

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Fund Distribution Agent Organization Unit. |
| 2 | ip_code | STRING |  |  |  |  | Mã CN/PGD đại lý phân phối quỹ. |
| 3 | src_stm_code | STRING |  |  |  | 'FMS.AGENCIESBRA' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ CN/PGD đại lý phân phối quỹ. |
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
| ip_id | fnd_dstr_agnt_ou | fnd_dstr_agnt_ou_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A





### Stored Procedure/Function

N/A

### Package

N/A
