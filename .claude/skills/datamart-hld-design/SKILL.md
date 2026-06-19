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

Đọc file này TRƯỚC KHI bắt đầu thiết kế HLD cho bất kỳ module nào.

## Tài nguyên đi kèm

- **Reference:**
  - [`reference/section_structure.md`](reference/section_structure.md) — 4 section cố định, format block READY/PENDING (Phase 1)
  - [`reference/flowchart_rules.md`](reference/flowchart_rules.md) — subgraph syntax, Calendar Date, node ID (Phase 1)
  - [`reference/erdiagram_rules.md`](reference/erdiagram_rules.md) — types hợp lệ, PK/FK only, naming (Phase 1)
  - [`reference/naming_conventions.md`](reference/naming_conventions.md) — tên bảng Fact/Dim/Operational, KPI ID (Phase 1)
  - [`reference/source_alias_mapping.md`](reference/source_alias_mapping.md) — bảng alias tên nguồn BA → Atomic (tra TRƯỚC KHI kết luận PENDING) (Phase 1)
  - [`reference/phase2_entities.md`](reference/phase2_entities.md) — Entities.csv + Entities.md format (Phase 2)
- **Examples:**
  - [`examples/erdiagram_correct.md`](examples/erdiagram_correct.md) — erDiagram đúng
  - [`examples/erdiagram_wrong.md`](examples/erdiagram_wrong.md) — 5 pattern sai erDiagram
  - [`examples/flowchart_correct.md`](examples/flowchart_correct.md) — flowchart đúng
  - [`examples/flowchart_wrong.md`](examples/flowchart_wrong.md) — pattern sai flowchart

## Điều kiện tiên quyết

- [ ] `BRD/BA/BA_analyst_{MODULE}.csv` tồn tại
- [ ] Screenshot báo cáo đã được upload
- [ ] `DataModel/Atomic/dm_manifest.yaml` tồn tại — entry point tra cứu Atomic entities đã approved
- [ ] `DataModel/datamart_model.yaml` tồn tại — registry schema cross-module (có thể rỗng `entities: []` nếu module đầu tiên)

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

## BƯỚC 1 — ĐỌC INPUT (thứ tự bắt buộc)

1. **BA file** (`BRD/BA/BA_analyst_{MODULE}.csv`) — extract toàn bộ dòng có `Trạng thái mapping ∈ {Done, Doing, Pending}`:

   > ⚠️ **Đọc CSV đúng cách:** File BA chứa cell multi-line (SQL, mô tả dài) — mỗi newline trong cell tạo thêm dòng vật lý. Đọc raw lines sẽ cho số dòng sai (VD: 452 chỉ tiêu nhưng 7358 dòng vật lý). **Bắt buộc dùng `csv.reader` với `delimiter=';'`** để parse đúng quoted multiline cells. STT trong file là số thứ tự nhóm/tab — mỗi STT = 1 nhóm duy nhất.
   >
   > ```python
   > import csv, io
   > with open('BA_analyst_{MODULE}.csv', encoding='utf-8-sig') as f:
   >     content = f.read()
   > reader = csv.reader(io.StringIO(content), delimiter=';')
   > rows = list(reader)
   > ```
   - `Phân loại = Chiều` → slicer/filter dimension — **phải có KPI_ID**, không được bỏ qua
   - `Phân loại = Cơ sở` + `Phái sinh` → KPI chỉ tiêu
   - Ghi nhận `Trạng thái mapping` — phân biệt Done/Doing/Pending
   - ❌ Không bỏ qua dòng `Phân loại = Chiều` — đây là phần của bảng KPI, không chỉ là gợi ý thiết kế

2. **Screenshot** — xác định scope boundary (tab, nhóm, loại thông tin hiển thị)

3. **dm_manifest.yaml** (`DataModel/Atomic/dm_manifest.yaml`) — xác định Atomic entity nào READY / PENDING
   - Entry tồn tại trong manifest với `status: approved` → READY
   - Không có entry tương ứng → PENDING
   - Nếu tên nguồn trong BA không tìm thấy → tra [`reference/source_alias_mapping.md`](reference/source_alias_mapping.md) trước khi kết luận PENDING
   - Mỗi `physical_name` có thể có nhiều entry (nhiều source table) — tra tất cả entry cùng `physical_name`, không dừng ở entry đầu tiên

4. **Entity YAML files** (`DataModel/Atomic/{BCV_Folder}/dm_atm_{physical_name}-{SOURCE}.{TABLE}.yaml`) — xác nhận tên entity/attribute khi cần (không đoán). Đọc `ldm.physical_name` = `atomic_table`, `attribute.physical_name` = `atomic_column`.

5. **HLD hiện tại** (nếu có) — append thêm, không viết lại

## BƯỚC 1B — SELF-REVIEW ATOMIC ATTRIBUTE NAMES (thực hiện TRƯỚC khi viết bảng KPI)

- [ ] Mọi tên attribute dùng trong cột Nguồn/KPI → tra file YAML entity đó, lấy đúng `attribute.name` (field `name:` trong YAML, không phải `physical_name`). KHÔNG tự suy tên từ nghĩa nghiệp vụ.
- [ ] Attribute không tìm thấy trong driving entity → kiểm tra entity liên quan (joined/shared entity), không kết luận PENDING trước khi tra entity phụ. Ví dụ: số định danh CCCD/Hộ chiếu nằm ở `Involved Party Alternative Identification`, không phải `Securities Practitioner`.
- [ ] Attribute dạng ngày tháng có 2 trường tách biệt (VD: `Birth Date` + `Birth Year`) → ghi rõ cả 2 và công thức `COALESCE` trong ETL formula của KPI Derived. KHÔNG chỉ ghi 1 trường.

---

## BƯỚC 2 — SCOPE GATING

| KPI | Hành xử |
|---|---|
| Atomic READY + `Trang thai mapping = Done/Doing` | In-scope — thiết kế đầy đủ (READY) |
| Atomic READY + `Trang thai mapping = Pending` | PENDING — Atomic có nhưng Mart chưa sẵn sàng |
| Atomic READY + `Trang thai mapping = blank` | PENDING — xử lý như Pending |
| Atomic PENDING | PENDING — placeholder + lý do + Atomic cần bổ sung |
| Không tìm được Atomic | Out-of-scope — ghi nhận, KHÔNG thiết kế |

> **Rule quan trọng (từ thực tế thiết kế PTTT):** `Trang thai mapping = blank` **KHÔNG phải Out-of-scope** — xử lý như **Pending**. Out-of-scope chỉ áp dụng khi không tìm được Atomic entity phù hợp.

> **Pattern "Fact thiếu FK":** Atomic entity nguồn đã READY nhưng Fact hiện tại thiếu FK đến một chiều cần bổ sung (VD: `Member Report Indicator Value` đã có nhưng cần thêm `Securities Company Dimension` để breakdown per-CTCK) → vẫn là **PENDING**, lý do ghi là "Fact cần bổ sung FK đến [Dimension]", Atomic cần bổ sung ghi tên Fact + chiều cần thêm.

❌ Không reuse fact/dim từ module khác để lấp KPI thiếu Atomic.

## BƯỚC 3 — CHECK REUSE (DATAMART MODEL)

**Mục tiêu:** Xác định bảng nào đã tồn tại trong `datamart_model.yaml` trước khi đặt tên bảng đích — tránh thiết kế trùng lặp, tái sử dụng cấu trúc khi có thể.

**Thực hiện:** Sau khi xác định sơ bộ tên/mục đích các bảng đích từ BA, đọc `DataModel/datamart_model.yaml`.

### Quy trình xác định reuse

**Bước 1 — Xác định Atomic source** từ BA analyst (cột Nguồn):
- Đọc cột Nguồn tại từng nhóm thông tin → tra `dm_manifest.yaml` lấy `physical_name` (= `atomic_table` vật lý)
- Nếu BA ghi tên nguồn chung (VD: "NHNCK") → đọc tất cả entry trong manifest có `source` khớp, lấy tất cả `physical_name` liên quan

**Bước 2 — Tìm trong `datamart_model.yaml`** theo `source_atomic`:
- Duyệt qua `entities` → tìm entry có `source_atomic` chứa `physical_name` đang xét
- Không tìm thấy → `new`, dừng

**Bước 3 — Nếu tìm thấy** (cùng nguồn Atomic đã được dùng):
- Lấy `datamart_table` + `table_type` + số cột hiện có (`columns` list) từ model
- Nếu `table_type` khác → `new` (khác mục đích)
- Nếu `table_type` giống → **báo cáo human**, hỏi phương án:

```
Phát hiện khả năng reuse:
  Nguồn Atomic: [atomic_table]
  Bảng đã có trong datamart_model.yaml: [datamart_table] (table_type: dim/operational, N cột hiện có)
  Bảng đang thiết kế: [tên mới đề xuất]

Đề xuất:
  (a) reuse — tái sử dụng toàn bộ [datamart_table] hiện có (không thêm cột)
  (b) partial — thêm nguồn mới vào [datamart_table] hiện có (có thể thêm cột)
  (c) new — tạo bảng mới (grain/mục đích thực sự khác)

→ Human chọn phương án
```

**Bước 4 — Tổng hợp và hỏi human (GATE — bắt buộc dừng)**

Sau khi hoàn tất phân tích tất cả bảng, trình bày bảng tóm tắt:

```
Kết quả phân tích reuse:

| Datamart Entity | datamart_table | reuse_status đề xuất | Lý do |
|---|---|---|---|
| Calendar Date Dimension | cdr_dt_dim | reuse | Đã có trong master |
| Branch Dimension | dim_branch | partial | Master có nguồn FLEX, module này thêm NHNCK |
| Fact ATM Transaction | fct_atm_txn | new | Chưa có trong master |

→ Xác nhận reuse_status từng bảng để tiến hành thiết kế?
```

> ❌ **KHÔNG được tự tiếp tục thiết kế** khi chưa có xác nhận của human — dù toàn bộ bảng đều là `new`.

**Bước 5 — Ghi kết quả vào Section 4 HLD.md** (xem format bên dưới)

> **Lưu ý:** `datamart_model.yaml` rỗng (`entities: []`, module đầu tiên) → toàn bộ bảng là `new`, vẫn phải trình bày bảng tóm tắt và chờ human xác nhận.

> **Bảng có khả năng reuse cao nhất:** `dim` và `operational` dùng chung (Calendar Date, Branch, thông tin 360°...). `fact` thường `new` vì grain gắn chặt với module.

### Section 4 — Reuse Analysis trong HLD.md

Thêm section này vào cuối file HLD, sau Section 3:

```markdown
## Section 4 — Reuse Analysis

| Datamart Entity | datamart_table | reuse_status | Ghi chú |
|---|---|---|---|
| Calendar Date Dimension | cdr_dt_dim | reuse | Đã có trong master — không thêm nguồn mới |
| Branch Dimension | dim_branch | partial | Đã có nguồn FLEX. Module này thêm nguồn NHNCK |
| Fact ATM Transaction | fct_atm_txn | new | Chưa có trong master |
```

> Section 4 là nguồn sự thật cho Phase 2 — Entities: cột `reuse_status` trong Entities.csv đọc trực tiếp từ đây.

---

## BƯỚC 4 — PHÂN LOẠI BẢNG DATAMART

| Loại | Khi nào | Pattern |
|---|---|---|
| **Phân tích** | KPI aggregate nhiều đối tượng / nhiều kỳ | Star Schema — Fact + Dim |
| **Tác nghiệp** | Lookup 1 đối tượng cụ thể | Denormalized Table — 1 row per đối tượng |

## BƯỚC 5 — THIẾT KẾ VÀ XUẤT FILE

Đọc [`reference/section_structure.md`](reference/section_structure.md) để biết format 4 section.
Đọc [`reference/flowchart_rules.md`](reference/flowchart_rules.md) trước khi vẽ Lineage.
Đọc [`reference/erdiagram_rules.md`](reference/erdiagram_rules.md) trước khi vẽ Star Schema.
Đọc [`reference/naming_conventions.md`](reference/naming_conventions.md) trước khi đặt tên bảng/KPI.

**Output:** `Datamart/hld/DTM_{MODULE}_HLD.md`

Tạo thư mục nếu chưa có. Thông báo đường dẫn file.

> **GATE — bắt buộc dừng:** Sau khi xuất file, đặt câu hỏi: "HLD.md đã được tạo tại [đường dẫn]. Bạn xác nhận để chuyển sang Phase 2?"
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
1. Xác định tên Dimension entity (node nguồn) và Fact entity (node đích)
2. Tên FK attribute = `{Dim Entity Name} Id` — ví dụ: `Calendar Date Dimension` → FK = `Calendar Date Dimension Id`
3. Format cột `FKs`: `{Dim Entity Name}.{FK Attribute Name}`, nhiều FK nối bằng ` | `

> `FKs` chỉ điền cho bảng `fact` — để trống cho `dim` và `operational`.

### Output Phase 2

- `Datamart/hld/DTM_{MODULE}_Entities.csv`
- `Datamart/hld/DTM_{MODULE}_Entities.md`

> **GATE — bắt buộc dừng:** Sau khi xuất 2 file, đặt câu hỏi: "Entities.csv và Entities.md đã được tạo tại [đường dẫn]. Bạn xác nhận để chuyển sang skill `datamart-lld-design`?"
> ❌ **KHÔNG được tự chuyển sang LLD** khi chưa có xác nhận của human.

---

## CHECKLIST TRƯỚC KHI BÀN GIAO

### Section 1 — Data Lineage
- [ ] Mỗi Cụm tổ chức theo 1 Fact (hoặc 1 nhóm Tác nghiệp)
- [ ] Mỗi flowchart có đủ 3 subgraph: `SRC["Staging"]` / `SIL["Atomic"]` / `GOLD["Datamart"]`
- [ ] Staging: 1 subgraph duy nhất, prefix table name thể hiện nguồn (VD: `FMS.RPTVALUES`)
- [ ] Mọi Cụm có Fact: `ECAT.ECAT_29_HolidayInfo` trong Staging + `Calendar Date` trong Atomic + `Calendar Date Dimension` trong Datamart
- [ ] Node Staging dùng `ID["label"]` — ID không có dấu chấm
- [ ] Node Atomic dùng `ID["label"]` — ID dùng `_`, label bỏ `_`
- [ ] Node Datamart dùng `ID["label"]` — ID = physical name, label = logical name
- [ ] Dim xuất hiện trong subgraph Datamart; link `Dim → Fact` (không phải `Fact → Dim`)
- [ ] Dimension seed từ Classification Value: chỉ vẽ node `Classification Value` trong Atomic
- [ ] **Mọi Dimension trong GOLD phải có Atomic entity nguồn trong SIL với edge đầy đủ** — duyệt từng node Dim trong subgraph GOLD, kiểm tra có ít nhất 1 Atomic entity trong SIL nối vào. Thiếu edge = thiếu nguồn → tự sửa trước khi xuất file. Ví dụ lỗi: `Securities Practitioner Dimension` xuất hiện trong GOLD nhưng không có node `Securities Practitioner` trong SIL + edge `Securities Practitioner → Securities Practitioner Dimension`.
- [ ] **Mọi Atomic entity dùng ETL join vào Fact phải có edge riêng vào Fact** — nếu Atomic entity A được dùng để enrich/join khi populate Fact (không chỉ qua Dim), phải có edge `A → Fact` trong flowchart. Ví dụ lỗi: `Securities Practitioner` dùng để join lấy CCHN của NHN có `Practice_Status_Code='3'` → cần edge `Securities Practitioner → fct_prac_license_ctf_snpst`, không chỉ `Securities Practitioner → scr_prac_dim`.

### Section 2 — Tổng quan báo cáo
- [ ] Hierarchy: `### Tab` → `#### Nhóm` → `##### PENDING/READY` (chỉ khi có cả 2) — quy tắc đặt tên:
  - **Tên Tab** (`### Tab`): lấy phần TRƯỚC dấu `/` trong cột **Dashboard/báo cáo** của BA (VD: `Dashboard Giám sát rủi ro`)
  - **Tên Nhóm** (`#### Nhóm`): lấy phần SAU dấu `/`, kèm **số STT từ BA** — format: `#### Nhóm {STT} - {tên sau dấu /}`. Số nhóm = STT trong BA, KHÔNG tự đánh số lại
  - Ví dụ đúng: BA ghi `Dashboard Giám sát rủi ro/ Chỉ số rủi ro hệ thống`, STT=1 → Tab: `### Tab Dashboard Giám sát rủi ro`, Nhóm: `#### Nhóm 1 - Chỉ số rủi ro hệ thống`
  - Ví dụ đúng: BA ghi `Dashboard Giám sát rủi ro/ Phân tích đóng góp rủi ro`, STT=2 → Nhóm: `#### Nhóm 2 - Phân tích đóng góp rủi ro`
  - Sai: `#### Nhóm Thanh khoản thị trường` (thiếu số STT); sai: `#### Nhóm 1` (thiếu tên)
- [ ] Block READY có đủ: Phân loại / Atomic / Mockup / Source / Bảng KPI / Star Schema / Lineage Mart → Báo cáo / Bảng grain
- [ ] **Bảng KPI READY chỉ có 1 bảng duy nhất** — KHÔNG tách thành `*KPI mới:*` và `*KPI reuse:*` thành 2 bảng riêng. Reuse được liệt kê cùng bảng với KPI mới; thêm cột "Ghi chú" để đánh dấu nguồn gốc reuse
- [ ] **Lineage Mart → Báo cáo chỉ vẽ từ Datamart lên báo cáo** — KHÔNG vẽ Atomic entities trong flowchart này. Node bắt đầu phải là bảng Fact/Dim/Operational (physical name trong GOLD layer), không phải Atomic entity
- [ ] Block PENDING có đủ: KPI liên quan / Lý do / Atomic cần bổ sung / Mart dự kiến (chỉ tên + grain) / Bảng mapping nguồn (Atomic Placeholder)
- [ ] Bảng mapping nguồn: mỗi dòng = 1 Atomic entity, điền đủ Bảng nguồn BA + Atomic entity dự kiến + Atomic table dự kiến (TBD nếu chưa rõ)
- [ ] Bảng KPI PENDING: chỉ 4 cột (KPI ID / Tên KPI / Tính chất / Trạng thái) — không có Đơn vị, Công thức
- [ ] **KPI reuse trong PENDING thêm vào bảng 4 cột bình thường** — KHÔNG tách bảng reuse riêng. Cột Tên KPI ghi thêm "(reuse từ Nhóm M)" để phân biệt. "KPI liên quan" header phải bao gồm cả ID reuse này
- [ ] **KPI Done (sub-component) đã khai sinh ở Nhóm trước → reuse vào bảng KPI READY** — KHÔNG để trong PENDING header. Sub-component Done = thuộc READY, sub-component Pending = thuộc PENDING
- [ ] Bảng PENDING không có Star Schema, erDiagram, Lineage flowchart
- [ ] Block PENDING không tạo Open Issue (Section 4) về grain/schema/logic — chỉ ghi nhận Atomic cần bổ sung
- [ ] **Tên attribute trong cột Nguồn phải là logical name chính xác từ YAML** — đọc `attribute.name` trong file YAML của entity đó. KHÔNG tự đặt tên theo cảm tính. Ví dụ sai: `Date Of Birth` khi YAML ghi `Birth Date`.
- [ ] **KPI có nguồn từ entity phụ (join/shared entity)** → ghi rõ tên entity phụ + điều kiện join trong cột Nguồn. KHÔNG ghi nhầm vào entity chính. Ví dụ đúng: "`Involved Party Alternative Identification`.Identification Number — join qua ip_id, filter Identification Type Code = CCCD/PASSPORT".
- [ ] KPI ID đã được khai sinh trong Section 2 trước khi xuất hiện ở file khác
- [ ] Mọi dòng BA `Phân loại = "Chiều"` phải có KPI_ID trong bảng KPI của nhóm tương ứng — không được bỏ qua
- [ ] Chiều dùng như ETL filter nội bộ (không hiển thị UI) → ghi rõ trong cột Ghi chú: "dùng trong formula KPI K_X_N" — vẫn phải có KPI_ID
- [ ] Cấm dùng shorthand "xem Nhóm N" thay thế bảng KPI — nếu nhóm reuse KPI từ nhóm khác, liệt kê explicit từng KPI_ID kèm ghi chú nguồn gốc: "Reuse từ Nhóm N"
- [ ] Đọc toàn bộ BA file trước khi viết bảng KPI — đảm bảo không sót dòng nào có `Trạng thái mapping ∈ {Done, Doing, Pending}`
- [ ] **Mọi dòng Done không note "Trùng" → bắt buộc có KPI_ID trong nhóm:** Nếu concept đã khai ở nhóm khác → reuse explicit trong bảng KPI nhóm này, không được im lặng bỏ qua
- [ ] **Dòng Done là sub-component của KPI phức tạp → vẫn cấp KPI_ID riêng:** Không gộp im lặng sub-component vào KPI cha. Ngoại lệ duy nhất: cột Đánh giá ghi "Trùng" → reuse ID đã có
- [ ] **Cấm thêm KPI không có dòng BA tương ứng:** Bảng KPI READY chỉ chứa KPI có dòng BA trong nhóm đó (mới hoặc reuse). Không thêm KPI từ suy luận nghiệp vụ dù hợp lý
- [ ] **Dedup KPI giữa các Nhóm trong cùng Tab:** Trước khi cấp ID mới cho Nhóm N, kiểm tra toàn bộ KPI đã khai sinh ở Nhóm 1→(N-1). Nếu trùng nội dung → reuse ID cũ, KHÔNG cấp ID mới. Liệt kê reuse **trong cùng bảng KPI 6 cột duy nhất** — điền cột Ghi chú = "Reuse từ Nhóm X". KHÔNG tạo bảng reuse riêng.
- [ ] **Đồng bộ "KPI liên quan" trong PENDING header:** Sau khi hoàn thiện bảng KPI PENDING, kiểm tra lại dòng `**KPI liên quan:**` — phải khớp chính xác với tất cả ID xuất hiện trong bảng (cả mới lẫn reuse). Nếu bảng KPI thay đổi → cập nhật dòng này ngay

### Section 3 — Mô hình tổng thể
- [ ] Không bao gồm PENDING
- [ ] Bảng Phân tích: chỉ liệt kê Fact (không liệt kê Dimension)
- [ ] Bảng Dimension: chỉ liệt kê Dimension, có ghi chú "Tất cả Dimension áp dụng SCD Type 4A"
- [ ] Cột Conformed điền đúng (Có/Không)

### Section 4 — Reuse Analysis
- [ ] Có bảng với 4 cột: Datamart Entity / datamart_table / reuse_status / Ghi chú
- [ ] Mỗi bảng đích trong Section 3 đều có 1 dòng trong Section 4
- [ ] `reuse_status` đã được human xác nhận (không tự gán nếu có khả năng reuse)
- [ ] Ghi chú ghi rõ lý do reuse/partial (module cũ, nguồn đã có...)

### erDiagram
- [ ] Mở bằng ` ```mermaid ` — KHÔNG phải ` ```erDiagram `
- [ ] Types chỉ dùng: `int` / `float` / `string` / `varchar` / `boolean` / `date` / `datetime`
- [ ] Chỉ dùng label `PK` và `FK` — không có NK/BK/DD
- [ ] `FK` chỉ xuất hiện trong Fact entity block và phải có `||--o{` tương ứng
- [ ] Tên entity dùng underscore (không dấu cách)
- [ ] Tên cột dùng Title_Case_With_Underscore
- [ ] Không thiết kế `Effective Date` / `Expiry Date` / `Population Date` / `Snapshot Date`
- [ ] Toàn file HLD: mỗi bảng có số trường và tên trường giống hệt nhau ở mọi erDiagram

### Quy ước chung
- [ ] Chỉ dùng tên logical — không có physical name (snake_case) ở bất kỳ vị trí nào
- [ ] Node label trong flowchart và graph TB không dùng `\n`
- [ ] Nội dung nghiệp vụ bằng tiếng Việt có dấu; tên bảng/cột/entity giữ tiếng Anh

### Phase 2 — Entities Files

```
□ Đọc Section 3 HLD — không đọc Section 2 hay erDiagram từng nhóm
□ Đọc Section 4 HLD — lấy reuse_status cho từng bảng
□ Danh sách entity đầy đủ: tất cả fact + dim + operational trong Section 3
□ table_type khớp với phân loại trong Section 3 (fact/dim/operational)
□ reuse_status lấy từ Section 4 — bắt buộc có cho mọi row
□ description + Grain lấy từ cột Grain/Mô tả của Section 3 — không tự suy luận
□ source_table tra từ dm_manifest.yaml (physical_name) — không đoán
□ FKs: chỉ điền cho fact, trống cho dim/operational
□ FKs: trích từ graph TB Section 3, format "{Dim Entity}.{Dim Entity Id}"
□ status = draft toàn bộ rows
□ Thứ tự: Dimension → Fact → Operational
□ Export UTF-8 BOM (utf-8-sig)
□ Entities.md: erDiagram chỉ vẽ relationship lines — không vẽ attribute block
□ Entities.md: bảng entity tóm tắt có cột Datamart Entity / Loại / Reuse / Mô tả / Grain / KPI
```
