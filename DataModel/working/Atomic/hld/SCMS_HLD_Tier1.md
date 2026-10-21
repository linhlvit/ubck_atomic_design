# SCMS HLD — Tier 1

**Source system:** SCMS (Quản lý Giám sát Công ty Chứng khoán)
**Tier 1:** Các entity độc lập, không FK đến bảng nghiệp vụ khác — chỉ FK đến bảng danh mục (CAT_*). Bao gồm thực thể trung tâm SC_FIRM_INFO, ngân hàng đối tác (BANK), các danh mục Classification (trạng thái, dịch vụ, loại sự kiện, chức vụ) và biểu mẫu báo cáo (FORM_REPORT, FORM_INDICATOR_INPUT).

> **Cập nhật (2026-07-10):** CAT_PROVINCE/CAT_DISTRICT/CAT_WARD đã loại khỏi scope Atomic
> — không extend vào Geographic Area như dự kiến trước đây. Dữ liệu địa giới hành chính
> chuẩn hóa tại nguồn **ECAT** (xem `ECAT_HLD_Tier1.md`). SCMS chỉ tham chiếu Geographic
> Area qua lookup giá trị. Xem mục 7f của `SCMS_HLD_Overview.md`.

---

## 6a. Bảng tổng quan BCV Concept

| BCV Core Object | BCV Concept | Category | Source Table | Mô tả bảng nguồn | Atomic Entity | table_type | BCV Term |
|---|---|---|---|---|---|---|---|
| Involved Party | [Involved Party] Broker Dealer | Involved Party | SC_FIRM_INFO | Thông tin công ty chứng khoán: tên, địa chỉ, vốn điều lệ, loại hình, giấy phép thành lập | Securities Company | Fundamental | (1) BCV term `Broker Dealer` (ID 11227, category Involved Party) — mô tả tổ chức trung gian hoạt động mua bán chứng khoán cho khách hàng và cho chính mình. (2) SC_FIRM_INFO lưu thông tin pháp lý toàn diện về CTCK: giấy phép UBCKNN, vốn điều lệ, loại hình doanh nghiệp, trạng thái hoạt động — đây là thực thể Involved Party trung tâm của phân hệ. (3) Chọn `Broker Dealer` — khớp hoàn toàn với vai trò và cấu trúc trường CTCK tại Việt Nam. |
| Involved Party | [Involved Party] Depositary Bank | Involved Party | BANK | Ngân hàng được CTCK dùng làm đối tác thanh toán/lưu ký | Securities Company Bank | Fundamental | (1) BCV có term `Depositary Bank` và `Settlement Bank` — đều thuộc Involved Party, mô tả ngân hàng giữ tài sản hoặc xử lý thanh toán. (2) BANK trong SCMS lưu thông tin ngân hàng đối tác của CTCK — không phải ngân hàng của UBCKNN. (3) Chọn `Depositary Bank` — ngân hàng lưu ký/thanh toán cho CTCK; đặt tên `Securities Company Settlement Bank` phản ánh vai trò thanh toán chính trong SCMS. |
| Common | [Common] Firm Status | — | CAT_SC_FIRM_STATUS | Danh mục trạng thái pháp lý CTCK/Chi nhánh/VPĐD/PGD/Ngân hàng | Classification Securities Company Firm Status | Classification | (1) Term gần nhất trong BCV: `Organization Life Cycle Status` (id 10930, category Involved Party) hoặc `Organization Registration Status` (id 11478) — mô tả vòng đời/trạng thái đăng ký của 1 Organization. (2) Cấu trúc bảng: SC_FIRM_STATUS_CODE/NAME, REPORT_SUBMISSION_ENABLED, DISCLOSURE_ENABLED (cờ nghiệp vụ theo trạng thái), APPLICABLE_ENTITY (CTCK/CN/VPĐD/NH/Cả hai) — danh mục dùng chung cho nhiều loại đối tượng, không riêng 1 Organization. (3) Theo chỉ đạo Data Modeler: gán BCV Core Object = Common (không dùng Involved Party dù match khá tốt). Table Type = Classification (Upsert) theo chỉ đạo. Tên entity dạng bare `Classification [Term]` (không chèn tên nguồn) theo CLAUDE.md #7 (rev. 2026-07-14). |
| Common | [Common] Service | — | CAT_SERVICE_LEGAL_CAPITAL | Danh mục dịch vụ và nghiệp vụ kinh doanh chứng khoán của CTCK/CN nước ngoài, kèm vốn pháp định tối thiểu theo tổ hợp loại hình + nghiệp vụ | Classification Securities Company Firm Service | Classification | (1) Term BCV: `Service` (id 11846, category Product) — giữ nguyên quyết định T1-05 gán Common thay vì Product. (2) Cấu trúc bảng: SERVICE_ID (PK riêng của chính bảng này, KHÔNG FK đến CAT_SERVICE), SERVICE_NAME, CATALOG_TYPE (CTCK/CN_NUOC_NGOAI), CATALOG_CODE (mã chi tiết hơn trong nhóm Catalog Type), APPLICATION_TYPE (KINH_DOANH/LUU_KY/TU_VAN/BACH_LANH), LEGAL_CAPITAL, DESCRIPTION, RECORD_STATUS. (3) **Thay thế CAT_SERVICE và CAT_BUSINESS_LINE (cả 2 deprecated — xem T1-11)** — nguồn đã gộp danh mục dịch vụ (Service) và danh mục nghiệp vụ kinh doanh (Business Line, nay là Application Type Code) vào 1 bảng duy nhất kèm vốn pháp định. Đặt tên entity `Classification Securities Company Firm Service` theo yêu cầu tường minh Data Modeler (physical_name `cl_securities_company_firm_service` — theo đúng viết tắt curated chuẩn `Classification` → `cl`, nhất quán với các entity Classification khác; xem T1-11). |
| Common | [Common] Event Type | — | CAT_EVENT_TYPE | Danh mục loại sự kiện/sự vụ nghiệp vụ (thành lập, điều chỉnh vốn, đổi tên...) làm cơ sở xác định nghĩa vụ báo cáo/CBTT | Classification Securities Company Event Type | Relative | (1) Term BCV khớp: `Event Type` (id 9924, category Event) — "distinguishes between Events according to their inherent characteristics". (2) Cấu trúc bảng: EVENT_TYPE_CODE/NAME, REQUIRES_LICENSE, REQUIRES_DISCLOSURE, OBLIGATION_TYPE, EVENT_CATEGORY, CYCLE, FREQUENCY — vượt cấu trúc Code+Name thuần, nhiều cờ nghiệp vụ xác định nghĩa vụ báo cáo. (3) Theo chỉ đạo Data Modeler: gán Common (không dùng Event dù match mạnh). Table Type = Relative (không phải Classification/Fundamental) theo chỉ đạo — lưu ý: bảng không có FK nghiệp vụ rõ ràng đến 1 Fundamental entity khác trong scope hiện tại (xem 6f T1-05). **[ĐỔI TÊN 2026-09-16]** `Classification Securities Company Event Type` → `Classification Securities Company Event Type` — đối xứng với `Classification FMS Event Type` đã có sẵn (2 source có "Event Type" khác cấu trúc, không dùng chung entity). Ngoại lệ so với CLAUDE.md #7 (prefix Classification chuẩn là trần, không chèn tên nguồn) — chấp nhận ngoại lệ để nhất quán với tiền lệ FMS đã tồn tại, xem 7e Overview. BCV Concept/Core Object không đổi. |
| Documentation | [Documentation] Form Document | Documentation | FORM_INDICATOR_INPUT | Định nghĩa 1 chỉ tiêu/trường dữ liệu có thể gắn vào ô (cell) của biểu mẫu báo cáo — mã, tên, kiểu dữ liệu, nguồn giá trị tham chiếu | Securities Company Report Indicator | Relative | (1) Tái dùng term `Form Document` (id 9348, category Documentation) — đã dùng cho FORM_REPORT và cả family Sheet/Row/Column/Cell; FORM_INDICATOR_INPUT là thành phần định nghĩa 1 trường dữ liệu cần điền trong biểu mẫu, cùng concept Documentation với entity cha. (2) Cấu trúc bảng: CODE, ITEM_NAME, DESCRIPTION, DATA_TYPE (TEXT/NUMBER/DATE/BOOLEAN/SELECT), REFERENCE_CATALOG_ID, REFERENCE_CATALOG_TYPE (PROVINCE/NATIONALITY/SC_FIRM_STATUS/CUSTOM), CATEGORY, SOURCE_ENTITY_CODE, FIELD_METADATA_ID, SELECTION_LIST_SOURCE — định nghĩa chỉ tiêu/trường dữ liệu (metadata), không lưu giá trị cụ thể theo từng CTCK/kỳ báo cáo. (3) Theo chỉ đạo Data Modeler: BCV Core Object = Documentation (không dùng Business Activity dù có tiền lệ Risk/Alert Indicator trong SCMS). Table Type = Relative — **ngoại lệ tường minh** cùng pattern CAT_EVENT_TYPE/FORM_REPORT (T1-07/T1-12): bảng không FK nghiệp vụ rõ ràng đến 1 Fundamental khác còn trong scope (REFERENCE_CATALOG_ID→FORM_INDICATOR_REFERENCE_VALUE và FIELD_METADATA_ID→FORM_INDICATOR_FIELD_META đều trỏ bảng ngoài scope, không model làm FK Atomic — xem 6f). Đặt tên `Securities Company Report Indicator` theo chỉ đạo Data Modeler. |
| Documentation | [Documentation] Form Document | Documentation | FORM_REPORT | Biểu mẫu báo cáo (định kỳ/bất thường/theo yêu cầu/CBTT) mà CTCK/CN/VPĐD phải nộp cho UBCKNN, gồm căn cứ pháp lý, phiên bản, phân cấp biểu mẫu cha-con | Securities Company Report | Relative | (1) BCV term `Form Document` (id 9348, category Documentation) — "Identifies a Documentation Item presented in a standard template layout which requires additional information to be supplied; e.g. a loan application form, ... a questionnaire." Tiền lệ IDS: toàn bộ family template báo cáo (FORMS/RROW/RCOL/REP_FORMS) dùng đúng term này — thay thế term tự đặt `[Condition] Regulatory Reporting Requirement` trước đây (không có thật trong BCV, vi phạm rule #6). (2) Cấu trúc bảng: REPORT_CODE/NAME, LEGAL_BASIS, REPORT_TYPE (ĐỊNH_KỲ/BẤT_THƯỜNG/THEO_YÊU_CẦU/CBTT), REPORT_STYLE (input/output), VERSION/VERSION_DATE, PARENT_ID tự tham chiếu phân cấp, EFORM_ENABLED, STRUCTURE_FORMAT — đúng bản chất 1 biểu mẫu chuẩn hóa cần điền thông tin, khớp Form Document hơn khái niệm "yêu cầu/quy định" (Condition). (3) Sửa BCV Concept theo chỉ đạo Data Modeler (đối chiếu tiền lệ IDS, 2026-09-15). Đổi tên entity `Securities Company Form Report` → `Securities Company Report` theo chỉ đạo Data Modeler. Table Type giữ Relative (ngoại lệ tự tham chiếu qua PARENT_ID, không FK đến Fundamental khác — xem T1-07/T1-12), áp dụng chung Relative cho cả 2 entity con mới `Securities Company Report Input Submission` (Tier 2) và `Securities Company Report Input Value` (Tier 3) theo chỉ đạo Data Modeler. Đảo ngược quyết định loại-scope trước đây (xem 7f/7e Overview) — riêng `REPORT_CELL_VALUE` không nằm trong lượt thiết kế này, giữ nguyên ngoài scope. |
| Common | [Common] Position | — | CAT_POSITION | Danh mục chức vụ nhân sự CTCK (nhóm chức vụ, mã, tên, các cờ người đại diện/thành viên Ban lãnh đạo/giám đốc chi nhánh) | Classification Securities Company Position | Classification | (1) Term BCV gần nhất `Employment Position Type` (id 11300, Involved Party) — không dùng để giữ nhất quán pattern Classification-naming; gán Common theo chỉ đạo Data Modeler. (2) Bảng: POSITION_GROUP, POSITION_CODE, POSITION_NAME, NOTE, REPRESENTATIVE, BOARD_MEMBER, BRANCH_DIRECTOR, ECATALOG_ID — danh mục Code+Name có cờ phân loại. (3) Nâng cấp từ Classification Value (scheme SCMS_POSITION_TYPE, deprecated) lên entity thật theo `lld_SCMS_CAT_POSITION.yaml` (2026-10-08). |

---

## 6b. Diagram Source (Mermaid)

```mermaid
erDiagram
    SC_FIRM_INFO {
        int ID PK
        nvarchar CODE
        nvarchar NAME_VI
        nvarchar BUSINESS_LICENSE_NUMBER
        int COMPANY_TYPE_ID FK
        int PROVINCE_ID FK
        int DISTRICT_ID FK
        int WARD_ID FK
        int RECORD_STATUS
    }
    BANK {
        int ID PK
        nvarchar BANK_NAME
        nvarchar BANK_CODE
    }
    CAT_PROVINCE {
        int ID PK
        nvarchar PROVINCE_NAME
    }
    CAT_DISTRICT {
        int ID PK
        int PROVINCE_ID FK
        nvarchar DISTRICT_NAME
    }
    CAT_WARD {
        int ID PK
        int PROVINCE_ID FK
        int DISTRICT_ID FK
        nvarchar WARD_NAME
    }
    CAT_SC_FIRM_STATUS {
        int ID PK
        nvarchar SC_FIRM_STATUS_CODE
        nvarchar SC_FIRM_STATUS_NAME
        nvarchar APPLICABLE_ENTITY
        number REPORT_SUBMISSION_ENABLED
        number DISCLOSURE_ENABLED
    }
    CAT_SERVICE_LEGAL_CAPITAL {
        int SERVICE_ID PK
        nvarchar SERVICE_NAME
        varchar CATALOG_TYPE
        nvarchar CATALOG_CODE
        number APPLICATION_TYPE
        number LEGAL_CAPITAL
        nvarchar DESCRIPTION
        number RECORD_STATUS
    }
    CAT_EVENT_TYPE {
        int ID PK
        nvarchar EVENT_TYPE_CODE
        nvarchar EVENT_TYPE_NAME
        number REQUIRES_LICENSE
        number OBLIGATION_TYPE
    }
    FORM_REPORT {
        int ID PK
        nvarchar REPORT_CODE
        nvarchar REPORT_NAME
        nvarchar LEGAL_BASIS
        nvarchar REPORT_TYPE
        int PARENT_ID FK
        number RECORD_STATUS
    }
    FORM_INDICATOR_INPUT {
        int ID PK
        nvarchar CODE
        nvarchar ITEM_NAME
        nvarchar DATA_TYPE
        nvarchar REFERENCE_CATALOG_TYPE
        int REFERENCE_CATALOG_ID
        int FIELD_METADATA_ID
    }
    CAT_POSITION {
        int ID PK
        nvarchar POSITION_CODE
    }

    FORM_REPORT ||--o{ FORM_REPORT : "PARENT_ID (self-ref)"
    SC_FIRM_INFO ||--o{ CAT_PROVINCE : "PROVINCE_ID"
    SC_FIRM_INFO ||--o{ CAT_DISTRICT : "DISTRICT_ID"
    SC_FIRM_INFO ||--o{ CAT_WARD : "WARD_ID"
    CAT_PROVINCE ||--o{ CAT_DISTRICT : "PROVINCE_ID"
    CAT_PROVINCE ||--o{ CAT_WARD : "PROVINCE_ID"
    CAT_DISTRICT ||--o{ CAT_WARD : "DISTRICT_ID"
    SC_FIRM_INFO }o--o{ CAT_SERVICE_LEGAL_CAPITAL : "LNK_SC_FIRM_BUSINESS_LINE (M:N, xem 6f T1-11)"
```

---

## 6c. Diagram Atomic (Mermaid)

```mermaid
erDiagram
    Securities_Company {
        bigint ds_securities_company_id PK
        string sc_firm_code
        string sc_firm_name_vi
        string business_license_number
        date business_license_date
        string ds_sc_firm_status_code
        string ds_company_type_code
        bigint geographic_area_id FK
        string geographic_area_code
        bigint ds_source_id
    }
    Securities_Company_Bank {
        bigint ds_bank_id PK
        string bank_code
        string bank_name
    }
    Geographic_Area {
        bigint ds_geographic_area_id PK
        string geographic_area_code
    }
    Classification_Securities_Company_Firm_Status {
        bigint ds_classification_firm_status_id PK
        string classification_firm_status_code
        string classification_firm_status_nm
    }
    Classification_Securities_Company_Firm_Service {
        bigint cl_sc_firm_service_id PK
        string cl_sc_firm_service_code
        string cl_sc_firm_service_nm
        string catalog_type_code
        string catalog_code
        string application_type_code
        number legal_capital_amt
    }
    Classification_Securities_Company_Event_Type {
        bigint ds_classification_securities_company_event_type_id PK
        string classification_securities_company_event_type_code
        string classification_securities_company_event_type_nm
    }
    Securities_Company_Report {
        bigint ds_securities_company_report_id PK
        string securities_company_report_code
        string report_name
        string legal_basis
        bigint parent_securities_company_report_id FK
    }
    Securities_Company_Report_Indicator {
        bigint ds_securities_company_report_indicator_id PK
        string securities_company_report_indicator_code
        string item_name
        string ds_data_type_code
        string ds_reference_catalog_type_code
    }
    Classification_Securities_Company_Position {
        bigint cl_sc_position_id PK
        string cl_sc_position_code
    }

    Securities_Company ||--o{ Geographic_Area : "geographic_area_id"
    Securities_Company_Report ||--o{ Securities_Company_Report : "parent_securities_company_report_id"
```

---

## 6d. Mục Danh mục & Tham chiếu (Reference Data)

| Source Field / Bảng | Mô tả | Scheme Code | source_type | Ghi chú |
|---|---|---|---|---|
| CAT_COMPANY_TYPE | Loại hình doanh nghiệp CTCK (Công ty TNHH, Công ty Cổ phần...) | `SCMS_COMPANY_TYPE` | source_table | FK từ SC_FIRM_INFO.COMPANY_TYPE_ID |
| SC_FIRM_INFO.RECORD_STATUS → CAT_SC_FIRM_STATUS | Trạng thái pháp lý CTCK (Đang hoạt động, Tạm ngừng, Đình chỉ, Đóng cửa) | ~~`SCMS_SC_FIRM_STATUS`~~ (deprecated) | source_table | **Đã nâng cấp lên entity thật `Classification Securities Company Firm Status` (xem 6a).** LLD SC_FIRM_INFO cần đổi sang cặp FK Firm Status Id + Firm Status Code. |
| CAT_SERVICE_LEGAL_CAPITAL | Danh mục dịch vụ + nghiệp vụ kinh doanh chứng khoán kèm vốn pháp định | (không còn Classification Value — entity thật) | source_table | **Thay thế CAT_SERVICE và CAT_BUSINESS_LINE (deprecated, xem 6f T1-11).** Nâng cấp thành entity thật `Classification Securities Company Firm Service` (xem 6a). Các entity tiêu thụ (Securities Company X Classification Securities Company Firm Service Relationship, Organization Unit X ..., Foreign Organization Unit X ...) dùng cặp FK Id+Code theo LLD. |
| CAT_POSITION | Danh mục chức vụ nhân sự | ~~`SCMS_POSITION_TYPE`~~ (deprecated) | source_table | **Đã nâng cấp lên entity thật `Classification Securities Company Position` (xem 6a).** FK từ SC_FIRM_SENIOR_PERSONNEL. |
| CAT_RELATIONSHIP | Danh mục mối quan hệ | `SCMS_RELATIONSHIP_TYPE` | source_table | FK từ SC_FIRM_INSIDER_RELATION |
| CAT_SHAREHOLDER_TRANSACTION_TYPE | Danh mục loại giao dịch cổ đông | `SCMS_SHAREHOLDER_TXN_TYPE` | source_table | Dùng cho SC_FIRM_SHAREHOLDER_OWNERSHIP_CHANGE |
| CAT_EVENT_TYPE | Danh mục loại sự kiện nghiệp vụ (loại văn bản/thay đổi) | ~~`SCMS_EVENT_TYPE`~~ (deprecated) | source_table | **Đã nâng cấp lên entity thật `Classification Securities Company Event Type` (đổi tên 2026-09-16, xem 6a).** Securities Company Profile Change, Securities Company Bank Periodic và entity `Securities Company Report X Classification Securities Company Event Type Relationship` (Tier 2) cần dùng cặp FK khi thiết kế LLD. |
| FORM_INDICATOR_INPUT.REFERENCE_CATALOG_TYPE | Loại danh mục tham chiếu cho chỉ tiêu SELECT (PROVINCE/NATIONALITY/SC_FIRM_STATUS/CUSTOM) | `SCMS_INDICATOR_REFERENCE_CATALOG_TYPE` | source_table | REFERENCE_CATALOG_ID không model làm FK Atomic — FORM_INDICATOR_REFERENCE_VALUE giữ ngoài scope (xem 7f Overview). Đăng ký scheme để LLD dùng khi làm Classification Value trên attribute. |
| FORM_INDICATOR_INPUT.DATA_TYPE | Kiểu dữ liệu chỉ tiêu (TEXT/NUMBER/DATE/BOOLEAN/SELECT) | `SCMS_FORM_DATA_TYPE` | source_table | Scheme dùng chung cho mọi cột DATA_TYPE trong family FORM_* (FORM_SHEET_COLUMN, FORM_SHEET_CELL — xem Tier 3) vì cùng value set. |
| CAT_SC_FIRM_STATUS | Trạng thái pháp lý cho Chi nhánh, VPDD, PGD | ~~`SCMS_SC_FIRM_STATUS`~~ (deprecated) | source_table | Dùng chung entity `Classification Securities Company Firm Status` với SC_FIRM_INFO.RECORD_STATUS — xem dòng trên. |
| CAT_PROFILE_STATUS | Trạng thái hồ sơ trong luồng phê duyệt | `SCMS_PROFILE_STATUS` | source_table | FK từ SC_FIRM_PROFILE_HISTORY |

---

## 6e. Bảng chờ thiết kế

*(Để trống — toàn bộ Tier 1 đã có cột đầy đủ)*

---

## 6f. Điểm cần xác nhận

| # | Câu hỏi | Kết quả |
|---|---|---|
| T1-01 | SC_FIRM_INFO có FK self-reference (SC_FIRM_INFO_ID → SC_FIRM_INFO.ID) — có phải quan hệ công ty mẹ-công ty con không? | Xác nhận: đây là tự tham chiếu cho trường hợp CTCK là chi nhánh của CTCK khác. Ghi nhận là FK self-ref trên entity, không tạo entity riêng. |
| T1-04 | CAT_PROVINCE/DISTRICT/WARD trong SCMS có trùng dữ liệu với COUNTRIES/PROVINCES/DISTRICTS của NHNCK không? | **Đã chốt (2026-07-10) — không còn liên quan đến NHNCK.** Geographic Area chỉ còn 1 nguồn duy nhất là ECAT. CAT_PROVINCE/CAT_DISTRICT/CAT_WARD loại khỏi scope Atomic (xem 7f Overview). SC_FIRM_*'s Province/District/Ward FK chuyển sang resolve bằng lookup giá trị đối chiếu Geographic Area (Province/Ward) hoặc Geographic Area Old (District — cấp bị bỏ sau sáp nhập 2025) nguồn ECAT, thay vì hash_id('SCMS.CAT_*', ...). |
| T1-05 | `CAT_SC_FIRM_STATUS`, `CAT_SERVICE`, `CAT_NATIONALITY`, `CAT_EVENT_TYPE` — nâng cấp từ Classification Value (scheme) lên Atomic entity thật, đặt tên `Classification [Term]`. Tra BCV cho thấy term khớp mạnh hơn ở category khác (Organization Life Cycle Status/Involved Party cho Firm Status; Service Type/Product cho Service; Event Type/Event cho Event Type) nhưng Data Modeler chỉ đạo giữ Common cho cả 4 bảng để nhất quán naming convention. Riêng Table Type: 3 bảng đầu = Classification (Upsert), `CAT_EVENT_TYPE` = Relative (khác 3 bảng còn lại) — theo chỉ đạo tường minh, không theo mặc định Bước 1b. | **Quyết định Data Modeler (chốt).** BCV Core Object = Common cho cả 4; Table Type: Classification (3 bảng đầu) / Relative (CAT_EVENT_TYPE). Ghi nhận độ lệch BCV để minh bạch, không chặn thiết kế. Tên entity dạng bare `Classification [Term]` — xem T1-10 (2026-07-14). **[2026-10-21]** `CAT_NATIONALITY` (Classification Nationality) đã gỡ khỏi HLD — không có LLD, xem 7f Overview. |
| T1-06 | `FORM_REPORT` — trước đây bị loại khỏi scope Atomic (§7f Overview, lý do "form metadata không cần trên Atomic"). Data Modeler yêu cầu đảo ngược, thiết kế thành entity `Securities Company Form Report`, BCV Core Object = Condition, Table Type = Relative. Cả nhóm cascade (FORM_SHEET*, FORM_REPORT_PERIODIC, LNK_EVENT_TYPE_FORM...) vẫn giữ ngoài scope — lý do cũ "Cascade từ FORM_REPORT đã loại" không còn đúng vì FORM_REPORT không còn "đã loại". | **Quyết định Data Modeler (chốt) — chỉ đảo ngược riêng FORM_REPORT.** Nhóm cascade cần lý do loại-scope độc lập, riêng biệt — chưa đánh giá lại trong lượt thiết kế này, để nguyên trong `atomic_out_of_scope.yaml`/§7f với ghi chú cần review lại lý do. |
| T1-07 | `Table Type = Relative` cho `CAT_EVENT_TYPE` và `Securities Company Form Report` không khớp định nghĩa chuẩn trong skill ("phụ thuộc Fundamental qua FK") — cả 2 bảng không FK nghiệp vụ rõ ràng đến 1 Fundamental entity khác (FORM_REPORT chỉ tự tham chiếu PARENT_ID; CAT_EVENT_TYPE không FK đi đâu). | **Xác nhận từ Data Modeler: giữ nguyên Relative** — quyết định tường minh, ghi nhận ngoại lệ so với định nghĩa chuẩn để minh bạch cho executor sau. |
| T1-10 | Đảo ngược quyết định tại T1-09 theo yêu cầu tường minh của Data Modeler (2026-07-14): **Đặt tên** — bỏ tiền tố nguồn "SCMS", entity đổi thành `Classification Business Transaction` (bare `Classification [Term]`, đồng thời đổi BCV Term hiển thị từ "Business Line" sang "Business Transaction" — BCV Concept giữ nguyên `[Common] Business Line`). Áp dụng cho toàn dự án — 9 entity Classification khác (ECAT×1, NHNCK×3, SCMS×4 còn lại) cũng đổi về bare name, xem CLAUDE.md #7 rev. | **Superseded một phần bởi T1-11 (2026-09-12)** — entity `Classification Business Transaction` (CAT_BUSINESS_LINE) bị deprecate, gộp vào `Classification Securities Company Firm Service`. |
| T1-12 | `FORM_REPORT` (T1-06) — Data Modeler yêu cầu (2026-09-15) sửa BCV Concept theo tiền lệ IDS, đổi tên entity, và mở rộng thiết kế 2 entity con `REPORT_INPUT_SUBMISSION`/`REPORT_INPUT_CELL_VALUE` (đều Table Type Relative theo chỉ đạo). | **Quyết định Data Modeler (chốt, 2026-09-15).** BCV Core Object: Condition → Documentation. BCV Concept: `[Condition] Regulatory Reporting Requirement` → `[Documentation] Form Document` (id 9348). Atomic Entity: `Securities Company Form Report` → `Securities Company Report`. Table Type giữ Relative (ngoại lệ tự tham chiếu, xem T1-07). 2 entity con mới: `Securities Company Report Input Submission` (Tier 2, xem SCMS_HLD_Tier2.md 6a) và `Securities Company Report Input Value` (Tier 3, xem SCMS_HLD_Tier3.md 6a) — cả 2 cũng Table Type Relative theo cùng chỉ đạo. **Lưu ý:** đổi tên entity kéo theo cần cập nhật `manifest.yaml` (`atomic_entity: Securities Company Form Report` → `Securities Company Report`) khi thiết kế LLD. `REPORT_CELL_VALUE` giữ nguyên ngoài scope, không đưa vào lượt thiết kế này (khác 2 bảng REPORT_INPUT_*). |
| T1-13 | `FORM_REPORT` — nguồn bổ sung 8 cột mới (2026-09-15): `SORT_ORDER`, `STRUCTURE_FORMAT`, `PRIMARY_SOURCE_TYPE`, `IDENTIFIER_FIELD`, `DISPLAY_LOCATION`, `PRIMARY_SOURCE_API_ID`, `SHOW_GRAND_TOTAL_ROW` — mô tả gốc BRD đều trống, cần Data Modeler xác nhận ý nghĩa nghiệp vụ và domain. | **Đã map cả 8 cột (LLD `lld_SCMS_FORM_REPORT.yaml`, chưa approved).** `Sort Order Number`/`Show Grand Total Row Indicator` → Small Counter (nhất quán các cờ NUMBER(1,0) khác trong bảng). `Structure Format Code`/`Primary Source Type Code` → tạm Text (không có tập giá trị xác nhận, cần profile — có thể nâng Classification Value sau). `Identifier Field`/`Display Location` → Text tự do. `PRIMARY_SOURCE_API_ID` → **map 1:1 theo chỉ đạo tường minh Data Modeler (2026-09-15)**, `Primary Source Api Id` dạng Text denormalized, KHÔNG thiết kế cặp Id+Code/FK dù bảng đích khả năng thuộc nhóm Operational/System (`API_MAPPINGS`/`SYS_FUNCTION_DETAIL`, cùng nhóm `SYS_FUNCTION_ID` — điểm khác biệt: `SYS_FUNCTION_ID` vẫn giữ pending hoàn toàn không map, xem T1-06). |
| T1-14 | **[MỚI 2026-09-16]** Đánh giá lại nhóm cascade `FORM_SHEET*`/`FORM_INDICATOR_*`/`LNK_EVENT_TYPE_FORM` bị loại khỏi scope với lý do lỗi thời "Cascade từ FORM_REPORT đã loại" (xem T1-06/T1-12) — theo yêu cầu Data Modeler. | **Quyết định Data Modeler (chốt, 2026-09-16).** Đưa vào scope: `FORM_SHEET` (Tier 2), `LNK_EVENT_TYPE_FORM` (Tier 2, đổi tên `Securities Company Report X Classification Securities Company Event Type Relationship` theo tham khảo pattern NHNCK `APPLICATION_DECISIONS`), `FORM_SHEET_ROW`/`FORM_SHEET_COLUMN`/`FORM_ROW_HEADER` (Tier 3), `FORM_SHEET_CELL` (Tier 4 — file mới), `FORM_INDICATOR_INPUT` (Tier 1, entity `Securities Company Report Indicator`, xem 6a). Giữ ngoài scope (lý do cập nhật, không còn "cascade"): `FORM_INDICATOR_FIELD_META`/`FORM_INDICATOR_DATA_SOURCE` (Operational/System — metadata kỹ thuật field-binding cho engine form động), `FORM_INDICATOR_REFERENCE_VALUE` (Reference Data — danh sách giá trị tham chiếu dùng chung nhiều loại). Đồng thời đổi tên `Classification Securities Company Event Type` → `Classification Securities Company Event Type` (đối xứng tiền lệ `Classification FMS Event Type`, ngoại lệ so với CLAUDE.md #7). Xem chi tiết Tier2/Tier3/Tier4 mới + 7e/7f Overview. |
| T1-11 | Nguồn SCMS bổ sung bảng mới `CAT_SERVICE_LEGAL_CAPITAL` — theo xác nhận Data Modeler, bảng này **thay thế cả `CAT_SERVICE` và `CAT_BUSINESS_LINE`** ở phía nghiệp vụ (2 bảng cũ bị bỏ, không còn ghi nhận dữ liệu mới). `SERVICE_ID` trên bảng mới là PK/identity riêng của chính bảng — KHÔNG phải FK đến `CAT_SERVICE.ID` như suy đoán ban đầu. | **Quyết định Data Modeler (chốt, 2026-09-12).** Deprecate 2 entity `Classification Service` (T1-05) và `Classification Business Transaction` (T1-10). Gộp thành 1 entity mới `Classification Securities Company Firm Service` (Tier 1, BCO=Common, BCV Concept=`[Common] Service`, Table Type=Classification, physical_name `cl_securities_company_firm_service` — ban đầu Data Modeler chọn tên đầy đủ `classification_securities_company_firm_service` làm ngoại lệ, sau đó đổi lại về viết tắt curated chuẩn `cl_` (2026-09-12) để tránh xung đột khi `transform_physical_names.py` chạy lại). BK/Id hash từ `SERVICE_ID` (không dùng `CATALOG_CODE`). `CATALOG_TYPE`/`CATALOG_CODE` giữ nguyên tên trường khi map Atomic (`Catalog Type`/`Catalog Code`), không thêm prefix entity. `APPLICATION_TYPE` → `Application Type Code` (Classification Value, thay thế vai trò Business Transaction cũ). `RECORD_STATUS` không thiết kế attribute (theo yêu cầu Data Modeler). `lld_SCMS_CAT_SERVICE.yaml`/`lld_SCMS_CAT_BUSINESS_LINE.yaml` hiện `design_status: approved` — cần Data Modeler đổi status trước khi xoá (xem Overview 7e). |
| T1-15 | **[MỚI 2026-10-06]** Đổi tên entity BANK: `Securities Company Depositary Bank` → `Securities Company Bank` (physical `sc_depositary_bank` → `sc_bank`; mọi cột `sc_depositary_bank_*` → `sc_bank_*`, kể cả cặp FK trên IP Postal/Electronic/Alt Identification và `SC_FIRM_ADHOC_REPORT`) theo chỉ đạo Data Modeler. BCV Concept giữ `[Involved Party] Depositary Bank`. | **Đã đổi (draft)** — cần duyệt lại để approved. Entity con mới `Securities Company Bank Periodic` (Tier2 T2-18) chứa trọn tên cha. |
| T1-16 | **[2026-10-21]** Đồng bộ HLD Tier 1 theo LLD (LLD là chuẩn). | Gỡ khỏi HLD (không có LLD, chuyển 7f Overview nhóm `Chưa có LLD`): `Audit Firm`, `Classification Nationality`, `Securities Company Risk Indicator`/`Risk Indicator Group`/`Risk Reporting Period`, `Securities Company Alert Indicator`/`Alert Financial Indicator`. Thêm `Classification Securities Company Position` (CAT_POSITION). Không còn junction table. |
