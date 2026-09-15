# SỔ TAY QUY TẮC KỸ THUẬT CHUYÊN SÂU DATAMART
## Quy Chuẩn Kiểm Định Lớp 2 (Attributes & Mô Hình) & Lớp 4 (Model & Master Registry)

---

## 1. Nguồn Tra Cứu Atomic Approved & Cấm Tuyệt Đối `Atomic_LinhLV`

Khi BA ghi nguồn dữ liệu trực tiếp bằng mã nguồn hệ thống (như `NHNCK.CERTIFICATE_RECORDS.FIELD` hoặc `IDS.data.field`), Reviewer bắt buộc phải tìm bảng và cột Atomic tương ứng theo đúng thứ tự ưu tiên:

### Thứ Tự Ưu Tiên 2 Nguồn Hợp Lệ:
| Thứ tự | Đường dẫn Thư mục Atomic | Ý nghĩa & Phạm vi áp dụng |
|---|---|---|
| **Ưu tiên 1 (Nguồn chính thức)** | `DataModel/Atomic/**/*.yaml` | Nguồn sự thật tối cao của kho Atomic DWH. Quét toàn bộ thư mục và các sub-directories. |
| **Ưu tiên 2 (Nguồn dự phòng)** | `DataModel/working/Atomic/lld/**/*.yaml` | Chỉ tra cứu khi Ưu tiên 1 không tìm thấy entity tương ứng. |

### Cấm Kỵ Tuyệt Đối:
- ❌ **TUYỆT ĐỐI CẤM tra cứu thư mục `DataModel/working/Atomic_LinhLV/`**: Đây là nhánh thử nghiệm cũ đã bị revert và hoàn toàn out-of-date. Mọi entity trong thư mục này không được coi là nguồn hợp lệ, dù cấu trúc tên file giống hệt.
- **Ngoại lệ:** Entity `cv` (Classification Value) là bảng danh mục phân loại dùng trực tiếp, không có file YAML riêng.
- Nếu không tìm thấy YAML nào ở cả 2 nguồn hợp lệ → Xác định là **Gap Atomic** (cần thiết kế bổ sung Atomic trước khi hoàn thiện Datamart).

### Quy Trình Verify Atomic YAML Thật Trước Khi Chấp Nhận READY:
Không tin tưởng mù quáng vào tên cột trong Attributes. Với mỗi bảng Fact/Dim đang review:
1. Mở file YAML của driving entity:
   ```bash
   grep -c "^  - name:" DataModel/Atomic/**/dm_atm_{entity}-*.yaml
   # Nếu không có, fallback:
   grep -c "^  - name:" DataModel/working/Atomic/lld/**/lld_*{entity}*.yaml
   ```
2. Liệt kê toàn bộ `physical_name` trong YAML approved.
3. Đối chiếu 1-1 với `atomic_column` trong Attributes.
4. Bất kỳ cột nào trong Attributes không xuất hiện trong YAML thật → Báo lỗi **🔴 Critical**, chuyển ngay về PENDING.

---

## 2. Quy Tắc Flatten Hoàn Toàn Xuống Atomic

Mọi biểu thức `etl_logic` trong Attributes phải tham chiếu trực tiếp tới bảng và cột của Atomic DWH. Tuyệt đối **không được** sử dụng cột của Datamart (`fct_*.col` hoặc `dim_*.col`) làm dữ liệu đầu vào, kể cả khi cột đó đã được tính sẵn trong cùng bảng mart.

### 2 Dấu Hiệu Vi Phạm Điển Hình:
1. **Tham chiếu cột mart:** Biểu thức chứa tên bảng mart (ví dụ: `fct_market_warning.warning_level_code`).
2. **Thiếu khai báo `join_atomic`:** Đếm số lượng bảng `atomic_table` distinct trong một bảng mart. Nếu có bảng phụ xuất hiện trong `atomic_table` mà không có dòng nào có `etl_logic_type = join_atomic` tương ứng → Bảng phụ chưa được định nghĩa JOIN SQL hợp lệ.

### Đoạn Mã Python Kiểm Tra Nhanh Missing Join:
```python
import csv

with open('Datamart/lld/datamart_attributes.csv', encoding='utf-8-sig') as f:
    rows = list(csv.reader(f))

tbl = 'fct_market_trade_event'  # Bảng cần kiểm tra
driving = 'dwh_security_trade_tr'  # Driving table
atomic_tables = set(r[12].strip() for r in rows[1:] if r[1] == tbl and r[12].strip() and r[12].strip() != driving)
join_atomic_tables = set(r[12].strip() for r in rows[1:] if r[1] == tbl and r[10].strip() == 'join_atomic')

missing = atomic_tables - join_atomic_tables
if missing:
    print(f"🔴 LỖI CRITICAL: Thiếu khai báo join_atomic cho các bảng: {missing}")
```

### Quy Tắc Phân Loại Biểu Thức:
- Có JOIN sang bảng Atomic khác driving table (dù kết hợp với driving) → Bắt buộc gán `etl_logic_type = join_atomic`.
- `computed` chỉ được dùng khi toàn bộ `etl_logic` chỉ tham chiếu driving table hoặc hàm tính toán thuần túy (như `SUBSTRING`, `COALESCE`, `CASE WHEN` nội bộ 1 bảng).

---

## 3. Quy Chuẩn Bộ Trường Kỹ Thuật SCD4A & Bộ Lọc ACTIVE

Toàn bộ kho dữ liệu Atomic và Datamart của dự án vận hành theo chuẩn SCD Type 4A (Snapshot Current + Historical Table).

### 3.1. Tiêu Chí `L2-SCD4A-TECH-FIELD` (Bộ Trường Kỹ Thuật Bắt Buộc)
Mọi bảng Dimension và Operational Fact áp dụng SCD4A bắt buộc phải có đầy đủ 5 trường kỹ thuật:
1. `ds_rcrd_st`: Trạng thái bản ghi (`ACTIVE` / `INACTIVE`), kiểu `VARCHAR(10)`.
2. `ds_eff_start_dt`: Ngày bắt đầu hiệu lực bản ghi, kiểu `DATE`.
3. `ds_eff_end_dt`: Ngày kết thúc hiệu lực bản ghi, kiểu `DATE`.
4. `ds_cdc_opr_cd`: Mã thao tác CDC (`I`, `U`, `D`), kiểu `VARCHAR(5)`.
5. `ds_load_ts`: Timestamp tải dữ liệu ETL, kiểu `TIMESTAMP`.
*(Đối với bảng Periodic Snapshot History, bổ sung trường khóa snapshot `ds_snpst_dt`).*

### 3.2. Tiêu Chí `L2-SCD4A-JOIN-FILTER` (Bộ Lọc Active Trong Mệnh Đề Join)
- Khi thực hiện truy vấn kết nối từ Fact/Bridge sang Dimension SCD4A hoặc kết nối giữa các bảng Atomic, **BẮT BUỘC** phải có điều kiện lọc bản ghi active:
  ```sql
  LEFT JOIN dim_security sec 
    ON fct.security_dim_id = sec.security_dim_id 
   AND sec.ds_rcrd_st = 'ACTIVE'
  ```
- **Hậu quả nếu thiếu:** Bảng Dimension SCD4A lưu trữ nhiều phiên bản lịch sử của cùng một thực thể. Nếu thiếu điều kiện `ds_rcrd_st = 'ACTIVE'`, câu lệnh JOIN sẽ gây ra hiện tượng nhân đôi số dòng (fan-out multiplication), làm sai lệch toàn bộ các chỉ số đo lường (Sum/Count) trên Fact.

---

## 4. Cơ Chế Bảo Vệ Entity Dùng Chung (SHARED Dimension) Tại Lớp 4

Khi thực hiện review và đồng bộ Model Registry (`Datamart/datamart_model.yaml`), Reviewer phải phân định rõ 2 loại Entity:

| Loại Entity | Tiêu chí Nhận diện | Nguồn Sự Thật (SSOT) | Quy Tắc Đồng Bộ |
|---|---|---|---|
| **Entity Riêng của Phân Hệ** | `module: "{MODULE}"` (ví dụ: TT, GSTT, GSDC) | Attributes Detail (`Datamart/lld/{MODULE}/*.csv`) | Cập nhật Model Registry khớp 1-1 theo Attributes detail của phân hệ đó. |
| **Entity Dùng Chung (SHARED)** | `module: "SHARED"` (ví dụ: `cdr_dt_dim`, `org_dim`, `securities_dim`, `account_dim`, `broker_dim`) | Model Registry Approved (`Datamart/datamart_model.yaml`) | **Nghiêm cấm tự ý ghi đè Registry!** Nếu Attributes của phân hệ đang review bị lệch type/cột so với Registry, BẮT BUỘC phải sửa file Attributes theo Registry. |

> 🔴 **CẢNH BÁO:** Mọi thay đổi về cấu trúc hoặc khóa chính của Dimension `SHARED` đều có thể gây lỗi dây chuyền (cross-module regression) trên toàn bộ hệ thống. Mọi điều chỉnh trên Entity SHARED bắt buộc phải qua quy trình RFC và được Data Architect phê duyệt.

---

## 5. Quy Chuẩn Đặt Tên Vật Lý (Physical Naming Exceptions)

### Nguồn Sự Thật Duy Nhất:
- Tệp tin: `system/rules/rule_physical_name_exceptions_datamart.csv`
- Chỉ những từ được liệt kê tường minh trong file này mới được phép viết tắt trong tên cột physical (`datamart_column`). Mọi từ khác bắt buộc phải dùng nguyên từ (full word).

### Nguyên Tắc Derive Tên Physical từ Logical Name:
1. Physical name phải được sinh trực tiếp từ **tên logical** (`datamart_attribute`).
2. Tuyệt đối **không được mở rộng** từ hoặc thay thế bằng từ đồng nghĩa:
   - *Sai:* Logical `Exam Score` → Physical `examination_score` (mở rộng sai).
   - *Đúng:* Logical `Exam Score` → Physical `exam_score`.
3. Kiểm tra tính nhất quán giữa Lớp 2 và Lớp 3: Cột `mart_column` trong file Detail Mapping phải khớp chính xác 100% với `datamart_column` trong file Attributes.

### Lệnh Grep Phát Hiện Từ Viết Tắt Trái Phép:
```bash
grep -E "\b(ctf|prac|trn|rcrd|org|nat|cty|dcsn|rslt|ases|issu|pcs|ovrl|scor|vln|actv|clss|dept|pos|emp|doc|ind)\b" Datamart/lld/datamart_attributes.csv
```

---

## 6. Phân Biệt Flow Metric vs Stock Metric (Chỉ Tiêu Tài Chính)

Khi phân hệ Datamart có các chỉ tiêu lấy từ Báo cáo tài chính (BCTC IDS EAV: `BCKQKD`, `BCDKT`...), Reviewer bắt buộc kiểm tra tính rõ ràng về bản chất thời gian:

| Bản chất Chỉ tiêu | Ý nghĩa Nghiệp vụ | Ví dụ Thực tế | Logic Xử lý Chuẩn |
|---|---|---|---|
| **Flow Metric** (Dòng tiền / Lũy kế) | Giá trị phát sinh trong 1 khoảng thời gian | Doanh thu thuần, Lợi nhuận sau thuế (LNST), Chi phí hoạt động | **TTM** (Trailing Twelve Months = Tổng 4 quý gần nhất) cho P/E, EPS; hoặc lũy kế kỳ báo cáo |
| **Stock Metric** (Số dư thời điểm) | Giá trị tại một mốc thời điểm kết thúc kỳ | Vốn chủ sở hữu (VCSH), Tổng tài sản, Tiền gửi khách hàng | **Quý gần nhất** (`ROW_NUMBER() OVER (ORDER BY report_year DESC, report_quarter DESC) = 1`) |

### Quy Tắc Kiểm Định:
- Cấm ghi chung chung là "chưa xác định" trong HLD.
- Fact table phải tách riêng các cột measure theo bản chất thời gian (ví dụ: `net_profit_after_tax_ttm` cho Flow vs `owner_equity_latest` cho Stock).

---

## 7. Giao Thức Bảo Toàn Toàn Vẹn CSV Sau Batch Edit

Khi cập nhật hàng loạt trên file CSV (bằng script Python, sed hoặc replace), các trường văn bản chứa dấu phẩy `,` rất dễ làm vỡ cấu trúc cột nếu không được quote kép (`"..."`).

Reviewer bắt buộc chạy đoạn mã kiểm tra sau mỗi lần cập nhật file CSV:
```python
import csv

def verify_csv_integrity(filepath: str):
    with open(filepath, 'r', encoding='utf-8-sig', errors='replace') as f:
        reader = csv.reader(f)
        header = next(reader, None)
        if not header:
            print(f"❌ File rỗng: {filepath}")
            return False
        
        expected_len = len(header)
        bad_rows = []
        for idx, row in enumerate(reader, start=2):
            if len(row) != expected_len:
                bad_rows.append((idx, len(row), row[:3]))
        
        if bad_rows:
            print(f"❌ LỖI VỠ CỘT CSV ({filepath}): {len(bad_rows)} dòng không khớp độ dài {expected_len}:")
            for b in bad_rows[:5]:
                print(f"   Dòng {b[0]}: có {b[1]} cột (Mẫu: {b[2]})")
            return False
        
        print(f"✅ CSV Integrity Verified: {filepath} ({expected_len} cột chuẩn)")
        return True
```

---

## 8. Quy Chuẩn Đối Soát Orphan Entity & Table 3 Chiều (LLD ↔ HLD ↔ Flat Table)

### 8.1. Bản Chất 3 Chiều (Bắt Buộc Thay Thế Quan Điểm 2 Chiều Cũ)
Trước đây, quy trình review chỉ so sánh 2 chiều giữa LLD Attributes và Flat Table DDL, đồng thời mặc định hướng xử lý duy nhất là xóa bỏ (Cleanup). Trong kiến trúc Datamart hoàn chỉnh của dự án UBCKNN, sự tồn tại của một thực thể dữ liệu phân tích bắt buộc phải được xác lập đồng bộ qua ma trận 3 chiều:

$$\text{Tier A: LLD Attributes CSV} \iff \text{Tier B: HLD Entities (CSV/MD)} \iff \text{Tier C: Flat Table SQL (DDL/DML)}$$

- **Tier A (LLD Attributes):** Tệp tin CSV chi tiết thuộc tính tại `Datamart/lld/{MODULE}/DTM_{MODULE}_*.csv`.
- **Tier B (HLD Entities):** Bảng danh mục thực thể tại `Datamart/hld/DTM_{MODULE}_Entities.csv` và mô tả thực thể trong Section 3 & Section 4 Reuse Analysis của `DTM_{MODULE}_HLD.md`.
- **Tier C: Flat Table SQL:** Câu lệnh DDL tạo bảng `CREATE TABLE` trong `Datamart/flat-table/{MODULE}/01_create_*.sql` và DML nạp dữ liệu `INSERT INTO ... SELECT` trong `02_populate_*.sql`.

Một thực thể Fact hoặc Operational chỉ được nghiệm thu hoàn tất khi hiện diện nhất quán trên cả 3 tầng này.

### 8.2. Ma Trận 3 Chiều & Hai Nhánh Xử Lý Chuẩn Hóa
Khi phát hiện một thực thể mồ côi (xuất hiện ở 1 hoặc 2 tầng nhưng vắng mặt ở tầng còn lại), Reviewer **TUYỆT ĐỐI KHÔNG ĐƯỢC MẶC ĐỊNH XÓA (CLEANUP)** mà phải căn cứ vào giá trị nghiệp vụ thực tế của bảng để phân định chính xác theo 1 trong 2 nhánh:

```
                          [PHÁT HIỆN ORPHAN ENTITY]
                                      │
              ┌───────────────────────┴───────────────────────┐
              │ Bảng có còn giá trị nghiệp vụ khai thác không? │
              │ (Có ≥1 KPI READY trong HLD / Detail Mapping?) │
              └───────────────────────┬───────────────────────┘
                           CÓ         │         KHÔNG
              ┌───────────────────────┘         └───────────────────────┐
              ▼                                                         ▼
     [NHÁNH A: HOÀN TẤT PHẦN THIẾU]                             [NHÁNH B: DỌN DẸP TOÀN DIỆN]
     (Entity còn giá trị, bị bỏ sót)                           (Entity bị hủy/thay thế/lỗi thời)
              │                                                         │
  ┌───────────┴───────────┐                                 ┌───────────┴───────────┐
  │ Mã: L2-ORPHAN-3WAY-   │                                 │ Mã: L2-ORPHAN-3WAY-   │
  │     INCOMPLETE        │                                 │     ABANDONED         │
  │ - Thêm vào Entities   │                                 │ Áp dụng 5 bước của    │
  │   (.csv & .md) nếu    │                                 │ All-Tier Cleanup      │
  │   thiếu tầng HLD.     │                                 │ Protocol:             │
  │ - Sinh CREATE +       │                                 │ 1. Xóa LLD file       │
  │   POPULATE flat table │                                 │ 2. Purge master CSV   │
  │   nếu thiếu Phase 3.  │                                 │ 3. Sửa Detail Mapping │
  │ - TUYỆT ĐỐI KHÔNG XÓA │                                 │ 4. Purge Model YAML   │
  └───────────────────────┘                                 │ 5. Update HLD Reuse   │
                                                            └───────────────────────┘
```

#### 🔹 Nhánh A: Hoàn Tất Phần Còn Thiếu (Incomplete Implementation)
- **Điều kiện kích hoạt:** Bảng có ≥1 KPI READY trong HLD hoặc Detail Mapping, bảng mang giá trị nghiệp vụ thực tế nhưng bị bỏ sót trong quá trình chuyển tiếp giữa các Phase thiết kế (điển hình: `fct_foreign_trading_min_snpst` của GSTT, hoặc 2 Fact violation của TT).
- **Mã lỗi kỹ thuật:** `🔴 Critical: [L2-ORPHAN-3WAY-INCOMPLETE]`.
- **Hành động bắt buộc:** **TUYỆT ĐỐI KHÔNG XÓA FILE LLD HOẶC ATTRIBUTES CỦA BẢNG!**
  1. *Nếu thiếu ở HLD Entities (Tier B):* Gọi `datamart-hld-design` bổ sung dòng mô tả thực thể vào `DTM_{MODULE}_Entities.csv`, đồng thời cập nhật Section 3 và Section 4 (Reuse Analysis) trong `DTM_{MODULE}_HLD.md`.
  2. *Nếu thiếu ở Flat Table SQL (Tier C):* Gọi `datamart-lld-design` (Phase 3) sinh câu lệnh `CREATE TABLE` trong `01_create_*.sql` và câu lệnh `INSERT INTO ... SELECT` trong `02_populate_*.sql`.

#### 🔹 Nhánh B: Dọn Dẹp Toàn Diện Khi Entity Bị Hủy (Abandoned Entity)
- **Điều kiện kích hoạt:** Bảng đã bị hủy bỏ, thay thế, hoặc có 0 KPI READY (toàn bộ chỉ tiêu phụ thuộc đã chuyển sang bảng khác hoặc bị BA đánh dấu `Delete`), nhưng tệp tin LLD CSV hoặc dòng định nghĩa vẫn còn sót lại (điển hình: `fct_public_company_shareholding` của GSTT sót trong Entities.csv).
- **Mã lỗi kỹ thuật:** `🟡 Warning / 🔴 Critical: [L2-ORPHAN-3WAY-ABANDONED]`.
- **Hành động bắt buộc (Giao thức All-Tier Cleanup Protocol 5 Bước):**
  1. *Bước 1 (LLD Module):* Xóa tệp tin CSV mồ côi `Datamart/lld/{MODULE}/DTM_{MODULE}_{table}.csv`.
  2. *Bước 2 (Master Registry CSV):* Purge toàn bộ các dòng thuộc tính của bảng khỏi `Datamart/lld/datamart_attributes.csv`.
  3. *Bước 3 (Detail Mapping):* Xóa bỏ hoặc chuyển trạng thái `RETIRED` toàn bộ các dòng tham chiếu bảng trong `Datamart/lld/DTM_{MODULE}_Detail_Mapping.csv`.
  4. *Bước 4 (Model Registry YAML):* Purge định nghĩa entity khỏi `Datamart/datamart_model.yaml` (trừ khi là SHARED Dimension).
  5. *Bước 5 (HLD Entities & Reuse):* Xóa dòng entity trong `DTM_{MODULE}_Entities.csv` và cập nhật Section 4 Reuse Analysis trong `DTM_{MODULE}_HLD.md`.

### 8.3. Xử Lý Các Trường Hợp Ngoại Lệ Hợp Lệ (Whitelisted Exceptions)
Reviewer và script kiểm tra cần loại trừ false positive cho các trường hợp:
- **Dimension Dùng Chung (`module: "SHARED"`):** Các Dimension dùng chung (`cdr_dt_dim`, `org_dim`, `securities_dim`, `account_dim`, `broker_dim`) thuộc quyền quản lý tập trung, không nhất thiết phải có file LLD riêng trong từng module hay có flat table độc lập.
- **Dimension Denormalized:** Các bảng Dimension được denormalize (inline) trực tiếp vào Flat Table của Fact mà không tạo bảng Flat Table Dimension riêng.
- **Thực Thể Tái Sử Dụng (`reuse_status = 'reuse'`):** Bảng thuộc module khác đã được sinh Flat Table ở module nguồn; module hiện tại chỉ tái sử dụng khai thác.

### 8.4. Lệnh CLI Tự Động Hóa Kiểm Tra
```bash
# Kiểm tra cho một phân hệ cụ thể:
python scripts/check_orphan.py --module [MODULE] [--strict]

# Quét toàn bộ repository:
python scripts/check_orphan.py --module all [--strict]
```

---

## 9. Quy Chuẩn Bảo Vệ Master Registry & Đối Soát etl_logic Content Parity

### 9.1. Vai Trò Tối Cao Của Master Registry `datamart_attributes.csv`
Tệp tin `Datamart/lld/datamart_attributes.csv` là Master Data Registry tập trung — nguồn sự thật tối cao (Single Source of Truth) lưu trữ toàn bộ thuộc tính của toàn bộ hệ thống Datamart. Tất cả các pipeline sinh code ETL, trình phân tích schema cross-module và các tác vụ khai thác tự động đều đọc trực tiếp từ master registry này.

### 9.2. Cơ Chế Phát Sinh Lỗi và Hậu Quả Sai Lệch Logic (Drift)
- Khi thực hiện sửa lỗi kỹ thuật theo Kịch bản C (sửa điều kiện JOIN, sửa filter WHERE, sửa cú pháp format thời gian, bổ sung active filter `ds_rcrd_st = 'ACTIVE'`), developer thường chỉ chỉnh sửa file LLD chi tiết của module (`Datamart/lld/{MODULE}/DTM_{MODULE}_*.csv`) mà **quên đồng bộ ngược lại vào master `datamart_attributes.csv`**.
- Vì tên bảng và tên cột không đổi, các bài kiểm tra số lượng cột hoặc schema truyền thống hoàn toàn bỏ lọt lỗi. Logic cũ bị sai lệch âm thầm tiếp tục tồn tại trong master registry, gây hậu quả nghiêm trọng khi hệ thống sinh mã ETL hoặc khi các module khác tích hợp.

### 9.3. Tiêu Chuẩn Byte-for-Byte Content Parity
Mọi thuộc tính xuất hiện đồng thời trong file module attributes và master registry bắt buộc phải tuân thủ chuẩn đối soát nội dung tuyệt đối:
- Khóa định danh dòng: Cặp `(datamart_table, datamart_column)` hoặc `(datamart_entity, datamart_attribute)`.
- Chuỗi biểu thức `etl_logic` sau khi chuẩn hóa (loại bỏ khoảng trắng đầu/cuối `.strip()`, chuẩn hóa ký tự ngắt dòng `\r\n` thành `\n`) **BẮT BUỘC PHẢI KHỚP NHAU 100% (BYTE-FOR-BYTE PARITY)**.
- Nghiêm cấm mọi sai lệch dù là nhỏ nhất: cắt cụt cú pháp (như `FORMAT(:etl_date` thiếu ngoặc), lệch điều kiện `JOIN` vs `LEFT JOIN`, thiếu filter `WHERE`, hay lệch biểu thức tính toán phái sinh.

### 9.4. Cơ Chế Chặn Cứng Bắt Buộc (Strict Blocking Mechanism)
- **Mã lỗi kỹ thuật:**
  - `🔴 Critical: [L2-ETL-LOGIC-PARITY-MISMATCH]`: Lệch nội dung chuỗi `etl_logic` giữa file module và master registry.
  - `🔴 Critical: [L4-MASTER-REGISTRY-OUT-OF-SYNC]`: Thiếu dòng thuộc tính trong master registry hoặc master registry chứa dòng mồ côi đã bị xóa ở module.
- **Quy tắc chặn cứng (Blocker):** Reviewer BẮT BUỘC **từ chối nghiệm thu, từ chối mở Gate 1 / Gate 2, và chặn hoàn toàn việc bàn giao (Handover / Pull Request)** nếu phát hiện bất kỳ sự sai lệch nào về `etl_logic` giữa module và master registry.

### 9.5. Quy Trình Đồng Bộ 3 Bước Bắt Buộc Khi Sửa Kịch Bản C
Mỗi khi phát sinh chỉnh sửa kỹ thuật trên tệp tin Attributes của phân hệ, Reviewer và Developer bắt buộc thực thi nghiêm ngặt 3 bước sau:

1. **Bước 1 (Edit Module File):** Cập nhật biểu thức `etl_logic` chuẩn xác trên tệp tin phân hệ `Datamart/lld/{MODULE}/DTM_{MODULE}_*.csv`.
2. **Bước 2 (Sync Master Registry):** Đồng bộ chính xác 1-1 chuỗi `etl_logic` đã sửa sang dòng tương ứng trong `Datamart/lld/datamart_attributes.csv`.
3. **Bước 3 (CLI Verification Gate):** Chạy công cụ kiểm tra tự động với cờ `--strict`:
   ```bash
   python scripts/check_parity.py --module [MODULE] --strict
   ```
   Chỉ khi công cụ trả về exit code 0 (`0 mismatch, 100% Parity PASS`) mới được phép tuyên bố hoàn thành sửa lỗi và chuyển sang bước tiếp theo.

### 9.6. Lệnh CLI Tự Động Hóa Kiểm Tra Parity
```bash
# Kiểm tra parity cho một module:
python scripts/check_parity.py --module [MODULE] [--strict]

# Quét toàn bộ repository:
python scripts/check_parity.py --module all [--strict]
```

---

## 10. Quy Chuẩn Kiểm Soát Grain & Chống Sao Chép Công Thức Lệch Hạt (Grain Mismatch)

### 10.1. Bản Chất Kỹ Thuật & Nguyên Lý Kimball
Theo nguyên lý Kimball trong thiết kế Data Warehouse / Datamart, Grain (cấp độ hạt) là định nghĩa cốt lõi trả lời câu hỏi: *"Một dòng dữ liệu đại diện chính xác cho đối tượng/sự kiện gì?"*.
Trong hệ thống Datamart báo cáo, cần phân định nghiêm ngặt giữa hai cấp độ Grain:
1. **Grain Lưu Trữ (Storage Grain):** Cấp độ chi tiết của bản ghi trong bảng Fact hoặc Operational, được định danh bởi tập hợp các khóa chính / khóa tự nhiên (ví dụ: 1 dòng = 1 mã chứng khoán × 1 ngày giao dịch).
2. **Grain Trình Diễn (Presentation / Visualization Grain):** Cấp độ chi tiết của đối tượng xuất hiện trên giao diện báo cáo / dashboard (ví dụ: 1 dòng trên bảng = 1 mã chứng khoán; hoặc 1 dòng = 1 rổ chỉ số; hoặc 1 dòng = 1 công ty chứng khoán).

**Cơ chế phát sinh lỗi Grain Mismatch:**
Hiện tượng Grain Mismatch xảy ra khi một chỉ tiêu đo lường được định nghĩa hoặc tái sử dụng (Reuse) từ một nhóm khác có tên gọi tương tự, nhưng cấp độ hạt trong biểu thức tổng hợp (`GROUP BY`, `PARTITION BY`, hoặc Grain của Fact nguồn) không tương thích với cấp độ hạt của đối tượng hiển thị. Khi đó, câu lệnh SQL vẫn hoàn toàn hợp lệ về mặt cú pháp và metadata, vượt qua 100% các bài kiểm tra tự động, nhưng dữ liệu trả về trên giao diện báo cáo hoàn toàn sai lệch bản chất nghiệp vụ.

### 10.2. Ma Trận Phân Cấp Hạt Nghiệp Vụ (Business Grain Hierarchy)
Reviewer bắt buộc đối soát cấp độ hạt theo thang phân cấp thứ bậc chuẩn trong thị trường chứng khoán:

| Cấp Độ Hạt (Grain Level) | Thực Thể Đại Diện | Khóa Định Danh Chính | Ví Dụ Bảng Fact / Dim Nguồn |
|---|---|---|---|
| **Level 1 — Cấp Sàn Giao Dịch** | Toàn bộ sàn giao dịch (HOSE, HNX, UPCOM) | `floor_code` / `exchange_code` | `fct_market_trading_summary_snpst` |
| **Level 2 — Cấp Rổ Chỉ Số** | Chỉ số thị trường (VN-Index, VN30, HNX30) | `index_code` | `fct_index_trading_snpst`, `fct_index_constituent_snpst` |
| **Level 3 — Cấp Ngành / Lĩnh Vực** | Ngành cấp 1, cấp 2 (Ngân hàng, Bất động sản...) | `industry_code` / `business_line_code` | `fct_industry_market_summary_snpst` |
| **Level 4 — Cấp Mã Chứng Khoán / DN** | Từng cổ phiếu niêm yết (VCB, FPT, VIC...) | `symbol` / `public_company_id` | `fct_stock_portfolio_snpst`, `dim_security` |
| **Level 5 — Cấp Định Chế / CTCK** | Công ty chứng khoán thành viên (SSI, VPS...) | `sc_firm_id` / `member_code` | `fct_securities_company_financial_snpst` |
| **Level 6 — Cấp Tài Khoản / Giao Dịch** | Lệnh đặt, giao dịch khớp lệnh từng NĐT | `account_number`, `order_id`, `trade_id` | `opr_foreign_investor_trading_detail_rpt` |

### 10.3. Quy Trình Thẩm Định Grain 3 Bước Dành Cho Reviewer
Khi review bất kỳ nhóm chỉ tiêu nào, Reviewer bắt buộc thực thi quy trình 3 bước:
1. **Bước 1 (Đọc Mockup & Cột Liền Kề):** Trả lời câu hỏi: *"Một dòng kết quả trên giao diện của nhóm này đại diện cho 1 đối tượng gì?"*. Nhìn vào các cột Dimension/Slicer đứng cạnh:
   - Đứng cạnh "Mã CK", "Tên công ty", "Số CP lưu hành" $\implies$ Grain bắt buộc là Cấp Mã CK (Level 4 - `symbol`).
   - Đứng cạnh "Mã chỉ số", "Tên chỉ số", có nhãn "(theo Chỉ số)" $\implies$ Grain là Cấp Chỉ Số (Level 2 - `index_code`).
   - Đứng cạnh "Tên sàn", "Sở GDCK" $\implies$ Grain là Cấp Sàn (Level 1 - `floor_code`).
2. **Bước 2 (Kiểm tra Fact Source):** Bảng Fact nguồn trong `mart_table` có hỗ trợ grain này không? Nếu nhóm hiển thị cấp Cổ phiếu mà chọn Fact cấp Chỉ số hoặc cấp Sàn để map trực tiếp $\implies$ Sai kiến trúc ngay từ HLD.
3. **Bước 3 (Đối chiếu GROUP BY / PARTITION BY trong Logic):** Danh sách cột trong mệnh đề gom nhóm `GROUP BY` hoặc phân đoạn `PARTITION BY` trong cột `logic` bắt buộc phải chứa đúng khóa định danh của đơn vị xác định ở Bước 1.

### 10.4. Quy Tắc Kiểm Soát Aggregate Khi Reuse & Mã Lỗi Kỹ Thuật
1. **Nguyên tắc Đồng Hạt (Iso-Grain Rule):** Mọi trường được đưa vào danh sách cột hiển thị (không aggregate) phải thuộc cùng một cấp độ hạt hoặc cấp độ hạt cha trực tiếp (quan hệ 1-to-N).
2. **Kiểm Soát Khi Reuse Công Thức:** Khi một dòng KPI có `ghi_chu` ghi `"Reuse từ Nhóm X"`:
   - Mở mockup của CẢ Nhóm X (nhóm gốc) và Nhóm hiện tại.
   - Nếu Nhóm X là Level 2 (Index) và Nhóm hiện tại là Level 4 (Symbol) $\implies$ **TUYỆT ĐỐI CẤM copy nguyên cột `mart_column` hay biểu thức `logic`**. Bắt buộc phải viết lại công thức tổng hợp theo đúng khóa của Level 4 (`symbol`).
3. **Mã lỗi kỹ thuật:**
   - `🔴 Critical: [L1-GRAIN-MISMATCH]`: Lệch cấp độ hạt ở tầng thiết kế HLD.
   - `🔴 Critical: [L3-GRAIN-MISMATCH]`: Lệch cấp độ hạt ở tầng Detail Mapping (mệnh đề `GROUP BY` / `PARTITION BY` sai đơn vị hiển thị).

### 10.5. Ví Dụ Đối Chiếu Thực Tế Đúng vs Sai (Case Study `K_GSTT_61` - Vốn Hóa Thị Trường)

#### ❌ SAI (Wrong Implementation):
```sql
-- Detail Mapping logic tại Nhóm 7 (Bảng Top khối lượng theo sàn — hiển thị từng Mã CK):
-- Sai lầm: Copy nguyên công thức từ Nhóm 6 (nhóm rổ chỉ số)
MAX(fct_index_constituent_snpst.idx_market_cap) 
FROM fct_index_constituent_snpst 
JOIN index_constituent_dim ON index_constituent_dim.index_constituent_dim_id = fct_index_constituent_snpst.index_constituent_dim_id 
GROUP BY index_constituent_dim.index_code, cdr_dt_dim.cdr_dt

-- HẬU QUẢ: Dòng hiển thị mã VCB nhưng Vốn hóa lại hiển thị 3.200.000 tỷ VNĐ (Vốn hóa của cả rổ VN30)!
```

#### ✅ ĐÚNG (Right Implementation):
```sql
-- Detail Mapping logic tại Nhóm 7 (Grain hiển thị: Symbol x Trading Date):
-- Công thức đúng: Tính vốn hóa của CHÍNH MÃ CHỨNG KHOÁN ĐÓ
MAX(security_trading_snpst_dim.close_price * fct_stock_portfolio_snpst.outstanding_share_quantity) 
GROUP BY security_trading_snpst_dim.symbol, cdr_dt_dim.cdr_dt

-- KẾT QUẢ: Dòng hiển thị mã VCB hiển thị đúng Vốn hóa riêng của VCB (~450.000 tỷ VNĐ).
```

---

## 11. Quy Chuẩn Thiết Kế Window Functions & Khung Thời Gian Đỉnh/Đáy

### 11.1. Nguyên Tắc Đếm Phiên Giao Dịch (Trading Sessions vs Calendar Days)
Thị trường chứng khoán Việt Nam (HOSE/HNX) chỉ giao dịch từ thứ Hai đến thứ Sáu, nghỉ thứ Bảy, Chủ nhật và các ngày lễ theo luật định. Do đó, chuỗi thời gian phân tích thị trường có các khoảng trống (gap) lịch tự nhiên.
- **CẤM:** Dùng hàm khoảng cách thời gian theo ngày lịch (`INTERVAL '52' WEEK`, `INTERVAL '6' MONTH`, `INTERVAL '1' YEAR` hoặc `D - INTERVAL`). Sử dụng ngày lịch sẽ bỏ sót hoặc nhảy cóc số phiên thực tế khi join.
- **BẮT BUỘC:** Sử dụng Window Function với khung cửa sổ hàng (`ROWS BETWEEN (N-1) PRECEDING AND CURRENT ROW`) trên chuỗi dữ liệu đã được sắp xếp tăng dần theo ngày giao dịch (`ORDER BY trading_date ASC`).

### 11.2. Bảng Quy Đổi Chu Kỳ Chuẩn Trên Thị Trường Chứng Khoán Việt Nam
Reviewer bắt buộc đối soát số phiên lookback theo bảng quy chuẩn:

| Khung Thời Gian BA | Cơ Sở Tính Toán Quy Ước | Số Phiên Chuẩn | Mệnh Đề SQL Window Frame Chuẩn |
|---|---|---|---|
| **52 tuần gần nhất (~1 năm)** | 52 tuần × 5 phiên/tuần | **260 phiên** | `ROWS BETWEEN 259 PRECEDING AND CURRENT ROW` |
| **6 tháng gần nhất (~2 quý / 26 tuần)** | 26 tuần × 5 phiên/tuần | **130 phiên** | `ROWS BETWEEN 129 PRECEDING AND CURRENT ROW` |
| **3 tháng gần nhất (~1 quý / 13 tuần)** | 13 tuần × 5 phiên/tuần | **65 phiên** | `ROWS BETWEEN 64 PRECEDING AND CURRENT ROW` |
| **1 tháng / 4 tuần gần nhất** | 4 tuần × 5 phiên/tuần | **20 phiên** | `ROWS BETWEEN 19 PRECEDING AND CURRENT ROW` |
| **20 phiên gần nhất (MA20 / Đột phá)** | 20 phiên giao dịch liên tiếp | **20 phiên** | `ROWS BETWEEN 19 PRECEDING AND CURRENT ROW` |
| **10 phiên gần nhất (MA10)** | 10 phiên giao dịch liên tiếp | **10 phiên** | `ROWS BETWEEN 9 PRECEDING AND CURRENT ROW` |
| **5 phiên gần nhất (MA5 / 1 tuần)** | 5 phiên giao dịch liên tiếp | **5 phiên** | `ROWS BETWEEN 4 PRECEDING AND CURRENT ROW` |

*Lưu ý Edge Case:* Với mã cổ phiếu mới niêm yết chưa đủ số phiên quy định (ví dụ mới giao dịch 50 phiên), khung `ROWS BETWEEN 259 PRECEDING AND CURRENT ROW` trong chuẩn SQL sẽ tự động lấy toàn bộ số phiên có sẵn từ phiên đầu tiên đến phiên hiện tại, không gây lỗi runtime.

### 11.3. Chuẩn Hóa Lựa Chọn Trường Giá (`close_price` vs `high_price` / `low_price`)
1. **Giá Đóng Cửa (`close_price`):**
   - Bắt buộc áp dụng cho 100% các báo cáo thống kê định giá chính thức của UBCKNN / Sở GDCK (ví dụ: mẫu báo cáo `BM021_MSS`).
   - Bắt buộc áp dụng cho các chỉ tiêu đỉnh/đáy 52 tuần, 6 tháng, 3 tháng dùng để so sánh tương quan định giá P/E, P/B.
   - *Lý do kinh tế:* Giá đóng cửa chốt phiên theo đợt khớp lệnh định kỳ đóng cửa (ATC) thể hiện mức giá cân bằng đồng thuận của thị trường, loại bỏ hoàn toàn các mức giá đột biến ảo (intraday tail noise / spike) do giao dịch lô lẻ hoặc lệnh quét tạm thời.
2. **Giá Cao Nhất / Thấp Nhất Trong Phiên (`high_price` / `low_price`):**
   - Chỉ sử dụng khi tài liệu BA analyst yêu cầu tường minh: *"Giá cao nhất/thấp nhất trong phiên (Intraday Extreme)"* hoặc phục vụ dựng biểu đồ nến kỹ thuật (Candlestick: Open, High, Low, Close).
   - Bảng Fact nguồn bắt buộc phải lưu trữ chuỗi `high_price` và `low_price` theo từng ngày giao dịch.

### 11.4. Yêu Cầu Lưu Trữ Kiến Trúc: Fact Periodic Snapshot vs SCD4A Dimension
- **Bẫy Lưu Trữ Thường Gặp:** Áp dụng hàm Window Function lên bảng Dimension SCD4A current-state (ví dụ: `MAX(security_trading_snpst_dim.close_price) OVER (...)`).
- **Nguyên Nhân Sai:** Dimension current-state chỉ lưu duy nhất 1 bản ghi của ngày hôm nay cho mỗi mã cổ phiếu. Hàm Window Function chạy trên 1 dòng duy nhất sẽ chỉ trả về chính giá ngày hôm nay, vô hiệu hóa hoàn toàn ý nghĩa lịch sử!
- **Kiến Trúc Bắt Buộc:** Mọi trường dữ liệu chuỗi thời gian làm nguồn cho Window Function bắt buộc phải nằm trên bảng **Fact Periodic Snapshot** (`fct_*_snpst`) có lưu trữ theo từng ngày giao dịch (`grain: 1 row / symbol / trade_date`).
- **Mã lỗi kỹ thuật:** `🔴 Critical: [L2-WINDOW-STORAGE-INVALID]` (ở Lớp 2) và `🔴 Critical: [L3-FORMULA-WINDOW-MISMATCH]` (ở Lớp 3).

### 11.5. Cấu Trúc Phân Đoạn Bắt Buộc Trong Window Function
Mọi biểu thức Window Function trên chuỗi thời gian bắt buộc phải có đủ 3 thành phần:
1. `PARTITION BY <entity_key>`: Bắt buộc phân đoạn theo khóa thực thể (ví dụ: `PARTITION BY security_trading_snpst_dim.symbol`). Nếu thiếu `PARTITION BY`, hàm `MAX() OVER (...)` sẽ tính đỉnh/đáy trên toàn bộ chuỗi giá của MỌI cổ phiếu trong kho dữ liệu bị xếp lẫn lộn theo ngày!
2. `ORDER BY <date_key> ASC`: Sắp xếp tăng dần theo ngày giao dịch.
3. `ROWS BETWEEN (N-1) PRECEDING AND CURRENT ROW`: Khung cửa sổ số phiên.

### 11.6. Ví Dụ Đối Chiếu Thực Tế Đúng vs Sai (Giá Cao Nhất 52 Tuần)

#### ❌ SAI (Wrong Implementation):
```sql
-- Sai lầm 1: Lấy từ Dimension current-state (chỉ có 1 dòng hôm nay, window function vô nghĩa)
-- Sai lầm 2: Lấy high_price trong phiên thay vì close_price theo quy định BA BM021_MSS
-- Sai lầm 3: Lùi theo ngày lịch INTERVAL '52' WEEK
MAX(security_trading_snpst_dim.high_price) 
OVER (
    PARTITION BY security_trading_snpst_dim.symbol 
    ORDER BY cdr_dt_dim.cdr_dt 
    RANGE BETWEEN INTERVAL '52' WEEK PRECEDING AND CURRENT ROW
)
```

#### ✅ ĐÚNG (Right Implementation):
```sql
-- Đúng 1: Lấy từ Fact Periodic Snapshot có lưu chuỗi giá đóng cửa theo từng ngày
-- Đúng 2: Trường giá là close_price theo chuẩn BA BM021_MSS
-- Đúng 3: Khung cửa sổ đúng 260 phiên giao dịch (259 phiên trước + phiên hiện tại)
MAX(fct_stock_portfolio_snpst.close_price) 
OVER (
    PARTITION BY security_trading_snpst_dim.symbol 
    ORDER BY cdr_dt_dim.cdr_dt ASC 
    ROWS BETWEEN 259 PRECEDING AND CURRENT ROW
)
```

---

## 12. Quy Chuẩn Nhất Quán Chu Kỳ Thời Gian Trong Tỷ Số Tài Chính

### 12.1. Bản Chất Kế Toán & Phân Loại Biến Số
Khi thiết kế các tỷ số tài chính (Financial Ratios) trong Datamart, Reviewer bắt buộc phân loại các biến số thành phần theo đúng nguyên lý kế toán:
- **Biến Số Dòng Tiền / Thời Kỳ (Flow Variables):** Lấy từ Báo cáo Kết quả Hoạt động Kinh doanh (`BCKQKD`). Giá trị phản ánh phát sinh tích lũy trong một khoảng thời gian (1 Quý, 6 Tháng, Cả năm). Ví dụ: Lợi nhuận sau thuế (`LNST` / `net_profit_after_tax`), Doanh thu thuần (`Revenue`).
- **Biến Số Thời Điểm / Số Dư (Stock Variables):** Lấy từ Bảng Cân đối Kế toán (`BCDKT`). Giá trị phản ánh số dư tại một thời điểm khóa sổ (Cuối quý, Cuối năm). Ví dụ: Vốn chủ sở hữu (`VCSH` / `owner_equity`), Tổng tài sản (`Total Assets`).
- **Biến Số Khối Lượng Cổ Phiếu (Share Volume):** Số lượng cổ phiếu đang lưu hành (`outstanding_share_quantity`). Có thể biến động theo thời gian do phát hành, trả cổ tức, hoặc mua lại cổ phiếu quỹ.

**Nguyên Tắc Ghép Cặp Nhất Quán (Time Horizon Consistency Principle):**
Tử số và Mẫu số của một tỷ số tài chính bắt buộc phải nằm trên **cùng một hệ quy chiếu thời gian**. Nếu một bên là tích lũy 1 năm (TTM 4 quý) thì bên kia cũng phải đại diện cho quy mô 1 năm tương ứng. Tuyệt đối không ghép một biến số tích lũy 1 quý với một biến số thời điểm mà không có hệ số quy năm (annualize), hoặc ghép tích lũy 4 quý với mẫu số chỉ tính cho 1 quý.

### 12.2. Ma Trận Đối Soát Nhất Quán Giữa Tử Số & Mẫu Số
Reviewer bắt buộc đối soát công thức theo ma trận chuẩn mực sau:

| Chỉ Số Tài Chính | Chu Kỳ Đo Lường | Tử Số (Numerator) | Mẫu Số (Denominator) | Quy Tắc Nhất Quán Bắt Buộc |
|---|---|---|---|---|
| **EPS Quý (1Q)** | 1 Quý gần nhất | LNST Quý gần nhất (`net_profit_after_tax`) | Số CP lưu hành **bình quân của chính quý đó** | Cùng chu kỳ 1 quý. Tuyệt đối không chia cho số CP cuối năm hay số CP đầu năm. |
| **EPS TTM (4Q)** | 4 Quý liên tiếp | LNST TTM 4 quý (`net_profit_after_tax_ttm`) | Số CP lưu hành **bình quân trong 4 quý đó** | Cùng chu kỳ 4 quý. LNST TTM = NULL nếu thiếu bất kỳ quý nào trong 4 quý liên tiếp. |
| **P/E Chuẩn** | Năm / TTM | Giá đóng cửa hiện tại (`close_price`) | **EPS TTM 4 quý** | Phản ánh định giá trên thu nhập 1 năm. Nếu lấy Giá / EPS 1 quý $\implies$ P/E bị thổi phồng ~4 lần! |
| **P/E Quý Quy Năm** | Quý quy năm | Giá đóng cửa hiện tại (`close_price`) | **EPS Quý gần nhất × 4** | Phải nhân 4 ở mẫu số hoặc nhân 4 EPS để chuẩn hóa về quy mô năm. |
| **BVPS Quý (1Q)** | Quý gần nhất | VCSH tại cuối quý gần nhất (`owner_equity`) | Số CP lưu hành bình quân quý gần nhất | VCSH là số dư cuối quý, mẫu số là số CP tương ứng quý đó. |
| **BVPS 4 Quý** | 4 Quý gần nhất | VCSH tại cuối quý gần nhất | Số CP lưu hành bình quân 4 quý gần nhất | **CẤM SUM(VCSH) 4 quý!** VCSH là số dư thời điểm, giữ nguyên quý gần nhất. |
| **P/B (Price-to-Book)** | Thị trường | Giá đóng cửa hiện tại (`close_price`) | **BVPS** (quý gần nhất hoặc bình quân 4 quý) | Thống nhất cách tính BVPS tương ứng. |
| **ROE (Return on Equity)** | Năm / TTM | Tổng LNST 4 quý (TTM) | **VCSH bình quân** = (VCSH đầu kỳ + VCSH cuối kỳ) / 2 | VCSH bình quân phải bao trọn khoảng thời gian phát sinh của LNST. |
| **ROA (Return on Assets)** | Năm / TTM | Tổng LNST 4 quý (TTM) | **Tổng tài sản bình quân** = (Tài sản đầu kỳ + Tài sản cuối kỳ) / 2 | Tài sản bình quân phải bao trọn khoảng thời gian phát sinh của LNST. |

### 12.3. Quy Tắc Tính Toán Từng Chỉ Số & Các Điều Cấm Kỵ
1. **Lệnh Cấm Cộng Dồn Biến Số Số Dư (Stock Metric Summation Ban):**
   - **TUYỆT ĐỐI CẤM:** Thực hiện phép tính `SUM(owner_equity)` hoặc `SUM(total_assets)` qua 4 quý trong công thức tính mẫu số.
   - *Lý do:* Vốn chủ sở hữu và Tổng tài sản là số dư tích lũy tại ngày kết thúc kỳ kế toán (BCDKT). Cộng dồn số dư của 4 quý liên tiếp là một sai lầm nghiêm trọng về nguyên lý kế toán tài chính, thổi phồng mẫu số lên 4 lần và làm sai lệch hoàn toàn chỉ số BVPS, ROE, ROA.
2. **Quy Tắc Xử Lý Thiếu Dữ Liệu BCTC (Missing Period Rule):**
   - Chỉ tiêu `net_profit_after_tax_ttm` bắt buộc phải trả về `NULL` nếu doanh nghiệp thiếu báo cáo tài chính của bất kỳ 1 quý nào trong chuỗi 4 quý liên tiếp gần nhất. Nghiêm cấm việc tự ý cộng 2 hoặc 3 quý rồi nội suy.
   - Khi `net_profit_after_tax_ttm` là `NULL`, chỉ số `EPS TTM` và `P/E` tương ứng bắt buộc phải hiển thị `NULL`.
3. **Bẫy Chia Cho 0 & Doanh Nghiệp Bị Lỗ:**
   - Khi EPS âm (doanh nghiệp kinh doanh thua lỗ), hệ số P/E không mang ý nghĩa kinh tế định giá thông thường. Công thức DERIVED phải sử dụng `NULLIF` để tránh lỗi chia cho 0: `close_price / NULLIF(eps_ttm, 0)`.
4. **Mã lỗi kỹ thuật:** `🔴 Critical: [L3-FINANCIAL-PERIOD-INCONSISTENT]`.

### 12.4. Ví Dụ Đối Chiếu Thực Tế Đúng vs Sai (P/E & EPS)

#### ❌ SAI (Wrong Implementation):
```sql
-- Sai lầm: Lấy Giá thị trường chia cho EPS của riêng 1 quý (không nhân 4 quy năm)
-- Detail Mapping DERIVED logic:
security_trading_snpst_dim.close_price / (
    fct_stock_portfolio_snpst.net_profit_after_tax / fct_stock_portfolio_snpst.outstanding_share_quantity
)
-- HẬU QUẢ: P/E thực tế của cổ phiếu là 15 lần, nhưng công thức này ra 60 lần (gấp 4 lần bình thường)!
```

#### ✅ ĐÚNG (Right Implementation):
```sql
-- Lựa chọn A (P/E TTM chuẩn mực thị trường):
-- Tử số: Giá đóng cửa hiện tại
-- Mẫu số: EPS TTM (LNST lũy kế 4 quý gần nhất chia cho Số CP bình quân 4 quý)
security_trading_snpst_dim.close_price / (
    fct_stock_portfolio_snpst.net_profit_after_tax_ttm / (
        AVG(fct_stock_portfolio_snpst.outstanding_share_quantity) 
        -- tính theo các kỳ báo cáo trong 4 quý gần nhất
    )
)

-- Lựa chọn B (Nếu BA yêu cầu tường minh P/E Quý quy năm - Annualized Quarterly P/E):
security_trading_snpst_dim.close_price / (
    (fct_stock_portfolio_snpst.net_profit_after_tax * 4.0) / (
        AVG(fct_stock_portfolio_snpst.outstanding_share_quantity)
        -- tính theo kỳ báo cáo quý hiện tại
    )
)
```

---

## 13. Quy Chuẩn Kiểm Soát Đồng Bộ Flat Table SQL (DDL & DML)

### 13.1. Bản Chất Kỹ Thuật & Vòng Lặp Đồng Bộ Khép Kín (Closed-Loop Sync)
Trong kiến trúc ClickHouse Datamart phục vụ BI & Trực quan hóa, Flat Table đóng vai trò là tầng phân phối dữ liệu cuối cùng (Presentation Layer). Mỗi bảng Fact hoặc Operational sẽ tương ứng với một bảng Flat Table được làm phẳng sẵn (denormalized), kết hợp dữ liệu từ bảng Fact chính, chiều thời gian `cdr_dt_dim`, và toàn bộ các Dimension liên quan theo khóa ngoại (FKs).

Bộ script Flat Table bao gồm 2 file bắt buộc trong thư mục `Datamart/flat-table/{MODULE}/`:
1. `01_create_{module}_flat_tables.sql`: Chứa các câu lệnh `CREATE TABLE IF NOT EXISTS datamart.{module}_{table}_flat` định nghĩa schema vật lý trên ClickHouse (`ENGINE = ReplicatedReplacingMergeTree()`, `PARTITION BY`, `ORDER BY`).
2. `02_populate_{module}_flat_tables.sql`: Chứa các câu lệnh ETL nạp dữ liệu định kỳ hàng ngày (`TRUNCATE / DELETE` và `INSERT INTO datamart.{module}_{table}_flat (...) SELECT ... FROM ...`).

Quy trình phát triển và thẩm định Datamart bắt buộc duy trì vòng lặp đồng bộ khép kín 3 pha:
```
[LLD Detail Mapping & Attributes]
           │ (Phát sinh thay đổi / Bổ sung)
           ▼
[Flat Table DDL & DML Scripts]
           │ (Đồng bộ cấu trúc & câu lệnh nạp)
           ▼
[GATE 4: Quality Review & Parity Audit]
```

Để đảm bảo tính toàn vẹn và ngăn chặn trôi lệch schema giữa LLD và Flat Table, Reviewer và Designer bắt buộc phải kiểm soát 4 tiêu chí kỹ thuật cốt lõi sau:

---

### 13.2. Tiêu Chí 1: Flat Table Column Coverage (Độ Bao Phủ Cột 100%)
Độ bao phủ cột là yêu cầu bảo đảm Flat Table cung cấp đầy đủ 100% trường dữ liệu cần thiết phục vụ báo cáo mà không bỏ sót bất kỳ thuộc tính nào đã được thiết kế ở LLD.

#### 1. Quy chuẩn chi tiết:
1. **Khối Cột Fact / Operational:** 100% cột trong file Attributes module (`DTM_{MODULE}_{table}.csv`) — bao gồm khóa chính, khóa ngoại, measures, attributes và technical indicators — PHẢI có mặt đầy đủ trong định nghĩa `CREATE TABLE` của file `01_create_*.sql`.
   - *Ngoại lệ hợp lệ:* Duy nhất 2 trường kỹ thuật audit hệ thống nạp batch (`ds_batch_date`, `ds_population_timestamp`) được phép không đưa vào Flat Table nếu hệ thống ClickHouse quản lý qua metadata riêng.
2. **Khối Cột Dimension Joined:** 100% cột giá trị nghiệp vụ của các Dimension được JOIN (theo khóa ngoại FK có trong Fact Attributes) PHẢI có mặt trong khối `CREATE TABLE`.
   - *Quy tắc loại trừ:* Bỏ qua PK surrogate của Dimension (vì Fact đã giữ FK), bỏ qua `src_stm_code` của Dim (dùng `src_stm_code` của Fact), và bỏ qua bộ 5 trường audit SCD4A của Dim (`ds_rcrd_st`, `ds_eff_start_dt`, `ds_eff_end_dt`, `ds_cdc_opr_cd`, `ds_load_ts`, `ds_snpst_dt`).
3. **Khối Cột Calendar Date:** Bắt buộc có mặt cột ngày lịch `cdr_dt` từ `cdr_dt_dim`, được đặt alias theo vai trò ngày nghiệp vụ (`snpst_cdr_dt` cho Fact Snapshot, `issue_cdr_dt`, `trade_cdr_dt` cho Fact Event).
4. **Mã lỗi vi phạm:** `🔴 Critical: [L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING]`.

---

### 13.3. Tiêu Chí 2: 1-1 Projection Alignment (Khớp Chiếu 1-1 Giữa DDL & DML)
Sự sai lệch giữa danh sách cột trong câu lệnh `CREATE TABLE` và mệnh đề `SELECT` của lệnh `INSERT INTO` là nguyên nhân hàng đầu gây lỗi runtime SQL trên ClickHouse, hoặc nghiêm trọng hơn là nạp nhầm dữ liệu chéo giữa các cột có cùng kiểu dữ liệu.

#### 1. Quy chuẩn chi tiết:
1. **Khớp Tuyệt Đối Số Lượng Cột:** Tổng số cột khai báo trong lệnh `CREATE TABLE` (`01_create_*.sql`) PHẢI BẰNG CHÍNH XÁC tổng số biểu thức cột được chiếu trong mệnh đề `SELECT` của câu lệnh `INSERT INTO` (`02_populate_*.sql`).
2. **Khớp Tuần Tự Thứ Tự Cột (Column Order):** Thứ tự các cột trong câu lệnh `CREATE TABLE` phải trùng khớp tuần tự từng dòng (1-1) với thứ tự các biểu thức trong mệnh đề `SELECT`. Khung cấu trúc 3 khối chuẩn mực bắt buộc:
   - *Khối 1:* Các cột thuộc tính và measure của Fact / Operational table.
   - *Khối 2:* Các cột ngày từ `cdr_dt_dim` (ví dụ `snpst_cdr_dt`).
   - *Khối 3:* Các cột thuộc tính từ các Dimension được JOIN, sắp xếp tuần tự theo từng bảng Dimension.
3. **Khớp Alias Chiếu (Projection Alias Match):** Tên alias trong mệnh đề `SELECT (... AS col_name)` phải khớp chính xác 100% với tên cột định nghĩa trong `CREATE TABLE`. Tuyệt đối không được để biểu thức trần không có alias hoặc alias sai chính tả.
4. **Mã lỗi vi phạm:** `🔴 Critical: [L4-FLAT-TABLE-PROJECTION-MISALIGNMENT]`.

---

### 13.4. Tiêu Chí 3: Column Drift Control (Chống Trôi Lệch Cột)
Trôi lệch cột (Column Drift) xảy ra khi schema Flat Table bị mất đồng bộ với Master Registry hoặc Detail Mapping, dẫn đến tồn tại cột mồ côi (không ai quản lý) hoặc bỏ sót cột mà người dùng đang khai thác.

#### 1. Quy chuẩn chi tiết:
1. **Chống Cột Ma / Cột Mồ Côi trong SQL:** Không được phép có bất kỳ cột nào xuất hiện trong `CREATE TABLE` (phần Fact/Operational) mà không tồn tại trong file module Attributes CSV và master registry `datamart_attributes.csv`. Toàn bộ các cột do copy-paste từ module khác hoặc tàn dư cũ chưa dọn PHẢI BỊ XÓA BỎ NGAY LẬP TỨC.
2. **Chống Bỏ Sót Chỉ Tiêu Detail Mapping:** Toàn bộ các cột Fact (`mart_column`) được khai thác bởi các KPI trong `Detail_Mapping.csv` bắt buộc phải có mặt đầy đủ trong Flat Table. Bỏ sót cột đang có KPI sử dụng là vi phạm nghiêm trọng.
3. **Đồng Bộ Master Registry Trước Khi Thêm Vào Flat Table:** Khi có yêu cầu nghiệp vụ bổ sung cột mới vào Flat Table, Designer bắt buộc phải thêm thuộc tính vào LLD Attributes module CSV, đồng bộ vào master `datamart_attributes.csv`, rồi mới được phép đưa vào Flat Table DDL và DML.
4. **Mã lỗi vi phạm:** `🔴 Critical: [L4-FLAT-TABLE-COLUMN-DRIFT]`.

---

### 13.5. Tiêu Chí 4: Parameter Consistency (Nhất Quán Tham Số ETL `:etl_date`)
Các job nạp dữ liệu Flat Table hàng ngày trên ClickHouse được kích hoạt bởi hệ thống Orchestration (như Airflow, DolphinScheduler, Spark job). Việc sử dụng sai cú pháp tham số lọc ngày sẽ khiến job không thể nhận tham số động, gây nạp thiếu dữ liệu hoặc nạp đè dữ liệu sai ngày.

#### 1. Quy chuẩn chi tiết:
1. **Cú Pháp Tham Số Chuẩn `:etl_date`:** Toàn bộ các mệnh đề `WHERE` lọc theo ngày chạy ETL trong file `02_populate_*.sql` BẮT BUỘC sử dụng thống nhất cú pháp biến tham số `:etl_date`:
   - Bảng Fact Periodic Snapshot: `WHERE snpst_cal.cdr_dt = :etl_date`
   - Bảng Fact Transaction / Event: `WHERE evnt_cal.cdr_dt = :etl_date`
2. **Lệnh Cấm Các Biến Thể & Cấm Hardcode Ngày:**
   - **TUYỆT ĐỐI CẤM:** Sử dụng các định dạng không tương thích như `{etl_date}`, `$etl_date`, `${etl_date}`, `%(etl_date)s`, `?`.
   - **TUYỆT ĐỐI CẤM:** Hardcode chuỗi ngày cố định (ví dụ `WHERE snpst_cal.cdr_dt = '2026-09-14'`).
3. **Mã lỗi vi phạm:** `🔴 Critical: [L4-FLAT-TABLE-PARAMETER-INCONSISTENT]`.

---

### 13.6. Bảng Ma Trận Đối Soát 5 Tiêu Chí Flat Table SQL

| # | Tiêu Chí Kiểm Tra | Đối Tượng Đối Soát | Điều Kiện Đạt Chuẩn (PASS) | Mã Lỗi Khi Vi Phạm |
|---|---|---|---|---|
| **1** | **Flat Table Column Coverage** | `01_create_*.sql` vs Attributes CSV & Dim FKs | 100% cột Fact và cột Dim joined có mặt trong DDL (bỏ qua audit fields và surrogate keys của Dim). | `L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING` |
| **2** | **1-1 Projection Alignment** | `01_create_*.sql` vs `02_populate_*.sql` | Tổng số cột, thứ tự 3 khối, và tên alias khớp chính xác 1-1 giữa `CREATE TABLE` và `SELECT`. | `L4-FLAT-TABLE-PROJECTION-MISALIGNMENT` |
| **3** | **Column Drift Control** | Flat Table SQL vs Master CSV & Detail Mapping | Không có cột thừa trong SQL; không bỏ sót cột Fact có KPI khai thác; 100% cột Fact có trong master CSV. | `L4-FLAT-TABLE-COLUMN-DRIFT` |
| **4** | **Parameter Consistency** | `02_populate_*.sql` (`WHERE` clause) | 100% mệnh đề lọc ngày ETL dùng đúng cú pháp `:etl_date`; không dùng format lạ hoặc hardcode ngày. | `L4-FLAT-TABLE-PARAMETER-INCONSISTENT` |
| **5** | **Common Dimensions Sync** | `Datamart/flat-table/Common/` vs `cdr_dt_dim` CSV | Bắt buộc có script DDL/DML cho bảng phẳng `datamart.cdr_dt_flat` (nguồn `datamart.cdr_dt_dim`) trên ClickHouse với đủ 9 cột kể cả cờ `is_trading_date`. | `L4-COMMON-DIM-CLICKHOUSE-MISSING` |


---

### 13.7. Ví Dụ Đối Chiếu Thực Tế Đúng vs Sai (DDL & DML)

#### ❌ SAI (Wrong Implementation):
```sql
-- FILE: 01_create_gstt_flat_tables.sql
CREATE TABLE IF NOT EXISTS datamart.gstt_stock_portfolio_flat (
    symbol Nullable(String) COMMENT 'Mã chứng khoán',
    close_price Nullable(Decimal(18, 4)) COMMENT 'Giá đóng cửa',
    -- LỖI 1: Thiếu cột total_matched_vol có trong Attributes.csv (Column Coverage Missing)
    -- LỖI 2: Cột mồ côi orphan_metric không có trong Attributes.csv (Column Drift)
    orphan_metric Nullable(Int64) COMMENT 'Cột thừa không có nguồn',
    snpst_cdr_dt Nullable(Date) COMMENT 'Ngày snapshot',
    company_name Nullable(String) COMMENT 'Tên công ty'
) ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (symbol);

-- FILE: 02_populate_gstt_flat_tables.sql
INSERT INTO datamart.gstt_stock_portfolio_flat
SELECT
    f.symbol AS symbol,
    f.close_price AS close_price,
    snpst_cal.cdr_dt AS snpst_cdr_dt,  -- LỖI 3: Sai thứ tự cột so với CREATE (lệch vị trí orphan_metric)
    dim_sec.company_name AS company_name
    -- LỖI 4: Số lượng cột trong SELECT (4 cột) không khớp CREATE TABLE (5 cột) (Projection Misalignment)
FROM datamart.fct_stock_portfolio_snpst f
JOIN datamart.cdr_dt_dim snpst_cal ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.dim_security dim_sec ON dim_sec.security_dim_id = f.security_dim_id
WHERE snpst_cal.cdr_dt = '2026-09-14'; -- LỖI 5: Hardcode ngày, không dùng :etl_date (Parameter Inconsistent)
```

#### ✅ ĐÚNG (Right Implementation):
```sql
-- FILE: 01_create_gstt_flat_tables.sql
CREATE TABLE IF NOT EXISTS datamart.gstt_stock_portfolio_flat (
    -- Khối 1: Fact columns (khớp 100% Attributes.csv, không có cột mồ côi)
    symbol Nullable(String) COMMENT 'Mã chứng khoán',
    close_price Nullable(Decimal(18, 4)) COMMENT 'Giá đóng cửa',
    total_matched_vol Nullable(Int64) COMMENT 'Tổng khối lượng khớp lệnh',
    -- Khối 2: Calendar Date columns
    snpst_cdr_dt Nullable(Date) COMMENT 'Ngày snapshot kỳ báo cáo',
    -- Khối 3: Joined Dimension columns
    company_name Nullable(String) COMMENT 'Tên tổ chức phát hành'
) ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (symbol);

-- FILE: 02_populate_gstt_flat_tables.sql
INSERT INTO datamart.gstt_stock_portfolio_flat
SELECT
    -- Khối 1: Khớp 1-1 cả tên alias và thứ tự với CREATE TABLE
    f.symbol AS symbol,
    f.close_price AS close_price,
    f.total_matched_vol AS total_matched_vol,
    -- Khối 2: Khớp cột Calendar Date
    snpst_cal.cdr_dt AS snpst_cdr_dt,
    -- Khối 3: Khớp cột Dimension joined
    dim_sec.company_name AS company_name
FROM datamart.fct_stock_portfolio_snpst f
JOIN datamart.cdr_dt_dim snpst_cal ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.dim_security dim_sec ON dim_sec.security_dim_id = f.security_dim_id
WHERE snpst_cal.cdr_dt = :etl_date; -- Chuẩn tham số động duy nhất :etl_date
```



