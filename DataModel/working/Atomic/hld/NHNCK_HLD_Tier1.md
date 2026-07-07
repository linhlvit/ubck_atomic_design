# NHNCK — HLD Tier 1: Reference Data (Main Entities)

> **Phụ thuộc:** Không phụ thuộc Tier nào — là nền tảng cho tất cả Tier sau.
>
> **Thiết kế theo:** [NHNCK_HLD_Overview.md](NHNCK_HLD_Overview.md)

---

## 6a. Bảng tổng quan BCV Concept

| BCV Core Object | BCV Concept | Category | Source Table | Source Table Change Mode | Mô tả bảng nguồn | Atomic Entity | Table Type | BCV Term |
|---|---|---|---|---|---|---|---|---|
| Location | [Location] Geographic Area | Geographic Area | COUNTRIES | Update | Danh mục quốc gia/vùng lãnh thổ theo ISO 3166 | Geographic Area | Fundamental | Geographic Area — BCV ngoại lệ: dù chỉ có Code+Name vẫn là Atomic entity vì BCV có Data Concept Location riêng. Cùng Atomic entity với PROVINCES + DISTRICTS, phân biệt bằng Geographic Area Type Code = COUNTRY. |
| Location | [Location] Geographic Area | Geographic Area | PROVINCES | Update | Danh mục tỉnh/thành phố trực thuộc trung ương | Geographic Area | Fundamental | Geographic Area — cùng Atomic entity với COUNTRIES + DISTRICTS. Geographic Area Type Code = PROVINCE. FK self-ref đến Geographic Area cha (COUNTRY). |
| Location | [Location] Geographic Area | Geographic Area | DISTRICTS | Update | Danh mục quận/huyện/thị xã | Geographic Area | Fundamental | Geographic Area — cùng Atomic entity với COUNTRIES + PROVINCES. Geographic Area Type Code = DISTRICT. FK self-ref đến Geographic Area cha (PROVINCE → COUNTRY). |
| Involved Party | [Involved Party] Organization | Organization | UNITS | Update | Danh mục đơn vị thuộc UBCKNN | Regulatory Authority Organization Unit | Fundamental | Organization — cơ cấu tổ chức UBCKNN dạng cây self-referencing. Cùng Atomic entity với DEPARTMENTS. Phân biệt bằng Organization Unit Type Code (UNIT/DEPARTMENT) và Source System Code. |
| Involved Party | [Involved Party] Organization | Organization | DEPARTMENTS | Update | Danh mục phòng ban thuộc UBCKNN | Regulatory Authority Organization Unit | Fundamental | Organization — cùng Atomic entity với UNITS. Parent của DEPARTMENTS trỏ đến UNITS (UNIT_ID). Phân biệt bằng Organization Unit Type Code = DEPARTMENT và Source System Code. 2 attr file riêng biệt (attr_NHNCK_Units.csv + attr_NHNCK_Departments.csv). |
| Involved Party | [Involved Party] Organization | Organization | ORGANIZATIONS | Update | Thông tin các tổ chức tham gia TTCK (CTCK, QLQ, Ngân hàng...) | Securities Organization Reference | Fundamental | Organization — *"Identifies an Involved Party that may stand alone in an operational or legal context."* Cấu trúc trường: mã tổ chức, tên, loại hình, vốn điều lệ, trạng thái, self-ref PARENT_ID. Được FK từ Employment Status và Organization Employment Report. |
| Documentation | [Documentation] Gov. Registration Document | Government Registration Document | DECISIONS | Update | Danh mục các quyết định hành chính do UBCKNN ban hành | Securities Practitioner License Decision Document | Fundamental | Government Registration Document — *"Identifies a Documentation Item that is issued by a principality or sovereignty."* Cấu trúc trường: số QĐ, tiêu đề, loại quyết định, ngày ký, người ký, trạng thái, file đính kèm. Được FK từ Certificate Document (×2), Certificate Group Document, Conduct Violation, Examination Assessment. |
| ~~Involved Party~~ | ~~[Involved Party] Individual~~ | ~~Individual~~ | USERS | Update | Thông tin cán bộ/chuyên viên UBCKNN có tài khoản trong hệ thống NHNCK | **LOẠI KHỎI SCOPE (2026-07-07)** — Regulatory Authority Officer đã xóa | — | Quyết định Data Modeler: không thiết kế Atomic entity riêng. Định hướng dùng chung Identity and Access Management User (IAM.USERS) — xem NHNCK_HLD_Overview.md 7e #6. |
| Documentation | [Documentation] Gov. Registration Document | Government Registration Document | CERTIFICATES | Update | Danh mục các loại chứng chỉ hành nghề chứng khoán | Securities Practitioner License Certificate Type | Fundamental | Government Registration Document — danh mục CCHN với processing_days/sort_order/description (entity thật, không phải Classification Value). Mới thiết kế 2026-07-07 — xem NHNCK_HLD_Overview.md 7e #8. |

---

## 6b. Diagram Source (Mermaid)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f

    COUNTRIES["**COUNTRIES**\nDanh mục quốc gia"]:::src
    PROVINCES["**PROVINCES**\nDanh mục tỉnh/thành phố"]:::src
    DISTRICTS["**DISTRICTS**\nDanh mục quận/huyện"]:::src
    UNITS["**UNITS**\nDanh mục đơn vị UBCKNN"]:::src
    DEPARTMENTS["**DEPARTMENTS**\nDanh mục phòng ban UBCKNN"]:::src
    ORGANIZATIONS["**ORGANIZATIONS**\nTổ chức tham gia TTCK"]:::src
    DECISIONS["**DECISIONS**\nQuyết định hành chính"]:::src
    USERS["**USERS**\nCán bộ UBCKNN"]:::src
    PROVINCES -->|"COUNTRY_ID"| COUNTRIES
    DISTRICTS -->|"COUNTRY_ID"| COUNTRIES
    DISTRICTS -->|"PROVINCE_ID"| PROVINCES
    DEPARTMENTS -->|"UNIT_ID"| UNITS
    USERS -->|"UNIT_ID"| UNITS
    USERS -->|"DEPARTMENT_ID"| DEPARTMENTS
    DECISIONS -->|"CREATED_BY"| USERS
    ORGANIZATIONS -->|"CREATED_BY"| USERS
    ORGANIZATIONS -->|"PARENT_ID (self-ref)"| ORGANIZATIONS
    ORGANIZATIONS -->|"ORGANIZATION_TYPE_ID (self-ref)"| ORGANIZATIONS
```

---

## 6c. Diagram Atomic (Mermaid)

```mermaid
graph TD
    classDef atomic fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef shared fill:#fae8ff,stroke:#9333ea,color:#4a044e

    GEOAREA["**Geographic Area**\n[Location] Geographic Area\nCOUNTRIES + PROVINCES + DISTRICTS\n(phân biệt bằng Geographic Area Type Code)"]:::atomic
    ORGUNIT["**Regulatory Authority Organization Unit**\n[Involved Party] Organization\nUNITS + DEPARTMENTS"]:::atomic
    SECORG["**Securities Organization Reference**\n[Involved Party] Organization\nORGANIZATIONS"]:::atomic
    DECISION["**Securities Practitioner License Decision Document**\n[Documentation] Gov. Registration Document\nDECISIONS"]:::atomic
    OFFICER["**Identity and Access Management User** (pending)\nnguồn IAM.USERS — thay Regulatory\nAuthority Officer đã loại khỏi scope"]:::atomic
    CERTTYPE["**Securities Practitioner License Certificate Type**\n[Documentation] Gov. Registration Document\nCERTIFICATES"]:::atomic
    ADDR["IP Postal Address"]:::shared
    EADDR["IP Electronic Address"]:::shared
    ALTID["IP Alt Identification"]:::shared

    GEOAREA -->|"Parent Geographic Area FK (self-ref)"| GEOAREA
    ORGUNIT -->|"Parent Organization Unit FK (self-ref)"| ORGUNIT
    OFFICER -->|"Organization Unit FK (UNIT_ID)"| ORGUNIT
    OFFICER -->|"Department Organization Unit FK (DEPARTMENT_ID)"| ORGUNIT
    DECISION -->|"Created By Officer FK"| OFFICER
    SECORG -->|"Created By Officer FK"| OFFICER
    SECORG -->|"Parent Organization FK (self-ref)"| SECORG
    ADDR -.->|"shared"| SECORG
    EADDR -.->|"shared"| SECORG
    ALTID -.->|"shared"| SECORG
```

---

## 6d. Danh mục & Tham chiếu

| Source Table | Mô tả | Scheme Code dự kiến | Ghi chú |
|---|---|---|---|
| POSITIONS | Danh mục chức vụ | POSITION | Chỉ có Code + Name → Classification Value (Employment Position Type). Không tạo Atomic entity. |
| EDUCATION_LEVELS | Danh mục trình độ học vấn | EDUCATION_LEVEL | Classification Value. |
| APPLICATION_STATUSES | Định nghĩa trạng thái hồ sơ | APPLICATION_STATUS | Classification Value. |
| CERTIFICATES | Danh mục loại chứng chỉ hành nghề | CERTIFICATE_TYPE | Classification Value — chỉ có CERTIFICATE_CODE + CERTIFICATE_NAME + metadata vận hành. |
| SPECIALIZATIONS | Danh mục chuyên môn | SPECIALIZATION | Classification Value. |
| DOCUMENTS | Danh mục loại tài liệu hồ sơ | DOCUMENT_TYPE | Classification Value. |
| APPLICATION_SOURCES | Hình thức nộp hồ sơ | APPLICATION_SOURCE | Classification Value. |

---

## 6e. Bảng chờ thiết kế

Không có bảng nào trong Tier 1 chưa đủ thông tin cột.

---

## 6f. Điểm cần xác nhận

| # | Câu hỏi | Ảnh hưởng |
|---|---|---|
| 1 | `DECISIONS.CREATED_BY` là FK thực đến USERS. | **Xác nhận.** FK thực → thiết kế giữ Created By Officer FK trên entity License Decision Document. |
| 2 | `ORGANIZATIONS` có bao gồm cả UBCKNN không? | **Xác nhận: không bao gồm.** ORGANIZATIONS chỉ chứa tổ chức tham gia TTCK bên ngoài → không có overlap với Regulatory Authority Organization Unit. |
| 3 | `ORGANIZATIONS.ORGANIZATION_TYPE_ID` tự tham chiếu — là loại hình tổ chức (Classification Value) hay FK entity khác? | **Xác nhận: Classification Value.** Xử lý thành ORGANIZATION_TYPE_CODE trên Atomic, không tạo FK entity riêng. |
