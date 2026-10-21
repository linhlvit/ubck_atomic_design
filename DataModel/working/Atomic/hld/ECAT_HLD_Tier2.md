# ECAT HLD — Tier 2

**Source system:** ECAT (Dịch vụ đồng bộ danh mục dùng chung từ HTTT)
**Tier 2:** Không có entity Atomic trong scope — chưa có LLD. Theo quyết định Data Modeler 2026-10-21 (LLD là chuẩn), các entity từng thiết kế ở tier này (Classification Enterprise Type, Classification Security Type, Par Value, Administrative Procedure, Administrative Procedure Component, Legal Document, Working Schedule, Violation Type, Regulatory Authority Organization Unit) đã gỡ khỏi HLD; bảng nguồn tương ứng nằm ở 7f Overview (nhóm `Chưa có LLD`).

> **Lưu ý FK audit:** Toàn bộ cột `CREATED_BY_ID`/`CREATED_BY_NAME`/`UPDATED_BY_ID`/`UPDATED_BY_NAME` (FK → UBCK_STAFF.ID) trên mọi bảng ECAT là **audit trail** theo pattern audit fields trong CLAUDE.md — KHÔNG tính là business dependency khi phân Tier.

---

## 6a. Bảng tổng quan BCV Concept

*(Không có entity Atomic trong scope — chưa có LLD.)*

---

## 6b. Diagram Source (Mermaid)

*(Không có.)*

---

## 6c. Diagram Atomic (Mermaid)

*(Không có.)*

---

## 6d. Mục Danh mục & Tham chiếu (Reference Data)

| Source Field / Bảng | Mô tả | Scheme Code | source_type | Ghi chú |
|---|---|---|---|---|
| MARKET | Danh mục Thị trường (chỉ CODE + NAME) | `ECAT_MARKET` | source_table | Chỉ CODE + NAME. |
| FINANCIAL_INDICATOR | Danh mục Chỉ tiêu tài chính | `ECAT_FINANCIAL_INDICATOR` | source_table | Chỉ NAME, không FK nào khác. |
| FINANCIAL_REPORT_TYPE | Danh mục Loại báo cáo tài chính | `ECAT_FINANCIAL_REPORT_TYPE` | source_table | Chỉ NAME. |
| INVESTOR_CATEGORY | Danh mục loại nhà đầu tư/cổ đông | `ECAT_INVESTOR_CATEGORY` | source_table | Chỉ NAME. |
| INVESTOR_TYPE | Loại hình nhà đầu tư/cổ đông | `ECAT_INVESTOR_TYPE` | source_table | Có thêm `APPLICABLE_TYPE` (phân loại áp dụng) — LLD xác nhận có cần tách value riêng không. |
| FUND_TYPE | Danh mục loại hình quỹ | `ECAT_FUND_TYPE` | source_table | Chỉ NAME. |
| APPLIED_SUBJECT | Danh mục Đối tượng áp dụng | `ECAT_APPLIED_SUBJECT` | source_table | Chỉ NAME. |
| FREQUENCY_REPORT | Danh mục Kỳ báo cáo | `ECAT_FREQUENCY_REPORT` | source_table | Chỉ NAME. |
| RELATIONSHIP_CATEGORY | Danh mục Quan hệ | `ECAT_RELATIONSHIP_CATEGORY` | source_table | Có `APPLIED_TO` — thuộc tính mô tả phạm vi áp dụng của category. |
| QUALIFICATION_CATEGORY | Danh mục Trình độ | `ECAT_QUALIFICATION_CATEGORY` | source_table | NAME + DESCRIPTION + DISPLAY_LABEL. |
| PRACTICE_CERTIFICATE_TYPE | Danh mục Loại chứng chỉ hành nghề | `ECAT_PRACTICE_CERTIFICATE_TYPE` | source_table | Có `DOSSIER_COMPONENTS` (text mô tả thành phần hồ sơ) — giữ như attribute mô tả của scheme value. |
| PRACTICE_CERTIFICATE | Danh mục Chứng chỉ hành nghề | `ECAT_PRACTICE_CERTIFICATE` | source_table | Chỉ NAME — độc lập với PRACTICE_CERTIFICATE_TYPE (không có FK giữa 2 bảng theo khảo sát cột). |
| ORGANIZATION_TYPE | Danh mục loại tổ chức (nội bộ/tổ chức ngoài/cá nhân ngoài) | `ECAT_ORGANIZATION_TYPE` | source_table | BCV: "[Involved Party] Organization Type" (id 11321) — reference data. |
| FOREIGN_INVESTOR_TYPE | Danh mục loại nhà đầu tư nước ngoài | `ECAT_FOREIGN_INVESTOR_TYPE` | source_table | CODE + NAME + DESCRIPTION. |
| ACTIVITY_STATUS | Danh mục tình trạng hoạt động | `ECAT_ACTIVITY_STATUS` | source_table | NAME + DESCRIPTION. |
| ACTIVE_STATUS | Bảng trạng thái hoạt động | `ECAT_ACTIVE_STATUS` | source_table | Chỉ ID + NAME — reference data thuần túy nhất trong tier này. |
| PENALTY_FORM | Danh mục Hình thức xử phạt | `ECAT_PENALTY_FORM` | source_table | NAME + CATEGORY + LEGAL_BASE + STATUS. |
| INSPECTION_TARGET | Danh mục Đối tượng thanh tra | `ECAT_INSPECTION_TARGET` | source_table | NAME + DESCRIPTION (mô tả bảng nguồn "Tổ chức kiểm toán được chấp thuận" trong `brd_ECAT.yaml` là lỗi copy-paste — nội dung cột thực tế là danh mục đối tượng thanh tra). |
| ENTERPRISE_POSITION_TYPE | Danh mục Loại chức vụ doanh nghiệp | `ECAT_ENTERPRISE_POSITION_TYPE` | source_table | NAME + 2 cờ (INFORMATION_DISCLOSURE, BOARD_MEMBER) mô tả đặc tính loại chức vụ. |
| ENTERPRISE_POSITION | Danh mục Chức vụ doanh nghiệp | `ECAT_ENTERPRISE_POSITION` | source_table | FK → ENTERPRISE_POSITION_TYPE (CV khác) — fold `enterprise_position_type_code`. |
| POSITION_TYPE | Danh mục Loại chức danh | `ECAT_POSITION_TYPE` | source_table | Cấu trúc giống hệt ENTERPRISE_POSITION_TYPE (NAME + INFORMATION_DISCLOSURE + BOARD_MEMBER) nhưng khác bảng nguồn, giữ scheme riêng theo đúng tên nguồn. |
| POSITION | Danh mục Chức danh | `ECAT_POSITION` | source_table | FK → POSITION_TYPE (CV) — fold `position_type_code` (1 field). |
| AGENT_TYPE | Danh mục loại đại lý | `ECAT_AGENT_TYPE` | source_table | FK → FUND_TYPE (CV) — fold `fund_type_code`. |
| BUSINESS_SERVICE | Danh mục Dịch vụ kinh doanh | `ECAT_BUSINESS_SERVICE` | source_table | NAME + mô tả. |
| BUSINESS_EVENT | Danh mục Sự vụ | `ECAT_BUSINESS_EVENT` | source_table | NAME + ADJUSTMENT_DECLARATION (cờ). |
| OPERATIONAL_STATUS_TYPE | Danh mục Loại trạng thái hoạt động | `ECAT_OPERATIONAL_STATUS_TYPE` | source_table | NAME + REPORTING_REQUIRED (cờ). |
| CURRENCY | Danh mục Tiền tệ | `ECAT_CURRENCY` | source_table | BCV: "[Common] Currency" — theo CLAUDE.md rule #4 ("Tương tự cho Currency"), xử lý như Classification Value (1 field Code, không cặp Id+Code). |

---

## 6e. Bảng chờ thiết kế

*(Không có.)*

---

## 6f. Điểm cần xác nhận

| # | Câu hỏi | Kết quả |
|---|---|---|
| T2-01 | `PRACTICE_CERTIFICATE_TYPE` và `PRACTICE_CERTIFICATE` là 2 bảng danh mục riêng biệt, không có FK giữa 2 bảng theo khảo sát cột nguồn (khác kỳ vọng ban đầu là TYPE cha của CERTIFICATE). Xác nhận đây có đúng là 2 danh mục độc lập trong nghiệp vụ, không phải lỗi thiếu FK ở nguồn. | Chưa xác nhận. |
| T2-02 | `INSPECTION_TARGET`: mô tả bảng trong `brd_ECAT.yaml` ghi "Danh mục Tổ chức kiểm toán được chấp thuận" — nhiều khả năng là lỗi copy-paste từ APPROVED_AUDIT_FIRM. Nội dung cột thực tế (NAME "Tên đối tượng thanh tra") cho thấy đây là danh mục đối tượng thanh tra thuộc UID-14. Đề xuất sửa `table_meaning` trong `brd_ECAT.yaml` khi có dịp. | Đã xử lý theo nội dung cột thực tế — chưa sửa `brd_ECAT.yaml`. |
