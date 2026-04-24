# Gold Data Mart HLD — Phân hệ Quản lý Chào bán (QLCB)

**Phiên bản:** 1.0  
**Ngày:** 24/04/2026

---

## Quy ước trạng thái

| Ký hiệu | Ý nghĩa |
|---|---|
| READY | Silver đủ — thiết kế đầy đủ |
| PENDING | Silver chưa có — placeholder + lý do |

---

## Section 1 — Data Lineage: Source → Silver → Gold Mart

### Cụm 1: Chào bán phát hành (Securities Offering)

Phục vụ Tab CHÀO BÁN PHÁT HÀNH — Nhóm 1 (KPI tình hình cấp phép/huy động theo ngành), Nhóm 2 (giá trị cấp phép theo loại hình), Nhóm 3 (giá trị huy động theo loại hình × ngành). Tab HỒ SƠ ĐĂNG KÝ CHÀO BÁN không xuất hiện trong Cụm này vì toàn bộ PENDING — nguồn TTHC chưa có Silver entity.

```mermaid
flowchart LR
    subgraph SRC_IDS["Source IDS"]
        S1["IDS.company_securities_issuance"]
        S2["IDS.company_profiles"]
        S3["IDS.company_detail"]
    end

    subgraph SIL["Silver"]
        SV1["Public Company Securities Offering"]
        SV2["Public Company"]
    end

    subgraph GOLD["Gold Mart"]
        G1["Fact Securities Offering"]
        G2["Public Company Dimension"]
        G3["Industry Category Dimension"]
        G4["Calendar Date Dimension"]
    end

    S1 --> SV1
    S2 --> SV2
    S3 --> SV2

    SV1 --> G1
    SV2 --> G2
    SV2 --> G3

    G2 --> G1
    G3 --> G1
    G4 --> G1
```

---

### Cụm 2: Chi tiết đợt chào bán (Bảng tác nghiệp)

Phục vụ Tab CHÀO BÁN PHÁT HÀNH — Nhóm 4 (bảng chi tiết số lượng CK chào bán & phát hành) và Tab DATA EXPLORER — Nhóm 8–11 (tra cứu chi tiết đợt chào bán theo 4 nhóm chỉ số). Bảng tác nghiệp nhận dữ liệu trực tiếp từ Silver, không qua Dimension.

```mermaid
flowchart LR
    subgraph SRC_IDS["Source IDS"]
        S1["IDS.company_securities_issuance"]
        S2["IDS.company_profiles"]
    end

    subgraph SIL["Silver"]
        SV1["Public Company Securities Offering"]
        SV2["Public Company"]
    end

    subgraph GOLD["Gold Mart"]
        G1["Securities Offering 360 Profile"]
    end

    S1 --> SV1
    S2 --> SV2

    SV1 --> G1
    SV2 --> G1
```

---

### Cụm 3: Hồ sơ đăng ký chào bán (PENDING — TTHC)

Phục vụ Tab HỒ SƠ ĐĂNG KÝ CHÀO BÁN — Nhóm 5 (KPI Cards), Nhóm 6 (donut Tỷ lệ xử lý hồ sơ), Nhóm 7 (bảng chi tiết hồ sơ theo hình thức × năm). Toàn bộ Cụm PENDING vì nguồn TTHC chưa có Silver entity — không có TTHC_Source_Analysis.md. Sẽ thiết kế khi Silver TTHC sẵn sàng.

```mermaid
flowchart LR
    subgraph SRC_TTHC["Source TTHC (PENDING)"]
        S1["TTHC.HS_DANG_KY_CHAO_BAN (dự kiến)"]
    end

    subgraph SIL["Silver (PENDING)"]
        SV1["Securities Offering Application (chưa thiết kế)"]
    end

    subgraph GOLD["Gold Mart (PENDING)"]
        G1["Fact Securities Offering Application (dự kiến)"]
        G2["Calendar Date Dimension (reuse)"]
        G3["Public Company Dimension (reuse)"]
    end

    S1 --> SV1

    SV1 --> G1
    G2 --> G1
    G3 --> G1
```


---

### Cụm 4: Tra cứu cá nhân — Mạng lưới & Hồ sơ (IDS + SCMS + FMS)

Phục vụ Tab TRA CỨU CÁ NHÂN — Nhóm 12 (danh sách tìm kiếm), Nhóm 13 (Mạng lưới quan hệ), Nhóm 14 (Hồ sơ: Vai trò DN / Người liên quan / Tài khoản), Nhóm 17 (Lịch sử công tác). Nguồn cross-module: IDS (Stock Holder, Stock Holder Trading Account), SCMS (Securities Company Senior Personnel, Securities Company Shareholder Related Party), FMS (Investment Fund Representative Board Member).

```mermaid
flowchart LR
    subgraph SRC_IDS["Source IDS"]
        S1["IDS.stock_holders"]
        S2["IDS.account_numbers"]
        S3["IDS.company_profiles"]
        S4["IDS.holder_relationship"]
    end

    subgraph SRC_SCMS["Source SCMS"]
        S5["SCMS.CTCK_NHAN_SU_CAO_CAP"]
        S6["SCMS.CTCK_CD_MOI_QUAN_HE"]
    end

    subgraph SRC_FMS["Source FMS"]
        S7["FMS.REPRESENT"]
        S8["FMS.TLProfiles"]
    end

    subgraph SIL["Silver"]
        SV1["Stock Holder"]
        SV2["Stock Holder Trading Account"]
        SV3["Public Company"]
        SV4["Stock Holder Relationship"]
        SV5["Securities Company Senior Personnel"]
        SV6["Securities Company Shareholder Related Party"]
        SV7["Investment Fund Representative Board Member"]
        SV8["Fund Management Company Key Person"]
    end

    subgraph GOLD["Gold Mart"]
        G1["Individual 360 Profile"]
    end

    S1 --> SV1
    S2 --> SV2
    S3 --> SV3
    S4 --> SV4
    S5 --> SV5
    S6 --> SV6
    S7 --> SV7
    S8 --> SV8

    SV1 --> G1
    SV2 --> G1
    SV3 --> G1
    SV4 --> G1
    SV5 --> G1
    SV6 --> G1
    SV7 --> G1
    SV8 --> G1
```

---

### Cụm 5: Tra cứu cá nhân — CCHN (NHNCK)

Phục vụ Tab TRA CỨU CÁ NHÂN — Nhóm 15 (Lịch sử cấp CCHN).

```mermaid
flowchart LR
    subgraph SRC_NHNCK["Source NHNCK"]
        S1["NHNCK.CertificateRecords"]
        S2["NHNCK.Professionals"]
    end

    subgraph SIL["Silver"]
        SV1["Securities Practitioner License Certificate Document"]
        SV2["Securities Practitioner"]
    end

    subgraph GOLD["Gold Mart"]
        G1["Individual 360 Profile"]
    end

    S1 --> SV1
    S2 --> SV2

    SV1 --> G1
    SV2 --> G1
```

---

### Cụm 6: Tra cứu cá nhân — Kiểm toán viên (IDS)

Phục vụ Tab TRA CỨU CÁ NHÂN — Nhóm 16 (Thông tin kiểm toán viên). Nguồn IDS (`Auditor Approval` ← IDS.af_auditor_approval).

```mermaid
flowchart LR
    subgraph SRC_IDS["Source IDS"]
        S1["IDS.af_auditor_approval"]
    end

    subgraph SIL["Silver"]
        SV1["Auditor Approval"]
    end

    subgraph GOLD["Gold Mart"]
        G1["Individual 360 Profile"]
    end

    S1 --> SV1
    SV1 --> G1
```

---

### Cụm 7: Tra cứu cá nhân — Lịch sử vi phạm (Thanh Tra)

Phục vụ Tab TRA CỨU CÁ NHÂN — Nhóm 18 (Lịch sử vi phạm & xử phạt hành chính). Silver từ phân hệ Thanh Tra (cả luồng GS_ và TT_).

```mermaid
flowchart LR
    subgraph SRC_TT["Source Thanh Tra"]
        S1["GS_HO_SO"]
        S2["GS_VAN_BAN_XU_LY"]
        S3["TT_HO_SO"]
        S4["TT_KET_LUAN"]
    end

    subgraph SIL["Silver"]
        SV1["Surveillance Enforcement Case"]
        SV2["Surveillance Enforcement Decision"]
        SV3["Inspection Case"]
        SV4["Inspection Case Conclusion"]
    end

    subgraph GOLD["Gold Mart"]
        G1["Individual 360 Profile"]
    end

    S1 --> SV1
    S2 --> SV2
    S3 --> SV3
    S4 --> SV4

    SV1 --> G1
    SV2 --> G1
    SV3 --> G1
    SV4 --> G1
```


---

## Section 2 — Tổng quan báo cáo

### Tab: CHÀO BÁN PHÁT HÀNH

**Slicer chung:** Ngày (date picker), Ngành

---

#### Nhóm 1 — Tình hình thực hiện chào bán phát hành theo ngành

> Phân loại: **Phân tích**  
> Silver: `Public Company Securities Offering` ← IDS.company_securities_issuance — **READY**  
> Silver: `Public Company` ← IDS.company_profiles / IDS.company_detail — **READY**

**Mockup:**

| Ngành | Giá trị Cấp phép (tỷ đ) | Giá trị Huy động (tỷ đ) | Chưa thành công (tỷ đ) |
|---|---|---|---|
| Tài chính - Ngân hàng | 12,500 | 10,200 | 2,300 |
| Bất động sản | 8,700 | 7,100 | 1,600 |
| Công nghiệp | 5,300 | 4,800 | 500 |

**Source:** `Fact Securities Offering` → `Public Company Dimension`, `Industry Category Dimension`, `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên | Đơn vị | Tính chất | Công thức / Mô tả |
|---|---|---|---|---|
| K_QLCB_1 | Giá trị Cấp phép | Tỷ VNĐ | Flow (Base) | `SUM(Planned Proceeds Amount)` per ngành × kỳ |
| K_QLCB_2 | Giá trị Huy động thành công | Tỷ VNĐ | Flow (Base) | `SUM(Actual Proceeds Amount)` per ngành × kỳ |
| K_QLCB_3 | Chưa thành công | Tỷ VNĐ | Derived | `K_QLCB_1 − K_QLCB_2` — tính ở presentation layer |
| K_QLCB_1_YOY | YoY% Giá trị Cấp phép | % | Derived | `(K_QLCB_1[Y] − K_QLCB_1[Y−1]) / K_QLCB_1[Y−1] × 100%` |
| K_QLCB_2_YOY | YoY% Giá trị Huy động | % | Derived | `(K_QLCB_2[Y] − K_QLCB_2[Y−1]) / K_QLCB_2[Y−1] × 100%` |

> **Lưu ý:** K_QLCB_1 và K_QLCB_2 là Base — lấy trực tiếp từ `Planned Proceeds Amount` và `Actual Proceeds Amount` của `Public Company Securities Offering`. K_QLCB_3 và YoY là Derived — tính ở presentation layer, không lưu mart.

> **Ghi chú — Industry Category Dimension:** ETL-derived Conformed Dimension — Silver không có entity riêng cho ngành. ETL extract từ `Public Company.Industry Category Level1/Level2 Code` (IDS.company_detail.category_l1_id, category_l2_id). Lý do tạo Dim riêng: (1) GROUP BY ngành ≠ GROUP BY công ty đại chúng, (2) Conformed Dim tái sử dụng cross-module (NDTNN, NHNCK, QLKD).

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        int Date_Dimension_Id PK
        date Full_Date
        int Year
        int Quarter
        int Month
    }
    Public_Company_Dimension {
        int Public_Company_Dimension_Id PK
        int Public_Company_Id
        string Public_Company_Code
        string Public_Company_Name
        varchar Industry_Category_Level1_Code
        varchar Equity_Listing_Exchange_Code
        date Effective_Date
        date Expiry_Date
    }
    Industry_Category_Dimension {
        int Industry_Category_Dimension_Id PK
        varchar Industry_Category_Level1_Code
        string Industry_Category_Level1_Name
        varchar Industry_Category_Level2_Code
        string Industry_Category_Level2_Name
        date Effective_Date
        date Expiry_Date
    }
    Fact_Securities_Offering {
        varchar Securities_Offering_Code
        int Certificate_Issue_Date_Dimension_Id FK
        int Public_Company_Dimension_Id FK
        int Industry_Category_Dimension_Id FK
        float Planned_Proceeds_Amount
        float Actual_Proceeds_Amount
        int Planned_Security_Quantity
        int Successful_Security_Quantity
        varchar Security_Type_Code
        varchar Offering_Type_Category_Code
        date Offering_Start_Date
        date Offering_End_Date
        datetime Population_Date
    }

    Calendar_Date_Dimension ||--o{ Fact_Securities_Offering : "Certificate Issue Date Dimension Id"
    Public_Company_Dimension ||--o{ Fact_Securities_Offering : "Public Company Dimension Id"
    Industry_Category_Dimension ||--o{ Fact_Securities_Offering : "Industry Category Dimension Id"
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Gold Mart"]
        G1["Fact Securities Offering"]
        G2["Public Company Dimension"]
        G3["Industry Category Dimension"]
        G4["Calendar Date Dimension"]
    end
    subgraph RPT["Báo cáo"]
        R1["Tab CHAO BAN PHAT HANH - Nhom 1 - K_QLCB_1 2 3"]
    end
    G1 --> R1
    G2 --> R1
    G3 --> R1
    G4 --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fact Securities Offering | 1 row = 1 đợt chào bán/phát hành CK của 1 công ty đại chúng (Event — 1 record per company_securities_issuance) |
| Public Company Dimension | 1 row = 1 công ty đại chúng (SCD2) |
| Industry Category Dimension | 1 row = 1 ngành cấp 1 × 1 ngành cấp 2 (SCD2 — ETL extract từ Public Company) |
| Calendar Date Dimension | 1 row = 1 ngày (Certificate Issue Date) |

---

#### Nhóm 2 — Giá trị cấp phép chào bán phát hành theo ngành

> Phân loại: **Phân tích**  
> Silver: `Public Company Securities Offering` ← IDS.company_securities_issuance — **READY**  
> Xem Issue O_QLCB_1 về logic mapping loại hình phát hành

**Mockup:**

| Loại hình | Giá trị cấp phép (tỷ đ) | % tổng |
|---|---|---|
| Công chúng | 8,200 | 42% |
| Riêng lẻ | 5,100 | 26% |
| ESOP | 2,300 | 12% |
| Trả cổ tức | 1,800 | 9% |
| Tăng vốn từ VCSH | 1,500 | 8% |
| Khác | 600 | 3% |

**Source:** `Fact Securities Offering` → `Industry Category Dimension`, `Calendar Date Dimension`
Filter thêm theo `Offering Type Category Code` (FK → Classification Dimension, scheme: `QLCB_OFFERING_TYPE_CATEGORY`)

**Bảng KPI:**

| KPI ID | Tên | Đơn vị | Tính chất | Công thức / Mô tả |
|---|---|---|---|---|
| K_QLCB_4 | Loại hình phát hành | — | Chiều | `GROUP BY Offering Type Category Code` — scheme: `QLCB_OFFERING_TYPE_CATEGORY` |
| K_QLCB_5 | Giá trị cấp phép — Công chúng | Tỷ VNĐ | Derived | `SUM(Planned Proceeds Amount) WHERE Offering Type Category Code = 'PUBLIC'` |
| K_QLCB_6 | Giá trị cấp phép — Riêng lẻ | Tỷ VNĐ | Derived | `SUM(Planned Proceeds Amount) WHERE Offering Type Category Code = 'PRIVATE'` |
| K_QLCB_7 | Giá trị cấp phép — ESOP | Tỷ VNĐ | Derived | `SUM(Planned Proceeds Amount) WHERE Offering Type Category Code = 'ESOP'` |
| K_QLCB_8 | Giá trị cấp phép — Trả cổ tức | Tỷ VNĐ | Derived | `SUM(Planned Proceeds Amount) WHERE Offering Type Category Code = 'DIVIDEND'` |
| K_QLCB_9 | Giá trị cấp phép — Tăng vốn từ VCSH | Tỷ VNĐ | Derived | `SUM(Planned Proceeds Amount) WHERE Offering Type Category Code = 'OWNER_CAPITAL'` |
| K_QLCB_10 | Giá trị cấp phép — Các loại khác | Tỷ VNĐ | Derived | `SUM(Planned Proceeds Amount) WHERE Offering Type Category Code = 'OTHER'` |

> **Lưu ý:** K_QLCB_5–10 đều là Derived từ K_QLCB_1 với filter loại hình — tính ở presentation layer. Tổng K_QLCB_5 + ... + K_QLCB_10 = K_QLCB_1. Xem O_QLCB_1 về business rule mapping loại hình từ Silver.

**Star Schema:** Kế thừa từ Nhóm 1 — thêm filter theo `Offering Type Category Code` và GROUP BY `Industry Category Dimension`.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Gold Mart"]
        G1["Fact Securities Offering"]
        G3["Industry Category Dimension"]
        G4["Calendar Date Dimension"]
    end
    subgraph RPT["Báo cáo"]
        R2["Tab CHAO BAN PHAT HANH - Nhom 2 - K_QLCB_4-10"]
    end
    G1 --> R2
    G3 --> R2
    G4 --> R2
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fact Securities Offering | 1 row = 1 đợt chào bán/phát hành CK (kế thừa Nhóm 1) |
| Industry Category Dimension | 1 row = 1 ngành cấp 1 × 1 ngành cấp 2 (SCD2) |
| Calendar Date Dimension | 1 row = 1 ngày |

---

#### Nhóm 3 — Giá trị phát hành theo hình thức phát hành và nhóm ngành

> Phân loại: **Phân tích**  
> Silver: `Public Company Securities Offering` ← IDS.company_securities_issuance — **READY**  
> Xem Issue O_QLCB_1 về logic mapping loại hình phát hành

**Mockup:**

| Ngành \ Loại hình | Công chúng | Riêng lẻ | ESOP | Trả cổ tức | Tăng vốn VCSH | Khác |
|---|---|---|---|---|---|---|
| Tài chính - Ngân hàng | 4,200 | 3,100 | 800 | 600 | 400 | 200 |
| Bất động sản | 2,100 | 1,800 | 500 | 400 | 700 | 100 |
| Công nghiệp | 1,800 | 950 | 300 | 200 | 150 | 100 |

**Source:** `Fact Securities Offering` → `Industry Category Dimension`, `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên | Đơn vị | Tính chất | Công thức / Mô tả |
|---|---|---|---|---|
| K_QLCB_11 | Giá trị huy động — Công chúng | Tỷ VNĐ | Derived | `SUM(Actual Proceeds Amount) WHERE Offering Type Category Code = 'PUBLIC'` GROUP BY ngành |
| K_QLCB_12 | Giá trị huy động — Riêng lẻ | Tỷ VNĐ | Derived | `SUM(Actual Proceeds Amount) WHERE Offering Type Category Code = 'PRIVATE'` GROUP BY ngành |
| K_QLCB_13 | Giá trị huy động — ESOP | Tỷ VNĐ | Derived | `SUM(Actual Proceeds Amount) WHERE Offering Type Category Code = 'ESOP'` GROUP BY ngành |
| K_QLCB_14 | Giá trị huy động — Trả cổ tức | Tỷ VNĐ | Derived | `SUM(Actual Proceeds Amount) WHERE Offering Type Category Code = 'DIVIDEND'` GROUP BY ngành |
| K_QLCB_15 | Giá trị huy động — Tăng vốn từ VCSH | Tỷ VNĐ | Derived | `SUM(Actual Proceeds Amount) WHERE Offering Type Category Code = 'OWNER_CAPITAL'` GROUP BY ngành |
| K_QLCB_16 | Giá trị huy động — Các loại khác | Tỷ VNĐ | Derived | `SUM(Actual Proceeds Amount) WHERE Offering Type Category Code = 'OTHER'` GROUP BY ngành |

> **Lưu ý:** Nhóm 3 khác Nhóm 2 ở chỗ dùng `Actual Proceeds Amount` (thực tế huy động) thay vì `Planned Proceeds Amount` (cấp phép). Cùng 1 Fact, GROUP BY ngành × loại hình thay vì chỉ theo loại hình.

**Star Schema:** Cùng star schema với Nhóm 1 — GROUP BY `Industry Category Dimension` × `Offering Type Category Code`.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Gold Mart"]
        G1["Fact Securities Offering"]
        G3["Industry Category Dimension"]
        G4["Calendar Date Dimension"]
    end
    subgraph RPT["Báo cáo"]
        R3["Tab CHAO BAN PHAT HANH - Nhom 3 - K_QLCB_11-16"]
    end
    G1 --> R3
    G3 --> R3
    G4 --> R3
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fact Securities Offering | 1 row = 1 đợt chào bán/phát hành CK (kế thừa Nhóm 1) |
| Industry Category Dimension | 1 row = 1 ngành cấp 1 × 1 ngành cấp 2 (SCD2) |
| Calendar Date Dimension | 1 row = 1 ngày |

---

#### Nhóm 4 — Bảng Chi tiết số lượng chứng khoán Chào bán & Phát hành

> Phân loại: **Tác nghiệp**  
> Silver: `Public Company Securities Offering` ← IDS.company_securities_issuance — **READY**  
> Silver: `Public Company` ← IDS.company_profiles — **READY**  
> **PENDING (4 attributes):** Đơn vị tư vấn, Tổ chức kiểm toán, Đơn vị bảo lãnh, Đơn vị xếp hạng tín nhiệm — nguồn TTHC chưa có Source Analysis MD

**Mockup:**

| Mã CK | Tên DN | Hình thức | Đvị tư vấn | Tổ chức KT | Đvị bảo lãnh | Đvị XHTN | SL cấp phép | SL thành công | GT cấp phép (tỷ) | GT thành công (tỷ) | Tỷ lệ % |
|---|---|---|---|---|---|---|---|---|---|---|---|
| ABC | Công ty ABC | Công chúng | — | — | — | — | 10,000,000 | 9,500,000 | 500 | 475 | 95% |
| DEF | Công ty DEF | Riêng lẻ | — | — | — | — | 5,000,000 | 5,000,000 | 250 | 250 | 100% |

**Source:** `Securities Offering 360 Profile` — lookup theo đợt chào bán / công ty

**Bảng KPI:**

| KPI ID | Tên | Đơn vị | Tính chất | Công thức / Mô tả |
|---|---|---|---|---|
| K_QLCB_17 | Thông tin doanh nghiệp (Mã CK, Tên DN) | — | Attribute | `SELECT Public Company Code, Public Company Name` |
| K_QLCB_18 | Hình thức chào bán | — | Attribute | `SELECT Offering Type Category Code` |
| K_QLCB_19 | Đơn vị tư vấn | — | Attribute | **PENDING** — nguồn TTHC chưa có Source Analysis |
| K_QLCB_20 | Tổ chức kiểm toán | — | Attribute | **PENDING** — nguồn TTHC chưa có Source Analysis |
| K_QLCB_21 | Đơn vị bảo lãnh | — | Attribute | **PENDING** — nguồn TTHC chưa có Source Analysis |
| K_QLCB_22 | Đơn vị xếp hạng tín nhiệm | — | Attribute | **PENDING** — nguồn TTHC chưa có Source Analysis |
| K_QLCB_23 | Số lượng CK được cấp phép | CK | Attribute | `Planned Security Quantity` — IDS.company_securities_issuance.planned_security_qty |
| K_QLCB_24 | Số lượng CK chào bán thành công | CK | Attribute | `Successful Security Quantity` — IDS.company_securities_issuance.successful_security_qty |
| K_QLCB_25 | Giá trị cấp phép | Tỷ VNĐ | Attribute | `Planned Proceeds Amount` — IDS.company_securities_issuance.planned_proceeds_am |
| K_QLCB_26 | Giá trị chào bán thành công | Tỷ VNĐ | Attribute | `Actual Proceeds Amount` — IDS.company_securities_issuance.actual_proceeds_am |
| K_QLCB_27 | Tỷ lệ chào bán thành công | % | Derived | `K_QLCB_24 / K_QLCB_23 × 100%` — tính ở presentation layer |

> **PENDING — K_QLCB_19 đến K_QLCB_22:** 4 KPI có nguồn TTHC. Không có TTHC_Source_Analysis.md → không xác định được Silver entity. Giữ placeholder NULL trong `Securities Offering 360 Profile`.  
> **Silver cần bổ sung:** Entity tư vấn, kiểm toán, bảo lãnh, xếp hạng tín nhiệm từ hồ sơ đăng ký chào bán trong TTHC — bao gồm attributes: tên đơn vị, mã đơn vị, FK sang đợt chào bán.

**Schema bảng tác nghiệp:**

```mermaid
erDiagram
    Securities_Offering_360_Profile {
        varchar Securities_Offering_Code PK
        string Public_Company_Code
        string Public_Company_Name
        string Public_Company_English_Name
        varchar Security_Type_Code
        varchar Offering_Type_Category_Code
        string Certificate_Number
        date Certificate_Issue_Date
        string SSC_Official_Document_Number
        date SSC_Official_Document_Date
        boolean Multi_Offering_Flag
        int Planned_Security_Quantity
        float Planned_Proceeds_Amount
        int Successful_Security_Quantity
        float Actual_Proceeds_Amount
        string Capital_Usage_Plan
        date Offering_Start_Date
        date Offering_End_Date
        varchar Industry_Category_Level1_Code
        varchar Industry_Category_Level2_Code
        varchar Equity_Listing_Exchange_Code
        datetime Population_Date
    }
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph SIL["Silver"]
        SV1["Public Company Securities Offering\n(IDS.company_securities_issuance)"]
        SV2["Public Company\n(IDS.company_profiles)"]
    end
    subgraph GOLD["Gold Mart"]
        G1["Securities Offering 360 Profile"]
    end
    subgraph RPT["Báo cáo"]
        R4["Tab CHAO BAN PHAT HANH - Nhom 4 - K_QLCB_17-27"]
    end
    SV1 --> G1
    SV2 --> G1
    G1 --> R4
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| `Securities Offering 360 Profile` | 1 row = 1 đợt chào bán/phát hành (latest state — 1 row per company_securities_issuance) |

---

### Tab: HỒ SƠ ĐĂNG KÝ CHÀO BÁN

**Slicer chung:** Từ ngày — Đến ngày (date range picker)

---

#### Nhóm 5 — KPI Cards tổng quan hồ sơ

##### PENDING — KPI Cards hồ sơ (STT 29–32)

**KPI liên quan:**

> **Lưu ý:** 4 KPI card trên màn hình hiển thị **số lượng hồ sơ** (không phải tỷ lệ %). Tỷ lệ % là chỉ tiêu phái sinh tính tại presentation layer từ các số lượng Base. BA đặt tên "Tỷ lệ..." nhưng thực tế card hiển thị số nguyên (ví dụ: Hồ sơ đăng ký = 1, Đang xử lý = 1, Bị từ chối = 2).

| STT BA | Tên KPI (BA) | Tên KPI thực tế | Tính chất | Công thức |
|---|---|---|---|---|
| 29 | Tỷ lệ hồ sơ đăng ký | Số lượng hồ sơ đăng ký | Cơ sở | COUNT(hồ sơ có trạng thái = Đăng ký) |
| 30 | Tỷ lệ hồ sơ đang xử lý | Số lượng hồ sơ đang xử lý | Cơ sở | COUNT(hồ sơ có trạng thái = Đang xử lý) |
| 31 | Tỷ lệ hồ sơ đã chấp thuận | Số lượng hồ sơ đã chấp thuận | Cơ sở | COUNT(hồ sơ có trạng thái = Đã cấp phép) |
| 32 | Tỷ lệ hồ sơ bị từ chối | Số lượng hồ sơ bị từ chối | Cơ sở | COUNT(hồ sơ có trạng thái = Từ chối) |
| — | Tỷ lệ % per trạng thái | Phái sinh | Derived | COUNT(trạng thái X) / SUM(tất cả trạng thái) × 100% — tính ở presentation layer |

**Lý do pending:** Toàn bộ KPI thuộc nguồn TTHC (hệ thống thủ tục hành chính). Không có TTHC_Source_Analysis.md trong project knowledge. Không xác định được Silver entity nào lưu trạng thái hồ sơ đăng ký chào bán (đăng ký / đang xử lý / chấp thuận / từ chối). Không thể thiết kế Fact hay Dim mà không có Silver LLD.

**Silver cần bổ sung:** Entity hồ sơ đăng ký chào bán từ TTHC, tối thiểu cần các attributes: mã hồ sơ, hình thức chào bán, năm nộp, trạng thái hồ sơ (scheme trạng thái: đăng ký / đang xử lý / đã cấp phép / bị từ chối), ngày nộp, ngày cập nhật trạng thái, FK sang công ty đại chúng.

**Mart dự kiến khi Silver sẵn sàng:** `Fact Securities Offering Application` — grain = 1 hồ sơ đăng ký × 1 ngày nộp.

---

#### Nhóm 6 — Biểu đồ Tỷ lệ xử lý hồ sơ (donut)

##### PENDING — Biểu đồ donut Tỷ lệ xử lý hồ sơ (STT 29–32)

**KPI liên quan:** Tỷ lệ hồ sơ đăng ký / đang xử lý / đã chấp thuận / bị từ chối — cùng KPI với Nhóm 5, hiển thị dạng donut chart.

**Lý do pending:** Cùng nguồn TTHC với Nhóm 5 — xem lý do chi tiết tại Nhóm 5. Biểu đồ donut hiển thị tỷ lệ % 4 trạng thái, cần đúng 4 Base KPI đếm hồ sơ per trạng thái.

**Silver cần bổ sung:** Xem Nhóm 5 — cùng entity TTHC.

**Mart dự kiến khi Silver sẵn sàng:** `Fact Securities Offering Application` — grain = 1 hồ sơ × 1 ngày nộp. Biểu đồ donut = GROUP BY `Application Status Code` COUNT(hồ sơ).

---

#### Nhóm 7 — Bảng Chi tiết hồ sơ chào bán & phát hành

##### PENDING — Bảng chi tiết hồ sơ theo hình thức × năm (STT 33–39)

**KPI liên quan:**

| STT BA | Tên KPI | Phân loại | Công thức |
|---|---|---|---|
| 33 | Hình thức chào bán | Cơ sở | GROUP BY hình thức chào bán |
| 34 | Năm | Cơ sở | GROUP BY năm nộp hồ sơ |
| 35 | Số lượng hồ sơ đăng ký | Cơ sở | COUNT hồ sơ có trạng thái = đăng ký |
| 36 | Số lượng hồ sơ đang xử lý | Cơ sở | COUNT hồ sơ có trạng thái = đang xử lý |
| 37 | Số lượng hồ sơ đã cấp phép | Cơ sở | COUNT hồ sơ có trạng thái = đã cấp phép |
| 38 | Số lượng hồ sơ bị từ chối | Cơ sở | COUNT hồ sơ có trạng thái = bị từ chối |
| 39 | Tổng hồ sơ | Phái sinh | SUM(STT 35 + 36 + 37 + 38) |

**Lý do pending:** Toàn bộ nguồn TTHC. Bảng chi tiết cần GROUP BY hình thức chào bán × năm. Screenshot cho thấy các hình thức: Chào bán cho CĐ hiện hữu, Phát hành Riêng lẻ hoán đổi nợ, Phát hành CP thưởng (Bonus), Chào bán CP riêng lẻ, Phát hành CP ESOP — các giá trị này cần scheme phân loại từ TTHC Silver.

**Silver cần bổ sung:** Xem Nhóm 5 — cùng entity TTHC. Thêm attribute `Offering Form Type Code` (scheme: `TTHC_OFFERING_FORM_TYPE`) và `Application Year`.

**Mart dự kiến khi Silver sẵn sàng:** `Fact Securities Offering Application` — grain = 1 hồ sơ × 1 ngày nộp. Bảng chi tiết = GROUP BY `Offering Form Type Code` × `Year` COUNT per `Application Status Code`.


---

### Tab: DATA EXPLORER

**Slicer chung:** Sàn (dropdown), Ngành nghề (dropdown), Khoảng thời gian (Từ ngày — Đến ngày)

> **Ghi chú thiết kế:** Data Explorer là màn hình tra cứu chi tiết từng đợt chào bán, cho phép người dùng chọn tổ hợp chỉ số (checkbox) từ 4 nhóm rồi hiển thị bảng kết quả. Đây là use case Tác nghiệp — lookup n đợt chào bán theo điều kiện lọc. Tab này **reuse** `Securities Offering 360 Profile` đã thiết kế ở Nhóm 4 Tab CHÀO BÁN PHÁT HÀNH, mở rộng thêm các attribute chi tiết theo từng hình thức phát hành (ESOP target, Dividend qty...). Không cần thêm Fact hay Dim mới.

---

#### Nhóm 8 — Thông tin cơ sở

> Phân loại: **Tác nghiệp**  
> Silver: `Public Company Securities Offering` ← IDS.company_securities_issuance — **READY**  
> Silver: `Public Company` ← IDS.company_profiles / IDS.company_detail — **READY**  
> Ghi chú: Attribute "Chuyên viên" (STT 65) — PENDING vì `Created By Login Name` map về `logins` (bảng hệ thống out-of-scope trong IDS Silver). Xem O_QLCB_5.

**Mockup:**

| Mã CK | Tên công ty | Sàn | Ngành | Thời điểm báo cáo | Chuyên viên | Loại CK |
|---|---|---|---|---|---|---|
| VIC | VinGroup | HOSE | Bất động sản | 24/03/2026 | — | Cổ phiếu |
| VCB | Vietcombank | UPCOM | Ngân hàng | 24/03/2026 | — | Cổ phiếu |

**Source:** `Securities Offering 360 Profile`

**Bảng KPI:**

| KPI ID | Tên | Đơn vị | Tính chất | Nguồn Silver | Ghi chú |
|---|---|---|---|---|---|
| K_QLCB_28 | Thời điểm báo cáo | Ngày | Attribute | `Public Company Securities Offering.Certificate Issue Date` | Ngày cấp GCN — dùng làm thời điểm báo cáo |
| K_QLCB_29 | Chuyên viên | Text | Attribute | `Public Company Securities Offering.Created By Login Name` — IDS.company_securities_issuance.created_by. Giá trị là login_name kỹ thuật (không phải tên đầy đủ). Xem O_QLCB_5 |
| K_QLCB_30 | Tên công ty | Text | Attribute | `Public Company.Public Company Name` | |
| K_QLCB_31 | Mã chứng khoán | Text | Attribute | `Public Company.Public Company Code` | |
| K_QLCB_32 | Sàn | Text | Attribute | `Public Company.Equity Listing Exchange Code` | Scheme: IDS_EQUITY_LISTING_EXCH |
| K_QLCB_33 | Loại chứng khoán | Text | Attribute | `Public Company Securities Offering.Security Type Code` | Scheme: IDS_ISSUANCE_SECURITY_TYPE |

**Schema bảng tác nghiệp:** Kế thừa `Securities Offering 360 Profile` — xem Nhóm 4 Tab CHÀO BÁN PHÁT HÀNH.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Gold Mart"]
        G1["Securities Offering 360 Profile"]
    end
    subgraph RPT["Báo cáo"]
        R8["Tab DATA EXPLORER - Nhom 8 - K_QLCB_28-33"]
    end
    G1 --> R8
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| `Securities Offering 360 Profile` | 1 row = 1 đợt chào bán/phát hành (1 row per company_securities_issuance) |

---

#### Nhóm 9 — Thông tin công văn cấp phép

> Phân loại: **Tác nghiệp**  
> Silver: `Public Company Securities Offering` ← IDS.company_securities_issuance — **READY**

**Mockup:**

| Số GCN | Ngày cấp GCN | Số công văn gửi CT | Ngày công văn | Hình thức phát hành |
|---|---|---|---|---|
| 12/GCN-UBCK | 15/01/2026 | 14/CV-UBCK | 14/01/2026 | Công chúng |
| 08/GCN-UBCK | 10/02/2026 | 07/CV-UBCK | 09/02/2026 | Riêng lẻ |

**Source:** `Securities Offering 360 Profile`

**Bảng KPI:**

| KPI ID | Tên | Đơn vị | Tính chất | Nguồn Silver |
|---|---|---|---|---|
| K_QLCB_34 | Số giấy chứng nhận | Text | Attribute | `Public Company Securities Offering.Certificate Number` — IDS.company_securities_issuance.certificate_no |
| K_QLCB_35 | Ngày cấp giấy chứng nhận | Ngày | Attribute | `Public Company Securities Offering.Certificate Issue Date` — IDS.company_securities_issuance.certificate_issue_date |
| K_QLCB_36 | Số công văn gửi công ty | Text | Attribute | `Public Company Securities Offering.SSC Official Document Number` — IDS.company_securities_issuance.ssc_official_doc_no |
| K_QLCB_37 | Ngày công văn | Ngày | Attribute | `Public Company Securities Offering.SSC Official Document Date` — IDS.company_securities_issuance.ssc_official_doc_date |
| K_QLCB_38 | Hình thức phát hành | Text | Attribute | `Securities Offering 360 Profile.Offering Type Category Code` — ETL derived từ plan_xxx_qty. Xem O_QLCB_1 |

**Schema bảng tác nghiệp:** Kế thừa `Securities Offering 360 Profile`.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Gold Mart"]
        G1["Securities Offering 360 Profile"]
    end
    subgraph RPT["Báo cáo"]
        R9["Tab DATA EXPLORER - Nhom 9 - K_QLCB_34-38"]
    end
    G1 --> R9
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| `Securities Offering 360 Profile` | 1 row = 1 đợt chào bán/phát hành |

---

#### Nhóm 10 — Thông tin cấp phép chào bán

> Phân loại: **Tác nghiệp**  
> Silver: `Public Company Securities Offering` ← IDS.company_securities_issuance — **READY**  
> Ghi chú: "Giá (cấp phép)" — Silver lưu giá riêng per hình thức (plan_esop_price, plan_single_price...), không có giá tổng hợp. Cần giải quyết qua O_QLCB_1 (Offering Type Category). "Số lượng người lao động" và "Đối tượng" là các text field riêng per hình thức — đã có trong Silver (`plan_esop_no`, `plan_single_obj`...).

**Mockup:**

| Số lượng cấp phép | Giá (cấp phép) | Giá trị cấp phép | SL người LĐ | Đối tượng | Mục đích sử dụng vốn |
|---|---|---|---|---|---|
| 10,000,000 | 15,000 đ | 150 tỷ | 500 | CBNV công ty | Bổ sung vốn lưu động |

**Source:** `Securities Offering 360 Profile`

**Bảng KPI:**

| KPI ID | Tên | Đơn vị | Tính chất | Nguồn Silver |
|---|---|---|---|---|
| K_QLCB_39 | Số lượng cấp phép | CK | Attribute | `Public Company Securities Offering.Planned Security Quantity` — IDS.company_securities_issuance.planned_security_qty |
| K_QLCB_40 | Giá (cấp phép) | VNĐ | Attribute | ETL derived — giá theo `Offering Type Category Code` chính. Xem O_QLCB_1 |
| K_QLCB_41 | Giá trị cấp phép | Tỷ VNĐ | Attribute | `Public Company Securities Offering.Planned Proceeds Amount` — IDS.company_securities_issuance.planned_proceeds_am |
| K_QLCB_42 | Số lượng người lao động | Người | Attribute | ETL derived — từ `plan_esop_no` / `plan_bonus_share_no` tùy hình thức. Xem O_QLCB_5 |
| K_QLCB_43 | Đối tượng | Text | Attribute | ETL derived — từ `plan_esop_no` / `plan_single_obj` / `plan_shareholder_qty`... tùy hình thức |
| K_QLCB_44 | Mục đích sử dụng vốn | Text | Attribute | `Public Company Securities Offering.Capital Usage Plan` — IDS.company_securities_issuance.capital_usage_plan |

**Schema bảng tác nghiệp:** Kế thừa `Securities Offering 360 Profile` — cần bổ sung thêm các attribute ESOP/bonus/private target.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Gold Mart"]
        G1["Securities Offering 360 Profile"]
    end
    subgraph RPT["Báo cáo"]
        R10["Tab DATA EXPLORER - Nhom 10 - K_QLCB_39-44"]
    end
    G1 --> R10
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| `Securities Offering 360 Profile` | 1 row = 1 đợt chào bán/phát hành |

---

#### Nhóm 11 — Thông tin kết quả chào bán

> Phân loại: **Tác nghiệp**  
> Silver: `Public Company Securities Offering` ← IDS.company_securities_issuance — **READY**

**Mockup:**

| Số lượng thực tế | Giá thực tế | Giá trị thực tế | SL người LĐ (TT) | Đối tượng (TT) |
|---|---|---|---|---|
| 9,800,000 | 15,000 đ | 147 tỷ | 490 | CBNV công ty |

**Source:** `Securities Offering 360 Profile`

**Bảng KPI:**

| KPI ID | Tên | Đơn vị | Tính chất | Nguồn Silver |
|---|---|---|---|---|
| K_QLCB_45 | Số lượng thực tế | CK | Attribute | `Public Company Securities Offering.Successful Security Quantity` — IDS.company_securities_issuance.successful_security_qty |
| K_QLCB_46 | Giá thực tế | VNĐ | Attribute | ETL derived — giá theo `Offering Type Category Code` chính (result). Xem O_QLCB_1 |
| K_QLCB_47 | Giá trị thực tế | Tỷ VNĐ | Attribute | `Public Company Securities Offering.Actual Proceeds Amount` — IDS.company_securities_issuance.actual_proceeds_am |
| K_QLCB_48 | Số lượng người lao động (TT) | Người | Attribute | ETL derived — từ `result_esop_no` / `result_bonus_share_no` tùy hình thức. Xem O_QLCB_5 |
| K_QLCB_49 | Đối tượng (thực tế) | Text | Attribute | ETL derived — từ `result_esop_no` / `result_single_obj`... tùy hình thức |

**Schema bảng tác nghiệp:** Kế thừa `Securities Offering 360 Profile`.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Gold Mart"]
        G1["Securities Offering 360 Profile"]
    end
    subgraph RPT["Báo cáo"]
        R11["Tab DATA EXPLORER - Nhom 11 - K_QLCB_45-49"]
    end
    G1 --> R11
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| `Securities Offering 360 Profile` | 1 row = 1 đợt chào bán/phát hành |


---

### Tab: TRA CỨU CÁ NHÂN

**Slicer chung:** Tìm theo tên hoặc số CMND/CCCD (search box). Ngày dữ liệu (date picker).

> **Ghi chú thiết kế — Cross-source 360 Profile:**
> Tab Tra cứu cá nhân là use case lookup 1 cá nhân theo CMND/CCCD. Dữ liệu tổng hợp từ 4 nguồn (IDS, SCMS, FMS, Thanh Tra, NHNCK). Thiết kế là **1 bảng Tác nghiệp duy nhất**: `Individual 360 Profile` — denormalized, 1 row per cá nhân (latest state), lưu toàn bộ context: vai trò DN, người liên quan, tài khoản, CCHN, thông tin kiểm toán viên, lịch sử công tác, lịch sử vi phạm dưới dạng nested/array attributes.

---

#### Nhóm 12 — Danh sách tìm kiếm cá nhân

> Phân loại: **Tác nghiệp**
> Silver: `Stock Holder` ← IDS.stock_holders — **READY**
> Silver: `Securities Company Senior Personnel` ← SCMS.CTCK_NHAN_SU_CAO_CAP — **READY**
> Silver: `Investment Fund Representative Board Member` ← FMS.REPRESENT — **READY**

**Mockup:**

| Họ tên | Chức vụ | Công ty | Loại | ID |
|---|---|---|---|---|
| Nguyễn Thế Anh | Chủ tịch HĐQT | SSI Securities | BROKER | 012345678 |
| Trần Thị B | Tổng Giám đốc | VCB | ENTERPRISE | 098765432 |
| Lê Minh Tuấn | Thành viên HĐQT | Dragon Capital | AMC | 024681357 |

**Source:** `Individual 360 Profile`

**Bảng KPI:**

| KPI ID | Tên | Tính chất | Nguồn Silver |
|---|---|---|---|
| K_QLCB_50 | Họ tên cá nhân | Attribute | `Stock Holder.Shareholder Name` / `Securities Company Senior Personnel.Full Name` |
| K_QLCB_51 | Chức vụ | Attribute | `Stock Holder.Position Codes` / `Securities Company Senior Personnel.Position Type Code` |
| K_QLCB_52 | Công ty | Attribute | `Stock Holder.Public Company Code` / `Securities Company Senior Personnel.Securities Company Code` |
| K_QLCB_53 | Loại (BROKER/ENTERPRISE/AMC/FUND) | Attribute | ETL derived — từ nguồn Silver xác định loại tổ chức |
| K_QLCB_54 | Số CMND/CCCD | Attribute | `Involved Party Alternative Identification.Identification Number` |

**Schema bảng tác nghiệp:**

```mermaid
erDiagram
    Individual_360_Profile {
        varchar National_Id PK
        string Full_Name
        string Position_Name
        string Company_Name
        varchar Company_Type_Code
        varchar Practice_Status_Code
        date Since_Date
        datetime Population_Date
    }
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph SIL["Silver"]
        SV1["Stock Holder (IDS)"]
        SV2["Securities Company Senior Personnel (SCMS)"]
        SV3["Investment Fund Representative Board Member (FMS)"]
        SV4["Securities Practitioner (NHNCK)"]
    end
    subgraph GOLD["Gold Mart"]
        G1["Individual 360 Profile"]
    end
    subgraph RPT["Báo cáo"]
        R12["Tab TRA CUU CA NHAN - Nhom 12 - K_QLCB_50-54"]
    end
    SV1 --> G1
    SV2 --> G1
    SV3 --> G1
    SV4 --> G1
    G1 --> R12
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| `Individual 360 Profile` | 1 row = 1 cá nhân (theo CMND/CCCD — latest state) |

---

#### Nhóm 13 — Mạng lưới quan hệ (đồ thị)

> Phân loại: **Tác nghiệp**
> Silver: `Stock Holder` ← IDS.stock_holders — **READY**
> Silver: `Stock Holder Relationship` ← IDS.holder_relationship — **READY** (quan hệ gia đình/liên quan giữa 2 cổ đông)
> Silver: `Securities Company Shareholder Related Party` ← SCMS.CTCK_CD_MOI_QUAN_HE — **READY**
> Silver: `Securities Company Senior Personnel` ← SCMS.CTCK_NHAN_SU_CAO_CAP — **READY**
> Silver: `Fund Management Company Key Person` ← FMS.TLProfiles — **READY** (nhân sự chủ chốt công ty QLQ)
> Ghi chú: Đồ thị mạng lưới (graph visualization) được render tại presentation layer từ dữ liệu tác nghiệp — Gold không lưu graph structure, chỉ lưu danh sách quan hệ dạng flat.

**Mockup:**

```
Đồ thị mạng lưới 360°
● NGUYỄN THẾ ANH (Nhân sự chính) — kết nối đến:
  ○ NGUYỄN THẾ G (Con trai) — cổ đông 50.000 CP
  ○ TRẦN VĂN H (Em rể) — Thành viên HĐQT VCB
  ○ LÊ THỊ HỒNG F (Vợ) — Cổ đông lớn 1.200.000 CP
  □ VIC, VHM, HPG, FPT, TCB, VCB (DN niêm yết liên quan)
```

**Source:** `Individual 360 Profile`

**Bảng KPI:**

| KPI ID | Tên | Tính chất | Nguồn Silver |
|---|---|---|---|
| K_QLCB_55 | Danh sách người liên quan (họ tên, CCCD, mối quan hệ) | Attribute | Tổng hợp từ 3 nguồn: (1) `Stock Holder Relationship.Relationship Type Code` + `Related Stock Holder Id` → họ tên/CCCD cổ đông liên quan — IDS.holder_relationship; (2) `Securities Company Shareholder Related Party.Related Party Full Name` + `.Relationship Type Code` + CCCD — SCMS.CTCK_CD_MOI_QUAN_HE; (3) `Fund Management Company Key Person.Full Name` + `.Job Type Code` — FMS.TLProfiles |
| K_QLCB_56 | Vai trò/Chức vụ của cá nhân tại các công ty liên quan | Attribute | Tổng hợp từ 3 nguồn: (1) `Stock Holder.Position Codes` + `Public Company Code` — IDS.stock_holders (cổ đông lớn/nội bộ tại công ty đại chúng); (2) `Securities Company Senior Personnel.Position Type Code` + `Securities Company Code` — SCMS.CTCK_NHAN_SU_CAO_CAP (nhân sự cao cấp CTCK); (3) `Fund Management Company Key Person.Job Type Code` + `Fund Management Company Code` — FMS.TLProfiles (nhân sự QLQ) |

**Schema bảng tác nghiệp:** Kế thừa `Individual 360 Profile` — nested array `Related Parties[]` và `Company Roles[]`.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Gold Mart"]
        G1["Individual 360 Profile"]
    end
    subgraph RPT["Báo cáo"]
        R13["Tab TRA CUU CA NHAN - Nhom 13 - K_QLCB_55 56"]
    end
    G1 --> R13
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| `Individual 360 Profile` | 1 row = 1 cá nhân (latest state, bao gồm nested relationships) |

---

#### Nhóm 14 — Hồ sơ: Vai trò DN / Người liên quan / Tài khoản

> Phân loại: **Tác nghiệp**
> Silver: `Stock Holder` ← IDS.stock_holders — **READY**
> Silver: `Stock Holder Trading Account` ← IDS.account_numbers — **READY**
> Silver: `Securities Company Shareholder Related Party` ← SCMS.CTCK_CD_MOI_QUAN_HE — **READY**

**Mockup:**

| VAI TRÒ TẠI DN | | MẠNG LƯỚI NGƯỜI LIÊN QUAN | | TÀI KHOẢN |
|---|---|---|---|---|
| VCB — Thành viên HĐQT ACTIVE (450.000 CP) | | Lê Thị Hồng F — Vợ — 250.000 CP — 0.12% | | SSI — 001C123456 — Chủ TK: Nguyễn Thế Anh |
| FPT — Cổ đông lớn ACTIVE (2.500.000 CP) | | Nguyễn Thế G — Con trai — 50.000 CP — 0.02% | | VNDIRECT — 002C998877 — Chủ TK: Lê Thị Hồng Văn |

**Source:** `Individual 360 Profile`

**Bảng KPI:**

| KPI ID | Tên | Tính chất | Nguồn Silver |
|---|---|---|---|
| K_QLCB_57 | Thông tin vai trò tại DN niêm yết (tên DN, vai trò, số CP, trạng thái) | Attribute | `Stock Holder.Public Company Code`, `.Position Codes`, `.Ownership Quantity`, `.Major Holder Flag`, `Public Company.Public Company Name` |
| K_QLCB_58 | Thông tin người liên quan (họ tên, CCCD, nghề nghiệp, quan hệ, số CP, %) | Attribute | `Securities Company Shareholder Related Party.Related Party Full Name`, `.Relationship Type Code`, `.Share Quantity`, `.Share Ratio`, `Involved Party Alternative Identification.Identification Number` |
| K_QLCB_59 | Danh sách tài khoản (số TK, CTCK, chủ TK) | Attribute | `Stock Holder Trading Account.Account Number`, `.Securities Company Code`, `.Account Holder Name` |

**Schema bảng tác nghiệp:** Kế thừa `Individual 360 Profile`.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Gold Mart"]
        G1["Individual 360 Profile"]
    end
    subgraph RPT["Báo cáo"]
        R14["Tab TRA CUU CA NHAN - Nhom 14 - K_QLCB_57 58 59"]
    end
    G1 --> R14
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| `Individual 360 Profile` | 1 row = 1 cá nhân (latest state) |

---

#### Nhóm 15 — Lịch sử cấp CCHN

> Phân loại: **Tác nghiệp**
> Silver: `Securities Practitioner License Certificate Document` ← NHNCK.CertificateRecords — **READY**
> Silver: `Securities Practitioner` ← NHNCK.Professionals — **READY**

**Mockup:**

| Số CCHN | Loại hành nghề | Ngày cấp | Ngày hết hạn | Quyết định | Trạng thái |
|---|---|---|---|---|---|
| CCHN-001 | Môi giới CK | 01/03/2020 | 01/03/2025 | QĐ 45/UBCK | Hết hiệu lực |
| CCHN-002 | Tư vấn đầu tư CK | 15/06/2023 | 15/06/2028 | QĐ 112/UBCK | Đang hiệu lực |

**Source:** `Individual 360 Profile`

**Bảng KPI:**

| KPI ID | Tên | Tính chất | Nguồn Silver |
|---|---|---|---|
| K_QLCB_60 | Số CCHN | Attribute | `Securities Practitioner License Certificate Document.License Certificate Document Code` |
| K_QLCB_61 | Loại hình hành nghề | Attribute | `Securities Practitioner License Certificate Document.Certificate Type Code` — Scheme: CERTIFICATE_TYPE |
| K_QLCB_62 | Ngày cấp | Attribute | `Securities Practitioner License Certificate Document.Issue Date` (từ NHNCK.Applications.IssueDate) |
| K_QLCB_63 | Ngày hết hạn | Attribute | `Securities Practitioner License Certificate Document.Revocation Date` — NHNCK.CertificateRecords.RevocationDate |
| K_QLCB_64 | Quyết định | Attribute | `Securities Practitioner License Certificate Document.Issuance Decision Document Code` |
| K_QLCB_65 | Trạng thái | Attribute | `Securities Practitioner.Practice Status Code` — Scheme: PRACTICE_STATUS |

**Schema bảng tác nghiệp:** Kế thừa `Individual 360 Profile` — nested array `Certificates[]`.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Gold Mart"]
        G1["Individual 360 Profile"]
    end
    subgraph RPT["Báo cáo"]
        R15["Tab TRA CUU CA NHAN - Nhom 15 - K_QLCB_60-65"]
    end
    G1 --> R15
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| `Individual 360 Profile` | 1 row = 1 cá nhân — CCHN là nested array per cá nhân |

---

#### Nhóm 16 — Thông tin kiểm toán viên

> Phân loại: **Tác nghiệp**
> Silver: `Auditor Approval` ← IDS.af_auditor_approval — **READY**

**Mockup:**

| Số GCNHN | Ngày cấp | Thời hạn | Quá trình công tác | QĐ đình chỉ |
|---|---|---|---|---|
| KTV-0234 | 15/04/2018 | 5 năm | Công ty KT ABC | Không |

**Source:** `Individual 360 Profile`

**Bảng KPI:**

| KPI ID | Tên | Tính chất | Nguồn Silver |
|---|---|---|---|
| K_QLCB_66 | Số GCNHN | Attribute | `Auditor Approval.Audit Practice Certificate Number` — IDS.af_auditor_approval.audit_practice_cert_no |
| K_QLCB_67 | Ngày cấp | Attribute | `Auditor Approval.MOF Approval Issue Date` — IDS.af_auditor_approval.mof_approval_issue_date |
| K_QLCB_68 | Thời hạn | Attribute | ETL derived: `MOF Approval End Date − MOF Approval Start Date` |
| K_QLCB_69 | Quá trình công tác | Attribute | `Auditor Approval.Auditor Full Name` + `Audit Firm Code` (xem O_QLCB_7 — không có lịch sử công tác riêng trong af_auditor_approval) |
| K_QLCB_70 | QĐ đình chỉ | Attribute | **PENDING** — chờ trao đổi BA. Xem O_QLCB_7 |

**Schema bảng tác nghiệp:** Kế thừa `Individual 360 Profile` — nested `Auditor Info{}`.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Gold Mart"]
        G1["Individual 360 Profile"]
    end
    subgraph RPT["Báo cáo"]
        R16["Tab TRA CUU CA NHAN - Nhom 16 - K_QLCB_66-70"]
    end
    G1 --> R16
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| `Individual 360 Profile` | 1 row = 1 cá nhân — thông tin kiểm toán viên là nested per cá nhân |

---

#### Nhóm 17 — Lịch sử công tác

> Phân loại: **Tác nghiệp**
> Silver: `Stock Holder` ← IDS.stock_holders — **READY** (vai trò cổ đông lớn/nội bộ tại công ty đại chúng)
> Silver: `Securities Company Senior Personnel` ← SCMS.CTCK_NHAN_SU_CAO_CAP — **READY** (nhân sự cao cấp CTCK)
> Silver: `Investment Fund Representative Board Member` ← FMS.REPRESENT — **READY** (thành viên ban đại diện quỹ)
> Silver: `Fund Management Company Key Person` ← FMS.TLProfiles — **READY** (nhân sự chủ chốt công ty QLQ — thêm mới)
> Ghi chú: "Thời gian làm việc" — Xem O_QLCB_8 (chờ trao đổi BA).

**Mockup:**

| Tên công ty | Chức vụ | Thời gian làm việc | Trạng thái |
|---|---|---|---|
| SSI Securities | Chủ tịch HĐQT | 2015 - Hiện nay (11 năm) | Hiện tại |
| Công ty CP Chứng khoán SSI | Trưởng phòng Môi giới | 2018 - 2023 (5 năm) | Quá khứ |

**Source:** `Individual 360 Profile`

**Bảng KPI:**

| KPI ID | Tên | Tính chất | Nguồn Silver | Ghi chú |
|---|---|---|---|---|
| K_QLCB_71 | Tên công ty | Attribute | Tổng hợp 4 nguồn: (1) `Stock Holder.Public Company Code` → tên công ty đại chúng; (2) `Securities Company Senior Personnel.Securities Company Code` → tên CTCK; (3) `Fund Management Company Key Person.Fund Management Company Code` → tên công ty QLQ; (4) `Investment Fund Representative Board Member.Investment Fund Code` → tên quỹ | ETL union 4 nguồn theo CCCD |
| K_QLCB_72 | Chức vụ | Attribute | (1) `Stock Holder.Position Codes` — IDS; (2) `Securities Company Senior Personnel.Position Type Code` — SCMS; (3) `Fund Management Company Key Person.Job Type Code` — FMS.TLProfiles; (4) `Investment Fund Representative Board Member.Is Chair Indicator` — FMS.REPRESENT | |
| K_QLCB_73 | Thời gian làm việc (Từ ngày — Đến ngày) | Attribute | SCMS: `Created Timestamp` → `Resignation Date`; IDS: `Ownership Date`; FMS: `Created Timestamp` → `Updated Timestamp` | Xem O_QLCB_8 — chờ BA |
| K_QLCB_74 | Trạng thái (Hiện tại / Quá khứ) | Attribute | (1) SCMS: `Personnel Status Code`; (2) IDS: `Major/Insider Holder Active/Inactive Date`; (3) FMS: `Practice Status Code` (REPRESENT) / `Updated Timestamp` (TLProfiles) | |

**Schema bảng tác nghiệp:** Kế thừa `Individual 360 Profile` — nested array `Work History[]`.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Gold Mart"]
        G1["Individual 360 Profile"]
    end
    subgraph RPT["Báo cáo"]
        R17["Tab TRA CUU CA NHAN - Nhom 17 - K_QLCB_71-74"]
    end
    G1 --> R17
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| `Individual 360 Profile` | 1 row = 1 cá nhân — lịch sử công tác là nested array |

---

#### Nhóm 18 — Lịch sử vi phạm & xử phạt hành chính

> Phân loại: **Tác nghiệp**
> Silver: `Surveillance Enforcement Case` ← ThanhTra.GS_HO_SO — **READY**
> Silver: `Surveillance Enforcement Decision` ← ThanhTra.GS_VAN_BAN_XU_LY — **READY**
> Silver: `Inspection Case` ← ThanhTra.TT_HO_SO — **READY**
> Silver: `Inspection Case Conclusion` ← ThanhTra.TT_KET_LUAN — **READY**
> Ghi chú: Cả luồng GS_ (giám sát) và TT_ (thanh tra) đều có thể phát sinh quyết định xử phạt cá nhân. ETL union 2 luồng theo CCCD. Xem O_QLCB_9.

**Mockup:**

| Ngày quyết định | Số quyết định | Nội dung vi phạm | Hình thức xử phạt | Trạng thái |
|---|---|---|---|---|
| 15/10/2023 | 142/QĐ-XPHC | Thao túng giá chứng khoán | 550,000,000 VNĐ | Đã chấp hành |
| 05/02/2021 | 24/QĐ-UBCK | Chậm công bố thông tin sở hữu | Cảnh cáo | Đã chốt |
| 12/11/2019 | BC-0012/CTCK | Vi phạm quy trình mở tài khoản | Đình chỉ hành nghề 3 tháng | Hết thời hạn |

**Source:** `Individual 360 Profile`

**Bảng KPI:**

| KPI ID | Tên | Tính chất | Nguồn Silver |
|---|---|---|---|
| K_QLCB_75 | Ngày quyết định | Attribute | GS_: `Surveillance Enforcement Decision.Violation Report Date`; TT_: `Inspection Case Conclusion` ngày ban hành |
| K_QLCB_76 | Số quyết định (số hiệu) | Attribute | GS_: `Surveillance Enforcement Decision.Penalty Decision Number`; TT_: `Inspection Case Conclusion` số quyết định |
| K_QLCB_77 | Nội dung vi phạm | Attribute | GS_: `Surveillance Enforcement Decision.Penalty Content`; TT_: `Inspection Case Conclusion.Violation Type Code` |
| K_QLCB_78 | Hình thức xử phạt | Attribute | GS_: `Surveillance Enforcement Decision.Total Penalty Amount`; TT_: `Inspection Case Conclusion.Penalty Type Code` |
| K_QLCB_79 | Trạng thái | Attribute | GS_: `Surveillance Enforcement Decision.Decision Status Code`; TT_: `Inspection Case Conclusion.Conclusion Status Code` |

**Schema bảng tác nghiệp:** Kế thừa `Individual 360 Profile` — nested array `Violation History[]`.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Gold Mart"]
        G1["Individual 360 Profile"]
    end
    subgraph RPT["Báo cáo"]
        R18["Tab TRA CUU CA NHAN - Nhom 18 - K_QLCB_75-79"]
    end
    G1 --> R18
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| `Individual 360 Profile` | 1 row = 1 cá nhân — lịch sử vi phạm là nested array |


---

## Section 3 — Mô hình tổng thể (READY only)

```mermaid
graph TB
    classDef dim fill:#E6F1FB,stroke:#185FA5,color:#0C447C
    classDef fact fill:#FAECE7,stroke:#993C1D,color:#4A1B0C
    classDef oper fill:#E8F5E9,stroke:#2E7D32,color:#1B5E20
    classDef pending fill:#FFF9E6,stroke:#B8860B,color:#5C4A00

    DIM_DATE["Calendar Date Dimension"]:::dim
    DIM_COMPANY["Public Company Dimension SCD2"]:::dim
    DIM_INDUSTRY["Industry Category Dimension SCD2"]:::dim

    FACT_OFF["Fact Securities Offering"]:::fact

    OPR_OFF["Securities Offering 360 Profile"]:::oper
    OPR_IND["Individual 360 Profile"]:::oper

    FACT_APP["Fact Securities Offering Application
(PENDING — chờ Silver TTHC)"]:::pending
    DIM_DATE2["Calendar Date Dimension
(reuse — PENDING)"]:::pending
    DIM_COMP2["Public Company Dimension
(reuse — PENDING)"]:::pending

    DIM_DATE --> FACT_OFF
    DIM_COMPANY --> FACT_OFF
    DIM_INDUSTRY --> FACT_OFF

    DIM_DATE2 --> FACT_APP
    DIM_COMP2 --> FACT_APP
```

### Bảng Phân tích (Star Schema)

| Bảng | Pattern | Grain | KPI | Trạng thái |
|---|---|---|---|---|
| Fact Securities Offering | Event | 1 đợt chào bán × 1 công ty đại chúng | K_QLCB_1–2, 4–16 | READY |

### Bảng Tác nghiệp (Denormalized)

| Bảng | Grain | KPI | Trạng thái |
|---|---|---|---|
| Securities Offering 360 Profile | 1 đợt chào bán (latest state) | K_QLCB_17–26, 28–49 | READY (một phần — K_QLCB_19–22 PENDING TTHC, K_QLCB_29 PENDING logins) |
| Individual 360 Profile | 1 cá nhân (latest state — nested roles, CCHN, lịch sử công tác, vi phạm) | K_QLCB_50–79 | READY (một phần — xem O_QLCB_6–9) |

### Dimension

| Dimension | Loại | Mô tả | Trạng thái |
|---|---|---|---|
| Calendar Date Dimension | Conformed | Lịch ngày — tĩnh / generated | READY |
| Public Company Dimension | Reference SCD2 | Công ty đại chúng — IDS.company_profiles. Chứa mã CK + Industry Category | READY |
| Industry Category Dimension | Conformed SCD2 | Nhóm ngành — ETL extract từ Public Company.Industry Category Level1/Level2 Code (IDS). Tái sử dụng cross-module | READY |

---

## Section 4 — Vấn đề mở

| ID | Vấn đề | Giả định hiện tại | KPI liên quan | Trạng thái |
|---|---|---|---|---|
| O_QLCB_1 | **Mapping Loại hình phát hành:** Silver `Public Company Securities Offering` không có field `offering_type_category` thống nhất — các loại hình lưu dưới dạng nhiều cặp field riêng biệt (`plan_public_company_qty`, `plan_single_qty`, `plan_dividend_qty`, `plan_bonus_share_qty`, `plan_owner_qty`...). | BA đồng ý ETL derived từ Silver — ETL sinh `Offering Type Category Code` từ field `planned_qty` cao nhất. Scheme: `QLCB_OFFERING_TYPE_CATEGORY`. | K_QLCB_4–16 | **Closed** |
| O_QLCB_2 | **KPI nguồn TTHC:** 4 KPI trong Nhóm 4 (Đơn vị tư vấn, Tổ chức kiểm toán, Đơn vị bảo lãnh, Đơn vị XHTN) có nguồn TTHC — không có TTHC_Source_Analysis.md trong project knowledge. Không thể xác định Silver entity, tên bảng nguồn hay field tương ứng. | Đánh dấu PENDING, giữ placeholder NULL trong `Securities Offering 360 Profile`. ETL bổ sung sau khi có Silver TTHC. | K_QLCB_19–22 | **Open** |
| O_QLCB_3 | **Ngày làm FK date trên Fact:** Silver `Public Company Securities Offering` có 3 trường ngày: `certificate_issue_date` (ngày cấp GCN chào bán), `offering_start_date` (ngày chào bán chứng khoán), `ssc_official_doc_date` (ngày ra công văn UBCKNN). Cần xác định ngày nào là FK date chính trên Fact phục vụ lọc theo kỳ. | BA xác nhận: FK date chính = `certificate_issue_date` (ngày cấp GCN chào bán) → `Certificate Issue Date Dimension Id`. `offering_start_date` và `ssc_official_doc_date` lưu thêm trên Fact/Tác nghiệp nhưng không làm FK date chính. | K_QLCB_1–16 | **Closed** |
| O_QLCB_4 | **Toàn bộ Tab Hồ sơ đăng ký chào bán (STT 29–39) nguồn TTHC:** 11 KPI gồm 3 Nhóm (KPI Cards, donut chart, bảng chi tiết hồ sơ) đều có nguồn TTHC — không có TTHC_Source_Analysis.md. Không tìm thấy Silver entity nào lưu trạng thái hồ sơ đăng ký chào bán trong `silver_attributes.csv`. Khi có Silver TTHC, cần thiết kế thêm: `Fact Securities Offering Application` (Event, grain = 1 hồ sơ × 1 ngày nộp), `Calendar Date Dimension` (reuse), `Public Company Dimension` (reuse). | Đánh dấu PENDING toàn bộ tab. Không thiết kế mart khi chưa có Silver LLD. | K_QLCB_28–38 | **Open** |
| O_QLCB_5 | **Chuyên viên và Giá/Đối tượng/SL NLĐ per hình thức:** (a) "Chuyên viên" = `Created By Login Name` (IDS.company_securities_issuance.created_by) — BA xác nhận dùng field này. Lưu ý giá trị là login_name kỹ thuật, không phải tên đầy đủ. ETL lấy trực tiếp, hiển thị login_name. (b) "Giá (cấp phép/thực tế)", "Số lượng NLĐ", "Đối tượng" không có field tổng hợp trên Silver — ETL pick theo `Offering Type Category Code` chính (O_QLCB_1 đã Closed). | (a) READY — map `Created By Login Name`, hiển thị login_name. (b) ETL pick theo Offering Type Category Code chính. | K_QLCB_29, K_QLCB_40, K_QLCB_42–43, K_QLCB_46, K_QLCB_48–49 | **Closed** |
| O_QLCB_6 | **Ngày hết hạn CCHN (K_QLCB_63):** BA xác nhận map về `CertificateRecords.RevocationDate` (ngày bị thu hồi chứng chỉ). | Map về `Securities Practitioner License Certificate Document.Revocation Date` — NHNCK.CertificateRecords.RevocationDate. | K_QLCB_63 | **Closed** |
| O_QLCB_7 | **Thông tin kiểm toán viên — QĐ đình chỉ (K_QLCB_70):** K_QLCB_69 (quá trình công tác) đã map về `Auditor Approval.Audit Firm Code` tại thời điểm chấp thuận. K_QLCB_70 (QĐ đình chỉ) cần xác nhận logic với BA — có thể join `Audit Firm Sanction` (IDS.af_sanctions) theo `Auditor Approval Id` nhưng cần BA confirm business rule. | K_QLCB_69 READY. K_QLCB_70 PENDING chờ BA. | K_QLCB_70 | **Open — chờ BA** |
| O_QLCB_8 | **Lịch sử công tác — Từ ngày/Đến ngày (K_QLCB_73):** SCMS `Securities Company Senior Personnel` có `Created Timestamp` (ngày tạo, không phải ngày bắt đầu công tác) và `Resignation Date`. IDS `Stock Holder` có `Ownership Date` (ngày đặt tỷ lệ sở hữu, không phải ngày bắt đầu giữ chức vụ). Không có field `start_date` tường minh cho lịch sử công tác. | Chờ trao đổi BA — cần xác nhận field nào dùng làm ngày bắt đầu công tác hoặc bổ sung Silver attribute. | K_QLCB_73 | **Open — chờ BA** |
| O_QLCB_9 | **Tra cứu vi phạm cá nhân cross-module (K_QLCB_75–79):** Silver `Surveillance Enforcement Case.Subject Full Name` (GS_HO_SO.TEN_DOI_TUONG) là text tự do — không FK sang CCCD cá nhân. Tương tự `Inspection Case.Subject Full Name` (TT_HO_SO). ETL phải resolve cá nhân qua text matching tên + CCCD. Rủi ro match sai nếu trùng tên. | Chờ trao đổi BA — cần xác nhận cơ chế resolve cá nhân. | K_QLCB_75–79 | **Open — chờ BA** |