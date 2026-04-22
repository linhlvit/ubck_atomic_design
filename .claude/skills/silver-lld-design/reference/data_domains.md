# 12 Data Domain chuẩn

Mỗi attribute Silver phải dùng đúng 1 Data Domain trong bảng dưới đây.

| Data Domain | Dùng cho |
|---|---|
| `Text` | Chuỗi ký tự thông thường |
| `Date` | Ngày (không có giờ) |
| `Timestamp` | Ngày + giờ |
| `Currency Amount` | Giá trị tiền tệ (KHÔNG viết tắt "Amount") |
| `Interest Rate` | Lãi suất |
| `Exchange Rate` | Tỷ giá |
| `Percentage` | Phần trăm |
| `Surrogate Key` | Khóa đại diện (FK Id) |
| `Classification Value` | Mã phân loại (FK Code đến Classification Value hoặc Currency) |
| `Indicator` | Cờ đánh dấu (Y/N, 0/1) |
| `Boolean` | True/False |
| `Small Counter` | Số đếm nhỏ |

## Data Domain mở rộng cho junction denormalized

| Data Domain | Dùng cho |
|---|---|
| `Array<Text>` | Mảng chuỗi — junction chỉ chứa code/text |
| `Array<Struct>` | Mảng struct — junction chứa cặp Id + Code. Ghi schema struct vào comment: `Struct: {field1: Domain1; field2: Domain2}` |
