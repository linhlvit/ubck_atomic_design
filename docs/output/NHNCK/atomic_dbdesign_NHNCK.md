# CƠ SỞ DỮ LIỆU (OLTP)


## NHNCK — Hệ thống Quản lý giám sát người hành nghề chứng khoán

### Các mô hình quan hệ dữ liệu

![Mô hình quan hệ dữ liệu NHNCK](NHNCK/fragments/NHNCK_diagram.png)

**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | scr_prac_conduct_vln | Vi phạm pháp luật hoặc hành chính của người hành nghề chứng khoán được ghi nhận kèm quyết định xử lý. Mỗi dòng = 1 sự kiện vi phạm insert-only. FK đến Practitioner và Decision. |
| 2 | scr_prac_prof_trn_clss_enrollment | Đăng ký tham gia và kết quả học tập của người hành nghề tại một khóa đào tạo chuyên môn. Ghi nhận điểm thi, kết quả đạt/không đạt và trạng thái ghi danh. |
| 3 | scr_prac_qualf_exam_ases | Đợt thi sát hạch cấp CCHN do UBCKNN tổ chức. Ghi nhận thời gian đăng ký và thi, địa điểm, hình thức nộp hồ sơ, quyết định công nhận kết quả và phí thi. |
| 4 | scr_prac_qualf_exam_ases_rslt | Kết quả thi sát hạch của từng thí sinh trong một đợt thi. Ghi nhận điểm thi luật, điểm chuyên môn, kết quả từng phần và kết quả tổng thể. FK đến Exam Assessment và Practitioner. |
| 5 | scr_prac_qualf_exam_ases_fee | Biểu phí thi sát hạch quy định cho từng loại CCHN trong từng đợt thi (Condition). Phân biệt với License Application Fee là phí thực tế thu từng hồ sơ (Transaction). |
| 6 | scr_prac_license_ap | Hồ sơ đăng ký chứng chỉ hành nghề chứng khoán. Ghi nhận loại đăng ký, loại hồ sơ, trạng thái, ngày nộp, CCHN liên quan và kết quả thi. FK đến Practitioner và Officer phụ trách. |
| 7 | scr_prac_license_ap_ed_ctf_doc | Chứng chỉ hoặc bằng chuyên môn đào tạo đính kèm trong hồ sơ đăng ký CCHN. Ghi nhận loại chuyên môn, file đính kèm, trạng thái thẩm định và cán bộ thẩm định. |
| 8 | scr_prac_license_ap_re-exam_rqs | Liên kết theo dõi chu trình thi lại — hồ sơ gốc, kết quả thi trượt và hồ sơ đăng ký thi lại mới (nullable nếu chưa nộp). FK đến License Application (×2) và Exam Assessment Result. |
| 9 | scr_prac_license_ctf_doc | Chứng chỉ hành nghề chứng khoán được cấp cho người hành nghề. Ghi nhận số CCHN, loại, ngày cấp, trạng thái và 3 quyết định liên quan (cấp/thu hồi/hủy). FK đến Practitioner. |
| 10 | scr_prac_license_dcsn_doc | Quyết định hành chính do UBCKNN ban hành liên quan đến CCHN — cấp, thu hồi, hủy CCHN hoặc công nhận kết quả thi. Ghi nhận số quyết định, loại, ngày ký và người ký. |
| 11 | scr_prac_org_emp_rpt | Báo cáo của tổ chức về tình trạng làm việc của người hành nghề. Mỗi dòng = 1 lần nộp báo cáo insert-only. Ghi nhận loại báo cáo, trạng thái làm việc, chức vụ và ngày báo cáo. |
| 12 | scr_prac_prof_trn_clss | Khóa học chuyên môn bổ sung kiến thức cho người hành nghề chứng khoán. Master entity của khóa học — ghi nhận mã, tên, loại chuyên môn, thời gian và địa điểm thi. |
| 13 | reg_ahr_ofcr | Cán bộ, chuyên viên UBCKNN có tài khoản trong hệ thống NHNCK. Ghi nhận thông tin nhân sự, đơn vị/phòng ban phụ trách và trạng thái tài khoản. Không lưu thông tin xác thực (PASSWORD). |
| 14 | reg_ahr_ou | Đơn vị và phòng ban thuộc UBCKNN — cấu trúc cây self-referencing DEPARTMENT → UNIT. Phân biệt bằng Organization Unit Type Code (ETL-derived). Dùng chung làm FK tổ chức nội bộ. |
| 15 | scr_org_refr | Tổ chức tham gia thị trường chứng khoán được UBCKNN quản lý (CTCK, QLQ, Ngân hàng, v.v.). Ghi nhận mã tổ chức, tên, loại hình, vốn điều lệ và trạng thái hoạt động. |
| 16 | scr_prac | Người hành nghề chứng khoán được UBCKNN quản lý. Ghi nhận thông tin nhân thân và trạng thái hành nghề. |
| 17 | scr_prac_emp_st | Giai đoạn làm việc của người hành nghề tại một tổ chức chứng khoán. Ghi nhận tổ chức, chức vụ, phòng ban, ngày bắt đầu và ngày kết thúc (NULL = đang làm việc). |
| 18 | scr_prac_license_ap_emp_exrnc | Kinh nghiệm làm việc khai báo trong hồ sơ đăng ký CCHN. Ghi nhận tổ chức, thời gian làm việc, chức vụ, phòng ban, số BHXH và thông tin hợp đồng lao động. |
| 19 | scr_prac_license_ap_snpst | Snapshot thông tin nhân thân của người đăng ký tại thời điểm nộp hồ sơ. Denormalize toàn bộ trường định danh, địa chỉ và liên lạc từ Practitioner. Loại bỏ USERNAME/PASSWORD. |
| 20 | scr_prac_prof_trn_hist | Lịch sử đào tạo và bồi dưỡng của người hành nghề chứng khoán. Ghi nhận thời gian, địa điểm đào tạo, chuyên ngành, khen thưởng và kỷ luật. FK đến Practitioner. |
| 21 | scr_prac_rel_p | Quan hệ thân nhân của người hành nghề chứng khoán. Ghi nhận loại quan hệ, họ tên, năm sinh, địa chỉ, nghề nghiệp và số giấy tờ định danh của người thân. |
| 22 | geo | Đơn vị địa lý dùng làm FK tham chiếu: quốc gia/quốc tịch (COUNTRY), vùng/miền (REGION), tỉnh/thành phố mới/cũ (PROVINCE/PROVINCE_OLD), quận/huyện cũ (DISTRICT_OLD), phường/xã mới/cũ (WARD/WARD_OLD). Phân biệt bằng geographic_area_type_code. Hỗ trợ song song bộ danh mục pre- và post-sáp nhập hành chính 2025. |
| 23 | scr_prac_license_ap_fee | Phí thực tế phát sinh cho hồ sơ đăng ký CCHN — phí nộp hồ sơ, phí cấp CCHN (Transaction). Có lifecycle riêng qua trạng thái thanh toán. Phân biệt với Examination Assessment Fee (Condition). |
| 24 | ip_alt_identn | Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn. |
| 25 | ip_elc_adr | Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn. |
| 26 | ip_pst_adr | Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn. |




### Bảng scr_prac_conduct_vln



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_prac_conduct_vln_id | STRING |  | X | P |  | Khóa đại diện cho bản ghi vi phạm đạo đức hành nghề (surrogate key). |
| 2 | scr_prac_conduct_vln_code | STRING |  |  |  |  | Mã định danh kỹ thuật tự tăng. BK của entity. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.VIOLATIONS' | Mã hệ thống nguồn. |
| 4 | scr_prac_id | STRING |  |  | F |  | FK đến người hành nghề chứng khoán bị vi phạm. |
| 5 | scr_prac_code | STRING |  |  |  |  | Mã người hành nghề chứng khoán bị vi phạm. |
| 6 | license_dcsn_doc_id | STRING | X |  | F |  | FK đến quyết định xử lý vi phạm. |
| 7 | license_dcsn_doc_code | STRING | X |  |  |  | Mã quyết định xử lý vi phạm. |
| 8 | prac_nm_at_vln | STRING | X |  |  |  | Họ tên người hành nghề tại thời điểm vi phạm (snapshot). |
| 9 | prac_brth_dt_at_vln | DATE | X |  |  |  | Ngày sinh người hành nghề tại thời điểm vi phạm (snapshot). |
| 10 | prac_id_nbr_at_vln | STRING | X |  |  |  | Số CMND/CCCD người hành nghề tại thời điểm vi phạm (snapshot). |
| 11 | vln_rcrd_dt | TIMESTAMP |  |  |  |  | Ngày ghi nhận vi phạm (business event date). |
| 12 | note | STRING | X |  |  |  | Ghi chú vi phạm. |
| 13 | rcrd_tp_code | STRING | X |  |  |  | Phân loại bản ghi. |
| 14 | rcrd_st_code | STRING |  |  |  |  | Trạng thái bản ghi vi phạm (1=Hoạt động). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_prac_conduct_vln_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_prac_id | scr_prac | scr_prac_id |
| license_dcsn_doc_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_prof_trn_clss_enrollment



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_prac_prof_trn_clss_enrollment_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | scr_prac_prof_trn_clss_enrollment_code | STRING |  |  |  |  | Mã định danh (BK từ PK nguồn) |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.SPECIALIZATION_COURSE_DETAILS' | Mã nguồn dữ liệu |
| 4 | scr_prac_prof_trn_clss_id | STRING |  |  | F |  | FK đến lớp đào tạo nghiệp vụ chứng khoán |
| 5 | scr_prac_prof_trn_clss_code | STRING |  |  |  |  | Mã lớp đào tạo |
| 6 | scr_prac_id | STRING |  |  | F |  | FK đến người hành nghề chứng khoán |
| 7 | scr_prac_code | STRING |  |  |  |  | Mã người hành nghề |
| 8 | specialization_tp_code | STRING |  |  |  |  | Loại chuyên ngành đào tạo |
| 9 | exam_nbr | STRING | X |  |  |  | Số báo danh dự thi |
| 10 | prac_nm_at_enrollment | STRING | X |  |  |  | Họ tên học viên tại thời điểm đăng ký (snapshot) |
| 11 | prac_brth_dt_at_enrollment | DATE | X |  |  |  | Ngày sinh tại thời điểm đăng ký (snapshot) |
| 12 | plc_of_brth | STRING | X |  |  |  | Nơi sinh (snapshot) |
| 13 | perm_rsdnc_cty_id | STRING | X |  | F |  | FK đến quốc gia thường trú (snapshot) |
| 14 | perm_rsdnc_cty_code | STRING | X |  |  |  | Mã quốc gia thường trú |
| 15 | perm_rsdnc_prov_id | STRING | X |  | F |  | FK đến tỉnh/thành thường trú (snapshot) |
| 16 | perm_rsdnc_prov_code | STRING | X |  |  |  | Mã tỉnh/thành thường trú |
| 17 | perm_rsdnc_dstc_id | STRING | X |  | F |  | FK đến quận/huyện thường trú (snapshot) |
| 18 | perm_rsdnc_dstc_code | STRING | X |  |  |  | Mã quận/huyện thường trú |
| 19 | prac_id_tp_code_at_enrollment | STRING | X |  |  |  | Loại giấy tờ định danh tại thời điểm đăng ký (snapshot) |
| 20 | prac_id_nbr_at_enrollment | STRING | X |  |  |  | Số định danh tại thời điểm đăng ký (snapshot) |
| 21 | prac_id_issu_dt_at_enrollment | DATE | X |  |  |  | Ngày cấp giấy tờ định danh (snapshot) |
| 22 | prac_id_issu_plc_at_enrollment | STRING | X |  |  |  | Nơi cấp giấy tờ định danh (snapshot) |
| 23 | exam_scor | DECIMAL(5,2) | X |  |  |  | Điểm thi |
| 24 | trn_rslt_code | STRING | X |  |  |  | Kết quả đào tạo (-1=Không thi, 0=Không đạt, 1=Đạt) |
| 25 | rcrd_st_code | STRING | X |  |  |  | Trạng thái bản ghi |
| 26 | dsc | STRING | X |  |  |  | Mô tả |
| 27 | note | STRING | X |  |  |  | Ghi chú |
| 28 | assignee_ofcr_id | STRING | X |  | F |  | FK đến cán bộ phụ trách (nullable) |
| 29 | assignee_ofcr_code | STRING | X |  |  |  | Mã cán bộ phụ trách |
| 30 | crt_tms | TIMESTAMP | X |  |  |  | Thời điểm tạo bản ghi |
| 31 | udt_tms | TIMESTAMP | X |  |  |  | Thời điểm cập nhật bản ghi |
| 32 | crt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer tạo bản ghi |
| 33 | udt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer cập nhật bản ghi |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_prac_prof_trn_clss_enrollment_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_prac_prof_trn_clss_id | scr_prac_prof_trn_clss | scr_prac_prof_trn_clss_id |
| scr_prac_id | scr_prac | scr_prac_id |
| perm_rsdnc_cty_id | geo | geo_id |
| perm_rsdnc_prov_id | geo | geo_id |
| perm_rsdnc_dstc_id | geo | geo_id |
| assignee_ofcr_id | reg_ahr_ofcr | reg_ahr_ofcr_id |
| crt_by_ofcr_id | reg_ahr_ofcr | reg_ahr_ofcr_id |
| udt_by_ofcr_id | reg_ahr_ofcr | reg_ahr_ofcr_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_qualf_exam_ases



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_prac_qualf_exam_ases_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | scr_prac_qualf_exam_ases_code | STRING |  |  |  |  | Mã định danh nghiệp vụ đợt thi. BK |
| 3 | ases_nm | STRING | X |  |  |  | Tên hiển thị đợt thi |
| 4 | rpt_yr | INT | X |  |  |  | Năm báo cáo (YYYY) |
| 5 | exam_ssn_nbr | 2…) |  | X | P |  | Kỳ thi trong năm (1 |
| 6 | organizing_unit_nm | STRING | X |  |  |  | Tên đơn vị tổ chức thi |
| 7 | ap_rgst_strt_dt | STRING | X |  |  |  | Ngày bắt đầu nhận đăng ký |
| 8 | ap_rgst_end_dt | STRING | X |  |  |  | Ngày kết thúc nhận đăng ký |
| 9 | exam_strt_dt | STRING | X |  |  |  | Ngày bắt đầu thi |
| 10 | exam_end_dt | STRING | X |  |  |  | Ngày kết thúc thi |
| 11 | rslt_notf_dt | STRING | X |  |  |  | Ngày thông báo kết quả thi |
| 12 | exam_locations | STRING | X |  |  |  | Địa điểm tổ chức thi |
| 13 | subm_methods | STRING | X |  |  |  | Phương thức nộp hồ sơ |
| 14 | notf_file_path | STRING | X |  |  |  | Đường dẫn file thông báo kết quả |
| 15 | license_dcsn_id | STRING | X |  | F |  | FK đến quyết định cấp chứng chỉ liên quan đợt thi |
| 16 | license_dcsn_code | STRING | X |  |  |  | Mã quyết định cấp chứng chỉ |
| 17 | bnk_code | STRING | X |  |  |  | Mã ngân hàng thu phí |
| 18 | bnk_ac_nbr | STRING | X |  |  |  | Số tài khoản ngân hàng thu phí |
| 19 | bnk_ac_nm | STRING | X |  |  |  | Tên chủ tài khoản ngân hàng thu phí |
| 20 | rcrd_st_code | STRING | X |  |  |  | Trạng thái đợt thi (1=Hoạt động) |
| 21 | src_stm_code | STRING |  |  |  | 'NHNCK.EXAM_SESSIONS' | Mã hệ thống nguồn |
| 22 | crt_tms | TIMESTAMP | X |  |  |  | Thời điểm tạo bản ghi |
| 23 | udt_tms | TIMESTAMP | X |  |  |  | Thời điểm cập nhật bản ghi |
| 24 | crt_by_ofcr_id | STRING | X |  | F |  | FK đến người tạo |
| 25 | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo |
| 26 | udt_by_ofcr_id | STRING | X |  | F |  | FK đến người cập nhật |
| 27 | udt_by_ofcr_code | STRING | X |  |  |  | Mã người cập nhật |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_prac_qualf_exam_ases_id |
| exam_ssn_nbr |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| license_dcsn_id | scr_prac_license_dcsn_doc | scr_prac_license_dcsn_doc_id |
| crt_by_ofcr_id | reg_ahr_ofcr | reg_ahr_ofcr_id |
| udt_by_ofcr_id | reg_ahr_ofcr | reg_ahr_ofcr_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_qualf_exam_ases_rslt



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_prac_qualf_exam_ases_rslt_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | scr_prac_qualf_exam_ases_rslt_code | STRING |  |  |  |  | Mã định danh nghiệp vụ. BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.EXAM_DETAILS' | Mã nguồn dữ liệu |
| 4 | scr_prac_qualf_exam_ases_id | STRING |  |  | F |  | FK đến đợt thi sát hạch |
| 5 | scr_prac_qualf_exam_ases_code | STRING |  |  |  |  | Mã đợt thi sát hạch |
| 6 | scr_prac_id | STRING |  |  | F |  | FK đến người hành nghề |
| 7 | scr_prac_code | STRING |  |  |  |  | Mã người hành nghề |
| 8 | ctf_tp_code | STRING |  |  |  |  | Mã loại chứng chỉ dự thi |
| 9 | license_ap_id | STRING | X |  | F |  | FK đến hồ sơ đăng ký |
| 10 | license_ap_code | STRING | X |  |  |  | Mã hồ sơ đăng ký |
| 11 | seq_nbr | INT | X |  |  |  | Số thứ tự dự thi trong đợt thi |
| 12 | exam_nbr | STRING | X |  |  |  | Số báo danh |
| 13 | law_scor | INT | X |  |  |  | Điểm thi pháp luật |
| 14 | law_rslt_code | STRING | X |  |  |  | Kết quả thi pháp luật (-1: Không thi, 0: Không đạt, 1: Đạt) |
| 15 | specialization_scor | INT | X |  |  |  | Điểm thi chuyên ngành |
| 16 | specialization_rslt_code | STRING | X |  |  |  | Kết quả thi chuyên ngành (-1: Không thi, 0: Không đạt, 1: Đạt) |
| 17 | ovrl_rslt_code | STRING | X |  |  |  | Kết quả thi tổng thể (-1: Không thi, 0: Không đạt, 1: Đạt) |
| 18 | exam_note | STRING | X |  |  |  | Ghi chú |
| 19 | crt_at | TIMESTAMP | X |  |  |  | Thời điểm tạo bản ghi |
| 20 | udt_at | TIMESTAMP | X |  |  |  | Thời điểm cập nhật bản ghi |
| 21 | crt_by | STRING | X |  |  |  | Người tạo bản ghi |
| 22 | udt_by | STRING | X |  |  |  | Người cập nhật bản ghi |
| 23 | --- |  |  |  |  |  |  |
| 24 | **giải_thích_các_quyết_định_thiết_kế:** |  |  |  |  |  |  |
| 25 | 1._**law_scor_x_specialization_scor_→_sml_counter**_(không_phải_text):_theo_yêu_cầu_trong_prompt;_khác_với_file_examdetails_cũ_dùng_tx_—_file_cũ_có_cmnt_giải_thích_có_thể_dạng_tx |  |  |  |  |  |  nhưng bảng EXAM_DETAILS nguồn khai báo kiểu NUMBER nên Small Counter phù hợp hơn. |
| 26 | 2._**law_rslt_x_specialization_rslt_→_cv_(exam_score_result)**_thay_vì_boolean:_vì_giá_trị_có_3_trạng_thái_(-1/0/1) |  |  |  |  |  |  Boolean chỉ đủ cho 2 trạng thái. Scheme EXAM_SCORE_RESULT là scheme mới đã liệt kê trong danh sách "SCHEMES MỚI CẦN THÊM". |
| 27 | 3._**overall_rslt_→_examination_result**_(scheme_đã_có)_thay_vì_exam_score_result:_theo_yêu_cầu_trong_prmpt |  |  |  |  |  |  giữ nhất quán với các entity khác dùng EXAMINATION_RESULT cho kết quả tổng thể. |
| 28 | 4._**created_at/updated_at/created_by/updated_by_→_status:_pending**:_theo_yêu_cầu;_chưa_xác_định_fk_mapping_cho_created_by/updated_by_nên_để_pndg_toàn_bộ_nhóm_audt |  |  |  |  |  |  với data_domain tạm là Text (chưa resolve FK). |
| 29 | 5._**grain_không_phải_i_party**_→_không_tách_shared_entity. |  |  |  |  |  |  |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_prac_qualf_exam_ases_rslt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_prac_qualf_exam_ases_id | scr_prac_qualf_exam_ases | scr_prac_qualf_exam_ases_id |
| scr_prac_id | scr_prac | scr_prac_id |
| license_ap_id | scr_prac_license_ap |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_qualf_exam_ases_fee



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_prac_qualf_exam_ases_fee_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | scr_prac_qualf_exam_ases_fee_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.EXAM_SESSION_FEES' | Mã nguồn dữ liệu |
| 4 | exam_ases_id | STRING |  |  | F |  | FK đến đợt thi (Exam Assessment) |
| 5 | exam_ases_code | STRING |  |  |  |  | Mã đợt thi |
| 6 | ctf_tp_code | STRING |  |  |  |  | Mã loại chứng chỉ |
| 7 | exam_fee_amt | DECIMAL(23,2) | X |  |  |  | Mức phí dự thi (VNĐ) |
| 8 | appeal_fee_amt | DECIMAL(23,2) | X |  |  |  | Mức phí phúc khảo (VNĐ) |
| 9 | rcrd_st_code | STRING | X |  |  |  | Trạng thái bản ghi |
| 10 | crt_tms | TIMESTAMP | X |  |  |  | Thời điểm tạo |
| 11 | udt_tms | TIMESTAMP | X |  |  |  | Thời điểm cập nhật |
| 12 | crt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer (người tạo) |
| 13 | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo |
| 14 | udt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer (người cập nhật) |
| 15 | udt_by_ofcr_code | STRING | X |  |  |  | Mã người cập nhật |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_prac_qualf_exam_ases_fee_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| exam_ases_id | scr_prac_qualf_exam_ases |  |
| crt_by_ofcr_id | reg_ahr_ofcr |  |
| udt_by_ofcr_id | reg_ahr_ofcr |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_license_ap



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_prac_license_ap_id | STRING |  | X | P |  | Id tự sinh (surrogate key). |
| 2 | scr_prac_license_ap_code | STRING |  |  |  |  | Mã hồ sơ đăng ký do hệ thống sinh — BK của entity. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.APPLICATIONS' | Mã hệ thống nguồn. |
| 4 | ap_tp_code | STRING |  |  |  |  | Loại hồ sơ. |
| 5 | ap_st_code | STRING |  |  | F |  | Trạng thái hồ sơ hiện tại. |
| 6 | rgst_tp_code | STRING |  |  |  |  | Nguồn tiếp nhận hồ sơ. |
| 7 | ctf_tp_code | STRING |  |  | F |  | Loại chứng chỉ hành nghề đăng ký. |
| 8 | ttl | STRING | X |  |  |  | Tiêu đề hoặc tên nhóm hồ sơ. |
| 9 | subm_dt | DATE | X |  |  |  | Ngày nộp hồ sơ chính thức. |
| 10 | supplement_dt | DATE | X |  |  |  | Ngày nộp bổ sung hồ sơ. |
| 11 | supplement_ltr_dt | DATE | X |  |  |  | Ngày ban hành công văn yêu cầu bổ sung hồ sơ. |
| 12 | ctf_nbr | STRING | X |  |  |  | Số CCHN cấp cho người hành nghề. |
| 13 | issu_dt | DATE | X |  |  |  | Ngày cấp CCHN. |
| 14 | prev_ctf_nbr | STRING | X |  |  |  | Số CCHN cũ trước khi cấp lại. |
| 15 | prev_issu_dt | DATE | X |  |  |  | Ngày cấp CCHN cũ. |
| 16 | prev_ctf_tp_code | STRING | X |  | F |  | Loại CCHN cũ khi cấp lại. |
| 17 | reissue_rsn | STRING | X |  |  |  | Lý do xin cấp lại CCHN. |
| 18 | rejection_rsn | STRING | X |  |  |  | Lý do trả lại hoặc từ chối hồ sơ. |
| 19 | ctf_recpt_mth_code | STRING | X |  |  |  | Phương thức nhận CCHN. |
| 20 | ctf_recpt_adr | STRING | X |  |  |  | Địa chỉ nhận CCHN qua bưu điện. |
| 21 | ctf_recpt_ph | STRING | X |  |  |  | Số điện thoại liên lạc khi nhận CCHN. |
| 22 | recpt_st_code | STRING | X |  |  |  | Trạng thái nhận CCHN. |
| 23 | violated_ind | BOOLEAN | X |  |  |  | Cờ người hành nghề vi phạm quy định. |
| 24 | data_exploitable_ind | BOOLEAN | X |  |  |  | Cờ dữ liệu có thể khai thác. |
| 25 | reissue_hsm | STRING | X |  |  |  | Thông tin HSM khi cấp CCHN điện tử. |
| 26 | note | STRING | X |  |  |  | Ghi chú bổ sung. |
| 27 | scr_prac_id | STRING |  |  | F |  | FK đến Securities Practitioner. |
| 28 | scr_prac_code | STRING |  |  |  |  | Mã người hành nghề. |
| 29 | license_ctf_doc_id | STRING | X |  | F |  | FK đến License Certificate Document (CCHN trong sổ đăng bộ). |
| 30 | license_ctf_doc_code | STRING | X |  |  |  | Mã CCHN trong sổ đăng bộ. |
| 31 | prev_license_ctf_doc_id | STRING | X |  | F |  | FK đến CCHN cũ (khi cấp lại). |
| 32 | prev_license_ctf_doc_code | STRING | X |  |  |  | Mã CCHN cũ. |
| 33 | exam_ases_id | STRING | X |  | F |  | FK đến Exam Session (đợt thi sát hạch liên quan — nullable). |
| 34 | exam_ases_code | STRING | X |  |  |  | Mã đợt thi sát hạch. |
| 35 | assignee_ofcr_id | STRING | X |  | F |  | FK đến Regulatory Authority Officer — cán bộ được phân công xử lý hồ sơ. |
| 36 | assignee_ofcr_code | STRING | X |  |  |  | Mã cán bộ được phân công. |
| 37 | info_verify_ofcr_id | STRING | X |  | F |  | FK đến Regulatory Authority Officer — cán bộ xác minh thông tin. |
| 38 | info_verify_ofcr_code | STRING | X |  |  |  | Mã cán bộ xác minh thông tin. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_prac_license_ap_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_prac_id | scr_prac | scr_prac_id |
| license_ctf_doc_id | scr_prac_license_ctf_doc | scr_prac_license_ctf_doc_id |
| prev_license_ctf_doc_id | scr_prac_license_ctf_doc | scr_prac_license_ctf_doc_id |
| exam_ases_id | scr_prac_qualf_exam_ases | scr_prac_qualf_exam_ases_id |
| assignee_ofcr_id | reg_ahr_ofcr | reg_ahr_ofcr_id |
| info_verify_ofcr_id | reg_ahr_ofcr | reg_ahr_ofcr_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_license_ap_ed_ctf_doc



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_prac_license_ap_ed_ctf_doc_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | scr_prac_license_ap_ed_ctf_doc_code | STRING |  |  |  |  | Mã định danh bản ghi chuyên môn. BK |
| 3 | license_ap_id | STRING |  |  | F |  | FK đến License Application (hồ sơ đăng ký) |
| 4 | license_ap_code | STRING |  |  |  |  | Mã hồ sơ đăng ký. Lookup pair |
| 5 | specialization_tp_code | STRING |  |  |  |  | Mã loại chuyên môn (Classification Value) |
| 6 | ctf_issu_dt | DATE | X |  |  |  | Ngày cấp chứng chỉ chuyên môn |
| 7 | ctf_issu_plc | STRING | X |  |  |  | Nơi cấp chứng chỉ chuyên môn |
| 8 | aprs_st_code | STRING |  |  |  |  | Trạng thái thẩm định chứng chỉ (Classification Value) |
| 9 | aprs_completed_dt | TIMESTAMP | X |  |  |  | Thời điểm thẩm định hoàn tất |
| 10 | appraised_by_ofcr_id | STRING | X |  | F |  | FK đến cán bộ thẩm định (Regulatory Authority Officer) |
| 11 | appraised_by_ofcr_code | STRING | X |  |  |  | Mã cán bộ thẩm định. Lookup pair |
| 12 | attch_files | STRING | X |  |  |  | Danh sách file đính kèm (JSON CLOB) |
| 13 | note | STRING | X |  |  |  | Ghi chú bổ sung |
| 14 | src_stm_code | STRING |  |  |  | 'NHNCK.APPLICATION_SPECIALIZATIONS' | Mã hệ thống nguồn (ETL-derived) |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_prac_license_ap_ed_ctf_doc_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| license_ap_id |  |  |
| appraised_by_ofcr_id | reg_ahr_ofcr | reg_ahr_ofcr_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_license_ap_re-exam_rqs



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_prac_license_ap_re-exam_rqs_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | scr_prac_license_ap_re-exam_rqs_code | STRING |  |  |  |  | Mã định danh. BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.APPLICATION_RE_EXAMS' | Mã nguồn dữ liệu |
| 4 | license_ap_id | STRING |  |  | F |  | FK đến hồ sơ gốc đã thi trượt |
| 5 | license_ap_code | STRING |  |  |  |  | Mã hồ sơ gốc |
| 6 | exam_ases_rslt_id | STRING |  |  | F |  | FK đến kết quả thi trượt |
| 7 | exam_ases_rslt_code | STRING |  |  |  |  | Mã kết quả thi trượt |
| 8 | re-exam_license_ap_id | STRING | X |  | F |  | FK đến hồ sơ thi lại mới (nullable — chưa nộp) |
| 9 | re-exam_license_ap_code | STRING | X |  |  |  | Mã hồ sơ thi lại mới |
| 10 | rcrd_st_code | STRING |  |  |  |  | Trạng thái bản ghi (1=Hoạt động) |
| 11 | crt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer tạo bản ghi |
| 12 | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo |
| 13 | udt_by_ofcr_id | STRING | X |  | F |  | FK đến Officer cập nhật bản ghi |
| 14 | udt_by_ofcr_code | STRING | X |  |  |  | Mã người cập nhật |
| 15 | crt_tms | TIMESTAMP | X |  |  |  | Thời điểm tạo |
| 16 | udt_tms | TIMESTAMP | X |  |  |  | Thời điểm cập nhật |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_prac_license_ap_re-exam_rqs_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| license_ap_id | scr_prac_license_ap |  |
| exam_ases_rslt_id | scr_prac_qualf_exam_ases_rslt |  |
| re-exam_license_ap_id | scr_prac_license_ap |  |
| crt_by_ofcr_id | reg_ahr_ofcr |  |
| udt_by_ofcr_id | reg_ahr_ofcr |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_license_ctf_doc



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_prac_license_ctf_doc_id | STRING |  | X | P |  | Surrogate key cho chứng chỉ hành nghề chứng khoán |
| 2 | scr_prac_license_ctf_doc_code | STRING |  |  |  |  | Business key từ CERTIFICATE_RECORDS.ID |
| 3 | ctf_nbr | STRING |  |  |  |  | Số chứng chỉ hành nghề |
| 4 | ctf_tp_code | STRING |  |  |  |  | Phân loại loại chứng chỉ (CCHN) |
| 5 | scr_prac_id | STRING |  |  | F |  | FK đến Securities Practitioner |
| 6 | scr_prac_code | STRING |  |  |  |  | Mã nghiệp vụ của người hành nghề |
| 7 | issu_license_dcsn_id | STRING |  |  | F |  | FK đến quyết định cấp chứng chỉ |
| 8 | issu_license_dcsn_code | STRING |  |  |  |  | Mã nghiệp vụ của quyết định cấp |
| 9 | revocation_license_dcsn_id | STRING | X |  | F |  | FK đến quyết định thu hồi chứng chỉ |
| 10 | revocation_license_dcsn_code | STRING | X |  |  |  | Mã nghiệp vụ của quyết định thu hồi |
| 11 | cncl_license_dcsn_id | STRING | X |  | F |  | FK đến quyết định hủy chứng chỉ |
| 12 | cncl_license_dcsn_code | STRING | X |  |  |  | Mã nghiệp vụ của quyết định hủy |
| 13 | issu_dt | DATE |  |  |  |  | Ngày cấp chứng chỉ hành nghề |
| 14 | revocation_dt | DATE | X |  |  |  | Ngày thu hồi chứng chỉ hành nghề |
| 15 | revocation_rsn | STRING | X |  |  |  | Lý do thu hồi chứng chỉ hành nghề |
| 16 | prac_nm_at_issn | STRING | X |  |  |  | Tên người hành nghề tại thời điểm cấp chứng chỉ (snapshot) |
| 17 | reissuance_allowed_cnt | INT |  |  |  |  | Số lần được phép cấp lại chứng chỉ (0 = không được cấp lại) |
| 18 | pcs_st_code | STRING |  |  |  |  | Trạng thái xử lý chứng chỉ (1=Đã cấp 2=Đã ký nháy 3=Đã ký 4=Đã trả) |
| 19 | ctf_file_path | STRING | X |  |  |  | Đường dẫn file chứng chỉ số |
| 20 | cnvr_st_code | STRING |  |  |  |  | Trạng thái chuyển đổi chứng chỉ (1=Giấy 2=Chờ điện tử 3=Chứng chỉ số) |
| 21 | rcrd_st_code | STRING |  |  |  |  | Trạng thái hiệu lực của bản ghi chứng chỉ (1=Hoạt động) |
| 22 | dsc | STRING | X |  |  |  | Mô tả bổ sung cho chứng chỉ hành nghề |
| 23 | src_stm_code | STRING |  |  |  | 'NHNCK.CERTIFICATE_RECORDS' | Mã hệ thống nguồn ETL-derived |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_prac_license_ctf_doc_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_prac_id | scr_prac | scr_prac_id |
| issu_license_dcsn_id |  |  |
| revocation_license_dcsn_id |  |  |
| cncl_license_dcsn_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_license_dcsn_doc



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_prac_license_dcsn_doc_id | STRING |  | X | P |  | Surrogate key cho quyết định hành chính |
| 2 | scr_prac_license_dcsn_doc_code | STRING |  |  |  |  | Business key từ PK nguồn DECISIONS.ID |
| 3 | dcsn_nbr | STRING | X |  |  |  | Số hiệu quyết định hành chính (VD: 123/QĐ-UBCK) |
| 4 | dcsn_ttl | STRING | X |  |  |  | Tiêu đề/tên quyết định hành chính |
| 5 | lgl_refr | STRING | X |  |  |  | Căn cứ pháp lý của quyết định |
| 6 | dcsn_cntnt | STRING | X |  |  |  | Nội dung đầy đủ của quyết định |
| 7 | dcsn_signed_dt | DATE | X |  |  |  | Ngày ký ban hành quyết định |
| 8 | signatory_nm | STRING | X |  |  |  | Họ tên người ký quyết định |
| 9 | signatory_pos | STRING | X |  |  |  | Chức vụ của người ký quyết định |
| 10 | issu_org_nm | STRING | X |  |  |  | Tên đơn vị ban hành quyết định (VD: Ủy ban Chứng khoán Nhà nước) |
| 11 | attch_file_nm | STRING | X |  |  |  | Tên file văn bản đính kèm |
| 12 | attch_file_path | STRING | X |  |  |  | Đường dẫn lưu trữ file đính kèm |
| 13 | dcsn_tp_code | STRING |  |  |  |  | Loại quyết định hành chính (Cấp mới / Thu hồi / Cấp lại / ...) |
| 14 | rcrd_st_code | STRING |  |  |  |  | Trạng thái hiệu lực của bản ghi quyết định |
| 15 | notf_cntnt | STRING | X |  |  |  | Nội dung thông báo hoặc yêu cầu bổ sung hồ sơ kèm theo |
| 16 | actv_f | BOOLEAN |  |  |  |  | Cờ đánh dấu quyết định đang được sử dụng (1=Đang dùng; 0=Vô hiệu) |
| 17 | src_stm_code | STRING |  |  |  | 'NHNCK.DECISIONS' | Mã hệ thống nguồn của bản ghi |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_prac_license_dcsn_doc_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_org_emp_rpt



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_prac_org_emp_rpt_id | STRING |  | X | P |  | Khóa đại diện cho báo cáo danh sách NHNCK tại tổ chức (surrogate key). |
| 2 | scr_prac_org_emp_rpt_code | STRING |  |  |  |  | Mã định danh kỹ thuật (BK). Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.ORGANIZATION_REPORTS' | Mã hệ thống nguồn. |
| 4 | scr_org_refr_id | STRING |  |  | F |  | FK đến tổ chức kinh doanh chứng khoán. |
| 5 | scr_org_refr_code | STRING |  |  |  |  | Mã tổ chức (denormalized). |
| 6 | scr_prac_id | STRING |  |  | F |  | FK đến người hành nghề chứng khoán. |
| 7 | scr_prac_code | STRING |  |  |  |  | Mã người hành nghề (denormalized). |
| 8 | license_ctf_doc_id | STRING | X |  | F |  | FK đến hồ sơ chứng chỉ hành nghề (nullable). |
| 9 | license_ctf_doc_code | STRING | X |  |  |  | Mã hồ sơ chứng chỉ hành nghề (denormalized). |
| 10 | ctf_tp_code | STRING | X |  | F |  | Loại chứng chỉ hành nghề tại thời điểm báo cáo. |
| 11 | prn_rpt_id | STRING | X |  | F |  | FK self-ref — báo cáo gốc được điều chỉnh (nullable). |
| 12 | prn_rpt_code | STRING | X |  |  |  | Mã báo cáo gốc (denormalized). |
| 13 | prac_nm_at_rpt | STRING | X |  |  |  | Họ và tên người hành nghề tại thời điểm lập báo cáo (snapshot). |
| 14 | prac_brth_dt_at_rpt | DATE | X |  |  |  | Ngày sinh người hành nghề tại thời điểm lập báo cáo (snapshot). |
| 15 | prac_id_nbr_at_rpt | STRING | X |  |  |  | Số định danh cá nhân tại thời điểm lập báo cáo (snapshot). |
| 16 | prac_pos_at_rpt | STRING | X |  |  |  | Chức vụ của người hành nghề tại tổ chức (snapshot). |
| 17 | prac_dept_at_rpt | STRING | X |  |  |  | Phòng ban của người hành nghề tại tổ chức (snapshot). |
| 18 | prac_workplace_at_rpt | STRING | X |  |  |  | Nơi làm việc của người hành nghề tại thời điểm báo cáo (snapshot). |
| 19 | ctf_nbr_at_rpt | STRING | X |  |  |  | Số chứng chỉ hành nghề tại thời điểm lập báo cáo (snapshot). |
| 20 | ctf_issu_dt_at_rpt | DATE | X |  |  |  | Ngày cấp chứng chỉ hành nghề tại thời điểm lập báo cáo (snapshot). |
| 21 | hire_dt | DATE | X |  |  |  | Ngày tuyển dụng vào tổ chức. |
| 22 | tmt_dt | DATE | X |  |  |  | Ngày chấm dứt hợp đồng lao động (NULL = đang làm việc). |
| 23 | rpt_dt | DATE | X |  |  |  | Ngày lập báo cáo. |
| 24 | disciplines | STRING | X |  |  |  | Kỷ luật của người hành nghề tại tổ chức. |
| 25 | dsc | STRING | X |  |  |  | Mô tả bổ sung cho báo cáo. |
| 26 | notes | STRING | X |  |  |  | Ghi chú nội bộ. |
| 27 | bsn_dept_nm | STRING | X |  | F |  | Tên phòng nghiệp vụ UBCKNN phụ trách (denormalized text). |
| 28 | rpt_file_path | STRING | X |  |  |  | Đường dẫn file báo cáo đính kèm. |
| 29 | tmt_file_path | STRING | X |  |  |  | Đường dẫn file chấm dứt hợp đồng đính kèm. |
| 30 | ext_sync_id | STRING | X |  |  |  | Mã đồng bộ từ hệ thống ngoài (FMS/SCMS). |
| 31 | rcrd_tp_code | STRING | X |  |  |  | Phân loại loại bản ghi báo cáo. |
| 32 | org_st_code_at_rpt | STRING | X |  |  |  | Trạng thái tổ chức tại thời điểm lập báo cáo. |
| 33 | rcrd_st_code | STRING |  |  |  |  | Trạng thái bản ghi báo cáo (1=Hoạt động). |
| 34 | sync_crt_tms | TIMESTAMP | X |  |  |  | Thời điểm tạo bản ghi tại hệ thống đồng bộ nguồn. |
| 35 | sync_udt_tms | TIMESTAMP | X |  |  |  | Thời điểm cập nhật bản ghi tại hệ thống đồng bộ nguồn. |
| 36 | crt_tms | TIMESTAMP | X |  |  |  | Thời điểm tạo bản ghi trong NHNCK. |
| 37 | crt_by_ofcr_id | STRING | X |  | F |  | FK đến nhân viên UBCKNN tạo bản ghi. |
| 38 | crt_by_ofcr_code | STRING | X |  |  |  | Mã nhân viên tạo bản ghi (denormalized). |
| 39 | udt_tms | TIMESTAMP | X |  |  |  | Thời điểm cập nhật bản ghi gần nhất. |
| 40 | udt_by_ofcr_id | STRING | X |  | F |  | FK đến nhân viên UBCKNN cập nhật bản ghi. |
| 41 | udt_by_ofcr_code | STRING | X |  |  |  | Mã nhân viên cập nhật bản ghi (denormalized). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_prac_org_emp_rpt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_org_refr_id | scr_org_refr | scr_org_refr_id |
| scr_prac_id | scr_prac | scr_prac_id |
| license_ctf_doc_id |  |  |
| prn_rpt_id | scr_prac_org_emp_rpt | scr_prac_org_emp_rpt_id |
| crt_by_ofcr_id | reg_ahr_ofcr |  |
| udt_by_ofcr_id | reg_ahr_ofcr |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_prof_trn_clss



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_prac_prof_trn_clss_id | STRING |  | X | P |  | Surrogate key cho khóa học chuyên môn |
| 2 | scr_prac_prof_trn_clss_code | STRING |  |  |  |  | Mã khóa học (business key) |
| 3 | trn_clss_nm | STRING | X |  |  |  | Tên khóa học |
| 4 | academic_yr | INT | X |  |  |  | Năm học |
| 5 | specialization_tp_code | STRING | X |  | F |  | Loại chuyên môn của khóa học |
| 6 | exam_strt_dt | DATE | X |  |  |  | Ngày bắt đầu thi |
| 7 | exam_end_dt | STRING | X |  |  |  | Ngày kết thúc thi |
| 8 | exam_lo_adr | STRING | X |  |  |  | Địa điểm tổ chức thi |
| 9 | prov_id | STRING | X |  | F |  | FK đến tỉnh/thành nơi tổ chức thi |
| 10 | prov_code | STRING | X |  |  |  | Mã tỉnh/thành nơi tổ chức thi (lookup pair) |
| 11 | rcrd_st_code | STRING |  |  |  |  | Trạng thái bản ghi khóa học |
| 12 | src_stm_code | STRING |  |  |  | 'NHNCK.SPECIALIZATION_COURSES' | Mã hệ thống nguồn |
| 13 | crt_at | TIMESTAMP | X |  |  |  | Thời điểm tạo bản ghi (pending) |
| 14 | crt_by | STRING | X |  | F |  | Người tạo bản ghi — FK đến USERS (pending) |
| 15 | udt_at | TIMESTAMP | X |  |  |  | Thời điểm cập nhật bản ghi (pending) |
| 16 | udt_by | STRING | X |  | F |  | Người cập nhật bản ghi — FK đến USERS (pending) |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_prac_prof_trn_clss_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prov_id | geo | geo_id |



#### Index

N/A

#### Trigger

N/A




### Bảng reg_ahr_ofcr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | reg_ahr_ofcr_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | reg_ahr_ofcr_code | STRING |  |  |  |  | Mã cán bộ/chuyên viên UBCK. BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.USERS' | Mã nguồn dữ liệu |
| 4 | full_nm | STRING | X |  |  |  | Họ và tên đầy đủ |
| 5 | idv_gnd_code | STRING | X |  |  |  | Giới tính |
| 6 | ou_id | STRING | X |  | F |  | FK đến Regulatory Authority Organization Unit (đơn vị) |
| 7 | ou_code | STRING | X |  |  |  | Mã đơn vị |
| 8 | dept_id | STRING | X |  | F |  | FK đến Regulatory Authority Organization Unit (phòng ban) |
| 9 | dept_code | STRING | X |  |  |  | Mã phòng ban |
| 10 | pos_code | STRING | X |  |  |  | Mã vị trí/chức danh |
| 11 | scr_prac_id | STRING | X |  | F |  | FK đến Securities Practitioner (nếu cán bộ cũng là NHNCK) |
| 12 | scr_prac_code | STRING | X |  |  |  | Mã người hành nghề liên kết |
| 13 | rcrd_st_code | STRING | X |  |  |  | Trạng thái hoạt động của cán bộ |
| 14 | rcrd_tp_code | STRING | X |  |  |  | Loại bản ghi cán bộ |
| 15 | crt_tms | TIMESTAMP | X |  |  |  | Thời điểm tạo bản ghi |
| 16 | udt_tms | TIMESTAMP | X |  |  |  | Thời điểm cập nhật bản ghi lần cuối |
| 17 | crt_by_ofcr_code | STRING | X |  | F |  | Mã cán bộ tạo bản ghi |
| 18 | udt_by_ofcr_code | STRING | X |  | F |  | Mã cán bộ cập nhật bản ghi lần cuối |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| reg_ahr_ofcr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ou_id | reg_ahr_ou | reg_ahr_ou_id |
| dept_id | reg_ahr_ou | reg_ahr_ou_id |
| scr_prac_id | scr_prac | prac_id |



#### Index

N/A

#### Trigger

N/A




### Bảng reg_ahr_ou



#### Từ NHNCK.UNITS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | reg_ahr_ou_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | reg_ahr_ou_code | STRING |  |  |  |  | Mã đơn vị nội bộ UBCKNN. BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.UNITS' | Mã hệ thống nguồn. BK |
| 4 | ou_tp_code | STRING |  |  |  | 'UNIT' | Phân loại — Đơn vị (Unit) |
| 5 | reg_ahr_ou_nm | STRING | X |  |  |  | Tên đơn vị nội bộ UBCKNN |
| 6 | hier_lvl_code | STRING | X |  |  |  | Cấp độ trong cây phân cấp tổ chức |
| 7 | prn_reg_ahr_ou_id | STRING | X |  | F |  | FK đến đơn vị cha (self-ref) |
| 8 | prn_reg_ahr_ou_code | STRING | X |  |  |  | Mã đơn vị cha |
| 9 | dsc | STRING | X |  |  |  | Mô tả chi tiết đơn vị |
| 10 | rcrd_st_code | STRING |  |  |  |  | Trạng thái hoạt động của đơn vị |
| 11 | sort_ordr | INT | X |  |  |  | Thứ tự sắp xếp phòng ban trong đơn vị |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| reg_ahr_ou_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prn_reg_ahr_ou_id | reg_ahr_ou | reg_ahr_ou_id |



**Index:** N/A

**Trigger:** N/A


#### Từ NHNCK.DEPARTMENTS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | reg_ahr_ou_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | reg_ahr_ou_code | STRING |  |  |  |  | Mã phòng ban. BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.DEPARTMENTS' | Mã hệ thống nguồn. BK |
| 4 | ou_tp_code | STRING |  |  |  | 'DEPARTMENT' | Phân loại — Phòng ban (Department) |
| 5 | reg_ahr_ou_nm | STRING | X |  |  |  | Tên phòng ban |
| 6 | hier_lvl_code | STRING | X |  |  |  | Cấp độ trong cây phân cấp — null cho phòng ban |
| 7 | prn_reg_ahr_ou_id | STRING | X |  | F |  | FK đến đơn vị cha (UNITS) |
| 8 | prn_reg_ahr_ou_code | STRING | X |  |  |  | Mã đơn vị cha (UNITS) |
| 9 | dsc | STRING | X |  |  |  | Mô tả chi tiết phòng ban |
| 10 | rcrd_st_code | STRING |  |  |  |  | Trạng thái hoạt động của phòng ban |
| 11 | sort_ordr | INT | X |  |  |  | Thứ tự sắp xếp phòng ban trong đơn vị |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| reg_ahr_ou_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prn_reg_ahr_ou_id | reg_ahr_ou | reg_ahr_ou_id |



**Index:** N/A

**Trigger:** N/A





### Bảng scr_org_refr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_org_refr_id | STRING |  | X | P |  | Khóa đại diện cho tổ chức kinh doanh chứng khoán (surrogate key). |
| 2 | scr_org_refr_code | STRING |  |  |  |  | Mã định danh kỹ thuật tự tăng. BK của entity. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.ORGANIZATIONS' | Mã hệ thống nguồn. |
| 4 | org_code | STRING | X |  |  |  | Mã tổ chức (mã nghiệp vụ do hệ thống gán). |
| 5 | scr_org_refr_nm | STRING | X |  |  |  | Tên đầy đủ tổ chức. |
| 6 | scr_org_refr_en_nm | STRING | X |  |  |  | Tên tiếng Anh của tổ chức. |
| 7 | scr_org_refr_shrt_nm | STRING | X |  |  |  | Tên viết tắt của tổ chức. |
| 8 | org_tp_code | STRING | X |  |  |  | Loại tổ chức: 0=Khác, 1=CTCK, 2=QLQ, 3=Ngân hàng. |
| 9 | org_lvl_code | STRING | X |  |  |  | Cấp độ phân cấp tổ chức. |
| 10 | prn_scr_org_refr_id | STRING | X |  | F |  | FK tự tham chiếu — tổ chức cha trong cấu trúc phân cấp. |
| 11 | prn_scr_org_refr_code | STRING | X |  |  |  | Mã tổ chức cha. |
| 12 | ext_stm_linked_id | STRING | X |  |  |  | ID liên kết sang hệ thống FMS/SCMS. |
| 13 | ext_stm_sync_id | STRING | X |  |  |  | Mã đồng bộ từ FMS/SCMS. |
| 14 | lgl_rprs_nm | STRING | X |  |  |  | Tên người đại diện pháp luật của tổ chức. |
| 15 | license_nbr | STRING | X |  |  |  | Số giấy phép hoạt động chứng khoán. |
| 16 | license_issur_nm | STRING | X |  |  |  | Tên cơ quan cấp giấy phép hoạt động. |
| 17 | license_dt | DATE | X |  |  |  | Ngày cấp giấy phép hoạt động. |
| 18 | charter_cptl_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ của tổ chức. |
| 19 | dsc | STRING | X |  |  |  | Mô tả chi tiết về tổ chức. |
| 20 | rcrd_st_code | STRING | X |  |  |  | Trạng thái bản ghi: 1=Hoạt động. |
| 21 | sort_ordr | INT | X |  |  |  | Thứ tự sắp xếp hiển thị. |
| 22 | last_sync_dt | DATE | X |  |  |  | Ngày đồng bộ dữ liệu gần nhất. |
| 23 | sync_st_code | STRING | X |  |  |  | Trạng thái đồng bộ: 0=Chưa đồng bộ, 1=Đã đồng bộ, 2=Lỗi. |
| 24 | crt_by_ofcr_id | STRING | X |  | F |  | FK đến cán bộ tạo bản ghi. |
| 25 | crt_by_ofcr_code | STRING | X |  |  |  | Mã cán bộ tạo bản ghi. |
| 26 | crt_dt | DATE | X |  |  |  | Ngày tạo bản ghi. |
| 27 | udt_by_ofcr_id | STRING | X |  | F |  | FK đến cán bộ cập nhật bản ghi gần nhất. |
| 28 | udt_by_ofcr_code | STRING | X |  |  |  | Mã cán bộ cập nhật bản ghi gần nhất. |
| 29 | udt_dt | DATE | X |  |  |  | Ngày cập nhật bản ghi gần nhất. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_org_refr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| prn_scr_org_refr_id | scr_org_refr | scr_org_refr_id |
| crt_by_ofcr_id | reg_ahr_ofcr |  |
| udt_by_ofcr_id | reg_ahr_ofcr |  |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac



#### Từ NHNCK.PROFESSIONALS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | prac_id | STRING |  | X | P |  | Khóa đại diện cho người hành nghề chứng khoán. |
| 2 | prac_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.PROFESSIONALS' | Mã nguồn dữ liệu |
| 4 | scr_co_id | STRING |  |  | F |  | FK đến công ty chứng khoán nơi hành nghề. |
| 5 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 6 | empe_code | STRING | X |  |  |  | Mã nhân viên nội bộ CTCK. |
| 7 | full_nm | STRING | X |  |  |  | Họ và tên đầy đủ của người hành nghề |
| 8 | dob | DATE | X |  |  |  | Ngày sinh. |
| 9 | license_nbr | STRING | X |  |  |  | Số chứng chỉ hành nghề chứng khoán. |
| 10 | emp_strt_dt | DATE | X |  |  |  | Ngày bắt đầu làm việc tại CTCK. |
| 11 | emp_end_dt | DATE | X |  |  |  | Ngày nghỉ việc. |
| 12 | note | STRING | X |  |  |  | Ghi chú. |
| 13 | prac_st_code | STRING | X |  |  |  | Trạng thái người hành nghề tại CTCK. |
| 14 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 15 | scr_prac_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 16 | scr_prac_code | STRING |  |  |  |  | Mã người hành nghề. BK từ PK nguồn |
| 17 | gvn_nm | STRING | X |  |  |  | Tên đệm và tên riêng |
| 18 | brth_dt | DATE | X |  |  |  | Ngày sinh |
| 19 | brth_yr | STRING | X |  |  |  | Năm sinh (lưu dạng chuỗi khi không có ngày tháng đủ) |
| 20 | gnd_code | STRING | X |  |  |  | Giới tính: 0=Nam / 1=Nữ |
| 21 | ed_lvl_code | STRING | X |  | F |  | Trình độ học vấn |
| 22 | prac_rgst_tp_code | STRING | X |  |  |  | Hình thức đăng ký hồ sơ: 0=MCĐT/cổng DVC / 1=Nhập tay |
| 23 | practice_st_code | STRING | X |  |  |  | Trạng thái hành nghề chứng khoán |
| 24 | ac_st_code | STRING | X |  |  |  | Trạng thái tài khoản người dùng trên cổng NHNCK |
| 25 | org_id | STRING | X |  | F |  | FK đến tổ chức chứng khoán hiện tại (nullable) |
| 26 | org_code | STRING | X |  |  |  | Mã tổ chức (denormalized lookup) |
| 27 | nat_id | STRING | X |  | F |  | FK đến Geographic Area (quốc tịch) |
| 28 | nat_code | STRING | X |  |  |  | Mã quốc gia/quốc tịch (denormalized) |
| 29 | workplace_nm | STRING | X |  |  |  | Nơi làm việc hiện tại (tên tổ chức — denormalized text tự do) |
| 30 | pos_nm | STRING | X |  | F |  | Chức vụ hiện tại (denormalized text tự do) |
| 31 | dept_nm | STRING | X |  |  |  | Phòng ban hiện tại (denormalized text tự do) |
| 32 | prev_id_nbr | STRING | X |  |  |  | Số CMND cũ trước khi chuyển sang CCCD |
| 33 | hometown | STRING | X |  |  |  | Quê quán (dữ liệu tích hợp C06) |
| 34 | ethnicity_nm | STRING | X |  |  |  | Dân tộc (dữ liệu tích hợp C06) |
| 35 | rlg_nm | STRING | X |  |  |  | Tôn giáo (dữ liệu tích hợp C06) |
| 36 | plc_of_brth_dsc | STRING | X |  |  |  | Nơi sinh (text tự do) |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| prac_id |
| scr_prac_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_co_id | scr_co | scr_co_id |
| org_id | scr_org_refr | scr_org_refr_id |
| nat_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ NHNCK.PROFESSIONAL_HISTORIES

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | prac_id | STRING |  | X | P |  | Khóa đại diện cho người hành nghề chứng khoán. |
| 2 | prac_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.PROFESSIONAL_HISTORIES' | Mã nguồn dữ liệu |
| 4 | scr_co_id | STRING |  |  | F |  | FK đến công ty chứng khoán nơi hành nghề. |
| 5 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 6 | empe_code | STRING | X |  |  |  | Mã nhân viên nội bộ CTCK. |
| 7 | full_nm | STRING | X |  |  |  | Họ và tên đầy đủ của người hành nghề |
| 8 | dob | DATE | X |  |  |  | Ngày sinh. |
| 9 | license_nbr | STRING | X |  |  |  | Số chứng chỉ hành nghề chứng khoán. |
| 10 | emp_strt_dt | DATE | X |  |  |  | Ngày bắt đầu làm việc tại CTCK. |
| 11 | emp_end_dt | DATE | X |  |  |  | Ngày nghỉ việc. |
| 12 | note | STRING | X |  |  |  | Ghi chú. |
| 13 | prac_st_code | STRING | X |  |  |  | Trạng thái người hành nghề tại CTCK. |
| 14 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 15 | scr_prac_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 16 | scr_prac_code | STRING |  |  |  |  | Mã người hành nghề. BK từ PK nguồn |
| 17 | gvn_nm | STRING | X |  |  |  | Tên đệm và tên riêng |
| 18 | brth_dt | DATE | X |  |  |  | Ngày sinh |
| 19 | brth_yr | STRING | X |  |  |  | Năm sinh (lưu dạng chuỗi khi không có ngày tháng đủ) |
| 20 | gnd_code | STRING | X |  |  |  | Giới tính: 0=Nam / 1=Nữ |
| 21 | ed_lvl_code | STRING | X |  | F |  | Trình độ học vấn |
| 22 | prac_rgst_tp_code | STRING | X |  |  |  | Hình thức đăng ký hồ sơ: 0=MCĐT/cổng DVC / 1=Nhập tay |
| 23 | practice_st_code | STRING | X |  |  |  | Trạng thái hành nghề chứng khoán |
| 24 | ac_st_code | STRING | X |  |  |  | Trạng thái tài khoản người dùng trên cổng NHNCK |
| 25 | org_id | STRING | X |  | F |  | FK đến tổ chức chứng khoán hiện tại (nullable) |
| 26 | org_code | STRING | X |  |  |  | Mã tổ chức (denormalized lookup) |
| 27 | nat_id | STRING | X |  | F |  | FK đến Geographic Area (quốc tịch) |
| 28 | nat_code | STRING | X |  |  |  | Mã quốc gia/quốc tịch (denormalized) |
| 29 | workplace_nm | STRING | X |  |  |  | Nơi làm việc hiện tại (tên tổ chức — denormalized text tự do) |
| 30 | pos_nm | STRING | X |  | F |  | Chức vụ hiện tại (denormalized text tự do) |
| 31 | dept_nm | STRING | X |  |  |  | Phòng ban hiện tại (denormalized text tự do) |
| 32 | prev_id_nbr | STRING | X |  |  |  | Số CMND cũ trước khi chuyển sang CCCD |
| 33 | hometown | STRING | X |  |  |  | Quê quán (dữ liệu tích hợp C06) |
| 34 | ethnicity_nm | STRING | X |  |  |  | Dân tộc (dữ liệu tích hợp C06) |
| 35 | rlg_nm | STRING | X |  |  |  | Tôn giáo (dữ liệu tích hợp C06) |
| 36 | plc_of_brth_dsc | STRING | X |  |  |  | Nơi sinh (text tự do) |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| prac_id |
| scr_prac_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_co_id | scr_co | scr_co_id |
| org_id | scr_org_refr | scr_org_refr_id |
| nat_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A





### Bảng scr_prac_emp_st



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_prac_emp_st_id | STRING |  | X | P |  | Khóa đại diện cho bản ghi lịch sử công tác / trạng thái việc làm của người hành nghề chứng khoán (surrogate key). |
| 2 | scr_prac_emp_st_code | STRING |  |  |  |  | Mã định danh kỹ thuật. BK của entity. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.PROFESSIONAL_WORK_HISTORIES' | Mã hệ thống nguồn. |
| 4 | scr_prac_id | STRING |  |  | F |  | Surrogate key FK đến người hành nghề chứng khoán. |
| 5 | scr_prac_code | STRING |  |  |  |  | Mã kỹ thuật của người hành nghề (dư thừa). |
| 6 | scr_org_refr_id | STRING | X |  | F |  | Surrogate key FK đến tổ chức kinh doanh chứng khoán nơi người hành nghề làm việc. |
| 7 | scr_org_refr_code | STRING | X |  |  |  | Mã kỹ thuật của tổ chức (dư thừa). |
| 8 | dept_nm | STRING | X |  |  |  | Tên đơn vị / phòng ban trong tổ chức tại thời điểm làm việc (snapshot text). |
| 9 | workplace_nm | STRING | X |  |  |  | Tên tổ chức / nơi làm việc dạng text (có thể khác ORGANIZATION_NAME khi tổ chức đổi tên hoặc chưa có trong ORGANIZATIONS). |
| 10 | emp_strt_dt | DATE |  |  |  |  | Ngày bắt đầu làm việc tại tổ chức. |
| 11 | emp_end_dt | DATE | X |  |  |  | Ngày kết thúc làm việc. Null = đang làm việc. |
| 12 | pos_code | STRING | X |  | F |  | Mã chức vụ của người hành nghề tại tổ chức. |
| 13 | pos_nm | STRING | X |  |  |  | Tên chức vụ snapshot tại thời điểm ghi nhận. |
| 14 | awards | STRING | X |  |  |  | Thông tin khen thưởng trong thời gian làm việc tại tổ chức. |
| 15 | disciplines | STRING | X |  |  |  | Thông tin kỷ luật trong thời gian làm việc tại tổ chức. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_prac_emp_st_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_prac_id | scr_prac | scr_prac_id |
| scr_org_refr_id | scr_org_refr | scr_org_refr_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_license_ap_emp_exrnc



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_prac_license_ap_emp_exrnc_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | scr_prac_license_ap_emp_exrnc_code | STRING |  |  |  |  | Mã định danh kinh nghiệm làm việc. BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.APPLICATION_EXPERIENCES' | Mã nguồn dữ liệu |
| 4 | license_ap_id | STRING |  |  | F |  | FK đến hồ sơ đăng ký CCHN |
| 5 | license_ap_code | STRING |  |  |  |  | Mã hồ sơ đăng ký CCHN |
| 6 | doc_tp_code | STRING | X |  | F |  | Mã loại tài liệu yêu cầu (Classification Value từ Documents) |
| 7 | scr_org_refr_id | STRING | X |  | F |  | FK đến tổ chức kinh doanh chứng khoán trong hệ thống (nullable — nếu nơi làm việc là CTCK/QLQ đã đăng ký) |
| 8 | scr_org_refr_code | STRING | X |  |  |  | Mã tổ chức kinh doanh chứng khoán (dư thừa) |
| 9 | org_nm | STRING |  |  |  |  | Tên tổ chức nơi làm việc (snapshot text — giữ kể cả khi ORGANIZATION_ID có giá trị) |
| 10 | dept_nm | STRING | X |  |  |  | Tên phòng ban nơi làm việc |
| 11 | pos | STRING | X |  |  |  | Chức vụ tại tổ chức |
| 12 | emp_strt_dt | DATE |  |  |  |  | Ngày bắt đầu làm việc tại tổ chức |
| 13 | emp_end_dt | DATE | X |  |  |  | Ngày kết thúc làm việc tại tổ chức (null nếu đang làm việc) |
| 14 | wrk_drtn_mo | INT |  |  |  |  | Thời gian làm việc tại tổ chức (số tháng) |
| 15 | tot_exrnc_drtn_mo | INT |  |  |  |  | Tổng thời gian kinh nghiệm tích lũy (số tháng) |
| 16 | ins_nbr | STRING | X |  |  |  | Số bảo hiểm xã hội |
| 17 | labor_ctr_info | STRING | X |  |  |  | Thông tin hợp đồng lao động |
| 18 | director_cfrm | STRING | X |  |  |  | Thông tin xác nhận của giám đốc tổ chức |
| 19 | note | STRING | X |  |  |  | Ghi chú bổ sung |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_prac_license_ap_emp_exrnc_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| license_ap_id | scr_prac_license_ap |  |
| scr_org_refr_id | scr_org_refr | scr_org_refr_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_license_ap_snpst



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_prac_license_ap_snpst_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | scr_prac_license_ap_snpst_code | STRING |  |  |  |  | Mã snapshot. BK từ PK nguồn |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.APPLICATION_PROFESSIONALS' | Mã nguồn dữ liệu |
| 4 | license_ap_id | STRING |  |  | F |  | FK đến hồ sơ đăng ký |
| 5 | license_ap_code | STRING |  |  |  |  | Mã hồ sơ đăng ký (denormalized) |
| 6 | scr_prac_id | STRING |  |  | F |  | FK đến người hành nghề |
| 7 | scr_prac_code | STRING |  |  |  |  | Mã người hành nghề (denormalized) |
| 8 | org_id | STRING | X |  | F |  | FK đến tổ chức chứng khoán (nullable) |
| 9 | org_code | STRING | X |  |  |  | Mã tổ chức (denormalized) |
| 10 | nat_id | STRING | X |  | F |  | FK đến Geographic Area (quốc tịch snapshot) |
| 11 | nat_code | STRING | X |  |  |  | Mã quốc gia/quốc tịch (denormalized) |
| 12 | snpst_full_nm | STRING | X |  |  |  | Họ và tên đầy đủ tại thời điểm nộp hồ sơ |
| 13 | snpst_gvn_nm | STRING | X |  |  |  | Tên đệm và tên riêng tại thời điểm nộp hồ sơ |
| 14 | snpst_brth_dt | DATE | X |  |  |  | Ngày sinh tại thời điểm nộp hồ sơ |
| 15 | snpst_brth_yr | STRING | X |  |  |  | Năm sinh (chuỗi) tại thời điểm nộp hồ sơ |
| 16 | snpst_gnd_code | STRING | X |  |  |  | Giới tính tại thời điểm nộp hồ sơ |
| 17 | snpst_ed_lvl_code | STRING | X |  |  |  | Trình độ học vấn tại thời điểm nộp hồ sơ |
| 18 | snpst_prac_rgst_tp_code | STRING | X |  |  |  | Hình thức đăng ký tại thời điểm nộp hồ sơ |
| 19 | snpst_id_tp_code | STRING | X |  |  |  | Loại giấy tờ định danh tại thời điểm nộp hồ sơ |
| 20 | snpst_id_nbr | STRING | X |  |  |  | Số giấy tờ định danh tại thời điểm nộp hồ sơ |
| 21 | snpst_id_issu_dt | DATE | X |  |  |  | Ngày cấp giấy tờ định danh tại thời điểm nộp hồ sơ |
| 22 | snpst_id_issu_plc | STRING | X |  |  |  | Nơi cấp giấy tờ định danh tại thời điểm nộp hồ sơ |
| 23 | snpst_prev_id_nbr | STRING | X |  |  |  | Số CMND cũ tại thời điểm nộp hồ sơ |
| 24 | snpst_ph_nbr | STRING | X |  |  |  | Số điện thoại cố định tại thời điểm nộp hồ sơ |
| 25 | snpst_mbl_nbr | STRING | X |  |  |  | Số điện thoại di động tại thời điểm nộp hồ sơ |
| 26 | snpst_email | STRING | X |  |  |  | Email tại thời điểm nộp hồ sơ |
| 27 | snpst_workplace_nm | STRING | X |  |  |  | Nơi làm việc tại thời điểm nộp hồ sơ |
| 28 | snpst_pos_nm | STRING | X |  |  |  | Chức vụ tại thời điểm nộp hồ sơ |
| 29 | snpst_dept_nm | STRING | X |  |  |  | Phòng ban tại thời điểm nộp hồ sơ |
| 30 | snpst_plc_of_brth | STRING | X |  |  |  | Nơi sinh tại thời điểm nộp hồ sơ |
| 31 | snpst_adr | STRING | X |  |  |  | Địa chỉ chung (legacy) tại thời điểm nộp hồ sơ |
| 32 | snpst_perm_adr | STRING | X |  |  |  | Địa chỉ thường trú chi tiết tại thời điểm nộp hồ sơ |
| 33 | snpst_perm_cty_id | STRING | X |  | F |  | FK đến Geographic Area — quốc gia thường trú (snapshot) |
| 34 | snpst_perm_cty_code | STRING | X |  |  |  | Mã quốc gia thường trú (denormalized snapshot) |
| 35 | snpst_perm_prov_id | STRING | X |  | F |  | FK đến Geographic Area — tỉnh thường trú (snapshot) |
| 36 | snpst_perm_prov_code | STRING | X |  |  |  | Mã tỉnh thường trú (denormalized snapshot) |
| 37 | snpst_perm_dstc_id | STRING | X |  | F |  | FK đến Geographic Area — huyện thường trú (snapshot) |
| 38 | snpst_perm_dstc_code | STRING | X |  |  |  | Mã huyện thường trú (denormalized snapshot) |
| 39 | snpst_crn_cty_id | STRING | X |  | F |  | FK đến Geographic Area — quốc gia tạm trú (snapshot) |
| 40 | snpst_crn_cty_code | STRING | X |  |  |  | Mã quốc gia tạm trú (denormalized snapshot) |
| 41 | snpst_crn_prov_id | STRING | X |  | F |  | FK đến Geographic Area — tỉnh tạm trú (snapshot) |
| 42 | snpst_crn_prov_code | STRING | X |  |  |  | Mã tỉnh tạm trú (denormalized snapshot) |
| 43 | snpst_crn_dstc_id | STRING | X |  | F |  | FK đến Geographic Area — huyện tạm trú (snapshot) |
| 44 | snpst_crn_dstc_code | STRING | X |  |  |  | Mã huyện tạm trú (denormalized snapshot) |
| 45 | rcrd_st_code | STRING | X |  |  |  | Trạng thái bản ghi snapshot |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_prac_license_ap_snpst_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| license_ap_id | scr_prac_license_ap | scr_prac_license_ap_id |
| scr_prac_id | scr_prac | scr_prac_id |
| org_id | scr_org_refr | scr_org_refr_id |
| nat_id | geo | geo_id |
| snpst_perm_cty_id | geo | geo_id |
| snpst_perm_prov_id | geo | geo_id |
| snpst_perm_dstc_id | geo | geo_id |
| snpst_crn_cty_id | geo | geo_id |
| snpst_crn_prov_id | geo | geo_id |
| snpst_crn_dstc_id | geo | geo_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_prof_trn_hist



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_prac_prof_trn_hist_id | STRING |  | X | P |  | Khóa đại diện cho bản ghi lịch sử đào tạo / bồi dưỡng chuyên môn của người hành nghề chứng khoán (surrogate key). |
| 2 | scr_prac_prof_trn_hist_code | STRING |  |  |  |  | Mã định danh kỹ thuật. BK của entity. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.PROFESSIONAL_TRAININGS' | Mã hệ thống nguồn. |
| 4 | scr_prac_id | STRING |  |  | F |  | Surrogate key FK đến người hành nghề chứng khoán. |
| 5 | scr_prac_code | STRING |  |  |  |  | Mã kỹ thuật của người hành nghề (dư thừa). |
| 6 | trn_strt_dt | STRING |  |  |  |  | Ngày bắt đầu khóa đào tạo / bồi dưỡng chuyên môn. |
| 7 | trn_end_dt | STRING | X |  |  |  | Ngày kết thúc khóa đào tạo / bồi dưỡng chuyên môn. |
| 8 | trn_plc | STRING | X |  |  |  | Nơi tổ chức đào tạo / bồi dưỡng. |
| 9 | specialization_dsc | STRING | X |  |  |  | Chuyên ngành được đào tạo (text tự do từ nguồn). |
| 10 | awards | STRING | X |  |  |  | Thông tin khen thưởng nhận được trong quá trình đào tạo. |
| 11 | disciplines | STRING | X |  |  |  | Thông tin kỷ luật trong quá trình đào tạo. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_prac_prof_trn_hist_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_prac_id | scr_prac | scr_prac_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_prac_rel_p



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_prac_rel_p_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | scr_prac_rel_p_code | STRING |  |  |  |  | Mã định danh quan hệ (PK nguồn). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.PROFESSIONAL_RELATIONSHIPS' | Mã hệ thống nguồn. |
| 4 | scr_prac_id | STRING |  |  | F |  | FK đến Securities Practitioner |
| 5 | scr_prac_code | STRING |  |  |  |  | Mã người hành nghề chứng khoán |
| 6 | rltnp_tp_code | STRING |  |  |  |  | Loại quan hệ (1: Vợ/Chồng, 2: Con, 3: Bố, 4: Mẹ, 5: Ông, 6: Bà) |
| 7 | rel_idv_full_nm | STRING | X |  |  |  | Họ và tên người thân |
| 8 | rel_idv_brth_yr | INT | X |  |  |  | Năm sinh người thân |
| 9 | rel_idv_adr | STRING | X |  |  |  | Địa chỉ người thân |
| 10 | rel_idv_ocp | STRING | X |  |  |  | Nghề nghiệp người thân |
| 11 | rel_idv_workplace | STRING | X |  |  |  | Nơi làm việc người thân |
| 12 | rel_idv_id_nbr | STRING | X |  |  |  | Số CMND/CCCD người thân |
| 13 | cty_id | STRING | X |  | F |  | FK đến Geographic Area — quốc gia |
| 14 | cty_code | STRING | X |  |  |  | Mã quốc gia |
| 15 | note | STRING | X |  |  |  | Ghi chú |
| 16 | crt_tms | TIMESTAMP | X |  |  |  | Thời điểm tạo bản ghi |
| 17 | udt_tms | TIMESTAMP | X |  |  |  | Thời điểm cập nhật bản ghi |
| 18 | crt_by_ofcr_id | STRING | X |  | F |  | FK đến Regulatory Authority Officer — người tạo |
| 19 | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo |
| 20 | udt_by_ofcr_id | STRING | X |  | F |  | FK đến Regulatory Authority Officer — người cập nhật |
| 21 | udt_by_ofcr_code | STRING | X |  |  |  | Mã người cập nhật |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_prac_rel_p_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_prac_id | scr_prac | prac_id |
| cty_id | geo | geo_id |
| crt_by_ofcr_id | reg_ahr_ofcr |  |
| udt_by_ofcr_id | reg_ahr_ofcr |  |



#### Index

N/A

#### Trigger

N/A




### Bảng geo



#### Từ NHNCK.COUNTRIES

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | geo_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | geo_code | STRING |  |  |  |  | Mã quốc gia nguồn. BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.COUNTRIES' | Mã nguồn dữ liệu |
| 4 | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. |
| 5 | geo_nm | STRING |  |  |  |  | Tên quốc gia/vùng lãnh thổ |
| 6 | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. |
| 7 | dsc | STRING | X |  |  |  | Mô tả. |
| 8 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 9 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 10 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 11 | geo_tp_code | STRING |  |  |  |  | Phân loại vùng địa lý — Quốc gia |
| 12 | geo_bsn_code | STRING | X |  |  |  | Mã quốc tịch/quốc gia (mã nghiệp vụ). |
| 13 | note | STRING | X |  |  |  | Ghi chú. |
| 14 | prn_geo_id | STRING | X |  | F |  | FK đến vùng địa lý cha (self-ref). NULL cho quốc gia |
| 15 | prn_geo_code | STRING | X |  |  |  | Mã vùng địa lý cha |
| 16 | iso_cty_code | STRING | X |  |  |  | Mã quốc gia ISO 3166-1 alpha-2 |
| 17 | dflt_f | BOOLEAN |  |  |  |  | Cờ mặc định: true=Mặc định; false=Không |
| 18 | geo_st_code | STRING | X |  |  |  | Trạng thái bản ghi: 1=Hoạt động; 0=Không hoạt động |


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


#### Từ NHNCK.PROVINCES

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | geo_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | geo_code | STRING |  |  |  |  | Mã tỉnh/thành phố nguồn. BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.PROVINCES' | Mã nguồn dữ liệu |
| 4 | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. |
| 5 | geo_nm | STRING |  |  |  |  | Tên tỉnh/thành phố |
| 6 | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. |
| 7 | dsc | STRING | X |  |  |  | Mô tả. |
| 8 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 9 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 10 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 11 | geo_tp_code | STRING |  |  |  |  | Phân loại vùng địa lý — Tỉnh/Thành phố |
| 12 | geo_bsn_code | STRING | X |  |  |  | Mã quốc tịch/quốc gia (mã nghiệp vụ). |
| 13 | note | STRING | X |  |  |  | Ghi chú. |
| 14 | prn_geo_id | STRING | X |  | F |  | FK đến quốc gia cha |
| 15 | prn_geo_code | STRING | X |  |  |  | Mã quốc gia cha |
| 16 | iso_cty_code | STRING | X |  |  |  | Mã tỉnh/thành theo chuẩn |
| 17 | dflt_f | BOOLEAN |  |  |  |  | Cờ mặc định |
| 18 | geo_st_code | STRING | X |  |  |  | Trạng thái bản ghi |


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


#### Từ NHNCK.DISTRICTS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | geo_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | geo_code | STRING |  |  |  |  | Mã quận/huyện nguồn. BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.DISTRICTS' | Mã nguồn dữ liệu |
| 4 | geo_shrt_code | STRING | X |  |  |  | Mã viết tắt quốc tịch/quốc gia. |
| 5 | geo_nm | STRING |  |  |  |  | Tên quận/huyện |
| 6 | lcs_code | STRING | X |  |  |  | Trạng thái: 0: Không sử dụng 1: Sử dụng. |
| 7 | dsc | STRING | X |  |  |  | Mô tả. |
| 8 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 9 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 10 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 11 | geo_tp_code | STRING |  |  |  |  | Phân loại vùng địa lý — Quận/Huyện |
| 12 | geo_bsn_code | STRING | X |  |  |  | Mã quốc tịch/quốc gia (mã nghiệp vụ). |
| 13 | note | STRING | X |  |  |  | Ghi chú. |
| 14 | prn_geo_id | STRING | X |  | F |  | FK đến tỉnh/thành cha |
| 15 | prn_geo_code | STRING | X |  |  |  | Mã tỉnh/thành cha |
| 16 | iso_cty_code | STRING | X |  |  |  | Mã quận/huyện theo chuẩn |
| 17 | dflt_f | BOOLEAN |  |  |  |  | Cờ mặc định |
| 18 | geo_st_code | STRING | X |  |  |  | Trạng thái bản ghi |


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





### Bảng scr_prac_license_ap_fee



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_prac_license_ap_fee_id | STRING |  | X | P |  | Surrogate primary key |
| 2 | scr_prac_license_ap_fee_code | STRING |  |  |  |  | Business key từ APPLICATION_FEES.ID |
| 3 | license_ap_id | STRING |  |  | F |  | FK đến License Application |
| 4 | license_ap_code | STRING |  |  |  |  | Mã hồ sơ đăng ký (lookup pair) |
| 5 | scr_prac_id | STRING | X |  | F |  | FK đến Securities Practitioner (redundant — derive được từ Application) |
| 6 | scr_prac_code | STRING | X |  |  |  | Mã chuyên viên (lookup pair) |
| 7 | fee_tp_code | STRING |  |  |  |  | Loại phí: 1=Phí thi 2=Phí phúc khảo 3=Phí cấp chứng chỉ |
| 8 | fee_cntnt | STRING | X |  |  |  | Nội dung khoản phí |
| 9 | fee_amt | DECIMAL(23,2) |  |  |  |  | Số tiền phí (VNĐ) |
| 10 | pymt_rqs_dt | DATE |  |  |  |  | Ngày yêu cầu nộp phí |
| 11 | pymt_dt | DATE | X |  |  |  | Ngày thanh toán thực tế |
| 12 | pymt_expiry_dt | DATE | X |  |  |  | Ngày hết hạn thanh toán |
| 13 | pymt_st_code | STRING |  |  |  |  | Trạng thái thanh toán (proxy từ RECORD_STATUS: 1=Hoạt động) |
| 14 | pymt_evidence_file_path | STRING | X |  |  |  | Đường dẫn chứng từ thanh toán |
| 15 | note | STRING | X |  |  |  | Ghi chú |
| 16 | src_stm_code | STRING |  |  |  | 'NHNCK.APPLICATION_FEES' | Mã hệ thống nguồn |
| 17 | crt_by_usr_id | STRING | X |  | F |  | FK đến User (người tạo) — pending |
| 18 | crt_by_usr_code | STRING | X |  |  |  | Mã user (lookup pair — pending) |
| 19 | crt_at | TIMESTAMP | X |  |  |  | Thời điểm tạo bản ghi — pending |
| 20 | udt_by_usr_id | STRING | X |  | F |  | FK đến User (người cập nhật) — pending |
| 21 | udt_by_usr_code | STRING | X |  |  |  | Mã user (lookup pair — pending) |
| 22 | udt_at | TIMESTAMP | X |  |  |  | Thời điểm cập nhật bản ghi — pending |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_prac_license_ap_fee_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| license_ap_id |  |  |
| scr_prac_id | scr_prac | scr_prac_id |
| crt_by_usr_id |  |  |
| udt_by_usr_id |  |  |



#### Index

N/A

#### Trigger

N/A




### Bảng ip_alt_identn



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Securities Practitioner. |
| 2 | ip_code | STRING |  |  |  |  | Mã người hành nghề. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.PROFESSIONALS' | Mã hệ thống nguồn. |
| 4 | identn_issu_dt | DATE | X |  |  |  | Ngày cấp giấy tờ định danh. |
| 5 | identn_issu_plc | STRING | X |  |  |  | Nơi cấp giấy tờ định danh. |
| 6 | prev_identn_nbr | STRING | X |  |  |  | Số CMND cũ (trước khi đổi sang CCCD). |


#### Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_prac | scr_prac_id |



#### Index

N/A

#### Trigger

N/A




### Bảng ip_elc_adr



#### Từ NHNCK.UNITS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Regulatory Authority Organization Unit |
| 2 | ip_code | STRING |  |  |  |  | Mã đơn vị |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.UNITS' | Mã hệ thống nguồn |
| 4 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — email |
| 5 | elc_adr_val | STRING | X |  |  |  | Số điện thoại đơn vị |
| 6 | --- |  |  |  |  |  |  |
| 7 | **tóm_tắt_các_thay_đổi_so_với_file_cũ:** |  |  |  |  |  |  |
| 8 | **attr_nhnck_organizations.csv_—_12_điểm_sửa:** |  |  |  |  |  |  |
| 9 | |_thay_đổi_|_chi_tiết_| |  |  |  |  |  |  |
| 10 | |---|---| |  |  |  |  |  |  |
| 11 | |_src_columns_fmt_|_đổi_toàn_bộ_sang_fully_qualified_`nhnck.qlnhn.organizations.column`_| |  |  |  |  |  |  |
| 12 | |_tên_attr_|_`organization_name`_→_`securities_org_refr_name`_| |  |  |  |  |  |  |
| 13 | |_tên_attr_|_`english_name`_→_`securities_org_refr_en_name`_| |  |  |  |  |  |  |
| 14 | |_tên_attr_|_`abbreviation`_→_`securities_org_refr_shrt_name`_| |  |  |  |  |  |  |
| 15 | |_tên_attr_|_`representative_name`_→_`legal_rprs_name`_| |  |  |  |  |  |  |
| 16 | |_tên_attr_|_`license_issuer`_→_`license_issur_name`_| |  |  |  |  |  |  |
| 17 | |_tên_attr_|_`parent_org_id/code`_→_`parent_scr_org_refr_id/code`_| |  |  |  |  |  |  |
| 18 | |_tên_attr_|_`organization_st_code`_→_`record_st_code`_+_src_map_đúng_`record_status`_| |  |  |  |  |  |  |
| 19 | |_tên_attr_|_`linked_id`_→_`external_stm_linked_id`_| |  |  |  |  |  |  |
| 20 | |_tên_attr_|_`sync_id`_→_`external_stm_sync_id`_| |  |  |  |  |  |  |
| 21 | |_tên_attr_|_`organization_description`_→_`description`_| |  |  |  |  |  |  |
| 22 | |_thêm_mới_|_`updated_by_ofcr_id`_+_`updated_by_ofcr_code`_(từ_`updated_by`)_| |  |  |  |  |  |  |
| 23 | |_cnvr_rsk_|_`charter_cptl_amount`_—_ghi_chú_nvarchar2_→_dcm_| |  |  |  |  |  |  |
| 24 | |_dmn_dt_|_`created_date`_x_`updated_date`_dùng_`date`_(nguồn_là_oracle_`date` |  |  |  |  |  |  không phải TIMESTAMP) | |
| 25 | |_`etl_derived_value`_|_`source_stm_code`_→_thêm_`nhnck.organizations`_| |  |  |  |  |  |  |
| 26 | **attr_nhnck_organizations_ip_postal_address.csv:**_src_columns_đổi_sang_fully_qualified. |  |  |  |  |  |  |
| 27 | **attr_nhnck_organizations_ip_electronic_address.csv:**_thêm_blc_webst_(`ip_elec_addr_type=website`)_+_src_columns_đổi_sang_fully_qualified. |  |  |  |  |  |  |
| 28 | **lưu_ý_pndg_cần_doc_thêm:** |  |  |  |  |  |  |
| 29 | __`created_by`_x_`updated_by`_nguồn_là_`number(10 |  |  |  |  |  | 0)` FK → `USERS.ID` — ETL cần resolve sang Officer surrogate key qua bảng USERS. |
| 30 | __`website`_đã_chuyển_sang_ip_elc_adr_(không_còn_trong_ent_chính)_—_nếu_file_cũ_có_trường_`website`_ở_ent_chính_cần_xóa_(đã_xóa_trong_file_mới_này). |  |  |  |  |  |  |
| 31 | __`sort_order`_src_`number`_→_`small_counter`:_không_cần_ghi_chú_cnvr_rsk_vì_nbr_→_intg_là_tự_nhiên. |  |  |  |  |  |  |
| 32 | elc_adr | STRING |  |  |  |  | Giá trị địa chỉ điện tử (email hoặc số điện thoại) |
| 33 | ip_id | STRING |  |  | F |  | FK đến Regulatory Authority Organization Unit |
| 34 | ip_code | STRING |  |  |  |  | Mã đơn vị |
| 35 | src_stm_code | STRING |  |  |  | 'NHNCK.UNITS' | Mã hệ thống nguồn |
| 36 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — fax |
| 37 | elc_adr_val | STRING | X |  |  |  | Số điện thoại đơn vị |
| 38 | --- |  |  |  |  |  |  |
| 39 | **tóm_tắt_các_thay_đổi_so_với_file_cũ:** |  |  |  |  |  |  |
| 40 | **attr_nhnck_organizations.csv_—_12_điểm_sửa:** |  |  |  |  |  |  |
| 41 | |_thay_đổi_|_chi_tiết_| |  |  |  |  |  |  |
| 42 | |---|---| |  |  |  |  |  |  |
| 43 | |_src_columns_fmt_|_đổi_toàn_bộ_sang_fully_qualified_`nhnck.qlnhn.organizations.column`_| |  |  |  |  |  |  |
| 44 | |_tên_attr_|_`organization_name`_→_`securities_org_refr_name`_| |  |  |  |  |  |  |
| 45 | |_tên_attr_|_`english_name`_→_`securities_org_refr_en_name`_| |  |  |  |  |  |  |
| 46 | |_tên_attr_|_`abbreviation`_→_`securities_org_refr_shrt_name`_| |  |  |  |  |  |  |
| 47 | |_tên_attr_|_`representative_name`_→_`legal_rprs_name`_| |  |  |  |  |  |  |
| 48 | |_tên_attr_|_`license_issuer`_→_`license_issur_name`_| |  |  |  |  |  |  |
| 49 | |_tên_attr_|_`parent_org_id/code`_→_`parent_scr_org_refr_id/code`_| |  |  |  |  |  |  |
| 50 | |_tên_attr_|_`organization_st_code`_→_`record_st_code`_+_src_map_đúng_`record_status`_| |  |  |  |  |  |  |
| 51 | |_tên_attr_|_`linked_id`_→_`external_stm_linked_id`_| |  |  |  |  |  |  |
| 52 | |_tên_attr_|_`sync_id`_→_`external_stm_sync_id`_| |  |  |  |  |  |  |
| 53 | |_tên_attr_|_`organization_description`_→_`description`_| |  |  |  |  |  |  |
| 54 | |_thêm_mới_|_`updated_by_ofcr_id`_+_`updated_by_ofcr_code`_(từ_`updated_by`)_| |  |  |  |  |  |  |
| 55 | |_cnvr_rsk_|_`charter_cptl_amount`_—_ghi_chú_nvarchar2_→_dcm_| |  |  |  |  |  |  |
| 56 | |_dmn_dt_|_`created_date`_x_`updated_date`_dùng_`date`_(nguồn_là_oracle_`date` |  |  |  |  |  |  không phải TIMESTAMP) | |
| 57 | |_`etl_derived_value`_|_`source_stm_code`_→_thêm_`nhnck.organizations`_| |  |  |  |  |  |  |
| 58 | **attr_nhnck_organizations_ip_postal_address.csv:**_src_columns_đổi_sang_fully_qualified. |  |  |  |  |  |  |
| 59 | **attr_nhnck_organizations_ip_electronic_address.csv:**_thêm_blc_webst_(`ip_elec_addr_type=website`)_+_src_columns_đổi_sang_fully_qualified. |  |  |  |  |  |  |
| 60 | **lưu_ý_pndg_cần_doc_thêm:** |  |  |  |  |  |  |
| 61 | __`created_by`_x_`updated_by`_nguồn_là_`number(10 |  |  |  |  |  | 0)` FK → `USERS.ID` — ETL cần resolve sang Officer surrogate key qua bảng USERS. |
| 62 | __`website`_đã_chuyển_sang_ip_elc_adr_(không_còn_trong_ent_chính)_—_nếu_file_cũ_có_trường_`website`_ở_ent_chính_cần_xóa_(đã_xóa_trong_file_mới_này). |  |  |  |  |  |  |
| 63 | __`sort_order`_src_`number`_→_`small_counter`:_không_cần_ghi_chú_cnvr_rsk_vì_nbr_→_intg_là_tự_nhiên. |  |  |  |  |  |  |
| 64 | elc_adr | STRING |  |  |  |  | Giá trị địa chỉ điện tử (email hoặc số điện thoại) |
| 65 | ip_id | STRING |  |  | F |  | FK đến Regulatory Authority Organization Unit |
| 66 | ip_code | STRING |  |  |  |  | Mã đơn vị |
| 67 | src_stm_code | STRING |  |  |  | 'NHNCK.UNITS' | Mã hệ thống nguồn |
| 68 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — điện thoại |
| 69 | elc_adr_val | STRING | X |  |  |  | Số điện thoại đơn vị |
| 70 | --- |  |  |  |  |  |  |
| 71 | **tóm_tắt_các_thay_đổi_so_với_file_cũ:** |  |  |  |  |  |  |
| 72 | **attr_nhnck_organizations.csv_—_12_điểm_sửa:** |  |  |  |  |  |  |
| 73 | |_thay_đổi_|_chi_tiết_| |  |  |  |  |  |  |
| 74 | |---|---| |  |  |  |  |  |  |
| 75 | |_src_columns_fmt_|_đổi_toàn_bộ_sang_fully_qualified_`nhnck.qlnhn.organizations.column`_| |  |  |  |  |  |  |
| 76 | |_tên_attr_|_`organization_name`_→_`securities_org_refr_name`_| |  |  |  |  |  |  |
| 77 | |_tên_attr_|_`english_name`_→_`securities_org_refr_en_name`_| |  |  |  |  |  |  |
| 78 | |_tên_attr_|_`abbreviation`_→_`securities_org_refr_shrt_name`_| |  |  |  |  |  |  |
| 79 | |_tên_attr_|_`representative_name`_→_`legal_rprs_name`_| |  |  |  |  |  |  |
| 80 | |_tên_attr_|_`license_issuer`_→_`license_issur_name`_| |  |  |  |  |  |  |
| 81 | |_tên_attr_|_`parent_org_id/code`_→_`parent_scr_org_refr_id/code`_| |  |  |  |  |  |  |
| 82 | |_tên_attr_|_`organization_st_code`_→_`record_st_code`_+_src_map_đúng_`record_status`_| |  |  |  |  |  |  |
| 83 | |_tên_attr_|_`linked_id`_→_`external_stm_linked_id`_| |  |  |  |  |  |  |
| 84 | |_tên_attr_|_`sync_id`_→_`external_stm_sync_id`_| |  |  |  |  |  |  |
| 85 | |_tên_attr_|_`organization_description`_→_`description`_| |  |  |  |  |  |  |
| 86 | |_thêm_mới_|_`updated_by_ofcr_id`_+_`updated_by_ofcr_code`_(từ_`updated_by`)_| |  |  |  |  |  |  |
| 87 | |_cnvr_rsk_|_`charter_cptl_amount`_—_ghi_chú_nvarchar2_→_dcm_| |  |  |  |  |  |  |
| 88 | |_dmn_dt_|_`created_date`_x_`updated_date`_dùng_`date`_(nguồn_là_oracle_`date` |  |  |  |  |  |  không phải TIMESTAMP) | |
| 89 | |_`etl_derived_value`_|_`source_stm_code`_→_thêm_`nhnck.organizations`_| |  |  |  |  |  |  |
| 90 | **attr_nhnck_organizations_ip_postal_address.csv:**_src_columns_đổi_sang_fully_qualified. |  |  |  |  |  |  |
| 91 | **attr_nhnck_organizations_ip_electronic_address.csv:**_thêm_blc_webst_(`ip_elec_addr_type=website`)_+_src_columns_đổi_sang_fully_qualified. |  |  |  |  |  |  |
| 92 | **lưu_ý_pndg_cần_doc_thêm:** |  |  |  |  |  |  |
| 93 | __`created_by`_x_`updated_by`_nguồn_là_`number(10 |  |  |  |  |  | 0)` FK → `USERS.ID` — ETL cần resolve sang Officer surrogate key qua bảng USERS. |
| 94 | __`website`_đã_chuyển_sang_ip_elc_adr_(không_còn_trong_ent_chính)_—_nếu_file_cũ_có_trường_`website`_ở_ent_chính_cần_xóa_(đã_xóa_trong_file_mới_này). |  |  |  |  |  |  |
| 95 | __`sort_order`_src_`number`_→_`small_counter`:_không_cần_ghi_chú_cnvr_rsk_vì_nbr_→_intg_là_tự_nhiên. |  |  |  |  |  |  |
| 96 | elc_adr | STRING |  |  |  |  | Giá trị địa chỉ điện tử (email hoặc số điện thoại) |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | reg_ahr_ou | reg_ahr_ou_id |



**Index:** N/A

**Trigger:** N/A


#### Từ NHNCK.ORGANIZATIONS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Securities Organization Reference. |
| 2 | ip_code | STRING |  |  |  |  | Mã tổ chức. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.ORGANIZATIONS' | Mã hệ thống nguồn. |
| 4 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Địa chỉ email của tổ chức. |
| 6 | --- |  |  |  |  |  |  |
| 7 | **tóm_tắt_các_thay_đổi_so_với_file_cũ:** |  |  |  |  |  |  |
| 8 | **attr_nhnck_organizations.csv_—_12_điểm_sửa:** |  |  |  |  |  |  |
| 9 | |_thay_đổi_|_chi_tiết_| |  |  |  |  |  |  |
| 10 | |---|---| |  |  |  |  |  |  |
| 11 | |_src_columns_fmt_|_đổi_toàn_bộ_sang_fully_qualified_`nhnck.qlnhn.organizations.column`_| |  |  |  |  |  |  |
| 12 | |_tên_attr_|_`organization_name`_→_`securities_org_refr_name`_| |  |  |  |  |  |  |
| 13 | |_tên_attr_|_`english_name`_→_`securities_org_refr_en_name`_| |  |  |  |  |  |  |
| 14 | |_tên_attr_|_`abbreviation`_→_`securities_org_refr_shrt_name`_| |  |  |  |  |  |  |
| 15 | |_tên_attr_|_`representative_name`_→_`legal_rprs_name`_| |  |  |  |  |  |  |
| 16 | |_tên_attr_|_`license_issuer`_→_`license_issur_name`_| |  |  |  |  |  |  |
| 17 | |_tên_attr_|_`parent_org_id/code`_→_`parent_scr_org_refr_id/code`_| |  |  |  |  |  |  |
| 18 | |_tên_attr_|_`organization_st_code`_→_`record_st_code`_+_src_map_đúng_`record_status`_| |  |  |  |  |  |  |
| 19 | |_tên_attr_|_`linked_id`_→_`external_stm_linked_id`_| |  |  |  |  |  |  |
| 20 | |_tên_attr_|_`sync_id`_→_`external_stm_sync_id`_| |  |  |  |  |  |  |
| 21 | |_tên_attr_|_`organization_description`_→_`description`_| |  |  |  |  |  |  |
| 22 | |_thêm_mới_|_`updated_by_ofcr_id`_+_`updated_by_ofcr_code`_(từ_`updated_by`)_| |  |  |  |  |  |  |
| 23 | |_cnvr_rsk_|_`charter_cptl_amount`_—_ghi_chú_nvarchar2_→_dcm_| |  |  |  |  |  |  |
| 24 | |_dmn_dt_|_`created_date`_x_`updated_date`_dùng_`date`_(nguồn_là_oracle_`date` |  |  |  |  |  |  không phải TIMESTAMP) | |
| 25 | |_`etl_derived_value`_|_`source_stm_code`_→_thêm_`nhnck.organizations`_| |  |  |  |  |  |  |
| 26 | **attr_nhnck_organizations_ip_postal_address.csv:**_src_columns_đổi_sang_fully_qualified. |  |  |  |  |  |  |
| 27 | **attr_nhnck_organizations_ip_electronic_address.csv:**_thêm_blc_webst_(`ip_elec_addr_type=website`)_+_src_columns_đổi_sang_fully_qualified. |  |  |  |  |  |  |
| 28 | **lưu_ý_pndg_cần_doc_thêm:** |  |  |  |  |  |  |
| 29 | __`created_by`_x_`updated_by`_nguồn_là_`number(10 |  |  |  |  |  | 0)` FK → `USERS.ID` — ETL cần resolve sang Officer surrogate key qua bảng USERS. |
| 30 | __`website`_đã_chuyển_sang_ip_elc_adr_(không_còn_trong_ent_chính)_—_nếu_file_cũ_có_trường_`website`_ở_ent_chính_cần_xóa_(đã_xóa_trong_file_mới_này). |  |  |  |  |  |  |
| 31 | __`sort_order`_src_`number`_→_`small_counter`:_không_cần_ghi_chú_cnvr_rsk_vì_nbr_→_intg_là_tự_nhiên. |  |  |  |  |  |  |
| 32 | elc_adr | STRING |  |  |  |  | Giá trị địa chỉ điện tử (email hoặc số điện thoại) |
| 33 | ip_id | STRING |  |  | F |  | FK đến Securities Organization Reference. |
| 34 | ip_code | STRING |  |  |  |  | Mã tổ chức. |
| 35 | src_stm_code | STRING |  |  |  | 'NHNCK.ORGANIZATIONS' | Mã hệ thống nguồn. |
| 36 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — fax. |
| 37 | elc_adr_val | STRING | X |  |  |  | Số fax của tổ chức. |
| 38 | --- |  |  |  |  |  |  |
| 39 | **tóm_tắt_các_thay_đổi_so_với_file_cũ:** |  |  |  |  |  |  |
| 40 | **attr_nhnck_organizations.csv_—_12_điểm_sửa:** |  |  |  |  |  |  |
| 41 | |_thay_đổi_|_chi_tiết_| |  |  |  |  |  |  |
| 42 | |---|---| |  |  |  |  |  |  |
| 43 | |_src_columns_fmt_|_đổi_toàn_bộ_sang_fully_qualified_`nhnck.qlnhn.organizations.column`_| |  |  |  |  |  |  |
| 44 | |_tên_attr_|_`organization_name`_→_`securities_org_refr_name`_| |  |  |  |  |  |  |
| 45 | |_tên_attr_|_`english_name`_→_`securities_org_refr_en_name`_| |  |  |  |  |  |  |
| 46 | |_tên_attr_|_`abbreviation`_→_`securities_org_refr_shrt_name`_| |  |  |  |  |  |  |
| 47 | |_tên_attr_|_`representative_name`_→_`legal_rprs_name`_| |  |  |  |  |  |  |
| 48 | |_tên_attr_|_`license_issuer`_→_`license_issur_name`_| |  |  |  |  |  |  |
| 49 | |_tên_attr_|_`parent_org_id/code`_→_`parent_scr_org_refr_id/code`_| |  |  |  |  |  |  |
| 50 | |_tên_attr_|_`organization_st_code`_→_`record_st_code`_+_src_map_đúng_`record_status`_| |  |  |  |  |  |  |
| 51 | |_tên_attr_|_`linked_id`_→_`external_stm_linked_id`_| |  |  |  |  |  |  |
| 52 | |_tên_attr_|_`sync_id`_→_`external_stm_sync_id`_| |  |  |  |  |  |  |
| 53 | |_tên_attr_|_`organization_description`_→_`description`_| |  |  |  |  |  |  |
| 54 | |_thêm_mới_|_`updated_by_ofcr_id`_+_`updated_by_ofcr_code`_(từ_`updated_by`)_| |  |  |  |  |  |  |
| 55 | |_cnvr_rsk_|_`charter_cptl_amount`_—_ghi_chú_nvarchar2_→_dcm_| |  |  |  |  |  |  |
| 56 | |_dmn_dt_|_`created_date`_x_`updated_date`_dùng_`date`_(nguồn_là_oracle_`date` |  |  |  |  |  |  không phải TIMESTAMP) | |
| 57 | |_`etl_derived_value`_|_`source_stm_code`_→_thêm_`nhnck.organizations`_| |  |  |  |  |  |  |
| 58 | **attr_nhnck_organizations_ip_postal_address.csv:**_src_columns_đổi_sang_fully_qualified. |  |  |  |  |  |  |
| 59 | **attr_nhnck_organizations_ip_electronic_address.csv:**_thêm_blc_webst_(`ip_elec_addr_type=website`)_+_src_columns_đổi_sang_fully_qualified. |  |  |  |  |  |  |
| 60 | **lưu_ý_pndg_cần_doc_thêm:** |  |  |  |  |  |  |
| 61 | __`created_by`_x_`updated_by`_nguồn_là_`number(10 |  |  |  |  |  | 0)` FK → `USERS.ID` — ETL cần resolve sang Officer surrogate key qua bảng USERS. |
| 62 | __`website`_đã_chuyển_sang_ip_elc_adr_(không_còn_trong_ent_chính)_—_nếu_file_cũ_có_trường_`website`_ở_ent_chính_cần_xóa_(đã_xóa_trong_file_mới_này). |  |  |  |  |  |  |
| 63 | __`sort_order`_src_`number`_→_`small_counter`:_không_cần_ghi_chú_cnvr_rsk_vì_nbr_→_intg_là_tự_nhiên. |  |  |  |  |  |  |
| 64 | elc_adr | STRING |  |  |  |  | Giá trị địa chỉ điện tử (email hoặc số điện thoại) |
| 65 | ip_id | STRING |  |  | F |  | FK đến Securities Organization Reference. |
| 66 | ip_code | STRING |  |  |  |  | Mã tổ chức. |
| 67 | src_stm_code | STRING |  |  |  | 'NHNCK.ORGANIZATIONS' | Mã hệ thống nguồn. |
| 68 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — số di động. |
| 69 | elc_adr_val | STRING | X |  |  |  | Số di động của tổ chức. |
| 70 | --- |  |  |  |  |  |  |
| 71 | **tóm_tắt_các_thay_đổi_so_với_file_cũ:** |  |  |  |  |  |  |
| 72 | **attr_nhnck_organizations.csv_—_12_điểm_sửa:** |  |  |  |  |  |  |
| 73 | |_thay_đổi_|_chi_tiết_| |  |  |  |  |  |  |
| 74 | |---|---| |  |  |  |  |  |  |
| 75 | |_src_columns_fmt_|_đổi_toàn_bộ_sang_fully_qualified_`nhnck.qlnhn.organizations.column`_| |  |  |  |  |  |  |
| 76 | |_tên_attr_|_`organization_name`_→_`securities_org_refr_name`_| |  |  |  |  |  |  |
| 77 | |_tên_attr_|_`english_name`_→_`securities_org_refr_en_name`_| |  |  |  |  |  |  |
| 78 | |_tên_attr_|_`abbreviation`_→_`securities_org_refr_shrt_name`_| |  |  |  |  |  |  |
| 79 | |_tên_attr_|_`representative_name`_→_`legal_rprs_name`_| |  |  |  |  |  |  |
| 80 | |_tên_attr_|_`license_issuer`_→_`license_issur_name`_| |  |  |  |  |  |  |
| 81 | |_tên_attr_|_`parent_org_id/code`_→_`parent_scr_org_refr_id/code`_| |  |  |  |  |  |  |
| 82 | |_tên_attr_|_`organization_st_code`_→_`record_st_code`_+_src_map_đúng_`record_status`_| |  |  |  |  |  |  |
| 83 | |_tên_attr_|_`linked_id`_→_`external_stm_linked_id`_| |  |  |  |  |  |  |
| 84 | |_tên_attr_|_`sync_id`_→_`external_stm_sync_id`_| |  |  |  |  |  |  |
| 85 | |_tên_attr_|_`organization_description`_→_`description`_| |  |  |  |  |  |  |
| 86 | |_thêm_mới_|_`updated_by_ofcr_id`_+_`updated_by_ofcr_code`_(từ_`updated_by`)_| |  |  |  |  |  |  |
| 87 | |_cnvr_rsk_|_`charter_cptl_amount`_—_ghi_chú_nvarchar2_→_dcm_| |  |  |  |  |  |  |
| 88 | |_dmn_dt_|_`created_date`_x_`updated_date`_dùng_`date`_(nguồn_là_oracle_`date` |  |  |  |  |  |  không phải TIMESTAMP) | |
| 89 | |_`etl_derived_value`_|_`source_stm_code`_→_thêm_`nhnck.organizations`_| |  |  |  |  |  |  |
| 90 | **attr_nhnck_organizations_ip_postal_address.csv:**_src_columns_đổi_sang_fully_qualified. |  |  |  |  |  |  |
| 91 | **attr_nhnck_organizations_ip_electronic_address.csv:**_thêm_blc_webst_(`ip_elec_addr_type=website`)_+_src_columns_đổi_sang_fully_qualified. |  |  |  |  |  |  |
| 92 | **lưu_ý_pndg_cần_doc_thêm:** |  |  |  |  |  |  |
| 93 | __`created_by`_x_`updated_by`_nguồn_là_`number(10 |  |  |  |  |  | 0)` FK → `USERS.ID` — ETL cần resolve sang Officer surrogate key qua bảng USERS. |
| 94 | __`website`_đã_chuyển_sang_ip_elc_adr_(không_còn_trong_ent_chính)_—_nếu_file_cũ_có_trường_`website`_ở_ent_chính_cần_xóa_(đã_xóa_trong_file_mới_này). |  |  |  |  |  |  |
| 95 | __`sort_order`_src_`number`_→_`small_counter`:_không_cần_ghi_chú_cnvr_rsk_vì_nbr_→_intg_là_tự_nhiên. |  |  |  |  |  |  |
| 96 | elc_adr | STRING |  |  |  |  | Giá trị địa chỉ điện tử (email hoặc số điện thoại) |
| 97 | ip_id | STRING |  |  | F |  | FK đến Securities Organization Reference. |
| 98 | ip_code | STRING |  |  |  |  | Mã tổ chức. |
| 99 | src_stm_code | STRING |  |  |  | 'NHNCK.ORGANIZATIONS' | Mã hệ thống nguồn. |
| 100 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — điện thoại. |
| 101 | elc_adr_val | STRING | X |  |  |  | Số điện thoại cố định của tổ chức. |
| 102 | --- |  |  |  |  |  |  |
| 103 | **tóm_tắt_các_thay_đổi_so_với_file_cũ:** |  |  |  |  |  |  |
| 104 | **attr_nhnck_organizations.csv_—_12_điểm_sửa:** |  |  |  |  |  |  |
| 105 | |_thay_đổi_|_chi_tiết_| |  |  |  |  |  |  |
| 106 | |---|---| |  |  |  |  |  |  |
| 107 | |_src_columns_fmt_|_đổi_toàn_bộ_sang_fully_qualified_`nhnck.qlnhn.organizations.column`_| |  |  |  |  |  |  |
| 108 | |_tên_attr_|_`organization_name`_→_`securities_org_refr_name`_| |  |  |  |  |  |  |
| 109 | |_tên_attr_|_`english_name`_→_`securities_org_refr_en_name`_| |  |  |  |  |  |  |
| 110 | |_tên_attr_|_`abbreviation`_→_`securities_org_refr_shrt_name`_| |  |  |  |  |  |  |
| 111 | |_tên_attr_|_`representative_name`_→_`legal_rprs_name`_| |  |  |  |  |  |  |
| 112 | |_tên_attr_|_`license_issuer`_→_`license_issur_name`_| |  |  |  |  |  |  |
| 113 | |_tên_attr_|_`parent_org_id/code`_→_`parent_scr_org_refr_id/code`_| |  |  |  |  |  |  |
| 114 | |_tên_attr_|_`organization_st_code`_→_`record_st_code`_+_src_map_đúng_`record_status`_| |  |  |  |  |  |  |
| 115 | |_tên_attr_|_`linked_id`_→_`external_stm_linked_id`_| |  |  |  |  |  |  |
| 116 | |_tên_attr_|_`sync_id`_→_`external_stm_sync_id`_| |  |  |  |  |  |  |
| 117 | |_tên_attr_|_`organization_description`_→_`description`_| |  |  |  |  |  |  |
| 118 | |_thêm_mới_|_`updated_by_ofcr_id`_+_`updated_by_ofcr_code`_(từ_`updated_by`)_| |  |  |  |  |  |  |
| 119 | |_cnvr_rsk_|_`charter_cptl_amount`_—_ghi_chú_nvarchar2_→_dcm_| |  |  |  |  |  |  |
| 120 | |_dmn_dt_|_`created_date`_x_`updated_date`_dùng_`date`_(nguồn_là_oracle_`date` |  |  |  |  |  |  không phải TIMESTAMP) | |
| 121 | |_`etl_derived_value`_|_`source_stm_code`_→_thêm_`nhnck.organizations`_| |  |  |  |  |  |  |
| 122 | **attr_nhnck_organizations_ip_postal_address.csv:**_src_columns_đổi_sang_fully_qualified. |  |  |  |  |  |  |
| 123 | **attr_nhnck_organizations_ip_electronic_address.csv:**_thêm_blc_webst_(`ip_elec_addr_type=website`)_+_src_columns_đổi_sang_fully_qualified. |  |  |  |  |  |  |
| 124 | **lưu_ý_pndg_cần_doc_thêm:** |  |  |  |  |  |  |
| 125 | __`created_by`_x_`updated_by`_nguồn_là_`number(10 |  |  |  |  |  | 0)` FK → `USERS.ID` — ETL cần resolve sang Officer surrogate key qua bảng USERS. |
| 126 | __`website`_đã_chuyển_sang_ip_elc_adr_(không_còn_trong_ent_chính)_—_nếu_file_cũ_có_trường_`website`_ở_ent_chính_cần_xóa_(đã_xóa_trong_file_mới_này). |  |  |  |  |  |  |
| 127 | __`sort_order`_src_`number`_→_`small_counter`:_không_cần_ghi_chú_cnvr_rsk_vì_nbr_→_intg_là_tự_nhiên. |  |  |  |  |  |  |
| 128 | elc_adr | STRING |  |  |  |  | Giá trị địa chỉ điện tử (email hoặc số điện thoại) |
| 129 | ip_id | STRING |  |  | F |  | FK đến Securities Organization Reference. |
| 130 | ip_code | STRING |  |  |  |  | Mã tổ chức. |
| 131 | src_stm_code | STRING |  |  |  | 'NHNCK.ORGANIZATIONS' | Mã hệ thống nguồn. |
| 132 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — website. |
| 133 | elc_adr_val | STRING | X |  |  |  | Địa chỉ website của tổ chức. |
| 134 | --- |  |  |  |  |  |  |
| 135 | **tóm_tắt_các_thay_đổi_so_với_file_cũ:** |  |  |  |  |  |  |
| 136 | **attr_nhnck_organizations.csv_—_12_điểm_sửa:** |  |  |  |  |  |  |
| 137 | |_thay_đổi_|_chi_tiết_| |  |  |  |  |  |  |
| 138 | |---|---| |  |  |  |  |  |  |
| 139 | |_src_columns_fmt_|_đổi_toàn_bộ_sang_fully_qualified_`nhnck.qlnhn.organizations.column`_| |  |  |  |  |  |  |
| 140 | |_tên_attr_|_`organization_name`_→_`securities_org_refr_name`_| |  |  |  |  |  |  |
| 141 | |_tên_attr_|_`english_name`_→_`securities_org_refr_en_name`_| |  |  |  |  |  |  |
| 142 | |_tên_attr_|_`abbreviation`_→_`securities_org_refr_shrt_name`_| |  |  |  |  |  |  |
| 143 | |_tên_attr_|_`representative_name`_→_`legal_rprs_name`_| |  |  |  |  |  |  |
| 144 | |_tên_attr_|_`license_issuer`_→_`license_issur_name`_| |  |  |  |  |  |  |
| 145 | |_tên_attr_|_`parent_org_id/code`_→_`parent_scr_org_refr_id/code`_| |  |  |  |  |  |  |
| 146 | |_tên_attr_|_`organization_st_code`_→_`record_st_code`_+_src_map_đúng_`record_status`_| |  |  |  |  |  |  |
| 147 | |_tên_attr_|_`linked_id`_→_`external_stm_linked_id`_| |  |  |  |  |  |  |
| 148 | |_tên_attr_|_`sync_id`_→_`external_stm_sync_id`_| |  |  |  |  |  |  |
| 149 | |_tên_attr_|_`organization_description`_→_`description`_| |  |  |  |  |  |  |
| 150 | |_thêm_mới_|_`updated_by_ofcr_id`_+_`updated_by_ofcr_code`_(từ_`updated_by`)_| |  |  |  |  |  |  |
| 151 | |_cnvr_rsk_|_`charter_cptl_amount`_—_ghi_chú_nvarchar2_→_dcm_| |  |  |  |  |  |  |
| 152 | |_dmn_dt_|_`created_date`_x_`updated_date`_dùng_`date`_(nguồn_là_oracle_`date` |  |  |  |  |  |  không phải TIMESTAMP) | |
| 153 | |_`etl_derived_value`_|_`source_stm_code`_→_thêm_`nhnck.organizations`_| |  |  |  |  |  |  |
| 154 | **attr_nhnck_organizations_ip_postal_address.csv:**_src_columns_đổi_sang_fully_qualified. |  |  |  |  |  |  |
| 155 | **attr_nhnck_organizations_ip_electronic_address.csv:**_thêm_blc_webst_(`ip_elec_addr_type=website`)_+_src_columns_đổi_sang_fully_qualified. |  |  |  |  |  |  |
| 156 | **lưu_ý_pndg_cần_doc_thêm:** |  |  |  |  |  |  |
| 157 | __`created_by`_x_`updated_by`_nguồn_là_`number(10 |  |  |  |  |  | 0)` FK → `USERS.ID` — ETL cần resolve sang Officer surrogate key qua bảng USERS. |
| 158 | __`website`_đã_chuyển_sang_ip_elc_adr_(không_còn_trong_ent_chính)_—_nếu_file_cũ_có_trường_`website`_ở_ent_chính_cần_xóa_(đã_xóa_trong_file_mới_này). |  |  |  |  |  |  |
| 159 | __`sort_order`_src_`number`_→_`small_counter`:_không_cần_ghi_chú_cnvr_rsk_vì_nbr_→_intg_là_tự_nhiên. |  |  |  |  |  |  |
| 160 | elc_adr | STRING |  |  |  |  | Giá trị địa chỉ điện tử (email hoặc số điện thoại) |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_org_refr | scr_org_refr_id |



**Index:** N/A

**Trigger:** N/A


#### Từ NHNCK.USERS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Regulatory Authority Officer |
| 2 | ip_code | STRING |  |  |  |  | Mã cán bộ UBCK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.USERS' | Mã nguồn dữ liệu |
| 4 | --- |  |  |  |  |  |  |
| 5 | **tóm_tắt_các_thay_đổi_so_với_file_cũ:** |  |  |  |  |  |  |
| 6 | **attr_nhnck_organizations.csv_—_12_điểm_sửa:** |  |  |  |  |  |  |
| 7 | |_thay_đổi_|_chi_tiết_| |  |  |  |  |  |  |
| 8 | |---|---| |  |  |  |  |  |  |
| 9 | |_src_columns_fmt_|_đổi_toàn_bộ_sang_fully_qualified_`nhnck.qlnhn.organizations.column`_| |  |  |  |  |  |  |
| 10 | |_tên_attr_|_`organization_name`_→_`securities_org_refr_name`_| |  |  |  |  |  |  |
| 11 | |_tên_attr_|_`english_name`_→_`securities_org_refr_en_name`_| |  |  |  |  |  |  |
| 12 | |_tên_attr_|_`abbreviation`_→_`securities_org_refr_shrt_name`_| |  |  |  |  |  |  |
| 13 | |_tên_attr_|_`representative_name`_→_`legal_rprs_name`_| |  |  |  |  |  |  |
| 14 | |_tên_attr_|_`license_issuer`_→_`license_issur_name`_| |  |  |  |  |  |  |
| 15 | |_tên_attr_|_`parent_org_id/code`_→_`parent_scr_org_refr_id/code`_| |  |  |  |  |  |  |
| 16 | |_tên_attr_|_`organization_st_code`_→_`record_st_code`_+_src_map_đúng_`record_status`_| |  |  |  |  |  |  |
| 17 | |_tên_attr_|_`linked_id`_→_`external_stm_linked_id`_| |  |  |  |  |  |  |
| 18 | |_tên_attr_|_`sync_id`_→_`external_stm_sync_id`_| |  |  |  |  |  |  |
| 19 | |_tên_attr_|_`organization_description`_→_`description`_| |  |  |  |  |  |  |
| 20 | |_thêm_mới_|_`updated_by_ofcr_id`_+_`updated_by_ofcr_code`_(từ_`updated_by`)_| |  |  |  |  |  |  |
| 21 | |_cnvr_rsk_|_`charter_cptl_amount`_—_ghi_chú_nvarchar2_→_dcm_| |  |  |  |  |  |  |
| 22 | |_dmn_dt_|_`created_date`_x_`updated_date`_dùng_`date`_(nguồn_là_oracle_`date` |  |  |  |  |  |  không phải TIMESTAMP) | |
| 23 | |_`etl_derived_value`_|_`source_stm_code`_→_thêm_`nhnck.organizations`_| |  |  |  |  |  |  |
| 24 | **attr_nhnck_organizations_ip_postal_address.csv:**_src_columns_đổi_sang_fully_qualified. |  |  |  |  |  |  |
| 25 | **attr_nhnck_organizations_ip_electronic_address.csv:**_thêm_blc_webst_(`ip_elec_addr_type=website`)_+_src_columns_đổi_sang_fully_qualified. |  |  |  |  |  |  |
| 26 | **lưu_ý_pndg_cần_doc_thêm:** |  |  |  |  |  |  |
| 27 | __`created_by`_x_`updated_by`_nguồn_là_`number(10 |  |  |  |  |  | 0)` FK → `USERS.ID` — ETL cần resolve sang Officer surrogate key qua bảng USERS. |
| 28 | __`website`_đã_chuyển_sang_ip_elc_adr_(không_còn_trong_ent_chính)_—_nếu_file_cũ_có_trường_`website`_ở_ent_chính_cần_xóa_(đã_xóa_trong_file_mới_này). |  |  |  |  |  |  |
| 29 | __`sort_order`_src_`number`_→_`small_counter`:_không_cần_ghi_chú_cnvr_rsk_vì_nbr_→_intg_là_tự_nhiên. |  |  |  |  |  |  |
| 30 | elc_adr | STRING |  |  |  |  | Giá trị địa chỉ điện tử (email hoặc số điện thoại) |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | reg_ahr_ofcr | reg_ahr_ofcr_id |



**Index:** N/A

**Trigger:** N/A


#### Từ NHNCK.PROFESSIONALS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Securities Practitioner. |
| 2 | ip_code | STRING |  |  |  |  | Mã người hành nghề. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.PROFESSIONALS' | Mã hệ thống nguồn. |
| 4 | --- |  |  |  |  |  |  |
| 5 | **tóm_tắt_các_thay_đổi_so_với_file_cũ:** |  |  |  |  |  |  |
| 6 | **attr_nhnck_organizations.csv_—_12_điểm_sửa:** |  |  |  |  |  |  |
| 7 | |_thay_đổi_|_chi_tiết_| |  |  |  |  |  |  |
| 8 | |---|---| |  |  |  |  |  |  |
| 9 | |_src_columns_fmt_|_đổi_toàn_bộ_sang_fully_qualified_`nhnck.qlnhn.organizations.column`_| |  |  |  |  |  |  |
| 10 | |_tên_attr_|_`organization_name`_→_`securities_org_refr_name`_| |  |  |  |  |  |  |
| 11 | |_tên_attr_|_`english_name`_→_`securities_org_refr_en_name`_| |  |  |  |  |  |  |
| 12 | |_tên_attr_|_`abbreviation`_→_`securities_org_refr_shrt_name`_| |  |  |  |  |  |  |
| 13 | |_tên_attr_|_`representative_name`_→_`legal_rprs_name`_| |  |  |  |  |  |  |
| 14 | |_tên_attr_|_`license_issuer`_→_`license_issur_name`_| |  |  |  |  |  |  |
| 15 | |_tên_attr_|_`parent_org_id/code`_→_`parent_scr_org_refr_id/code`_| |  |  |  |  |  |  |
| 16 | |_tên_attr_|_`organization_st_code`_→_`record_st_code`_+_src_map_đúng_`record_status`_| |  |  |  |  |  |  |
| 17 | |_tên_attr_|_`linked_id`_→_`external_stm_linked_id`_| |  |  |  |  |  |  |
| 18 | |_tên_attr_|_`sync_id`_→_`external_stm_sync_id`_| |  |  |  |  |  |  |
| 19 | |_tên_attr_|_`organization_description`_→_`description`_| |  |  |  |  |  |  |
| 20 | |_thêm_mới_|_`updated_by_ofcr_id`_+_`updated_by_ofcr_code`_(từ_`updated_by`)_| |  |  |  |  |  |  |
| 21 | |_cnvr_rsk_|_`charter_cptl_amount`_—_ghi_chú_nvarchar2_→_dcm_| |  |  |  |  |  |  |
| 22 | |_dmn_dt_|_`created_date`_x_`updated_date`_dùng_`date`_(nguồn_là_oracle_`date` |  |  |  |  |  |  không phải TIMESTAMP) | |
| 23 | |_`etl_derived_value`_|_`source_stm_code`_→_thêm_`nhnck.organizations`_| |  |  |  |  |  |  |
| 24 | **attr_nhnck_organizations_ip_postal_address.csv:**_src_columns_đổi_sang_fully_qualified. |  |  |  |  |  |  |
| 25 | **attr_nhnck_organizations_ip_electronic_address.csv:**_thêm_blc_webst_(`ip_elec_addr_type=website`)_+_src_columns_đổi_sang_fully_qualified. |  |  |  |  |  |  |
| 26 | **lưu_ý_pndg_cần_doc_thêm:** |  |  |  |  |  |  |
| 27 | __`created_by`_x_`updated_by`_nguồn_là_`number(10 |  |  |  |  |  | 0)` FK → `USERS.ID` — ETL cần resolve sang Officer surrogate key qua bảng USERS. |
| 28 | __`website`_đã_chuyển_sang_ip_elc_adr_(không_còn_trong_ent_chính)_—_nếu_file_cũ_có_trường_`website`_ở_ent_chính_cần_xóa_(đã_xóa_trong_file_mới_này). |  |  |  |  |  |  |
| 29 | __`sort_order`_src_`number`_→_`small_counter`:_không_cần_ghi_chú_cnvr_rsk_vì_nbr_→_intg_là_tự_nhiên. |  |  |  |  |  |  |
| 30 | elc_adr | STRING |  |  |  |  | Giá trị địa chỉ điện tử (email hoặc số điện thoại) |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_prac | scr_prac_id |



**Index:** N/A

**Trigger:** N/A





### Bảng ip_pst_adr



#### Từ NHNCK.UNITS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Regulatory Authority Organization Unit |
| 2 | ip_code | STRING |  |  |  |  | Mã đơn vị |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.UNITS' | Mã hệ thống nguồn |
| 4 | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ — trụ sở chính |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở đơn vị |
| 6 | prov_id | STRING | X |  | F |  | FK đến tỉnh/thành phố trụ sở. |
| 7 | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). |
| 8 | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. |
| 9 | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. |
| 10 | geo_id | STRING | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. |
| 11 | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. |
| 12 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |
| 13 | cty_id | STRING | X |  | F |  | FK đến Geographic Area — quốc gia. |
| 14 | cty_code | STRING | X |  |  |  | Mã quốc gia. |
| 15 | dstc_id | STRING | X |  | F |  | FK đến Geographic Area — quận/huyện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | reg_ahr_ou | reg_ahr_ou_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |
| cty_id | geo | geo_id |
| dstc_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ NHNCK.ORGANIZATIONS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Securities Organization Reference. |
| 2 | ip_code | STRING |  |  |  |  | Mã tổ chức. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.ORGANIZATIONS' | Mã hệ thống nguồn. |
| 4 | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ — trụ sở chính. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở chính của tổ chức. |
| 6 | prov_id | STRING | X |  | F |  | FK đến tỉnh/thành phố trụ sở. |
| 7 | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). |
| 8 | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. |
| 9 | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. |
| 10 | geo_id | STRING | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. |
| 11 | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. |
| 12 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |
| 13 | cty_id | STRING | X |  | F |  | FK đến Geographic Area — quốc gia. |
| 14 | cty_code | STRING | X |  |  |  | Mã quốc gia. |
| 15 | dstc_id | STRING | X |  | F |  | FK đến Geographic Area — quận/huyện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_org_refr | scr_org_refr_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |
| cty_id | geo | geo_id |
| dstc_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ NHNCK.PROFESSIONALS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Securities Practitioner. |
| 2 | ip_code | STRING |  |  |  |  | Mã người hành nghề. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.PROFESSIONALS' | Mã hệ thống nguồn. |
| 4 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |
| 5 | cty_id | STRING | X |  | F |  | FK đến Geographic Area — quốc gia. |
| 6 | cty_code | STRING | X |  |  |  | Mã quốc gia. |
| 7 | dstc_id | STRING | X |  | F |  | FK đến Geographic Area — quận/huyện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_prac | scr_prac_id |
| cty_id | geo | geo_id |
| dstc_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A





### Stored Procedure/Function

N/A

### Package

N/A


