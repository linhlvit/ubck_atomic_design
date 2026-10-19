# Phase 0 — Plan — LLD Datamart

Đọc khi bắt đầu thiết kế LLD cho một module. Quy trình tổng và GATE RULE nằm trong `SKILL.md`.

## Mục lục

- PHASE 0 — PLAN
  - Bước P1 — Đọc HLD Section 2
  - Bước P2 — Map bảng cho từng nhóm
  - Bước P2b — Chốt physical name chuẩn cho entity dùng chung nhiều bảng (bắt buộc)
  - Bước P3 — Trình bày plan và GATE

## PHASE 0 — PLAN

**Bắt buộc thực hiện trước Phase 1.** Mục đích: human nắm toàn bộ scope, approve một lần, Claude chạy từng nhóm.

### Bước P1 — Đọc HLD Section 2

Lấy danh sách **TOÀN BỘ** nhóm báo cáo bằng `python .claude/skills/datamart-review/scripts/lld_selfcheck.py --module {MODULE} --tc 5`
(dòng tóm tắt in ra số nhóm và số KPI_ID của HLD Section 2) — KHÔNG Read cả file HLD.
Chỉ nạp khối từng Nhóm khi bắt đầu xử lý Nhóm đó: `ctx_slice.py --module {MODULE} --nhom {N}`.
Danh sách nhóm báo cáo
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
2. Với mỗi entity như vậy: áp dụng PHYSICAL NAMING RULE (`reference/physical_naming.md`) để xác định **đúng 1 dạng
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

