# etl_logic — Ví dụ đúng theo từng type

## `direct` — map thẳng từ driving table

```csv
"Fund Management Company Dimension","fnd_mgt_co_dim","Company Code","co_code","false","Text","string","BK",
"Mã CTQLQ — BK join anchor ETL",
"fnd_mgt_co.fnd_mgt_co_code","direct","Fund Management Company","fnd_mgt_co","Fund Management Company Code","fnd_mgt_co_code"
```

**Đặc điểm:** `etl_logic = table.column` — không có dấu `=` ở đầu; `atomic_table` là driving table.

---

## `computed` — tính từ Atomic cols

```csv
"Calendar Date Dimension","cdr_dt_dim","Year","yr","true","Small Counter","int","",
"Năm (YYYY)",
"YEAR(cdr_dt.cdr_dt)","computed","Calendar Date","cdr_dt","Calendar Date","cdr_dt"
```

```csv
"Fact Fund Management Company Snapshot","fct_fnd_mgt_co_snpst","Active Company Count","actv_co_cnt","true","Small Counter","int","",
"Số CTQLQ đang hoạt động",
"COUNT(fnd_mgt_co.fnd_mgt_co_id) WHERE fnd_mgt_co.lcs_code='ACTIVE'","computed","Fund Management Company","fnd_mgt_co","Fund Management Company Id","fnd_mgt_co_id"
```

**Đặc điểm:** SQL function hoặc arithmetic expression; column reference vẫn có `table.` prefix.

---

## `lookup_date` — FK → Calendar Date Dimension

```csv
"Fact Fund Management Company Snapshot","fct_fnd_mgt_co_snpst","Snapshot Date Dimension Id","snpst_dt_dim_id","false","Surrogate Dimension Key","string","FK → Calendar Date Dimension",
"FK ngày báo cáo",
"LOOKUP cdr_dt_dim ON cdr_dt_dim.dt = rpt_impr_val.rpt_dt","lookup_date","Report Import Value","rpt_impr_val","Report Date","rpt_dt"
```

**Đặc điểm:** `source_entity/atomic_table/atomic_column` phản ánh join key từ driving table (`rpt_impr_val.rpt_dt`), không phải Calendar Date Dimension.

---

## `lookup_dim` — FK → SCD4A Dimension qua BK (current state)

```csv
"Fact Fund Management Company Snapshot","fct_fnd_mgt_co_snpst","Fund Management Company Dimension Id","fnd_mgt_co_dim_id","false","Surrogate Dimension Key","string","FK → Fund Management Company Dimension",
"FK CTQLQ",
"LOOKUP fnd_mgt_co_dim ON fnd_mgt_co_dim.co_code = rpt_impr_val.fnd_mgt_co_code","lookup_dim","Report Import Value","rpt_impr_val","Fund Management Company Code","fnd_mgt_co_code"
```

**Đặc điểm:** `source_entity/atomic_table/atomic_column` = join key từ driving table. Dimension dùng SCD4A (current state) — không có `eff_dt`/`expiry_dt`, lookup đơn giản qua natural key.

---

## `join_atomic` — cột từ Atomic table khác driving

```csv
"Foreign Investor 360 Profile","frgn_ivsr_360_prfl","Custodian Bank Name","cstd_bnk_nm","true","Text","string","",
"Tên NHLK — driving=frgn_ivsr",
"INNER JOIN cstd_bnk ON cstd_bnk.cstd_bnk_id = frgn_ivsr.cstd_bnk_id → cstd_bnk.cstd_bnk_nm","join_atomic","Custodian Bank","cstd_bnk","Custodian Bank Name","cstd_bnk_nm"
```

**Đặc điểm:** `source_entity/atomic_table/atomic_column` = bảng **joined** (cstd_bnk), không phải driving. Ghi rõ INNER/LEFT JOIN.

### ✅ join_atomic — ưu tiên surrogate key (_id)

```csv
"Practitioner 360 Profile","opr_prac_360_profile","Identification Number","identn_nbr","true","Text","string","",
"Số CCCD/Hộ chiếu NHN — LEFT JOIN ip_alt_identn qua scr_prac_id (surrogate key)",
"LEFT JOIN ip_alt_identn ON ip_alt_identn.ip_id = scr_prac.scr_prac_id AND ip_alt_identn.identn_tp_code IN ('CCCD','PASSPORT') → ip_alt_identn.identn_nbr","join_atomic","Involved Party Alternative Identification","ip_alt_identn","Identification Number","identn_nbr"
```

### ❌ join_atomic — sai khi dùng business code thay surrogate key

```csv
-- SAI: ip_code là business code, không phải FK thực sự
"LEFT JOIN ip_alt_identn ON ip_alt_identn.ip_code = scr_prac.scr_prac_code AND ..."
```

**Quy tắc:** Khi join 2 Atomic table, tra entity YAML để tìm FK attribute (thường có comment `"FK target: <table>.<column>"`). Dùng surrogate `_id` nếu có — không suy luận join key từ tên cột tương đồng.

---

## `join_atomic` multi-hop — qua bảng trung gian

```csv
"Fact Foreign Investor Capital Flow","fct_frgn_ivsr_cptl_flow","Investor Dimension Id","ivsr_dim_id","false","Surrogate Dimension Key","string","FK → Foreign Investor Dimension",
"FK NĐT — driving=mbr_rpt_val",
"INNER JOIN mbr_reg_rpt ON mbr_reg_rpt.mbr_reg_rpt_id = mbr_rpt_val.mbr_reg_rpt_id → LOOKUP frgn_ivsr_dim ON frgn_ivsr_dim.ivsr_id = mbr_reg_rpt.frgn_ivsr_id","lookup_dim","Member Regulatory Report","mbr_reg_rpt","Foreign Investor Id","frgn_ivsr_id"
```

**Đặc điểm:** Hop cuối là LOOKUP → `etl_logic_type = lookup_dim`. `source` phản ánh bảng cuối chain (`mbr_reg_rpt`).

---

## `pivot` — fanout 1 row thành nhiều rows

```csv
"Securities Offering 360 Profile","scr_ofrg_360_prfl","Offering Type Category Code","ofrg_tp_cgy_code","false","Text","string","",
"Branch key — ETL emit 1 row per branch",
"'PUBLIC' UNION ALL 'PRIVATE' UNION ALL 'OTHER'","pivot","Public Company Securities Offering","company_securities_issuance","Offering Type Category Code","ofrg_tp_cgy_code"
```

```csv
"Securities Offering 360 Profile","scr_ofrg_360_prfl","Planned Offering Quantity","pln_ofrg_qty","true","Small Counter","int","",
"Số lượng CK dự kiến theo loại hình",
"company_securities_issuance.plan_shareholder_qty -- PUBLIC
UNION ALL company_securities_issuance.plan_single_qty -- PRIVATE
UNION ALL company_securities_issuance.planned_security_qty - (company_securities_issuance.plan_shareholder_qty + company_securities_issuance.plan_single_qty) -- OTHER",
"pivot","Public Company Securities Offering","company_securities_issuance","Planned Security Quantity / Planned Existing Shareholder Offering Quantity / Planned Private Placement Offering Quantity","planned_security_qty / plan_shareholder_qty / plan_single_qty"
```

**Đặc điểm:** Số branch và thứ tự đồng nhất giữa branch-key và value cols. Branch residual (`OTHER`) flatten hoàn toàn. Mọi branch có `-- BRANCH_NAME` comment.

---

## `pending` — chưa có Atomic source

```csv
"Advisory Firm Rating Report","adv_firm_rtg_rpt","Advisory Firm Name","adv_firm_nm","true","Text","string","",
"Tên đơn vị tư vấn — PENDING",
"","pending","","","",""
```

**Đặc điểm:** `etl_logic` trống; `source_entity` trống; `etl_logic_type = pending`. Không dùng `Generated` cho pending — `Generated` chỉ dành riêng cho Surrogate Key (PK) và Surrogate Dimension Key (FK).
