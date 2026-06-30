# FMS HLD — Tier 4

**Source system:** FMS (Hệ thống quản lý giám sát công ty chứng khoán và quỹ đầu tư chứng khoán)
**Tier 4:** FK đến Tier 3 — các entity phụ thuộc vào Investment Fund Investor Membership (MBFUND), hoặc Investment Fund (Tier 2) + Investor Membership (Tier 3) cùng lúc. Bao gồm: lịch sử thay đổi vốn góp NĐT quỹ, giao dịch CCQ, giao dịch chuyển nhượng cổ phần QLQ.

---

## 6a. Bảng tổng quan BCV Concept

| BCV Core Object | BCV Concept | Category | Source Table | Source Table Change Mode | Mô tả bảng nguồn | Atomic Entity | table_type | BCV Term |
|---|---|---|---|---|---|---|---|---|
| Transaction | [Event] Transaction | Transaction | MBCHANGE | Append | Lịch sử thay đổi vốn góp của nhà đầu tư trong quỹ | Investment Fund Investor Capital Change Log | Fact Append | (1) Term candidate: `Transaction` — BCV mô tả sự kiện tài chính thực tế phát sinh (thay đổi vốn góp). (2) Cấu trúc trường: MBCHANGE có FK đến MBFUND (NĐT trong quỹ), số tiền thay đổi, loại thay đổi (góp thêm/rút bớt), ngày phát sinh → append theo ngày, mỗi dòng = 1 sự kiện thay đổi vốn. (3) Chọn `Transaction` → Fact Append. |
| Transaction | [Event] Transaction | Transaction | TRANSFERMBF | Append | Giao dịch mua/bán chứng chỉ quỹ | Investment Fund Certificate Transfer | Fact Append | (1) Term candidate: `Transaction` — BCV mô tả giao dịch chuyển nhượng CCQ. (2) Cấu trúc trường: TRANSFERMBF có FK đến FUNDS (quỹ), FK đến MBFUND (NĐT), loại giao dịch, số lượng CCQ, ngày giao dịch, giá trị giao dịch → mỗi dòng = 1 giao dịch CCQ, insert-only. (3) Chọn `Transaction` → Fact Append. |
| Transaction | [Event] Transaction | Transaction | TRSFERINDER | Append | Giao dịch chuyển nhượng cổ phần nội bộ công ty QLQ | Fund Management Company Share Transfer | Fact Append | (1) Term candidate: `Transaction` — giao dịch chuyển nhượng cổ phần. (2) Cấu trúc trường: TRSFERINDER có FK đến SECURITIES (CTQLQ), ngày giao dịch, số lượng, giá trị → mỗi dòng = 1 giao dịch chuyển nhượng cổ phần, insert-only. Lưu ý BRD note: mất FK InFrmId/InToId (INSIDER bị bỏ). (3) Chọn `Transaction` → Fact Append. |

---

## 6b. Diagram Source (Mermaid)

```mermaid
erDiagram
    MBFUND {
        raw ID PK
        raw FUND_ID FK
        nvarchar INVESTOR_NAME
    }

    FUNDS {
        raw ID PK
        nvarchar ITEM_NAME
    }

    SECURITIES {
        raw ID PK
        nvarchar ITEM_NAME
    }

    MBCHANGE {
        raw ID PK
        raw MB_FUND_ID FK
        number AMOUNT
        nvarchar CHANGE_TYPE
        date CHANGE_DATE
    }

    TRANSFERMBF {
        raw ID PK
        raw FUND_ID FK
        raw MB_FUND_ID FK
        nvarchar TRANSFER_TYPE
        number QUANTITY
        number VALUE
        date TRANSFER_DATE
    }

    TRSFERINDER {
        raw ID PK
        raw SEC_ID FK
        number QUANTITY
        number VALUE
        date TRANSFER_DATE
    }

    MBCHANGE }o--|| MBFUND : "MB_FUND_ID"
    TRANSFERMBF }o--|| FUNDS : "FUND_ID"
    TRANSFERMBF }o--|| MBFUND : "MB_FUND_ID"
    TRSFERINDER }o--|| SECURITIES : "SEC_ID"
```

---

## 6c. Diagram Atomic (Mermaid)

```mermaid
erDiagram
    Investment_Fund_Investor_Membership {
        bigint ds_investment_fund_investor_membership_id PK
        string investor_id_number
    }

    Investment_Fund {
        bigint ds_investment_fund_id PK
        string investment_fund_code
    }

    Fund_Management_Company {
        bigint ds_fund_management_company_id PK
        string fund_management_company_code
    }

    Investment_Fund_Investor_Capital_Change_Log {
        bigint ds_investment_fund_investor_capital_change_log_id PK
        bigint investment_fund_investor_membership_id FK
        string investment_fund_investor_membership_code
        string capital_change_type_code
        number change_amount
        date change_date
    }

    Investment_Fund_Certificate_Transfer {
        bigint ds_investment_fund_certificate_transfer_id PK
        bigint investment_fund_id FK
        string investment_fund_code
        bigint investment_fund_investor_membership_id FK
        string transfer_type_code
        number certificate_quantity
        number transaction_value
        date transfer_date
    }

    Fund_Management_Company_Share_Transfer {
        bigint ds_fund_management_company_share_transfer_id PK
        bigint fund_management_company_id FK
        string fund_management_company_code
        number share_quantity
        number transaction_value
        date transfer_date
    }

    Investment_Fund_Investor_Capital_Change_Log }o--|| Investment_Fund_Investor_Membership : "investment_fund_investor_membership_id"
    Investment_Fund_Certificate_Transfer }o--|| Investment_Fund : "investment_fund_id"
    Investment_Fund_Certificate_Transfer }o--|| Investment_Fund_Investor_Membership : "investment_fund_investor_membership_id"
    Fund_Management_Company_Share_Transfer }o--|| Fund_Management_Company : "fund_management_company_id"
```

---

## 6d. Mục Danh mục & Tham chiếu (Reference Data)

| Source Field / Bảng | Mô tả | Scheme Code | source_type | Ghi chú |
|---|---|---|---|---|
| MBCHANGE.CHANGE_TYPE | Loại thay đổi vốn góp: góp thêm / rút bớt | `FMS_CAPITAL_CHANGE_TYPE` | etl_derived | ETL derived: SUBSCRIPTION / REDEMPTION / TRANSFER_IN / TRANSFER_OUT |
| TRANSFERMBF.TRANSFER_TYPE | Loại giao dịch CCQ: mua / bán / chuyển nhượng | `FMS_CERTIFICATE_TRANSFER_TYPE` | etl_derived | ETL derived: BUY / SELL / TRANSFER |

---

## 6e. Bảng chờ thiết kế

*(Không có)*

---

## 6f. Điểm cần xác nhận

| # | Câu hỏi | Kết quả |
|---|---|---|
| T4-01 | TRSFERINDER mất FK InFrmId/InToId (INSIDER table bị bỏ khỏi scope) — entity Share Transfer sẽ không biết bên mua và bên bán là ai. Xác nhận: có thể load dữ liệu thiếu FK này không, hay cần xem xét scope lại? | **Chờ xác nhận.** GAP đã ghi nhận trong BRD notes. Tạm thiết kế entity không có FK bên mua/bán — ghi nhận trong pending_design.yaml ở bước LLD. |
| T4-02 | TRANSFERMBF FK đến MBFUND — nếu NĐT chưa có record trong MBFUND thì giao dịch đầu tiên có thể bị orphan. Xác nhận: MBFUND luôn tồn tại trước TRANSFERMBF? | **Chờ xác nhận.** |
| T4-03 | MBCHANGE vs TRANSFERMBF — hai bảng cùng ghi về vốn góp NĐT. Xác nhận phân biệt: MBCHANGE = thay đổi vốn góp (tài chính); TRANSFERMBF = giao dịch CCQ (thị trường). Đây là 2 entity khác nhau? | **Chờ xác nhận.** Tạm thiết kế 2 entity riêng. |
