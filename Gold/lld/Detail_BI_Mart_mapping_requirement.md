 1. Objective

Mapping chỉ tiêu báo cáo với Datamart ở mức column.

 2. General Rule

2.1 Không thay đổi danh sách KPI từ BA
2.2 Mapping dựa trên Detail Design
2.3 Mỗi KPI có thể dùng nhiều column

 3. Output Format Requirement

| STT | Dashboard | KPI | Description | BI Type | Category | Module | Datamart | Column | Status | Rule | Note |

 4. Column Definitions

 4.1 STT

Số thứ tự

 4.2 Dashboard

Tên dashboard

 4.3 KPI

Tên chỉ tiêu

 4.4 Description

Mô tả chỉ tiêu

 4.5 BI Type

Dashboard / Báo cáo / Data Explorer

 4.6 Category

Chỉ tiêu cơ sở / phái sinh / chiều

 4.7 Module

Theo detail design

 4.8 Datamart

Tên bảng

 4.9 Column

Tên cột

 4.10 Status

Done / Pending

 4.11 Rule

Công thức tính toán

 4.12 Note

Để trống

 5. Example

| STT | Dashboard            | KPI             | Description     | BI Type   | Category | Module | Datamart             | Column     | Status | Rule              | Note |
| --- | -------------------- | --------------- | --------------- | --------- | -------- | ------ | -------------------- | ---------- | ------ | ----------------- | ---- |
| 1   | Monitoring Dashboard | Tổng số công ty | Tổng số công ty | Dashboard | Chỉ tiêu | PCS    | FCT_PCS_COMPANY_SNAP | COMPANY_ID | Done   | COUNT(COMPANY_ID) |      |
