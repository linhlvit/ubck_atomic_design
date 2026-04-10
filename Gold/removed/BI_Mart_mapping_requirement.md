 1. Objective

Mapping giữa Dashboard/Report/Data Explorer với Datamart.

 2. General Rule

2.1 Tên bảng phải khớp High-Level Design
2.2 Không tự tạo bảng mới
2.3 Description bám sát nghiệp vụ

 3. Output Format Requirement

| Module | Dashboard / Report / Data Explorer | Fact Table | Dimension Table | Description |

 4. Column Definitions

 4.1 Module

Tên phân hệ

 4.2 Dashboard / Report / Data Explorer

Tên theo tài liệu BA

 4.3 Fact Table

Tên bảng fact

 4.4 Dimension Table

Danh sách bảng dimension

 4.5 Description

Mô tả cách sử dụng dữ liệu

5. Mapping Principle

5.1 Mỗi Dashboard sử dụng một bảng Fact
5.2 Dimension phải phù hợp với Fact
5.3 Fact có thể dùng cho nhiều Dashboard
5.4 Dimension có thể dùng lại
5.5 Mỗi bảng (Fact hoặc Dimension) phải tách thành 1 dòng riêng biệt:
    - Dòng Fact: chỉ điền cột Fact Table, để trống Dimension Table
    - Dòng Dimension: chỉ điền cột Dimension Table, để trống Fact Table
5.6 Description mô tả ý nghĩa nghiệp vụ của từng bảng, 
    lấy từ cột Description trong High-Level Design

 6. Example

6. Example

| Module | Dashboard            | Fact Table           | Dimension Table | Description                    |
| ------ | -------------------- | -------------------- | --------------- | ------------------------------ |
| PCS    | Monitoring Dashboard | FCT_PCS_COMPANY_SNAP |                 | Lưu trạng thái công ty         |
| PCS    | Monitoring Dashboard |                      | DIM_PCS_COMPANY | Thông tin công ty đại chúng     |
| PCS    | Monitoring Dashboard |                      | DIM_PCS_STATUS  | Danh mục trạng thái công ty    |
