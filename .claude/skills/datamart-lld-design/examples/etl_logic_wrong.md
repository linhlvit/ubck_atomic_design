# etl_logic — Các pattern sai cần tránh

## SAI 1 — `direct` nhưng cột không có trong driving table

```
❌ Sai:
datamart_entity = Fact Foreign Investor Capital Flow
etl_logic_type  = direct
etl_logic       = mbr_reg_rpt.frgn_ivsr_id
atomic_table    = mbr_rpt_val   ← driving table

Vấn đề: frgn_ivsr_id nằm trong mbr_reg_rpt, không phải driving table mbr_rpt_val
→ không thể lấy direct được.

✅ Đúng: đổi sang join_atomic hoặc lookup_dim:
etl_logic_type = lookup_dim
etl_logic      = INNER JOIN mbr_reg_rpt ON mbr_reg_rpt.mbr_reg_rpt_id = mbr_rpt_val.mbr_reg_rpt_id
                 → LOOKUP frgn_ivsr_dim ON frgn_ivsr_dim.ivsr_id = mbr_reg_rpt.frgn_ivsr_id
atomic_table   = mbr_reg_rpt   ← bảng cuối chain
```

---

## SAI 2 — `etl_logic` bắt đầu bằng dấu `=`

```
❌ Sai:
etl_logic_type = direct
etl_logic      = =fnd_mgt_co.fnd_mgt_co_code

✅ Đúng:
etl_logic_type = direct
etl_logic      = fnd_mgt_co.fnd_mgt_co_code
```

**Vấn đề:** Dấu `=` ở đầu là lỗi format — ETL reader sẽ parse thành expression assignment, không phải column reference.

---

## SAI 3 — `join_atomic` tham chiếu Dimension entity

```
❌ Sai:
etl_logic_type = join_atomic
etl_logic      = INNER JOIN fnd_mgt_co_dim ON fnd_mgt_co_dim.co_code = rpt_impr_val.fnd_mgt_co_code
                 → fnd_mgt_co_dim.co_nm
source_entity  = Fund Management Company Dimension   ← Dimension entity

Vấn đề: join_atomic phải tham chiếu Atomic entity, không phải Datamart Dimension entity.

✅ Đúng: join vào Atomic entity, sau đó lookup Dimension nếu cần FK:
etl_logic_type = lookup_dim
etl_logic      = LOOKUP fnd_mgt_co_dim ON fnd_mgt_co_dim.co_code = rpt_impr_val.fnd_mgt_co_code
                 AND rpt_impr_val.rpt_dt BETWEEN fnd_mgt_co_dim.eff_dt AND fnd_mgt_co_dim.expiry_dt
source_entity  = Report Import Value   ← Atomic entity (driving)
```

---

## SAI 4 — Column reference thiếu `table.` prefix

```
❌ Sai:
etl_logic_type = computed
etl_logic      = COUNT(fnd_mgt_co_id) WHERE lcs_code='ACTIVE'

✅ Đúng:
etl_logic_type = computed
etl_logic      = COUNT(fnd_mgt_co.fnd_mgt_co_id) WHERE fnd_mgt_co.lcs_code='ACTIVE'
```

**Vấn đề:** Thiếu `table.` prefix → ETL developer không biết column lấy từ bảng nào khi có nhiều bảng join.

---

## SAI 5 — Pivot: số branch không đồng nhất

```
❌ Sai — branch key có 3 giá trị, value col có 4 branch:
-- Branch key:
'PUBLIC' UNION ALL 'PRIVATE' UNION ALL 'OTHER'

-- Value col:
tbl.plan_shareholder_qty -- PUBLIC
UNION ALL tbl.plan_single_qty -- PRIVATE
UNION ALL tbl.plan_esop_qty -- ESOP      ← branch thừa không có trong branch key
UNION ALL tbl.planned_qty - (...) -- OTHER

✅ Đúng — số branch và thứ tự phải đồng nhất:
-- Branch key:
'PUBLIC' UNION ALL 'PRIVATE' UNION ALL 'ESOP' UNION ALL 'OTHER'

-- Value col:
tbl.plan_shareholder_qty -- PUBLIC
UNION ALL tbl.plan_single_qty -- PRIVATE
UNION ALL tbl.plan_esop_qty -- ESOP
UNION ALL tbl.planned_qty - (tbl.plan_shareholder_qty + tbl.plan_single_qty + tbl.plan_esop_qty) -- OTHER
```

---

## SAI 6 — etl_logic để trống cho attribute READY

```
❌ Sai:
datamart_attribute = Company Name
etl_logic_type     = direct
etl_logic          =            ← trống dù đây là attribute READY
source_entity      = Fund Management Company

✅ Đúng:
etl_logic_type = direct
etl_logic      = fnd_mgt_co.co_nm
```

**Vấn đề:** `etl_logic` chỉ được để trống khi `key ∈ {PK, NK, BK}` hoặc `etl_logic_type = pending`. Attribute READY khác phải có `etl_logic` đầy đủ.

---

## SAI 7 — LEFT JOIN nhưng nullable = false

```
❌ Sai:
etl_logic  = LEFT JOIN cstd_bnk ON cstd_bnk.cstd_bnk_id = frgn_ivsr.cstd_bnk_id → cstd_bnk.cstd_bnk_nm
nullable   = false   ← sai — LEFT JOIN có thể trả NULL

✅ Đúng:
etl_logic  = LEFT JOIN cstd_bnk ON cstd_bnk.cstd_bnk_id = frgn_ivsr.cstd_bnk_id → cstd_bnk.cstd_bnk_nm
nullable   = true
```

**Vấn đề:** LEFT JOIN → bảng con có thể không có record → cột phải nullable.
