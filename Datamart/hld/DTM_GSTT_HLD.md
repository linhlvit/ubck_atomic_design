# DTM_GSTT_HLD — v4.0

**Phiên bản:** 4.0
**Ngày cập nhật:** 2026-07-27
**Thay đổi v4.0:** Thiết kế lại toàn bộ theo BA mới (`BRD/BA/BA_analyst_GSTT.csv`, thay bản `Old versions/BA_analyst_GSTT_20260727.csv`). Đổi nguyên tắc tổ chức Section 2: **1 Nhóm = 1 STT** (bám tuyệt đối theo cột STT của BA, không gộp nhiều STT vào 1 Nhóm, không tách 1 STT thành nhiều Nhóm phụ a/b/c). Áp dụng gating mới theo cột "Loại dữ liệu" (Dữ liệu tĩnh/động) — độc lập với gating theo Atomic. Dùng biến thể 5-Section (thêm Section 4 — Reuse Analysis). File được viết lại tăng dần theo từng Nhóm được duyệt — xem lịch sử bản cũ tại git history nếu cần đối chiếu.
**Phạm vi:** Đang thiết kế — cập nhật dần theo tiến độ duyệt từng Nhóm (1 → 49).

---

## Section 1 — Data Lineage

##### Cụm 1: Thông tin danh mục chứng khoán (Fact Stock Portfolio Snapshot)

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        S1A["MDDS.JAD_STOCKINFOR"]
        S1C["ORDERTRADE.TRADE_BOOK_HOSE"]
        S1D["ORDERTRADE.TRADE_BOOK_HNX"]
        S1E["IDS.COMPANY_PROFILES"]
        S1F["ECAT.BUSINESS_LINE_LEVEL_1"]
        S1G["ECAT.BUSINESS_LINE_LEVEL_2"]
    end
    subgraph SIL["Atomic"]
        A1A["Security Trading Snapshot"]
        A1C["Securities Trade"]
        A1D["Public Company"]
        A1E["Classification Business Line"]
    end
    subgraph GOLD["Datamart"]
        fct_stock_portfolio_snpst["Fact Stock Portfolio Snapshot"]
    end
    S1A --> A1A
    S1C --> A1C
    S1D --> A1C
    S1E --> A1D
    S1F --> A1E
    S1G --> A1E
    A1A --> fct_stock_portfolio_snpst
    A1C --> fct_stock_portfolio_snpst
    A1D --> fct_stock_portfolio_snpst
    A1E --> fct_stock_portfolio_snpst
```

> **Ghi chú nguồn Ngành:** BA viết SQL tham khảo JOIN trực tiếp `IDS.CATEGORIES`, nhưng Atomic thật quy định `IDS.CATEGORIES` chỉ là bảng join nội bộ — không tự sinh entity (quyết định 2026-07-23). Đường JOIN chuẩn: `Public Company.Business Line Level 1 Id` → `Classification Business Line.Classification Business Line Id`. `public_company_dim` (Datamart, dùng chung GSDC/QLCB/NDTNN) đã có sẵn cột đệm `Classification Business Line Name` — logic JOIN của cột này vừa được sửa lại từ so khớp theo Code sang so khớp theo Id (2026-07-27, theo khuyến nghị Atomic designer — Id = hash theo source_system nên tránh sai khi `cl_business_line` nhận thêm nguồn ngoài ECAT). GSTT reuse nguyên trạng `public_company_dim`, không tạo Dimension riêng cho Ngành.
> **Ghi chú measure tổng hợp:** `Securities Trade` (Fact Append, grain = 1 lệnh khớp) thô hơn grain Fact (1 mã CK/ngày) — Tổng KL/GT, Tổng KL/GT thỏa thuận, KLNN ròng đều phải `SUM(...) GROUP BY Security Symbol Code, Trade Date` trước khi đặt lên Fact (Bước 4B — grain-matching).

---

##### Cụm 1b: Thành phần rổ chỉ số (Fact Index Constituent Snapshot)

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        S1bA["MDDS.JAD_CSIDXINFOR"]
    end
    subgraph SIL["Atomic"]
        A1bA["Index Constituent Snapshot"]
    end
    subgraph GOLD["Datamart"]
        indx_basket_dim["Index Basket Dimension"]
        fct_indx_cnst_snpst["Fact Index Constituent Snapshot"]
        indx_basket_dim --> fct_indx_cnst_snpst
    end
    S1bA --> A1bA
    A1bA --> fct_indx_cnst_snpst
    A1bA --> indx_basket_dim
```

> **Sửa lại thiết kế (2026-07-27, phát hiện qua review Star Schema Nhóm 1):** Ban đầu đặt `Index_Code` trực tiếp làm cột scalar trên `Fact_Stock_Portfolio_Snapshot` — **sai theo lý thuyết Star Schema**, vì `Index Constituent Snapshot` (JAD_CSIDXINFOR) là quan hệ **N:N** giữa 1 mã CK và 1 rổ chỉ số tại 1 ngày (Atomic ghi rõ grain = 1 cặp (index_code, symbol, trading_date), 1 mã CK có thể thuộc nhiều rổ cùng lúc — VD VCB vừa thuộc VN30 vừa thuộc VNAllShare). Không thể nén thành 1 giá trị trên Fact có grain "1 mã CK/ngày" mà không mất dữ liệu.
>
> **Sửa lần 2 (cùng ngày, sau khi user chỉ ra sai tiếp):** Lần sửa đầu tiên nhầm dùng `Market Index Dimension` (đã có trong `datamart_model.yaml`, sở hữu QLKD) làm Dimension đích cho `Index Code` — **sai**, vì `Market Index Dimension` mô tả **giá trị điểm số chỉ số** (nguồn `Market Index Snapshot` ← MDDS.JAD_MARKETINFOR, BK = Market Id + Market Code) — một khái niệm nghiệp vụ hoàn toàn khác với "danh mục các rổ chỉ số" mà `Index Constituent Snapshot.Index Code` cần tham chiếu. 2 bảng nguồn khác nhau (JAD_MARKETINFOR vs JAD_CSIDXINFOR), 2 khái niệm nghiệp vụ khác nhau (điểm số vs danh mục rổ) — comment Atomic "denormalized join key" chỉ nói về khả năng join kỹ thuật (2 giá trị string trùng), không có nghĩa chung 1 Dimension.
>
> **Thiết kế đúng:** Atomic chưa có entity danh mục "rổ chỉ số" độc lập — `Index Code` trên `Index Constituent Snapshot` chỉ là text field denormalized (không có FK surrogate ở Atomic, theo đúng D-02 pattern). Tạo `Index Basket Dimension` mới ở Datamart layer, derive từ giá trị distinct `Index Code` của chính `Index Constituent Snapshot` — tối giản, chỉ gồm `Index Code` (BK) + `Source System Code`. Không liên quan `Market Index Dimension`. Bridge Fact riêng `Fact Index Constituent Snapshot` (đúng grain Atomic entity) nối `Security Trading Snapshot Dimension` ↔ `Index Basket Dimension` ↔ `Calendar Date Dimension`.

---

## Section 2 — Tổng quan báo cáo

### Tab Dashboard thông tin về danh mục chứng khoán

#### Nhóm 1 - Bảng số liệu

> **Phân loại:** Phân tích
> **Atomic:** `Security Trading Snapshot` ← MDDS.JAD_STOCKINFOR — **READY** (Nguồn 2, approved) / `Securities Trade` ← ORDERTRADE.TRADE_BOOK_HOSE, TRADE_BOOK_HNX — **READY** (Nguồn 2, approved) / `Public Company` ← IDS.COMPANY_PROFILES — **READY** (Nguồn 1, approved) / `Classification Business Line` ← ECAT.BUSINESS_LINE_LEVEL_1, BUSINESS_LINE_LEVEL_2 — **READY** (Nguồn 1, approved) / `Index Constituent Snapshot` ← MDDS.JAD_CSIDXINFOR — **READY** (Nguồn 2, approved) — dùng cho KPI Chỉ số qua bridge Fact riêng, xem Cụm 1b Section 1

**Mockup:**

| Mã CK | Ngành | Sàn | Chỉ số | Loại phái sinh | Ngày đáo hạn | Giá TC | Giá ĐC | Thay đổi | % TĐ | Tổng KL | Tổng GT | Tổng KL PS | Tổng GT PS | Tổng KL TT | Tổng GT TT | KLNN ròng |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| VCB | Ngân hàng | HOSE | VN30 | — | — | 82.00 | 82.50 | +0.50 | +0.61% | 548 Tr | 22.1 Tỷ | 0 | 0 | 12 Tr | 1.0 Tỷ | +4 Tr |

**Source:** `Fact Stock Portfolio Snapshot` → `Security Trading Snapshot Dimension`, `Public Company Dimension`, `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSTT_1 | Mã CK | — | Chiều | `Security Trading Snapshot Dimension.Symbol` | Filter: `Stock Type Code NOT IN ('B','1','BO','D')` (loại trái phiếu) | READY |
| K_GSTT_2 | Ngành | — | Chiều | `Public Company Dimension.Business Line Level 1 Code`, `Classification Business Line Name` | Reuse nguyên trạng `public_company_dim` — cột đệm sẵn tên ngành đã sửa JOIN theo Id (xem Section 1) | READY |
| K_GSTT_3 | Sàn | — | Chiều | `Security Trading Snapshot Dimension.Floor Code` | Scheme MDDS_FLOOR_CODE: 10-HOSE, 02-HNX, 04-UPCOM, 03-FDS | READY |
| K_GSTT_4 | Chỉ số | — | Chiều | `Index Basket Dimension.Index Code` | Filter/JOIN qua `Fact Index Constituent Snapshot` (bridge, quan hệ N:N mã CK ↔ rổ chỉ số theo ngày) — không phải cột scalar trên `Fact Stock Portfolio Snapshot`, xem Cụm 1b Section 1 | READY |
| K_GSTT_5 | Loại phái sinh | — | Chiều | `Security Trading Snapshot Dimension.Stock Type Code`, `Underlying Symbol` | Chỉ có giá trị khi Floor Code = '03' | READY |
| K_GSTT_6 | Phương thức khớp lệnh (thỏa thuận) | — | Chiều | `Securities Trade.Board Type Code IN ('T1','T2','T3','T4','T6')` | Slicer phân biệt Khớp lệnh / Thỏa thuận | READY |
| K_GSTT_7 | Ngày | — | Chiều | `Calendar Date Dimension.Calendar Date` | Tham số lọc theo ngày giao dịch | READY |
| K_GSTT_8 | Ngày đáo hạn phái sinh | Ngày | Cơ sở | `Security Trading Snapshot Dimension.Maturity Date` | Chỉ có giá trị khi Floor Code = '03' | READY |
| K_GSTT_9 | Giá tham chiếu | VNĐ | Cơ sở | `Security Trading Snapshot Dimension.Reference Price` | — | READY |
| K_GSTT_10 | Giá đóng cửa | VNĐ | Cơ sở | `Security Trading Snapshot Dimension.Close Price` | — | READY |
| K_GSTT_11 | Thay đổi (+/-) | VNĐ | Cơ sở | `Security Trading Snapshot Dimension.Price Change` | = Giá đóng cửa − Giá TC | READY |
| K_GSTT_12 | % thay đổi | % | Phái sinh | `Price Change / Reference Price × 100` | Computed tại query layer | READY |
| K_GSTT_13 | Tổng KL | Cổ phiếu | Phái sinh | `SUM(Securities Trade.Execution Volume) GROUP BY Symbol, Trade Date` | Pre-aggregate — grain measure thô hơn grain Fact (Bước 4B) | READY |
| K_GSTT_14 | Tổng GT | VNĐ | Phái sinh | `SUM(Securities Trade.Execution Value) GROUP BY Symbol, Trade Date` | Pre-aggregate | READY |
| K_GSTT_15 | Tổng KL theo loại phái sinh | Hợp đồng | Phái sinh | `SUM(Securities Trade.Execution Volume WHERE Market Id Code = 'DVX') GROUP BY Symbol, Trade Date` | Pre-aggregate | READY |
| K_GSTT_16 | Tổng GT theo loại phái sinh | VNĐ | Phái sinh | `SUM(Securities Trade.Execution Value WHERE Market Id Code = 'DVX') GROUP BY Symbol, Trade Date` | Pre-aggregate | READY |
| K_GSTT_17 | Tổng KL thỏa thuận | Cổ phiếu | Phái sinh | `SUM(Securities Trade.Execution Volume WHERE Board Type Code IN ('T1','T2','T3','T4','T6')) GROUP BY Symbol, Trade Date` | Pre-aggregate | READY |
| K_GSTT_18 | Tổng GT thỏa thuận | VNĐ | Phái sinh | `SUM(Securities Trade.Execution Value WHERE Board Type Code IN ('T1','T2','T3','T4','T6')) GROUP BY Symbol, Trade Date` | Pre-aggregate | READY |
| K_GSTT_19 | KLNN ròng | Cổ phiếu | Phái sinh | `SUM(Buy Foreign Investor Type Code IN ('10','20') → Execution Volume) − SUM(Sell Foreign Investor Type Code IN ('10','20') → Execution Volume) GROUP BY Symbol, Trade Date` | Pre-aggregate | READY |

**Star Schema:**

```mermaid
erDiagram
    Security_Trading_Snapshot_Dimension {
        string Security_Trading_Snapshot_Dimension_Id PK
        string Symbol
        string Security_Full_Name
        string Floor_Code
        string Stock_Type_Code
        string Underlying_Symbol
        string ISIN_Code
        string Issuer_Name
        int Listed_Share_Count
        date First_Trading_Date
        date Last_Trading_Date
        date Issue_Date
        date Maturity_Date
        string Fund_Type_Code
        string Covered_Warrant_Type_Code
        decimal Exercise_Price
        string Exercise_Ratio
        string Exercise_Style_Code
        string Put_Or_Call_Code
        string Contract_Multiplier
        string Maturity_Month_Year
        decimal Coupon_Rate
        decimal Yield
        decimal Reference_Price
        decimal Close_Price
        decimal Price_Change
        string Source_System_Code
    }
    Public_Company_Dimension {
        string Public_Company_Dimension_Id PK
        string Equity_Ticker_Symbol
        string Business_Line_Level_1_Code
        string Classification_Business_Line_Name
        string Source_System_Code
    }
    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        string Source_System_Code
    }
    Fact_Stock_Portfolio_Snapshot {
        string Security_Trading_Snapshot_Dimension_Id FK
        string Public_Company_Dimension_Id FK
        string Calendar_Date_Dimension_Id FK
        int Total_Volume
        decimal Total_Value
        int Total_Derivative_Volume
        decimal Total_Derivative_Value
        int Total_Negotiated_Volume
        decimal Total_Negotiated_Value
        int Foreign_Net_Volume
    }
    Index_Basket_Dimension {
        string Index_Basket_Dimension_Id PK
        string Index_Code
        string Source_System_Code
    }
    Fact_Index_Constituent_Snapshot {
        string Security_Trading_Snapshot_Dimension_Id FK
        string Index_Basket_Dimension_Id FK
        string Calendar_Date_Dimension_Id FK
    }
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Stock_Portfolio_Snapshot : " "
    Public_Company_Dimension ||--o{ Fact_Stock_Portfolio_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Stock_Portfolio_Snapshot : " "
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Index_Constituent_Snapshot : " "
    Index_Basket_Dimension ||--o{ Fact_Index_Constituent_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Index_Constituent_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    F1["Fact Stock Portfolio Snapshot"] --> RPT1["Bảng số liệu Cổ phiếu"]
    D1["Security Trading Snapshot Dimension"] --> RPT1
    D2["Public Company Dimension"] --> RPT1
    D3["Calendar Date Dimension"] --> RPT1
    F1b["Fact Index Constituent Snapshot"] --> RPT1
    D4["Index Basket Dimension"] --> RPT1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fact Stock Portfolio Snapshot | 1 row / mã CK / ngày giao dịch |
| Fact Index Constituent Snapshot | 1 row / mã CK / rổ chỉ số / ngày (bridge, quan hệ N:N) |
| Index Basket Dimension | 1 row / rổ chỉ số (SCD4A) |
| Security Trading Snapshot Dimension | 1 row / mã CK (SCD4A) |
| Public Company Dimension | 1 row / mã CK (SCD4A) |
| Calendar Date Dimension | 1 row / ngày |

> **Coverage rule (Bước 1a skill):** `Security Trading Snapshot Dimension` kéo dư thừa toàn bộ attribute hồ sơ mô tả chứng khoán từ `security_trading_snapshot` (Symbol, Security Full Name, Floor Code, Stock Type Code, Underlying Symbol, ISIN Code, Issuer Name, Listed Share Count, First/Last Trading Date, Issue Date, Maturity Date, Fund Type Code, Covered Warrant Type/Exercise Price/Ratio/Style Code, Put Or Call Code, Contract Multiplier, Maturity Month Year, Coupon Rate, Yield) — kể cả cột chưa cần cho Nhóm 1, để tránh phải bổ sung nhiều lần khi các Nhóm sau (Nhóm 2 — Trái phiếu, biểu đồ kỹ thuật, phái sinh...) cần đến. Không kéo các cột giá theo phiên/ngày (Open/High/Low/Bid/Offer/Volume...) vì đây là Fact Snapshot — grain đúng của các cột đó là Fact, không phải Dimension; `Reference Price`/`Close Price`/`Price Change` giữ lại trên Dimension vì được dùng làm giá "hiện hành" hiển thị cùng hồ sơ mô tả (theo mockup BA), không phải để tính toán lịch sử.

---

#### Nhóm 2 - Bảng số liệu của trái phiếu

> **Phân loại:** Phân tích
> **Atomic:** `Security Trading Snapshot` ← MDDS.JAD_STOCKINFOR — **READY** (Nguồn 2, approved) / `Securities Trade` ← ORDERTRADE.TRADE_BOOK_HOSE, TRADE_BOOK_HNX — **READY** (Nguồn 2, approved)
>
> **Ghi chú nguồn (khác bản HLD cũ):** BA xác nhận trái phiếu niêm yết dùng **cùng** `MDDS.JAD_STOCKINFOR` với cổ phiếu (filter `Stock Type Code = '1'`), không phải entity riêng `MDDS.CorpBondInfor` như thiết kế trước — Note BA: "đổi lại do CorpBondInfor là trái phiếu riêng lẻ?". Do đó reuse toàn bộ `Fact Stock Portfolio Snapshot` + `Security Trading Snapshot Dimension` đã thiết kế ở Nhóm 1, không tạo Fact/Dimension riêng cho trái phiếu.

**Mockup:**

| Mã TP | Ngày | Giá TC | Giá ĐC | Giá mở cửa | Thay đổi | % TĐ | Ngày đáo hạn | KLGD | GTGD | YTM bình quân | Lãi suất |
|---|---|---|---|---|---|---|---|---|---|---|---|
| TCH2226 | 27/07/2026 | 102.5 | 103.0 | 102.8 | +0.5 | +0.49% | 15/03/2028 | 1.200 | 12.4 Tỷ | 6.8% | 7.2% |

**Source:** `Fact Stock Portfolio Snapshot` → `Security Trading Snapshot Dimension`, `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSTT_20 | Mã trái phiếu | — | Chiều | `Security Trading Snapshot Dimension.Symbol` | Filter: `Stock Type Code = '1' AND Floor Code IN ('04','10','03','02')` | READY |
| K_GSTT_7 | Ngày | — | Chiều | `Calendar Date Dimension.Calendar Date` | Reuse từ Nhóm 1 | READY |
| K_GSTT_9 | Giá tham chiếu | VNĐ | Cơ sở | `Security Trading Snapshot Dimension.Reference Price` | Reuse từ Nhóm 1 | READY |
| K_GSTT_10 | Giá đóng cửa | VNĐ | Cơ sở | `Security Trading Snapshot Dimension.Close Price` | Reuse từ Nhóm 1 | READY |
| K_GSTT_21 | Giá mở cửa | VNĐ | Cơ sở | `Security Trading Snapshot Dimension.Open Price` | — | READY |
| K_GSTT_11 | Thay đổi (+/-) | VNĐ | Cơ sở | `Security Trading Snapshot Dimension.Price Change` | Reuse từ Nhóm 1 | READY |
| K_GSTT_12 | % thay đổi | % | Phái sinh | `Price Change / Reference Price × 100` | Reuse từ Nhóm 1 | READY |
| K_GSTT_22 | Ngày đáo hạn của trái phiếu | Ngày | Cơ sở | `Security Trading Snapshot Dimension.Maturity Date` | — | READY |
| K_GSTT_23 | KLGD | Trái phiếu | Phái sinh | `SUM(Securities Trade.Execution Volume WHERE Market Id Code IN ('BDO','HCX') AND Board Type Code IN ('G1','G2','G3','T1','T2','T3')) GROUP BY Symbol, Trade Date` | Pre-aggregate — không có G4/T4/T6 vì TP không có lô lẻ | READY |
| K_GSTT_24 | GTGD | VNĐ | Phái sinh | `SUM(Securities Trade.Execution Value WHERE Market Id Code IN ('BDO','HCX') AND Board Type Code IN ('G1','G2','G3','T1','T2','T3')) GROUP BY Symbol, Trade Date` | Pre-aggregate | READY |
| K_GSTT_25 | YTM bình quân | % | Cơ sở | `Security Trading Snapshot Dimension.Yield` | — | READY |
| K_GSTT_26 | Lãi suất | % | Cơ sở | `Security Trading Snapshot Dimension.Coupon Rate` | — | READY |

**Star Schema:** *(dùng chung `Fact Stock Portfolio Snapshot` + `Security Trading Snapshot Dimension` + `Calendar Date Dimension` đã vẽ ở Nhóm 1 — xem Nhóm 1 để có schema đầy đủ đã bổ sung `Coupon_Rate`, `Yield`)*

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    F1["Fact Stock Portfolio Snapshot"] --> RPT2["Bảng số liệu Trái phiếu"]
    D1["Security Trading Snapshot Dimension"] --> RPT2
    D3["Calendar Date Dimension"] --> RPT2
```

**Bảng grain:** *(giống Nhóm 1 — cùng Fact/Dimension, không grain riêng)*

---

## Section 3 — Mô hình tổng thể

### 3.1 graph TB

```mermaid
graph TB
    classDef dim fill:#E6F1FB,stroke:#185FA5,color:#0C447C
    classDef fact fill:#FAECE7,stroke:#993C1D,color:#4A1B0C
    classDef oper fill:#E8F5E9,stroke:#2E7D32,color:#1B5E20

    ScrTdgSnpstDim["Security Trading Snapshot Dimension"]:::dim
    PblcCoDim["Public Company Dimension"]:::dim
    CdrDtDim["Calendar Date Dimension"]:::dim
    IndxBasketDim["Index Basket Dimension"]:::dim
    FctStockPortfolioSnpst["Fact Stock Portfolio Snapshot"]:::fact
    FctIndxCnstSnpst["Fact Index Constituent Snapshot"]:::fact

    ScrTdgSnpstDim --> FctStockPortfolioSnpst
    PblcCoDim --> FctStockPortfolioSnpst
    CdrDtDim --> FctStockPortfolioSnpst
    ScrTdgSnpstDim --> FctIndxCnstSnpst
    IndxBasketDim --> FctIndxCnstSnpst
    CdrDtDim --> FctIndxCnstSnpst
```

### 3.2 Bảng Phân tích (chỉ liệt kê Fact)

| Bảng | Pattern | Grain | KPI | Trạng thái |
|---|---|---|---|---|
| Fact Stock Portfolio Snapshot | Periodic Snapshot | 1 row / mã CK / ngày giao dịch | K_GSTT_1–19 (Nhóm 1), K_GSTT_20–26 (Nhóm 2, reuse Nhóm 1) | READY |
| Fact Index Constituent Snapshot | Periodic Snapshot (bridge N:N) | 1 row / mã CK / rổ chỉ số / ngày | K_GSTT_4 (Nhóm 1) | READY |

### 3.3 Bảng Tác nghiệp

Không có.

| Bảng | Grain | KPI | Trạng thái |
|---|---|---|---|

### 3.4 Bảng Dimension (chỉ liệt kê Dimension)

*Tất cả Dimension áp dụng SCD Type 4A (trừ khi ghi chú khác).*

| Dimension | Loại | Mô tả | Scheme | Trạng thái |
|---|---|---|---|---|
| Security Trading Snapshot Dimension | Reference per module | 1 row / mã CK — hồ sơ mô tả chứng khoán (tên, ISIN, tổ chức phát hành, ngày niêm yết, đặc điểm CW/OP/HĐTL/TP) + giá tham chiếu/đóng cửa gần nhất | MDDS_FLOOR_CODE | READY |
| Public Company Dimension | Conformed (dùng chung GSDC/QLCB/NDTNN) | 1 row / mã CK — thông tin công ty đại chúng, ngành | — | READY |
| Calendar Date Dimension | Conformed (dùng chung toàn hệ thống) | 1 row / ngày | — | READY |
| Index Basket Dimension | Reference per module | 1 row / rổ chỉ số — derive từ giá trị distinct Index Code của `index_constituent_snapshot` (Atomic chưa có entity danh mục rổ chỉ số độc lập) | — | READY |

---

## Section 4 — Reuse Analysis

| Datamart Entity | datamart_table | reuse_status | Ghi chú |
|---|---|---|---|
| Fact Stock Portfolio Snapshot | fct_stock_portfolio_snpst | new | Chưa có trong master — Nhóm đầu tiên của module GSTT |
| Security Trading Snapshot Dimension | security_trading_snpst_dim | new | Chưa có trong master. Schema đã áp dụng coverage rule (Bước 1a) ngay từ Nhóm 1 — bao gồm sẵn cột phục vụ Nhóm 2 (Coupon Rate, Yield) và các Nhóm biểu đồ/phái sinh sau này (ISIN, Issuer, CW/OP/HĐTL...) |
| Public Company Dimension | public_company_dim | reuse | Đã có trong master (module gốc GSDC, dùng chung QLCB/NDTNN) — đủ cột (Code + Name ngành đệm sẵn) cho nhu cầu GSTT, không cần thêm cột. Đã sửa logic JOIN nội bộ của cột `Classification Business Line Name` sang so khớp qua Id (2026-07-27) — không đổi cấu trúc schema |
| Calendar Date Dimension | cdr_dt_dim | reuse | Conformed Dimension — luôn reuse toàn hệ thống |
| Fact Index Constituent Snapshot | fct_indx_cnst_snpst | new | Chưa có trong master. Bridge Fact tách riêng khỏi `Fact Stock Portfolio Snapshot` sau khi phát hiện lỗi thiết kế (Index Code là quan hệ N:N, không phải cột scalar) — xem ghi chú Section 1 Cụm 1b |
| Index Basket Dimension | index_basket_dim | new | Chưa có trong master. KHÔNG nhầm với `Market Index Dimension` (đã có, sở hữu QLKD, nguồn khác — JAD_MARKETINFOR, khái niệm giá trị điểm số chỉ số) — 2 Dimension độc lập, khác nguồn, khác ý nghĩa nghiệp vụ. Derive từ giá trị distinct `Index Code` của `index_constituent_snapshot` vì Atomic chưa có entity danh mục rổ chỉ số riêng |

---

## Section 5 — Vấn đề mở

*(Chưa phát sinh vấn đề mở nào — sẽ cập nhật khi có Nhóm cần ghi nhận Open Issue)*
