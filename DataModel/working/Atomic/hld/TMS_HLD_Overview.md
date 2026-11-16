# TMS — HLD Overview: Toàn cảnh thiết kế Atomic Layer

> **Nguồn:** Hệ thống TMS (schema UAT_TMS) — phân hệ giám sát giao dịch bất thường và quản lý hồ sơ vụ việc (Oracle). Tài liệu trước đây đặt tên "GSGD".
>
> **Trạng thái:** Theo quyết định Data Modeler 2026-10-21, **LLD là chuẩn** ("LLD đã đủ cho dự án, HLD có mà LLD chưa làm là sai"). TMS **không có LLD** (không có thư mục `lld/TMS/`, không có trong `manifest.yaml`), nên toàn bộ 12 Atomic entity từng thiết kế ở HLD đã gỡ; 14 bảng nguồn thuộc phạm vi cũ chuyển vào mục 7f nhóm `Chưa có LLD`. Các bảng TMS khác (ANALYSIS_*, SUSPICIOUS_ACCOUNT*, REPORT_TEMPLATE*, ANALYSIS_WORKFLOW*, ABNORMAL_REPORT*, COMPLIANCE_REPORT*, CATEGORY_ITEM, TRANSACTION_REVIEW*, hệ thống/cấu hình...) chưa được đánh giá scope.
>
> **[CẬP NHẬT 2026-11-16]** Entity `Compliance Report` (nguồn `COMPLIANCE_REPORT_MASTER`, thêm 2026-10-28) đã **xóa** theo yêu cầu Data Modeler — bảng này đã được dùng để xây dựng 2 bảng ODS bên dưới (`COMPLIANCE_REPORT_STRUCTURE`, `COMPLIANCE_REPORT_VALUE`). LLD, entity, scheme `TMS_AUTO_CHECK_STATUS`/`TMS_COMPLIANCE_APPROVAL_STATUS` và file Atomic sinh ra từ MASTER cũng đã gỡ.
>
> **[CẬP NHẬT 2026-11-15, chỉnh 2026-11-16]** Thiết kế bổ sung 2 entity lấy từ tầng ODS, không có bảng nguồn BRD (nguồn `TMS.xlsx` + `note_logic_ods_tms_report_cho_atomic_20261111.md`): `COMPLIANCE_REPORT_STRUCTURE` → `Compliance Report Structure` (Tier 1, physical `cr_structure`, `[Documentation] Form Document`, Relative, hash_id = `form_code` + `column_code`) và `COMPLIANCE_REPORT_VALUE` → `Compliance Report Value` (Tier 2, physical `cr_value`, `[Documentation] Regulatory Information`, Classification, hash_id = `form_code` + `column_code` + `row_index` + `submission_dt`). Cột ODS `Map? = không` trong `TMS.xlsx` không lên Atomic. LLD đã `approved` (2026-11-16); điểm còn mở xem 7e #1–#6.
>
> **File chi tiết theo tầng:** [TMS_HLD_Tier1.md](TMS_HLD_Tier1.md) (2 entity), [TMS_HLD_Tier2.md](TMS_HLD_Tier2.md) (1 entity), [TMS_HLD_Tier3.md](TMS_HLD_Tier3.md) — Tier 3 không có entity Atomic trong scope.

---

#### 7a. Bảng tổng quan Atomic entities

| Tier | BCV Core Object | BCV Concept | Category | Source Table | Source Table Change Mode | Mô tả bảng nguồn | Atomic Entity | Table Type | BCV Term |
|---|---|---|---|---|---|---|---|---|---|
| T1 | Documentation | [Documentation] Form Document | Compliance Report Management | COMPLIANCE_REPORT_STRUCTURE | N/A | Bảng ODS (không BRD): 1 dòng = 1 cột (chỉ tiêu) của 1 biểu mẫu báo cáo tuân thủ — mã/tên biểu mẫu, mã phụ lục, trạng thái, phiên bản, `key_columns`, thứ tự/mã/nhãn cột | Compliance Report Structure | Relative | (1) Form Document — BCV: "Documentation Item presented in a standard template layout"; Regulatory Report không chọn vì bảng không chứa dữ liệu nộp. (2) Bảng mô tả khung biểu mẫu + danh sách cột, không chứa dữ liệu nộp. (3) Cùng cách xử lý `Dynamic Report Structure` (FMS); Table Type = Relative theo `TMS.xlsx`; hash_id = `form_code` + `column_code`. Chi tiết xem TMS_HLD_Tier1.md. |
| T2 | Documentation | [Documentation] Regulatory Information | Compliance Report Management | COMPLIANCE_REPORT_VALUE | N/A | Bảng ODS (không BRD): 1 dòng = 1 giá trị của 1 cột (ô) trong 1 dòng dữ liệu của 1 lần nộp biểu mẫu, kèm kỳ báo cáo, loại người nộp, thời điểm và tên file tải lên | Compliance Report Value | Classification | (1) Regulatory Information — BCV: "Reported Information that is required to be filed with regulatory bodies"; Regulatory Report không chọn vì 1 dòng là 1 ô giá trị, không phải 1 báo cáo. (2) Bảng chứa giá trị đã nộp theo từng ô (`cell_val`, `row_index`). (3) Cùng BCV với `Dynamic Report Value` (FMS); Table Type = Classification (ETL Upsert) theo `TMS.xlsx`, xem 7e #7; hash_id = `form_code` + `column_code` + `row_index` + `submission_dt`. Chi tiết xem TMS_HLD_Tier2.md. |

**Tổng: 3 Atomic entity** (T1: 2, T2: 1)

---

#### 7b. Diagram Atomic tổng (Mermaid)

```mermaid
graph TD
    subgraph T1["Tier 1 — Independent Entities"]
        CRS["Compliance Report Structure"]
    end
    subgraph T2["Tier 2 — Phụ thuộc Tier 1"]
        CRV["Compliance Report Value"]
    end
    CRS --> CRV
```

---

#### 7c. Bảng Classification Value

| Source Table | Mô tả | BCV Term | Xử lý Atomic |
|---|---|---|---|
| INVESTOR_ACCOUNT.APPROVAL_STATUS / COMPANY_EVENT.APPROVAL_STATUS / ACCOUNT_GROUP.APPROVAL_STATUS | Trạng thái phê duyệt | Classification Value | Scheme: `GSGD_APPROVAL_STATUS` (dùng chung 3 bảng, cần profile riêng nếu value set khác nhau). |
| INVESTOR_ACCOUNT.INVESTOR_TYPE | Loại hình nhà đầu tư (1=Cá nhân, 2=Tổ chức) | Classification Value | Scheme: `GSGD_INVESTOR_TYPE`. |
| INVESTOR_ACCOUNT.ACCOUNT_STATUS | Trạng thái tài khoản (0=Đóng, 1=Mở) | Classification Value | Scheme: `GSGD_INVESTOR_ACCOUNT_STATUS` (khác `GSGD_ACCOUNT_STATUS` — scheme đó dùng cho ACCOUNT_GROUP_MEMBER.STATUS, ý nghĩa khác). |
| INVESTOR_ACCOUNT.DOMESTIC_FOREIGN_FLAG | Trong nước/Nước ngoài (0=Trong nước, 1=Nước ngoài) | Classification Value | Scheme: `GSGD_DOMESTIC_FOREIGN_FLAG`. Cân nhắc Data Domain Indicator thay vì Classification Value — quyết định tại LLD. |
| COMPANY_EVENT.EVENT_TYPE | Loại sự kiện tổ chức niêm yết | Classification Value | Scheme: `GSGD_COMPANY_EVENT_TYPE`. |
| SECURITIES_GROUP.GROUP_TYPE | Loại nhóm chứng khoán | Classification Value | Scheme: `GSGD_SECURITIES_GROUP_TYPE`. |
| SECURITIES_GROUP.STATUS | Trạng thái nhóm chứng khoán | Classification Value | Scheme: `GSGD_GROUP_STATUS`. Cần profile giá trị thực tế. |
| CASE_FILE.CASE_FILE_TYPE / CASE_FILE_WORKFLOW.WORKFLOW_TYPE | Loại vụ việc / loại quy trình | Classification Value | Scheme: `GSGD_CASE_TYPE` (dùng chung — cùng bộ giá trị Sơ bộ/Thao túng/Nội gián/Liên thị trường). |
| CASE_FILE.INFORMATION_SOURCE | Nguồn thông tin vụ việc | Classification Value | Scheme: `GSGD_INFORMATION_SOURCE`. |
| CASE_FILE.CASE_FILE_STATUS | Trạng thái vụ việc | Classification Value | Scheme: `GSGD_CASE_STATUS`. |
| ACCOUNT_FINANCIAL_SERVICE.SERVICE_TYPE | Loại dịch vụ tài chính | Classification Value | Scheme: `GSGD_FINANCIAL_SERVICE_TYPE`. |
| ACCOUNT_GROUP.GROUP_TYPE | Loại nhóm tài khoản | Classification Value | Scheme: `GSGD_ACCOUNT_GROUP_TYPE`. |
| ACCOUNT_GROUP.RELATION_TYPE_ID / ACCOUNT_RELATIONSHIP.CATEGORY_ITEM_ID | Loại quan hệ (Danh tính/IP/MAC/Tiền) | Classification Value | Scheme: `GSGD_ACCOUNT_RELATION_TYPE` (dùng chung 2 bảng). FK suy luận → CATEGORY_ITEM, ngoài phạm vi task. |
| CASE_ATTACH_FILE.FILE_TYPE | Loại file đính kèm | Classification Value | Scheme: `GSGD_FILE_TYPE`. |
| CASE_ATTACH_FILE.FILE_GROUP | Nhóm file đính kèm | Classification Value | Scheme: `GSGD_FILE_GROUP`. |
| CASE_APPROVAL_STEP.STEP_CODE / NEXT_STEP_CODE | Mã bước duyệt | Classification Value | Scheme: `GSGD_APPROVAL_STEP_CODE`. |
| CASE_APPROVAL_STEP.STATUS / CASE_FILE_WORKFLOW.STATUS | Trạng thái bước duyệt/quy trình | Classification Value | Scheme: `GSGD_APPROVAL_STEP_STATUS` (dùng chung — value set có thể khác nhau, cần profile riêng). |
| ACCOUNT_GROUP_MEMBER.STATUS | Trạng thái tài khoản trong nhóm | Classification Value | Scheme: `GSGD_ACCOUNT_STATUS`. |
| COMPLIANCE_REPORT_STRUCTURE.STATUS | Trạng thái biểu mẫu báo cáo (0=Không hoạt động, 1=Hoạt động) | Classification Value | Scheme: `TMS_REPORT_FORM_STATUS`. Cân nhắc Indicator — quyết định tại LLD. |
| COMPLIANCE_REPORT_VALUE.PERIOD_TP | Kỳ báo cáo: DAILY/WEEKLY/MONTHLY/YEARLY | Classification Value | Scheme: `TMS_REPORT_PERIOD_TYPE`. |
| COMPLIANCE_REPORT_VALUE.SUBMITTER_TP | Loại người nộp báo cáo | Classification Value | Scheme: `TMS_SUBMITTER_TYPE` (modeler_defined — cần profile). |

---

#### 7d. Junction Tables

Không có junction table.

---

#### 7e. Điểm cần xác nhận

| # | Tier | Câu hỏi | Ảnh hưởng |
|---|---|---|---|
| 1 | T2 | Hash_id `Compliance Report Value` = `form_code` + `column_code` + `row_index` + `submission_dt` (Data Modeler chốt 2026-11-16; `submission_id`/`form_id` không map). Khóa không chứa đơn vị nộp (ODS không có `SUBMITTER_ID`), `submission_dt` chỉ đến mức ngày, `row_index` bắt đầu từ 1 mỗi lần nộp (Tier2 T2-01) | Hai lần nộp cùng biểu mẫu trong cùng 1 ngày vẫn trùng hash, upsert chỉ giữ 1 lần. Cần xác nhận hoặc thêm `period_*` vào hash |
| 2 | T1 | Hash_id `Compliance Report Structure` = `form_code` + `column_code` (Data Modeler chốt 2026-11-16; không gồm `template_code`). Cần xác nhận `form_code` duy nhất toàn cục (Tier1 T1-09) | Nếu không duy nhất phải thêm `template_code` vào hash |
| 3 | T1/T2 | Table Type: `Compliance Report Structure` = Relative nhưng chưa có FK Fundamental (Tier1 T1-08); `Compliance Report Value` = Classification dù chứa instance data (Tier2 T2-02) | Xác nhận ETL pattern (Upsert/SCD2 hay Snapshot) |
| 4 | T1 | Đặt tên (Data Modeler chốt 2026-11-16): `Compliance Report Structure` → `cr_structure`, `Compliance Report Value` → `cr_value`; Domain Prefix `Compliance Report` → `cr` (Tier1 T1-11). Entity `Compliance Report` cũ (nguồn MASTER) đã xóa 2026-11-16 nên không còn xung đột tên | Đã chốt |
| 5 | T1/T2 | Structure lặp thông tin biểu mẫu trên mỗi cột (Tier1 T1-10); Value lặp thuộc tính kỳ/người nộp ở mọi dòng giá trị (Tier2 T2-04); Value FK về Structure phải nullable (Tier2 T2-03) | Chờ quyết định tách entity |
| 6 | T1 | Tên bảng nguồn và tên cột ghi theo `TMS.xlsx` (khác note ODS); Change Mode = N/A; không `ds_*` (Tier1 T1-12) | Xác nhận |

---

#### 7f. Bảng ngoài scope

| Nhóm | Source Table | Mô tả bảng nguồn | Lý do ngoài scope |
|---|---|---|---|
| Khảo sát sai | ACCOUNT_AUTHORIZATION | Thông tin ủy quyền giao dịch trên tài khoản (theo khảo sát cũ) | Không tồn tại trong DDL UAT thực tế (schema UAT_TMS) — dữ liệu khảo sát nguồn lỗi thời/sai sót, đã reconcile 2026-07-23. Nghiệp vụ ủy quyền đã nằm sẵn trên INVESTOR_ACCOUNT.AUTHORIZED_PERSON_NAME/AUTHORIZATION_DATE. |
| Chưa có LLD | INVESTOR_ACCOUNT | Thông tin tài khoản nhà đầu tư (từ VSDC) | Không có LLD trong dự án — HLD gỡ theo quyết định Data Modeler 2026-10-21 |
| Chưa có LLD | INVESTOR_ACCOUNT_EXTENDED_INFO | Thông tin mở rộng tài khoản (liên hệ/ngân hàng) | Không có LLD trong dự án — HLD gỡ theo quyết định Data Modeler 2026-10-21 |
| Chưa có LLD | COMPANY_EVENT | Sự kiện tổ chức niêm yết ảnh hưởng giá tham chiếu | Không có LLD trong dự án — HLD gỡ theo quyết định Data Modeler 2026-10-21 |
| Chưa có LLD | SECURITIES_GROUP | Nhóm chứng khoán do Ban GSTT tự quản lý | Không có LLD trong dự án — HLD gỡ theo quyết định Data Modeler 2026-10-21 |
| Chưa có LLD | SECURITIES_GROUP_MEMBER | Thành viên nhóm chứng khoán (GROUP_ID + SECURITIES_CODE) | Không có LLD trong dự án — HLD gỡ theo quyết định Data Modeler 2026-10-21 |
| Chưa có LLD | CASE_FILE | Vụ việc giám sát giao dịch chứng khoán bất thường | Không có LLD trong dự án — HLD gỡ theo quyết định Data Modeler 2026-10-21 |
| Chưa có LLD | ACCOUNT_FINANCIAL_SERVICE | Dịch vụ tài chính đăng ký trên tài khoản | Không có LLD trong dự án — HLD gỡ theo quyết định Data Modeler 2026-10-21 |
| Chưa có LLD | ACCOUNT_GROUP | Nhóm tài khoản do nghiệp vụ giám sát xác định | Không có LLD trong dự án — HLD gỡ theo quyết định Data Modeler 2026-10-21 |
| Chưa có LLD | CASE_ATTACH_FILE | File đính kèm vụ việc | Không có LLD trong dự án — HLD gỡ theo quyết định Data Modeler 2026-10-21 |
| Chưa có LLD | CASE_FILE_WORKFLOW | Từng bước quy trình xử lý vụ việc | Không có LLD trong dự án — HLD gỡ theo quyết định Data Modeler 2026-10-21 |
| Chưa có LLD | CASE_APPROVAL_STEP | Nhật ký duyệt từng bước xử lý vụ việc | Không có LLD trong dự án — HLD gỡ theo quyết định Data Modeler 2026-10-21 |
| Chưa có LLD | CASE_FILE_SECURITIES_CODE | Mã chứng khoán liên quan tới vụ việc (N-N) | Không có LLD trong dự án — HLD gỡ theo quyết định Data Modeler 2026-10-21 |
| Chưa có LLD | ACCOUNT_GROUP_MEMBER | Quan hệ thành viên giữa tài khoản và nhóm giám sát | Không có LLD trong dự án — HLD gỡ theo quyết định Data Modeler 2026-10-21 |
| Chưa có LLD | ACCOUNT_RELATIONSHIP | Mối quan hệ giữa 2 tài khoản NĐT trong giám sát | Không có LLD trong dự án — HLD gỡ theo quyết định Data Modeler 2026-10-21 |

*(Các bảng TMS khác ngoài 15 bảng phạm vi cũ — ANALYSIS_*, SUSPICIOUS_ACCOUNT*, REPORT_TEMPLATE*, ANALYSIS_WORKFLOW*, ABNORMAL_REPORT*, COMPLIANCE_REPORT* (gồm COMPLIANCE_REPORT_MASTER — entity Atomic đã xóa 2026-11-16 vì đã được dùng để dựng 2 bảng ODS `COMPLIANCE_REPORT_STRUCTURE`/`COMPLIANCE_REPORT_VALUE`), CATEGORY_ITEM, TRANSACTION_REVIEW*, hệ thống/cấu hình... — chưa được đánh giá scope.)*

---

## Entities

> Single source of truth cho metadata entity. `aggregate_atomic.py` parse section này để sinh `atomic_entities.yaml`.
> Format bắt buộc: heading `### N.` + dòng `**Description:**` trong 500 ký tự đầu tiên sau heading.

### 1. Compliance Report Structure
**Tier:** 1 | **Source:** `COMPLIANCE_REPORT_STRUCTURE` | **BCV Concept:** [Documentation] Form Document | **BCO:** Documentation | **Table Type:** Relative
**Domain Prefix:** Compliance Report
**Description:** Cấu trúc cột (chỉ tiêu) của biểu mẫu báo cáo tuân thủ — 1 dòng = 1 cột của 1 biểu mẫu, kèm mã và tên biểu mẫu, mã phụ lục, trạng thái, phiên bản và thứ tự, mã, nhãn cột. Nguồn ODS, không có BRD.

### 2. Compliance Report Value
**Tier:** 2 | **Source:** `COMPLIANCE_REPORT_VALUE` | **BCV Concept:** [Documentation] Regulatory Information | **BCO:** Documentation | **Table Type:** Classification
**Domain Prefix:** Compliance Report
**Description:** Giá trị đã nộp của từng cột (ô) trong biểu mẫu báo cáo tuân thủ — 1 dòng = 1 cột của 1 dòng dữ liệu trong 1 lần nộp, kèm kỳ báo cáo, loại người nộp, thời điểm và tên file tải lên. Nguồn ODS, không có BRD.
