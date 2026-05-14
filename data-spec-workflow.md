# Data Specification Workflow — Data Lakehouse

## Tổng quan

File này mô tả **toàn bộ luồng quy trình** từ yêu cầu nghiệp vụ (BRD) → thiết kế dữ liệu (DM) → chuẩn bị triển khai (ETL/DDL/Deploy) cho kiến trúc Data Lakehouse (Medallion: Bronze/Atomic/Data Mart) trên Data Lakehouse.

**Ai dùng:** Data Modeler, Data Engineer (DE), BA, Quality Engineer (QE)  
**Mục đích:** Là kim chỉ nam khi triển khai dự án, quy định format artifact, tool hỗ trợ ở từng bước  
**Update:** Người dùng tự maintain theo tiến độ dự án. Thêm bước mới, cập nhật sample khi có thay đổi quy trình

---

## Luồng quy trình

```
┌─────────────────────────────────────────────────────────────────────────┐
│ 1. BRD (Business Requirements)                                          │
│    [AI-Prompt] → YAML files (BRD/Source/brd_*.yaml)                     │
│    + Schema validation (schemas/brd_source.schema.json)                 │
│    + Update Spec-Registry (KV Database trên Cloudflare)                 │
│    + Jira task creation (optional)                                      │
└─────────────────────────────────────────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ 2. Data Model (DM) — LDM + PDM gộp trong 1 file YAML                   │
│    [AI-Skill] → 1 file per (Atomic entity × source combo)               │
│    DataModel/Atomic/{BCV_Folder}/dm_atm_{table}-{SOURCE}.{TABLE}.yaml  │
│    + Entity header: id, bcv_core_object, table_type, etl_pattern        │
│    + Attributes: source mapping, data_domain, nullable, PK              │
│    + Schema validation (schemas/dm.schema.json)                         │
│    + Generate hàng loạt: DataModel/generate_dm_yaml.py                 │
└─────────────────────────────────────────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ 3. Mapping — Source-to-Atomic column mapping                            │
│    [Script/AI] → 1 YAML per (atomic_table × source combo)              │
│    Mapping/Atomic/{BCV_Folder}/mapping_atm_{table}-{SOURCE}.{TABLE}.yaml│
│    + header: pattern, etl_pattern, dm_ref, brd_ref                     │
│    + sections: target / input / relationship / mapping_columns / filter │
│    + 3 pattern: regular (JOIN) / unpivot (legs) / direct               │
│    + Schema validation: schemas/mapping.schema.json                     │
└─────────────────────────────────────────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ 4. DDL Generation & ETL Spec                                            │
│    [Manual / Code Gen] → Delta Lake schema, Spark/SQL ETL jobs          │
│    - Bronze ingest spec                                                 │
│    - Silver transformation spec (SCD4A, dedup, normalization)          │
│    - Gold aggregation spec                                              │
└─────────────────────────────────────────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ 5. Deploy & Validation                                                  │
│    [Manual] → Deploy on Databricks/Delta, unit & integration tests      │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 1. BRD — Business Requirements Documentation

### 1.1 Loại BRD

| Loại | Mã | Tool | Mục đích |
|------|---|------|---------|
| **Theo Source** | `BRD-SRC-{SOURCE}-{TABLE}` | AI-Prompt | Thiết kế Atomic layer từ bảng nguồn |
| **Theo Báo cáo** | `BRD-RPT-{RPT_CODE}` | AI-Prompt | Thiết kế Gold layer từ yêu cầu báo cáo |

### 1.2 Artifact & Thư mục

| Loại BRD | File location | Format |
|----------|---------------|--------|
| Theo Source | `BRD/Source/brd_{SOURCE}.yaml` | YAML (1 file per source) |
| Theo Báo cáo | `BRD/Reports/brd_{RPT_CODE}.yaml` | YAML (1 file per report) |

### 1.3 BRD Theo Source — Format YAML

**File:** `BRD/Source/brd_{SOURCE}.yaml`  
**Schema:** `schemas/brd_source.schema.json` (JSON Schema Draft-07)

**Cấu trúc:**

```yaml
source: ThanhTra
description: "Phân hệ Thanh tra — Quản lý hoạt động thanh tra, kiểm tra, xử lý vi phạm..."

brd_entries:
  - brd_id: BRD-SRC-ThanhTra-TT_KE_HOACH
    brd_name: "Design Atomic từ nguồn ThanhTra bảng TT_KE_HOACH"
    type: Theo Source
    ba_email: username@fssc.com.vn
    steward_email: username@ubck.com.vn
    content:
      table_meaning: "Kế hoạch thanh tra, kiểm tra hàng năm"
      functional_group: "B.1 Hoạt động thanh tra - kiểm tra"
      scope_status: in_scope
      scope_reason: null   # null nếu in_scope; ghi lý do nếu out_of_scope
      related_tables:
        - table: TT_KE_HOACH_DOI_TUONG
          relation: "1-N — đối tượng thanh tra trong kế hoạch"
        - table: TT_QUYET_DINH
          relation: "1-N — quyết định phát sinh từ kế hoạch"
      notes: null
      data_volume_hint: null   # static | small | medium | large | very_large
      refresh_frequency: null  # real_time | hourly | daily | weekly | monthly | ad_hoc | static
```

**Quy tắc:**
- Mỗi entry = 1 bảng nguồn
- `scope_status: in_scope` → bảng sẽ thiết kế trên Atomic layer
- `scope_status: out_of_scope` → ghi rõ lý do (VD: audit log, SCD2 kỹ thuật, config, Gold only)
- `related_tables` = danh sách bảng có FK, 1-N, hay shared entities

### 1.4 Validation & Tooling

**VS Code:** Cấu hình tại `.vscode/settings.json` → YAML realtime validation

```json
{
  "yaml.schemas": {
    "schemas/brd_source.schema.json": ["BRD/Source/brd_*.yaml"]
  }
}
```

**CLI validation:**

```bash
# Validate một file
ajv validate -s schemas/brd_source.schema.json -d "BRD/Source/brd_ThanhTra.yaml"

# Validate tất cả
for file in BRD/Source/brd_*.yaml; do
  ajv validate -s schemas/brd_source.schema.json -d "$file" && echo "OK $file" || echo "FAIL $file"
done
```

### 1.5 Từ BRD → Jira Task

**Cách 1: Jira API** — Tạo 1 task per BRD ID

```
Task title: [BRD-SRC-{SOURCE}-{TABLE}] Design Atomic — {table_meaning}
Description:
  - Source: {SOURCE}
  - Table: {TABLE}
  - Functional group: {functional_group}
  - Scope: {scope_status}
  - Related tables: {related_tables}
  - BA: {ba_email}
  - Steward: {steward_email}
```

**Cách 2: Spec Registry** — KV database (Cloudflare Workers KV)

- Primary Key: `BRD-ID`
- Value: Full BRD entry (JSON/YAML)
- Indexed by: `source`, `scope_status`, `functional_group`
- Query endpoint: `/api/brd/{brd_id}`

---

## 2. Data Model (DM)

DM gộp cả Logical Design (LDM) và Physical Design (PDM) trong **một file YAML duy nhất** per Atomic entity × source combo. Không có thư mục `PhysicalModel/` hay `LDM/` riêng biệt.

### 2.1 Granularity & Scope

- **Granularity:** 1 file per **(atomic_table × source_system × source_table)** — entity có nhiều source sẽ có nhiều file DM
- **Input:** BRD entries `in_scope` + `Atomic/lld/atomic_attributes.csv` + `Atomic/hld/atomic_entities.csv`
- **Output:** `DataModel/Atomic/{BCV_Folder}/dm_atm_{table}-{SOURCE}.{SRC_TABLE}.yaml`
- **Tool thiết kế:** AI-Skill (`atomic-hld-design`, `atomic-lld-design`)
- **Tool generate:** `DataModel/generate_dm_yaml.py`

### 2.2 Cấu trúc thư mục

```
DataModel/
  Atomic/
    Arrangement/          # 10 files
    Business_Activity/    # 56 files
    Common/               # 5 files
    Communication/        # 10 files
    Condition/            # 22 files
    Documentation/        # 40 files
    Event/                # 4 files
    Group/                # 6 files
    Involved_Party/       # 86 files
    Location/             # 76 files
    Product/              # 3 files
    Transaction/          # 11 files
  generate_dm_yaml.py     # script generate hàng loạt
```

Sub-folder = BCV Core Object (space → underscore, VD: `Involved Party` → `Involved_Party`).

### 2.3 File Naming

```
dm_atm_{physical_name}-{SOURCE}.{SRC_TABLE}.yaml
```

| Thành phần | Mô tả | Ví dụ |
|---|---|---|
| `dm_atm_` | Prefix cố định — Atomic Data Model | |
| `{physical_name}` | Tên bảng Atomic (snake_case) | `dscl_ahr` |
| `{SOURCE}` | Source system code | `FIMS` |
| `{SRC_TABLE}` | Tên bảng nguồn | `AUTHOANNOUNCE` |

**Ví dụ:** `dm_atm_dscl_ahr-FIMS.AUTHOANNOUNCE.yaml`

Entity có nhiều source combo → nhiều file riêng biệt:
- `dm_atm_mbr_prd_rpt-FMS.RPTMEMBER.yaml`
- `dm_atm_mbr_prd_rpt-SCMS.BC_THANH_VIEN.yaml`

### 2.4 DM YAML — Cấu trúc đầy đủ

**File:** `DataModel/Atomic/{BCV_Folder}/dm_atm_{table}-{SOURCE}.{SRC_TABLE}.yaml`  
**Schema:** `schemas/dm.schema.json` (JSON Schema Draft-07)

```yaml
schema_type: data_model
schema_version: "1.0"

ldm:
  # Định danh: ATM-{physical_name}-{SOURCE}.{SRC_TABLE}
  id: ATM-dscl_ahr-FIMS.AUTHOANNOUNCE

  # Tên đầy đủ
  logical_name: "Atomic - Disclosure Authorization – source FIMS.AUTHOANNOUNCE"

  # Tên bảng Delta Lake (snake_case)
  physical_name: dscl_ahr

  version: "1.0"

  # Trạng thái: draft | approved
  status: approved

  # BCV Core Object — enum 12 values
  # Arrangement | Business Activity | Common | Communication | Condition |
  # Documentation | Event | Group | Involved Party | Location | Product | Transaction
  bcv_core_object: Arrangement

  # BCV Concept chi tiết
  bcv_concept: "[Arrangement] Authorization"

  # Loại bảng — enum 5 values
  # Fundamental | Fact Append | Fact Snapshot | Relative | Classification
  table_type: Fundamental

  # ETL / Technical pattern — map từ table_type (system/rules/rule_map_technical_table_type.csv)
  # Fundamental → SCD4A | Relative → SCD2 | Fact Append → Fact Append |
  # Fact Snapshot → Fact Append | Classification → Upsert
  etl_pattern: SCD4A

  # Source system code
  source: FIMS

  description: |
    Ủy quyền công bố thông tin của người đại diện CBTT cho nhà đầu tư nước ngoài.
    Ghi nhận bên được ủy quyền, loại quan hệ và thời hạn hiệu lực.

  owner:
    steward: username@ubck.com.vn
    data_modeler: username@fssc.com.vn

  references:
    # Pattern: BRD-SRC-{SOURCE}-{SRC_TABLE}
    brd: BRD-SRC-FIMS-AUTHOANNOUNCE

attributes:
  - name: Disclosure Authorization Id       # Title Case — tên BCV attribute
    physical_name: dscl_ahr_id              # snake_case — tên cột Delta
    business_meaning: "Khóa đại diện cho ủy quyền CBTT."
    # data_domain — enum 14 values:
    # Text | Date | Timestamp | Currency Amount | Interest Rate | Exchange Rate |
    # Percentage | Surrogate Key | Classification Value | Indicator | Boolean |
    # Small Counter | Array<Text> | Array<Struct>
    data_domain: Surrogate Key
    # data_type — enum: string | date | timestamp | boolean | int |
    #   decimal(23,2) | decimal(5,2) | decimal(8,5) | array<string> | array<struct<...>>
    data_type: string
    nullable: false
    is_primary_key: true
    source_system: FIMS
    source_table: AUTHOANNOUNCE
    source_column: null                     # null nếu surrogate key hoặc derived
    comment: "PK surrogate."
    classification_context: "Source System Code = 'FIMS_AUTHOANNOUNCE'"
    etl_derived_value: null                 # null nếu map thẳng từ source

  - name: Relationship Type Code
    physical_name: rltnp_tp_code
    business_meaning: "Loại quan hệ ủy quyền."
    data_domain: Classification Value
    data_type: string
    nullable: true
    is_primary_key: false
    source_system: FIMS
    source_table: AUTHOANNOUNCE
    source_column: FIMS.AUTHOANNOUNCE.RelationshipId
    comment: "Scheme: FIMS_RELATIONSHIP_TYPE."
    classification_context: "Source System Code = 'FIMS_AUTHOANNOUNCE'"
    etl_derived_value: null
```

### 2.5 etl_pattern Mapping

Lấy từ `system/rules/rule_map_technical_table_type.csv`:

| table_type | etl_pattern |
|---|---|
| Fundamental | SCD4A |
| Relative | SCD2 |
| Fact Append | Fact Append |
| Fact Snapshot | Fact Append |
| Classification | Upsert |

### 2.6 Generate hàng loạt

Script `DataModel/generate_dm_yaml.py` đọc trực tiếp từ CSV và generate toàn bộ 329 files:

```bash
# Dry run — xem danh sách file sẽ tạo
python DataModel/generate_dm_yaml.py --dry-run

# Chạy thật — tạo/overwrite tất cả
python DataModel/generate_dm_yaml.py
```

**Input:** `Atomic/lld/atomic_attributes.csv`, `Atomic/hld/atomic_entities.csv`, `system/rules/rule_map_technical_table_type.csv`  
**Output:** `DataModel/Atomic/{BCV_Folder}/dm_atm_*.yaml` (1 file per table × source combo)

> Sau khi chỉnh sửa attribute trong CSV, chạy lại script để sync YAML. File đã chỉnh tay sẽ bị **overwrite** — lưu ý chỉ sửa CSV làm nguồn gốc.

### 2.7 Schema Validation

**VS Code** (realtime, `.vscode/settings.json`):

```json
{
  "yaml.schemas": {
    "schemas/brd_source.schema.json": ["BRD/Source/brd_*.yaml"],
    "schemas/dm.schema.json": ["DataModel/Atomic/dm_atm_*.yaml"]
  }
}
```

**CLI:**

```bash
# Validate một file
ajv validate -s schemas/dm.schema.json -d "DataModel/Atomic/Arrangement/dm_atm_dscl_ahr-FIMS.AUTHOANNOUNCE.yaml"

# Validate tất cả DM files
for file in DataModel/Atomic/**/*.yaml; do
  ajv validate -s schemas/dm.schema.json -d "$file" && echo "OK $file" || echo "FAIL $file"
done
```

### 2.8 Classification Value — File riêng

Nếu attribute có `data_domain: Classification Value`, tạo file CV riêng khi cần document giá trị:

**File:** `DataModel/cv_{CV_CODE}.yaml`

```yaml
classification_value:
  code: FIMS_RELATIONSHIP_TYPE
  name: "Relationship Type"
  description: "Loại quan hệ trong FIMS"
  values:
    - code: CHA_CON
      label: "Cha - Con"
    - code: VO_CHONG
      label: "Vợ - Chồng"
```

---

## 3. Mapping — Source-to-Atomic Column Mapping

Mapping là bước chuyển đổi cụ thể từng cột Bronze → Atomic, bao gồm transformation logic, join pattern, filter điều kiện. Output là file YAML có cấu trúc cố định dùng làm spec cho Data Engineer viết ETL job.

### 3.1 Granularity & Scope

- **Granularity:** 1 file per **(atomic_table × source_system × source_table)** — giống với DM YAML, 1 entity có nhiều source combo sẽ có nhiều file
- **Input:** DM YAML (`DataModel/Atomic/`) + `Mapping/registries/gm_atomic_entities.csv` + `gm_atomic_attributes.csv` + `gm_bronze_attributes.csv`
- **Output:** `Mapping/Atomic/{BCV_Folder}/mapping_atm_{table}-{SOURCE}.{SRC_TABLE}.yaml`
- **Schema:** `schemas/mapping.schema.json` (JSON Schema Draft-07)
- **Tool generate:** `Mapping/scripts/gen_mapping_atomic.py`

### 3.2 Cấu trúc thư mục

```
Mapping/
  Atomic/                     # Sub-folder per BCV Core Object — giống DataModel/Atomic/
    Arrangement/
    Business_Activity/
    Common/
    Communication/
    Condition/
    Documentation/
    Event/
    Group/
    Involved_Party/
    Location/
    Product/
    Transaction/
  rules/
    transformation_rules.yaml # Shared transformation rules — tra cứu bởi ETL generator
  registries/
    gm_atomic_entities.csv    # metadata entity: table_type, mapping_type, description
    gm_atomic_attributes.csv  # attributes: domain, source_column, transformation hints
    gm_bronze_attributes.csv  # bronze PK/FK info để auto-detect join condition
  scripts/
    gen_mapping_atomic.py     # script generate hàng loạt
```

### 3.3 File Naming

```
mapping_atm_{physical_name}-{SOURCE}.{SRC_TABLE}.yaml
```

| Thành phần | Mô tả | Ví dụ |
|---|---|---|
| `mapping_atm_` | Prefix cố định — Atomic Mapping | |
| `{physical_name}` | Tên bảng Atomic (snake_case) | `fnd_mgt_co` |
| `{SOURCE}` | Source system code | `FIMS` |
| `{SRC_TABLE}` | Tên bảng nguồn | `FUNDCOMPANY` |

**Ví dụ:**
- `mapping_atm_fnd_mgt_co-FIMS.FUNDCOMPANY.yaml` — regular pattern
- `mapping_atm_ip_alt_identn-FIMS.BANKMONI.yaml` — unpivot pattern (1 file per source table)

### 3.4 Cấu trúc YAML — 5 Section

Mỗi file mapping YAML có cấu trúc 5 section cố định:

```
Target     → Thông tin bảng đích (schema, table, etl_handle, description)
Input      → Danh sách bảng/CTE nguồn (physical_table, derived_cte, unpivot_cte)
Relationship → JOIN giữa các bảng/CTE nguồn
Mapping    → Map từng cột nguồn → cột đích (transformation, data type)
Final Filter → WHERE / GROUP BY / UNION ALL ở cuối transform
```

**Header của từng section:**

| Section | Cột key |
|---|---|
| Target | Database, Schema, Table Name, ETL Handle, Description |
| Input | #, Source Type, Schema, Table Name, Alias, Select Fields, Filter |
| Relationship | #, Main Alias, Join Type, Join Alias, Join On |
| Mapping | #, Target Column, Transformation, Data Type, Description |
| Final Filter | #, Clause Type, Expression, Description |

### 3.5 Hai loại Mapping Pattern

#### Pattern 1 — Regular (1 source, có JOIN)

Dùng khi entity map từ **1 bảng chính + các bảng phụ JOIN vào**. Input gồm `physical_table` và `derived_cte` (nếu có aggregate Array).

```csv
Target,Bảng đích,,,,,,,,,
Database,Schema,Table Name,ETL Handle,,,,Description,...
,atomic,Fund Management Company,SCD4A,,,,Công ty quản lý quỹ...

Input,Bảng / CTE nguồn,,,,,,,,,
#,Source Type,Schema,Table Name,Alias,Select Fields,Filter,...
1,physical_table,bronze,FUNDCOMPANY,fu_co,"id, name, capital, ...",data_date = ...
2,physical_table,bronze,FUNDCOMBUSINES,fu_bu_raw,"fundid, buid",data_date = ...
3,derived_cte,,fu_bu_raw,fu_bu,"fundid, array_agg(buid) AS business_type_codes",GROUP BY fundid

Relationship,Quan hệ giữa các bảng / CTE nguồn,,,,,,,,,
#,Main Alias,Join Type,Join Alias,Join On,...
1,fu_co,LEFT JOIN,fu_bu,fu_co.id = fu_bu.fundid

Mapping,Mapping trường nguồn → trường đích,,,,,,,,,
#,Target Column,Transformation,Data Type,,,,Description,...
1,fund_management_company_id,"hash_id('FIMS_FUNDCOMPANY', fu_co.id)",string,,,,Surrogate key
2,fund_management_company_code,fu_co.id,string,,,,BK từ PK bảng nguồn
3,source_system_code,'FIMS_FUNDCOMPANY',string,,,,Hardcode SSC

Final Filter,Điều kiện lọc của Main Transform,,,,,,,,,
#,Clause Type,Expression,...
```

**Input Source Types:**

| Source Type | Mô tả |
|---|---|
| `physical_table` | Bảng Bronze thực tế |
| `derived_cte` | CTE tính toán từ bảng khác (VD: `array_agg`, `GROUP BY`) |
| `unpivot_cte` | CTE LATERAL VIEW stack — dùng cho shared entity |

#### Pattern 2 — Shared Entity (multi-source, UNION ALL)

Dùng cho các entity gộp nhiều nguồn (IP Alt Identification, IP Postal Address, IP Electronic Address). Mỗi nguồn sinh 1 cặp `physical_table + unpivot_cte`, kết hợp bằng `UNION ALL` ở Final Filter.

```csv
Input,Bảng / CTE nguồn,,,,,,,,,
#,Source Type,Schema,Table Name,Alias,Select Fields,Filter,...
1,physical_table,bronze,BANKMONI,ba_mo,"id, idno, idadd, regno, regadd",data_date = ...
2,unpivot_cte,,ba_mo,leg_ba_mo,"id AS ip_code, type_code, address_value
LATERAL VIEW stack(4, 'IDNO', idno, 'IDADD', idadd, 'REGNO', regno, 'REGADD', regadd) AS (type_code, address_value)",address_value IS NOT NULL
3,physical_table,bronze,BRANCHS,br,"id, idno, idadd, regno, regadd",data_date = ...
4,unpivot_cte,,br,leg_br,"id AS ip_code, type_code, address_value
LATERAL VIEW stack(4, 'IDNO', ...) AS (type_code, address_value)",address_value IS NOT NULL
...

Relationship,Quan hệ giữa các bảng / CTE nguồn,,,,,,,,,
#,Main Alias,Join Type,Join Alias,Join On,...
(để trống — không JOIN, dùng UNION ALL)

Mapping,Mapping trường nguồn → trường đích,,,,,,,,,
#,Target Column,Transformation,...
1,involved_party_id,"hash_id('FIMS_BANKMONI', leg_ba_mo.ip_code); hash_id('FIMS_BRANCHS', leg_br.ip_code); ..."
2,involved_party_code,"leg_ba_mo.ip_code; leg_br.ip_code; ..."
3,source_system_code,"'FIMS_BANKMONI'; 'FIMS_BRANCHS'; ..."
4,identification_type_code,"leg_ba_mo.type_code; leg_br.type_code; ..."
5,identification_number,"leg_ba_mo.address_value; leg_br.address_value; ..."

Final Filter,Điều kiện lọc của Main Transform,,,,,,,,,
#,Clause Type,Expression,...
1,UNION ALL,"SELECT * FROM leg_ba_mo
UNION ALL
SELECT * FROM leg_br
..."
```

> Trong cột Transformation của Mapping section, các expression cách nhau bằng `; ` — mỗi phần tương ứng với 1 leg theo thứ tự trong Input section.

### 3.6 Transformation Conventions

| Pattern | Cú pháp | Ví dụ |
|---|---|---|
| Surrogate Key (PK) | `hash_id('{SSC}', alias.pk_col)` | `hash_id('FIMS_FUNDCOMPANY', fu_co.id)` |
| Surrogate Key (FK) | `hash_id('{target_SSC}', alias.fk_col)` | `hash_id('FIMS_NATIONAL', fu_co.naid)` |
| Source System Code | `'{SSC}'` (literal) | `'FIMS_FUNDCOMPANY'` |
| Direct map | `alias.column` | `fu_co.name` |
| Array aggregate | `alias.array_agg_col` (từ derived_cte) | `fu_bu.business_type_codes` |
| Chưa xác định | (để trống) | — |
| ETL date filter | `data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')` | Filter chuẩn cho mọi physical_table |

### 3.7 Registries — Nguồn dữ liệu cho generate

| File | Mô tả | Key columns |
|---|---|---|
| `gm_atomic_entities.csv` | Metadata entity-level | `atomic_entity`, `table_type`, `technical_table_type`, `mapping_type`, `source_table` |
| `gm_atomic_attributes.csv` | Metadata attribute-level | `atomic_entity`, `atomic_attribute`, `data_domain`, `source_column`, `classification_context` |
| `gm_bronze_attributes.csv` | Bronze PK/FK để auto-detect join | `table_name`, `column_name`, `pk/fk`, `description` |

`mapping_type` trong `gm_atomic_entities.csv`:
- `regular` — 1 source table, có JOIN
- `shared_entity` — multi-source, UNION ALL
- `cv` — Classification Value (placeholder, chưa implement)

### 3.8 Generate hàng loạt

```bash
# Generate tất cả
python Mapping/scripts/gen_mapping_atomic.py

# Generate 1 entity cụ thể
python Mapping/scripts/gen_mapping_atomic.py --entity "Fund Management Company"

# Generate tất cả entity của 1 source system
python Mapping/scripts/gen_mapping_atomic.py --source-system FIMS
```

> Script đọc từ registries, tự động detect join condition từ `gm_bronze_attributes.csv`, và sinh file YAML theo đúng template. Các transformation chưa xác định sẽ để `null` — Data Engineer tự điền sau.

### 3.9 Mapping YAML — Cấu trúc đầy đủ

**File:** `Mapping/Atomic/{BCV_Folder}/mapping_atm_{table}-{SOURCE}.{SRC_TABLE}.yaml`  
**Schema:** `schemas/mapping.schema.json` (JSON Schema Draft-07)

**Pattern `regular`** (1 source + JOIN):

```yaml
schema_type: mapping
schema_version: "1.0"

transformation_rules_ref: Mapping/rules/transformation_rules.yaml  # shared rules file

mapping:
  id: MAP-ATM-fnd_mgt_co-FIMS.FUNDCOMPANY
  logical_name: "Mapping Atomic - Fund Management Company – source FIMS.FUNDCOMPANY"
  physical_name: fnd_mgt_co
  pattern: regular            # regular | unpivot | direct
  dm_ref: ATM-fnd_mgt_co-FIMS.FUNDCOMPANY
  brd_ref: BRD-SRC-FIMS-FUNDCOMPANY

target:
  schema: atomic              # luôn là 'atomic'
  physical_name: fnd_mgt_co  # tên bảng đích (snake_case) — dùng cho ETL job generation
  etl_handle: SCD4A           # ETL pattern (SCD4A | SCD2 | Fact Append | Upsert)
  description: "Công ty quản lý quỹ..."

input:
  - source_type: physical_table   # physical_table | derived_cte | unpivot_cte
    schema: bronze
    table_name: FUNDCOMPANY
    alias: fu_co
    select_fields: "id, name, capital, ..."
    filter: "data_date = to_date('{{ var(\"etl_date\") }}', 'yyyy-MM-dd')"
  - source_type: derived_cte
    schema: null
    table_name: fu_bu_raw
    alias: fu_bu
    select_fields: "fundid, array_agg(buid) AS business_type_codes"
    filter: "GROUP BY fundid"

relationship:
  - main_alias: fu_co
    join_type: LEFT JOIN        # INNER JOIN | LEFT JOIN | RIGHT JOIN | FULL OUTER JOIN
    join_alias: fu_bu
    join_on: "fu_co.id = fu_bu.fundid"

mapping_columns:
  - target_column: fund_management_company_id
    transformation: "{hash_id}('FIMS_FUNDCOMPANY', fu_co.id)"  # {rule_id}(...) = transformation rule
    data_type: string
    description: Khóa đại diện cho công ty quản lý quỹ.
  - target_column: source_system_code
    transformation: "'FIMS_FUNDCOMPANY'"                        # SQL expression thuần
    data_type: string
    description: Mã nguồn dữ liệu.
  - target_column: fund_management_company_name
    transformation: fu_co.name
    data_type: string
    description: Tên công ty QLQ.

final_filter: []                # để [] nếu không có WHERE/UNION ALL
```

**Pattern `unpivot`** (1 source, nhiều legs UNION ALL từ cùng bảng):

```yaml
schema_type: mapping
schema_version: "1.0"

transformation_rules_ref: Mapping/rules/transformation_rules.yaml

mapping:
  id: MAP-ATM-ip_alt_identn-FIMS.BANKMONI
  logical_name: "Mapping Atomic - IP Alternative Identification – source FIMS.BANKMONI"
  physical_name: ip_alt_identn
  pattern: unpivot
  dm_ref: ATM-ip_alt_identn-FIMS.BANKMONI
  brd_ref: BRD-SRC-FIMS-BANKMONI

target:
  schema: atomic
  physical_name: ip_alt_identn  # snake_case physical name
  etl_handle: SCD4A             # ETL pattern
  description: "Giấy tờ định danh thay thế cho các đối tượng tham gia"

input:
  - source_type: physical_table
    schema: bronze
    table_name: BANKMONI
    alias: ba_mo
    select_fields: "id, idno, idadd, iddate, regno, regadd, regdate"
    filter: "data_date = to_date('{{ var(\"etl_date\") }}', 'yyyy-MM-dd')"

relationship: []

mapping_legs:                   # thay mapping_columns khi dùng pattern unpivot
  - leg: BUSINESS_LICENSE       # tên leg = identification_type_code value
    filter: "ba_mo.idno IS NOT NULL"
    mapping_columns:
      - target_column: ip_id
        transformation: "{hash_id}('FIMS_BANKMONI', ba_mo.id)"
        source_column: FIMS.BANKMONI.Id
        data_type: string
      - target_column: identn_tp_code
        transformation: "'BUSINESS_LICENSE'"
        source_column: null
        data_type: string
        etl_derived_value: BUSINESS_LICENSE
      - target_column: identn_nbr
        transformation: ba_mo.idno
        source_column: FIMS.BANKMONI.IdNo
        data_type: string
  - leg: OPERATING_LICENSE
    filter: "ba_mo.regno IS NOT NULL"
    mapping_columns:
      - target_column: ip_id
        transformation: "{hash_id}('FIMS_BANKMONI', ba_mo.id)"
        source_column: FIMS.BANKMONI.Id
        data_type: string
      - target_column: identn_tp_code
        transformation: "'OPERATING_LICENSE'"
        source_column: null
        data_type: string
        etl_derived_value: OPERATING_LICENSE
      - target_column: identn_nbr
        transformation: ba_mo.regno
        source_column: FIMS.BANKMONI.RegNo
        data_type: string

mapping_columns: null           # null khi dùng mapping_legs

final_filter:
  - clause_type: UNION ALL
    expression: |
      SELECT ... FROM ba_mo WHERE ba_mo.idno IS NOT NULL
      UNION ALL
      SELECT ... FROM ba_mo WHERE ba_mo.regno IS NOT NULL
    description: UNION ALL 2 legs từ cùng 1 physical table.
```

### 3.10 Ba loại Mapping Pattern (YAML)

| Pattern | Dùng khi | `mapping_columns` hay `mapping_legs` | `final_filter` |
|---|---|---|---|
| `regular` | 1 bảng chính + JOIN bảng phụ | `mapping_columns` | `[]` hoặc WHERE/GROUP BY |
| `unpivot` | 1 bảng, nhiều legs (loại giấy tờ) | `mapping_legs` | UNION ALL các legs |
| `direct` | 1 bảng, không JOIN, không legs | `mapping_columns` | `[]` hoặc WHERE |
| `shared_entity` | Multi-source UNION ALL (IP addresses, identifications) | `mapping_columns` | UNION ALL các nguồn |

### 3.11 ETL Handle

**`etl_handle`** trong section `target` định nghĩa cách xử lý dữ liệu trên Atomic layer:

| Value | Ý nghĩa | Dùng cho |
|---|---|---|
| `SCD4A` | Slowly Changing Dimension Type 4A (effective date tracking) | Dimension entities (Fundamental) |
| `SCD2` | Slowly Changing Dimension Type 2 (historical snapshots) | Relative entities |
| `Fact Append` | Chỉ insert mới, không update/delete (append-only pattern) | Fact tables, Transaction events |
| `Upsert` | Insert + Update (match by key, replace if exists) | Classification Values, Configuration |

> **Lưu ý:** ETL pattern được định nghĩa **duy nhất** tại `target.etl_handle`. Không còn trường `mapping.etl_pattern`.

### 3.13 Schema Validation

**VS Code** (realtime, `.vscode/settings.json`):

```json
{
  "yaml.schemas": {
    "schemas/brd_source.schema.json": ["BRD/Source/brd_*.yaml"],
    "schemas/dm.schema.json": ["DataModel/Atomic/dm_atm_*.yaml"],
    "schemas/mapping.schema.json": ["Mapping/Atomic/mapping_atm_*.yaml"]
  }
}
```

**CLI:**

```bash
# Validate một file
ajv validate -s schemas/mapping.schema.json -d "Mapping/Atomic/Involved_Party/mapping_atm_fnd_mgt_co-FIMS.FUNDCOMPANY.yaml"

# Validate tất cả mapping files
for file in Mapping/Atomic/**/*.yaml; do
  ajv validate -s schemas/mapping.schema.json -d "$file" && echo "OK $file" || echo "FAIL $file"
done
```

**Các trường bắt buộc validate:**
- `mapping.id` pattern: `^MAP-ATM-{physical_name}-{SOURCE}.{TABLE}$`
- `mapping.pattern` enum: `regular | unpivot | direct | shared_entity`
- `mapping.dm_ref` string (not removed from required)
- `mapping.brd_ref` string (not removed from required)
- `target.schema` const: `atomic`
- `target.physical_name` pattern: snake_case
- `target.etl_handle` enum: `SCD4A | SCD2 | Fact Append | Upsert`
- `input[].source_type` enum: `physical_table | derived_cte | unpivot_cte`
- `mapping_columns[].target_column` pattern: snake_case
- `mapping_columns[].data_type` enum: 10 Delta Lake types
- `final_filter[].clause_type` enum: `WHERE | UNION ALL | GROUP BY | HAVING | ORDER BY`

### 3.14 Transformation Rules — Shared Rule Library

**File:** `Mapping/rules/transformation_rules.yaml`  
**Scope:** Shared toàn dự án — tất cả mapping YAML đều tham chiếu file này qua `transformation_rules_ref`

**Mục đích:**
- Định nghĩa function signature cho các transformation đặc biệt cần ETL generator nhận diện
- ETL generator tra cứu file này khi gặp cú pháp `{rule_id}(...)` trong trường `transformation`
- Đảm bảo consistency — cùng rule sinh ra cùng SQL pattern trên toàn bộ project

**Cú pháp nhận diện rule trong `transformation`:**

Dùng `{rule_id}(...)` để phân biệt transformation rule với SQL function thông thường:

```yaml
# Transformation rule — ETL generator tra cứu transformation_rules.yaml
transformation: "{hash_id}('FIMS_FUNDCOMPANY', fu_co.id)"

# SQL thông thường — ETL generator dùng trực tiếp
transformation: fu_co.name
transformation: "'FIMS_FUNDCOMPANY'"
transformation: null
```

Rule hiện tại của dự án: **`hash_id`**

**Cấu trúc file:**

```yaml
schema_type: transformation_rules
schema_version: "1.0"

rules:
  - id: hash_id
    function: hash_id
    category: surrogate_key
    description: "Sinh surrogate key bằng MD5/SHA hash từ Source System Code + business key."
    params:
      - name: ssc
        type: string_literal             # string_literal | column_ref
        description: "Source System Code, VD: 'FIMS_FUNDCOMPANY'"
        example: "'FIMS_FUNDCOMPANY'"
      - name: source_key
        type: column_ref
        description: "Cột chứa business key, VD: fu_co.id"
        example: fu_co.id
    syntax: "{hash_id}({ssc}, {source_key})"
    render_template: "hash_id({ssc}, {source_key})"
    output_type: string
    nullable: false
```

**Cách dùng trong `mapping_columns`:**

```yaml
mapping_columns:
  - seq: 1
    target_column: fund_management_company_id
    transformation: "{hash_id}('FIMS_FUNDCOMPANY', fu_co.id)"
    data_type: string
    description: Khóa đại diện — PK surrogate key.

  - seq: 18
    target_column: country_of_registration_id
    transformation: "{hash_id}('FIMS_NATIONAL', fu_co.naid)"
    data_type: string
    description: FK surrogate key → Geographic Area.
```

> ETL generator nhận diện prefix `{hash_id}` trong `transformation`, tra cứu `transformation_rules.yaml` để biết function signature và sinh SQL tương ứng. Các transformation không có prefix `{...}` được dùng trực tiếp như SQL expression thuần.

---

## 4. DDL Generation & ETL Spec

### 4.1 Từ DM → DDL

- **Input:** DM YAML từ bước 2 (`DataModel/Atomic/`)
- **Output:** Delta Lake `CREATE TABLE` scripts, Spark/SQL ETL jobs
- **Tool:** Manual hoặc code gen từ DM YAML

### 4.2 Nội dung ETL Spec (bổ sung vào DM hoặc file riêng)

```yaml
# Có thể extend DM YAML với section etl_spec nếu cần
etl_spec:
  delta:
    table_location: /delta/atomic/dscl_ahr
    partitioned_by:
      - column: ds_date
        format: YYYY-MM-DD
    z_order_by:
      - dscl_ahr_id

  scd4a_columns:
    effective_from: ds_eff_from_date
    effective_to: ds_eff_to_date
    is_current: ds_is_current
    change_reason: ds_change_reason

  technical_columns:
    - ds_load_timestamp   # timestamp — ETL load time
    - ds_record_hash      # string — MD5 hash for change detection

  unit_tests:
    - test_id: TEST-001
      description: "Duplicate detection on PK"
      expected: "1 row per PK"
    - test_id: TEST-002
      description: "SCD4A: only 1 row with is_current=true per PK"
      expected: "All PKs have exactly 1 current row"
```

---

## 5. Spec Registry — Trạng thái tiến độ toàn dự án

### 5.1 Mục đích

File `spec-registry/registry.csv` là **nguồn sự thật duy nhất** về trạng thái tiến độ của từng BRD trong dự án. Cho phép liệt kê, filter, và theo dõi pipeline: BRD → DM → Mapping → ETL → Test → Deploy.

### 5.2 Cấu trúc CSV

| Cột | Nguồn | Ghi chú |
|---|---|---|
| `brd_id` | BRD YAML | PK — định danh duy nhất |
| `source` | BRD YAML | Source system code (FIMS, FMS, ...) |
| `table_name` | BRD YAML | Tên bảng nguồn |
| `functional_group` | BRD YAML | Nhóm nghiệp vụ |
| `scope_status` | BRD YAML | `in_scope` / `out_of_scope` |
| `scope_reason` | BRD YAML | Lý do nếu out_of_scope |
| `data_volume_hint` | BRD YAML | static / small / medium / large / very_large |
| `refresh_frequency` | BRD YAML | real_time / daily / ... |
| `dm_status` | DM YAML (auto) | `none` / `draft` / `approved` |
| `mapping_status` | Mapping YAML (auto) | `none` / `done` |
| `etl_status` | **Manual** | `none` / `dev` / `done` |
| `test_status` | **Manual** | `none` / `written` / `passed` |
| `deployed` | **Manual** | `yes` / `no` |
| `dm_files` | DM YAML (auto) | Số DM file cho BRD này |
| `mapping_files` | Mapping YAML (auto) | Số Mapping file cho BRD này |

> Các cột **Manual** (`etl_status`, `test_status`, `deployed`) được preserve khi chạy lại script — chỉnh sửa trực tiếp trong CSV.

### 5.3 Sync Script

**File:** `scripts/sync_registry.py`

Script đọc tất cả BRD/DM/Mapping YAML và cập nhật registry.csv. Chạy sau mỗi khi thêm/sửa YAML files.

```bash
# Sync toàn bộ + in bảng tiến độ
python -X utf8 scripts/sync_registry.py --summary

# Sync toàn bộ (không in summary)
python -X utf8 scripts/sync_registry.py

# Chỉ sync 1 source
python -X utf8 scripts/sync_registry.py --source FIMS
```

**Output mẫu:**

```
===================================================================
Source         Total InScope   DM✓   DM~   Map✓  ETL✓  Test✓ Deploy
-------------------------------------------------------------------
FIMS              85      41    19     0      7     0      0      0
FMS               79      35    24     0      0     0      0      0
...
TOTAL            541     354   235     1      7     0      0      0
===================================================================
  DM✓=approved  DM~=draft  Map✓=mapping done
```

### 5.4 Query CSV bằng Python

```python
import pandas as pd

df = pd.read_csv("spec-registry/registry.csv")

# BRD in_scope chưa có DM
df[(df.scope_status == "in_scope") & (df.dm_status == "none")]

# Tất cả BRD của source FIMS
df[df.source == "FIMS"]

# BRD đã DM approved nhưng chưa Mapping
df[(df.dm_status == "approved") & (df.mapping_status == "none")]

# Tiến độ theo source
df.groupby("source")[["dm_status", "mapping_status"]].value_counts()
```

### 5.5 Quy trình cập nhật

| Khi nào | Hành động |
|---|---|
| Thêm/sửa BRD YAML | Chạy `sync_registry.py` |
| Thêm DM YAML mới hoặc đổi status | Chạy `sync_registry.py` |
| Thêm Mapping YAML mới | Chạy `sync_registry.py` |
| DE hoàn thành ETL job | Sửa `etl_status` trực tiếp trong CSV |
| QE pass test | Sửa `test_status` trực tiếp trong CSV |
| Deploy lên môi trường | Sửa `deployed` trực tiếp trong CSV |

---

## 6. Schema Registry

### 6.1 Registry File

**File:** `schemas/registry.json`  
**Purpose:** Web app dùng để xác định schema nào để validate/parse từng loại YAML file

### 6.2 Active Schema Types

| type | schema_file | file_pattern |
|---|---|---|
| `brd_source` | `schemas/brd_source.schema.json` | `BRD/Source/brd_*.yaml` |
| `data_model` | `schemas/dm.schema.json` | `DataModel/Atomic/dm_atm_*.yaml` |
| `mapping` | `schemas/mapping.schema.json` | `Mapping/Atomic/mapping_atm_*.yaml` |

### 6.3 Structure

```json
{
  "schema_types": [
    {
      "type": "brd_source",
      "label": "BRD Source Analysis",
      "schema_file": "schemas/brd_source.schema.json",
      "file_pattern": "BRD/Source/brd_*.yaml",
      "file_location": "BRD/Source/",
      "file_naming": "brd_{SOURCE}.yaml",
      "version": "1.0"
    },
    {
      "type": "data_model",
      "label": "Data Model Design",
      "schema_file": "schemas/dm.schema.json",
      "file_pattern": "DataModel/Atomic/dm_atm_*.yaml",
      "file_location": "DataModel/Atomic/",
      "file_naming": "dm_atm_{physical_name}-{SOURCE}.{TABLE}.yaml",
      "version": "1.0"
    }
  ],
  "future_schema_types": [
    {
      "type": "mapping",
      "label": "Source-to-Atomic Mapping",
      "file_pattern": "Mapping/mapping_*.yaml",
      "status": "planned"
    }
  ]
}
```

---

## 7. Validation & Tooling

### 7.1 VS Code Setup

**File:** `.vscode/settings.json`

```json
{
  "yaml.schemas": {
    "schemas/brd_source.schema.json": ["BRD/Source/brd_*.yaml"],
    "schemas/dm.schema.json": ["DataModel/Atomic/dm_atm_*.yaml"],
    "schemas/mapping.schema.json": ["Mapping/Atomic/mapping_atm_*.yaml"]
  },
  "yaml.validate": true,
  "yaml.format.enable": true,
  "yaml.completion": true
}
```

### 7.2 CLI Validation

```bash
# Validate BRD YAML
ajv validate -s schemas/brd_source.schema.json -d "BRD/Source/brd_ThanhTra.yaml"

# Validate tất cả BRD files
for file in BRD/Source/brd_*.yaml; do
  ajv validate -s schemas/brd_source.schema.json -d "$file"
done

# Validate DM YAML
ajv validate -s schemas/dm.schema.json -d "DataModel/Atomic/Arrangement/dm_atm_dscl_ahr-FIMS.AUTHOANNOUNCE.yaml"

# Validate tất cả DM files
for file in DataModel/Atomic/**/*.yaml; do
  ajv validate -s schemas/dm.schema.json -d "$file"
done

# Validate Mapping YAML
ajv validate -s schemas/mapping.schema.json -d "Mapping/Atomic/Involved_Party/mapping_atm_fnd_mgt_co-FIMS.FUNDCOMPANY.yaml"

# Validate tất cả mapping files
for file in Mapping/Atomic/**/*.yaml; do
  ajv validate -s schemas/mapping.schema.json -d "$file"
done
```

---

## 8. Thêm loại YAML mới

Khi mở rộng (ETL spec, mapping, ...):

1. **Tạo schema file:** `schemas/{type}.schema.json` (JSON Schema Draft-07)
2. **Thêm vào registry:** `schemas/registry.json` → thêm entry vào `schema_types`
3. **Update VS Code:** `.vscode/settings.json` → thêm mapping mới

---

## 9. Key Contacts

| Role | Email | Trách nhiệm |
|------|-------|------------|
| BA | username@fssc.com.vn | Thu thập BRD, validate yêu cầu |
| Steward | username@ubck.com.vn | Approve BRD, governance |
| Data Modeler | username@fssc.com.vn | Thiết kế DM, maintain CSV |

---

## 10. References

- **CLAUDE.md** — Data modeling principles & terminology
- **SCHEMA_SETUP.md** — YAML validation setup detailed guide
- **`system/rules/rule_map_technical_table_type.csv`** — Mapping table_type → etl_pattern
- **`Mapping/registries/`** — Registry CSV cho generate mapping (entities, attributes, bronze)
- **`Mapping/scripts/gen_mapping_atomic.py`** — Script generate mapping CSV hàng loạt
- **PDF:** `data-spec-workflow DETAIL.pdf` — Full workflow specification
- **`spec-registry/registry.csv`** — Spec Registry: trạng thái tiến độ toàn dự án
- **`scripts/sync_registry.py`** — Script sync YAML → registry.csv
