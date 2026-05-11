1. Objective

Thiết kế danh sách các bảng (fact/dimension) cho datamart trong lĩnh vực chứng khoán, đảm bảo rõ grain, nguồn dữ liệu và ý nghĩa nghiệp vụ.

2. General Rule

2.1 Các danh sách trong tài liệu chỉ mang tính ví dụ phổ biến, không giới hạn
2.2 Cho phép mở rộng domain, subject, type theo nghiệp vụ thực tế
2.3 Physical Name sử dụng tiếng Anh đầy đủ

3. Output Format Requirement

| No | Module | Source | Physical Table Name | Logical Table Name | Grain | Description | Note | Reference

4. Column Definitions

4.1 No

Số thứ tự dòng

4.2 Module

Mã phân hệ nghiệp vụ nội bộ

Ví dụ:
* GSDC: Giám sát công ty đại chúng
* TT: Thanh tra
* GSTT: Giám sát thị trường

4.3 Source

Thông tin nguồn dựa vào cột "Nguồn" trên file phân tích

Ví dụ:
* IDS
* SGDCK
* TT

4.4 Physical Table Name

Tên bảng vật lý, sử dụng tiếng Anh viết tắt

Format: <PREFIX>*<DOMAIN_EN>*<SUBJECT>_<TYPE>

4.4.1 Prefix

* FCT: Fact
* DIM: Dimension

4.4.2 Domain Mapping

| Module | DOMAIN_EN | Ý nghĩa                    |
| ------ | --------- | -------------------------- |
| GSDC   | PCS       | Public Company Supervision |
| TT     | INS       | Inspection                 |
| GSTT   | MS        | Market Surveillance        |

4.4.3 Subject

Thực thể nghiệp vụ, ví dụ:

* COMPANY
* CASE
* VIOLATION
* TRADING
* ACCOUNT

4.4.4 Type

* DTL: Detail
* SMY: Summary
* SNAP: Snapshot
* HIS: History
* AGG: Aggregate
* LOG: Log

4.5 Logical Table Name

Tên đầy đủ tiếng Anh theo nghiệp vụ

Format: <Domain Full Name> + <Subject> + <Type> + (Fact/Dimension)

4.6 Grain

Viết bằng tiếng Việt, mô tả độ chi tiết:
"Độ chi tiết đến từng ..."

4.7 Description

Mô tả nghiệp vụ bằng tiếng Việt

4.8 Note

Thông tin về khóa chính, khóa ngoại, snapshot

4.9 Reference

Dashboard sử dụng bảng Fct/Dim thiết kế

5. Business Term Mapping

| English   | Vietnamese        |
| --------- | ----------------- |
| COMPANY   | Công ty đại chúng |
| CASE      | Vụ việc thanh tra |
| VIOLATION | Vi phạm           |
| TRADING   | Giao dịch         |
| ACCOUNT   | Tài khoản         |

6. Example

| No | Module | Source     | Physical Table Name  | Logical Table Name                       | Grain                                  | Description            | Note                           |
| -- | ------ | ---------- | -------------------- | ---------------------------------------- | -------------------------------------- | ---------------------- | ------------------------------ |
| 1  | GSDC   | IDS | FCT_PCS_COMPANY_SNAP | Public Company Supervision Snapshot Fact | Độ chi tiết đến từng công ty đại chúng | Lưu trạng thái công ty | PK: company_id + snapshot_date |
| 2  | TT     | TT  | FCT_INS_CASE_DTL     | Inspection Case Detail Fact              | Độ chi tiết đến từng vụ việc thanh tra | Lưu vụ việc            | PK: case_id                    |
