# FMS — HLD Tier 3: Phụ thuộc Tier 2

> **Phụ thuộc Tier 1:** Fund Management Company, Custodian Bank, Fund Distribution Agent
> **Phụ thuộc Tier 2:** Foreign Fund Management Organization Unit, Fund Management Company Key Person, Investment Fund, Discretionary Investment Investor
>
> **Thiết kế theo:** [FMS_HLD_Overview.md](FMS_HLD_Overview.md)

---

## 6a. Bảng tổng quan BCV Concept

| BCV Core Object | BCV Concept | Category | Source Table | Source Table Change Mode | Mô tả bảng nguồn | Atomic Entity | Table Type | BCV Term |
|---|---|---|---|---|---|---|---|---|
| Involved Party | [Involved Party] Individual Employment Status | Employment Status | STF_FG_BRCH | Update | Danh sách nhân sự của VPĐD/CN công ty QLQ nước ngoài tại VN | Foreign Fund Management Organization Unit Staff | Fundamental | (1) Term candidate: `Individual Employment Status` — cá nhân giữ vị trí trong tổ chức. (2) Cấu trúc trường: STF_FG_BRCH có FK đến FOR_BRCH (tổ chức) + FK đến TL_PROFILES (nhân sự kiêm nhiệm), họ tên, chức vụ, ngày bổ nhiệm → entity vai trò nhân sự trong tổ chức VPĐD NN. (3) Chọn `Individual Employment Status`. |
| Involved Party | [Involved Party] Individual Employment Status | Employment Status | REPRESENT | Update | Danh sách ban đại diện/HĐQT quỹ đầu tư | Investment Fund Representative Board Member | Fundamental | (1) Term candidate: `Individual Employment Status` — thành viên ban đại diện là cá nhân đang giữ vị trí trong cơ cấu quản trị quỹ. (2) Cấu trúc trường: REPRESENT có FK đến FUNDS (quỹ) + FK đến TL_PROFILES (nhân sự QLQ), chức vụ trong BĐD, ngày bổ nhiệm/thôi chức → giao giữa nhân sự và quỹ. (3) Chọn `Individual Employment Status`. |
| Arrangement | [Arrangement] Investment Fund | Investment Fund | MB_FUND | Update | Danh sách nhà đầu tư nắm giữ chứng chỉ quỹ | Investment Fund Investor Membership | Fundamental | (1) Term candidate: `Investment Fund` — quan hệ thành viên/NĐT trong quỹ (bên nhiều của Arrangement). (2) Cấu trúc trường: MB_FUND có FK đến FUNDS (quỹ), thông tin NĐT (tên, CCCD, loại NĐT STOCKHOLDER_TYPE FK), số lượng CCQ nắm giữ → quan hệ NĐT–quỹ với trạng thái. (3) Chọn `Investment Fund`. Table Type điều chỉnh theo review: `Fundamental` (thay cho `Relative`) — grain NĐT-per-quỹ có lifecycle riêng (SCD4A), tương tự cách BRANCHS/TL_PROFILES vẫn Fundamental dù có FK đến entity Tier trước. |
| Arrangement | [Arrangement] Investment Account | Investment Account | INVES_ACC | Update | Danh sách tài khoản của nhà đầu tư ủy thác | Discretionary Investment Account | Relative | (1) Term candidate: `Investment Account` — tài khoản được mở cho NĐT ủy thác. (2) Cấu trúc trường: INVES_ACC có FK đến INVES (NĐT ủy thác), mã tài khoản, ngày mở, trạng thái → entity tài khoản phụ thuộc NĐT ủy thác (Tier 2). (3) Chọn `Investment Account`. |

---

## 6b. Diagram Source (Mermaid)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef outscope fill:#fef9c3,stroke:#ca8a04,color:#713f12

    STF_FG_BRCH["**STF_FG_BRCH**\nNhân sự VPĐD QLQ NN"]:::src
    REPRESENT["**REPRESENT**\nBan đại diện/HĐQT quỹ"]:::src
    MB_FUND["**MB_FUND**\nNĐT nắm giữ CCQ"]:::src
    INVES_ACC["**INVES_ACC**\nTài khoản NĐT ủy thác"]:::src

    FOR_BRCH["**FOR_BRCH** (Tier 2)"]:::outscope
    TL_PROFILES["**TL_PROFILES** (Tier 2)"]:::outscope
    FUNDS["**FUNDS** (Tier 2)"]:::outscope
    INVES["**INVES** (Tier 2)"]:::outscope

    STF_FG_BRCH -->|"FORBRCH_ID"| FOR_BRCH
    STF_FG_BRCH -->|"TL_ID (kiêm nhiệm, nullable)"| TL_PROFILES
    REPRESENT -->|"FUND_ID"| FUNDS
    REPRESENT -->|"TL_ID"| TL_PROFILES
    MB_FUND -->|"FUND_ID"| FUNDS
    INVES_ACC -->|"INVES_ID"| INVES
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
    IFIM["**Investment Fund Investor Membership**\n[Arrangement] Investment Fund\nMBFUND"]:::atomic
    DIA["**Discretionary Investment Account**\n[Arrangement] Investment Account\nINVESACC"]:::atomic

    FFMOU["**Foreign Fund Management Organization Unit** (Tier 2)"]:::outscope
    KP["**Fund Management Company Key Person** (Tier 2)"]:::outscope
    IF["**Investment Fund** (Tier 2)"]:::outscope
    DII["**Discretionary Investment Investor** (Tier 2)"]:::outscope

    FFMS -->|"Foreign Fund Management Organization Unit FK"| FFMOU
    FFMS -->|"Key Person FK (nullable)"| KP
    RBM -->|"Investment Fund FK"| IF
    RBM -->|"Key Person FK"| KP
    IFIM -->|"Investment Fund FK"| IF
    DIA -->|"Discretionary Investment Investor FK"| DII
```

---

## 6d. Danh mục & Tham chiếu

| Source Table | Mô tả | Scheme Code dự kiến | Ghi chú |
|---|---|---|---|
| MB_FUND.STOCKHOLDERTYPE_ID | Loại hình NĐT/cổ đông nắm giữ CCQ | `FMS_STOCKHOLDER_TYPE` | source_table — Đã đăng ký Tier 1; tham chiếu lại. |
| STF_FG_BRCH.JOBTYPE_ID | Loại chức vụ nhân sự VPĐD NN | `FMS_JOB_TYPE` | source_table — Đã đăng ký Tier 1; tham chiếu lại. |

---

## 6e. Bảng chờ thiết kế

Không có bảng nào trong Tier 3 chưa đủ thông tin cột.

---

## 6f. Điểm cần xác nhận

| # | Câu hỏi | Ảnh hưởng |
|---|---|---|
| T3-01 | STF_FG_BRCH.TL_ID (FK đến TL_PROFILES) nullable — nhân sự VPĐD NN có thể không phải nhân sự QLQ trong nước. Xác nhận: TL_ID là nullable OK? | **Chờ xác nhận.** Thiết kế hiện tại TL_ID nullable. |
| T3-02 | MB_FUND — 1 NĐT có thể nắm giữ CCQ của nhiều quỹ → grain là (FUND_ID, INVESTOR_ID) hay chỉ FUND_ID? Table Type đã chốt `Fundamental` theo review. | **Chờ xác nhận grain.** Tạm thiết kế grain = 1 dòng NĐT per quỹ (FUND_ID + investor_id_number). |
| T3-04 | REPRESENT — 1 nhân sự có thể là thành viên BĐD của nhiều quỹ cùng lúc. Grain = (FUND_ID, TL_ID, FR_DATE) → xác nhận. | **Chờ xác nhận.** |
