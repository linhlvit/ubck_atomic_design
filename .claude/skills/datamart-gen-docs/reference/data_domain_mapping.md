# Data Domain → Kiểu dữ liệu (C.2)

Tra bảng này khi cột `data_type` trong Attributes.csv để trống.
Nếu `data_type` đã có giá trị → lấy thẳng, không cần tra.

| Data Domain | Kiểu dữ liệu |
|---|---|
| Boolean | boolean |
| Classification Value | string |
| Currency Amount | decimal(23,2) |
| Date | date |
| Exchange Rate | decimal(12,7) |
| Indicator | string |
| Interest Rate | decimal(8,5) |
| Percentage | decimal(5,2) |
| Small Counter | int |
| Surrogate Key | string |
| Surrogate Dimension Key | string |
| Text | string |
| Timestamp | timestamp |
| Array\<Text\> | array\<string\> |
| Array\<Struct\> | array\<struct\<...\>\> |

## Quy tắc rút gọn cho ERD Mermaid

Mermaid chỉ hỗ trợ một số kiểu dữ liệu hạn chế. Khi viết ERD, rút gọn như sau:

| Kiểu đầy đủ | Trong ERD Mermaid |
|---|---|
| boolean | string |
| decimal(...) | float |
| array\<...\> | string |
| string | string |
| int | int |
| date | date |
| timestamp | timestamp |
