---
name: gen-code
description: |
  Generate formatted SQL code từ mapping CSV theo kiến trúc Medallion 4 tầng: Source → Staging → ODS → Atomic.
  Sử dụng khi: gen SQL từ file mapping staging/ods/atomic, build ETL SQL,
  chạy pipeline sinh code, convert mapping → SQL có CTE + CAST chuẩn.
  Script files nằm tại: Code/scripts/
---

# Gen Code Skill

Sinh file SQL đã format từ mapping CSV của từng tầng trong kiến trúc Medallion.

Mỗi tầng có 1 script riêng — input là mapping CSV của tầng đó, output là file SQL tương ứng.

---

## Cấu trúc repo

```
ubck_atomic_design/
├── Mapping/
│   ├── staging/<SS>/stg_<ss>_<table>.csv   ← input staging
│   ├── ods/<SS>/ods_<ss>_<table>.csv        ← input ODS
│   └── atomic/<SS>/<entity>.csv            ← input atomic
├── system/
│   └── rules/rule_map_schema.csv           ← lookup Tên Schema Var DBT SRC/STG/ODS
└── Code/
    ├── scripts/
    │   ├── gen_code_staging.py              ← Bước 1
    │   ├── gen_code_ods.py                  ← Bước 2 (🚧 chưa implement)
    │   └── gen_code_atomic.py               ← Bước 3
    ├── staging/<SS>/stg_<ss>_<table>.sql   ← output staging
    ├── ods/<SS>/ods_<ss>_<table>.sql        ← output ODS
    └── atomic/<SS>/<entity>.sql            ← output atomic
```

---

## Pipeline tổng thể

```
Source DDL  (Source/<SS>_Tables.csv + _Columns.csv)
│
├─ Bước 1: Staging
│   Mapping/staging/<SS>/stg_*.csv
│   ↓ gen_code_staging.py
│   Code/staging/<SS>/stg_*.sql
│
├─ Bước 2: ODS  (🚧 gen_code_ods.py chưa implement)
│   Mapping/ods/<SS>/ods_*.csv
│   ↓ gen_code_ods.py
│   Code/ods/<SS>/ods_*.sql
│
└─ Bước 3: Atomic
    Mapping/atomic/<SS>/<entity>.csv
    ↓ gen_code_atomic.py
    Code/atomic/<SS>/<entity>.sql
```

---

## Cấu trúc SQL output (chung mọi tầng)

```
┌─ Program Header (block comment)
│
├─ WITH
│   <cte_1> AS (...),
│   <cte_2> AS (...),
│   ...
│
└─ SELECT
     <column list>
   FROM <primary_alias>
     LEFT JOIN ...
   WHERE ...
   ;
```

---

## Program Header format (chung mọi tầng)

```sql
/*
*--------------------------------------------------------------------*
* Program code: <filename_không_extension>
* Program name: <tên file bỏ dấu _, viết hoa chữ cái đầu mỗi từ>
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/
```

### Quy tắc đặt Program name

**Staging** (`stg_<ss>_<table>`):
- Format cố định: `Staging <SS_UPPER> <TABLE_UPPER>`
- VD: `stg_fms_securities` → `Staging FMS SECURITIES`

**ODS** (`ods_<ss>_<table>`):
- Format cố định: `ODS <SS_UPPER> <TABLE_UPPER>`
- VD: `ods_fms_securities` → `ODS FMS SECURITIES`

**Atomic** (`gen_code_atomic.py`):
- Split tên file bằng `_`, viết hoa chỉ chữ cái đầu mỗi từ, phần còn lại giữ nguyên
- VD: `fund_management_company_fims_fundcompany` → `Fund Management Company Fims Fundcompany`

**Ví dụ:**

| File | Program name |
|---|---|
| `stg_fms_securities` | `Staging FMS SECURITIES` |
| `stg_scms_ctck` | `Staging SCMS CTCK` |
| `ods_fms_securities` | `ODS FMS SECURITIES` |
| `fund_management_company_fims_fundcompany` | `Fund Management Company Fims Fundcompany` |
| `involved_party_alternative_identification_fms` | `Involved Party Alternative Identification Fms` |

---

## Encoding & format (chung mọi tầng)

- **Input CSV:** `utf-8-sig` (có BOM)
- **Output SQL:** `utf-8` (không BOM)
- **Indent:** 4 spaces (không tab, trừ bảng Modified management dùng `\t`)
- **Line ending:** `\n` (LF)
- **Comma placement:** Dấu phẩy đứng **cuối** mỗi dòng (trừ dòng cuối)

---

## Bước 1 — Staging (Source → Staging)

### Chạy script

```bash
# 1 file cụ thể
python Code/scripts/gen_code_staging.py Mapping/staging/FMS/stg_fms_securities.csv

# theo source system
python Code/scripts/gen_code_staging.py --source-system FMS

# theo tên bảng (prefix match)
python Code/scripts/gen_code_staging.py --table stg_fms_securities

# tất cả
python Code/scripts/gen_code_staging.py --all

# in ra stdout
python Code/scripts/gen_code_staging.py --stdout Mapping/staging/FMS/stg_fms_securities.csv
```

**Input:** `Mapping/staging/<SS>/stg_<ss>_<table>.csv`
**Output:** `Code/staging/<SS>/stg_<ss>_<table>.sql`

### Quy tắc build CTE (Staging)

- Mỗi dòng `physical_table` → 1 CTE đơn giản
- FROM dùng **dbt source syntax** thay vì `schema.table`:

```sql
{{ source('source_<ss_lower>', 'raw_<table_lower>') }}
```

`source_<ss_lower>` derive trực tiếp từ tên thư mục cha của mapping file (VD: `FMS` → `source_fms`).

`raw_<table_lower>` = prefix `raw_` + tên bảng nguồn viết thường (VD: `SECURITIES` → `raw_securities`).

**Ví dụ CTE staging:**

```sql
se AS (
    SELECT *
    FROM {{ source('source_fms', 'raw_securities') }}
)
```

### Quy tắc Main SELECT (Staging)

| Điều | Giá trị |
|---|---|
| Physical Target Column | **Lowercase** của tên cột gốc (`ShortName` → `shortname`) |
| `to_date("etl_date", 'yyyy-MM-dd')` | `to_date('{{ var("etl_date") }}','yyyy-MM-dd')` — **không CAST** |
| `current_timestamp()` | Giữ nguyên `current_timestamp()` — **không CAST** (áp dụng mọi tầng) |
| CAST | Chỉ render nếu Data Type **không trống** (và không phải etl_date / current_timestamp()): `CAST(expr AS dtype)` |
| Không có Data Type | Giữ nguyên transformation, không wrap CAST |
| Transformation trống | `NULL` (kèm CAST nếu Data Type có giá trị) |
| WHERE | **Chỉ render** nếu filter không trống (lấy từ cột `filter` trong `gm_staging_entities`) |

**Alignment:** `AS <target>` căn thẳng hàng (expression dài nhất, cap 72 ký tự).

**Ví dụ Main SELECT staging (không có Data Type):**

```sql
SELECT
    se.Id               AS id,
    se.Name             AS name,
    se.ShortName        AS shortname,
    se.EnName           AS enname,
    se.Address          AS address,
    se.IsDataMigration  AS isdatamigration
FROM se
;
```

**Ví dụ khi có Data Type:**

```sql
SELECT
    se.Id                            AS id,
    CAST(se.Amount AS decimal(23,2)) AS amount,
    CAST(se.ActiveDate AS date)      AS activedate
FROM se
;
```

---

## Bước 2 — ODS (Staging → ODS)

### Chạy script

```bash
# 1 file cụ thể
python Code/scripts/gen_code_ods.py Mapping/ods/FMS/ods_fms_securities.csv

# theo source system
python Code/scripts/gen_code_ods.py --source-system FMS

# theo tên bảng (prefix match)
python Code/scripts/gen_code_ods.py --table ods_fms_securities

# tất cả
python Code/scripts/gen_code_ods.py --all

# in ra stdout
python Code/scripts/gen_code_ods.py --stdout Mapping/ods/FMS/ods_fms_securities.csv
```

**Input:** `Mapping/ods/<SS>/ods_<ss>_<table>.csv`
**Output:** `Code/ods/<SS>/ods_<ss>_<table>.sql`

### Quy tắc build CTE (ODS)

Mỗi dòng `physical_table` → 1 CTE. FROM dùng **dbt ref()** trỏ tới staging model:

```sql
{{ ref('<staging_table>') }}
```

`staging_table` lấy từ cột `Table Name` trong Input section của mapping (VD: `stg_fms_securities`).

**Ví dụ CTE ODS:**

```sql
se AS (
    SELECT *
    FROM {{ ref('stg_fms_securities') }}
)
```

### Quy tắc Main SELECT (ODS)

| Điều | Giá trị |
|---|---|
| Physical Target Column | As-is từ mapping (đã lowercase) |
| Transformation | `alias.column` (1:1 pass-through từ staging) |
| CAST | Chỉ render nếu Data Type **không trống**: `CAST(expr AS dtype)` |
| WHERE | Chỉ render nếu filter không trống |

**Ví dụ Main SELECT ODS:**

```sql
SELECT
    se.id              AS id,
    se.name            AS name,
    se.ds_snpst_dt     AS ds_snpst_dt
FROM se
;
```

### Program name (ODS)

Format: `ODS <SS_UPPER> <TABLE_UPPER>`

VD: `ods_fms_securities` → `ODS FMS SECURITIES`

---

## Bước 3 — Atomic (ODS → Atomic)

Script: `gen_code_atomic.py`

### Chạy script

```bash
# 1 file cụ thể
python Code/scripts/gen_code_atomic.py Mapping/atomic/FIMS/fund_management_company_fims_fundcompany.csv

# theo entity (prefix match)
python Code/scripts/gen_code_atomic.py --entity "Fund Management Company"

# theo source system
python Code/scripts/gen_code_atomic.py --source-system FIMS

# tất cả
python Code/scripts/gen_code_atomic.py --all

# in ra stdout
python Code/scripts/gen_code_atomic.py --stdout <file>
```

**Input:** `Mapping/atomic/<SS>/<entity>.csv`
**Output:** `Code/atomic/<SS>/<entity>.sql`

### Quy tắc build CTE (Atomic)

- FROM dùng **dbt ref()** trỏ tới ODS model: `{{ ref('<ods_table>') }}`
- Pair detection: nếu `input_rows[i+1].Table Name == input_rows[i].Alias` → 2 dòng là 1 cặp.

| Pattern | Kết quả SQL |
|---|---|
| `physical_table` đứng riêng | 1 CTE: `SELECT <cols> FROM {{ ref(...) }} WHERE <filter>` |
| `physical_table` + `derived_cte` (cặp) | **Gộp thành 1 CTE**: `SELECT <agg_cols> FROM {{ ref(...) }} WHERE <filter> GROUP BY <fk>` |
| `physical_table` + `unpivot_cte` (cặp) | 1 CTE dùng `LATERAL VIEW stack(...)` multi-line |

#### Ví dụ merged derived_cte

```sql
fu_bu AS (
    SELECT fundid, array_agg(buid) AS bsn_tp_codes
    FROM {{ ref('ods_fims_fundcombusines') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    GROUP BY fundid
)
```

#### Ví dụ unpivot_cte (LATERAL VIEW stack, 1 leg per line)

```sql
leg_fu_co AS (
    SELECT id AS ip_code, type_code, address_value
    FROM {{ ref('ods_fims_fundcompany') }}
    LATERAL VIEW stack(4,
        'EMAIL', email,
        'FAX', fax,
        'PHONE', telephone,
        'WEBSITE', website
    ) AS (type_code, address_value)
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND address_value IS NOT NULL
)
```

### Quy tắc Main SELECT (Atomic)

| Transformation | Kết quả |
|---|---|
| `hash_id(...)` | **Đổi thành dbt macro** — `{{ generate_surrogate_key_bigint(...) }}`, không CAST |
| Biểu thức khác + Data Type | `CAST(<transformation> AS <data_type>)` |
| Trống + Data Type | `CAST(NULL AS <data_type>)` |

**Data Type** luôn bắt buộc trong mapping atomic (khác Staging).

**Ví dụ Main SELECT atomic:**

```sql
SELECT
    {{ generate_surrogate_key_bigint('FIMS_FUNDCOMPANY', fu_co.id) }} AS fnd_mgt_co_id,
    CAST(fu_co.id AS string)                                          AS fnd_mgt_co_code,
    CAST('FIMS_FUNDCOMPANY' AS string)                                AS src_stm_code,
    CAST(fu_co.capital AS decimal(23,2))                              AS charter_cptl_amt,
    CAST(NULL AS date)                                                AS license_dcsn_dt
FROM fu_co
    LEFT JOIN fu_bu ON fu_co.id = fu_bu.fundid
;
```

### Shared Entity mode (UNION ALL) — Atomic only

**Detection:** Có `UNION ALL` trong section Final Filter (hoặc có dòng `unpivot_cte` trong Input).

Logic build SELECT:
1. Trích leg aliases từ UNION ALL clause (`SELECT * FROM <alias>`)
2. Transformation cell dùng `;`-separated — phần thứ `i` cho leg thứ `i`; phần trống → `CAST(NULL AS dtype)`
3. Mỗi leg = 1 SELECT block, nối bằng `UNION ALL`

### Final Filter (Atomic)

| Clause Type | Render |
|---|---|
| `WHERE` | `WHERE <expr>` (nhiều row → join `AND`, xuống dòng tại AND/OR) |
| `GROUP BY` | `GROUP BY <expr>` |
| `HAVING` | `HAVING <expr>` |
| `ORDER BY` | `ORDER BY <expr>` |
| `UNION ALL` | Trigger shared_entity mode |

### Format WHERE có AND/OR (áp dụng mọi tầng)

```sql
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
        AND status = 'LIVE'
```

---

## Khi nào chạy lại

| Nguồn thay đổi | Action |
|---|---|
| File mapping CSV thay đổi | Chạy lại script tương ứng cho file đó |
| Đổi output format/rule | Chạy `--all` để regen toàn bộ tầng đó |

Script **không tracking dependency** — user phải tự gọi khi mapping thay đổi.
