# DTM_QLCB_Entities — Star Schema per nhóm báo cáo

**Module:** QLCB — Quản lý Chào bán  
**Ngày:** 07/05/2026

---

## Nhóm 1–3: Phân tích chào bán phát hành theo ngành / loại hình

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Securities_Offering : "SSC Official Document Date Dimension Id"
    Public_Company_Dimension ||--o{ Fact_Securities_Offering : "Public Company Dimension Id"
    Industry_Category_Dimension ||--o{ Fact_Securities_Offering : "Industry Category Dimension Id"
```

| Datamart entity | Description | Grain | KPI |
|---|---|---|---|
| Fact Securities Offering | Event chào bán/phát hành CK — lưu 6 cột per-type Amount/Quantity | 1 row = 1 đợt chào bán × 1 công ty đại chúng | K_QLCB_1–2, 4–16 |
| Public Company Dimension | Công ty đại chúng — mã CK / tên / ngành / sàn (SCD2) | 1 công ty đại chúng | — |
| Industry Category Dimension | Nhóm ngành — ETL-derived Conformed Dim | 1 ngành cấp 1 × 1 ngành cấp 2 (SCD2) | — |
| Calendar Date Dimension | Lịch ngày | 1 ngày | — |

---

## Nhóm 4 + Nhóm 8–11: Tra cứu chi tiết đợt chào bán (Tác nghiệp — Pivot)

```mermaid
erDiagram
    Securities_Offering_360_Profile {
        varchar Securities_Offering_Code PK
        varchar Offering_Type_Category_Code PK
        string Public_Company_Code
        string Public_Company_Name
        string Equity_Ticker
        varchar Security_Type_Code
        int Planned_Offering_Quantity
        float Planned_Offering_Amount
        string Planned_Offering_Target
        int Planned_Offering_Employee_Quantity
        int Actual_Offering_Quantity
        float Actual_Offering_Amount
        string Actual_Offering_Target
        int Actual_Offering_Employee_Quantity
        string Certificate_Number
        date Certificate_Issue_Date
        string SSC_Official_Document_Number
        date SSC_Official_Document_Date
        date Offering_Start_Date
        date Offering_End_Date
        boolean Multi_Offering_Flag
        string Created_By_Login_Name
        string Capital_Usage_Plan
        datetime Population_Date
    }
```

| Datamart entity | Description | Grain | KPI |
|---|---|---|---|
| Securities Offering 360 Profile | Hồ sơ 360° đợt chào bán — pivot theo loại hình. Composite PK: (Securities Offering Code, Offering Type Category Code) | 1 row = 1 đợt × 1 loại hình có qty > 0 (PUBLIC/PRIVATE/ESOP/DIVIDEND/OWNER_CAPITAL/OTHER) | K_QLCB_17–27, 28–49 |

---

## Nhóm 5–7: Hồ sơ đăng ký chào bán (PENDING — TTHC)

> Toàn bộ PENDING — chờ Atomic TTHC. Không có star schema thiết kế tại thời điểm này.

| Datamart entity | Description | Grain | KPI | Trạng thái |
|---|---|---|---|---|
| Fact Securities Offering Application | Event hồ sơ đăng ký chào bán | 1 hồ sơ × 1 ngày nộp | K_QLCB_28–38 (PENDING) | PENDING — chờ Atomic TTHC |
| Calendar Date Dimension | Lịch ngày (reuse) | 1 ngày | — | PENDING |
| Public Company Dimension | Công ty đại chúng (reuse) | 1 công ty (SCD2) | — | PENDING |
