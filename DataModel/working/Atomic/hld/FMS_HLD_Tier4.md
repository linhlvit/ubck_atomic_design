# FMS — HLD Tier 4: Phụ thuộc Tier 3

> **Phụ thuộc Tier 1:** Fund Management Company
> **Phụ thuộc Tier 2:** Investment Fund
> **Phụ thuộc Tier 3:** Investment Fund Investor Membership
>
> **Thiết kế theo:** [FMS_HLD_Overview.md](FMS_HLD_Overview.md)

---

## 6a. Bảng tổng quan BCV Concept

| BCV Core Object | BCV Concept | Category | Source Table | Source Table Change Mode | Mô tả bảng nguồn | Atomic Entity | Table Type | BCV Term |
|---|---|---|---|---|---|---|---|---|
| Transaction | [Event] Transaction | Transaction | MBCHANGE | Append | Lịch sử thay đổi vốn góp của nhà đầu tư trong quỹ | Investment Fund Investor Capital Change Log | Fact Append | (1) Term candidate: `Transaction` — BCV mô tả sự kiện tài chính thực tế phát sinh (thay đổi vốn góp). (2) Cấu trúc trường: MBCHANGE có FK đến MBFUND (NĐT trong quỹ), số tiền thay đổi, loại thay đổi (góp thêm/rút bớt), ngày phát sinh → append theo ngày, mỗi dòng = 1 sự kiện thay đổi vốn. (3) Chọn `Transaction` → Fact Append. |
| Transaction | [Event] Transaction | Transaction | TRANSFERMBF | Append | Giao dịch mua/bán chứng chỉ quỹ | Investment Fund Certificate Transfer | Fact Append | (1) Term candidate: `Transaction` — BCV mô tả giao dịch chuyển nhượng CCQ. (2) Cấu trúc trường: TRANSFERMBF có FK đến FUNDS (quỹ), FK đến MBFUND (NĐT), loại giao dịch, số lượng CCQ, ngày giao dịch, giá trị giao dịch → mỗi dòng = 1 giao dịch CCQ, insert-only. (3) Chọn `Transaction` → Fact Append. |
| Transaction | [Event] Transaction | Transaction | TRSFERINDER | Append | Giao dịch chuyển nhượng cổ phần nội bộ công ty QLQ | Fund Management Company Share Transfer | Fact Append | (1) Term candidate: `Transaction` — giao dịch chuyển nhượng cổ phần. (2) Cấu trúc trường: TRSFERINDER có FK đến SECURITIES (CTQLQ), ngày giao dịch, số lượng, giá trị → mỗi dòng = 1 giao dịch chuyển nhượng cổ phần, insert-only. Lưu ý BRD note: mất FK InFrmId/InToId (INSIDER bị bỏ). (3) Chọn `Transaction` → Fact Append. |

---

## 6b. Diagram Source (Mermaid)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef outscope fill:#fef9c3,stroke:#ca8a04,color:#713f12

    MBCHANGE["**MBCHANGE**\nThay đổi vốn góp NĐT quỹ"]:::src
    TRANSFERMBF["**TRANSFERMBF**\nGiao dịch mua/bán CCQ"]:::src
    TRSFERINDER["**TRSFERINDER**\nChuyển nhượng cổ phần QLQ"]:::src

    MBFUND["**MBFUND** (Tier 3)"]:::outscope
    FUNDS["**FUNDS** (Tier 2)"]:::outscope
    SECURITIES["**SECURITIES** (Tier 1)"]:::outscope

    MBCHANGE -->|"MB_FUND_ID"| MBFUND
    TRANSFERMBF -->|"FUND_ID"| FUNDS
    TRANSFERMBF -->|"MB_FUND_ID"| MBFUND
    TRSFERINDER -->|"SEC_ID"| SECURITIES
```

---

## 6c. Diagram Atomic (Mermaid)

```mermaid
graph TD
    classDef pattern fill:#e2e8f0,stroke:#64748b,color:#1e293b
    classDef outscope fill:#fef9c3,stroke:#ca8a04,color:#713f12

    IFCCL["**Investment Fund Investor Capital Change Log**\n[Event] Transaction\nMBCHANGE"]:::pattern
    IFCT["**Investment Fund Certificate Transfer**\n[Event] Transaction\nTRANSFERMBF"]:::pattern
    FMCST["**Fund Management Company Share Transfer**\n[Event] Transaction\nTRSFERINDER"]:::pattern

    IFIM["**Investment Fund Investor Membership** (Tier 3)"]:::outscope
    IF["**Investment Fund** (Tier 2)"]:::outscope
    FMC["**Fund Management Company** (Tier 1)"]:::outscope

    IFCCL -->|"Investment Fund Investor Membership FK"| IFIM
    IFCT -->|"Investment Fund FK"| IF
    IFCT -->|"Investment Fund Investor Membership FK"| IFIM
    FMCST -->|"Fund Management Company FK"| FMC
```

---

## 6d. Danh mục & Tham chiếu

| Source Table | Mô tả | Scheme Code dự kiến | Ghi chú |
|---|---|---|---|
| MBCHANGE.CHANGE_TYPE | Loại thay đổi vốn góp: góp thêm / rút bớt | `FMS_CAPITAL_CHANGE_TYPE` | etl_derived — ETL derived: SUBSCRIPTION / REDEMPTION / TRANSFER_IN / TRANSFER_OUT. |
| TRANSFERMBF.TRANSFER_TYPE | Loại giao dịch CCQ: mua / bán / chuyển nhượng | `FMS_CERTIFICATE_TRANSFER_TYPE` | etl_derived — ETL derived: BUY / SELL / TRANSFER. |

---

## 6e. Bảng chờ thiết kế

Không có bảng nào trong Tier 4 chưa đủ thông tin cột.

---

## 6f. Điểm cần xác nhận

| # | Câu hỏi | Ảnh hưởng |
|---|---|---|
| T4-01 | TRSFERINDER mất FK InFrmId/InToId (INSIDER table bị bỏ khỏi scope) — entity Share Transfer sẽ không biết bên mua và bên bán là ai. Xác nhận: có thể load dữ liệu thiếu FK này không, hay cần xem xét scope lại? | **Chờ xác nhận.** GAP đã ghi nhận trong BRD notes. Tạm thiết kế entity không có FK bên mua/bán — ghi nhận trong pending_design.yaml ở bước LLD. |
| T4-02 | TRANSFERMBF FK đến MBFUND — nếu NĐT chưa có record trong MBFUND thì giao dịch đầu tiên có thể bị orphan. Xác nhận: MBFUND luôn tồn tại trước TRANSFERMBF? | **Chờ xác nhận.** |
| T4-03 | MBCHANGE vs TRANSFERMBF — hai bảng cùng ghi về vốn góp NĐT. Xác nhận phân biệt: MBCHANGE = thay đổi vốn góp (tài chính); TRANSFERMBF = giao dịch CCQ (thị trường). Đây là 2 entity khác nhau? | **Chờ xác nhận.** Tạm thiết kế 2 entity riêng. |
