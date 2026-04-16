# Khảo sát nguồn GSGD — Giám sát giao dịch chứng khoán

**Phân hệ:** GSGD (Giám sát giao dịch chứng khoán)
**Chủ đầu tư:** Ban Công nghệ và Chuyển đổi số — UBCKNN
**Đơn vị sử dụng:** Ban Giám sát thị trường (Ban GSTT)
**Mục đích:** Tài liệu tham chiếu cho thiết kế Silver layer — tổng hợp nghiệp vụ nguồn, quan hệ bảng, và ánh xạ Silver entity theo từng nhóm chức năng.

**Nguồn tài liệu:**
- Đặc tả yêu cầu: `New_UBCKNN_Dac_ta_yeu_cau_GSGD_18_03_2026.docx`
- Thiết kế CSDL: `New_UBCKNN_Thiet_ke_co_so_du_lieu_GSGD_18_03_2026.docx`
- HLD Silver Overview: `GSGD_HLD_Overview.md`
- Silver mapping: `silver_entities.csv`
- Classification Value registry: `ref_shared_entity_classifications.csv`

**Phạm vi CSDL nguồn:** 47 bảng — 28 bảng map Silver entity, 19 bảng ngoài scope.

---

## Bảng quy ước

Cột **Ánh xạ Silver** sử dụng các ký hiệu sau:

| Ký hiệu | Ý nghĩa |
|---|---|
| 🟢 Tên entity | Silver entity được thiết kế cho bảng nguồn này |
| 🟢 `CV: CODE` | Classification Value — bảng/cột nguồn map thành danh mục mã hóa |
| 🟢 ↳ denormalize vào *Entity* | Junction table — flatten thành `Array<Text>` trên entity chính |
| 🔴 (Out of scope) *lý do* | Bảng ngoài scope Silver với lý do cụ thể |

Cấu trúc phân cấp dùng ký hiệu tree:
- `├──` / `└──` — quan hệ FK cha-con (indent 1 cấp)
- `│   ├──` / `│   └──` — nested 2 cấp trở lên

Danh mục tham chiếu (ví dụ `category_item` với scheme CV) được ghi ở dòng cuối mỗi bảng nếu có tham chiếu.

---

## Mục lục

- [UID1 — Nhóm chức năng: Quản lý thông tin](#uid1--nhóm-chức-năng-quản-lý-thông-tin)
  - [1.1 Quản lý tài khoản nhà đầu tư](#11-quản-lý-tài-khoản-nhà-đầu-tư)
  - [1.2 Khai thác thông tin doanh nghiệp](#12-khai-thác-thông-tin-doanh-nghiệp)
  - [1.3 Quản lý mã chứng khoán](#13-quản-lý-mã-chứng-khoán)
  - [1.4 Quản lý báo cáo (tuân thủ & bất thường)](#14-quản-lý-báo-cáo-tuân-thủ--bất-thường)
- [UID2 — Nhóm chức năng: Phân tích chuyên sâu vụ việc](#uid2--nhóm-chức-năng-phân-tích-chuyên-sâu-vụ-việc)
  - [2.1 Khởi tạo và phê duyệt vụ việc](#21-khởi-tạo-và-phê-duyệt-vụ-việc)
  - [2.2 Tiêu chí và tham số phân tích](#22-tiêu-chí-và-tham-số-phân-tích)
  - [2.3 Thực thi và kết quả phân tích](#23-thực-thi-và-kết-quả-phân-tích)
  - [2.4 Tài khoản nghi vấn (kết luận vụ việc)](#24-tài-khoản-nghi-vấn-kết-luận-vụ-việc)
- [UID3 — Nhóm chức năng: Quản trị phân hệ & tiện ích](#uid3--nhóm-chức-năng-quản-trị-phân-hệ--tiện-ích)
- [Phụ lục: Danh mục dùng chung](#phụ-lục-danh-mục-dùng-chung)

---

## UID1 — Nhóm chức năng: Quản lý thông tin

Nhóm chức năng phục vụ Ban GSTT khai thác thông tin cơ bản: tài khoản nhà đầu tư, doanh nghiệp niêm yết, mã chứng khoán, và quản lý báo cáo từ SGDCK/VSDC. Dữ liệu chủ yếu được đồng bộ từ VSDC, CTCK, và Phân hệ Quản lý danh mục điện tử dùng chung qua API. GSGD lưu trữ local một số nhóm bảng tự quản lý như nhóm tài khoản, nhóm chứng khoán, sự kiện TCNY (được Ban GSTT thêm thủ công).

### 1.1 Quản lý tài khoản nhà đầu tư

**Nghiệp vụ:** Khai thác số liệu tổng hợp NĐT/TK, tra cứu và xem chi tiết tài khoản, sửa thông tin mở rộng (SĐT, email, địa chỉ, người đại diện...), phê duyệt yêu cầu thay đổi thông tin. Quản lý nhóm tài khoản nhà đầu tư (tạo, sửa, xóa, phê duyệt). Khai thác danh sách tài khoản bị xử phạt VPHC. Nguồn dữ liệu: VSDC (thông tin gốc), CTCK (thông tin mở rộng), chuyên viên Ban GSTT (chỉnh sửa). Vai trò: Trưởng ban, Phó Trưởng ban, Chuyên viên Ban GSTT.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `investor_account` | Tài khoản nhà đầu tư (gốc từ VSDC) | 🟢 **Investor Trading Account** |
| ├── `investor_account_history` | Lịch sử thay đổi thông tin TK | 🔴 (Out of scope) *Audit Log nguồn* |
| ├── `account_financial_service` | Dịch vụ tài chính (ký quỹ / ứng trước / HĐ khác) | 🟢 **Investor Trading Account Financial Service** |
| ├── `account_authorization` | Ủy quyền giao dịch trên tài khoản | 🟢 **Investor Trading Account Authorization** |
| └── `account_relationship` | Quan hệ giữa các tài khoản (danh tính / IP / MAC / tiền) | 🟢 **Investor Account Relationship** |
| `account_group` | Nhóm tài khoản nhà đầu tư | 🟢 **Account Investor Group** |
| ├── `account_group_member` | Thành viên nhóm tài khoản | 🟢 **Account Investor Group Member** |
| └── `account_group_history` | Lịch sử thay đổi nhóm TK | 🔴 (Out of scope) *Audit Log nguồn* |

**Danh mục tham chiếu:** `category_item` với các scheme — `GSGD_INVESTOR_TYPE` (cột `investor_account.investor_type`), `GSGD_ACCOUNT_STATUS` (cột `investor_account.account_status`), `GSGD_DOMESTIC_FOREIGN_FLAG` (cột `investor_account.domestic_foreign_flag`), `GSGD_ACCOUNT_GROUP_TYPE` (cột `account_group.group_type`), `GSGD_ACCOUNT_RELATION_TYPE` (bảng-level: loại quan hệ `account_relationship.category_item_id`), `GSGD_FINANCIAL_SERVICE_TYPE` (cột `account_financial_service.service_type`).

### 1.2 Khai thác thông tin doanh nghiệp

**Nghiệp vụ:** Khai thác thông tin tổ chức niêm yết (TCNY), cổ đông lớn, người nội bộ / người liên quan (NNB/NLQ), công ty chứng khoán, công ty quản lý quỹ và quỹ đầu tư. Quản lý sự kiện tổ chức niêm yết (ảnh hưởng giá tham chiếu): thêm mới, chỉnh sửa, xóa, phê duyệt. Dữ liệu TCNY/CTCK/NNB/cổ đông chủ yếu được đồng bộ từ **Phân hệ Danh mục điện tử dùng chung** qua API (không lưu trong CSDL GSGD — chỉ sự kiện TCNY được quản lý local).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `company_event` | Sự kiện tổ chức niêm yết | 🟢 **Listed Company Corporate Event** |
| └── `company_event_history` | Lịch sử thay đổi sự kiện TCNY | 🔴 (Out of scope) *Audit Log nguồn* |

**Danh mục tham chiếu:** `category_item` với scheme `GSGD_COMPANY_EVENT_TYPE` (bảng-level: loại sự kiện `company_event.event_type_id`).

### 1.3 Quản lý mã chứng khoán

**Nghiệp vụ:** Tra cứu mã chứng khoán (thông tin cơ bản + giá theo khoảng thời gian + khối lượng/giá trị giao dịch). Quản lý nhóm chứng khoán (Ban GSTT tự tạo): thêm mới, chỉnh sửa, xóa nhóm với danh sách mã CK. Phê duyệt thay đổi nhóm CK. Tra cứu chỉ số ngành. Dữ liệu mã CK và chỉ số ngành được đồng bộ từ **Phân hệ Danh mục điện tử dùng chung** qua API — GSGD chỉ lưu nhóm chứng khoán do Ban GSTT tự quản lý.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `securities_group` | Nhóm chứng khoán (watchlist) | 🟢 **Securities Watchlist Group** |
| ├── `securities_group_member` | Thành viên nhóm chứng khoán | 🟢 ↳ denormalize vào *Securities Watchlist Group* (`Array<Text>`) |
| └── `securities_group_history` | Lịch sử thay đổi nhóm CK | 🔴 (Out of scope) *Audit Log nguồn* |

**Danh mục tham chiếu:** `category_item` với scheme `GSGD_SECURITIES_GROUP_TYPE` (cột `securities_group.group_type`).

### 1.4 Quản lý báo cáo (tuân thủ & bất thường)

**Nghiệp vụ:** Quản lý báo cáo tuân thủ (weekly, monthly, annual từ SGDCK/VSDC theo Thông tư 138/2025) và báo cáo bất thường. Tổng hợp số lượng BC, khai thác danh sách, phê duyệt/từ chối BC. Hệ thống tự động phê duyệt BC tuân thủ dựa trên rule; BC bất thường phê duyệt thủ công bởi Lãnh đạo Ban. Quy trình sau phê duyệt: với BC tuân thủ → phân công theo dõi xử lý, gửi ý kiến; với BC bất thường → khởi tạo vụ việc tự động. Nguồn: 52 loại BC tuân thủ (BM057–BM108) và BC bất thường từ SGDCK/VSDC qua Cổng truy cập tập trung nội bộ.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `abnormal_report` | Báo cáo bất thường từ SGDCK/VSDC | 🟢 **Abnormal Trading Report** |
| └── `abnormal_report_file` | File đính kèm (PDF, chữ ký số) | 🟢 **Abnormal Trading Report File Attachment** |
| `compliance_report_template` | Danh sách loại báo cáo tuân thủ (BM057–BM108) | 🟢 **Market Surveillance Compliance Report Template** |
| ├── `compliance_report_config` | Cấu hình cấu trúc cột cho từng loại BC | 🟢 **Market Surveillance Compliance Report Column Config** |
| └── `compliance_report_master` | Thông tin tổng hợp BC tuân thủ theo kỳ | 🟢 **Market Surveillance Compliance Report Instance** |
| &nbsp;&nbsp;&nbsp;&nbsp;└── `compliance_report_data` | Dữ liệu chi tiết từng dòng báo cáo (JSON) | 🟢 **Market Surveillance Compliance Report Row Data** |

**Danh mục tham chiếu:** `category_item` với các scheme — `GSGD_ABNORMAL_REPORT_TYPE` (bảng-level: loại BC bất thường), `GSGD_APPROVAL_STATUS` (cột `abnormal_report.approval_status`), `GSGD_PERIOD_TYPE` (shared — cột `abnormal_report.period_type` và `compliance_report_template.period_type`), `GSGD_SUBMITTER_TYPE` (cột `abnormal_report.submitter_type`), `GSGD_FILE_TYPE` (shared — cột `abnormal_report_file.file_type` và `case_attach_file.file_type`).

---

## UID2 — Nhóm chức năng: Phân tích chuyên sâu vụ việc

Nhóm chức năng trọng tâm của phân hệ GSGD — xử lý vụ việc giám sát giao dịch theo 4 quy trình phân tích: Sơ bộ, Nội gián, Thao túng, Liên thị trường. Mỗi vụ việc gắn với 1 mã chứng khoán (hoặc nhóm MCK) hoặc 1 nhóm tài khoản/nhà đầu tư. Luồng xử lý: Chuyên viên khởi tạo → Trưởng ban phê duyệt → Phó Trưởng ban phân công → Chuyên viên xử lý. Khi chạy phân tích, hệ thống tạo ra các báo cáo tổng hợp (BM032–BM055), TK nghi vấn, nhóm TK nghi vấn, sơ đồ quan hệ và báo cáo kết luận (BM103–BM105). Kết quả được lưu lại theo từng lần chạy để hỗ trợ truy vết.

### 2.1 Khởi tạo và phê duyệt vụ việc

**Nghiệp vụ:** Chuyên viên khởi tạo vụ việc với loại MCK/NĐT/TK, nhập thời gian phân tích và nguồn thông tin. Hệ thống sinh mã vụ việc (`MCK-YYYYMMDD-XXX` hoặc `TK-YYYYMMDD-XXX`), lưu vụ việc và chuyển phê duyệt. Luồng phê duyệt 4 bước: Chuyên viên khởi tạo → Trưởng ban phê duyệt → Phó Trưởng ban phân công → Chuyên viên xử lý. Vụ việc cũng có thể được khởi tạo tự động từ báo cáo bất thường của Sở (xem mục 1.4). Đính kèm các file hồ sơ của Sở và danh sách TK nghi vấn ban đầu.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `case_file` | Vụ việc giám sát | 🟢 **Market Surveillance Case** |
| ├── `case_attach_file` | File đính kèm vụ việc (hồ sơ Sở, danh sách TK nghi vấn) | 🟢 **Market Surveillance Case Document Attachment** |
| ├── `case_file_workflow` | Quy trình xử lý vụ việc (các bước phân tích) | 🟢 **Market Surveillance Case Workflow Step** |
| └── `case_approval_step` | Tiến trình gửi duyệt vụ việc (4 bước) | 🟢 **Market Surveillance Case Approval Step Log** |

**Danh mục tham chiếu:** `category_item` với các scheme — `GSGD_CASE_TYPE` (cột `case_file.case_file_type`), `GSGD_CASE_STATUS` (bảng-level: trạng thái vụ việc), `GSGD_INFORMATION_SOURCE` (bảng-level: nguồn thông tin vụ việc), `GSGD_WORKFLOW_TYPE` (cột `case_file_workflow.workflow_type`), `GSGD_APPROVAL_STEP_CODE` (cột `case_approval_step.step_code`), `GSGD_APPROVAL_STEP_STATUS` (cột `case_approval_step.status`), `GSGD_FILE_GROUP` (cột `case_attach_file.file_group`), `GSGD_FILE_TYPE` (shared — cột `case_attach_file.file_type`).

### 2.2 Tiêu chí và tham số phân tích

**Nghiệp vụ:** Quản trị phân hệ định nghĩa các tiêu chí phân tích (VD: "Tỷ trọng đặt/khớp lệnh > A% trong X ngày") với kiểu dữ liệu, giá trị mặc định, min/max. Khi chạy phân tích vụ việc, chuyên viên có thể thay đổi giá trị tiêu chí cho từng quy trình (Sơ bộ/Thao túng/Nội gián/Liên thị trường). Giá trị tiêu chí được lưu theo từng lần chạy để đảm bảo tái hiện kết quả. Tiêu chí là cơ sở để lọc TK nghi vấn từ các báo cáo tổng hợp.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `analysis_attribute_define` | Định nghĩa tiêu chí phân tích | 🟢 **Market Surveillance Analysis Criterion** |
| └── `analysis_attribute_value` | Giá trị tiêu chí theo từng lần chạy | 🟢 **Market Surveillance Analysis Criterion Value** |

**Danh mục tham chiếu:** `category_item` với scheme `GSGD_DATA_TYPE` (cột `analysis_attribute_define.data_type` — NUMBER/STRING/DATE/BOOLEAN), `GSGD_WORKFLOW_TYPE` (shared — cột `analysis_attribute_define.workflow_type` và `analysis_attribute_value.workflow_type`).

### 2.3 Thực thi và kết quả phân tích

**Nghiệp vụ:** Chuyên viên chạy quy trình phân tích trên vụ việc. Hệ thống truy vấn dữ liệu theo tham số, chạy các biểu mẫu báo cáo tổng hợp (BM032–BM055) và báo cáo phân tích (BM103–BM105, BM053–BM056). Kết quả mỗi lần chạy bao gồm: log thực thi (status, thời gian, tham số), danh sách TK nghi vấn snapshot theo biểu mẫu, kết quả phân tích TK/nhóm TK nghi vấn chi tiết, và các mối quan hệ được xác định. Hỗ trợ xem lịch sử phân tích và tải lại báo cáo kết quả.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `case_file` | Vụ việc (xem 2.1) | 🟢 **Market Surveillance Case** *(xem 2.1)* |
| ├── `analysis_execution_log` | Log thực thi phân tích (trạng thái, thời gian, tham số) | 🟢 **Market Surveillance Analysis Execution Log** |
| ├── `analysis_suspicious_account_code` | Snapshot TK nghi vấn theo từng biểu mẫu/lần chạy | 🟢 **Market Surveillance Analysis Suspicious Account Snapshot** |
| ├── `analysis_suspicious_account` | Kết quả phân tích TK nghi vấn theo quy trình | 🟢 **Market Surveillance Suspicious Account Analysis Result** |
| ├── `analysis_account_relationship` | Kết quả phân tích mối quan hệ TK nghi vấn | 🟢 **Market Surveillance Account Relationship Analysis Result** |
| ├── `analysis_account_group` | Kết quả phân tích nhóm TK nghi vấn | 🟢 **Market Surveillance Account Group Analysis Result** |
| ├── `analysis_account_group_member` | Thành viên nhóm TK trong kết quả phân tích | 🟢 **Market Surveillance Account Group Member Analysis Result** |
| └── `analysis_report` | Báo cáo phân tích tổng hợp (file kết quả, JSON data) | 🟢 **Market Surveillance Analysis Report** |

**Danh mục tham chiếu:** `category_item` với các scheme — `GSGD_WORKFLOW_TYPE` (shared — nhiều cột `workflow_type` trên các bảng `analysis_*`), `GSGD_EXECUTION_STATUS` (cột `analysis_execution_log.status`), `GSGD_TEMPLATE_TYPE` (cột `analysis_execution_log.template_type`), `GSGD_RESULT_TYPE` (shared — cột `result_type` trên `analysis_suspicious_account`, `analysis_account_relationship`, `analysis_account_group`, `analysis_account_group_member`), `GSGD_ANALYSIS_REPORT_TYPE` (bảng-level: loại báo cáo phân tích `analysis_report.report_type`).

### 2.4 Tài khoản nghi vấn (kết luận vụ việc)

**Nghiệp vụ:** Sau khi chạy phân tích, hệ thống tổng hợp danh sách TK nghi vấn cuối cùng và nhóm TK nghi vấn cho vụ việc. Chuyên viên có thể thêm/sửa/xóa TK nghi vấn, phân nhóm theo tiêu chí (Danh tính / IP / MAC / Tiền / Cổ đông lớn). Đây là output nghiệp vụ của vụ việc — được dùng làm căn cứ xử lý (xử phạt, chuyển Công an, tiếp tục theo dõi).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `case_file` | Vụ việc (xem 2.1) | 🟢 **Market Surveillance Case** *(xem 2.1)* |
| ├── `suspicious_account` | TK nghi vấn cuối cùng của vụ việc | 🟢 **Market Surveillance Suspicious Account** |
| └── `suspicious_account_group` | Nhóm TK nghi vấn của vụ việc | 🟢 **Market Surveillance Suspicious Account Group** |

**Danh mục tham chiếu:** `category_item` với scheme `GSGD_SUSPICIOUS_SOURCE` (cột `suspicious_account.source` — 1=Hệ thống tự động, 2=User thêm), `GSGD_RELATIONSHIP_CRITERIA` (bảng-level: tiêu chí phân nhóm nghi vấn `suspicious_account_group.relationship_criteria`).

---

## UID3 — Nhóm chức năng: Quản trị phân hệ & tiện ích

Nhóm chức năng phục vụ Quản trị phân hệ cấu hình hệ thống (quy trình vụ việc, trạng thái, tham số, biểu mẫu báo cáo động, bảng điều hành dashboard, nhóm quyền truy cập). Đồng thời quản lý nhật ký hệ thống (audit trail) và các tiện ích người dùng (hướng dẫn sử dụng, thông báo, biểu mẫu văn bản đi BM109–BM121). Toàn bộ nhóm chức năng này là **operational/system data** phục vụ vận hành phân hệ, không có giá trị nghiệp vụ cho Silver layer.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `system_user` | Người dùng hệ thống | 🔴 (Out of scope) *Operational/system data* |
| ├── `user_group` | Nhóm người dùng | 🔴 (Out of scope) *Operational/system data* |
| ├── `user_group_member` | Thành viên nhóm người dùng | 🔴 (Out of scope) *Operational/system data* |
| └── `system_permission` | Quyền hệ thống | 🔴 (Out of scope) *Operational/system data* |
| `system_config` | Cấu hình hệ thống | 🔴 (Out of scope) *Operational/system data* |
| `system_parameter` | Tham số hệ thống | 🔴 (Out of scope) *Operational/system data* |
| `audit_log` | Nhật ký thao tác người dùng | 🔴 (Out of scope) *Operational/system data* |
| `user_table_config` | Cấu hình hiển thị bảng theo user | 🔴 (Out of scope) *Operational/system data — UI metadata* |
| `report_template` | Mẫu báo cáo (cấu hình UI cho BM001–BM121) | 🔴 (Out of scope) *Operational/system data — UI metadata* |
| └── `report_template_workflow` | Cấu hình biểu mẫu cho quy trình phân tích | 🔴 (Out of scope) *Operational/system data* |
| `analysis_define_report_template` | Tham số cấu hình biểu mẫu báo cáo phân tích | 🔴 (Out of scope) *Pure junction, không có giá trị nghiệp vụ* |

**Danh mục dùng chung (Reference Data):** `category_config` và `category_item` — xem [Phụ lục](#phụ-lục-danh-mục-dùng-chung) bên dưới. Hai bảng này được xử lý thành các Classification Value thay vì tạo Silver entity.

---

## Phụ lục: Danh mục dùng chung

Hai bảng `category_config` và `category_item` lưu trữ toàn bộ danh mục dùng chung của phân hệ GSGD (dropdown, listbox, loại, trạng thái...). Thay vì tạo Silver entity, chúng được xử lý thành **Classification Value schemes** theo Silver design convention.

**Ánh xạ bảng-level:**

| Bảng | Ý nghĩa | Sử dụng bởi | Ánh xạ Silver |
|---|---|---|---|
| `category_config` | Cấu hình danh mục dùng chung (tên, mã danh mục) | Toàn phân hệ | 🔴 (Out of scope) *Reference Data — xử lý thành Classification Value* |
| `category_item` | Item trong danh mục dùng chung | Toàn phân hệ | 🔴 (Out of scope) *Reference Data — xử lý thành Classification Value* |

**Classification Value schemes sinh ra từ `category_item`:**

Có 27 scheme Classification được sinh từ dữ liệu nguồn GSGD, chia thành 2 nhóm:

**Nhóm 1 — Bảng-level (7 scheme, `source_type=source_table`):** Các scheme này map trực tiếp từ `category_item` khi một ID trong category_item được tham chiếu bởi bảng nghiệp vụ thông qua cột `*_id`.

| Scheme | Mô tả | Sử dụng bởi (FK) |
|---|---|---|
| `GSGD_ACCOUNT_RELATION_TYPE` | Loại quan hệ TK: Danh tính / IP / MAC / Tiền / Cổ đông lớn | `account_relationship.category_item_id` |
| `GSGD_ABNORMAL_REPORT_TYPE` | Loại báo cáo bất thường | `abnormal_report.report_type` |
| `GSGD_ANALYSIS_REPORT_TYPE` | Loại báo cáo phân tích vụ việc | `analysis_report.report_type` |
| `GSGD_CASE_STATUS` | Trạng thái vụ việc | `case_file.case_file_status` |
| `GSGD_COMPANY_EVENT_TYPE` | Loại sự kiện tổ chức niêm yết | `company_event.event_type_id` |
| `GSGD_INFORMATION_SOURCE` | Nguồn thông tin vụ việc (Báo cáo Sở / UBCKNN) | `case_file.information_source` |
| `GSGD_RELATIONSHIP_CRITERIA` | Tiêu chí phân nhóm TK nghi vấn | `suspicious_account_group.relationship_criteria` |

**Nhóm 2 — Column-level (20 scheme, `source_type=etl_derived`/`modeler_defined`):** Các scheme này được ETL derive từ giá trị enum trong cột nghiệp vụ (không tham chiếu `category_item`). Bảng cha vẫn giữ Silver entity riêng.

| Scheme | Cột nguồn | Mô tả |
|---|---|---|
| `GSGD_INVESTOR_TYPE` | `investor_account.investor_type` | Cá nhân / Tổ chức |
| `GSGD_ACCOUNT_STATUS` | `investor_account.account_status` | Đóng / Mở |
| `GSGD_DOMESTIC_FOREIGN_FLAG` | `investor_account.domestic_foreign_flag` | Trong nước / Nước ngoài |
| `GSGD_ACCOUNT_GROUP_TYPE` | `account_group.group_type` | Thường / Nghi vấn |
| `GSGD_SECURITIES_GROUP_TYPE` | `securities_group.group_type` | Thường / Theo ngành |
| `GSGD_CASE_TYPE` | `case_file.case_file_type` | MCK / TK-NĐT |
| `GSGD_WORKFLOW_TYPE` | `case_file_workflow.workflow_type` | Sơ bộ / Thao túng / Nội gián / Liên thị trường |
| `GSGD_DATA_TYPE` | `analysis_attribute_define.data_type` | NUMBER / STRING / DATE / BOOLEAN |
| `GSGD_APPROVAL_STATUS` | `abnormal_report.approval_status` | Chờ duyệt / Đã duyệt / Từ chối / Yêu cầu nộp lại |
| `GSGD_APPROVAL_STEP_CODE` | `case_approval_step.step_code` | 4 bước phê duyệt vụ việc |
| `GSGD_APPROVAL_STEP_STATUS` | `case_approval_step.status` | Trạng thái bước phê duyệt |
| `GSGD_FINANCIAL_SERVICE_TYPE` | `account_financial_service.service_type` | Ký quỹ / Ứng trước / HĐ khác |
| `GSGD_SUSPICIOUS_SOURCE` | `suspicious_account.source` | Hệ thống tự động / User thêm |
| `GSGD_FILE_GROUP` | `case_attach_file.file_group` | Hồ sơ Sở / Danh sách TK nghi vấn |
| `GSGD_EXECUTION_STATUS` | `analysis_execution_log.status` | Active / Inactive |
| `GSGD_TEMPLATE_TYPE` | `analysis_execution_log.template_type` | BC tổng hợp / BC phân tích |
| `GSGD_RESULT_TYPE` | `analysis_suspicious_account.result_type` | Kết quả phân tích / Kết quả kiểm tra |
| `GSGD_PERIOD_TYPE` *(shared)* | `abnormal_report.period_type` + `compliance_report_template.period_type` | Loại kỳ báo cáo |
| `GSGD_SUBMITTER_TYPE` | `abnormal_report.submitter_type` | Loại người nộp BC |
| `GSGD_FILE_TYPE` *(shared)* | `case_attach_file.file_type` + `abnormal_report_file.file_type` | Loại file: CSV / XLSX / PDF |

---

## Ghi chú tổng hợp

**Coverage đầy đủ của 47 bảng nguồn:**
- **29 bảng** → Silver entity
- **4 bảng** → Audit Log nguồn (history tables)
- **12 bảng** → Operational/system data (user management, audit log, UI metadata, config)
- **2 bảng** → Reference Data → Classification Value (`category_config`, `category_item`)
- **1 bảng** → Junction denormalize (`securities_group_member`)

**Điểm cần xác nhận (từ HLD 7e):**
1. `account_group.case_file_id` — tiềm ẩn circular dependency account_group ↔ case_file. Đề xuất giữ T1, FK nullable.
2. `abnormal_report.submitter_id` — text không có FK đến entity Silver. Đề xuất giữ denormalized đến khi có mapping tường minh.
3. `case_file.securities_code_id` — FK đến `securities_code` ngoài scope GSGD. Cần xác nhận system nguồn (VSD/HoSE/HNX) để ghi nhận cross-system dependency.
4. `compliance_report_data.row_data` — JSON blob không có schema ổn định. Giữ Silver entity với row_data dạng Text (raw JSON).

