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

5.1 Mỗi Dashboard sử dụng một bảng fact
5.2 Dimension phải phù hợp với fact
5.3 Fact có thể dùng cho nhiều dashboard
5.4 Dimension có thể dùng lại

 6. Example

| Module | Dashboard            | Fact Table           | Dimension Table | Description      |
| ------ | -------------------- | -------------------- | --------------- | ---------------- |
| PCS    | Monitoring Dashboard | FCT_PCS_COMPANY_SNAP | DIM_PCS_COMPANY | Giám sát công ty |
