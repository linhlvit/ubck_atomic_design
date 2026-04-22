# File Layout — LLD outputs

## File LLD do người thiết kế tạo

| File | Vai trò | Encoding |
|---|---|---|
| `Silver/lld/{SOURCE}/attr_{SOURCE}_{table}.csv` | Attribute mapping cho 1 bảng nguồn | UTF-8 with BOM (`utf-8-sig`) |

## File config / metadata (Silver/lld/)

| File | Vai trò | Encoding |
|---|---|---|
| `Silver/lld/manifest.csv` | Mapping `(source_system, source_table) → (silver_entity, group, lld_file)` | UTF-8 with BOM |
| `Silver/lld/ref_shared_entity_classifications.csv` | Danh mục Classification Value scheme toàn dự án | UTF-8 with BOM |
| `Silver/lld/pending_design.csv` | Cột nguồn pending decision (reason + action) | UTF-8 with BOM |

## File auto-generated bởi script

| File | Sinh bởi | Source-of-truth |
|---|---|---|
| `Silver/lld/silver_attributes.csv` | `aggregate_silver.py` | manifest.csv + tất cả attr_*.csv |
| `Silver/hld/silver_entities.csv` | `aggregate_silver.py` | manifest.csv + silver_entities.csv (description preserve) |

## Cấu trúc file attr_*.csv (10 cột)

```
attribute_name,description,data_domain,nullable,is_primary_key,status,source_columns,comment,classification_context,etl_derived_value
```

- `etl_derived_value`: để rỗng nếu không có giá trị ETL-derived cố định.
- `classification_context` format nội bộ: `SCHEME=VALUE`. Script `aggregate_silver.py` tự convert sang format output `Field Name = 'VALUE'` khi ghi vào `silver_attributes.csv`.

## Encoding chuẩn

Mọi file CSV trong dự án dùng **UTF-8 with BOM** (`utf-8-sig` trong Python). Lý do: Excel/Windows tool nhận diện đúng tiếng Việt khi mở trực tiếp; script Python đọc với `utf-8-sig` strip BOM tự động.

Sau Write/Edit nếu cần kiểm tra/strip BOM dư thừa (VD: file bị ghi 2 lần BOM), dùng:

```bash
python Silver/lld/scripts/strip_bom.py {path}
```

## Cấu trúc manifest.csv

```
source_system,source_table,silver_entity,group,lld_file
```

- `silver_entity`: tên Silver entity đích — phải khớp với `silver_entities.csv`.
- `group`: tier nhóm (`T1`, `T2`, `T3`, `T4`, hoặc `pending`).
- `lld_file`: tên file `attr_*.csv` tương ứng.

## Cấu trúc ref_shared_entity_classifications.csv

```
scheme_code,code,name,source_type,source_table,used_in_entities
```

3 loại `source_type`:
- `etl_derived`: team tự định nghĩa → liệt kê đầy đủ code + name.
- `source_table`: values load từ bảng danh mục nguồn → ghi `(source)` ở cột code, ghi source table.
- `modeler_defined`: trường text nguồn cần chuẩn hóa, chưa profile → ghi `(to_define)`.

## Cấu trúc pending_design.csv

```
source_system,source_table,source_column,description,reason,action
```

- `source_column`: tên cột pending (hoặc `(all)` nếu cả bảng).
- `reason`: lý do không map vào Silver hiện tại.
- `action`: hành động cần làm hoặc trạng thái xử lý.
