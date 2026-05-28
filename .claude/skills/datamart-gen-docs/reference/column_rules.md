# Quy tắc các cột bảng thuộc tính (C.4)

## Cột P/F Key

| Giá trị `key` trong Attributes.csv | Ghi vào tài liệu |
|---|---|
| PK | P |
| FK → ... (bất kỳ) | F |
| BK | rỗng |
| DD | rỗng |
| rỗng | rỗng |

## Cột Nullable

| Điều kiện | Giá trị |
|---|---|
| `key` = PK hoặc FK → ... | rỗng (NOT NULL — không cần đánh X) |
| `nullable` = true | X |
| `nullable` = false | rỗng |

## Cột Unique

| Điều kiện | Giá trị |
|---|---|
| `key` = PK | X |
| Còn lại | rỗng |

## Cột Giá trị mặc định

Luôn để **trống hoàn toàn** — không điền bất kỳ giá trị nào.

## Cột Silver Table và Silver Field Name

3 trường kỹ thuật (xem bên dưới) → **để trống**
`source_entity` = `Generated` hoặc rỗng → **để trống**
Còn lại:
- Silver Table = lấy `source_entity`
- Silver Field Name = lấy `source_attribute`

## Cột ETL Rules

| Điều kiện | Giá trị |
|---|---|
| 3 trường kỹ thuật | `ETL sinh tự động` |
| `source_entity` = `Generated` hoặc rỗng | `ETL sinh tự động` |
| Còn lại | `SM1:1` |

> **Không dùng** `ETL derived` — chỉ dùng `SM1:1` hoặc `ETL sinh tự động`.

## 3 trường kỹ thuật (áp dụng quy tắc trên)

| Tên logical |
|---|
| Effective Date |
| Expiry Date |
| Population Date |

## Ví dụ áp dụng

| gold_attribute | key | nullable | source_entity | P/F Key | Nullable | Unique | Silver Table | ETL Rules |
|---|---|---|---|---|---|---|---|---|
| Inspection Case Activity Id | PK | false | Generated | P | rỗng | X | rỗng | ETL sinh tự động |
| Received Date Dimension Id | FK → Calendar Date Dimension | false | Inspection Case | F | rỗng | rỗng | Inspection Case | SM1:1 |
| Inspection Case Code | DD | true | Inspection Case | rỗng | X | rỗng | Inspection Case | SM1:1 |
| Effective Date | — | false | Generated | rỗng | rỗng | rỗng | rỗng | ETL sinh tự động |
| Population Date | — | false | Generated | rỗng | rỗng | rỗng | rỗng | ETL sinh tự động |
