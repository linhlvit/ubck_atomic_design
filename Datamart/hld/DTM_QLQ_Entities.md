# DATAMART QLQ — Phase 2b: Entity Relationships

> **[VIẾT LẠI TOÀN BỘ 2026-09-26]** Bản trước (Phase 2b cũ) tự ghi nhận đã lệch hoàn toàn với HLD sau nhiều lần renumber (K_FMS→K_QLQ 1-981). File này viết lại từ Section 3 + Section 4 của `DTM_QLQ_HLD.md` sau khi rà soát Nhóm 1-28 (gỡ gating "Dữ liệu động" sai, sửa nguồn Securities/Fund Distribution Agent, xem `project_qlq_reconciliation_0926.md`). Nguồn sự thật: `DTM_QLQ_Entities.csv` (cùng thư mục).

## Nhóm 1, 6 — Thống kê chung CTQLQ (Fact Fund Management Company Snapshot)

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Fund_Management_Company_Snapshot : " "
    Investment_Fund_Dimension ||--o{ Fact_Fund_Management_Company_Snapshot : " "
    Foreign_Fund_Management_Organization_Unit_Dimension ||--o{ Fact_Fund_Management_Company_Snapshot : " "
    Custodian_Bank_Dimension ||--o{ Fact_Fund_Management_Company_Snapshot : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Fund Management Company Snapshot | Fact Snapshot | new | Thống kê thị trường CTQLQ | 1 snapshot toàn TT × 1 tháng | K_QLQ_1,2,5,6,8,9,10,11 (Nhóm 1); K_QLQ_39,40 (Nhóm 6, reuse) |
| Investment Fund Dimension | Dimension | new | Quỹ đầu tư (SCD4A) | 1 quỹ (current state) | — |
| Foreign Fund Management Organization Unit Dimension | Dimension | new | CN CTQLQ nước ngoài (SCD4A) | 1 CN (current state) | — |
| Custodian Bank Dimension | Dimension | new | Ngân hàng giám sát (SCD4A) | 1 NH (current state) | — |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày | 1 ngày | — |

---

## Nhóm 1, 2, 6–9, 12, 17–21, 24, 25 — Dashboard RPT: giá trị ô báo cáo định kỳ (Fact Fund Management Report Cell Value)

> **[MỚI 2026-10-14 — bổ sung đăng ký]** Fact và Dimension này đã có LLD/master/model/Detail Mapping và Cụm 17 của HLD từ 2026-10-13 nhưng bị bỏ sót ở Section 3/4, Entities và flat SQL (`check_orphan` báo Nhánh A). Nhãn dòng/cột của Dimension ô là giả định chờ mẫu dữ liệu (O_QLQ_31); nạp tăng dần theo ngày nộp `submitted_dt = :etl_date` (O_QLQ_34).

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Fund_Management_Report_Cell_Value : " "
    Fund_Management_Report_Cell_Dimension ||--o{ Fact_Fund_Management_Report_Cell_Value : " "
    Fund_Type_Dimension ||--o{ Fact_Fund_Management_Report_Cell_Value : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Fund Management Report Cell Value | Fact (EAV mức ô) | new | Giá trị ô báo cáo định kỳ `RPT_*`; mỗi KPI là bộ lọc (sheet, nhãn dòng, nhãn cột, `record_tp`) trên Dimension ô | 1 ô báo cáo × 1 bản nộp | 51 KPI READY: K_QLQ_3,4,7 (Nhóm 1); K_QLQ_12–18 (Nhóm 2); K_QLQ_42,43 (Nhóm 6); K_QLQ_46,49 (Nhóm 7); K_QLQ_44,50–55 (Nhóm 8); K_QLQ_44,56 (Nhóm 9); K_QLQ_81 (Nhóm 12); K_QLQ_118–121 (Nhóm 17); K_QLQ_122–125 (Nhóm 18); K_QLQ_126–129 (Nhóm 19); K_QLQ_130–133 (Nhóm 20); K_QLQ_134–136 (Nhóm 21); K_QLQ_162,163 (Nhóm 24); K_QLQ_164–170 (Nhóm 25) |
| Fund Management Report Cell Dimension | Dimension | new | Ô báo cáo định kỳ — sheet, biểu mẫu, chỉ số dòng/cột, nhãn dòng/cột (SCD4A) | 1 ô × 1 sheet (current state) | — |
| Fund Type Dimension | Dimension | new | Loại hình quỹ (SCD4A) | 1 loại hình quỹ (current state) | — |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày — FK vai trò ngày cuối kỳ báo cáo | 1 ngày | — |

---

## Nhóm 3 — Danh sách các Công ty quản lý quỹ (Operational)

Bảng tác nghiệp — lấy trực tiếp từ Atomic (Fund Management Company, Investment Fund, Member Rating), không qua Dimension riêng.

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fund Management Company Profile | Operational | new | Hồ sơ CTQLQ | 1 CTQLQ × 1 tháng slicer | K_QLQ_19,20,23,24,25,26 |

---

## Nhóm 4 — Chi tiết Quỹ của một CTQLQ (Operational)

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fund Management Company Fund List | Operational | new | Bảng con drill-down danh sách quỹ theo CTQLQ | 1 quỹ (PK `investment_fund_code`, thuộc 1 CTQLQ — lọc `fmc_id` khi drill-down từ Nhóm 3, O_QLQ_68); NAV đọc Fact RPT Cụm 17 theo tháng slicer (O_QLQ_72) | K_QLQ_33-35 |

---

## Nhóm 5 — Chi tiết các hợp đồng UTDM của CTQLQ (Operational)

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fund Management Company Contract List | Operational | new | Bảng con drill-down danh sách hợp đồng UTDM của CTQLQ — đọc engine báo cáo định kỳ `RPT_*` (sheet `@QLDMDT`), PII lưu nguyên văn là ngoại lệ đã duyệt (O_QLQ_33) | 1 hợp đồng UTDM (bảng `table_idx`, O_QLQ_75) × 1 bản nộp báo cáo của 1 CTQLQ × 1 kỳ báo cáo; lọc `fmc_id` khi drill-down từ Nhóm 3 (O_QLQ_68) | K_QLQ_36,37,38 (Nhóm 5); K_QLQ_2713–2722 (Nhóm 31, không lọc `fmc_id`, O_QLQ_86) |
| Fund Management Company Contract Asset List | Operational | new | Bảng con chi tiết danh mục tài sản của hợp đồng UTDMĐT (popup từ Nhóm 31) — đọc engine báo cáo định kỳ `RPT_*` (sheet `@QLDMDT`, `record_tp` = 2) | 1 hợp đồng UTDM (`table_idx`) × 1 mã chỉ tiêu tài sản × 1 bản nộp báo cáo của 1 CTQLQ × 1 kỳ báo cáo | K_QLQ_2723–2726 (Nhóm 32, 33) |

---

## Nhóm 7 (+8, 9 partial) — Biểu đồ Tổng NAV Quỹ / Phân bổ tài sản / Biến động NAV (Fact Investment Fund NAV Snapshot)

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Investment_Fund_NAV_Snapshot : " "
    Investment_Fund_Dimension ||--o{ Fact_Investment_Fund_NAV_Snapshot : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Investment Fund NAV Snapshot | Fact Snapshot | partial | Tổng NAV quỹ so với GDP | 1 quỹ × 1 tháng | K_QLQ_44,45,47 (Nhóm 7) |
| Investment Fund Dimension | Dimension | new | Quỹ đầu tư (SCD4A) | 1 quỹ (current state) | — |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày | 1 ngày | — |
| Fact Macro Indicator Snapshot (module PTTT) | Fact Snapshot | reuse | GDP_VN — reuse xuyên module, không sinh file LLD cho QLQ | 1 chỉ số × 1 kỳ | K_QLQ_47 |

> Nhóm 8, 9 tái sử dụng Chiều Thời gian (K_QLQ_44) nhưng không có measure riêng READY — toàn bộ 6 chỉ tiêu phân bổ tài sản (Nhóm 8) và 3 chỉ tiêu biến động NAV (Nhóm 9) PENDING, xem O_QLQ_15.

---

## Nhóm 10 (+6 reuse) — Số lượng quỹ đầu tư chứng khoán (Fact Investment Fund Count Snapshot)

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Investment_Fund_Count_Snapshot : " "
    Fund_Type_Dimension ||--o{ Fact_Investment_Fund_Count_Snapshot : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Investment Fund Count Snapshot | Fact Snapshot | new | Đếm số quỹ theo loại hình quỹ | 1 loại hình quỹ × 1 tháng | K_QLQ_59–67 (Nhóm 10); K_QLQ_41 (Nhóm 6, reuse) |
| Fund Type Dimension | Dimension | new | Loại hình quỹ (SCD4A) | 1 loại hình quỹ (current state) | — |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày | 1 ngày | — |

---

## Nhóm 11 — Tăng trưởng số lượng CCQ lưu hành (dùng Fact RPT — không còn Fact riêng)

> **[SỬA 2026-10-26 — All-Tier Cleanup]** BA chuyển CCQ lưu hành (K_QLQ_70–76) sang engine báo cáo định kỳ `RPT_*` (mã chỉ tiêu `2218`) → `Fact Investment Fund CCQ Snapshot` còn 0 KPI dùng nên đã xóa. K_QLQ_68–76 dùng `Fact Fund Management Report Cell Value` (Cụm 17) và `Fund Type Dimension` (O_QLQ_49).

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Fund Management Report Cell Value | Fact | reuse | Giá trị ô báo cáo định kỳ `RPT_*` — mã chỉ tiêu `2218` (CCQ lưu hành), kỳ tháng, bản nộp của quỹ | 1 ô × 1 bản nộp | K_QLQ_68–76 |
| Fund Type Dimension | Dimension | new | Loại hình quỹ (SCD4A) | 1 loại hình quỹ (current state) | K_QLQ_69 |

---

## Nhóm 12 — Tỉ lệ tăng trưởng NAV/CCQ so với VN-Index và Lãi suất liên NH (không còn Fact riêng)

> **[SỬA 2026-10-05 — All-Tier Cleanup]** BA lấy NAV/CCQ (K_QLQ_81–91) từ engine báo cáo định kỳ `RPT_*` (chưa có Atomic entity) → hạ PENDING, `Fact Investment Fund NAV per CCQ Snapshot` còn 0 KPI READY mang measure nên đã xóa. K_QLQ_77 (Thời gian) gắn `Fact Fund Management Company Snapshot`; K_QLQ_80 (Loại hình quỹ chi tiết) là Chiều DERIVED chưa gắn cột (giống K_QLQ_45); VN-Index/Lãi suất reuse module khác. Xem O_QLQ_25.

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fund Type Dimension | Dimension | new | Loại hình quỹ chi tiết (nguồn Atomic Classification FMS Fund Type; [SỬA 2026-10-12] thay Classification Dimension scheme FMS_FUND_TYPE) | 1 loại hình quỹ | K_QLQ_80 (DERIVED) |
| Fact Market Index Snapshot (module GSTT) | Fact Snapshot | reuse | VN-Index — reuse xuyên module, không sinh file LLD cho QLQ | 1 chỉ số × 1 ngày | K_QLQ_78 |
| Fact Macro Indicator Snapshot (module PTTT) | Fact Snapshot | reuse | Lãi suất liên NH qua đêm (INTERBANK_IR) — reuse xuyên module | 1 chỉ số × 1 kỳ | K_QLQ_79 |

---

## Nhóm 13 — Danh sách các quỹ đầu tư (Operational)

```mermaid
erDiagram
    Investment_Fund_Profile ||--o{ Investment_Fund_Representative_Board_Member_List : " "
    Investment_Fund_Profile ||--o{ Investment_Fund_Manager_List : " "
    Investment_Fund_Profile ||--o{ Investment_Fund_Distribution_Agent_List : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Investment Fund Profile | Operational | partial | Hồ sơ quỹ đầu tư | Tác nghiệp Active-only — 1 quỹ (hiện trạng; NAV và LN YTD đọc Fact RPT Cụm 17 theo tháng slicer, O_QLQ_72) | K_QLQ_92-102 |

---

## Nhóm 14 — Danh sách đại lý phân phối (Operational, drill-down từ Nhóm 13)

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Investment Fund Distribution Agent List | Operational | new | Bảng con drill-down đại lý phân phối của quỹ (junction FUD_AG_AGT draft — dùng tạm, O_QLQ_9) | 1 đại lý × 1 quỹ | K_QLQ_103 |

---

## Nhóm 15 — Danh sách thành viên ban đại diện (Operational, drill-down từ Nhóm 13)

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Investment Fund Representative Board Member List | Operational | new | Bảng con drill-down thành viên BĐD quỹ | 1 thành viên × 1 quỹ | K_QLQ_104 |

---

## Nhóm 16 — Danh sách người điều hành quỹ (Operational, drill-down từ Nhóm 13)

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Investment Fund Manager List | Operational | new | Bảng con drill-down người điều hành quỹ | 1 người × 1 quỹ | K_QLQ_105 |

---

## Nhóm 17 — Thống kê chung Đại lý phân phối (Fact Fund Distribution Agent Snapshot)

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Fund_Distribution_Agent_Snapshot : " "
    Securities_Distribution_Agent_Dimension ||--o{ Fact_Fund_Distribution_Agent_Snapshot : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Fund Distribution Agent Snapshot | Fact Snapshot | new | Thống kê chung ĐLPP toàn thị trường (nguồn FMS.DISTRIBUTOR_AGENT) | 1 snapshot toàn TT × 1 quý/năm | K_QLQ_116,117 |
| Securities Distribution Agent Dimension | Dimension | new | ĐLPP (SCD4A, + shared IP Alt Identification/Postal Address) | 1 ĐLPP (current state) | — |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày | 1 ngày | — |

---

## Nhóm 22 — Danh sách Đại lý phân phối (Operational)

```mermaid
erDiagram
    Fund_Distribution_Agent_Profile ||--o{ Fund_Distribution_Agent_Fund_List : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fund Distribution Agent Profile | Operational | new | Hồ sơ ĐLPP (nguồn FMS.DISTRIBUTOR_AGENT) | Tác nghiệp Active-only — 1 ĐLPP (lọc theo ngày cấp GCN `distribution_cert_dt` ≤ ngày chọn; 15 chỉ tiêu RPT đọc Fact RPT Cụm 17, O_QLQ_72) | K_QLQ_137-158 |

---

## Nhóm 23 — Danh sách các Quỹ đang phân phối (Operational, drill-down từ Nhóm 22)

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fund Distribution Agent Fund List | Operational | new | Bảng con drill-down danh sách quỹ đang phân phối (nguồn FMS.FUD_AG_AGT, nối ĐLPP theo mã nguồn) | 1 quỹ × 1 ĐLPP | K_QLQ_159 |
| Fund Distribution Agent Dimension | Dimension | new | ĐLPP nguồn FMS.AGENCIES (SCD4A) — xem O_QLQ_10 | 1 ĐLPP (current state) | — |

---

## Nhóm 24 — Thống kê chung CN CTQLQ nước ngoài tại VN (Fact Foreign Fund Management Organization Unit Snapshot)

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Foreign_Fund_Management_Organization_Unit_Snapshot : " "
    Foreign_Fund_Management_Organization_Unit_Dimension ||--o{ Fact_Foreign_Fund_Management_Organization_Unit_Snapshot : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Foreign Fund Management Organization Unit Snapshot | Fact Snapshot | new | Thống kê chung CN CTQLQ nước ngoài toàn thị trường | 1 snapshot toàn TT × 1 tháng | K_QLQ_160,161 (Nhóm 24); K_QLQ_2701–2704 (Nhóm 29) |
| Foreign Fund Management Organization Unit Dimension | Dimension | new | CN CTQLQ nước ngoài (SCD4A) | 1 CN (current state) | — |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày | 1 ngày | — |

---

## Nhóm 26 — Danh sách các Chi nhánh CTQLQ nước ngoài tại Việt Nam (Operational)

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Foreign Fund Management Organization Unit Profile | Operational | partial | Hồ sơ CN CTQLQ nước ngoài | Tác nghiệp Active-only — 1 CN (hiện trạng; 5 chỉ tiêu RPT đọc Fact RPT Cụm 17 theo tháng slicer, O_QLQ_72) | K_QLQ_171-178 |
| Foreign Fund Management Organization Unit Staff Dimension | Dimension | new | Nhân viên CN CTQLQ nước ngoài (Giám đốc CN) | 1 nhân viên (current state) | — |

---

## Nhóm 27 — Chi tiết hợp đồng UTQLDM của CN CTQLQ nước ngoài (Operational)

> **[THIẾT KẾ 2026-10-14]** Nhóm 27 (K_QLQ_179–181) trước đó PENDING; nay READY qua bảng Operational đọc engine báo cáo định kỳ `RPT_*` theo cách của `Fund Management Company Contract List` (Nhóm 5): 1 hợp đồng UTQLDM = 1 dòng động (`dynamic_row_nbr`), `record_tp = 4`. BA để trống tên sheet nên không lọc sheet; dòng hợp đồng nhận diện bằng nhãn cột "Loại" (O_QLQ_37).

> **[SỬA 2026-11-09, O_QLQ_82/83]** *(Lịch sử: đoạn trên mô tả ghép theo `dynamic_row_nbr` và không lọc sheet.)* Khóa hợp đồng nay là `table_idx` (PK = `fmr_submission_code` + `table_idx`), lọc sheet `@QLDMDT`, `record_tp = 4`; BA bỏ điều kiện cơ sở pháp lý `97/2020/TT`.

```mermaid
erDiagram
    Foreign_Fund_Management_Organization_Unit_Contract_List {
        string Fund_Management_Report_Submission_Code PK
        int Table_Index PK
        string Foreign_Fund_Management_Organization_Unit_Code
        string Record_Type
        string Period_Type_Code
        string Period_Value
        int Report_Year
        int Version_Number
        string Customer_Name
        string Custody_Account_Number
        decimal Contract_Market_Value_Amount
        string Source_System_Code
    }
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Foreign Fund Management Organization Unit Contract List | Operational | new | Danh sách hợp đồng UTQLDM của CN CTQLQ nước ngoài (popup Nhóm 26) | 1 hợp đồng (bảng `table_idx`) × 1 bản nộp × 1 kỳ báo cáo | K_QLQ_178 (Nhóm 26), K_QLQ_179–181 (Nhóm 27) |

---

## Nhóm 28 — Thống kê giao dịch của nhân viên công ty QLQ (Fact báo cáo — append)

> **[THIẾT KẾ 2026-10-14]** Nhóm 28 (K_QLQ_106–115) trước đó PENDING (thiếu cầu nối VSDC investor registry); nay READY qua bảng Fact dạng report (`_rpt`, append) đọc `securities_trade` (HOSE/HNX), nối nhân viên theo `fmc_employee.securities_trading_account_nbr`. Phạm vi tài khoản có thể hẹp hơn BA (O_QLQ_35/36). **[SỬA 2026-10-15 — làm theo BA]** nay nối qua CCCD → `open_investor_account` → `securities_trade` và khử trùng như UNION của BA (O_QLQ_35/36/39). Nạp append theo ngày `trade_dt = :etl_date`. **[SỬA 2026-10-14 — O_QLQ_38]** Đổi từ Operational (SCD4A) sang Fact report: `securities_trade` là bảng event nên bộ lọc `trade_dt = :etl_date` làm mọi giao dịch ngày trước thành INACTIVE và `_hstr` phình dần.

```mermaid
erDiagram
    Fund_Management_Company_Staff_Trade_Report {
        date Trade_Date
        string Securities_Trade_Code
        string Trade_Direction_Code
        string FMC_Employee_Code
        string FMC_Code
        string Identification_Number
        string Securities_Account_Number
        string Securities_Company_Code
        string Board_Type_Code
        string Trade_Method_Name
        string Trade_Direction_Name
        string Security_Symbol_Code
        bigint Order_Volume
        decimal Order_Price
        decimal Order_Amount
        string Source_System_Code
    }
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fund Management Company Staff Trade Report | Fact (report) | new | Giao dịch của nhân viên CTQLQ trên sổ lệnh HOSE/HNX | 1 dòng khử trùng (như UNION của BA) × nhân viên × ngày × tài khoản × bên mua/bán × mã CK × phương thức × CTCK × số lượng lệnh × giá lệnh | K_QLQ_106–115 (Nhóm 28) |
| Fund Management Company Employee Investor Account List | Operational | new | Nhân viên CTQLQ × tài khoản giao dịch chứng khoán VSDC (nối CCCD) | 1 nhân viên × 1 tài khoản | K_QLQ_106–107 (Nhóm 28) |

---

## Nhóm 29 — Thống kê chung VPĐD CTQLQ nước ngoài (Fact Foreign Fund Management Organization Unit Snapshot)

> **[THIẾT KẾ 2026-11-09, O_QLQ_83]** BA chèn Nhóm 29 (4 chỉ tiêu cơ sở). Dùng lại Fact snapshot chi nhánh của Nhóm 24, thêm 4 cột đếm VPĐD (`ou_tp_code = '0'`) theo `LICENSE_DATE`; không dùng chung KPI VPĐD của Nhóm 1 (K_QLQ_6, 8–10 — mốc `START_DATE`, Fact snapshot CTQLQ).

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Foreign_Fund_Management_Organization_Unit_Snapshot : " "
    Foreign_Fund_Management_Organization_Unit_Dimension ||--o{ Fact_Foreign_Fund_Management_Organization_Unit_Snapshot : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Foreign Fund Management Organization Unit Snapshot | Fact Snapshot | partial | Thống kê chung CN và VPĐD CTQLQ nước ngoài toàn thị trường (thêm 4 cột đếm VPĐD) | 1 snapshot toàn TT × 1 tháng | K_QLQ_2701–2704 (Nhóm 29) |
| Foreign Fund Management Organization Unit Dimension | Dimension | reuse | CN/VPĐD CTQLQ nước ngoài (SCD4A) | 1 CN/VPĐD (current state) | — |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày | 1 ngày | — |

---

## Nhóm 30 — Danh sách VPĐD CTQLQ nước ngoài (Operational)

> **[THIẾT KẾ 2026-11-09, O_QLQ_83]** Bảng tác nghiệp Active-only riêng cho VPĐD (`ou_tp_code = '0'`), cùng khuôn `Foreign Fund Management Organization Unit Profile` của Nhóm 26 (bộ lọc dòng nằm ở `src_stm_code`). Số giấy phép, ngày cấp, MST đọc `ip_alternative_identification`; địa chỉ đọc `ip_postal_address`; trạng thái đọc `cl_fms_status`.

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Foreign Fund Management Representative Office Profile | Operational | new | Hồ sơ VPĐD CTQLQ nước ngoài | Tác nghiệp Active-only — 1 VPĐD (hiện trạng) | K_QLQ_2705–2710 (Nhóm 30) |

---

## Nhóm 34–38 — Data Explorer: danh sách sheet biểu mẫu báo cáo định kỳ (Operational)

> **[MỚI 2026-10-06]** Atomic (commit e9378756) đã có `fund_management_report` (FMS.RPT_TEMP), `fmr_sheet` (FMS.SHEET), `fmr_period`, `fmr_submission`, `fmr_value`. Thiết kế phần **header** của Data Explorer: Loại/Mã/Tên báo cáo + Mã/Tên sheet (5/9 dòng BA mỗi sheet, 26 sheet có BA Done). Kỳ báo cáo, Mã chỉ tiêu, Tên chỉ tiêu, Giá trị vẫn PENDING — xem O_QLQ_27.

```mermaid
erDiagram
    Fund_Management_Report_Sheet_List {
        string Fund_Management_Report_Sheet_Code PK
        string Fund_Management_Report_Code
        string Fund_Management_Report_Name
        string Fund_Management_Report_Type_Code
        string Report_Short_Code
        string Fund_Management_Report_Sheet_Name
        string Sheet_Short_Code
        string Source_System_Code
    }
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fund Management Report Sheet List | Operational | new | Danh sách sheet biểu mẫu báo cáo định kỳ FMS — Loại/Mã/Tên báo cáo + Mã/Tên sheet | 1 sheet của 1 biểu mẫu (current state) | 130 KPI header Nhóm 34–38 (xem Detail Mapping) |

---

## Data Explorer — engine báo cáo động FMS: 2 bảng khai thác (Operational) từ 2 Dimension kéo 1:1 từ Atomic `dr_*`

> **[CẬP NHẬT 2026-11-08, O_QLQ_80]** Atomic có engine báo cáo động FMS: `dr_structure` (FMS.ITEM_LIST), `dr_submission_history` (FMS.REPORT_HISTORY), `dr_value` (FMS.ITEM_VALUE). Datamart giữ 2 Dimension kéo 1:1 (`dynamic_report_structure_dim`, `dynamic_report_submission_history_dim`); bảng giá trị `fct_dynamic_report_val` vẫn nạp vật lý ở Datamart nhưng không còn là entity thiết kế riêng (chỉ làm nguồn của 2 flat). ClickHouse có đúng 2 bảng khai thác, giữ cấu trúc bảng của job Data Explorer ODS cũ và chỉ chuẩn hóa tên: `qlq_opr_dynamic_report_explorer_val_flat` (thay `bc_bao_cao_quy`) và `qlq_opr_dynamic_report_explorer_indicator_flat` (thay `metadata_etl` của QLQ). Logic biến đổi của job cũ nằm trong DML flat (`02_populate_qlq_flat_tables.sql` khối 21, 22). Rủi ro khóa `acc_value` ở Atomic: O_QLQ_81.

```mermaid
erDiagram
    Dynamic_Report_Structure_Dimension ||--o{ Operational_Dynamic_Report_Explorer_Value : " "
    Dynamic_Report_Submission_History_Dimension ||--o{ Operational_Dynamic_Report_Explorer_Value : " "
    Dynamic_Report_Structure_Dimension ||--o{ Operational_Dynamic_Report_Explorer_Indicator : " "
    Dynamic_Report_Submission_History_Dimension ||--o{ Operational_Dynamic_Report_Explorer_Indicator : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Operational Dynamic Report Explorer Value | Operational | new | Bảng dữ liệu khai thác Data Explorer — giá trị ô báo cáo động đã biến đổi (thay `bc_bao_cao_quy`) | 1 ô × 1 lần nộp (× dòng động × tài khoản lưu ký) | — (chưa có KPI, O_QLQ_79) |
| Operational Dynamic Report Explorer Indicator | Operational | new | Bảng chỉ tiêu (metadata) Data Explorer — mỗi ô của mẫu là một chỉ tiêu (thay `metadata_etl` của QLQ) | 1 chỉ tiêu (`indicator_id`) | — |
| Dynamic Report Structure Dimension | Dimension | new | Cây chỉ tiêu mẫu báo cáo động (`dr_structure`) — mã/tên mẫu, sheet, đường dẫn cột-dòng, mã ô | 1 ô chỉ tiêu của 1 sheet (current state) | — |
| Dynamic Report Submission History Dimension | Dimension | new | Lịch sử nộp báo cáo động (`dr_submission_history`) — đối tượng nộp, kỳ, ngày nộp, phiên bản | 1 lần nộp báo cáo của 1 đối tượng theo kỳ | — |

---

## Bảng PENDING (không thiết kế trong Phase 2)

| Datamart Entity | Lý do PENDING | Issue |
|---|---|---|
| Fact Discretionary Investment Contract Snapshot (Nhóm 2) | 0/7 KPI READY — BA đổi hẳn nguồn sang engine báo cáo định kỳ, chưa có Atomic entity | O_QLQ_15 |
| Fund Management Report Data (giá trị ô báo cáo + Kỳ báo cáo — Tab DATA EXPLORER, STT 29–91; thay `Report Pass-through View`) | PENDING — `fmr_value` thiếu TGT_ID/CODE, `fmr_sheet` thiếu DATA_LABEL/CELLS_META, thiếu RECORD_STATUS (O_QLQ_27); STT 33 (từ dòng 10)–91 BA Pending (O_QLQ_26) | O_QLQ_1, O_QLQ_27 |
