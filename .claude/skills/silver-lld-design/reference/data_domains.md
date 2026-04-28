# 12 Data Domain chuẩn

Mỗi attribute Silver phải dùng đúng 1 Data Domain trong bảng dưới đây.

| Data Domain | Dùng cho | Data Type |
|---|---|---|
| `Text` | Chuỗi ký tự thông thường | `string` |
| `Date` | Ngày (không có giờ) | `date` |
| `Timestamp` | Ngày + giờ | `timestamp` |
| `Currency Amount` | Giá trị tiền tệ (KHÔNG viết tắt "Amount") | `decimal(23,2)` |
| `Interest Rate` | Lãi suất | `decimal(8,5)` |
| `Exchange Rate` | Tỷ giá | `decimal(12,7)` |
| `Percentage` | Phần trăm | `decimal(5,2)` |
| `Surrogate Key` | Khóa đại diện (FK Id) | `string` |
| `Classification Value` | Mã phân loại (FK Code đến Classification Value hoặc Currency) | `string` |
| `Indicator` | Cờ đánh dấu — bản thân giá trị đã mang ý nghĩa tường minh | `string` |
| `Boolean` | True/False | `boolean` |
| `Small Counter` | Số đếm nhỏ, dạng lưu version number | `int` |

## Data Domain mở rộng cho junction denormalized

| Data Domain | Dùng cho | Data Type |
|---|---|---|
| `Array<Text>` | Mảng chuỗi — junction chỉ chứa code/text | `array<string>` |
| `Array<Struct>` | Mảng struct — junction chứa cặp Id + Code. Ghi schema struct vào comment: `Struct: {field1: Domain1; field2: Domain2}` | `array<struct<...>>` |
