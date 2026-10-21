# THANHTRA HLD — Tier 2

**Source system:** THANHTRA (Hệ thống Thanh tra, Kiểm tra và Xử phạt vi phạm hành chính — UBCKNN)
**Tier 2:** Entity có FK đến Tier 1. Gồm 5 entity: đoàn thanh tra/kiểm tra (→T1 Annual Plan), danh sách mục tiêu kế hoạch (→T1 Annual Plan), danh mục hành vi vi phạm (→T1 Penalty Type).

---

## 6a. Bảng tổng quan BCV Concept

| BCV Core Object | BCV Concept | Category | Source Table | Source Table Change Mode | Mô tả bảng nguồn | Atomic Entity | Table Type | BCV Term |
|---|---|---|---|---|---|---|---|---|
| Business Activity | [Business Activity] Business Review | Inspection | INSPECTION_TEAM | Update | Hồ sơ đoàn thanh tra: mã CODE(HSTT-YYYY-XXX), FK→ANNUAL_PLAN(nullable), FORM_TYPE(PERIODIC/UNSCHEDULED), DECISION_NUMBER, thông tin đoàn, ngày ký biên bản xác minh | Inspection Team | Fundamental | (1) Business Review — BCV: "a Business Activity in which business operations are studied and compared to business objectives". Status Review — BCV: "a Business Activity in which the status of an item is reviewed". (2) Bảng có CODE chuẩn HSTT-YYYY-XXX, FK→ANNUAL_PLAN(nullable), PLAN_YEAR, FORM_TYPE(PERIODIC/UNSCHEDULED), DECISION_NUMBER(UNIQUE), rich inspection team details, VERIFICATION_MINUTES_SIGN_DATE — đây là instance một đoàn thanh tra cụ thể, có mã số, quyết định thành lập, lifecycle. (3) Business Review là term BCV phù hợp nhất cho hoạt động thanh tra (review business operations so với objectives). Không có "Regulatory Inspection" trong BCV. |
| Business Activity | [Business Activity] Business Review | Examination | EXAMINATION_TEAM | Update | Hồ sơ đoàn kiểm tra: cấu trúc song song với INSPECTION_TEAM nhưng mã CODE(HSKT-YYYY-XXX), FK→EXAMINATION_ANNUAL_PLAN(nullable), có thêm UNIT_ID/UNIT_NAME | Examination Team | Fundamental | (1) Business Review — cùng mô tả như INSPECTION_TEAM. (2) Bảng có CODE(HSKT-YYYY-XXX), FK→EXAMINATION_ANNUAL_PLAN(nullable), UNIT_ID, UNIT_NAME, FORM_TYPE, DECISION_NUMBER(UNIQUE) — đoàn kiểm tra cụ thể. (3) Business Review khớp. Inspection và Examination khác thẩm quyền nhưng cùng BCV Concept — tạo 2 entity riêng vì 2 loại hình nghiệp vụ khác nhau. |
| Business Activity | [Business Activity] Business Review | Inspection Target | INSPECTION_ANNUAL_PLAN_TARGET | Update | Danh sách đối tượng thanh tra trong kế hoạch năm: TARGET_TYPE(SECURITIES_COMPANY/FUND_MGT_COMPANY/PUBLIC_COMPANY), TARGET_NAME, số lượng | Inspection Annual Plan Target | Fundamental | (1) Business Review — BCV: entity này ghi nhận danh sách đối tượng của hoạt động thanh tra trong kế hoạch. (2) Bảng có FK→INSPECTION_ANNUAL_PLAN, TARGET_TYPE(3 values), TARGET_NAME, số lượng — danh sách đối tượng được đưa vào kế hoạch thanh tra. (3) BCO đổi sang Business Activity vì đây là đối tượng của hoạt động thanh tra. Tên chứa "Inspection Annual Plan" ✓. |
| Business Activity | [Business Activity] Business Review | Examination Target | EXAMINATION_ANNUAL_PLAN_TARGET | Update | Danh sách đối tượng kiểm tra trong kế hoạch năm: tương tự INSPECTION_ANNUAL_PLAN_TARGET | Examination Annual Plan Target | Fundamental | (1) Business Review — BCV: cùng mô tả. (2) Cấu trúc đồng nhất với INSPECTION_ANNUAL_PLAN_TARGET. (3) BCO đổi sang Business Activity. Tên chứa "Examination Annual Plan" ✓. |
| Business Activity | [Business Activity] Conduct Violation | Violation Behavior Catalog | VIOLATION_BEHAVIOR | Update | Danh mục hành vi vi phạm hành chính: CODE(UNIQUE), NAME, FK→PENALTY_TYPE, MIN/MAX_FINE_AMOUNT, REMEDIAL_MEASURE, VIOLATION_CLAUSE | Violation Behavior | Fundamental | (1) Conduct Violation — BCV: "a Business Activity that breaches a business code of conduct". (2) Bảng có CODE(UNIQUE), NAME, PRIMARY_PENALTY_TYPE_ID(FK→PENALTY_TYPE), MIN_FINE_AMOUNT, MAX_FINE_AMOUNT, REMEDIAL_MEASURE, LEGAL_DOCUMENT(text legacy), VIOLATION_CLAUSE — danh mục hành vi vi phạm có mức phạt tiền min/max. (3) Không thuần Code+Name vì có fine range, FK→PENALTY_TYPE → Fundamental. Conduct Violation phù hợp. |

---

## 6b. Diagram Source (Mermaid)

```mermaid
erDiagram
    INSPECTION_ANNUAL_PLAN {
        varchar ID PK
    }
    EXAMINATION_ANNUAL_PLAN {
        varchar ID PK
    }
    PENALTY_TYPE {
        varchar ID PK
    }

    INSPECTION_TEAM {
        varchar ID PK
        varchar INSPECTION_ANNUAL_PLAN_ID FK
        varchar FORM_TYPE
        varchar DECISION_NUMBER
    }
    EXAMINATION_TEAM {
        varchar ID PK
        varchar EXAMINATION_ANNUAL_PLAN_ID FK
        varchar FORM_TYPE
        varchar DECISION_NUMBER
    }
    INSPECTION_ANNUAL_PLAN_TARGET {
        varchar ID PK
        varchar INSPECTION_ANNUAL_PLAN_ID FK
        varchar TARGET_TYPE
        varchar TARGET_NAME
    }
    EXAMINATION_ANNUAL_PLAN_TARGET {
        varchar ID PK
        varchar EXAMINATION_ANNUAL_PLAN_ID FK
        varchar TARGET_TYPE
    }
    VIOLATION_BEHAVIOR {
        varchar ID PK
        varchar PRIMARY_PENALTY_TYPE_ID FK
        varchar CODE
        number MIN_FINE_AMOUNT
        number MAX_FINE_AMOUNT
    }

    INSPECTION_ANNUAL_PLAN ||--o{ INSPECTION_TEAM : "nullable FK"
    EXAMINATION_ANNUAL_PLAN ||--o{ EXAMINATION_TEAM : "nullable FK"
    INSPECTION_ANNUAL_PLAN ||--o{ INSPECTION_ANNUAL_PLAN_TARGET : "FK"
    EXAMINATION_ANNUAL_PLAN ||--o{ EXAMINATION_ANNUAL_PLAN_TARGET : "FK"
    PENALTY_TYPE ||--o{ VIOLATION_BEHAVIOR : "FK"
```

---

## 6c. Diagram Atomic (Mermaid)

```mermaid
erDiagram
    Inspection_Annual_Plan {
        bigint ds_inspection_annual_plan_id PK
    }
    Examination_Annual_Plan {
        bigint ds_examination_annual_plan_id PK
    }
    Penalty_Type {
        bigint ds_penalty_type_id PK
    }

    Inspection_Team {
        bigint ds_inspection_team_id PK
        varchar inspection_team_code
        bigint ds_inspection_annual_plan_id FK
        varchar inspection_annual_plan_code
        varchar inspection_form_type_code
        varchar decision_number
    }
    Examination_Team {
        bigint ds_examination_team_id PK
        varchar examination_team_code
        bigint ds_examination_annual_plan_id FK
        varchar examination_annual_plan_code
        varchar examination_form_type_code
        varchar decision_number
    }
    Inspection_Annual_Plan_Target {
        bigint ds_inspection_annual_plan_target_id PK
        bigint ds_inspection_annual_plan_id FK
        varchar inspection_annual_plan_code
        varchar target_type_code
    }
    Examination_Annual_Plan_Target {
        bigint ds_examination_annual_plan_target_id PK
        bigint ds_examination_annual_plan_id FK
        varchar examination_annual_plan_code
        varchar target_type_code
    }
    Violation_Behavior {
        bigint ds_violation_behavior_id PK
        varchar violation_behavior_code
        bigint ds_penalty_type_id FK
        varchar penalty_type_code
        number min_fine_amount
        number max_fine_amount
    }

    Inspection_Annual_Plan ||--o{ Inspection_Team : "nullable"
    Examination_Annual_Plan ||--o{ Examination_Team : "nullable"
    Inspection_Annual_Plan ||--o{ Inspection_Annual_Plan_Target : ""
    Examination_Annual_Plan ||--o{ Examination_Annual_Plan_Target : ""
    Penalty_Type ||--o{ Violation_Behavior : ""
```

---

## 6d. Mục Danh mục & Tham chiếu (Reference Data)

| Source Field / Bảng | Mô tả | Scheme Code | source_type | Ghi chú |
|---|---|---|---|---|
| INSPECTION_TEAM.FORM_TYPE / EXAMINATION_TEAM.FORM_TYPE | Hình thức: PERIODIC (Định kỳ), UNSCHEDULED (Đột xuất) | `TT_REVIEW_FORM_TYPE` | source_table | Dùng chung cho cả 2 loại đoàn |
| INSPECTION_ANNUAL_PLAN_TARGET.TARGET_TYPE / EXAMINATION_ANNUAL_PLAN_TARGET.TARGET_TYPE | Loại đối tượng kế hoạch: SECURITIES_COMPANY, FUND_MANAGEMENT_COMPANY, PUBLIC_COMPANY | `TT_PLAN_TARGET_TYPE` | source_table | |
| EXAMINATION_TEAM_TARGET.TARGET_TYPE / INSPECTION_TEAM_TARGET.TARGET_TYPE | Loại đối tượng đoàn (rộng hơn plan target, thêm AUDIT_COMPANY, CRYPTO_SERVICE_PROVIDER, INDIVIDUAL, ORGANIZATION) | `TT_TEAM_TARGET_TYPE` | source_table | Khác với TT_PLAN_TARGET_TYPE — thêm 4 loại |

---

## 6e. Bảng chờ thiết kế

*(Để trống)*

---

## 6f. Điểm cần xác nhận

| # | Câu hỏi | Kết quả |
|---|---|---|
| T2-01 | INSPECTION_TEAM và EXAMINATION_TEAM có cùng BCV Concept [Business Activity] Business Review — có nên gộp thành 1 entity với Classification Value phân biệt không? | Không gộp. Hai loại hình nghiệp vụ khác nhau (thanh tra vs kiểm tra), khác thẩm quyền, có FK về 2 annual plan khác nhau. Tách entity phù hợp hơn để phân tích báo cáo riêng. |
| T2-03 | VIOLATION_BEHAVIOR có LEGAL_DOCUMENT cột text (không FK chính thức đến bảng LEGAL_DOCUMENT) — cần làm rõ có cần FK đến TT Legal Document không hay chỉ lưu text. | Ghi nhận: LEGAL_DOCUMENT trong VIOLATION_BEHAVIOR là text legacy field. Khi thiết kế LLD sẽ xem xét thêm FK suy luận hoặc bỏ qua. |
