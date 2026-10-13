# FMS — HLD Tier 3: Phụ thuộc Tier 2

> **Phụ thuộc Tier 1:** Fund Management Company, Custodian Bank, Fund Distribution Agent, Classification FMS Job
> **Phụ thuộc Tier 2:** Foreign Fund Management Organization Unit, Fund Management Company Employee, Investment Fund, Discretionary Investment Investor
>
> **Thiết kế theo:** [FMS_HLD_Overview.md](FMS_HLD_Overview.md)

---

## 6a. Bảng tổng quan BCV Concept

| BCV Core Object | BCV Concept | Category | Source Table | Source Table Change Mode | Mô tả bảng nguồn | Atomic Entity | Table Type | BCV Term |
|---|---|---|---|---|---|---|---|---|
| Involved Party | [Involved Party] Individual Employment Status | Employment Status | STF_FG_BRCH | Update | Danh sách nhân sự của VPĐD/CN công ty QLQ nước ngoài tại VN | Foreign Fund Management Organization Unit Staff | Fundamental | (1) Term candidate: `Individual Employment Status` — cá nhân giữ vị trí trong tổ chức. (2) Cấu trúc trường: STF_FG_BRCH có FK đến FOR_BRCH (tổ chức) + FK đến TL_PROFILES (nhân sự kiêm nhiệm), họ tên, chức vụ, ngày bổ nhiệm → entity vai trò nhân sự trong tổ chức VPĐD NN. (3) Chọn `Individual Employment Status`. |
| Involved Party | [Involved Party] Individual Employment Status | Employment Status | REPRESENT | Update | Danh sách ban đại diện/HĐQT quỹ đầu tư | Investment Fund Representative Board Member | Fundamental | (1) Term candidate: `Individual Employment Status` — thành viên ban đại diện là cá nhân đang giữ vị trí trong cơ cấu quản trị quỹ. (2) Cấu trúc trường: REPRESENT có FK đến FUNDS (quỹ) + FK đến TL_PROFILES (nhân sự QLQ), chức vụ trong BĐD, ngày bổ nhiệm/thôi chức → giao giữa nhân sự và quỹ. (3) Chọn `Individual Employment Status`. |
| Arrangement | [Arrangement] Investment Account | Investment Account | INVES_ACC | Update | Danh sách tài khoản của nhà đầu tư ủy thác | Discretionary Investment Account | Relative | (1) Term candidate: `Investment Account` — tài khoản được mở cho NĐT ủy thác. (2) Cấu trúc trường: INVES_ACC có FK đến INVES (NĐT ủy thác), mã tài khoản, ngày mở, trạng thái → entity tài khoản phụ thuộc NĐT ủy thác (Tier 2). (3) Chọn `Investment Account`. |
| Involved Party | [Involved Party] Individual Employment Status | Investment Fund | FUND_TL_PRO | Update | Người hành nghề liên quan đến quỹ đầu tư (junction) | Fund Management Company Employee X Investment Fund Relationship | Relative | **[MỚI 2026-07-19]** Junction thuần (FUND_ID + TLPR_ID) — trước đây ở Overview 7f. FK đến Fund Management Company Employee (Tier 2) + Investment Fund (Tier 2). **[SỬA 2026-08-15]** BCO đổi Arrangement→Involved Party, tái dùng concept từ phía Employee — khớp với chính Investment Fund (đã BCO Involved Party). Đã tra BCV chính thức — xem Overview 7e#20. |
| Involved Party | [Involved Party] Organization | Investment Fund | AGEN_FUNDS | Update | Bảng trung gian đại lý và quỹ đầu tư (junction) | Fund Distribution Agent X Investment Fund Relationship | Relative | **[MỚI 2026-07-19]** Junction (AGENCY_ID + FUND_ID + DATA_MIGRATION). FK đến Fund Distribution Agent (Tier 1) + Investment Fund (Tier 2). `DATA_MIGRATION` (cờ migration kỹ thuật) không map. FUD_AG_AGT (mở rộng 4-FK) cần rà soát gộp/tách — xem Overview 7e#19. **[SỬA 2026-08-15]** BCO đổi Arrangement→Involved Party, tái dùng concept từ phía Agent — khớp với chính Investment Fund (đã BCO Involved Party). Đã tra BCV chính thức — xem Overview 7e#20. |
| Involved Party | [Involved Party] Organization | Investment Fund | FUD_AG_AGT | Update | Bảng trung gian quỹ, loại đại lý và đại lý phân phối | Fund Distribution Agent X Investment Fund X Classification FMS Agency Type Relationship | Relative | **[MỚI 2026-10-12]** Junction 4-FK, thiết kế entity Relative riêng theo Data Modeler (không gộp AGEN_FUNDS) — giải quyết Overview 7e#19. FK đến Fund Distribution Agent (T1) + Investment Fund (T2) + Classification FMS Agency Type (T1). Chỉ map FUD_ID, AG_TY_ID, AGEN_ID; AGEN_ID_PARENT chưa map. |

---

## 6b. Diagram Source (Mermaid)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef outscope fill:#fef9c3,stroke:#ca8a04,color:#713f12

    STF_FG_BRCH["**STF_FG_BRCH**\nNhân sự VPĐD QLQ NN"]:::src
    REPRESENT["**REPRESENT**\nBan đại diện/HĐQT quỹ"]:::src
    INVES_ACC["**INVES_ACC**\nTài khoản NĐT ủy thác"]:::src
    FUND_TL_PRO["**FUND_TL_PRO**\nNgười hành nghề liên quan quỹ"]:::src
    AGEN_FUNDS["**AGEN_FUNDS**\nĐại lý phân phối và quỹ đầu tư"]:::src

    FOR_BRCH["**FOR_BRCH** (Tier 2)"]:::outscope
    TL_PROFILES["**TL_PROFILES** (Tier 2)"]:::outscope
    FUNDS["**FUNDS** (Tier 2)"]:::outscope
    INVES["**INVES** (Tier 2)"]:::outscope
    JOBS["**JOBS** (Tier 1)"]:::outscope
    AGENCIES["**AGENCIES** (Tier 1)"]:::outscope

    STF_FG_BRCH -->|"FORBRCH_ID"| FOR_BRCH
    STF_FG_BRCH -->|"TL_ID (kiêm nhiệm, nullable)"| TL_PROFILES
    REPRESENT -->|"FUND_ID"| FUNDS
    REPRESENT -->|"TL_ID"| TL_PROFILES
    INVES_ACC -->|"INVES_ID"| INVES
    FUND_TL_PRO -->|"TLPR_ID"| TL_PROFILES
    FUND_TL_PRO -->|"FUND_ID"| FUNDS
    AGEN_FUNDS -->|"AGENCY_ID"| AGENCIES
    AGEN_FUNDS -->|"FUND_ID"| FUNDS
```

---

## 6c. Diagram Atomic (Mermaid)

```mermaid
graph TD
    classDef atomic fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef pattern fill:#e2e8f0,stroke:#64748b,color:#1e293b
    classDef outscope fill:#fef9c3,stroke:#ca8a04,color:#713f12

    FFMS["**Foreign Fund Management Organization Unit Staff**\n[Involved Party] Individual Employment Status\nSTFFGBRCH"]:::atomic
    RBM["**Investment Fund Representative Board Member**\n[Involved Party] Individual Employment Status\nREPRESENT"]:::atomic
    DIA["**Discretionary Investment Account**\n[Arrangement] Investment Account\nINVESACC"]:::atomic
    FUNDPREL["**FMC Employee X Investment Fund Relationship**\n[Involved Party] Individual Employment Status\nFUND_TL_PRO"]:::atomic
    AGENREL["**Fund Distribution Agent X Investment Fund Relationship**\n[Involved Party] Organization\nAGEN_FUNDS"]:::atomic

    FFMOU["**Foreign Fund Management Organization Unit** (Tier 2)"]:::outscope
    KP["**Fund Management Company Employee** (Tier 2)"]:::outscope
    IF["**Investment Fund** (Tier 2)"]:::outscope
    DII["**Discretionary Investment Investor** (Tier 2)"]:::outscope
    CPOS["**Classification FMS Job** (Tier 1)"]:::outscope
    FDA["**Fund Distribution Agent** (Tier 1)"]:::outscope

    FFMS -->|"Foreign Fund Management Organization Unit FK"| FFMOU
    FFMS -->|"Employee FK (nullable)"| KP
    RBM -->|"Investment Fund FK"| IF
    RBM -->|"Employee FK"| KP
    DIA -->|"Discretionary Investment Investor FK"| DII
    FUNDPREL -->|"Investment Fund FK"| IF
    FUNDPREL -->|"Fund Management Company Employee FK"| KP
    AGENREL -->|"Investment Fund FK"| IF
    AGENREL -->|"Fund Distribution Agent FK"| FDA
```

---

## 6d. Danh mục & Tham chiếu

| Source Table | Mô tả | Scheme Code dự kiến | Ghi chú |
|---|---|---|---|
| STF_FG_BRCH.JOBTYPE_ID | Loại chức vụ nhân sự VPĐD NN | `FMS_JOB_TYPE` | source_table — Đã đăng ký Tier 1; tham chiếu lại. |

---

## 6e. Bảng chờ thiết kế

Không có bảng nào trong Tier 3 chưa đủ thông tin cột.

---

## 6f. Điểm cần xác nhận

| # | Câu hỏi | Ảnh hưởng |
|---|---|---|
| T3-01 | STF_FG_BRCH.TL_ID (FK đến TL_PROFILES) nullable — nhân sự VPĐD NN có thể không phải nhân sự QLQ trong nước. Xác nhận: TL_ID là nullable OK? | **Chờ xác nhận.** Thiết kế hiện tại TL_ID nullable. |
| T3-04 | REPRESENT — 1 nhân sự có thể là thành viên BĐD của nhiều quỹ cùng lúc. Grain = (FUND_ID, TL_ID, FR_DATE) → xác nhận. | **Chờ xác nhận.** |
| T3-05 | **[MỚI 2026-07-19, MỘT PHẦN GIẢI QUYẾT 2026-08-15]** 2 entity Relationship (FUND_TL_PRO, AGEN_FUNDS) — BCO Involved Party, tái dùng concept từ phía Employee/Agent tương ứng (xem Overview 7e#20). | Đã giải quyết. |
