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

1. **BA file** (`BRD/BA/BA_analyst_{MODULE}.csv`) — extract KPI:
   - Lọc cột `Phân loại`: `Chiều` → slicer/filter dimension; `Cơ sở` + `Phái sinh` → KPI list
   - Ghi nhận cột `Trạng thái mapping` — phân biệt Done/Doing/Pending

2. **Screenshot** — xác định scope boundary (tab, nhóm, loại thông tin hiển thị)

3. **Source Analysis MD** (`BRD/source/working/{Module}_Source_Analysis.md`) — xác định Atomic entity nào READY / PENDING

4. **atomic_attributes.csv** — xác nhận tên entity/attribute khi cần (không đoán)

5. **HLD hiện tại** (nếu có) — append thêm, không viết lại

## BƯỚC 2 — SCOPE GATING

| KPI | Hành xử |
|---|---|
| Atomic READY | In-scope — thiết kế đầy đủ |
| Atomic PENDING | PENDING — placeholder + lý do + Atomic cần bổ sung |
| Không tìm được Atomic | Out-of-scope — ghi nhận, KHÔNG thiết kế |

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
- [ ] Block READY có đủ: Phân loại / Atomic / Mockup / Source / Bảng KPI / Star Schema / Lineage Mart / Bảng grain
- [ ] Block PENDING có đủ: KPI liên quan / Lý do / Atomic cần bổ sung / Mart dự kiến (chỉ tên + grain)
- [ ] Bảng KPI PENDING: chỉ 4 cột (KPI ID / Tên KPI / Tính chất / Trạng thái) — không có Đơn vị, Công thức
- [ ] Bảng PENDING không có Star Schema, erDiagram, Lineage flowchart
- [ ] KPI ID đã được khai sinh trong Section 2 trước khi xuất hiện ở file khác

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
