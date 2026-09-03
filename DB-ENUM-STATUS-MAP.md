# Tra cứu map trạng thái / loại — Code-New-TT

> **Mục đích:** Liệt kê các cột Oracle lưu **mã số** (NUMBER) hoặc **chuỗi enum** mà **không có bảng tra cứu riêng** trên DB — giá trị được map trong **Java enum** (`nhnck-service/.../common/enums/`).
>
> **Ngược lại:** Một số trường dùng **bảng danh mục** trên DB (xem mục 1).
>
> **Cập nhật:** rà soát từ source Code-New-TT (CMS BE + Portal BE).

---

## 1. Các trường CÓ bảng map trên DB (ngoại lệ)

| Bảng | Cột | Bảng tra cứu | Ghi chú |
|------|-----|--------------|---------|
| `APPLICATIONS` | `STATUS_ID` | **`APPLICATION_STATUSES`** | `STATUS_CODE` (HS01…HS12), `STATUS_NAME`, `LABEL` |
| `VERIFY_APPLICATION_STATUSES` | `STATUS_ID`, `PREV_STATUS_ID` | **`APPLICATION_STATUSES`** | FK sang trạng thái hồ sơ |
| `APPLICATIONS` | (nguồn hồ sơ) | **`APPLICATION_SOURCES`** | Danh mục CODE/NAME/LABEL — không phải enum |
| Danh mục địa lý, chứng chỉ, giấy tờ… | `*_ID` | `COUNTRIES`, `PROVINCES`, `CERTIFICATES`, `DOCUMENTS`… | Master data, không phải enum map |

**Bridge enum (chỉ trong code, không phải bảng):** `IssueApplicationStatusEnum` map số 1–12 ↔ `STATUS_CODE` HS01–HS12 trong `APPLICATION_STATUSES`.

| Value | Status code | Mô tả ngắn |
|------:|-------------|------------|
| 1 | HS01 | Chờ phân công |
| 2 | HS02 | Chờ thẩm định |
| 3 | HS03 | Chờ bổ sung |
| 4 | HS04 | Hợp lệ |
| 5 | HS05 | Chờ thi |
| 6 | HS06 | Đậu |
| 7 | HS07 | Chờ xác nhận chuyên môn |
| 8 | HS08 | Chờ xác nhận TCQ |
| 9 | HS09 | Chờ cấp CC |
| 10 | HS10 | Hoàn thành |
| 11 | HS11 | Từ chối |
| 12 | HS12 | Thi lại |

Tra cứu đầy đủ trên DB:

```sql
SELECT ID, STATUS_CODE, STATUS_NAME, LABEL
FROM APPLICATION_STATUSES
ORDER BY SORT_ORDER, ID;
```

---

## 2. Map theo bảng nghiệp vụ (enum trong code)

### 2.1 Chuyển đổi chứng chỉ

| Bảng | Cột | Enum Java | File enum |
|------|-----|-----------|-----------|
| `CERTIFICATE_CONVERSION_REQUESTS` | `STATUS` | `ConversionRequestStatusEnum` | `common/enums/ConversionRequestStatusEnum.java` |
| `VERIFY_CERTIFICATE_CONVERSION_STATUSES` | `STATUS` | `StatusConfirmStatusApplicationEnum` | `common/enums/StatusConfirmStatusApplicationEnum.java` |
| `VERIFY_CERTIFICATE_CONVERSION_STATUSES` | `TARGET_STATUS`, `PREV_STATUS` | `ConversionRequestStatusEnum` | (cùng enum) |
| `CERTIFICATE_RECORDS` | `STATUS` | `CertificateRecordStatusEnum` | `common/enums/CertificateRecordStatusEnum.java` |
| `CERTIFICATE_RECORDS` | `CONVERSION_STATUS` | `ConversionStatusEnum` | `common/enums/ConversionStatusEnum.java` |
| `CERTIFICATE_RECORDS` | `PROCESS_STATUS` | `CertificateProcessStatusEnum` | `common/enums/CertificateProcessStatusEnum.java` |
| `CERTIFICATE_RECORD_GROUPS` | `STATUS` | `CertificateRecordGroupStatusEnum` | `common/enums/CertificateRecordGroupStatusEnum.java` |
| `CERTIFICATE_RECORD_GROUPS` | `TYPE` | `CertificateRecordGroupTypeEnum` | `common/enums/CertificateRecordGroupTypeEnum.java` |

**Label CMS** (`ConversionRequestCodes.statusLabel`):

| Value | Enum | Label CMS |
|------:|------|-----------|
| 1 | PENDING | Chờ LĐCM phân công |
| 2 | PROCESSING | Chờ thẩm định |
| 3 | COMPLETED | Hoàn thành |
| 4 | REJECTED | Không hợp lệ |
| 5 | WAITING_UPDATE | Chờ bổ sung |
| 6 | VALID | Hợp lệ — chờ gom nhóm |
| 7 | IN_GROUP | Đã trong nhóm |
| 8 | DRAFT | Đang soạn hồ sơ |

**Label Portal** (có thể khác CMS):

| Value | Label Portal |
|------:|--------------|
| 1 | Đã gửi, chờ xử lý |
| 2 | Đang thẩm định |
| 3 | Hoàn thành |
| 4 | Từ chối |
| 5 | Chờ bổ sung |
| 6 | Hợp lệ |
| 7 | Trong nhóm chuyển đổi |
| 8 | Đang soạn hồ sơ |

---

### 2.2 Hồ sơ cấp mới / thi / phí

| Bảng | Cột | Enum Java |
|------|-----|-----------|
| `APPLICATION_GROUPS` | `STATUS` | `ApplicationGroupStatusEnum` |
| `APPLICATION_DOCUMENTS` | `STATUS` | `StatusAppraisalEnum` |
| `APPLICATION_SPECIALIZATIONS` | `STATUS` | `StatusAppraisalEnum` |
| `APPLICATION_FEES` | `STATUS` | `StatusFeeEnum` |
| `APPLICATION_FEES` | `FEE_TYPE` | `TypeFeeEnum` |
| `APPLICATIONS` | `APPLICATION_TYPE` | `TypeApplicationEnum` |
| `APPLICATIONS` | `REGISTRATION_TYPE` | `TypeRegistrationApplicationEnum` |
| `VERIFY_APPLICATION_STATUSES` | `STATUS` | `StatusConfirmStatusApplicationEnum` |
| `APPLICATION_RE_EXAMS` | `STATUS` | `StatusReApplicationEnum` |
| `EXAM_SESSIONS` | `STATUS` | `ExamSessionStatusEnum` |
| `EXAM_DETAILS` | `RESULT` | `ExamDetailResultEnum` |

---

### 2.3 Quyết định / ký số

| Bảng | Cột | Enum Java |
|------|-----|-----------|
| `DECISION_DOCUMENTS` | `TYPE` | `DecisionDocumentTypeEnum` |
| `DECISION_DOCUMENTS` | `STATUS` | `SignEdocStatusEnum` |

---

### 2.4 Tổ chức / báo cáo / người hành nghề

| Bảng | Cột | Enum Java |
|------|-----|-----------|
| `ORGANIZATIONS` | `STATUS` | `StatusOrganizationEnum` |
| `ORGANIZATIONS` | `TYPE` | `TypeOrganizationEnum` |
| `ORGANIZATION_REPORTS` | `STATUS` | `OrganizationReportStatusEnum` |
| `ORGANIZATION_REPORTS` | `STATUS_ORGANIZATION` | `OrganizationReportStatusEnum` |
| `ORGANIZATION_REPORTS` | `TYPE` | `TypeOrganizationReportEnum` |
| `ORGANIZATION_REPORTS` | `SUB_TYPE` | `OrganizationReportSubTypeEnum` (HIRE / TERMINATION) |
| `ORGANIZATION_REPORT_YEARLYS` | `STATUS` | `StatusCompareOrgReportEnum` |
| `PROFESSIONALS` | `STATUS` | `StatusProfessionalEnum` |
| `PROFESSIONALS` | `STATUS_WORK` | `StatusWorkProfessionalEnum` |
| `PROFESSIONALS` | `STATUS_ACCOUNT` | `StatusAccountProfessionalEnum` |
| `PROFESSIONALS` | `GENDER` | `GenderEnum` |
| `VIOLATIONS` | `STATUS` | `StatusEnumInput` |
| `VIOLATIONS` | `TYPE` | `ViolationTypeEnum` |
| `POST_CERT_TRAINING_RESULTS` | `STATUS` | `PostCertTrainingResultStatusEnum` |
| `REPORT_TEMPLATES` | `STATUS` | `RptTempStatusEnum` |

---

### 2.5 Danh mục dùng chung `StatusEnum` (Active/Inactive)

Cột `STATUS`: **0 = INACTIVE, 1 = ACTIVE** — enum `StatusEnum`.

Áp dụng cho (không đầy đủ): `USERS`, `ROLES`, `DOCUMENTS`, `CERTIFICATES`, `SPECIALIZATIONS`, `PROVINCES`, `DISTRICTS`, `DEPARTMENTS`, `POSITIONS`, `UNITS`, `EDUCATION_LEVELS`, `COUNTRIES`, `APPLICATION_SOURCES`, `SPECIALIZATION_COURSES`, `DIGITAL_CERTIFICATES`, `DIGITAL_CERTIFICATE_USERS`, …

---

### 2.6 Chưa có enum rõ trong code

| Bảng | Cột | Ghi chú |
|------|-----|---------|
| `APPLICATION_GROUP_MEMBERS` | `STATUS` | `Integer`, default 1 — không thấy enum |
| `CERTIFICATE_RECORD_GROUP_MEMBERS` | `STATUS` | `Integer`, default 1 — không thấy enum |

---

## 3. Bảng giá trị enum chi tiết

### ConversionRequestStatusEnum (Chưa dùng)

| Value | Constant |
|------:|----------|
| 1 | PENDING |
| 2 | PROCESSING |
| 3 | COMPLETED |
| 4 | REJECTED |
| 5 | WAITING_UPDATE |
| 6 | VALID |
| 7 | IN_GROUP |
| 8 | DRAFT |

### CertificateRecordStatusEnum (NHNCK.CERTIFICATE_RECORDS.STATUS)

| Value | Constant | Mô tả (comment code) |
|------:|----------|----------------------|
| 0 | NOT_USED | Chưa sử dụng |
| 1 | IN_USE | Đang sử dụng |
| 2 | REVOKED_REISSUABLE | Thu hồi có cấp lại |
| 3 | REVOKED_PERMANENT | Thu hồi không cấp lại |
| 4 | CANCELLED | Đã hủy |
| 5 | EXPIRED | Hết hiệu lực |

### ConversionStatusEnum (NHNCK.CERTIFICATE_RECORDS.CONVERSION_STATUS)

| Value | Constant | Mô tả |
|------:|----------|-------|
| 1 | PAPER | Chứng chỉ giấy |
| 2 | PENDING_DIGITAL_CONVERSION | Chờ chuyển đổi điện tử |
| 3 | DIGITAL | Chứng chỉ số |

### CertificateProcessStatusEnum (NHNCK.CERTIFICATE_RECORDS.PROCESS_STATUS)

| Value | Constant | Mô tả |
|------:|----------|-------|
| 1 | ISSUED | Đã cấp |
| 2 | FLASHING_SIGNED | Đã ký nháy |
| 3 | SIGNED | Đã ký |
| 4 | DELIVERED | Đã trả |

### CertificateRecordGroupStatusEnum (NHNCK.CERTIFICATE_RECORD_GROUPS.STATUS)

| Value | Constant | Label (getDisplayName) |
|------:|----------|------------------------|
| -1 | REJECTED | Từ chối |
| 0 | CREATED | Tạo mới |
| 1 | PENDING_CM_APPROVAL | Chờ Lãnh đạo CM duyệt |
| 2 | PENDING_UBCK_APPROVAL | Chờ Lãnh đạo UBCK duyệt |
| 3 | REVOKED | Hoàn thành *(label code)* |
| 4 | CANCELLED | Hoàn thành *(label code)* |
| 5 | COMPLETED | Hoàn thành ký số |
| 6 | CONVERTED | Đã Chuyển đổi |

### CertificateRecordGroupTypeEnum (NHNCK.CERTIFICATE_RECORD_GROUPS.TYPE)

| Value | Constant | Label |
|------:|----------|-------|
| 1 | REVOCATION | Thu hồi |
| 2 | CANCELLATION | Hủy |
| 3 | CONVERSION | Chuyển đổi |

### ApplicationGroupStatusEnum (NHNCK.APPLICATION_GROUPS.STATUS)

| Value | Constant |
|------:|----------|
| -1 | REJECTED |
| 0 | CREATED |
| 1 | PENDING_CM_APPROVAL |
| 2 | PENDING_UBCK_APPROVAL |
| 3 | APPROVED |
| 4 | COMPLETED |

### StatusAppraisalEnum (NHNCK.APPLICATION_SPECIALIZATIONS.STATUS)

| Value | Constant |
|------:|----------|
| 0 | RECEPTED |
| 1 | CONFIRMED |
| 2 | RESUPPLY |
| 3 | REJECTED |

### StatusFeeEnum (NHNCK.APPLICATION_FEES.STATUS)

| Value | Constant | Mô tả |
|------:|----------|-------|
| 0 | NOT_SUBMIT | Chưa nộp |
| 1 | WAITING_CONFIRM | Chờ xác nhận |
| 2 | SUBMITTED | Đã nộp |
| 3 | REJECTED | Từ chối |

### TypeFeeEnum (NHNCK.APPLICATION_FEES.FEE_TYPE)

| Value | Constant | Mô tả |
|------:|----------|-------|
| 1 | EXAM | Thi |
| 2 | APPEAL | Phúc khảo |
| 3 | CERTIFICATE | Phí cấp chứng chỉ |

### TypeApplicationEnum (NHNCK.APPLICATIONS.APPLICATION_TYPE)

| Value | Constant | Mô tả |
|------:|----------|-------|
| 0 | ISSUE_NEW | Cấp mới |
| 1 | RE_ISSUE_NEW | Cấp lại do thu hồi |
| 2 | RE_ISSUE_UPDATE_INFO | Cấp lại thay đổi thông tin |
| 3 | RE_ISSUE_LOSS_CER | Cấp lại do mất CC |

### TypeRegistrationApplicationEnum (NHNCK.APPLICATIONS.REGISTRATION_TYPE)

| Value | Constant |
|------:|----------|
| 0 | MCDT |
| 1 | MANUAL |

### StatusConfirmStatusApplicationEnum (NHNCK.VERIFY_APPLICATION_STATUSES.STATUS)

| Value | Constant |
|------:|----------|
| 0 | WAITING_CONFIRM_OVERVIEW |
| 1 | REJECTED_CONFIRM_OVERVIEW |
| 2 | WAITING_CONFIRM_SPEC |
| 3 | WAITING_CONFIRM_ORG |
| 4 | REJECTED_SPEC |
| 5 | REJECTED_ORG |
| 6 | CONFIRMED |

### StatusReApplicationEnum (NHNCK.APPLICATION_RE_EXAMS.STATUS)

| Value | Constant |
|------:|----------|
| 1 | RE_EXAM |
| 2 | SUBMITTED |
| 3 | DOING |
| 4 | PASS |
| 5 | FAIL |
| 6 | EXPIRED |
| 7 | REJECTED |

### ExamSessionStatusEnum (NHNCK.EXAM_SESSIONS.STATUS)

| Value | Constant |
|------:|----------|
| -1 | CANCELLED |
| 1 | CREATED |
| 2 | IN_PROGRESS |
| 3 | COMPLETED |

### ExamDetailResultEnum (NHNCK.EXAM_DETAILS.RESULT)

| Value | Constant | Label |
|------:|----------|-------|
| -1 | NOT_TAKE | Chưa thi |
| 0 | FAIL | Không đạt |
| 1 | PASS | Đạt |

### DecisionDocumentTypeEnum (NHNCK.DECISION_DOCUMENTS.TYPE)

| Value | Constant |
|------:|----------|
| 0 | ISSUE_CERTIFICATE_DOC |
| 1 | DECISION_DOC |
| 2 | OTHER_DOCUMENT |

### SignEdocStatusEnum (NHNCK.DECISION_DOCUMENTS.STATUS)

| Value | Constant |
|------:|----------|
| 0 | INIT |
| 1 | EMPLOYEE_FLASH_SIGNED |
| 2 | FLASH_SIGNED |
| 3 | SIGNED |
| 4 | COMPLETED |

### OrganizationReportStatusEnum (NHNCK.ORGANIZATION_REPORTS.STATUS)

| Value | Constant | Mô tả |
|------:|----------|-------|
| -1 | REJECTED | Từ chối |
| 0 | DRAFT | Bản nháp |
| 1 | PENDING | Chờ duyệt |
| 2 | APPROVED | Đã duyệt |

### TypeOrganizationReportEnum (NHNCK.ORGANIZATION_REPORTS.TYPE)

| Value | Constant |
|------:|----------|
| 0 | UPDATE |
| 1 | YEARLY |

### OrganizationReportSubTypeEnum (Chưa dùng)

| Constant | Mô tả |
|----------|-------|
| HIRE | Ký kết HĐ |
| TERMINATION | Chấm dứt HĐ |

*(Lưu string vào DB, không phải số.)*

### StatusCompareOrgReportEnum (NHNCK.ORGANIZATION_REPORT_YEARLYS.STATUS)

| Value | Constant |
|------:|----------|
| 0 | WAIT_COMPARE |
| 1 | COMPARED |

### StatusOrganizationEnum (NHNCK.ORGANIZATIONS.STATUS)

| Value | Constant | Mô tả |
|------:|----------|-------|
| 0 | INACTIVE | Chưa hoạt động |
| 1 | ACTIVE | Đang hoạt động |
| 2 | PAUSE | Tạm dừng |
| 3 | DISSOLUTION | Giải thể |

### TypeOrganizationEnum (NHNCK.ORGANIZATIONS.ORGANIZATIONS_TYPE)

| Value | Constant | Mô tả |
|------:|----------|-------|
| 0 | OTHER | Khác |
| 1 | STOCK | CTCK |
| 2 | FUND | QLQ |
| 3 | BANK | Ngân hàng |

### StatusProfessionalEnum (NHNCK.PROFESSIONALS.STATUS)

| Value | Constant |
|------:|----------|
| 0 | INACTIVE |
| 1 | ACTIVE |
| 2 | UNKNOW |

### StatusWorkProfessionalEnum (NHNCK.PROFESSIONALS.STATUS_WORK)

| Value | Constant | Mô tả |
|------:|----------|-------|
| 0 | NOT_WORK | Chưa hành nghề |
| 1 | WORK | Đang hành nghề |
| 2 | RECALL_REFUND | Thu hồi có cấp lại |
| 3 | RECALL | Thu hồi không cấp lại |
| 4 | STOPPED | Cấp HN có thời hạn |

### StatusAccountProfessionalEnum (NHNCK.PROFESSIONALS.STATUS_ACCOUNT)

| Value | Constant | Mô tả |
|------:|----------|-------|
| 0 | INACTIVE | Chưa kích hoạt |
| 1 | ACTIVE | Đang hoạt động |
| 2 | LOCKED | Khóa |

### GenderEnum (Đồng bộ theo ECAT.GENDER 0: Không xác định; 1: Name; 2: Nữ)

| Value | Constant |
|------:|----------|
| 0 | MALE |
| 1 | FEMALE |

### StatusEnumInput (NHNCK.VIOLATIONS.STATUS)

| Value | Constant |
|------:|----------|
| -1 | DELETED |
| 0 | INACTIVE |
| 1 | ACTIVE |

### StatusEnum (danh mục chung)

| Value | Constant |
|------:|----------|
| 0 | INACTIVE |
| 1 | ACTIVE |

### ViolationTypeEnum (NHNCK.VIOLATIONS.TYPE)

| Value | Constant |
|------:|----------|
| 1 | ADMINISTRATIVE |
| 2 | LEGAL |

### PostCertTrainingResultStatusEnum (Chưa dùng)

| Value | Constant | Label |
|------:|----------|-------|
| 0 | INCOMPLETE | Chưa hoàn thành |
| 1 | COMPLETED | Hoàn thành |

### PostCertTrainingComplianceStatusEnum (Chưa dùng)

| Constant | Mô tả |
|----------|-------|
| MET | Đáp ứng |
| NOT_MET | Không đáp ứng |
| EXEMPT | Miễn |

*(String enum, không phải số.)*

### RptTempStatusEnum (Chưa dùng)

| Value | Constant | Label |
|------:|----------|-------|
| 0 | DRAFT | Bản nháp |
| 1 | ACTIVE | Đang sử dụng |
| 2 | UNACTIVE | Không sử dụng |
| 3 | PENDING | Chờ sử dụng |

### RptMemberStatusEnum (Chưa dùng)

| Value | Constant | Label |
|------:|----------|-------|
| 1 | DRAFT | Chưa gửi |
| 2 | SUBMITTED | Đã gửi |
| 3 | SUBMITTED_LATE | Gửi muộn |
| 4 | REJECTED | Bị hủy |
| 5 | SENT_BACK | Đã gửi lại |

### ApplicationWarningStatusEnum (Chưa dùng)

| Value | Constant |
|------:|----------|
| 0 | PENDING |
| 1 | EXPIRED |
| 2 | CONFIRMED |
| 3 | REJECTED |

---

## 4. Enum khác (ít gặp khi query DB trực tiếp)

| Enum | Ghi chú |
|------|---------|
| `RequestSourceSystemEnum` | Nguồn request tích hợp |
| `RequestTypeEnum` | Loại request log |
| `NotificationTypeEnum`, `NotificationActionTypeEnum`, `NotificationAlertTypeEnum` | Thông báo |
| `ReportGroupsEnum`, `PeriodTypeEnum` | Báo cáo |
| `MemberProfileTypeEnum` | Loại hồ sơ thành viên |
| `TypeSignedEnum`, `TypeRelationshipEnum`, `TypeAccountEnum`, `TypeDataEnum` | Metadata |
| `ConversionRequestSectionEnum` | Section payload chuyển đổi (code, không cột DB) |
| `StatusVerifyEnum` | 0 REJECTED, 1 VERIFIED |
| `WarningHeaderApplicationStatusEnum` | Cảnh báo header hồ sơ |
| `SystemObjectEnum`, `SysVarsEnum`, `SystemDaysOfWeekEnum` | Hệ thống / tham số |


> **Mục đích:** Chi tiết giá trị các enum **ít gặp khi query DB trực tiếp** — bổ sung cho [DB-ENUM-STATUS-MAP.md](./DB-ENUM-STATUS-MAP.md) mục 4.
>
> **Nguồn:** `nhnck-service/src/main/java/com/tinhvan/nhnckservice/common/enums/`
>
> **Quy ước:** Enum implement `BaseEnum<Integer>` → cột DB thường lưu **NUMBER (Integer)**. Enum không có `value` → chỉ dùng **string code** trong payload/API.

---

## Lưu ý chung khi query DB

| Quy tắc | Chi tiết |
|---------|----------|
| Kiểu lưu trữ | Hầu hết enum dưới đây → **INTEGER** (JPA `GenericEnumConverter`) |
| Không phải cột DB | `ConversionRequestSectionEnum` — chỉ code string trong API |
| `SysVarsEnum` | Là **mã loại** tham số hệ thống (1–34); giá trị thực nằm bảng `SYSTEM_PARAMETERS` |
| Dễ nhầm | `TypeSignedEnum` (0/1, log ký) **≠** `CERTIFICATE_RECORDS.PROCESS_STATUS` (1/2/3/4) |
| Hai enum thông báo | `NotificationTypeEnum` (legacy NDTNN) **≠** `NotificationAlertTypeEnum` (NOTI/WARNING) |

---

## RequestSourceSystemEnum

**Ghi chú:** Nguồn request tích hợp.

| Value | Constant | Mô tả |
|------:|----------|-------|
| 1 | `MCDT` | MCĐT |
| 2 | `FMS` | FMS |
| 3 | `SCMS` | SCMS |
| 4 | `C06` | C06 |
| 5 | `THANH_TRA` | Thanh tra |

**File:** `RequestSourceSystemEnum.java`

---

## RequestTypeEnum

**Ghi chú:** Loại request log.

| Value | Constant | Mô tả |
|------:|----------|-------|
| 1 | `RECEIVE` | Nhận |
| 2 | `SEND` | Gửi |

**File:** `RequestTypeEnum.java`

---

## NotificationTypeEnum

**Ghi chú:** Loại thông báo (legacy NDTNN / thành viên thị trường).

| Value | Constant | Title |
|------:|----------|-------|
| 1 | `MEMBER_CHANGE_INFOR` | Thành viên thị trường thay đổi thông tin trong hồ sơ của thành viên |
| 2 | `MEMBER_SEND_REPORT` | Thành viên thị trường gửi báo cáo lên hệ thống |
| 3 | `MEMBER_PUBLISH` | Thành viên thị trường gửi công bố thông tin trên hệ thống |
| 4 | `MEMBER_INFOR_EXCHANGE` | Thành viên thị trường gửi tin nhắn trao đổi |
| 5 | `WARNING_VIOLT` | Cảnh báo vi phạm tham số cảnh báo của hệ thống |
| 6 | `UBCK_DESTROY_REPORT` | UBCK huỷ báo cáo |
| 7 | `WARNING_CERTIFICATE_EXPIRED` | Cảnh báo hết hạn chứng thư số |
| 8 | `UBCK_INFOR_EXCHANGE` | UBCK gửi tin nhắn trao đổi |
| 9 | `UBCK_ACTIVE_RPTTEMP` | UBCK đưa biểu mẫu mới vào sử dụng |
| 10 | `UBCK_SEND_NOTIFI` | Thông báo từ UBCK gửi đến đối tượng gửi báo cáo |
| 11 | `UBCK_USER_NOTI` | Thông báo tài khoản |

**File:** `NotificationTypeEnum.java`

---

## NotificationActionTypeEnum

**Ghi chú:** Loại sự kiện thông báo NHNCK (parity C#).

| Value | Constant | Title |
|------:|----------|-------|
| 1 | `NEW_APPLICATION_RECEIVED` | Tiếp nhận hồ sơ mới |
| 2 | `APPLICATION_ASSIGNED` | Phân công thụ lý hồ sơ |
| 3 | `DOCUMENT_REVIEW_ASSIGNED` | Phân công thẩm định hồ sơ |
| 4 | `APPLICATION_UPDATE_NOTIFICATION` | Thông báo cập nhật hồ sơ đang phụ trách |
| 5 | `PROFESSIONAL_INACTIVE_3_YEARS_WARNING` | Cảnh báo người hành nghề không làm việc liên tục trong 3 năm |
| 6 | `PROFESSIONAL_MULTIPLE_ORGANIZATIONS_WARNING` | Cảnh báo người hành nghề làm việc tại nhiều tổ chức cùng một thời điểm |
| 7 | `CERTIFICATE_FEE_OVERDUE_WARNING` | Cảnh báo người hành nghề chưa nộp phí cấp chứng chỉ quá 1 năm |
| 8 | `LEADER_REJECTED_APPLICATION` | Lãnh đạo từ chối duyệt hồ sơ |

**File:** `NotificationActionTypeEnum.java`

---

## NotificationAlertTypeEnum

**Ghi chú:** Phân loại thông báo / cảnh báo (NOTI vs WARNING).

| Value | Constant | Title |
|------:|----------|-------|
| 1 | `NOTI` | Thông báo |
| 2 | `WARNING` | Cảnh báo |

**File:** `NotificationAlertTypeEnum.java`

---

## ReportGroupsEnum

**Ghi chú:** Nhóm báo cáo.

| Value | Constant | Title |
|------:|----------|-------|
| 1 | `FUND_MANAGEMENT_REPORT` | Báo cáo công ty QLQ |
| 2 | `SECURITIES_COMPANY_REPORT` | Báo cáo công ty chứng khoán |
| 3 | `BANK_MONI_REPORT` | Báo cáo ngân hàng lưu ký |
| 4 | `DEPOSITORY_CENTER_REPORT` | Báo cáo Tổng công ty Lưu ký và Bù trừ chứng khoán VN |
| 5 | `STOCK_EXCHANGE_REPORT` | Báo cáo sở giao dịch chứng khoán |
| 6 | `INFORMATION_DISCLOSURE_REPRESENTATIVE_REPORT` | Báo cáo người đại diện công bố thông tin |
| 7 | `BRANCH_REPORT` | Báo cáo chi nhánh công ty QLQ nước ngoài tại Việt Nam |
| 8 | `OTHER` | Khác |

**File:** `ReportGroupsEnum.java`

---

## PeriodTypeEnum

**Ghi chú:** Kỳ báo cáo.

| Value | Constant | Title |
|------:|----------|-------|
| 1 | `PERIOD_DATE` | Báo cáo ngày |
| 2 | `PERIOD_WEEK` | Báo cáo tuần |
| 3 | `PERIOD_HALF_MONTH` | Báo cáo nửa tháng |
| 4 | `PERIOD_MONTH` | Báo cáo tháng |
| 5 | `PERIOD_QUARTER` | Báo cáo quý |
| 6 | `PERIOD_HALF_A_YEAR` | Báo cáo bán niên |
| 7 | `PERIOD_YEAR` | Báo cáo năm |

**File:** `PeriodTypeEnum.java`

---

## MemberProfileTypeEnum

**Ghi chú:** Loại profile thành viên.

| Value | Constant | Title |
|------:|----------|-------|
| 1 | `INVESTOR_LIST` | Danh sách nhà đầu tư |
| 2 | `NATIONALITY_COUNTRY_LIST` | Danh sách quốc tịch/Quốc gia |
| 3 | `FOREIGN_INVESTOR_TYPE_LIST` | Danh sách loại hình NĐT NN |
| 4 | `SECURITIES_LIST` | Danh sách chứng khoán |

**File:** `MemberProfileTypeEnum.java`

---

## TypeSignedEnum

**Ghi chú:** Loại ký trong log chữ ký (`SIGNATURE_LOGS.TYPE`).

| Value | Constant | Mô tả |
|------:|----------|-------|
| 0 | `FLASHING_SIGNED` | Ký nháy |
| 1 | `SIGNED` | Ký chính thức |

> **Cảnh báo:** Không nhầm với `CERTIFICATE_RECORDS.PROCESS_STATUS`:
>
> | PROCESS_STATUS | Ý nghĩa |
> |---------------:|---------|
> | 1 | ISSUED — chờ ký nháy |
> | 2 | FLASHING_SIGNED |
> | 3 | SIGNED |
> | 4 | STAMPED / DELIVERED |

**File:** `TypeSignedEnum.java`

---

## TypeRelationshipEnum (NHNCK.PROFESSIONAL_RELATIONSHIPS.RELATIONSHIP_TYPE)

**Ghi chú:** Loại quan hệ gia đình.

| Value | Constant | Mô tả |
|------:|----------|-------|
| 1 | `HUSBAND_OR_WIFE` | Chồng hoặc vợ |
| 2 | `CHILDRENT` | Con |
| 3 | `FATHER` | Bố |
| 4 | `MOTHER` | Mẹ |
| 5 | `GRAND_FATHER` | Ông |
| 6 | `GRAND_MOTHER` | Bà |

**File:** `TypeRelationshipEnum.java`

---

## TypeAccountEnum

**Ghi chú:** Loại tài khoản đăng nhập.

| Value | Constant | Mô tả |
|------:|----------|-------|
| 0 | `LOCAL` | Tài khoản local |
| 1 | `LDAP` | LDAP |

**File:** `TypeAccountEnum.java`

---

## TypeDataEnum

**Ghi chú:** Phân loại dữ liệu mới / cũ.

| Value | Constant | Mô tả |
|------:|----------|-------|
| 0 | `OLD` | Dữ liệu cũ |
| 1 | `NEW` | Dữ liệu mới |

**File:** `TypeDataEnum.java`

---

## ConversionRequestSectionEnum

**Ghi chú:** Hạng mục thẩm định hồ sơ chuyển đổi — **không có value số**, chỉ string code trong payload/API.

| Code (string) | Mô tả |
|---------------|-------|
| `CERTIFICATE` | Chứng chỉ |
| `WORK_HISTORY` | Quá trình công tác |
| `OTHER_DOCUMENT` | Tài liệu khác |

**File:** `ConversionRequestSectionEnum.java`

---

## StatusVerifyEnum

**Ghi chú:** Hành động xác minh.

| Value | Constant | Mô tả |
|------:|----------|-------|
| 0 | `REJECTED` | Từ chối |
| 1 | `VERIFIED` | Đã xác minh |

**File:** `StatusVerifyEnum.java`

---

## WarningHeaderApplicationStatusEnum

**Ghi chú:** Trạng thái cảnh báo trên header hồ sơ.

| Value | Constant | Mô tả |
|------:|----------|-------|
| 0 | `NONE` | Không cảnh báo |
| 1 | `RE_EXAM` | Thi lại |

**File:** `WarningHeaderApplicationStatusEnum.java`

---

## SystemObjectEnum

**Ghi chú:** Đối tượng / loại thực thể trong hệ thống.

| Value | Constant | Title |
|------:|----------|-------|
| 0 | `UBCK` | Uỷ ban chứng khoán nhà nước |
| 1 | `FUND_MANAGEMENT` | Công ty QLQ |
| 2 | `SECURITIES_COMPANY` | Công ty chứng khoán |
| 3 | `BANK_MONI` | Ngân hàng lưu ký |
| 4 | `DEPOSITORY_CENTER` | Tổng công ty Lưu ký và Bù trừ chứng khoán VN |
| 5 | `STOCK_EXCHANGE` | Sở giao dịch chứng khoán |
| 6 | `INFORMATION_DISCLOSURE_REPRESENTATIVE` | Người đại diện công bố thông tin |
| 7 | `BRANCHE` | Chi nhánh nước ngoài tại Việt Nam |
| 8 | `OTHER` | Khác |
| 9 | `INVESTOR` | Nhà đầu tư |
| 10 | `INVESTOR_TYPE` | Loại nhà đầu tư |
| 11 | `SECURITIES` | Chứng khoán |

**File:** `SystemObjectEnum.java`

---

## SysVarsEnum

**Ghi chú:** Mã biến cấu hình hệ thống (ID loại tham số). Giá trị cấu hình thực tế tra bảng `SYSTEM_PARAMETERS` theo `PARAMETER_CODE`.

| Value | Constant | Mô tả ngắn |
|------:|----------|------------|
| 1 | `LINKSYSTEMFIMS` | Link hệ thống FIMS |
| 2 | `HOTLINE` | Hotline |
| 3 | `FILESIZE` | Giới hạn kích thước file |
| 4 | `MAIL_SERVER` | Host mail |
| 5 | `MAIL_PORT` | Port mail |
| 6 | `MAIL_USER` | User mail |
| 7 | `MAIL_PASSWORD` | Password mail |
| 8 | `MAIL_CC` | Mail CC |
| 9 | `MAIL_BCC` | Mail BCC |
| 10 | `IP_UNACCESS` | Danh sách IP bị khóa |
| 11 | `MAIL_CONTENT_FORGOTPASSWORD` | Nội dung mail quên mật khẩu |
| 12 | `MAIL_CONTENT_CERTIFICATE_EXPIRED` | Nội dung mail hết hạn CTS |
| 13 | `MAIL_CONTENT_SENDMAKENOTICE_ACCOUNT` | Nội dung mail cấp tài khoản |
| 14 | `DATE_CONFIG_GEN_REPORT_DAY` | Lịch sinh báo cáo — ngày |
| 15 | `DATE_CONFIG_GEN_REPORT_WEEK` | Lịch sinh báo cáo — tuần |
| 16 | `DATE_CONFIG_GEN_REPORT_HAFTMONTH` | Lịch sinh báo cáo — nửa tháng |
| 17 | `DATE_CONFIG_GEN_REPORT_MONTH` | Lịch sinh báo cáo — tháng |
| 18 | `DATE_CONFIG_GEN_REPORT_QUARTER` | Lịch sinh báo cáo — quý |
| 19 | `DATE_CONFIG_GEN_REPORT_HAFTYEAR` | Lịch sinh báo cáo — bán niên |
| 20 | `DATE_CONFIG_GEN_REPORT_YEAR` | Lịch sinh báo cáo — năm |
| 21 | `LOGIN_CONFIG_CAPTCHA` | Cấu hình captcha đăng nhập |
| 22 | `SYSTEM_TIMEOUT` | Timeout hệ thống |
| 23 | `PASSWORD_RULE_NOT_ACCOUNT` | MK không chứa tên TK |
| 24 | `PASSWORD_RULE_CHARACTER` | Quy tắc ký tự MK |
| 25 | `PASSWORD_RULE_LOCK` | Khóa TK khi MK hết hạn |
| 26 | `PASSWORD_RULE_LIMIT` | Giới hạn lần đăng nhập sai |
| 27 | `PASSWORD_RULE_UNLOCK_ACCOUNT` | Mở khóa khi đổi MK thành công |
| 28 | `PASSWORD_RULE_TIME_ACTIVE` | Thời gian MK hợp lệ |
| 29 | `PASSWORD_RULE_TIME_CHANGE` | Thời gian cảnh báo đổi MK |
| 30 | `PASSWORD_RULE_LIMIT_CHAR` | Độ dài tối thiểu MK |
| 31 | `PASSWORD_RULE_NEW_FIRST` | Đổi MK lần đăng nhập đầu |
| 32 | `DAY_CHECK_CERTIFICATE_EXPRIED` | Số ngày cảnh báo CTS sắp hết hạn |
| 33 | `DAY_CHECK_CERTIFICATE` | Thời gian kiểm tra cer |
| 34 | `DAY_GET_DATA_MSS` | Thời gian lấy dữ liệu MSS |

**File:** `SysVarsEnum.java`

---

## SystemDaysOfWeekEnum

**Ghi chú:** Ngày trong tuần (0 = Chủ nhật).

| Value | Constant | Title |
|------:|----------|-------|
| 0 | `SUNDAY` | Chủ nhật |
| 1 | `MONDAY` | Thứ hai |
| 2 | `TUESDAY` | Thứ ba |
| 3 | `WEDNESDAY` | Thứ tư |
| 4 | `THURSDAY` | Thứ năm |
| 5 | `FRIDAY` | Thứ sáu |
| 6 | `SATURDAY` | Thứ bảy |

**File:** `SystemDaysOfWeekEnum.java`

---

## File source tham chiếu

| Loại | Đường dẫn |
|------|-----------|
| Enum CMS | `nhnck-service/src/main/java/com/tinhvan/nhnckservice/common/enums/` |
| Map trạng thái chính | [DB-ENUM-STATUS-MAP.md](./DB-ENUM-STATUS-MAP.md) |

---

## 5. Gợi ý query Oracle

**Bước 1:** Xem cột là `STATUS_ID` hay `STATUS`:

```sql
-- Có bảng map
SELECT a.ID, a.STATUS_ID, s.STATUS_CODE, s.LABEL
FROM APPLICATIONS a
JOIN APPLICATION_STATUSES s ON s.ID = a.STATUS_ID;

-- Chỉ có enum code — decode thủ công
SELECT ID, STATUS,
  CASE STATUS
    WHEN 1 THEN 'PENDING'
    WHEN 2 THEN 'PROCESSING'
    WHEN 3 THEN 'COMPLETED'
    WHEN 4 THEN 'REJECTED'
    WHEN 5 THEN 'WAITING_UPDATE'
    WHEN 6 THEN 'VALID'
    WHEN 7 THEN 'IN_GROUP'
    WHEN 8 THEN 'DRAFT'
  END AS STATUS_NAME
FROM CERTIFICATE_CONVERSION_REQUESTS;
```

**Bước 2:** Đếm phân bố giá trị trước khi suy luận:

```sql
SELECT STATUS, COUNT(*) FROM CERTIFICATE_CONVERSION_REQUESTS GROUP BY STATUS ORDER BY STATUS;
```

---

## 6. File source tham chiếu

| Loại | Đường dẫn |
|------|-----------|
| Enum CMS | `nhnck-service/src/main/java/com/tinhvan/nhnckservice/common/enums/` |
| Enum Portal | `nhnck-service-front/src/main/java/com/tinhvan/nhnckservicefront/common/enums/` |
| Label chuyển đổi CMS | `.../certificaterecord/application/util/ConversionRequestCodes.java` |
| Label chuyển đổi Portal | `PersonalApplicationServiceImpl.conversionRequestStatusLabel()` |
| Label FE CMS | `nhnck-frontend/.../helpers/conversion-request-display.util.ts` |
| Schema Oracle | `nhnck-service/src/main/resources/migrate/db.sql` |
