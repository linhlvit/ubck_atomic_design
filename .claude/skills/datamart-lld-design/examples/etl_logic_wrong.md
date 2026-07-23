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

**Vấn đề:** `etl_logic` chỉ được để trống khi `key = PK` (Surrogate Key, `source_entity = Generated`) hoặc `etl_logic_type = pending`. **`BK` (business key, mọi loại bảng) vẫn phải có `etl_logic`/`etl_logic_type` đầy đủ** như attribute thường — BK là cột lấy giá trị thật từ Atomic (thường `direct` từ driving table), không phải cột generated.

```
❌ Sai — BK bị để trống vì nhầm tưởng giống PK:
datamart_entity = Inspection Team Dimension
datamart_attribute = Inspection Team Code
key             = BK
etl_logic_type  =            ← trống — SAI
etl_logic       =            ← trống — SAI

✅ Đúng:
key             = BK
etl_logic_type  = direct
etl_logic       = inspection_team.inspection_team_code
```

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

---

## SAI 8 — Thứ tự etl_logic ngược: giá trị trước, JOIN sau, thiếu `→`

```
❌ Sai (bài học module TT, 2026-07-21 — 19 dòng lỗi này lọt qua SELF-REVIEW):
etl_logic_type = join_atomic
etl_logic      = penalty_decision.issued_dt INNER JOIN penalty_decision_subject ON penalty_decision_subject.pd_subject_id = pd_subject_behavior.pd_subject_id AND penalty_decision_subject.src_stm_code = 'THANHTRA_PENALTY_DECISION_SUBJECT' INNER JOIN penalty_decision ON penalty_decision.pd_id = penalty_decision_subject.pd_id AND penalty_decision.src_stm_code = 'THANHTRA_PENALTY_DECISION'

Vấn đề: giá trị đích (penalty_decision.issued_dt) bị đặt Ở ĐẦU, JOIN clause đặt SAU — ngược thứ tự
đọc tự nhiên (ETL developer phải đọc hết JOIN mới quay lại đầu câu để biết cột nào được lấy).
Không có dấu `→` phân tách JOIN clause và cột giá trị — không phân biệt được đâu là điều kiện
join, đâu là cột trả về.

✅ Đúng — JOIN clause trước, cột giá trị SAU dấu →:
etl_logic_type = join_atomic
etl_logic      = INNER JOIN penalty_decision_subject ON penalty_decision_subject.pd_subject_id = pd_subject_behavior.pd_subject_id AND penalty_decision_subject.src_stm_code = 'THANHTRA_PENALTY_DECISION_SUBJECT'
                 INNER JOIN penalty_decision ON penalty_decision.pd_id = penalty_decision_subject.pd_id AND penalty_decision.src_stm_code = 'THANHTRA_PENALTY_DECISION'
                 → penalty_decision.issued_dt
```

**Vấn đề:** Mọi `etl_logic_type ∈ {join_atomic, lookup_dim, lookup_date}` có JOIN clause phải theo đúng thứ tự: **(1) JOIN clause(s) trước, theo đúng thứ tự hop; (2) dấu `→`; (3) cột giá trị cuối cùng sau `→`**. Đây không phải khác biệt văn phong — đọc ngược thứ tự khiến ETL developer dễ nhầm bảng nguồn của điều kiện JOIN với bảng nguồn của giá trị trả về, đặc biệt khi có multi-hop.

**Vấn đề:** LEFT JOIN → bảng con có thể không có record → cột phải nullable.

---

## SAI 9 — `lookup_dim`/`lookup_date` thiếu từ khóa `LOOKUP...ON`, dùng `WHERE` value-first hoặc `WHERE` sau `→`

```
❌ Sai (bài học module QLCB, 2026-07-23 — không có JOIN keyword nên sub-check thứ tự JOIN cũ không bắt được):
etl_logic_type = lookup_dim
etl_logic      = public_company_dim.public_company_dim_id WHERE public_company_dim.public_company_code = pc_securities_offering.pc_code

Vấn đề: không có JOIN keyword nên nhìn qua tưởng "hợp lệ" (không vi phạm thứ tự JOIN), nhưng đây
vẫn là lookup FK sang Dimension — thiếu từ khóa LOOKUP, và cột giá trị (public_company_dim_id) bị
đặt TRƯỚC điều kiện WHERE thay vì dùng cú pháp LOOKUP...ON chuẩn.

✅ Đúng:
etl_logic_type = lookup_dim
etl_logic      = LOOKUP public_company_dim ON public_company_dim.public_company_code = pc_securities_offering.pc_code
```

```
❌ Sai — multi-hop: JOIN clause đúng thứ tự (trước dấu →), nhưng hop lookup CUỐI (sau →) lại dùng
WHERE thay vì LOOKUP...ON (bài học module QLCB, 2026-07-23):
etl_logic_type = join_atomic
etl_logic      = INNER JOIN pc_securities_offering ON pc_securities_offering.pc_securities_offering_id = pc_securities_offering_result.pc_securities_offering_id
                 WHERE cdr_dt_dim.cdr_dt = pc_securities_offering.official_letter_dt
                 → cdr_dt_dim.cdr_dt_dim_id

Vấn đề: sub-check thứ tự JOIN cũ chỉ kiểm tra "JOIN nằm trước →" — pattern này PASS check đó vì
JOIN đúng thứ tự, nhưng phần lookup dimension cuối cùng (cdr_dt_dim) vẫn viết dạng WHERE value-first
thay vì LOOKUP...ON. Đồng thời etl_logic_type sai — hop cuối là lookup dimension nên phải là
lookup_date, không phải join_atomic.

✅ Đúng:
etl_logic_type = lookup_date
etl_logic      = INNER JOIN pc_securities_offering ON pc_securities_offering.pc_securities_offering_id = pc_securities_offering_result.pc_securities_offering_id
                 AND pc_securities_offering.src_stm_code = 'IDS_SECURITIES_OFFERING'
                 → LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt = pc_securities_offering.official_letter_dt
```

**Vấn đề:** `LOOKUP <dim> ON <dim>.<col> = <driving_or_joined_table>.<col>` là cú pháp bắt buộc cho MỌI lookup FK sang Dimension (`lookup_dim`/`lookup_date`) — kể cả khi không có JOIN clause phía trước (lookup trực tiếp từ driving table) lẫn khi có multi-hop JOIN phía trước (hop lookup luôn là hop cuối, ngay sau dấu `→`). Viết dạng `<dim>.<col> WHERE ...` (value-first, thiếu `LOOKUP`) hoặc `→ WHERE ...` (thiếu `LOOKUP...ON` ở hop cuối) đều sai format, kể cả khi không vi phạm sub-check thứ tự JOIN (vì bản thân không chứa `JOIN` keyword — chỉ chứa `WHERE`). Đồng thời khi hop cuối là lookup dimension, `etl_logic_type` phải phản ánh đúng (`lookup_dim`/`lookup_date`), không dùng `join_atomic`.
