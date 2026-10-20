# AUDIT — Tài liệu khảo sát nguồn và ánh xạ Atomic

**Phân hệ:** AUDIT (GMS Audit — schema Oracle `GMS_AUDIT_UAT`, tách từ IDS ngày 2026-10-16)
**Phạm vi tài liệu:** 50 bảng, gồm:
- Quản lý, giám sát tổ chức kiểm toán được chấp thuận và kiểm toán viên (12 bảng `AF_*` — 11 bảng đã thiết kế Atomic, 1 bảng mới chờ thiết kế)
- Các bảng còn lại của schema (38 bảng — công bố thông tin, báo cáo/biểu mẫu, danh mục và hệ thống) **chưa đánh phạm vi** (`scope_status: pending`); Data Modeler sẽ quyết định `in_scope`/`out_of_scope` theo số lượng LLD và FK

**Mục đích:** Tổng hợp nghiệp vụ nguồn, quan hệ bảng (tree FK), và ánh xạ Atomic entity theo từng nhóm chức năng (UID) — phục vụ tham chiếu cho thiết kế Atomic layer.

**Nguồn tài liệu:**
- Schema CSDL: `Source/DDL UAT 1/GMS_AUDIT_UAT_schema.txt`
- BRD: `BRD/Source/brd_AUDIT.yaml` và `BRD/Source/AUDIT/brd_AUDIT_*.yaml`
- HLD Overview: `AUDIT_HLD_Overview.md`
- LLD: `DataModel/working/Atomic/lld/AUDIT/lld_AUDIT_AF_*.yaml`
- Đặc tả yêu cầu: **Không có** — nhóm chức năng (UID) được suy luận từ cấu trúc CSDL + HLD Overview

> **Lưu ý về UID:** Do không có tài liệu đặc tả yêu cầu, các UID trong tài liệu này được suy luận từ (1) ngữ nghĩa nghiệp vụ của từng bảng, (2) phân nhóm bảng trong HLD Overview. Không phải mã chức năng chính thức của hệ thống.

> **Lưu ý về FK:** Schema nguồn gần như không khai báo ràng buộc FK ở mức CSDL cho các bảng `AF_*`. Toàn bộ quan hệ FK trong tài liệu này là **gợi ý suy luận theo tên cột** (`fk_src: inferred` trong BRD), chưa được Data Modeler xác nhận.

> **Nguồn gốc:** Phần nghiệp vụ `AF_*` trước đây nằm ở UID-07 của `IDS_Source_Analysis.md`. Bản này viết lại theo thiết kế hiện tại (tên entity và quan hệ lấy từ LLD/HLD AUDIT), không sao chép nguyên văn vì bản IDS còn dùng tên cũ (`af_auditor_approval`, `Auditor Approval`).

---

## Bảng quy ước

Ký hiệu trong cột **Ánh xạ Atomic**:

| Ký hiệu | Ý nghĩa |
|---|---|
| 🟢 *Tên entity* | Atomic entity được thiết kế, ví dụ `🟢 Audit Firm` |
| 🟢 *Entity* (shared — bổ sung source) | Bảng nguồn bổ sung cho shared entity đã có, chỉ extend cột `source_table` |
| 🟢 CV: `CODE` | Bảng nguồn là Classification Value scheme (danh mục mã hóa) |
| ⚪ (Pending) *lý do* | Bảng chưa đánh phạm vi hoặc chưa thiết kế Atomic |
| 🔴 (Out of scope) *lý do* | Bảng không thiết kế Atomic, kèm lý do ngắn gọn |

---

## Mục lục

- [UID-01 — Quản lý hồ sơ công ty kiểm toán và kiểm toán viên](#uid-01--quản-lý-hồ-sơ-công-ty-kiểm-toán-và-kiểm-toán-viên)
- [UID-02 — Kiểm tra, nhắc nhở, xử phạt và đình chỉ](#uid-02--kiểm-tra-nhắc-nhở-xử-phạt-và-đình-chỉ)
- [UID-03 — Công bố thông tin, thông báo và cảnh báo](#uid-03--công-bố-thông-tin-thông-báo-và-cảnh-báo)
- [UID-04 — Báo cáo tài chính và biểu mẫu](#uid-04--báo-cáo-tài-chính-và-biểu-mẫu)
- [UID-05 — Quản trị hệ thống và danh mục dùng chung](#uid-05--quản-trị-hệ-thống-và-danh-mục-dùng-chung)
- [Phụ lục A — Danh mục dùng chung](#phụ-lục-a--danh-mục-dùng-chung)
- [Phụ lục B — Classification Value schemes từ lookup_values](#phụ-lục-b--classification-value-schemes-từ-lookup_values)

---

## UID-01 — Quản lý hồ sơ công ty kiểm toán và kiểm toán viên

Quản lý hồ sơ các công ty kiểm toán được Bộ Tài chính (BTC) và UBCKNN chấp thuận, người đại diện pháp luật, kiểm toán viên (KTV) thuộc công ty, quyết định chấp thuận/đình chỉ và lịch sử trạng thái. `AF_PROFILES` là gốc của toàn bộ nhóm bảng `AF_*`: hầu hết bảng còn lại FK về đây.

### 1.1 Hồ sơ công ty kiểm toán

**Nghiệp vụ:** Lưu thông tin cơ bản công ty kiểm toán: tên VI/EN, mã, địa chỉ trụ sở, liên hệ, vốn điều lệ thực góp, thành viên hãng kiểm toán nước ngoài, trạng thái. Các trường địa chỉ và liên hệ được ánh xạ sang shared Involved Party Address entities; số ĐKKD/giấy chứng nhận đủ điều kiện kinh doanh ánh xạ sang shared Involved Party Alternative Identification.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `AF_PROFILES` | Hồ sơ công ty kiểm toán | 🟢 Audit Firm<br>🟢 Involved Party Postal Address *(shared — bổ sung source)*<br>🟢 Involved Party Electronic Address *(shared — bổ sung source)*<br>🟢 Involved Party Alternative Identification *(shared — bổ sung source)* |

Danh mục tham chiếu: `LOOKUP_VALUES` (CV: `AUDIT_AF_STATUS`).

### 1.2 Người đại diện pháp luật công ty kiểm toán

**Nghiệp vụ:** Danh sách người đại diện pháp luật của công ty kiểm toán (họ tên, số CMND/hộ chiếu, chức vụ, email, điện thoại). Một công ty có thể có nhiều bản ghi theo thời gian. Số giấy tờ định danh giữ denormalized trên entity (nguồn không có cột phân biệt loại giấy tờ).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `AF_PROFILES` | Công ty kiểm toán (xem 1.1) | 🟢 Audit Firm |
| └── `AF_LEGAL_REPRESENTATIVE` | Người đại diện pháp luật của công ty kiểm toán | 🟢 Audit Firm Legal Representative<br>🟢 Involved Party Electronic Address *(shared — bổ sung source)* |

Danh mục tham chiếu: `LOOKUP_VALUES` (CV: `AUDIT_AF_POSITION_TITLE`, `AUDIT_POSITION`).

### 1.3 Kiểm toán viên

**Nghiệp vụ:** Hồ sơ kiểm toán viên thuộc công ty kiểm toán: họ tên, số CCCD, chứng chỉ hành nghề, chứng chỉ kiểm toán viên, ngày rời công ty. Có lịch sử thay đổi trạng thái hành nghề (cấp/thu hồi/đình chỉ chứng chỉ) và lịch sử hành nghề.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `AF_PROFILES` | Công ty kiểm toán (xem 1.1) | 🟢 Audit Firm |
| └── `AF_AUDITOR_PROFILES` | Hồ sơ kiểm toán viên | 🟢 Audit Firm Auditor<br>🟢 Involved Party Alternative Identification *(shared — bổ sung source)* |
| &nbsp;&nbsp;&nbsp;&nbsp;└── `AF_AUDITOR_STATUS_HISTORY` | Lịch sử thay đổi trạng thái của kiểm toán viên | 🟢 Audit Firm Auditor Status History |
| &nbsp;&nbsp;&nbsp;&nbsp;└── `AF_AUDITOR_PRACTICE_HISTORY` | Lịch sử hành nghề của kiểm toán viên *(bảng mới trong schema AUDIT)* | ⚪ (Pending) *Chưa thiết kế Atomic* |

Danh mục tham chiếu: `LOOKUP_VALUES` (CV: `AUDIT_AUDITOR_STATUS`, `AUDIT_POSITION`, `AUDIT_AF_POSITION_TITLE`); `AF_AUDITOR_STATUS_HISTORY.EVENT_TYPE` (CV: `AUDIT_AUDITOR_STATUS_EVENT_TYPE`).

### 1.4 Chấp thuận công ty kiểm toán / kiểm toán viên

**Nghiệp vụ:** Quyết định chấp thuận và đình chỉ do BTC hoặc UBCKNN ban hành. Một bảng xử lý cả công ty kiểm toán và kiểm toán viên: `TARGET_TYPE_CD` phân biệt đối tượng, `SOURCE_TYPE_CD` phân biệt cơ quan ban hành. FK tới công ty bắt buộc, FK tới kiểm toán viên nullable.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `AF_PROFILES` | Công ty kiểm toán (xem 1.1) | 🟢 Audit Firm |
| └── `AF_APPROVAL` | Quyết định chấp thuận/đình chỉ | 🟢 Audit Firm Approval |
| `AF_AUDITOR_PROFILES` | Kiểm toán viên (xem 1.3, FK nullable) | 🟢 Audit Firm Auditor |

Danh mục tham chiếu: `LOOKUP_VALUES` (CV: `AUDIT_APPROVAL_TARGET_TYPE`, `AUDIT_APPROVAL_SOURCE_TYPE`).

### 1.5 Lịch sử trạng thái công ty kiểm toán

**Nghiệp vụ:** Chuỗi sự kiện thay đổi trạng thái hoạt động của công ty kiểm toán: loại trạng thái (đình chỉ/tạm ngừng/chấm dứt/thu hồi), số quyết định, thời gian hiệu lực. Chỉ thêm bản ghi, không sửa (Fact Append).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `AF_PROFILES` | Công ty kiểm toán (xem 1.1) | 🟢 Audit Firm |
| └── `AF_STATUS_HISTORY` | Lịch sử trạng thái công ty kiểm toán | 🟢 Audit Firm Status History |

Danh mục tham chiếu: CV `AUDIT_AF_STATUS_TYPE`, `AUDIT_AF_SUSPENSION_STATUS_TYPE`.

---

## UID-02 — Kiểm tra, nhắc nhở, xử phạt và đình chỉ

Các hoạt động giám sát UBCKNN/BTC đối với công ty kiểm toán và kiểm toán viên: đợt kiểm tra, kiểm tra hồ sơ kiểm toán, văn bản nhắc nhở, xử phạt hành chính, đình chỉ hoạt động. Phần lớn là Fact Append, FK về `AF_PROFILES`; nhắc nhở/đình chỉ có thêm FK nullable tới kiểm toán viên và đợt kiểm tra.

### 2.1 Đợt kiểm tra công ty kiểm toán

**Nghiệp vụ:** Đợt kiểm tra tổng thể công ty kiểm toán: số quyết định kiểm tra, thời gian, đơn vị kiểm tra, kết quả kiểm tra hệ thống kiểm toán, kết quả tổng thể và hình thức xử lý.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `AF_PROFILES` | Công ty kiểm toán (xem 1.1) | 🟢 Audit Firm |
| └── `AF_INSPECTION` | Đợt kiểm tra công ty kiểm toán | 🟢 Audit Firm Inspection |

Danh mục tham chiếu: CV `AUDIT_INSPECTION_AUTHORITY`, `AUDIT_AUDIT_SYSTEM_RESULT`, `AUDIT_AF_INSPECTION_OVERALL_RESULT`, `AUDIT_AF_INSPECTION_OVERALL_ACTION`, `AUDIT_AF_INSPECTION_OVERALL_ACTION_TYPE`.

### 2.2 Kiểm tra hồ sơ kiểm toán

**Nghiệp vụ:** Kết quả kiểm tra hồ sơ kiểm toán trong một đợt kiểm tra: kết quả, hành động xử lý, nội dung vi phạm.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `AF_INSPECTION` | Đợt kiểm tra (xem 2.1) | 🟢 Audit Firm Inspection |
| └── `AF_TECHNICAL_AUDIT` | Kết quả kiểm tra hồ sơ kiểm toán (FK thêm tới `AF_PROFILES`) | 🟢 Audit Firm Technical Audit |

Danh mục tham chiếu: CV `AUDIT_AF_TECHNICAL_AUDIT_RESULT`, `AUDIT_AF_TECHNICAL_AUDIT_ACTION`, `AUDIT_AF_TECHNICAL_AUDIT_ACTION_TYPE`.

### 2.3 Nhắc nhở (Warning)

**Nghiệp vụ:** Văn bản nhắc nhở do BTC hoặc UBCKNN phát hành đối với công ty kiểm toán **hoặc** kiểm toán viên. `TARGET_TYPE_CD` xác định đối tượng; FK tới kiểm toán viên và đợt kiểm tra đều nullable.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `AF_PROFILES` | Công ty kiểm toán (xem 1.1) | 🟢 Audit Firm |
| └── `AF_WARNING` | Văn bản nhắc nhở | 🟢 Audit Firm Warning |
| `AF_AUDITOR_PROFILES` | Kiểm toán viên (xem 1.3, FK nullable) | 🟢 Audit Firm Auditor |
| `AF_INSPECTION` | Đợt kiểm tra (xem 2.1, FK nullable) | 🟢 Audit Firm Inspection |

Danh mục tham chiếu: CV `AUDIT_WARNING_TARGET_TYPE`, `AUDIT_WARNING_SOURCE_TYPE`, `AUDIT_WARNING_TYPE`.

### 2.4 Xử phạt hành chính (Sanctions)

**Nghiệp vụ:** Quyết định xử phạt hành chính đối với công ty kiểm toán: cơ quan xử phạt, số quyết định, ngày ban hành, nội dung xử phạt.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `AF_PROFILES` | Công ty kiểm toán (xem 1.1) | 🟢 Audit Firm |
| └── `AF_SANCTIONS` | Quyết định xử phạt | 🟢 Audit Firm Sanction |

Danh mục tham chiếu: CV `AUDIT_SANCTION_TARGET_TYPE`, `AUDIT_SANCTION_AUTHORITY`.

### 2.5 Đình chỉ hoạt động (Suspension)

**Nghiệp vụ:** Quyết định đình chỉ hoạt động của công ty kiểm toán hoặc kiểm toán viên (`TARGET_TYPE_CD` phân biệt đối tượng); FK tới kiểm toán viên và đợt kiểm tra nullable.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `AF_PROFILES` | Công ty kiểm toán (xem 1.1) | 🟢 Audit Firm |
| └── `AF_SUSPENSION` | Quyết định đình chỉ | 🟢 Audit Firm Suspension |
| `AF_AUDITOR_PROFILES` | Kiểm toán viên (xem 1.3, FK nullable) | 🟢 Audit Firm Auditor |
| `AF_INSPECTION` | Đợt kiểm tra (xem 2.1, FK nullable) | 🟢 Audit Firm Inspection |

---

## UID-03 — Công bố thông tin, thông báo và cảnh báo

Nhóm bảng thông báo, cảnh báo và log gửi tin. **Chưa đánh phạm vi** — chưa có LLD.

### 3.1 Thông báo

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `NOTIFICATIONS` | Thông báo | ⚪ (Pending) *Chưa đánh phạm vi* |
| └── `NOTIFICATIONS_DTL` | Chi tiết/người nhận thông báo | ⚪ (Pending) *Chưa đánh phạm vi* |
| └── `NOTIFICATIONS_RESULT` | Kết quả gửi thông báo | ⚪ (Pending) *Chưa đánh phạm vi* |
| `HTE_NOTIFICATIONS_DTL` | Chi tiết thông báo (module HTE) | ⚪ (Pending) *Chưa đánh phạm vi* |
| `HTE_NOTIFICATIONS_RESULT` | Kết quả gửi thông báo (module HTE) | ⚪ (Pending) *Chưa đánh phạm vi* |
| `SMS_LOG` | Log tin nhắn SMS | ⚪ (Pending) *Chưa đánh phạm vi* |

### 3.2 Mẫu cảnh báo

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ALERT_TEMPLATE_AUDIT_HDR` | Danh sách mẫu template cảnh báo | ⚪ (Pending) *Chưa đánh phạm vi* |
| └── `ALERT_TEMPLATE_AUDIT_DTL` | Danh sách rule cấu hình cảnh báo | ⚪ (Pending) *Chưa đánh phạm vi* |

---

## UID-04 — Báo cáo tài chính và biểu mẫu

Nhóm bảng form, báo cáo và theo dõi vi phạm nộp báo cáo (cấu trúc tương tự nhóm cùng tên của IDS). **Chưa đánh phạm vi** — chưa có LLD.

### 4.1 Form và trường dữ liệu

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `FORMS` | Định nghĩa form | ⚪ (Pending) *Chưa đánh phạm vi* |
| └── `FORM_FIELDS` | Trường thuộc form | ⚪ (Pending) *Chưa đánh phạm vi* |
| └── `FORM_FIELD_HISTORY` | Lịch sử thay đổi trường form | ⚪ (Pending) *Chưa đánh phạm vi* |
| `FIELDS` | Định nghĩa trường | ⚪ (Pending) *Chưa đánh phạm vi* |
| `DATA_TYPES` | Danh mục kiểu dữ liệu | ⚪ (Pending) *Chưa đánh phạm vi* |
| `DATA_VALUES` | Giá trị nhập theo form/field | ⚪ (Pending) *Chưa đánh phạm vi* |
| `COMPANY_DATA` | Dữ liệu form nộp | ⚪ (Pending) *Chưa đánh phạm vi* |

### 4.2 Báo cáo tài chính và báo cáo định kỳ

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `REPORT_CATALOG` | Danh mục báo cáo tài chính | ⚪ (Pending) *Chưa đánh phạm vi* |
| └── `RROW` | Hàng của mẫu báo cáo tài chính | ⚪ (Pending) *Chưa đánh phạm vi* |
| └── `RCOL` | Cột của mẫu báo cáo tài chính | ⚪ (Pending) *Chưa đánh phạm vi* |
| └── `DATA` | Dữ liệu hàng/cột của báo cáo tài chính | ⚪ (Pending) *Chưa đánh phạm vi* |
| `REP_FORMS` | Mẫu báo cáo định kỳ | ⚪ (Pending) *Chưa đánh phạm vi* |
| └── `REP_ROW` | Hàng của mẫu báo cáo định kỳ | ⚪ (Pending) *Chưa đánh phạm vi* |
| └── `REP_COLUMN` | Cột của mẫu báo cáo định kỳ | ⚪ (Pending) *Chưa đánh phạm vi* |
| └── `REP_DATA` | Dữ liệu báo cáo định kỳ có cấu trúc | ⚪ (Pending) *Chưa đánh phạm vi* |

### 4.3 Vi phạm nộp báo cáo

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `VIOLATION_TEMPLATES` | Cấu hình mẫu vi phạm | ⚪ (Pending) *Chưa đánh phạm vi* |
| └── `VIOLATION_REPORT` | Theo dõi vi phạm nộp báo cáo | ⚪ (Pending) *Chưa đánh phạm vi* |
| └── `HTE_VIOLATION_REPORT` | Theo dõi vi phạm nộp báo cáo (module HTE) | ⚪ (Pending) *Chưa đánh phạm vi* |

---

## UID-05 — Quản trị hệ thống và danh mục dùng chung

Tài khoản, phân quyền, log hệ thống và danh mục tham chiếu. **Chưa đánh phạm vi.** Các bảng này có đặc điểm tương tự nhóm cùng tên ở IDS (`Operational/system data`, `Audit Log nguồn`), nhưng quyết định phạm vi cho AUDIT do Data Modeler đưa ra sau.

### 5.1 Người dùng, phân quyền, tệp

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `LOGINS` | Tài khoản đăng nhập | ⚪ (Pending) *Chưa đánh phạm vi* |
| └── `LOGIN_PERMISSION_BY_CODE` | Phân quyền theo mã permission (có cột trỏ tới `AF_PROFILES`) | ⚪ (Pending) *Chưa đánh phạm vi* |
| `DEPARTMENTS` | Phòng ban | ⚪ (Pending) *Chưa đánh phạm vi* |
| `FILES` | Quản lý file đính kèm | ⚪ (Pending) *Chưa đánh phạm vi* |
| `COMPANY_DIGITAL_CERTIFICATES` | Chứng thư số | ⚪ (Pending) *Chưa đánh phạm vi* |

### 5.2 Log và lịch sử thay đổi

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `HISTORY_CHANGE_LOG` | Lịch sử thay đổi dữ liệu theo cơ chế generic | ⚪ (Pending) *Chưa đánh phạm vi* |
| `COMPANY_CHANGE_ROLE_HIS` | Lịch sử thay đổi vai trò (có cột trỏ tới `AF_PROFILES`) | ⚪ (Pending) *Chưa đánh phạm vi* |
| `DATABASECHANGELOG` | Lịch sử migration (Liquibase) | ⚪ (Pending) *Bảng hệ thống migration* |
| `DATABASECHANGELOGLOCK` | Khoá migration (Liquibase) | ⚪ (Pending) *Bảng hệ thống migration* |

### 5.3 Danh mục / Reference data

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `LOOKUP_VALUES` | LOV trung tâm của schema AUDIT (độc lập `IDS.LOOKUP_VALUES`) | 🟢 `CV:` *(22 scheme `AUDIT_*` — xem Phụ lục B)* |
| `COUNTRIES` | Danh mục quốc gia | ⚪ (Pending) *Chưa đánh phạm vi* |
| `HOLIDAY_CALENDAR` | Danh mục ngày lễ/nghỉ | ⚪ (Pending) *Chưa đánh phạm vi* |

---

## Phụ lục A — Danh mục dùng chung

Các bảng được tham chiếu xuyên suốt nhiều UID:

| Bảng | Ý nghĩa | Sử dụng bởi | Ánh xạ Atomic |
|---|---|---|---|
| `LOOKUP_VALUES` | LOV trung tâm, 22 schemes CV | UID-01, UID-02 | 🟢 `CV:` *(22 scheme — xem Phụ lục B)* |
| `AF_PROFILES` | Công ty kiểm toán (gốc quan hệ) | UID-01, UID-02, UID-05 (`LOGIN_PERMISSION_BY_CODE`, `COMPANY_CHANGE_ROLE_HIS`) | 🟢 Audit Firm |

---

## Phụ lục B — Classification Value schemes từ `lookup_values`

Bảng `LOOKUP_VALUES` của AUDIT chứa các `LOOKUP_GROUP`; mỗi group dùng bởi `AF_*` đăng ký thành một Classification Value scheme `AUDIT_*` trong `classification_schemes.yaml` (nguồn: `AUDIT.LOOKUP_VALUES` hoặc cột của bảng `AF_*`). Danh sách hiện có:

| Scheme code | Mô tả | Sử dụng bởi Atomic entity |
|---|---|---|
| `AUDIT_AF_POSITION_TITLE` | Chức vụ người đại diện pháp luật và kiểm toán viên | Audit Firm Legal Representative \| Audit Firm Auditor |
| `AUDIT_POSITION` | Chức vụ (LOOKUP_GROUP = POSITION) | Audit Firm Legal Representative \| Audit Firm Auditor |
| `AUDIT_AF_STATUS` | Trạng thái công ty kiểm toán | Audit Firm |
| `AUDIT_AUDITOR_STATUS` | Trạng thái kiểm toán viên | Audit Firm Auditor |
| `AUDIT_APPROVAL_TARGET_TYPE` | Đối tượng chấp thuận (công ty KT / KTV) | Audit Firm Approval |
| `AUDIT_APPROVAL_SOURCE_TYPE` | Cơ quan chấp thuận (BTC / UBCKNN) | Audit Firm Approval |
| `AUDIT_AF_STATUS_TYPE` | Loại trạng thái công ty kiểm toán | Audit Firm Status History |
| `AUDIT_AF_SUSPENSION_STATUS_TYPE` | Trạng thái đình chỉ công ty kiểm toán | Audit Firm Status History |
| `AUDIT_AUDITOR_STATUS_EVENT_TYPE` | Loại sự kiện thay đổi trạng thái kiểm toán viên | Audit Firm Auditor Status History |
| `AUDIT_INSPECTION_AUTHORITY` | Đơn vị kiểm tra công ty kiểm toán (BTC/UBCKNN) | Audit Firm Inspection |
| `AUDIT_AUDIT_SYSTEM_RESULT` | Kết quả kiểm tra hệ thống kiểm toán | Audit Firm Inspection |
| `AUDIT_AF_INSPECTION_OVERALL_RESULT` | Kết quả kiểm tra tổng thể | Audit Firm Inspection |
| `AUDIT_AF_INSPECTION_OVERALL_ACTION` | Hình thức quyết định tổng thể sau kiểm tra | Audit Firm Inspection |
| `AUDIT_AF_INSPECTION_OVERALL_ACTION_TYPE` | Hình thức xử lý tổng thể | Audit Firm Inspection |
| `AUDIT_AF_TECHNICAL_AUDIT_RESULT` | Kết quả kiểm tra hồ sơ kiểm toán | Audit Firm Technical Audit |
| `AUDIT_AF_TECHNICAL_AUDIT_ACTION` | Hành động xử lý sau kiểm tra hồ sơ | Audit Firm Technical Audit |
| `AUDIT_AF_TECHNICAL_AUDIT_ACTION_TYPE` | Loại hành động xử lý sau kiểm tra hồ sơ | Audit Firm Technical Audit |
| `AUDIT_WARNING_TARGET_TYPE` | Đối tượng nhắc nhở (công ty / KTV) | Audit Firm Warning |
| `AUDIT_WARNING_SOURCE_TYPE` | Cơ quan phát hành văn bản nhắc nhở | Audit Firm Warning |
| `AUDIT_WARNING_TYPE` | Loại văn bản cảnh báo/nhắc nhở | Audit Firm Warning |
| `AUDIT_SANCTION_TARGET_TYPE` | Đối tượng xử phạt (công ty / KTV) | Audit Firm Sanction |
| `AUDIT_SANCTION_AUTHORITY` | Cơ quan phát hành quyết định xử phạt | Audit Firm Sanction |

**Chưa có scheme:** `PROFILE_APPROVAL_STATUS` (LLD `AF_PROFILES` và `AF_AUDITOR_PROFILES` dùng `SCHEMA_CODE=AUDIT.PROFILE_APPROVAL_STATUS`) — cần đăng ký `AUDIT_PROFILE_APPROVAL_STATUS`.
