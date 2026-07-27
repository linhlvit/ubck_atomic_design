# Naming Conventions — Datamart HLD

## Tên bảng Datamart

| Loại | Convention | Ví dụ |
|---|---|---|
| Fact Event | `Fact <Subject> <Event>` | `Fact Foreign Investor Registration` |
| Fact Snapshot | `Fact <Subject> <Object> Snapshot` | `Fact Foreign Investor Portfolio Snapshot` |
| Dimension | `<Entity> Dimension` | `Foreign Investor Dimension` |
| Tác nghiệp | `Operational <Subject> <Pattern>` (tiếng Anh) | `Operational Foreign Investor 360 Profile` |
| Fact dạng report (xem ngoại lệ bên dưới) | `<Subject> <...> Report` (KHÔNG mang tiền tố "Fact") | `Foreign Investor Trading Statistics Report` |

❌ Không prefix `flat_`.
❌ Không mô tả storage hoặc tần suất trong tên bảng (VD: `Daily_Snapshot`, `Monthly_Report`).
❌ Không dùng tên module trong tên bảng (VD: `NDTNN_Foreign_Investor_Dimension`).

**Đối chiếu logical name ↔ physical name theo `table_type` (bắt buộc đặt tên logical đúng ngay từ HLD — tránh phải đổi ngược ở LLD):**

| `table_type` | Physical name (LLD) | Logical name (HLD) tương ứng | Ghi chú |
|---|---|---|---|
| `fact` | tiền tố `fct_` | mang tiền tố **"Fact"** | mặc định |
| `dim` | hậu tố `_dim` | hậu tố **"Dimension"** | |
| `operational` | tiền tố `opr_` | mang tiền tố **"Operational"** | nhất quán với "Fact ..."/"... Dimension" — đặt tên logical `Operational <Subject> <Pattern>` ngay từ HLD (VD: `Operational Foreign Investor 360 Profile`); LLD chỉ cần lowercase + áp physical naming rule để ra `opr_...`, không phải tự suy luận tiền tố một chiều |
| `fact` (biến thể **report**) | hậu tố `_rpt` (KHÔNG kèm tiền tố `fct_`) | mang hậu tố **"Report"**, **không mang tiền tố "Fact"** | xem điều kiện nhận diện bên dưới |

**Khi nào dùng biến thể Fact-report (hậu tố `_rpt`):** Bảng phục vụ báo cáo đóng gói cố định theo kỳ — ETL append-only theo Report Date, không SCD4A, thường denormalize hoàn toàn, không có FK Dimension. Nếu Nhóm/KPI đang thiết kế khớp mô tả này, đặt tên logical ngay từ Section 2/3 theo dạng `<Subject> ... Report` (KHÔNG `Fact <Subject> ... Report`) để LLD chỉ cần áp `_rpt`, không phải đổi tên logical đã duyệt. Tiêu chí phân biệt Fact vs Operational khi chọn `table_type`: **Fact = append theo thời gian** (mỗi lần ETL chạy thêm dòng cho kỳ mới); **Operational = SCD4A** (giữ current-state, update/replace theo latest) — không dùng "có denormalize hay không" làm tiêu chí.

---

## KPI ID

| Loại | Format | Ví dụ |
|---|---|---|
| Base | `K_{MODULE}_{N}` | `K_FMS_1` |
| Sub | `K_{MODULE}_{N}a`, `K_{MODULE}_{N}b` | `K_FMS_3a` |
| YoY | `K_{MODULE}_{N}_YOY` | `K_FMS_1_YOY` |

**Quy tắc khai sinh:**
- KPI ID được khai sinh **lần đầu** tại Section 2 (bảng KPI duy nhất của Nhóm, dòng có Trạng thái READY hoặc PENDING)
- Chỉ sau khi khai sinh trong HLD mới xuất hiện trong Attributes CSV và Detail Mapping CSV
- ❌ Detail Mapping không tự sinh KPI ID mới — chỉ tham chiếu từ HLD

**Khi rút scope:**
- Không re-number KPI ID — giữ gap (VD: K_FMS_1, K_FMS_3, K_FMS_5 — không đánh lại)
- Ghi nhận gap trong Section 4 (Vấn đề mở) nếu cần giải thích

**Khi PENDING → READY:**
- Giữ nguyên KPI ID đã khai sinh — chỉ đổi cột Trạng thái từ PENDING sang READY trong cùng bảng KPI, không cấp ID mới, không tạo dòng/bảng mới

---

## Open Issue ID

Format: `O_{MODULE}_{N}` — tuần tự trong module.

Ví dụ: `O_FMS_1`, `O_FMS_2`, `O_NDTNN_3`

---

## Fact Pattern

| Pattern | Khi nào | Grain |
|---|---|---|
| `Fact Event` | Sự kiện bất biến 1 lần | 1 row / sự kiện |
| `Fact Snapshot` | Stock metric so sánh cùng kỳ | 1 row / đối tượng / kỳ |
| `Fact Accumulating Snapshot` | Vòng đời nhiều milestone | 1 row / đối tượng (update in-place) |

Mọi Fact bắt buộc có ít nhất 1 FK date đến Calendar Date Dimension.
❌ Không thiết kế Surrogate key cho Fact table.
❌ Không dùng Snowflake schema.

---

## Dimension và Operational SCD

- **SCD Type 4A bắt buộc** cho tất cả Dimension (trừ Calendar Date Dimension) và Operational
- ETL tự quản lý `Effective Date` / `Expiry Date` — không thiết kế trong schema
- **Conformed Dimension** (dùng chung cross-module): Calendar Date, Geographic Area, Classification

---

## Classification Dimension

FK trên Fact: `FK → Classification Dimension (scheme: <SCHEME>)`

❌ Cấm tự sinh giá trị phân loại khi Atomic không có danh mục.

---

## Quy ước ngôn ngữ trong HLD

| Nội dung | Ngôn ngữ |
|---|---|
| Tên KPI, mô tả, grain description, vấn đề mở | Tiếng Việt có dấu |
| Tên bảng, tên cột, tên entity, mã nguồn | Tiếng Anh |
| Keyword kỹ thuật (Fact, Dimension, Snapshot...) | Tiếng Anh |

❌ Tuyệt đối không dùng physical name (snake_case) ở bất kỳ vị trí nào trong HLD.
