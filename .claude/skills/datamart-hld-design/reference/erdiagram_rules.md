# erDiagram Rules — Star Schema

## Cú pháp bắt buộc

```
✅ Đúng:
```mermaid
erDiagram
    ...
```

❌ Sai:
```erDiagram
    ...
```
```

Thiếu `mermaid` → render thành plain text trên mọi renderer.

---

## Types hợp lệ

| Dùng | Không dùng |
|---|---|
| `int` | `decimal`, `decimal(23,2)` |
| `float` | `timestamp` |
| `string` | `nvarchar` |
| `varchar` | `bigint`, `smallint` |
| `boolean` | |
| `date` | |
| `datetime` | |

---

## Key Labels — chỉ 2 label hợp lệ: `PK` và `FK`

| Label | Dùng ở đâu | Điều kiện |
|---|---|---|
| `PK` | Dimension, Tác nghiệp | Surrogate key của entity |
| `FK` | **Chỉ** Fact entity block | Phải có `\|\|--o{` tương ứng |
| (trống) | Mọi attribute còn lại | Measure, Classification Value, date, boolean, DD, metadata |

❌ `NK`, `BK`, `DD` — không bao giờ xuất hiện trong erDiagram.
❌ `FK` không được gắn cho Classification Value field, date field, hay measure.
❌ `FK` trên Dimension hoặc Tác nghiệp → parse error.

---

## Tên entity và tên cột

**Tên entity:** dùng underscore, không dấu cách.
```
✅ Fund_Management_Company_Snapshot
❌ Fund Management Company Snapshot
```

**Tên cột:** Title_Case_With_Underscore.
```
✅ Snapshot_Date_Dimension_Id
✅ Investment_Fund_Count
❌ snapshot_date_dimension_id   (snake_case — chỉ dùng ở physical layer)
❌ SnapshotDateDimensionId      (PascalCase — không dùng)
```

---

## Quan hệ FK

Mỗi `FK` trong Fact block **bắt buộc** có đường quan hệ tương ứng:
```
Calendar_Date_Dimension ||--o{ Fact_FMS_Snapshot : " "
```

Label quan hệ: `" "` (space) — không để trống, không viết text.

---

## Không thiết kế trong erDiagram

Các trường sau do ETL tự quản lý — không đưa vào schema Datamart:
- `Effective Date`
- `Expiry Date`
- `Population Date`
- `Snapshot Date` → thay bằng `FK Snapshot_Date_Dimension_Id → Calendar Date Dimension`

---

## Nhất quán toàn file HLD

**Quy tắc quan trọng:** Mỗi bảng Datamart phải có **số trường và tên trường giống hệt nhau** ở mọi erDiagram trong toàn file HLD.

Ví dụ: nếu `Fact_FMS_Snapshot` có 5 trường ở Section 2 Nhóm 1, thì ở Section 2 Nhóm 2 và Section 3 cũng phải đúng 5 trường đó — không thêm, không bớt.

---

## Ví dụ erDiagram đúng

```mermaid
erDiagram
    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date NK
        int Year
        int Quarter
        int Month
        boolean Is_Weekend
        string Holiday_Name
    }
    Fund_Management_Company_Dimension {
        string Fund_Management_Company_Dimension_Id PK
        string Company_Code NK
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
