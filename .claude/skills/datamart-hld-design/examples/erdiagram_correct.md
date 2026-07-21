# erDiagram — Format đúng

## Ví dụ 1: Star Schema Fact Snapshot + 2 Dimension

```mermaid
erDiagram
    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Is_Weekend
        string Holiday_Name
    }
    Fund_Management_Company_Dimension {
        string Fund_Management_Company_Dimension_Id PK
        string Company_Code
        string Company_Name
        string Life_Cycle_Status_Code
    }
    Fact_Fund_Management_Company_Snapshot {
        string Snapshot_Date_Dimension_Id FK
        string Fund_Management_Company_Dimension_Id FK
        int Investment_Fund_Count
        float Total_Asset_Under_Management
    }
    Calendar_Date_Dimension ||--o{ Fact_Fund_Management_Company_Snapshot : " "
    Fund_Management_Company_Dimension ||--o{ Fact_Fund_Management_Company_Snapshot : " "
```

**Đặc điểm đúng:**
- Mở bằng ` ```mermaid ` — có từ `mermaid`
- Types hợp lệ: `string`, `date`, `int`, `float`, `boolean`
- `PK` chỉ trên Dimension; `FK` chỉ trên Fact và có `||--o{` tương ứng
- Không có `BK` trong erDiagram (BK chỉ ghi trong Attributes CSV)
- Tên entity dùng underscore: `Fund_Management_Company_Dimension`
- Tên cột dùng Title_Case: `Snapshot_Date_Dimension_Id`
- Label quan hệ: `" "` (space)
- Không có `Effective_Date`, `Expiry_Date`, `Population_Date`

---

## Ví dụ 2: Bảng Tác nghiệp

```mermaid
erDiagram
    Foreign_Investor_360_Profile {
        string Investor_Id PK
        string Investor_Code
        string Investor_Name
        string Investor_Type_Code
        string Nationality_Code
        string Custodian_Bank_Code
        string Custodian_Bank_Name
        string Life_Cycle_Status_Code
        datetime Created_Timestamp
    }
```

**Đặc điểm đúng:**
- Bảng Tác nghiệp: có `PK`, không có `FK` (không join sang Dimension)
- Không có quan hệ `||--o{` vì Tác nghiệp độc lập
- Không có `BK` — chỉ `PK`, còn lại trống
