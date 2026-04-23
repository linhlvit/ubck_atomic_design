---
name: gen-code
description: |
  Generate formatted SQL code từ mapping CSV của tầng Silver.
  Sử dụng khi: gen SQL từ file mapping, build ETL SQL cho silver entity,
  chạy pipeline sinh code, convert mapping → SQL có CTE + CAST chuẩn.
  Script files nằm tại: Code/scripts/
---

# Gen Code Skill

Sinh file SQL đã format từ mapping CSV (output của `gen_mapping_silver`).

## Cấu trúc repo

```
ubck_atomic_design/
├── Mapping/
│   └── silver/<SS>/<entity>.csv        ← input
└── Code/
    ├── scripts/
    │   └── gen_code_silver.py           ← script này
    └── silver/
        ├── FMS/
        │   └── <entity>.sql             ← output
        ├── FIMS/
        ├── NHNCK/
        └── ...
```

---

## Chạy script

```bash
# 1 file cụ thể
python Code/scripts/gen_code_silver.py Mapping/silver/FIMS/fund_management_company_FIMS_FUNDCOMPANY.csv

# theo entity (tất cả SSC)
python Code/scripts/gen_code_silver.py --entity "Fund Management Company"

# theo source system
python Code/scripts/gen_code_silver.py --source-system FIMS

# tất cả
python Code/scripts/gen_code_silver.py --all

# in ra stdout thay vì ghi file
python Code/scripts/gen_code_silver.py --stdout <file>
```

**Input:** `Mapping/silver/<SS>/<entity>.csv`
**Output:** `Code/silver/<SS>/<entity>.sql` (encoding `utf-8`, tên file = tên mapping CSV, chỉ đổi extension)

---

## Cấu trúc SQL output

```
┌─ Program Header (block comment)
│
├─ WITH
│   <cte_1> AS (...),
│   <cte_2> AS (...),
│   ...
│
└─ SELECT
     <column list with CAST>
   FROM <primary_alias>
     LEFT JOIN ...
   WHERE ...
   ;
```

---

## Quy tắc build CTE

Pair detection: nếu `input_rows[i+1].Table Name == input_rows[i].Alias` → 2 dòng là 1 cặp, gộp lại thành 1 CTE.

| Pattern | Kết quả SQL |
|---|---|
| `physical_table` đứng riêng | 1 CTE đơn giản: `SELECT <cols> FROM <schema>.<table> WHERE <filter>` |
| `physical_table` + `derived_cte` (cặp, `Array<Text>`) | **Gộp thành 1 CTE**: `SELECT <agg_cols> FROM <schema>.<table> WHERE <filter> GROUP BY <fk>` — pre-aggregate tại nguồn, bỏ CTE trung gian `<alias>_raw` |
| `physical_table` + `unpivot_cte` (cặp, shared_entity) | 1 CTE với UNION ALL các legs: mỗi leg hardcode type_code, chỉ SELECT các cột value non-NULL |
| Không có cặp, chỉ có physical | Fallback: mỗi dòng 1 CTE |

### Ví dụ merged derived_cte

Mapping:
```
1,physical_table,bronze,FUNDCOMBUSINES,fu_bu_raw,"fundid, buid",data_date = ...
2,derived_cte,,fu_bu_raw,fu_bu,"fundid, array_agg(buid) AS business_type_codes",GROUP BY fundid
```

SQL:
```sql
fu_bu AS (
    SELECT fundid, array_agg(buid) AS business_type_codes
    FROM bronze.FUNDCOMBUSINES
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    GROUP BY fundid
)
```

### Ví dụ unpivot_cte (shared_entity)

Mapping:
```
1,physical_table,bronze,FUNDCOMPANY,fu_co,"id, email, fax, telephone, website, 'FIMS_FUNDCOMPANY' AS source_system_code",data_date = ...
2,unpivot_cte,,fu_co,leg_fu_co,ip_code=id | EMAIL:email | FAX:fax | PHONE:telephone | WEBSITE:website | source_system_code,address_value IS NOT NULL
```

SQL:
```sql
leg_fu_co AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        'FIMS_FUNDCOMPANY' AS source_system_code
    FROM bronze.FUNDCOMPANY
    WHERE data_date = ... AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax AS address_value,
        ...
    FROM bronze.FUNDCOMPANY
    WHERE data_date = ... AND fax IS NOT NULL
    UNION ALL
    ...
)
```

- `ip_code=<col>` → `<col> AS ip_code`
- `<TYPE>:<col>` → 1 leg SELECT với `'<TYPE>' AS type_code`, `<col> AS address_value`, và filter `<col> IS NOT NULL`
- passthrough (không có `:`) → carry-through column, giữ nguyên tên

---

## Quy tắc Main SELECT

| Transformation | Kết quả |
|---|---|
| `hash_id(...)` | **Giữ nguyên** — không cast (vì hash_id đã return string) |
| Biểu thức khác | `<transformation> :: <data_type>` (có khoảng trắng trước/sau `::` cho dễ đọc) |
| Trống (không có source_column) | `NULL :: <data_type>` |

**Alignment:** Tất cả `AS <target_column>` căn thẳng hàng (dựa vào expression dài nhất, cap 72 ký tự).

**Data type** lấy từ cột `Data Type` trong mapping (thường: `string`, `decimal(23,2)`, `date`, `timestamp`, `int`, ...).

**Comma placement:** Dấu phẩy đứng **cuối** mỗi dòng (trừ dòng cuối), KHÔNG dùng leading comma.

### Ví dụ Main SELECT

```sql
SELECT
    hash_id('FIMS_FUNDCOMPANY', fu_co.id)  AS fund_management_company_id,
    fu_co.id :: string                     AS fund_management_company_code,
    'FIMS_FUNDCOMPANY' :: string           AS source_system_code,
    fu_co.capital :: decimal(23,2)         AS charter_capital_amount,
    fu_co.datecreated :: timestamp         AS created_timestamp,
    NULL :: date                           AS license_decision_date,
    hash_id('FIMS_NATIONAL', fu_co.naid)   AS country_of_registration_id,
    fu_bu.business_type_codes :: string    AS business_type_codes
FROM fu_co
    LEFT JOIN fu_bu ON fu_co.id = fu_bu.fundid
    LEFT JOIN fu_ty ON fu_co.id = fu_ty.fundid
;
```

---

## FROM + JOIN

Lấy từ section `Relationship` của mapping:

- `Main Alias` cột đầu tiên có giá trị → primary alias (dùng trong `FROM <primary>`)
- Mỗi dòng còn lại: `<Join Type> <Join Alias> ON <Join On>` (indent 4 spaces)
- Không có row nào → chỉ `FROM <primary>`, không có join

---

## Final Filter

Từ section `Final Filter`, chỉ render clause có giá trị:

| Clause Type | Render |
|---|---|
| `WHERE` | `WHERE <expr>` (nhiều row WHERE → join với ` AND `, xuống dòng tại mỗi AND/OR) |
| `GROUP BY` | `GROUP BY <expr>` |
| `HAVING` | `HAVING <expr>` |
| `ORDER BY` | `ORDER BY <expr>` |
| `UNION ALL` | **Trigger shared_entity mode** (xem bên dưới) |

### Format WHERE có AND/OR

Biểu thức WHERE có nhiều điều kiện nối bằng `AND`/`OR` sẽ được xuống dòng, AND/OR đứng đầu dòng mới, indent sâu hơn 4 spaces so với WHERE. Áp dụng ở MỌI chỗ có WHERE (CTE physical, CTE merged, CTE unpivot leg, main query).

Ví dụ:
```sql
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
        AND status = 'LIVE'
```

---

## Shared Entity mode (UNION ALL)

**Detection:** Shared entity được phát hiện khi có **bất kỳ dòng `unpivot_cte`** nào trong section Input — không phụ thuộc vào UNION ALL clause (vì khi source system chỉ có 1 leg, Final Filter sẽ bỏ trống UNION ALL).

Logic build SELECT:

1. Liệt kê leg aliases:
   - Nếu có UNION ALL clause trong Final Filter → parse các alias từ `SELECT * FROM <leg>`
   - Nếu không có UNION ALL → dùng alias của các dòng `unpivot_cte` (thường = 1 leg duy nhất)
2. Tìm `first_leg` = alias hardcoded trong Mapping transformations (pattern `leg_<...>`). Fallback về leg đầu tiên nếu không tìm được.
3. Với mỗi leg, duplicate toàn bộ SELECT của mapping section:
   - Thay `first_leg` → `<leg_N>` trong mọi transformation
   - `FROM <leg_N>` (không có JOIN, không có WHERE)
4. Nếu có > 1 leg → nối bằng `UNION ALL`. Nếu chỉ 1 leg → chỉ 1 SELECT.

### Ví dụ shared_entity output

```sql
SELECT
    hash_id(leg_ba_mo.source_system_code, leg_ba_mo.ip_code) AS involved_party_id,
    CAST(leg_ba_mo.ip_code AS string)                        AS involved_party_code,
    CAST(leg_ba_mo.source_system_code AS string)             AS source_system_code,
    CAST(leg_ba_mo.type_code AS string)                      AS electronic_address_type_code,
    CAST(leg_ba_mo.address_value AS string)                  AS electronic_address_value
FROM leg_ba_mo
UNION ALL
SELECT
    hash_id(leg_br.source_system_code, leg_br.ip_code) AS involved_party_id,
    ...
FROM leg_br
UNION ALL
...
;
```

---

## Program Header format

Mỗi file SQL bắt đầu bằng block comment chuẩn:

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

- Split tên file bằng `_`
- Với mỗi từ: viết hoa **chỉ chữ cái đầu**, phần còn lại giữ nguyên (không lowercase rest)
- Join bằng space

**Lý do giữ nguyên phần còn lại:** Các acronym như `FMS`, `FIMS`, `NHNCK`, `FUNDCOMPANY` phải giữ nguyên uppercase, không chuyển thành `Fms`, `Fundcompany`.

**Ví dụ:**

| File | Program name |
|---|---|
| `fund_management_company_FIMS_FUNDCOMPANY` | `Fund Management Company FIMS FUNDCOMPANY` |
| `involved_party_electronic_address` | `Involved Party Electronic Address` |
| `securities_company_organization_unit_SCMS_CTCK_CHI_NHANH` | `Securities Company Organization Unit SCMS CTCK CHI NHANH` |

### Field trống

- `Created by:` / `Created date:` → để trống, user nhập tay khi merge
- Dòng modified entry → để trống (chỉ có dấu `* `), mỗi lần modify user thêm 1 dòng mới

---

## Encoding & format

- **Input CSV:** `utf-8-sig` (có BOM, để Excel/VSCode extension parse tiếng Việt đúng)
- **Output SQL:** `utf-8` (không BOM)
- **Indent:** 4 spaces (không tab, trừ bảng Modified management dùng `\t` để căn 3 cột)
- **Line ending:** `\n` (LF)

---

## Khi nào chạy lại

| Nguồn thay đổi | Action |
|---|---|
| File mapping CSV thay đổi | Chạy lại `gen_code_silver.py <mapping_file>` để regen SQL |
| Script `gen_mapping_silver.py` đổi output pattern | Chạy lại cả `gen_mapping_silver` → rồi `gen_code_silver --all` |
| Chỉ đổi format SQL (CAST rule, header, ...) | Chạy `gen_code_silver.py --all` để regen toàn bộ |

Script **không tracking dependency** — không auto-detect file mapping mới/đổi, user phải tự gọi.

---

## Pipeline tổng thể

```
1. Source DDL                         (Source/<SS>_Tables.csv + _Columns.csv)
   ↓ gen_reg_bronze.py
2. Bronze registry                    (Mapping/registries/gm_bronze_*.csv)
   ↓ (+ Silver HLD/LLD)
   ↓ gen_reg_silver.py
3. Silver registry                    (Mapping/registries/gm_silver_*.csv)
   ↓ gen_mapping_silver.py
4. Mapping CSV                        (Mapping/silver/<SS>/<entity>.csv)
   ↓ gen_code_silver.py               ← BƯỚC NÀY
5. SQL code                           (Code/silver/<SS>/<entity>.sql)
```
