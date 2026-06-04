---
name: datamart-lld-design
description: |
  Thiết kế Low-Level Design (LLD) cho Datamart layer — Phase 2, 2b, 3 trong workflow thiết kế Datamart UBCKNN.
  Sử dụng khi: HLD đã được duyệt, cần thiết kế chi tiết attribute mapping (Attributes.csv),
  quan hệ bảng (Entities.csv), và mapping KPI (Detail_Mapping.csv).

  Output:
    Datamart/lld/DTM_{MODULE}_Attributes.csv   (Phase 2)
    Datamart/hld/DTM_{MODULE}_Entities.csv     (Phase 2b)
    Datamart/hld/DTM_{MODULE}_Entities.md      (Phase 2b)
    Datamart/lld/DTM_{MODULE}_Detail_Mapping.csv (Phase 3)

  Input bắt buộc Phase 2: DTM_{MODULE}_HLD.md đã duyệt + atomic_attributes.csv
---

# Skill: Thiết kế LLD Datamart

Đọc file này TRƯỚC KHI bắt đầu Phase 2/2b/3 cho bất kỳ module nào.

## Tài nguyên đi kèm

- **Reference:**
  - [`reference/phase2_attributes.md`](reference/phase2_attributes.md) — 15 cột CSV, etl_logic_type, ràng buộc key/nullable
  - [`reference/phase2b_entities.md`](reference/phase2b_entities.md) — Entities.csv + Entities.md format
  - [`reference/phase3_detail_mapping.md`](reference/phase3_detail_mapping.md) — column_role, logic format, xử lý PENDING/Doing
- **Examples:**
  - [`examples/etl_logic_correct.md`](examples/etl_logic_correct.md) — ví dụ đại diện mỗi etl_logic_type
  - [`examples/etl_logic_wrong.md`](examples/etl_logic_wrong.md) — pattern sai etl_logic
  - [`examples/key_constraints.md`](examples/key_constraints.md) — ràng buộc key × bảng type + ví dụ vi phạm

## Điều kiện tiên quyết

- [ ] `Datamart/hld/DTM_{MODULE}_HLD.md` tồn tại và đã được user duyệt
- [ ] `Atomic/lld/atomic_attributes.csv` tồn tại — **nguồn sự thật duy nhất cho Atomic mapping**
- [ ] `BRD/BA/BA_analyst_{MODULE}.csv` tồn tại (cần cho Phase 3)
- [ ] `Atomic/lld/attr_Classification_Value.csv` tồn tại (cần khi map từ danh mục)

> **QUYẾT ĐỊNH CỨNG:** Claude KHÔNG được đoán `source_entity` hay `source_attribute`.
> Mọi mapping phải tra cứu trực tiếp từ `atomic_attributes.csv`.

---

## QUY TRÌNH (BẮT BUỘC)

```
Phase 2:   Claude tra atomic_attributes.csv → xuất DTM_{MODULE}_Attributes.csv
           → DỪNG, chờ user duyệt

Phase 2b:  Sau khi Phase 2 duyệt → xuất Entities.csv + Entities.md
           → DỪNG, chờ user duyệt

Phase 3:   Sau khi Phase 2 duyệt → xuất Detail_Mapping.csv
           → Tự động (không cần gate riêng)
```

> **GATE RULE:** Không tự chuyển Phase khi user chưa xác nhận. Kết thúc mỗi Phase bằng câu hỏi xác nhận.

---

## PHASE 2 — ATTRIBUTES CSV

Đọc [`reference/phase2_attributes.md`](reference/phase2_attributes.md) đầy đủ trước khi bắt đầu.

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

### Bước 2 — Tra atomic_attributes.csv

Với mỗi attribute cần map:
1. Tra `atomic_attributes.csv` xác nhận tên `atomic_table` và `atomic_column`
2. Xác định `etl_logic_type` theo rule trong [`reference/phase2_attributes.md`](reference/phase2_attributes.md)
3. Viết `etl_logic` đúng format

### Bước 3 — Xuất CSV

Header 15 cột:
```
datamart_entity,datamart_table,datamart_attribute,datamart_column,nullable,data_domain,data_type,key,description,etl_logic,etl_logic_type,source_entity,atomic_table,source_attribute,atomic_column
```

Export encoding: **UTF-8 BOM** (`utf-8-sig`).
Mọi giá trị trong `etl_logic` và `description` phải được bao double-quote.

**Tên physical:** `datamart_table` và `datamart_column` kế thừa từ `atomic_table`/`atomic_column` hoặc đặt tay theo convention — không áp dụng greedy match algorithm.

### Checklist Phase 2

```
□ Driving Table ghi rõ trong description của PK/BK
□ Mọi mapping tra từ atomic_attributes.csv — không đoán
□ etl_logic_type điền mọi row — kể cả pending row, trừ PK/NK/BK
□ etl_logic (content) trống chỉ khi key ∈ {PK, NK, BK} hoặc etl_logic_type = pending
□ etl_logic: mọi column reference có table_name. prefix
□ etl_logic có dấu phẩy bên trong → đã double-quote trong CSV
□ join_atomic: ghi rõ INNER JOIN hay LEFT JOIN
□ Cột từ LEFT JOIN: nullable = true
□ join_atomic: atomic_table khác driving — nếu trùng đổi về direct
□ lookup_dim/lookup_date: source_entity/atomic_table/atomic_column điền join key
□ Pivot: số branch + thứ tự đồng nhất; mọi branch có -- BRANCH_NAME
□ Branch residual (OTHER) flatten hoàn toàn xuống Atomic
□ Operational ≥2 BK: driving = entity con; entity cha lấy direct từ FK trong entity con
□ Mọi Dimension có ≥1 NK
□ Mọi Operational có đủ PK (_id) + BK (_code)
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

## PHASE 2b — ENTITIES FILES

Đọc [`reference/phase2b_entities.md`](reference/phase2b_entities.md) đầy đủ trước khi bắt đầu.

Output:
- `Datamart/hld/DTM_{MODULE}_Entities.csv`
- `Datamart/hld/DTM_{MODULE}_Entities.md`

`status` toàn bộ rows = **`draft`** — chỉ reviewer chuyển sang `ready`.

---

## PHASE 3 — DETAIL MAPPING CSV

Đọc [`reference/phase3_detail_mapping.md`](reference/phase3_detail_mapping.md) đầy đủ trước khi bắt đầu.

**Nguồn sự thật:** `BRD/BA/BA_analyst_{MODULE}.csv` — mọi dòng `Trạng thái mapping ∈ {Done, Doing, Pending}` đều phải map.

Header:
```
kpi_id,tab,nhom,kpi_name,tinh_chat,source_module,mart_table,mart_column,column_role,logic,ghi_chu
```

Export encoding: **UTF-8 BOM** (`utf-8-sig`).

### Checklist Phase 3

```
PRE-CHECK (trước khi sinh — bắt buộc):
□ Cross-check BA ↔ HLD: mọi dòng Done/Doing/Pending (kể cả Chiều) đều có KPI_ID trong HLD
□ Nếu dòng BA nào chưa có KPI_ID → DỪNG và báo cáo trước khi tiếp tục
□ Không tự sinh KPI_ID mới trong Phase 3 — KPI_ID mới phải được khai sinh trong HLD trước

OUTPUT CHECK:
□ Tất cả dòng Done/Doing/Pending từ BA file đều có trong output
□ KPI PENDING từ HLD cũng có trong output (mart_table/mart_column/logic trống)
□ Không bỏ qua dòng Phân loại = Chiều
□ Không bỏ qua dòng Trạng thái = Doing
□ Không bỏ qua chiều lặp lại giữa các nhóm — mỗi nhóm có đủ SLICER/FILTER explicit (không dùng shorthand "xem nhóm X")
□ Không có KPI_ID trong output mà chưa được khai sinh trong HLD
□ tinh_chat khớp với Tính chất trong HLD bảng KPI
□ mart_table dùng tên logical; mart_column dùng tên logical
□ logic dùng tên physical (physical_table.physical_column)
□ DERIVED: mart_table và mart_column để trống
□ MEASURE: chỉ phép tính thuần (COUNT/SUM/AVG) — condition tách thành FILTER riêng
□ NaN/trống trong cột Trạng thái mapping → ghi chú, xác nhận với BA
□ Export UTF-8 BOM (utf-8-sig)
```
