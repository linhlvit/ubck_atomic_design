## 2.{IDX} NHNCK — Phân hệ Quản lý giám sát người hành nghề chứng khoán

### 2.{IDX}.1 Các mô hình quan hệ dữ liệu

- DBML tổng hợp (tất cả bảng): [`NHNCK.dbml`](NHNCK.dbml) — paste vào https://dbdiagram.io để render.
- Diagram theo mảng nghiệp vụ:
  - **UID01 — Quản trị phân hệ**: [`NHNCK_UID01.dbml`](NHNCK_UID01.dbml)
  - **UID02 — Quản lý danh mục dùng riêng**: [`NHNCK_UID02.dbml`](NHNCK_UID02.dbml)
  - **UID03 — Quản lý hồ sơ**: [`NHNCK_UID03.dbml`](NHNCK_UID03.dbml)
  - **UID04 — Quản lý thi sát hạch**: [`NHNCK_UID04.dbml`](NHNCK_UID04.dbml)
  - **UID05 — Quản lý chứng chỉ hành nghề**: [`NHNCK_UID05.dbml`](NHNCK_UID05.dbml)
  - **UID06 — Quản lý người hành nghề chứng khoán**: [`NHNCK_UID06.dbml`](NHNCK_UID06.dbml)
  - **UID10 — Quản lý đào tạo tập huấn**: [`NHNCK_UID10.dbml`](NHNCK_UID10.dbml)


**Danh sách bảng:**

| STT | Thực thể | Tên bảng | Mô tả |
|---|---|---|---|
| 1 | Securities Practitioner License Application | scr_practitioner_license_ap | Hồ sơ đăng ký cấp/cấp lại/gia hạn chứng chỉ hành nghề chứng khoán. Ghi nhận đầy đủ thông tin người nộp và kết quả xử lý. |
| 2 | Securities Practitioner License Application Education Certificate Document | scr_practitioner_license_ap_ed_ctf_doc | Văn bằng/chứng chỉ học tập đính kèm hồ sơ CCHN. Ghi nhận loại chuyên môn và file đính kèm kèm trạng thái thẩm định. |
| 3 | Securities Practitioner License Application Document Attachment | scr_practitioner_license_ap_doc_attachment | Tài liệu đính kèm hồ sơ CCHN. Ghi nhận loại tài liệu và trạng thái thẩm định. |
| 4 | Securities Practitioner License Application Processing Activity Log | scr_practitioner_license_ap_pcs_avy_log | Nhật ký hoạt động xử lý hồ sơ CCHN. Ghi nhận từng bước xử lý và trạng thái hồ sơ theo thời gian. |
| 5 | Securities Practitioner License Application Fee | scr_practitioner_license_ap_fee | Phí thực tế phát sinh theo từng hồ sơ đăng ký CCHN. Ghi nhận loại phí và trạng thái thanh toán. |
| 6 | Securities Practitioner License Application Verification Status | scr_practitioner_license_ap_verf_st | Bản ghi phê duyệt nội bộ hồ sơ CCHN theo cấp lãnh đạo. Ghi nhận người phê duyệt và kết quả phê duyệt tại từng cấp. |
| 7 | Securities Practitioner | scr_practitioner | Người hành nghề chứng khoán được UBCKNN cấp phép. Ghi nhận thông tin cá nhân và trạng thái hành nghề. Attribute chi tiết (BirthDate full |
| 8 | Involved Party Postal Address | ip_pst_adr | Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn. |
| 9 | Involved Party Electronic Address | ip_elc_adr | Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn. |
| 10 | Involved Party Alternative Identification | ip_alt_identn | Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn. |
| 11 | Securities Practitioner License Certificate Document | scr_practitioner_license_ctf_doc | Chứng chỉ hành nghề chứng khoán được cấp cho người hành nghề. Ghi nhận loại chứng chỉ và quyết định cấp/thu hồi. |
| 12 | Securities Practitioner License Certificate Group Document | scr_practitioner_license_ctf_grp_doc | Nhóm chứng chỉ hành nghề trong một quyết định cấp/thu hồi/hủy tập thể. Liên kết với quyết định hành chính. |
| 13 | Securities Practitioner License Certificate Group Member | scr_practitioner_license_ctf_grp_mbr | Quan hệ thành viên giữa chứng chỉ hành nghề và nhóm cấp/thu hồi. Liên kết Certificate ↔ Group ↔ Application. |
| 14 | Securities Practitioner License Certificate Document Status History | scr_practitioner_license_ctf_doc_st_hist | Lịch sử thay đổi trạng thái của chứng chỉ hành nghề. Ghi nhận trạng thái trước/sau và lý do thay đổi. |
| 15 | Securities Practitioner License Certificate Document Activity Log | scr_practitioner_license_ctf_doc_avy_log | Nhật ký hoạt động tác động lên chứng chỉ hành nghề. Ghi nhận hành động và người thực hiện. |
| 16 | Securities Practitioner Related Party | scr_practitioner_rel_p | Quan hệ thân nhân của người hành nghề chứng khoán. Ghi nhận loại quan hệ và thông tin người liên quan. |
| 17 | Securities Practitioner Conduct Violation | scr_practitioner_conduct_vln | Vi phạm pháp luật hoặc hành chính của người hành nghề chứng khoán. Ghi nhận loại vi phạm và quyết định xử lý. |
| 18 | Securities Practitioner Organization Employment Report | scr_practitioner_org_emp_rpt | Báo cáo của tổ chức về tình trạng tuyển dụng/chấm dứt hợp đồng người hành nghề chứng khoán. |
| 19 | Securities Practitioner Identity Verification Record | scr_practitioner_identity_verf_rcrd | Kết quả xác thực danh tính người hành nghề qua hệ thống C06 của Bộ Công An. Lưu trạng thái và phản hồi xác thực. |
| 20 | Securities Practitioner Professional Training Class | scr_practitioner_prof_trn_clss | Khóa đào tạo chuyên môn nghiệp vụ chứng khoán do UBCKNN tổ chức. Ghi nhận thông tin khóa học và ngày thi. |
| 21 | Securities Practitioner Professional Training Class Enrollment | scr_practitioner_prof_trn_clss_enrollment | Đăng ký tham gia và kết quả học tập của người hành nghề tại một khóa đào tạo chuyên môn. |
| 22 | Securities Practitioner Qualification Examination Assessment | scr_practitioner_qualf_exam_ases | Đợt thi sát hạch cấp chứng chỉ hành nghề chứng khoán. Ghi nhận thông tin tổ chức đợt thi và quyết định công nhận kết quả. |
| 23 | Securities Practitioner Qualification Examination Assessment Result | scr_practitioner_qualf_exam_ases_rslt | Kết quả thi sát hạch của từng thí sinh trong một đợt thi. Ghi nhận điểm thi và kết quả đạt/không đạt. |
| 24 | Securities Practitioner Qualification Examination Assessment Fee | scr_practitioner_qualf_exam_ases_fee | Biểu phí thi sát hạch theo đợt thi và loại chứng chỉ. Ghi nhận mức phí thi và phúc khảo. |
| 25 | Securities Organization Reference | scr_org_refr | Tổ chức tham gia thị trường chứng khoán (CTCK/QLQ/NH) được UBCKNN quản lý. Danh mục tổ chức tham chiếu trong hệ thống NHNCK. |
| 26 | Securities Practitioner License Decision Document | scr_practitioner_license_dcsn_doc | Quyết định hành chính của UBCKNN về cấp/thu hồi/hủy chứng chỉ hành nghề chứng khoán. |
| 27 | Regulatory Authority Organization Unit | reg_ahr_ou | Đơn vị/phòng ban thuộc UBCKNN. Cấu trúc phân cấp gộp Units và Departments. |



### 2.{IDX}.2 Bảng Securities Practitioner License Application

- **Mô tả:** Hồ sơ đăng ký cấp/cấp lại/gia hạn chứng chỉ hành nghề chứng khoán. Ghi nhận đầy đủ thông tin người nộp và kết quả xử lý.
- **Tên vật lý:** scr_practitioner_license_ap
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | License Application Id | license_ap_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.Applications |  | PK surrogate. BCV: "Government Registration" (Arrangement). Hồ sơ đăng ký CCHN. |
| 2 | License Application Code | license_ap_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.Applications | Id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.Applications' | Mã nguồn dữ liệu | NHNCK.Applications |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Practitioner Id | practitioner_id | BIGINT |  |  | F |  | FK đến Securities Practitioner | NHNCK.Applications | ProfessionalId |  |
| 5 | Practitioner Code | practitioner_code | STRING |  |  |  |  | Mã người hành nghề | NHNCK.Applications | ProfessionalId |  |
| 6 | Certificate Type Code | ctf_tp_code | STRING | X |  |  |  | Mã loại chứng chỉ đăng ký | NHNCK.Applications | CertificateId | Scheme: CERTIFICATE_TYPE. |
| 7 | Application Status Code | ap_st_code | STRING | X |  |  |  | Trạng thái hồ sơ (FK → ApplicationStatuses) | NHNCK.Applications | StatusId | Scheme: APPLICATION_STATUS. |
| 8 | License Certificate Document Id | license_ctf_doc_id | BIGINT | X |  | F |  | FK đến CCHN đã được cấp (nếu có) | NHNCK.Applications | CertificateRecordId |  |
| 9 | License Certificate Document Code | license_ctf_doc_code | STRING | X |  |  |  | Mã CCHN đã cấp | NHNCK.Applications | CertificateRecordId |  |
| 10 | Previous Certificate Type Code | prev_ctf_tp_code | STRING | X |  |  |  | Mã loại chứng chỉ trước đó | NHNCK.Applications | PreviousCertificateId | Scheme: CERTIFICATE_TYPE. |
| 11 | Previous License Certificate Document Id | prev_license_ctf_doc_id | BIGINT | X |  | F |  | FK đến CCHN trước đó | NHNCK.Applications | PreviousCertificateRecordId |  |
| 12 | Previous License Certificate Document Code | prev_license_ctf_doc_code | STRING | X |  |  |  | Mã CCHN trước đó | NHNCK.Applications | PreviousCertificateRecordId |  |
| 13 | Examination Assessment Id | exam_ases_id | BIGINT | X |  | F |  | FK đến đợt thi (nếu hồ sơ gắn với kỳ thi) | NHNCK.Applications | ExamSessionId |  |
| 14 | Examination Assessment Code | exam_ases_code | STRING | X |  |  |  | Mã đợt thi | NHNCK.Applications | ExamSessionId |  |
| 15 | Assignee Officer Id | assignee_ofcr_id | BIGINT | X |  | F |  | FK đến cán bộ xử lý | NHNCK.Applications | AssigneeId |  |
| 16 | Assignee Officer Code | assignee_ofcr_code | STRING | X |  |  |  | Mã cán bộ xử lý | NHNCK.Applications | AssigneeId |  |
| 17 | License Application Verification Status Id | license_ap_verf_st_id | BIGINT | X |  | F |  | FK đến yêu cầu phê duyệt lãnh đạo | NHNCK.Applications | InfoVerifyId |  |
| 18 | License Application Verification Status Code | license_ap_verf_st_code | STRING | X |  |  |  | Mã yêu cầu phê duyệt | NHNCK.Applications | InfoVerifyId |  |
| 19 | Application Code | ap_code | STRING | X |  |  |  | Mã hồ sơ (mã nghiệp vụ) | NHNCK.Applications | ApplicationCode |  |
| 20 | Application Title | ap_ttl | STRING | X |  |  |  | Tiêu đề hồ sơ | NHNCK.Applications | Title |  |
| 21 | Registration Type Code | rgst_tp_code | STRING | X |  |  |  | Loại đăng ký | NHNCK.Applications | RegistrationType | Scheme: REGISTRATION_TYPE. |
| 22 | Application Type Code | ap_tp_code | STRING | X |  |  |  | Loại hồ sơ | NHNCK.Applications | ApplicationType | Scheme: APPLICATION_TYPE. |
| 23 | Submission Date | submission_dt | DATE | X |  |  |  | Ngày nộp hồ sơ | NHNCK.Applications | SubmissionDate |  |
| 24 | Supplement Date | supplement_dt | DATE | X |  |  |  | Ngày bổ sung hồ sơ | NHNCK.Applications | SupplementDate |  |
| 25 | Supplement Letter Date | supplement_ltr_dt | DATE | X |  |  |  | Ngày thư yêu cầu bổ sung | NHNCK.Applications | SupplementLetterDate |  |
| 26 | Reissue Reason | reissue_rsn | STRING | X |  |  |  | Lý do cấp lại | NHNCK.Applications | ReissueReason |  |
| 27 | Rejection Reason | rejection_rsn | STRING | X |  |  |  | Lý do từ chối | NHNCK.Applications | RejectionReason |  |
| 28 | Certificate Number | ctf_nbr | STRING | X |  |  |  | Số chứng chỉ (snapshot tại thời điểm cấp) | NHNCK.Applications | CertificateNumber |  |
| 29 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp chứng chỉ (snapshot) | NHNCK.Applications | IssueDate |  |
| 30 | Previous Certificate Number | prev_ctf_nbr | STRING | X |  |  |  | Số chứng chỉ trước đó (snapshot) | NHNCK.Applications | PreviousCertificateNumber |  |
| 31 | Previous Issue Date | prev_issu_dt | DATE | X |  |  |  | Ngày cấp chứng chỉ trước đó (snapshot) | NHNCK.Applications | PreviousIssueDate |  |
| 32 | Reissue HSM Code | reissue_hsm_code | STRING | X |  |  |  | Mã tái cấp HSM | NHNCK.Applications | ReissueHSM |  |
| 33 | Certificate Receipt Method Code | ctf_recpt_mth_code | STRING | X |  |  |  | Phương thức nhận chứng chỉ | NHNCK.Applications | CertificateReceiptMethod | Scheme: RECEIPT_METHOD. |
| 34 | Certificate Receipt Address | ctf_recpt_adr | STRING | X |  |  |  | Địa chỉ nhận chứng chỉ | NHNCK.Applications | CertificateReceiptAddress |  |
| 35 | Certificate Receipt Phone | ctf_recpt_ph | STRING | X |  |  |  | Số điện thoại nhận chứng chỉ | NHNCK.Applications | CertificateReceiptPhone |  |
| 36 | Receipt Status Code | recpt_st_code | STRING | X |  |  |  | Trạng thái nhận chứng chỉ | NHNCK.Applications | ReceiptStatus | Scheme: RECEIPT_STATUS. |
| 37 | Is Violated Indicator | is_violated_ind | BOOLEAN | X |  |  |  | Cờ vi phạm | NHNCK.Applications | IsViolated |  |
| 38 | Is Date Exploitable Indicator | is_dt_exploitable_ind | BOOLEAN | X |  |  |  | Cờ khai thác theo ngày | NHNCK.Applications | IsDateExploitable |  |
| 39 | Application Note | ap_note | STRING | X |  |  |  | Ghi chú | NHNCK.Applications | Note |  |
| 40 | Created By Officer Id | crt_by_ofcr_id | BIGINT | X |  | F |  | FK đến Officer | NHNCK.Applications | CreatedBy |  |
| 41 | Created By Officer Code | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo | NHNCK.Applications | CreatedBy |  |
| 42 | Updated By Officer Id | udt_by_ofcr_id | BIGINT | X |  | F |  | FK đến Officer | NHNCK.Applications | UpdatedBy |  |
| 43 | Updated By Officer Code | udt_by_ofcr_code | STRING | X |  |  |  | Mã người cập nhật | NHNCK.Applications | UpdatedBy |  |
| 44 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo | NHNCK.Applications | CreatedAt |  |
| 45 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật | NHNCK.Applications | UpdatedAt |  |


#### 2.{IDX}.2.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| License Application Id | license_ap_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Practitioner Id | practitioner_id | Securities Practitioner | Practitioner Id | practitioner_id |
| License Certificate Document Id | license_ctf_doc_id | Securities Practitioner License Certificate Document | License Certificate Document Id | license_ctf_doc_id |
| Previous License Certificate Document Id | prev_license_ctf_doc_id | Securities Practitioner License Certificate Document | License Certificate Document Id | license_ctf_doc_id |
| Examination Assessment Id | exam_ases_id | Securities Practitioner Qualification Examination Assessment | Examination Assessment Id | exam_ases_id |
| Assignee Officer Id | assignee_ofcr_id | Regulatory Authority Officer | Officer Id |  |
| License Application Verification Status Id | license_ap_verf_st_id | Securities Practitioner License Application Verification Status | License Application Verification Status Id | license_ap_verf_st_id |
| Created By Officer Id | crt_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |
| Updated By Officer Id | udt_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |




### 2.{IDX}.3 Bảng Securities Practitioner License Application Education Certificate Document

- **Mô tả:** Văn bằng/chứng chỉ học tập đính kèm hồ sơ CCHN. Ghi nhận loại chuyên môn và file đính kèm kèm trạng thái thẩm định.
- **Tên vật lý:** scr_practitioner_license_ap_ed_ctf_doc
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | License Application Education Certificate Document Id | license_ap_ed_ctf_doc_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.ApplicationSpecializations |  | PK surrogate. BCV: "Documentation". Chứng chỉ chuyên môn đính kèm hồ sơ. |
| 2 | License Application Education Certificate Document Code | license_ap_ed_ctf_doc_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.ApplicationSpecializations | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.ApplicationSpecializations' | Mã nguồn dữ liệu | NHNCK.ApplicationSpecializations |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | License Application Id | license_ap_id | BIGINT |  |  | F |  | FK đến hồ sơ | NHNCK.ApplicationSpecializations | ApplicationId |  |
| 5 | License Application Code | license_ap_code | STRING |  |  |  |  | Mã hồ sơ | NHNCK.ApplicationSpecializations | ApplicationId |  |
| 6 | Specialization Type Code | specialization_tp_code | STRING |  |  |  |  | Mã chuyên môn (FK → Specializations) | NHNCK.ApplicationSpecializations | SpecializationId | Scheme: SPECIALIZATION_TYPE. |
| 7 | File Name | file_nm | STRING | X |  |  |  | Tên file chứng chỉ chuyên môn | NHNCK.ApplicationSpecializations | FileName |  |
| 8 | File Path | file_path | STRING | X |  |  |  | Đường dẫn file | NHNCK.ApplicationSpecializations | FilePath |  |
| 9 | File Format | file_fmt | STRING | X |  |  |  | Loại file | NHNCK.ApplicationSpecializations | Format |  |
| 10 | File Size | file_sz | STRING | X |  |  |  | Dung lượng file (bytes) | NHNCK.ApplicationSpecializations | FileSize |  |
| 11 | Specialization Note | specialization_note | STRING | X |  |  |  | Nội dung/ghi chú | NHNCK.ApplicationSpecializations | Note |  |
| 12 | Appraisal Status Code | aprs_st_code | STRING | X |  |  |  | Trạng thái thẩm định | NHNCK.ApplicationSpecializations | Status | Scheme: APPRAISAL_STATUS. |
| 13 | Assignee Officer Id | assignee_ofcr_id | BIGINT | X |  | F |  | FK đến người thẩm định | NHNCK.ApplicationSpecializations | AssigneeId |  |
| 14 | Assignee Officer Code | assignee_ofcr_code | STRING | X |  |  |  | Mã người thẩm định | NHNCK.ApplicationSpecializations | AssigneeId |  |
| 15 | Appraisaled Timestamp | appraisaled_tms | TIMESTAMP | X |  |  |  | Ngày thẩm định | NHNCK.ApplicationSpecializations | AppraisaledAt |  |


#### 2.{IDX}.3.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| License Application Education Certificate Document Id | license_ap_ed_ctf_doc_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| License Application Id | license_ap_id | Securities Practitioner License Application | License Application Id | license_ap_id |
| Assignee Officer Id | assignee_ofcr_id | Regulatory Authority Officer | Officer Id |  |




### 2.{IDX}.4 Bảng Securities Practitioner License Application Document Attachment

- **Mô tả:** Tài liệu đính kèm hồ sơ CCHN. Ghi nhận loại tài liệu và trạng thái thẩm định.
- **Tên vật lý:** scr_practitioner_license_ap_doc_attachment
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | License Application Document Attachment Id | license_ap_doc_attachment_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.ApplicationDocuments |  | PK surrogate. BCV: "Documentation" (Documentation). Tài liệu đính kèm hồ sơ. |
| 2 | License Application Document Attachment Code | license_ap_doc_attachment_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.ApplicationDocuments | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.ApplicationDocuments' | Mã nguồn dữ liệu | NHNCK.ApplicationDocuments |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | License Application Id | license_ap_id | BIGINT |  |  | F |  | FK đến hồ sơ | NHNCK.ApplicationDocuments | ApplicationId |  |
| 5 | License Application Code | license_ap_code | STRING |  |  |  |  | Mã hồ sơ | NHNCK.ApplicationDocuments | ApplicationId |  |
| 6 | Document Type Code | doc_tp_code | STRING | X |  | F |  | Mã loại tài liệu (FK → Documents) | NHNCK.ApplicationDocuments | DocumentId | Scheme: DOCUMENT_TYPE. FK đến bảng Documents. |
| 7 | Document Name | doc_nm | STRING | X |  |  |  | Tên tài liệu | NHNCK.ApplicationDocuments | DocumentName |  |
| 8 | File Name | file_nm | STRING | X |  |  |  | Tên file | NHNCK.ApplicationDocuments | FileName |  |
| 9 | File Path | file_path | STRING | X |  |  |  | Đường dẫn file | NHNCK.ApplicationDocuments | FilePath |  |
| 10 | File Format | file_fmt | STRING | X |  |  |  | Loại file (pdf, docx...) | NHNCK.ApplicationDocuments | Format |  |
| 11 | File Size | file_sz | STRING | X |  |  |  | Dung lượng file (bytes) | NHNCK.ApplicationDocuments | FileSize |  |
| 12 | Attachment Description | attachment_dsc | STRING | X |  |  |  | Mô tả tài liệu | NHNCK.ApplicationDocuments | Description |  |
| 13 | Attachment Note | attachment_note | STRING | X |  |  |  | Ghi chú thẩm định | NHNCK.ApplicationDocuments | Note |  |
| 14 | Appraisal Status Code | aprs_st_code | STRING | X |  |  |  | Trạng thái thẩm định | NHNCK.ApplicationDocuments | Status | Scheme: APPRAISAL_STATUS. |
| 15 | Is Invalid Indicator | is_inval_ind | BOOLEAN | X |  |  |  | Cờ không hợp lệ | NHNCK.ApplicationDocuments | IsInvalid |  |
| 16 | Is Incomplete Indicator | is_incom_ind | BOOLEAN | X |  |  |  | Cờ chưa hoàn thành | NHNCK.ApplicationDocuments | IsIncomplete |  |
| 17 | Assignee Officer Id | assignee_ofcr_id | BIGINT | X |  | F |  | FK đến người thẩm định | NHNCK.ApplicationDocuments | AssigneeId |  |
| 18 | Assignee Officer Code | assignee_ofcr_code | STRING | X |  |  |  | Mã người thẩm định | NHNCK.ApplicationDocuments | AssigneeId |  |
| 19 | Appraisaled Timestamp | appraisaled_tms | TIMESTAMP | X |  |  |  | Ngày thẩm định | NHNCK.ApplicationDocuments | AppraisaledAt |  |
| 20 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo | NHNCK.ApplicationDocuments | CreatedAt |  |


#### 2.{IDX}.4.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| License Application Document Attachment Id | license_ap_doc_attachment_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| License Application Id | license_ap_id | Securities Practitioner License Application | License Application Id | license_ap_id |
| Assignee Officer Id | assignee_ofcr_id | Regulatory Authority Officer | Officer Id |  |




### 2.{IDX}.5 Bảng Securities Practitioner License Application Processing Activity Log

- **Mô tả:** Nhật ký hoạt động xử lý hồ sơ CCHN. Ghi nhận từng bước xử lý và trạng thái hồ sơ theo thời gian.
- **Tên vật lý:** scr_practitioner_license_ap_pcs_avy_log
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | License Application Processing Activity Log Id | license_ap_pcs_avy_log_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.ActionLogs |  | PK surrogate. BCV: "Business Activity" — nhật ký hoạt động hệ thống. |
| 2 | License Application Processing Activity Log Code | license_ap_pcs_avy_log_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.ActionLogs | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.ActionLogs' | Mã nguồn dữ liệu | NHNCK.ActionLogs |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Officer Id | ofcr_id | BIGINT | X |  | F |  | FK đến tài khoản thực hiện | NHNCK.ActionLogs | UserId |  |
| 5 | Officer Code | ofcr_code | STRING | X |  |  |  | Mã tài khoản thực hiện | NHNCK.ActionLogs | UserId |  |
| 6 | Client Machine Address | clnt_mchn_adr | STRING | X |  |  |  | Địa chỉ IP máy thực hiện | NHNCK.ActionLogs | ClientMachine |  |
| 7 | Activity Detail | avy_dtl | STRING | X |  |  |  | Mô tả nội dung thao tác | NHNCK.ActionLogs | Detail |  |
| 8 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo | NHNCK.ActionLogs | CreatedAt |  |


#### 2.{IDX}.5.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| License Application Processing Activity Log Id | license_ap_pcs_avy_log_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Officer Id | ofcr_id | Regulatory Authority Officer | Officer Id |  |




### 2.{IDX}.6 Bảng Securities Practitioner License Application Fee

- **Mô tả:** Phí thực tế phát sinh theo từng hồ sơ đăng ký CCHN. Ghi nhận loại phí và trạng thái thanh toán.
- **Tên vật lý:** scr_practitioner_license_ap_fee
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | License Application Fee Id | license_ap_fee_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.ApplicationFees |  | PK surrogate. BCV: "Transaction" (Event). Phí thanh toán liên quan đến hồ sơ. |
| 2 | License Application Fee Code | license_ap_fee_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.ApplicationFees | Id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.ApplicationFees' | Mã nguồn dữ liệu | NHNCK.ApplicationFees |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | License Application Id | license_ap_id | BIGINT |  |  | F |  | FK đến hồ sơ | NHNCK.ApplicationFees | ApplicationId |  |
| 5 | License Application Code | license_ap_code | STRING |  |  |  |  | Mã hồ sơ | NHNCK.ApplicationFees | ApplicationId |  |
| 6 | Practitioner Id | practitioner_id | BIGINT | X |  | F |  | FK đến Securities Practitioner | NHNCK.ApplicationFees | ProfessionalId |  |
| 7 | Practitioner Code | practitioner_code | STRING | X |  |  |  | Mã người hành nghề | NHNCK.ApplicationFees | ProfessionalId |  |
| 8 | Fee Type Code | fee_tp_code | STRING | X |  |  |  | Loại phí | NHNCK.ApplicationFees | FeeType | Scheme: FEE_TYPE. |
| 9 | Fee Amount | fee_amt | DECIMAL(18,2) | X |  |  |  | Số tiền phí (VNĐ) | NHNCK.ApplicationFees | Fee |  |
| 10 | Fee Content | fee_cntnt | STRING | X |  |  |  | Nội dung phí | NHNCK.ApplicationFees | Content |  |
| 11 | Fee Note | fee_note | STRING | X |  |  |  | Ghi chú | NHNCK.ApplicationFees | Note |  |
| 12 | Payment Status Code | pymt_st_code | STRING | X |  |  |  | Trạng thái thanh toán | NHNCK.ApplicationFees | Status | Scheme: PAYMENT_STATUS. |
| 13 | Request Date | rqs_dt | DATE | X |  |  |  | Ngày yêu cầu thanh toán | NHNCK.ApplicationFees | RequestDate |  |
| 14 | Payment Date | pymt_dt | DATE | X |  |  |  | Ngày thanh toán | NHNCK.ApplicationFees | PaymentDate |  |
| 15 | Expiry Date | expiry_dt | DATE | X |  |  |  | Ngày hết hạn thanh toán | NHNCK.ApplicationFees | ExpiryDate |  |
| 16 | Created By Officer Id | crt_by_ofcr_id | BIGINT | X |  | F |  | FK đến Officer | NHNCK.ApplicationFees | CreatedBy |  |
| 17 | Created By Officer Code | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo | NHNCK.ApplicationFees | CreatedBy |  |
| 18 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo | NHNCK.ApplicationFees | CreatedAt |  |
| 19 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật | NHNCK.ApplicationFees | UpdatedAt |  |


#### 2.{IDX}.6.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| License Application Fee Id | license_ap_fee_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| License Application Id | license_ap_id | Securities Practitioner License Application | License Application Id | license_ap_id |
| Practitioner Id | practitioner_id | Securities Practitioner | Practitioner Id | practitioner_id |
| Created By Officer Id | crt_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |




### 2.{IDX}.7 Bảng Securities Practitioner License Application Verification Status

- **Mô tả:** Bản ghi phê duyệt nội bộ hồ sơ CCHN theo cấp lãnh đạo. Ghi nhận người phê duyệt và kết quả phê duyệt tại từng cấp.
- **Tên vật lý:** scr_practitioner_license_ap_verf_st
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | License Application Verification Status Id | license_ap_verf_st_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.VerifyApplicationStatuses |  | PK surrogate. BCV: "Approval Activity" (Business Activity). Phê duyệt trạng thái hồ sơ. |
| 2 | License Application Verification Status Code | license_ap_verf_st_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.VerifyApplicationStatuses | Id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.VerifyApplicationStatuses' | Mã nguồn dữ liệu | NHNCK.VerifyApplicationStatuses |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | License Application Id | license_ap_id | BIGINT |  |  | F |  | FK đến hồ sơ | NHNCK.VerifyApplicationStatuses | ApplicationId |  |
| 5 | License Application Code | license_ap_code | STRING |  |  |  |  | Mã hồ sơ | NHNCK.VerifyApplicationStatuses | ApplicationId |  |
| 6 | Verification Status Code | verf_st_code | STRING | X |  | F |  | Trạng thái phê duyệt (FK → ApplicationStatuses) | NHNCK.VerifyApplicationStatuses | StatusId | Scheme: APPLICATION_STATUS. FK đến bảng ApplicationStatuses. |
| 7 | Previous Verification Status Code | prev_verf_st_code | STRING | X |  |  |  | Trạng thái hồ sơ trước đó | NHNCK.VerifyApplicationStatuses | PrevStatusId | Scheme: APPLICATION_STATUS. |
| 8 | Verified By Officer Id | verf_by_ofcr_id | BIGINT | X |  | F |  | FK đến người phê duyệt | NHNCK.VerifyApplicationStatuses | VerifiedBy |  |
| 9 | Verified By Officer Code | verf_by_ofcr_code | STRING | X |  |  |  | Mã người phê duyệt | NHNCK.VerifyApplicationStatuses | VerifiedBy |  |
| 10 | Rejection Reason Description | rejection_rsn_dsc | STRING | X |  |  |  | Lý do thay đổi trạng thái | NHNCK.VerifyApplicationStatuses | Reason |  |
| 11 | Specialization Officer Reason | specialization_ofcr_rsn | STRING | X |  |  |  | Nội dung ý kiến — Lãnh đạo chuyên môn | NHNCK.VerifyApplicationStatuses | SpecReason |  |
| 12 | Organization Officer Reason | org_ofcr_rsn | STRING | X |  |  |  | Nội dung ý kiến — Lãnh đạo UBCK | NHNCK.VerifyApplicationStatuses | OrgReason |  |
| 13 | Overview Officer Reason | overview_ofcr_rsn | STRING | X |  |  |  | Nội dung ý kiến — Cán bộ tổng hợp | NHNCK.VerifyApplicationStatuses | OverviewReason |  |
| 14 | Created By Officer Id | crt_by_ofcr_id | BIGINT | X |  | F |  | FK đến Officer | NHNCK.VerifyApplicationStatuses | CreatedBy |  |
| 15 | Created By Officer Code | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo | NHNCK.VerifyApplicationStatuses | CreatedBy |  |
| 16 | Updated By Officer Id | udt_by_ofcr_id | BIGINT | X |  | F |  | FK đến Officer | NHNCK.VerifyApplicationStatuses | UpdatedBy |  |
| 17 | Updated By Officer Code | udt_by_ofcr_code | STRING | X |  |  |  | Mã người cập nhật | NHNCK.VerifyApplicationStatuses | UpdatedBy |  |
| 18 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo | NHNCK.VerifyApplicationStatuses | CreatedAt |  |
| 19 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật | NHNCK.VerifyApplicationStatuses | UpdatedAt |  |


#### 2.{IDX}.7.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| License Application Verification Status Id | license_ap_verf_st_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| License Application Id | license_ap_id | Securities Practitioner License Application | License Application Id | license_ap_id |
| Verified By Officer Id | verf_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |
| Created By Officer Id | crt_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |
| Updated By Officer Id | udt_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |




### 2.{IDX}.8 Bảng Securities Practitioner

- **Mô tả:** Người hành nghề chứng khoán được UBCKNN cấp phép. Ghi nhận thông tin cá nhân và trạng thái hành nghề. Attribute chi tiết (BirthDate full
- **Tên vật lý:** scr_practitioner
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Practitioner Id | practitioner_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.Professionals |  | PK surrogate. BCV: "Individual" (Involved Party). Domain prefix "Securities Practitioner" theo HLD. |
| 2 | Practitioner Code | practitioner_code | STRING |  |  |  |  | Mã định danh người hành nghề (tự động tăng). BK | NHNCK.Professionals | Id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.Professionals' | Mã nguồn dữ liệu | NHNCK.Professionals |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Full Name | full_nm | STRING | X |  |  |  | Họ và tên | NHNCK.Professionals | FullName |  |
| 5 | Birth Year | brth_yr | STRING | X |  |  |  | Năm sinh | NHNCK.Professionals | BirthYear |  |
| 6 | Date Of Birth | dob | DATE | X |  |  |  | Ngày sinh đầy đủ (ngày/tháng/năm) | NHNCK.Professionals | BirthDate |  |
| 7 | Individual Gender Code | idv_gnd_code | STRING | X |  |  |  | Giới tính | NHNCK.Professionals | Gender | Scheme: INDIVIDUAL_GENDER. Lấy từ bản mới nhất ProfessionalHistories. |
| 8 | Nationality Code | nationality_code | STRING | X |  |  |  | Quốc tịch | NHNCK.Professionals | NationalityId | Scheme: NATIONALITY. Lấy từ bản mới nhất ProfessionalHistories. Thay thế Country Code từ Professionals.CountryId (cùng ngữ nghĩa quốc tịch). |
| 9 | Education Level Code | ed_lvl_code | STRING | X |  |  |  | Trình độ học vấn | NHNCK.Professionals | EducationLevelId | Scheme: EDUCATION_LEVEL. Lấy từ bản mới nhất ProfessionalHistories. Professionals không có trường này. |
| 10 | Birth Place | brth_plc | STRING | X |  |  |  | Nơi sinh | NHNCK.Professionals | PlaceOfBirth |  |
| 11 | Practitioner Registration Type Code | practitioner_rgst_tp_code | STRING | X |  |  |  | Hình thức đăng ký người hành nghề vào hệ thống | NHNCK.Professionals | RegistrationType | Scheme: PRACTITIONER_REGISTRATION_TYPE. Lấy từ bản mới nhất ProfessionalHistories. Khác với Applications.RegistrationType (loại đăng ký hồ sơ CCHN). |
| 12 | Practice Status Code | practice_st_code | STRING | X |  |  |  | Trạng thái hành nghề | NHNCK.Professionals | StatusWork | Scheme: PRACTICE_STATUS. Lấy từ bản mới nhất ProfessionalHistories. 5 giá trị: 0=Chưa hành nghề; 1=Hành nghề; 2=Thu hồi cho cấp lại; 3=Thu hồi không cấp lại; 4=Hành nghề có thời hạn. |
| 13 | Country of Residence Geographic Area Id | cty_of_rsdnc_geo_id | BIGINT | X |  | F |  | FK đến quốc gia cư trú. | NHNCK.Professionals | CountryId |  |
| 14 | Country of Residence Geographic Area Code | cty_of_rsdnc_geo_code | STRING | X |  |  |  | Mã quốc gia cư trú. | NHNCK.Professionals | CountryId |  |
| 15 | Identity Reference Code | identity_refr_code | STRING | X |  |  |  | Mã định danh giấy tờ tùy thân (FK bảng identity riêng) | NHNCK.Professionals | IdentityId |  |
| 16 | Relationship Type Code | rltnp_tp_code | STRING | X |  |  |  | Loại quan hệ người hành nghề | NHNCK.Professionals | RelationshipType | Scheme: PRACTITIONER_RELATIONSHIP_TYPE. |
| 17 | Occupation Name | ocp_nm | STRING | X |  |  |  | Nghề nghiệp | NHNCK.Professionals | Occupation |  |
| 18 | Workplace Name | workplace_nm | STRING | X |  |  |  | Nơi làm việc | NHNCK.Professionals | Workplace |  |
| 19 | Practitioner Note | practitioner_note | STRING | X |  |  |  | Ghi chú | NHNCK.Professionals | Note |  |
| 20 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo | NHNCK.Professionals | CreatedAt |  |
| 21 | Securities Company Id | scr_co_id | BIGINT |  |  | F |  | FK đến công ty chứng khoán nơi hành nghề. | NHNCK.Professionals |  |  |
| 22 | Securities Company Code | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. | NHNCK.Professionals |  |  |
| 23 | Employee Code | empe_code | STRING | X |  |  |  | Mã nhân viên nội bộ CTCK. | NHNCK.Professionals |  |  |
| 24 | License Number | license_nbr | STRING | X |  |  |  | Số chứng chỉ hành nghề chứng khoán. | NHNCK.Professionals |  |  |
| 25 | Employment Start Date | emp_strt_dt | DATE | X |  |  |  | Ngày bắt đầu làm việc tại CTCK. | NHNCK.Professionals |  |  |
| 26 | Employment End Date | emp_end_dt | DATE | X |  |  |  | Ngày nghỉ việc. | NHNCK.Professionals |  |  |
| 27 | Note | note | STRING | X |  |  |  | Ghi chú. | NHNCK.Professionals |  |  |
| 28 | Practitioner Status Code | practitioner_st_code | STRING | X |  |  |  | Trạng thái người hành nghề tại CTCK. | NHNCK.Professionals |  | Scheme: SCMS_COMPANY_STATUS. |


#### 2.{IDX}.8.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Practitioner Id | practitioner_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Country of Residence Geographic Area Id | cty_of_rsdnc_geo_id | Geographic Area | Geographic Area Id | geo_id |
| Securities Company Id | scr_co_id | Securities Company | Securities Company Id | scr_co_id |




### 2.{IDX}.9 Bảng Involved Party Postal Address — NHNCK.Professionals

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Securities Practitioner | NHNCK.Professionals | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người hành nghề | NHNCK.Professionals | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.Professionals' | Mã nguồn dữ liệu | NHNCK.Professionals |  |  |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ — địa chỉ chung | NHNCK.Professionals |  |  |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ | NHNCK.Professionals | Address |  |
| 6 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | NHNCK.Professionals |  |  |


#### 2.{IDX}.9.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Practitioner | Practitioner Id | practitioner_id |




### 2.{IDX}.10 Bảng Involved Party Electronic Address — NHNCK.Professionals

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Securities Practitioner | NHNCK.Professionals | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người hành nghề | NHNCK.Professionals | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.Professionals' | Mã nguồn dữ liệu | NHNCK.Professionals |  |  |


#### 2.{IDX}.10.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Practitioner | Practitioner Id | practitioner_id |




### 2.{IDX}.11 Bảng Involved Party Alternative Identification — NHNCK.Professionals

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Securities Practitioner | NHNCK.Professionals | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người hành nghề | NHNCK.Professionals | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.Professionals' | Mã nguồn dữ liệu | NHNCK.Professionals |  |  |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ định danh — CCCD/CMND | NHNCK.Professionals |  |  |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Mã định danh giấy tờ tùy thân (FK bảng identity riêng) | NHNCK.Professionals | IdentityId |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp CCCD/Hộ chiếu. | NHNCK.Professionals |  |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp CCCD/Hộ chiếu. | NHNCK.Professionals |  |  |


#### 2.{IDX}.11.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Practitioner | Practitioner Id | practitioner_id |




### 2.{IDX}.12 Bảng Securities Practitioner License Certificate Document

- **Mô tả:** Chứng chỉ hành nghề chứng khoán được cấp cho người hành nghề. Ghi nhận loại chứng chỉ và quyết định cấp/thu hồi.
- **Tên vật lý:** scr_practitioner_license_ctf_doc
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | License Certificate Document Id | license_ctf_doc_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.CertificateRecords |  | PK surrogate. BCV: "Government Registration Document" (Documentation). Chứng chỉ hành nghề được cấp. |
| 2 | License Certificate Document Code | license_ctf_doc_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.CertificateRecords | Id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.CertificateRecords' | Mã nguồn dữ liệu | NHNCK.CertificateRecords |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Practitioner Id | practitioner_id | BIGINT | X |  | F |  | FK đến Securities Practitioner | NHNCK.CertificateRecords | ProfessionalId |  |
| 5 | Practitioner Code | practitioner_code | STRING | X |  |  |  | Mã người hành nghề | NHNCK.CertificateRecords | ProfessionalId |  |
| 6 | Professional Full Name | prof_full_nm | STRING | X |  |  |  | Họ và tên người hành nghề (snapshot tại thời điểm cấp) | NHNCK.CertificateRecords | ProfessionalFullName |  |
| 7 | Certificate Type Code | ctf_tp_code | STRING | X |  |  |  | Mã loại chứng chỉ | NHNCK.CertificateRecords | CertificateId | Scheme: CERTIFICATE_TYPE. |
| 8 | Issuance Decision Document Id | issn_dcsn_doc_id | BIGINT | X |  | F |  | FK đến quyết định cấp | NHNCK.CertificateRecords | IssueDecisionId |  |
| 9 | Issuance Decision Document Code | issn_dcsn_doc_code | STRING | X |  |  |  | Mã quyết định cấp | NHNCK.CertificateRecords | IssueDecisionId |  |
| 10 | Revocation Decision Document Id | revocation_dcsn_doc_id | BIGINT | X |  | F |  | FK đến quyết định thu hồi | NHNCK.CertificateRecords | RevocationDecisionId |  |
| 11 | Revocation Decision Document Code | revocation_dcsn_doc_code | STRING | X |  |  |  | Mã quyết định thu hồi | NHNCK.CertificateRecords | RevocationDecisionId |  |
| 12 | Cancellation Decision Document Id | cncl_dcsn_doc_id | BIGINT | X |  | F |  | FK đến quyết định hủy | NHNCK.CertificateRecords | CannellationDecisionId |  |
| 13 | Cancellation Decision Document Code | cncl_dcsn_doc_code | STRING | X |  |  |  | Mã quyết định hủy | NHNCK.CertificateRecords | CannellationDecisionId |  |
| 14 | Certificate Number | ctf_nbr | STRING | X |  |  |  | Số chứng chỉ | NHNCK.CertificateRecords | CertificateNumber |  |
| 15 | Certificate Issue Date | ctf_issu_dt | DATE | X |  |  |  | Ngày cấp chứng chỉ | NHNCK.CertificateRecords | IssueDate |  |
| 16 | Revocation Date | revocation_dt | DATE | X |  |  |  | Ngày thu hồi chứng chỉ | NHNCK.CertificateRecords | RevocationDate |  |
| 17 | Revocation Reason | revocation_rsn | STRING | X |  |  |  | Lý do thu hồi | NHNCK.CertificateRecords | RevocationReason |  |
| 18 | Certificate Status Code | ctf_st_code | STRING | X |  |  |  | Trạng thái (0: Chưa sử dụng, 1: Đang sử dụng, 2: Thu hồi, 3: Đã hủy) | NHNCK.CertificateRecords | Status | Scheme: CERTIFICATE_STATUS. |
| 19 | Process Status Code | pcs_st_code | STRING | X |  |  |  | Trạng thái xử lý (Đã cấp, Đã ký, Đã trả) | NHNCK.CertificateRecords | ProcessStatus | Scheme: CERTIFICATE_PROCESS_STATUS. |
| 20 | Certificate Description | ctf_dsc | STRING | X |  |  |  | Mô tả | NHNCK.CertificateRecords | Description |  |
| 21 | Allow Reissue Indicator | alw_reissue_ind | BOOLEAN | X |  |  |  | Cho phép cấp lại (0: Không, 1: Có) | NHNCK.CertificateRecords | AllowReissue |  |
| 22 | Created By Officer Id | crt_by_ofcr_id | BIGINT | X |  | F |  | FK đến Officer | NHNCK.CertificateRecords | CreatedBy |  |
| 23 | Created By Officer Code | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo | NHNCK.CertificateRecords | CreatedBy |  |
| 24 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo | NHNCK.CertificateRecords | CreatedAt |  |


#### 2.{IDX}.12.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| License Certificate Document Id | license_ctf_doc_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Practitioner Id | practitioner_id | Securities Practitioner | Practitioner Id | practitioner_id |
| Issuance Decision Document Id | issn_dcsn_doc_id | Securities Practitioner License Decision Document | License Decision Document Id | license_dcsn_doc_id |
| Revocation Decision Document Id | revocation_dcsn_doc_id | Securities Practitioner License Decision Document | License Decision Document Id | license_dcsn_doc_id |
| Cancellation Decision Document Id | cncl_dcsn_doc_id | Securities Practitioner License Decision Document | License Decision Document Id | license_dcsn_doc_id |
| Created By Officer Id | crt_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |




### 2.{IDX}.13 Bảng Securities Practitioner License Certificate Group Document

- **Mô tả:** Nhóm chứng chỉ hành nghề trong một quyết định cấp/thu hồi/hủy tập thể. Liên kết với quyết định hành chính.
- **Tên vật lý:** scr_practitioner_license_ctf_grp_doc
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | License Certificate Group Document Id | license_ctf_grp_doc_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.CertificateRecordGroups |  | PK surrogate. BCV: "Government Registration Document". Nhóm cấp/thu hồi/hủy chứng chỉ. |
| 2 | License Certificate Group Document Code | license_ctf_grp_doc_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.CertificateRecordGroups | Id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.CertificateRecordGroups' | Mã nguồn dữ liệu | NHNCK.CertificateRecordGroups |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Group Name | grp_nm | STRING | X |  |  |  | Tên nhóm | NHNCK.CertificateRecordGroups | GroupName |  |
| 5 | Group Type Code | grp_tp_code | STRING | X |  |  |  | Loại nhóm (Cấp/Thu hồi/Hủy/Chuyển đổi) | NHNCK.CertificateRecordGroups | Type | Scheme: GROUP_TYPE. |
| 6 | License Decision Document Id | license_dcsn_doc_id | BIGINT | X |  | F |  | FK đến quyết định | NHNCK.CertificateRecordGroups | DecisionId |  |
| 7 | License Decision Document Code | license_dcsn_doc_code | STRING | X |  |  |  | Mã quyết định | NHNCK.CertificateRecordGroups | DecisionId |  |
| 8 | Group Description | grp_dsc | STRING | X |  |  |  | Mô tả nhóm | NHNCK.CertificateRecordGroups | Description |  |
| 9 | Group Notes | grp_notes | STRING | X |  |  |  | Ghi chú | NHNCK.CertificateRecordGroups | Notes |  |
| 10 | Group Status Code | grp_st_code | STRING | X |  |  |  | Trạng thái nhóm | NHNCK.CertificateRecordGroups | Status | Scheme: GROUP_STATUS. |
| 11 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo | NHNCK.CertificateRecordGroups | CreatedAt |  |
| 12 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật | NHNCK.CertificateRecordGroups | UpdatedAt |  |


#### 2.{IDX}.13.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| License Certificate Group Document Id | license_ctf_grp_doc_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| License Decision Document Id | license_dcsn_doc_id | Securities Practitioner License Decision Document | License Decision Document Id | license_dcsn_doc_id |




### 2.{IDX}.14 Bảng Securities Practitioner License Certificate Group Member

- **Mô tả:** Quan hệ thành viên giữa chứng chỉ hành nghề và nhóm cấp/thu hồi. Liên kết Certificate ↔ Group ↔ Application.
- **Tên vật lý:** scr_practitioner_license_ctf_grp_mbr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | License Certificate Group Member Id | license_ctf_grp_mbr_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.CertificateRecordGroupMembers |  | PK surrogate. Junction: Certificate ↔ Group. |
| 2 | License Certificate Group Member Code | license_ctf_grp_mbr_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.CertificateRecordGroupMembers | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.CertificateRecordGroupMembers' | Mã nguồn dữ liệu | NHNCK.CertificateRecordGroupMembers |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | License Certificate Group Document Id | license_ctf_grp_doc_id | BIGINT |  |  | F |  | FK đến nhóm chứng chỉ | NHNCK.CertificateRecordGroupMembers | CertificateRecordGroupId |  |
| 5 | License Certificate Group Document Code | license_ctf_grp_doc_code | STRING |  |  |  |  | Mã nhóm | NHNCK.CertificateRecordGroupMembers | CertificateRecordGroupId |  |
| 6 | License Certificate Document Id | license_ctf_doc_id | BIGINT |  |  | F |  | FK đến chứng chỉ | NHNCK.CertificateRecordGroupMembers | CertificateRecordId |  |
| 7 | License Certificate Document Code | license_ctf_doc_code | STRING |  |  |  |  | Mã chứng chỉ | NHNCK.CertificateRecordGroupMembers | CertificateRecordId |  |
| 8 | Order Index | ordr_indx | INT | X |  |  |  | Thứ tự sắp xếp trong nhóm | NHNCK.CertificateRecordGroupMembers | OrderIndex |  |
| 9 | Is Reissue Indicator | is_reissue_ind | BOOLEAN | X |  |  |  | Cờ cho phép cấp lại | NHNCK.CertificateRecordGroupMembers | IsReissue |  |
| 10 | Revocation Reason | revocation_rsn | STRING | X |  |  |  | Lý do thu hồi/hủy | NHNCK.CertificateRecordGroupMembers | RevocationReason |  |
| 11 | Member Status Code | mbr_st_code | STRING | X |  |  |  | Trạng thái thành viên nhóm | NHNCK.CertificateRecordGroupMembers | Status | Scheme: GROUP_MEMBER_STATUS. |


#### 2.{IDX}.14.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| License Certificate Group Member Id | license_ctf_grp_mbr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| License Certificate Group Document Id | license_ctf_grp_doc_id | Securities Practitioner License Certificate Group Document | License Certificate Group Document Id | license_ctf_grp_doc_id |
| License Certificate Document Id | license_ctf_doc_id | Securities Practitioner License Certificate Document | License Certificate Document Id | license_ctf_doc_id |




### 2.{IDX}.15 Bảng Securities Practitioner License Certificate Document Status History

- **Mô tả:** Lịch sử thay đổi trạng thái của chứng chỉ hành nghề. Ghi nhận trạng thái trước/sau và lý do thay đổi.
- **Tên vật lý:** scr_practitioner_license_ctf_doc_st_hist
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | License Certificate Document Status History Id | license_ctf_doc_st_hist_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.CertificateRecordStatusHistories |  | PK surrogate. ETL Pattern — status history. |
| 2 | License Certificate Document Status History Code | license_ctf_doc_st_hist_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.CertificateRecordStatusHistories | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.CertificateRecordStatusHistories' | Mã nguồn dữ liệu | NHNCK.CertificateRecordStatusHistories |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | License Certificate Document Id | license_ctf_doc_id | BIGINT |  |  | F |  | FK đến chứng chỉ | NHNCK.CertificateRecordStatusHistories | CertificateRecordId |  |
| 5 | License Certificate Document Code | license_ctf_doc_code | STRING |  |  |  |  | Mã chứng chỉ | NHNCK.CertificateRecordStatusHistories | CertificateRecordId |  |
| 6 | License Decision Document Id | license_dcsn_doc_id | BIGINT | X |  | F |  | FK đến quyết định | NHNCK.CertificateRecordStatusHistories | DecisionId |  |
| 7 | License Decision Document Code | license_dcsn_doc_code | STRING | X |  |  |  | Mã quyết định | NHNCK.CertificateRecordStatusHistories | DecisionId |  |
| 8 | Update Type Code | udt_tp_code | STRING | X |  |  |  | Loại cập nhật (Manual, System, Decision) | NHNCK.CertificateRecordStatusHistories | UpdateType | Scheme: STATUS_UPDATE_TYPE. |
| 9 | Old Status Code | old_st_code | STRING | X |  |  |  | Trạng thái trước | NHNCK.CertificateRecordStatusHistories | OldStatus | Scheme: CERTIFICATE_STATUS. |
| 10 | New Status Code | new_st_code | STRING | X |  |  |  | Trạng thái sau | NHNCK.CertificateRecordStatusHistories | NewStatus | Scheme: CERTIFICATE_STATUS. |
| 11 | Status Change Reason Description | st_chg_rsn_dsc | STRING | X |  |  |  | Lý do thay đổi | NHNCK.CertificateRecordStatusHistories | Reason |  |
| 12 | Status Change Timestamp | st_chg_tms | TIMESTAMP | X |  |  |  | Thời điểm thay đổi | NHNCK.CertificateRecordStatusHistories | CreatedAt |  |
| 13 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi | NHNCK.CertificateRecordStatusHistories | UpdatedAt |  |


#### 2.{IDX}.15.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| License Certificate Document Status History Id | license_ctf_doc_st_hist_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| License Certificate Document Id | license_ctf_doc_id | Securities Practitioner License Certificate Document | License Certificate Document Id | license_ctf_doc_id |
| License Decision Document Id | license_dcsn_doc_id | Securities Practitioner License Decision Document | License Decision Document Id | license_dcsn_doc_id |




### 2.{IDX}.16 Bảng Securities Practitioner License Certificate Document Activity Log

- **Mô tả:** Nhật ký hoạt động tác động lên chứng chỉ hành nghề. Ghi nhận hành động và người thực hiện.
- **Tên vật lý:** scr_practitioner_license_ctf_doc_avy_log
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | License Certificate Document Activity Log Id | license_ctf_doc_avy_log_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.CertificateRecordLogs |  | PK surrogate. ETL Pattern — activity log. |
| 2 | License Certificate Document Activity Log Code | license_ctf_doc_avy_log_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.CertificateRecordLogs | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.CertificateRecordLogs' | Mã nguồn dữ liệu | NHNCK.CertificateRecordLogs |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | License Certificate Document Id | license_ctf_doc_id | BIGINT |  |  | F |  | FK đến chứng chỉ | NHNCK.CertificateRecordLogs | CertificateRecordId |  |
| 5 | License Certificate Document Code | license_ctf_doc_code | STRING |  |  |  |  | Mã chứng chỉ | NHNCK.CertificateRecordLogs | CertificateRecordId |  |
| 6 | Activity Type Code | avy_tp_code | STRING | X |  |  |  | Loại hành động | NHNCK.CertificateRecordLogs | ActionType | Scheme: CERTIFICATE_ACTIVITY_TYPE. |
| 7 | Certificate Number | ctf_nbr | STRING | X |  |  |  | Số chứng chỉ tại thời điểm ghi log | NHNCK.CertificateRecordLogs | CertificateNumber |  |
| 8 | License Decision Document Id | license_dcsn_doc_id | BIGINT | X |  | F |  | FK đến quyết định | NHNCK.CertificateRecordLogs | DecisionId |  |
| 9 | License Decision Document Code | license_dcsn_doc_code | STRING | X |  |  |  | Mã quyết định | NHNCK.CertificateRecordLogs | DecisionId |  |
| 10 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày quyết định | NHNCK.CertificateRecordLogs | IssueDate |  |
| 11 | Activity Note | avy_note | STRING | X |  |  |  | Ghi chú hoạt động | NHNCK.CertificateRecordLogs | Note |  |
| 12 | Processed By Officer Id | pcs_by_ofcr_id | BIGINT | X |  | F |  | FK đến người xử lý | NHNCK.CertificateRecordLogs | CreatedBy |  |
| 13 | Processed By Officer Code | pcs_by_ofcr_code | STRING | X |  |  |  | Mã người xử lý | NHNCK.CertificateRecordLogs | CreatedBy |  |


#### 2.{IDX}.16.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| License Certificate Document Activity Log Id | license_ctf_doc_avy_log_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| License Certificate Document Id | license_ctf_doc_id | Securities Practitioner License Certificate Document | License Certificate Document Id | license_ctf_doc_id |
| License Decision Document Id | license_dcsn_doc_id | Securities Practitioner License Decision Document | License Decision Document Id | license_dcsn_doc_id |
| Processed By Officer Id | pcs_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |




### 2.{IDX}.17 Bảng Securities Practitioner Related Party

- **Mô tả:** Quan hệ thân nhân của người hành nghề chứng khoán. Ghi nhận loại quan hệ và thông tin người liên quan.
- **Tên vật lý:** scr_practitioner_rel_p
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Securities Practitioner Related Party Id | scr_practitioner_rel_p_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.ProfessionalRelationships |  | PK surrogate. BCV: "Related Involved Party" (Involved Party). Quan hệ gia đình/xã hội. |
| 2 | Securities Practitioner Related Party Code | scr_practitioner_rel_p_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.ProfessionalRelationships | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.ProfessionalRelationships' | Mã nguồn dữ liệu | NHNCK.ProfessionalRelationships |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Practitioner Id | practitioner_id | BIGINT |  |  | F |  | FK đến Securities Practitioner | NHNCK.ProfessionalRelationships | ProfessionalId |  |
| 5 | Practitioner Code | practitioner_code | STRING |  |  |  |  | Mã người hành nghề | NHNCK.ProfessionalRelationships | ProfessionalId |  |
| 6 | Related Party Full Name | rel_p_full_nm | STRING | X |  |  |  | Họ và tên người liên quan | NHNCK.ProfessionalRelationships | FullName |  |
| 7 | Relationship Type Code | rltnp_tp_code | STRING | X |  |  |  | Quan hệ (1: Vợ/Chồng, 2: Con, 3: Bố, 4: Mẹ, 5: Ông, 6: Bà) | NHNCK.ProfessionalRelationships | RelationshipType | Scheme: RELATIONSHIP_TYPE. |
| 8 | Birth Year | brth_yr | STRING | X |  |  |  | Năm sinh | NHNCK.ProfessionalRelationships | BirthYear |  |
| 9 | Country Code | cty_code | STRING | X |  |  |  | Quốc gia | NHNCK.ProfessionalRelationships | CountryId | Scheme: COUNTRY. |
| 10 | Identity Reference Code | identity_refr_code | STRING | X |  | F |  | Mã định danh giấy tờ tùy thân | NHNCK.ProfessionalRelationships | IdentityId |  |
| 11 | Address | adr | STRING | X |  |  |  | Địa chỉ | NHNCK.ProfessionalRelationships | Address |  |
| 12 | Occupation Name | ocp_nm | STRING | X |  |  |  | Nghề nghiệp | NHNCK.ProfessionalRelationships | Occupation |  |
| 13 | Workplace Name | workplace_nm | STRING | X |  |  |  | Nơi làm việc | NHNCK.ProfessionalRelationships | Workplace |  |
| 14 | Related Party Note | rel_p_note | STRING | X |  |  |  | Ghi chú | NHNCK.ProfessionalRelationships | Note |  |
| 15 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo | NHNCK.ProfessionalRelationships | CreatedAt |  |


#### 2.{IDX}.17.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Securities Practitioner Related Party Id | scr_practitioner_rel_p_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Practitioner Id | practitioner_id | Securities Practitioner | Practitioner Id | practitioner_id |




### 2.{IDX}.18 Bảng Securities Practitioner Conduct Violation

- **Mô tả:** Vi phạm pháp luật hoặc hành chính của người hành nghề chứng khoán. Ghi nhận loại vi phạm và quyết định xử lý.
- **Tên vật lý:** scr_practitioner_conduct_vln
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Conduct Violation Id | conduct_vln_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.Violations |  | PK surrogate. BCV: "Conduct Violation" (Business Activity). |
| 2 | Conduct Violation Code | conduct_vln_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.Violations | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.Violations' | Mã nguồn dữ liệu | NHNCK.Violations |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Practitioner Id | practitioner_id | BIGINT |  |  | F |  | FK đến Securities Practitioner | NHNCK.Violations | ProfessionalId |  |
| 5 | Practitioner Code | practitioner_code | STRING |  |  |  |  | Mã người hành nghề | NHNCK.Violations | ProfessionalId |  |
| 6 | Full Name | full_nm | STRING | X |  |  |  | Họ và tên người vi phạm (snapshot) | NHNCK.Violations | FullName |  |
| 7 | Date Of Birth | dob | DATE | X |  |  |  | Ngày sinh (snapshot) | NHNCK.Violations | BirthDate |  |
| 8 | Identification Number | identn_nbr | STRING | X |  |  |  | Số CMND/CCCD (snapshot) | NHNCK.Violations | IdentityNumber |  |
| 9 | License Decision Document Id | license_dcsn_doc_id | BIGINT | X |  | F |  | FK đến quyết định xử lý vi phạm | NHNCK.Violations | DecisionId |  |
| 10 | License Decision Document Code | license_dcsn_doc_code | STRING | X |  |  |  | Mã quyết định | NHNCK.Violations | DecisionId |  |
| 11 | Conduct Violation Type Code | conduct_vln_tp_code | STRING | X |  |  |  | Loại vi phạm (1: Hành chính, 2: Pháp luật) | NHNCK.Violations | Type | Scheme: CONDUCT_VIOLATION_TYPE. |
| 12 | Violation Note | vln_note | STRING | X |  |  |  | Ghi chú vi phạm | NHNCK.Violations | Note |  |
| 13 | Violation Status Code | vln_st_code | STRING | X |  |  |  | Trạng thái (1: Hoạt động, 0: Không hoạt động, -1: Đã xóa) | NHNCK.Violations | Status | Scheme: VIOLATION_STATUS. |
| 14 | Created By Officer Id | crt_by_ofcr_id | BIGINT | X |  | F |  | FK đến Officer | NHNCK.Violations | CreatedBy |  |
| 15 | Created By Officer Code | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo | NHNCK.Violations | CreatedBy |  |
| 16 | Updated By Officer Id | udt_by_ofcr_id | BIGINT | X |  | F |  | FK đến Officer | NHNCK.Violations | UpdatedBy |  |
| 17 | Updated By Officer Code | udt_by_ofcr_code | STRING | X |  |  |  | Mã người cập nhật | NHNCK.Violations | UpdatedBy |  |
| 18 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo | NHNCK.Violations | CreatedAt |  |
| 19 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật | NHNCK.Violations | UpdatedAt |  |


#### 2.{IDX}.18.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Conduct Violation Id | conduct_vln_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Practitioner Id | practitioner_id | Securities Practitioner | Practitioner Id | practitioner_id |
| License Decision Document Id | license_dcsn_doc_id | Securities Practitioner License Decision Document | License Decision Document Id | license_dcsn_doc_id |
| Created By Officer Id | crt_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |
| Updated By Officer Id | udt_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |




### 2.{IDX}.19 Bảng Securities Practitioner Organization Employment Report

- **Mô tả:** Báo cáo của tổ chức về tình trạng tuyển dụng/chấm dứt hợp đồng người hành nghề chứng khoán.
- **Tên vật lý:** scr_practitioner_org_emp_rpt
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Organization Employment Report Id | org_emp_rpt_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.OrganizationReports |  | PK surrogate. BCV: "Employer Registration" (Documentation). |
| 2 | Organization Employment Report Code | org_emp_rpt_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.OrganizationReports | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.OrganizationReports' | Mã nguồn dữ liệu | NHNCK.OrganizationReports |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Practitioner Id | practitioner_id | BIGINT |  |  | F |  | FK đến Securities Practitioner | NHNCK.OrganizationReports | ProfessionalId |  |
| 5 | Practitioner Code | practitioner_code | STRING |  |  |  |  | Mã người hành nghề | NHNCK.OrganizationReports | ProfessionalId |  |
| 6 | Securities Organization Id | scr_org_id | BIGINT | X |  | F |  | FK đến tổ chức | NHNCK.OrganizationReports | OrganizationId |  |
| 7 | Securities Organization Code | scr_org_code | STRING | X |  |  |  | Mã tổ chức | NHNCK.OrganizationReports | OrganizationId |  |
| 8 | Certificate Type Code | ctf_tp_code | STRING | X |  |  |  | Mã loại chứng chỉ | NHNCK.OrganizationReports | CertificateId | Scheme: CERTIFICATE_TYPE. |
| 9 | License Certificate Document Id | license_ctf_doc_id | BIGINT | X |  | F |  | FK đến chứng chỉ hành nghề | NHNCK.OrganizationReports | CertificateRecordId |  |
| 10 | License Certificate Document Code | license_ctf_doc_code | STRING | X |  |  |  | Mã chứng chỉ | NHNCK.OrganizationReports | CertificateRecordId |  |
| 11 | Parent Organization Employment Report Id | prn_org_emp_rpt_id | BIGINT | X |  | F |  | FK self-ref — báo cáo cha | NHNCK.OrganizationReports | ParentReportId |  |
| 12 | Parent Organization Employment Report Code | prn_org_emp_rpt_code | STRING | X |  |  |  | Mã báo cáo cha | NHNCK.OrganizationReports | ParentReportId |  |
| 13 | Report Type Code | rpt_tp_code | STRING | X |  |  |  | Loại báo cáo | NHNCK.OrganizationReports | Type | Scheme: REPORT_TYPE. |
| 14 | Report Date | rpt_dt | DATE | X |  |  |  | Ngày báo cáo | NHNCK.OrganizationReports | ReportDate |  |
| 15 | Full Name | full_nm | STRING | X |  |  |  | Họ và tên (snapshot) | NHNCK.OrganizationReports | FullName |  |
| 16 | Date Of Birth | dob | DATE | X |  |  |  | Ngày sinh (snapshot) | NHNCK.OrganizationReports | BirthDate |  |
| 17 | Identification Number | identn_nbr | STRING | X |  |  |  | Số chứng minh thư (snapshot) | NHNCK.OrganizationReports | IdentityNumber |  |
| 18 | Position Name | pos_nm | STRING | X |  |  |  | Chức vụ | NHNCK.OrganizationReports | Position |  |
| 19 | Department Name | dept_nm | STRING | X |  |  |  | Phòng ban | NHNCK.OrganizationReports | Department |  |
| 20 | Business Department Name | bsn_dept_nm | STRING | X |  |  |  | Phòng ban nghiệp vụ | NHNCK.OrganizationReports | BusinessDepartment |  |
| 21 | Workplace Name | workplace_nm | STRING | X |  |  |  | Nơi công tác | NHNCK.OrganizationReports | Workplace |  |
| 22 | Hire Date | hire_dt | DATE | X |  |  |  | Ngày tiếp nhận | NHNCK.OrganizationReports | HireDate |  |
| 23 | Termination Date | tmt_dt | DATE | X |  |  |  | Ngày thôi việc | NHNCK.OrganizationReports | TerminationDate |  |
| 24 | Certificate Number | ctf_nbr | STRING | X |  |  |  | Số chứng chỉ (snapshot) | NHNCK.OrganizationReports | CertificateNumber |  |
| 25 | Certificate Issue Date | ctf_issu_dt | DATE | X |  |  |  | Ngày cấp chứng chỉ (snapshot) | NHNCK.OrganizationReports | IssueDate |  |
| 26 | Discipline Description | discipline_dsc | STRING | X |  |  |  | Kỷ luật (vi phạm hoặc xử phạt) | NHNCK.OrganizationReports | Disciplines |  |
| 27 | Report Description | rpt_dsc | STRING | X |  |  |  | Mô tả báo cáo | NHNCK.OrganizationReports | Description |  |
| 28 | Sync Id | sync_id | STRING | X |  |  |  | Mã đồng bộ | NHNCK.OrganizationReports | SyncId |  |
| 29 | Sync Created Timestamp | sync_crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo đồng bộ | NHNCK.OrganizationReports | SyncCreatedAt |  |
| 30 | Sync Updated Timestamp | sync_udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật đồng bộ | NHNCK.OrganizationReports | SyncUpdatedAt |  |
| 31 | Created By Officer Id | crt_by_ofcr_id | BIGINT | X |  | F |  | FK đến Officer | NHNCK.OrganizationReports | CreatedBy |  |
| 32 | Created By Officer Code | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo | NHNCK.OrganizationReports | CreatedBy |  |
| 33 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo | NHNCK.OrganizationReports | CreatedAt |  |
| 34 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật | NHNCK.OrganizationReports | UpdatedAt |  |


#### 2.{IDX}.19.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Organization Employment Report Id | org_emp_rpt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Practitioner Id | practitioner_id | Securities Practitioner | Practitioner Id | practitioner_id |
| Securities Organization Id | scr_org_id | Securities Organization Reference | Securities Organization Reference Id | scr_org_refr_id |
| License Certificate Document Id | license_ctf_doc_id | Securities Practitioner License Certificate Document | License Certificate Document Id | license_ctf_doc_id |
| Parent Organization Employment Report Id | prn_org_emp_rpt_id | Securities Practitioner Organization Employment Report | Organization Employment Report Id | org_emp_rpt_id |
| Created By Officer Id | crt_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |




### 2.{IDX}.20 Bảng Securities Practitioner Identity Verification Record

- **Mô tả:** Kết quả xác thực danh tính người hành nghề qua hệ thống C06 của Bộ Công An. Lưu trạng thái và phản hồi xác thực.
- **Tên vật lý:** scr_practitioner_identity_verf_rcrd
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Identity Verification Record Id | identity_verf_rcrd_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.IdentityInfoC06s |  | PK surrogate. BCV: "Verification" (Communication). Dữ liệu xác thực định danh từ C06 (Bộ Công An). |
| 2 | Identity Verification Record Code | identity_verf_rcrd_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.IdentityInfoC06s | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.IdentityInfoC06s' | Mã nguồn dữ liệu | NHNCK.IdentityInfoC06s |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Identity Number | identity_nbr | STRING | X |  |  |  | Số định danh cá nhân (CCCD/CMND) | NHNCK.IdentityInfoC06s | IdentityNumber |  |
| 5 | Full Name | full_nm | STRING | X |  |  |  | Họ và tên | NHNCK.IdentityInfoC06s | FullName |  |
| 6 | First Name | frst_nm | STRING | X |  |  |  | Tên | NHNCK.IdentityInfoC06s | FirstName |  |
| 7 | Date Of Birth | dob | DATE | X |  |  |  | Ngày sinh | NHNCK.IdentityInfoC06s | BirthDate |  |
| 8 | Birth Year | brth_yr | STRING | X |  |  |  | Năm sinh | NHNCK.IdentityInfoC06s | BirthYear |  |
| 9 | Individual Gender Code | idv_gnd_code | STRING | X |  |  |  | Giới tính (0: Nữ, 1: Nam) | NHNCK.IdentityInfoC06s | Gender | Scheme: INDIVIDUAL_GENDER. |
| 10 | Nationality Code | nationality_code | STRING | X |  |  |  | Quốc tịch | NHNCK.IdentityInfoC06s | National | Scheme: NATIONALITY. |
| 11 | Religion Name | rlg_nm | STRING | X |  |  |  | Tôn giáo | NHNCK.IdentityInfoC06s | Religion |  |
| 12 | Country Code | cty_code | STRING | X |  |  |  | Mã quốc gia | NHNCK.IdentityInfoC06s | CountryCode | Scheme: COUNTRY. |
| 13 | Place Of Birth | plc_of_brth | STRING | X |  |  |  | Nơi sinh | NHNCK.IdentityInfoC06s | PlaceOfBirth |  |
| 14 | Hometown | hometown | STRING | X |  |  |  | Địa chỉ quê quán | NHNCK.IdentityInfoC06s | Hometown |  |
| 15 | Permanent Country Code | perm_cty_code | STRING | X |  |  |  | Quốc gia nguyên quán | NHNCK.IdentityInfoC06s | PermanentCountryCode | Scheme: COUNTRY. |
| 16 | Permanent Province Code | perm_prov_code | STRING | X |  |  |  | Tỉnh thành nguyên quán | NHNCK.IdentityInfoC06s | PermanentProvinceCode | Scheme: PROVINCE. |
| 17 | Permanent District Code | perm_dstc_code | STRING | X |  |  |  | Quận huyện nguyên quán | NHNCK.IdentityInfoC06s | PermanentDistrictCode | Scheme: DISTRICT. |
| 18 | Permanent Address Detail | perm_adr_dtl | STRING | X |  |  |  | Địa chỉ nguyên quán chi tiết | NHNCK.IdentityInfoC06s | PermanentDetail |  |
| 19 | Current Country Code | crn_cty_code | STRING | X |  |  |  | Quốc gia hiện tại | NHNCK.IdentityInfoC06s | CurrentCountryCode | Scheme: COUNTRY. |
| 20 | Current Province Code | crn_prov_code | STRING | X |  |  |  | Tỉnh thành hiện tại | NHNCK.IdentityInfoC06s | CurrentProvinceCode | Scheme: PROVINCE. |
| 21 | Current District Code | crn_dstc_code | STRING | X |  |  |  | Quận huyện hiện tại | NHNCK.IdentityInfoC06s | CurrentDistrictCode | Scheme: DISTRICT. |
| 22 | Current Address Detail | crn_adr_dtl | STRING | X |  |  |  | Địa chỉ hiện tại chi tiết | NHNCK.IdentityInfoC06s | CurrentDetail |  |
| 23 | Father Full Name | fthr_full_nm | STRING | X |  |  |  | Họ và tên bố | NHNCK.IdentityInfoC06s | FatherFullName |  |
| 24 | Father Country Code | fthr_cty_code | STRING | X |  |  |  | Quốc gia của bố | NHNCK.IdentityInfoC06s | FatherCountryCode | Scheme: COUNTRY. |
| 25 | Father Identity Number | fthr_identity_nbr | STRING | X |  |  |  | Số định danh của bố | NHNCK.IdentityInfoC06s | FatherIdentityNumber |  |
| 26 | Father Identity Number Old | fthr_identity_nbr_old | STRING | X |  |  |  | Số định danh cũ của bố | NHNCK.IdentityInfoC06s | FatherIdentityNumberOld |  |
| 27 | Mother Full Name | mthr_full_nm | STRING | X |  |  |  | Họ và tên mẹ | NHNCK.IdentityInfoC06s | MotherFullName |  |
| 28 | Mother Country Code | mthr_cty_code | STRING | X |  |  |  | Quốc gia của mẹ | NHNCK.IdentityInfoC06s | MotherCountryCode | Scheme: COUNTRY. |
| 29 | Mother Identity Number | mthr_identity_nbr | STRING | X |  |  |  | Số định danh của mẹ | NHNCK.IdentityInfoC06s | MotherIdentityNumber |  |
| 30 | Mother Identity Number Old | mthr_identity_nbr_old | STRING | X |  |  |  | Số định danh cũ của mẹ | NHNCK.IdentityInfoC06s | MotherIdentityNumberOld |  |
| 31 | Couple Full Name | couple_full_nm | STRING | X |  |  |  | Họ và tên vợ/chồng | NHNCK.IdentityInfoC06s | CoupleFullName |  |
| 32 | Couple Country Code | couple_cty_code | STRING | X |  |  |  | Quốc gia của vợ/chồng | NHNCK.IdentityInfoC06s | CoupleCountryCode | Scheme: COUNTRY. |
| 33 | Couple Identity Number | couple_identity_nbr | STRING | X |  |  |  | Số định danh của vợ/chồng | NHNCK.IdentityInfoC06s | CoupleIdentityNumber |  |
| 34 | Couple Identity Number Old | couple_identity_nbr_old | STRING | X |  |  |  | Số định danh cũ của vợ/chồng | NHNCK.IdentityInfoC06s | CoupleIdentityNumberOld |  |
| 35 | Updated By Officer Id | udt_by_ofcr_id | BIGINT | X |  | F |  | FK đến người cập nhật | NHNCK.IdentityInfoC06s | UserUpdateId |  |
| 36 | Updated By Officer Code | udt_by_ofcr_code | STRING | X |  |  |  | Mã người cập nhật | NHNCK.IdentityInfoC06s | UserUpdateId |  |


#### 2.{IDX}.20.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Identity Verification Record Id | identity_verf_rcrd_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Updated By Officer Id | udt_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |




### 2.{IDX}.21 Bảng Securities Practitioner Professional Training Class

- **Mô tả:** Khóa đào tạo chuyên môn nghiệp vụ chứng khoán do UBCKNN tổ chức. Ghi nhận thông tin khóa học và ngày thi.
- **Tên vật lý:** scr_practitioner_prof_trn_clss
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Professional Training Class Id | prof_trn_clss_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.SpecializationCourses |  | PK surrogate. BCV: "Business Activity" — khóa học chuyên môn định kỳ. |
| 2 | Professional Training Class Code | prof_trn_clss_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.SpecializationCourses | Id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.SpecializationCourses' | Mã nguồn dữ liệu | NHNCK.SpecializationCourses |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Specialization Type Code | specialization_tp_code | STRING |  |  | F |  | Mã chuyên môn | NHNCK.SpecializationCourses | SpecializationId | Scheme: SPECIALIZATION_TYPE. FK đến bảng Specializations. |
| 5 | Course Code | course_code | STRING | X |  |  |  | Mã khóa học (mã nghiệp vụ) | NHNCK.SpecializationCourses | CourseCode |  |
| 6 | Course Name | course_nm | STRING | X |  |  |  | Tên khóa học | NHNCK.SpecializationCourses | CourseName |  |
| 7 | Academic Year | academic_yr | STRING | X |  |  |  | Năm học | NHNCK.SpecializationCourses | AcademicYear |  |
| 8 | Exam Date | exam_dt | DATE | X |  |  |  | Ngày thi | NHNCK.SpecializationCourses | ExamDate |  |
| 9 | Course Description | course_dsc | STRING | X |  |  |  | Mô tả khóa học | NHNCK.SpecializationCourses | Description |  |
| 10 | Attachment File Path | attachment_file_path | STRING | X |  |  |  | Đường dẫn tài liệu | NHNCK.SpecializationCourses | FilePath |  |
| 11 | Is Active Flag | is_actv_f | BOOLEAN | X |  |  |  | Trạng thái hoạt động | NHNCK.SpecializationCourses | IsActive |  |
| 12 | Course Status Code | course_st_code | STRING | X |  |  |  | Trạng thái (1: Hoạt động, 0: Không hoạt động, -1: Đã xóa) | NHNCK.SpecializationCourses | Status | Scheme: COURSE_STATUS. |
| 13 | Created By Officer Id | crt_by_ofcr_id | BIGINT | X |  | F |  | FK đến Officer | NHNCK.SpecializationCourses | CreatedBy |  |
| 14 | Created By Officer Code | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo | NHNCK.SpecializationCourses | CreatedBy |  |
| 15 | Updated By Officer Id | udt_by_ofcr_id | BIGINT | X |  | F |  | FK đến Officer | NHNCK.SpecializationCourses | UpdatedBy |  |
| 16 | Updated By Officer Code | udt_by_ofcr_code | STRING | X |  |  |  | Mã người cập nhật | NHNCK.SpecializationCourses | UpdatedBy |  |
| 17 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo | NHNCK.SpecializationCourses | CreatedAt |  |
| 18 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật | NHNCK.SpecializationCourses | UpdatedAt |  |


#### 2.{IDX}.21.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Professional Training Class Id | prof_trn_clss_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Created By Officer Id | crt_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |
| Updated By Officer Id | udt_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |




### 2.{IDX}.22 Bảng Securities Practitioner Professional Training Class Enrollment

- **Mô tả:** Đăng ký tham gia và kết quả học tập của người hành nghề tại một khóa đào tạo chuyên môn.
- **Tên vật lý:** scr_practitioner_prof_trn_clss_enrollment
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Professional Training Class Enrollment Id | prof_trn_clss_enrollment_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.SpecializationCourseDetails |  | PK surrogate. BCV: "Business Activity" — đăng ký học viên + kết quả. |
| 2 | Professional Training Class Enrollment Code | prof_trn_clss_enrollment_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.SpecializationCourseDetails | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.SpecializationCourseDetails' | Mã nguồn dữ liệu | NHNCK.SpecializationCourseDetails |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Professional Training Class Id | prof_trn_clss_id | BIGINT |  |  | F |  | FK đến khóa học | NHNCK.SpecializationCourseDetails | SpecializationCourseId |  |
| 5 | Professional Training Class Code | prof_trn_clss_code | STRING |  |  |  |  | Mã khóa học | NHNCK.SpecializationCourseDetails | SpecializationCourseId |  |
| 6 | Practitioner Id | practitioner_id | BIGINT |  |  | F |  | FK đến Securities Practitioner | NHNCK.SpecializationCourseDetails | ProfessionalId |  |
| 7 | Practitioner Code | practitioner_code | STRING |  |  |  |  | Mã người hành nghề | NHNCK.SpecializationCourseDetails | ProfessionalId |  |
| 8 | Full Name | full_nm | STRING | X |  |  |  | Họ và tên học viên (snapshot) | NHNCK.SpecializationCourseDetails | Fullname |  |
| 9 | Date Of Birth | dob | DATE | X |  |  |  | Ngày sinh (snapshot) | NHNCK.SpecializationCourseDetails | BirthDate |  |
| 10 | Place Of Birth | plc_of_brth | STRING | X |  |  |  | Nơi sinh (snapshot) | NHNCK.SpecializationCourseDetails | PlaceOfDate |  |
| 11 | Identification Number | identn_nbr | STRING | X |  |  |  | Số định danh (snapshot) | NHNCK.SpecializationCourseDetails | IdentityNumber |  |
| 12 | Exam Number | exam_nbr | STRING | X |  |  |  | Số dự thi | NHNCK.SpecializationCourseDetails | ExamNumber |  |
| 13 | Enrollment Description | enrollment_dsc | STRING | X |  |  |  | Mô tả | NHNCK.SpecializationCourseDetails | Description |  |
| 14 | Assessment Score | ases_scor | STRING | X |  |  |  | Điểm thi | NHNCK.SpecializationCourseDetails | ExamScore |  |
| 15 | Assessment Result Code | ases_rslt_code | STRING | X |  |  |  | Kết quả thi (1: Đạt, 0: Không đạt) | NHNCK.SpecializationCourseDetails | Result | Scheme: TRAINING_RESULT. |
| 16 | Enrollment Note | enrollment_note | STRING | X |  |  |  | Ghi chú | NHNCK.SpecializationCourseDetails | Note |  |
| 17 | Enrollment Status Code | enrollment_st_code | STRING | X |  |  |  | Trạng thái (0: Chờ thẩm định, 1: Xác nhận, 2: Yêu cầu nộp lại, 3: Từ chối) | NHNCK.SpecializationCourseDetails | Status | Scheme: ENROLLMENT_STATUS. |
| 18 | Assignee Officer Id | assignee_ofcr_id | BIGINT | X |  | F |  | FK đến cán bộ xử lý | NHNCK.SpecializationCourseDetails | AssigneeId |  |
| 19 | Assignee Officer Code | assignee_ofcr_code | STRING | X |  |  |  | Mã cán bộ xử lý | NHNCK.SpecializationCourseDetails | AssigneeId |  |
| 20 | Created By Officer Id | crt_by_ofcr_id | BIGINT | X |  | F |  | FK đến Officer | NHNCK.SpecializationCourseDetails | CreatedBy |  |
| 21 | Created By Officer Code | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo | NHNCK.SpecializationCourseDetails | CreatedBy |  |
| 22 | Updated By Officer Id | udt_by_ofcr_id | BIGINT | X |  | F |  | FK đến Officer | NHNCK.SpecializationCourseDetails | UpdatedBy |  |
| 23 | Updated By Officer Code | udt_by_ofcr_code | STRING | X |  |  |  | Mã người cập nhật | NHNCK.SpecializationCourseDetails | UpdatedBy |  |
| 24 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo | NHNCK.SpecializationCourseDetails | CreatedAt |  |
| 25 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật | NHNCK.SpecializationCourseDetails | UpdatedAt |  |


#### 2.{IDX}.22.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Professional Training Class Enrollment Id | prof_trn_clss_enrollment_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Professional Training Class Id | prof_trn_clss_id | Securities Practitioner Professional Training Class | Professional Training Class Id | prof_trn_clss_id |
| Practitioner Id | practitioner_id | Securities Practitioner | Practitioner Id | practitioner_id |
| Assignee Officer Id | assignee_ofcr_id | Regulatory Authority Officer | Officer Id |  |
| Created By Officer Id | crt_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |
| Updated By Officer Id | udt_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |




### 2.{IDX}.23 Bảng Securities Practitioner Qualification Examination Assessment

- **Mô tả:** Đợt thi sát hạch cấp chứng chỉ hành nghề chứng khoán. Ghi nhận thông tin tổ chức đợt thi và quyết định công nhận kết quả.
- **Tên vật lý:** scr_practitioner_qualf_exam_ases
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Examination Assessment Id | exam_ases_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.ExamSessions |  | PK surrogate. BCV: "Assessment" (Communication). Đợt thi sát hạch CCHN. |
| 2 | Examination Assessment Code | exam_ases_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.ExamSessions | Id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.ExamSessions' | Mã nguồn dữ liệu | NHNCK.ExamSessions |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Session Code | ssn_code | STRING | X |  |  |  | Mã đợt thi (mã nghiệp vụ) | NHNCK.ExamSessions | Code |  |
| 5 | Session Name | ssn_nm | STRING | X |  |  |  | Tên đợt thi | NHNCK.ExamSessions | Name |  |
| 6 | Examination Year | exam_yr | STRING | X |  |  |  | Năm thi | NHNCK.ExamSessions | Year |  |
| 7 | Session Number | ssn_nbr | STRING | X |  |  |  | Đợt thi (số thứ tự trong năm) | NHNCK.ExamSessions | Session |  |
| 8 | Organizer Name | organizer_nm | STRING | X |  |  |  | Đơn vị tổ chức | NHNCK.ExamSessions | OrganizingUnit |  |
| 9 | Registration Start Date | rgst_strt_dt | DATE | X |  |  |  | Ngày bắt đầu nhận hồ sơ | NHNCK.ExamSessions | ApplicationStartDate |  |
| 10 | Registration End Date | rgst_end_dt | DATE | X |  |  |  | Ngày kết thúc nhận hồ sơ | NHNCK.ExamSessions | ApplicationEndDate |  |
| 11 | Examination Start Date | exam_strt_dt | DATE | X |  |  |  | Ngày bắt đầu thi | NHNCK.ExamSessions | ExamStartDate |  |
| 12 | Examination End Date | exam_end_dt | DATE | X |  |  |  | Ngày kết thúc thi | NHNCK.ExamSessions | ExamEndDate |  |
| 13 | Examination Location | exam_lo | STRING | X |  |  |  | Địa điểm thi | NHNCK.ExamSessions | ExamLocations |  |
| 14 | Notification Date | notf_dt | DATE | X |  |  |  | Ngày thông báo kết quả | NHNCK.ExamSessions | NotiDate |  |
| 15 | Submission Method Description | submission_mth_dsc | STRING | X |  |  |  | Phương thức nộp hồ sơ | NHNCK.ExamSessions | SubmissionMethods |  |
| 16 | Attachment File Path | attachment_file_path | STRING | X |  |  |  | File thông báo đính kèm | NHNCK.ExamSessions | FilePath |  |
| 17 | License Decision Document Id | license_dcsn_doc_id | BIGINT | X |  | F |  | FK đến quyết định công nhận kết quả | NHNCK.ExamSessions | DecisionId |  |
| 18 | License Decision Document Code | license_dcsn_doc_code | STRING | X |  |  |  | Mã quyết định | NHNCK.ExamSessions | DecisionId |  |
| 19 | Examination Status Code | exam_st_code | STRING | X |  |  |  | Trạng thái (0: Chưa hoàn thành, 1: Đã hoàn thành) | NHNCK.ExamSessions | Status | Scheme: EXAMINATION_STATUS. |
| 20 | Created By Officer Id | crt_by_ofcr_id | BIGINT | X |  | F |  | FK đến Officer | NHNCK.ExamSessions | CreatedBy |  |
| 21 | Created By Officer Code | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo | NHNCK.ExamSessions | CreatedBy |  |


#### 2.{IDX}.23.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Examination Assessment Id | exam_ases_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| License Decision Document Id | license_dcsn_doc_id | Securities Practitioner License Decision Document | License Decision Document Id | license_dcsn_doc_id |
| Created By Officer Id | crt_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |




### 2.{IDX}.24 Bảng Securities Practitioner Qualification Examination Assessment Result

- **Mô tả:** Kết quả thi sát hạch của từng thí sinh trong một đợt thi. Ghi nhận điểm thi và kết quả đạt/không đạt.
- **Tên vật lý:** scr_practitioner_qualf_exam_ases_rslt
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Examination Assessment Result Id | exam_ases_rslt_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.ExamDetails |  | PK surrogate. BCV: "Assessment" (Communication). Kết quả thi của thí sinh. |
| 2 | Examination Assessment Result Code | exam_ases_rslt_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.ExamDetails | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.ExamDetails' | Mã nguồn dữ liệu | NHNCK.ExamDetails |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Examination Assessment Id | exam_ases_id | BIGINT |  |  | F |  | FK đến đợt thi | NHNCK.ExamDetails | ExamSessionId |  |
| 5 | Examination Assessment Code | exam_ases_code | STRING |  |  |  |  | Mã đợt thi | NHNCK.ExamDetails | ExamSessionId |  |
| 6 | Practitioner Id | practitioner_id | BIGINT |  |  | F |  | FK đến Securities Practitioner | NHNCK.ExamDetails | ProfessionalId |  |
| 7 | Practitioner Code | practitioner_code | STRING |  |  |  |  | Mã người hành nghề | NHNCK.ExamDetails | ProfessionalId |  |
| 8 | Certificate Type Code | ctf_tp_code | STRING | X |  |  |  | Mã loại chứng chỉ dự thi | NHNCK.ExamDetails | CertificateId | Scheme: CERTIFICATE_TYPE. |
| 9 | License Application Id | license_ap_id | BIGINT | X |  | F |  | FK đến hồ sơ | NHNCK.ExamDetails | ApplicationId |  |
| 10 | License Application Code | license_ap_code | STRING | X |  |  |  | Mã hồ sơ | NHNCK.ExamDetails | ApplicationId |  |
| 11 | Sequence Number | seq_nbr | INT | X |  |  |  | Số thứ tự trong đợt thi | NHNCK.ExamDetails | SequenceNumber |  |
| 12 | Exam Number | exam_nbr | STRING | X |  |  |  | Số báo danh | NHNCK.ExamDetails | ExamNumber |  |
| 13 | Law Score | law_scor | STRING | X |  |  |  | Điểm pháp luật | NHNCK.ExamDetails | LawScore |  |
| 14 | Law Result Indicator | law_rslt_ind | BOOLEAN | X |  |  |  | Kết quả luật (1: Đạt, 0: Không đạt) | NHNCK.ExamDetails | LawResult |  |
| 15 | Specialization Score | specialization_scor | STRING | X |  |  |  | Điểm chuyên môn | NHNCK.ExamDetails | SpecializationScore |  |
| 16 | Specialization Result Indicator | specialization_rslt_ind | BOOLEAN | X |  |  |  | Kết quả chuyên môn (1: Đạt, 0: Không đạt) | NHNCK.ExamDetails | SpecializationResult |  |
| 17 | Examination Result Code | exam_rslt_code | STRING | X |  |  |  | Kết quả tổng (1: Đạt, 0: Không đạt) | NHNCK.ExamDetails | Result | Scheme: EXAMINATION_RESULT. |
| 18 | Examination Note | exam_note | STRING | X |  |  |  | Ghi chú | NHNCK.ExamDetails | Note |  |
| 19 | Created By Officer Id | crt_by_ofcr_id | BIGINT | X |  | F |  | FK đến Officer | NHNCK.ExamDetails | CreatedBy |  |
| 20 | Created By Officer Code | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo | NHNCK.ExamDetails | CreatedBy |  |
| 21 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo | NHNCK.ExamDetails | CreatedAt |  |


#### 2.{IDX}.24.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Examination Assessment Result Id | exam_ases_rslt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Examination Assessment Id | exam_ases_id | Securities Practitioner Qualification Examination Assessment | Examination Assessment Id | exam_ases_id |
| Practitioner Id | practitioner_id | Securities Practitioner | Practitioner Id | practitioner_id |
| License Application Id | license_ap_id | Securities Practitioner License Application | License Application Id | license_ap_id |
| Created By Officer Id | crt_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |




### 2.{IDX}.25 Bảng Securities Practitioner Qualification Examination Assessment Fee

- **Mô tả:** Biểu phí thi sát hạch theo đợt thi và loại chứng chỉ. Ghi nhận mức phí thi và phúc khảo.
- **Tên vật lý:** scr_practitioner_qualf_exam_ases_fee
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Examination Assessment Fee Id | exam_ases_fee_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.ExamSessionFees |  | PK surrogate. BCV: "Condition" (Condition). Mức phí thi theo đợt thi + loại chứng chỉ. |
| 2 | Examination Assessment Fee Code | exam_ases_fee_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.ExamSessionFees | Id | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.ExamSessionFees' | Mã nguồn dữ liệu | NHNCK.ExamSessionFees |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Examination Assessment Id | exam_ases_id | BIGINT |  |  | F |  | FK đến đợt thi | NHNCK.ExamSessionFees | ExamSessionId |  |
| 5 | Examination Assessment Code | exam_ases_code | STRING |  |  |  |  | Mã đợt thi | NHNCK.ExamSessionFees | ExamSessionId |  |
| 6 | Certificate Type Code | ctf_tp_code | STRING |  |  |  |  | Mã loại chứng chỉ | NHNCK.ExamSessionFees | CertificateId | Scheme: CERTIFICATE_TYPE. |
| 7 | Examination Fee Amount | exam_fee_amt | DECIMAL(18,2) | X |  |  |  | Phí thi (VNĐ) | NHNCK.ExamSessionFees | FeeExam |  |
| 8 | Appeal Fee Amount | appeal_fee_amt | DECIMAL(18,2) | X |  |  |  | Phí phúc khảo (VNĐ) | NHNCK.ExamSessionFees | FeeAppeal |  |
| 9 | Fee Status Code | fee_st_code | STRING | X |  |  |  | Trạng thái | NHNCK.ExamSessionFees | Status | Scheme: FEE_STATUS. |
| 10 | Created By Officer Id | crt_by_ofcr_id | BIGINT | X |  | F |  | FK đến Officer | NHNCK.ExamSessionFees | CreatedBy |  |
| 11 | Created By Officer Code | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo | NHNCK.ExamSessionFees | CreatedBy |  |
| 12 | Updated By Officer Id | udt_by_ofcr_id | BIGINT | X |  | F |  | FK đến Officer | NHNCK.ExamSessionFees | UpdatedBy |  |
| 13 | Updated By Officer Code | udt_by_ofcr_code | STRING | X |  |  |  | Mã người cập nhật | NHNCK.ExamSessionFees | UpdatedBy |  |
| 14 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo | NHNCK.ExamSessionFees | CreatedAt |  |
| 15 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật | NHNCK.ExamSessionFees | UpdatedAt |  |


#### 2.{IDX}.25.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Examination Assessment Fee Id | exam_ases_fee_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Examination Assessment Id | exam_ases_id | Securities Practitioner Qualification Examination Assessment | Examination Assessment Id | exam_ases_id |
| Created By Officer Id | crt_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |
| Updated By Officer Id | udt_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |




### 2.{IDX}.26 Bảng Securities Organization Reference

- **Mô tả:** Tổ chức tham gia thị trường chứng khoán (CTCK/QLQ/NH) được UBCKNN quản lý. Danh mục tổ chức tham chiếu trong hệ thống NHNCK.
- **Tên vật lý:** scr_org_refr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Securities Organization Reference Id | scr_org_refr_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.Organizations |  | PK surrogate. BCV: "Organization" (Involved Party). Tổ chức tham gia TTCK (CTCK, QLQ, NH...). |
| 2 | Securities Organization Reference Code | scr_org_refr_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.Organizations | Id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.Organizations' | Mã nguồn dữ liệu | NHNCK.Organizations |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Organization Code | org_code | STRING | X |  |  |  | Mã tổ chức (mã nghiệp vụ) | NHNCK.Organizations | OrganizationCode |  |
| 5 | Organization Name | org_nm | STRING | X |  |  |  | Tên tổ chức | NHNCK.Organizations | OrganizationName |  |
| 6 | English Name | english_nm | STRING | X |  |  |  | Tên tiếng Anh | NHNCK.Organizations | EnglishName |  |
| 7 | Abbreviation | abr | STRING | X |  |  |  | Tên viết tắt | NHNCK.Organizations | Abbreviation |  |
| 8 | Organization Type Code | org_tp_code | STRING | X |  |  |  | Mã loại tổ chức (1: CTCK, 2: QLQ, 3: Ngân hàng, 4: Khác) | NHNCK.Organizations | OrganizationTypeId | Scheme: ORGANIZATION_TYPE. |
| 9 | Organization Level Code | org_lvl_code | STRING | X |  |  |  | Cấp độ tổ chức | NHNCK.Organizations | Level | Scheme: ORGANIZATION_LEVEL. |
| 10 | Parent Organization Id | prn_org_id | BIGINT | X |  | F |  | FK self-referencing — tổ chức cha | NHNCK.Organizations | ParentId |  |
| 11 | Parent Organization Code | prn_org_code | STRING | X |  |  |  | Mã tổ chức cha | NHNCK.Organizations | ParentId |  |
| 12 | Representative Name | representative_nm | STRING | X |  |  |  | Người đại diện | NHNCK.Organizations | Representative |  |
| 13 | Charter Capital Amount | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ | NHNCK.Organizations | CharterCapital |  |
| 14 | License Number | license_nbr | STRING | X |  |  |  | Số giấy phép hoạt động | NHNCK.Organizations | LicenseNumber |  |
| 15 | License Issuer | license_issur | STRING | X |  |  |  | Cơ quan cấp giấy phép | NHNCK.Organizations | LicenseIssuer |  |
| 16 | License Date | license_dt | DATE | X |  |  |  | Ngày cấp giấy phép | NHNCK.Organizations | LicenseDate |  |
| 17 | Website | webst | STRING | X |  |  |  | Địa chỉ website | NHNCK.Organizations | Website |  |
| 18 | Organization Description | org_dsc | STRING | X |  |  |  | Mô tả | NHNCK.Organizations | Description |  |
| 19 | Organization Status Code | org_st_code | STRING | X |  |  |  | Trạng thái | NHNCK.Organizations | Status | Scheme: ORGANIZATION_STATUS. |
| 20 | Sort Order | sort_ordr | INT | X |  |  |  | Thứ tự sắp xếp | NHNCK.Organizations | SortOrder |  |
| 21 | Linked Id | linked_id | STRING | X |  |  |  | ID liên kết | NHNCK.Organizations | LinkedId |  |
| 22 | Sync Id | sync_id | STRING | X |  |  |  | Mã đồng bộ | NHNCK.Organizations | SyncId |  |
| 23 | Last Sync Date | last_sync_dt | DATE | X |  |  |  | Lần cuối đồng bộ | NHNCK.Organizations | LastSyncDate |  |
| 24 | Sync Status Code | sync_st_code | STRING | X |  |  |  | Trạng thái đồng bộ | NHNCK.Organizations | SyncStatus | Scheme: SYNC_STATUS. |
| 25 | Created By Officer Id | crt_by_ofcr_id | BIGINT | X |  | F |  | FK đến Officer | NHNCK.Organizations | CreatedBy |  |
| 26 | Created By Officer Code | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo | NHNCK.Organizations | CreatedBy |  |
| 27 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo | NHNCK.Organizations | CreatedAt |  |
| 28 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật | NHNCK.Organizations | UpdatedAt |  |


#### 2.{IDX}.26.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Securities Organization Reference Id | scr_org_refr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Parent Organization Id | prn_org_id | Securities Organization Reference | Securities Organization Reference Id | scr_org_refr_id |
| Created By Officer Id | crt_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |




### 2.{IDX}.27 Bảng Securities Practitioner License Decision Document

- **Mô tả:** Quyết định hành chính của UBCKNN về cấp/thu hồi/hủy chứng chỉ hành nghề chứng khoán.
- **Tên vật lý:** scr_practitioner_license_dcsn_doc
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | License Decision Document Id | license_dcsn_doc_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.Decisions |  | PK surrogate. BCV: "Government Registration Document" (Documentation). Quyết định hành chính. |
| 2 | License Decision Document Code | license_dcsn_doc_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK | NHNCK.Decisions | Id | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.Decisions' | Mã nguồn dữ liệu | NHNCK.Decisions |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Decision Number | dcsn_nbr | STRING | X |  |  |  | Số quyết định | NHNCK.Decisions | DecisionNumber |  |
| 5 | Decision Title | dcsn_ttl | STRING | X |  |  |  | Tiêu đề quyết định | NHNCK.Decisions | Title |  |
| 6 | Decision Reference | dcsn_refr | STRING | X |  |  |  | Trích dẫn | NHNCK.Decisions | Reference |  |
| 7 | Decision Content | dcsn_cntnt | STRING | X |  |  |  | Nội dung quyết định | NHNCK.Decisions | DecisionContent |  |
| 8 | Signing Date | signing_dt | DATE | X |  |  |  | Ngày ký | NHNCK.Decisions | SignedDate |  |
| 9 | Signatory Name | signatory_nm | STRING | X |  |  |  | Người ký | NHNCK.Decisions | Signatory |  |
| 10 | Signatory Position Name | signatory_pos_nm | STRING | X |  |  |  | Chức vụ người ký | NHNCK.Decisions | Position |  |
| 11 | Decision Unit Name | dcsn_unit_nm | STRING | X |  |  |  | Đơn vị ban hành | NHNCK.Decisions | DecisionUnit |  |
| 12 | Attachment File Name | attachment_file_nm | STRING | X |  |  |  | Tên file đính kèm | NHNCK.Decisions | FileName |  |
| 13 | Attachment File Path | attachment_file_path | STRING | X |  |  |  | Đường dẫn file | NHNCK.Decisions | FilePath |  |
| 14 | Decision Type Code | dcsn_tp_code | STRING | X |  |  |  | Loại quyết định | NHNCK.Decisions | TypeId | Scheme: DECISION_TYPE. |
| 15 | Decision Status Code | dcsn_st_code | STRING | X |  |  |  | Trạng thái quyết định | NHNCK.Decisions | Status | Scheme: DECISION_STATUS. |
| 16 | Created By Officer Id | crt_by_ofcr_id | BIGINT | X |  | F |  | FK đến Officer | NHNCK.Decisions | CreatedBy |  |
| 17 | Created By Officer Code | crt_by_ofcr_code | STRING | X |  |  |  | Mã người tạo | NHNCK.Decisions | CreatedBy |  |
| 18 | Created Timestamp | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo | NHNCK.Decisions | CreatedAt |  |
| 19 | Updated Timestamp | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật | NHNCK.Decisions | UpdatedAt |  |


#### 2.{IDX}.27.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| License Decision Document Id | license_dcsn_doc_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Created By Officer Id | crt_by_ofcr_id | Regulatory Authority Officer | Officer Id |  |




### 2.{IDX}.28 Bảng Regulatory Authority Organization Unit — NHNCK.Units

- **Mô tả:** Đơn vị/phòng ban thuộc UBCKNN. Cấu trúc phân cấp gộp Units và Departments.
- **Tên vật lý:** reg_ahr_ou
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Organization Unit Id | ou_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.Units |  | PK surrogate. BCV: "Organization" (Involved Party). Đơn vị thuộc UBCK. |
| 2 | Organization Unit Code | ou_code | STRING |  |  |  |  | Mã đơn vị. BK | NHNCK.Units | UnitCode | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.Units' | Mã nguồn dữ liệu | NHNCK.Units |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Organization Unit Type Code | ou_tp_code | STRING |  |  |  |  | Phân loại — Đơn vị (Unit) | NHNCK.Units |  |  |
| 5 | Organization Unit Name | ou_nm | STRING | X |  |  |  | Tên đơn vị | NHNCK.Units | UnitName |  |
| 6 | Organization Unit Description | ou_dsc | STRING | X |  |  |  | Mô tả | NHNCK.Units | Description |  |
| 7 | Organization Unit Status Code | ou_st_code | STRING | X |  |  |  | Trạng thái | NHNCK.Units | Status | Scheme: ORGANIZATION_UNIT_STATUS. |
| 8 | Parent Organization Unit Id | prn_ou_id | BIGINT | X |  | F |  | FK đến đơn vị cha (Units) | NHNCK.Units |  |  |
| 9 | Parent Organization Unit Code | prn_ou_code | STRING | X |  |  |  | Mã đơn vị cha | NHNCK.Units |  |  |
| 10 | Sort Order | sort_ordr | INT | X |  |  |  | Thứ tự sắp xếp | NHNCK.Units |  |  |


#### 2.{IDX}.28.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Organization Unit Id | ou_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Parent Organization Unit Id | prn_ou_id | Regulatory Authority Organization Unit | Organization Unit Id | ou_id |




### 2.{IDX}.29 Bảng Regulatory Authority Organization Unit — NHNCK.Departments

- **Mô tả:** Đơn vị/phòng ban thuộc UBCKNN. Cấu trúc phân cấp gộp Units và Departments.
- **Tên vật lý:** reg_ahr_ou
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Organization Unit Id | ou_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | NHNCK.Departments |  | PK surrogate. BCV: "Organization" (Involved Party). Phòng ban thuộc đơn vị UBCK. |
| 2 | Organization Unit Code | ou_code | STRING |  |  |  |  | Mã phòng ban. BK | NHNCK.Departments | DepartmentCode | BK chính. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.Departments' | Mã nguồn dữ liệu | NHNCK.Departments |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Organization Unit Type Code | ou_tp_code | STRING |  |  |  |  | Phân loại — Phòng ban (Department) | NHNCK.Departments |  |  |
| 5 | Organization Unit Name | ou_nm | STRING | X |  |  |  | Tên phòng ban | NHNCK.Departments | DepartmentName |  |
| 6 | Organization Unit Description | ou_dsc | STRING | X |  |  |  | Mô tả | NHNCK.Departments | Description |  |
| 7 | Organization Unit Status Code | ou_st_code | STRING | X |  |  |  | Trạng thái | NHNCK.Departments | Status | Scheme: ORGANIZATION_UNIT_STATUS. |
| 8 | Parent Organization Unit Id | prn_ou_id | BIGINT | X |  | F |  | FK đến đơn vị cha (Units) | NHNCK.Departments | UnitId |  |
| 9 | Parent Organization Unit Code | prn_ou_code | STRING | X |  |  |  | Mã đơn vị cha | NHNCK.Departments | UnitId |  |
| 10 | Sort Order | sort_ordr | INT | X |  |  |  | Thứ tự sắp xếp | NHNCK.Departments | SortOrder |  |


#### 2.{IDX}.29.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Organization Unit Id | ou_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Parent Organization Unit Id | prn_ou_id | Regulatory Authority Organization Unit | Organization Unit Id | ou_id |




### 2.{IDX}.30 Bảng Involved Party Postal Address — NHNCK.Organizations

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Securities Organization Reference | NHNCK.Organizations | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã tổ chức | NHNCK.Organizations | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.Organizations' | Mã nguồn dữ liệu | NHNCK.Organizations |  |  |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ — trụ sở chính | NHNCK.Organizations |  |  |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ tổ chức | NHNCK.Organizations | Address |  |
| 6 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | NHNCK.Organizations |  |  |
| 7 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). | NHNCK.Organizations |  |  |
| 8 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. | NHNCK.Organizations |  |  |
| 9 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. | NHNCK.Organizations |  |  |
| 10 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | NHNCK.Organizations |  |  |
| 11 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | NHNCK.Organizations |  |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | NHNCK.Organizations |  |  |


#### 2.{IDX}.30.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Organization Reference | Securities Organization Reference Id | scr_org_refr_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.31 Bảng Involved Party Electronic Address — NHNCK.Organizations

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Securities Organization Reference | NHNCK.Organizations | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã tổ chức | NHNCK.Organizations | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.Organizations' | Mã nguồn dữ liệu | NHNCK.Organizations |  |  |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — email | NHNCK.Organizations |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Email | NHNCK.Organizations | Email |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Securities Organization Reference | NHNCK.Organizations | Id |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã tổ chức | NHNCK.Organizations | Id |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.Organizations' | Mã nguồn dữ liệu | NHNCK.Organizations |  |  |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — fax | NHNCK.Organizations |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Fax | NHNCK.Organizations | Fax |  |
| 11 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Securities Organization Reference | NHNCK.Organizations | Id |  |
| 12 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã tổ chức | NHNCK.Organizations | Id |  |
| 13 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.Organizations' | Mã nguồn dữ liệu | NHNCK.Organizations |  |  |
| 14 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — số di động | NHNCK.Organizations |  |  |
| 15 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số di động | NHNCK.Organizations | MobileNumber |  |
| 16 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Securities Organization Reference | NHNCK.Organizations | Id |  |
| 17 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã tổ chức | NHNCK.Organizations | Id |  |
| 18 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.Organizations' | Mã nguồn dữ liệu | NHNCK.Organizations |  |  |
| 19 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — điện thoại | NHNCK.Organizations |  |  |
| 20 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại | NHNCK.Organizations | PhoneNumber |  |


#### 2.{IDX}.31.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Organization Reference | Securities Organization Reference Id | scr_org_refr_id |




### 2.{IDX}.32 Bảng Involved Party Alternative Identification — NHNCK.Organizations

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Securities Organization Reference | NHNCK.Organizations | Id |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã tổ chức | NHNCK.Organizations | Id |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'NHNCK.Organizations' | Mã nguồn dữ liệu | NHNCK.Organizations |  |  |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ — Số giấy phép hoạt động | NHNCK.Organizations |  |  |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số giấy phép hoạt động | NHNCK.Organizations | LicenseNumber |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép | NHNCK.Organizations | LicenseDate |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Cơ quan cấp giấy phép | NHNCK.Organizations | LicenseIssuer |  |


#### 2.{IDX}.32.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Securities Organization Reference | Securities Organization Reference Id | scr_org_refr_id |




