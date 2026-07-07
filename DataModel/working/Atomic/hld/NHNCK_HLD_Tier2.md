# NHNCK — HLD Tier 2: Phụ thuộc Tier 1

> **Phụ thuộc Tier 1:** Securities Practitioner License Decision Document, Regulatory Authority Officer, Securities Organization Reference
>
> **Thiết kế theo:** [NHNCK_HLD_Overview.md](NHNCK_HLD_Overview.md)

---

## 6a. Bảng tổng quan BCV Concept

| BCV Core Object | BCV Concept | Category | Source Table | Source Table Change Mode | Mô tả bảng nguồn | Atomic Entity | Table Type | BCV Term |
|---|---|---|---|---|---|---|---|---|
| Involved Party | [Involved Party] Individual | Individual | PROFESSIONALS | Update | Thông tin người hành nghề chứng khoán được UBCKNN quản lý | Securities Practitioner | Fundamental | Individual — *"Identifies an Involved Party who is a natural person."* Cấu trúc trường: mã người hành nghề, họ tên, ngày sinh đầy đủ, giới tính, quốc tịch, nơi sinh, trình độ học vấn, hình thức đăng ký, trạng thái hành nghề, trạng thái tài khoản. Không FK đến bảng nghiệp vụ nào trong Tier 1 (chỉ dùng shared entities). |
| Involved Party | [Involved Party] Individual | Individual | PROFESSIONAL_HISTORIES | Update | Lịch sử thay đổi thông tin cá nhân của người hành nghề | Securities Practitioner Reason Change History | Fundamental | Individual — **Thiết kế lại 2026-07-07** (bản cũ map nhầm source_columns sang PROFESSIONALS). Grain: 1 dòng = 1 lần ghi nhận thay đổi thông tin — chỉ lưu ID/PROFESSIONAL_ID/CHANGE_DATE/REASON_UPDATE. FK đến Securities Practitioner qua PROFESSIONAL_ID. ~43 cột snapshot còn lại loại khỏi thiết kế (xem pending_design.yaml). |
| Event | [Event] Training Course | Training Course | SPECIALIZATION_COURSES | Update | Danh mục khóa học chuyên môn bổ sung kiến thức cho người hành nghề | Securities Practitioner Professional Training Class | Fundamental | Training Course — *"Identifies an Event that is a course of instruction."* Cấu trúc trường: mã khóa học, tên khóa học, loại chuyên môn, thời gian thi, địa điểm, trạng thái. Master entity của khóa học — không gắn với người cụ thể. |
| Communication | [Communication] Assessment | Assessment | EXAM_SESSIONS | Update | Danh mục các đợt thi sát hạch cấp CCHN do UBCKNN tổ chức | Securities Practitioner Qualification Examination Assessment | Fundamental | Assessment — *"Identifies a Communication that is an evaluation or appraisal."* Cấu trúc trường: Session CODE/ITEM_NAME/SESSION_, REPORT_YEAR, ORGANIZING_UNIT, APPLICATION_START_DATE/END_DATE, EXAM_START_DATE/END_DATE, EXAM_LOCATIONS, SUBMISSION_METHODS, RECORD_STATUS, FK đến DECISIONS, FK đến USERS (CREATED_BY + UPDATED_BY), BANK_ID (phí thi). FK đến Tier 1 (Decision + Officer). |

---

## 6b. Diagram Source (Mermaid)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef outscope fill:#fef9c3,stroke:#ca8a04,color:#713f12

    PROFESSIONALS["**PROFESSIONALS**\nNgười hành nghề CK"]:::src
    PROFESSIONAL_HISTORIES["**PROFESSIONAL_HISTORIES**\nLịch sử thông tin người hành nghề\n(lấy bản mới nhất)"]:::src
    SPECIALIZATION_COURSES["**SPECIALIZATION_COURSES**\nKhóa học chuyên môn"]:::src
    EXAM_SESSIONS["**EXAM_SESSIONS**\nĐợt thi sát hạch"]:::src

    DECISIONS["**DECISIONS** (Tier 1)"]:::outscope
    USERS["**USERS** (Tier 1)"]:::outscope
    BANKS["**BANKS** (Classification Value)"]:::outscope

    PROFESSIONAL_HISTORIES -->|"PROFESSIONAL_ID"| PROFESSIONALS
    EXAM_SESSIONS -->|"DECISION_ID"| DECISIONS
    EXAM_SESSIONS -->|"CREATED_BY, UPDATED_BY"| USERS
    EXAM_SESSIONS -->|"BANK_ID"| BANKS
```

---

## 6c. Diagram Atomic (Mermaid)

```mermaid
graph TD
    classDef atomic fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef shared fill:#fae8ff,stroke:#9333ea,color:#4a044e
    classDef outscope fill:#fef9c3,stroke:#ca8a04,color:#713f12

    PRAC["**Securities Practitioner**\n[Involved Party] Individual\nPROFESSIONALS"]:::atomic
    REASONCHG["**Securities Practitioner\nReason Change History**\n[Involved Party] Individual\nPROFESSIONAL_HISTORIES"]:::atomic
    TRAINCLASS["**Securities Practitioner\nProfessional Training Class**\n[Event] Training Course\nSPECIALIZATION_COURSES"]:::atomic
    EXAM["**Securities Practitioner\nQualification Examination Assessment**\n[Communication] Assessment\nEXAM_SESSIONS"]:::atomic

    ADDR["IP Postal Address"]:::shared
    EADDR["IP Electronic Address"]:::shared
    ALTID["IP Alt Identification"]:::shared

    DECISION["**License Decision Document** (Tier 1)"]:::outscope
    OFFICER["**Regulatory Authority Officer** (Tier 1)"]:::outscope

    ADDR -.->|"shared"| PRAC
    EADDR -.->|"shared"| PRAC
    ALTID -.->|"shared"| PRAC
    EXAM -->|"Decision FK"| DECISION
    EXAM -->|"Created By Officer FK"| OFFICER
    EXAM -->|"Updated By Officer FK"| OFFICER
```

---

## 6d. Danh mục & Tham chiếu

| Source Table | Mô tả | Scheme Code | Ghi chú |
|---|---|---|---|
| BANKS | Danh mục ngân hàng (dùng cho nộp phí thi) | BANK | Classification Value. FK từ EXAM_SESSIONS.BANK_ID — chỉ có mã + tên ngân hàng. |

---

## 6e. Bảng chờ thiết kế

Không có bảng nào trong Tier 2 chưa đủ thông tin cột.

---

## 6f. Điểm cần xác nhận

| # | Câu hỏi | Ảnh hưởng |
|---|---|---|
| 1 | `PROFESSIONALS` có FK đến bất kỳ bảng nghiệp vụ Tier 1 nào không (ngoài ORGANIZATIONS, COUNTRIES, PROVINCES, DISTRICTS là danh mục)? | Hiện tại ORGANIZATION_ID trỏ đến ORGANIZATIONS — là Tier 1 entity, không phải Classification Value. Tuy nhiên PROFESSIONALS thiết kế ở Tier 2 vì ORGANIZATION_ID là FK mô tả tổ chức hiện tại (denormalized, có thể null), không phải dependency lifecycle. Cần xác nhận. |
| 2 | `SPECIALIZATION_COURSES.SPECIALIZATION_ID` trỏ đến SPECIALIZATIONS (Classification Value) — xác nhận không có FK đến entity nghiệp vụ Tier 1 nào khác. | **Xác nhận: đúng.** SPECIALIZATION_ID là Classification Value → Tier 2 giữ nguyên. |
| 3 | `EXAM_SESSIONS.BANK_ID` — BANKS chỉ là danh mục thanh toán phí? Hay BANKS là entity Tier 1 phức tạp hơn? | Nếu BANKS chỉ có CODE + NAME → Classification Value, không tạo Atomic entity. |
