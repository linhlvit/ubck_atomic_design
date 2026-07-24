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
           Claude đọc HLD (Section 2) + Entities.csv → trích danh sách TOÀN BỘ nhóm báo cáo
           (Nhóm 1 → Nhóm N_max — kể cả nhóm PENDING toàn bộ không có bảng nào cần thiết kế)
           → với mỗi nhóm: liệt kê KPI IDs + bảng cần thiết kế (new/partial) + bảng reuse
             — nhóm PENDING toàn bộ ghi "— (PENDING toàn bộ, không có bảng)"
           → dim dùng chung: nhóm đầu tiên dùng → thiết kế; nhóm sau → check datamart_model.yaml
             (reuse nếu đủ cột / partial nếu thiếu cột)
           → trình bày plan tổng dạng bảng (xem định dạng bên dưới) — tổng số dòng Plan PHẢI
             bằng tổng số nhóm trong HLD Section 2, không chỉ nhóm có bảng READY
           → DỪNG chờ human approve plan → sau khi approve mới bắt đầu Nhóm 1

Loop mỗi nhóm N — Phase 1 (HOÀN THÀNH TOÀN BỘ NHÓM TRƯỚC KHI CHUYỂN PHASE 2):
  Phase 1:   Đọc reuse_status từ Entities.csv cho các bảng của nhóm N
             → dim dùng chung đã thiết kế ở nhóm trước: check datamart_model.yaml
               → đủ cột → bỏ qua (reuse) | thiếu cột → báo delta, DỪNG chờ approve delta
             → bảng new/partial: đọc datamart_model.yaml lấy baseline (nếu partial)
             → xác định driving table + src_stm_code → sinh từng file
             → SELF-REVIEW 8 TC (TC6/TC7 quét lại TOÀN BỘ master + các nguồn khác, không chỉ file vừa sinh) → sửa nếu FAIL → trình bày SELF-REVIEW + file
             → DỪNG chờ human duyệt từng file
             → hỏi merge master → DỪNG chờ human xác nhận merge
             → ghi datamart_model.yaml (upsert new / append delta)
             → làm Nhóm N+1 Phase 1 → ... → làm đến hết Nhóm cuối Phase 1

> **GATE CỨNG — chuyển Phase 2:**
> ❌ KHÔNG được bắt đầu Phase 2 khi còn bất kỳ nhóm nào chưa hoàn thành Phase 1.
> Điều kiện bắt buộc: **tất cả nhóm** (Nhóm 1 → Nhóm N_max) đã có file Attributes được human approve và merge vào master.
> Trước khi chuyển Phase 2: liệt kê toàn bộ nhóm + trạng thái Phase 1 → báo cáo human → DỪNG chờ xác nhận.

Phase 2 — Bước 0 (TODO LIST — bắt buộc, chạy 1 lần trước khi vào loop):
             Quét lại HLD Section 2 từ đầu (độc lập với Phase 0 Plan) → lập danh sách
             TOÀN BỘ nhóm 1 → N_max kèm trạng thái (READY / READY thu hẹp / PENDING toàn bộ)
             → đây là todo list kiểm soát tiến độ Phase 2, KHÔNG lấy lại danh sách từ Phase 0 Plan
             (Plan Phase 0 có thể đã lược bỏ nhóm PENDING toàn bộ vì không cần bảng Attributes)
             → trình bày todo list dạng bảng: Nhóm | Trạng thái HLD | Đã có trong Detail Mapping? (chưa/rồi)
             → DỪNG chờ human xác nhận todo list trước khi bắt đầu loop Nhóm 1

Loop mỗi nhóm N — Phase 2 (theo TODO LIST vừa lập, N = 1 → N_max, xử lý cả nhóm PENDING toàn bộ):
  Phase 2:   Cross-check BA ↔ HLD cho KPI của nhóm N → báo gap nếu có
             → DỪNG chờ human xử lý gap (nếu có)
             → xuất block KPI nhóm N (kể cả nhóm PENDING toàn bộ — xem quy tắc PENDING trong
               reference/phase2_detail_mapping.md) → append vào DTM_{MODULE}_Detail_Mapping.csv
               theo ĐÚNG THỨ TỰ SỐ NHÓM TĂNG DẦN (không append cuối file nếu nhóm đó có số nhỏ hơn
               nhóm đã append trước đó — xem TC6)
             → SELF-REVIEW 4 TC → sửa nếu FAIL → trình bày SELF-REVIEW + block KPI
             → DỪNG chờ human duyệt block KPI nhóm N
             → cập nhật todo list (đánh dấu Nhóm N đã xong) → làm Nhóm N+1 Phase 2 → ... → hết Nhóm cuối

  → Sau khi tất cả nhóm trong todo list đã xử lý:
             Chạy SELF-REVIEW module-level TC5 (đối chiếu tổng số nhóm/KPI) + TC6 (thứ tự nhóm)
             → sửa nếu FAIL → DỪNG — báo "Tất cả nhóm Phase 2 hoàn thành, TC5+TC6 PASS."
             → chờ human xác nhận chuyển Phase 3

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

Đọc `DTM_{MODULE}_HLD.md` Section 2 từ đầu đến hết → trích danh sách **TOÀN BỘ** nhóm báo cáo
(Nhóm 1 → Nhóm N_max), không bỏ sót nhóm nào dù trạng thái gì:
- Tên nhóm (Nhóm 1, Nhóm 2, ..., Nhóm N_max)
- Trạng thái HLD của nhóm: READY / READY (thu hẹp) / PENDING toàn bộ
- KPI IDs thuộc nhóm (bao gồm Chiều + Pending)

> ❌ Không bỏ sót nhóm PENDING toàn bộ chỉ vì nhóm đó không cần bảng Attributes nào ở Phase 1 —
> nhóm này vẫn phải xuất hiện trong Plan (cột "Bảng cần thiết kế" ghi "— (PENDING toàn bộ)")
> để Phase 2 không bỏ sót khi lập todo list.

### Bước P2 — Map bảng cho từng nhóm

Đọc `DTM_{MODULE}_Entities.csv` → với mỗi nhóm:
1. Xác định bảng nào phục vụ nhóm đó (từ Source trong HLD Section 2)
2. Kiểm tra `reuse_status` từ Entities.csv
3. **Dim dùng chung:**
   - Conformed dim (Calendar Date Dimension): luôn reuse — không thiết kế lại ở bất kỳ nhóm nào
   - Dim nội bộ module: nhóm đầu tiên dùng → gán `new`; nhóm sau → gán `reuse` (check `datamart_model.yaml` trước)
   - Nếu `datamart_model.yaml` có entry nhưng thiếu cột → gán `partial` cho nhóm đó, sẽ báo delta khi đến nhóm đó
4. **Nhóm PENDING toàn bộ** (không có Atomic source hoặc Fact/Dim nào sẵn sàng): vẫn giữ trong Plan
   với cột "Bảng cần thiết kế" = "— (PENDING toàn bộ, không có bảng)" — KHÔNG loại khỏi Plan

### Bước P2b — Chốt physical name chuẩn cho entity dùng chung nhiều bảng (bắt buộc)

> **Lý do (bài học GSDC 2026-07-16):** Khi 1 entity/khái niệm nghiệp vụ (VD: "Public Company") xuất
> hiện trong tên của ≥ 2 bảng Datamart cùng module (1 Dimension + nhiều Fact), rất dễ mỗi bảng tự
> nghĩ ra 1 biến thể viết tắt khác nhau (`pblc_co` ở Dimension, `pc` ở các Fact) — cả hai đều không
> có trong `rule_physical_name_exceptions_datamart.csv` và không nhất quán với nhau. Lỗi này không
> bị TC nào bắt được cho tới khi đã sinh xong 13 file (Attributes + Detail Mapping + HLD + model +
> SQL) vì mỗi bảng được review độc lập theo nhóm, không ai đối chiếu ngược các bảng với nhau.

**Quy trình:**
1. Từ danh sách bảng đã map ở Bước P2 (toàn bộ Nhóm), liệt kê mọi entity/khái niệm nghiệp vụ xuất
   hiện trong tên ≥ 2 bảng khác nhau (kể cả 1 Dimension + N Fact, hoặc N Fact dùng chung 1 khái niệm)
2. Với mỗi entity như vậy: áp dụng PHYSICAL NAMING RULE (mục bên dưới) để xác định **đúng 1 dạng
   token duy nhất** — full word nếu không có trong exceptions, viết tắt nếu có
3. `grep` `datamart_attributes.csv` xem entity đó đã từng dùng token nào ở module khác chưa (dim
   conformed/shared) — nếu có, dùng lại nguyên token đó, không tự nghĩ ra token mới
4. Ghi bảng "Physical name chuẩn" vào Plan tổng (Bước P3) — liệt kê entity | token chuẩn | áp dụng
   cho bảng nào — để human duyệt 1 lần cho toàn module, tránh lệch nhau giữa các nhóm thiết kế sau

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

Physical name chuẩn (entity dùng chung ≥ 2 bảng — xem Bước P2b):

| Entity/khái niệm | Token chuẩn | Áp dụng cho bảng |
|---|---|---|
| Public Company | `public_company` (full — không có trong exceptions) | public_company_dim, fct_public_company_risk_score_snpst, fct_public_company_*_score_snpst (5 bảng) |
| ... | ... | ... |

Tổng: [N] nhóm | [M] bảng new | [P] bảng partial | [Q] bảng reuse

→ Xác nhận plan (kể cả bảng Physical name chuẩn) để bắt đầu Nhóm 1?
```

> **GATE — bắt buộc dừng:** Chờ human approve plan trước khi bắt đầu bất kỳ nhóm nào.
> ❌ KHÔNG bắt đầu Phase 1 Nhóm 1 khi chưa có xác nhận plan.
> ❌ Trong Phase 1, khi đặt tên bảng/cột cho entity đã có trong bảng "Physical name chuẩn" —
> PHẢI dùng đúng token đã duyệt, không tự đổi hay nghĩ ra biến thể khác dù ngắn gọn hơn.

---

## PHASE 1 — ATTRIBUTES CSV

Đọc [`reference/phase1_attributes.md`](reference/phase1_attributes.md) đầy đủ trước khi bắt đầu.

**Input Phase 1:**
- `Datamart/hld/DTM_{MODULE}_Entities.csv` — danh sách entity, table_type, reuse_status, source_table đã duyệt
- `Datamart/lld/datamart_attributes.csv` — master hiện tại (cần cho partial flow)

**Bước 0 — Đọc reuse_status từ Entities.csv:**
- `reuse` → bỏ qua hoàn toàn, không sinh file, ghi note: "Bảng [datamart_table] reuse từ master — không thiết kế mới"
- `new` → thiết kế đầy đủ, sinh file
- `partial` → đọc `DataModel/datamart_model.yaml` (entry có `id = DTM-{datamart_table}`), lấy `columns` hiện có làm baseline + xác định `module` sở hữu gốc → so sánh delta → **báo cáo human, DỪNG chờ approve** trước khi sinh file
  > ❌ **KHÔNG được sinh file partial** khi chưa có xác nhận của human về delta.
  > ❌ **KHÔNG tạo file `_delta.csv` hay bất kỳ file Attributes nào trong thư mục module đang thiết kế** (`Datamart/lld/{MODULE}/`) khi bảng thuộc sở hữu module khác — cột mới phải sửa TRỰC TIẾP vào file gốc `Datamart/lld/{MODULE_SỞ_HỮU}/DTM_{MODULE_SỞ_HỮU}_{datamart_table}_....csv`. Xem chi tiết [`reference/phase1_attributes.md`](reference/phase1_attributes.md) mục "Quy trình partial".

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

### Bước 1a — Phạm vi cột Dimension (coverage rule — bắt buộc, thiết kế lần đầu VÀ khi partial)

> **Bài học (module NDTNN, 2026-07-24):** `Public Company Dimension` (dùng chung GSDC/QLCB/NDTNN) ban đầu chỉ chọn 8 cột đủ dùng cho KPI đang thiết kế lúc đó. Sau đó phải quay lại bổ sung 2 lần (7 cột rồi 11 cột) khi rà soát lại entity Atomic gốc — vì cách chọn "đủ dùng cho KPI hiện tại" bỏ sót nhiều attribute mô tả tĩnh có giá trị dùng chung lâu dài cho các module sau. Với Dimension dùng chung nhiều module, thiếu 1 cột không chỉ vá lại 1 lần — mỗi module mới cần thêm lại phải sửa `datamart_attributes.csv` + `datamart_model.yaml` + mọi Detail Mapping đã tham chiếu, tốn công hơn nhiều so với thiết kế đủ ngay từ đầu.

**Quy tắc:** Khi thiết kế Dimension mới (`new`) hoặc mở rộng Dimension đã có (`partial`), đọc **toàn bộ** danh sách attribute của Atomic entity driving table (không dừng ở tập cột cần cho KPI hiện tại) và áp dụng bộ lọc theo **SCD-nature** — bản chất thay đổi chậm/nhanh của chính attribute đó trên Atomic:

| Loại attribute Atomic | Đưa vào Dimension? | Ví dụ |
|---|---|---|
| Đặc điểm/hồ sơ mô tả thực thể (tên, mã, loại hình, ngày đăng ký, tỉnh/thành, cờ cấu trúc sở hữu...) | ✅ Có — kéo dư thừa toàn bộ, kể cả khi KPI hiện tại chưa dùng | `pc_nm`, `enterprise_tp_code`, `head_office_province_nm`, `has_parent_company_indicator` |
| Khóa/liên kết kỹ thuật thuần (PK/FK surrogate nội bộ Atomic không mang ý nghĩa nghiệp vụ độc lập) | ❌ Không | id kỹ thuật không có business meaning riêng |
| Audit/vận hành thuần (created_by, file_name, upload timestamp, ghi chú xử lý nội bộ) | ❌ Không | `attachment_file_nm`, `specialist_note`, `company_login_username` |
| Gắn với 1 giao dịch/sự kiện cụ thể, đổi theo phiên/ngày (giá, khối lượng, số dư, trạng thái tại 1 thời điểm snapshot) | ❌ Không — thuộc về Fact/Snapshot, không phải Dimension | giá khớp lệnh, khối lượng giao dịch, số dư tài khoản theo ngày |

❌ Không áp dụng ngược lại cho Fact — Fact vẫn giữ nguyên rule "chỉ giữ cột trace được về KPI" (xem CLAUDE.md `feedback_fact_no_etl_filter_columns`). Coverage rule này CHỈ áp dụng cho Dimension.

**Khi partial (Dimension đã tồn tại từ module khác):** Trước khi chỉ thêm đúng 1-2 cột module hiện tại cần, chủ động rà lại **toàn bộ** attribute còn lại của Atomic driving table theo bảng phân loại trên — đề xuất bổ sung 1 lần đầy đủ, tránh để module sau lại phải mở lại cùng bảng.

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
2. **Mỗi bộ** gồm đầy đủ tất cả attribute của bảng (PK/BK + các cột + `src_stm_code`)
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

> **Lỗi tái diễn — 2 biến thể viết tắt song song cho CÙNG một tên bảng/entity (phát hiện ở GSDC 2026-07-16):**
> Khi module có nhiều bảng Fact/Dim cùng gắn với 1 khái niệm nghiệp vụ (VD: "Public Company"), rất dễ đặt tên bảng đầu tiên theo 1 kiểu viết tắt tự nghĩ ra (`pblc_co_dim`) rồi bảng sau lại đặt theo kiểu khác (`fct_pc_risk_score_snpst`) — cả 2 đều KHÔNG có trong exceptions và KHÔNG nhất quán với nhau.
> **Nguyên nhân sâu xa:** dễ nhầm lẫn giữa 2 ngữ cảnh — (a) `atomic_table`/`atomic_column` là tên **Atomic gốc** (read-only, VD: `pc_evaluation_detail`, `pc_report_submission`, `pc_id` — những tên này giữ nguyên, không đổi), và (b) `datamart_table`/`datamart_column` là tên **Datamart tự đặt**, phải tuân physical naming rule độc lập với cách Atomic đặt tên. Thấy Atomic dùng tiền tố `pc_` rồi bắt chước đặt tên Datamart cũng `pc_`/`pblc_co` là sai — hai tầng đặt tên độc lập nhau.
> **Quy tắc phòng ngừa:** Trước khi đặt tên bảng/cột Datamart mới cho 1 entity xuất hiện ở nhiều bảng trong cùng module, `grep` toàn bộ tên hiện có của entity đó trong `datamart_attributes.csv` + các file Attributes detail đã duyệt trước — đảm bảo dùng lại đúng 1 biến thể duy nhất, không tự nghĩ ra biến thể mới giữa chừng.

### Khi đặt tên `datamart_column`

- Mọi cột trong Attributes CSV phải tuân thủ rule này
- Khi kế thừa từ `atomic_column`: nếu Atomic column dùng tên chuẩn (ví dụ `sp_code`, `practitioner_position_at_rpt`) → giữ nguyên; chỉ đổi nếu Atomic column đang dùng sai convention
- Khi đặt tên mới (ETL-derived, computed): áp dụng rule từ đầu
- **Không copy tiền tố viết tắt từ tên Atomic sang tên Datamart** — `atomic_table`/`atomic_column` (VD: `pc_evaluation_detail`) là namespace riêng của Atomic, không phải gợi ý cách viết tắt cho `datamart_table`/`datamart_column`

### Khi review/detect lỗi

Nếu phát hiện `datamart_column` hoặc `datamart_table` dùng từ viết tắt không có trong exceptions, HOẶC dùng 2 biến thể viết tắt khác nhau cho cùng 1 entity/khái niệm trong cùng module:
1. Tra `system/rules/rule_physical_name_exceptions_datamart.csv` xác nhận
2. Đây là **Kịch bản C — Lỗi thiết kế** → sửa trực tiếp file Attributes detail + `datamart_attributes.csv` + `Detail_Mapping.csv` (cột `logic`) + `HLD.md` (tên bảng trong text/mermaid) + `datamart_model.yaml` (chỉ field `id`/`datamart_table`/`physical_name` — KHÔNG dùng `yaml.dump` để ghi lại toàn file vì sẽ phá format/comment gốc, chỉ sửa bằng text-replace theo dòng cụ thể) + tên file Attributes detail (nếu tên file chứa physical_name cũ) + 2 file SQL Phase 3 (nếu đã sinh)
3. Dùng `grep -rn "tên_cũ" Datamart/` để tìm tất cả vị trí trước khi sửa
4. **Tuyệt đối không sửa cột `source_entity`/`atomic_table`/`source_attribute`/`atomic_column`** trong Attributes, hay `source_atomic_table`/`source_atomic_column` trong `datamart_model.yaml` — đây là tên Atomic gốc (read-only), kể cả khi trùng chuỗi ký tự với tên Datamart bị đổi (VD: đổi `pc_code` Datamart-side nhưng KHÔNG đổi `pc_code` xuất hiện trong `source_atomic_column: "public_company.pc_code"`)
5. Sau khi sửa: chạy lại SELF-REVIEW đầy đủ (Phase 1 5 TC + Phase 2 TC5/TC6 module-level) để xác nhận số dòng/cấu trúc không đổi trước và sau khi đổi tên

---

### Bước 4 — SELF-REVIEW trước khi trình bày kết quả

**Bắt buộc thực hiện sau khi sinh xong mỗi file, trước khi trình bày cho human duyệt.** Chạy 8 testcase sau (TC1, TC2, TC2b, TC3 gồm cả sub-check TC3b, TC4, TC5, TC6, TC7) và báo kết quả:

**TC1 — Số cột khớp HLD:**
- Đếm số attribute trong file CSV vừa sinh (theo `datamart_attribute` unique, không đếm multi-source row).
- Đối chiếu với bảng entity tương ứng trong `DTM_{MODULE}_HLD.md` (Section 3) — số cột trong bảng HLD.
- Báo: `✅ TC1 PASS: X cột — khớp HLD` hoặc `❌ TC1 FAIL: CSV có X cột, HLD có Y cột — Chênh: [danh sách cột thừa/thiếu]`.
- Nếu FAIL → sửa trước khi trình bày.

**TC2 — etl_logic_type hợp lệ:**
- Kiểm tra mọi row không phải PK: `etl_logic_type` không được trống (BK vẫn phải điền).
- **Sub-check bắt buộc:** Với mỗi row có `etl_logic_type ∈ {direct, computed}`: kiểm tra `atomic_table` của row đó có phải driving table không. Nếu `atomic_table` khác driving table → phải đổi thành `join_atomic`. Ngoại lệ: `lookup_dim`, `lookup_date`, `pivot`, `pending` không áp dụng sub-check này.
- Kiểm tra đặc biệt: khi file CSV có nhiều `atomic_table` khác nhau (ký hiệu ` / ` hoặc nhiều row khác nhau) → bảng nào không phải driving phải dùng `join_atomic`.
- Báo: `✅ TC2 PASS` hoặc `❌ TC2 FAIL: [danh sách row sai etl_logic_type — ghi rõ atomic_table và driving table]`.
- Nếu FAIL → sửa trước khi trình bày.

**TC2b — `key` hợp lệ theo loại bảng (bắt buộc, dùng bảng `examples/key_constraints.md`):**
- Xác định loại bảng (`fact` / `dim` / `operational`) từ `datamart_entity`/tên file.
- **Fact:** không được có bất kỳ row nào `key = PK`. Chỉ `FK → <Dim>` / `DD` / (trống) hợp lệ.
- **Dimension:** `key ∈ {PK, BK, (trống)}` — cấm `FK`, `DD`. Bắt buộc có ít nhất 1 `PK` và ít nhất 1 `BK`.
- **Operational:** `key ∈ {PK, BK, (trống)}` — cấm `FK`, `DD`. Bắt buộc có đúng 1 `PK` (thường là `_code` đóng vai trò PK, không tạo `_id` riêng).
- Với mọi row `key = BK`: `etl_logic` và `etl_logic_type` không được trống (BK là business key thật, map từ Atomic — không phải surrogate generated).
- Với mọi row `key = PK`: `description` không được lẫn chữ "BK" hoặc ngược lại — token trong `description` (nếu có nhắc lại key) phải khớp đúng giá trị cột `key` của chính dòng đó.
- Báo: `✅ TC2b PASS` hoặc `❌ TC2b FAIL: [danh sách row vi phạm — ghi rõ key hiện tại, loại bảng, và vi phạm cụ thể]`.
- Nếu FAIL → sửa trước khi trình bày (Dim/Operational thiếu etl_logic cho BK → điền đầy đủ).
- **Fact có `key = PK` → XÓA HẲN TOÀN BỘ DÒNG (row) khỏi CSV — không phải chỉ đổi giá trị cột `key` thành trống và giữ nguyên dòng.** Bài học thực tế (module GSDC, 2026-07-22): đã từng chỉ đổi `key: PK` → `key: ''` mà giữ nguyên dòng `fct_..._id`, khiến cột surrogate thừa vẫn tồn tại trong Attributes/registry/SQL sau khi báo "đã fix" — human phải tự phát hiện lại. Trước khi xóa, kiểm tra cột đó có được tham chiếu ở nơi khác không (`grep` trong `Detail_Mapping.csv` và `HLD.md`): nếu KHÔNG có tham chiếu nào → xóa hẳn dòng; nếu có bằng chứng ETL cần cột đó cho merge/upsert kỹ thuật → giữ dòng nhưng `key` để trống (ngoại lệ hiếm, cần nêu rõ lý do). Khi xóa, đồng bộ đủ 4 nơi: (1) file Attributes detail, (2) master `datamart_attributes.csv`, (3) `datamart_model.yaml` — xóa cả block `columns` tương ứng bằng text-replace theo block, KHÔNG dùng `yaml.dump`, (4) file SQL Phase 3 đã sinh nếu có (`01_create_*.sql` dòng CREATE, `02_populate_*.sql` dòng SELECT).

**TC3 — Đầy đủ prefix table_name.column_name + thứ tự JOIN đúng:**
- Kiểm tra mọi column reference trong `etl_logic` có dạng `<table>.<col>`.
- Ngoại lệ không cần prefix: literal values, SQL functions (`YEAR(...)`, `COUNT(...)`), NULL, ETL runtime parameter (`{etl_date}`).
- **Sub-check thứ tự JOIN (bắt buộc):** Với mọi row có `etl_logic_type ∈ {join_atomic, lookup_dim, lookup_date}` mà `etl_logic` chứa từ khóa `JOIN`: kiểm tra `etl_logic` có chứa dấu `→` (hoặc `->`), và toàn bộ JOIN clause phải nằm TRƯỚC dấu `→`, cột giá trị nằm SAU. Vi phạm khi: (a) có `JOIN` nhưng không có `→`/`->`, hoặc (b) cột giá trị xuất hiện trước từ khóa `JOIN` đầu tiên trong chuỗi.
- Báo: `✅ TC3 PASS` hoặc `❌ TC3 FAIL: [danh sách etl_logic thiếu prefix hoặc sai thứ tự JOIN — ghi rõ loại lỗi]`.
- Nếu FAIL → sửa trước khi trình bày.

**Sub-check TC3b — Cú pháp `LOOKUP <dim> ON ...` bắt buộc cho mọi lookup FK sang Dimension (bắt buộc):**
- Bài học thực tế (module QLCB, 2026-07-23): sub-check thứ tự JOIN ở trên chỉ kích hoạt khi `etl_logic` chứa từ khóa `JOIN` — 4/6 file LLD của QLCB dùng dạng `<dim>.<col> WHERE <dim>.<col> = <driving>.<col>` (không có `JOIN` keyword, chỉ có `WHERE`) hoặc multi-hop `INNER JOIN ... WHERE <dim>.<col> = ... → <dim>.<col>` (JOIN đúng thứ tự trước `→`, nhưng hop lookup cuối vẫn dùng `WHERE` thay vì `LOOKUP...ON`) — cả 2 pattern đều PASS sub-check thứ tự JOIN vì không vi phạm quy tắc "JOIN trước, giá trị sau `→`", nhưng vẫn sai format chuẩn. Xem `examples/etl_logic_wrong.md` mục SAI 9.
- Với mọi row có `etl_logic_type ∈ {lookup_dim, lookup_date}`: kiểm tra hop lookup (không JOIN clause phía trước thì là toàn bộ `etl_logic`; có JOIN clause phía trước thì là phần sau dấu `→`) phải khớp cú pháp `LOOKUP <dim_table> ON <dim_table>.<col> = <table>.<col>` — bắt đầu bằng từ khóa `LOOKUP`, có `ON`, không chứa `WHERE` value-first trong chính hop đó.
- Vi phạm khi: (a) toàn bộ `etl_logic` là `<dim>.<col> WHERE <dim>.<col> = ...` (thiếu `LOOKUP`, giá trị đặt trước điều kiện); (b) có JOIN clause hợp lệ trước `→` nhưng phần sau `→` là `<dim>.<col>` trần hoặc dùng `WHERE` thay vì `LOOKUP <dim> ON ...`.
- Khi phát hiện vi phạm (b), kiểm tra thêm: `etl_logic_type` của row đó có đang để `join_atomic` thay vì `lookup_dim`/`lookup_date` không — nếu hop cuối là lookup dimension thì bắt buộc đổi `etl_logic_type` cho khớp.
- Báo: `✅ TC3b PASS` hoặc `❌ TC3b FAIL: [danh sách attribute thiếu LOOKUP...ON — ghi rõ pattern (a) hay (b), và etl_logic_type có cần đổi không]`.
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

Sub-check C — Giá trị `src_stm_code` đúng format (không chép theo tên file Atomic):
- Giá trị `src_stm_code` là data value (dùng dấu `_` nối module + table, VD `NHNCK_CERTIFICATES`) — **khác** với tên file Atomic YAML (dùng dấu `.`, VD `dm_atm_..._-NHNCK.CERTIFICATES.yaml`). Đây là 2 thứ khác nhau; nhầm lẫn giữa chúng là lỗi đã từng xảy ra thực tế (2026-07-21, module NHNCK/QLCB/QLKD).
- Regex kiểm tra: mọi giá trị trong `src_stm_code = '...'` hoặc `src_stm_code IN (...)` **không được chứa dấu `.`** giữa 2 khối chữ hoa (pattern lỗi: `'[A-Z][A-Z0-9_]*\.[A-Z][A-Z0-9_]*'`).
- Nếu phát hiện dấu chấm → tra lại `classification_context` của attribute "Source System Code" trong Atomic YAML tương ứng (theo quy trình tra cứu Atomic ở đầu skill) để lấy giá trị đúng, KHÔNG tự suy ra bằng cách thay `.` → `_`.
- Áp dụng luôn cho tên file dim/operational: `DTM_{MODULE}_{mart_table}_{src_stm_code}.csv` — phần `{src_stm_code}` trong tên file cũng phải dùng dấu `_`, không dùng dấu `.`.
- Báo fail nếu phát hiện: `❌ TC4C FAIL: [file/attribute] — src_stm_code = '[giá trị sai]' dùng dấu chấm, đúng phải là '[giá trị đúng]'`.

Sub-check D — Giá trị `src_stm_code` khớp đúng module nguồn thật của bảng đích (không suy diễn theo tên module đang thiết kế):
- TC4B chỉ kiểm tra "có filter `src_stm_code` hay không"; TC4C chỉ kiểm tra "định dạng gạch dưới hay dấu chấm". Cả 2 đều **không** verify bản thân giá trị filter có đúng thật không — đây là lỗi đã xảy ra thực tế (module NHNCK, 2026-07-21): `etl_logic` JOIN tới `geographic_area` (Atomic entity thuộc phân hệ **ECAT**, không phải NHNCK) nhưng viết `AND geographic_area.src_stm_code = 'NHNCK_COUNTRIES'` — đúng định dạng gạch dưới (qua TC4C), có mặt điều kiện lọc (qua TC4B), nhưng sai hoàn toàn giá trị vì tự suy diễn theo tên module đang thiết kế (NHNCK) thay vì tra cứu module nguồn thật của bảng đích (`geographic_area` luôn thuộc ECAT dù được dùng bởi bất kỳ module nào).
- Quy tắc: mọi khi `etl_logic_type ∈ {join_atomic, lookup_dim, lookup_date}` JOIN sang 1 **shared/cross-module Atomic entity** (entity dùng chung nhiều module — dấu hiệu nhận biết: entity nằm trong BCV Core Object `Location`/`Involved Party`/`Common`/`Classification`, hoặc tên entity không có prefix module cụ thể, VD `geographic_area`, `ip_alternative_identification`, `ip_postal_address`) — **không được suy diễn giá trị `src_stm_code` từ tên module đang thiết kế**. Bắt buộc mở đúng file Atomic YAML của bảng đích (`grep -rl "entity_physical_name: \"<atomic_table>\"" DataModel/Atomic/**/*.yaml DataModel/working/Atomic/**/*.yaml`), đọc `classification_context`/`etl_derived_value` của attribute "Source System Code" trong CHÍNH FILE ĐÓ (không phải file của driving table module đang thiết kế) để lấy giá trị thật.
- Ví dụ cụ thể: bảng `geographic_area` luôn có nguồn `dm_atm_geographic_area-ECAT.COUNTRY.yaml` (hoặc `.REGION`/`.PROVINCE_NEW`/... tùy cấp hành chính) — giá trị `src_stm_code` đúng luôn có prefix `ECAT_`, bất kể module Datamart nào (NHNCK, QLCB, GSDC...) đang JOIN tới nó để lấy tên quốc gia/tỉnh/thành.
- Cách kiểm tra bằng script: với mỗi giá trị `src_stm_code = 'X'` xuất hiện trong `etl_logic`, tách phần trước dấu `_` đầu tiên trong `X` — nếu phần đó KHÔNG khớp `source_system` thật của Atomic YAML chứa `atomic_table` đang JOIN (tra bằng `grep "source_system:" <file>.yaml` ngay dưới attribute Source System Code) → nghi vấn sai, cần xác nhận thủ công bằng cách đọc `classification_context`/`etl_derived_value`.
- Báo fail nếu phát hiện: `❌ TC4D FAIL: [attribute] — join sang [atomic_table] dùng src_stm_code = '[giá trị nghi sai]', nhưng Atomic YAML của [atomic_table] ghi source_system=[X] → giá trị đúng phải là '[giá trị đúng theo classification_context]'`.

Báo tổng: `✅ TC4 PASS` (A, B, C, D đều pass) hoặc liệt kê từng lỗi A/B/C/D.
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

**TC6 — Physical name khớp tất định với logical name (bắt buộc dùng Bash tool):**

- Mục đích: TC6 bản đầu (chỉ "tự nhìn bằng mắt") đã được kiểm chứng là **không phát hiện được gì** — khi áp dụng thử thuật toán tất định bên dưới lên `datamart_attributes.csv`/`datamart_model.yaml` hiện có (2026-07-16), phát hiện thực tế 2 lỗi cùng loại đã lọt từ trước: "Practitioner" → viết tắt `prac` (9 bảng NHNCK) và "Securities Company" → viết tắt `sc` (4 bảng NHNCK) — cả hai đều không có trong exceptions. TC6 phải **tính toán, không đoán**.
- Thuật toán: với mỗi `datamart_entity` (logical name), tính **physical name kỳ vọng** bằng cách áp dụng đúng PHYSICAL NAMING RULE (tách từng từ theo khoảng trắng/gạch ngang, tra `rule_physical_name_exceptions_datamart.csv`, giữ full word nếu không có exception, nối bằng `_`) — rồi so với `datamart_table` thực tế trong **toàn bộ** `datamart_attributes.csv` (mọi module, không chỉ module đang thiết kế — bắt cả trường hợp entity conformed/shared bị đặt tên lệch giữa các module).
- Chạy script sau **trên toàn bộ master sau khi merge** (không chỉ file vừa sinh — vì lỗi có thể đã tồn tại từ trước, TC6 phải quét lại toàn bộ mỗi lần có thay đổi):
  ```bash
  python3 -c "
  import csv, re

  # Whitelist ngoại lệ đã xác nhận là quy ước riêng, không phải lỗi — cập nhật khi có ca mới được human duyệt
  # CẢNH BÁO: KHÔNG thêm entry vào đây chỉ vì "có vẻ là quy ước riêng" — phải xác minh bằng chứng cụ thể
  # (VD: rule_physical_name_exceptions_datamart.csv, tài liệu quyết định, hoặc human xác nhận trực tiếp).
  # Bài học 2026-07: 'cls_dim' từng bị thêm vào đây với lý do tự suy diễn "quy ước 3-ký-tự cho bảng conformed"
  # — không có căn cứ nào cả, chỉ là lỗi gõ tay (thừa chữ 's') trong datamart_model.yaml. Việc thêm exception
  # đã che giấu lỗi thật khỏi TC6/TC7 trong nhiều tháng dù cả 2 TC vẫn chạy đúng và báo đúng mismatch mỗi lần —
  # vấn đề nằm ở người đọc kết quả tự nhận định "known exception" mà không truy nguyên gốc.
  KNOWN_EXCEPTIONS = {
      'fct_public_company_nonfinancial_score_snpst',  # "Non-Financial" viết liền không gạch dưới ở tên bảng (naive split coi "Non"/"Financial" là 2 từ riêng) — nhưng LƯU Ý: cột non_financial_m_score trong Fact Risk Score Snapshot lại giữ gạch dưới → không nhất quán thật giữa 2 bảng, cân nhắc thống nhất khi rà soát GSDC
  }

  exceptions = {}
  with open('system/rules/rule_physical_name_exceptions_datamart.csv', encoding='utf-8-sig') as f:
      reader = csv.reader(f)
      next(reader)
      for row in reader:
          if len(row) >= 2:
              exceptions[row[0].strip().lower()] = row[1].strip().lower()

  def expected_physical(logical_name):
      words = re.findall(r\"[A-Za-z0-9']+\", logical_name)  # tách cả từ ghép có gạch ngang (Non-Financial -> Non, Financial)
      tokens = [exceptions.get(w.lower(), w.lower()) for w in words]
      return '_'.join(tokens)

  with open('Datamart/lld/datamart_attributes.csv', encoding='utf-8-sig') as f:
      rows = list(csv.reader(f))
  header = rows[0]
  ent_idx, tbl_idx = header.index('datamart_entity'), header.index('datamart_table')

  pairs = set((r[ent_idx], r[tbl_idx]) for r in rows[1:])
  fails = []
  for ent, tbl in sorted(pairs):
      if tbl in KNOWN_EXCEPTIONS:
          continue
      exp = expected_physical(ent)
      if exp != tbl:
          fails.append((ent, tbl, exp))

  print(f'Tổng entity: {len(pairs)} | Mismatch: {len(fails)}')
  for ent, tbl, exp in fails:
      print(f'  ❌ {ent!r} actual={tbl!r} expected={exp!r}')
  "
  ```
- **Lưu ý xử lý kết quả — không phải mọi mismatch đều là lỗi:**
  - Nếu `actual` là viết tắt tùy tiện không có trong exceptions (VD: `prac`, `sc`, `pc`, `pblc_co`) → **lỗi thật**, phải sửa theo Kịch bản C.
  - Nếu `actual` giữ full word dù từ đó CÓ trong exceptions (VD: `history` thay vì `hist` dù "History" có exception) → **lỗi thật khác chiều** (thiếu áp dụng exception có sẵn), cũng phải sửa.
  - Nếu mismatch chỉ do thuật toán tách từ ghép ngây thơ (VD: "Non-Financial" tách thành `non_financial` nhưng bảng dùng liền `nonfinancial`) → kiểm tra xem cách viết liền có nhất quán ở nơi khác cùng module không; nếu có tiền lệ nhất quán → thêm vào `KNOWN_EXCEPTIONS`, không phải lỗi.
  - Nếu là bảng conformed/shared có vẻ theo "quy ước riêng" → **KHÔNG tự kết luận là hợp lệ**. Bắt buộc tìm bằng chứng cụ thể (exceptions CSV, tài liệu quyết định) trước khi thêm vào `KNOWN_EXCEPTIONS` — không suy diễn quy ước không có căn cứ. Nếu không tìm được bằng chứng → mismatch là lỗi thật, sửa theo Kịch bản C.
- Báo: `✅ TC6 PASS: N entity, 0 mismatch` hoặc `❌ TC6 FAIL: [danh sách entity | actual | expected]` — với mỗi FAIL, phân loại rõ là lỗi thật hay cần thêm KNOWN_EXCEPTIONS trước khi kết luận.
- Nếu là lỗi thật → sửa theo Kịch bản C (mục "Khi review/detect lỗi" bên dưới) → chạy lại TC6 trên toàn bộ master → báo kết quả.
- **Áp dụng cho cả `datamart_column`** (không chỉ `datamart_table`): với mỗi `datamart_attribute` (logical) trong cùng 1 `datamart_entity`, tính expected tương tự và so với `datamart_column` thực tế.

**TC7 — Tên bảng/cột đồng nhất xuyên suốt các nguồn output (bắt buộc dùng Bash tool):**

- Mục đích: TC6 chỉ kiểm tra 1 file (`datamart_attributes.csv`) có tự nhất quán với chính nó không. TC7 kiểm tra **giữa các nguồn khác nhau** có cùng dùng 1 tên hay không — bài học NHNCK 2026-07-16: `datamart_model.yaml` và `datamart_attributes.csv` tồn tại song song 2 tên khác nhau cho cùng 13 entity (`scr_prac` vs `securities_practitioner`) trong nhiều tháng mà không ai phát hiện, vì mỗi file được review độc lập.
- **Phạm vi tự động hóa — chỉ 4 nguồn có cấu trúc trường rõ ràng, đối chiếu tất định (không đoán):**
  1. `datamart_attributes.csv` (master) — **anchor set**, nguồn sự thật duy nhất
  2. `Datamart/lld/{MODULE}/DTM_{MODULE}_*.csv` (Attributes detail) — cùng cấu trúc cột, so trực tiếp
  3. `Datamart/datamart_model.yaml` — so `logical_name`↔`datamart_table` (entity), `columns[].logical_name`↔`columns[].physical_name` (cột)
  4. `Datamart/lld/DTM_{MODULE}_Detail_Mapping.csv` — `mart_table`/`mart_column` (logical) phải resolve đúng `datamart_table`/`datamart_column` (physical) trong anchor, và cột `logic` phải chứa đúng chuỗi `<physical_table>.<physical_column>` tương ứng
  5. `Datamart/hld/DTM_{MODULE}_Entities.csv` — `datamart_entity` (logical) phải tồn tại trong anchor set
- **KHÔNG tự động hóa cho `HLD.md`** — free-text + mermaid, regex bắt token dễ false positive (node ID, alias biến, tên Atomic lẫn trong công thức). Khi TC7 FAIL ở bất kỳ nguồn nào trong 5 nguồn trên, bước sửa lỗi (Kịch bản C) đã yêu cầu `grep -rn "tên_cũ" Datamart/` — lệnh này tự nhiên quét luôn HLD.md, nên HLD vẫn được rà soát nhưng qua cơ chế sửa lỗi thủ công, không qua TC7 tự động.
- Chạy script sau (xây anchor set 1 lần, đối chiếu cả 4 nguồn):
  ```bash
  python3 -c "
  import csv, yaml, re, glob

  with open('Datamart/lld/datamart_attributes.csv', encoding='utf-8-sig') as f:
      rows = list(csv.reader(f))
  header = rows[0]
  idx = {h: i for i, h in enumerate(header)}

  entity_map, column_map = {}, {}
  for r in rows[1:]:
      ent, tbl, attr, col = r[idx['datamart_entity']], r[idx['datamart_table']], r[idx['datamart_attribute']], r[idx['datamart_column']]
      entity_map[ent] = tbl
      column_map[(ent, attr)] = col

  fails = []

  # Nguồn 2: Attributes detail — thay '{MODULE}' bằng module đang xử lý
  for fp in glob.glob('Datamart/lld/{MODULE}/DTM_{MODULE}_*.csv'):
      with open(fp, encoding='utf-8-sig') as f:
          rows2 = list(csv.reader(f))
      h2 = rows2[0]; i2 = {h: i for i, h in enumerate(h2)}
      for r in rows2[1:]:
          ent, tbl, attr, col = r[i2['datamart_entity']], r[i2['datamart_table']], r[i2['datamart_attribute']], r[i2['datamart_column']]
          if ent in entity_map and entity_map[ent] != tbl:
              fails.append(('detail_csv:entity', fp, ent, tbl, entity_map[ent]))
          if (ent, attr) in column_map and column_map[(ent, attr)] != col:
              fails.append(('detail_csv:column', fp, f'{ent}.{attr}', col, column_map[(ent, attr)]))

  # Nguồn 3: datamart_model.yaml
  with open('Datamart/datamart_model.yaml', encoding='utf-8') as f:
      model = yaml.safe_load(f)
  for e in model['entities']:
      logical, physical = e['logical_name'], e['datamart_table']
      if logical in entity_map and entity_map[logical] != physical:
          fails.append(('model:entity', 'datamart_model.yaml', logical, physical, entity_map[logical]))
      for c in e.get('columns', []):
          key = (logical, c['logical_name'])
          if key in column_map and column_map[key] != c['physical_name']:
              fails.append(('model:column', 'datamart_model.yaml', f\"{logical}.{c['logical_name']}\", c['physical_name'], column_map[key]))

  # Nguồn 4: Detail Mapping — thay '{MODULE}' bằng module đang xử lý
  dm_path = 'Datamart/lld/DTM_{MODULE}_Detail_Mapping.csv'
  with open(dm_path, encoding='utf-8-sig') as f:
      dm_rows = list(csv.reader(f))
  dh = dm_rows[0]; di = {h: i for i, h in enumerate(dh)}
  for r in dm_rows[1:]:
      mart_table, mart_col, logic, role = r[di['mart_table']], r[di['mart_column']], r[di['logic']], r[di['column_role']]
      if role in ('DERIVED', 'PENDING') or not mart_table or not mart_col:
          continue
      if mart_table not in entity_map:
          fails.append(('detail_mapping:entity_not_found', dm_path, r[di['kpi_id']], mart_table, None))
          continue
      exp_col = column_map.get((mart_table, mart_col))
      if exp_col is None:
          fails.append(('detail_mapping:column_not_found', dm_path, r[di['kpi_id']], f'{mart_table}.{mart_col}', None))
          continue
      expected_ref = f\"{entity_map[mart_table]}.{exp_col}\"
      if expected_ref not in logic:
          fails.append(('detail_mapping:logic_missing_ref', dm_path, r[di['kpi_id']], f'{mart_table}.{mart_col}', expected_ref))

  # Nguồn 5: Entities.csv — thay '{MODULE}' bằng module đang xử lý
  with open('Datamart/hld/DTM_{MODULE}_Entities.csv', encoding='utf-8-sig') as f:
      ent_rows = list(csv.reader(f))
  eh = ent_rows[0]; ei = eh.index('datamart_entity')
  for r in ent_rows[1:]:
      if r[ei] not in entity_map:
          fails.append(('entities_csv:not_in_anchor', 'Entities.csv', r[ei], None, None))

  print(f'Tổng issue: {len(fails)}')
  for f_ in fails:
      print(' ', f_)
  "
  ```
- **Lưu ý khi đọc kết quả `detail_mapping:logic_missing_ref`:** Có thể là false positive hợp lệ khi cột dùng pattern đặc biệt không có prefix bảng (VD: `src_stm_code` filter viết dạng `"src_stm_code = 'VALUE'"` không kèm `<table>.`, theo rule L11) — xác nhận từng trường hợp trước khi kết luận lỗi, không tự động sửa hàng loạt.
- Báo: `✅ TC7 PASS: 0 issue giữa 5 nguồn` hoặc `❌ TC7 FAIL: [danh sách issue theo nguồn]` — phân loại rõ nguồn nào lệch, giá trị nào đúng (anchor = `datamart_attributes.csv`).
- Nếu FAIL → xác định nguồn đang sai (không phải anchor — anchor luôn đúng vì là nguồn sự thật) → sửa theo Kịch bản C → **đồng thời `grep -rn "tên_cũ" Datamart/hld/DTM_{MODULE}_HLD.md` để rà soát HLD thủ công** (không tự động qua TC7) → chạy lại TC7 → báo kết quả.

**TC8 — Tiền tố/hậu tố `datamart_table` khớp `table_type` (bắt buộc dùng Bash tool):**

- Mục đích: TC6 chỉ kiểm tra physical name có đúng thuật toán tách-từ + exceptions của **logical name** không (VD "Practitioner" → `prac`) — không kiểm tra bảng có đúng **tiền tố/hậu tố theo loại bảng** hay không. Bài học thực tế (module QLKD, 2026-07-24): entity `Market Index Snapshot` là Fact (`table_type: "fact"`, có FK Dimension, measure, đúng grain Fact Snapshot) nhưng được đặt tên `market_index_snpst` — thiếu hẳn tiền tố `fct_`, khác biệt với 4/5 Fact khác cùng module QLKD đều có `fct_`. TC6 không bắt được lỗi này vì thuật toán tách-từ của TC6 chỉ áp dụng cho phần logical name sau tiền tố (TC6 coi "Fact" là 1 token thường không có trong `datamart_entity` gốc nếu người thiết kế quên thêm), lỗi lọt qua nhiều vòng review cho tới khi so sánh chéo với 1 Fact khác cùng nguồn Atomic ở module NDTNN mới lộ ra.
- Quy tắc tiền tố/hậu tố chuẩn theo `table_type` (tra từ `datamart_model.yaml` thực tế, không suy đoán):
  - `table_type: "fact"` → `datamart_table` PHẢI bắt đầu bằng tiền tố `fct_`.
  - `table_type: "operational"` → `datamart_table` PHẢI bắt đầu bằng tiền tố `opr_`.
  - `table_type: "dim"` → `datamart_table` PHẢI kết thúc bằng hậu tố `_dim` (ngoại lệ: `cdr_dt_dim` và `cl_dim` vẫn theo đúng hậu tố này, không phải ngoại lệ thật).
  - Không áp dụng cho bảng Classification Value dùng chung (`cl_dim`) nếu đã có exception ghi nhận riêng — nhưng mặc định coi là lỗi thật cho tới khi tìm được bằng chứng ngoại lệ cụ thể (cùng nguyên tắc thận trọng như TC6).
  - **Ngoại lệ — nhóm Fact dạng "report" (quyết định 2026-07-24, module NDTNN `foreign_investor_trading_statistics_rpt`/`foreign_investor_trading_detail_rpt`):** Fact phục vụ báo cáo đóng gói cố định theo kỳ (ETL append-only theo Report Date, không SCD4A, thường denormalize hoàn toàn không FK Dimension) dùng **hậu tố `_rpt`** làm dấu hiệu nhận diện thay cho tiền tố `fct_` — bảng loại này KHÔNG cần (và không nên) có cả tiền tố `fct_` lẫn hậu tố `_rpt` cùng lúc, chỉ `_rpt` là đủ. Áp dụng đồng thời cho `logical_name` — cũng KHÔNG mang tiền tố "Fact" (VD: `"Foreign Investor Trading Statistics Report"`, không phải `"Fact Foreign Investor Trading Statistics Report"`), dù `table_type` đăng ký là `"fact"`. Tiêu chí phân biệt Fact vs Operational khi quyết định table_type: **Fact = append theo thời gian** (mỗi lần ETL chạy thêm dòng cho kỳ mới, không update dòng cũ); **Operational = SCD4A** (giữ current-state, ETL update/replace theo latest) — không dùng "có denormalize hay không" làm tiêu chí phân loại table_type (denormalize là thuộc tính độc lập, áp dụng được cho cả Fact lẫn Operational).
- Chạy script sau **trên toàn bộ `datamart_model.yaml`** (không chỉ entity vừa thiết kế — vì đây là lỗi loại "thiếu nhất quán với quy ước module", chỉ lộ ra khi so sánh chéo với các entity cùng `table_type` khác, giống cách TC7 phải quét toàn bộ thay vì chỉ file đang sửa):
  ```bash
  python3 -c "
  import re

  with open('Datamart/datamart_model.yaml', encoding='utf-8') as f:
      content = f.read()

  blocks = re.split(r'\n  - id: ', content)
  fails = []
  for b in blocks[1:]:
      tbl_m = re.search(r'datamart_table: \"([^\"]+)\"', b)
      tt_m = re.search(r'table_type: \"([^\"]+)\"', b)
      logical_m = re.search(r'logical_name: \"([^\"]+)\"', b)
      if not (tbl_m and tt_m):
          continue
      table, ttype, logical = tbl_m.group(1), tt_m.group(1), logical_m.group(1) if logical_m else '?'
      is_report = table.endswith('_rpt')
      if ttype == 'fact' and is_report:
          # Nhóm Fact-report: bắt buộc _rpt, cấm cả tiền tố fct_ lẫn logical_name có tiền tố \"Fact\"
          if table.startswith('fct_'):
              fails.append((logical, table, ttype, 'Fact-report không được có cả tiền tố fct_ lẫn hậu tố _rpt — chỉ giữ _rpt'))
          if logical.startswith('Fact '):
              fails.append((logical, table, ttype, 'Fact-report — logical_name không được mang tiền tố \"Fact\"'))
      elif ttype == 'fact' and not table.startswith('fct_'):
          fails.append((logical, table, ttype, 'thiếu tiền tố fct_'))
      elif ttype == 'operational' and not table.startswith('opr_'):
          fails.append((logical, table, ttype, 'thiếu tiền tố opr_'))
      elif ttype == 'dim' and not table.endswith('_dim'):
          fails.append((logical, table, ttype, 'thiếu hậu tố _dim'))

  print(f'Tổng lỗi: {len(fails)}')
  for logical, table, ttype, reason in fails:
      print(f'  ❌ {logical!r} | datamart_table={table!r} | table_type={ttype!r} | {reason}')
  "
  ```
- Báo: `✅ TC8 PASS: 0 mismatch tiền tố/hậu tố` hoặc `❌ TC8 FAIL: [danh sách logical_name | datamart_table | table_type | lý do]`.
- Nếu FAIL → đổi tên theo Kịch bản C (đồng bộ cả `datamart_attributes.csv`, `datamart_model.yaml`, file Attributes detail, Detail Mapping, SQL Phase 3, HLD.md — dùng `grep -rn "tên_cũ" Datamart/` để tìm hết vị trí cần sửa) → chạy lại TC8 → báo kết quả.
- **Lưu ý:** nếu entity dùng chung nhiều module (`modules_using` có >1 giá trị), việc đổi tên ảnh hưởng tới mọi module đang reuse — phải rà cả Detail Mapping và HLD của các module khác trong `modules_using`, không chỉ module đang thiết kế.

> **Quy tắc SELF-REVIEW:** Chỉ trình bày file cho human sau khi cả 9 TC (TC1, TC2, TC2b, TC3 gồm cả TC3b, TC4, TC5, TC6, TC7, TC8) đều PASS. Nếu có TC FAIL → sửa → chạy lại TC đó → báo kết quả cuối cùng kèm tóm tắt "Đã sửa X lỗi" trước khi trình bày file.

### Checklist Phase 1

```
PRE-CHECK (trước khi sinh):
□ Đọc Entities.csv — liệt kê bảng theo reuse_status (new/partial/reuse)
□ Bảng reuse: ghi note bỏ qua, không sinh file
□ Bảng partial: đọc master, báo cáo delta, chờ human approve trước khi sinh
□ Xác định driving table + src_stm_code cho từng bảng new/partial (tra manifest → entity YAML → classification_context)
□ Đối chiếu bảng "Physical name chuẩn" từ Phase 0 Bước P2b — mọi entity dùng chung ≥2 bảng phải dùng đúng token đã duyệt
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
□ etl_logic_type điền mọi row — kể cả pending row, trừ PK (BK vẫn phải điền)
□ etl_logic (content) trống chỉ khi key = PK hoặc etl_logic_type = pending — BK KHÔNG được để trống
□ etl_logic có JOIN (join_atomic/lookup_dim/lookup_date): JOIN clause đặt TRƯỚC, cột giá trị SAU dấu → (không được ngược thứ tự)
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
□ Mọi Dimension có ≥1 BK (join anchor cho Fact lookup)
□ Mọi Operational dùng trường _code làm PK duy nhất — không tạo surrogate key (_id)
□ Fact KHÔNG có dòng key = PK (dù có cột surrogate id kỹ thuật — để key trống)
□ Không thiết kế Effective Date / Expiry Date / Population Date
□ Mọi bảng dim/operational có attribute src_stm_code (cuối danh sách)
□ src_stm_code: mọi bảng (kể cả single-source) → luôn có WHERE filter trong etl_logic (forward-compatibility)
□ src_stm_code: multi-source nhiều nguồn dùng cùng lúc → dùng WHERE IN (...)
□ src_stm_code: multi-source tách bộ (partition/UNION) → N bộ × M dòng, mỗi bộ có src_stm_code riêng
□ src_stm_code: bộ chưa xác định Atomic source → etl_logic_type = pending toàn bộ bộ đó
□ src_stm_code: fact No-Driving-Table → không thêm
□ src_stm_code: giá trị dùng dấu `_` (VD NHNCK_CERTIFICATES) — KHÔNG dùng dấu `.` theo tên file Atomic YAML (VD NHNCK.CERTIFICATES); áp dụng cả tên file DTM_{MODULE}_{table}_{src_stm_code}.csv
□ cl_dim: tên cột scm_code / cl_code / cl_nm (align Atomic cv); Detail Mapping dùng Scheme Code= / Classification Code=
□ nullable = false cho PK / BK / FK
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
BƯỚC 0 — TODO LIST TOÀN MODULE (bắt buộc, chạy 1 lần trước khi vào loop nhóm):
□ Quét lại HLD Section 2 từ đầu đến hết (Nhóm 1 → Nhóm N_max) — ĐỘC LẬP với Phase 0 Plan,
  không copy danh sách nhóm từ Plan (Plan có thể đã lược bỏ nhóm PENDING toàn bộ vì không cần
  bảng Attributes ở Phase 1)
□ Lập bảng todo list: Nhóm | Tên nhóm | Trạng thái HLD (READY/READY thu hẹp/PENDING toàn bộ) |
  Đã xử lý Phase 2? (chưa)
□ Tổng số dòng todo list PHẢI bằng tổng số nhóm xuất hiện trong HLD Section 2 — kể cả nhóm
  PENDING toàn bộ không có bảng nào ở Phase 1
□ Trình bày todo list cho human → DỪNG chờ xác nhận trước khi bắt đầu Nhóm 1
□ Cập nhật cột "Đã xử lý Phase 2?" ngay sau khi mỗi nhóm được human duyệt block KPI — dùng
  bảng này để xác định "Nhóm cuối" thay vì suy đoán theo Plan Phase 0

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
□ Append đúng THỨ TỰ SỐ NHÓM TĂNG DẦN — xem TC6; nếu file hiện tại đã append lệch thứ tự từ
  trước, KHÔNG tự ý append tiếp theo thứ tự sai đó, báo cho human trước
□ Sau khi human duyệt block: append vào DTM_{MODULE}_Detail_Mapping.csv → báo "Đã append N dòng nhóm [N] vào Detail Mapping"

SELF-REVIEW Phase 2 — mỗi nhóm (bắt buộc trước khi trình bày — chạy 4 testcase, báo kết quả):

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

TC3 — Logic dùng tên physical (snake_case), đủ prefix table_name.column_name:
□ Kiểm tra cột `logic`: tên bảng và cột phải là tên physical/snake_case (ví dụ "fct_mkt_rsk_snpst.compliance_score", "cdr_dt_dim.cdr_dt") — không phải tên logical ("Fact Market Risk Snapshot", "Inspection Date")
□ Báo: ✅ TC3 PASS hoặc ❌ TC3 FAIL: [danh sách kpi_id có logic dùng tên logical thay vì physical]
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
□ Cập nhật todo list Bước 0: đánh dấu Nhóm N = đã xử lý
→ Báo: "Nhóm [N] — [Tên nhóm] hoàn thành. Tiếp tục Nhóm [N+1] — [Tên nhóm N+1]?"
→ DỪNG chờ human xác nhận → ❌ KHÔNG tự bắt đầu nhóm tiếp theo
→ "Nhóm cuối" = nhóm cuối trong todo list Bước 0 (toàn bộ HLD), KHÔNG phải nhóm cuối trong
  Phase 0 Plan — nếu Plan Phase 0 không liệt kê hết nhóm HLD, vẫn phải tiếp tục xử lý các nhóm
  còn thiếu trong todo list trước khi coi là hoàn thành

SELF-REVIEW Phase 2 — module-level (bắt buộc, chạy 1 lần sau khi TẤT CẢ nhóm trong todo list
đã xử lý, TRƯỚC KHI báo "Tất cả nhóm hoàn thành"):

TC5 — Đối chiếu tổng số nhóm/KPI toàn module (không chỉ từng nhóm riêng lẻ):
□ Lấy tập hợp số nhóm (cột `nhom`, parse ra số nhóm) xuất hiện trong Detail Mapping
□ Lấy tập hợp số nhóm xuất hiện trong HLD Section 2 (Nhóm 1 → Nhóm N_max)
□ Đối chiếu 2 tập — báo danh sách nhóm có trong HLD nhưng THIẾU trong Detail Mapping
□ Lấy toàn bộ KPI_ID unique trong HLD (mọi nhóm, mọi trạng thái) và toàn bộ KPI_ID unique trong
  Detail Mapping → đối chiếu, báo danh sách KPI_ID có trong HLD nhưng thiếu trong Detail Mapping
□ Báo: ✅ TC5 PASS: [N_nhom] nhóm, [N_kpi] KPI_ID unique — khớp đủ HLD
  hoặc ❌ TC5 FAIL: thiếu [X] nhóm ([danh sách]), thiếu [Y] KPI_ID ([danh sách])
□ Nếu FAIL → bổ sung nhóm/KPI còn thiếu trước khi báo hoàn thành Phase 2 (không được báo hoàn
  thành khi TC5 còn FAIL)

TC6 — Thứ tự nhóm trong file tăng dần theo số nhóm:
□ Duyệt cột `nhom` theo thứ tự xuất hiện trong file (top-to-bottom), parse số nhóm bằng regex
  (VD: `Nhóm (\d+)`) — KHÔNG so sánh dạng chuỗi (string sort xếp "Nhóm 11" trước "Nhóm 2" là SAI)
□ Nhóm nào xuất hiện lần đầu ở dòng thứ i thì số nhóm phải ≥ số nhóm xuất hiện lần đầu ở mọi dòng
  trước i — tức thứ tự nhóm-xuất-hiện-lần-đầu phải là 1, 2, 3, ..., N_max tăng dần liên tục
□ Báo: ✅ TC6 PASS: thứ tự nhóm đúng 1→N_max
  hoặc ❌ TC6 FAIL: nhóm [X] xuất hiện trước nhóm [Y] dù X > Y — [vị trí dòng cụ thể]
□ Nếu FAIL → sắp xếp lại toàn bộ file theo đúng thứ tự số nhóm tăng dần (giữ nguyên nội dung
  từng dòng, chỉ đổi thứ tự dòng) — báo cho human trước khi ghi đè file, vì đây là thay đổi
  toàn file không phải append

□ TC5 + TC6 đều PASS → báo "Tất cả nhóm hoàn thành. Chuyển sang Phase 3?"
→ DỪNG chờ human xác nhận chuyển Phase 3
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
□ Thứ tự cột: fact columns → Calendar Date columns → dim columns
□ Operational: chỉ operational columns (không có Calendar Date, không có dim)
□ Không có technical metadata (ds_batch_date, ds_population_timestamp) trong flat table
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
□ Đếm cột SELECT = đếm cột CREATE
□ Tên bảng nguồn fact: datamart.{module}_{datamart_table} (có prefix module)
□ Tên bảng nguồn operational: datamart.{datamart_table} (không có prefix module)
□ Calendar Date join: datamart.{module}_calendar_date_dimension / date_dimension_id = f.{fk_col}
□ Dim join: alias rõ ràng, ON {dim_pk} = f.{fk_col}
□ Operational: không có LEFT JOIN nào

POST-CHECK (sau khi sinh):
□ Cross-check: mỗi cột trong CREATE có đúng 1 entry tương ứng trong SELECT của INSERT
□ Không có cột nào trong Attributes.csv bị bỏ sót trong CREATE TABLE (fact/operational columns)
□ Không có cột nào trong CREATE TABLE (fact/operational section) mà KHÔNG có trong Attributes.csv — cột thừa phải xóa
□ Dim JOIN: mọi dim được JOIN phải có FK tương ứng trong Attributes.csv — dim không có FK thì không JOIN, không lấy cột
□ Sau khi xuất 2 file: DỪNG chờ human duyệt → ❌ KHÔNG tự kết thúc skill khi chưa có xác nhận
```
