## 2.1 NHNCK — Phân hệ Quản lý giám sát người hành nghề chứng khoán

### 2.1.1 Các mô hình quan hệ dữ liệu

- DBML tổng hợp (tất cả bảng): [`NHNCK.dbml`](NHNCK.dbml) — paste vào https://dbdiagram.io để render.
- Diagram theo mảng nghiệp vụ:
  - **UID03 — Quản lý hồ sơ**: [`NHNCK_UID03.dbml`](NHNCK_UID03.dbml)


**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | scr_prac_license_ap | Hồ sơ đăng ký cấp/cấp lại/gia hạn chứng chỉ hành nghề chứng khoán. Ghi nhận đầy đủ thông tin người nộp và kết quả xử lý. |
| 2 | scr_prac_license_ap_ed_ctf_doc | Văn bằng/chứng chỉ học tập đính kèm hồ sơ CCHN. Ghi nhận loại chuyên môn và file đính kèm kèm trạng thái thẩm định. |
| 3 | scr_prac_license_ap_doc_attch | Tài liệu đính kèm hồ sơ CCHN. Ghi nhận loại tài liệu và trạng thái thẩm định. |




### 2.1.2 Bảng scr_prac_license_ap

- **Mô tả:** Hồ sơ đăng ký cấp/cấp lại/gia hạn chứng chỉ hành nghề chứng khoán. Ghi nhận đầy đủ thông tin người nộp và kết quả xử lý.
- **Tên vật lý:** scr_prac_license_ap
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | license_ap_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | license_ap_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.Applications' | Mã nguồn dữ liệu |
| 4 | prac_id | BIGINT |  |  | F |  | FK đến Securities Practitioner |
| 5 | prac_code | STRING |  |  |  |  | Mã người hành nghề |
| 6 | ctf_tp_code | STRING | X |  |  |  | Mã loại chứng chỉ đăng ký |
| 7 | ap_st_code | STRING | X |  |  |  | Trạng thái hồ sơ (FK → ApplicationStatuses) |
| 8 | license_ctf_doc_id | BIGINT | X |  | F |  | FK đến CCHN đã được cấp (nếu có) |
| 9 | license_ctf_doc_code | STRING | X |  |  |  | Mã CCHN đã cấp |
| 10 | prev_ctf_tp_code | STRING | X |  |  |  | Mã loại chứng chỉ trước đó |
| 11 | prev_license_ctf_doc_id | BIGINT | X |  | F |  | FK đến CCHN trước đó |
| 12 | prev_license_ctf_doc_code | STRING | X |  |  |  | Mã CCHN trước đó |
| 13 | exam_ases_id | BIGINT | X |  | F |  | FK đến đợt thi (nếu hồ sơ gắn với kỳ thi) |
| 14 | exam_ases_code | STRING | X |  |  |  | Mã đợt thi |
| 15 | assignee_ofcr_id | BIGINT | X |  | F |  | FK đến cán bộ xử lý |
| 16 | assignee_ofcr_code | STRING | X |  |  |  | Mã cán bộ xử lý |
| 17 | license_ap_verf_st_id | BIGINT | X |  | F |  | FK đến yêu cầu phê duyệt lãnh đạo |
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
| 40 | crt_by_ofcr_id | BIGINT | X |  | F |  | FK đến Officer |
| 41 | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo |
| 42 | udt_by_ofcr_id | BIGINT | X |  | F |  | FK đến Officer |
| 43 | udt_by_ofcr_code | STRING | X |  |  |  | Mã người cập nhật |
| 44 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo |
| 45 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật |


#### 2.1.2.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| License Application Id | license_ap_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Practitioner Id | prac_id | scr_prac | Practitioner Id | prac_id |
| License Certificate Document Id | license_ctf_doc_id | scr_prac_license_ctf_doc | License Certificate Document Id | license_ctf_doc_id |
| Previous License Certificate Document Id | prev_license_ctf_doc_id | scr_prac_license_ctf_doc | License Certificate Document Id | license_ctf_doc_id |
| Examination Assessment Id | exam_ases_id | scr_prac_qualf_exam_ases | Examination Assessment Id | exam_ases_id |
| Assignee Officer Id | assignee_ofcr_id | regulatory_authority_officer | Officer Id |  |
| License Application Verification Status Id | license_ap_verf_st_id | scr_prac_license_ap_verf_st | License Application Verification Status Id | license_ap_verf_st_id |
| Created By Officer Id | crt_by_ofcr_id | regulatory_authority_officer | Officer Id |  |
| Updated By Officer Id | udt_by_ofcr_id | regulatory_authority_officer | Officer Id |  |






### 2.1.3 Bảng scr_prac_license_ap_ed_ctf_doc

- **Mô tả:** Văn bằng/chứng chỉ học tập đính kèm hồ sơ CCHN. Ghi nhận loại chuyên môn và file đính kèm kèm trạng thái thẩm định.
- **Tên vật lý:** scr_prac_license_ap_ed_ctf_doc
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | license_ap_ed_ctf_doc_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | license_ap_ed_ctf_doc_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.ApplicationSpecializations' | Mã nguồn dữ liệu |
| 4 | license_ap_id | BIGINT |  |  | F |  | FK đến hồ sơ |
| 5 | license_ap_code | STRING |  |  |  |  | Mã hồ sơ |
| 6 | specialization_tp_code | STRING |  |  |  |  | Mã chuyên môn (FK → Specializations) |
| 7 | file_nm | STRING | X |  |  |  | Tên file chứng chỉ chuyên môn |
| 8 | file_path | STRING | X |  |  |  | Đường dẫn file |
| 9 | file_fmt | STRING | X |  |  |  | Loại file |
| 10 | file_sz | STRING | X |  |  |  | Dung lượng file (bytes) |
| 11 | specialization_note | STRING | X |  |  |  | Nội dung/ghi chú |
| 12 | aprs_st_code | STRING | X |  |  |  | Trạng thái thẩm định |
| 13 | assignee_ofcr_id | BIGINT | X |  | F |  | FK đến người thẩm định |
| 14 | assignee_ofcr_code | STRING | X |  |  |  | Mã người thẩm định |
| 15 | appraisaled_tms | TIMESTAMP | X |  |  |  | Ngày thẩm định |


#### 2.1.3.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| License Application Education Certificate Document Id | license_ap_ed_ctf_doc_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| License Application Id | license_ap_id | scr_prac_license_ap | License Application Id | license_ap_id |
| Assignee Officer Id | assignee_ofcr_id | regulatory_authority_officer | Officer Id |  |






### 2.1.4 Bảng scr_prac_license_ap_doc_attch

- **Mô tả:** Tài liệu đính kèm hồ sơ CCHN. Ghi nhận loại tài liệu và trạng thái thẩm định.
- **Tên vật lý:** scr_prac_license_ap_doc_attch
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | license_ap_doc_attch_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | license_ap_doc_attch_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.ApplicationDocuments' | Mã nguồn dữ liệu |
| 4 | license_ap_id | BIGINT |  |  | F |  | FK đến hồ sơ |
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
| 17 | assignee_ofcr_id | BIGINT | X |  | F |  | FK đến người thẩm định |
| 18 | assignee_ofcr_code | STRING | X |  |  |  | Mã người thẩm định |
| 19 | appraisaled_tms | TIMESTAMP | X |  |  |  | Ngày thẩm định |
| 20 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo |


#### 2.1.4.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| License Application Document Attachment Id | license_ap_doc_attch_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| License Application Id | license_ap_id | scr_prac_license_ap | License Application Id | license_ap_id |
| Assignee Officer Id | assignee_ofcr_id | regulatory_authority_officer | Officer Id |  |





