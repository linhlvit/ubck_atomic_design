# DTM_FMS_HLD — Data Mart: Phân hệ FMS (Công ty Quản lý Quỹ)

---

## Section 1 — Data Lineage: Staging → Atomic → Datamart

> **Nhóm 1, 2, 6, 7, 8, 9, 10, 11, 12 (Tab TỔNG QUAN CTQLQ + QUỸ ĐẦU TƯ), Nhóm 18, 19, 20, 21, 25 (Tab TỔNG QUAN ĐẠI LÝ PHÂN PHỐI / CN CTQLQ NN), Nhóm 27 (Báo cáo GD nhân viên) hiện PENDING toàn bộ** — BA đánh "Dữ liệu động" cho toàn bộ measure của các Nhóm này, hoặc Atomic nguồn chỉ có ở track `Atomic_LinhLV` (out of date, không phải nguồn chuẩn), hoặc thiếu hẳn Chiều thời gian hợp lệ ở đúng grain (Nhóm 12 — `FMS.FUND_REPORT` chưa có Atomic entity) — theo gating "Loại dữ liệu" nên không thiết kế Cụm Lineage/Star Schema ở giai đoạn này. Xem chi tiết Atomic đã sẵn sàng + lý do pending trong Section 2 của từng Nhóm tương ứng.

##### Cụm 1: Danh sách CTQLQ — flat (Tác nghiệp)

Phục vụ Tab TỔNG QUAN CTQLQ — Nhóm 3. Bảng flat `Fund Management Company Profile` — chỉ 2/13 chỉ tiêu READY (Tên công ty, Người đại diện theo pháp luật); 11 chỉ tiêu còn lại PENDING (Dữ liệu động hoặc thiếu Atomic `FMS.SECURITIES_REPORT`). Lấy từ Atomic trực tiếp, không qua Dimension.

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        FMS_SECURITIES["FMS.SECURITIES"]
        FMS_TLPROFILES["FMS.TL_PROFILES"]
    end

    subgraph SIL["Atomic"]
        Fund_Management_Company["Fund Management Company"]
        Fund_Management_Company_Employee["Fund Management Company Employee"]
    end

    subgraph GOLD["Datamart"]
        fnd_mgt_co_prf["Fund Management Company Profile"]
    end

    FMS_SECURITIES --> Fund_Management_Company
    FMS_TLPROFILES --> Fund_Management_Company_Employee

    Fund_Management_Company --> fnd_mgt_co_prf
    Fund_Management_Company_Employee --> fnd_mgt_co_prf
```

---

##### Cụm 2: Chi tiết Quỹ của một CTQLQ (Tác nghiệp)

Phục vụ Tab TỔNG QUAN CTQLQ — Nhóm 4. Bảng con drill-down `Fund Management Company Fund List` — 2/3 chỉ tiêu READY (Tên quỹ, Loại hình quỹ); Giá trị NAV PENDING (Dữ liệu động).

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        FMS_FUNDS["FMS.FUNDS"]
        FMS_FUND_TYPE["FMS.FUND_TYPE"]
    end

    subgraph SIL["Atomic"]
        Investment_Fund["Investment Fund"]
        Classification_Value["Classification Value"]
    end

    subgraph GOLD["Datamart"]
        fnd_mgt_co_fnd_lst["Fund Management Company Fund List"]
    end

    FMS_FUNDS --> Investment_Fund
    FMS_FUND_TYPE --> Classification_Value

    Investment_Fund --> fnd_mgt_co_fnd_lst
    Classification_Value --> fnd_mgt_co_fnd_lst
```

---

##### Cụm 3: Chi tiết hợp đồng UTDM của một CTQLQ (Tác nghiệp)

Phục vụ Tab TỔNG QUAN CTQLQ — Nhóm 5. Bảng con drill-down `Fund Management Company Contract List` — 2/3 chỉ tiêu READY (Mã HĐ, Số TK lưu ký); Giá trị hợp đồng PENDING (Dữ liệu động).

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        FMS_INVESACC["FMS.INVES_ACC"]
    end

    subgraph SIL["Atomic"]
        Discretionary_Investment_Account["Discretionary Investment Account"]
    end

    subgraph GOLD["Datamart"]
        fnd_mgt_co_ctr_lst["Fund Management Company Contract List"]
    end

    FMS_INVESACC --> Discretionary_Investment_Account

    Discretionary_Investment_Account --> fnd_mgt_co_ctr_lst
```

---

##### Cụm 4: Danh sách quỹ đầu tư (Tác nghiệp)

Phục vụ Tab QUỸ ĐẦU TƯ — Nhóm 13. Bảng flat `Investment Fund Profile` — 8/11 chỉ tiêu READY (Tên quỹ, Phân loại, Công ty quản lý, Ngân hàng giám sát, Số ĐLPP, Số TV BĐD, Số người điều hành); NAV hiện tại/KL CCQ/LN YTD PENDING (Dữ liệu động).

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        FMS_FUNDS["FMS.FUNDS"]
        FMS_SECURITIES["FMS.SECURITIES"]
        FMS_BANKMONI["FMS.BANK_MONI"]
        FMS_AGENFUNDS["FMS.AGEN_FUNDS"]
        FMS_REPRESENT["FMS.REPRESENT"]
        FMS_FUNDTLPRO["FMS.FUND_TL_PRO"]
    end

    subgraph SIL["Atomic"]
        Investment_Fund["Investment Fund"]
        Fund_Management_Company["Fund Management Company"]
        Custodian_Bank["Custodian Bank"]
        Investment_Fund_X_Fund_Distribution_Agent_Relationship["Investment Fund X Fund Distribution Agent Relationship"]
        Investment_Fund_Representative_Board_Member["Investment Fund Representative Board Member"]
        Investment_Fund_X_Fund_Management_Company_Employee_Relationship["Investment Fund X Fund Management Company Employee Relationship"]
    end

    subgraph GOLD["Datamart"]
        inv_fnd_prf["Investment Fund Profile"]
    end

    FMS_FUNDS --> Investment_Fund
    FMS_SECURITIES --> Fund_Management_Company
    FMS_BANKMONI --> Custodian_Bank
    FMS_AGENFUNDS --> Investment_Fund_X_Fund_Distribution_Agent_Relationship
    FMS_REPRESENT --> Investment_Fund_Representative_Board_Member
    FMS_FUNDTLPRO --> Investment_Fund_X_Fund_Management_Company_Employee_Relationship

    Investment_Fund --> inv_fnd_prf
    Fund_Management_Company --> inv_fnd_prf
    Custodian_Bank --> inv_fnd_prf
    Investment_Fund_X_Fund_Distribution_Agent_Relationship --> inv_fnd_prf
    Investment_Fund_Representative_Board_Member --> inv_fnd_prf
    Investment_Fund_X_Fund_Management_Company_Employee_Relationship --> inv_fnd_prf
```

---

##### Cụm 5a: Drill-down danh sách đại lý phân phối của quỹ (Tác nghiệp)

Phục vụ Tab QUỸ ĐẦU TƯ — Nhóm 14. Bảng con drill-down từ Nhóm 13, 1 chỉ tiêu READY.

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        FMS_AGENCIES["FMS.AGENCIES"]
        FMS_AGENFUNDS["FMS.AGEN_FUNDS"]
    end

    subgraph SIL["Atomic"]
        Fund_Distribution_Agent["Fund Distribution Agent"]
    end

    subgraph GOLD["Datamart"]
        inv_fnd_dist_agt_lst["Investment Fund Distribution Agent List"]
    end

    FMS_AGENCIES --> Fund_Distribution_Agent
    FMS_AGENFUNDS --> Fund_Distribution_Agent

    Fund_Distribution_Agent --> inv_fnd_dist_agt_lst
```

---

##### Cụm 5b: Drill-down danh sách thành viên ban đại diện của quỹ (Tác nghiệp)

Phục vụ Tab QUỸ ĐẦU TƯ — Nhóm 15. Bảng con drill-down từ Nhóm 13, 1 chỉ tiêu READY.

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        FMS_REPRESENT["FMS.REPRESENT"]
    end

    subgraph SIL["Atomic"]
        Investment_Fund_Representative_Board_Member["Investment Fund Representative Board Member"]
    end

    subgraph GOLD["Datamart"]
        inv_fnd_rep_brd_mbr_lst["Investment Fund Representative Board Member List"]
    end

    FMS_REPRESENT --> Investment_Fund_Representative_Board_Member

    Investment_Fund_Representative_Board_Member --> inv_fnd_rep_brd_mbr_lst
```

---

##### Cụm 5c: Drill-down danh sách người điều hành quỹ (Tác nghiệp)

Phục vụ Tab QUỸ ĐẦU TƯ — Nhóm 16. Bảng con drill-down từ Nhóm 13, 1 chỉ tiêu READY.

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        FMS_TLPROFILES["FMS.TL_PROFILES"]
        FMS_FUNDTLPRO["FMS.FUND_TL_PRO"]
    end

    subgraph SIL["Atomic"]
        Fund_Management_Company_Employee["Fund Management Company Employee"]
    end

    subgraph GOLD["Datamart"]
        inv_fnd_mgr_lst["Investment Fund Manager List"]
    end

    FMS_TLPROFILES --> Fund_Management_Company_Employee
    FMS_FUNDTLPRO --> Fund_Management_Company_Employee

    Fund_Management_Company_Employee --> inv_fnd_mgr_lst
```

---

##### Cụm 7: Thống kê chung Đại lý phân phối (`Fact Fund Distribution Agent Snapshot`)

Phục vụ Tab TỔNG QUAN ĐẠI LÝ PHÂN PHỐI — Nhóm 17. Chỉ 2 measure READY: Chiều Thời gian và Số lượng ĐLPP (COUNT db). Số tài khoản/Giá trị phát hành/mua lại PENDING (Dữ liệu động, BA chưa cung cấp nguồn).

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        FMS_AGENCIES["FMS.AGENCIES"]
        ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end

    subgraph SIL["Atomic"]
        Fund_Distribution_Agent["Fund Distribution Agent"]
        Calendar_Date["Calendar Date"]
    end

    subgraph GOLD["Datamart"]
        fct_fnd_dist_agt_snpst["Fact Fund Distribution Agent Snapshot"]
        cdr_dt_dim["Calendar Date Dimension"]
    end

    FMS_AGENCIES --> Fund_Distribution_Agent
    ECAT_ECAT_29_HolidayInfo --> Calendar_Date

    Fund_Distribution_Agent --> fct_fnd_dist_agt_snpst
    Calendar_Date --> cdr_dt_dim
    cdr_dt_dim --> fct_fnd_dist_agt_snpst
```

---

##### Cụm 8a: Danh sách Đại lý phân phối (Tác nghiệp)

Phục vụ Tab TỔNG QUAN ĐẠI LÝ PHÂN PHỐI — Nhóm 22. Bảng flat `Fund Distribution Agent Profile` — 6/13 chỉ tiêu READY.

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        FMS_AGENCIES["FMS.AGENCIES"]
    end

    subgraph SIL["Atomic"]
        Fund_Distribution_Agent["Fund Distribution Agent"]
    end

    subgraph GOLD["Datamart"]
        fnd_dist_agt_prf["Fund Distribution Agent Profile"]
    end

    FMS_AGENCIES --> Fund_Distribution_Agent

    Fund_Distribution_Agent --> fnd_dist_agt_prf
```

---

##### Cụm 8b: Danh sách các Quỹ đang phân phối (Tác nghiệp)

Phục vụ Tab TỔNG QUAN ĐẠI LÝ PHÂN PHỐI — Nhóm 23. Bảng con drill-down `Fund Distribution Agent Fund List` — 1 chỉ tiêu READY.

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        FMS_AGENCIES["FMS.AGENCIES"]
        FMS_AGENFUNDS["FMS.AGEN_FUNDS"]
        FMS_FUNDS["FMS.FUNDS"]
    end

    subgraph SIL["Atomic"]
        Fund_Distribution_Agent["Fund Distribution Agent"]
        Investment_Fund["Investment Fund"]
    end

    subgraph GOLD["Datamart"]
        fnd_dist_agt_fnd_lst["Fund Distribution Agent Fund List"]
    end

    FMS_AGENCIES --> Fund_Distribution_Agent
    FMS_AGENFUNDS --> Investment_Fund
    FMS_FUNDS --> Investment_Fund

    Fund_Distribution_Agent --> fnd_dist_agt_fnd_lst
    Investment_Fund --> fnd_dist_agt_fnd_lst
```

---

##### Cụm 9a: Thống kê chung CN CTQLQ nước ngoài tại VN (`Fact Foreign Fund Management Organization Unit Snapshot`)

Phục vụ Tab TỔNG QUAN CN CTQLQ NN TẠI VN — Nhóm 24. Fact Market-Level Snapshot — 2 measure READY (Chiều Thời gian, đếm CN).

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        FMS_FORBRCH["FMS.FOR_BRCH"]
        ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end

    subgraph SIL["Atomic"]
        Foreign_Fund_Management_Organization_Unit["Foreign Fund Management Organization Unit"]
        Calendar_Date["Calendar Date"]
    end

    subgraph GOLD["Datamart"]
        fct_frgn_fnd_mgt_org_unit_snpst["Fact Foreign Fund Management Organization Unit Snapshot"]
        cdr_dt_dim["Calendar Date Dimension"]
    end

    FMS_FORBRCH --> Foreign_Fund_Management_Organization_Unit
    ECAT_ECAT_29_HolidayInfo --> Calendar_Date

    Foreign_Fund_Management_Organization_Unit --> fct_frgn_fnd_mgt_org_unit_snpst
    Calendar_Date --> cdr_dt_dim
    cdr_dt_dim --> fct_frgn_fnd_mgt_org_unit_snpst
```

---

##### Cụm 9b: Danh sách CN CTQLQ nước ngoài tại VN (Tác nghiệp)

Phục vụ Tab TỔNG QUAN CN CTQLQ NN TẠI VN — Nhóm 26. Bảng flat `Foreign Fund Management Organization Unit Profile` — 4/10 chỉ tiêu READY (Tên CN, Giám đốc CN, Số nhân viên CCHN, Chiều Thời gian).

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        FMS_FORBRCH["FMS.FOR_BRCH"]
        FMS_STFFGBRCH["FMS.STF_FG_BRCH"]
    end

    subgraph SIL["Atomic"]
        Foreign_Fund_Management_Organization_Unit["Foreign Fund Management Organization Unit"]
        Foreign_Fund_Management_Organization_Unit_Staff["Foreign Fund Management Organization Unit Staff"]
    end

    subgraph GOLD["Datamart"]
        frgn_fnd_mgt_org_unit_prf["Foreign Fund Management Organization Unit Profile"]
    end

    FMS_FORBRCH --> Foreign_Fund_Management_Organization_Unit
    FMS_STFFGBRCH --> Foreign_Fund_Management_Organization_Unit_Staff

    Foreign_Fund_Management_Organization_Unit --> frgn_fnd_mgt_org_unit_prf
    Foreign_Fund_Management_Organization_Unit_Staff --> frgn_fnd_mgt_org_unit_prf
```

---

## Section 2 — Tổng quan báo cáo

### Tab: TỔNG QUAN CTQLQ

**Slicer chung:** Tháng/Năm (ví dụ: "THÁNG 5 — 2024")

---

#### Nhóm 1 - Thống kê chung

> Phân loại: **Phân tích**
> Atomic: `Investment Fund` ← FMS.FUNDS — READY *(K_FMS_1, K_FMS_147: COUNT db — nhưng BA đánh "Dữ liệu động" nên PENDING)*
> Atomic: `Discretionary Investment Account` ← FMS.INVES_ACC — READY *(K_FMS_2 — BA đánh "Dữ liệu động" nên PENDING)*
> Atomic: `Fund Management Company` ← FMS.SECURITIES — READY *(K_FMS_4 — BA đánh "Dữ liệu động" nên PENDING)*
> Atomic: `Foreign Fund Management Organization Unit` ← FMS.FOR_BRCH — READY *(K_FMS_5, K_FMS_148, K_FMS_149, K_FMS_150 — BA đánh "Dữ liệu động" nên PENDING)*
> Atomic: `Custodian Bank` ← FMS.BANK_MONI — READY *(K_FMS_151 — BA đánh "Dữ liệu động" nên PENDING)*
> Ghi chú: **Toàn bộ Nhóm PENDING.** Toàn bộ chỉ tiêu cơ sở trong Nhóm này (K_FMS_1–5, K_FMS_147–151) BA đánh **Dữ liệu động** — theo gating "Loại dữ liệu" (xem SKILL.md), Dữ liệu động → PENDING dù Atomic đã sẵn sàng. Chỉ còn lại 1 dòng Chiều "Thời gian" (Dữ liệu tĩnh), nhưng không còn measure nào READY đi kèm để hiển thị → PENDING toàn bộ Nhóm, kể cả Chiều.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_9 | Thời gian | — | Chiều | | **Lý do pending:** Nhóm không còn measure nào READY (toàn bộ đánh Dữ liệu động) nên Chiều không có ý nghĩa hiển thị độc lập. **Atomic cần bổ sung:** không — chờ BA xác nhận lại quy tắc khai thác cho các measure trong Nhóm. **Mart dự kiến:** `Fact Fund Management Company Snapshot` — grain: 1 snapshot toàn thị trường × 1 tháng. | PENDING |
| K_FMS_1 | Quỹ đầu tư chứng khoán | Quỹ | Cơ sở | | **Lý do pending:** BA đánh Dữ liệu động — nguồn COUNT(Investment Fund) theo FUNDS.ID, DELETED=0, ID_DATE. **Atomic cần bổ sung:** không cần bổ sung Atomic (Investment Fund đã READY), chờ BA xác nhận quy tắc khai thác. **Mart dự kiến:** `Fact Fund Management Company Snapshot`. | PENDING |
| K_FMS_2 | Hợp đồng UTDM | Hợp đồng | Cơ sở | | **Lý do pending:** BA đánh Dữ liệu động — nguồn COUNT DISTINCT(Discretionary Investment Account.Contract_No), DELETED=0, DATE_REPORT. **Atomic cần bổ sung:** không — chờ BA xác nhận quy tắc khai thác. **Mart dự kiến:** `Fact Fund Management Company Snapshot`. | PENDING |
| K_FMS_3 | Tổng AUM quản lý | Nghìn tỷ VND | Cơ sở | | **Lý do pending:** BA đánh Dữ liệu động — nguồn SUM(FUND_REPORT.TOTAL_PROPERTY), EXCUTION_DATE; FUND_REPORT chưa có LLD Atomic riêng trong `DataModel/working/Atomic/lld/FMS/`. **Atomic cần bổ sung:** entity cho `FMS.FUND_REPORT` (Fund NAV/Property Report). **Mart dự kiến:** `Fact Fund Management Company Snapshot`. | PENDING |
| K_FMS_4 | CTQLQ đang hoạt động | Công ty | Cơ sở | | **Lý do pending:** BA đánh Dữ liệu động — nguồn COUNT(Fund Management Company) JOIN STATUS, Type_Sec=2, Item_Name='Hoạt động'. **Atomic cần bổ sung:** không — chờ BA xác nhận quy tắc khai thác. **Mart dự kiến:** `Fact Fund Management Company Snapshot`. | PENDING |
| K_FMS_5 | VPĐD QLQ nước ngoài tại VN | Văn phòng | Cơ sở | | **Lý do pending:** BA đánh Dữ liệu động — nguồn COUNT(Foreign Fund Management Organization Unit), Branch_Flag=0. **Atomic cần bổ sung:** không — chờ BA xác nhận quy tắc khai thác. **Mart dự kiến:** `Fact Fund Management Company Snapshot`. | PENDING |
| K_FMS_147 | Số lượng hợp đồng tư vấn đầu tư | Hợp đồng | Cơ sở | | **Lý do pending:** BA chưa cung cấp Bảng nguồn/Trường nguồn (để trống) dù Trạng thái mapping = Done; đồng thời BA đánh Dữ liệu động. **Atomic cần bổ sung:** chưa xác định entity nguồn — chờ BA bổ sung Bảng nguồn. **Mart dự kiến:** `Fact Fund Management Company Snapshot`. | PENDING |
| K_FMS_148 | VPĐD CTQLQ NN tại VN đang hoạt động | Văn phòng | Cơ sở | | **Lý do pending:** BA đánh Dữ liệu động — nguồn COUNT(Foreign Fund Management Organization Unit) JOIN STATUS, Branch_Flag=0, Operation_Status_Code tương ứng 'Hoạt động'. **Atomic cần bổ sung:** không — Foreign Fund Management Organization Unit đã có Operation Status Code (scheme FMS_OPERATION_STATUS), chờ BA xác nhận quy tắc khai thác. **Mart dự kiến:** `Fact Fund Management Company Snapshot`. | PENDING |
| K_FMS_149 | VPĐD CTQLQ NN tại VN đang chờ đóng cửa | Văn phòng | Cơ sở | | **Lý do pending:** Tương tự K_FMS_148, lọc Operation_Status_Code = 'Chờ đóng cửa'. **Atomic cần bổ sung:** không. **Mart dự kiến:** `Fact Fund Management Company Snapshot`. | PENDING |
| K_FMS_150 | VPĐD CTQLQ NN tại VN đã đóng cửa | Văn phòng | Cơ sở | | **Lý do pending:** Tương tự K_FMS_148, lọc Operation_Status_Code = 'Đóng cửa VPĐD'. **Atomic cần bổ sung:** không. **Mart dự kiến:** `Fact Fund Management Company Snapshot`. | PENDING |
| K_FMS_151 | Tổng số ngân hàng giám sát | Ngân hàng | Cơ sở | | **Lý do pending:** BA đánh Dữ liệu động — nguồn COUNT(Custodian Bank), Type='1'. **Atomic cần bổ sung:** không — chờ BA xác nhận quy tắc khai thác. **Mart dự kiến:** `Fact Fund Management Company Snapshot`. | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_1 | FMSQLQ.FUNDS | Investment Fund | investment_fund |
| K_FMS_2 | FMSQLQ.INVES_ACC | Discretionary Investment Account | discretionary_investment_account |
| K_FMS_3 | FMSQLQ.FUND_REPORT | Fund NAV/Property Report *(chưa có LLD)* | TBD |
| K_FMS_4 | FMSQLQ.SECURITIES, FMSQLQ.STATUS | Fund Management Company | fund_management_company |
| K_FMS_5, 148, 149, 150 | FMSQLQ.FOR_BRCH, FMSQLQ.STATUS | Foreign Fund Management Organization Unit | foreign_fm_ou |
| K_FMS_147 | *(BA chưa cung cấp)* | TBD | TBD |
| K_FMS_151 | FMSQLQ.BANK_MONI | Custodian Bank | custodian_bank |

---

#### Nhóm 2 - Số liệu hợp đồng uỷ thác danh mục

> Phân loại: **Phân tích**
> Atomic: `Discretionary Investment Account` ← FMS.INVES_ACC — READY *(K_FMS_10–K_FMS_16 — BA đánh "Dữ liệu động" nên PENDING)*
> Ghi chú: **Toàn bộ Nhóm PENDING** — BA đánh "Dữ liệu động" cho cả Chiều "Thời gian" lẫn toàn bộ 6 chỉ tiêu cơ sở của Nhóm này, theo gating "Loại dữ liệu" nên PENDING toàn bộ dù Atomic `Discretionary Investment Account` đã sẵn sàng. Toàn bộ chỉ tiêu (số lượng HĐ, giá trị thị trường) lấy trực tiếp từ INVES_ACC theo Investor Object Type.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_10a | Thời gian | — | Chiều | | **Lý do pending:** Nhóm không còn measure nào READY (toàn bộ đánh Dữ liệu động). **Atomic cần bổ sung:** không — chờ BA xác nhận quy tắc khai thác. **Mart dự kiến:** `Fact Discretionary Investment Contract Snapshot` — grain: 1 CTQLQ × 1 tháng. | PENDING |
| K_FMS_10 | Số lượng hợp đồng UTDM cá nhân | HĐ | Cơ sở | | **Lý do pending:** BA đánh Dữ liệu động — nguồn COUNT DISTINCT(Discretionary Investment Account.Contract_No) WHERE ID_Type cá nhân. **Atomic cần bổ sung:** không — chờ BA xác nhận quy tắc khai thác. **Mart dự kiến:** `Fact Discretionary Investment Contract Snapshot`. | PENDING |
| K_FMS_11 | Giá trị thị trường hợp đồng UTDM cá nhân | Tỷ VND | Cơ sở | | **Lý do pending:** BA đánh Dữ liệu động — nguồn SUM(Discretionary Investment Account.List_Value) WHERE ID_Type cá nhân. **Atomic cần bổ sung:** không. **Mart dự kiến:** `Fact Discretionary Investment Contract Snapshot`. | PENDING |
| K_FMS_12 | Số lượng hợp đồng UTDM tổ chức | HĐ | Cơ sở | | **Lý do pending:** Tương tự K_FMS_10, WHERE ID_Type tổ chức. **Atomic cần bổ sung:** không. **Mart dự kiến:** `Fact Discretionary Investment Contract Snapshot`. | PENDING |
| K_FMS_13 | Giá trị thị trường hợp đồng UTDM tổ chức | Tỷ VND | Cơ sở | | **Lý do pending:** Tương tự K_FMS_11, WHERE ID_Type tổ chức. **Atomic cần bổ sung:** không. **Mart dự kiến:** `Fact Discretionary Investment Contract Snapshot`. | PENDING |
| K_FMS_14 | Tổng số lượng hợp đồng UTDM | HĐ | Cơ sở | | **Lý do pending:** BA đánh Dữ liệu động — nguồn COUNT DISTINCT(Discretionary Investment Account.Contract_No) toàn thị trường. **Atomic cần bổ sung:** không. **Mart dự kiến:** `Fact Discretionary Investment Contract Snapshot`. | PENDING |
| K_FMS_15 | Tổng giá trị ủy thác | Tỷ VND | Cơ sở | | **Lý do pending:** BA đánh Dữ liệu động — nguồn SUM(Discretionary Investment Account.List_Value) toàn thị trường. **Atomic cần bổ sung:** không. **Mart dự kiến:** `Fact Discretionary Investment Contract Snapshot`. | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_10, 11, 12, 13, 14, 15 | FMSQLQ.INVES_ACC | Discretionary Investment Account | discretionary_investment_account |

---

#### Nhóm 3 - Danh sách các Công ty quản lý quỹ

> Phân loại: **Tác nghiệp**
> Atomic: `Fund Management Company` ← FMS.SECURITIES — READY *(K_FMS_17: Tên công ty)*
> Atomic: `Fund Management Company Employee` ← FMS.TL_PROFILES — READY *(K_FMS_152: Người đại diện theo pháp luật)*
> Ghi chú: **Mix READY/PENDING** — chỉ 2/14 chỉ tiêu BA đánh Dữ liệu tĩnh (Tên công ty, Người đại diện) + Chiều "Thời gian". 11 chỉ tiêu còn lại BA đánh Dữ liệu động → PENDING. Trong đó `Số lượng nhân viên có CCHN`/`AUM`/`Thị phần`/`Lợi nhuận` (nguồn FMSQLQ.SECURITIES_REPORT) **PENDING kép** — vừa Dữ liệu động, vừa chưa có Atomic entity nào cho `FMS.SECURITIES_REPORT`. `CAR (ATTC)` và `Vốn CSH` BA chưa cung cấp Bảng nguồn. 2 bảng con drill-down `Fund Management Company Fund List`/`Fund Management Company Contract List` tách thành Nhóm 4 và Nhóm 5 riêng (xem STT=4, STT=5).

**Mockup:**

| Mã | Tên CT | Người đại diện | Số nhân viên CCHN | Số lượng Quỹ | Xếp loại | CAMEL | Vốn điều lệ | AUM | Thị phần | CAR | Lợi nhuận | Vốn CSH | Số HĐ UTQLDM |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| CT1 | Công ty ABC | Nguyễn Văn A | 12 | 5 | A | 89.5% | 150 | 25.450 | 8.2% | 18.5% | 120.4 | 165 | 350 |

**Source:** `Fund Management Company Profile`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_17a | Thời gian | — | Chiều | | **Lý do pending:** BA đánh Dữ liệu động cho dòng Thời gian ở Nhóm này — Chiều PENDING dù Nhóm còn 2 measure READY khác (Tên công ty, Người đại diện). **Atomic cần bổ sung:** không. **Mart dự kiến:** `Fund Management Company Profile` — grain: 1 CTQLQ × 1 tháng slicer. | PENDING |
| K_FMS_17 | Tên công ty | — | Cơ sở | `Company_Name`, `Company_Short_Name` ← Fund Management Company | | READY |
| K_FMS_152 | Người đại diện theo pháp luật | — | Cơ sở | `Item_Name` ← Fund Management Company Employee (FMS.TL_PROFILES) | | READY |
| K_FMS_153 | Số lượng nhân viên có CCHN | Người | Cơ sở | | **Lý do pending:** Dữ liệu động + chưa có Atomic entity cho `FMS.SECURITIES_REPORT`. **Atomic cần bổ sung:** entity cho `FMS.SECURITIES_REPORT` (Securities Company Periodic Report). **Mart dự kiến:** `Fund Management Company Profile`. | PENDING |
| K_FMS_154 | Số lượng Quỹ | Quỹ | Cơ sở | | **Lý do pending:** Dữ liệu động — nguồn COUNT(Investment Fund) theo Fund_Management_Company_Id. **Atomic cần bổ sung:** không — Investment Fund đã READY, chờ BA xác nhận quy tắc khai thác. **Mart dự kiến:** `Fund Management Company Profile`. | PENDING |
| K_FMS_155 | Xếp loại | — | Cơ sở | | **Lý do pending:** Dữ liệu động — nguồn `Rank_Index` ← Member Rating (FMS.RANK). **Atomic cần bổ sung:** không — Member Rating đã READY, chờ BA xác nhận quy tắc khai thác. **Mart dự kiến:** `Fund Management Company Profile`. | PENDING |
| K_FMS_156 | CAMEL | % | Cơ sở | | **Lý do pending:** Dữ liệu động — nguồn `Total_Score_Amount` ← Member Rating. **Atomic cần bổ sung:** không. **Mart dự kiến:** `Fund Management Company Profile`. | PENDING |
| K_FMS_157 | Vốn điều lệ | Tỷ VND | Cơ sở | | **Lý do pending:** Dữ liệu động — nguồn `Capital` ← Fund Management Company (FMS.SECURITIES). **Atomic cần bổ sung:** không. **Mart dự kiến:** `Fund Management Company Profile`. | PENDING |
| K_FMS_158 | AUM | Tỷ VND | Cơ sở | | **Lý do pending:** Dữ liệu động + chưa có Atomic entity cho `FMS.SECURITIES_REPORT`. **Atomic cần bổ sung:** entity cho `FMS.SECURITIES_REPORT`. **Mart dự kiến:** `Fund Management Company Profile`. | PENDING |
| K_FMS_159 | Thị phần | % | Phái sinh | | **Lý do pending:** Dữ liệu động + chưa có Atomic entity cho `FMS.SECURITIES_REPORT`. **Atomic cần bổ sung:** entity cho `FMS.SECURITIES_REPORT`. **Mart dự kiến:** `Fund Management Company Profile`. | PENDING |
| K_FMS_160 | CAR (ATTC) | % | Cơ sở | | **Lý do pending:** Dữ liệu động; BA chưa cung cấp Bảng nguồn/Trường nguồn. **Atomic cần bổ sung:** chưa xác định — chờ BA bổ sung Bảng nguồn. **Mart dự kiến:** `Fund Management Company Profile`. | PENDING |
| K_FMS_161 | Lợi nhuận | Tỷ VND | Cơ sở | | **Lý do pending:** Dữ liệu động + chưa có Atomic entity cho `FMS.SECURITIES_REPORT`. **Atomic cần bổ sung:** entity cho `FMS.SECURITIES_REPORT`. **Mart dự kiến:** `Fund Management Company Profile`. | PENDING |
| K_FMS_162 | Vốn CSH | Tỷ VND | Cơ sở | | **Lý do pending:** Dữ liệu động; BA chưa cung cấp Bảng nguồn/Trường nguồn. **Atomic cần bổ sung:** chưa xác định — chờ BA bổ sung Bảng nguồn. **Mart dự kiến:** `Fund Management Company Profile`. | PENDING |
| K_FMS_163 | Số lượng hợp đồng UTQLDM | HĐ | Cơ sở | | **Lý do pending:** Dữ liệu động — nguồn COUNT(Discretionary Investment Account) per CTQLQ. **Atomic cần bổ sung:** không — Discretionary Investment Account đã READY, chờ BA xác nhận quy tắc khai thác. **Mart dự kiến:** `Fund Management Company Profile`. | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_153, 158, 159, 161 | FMSQLQ.SECURITIES_REPORT | Securities Company Periodic Report *(chưa có LLD)* | TBD |
| K_FMS_154 | FMSQLQ.FUNDS | Investment Fund | investment_fund |
| K_FMS_155, 156 | FMSQLQ.RANK | Member Rating | member_rating |
| K_FMS_157 | FMSQLQ.SECURITIES | Fund Management Company | fund_management_company |
| K_FMS_160, 162 | *(BA chưa cung cấp)* | TBD | TBD |
| K_FMS_163 | FMSQLQ.INVES_ACC | Discretionary Investment Account | discretionary_investment_account |

**Schema bảng tác nghiệp — Fund Management Company Profile:**

```mermaid
erDiagram
    Fund_Management_Company_Profile {
        string Fund_Management_Company_Id PK
        string Company_Code
        string Company_Short_Name
        string Company_Name
        string Legal_Representative_Name
        string Source_System_Code
    }
```

> Chỉ 2 cột READY (`Company_Name`/`Company_Short_Name`, `Legal_Representative_Name`) được đưa vào schema — 11 cột còn lại đang PENDING (xem Bảng KPI), sẽ bổ sung vào schema này khi chuyển READY.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        G1["Fund Management Company Profile"]
    end
    subgraph RPT["Báo cáo"]
        R1["K_FMS_17,152: Danh sách CTQLQ (Nhóm 3)"]
    end
    G1 --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fund Management Company Profile | Tác nghiệp — bảng flat \| 1 CTQLQ × 1 tháng slicer |

---

#### Nhóm 4 - Chi tiết Quỹ của một CTQLQ

> Phân loại: **Tác nghiệp**
> Atomic: `Investment Fund` ← FMS.FUNDS — READY *(K_FMS_164: Tên quỹ)*
> Ghi chú: Popup drill-down khi bấm vào Số lượng Quỹ ở Nhóm 3 — FK về `Fund_Management_Company_Id`. Loại hình quỹ là Classification Value (scheme `FMS_FUND_TYPE`) → reuse `cl_dim`, không tạo Dimension riêng. Giá trị NAV BA đánh Dữ liệu động → PENDING.

**Mockup — popup "DANH SÁCH QUỸ":**

| Mã quỹ | Tên quỹ | Loại hình quỹ | NAV (tỷ) |
|---|---|---|---|
| QA1 | Quỹ ABC Cổ phần | Quỹ mở | 1.250 |

**Source:** `Fund Management Company Fund List`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_164 | Tên quỹ | — | Cơ sở | `Fund_Name` ← Investment Fund (FMS.FUNDS.Item_Name) | | READY |
| K_FMS_165 | Loại hình quỹ | — | Cơ sở | `Fund_Type_Code` ← Classification Dimension (scheme FMS_FUND_TYPE) | reuse `cl_dim` — xem Lớp 2 Reuse Analysis | READY |
| K_FMS_166 | Giá trị NAV của từng quỹ của CTQLQ | Tỷ VND | Cơ sở | | **Lý do pending:** Dữ liệu động — nguồn `FUNDS.NAV`. **Atomic cần bổ sung:** không — Investment Fund đã READY, chờ BA xác nhận quy tắc khai thác. **Mart dự kiến:** `Fund Management Company Fund List`. | PENDING |

**Schema bảng con — Fund Management Company Fund List:**

```mermaid
erDiagram
    Fund_Management_Company_Fund_List {
        string Fund_Management_Company_Id PK
        string Investment_Fund_Id PK
        string Fund_Code
        string Fund_Name
        string Fund_Type_Code
        string Source_System_Code
    }
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        G1["Fund Management Company Fund List"]
    end
    subgraph RPT["Báo cáo"]
        R1["K_FMS_164-165: Chi tiết Quỹ của một CTQLQ (Nhóm 4)"]
    end
    G1 --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fund Management Company Fund List | Tác nghiệp — bảng con drill-down \| 1 quỹ × 1 CTQLQ × 1 tháng slicer |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_166 | FMSQLQ.FUNDS | Investment Fund | investment_fund |

---

#### Nhóm 5 - Chi tiết các hợp đồng UTDM của CTQLQ

> Phân loại: **Tác nghiệp**
> Atomic: `Discretionary Investment Account` ← FMS.INVES_ACC — READY *(K_FMS_167, K_FMS_168: Mã HĐ, Số TK lưu ký)*
> Ghi chú: Popup drill-down khi bấm vào Số lượng HĐ UTQLDM ở Nhóm 3 — FK về `Fund_Management_Company_Id`. Giá trị hợp đồng BA đánh Dữ liệu động → PENDING.

**Mockup — popup "DANH SÁCH HĐ UTDM":**

| Mã HĐ | Số TK lưu ký | Giá trị (tỷ) |
|---|---|---|
| HĐ001 | 001C123456 | 25.4 |

**Source:** `Fund Management Company Contract List`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_167 | Mã số hợp đồng UTQLDM | — | Cơ sở | `Contract_Number` ← Discretionary Investment Account (FMS.INVES_ACC.Contract_No) | | READY |
| K_FMS_168 | Số tài khoản lưu ký | — | Cơ sở | `Account_Number` ← Discretionary Investment Account (FMS.INVES_ACC.Account) | | READY |
| K_FMS_169 | Giá trị của từng hợp đồng UTDM của CTQLQ | Tỷ VND | Cơ sở | | **Lý do pending:** Dữ liệu động — nguồn `INVES_ACC.LIST_VALUE`. **Atomic cần bổ sung:** không — Discretionary Investment Account đã READY, chờ BA xác nhận quy tắc khai thác. **Mart dự kiến:** `Fund Management Company Contract List`. | PENDING |

**Schema bảng con — Fund Management Company Contract List:**

```mermaid
erDiagram
    Fund_Management_Company_Contract_List {
        string Fund_Management_Company_Id PK
        string Discretionary_Investment_Account_Id PK
        string Account_Number
        string Contract_Number
        string Source_System_Code
    }
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        G1["Fund Management Company Contract List"]
    end
    subgraph RPT["Báo cáo"]
        R1["K_FMS_167-168: Chi tiết HĐ UTDM của CTQLQ (Nhóm 5)"]
    end
    G1 --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fund Management Company Contract List | Tác nghiệp — bảng con drill-down \| 1 Discretionary Investment Account × 1 CTQLQ × 1 tháng slicer |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_169 | FMSQLQ.INVES_ACC | Discretionary Investment Account | discretionary_investment_account |

---

### Tab: QUỸ ĐẦU TƯ

**Slicer chung:** Tháng/Năm (tháng slicer); một số nhóm có thêm slicer Từ tháng / Đến tháng

---

#### Nhóm 6 - Thống kê chung của QĐT

> Phân loại: **Phân tích**
> Atomic: `Investment Fund` ← FMS.FUNDS — READY *(K_FMS_170–K_FMS_173 — BA đánh "Dữ liệu động" nên PENDING)*
> Ghi chú: **Toàn bộ Nhóm PENDING** — BA đánh Dữ liệu động cho cả 4 chỉ tiêu cơ sở (Tổng số QĐT, Số quỹ theo loại hình, Tổng NAV, Tổng NAV theo loại hình). Chiều "Thời gian" tự nó Dữ liệu tĩnh nhưng không còn measure nào READY đi kèm → PENDING toàn bộ Nhóm. Loại hình quỹ là Classification Value (scheme `FMS_FUND_TYPE`).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_170a | Thời gian | — | Chiều | | **Lý do pending:** Nhóm không còn measure nào READY. **Atomic cần bổ sung:** không. **Mart dự kiến:** `Fact Investment Fund Count Snapshot` — grain: 1 loại hình quỹ × 1 tháng. | PENDING |
| K_FMS_170 | Tổng số lượng QĐT | Quỹ | Cơ sở | | **Lý do pending:** Dữ liệu động — nguồn COUNT(Investment Fund). **Atomic cần bổ sung:** không — Investment Fund đã READY, chờ BA xác nhận quy tắc khai thác. **Mart dự kiến:** `Fact Investment Fund Count Snapshot`. | PENDING |
| K_FMS_171 | Số lượng quỹ theo từng loại hình quỹ | Quỹ | Cơ sở | | **Lý do pending:** Dữ liệu động — nguồn COUNT(Investment Fund) GROUP BY Fund_Type_Code. **Atomic cần bổ sung:** không. **Mart dự kiến:** `Fact Investment Fund Count Snapshot`. | PENDING |
| K_FMS_172 | Tổng giá trị NAV | Tỷ VND | Cơ sở | | **Lý do pending:** Dữ liệu động — nguồn SUM(Investment Fund.NAV). **Atomic cần bổ sung:** không. **Mart dự kiến:** `Fact Investment Fund Count Snapshot`. | PENDING |
| K_FMS_173 | Tổng giá trị NAV của từng loại hình quỹ | Tỷ VND | Cơ sở | | **Lý do pending:** Dữ liệu động — nguồn SUM(Investment Fund.NAV) GROUP BY Fund_Type_Code. **Atomic cần bổ sung:** không. **Mart dự kiến:** `Fact Investment Fund Count Snapshot`. | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_170, 171, 172, 173 | FMSQLQ.FUNDS, FMSQLQ.FUND_TYPE | Investment Fund | investment_fund |

---

#### Nhóm 7 - Biểu đồ Tổng NAV Quỹ và Tỷ lệ NAV/GDP

> Phân loại: **Phân tích**
> Ghi chú: **PENDING toàn bộ.** K_FMS_33 (GDP) BA đánh Dữ liệu tĩnh nhưng Atomic nguồn (`Risk Indicator Value`, QLRR.risk_indicator_value) chỉ tồn tại ở `DataModel/working/Atomic_LinhLV/` — track cá nhân đã lỗi thời (out of date), KHÔNG phải nguồn Atomic chuẩn (chuẩn chỉ gồm `DataModel/Atomic/` và `DataModel/working/Atomic/`) → PENDING, cần Atomic team thiết kế lại trong track chuẩn. Còn lại (Loại hình quỹ, Tổng NAV của quỹ, Tổng NAV từng loại hình, Tỷ lệ NAV/GDP) BA đánh Dữ liệu động → PENDING; nguồn NAV lấy trực tiếp từ `FMS.FUND_REPORT` — `FUND_REPORT` chưa có Atomic entity (giống Nhóm 1/3).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_38a | Thời gian | — | Chiều | | **Lý do pending:** Không có measure NAV nào READY cùng Fact để ghép cùng Chiều thời gian. **Atomic cần bổ sung:** entity cho `FMS.FUND_REPORT`. **Mart dự kiến:** `Fact Investment Fund NAV Snapshot` — grain: 1 quỹ × 1 tháng. | PENDING |
| K_FMS_36 | Loại hình quỹ | — | Chiều | | **Lý do pending:** Dữ liệu động — nguồn `Fund_Type_Code` ← Investment Fund/Classification Dimension (scheme FMS_FUND_TYPE). **Atomic cần bổ sung:** không. **Mart dự kiến:** `Fact Investment Fund NAV Snapshot`. | PENDING |
| K_FMS_32 | Tổng NAV của quỹ | Tỷ VND | Cơ sở | | **Lý do pending:** Dữ liệu động + chưa có Atomic entity cho `FMS.FUND_REPORT`. **Atomic cần bổ sung:** entity cho `FMS.FUND_REPORT` (Fund NAV/Property Report). **Mart dự kiến:** `Fact Investment Fund NAV Snapshot`. | PENDING |
| K_FMS_33 | GDP | Nghìn tỷ VND | Cơ sở | | **Lý do pending:** Dữ liệu tĩnh nhưng Atomic nguồn (`Risk Indicator Value`, QLRR) chỉ có ở track `Atomic_LinhLV` (out of date, không phải nguồn chuẩn). **Atomic cần bổ sung:** thiết kế lại `Risk Indicator Value` (QLRR) trong `DataModel/Atomic/` hoặc `DataModel/working/Atomic/`. **Mart dự kiến:** `Fact Investment Fund NAV Snapshot`. | PENDING |
| K_FMS_37 | Tỷ lệ NAV/GDP | % | Phái sinh | | **Lý do pending:** Phụ thuộc K_FMS_32 (PENDING) — K_FMS_32/K_FMS_33 × 100%. **Atomic cần bổ sung:** như K_FMS_32. **Mart dự kiến:** `Fact Investment Fund NAV Snapshot`. | PENDING |
| K_FMS_35 | Tổng NAV của từng loại hình quỹ | Tỷ VND | Phái sinh | | **Lý do pending:** Dữ liệu động + chưa có Atomic entity cho `FMS.FUND_REPORT` — SUM(K_FMS_32) GROUP BY Fund_Type_Code. **Atomic cần bổ sung:** entity cho `FMS.FUND_REPORT`. **Mart dự kiến:** `Fact Investment Fund NAV Snapshot`. | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_36 | FMSQLQ.FUND_TYPE | Classification Value (scheme FMS_FUND_TYPE) | cv |
| K_FMS_32, 35, 37 | FMSQLQ.FUND_REPORT | Fund NAV/Property Report *(chưa có LLD)* | TBD |
| K_FMS_33 | SIT_MRMS.RISK_INDICATOR_VALUE | Risk Indicator Value *(có draft ở Atomic_LinhLV — cần thiết kế lại trong track chuẩn)* | rsk_ind_val |

---

#### Nhóm 8 - Biểu đồ Phân bổ tài sản của Quỹ đầu tư

> Phân loại: **Phân tích**
> Atomic: chưa xác định — Ghi chú
> Ghi chú: **PENDING toàn bộ.** BA đánh Dữ liệu động cho toàn bộ 6 chỉ tiêu phân bổ tài sản (CP niêm yết, CP chưa niêm yết, TP, Tiền, CK khác, TS khác) và Chiều "Thời gian" — nguồn `FMS.FUND_REPORT`, chưa có Atomic entity. Reuse `Fact Investment Fund NAV Snapshot` (xem Nhóm 7) khi Fact này chuyển READY.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_38a | Thời gian | — | Chiều | | **Lý do pending:** Reuse từ Nhóm 7 — Fact `Fact Investment Fund NAV Snapshot` chưa có measure nào READY. **Atomic cần bổ sung:** entity cho `FMS.FUND_REPORT`. **Mart dự kiến:** `Fact Investment Fund NAV Snapshot`. | PENDING |
| K_FMS_39 | Cổ phiếu niêm yết | Tỷ VND | Phái sinh | | **Lý do pending:** Dữ liệu động + chưa có Atomic entity cho `FMS.FUND_REPORT` (cột PROP_PUBLIC_STOCK). **Atomic cần bổ sung:** entity cho `FMS.FUND_REPORT` (Fund NAV/Property Report). **Mart dự kiến:** `Fact Investment Fund NAV Snapshot`. | PENDING |
| K_FMS_40 | Cổ phiếu chưa niêm yết | Tỷ VND | Phái sinh | | **Lý do pending:** Tương tự K_FMS_39, cột PROP_PRIVATE_STOCK. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund NAV Snapshot`. | PENDING |
| K_FMS_41 | Trái phiếu | Tỷ VND | Phái sinh | | **Lý do pending:** Tương tự K_FMS_39, cột PROP_BONDS. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund NAV Snapshot`. | PENDING |
| K_FMS_42 | Tiền | Tỷ VND | Phái sinh | | **Lý do pending:** Tương tự K_FMS_39, cột PROP_MONEY. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund NAV Snapshot`. | PENDING |
| K_FMS_43 | Các loại chứng khoán khác | Tỷ VND | Phái sinh | | **Lý do pending:** Tương tự K_FMS_39, cột PROP_OTHER_STOCK. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund NAV Snapshot`. | PENDING |
| K_FMS_44 | Các tài sản khác | Tỷ VND | Phái sinh | | **Lý do pending:** Tương tự K_FMS_39, cột PROP_OTHER_PROPERTY. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund NAV Snapshot`. | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_39, 40, 41, 42, 43, 44 | FMSQLQ.FUND_REPORT | Fund NAV/Property Report *(chưa có LLD)* | TBD |

---

#### Nhóm 9 - Sự biến động về NAV của các Quỹ ĐTCK

> Phân loại: **Phân tích**
> Ghi chú: **PENDING toàn bộ.** BA đánh Dữ liệu động cho cả Chiều "Thời gian" lẫn NAV của các quỹ, Tăng trưởng NAV từng tháng, Trung bình tăng trưởng NAV — nguồn `FMS.FUND_REPORT`, chưa có Atomic entity. Reuse `Fact Investment Fund NAV Snapshot` (xem Nhóm 7).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_38a | Thời gian | — | Chiều | | **Lý do pending:** Reuse từ Nhóm 7. **Atomic cần bổ sung:** entity cho `FMS.FUND_REPORT`. **Mart dự kiến:** `Fact Investment Fund NAV Snapshot` — grain: 1 quỹ × 1 tháng. | PENDING |
| K_FMS_47 | NAV của các quỹ ĐTCK | Tỷ VND | Cơ sở | | **Lý do pending:** Dữ liệu động + chưa có Atomic entity cho `FMS.FUND_REPORT`. Reuse ý nghĩa với K_FMS_32 (Nhóm 7) nhưng cấp ID riêng vì BA liệt kê dòng độc lập ở Nhóm này. **Atomic cần bổ sung:** entity cho `FMS.FUND_REPORT`. **Mart dự kiến:** `Fact Investment Fund NAV Snapshot`. | PENDING |
| K_FMS_48 | Tăng trưởng NAV từng tháng | % | Phái sinh | | **Lý do pending:** Phụ thuộc K_FMS_47 (PENDING) — (NAV[T] − NAV[T−1]) / NAV[T−1] × 100%. **Atomic cần bổ sung:** như K_FMS_47. **Mart dự kiến:** `Fact Investment Fund NAV Snapshot`. | PENDING |
| K_FMS_49 | Trung bình tăng trưởng NAV | % | Phái sinh | | **Lý do pending:** Phụ thuộc K_FMS_48 (PENDING) — AVG(K_FMS_48) trong khoảng thời gian chọn. **Atomic cần bổ sung:** như K_FMS_47. **Mart dự kiến:** `Fact Investment Fund NAV Snapshot`. | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_47, 48, 49 | FMSQLQ.FUND_REPORT | Fund NAV/Property Report *(chưa có LLD)* | TBD |

---

#### Nhóm 10 - Số lượng quỹ đầu tư chứng khoán

> Phân loại: **Phân tích**
> Atomic: `Investment Fund` ← FMS.FUNDS — READY *(K_FMS_51: Loại hình quỹ — Dữ liệu tĩnh)*
> Ghi chú: **Mix READY/PENDING.** Chiều "Thời gian" và "Loại hình quỹ" BA đánh Dữ liệu tĩnh → READY. 7 chỉ tiêu phái sinh (đếm số quỹ theo từng loại hình) BA đánh Dữ liệu động, nguồn `FMS.FUND_REPORT.FUND_ID` → PENDING toàn bộ vì Fact không còn measure nào READY để hiển thị cùng 2 Chiều.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_50a | Thời gian | — | Chiều | | **Lý do pending:** Không còn measure nào READY cùng Fact để ghép cùng Chiều. **Atomic cần bổ sung:** entity cho `FMS.FUND_REPORT`. **Mart dự kiến:** `Fact Investment Fund Count Snapshot` — grain: 1 loại hình quỹ × 1 tháng. | PENDING |
| K_FMS_51 | Loại hình quỹ | — | Chiều | | **Lý do pending:** Atomic sẵn sàng (Investment Fund, Classification Dimension scheme FMS_FUND_TYPE) và Dữ liệu tĩnh, nhưng không có measure nào cùng Fact để ghép. **Atomic cần bổ sung:** không — chờ measure READY. **Mart dự kiến:** `Fact Investment Fund Count Snapshot`. | PENDING |
| K_FMS_52a | Quỹ mở | Quỹ | Phái sinh | | **Lý do pending:** Dữ liệu động + chưa có Atomic entity cho `FMS.FUND_REPORT`. **Atomic cần bổ sung:** entity cho `FMS.FUND_REPORT` (Fund NAV/Property Report). **Mart dự kiến:** `Fact Investment Fund Count Snapshot`. | PENDING |
| K_FMS_52b | Quỹ thành viên | Quỹ | Phái sinh | | **Lý do pending:** Tương tự K_FMS_52a. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund Count Snapshot`. | PENDING |
| K_FMS_52c | Quỹ ETF | Quỹ | Phái sinh | | **Lý do pending:** Tương tự K_FMS_52a. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund Count Snapshot`. | PENDING |
| K_FMS_52d | Quỹ đóng | Quỹ | Phái sinh | | **Lý do pending:** Tương tự K_FMS_52a. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund Count Snapshot`. | PENDING |
| K_FMS_52e | Quỹ BĐS | Quỹ | Phái sinh | | **Lý do pending:** Tương tự K_FMS_52a. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund Count Snapshot`. | PENDING |
| K_FMS_174 | Quỹ đầu tư công cụ thị trường tiền tệ | Quỹ | Phái sinh | | **Lý do pending:** Tương tự K_FMS_52a. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund Count Snapshot`. | PENDING |
| K_FMS_175 | Quỹ đầu tư trái phiếu hạ tầng | Quỹ | Phái sinh | | **Lý do pending:** Tương tự K_FMS_52a. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund Count Snapshot`. | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_52a, 52b, 52c, 52d, 52e, 174, 175 | FMSQLQ.FUND_REPORT | Fund NAV/Property Report *(chưa có LLD)* | TBD |

---

#### Nhóm 11 - Tăng trưởng số lượng CCQ lưu hành của các quỹ đầu tư

> Phân loại: **Phân tích**
> Atomic: `Investment Fund` ← FMS.FUNDS — READY *(K_FMS_54: Loại hình quỹ — Dữ liệu tĩnh)*
> Ghi chú: **PENDING toàn bộ** — tương tự Nhóm 10. Nguồn CCQ lưu hành là `FMS.FUND_REPORT.TOTAL_CCQ` trực tiếp, BA đánh Dữ liệu động cho toàn bộ 6 chỉ tiêu phái sinh (theo loại hình quỹ) → Fact không còn measure nào READY để ghép cùng 2 Chiều (Thời gian, Loại hình quỹ — dù bản thân Loại hình quỹ Dữ liệu tĩnh).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_53a | Thời gian | — | Chiều | | **Lý do pending:** Không còn measure nào READY cùng Fact. **Atomic cần bổ sung:** entity cho `FMS.FUND_REPORT`. **Mart dự kiến:** `Fact Investment Fund CCQ Snapshot` — grain: 1 loại hình quỹ × 1 tháng. | PENDING |
| K_FMS_54 | Loại hình quỹ | — | Chiều | | **Lý do pending:** Atomic sẵn sàng (Investment Fund) và Dữ liệu tĩnh, nhưng không có measure nào cùng Fact để ghép. **Atomic cần bổ sung:** không — chờ measure READY. **Mart dự kiến:** `Fact Investment Fund CCQ Snapshot`. | PENDING |
| K_FMS_55a | Quỹ mở | CCQ | Phái sinh | | **Lý do pending:** Dữ liệu động + chưa có Atomic entity cho `FMS.FUND_REPORT` (cột TOTAL_CCQ). **Atomic cần bổ sung:** entity cho `FMS.FUND_REPORT`. **Mart dự kiến:** `Fact Investment Fund CCQ Snapshot`. | PENDING |
| K_FMS_55b | Quỹ ETF | CCQ | Phái sinh | | **Lý do pending:** Tương tự K_FMS_55a. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund CCQ Snapshot`. | PENDING |
| K_FMS_55c | Quỹ đóng | CCQ | Phái sinh | | **Lý do pending:** Tương tự K_FMS_55a — dùng chung nguồn FUND_REPORT.TOTAL_CCQ cho quỹ đóng. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund CCQ Snapshot`. | PENDING |
| K_FMS_55d | Quỹ BĐS | CCQ | Phái sinh | | **Lý do pending:** Tương tự K_FMS_55a. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund CCQ Snapshot`. | PENDING |
| K_FMS_55e | Quỹ thành viên | CCQ | Phái sinh | | **Lý do pending:** Tương tự K_FMS_55a. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund CCQ Snapshot`. | PENDING |
| K_FMS_176 | Quỹ đầu tư công cụ thị trường tiền tệ | CCQ | Phái sinh | | **Lý do pending:** Tương tự K_FMS_55a. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund CCQ Snapshot`. | PENDING |
| K_FMS_177 | Quỹ đầu tư trái phiếu hạ tầng | CCQ | Phái sinh | | **Lý do pending:** Tương tự K_FMS_55a. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund CCQ Snapshot`. | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_55a, 55b, 55c, 55d, 55e, 176, 177 | FMSQLQ.FUND_REPORT | Fund NAV/Property Report *(chưa có LLD)* | TBD |

---

#### Nhóm 12 - Tỉ lệ tăng trưởng NAV/CCQ một năm theo loại hình quỹ so với VN-Index và Lãi suất liên ngân hàng qua đêm

> Phân loại: **Phân tích**
> Ghi chú: **PENDING toàn bộ.** Grain của Nhóm này là 1 loại hình quỹ chi tiết × 1 tháng, join theo `FMS.FUND_REPORT.EXCUTION_DATE` — nhưng `FUND_REPORT` hoàn toàn chưa có Atomic entity (giống Nhóm 1/3/7-11). Do đó Chiều "Thời gian" (K_FMS_56a) tự nó cũng PENDING — nguồn `Excution_Date` thuộc bảng chưa có Atomic thì không thể READY. VN-Index (K_FMS_178, nguồn `MDDS.JAD_MARKETINFOR` — track chuẩn, approved) và Lãi suất LNH qua đêm (K_FMS_61, nguồn `Risk Indicator Value` — chỉ có ở track `Atomic_LinhLV`, out of date) đều là measure macro-level cần denormalize theo đúng grain của Fact này, nhưng không có Chiều thời gian hợp lệ ở đúng grain đó để ghép cùng cho tới khi `FUND_REPORT` sẵn sàng — nên PENDING theo luôn, không tách riêng thành 1 Fact khác chỉ để hiển thị 2 measure macro độc lập.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_56a | Thời gian | — | Chiều | | **Lý do pending:** Nguồn `Excution_Date` thuộc `FMS.FUND_REPORT` — chưa có Atomic entity. **Atomic cần bổ sung:** entity cho `FMS.FUND_REPORT` (Fund NAV/Property Report). **Mart dự kiến:** `Fact Investment Fund NAV per CCQ Snapshot` — grain: 1 loại hình quỹ chi tiết × 1 tháng. | PENDING |
| K_FMS_178 | VN-Index | Điểm | Cơ sở | | **Lý do pending:** Atomic nguồn (`Market Index Snapshot`, MDDS.JAD_MARKETINFOR) đã sẵn sàng, nhưng không có Chiều thời gian hợp lệ ở đúng grain (loại hình quỹ × tháng) của Fact này để ghép cùng — chờ K_FMS_56a READY. **Atomic cần bổ sung:** entity cho `FMS.FUND_REPORT` (để có Chiều thời gian join). **Mart dự kiến:** `Fact Investment Fund NAV per CCQ Snapshot`. | PENDING |
| K_FMS_61 | Lãi suất liên ngân hàng qua đêm | %/năm | Cơ sở | | **Lý do pending:** Dữ liệu tĩnh nhưng Atomic nguồn (`Risk Indicator Value`, QLRR) chỉ có ở track `Atomic_LinhLV` (out of date, không phải nguồn chuẩn); đồng thời cũng chờ K_FMS_56a READY để có Chiều thời gian ghép cùng. **Atomic cần bổ sung:** thiết kế lại `Risk Indicator Value` (QLRR) trong `DataModel/Atomic/` hoặc `DataModel/working/Atomic/`; và entity cho `FMS.FUND_REPORT`. **Mart dự kiến:** `Fact Investment Fund NAV per CCQ Snapshot`. | PENDING |
| K_FMS_179 | Loại hình quỹ chi tiết | — | Chiều | | **Lý do pending:** Dữ liệu động — nguồn Classification Value (FMS_FUND_TYPE), nhưng measure NAV/CCQ gắn cùng đang PENDING. **Atomic cần bổ sung:** entity cho `FMS.FUND_REPORT`. **Mart dự kiến:** `Fact Investment Fund NAV per CCQ Snapshot`. | PENDING |
| K_FMS_180 | NAV/CCQ | VND/CCQ | Cơ sở | | **Lý do pending:** Dữ liệu động + chưa có Atomic entity cho `FMS.FUND_REPORT` (cột NAV_CCQ). **Atomic cần bổ sung:** entity cho `FMS.FUND_REPORT`. **Mart dự kiến:** `Fact Investment Fund NAV per CCQ Snapshot`. | PENDING |
| K_FMS_181 | Tỷ lệ tăng trưởng NAV/CCQ | % | Phái sinh | | **Lý do pending:** Phụ thuộc K_FMS_180 (PENDING). **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund NAV per CCQ Snapshot`. | PENDING |
| K_FMS_182 | Quỹ mở CP | VND/CCQ | Phái sinh | | **Lý do pending:** Dữ liệu động + chưa có Atomic entity cho `FMS.FUND_REPORT`. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund NAV per CCQ Snapshot`. | PENDING |
| K_FMS_183 | Quỹ mở TP | VND/CCQ | Phái sinh | | **Lý do pending:** Tương tự K_FMS_182. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund NAV per CCQ Snapshot`. | PENDING |
| K_FMS_184 | Quỹ mở cân bằng | VND/CCQ | Phái sinh | | **Lý do pending:** Tương tự K_FMS_182. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund NAV per CCQ Snapshot`. | PENDING |
| K_FMS_60 | Quỹ ETF | VND/CCQ | Phái sinh | | **Lý do pending:** Tương tự K_FMS_182 — nguồn FUND_REPORT.NAV_CCQ trực tiếp. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund NAV per CCQ Snapshot`. | PENDING |
| K_FMS_185 | Quỹ đóng | VND/CCQ | Phái sinh | | **Lý do pending:** Tương tự K_FMS_182. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund NAV per CCQ Snapshot`. | PENDING |
| K_FMS_186 | Quỹ BĐS | VND/CCQ | Phái sinh | | **Lý do pending:** Tương tự K_FMS_182. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund NAV per CCQ Snapshot`. | PENDING |
| K_FMS_187 | Quỹ thành viên | VND/CCQ | Phái sinh | | **Lý do pending:** Tương tự K_FMS_182. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund NAV per CCQ Snapshot`. | PENDING |
| K_FMS_188 | Quỹ đầu tư công cụ thị trường tiền tệ | VND/CCQ | Phái sinh | | **Lý do pending:** Tương tự K_FMS_182. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund NAV per CCQ Snapshot`. | PENDING |
| K_FMS_189 | Quỹ đầu tư trái phiếu hạ tầng | VND/CCQ | Phái sinh | | **Lý do pending:** Tương tự K_FMS_182. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fact Investment Fund NAV per CCQ Snapshot`. | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_56a, 179, 180, 181, 182, 183, 184, 60, 185, 186, 187, 188, 189 | FMSQLQ.FUND_REPORT, FMSQLQ.FUND_TYPE | Fund NAV/Property Report *(chưa có LLD)* | TBD |
| K_FMS_178 | MDDS.JAD_MARKETINFOR | Market Index Snapshot *(đã approved — chờ Chiều thời gian đúng grain)* | market_index_snapshot |
| K_FMS_61 | SIT_MRMS.RISK_INDICATOR_VALUE | Risk Indicator Value *(có draft ở Atomic_LinhLV — cần thiết kế lại trong track chuẩn)* | rsk_ind_val |

---

#### Nhóm 13 - Danh sách các quỹ đầu tư

> Phân loại: **Tác nghiệp**
> Atomic: `Investment Fund` ← FMS.FUNDS — READY *(K_FMS_62, 64: Tên quỹ, Phân loại)*
> Atomic: `Fund Management Company` ← FMS.SECURITIES — READY *(K_FMS_63: Công ty quản lý)*
> Atomic: `Custodian Bank` ← FMS.BANK_MONI — READY *(K_FMS_190: Ngân hàng giám sát)*
> Atomic: `Fund Distribution Agent` ← FMS.AGENCIES — READY *(K_FMS_191: Số lượng đại lý phân phối)*
> Atomic: `Investment Fund Representative Board Member` ← FMS.REPRESENT — READY *(K_FMS_192: Số lượng thành viên ban đại diện)*
> Atomic: `Fund Management Company Employee` ← FMS.TL_PROFILES — READY *(K_FMS_193: Số lượng người điều hành quỹ)*
> Ghi chú: **Mix READY/PENDING.** 8/11 chỉ tiêu BA đánh Dữ liệu tĩnh → READY (Ngân hàng giám sát, Số lượng ĐLPP, Số lượng thành viên BĐD, Số lượng người điều hành quỹ). 3 chỉ tiêu còn lại (NAV hiện tại, KL CCQ lưu hành, Lợi nhuận YTD) BA đánh Dữ liệu động → PENDING; nguồn NAV/KL CCQ là `FMS.FUNDS.NAV`/`NAV_CCQ` trực tiếp; Lợi nhuận YTD BA chưa cung cấp Bảng nguồn.

**Mockup:**

| Tên quỹ | Công ty quản lý | Phân loại | NH giám sát | Số ĐLPP | Số TV BĐD | Số người điều hành | NAV (tỷ) | LN YTD (tỷ) | KL CCQ lưu hành |
|---|---|---|---|---|---|---|---|---|---|
| Q1 / Quỹ ABC 1 | Công ty ABC 1 | Quỹ mở | NH Vietcombank | 3 | 5 | 2 | 12.580 | 120.4 | 188.481.686 |

**Source:** `Investment Fund Profile`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_62a | Thời gian | — | Chiều | `Id_Date` ← Investment Fund (FMS.FUNDS) | | READY |
| K_FMS_62 | Tên quỹ | — | Chiều | `Fund_Name`, `Fund_Short_Name` ← Investment Fund (FMS.FUNDS) | | READY |
| K_FMS_64 | Phân loại | — | Chiều | `Fund_Type_Code` ← Investment Fund/Classification Dimension (scheme FMS_FUND_TYPE) | reuse `cl_dim` | READY |
| K_FMS_63 | Công ty quản lý | — | Cơ sở | `Company_Short_Name` ← Fund Management Company (FMS.SECURITIES) | | READY |
| K_FMS_190 | Ngân hàng giám sát | — | Cơ sở | `Item_Name` ← Custodian Bank (FMS.BANK_MONI) | | READY |
| K_FMS_191 | Số lượng đại lý phân phối | Đại lý | Cơ sở | COUNT(Fund Distribution Agent) per quỹ, join AGEN_FUNDS | | READY |
| K_FMS_192 | Số lượng thành viên ban đại diện | Người | Cơ sở | COUNT(Fund Representative) per quỹ | | READY |
| K_FMS_193 | Số lượng người điều hành quỹ | Người | Cơ sở | COUNT(Fund Management Company Employee) per quỹ | | READY |
| K_FMS_65 | NAV hiện tại | Tỷ VND | Cơ sở | | **Lý do pending:** Dữ liệu động — nguồn `FUNDS.NAV` trực tiếp. **Atomic cần bổ sung:** không — Investment Fund đã READY, chờ BA xác nhận quy tắc khai thác. **Mart dự kiến:** `Investment Fund Profile` — grain: 1 quỹ × 1 tháng slicer. | PENDING |
| K_FMS_67 | KL CCQ đang lưu hành | CCQ | Phái sinh | | **Lý do pending:** Dữ liệu động — nguồn `FUNDS.NAV`/`FUNDS.NAV_CCQ`. **Atomic cần bổ sung:** không. **Mart dự kiến:** `Investment Fund Profile`. | PENDING |
| K_FMS_66 | Lợi nhuận YTD | Tỷ VND | Phái sinh | | **Lý do pending:** Dữ liệu động; BA chưa cung cấp Bảng nguồn/Trường nguồn. **Atomic cần bổ sung:** chưa xác định — chờ BA bổ sung Bảng nguồn. **Mart dự kiến:** `Investment Fund Profile`. | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_65, 67 | FMSQLQ.FUNDS | Investment Fund | investment_fund |
| K_FMS_66 | *(BA chưa cung cấp)* | TBD | TBD |

**Schema bảng tác nghiệp — Investment Fund Profile:**

```mermaid
erDiagram
    Investment_Fund_Profile {
        string Investment_Fund_Id PK
        string Fund_Management_Company_Id
        string Fund_Code
        string Fund_Short_Name
        string Fund_Name
        string Fund_Type_Code
        string Custodian_Bank_Name
        int Distribution_Agent_Count
        int Representative_Count
        int Employee_Count
        string Source_System_Code
    }
```

> Chỉ các cột READY được đưa vào schema — `NAV_Amount`/`Outstanding_Unit_Count`/`YTD_Profit_Amount` đang PENDING (xem Bảng KPI), sẽ bổ sung khi chuyển READY.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        G1["Investment Fund Profile"]
    end
    subgraph RPT["Báo cáo"]
        R1["K_FMS_62a,62,64,63,190-193: Danh sách các quỹ đầu tư (Nhóm 13)"]
    end
    G1 --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Investment Fund Profile | 1 quỹ × 1 tháng slicer |

---

#### Nhóm 14 - Danh sách đại lý phân phối

> Phân loại: **Tác nghiệp**
> Atomic: `Fund Distribution Agent` ← FMS.AGENCIES — READY *(K_FMS_194: Danh sách đại lý phân phối)*
> Ghi chú: Popup drill-down khi bấm vào Số lượng đại lý phân phối ở Nhóm 13 (K_FMS_191) — FK về `Investment_Fund_Id`, join `Investment Fund X Fund Distribution Agent Relationship` (FMS.AGEN_FUNDS).

**Mockup — popup "DANH SÁCH ĐẠI LÝ PHÂN PHỐI":**

| Tên đại lý phân phối |
|---|
| Công ty Chứng khoán XYZ |

**Source:** `Investment Fund Distribution Agent List`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_194 | Danh sách đại lý phân phối | — | Cơ sở | `Item_Name` ← Fund Distribution Agent (FMS.AGENCIES), join Investment Fund X Fund Distribution Agent Relationship (FMS.AGEN_FUNDS) | | READY |

**Schema bảng con — Investment Fund Distribution Agent List:**

```mermaid
erDiagram
    Investment_Fund_Distribution_Agent_List {
        string Investment_Fund_Id PK
        string Fund_Distribution_Agent_Id PK
        string Fund_Distribution_Agent_Name
        string Source_System_Code
    }
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        G1["Investment Fund Distribution Agent List"]
    end
    subgraph RPT["Báo cáo"]
        R1["K_FMS_194: Danh sách đại lý phân phối (Nhóm 14)"]
    end
    G1 --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Investment Fund Distribution Agent List | Tác nghiệp — bảng con drill-down \| 1 đại lý phân phối × 1 quỹ |

---

#### Nhóm 15 - Danh sách thành viên ban đại diện

> Phân loại: **Tác nghiệp**
> Atomic: `Investment Fund Representative Board Member` ← FMS.REPRESENT — READY *(K_FMS_195: Danh sách thành viên ban đại diện)*
> Ghi chú: Popup drill-down khi bấm vào Số lượng thành viên ban đại diện ở Nhóm 13 (K_FMS_192) — FK về `Investment_Fund_Id`.

**Mockup — popup "DANH SÁCH THÀNH VIÊN BAN ĐẠI DIỆN":**

| Tên thành viên |
|---|
| Nguyễn Văn A |

**Source:** `Investment Fund Representative Board Member List`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_195 | Danh sách thành viên ban đại diện | — | Cơ sở | `Item_Name` ← Investment Fund Representative Board Member (FMS.REPRESENT) | | READY |

**Schema bảng con — Investment Fund Representative Board Member List:**

```mermaid
erDiagram
    Investment_Fund_Representative_Board_Member_List {
        string Investment_Fund_Id PK
        string Representative_Board_Member_Id PK
        string Representative_Board_Member_Name
        string Source_System_Code
    }
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        G1["Investment Fund Representative Board Member List"]
    end
    subgraph RPT["Báo cáo"]
        R1["K_FMS_195: Danh sách thành viên ban đại diện (Nhóm 15)"]
    end
    G1 --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Investment Fund Representative Board Member List | Tác nghiệp — bảng con drill-down \| 1 thành viên BĐD × 1 quỹ |

---

#### Nhóm 16 - Danh sách người điều hành quỹ

> Phân loại: **Tác nghiệp**
> Atomic: `Fund Management Company Employee` ← FMS.TL_PROFILES — READY *(K_FMS_196: Danh sách người điều hành quỹ)*
> Ghi chú: Popup drill-down khi bấm vào Số lượng người điều hành quỹ ở Nhóm 13 (K_FMS_193) — FK về `Investment_Fund_Id`, join `FMS.FUND_TL_PRO`.

**Mockup — popup "DANH SÁCH NGƯỜI ĐIỀU HÀNH QUỸ":**

| Tên người điều hành |
|---|
| Trần Thị B |

**Source:** `Investment Fund Manager List`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_196 | Danh sách người điều hành quỹ | — | Cơ sở | `Item_Name` ← Fund Management Company Employee (FMS.TL_PROFILES), join FMS.FUND_TL_PRO | | READY |

**Schema bảng con — Investment Fund Manager List:**

```mermaid
erDiagram
    Investment_Fund_Manager_List {
        string Investment_Fund_Id PK
        string Fund_Management_Company_Employee_Id PK
        string Fund_Manager_Name
        string Source_System_Code
    }
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        G1["Investment Fund Manager List"]
    end
    subgraph RPT["Báo cáo"]
        R1["K_FMS_196: Danh sách người điều hành quỹ (Nhóm 16)"]
    end
    G1 --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Investment Fund Manager List | Tác nghiệp — bảng con drill-down \| 1 người điều hành × 1 quỹ |

---

### Tab: BÁO CÁO / CÔNG TY QLQ

**Slicer chung:** CTQLQ, kỳ thời gian

---

#### Nhóm 27 - Thống kê giao dịch của nhân viên công ty QLQ

> Phân loại: **Tác nghiệp**
> Atomic: `Fund Management Company Key Person` ← FMS.TL_PROFILES — READY *(K_FMS_70a: Số CCCD/Hộ chiếu)*
> Ghi chú: **PENDING toàn bộ 8 chỉ tiêu sổ lệnh.** Nguồn sổ lệnh là `OrderTrade.Trade_HOSE`/`Trade_HNX`. Entity logical tương ứng (`Securities Trade` / `scr_trd`) chỉ tồn tại trong `DataModel/working/Atomic_LinhLV/` — track cá nhân đã lỗi thời (out of date), KHÔNG phải nguồn Atomic chuẩn (chuẩn chỉ gồm `DataModel/Atomic/` và `DataModel/working/Atomic/`). Do đó toàn bộ 8 chỉ tiêu liên quan sổ lệnh (Tài khoản GDCK, Mã CTCK, Ngày GD, Phương thức GD, Lệnh mua/bán, Mã CK, Số lượng, Giá, Tổng giá trị) đều PENDING — cần Atomic team thiết kế lại `Securities Trade` (hoặc tương đương) trong track chuẩn trước khi READY. Chỉ Số CCCD/Hộ chiếu (Chiều join key, nguồn FMS.TL_PROFILES) READY.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_70a | Số CCCD/Hộ chiếu | — | Chiều | `Id_No` ← Fund Management Company Key Person (FMS.TL_PROFILES) | Chiều join key — chờ measure sổ lệnh READY để ghép cùng Fact | READY |
| K_FMS_198 | Tài khoản giao dịch chứng khoán | — | Cơ sở | | **Lý do pending:** Atomic entity nguồn (`Securities Trade`/`scr_trd`, OrderTrade.Trade_HOSE/Trade_HNX) chỉ có ở track `Atomic_LinhLV` (out of date, không phải nguồn chuẩn). **Atomic cần bổ sung:** thiết kế lại entity cho `OrderTrade.Trade_HOSE`/`Trade_HNX` trong `DataModel/Atomic/` hoặc `DataModel/working/Atomic/`. **Mart dự kiến:** `Fund Management Company Staff Trade Report` — grain: 1 lần khớp lệnh × 1 nhân viên CTQLQ. | PENDING |
| K_FMS_72 | Mã CTCK nơi mở tài khoản | — | Chiều | | **Lý do pending:** Tương tự K_FMS_198. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fund Management Company Staff Trade Report`. | PENDING |
| K_FMS_73 | Ngày giao dịch | — | Chiều | | **Lý do pending:** Tương tự K_FMS_198. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fund Management Company Staff Trade Report`. | PENDING |
| K_FMS_74 | Phương thức giao dịch | — | Cơ sở | | **Lý do pending:** BA đánh Trạng thái mapping = Pending (chưa hoàn thiện phân tích), đồng thời Atomic nguồn chưa có ở track chuẩn. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fund Management Company Staff Trade Report`. | PENDING |
| K_FMS_75 | Lệnh mua/bán | — | Cơ sở | | **Lý do pending:** Tương tự K_FMS_198. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fund Management Company Staff Trade Report`. | PENDING |
| K_FMS_76 | Mã CK | — | Chiều | | **Lý do pending:** Tương tự K_FMS_198. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fund Management Company Staff Trade Report`. | PENDING |
| K_FMS_199 | Số lượng CK | CK | Cơ sở | | **Lý do pending:** Tương tự K_FMS_198. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fund Management Company Staff Trade Report`. | PENDING |
| K_FMS_200 | Giá | VND | Cơ sở | | **Lý do pending:** Tương tự K_FMS_198. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fund Management Company Staff Trade Report`. | PENDING |
| K_FMS_201 | Tổng giá trị | VND | Cơ sở | | **Lý do pending:** Tương tự K_FMS_198. **Atomic cần bổ sung:** như trên. **Mart dự kiến:** `Fund Management Company Staff Trade Report`. | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_198, 72, 73, 75, 76, 199, 200, 201 | OrderTrade.Trade_HOSE, OrderTrade.Trade_HNX | Securities Trade *(có draft ở Atomic_LinhLV — cần thiết kế lại trong track chuẩn)* | scr_trd |
| K_FMS_74 | *(BA chưa cung cấp)* | TBD | TBD |

---

### Tab: DATA EXPLORER

**Đặc điểm chung:** DataExplorer là **pass-through** — hiển thị trực tiếp nội dung báo cáo BC từ `Report Import Value` ← FMS.RPTVALUES. Người dùng chọn loại báo cáo, kỳ, CTQLQ/quỹ → hệ thống render các dòng chỉ tiêu theo mã báo cáo.

> **PENDING toàn bộ 63 STT Data Explorer (STT 28–90 theo BA).** Toàn bộ dòng BA thuộc dải STT này đánh **Dữ liệu động** 100% — theo gating "Loại dữ liệu", PENDING dù Atomic nguồn (`Report Import Value` ← FMS.RPTVALUES) đã READY. Xem chi tiết theo từng loại báo cáo ở Tab DATA EXPLORER (Section 2, phần cuối).

### Tab: TỔNG QUAN ĐẠI LÝ PHÂN PHỐI

#### Nhóm 17 - Thống kê chung

> Phân loại: **Phân tích**
> Atomic: `Fund Distribution Agent` ← FMS.AGENCIES — READY *(K_FMS_92: Số lượng Đại lý phân phối)*
> Ghi chú: **Mix READY/PENDING.** Atomic `Fund Distribution Agent` đã sẵn sàng. K_FMS_92 (Số lượng ĐLPP) BA đánh Dữ liệu tĩnh → READY. K_FMS_93/94/95 (Số tài khoản, Giá trị phát hành/mua lại) BA đánh Dữ liệu động và chưa cung cấp Bảng nguồn → PENDING.

**Mockup:**

| Chỉ tiêu | Giá trị |
|---|---|
| Số lượng Đại lý phân phối | 49 |

**Source:** `Fact Fund Distribution Agent Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_91a | Thời gian | — | Chiều | `Decision_Date` ← Fund Distribution Agent (FMS.AGENCIES) | | READY |
| K_FMS_92 | Số lượng Đại lý phân phối | Đại lý | Cơ sở | COUNT(Fund Distribution Agent) | | READY |
| K_FMS_93 | Số tài khoản | TK | Cơ sở | | **Lý do pending:** Dữ liệu động; BA chưa cung cấp Bảng nguồn/Trường nguồn. **Atomic cần bổ sung:** chưa xác định — chờ BA bổ sung Bảng nguồn. **Mart dự kiến:** `Fact Fund Distribution Agent Snapshot` — grain: 1 ĐLPP × 1 tháng. | PENDING |
| K_FMS_94 | Giá trị phát hành | Tỷ VND | Cơ sở | | **Lý do pending:** Tương tự K_FMS_93. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Fund Distribution Agent Snapshot`. | PENDING |
| K_FMS_95 | Giá trị mua lại | Tỷ VND | Cơ sở | | **Lý do pending:** Tương tự K_FMS_93. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Fund Distribution Agent Snapshot`. | PENDING |

**Star Schema:**

```mermaid
erDiagram
    Fact_Fund_Distribution_Agent_Snapshot {
        int Snapshot_Date_Dimension_Id FK
        int Distribution_Agent_Count
    }
    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Month
        int Quarter
        int Day_Of_Week
        boolean Is_Weekend
        boolean Holiday_Flag
        string Holiday_Name
        string Source_System_Code
    }

    Calendar_Date_Dimension ||--o{ Fact_Fund_Distribution_Agent_Snapshot : "Snapshot Date Dimension Id"
```

> Chỉ `Distribution_Agent_Count` READY — `Account_Count`/`Issue_Value_Amount`/`Redeem_Value_Amount` đang PENDING, bổ sung khi có nguồn.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        G1["Fact Fund Distribution Agent Snapshot"]
        G2["Calendar Date Dimension"]
    end
    subgraph RPT["Báo cáo"]
        R1["K_FMS_91a,92: Thống kê chung Đại lý phân phối (Nhóm 17)"]
    end
    G2 --> G1
    G1 --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fact Fund Distribution Agent Snapshot | 1 snapshot toàn thị trường × 1 tháng |
| Calendar Date Dimension | 1 ngày |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_93, 94, 95 | *(BA chưa cung cấp)* | TBD | TBD |

---

#### Nhóm 18 - Tổng số tài khoản giao dịch chứng chỉ quỹ

> Phân loại: **Phân tích**
> Ghi chú: **PENDING toàn bộ.** BA đánh Dữ liệu động cho cả 3 chỉ tiêu (Tổ chức, Cá nhân, Nước ngoài) và chưa cung cấp Bảng nguồn/Trường nguồn.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_96a | Thời gian | — | Chiều | | **Lý do pending:** Không measure nào READY cùng Fact. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Fund Distribution Agent Account Snapshot` — grain: 1 ĐLPP × 1 tháng. | PENDING |
| K_FMS_96 | Tổ chức | TK | Cơ sở | | **Lý do pending:** Dữ liệu động; BA chưa cung cấp Bảng nguồn. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Fund Distribution Agent Account Snapshot`. | PENDING |
| K_FMS_97 | Cá nhân | TK | Cơ sở | | **Lý do pending:** Tương tự K_FMS_96. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Fund Distribution Agent Account Snapshot`. | PENDING |
| K_FMS_98 | Nước ngoài | TK | Cơ sở | | **Lý do pending:** Tương tự K_FMS_96. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Fund Distribution Agent Account Snapshot`. | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_96, 97, 98 | *(BA chưa cung cấp)* | TBD | TBD |

---

#### Nhóm 19 - Số tài khoản nắm giữ chứng chỉ quỹ

> Phân loại: **Phân tích**
> Ghi chú: **PENDING toàn bộ.** BA đánh Dữ liệu động cho cả 3 chỉ tiêu (Tổ chức, Cá nhân, Nước ngoài) và chưa cung cấp Bảng nguồn/Trường nguồn.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_99a | Thời gian | — | Chiều | | **Lý do pending:** Không measure nào READY cùng Fact. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Fund Distribution Agent Holding Snapshot` — grain: 1 ĐLPP × 1 tháng. | PENDING |
| K_FMS_99 | Tổ chức | TK | Cơ sở | | **Lý do pending:** Dữ liệu động; BA chưa cung cấp Bảng nguồn. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Fund Distribution Agent Holding Snapshot`. | PENDING |
| K_FMS_100 | Cá nhân | TK | Cơ sở | | **Lý do pending:** Tương tự K_FMS_99. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Fund Distribution Agent Holding Snapshot`. | PENDING |
| K_FMS_101 | Nước ngoài | TK | Cơ sở | | **Lý do pending:** Tương tự K_FMS_99. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Fund Distribution Agent Holding Snapshot`. | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_99, 100, 101 | *(BA chưa cung cấp)* | TBD | TBD |

---

#### Nhóm 20 - Giá trị chứng chỉ quỹ

> Phân loại: **Phân tích**
> Ghi chú: **PENDING toàn bộ.** BA đánh Dữ liệu động cho cả 3 chỉ tiêu (Tổ chức, Cá nhân, Nước ngoài) và chưa cung cấp Bảng nguồn/Trường nguồn.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_102a | Thời gian | — | Chiều | | **Lý do pending:** Không measure nào READY cùng Fact. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Fund Distribution Agent Certificate Value Snapshot` — grain: 1 ĐLPP × 1 tháng. | PENDING |
| K_FMS_102 | Tổ chức | Tỷ VND | Cơ sở | | **Lý do pending:** Dữ liệu động; BA chưa cung cấp Bảng nguồn. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Fund Distribution Agent Certificate Value Snapshot`. | PENDING |
| K_FMS_103 | Cá nhân | Tỷ VND | Cơ sở | | **Lý do pending:** Tương tự K_FMS_102. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Fund Distribution Agent Certificate Value Snapshot`. | PENDING |
| K_FMS_104 | Nước ngoài | Tỷ VND | Cơ sở | | **Lý do pending:** Tương tự K_FMS_102. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Fund Distribution Agent Certificate Value Snapshot`. | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_102, 103, 104 | *(BA chưa cung cấp)* | TBD | TBD |

---

#### Nhóm 21 - Giao dịch thông qua Đại lý phân phối

> Phân loại: **Phân tích**
> Ghi chú: **PENDING toàn bộ.** BA đánh Dữ liệu động cho cả 2 chỉ tiêu (Giá trị phát hành, Giá trị mua lại) và chưa cung cấp Bảng nguồn/Trường nguồn.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_105a | Thời gian | — | Chiều | | **Lý do pending:** Không measure nào READY cùng Fact. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Fund Distribution Agent Transaction Snapshot` — grain: 1 ĐLPP × 1 tháng. | PENDING |
| K_FMS_105 | Giá trị phát hành (PH) | Tỷ VND | Cơ sở | | **Lý do pending:** Dữ liệu động; BA chưa cung cấp Bảng nguồn. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Fund Distribution Agent Transaction Snapshot`. | PENDING |
| K_FMS_106 | Giá trị mua lại (ML) | Tỷ VND | Cơ sở | | **Lý do pending:** Tương tự K_FMS_105. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Fund Distribution Agent Transaction Snapshot`. | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_105, 106 | *(BA chưa cung cấp)* | TBD | TBD |

---

#### Nhóm 22 - Danh sách Đại lý phân phối

> Phân loại: **Tác nghiệp**
> Atomic: `Fund Distribution Agent` ← FMS.AGENCIES — READY *(K_FMS_107–112: Tên, Số GP, Ngày cấp, Địa chỉ, Tình trạng, Quỹ đang PP)*
> Ghi chú: **Mix READY/PENDING.** 6/13 chỉ tiêu (Tên ĐLPP, Số GP thành lập, Ngày cấp GP, Địa chỉ, Tình trạng hoạt động, Quỹ đang phân phối) BA đánh Dữ liệu tĩnh → READY — Atomic đã sẵn sàng. 7 chỉ tiêu còn lại (tài khoản giao dịch, tài khoản nắm giữ theo Tổ chức/Cá nhân/Nước ngoài, giá trị phát hành/mua lại, thị phần) BA đánh Dữ liệu động và chưa cung cấp Bảng nguồn → PENDING.

**Mockup:**

| Tên ĐLPP | Số GP | Ngày cấp GP | Địa chỉ | Tình trạng | Quỹ đang PP |
|---|---|---|---|---|---|
| Công ty Chứng khoán XYZ | 123/GP | 01/01/2020 | Hà Nội | Hoạt động | 5 |

**Source:** `Fund Distribution Agent Profile`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_107a | Thời gian | — | Chiều | `Decision_Date` ← Fund Distribution Agent (FMS.AGENCIES) | | READY |
| K_FMS_107 | Tên Đại lý phân phối | — | Cơ sở | `Item_Name` ← Fund Distribution Agent | | READY |
| K_FMS_108 | Số GP thành lập | — | Cơ sở | `Decision` ← Fund Distribution Agent | | READY |
| K_FMS_109 | Ngày cấp GP thành lập | — | Cơ sở | `Decision_Date` ← Fund Distribution Agent | | READY |
| K_FMS_110 | Địa chỉ | — | Cơ sở | `Address` ← Fund Distribution Agent | | READY |
| K_FMS_111 | Tình trạng hoạt động | — | Cơ sở | `Active_Date`/`Stop_Date` ← Fund Distribution Agent | | READY |
| K_FMS_112 | Quỹ đang phân phối | Quỹ | Cơ sở | COUNT(Investment Fund) join Investment Fund X Fund Distribution Agent Relationship (FMS.AGEN_FUNDS) | | READY |
| K_FMS_114 | Tài khoản giao dịch | TK | Cơ sở | | **Lý do pending:** Dữ liệu động; BA chưa cung cấp Bảng nguồn. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fund Distribution Agent Profile`. | PENDING |
| K_FMS_115 | Tài khoản giao dịch (YTD) | TK | Cơ sở | | **Lý do pending:** Tương tự K_FMS_114. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fund Distribution Agent Profile`. | PENDING |
| K_FMS_116 | Tổng số tài khoản giao dịch CCQ - Tổ chức | TK | Cơ sở | | **Lý do pending:** Tương tự K_FMS_114. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fund Distribution Agent Profile`. | PENDING |
| K_FMS_117 | Tổng số tài khoản giao dịch CCQ - Cá nhân | TK | Cơ sở | | **Lý do pending:** Tương tự K_FMS_114. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fund Distribution Agent Profile`. | PENDING |
| K_FMS_118 | Tổng số tài khoản giao dịch CCQ - Nước ngoài | TK | Cơ sở | | **Lý do pending:** Tương tự K_FMS_114. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fund Distribution Agent Profile`. | PENDING |
| K_FMS_119 | Số tài khoản nắm giữ CCQ - Tổ chức | TK | Cơ sở | | **Lý do pending:** Tương tự K_FMS_114. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fund Distribution Agent Profile`. | PENDING |
| K_FMS_120 | Số tài khoản nắm giữ CCQ - Cá nhân | TK | Cơ sở | | **Lý do pending:** Tương tự K_FMS_114. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fund Distribution Agent Profile`. | PENDING |
| K_FMS_121 | Số tài khoản nắm giữ CCQ - Nước ngoài | TK | Cơ sở | | **Lý do pending:** Tương tự K_FMS_114. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fund Distribution Agent Profile`. | PENDING |
| K_FMS_122 | Giá trị chứng chỉ quỹ - Tổ chức | Tỷ VND | Cơ sở | | **Lý do pending:** Tương tự K_FMS_114. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fund Distribution Agent Profile`. | PENDING |
| K_FMS_123 | Giá trị chứng chỉ quỹ - Cá nhân | Tỷ VND | Cơ sở | | **Lý do pending:** Tương tự K_FMS_114. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fund Distribution Agent Profile`. | PENDING |
| K_FMS_124 | Giá trị chứng chỉ quỹ - Nước ngoài | Tỷ VND | Cơ sở | | **Lý do pending:** Tương tự K_FMS_114. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fund Distribution Agent Profile`. | PENDING |
| K_FMS_125 | Giá trị phát hành (PH) | Tỷ VND | Cơ sở | | **Lý do pending:** Tương tự K_FMS_114. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fund Distribution Agent Profile`. | PENDING |
| K_FMS_126 | Giá trị phát hành (PH) (YTD) | Tỷ VND | Cơ sở | | **Lý do pending:** Tương tự K_FMS_114. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fund Distribution Agent Profile`. | PENDING |
| K_FMS_127 | Giá trị mua lại (ML) | Tỷ VND | Cơ sở | | **Lý do pending:** Tương tự K_FMS_114. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fund Distribution Agent Profile`. | PENDING |
| K_FMS_128 | Thị phần (TP) | % | Phái sinh | | **Lý do pending:** Phụ thuộc K_FMS_122-124 (PENDING). **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fund Distribution Agent Profile`. | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_114–128 | *(BA chưa cung cấp)* | TBD | TBD |

**Schema bảng tác nghiệp — Fund Distribution Agent Profile:**

```mermaid
erDiagram
    Fund_Distribution_Agent_Profile {
        string Fund_Distribution_Agent_Id PK
        string Agent_Name
        string License_Number
        date License_Date
        string Address
        string Operation_Status_Code
        int Distributing_Fund_Count
        string Source_System_Code
    }
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        G1["Fund Distribution Agent Profile"]
    end
    subgraph RPT["Báo cáo"]
        R1["K_FMS_107a,107-112: Danh sách Đại lý phân phối (Nhóm 22)"]
    end
    G1 --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fund Distribution Agent Profile | Tác nghiệp — bảng flat \| 1 ĐLPP × 1 tháng slicer |

---

#### Nhóm 23 - Danh sách các Quỹ đang phân phối

> Phân loại: **Tác nghiệp**
> Atomic: `Investment Fund` ← FMS.FUNDS — READY *(K_FMS_197: Danh sách các Quỹ đang phân phối)*
> Ghi chú: Popup drill-down khi bấm vào Quỹ đang phân phối ở Nhóm 22 (K_FMS_112) — FK về `Fund_Distribution_Agent_Id`, join `Investment Fund X Fund Distribution Agent Relationship` (FMS.AGEN_FUNDS).

**Mockup — popup "DANH SÁCH CÁC QUỸ ĐANG PHÂN PHỐI":**

| Tên quỹ |
|---|
| Quỹ ABC Cổ phần |

**Source:** `Fund Distribution Agent Fund List`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_197 | Danh sách các Quỹ đang phân phối | — | Cơ sở | `Fund_Name` ← Investment Fund (FMS.FUNDS), join Investment Fund X Fund Distribution Agent Relationship (FMS.AGEN_FUNDS) | | READY |

**Schema bảng con — Fund Distribution Agent Fund List:**

```mermaid
erDiagram
    Fund_Distribution_Agent_Fund_List {
        string Fund_Distribution_Agent_Id PK
        string Investment_Fund_Id PK
        string Fund_Name
        string Source_System_Code
    }
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        G1["Fund Distribution Agent Fund List"]
    end
    subgraph RPT["Báo cáo"]
        R1["K_FMS_197: Danh sách các Quỹ đang phân phối (Nhóm 23)"]
    end
    G1 --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fund Distribution Agent Fund List | Tác nghiệp — bảng con drill-down \| 1 quỹ × 1 ĐLPP |

---

### Tab: TỔNG QUAN CN CTQLQ NN TẠI VN

#### Nhóm 24 - Thống kê chung

> Phân loại: **Phân tích**
> Atomic: `Foreign Fund Management Organization Unit` ← FMS.FOR_BRCH — READY *(K_FMS_129: Chi nhánh CTQLQ nước ngoài tại Việt Nam)*
> Ghi chú: **Mix READY/PENDING.** Atomic đã sẵn sàng. K_FMS_129 (đếm CN, lọc Branch_Flag=1) BA đánh Dữ liệu tĩnh → READY. K_FMS_130/131 (Hợp đồng QLDMĐT, Giá trị hợp đồng) BA đánh Dữ liệu động và chưa cung cấp Bảng nguồn → PENDING.

**Mockup:**

| Chỉ tiêu | Giá trị |
|---|---|
| Chi nhánh CTQLQ nước ngoài tại VN | 8 |

**Source:** `Fact Foreign Fund Management Organization Unit Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_129a | Thời gian | — | Chiều | `License_Date` ← Foreign Fund Management Organization Unit (FMS.FOR_BRCH) | | READY |
| K_FMS_129 | Chi nhánh CTQLQ nước ngoài tại Việt Nam | Chi nhánh | Cơ sở | COUNT(Foreign Fund Management Organization Unit) WHERE Branch_Type_Code = Chi nhánh | | READY |
| K_FMS_130 | Hợp đồng quản lý danh mục đầu tư | HĐ | Cơ sở | | **Lý do pending:** Dữ liệu động; BA chưa cung cấp Bảng nguồn. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Foreign Fund Management Organization Unit Snapshot` — grain: 1 CN × 1 tháng. | PENDING |
| K_FMS_131 | Giá trị hợp đồng quản lý danh mục đầu tư | Tỷ VND | Cơ sở | | **Lý do pending:** Tương tự K_FMS_130. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Foreign Fund Management Organization Unit Snapshot`. | PENDING |

**Star Schema:**

```mermaid
erDiagram
    Fact_Foreign_Fund_Management_Organization_Unit_Snapshot {
        int Snapshot_Date_Dimension_Id FK
        int Branch_Count
    }
    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Month
        int Quarter
        int Day_Of_Week
        boolean Is_Weekend
        boolean Holiday_Flag
        string Holiday_Name
        string Source_System_Code
    }

    Calendar_Date_Dimension ||--o{ Fact_Foreign_Fund_Management_Organization_Unit_Snapshot : "Snapshot Date Dimension Id"
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        G1["Fact Foreign Fund Management Organization Unit Snapshot"]
        G2["Calendar Date Dimension"]
    end
    subgraph RPT["Báo cáo"]
        R1["K_FMS_129a,129: Thống kê chung CN CTQLQ NN (Nhóm 24)"]
    end
    G2 --> G1
    G1 --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fact Foreign Fund Management Organization Unit Snapshot | 1 snapshot toàn thị trường × 1 tháng |
| Calendar Date Dimension | 1 ngày |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_130, 131 | *(BA chưa cung cấp)* | TBD | TBD |

---

#### Nhóm 25 - Số liệu hợp đồng uỷ thác danh mục

> Phân loại: **Phân tích**
> Ghi chú: **PENDING toàn bộ.** BA đánh Dữ liệu động cho toàn bộ 6 chỉ tiêu (số lượng/giá trị HĐ UTQLDM theo cá nhân/tổ chức, tổng) và chưa cung cấp Bảng nguồn/Trường nguồn.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_132a | Thời gian | — | Chiều | | **Lý do pending:** Không measure nào READY cùng Fact. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Foreign Fund Management Organization Unit Contract Snapshot` — grain: 1 CN × 1 tháng. | PENDING |
| K_FMS_132 | Số lượng hợp đồng UTQLDM cá nhân | HĐ | Cơ sở | | **Lý do pending:** Dữ liệu động; BA chưa cung cấp Bảng nguồn. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Foreign Fund Management Organization Unit Contract Snapshot`. | PENDING |
| K_FMS_133 | Giá trị thị trường hợp đồng UTQLDM cá nhân | Tỷ VND | Cơ sở | | **Lý do pending:** Tương tự K_FMS_132. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Foreign Fund Management Organization Unit Contract Snapshot`. | PENDING |
| K_FMS_134 | Số lượng hợp đồng UTQLDM tổ chức | HĐ | Cơ sở | | **Lý do pending:** Tương tự K_FMS_132. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Foreign Fund Management Organization Unit Contract Snapshot`. | PENDING |
| K_FMS_135 | Giá trị thị trường hợp đồng UTQLDM tổ chức | Tỷ VND | Cơ sở | | **Lý do pending:** Tương tự K_FMS_132. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Foreign Fund Management Organization Unit Contract Snapshot`. | PENDING |
| K_FMS_136 | Tổng số lượng hợp đồng UTQLDM | HĐ | Cơ sở | | **Lý do pending:** Tương tự K_FMS_132. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Foreign Fund Management Organization Unit Contract Snapshot`. | PENDING |
| K_FMS_137 | Tổng giá trị ủy thác | Tỷ VND | Cơ sở | | **Lý do pending:** Tương tự K_FMS_132. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Fact Foreign Fund Management Organization Unit Contract Snapshot`. | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_132–137 | *(BA chưa cung cấp)* | TBD | TBD |

---

#### Nhóm 26 - Danh sách các Chi nhánh CTQLQ nước ngoài tại Việt Nam

> Phân loại: **Tác nghiệp**
> Atomic: `Foreign Fund Management Organization Unit` ← FMS.FOR_BRCH — READY *(K_FMS_138: Tên Chi nhánh)*
> Atomic: `Foreign Fund Management Organization Unit Staff` ← FMS.STF_FG_BRCH — READY *(K_FMS_143, K_FMS_144: Giám đốc chi nhánh, Số lượng nhân viên có CCHN)*
> Ghi chú: **Mix READY/PENDING.** 3/10 chỉ tiêu (Tên CN, Giám đốc chi nhánh, Số nhân viên CCHN) BA đánh Dữ liệu tĩnh → READY — Atomic đã sẵn sàng. 7 chỉ tiêu còn lại (CAR, Lợi nhuận, Vốn CSH, Số/Mã HĐ UTQLDM, Số TK lưu ký, Giá trị HĐ) BA đánh Dữ liệu động và chưa cung cấp Bảng nguồn → PENDING. Riêng "Mã hợp đồng UTQLDM" (K_FMS_145) BA đánh **Trạng thái mapping = Pending** (khác các dòng còn lại = Done) — ghi nhận PENDING kép (chưa Done + Dữ liệu động).

**Mockup:**

| Tên CN | Giám đốc CN | Số nhân viên CCHN |
|---|---|---|
| CN Công ty ABC tại VN | Nguyễn Văn C | 4 |

**Source:** `Foreign Fund Management Organization Unit Profile`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_FMS_138a | Thời gian | — | Chiều | `License_Date` ← Foreign Fund Management Organization Unit (FMS.FOR_BRCH) | | READY |
| K_FMS_138 | Tên Chi nhánh CTQLQ nước ngoài tại Việt Nam | — | Cơ sở | `Foreign_Fm_Ou_Full_Nm`, `Short_Name` ← Foreign Fund Management Organization Unit | | READY |
| K_FMS_143 | Giám đốc chi nhánh | — | Cơ sở | `Item_Name` ← Foreign Fund Management Organization Unit Staff (FMS.STF_FG_BRCH) | | READY |
| K_FMS_144 | Số lượng nhân viên có CCHN | Người | Cơ sở | COUNT(Foreign Fund Management Organization Unit Staff) | | READY |
| K_FMS_139 | CAR (ATTC) | % | Cơ sở | | **Lý do pending:** Dữ liệu động; BA chưa cung cấp Bảng nguồn. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Foreign Fund Management Organization Unit Profile`. | PENDING |
| K_FMS_140 | Lợi nhuận (Tỷ đồng) | Tỷ VND | Cơ sở | | **Lý do pending:** Tương tự K_FMS_139. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Foreign Fund Management Organization Unit Profile`. | PENDING |
| K_FMS_141 | Vốn CSH | Tỷ VND | Cơ sở | | **Lý do pending:** Tương tự K_FMS_139. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Foreign Fund Management Organization Unit Profile`. | PENDING |
| K_FMS_142 | Số lượng hợp đồng UTQLDM | HĐ | Cơ sở | | **Lý do pending:** Tương tự K_FMS_139. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Foreign Fund Management Organization Unit Profile`. | PENDING |
| K_FMS_145 | Mã hợp đồng UTQLDM | — | Cơ sở | | **Lý do pending:** BA đánh Trạng thái mapping = Pending (chưa Done) + Dữ liệu động. **Atomic cần bổ sung:** chưa xác định — chờ BA hoàn thiện phân tích. **Mart dự kiến:** `Foreign Fund Management Organization Unit Contract List` (bảng con drill-down). | PENDING |
| K_FMS_146 | Số tài khoản lưu ký | — | Cơ sở | | **Lý do pending:** Tương tự K_FMS_139. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Foreign Fund Management Organization Unit Contract List`. | PENDING |
| K_FMS_147 | Giá trị thị trường của từng hợp đồng UTQLDM | Tỷ VND | Cơ sở | | **Lý do pending:** Tương tự K_FMS_139. **Atomic cần bổ sung:** chưa xác định. **Mart dự kiến:** `Foreign Fund Management Organization Unit Contract List`. | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| K_FMS_139–142, 145–147 | *(BA chưa cung cấp)* | TBD | TBD |

**Schema bảng tác nghiệp — Foreign Fund Management Organization Unit Profile:**

```mermaid
erDiagram
    Foreign_Fund_Management_Organization_Unit_Profile {
        string Foreign_Fund_Management_Organization_Unit_Id PK
        string Foreign_Fm_Ou_Full_Nm
        string Short_Name
        string Director_Name
        int Certified_Staff_Count
        string Source_System_Code
    }
```

> Chỉ 3 cột READY (`Foreign_Fm_Ou_Full_Nm`/`Short_Name`, `Director_Name`, `Certified_Staff_Count`) được đưa vào schema — 7 cột còn lại đang PENDING.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        G1["Foreign Fund Management Organization Unit Profile"]
    end
    subgraph RPT["Báo cáo"]
        R1["K_FMS_138a,138,143,144: Danh sách CN CTQLQ NN (Nhóm 26)"]
    end
    G1 --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Foreign Fund Management Organization Unit Profile | Tác nghiệp — bảng flat \| 1 CN × 1 tháng slicer |

---

### Tab: DATA EXPLORER

**PENDING toàn bộ 63 STT Data Explorer (STT 28–90 theo BA).** Toàn bộ measure thuộc dải STT này BA đánh **Dữ liệu động** 100% — theo gating "Loại dữ liệu", PENDING dù Atomic nguồn (`Report Import Value` ← FMS.RPTVALUES) đã READY.

**Atomic cần bổ sung:** không — Atomic `Report Import Value` đã READY; cần mapping `Row_Code` cụ thể per chỉ tiêu (xem O_FMS_1) khi BA xác nhận lại quy tắc khai thác.

**Mart dự kiến:** `Report Pass-through View` — grain: 1 CTQLQ/Quỹ × 1 mẫu BC × 1 kỳ × 1 dòng chỉ tiêu.

Chi tiết từng loại báo cáo dưới đây (7 nhóm nội dung, mỗi KPI ID = 1 dòng/chỉ tiêu báo cáo chi tiết — chưa khai sinh mapping `Row_Code` riêng, hiện gộp theo nhóm báo cáo):

---

#### Nhóm — BCTC-BCLCTT_GianTiep

**KPI liên quan:** K_FMS_305 – K_FMS_344

| KPI ID | Tên KPI | Tính chất | Trạng thái |
|---|---|---|---|
| K_FMS_305 | I. Lưu chuyển tiền từ hoạt động kinh doanh | Cơ sở | PENDING |
| K_FMS_306 | 1. Lợi nhuận trước thuế | Cơ sở | PENDING |
| K_FMS_307 | 2. Điều chỉnh cho các khoản | Cơ sở | PENDING |
| K_FMS_308 | - Khấu hao TSCĐ | Cơ sở | PENDING |
| K_FMS_309 | - Các khoản dự phòng | Cơ sở | PENDING |
| K_FMS_310 | - Lãi, lỗ chênh lệch tỷ giá hối đoái chưa thực hiện | Cơ sở | PENDING |
| K_FMS_311 | - Lãi, lỗ từ hoạt động đầu tư | Cơ sở | PENDING |
| K_FMS_312 | - Chi phí lãi vay | Cơ sở | PENDING |
| K_FMS_313 | 3. Lợi nhuận từ hoạt động kinh doanh trước thay đổi vốn lưu động | Cơ sở | PENDING |
| K_FMS_314 | - Tăng, giảm các khoản phải thu | Cơ sở | PENDING |
| K_FMS_315 | - Tăng, giảm hàng tồn kho | Cơ sở | PENDING |
| K_FMS_316 | - Tăng, giảm các khoản phải trả (Không kể lãi vay phải trả, thuế thu nhập doanh nghiệp phải nộp) | Cơ sở | PENDING |
| K_FMS_317 | - Tăng, giảm chi phí trả trước. | Cơ sở | PENDING |
| K_FMS_318 | - Tiền lãi vay đã trả | Cơ sở | PENDING |
| K_FMS_319 | - Thuế thu nhập doanh nghiệp đã nộp | Cơ sở | PENDING |
| K_FMS_320 | - Tiền khu khác từ hoạt động kinh doanh | Cơ sở | PENDING |
| K_FMS_321 | - Tiền chi khác cho hoạt động kinh doanh | Cơ sở | PENDING |
| K_FMS_322 | Lưu chuyển tiền thuần từ hoạt động kinh doanh | Cơ sở | PENDING |
| K_FMS_323 | II. Lưu chuyển tiền từ hoạt động đầu tư | Cơ sở | PENDING |
| K_FMS_324 | 1. Tiền chi để mua sắm, xây dựng TSCĐ và các tài sản dài hạn khác | Cơ sở | PENDING |
| K_FMS_325 | 2. Tiền thu từ thanh lý, nhượng bán TSCĐ và các tài sản dài hạn khác | Cơ sở | PENDING |
| K_FMS_326 | 3. Tiền chi mua các công cụ nợ của đơn vị khác | Cơ sở | PENDING |
| K_FMS_327 | 4. Tiền thu từ thanh lý các công cụ nợ của đơn vị khác | Cơ sở | PENDING |
| K_FMS_328 | 5. Tiền chi đầu tư góp vốn vào đơn vị khác | Cơ sở | PENDING |
| K_FMS_329 | 6. Tiền thu hồi đầu tư góp vốn vào đơn vị khác | Cơ sở | PENDING |
| K_FMS_330 | 7. Tiền thu cổ tức và lợi nhuận được chia | Cơ sở | PENDING |
| K_FMS_331 | Lưu chuyển tiền thuần từ hoạt động đầu tư | Cơ sở | PENDING |
| K_FMS_332 | III. Lưu chuyển tiền từ hoạt động tài chính | Cơ sở | PENDING |
| K_FMS_333 | 1. Tiền thu từ phát hành cổ phiếu, trái phiếu, nhận vốn góp của chủ sở hữu | Cơ sở | PENDING |
| K_FMS_334 | 2. Tiền chi trả vốn góp cho các chủ sở hữu, mua lại cổ phiếu của công ty đã phát hành | Cơ sở | PENDING |
| K_FMS_335 | 3. Tiền vay ngắn hạn, dài hạn nhận được | Cơ sở | PENDING |
| K_FMS_336 | 4. Tiền chi trả nợ gốc vay | Cơ sở | PENDING |
| K_FMS_337 | 5. Tiền chi trả nợ thuê tài chính | Cơ sở | PENDING |
| K_FMS_338 | 6. Cổ tức, lợi nhuận đã trả cho chủ sở hữu | Cơ sở | PENDING |
| K_FMS_339 | Khác | Cơ sở | PENDING |
| K_FMS_340 | Lưu chuyển tiền thuần từ hoạt động tài chính | Cơ sở | PENDING |
| K_FMS_341 | Lưu chuyển tiền thuần trong kỳ (50 = 20+30+40) | Cơ sở | PENDING |
| K_FMS_342 | Tiền và tương đương tiền đầu kỳ | Cơ sở | PENDING |
| K_FMS_343 | Ảnh hưởng của thay đổi tỷ giá hối đoái quy đổi ngoại tệ | Cơ sở | PENDING |
| K_FMS_344 | Tiền và tương đương tiền cuối kỳ (70 = 50+60+61) | Cơ sở | PENDING |

#### Nhóm — BCTC-BCLCTT_TrucTiep

**KPI liên quan:** K_FMS_275 – K_FMS_304

| KPI ID | Tên KPI | Tính chất | Trạng thái |
|---|---|---|---|
| K_FMS_275 | I. Lưu chuyển tiền từ hoạt động kinh doanh | Cơ sở | PENDING |
| K_FMS_276 | 1. Tiền thu từ hoạt động nghiệp vụ, cung cấp dịch vụ và doanh thu khác | Cơ sở | PENDING |
| K_FMS_277 | 2. Tiền chi trả cho hoạt động nghiệp vụ và người cung cấp hàng hóa, dịch vụ | Cơ sở | PENDING |
| K_FMS_278 | 3. Tiền chi trả cho người lao động | Cơ sở | PENDING |
| K_FMS_279 | 4. Tiền chi trả lãi vay | Cơ sở | PENDING |
| K_FMS_280 | 5. Tiền chi nộp thuế thu nhập doanh nghiệp | Cơ sở | PENDING |
| K_FMS_281 | 6. Tiền thu khác từ hoạt động kinh doanh | Cơ sở | PENDING |
| K_FMS_282 | 7. Tiền chi khác từ hoạt động kinh doanh | Cơ sở | PENDING |
| K_FMS_283 | Lưu chuyển tiền thuần từ hoạt động kinh doanh | Cơ sở | PENDING |
| K_FMS_284 | II. Lưu chuyển tiền từ hoạt động đầu tư | Cơ sở | PENDING |
| K_FMS_285 | 1.Tiền chi để mua sắm, xây dựng TSCĐ và các tài sản dài hạn khác | Cơ sở | PENDING |
| K_FMS_286 | 2.Tiền thu từ thanh lý, nhượng bán TSCĐ và các tài sản dài hạn khác | Cơ sở | PENDING |
| K_FMS_287 | 3. Tiền chi mua các công cụ nợ của đơn vị khác | Cơ sở | PENDING |
| K_FMS_288 | 4. Tiền thu từ thanh lý các khoản đầu tư công cụ nợ của đơn vị khác | Cơ sở | PENDING |
| K_FMS_289 | 5.Tiền chi đầu tư góp vốn vào đơn vị khác | Cơ sở | PENDING |
| K_FMS_290 | 6.Tiền thu hồi đầu tư góp vốn vào đơn vị khác | Cơ sở | PENDING |
| K_FMS_291 | 7. Tiền thu cổ tức và lợi nhuận được chia | Cơ sở | PENDING |
| K_FMS_292 | Lưu chuyển tiền thuần từ hoạt động đầu tư | Cơ sở | PENDING |
| K_FMS_293 | III. Lưu chuyển tiền từ hoạt động tài chính | Cơ sở | PENDING |
| K_FMS_294 | 1. Tiền thu từ phát hành cổ phiếu, trái phiếu, nhận vốn góp của chủ sở hữu | Cơ sở | PENDING |
| K_FMS_295 | 2. Tiền chi trả vốn cho các chủ sở hữu, mua lại cổ phiếu của công ty đã phát hành | Cơ sở | PENDING |
| K_FMS_296 | 3. Tiền vay ngắn hạn, dài hạn nhận được | Cơ sở | PENDING |
| K_FMS_297 | 4.Tiền chi trả nợ gốc vay | Cơ sở | PENDING |
| K_FMS_298 | 5.Tiền chi trả nợ thuê tài chính | Cơ sở | PENDING |
| K_FMS_299 | 6. Cổ tức, lợi nhuận đã trả cho chủ sở hữu | Cơ sở | PENDING |
| K_FMS_300 | Lưu chuyển tiền thuần từ hoạt động tài chính | Cơ sở | PENDING |
| K_FMS_301 | Lưu chuyển tiền thuần trong kỳ (50 = 20+30+40) | Cơ sở | PENDING |
| K_FMS_302 | Tiền và tương đương tiền đầu kỳ | Cơ sở | PENDING |
| K_FMS_303 | Ảnh hưởng của thay đổi tỷ giá hối đoái quy đổi ngoại tệ | Cơ sở | PENDING |
| K_FMS_304 | Tiền và tương đương tiền cuối kỳ (70 = 50+60+61) | Cơ sở | PENDING |

#### Nhóm — BCTC-BCTinhHinhBienDongVCSH

**KPI liên quan:** K_FMS_345 – K_FMS_355

| KPI ID | Tên KPI | Tính chất | Trạng thái |
|---|---|---|---|
| K_FMS_345 | 1. Vốn đầu tư của chủ sở hữu | Cơ sở | PENDING |
| K_FMS_346 | 2. Thặng dư vốn cổ phần | Cơ sở | PENDING |
| K_FMS_347 | 3. Vốn khác của chủ sở hữu | Cơ sở | PENDING |
| K_FMS_348 | 4. Cổ phiếu quỹ (*) | Cơ sở | PENDING |
| K_FMS_349 | 5. Chênh lệch đánh giá lại tài sản | Cơ sở | PENDING |
| K_FMS_350 | 6. Chênh lệch tỷ giá hối đoái | Cơ sở | PENDING |
| K_FMS_351 | 7. Quỹ đầu tư phát triển | Cơ sở | PENDING |
| K_FMS_352 | 8. Quỹ dự phòng tài chính | Cơ sở | PENDING |
| K_FMS_353 | 9. Các Quỹ khác thuộc vốn chủ sở hữu | Cơ sở | PENDING |
| K_FMS_354 | 10. Lợi nhuận chưa phân phối | Cơ sở | PENDING |
| K_FMS_355 | Cộng | Cơ sở | PENDING |

#### Nhóm — BCTC-Báo cáo kết quả hoạt động kinh doanh

**KPI liên quan:** K_FMS_258 – K_FMS_274

| KPI ID | Tên KPI | Tính chất | Trạng thái |
|---|---|---|---|
| K_FMS_258 | 1. Doanh thu | Cơ sở | PENDING |
| K_FMS_259 | 2. Các khoản giảm trừ doanh thu | Cơ sở | PENDING |
| K_FMS_260 | 3. Doanh thu thuần về hoạt động kinh doanh (10=01-02) | Cơ sở | PENDING |
| K_FMS_261 | 4. Chi phí hoạt động kinh doanh, giá vốn hàng bán | Cơ sở | PENDING |
| K_FMS_262 | 5. Lợi nhuận gộp của hoạt động kinh doanh(20=10-11) | Cơ sở | PENDING |
| K_FMS_263 | 6. Doanh thu hoạt động tài chính | Cơ sở | PENDING |
| K_FMS_264 | 7. Chi phí tài chính | Cơ sở | PENDING |
| K_FMS_265 | 8. Chi phí quản lý doanh nghiệp | Cơ sở | PENDING |
| K_FMS_266 | 9. Lợi nhuận thuần từ hoạt động kinh doanh (30=20 +(21-22)- 25) | Cơ sở | PENDING |
| K_FMS_267 | 10. Thu nhập khác | Cơ sở | PENDING |
| K_FMS_268 | 11. Chi phí khác | Cơ sở | PENDING |
| K_FMS_269 | 12. Lợi nhuận khác (40=31-32) | Cơ sở | PENDING |
| K_FMS_270 | 13. Tổng lợi nhuận kế toán trước thuế (50=30+40) | Cơ sở | PENDING |
| K_FMS_271 | 14. Chi phí thuế TNDN hiện hành | Cơ sở | PENDING |
| K_FMS_272 | 15. Chi phí thuế TNDN hoãn lại | Cơ sở | PENDING |
| K_FMS_273 | 16. Lợi nhuận sau thuế TNDN (60=50-51-52) | Cơ sở | PENDING |
| K_FMS_274 | 17. Lãi trên cổ phiếu (*) | Cơ sở | PENDING |

#### Nhóm — BCTC-Bảng cân đối kế toán

**KPI liên quan:** K_FMS_148 – K_FMS_257

| KPI ID | Tên KPI | Tính chất | Trạng thái |
|---|---|---|---|
| K_FMS_148 | A- TÀI SẢN NGẮN HẠN(100 = 110 + 120 + 130 + 140 + 150) | Cơ sở | PENDING |
| K_FMS_149 | I.Tiền và các khoản tương đương tiền | Cơ sở | PENDING |
| K_FMS_150 | 1. Tiền | Cơ sở | PENDING |
| K_FMS_151 | 2. Các khoản tương đương tiền | Cơ sở | PENDING |
| K_FMS_152 | II. Các khoản đầu tư tài chính ngắn hạn | Cơ sở | PENDING |
| K_FMS_153 | 1. Đầu tư ngắn hạn | Cơ sở | PENDING |
| K_FMS_154 | 2. Dự phòng giảm giá đầu tư tài chính ngắn hạn(*) | Cơ sở | PENDING |
| K_FMS_155 | III. Các khoản phải thu ngắn hạn | Cơ sở | PENDING |
| K_FMS_156 | 1. Phải thu của khách hàng | Cơ sở | PENDING |
| K_FMS_157 | 2. Trả trước cho người bán | Cơ sở | PENDING |
| K_FMS_158 | 3. Phải thu nội bộ ngắn hạn | Cơ sở | PENDING |
| K_FMS_159 | 5. Các khoản phải thu khác | Cơ sở | PENDING |
| K_FMS_160 | 6. Dự phòng phải thu ngắn hạn khó đòi(*) | Cơ sở | PENDING |
| K_FMS_161 | IV. Hàng tồn kho | Cơ sở | PENDING |
| K_FMS_162 | V. Tài sản ngắn hạn khác | Cơ sở | PENDING |
| K_FMS_163 | 1. Chi phí trả trước ngắn hạn | Cơ sở | PENDING |
| K_FMS_164 | 2. Thuế GTGT được khấu trừ | Cơ sở | PENDING |
| K_FMS_165 | 3. Thuế và các khoản phải thu nhà nước | Cơ sở | PENDING |
| K_FMS_166 | 4. Giao dịch mua bán lại trái phiếu Chính phủ | Cơ sở | PENDING |
| K_FMS_167 | 5. Tài sản ngắn hạn khác | Cơ sở | PENDING |
| K_FMS_168 | B. TÀI SẢN DÀI HẠN (200 = 210 + 220 + 250 + 260) | Cơ sở | PENDING |
| K_FMS_169 | I. Các khoản phải thu dài hạn | Cơ sở | PENDING |
| K_FMS_170 | 1. Phải thu dài hạn của khách hàng | Cơ sở | PENDING |
| K_FMS_171 | 2.Vốn kinh doanh ở đơn vị trực thuộc | Cơ sở | PENDING |
| K_FMS_172 | 3. Phải thu dài hạn nội bộ | Cơ sở | PENDING |
| K_FMS_173 | 4. Phải thu dài hạn khác | Cơ sở | PENDING |
| K_FMS_174 | 5. Dự phòng phải thu dài hạn khó đòi(*) | Cơ sở | PENDING |
| K_FMS_175 | II. Tài sản cố định | Cơ sở | PENDING |
| K_FMS_176 | 1. Tài sản cố định hữu hình | Cơ sở | PENDING |
| K_FMS_177 | - Nguyên giá | Cơ sở | PENDING |
| K_FMS_178 | - Giá trị hao mòn luỹ kế(*) | Cơ sở | PENDING |
| K_FMS_179 | 2. Tài sản cố định thuê tài chính | Cơ sở | PENDING |
| K_FMS_180 | - Nguyên giá | Cơ sở | PENDING |
| K_FMS_181 | - Giá trị hao mòn luỹ kế (*) | Cơ sở | PENDING |
| K_FMS_182 | 3. Tài sản cố định vô hình | Cơ sở | PENDING |
| K_FMS_183 | - Nguyên giá | Cơ sở | PENDING |
| K_FMS_184 | - Giá trị hao mòn luỹ kế (*) | Cơ sở | PENDING |
| K_FMS_185 | 4. Chi phí đầu tư xây dựng cơ bản dở dang | Cơ sở | PENDING |
| K_FMS_186 | III. Các khoản đầu tư tài chính dài hạn | Cơ sở | PENDING |
| K_FMS_187 | 1. Đầu tư vào công ty con | Cơ sở | PENDING |
| K_FMS_188 | 2. Đầu tư vào công ty liên kết, liên doanh | Cơ sở | PENDING |
| K_FMS_189 | 3. Đầu tư dài hạn khác | Cơ sở | PENDING |
| K_FMS_190 | 4. Dự phòng giảm giá đầu tư tài chính dài hạn (*) | Cơ sở | PENDING |
| K_FMS_191 | IV. Tài sản dài hạn khác | Cơ sở | PENDING |
| K_FMS_192 | 1. Chi phí trả trước dài hạn | Cơ sở | PENDING |
| K_FMS_193 | 2. Tài sản thuế thu nhập hoãn lại | Cơ sở | PENDING |
| K_FMS_194 | 3. Tài sản dài hạn khác | Cơ sở | PENDING |
| K_FMS_195 | TỔNG CỘNG TÀI SẢN (270 = 100 + 200) | Cơ sở | PENDING |
| K_FMS_196 | A – NỢ PHẢI TRẢ (300 = 310 + 330) | Cơ sở | PENDING |
| K_FMS_197 | I. Nợ ngắn hạn | Cơ sở | PENDING |
| K_FMS_198 | 1.Vay ngắn hạn | Cơ sở | PENDING |
| K_FMS_199 | 2. Phải trả người bán | Cơ sở | PENDING |
| K_FMS_200 | 3. Người mua trả tiền trước | Cơ sở | PENDING |
| K_FMS_201 | 4. Thuế và các khoản phải nộp Nhà nước | Cơ sở | PENDING |
| K_FMS_202 | 5. Phải trả người lao động | Cơ sở | PENDING |
| K_FMS_203 | 6. Chi phí phải trả | Cơ sở | PENDING |
| K_FMS_204 | 7. Phải trả nội bộ | Cơ sở | PENDING |
| K_FMS_205 | 8. Các khoản phải trả, phải nộp ngắn hạn khác | Cơ sở | PENDING |
| K_FMS_206 | 9. Dự phòng phải trả ngắn hạn | Cơ sở | PENDING |
| K_FMS_207 | 10. Quỹ khen thưởng, phúc lợi | Cơ sở | PENDING |
| K_FMS_208 | 11. Giao dịch mua bán lại trái phiếu Chính phủ | Cơ sở | PENDING |
| K_FMS_209 | 12. Doanh thu chưa thực hiện ngắn hạn | Cơ sở | PENDING |
| K_FMS_210 | II. Nợ dài hạn | Cơ sở | PENDING |
| K_FMS_211 | 1. Phải trả dài hạn người bán | Cơ sở | PENDING |
| K_FMS_212 | 2. Phải trả dài hạn nội bộ | Cơ sở | PENDING |
| K_FMS_213 | 3. Phải trả dài hạn khác | Cơ sở | PENDING |
| K_FMS_214 | 4. Vay và nợ dài hạn | Cơ sở | PENDING |
| K_FMS_215 | 5. Thuế thu nhập hoãn lại phải trả | Cơ sở | PENDING |
| K_FMS_216 | 6. Dự phòng trợ cấp mất việc làm | Cơ sở | PENDING |
| K_FMS_217 | 7. Dự phòng phải trả dài hạn | Cơ sở | PENDING |
| K_FMS_218 | 8. Doanh thu chưa thực hiện dài hạn | Cơ sở | PENDING |
| K_FMS_219 | 9. Quỹ phát triển khoa học và công nghệ | Cơ sở | PENDING |
| K_FMS_220 | 10. Quỹ dự phòng bồi thường thiệt hại cho nhà đầu tư | Cơ sở | PENDING |
| K_FMS_221 | B - VỐN CHỦ SỞ HỮU | Cơ sở | PENDING |
| K_FMS_222 | 1. Vốn đầu tư của chủ sở hữu | Cơ sở | PENDING |
| K_FMS_223 | 2. Thặng dư vốn cổ phần | Cơ sở | PENDING |
| K_FMS_224 | 3. Vốn khác của chủ sở hữu | Cơ sở | PENDING |
| K_FMS_225 | 4. Cổ phiếu quỹ (*) | Cơ sở | PENDING |
| K_FMS_226 | 5. Chênh lệch đánh giá lại tài sản | Cơ sở | PENDING |
| K_FMS_227 | 6. Chênh lệch tỷ giá hối đoái | Cơ sở | PENDING |
| K_FMS_228 | 7. Quỹ đầu tư phát triển | Cơ sở | PENDING |
| K_FMS_229 | 8. Quỹ dự phòng tài chính | Cơ sở | PENDING |
| K_FMS_230 | 9. Quỹ khác thuộc vốn chủ sở hữu | Cơ sở | PENDING |
| K_FMS_231 | 10. Lợi nhuận sau thuế chưa phân phối | Cơ sở | PENDING |
| K_FMS_232 | TỔNG CỘNG NGUỒN VỐN (440 = 300 + 400) | Cơ sở | PENDING |
| K_FMS_233 | 1. Tài sản cố định thuê ngoài | Cơ sở | PENDING |
| K_FMS_234 | 2. Vật tư, chứng chỉ có giá nhận giữ hộ | Cơ sở | PENDING |
| K_FMS_235 | 3. Tài sản nhận ký cược | Cơ sở | PENDING |
| K_FMS_236 | 4. Nợ khó đòi đã xử lý | Cơ sở | PENDING |
| K_FMS_237 | 5. Ngoại tệ các loại | Cơ sở | PENDING |
| K_FMS_238 | 6. Chứng khoán lưu ký của công ty quản lý quỹ | Cơ sở | PENDING |
| K_FMS_239 | Trong đó: | Cơ sở | PENDING |
| K_FMS_240 | 6.1. Chứng khoán giao dịch | Cơ sở | PENDING |
| K_FMS_241 | 6.2. Chứng khoán tạm ngừng giao dịch | Cơ sở | PENDING |
| K_FMS_242 | 6.3. Chứng khoán cầm cố | Cơ sở | PENDING |
| K_FMS_243 | 6.4. Chứng khoán tạm giữ | Cơ sở | PENDING |
| K_FMS_244 | 6.5. Chứng khoán chờ thanh toán | Cơ sở | PENDING |
| K_FMS_245 | 6.6. Chứng khoán phong toả chờ rút | Cơ sở | PENDING |
| K_FMS_246 | 6.7. Chứng khoán chờ giao dịch | Cơ sở | PENDING |
| K_FMS_247 | 6.8. Chứng khoán ký quỹ đảm bảo khoản vay | Cơ sở | PENDING |
| K_FMS_248 | 6.9 Chứng khoán sửa lỗi giao dịch | Cơ sở | PENDING |
| K_FMS_249 | 7. Chứng khoán chưa lưu ký của Công ty quản lý quỹ | Cơ sở | PENDING |
| K_FMS_250 | 8. Tiền gửi của nhà đầu tư ủy thác | Cơ sở | PENDING |
| K_FMS_251 | - Tiền gửi của nhà đầu tư ủy thác trong nước | Cơ sở | PENDING |
| K_FMS_252 | - Tiền gửi của nhà đầu tư ủy thác nước ngoài | Cơ sở | PENDING |
| K_FMS_253 | 9. Danh mục đầu tư của nhà đầu tư ủy thác | Cơ sở | PENDING |
| K_FMS_254 | 9.1. Nhà đầu tư ủy thác trong nước | Cơ sở | PENDING |
| K_FMS_255 | 9.2. Nhà đầu tư ủy thác nước ngoài | Cơ sở | PENDING |
| K_FMS_256 | 10. Các khoản phải thu của nhà đầu tư ủy thác | Cơ sở | PENDING |
| K_FMS_257 | 11. Các khoản phải trả của nhà đầu tư ủy thác | Cơ sở | PENDING |

#### Nhóm — Báo cáo tỷ lệ an toàn tài chính

**KPI liên quan:** K_FMS_792 – K_FMS_947

| KPI ID | Tên KPI | Tính chất | Trạng thái |
|---|---|---|---|
| K_FMS_792 | Nguồn vốn chủ sở hữu | Cơ sở | PENDING |
| K_FMS_793 | Vốn chủ sở hữu không bao gồm cổ phần ưu đãi hoàn lại (nếu có) | Cơ sở | PENDING |
| K_FMS_794 | Thặng dư vốn cổ phần không bao gồm cổ phần ưu đãi hoàn lại (nếu có) | Cơ sở | PENDING |
| K_FMS_795 | Cổ phiếu quỹ | Cơ sở | PENDING |
| K_FMS_796 | Quỹ dự trữ bổ sung vốn điều lệ (nếu có) | Cơ sở | PENDING |
| K_FMS_797 | Quỹ đầu tư phát triển (nếu có) | Cơ sở | PENDING |
| K_FMS_798 | Quỹ dự phòng tài chính và rủi ro nghiệp vụ | Cơ sở | PENDING |
| K_FMS_799 | Quỹ khác thuộc vốn chủ sở hữu | Cơ sở | PENDING |
| K_FMS_800 | Lợi nhuận sau thuế chưa phân phối | Cơ sở | PENDING |
| K_FMS_801 | Số dư dự phòng suy giảm giá trị tài sản | Cơ sở | PENDING |
| K_FMS_802 | Chênh lệch đánh giá lại tài sản cố định | Cơ sở | PENDING |
| K_FMS_803 | Chênh lệch tỷ giá hối đoái | Cơ sở | PENDING |
| K_FMS_804 | Các khoản nợ có thể chuyển đổi | Cơ sở | PENDING |
| K_FMS_805 | Toàn bộ phần giảm đi hoặc tăng thêm của các chứng khoán tại chỉ tiêu đầu tư tài chính | Cơ sở | PENDING |
| K_FMS_806 | Vốn khác (nếu có) | Cơ sở | PENDING |
| K_FMS_807 | Tổng | Cơ sở | PENDING |
| K_FMS_808 | Tài sản ngắn hạn | Cơ sở | PENDING |
| K_FMS_809 | Tiền và các khoản tương đương tiền | Cơ sở | PENDING |
| K_FMS_810 | Các khoản đầu tư tài chính ngắn hạn | Cơ sở | PENDING |
| K_FMS_811 | Đầu tư ngắn hạn | Cơ sở | PENDING |
| K_FMS_812 | Chứng khoán tiềm ẩn rủi ro thị trường theo quy định tại khoản 2 Điều 9 | Cơ sở | PENDING |
| K_FMS_813 | Chứng khoán bị giảm trừ khỏi vốn khả dụng theo quy định khoản 5 Điều 6 | Cơ sở | PENDING |
| K_FMS_814 | Dự phòng giảm giá đầu tư ngắn hạn | Cơ sở | PENDING |
| K_FMS_815 | Các khoản phải thu ngắn hạn, kể cả phải thu từ hoạt động ủy thác | Cơ sở | PENDING |
| K_FMS_816 | Phải thu của khách hàng | Cơ sở | PENDING |
| K_FMS_817 | Phải thu của khách hàng có thời hạn thanh toán còn lại từ 90 ngày trở xuống | Cơ sở | PENDING |
| K_FMS_818 | Phải thu của khách hàng có thời hạn thanh toán còn lại trên 90 ngày | Cơ sở | PENDING |
| K_FMS_819 | Trả trước cho người bán | Cơ sở | PENDING |
| K_FMS_820 | Phải thu hoạt động nghiệp vụ | Cơ sở | PENDING |
| K_FMS_821 | Phải thu hoạt động nghiệp vụ có thời hạn thanh toán còn lại từ 90 ngày trở xuống | Cơ sở | PENDING |
| K_FMS_822 | Phải thu hoạt động nghiệp vụ có thời hạn thanh toán còn lại trên 90 ngày | Cơ sở | PENDING |
| K_FMS_823 | Phải thu nội bộ ngắn hạn | Cơ sở | PENDING |
| K_FMS_824 | Phải thu nội bộ có thời hạn thanh toán còn lại từ 90 ngày trở xuống | Cơ sở | PENDING |
| K_FMS_825 | Phải thu nội bộ có thời hạn thanh toán còn lại trên 90 ngày | Cơ sở | PENDING |
| K_FMS_826 | Phải thu hoạt động giao dịch chứng khoán | Cơ sở | PENDING |
| K_FMS_827 | Phải thu hoạt động giao dịch chứng khoán có thời hạn thanh toán còn lại từ 90 ngày trở xuống | Cơ sở | PENDING |
| K_FMS_828 | Phải thu hoạt động giao dịch chứng khoán có thời hạn thanh toán còn lại trên 90 ngày | Cơ sở | PENDING |
| K_FMS_829 | Các khoản phải thu khác | Cơ sở | PENDING |
| K_FMS_830 | Phải thu khác có thời hạn thanh toán còn lại từ 90 ngày trở xuống | Cơ sở | PENDING |
| K_FMS_831 | Phải thu khác có thời hạn thanh toán còn lại trên 90 ngày | Cơ sở | PENDING |
| K_FMS_832 | Dự phòng phải thu ngắn hạn khó đòi | Cơ sở | PENDING |
| K_FMS_833 | Hàng tồn kho | Cơ sở | PENDING |
| K_FMS_834 | Tài sản ngắn hạn khác | Cơ sở | PENDING |
| K_FMS_835 | Chi phí trả trước ngắn hạn | Cơ sở | PENDING |
| K_FMS_836 | Thuế GTGT được khấu trừ | Cơ sở | PENDING |
| K_FMS_837 | Thuế và các khoản phải thu nhà nước | Cơ sở | PENDING |
| K_FMS_838 | Tài sản ngắn hạn khác | Cơ sở | PENDING |
| K_FMS_839 | Tạm ứng | Cơ sở | PENDING |
| K_FMS_840 | Tạm ứng có thời hạn hoàn ứng còn lại từ 90 ngày trở xuống | Cơ sở | PENDING |
| K_FMS_841 | Tạm ứng có thời hạn hoàn ứng còn lại trên 90 ngày | Cơ sở | PENDING |
| K_FMS_842 | Tài sản ngắn hạn khác | Cơ sở | PENDING |
| K_FMS_843 | Tổng | Cơ sở | PENDING |
| K_FMS_844 | Tài sản dài hạn | Cơ sở | PENDING |
| K_FMS_845 | Các khoản phải thu dài hạn, kể cả phải thu từ hoạt động ủy thác | Cơ sở | PENDING |
| K_FMS_846 | Phải thu dài hạn của khách hàng | Cơ sở | PENDING |
| K_FMS_847 | Phải thu dài hạn của khách hàng có thời hạn thanh toán còn lại từ 90 ngày trở xuống | Cơ sở | PENDING |
| K_FMS_848 | Phải thu dài hạn của khách hàng có thời hạn thanh toán còn lại trên 90 ngày | Cơ sở | PENDING |
| K_FMS_849 | Vốn kinh doanh ở đơn vị trực thuộc | Cơ sở | PENDING |
| K_FMS_850 | Phải thu dài hạn nội bộ | Cơ sở | PENDING |
| K_FMS_851 | Phải thu dài hạn nội bộ có thời hạn thanh toán còn lại từ 90 ngày trở xuống | Cơ sở | PENDING |
| K_FMS_852 | Phải thu dài hạn nội bộ có thời hạn thanh toán còn lại trên 90 ngày | Cơ sở | PENDING |
| K_FMS_853 | Phải thu dài hạn khác | Cơ sở | PENDING |
| K_FMS_854 | Phải thu dài hạn khác có thời hạn thanh toán còn lại từ 90 ngày trở xuống | Cơ sở | PENDING |
| K_FMS_855 | Phải thu dài hạn khác có thời hạn thanh toán còn lại trên 90 ngày | Cơ sở | PENDING |
| K_FMS_856 | Dự phòng phải thu dài hạn khó đòi | Cơ sở | PENDING |
| K_FMS_857 | Tài sản cố định | Cơ sở | PENDING |
| K_FMS_858 | Bất động sản đầu tư | Cơ sở | PENDING |
| K_FMS_859 | Các khoản đầu tư tài chính dài hạn | Cơ sở | PENDING |
| K_FMS_860 | Đầu tư vào công ty con | Cơ sở | PENDING |
| K_FMS_861 | Đầu tư chứng khoán dài hạn | Cơ sở | PENDING |
| K_FMS_862 | Chứng khoán tiềm ẩn rủi ro thị trường theo quy định tại khoản 2 Điều 9 | Cơ sở | PENDING |
| K_FMS_863 | Chứng khoán bị giảm trừ khỏi vốn khả dụng theo quy định tại khoản 5 Điều 6 | Cơ sở | PENDING |
| K_FMS_864 | Các khoản đầu tư dài hạn ra nước ngoài | Cơ sở | PENDING |
| K_FMS_865 | Đầu tư dài hạn khác | Cơ sở | PENDING |
| K_FMS_866 | Dự phòng giảm giá đầu tư tài chính dài hạn | Cơ sở | PENDING |
| K_FMS_867 | Tài sản dài hạn khác | Cơ sở | PENDING |
| K_FMS_868 | Chi phí trả trước dài hạn | Cơ sở | PENDING |
| K_FMS_869 | Tài sản thuế thu nhập hoãn lại | Cơ sở | PENDING |
| K_FMS_870 | Ký cược, ký quỹ dài hạn | Cơ sở | PENDING |
| K_FMS_871 | Các chỉ tiêu tài sản bị coi là khoản ngoại trừ, có ý kiến trái ngược hoặc từ chối đưa ra ý kiến tại báo cáo tài chính đã được kiểm toán, soát xét mà không bị tính giảm trừ theo quy định tại Điều 6 | Cơ sở | PENDING |
| K_FMS_872 | Tổng | Cơ sở | PENDING |
| K_FMS_873 | VỐN KHẢ DỤNG = 1A-1B-1C | Cơ sở | PENDING |
| K_FMS_874 | RỦI RO THỊ TRƯỜNG | Cơ sở | PENDING |
| K_FMS_875 | Tiền và các khoản tương đương tiền, công cụ thị trường tiền tệ | Cơ sở | PENDING |
| K_FMS_876 | Tiền mặt (VND) | Cơ sở | PENDING |
| K_FMS_877 | Các khoản tương đương tiền | Cơ sở | PENDING |
| K_FMS_878 | Giấy tờ có giá, công cụ chuyển nhượng trên thị trường tiền tệ, chứng chỉ tiền gửi | Cơ sở | PENDING |
| K_FMS_879 | Trái phiếu Chính phủ | Cơ sở | PENDING |
| K_FMS_880 | Trái phiếu Chính phủ không trả lại | Cơ sở | PENDING |
| K_FMS_881 | Trái phiếu Chính phủ trả lãi suất cuống phiếu: Trái phiếu Chính phủ (bao gồm công trái và trái phiếu công trình đã phát hành trước đây), trái phiếu Chính phủ các nước thuộc khối OECD hoặc được bảo lãnh bởi Chính phủ hoặc Ngân hàng Trung ương của các nước thuộc khối này, trái phiếu được phát hành bởi các tổ chức quốc tế IBRD, ADB, IADB, AFDB, EIB và EBRD, Trái phiếu chính quyền địa phương. | Cơ sở | PENDING |
| K_FMS_882 | Trái phiếu tổ chức tín dụng | Cơ sở | PENDING |
| K_FMS_883 | Trái phiếu tổ chức tín dụng có thời gian đáo hạn còn lại dưới 1 năm, kể cả trái phiếu chuyển đổi | Cơ sở | PENDING |
| K_FMS_884 | Trái phiếu tổ chức tín dụng có thời gian đáo hạn còn từ 1 năm đến dưới 3 năm, kể cả trái phiếu chuyển đổi | Cơ sở | PENDING |
| K_FMS_885 | Trái phiếu tổ chức tín dụng có thời gian đáo hạn còn lại từ 3 năm đến dưới 5 năm, kể cả trái phiếu chuyển đổi | Cơ sở | PENDING |
| K_FMS_886 | Trái phiếu tổ chức tín dụng có thời gian đáo hạn còn lại từ 5 năm trở lên, kể cả trái phiếu chuyển đổi | Cơ sở | PENDING |
| K_FMS_887 | Trái phiếu doanh nghiệp | Cơ sở | PENDING |
| K_FMS_888 | Trái phiếu doanh nghiệp niêm yết | Cơ sở | PENDING |
| K_FMS_889 | Trái phiếu niêm yết có thời gian đáo hạn còn lại dưới 1 năm, kể cả trái phiếu chuyển đổi | Cơ sở | PENDING |
| K_FMS_890 | Trái phiếu niêm yết có thời gian đáo hạn còn lại từ 1 năm đến dưới 3 năm, kể cả trái phiếu chuyển đổi | Cơ sở | PENDING |
| K_FMS_891 | Trái phiếu niêm yết có thời gian đáo hạn còn lại từ 3 năm đến dưới 5 năm, kể cả trái phiếu chuyển đổi | Cơ sở | PENDING |
| K_FMS_892 | Trái phiếu niêm yết có thời gian đáo hạn còn lại từ 5 năm trở lên, kể cả trái phiếu chuyển đổi | Cơ sở | PENDING |
| K_FMS_893 | Trái phiếu doanh nghiệp không niêm yết | Cơ sở | PENDING |
| K_FMS_894 | Trái phiếu không niêm yết do doanh nghiệp niêm yết phát hành có thời gian đáo hạn còn lại dưới 1 năm, kể cả trái phiếu chuyển đổi | Cơ sở | PENDING |
| K_FMS_895 | Trái phiếu không niêm yết do doanh nghiệp niêm yết phát hành có thời gian đáo hạn còn lại từ 1 năm đến dưới 3 năm, kể cả trái phiếu chuyển đổi | Cơ sở | PENDING |
| K_FMS_896 | Trái phiếu không niêm yết do doanh nghiệp niêm yết phát hành có thời gian đáo hạn còn lại từ 3 năm đến dưới 5 năm, kể cả trái phiếu chuyển đổi | Cơ sở | PENDING |
| K_FMS_897 | Trái phiếu không niêm yết do doanh nghiệp niêm yết phát hành có thời gian đáo hạn còn lại từ 5 năm trở lên, kể cả trái phiếu chuyển đổi | Cơ sở | PENDING |
| K_FMS_898 | Trái phiếu không niêm yết do doanh nghiệp khác phát hành có thời gian đáo hạn còn lại dưới 1 năm, kể cả trái phiếu chuyển đổi | Cơ sở | PENDING |
| K_FMS_899 | Trái phiếu không niêm yết do doanh nghiệp khác phát hành có thời gian đáo hạn còn lại từ 1 năm đến dưới 3 năm, kể cả trái phiếu chuyển đổi | Cơ sở | PENDING |
| K_FMS_900 | Trái phiếu không niêm yết do doanh nghiệp khác phát hành có thời gian đáo hạn còn lại từ 3 năm đến dưới 5 năm, kể cả trái phiếu chuyển đổi | Cơ sở | PENDING |
| K_FMS_901 | Trái phiếu không niêm yết do doanh nghiệp khác phát hành có thời gian đáo hạn còn lại từ 5 năm trở lên, kể cả trái phiếu chuyển đổi | Cơ sở | PENDING |
| K_FMS_902 | Cổ phiếu phổ thông, cổ phiếu ưu đãi của các tổ chức niêm yết tại Sở giao dịch Chứng khoán Thành phố Hồ Chí Minh; chứng chỉ quỹ mở | Cơ sở | PENDING |
| K_FMS_903 | Cổ phiếu phổ thông, cổ phiếu ưu đãi của các tổ chức niêm yết tại Sở Giao dịch Chứng khoán Hà Nội | Cơ sở | PENDING |
| K_FMS_904 | Cổ phiếu phổ thông, cổ phiếu ưu đãi các công ty đại chúng chưa niêm yết, đăng ký giao dịch qua hệ thống UpCom | Cơ sở | PENDING |
| K_FMS_905 | Cổ phiếu phổ thông, cổ phiếu ưu đãi của các công ty đại chúng đã đăng ký lưu ký, nhưng chưa niêm yết hoặc đăng ký giao dịch; cổ phiếu đang trong đợt phát hành lần đầu (IPO) | Cơ sở | PENDING |
| K_FMS_906 | Cổ phiếu của các công ty đại chúng khác | Cơ sở | PENDING |
| K_FMS_907 | Quỹ đại chúng, bao gồm cả công ty đầu tư chứng khoán đại chúng | Cơ sở | PENDING |
| K_FMS_908 | Quỹ thành viên, công ty đầu tư chứng khoán riêng lẻ | Cơ sở | PENDING |
| K_FMS_909 | Chứng khoán công ty đại chúng chưa niêm yết bị nhắc nhở do chậm công bố thông tin báo cáo tài chính kiểm toán/soát xét theo quy định | Cơ sở | PENDING |
| K_FMS_910 | Chứng khoán niêm yết bị cảnh báo | Cơ sở | PENDING |
| K_FMS_911 | Chứng khoán niêm yết bị kiểm soát | Cơ sở | PENDING |
| K_FMS_912 | Chứng khoán bị tạm ngừng, hạn chế giao dịch | Cơ sở | PENDING |
| K_FMS_913 | Chứng khoán bị hủy niêm yết, hủy giao dịch | Cơ sở | PENDING |
| K_FMS_914 | Cổ phiếu, trái phiếu của công ty chưa đại chúng phát hành không có báo cáo tài chính kiểm toán gần nhất đến thời điểm lập báo cáo hoặc có báo cáo tài chính kiểm toán nhưng có ý kiến kiểm toán là trái ngược, từ chối đưa ra ý kiến hoặc ý kiến không chấp thuận toàn phần. | Cơ sở | PENDING |
| K_FMS_915 | Cổ phần, phần vốn góp và các loại chứng khoán khác | Cơ sở | PENDING |
| K_FMS_916 | Các tài sản đầu tư khác | Cơ sở | PENDING |
| K_FMS_917 | RỦI RO THANH TOÁN | Cơ sở | PENDING |
| K_FMS_918 | Rủi ro trước thời hạn thanh toán | Cơ sở | PENDING |
| K_FMS_919 | Tiền gửi có kỳ hạn, chứng chỉ tiền gửi, các khoản tiền cho vay không có tài sản bảo đảm, các khoản phải thu từ hoạt động kinh doanh chứng khoán và các khoản mục tiềm ẩn rủi ro thanh toán khác | Cơ sở | PENDING |
| K_FMS_920 | Cho vay chứng khoán/Các thỏa thuận kinh tế có cùng bản chất | Cơ sở | PENDING |
| K_FMS_921 | Vay chứng khoán/Các thỏa thuận kinh tế có cùng bản chất | Cơ sở | PENDING |
| K_FMS_922 | Hợp đồng mua chứng khoán có cam kết bán lại/Các thỏa thuận kinh tế có cùng bản chất | Cơ sở | PENDING |
| K_FMS_923 | Hợp đồng bán chứng khoán có cam kết mua lại/Các thỏa thuận kinh tế có cùng bản chất | Cơ sở | PENDING |
| K_FMS_924 | Hợp đồng cho vay mua ký quỹ (cho khách hàng vay mua chứng khoán)/Các thỏa thuận kinh tế có cùng bản chất | Cơ sở | PENDING |
| K_FMS_925 | Rủi ro quá thời hạn thanh toán | Cơ sở | PENDING |
| K_FMS_926 | Từ 0 đến 15 ngày sau thời hạn thanh toán, chuyển giao chứng khoán | Cơ sở | PENDING |
| K_FMS_927 | Từ 16 đến 30 ngày sau thời hạn thanh toán, chuyển giao chứng khoán | Cơ sở | PENDING |
| K_FMS_928 | Từ 31 đến 60 ngày sau thời hạn thanh toán, chuyển giao chứng khoán | Cơ sở | PENDING |
| K_FMS_929 | Trên 60 ngày sau thời hạn thanh toán, chuyển giao chứng khoán | Cơ sở | PENDING |
| K_FMS_930 | Rủi ro tăng thêm (nếu có) | Cơ sở | PENDING |
| K_FMS_931 | Chi tiết tới từng khoản vay, tới từng đối tác | Cơ sở | PENDING |
| K_FMS_932 | RỦI RO HOẠT ĐỘNG (TÍNH TRONG VÒNG 12 THÁNG) | Cơ sở | PENDING |
| K_FMS_933 | Tổng chi phí hoạt động phát sinh trong vòng 12 tháng tính tới tháng xx năm 20xx | Cơ sở | PENDING |
| K_FMS_934 | Các khoản giảm trừ khỏi tổng chi phí | Cơ sở | PENDING |
| K_FMS_935 | Chi phí khấu hao | Cơ sở | PENDING |
| K_FMS_936 | Chi phí/Hoàn nhập dự phòng giảm giá đầu tư chứng khoán ngắn hạn | Cơ sở | PENDING |
| K_FMS_937 | Chi phí/Hoàn nhập dự phòng giảm giá đầu tư chứng khoán dài hạn | Cơ sở | PENDING |
| K_FMS_938 | Chi phí/Hoàn nhập dự phòng phải thu khó đòi | Cơ sở | PENDING |
| K_FMS_939 | Tổng chi phí sau khi giảm trừ (III = I – II) | Cơ sở | PENDING |
| K_FMS_940 | 25% Tổng chi phí sau khi giảm trừ (IV = 25% III) | Cơ sở | PENDING |
| K_FMS_941 | 20% Vốn pháp định của tổ chức kinh doanh chứng khoán | Cơ sở | PENDING |
| K_FMS_942 | Tổng giá trị rủi ro thị trường | Cơ sở | PENDING |
| K_FMS_943 | Tổng giá trị rủi ro thanh toán | Cơ sở | PENDING |
| K_FMS_944 | Tổng giá trị rủi ro hoạt động | Cơ sở | PENDING |
| K_FMS_945 | Tổng giá trị rủi ro (4=1+2+3) | Cơ sở | PENDING |
| K_FMS_946 | Vốn khả dụng | Cơ sở | PENDING |
| K_FMS_947 | Tỷ lệ vốn khả dụng tháng (6=5/4) | Cơ sở | PENDING |

#### Nhóm — Báo cáo về tình hình quản lý danh mục đầu tư

**KPI liên quan:** K_FMS_356 – K_FMS_791

| KPI ID | Tên KPI | Tính chất | Trạng thái |
|---|---|---|---|
| K_FMS_356 | Tổng số Hợp đồng ủy thác đầu tư đang thực hiện | Cơ sở | PENDING |
| K_FMS_357 | - Tổ chức (%) | Cơ sở | PENDING |
| K_FMS_358 | - Cá nhân (%) | Cơ sở | PENDING |
| K_FMS_359 | Tổng giá trị các Hợp đồng ủy thác đầu tư (Hợp đồng khung) (VND) | Cơ sở | PENDING |
| K_FMS_360 | - Tổ chức (%) | Cơ sở | PENDING |
| K_FMS_361 | - Cá nhân (%) | Cơ sở | PENDING |
| K_FMS_362 | Tổng giá trị các Hợp đồng ủy thác đầu tư (Giá trị giải ngân thực tế) (VND) | Cơ sở | PENDING |
| K_FMS_363 | - Tổ chức (%) | Cơ sở | PENDING |
| K_FMS_364 | - Cá nhân (%) | Cơ sở | PENDING |
| K_FMS_365 | Tổng giá trị thị trường các Hợp đồng ủy thác đầu tư (VND) | Cơ sở | PENDING |
| K_FMS_366 | - Tổ chức (%) | Cơ sở | PENDING |
| K_FMS_367 | - Cá nhân (%) | Cơ sở | PENDING |
| K_FMS_368 | Tổng giá trị giá dịch vụ quản lý danh mục đầu tư thu được trong kỳ (VND) | Cơ sở | PENDING |
| K_FMS_369 | Tỷ lệ giá dịch vụ quản lý danh mục đầu tư bình quân (5/4) | Cơ sở | PENDING |
| K_FMS_370 | Khối lượng (Mua) | Cơ sở | PENDING |
| K_FMS_371 | Giá trị giao dịch (VND) (Mua) | Cơ sở | PENDING |
| K_FMS_372 | Khối lượng (Bán) | Cơ sở | PENDING |
| K_FMS_373 | Giá trị giao dịch (VND) (Bán) | Cơ sở | PENDING |
| K_FMS_374 | Tổng giá trị mua bán/tổng giá trị tài sản quản lý ủy thác bình quân-Kỳ này | Cơ sở | PENDING |
| K_FMS_375 | Tổng giá trị mua bán/tổng giá trị tài sản quản lý ủy thác bình quân-Kỳ trước | Cơ sở | PENDING |
| K_FMS_376 | Giá trị HĐUT | Cơ sở | PENDING |
| K_FMS_377 | Giá trị giải ngân thực tế | Cơ sở | PENDING |
| K_FMS_378 | Phí QL | Cơ sở | PENDING |
| K_FMS_379 | Chứng khoán niêm yết, đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_380 | Cổ phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_381 | Tổng | Cơ sở | PENDING |
| K_FMS_382 | Chứng chỉ quỹ | Cơ sở | PENDING |
| K_FMS_383 | Tổng | Cơ sở | PENDING |
| K_FMS_384 | Cổ phiếu đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_385 | Tổng | Cơ sở | PENDING |
| K_FMS_386 | Trái phiếu | Cơ sở | PENDING |
| K_FMS_387 | Tổng | Cơ sở | PENDING |
| K_FMS_388 | Các loại chứng khoán niêm yết | Cơ sở | PENDING |
| K_FMS_389 | Tổng | Cơ sở | PENDING |
| K_FMS_390 | Tổng chứng khoán niêm yết, đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_391 | Chứng khoán chưa niêm yết, chưa đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_392 | Cổ phiếu | Cơ sở | PENDING |
| K_FMS_393 | Tổng | Cơ sở | PENDING |
| K_FMS_394 | Chứng chỉ quỹ | Cơ sở | PENDING |
| K_FMS_395 | Tổng | Cơ sở | PENDING |
| K_FMS_396 | Trái phiếu | Cơ sở | PENDING |
| K_FMS_397 | Tổng | Cơ sở | PENDING |
| K_FMS_398 | Các loại chứng khoán chưa niêm yết, chưa đăng ký giao dịch khác | Cơ sở | PENDING |
| K_FMS_399 | Tổng | Cơ sở | PENDING |
| K_FMS_400 | Tổng chứng khoán chưa niêm yết, chưa đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_401 | Các tài sản khác | Cơ sở | PENDING |
| K_FMS_402 | Tổng | Cơ sở | PENDING |
| K_FMS_403 | Tiền | Cơ sở | PENDING |
| K_FMS_404 | Tiền, tương đương tiền | Cơ sở | PENDING |
| K_FMS_405 | Tiền gửi ngân hàng | Cơ sở | PENDING |
| K_FMS_406 | Tổng | Cơ sở | PENDING |
| K_FMS_407 | Tổng các danh mục đầu tư | Cơ sở | PENDING |
| K_FMS_408 | Giá trị HĐUT | Cơ sở | PENDING |
| K_FMS_409 | Giá trị giải ngân thực tế | Cơ sở | PENDING |
| K_FMS_410 | Phí QL | Cơ sở | PENDING |
| K_FMS_411 | Chứng khoán niêm yết, đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_412 | Cổ phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_413 | Tổng | Cơ sở | PENDING |
| K_FMS_414 | Chứng chỉ quỹ | Cơ sở | PENDING |
| K_FMS_415 | Tổng | Cơ sở | PENDING |
| K_FMS_416 | Cổ phiếu đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_417 | Tổng | Cơ sở | PENDING |
| K_FMS_418 | Trái phiếu | Cơ sở | PENDING |
| K_FMS_419 | Tổng | Cơ sở | PENDING |
| K_FMS_420 | Các loại chứng khoán niêm yết | Cơ sở | PENDING |
| K_FMS_421 | Tổng | Cơ sở | PENDING |
| K_FMS_422 | Tổng chứng khoán niêm yết, đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_423 | Chứng khoán chưa niêm yết, chưa đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_424 | Cổ phiếu | Cơ sở | PENDING |
| K_FMS_425 | Tổng | Cơ sở | PENDING |
| K_FMS_426 | Chứng chỉ quỹ | Cơ sở | PENDING |
| K_FMS_427 | Tổng | Cơ sở | PENDING |
| K_FMS_428 | Trái phiếu | Cơ sở | PENDING |
| K_FMS_429 | Tổng | Cơ sở | PENDING |
| K_FMS_430 | Các loại chứng khoán chưa niêm yết, chưa đăng ký giao dịch khác | Cơ sở | PENDING |
| K_FMS_431 | Tổng | Cơ sở | PENDING |
| K_FMS_432 | Tổng chứng khoán chưa niêm yết, chưa đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_433 | Các tài sản khác | Cơ sở | PENDING |
| K_FMS_434 | Tổng | Cơ sở | PENDING |
| K_FMS_435 | Tiền | Cơ sở | PENDING |
| K_FMS_436 | Tiền, tương đương tiền | Cơ sở | PENDING |
| K_FMS_437 | Tiền gửi ngân hàng | Cơ sở | PENDING |
| K_FMS_438 | Tổng | Cơ sở | PENDING |
| K_FMS_439 | Tổng các danh mục đầu tư | Cơ sở | PENDING |
| K_FMS_440 | Giá trị HĐUT | Cơ sở | PENDING |
| K_FMS_441 | Giá trị giải ngân thực tế | Cơ sở | PENDING |
| K_FMS_442 | Phí QL | Cơ sở | PENDING |
| K_FMS_443 | Chứng khoán niêm yết, đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_444 | Cổ phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_445 | Tổng | Cơ sở | PENDING |
| K_FMS_446 | Chứng chỉ quỹ | Cơ sở | PENDING |
| K_FMS_447 | Tổng | Cơ sở | PENDING |
| K_FMS_448 | Cổ phiếu đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_449 | Tổng | Cơ sở | PENDING |
| K_FMS_450 | Trái phiếu | Cơ sở | PENDING |
| K_FMS_451 | Tổng | Cơ sở | PENDING |
| K_FMS_452 | Các loại chứng khoán niêm yết | Cơ sở | PENDING |
| K_FMS_453 | Tổng | Cơ sở | PENDING |
| K_FMS_454 | Tổng chứng khoán niêm yết, đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_455 | Chứng khoán chưa niêm yết, chưa đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_456 | Cổ phiếu | Cơ sở | PENDING |
| K_FMS_457 | Tổng | Cơ sở | PENDING |
| K_FMS_458 | Chứng chỉ quỹ | Cơ sở | PENDING |
| K_FMS_459 | Tổng | Cơ sở | PENDING |
| K_FMS_460 | Trái phiếu | Cơ sở | PENDING |
| K_FMS_461 | Tổng | Cơ sở | PENDING |
| K_FMS_462 | Các loại chứng khoán chưa niêm yết, chưa đăng ký giao dịch khác | Cơ sở | PENDING |
| K_FMS_463 | Tổng | Cơ sở | PENDING |
| K_FMS_464 | Tổng chứng khoán chưa niêm yết, chưa đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_465 | Các tài sản khác | Cơ sở | PENDING |
| K_FMS_466 | Tổng | Cơ sở | PENDING |
| K_FMS_467 | Tiền | Cơ sở | PENDING |
| K_FMS_468 | Tiền, tương đương tiền | Cơ sở | PENDING |
| K_FMS_469 | Tiền gửi ngân hàng | Cơ sở | PENDING |
| K_FMS_470 | Tổng | Cơ sở | PENDING |
| K_FMS_471 | Tổng các danh mục đầu tư | Cơ sở | PENDING |
| K_FMS_472 | Chứng khoán niêm yết, đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_473 | Cổ phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_474 | Tổng | Cơ sở | PENDING |
| K_FMS_475 | Chứng chỉ quỹ | Cơ sở | PENDING |
| K_FMS_476 | Tổng | Cơ sở | PENDING |
| K_FMS_477 | Cổ phiếu đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_478 | Tổng | Cơ sở | PENDING |
| K_FMS_479 | Trái phiếu | Cơ sở | PENDING |
| K_FMS_480 | Tổng | Cơ sở | PENDING |
| K_FMS_481 | Các loại chứng khoán niêm yết | Cơ sở | PENDING |
| K_FMS_482 | Tổng | Cơ sở | PENDING |
| K_FMS_483 | Tổng chứng khoán niêm yết, đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_484 | Chứng khoán chưa niêm yết, chưa đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_485 | Cổ phiếu | Cơ sở | PENDING |
| K_FMS_486 | Tổng | Cơ sở | PENDING |
| K_FMS_487 | Chứng chỉ quỹ | Cơ sở | PENDING |
| K_FMS_488 | Tổng | Cơ sở | PENDING |
| K_FMS_489 | Trái phiếu | Cơ sở | PENDING |
| K_FMS_490 | Tổng | Cơ sở | PENDING |
| K_FMS_491 | Các loại chứng khoán chưa niêm yết, chưa đăng ký giao dịch khác | Cơ sở | PENDING |
| K_FMS_492 | Tổng | Cơ sở | PENDING |
| K_FMS_493 | Tổng chứng khoán chưa niêm yết, chưa đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_494 | Các tài sản khác | Cơ sở | PENDING |
| K_FMS_495 | Tổng | Cơ sở | PENDING |
| K_FMS_496 | Tiền | Cơ sở | PENDING |
| K_FMS_497 | Tiền, tương đương tiền | Cơ sở | PENDING |
| K_FMS_498 | Tiền gửi ngân hàng | Cơ sở | PENDING |
| K_FMS_499 | Tổng | Cơ sở | PENDING |
| K_FMS_500 | Tổng các danh mục đầu tư | Cơ sở | PENDING |
| K_FMS_501 | Chứng khoán niêm yết, đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_502 | Cổ phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_503 | Tổng | Cơ sở | PENDING |
| K_FMS_504 | Chứng chỉ quỹ | Cơ sở | PENDING |
| K_FMS_505 | Tổng | Cơ sở | PENDING |
| K_FMS_506 | Cổ phiếu đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_507 | Tổng | Cơ sở | PENDING |
| K_FMS_508 | Trái phiếu | Cơ sở | PENDING |
| K_FMS_509 | Tổng | Cơ sở | PENDING |
| K_FMS_510 | Các loại chứng khoán niêm yết | Cơ sở | PENDING |
| K_FMS_511 | Tổng | Cơ sở | PENDING |
| K_FMS_512 | Tổng chứng khoán niêm yết, đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_513 | Chứng khoán chưa niêm yết, chưa đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_514 | Cổ phiếu | Cơ sở | PENDING |
| K_FMS_515 | Tổng | Cơ sở | PENDING |
| K_FMS_516 | Chứng chỉ quỹ | Cơ sở | PENDING |
| K_FMS_517 | Tổng | Cơ sở | PENDING |
| K_FMS_518 | Trái phiếu | Cơ sở | PENDING |
| K_FMS_519 | Tổng | Cơ sở | PENDING |
| K_FMS_520 | Các loại chứng khoán chưa niêm yết, chưa đăng ký giao dịch khác | Cơ sở | PENDING |
| K_FMS_521 | Tổng | Cơ sở | PENDING |
| K_FMS_522 | Tổng chứng khoán chưa niêm yết, chưa đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_523 | Các tài sản khác | Cơ sở | PENDING |
| K_FMS_524 | Tổng | Cơ sở | PENDING |
| K_FMS_525 | Tiền | Cơ sở | PENDING |
| K_FMS_526 | Tiền, tương đương tiền | Cơ sở | PENDING |
| K_FMS_527 | Tiền gửi ngân hàng | Cơ sở | PENDING |
| K_FMS_528 | Tổng | Cơ sở | PENDING |
| K_FMS_529 | Tổng các danh mục đầu tư | Cơ sở | PENDING |
| K_FMS_530 | Chứng khoán niêm yết, đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_531 | Cổ phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_532 | Tổng | Cơ sở | PENDING |
| K_FMS_533 | Chứng chỉ quỹ | Cơ sở | PENDING |
| K_FMS_534 | Tổng | Cơ sở | PENDING |
| K_FMS_535 | Cổ phiếu đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_536 | Tổng | Cơ sở | PENDING |
| K_FMS_537 | Trái phiếu | Cơ sở | PENDING |
| K_FMS_538 | Tổng | Cơ sở | PENDING |
| K_FMS_539 | Các loại chứng khoán niêm yết | Cơ sở | PENDING |
| K_FMS_540 | Tổng | Cơ sở | PENDING |
| K_FMS_541 | Tổng chứng khoán niêm yết, đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_542 | Chứng khoán chưa niêm yết, chưa đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_543 | Cổ phiếu | Cơ sở | PENDING |
| K_FMS_544 | Tổng | Cơ sở | PENDING |
| K_FMS_545 | Chứng chỉ quỹ | Cơ sở | PENDING |
| K_FMS_546 | Tổng | Cơ sở | PENDING |
| K_FMS_547 | Trái phiếu | Cơ sở | PENDING |
| K_FMS_548 | Tổng | Cơ sở | PENDING |
| K_FMS_549 | Các loại chứng khoán chưa niêm yết, chưa đăng ký giao dịch khác | Cơ sở | PENDING |
| K_FMS_550 | Tổng | Cơ sở | PENDING |
| K_FMS_551 | Tổng chứng khoán chưa niêm yết, chưa đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_552 | Các tài sản khác | Cơ sở | PENDING |
| K_FMS_553 | Tổng | Cơ sở | PENDING |
| K_FMS_554 | Tiền | Cơ sở | PENDING |
| K_FMS_555 | Tiền, tương đương tiền | Cơ sở | PENDING |
| K_FMS_556 | Tiền gửi ngân hàng | Cơ sở | PENDING |
| K_FMS_557 | Tổng | Cơ sở | PENDING |
| K_FMS_558 | Tổng các danh mục đầu tư | Cơ sở | PENDING |
| K_FMS_559 | Chứng khoán niêm yết, đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_560 | Cổ phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_561 | Tổng | Cơ sở | PENDING |
| K_FMS_562 | Chứng chỉ quỹ | Cơ sở | PENDING |
| K_FMS_563 | Tổng | Cơ sở | PENDING |
| K_FMS_564 | Cổ phiếu đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_565 | Tổng | Cơ sở | PENDING |
| K_FMS_566 | Trái phiếu | Cơ sở | PENDING |
| K_FMS_567 | Tổng | Cơ sở | PENDING |
| K_FMS_568 | Các loại chứng khoán niêm yết | Cơ sở | PENDING |
| K_FMS_569 | Tổng | Cơ sở | PENDING |
| K_FMS_570 | Tổng chứng khoán niêm yết, đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_571 | Chứng khoán chưa niêm yết, chưa đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_572 | Cổ phiếu | Cơ sở | PENDING |
| K_FMS_573 | Tổng | Cơ sở | PENDING |
| K_FMS_574 | Chứng chỉ quỹ | Cơ sở | PENDING |
| K_FMS_575 | Tổng | Cơ sở | PENDING |
| K_FMS_576 | Trái phiếu | Cơ sở | PENDING |
| K_FMS_577 | Tổng | Cơ sở | PENDING |
| K_FMS_578 | Các loại chứng khoán chưa niêm yết, chưa đăng ký giao dịch khác | Cơ sở | PENDING |
| K_FMS_579 | Tổng | Cơ sở | PENDING |
| K_FMS_580 | Tổng chứng khoán chưa niêm yết, chưa đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_581 | Các tài sản khác | Cơ sở | PENDING |
| K_FMS_582 | Tổng | Cơ sở | PENDING |
| K_FMS_583 | Tiền | Cơ sở | PENDING |
| K_FMS_584 | Tiền, tương đương tiền | Cơ sở | PENDING |
| K_FMS_585 | Tiền gửi ngân hàng | Cơ sở | PENDING |
| K_FMS_586 | Tổng | Cơ sở | PENDING |
| K_FMS_587 | Tổng các danh mục đầu tư | Cơ sở | PENDING |
| K_FMS_588 | Chứng khoán niêm yết, đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_589 | Cổ phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_590 | Tổng | Cơ sở | PENDING |
| K_FMS_591 | Chứng chỉ quỹ | Cơ sở | PENDING |
| K_FMS_592 | Tổng | Cơ sở | PENDING |
| K_FMS_593 | Cổ phiếu đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_594 | Tổng | Cơ sở | PENDING |
| K_FMS_595 | Trái phiếu | Cơ sở | PENDING |
| K_FMS_596 | Tổng | Cơ sở | PENDING |
| K_FMS_597 | Các loại chứng khoán niêm yết khác | Cơ sở | PENDING |
| K_FMS_598 | Tổng | Cơ sở | PENDING |
| K_FMS_599 | Tổng chứng khoán niêm yết, đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_600 | Chứng khoán chưa niêm yết, chưa đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_601 | Cổ phiếu | Cơ sở | PENDING |
| K_FMS_602 | Tổng | Cơ sở | PENDING |
| K_FMS_603 | Chứng chỉ quỹ | Cơ sở | PENDING |
| K_FMS_604 | Tổng | Cơ sở | PENDING |
| K_FMS_605 | Trái phiếu | Cơ sở | PENDING |
| K_FMS_606 | Tổng | Cơ sở | PENDING |
| K_FMS_607 | Các loại chứng khoán chưa niêm yết, chưa đăng ký giao dịch khác | Cơ sở | PENDING |
| K_FMS_608 | Tổng | Cơ sở | PENDING |
| K_FMS_609 | Tổng chứng khoán chưa niêm yết, chưa đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_610 | Các tài sản khác | Cơ sở | PENDING |
| K_FMS_611 | Tổng | Cơ sở | PENDING |
| K_FMS_612 | Tiền | Cơ sở | PENDING |
| K_FMS_613 | Tiền, tương đương tiền | Cơ sở | PENDING |
| K_FMS_614 | Tiền gửi ngân hàng | Cơ sở | PENDING |
| K_FMS_615 | Tổng | Cơ sở | PENDING |
| K_FMS_616 | Tổng các danh mục đầu tư | Cơ sở | PENDING |
| K_FMS_617 | Chứng khoán niêm yết, đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_618 | Cổ phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_619 | Tổng | Cơ sở | PENDING |
| K_FMS_620 | Chứng chỉ quỹ | Cơ sở | PENDING |
| K_FMS_621 | Tổng | Cơ sở | PENDING |
| K_FMS_622 | Cổ phiếu đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_623 | Tổng | Cơ sở | PENDING |
| K_FMS_624 | Trái phiếu | Cơ sở | PENDING |
| K_FMS_625 | Tổng | Cơ sở | PENDING |
| K_FMS_626 | Các loại chứng khoán niêm yết khác | Cơ sở | PENDING |
| K_FMS_627 | Tổng | Cơ sở | PENDING |
| K_FMS_628 | Tổng chứng khoán niêm yết, đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_629 | Chứng khoán chưa niêm yết, chưa đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_630 | Cổ phiếu | Cơ sở | PENDING |
| K_FMS_631 | Tổng | Cơ sở | PENDING |
| K_FMS_632 | Chứng chỉ quỹ | Cơ sở | PENDING |
| K_FMS_633 | Tổng | Cơ sở | PENDING |
| K_FMS_634 | Trái phiếu | Cơ sở | PENDING |
| K_FMS_635 | Tổng | Cơ sở | PENDING |
| K_FMS_636 | Các loại chứng khoán chưa niêm yết, chưa đăng ký giao dịch khác | Cơ sở | PENDING |
| K_FMS_637 | Tổng | Cơ sở | PENDING |
| K_FMS_638 | Tổng chứng khoán chưa niêm yết, chưa đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_639 | Các tài sản khác | Cơ sở | PENDING |
| K_FMS_640 | Tổng | Cơ sở | PENDING |
| K_FMS_641 | Tiền | Cơ sở | PENDING |
| K_FMS_642 | Tiền, tương đương tiền | Cơ sở | PENDING |
| K_FMS_643 | Tiền gửi ngân hàng | Cơ sở | PENDING |
| K_FMS_644 | Tổng | Cơ sở | PENDING |
| K_FMS_645 | Tổng các danh mục đầu tư | Cơ sở | PENDING |
| K_FMS_646 | Chứng khoán niêm yết, đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_647 | Cổ phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_648 | Tổng | Cơ sở | PENDING |
| K_FMS_649 | Chứng chỉ quỹ | Cơ sở | PENDING |
| K_FMS_650 | Tổng | Cơ sở | PENDING |
| K_FMS_651 | Cổ phiếu đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_652 | Tổng | Cơ sở | PENDING |
| K_FMS_653 | Trái phiếu | Cơ sở | PENDING |
| K_FMS_654 | Tổng | Cơ sở | PENDING |
| K_FMS_655 | Các loại chứng khoán niêm yết khác | Cơ sở | PENDING |
| K_FMS_656 | Tổng | Cơ sở | PENDING |
| K_FMS_657 | Tổng chứng khoán niêm yết, đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_658 | Chứng khoán chưa niêm yết, chưa đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_659 | Cổ phiếu | Cơ sở | PENDING |
| K_FMS_660 | Tổng | Cơ sở | PENDING |
| K_FMS_661 | Chứng chỉ quỹ | Cơ sở | PENDING |
| K_FMS_662 | Tổng | Cơ sở | PENDING |
| K_FMS_663 | Trái phiếu | Cơ sở | PENDING |
| K_FMS_664 | Tổng | Cơ sở | PENDING |
| K_FMS_665 | Các loại chứng khoán chưa niêm yết, chưa đăng ký giao dịch khác | Cơ sở | PENDING |
| K_FMS_666 | Tổng | Cơ sở | PENDING |
| K_FMS_667 | Tổng chứng khoán chưa niêm yết, chưa đăng ký giao dịch | Cơ sở | PENDING |
| K_FMS_668 | Các tài sản khác | Cơ sở | PENDING |
| K_FMS_669 | Tổng | Cơ sở | PENDING |
| K_FMS_670 | Tiền | Cơ sở | PENDING |
| K_FMS_671 | Tiền, tương đương tiền | Cơ sở | PENDING |
| K_FMS_672 | Tiền gửi ngân hàng | Cơ sở | PENDING |
| K_FMS_673 | Tổng | Cơ sở | PENDING |
| K_FMS_674 | Tổng các danh mục đầu tư | Cơ sở | PENDING |
| K_FMS_675 | Hạn mức nhận ủy thác được Ngân hàng Nhà nước xác nhận | Cơ sở | PENDING |
| K_FMS_676 | Giá trị đã nhận ủy thác tính đến thời điểm cuối tháng | Cơ sở | PENDING |
| K_FMS_677 | Giá trị đã nhận ủy thác trong tháng | Cơ sở | PENDING |
| K_FMS_678 | Giá trị còn được nhận ủy thác (4)=(1)-(2) | Cơ sở | PENDING |
| K_FMS_679 | Tổng số Hợp đồng ủy thác đầu tư đang thực hiện | Cơ sở | PENDING |
| K_FMS_680 | - Tổ chức (%) | Cơ sở | PENDING |
| K_FMS_681 | - Cá nhân (%) | Cơ sở | PENDING |
| K_FMS_682 | Tổng giá trị các Hợp đồng ủy thác đầu tư (Hợp đồng khung) | Cơ sở | PENDING |
| K_FMS_683 | - Tổ chức (%) | Cơ sở | PENDING |
| K_FMS_684 | - Cá nhân (%) | Cơ sở | PENDING |
| K_FMS_685 | Tổng giá trị các Hợp đồng ủy thác đầu tư (Giá trị giải ngân thực tế) | Cơ sở | PENDING |
| K_FMS_686 | - Tổ chức (%) | Cơ sở | PENDING |
| K_FMS_687 | - Cá nhân (%) | Cơ sở | PENDING |
| K_FMS_688 | Tổng giá trị thị trường các Hợp đồng ủy thác đầu tư | Cơ sở | PENDING |
| K_FMS_689 | - Tổ chức (%) | Cơ sở | PENDING |
| K_FMS_690 | - Cá nhân (%) | Cơ sở | PENDING |
| K_FMS_691 | Tổng giá trị giá dịch vụ quản lý danh mục đầu tư thu được trong kỳ | Cơ sở | PENDING |
| K_FMS_692 | Tỷ lệ giá dịch vụ quản lý danh mục đầu tư bình quân (5/4) | Cơ sở | PENDING |
| K_FMS_693 | Khối lượng mua | Cơ sở | PENDING |
| K_FMS_694 | Giá trị mua (USD) | Cơ sở | PENDING |
| K_FMS_695 | Giá trị mua (VND) | Cơ sở | PENDING |
| K_FMS_696 | Khối lượng bán | Cơ sở | PENDING |
| K_FMS_697 | Giá trị bán (USD) | Cơ sở | PENDING |
| K_FMS_698 | Giá trị bán (VND) | Cơ sở | PENDING |
| K_FMS_699 | Tổng giá trị mua bán/tổng giá trị tài sản quản lý ủy thác bình quân - Kỳ trước | Cơ sở | PENDING |
| K_FMS_700 | Tổng giá trị mua bán/tổng giá trị tài sản quản lý ủy thác bình quân - Kỳ này | Cơ sở | PENDING |
| K_FMS_701 | Chứng chỉ tiền gửi | Cơ sở | PENDING |
| K_FMS_702 | Tổng | Cơ sở | PENDING |
| K_FMS_703 | Trái phiếu Chính phủ | Cơ sở | PENDING |
| K_FMS_704 | Tổng | Cơ sở | PENDING |
| K_FMS_705 | Cổ phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_706 | Tổng | Cơ sở | PENDING |
| K_FMS_707 | Trái phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_708 | Tổng | Cơ sở | PENDING |
| K_FMS_709 | Chứng chỉ quỹ niêm yết | Cơ sở | PENDING |
| K_FMS_710 | Tổng | Cơ sở | PENDING |
| K_FMS_711 | Các loại tài sản khác | Cơ sở | PENDING |
| K_FMS_712 | Tổng | Cơ sở | PENDING |
| K_FMS_713 | Tổng danh mục đầu tư | Cơ sở | PENDING |
| K_FMS_714 | Chứng chỉ tiền gửi | Cơ sở | PENDING |
| K_FMS_715 | Tổng | Cơ sở | PENDING |
| K_FMS_716 | Trái phiếu Chính phủ | Cơ sở | PENDING |
| K_FMS_717 | Tổng | Cơ sở | PENDING |
| K_FMS_718 | Cổ phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_719 | Tổng | Cơ sở | PENDING |
| K_FMS_720 | Trái phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_721 | Tổng | Cơ sở | PENDING |
| K_FMS_722 | Chứng chỉ quỹ niêm yết | Cơ sở | PENDING |
| K_FMS_723 | Tổng | Cơ sở | PENDING |
| K_FMS_724 | Các loại tài sản khác | Cơ sở | PENDING |
| K_FMS_725 | Tổng | Cơ sở | PENDING |
| K_FMS_726 | Tổng danh mục đầu tư | Cơ sở | PENDING |
| K_FMS_727 | Chứng chỉ tiền gửi | Cơ sở | PENDING |
| K_FMS_728 | Tổng | Cơ sở | PENDING |
| K_FMS_729 | Trái phiếu Chính phủ | Cơ sở | PENDING |
| K_FMS_730 | Tổng | Cơ sở | PENDING |
| K_FMS_731 | Cổ phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_732 | Tổng | Cơ sở | PENDING |
| K_FMS_733 | Trái phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_734 | Tổng | Cơ sở | PENDING |
| K_FMS_735 | Chứng chỉ quỹ niêm yết | Cơ sở | PENDING |
| K_FMS_736 | Tổng | Cơ sở | PENDING |
| K_FMS_737 | Các loại tài sản khác | Cơ sở | PENDING |
| K_FMS_738 | Tổng | Cơ sở | PENDING |
| K_FMS_739 | Tổng danh mục đầu tư | Cơ sở | PENDING |
| K_FMS_740 | Chứng chỉ tiền gửi | Cơ sở | PENDING |
| K_FMS_741 | Tổng | Cơ sở | PENDING |
| K_FMS_742 | Trái phiếu Chính phủ | Cơ sở | PENDING |
| K_FMS_743 | Tổng | Cơ sở | PENDING |
| K_FMS_744 | Cổ phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_745 | Tổng | Cơ sở | PENDING |
| K_FMS_746 | Trái phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_747 | Tổng | Cơ sở | PENDING |
| K_FMS_748 | Chứng chỉ quỹ niêm yết | Cơ sở | PENDING |
| K_FMS_749 | Tổng | Cơ sở | PENDING |
| K_FMS_750 | Các loại tài sản khác | Cơ sở | PENDING |
| K_FMS_751 | Tổng | Cơ sở | PENDING |
| K_FMS_752 | Tổng danh mục đầu tư | Cơ sở | PENDING |
| K_FMS_753 | Chứng chỉ tiền gửi | Cơ sở | PENDING |
| K_FMS_754 | Tổng | Cơ sở | PENDING |
| K_FMS_755 | Trái phiếu Chính phủ | Cơ sở | PENDING |
| K_FMS_756 | Tổng | Cơ sở | PENDING |
| K_FMS_757 | Cổ phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_758 | Tổng | Cơ sở | PENDING |
| K_FMS_759 | Trái phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_760 | Tổng | Cơ sở | PENDING |
| K_FMS_761 | Chứng chỉ quỹ niêm yết | Cơ sở | PENDING |
| K_FMS_762 | Tổng | Cơ sở | PENDING |
| K_FMS_763 | Các loại tài sản khác | Cơ sở | PENDING |
| K_FMS_764 | Tổng | Cơ sở | PENDING |
| K_FMS_765 | Tổng danh mục đầu tư | Cơ sở | PENDING |
| K_FMS_766 | Chứng chỉ tiền gửi | Cơ sở | PENDING |
| K_FMS_767 | Tổng | Cơ sở | PENDING |
| K_FMS_768 | Trái phiếu Chính phủ | Cơ sở | PENDING |
| K_FMS_769 | Tổng | Cơ sở | PENDING |
| K_FMS_770 | Cổ phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_771 | Tổng | Cơ sở | PENDING |
| K_FMS_772 | Trái phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_773 | Tổng | Cơ sở | PENDING |
| K_FMS_774 | Chứng chỉ quỹ niêm yết | Cơ sở | PENDING |
| K_FMS_775 | Tổng | Cơ sở | PENDING |
| K_FMS_776 | Các loại tài sản khác | Cơ sở | PENDING |
| K_FMS_777 | Tổng | Cơ sở | PENDING |
| K_FMS_778 | Tổng danh mục đầu tư | Cơ sở | PENDING |
| K_FMS_779 | Chứng chỉ tiền gửi | Cơ sở | PENDING |
| K_FMS_780 | Tổng | Cơ sở | PENDING |
| K_FMS_781 | Trái phiếu Chính phủ | Cơ sở | PENDING |
| K_FMS_782 | Tổng | Cơ sở | PENDING |
| K_FMS_783 | Cổ phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_784 | Tổng | Cơ sở | PENDING |
| K_FMS_785 | Trái phiếu niêm yết | Cơ sở | PENDING |
| K_FMS_786 | Tổng | Cơ sở | PENDING |
| K_FMS_787 | Chứng chỉ quỹ niêm yết | Cơ sở | PENDING |
| K_FMS_788 | Tổng | Cơ sở | PENDING |
| K_FMS_789 | Các loại tài sản khác | Cơ sở | PENDING |
| K_FMS_790 | Tổng | Cơ sở | PENDING |
| K_FMS_791 | Tổng danh mục đầu tư | Cơ sở | PENDING |

## Section 3 — Mô hình tổng thể (READY only)

```mermaid
graph TB
    classDef fact fill:#4472C4,color:#fff
    classDef dim fill:#70AD47,color:#fff
    classDef operational fill:#ED7D31,color:#fff

    DIM_DATE(["Calendar Date Dimension"]):::dim

    FACT_DIST(["Fact Fund Distribution Agent Snapshot"]):::fact
    FACT_FRGN(["Fact Foreign Fund Management Organization Unit Snapshot"]):::fact

    OPR_CO_PRF(["Fund Management Company Profile"]):::operational
    OPR_FND_LST(["Fund Management Company Fund List"]):::operational
    OPR_CTR_LST(["Fund Management Company Contract List"]):::operational
    OPR_FUND_PRF(["Investment Fund Profile"]):::operational
    OPR_DIST_AGT_LST(["Investment Fund Distribution Agent List"]):::operational
    OPR_REP_BRD_LST(["Investment Fund Representative Board Member List"]):::operational
    OPR_MGR_LST(["Investment Fund Manager List"]):::operational
    OPR_DIST_PRF(["Fund Distribution Agent Profile"]):::operational
    OPR_DIST_FND_LST(["Fund Distribution Agent Fund List"]):::operational
    OPR_FRGN_PRF(["Foreign Fund Management Organization Unit Profile"]):::operational

    DIM_DATE --> FACT_DIST
    DIM_DATE --> FACT_FRGN

    OPR_FUND_PRF --> OPR_DIST_AGT_LST
    OPR_FUND_PRF --> OPR_REP_BRD_LST
    OPR_FUND_PRF --> OPR_MGR_LST
    OPR_DIST_PRF --> OPR_DIST_FND_LST
```

**Bảng Phân tích (Star Schema):**

| Bảng | Pattern | Grain | KPI | Trạng thái |
|---|---|---|---|---|
| Fact Fund Distribution Agent Snapshot | Periodic Snapshot (Market-Level) | 1 snapshot toàn thị trường × 1 tháng | K_FMS_91a, 92 (Nhóm 17) | READY (partial — 2/5 chỉ tiêu) |
| Fact Foreign Fund Management Organization Unit Snapshot | Periodic Snapshot (Market-Level) | 1 snapshot toàn thị trường × 1 tháng | K_FMS_129a, 129 (Nhóm 24) | READY (partial — 2/4 chỉ tiêu) |

> **Ghi chú quan trọng:** Các Fact sau đây KHÔNG READY và đã loại khỏi Section 3 (xem Section 2 từng Nhóm để biết chi tiết PENDING): `Fact Fund Management Company Snapshot` (Nhóm 1), `Fact Discretionary Investment Contract Snapshot` (Nhóm 2), `Fact Investment Fund NAV Snapshot` (Nhóm 7-9), `Fact Investment Fund Count Snapshot` (Nhóm 10), `Fact Investment Fund CCQ Snapshot` (Nhóm 11), `Fact Investment Fund NAV per CCQ Snapshot` (Nhóm 12 — Chiều thời gian nguồn `FMS.FUND_REPORT` chưa có Atomic entity, nên toàn bộ measure kể cả VN-Index/Lãi suất LNH đều PENDING theo). Bảng Tác nghiệp `Report Pass-through View` (Tab DATA EXPLORER, STT 28-90) cũng PENDING toàn bộ — BA đánh Dữ liệu động 100% dù Atomic `Report Import Value` đã READY.

**Bảng Tác nghiệp (Denormalized):**

| Bảng | Loại | Grain | KPI | Trạng thái |
|---|---|---|---|---|
| Fund Management Company Profile | Flat chính | 1 CTQLQ × 1 tháng slicer | K_FMS_17, 152 (Nhóm 3) | READY (partial — 2/13 chỉ tiêu) |
| Fund Management Company Fund List | Bảng con drill-down | 1 quỹ × 1 CTQLQ × 1 tháng slicer | K_FMS_164, 165 (Nhóm 4) | READY (partial — 2/3 chỉ tiêu) |
| Fund Management Company Contract List | Bảng con drill-down | 1 Discretionary Investment Account × 1 CTQLQ × 1 tháng slicer | K_FMS_167, 168 (Nhóm 5) | READY (partial — 2/3 chỉ tiêu) |
| Investment Fund Profile | Flat | 1 quỹ × 1 tháng slicer | K_FMS_62a, 62, 64, 63, 190–193 (Nhóm 13) | READY (partial — 8/11 chỉ tiêu) |
| Investment Fund Distribution Agent List | Bảng con drill-down | 1 đại lý phân phối × 1 quỹ | K_FMS_194 (Nhóm 14) | READY |
| Investment Fund Representative Board Member List | Bảng con drill-down | 1 thành viên BĐD × 1 quỹ | K_FMS_195 (Nhóm 15) | READY |
| Investment Fund Manager List | Bảng con drill-down | 1 người điều hành × 1 quỹ | K_FMS_196 (Nhóm 16) | READY |
| Fund Distribution Agent Profile | Flat | 1 ĐLPP × 1 tháng slicer | K_FMS_107a, 107–112 (Nhóm 22) | READY (partial — 7/20 chỉ tiêu) |
| Fund Distribution Agent Fund List | Bảng con drill-down | 1 quỹ × 1 ĐLPP | K_FMS_197 (Nhóm 23) | READY |
| Foreign Fund Management Organization Unit Profile | Flat | 1 CN × 1 tháng slicer | K_FMS_138a, 138, 143, 144 (Nhóm 26) | READY (partial — 4/10 chỉ tiêu) |

**Bảng Dimension:**

*Tất cả Dimension áp dụng SCD Type 4A.*

| Dimension | Mô tả | Grain | Nguồn Atomic chính | Conformed |
|---|---|---|---|---|
| Calendar Date Dimension | Lịch ngày — năm/quý/tháng/ngày lễ phục vụ slicer | 1 ngày | Calendar Date | Có |

> **Ghi chú:** `Fund Management Company Dimension` và `Investment Fund Dimension` đã loại khỏi Section 3 vì không còn Fact nào FK tới — các Fact dùng chung 2 Dimension này (Fact Investment Fund NAV Snapshot, Count Snapshot, CCQ Snapshot) đều PENDING toàn bộ.

---

## Section 4 — Reuse Analysis

| Datamart Entity | datamart_table | reuse_status | Ghi chú |
|---|---|---|---|
| Calendar Date Dimension | cdr_dt_dim | reuse | Conformed Dim toàn hệ thống — dùng chung mọi Fact có chiều thời gian |
| Classification Dimension | cl_dim | reuse | Dùng cho Loại hình quỹ (scheme FMS_FUND_TYPE) ở Nhóm 4, 7, 10-12 khi cần |
| Fund Management Company Profile | fnd_mgt_co_prf | new | Module đầu tiên của FMS — chưa có trong datamart_model.yaml |
| Fund Management Company Fund List | fnd_mgt_co_fnd_lst | new | Bảng con drill-down — Nhóm 4 |
| Fund Management Company Contract List | fnd_mgt_co_ctr_lst | new | Bảng con drill-down — Nhóm 5 |
| Fact Investment Fund NAV per CCQ Snapshot | fct_inv_fnd_nav_per_ccq_snpst | new | Nhóm 7-9, 12 — hiện PENDING toàn bộ (Chiều thời gian nguồn `FMS.FUND_REPORT` chưa có Atomic entity), chưa cần bảng thật, giữ ghi nhận cho khi Atomic sẵn sàng |
| Investment Fund Profile | inv_fnd_prf | new | Module đầu tiên của FMS |
| Investment Fund Distribution Agent List | inv_fnd_dist_agt_lst | new | Bảng con drill-down mới (Nhóm 14) |
| Investment Fund Representative Board Member List | inv_fnd_rep_brd_mbr_lst | new | Bảng con drill-down mới (Nhóm 15) |
| Investment Fund Manager List | inv_fnd_mgr_lst | new | Bảng con drill-down mới (Nhóm 16) |
| Report Pass-through View | rpt_pass_thru_view | new | Tab DATA EXPLORER (STT 28-90) — hiện PENDING toàn bộ (Dữ liệu động 100%), chưa cần bảng thật, giữ ghi nhận cho khi BA xác nhận quy tắc khai thác |
| Fact Fund Distribution Agent Snapshot | fct_fnd_dist_agt_snpst | new | Module đầu tiên — Nhóm 17 |
| Fund Distribution Agent Profile | fnd_dist_agt_prf | new | Module đầu tiên — Nhóm 22 |
| Fund Distribution Agent Fund List | fnd_dist_agt_fnd_lst | new | Bảng con drill-down mới — Nhóm 23 |
| Fact Foreign Fund Management Organization Unit Snapshot | fct_frgn_fnd_mgt_org_unit_snpst | new | Module đầu tiên — Nhóm 24 |
| Foreign Fund Management Organization Unit Profile | frgn_fnd_mgt_org_unit_prf | new | Module đầu tiên — Nhóm 26 |
| Fund Management Company Staff Trade Report | fnd_mgt_co_stf_trd_rpt | new | Nhóm 27 — hiện PENDING toàn bộ, chưa cần bảng thật (giữ ghi nhận cho khi Atomic Securities Trade sẵn sàng ở track chuẩn) |

> `datamart_model.yaml` hiện chưa có entry cho module FMS (module đầu tiên) — toàn bộ bảng mới đánh `new`, chờ user xác nhận trước khi ghi vào registry ở bước `datamart-lld-design`.

---

## Section 5 — Vấn đề mở

| ID | Vấn đề | Giả định hiện tại | KPI liên quan | Trạng thái |
|---|---|---|---|---|
| O_FMS_1 | RPTVALUES lưu dạng cell value (sheet/ô) — mapping report_template_code + row_code cho các chỉ tiêu BC cũ | Áp dụng cho Tab DATA EXPLORER (STT 28-90) — hiện PENDING toàn bộ (Dữ liệu động 100%). Nhóm 1-27 dùng nguồn db trực tiếp (FUNDS, INVES_ACC, FUND_REPORT) hoặc đánh Dữ liệu động/PENDING, không dùng RPTVALUES | K_FMS_78–91 | Open (chỉ áp dụng Data Explorer, PENDING) |
| O_FMS_2 | Mapping Xếp loại và CAMEL từ FMS.RANK | K_FMS_155/156 (Nhóm 3) BA đánh Dữ liệu động dù Atomic Member Rating đã sẵn sàng → PENDING theo gating Loại dữ liệu | K_FMS_155, K_FMS_156 | Open (gating) |
| O_FMS_3 | Vốn điều lệ CTQLQ — xác nhận trường nguồn | K_FMS_157 (Nhóm 3) BA đánh Dữ liệu động → PENDING theo gating | K_FMS_157 | Open (gating) |
| O_FMS_4 | Vốn CSH — mapping chỉ tiêu BCTC cụ thể | BA không cung cấp Bảng nguồn cho Vốn CSH ở cả Nhóm 3 (K_FMS_162) và Nhóm 26 (K_FMS_141) — cần BA bổ sung nguồn trước khi thiết kế | K_FMS_162, K_FMS_141 | Open |
| O_FMS_5 | Grain Contract List — 1 INVESACC = 1 HĐUTDM | Áp dụng cho Nhóm 5 | K_FMS_167–169 | Closed |
| O_FMS_7 | CCQ lưu hành quỹ đóng — nguồn VSDC chưa xác định | Toàn bộ 8 loại hình quỹ (kể cả đóng) dùng cùng nguồn `FMS.FUND_REPORT.TOTAL_CCQ`, nhưng FUND_REPORT chưa có Atomic entity nên PENDING chung, không phân biệt riêng quỹ đóng | K_FMS_55a–55e, 176, 177 (Nhóm 11) | Open |
| O_FMS_11 | Báo cáo GD nhân viên CTQLQ — cross-module FMS × GSGD, sổ lệnh PENDING (VSDC) | Nguồn sổ lệnh là `OrderTrade.Trade_HOSE`/`Trade_HNX` (entity `Securities Trade`). Entity này chỉ có draft ở `DataModel/working/Atomic_LinhLV/` (track out of date, không phải nguồn chuẩn) — toàn bộ 8 chỉ tiêu sổ lệnh PENDING, cần Atomic team thiết kế lại `Securities Trade` trong `DataModel/Atomic/` hoặc `DataModel/working/Atomic/` | K_FMS_198, 72, 73, 74, 75, 76, 199–201 (Nhóm 27) | Open |
| O_FMS_12 | Calendar Date Dimension map từ Atomic `cdr_dt` | Áp dụng cho tất cả KPI dùng chiều thời gian | Tất cả KPI dùng chiều thời gian | Confirmed |
| O_FMS_15 | FMS.FUND_REPORT chưa có Atomic entity — ảnh hưởng diện rộng | Nhiều measure (NAV, phân bổ tài sản, CCQ, NAV/CCQ) ở các Nhóm 1, 3, 7, 8, 9, 10, 11, 12, 13 lấy nguồn trực tiếp từ `FMS.FUND_REPORT` — nhưng bảng này hoàn toàn chưa có LLD Atomic. Đây là gap Atomic lớn nhất ảnh hưởng tới phần lớn Nhóm 1-27, cần Atomic team ưu tiên thiết kế `FMS.FUND_REPORT` (đề xuất tên: Fund NAV/Property Report). Riêng Nhóm 12: vì Chiều thời gian (K_FMS_56a) cũng phụ thuộc `FMS.FUND_REPORT.EXCUTION_DATE`, nên các measure macro-level vốn có Atomic sẵn sàng (VN-Index K_FMS_178, Lãi suất LNH K_FMS_61) vẫn PENDING theo do thiếu Chiều thời gian hợp lệ ở đúng grain — không chỉ các measure NAV/CCQ trực tiếp | K_FMS_3, 32, 35, 39–44, 47–49, 52a–52e, 55a–55e, 56a, 60, 61, 65, 67, 170–175, 176, 177, 178, 179, 180–189 | Open |
| O_FMS_16 | FMS.SECURITIES_REPORT chưa có Atomic entity | Ảnh hưởng Nhóm 3 (Số nhân viên CCHN, AUM, Thị phần, Lợi nhuận) — cần Atomic team thiết kế entity (đề xuất tên: Securities Company Periodic Report) | K_FMS_153, 158, 159, 161 | Open |
| O_FMS_17 | Nhiều KPI ở Nhóm 17-26 (tài khoản GDCK, tài khoản nắm giữ CCQ, giá trị phát hành/mua lại theo Tổ chức/Cá nhân/Nước ngoài) BA đánh Dữ liệu động nhưng để trống hoàn toàn Bảng nguồn/Trường nguồn | Cần làm việc lại với BA để xác định nguồn dữ liệu thực tế trước khi có thể thiết kế Atomic — hiện chưa đủ thông tin để đề xuất tên entity dự kiến | K_FMS_93–106, 114–128, 130–137, 139–142, 145–147 | Open |
| O_FMS_18 | Gap KPI_ID lớn trong dải 1-201 (6,7,8,18,21,22,27,29,31,34,45,46,58,59,69,71,77,113) | Theo quy tắc "không re-number khi rút scope" — giữ nguyên gap, không đánh số lại. K_FMS_6/7/8 dời sang Nhóm 17/24 hoặc bị xóa (K_FMS_8 — Quỹ hưu trí, BA không còn yêu cầu) | — | Confirmed (không cần xử lý thêm) |

---
