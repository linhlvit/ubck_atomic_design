---
name: gen-mapping
description: |
  Generate ETL mapping CSV files theo kiến trúc Medallion 4 tầng: Source → Staging → ODS → Atomic.
  Sử dụng khi: gen registry (gm_staging_*, gm_ods_*, gm_atomic_*, gm_bronze_*),
  gen mapping staging/ods/atomic từ LLD design, chạy pipeline mapping,
  generate mapping CSV từ template chuẩn.
  Script files nằm tại: Mapping/scripts/
---

# Gen Mapping Skill

Quy trình sinh ETL mapping theo kiến trúc Medallion 4 tầng: **Source → Staging → ODS → Atomic**.

Mỗi tầng gồm 2 bước:
1. **Gen registry** `gm_*` — metadata tổng hợp của tầng đó
2. **Gen mapping** CSV — file mapping chi tiết từ registry

---

## Cấu trúc repo

```
ubck_atomic_design/
├── Source/                          ← DDL nguồn
│   └── <SS>_Tables.csv, <SS>_Columns.csv
├── Atomic/
│   ├── hld/atomic_entities.csv
│   └── lld/atomic_attributes.csv
├── system/
│   ├── rules/
│   │   ├── rule_map_technical_table_type.csv
│   │   ├── rule_map_schema.csv      ← schema cho mọi tầng (SRC/STG/ODS)
│   │   └── rule_map_data_type.csv
│   └── templates/mapping_template.csv
└── Mapping/
    ├── scripts/
    │   ├── gen_reg_bronze.py
    │   ├── gen_reg_staging.py
    │   ├── gen_mapping_staging.py   ← 🚧 chưa implement
    │   ├── gen_reg_ods.py
    │   ├── gen_mapping_ods.py
    │   ├── gen_reg_atomic.py
    │   └── gen_mapping_atomic.py
    ├── registries/                  ← gm_* files (living files)
    │   ├── gm_bronze_entities.csv
    │   ├── gm_bronze_attributes.csv
    │   ├── gm_staging_entities.csv
    │   ├── gm_staging_attributes.csv
    │   ├── gm_ods_entities.csv
    │   ├── gm_ods_attributes.csv
    │   ├── gm_atomic_entities.csv
    │   └── gm_atomic_attributes.csv
    ├── staging/                     ← mapping output staging
    │   └── <SS>/stg_<ss>_<table>.csv
    ├── ods/                         ← mapping output ODS
    │   └── <SS>/ods_<ss>_<table>.csv
    └── atomic/                      ← mapping output atomic
        └── <SS>/<entity_snake>_<ssc_lower>.csv
```

---

## Bước 1 — Staging (Source → Staging)

### 1.1 gen_reg_staging.py

```bash
python Mapping/scripts/gen_reg_staging.py FMS
```

**Append mode** — replace dòng cũ của `source_system` nếu chạy lại.

**Input:** `Source/<SS>_Tables.csv`, `Source/<SS>_Columns.csv`

**Output:**
- `Mapping/registries/gm_staging_entities.csv`
- `Mapping/registries/gm_staging_attributes.csv`

**gm_staging_entities** cột:

| Cột | Mô tả |
|---|---|
| `source_system` | Phân hệ (VD: FMS) |
| `table_name` | Tên bảng nguồn gốc (VD: SECURITIES) |
| `staging_table` | `stg_<ss_lower>_<table_lower>` (VD: `stg_fms_securities`) |
| `table_type` | **Trống — điền thủ công** (Master / Event) |
| `etl_handle` | Luôn `Incremental - Delete then Insert` |
| `filter` | Trống — điền thủ công |
| `description` | Từ `Ý nghĩa bảng` |

**gm_staging_attributes** cột: `source_system` | `table_name` | `staging_table` | `column_name` | `data_type` | `description` | `pk/fk`

> **Quy tắc tên trường:**
> - `column_name` trong registry = **UPPERCASE** (tên trường gốc tại tầng nguồn)
> - Physical Target Column trong mapping = **lowercase** (tên trường tại tầng Staging)

---

### 1.2 gen_mapping_staging.py

Output: `Mapping/staging/<SS>/stg_<ss>_<table>.csv`

**Schema convention:**

| Phần | Cột trong rule_map_schema.csv |
|---|---|
| Target (Staging) | `Tên Schema STG` — VD: `staging."env_name"_FMS_stg` |
| Source (Bronze) | `Tên Schema SRC` — VD: `oracle_viettel.FMS` |

**Mapping rules:** 1:1.
- `Physical Target Column` = `column_name.lower()` (lowercase)
- `Transformation`:
  - Cột tên kết thúc bằng `ID` (VD: `ID`, `AGENCYTYPEID`, `SECID`) → `HEX(alias.COLUMN_NAME)`
  - Các cột còn lại → `alias.COLUMN_NAME`
- `Select Fields` = `*` (luôn lấy toàn bộ cột)
- `Filter` = lấy từ cột `filter` trong `gm_staging_entities` (trống nếu không có)

**Technical fields** — thêm vào cuối Mapping cho **mọi bảng staging**:

| Physical Target Column | Transformation | Data Type | Mô tả |
|---|---|---|---|
| `ds_snpst_dt` | `to_date("etl_date", 'yyyy-MM-dd')` | `date` | Ngày dữ liệu |
| `ds_etl_pcs_tms` | `current_timestamp()` | `timestamp` | Thời điểm xử lý ETL |

> **Phân biệt mapping vs code:**
> - `to_date("etl_date", ...)` → `to_date('{{ var("etl_date") }}','yyyy-MM-dd')` — không CAST
> - `current_timestamp()` → giữ nguyên — **không CAST** (dù Data Type = `timestamp`)

---

## Bước 2 — ODS (Staging → ODS)

### 2.1 gen_reg_ods.py

```bash
python Mapping/scripts/gen_reg_ods.py FMS
```

**Append mode** — replace dòng cũ của `source_system` nếu chạy lại.

**Input:**
- `Mapping/registries/gm_staging_entities.csv` — lấy `table_type` theo 1:1 map
- `Mapping/registries/gm_staging_attributes.csv` — pass-through columns

**Output:**
- `Mapping/registries/gm_ods_entities.csv`
- `Mapping/registries/gm_ods_attributes.csv`

**gm_ods_entities** cột:

| Cột | Mô tả |
|---|---|
| `source_system` | Phân hệ |
| `staging_table` | Tên bảng staging tương ứng |
| `ods_table` | `ods_<ss_lower>_<table_lower>` (VD: `ods_fms_securities`) |
| `table_type` | Map 1:1 từ `gm_staging_entities.table_type` |
| `technical_table` | Trống — điền thủ công |
| `etl_handle` | Luôn `Incremental - Append` |
| `filter` | Trống — điền thủ công |
| `description` | Từ `gm_staging_entities.description` |

> Không có cột `table_name` — join key là `staging_table`.

**gm_ods_attributes** cột: `source_system` | `staging_table` | `ods_table` | `column_name` | `data_type` | `description` | `pk/fk`

> **Quy tắc tên trường:**
> - `column_name` = lowercase (tên trường từ tầng staging)
> - Technical fields (`ds_snpst_dt`, `ds_etl_pcs_tms`) **không lưu trong gm_** — được append trực tiếp trong `gen_mapping_ods.py`

---

### 2.2 gen_mapping_ods.py

```bash
python Mapping/scripts/gen_mapping_ods.py
python Mapping/scripts/gen_mapping_ods.py --source-system FMS
python Mapping/scripts/gen_mapping_ods.py --table SECURITIES
```

**Input:**
- `Mapping/registries/gm_ods_entities.csv`
- `Mapping/registries/gm_ods_attributes.csv`
- `system/rules/rule_map_schema.csv`

**Output:** `Mapping/ods/<SS>/ods_<ss>_<table>.csv`

**Schema convention:**

| Phần | Cột trong rule_map_schema.csv |
|---|---|
| Target (ODS) | `Tên Schema ODS` — VD: `ods."env_name"_FMS_ods` |
| Source (Staging) | `Tên Schema STG` — VD: `staging."env_name"_FMS_stg` |

**ETL Handle:** `Incremental - Append` (từ `gm_ods_entities`)

**Mapping rules (ODS — 1:1 từ staging):**
- `Physical Target Column` = `column_name` (already lowercase, as-is)
- `Transformation` = `alias.column_name` (1:1 pass-through)
- `Select Fields` = `*`
- `Filter` = lấy từ `gm_ods_entities.filter` (trống nếu không có)
- `Alias`: derive từ `staging_table` — bỏ prefix `stg_<ss>_`, lấy phần còn lại uppercase → alias convention
- **Technical fields** (append cuối mỗi mapping, không qua gm_ registry):
  - `ds_snpst_dt`: transformation = `to_date("etl_date", 'yyyy-MM-dd')`, Data Type = `date`
  - `ds_etl_pcs_tms`: transformation = `current_timestamp()`, Data Type = `timestamp` — **không CAST** trong SQL output

---

## Bước 3 — Atomic (ODS → Atomic)

### 3.1 gen_reg_atomic.py

```bash
python Mapping/scripts/gen_reg_atomic.py
```

**Input:** `Atomic/hld/atomic_entities.csv`, `Atomic/lld/atomic_attributes.csv`, `rule_map_technical_table_type.csv`

**Output:** `gm_atomic_entities.csv`, `gm_atomic_attributes.csv`

**gm_atomic_entities** cột thêm sau `atomic_table`:
- `technical_table_type`: map từ rule file
- `filter`: trống
- `mapping_type`: `regular` / `shared_entity` / `cv`
- `ods_table`: derived từ `source_table` trong HLD (`SS.TABLE` → `ods_ss_table`; multi-source → comma-separated)

Các cột bị drop: `bcv_core_object`, `bcv_concept`, `status`, `source_table`.

**gm_atomic_attributes** — pass-through từ `atomic_attributes.csv`, với các rename:
- `source_table` → `ods_table` (derived: `source_system` + `source_table` → `ods_<ss>_<table>`)
- `source_column` → `ods_column` (derived: `SS.TABLE.col` → `col` — chỉ tên cột, lowercase)

**Rule map technical_table_type:**

| Model Table Type | Technical Table Type | Technical Fields |
|---|---|---|
| Fundamental | SCD4A | ds_rcrd_isrt_dt, ds_rcrd_udt_dt, ds_rcrd_st, ds_etl_pcs_tms |
| Relative | SCD2 | ds_rcrd_eff_dt, ds_rcrd_end_dt, ds_rcrd_st, ds_etl_pcs_tms |
| Fact Append | Fact Append | ds_etl_pcs_tms |
| Classification | SCD1 | ds_etl_pcs_tms |
| Fact Snapshot | Fact Snapshot | ds_snpst_dt, ds_etl_pcs_tms |

**mapping_type derivation:**

| Điều kiện | mapping_type |
|---|---|
| `bcv_concept == 'Shared Entity'` | `shared_entity` |
| `table_type == 'Classification'` | `cv` |
| else | `regular` |

---

### 3.2 gen_mapping_atomic.py

```bash
python Mapping/scripts/gen_mapping_atomic.py
python Mapping/scripts/gen_mapping_atomic.py --entity "Fund Management Company"
python Mapping/scripts/gen_mapping_atomic.py --source-system FMS
```

**Input:** `gm_atomic_entities`, `gm_atomic_attributes`, `gm_bronze_attributes` (dùng detect_join), `mapping_template.csv`, `rule_map_schema.csv`, `rule_map_technical_table_type.csv`

**Output:** `Mapping/atomic/<SS>/<entity_snake>_<ssc_lower>.csv`

Nếu entity chỉ có 1 SSC: `Mapping/atomic/<SS>/<entity_snake>.csv`. Tên file toàn lowercase.

**Schema convention:**

| Phần | Giá trị |
|---|---|
| Target (Atomic) | `atomic."env_name"_atm` |
| Source (ODS) | `Tên Schema ODS` từ `rule_map_schema.csv` (VD: `ods."env_name"_FMS_ods`) |

**Input table name:** `ods_<ss_lower>_<table_lower>` (VD: `ods_fims_fundcompany`).

**Select Fields (atomic):** So sánh số cột được map với tổng số cột của bảng trong `gm_bronze_attributes`:
- Dùng hết tất cả cột → `*`
- Chỉ dùng một phần → liệt kê các cột cụ thể, ngăn cách bằng `, `

(Staging và ODS luôn dùng `*` vì là pass-through toàn bộ.)

**Mapping cases:**

#### Case 1 — Regular (`mapping_type = regular`)

1 SSC = 1 file. Mapping cột:

| Col | Header | Nội dung |
|---|---|---|
| 2 | Physical Target Column | `atomic_column` |
| 3 | Transformation | Xem rules dưới |
| 4 | Data Type | `data_type` |
| 5 | Logical Target Column | `atomic_attribute` |
| 8 | Description | `description` |

Transformation rules:

| Pattern | Transformation |
|---|---|
| `atomic_attribute == 'Source System Code'` | `'<SSC>'` |
| Surrogate Key PK | `hash_id('<own_SSC>', alias.code_col)` |
| Surrogate Key FK | `hash_id('<target_SSC>', alias.fk_col)` |
| Classification Value + SOURCE_SYSTEM trong comment | `'<SSC>'` |
| Array\<Text\> | `alias.<atomic_column>` (từ derived CTE) |
| Các domain khác có source_column | `alias.source_col` |
| Không có source_column | trống |

Technical fields appended sau (transformation trống, Data Type + Logical Name từ TECH_FIELD_META):

| Physical Name | Logical Name | Data Type |
|---|---|---|
| ds_etl_pcs_tms | ETL Processing Timestamp | timestamp |
| ds_snpst_dt | Snapshot Date | date |
| ds_rcrd_st | Record Status | int |
| ds_rcrd_eff_dt | Record Effective Date | date |
| ds_rcrd_end_dt | Record End Date | date |
| ds_rcrd_isrt_dt | Record Insert Date | date |
| ds_rcrd_udt_dt | Record Update Date | date |

#### Case 2 — Shared Entity (`mapping_type = shared_entity`)

Áp dụng cho: `Involved Party Electronic Address`, `Involved Party Postal Address`, `Involved Party Alternative Identification`.

1 source_system = 1 file. Router tự động dựa trên `classification_context`:

| Điều kiện | Sub-pattern | Hàm |
|---|---|---|
| `classification_context` chứa `\|` | Alt ID — direct SELECT | `write_alt_id_sheet` |
| Không có `\|` | Unpivot — LATERAL VIEW | `write_unpivot_sheet` |

> **Schema/Table trong Input section của Shared Entity = ODS, giống Regular.**
> - Schema: `Tên Schema ODS` từ `rule_map_schema.csv` (VD: `ods."env_name"_FIMS_ods`)
> - Table Name: `ods_<ss_lower>_<table_lower>` (VD: `ods_fims_bankmoni`)
> - **Không dùng** source schema (`oracle_viettel.SS`) hay tên bảng nguồn viết HOA.

**Sub-pattern A — Alt ID** (`classification_context` có `|`):

Format: `Source System Code = '<SSC>' | Identification Type Code = '<TYPE>'`

Mỗi `classification_context` duy nhất = 1 leg. Alias disambiguation khi cùng bảng có 2+ types: `base`, `base_2`, `base_3`...

INPUT_TABLES: 1 `physical_table` per leg (Schema = ODS schema, Table Name = `ods_<ss>_<table>`). MAPPING: expressions per leg, ngăn cách bằng `; `. FINAL FILTER: UNION ALL tất cả leg aliases.

**Sub-pattern B — Unpivot / LATERAL VIEW:**

INPUT_TABLES: 2 dòng per source table (`physical_table` Schema/Table = ODS + `unpivot_cte`). MAPPING: 5 dòng cố định. FINAL FILTER: UNION ALL khi > 1 leg.

#### Case 3 — Classification Value (`mapping_type = cv`)

🚧 Chưa định nghĩa. Script sinh placeholder.

---

## Alias naming convention

| Loại | Rule | Ví dụ |
|---|---|---|
| Single word | wordninja tách → gộp greedy ≥4 chars → 2 ký tự/segment | `AUTHOANNOUNCE → au_an` |
| Multi-word (có `_`) | 2 ký tự đầu mỗi segment | `AA_ARRANGEMENT_LINKED → aa_ar_li` |

Override dict: `SECBUSINES→se_bu`, `FUNDCOMBUSINES→fu_bu`, `FUNDCOMTYPE→fu_ty`, `STFFGBRCH→st_br`, `ORGANIZATIONS→org`, `PROFESSIONALS→pro`

---

## rule_map_schema.csv

Key = `Phân hệ`. Script đọc đúng cột theo tầng đang gen:

| Cột | Tầng dùng | Ví dụ (FMS) |
|---|---|---|
| `Tên Schema SRC` | Input của Staging | `oracle_viettel.FMS` |
| `Tên Schema STG` | Target Staging / Input của ODS | `staging."env_name"_FMS_stg` |
| `Tên Schema ODS` | Target ODS / **Input của Atomic** (Regular + Shared Entity) | `ods."env_name"_FMS_ods` |

---

## Template

- `system/templates/mapping_template.csv` — đọc/ghi bằng module `csv`, encoding `utf-8-sig`
- Mapping section header (row 17): `#,Physical Target Column,Transformation,Data Type,Logical Target Column,,,Description,Last update,Update by,Update reason`
- Cột `Last update` / `Update by` / `Update reason`: **LUÔN trống** khi gen
- Final Filter: chỉ render clause có giá trị
