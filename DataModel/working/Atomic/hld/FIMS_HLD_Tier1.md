# FIMS HLD — Tier 1

**Source system:** FIMS (Hệ thống quản lý giám sát và công bố thông tin thành viên thị trường — Oracle)
**Tier 1:** Entity độc lập, không FK đến entity nghiệp vụ khác — chỉ FK đến Classification Value. Gồm 7 entity: Market Participant Organization (5 bảng nguồn gộp), Geographic Area (shared), Foreign Investor, Reporting Template, Reporting Period, Reporting Obligation Type, Warning Parameter.

---

## 6a. Bảng tổng quan BCV Concept

| BCV Core Object | BCV Concept | Category | Source Table | Mô tả bảng nguồn | Atomic Entity | table_type | BCV Term |
|---|---|---|---|---|---|---|---|
| Involved Party | [Involved Party] Organization | Organization | FUNDCOMPANY | Danh sách công ty quản lý quỹ — đối tượng thành viên thị trường gửi báo cáo lên UBCKNN | Market Participant Organization | Fundamental | (1) BCV term `[Involved Party] Organization` — tổ chức là Involved Party tham gia thị trường. (2) FUNDCOMPANY: Name, EName, ShortName, IdNo, RegNo, StatusId, Capital — đây là profile tổ chức pháp nhân đầy đủ. (3) Chọn `[Involved Party] Organization`. Gộp 5 bảng nguồn (FUNDCOMPANY, SECURITIESCOMPANY, BANKMONI, DEPOSITORYCENTER, STOCKEXCHANGE) thành 1 entity phân biệt bằng `FIMS_MARKET_PARTICIPANT_TYPE`. |
| Involved Party | [Involved Party] Organization | Organization | SECURITIESCOMPANY | Danh sách công ty chứng khoán — đối tượng thành viên thị trường | Market Participant Organization | Fundamental | Cùng entity với FUNDCOMPANY — gộp vào Market Participant Organization, `FIMS_MARKET_PARTICIPANT_TYPE = SECURITIES_COMPANY`. |
| Involved Party | [Involved Party] Organization | Organization | BANKMONI | Danh sách ngân hàng lưu ký giám sát — đối tượng thành viên thị trường | Market Participant Organization | Fundamental | Cùng entity với FUNDCOMPANY — gộp vào Market Participant Organization, `FIMS_MARKET_PARTICIPANT_TYPE = CUSTODIAN_BANK`. |
| Involved Party | [Involved Party] Organization | Organization | DEPOSITORYCENTER | Danh sách Trung tâm lưu ký chứng khoán (VSDC) — đối tượng thành viên thị trường | Market Participant Organization | Fundamental | Cùng entity với FUNDCOMPANY — gộp vào Market Participant Organization, `FIMS_MARKET_PARTICIPANT_TYPE = DEPOSITORY_CENTER`. |
| Involved Party | [Involved Party] Organization | Organization | STOCKEXCHANGE | Danh sách sở giao dịch chứng khoán — đối tượng thành viên thị trường | Market Participant Organization | Fundamental | Cùng entity với FUNDCOMPANY — gộp vào Market Participant Organization, `FIMS_MARKET_PARTICIPANT_TYPE = STOCK_EXCHANGE`. |
| Location | [Location] Geographic Area | Geographic Area | NATIONAL | Danh sách quốc gia/quốc tịch — dùng làm FK từ nhiều entity FIMS | Geographic Area | Fundamental | (1) BCV term `[Location] Geographic Area` — danh mục địa lý. (2) NATIONAL: Id, Name, Code — danh mục quốc gia. (3) Shared entity đã approved từ NHNCK. FIMS.NATIONAL bổ sung source_table vào COUNTRY type của GEOGRAPHIC_AREA_TYPE scheme. Không tạo entity mới. |
| Location | [Location] Geographic Area | Geographic Area | LOCATION | Danh sách tỉnh/thành phố Việt Nam | Geographic Area | Fundamental | Shared entity. FIMS.LOCATION bổ sung source_table vào PROVINCE type của GEOGRAPHIC_AREA_TYPE scheme. Không tạo entity mới. |
| Involved Party | [Involved Party] Individual | Individual | INVESTOR | Danh sách nhà đầu tư nước ngoài (cá nhân và tổ chức) đăng ký hoạt động tại Việt Nam theo quy định UBCKNN | Foreign Investor | Fundamental | (1) BCV term `[Involved Party] Individual` — đây là cá nhân/tổ chức nước ngoài. (2) INVESTOR: ObjectType(1=Cá nhân, 2=Tổ chức), IdNo, NaId, Address, Tel, Email, StatusId — profile NĐT NN với thông tin nhận dạng và liên lạc. (3) ObjectType gộp cả cá nhân lẫn tổ chức → 1 entity dùng Classification Value phân biệt. Chọn `[Involved Party] Individual` vì primary use case là cá nhân; tổ chức NĐT NN là ngoại lệ (ít trường hơn). |
| Business Activity | [Business Activity] Business Activity | Business Activity | RPTTEMP | Danh sách biểu mẫu báo cáo định kỳ do UBCKNN ban hành — master template mà thành viên thị trường phải nộp | Reporting Template | Fundamental | (1) BCV term `[Business Activity] Business Activity` — biểu mẫu báo cáo định nghĩa một nghĩa vụ hoạt động. (2) RPTTEMP: mã biểu mẫu, tên, loại báo cáo, trạng thái, phiên bản — đây là chuẩn báo cáo pháp lý. (3) Không phải Entity "Arrangement" (không có tài khoản/hợp đồng) hay "Documentation" (không phải hồ sơ cụ thể) → BCV `[Business Activity] Business Activity`. |
| Business Activity | [Business Activity] Assessment Period | Period | RPTPERIOD | Danh sách kỳ báo cáo định kỳ gắn với biểu mẫu — xác định ngày bắt đầu, kết thúc, hạn nộp | Reporting Period | Fundamental | (1) BCV term `[Business Activity] Assessment Period` — kỳ đánh giá/báo cáo. (2) RPTPERIOD: mã kỳ, ngày bắt đầu, ngày kết thúc, hạn nộp, FK đến RPTTEMP. (3) Kỳ báo cáo pháp lý mang ngữ nghĩa "assessment period" rõ ràng → chọn `[Business Activity] Assessment Period`. |
| Business Activity | [Business Activity] Business Activity | Business Activity | RPT_EVENT_TYPE | Danh mục loại sự vụ/nghĩa vụ báo cáo mà thành viên thị trường phải thực hiện theo pháp luật | Reporting Obligation Type | Fundamental | (1) BCV term `[Business Activity] Business Activity` — loại sự vụ định nghĩa một nghĩa vụ hoạt động. (2) RPT_EVENT_TYPE: MA_SU_VU, TEN_SU_VU, PHAN_LOAI_SU_VU, LOAI_NGHIA_VU — phân loại nghĩa vụ báo cáo/CBTT/hồ sơ. (3) Đây là danh mục loại nghĩa vụ (master reference) chứ không phải instance → Fundamental (Classification có cấu trúc rộng hơn Code+Name). |
| Condition | [Condition] Scoring Criterion | Scoring Criterion | PARAWARN | Danh sách tham số cảnh báo giám sát — định nghĩa chỉ tiêu theo dõi thành viên thị trường kèm công thức tính | Warning Parameter | Fundamental | (1) BCV term `[Condition] Scoring Criterion` — tham số cảnh báo là tiêu chí chấm điểm/đánh giá. (2) PARAWARN: Name, LegalCode, FormulaInfo (NCLOB), SystemObject — tham số kỹ thuật với công thức. (3) Đây là "criterion" định nghĩa ngưỡng đánh giá, không phải Condition instance → `[Condition] Scoring Criterion`. Nền tảng cho Warning Condition (Tier 2). |

---

## 6b. Diagram Source (Mermaid)

```mermaid
erDiagram
    FUNDCOMPANY {
        NUMBER Id PK
        NVARCHAR2 Name
        NVARCHAR2 EName
        NVARCHAR2 ShortName
        NUMBER NaId FK
        NVARCHAR2 IdNo
        DATE IdDate
        NVARCHAR2 IdAdd
        NVARCHAR2 RegNo
        DATE RegDate
        NVARCHAR2 RegAdd
        NVARCHAR2 Address
        NVARCHAR2 Tel
        NVARCHAR2 Fax
        NVARCHAR2 Email
        NVARCHAR2 Website
        NUMBER Capital
        NUMBER StatusId FK
    }

    SECURITIESCOMPANY {
        NUMBER Id PK
        NVARCHAR2 Name
        NVARCHAR2 EName
        NVARCHAR2 ShortName
        NUMBER NaId FK
        NVARCHAR2 Address
        NUMBER StatusId FK
    }

    BANKMONI {
        NUMBER Id PK
        NVARCHAR2 Name
        NUMBER NaId FK
        NUMBER StatusId FK
    }

    DEPOSITORYCENTER {
        NUMBER Id PK
        NVARCHAR2 Name
        NUMBER NaId FK
        NUMBER StatusId FK
    }

    STOCKEXCHANGE {
        NUMBER Id PK
        NVARCHAR2 Name
        NUMBER NaId FK
        NUMBER StatusId FK
    }

    INVESTOR {
        NUMBER Id PK
        NUMBER ObjectType
        NVARCHAR2 InvesCode
        NUMBER NaId FK
        NUMBER SecId FK
        NUMBER BankId FK
        NVARCHAR2 IdNo
        NVARCHAR2 Address
        NVARCHAR2 Tel
        NVARCHAR2 Email
        NUMBER StatusId FK
    }

    NATIONAL {
        NUMBER Id PK
        NVARCHAR2 Name
        NVARCHAR2 Code
    }

    LOCATION {
        NUMBER Id PK
        NVARCHAR2 Name
        NVARCHAR2 Code
    }

    RPTTEMP {
        NUMBER Id PK
        NVARCHAR2 Code
        NVARCHAR2 Name
        NUMBER ReportTypeId FK
        NUMBER Status
    }

    RPTPERIOD {
        NUMBER Id PK
        NVARCHAR2 PeriodCode
        DATE StartDate
        DATE EndDate
        DATE DeadlineSend
        NUMBER RptTempId FK
    }

    RPT_EVENT_TYPE {
        NUMBER BC_SU_VU_ID PK
        NVARCHAR2 MA_SU_VU
        NVARCHAR2 TEN_SU_VU
        NUMBER PHAN_LOAI_SU_VU
        NUMBER LOAI_NGHIA_VU
    }

    PARAWARN {
        NUMBER Id PK
        NVARCHAR2 Name
        NVARCHAR2 LegalCode
        NCLOB FormulaInfo
        NUMBER SystemObject
    }

    STATUS {
        NUMBER Id PK
        NVARCHAR2 Name
    }

    FUNDCOMPANY ||--o{ NATIONAL : "NaId"
    SECURITIESCOMPANY ||--o{ NATIONAL : "NaId"
    BANKMONI ||--o{ NATIONAL : "NaId"
    DEPOSITORYCENTER ||--o{ NATIONAL : "NaId"
    STOCKEXCHANGE ||--o{ NATIONAL : "NaId"
    INVESTOR ||--o{ NATIONAL : "NaId"
    INVESTOR ||--o{ SECURITIESCOMPANY : "SecId"
    INVESTOR ||--o{ BANKMONI : "BankId"
    RPTPERIOD ||--o{ RPTTEMP : "RptTempId"
```

---

## 6c. Diagram Atomic (Mermaid)

```mermaid
erDiagram
    Market_Participant_Organization {
        bigint ds_market_participant_org_id PK
        string market_participant_org_code
        string market_participant_type_code
        string name
        string ename
        string short_name
        string geographic_area_code
        bigint geographic_area_id FK
        string activity_status_code
        string reg_no
        date reg_date
        decimal capital
        date ds_effective_from
        date ds_effective_to
        string ds_source_system
        timestamp ds_loaded_at
    }

    Geographic_Area {
        bigint ds_geographic_area_id PK
        string geographic_area_code
        string geographic_area_type_code
        string name
        string ds_source_system
    }

    IP_Postal_Address {
        bigint ds_ip_postal_address_id PK
        bigint ds_involved_party_id FK
        string address_type_code
        string address_text
    }

    IP_Electronic_Address {
        bigint ds_ip_electronic_address_id PK
        bigint ds_involved_party_id FK
        string electronic_address_type_code
        string electronic_address_value
    }

    IP_Alt_Identification {
        bigint ds_ip_alt_id_id PK
        bigint ds_involved_party_id FK
        string alt_id_type_code
        string alt_id_no
        date alt_id_date
        string alt_id_place
    }

    Foreign_Investor {
        bigint ds_foreign_investor_id PK
        string foreign_investor_code
        string investor_object_type_code
        bigint geographic_area_id FK
        string geographic_area_code
        string investor_type_code
        string activity_status_code
        timestamp ds_effective_from
        timestamp ds_effective_to
        string ds_source_system
        timestamp ds_loaded_at
    }

    Reporting_Template {
        bigint ds_reporting_template_id PK
        string reporting_template_code
        string name
        string report_type_code
        string activity_status_code
        string ds_source_system
        timestamp ds_loaded_at
    }

    Reporting_Period {
        bigint ds_reporting_period_id PK
        string reporting_period_code
        bigint ds_reporting_template_id FK
        string reporting_template_code
        date start_date
        date end_date
        date deadline_date
        string ds_source_system
        timestamp ds_loaded_at
    }

    Reporting_Obligation_Type {
        bigint ds_reporting_obligation_type_id PK
        string reporting_obligation_type_code
        string name
        string event_category_code
        string obligation_category_code
        string ds_source_system
        timestamp ds_loaded_at
    }

    Warning_Parameter {
        bigint ds_warning_parameter_id PK
        string warning_parameter_code
        string name
        string legal_code
        string formula_info
        string system_object_type_code
        string ds_source_system
        timestamp ds_loaded_at
    }

    Market_Participant_Organization ||--o{ Geographic_Area : "geographic_area_id"
    Market_Participant_Organization ||--o{ IP_Postal_Address : "ds_involved_party_id"
    Market_Participant_Organization ||--o{ IP_Electronic_Address : "ds_involved_party_id"
    Market_Participant_Organization ||--o{ IP_Alt_Identification : "ds_involved_party_id"
    Foreign_Investor ||--o{ Geographic_Area : "geographic_area_id"
    Foreign_Investor ||--o{ IP_Alt_Identification : "ds_involved_party_id"
    Reporting_Period ||--o{ Reporting_Template : "ds_reporting_template_id"
```

---

## 6d. Mục Danh mục & Tham chiếu (Reference Data)

| Source Field / Bảng | Mô tả | Scheme Code | source_type | Ghi chú |
|---|---|---|---|---|
| FUNDCOMPANY.StatusId → STATUS | Tình trạng hoạt động của tổ chức thành viên | `FIMS_ACTIVITY_STATUS` | source_table | Dùng chung cho cả 5 loại tổ chức thành viên + NĐT NN |
| INVESTOR.InvesTypeId → INVESTORTYPE | Loại nhà đầu tư nước ngoài | `FIMS_INVESTOR_TYPE` | source_table | |
| FUNDCOMPANY.CompanyTypeId → COMPANYTYPE | Loại hình doanh nghiệp | `FIMS_COMPANY_TYPE` | source_table | |
| INVESTOR.ObjectType | Loại đối tượng NĐT NN (cá nhân/tổ chức) | `FIMS_STOCKHOLDER_TYPE` | source_table | → FIMS.STOCKHOLDERTYPE |
| ETL-derived | Loại thành viên thị trường (QLQ/CTCK/NHLK/VSDC/Sở GD) | `FIMS_MARKET_PARTICIPANT_TYPE` | etl_derived | Phân biệt 5 bảng nguồn gộp chung |
| RPTTEMP.ReportTypeId → REPORTTYPE | Loại báo cáo thành viên | `FIMS_REPORT_TYPE` | source_table | |
| RPT_EVENT_TYPE.PHAN_LOAI_SU_VU | Phân loại sự vụ (định kỳ/bất thường/theo yêu cầu) | `FIMS_REPORTING_EVENT_CATEGORY` | etl_derived | |
| RPT_EVENT_TYPE.LOAI_NGHIA_VU | Loại nghĩa vụ (BC/CBTT/hồ sơ/khác) | `FIMS_REPORTING_OBLIGATION_CATEGORY` | etl_derived | |
| PARAWARN.SystemObject | Loại đối tượng áp dụng tham số cảnh báo | `FIMS_SYSTEM_OBJECT_TYPE` | etl_derived | 1=QLQ, 2=CTCK, 3=NHLK, 4=VSDC, 5=Sở GD, 7=CN QLQ NN |
| NATIONAL | Danh mục quốc gia/quốc tịch | `GEOGRAPHIC_AREA_TYPE` | etl_derived | Shared scheme — bổ sung FIMS.NATIONAL vào COUNTRY type |
| LOCATION | Danh mục tỉnh/thành phố VN | `GEOGRAPHIC_AREA_TYPE` | etl_derived | Shared scheme — bổ sung FIMS.LOCATION vào PROVINCE type |

---

## 6e. Bảng chờ thiết kế

*(Không có — tất cả bảng Tier 1 đã có thông tin cột đầy đủ)*

---

## 6f. Điểm cần xác nhận

| # | Câu hỏi | Kết quả |
|---|---|---|
| T1-01 | FUNDCOMPANY, SECURITIESCOMPANY, BANKMONI, DEPOSITORYCENTER, STOCKEXCHANGE có cấu trúc cột gần đồng nhất — xác nhận gộp 5 bảng thành 1 entity `Market Participant Organization` phân biệt bằng `FIMS_MARKET_PARTICIPANT_TYPE`? | Đề xuất: Gộp. Cấu trúc (Name/EName/ShortName/NaId/IdNo/RegNo/Address/Tel/Fax/Email/Website/Capital/StatusId) đồng nhất. ETL union 5 bảng, thêm cột `market_participant_type_code` ETL-derived. |
| T1-02 | INVESTOR.ObjectType = 1 (cá nhân) và 2 (tổ chức) — có cần tách thành 2 entity riêng (Foreign Investor Individual + Foreign Investor Organization) không? | Đề xuất: Giữ 1 entity, phân biệt bằng `investor_object_type_code`. Cấu trúc cột đồng nhất — không có cột riêng cho từng loại. |
| T1-03 | RPTTEMP và RPTPERIOD — xác nhận đây là entity nghiệp vụ (không phải config IT) cần thiết kế Atomic? | Cần xác nhận. Nếu RPTTEMP là template cố định do UBCKNN ban hành → in scope. Nếu là config UI của hệ thống → ngoài scope. |
| T1-04 | Geographic Area — FIMS.NATIONAL và FIMS.LOCATION: đã được bổ sung vào shared entity `Geographic Area` từ NHNCK. Xác nhận ETL không tạo duplicate với NATIONAL từ FMS. | Cần profile data: FIMS.NATIONAL.Code vs FMS.NATIONAL.Code — nếu dùng cùng chuẩn ISO 3166 thì deduplicate; nếu khác → ghi nhận riêng với `ds_source_system = FIMS`. |
