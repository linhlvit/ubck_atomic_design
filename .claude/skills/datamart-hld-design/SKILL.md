---
name: datamart-hld-design
description: |
  Thiết kế High-Level Design (HLD) cho Datamart layer — Phase 1 trong workflow thiết kế Datamart UBCKNN.
  Sử dụng khi: bắt đầu thiết kế mới hoặc cập nhật HLD cho một module Datamart
  (TT/NHNCK/NDTNN/QLCB/FMS/GSTT/GSDC/QLKD/...).

  Output: Datamart/hld/DTM_{MODULE}_HLD.md
  Input bắt buộc: BA_analyst_{MODULE}.csv + Source_Analysis.md + Screenshot báo cáo
---

# Skill: Thiết kế HLD Datamart

Đọc file này TRƯỚC KHI bắt đầu thiết kế HLD cho bất kỳ module nào.

## Tài nguyên đi kèm

- **Reference:**
  - [`reference/section_structure.md`](reference/section_structure.md) — 4 section cố định, format block READY/PENDING
  - [`reference/flowchart_rules.md`](reference/flowchart_rules.md) — subgraph syntax, Calendar Date, node ID
  - [`reference/erdiagram_rules.md`](reference/erdiagram_rules.md) — types hợp lệ, PK/FK only, naming
  - [`reference/naming_conventions.md`](reference/naming_conventions.md) — tên bảng Fact/Dim/Operational, KPI ID
  - [`reference/source_alias_mapping.md`](reference/source_alias_mapping.md) — bảng alias tên nguồn BA → Atomic (tra TRƯỚC KHI kết luận PENDING)
- **Examples:**
  - [`examples/erdiagram_correct.md`](examples/erdiagram_correct.md) — erDiagram đúng
  - [`examples/erdiagram_wrong.md`](examples/erdiagram_wrong.md) — 5 pattern sai erDiagram
  - [`examples/flowchart_correct.md`](examples/flowchart_correct.md) — flowchart đúng
  - [`examples/flowchart_wrong.md`](examples/flowchart_wrong.md) — pattern sai flowchart

## Điều kiện tiên quyết

- [ ] `BRD/BA/BA_analyst_{MODULE}.csv` tồn tại
- [ ] `BRD/source/working/{Module}_Source_Analysis.md` tồn tại
- [ ] Screenshot báo cáo đã được upload
- [ ] `Atomic/lld/atomic_attributes.csv` tồn tại (dùng xác nhận entity READY/PENDING)

---

## QUY TRÌNH (BẮT BUỘC)

```
Phase 1:  Claude đọc input → thiết kế → xuất DTM_{MODULE}_HLD.md
Phase 2+: Chờ user duyệt HLD trước khi chuyển sang datamart-lld-design
```

> **GATE RULE:** Không tự chuyển sang Phase 2 (LLD) khi user chưa xác nhận duyệt HLD.
> Kết thúc Phase 1 bằng câu hỏi xác nhận.

---

## BƯỚC 1 — ĐỌC INPUT (thứ tự bắt buộc)

1. **BA file** (`BRD/BA/BA_analyst_{MODULE}.csv`) — extract toàn bộ dòng có `Trạng thái mapping ∈ {Done, Doing, Pending}`:
   - `Phân loại = Chiều` → slicer/filter dimension — **phải có KPI_ID**, không được bỏ qua
   - `Phân loại = Cơ sở` + `Phái sinh` → KPI chỉ tiêu
   - Ghi nhận `Trạng thái mapping` — phân biệt Done/Doing/Pending
   - ❌ Không bỏ qua dòng `Phân loại = Chiều` — đây là phần của bảng KPI, không chỉ là gợi ý thiết kế

2. **Screenshot** — xác định scope boundary (tab, nhóm, loại thông tin hiển thị)

3. **Source Analysis MD** (`BRD/source/working/{Module}_Source_Analysis.md`) — xác định Atomic entity nào READY / PENDING
   - Nếu tên nguồn trong BA không tìm thấy trong `Atomic/lld/` → tra [`reference/source_alias_mapping.md`](reference/source_alias_mapping.md) trước khi kết luận PENDING

4. **atomic_attributes.csv** — xác nhận tên entity/attribute khi cần (không đoán)

5. **HLD hiện tại** (nếu có) — append thêm, không viết lại

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

## BƯỚC 3 — PHÂN LOẠI BẢNG DATAMART

| Loại | Khi nào | Pattern |
|---|---|---|
| **Phân tích** | KPI aggregate nhiều đối tượng / nhiều kỳ | Star Schema — Fact + Dim |
| **Tác nghiệp** | Lookup 1 đối tượng cụ thể | Denormalized Table — 1 row per đối tượng |

## BƯỚC 4 — THIẾT KẾ VÀ XUẤT FILE

Đọc [`reference/section_structure.md`](reference/section_structure.md) để biết format 4 section.
Đọc [`reference/flowchart_rules.md`](reference/flowchart_rules.md) trước khi vẽ Lineage.
Đọc [`reference/erdiagram_rules.md`](reference/erdiagram_rules.md) trước khi vẽ Star Schema.
Đọc [`reference/naming_conventions.md`](reference/naming_conventions.md) trước khi đặt tên bảng/KPI.

**Output:** `Datamart/hld/DTM_{MODULE}_HLD.md`

Tạo thư mục nếu chưa có. Thông báo đường dẫn file và yêu cầu user review.

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

### Section 2 — Tổng quan báo cáo
- [ ] Hierarchy: `### Tab` → `#### Nhóm` → `##### PENDING/READY` (chỉ khi có cả 2)
- [ ] Block READY có đủ: Phân loại / Atomic / Mockup / Source / Bảng KPI / Star Schema / Lineage Mart → Báo cáo / Bảng grain
- [ ] Block PENDING có đủ: KPI liên quan / Lý do / Atomic cần bổ sung / Mart dự kiến (chỉ tên + grain)
- [ ] Bảng KPI PENDING: chỉ 4 cột (KPI ID / Tên KPI / Tính chất / Trạng thái) — không có Đơn vị, Công thức
- [ ] Bảng PENDING không có Star Schema, erDiagram, Lineage flowchart
- [ ] Block PENDING không tạo Open Issue (Section 4) về grain/schema/logic — chỉ ghi nhận Atomic cần bổ sung
- [ ] KPI ID đã được khai sinh trong Section 2 trước khi xuất hiện ở file khác
- [ ] Mọi dòng BA `Phân loại = "Chiều"` phải có KPI_ID trong bảng KPI của nhóm tương ứng — không được bỏ qua
- [ ] Chiều dùng như ETL filter nội bộ (không hiển thị UI) → ghi rõ trong cột Ghi chú: "dùng trong formula KPI K_X_N" — vẫn phải có KPI_ID
- [ ] Cấm dùng shorthand "xem Nhóm N" thay thế bảng KPI — nếu nhóm reuse KPI từ nhóm khác, liệt kê explicit từng KPI_ID kèm ghi chú nguồn gốc: "Reuse từ Nhóm N"
- [ ] Đọc toàn bộ BA file trước khi viết bảng KPI — đảm bảo không sót dòng nào có `Trạng thái mapping ∈ {Done, Doing, Pending}`
- [ ] **Dedup KPI giữa các Nhóm trong cùng Tab:** Trước khi cấp ID mới cho Nhóm N, kiểm tra toàn bộ KPI đã khai sinh ở Nhóm 1→(N-1). Nếu trùng nội dung → reuse ID cũ, KHÔNG cấp ID mới. Liệt kê reuse bằng bảng riêng (xem format trong `reference/section_structure.md`)
- [ ] **Đồng bộ "KPI liên quan" trong PENDING header:** Sau khi hoàn thiện bảng KPI PENDING, kiểm tra lại dòng `**KPI liên quan:**` — phải khớp chính xác với tất cả ID xuất hiện trong bảng (cả mới lẫn reuse). Nếu bảng KPI thay đổi → cập nhật dòng này ngay

### Section 3 — Mô hình tổng thể
- [ ] Không bao gồm PENDING
- [ ] Bảng Phân tích: chỉ liệt kê Fact (không liệt kê Dimension)
- [ ] Bảng Dimension: chỉ liệt kê Dimension, có ghi chú "Tất cả Dimension áp dụng SCD Type 4A"
- [ ] Cột Conformed điền đúng (Có/Không)

### Section 4 — Vấn đề mở
- [ ] ID format: `O_{MODULE}_N`
- [ ] Có cột: ID / Vấn đề / Giả định hiện tại / KPI liên quan / Trạng thái

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
