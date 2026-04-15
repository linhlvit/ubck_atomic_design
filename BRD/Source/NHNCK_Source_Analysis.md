# NHNCK — Tài liệu khảo sát nguồn và ánh xạ Silver

> **Phân hệ:** Quản lý giám sát người hành nghề chứng khoán (CSDL: `qlnhn`, MySQL Server)
>
> **Nguồn tài liệu:**
> - Đặc tả yêu cầu: `New_UBCKNN_Dac_ta_yeu_cau_NHNCK_18_03_2026.docx`
> - Thiết kế CSDL: `New_UBCKNN_Thiet_ke_co_so_du_lieu_NHNCK_20_03_2026.docx`
> - HLD Overview: `NHNCK_HLD_Overview.md`
> - Silver mapping: `silver_entities.csv`

---

## Quy ước cột Ánh xạ Silver

| Ký hiệu | Ý nghĩa |
|---|---|
| 🟢 *Tên entity* | Silver entity được thiết kế |
| 🟢 `CV: CODE` | Classification Value (danh mục mã hóa) |
| 🟢 ↳ denormalize vào *Entity* | Junction/bảng con flatten vào entity chính |
| 🔴 (Out of scope) *lý do* | Ngoài scope Silver |

---

## Mục lục

- [UID01 — Quản trị phân hệ](#uid01--quản-trị-phân-hệ)
- [UID02 — Quản lý danh mục dùng riêng](#uid02--quản-lý-danh-mục-dùng-riêng)
- [UID03 — Quản lý hồ sơ](#uid03--quản-lý-hồ-sơ)
- [UID04 — Quản lý thi sát hạch](#uid04--quản-lý-thi-sát-hạch)
- [UID05 — Quản lý chứng chỉ hành nghề](#uid05--quản-lý-chứng-chỉ-hành-nghề)
- [UID06 — Quản lý người hành nghề chứng khoán](#uid06--quản-lý-người-hành-nghề-chứng-khoán)
- [UID07–09 — Báo cáo thống kê & Khai thác báo cáo](#uid0709--báo-cáo-thống-kê--khai-thác-báo-cáo)
- [UID10 — Quản lý đào tạo tập huấn](#uid10--quản-lý-đào-tạo-tập-huấn)
- [UID11–12 — Tiện ích & Quản lý tích hợp](#uid1112--tiện-ích--quản-lý-tích-hợp)
- [Phụ lục: Danh mục dùng chung](#phụ-lục-danh-mục-dùng-chung)

---

## UID01 — Quản trị phân hệ

Quản lý người dùng hệ thống, phân quyền, chứng thư số ký điện tử, sao lưu/phục hồi CSDL, nhật ký hệ thống. Phục vụ cán bộ quản trị UBCKNN.

### 1.1. Quản lý người dùng & phân quyền

**Nghiệp vụ:** Quản lý tài khoản, gán nhóm quyền cho người dùng. Mỗi người dùng thuộc 1 đơn vị/phòng ban, có chức vụ. Hỗ trợ cập nhật thông tin cá nhân và đổi mật khẩu.

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `Users` | Thông tin người dùng hệ thống | 🟢 *Regulatory Authority Officer* |
| ├── `Units` | Danh mục đơn vị UBCKNN | 🟢 *Regulatory Authority Organization Unit* |
| ├── `Departments` | Danh mục phòng ban UBCKNN | 🟢 *Regulatory Authority Organization Unit* |
| ├── `Positions` | Danh mục chức vụ | 🟢 `CV: POSITION` |
| `UserRoles` | Phân quyền người dùng theo nhóm | 🔴 (Out of scope) *Operational/system data* |
| ├── `Roles` | Nhóm quyền | 🔴 (Out of scope) *Operational/system data* |
| `Permissions` | Danh mục quyền hạn | 🔴 (Out of scope) *Operational/system data* |
| `PermissionRoles` | Gán quyền cho nhóm | 🔴 (Out of scope) *Operational/system data* |
| `DepartmentAccess` | Quyền khai thác giữa phòng ban | 🔴 (Out of scope) *Operational/system data* |

### 1.2. Quản lý chứng thư số

**Nghiệp vụ:** Đăng ký chứng thư số (USB Token, Smart Card) vào hệ thống, gán cho tài khoản người dùng để ký số chứng chỉ hành nghề điện tử.

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `DigitalCertificates` | Chứng thư số | 🔴 (Out of scope) *Operational/PKI data* |
| `DigitalCertificateUsers` | Tài khoản sử dụng chứng thư số | 🔴 (Out of scope) *Operational/PKI data* |

### 1.3. Nhật ký hệ thống

**Nghiệp vụ:** Ghi nhận mọi thao tác của người dùng trên hệ thống (IP, nội dung, thời gian).

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `ActionLogs` | Nhật ký hoạt động hệ thống | 🔴 (Out of scope) *System audit log* |

---

## UID02 — Quản lý danh mục dùng riêng

Quản lý các danh mục dữ liệu dùng trong phân hệ: loại chứng chỉ, tài liệu, chuyên môn, trình độ, tổ chức, quyết định, hình thức nộp hồ sơ. Cán bộ quản trị phân hệ thực hiện.

### 2.1. Danh mục chứng chỉ & cấu hình liên quan

**Nghiệp vụ:** Quản lý loại chứng chỉ (MGCK, PTTC, QLQ), cấu hình tài liệu cần nộp, chuyên môn yêu cầu, phòng ban xử lý, mẫu số chứng chỉ cho từng loại.

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `Certificates` | Danh mục loại chứng chỉ hành nghề | 🟢 `CV: CERTIFICATE_TYPE` |
| `CertificateDocuments` | Cấu hình tài liệu theo loại chứng chỉ | 🔴 (Out of scope) *Application config* |
| `CertificateSpecializations` | Cấu hình chuyên môn theo loại chứng chỉ | 🔴 (Out of scope) *Application config* |
| `CertificateDepartments` | Phân quyền phòng ban theo loại chứng chỉ | 🔴 (Out of scope) *Application config* |
| `CertificateNumberTemplates` | Mẫu sinh số chứng chỉ từ MCĐT | 🔴 (Out of scope) *Config/template data* |

### 2.2. Danh mục chuyên môn & tài liệu

**Nghiệp vụ:** Quản lý danh mục chứng chỉ chuyên môn (CPA, CFA...) và danh mục tài liệu cần nộp trong hồ sơ.

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `Specializations` | Danh mục chuyên môn | 🟢 `CV: SPECIALIZATION` |
| `Documents` | Danh mục tài liệu hồ sơ | 🟢 `CV: DOCUMENT_TYPE` |
| `EducationLevels` | Danh mục trình độ học vấn | 🟢 `CV: EDUCATION_LEVEL` |

### 2.3. Danh mục tổ chức

**Nghiệp vụ:** Quản lý thông tin tổ chức CTCK, QLQ, ngân hàng. Cấu trúc cây (ParentId self-ref). Dữ liệu sync từ các phân hệ khác.

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `Organizations` | Tổ chức tham gia TTCK | 🟢 *Securities Organization Reference* |

### 2.4. Danh mục quyết định & hình thức nộp hồ sơ

**Nghiệp vụ:** Quản lý quyết định hành chính (cấp/thu hồi/hủy CCHN, công nhận kết quả thi, xử lý vi phạm). Quản lý hình thức nộp hồ sơ (MCĐT, trực tiếp) và định nghĩa trạng thái hồ sơ.

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `Decisions` | Quyết định hành chính | 🟢 *Securities Practitioner License Decision Document* |
| `ApplicationSources` | Hình thức nộp hồ sơ | 🟢 `CV: APPLICATION_SOURCE` |
| `ApplicationStatuses` | Định nghĩa trạng thái hồ sơ | 🟢 `CV: APPLICATION_STATUS` |

### 2.5. Tham số hệ thống

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `SystemParameters` | Tham số cấu hình hệ thống | 🔴 (Out of scope) *Config data* |

---

## UID03 — Quản lý hồ sơ

Quản lý toàn bộ vòng đời hồ sơ đăng ký CCHN: tiếp nhận từ MCĐT, phân công cán bộ, thẩm định tài liệu + chuyên môn, xác nhận hợp lệ/từ chối/bổ sung, phê duyệt đa cấp (CVTH → LĐCM → LĐUB). Bao gồm hồ sơ thi cấp mới và hồ sơ cấp lại.

### 3.1. Hồ sơ thi cấp CCHN

**Nghiệp vụ:** Tiếp nhận hồ sơ cấp mới từ MCĐT, xác thực danh tính C06, phân công cán bộ thẩm định, thẩm định tài liệu + chứng chỉ chuyên môn, xác nhận hợp lệ → phê duyệt lãnh đạo. Hỗ trợ gộp đăng ký thi sát hạch vào thủ tục cấp CCHN (theo NĐ 245/2025).

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `Applications` | Hồ sơ đăng ký CCHN | 🟢 *Securities Practitioner License Application* |
| ├── `Professionals` | Người hành nghề nộp hồ sơ | 🟢 *Securities Practitioner* *(xem UID06)* |
| ├── `ApplicationSpecializations` | Chứng chỉ chuyên môn đính kèm | 🟢 *License Application Education Certificate Document* |
| ├── `ApplicationDocuments` | Tài liệu đính kèm hồ sơ | 🟢 *License Application Document Attachment* |
| ├── `ApplicationFees` | Nghĩa vụ tài chính | 🟢 *License Application Fee* |
| ├── `ApplicationLogs` | Nhật ký xử lý hồ sơ | 🟢 *License Application Processing Activity Log* |
| ├── `VerifyApplicationStatuses` | Phê duyệt lãnh đạo | 🟢 *License Application Verification Status* |
| ├── `IdentityInfoC06s` | Xác thực danh tính C06 | 🟢 *Identity Verification Record* |
| └── Danh mục tham chiếu: `Certificates`, `ApplicationStatuses`, `ApplicationSources`, `ExamSessions` | | *(xem Phụ lục)* |

### 3.2. Hồ sơ cấp lại CCHN

**Nghiệp vụ:** Hồ sơ cấp lại do hỏng/mất hoặc thay đổi thông tin cá nhân. Không cần thi sát hạch lại. Cùng quy trình thẩm định và phê duyệt.

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `Applications` | Hồ sơ cấp lại (ApplicationType phân loại) | 🟢 *Securities Practitioner License Application* *(xem 3.1)* |
| └── `ProfessionalRelationships` | Quan hệ gia đình (cập nhật khi thay đổi TT) | 🟢 *Securities Practitioner Related Party* *(xem UID06)* |

---

## UID04 — Quản lý thi sát hạch

Quản lý đợt thi sát hạch cấp CCHN: tạo đợt thi, quản lý thí sinh, nhập kết quả (thủ công hoặc import Excel), công nhận kết quả. Bao gồm cả kết quả thi chứng chỉ chuyên môn.

### 4.1. Đợt thi sát hạch & kết quả

**Nghiệp vụ:** Tạo đợt thi (mã đợt, năm, địa điểm, đơn vị tổ chức, phí thi). Import kết quả từ Excel. Cập nhật quyết định công nhận kết quả. Hoàn thành → chuyển trạng thái hồ sơ "Sát hạch — Đạt".

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `ExamSessions` | Đợt thi sát hạch | 🟢 *Qualification Examination Assessment* |
| ├── `ExamDetails` | Kết quả từng thí sinh | 🟢 *Qualification Examination Assessment Result* |
| │   ├── `Professionals` | Thí sinh | 🟢 *Securities Practitioner* *(xem UID06)* |
| │   └── `Applications` | Hồ sơ liên kết | 🟢 *License Application* *(xem UID03)* |
| ├── `ExamSessionFees` | Biểu phí thi theo loại chứng chỉ | 🟢 *Qualification Examination Assessment Fee* |
| └── `Decisions` | QĐ công nhận kết quả | 🟢 *License Decision Document* *(xem UID02)* |

### 4.2. Kết quả thi chứng chỉ chuyên môn

**Nghiệp vụ:** Quản lý kết quả thi chứng chỉ chuyên môn bổ sung (CPA, CFA...) do TTNCKH&ĐTCK cập nhật. Import từ Excel.

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `SpecializationCourses` | Khóa học chuyên môn | 🟢 *Professional Training Class* |
| └── `SpecializationCourseDetails` | Kết quả từng học viên | 🟢 *Training Class Enrollment* |

---

## UID05 — Quản lý chứng chỉ hành nghề

Quản lý cấp/thu hồi/hủy/chuyển đổi điện tử chứng chỉ hành nghề. Xử lý theo nhóm (batch): gom nhiều chứng chỉ vào 1 nhóm → duyệt LĐCM → LĐUB → cấp số + ký số. Tra cứu danh sách chứng chỉ.

### 5.1. Nhóm cấp / thu hồi / hủy chứng chỉ

**Nghiệp vụ:** Tạo nhóm chứng chỉ, thêm/xóa thành viên, gửi duyệt LĐCM → LĐUB. Sau khi duyệt: cấp số tự động 6 chữ số, ký số lên CCHN điện tử. Thu hồi/hủy tương tự: chọn chứng chỉ → tạo nhóm → chọn QĐ → xác nhận.

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `CertificateRecordGroups` | Nhóm chứng chỉ (cấp/thu hồi/hủy/chuyển đổi) | 🟢 *License Certificate Group Document* |
| ├── `CertificateRecordGroupMembers` | Thành viên trong nhóm | 🟢 *License Certificate Group Member* |
| │   ├── `CertificateRecords` | Chứng chỉ hành nghề | 🟢 *License Certificate Document* *(xem 5.2)* |
| │   └── `Applications` | Hồ sơ liên kết | 🟢 *License Application* *(xem UID03)* |
| └── `Decisions` | Quyết định cấp/thu hồi/hủy | 🟢 *License Decision Document* *(xem UID02)* |

### 5.2. Chứng chỉ hành nghề & lịch sử

**Nghiệp vụ:** Mỗi chứng chỉ gắn NHN + loại chứng chỉ + QĐ cấp + QĐ thu hồi (nếu có). Trạng thái: Chưa sử dụng → Đang sử dụng → Thu hồi có/không cấp lại → Hết hiệu lực → Đã hủy.

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `CertificateRecords` | Chứng chỉ hành nghề được cấp | 🟢 *License Certificate Document* |
| ├── `Professionals` | Người hành nghề | 🟢 *Securities Practitioner* *(xem UID06)* |
| ├── `Decisions` (IssueDecisionId) | QĐ cấp | 🟢 *License Decision Document* *(xem UID02)* |
| ├── `Decisions` (RevocationDecisionId) | QĐ thu hồi | 🟢 *License Decision Document* *(xem UID02)* |
| ├── `CertificateRecordStatusHistories` | Lịch sử chuyển trạng thái | 🟢 *License Certificate Document Status History* |
| └── `CertificateRecordLogs` | Nhật ký hoạt động | 🟢 *License Certificate Document Activity Log* |

### 5.3. Chuyển đổi chứng chỉ điện tử

**Nghiệp vụ:** Chuyển đổi CCHN từ giấy sang điện tử: tạo danh sách → phê duyệt → ký số. Sử dụng cùng cơ chế nhóm (CertificateRecordGroups).

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| Sử dụng cùng `CertificateRecordGroups` (Type = chuyển đổi) | | *(xem 5.1)* |

---

## UID06 — Quản lý người hành nghề chứng khoán

Quản lý thông tin NHN đã được cấp CCHN: tra cứu, cập nhật trạng thái hành nghề, quản lý quá trình công tác, quản lý vi phạm. Trạng thái: Chưa hành nghề / Đang hành nghề / Cấm hành nghề có thời hạn / Thu hồi có cấp lại / Thu hồi không cấp lại.

### 6.1. Thông tin người hành nghề

**Nghiệp vụ:** Master entity NHN — xem chi tiết (định danh, chứng chỉ, chuyên môn, quá trình công tác), cập nhật trạng thái, cảnh báo (không làm việc 3 năm, làm nhiều tổ chức, chưa nộp lệ phí). Thông tin cá nhân xác thực qua C06.

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `Professionals` | Thông tin người hành nghề | 🟢 *Securities Practitioner* |
| ├── `ProfessionalHistories` | Lịch sử thay đổi định danh | 🟢 ↳ denormalize vào *Securities Practitioner* |
| ├── `ProfessionalRelationships` | Quan hệ gia đình/xã hội | 🟢 *Securities Practitioner Related Party* |
| ├── `ProfessionalWorkHistories` | Lịch sử làm việc tại tổ chức | 🟢 *Securities Practitioner Employment Status* |
| │   └── `Organizations` | Tổ chức sử dụng NHN | 🟢 *Securities Organization Reference* *(xem UID02)* |
| └── `IdentityInfoC06s` | Xác thực C06 | 🟢 *Identity Verification Record* |

### 6.2. Quản lý vi phạm

**Nghiệp vụ:** Ghi nhận vi phạm NHN (Pháp luật / Hành chính), liên kết với quyết định xử lý. Trạng thái: Hiệu lực / Không hiệu lực.

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `Violations` | Vi phạm người hành nghề | 🟢 *Securities Practitioner Conduct Violation* |
| ├── `Professionals` | Người vi phạm | 🟢 *Securities Practitioner* *(xem 6.1)* |
| └── `Decisions` | QĐ xử lý vi phạm | 🟢 *License Decision Document* *(xem UID02)* |

### 6.3. Báo cáo tổ chức về NHN

**Nghiệp vụ:** Tổ chức (CTCK, QLQ) báo cáo về NHN qua 2 luồng: (1) Báo cáo biến động — ký kết/chấm dứt HĐLĐ, sync hằng ngày từ Cổng BCTT; (2) Báo cáo thường niên — mẫu số 87 NĐ 155/2020, khi có yêu cầu. Trường `Type` phân loại. Self-referencing (ParentReportId).

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `OrganizationReports` | Báo cáo tổ chức về NHN | 🟢 *Organization Employment Report* |
| ├── `Professionals` | NHN được báo cáo | 🟢 *Securities Practitioner* *(xem 6.1)* |
| ├── `Organizations` | Tổ chức báo cáo | 🟢 *Securities Organization Reference* *(xem UID02)* |
| └── `OrganizationReports` (ParentReportId) | Báo cáo cha (self-ref) | 🟢 *Organization Employment Report* |

---

## UID07–09 — Báo cáo thống kê & Khai thác báo cáo

Báo cáo hồ sơ đăng ký, danh sách chứng chỉ, NHN theo nhiều chiều (loại, trạng thái, tổ chức, vi phạm). Khai thác báo cáo NHN tự kê khai (ký/chấm dứt HĐLĐ) và báo cáo tổ chức (biến động + thường niên). Xuất Excel.

**Nghiệp vụ:** Đọc dữ liệu từ các bảng nghiệp vụ đã lên Silver. Không tạo dữ liệu mới.

| Bảng đọc dữ liệu | Ánh xạ Silver |
|---|---|
| `Applications`, `CertificateRecords`, `Professionals`, `Organizations`, `OrganizationReports`, `ProfessionalWorkHistories`, `Violations`, `ExamSessions` | *(Đã ánh xạ tại các UID tương ứng)* |

---

## UID10 — Quản lý đào tạo tập huấn

Quản lý kết quả đào tạo tập huấn sau khi cấp CCHN do TTNCKH&ĐTCK thực hiện. Cảnh báo NHN không đáp ứng yêu cầu thời gian đào tạo.

**Nghiệp vụ:** Thêm/sửa/xóa kết quả, import Excel, xem lịch sử, xuất báo cáo. Cảnh báo theo thời gian.

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `SpecializationCourses` | Khóa học chuyên môn | 🟢 *Professional Training Class* *(xem UID04)* |
| └── `SpecializationCourseDetails` | Kết quả từng học viên | 🟢 *Training Class Enrollment* *(xem UID04)* |

---

## UID11–12 — Tiện ích & Quản lý tích hợp

UID11: Thông báo nhắc việc xử lý hồ sơ, dashboard thống kê. UID12: Cấu hình tích hợp với MCĐT, Cổng BCTT, C06, các phân hệ CTCK/QLQ. Không tạo bảng nghiệp vụ riêng — sử dụng `SystemParameters` và các bảng đã có.

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `SystemParameters` | Cấu hình kết nối tích hợp | 🔴 (Out of scope) *Config data* |

---

## Phụ lục: Danh mục dùng chung

Các bảng danh mục được tham chiếu xuyên suốt nhiều UID:

| Bảng | Ý nghĩa | Sử dụng bởi | Ánh xạ Silver |
|---|---|---|---|
| `Certificates` | Loại chứng chỉ hành nghề (MGCK, PTTC, QLQ) | UID02, UID03, UID04, UID05, UID06 | 🟢 `CV: CERTIFICATE_TYPE` |
| `Specializations` | Chuyên môn (CPA, CFA...) | UID02, UID03, UID04, UID10 | 🟢 `CV: SPECIALIZATION` |
| `Documents` | Loại tài liệu hồ sơ | UID02, UID03 | 🟢 `CV: DOCUMENT_TYPE` |
| `EducationLevels` | Trình độ học vấn | UID02, UID06 | 🟢 `CV: EDUCATION_LEVEL` |
| `ApplicationStatuses` | Trạng thái hồ sơ | UID02, UID03 | 🟢 `CV: APPLICATION_STATUS` |
| `ApplicationSources` | Hình thức nộp hồ sơ | UID02, UID03, UID04 | 🟢 `CV: APPLICATION_SOURCE` |
| `Positions` | Chức vụ trong tổ chức | UID01 | 🟢 `CV: POSITION` |
| `Decisions` | Quyết định hành chính UBCKNN | UID02, UID04, UID05, UID06 | 🟢 *Securities Practitioner License Decision Document* |
| `Organizations` | Tổ chức CTCK/QLQ/NH | UID02, UID03, UID06 | 🟢 *Securities Organization Reference* |
| `Users` | Cán bộ/chuyên viên UBCKNN | UID01, UID03, UID04, UID05 | 🟢 *Regulatory Authority Officer* |
| `Units` | Đơn vị UBCKNN | UID01 | 🟢 *Regulatory Authority Organization Unit* |
| `Departments` | Phòng ban UBCKNN | UID01 | 🟢 *Regulatory Authority Organization Unit* |
