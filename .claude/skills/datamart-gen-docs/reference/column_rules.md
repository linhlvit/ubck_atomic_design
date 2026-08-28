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

## Cột Schema.Table và Source Field Name

3 trường kỹ thuật (xem bên dưới) → **để trống**
`source_entity` = `Generated` hoặc rỗng → **để trống**
Còn lại:
- **Schema.Table**: `ATM.{atomic_table}` (schema cố định `ATM` = Atomic)
- **Source Field Name**: lấy `atomic_column` từ Attributes.csv

## Cột Hệ thống nguồn

- Lookup `(atomic_table, atomic_column)` ➔ `source_system` từ `DataModel/working/Atomic/aggregate/atomic_attributes.yaml`
- 3 trường kỹ thuật hoặc `source_entity` = `Generated` / rỗng → **để trống**

## Cột ETL Rules

| Điều kiện | Giá trị |
|---|---|
| 3 trường kỹ thuật | `ETL sinh tự động` |
| `source_entity` = `Generated` hoặc rỗng | `ETL sinh tự động` |
| Còn lại | Lấy `etl_logic` từ file `Attributes.csv` |

## 3 trường kỹ thuật (áp dụng quy tắc trên)

| Tên logical | Tên physical |
|---|---|
| Effective Date | eff_dt |
| Expiry Date | expr_dt |
| Population Date | ppl_dt |

## Ví dụ áp dụng bảng Physical (12 cột)

| gold_column | key | nullable | source_entity | P/F Key | Nullable | Unique | Giá trị mặc định | Hệ thống nguồn | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| fct_inspection_case_avy_id | PK | false | Generated | P | rỗng | X | rỗng | rỗng | rỗng | rỗng | ETL sinh tự động |
| rcvd_dt_dim_id | FK | false | Inspection Case | F | rỗng | rỗng | rỗng | THANHTRA | ATM.inspection_case | rcvd_dt | inspection_case.rcvd_dt |
| inspection_case_code | DD | true | Inspection Case | rỗng | X | rỗng | rỗng | THANHTRA | ATM.inspection_case | inspection_case_code | inspection_case.inspection_case_code |
| eff_dt | — | false | Generated | rỗng | rỗng | rỗng | rỗng | rỗng | rỗng | rỗng | ETL sinh tự động |
| ppl_dt | — | false | Generated | rỗng | rỗng | rỗng | rỗng | rỗng | rỗng | rỗng | ETL sinh tự động |
