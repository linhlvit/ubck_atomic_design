# HƯỚNG DẪN CHUYÊN SÂU ROLE-PLAYING DATE DIMENSION FK
## Dự án: Data Warehouse UBCKNN — Chuẩn Thiết kế Kimball & Kiểm định Datamart

---

## 1. Bản Chất Kiến Trúc & Lý Thuyết Ralph Kimball

Trong kho dữ liệu theo chuẩn Dimensional Modeling của Ralph Kimball:
- **Calendar Date Dimension** (`cdr_dt_dim`) là một Conformed Dimension dùng chung toàn hệ thống. Khóa chính (Primary Key - PK) duy nhất của bảng này là `Calendar Date Dimension Id` (tên physical: `cdr_dt_dim_id`, kiểu chuỗi `string` hoặc surrogate key `int`).
- Khi bảng Fact tham chiếu đến chiều ngày, một bảng Fact trong thực tế nghiệp vụ chứng khoán có thể có **nhiều mối quan hệ độc lập** với trục thời gian:
  - Ngày giao dịch phát sinh (`Trade Date`)
  - Ngày thanh toán tiền/chứng khoán (`Settlement Date`)
  - Ngày nộp báo cáo (`Submission Date`)
  - Ngày phê duyệt hồ sơ (`Approval Date`)
  - Ngày hiệu lực cấp phép (`Effective Date`)
  - Ngày kết thúc kỳ snapshot thống kê (`Snapshot Date`)
- Nếu bảng Fact đặt tên khóa ngoại đơn giản là `Calendar Date Dimension Id` hoặc `cdr_dt_dim_id`, mô hình dữ liệu sẽ bị mất đi ngữ cảnh nghiệp vụ, không thể phân biệt được các chiều thời gian khác nhau trong cùng một Fact table và vi phạm nghiêm trọng chuẩn Kimball.
- Do đó, mọi Foreign Key từ Fact trỏ đến `cdr_dt_dim` **BẮT BUỘC** phải là **Role-Playing Dimension Keys**, mang tên vai trò nghiệp vụ cụ thể.

---

## 2. Phân Định: Role-Playing Date FK vs Degenerate Date Attribute

Để tránh nhầm lẫn biến tất cả trường ngày thành Dimension FK hoặc tạo các cột giả surrogate key không cần thiết, áp dụng quy tắc phân định rõ ràng sau:

| Tiêu chí | Role-Playing Date Dimension FK | Degenerate Date Attribute |
|---|---|---|
| **Mục đích sử dụng** | Trục phân tích thời gian chính (slicer, filter theo năm/quý/tháng/tuần/ngày làm việc, so sánh YoY/MoM, rollup thời gian). | Thuộc tính ngày mô tả chi tiết nghiệp vụ phục vụ hiển thị (pass-through), không dùng làm trục cắt lát báo cáo. |
| **Phạm vi áp dụng** | Primary Grain Date, Periodic Snapshot Date, Transaction/Event Date, Effective Date. | Ngày ký quyết định, ngày lập biên bản xử phạt, ngày cấp phép lần đầu, ngày công bố thông tin, ngày đóng tài khoản. |
| **Quy ước đặt tên logical** | Bắt buộc kết thúc bằng `Date Dimension Id` (ví dụ: `Snapshot Date Dimension Id`, `Trade Date Dimension Id`). | Kết thúc bằng `Date` hoặc `Dt` (ví dụ: `Decision Signed Date`, `Violation Record Date`). |
| **Quy ước đặt tên physical** | Bắt buộc kết thúc bằng `_dt_dim_id` (ví dụ: `snpst_dt_dim_id`, `trade_dt_dim_id`). | Kết thúc bằng `_dt` (ví dụ: `decision_signed_dt`, `violation_record_dt`, `first_license_dt`). |
| **Kiểu dữ liệu & Domain** | `string` / `VARCHAR(32)`, Domain: `Surrogate Dimension Key`, Role: `FK`. | `date` / `DATE`, Domain: `Date`, Role: `Measure` hoặc `Attribute`. |
| **Mối quan hệ FK** | Có quan hệ FK tường minh trỏ tới bảng `cdr_dt_dim`. | Không tạo quan hệ FK, không trỏ sang Dimension. |

---

## 3. Quy Tắc Đặt Tên & Cú Pháp Chuẩn Hóa

### 3.1. Cấm Tuyệt Đối Trên Fact Table
- ⛔ **CẤM TUYỆT ĐỐI:** Sử dụng `Calendar Date Dimension Id` hoặc `cdr_dt_dim_id` (cũng như biến thể cũ `calendar_dt_dim_id`) làm Foreign Key trên bất kỳ bảng Fact nào!
- `cdr_dt_dim_id` **CHỈ là Primary Key của chính bảng Dimension `cdr_dt_dim`** (`table_type = dim`).

### 3.2. Với Fact Periodic Snapshot (`fct_*_snpst`)
Bảng Periodic Snapshot định kỳ lưu số dư/chỉ số tại các mốc thời gian (ngày, tháng, quý, năm). Trục thời gian kỳ bắt buộc phải mang tên:
- **Logical name:** `Snapshot Date Dimension Id`
- **Physical name:** `snpst_dt_dim_id` (quy tắc viết tắt chuẩn: snapshot → snpst, date → dt, dimension → dim, id → id)
- **Domain:** `Surrogate Dimension Key` | **Type:** `string` | **Role:** `FK`
- **ETL Logic trong Attributes (Lớp 2):** Tra cứu từ Atomic lên Datamart bằng trường ngày tự nhiên của driving table:
  ```sql
  LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt = <driving_table>.ds_snpst_dt
  ```
- **Query Logic trong Detail Mapping (Lớp 3):** Kết nối truy vấn báo cáo từ Fact sang Dimension ngày bằng surrogate key:
  ```sql
  LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt_dim_id = <fact>.snpst_dt_dim_id
  ```

### 3.3. Với Fact Event / Transaction / Accumulating Snapshot
Bảng ghi nhận sự kiện/giao dịch phát sinh bắt buộc đặt tên theo vai trò nghiệp vụ:
- **Logical name:** `<Role> Date Dimension Id`
- **Physical name:** `<role>_dt_dim_id`
- **ETL Logic trong Attributes (Lớp 2):**
  ```sql
  LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt = <driving_table>.<event_date_col>
  ```
- **Query Logic trong Detail Mapping (Lớp 3):**
  ```sql
  LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt_dim_id = <fact>.<role>_dt_dim_id
  ```

### 3.4. Bảng Tra Cứu Role-Playing Date Columns Phổ Biến Theo Phân Hệ UBCKNN

| Phân hệ UBCKNN | Bảng Fact Đại diện | Logical Name Chuẩn | Physical Name Chuẩn | Mô tả Ý nghĩa Nghiệp vụ |
|---|---|---|---|---|
| **Toàn hệ thống** | `fct_*_snpst` | Snapshot Date Dimension Id | `snpst_dt_dim_id` | Khóa ngày chốt kỳ snapshot báo cáo |
| **TT (Thanh tra)** | `fct_inspection_plan` | Inspection Plan Date Dimension Id | `inspection_plan_dt_dim_id` | Ngày ban hành kế hoạch thanh tra |
| **TT (Thanh tra)** | `fct_inspection_conclusion` | Conclusion Date Dimension Id | `conclusion_dt_dim_id` | Ngày ban hành kết luận thanh tra |
| **GSDC (Giám sát Cty ĐC)** | `fct_public_company_financial_snpst` | Snapshot Date Dimension Id | `snpst_dt_dim_id` | Kỳ báo cáo tài chính snapshot |
| **GSDC (Giám sát Cty ĐC)** | `fct_corporate_disclosure_event` | Disclosure Date Dimension Id | `disclosure_dt_dim_id` | Ngày doanh nghiệp công bố thông tin |
| **GSTT (Giám sát Thị trường)** | `fct_market_warning_event` | Warning Date Dimension Id | `warning_dt_dim_id` | Ngày hệ thống kích hoạt cảnh báo |
| **GSTT (Giám sát Thị trường)** | `fct_trading_order_event` | Order Date Dimension Id | `order_dt_dim_id` | Ngày đặt lệnh giao dịch |
| **GSTT (Giám sát Thị trường)** | `fct_trade_execution_event` | Trade Date Dimension Id | `trade_dt_dim_id` | Ngày khớp lệnh thực tế |
| **NHNCK (Người hành nghề)** | `fct_practicing_license_snpst` | Snapshot Date Dimension Id | `snpst_dt_dim_id` | Kỳ snapshot tình trạng chứng chỉ hành nghề |
| **NHNCK (Người hành nghề)** | `fct_license_issuance_event` | Issue Date Dimension Id | `issue_dt_dim_id` | Ngày cấp chứng chỉ hành nghề |
| **QLKD (Quản lý Kinh doanh)** | `fct_security_company_finance_snpst` | Snapshot Date Dimension Id | `snpst_dt_dim_id` | Kỳ snapshot an toàn tài chính CTCK |
| **PTTT (Phát triển Thị trường)** | `fct_ipo_issuance_event` | Issue Date Dimension Id | `issue_dt_dim_id` | Ngày phát hành IPO cổ phiếu |
| **PTTT (Phát triển Thị trường)** | `fct_ipo_submission_event` | Submission Date Dimension Id | `submission_dt_dim_id` | Ngày nộp hồ sơ đăng ký chào bán |
| **QLQ (Quản lý Quỹ)** | `fct_fund_nav_snpst` | Snapshot Date Dimension Id | `snpst_dt_dim_id` | Kỳ snapshot giá trị tài sản ròng NAV |
| **QLCB (Quản lý Chào bán)** | `fct_issuance_approval_event` | Approval Date Dimension Id | `approval_dt_dim_id` | Ngày chấp thuận chào bán chứng khoán |

---

## 4. Bài Học Thực Tế: Sự Cố GSĐC (2026-09-08)

- **Hiện tượng:** Khi thiết kế phân hệ GSĐC (Giám sát Công ty Đại chúng), tài liệu HLD và LLD đặt tên logical generic là `Calendar Date Dimension Id` trên bảng `fct_public_company_financial_snpst`. Khi chạy script derive physical name, hệ thống tự động sinh ra `cdr_dt_dim_id` trên bảng Fact.
- **Hậu quả:**
  1. Script `datamart_date_fk_checker.py` báo vi phạm nghiêm trọng `L2-DATE-FK-ROLE-PLAYING`.
  2. Bảng Fact Snapshot thiếu mất định danh kỳ (`snpst_dt_dim_id`), khiến câu lệnh SQL tổng hợp báo cáo PTTK/TKCSLD bị sai lệch ngữ nghĩa.
  3. Lỗi lây lan sang cả 4 tầng artifact: Attributes CSV, Detail Mapping CSV, Model Registry YAML và Flat Table SQL scripts.
- **Nguyên nhân cốt lõi:** Người thiết kế áp dụng quy tắc "Tên FK = {Tên Dim} + Id" một cách máy móc mà không định danh vai trò ngày (Role-Playing).
- **Giải pháp triệt để:** Bắt buộc đặt tên logical theo vai trò ngày ngay từ tầng HLD/Phase 1 trước khi chuyển giao sang LLD.

---

## 5. Công Cụ Kiểm Tra Tự Động Hóa (CLI Checker)

Reviewer bắt buộc chạy công cụ kiểm tra tự động trước khi xác nhận bất kỳ nhóm nào là READY:

```bash
# Kiểm tra riêng cho một phân hệ cụ thể:
python scripts/datamart_date_fk_checker.py --module [MODULE]

# Kiểm tra toàn bộ kho dữ liệu Datamart:
python scripts/datamart_date_fk_checker.py --module all
```

### Các Quy Tắc Kiểm Tra Trong Script:
1. **Rule 1 (Critical Error):** Bất kỳ cột nào trên bảng Fact (`fct_*`) có tên physical là `cdr_dt_dim_id` hoặc `calendar_dt_dim_id` → Báo lỗi `Severity.ERROR`, mã vi phạm `L2-DATE-FK-ROLE-PLAYING`.
2. **Rule 2 (Critical Error / Blocker):** Bảng Periodic Snapshot (`fct_*_snpst`) bắt buộc phải có cột `snpst_dt_dim_id`. Nếu thiếu hoàn toàn hoặc đặt tên khác → Báo lỗi `Severity.ERROR`.
3. **Rule 3 (Advisory Info):** Bảng Fact Event không có bất kỳ trường Date FK nào trỏ `cdr_dt_dim` → Cảnh báo Advisory để reviewer kiểm tra xem có cần bổ sung Role-Playing FK hay không.

---

## 6. Giao Thức Khắc Phục 4 Tầng (Remediation Protocol)

Khi phát hiện vi phạm `L2-DATE-FK-ROLE-PLAYING`, Reviewer tuân thủ nghiêm ngặt **Kịch bản C** (không tự ý edit file trực tiếp):

### Bước 1: Trình Bày Action Đề Xuất
Lập bảng đối soát chi tiết 4 cột:
```
| File Path | Bảng Fact | Tên Cột Cũ (Sai) | Tên Cột Đề Xuất (Đúng) |
|---|---|---|---|
| Datamart/lld/GSDC/DTM_GSDC_Attributes_fct_snpst.csv | fct_public_company_financial_snpst | cdr_dt_dim_id | snpst_dt_dim_id |
```

### Bước 2: Dừng Chờ Human Phê Duyệt
Claude DỪNG và xin ý kiến phê duyệt của Tech Lead / Human Operator.

### Bước 3: Đồng Bộ Hóa Xuyên Suốt 4 Tầng Qua Skill Con
Sau khi Human đồng ý, kích hoạt skill `datamart-lld-design` để đồng bộ đồng thời trên 4 tầng:
1. **Tầng 1 — Attributes CSV:** Cập nhật cột trong file phân hệ chi tiết `Datamart/lld/{MODULE}/*.csv` và file master `Datamart/lld/datamart_attributes.csv`.
2. **Tầng 2 — Detail Mapping CSV:** Cập nhật cột `mart_column` và mệnh đề JOIN `LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt_dim_id = <fact>.<role>_dt_dim_id` trong `DTM_{MODULE}_Detail_Mapping.csv`.
3. **Tầng 3 — Model Registry:** Cập nhật attribute và column tương ứng trong `Datamart/datamart_model.yaml`.
4. **Tầng 4 — Flat Table SQL:** Cập nhật file DDL `01_create_*.sql` và DML `02_populate_*.sql` trong `Datamart/flat-table/{MODULE}/` nếu đã sinh code.

### Bước 4: Chạy Lại CLI Checker
Reviewer chạy lại `python scripts/datamart_date_fk_checker.py --module [MODULE]` để xác nhận 100% không còn vi phạm trước khi chuyển trạng thái READY.
