## NHNCK — Hệ thống Quản lý giám sát người hành nghề chứng khoán

### Các mô hình quan hệ dữ liệu

![Mô hình quan hệ dữ liệu NHNCK](NHNCK/fragments/NHNCK_diagram.png)

**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | scr_prac_conduct_vln | Vi phạm pháp luật hoặc hành chính của người hành nghề chứng khoán. Ghi nhận loại vi phạm và quyết định xử lý. |
| 2 | scr_prac_license_ap_pcs_avy_log | Nhật ký hoạt động xử lý hồ sơ CCHN. Ghi nhận từng bước xử lý và trạng thái hồ sơ theo thời gian. |
| 3 | scr_prac_license_ap_verf_st | Bản ghi phê duyệt nội bộ hồ sơ CCHN theo cấp lãnh đạo. Ghi nhận người phê duyệt và kết quả phê duyệt tại từng cấp. |
| 4 | scr_prac_license_ctf_doc_avy_log | Nhật ký hoạt động tác động lên chứng chỉ hành nghề. Ghi nhận hành động và người thực hiện. |
| 5 | scr_prac_license_ctf_doc_st_hist | Lịch sử thay đổi trạng thái của chứng chỉ hành nghề. Ghi nhận trạng thái trước/sau và lý do thay đổi. |
| 6 | scr_prac_prof_trn_clss_enrollment | Đăng ký tham gia và kết quả học tập của người hành nghề tại một khóa đào tạo chuyên môn. |
| 7 | scr_prac_id_verf_rcrd | Kết quả xác thực danh tính người hành nghề qua hệ thống C06 của Bộ Công An. Lưu trạng thái và phản hồi xác thực. |
| 8 | scr_prac_qualf_exam_ases | Đợt thi sát hạch cấp chứng chỉ hành nghề chứng khoán. Ghi nhận thông tin tổ chức đợt thi và quyết định công nhận kết quả. |
| 9 | scr_prac_qualf_exam_ases_rslt | Kết quả thi sát hạch của từng thí sinh trong một đợt thi. Ghi nhận điểm thi và kết quả đạt/không đạt. |
| 10 | scr_prac_qualf_exam_ases_fee | Biểu phí thi sát hạch theo đợt thi và loại chứng chỉ. Ghi nhận mức phí thi và phúc khảo. |
| 11 | scr_prac_license_ap | Hồ sơ đăng ký cấp/cấp lại/gia hạn chứng chỉ hành nghề chứng khoán. Ghi nhận đầy đủ thông tin người nộp và kết quả xử lý. |
| 12 | scr_prac_license_ap_doc_attch | Tài liệu đính kèm hồ sơ CCHN. Ghi nhận loại tài liệu và trạng thái thẩm định. |
| 13 | scr_prac_license_ap_ed_ctf_doc | Văn bằng/chứng chỉ học tập đính kèm hồ sơ CCHN. Ghi nhận loại chuyên môn và file đính kèm kèm trạng thái thẩm định. |
| 14 | scr_prac_license_ctf_doc | Chứng chỉ hành nghề chứng khoán được cấp cho người hành nghề. Ghi nhận loại chứng chỉ và quyết định cấp/thu hồi. |
| 15 | scr_prac_license_ctf_grp_doc | Nhóm chứng chỉ hành nghề trong một quyết định cấp/thu hồi/hủy tập thể. Liên kết với quyết định hành chính. |
| 16 | scr_prac_license_ctf_grp_mbr | Quan hệ thành viên giữa chứng chỉ hành nghề và nhóm cấp/thu hồi. Liên kết Certificate ↔ Group ↔ Application. |
| 17 | scr_prac_license_dcsn_doc | Quyết định hành chính của UBCKNN về cấp/thu hồi/hủy chứng chỉ hành nghề chứng khoán. |
| 18 | scr_prac_org_emp_rpt | Báo cáo của tổ chức về tình trạng tuyển dụng/chấm dứt hợp đồng người hành nghề chứng khoán. |
| 19 | scr_prac_prof_trn_clss | Khóa đào tạo chuyên môn nghiệp vụ chứng khoán do UBCKNN tổ chức. Ghi nhận thông tin khóa học và ngày thi. |
| 20 | reg_ahr_ou | Đơn vị/phòng ban thuộc UBCKNN. Cấu trúc phân cấp gộp Units và Departments. |
| 21 | scr_org_refr | Tổ chức tham gia thị trường chứng khoán (CTCK/QLQ/NH) được UBCKNN quản lý. Danh mục tổ chức tham chiếu trong hệ thống NHNCK. |
| 22 | scr_prac | Người hành nghề chứng khoán được UBCKNN cấp phép. Ghi nhận thông tin cá nhân và trạng thái hành nghề. Attribute chi tiết (BirthDate full |
| 23 | scr_prac_rel_p | Quan hệ thân nhân của người hành nghề chứng khoán. Ghi nhận loại quan hệ và thông tin người liên quan. |
| 24 | scr_prac_license_ap_fee | Phí thực tế phát sinh theo từng hồ sơ đăng ký CCHN. Ghi nhận loại phí và trạng thái thanh toán. |
| 25 | ip_alt_identn | Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn. |
| 26 | ip_elc_adr | Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn. |
| 27 | ip_pst_adr | Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn. |




### Bảng scr_prac_conduct_vln



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | conduct_vln_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | conduct_vln_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.Violations' | Mã nguồn dữ liệu |
| 4 | prac_id | STRING |  |  | F |  | FK đến Securities Practitioner |
| 5 | prac_code | STRING |  |  |  |  | Mã người hành nghề |
| 6 | full_nm | STRING | X |  |  |  | Họ và tên người vi phạm (snapshot) |
| 7 | dob | DATE | X |  |  |  | Ngày sinh (snapshot) |
| 8 | identn_nbr | STRING | X |  |  |  | Số CMND/CCCD (snapshot) |
| 9 | license_dcsn_doc_id | STRING | X |  | F |  | FK đến quyết định xử lý vi phạm |
| 10 | license_dcsn_doc_code | STRING | X |  |  |  | Mã quyết định |
| 11 | conduct_vln_tp_code | STRING | X |  |  |  | Loại vi phạm (1: Hành chính, 2: Pháp luật) |
| 12 | vln_note | STRING | X |  |  |  | Ghi chú vi phạm |
| 13 | vln_st_code | STRING | X |  |  |  | Trạng thái (1: Hoạt động, 0: Không hoạt động, -1: Đã xóa) |
| 14 | crt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer |
| 15 | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo |
| 16 | udt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer |
| 17 | udt_by_ofcr_code | STRING | X |  |  |  | Mã người cập nhật |
| 18 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo |
| 19 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| conduct_vln_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prac_id | scr_prac | prac_id |
| license_dcsn_doc_id | scr_prac_license_dcsn_doc | license_dcsn_doc_id |
| crt_by_ofcr_id |  |  |
| udt_by_ofcr_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_license_ap_pcs_avy_log



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | license_ap_pcs_avy_log_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | license_ap_pcs_avy_log_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.ActionLogs' | Mã nguồn dữ liệu |
| 4 | ofcr_id | STRING | X |  | F |  | FK đến tài khoản thực hiện |
| 5 | ofcr_code | STRING | X |  |  |  | Mã tài khoản thực hiện |
| 6 | clnt_mchn_adr | STRING | X |  |  |  | Địa chỉ IP máy thực hiện |
| 7 | avy_dtl | STRING | X |  |  |  | Mô tả nội dung thao tác |
| 8 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| license_ap_pcs_avy_log_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ofcr_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_license_ap_verf_st



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | license_ap_verf_st_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | license_ap_verf_st_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.VerifyApplicationStatuses' | Mã nguồn dữ liệu |
| 4 | license_ap_id | STRING |  |  | F |  | FK đến hồ sơ |
| 5 | license_ap_code | STRING |  |  |  |  | Mã hồ sơ |
| 6 | verf_st_code | STRING | X |  | F |  | Trạng thái phê duyệt (FK → ApplicationStatuses) |
| 7 | prev_verf_st_code | STRING | X |  |  |  | Trạng thái hồ sơ trước đó |
| 8 | verf_by_ofcr_id | STRING | X |  | F |  | FK đến người phê duyệt |
| 9 | verf_by_ofcr_code | STRING | X |  |  |  | Mã người phê duyệt |
| 10 | rejection_rsn_dsc | STRING | X |  |  |  | Lý do thay đổi trạng thái |
| 11 | specialization_ofcr_rsn | STRING | X |  |  |  | Nội dung ý kiến — Lãnh đạo chuyên môn |
| 12 | org_ofcr_rsn | STRING | X |  |  |  | Nội dung ý kiến — Lãnh đạo UBCK |
| 13 | overview_ofcr_rsn | STRING | X |  |  |  | Nội dung ý kiến — Cán bộ tổng hợp |
| 14 | crt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer |
| 15 | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo |
| 16 | udt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer |
| 17 | udt_by_ofcr_code | STRING | X |  |  |  | Mã người cập nhật |
| 18 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo |
| 19 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| license_ap_verf_st_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| license_ap_id | scr_prac_license_ap | license_ap_id |
| verf_by_ofcr_id |  |  |
| crt_by_ofcr_id |  |  |
| udt_by_ofcr_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_license_ctf_doc_avy_log



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | license_ctf_doc_avy_log_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | license_ctf_doc_avy_log_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.CertificateRecordLogs' | Mã nguồn dữ liệu |
| 4 | license_ctf_doc_id | STRING |  |  | F |  | FK đến chứng chỉ |
| 5 | license_ctf_doc_code | STRING |  |  |  |  | Mã chứng chỉ |
| 6 | avy_tp_code | STRING | X |  |  |  | Loại hành động |
| 7 | ctf_nbr | STRING | X |  |  |  | Số chứng chỉ tại thời điểm ghi log |
| 8 | license_dcsn_doc_id | STRING | X |  | F |  | FK đến quyết định |
| 9 | license_dcsn_doc_code | STRING | X |  |  |  | Mã quyết định |
| 10 | issu_dt | DATE | X |  |  |  | Ngày quyết định |
| 11 | avy_note | STRING | X |  |  |  | Ghi chú hoạt động |
| 12 | pcs_by_ofcr_id | STRING | X |  | F |  | FK đến người xử lý |
| 13 | pcs_by_ofcr_code | STRING | X |  |  |  | Mã người xử lý |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| license_ctf_doc_avy_log_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| license_ctf_doc_id | scr_prac_license_ctf_doc | license_ctf_doc_id |
| license_dcsn_doc_id | scr_prac_license_dcsn_doc | license_dcsn_doc_id |
| pcs_by_ofcr_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_license_ctf_doc_st_hist



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | license_ctf_doc_st_hist_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | license_ctf_doc_st_hist_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.CertificateRecordStatusHistories' | Mã nguồn dữ liệu |
| 4 | license_ctf_doc_id | STRING |  |  | F |  | FK đến chứng chỉ |
| 5 | license_ctf_doc_code | STRING |  |  |  |  | Mã chứng chỉ |
| 6 | license_dcsn_doc_id | STRING | X |  | F |  | FK đến quyết định |
| 7 | license_dcsn_doc_code | STRING | X |  |  |  | Mã quyết định |
| 8 | udt_tp_code | STRING | X |  |  |  | Loại cập nhật (Manual, System, Decision) |
| 9 | old_st_code | STRING | X |  |  |  | Trạng thái trước |
| 10 | new_st_code | STRING | X |  |  |  | Trạng thái sau |
| 11 | st_chg_rsn_dsc | STRING | X |  |  |  | Lý do thay đổi |
| 12 | st_chg_tms | TIMESTAMP | X |  |  |  | Thời điểm thay đổi |
| 13 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| license_ctf_doc_st_hist_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| license_ctf_doc_id | scr_prac_license_ctf_doc | license_ctf_doc_id |
| license_dcsn_doc_id | scr_prac_license_dcsn_doc | license_dcsn_doc_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_prof_trn_clss_enrollment



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | prof_trn_clss_enrollment_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | prof_trn_clss_enrollment_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.SpecializationCourseDetails' | Mã nguồn dữ liệu |
| 4 | prof_trn_clss_id | STRING |  |  | F |  | FK đến khóa học |
| 5 | prof_trn_clss_code | STRING |  |  |  |  | Mã khóa học |
| 6 | prac_id | STRING |  |  | F |  | FK đến Securities Practitioner |
| 7 | prac_code | STRING |  |  |  |  | Mã người hành nghề |
| 8 | full_nm | STRING | X |  |  |  | Họ và tên học viên (snapshot) |
| 9 | dob | DATE | X |  |  |  | Ngày sinh (snapshot) |
| 10 | plc_of_brth | STRING | X |  |  |  | Nơi sinh (snapshot) |
| 11 | identn_nbr | STRING | X |  |  |  | Số định danh (snapshot) |
| 12 | exam_nbr | STRING | X |  |  |  | Số dự thi |
| 13 | enrollment_dsc | STRING | X |  |  |  | Mô tả |
| 14 | ases_scor | STRING | X |  |  |  | Điểm thi |
| 15 | ases_rslt_code | STRING | X |  |  |  | Kết quả thi (1: Đạt, 0: Không đạt) |
| 16 | enrollment_note | STRING | X |  |  |  | Ghi chú |
| 17 | enrollment_st_code | STRING | X |  |  |  | Trạng thái (0: Chờ thẩm định, 1: Xác nhận, 2: Yêu cầu nộp lại, 3: Từ chối) |
| 18 | assignee_ofcr_id | STRING | X |  | F |  | FK đến cán bộ xử lý |
| 19 | assignee_ofcr_code | STRING | X |  |  |  | Mã cán bộ xử lý |
| 20 | crt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer |
| 21 | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo |
| 22 | udt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer |
| 23 | udt_by_ofcr_code | STRING | X |  |  |  | Mã người cập nhật |
| 24 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo |
| 25 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| prof_trn_clss_enrollment_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prof_trn_clss_id | scr_prac_prof_trn_clss | prof_trn_clss_id |
| prac_id | scr_prac | prac_id |
| assignee_ofcr_id |  |  |
| crt_by_ofcr_id |  |  |
| udt_by_ofcr_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_id_verf_rcrd



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | id_verf_rcrd_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | id_verf_rcrd_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.IdentityInfoC06s' | Mã nguồn dữ liệu |
| 4 | id_nbr | STRING | X |  |  |  | Số định danh cá nhân (CCCD/CMND) |
| 5 | full_nm | STRING | X |  |  |  | Họ và tên |
| 6 | frst_nm | STRING | X |  |  |  | Tên |
| 7 | dob | DATE | X |  |  |  | Ngày sinh |
| 8 | brth_yr | STRING | X |  |  |  | Năm sinh |
| 9 | idv_gnd_code | STRING | X |  |  |  | Giới tính (0: Nữ, 1: Nam) |
| 10 | nat_code | STRING | X |  |  |  | Quốc tịch |
| 11 | rlg_nm | STRING | X |  |  |  | Tôn giáo |
| 12 | cty_code | STRING | X |  |  |  | Mã quốc gia |
| 13 | plc_of_brth | STRING | X |  |  |  | Nơi sinh |
| 14 | hometown | STRING | X |  |  |  | Địa chỉ quê quán |
| 15 | perm_cty_code | STRING | X |  |  |  | Quốc gia nguyên quán |
| 16 | perm_prov_code | STRING | X |  |  |  | Tỉnh thành nguyên quán |
| 17 | perm_dstc_code | STRING | X |  |  |  | Quận huyện nguyên quán |
| 18 | perm_adr_dtl | STRING | X |  |  |  | Địa chỉ nguyên quán chi tiết |
| 19 | crn_cty_code | STRING | X |  |  |  | Quốc gia hiện tại |
| 20 | crn_prov_code | STRING | X |  |  |  | Tỉnh thành hiện tại |
| 21 | crn_dstc_code | STRING | X |  |  |  | Quận huyện hiện tại |
| 22 | crn_adr_dtl | STRING | X |  |  |  | Địa chỉ hiện tại chi tiết |
| 23 | fthr_full_nm | STRING | X |  |  |  | Họ và tên bố |
| 24 | fthr_cty_code | STRING | X |  |  |  | Quốc gia của bố |
| 25 | fthr_id_nbr | STRING | X |  |  |  | Số định danh của bố |
| 26 | fthr_id_nbr_old | STRING | X |  |  |  | Số định danh cũ của bố |
| 27 | mthr_full_nm | STRING | X |  |  |  | Họ và tên mẹ |
| 28 | mthr_cty_code | STRING | X |  |  |  | Quốc gia của mẹ |
| 29 | mthr_id_nbr | STRING | X |  |  |  | Số định danh của mẹ |
| 30 | mthr_id_nbr_old | STRING | X |  |  |  | Số định danh cũ của mẹ |
| 31 | couple_full_nm | STRING | X |  |  |  | Họ và tên vợ/chồng |
| 32 | couple_cty_code | STRING | X |  |  |  | Quốc gia của vợ/chồng |
| 33 | couple_id_nbr | STRING | X |  |  |  | Số định danh của vợ/chồng |
| 34 | couple_id_nbr_old | STRING | X |  |  |  | Số định danh cũ của vợ/chồng |
| 35 | udt_by_ofcr_id | STRING | X |  | F |  | FK đến người cập nhật |
| 36 | udt_by_ofcr_code | STRING | X |  |  |  | Mã người cập nhật |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| id_verf_rcrd_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| udt_by_ofcr_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_qualf_exam_ases



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | exam_ases_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | exam_ases_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.ExamSessions' | Mã nguồn dữ liệu |
| 4 | ssn_code | STRING | X |  |  |  | Mã đợt thi (mã nghiệp vụ) |
| 5 | ssn_nm | STRING | X |  |  |  | Tên đợt thi |
| 6 | exam_yr | STRING | X |  |  |  | Năm thi |
| 7 | ssn_nbr | STRING | X |  |  |  | Đợt thi (số thứ tự trong năm) |
| 8 | organizer_nm | STRING | X |  |  |  | Đơn vị tổ chức |
| 9 | rgst_strt_dt | DATE | X |  |  |  | Ngày bắt đầu nhận hồ sơ |
| 10 | rgst_end_dt | DATE | X |  |  |  | Ngày kết thúc nhận hồ sơ |
| 11 | exam_strt_dt | DATE | X |  |  |  | Ngày bắt đầu thi |
| 12 | exam_end_dt | DATE | X |  |  |  | Ngày kết thúc thi |
| 13 | exam_lo | STRING | X |  |  |  | Địa điểm thi |
| 14 | notf_dt | DATE | X |  |  |  | Ngày thông báo kết quả |
| 15 | subm_mth_dsc | STRING | X |  |  |  | Phương thức nộp hồ sơ |
| 16 | attch_file_path | STRING | X |  |  |  | File thông báo đính kèm |
| 17 | license_dcsn_doc_id | STRING | X |  | F |  | FK đến quyết định công nhận kết quả |
| 18 | license_dcsn_doc_code | STRING | X |  |  |  | Mã quyết định |
| 19 | exam_st_code | STRING | X |  |  |  | Trạng thái (0: Chưa hoàn thành, 1: Đã hoàn thành) |
| 20 | crt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer |
| 21 | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| exam_ases_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| license_dcsn_doc_id | scr_prac_license_dcsn_doc | license_dcsn_doc_id |
| crt_by_ofcr_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_qualf_exam_ases_rslt



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | exam_ases_rslt_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | exam_ases_rslt_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.ExamDetails' | Mã nguồn dữ liệu |
| 4 | exam_ases_id | STRING |  |  | F |  | FK đến đợt thi |
| 5 | exam_ases_code | STRING |  |  |  |  | Mã đợt thi |
| 6 | prac_id | STRING |  |  | F |  | FK đến Securities Practitioner |
| 7 | prac_code | STRING |  |  |  |  | Mã người hành nghề |
| 8 | ctf_tp_code | STRING | X |  |  |  | Mã loại chứng chỉ dự thi |
| 9 | license_ap_id | STRING | X |  | F |  | FK đến hồ sơ |
| 10 | license_ap_code | STRING | X |  |  |  | Mã hồ sơ |
| 11 | seq_nbr | INT | X |  |  |  | Số thứ tự trong đợt thi |
| 12 | exam_nbr | STRING | X |  |  |  | Số báo danh |
| 13 | law_scor | STRING | X |  |  |  | Điểm pháp luật |
| 14 | law_rslt_ind | BOOLEAN | X |  |  |  | Kết quả luật (1: Đạt, 0: Không đạt) |
| 15 | specialization_scor | STRING | X |  |  |  | Điểm chuyên môn |
| 16 | specialization_rslt_ind | BOOLEAN | X |  |  |  | Kết quả chuyên môn (1: Đạt, 0: Không đạt) |
| 17 | exam_rslt_code | STRING | X |  |  |  | Kết quả tổng (1: Đạt, 0: Không đạt) |
| 18 | exam_note | STRING | X |  |  |  | Ghi chú |
| 19 | crt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer |
| 20 | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo |
| 21 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| exam_ases_rslt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| exam_ases_id | scr_prac_qualf_exam_ases | exam_ases_id |
| prac_id | scr_prac | prac_id |
| license_ap_id | scr_prac_license_ap | license_ap_id |
| crt_by_ofcr_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_qualf_exam_ases_fee



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | exam_ases_fee_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | exam_ases_fee_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.ExamSessionFees' | Mã nguồn dữ liệu |
| 4 | exam_ases_id | STRING |  |  | F |  | FK đến đợt thi |
| 5 | exam_ases_code | STRING |  |  |  |  | Mã đợt thi |
| 6 | ctf_tp_code | STRING |  |  |  |  | Mã loại chứng chỉ |
| 7 | exam_fee_amt | DECIMAL(23,2) | X |  |  |  | Phí thi (VNĐ) |
| 8 | appeal_fee_amt | DECIMAL(23,2) | X |  |  |  | Phí phúc khảo (VNĐ) |
| 9 | fee_st_code | STRING | X |  |  |  | Trạng thái |
| 10 | crt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer |
| 11 | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo |
| 12 | udt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer |
| 13 | udt_by_ofcr_code | STRING | X |  |  |  | Mã người cập nhật |
| 14 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo |
| 15 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| exam_ases_fee_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| exam_ases_id | scr_prac_qualf_exam_ases | exam_ases_id |
| crt_by_ofcr_id |  |  |
| udt_by_ofcr_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_license_ap



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | license_ap_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | license_ap_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.Applications' | Mã nguồn dữ liệu |
| 4 | prac_id | STRING |  |  | F |  | FK đến Securities Practitioner |
| 5 | prac_code | STRING |  |  |  |  | Mã người hành nghề |
| 6 | ctf_tp_code | STRING | X |  |  |  | Mã loại chứng chỉ đăng ký |
| 7 | ap_st_code | STRING | X |  |  |  | Trạng thái hồ sơ (FK → ApplicationStatuses) |
| 8 | license_ctf_doc_id | STRING | X |  | F |  | FK đến CCHN đã được cấp (nếu có) |
| 9 | license_ctf_doc_code | STRING | X |  |  |  | Mã CCHN đã cấp |
| 10 | prev_ctf_tp_code | STRING | X |  |  |  | Mã loại chứng chỉ trước đó |
| 11 | prev_license_ctf_doc_id | STRING | X |  | F |  | FK đến CCHN trước đó |
| 12 | prev_license_ctf_doc_code | STRING | X |  |  |  | Mã CCHN trước đó |
| 13 | exam_ases_id | STRING | X |  | F |  | FK đến đợt thi (nếu hồ sơ gắn với kỳ thi) |
| 14 | exam_ases_code | STRING | X |  |  |  | Mã đợt thi |
| 15 | assignee_ofcr_id | STRING | X |  | F |  | FK đến cán bộ xử lý |
| 16 | assignee_ofcr_code | STRING | X |  |  |  | Mã cán bộ xử lý |
| 17 | license_ap_verf_st_id | STRING | X |  | F |  | FK đến yêu cầu phê duyệt lãnh đạo |
| 18 | license_ap_verf_st_code | STRING | X |  |  |  | Mã yêu cầu phê duyệt |
| 19 | ap_code | STRING | X |  |  |  | Mã hồ sơ (mã nghiệp vụ) |
| 20 | ap_ttl | STRING | X |  |  |  | Tiêu đề hồ sơ |
| 21 | rgst_tp_code | STRING | X |  |  |  | Loại đăng ký |
| 22 | ap_tp_code | STRING | X |  |  |  | Loại hồ sơ |
| 23 | subm_dt | DATE | X |  |  |  | Ngày nộp hồ sơ |
| 24 | supplement_dt | DATE | X |  |  |  | Ngày bổ sung hồ sơ |
| 25 | supplement_ltr_dt | DATE | X |  |  |  | Ngày thư yêu cầu bổ sung |
| 26 | reissue_rsn | STRING | X |  |  |  | Lý do cấp lại |
| 27 | rejection_rsn | STRING | X |  |  |  | Lý do từ chối |
| 28 | ctf_nbr | STRING | X |  |  |  | Số chứng chỉ (snapshot tại thời điểm cấp) |
| 29 | issu_dt | DATE | X |  |  |  | Ngày cấp chứng chỉ (snapshot) |
| 30 | prev_ctf_nbr | STRING | X |  |  |  | Số chứng chỉ trước đó (snapshot) |
| 31 | prev_issu_dt | DATE | X |  |  |  | Ngày cấp chứng chỉ trước đó (snapshot) |
| 32 | reissue_hsm_code | STRING | X |  |  |  | Mã tái cấp HSM |
| 33 | ctf_recpt_mth_code | STRING | X |  |  |  | Phương thức nhận chứng chỉ |
| 34 | ctf_recpt_adr | STRING | X |  |  |  | Địa chỉ nhận chứng chỉ |
| 35 | ctf_recpt_ph | STRING | X |  |  |  | Số điện thoại nhận chứng chỉ |
| 36 | recpt_st_code | STRING | X |  |  |  | Trạng thái nhận chứng chỉ |
| 37 | is_violated_ind | BOOLEAN | X |  |  |  | Cờ vi phạm |
| 38 | is_dt_exploitable_ind | BOOLEAN | X |  |  |  | Cờ khai thác theo ngày |
| 39 | ap_note | STRING | X |  |  |  | Ghi chú |
| 40 | crt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer |
| 41 | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo |
| 42 | udt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer |
| 43 | udt_by_ofcr_code | STRING | X |  |  |  | Mã người cập nhật |
| 44 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo |
| 45 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| license_ap_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prac_id | scr_prac | prac_id |
| license_ctf_doc_id | scr_prac_license_ctf_doc | license_ctf_doc_id |
| prev_license_ctf_doc_id | scr_prac_license_ctf_doc | license_ctf_doc_id |
| exam_ases_id | scr_prac_qualf_exam_ases | exam_ases_id |
| assignee_ofcr_id |  |  |
| license_ap_verf_st_id | scr_prac_license_ap_verf_st | license_ap_verf_st_id |
| crt_by_ofcr_id |  |  |
| udt_by_ofcr_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_license_ap_doc_attch



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | license_ap_doc_attch_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | license_ap_doc_attch_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.ApplicationDocuments' | Mã nguồn dữ liệu |
| 4 | license_ap_id | STRING |  |  | F |  | FK đến hồ sơ |
| 5 | license_ap_code | STRING |  |  |  |  | Mã hồ sơ |
| 6 | doc_tp_code | STRING | X |  | F |  | Mã loại tài liệu (FK → Documents) |
| 7 | doc_nm | STRING | X |  |  |  | Tên tài liệu |
| 8 | file_nm | STRING | X |  |  |  | Tên file |
| 9 | file_path | STRING | X |  |  |  | Đường dẫn file |
| 10 | file_fmt | STRING | X |  |  |  | Loại file (pdf, docx...) |
| 11 | file_sz | STRING | X |  |  |  | Dung lượng file (bytes) |
| 12 | attch_dsc | STRING | X |  |  |  | Mô tả tài liệu |
| 13 | attch_note | STRING | X |  |  |  | Ghi chú thẩm định |
| 14 | aprs_st_code | STRING | X |  |  |  | Trạng thái thẩm định |
| 15 | is_inval_ind | BOOLEAN | X |  |  |  | Cờ không hợp lệ |
| 16 | is_incom_ind | BOOLEAN | X |  |  |  | Cờ chưa hoàn thành |
| 17 | assignee_ofcr_id | STRING | X |  | F |  | FK đến người thẩm định |
| 18 | assignee_ofcr_code | STRING | X |  |  |  | Mã người thẩm định |
| 19 | appraisaled_tms | TIMESTAMP | X |  |  |  | Ngày thẩm định |
| 20 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| license_ap_doc_attch_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| license_ap_id | scr_prac_license_ap | license_ap_id |
| assignee_ofcr_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_license_ap_ed_ctf_doc



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | license_ap_ed_ctf_doc_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | license_ap_ed_ctf_doc_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.ApplicationSpecializations' | Mã nguồn dữ liệu |
| 4 | license_ap_id | STRING |  |  | F |  | FK đến hồ sơ |
| 5 | license_ap_code | STRING |  |  |  |  | Mã hồ sơ |
| 6 | specialization_tp_code | STRING |  |  |  |  | Mã chuyên môn (FK → Specializations) |
| 7 | file_nm | STRING | X |  |  |  | Tên file chứng chỉ chuyên môn |
| 8 | file_path | STRING | X |  |  |  | Đường dẫn file |
| 9 | file_fmt | STRING | X |  |  |  | Loại file |
| 10 | file_sz | STRING | X |  |  |  | Dung lượng file (bytes) |
| 11 | specialization_note | STRING | X |  |  |  | Nội dung/ghi chú |
| 12 | aprs_st_code | STRING | X |  |  |  | Trạng thái thẩm định |
| 13 | assignee_ofcr_id | STRING | X |  | F |  | FK đến người thẩm định |
| 14 | assignee_ofcr_code | STRING | X |  |  |  | Mã người thẩm định |
| 15 | appraisaled_tms | TIMESTAMP | X |  |  |  | Ngày thẩm định |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| license_ap_ed_ctf_doc_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| license_ap_id | scr_prac_license_ap | license_ap_id |
| assignee_ofcr_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_license_ctf_doc



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | license_ctf_doc_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | license_ctf_doc_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.CertificateRecords' | Mã nguồn dữ liệu |
| 4 | prac_id | STRING | X |  | F |  | FK đến Securities Practitioner |
| 5 | prac_code | STRING | X |  |  |  | Mã người hành nghề |
| 6 | prof_full_nm | STRING | X |  |  |  | Họ và tên người hành nghề (snapshot tại thời điểm cấp) |
| 7 | ctf_tp_code | STRING | X |  |  |  | Mã loại chứng chỉ |
| 8 | issn_dcsn_doc_id | STRING | X |  | F |  | FK đến quyết định cấp |
| 9 | issn_dcsn_doc_code | STRING | X |  |  |  | Mã quyết định cấp |
| 10 | revocation_dcsn_doc_id | STRING | X |  | F |  | FK đến quyết định thu hồi |
| 11 | revocation_dcsn_doc_code | STRING | X |  |  |  | Mã quyết định thu hồi |
| 12 | cncl_dcsn_doc_id | STRING | X |  | F |  | FK đến quyết định hủy |
| 13 | cncl_dcsn_doc_code | STRING | X |  |  |  | Mã quyết định hủy |
| 14 | ctf_nbr | STRING | X |  |  |  | Số chứng chỉ |
| 15 | ctf_issu_dt | DATE | X |  |  |  | Ngày cấp chứng chỉ |
| 16 | revocation_dt | DATE | X |  |  |  | Ngày thu hồi chứng chỉ |
| 17 | revocation_rsn | STRING | X |  |  |  | Lý do thu hồi |
| 18 | ctf_st_code | STRING | X |  |  |  | Trạng thái (0: Chưa sử dụng, 1: Đang sử dụng, 2: Thu hồi, 3: Đã hủy) |
| 19 | pcs_st_code | STRING | X |  |  |  | Trạng thái xử lý (Đã cấp, Đã ký, Đã trả) |
| 20 | ctf_dsc | STRING | X |  |  |  | Mô tả |
| 21 | alw_reissue_ind | BOOLEAN | X |  |  |  | Cho phép cấp lại (0: Không, 1: Có) |
| 22 | crt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer |
| 23 | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo |
| 24 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| license_ctf_doc_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prac_id | scr_prac | prac_id |
| issn_dcsn_doc_id | scr_prac_license_dcsn_doc | license_dcsn_doc_id |
| revocation_dcsn_doc_id | scr_prac_license_dcsn_doc | license_dcsn_doc_id |
| cncl_dcsn_doc_id | scr_prac_license_dcsn_doc | license_dcsn_doc_id |
| crt_by_ofcr_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_license_ctf_grp_doc



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | license_ctf_grp_doc_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | license_ctf_grp_doc_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.CertificateRecordGroups' | Mã nguồn dữ liệu |
| 4 | grp_nm | STRING | X |  |  |  | Tên nhóm |
| 5 | grp_tp_code | STRING | X |  |  |  | Loại nhóm (Cấp/Thu hồi/Hủy/Chuyển đổi) |
| 6 | license_dcsn_doc_id | STRING | X |  | F |  | FK đến quyết định |
| 7 | license_dcsn_doc_code | STRING | X |  |  |  | Mã quyết định |
| 8 | grp_dsc | STRING | X |  |  |  | Mô tả nhóm |
| 9 | grp_notes | STRING | X |  |  |  | Ghi chú |
| 10 | grp_st_code | STRING | X |  |  |  | Trạng thái nhóm |
| 11 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo |
| 12 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| license_ctf_grp_doc_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| license_dcsn_doc_id | scr_prac_license_dcsn_doc | license_dcsn_doc_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_license_ctf_grp_mbr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | license_ctf_grp_mbr_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | license_ctf_grp_mbr_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.CertificateRecordGroupMembers' | Mã nguồn dữ liệu |
| 4 | license_ctf_grp_doc_id | STRING |  |  | F |  | FK đến nhóm chứng chỉ |
| 5 | license_ctf_grp_doc_code | STRING |  |  |  |  | Mã nhóm |
| 6 | license_ctf_doc_id | STRING |  |  | F |  | FK đến chứng chỉ |
| 7 | license_ctf_doc_code | STRING |  |  |  |  | Mã chứng chỉ |
| 8 | ordr_indx | INT | X |  |  |  | Thứ tự sắp xếp trong nhóm |
| 9 | is_reissue_ind | BOOLEAN | X |  |  |  | Cờ cho phép cấp lại |
| 10 | revocation_rsn | STRING | X |  |  |  | Lý do thu hồi/hủy |
| 11 | mbr_st_code | STRING | X |  |  |  | Trạng thái thành viên nhóm |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| license_ctf_grp_mbr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| license_ctf_grp_doc_id | scr_prac_license_ctf_grp_doc | license_ctf_grp_doc_id |
| license_ctf_doc_id | scr_prac_license_ctf_doc | license_ctf_doc_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_license_dcsn_doc



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | license_dcsn_doc_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | license_dcsn_doc_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.Decisions' | Mã nguồn dữ liệu |
| 4 | dcsn_nbr | STRING | X |  |  |  | Số quyết định |
| 5 | dcsn_ttl | STRING | X |  |  |  | Tiêu đề quyết định |
| 6 | dcsn_refr | STRING | X |  |  |  | Trích dẫn |
| 7 | dcsn_cntnt | STRING | X |  |  |  | Nội dung quyết định |
| 8 | signing_dt | DATE | X |  |  |  | Ngày ký |
| 9 | signatory_nm | STRING | X |  |  |  | Người ký |
| 10 | signatory_pos_nm | STRING | X |  |  |  | Chức vụ người ký |
| 11 | dcsn_unit_nm | STRING | X |  |  |  | Đơn vị ban hành |
| 12 | attch_file_nm | STRING | X |  |  |  | Tên file đính kèm |
| 13 | attch_file_path | STRING | X |  |  |  | Đường dẫn file |
| 14 | dcsn_tp_code | STRING | X |  |  |  | Loại quyết định |
| 15 | dcsn_st_code | STRING | X |  |  |  | Trạng thái quyết định |
| 16 | crt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer |
| 17 | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo |
| 18 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo |
| 19 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| license_dcsn_doc_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| crt_by_ofcr_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_org_emp_rpt



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | org_emp_rpt_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | org_emp_rpt_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.OrganizationReports' | Mã nguồn dữ liệu |
| 4 | prac_id | STRING |  |  | F |  | FK đến Securities Practitioner |
| 5 | prac_code | STRING |  |  |  |  | Mã người hành nghề |
| 6 | scr_org_id | STRING | X |  | F |  | FK đến tổ chức |
| 7 | scr_org_code | STRING | X |  |  |  | Mã tổ chức |
| 8 | ctf_tp_code | STRING | X |  |  |  | Mã loại chứng chỉ |
| 9 | license_ctf_doc_id | STRING | X |  | F |  | FK đến chứng chỉ hành nghề |
| 10 | license_ctf_doc_code | STRING | X |  |  |  | Mã chứng chỉ |
| 11 | prn_org_emp_rpt_id | STRING | X |  | F |  | FK self-ref — báo cáo cha |
| 12 | prn_org_emp_rpt_code | STRING | X |  |  |  | Mã báo cáo cha |
| 13 | rpt_tp_code | STRING | X |  |  |  | Loại báo cáo |
| 14 | rpt_dt | DATE | X |  |  |  | Ngày báo cáo |
| 15 | full_nm | STRING | X |  |  |  | Họ và tên (snapshot) |
| 16 | dob | DATE | X |  |  |  | Ngày sinh (snapshot) |
| 17 | identn_nbr | STRING | X |  |  |  | Số chứng minh thư (snapshot) |
| 18 | pos_nm | STRING | X |  |  |  | Chức vụ |
| 19 | dept_nm | STRING | X |  |  |  | Phòng ban |
| 20 | bsn_dept_nm | STRING | X |  |  |  | Phòng ban nghiệp vụ |
| 21 | workplace_nm | STRING | X |  |  |  | Nơi công tác |
| 22 | hire_dt | DATE | X |  |  |  | Ngày tiếp nhận |
| 23 | tmt_dt | DATE | X |  |  |  | Ngày thôi việc |
| 24 | ctf_nbr | STRING | X |  |  |  | Số chứng chỉ (snapshot) |
| 25 | ctf_issu_dt | DATE | X |  |  |  | Ngày cấp chứng chỉ (snapshot) |
| 26 | discipline_dsc | STRING | X |  |  |  | Kỷ luật (vi phạm hoặc xử phạt) |
| 27 | rpt_dsc | STRING | X |  |  |  | Mô tả báo cáo |
| 28 | sync_id | STRING | X |  |  |  | Mã đồng bộ |
| 29 | sync_crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo đồng bộ |
| 30 | sync_udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật đồng bộ |
| 31 | crt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer |
| 32 | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo |
| 33 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo |
| 34 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| org_emp_rpt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prac_id | scr_prac | prac_id |
| scr_org_id | scr_org_refr | scr_org_refr_id |
| license_ctf_doc_id | scr_prac_license_ctf_doc | license_ctf_doc_id |
| prn_org_emp_rpt_id | scr_prac_org_emp_rpt | org_emp_rpt_id |
| crt_by_ofcr_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_prof_trn_clss



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | prof_trn_clss_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | prof_trn_clss_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.SpecializationCourses' | Mã nguồn dữ liệu |
| 4 | specialization_tp_code | STRING |  |  | F |  | Mã chuyên môn |
| 5 | course_code | STRING | X |  |  |  | Mã khóa học (mã nghiệp vụ) |
| 6 | course_nm | STRING | X |  |  |  | Tên khóa học |
| 7 | academic_yr | STRING | X |  |  |  | Năm học |
| 8 | exam_dt | DATE | X |  |  |  | Ngày thi |
| 9 | course_dsc | STRING | X |  |  |  | Mô tả khóa học |
| 10 | attch_file_path | STRING | X |  |  |  | Đường dẫn tài liệu |
| 11 | is_actv_f | BOOLEAN | X |  |  |  | Trạng thái hoạt động |
| 12 | course_st_code | STRING | X |  |  |  | Trạng thái (1: Hoạt động, 0: Không hoạt động, -1: Đã xóa) |
| 13 | crt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer |
| 14 | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo |
| 15 | udt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer |
| 16 | udt_by_ofcr_code | STRING | X |  |  |  | Mã người cập nhật |
| 17 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo |
| 18 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| prof_trn_clss_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| crt_by_ofcr_id |  |  |
| udt_by_ofcr_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng reg_ahr_ou



#### Từ NHNCK.Units

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ou_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | ou_code | STRING |  |  |  |  | Mã đơn vị. BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.Units' | Mã nguồn dữ liệu |
| 4 | ou_tp_code | STRING |  |  |  |  | Phân loại — Đơn vị (Unit) |
| 5 | ou_nm | STRING | X |  |  |  | Tên đơn vị |
| 6 | ou_dsc | STRING | X |  |  |  | Mô tả |
| 7 | ou_st_code | STRING | X |  |  |  | Trạng thái |
| 8 | prn_ou_id | STRING | X |  | F |  | FK đến đơn vị cha (Units) |
| 9 | prn_ou_code | STRING | X |  |  |  | Mã đơn vị cha |
| 10 | sort_ordr | INT | X |  |  |  | Thứ tự sắp xếp |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ou_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prn_ou_id | reg_ahr_ou | ou_id |



**Index:** N/A

**Trigger:** N/A


#### Từ NHNCK.Departments

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ou_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | ou_code | STRING |  |  |  |  | Mã phòng ban. BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.Departments' | Mã nguồn dữ liệu |
| 4 | ou_tp_code | STRING |  |  |  |  | Phân loại — Phòng ban (Department) |
| 5 | ou_nm | STRING | X |  |  |  | Tên phòng ban |
| 6 | ou_dsc | STRING | X |  |  |  | Mô tả |
| 7 | ou_st_code | STRING | X |  |  |  | Trạng thái |
| 8 | prn_ou_id | STRING | X |  | F |  | FK đến đơn vị cha (Units) |
| 9 | prn_ou_code | STRING | X |  |  |  | Mã đơn vị cha |
| 10 | sort_ordr | INT | X |  |  |  | Thứ tự sắp xếp |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ou_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prn_ou_id | reg_ahr_ou | ou_id |



**Index:** N/A

**Trigger:** N/A





### Bảng scr_org_refr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_org_refr_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | scr_org_refr_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.Organizations' | Mã nguồn dữ liệu |
| 4 | org_code | STRING | X |  |  |  | Mã tổ chức (mã nghiệp vụ) |
| 5 | org_nm | STRING | X |  |  |  | Tên tổ chức |
| 6 | en_nm | STRING | X |  |  |  | Tên tiếng Anh |
| 7 | abr | STRING | X |  |  |  | Tên viết tắt |
| 8 | org_tp_code | STRING | X |  |  |  | Mã loại tổ chức (1: CTCK, 2: QLQ, 3: Ngân hàng, 4: Khác) |
| 9 | org_lvl_code | STRING | X |  |  |  | Cấp độ tổ chức |
| 10 | prn_org_id | STRING | X |  | F |  | FK self-referencing — tổ chức cha |
| 11 | prn_org_code | STRING | X |  |  |  | Mã tổ chức cha |
| 12 | rprs_nm | STRING | X |  |  |  | Người đại diện |
| 13 | charter_cptl_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ |
| 14 | license_nbr | STRING | X |  |  |  | Số giấy phép hoạt động |
| 15 | license_issur | STRING | X |  |  |  | Cơ quan cấp giấy phép |
| 16 | license_dt | DATE | X |  |  |  | Ngày cấp giấy phép |
| 17 | webst | STRING | X |  |  |  | Địa chỉ website |
| 18 | org_dsc | STRING | X |  |  |  | Mô tả |
| 19 | org_st_code | STRING | X |  |  |  | Trạng thái |
| 20 | sort_ordr | INT | X |  |  |  | Thứ tự sắp xếp |
| 21 | linked_id | STRING | X |  |  |  | ID liên kết |
| 22 | sync_id | STRING | X |  |  |  | Mã đồng bộ |
| 23 | last_sync_dt | DATE | X |  |  |  | Lần cuối đồng bộ |
| 24 | sync_st_code | STRING | X |  |  |  | Trạng thái đồng bộ |
| 25 | crt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer |
| 26 | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo |
| 27 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo |
| 28 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_org_refr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prn_org_id | scr_org_refr | scr_org_refr_id |
| crt_by_ofcr_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | prac_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | prac_code | STRING |  |  |  |  | Mã định danh người hành nghề (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.Professionals' | Mã nguồn dữ liệu |
| 4 | full_nm | STRING | X |  |  |  | Họ và tên |
| 5 | brth_yr | STRING | X |  |  |  | Năm sinh |
| 6 | dob | DATE | X |  |  |  | Ngày sinh đầy đủ (ngày/tháng/năm) |
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
| 20 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo |
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




### Bảng scr_prac_rel_p



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_prac_rel_p_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | scr_prac_rel_p_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.ProfessionalRelationships' | Mã nguồn dữ liệu |
| 4 | prac_id | STRING |  |  | F |  | FK đến Securities Practitioner |
| 5 | prac_code | STRING |  |  |  |  | Mã người hành nghề |
| 6 | rel_p_full_nm | STRING | X |  |  |  | Họ và tên người liên quan |
| 7 | rltnp_tp_code | STRING | X |  |  |  | Quan hệ (1: Vợ/Chồng, 2: Con, 3: Bố, 4: Mẹ, 5: Ông, 6: Bà) |
| 8 | brth_yr | STRING | X |  |  |  | Năm sinh |
| 9 | cty_code | STRING | X |  |  |  | Quốc gia |
| 10 | id_refr_code | STRING | X |  | F |  | Mã định danh giấy tờ tùy thân |
| 11 | adr | STRING | X |  |  |  | Địa chỉ |
| 12 | ocp_nm | STRING | X |  |  |  | Nghề nghiệp |
| 13 | workplace_nm | STRING | X |  |  |  | Nơi làm việc |
| 14 | rel_p_note | STRING | X |  |  |  | Ghi chú |
| 15 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_prac_rel_p_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prac_id | scr_prac | prac_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_license_ap_fee



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | license_ap_fee_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | license_ap_fee_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.ApplicationFees' | Mã nguồn dữ liệu |
| 4 | license_ap_id | STRING |  |  | F |  | FK đến hồ sơ |
| 5 | license_ap_code | STRING |  |  |  |  | Mã hồ sơ |
| 6 | prac_id | STRING | X |  | F |  | FK đến Securities Practitioner |
| 7 | prac_code | STRING | X |  |  |  | Mã người hành nghề |
| 8 | fee_tp_code | STRING | X |  |  |  | Loại phí |
| 9 | fee_amt | DECIMAL(23,2) | X |  |  |  | Số tiền phí (VNĐ) |
| 10 | fee_cntnt | STRING | X |  |  |  | Nội dung phí |
| 11 | fee_note | STRING | X |  |  |  | Ghi chú |
| 12 | pymt_st_code | STRING | X |  |  |  | Trạng thái thanh toán |
| 13 | rqs_dt | DATE | X |  |  |  | Ngày yêu cầu thanh toán |
| 14 | pymt_dt | DATE | X |  |  |  | Ngày thanh toán |
| 15 | expiry_dt | DATE | X |  |  |  | Ngày hết hạn thanh toán |
| 16 | crt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer |
| 17 | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo |
| 18 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo |
| 19 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| license_ap_fee_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| license_ap_id | scr_prac_license_ap | license_ap_id |
| prac_id | scr_prac | prac_id |
| crt_by_ofcr_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng ip_alt_identn



#### Từ NHNCK.Professionals

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Securities Practitioner |
| 2 | ip_code | STRING |  |  |  |  | Mã người hành nghề |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.Professionals' | Mã nguồn dữ liệu |
| 4 | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ định danh — CCCD/CMND |
| 5 | identn_nbr | STRING | X |  |  |  | Mã định danh giấy tờ tùy thân (FK bảng identity riêng) |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp CCCD/Hộ chiếu. |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp CCCD/Hộ chiếu. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_prac | prac_id |



**Index:** N/A

**Trigger:** N/A


#### Từ NHNCK.Organizations

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Securities Organization Reference |
| 2 | ip_code | STRING |  |  |  |  | Mã tổ chức |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.Organizations' | Mã nguồn dữ liệu |
| 4 | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ — Số giấy phép hoạt động |
| 5 | identn_nbr | STRING | X |  |  |  | Số giấy phép hoạt động |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Cơ quan cấp giấy phép |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_org_refr | scr_org_refr_id |



**Index:** N/A

**Trigger:** N/A





### Bảng ip_elc_adr



#### Từ NHNCK.Professionals

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Securities Practitioner |
| 2 | ip_code | STRING |  |  |  |  | Mã người hành nghề |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.Professionals' | Mã nguồn dữ liệu |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_prac | prac_id |



**Index:** N/A

**Trigger:** N/A


#### Từ NHNCK.Organizations

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Securities Organization Reference |
| 2 | ip_code | STRING |  |  |  |  | Mã tổ chức |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.Organizations' | Mã nguồn dữ liệu |
| 4 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — email |
| 5 | elc_adr_val | STRING | X |  |  |  | Email |
| 6 | ip_id | STRING |  |  | F |  | FK đến Securities Organization Reference |
| 7 | ip_code | STRING |  |  |  |  | Mã tổ chức |
| 8 | src_stm_code | STRING |  |  |  | 'NHNCK.Organizations' | Mã nguồn dữ liệu |
| 9 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — fax |
| 10 | elc_adr_val | STRING | X |  |  |  | Fax |
| 11 | ip_id | STRING |  |  | F |  | FK đến Securities Organization Reference |
| 12 | ip_code | STRING |  |  |  |  | Mã tổ chức |
| 13 | src_stm_code | STRING |  |  |  | 'NHNCK.Organizations' | Mã nguồn dữ liệu |
| 14 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — số di động |
| 15 | elc_adr_val | STRING | X |  |  |  | Số di động |
| 16 | ip_id | STRING |  |  | F |  | FK đến Securities Organization Reference |
| 17 | ip_code | STRING |  |  |  |  | Mã tổ chức |
| 18 | src_stm_code | STRING |  |  |  | 'NHNCK.Organizations' | Mã nguồn dữ liệu |
| 19 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — điện thoại |
| 20 | elc_adr_val | STRING | X |  |  |  | Số điện thoại |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_org_refr | scr_org_refr_id |



**Index:** N/A

**Trigger:** N/A





### Bảng ip_pst_adr



#### Từ NHNCK.Professionals

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Securities Practitioner |
| 2 | ip_code | STRING |  |  |  |  | Mã người hành nghề |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.Professionals' | Mã nguồn dữ liệu |
| 4 | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ — địa chỉ chung |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ |
| 6 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_prac | prac_id |



**Index:** N/A

**Trigger:** N/A


#### Từ NHNCK.Organizations

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Securities Organization Reference |
| 2 | ip_code | STRING |  |  |  |  | Mã tổ chức |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.Organizations' | Mã nguồn dữ liệu |
| 4 | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ — trụ sở chính |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ tổ chức |
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
| ip_id | scr_org_refr | scr_org_refr_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A





### Stored Procedure/Function

N/A

### Package

N/A
