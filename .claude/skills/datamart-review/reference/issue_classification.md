# Phân loại vấn đề và hành động tương ứng

## 5 Kịch bản chính

### Kịch bản A — HLD thiếu / PENDING, BA đã Done

**Dấu hiệu:**
- HLD không có section cho nhóm này, HOẶC
- HLD ghi `PENDING` / `Chờ BA xác nhận` cho nhóm này
- BA analyst: trạng thái = Done (100% hoặc phần lớn), có bảng nguồn rõ ràng

**Hành động:** Gọi skill `datamart-hld-design`

Truyền context cụ thể:
- Số nhóm và tên nhóm cần thiết kế
- Trạng thái hiện tại trong HLD (PENDING / chưa có)
- Thông tin BA đã có: nguồn, KPI, công thức

**Không tự viết thêm vào HLD** — để skill `datamart-hld-design` xử lý đúng format.

---

### Kịch bản B — Logic BA thay đổi

**Dấu hiệu — một trong các trường hợp sau:**
- BA cập nhật công thức tính KPI (thêm/bớt filter, thay đổi aggregation)
- BA thêm bảng nguồn mới (field mới từ Atomic entity khác)
- BA thay đổi dimension (thêm/bớt chiều slicer/filter)
- Detail Mapping `logic` không khớp với công thức BA mới nhất
- Attributes `etl_logic` không phản ánh join/filter mới từ BA

**Hành động:** Gọi skill `datamart-lld-design`

Truyền context cụ thể:
- File nào cần cập nhật: Attributes.csv, Detail_Mapping.csv, hoặc cả hai
- Nhóm/KPI nào bị ảnh hưởng
- Thay đổi cụ thể từ BA (trước vs sau)

**Không tự sửa file** khi đây là thay đổi logic nghiệp vụ — cần qua skill LLD để đảm bảo nhất quán.

---

### Kịch bản C — Lỗi kỹ thuật thiết kế

**Dấu hiệu — không liên quan thay đổi BA:**
- Sai `data_domain` hoặc `data_type` (VD: số tiền dùng `int` thay vì `float`)
- Thiếu `WHERE` filter trong `src_stm_code`
- `nullable` sai với business rule (FK để nullable = true)
- Tên cột không nhất quán (physical/logical lẫn lộn)
- Thiếu `src_stm_code` cho Dim/Operational

**Hành động:** Trình bày action đề xuất → chờ user xác nhận → **gọi skill con để sửa**

Cách xử lý (chốt 2026-08-22 — trước đây cho phép tự `Edit`, nay KHÔNG):
1. Liệt kê cụ thể: file, dòng, cột cần sửa, giá trị cũ → mới, lý do
2. Hỏi user xác nhận
3. **Gọi skill con thực hiện** — HLD → `datamart-hld-design`; Attributes / Detail Mapping / `datamart_model.yaml` → `datamart-lld-design`

❌ **Không dùng `Edit` tool sửa trực tiếp** — `datamart-review` chỉ phát hiện, phân loại, đề xuất.

---

### Kịch bản D — HLD sai do thiết kế/nguồn Atomic lỗi thời

**Dấu hiệu:**
- HLD đã tồn tại, đánh READY, nhưng trỏ nhầm nguồn Atomic đã deprecated/tái cấu trúc, sai grain, sai entity, hoặc logic nghiệp vụ không còn khớp Atomic hiện hành
- Khác Kịch bản A (không phải PENDING) và khác Kịch bản C (đây là lỗi nội dung/logic, không phải lỗi kỹ thuật thuần cấu trúc)

**Hành động:** Gọi `datamart-hld-design` để thiết kế lại — KHÔNG tự sửa tay nội dung HLD (Fact, grain, nguồn Atomic, bảng KPI) dù đã xác định rõ hướng sửa.

---

### Kịch bản E — Review theo issue/bug report

**Dấu hiệu:**
- User hoặc BA báo một vấn đề/lỗi cụ thể trên hệ thống (VD: "thiếu TRADINGTIME", "P/E tính sai", "thiếu chỉ tiêu intraday") thay vì yêu cầu review tuần tự cả module.

**Hành động:** Chạy **BƯỚC 0-ALT** (Review theo Issue/Bug Report):
1. Xác định field/KPI/bảng nguồn liên quan
2. Trace đủ 5 tầng: Source → Atomic → HLD → LLD (Attributes & Detail Mapping) → Flat Table
3. Xuất bảng ma trận trạng thái per-tầng (✅/⚠️/❌)
4. Xác định root cause, blocker cụ thể và Open Issue liên quan
5. Đọc sâu SQL BA (đặc biệt các logic TTM, filter, dedup) để xác minh tính chính xác
6. Xuất báo cáo kết luận + Action Items và chờ phê duyệt

---

## Bảng quyết định nhanh

```
KPI trong BA = Done
    + HLD = PENDING / chưa có
        → Kịch bản A → datamart-hld-design

    + HLD = READY
        + Attributes thiếu / logic sai do BA đổi
            → Kịch bản B → datamart-lld-design (Phase 1 — Attributes)
        + Detail Mapping thiếu / formula sai do BA đổi  
            → Kịch bản B → datamart-lld-design (Phase 2 — Detail Mapping)
        + Lỗi kỹ thuật thuần (không phải BA đổi)
            → Kịch bản C → sửa trực tiếp

KPI trong BA = Pending
    + HLD ghi PENDING
        → OK — không action
    + HLD không có
        → Warning — kiểm tra lại HLD
```

---

## Trường hợp đặc biệt

### Atomic entity chưa có (không tìm được ở cả 2 nguồn Atomic chuẩn)

- **Không phải** Kịch bản A, B, hoặc C
- Đây là gap ở lớp Atomic — nằm ngoài scope review Datamart
- Hành động: ghi nhận là `Gap Atomic`, báo cáo cho user
- Datamart vẫn để `PENDING` cho KPI này cho đến khi Atomic bổ sung

### HLD READY nhưng Attributes/Detail Mapping hoàn toàn trống

- Critical — LLD chưa được thiết kế dù HLD đã duyệt
- Hành động: gọi `datamart-lld-design` Phase 1 (Attributes) + Phase 2 (Detail Mapping)

### BA mô tả nguồn bằng tên bảng source (IDS.data, T24.FUNDS.TRANSFER...)

- Cần trace qua Atomic trước khi kết luận
- Tra theo **đúng 2 nguồn chuẩn, theo thứ tự ưu tiên** (giống `SKILL.md` — không dùng nguồn nào khác):

| Ưu tiên | Nguồn |
|---|---|
| 1 — luôn tra trước | `DataModel/Atomic/**/*.yaml` |
| 2 — chỉ khi Nguồn 1 không có | `DataModel/working/Atomic/lld/**/*.yaml` |

```bash
grep -rl "IDS.data" DataModel/Atomic/
grep -rl "IDS.data" DataModel/working/Atomic/lld/   # chỉ khi Nguồn 1 không có
```

- ❌ KHÔNG tra `DataModel/working/Atomic_LinhLV/` (track cũ đã revert) và KHÔNG tra `DataModel/working/Atomic/aggregate/atomic_attributes.yaml` (nằm ngoài 2 nguồn chuẩn)
- Nếu không tìm thấy ở cả 2 nguồn → Gap Atomic (xem trên)
- Không map trực tiếp source table → Datamart
