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

Các trường kỹ thuật SCD4A / audit (xem bên dưới) → **để trống**
`source_entity` = `Generated` hoặc rỗng → **để trống**
Còn lại:
- **Schema.Table**: `ATM.{atomic_table}` (schema cố định `ATM` = Atomic)
- **Source Field Name**: lấy `atomic_column` từ Attributes.csv

## Cột Hệ thống nguồn

- Lookup `(atomic_table, atomic_column)` ➔ `source_system` từ `DataModel/working/Atomic/aggregate/atomic_attributes.yaml`
- Các trường kỹ thuật SCD4A / audit hoặc `source_entity` = `Generated` / rỗng → **để trống**

## Cột ETL Rules

| Điều kiện | Giá trị |
|---|---|
| Các trường kỹ thuật SCD4A / audit | `ETL sinh tự động` |
| `source_entity` = `Generated` hoặc rỗng | `ETL sinh tự động` |
| Còn lại | Lấy `etl_logic` từ file `Attributes.csv` |

## Bộ 5 trường kỹ thuật SCD4A mặc định (và trường audit legacy)

### 1. Bộ 5 trường kỹ thuật chuẩn SCD4A:
| Tên logical | Tên physical | Mô tả |
|---|---|---|
| Record Status | ds_rcrd_st | Trạng thái bản ghi ('ACTIVE' / 'INACTIVE') |
| Record Insert Date | ds_rcrd_isrt_dt | Ngày insert lần đầu |
| Record Update Date | ds_rcrd_udt_dt | Ngày update gần nhất |
| ETL Process Timestamp | ds_etl_pcs_tms | Timestamp xử lý ETL |
| Snapshot Date | ds_snpst_dt | Ngày snapshot (chỉ có ở bảng History) |

### 2. Các trường audit legacy (nếu có trong bảng cũ):
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
| ds_rcrd_st | — | false | Generated | rỗng | rỗng | rỗng | rỗng | rỗng | rỗng | rỗng | ETL sinh tự động |
| ds_rcrd_isrt_dt | — | false | Generated | rỗng | rỗng | rỗng | rỗng | rỗng | rỗng | rỗng | ETL sinh tự động |
| ds_rcrd_udt_dt | — | false | Generated | rỗng | rỗng | rỗng | rỗng | rỗng | rỗng | rỗng | ETL sinh tự động |
| ds_etl_pcs_tms | — | false | Generated | rỗng | rỗng | rỗng | rỗng | rỗng | rỗng | rỗng | ETL sinh tự động |
| eff_dt | — | false | Generated | rỗng | rỗng | rỗng | rỗng | rỗng | rỗng | rỗng | ETL sinh tự động |
| ppl_dt | — | false | Generated | rỗng | rỗng | rỗng | rỗng | rỗng | rỗng | rỗng | ETL sinh tự động |
