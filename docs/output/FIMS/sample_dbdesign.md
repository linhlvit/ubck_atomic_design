### §2.1 FIMS — Hệ thống quản lý giám sát nhà đầu tư nước ngoài

#### §2.1.1 Các mô hình quan hệ dữ liệu

![ERD FIMS](erd_FIMS.png)

> Nguồn DBML: [`FIMS.dbml`](FIMS.dbml) — paste vào https://dbdiagram.io để render và screenshot.

**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | stock_exchange | So giao dich chung khoan - thanh vien thi truong trong he thong FIMS (HNX, HOSE). |
| 2 | depository_center | Trung tam luu ky chung khoan quoc gia - thanh vien thi truong trong he thong FIMS (VSD). |



#### §2.1.2 Bảng stock_exchange

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | Stock Exchange Id | BIGINT |  | X | P |  | Khóa đại diện cho Sở giao dịch chứng khoán. |
| 2 | Stock Exchange Code | STRING |  |  |  |  | Mã định danh Sở giao dịch. Map từ PK bảng nguồn. |
| 3 | Source System Code | STRING |  |  |  | 'FIMS' | Mã nguồn dữ liệu. |
| 4 | Country of Registration Id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký của Sở giao dịch. |
| 5 | Country of Registration Code | STRING | X |  |  |  | Mã quốc gia đăng ký. |
| 6 | Full Name | STRING |  |  |  |  | Tên Sở giao dịch. |
| 7 | English Name | STRING | X |  |  |  | Tên tiếng Anh. |
| 8 | Abbreviation | STRING | X |  |  |  | Tên viết tắt. |
| 9 | Life Cycle Status Code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. |
| 10 | Description | STRING | X |  |  |  | Ghi chú. |
| 11 | Created By | STRING | X |  |  |  | Người tạo bản ghi. |
| 12 | Created Timestamp | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 13 | Updated Timestamp | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


##### Constraint

| Trường | Bảng tham chiếu | Trường tham chiếu |
|---|---|---|
| Country of Registration Id | Geographic Area | Geographic Area Id |



##### Index

*Không áp dụng cho Silver.*

##### Trigger

*Không áp dụng cho Silver.*


#### §2.1.3 Bảng depository_center

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | Depository Center Id | BIGINT |  | X | P |  | Khóa đại diện cho Trung tâm lưu ký chứng khoán. |
| 2 | Depository Center Code | STRING |  |  |  |  | Mã định danh Trung tâm lưu ký. Map từ PK bảng nguồn. |
| 3 | Source System Code | STRING |  |  |  | 'FIMS' | Mã nguồn dữ liệu. |
| 4 | Country of Registration Id | BIGINT | X |  | F |  | FK đến quốc gia đăng ký của Trung tâm lưu ký. |
| 5 | Country of Registration Code | STRING | X |  |  |  | Mã quốc gia đăng ký. |
| 6 | Full Name | STRING |  |  |  |  | Tên Trung tâm lưu ký. |
| 7 | English Name | STRING | X |  |  |  | Tên tiếng Anh. |
| 8 | Abbreviation | STRING | X |  |  |  | Tên viết tắt. |
| 9 | Life Cycle Status Code | STRING | X |  |  |  | Trạng thái hoạt động. ID lấy từ bảng STATUS. |
| 10 | Description | STRING | X |  |  |  | Ghi chú. |
| 11 | Created By | STRING | X |  |  |  | Người tạo bản ghi. |
| 12 | Created Timestamp | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 13 | Updated Timestamp | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |


##### Constraint

| Trường | Bảng tham chiếu | Trường tham chiếu |
|---|---|---|
| Country of Registration Id | Geographic Area | Geographic Area Id |



##### Index

*Không áp dụng cho Silver.*

##### Trigger

*Không áp dụng cho Silver.*


