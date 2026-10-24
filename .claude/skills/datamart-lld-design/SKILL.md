---
name: datamart-lld-design
description: |
  Thiết kế Low-Level Design (LLD) cho Datamart layer — Phase 1, 2, 3 trong workflow thiết kế Datamart UBCKNN.
  Sử dụng khi: HLD + Entities đã được duyệt, cần thiết kế attribute mapping
  (Attributes.csv), mapping KPI (Detail_Mapping.csv), và sinh DDL flat table SQL.

  Output:
    Datamart/lld/{MODULE}/DTM_{MODULE}_{mart_table}.csv                        (Phase 1 — fact)
    Datamart/lld/{MODULE}/DTM_{MODULE}_{mart_table}_{src_stm_code}.csv         (Phase 1 — dim/operational)
    Datamart/lld/datamart_attributes.csv                                        (Phase 1 — master, sinh bằng build_registry.py)
    Datamart/lld/DTM_{MODULE}_Detail_Mapping.csv                               (Phase 2)
    Datamart/flat-table/{MODULE}/01_create_{module}_flat_tables.sql            (Phase 3)
    Datamart/flat-table/{MODULE}/02_populate_{module}_flat_tables.sql          (Phase 3)

  Input bắt buộc Phase 1: DTM_{MODULE}_HLD.md + DTM_{MODULE}_Entities.csv đã duyệt + DataModel/Atomic/dm_manifest.yaml
---

# Skill: Thiết kế LLD Datamart

File này giữ phần dùng ở mọi Phase: điều kiện tiên quyết, cách tra Atomic, quy tắc ngữ cảnh, lệnh kiểm sau mỗi thay đổi, bảng tóm tắt luật A1–A26 và quy trình tổng. Chi tiết từng Phase nằm trong `reference/` — chỉ đọc file của Phase đang làm.

## Đọc gì, khi nào

| Khi | Đọc | Nội dung chính |
|---|---|---|
| Mọi Phase | [`reference/rules.md`](reference/rules.md) — đúng mục của luật liên quan | Luật A1–A26 đầy đủ, ví dụ sai thực tế, lệnh kiểm |
| Phase 0 — Plan | [`reference/phase0_plan.md`](reference/phase0_plan.md) | Bước P1–P3, định dạng Plan tổng, bảng physical name chuẩn |
| Phase 1 — Attributes | [`reference/phase1_workflow.md`](reference/phase1_workflow.md) | Input, Bước 0–3 (driving table, coverage Dimension, `src_stm_code`, xuất CSV), Checklist Phase 1 |
| | [`reference/phase1_attributes.md`](reference/phase1_attributes.md) | 15 cột CSV, `etl_logic_type`, ràng buộc key/nullable, partial, merge |
| | [`reference/physical_naming.md`](reference/physical_naming.md) | Quy tắc tên physical, role-playing date FK, Kịch bản C (sửa tên/logic) |
| | [`reference/phase1_selfreview.md`](reference/phase1_selfreview.md) | SELF-REVIEW TC1–TC12, chạy trước khi trình bày từng file |
| Phase 2 — Detail Mapping | [`reference/phase2_workflow.md`](reference/phase2_workflow.md) | Input/Output, ghi qua `apply_patch.py` / `apply_kpi_patch.py`, Checklist + SELF-REVIEW Phase 2 |
| | [`reference/phase2_detail_mapping.md`](reference/phase2_detail_mapping.md) | `column_role`, 4 trường hợp đặc biệt, lỗi tái diễn L1–L18 |
| Phase 3 — Flat table | [`reference/phase3_workflow.md`](reference/phase3_workflow.md) | Đồng bộ khép kín LLD ↔ flat, Trigger 1–5, Checklist Phase 3, All-Tier Cleanup |
| | [`reference/phase3_flat_table.md`](reference/phase3_flat_table.md) | Type mapping ClickHouse, ENGINE/PARTITION, pattern CREATE + POPULATE |
| Ví dụ | [`examples/etl_logic_correct.md`](examples/etl_logic_correct.md), [`examples/etl_logic_wrong.md`](examples/etl_logic_wrong.md), [`examples/key_constraints.md`](examples/key_constraints.md) | Mẫu đúng/sai `etl_logic`, ràng buộc key theo loại bảng |

Bỏ một Fact/Dim draft ở bất kỳ Phase nào: làm đủ 5 bước All-Tier Cleanup ở cuối `reference/phase3_workflow.md`.

## Điều kiện tiên quyết

- [ ] `Datamart/hld/DTM_{MODULE}_HLD.md` tồn tại và đã được user duyệt
- [ ] `Datamart/hld/DTM_{MODULE}_Entities.csv` tồn tại và đã được user duyệt (có cột `reuse_status`)
- [ ] `DataModel/Atomic/dm_manifest.yaml` tồn tại — **entry point tra cứu Atomic entities, Nguồn 1 (ưu tiên cao nhất)**
- [ ] `DataModel/working/Atomic/lld/manifest.yaml` tồn tại — **entry point tra cứu Atomic entities draft, Nguồn 2 (chỉ tra khi Nguồn 1 không có entry)**
- [ ] `Datamart/datamart_model.yaml` tồn tại — registry schema cross-module (có thể rỗng nếu module đầu tiên)
- [ ] `Datamart/lld/datamart_attributes.csv` tồn tại (có thể rỗng nếu module đầu tiên)
- [ ] `BRD/BA/BA_analyst_{MODULE}.csv` tồn tại (cần cho Phase 2)
- [ ] `DataModel/working/Atomic/lld/classification_schemes.yaml` tồn tại (cần khi map từ danh mục CV)

> **❌ TUYỆT ĐỐI CẤM SỬA ATOMIC TỪ SKILL THIẾT KẾ DATAMART:**
> Skill thiết kế Datamart (`datamart-hld-design`, `datamart-lld-design`, `datamart-review`) chỉ có quyền **READ-ONLY** đối với thư mục `DataModel/Atomic/` và `DataModel/working/Atomic/`.
> - Tuyệt đối **KHÔNG ĐƯỢC** tạo file mới, sửa đổi thuộc tính, thêm cột kỹ thuật, hoặc can thiệp vào bất kỳ file YAML nào trong `DataModel/`.
> - Nếu Atomic thiếu bảng, thiếu cột, hoặc thiếu audit field cần thiết cho Datamart:
>   - Đánh dấu KPI liên quan là **PENDING** (ghi rõ lý do: "Thiếu nguồn Atomic / Chưa có trong Atomic schema").
>   - Ghi nhận vào Section 5 Open Issues (`DTM_{MODULE}_HLD.md`).
>   - DỪNG lại báo cáo human để Data Modeler thuộc luồng Atomic xử lý độc lập. Tuyệt đối không tự ý sửa Atomic!
>
> **QUYẾT ĐỊNH CỨNG:** Claude KHÔNG được đoán `source_entity` hay `source_attribute`.
> Mọi mapping phải tra cứu trực tiếp từ entity YAML files, theo đúng thứ tự ưu tiên 2 nguồn dưới đây.
>
> **❌ TUYỆT ĐỐI CẤM dùng `DataModel/working/Atomic_LinhLV/`** — track cũ đã revert, out of date. Dù cấu trúc thư mục giống hệt `DataModel/Atomic/` (cùng BCV folder: Arrangement/Common/Event/...), entity ở đây KHÔNG được coi là nguồn hợp lệ dưới bất kỳ hình thức nào — kể cả khi không tìm thấy entity đó ở 2 nguồn hợp lệ bên dưới, vẫn phải kết luận PENDING, không fallback sang `Atomic_LinhLV`.
>
> **Quy trình tra cứu Atomic — 2 nguồn theo thứ tự ưu tiên:**
>
> | Ưu tiên | Nguồn | Manifest | Schema manifest |
> |---|---|---|---|
> | **1** | `DataModel/Atomic/` | `DataModel/Atomic/dm_manifest.yaml` | `dm_manifest` — field `subfolder`/`file_name`/`physical_name`/`status` |
> | **2** | `DataModel/working/Atomic/` | `DataModel/working/Atomic/lld/manifest.yaml` | `lld_manifest` — field `source_system`/`source_table`/`atomic_entity`/`lld_file`/`design_status` |
>
> 1. Mở `DataModel/Atomic/dm_manifest.yaml` → tìm entry có `physical_name` khớp `atomic_table` đang cần.
>    - Có entry (bất kể `status: approved` hay `draft`) → dùng Nguồn 1, đọc `subfolder` + `file_name` → mở file `DataModel/Atomic/{subfolder}/{file_name}`.
>    - Lấy `ldm.physical_name` = `atomic_table`, `attribute.physical_name` = `atomic_column`.
> 2. Không có entry ở Nguồn 1 → mở `DataModel/working/Atomic/lld/manifest.yaml` → tìm entry khớp `atomic_entity`/`source_table` → có entry → mở file `DataModel/working/Atomic/lld/{source_system}/{lld_file}` để lấy attribute tương ứng.
> 3. Không có entry ở cả 2 nguồn → Atomic PENDING, không suy diễn.
> 4. **Trùng ở cả 2 nguồn** (entity vừa có ở Nguồn 1 vừa còn bản draft cũ ở Nguồn 2) → luôn dùng Nguồn 1, bỏ qua Nguồn 2.
> 5. **Nhiều source table cùng `physical_name`/`atomic_entity`:** đọc TẤT CẢ entry cùng tên — không dừng ở entry đầu.
> 6. **`src_stm_code` value:** trích từ `classification_context` của attribute `Source System Code` — format `"Source System Code = 'VALUE'"` → value = `VALUE`.

---

## Ngữ cảnh — trần 500K token mỗi bước

**KHÔNG bao giờ Read trực tiếp 4 nhóm file này** — luôn đi qua lát cắt:

| File | Vì sao | Thay bằng |
|---|---|---|
| `BRD/BA/BA_analyst_*.csv` | QLKD 998K token, GSĐC 443K | `ba_slice.py --index` rồi `--nhom N` |
| `Datamart/hld/DTM_*_HLD.md` | TKNB 163K; bị yêu cầu đọc lại 2 lần/module | `ctx_slice.py --sections` + `--nhom N` |
| `Datamart/lld/DTM_*_Detail_Mapping.csv` | QLKD 552K; TC4–TC7 cũ nạp lại 4 lần | `ctx_slice.py --nhom N`; kiểm tra bằng `lld_selfcheck.py` |
| `Datamart/lld/datamart_attributes.csv` | master registry 800KB | `grep`, hoặc file per-table trong `Datamart/lld/{MODULE}/` |

Ghi ngược lại file gốc bằng `apply_patch.py` — **không** Edit tay file lớn, **không** append mù
(append chỉ đúng khi viết mới, sai khi sửa lại một Nhóm đã có: sinh Nhóm trùng và phá thứ tự TC6).
Sau khi `apply_patch.py` báo ghi thành công, **không Read lại file lớn vừa ghi để "kiểm tra"** — diff
đã in ra (hoặc `--quiet` xác nhận số dòng thêm/bớt) là bằng chứng đủ; đọc lại cả file chỉ tốn ngân
sách 500K mà không phát hiện thêm gì so với diff đã thấy.

Mọi script ở `.claude/skills/datamart-review/scripts/`. Kiểm ngân sách trước bước nặng — dùng số đo của lệnh này, không dùng số cũ chép trong tài liệu:

```bash
python .claude/skills/datamart-review/scripts/ctx_budget.py --module {MODULE} --all-steps
```

Nếu một bước vượt trần: chia nhỏ theo Nhóm, **không** nén hay bỏ bớt thông tin nghiệp vụ.

---

## Sau mỗi thay đổi LLD — chạy trước khi báo kết quả

```bash
python .claude/skills/datamart-review/scripts/run_quality_gates.py --module {MODULE} --strict
```

Chạy đủ Pre-flight + Gate 0 → Gate 9 (thêm `--nhom N …` để bật Gate 10 cho các Nhóm vừa sửa).
**Không được tuyên bố hoàn thành khi chưa dán output của lệnh này.**
Nếu chỉ sửa 1 file, vẫn chạy toàn bộ — các lỗi dưới đây là lỗi *liên file*, sửa cục bộ không thấy.

File đọc bảng Atomic snapshot/event: chạy thêm `check_date_bound.py --module {MODULE} --file {mart_table}` (TC12). Gate 8 không kiểm A19, nên `run_quality_gates.py` PASS chưa có nghĩa `etl_logic` đã khóa ngày.

### Artifact sinh tự động — KHÔNG sửa tay (RFC Đ3/Đ4/Đ7)

Sau khi sửa file LLD per-module (`Datamart/lld/{MODULE}/*.csv`), **luôn `--check` trước** (Gate 9 cũng chạy đúng
các lệnh này, chỉ đọc):

```bash
python .claude/skills/datamart-review/scripts/build_registry.py --check     # datamart_attributes.csv
python .claude/skills/datamart-review/scripts/build_model_yaml.py --check   # datamart_model.yaml (khối columns)
python .claude/skills/datamart-review/scripts/build_kpi_index.py --check    # Datamart/index/kpi_index.csv
python .claude/skills/datamart-review/scripts/build_flat_tables.py --module {MODULE} --check
# --check báo thiếu khối bảng + cột LLD thiếu trong flat DDL (cùng ngữ nghĩa Gate 4). Có thiếu -> A20: --sync-columns [--apply]
```

Ghi thật (bỏ `--check`) chỉ khi `--check` cho thấy phần lệch **chỉ** thuộc bảng vừa sửa. Cả 3 script build có chốt chặn mất dữ liệu; `--allow-drop` / `--allow-shrink` chỉ dùng khi human đã duyệt (hook `dm_guard` sẽ hỏi lại). Chi tiết từng chốt: `reference/rules.md`, mục "Ghi chú lịch sử". `build_registry.py` từ chối ghi khi master còn bảng không có file per-module (bảng mồ côi) — khi đó dừng và báo human, không sửa tay master để lách. `--allow-drop` xóa **mọi** bảng mồ côi cùng lúc, chỉ dùng khi danh sách của `--check` đúng bằng các bảng human đã duyệt bỏ.

- `Datamart/lld/datamart_attributes.csv` và khối `columns` trong `Datamart/datamart_model.yaml`
  là **output sinh ra** — sửa tay sẽ bị ghi đè ở lần build kế tiếp. Nguồn sự thật là file LLD per-module.
- Tra cứu nhanh một KPI (ở đâu, trạng thái gì, map cột nào) dùng `Datamart/index/kpi_index.csv`
  thay vì nạp cả file HLD 3.000 dòng:
  `grep -E "^K_PTTT_58," Datamart/index/kpi_index.csv`
- Đọc/ghi CSV thiết kế bằng `datamart_common.csv_io` (`read_design_csv` / `write_design_csv`)
  — tự quote đúng và verify lại số cột sau khi ghi.
- Danh mục giá trị hợp lệ của `column_role` / `tinh_chat` / `etl_logic_type` nằm ở
  `system/rules/datamart_conventions.yaml` — đọc file này thay vì đoán theo đa số.

---

## Luật A1–A26 (tóm tắt)

Mỗi luật rút từ một lỗi thật. Bảng dưới chỉ để biết luật nào liên quan; trước khi áp dụng, đọc mục tương ứng trong [`reference/rules.md`](reference/rules.md) (`grep -n "^### A19" .claude/skills/datamart-lld-design/reference/rules.md`). Cột "Máy kiểm" ghi Gate/script bắt được lỗi và mã lỗi in ra; "—" nghĩa là chưa có script, phải tự kiểm theo hướng dẫn trong `rules.md`.

| Luật | Nội dung | Phase | Máy kiểm |
|---|---|---|---|
| A1 | `atomic_column` và mọi `bảng.cột` trong `etl_logic` phải grep được trong YAML Atomic thật; không suy tên từ nghĩa nghiệp vụ | 1 | Gate 0 `L0-ATOMIC-COLUMN-NOT-FOUND` |
| A2 | `mart_column` trong Detail Mapping phải có trong Attributes của chính bảng đó (physical hoặc logical, không tên thứ ba) | 2 | Gate 0 `L0-MART-COLUMN-NOT-FOUND` |
| A3 | Ghi CSV qua `csv.writer` / `csv_io`, không nối chuỗi; đọc lại đếm số cột từng dòng | 1, 2 | Gate 0 `L0-CSV-STRUCTURE-BROKEN` |
| A4 | Nâng/hạ READY phải sửa cả cột Trạng thái trong HLD lẫn Detail Mapping | 2 | Gate 0 `L0-HLD-LLD-STATUS-DESYNC` |
| A5 | Reuse Fact xuyên module: chép nguyên văn grain của module chủ; `source_table` ghi entity Atomic, không ghi `fct_*` | 1 | — (`L1-GRAIN-MISMATCH`) |
| A6 | Đóng Open Issue mặc định "Resolved một phần"; KPI chưa đạt tách sang issue mới | 2 | — |
| A7 | Thêm dòng vào CSV có sẵn: theo convention `column_role` / `tinh_chat` của chính file đó | 1, 2 | — |
| A8 | Window function: `PARTITION BY` + `ORDER BY <cột ngày>` + `ROWS BETWEEN` đủ mệnh đề; cấm order theo surrogate key | 1, 2 | — |
| A9 | `datamart_model.yaml`: chỉ append/patch block, cấm `yaml.dump` cả file | 1 | — |
| A10 | Ghi chú "đã lọc sẵn tại ETL" phải grep thấy điều kiện trong `etl_logic`; khóa JOIN giữa 2 nguồn phải có bằng chứng | 2 | `check_ba_mapping.py` (ngoài Gate) `L3-REFERENCE-SQL-MISALIGNMENT` — một phần |
| A11 | Kiểm toàn vẹn Detail Mapping trước khi sửa; S1 báo cắt thì dừng, đọc MEMORY.md, hỏi human — không tự khôi phục | 2 | Pre-flight S1, `ba_hld_sync_check.py` `L0-DM-FILE-INTEGRITY` |
| A12 | Không kết luận cột Atomic thiếu/rỗng chỉ từ YAML LLD; đối chiếu `BRD/Source/` và xác nhận bằng dữ liệu | 1 | — |
| A13 | Câu trả lời 1 chữ cho câu hỏi kép: nhắc lại cách hiểu trước khi sửa ≥ 5 cột hoặc nhiều module | mọi | — (quy trình) |
| A14 | PII đã mã hóa từ nguồn: lên Datamart như cột thường, không chặn, không hạ PENDING vì PII | 1 | — (quy trình) |
| A15 | Comment flat SQL không viết `:etl_date` dính dấu câu | 3 | Gate 8 `L4-FLAT-COMMENT-PARAM` |
| A16 | Dòng nhiều bảng: `atomic_column` ghi `bảng.cột` cho từng cột | 1 | Gate 0 `L0-MULTI-TABLE-COLUMN-NOT-FOUND` |
| A17 | `securities_trade` ↔ `security_trading_snapshot`: HNX nối bằng ISIN | 1 | Gate 8 `L3-HNX-ISSUE-CODE-JOIN` |
| A18 | Chỉ tiêu mã CK × ngày: dùng bản tin cuối ngày của snapshot (`trading_time DESC, sequence DESC`), không `SUM` lại `securities_trade` | 1 | Gate 8 `L3-CUMULATIVE-SNAPSHOT-NOT-DEDUPED` |
| A19 | Bảng Atomic snapshot/event: mọi tham chiếu có giới hạn ngày tường minh (R1–R6) | 1 (+ mốc ngày KPI ở Phase 2) | `check_date_bound.py` (TC12) — chưa nằm trong Gate |
| A20 | Cột mới ở Fact/Operational lên flat DDL + DML trong cùng lượt; Gate 4 FAIL không phải "tồn đọng" | 1, 3 | Gate 4 `L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING`, Gate 9 |
| A21 | Lọc VN-Index trên `market_index_snapshot`: giữ `market_code = 'HOSE'` (Data Modeler chốt 2026-10-21, BA `IndexCode`/`indexname` nhầm), KHÔNG đổi sang `index_nm`; `PARTITION BY` cuối ngày chứa `market_code`; đổi một cột thì grep và sửa đồng loạt | 1, 2 | — (quy trình) |
| A22 | **Mọi Fact khai báo ĐÚNG 1 cột `key = PK`** (khóa dòng = khóa MERGE/UPSERT, `nullable = false`, đặt đầu bảng): Dạng A (grain = 1 dòng Atomic driving) = id dòng Atomic, `direct`; Dạng B (Fact gộp/pivot) = hash mọi cột grain, `Generated`, description liệt kê cột grain. Flat ClickHouse `ORDER BY` phải chứa PK (ReplacingMergeTree dedup theo ORDER BY). Mô tả grain (yaml/Entities/HLD) nêu tên PK. Fact cũ thiếu PK nằm trong `datamart-review/reference/fact_row_key_baseline.yaml` — Fact MỚI không được thêm vào | 1, 3 | Gate 8 `L2-FACT-NO-ROW-KEY`, `L2-FACT-PK-INVALID`, `L4-FLAT-ORDERBY-MISSING-PK` |
| A23 | **PK Dimension = id Atomic khi có cột khác carry id đó:** cùng module có cột `direct` mang PK (hoặc FK-target) của entity driving thì PK Dim `etl_logic_type = direct` ← `<driving>.<pk>` (không `Generated`, không hash lại ở Datamart); không có cột carry thì giữ `Generated` (Fact→Dim nối qua `lookup_dim` theo BK). Kiểm tay: BK `*_code` của Dim cùng nguồn với `*_code` mà entity con Atomic mang | 1 | Gate 8 `L2-DIM-PK-GENERATED-CARRIED` |
| A24 | **`bảng.cột` viết trong `logic` Detail Mapping và công thức HLD phải tồn tại thật** (Attributes CSV / YAML Atomic): grep trước khi viết; đổi tên/xóa cột ở LLD ⇒ grep tên cũ trong Detail Mapping + HLD + yaml + flat ngay trong lượt đó; tên cũ chỉ được nằm trong `[...]`/`ghi_chu`. Nợ cũ ở `dm_logic_column_baseline.yaml` (cấm thêm) | 1, 2 | Gate 8 D13 `L0-DM-LOGIC-COLUMN-NOT-FOUND` |
| A25 | **Thuộc tính trùng tên ở nhiều bảng Atomic (`period_*`, `record_tp` có ở `fmr_value` và `fmr_submission`…): bảng nguồn do SQL BA dùng quyết định** — lập cặp (cột BA → bảng `FROM/JOIN` của SQL BA → entity Atomic); nghi BA ghi sai thì mở O_ issue, không tự chọn bảng tiện hơn | 1, 2 | — (đọc tay, `datamart-review` Checklist điểm 1) |
| A26 | **Kiểm kê MỌI điều kiện của SQL BA** (`WHERE`, `ON` của LEFT JOIN, CTE, `ROW_NUMBER = 1`, `NULLIF`/`*100`/`COALESCE`/`CASE`): mỗi điều kiện = có trong logic / thay thế có chủ ý (ghi + O_ issue) / không áp dụng (ghi lý do). "Active-only" chỉ miễn điều kiện slicer thời gian (`:filter_month` → `:etl_date`); `PERIOD_TYPE`, `RECORD_TYPE`, `BRANCH_FLAG`, `ID_DATE`, biểu thức tính KHÔNG được miễn. SQL BA nghi ngược ⇒ ghi lệch + mở O_ issue cùng lượt | 1, 2 | — (đọc tay, Checklist điểm 2–3, L17(e)) |

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
             → SELF-REVIEW 12 TC (TC6/TC7/TC8 quét lại TOÀN BỘ master + các nguồn khác, không chỉ file vừa sinh) → sửa nếu FAIL → trình bày SELF-REVIEW + file
             → DỪNG chờ human duyệt từng file
             → sinh lại master: build_registry.py --check → ghi thật nếu phần lệch chỉ thuộc bảng vừa duyệt
               (không append/sửa tay datamart_attributes.csv; bị chặn vì bảng mồ côi → DỪNG, báo human)
             → datamart_model.yaml: entity mới thêm block metadata bằng text (không yaml.dump);
               khối columns sinh bằng build_model_yaml.py --check → ghi thật
             → đã xử lý ≥6 Nhóm new/partial liên tiếp trong phiên hiện tại → DỪNG, báo tiến độ,
               hỏi human tiếp tục ngay hay mở phiên mới (xem CLAUDE.md — "QUY TẮC CỨNG — NGƯỠNG
               NGỮ CẢNH CẤP PHIÊN"); human xác nhận tiếp tục → reset bộ đếm, làm Nhóm N+1 Phase 1
             → làm Nhóm N+1 Phase 1 → ... → làm đến hết Nhóm cuối Phase 1

> **GATE CỨNG — chuyển Phase 2:**
> ❌ KHÔNG được bắt đầu Phase 2 khi còn bất kỳ nhóm nào chưa hoàn thành Phase 1.
> Điều kiện bắt buộc: **tất cả nhóm** (Nhóm 1 → Nhóm N_max) đã có file Attributes được human approve và master đã sinh lại bằng `build_registry.py`.
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
             → SELF-REVIEW 5 TC → sửa nếu FAIL → trình bày SELF-REVIEW + block KPI
             → DỪNG chờ human duyệt block KPI nhóm N
             → cập nhật todo list (đánh dấu Nhóm N đã xong)
             → đã xử lý ≥6 Nhóm READY (có block KPI thật, không tính PENDING toàn bộ) liên tiếp trong
               phiên hiện tại → DỪNG, báo tiến độ, hỏi human tiếp tục ngay hay mở phiên mới; human
               xác nhận tiếp tục → reset bộ đếm, làm Nhóm N+1 Phase 2
             → làm Nhóm N+1 Phase 2 → ... → hết Nhóm cuối

  → Sau khi tất cả nhóm trong todo list đã xử lý:
             Chạy SELF-REVIEW module-level TC5 (đối chiếu tổng số nhóm/KPI) + TC6 (thứ tự nhóm)
             → sửa nếu FAIL → DỪNG — báo "Tất cả nhóm Phase 2 hoàn thành, TC5+TC6 PASS."
             → chờ human xác nhận chuyển Phase 3

Phase 3:   Sau khi tất cả nhóm đã duyệt → báo số bảng flat
           → DỪNG chờ human xác nhận
           → sinh 2 file SQL → DỪNG chờ human duyệt
```

> **GATE RULE — BẮT BUỘC TUYỆT ĐỐI:**
> - Claude **KHÔNG ĐƯỢC** tự bỏ qua bất kỳ GATE nào, dù kết quả có vẻ hiển nhiên hay không có vấn đề gì.
> - Tại mỗi GATE: **DỪNG hoàn toàn**, đặt câu hỏi xác nhận rõ ràng, **chờ human trả lời** trước khi tiếp tục.
> - Human chưa trả lời = chưa được phép tiếp tục. Không được suy diễn "im lặng = đồng ý".
> - Không được gộp nhiều GATE vào 1 câu hỏi — mỗi GATE là 1 điểm dừng độc lập.

---

## Chi tiết từng Phase

**Phase 0 — Plan** → `reference/phase0_plan.md`. Lấy danh sách Nhóm bằng `lld_selfcheck.py --module {MODULE} --tc 5` (không Read cả HLD). Plan phải đủ mọi Nhóm, kể cả Nhóm PENDING toàn bộ. Chốt một token physical chuẩn cho mỗi entity xuất hiện trong tên ≥ 2 bảng (Bước P2b). Dừng chờ human duyệt Plan.

**Phase 1 — Attributes** → `reference/phase1_workflow.md`. BA đọc qua `ba_slice.py --module {MODULE} --nhom {N} --print`, loại chỉ tiêu `Delete`. Với mỗi bảng: đọc `reuse_status` (bảng `partial` thuộc module khác thì sửa thẳng file gốc của module sở hữu, không tạo `_delta.csv`), xác định Driving Table và giới hạn ngày (A19), thêm `src_stm_code` có `WHERE` cho Dimension/Operational, tra YAML Atomic, xuất 15 cột UTF-8 BOM. Đặt tên theo `reference/physical_naming.md`. Trước khi trình bày từng file: chạy đủ 12 TC trong `reference/phase1_selfreview.md`. Sửa `etl_logic` / `description` của file Attributes đã tồn tại: sửa file per-module (nguồn sự thật), rồi sinh lại master bằng `build_registry.py --check` → ghi thật và chạy TC7 Sub-check E — không chép chuỗi vào master bằng tay.

**Phase 2 — Detail Mapping** → `reference/phase2_workflow.md`. Bước 0 lập todo list toàn module, độc lập với Plan Phase 0. Mỗi Nhóm: chạy `ba_hld_sync_check.py --module {MODULE} --nhom {N}`, đọc BA kèm SQL (`ba_slice.py --with-sql`), không map chỉ tiêu `Delete`, không tự sinh KPI_ID mới. Ghi bằng `apply_patch.py --target dm` (cả Nhóm) hoặc `apply_kpi_patch.py` (1 KPI vào Nhóm đã có), luôn `--dry-run` trước. SELF-REVIEW 5 TC mỗi Nhóm; hết module thì TC5 + TC6 bằng `lld_selfcheck.py --tc 5,6`.

**Phase 3 — Flat table** → `reference/phase3_workflow.md`. Báo số bảng flat và chờ xác nhận trước khi sinh. Thêm cột vào bảng đã có dùng `build_flat_tables.py --sync-columns` (A20). Hậu kiểm Column Coverage, 1-1 Projection Alignment, Orphan Check 3 chiều.
