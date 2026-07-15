# NHNCK — Đánh giá ảnh hưởng đối chiếu DDL UAT tới thiết kế Atomic

> Nguồn đối chiếu: `Source/DDL UAT/NHNCK_UAT_schema.txt` (95 bảng) vs `Source/NHNCK_Tables.csv` / `Source/NHNCK_Columns.csv` (85 bảng gốc).
> Kết quả chi tiết từng dòng: `Source/NHNCK_Reconcile_Issues.csv`.
> Ngày thực hiện: 2026-07-15.

## 1. Tóm tắt đối chiếu

| Hạng mục | Số lượng | Xử lý |
|---|---|---|
| Bảng khớp tên | 85/85 | Không bảng nào bị xóa khỏi UAT |
| Bảng mới (nghiệp vụ) | 4 | Thêm vào Tables/Columns.csv + BRD yaml, `scope_status: pending` |
| Bảng mới (artifact kỹ thuật, loại bỏ) | 6 | `flyway_schema_history`, `NHNCKEXP*`×4, `SYS_EXPORT_SCHEMA_01` |
| Đổi tên cột (đã áp dụng, độ tin cậy cao) | 100 | Cập nhật CSV + BRD yaml, giữ nguyên mô tả nghiệp vụ |
| Đổi tên cột nghi vấn (chưa áp dụng) | 7 | Ghi vào Reconcile_Issues, chờ Data Modeler xác nhận |
| Sai kiểu dữ liệu thật (đã áp dụng) | 11 | Base type hoặc precision thực sự khác |
| Khác biệt CHAR/BYTE (không sửa) | 338 | Artifact cách dump DDL tính DATA_LENGTH (byte) thay vì CHAR_LENGTH — CSV vẫn đúng số ký tự |
| Cột mới trong bảng đã khảo sát | 21 | Thêm vào CSV/BRD, mô tả TBD |
| Sai vai trò khóa (PK/FK) | 75 | Đa số là FK mức ứng dụng không có constraint DB (bình thường) — xem mục 4 |

## 2. Ảnh hưởng tới 34 file LLD đã thiết kế

Đối chiếu `source_columns` của từng attribute trong 34 file `lld_NHNCK_*.yaml` với danh sách đổi tên/đổi kiểu ở trên. Tổng cộng **17 điểm cần xử lý**, tại **8 entity**:

### Mức HIGH — cột nguồn đã đổi tên, mapping cần cập nhật lại tên cột vật lý

| File LLD | design_status | Attribute | Cột cũ → Cột mới |
|---|---|---|---|
| `lld_NHNCK_APPLICATIONS.yaml` | draft | Violated Indicator | `VIOLATED` → `IS_VIOLATED` |
| `lld_NHNCK_APPLICATIONS.yaml` | draft | Data Exploitable Indicator | `DATA_EXPLOITABLE` → `IS_DATA_EXPLOITABLE` |
| `lld_NHNCK_APPLICATION_STATUSES.yaml` | draft | Active Indicator | `ACTIVE` → `IS_ACTIVE` |
| `lld_NHNCK_APPLICATION_STATUSES.yaml` | draft | Original Data Indicator | `ORIGINAL_DATA` → `IS_ORIGINAL_DATA` |
| `lld_NHNCK_CERTIFICATES.yaml` | draft | Displayed Indicator | `DISPLAYED` → `IS_DISPLAYED` |
| `lld_NHNCK_CERTIFICATES.yaml` | draft | Original Data Indicator | `ORIGINAL_DATA` → `IS_ORIGINAL_DATA` |
| `lld_NHNCK_DECISIONS.yaml` | **approved** | Active Flag | `ACTIVE` → `IS_ACTIVE` |
| `lld_NHNCK_DOCUMENTS.yaml` | draft | Active Indicator | `ACTIVE` → `IS_ACTIVE` |
| `lld_NHNCK_DOCUMENTS.yaml` | draft | Original Data Indicator | `ORIGINAL_DATA` → `IS_ORIGINAL_DATA` |
| `lld_NHNCK_EXAM_SESSIONS.yaml` | **approved** | Assessment Name | `ITEM_NAME` → `NAME` |
| `lld_NHNCK_EXAM_SESSIONS.yaml` | **approved** | Report Year | `REPORT_YEAR` — **chưa xác định được tên mới** (xem mục 3) |
| `lld_NHNCK_SPECIALIZATIONS.yaml` | draft | Active Indicator | `ACTIVE` → `IS_ACTIVE` |
| `lld_NHNCK_SPECIALIZATIONS.yaml` | draft | Original Data Indicator | `ORIGINAL_DATA` → `IS_ORIGINAL_DATA` |

**Hành động đề xuất**: cập nhật `comment`/ghi chú mapping trong các attribute trên để phản ánh tên cột vật lý mới (không đổi ý nghĩa nghiệp vụ, không đổi `attribute_name`/`physical_name` phía Atomic). Ưu tiên xử lý `lld_NHNCK_DECISIONS.yaml` và `lld_NHNCK_EXAM_SESSIONS.yaml` trước vì đã `approved`.

### Mức MEDIUM — kiểu dữ liệu nguồn thay đổi thật (không phải artifact CHAR/BYTE)

| File LLD | design_status | Attribute | Thay đổi |
|---|---|---|---|
| `lld_NHNCK_DECISIONS.yaml` | **approved** | Decision Number | `NVARCHAR2(255)` → `NVARCHAR2(1000)` ký tự (giãn ×3.9, vượt mức CHAR/BYTE thông thường ×2 của NVARCHAR2 — khả năng cột đã thực sự mở rộng độ dài) |
| `lld_NHNCK_DECISIONS.yaml` | **approved** | Signatory Name | `NVARCHAR2(255)` → `NVARCHAR2(1000)` ký tự (tương tự) |
| `lld_NHNCK_DECISIONS.yaml` | **approved** | Issuing Organization Name | `NVARCHAR2(1024)` → `NVARCHAR2(4000)` ký tự (tương tự) |
| `lld_NHNCK_SPECIALIZATION_COURSES.yaml` | **approved** | Exam End Date | `VARCHAR2(200)` (text) → `DATE` — **đổi hẳn loại dữ liệu**, cần xem lại `data_domain`/`data_type` của attribute |

**Lưu ý riêng**: 3 dòng NVARCHAR2 giãn ×~4 lần (DECISIONS) không khớp tỷ lệ CHAR/BYTE kỳ vọng (×2 cho NVARCHAR2/NCHAR) — đây là phát hiện ngoài phạm vi trao đổi ban đầu (chỉ có EXAM_DATE_TO được xác nhận trước). Cần Data Modeler xác nhận đây là do cột thực sự được mở rộng trên UAT hay do khác biệt charset/tool đo đạc.

## 3. Chưa xử lý được — cần Data Modeler xác nhận thủ công

7 cột có tên cũ trong tài liệu nhưng không khớp DDL UAT và không đủ độ tin cậy để tự động đổi tên (xem chi tiết trong `NHNCK_Reconcile_Issues.csv`):

- `EXAM_SESSIONS.REPORT_YEAR` — nghi ngờ tương ứng với `YEAR` trong DDL (đã xuất hiện là "cột mới"), **ảnh hưởng trực tiếp tới `lld_NHNCK_EXAM_SESSIONS.yaml` (approved)**, attribute "Report Year" — cần xác nhận sớm.
- `NOTIFICATIONS.READ_FLAG` — nghi ngờ tương ứng `IS_READ`. Không có LLD tương ứng (chưa thiết kế), không ảnh hưởng LLD hiện tại.
- `NOTIFICATION_CONFIGURATIONS.EMAIL_ENABLED / NOTI_ENABLED / SMS_ENABLED` — nghi ngờ tương ứng `IS_EMAIL / IS_NOTI / IS_SMS`. Không có LLD tương ứng.
- `ORGANIZATION_REPORT_YEARLYS.REPORT_YEAR` — nghi ngờ tương ứng `YEAR`. Không có LLD tương ứng.
- `PERMISSIONS.MENU_FLAG` — nghi ngờ tương ứng `IS_MENU`. Không có LLD tương ứng.

## 4. Quan sát khác (không cần hành động ngay)

- **75 dòng "Sai khóa (PK/FK)"**: phần lớn là cột được tài liệu ghi là FK nhưng DDL UAT không có FK constraint tương ứng ở mức DB (`doc_only` theo thuật ngữ skill `source-survey`) — đây là pattern rất phổ biến (FK mức ứng dụng, không ràng buộc DB), **không phải lỗi**, không ảnh hưởng tới thiết kế Atomic vì Atomic không dựa vào constraint vật lý của nguồn.
- 5 trường hợp ngược lại đáng chú ý: `EMAIL_LOGS.ID`, `NOTIFICATIONS.ID`, `NOTIFICATION_CONFIGURATIONS.ID`, `SMS_LOGS.ID` được DDL xác nhận là PK nhưng tài liệu cũ chưa đánh dấu — có thể là thiếu sót tài liệu đơn thuần (dễ sửa, không có LLD liên quan nên không gấp).
- 2 trường hợp phát hiện FK mới qua DDL (`db_only`): `CERTIFICATE_CONVERSION_REQUESTS.CREATED_BY`, `CERTIFICATE_RECORD_STATUS_HISTORIES.CREATED_BY` — đều FK tới `USERS.ID`, phù hợp logic audit, không ảnh hưởng thiết kế hiện tại.
- Đã bổ sung attribute map `NHNCK.ORGANIZATION_REPORTS.CREATED_AT` vào `lld_NHNCK_ORGANIZATION_REPORTS.yaml` — BRD ingestion (`Append`, `filter_logic: created_at >= {etl_date}`) trước đó không có attribute Atomic nào phản ánh mốc này. Đặt tên chuẩn hóa là **"Data Date"** (`data_dt`, 2026-07-15) — áp dụng thống nhất cho mọi bảng Append cần CREATED_AT làm partition key, thay cho tên "Report Recorded Date" đã dùng tạm trước đó (đã hợp nhất, không tạo trùng attribute).

## 5. Việc cần làm tiếp theo (đề xuất thứ tự ưu tiên)

1. Xác nhận rename `EXAM_SESSIONS.REPORT_YEAR → YEAR` (ảnh hưởng entity đã approved).
2. Cập nhật ghi chú mapping cột đổi tên trong `lld_NHNCK_DECISIONS.yaml` (Active Flag) và `lld_NHNCK_EXAM_SESSIONS.yaml` (Assessment Name) — 2 entity đã approved.
3. Xác nhận 3 trường hợp NVARCHAR2 giãn độ dài bất thường trong `lld_NHNCK_DECISIONS.yaml`.
4. Xác nhận đổi `data_domain`/`data_type` cho attribute "Exam End Date" trong `lld_NHNCK_SPECIALIZATION_COURSES.yaml` (Text → Date).
5. Các attribute còn `draft` (APPLICATIONS, APPLICATION_STATUSES, CERTIFICATES, DOCUMENTS, SPECIALIZATIONS) — cập nhật cùng lúc với vòng review LLD tiếp theo, không cần gấp.
6. Xác định ý nghĩa nghiệp vụ + `scope_status` cho 4 bảng mới (`CERTIFICATE_CONVERSION_REQUEST_LOGS`, `POST_CERT_TRAINING_RESULTS`, `REPORT_TEMPLATES`, `VERIFY_CERTIFICATE_CONVERSION_STATUSES`) khi chạy `atomic-lld-design` cho các nhóm chức năng liên quan.
