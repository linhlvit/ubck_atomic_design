# BẢNG CÂU TRẢ LỜI & XÁC MINH CSDL PHÂN HỆ NGƯỜI HÀNH NGHỀ (NHNCK)

---

## I. CÂU HỎI VỀ ĐỊNH NGHĨA ENUM VÀ CÁC TRƯỜNG KHÔNG TỒN TẠI TRONG BẢNG (THEO YÊU CẦU ĐẶC BIỆT)

### 1. Trường `TYPE` của bảng `ORGANIZATIONS`
- **Tình trạng CSDL**: Trong bảng `ORGANIZATIONS`, **không có** trường tên là `TYPE`.
- **Tên cột thực tế trong DB**: Cột thực tế là **`ORGANIZATION_TYPE_ID`** (đại diện cho Loại tổ chức kinh doanh chứng khoán).
- **Định nghĩa Enum tương ứng**: Ánh xạ với `TypeOrganizationEnum` trong hệ thống:
  - `0`: **Khác** (`OTHER`)
  - `1`: **Công ty chứng khoán** (`STOCK`)
  - `2`: **Công ty quản lý quỹ** (`FUND`)
  - `3`: **Ngân hàng thương mại / Ngân hàng lưu ký** (`BANK`)

---

### 2. Trường `SUB_TYPE` của bảng `ORGANIZATION_REPORTS`
- **Tình trạng CSDL**: Trong bảng `ORGANIZATION_REPORTS`, **không có** trường tên là `SUB_TYPE`.
- **Tên cột thực tế trong DB**: Bảng này chỉ sử dụng cột **`TYPE`** (Loại báo cáo tổ chức).
- **Định nghĩa Enum tương ứng**: Ánh xạ với `TypeOrganizationReportEnum` trong hệ thống:
  - `0`: **Báo cáo cập nhật biến động người hành nghề / tuyển dụng / thôi việc** (`UPDATE`)
  - `1`: **Báo cáo thường niên tình hình người hành nghề** (`YEARLY`)

---

## II. GIẢI ĐÁP CHI TIẾT DỰA TRÊN FILE `Câu hỏi NHNCK.xlsx`

### 1. Bảng `DECISION_DOCUMENTS`
- **Câu hỏi**: `DECISION_ID` và `DECISION_NUMBER` có 1:1 với nhau không? Cùng 1 `DECISION_ID` nhưng `DECISION_DOCUMENTS.DECISION_NUMBER` khác với `DECISIONS.DECISION_NUMBER` cần xác minh lại dữ liệu?
- **Trả lời**:
  - Mối quan hệ giữa `DECISIONS` và `DECISION_DOCUMENTS` là **1 : N** (Một Quyết định hành chính có thể liên kết với nhiều văn bản/tờ trình liên quan).
  - Trường `DECISION_NUMBER` trong `DECISION_DOCUMENTS` lưu **Số văn bản điều hành (Số VBĐH)** của từng loại tài liệu trong tập hồ sơ:
    - Loại `0` (`Tờ trình`): `DECISION_NUMBER` lưu số hiệu của Tờ trình (ví dụ: *12/TTr-UBCK*).
    - Loại `1` (`Quyết định`): `DECISION_NUMBER` lưu số hiệu của Quyết định (ví dụ: *105/QĐ-UBCK*), trùng khớp với `DECISIONS.DECISION_NUMBER`.
    - Loại `2` (`Văn bản đính kèm khác`): Lưu số hiệu công văn/tài liệu tương ứng.
  - **Kết luận**: Việc `DECISION_DOCUMENTS.DECISION_NUMBER` khác với `DECISIONS.DECISION_NUMBER` đối với các bản ghi Tờ trình/Công văn khác là **đúng thiết kế nghiệp vụ**.

---

### 2. Bảng `EXAM_DETAILS` & `SPECIALIZATION_COURSE_DETAILS`
- **Câu hỏi**:
  1. Trường `EXAM_NUMBER` có `NOT NULL` và `UNIQUE` với mỗi `EXAM_SESSION_ID` không?
  2. Cơ chế ghi dữ liệu của bảng như thế nào?
- **Trả lời**:
  1. `EXAM_NUMBER` là **Số báo danh / Mã số thí sinh dự thi**. Trong cùng 1 đợt sát hạch (`EXAM_SESSION_ID`), trường `EXAM_NUMBER` là **NOT NULL** (khi đã lập danh sách thi chính thức) và **UNIQUE** (mỗi thí sinh chỉ có 1 SBD duy nhất trong đợt thi đó).
  2. **Cơ chế ghi dữ liệu**: Dữ liệu được ghi nhận khi Lập danh sách thí sinh dự thi sát hạch / Import danh sách thi theo đợt từ file Excel hoặc đồng bộ kết quả từ hệ thống Quản lý thi sát hạch (SRTC). Nếu update thông tin thì SCD1 + Update trường UPDATED_AT

---

### 3. Bảng `ORGANIZATION_REPORTS`
- **Câu hỏi**: Cơ chế ghi dữ liệu của bảng như thế nào?
- **Trả lời**:
  - Bảng `ORGANIZATION_REPORTS` ghi nhận báo cáo tình hình người hành nghề tại các Tổ chức kinh doanh chứng khoán.
  - **Cơ chế ghi dữ liệu**:
    1. **Đồng bộ tự động (Sync)**: Nhận dữ liệu tự động từ các hệ thống FMS và SCMS.
    2. **Khai báo từ cổng/giao diện**: Tổ chức kinh doanh chứng khoán hoặc Cán bộ khai báo thông tin biến động (tuyển dụng mới `HIRE_DATE` hoặc chấm dứt hợp đồng `TERMINATION_DATE`).
    3. Dữ liệu sau khi Cán bộ UBCK duyệt (`APPROVED`) sẽ tự động cập nhật vào Quá trình làm việc (`PROFESSIONAL_WORK_HISTORIES`) của Người hành nghề.

---

### 4. Định nghĩa Enum `STATUS` trong `APPLICATION_GROUP_MEMBERS` và `CERTIFICATE_RECORD_GROUP_MEMBERS`
- **Câu hỏi**: Định nghĩa enum của trường `STATUS` là gì?
- **Trả lời**:
  - Trường `STATUS` đại diện cho trạng thái hiệu lực của bản ghi thành viên trong nhóm:
    - `1`: **Active / Đang hiệu lực** (Hồ sơ/Chứng chỉ nằm trong nhóm xử lý).
    - `0`: **Inactive / Đã xoá khỏi nhóm** (Bản ghi đã bị hủy hoặc loại ra khỏi nhóm).

---

### 5. Bảng `DEPARTMENTS` - Trường `ECATALOG_ID`
- **Câu hỏi**: Trường `ECATALOG_ID` link tới bảng nào?
- **Trả lời**:
  - `ECATALOG_ID` (kiểu UUID/String) lưu mã định danh danh mục phòng ban trên **Hệ thống Quản lý Danh mục dùng chung (eCatalog / Bộ Tài chính / UBCK)**.
  - Trường này được sử dụng để tích hợp, đồng bộ và liên kết danh mục Phòng ban giữa hệ thống NHNCK với hệ thống eCatalog tập trung.
  - ECAT.DEPARTMENTS: Phòng ban UBCK
  - ECAT.ENTERPRISE_TYPE: Phòng ban ngoài UBCK

---

### 6. Bảng `CERTIFICATE_SPECIALIZATIONS` - Trường `DOCUMENT_TYPE`
- **Câu hỏi**: Định nghĩa enum của trường `DOCUMENT_TYPE` là gì?
- **Trả lời**:
  - `DOCUMENT_TYPE` định nghĩa loại văn bản/văn bằng chuyên môn đính kèm để chứng minh điều kiện cấp CCHN:
    - `1`: **Văn bằng đại học / Chuyên ngành** (Đại học tài chính, kinh tế, luật...).
    - `2`: **Chứng chỉ chuyên môn chứng khoán** (Do SRTC/UBCK cấp).
    - `3`: **Chứng chỉ quốc tế** (CFA, ACCA, CIIA... được miễn trừ môn thi).

---

### 7. Bảng `BANKS`, `POSITIONS`, `EDUCATION_LEVELS`
- **Câu hỏi**: Các bảng này có đồng bộ từ phân hệ khác không?
- **Trả lời**:
  - **CÓ**. Cả 3 bảng đều là **Danh mục dùng chung (Master Data)** của toàn bộ hệ thống UBCK:
    - `BANKS`: Đồng bộ từ danh mục Ngân hàng dùng chung (eCatalog).
    - `POSITIONS`: Đồng bộ từ danh mục Chức vụ dùng chung (eCatalog / SCMS).
    - `EDUCATION_LEVELS`: Đồng bộ từ danh mục Trình độ học vấn dùng chung (eCatalog).

---

### 8. Bảng `ORGANIZATION_REPORT_YEARLYS` - Trường `TYPE`
- **Câu hỏi**: Định nghĩa enum của trường `TYPE` là gì?
- **Trả lời**:
  - `TYPE` phân loại hình thức báo cáo thường niên của Tổ chức:
    - `1`: **Báo cáo định kỳ hàng năm** (Báo cáo thường niên định kỳ về Người hành nghề).
    - `2`: **Báo cáo đột xuất / Bổ sung** (Báo cáo theo yêu cầu riêng của UBCK).

---

### 9. Bảng `POST_CERT_TRAINING_RESULTS` - Trường `RESULT_STATUS`
- **Câu hỏi**: Trường `RESULT_STATUS` có thay thế cho `STATUS` không?
- **Trả lời**:
  - **CÓ**. Tên cột thực tế lưu trong CSDL Oracle là **`RESULT_STATUS`** (thay thế cho tên `STATUS` mô tả trong tài liệu enum ban đầu).
  - Giá trị ánh xạ qua `PostCertTrainingResultStatusEnum`:
    - `0`: **Đạt** (`PASSED`)
    - `1`: **Không đạt** (`FAILED`)

---

### 10. Bảng `PROFESSIONALS` & `SPECIALIZATION_COURSE_DETAILS` - Trường `IDENTITY_TYPE`
- **Câu hỏi**: Định nghĩa enum của `IDENTITY_TYPE` là gì?
- **Trả lời**:
  - `IDENTITY_TYPE` xác định loại giấy tờ tùy thân của Người hành nghề / Thí sinh:
    - `1`: **CMND** (Chứng minh nhân dân)
    - `2`: **CCCD** (Căn cước công dân / Căn cước)
    - `3`: **Hộ chiếu** (Passport - Thường dùng cho người nước ngoài)
  - Trường `IDENTITY_TYPE` trong `SPECIALIZATION_COURSE_DETAILS` vẫn được giữ trong CSDL để lưu lại lịch sử loại giấy tờ định danh của học viên tại thời điểm đăng ký khóa học/sát hạch.

---

### 11. Bảng `SPECIALIZATIONS` - Trường `ACTIVE` và `RECORD_STATUS`
- **Câu hỏi**: `ACTIVE`, `RECORD_STATUS` khai thác như thế nào?
- **Trả lời**:
  - `ACTIVE`: Dùng cho giao diện người dùng (UI/Dropdown Filters).
    - `1`: **Hoạt động** (Hiển thị cho chọn trên giao diện).
    - `0`: **Ngưng hoạt động / Khóa** (Ẩn trên dropdown chọn mới).
  - `RECORD_STATUS`: Quản lý trạng thái vòng đời của bản ghi dữ liệu danh mục:
    - `1`: **Chính thức / Đã duyệt** (Áp dụng chính thức trên toàn hệ thống).
    - `0`: **Nháp / Đang cập nhật** (Dữ liệu tạm thời chưa phê duyệt).

---

### 12. Bảng `VIOLATIONS` - Các loại vi phạm (`TYPE`)
- **Câu hỏi**: Có những loại vi phạm nào?
- **Trả lời**:
  - Phân loại qua `ViolationTypeEnum`:
    - `1`: **Vi phạm Hành chính** (`ADMINISTRATIVE`) - Các quyết định xử phạt vi phạm hành chính trong lĩnh vực chứng khoán.
    - `2`: **Vi phạm Pháp luật / Hình sự** (`LEGAL`) - Các vi phạm truy cứu trách nhiệm hình sự hoặc vi phạm pháp luật nghiêm trọng.

---

### 13. `PostCertTrainingComplianceStatusEnum`
- **Câu hỏi**: `PostCertTrainingComplianceStatusEnum` đang dùng ở đâu?
- **Trả lời**:
  - Enum này được sử dụng trong dịch vụ **`PostCertTrainingHourServiceImpl`** (Backend Java) để tự động tính toán và đánh giá **Trạng thái Tuân thủ Đào tạo/Bồi dưỡng Sau cấp CCHN** của Người hành nghề trong chu kỳ bồi dưỡng (ví dụ 3 năm / 30 giờ):
    - **`EXEMPT`**: **Miễn đào tạo** (Trong thời gian được miễn bồi dưỡng theo quy định).
    - **`MET`**: **Đạt chuẩn / Đã tuân thủ** (Đã hoàn thành đủ số giờ đào tạo bắt buộc).
    - **`NOT_MET`**: **Chưa đạt / Chưa tuân thủ** (Chưa hoàn thành đủ số giờ bồi dưỡng bắt buộc trong chu kỳ).
