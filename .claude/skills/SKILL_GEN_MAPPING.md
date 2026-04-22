---
name: gen-mapping
description: |
  Generate ETL mapping Excel files từ Silver LLD design và Bronze source metadata.
  Sử dụng khi: gen mapping từ LLD, gen bronze/silver registry, chạy pipeline mapping,
  tạo file gm_bronze_entities, gm_silver_entities, gm_bronze_attributes, gm_silver_attributes,
  generate mapping Excel từ template chuẩn.
  Script files nằm tại: Mapping/scripts/
---

# Gen Mapping Skill

Quy trình 3 bước sinh ETL mapping từ thiết kế Silver LLD ra file Excel theo template chuẩn.

## Cấu trúc repo (ubck_atomic_design)

```
ubck_atomic_design/
├── .claude/skills/
│   └── SKILL_GEN_MAPPING.md        ← file này
├── Source/                          ← DDL nguồn
│   ├── FMS_Tables.csv
│   ├── FMS_Columns.csv
│   └── <SS>_Tables.csv, <SS>_Columns.csv  (per source system)
├── Silver/
│   ├── hld/
│   │   └── silver_entities.csv     ← input bước 2
│   └── lld/
│       ├── silver_attributes.csv   ← input bước 2 + 3
│       ├── attr_Classification_Value.csv
│       └── ref_shared_entity_classifications.csv
├── system/
│   ├── rules/
│   │   ├── rule_map_technical_table_type.csv
│   │   └── rule_map_data_type.csv
│   └── templates/
│       └── mapping_template.csv
└── Mapping/
    ├── scripts/                     ← scripts Python
    │   ├── gen_reg_bronze.py
    │   ├── gen_reg_silver.py
    │   └── gen_mapping_silver.py
    ├── registries/                    ← gm_* files (living files)
    │   ├── gm_bronze_entities.csv
    │   ├── gm_bronze_attributes.csv
    │   ├── gm_silver_entities.csv
    │   └── gm_silver_attributes.csv
    └── silver/                      ← mapping output, 1 folder per source system
        ├── FMS/
        │   └── <entity>.csv
        ├── FIMS/
        ├── NHNCK/
        ├── SCMS/
        └── ...
```

---

## Bước 1 — gen_reg_bronze.py

```bash
python Mapping/scripts/gen_reg_bronze.py FMS
python Mapping/scripts/gen_reg_bronze.py NHNCK
```

Chạy 1 lần per source system. **Append mode** — tự động replace dòng cũ nếu chạy lại.

**Input:**
- `Source/<SS>_Tables.csv` — cột: `Tên bảng`, `Ý nghĩa bảng`
- `Source/<SS>_Columns.csv` — cột: `Tên bảng`, `Tên trường`, `Mô tả`, `Khóa`

**Output (append vào file chung):**
- `Mapping/registries/gm_bronze_entities.csv`
- `Mapping/registries/gm_bronze_attributes.csv`

**gm_bronze_entities** cột: `source_system` | `table_name` | `source_system.table_name` | `technical_table_type` | `filter` | `description`

**gm_bronze_attributes** cột: `source_system` | `table_name` | `column_name` | `source_system.table_name` | `data_type` | `description` | `pk/fk`

---

## Bước 2 — gen_reg_silver.py

```bash
python Mapping/scripts/gen_reg_silver.py
```

**Input:**
- `Silver/hld/silver_entities.csv`
- `Silver/lld/silver_attributes.csv`
- `Silver/lld/attr_Classification_Value.csv`
- `system/rules/rule_map_technical_table_type.csv` (hoặc .xlsx)
- `system/rules/rule_map_data_type.csv` (hoặc .xlsx)

**Output:**
- `Mapping/registries/gm_silver_entities.csv`
- `Mapping/registries/gm_silver_attributes.csv`

**gm_silver_entities** — thêm các cột vào sau `table_type`:
- `technical_table_type`: map từ rule file
- `filter`: trống (điền thủ công)
- `mapping_type`: tự động — `regular` / `shared_entity` / `cv`

**gm_silver_attributes** — thêm `silver_data_type` sau `silver_attribute`.

Các cột bị drop: `bcv_core_object`, `bcv_concept`, `status`.
`source_table` được uppercase toàn bộ.

### normalize_attr_columns()
Auto-detect và xử lý 2 dạng tên cột trong `silver_attributes.csv`:
- Dạng A (chuẩn pipeline): `silver_attribute`, `source_column` → giữ nguyên
- Dạng B (individual attr file): `attribute_name`, `source_columns` → tự rename

### Rule map technical_table_type

| Model Table Type | Technical Table Type |
|---|---|
| Fundamental | SCD4A |
| Relation | SCD2 |
| Fact Append | Fact Append |
| Fact Snapshot | Fact Append |
| Classification | SCD1 |

### Rule map data_type (word-boundary, widest decimal wins)

| Keyword | Data Type |
|---|---|
| amount / income / revenue | decimal(23,2) |
| rate | decimal(12,7) |
| percentage | decimal(8,5) |
| ratio | decimal(5,2) |
| date | date |
| timestamp | timestamp |
| *(no match)* | string |

### mapping_type derivation

| bcv_concept | mapping_type |
|---|---|
| `Shared Entity` | `shared_entity` |
| table_type == `Classification` | `cv` |
| else | `regular` |

---

## Bước 3 — gen_mapping_silver.py

```bash
python Mapping/scripts/gen_mapping_silver.py
python Mapping/scripts/gen_mapping_silver.py --entity "Fund Management Company"
python Mapping/scripts/gen_mapping_silver.py --source-system FMS
```

**Input:**
- `Mapping/registries/gm_silver_entities.csv`
- `Mapping/registries/gm_silver_attributes.csv`
- `Mapping/registries/gm_bronze_attributes.csv`
- `system/templates/mapping_template.csv`

**Output:**
```
Mapping/silver/<source_system>/<entity_snake>.csv
```
Ví dụ: `Mapping/silver/FMS/fund_management_company.csv`

Nếu entity có nhiều SSC (multi-source): `fund_management_company_FMS_SECURITIES.csv`

Template được đọc bằng `csv.reader` và output ghi bằng `csv.writer` với encoding `utf-8-sig`. Không dùng openpyxl — giữ file dạng text để Git diff/merge được.

---

### Case 1 — Regular (mapping_type = `regular`)

**1 SSC = 1 file.** Sheet duy nhất trong mỗi file.

**INPUT_TABLES:**
- `physical_table`: bảng chính + bảng join
- `derived_cte` (nếu có `Array<Text>`): pre-aggregate `array_agg` trước khi join

**RELATIONSHIP:** LEFT JOIN cho bảng phụ. Bỏ trống nếu không có join.

**MAPPING — transformation rules:**

| Pattern | Transformation |
|---|---|
| `silver_attribute == 'Source System Code'` | `'<value trong classification_context>'` — LUÔN lấy giá trị trong `''` từ `classification_context`, không phụ thuộc vào comment |
| Surrogate Key PK | `hash_id('<own_SSC>', alias.code_col)` |
| Surrogate Key FK | `hash_id('<target_SSC>', alias.fk_col)` |
| Classification Value + SOURCE_SYSTEM trong comment | `'<value trong classification_context>'` |
| Array<Text> | `alias.snake_attr_name` (direct map từ derived CTE) |
| Các domain khác có source_column | `alias.source_col` |
| Không có source_column | transformation trống (người dùng tự điền) — KHÔNG ghi flag/note vào cột Last update |

**derived_cte cho Array<Text>:**
- physical `{alias}_raw` → `fk_col, val_col`
- derived `{alias}` → `fk_col, array_agg(val_col) AS snake_name` | `GROUP BY fk_col`

**Final Filter:** chỉ render clause có giá trị — bỏ trống hoàn toàn nếu không có clause nào.

---

### Case 2 — Shared Entity (mapping_type = `shared_entity`)

Áp dụng cho: `Involved Party Electronic Address`, `Involved Party Postal Address`, `Involved Party Alternative Identification`.

**1 source_system = 1 file** (FMS, FIMS, DCST, NHNCK → tối đa 4 files per entity).
Mỗi file có 1 sheet, bên trong có N cặp `physical_table + unpivot_cte`.

**INPUT_TABLES — 2 dòng per source table:**

| # | source_type | table | alias | select_fields | filter |
|---|---|---|---|---|---|
| 1 | `physical_table` | `<TABLE>` | `<alias>` | `id, col1, col2, '<SSC>' AS source_system_code` | `data_date = ...` |
| 2 | `unpivot_cte` | `<alias>` | `leg_<alias>` | `ip_code=id \| TYPE1:col1 \| TYPE2:col2 \| source_system_code` | `address_value IS NOT NULL` |

**unpivot_cte select_fields convention:**
```
ip_code=<id_col> | <TYPE>:<val_col> | <TYPE>:<val_col> | <passthrough_col>
```
- `TYPE:col` = 1 unpivot leg
- `passthrough_col` (không có `:`) = carry-through (e.g. `source_system_code`)

**source_system_code hardcode tại physical_table** → carry-through qua unpivot_cte → MAPPING select `leg.source_system_code` trực tiếp.

**RELATIONSHIP:** bỏ trống (không có join — mỗi leg CTE độc lập).

**MAPPING — 5 dòng cố định (generic, first leg alias):**

| target_column | transformation |
|---|---|
| `involved_party_id` | `hash_id(leg_<alias>.source_system_code, leg_<alias>.ip_code)` |
| `involved_party_code` | `leg_<alias>.ip_code` |
| `source_system_code` | `leg_<alias>.source_system_code` |
| `<type_code_attr>` | `leg_<alias>.type_code` |
| `<value_attr>` | `leg_<alias>.address_value` |

**Final Filter — UNION ALL** khi có > 1 leg:
```sql
SELECT * FROM leg_se
UNION ALL
SELECT * FROM leg_fo_ch
```

**type_attr detection:** `silver_attribute != 'Source System Code'` — SSC luôn có tên cố định, không cần parse comment.

---

### Case 3 — Classification Value (mapping_type = `cv`)

🚧 Chưa định nghĩa. Script sinh placeholder.

---

## Alias naming convention

| Loại | Rule | Ví dụ |
|---|---|---|
| Single word | wordninja tách → gộp greedy ≥4 chars → 2 ký tự/segment | `AUTHOANNOUNCE → au_an` |
| Multi-word (có `_`) | 2 ký tự đầu mỗi segment | `AA_ARRANGEMENT_LINKED → aa_ar_li` |

**Override dict:**

| Table | Alias |
|---|---|
| SECBUSINES | se_bu |
| FUNDCOMBUSINES | fu_bu |
| FUNDCOMTYPE | fu_ty |
| STFFGBRCH | st_br |
| ORGANIZATIONS | org |
| PROFESSIONALS | pro |

---

## parse_source_col

```
3-part: SOURCE.TABLE.col        → (SOURCE, TABLE, col)   — FMS, FIMS, DCST, SCMS
4-part: SOURCE.SCHEMA.TABLE.col → (SOURCE, TABLE, col)   — NHNCK (schema = qlnhn)
```

---

## entity_ssc_map

Build từ `gm_silver_attributes.csv`: tìm dòng `Classification Value` + comment `SOURCE_SYSTEM` → extract giá trị `''` trong `classification_context`. Dùng để resolve target SSC cho FK Surrogate Key.

---

## Template

- `system/templates/mapping_template.csv` — template CSV thuần, đọc/ghi bằng module `csv` của Python
- Banner: `Final Filter` (không phải FINAL_FILTER)
- 11 cột: `#`, `Target Column/Source Type/...`, `Transformation/...`, `Data Type/...`, 4 cột phụ, `Description`, `Last update`, `Update by`, `Update reason`
- Cột `Last update` / `Update by` / `Update reason`: **LUÔN trống** khi gen — dành cho người maintain điền thủ công, không ghi flag/note vào đây
- Final Filter: chỉ render clause có giá trị, bỏ trống hoàn toàn nếu không dùng
- Output encoding: `utf-8-sig` (có BOM) để Excel/extension parse tiếng Việt đúng
