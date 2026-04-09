 1. Objective

Thiết kế chi tiết cấu trúc bảng (column-level) cho datamart, bám sát high-level design và phục vụ triển khai ETL.

 2. General Rule

2.1 Physical Name sử dụng tiếng Anh viết tắt
2.2 Logical Name là tiếng Anh dễ hiểu
2.3 Description và Purpose viết bằng tiếng Việt đầy đủ
2.4 Field phân loại cần có danh sách giá trị
2.5 Không cần ghi NULL trong cột Key

 3. Output Format Requirement

| Module | Physical Table Name | Logical Table Name | Physical Column Name | Logical Column Name | Description | Purpose | Datatype | Data Length | Key | Status Model | Note |

 4. Column Definitions

 4.1 Module

Giống High-Level Design

 4.2 Physical Table Name

Tên bảng vật lý theo chuẩn

 4.3 Logical Table Name

Tên bảng tiếng Anh đầy đủ

 4.4 Physical Column Name

Tên cột viết hoa, dạng snake case

 4.5 Logical Column Name

Tên cột đầy đủ tiếng Anh

 4.6 Description

Mô tả chi tiết bằng tiếng Việt
Nếu là trường phân loại cần có list value

 4.7 Purpose

Giải thích mục đích sử dụng cột
Nếu là phân loại cần gắn với tài liệu BA

 4.8 Datatype

Ví dụ: VARCHAR, NUMBER, DATE, TIMESTAMP

 4.9 Data Length

Ví dụ: VARCHAR(50), NUMBER(18,2)

 4.10 Key

Chỉ ghi khi là PK hoặc FK

 4.11 Status Model

NEW, REVIEWED, APPROVED

 4.12 Note

Mô tả lookup sang bảng khác nếu cột Key là PK hoặc FK

 5. Technical Columns

 5.1 Dimension Table

Bao gồm:

* <SUBJECT>_DIM_ID
* EFF_DT
* END_DT

 5.2 Fact Table

Bao gồm:

* DATA_DT
* PPN_DT

 6. Example

| Module | Physical Table Name  | Logical Table Name           | Physical Column Name | Logical Column Name  | Description   | Purpose        | Datatype | Data Length | Key | Status Model | Note |
| ------ | -------------------- | ---------------------------- | -------------------- | -------------------- | ------------- | -------------- | -------- | ----------- | --- | ------------ | ---- |
| GSDC   | DIM_PCS_COMPANY      | Public Company Dimension     | COMPANY_DIM_ID       | Company Dimension ID | Khoá thay thế | Khoá chính     | NUMBER   | 18          | PK  | NEW     |      |
| GSDC   | FCT_PCS_COMPANY_SNAP | Public Company Snapshot Fact | DATA_DT              | Data Date            | Ngày dữ liệu  | Trục thời gian | DATE     |             | PK  | NEW     |      |
