## NHNCK — Hệ thống Quản lý giám sát người hành nghề chứng khoán

### Các mô hình quan hệ dữ liệu

![Mô hình quan hệ dữ liệu NHNCK](NHNCK/fragments/NHNCK_diagram.png)

**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | sp_conduct_violation | Vi phạm pháp luật hoặc hành chính của người hành nghề chứng khoán được ghi nhận kèm quyết định xử lý. Mỗi dòng = 1 sự kiện vi phạm insert-only. FK đến Practitioner và Decision. |
| 2 | sp_professional_training_class | Khóa học chuyên môn bổ sung kiến thức cho người hành nghề chứng khoán. Master entity của khóa học — ghi nhận mã, tên, loại chuyên môn, thời gian và địa điểm thi. |
| 3 | sp_professional_training_class_enrollment | Đăng ký tham gia và kết quả học tập của người hành nghề tại một khóa đào tạo chuyên môn. Ghi nhận điểm thi, kết quả đạt/không đạt và trạng thái ghi danh. |
| 4 | sp_qualification_examination_assessment | Đợt thi sát hạch cấp CCHN do UBCKNN tổ chức. Ghi nhận thời gian đăng ký và thi, địa điểm, hình thức nộp hồ sơ, quyết định công nhận kết quả và phí thi. |
| 5 | sp_qualification_examination_assessment_result | Kết quả thi sát hạch của từng thí sinh trong một đợt thi. Ghi nhận điểm thi luật, điểm chuyên môn, kết quả từng phần và kết quả tổng thể. FK đến Exam Assessment và Practitioner. |
| 6 | sp_qualification_examination_assessment_fee | Biểu phí thi sát hạch quy định cho từng loại CCHN trong từng đợt thi (Condition). Phân biệt với License Application Fee là phí thực tế thu từng hồ sơ (Transaction). |
| 7 | sp_license_application | Hồ sơ đăng ký chứng chỉ hành nghề chứng khoán. Ghi nhận loại đăng ký, loại hồ sơ, trạng thái, ngày nộp, CCHN liên quan và kết quả thi. FK đến Practitioner và Officer phụ trách. |
| 8 | sp_license_application_education_certificate_document | Chứng chỉ hoặc bằng chuyên môn đào tạo đính kèm trong hồ sơ đăng ký CCHN. Ghi nhận loại chuyên môn, file đính kèm, trạng thái thẩm định và cán bộ thẩm định. |
| 9 | sp_license_application_re_exam_request | Liên kết theo dõi chu trình thi lại — hồ sơ gốc, kết quả thi trượt và hồ sơ đăng ký thi lại mới (nullable nếu chưa nộp). FK đến License Application (×2) và Exam Assessment Result. |
| 10 | sp_license_certificate_document | Chứng chỉ hành nghề chứng khoán được cấp cho người hành nghề. Ghi nhận số CCHN, loại, ngày cấp, trạng thái và 3 quyết định liên quan (cấp/thu hồi/hủy). FK đến Practitioner. |
| 11 | sp_license_certificate_type | Danh mục loại chứng chỉ hành nghề chứng khoán — tên CCHN, mô tả, số ngày xử lý, thứ tự hiển thị. FK target cho Certificate Type Id ở các entity License Application/Certificate Document/Organization Employment Report và cross-source từ IAM User (Practice Certificate Type Id). |
| 12 | sp_license_decision_document | Quyết định hành chính do UBCKNN ban hành liên quan đến CCHN — cấp, thu hồi, hủy CCHN hoặc công nhận kết quả thi. Ghi nhận số quyết định, loại, ngày ký và người ký. |
| 13 | sp_organization_employment_report | Báo cáo của tổ chức về tình trạng làm việc của người hành nghề. Mỗi dòng = 1 lần nộp báo cáo insert-only. Ghi nhận loại báo cáo, trạng thái làm việc, chức vụ và ngày báo cáo. |
| 14 | ra_organization_unit | Đơn vị và phòng ban thuộc UBCKNN — cấu trúc cây self-referencing DEPARTMENT → UNIT. Phân biệt bằng Organization Unit Type Code (ETL-derived). Dùng chung làm FK tổ chức nội bộ. |
| 15 | securities_organization_reference | Tổ chức tham gia thị trường chứng khoán được UBCKNN quản lý (CTCK, QLQ, Ngân hàng, v.v.). Ghi nhận mã tổ chức, tên, loại hình, vốn điều lệ và trạng thái hoạt động. |
| 16 | securities_practitioner | Người hành nghề chứng khoán được UBCKNN quản lý. Ghi nhận thông tin nhân thân và trạng thái hành nghề. |
| 17 | sp_employment_status | Giai đoạn làm việc của người hành nghề tại một tổ chức chứng khoán. Ghi nhận tổ chức, chức vụ, phòng ban, ngày bắt đầu và ngày kết thúc (NULL = đang làm việc). |
| 18 | sp_reason_change_history | Ghi nhận 1 lần thay đổi thông tin cá nhân của người hành nghề — ai bị thay đổi, khi nào, lý do gì. Giữ concept Involved Party (cùng nhóm với Securities Practitioner) theo quyết định Data Modeler. |
| 19 | sp_related_party | Quan hệ thân nhân của người hành nghề chứng khoán. Ghi nhận loại quan hệ, họ tên, năm sinh, địa chỉ, nghề nghiệp và số giấy tờ định danh của người thân. |
| 20 | sp_license_application_fee | Phí thực tế phát sinh cho hồ sơ đăng ký CCHN — phí nộp hồ sơ, phí cấp CCHN (Transaction). Có lifecycle riêng qua trạng thái thanh toán. Phân biệt với Examination Assessment Fee (Condition). |
| 21 | cl_application_status |  |
| 22 | cl_document |  |
| 23 | cl_specialization |  |
| 24 | individual |  |
| 25 | sp_license_certificate_status_change_history |  |
| 26 | sp_post_certification_training_course |  |
| 27 | sp_post_certification_training_result |  |
| 28 | ip_alternative_identification | Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn. |
| 29 | ip_electronic_address | Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn. |
| 30 | ip_postal_address | Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn. |




### Bảng sp_conduct_violation



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | sp_conduct_violation_id | STRING |  | X | P |  | Khóa đại diện cho bản ghi vi phạm đạo đức hành nghề (surrogate key). |
| 2 | sp_conduct_violation_code | STRING |  |  |  |  | Mã định danh kỹ thuật tự tăng. BK của entity. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.VIOLATIONS' | Mã hệ thống nguồn. |
| 4 | sp_id | STRING |  |  | F |  | FK đến người hành nghề chứng khoán bị vi phạm. |
| 5 | sp_code | STRING |  |  |  |  | Mã người hành nghề chứng khoán bị vi phạm. |
| 6 | sp_license_decision_document_id | STRING | X |  | F |  | FK đến quyết định xử lý vi phạm. |
| 7 | sp_license_decision_document_code | STRING | X |  |  |  | Mã quyết định xử lý vi phạm. |
| 8 | practitioner_nm_at_violation | STRING | X |  |  |  | Họ tên người hành nghề tại thời điểm vi phạm (snapshot). |
| 9 | practitioner_birth_dt_at_violation | DATE | X |  |  |  | Ngày sinh người hành nghề tại thời điểm vi phạm (snapshot). |
| 10 | practitioner_identity_nbr_at_violation | STRING | X |  |  |  | Số CMND/CCCD người hành nghề tại thời điểm vi phạm (snapshot). |
| 11 | violation_record_dt | TIMESTAMP |  |  |  |  | Ngày ghi nhận vi phạm (business event date). |
| 12 | note | STRING | X |  |  |  | Ghi chú vi phạm. |
| 13 | violation_status_code | STRING |  |  |  |  | Trạng thái bản ghi vi phạm: 1=Đang hoạt động/Hiệu lực, 0=Không hoạt động. |
| 14 | violation_tp_code | STRING | X |  |  |  | Loại/phân loại của bản ghi vi phạm. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| sp_conduct_violation_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| sp_id | securities_practitioner | sp_id |
| sp_license_decision_document_id | sp_license_decision_document | sp_license_decision_document_id |



#### Index

N/A

#### Trigger

N/A




### Bảng sp_professional_training_class



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | sp_professional_training_class_id | STRING |  | X | P |  | Surrogate key cho khóa học chuyên môn |
| 2 | sp_professional_training_class_code | STRING |  |  |  |  | Mã khóa học (business key) |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.SPECIALIZATION_COURSES' | Mã hệ thống nguồn |
| 4 | training_class_nm | STRING | X |  |  |  | Tên khóa học |
| 5 | academic_year | INT | X |  |  |  | Năm học |
| 6 | specialization_tp_code | STRING | X |  | F |  | Loại chuyên môn của khóa học |
| 7 | exam_start_dt | DATE | X |  |  |  | Ngày bắt đầu thi |
| 8 | exam_end_dt | DATE | X |  |  |  | Ngày kết thúc thi |
| 9 | exam_location_adr | STRING | X |  |  |  | Địa điểm tổ chức thi |
| 10 | province_id | STRING | X |  | F |  | FK đến tỉnh/thành nơi tổ chức thi |
| 11 | province_code | STRING | X |  |  |  | Mã tỉnh/thành nơi tổ chức thi (lookup pair) |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| sp_professional_training_class_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng sp_professional_training_class_enrollment



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | sp_professional_training_class_enrollment_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | sp_professional_training_class_enrollment_code | STRING |  |  |  |  | Mã định danh (BK từ PK nguồn) |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.SPECIALIZATION_COURSE_DETAILS' | Mã nguồn dữ liệu |
| 4 | sp_professional_training_class_id | STRING |  |  | F |  | FK đến lớp đào tạo nghiệp vụ chứng khoán |
| 5 | sp_professional_training_class_code | STRING |  |  |  |  | Mã lớp đào tạo |
| 6 | sp_id | STRING |  |  | F |  | FK đến người hành nghề chứng khoán |
| 7 | sp_code | STRING |  |  |  |  | Mã người hành nghề |
| 8 | specialization_tp_code | STRING |  |  |  |  | Loại chuyên ngành đào tạo |
| 9 | exam_nbr | STRING | X |  |  |  | Số báo danh dự thi |
| 10 | practitioner_nm_at_enrollment | STRING | X |  |  |  | Họ tên học viên tại thời điểm đăng ký (snapshot) |
| 11 | practitioner_birth_dt_at_enrollment | DATE | X |  |  |  | Ngày sinh tại thời điểm đăng ký (snapshot) |
| 12 | place_of_birth | STRING | X |  |  |  | Nơi sinh (snapshot) |
| 13 | permanent_residence_country_id | STRING | X |  | F |  | FK đến quốc gia thường trú (snapshot) |
| 14 | permanent_residence_country_code | STRING | X |  |  |  | Mã quốc gia thường trú |
| 15 | permanent_residence_province_id | STRING | X |  | F |  | FK đến tỉnh/thành thường trú (snapshot) |
| 16 | permanent_residence_province_code | STRING | X |  |  |  | Mã tỉnh/thành thường trú |
| 17 | permanent_residence_district_id | STRING | X |  | F |  | FK đến quận/huyện thường trú (snapshot) |
| 18 | permanent_residence_district_code | STRING | X |  |  |  | Mã quận/huyện thường trú |
| 19 | practitioner_identity_tp_code_at_enrollment | STRING | X |  |  |  | Loại giấy tờ định danh tại thời điểm đăng ký (snapshot) |
| 20 | practitioner_identity_nbr_at_enrollment | STRING | X |  |  |  | Số định danh tại thời điểm đăng ký (snapshot) |
| 21 | practitioner_identity_issue_dt_at_enrollment | DATE | X |  |  |  | Ngày cấp giấy tờ định danh (snapshot) |
| 22 | practitioner_identity_issue_place_at_enrollment | STRING | X |  |  |  | Nơi cấp giấy tờ định danh (snapshot) |
| 23 | exam_score | DECIMAL(5,2) | X |  |  |  | Điểm thi |
| 24 | training_result_code | STRING | X |  |  |  | Kết quả đào tạo (-1=Không thi, 0=Không đạt, 1=Đạt) |
| 25 | description | STRING | X |  |  |  | Mô tả |
| 26 | note | STRING | X |  |  |  | Ghi chú |
| 27 | assignee_officer_id | STRING | X |  | F |  | FK đến cán bộ phụ trách (nullable) |
| 28 | assignee_officer_code | STRING | X |  |  |  | Mã cán bộ phụ trách |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| sp_professional_training_class_enrollment_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| sp_id | securities_practitioner | sp_id |



#### Index

N/A

#### Trigger

N/A




### Bảng sp_qualification_examination_assessment



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | sp_qualification_examination_assessment_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | sp_qualification_examination_assessment_code | STRING |  |  |  |  | Mã định danh nghiệp vụ đợt thi. BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.EXAM_SESSIONS' | Mã hệ thống nguồn |
| 4 | assessment_nm | STRING | X |  |  |  | Tên hiển thị đợt thi |
| 5 | rpt_year | INT | X |  |  |  | Năm báo cáo (YYYY) |
| 6 | examination_session_nbr | INT | X |  |  |  | Kỳ thi trong năm (1, 2…) |
| 7 | organizing_unit_nm | STRING | X |  |  |  | Tên đơn vị tổ chức thi |
| 8 | application_registration_start_dt | STRING | X |  |  |  | Ngày bắt đầu nhận đăng ký |
| 9 | application_registration_end_dt | STRING | X |  |  |  | Ngày kết thúc nhận đăng ký |
| 10 | examination_start_dt | STRING | X |  |  |  | Ngày bắt đầu thi |
| 11 | examination_end_dt | STRING | X |  |  |  | Ngày kết thúc thi |
| 12 | result_notification_dt | STRING | X |  |  |  | Ngày thông báo kết quả thi |
| 13 | examination_locations | STRING | X |  |  |  | Địa điểm tổ chức thi |
| 14 | submission_methods | STRING | X |  |  |  | Phương thức nộp hồ sơ |
| 15 | notification_file_path | STRING | X |  |  |  | Đường dẫn file thông báo kết quả |
| 16 | sp_license_decision_document_id | STRING | X |  | F |  | FK đến quyết định cấp chứng chỉ liên quan đợt thi |
| 17 | sp_license_decision_document_code | STRING | X |  |  |  | Mã quyết định cấp chứng chỉ |
| 18 | bank_code | STRING | X |  |  |  | Mã ngân hàng thu phí |
| 19 | bank_account_nbr | STRING | X |  |  |  | Số tài khoản ngân hàng thu phí |
| 20 | bank_account_nm | STRING | X |  |  |  | Tên chủ tài khoản ngân hàng thu phí |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| sp_qualification_examination_assessment_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| sp_license_decision_document_id | sp_license_decision_document | sp_license_decision_document_id |



#### Index

N/A

#### Trigger

N/A




### Bảng sp_qualification_examination_assessment_result



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | sp_qualification_examination_assessment_result_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | sp_qualification_examination_assessment_result_code | STRING |  |  |  |  | Mã định danh nghiệp vụ. BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.EXAM_DETAILS' | Mã nguồn dữ liệu |
| 4 | sp_qualification_examination_assessment_id | STRING |  |  | F |  | FK đến đợt thi sát hạch |
| 5 | sp_qualification_examination_assessment_code | STRING |  |  |  |  | Mã đợt thi sát hạch |
| 6 | sp_id | STRING |  |  | F |  | FK đến người hành nghề |
| 7 | sp_code | STRING |  |  |  |  | Mã người hành nghề |
| 8 | sp_license_certificate_tp_id | STRING |  |  | F |  | FK đến loại chứng chỉ dự thi |
| 9 | sp_license_certificate_tp_code | STRING |  |  |  |  | Mã loại chứng chỉ dự thi (denormalized lookup) |
| 10 | sp_license_application_id | STRING | X |  | F |  | FK đến hồ sơ đăng ký |
| 11 | sp_license_application_code | STRING | X |  |  |  | Mã hồ sơ đăng ký |
| 12 | sequence_nbr | INT | X |  |  |  | Số thứ tự dự thi trong đợt thi |
| 13 | exam_nbr | STRING | X |  |  |  | Số báo danh |
| 14 | law_score | INT | X |  |  |  | Điểm thi pháp luật |
| 15 | law_result_code | STRING | X |  |  |  | Kết quả thi pháp luật (-1: Không thi, 0: Không đạt, 1: Đạt) |
| 16 | specialization_score | INT | X |  |  |  | Điểm thi chuyên ngành |
| 17 | specialization_result_code | STRING | X |  |  |  | Kết quả thi chuyên ngành (-1: Không thi, 0: Không đạt, 1: Đạt) |
| 18 | overall_result_code | STRING | X |  |  |  | Kết quả thi tổng thể (-1: Không thi, 0: Không đạt, 1: Đạt) |
| 19 | examination_note | STRING | X |  |  |  | Ghi chú |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| sp_qualification_examination_assessment_result_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| sp_id | securities_practitioner | sp_id |



#### Index

N/A

#### Trigger

N/A




### Bảng sp_qualification_examination_assessment_fee



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | sp_qualification_examination_assessment_fee_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | sp_qualification_examination_assessment_fee_code | STRING |  |  |  |  | Mã định danh (tự động tăng). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.EXAM_SESSION_FEES' | Mã nguồn dữ liệu |
| 4 | sp_qualification_examination_assessment_id | STRING |  |  | F |  | FK đến đợt thi (Exam Assessment) |
| 5 | sp_qualification_examination_assessment_code | STRING |  |  |  |  | Mã đợt thi |
| 6 | sp_license_certificate_tp_id | STRING |  |  | F |  | FK đến loại chứng chỉ |
| 7 | sp_license_certificate_tp_code | STRING |  |  |  |  | Mã loại chứng chỉ (denormalized lookup) |
| 8 | examination_fee_amt | DECIMAL(23,2) | X |  |  |  | Mức phí dự thi (VNĐ) |
| 9 | appeal_fee_amt | DECIMAL(23,2) | X |  |  |  | Mức phí phúc khảo (VNĐ) |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| sp_qualification_examination_assessment_fee_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| sp_qualification_examination_assessment_id | sp_qualification_examination_assessment | sp_qualification_examination_assessment_id |



#### Index

N/A

#### Trigger

N/A




### Bảng sp_license_application



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | sp_license_application_id | STRING |  | X | P |  | Id tự sinh (surrogate key). |
| 2 | sp_license_application_code | STRING |  |  |  |  | Mã hồ sơ đăng ký do hệ thống sinh — BK của entity. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.APPLICATIONS' | Mã hệ thống nguồn. |
| 4 | application_tp_code | STRING |  |  |  |  | Loại hồ sơ. |
| 5 | cl_application_status_id | STRING |  |  | F |  | FK đến trạng thái hồ sơ hiện tại. |
| 6 | cl_application_status_code | STRING |  |  |  |  | Mã trạng thái hồ sơ hiện tại (denormalized lookup). |
| 7 | registration_tp_code | STRING |  |  |  |  | Nguồn tiếp nhận hồ sơ. |
| 8 | sp_license_certificate_tp_id | STRING |  |  | F |  | FK đến loại chứng chỉ hành nghề đăng ký. |
| 9 | sp_license_certificate_tp_code | STRING |  |  |  |  | Mã loại chứng chỉ hành nghề đăng ký (denormalized lookup) |
| 10 | title | STRING | X |  |  |  | Tiêu đề hoặc tên nhóm hồ sơ. |
| 11 | submission_dt | DATE | X |  |  |  | Ngày nộp hồ sơ chính thức. |
| 12 | supplement_dt | DATE | X |  |  |  | Ngày nộp bổ sung hồ sơ. |
| 13 | supplement_letter_dt | DATE | X |  |  |  | Ngày ban hành công văn yêu cầu bổ sung hồ sơ. |
| 14 | certificate_nbr | STRING | X |  |  |  | Số CCHN cấp cho người hành nghề. |
| 15 | issue_dt | DATE | X |  |  |  | Ngày cấp CCHN. |
| 16 | previous_certificate_nbr | STRING | X |  |  |  | Số CCHN cũ trước khi cấp lại. |
| 17 | previous_issue_dt | DATE | X |  |  |  | Ngày cấp CCHN cũ. |
| 18 | previous_sp_license_certificate_tp_id | STRING | X |  | F |  | FK đến loại CCHN cũ khi cấp lại. |
| 19 | previous_sp_license_certificate_tp_code | STRING | X |  |  |  | Mã loại CCHN cũ khi cấp lại (denormalized lookup) |
| 20 | reissue_reason | STRING | X |  |  |  | Lý do xin cấp lại CCHN. |
| 21 | rejection_reason | STRING | X |  |  |  | Lý do trả lại hoặc từ chối hồ sơ. |
| 22 | certificate_receipt_method_code | STRING | X |  |  |  | Phương thức nhận CCHN. |
| 23 | certificate_receipt_adr | STRING | X |  |  |  | Địa chỉ nhận CCHN qua bưu điện. |
| 24 | certificate_receipt_phone | STRING | X |  |  |  | Số điện thoại liên lạc khi nhận CCHN. |
| 25 | receipt_status_code | STRING | X |  |  |  | Trạng thái nhận CCHN. |
| 26 | violated_ind | INT | X |  |  |  | Cờ người hành nghề vi phạm quy định. |
| 27 | data_exploitable_ind | INT | X |  |  |  | Cờ dữ liệu có thể khai thác. |
| 28 | reissue_hsm | STRING | X |  |  |  | Thông tin HSM khi cấp CCHN điện tử. |
| 29 | note | STRING | X |  |  |  | Ghi chú bổ sung. |
| 30 | sp_id | STRING |  |  | F |  | FK đến Securities Practitioner. |
| 31 | sp_code | STRING |  |  |  |  | Mã người hành nghề. |
| 32 | sp_license_certificate_document_id | STRING | X |  | F |  | FK đến License Certificate Document (CCHN trong sổ đăng bộ). |
| 33 | sp_license_certificate_document_code | STRING | X |  |  |  | Mã CCHN trong sổ đăng bộ. |
| 34 | previous_sp_license_certificate_document_id | STRING | X |  | F |  | FK đến CCHN cũ (khi cấp lại). |
| 35 | previous_sp_license_certificate_document_code | STRING | X |  |  |  | Mã CCHN cũ. |
| 36 | sp_qualification_examination_assessment_id | STRING | X |  | F |  | FK đến Exam Session (đợt thi sát hạch liên quan — nullable). |
| 37 | sp_qualification_examination_assessment_code | STRING | X |  |  |  | Mã đợt thi sát hạch. |
| 38 | assignee_officer_id | STRING | X |  | F |  | FK đến Regulatory Authority Officer — cán bộ được phân công xử lý hồ sơ. |
| 39 | assignee_officer_code | STRING | X |  |  |  | Mã cán bộ được phân công. |
| 40 | info_verify_officer_id | STRING | X |  | F |  | FK đến Regulatory Authority Officer — cán bộ xác minh thông tin. |
| 41 | info_verify_officer_code | STRING | X |  |  |  | Mã cán bộ xác minh thông tin. |
| 42 | public_service_portal_content_item_code | STRING | X |  |  |  | ContentItemId hồ sơ TTHC trên DVC (MCĐT). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| sp_license_application_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| sp_id | securities_practitioner | sp_id |
| sp_license_certificate_document_id | sp_license_certificate_document | sp_license_certificate_document_id |
| previous_sp_license_certificate_document_id | sp_license_certificate_document | sp_license_certificate_document_id |
| sp_qualification_examination_assessment_id | sp_qualification_examination_assessment | sp_qualification_examination_assessment_id |



#### Index

N/A

#### Trigger

N/A




### Bảng sp_license_application_education_certificate_document



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | sp_license_application_education_certificate_document_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | sp_license_application_education_certificate_document_code | STRING |  |  |  |  | Mã định danh bản ghi chuyên môn. BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.APPLICATION_SPECIALIZATIONS' | Mã hệ thống nguồn (ETL-derived) |
| 4 | sp_license_application_id | STRING |  |  | F |  | FK đến License Application (hồ sơ đăng ký) |
| 5 | sp_license_application_code | STRING |  |  |  |  | Mã hồ sơ đăng ký. Lookup pair |
| 6 | cl_specialization_id | STRING |  |  | F |  | FK đến chuyên ngành CCHN đăng ký |
| 7 | cl_specialization_code | STRING |  |  |  |  | Mã chuyên ngành CCHN đăng ký (denormalized lookup) |
| 8 | certificate_issue_dt | DATE | X |  |  |  | Ngày cấp chứng chỉ chuyên môn |
| 9 | certificate_issue_place | STRING | X |  |  |  | Nơi cấp chứng chỉ chuyên môn |
| 10 | appraisal_completed_dt | TIMESTAMP | X |  |  |  | Thời điểm thẩm định hoàn tất |
| 11 | appraised_by_officer_id | STRING | X |  | F |  | FK đến cán bộ thẩm định (Regulatory Authority Officer) |
| 12 | appraised_by_officer_code | STRING | X |  |  |  | Mã cán bộ thẩm định. Lookup pair |
| 13 | attachment_files | STRING | X |  |  |  | Danh sách file đính kèm (JSON CLOB) |
| 14 | note | STRING | X |  |  |  | Ghi chú bổ sung |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| sp_license_application_education_certificate_document_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng sp_license_application_re_exam_request



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | sp_license_application_re_exam_request_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | sp_license_application_re_exam_request_code | STRING |  |  |  |  | Mã định danh. BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.APPLICATION_RE_EXAMS' | Mã nguồn dữ liệu |
| 4 | sp_license_application_id | STRING |  |  | F |  | FK đến hồ sơ gốc đã thi trượt |
| 5 | sp_license_application_code | STRING |  |  |  |  | Mã hồ sơ gốc |
| 6 | sp_qualification_examination_assessment_result_id | STRING |  |  | F |  | FK đến kết quả thi trượt |
| 7 | sp_qualification_examination_assessment_result_code | STRING |  |  |  |  | Mã kết quả thi trượt |
| 8 | re_exam_sp_license_application_id | STRING | X |  | F |  | FK đến hồ sơ thi lại mới (nullable — chưa nộp) |
| 9 | re_exam_sp_license_application_code | STRING | X |  |  |  | Mã hồ sơ thi lại mới |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| sp_license_application_re_exam_request_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| sp_qualification_examination_assessment_result_id | sp_qualification_examination_assessment_result | sp_qualification_examination_assessment_result_id |



#### Index

N/A

#### Trigger

N/A




### Bảng sp_license_certificate_document



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | sp_license_certificate_document_id | STRING |  | X | P |  | Surrogate key cho chứng chỉ hành nghề chứng khoán |
| 2 | sp_license_certificate_document_code | STRING |  |  |  |  | Business key từ CERTIFICATE_RECORDS.ID |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.CERTIFICATE_RECORDS' | Mã hệ thống nguồn ETL-derived |
| 4 | certificate_nbr | STRING |  |  |  |  | Số chứng chỉ hành nghề |
| 5 | sp_license_certificate_tp_id | STRING |  |  | F |  | FK đến loại chứng chỉ hành nghề (CCHN) |
| 6 | sp_license_certificate_tp_code | STRING |  |  |  |  | Mã loại chứng chỉ (denormalized lookup) |
| 7 | sp_id | STRING |  |  | F |  | FK đến Securities Practitioner |
| 8 | sp_code | STRING |  |  |  |  | Mã nghiệp vụ của người hành nghề |
| 9 | issue_sp_license_decision_document_id | STRING |  |  | F |  | FK đến quyết định cấp chứng chỉ |
| 10 | issue_sp_license_decision_document_code | STRING |  |  |  |  | Mã nghiệp vụ của quyết định cấp |
| 11 | revocation_sp_license_decision_document_id | STRING | X |  | F |  | FK đến quyết định thu hồi chứng chỉ |
| 12 | revocation_sp_license_decision_document_code | STRING | X |  |  |  | Mã nghiệp vụ của quyết định thu hồi |
| 13 | cancellation_sp_license_decision_document_id | STRING | X |  | F |  | FK đến quyết định hủy chứng chỉ |
| 14 | cancellation_sp_license_decision_document_code | STRING | X |  |  |  | Mã nghiệp vụ của quyết định hủy |
| 15 | issue_dt | DATE |  |  |  |  | Ngày cấp chứng chỉ hành nghề |
| 16 | revocation_dt | DATE | X |  |  |  | Ngày thu hồi chứng chỉ hành nghề |
| 17 | revocation_reason | STRING | X |  |  |  | Lý do thu hồi chứng chỉ hành nghề |
| 18 | practitioner_nm_at_issuance | STRING | X |  |  |  | Tên người hành nghề tại thời điểm cấp chứng chỉ (snapshot) |
| 19 | reissuance_allowed_count | INT |  |  |  |  | Số lần được phép cấp lại chứng chỉ (0 = không được cấp lại) |
| 20 | process_status_code | STRING |  |  |  |  | Trạng thái xử lý chứng chỉ (1=Đã cấp 2=Đã ký nháy 3=Đã ký 4=Đã trả) |
| 21 | certificate_file_path | STRING | X |  |  |  | Đường dẫn file chứng chỉ số |
| 22 | conversion_status_code | STRING |  |  |  |  | Trạng thái chuyển đổi chứng chỉ (1=Giấy 2=Chờ điện tử 3=Chứng chỉ số) |
| 23 | description | STRING | X |  |  |  | Mô tả bổ sung cho chứng chỉ hành nghề |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| sp_license_certificate_document_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| sp_id | securities_practitioner | sp_id |
| issue_sp_license_decision_document_id | sp_license_decision_document | sp_license_decision_document_id |
| revocation_sp_license_decision_document_id | sp_license_decision_document | sp_license_decision_document_id |
| cancellation_sp_license_decision_document_id | sp_license_decision_document | sp_license_decision_document_id |



#### Index

N/A

#### Trigger

N/A




### Bảng sp_license_certificate_type



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | sp_license_certificate_tp_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | sp_license_certificate_tp_code | STRING |  |  |  |  | Mã định danh nghiệp vụ duy nhất của loại chứng chỉ (VD: MGCK, PTTC, QLQ). BK duy nhất — Id hash từ trường này. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.CERTIFICATES' | Mã nguồn dữ liệu |
| 4 | certificate_tp_nm | STRING | X |  |  |  | Tên loại chứng chỉ hành nghề (VD: Quản lý quỹ, Phân tích đầu tư, Môi giới CK) |
| 5 | description | STRING | X |  |  |  | Mô tả chi tiết |
| 6 | processing_days | INT | X |  |  |  | Số ngày làm việc xử lý hồ sơ theo quy định |
| 7 | sort_order | INT | X |  |  |  | Thứ tự sắp xếp hiển thị (số nhỏ hơn hiển thị trước) |
| 8 | displayed_ind | STRING | X |  |  |  | Cờ hiển thị trên giao diện người dùng: 1=Hiển thị, 0=Ẩn |
| 9 | original_data_ind | STRING | X |  |  |  | Cờ dữ liệu gốc của hệ thống (không được xóa): 1=Dữ liệu gốc, 0=Người dùng tạo |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| sp_license_certificate_tp_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng sp_license_decision_document



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | sp_license_decision_document_id | STRING |  | X | P |  | Surrogate key cho quyết định hành chính |
| 2 | sp_license_decision_document_code | STRING |  |  |  |  | Business key từ PK nguồn DECISIONS.ID |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.DECISIONS' | Mã hệ thống nguồn của bản ghi |
| 4 | decision_nbr | STRING | X |  |  |  | Số hiệu quyết định hành chính (VD: 123/QĐ-UBCK) |
| 5 | decision_title | STRING | X |  |  |  | Tiêu đề/tên quyết định hành chính |
| 6 | legal_reference | STRING | X |  |  |  | Căn cứ pháp lý của quyết định |
| 7 | decision_content | STRING | X |  |  |  | Nội dung đầy đủ của quyết định |
| 8 | decision_signed_dt | DATE | X |  |  |  | Ngày ký ban hành quyết định |
| 9 | signatory_nm | STRING | X |  |  |  | Họ tên người ký quyết định |
| 10 | signatory_position | STRING | X |  |  |  | Chức vụ của người ký quyết định |
| 11 | issuing_organization_nm | STRING | X |  |  |  | Tên đơn vị ban hành quyết định (VD: Ủy ban Chứng khoán Nhà nước) |
| 12 | attachment_file_nm | STRING | X |  |  |  | Tên file văn bản đính kèm |
| 13 | attachment_file_path | STRING | X |  |  |  | Đường dẫn lưu trữ file đính kèm |
| 14 | decision_tp_code | STRING |  |  |  |  | Loại quyết định hành chính (Cấp mới / Thu hồi / Cấp lại / ...) |
| 15 | notification_content | STRING | X |  |  |  | Nội dung thông báo hoặc yêu cầu bổ sung hồ sơ kèm theo |
| 16 | active_flag | INT |  |  |  |  | Cờ đánh dấu quyết định đang được sử dụng (1=Đang dùng; 0=Vô hiệu) |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| sp_license_decision_document_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng sp_organization_employment_report



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | sp_organization_employment_rpt_id | STRING |  | X | P |  | Khóa đại diện cho báo cáo danh sách NHNCK tại tổ chức (surrogate key). |
| 2 | sp_organization_employment_rpt_code | STRING |  |  |  |  | Mã định danh kỹ thuật (BK). Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.ORGANIZATION_REPORTS' | Mã hệ thống nguồn. |
| 4 | data_dt | DATE |  |  |  |  | Thời điểm tạo bản ghi (nguồn: CREATED_AT). Dùng làm căn cứ partition Delta Lake / incremental filter — bảng nguồn có data_change_mode=Append, filter_logic theo created_at (xem BRD/Source/brd_NHNCK.yaml). |
| 5 | securities_organization_reference_id | STRING |  |  | F |  | FK đến tổ chức kinh doanh chứng khoán. |
| 6 | securities_organization_reference_code | STRING |  |  |  |  | Mã tổ chức (denormalized). |
| 7 | sp_id | STRING |  |  | F |  | FK đến người hành nghề chứng khoán. |
| 8 | sp_code | STRING |  |  |  |  | Mã người hành nghề (denormalized). |
| 9 | sp_license_certificate_document_id | STRING | X |  | F |  | FK đến hồ sơ chứng chỉ hành nghề (nullable). |
| 10 | sp_license_certificate_document_code | STRING | X |  |  |  | Mã hồ sơ chứng chỉ hành nghề (denormalized). |
| 11 | sp_license_certificate_tp_id | STRING | X |  | F |  | FK đến loại chứng chỉ hành nghề tại thời điểm báo cáo. |
| 12 | sp_license_certificate_tp_code | STRING | X |  |  |  | Mã loại chứng chỉ hành nghề tại thời điểm báo cáo (denormalized lookup) |
| 13 | parent_sp_organization_employment_rpt_id | STRING | X |  | F |  | FK self-ref — báo cáo gốc được điều chỉnh (nullable). |
| 14 | parent_sp_organization_employment_rpt_code | STRING | X |  |  |  | Mã báo cáo gốc (denormalized). |
| 15 | practitioner_nm_at_rpt | STRING | X |  |  |  | Họ và tên người hành nghề tại thời điểm lập báo cáo (snapshot). |
| 16 | practitioner_birth_dt_at_rpt | DATE | X |  |  |  | Ngày sinh người hành nghề tại thời điểm lập báo cáo (snapshot). |
| 17 | practitioner_identity_nbr_at_rpt | STRING | X |  |  |  | Số định danh cá nhân tại thời điểm lập báo cáo (snapshot). |
| 18 | practitioner_position_at_rpt | STRING | X |  |  |  | Chức vụ của người hành nghề tại tổ chức (snapshot). |
| 19 | practitioner_department_at_rpt | STRING | X |  |  |  | Phòng ban của người hành nghề tại tổ chức (snapshot). |
| 20 | practitioner_workplace_at_rpt | STRING | X |  |  |  | Nơi làm việc của người hành nghề tại thời điểm báo cáo (snapshot). |
| 21 | certificate_nbr_at_rpt | STRING | X |  |  |  | Số chứng chỉ hành nghề tại thời điểm lập báo cáo (snapshot). |
| 22 | certificate_issue_dt_at_rpt | DATE | X |  |  |  | Ngày cấp chứng chỉ hành nghề tại thời điểm lập báo cáo (snapshot). |
| 23 | hire_dt | DATE | X |  |  |  | Ngày tuyển dụng vào tổ chức. |
| 24 | termination_dt | DATE | X |  |  |  | Ngày chấm dứt hợp đồng lao động (NULL = đang làm việc). |
| 25 | rpt_dt | DATE | X |  |  |  | Ngày lập báo cáo. |
| 26 | disciplines | STRING | X |  |  |  | Kỷ luật của người hành nghề tại tổ chức. |
| 27 | description | STRING | X |  |  |  | Mô tả bổ sung cho báo cáo. |
| 28 | notes | STRING | X |  |  |  | Ghi chú nội bộ. |
| 29 | business_department_nm | STRING | X |  | F |  | Tên phòng nghiệp vụ UBCKNN phụ trách (denormalized text). |
| 30 | rpt_file_path | STRING | X |  |  |  | Đường dẫn file báo cáo đính kèm. |
| 31 | termination_file_path | STRING | X |  |  |  | Đường dẫn file chấm dứt hợp đồng đính kèm. |
| 32 | external_sync_id | STRING | X |  |  |  | Mã đồng bộ từ hệ thống ngoài (FMS/SCMS). |
| 33 | organization_status_code_at_rpt | STRING | X |  |  |  | Trạng thái tổ chức tại thời điểm lập báo cáo. |
| 34 | sync_created_tms | TIMESTAMP | X |  |  |  | Thời điểm tạo bản ghi tại hệ thống đồng bộ nguồn. |
| 35 | sync_updated_tms | TIMESTAMP | X |  |  |  | Thời điểm cập nhật bản ghi tại hệ thống đồng bộ nguồn. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| sp_organization_employment_rpt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| sp_id | securities_practitioner | sp_id |
| sp_license_certificate_document_id | sp_license_certificate_document | sp_license_certificate_document_id |
| parent_sp_organization_employment_rpt_id | sp_organization_employment_report | sp_organization_employment_rpt_id |



#### Index

N/A

#### Trigger

N/A




### Bảng ra_organization_unit



#### Từ NHNCK.UNITS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ra_ou_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | ra_ou_code | STRING |  |  |  |  | Mã đơn vị nội bộ UBCKNN. BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.UNITS' | Mã hệ thống nguồn. BK |
| 4 | ou_tp_code | STRING |  |  |  | 'UNIT' | Phân loại — Đơn vị (Unit) |
| 5 | ra_ou_nm | STRING | X |  |  |  | Tên đơn vị nội bộ UBCKNN |
| 6 | hierarchy_level_code | STRING | X |  |  |  | Cấp độ trong cây phân cấp tổ chức |
| 7 | parent_ra_ou_id | STRING | X |  | F |  | FK đến đơn vị cha (self-ref) |
| 8 | parent_ra_ou_code | STRING | X |  |  |  | Mã đơn vị cha |
| 9 | description | STRING | X |  |  |  | Mô tả chi tiết đơn vị |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ra_ou_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


**Index:** N/A

**Trigger:** N/A


#### Từ NHNCK.DEPARTMENTS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ra_ou_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | ra_ou_code | STRING |  |  |  |  | Mã phòng ban. BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.DEPARTMENTS' | Mã hệ thống nguồn. BK |
| 4 | ou_tp_code | STRING |  |  |  | 'DEPARTMENT' | Phân loại — Phòng ban (Department) |
| 5 | ra_ou_nm | STRING | X |  |  |  | Tên phòng ban |
| 6 | hierarchy_level_code | STRING | X |  |  |  | Cấp độ trong cây phân cấp — null cho phòng ban |
| 7 | parent_ra_ou_id | STRING | X |  | F |  | FK đến đơn vị cha (UNITS) |
| 8 | parent_ra_ou_code | STRING | X |  |  |  | Mã đơn vị cha (UNITS) |
| 9 | description | STRING | X |  |  |  | Mô tả chi tiết phòng ban |
| 10 | sort_order | INT | X |  |  |  | Thứ tự sắp xếp phòng ban trong đơn vị |
| 11 | external_catalog_reference_code | STRING | X |  |  |  | TBD - cần bổ sung mô tả |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| ra_ou_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


**Index:** N/A

**Trigger:** N/A





### Bảng securities_organization_reference



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | securities_organization_reference_id | STRING |  | X | P |  | Khóa đại diện cho tổ chức kinh doanh chứng khoán (surrogate key). |
| 2 | securities_organization_reference_code | STRING |  |  |  |  | Mã tổ chức kinh doanh chứng khoán do hệ thống cấp. BK của entity. Map từ ORGANIZATION_CODE. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.ORGANIZATIONS' | Mã hệ thống nguồn. |
| 4 | securities_organization_reference_nm | STRING | X |  |  |  | Tên đầy đủ tổ chức. |
| 5 | securities_organization_reference_english_nm | STRING | X |  |  |  | Tên tiếng Anh của tổ chức. |
| 6 | securities_organization_reference_short_nm | STRING | X |  |  |  | Tên viết tắt của tổ chức. |
| 7 | organization_tp_code | STRING | X |  |  |  | Loại tổ chức: 0=Khác, 1=CTCK, 2=QLQ, 3=Ngân hàng. |
| 8 | organization_level_code | STRING | X |  |  |  | Cấp độ phân cấp tổ chức. |
| 9 | parent_securities_organization_reference_id | STRING | X |  | F |  | FK tự tham chiếu — tổ chức cha trong cấu trúc phân cấp. |
| 10 | parent_securities_organization_reference_code | STRING | X |  |  |  | Mã tổ chức cha. |
| 11 | external_stm_linked_id | STRING | X |  |  |  | ID liên kết sang hệ thống FMS/SCMS. |
| 12 | external_stm_sync_id | STRING | X |  |  |  | Mã đồng bộ từ FMS/SCMS. |
| 13 | legal_representative_nm | STRING | X |  |  |  | Tên người đại diện pháp luật của tổ chức. |
| 14 | license_nbr | STRING | X |  |  |  | Số giấy phép hoạt động chứng khoán. |
| 15 | license_issuer_nm | STRING | X |  |  |  | Tên cơ quan cấp giấy phép hoạt động. |
| 16 | license_dt | DATE | X |  |  |  | Ngày cấp giấy phép hoạt động. |
| 17 | charter_capital_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ của tổ chức. |
| 18 | description | STRING | X |  |  |  | Mô tả chi tiết về tổ chức. |
| 19 | sort_order | INT | X |  |  |  | Thứ tự sắp xếp hiển thị. |
| 20 | last_sync_dt | DATE | X |  |  |  | Ngày đồng bộ dữ liệu gần nhất. |
| 21 | sync_status_code | STRING | X |  |  |  | Trạng thái đồng bộ: 0=Chưa đồng bộ, 1=Đã đồng bộ, 2=Lỗi. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| securities_organization_reference_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng securities_practitioner



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | sp_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | sp_code | STRING |  |  |  |  | Mã người hành nghề. BK từ PK nguồn |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.PROFESSIONALS' | Mã nguồn dữ liệu |
| 4 | full_nm | STRING | X |  |  |  | Họ và tên đầy đủ của người hành nghề |
| 5 | given_nm | STRING | X |  |  |  | Tên đệm và tên riêng |
| 6 | birth_dt | DATE | X |  |  |  | Ngày sinh |
| 7 | birth_year | STRING | X |  |  |  | Năm sinh (lưu dạng chuỗi khi không có ngày tháng đủ) |
| 8 | gender_code | STRING | X |  |  |  | Giới tính: 0=Nam / 1=Nữ |
| 9 | education_level_code | STRING | X |  | F |  | Trình độ học vấn |
| 10 | practitioner_registration_tp_code | STRING | X |  |  |  | Hình thức đăng ký hồ sơ: 0=MCĐT/cổng DVC / 1=Nhập tay |
| 11 | practice_status_code | STRING | X |  |  |  | Trạng thái hành nghề chứng khoán |
| 12 | account_status_code | STRING | X |  |  |  | Trạng thái tài khoản người dùng trên cổng NHNCK |
| 13 | securities_organization_reference_id | STRING | X |  | F |  | FK đến tổ chức chứng khoán hiện tại (nullable) |
| 14 | securities_organization_reference_code | STRING | X |  |  |  | Mã tổ chức (denormalized lookup) |
| 15 | nationality_id | STRING | X |  | F |  | FK đến Geographic Area (quốc tịch) |
| 16 | nationality_code | STRING | X |  |  |  | Mã quốc gia/quốc tịch (denormalized) |
| 17 | workplace_nm | STRING | X |  |  |  | Nơi làm việc hiện tại (tên tổ chức — denormalized text tự do) |
| 18 | position_nm | STRING | X |  | F |  | Chức vụ hiện tại (denormalized text tự do) |
| 19 | department_nm | STRING | X |  |  |  | Phòng ban hiện tại (denormalized text tự do) |
| 20 | previous_identity_nbr | STRING | X |  |  |  | Số CMND cũ trước khi chuyển sang CCCD |
| 21 | hometown | STRING | X |  |  |  | Quê quán (dữ liệu tích hợp C06) |
| 22 | ethnicity_nm | STRING | X |  |  |  | Dân tộc (dữ liệu tích hợp C06) |
| 23 | religion_nm | STRING | X |  |  |  | Tôn giáo (dữ liệu tích hợp C06) |
| 24 | place_of_birth_description | STRING | X |  |  |  | Nơi sinh (text tự do) |
| 25 | avatar_file_path | STRING | X |  |  |  | Đường dẫn/URL ảnh đại diện của người hành nghề |
| 26 | place_of_birth_country_id | STRING | X |  | F |  | FK đến Geographic Area — quốc gia nơi sinh |
| 27 | place_of_birth_country_code | STRING | X |  |  |  | Mã quốc gia nơi sinh (denormalized) |
| 28 | place_of_birth_province_id | STRING | X |  | F |  | FK đến Geographic Area — tỉnh/thành phố nơi sinh |
| 29 | place_of_birth_province_code | STRING | X |  |  |  | Mã tỉnh/thành phố nơi sinh (denormalized) |
| 30 | place_of_birth_district_id | STRING | X |  | F |  | FK đến Geographic Area — quận/huyện nơi sinh |
| 31 | place_of_birth_district_code | STRING | X |  |  |  | Mã quận/huyện nơi sinh (denormalized) |
| 32 | sso_sync_status_code | STRING | X |  |  |  | 0=chưa chuyển SSO, 1=đã chuyển SSO |
| 33 | identity_and_access_management_user_id | STRING | X |  | F |  | UUID user trên IAM (provisioning SSO) |
| 34 | identity_and_access_management_user_code | STRING | X |  |  |  | Mã user IAM (denormalized lookup) |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| sp_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng sp_employment_status



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | sp_employment_status_id | STRING |  | X | P |  | Khóa đại diện cho bản ghi lịch sử công tác / trạng thái việc làm của người hành nghề chứng khoán (surrogate key). |
| 2 | sp_employment_status_code | STRING |  |  |  |  | Mã định danh kỹ thuật. BK của entity. Map từ PK bảng nguồn. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.PROFESSIONAL_WORK_HISTORIES' | Mã hệ thống nguồn. |
| 4 | sp_id | STRING |  |  | F |  | Surrogate key FK đến người hành nghề chứng khoán. |
| 5 | sp_code | STRING |  |  |  |  | Mã kỹ thuật của người hành nghề (dư thừa). |
| 6 | securities_organization_reference_id | STRING | X |  | F |  | Surrogate key FK đến tổ chức kinh doanh chứng khoán nơi người hành nghề làm việc. |
| 7 | securities_organization_reference_code | STRING | X |  |  |  | Mã kỹ thuật của tổ chức (dư thừa). |
| 8 | department_nm | STRING | X |  |  |  | Tên đơn vị / phòng ban trong tổ chức tại thời điểm làm việc (snapshot text). |
| 9 | workplace_nm | STRING | X |  |  |  | Tên tổ chức / nơi làm việc dạng text (có thể khác ORGANIZATION_NAME khi tổ chức đổi tên hoặc chưa có trong ORGANIZATIONS). |
| 10 | employment_start_dt | DATE |  |  |  |  | Ngày bắt đầu làm việc tại tổ chức. |
| 11 | employment_end_dt | DATE | X |  |  |  | Ngày kết thúc làm việc. Null = đang làm việc. |
| 12 | position_code | STRING | X |  | F |  | Mã chức vụ của người hành nghề tại tổ chức. |
| 13 | position_nm | STRING | X |  |  |  | Tên chức vụ snapshot tại thời điểm ghi nhận. |
| 14 | awards | STRING | X |  |  |  | Thông tin khen thưởng trong thời gian làm việc tại tổ chức. |
| 15 | disciplines | STRING | X |  |  |  | Thông tin kỷ luật trong thời gian làm việc tại tổ chức. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| sp_employment_status_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| sp_id | securities_practitioner | sp_id |



#### Index

N/A

#### Trigger

N/A




### Bảng sp_reason_change_history



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | sp_reason_change_history_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | sp_reason_change_history_code | STRING |  |  |  |  | Mã bản ghi thay đổi. BK từ PK nguồn |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.PROFESSIONAL_HISTORIES' | Mã nguồn dữ liệu |
| 4 | sp_id | STRING |  |  | F |  | FK đến người hành nghề bị thay đổi thông tin |
| 5 | sp_code | STRING |  |  |  |  | Mã người hành nghề (denormalized lookup) |
| 6 | change_dt | DATE | X |  |  |  | Ngày ghi nhận thay đổi thông tin |
| 7 | change_reason | STRING | X |  |  |  | Lý do cập nhật thông tin người hành nghề |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| sp_reason_change_history_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| sp_id | securities_practitioner | sp_id |



#### Index

N/A

#### Trigger

N/A




### Bảng sp_related_party



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | sp_related_party_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | sp_related_party_code | STRING |  |  |  |  | Mã định danh quan hệ (PK nguồn). BK |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.PROFESSIONAL_RELATIONSHIPS' | Mã hệ thống nguồn. |
| 4 | sp_id | STRING |  |  | F |  | FK đến Securities Practitioner |
| 5 | sp_code | STRING |  |  |  |  | Mã người hành nghề chứng khoán |
| 6 | rltnp_tp_code | STRING |  |  |  |  | Loại quan hệ (1: Vợ/Chồng, 2: Con, 3: Bố, 4: Mẹ, 5: Ông, 6: Bà) |
| 7 | related_individual_full_nm | STRING | X |  |  |  | Họ và tên người thân |
| 8 | related_individual_birth_year | INT | X |  |  |  | Năm sinh người thân |
| 9 | related_individual_adr | STRING | X |  |  |  | Địa chỉ người thân |
| 10 | related_individual_occupation | STRING | X |  |  |  | Nghề nghiệp người thân |
| 11 | related_individual_workplace | STRING | X |  |  |  | Nơi làm việc người thân |
| 12 | related_individual_identity_nbr | STRING | X |  |  |  | Số CMND/CCCD người thân |
| 13 | country_id | STRING | X |  | F |  | FK đến Geographic Area — quốc gia |
| 14 | country_code | STRING | X |  |  |  | Mã quốc gia |
| 15 | note | STRING | X |  |  |  | Ghi chú |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| sp_related_party_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| sp_id | securities_practitioner | sp_id |



#### Index

N/A

#### Trigger

N/A




### Bảng sp_license_application_fee



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | sp_license_application_fee_id | STRING |  | X | P |  | Surrogate primary key |
| 2 | sp_license_application_fee_code | STRING |  |  |  |  | Business key từ APPLICATION_FEES.ID |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.APPLICATION_FEES' | Mã hệ thống nguồn |
| 4 | sp_license_application_id | STRING |  |  | F |  | FK đến License Application |
| 5 | sp_license_application_code | STRING |  |  |  |  | Mã hồ sơ đăng ký (lookup pair) |
| 6 | sp_id | STRING | X |  | F |  | FK đến Securities Practitioner (redundant — derive được từ Application) |
| 7 | sp_code | STRING | X |  |  |  | Mã chuyên viên (lookup pair) |
| 8 | fee_tp_code | STRING |  |  |  |  | Loại phí: 1=Phí thi 2=Phí phúc khảo 3=Phí cấp chứng chỉ |
| 9 | fee_content | STRING | X |  |  |  | Nội dung khoản phí |
| 10 | fee_amt | DECIMAL(23,2) |  |  |  |  | Số tiền phí (VNĐ) |
| 11 | payment_request_dt | DATE |  |  |  |  | Ngày yêu cầu nộp phí |
| 12 | payment_dt | DATE | X |  |  |  | Ngày thanh toán thực tế |
| 13 | payment_expiry_dt | DATE | X |  |  |  | Ngày hết hạn thanh toán |
| 14 | payment_evidence_file_path | STRING | X |  |  |  | Đường dẫn chứng từ thanh toán |
| 15 | note | STRING | X |  |  |  | Ghi chú |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| sp_license_application_fee_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| sp_id | securities_practitioner | sp_id |



#### Index

N/A

#### Trigger

N/A




### Bảng cl_application_status



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | cl_application_status_id | STRING |  | X | P |  | Id tự sinh (surrogate key). |
| 2 | cl_application_status_code | STRING |  |  |  |  | Mã trạng thái hồ sơ — BK của entity. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.APPLICATION_STATUSES' | Mã hệ thống nguồn. |
| 4 | cl_application_status_nm | STRING |  |  |  |  | Tên trạng thái hồ sơ hiển thị trên giao diện. |
| 5 | label | STRING | X |  |  |  | Nhãn hiển thị ngắn gọn trên badge/tag. |
| 6 | description | STRING | X |  |  |  | Mô tả chi tiết trạng thái. |
| 7 | sort_order | INT | X |  |  |  | Thứ tự sắp xếp hiển thị (số nhỏ hơn hiển thị trước). |
| 8 | active_ind | STRING | X |  |  |  | Cờ đang kích hoạt/hiệu lực. |
| 9 | original_data_ind | STRING | X |  |  |  | Cờ dữ liệu gốc của hệ thống (không được xóa). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| cl_application_status_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng cl_document



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | cl_document_id | STRING |  | X | P |  | Id tự sinh (surrogate key). |
| 2 | cl_document_code | STRING |  |  |  |  | Mã tài liệu — BK của entity. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.DOCUMENTS' | Mã hệ thống nguồn. |
| 4 | cl_document_nm | STRING |  |  |  |  | Tên tài liệu. |
| 5 | legal_reference | STRING | X |  |  |  | Trích dẫn căn cứ pháp lý liên quan đến tài liệu. |
| 6 | sort_order | INT | X |  |  |  | Thứ tự sắp xếp hiển thị (số nhỏ hơn hiển thị trước). |
| 7 | active_ind | STRING | X |  |  |  | Cờ đang kích hoạt/hiệu lực. |
| 8 | original_data_ind | STRING | X |  |  |  | Cờ dữ liệu gốc của hệ thống (không được xóa). |
| 9 | public_service_portal_code | STRING | X |  |  |  | Mã đồng bộ chuyên ngành trên hệ thống Cổng Dịch vụ công quốc gia (MCĐT). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| cl_document_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng cl_specialization



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | cl_specialization_id | STRING |  | X | P |  | Id tự sinh (surrogate key). |
| 2 | cl_specialization_code | STRING |  |  |  |  | Mã chuyên ngành CCHN — BK của entity. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.SPECIALIZATIONS' | Mã hệ thống nguồn. |
| 4 | cl_specialization_nm | STRING |  |  |  |  | Tên chuyên ngành CCHN (VD: Phân tích đầu tư, Quản lý quỹ...). |
| 5 | legal_reference | STRING | X |  |  |  | Trích dẫn căn cứ pháp lý liên quan đến chuyên ngành. |
| 6 | active_ind | STRING | X |  |  |  | Cờ đang kích hoạt/hiệu lực. |
| 7 | original_data_ind | STRING | X |  |  |  | Cờ dữ liệu gốc của hệ thống (không được xóa). |
| 8 | public_service_portal_code | STRING | X |  |  |  | Mã đồng bộ chuyên ngành trên hệ thống Cổng Dịch vụ công quốc gia (MCĐT). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| cl_specialization_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng individual



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | individual_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | individual_code | STRING |  |  |  |  | Số CMND/CCCD/Hộ chiếu của người hành nghề. BK duy nhất của entity |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.IDENTITY_INFO_C06S' | Mã nguồn dữ liệu |
| 4 | full_nm | STRING | X |  |  |  | Họ và tên đầy đủ của người hành nghề |
| 5 | given_nm | STRING | X |  |  |  | Tên đệm và tên riêng (tên gọi) của người hành nghề |
| 6 | birth_dt | DATE | X |  |  |  | Ngày sinh (trong bản ghi vi phạm, snapshot tại thời điểm ghi) |
| 7 | birth_year | STRING | X |  |  |  | Năm sinh (lưu dạng chuỗi, dùng khi chỉ biết năm không có ngày tháng) |
| 8 | gender_code | STRING | X |  |  |  | Giới tính: 0=Nam, 1=Nữ |
| 9 | ethnicity_nm | STRING | X |  |  |  | Dân tộc (theo dữ liệu C06 CSDL quốc gia về dân cư) |
| 10 | religion_nm | STRING | X |  |  |  | Tôn giáo (theo dữ liệu C06 CSDL quốc gia về dân cư) |
| 11 | country_code | STRING | X |  | F |  | Mã quốc gia theo chuẩn ISO 3166-1 alpha-2 |
| 12 | place_of_birth_description | STRING | X |  |  |  | Nơi sinh của người hành nghề |
| 13 | place_of_birth_country_code | STRING | X |  |  |  | Mã quốc gia nơi sinh (theo C06) |
| 14 | place_of_birth_province_code | STRING | X |  |  |  | Mã tỉnh/thành phố nơi sinh (theo C06) |
| 15 | place_of_birth_district_code | STRING | X |  |  |  | Mã quận/huyện nơi sinh (theo C06) |
| 16 | hometown | STRING | X |  |  |  | Quê quán theo C06 CSDL quốc gia về dân cư |
| 17 | father_full_nm | STRING | X |  |  |  | Họ tên đầy đủ của bố (theo C06) |
| 18 | father_country_code | STRING | X |  |  |  | Mã quốc tịch của bố (theo C06) |
| 19 | father_identity_nbr | STRING | X |  |  |  | Số CMND/CCCD của bố (theo C06) |
| 20 | father_previous_identity_nbr | STRING | X |  |  |  | Số CMND cũ của bố (trước khi đổi CCCD, theo C06) |
| 21 | mother_full_nm | STRING | X |  |  |  | Họ tên đầy đủ của mẹ (theo C06) |
| 22 | mother_country_code | STRING | X |  |  |  | Mã quốc tịch của mẹ (theo C06) |
| 23 | mother_identity_nbr | STRING | X |  |  |  | Số CMND/CCCD của mẹ (theo C06) |
| 24 | mother_previous_identity_nbr | STRING | X |  |  |  | Số CMND cũ của mẹ (theo C06) |
| 25 | spouse_full_nm | STRING | X |  |  |  | Họ tên đầy đủ của vợ/chồng (theo C06) |
| 26 | spouse_country_code | STRING | X |  |  |  | Mã quốc tịch của vợ/chồng (theo C06) |
| 27 | spouse_identity_nbr | STRING | X |  |  |  | Số CMND/CCCD của vợ/chồng (theo C06) |
| 28 | spouse_previous_identity_nbr | STRING | X |  |  |  | Số CMND cũ của vợ/chồng (theo C06) |
| 29 | updated_by_officer_id | STRING | X |  | F |  | FK -> USERS: Người cập nhật thông tin C06 lần cuối |
| 30 | updated_by_officer_code | STRING | X |  |  |  | Mã cán bộ cập nhật (denormalized lookup) |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| individual_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng sp_license_certificate_status_change_history



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | sp_license_certificate_status_change_history_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | sp_license_certificate_status_change_history_code | STRING |  |  |  |  | Mã định danh (BK từ PK nguồn — nguồn không có cột mã nghiệp vụ riêng) |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.CERTIFICATE_RECORD_STATUS_HISTORIES' | Mã nguồn dữ liệu |
| 4 | data_dt | DATE |  |  |  |  | Thời điểm ghi nhận thay đổi trạng thái CCHN (nguồn: CREATED_AT). Dùng làm căn cứ partition Delta Lake / incremental filter — bảng nguồn là Fact Append (insert-only, xem BRD/Source/brd_NHNCK.yaml). |
| 5 | sp_license_certificate_document_id | STRING |  |  | F |  | FK đến chứng chỉ hành nghề bị thay đổi trạng thái |
| 6 | sp_license_certificate_document_code | STRING |  |  |  |  | Mã chứng chỉ hành nghề (denormalized lookup) |
| 7 | update_tp | STRING | X |  |  |  | Loại cập nhật trạng thái CCHN (chuỗi mô tả hành động thay đổi) |
| 8 | old_certificate_status_code | STRING | X |  |  |  | Trạng thái CCHN trước khi thay đổi |
| 9 | new_certificate_status_code | STRING | X |  |  |  | Trạng thái CCHN sau khi thay đổi |
| 10 | sp_license_decision_document_id | STRING | X |  | F |  | FK đến quyết định hành chính liên quan đến lần thay đổi trạng thái |
| 11 | sp_license_decision_document_code | STRING | X |  |  |  | Mã quyết định (denormalized lookup) |
| 12 | change_reason | STRING | X |  |  |  | Lý do thực hiện thao tác hoặc thay đổi |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| sp_license_certificate_status_change_history_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| sp_license_certificate_document_id | sp_license_certificate_document | sp_license_certificate_document_id |
| sp_license_decision_document_id | sp_license_decision_document | sp_license_decision_document_id |



#### Index

N/A

#### Trigger

N/A




### Bảng sp_post_certification_training_course



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | sp_post_certification_training_course_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | sp_post_certification_training_course_code | STRING |  |  |  |  | Mã khóa học/lớp học. BK duy nhất của entity |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.POST_CERT_TRAINING_COURSES' | Mã nguồn dữ liệu |
| 4 | training_course_nm | STRING | X |  |  |  | Tên khóa học/lớp học |
| 5 | training_class_code | STRING | X |  |  |  | Mã lớp học (định danh lớp cụ thể trong khóa) |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| sp_post_certification_training_course_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng sp_post_certification_training_result



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | sp_post_certification_training_result_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | sp_post_certification_training_result_code | STRING |  |  |  |  | Mã định danh (BK từ PK nguồn — nguồn không có cột mã nghiệp vụ riêng) |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.POST_CERT_TRAINING_RESULTS' | Mã nguồn dữ liệu |
| 4 | sp_id | STRING |  |  | F |  | FK đến người hành nghề tham gia đào tạo |
| 5 | sp_code | STRING |  |  |  |  | Mã người hành nghề (denormalized lookup) |
| 6 | sp_post_certification_training_course_id | STRING |  |  | F |  | FK đến khóa bồi dưỡng sau cấp CCHN |
| 7 | sp_post_certification_training_course_code | STRING |  |  |  |  | Mã khóa bồi dưỡng (denormalized lookup) |
| 8 | training_start_dt | DATE | X |  |  |  | Ngày bắt đầu tham gia khóa bồi dưỡng |
| 9 | training_end_dt | DATE | X |  |  |  | Ngày kết thúc tham gia khóa bồi dưỡng |
| 10 | training_hours | INT | X |  |  |  | Số giờ đào tạo |
| 11 | training_result_status_code | STRING | X |  |  |  | Trạng thái kết quả khóa bồi dưỡng (Đạt/Không đạt — suy đoán từ NUMBER(1,0)) |
| 12 | training_cl_result_code | STRING | X |  |  |  | Phân loại kết quả khóa bồi dưỡng (VD: Giỏi/Khá/Trung bình — suy đoán) |
| 13 | note | STRING | X |  |  |  | Ghi chú |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| sp_post_certification_training_result_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| sp_id | securities_practitioner | sp_id |



#### Index

N/A

#### Trigger

N/A




### Bảng ip_alternative_identification



#### Từ NHNCK.PROFESSIONALS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Securities Practitioner. |
| 2 | ip_code | STRING |  |  |  |  | Mã người hành nghề. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.PROFESSIONALS' | Mã hệ thống nguồn. |
| 4 | identification_tp_code | STRING | X |  |  |  | Loại giấy tờ định danh. |
| 5 | identification_nbr | STRING |  |  |  |  | Số giấy tờ định danh (CMND/CCCD/Hộ chiếu). |
| 6 | identification_issue_dt | DATE | X |  |  |  | Ngày cấp giấy tờ định danh. |
| 7 | identification_issue_place | STRING | X |  |  |  | Nơi cấp giấy tờ định danh. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | securities_practitioner | sp_id |



**Index:** N/A

**Trigger:** N/A


#### Từ NHNCK.IDENTITY_INFO_C06S

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Individual. |
| 2 | ip_code | STRING |  |  |  |  | Số CMND/CCCD/Hộ chiếu của người hành nghề. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.IDENTITY_INFO_C06S' | Mã hệ thống nguồn. |
| 4 | identification_tp_code | STRING |  |  |  | 'NATIONAL_ID' | Loại giấy tờ định danh. |
| 5 | identification_nbr | STRING |  |  |  |  | Số CMND/CCCD/Hộ chiếu của người hành nghề. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | individual | individual_id |



**Index:** N/A

**Trigger:** N/A





### Bảng ip_electronic_address



#### Từ NHNCK.UNITS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Regulatory Authority Organization Unit |
| 2 | ip_code | STRING |  |  |  |  | Mã đơn vị |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.UNITS' | Mã hệ thống nguồn |
| 4 | electronic_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email |
| 5 | electronic_adr_val | STRING | X |  |  |  | Email đơn vị |
| 6 | electronic_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax |
| 7 | electronic_adr_val | STRING | X |  |  |  | Số fax đơn vị |
| 8 | electronic_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại |
| 9 | electronic_adr_val | STRING | X |  |  |  | Số điện thoại đơn vị |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


**Index:** N/A

**Trigger:** N/A


#### Từ NHNCK.ORGANIZATIONS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Securities Organization Reference. |
| 2 | ip_code | STRING |  |  |  |  | Mã tổ chức. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.ORGANIZATIONS' | Mã hệ thống nguồn. |
| 4 | electronic_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. |
| 5 | electronic_adr_val | STRING | X |  |  |  | Địa chỉ email của tổ chức. |
| 6 | electronic_adr_tp_code | STRING |  |  |  | 'FAX' | Loại kênh liên lạc — fax. |
| 7 | electronic_adr_val | STRING | X |  |  |  | Số fax của tổ chức. |
| 8 | electronic_adr_tp_code | STRING |  |  |  | 'MOBILE' | Loại kênh liên lạc — số di động. |
| 9 | electronic_adr_val | STRING | X |  |  |  | Số di động của tổ chức. |
| 10 | electronic_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại. |
| 11 | electronic_adr_val | STRING | X |  |  |  | Số điện thoại cố định của tổ chức. |
| 12 | electronic_adr_tp_code | STRING |  |  |  | 'WEBSITE' | Loại kênh liên lạc — website. |
| 13 | electronic_adr_val | STRING | X |  |  |  | Địa chỉ website của tổ chức. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


**Index:** N/A

**Trigger:** N/A


#### Từ NHNCK.PROFESSIONALS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Securities Practitioner. |
| 2 | ip_code | STRING |  |  |  |  | Mã người hành nghề. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.PROFESSIONALS' | Mã hệ thống nguồn. |
| 4 | electronic_adr_tp_code | STRING |  |  |  | 'EMAIL' | Loại kênh liên lạc — email. |
| 5 | electronic_adr_val | STRING | X |  |  |  | Địa chỉ email. |
| 6 | electronic_adr_tp_code | STRING |  |  |  | 'MOBILE' | Loại kênh liên lạc — điện thoại di động. |
| 7 | electronic_adr_val | STRING | X |  |  |  | Số điện thoại di động. |
| 8 | electronic_adr_tp_code | STRING |  |  |  | 'PHONE' | Loại kênh liên lạc — điện thoại cố định. |
| 9 | electronic_adr_val | STRING | X |  |  |  | Số điện thoại cố định. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | securities_practitioner | sp_id |



**Index:** N/A

**Trigger:** N/A





### Bảng ip_postal_address



#### Từ NHNCK.UNITS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Regulatory Authority Organization Unit |
| 2 | ip_code | STRING |  |  |  |  | Mã đơn vị |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.UNITS' | Mã hệ thống nguồn |
| 4 | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở đơn vị |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


**Index:** N/A

**Trigger:** N/A


#### Từ NHNCK.ORGANIZATIONS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Securities Organization Reference. |
| 2 | ip_code | STRING |  |  |  |  | Mã tổ chức. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.ORGANIZATIONS' | Mã hệ thống nguồn. |
| 4 | adr_tp_code | STRING |  |  |  | 'HEAD_OFFICE' | Loại địa chỉ — trụ sở chính. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở chính của tổ chức. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


**Index:** N/A

**Trigger:** N/A


#### Từ NHNCK.PROFESSIONALS

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Securities Practitioner. |
| 2 | ip_code | STRING |  |  |  |  | Mã người hành nghề. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.PROFESSIONALS' | Mã hệ thống nguồn. |
| 4 | adr_tp_code | STRING |  |  |  | 'CURRENT' | Loại địa chỉ — tạm trú. |
| 5 | country_id | STRING | X |  | F |  | FK đến Geographic Area — quốc gia địa chỉ tạm trú hiện tại. |
| 6 | country_code | STRING | X |  |  |  | Mã quốc gia địa chỉ tạm trú. |
| 7 | province_id | STRING | X |  | F |  | FK đến Geographic Area — tỉnh/thành địa chỉ tạm trú. |
| 8 | province_code | STRING | X |  |  |  | Mã tỉnh/thành địa chỉ tạm trú. |
| 9 | district_id | STRING | X |  | F |  | FK đến Geographic Area — quận/huyện địa chỉ tạm trú. |
| 10 | district_code | STRING | X |  |  |  | Mã quận/huyện địa chỉ tạm trú. |
| 11 | adr_tp_code | STRING |  |  |  | 'PERMANENT' | Loại địa chỉ. |
| 12 | adr_val | STRING | X |  |  |  | Giá trị địa chỉ. |
| 13 | country_id | STRING | X |  | F |  | FK đến Geographic Area — quốc gia. |
| 14 | country_code | STRING | X |  |  |  | Mã quốc gia. |
| 15 | province_id | STRING | X |  | F |  | FK đến Geographic Area — tỉnh/thành. |
| 16 | province_code | STRING | X |  |  |  | Mã tỉnh/thành. |
| 17 | district_id | STRING | X |  | F |  | FK đến Geographic Area — quận/huyện. |
| 18 | district_code | STRING | X |  |  |  | Mã quận/huyện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | securities_practitioner | sp_id |



**Index:** N/A

**Trigger:** N/A


#### Từ NHNCK.IDENTITY_INFO_C06S

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Individual. |
| 2 | ip_code | STRING |  |  |  |  | Số CMND/CCCD/Hộ chiếu của người hành nghề. |
| 3 | src_stm_code | STRING |  |  |  | 'NHNCK.IDENTITY_INFO_C06S' | Mã hệ thống nguồn. |
| 4 | adr_tp_code | STRING |  |  |  | 'CURRENT' | Loại địa chỉ — tạm trú. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ chi tiết tạm trú (theo C06). |
| 6 | country_code | STRING | X |  |  |  | Mã quốc gia địa chỉ tạm trú (theo C06). |
| 7 | province_code | STRING | X |  |  |  | Mã tỉnh/thành phố địa chỉ tạm trú (theo C06). |
| 8 | district_code | STRING | X |  |  |  | Mã quận/huyện địa chỉ tạm trú (theo C06). |
| 9 | adr_tp_code | STRING |  |  |  | 'PERMANENT' | Loại địa chỉ — thường trú. |
| 10 | adr_val | STRING | X |  |  |  | Địa chỉ chi tiết thường trú (số nhà, đường, phường/xã theo C06). |
| 11 | country_code | STRING | X |  | F |  | Mã quốc gia địa chỉ thường trú (theo C06). |
| 12 | province_code | STRING | X |  |  |  | Mã tỉnh/thành phố địa chỉ thường trú (theo C06). |
| 13 | district_code | STRING | X |  |  |  | Mã quận/huyện địa chỉ thường trú (theo C06). |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | individual | individual_id |



**Index:** N/A

**Trigger:** N/A





### Stored Procedure/Function

N/A

### Package

N/A
