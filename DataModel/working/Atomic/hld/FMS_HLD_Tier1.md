# FMS HLD — Tier 1

**Source system:** FMS (Hệ thống quản lý giám sát công ty chứng khoán và quỹ đầu tư chứng khoán)
**Tier 1:** Independent Entities — các entity không có FK đến entity nghiệp vụ khác (chỉ FK đến danh mục hoặc self-ref). Bao gồm: Fund Management Company, Custodian Bank, Fund Distribution Agent, Member Rating Period, Rating Criterion, Reporting Period. Các bảng danh mục (Classification Value) cũng xử lý ở tầng này.

---

## 6a. Bảng tổng quan BCV Concept

| BCV Core Object | BCV Concept | Category | Source Table | Source Table Change Mode | Mô tả bảng nguồn | Atomic Entity | table_type | BCV Term |
|---|---|---|---|---|---|---|---|---|
| Involved Party | [Involved Party] Portfolio Fund Management Company | Organization | SECURITIES | Update | Danh sách công ty quản lý quỹ (QLQ) trong nước và nước ngoài tại VN | Fund Management Company | Fundamental | (1) Term candidate: `Portfolio Fund Management Company` — BCV mô tả tổ chức quản lý quỹ đầu tư được UBCK giám sát. (2) Cấu trúc trường: SECURITIES có mã công ty (CODE), tên VN/EN/viết tắt, địa chỉ, phone, fax, email, website, vốn điều lệ (CAPITAL), ngày đăng ký, trạng thái hoạt động (STATUS_ID), mã định danh doanh nghiệp (ID_NO) → entity tổ chức độc lập, lifecycle riêng, có địa chỉ + liên lạc → tách IP Postal Address + IP Electronic Address + IP Alt Identification. (3) Chọn `Portfolio Fund Management Company`. |
| Location | [Location] Geographic Area | Geographic Area | NATIONAL | Update | Danh sách quốc gia/quốc tịch | Geographic Area | Fundamental | (1) Term candidate: `Geographic Area` — BCV ngoại lệ: dù chỉ có Code+Name vẫn là Atomic entity Location, không phải Classification Value. (2) Cấu trúc trường: NATIONAL lưu mã quốc gia và tên quốc gia → phục vụ FK từ các entity nghiệp vụ (SECURITIES, INVES...). Đây là nguồn bổ sung thêm `source_table` vào entity Geographic Area đã có từ NHNCK (locked). (3) Shared entity `Geographic Area` — bổ sung source FMS.NATIONAL, không tạo entity mới. |
| Involved Party | [Involved Party] Organization | Organization | BANKMONI | Update | Danh sách ngân hàng lưu ký giám sát (LKGS) | Custodian Bank | Fundamental | (1) Term candidate: `Custodian Bank` — BCV mô tả ngân hàng lưu giữ tài sản quỹ và giám sát hoạt động quỹ. (2) Cấu trúc trường: BANKMONI có tên, địa chỉ, phone, email → entity tổ chức độc lập, FK từ FUNDS (BANK_ID) và FNDSBMN → lifecycle riêng, tách IP Postal Address + IP Electronic Address. (3) Chọn `Custodian Bank`. |
| Involved Party | [Involved Party] Organization | Organization | AGENCIES | Update | Danh sách đại lý quỹ đầu tư | Fund Distribution Agent | Fundamental | (1) Term candidate: `Fund Distribution Agent` — BCV mô tả tổ chức phân phối chứng chỉ quỹ cho nhà đầu tư. (2) Cấu trúc trường: AGENCIES có tên, loại đại lý (AGENCYTYPE FK), địa chỉ → entity tổ chức độc lập, có AGENCIESBRA bảng con, FK từ AGENFUNDS. (3) Chọn `Fund Distribution Agent`. |
| Event | [Event] Assessment Period | Period | RATINGPD | Update | Danh sách kỳ đánh giá xếp loại công ty QLQ | Member Rating Period | Fundamental | (1) Term candidate: `Assessment Period` — BCV mô tả một chu kỳ đánh giá có ngày bắt đầu/kết thúc, tên kỳ, trạng thái. (2) Cấu trúc trường: RATINGPD có tên kỳ, thời gian kỳ đánh giá, trạng thái → master entity kỳ đánh giá, được FK từ RANK. (3) Chọn `Assessment Period` — xác nhận cần tra thêm. |
| Condition | [Condition] Scoring Criterion | Scoring Criterion | RNKFACTOR | Update | Bảng nhân tố chấm điểm đánh giá xếp loại (self-ref cha/con) | Rating Criterion | Fundamental | (1) Term candidate: `Scoring Criterion` — BCV mô tả nhân tố/tiêu chí dùng để tính điểm đánh giá. (2) Cấu trúc trường: RNKFACTOR self-ref ParentId (cấu trúc cây nhân tố cha/con), trọng số điểm → cấu hình tiêu chí chấm điểm, không phải kết quả → Condition. (3) Chọn `Scoring Criterion`. |
| Event | [Event] Business Activity | Period | RPTPERIOD | Update | Kỳ báo cáo định kỳ của thành viên | Reporting Period | Fundamental | (1) Term candidate: `Business Activity` — BCV mô tả kỳ thời gian được định nghĩa để thu thập báo cáo. (2) Cấu trúc trường: RPTPERIOD có tên kỳ, ngày bắt đầu/kết thúc, trạng thái → master entity kỳ báo cáo, FK từ RPTMEMBER. (3) Chọn `Business Activity` — đây là kỳ thời gian nghiệp vụ. |
| Involved Party | [Involved Party] Conduct Violation | Conduct Violation | VIOLT | Update | Danh sách vi phạm của thành viên thị trường | Member Conduct Violation | Fundamental | (1) Term candidate: `Conduct Violation` — BCV mô tả sự kiện vi phạm quy định của thành viên thị trường. (2) Cấu trúc trường: VIOLT lưu thông tin vi phạm của các thành viên (SECURITIES, FUNDS...), loại vi phạm, quyết định xử lý → entity vi phạm của thành viên, có FK đến nhiều entity Tier 1. (3) Chọn `Conduct Violation`. |

---

## 6b. Diagram Source (Mermaid)

```mermaid
erDiagram
    SECURITIES {
        raw ID PK
        nvarchar CODE
        nvarchar ITEM_NAME
        nvarchar ADDRESS
        nvarchar TELEPHONE
        nvarchar EMAIL
        nvarchar ID_NO
        number CAPITAL
        raw STATUS_ID FK
        raw CT_ID FK
        date FR_DATE
        date TO_DATE
    }

    NATIONAL {
        raw ID PK
        nvarchar CODE
        nvarchar ITEM_NAME
    }

    BANKMONI {
        raw ID PK
        nvarchar CODE
        nvarchar ITEM_NAME
        nvarchar ADDRESS
        nvarchar TELEPHONE
        nvarchar EMAIL
    }

    AGENCIES {
        raw ID PK
        nvarchar CODE
        nvarchar ITEM_NAME
        nvarchar ADDRESS
        raw AGENCYTYPE_ID FK
    }

    AGENCYTYPE {
        raw ID PK
        nvarchar CODE
        nvarchar ITEM_NAME
    }

    RATINGPD {
        raw ID PK
        nvarchar ITEM_NAME
        date FR_DATE
        date TO_DATE
    }

    RNKFACTOR {
        raw ID PK
        nvarchar ITEM_NAME
        number WEIGHT
        raw PARENT_ID FK
    }

    RPTPERIOD {
        raw ID PK
        nvarchar ITEM_NAME
        date FR_DATE
        date TO_DATE
    }

    STATUS {
        raw ID PK
        nvarchar CODE
        nvarchar ITEM_NAME
    }

    BUSINESS {
        raw ID PK
        nvarchar CODE
        nvarchar ITEM_NAME
    }

    AGENCIES }o--|| AGENCYTYPE : "AGENCYTYPE_ID"
    RNKFACTOR }o--o| RNKFACTOR : "PARENT_ID (self-ref)"
    SECURITIES }o--o| STATUS : "STATUS_ID"
```

---

## 6c. Diagram Atomic (Mermaid)

```mermaid
erDiagram
    Fund_Management_Company {
        bigint ds_fund_management_company_id PK
        string fund_management_company_code
        string fund_management_company_name
        string operation_status_code
        date registration_date
        number registered_capital
    }

    Custodian_Bank {
        bigint ds_custodian_bank_id PK
        string custodian_bank_code
        string custodian_bank_name
    }

    Fund_Distribution_Agent {
        bigint ds_fund_distribution_agent_id PK
        string fund_distribution_agent_code
        string fund_distribution_agent_name
        string agency_type_code
    }

    Member_Rating_Period {
        bigint ds_member_rating_period_id PK
        string member_rating_period_code
        string member_rating_period_name
        date period_from_date
        date period_to_date
    }

    Rating_Criterion {
        bigint ds_rating_criterion_id PK
        string rating_criterion_code
        string rating_criterion_name
        bigint parent_rating_criterion_id FK
    }

    Reporting_Period {
        bigint ds_reporting_period_id PK
        string reporting_period_code
        string reporting_period_name
        date period_from_date
        date period_to_date
    }

    Geographic_Area {
        bigint ds_geographic_area_id PK
        string geographic_area_code
        string geographic_area_name
        string geographic_area_type_code
    }

    Member_Conduct_Violation {
        bigint ds_member_conduct_violation_id PK
        string violation_code
        string violation_type_code
    }

    Rating_Criterion }o--o| Rating_Criterion : "parent_rating_criterion_id"
```

---

## 6d. Mục Danh mục & Tham chiếu (Reference Data)

| Source Field / Bảng | Mô tả | Scheme Code | source_type | Ghi chú |
|---|---|---|---|---|
| BUSINESS | Danh mục ngành nghề kinh doanh của công ty QLQ | `FMS_BUSINESS_TYPE` | source_table | Values load từ BUSINESS.CODE + ITEM_NAME |
| JOBTYPE | Danh sách loại chức vụ nhân sự | `FMS_JOB_TYPE` | source_table | Values load từ JOBTYPE.CODE + ITEM_NAME |
| RELATION | Danh mục loại quan hệ cổ đông | `FMS_RELATION_TYPE` | source_table | Values load từ RELATION.CODE + ITEM_NAME |
| STATUS | Danh sách trạng thái hoạt động | `FMS_OPERATION_STATUS` | source_table | Dùng chung cho SECURITIES, FUNDS, BANKMONI, AGENCIES... |
| STOCKHOLDERTYPE | Danh sách loại hình NĐT/cổ đông | `FMS_STOCKHOLDER_TYPE` | source_table | Values load từ STOCKHOLDERTYPE.CODE + ITEM_NAME |
| AGENCYTYPE | Danh sách loại đại lý quỹ | `FMS_AGENCY_TYPE` | source_table | Values load từ AGENCYTYPE.CODE + ITEM_NAME |
| SECURITIES.BORF_FLAG | Loại tổ chức theo địa giới: 1=Trong nước, 0=Nước ngoài | `FMS_ORG_TERRITORY_TYPE` | etl_derived | ETL derived: DOMESTIC / FOREIGN |
| RANK.RANK_TYPE | Loại xếp hạng: 1=Cuối năm, 2=Giữa năm | `FMS_RATING_PERIOD_TYPE` | etl_derived | ETL derived: YEAR_END / MID_YEAR |

---

## 6e. Bảng chờ thiết kế

| Source Table | Mô tả bảng nguồn | Lý do chưa thiết kế |
|---|---|---|
| VIOLT | Danh sách vi phạm thành viên | BCV Concept cần xác nhận thêm — VIOLT có FK đến SECURITIES, FUNDS, BANKMONI, FORBRCH → cần đọc cấu trúc cột đầy đủ trước khi xác định tier chính xác. Tạm đưa vào Tier 1 chờ xác nhận. |

*(Các bảng pending (FMS.8, FMS.9) chưa có đủ thông tin cột → chờ khảo sát bổ sung)*

---

## 6f. Điểm cần xác nhận

| # | Câu hỏi | Kết quả |
|---|---|---|
| T1-01 | SECURITIES dùng chung 1 bảng cho cả công ty QLQ trong nước (BORF_FLAG=1) và VPĐD/CN nước ngoài (BORF_FLAG=0) — xác nhận grain của entity Fund Management Company có bao gồm cả 2 loại không, hay chỉ bao gồm loại trong nước? | **Chờ xác nhận.** BRD notes ghi FORBRCH là entity riêng cho VPĐD/CN QLQ nước ngoài — SECURITIES chỉ cho công ty QLQ trong nước. Cần kiểm tra BORF_FLAG thực tế. |
| T1-02 | RATINGPD — BCV Concept `Assessment Period` cần tra lại nếu BCV dự án dùng term khác. | **Chờ xác nhận.** Tạm dùng `Assessment Period` — sẽ cập nhật nếu BCV Term chính xác hơn. |
| T1-03 | VIOLT có FK đến SECURITIES, FUNDS, BANKMONI, FORBRCH, AGENCIES (đa hướng) — xác nhận grain: 1 vi phạm = 1 thành viên hay có thể 1 vi phạm liên quan nhiều thành viên? | **Chờ xác nhận.** Tạm giữ ở Tier 1. Nếu VIOLT FK đến entity Tier 2 → phải chuyển lên Tier 2 hoặc 3. |
| T1-04 | NATIONAL — xác nhận shared entity `Geographic Area` đã approved từ NHNCK. Chỉ bổ sung `source_table: FMS.NATIONAL`, không tạo entity mới. | **Xác nhận: đúng.** Geographic Area đã locked từ NHNCK. |
| T1-05 | RPTPERIOD — BCV Concept cần xác nhận xem là `Business Activity` (period) hay có term cụ thể hơn như `Reporting Period`. | **Chờ xác nhận.** Tạm dùng `Business Activity`. |
