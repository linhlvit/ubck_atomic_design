# Phân loại vấn đề và hành động tương ứng

## 3 Kịch bản chính

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

**Hành động:** Sửa trực tiếp file LLD sau khi user xác nhận

Cách xử lý:
1. Liệt kê cụ thể: file, dòng, cột cần sửa, giá trị cũ → mới
2. Hỏi user xác nhận
3. Dùng `Edit` tool để sửa trực tiếp

---

## Bảng quyết định nhanh

```
KPI trong BA = Done
    + HLD = PENDING / chưa có
        → Kịch bản A → datamart-hld-design

    + HLD = READY
        + Attributes thiếu / logic sai do BA đổi
            → Kịch bản B → datamart-lld-design (Phase 2)
        + Detail Mapping thiếu / formula sai do BA đổi  
            → Kịch bản B → datamart-lld-design (Phase 3)
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

### Atomic entity chưa có (không tìm được trong atomic_attributes.csv)

- **Không phải** Kịch bản A, B, hoặc C
- Đây là gap ở lớp Atomic — nằm ngoài scope review Datamart
- Hành động: ghi nhận là `Gap Atomic`, báo cáo cho user
- Datamart vẫn để `PENDING` cho KPI này cho đến khi Atomic bổ sung

### HLD READY nhưng Attributes/Detail Mapping hoàn toàn trống

- Critical — LLD chưa được thiết kế dù HLD đã duyệt
- Hành động: gọi `datamart-lld-design` Phase 2 + Phase 3

### BA mô tả nguồn bằng tên bảng source (IDS.data, T24.FUNDS.TRANSFER...)

- Cần trace qua Atomic trước khi kết luận
- Tra `Atomic/lld/atomic_attributes.csv` để tìm entity/column tương ứng
- Nếu không tìm thấy → Gap Atomic (xem trên)
- Không map trực tiếp source table → Datamart
