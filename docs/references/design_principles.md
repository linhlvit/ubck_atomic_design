# Nguyên tắc Thiết kế Atomic Layer — UBCK Lakehouse

**Cập nhật lần cuối:** 2026-06-01
**Ngữ cảnh:** Medallion Architecture (Bronze/Atomic/Gold) trên Delta Lake, nguồn chính T24 v23 AA

---

## 1. Nền tảng Khái niệm

**Kết luận nhanh:** Atomic layer = 3NF normalized + IBM BCV concepts làm semantic layer + SCD4A cho Fundamental entities. Không phải Data Vault, không phải dimensional model.

**Ba tầng trong Medallion:**

| Layer | Grain | Đặc điểm | Filter |
|---|---|---|---|
| Bronze | Raw 1:1 từ nguồn | MV/SV đã parsing. Gồm UNAUTH, RNAU | Không filter |
| Atomic | Chuẩn hóa 3NF, Enterprise view | Classification Value, Surrogate Key, SCD4A | Chỉ RECORD.STATUS = 'LIVE' |
| Gold | De-normalized cho báo cáo | Star Schema / Fact-Dim / OBT | Aggregated |

---

## 2. Quy tắc Thiết kế Cốt lõi (15 rules)

### R01 — Grain
Xác định rõ grain cho mỗi bảng trước khi thiết kế attribute. Grain = "1 dòng đại diện cho 1 ___". Ghi rõ trong HLD và LLD.

### R02 — Surrogate Key
Luôn tạo surrogate key trên Atomic. Không dùng @ID T24 làm PK. Pattern: `{entity_name}_id` (kiểu Surrogate Key).

### R03 — Pattern Id + Code
Mỗi FK đến Fundamental entity có cặp:
- `[Entity] Id` — surrogate key, dùng cho JOIN
- `[Entity] Code` — mã nghiệp vụ, lưu dư thừa để tra cứu không cần JOIN

```
Loan Arrangement Id   → FK đến Loan Arrangement (surrogate)
Loan Arrangement Code → @ID T24 (dư thừa, Text)
```

### R04 — Classification Value: chỉ Code, không tạo cặp Id+Code
Trường phân loại (Reference Data / Classification Value) chỉ lưu Code — không tạo cặp Id+Code. Tương tự với Currency Code.

```
✓ Đúng: loan_status_code (Classification Value, Scheme: LOAN_STATUS)
✗ Sai:  loan_status_id + loan_status_code
```

### R05 — Technical fields prefix ds_
Tất cả technical fields (audit, pipeline metadata) trên Atomic có prefix `ds_`:
- `ds_inputter`, `ds_authoriser`, `ds_input_timestamp`
- `ds_source_system`, `ds_batch_id`, `ds_load_timestamp`

### R06 — Tra cứu BCV trước khi gán Concept
Không suy luận BCV Concept từ tên bảng. Tra cứu trong `knowledge/` trước. Dùng `terms.csv` → `term_relationships.csv` → `reference_data_sets.csv`.

### R07 — Đặt tên Atomic entity
Pattern: `[Domain Prefix] + [BCV Term]`. Tất cả entity cùng nhóm nghiệp vụ phải chung prefix.

```
Loan Arrangement
Loan Party Role
Loan Transaction
Loan Payment
```

### R08 — Entity con tham chiếu entity cha
Tên entity cha phải là substring liên tục trong tên entity con.

```
✓ Đúng: "Loan Arrangement" → "Loan Arrangement Condition" (chứa "Loan Arrangement")
✗ Sai:  "Loan Arrangement" → "Loan Condition" (mất context)
```

### R09 — Condition vs Transaction
- **Condition** = quy tắc, biểu phí, chính sách — tĩnh, áp dụng trong khoảng thời gian
- **Transaction** = phát sinh thực tế — động, gắn timestamp cụ thể + số tiền thực tế

```
Phí phạt trả nợ trước hạn = 2% dư nợ  → Condition
Thu phí phạt 5,200,000 VND ngày 15/03  → Transaction
```

### R10 — Gộp entity khi hợp lý
Cấu trúc tương tự + ít trường → gộp, dùng Classification Value phân biệt. Tránh tạo quá nhiều entity tương tự nhau chỉ khác code type.

### R11 — Reference data set ≠ entity concept
Bảng chỉ có Code + Name, không có instance data, không có FK đến entity khác → Classification Value (reference data set), không phải Atomic entity.

### R12 — Không đưa logic khai thác vào Atomic
Atomic = Enterprise view, chuẩn hóa 3NF. Logic tổng hợp, tính toán, aggregation → Gold layer.

### R13 — LIVE only
Chỉ lấy RECORD.STATUS = 'LIVE' lên Atomic. Không lẫn UNAUTH, RNAU, simulation records.

### R14 — SCD Type 4A cho Fundamental entities
Fundamental entities (Involved Party, Product, v.v.) dùng SCD Type 4A:
- Bảng current: chỉ giữ version hiện tại
- Bảng history: lưu toàn bộ lịch sử thay đổi

### R15 — Natural key → Surrogate key
Khi tạo surrogate key từ T24 @ID: strip prefix nếu có, normalize format, hash hoặc sequence tùy convention dự án.

---

## 3. 12 Data Domain Chuẩn

| Data Domain | Mô tả | Ví dụ |
|---|---|---|
| Text | Chuỗi văn bản tự do | Tên, mô tả |
| Date | Ngày (không có giờ) | Effective Date, Maturity Date |
| Timestamp | Ngày giờ đầy đủ | Input timestamp |
| Monetary Amount | Số tiền có currency | Principal Amount |
| Interest Rate | Lãi suất | Lending Rate |
| Exchange Rate | Tỷ giá | FX Rate |
| Percentage | Tỷ lệ phần trăm | LTV Ratio |
| Surrogate Key | Khóa thay thế nội bộ | Customer Id |
| Classification Value | Giá trị phân loại/danh mục | Status Code, Type Code |
| Indicator | Chỉ báo 2 giá trị (Y/N) | Active Indicator |
| Boolean | True/False | Prepayment Penalty Flag |
| Small Counter | Số đếm nhỏ | Instalment Number |

---

## 4. Cách Tra cứu IBM BCV từ knowledge/

**Kết luận nhanh:** Dùng exact last-segment matching khi tra `part_of_terms` — không dùng substring match vì gây sai (603 → 82 attrs đúng).

**File quan trọng trong `knowledge/`:**

| File | Dùng để |
|---|---|
| `terms.csv` | Tra tên term, description, data type, quan hệ kế thừa |
| `term_relationships.csv` | Tra part_of, type_of, related relationships |
| `reference_data_sets.csv` | Tra Reference Data Set cho từng term |
| `reference_data_values.csv` | Tra các giá trị của Reference Data Set |
| `bpi_terms.csv` | Tra BPI/KPI chuẩn ngành |
| `business_scopes.csv` | Tra regulatory scope (Basel, FATCA, AML) |

**Query pattern đúng cho part_of_terms:**

```python
def is_direct_child(part_of_raw, concept_name):
    """Chỉ match khi concept_name là LAST SEGMENT trong path."""
    for path in part_of_raw.split(';'):
        if path.strip().split('>>')[-1].strip() == concept_name:
            return True
    return False
```

**Lý do:** `part_of_terms` chứa full path như `"Business Core Vocabulary >> Arrangement >> Loan Arrangement"`. Substring match `'Arrangement'` sẽ khớp cả `"Arrangement Activity"`, `"Arrangement Accounting Category"` → sai.

---

## 5. Cách Xử lý IBM BCV Term Relationships

Khi tra cứu một term (ví dụ `Loan Arrangement`), có 4 loại relationship:

| Relationship | Ý nghĩa | Cách dùng khi thiết kế |
|---|---|---|
| `part_of` (child terms) | Attributes trực tiếp của entity | **Dùng làm attribute candidates** — lấy full, không tự lọc |
| `type_of` upward (ancestors) | Entity cha trong hierarchy | **Lấy attributes của cha** — cũng là attributes của con (kế thừa) |
| `type_of` downward (subtypes) | Entity con — loại cụ thể hơn | **Xem attributes riêng của subtype** — vẫn 1 bảng, thêm attrs với ghi chú "chỉ áp dụng khi type = X" |
| `related` | Entities liên quan | **Căn cứ thiết kế entity liên quan** — không phải attributes trực tiếp |

**Ví dụ Loan Arrangement hierarchy:**

```
Arrangement (Ancestor-L4, 82 attrs)
  └── Product Arrangement (Ancestor-L3, 13 attrs)
        └── Account Arrangement (Ancestor-L2, 24 attrs)
              └── Finance Service Arrangement (Ancestor-L1, 139 attrs)
                    └── Loan Arrangement (Core, 49 attrs)
                          └── Mortgage Arrangement (Subtype-L1, 13 attrs)
                                └── Reverse Mortgage Arrangement (Subtype-L2, 0 attrs)
```

**Related terms của Loan Arrangement:**
- `Loan Arrangement Loan Officer` → không phải attribute, là entity concept → đưa vào `Loan Party Role` với role = LOAN_OFFICER
- `Loan Arrangement Adjustment Period` → kỳ điều chỉnh lãi suất → đưa vào `Interest Rate Condition`

---

## 6. Lỗi Phổ biến và Cách Tránh

| # | Lỗi | Cách tránh |
|---|---|---|
| 1 | Dùng @ID T24 làm PK Atomic | Luôn tạo surrogate key (R02) |
| 2 | Không filter RECORD.STATUS | Chỉ lấy LIVE (R13) |
| 3 | Gán BCV Concept sai do không tra cứu | Tra `knowledge/` trước (R06) |
| 4 | Nhầm Reference Data Set với entity concept | Kiểm tra: chỉ có Code + Name + không có FK? → Classification Value (R11) |
| 5 | Entity con đặt tên không chứa tên cha | Kiểm tra substring (R08) |
| 6 | Prefix không nhất quán | Tất cả entity cùng domain = cùng prefix (R07) |
| 7 | Nhầm Condition và Transaction | Dùng rule: có timestamp thực tế + số tiền phát sinh? → Transaction (R09) |
| 8 | Đặt logic khai thác vào Atomic | Aggregation, calculation → Gold (R12) |
| 9 | Substring match khi tra part_of_terms | Dùng exact last-segment matching (Section 4) |
| 10 | Tạo cặp Id+Code cho Classification Value | Chỉ lưu Code (R04) |

---

## 7. Design Starter Pack — Cách Tạo

Starter Pack là bộ khung thiết kế pre-populated cho từng nghiệp vụ, giúp khách hàng không có kinh nghiệm modeling có thể review thay vì thiết kế từ đầu.

**Cấu trúc một Starter Pack (HTML):**

1. **Business Scoping Questions** — checklist tick để xác định scope
2. **Entity gợi ý** — chia Core / Classification Value / Extended, mỗi entity có grain rõ ràng
3. **Attribute template** — accordion theo tầng kế thừa BCV (Core → Subtype → Ancestor)
4. **Classification Value** — bảng scheme + ví dụ giá trị
5. **ERD diagram** — Mermaid render inline

**Nguyên tắc phân loại entity:**
- **Core entity**: có grain rõ, có instance data, có FK quan hệ
- **Classification Value**: chỉ Code + Name, dùng chung toàn hệ thống với `scheme_code` phân biệt
- **Extended entity**: có thể không có ở nguồn → badge "Extended" + ghi chú điều kiện

**File output:** `docs/starter-packs/{domain}_starter_pack.html`

**Hiện có:** `docs/starter-packs/loan_starter_pack.html` (Loan/Tín dụng)
