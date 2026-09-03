# Tổng hợp cờ Active / Delete trong phân hệ IDS

Nguồn: `BRD/Source/IDS/brd_IDS_*.yaml` (127 bảng). Tiêu chí gom nhóm là **ý nghĩa nghiệp vụ**, không phải tên cột — vì cùng ý nghĩa "còn hoạt động / đã xóa mềm" nhưng mỗi bảng IDS đặt tên cột khác nhau (`ACTIVE_FLG`, `ACTIVATED_FLG`, `ENABLED`, `STATUS_FLG`, `DELETE_FLG`, `IS_DELETED`...).

- **Cờ Active** (kích hoạt/còn hiệu lực): giá trị dạng "1-Hoạt động/0-Không hoạt động" hoặc "Y/N".
- **Cờ Delete** (xóa mềm): giá trị dạng "1-Đã xóa/0-Chưa xóa".

Các cột dạng `FLG` khác không liệt kê ở đây (VD: `SYNC_FLG`, `APPROVAL_FLG`, `REC_CHANGED_FLG`, `REQUIRED_FLG`, `PUBLISHED_FLG`, `STATUS_FLG` mang nghĩa xử lý SUCCESS/FAILED...) vì mang ý nghĩa nghiệp vụ khác, không phải active/delete.

## 1. Bảng có CẢ 2 cờ (Active + Delete)

| Bảng | Cờ Active | Cờ Delete | Ghi chú |
|---|---|---|---|
| ALERT_TEMPLATE_AUDIT_HDR | `ACTIVE_FLG` — Trạng thái hoạt động | `DELETE_FLG` — Đánh dấu xóa | |
| COMPANY_DIGITAL_CERTIFICATES | `ACTIVE_FLG` — Active status (1 active, 0 inactive) | `DELETE_FLG` — Soft delete flag (0 not deleted, 1 deleted) | |
| COMPANY_ENTITY_ROLE | `ACTIVE_FLG` — Trạng thái (1-Hoạt động, 0-Không hoạt động) | `DELETE_FLG` — Đánh dấu xóa mềm | |
| FORMS | `ACTIVATED_FLG` — Kích hoạt | `DELETE_FLG` — (mô tả trống, theo tên cột) | |
| HOLIDAY_CALENDAR | `ACTIVE_FLG` — Trạng thái hoạt động (1 đang sử dụng, 0 không sử dụng) | `DELETE_FLG` — Đánh dấu xóa mềm | |
| HOLDER_RELATIONSHIP | `ACTIVE_FLG` — Trạng thái (0-Inactive, 1-Active) | `DELETE_FLG` — Đánh dấu xóa mềm | |
| LOOKUP_VALUES | `ACTIVE_FLG` — (mô tả trống) | `DELETE_FLG` — Xóa mềm, "khác với ACTIVE_FLG" (nguồn tự phân biệt rõ 2 cờ) | |
| MANUAL_DOCUMENT | `ACTIVE_FLG` — (mô tả trống) | `DELETE_FLG` — (mô tả trống) | |
| NOTIFICATIONS | `ACTIVE_FLG` — Trạng thái (0-không kích hoạt, 1-kích hoạt) | `DELETE_FLG` — Đánh dấu xóa mềm | |
| POSITIONS | `ACTIVE_FLG` — Có trạng thái chức vụ hiện tại (0-Không, 1-Có) | `DELETE_FLG` — Đánh dấu xóa mềm | `ACTIVE_FLG` ở đây thiên về "chức vụ hiện tại" hơn là active/inactive chung, cần xác nhận lại nếu dùng làm cờ active chuẩn |
| REPORT_CATALOG | `ACTIVE_FLG` — Trạng thái (0 không sử dụng, 1 đang sử dụng) | `IS_DELETED` — Trạng thái xóa (0 chưa xóa, 1 đã xóa) | Tên cờ delete khác biệt (`IS_DELETED` thay vì `DELETE_FLG`) |
| VIOLATION_PENALTY_CONFIG | `ACTIVE_FLG` — Cờ trạng thái hoạt động (1 Hoạt động, 0 Vô hiệu) | `DELETE_FLG` — Cờ xóa logic (1 Đã xóa, 0 Chưa xóa) | |
| VIOLATION_TEMPLATES | `ACTIVE_FLG` — Cờ trạng thái hoạt động (1 Hoạt động, 0 Vô hiệu) | `DELETE_FLG` — Cờ xóa logic (1 Đã xóa, 0 Chưa xóa) | |
| FIELDS | — | — | Chỉ có **1 cột duy nhất** `DELETE_FLG` nhưng mô tả gộp cả 2 ý nghĩa: "Cờ kích hoạt (1 - active, 0 - deleted soft delete)". Xem mục 4. |

## 2. Bảng chỉ có cờ Active (không có cờ Delete)

| Bảng | Cờ Active | Mô tả |
|---|---|---|
| CATEGORIES | `ACTIVE_FLG` + `STATUS_FLG` | `ACTIVE_FLG`="Chọn" (mô tả mơ hồ); `STATUS_FLG`="1: Active; 0: Inactive" — 2 cột cùng mang nghĩa active, có thể trùng lặp |
| COUNTRIES | `ACTIVE_FLG` + `STATUS_FLG` | Cả 2 đều mô tả trống — cần xác nhận với nguồn cột nào thực sự dùng |
| DEPARTMENTS | `ACTIVE_FLG` | Kích hoạt |
| FIELDS_MGR | `ACTIVATED_FLG` | Mô tả trống |
| FORM_FIELDS | `ACTIVE_FLG` | 0-không hoạt động, 1-đang hoạt động |
| INTEGRATION_JOB_DEFINITION | `ENABLED` (VARCHAR2) | Y=bật; N (hoặc khác Y)=tắt — dùng Y/N thay vì 1/0 |
| INTG_FINANCIAL_STATEMENT | `ACTIVE_FLG` | Trạng thái hoạt động |
| INTG_FORM_MAPPING | `ACTIVE_FLG` | Active flag |
| INTG_REPORT_CONFIG | `ACTIVE_FLG` | Active flag |
| INTG_REPORT_FIELD | `ACTIVE_FLG` | Trạng thái (1 Đang hoạt động, 0 Không hoạt động) |
| LOGINS | `ACTIVE_FLG` | Trạng thái hoạt động |
| PROVINCES | `ACTIVE_FLG` + `STATUS_FLG` | `ACTIVE_FLG`="Trạng thái sử dụng"; `STATUS_FLG`="Tình trạng" — có thể trùng lặp |
| SYS_PARAMETERS | `ACTIVE_FLG` | Mô tả trống |
| WARDS | `ACTIVE_FLG` + `STATUS_FLG` | Tương tự PROVINCES |

## 3. Bảng chỉ có cờ Delete (không có cờ Active)

| Bảng | Cờ Delete | Mô tả |
|---|---|---|
| ACCOUNT_NUMBERS | `DELETE_FLG` | Đánh dấu xóa mềm - 1:Xóa, 0:Không xóa |
| AF_APPROVAL | `DELETE_FLG` | (trống) |
| AF_AUDITOR_PROFILES | `DELETE_FLG` | (trống) — bảng này còn có `REC_CHANGED_FLG` (không phải active/delete) |
| AF_AUDITOR_STATUS_HISTORY | `DELETE_FLG` | (trống) |
| AF_INSPECTION | `DELETE_FLG` | Soft delete - 0: Active, 1: Deleted |
| AF_LEGAL_REPRESENTATIVE | `DELETE_FLG` | (trống) |
| AF_PROFILES | `DELETE_FLG` | (trống) |
| AF_SANCTIONS | `DELETE_FLG` | (trống) |
| AF_STATUS_HISTORY | `DELETE_FLG` | (trống) |
| AF_SUSPENSION | `DELETE_FLG` | Soft delete - 0: Active, 1: Deleted |
| AF_TECHNICAL_AUDIT | `DELETE_FLG` | Soft delete flag - 0: Active, 1: Deleted |
| AF_WARNING | `DELETE_FLG` | Soft delete - 0: Active, 1: Deleted |
| BOND_LISTING_HISTORY | `IS_DELETED` | Trạng thái xóa (0 chưa xóa, 1 đã xóa) |
| CAPITAL_MOBILIZATION | `DELETE_FLG` | Ghi nhận bản ghi đã xóa hay không |
| COMPANY_ADD_CAPITAL | `DELETE_FLG` | Ghi nhận bản ghi đã xóa hay không |
| COMPANY_INSPECTION | `DELETE_FLG` | (trống) |
| COMPANY_PENALTIES | `DELETE_FLG` | (trống) |
| COMPANY_PROFILES | `DELETE_FLG` | Trạng thái xoá |
| COMPANY_RELATIONSHIP | `DELETE_FLG` | Đánh dấu xóa mềm (0 Chưa xóa; 1 Đã xóa) |
| COMPANY_SHAREHOLDING | `DELETE_FLG` | Đánh dấu xóa mềm - 1:Xóa, 0:Không xóa |
| COMPANY_TENDER_OFFER | `DELETE_FLG` | (trống) |
| COMPANY_TENDER_OFFER_RESULT | `DELETE_FLG` | Đánh dấu xóa mềm (0 Chưa xóa; 1 Đã xóa) |
| COMPANY_TREASURY_SHARES | `DELETE_FLG` | Đánh dấu trạng thái xóa mềm: 1-Xóa; 0-Chưa xóa |
| COMPANY_TREASURY_STOCKS | `DELETE_FLG` | Xóa mềm (0 chưa xóa, 1 đã xóa) |
| DYNAMIC_REPORT_TEMPLATES | `DELETE_FLG` | (trống) |
| FOREIGN_OWNER_LIMIT | `DELETE_FLG` | Đánh dấu xóa mềm (1 Xóa, 0 Chưa xóa) |
| HTE_NOTIFICATIONS_DTL | `DELETE_FLG` | (trống, data_type NUMBER(10,0) — khác kiểu chuẩn NUMBER(1,0)) |
| IDENTITY | `DELETE_FLG` | Cờ xóa mềm: 0-Hoạt động, 1-Đã xóa |
| LEGAL_ENTITIES | `DELETE_FLG` | Đánh dấu xóa mềm - 1:Xóa, 0:Không xóa |
| LEGAL_REPRESENTATIVE | `DELETE_FLG` | Đánh dấu xóa mềm (1 Xóa, 0 Chưa xóa) |
| NOTIFICATIONS_DTL | `DELETE_FLG` | Đánh dấu xóa mềm |
| PUB_COMPANY_CANCELLATION | `DELETE_FLG` | (trống) |
| PUB_COMPANY_REGISTRATION | `DELETE_FLG` | (trống) |
| REP_COLUMN | `DELETE_FLG` | Xóa mềm |
| REP_FORMS | `DELETE_FLG` | Xóa mềm |
| REP_ROW | `DELETE_FLG` | Xóa mềm |
| SECURITIES_OFFERING | `DELETE_FLG` | Đánh dấu trạng thái xóa mềm: 1-Xóa; 0-Chưa xóa |
| SECURITIES_OFFERING_PLAN | `DELETE_FLG` | (trống) |
| SECURITIES_OFFERING_RESULT | `DELETE_FLG` | Đánh dấu trạng thái xóa mềm: 1-Xóa; 0-Chưa xóa |
| STATE_CAPITAL | `DELETE_FLG` | Đánh dấu xóa mềm (1 Xóa, 0 Chưa xóa) |
| STOCK_CONTROLS | `DELETE_FLG` | Đánh dấu xóa mềm - 1:Xóa, 0:Không xóa |
| STOCK_LISTING_HISTORY | `DELETE_FLG` | Soft Delete mark |
| TENDER_OFFER | `DELETE_FLG` | Đánh dấu xóa mềm (0 Chưa xóa, 1 Đã xóa) |
| TENDER_OFFER_RESULT | `DELETE_FLG` | Đánh dấu xóa mềm (0 Chưa xóa, 1 Đã xóa) |
| TREASURY_SHARE_TRANS_RESULT | `DELETE_FLG` | Đánh dấu trạng thái xóa mềm: 1-Xóa; 0-Chưa xóa |

## 4. Trường hợp đặc biệt cần Data Modeler xác nhận lại với nguồn

Các cột dưới đây có **tên cột không khớp ý nghĩa mô tả** — rất dễ gây hiểu sai khi map sang Atomic (`ds_is_deleted` / `ds_is_active`). Cần đối chiếu lại với DBA/nguồn IDS trước khi map.

| Bảng | Cột | Mô tả trong BRD | Vấn đề |
|---|---|---|---|
| RCOL | `DELETE_FLG` | "Trạng thái - (0 - không sử dụng, 1 - đang sử dụng)" | Tên cột là DELETE_FLG nhưng mô tả lại là cờ **active/in-use**, ngược nghĩa xóa mềm thông thường |
| RROW | `DELETE_FLG` | "Trạng thái (0 không sử dụng, 1 - đang sử dụng)" | Tương tự RCOL — tên gợi ý delete nhưng mô tả là active |
| FIELDS | `DELETE_FLG` | "Cờ kích hoạt (1 - active, 0 - deleted soft delete)" | 1 cột duy nhất gộp cả 2 ý nghĩa active + delete, polarity ngược với DELETE_FLG chuẩn (1 = active, không phải 1 = deleted) |
| CATEGORIES / COUNTRIES / PROVINCES / WARDS | `ACTIVE_FLG` **và** `STATUS_FLG` cùng tồn tại | Mô tả mơ hồ hoặc trống | Nghi ngờ 2 cột trùng lặp ý nghĩa active trên cùng 1 bảng — chỉ nên chọn 1 làm nguồn map, ưu tiên xác nhận cột nào thực tế được ứng dụng dùng |

## Ghi chú tổng hợp

- Tổng số bảng có cờ Active và/hoặc Delete (ý nghĩa, không theo tên): **~52 bảng** trong tổng 127 bảng IDS.
- Không đưa vào danh sách: cột `FLG` mang ý nghĩa nghiệp vụ khác (VD: `SYNC_FLG`, `REC_CHANGED_FLG`, `APPROVAL_FLG`, `PUBLISHED_FLG`, `STATUS_FLG` dạng SUCCESS/FAILED trong `INTG_IMPORT_DATA_LOG`/`HTE_INTG_IMPORT_DATA_LOG`...).
- Khi thiết kế Atomic: theo quy tắc CLAUDE.md, các cờ này thuộc nhóm **Indicator/Boolean** (data domain chuẩn), map về field `ds_is_active` / `ds_is_deleted` (prefix `ds_`) — không giữ tên gốc T24-style của IDS.
