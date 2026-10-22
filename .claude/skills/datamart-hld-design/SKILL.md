---
name: datamart-hld-design
description: |
  Thiết kế High-Level Design (HLD) cho Datamart layer — Phase 1 và Phase 2 trong workflow thiết kế Datamart UBCKNN.
  Sử dụng khi: bắt đầu thiết kế mới hoặc cập nhật HLD cho một module Datamart
  (TT/NHNCK/NDTNN/QLCB/FMS/GSTT/GSDC/QLKD/...).

  Output:
    Datamart/hld/DTM_{MODULE}_HLD.md                  (Phase 1)
    Datamart/hld/DTM_{MODULE}_Entities.csv             (Phase 2)
    Datamart/hld/DTM_{MODULE}_Entities.md              (Phase 2)
  Input bắt buộc: BA_analyst_{MODULE}.csv + Screenshot báo cáo + DataModel/Atomic/dm_manifest.yaml
---

# Skill: Thiết kế HLD Datamart

File này giữ quy trình, điều kiện tiên quyết, quy tắc ngữ cảnh, bảng tóm tắt luật H1–H14, Bước 5B và Phase 2. Chi tiết Bước 1–4, diễn giải 14 mục của Bước 5B và checklist bàn giao nằm trong `reference/` — đọc file của bước đang làm.

## Tài nguyên đi kèm

- **Reference:**
  - [`reference/section_structure.md`](reference/section_structure.md) — 5 Section cố định, bảng KPI 7 cột chuẩn (Cây 5 nhóm PENDING & Open Issue), Presentation Grain vs Storage Grain, Reuse Case 1/2, All-Tier Deprecation (Phase 1)
  - [`reference/flowchart_rules.md`](reference/flowchart_rules.md) — subgraph syntax (SRC/SIL/GOLD), Calendar Date, node ID không dấu chấm, mỗi Cụm 1 bảng Datamart (Phase 1)
  - [`reference/erdiagram_rules.md`](reference/erdiagram_rules.md) — types hợp lệ (decimal trần), Role-Playing Date FK (`Snapshot_Date_Dimension_Id FK`, `<Role>_Date_Dimension_Id FK`), cấm Calendar_Date FK trên Fact, Degenerate Date, Fact Periodic Snapshot cho chuỗi thời gian lookback, cấm Window Function trên Dimension SCD4A (Phase 1)
  - [`reference/naming_conventions.md`](reference/naming_conventions.md) — tên bảng Fact/Dim/Operational, Thang 6 bậc phân cấp hạt (chống Grain Mismatch K_GSTT_61), quy đổi phiên giao dịch lookback (260/130/65/20), tính nhất quán chu kỳ tỷ số tài chính (Phase 1)
  - [`reference/source_alias_mapping.md`](reference/source_alias_mapping.md) — bảng alias tên nguồn BA → Atomic (tra TRƯỚC KHI kết luận PENDING) (Phase 1)
  - [`reference/phase2_entities.md`](reference/phase2_entities.md) — Entities.csv + Entities.md format, trạng thái DEPRECATED, đồng bộ Reuse Case 1/2, trích xuất Role-Playing Date FKs (Phase 2)

- **Examples:**
  - [`examples/erdiagram_correct.md`](examples/erdiagram_correct.md) — erDiagram đúng
  - [`examples/erdiagram_wrong.md`](examples/erdiagram_wrong.md) — 5 pattern sai erDiagram
  - [`examples/flowchart_correct.md`](examples/flowchart_correct.md) — flowchart đúng
  - [`examples/flowchart_wrong.md`](examples/flowchart_wrong.md) — pattern sai flowchart

**Chi tiết từng bước (tách từ file này):**

| Khi | Đọc |
|---|---|
| Mọi lần sửa HLD | [`reference/rules.md`](reference/rules.md) — đúng mục của luật liên quan (H1–H14, kèm sự cố gốc) |
| Bước 1 — đọc BA, tra Atomic, Bước 1B | [`reference/step1_input.md`](reference/step1_input.md) |
| Bước 2 — scope gating, 5 nhóm PENDING, liên kết Section 5 | [`reference/step2_scope_gating.md`](reference/step2_scope_gating.md) |
| Bước 3 — reuse 4 lớp, Section 4, bãi bỏ bảng 5 tầng | [`reference/step3_reuse.md`](reference/step3_reuse.md) |
| Bước 4 — loại bảng, iso-grain, chuỗi thời gian, tỷ số tài chính | [`reference/step4_grain.md`](reference/step4_grain.md) |
| Bước 5B — diễn giải 14 mục, lệnh CLI lẻ, bảng exit code | [`reference/step5b_review.md`](reference/step5b_review.md) |
| Trước khi bàn giao | [`reference/handoff_checklist.md`](reference/handoff_checklist.md) |

## Điều kiện tiên quyết

- [ ] `BRD/BA/BA_analyst_{MODULE}.csv` tồn tại
- [ ] Screenshot báo cáo đã được upload
- [ ] `DataModel/Atomic/dm_manifest.yaml` tồn tại — entry point tra cứu Atomic entities (Nguồn 1, ưu tiên cao nhất)
- [ ] `DataModel/working/Atomic/lld/manifest.yaml` tồn tại — entry point tra cứu Atomic entities draft (Nguồn 2, chỉ tra khi Nguồn 1 không có)
- [ ] `Datamart/datamart_model.yaml` tồn tại — registry schema cross-module (có thể rỗng `entities: []` nếu module đầu tiên)

> **❌ TUYỆT ĐỐI CẤM SỬA ATOMIC TỪ SKILL THIẾT KẾ DATAMART:**
> Skill thiết kế Datamart (`datamart-hld-design`, `datamart-lld-design`, `datamart-review`) chỉ có quyền **READ-ONLY** đối với thư mục `DataModel/Atomic/` và `DataModel/working/Atomic/`.
> - Tuyệt đối **KHÔNG ĐƯỢC** tạo file mới, sửa đổi thuộc tính, thêm cột kỹ thuật, hoặc can thiệp vào bất kỳ file YAML nào trong `DataModel/`.
> - Nếu Atomic thiếu bảng, thiếu cột, hoặc thiếu audit field cần thiết cho Datamart:
>   - Đánh dấu KPI liên quan là **PENDING** (ghi rõ lý do: "Thiếu nguồn Atomic / Chưa có trong Atomic schema").
>   - Ghi nhận vào Section 5 Open Issues (`DTM_{MODULE}_HLD.md`).
>   - DỪNG lại báo cáo human để Data Modeler thuộc luồng Atomic xử lý độc lập. Tuyệt đối không tự ý sửa Atomic!
>
> **Cấm dùng `DataModel/working/Atomic_LinhLV/`** — track cũ đã revert, out of date. Xem chi tiết thứ tự ưu tiên 2 nguồn ở `reference/step1_input.md` mục 3.

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

## Luật H1–H14 (tóm tắt)

Mỗi luật rút từ một lỗi thật. Bảng dưới chỉ để biết luật nào liên quan; trước khi áp dụng, đọc mục tương ứng trong [`reference/rules.md`](reference/rules.md) (`grep -n "^### H7" .claude/skills/datamart-hld-design/reference/rules.md`). Cột "Máy kiểm" ghi Gate/script bắt được lỗi; "—" nghĩa là chưa có script, phải tự kiểm theo hướng dẫn trong `rules.md`.

| Luật | Nội dung | Máy kiểm |
|---|---|---|
| H1 | Một HLD là một nguồn sự thật: thay/bãi bỏ bảng phải sửa đủ 6 nơi (Section 1 flowchart, 3.1, bảng 3.2–3.4, Section 4, Section 5, Entities.csv/.md) | Gate 5 #0 (Section 3 ↔ Section 4) — một phần |
| H2 | Đóng Open Issue mặc định "Resolved một phần"; KPI chưa đạt mở issue mới | — |
| H3 | Reuse Fact xuyên module: chép nguyên văn grain của module chủ; grain kỳ báo cáo không phục vụ rolling theo phiên; "Nguồn Atomic" ghi entity Atomic, không ghi `fct_*` | — (`L1-GRAIN-MISMATCH`) |
| H4 | Trạng thái KPI đồng bộ 2 chiều HLD ↔ Detail Mapping; Nhóm hết PENDING phải bổ sung Source / Star Schema / Lineage / Bảng grain | Gate 0 `L0-HLD-LLD-STATUS-DESYNC` |
| H5 | Mọi tên cột Atomic viết vào HLD phải grep được trong YAML | Gate 0 `L0-ATOMIC-COLUMN-NOT-FOUND` |
| H6 | BA tách/gộp/dồn số Nhóm: đánh số lại toàn bộ tham chiếu trong một lượt trước, thiết kế sau | `ba_hld_sync_check.py` S2/S3 (Gate 10 khi có `--nhom`) |
| H7 | Khóa JOIN giữa 2 nguồn khác hệ định danh phải có bằng chứng: SQL BA, tài liệu cột nguồn, hoặc Data Modeler xác nhận trong phiên | — (`L1-JOIN-KEY-UNVERIFIED`) |
| H8 | Loại measure Giá trị / Khối lượng phải khớp Trường nguồn BA | `ba_hld_sync_check.py` S5 `L3-MEASURE-TYPE-MISMATCH` |
| H9 | Đối soát nội dung từng dòng BA, không chỉ số lượng; xử lý từng cảnh báo S4 | `ba_hld_sync_check.py` S4 `L3-BA-ROW-UNMAPPED` |
| H10 | Dòng BA mâu thuẫn: Điều kiện chung / Mô tả ưu tiên hơn SQL có Note "cần check"; ghi Open Issue | `check_ba_mapping.py` (ngoài Gate) — một phần |
| H11 | Cột/công thức dùng chung nhiều Nhóm: đọc BA của mọi Nhóm tiêu thụ trước khi đổi; BA đổi quy tắc thì sửa đồng loạt | — (`L3-SHARED-RULE-DRIFT`) |
| H12 | Nhóm chuyển sang bảng mới: bảng cũ 0 KPI dùng → All-Tier Cleanup, giữ lịch sử ở Section 4 | Gate 8 `L2-TABLE-ZERO-USAGE` |
| H12b | Trước khi kết luận "thiếu", đọc `ghi_chu` Detail Mapping và Ghi chú HLD của đúng KPI | — (quy trình) |
| H13 | Dòng KPI đúng 7 ô; giải trình "dòng BA → K_xxx" phải tra lại KPI thật; khối erDiagram trùng tên chép nguyên văn | Gate 8 `L1-HLD-KPI-ROW-CELLS`, Gate 5 #11 |
| H14 | Chọn chỉ số trên `market_index_snapshot`: Data Modeler chốt 2026-10-21 — BA `IndexCode`/`indexname = 'VNINDEX'` là BA nhầm, giữ `market_code = 'HOSE'` (KHÔNG đổi sang `index_nm`); cột BA không có ở Atomic thì liệt kê đủ cột entity trước khi kết luận; quyết định của Nhóm này không tự áp sang Nhóm khác | — (quy trình) |

---

## QUY TRÌNH (BẮT BUỘC)

```
Phase 1:  Claude đọc input → check datamart_model.yaml → hỏi human phương án reuse
          → DỪNG chờ human xác nhận reuse_status từng bảng
          → thiết kế → xuất DTM_{MODULE}_HLD.md (gồm Section 4 Reuse Analysis)
          → DỪNG chờ human duyệt HLD.md

Phase 2:  Sau khi Phase 1 duyệt → đọc Section 3 + Section 4 HLD → xuất Entities.csv + Entities.md
          → DỪNG chờ human duyệt Entities.csv + Entities.md
```

> **GATE RULE — BẮT BUỘC TUYỆT ĐỐI:**
> - Claude **KHÔNG ĐƯỢC** tự bỏ qua bất kỳ GATE nào, dù không có khả năng reuse, dù kết quả có vẻ hiển nhiên.
> - Tại mỗi GATE: **DỪNG hoàn toàn**, đặt câu hỏi xác nhận rõ ràng, **chờ human trả lời** trước khi tiếp tục bất kỳ hành động nào.
> - Human chưa trả lời = chưa được phép tiếp tục. Không được suy diễn "im lặng = đồng ý".
> - Sau khi Phase 2 duyệt → chuyển sang skill `datamart-lld-design`.

---

## Bước 1–4 (tóm tắt)

**Bước 1 — Đọc input** → `reference/step1_input.md`. Đọc BA qua `ba_slice.py --module {MODULE} --index` rồi `--nhom {N} --print` (thêm `--with-sql` khi cần SQL tham khảo), không Read thẳng file BA. Chỉ lấy dòng `Trạng thái mapping ∈ {Done, Doing, Pending}`; dòng `Delete` loại hẳn khỏi thiết kế; dòng `Phân loại = Chiều` vẫn phải có KPI_ID. Tra Atomic theo thứ tự `DataModel/Atomic/dm_manifest.yaml` → `DataModel/working/Atomic/lld/manifest.yaml`, tra `reference/source_alias_mapping.md` trước khi kết luận; không có ở cả hai nguồn thì PENDING. Mọi entity nguồn phải grep được, kể cả khi Nhóm trước đã dùng. HLD đã có thì append, không viết lại. Bước 1B: tên attribute lấy đúng `attribute.name` trong YAML; đọc SQL tham khảo của từng dòng BA trong Nhóm; ghi chú reuse trích nguyên văn tên dòng BA; khi sửa Nhóm đã có, đếm lại từ BA hiện tại, không tin ghi chú cũ.

**Bước 2 — Scope gating** → `reference/step2_scope_gating.md`. Atomic READY + `Done`/`Doing` → READY; `Pending` hoặc ô trống → PENDING (ô trống không phải out-of-scope); không tìm được Atomic → out-of-scope. Mọi KPI PENDING phân vào đúng 1 trong 5 nhóm nguyên nhân và ghi chú theo cú pháp chuẩn (mục 2.3); blocker Nhóm 3/4/5 phải có Open Issue ở Section 5. Không reuse Fact/Dim của module khác để lấp KPI thiếu Atomic. Cột `Loại dữ liệu` của BA không dùng để quyết READY/PENDING.

**Bước 3 — Reuse** → `reference/step3_reuse.md`. Đọc `datamart_model.yaml` một lần; kiểm 4 lớp theo thứ tự và dừng ở lớp xác định được: conformed (`cdr_dt_dim`, `cl_dim`) → Classification Value (`cl_dim` khi `physical_name = cv`) → cùng nguồn Atomic → partial. Trình bày bảng `reuse_status` và dừng chờ human xác nhận, kể cả khi toàn bộ là `new`. Kết quả ghi Section 4 (gồm `DEPRECATED`); bãi bỏ bảng theo giao thức 5 tầng.

**Bước 4 — Loại bảng và grain** → `reference/step4_grain.md`. Phân tích → Star Schema (Fact + Dim); tác nghiệp → bảng denormalize 1 dòng/đối tượng. Presentation grain không được mịn hơn grain lưu trữ của Fact (thang 6 bậc Sàn → Chỉ số → Ngành → Mã CK → CTCK → Giao dịch); reuse lệch cấp hạt thì viết lại aggregate. Lookback dùng số phiên (260/130/65/20) bằng `ROWS BETWEEN` trên Fact Periodic Snapshot theo ngày, không trên Dimension SCD4A. Tử và mẫu của tỷ số tài chính cùng kỳ; không `SUM` biến số dư qua nhiều kỳ.

## BƯỚC 5 — THIẾT KẾ VÀ XUẤT FILE

Đọc [`reference/section_structure.md`](reference/section_structure.md) để biết format 5 section cố định.
Đọc [`reference/flowchart_rules.md`](reference/flowchart_rules.md) trước khi vẽ Lineage.
Đọc [`reference/erdiagram_rules.md`](reference/erdiagram_rules.md) trước khi vẽ Star Schema.
Đọc [`reference/naming_conventions.md`](reference/naming_conventions.md) trước khi đặt tên bảng/KPI.

**Output:** `Datamart/hld/DTM_{MODULE}_HLD.md`

Tạo thư mục nếu chưa có. Thông báo đường dẫn file.

## Bước 5B — Review cuối toàn file

Bắt buộc sau khi viết xong HLD, và cả khi chỉ sửa một Nhóm — mọi mục quét toàn file nên thay đổi cục bộ vẫn có thể làm lộ lỗi cũ. 14 mục #0–#13 đã tự động hóa: chạy script, không đánh giá bằng mắt, dán nguyên output.

```bash
python .claude/skills/datamart-review/scripts/run_quality_gates.py --module {MODULE} --strict
```

Runner gồm `check_hld_5b.py` (14 mục #0–#13, Gate 5) và Gate 0 → Gate 9. Thêm `--nhom N1 N2 …` để bật Gate 10 cho các Nhóm vừa sửa: chạy `ba_hld_sync_check.py --nhom` và in dòng delta của đúng các Nhóm đó từ `datamart_progress_analyzer.py`. Gate 10 chỉ cảnh báo — vẫn phải đọc và xử lý từng dòng 🔴 / 🟡 (S4: bổ sung KPI hoặc ghi giải trình). Lọc output bằng `grep "Nhóm {N} "`, không cắt bằng `tail`/`head`.

Diễn giải từng mục, các lệnh lẻ và bảng exit code: [`reference/step5b_review.md`](reference/step5b_review.md). Còn script trả exit ≠ 0 thì chưa mở GATE.

> **GATE — bắt buộc dừng:** Sau khi xuất file, hoàn tất Bước 5B và kiểm tra sạch bằng CLI audit (Exit Code 0), đặt câu hỏi: "HLD.md đã được tạo tại [đường dẫn], đã chạy review cuối Bước 5B và bộ công cụ audit đạt chuẩn 100%. Bạn xác nhận để chuyển sang Phase 2?"
> ❌ **KHÔNG được tự chuyển sang Phase 2** khi chưa có xác nhận của human.

---

## PHASE 2 — ENTITIES FILES

Đọc [`reference/phase2_entities.md`](reference/phase2_entities.md) đầy đủ trước khi bắt đầu.

### Điều kiện tiên quyết Phase 2

- [ ] `Datamart/hld/DTM_{MODULE}_HLD.md` đã được user duyệt (Phase 1 hoàn thành)
- [ ] `DataModel/Atomic/dm_manifest.yaml` tồn tại

### Nguồn sự thật: Section 3 + Section 4 HLD

**Thông tin cho Entities nằm trong Section 3 và Section 4 của `DTM_{MODULE}_HLD.md`** — không cần đọc Section 2 hay erDiagram từng nhóm.

| Cột Entities | Lấy từ đâu |
|---|---|
| `datamart_entity` | Section 3 — tên bảng trong bảng Phân tích / Tác nghiệp / Dimension |
| `table_type` | Section 3 — `fact` (Phân tích), `operational` (Tác nghiệp), `dim` (Dimension) |
| `reuse_status` | **Section 4** — cột `reuse_status` đã được human xác nhận |
| `status` | Luôn `draft` |
| `description` + Grain | Section 3 — cột Grain / Mô tả |
| `source_table` | Section 3 — cột "Nguồn Atomic chính" → tra `dm_manifest.yaml` lấy `physical_name` (`atomic_table`) |
| `FKs` | Section 3 — graph TB (`DIM_X --> FACT_Y`) |

### Rule trích xuất `FKs` từ graph TB

Graph TB trong Section 3 dùng mũi tên `DIM_X --> FACT_Y`. Với mỗi mũi tên:
1. Xác định tên Dimension entity (node nguồn) và Fact entity (node đích).
2. Tên FK attribute tuân thủ nghiêm ngặt chuẩn Dimension Key:
   - **Dimension thông thường:** Tên FK attribute = `{Dim Entity Name} Id` (ví dụ: `Fund Management Company Dimension` → FK = `Fund Management Company Dimension Id`).
   - **Calendar Date Dimension (BẮT BUỘC ROLE-PLAYING):** Tuyệt đối CẤM dùng `Calendar Date Dimension Id` trên Fact. FK trỏ tới `Calendar Date Dimension` bắt buộc phải mang tên vai trò nghiệp vụ (Role-Playing Date):
     - Fact Periodic Snapshot (`_Snapshot`): Bắt buộc là `Snapshot Date Dimension Id`.
     - Fact Event / Fact khác: Bắt buộc là `<Role> Date Dimension Id` (ví dụ: `Issue Date Dimension Id`, `Trade Date Dimension Id`, `Decision Date Dimension Id`, `Submission Date Dimension Id`, `Effective Date Dimension Id`...).
3. Format cột `FKs`: `{Dim Entity Name}.{FK Attribute Name}`, nhiều FK nối bằng ` | `.
   - Ví dụ Fact Snapshot: `Calendar Date Dimension.Snapshot Date Dimension Id | Fund Management Company Dimension.Fund Management Company Dimension Id`
   - Ví dụ Fact Event: `Calendar Date Dimension.Issue Date Dimension Id | Securities Practitioner Dimension.Securities Practitioner Dimension Id`

> `FKs` chỉ điền cho bảng `fact` — để trống cho `dim` và `operational`.

### Output Phase 2

- `Datamart/hld/DTM_{MODULE}_Entities.csv`
- `Datamart/hld/DTM_{MODULE}_Entities.md`

> **GATE — bắt buộc dừng:** Sau khi xuất 2 file, đặt câu hỏi: "Entities.csv và Entities.md đã được tạo tại [đường dẫn]. Bạn xác nhận để chuyển sang skill `datamart-lld-design`?"
> ❌ **KHÔNG được tự chuyển sang LLD** khi chưa có xác nhận của human.

---

## Trước khi bàn giao

Rà checklist trong [`reference/handoff_checklist.md`](reference/handoff_checklist.md): Section 1–5, erDiagram, quy ước chung, Phase 2 Entities.
