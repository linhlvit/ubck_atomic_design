# Quy ước thiết kế Atomic Layer

## 1. Các loại bảng (Table Type) trên Atomic

Atomic layer có 5 loại bảng, phân biệt theo bản chất nghiệp vụ và chiến lược ETL:

| Table Type | Khi nào dùng | ETL Pattern |
|---|---|---|
| `Fundamental` | Entity độc lập, có lifecycle riêng. Không có FK đến entity nghiệp vụ khác (chỉ có FK đến bảng danh mục). | SCD4A |
| `Relative` | Entity phụ thuộc Fundamental — mô tả trạng thái hoặc thuộc tính bổ sung của entity cha. Có FK đến Fundamental. | SCD2 |
| `Fact Append` | Log hoạt động, giao dịch, sự kiện. Grain = 1 event/occurrence. Mỗi dòng là 1 sự kiện xảy ra — không xóa, không sửa. | Insert-only, append |
| `Fact Snapshot` | Chụp trạng thái tại 1 thời điểm/kỳ. Grain = 1 trạng thái tại 1 thời điểm. Cùng business key có thể có nhiều dòng qua các kỳ khác nhau. | Insert-only theo partition ngày/kỳ, giữ lịch sử |
| `Classification` | Danh mục phân loại — lấy từ nguồn hoặc tự định nghĩa. Mặc định cho tất cả entity có `bcv_core_object = Common`. | SCD1 |

### Phân biệt Fact Append và Fact Snapshot

| Tiêu chí | Fact Append | Fact Snapshot |
|---|---|---|
| Grain | 1 event/occurrence | 1 trạng thái tại 1 thời điểm/kỳ |
| Ví dụ | Tick khớp lệnh, log thay đổi trạng thái | Bảng giá cuối ngày, danh mục theo kỳ |
| Nhiều dòng cùng business key? | Có (mỗi lần xảy ra là 1 dòng mới) | Có (mỗi kỳ chụp là 1 dòng mới) |
| Overwrite dòng cũ? | Không | Không |

### Dấu hiệu nhận biết nhanh

| Dấu hiệu | Table Type |
|---|---|
| Tên entity chứa "Activity Log", "Status Log", "Status History" | `Fact Append` |
| `bcv_core_object = Transaction` | `Fact Append` |
| Tên entity chứa "Snapshot" | `Fact Snapshot` |
| `bcv_core_object = Common` | `Classification` |
| Không có FK đến entity nghiệp vụ khác; không thuộc các trường hợp trên | `Fundamental` |
| Có FK đến Fundamental; không thuộc các trường hợp trên | `Relative` |

---

## 2. Technical Fields trên Atomic

Tất cả technical field trên Atomic có prefix `ds_` để phân biệt với trường nghiệp vụ. ETL framework tự động thêm vào khi load — **không thiết kế trong file LLD**.

| Technical Field | Data Domain | Nullable | Mô tả |
|---|---|---|---|
| `ds_record_status` | Classification Value | false | Trạng thái bản ghi trên Atomic (ACTIVE / INACTIVE). Được ETL quản lý — khác với `RECORD.STATUS` T24 (chỉ dữ liệu `LIVE` từ T24 mới được load lên Atomic). |
| `ds_source_system_code` | Classification Value | false | Mã hệ thống nguồn. Ghi đến mức bảng nguồn: ví dụ `DCST.THONG_TIN_DK_THUE`, không chỉ `DCST`. |
| `ds_insert_datetime` | Timestamp | false | Thời điểm ETL insert bản ghi vào Atomic lần đầu. |
| `ds_update_datetime` | Timestamp | false | Thời điểm ETL cập nhật bản ghi gần nhất. |
| `ds_batch_id` | Text | false | ID của batch ETL tạo ra bản ghi — dùng để trace lineage và debug. |

### Quy tắc liên quan

- **Không** đặt tên trường nghiệp vụ với prefix `ds_`.
- Trường metadata truyền nhận từ nguồn (ví dụ: `GOI_TIN_ID`) là trường nghiệp vụ bình thường — không đưa vào nhóm `ds_`.
- File LLD (`attr_*.csv`) **không** bao gồm technical fields — chỉ thiết kế attribute nghiệp vụ.

---

## 3. Data Domain trên Atomic

Mỗi attribute Atomic phải dùng đúng 1 Data Domain trong danh sách chuẩn dưới đây. Data Domain phản ánh **ý nghĩa nghiệp vụ** của attribute — không ép theo data type nguồn.

### 3.1 12 Data Domain chuẩn

| Data Domain | Dùng cho | Physical Data Type |
|---|---|---|
| `Text` | Chuỗi ký tự thông thường | `string` |
| `Date` | Ngày (không có giờ) | `date` |
| `Timestamp` | Ngày + giờ | `timestamp` |
| `Currency Amount` | Giá trị tiền tệ | `decimal(23,2)` |
| `Interest Rate` | Lãi suất | `decimal(8,5)` |
| `Exchange Rate` | Tỷ giá | `decimal(12,7)` |
| `Percentage` | Phần trăm (không phải lãi suất) | `decimal(5,2)` |
| `Surrogate Key` | Khóa đại diện — FK đến Id của entity | `string` |
| `Classification Value` | Mã phân loại — FK đến Classification Value hoặc Currency | `string` |
| `Indicator` | Cờ đánh dấu — bản thân giá trị đã mang ý nghĩa tường minh | `string` |
| `Boolean` | Giá trị True / False | `boolean` |
| `Small Counter` | Số đếm nhỏ, version number | `int` |

### 3.2 Data Domain mở rộng — Junction denormalized

Dùng khi HLD quyết định denormalize bảng junction thành ARRAY trên entity cha.

| Data Domain | Dùng cho | Physical Data Type |
|---|---|---|
| `Array<Text>` | Mảng chuỗi — junction chỉ chứa code hoặc text | `array<string>` |
| `Array<Struct>` | Mảng struct — junction chứa cặp Id + Code. Ghi schema struct vào comment: `Struct: {field1: Domain1; field2: Domain2}` | `array<struct<...>>` |

### 3.3 Quy tắc chọn Data Domain

**Bước 1 — Chọn theo ý nghĩa nghiệp vụ (ưu tiên ngữ nghĩa, không ép theo data type nguồn):**

| Ý nghĩa attribute | Data Domain |
|---|---|
| Giá trị tiền tệ | `Currency Amount` — dù nguồn lưu `varchar` |
| Lãi suất | `Interest Rate` |
| Tỷ giá | `Exchange Rate` |
| Phần trăm (không phải lãi suất) | `Percentage` |
| Ngày không có giờ | `Date` |
| Ngày có giờ | `Timestamp` |
| Cờ True/False | `Boolean` |
| Số đếm, version | `Small Counter` |
| Mã phân loại (danh mục) | `Classification Value` |
| FK surrogate | `Surrogate Key` |
| Không thuộc các loại trên | `Text` |

**Bước 2 — Ghi nhận conversion risk** (không thay đổi domain đã chọn):

| Tình huống | Hành động |
|---|---|
| Data type nguồn khớp tự nhiên với domain (ví dụ: `date` → `Date`, `decimal` → `Currency Amount`) | Không cần ghi chú thêm |
| Nguồn lưu `string`/`varchar` nhưng domain là số (`Small Counter`, `Currency Amount`...) | Ghi vào comment: `"Nguồn lưu dạng string — ETL cần cast/parse sang [data type vật lý]. Cần validate không có giá trị non-numeric."` |
| Nguồn lưu số (`int`, `decimal`) nhưng domain là `Text` hoặc `Classification Value` | Ghi vào comment: `"Nguồn lưu dạng số — ETL cần convert sang string. Giữ nguyên leading zeros nếu có."` |
| Data type nguồn không khai báo trong Columns.csv | Ghi vào comment: `"Data type nguồn không rõ — cần profile trước khi ETL. Domain tạm chọn dựa trên mô tả cột."` |

**Đề xuất Data Domain mới:** Nếu ý nghĩa nghiệp vụ không ánh xạ được vào bất kỳ domain hiện có → đề xuất kèm định nghĩa và data type vật lý dự kiến, ghi vào comment với tag `[PROPOSE NEW DOMAIN]`.

### 3.4 Lưu ý đặc biệt

| Domain | Lưu ý |
|---|---|
| `Currency Amount` | Không viết tắt thành "Amount" trong tên attribute |
| `Classification Value` | Chỉ 1 trường Code — **không** tạo cặp Id + Code (khác với FK đến Fundamental entity) |
| `Surrogate Key` | Luôn đi kèm với trường Code tương ứng (Text) — xem Pattern Id + Code |
| `Indicator` | Khác `Boolean` — Indicator có giá trị tường minh (ví dụ: `'Y'`/`'N'`, `'BUY'`/`'SELL'`), không nhất thiết là True/False |
