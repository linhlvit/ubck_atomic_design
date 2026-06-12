## NHNCK — Hệ thống Quản lý giám sát người hành nghề chứng khoán

### Các mô hình quan hệ dữ liệu

![Mô hình quan hệ dữ liệu NHNCK](NHNCK/fragments/NHNCK_diagram.png)

**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | scr_prac_conduct_vln | Vi phạm pháp luật hoặc hành chính của người hành nghề chứng khoán được ghi nhận kèm quyết định xử lý. Mỗi dòng = 1 sự kiện vi phạm insert-only. FK đến Practitioner và Decision. |
| 2 | scr_prac_prof_trn_clss_enrollment | Đăng ký tham gia và kết quả học tập của người hành nghề tại một khóa đào tạo chuyên môn. Ghi nhận điểm thi, kết quả đạt/không đạt và trạng thái ghi danh. |




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




### Stored Procedure/Function

N/A

### Package

N/A
