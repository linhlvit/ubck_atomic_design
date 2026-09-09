# SỔ TAY QUY TẮC KỸ THUẬT CHUYÊN SÂU DATAMART
## Quy Chuẩn Kiểm Định Lớp 2 (Attributes & Mô Hình) & Lớp 4 (Model Registry)

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
