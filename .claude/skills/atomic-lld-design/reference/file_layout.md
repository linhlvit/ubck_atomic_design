# File Layout — LLD outputs

## File LLD do người thiết kế tạo

| File | Vai trò | Encoding |
|---|---|---|
| `DataModel/working/Atomic/lld/{SOURCE}/lld_{SOURCE}_{table}.yaml` | Attribute mapping cho 1 bảng nguồn | UTF-8 |

## File config / metadata (DataModel/working/Atomic/lld/)

| File | Vai trò | Encoding |
|---|---|---|
| `DataModel/working/Atomic/lld/manifest.yaml` | Mapping `(source_system, source_table) → (atomic_entity, group, lld_file)` | UTF-8 |
| `DataModel/working/Atomic/lld/classification_schemes.yaml` | Danh mục Classification Value scheme toàn dự án | UTF-8 |
| `DataModel/working/Atomic/lld/pending_design.yaml` | Cột nguồn pending decision (reason + action) | UTF-8 |

## File auto-generated bởi script

| File | Sinh bởi | Source-of-truth |
|---|---|---|
| `DataModel/working/Atomic/aggregate/atomic_attributes.yaml` | `aggregate_atomic.py` | manifest.yaml + tất cả lld_*.yaml |
| `DataModel/working/Atomic/hld/atomic_entities.yaml` | `aggregate_atomic.py` | manifest.yaml + atomic_entities.yaml (description preserve) |
| `DataModel/Atomic/dm_manifest.yaml` | `gen_summary_and_model.py` | tất cả `dm_atm_*.yaml` trong `DataModel/Atomic/` |
| `DataModel/atomic_model.yaml` | `gen_summary_and_model.py` | tất cả `dm_atm_*.yaml` trong `DataModel/Atomic/` |

## Cấu trúc file lld_*.yaml (Level 1 per source table)

```yaml
schema_type: lld_source_table
schema_version: "2.0"

metadata:
  source_system: NHNCK
  source_table: PROFESSIONALS
  atomic_entity: Securities Practitioner
  entity_physical_name: securities_practitioner   # copy từ atomic_entities.yaml, không tự tính
  bcv_core_object: Involved Party
  group: T1
  design_status: draft   # draft | reviewed | approved

attributes:
  - attribute_name: Securities Practitioner Id
    physical_name: securities_practitioner_id  # auto-patch bởi transform_physical_names.py
    data_type: string                  # auto-patch bởi transform_physical_names.py
    description: Khóa đại diện (surrogate key).
    data_domain: Surrogate Key
    nullable: false
    is_primary_key: true
    status: draft
    source_columns: []
    comment: null
    classification_context: null
    etl_derived_value: null
```

- `physical_name` và `data_type`: auto-patch bởi `transform_physical_names.py` — không điền tay.
- `etl_derived_value`: để null nếu không có giá trị ETL-derived cố định.
- `classification_context` format: `SCHEME=VALUE`. Script `aggregate_atomic.py` tự convert sang format output `Field Name = 'VALUE'` khi ghi vào `atomic_attributes.yaml`.

## Cấu trúc atomic_attributes.yaml (aggregate output)

Path: `DataModel/working/Atomic/aggregate/atomic_attributes.yaml`  
Flat list (1 entry = entity × attribute × source × context):

```yaml
schema_type: atomic_attributes
schema_version: "1.0"

attributes:
  - bcv_core_object: Involved Party
    atomic_entity: Securities Practitioner
    atomic_table: securities_practitioner
    atomic_attribute: Securities Practitioner Id
    atomic_column: securities_practitioner_id
    description: "Khóa đại diện (surrogate key)."
    data_domain: Surrogate Key
    data_type: bigint
    nullable: false
    is_primary_key: true
    source_system: NHNCK
    source_table: PROFESSIONALS
    source_column: null
    comment: null
    classification_context: null
    etl_derived_value: null
```

## Encoding chuẩn

File YAML dùng **UTF-8** (không BOM). File CSV còn lại dùng **UTF-8 with BOM** (`utf-8-sig`).

Sau Write/Edit nếu cần kiểm tra/strip BOM dư thừa, dùng:

```bash
python DataModel/working/Atomic/lld/scripts/strip_bom.py {path}
```

## Cấu trúc manifest.yaml

```yaml
schema_type: manifest
schema_version: "1.0"

entries:
  - source_system: NHNCK
    source_table: PROFESSIONALS
    atomic_entity: Securities Practitioner
    group: T1
    lld_file: NHNCK/lld_NHNCK_PROFESSIONALS.yaml
```

- `atomic_entity`: phải khớp với `atomic_entities.yaml`.
- `group`: tier nhóm (`T1`, `T2`, `T3`, `T4`, hoặc `pending`).
- `lld_file`: đường dẫn tương đối so với `DataModel/working/Atomic/lld/`.

## Cấu trúc classification_schemes.yaml

```yaml
schema_type: classification_scheme_registry
schema_version: "1.0"

schemes:
  - scheme_code: IP_ADDR_TYPE
    name: null
    source_type: etl_derived   # etl_derived | source_table | modeler_defined
    source_table: null
    used_in_entities:
      - IP Postal Address
    values:
      - code: ADDRESS
        name: Địa chỉ chung (không phân biệt loại)
        source_table: null
```

3 loại `source_type`:
- `etl_derived`: team tự định nghĩa → liệt kê đầy đủ code + name trong `values[]`.
- `source_table`: values load từ bảng danh mục nguồn → để `values: []`, ghi `source_table`.
- `modeler_defined`: trường text nguồn cần chuẩn hóa, chưa profile → liệt kê các code đã biết hoặc để rỗng.

## Cấu trúc pending_design.yaml

```yaml
schema_type: pending_design_registry
schema_version: "1.0"

entries:
  - source_system: NHNCK
    source_table: Departments
    source_column: Id
    description: PK nguồn của Departments
    reason: BK dùng DepartmentCode thay Id — Id là PK kỹ thuật, không có giá trị nghiệp vụ riêng. Out-of-scope.
    action: Xác nhận out-of-scope — không map, không cần SKIP_COLUMNS toàn cục vì PK này đặc thù NHNCK
```

- `source_column`: tên cột pending (hoặc `(all)` nếu cả bảng).
- `reason`: lý do không map vào Atomic — phải đủ rõ để reviewer hiểu không cần xem source.
- `action`: hành động tiếp theo hoặc kết luận cuối cùng.
