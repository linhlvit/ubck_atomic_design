---
name: datamart-lld-design
description: |
  Thiết kế Low-Level Design (LLD) cho Datamart layer — Phase 1, 2, 3 trong workflow thiết kế Datamart UBCKNN.
  Sử dụng khi: HLD + Entities đã được duyệt, cần thiết kế attribute mapping
  (Attributes.csv), mapping KPI (Detail_Mapping.csv), và sinh DDL flat table SQL.

  Output:
    Datamart/lld/{MODULE}/DTM_{MODULE}_{mart_table}.csv                        (Phase 1 — fact)
    Datamart/lld/{MODULE}/DTM_{MODULE}_{mart_table}_{src_stm_code}.csv         (Phase 1 — dim/operational)
    Datamart/lld/datamart_attributes.csv                                        (Phase 1 — master, append)
    Datamart/lld/DTM_{MODULE}_Detail_Mapping.csv                               (Phase 2)
    Datamart/flat-table/{MODULE}/01_create_{module}_flat_tables.sql            (Phase 3)
    Datamart/flat-table/{MODULE}/02_populate_{module}_flat_tables.sql          (Phase 3)

  Input bắt buộc Phase 1: DTM_{MODULE}_HLD.md + DTM_{MODULE}_Entities.csv đã duyệt + DataModel/Atomic/dm_manifest.yaml
---

# Skill: Thiết kế LLD Datamart

Đọc file này TRƯỚC KHI bắt đầu Phase 1/2/3 cho bất kỳ module nào.

## Tài nguyên đi kèm

- **Reference:**
  - [`reference/phase1_attributes.md`](reference/phase1_attributes.md) — 15 cột CSV, etl_logic_type, ràng buộc key/nullable (Phase 1)
  - [`reference/phase2_detail_mapping.md`](reference/phase2_detail_mapping.md) — column_role, logic format, xử lý PENDING/Doing (Phase 2)
  - [`reference/phase3_flat_table.md`](reference/phase3_flat_table.md) — data type mapping, ENGINE/PARTITION, pattern CREATE + POPULATE (Phase 3)
- **Examples:**
  - [`examples/etl_logic_correct.md`](examples/etl_logic_correct.md) — ví dụ đại diện mỗi etl_logic_type
  - [`examples/etl_logic_wrong.md`](examples/etl_logic_wrong.md) — pattern sai etl_logic
  - [`examples/key_constraints.md`](examples/key_constraints.md) — ràng buộc key × bảng type + ví dụ vi phạm

## Điều kiện tiên quyết

- [ ] `Datamart/hld/DTM_{MODULE}_HLD.md` tồn tại và đã được user duyệt
- [ ] `Datamart/hld/DTM_{MODULE}_Entities.csv` tồn tại và đã được user duyệt (có cột `reuse_status`)
- [ ] `DataModel/Atomic/dm_manifest.yaml` tồn tại — **entry point tra cứu Atomic entities đã approved**
- [ ] `DataModel/datamart_model.yaml` tồn tại — registry schema cross-module (có thể rỗng nếu module đầu tiên)
- [ ] `Datamart/lld/datamart_attributes.csv` tồn tại (có thể rỗng nếu module đầu tiên)
- [ ] `BRD/BA/BA_analyst_{MODULE}.csv` tồn tại (cần cho Phase 2)
- [ ] `DataModel/working/Atomic/lld/classification_schemes.yaml` tồn tại (cần khi map từ danh mục CV)

> **QUYẾT ĐỊNH CỨNG:** Claude KHÔNG được đoán `source_entity` hay `source_attribute`.
> Mọi mapping phải tra cứu trực tiếp từ entity YAML files trong `DataModel/Atomic/`.
>
> **Quy trình tra cứu Atomic:**
> 1. Mở `dm_manifest.yaml` → tìm entry có `physical_name` khớp `atomic_table` đang cần
> 2. Đọc `subfolder` + `file_name` → mở file `DataModel/Atomic/{subfolder}/{file_name}`
> 3. Lấy `ldm.physical_name` = `atomic_table`, `attribute.physical_name` = `atomic_column`
> 4. **Nhiều source table cùng `physical_name`:** đọc TẤT CẢ entry cùng `physical_name` — không dừng ở entry đầu
> 5. **`src_stm_code` value:** trích từ `classification_context` của attribute `Source System Code` — format `"Source System Code = 'VALUE'"` → value = `VALUE`

---

## QUY TRÌNH (BẮT BUỘC)

```
Phase 0 (PLAN):
           Claude đọc HLD (Section 2) + Entities.csv → trích danh sách nhóm báo cáo
           → với mỗi nhóm: liệt kê KPI IDs + bảng cần thiết kế (new/partial) + bảng reuse
           → dim dùng chung: nhóm đầu tiên dùng → thiết kế; nhóm sau → check datamart_model.yaml
             (reuse nếu đủ cột / partial nếu thiếu cột)
           → trình bày plan tổng dạng bảng (xem định dạng bên dưới)
           → DỪNG chờ human approve plan → sau khi approve mới bắt đầu Nhóm 1

Loop mỗi nhóm N — Phase 1 (HOÀN THÀNH TOÀN BỘ NHÓM TRƯỚC KHI CHUYỂN PHASE 2):
  Phase 1:   Đọc reuse_status từ Entities.csv cho các bảng của nhóm N
             → dim dùng chung đã thiết kế ở nhóm trước: check datamart_model.yaml
               → đủ cột → bỏ qua (reuse) | thiếu cột → báo delta, DỪNG chờ approve delta
             → bảng new/partial: đọc datamart_model.yaml lấy baseline (nếu partial)
             → xác định driving table + src_stm_code → sinh từng file
             → SELF-REVIEW 5 TC → sửa nếu FAIL → trình bày SELF-REVIEW + file
             → DỪNG chờ human duyệt từng file
             → hỏi merge master → DỪNG chờ human xác nhận merge
             → ghi datamart_model.yaml (upsert new / append delta)
             → làm Nhóm N+1 Phase 1 → ... → làm đến hết Nhóm cuối Phase 1

> **GATE CỨNG — chuyển Phase 2:**
> ❌ KHÔNG được bắt đầu Phase 2 khi còn bất kỳ nhóm nào chưa hoàn thành Phase 1.
> Điều kiện bắt buộc: **tất cả nhóm** (Nhóm 1 → Nhóm N_max) đã có file Attributes được human approve và merge vào master.
> Trước khi chuyển Phase 2: liệt kê toàn bộ nhóm + trạng thái Phase 1 → báo cáo human → DỪNG chờ xác nhận.

Loop mỗi nhóm N — Phase 2 (sau khi TOÀN BỘ Phase 1 đã xong):
  Phase 2:   Cross-check BA ↔ HLD cho KPI của nhóm N → báo gap nếu có
             → DỪNG chờ human xử lý gap (nếu có)
             → xuất block KPI nhóm N → append vào DTM_{MODULE}_Detail_Mapping.csv
             → SELF-REVIEW 4 TC → sửa nếu FAIL → trình bày SELF-REVIEW + block KPI
             → DỪNG chờ human duyệt block KPI nhóm N
             → làm Nhóm N+1 Phase 2 → ... → làm đến hết Nhóm cuối Phase 2

  → Sau khi human approve toàn bộ Phase 2:
             DỪNG — báo "Tất cả nhóm Phase 2 hoàn thành." → chờ human xác nhận chuyển Phase 3

Phase 3:   Sau khi tất cả nhóm đã duyệt → báo số bảng flat
           → DỪNG chờ human xác nhận
           → sinh 2 file SQL → DỪNG chờ human duyệt
```

### Định dạng Plan tổng (Phase 0 output)

```
## Plan thiết kế LLD — {MODULE}

| Nhóm | Tên nhóm | KPI IDs | Bảng cần thiết kế | Bảng reuse |
|------|----------|---------|-------------------|------------|
| 1    | Tên nhóm 1 | K_X_1, K_X_2 | Fact A (new), Dim B (new) | Calendar Date Dimension |
| 2    | Tên nhóm 2 | K_X_3       | Operational C (new)      | Dim B (reuse — đã thiết kế Nhóm 1) |
| ...  | ...        | ...          | ...                       | ... |

Dim dùng chung:
- Calendar Date Dimension: reuse toàn module (không thiết kế lại)
- Dim B: thiết kế ở Nhóm 1, các nhóm sau check datamart_model.yaml

Tổng: N nhóm | M bảng new | P bảng partial | Q bảng reuse

→ Xác nhận plan để bắt đầu Nhóm 1?
```

> **GATE RULE — BẮT BUỘC TUYỆT ĐỐI:**
> - Claude **KHÔNG ĐƯỢC** tự bỏ qua bất kỳ GATE nào, dù kết quả có vẻ hiển nhiên hay không có vấn đề gì.
> - Tại mỗi GATE: **DỪNG hoàn toàn**, đặt câu hỏi xác nhận rõ ràng, **chờ human trả lời** trước khi tiếp tục.
> - Human chưa trả lời = chưa được phép tiếp tục. Không được suy diễn "im lặng = đồng ý".
> - Không được gộp nhiều GATE vào 1 câu hỏi — mỗi GATE là 1 điểm dừng độc lập.

---

## PHASE 0 — PLAN

**Bắt buộc thực hiện trước Phase 1.** Mục đích: human nắm toàn bộ scope, approve một lần, Claude chạy từng nhóm.

### Bước P1 — Đọc HLD Section 2

Đọc `DTM_{MODULE}_HLD.md` Section 2 → trích danh sách nhóm báo cáo:
- Tên nhóm (Nhóm 1, Nhóm 2, ...)
- KPI IDs thuộc nhóm (bao gồm Chiều + Pending)

### Bước P2 — Map bảng cho từng nhóm

Đọc `DTM_{MODULE}_Entities.csv` → với mỗi nhóm:
1. Xác định bảng nào phục vụ nhóm đó (từ Source trong HLD Section 2)
2. Kiểm tra `reuse_status` từ Entities.csv
3. **Dim dùng chung:**
   - Conformed dim (Calendar Date Dimension): luôn reuse — không thiết kế lại ở bất kỳ nhóm nào
   - Dim nội bộ module: nhóm đầu tiên dùng → gán `new`; nhóm sau → gán `reuse` (check `datamart_model.yaml` trước)
   - Nếu `datamart_model.yaml` có entry nhưng thiếu cột → gán `partial` cho nhóm đó, sẽ báo delta khi đến nhóm đó

### Bước P3 — Trình bày plan và GATE

Format plan tổng (bắt buộc dùng bảng):

```
## Plan thiết kế LLD — {MODULE}

| Nhóm | Tên nhóm | KPI IDs | Bảng cần thiết kế | Bảng reuse/bỏ qua |
|------|----------|---------|-------------------|-------------------|
| 1    | <tên>    | K_X_1, K_X_2 | Fact A (new), Dim B (new) | Calendar Date Dimension (reuse) |
| 2    | <tên>    | K_X_3   | Operational C (new)  | Fact A (reuse), Dim B (reuse) |
| ...  |          |         |                      |                    |

Ghi chú dim dùng chung:
- <Dim name>: thiết kế ở Nhóm X, các nhóm sau reuse (check datamart_model.yaml)
- Calendar Date Dimension: conformed dim — reuse toàn module

Tổng: [N] nhóm | [M] bảng new | [P] bảng partial | [Q] bảng reuse

→ Xác nhận plan để bắt đầu Nhóm 1?
```

> **GATE — bắt buộc dừng:** Chờ human approve plan trước khi bắt đầu bất kỳ nhóm nào.
> ❌ KHÔNG bắt đầu Phase 1 Nhóm 1 khi chưa có xác nhận plan.

---

## PHASE 1 — ATTRIBUTES CSV

Đọc [`reference/phase1_attributes.md`](reference/phase1_attributes.md) đầy đủ trước khi bắt đầu.

**Input Phase 1:**
- `Datamart/hld/DTM_{MODULE}_Entities.csv` — danh sách entity, table_type, reuse_status, source_table đã duyệt
- `Datamart/lld/datamart_attributes.csv` — master hiện tại (cần cho partial flow)

**Bước 0 — Đọc reuse_status từ Entities.csv:**
- `reuse` → bỏ qua hoàn toàn, không sinh file, ghi note: "Bảng [datamart_table] reuse từ master — không thiết kế mới"
- `new` → thiết kế đầy đủ, sinh file
- `partial` → đọc `DataModel/datamart_model.yaml` (entry có `id = DTM-{datamart_table}`), lấy `columns` hiện có làm baseline → so sánh delta → **báo cáo human, DỪNG chờ approve** trước khi sinh file
  > ❌ **KHÔNG được sinh file partial** khi chưa có xác nhận của human về delta.

**Bước 0b — Trình bày danh sách file sẽ sinh cho nhóm N (GATE — chờ human xác nhận trước khi sinh):**

Trước khi trình bày: với bảng `partial` → đọc `DataModel/datamart_model.yaml` lấy `datamart_table` physical name đã ghi (không đặt lại tên). Sau khi xác định driving table và `src_stm_code` cho từng bảng `new`/`partial` của nhóm N, trình bày bảng tóm tắt:

```
Nhóm [N] — [Tên nhóm]: danh sách file sẽ sinh

| STT | Tên file | table_type | Driving Table | src_stm_code |
|-----|----------|------------|---------------|--------------|
| 1   | DTM_NHNCK_scr_prac_conduct_vln_NHNCK_VIOLATIONS.csv | dim | scr_prac_conduct_vln | NHNCK_VIOLATIONS |
| 2   | DTM_NHNCK_fct_prac_exam_rslt.csv | fact | — | — |
| 3   | ... | ... | ... | ... |

Bảng reuse/bỏ qua nhóm này: [danh sách tên bảng + lý do]

→ Xác nhận để tiến hành sinh file nhóm [N]?
```

> **GATE — bắt buộc dừng:** Chờ human xác nhận danh sách của nhóm trước khi điền 15 cột bất kỳ file nào.
> ❌ **KHÔNG được bắt đầu điền nội dung file** khi chưa có xác nhận của human. Nếu driving table hoặc src_stm_code sai → sửa, trình bày lại bảng, chờ xác nhận lại.

Xem quy trình chi tiết trong [`reference/phase1_attributes.md`](reference/phase1_attributes.md).

### Bước 1 — Xác định Driving Table

Bắt buộc xác định Driving Table trước khi điền `etl_logic`:

| Loại bảng | Driving Table |
|---|---|
| Fact Event / Snapshot | Atomic entity có grain tương đương |
| Tác nghiệp | Atomic entity của đối tượng chính |
| Dimension | Atomic entity tương ứng |

Ghi rõ Driving Table trong `description` của row PK/BK.

**Driving Table khi Fact không có join key chung (No Driving Table):**
Fact dùng pattern CROSS JOIN scalar subquery (mỗi measure aggregate độc lập từ 1 Atomic table) — không có driving table. Không thêm `src_stm_code` cho loại bảng này.

### Bước 1b — Bổ sung `src_stm_code` cho Dimension và Operational

Mọi bảng `dim` và `operational` **phải có** attribute `src_stm_code` (thêm cuối danh sách attribute của bảng).

**Xác định driving table để lấy `src_stm_code`:** Driving table = bảng chính của grain — bảng có PK/BK trong Attributes, các attribute của nó dùng `etl_logic_type = direct`. Bảng phụ (`etl_logic_type = join_atomic`) **không dùng** để xác định `src_stm_code`.

| Trường hợp | ETL Logic | etl_logic_type |
|---|---|---|
| Driving table single-source | `<driving_table>.src_stm_code WHERE <driving_table>.src_stm_code = '<value>'` | `direct` |
| Driving table multi-source (nhiều nguồn, lấy 1 chính thức) | `<driving_table>.src_stm_code WHERE <driving_table>.src_stm_code = '<value>'` | `direct` |
| Driving table multi-source (nhiều nguồn, lấy nhiều) | `<driving_table>.src_stm_code WHERE <driving_table>.src_stm_code IN ('<val1>','<val2>')` | `direct` |
| Multi-source tách bộ (xem bên dưới) | `<atomic_table>.src_stm_code WHERE <partition_key> = '<value>'` | `direct` hoặc `pending` |

**Quy tắc WHERE filter bắt buộc (forward-compatibility):**
Mọi `src_stm_code` attribute **luôn phải có điều kiện lọc** — kể cả khi Atomic driving table hiện chỉ có 1 nguồn. Lý do: nếu sau này Atomic nhận thêm nguồn mới, Datamart ETL không bị ảnh hưởng mà không cần sửa schema.

1. Single-source: `WHERE <driving_table>.src_stm_code = '<giá_trị>'`
2. Multi-source lấy 1 chính thức: `WHERE <driving_table>.src_stm_code = '<giá_trị_chính_thức>'`
3. Multi-source lấy nhiều: `WHERE <driving_table>.src_stm_code IN ('<val1>','<val2>',...)`
4. Vẫn dùng `etl_logic_type = direct` cho tất cả trường hợp trên

**Xử lý multi-source — Tách bộ (UNION/Partition pattern):**
Áp dụng khi bảng Datamart populate từ **nhiều nguồn độc lập** theo 1 trong 2 trường hợp:

| Trường hợp | Mô tả | Ví dụ |
|---|---|---|
| **A — Partition trên 1 Atomic table** | 1 Atomic table chứa nhiều nhóm data phân biệt qua 1 partition key, mỗi nhóm có `src_stm_code` riêng | `cv` phân biệt theo `scm_code` — mỗi scheme có `src_stm_code` khác nhau |
| **B — UNION nhiều Atomic tables** | Datamart populate từ N Atomic tables độc lập, mỗi table có schema/grain riêng | Bảng tổng hợp từ `insp_case` + `surveil_nfrc_case` + ... |

Cách xử lý tách bộ:
1. **Tách thành N bộ attribute** — 1 bộ per partition value (scheme) hoặc per Atomic table
2. **Mỗi bộ** gồm đầy đủ tất cả attribute của bảng (PK/NK/BK + các cột + `src_stm_code`)
3. **`src_stm_code`** của mỗi bộ map từ Atomic source tương ứng
4. Nếu Atomic source chưa xác định → `etl_logic_type = pending` toàn bộ bộ đó
5. **Tên cột** `datamart_column` align với tên cột Atomic source tương ứng

**Trường hợp đặc biệt — Conformed Classification Dimension (`cl_dim`):**
- Tách theo `scm_code` (scheme) — mỗi scheme = 1 bộ 5 dòng
- Tên cột align với Atomic `cv`: `scm_code`, `cl_code`, `cl_nm`
- Scheme load từ `cv` → `etl_logic = cv.<col> WHERE cv.scm_code = '<SCHEME>'`, `etl_logic_type = direct`
- Scheme ETL-generated (không qua `cv`) → `etl_logic_type = pending` toàn bộ bộ
- **Detail Mapping**: tên logical dùng `Scheme Code=` và `Classification Code=` (không phải `Scheme=` / `Code=`)

Spec row `src_stm_code`:
```
nullable=false | data_domain=Classification Value | data_type=string | key=(trống)
source_entity=<tên Atomic entity của driving table / Atomic table tương ứng bộ>
atomic_table=<driving_table> | source_attribute=Source System Code | atomic_column=src_stm_code
```

### Bước 2 — Tra entity YAML files

Với mỗi attribute cần map:
1. **Bảng `partial`:** đọc `DataModel/datamart_model.yaml` → lấy `columns` hiện có làm baseline — chỉ tra entity YAML Atomic cho delta columns mới
2. **Bảng `new` và delta columns:** Tra `dm_manifest.yaml` → tìm entry theo `physical_name` → đọc file YAML tương ứng trong `DataModel/Atomic/{subfolder}/`
3. Lấy `attribute.physical_name` xác nhận tên `atomic_column`
4. Xác định `etl_logic_type` theo rule trong [`reference/phase1_attributes.md`](reference/phase1_attributes.md)
5. Viết `etl_logic` đúng format

### Bước 3 — Xuất CSV

Header 15 cột:
```
datamart_entity,datamart_table,datamart_attribute,datamart_column,nullable,data_domain,data_type,key,description,etl_logic,etl_logic_type,source_entity,atomic_table,source_attribute,atomic_column
```

Export encoding: **UTF-8 BOM** (`utf-8-sig`).
Mọi giá trị trong `etl_logic` và `description` phải được bao double-quote.

**Tên physical — quy tắc bắt buộc:** Xem mục **PHYSICAL NAMING RULE** bên dưới trước khi đặt tên bất kỳ `datamart_table` hay `datamart_column` nào.

---

## PHYSICAL NAMING RULE (BẮT BUỘC — đọc trước khi đặt tên cột/bảng)

**Nguồn sự thật:** `system/rules/rule_physical_name_exceptions_datamart.csv` — danh sách duy nhất các từ được phép viết tắt.

### Quy tắc cốt lõi

> **Chỉ những từ có trong `rule_physical_name_exceptions_datamart.csv` mới được viết tắt. Mọi từ khác phải dùng full word.**

Exceptions hiện tại (cố định, không được tự bổ sung):

| Full word | Abbreviation |
|---|---|
| address | adr |
| amount | amt |
| classification | cl |
| date | dt |
| dimension | dim |
| fact | fct |
| history | hist |
| id | id |
| name | nm |
| number | nbr |
| operational | opr |
| relationship | rltnp |
| report | rpt |
| scheme | scm |
| snapshot | snpst |
| source | src |
| system | stm |
| timestamp | tms |
| type | tp |
| value | val |
| volume | vol |

### Cách áp dụng

1. **Tách tên logical thành từng token** theo dấu cách
2. **Với mỗi token:**
   - Nếu từ có trong bảng exceptions → dùng dạng viết tắt tương ứng
   - Nếu không → dùng **đúng từ đó** dạng full word — **KHÔNG được thay bằng từ đồng nghĩa hay dạng mở rộng khác**
3. **Nối lại** bằng dấu gạch dưới `_`

> **Ràng buộc cốt lõi — bắt buộc:** Physical name phải derive trực tiếp từ **tên logical**, không được thay thế token bằng từ khác dù tương đồng về nghĩa. Quy tắc chỉ cho phép **viết tắt** các từ trong exceptions, không cho phép **mở rộng** hay **đổi từ**.
>
> Ví dụ vi phạm điển hình: logical "Exam Score" → physical `examination_score` ❌ — chữ "exam" bị mở rộng thành "examination" dù không được phép. Đúng phải là `exam_score` ✅.

**Ví dụ đúng:**
```
Certificate Type Code          →  certificate_tp_code             (type → tp; certificate KHÔNG có trong exceptions → full)
Practitioner Code              →  practitioner_code               (không có token nào trong exceptions)
Issue Decision Number          →  issue_decision_nbr              (number → nbr; issue, decision → full)
Organization Name              →  organization_nm                 (name → nm; organization → full)
Source System Code             →  src_stm_code                    (source → src; system → stm; code → full)
Snapshot Date                  →  snpst_dt                        (snapshot → snpst; date → dt)
Calendar Date                  →  calendar_dt                     (date → dt; calendar → full)
Practitioner Dimension ID      →  practitioner_dim_id             (dimension → dim; id → id; practitioner → full)
Fact Practitioner Daily Snpst  →  fct_practitioner_dly_snpst      (fact → fct; snapshot → snpst; practitioner → full)
Operational History            →  opr_hist                        (operational → opr; history → hist)
Classification Code            →  cl_code                         (classification → cl; code → full)
Scheme Code                    →  scm_code                        (scheme → scm; code → full)
Exam Score                     →  exam_score                      (exam, score KHÔNG có trong exceptions → full; giữ nguyên "exam", KHÔNG đổi thành "examination")
Exam Start Date                →  exam_start_dt                   (date → dt; exam, start → full)
```

**Ví dụ SAI (phổ biến trước đây):**
```
ctf_tp_code     ❌  (ctf không phải exception)          →   certificate_tp_code  ✅
prac_code       ❌  (prac không phải exception)         →   practitioner_code    ✅
trn_rslt_nm     ❌  (trn, rslt không phải exception)    →   training_result_nm   ✅
org_tp_nm       ❌  (org không phải exception)          →   organization_tp_nm   ✅
examination_score  ❌  (logical là "Exam Score" — "exam" bị mở rộng thành "examination")  →   exam_score  ✅
```

### Khi đặt tên `datamart_column`

- Mọi cột trong Attributes CSV phải tuân thủ rule này
- Khi kế thừa từ `atomic_column`: nếu Atomic column dùng tên chuẩn (ví dụ `sp_code`, `practitioner_position_at_rpt`) → giữ nguyên; chỉ đổi nếu Atomic column đang dùng sai convention
- Khi đặt tên mới (ETL-derived, computed): áp dụng rule từ đầu

### Khi review/detect lỗi

Nếu phát hiện `datamart_column` dùng từ viết tắt không có trong exceptions:
1. Tra `system/rules/rule_physical_name_exceptions_datamart.csv` xác nhận
2. Đây là **Kịch bản C — Lỗi thiết kế** → sửa trực tiếp file Attributes detail + `datamart_attributes.csv` + `Detail_Mapping.csv` + `HLD.md`
3. Dùng `grep -rn "tên_cũ" Datamart/` để tìm tất cả vị trí trước khi sửa

---

### Bước 4 — SELF-REVIEW trước khi trình bày kết quả

**Bắt buộc thực hiện sau khi sinh xong mỗi file, trước khi trình bày cho human duyệt.** Chạy 5 testcase sau và báo kết quả:

**TC1 — Số cột khớp HLD:**
- Đếm số attribute trong file CSV vừa sinh (theo `datamart_attribute` unique, không đếm multi-source row).
- Đối chiếu với bảng entity tương ứng trong `DTM_{MODULE}_HLD.md` (Section 3) — số cột trong bảng HLD.
- Báo: `✅ TC1 PASS: X cột — khớp HLD` hoặc `❌ TC1 FAIL: CSV có X cột, HLD có Y cột — Chênh: [danh sách cột thừa/thiếu]`.
- Nếu FAIL → sửa trước khi trình bày.

**TC2 — etl_logic_type hợp lệ:**
- Kiểm tra mọi row không phải PK/NK/BK: `etl_logic_type` không được trống.
- **Sub-check bắt buộc:** Với mỗi row có `etl_logic_type ∈ {direct, computed}`: kiểm tra `atomic_table` của row đó có phải driving table không. Nếu `atomic_table` khác driving table → phải đổi thành `join_atomic`. Ngoại lệ: `lookup_dim`, `lookup_date`, `pivot`, `pending` không áp dụng sub-check này.
- Kiểm tra đặc biệt: khi file CSV có nhiều `atomic_table` khác nhau (ký hiệu ` / ` hoặc nhiều row khác nhau) → bảng nào không phải driving phải dùng `join_atomic`.
- Báo: `✅ TC2 PASS` hoặc `❌ TC2 FAIL: [danh sách row sai etl_logic_type — ghi rõ atomic_table và driving table]`.
- Nếu FAIL → sửa trước khi trình bày.

**TC3 — Đầy đủ prefix table_name.column_name:**
- Kiểm tra mọi column reference trong `etl_logic` có dạng `<table>.<col>`.
- Ngoại lệ không cần prefix: literal values, SQL functions (`YEAR(...)`, `COUNT(...)`), NULL, ETL runtime parameter (`{etl_date}`).
- Báo: `✅ TC3 PASS` hoặc `❌ TC3 FAIL: [danh sách etl_logic thiếu prefix]`.
- Nếu FAIL → sửa trước khi trình bày.

**TC4 — Lọc src_stm_code đầy đủ:**

Sub-check A — `src_stm_code` attribute của bảng dim/operational:
- Với mỗi bảng `dim` và `operational`: kiểm tra attribute `src_stm_code` có `etl_logic` chứa điều kiện `WHERE <table>.src_stm_code = '...'` hoặc `WHERE <table>.src_stm_code IN (...)`.
- Báo fail nếu thiếu: `❌ TC4A FAIL: [tên bảng] thiếu WHERE filter trên src_stm_code`.

Sub-check B — JOIN sang bảng Atomic khác driving table:
- Với mọi row có `etl_logic_type ∈ {join_atomic, lookup_dim, lookup_date}`: nếu bảng đích (`atomic_table`) là Atomic entity có cột `src_stm_code` (xác định bằng cách kiểm tra `etl_logic` có tham chiếu bảng đó không), thì `etl_logic` phải chứa `AND <atomic_table>.src_stm_code = '<VALUE>'` trong điều kiện JOIN.
- Ngoại lệ không áp dụng sub-check B: `cv` (Classification Value) và `cdr_dt_dim` (Calendar Date) — 2 bảng này là conformed/shared, không có phân biệt nguồn.
- Lý do (forward-compatibility): khi Atomic table sau này nhận thêm nguồn mới, ETL join không bị nhân bản dữ liệu sai nguồn.
- Báo fail nếu thiếu: `❌ TC4B FAIL: [attribute] — join sang [atomic_table] thiếu AND src_stm_code filter`.

Báo tổng: `✅ TC4 PASS` (cả A và B đều pass) hoặc liệt kê từng lỗi A/B.
Nếu FAIL → sửa trước khi trình bày.

**TC5 — Cấu trúc CSV hợp lệ (bắt buộc dùng Bash tool):**
- Sau khi Write file, chạy lệnh sau bằng Bash tool:
  ```bash
  python3 -c "
  import csv
  with open('<path_to_file>') as f:
      rows = list(csv.reader(f))
  bad = [i for i,r in enumerate(rows) if len(r) != 15]
  print(f'Rows: {len(rows)-1} data rows')
  print('Bad rows:', bad if bad else 'none')
  "
  ```
- Báo: `✅ TC5 PASS: N rows × 15 cols` hoặc `❌ TC5 FAIL: row [i] có X cột — [nội dung row]`.
- Nếu FAIL → sửa (thường do dấu `"` thiếu trong ô trống hoặc dấu phẩy trong etl_logic chưa được quote) → chạy lại TC5 → báo kết quả.

> **Quy tắc SELF-REVIEW:** Chỉ trình bày file cho human sau khi cả 5 TC đều PASS. Nếu có TC FAIL → sửa → chạy lại TC đó → báo kết quả cuối cùng kèm tóm tắt "Đã sửa X lỗi" trước khi trình bày file.

### Checklist Phase 1

```
PRE-CHECK (trước khi sinh):
□ Đọc Entities.csv — liệt kê bảng theo reuse_status (new/partial/reuse)
□ Bảng reuse: ghi note bỏ qua, không sinh file
□ Bảng partial: đọc master, báo cáo delta, chờ human approve trước khi sinh
□ Xác định driving table + src_stm_code cho từng bảng new/partial (tra manifest → entity YAML → classification_context)
□ Trình bày bảng tóm tắt: tên file | table_type | Driving Table | src_stm_code → DỪNG chờ human xác nhận trước khi sinh bất kỳ file nào

OUTPUT CHECK:
□ Naming fact: DTM_{MODULE}_{mart_table}.csv (không có src_stm_code)
□ Naming dim/operational: DTM_{MODULE}_{mart_table}_{src_stm_code}.csv
□ src_stm_code: lấy từ classification_context của attribute "Source System Code" trong entity YAML — format "Source System Code = 'VALUE'" → VALUE
□ Thư mục output: Datamart/lld/{MODULE}/ (tạo nếu chưa có)
□ Mọi file partial chứa đầy đủ số cột hiện tại của bảng (không thiếu cột so với schema)
□ Xuất từng file → DỪNG chờ human duyệt từng file riêng lẻ trước khi xuất file tiếp theo
□ Sau khi human approve từng file: hỏi merge → DỪNG chờ human xác nhận merge từng file
□ Khi merge: check trùng (datamart_table, datamart_column) — chỉ append dòng mới
□ Sau khi human xác nhận merge: ghi DataModel/datamart_model.yaml
    - Entity new: thêm entry đầy đủ (id, logical_name, datamart_table, table_type, module, status=draft,
      reuse_status=new, description, source_atomic, modules_using, columns đầy đủ)
    - Entity partial: append delta columns vào `columns` list của entry đã có
    - Báo cáo: "Đã cập nhật datamart_model.yaml: [tên entity], [N] cột"
□ ❌ KHÔNG được tự duyệt thay human, KHÔNG được gộp nhiều file vào 1 câu hỏi approve

ATTRIBUTES CHECK:
□ Driving Table ghi rõ trong description của PK/BK
□ Mọi mapping tra từ entity YAML files trong DataModel/Atomic/ — không đoán
□ etl_logic_type điền mọi row — kể cả pending row, trừ PK/NK/BK
□ etl_logic (content) trống chỉ khi key ∈ {PK, NK, BK} hoặc etl_logic_type = pending
□ etl_logic: mọi column reference có table_name. prefix
□ etl_logic có dấu phẩy bên trong → đã double-quote trong CSV
□ computed chỉ dùng khi TẤT CẢ input đều từ driving table — nếu dùng bảng khác (kể cả EXISTS, CASE WHEN, aggregate có điều kiện) → đổi thành join_atomic
□ join_atomic: ghi rõ INNER JOIN hay LEFT JOIN
□ Cột từ LEFT JOIN: nullable = true
□ join_atomic: atomic_table khác driving — nếu trùng đổi về direct
□ lookup_dim/lookup_date: source_entity/atomic_table/atomic_column điền join key
□ Pivot: số branch + thứ tự đồng nhất; mọi branch có -- BRANCH_NAME
□ Branch residual (OTHER) flatten hoàn toàn xuống Atomic
□ Operational ≥2 BK: driving = entity con; entity cha lấy direct từ FK trong entity con
□ Mọi Dimension có ≥1 NK
□ Mọi Operational dùng trường _code làm PK duy nhất — không tạo surrogate key (_id)
□ Không thiết kế Effective Date / Expiry Date / Population Date
□ Mọi bảng dim/operational có attribute src_stm_code (cuối danh sách)
□ src_stm_code: mọi bảng (kể cả single-source) → luôn có WHERE filter trong etl_logic (forward-compatibility)
□ src_stm_code: multi-source nhiều nguồn dùng cùng lúc → dùng WHERE IN (...)
□ src_stm_code: multi-source tách bộ (partition/UNION) → N bộ × M dòng, mỗi bộ có src_stm_code riêng
□ src_stm_code: bộ chưa xác định Atomic source → etl_logic_type = pending toàn bộ bộ đó
□ src_stm_code: fact No-Driving-Table → không thêm
□ cl_dim: tên cột scm_code / cl_code / cl_nm (align Atomic cv); Detail Mapping dùng Scheme Code= / Classification Code=
□ nullable = false cho PK / BK / NK / FK
□ data_domain = Classification Value → key trống
□ data_domain = Surrogate Dimension Key → key = FK → <Dim>
□ data_domain = Surrogate Key không xuất hiện trên Fact table
□ Export UTF-8 BOM (utf-8-sig)
```

---

## PHASE 2 — DETAIL MAPPING CSV

Đọc [`reference/phase2_detail_mapping.md`](reference/phase2_detail_mapping.md) đầy đủ trước khi bắt đầu.

**Nguồn sự thật:** `BRD/BA/BA_analyst_{MODULE}.csv` — mọi dòng `Trạng thái mapping ∈ {Done, Doing, Pending}` đều phải map.

**Input bổ sung Phase 2:** Các file `Datamart/lld/{MODULE}/DTM_{MODULE}_*.csv` đã duyệt (Phase 1) — đọc tất cả file trong thư mục `{MODULE}/`.

**Output:** Append block KPI của nhóm N vào `Datamart/lld/DTM_{MODULE}_Detail_Mapping.csv` — không tạo file riêng từng nhóm. File tạo mới với header nếu chưa tồn tại; append nếu đã có.

Header:
```
kpi_id,tab,nhom,kpi_name,tinh_chat,source_module,mart_table,mart_column,column_role,logic,ghi_chu
```

Export encoding: **UTF-8 BOM** (`utf-8-sig`).

### Checklist Phase 2

```
PRE-CHECK (trước khi sinh — bắt buộc, chỉ cho KPI của nhóm đang xử lý):
□ Cross-check BA ↔ HLD: mọi dòng Done/Doing/Pending (kể cả Chiều) của nhóm N đều có KPI_ID trong HLD
□ Nếu dòng BA nào chưa có KPI_ID → DỪNG, báo cáo danh sách gap → ❌ KHÔNG sinh block khi chưa có xác nhận của human về cách xử lý gap
□ Không tự sinh KPI_ID mới trong Phase 2 — KPI_ID mới phải được khai sinh trong HLD trước
□ Đếm N_BA(nhóm) và N_KPI(nhóm) → báo cáo 2 con số → DỪNG chờ human xác nhận trước khi sinh

OUTPUT CHECK (chỉ kiểm tra block KPI của nhóm đang xử lý):
□ Số dòng block ≥ N_BA(nhóm) — báo danh sách dòng BA bị bỏ sót nếu thiếu
□ Số KPI_ID unique trong block = N_KPI(nhóm) — báo cáo nếu lệch
□ Không có KPI_ID trong block mà chưa được khai sinh trong HLD — báo danh sách nếu vi phạm
□ KPI PENDING của nhóm từ HLD cũng có trong block (mart_table/mart_column/logic trống)
□ Không bỏ qua dòng Phân loại = Chiều
□ Không bỏ qua dòng Trạng thái = Doing
□ Không bỏ qua chiều lặp lại giữa các nhóm — nhóm đang xử lý có đủ SLICER/FILTER explicit (không dùng shorthand "xem nhóm X")
□ tinh_chat khớp với Tính chất trong HLD bảng KPI
□ mart_table dùng tên logical; mart_column dùng tên logical
□ logic dùng tên physical (physical_table.physical_column)
□ DERIVED: mart_table và mart_column để trống
□ MEASURE: chỉ phép tính thuần (COUNT/SUM/AVG) — condition tách thành FILTER riêng
□ NaN/trống trong cột Trạng thái mapping → ghi chú, xác nhận với BA
□ Sau khi human duyệt block: append vào DTM_{MODULE}_Detail_Mapping.csv → báo "Đã append N dòng nhóm [N] vào Detail Mapping"

SELF-REVIEW Phase 2 (bắt buộc trước khi trình bày — chạy 4 testcase, báo kết quả):

TC1 — Mô tả khớp chỉ tiêu:
□ Kiểm tra cột `kpi_name` trong Detail Mapping khớp với tên KPI trong HLD bảng KPI (Section 2)
□ Kiểm tra cột `logic` mô tả đúng bản chất chỉ tiêu — không mâu thuẫn với mô tả trong BA_analyst
□ Báo: ✅ TC1 PASS hoặc ❌ TC1 FAIL: [danh sách kpi_id có kpi_name hoặc logic không khớp]
□ Nếu FAIL → sửa trước khi trình bày

TC2 — KPI_ID hợp lệ (thuộc HLD, kể cả Chiều và Pending):
□ Lấy toàn bộ KPI_ID từ HLD (Section KPI + Chiều + Pending)
□ Kiểm tra mọi kpi_id trong Detail Mapping ∈ tập KPI_ID HLD — không có ID ngoài HLD
□ KPI_ID xuất hiện trong Detail Mapping nhưng chưa khai sinh trong HLD → DỪNG, báo danh sách, chờ human phê duyệt quyết định trước khi tiếp tục
□ Báo: ✅ TC2 PASS hoặc ❌ TC2 FAIL: [danh sách kpi_id chưa khai sinh trong HLD]

TC3 — Logic dùng tên logical (không phải snake_case):
□ Kiểm tra cột `logic`: tên bảng và cột phải là tên logical (ví dụ "Fact Market Risk Snapshot", "Inspection Date") — không phải snake_case (fct_mkt_rsk_snpst, insp_dt)
□ Báo: ✅ TC3 PASS hoặc ❌ TC3 FAIL: [danh sách kpi_id có logic dùng snake_case]
□ Nếu FAIL → sửa trước khi trình bày

TC4 — Trường/bảng trong Detail Mapping tồn tại trong datamart_model.yaml:
□ Lấy toàn bộ (mart_table, mart_column) unique từ Detail Mapping (bỏ qua row DERIVED có mart_table/mart_column trống)
□ Kiểm tra mỗi cặp: tra DataModel/datamart_model.yaml → tìm entity có datamart_table khớp → kiểm tra columns list có physical_name = mart_column không
□ Báo: ✅ TC4 PASS hoặc ❌ TC4 FAIL: [danh sách (mart_table, mart_column) chưa có trong datamart_model.yaml]
□ Nếu FAIL → kiểm tra xem model thiếu cột (Phase 1 chưa ghi đủ) hay Detail Mapping dùng sai tên → sửa tương ứng

□ Tất cả 4 TC đều PASS → trình bày block KPI nhóm N cho human
□ Sau khi xuất block: DỪNG chờ human duyệt block → append vào Detail Mapping khi được approve

GATE CUỐI NHÓM:
□ Phase 1 (Attributes) + Phase 2 (Detail Mapping block) của nhóm N đã được human duyệt
→ Báo: "Nhóm [N] — [Tên nhóm] hoàn thành. Tiếp tục Nhóm [N+1] — [Tên nhóm N+1]?"
→ DỪNG chờ human xác nhận → ❌ KHÔNG tự bắt đầu nhóm tiếp theo
→ Sau khi tất cả nhóm hoàn thành: báo "Tất cả nhóm hoàn thành. Chuyển sang Phase 3?"
```

---

## PHASE 3 — FLAT TABLE SQL

Đọc [`reference/phase3_flat_table.md`](reference/phase3_flat_table.md) đầy đủ trước khi bắt đầu.

**Input Phase 3:**
- `Datamart/hld/DTM_{MODULE}_Entities.csv` — danh sách entity + FKs + reuse_status
- `DataModel/datamart_model.yaml` — data_type, nullable, key, physical_name của từng cột (nguồn sự thật, kể cả bảng reuse)
- Các file `Datamart/lld/{MODULE}/DTM_{MODULE}_*.csv` — chỉ đọc khi cần ETL logic; không cần đọc để lấy schema

**Output:**
```
Datamart/flat-table/{MODULE}/01_create_{module}_flat_tables.sql
Datamart/flat-table/{MODULE}/02_populate_{module}_flat_tables.sql
```

### Checklist Phase 3

```
PRE-CHECK (trước khi sinh):
□ Đọc Entities.csv — đếm số fact + operational → báo cáo cho user → DỪNG chờ human xác nhận trước khi sinh
□ ❌ KHÔNG bắt đầu sinh SQL khi chưa có xác nhận số bảng flat
□ Đọc DataModel/datamart_model.yaml — lấy columns (physical_name, data_type, nullable, key) cho từng entity fact/operational/dim liên quan
□ Xác nhận tên thư mục output: Datamart/flat-table/{MODULE}/
□ Xác nhận tên file: 01_create_{module}_flat_tables.sql, 02_populate_{module}_flat_tables.sql

FILE 01 (CREATE):
□ Số bảng CREATE = số fact + số operational
□ Naming fact flat: datamart.{module}_{datamart_table}_flat
□ Naming operational flat: datamart.{module}_{datamart_table}_flat (có module prefix — giống fact)
□ Thứ tự cột: fact columns → Calendar Date columns → dim columns → technical metadata
□ Operational: chỉ operational columns → technical metadata (không có Calendar Date, không có dim)
□ Data type dùng ClickHouse types (Nullable wrapper theo nullable=true/false trong Attributes)
□ Calendar Date: chỉ lấy cột cdr_dt (có thể alias theo vai trò: snpst_cdr_dt, issue_cdr_dt, event_cdr_dt)
□ Cột fact/operational: lấy ĐÚNG các cột có trong Attributes.csv — không thêm, không bớt
□ Cột từ dim JOIN: chỉ JOIN dim có FK tương ứng trong Attributes.csv của bảng fact — không JOIN dim không có FK
□ Cột từ dim: bỏ PK surrogate và src_stm_code, giữ các cột giá trị nghiệp vụ còn lại
□ Cột từ dim: COMMENT ghi rõ "— từ {Dim Entity Name}"
□ ENGINE = ReplicatedReplacingMergeTree()
□ PARTITION BY toYYYYMM(<cột DD>)
□ ORDER BY (<cột DD>, <grain_key>)

FILE 02 (POPULATE):
□ Số TRUNCATE + INSERT block = số bảng trong file 01
□ SELECT list đủ cột, đúng thứ tự khớp với CREATE TABLE
□ Đếm cột SELECT = đếm cột CREATE (kể cả ds_batch_date, ds_population_timestamp)
□ Tên bảng nguồn fact: datamart.{module}_{datamart_table} (có prefix module)
□ Tên bảng nguồn operational: datamart.{datamart_table} (không có prefix module)
□ Calendar Date join: datamart.{module}_calendar_date_dimension / date_dimension_id = f.{fk_col}
□ Dim join: alias rõ ràng, ON {dim_pk} = f.{fk_col}
□ today() AS ds_batch_date, now() AS ds_population_timestamp
□ Operational: không có LEFT JOIN nào

POST-CHECK (sau khi sinh):
□ Cross-check: mỗi cột trong CREATE có đúng 1 entry tương ứng trong SELECT của INSERT
□ Không có cột nào trong Attributes.csv bị bỏ sót trong CREATE TABLE (fact/operational columns)
□ Không có cột nào trong CREATE TABLE (fact/operational section) mà KHÔNG có trong Attributes.csv — cột thừa phải xóa
□ Dim JOIN: mọi dim được JOIN phải có FK tương ứng trong Attributes.csv — dim không có FK thì không JOIN, không lấy cột
□ Sau khi xuất 2 file: DỪNG chờ human duyệt → ❌ KHÔNG tự kết thúc skill khi chưa có xác nhận
```
