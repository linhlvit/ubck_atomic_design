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
- Ghi nhận gap trong Section 5 (Vấn đề mở) nếu cần giải thích

**Khi PENDING → READY:**
- Giữ nguyên KPI ID đã khai sinh — chỉ đổi cột Trạng thái từ PENDING sang READY trong cùng bảng KPI, không cấp ID mới, không tạo dòng/bảng mới

---

## Open Issue ID

Format: `O_{MODULE}_{N}` — tuần tự trong module.

Ví dụ: `O_FMS_1`, `O_FMS_2`, `O_NDTNN_3`

---

## Fact Pattern & Lưu Trữ Chuỗi Thời Gian

**Giá trị hợp lệ của cột `Pattern` (Section 3.2) — chốt đúng 2, theo `section_structure.md`:**

| Pattern | Khi nào | Grain Lưu Trữ (Fact Storage Grain) |
|---|---|---|
| `Event` | Sự kiện nghiệp vụ bất biến phát sinh 1 lần (giao dịch, vi phạm, cấp phép...) | 1 row / sự kiện phát sinh |
| `Periodic Snapshot` | Trạng thái định kỳ, số dư tích lũy, hoặc chuỗi thời gian phân tích (lookback N phiên, giá đóng cửa, chỉ số tài chính) | 1 row / đối tượng / kỳ (ngày, tháng, quý, năm) |

> ⚠️ **Chuẩn hóa lưu trữ chuỗi thời gian lookback trên Fact Periodic Snapshot:**
> Mọi chỉ tiêu phân tích lookback (Đỉnh/Đáy 52 tuần, 6 tháng, 3 tháng, 1 tháng, MA20, MA10, MA5) bắt buộc phải được thiết kế trên **Fact Periodic Snapshot theo ngày** (`Fact ... Snapshot` / `fct_*_snpst`) với Grain `1 row / entity / trade_date`.
> - **Quy đổi phiên giao dịch chuẩn (Trading Sessions):**
>   + 52 tuần = **260 phiên** (`ROWS BETWEEN 259 PRECEDING AND CURRENT ROW`)
>   + 6 tháng = **130 phiên** (`ROWS BETWEEN 129 PRECEDING AND CURRENT ROW`)
>   + 3 tháng = **65 phiên** (`ROWS BETWEEN 64 PRECEDING AND CURRENT ROW`)
>   + 1 tháng / 4 tuần = **20 phiên** (`ROWS BETWEEN 19 PRECEDING AND CURRENT ROW`)
>   + MA20 = **20 phiên**, MA10 = **10 phiên**, MA5 = **5 phiên**
> - ⛔ **CẤM TUYỆT ĐỐI:** Cấm dùng ngày lịch `INTERVAL '52' WEEK` (vì thị trường nghỉ cuối tuần/ngày lễ). Cấm thiết kế Window Function trên Dimension SCD4A current-state (`L2-WINDOW-STORAGE-INVALID`).

Mọi Fact bắt buộc có ít nhất 1 FK date đến Calendar Date Dimension theo chuẩn **Role-Playing Date Dimension**:
- Fact Periodic Snapshot (`fct_*_snpst` / `Fact ... Snapshot`): `Snapshot Date Dimension Id` → physical: `snpst_dt_dim_id`.
- Fact Event / Fact khác: `<Role> Date Dimension Id` → physical: `<role>_dt_dim_id` (`issue_dt_dim_id`, `trade_dt_dim_id`, `evaluation_dt_dim_id`, `submission_dt_dim_id`, `effective_dt_dim_id`...).
- ❌ **TUYỆT ĐỐI CẤM:** Không được dùng `Calendar Date Dimension Id` / `cdr_dt_dim_id` trên bất kỳ Fact table nào (`cdr_dt_dim_id` chỉ là PK của Dimension `cdr_dt_dim`).
- ⚠️ **Cảnh báo lỗi thực tế điển hình:** Trong `DTM_QLKD_HLD.md` (dòng 1201), bảng `Fact_Securities_Company_Compliance_Report_Snapshot` chứa `int Calendar_Date_Dimension_Id FK` là lỗi vi phạm nghiêm trọng Role-Playing Date Key (`L1-DATE-FK-VIOLATION`), bắt buộc phải đổi thành `Snapshot_Date_Dimension_Id FK`.
- **Degenerate Date Attributes:** Các ngày thuộc tính nghiệp vụ phụ (như ngày lập biên bản, ngày ký QĐ, ngày nộp, ngày cấp đầu tiên) giữ kiểu `date` thuần túy, đặt tên `<Concept> Date` (erDiagram: `<Concept>_Date`, physical: `<concept>_dt`), KHÔNG mang nhãn `FK`, KHÔNG thêm hậu tố `_Dimension_Id` / `_dim_id`.
❌ Không thiết kế Surrogate key cho Fact table.
❌ Không dùng Snowflake schema.

---

## Thang 6 Bậc Phân Cấp Hạt Kinh Doanh (Grain Hierarchy) & Chống Grain Mismatch

Khi đặt tên bảng và xác định grain cho Fact, Designer bắt buộc tuân theo thứ bậc 6 cấp độ hạt:
- **Level 1 (Sàn GDCK):** `floor_code` (HOSE, HNX, UPCOM) $\implies$ Bảng phân tích toàn thị trường / cấp sở.
- **Level 2 (Rổ Chỉ Số):** `index_code` (VN-Index, VN30, HNX30) $\implies$ Bảng rổ chỉ số / rổ cổ phiếu.
- **Level 3 (Ngành / Lĩnh Vực):** `industry_code` $\implies$ Bảng thống kê theo ngành kinh tế.
- **Level 4 (Mã Chứng Khoán / Doanh Nghiệp):** `symbol` / `public_company_id` $\implies$ Bảng cổ phiếu, trái phiếu, doanh nghiệp niêm yết.
- **Level 5 (Định Chế / CTCK / Thành Viên):** `member_code` / `sc_firm_id` $\implies$ Bảng thành viên thị trường, công ty quản lý quỹ.
- **Level 6 (Tài Khoản / Giao Dịch Chi Tiết):** `account_number`, `order_id` $\implies$ Bảng lệnh, giao dịch chi tiết, tài khoản NĐT.

> ⛔ **Nguyên tắc chống Grain Mismatch (Bài học Case K_GSTT_61):**
> Cấp độ hạt trình diễn (Presentation Grain ở Section 2) không được mịn hơn Fact Storage Grain ở Section 3. Khi tái sử dụng chỉ tiêu (Reuse), nếu Presentation Grain của nhóm mới khác nhóm gốc (ví dụ gốc cấp Chỉ số Level 2, nhóm mới cấp Mã CK Level 4), **CẤM sao chép nguyên công thức aggregate** — bắt buộc viết lại công thức theo đúng cấp grain của nhóm mới (vd: `GROUP BY symbol`).

---

## Tính Nhất Quán Chu Kỳ Trong Tỷ Số Tài Chính (Financial Ratio Period Consistency)

Khi thiết kế các chỉ tiêu tỷ số tài chính (P/E, P/B, EPS, BVPS, ROE, ROA) trên Fact hoặc trong công thức tính toán:
1. **Nguyên tắc Ghép Cặp Thời Gian (Period Matching):** Tử số và Mẫu số bắt buộc phải nằm trên **cùng một hệ quy chiếu thời gian**:
   - **Chỉ số P/E Năm (TTM):** Tử số = `close_price`, Mẫu số = `EPS TTM` (Lợi nhuận sau thuế lũy kế 4 quý gần nhất chia cho Số cổ phiếu bình quân lưu hành 4 quý).
   - **Chỉ số P/E Quý:** Phải nhân 4 quy năm (`EPS Quý × 4`). Tuyệt đối không lấy Giá đóng cửa chia cho EPS 1 quý mà không quy năm (khiến P/E bị thổi phồng 4 lần).
2. **Lệnh Cấm Cộng Dồn Biến Số Số Dư (Stock Summation Ban):**
   - **TUYỆT ĐỐI CẤM:** Sử dụng `SUM(owner_equity)` hoặc `SUM(total_assets)` qua 4 quý trong mẫu số của P/B hay ROE. Vốn chủ sở hữu và Tổng tài sản là biến số số dư thời điểm (Balance Sheet Stock). Bắt buộc phải lấy số dư quý gần nhất hoặc tính bình quân: `(Đầu kỳ + Cuối kỳ) / 2`.
3. **Quy Tắc Xử Lý Thiếu Báo Cáo Tài Chính (Missing Financial Period):**
   - Nếu doanh nghiệp thiếu BCTC của bất kỳ quý nào trong chuỗi 4 quý TTM $\implies$ Các chỉ tiêu `net_profit_after_tax_ttm`, `EPS TTM`, `P/E` bắt buộc phải trả về `NULL`. Nghiêm cấm việc cộng 2-3 quý rồi tự ý nội suy hoặc chia bình quân.

---


## Role-Playing Date FK và Degenerate Date Attribute Naming Conventions

| Loại thuộc tính ngày | Logical Name (HLD) | erDiagram Name | Physical Name (LLD) | Label | Type | Mục đích & Ví dụ |
|---|---|---|---|---|---|---|
| **Fact Snapshot Date** | `Snapshot Date Dimension Id` | `Snapshot_Date_Dimension_Id` | `snpst_dt_dim_id` | `FK` | `string` / `int` | Trục thời gian định kỳ của Fact Snapshot.<br>VD: `Fact Fund Management Company Snapshot` |
| **Fact Event Date** | `<Role> Date Dimension Id` | `<Role>_Date_Dimension_Id` | `<role>_dt_dim_id` | `FK` | `string` / `int` | Trục thời gian sự kiện của Fact Event.<br>VD: `Trade Date Dimension Id` → `trade_dt_dim_id`<br>`Issue Date Dimension Id` → `issue_dt_dim_id`<br>`Decision Date Dimension Id` → `decision_dt_dim_id`<br>`Submission Date Dimension Id` → `submission_dt_dim_id`<br>`Effective Date Dimension Id` → `effective_dt_dim_id` |
| **Degenerate Date** | `<Concept> Date` | `<Concept>_Date` | `<concept>_dt` | (trống) | `date` / `datetime` | Thuộc tính ngày mô tả nghiệp vụ (pass-through).<br>VD: `Violation Record Date` → `violation_record_dt`<br>`Decision Signed Date` → `decision_signed_dt`<br>`First License Date` → `first_license_dt`<br>`Birth Date` → `birth_dt` |

❌ **CẤM:**
- Cấm dùng `Calendar Date Dimension Id` (`cdr_dt_dim_id`) trên bất kỳ Fact table nào (`Calendar Date Dimension Id` chỉ là PK của Dimension `Calendar_Date_Dimension`).
- Cấm đặt tên Degenerate Date có hậu tố `_Dimension_Id`, `_Dim_Id`, hoặc `_Id`.
- Cấm gắn nhãn `FK` cho Degenerate Date attributes.

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

❌ Không dùng physical name (snake_case) trong HLD — kể cả node ID của mermaid (flowchart Section 1 dùng
tên logical nối bằng `_`, xem `flowchart_rules.md`).

**Ngoại lệ duy nhất — cột `datamart_table` của Section 4 (Reuse Analysis):** cột này theo định nghĩa mang
physical name, vì nó là nguồn để Phase 2 sinh `Entities.csv` và để đối chiếu với `datamart_model.yaml`.
Mọi vị trí khác trong HLD (tên bảng trong văn bản, erDiagram, graph TB, node ID/label flowchart, bảng KPI,
bảng grain, Section 3, Section 5) đều dùng tên logical.
