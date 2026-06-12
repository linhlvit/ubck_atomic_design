# Mapping T24 AA → IBM BCV — Hướng dẫn Thiết kế Atomic Layer

**Cập nhật lần cuối:** 2026-06-01
**Ngữ cảnh:** T24 Transact v23, AA (Arrangement Architecture) module

---

## 1. Tổng quan T24 AA và IBM BCV

**Kết luận nhanh:** T24 AA phân tách rõ Product → Arrangement → Condition → Activity — ánh xạ 1:1 với BCV concepts. Mapping tương đối tự nhiên ở tầng khái niệm; cần xử lý kỹ ở tầng attribute do đặc thù T24 (MV/SV fields, @ID, RECORD.STATUS).

**Phân cấp T24 AA:**

```
Product Line  (AA.PRODUCT.LINE)     → định nghĩa nhóm sản phẩm cấp cao
  └── Product Group                 → nhóm sản phẩm
        └── Product  (AA.PRODUCT)   → sản phẩm cụ thể (template)
              └── Arrangement       → instance hợp đồng từng khách hàng
                    └── Activity    → sự kiện/phát sinh trên hợp đồng
```

---

## 2. Mapping Bảng T24 AA → BCV Concept → Atomic Entity

| Bảng T24 AA | Chứa gì | BCV Concept | Atomic Entity |
|---|---|---|---|
| `AA.PRODUCT.LINE` | Định nghĩa Product Line | Product | Product Line |
| `AA.PRODUCT` | Định nghĩa sản phẩm (template) | Product | Product |
| `AA.PRODUCT.CONDITION` | Điều kiện mặc định tại product level | Condition | Product Condition |
| `AA.ARRANGEMENT` | Header hợp đồng (ID, status, customer, dates) | Arrangement | [Domain] Arrangement |
| `AA.ARRANGEMENT.CONDITION` | Điều kiện override tại instance | Condition | Arrangement Condition |
| `AA.ARRANGEMENT.ACTIVITY` | Log mọi event trên arrangement | Event | Transaction / Event |
| `AA.ARR.PAYMENT.SCHEDULE` | Lịch trả nợ dự kiến (kế hoạch) | Condition | Payment Schedule |
| `AA.ARR.BALANCE` | Số dư theo từng balance component | Event (snapshot) | Balance |
| `COLLATERAL` | Tài sản đảm bảo | Resource Item (Property) | Collateral |
| `CUSTOMER` | Thông tin khách hàng | Involved Party | Involved Party |

---

## 3. Property Classes trong T24 AA

Property Class là cách T24 AA nhóm các điều kiện/thuộc tính của sản phẩm. Mapping sang BCV:

| Property Class | Mô tả | BCV Concept | Xử lý Atomic |
|---|---|---|---|
| `ACCOUNT` | Tài khoản gắn với arrangement | Arrangement (sub-entity) | Attribute trong Arrangement |
| `INTEREST` | Cấu hình lãi suất | Condition | Interest Rate Condition entity |
| `CHARGE` | Cấu hình phí | Condition | Fee Condition entity |
| `PENAL.INTEREST` | Lãi phạt quá hạn | Condition | Penalty Condition entity |
| `COLLATERAL` | Tài sản đảm bảo | Resource Item | Collateral entity |
| `LIMIT` | Hạn mức tín dụng | Condition / Arrangement | Credit Limit entity |
| `TERM` | Kỳ hạn | Condition | Attribute trong Arrangement |
| `PAYMENT` | Cấu hình thanh toán | Condition | Payment Schedule entity |

---

## 4. Phân biệt Condition vs Event/Transaction (điểm hay nhầm lẫn nhất)

**Kết luận nhanh:** Condition = quy tắc/chính sách (tĩnh). Transaction = phát sinh thực tế (động, gắn timestamp cụ thể).

```
AA.PRODUCT.CONDITION / AA.ARRANGEMENT.CONDITION
→ BCV: Condition
→ Atomic: [Product/Arrangement] Condition entity
→ Ví dụ: "Phí phạt trả nợ trước hạn = 2% dư nợ còn lại" (quy định)

AA.ARRANGEMENT.ACTIVITY (activity_type = CHARGE)
→ BCV: Event > Transaction
→ Atomic: [Arrangement] Transaction entity
→ Ví dụ: "Ngày 15/03/2026: thu phí phạt 5,200,000 VND từ HĐ AR-2024-0001" (thực tế)
```

**Rule kiểm tra nhanh:**
- Có timestamp cụ thể + số tiền thực tế phát sinh → **Transaction**
- Là tỷ lệ/công thức/ngưỡng áp dụng trong khoảng thời gian → **Condition**

---

## 5. Lifecycle States của AA Arrangement

T24 AA lifecycle: `ACTIVE → MATURED → LIQUIDATED → CANCELLED`

**Xử lý trên Atomic:**
- Lưu là `arrangement_status_code` (Classification Value) — không tạo entity riêng
- Dùng SCD Type 2 hoặc SCD Type 4A để track lịch sử thay đổi trạng thái
- Tham chiếu IBM BCV term: `Arrangement Life Cycle Status`

---

## 6. Đặc thù T24 v23 Cần Xử lý Đặc biệt

| Đặc thù T24 | Vấn đề | Xử lý trên Atomic |
|---|---|---|
| **Simulation records** | T24 AA tạo arrangement giả lập "what-if" không phải data thật | Filter tại Bronze → Atomic ETL: chỉ lấy `RECORD.STATUS = 'LIVE'` |
| **UNAUTHORISED records** | Records chưa được authorize | Không đưa vào Atomic — chỉ LIVE |
| **Multiple INTEREST conditions** | Một arrangement có nhiều interest condition (MV field ở Bronze) | Thiết kế entity con `Interest Rate Condition` với FK về Arrangement |
| **Activity types** | AA.ARRANGEMENT.ACTIVITY có nhiều loại: PAYMENT, CHARGE, ROLLOVER, MATURITY, SETTLEMENT | Dùng `activity_type_code` (Classification Value, Scheme: ACTIVITY_TYPE) — không tạo entity riêng mỗi loại |
| **@ID format** | T24 @ID thường có prefix: `AA-LOAN-2024-001` | Strip prefix khi tạo `natural_key` cho surrogate key generation |
| **MV/SV fields** | Multi-value và Sub-value đã được Bronze parsing thành flat rows | Thiết kế Atomic entity theo grain của từng MV row, không denorm |
| **CO.CODE** | Company code trong T24 (multi-entity/multi-branch) | Đưa vào audit fields với prefix `ds_` trên Atomic |

---

## 7. System Fields T24 và Xử lý Atomic

**System fields T24 (có trong hầu hết bảng):**

| Field T24 | Ý nghĩa | Xử lý Atomic |
|---|---|---|
| `@ID` | Primary key nghiệp vụ | Dùng tạo surrogate key, lưu thêm làm `[entity]_code` |
| `RECORD.STATUS` | Trạng thái record (LIVE, UNAUTH, RNAU...) | Filter chỉ lấy LIVE lên Atomic |
| `CURR.NO` | Số phiên bản record | Dùng để detect latest version ở Bronze |
| `INPUTTER` | User nhập liệu | `ds_inputter` (audit field, prefix ds_) |
| `DATE.TIME` | Timestamp nhập liệu | `ds_input_timestamp` |
| `AUTHORISER` | User phê duyệt | `ds_authoriser` |
| `CO.CODE` | Mã công ty/chi nhánh | `ds_company_code` |
| `DEPT.CODE` | Mã bộ phận | `ds_dept_code` |

---

## 8. IBM BCV Terms Liên quan T24 AA (Tra cứu nhanh)

Các IBM terms thường dùng khi thiết kế từ T24 AA source:

| IBM Term | BCV Category | Liên quan T24 |
|---|---|---|
| Lending Arrangement | Arrangement | AA.ARRANGEMENT (loan type) |
| Arrangement Life Cycle Status | Arrangement | RECORD.STATUS / lifecycle state |
| Interest Rate Condition | Condition | INTEREST property class |
| Credit Limit | Condition | LIMIT property class |
| Repayment Schedule | Condition | AA.ARR.PAYMENT.SCHEDULE |
| Loan Disbursement Transaction | Transaction | AA.ARRANGEMENT.ACTIVITY (DISBURSEMENT) |
| Loan Repayment | Transaction | AA.ARRANGEMENT.ACTIVITY (PAYMENT) |
| Collateral Arrangement | Property | COLLATERAL property class |
| Collateral Appraisal Value | Property | Định giá TSĐB |
| Borrower | Involved Party | Customer với role = borrower |
| Guarantor | Involved Party | Customer với role = guarantor |
| Fund Availability Date | Arrangement | Ngày giải ngân đầu tiên |
| Maturity Date | Arrangement | Ngày đáo hạn |
