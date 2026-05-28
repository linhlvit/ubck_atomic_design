## 3.2.1 Luồng đồng bộ dữ liệu cho nhóm báo cáo Quản lý quỹ

### 3.2.1.1 Thông tin chung luồng đồng bộ

- tên job:
- nguồn dữ liệu (hệ thống nguồn): FMS, ECAT, QLRR, GSGD
- cách thức truy xuất đồng bộ dữ liệu:
- tần suất đồng bộ dữ liệu:
- dung lượng dữ liệu sẽ thực hiện đồng bộ:
- thời gian lưu trữ dữ liệu:
- thư mục lưu trữ dữ liệu trên kho dữ liệu:

### 3.2.1.2 Luồng nghiệp vụ

#### 3.2.1.2.1 Nhóm thông tin Thống kê thị trường toàn phần

```mermaid
flowchart LR
  subgraph Staging
    FMS_SECURITIES["FMS.SECURITIES"]
    FMS_FUNDS["FMS.FUNDS"]
    FMS_FORBRCH["FMS.FORBRCH"]
    FMS_AGENCIES["FMS.AGENCIES"]
    FMS_RPTVALUES["FMS.RPTVALUES"]
    ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
  end
  subgraph Atomic
    Fund_Management_Company
    Investment_Fund
    Foreign_Fund_Management_Organization_Unit
    Fund_Distribution_Agent
    Report_Import_Value
    Calendar_Date
  end
  subgraph Datamart
    fct_fnd_mgt_co_snpst
    cdr_dt_dim
  end
  FMS_SECURITIES --> Fund_Management_Company
  FMS_FUNDS --> Investment_Fund
  FMS_FORBRCH --> Foreign_Fund_Management_Organization_Unit
  FMS_AGENCIES --> Fund_Distribution_Agent
  FMS_RPTVALUES --> Report_Import_Value
  ECAT_ECAT_29_HolidayInfo --> Calendar_Date
  Fund_Management_Company --> fct_fnd_mgt_co_snpst
  Investment_Fund --> fct_fnd_mgt_co_snpst
  Foreign_Fund_Management_Organization_Unit --> fct_fnd_mgt_co_snpst
  Fund_Distribution_Agent --> fct_fnd_mgt_co_snpst
  Report_Import_Value --> fct_fnd_mgt_co_snpst
  Calendar_Date --> cdr_dt_dim
  cdr_dt_dim --> fct_fnd_mgt_co_snpst
```

**Mục đích:** Cung cấp bảng sự kiện tổng hợp thống kê toàn thị trường quản lý quỹ theo tháng, phục vụ Tab TỔNG QUAN CTQLQ — Nhóm 1 với các chỉ tiêu đếm số lượng công ty, quỹ, đại lý và tổng hợp AUM toàn thị trường.

**Mô tả luồng Staging → Atomic:**

- **Fund Management Company:** Bảng lưu thông tin công ty quản lý quỹ lấy thông tin từ bảng FMS.SECURITIES
- **Investment Fund:** Bảng lưu thông tin quỹ đầu tư lấy thông tin từ bảng FMS.FUNDS
- **Foreign Fund Management Organization Unit:** Bảng lưu thông tin văn phòng đại diện và chi nhánh công ty quản lý quỹ nước ngoài tại Việt Nam lấy thông tin từ bảng FMS.FORBRCH
- **Fund Distribution Agent:** Bảng lưu thông tin đại lý phân phối chứng chỉ quỹ lấy thông tin từ bảng FMS.AGENCIES
- **Report Import Value:** Bảng lưu giá trị các chỉ tiêu báo cáo định kỳ lấy thông tin từ bảng FMS.RPTVALUES
- **Calendar Date:** Bảng lưu thông tin lịch ngày lấy thông tin từ bảng ECAT.ECAT_29_HolidayInfo

**Mô tả luồng Atomic → Datamart:**

- **fct_fnd_mgt_co_snpst:** Bảng sự kiện tổng hợp thống kê toàn thị trường quản lý quỹ theo tháng — đếm số công ty, quỹ, văn phòng đại diện, chi nhánh, đại lý và tổng hợp AUM từ báo cáo
- **cdr_dt_dim:** Bảng lưu thông tin thời gian phục vụ slicer tháng/năm trên dashboard

---

#### 3.2.1.2.2 Nhóm thông tin Số liệu hợp đồng ủy thác danh mục per CTQLQ

```mermaid
flowchart LR
  subgraph Staging
    FMS_RPTMEMBER["FMS.RPTMEMBER"]
    FMS_RPTVALUES["FMS.RPTVALUES"]
    FMS_SECURITIES["FMS.SECURITIES"]
    ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
  end
  subgraph Atomic
    Member_Periodic_Report
    Report_Import_Value
    Fund_Management_Company
    Calendar_Date
  end
  subgraph Datamart
    fct_dscr_ivsm_ctr_snpst
    fnd_mgt_co_dim
    cdr_dt_dim
  end
  FMS_RPTMEMBER --> Member_Periodic_Report
  FMS_RPTVALUES --> Report_Import_Value
  FMS_SECURITIES --> Fund_Management_Company
  ECAT_ECAT_29_HolidayInfo --> Calendar_Date
  Member_Periodic_Report --> fct_dscr_ivsm_ctr_snpst
  Report_Import_Value --> fct_dscr_ivsm_ctr_snpst
  Fund_Management_Company --> fnd_mgt_co_dim
  Calendar_Date --> cdr_dt_dim
  fnd_mgt_co_dim --> fct_dscr_ivsm_ctr_snpst
  cdr_dt_dim --> fct_dscr_ivsm_ctr_snpst
```

**Mục đích:** Cung cấp bảng sự kiện tổng hợp số liệu hợp đồng ủy thác danh mục đầu tư theo từng công ty quản lý quỹ và kỳ báo cáo, phục vụ Tab TỔNG QUAN CTQLQ — Nhóm 2 với các chỉ tiêu số lượng và giá trị thị trường hợp đồng UTDM.

**Mô tả luồng Staging → Atomic:**

- **Member Periodic Report:** Bảng lưu thông tin kỳ báo cáo định kỳ của thành viên lấy thông tin từ bảng FMS.RPTMEMBER
- **Report Import Value:** Bảng lưu giá trị các chỉ tiêu báo cáo định kỳ lấy thông tin từ bảng FMS.RPTVALUES
- **Fund Management Company:** Bảng lưu thông tin công ty quản lý quỹ lấy thông tin từ bảng FMS.SECURITIES
- **Calendar Date:** Bảng lưu thông tin lịch ngày lấy thông tin từ bảng ECAT.ECAT_29_HolidayInfo

**Mô tả luồng Atomic → Datamart:**

- **fct_dscr_ivsm_ctr_snpst:** Bảng sự kiện tổng hợp thông tin số lượng và giá trị thị trường hợp đồng ủy thác danh mục đầu tư theo từng công ty quản lý quỹ và kỳ báo cáo
- **fnd_mgt_co_dim:** Bảng lưu thông tin công ty quản lý quỹ phục vụ tra cứu và lọc theo chiều CTQLQ
- **cdr_dt_dim:** Bảng lưu thông tin thời gian phục vụ slicer tháng/năm trên dashboard

---

#### 3.2.1.2.3 Nhóm thông tin Hồ sơ công ty quản lý quỹ

```mermaid
flowchart LR
  subgraph Staging
    FMS_SECURITIES["FMS.SECURITIES"]
    FMS_FUNDS["FMS.FUNDS"]
    FMS_RPTVALUES["FMS.RPTVALUES"]
    FMS_RANK["FMS.RANK"]
    FMS_RATINGPD["FMS.RATINGPD"]
    FMS_INVESACC["FMS.INVESACC"]
    FMS_INVES["FMS.INVES"]
  end
  subgraph Atomic
    Fund_Management_Company
    Investment_Fund
    Report_Import_Value
    Member_Rating
    Member_Rating_Period
    Discretionary_Investment_Account
    Discretionary_Investment_Investor
  end
  subgraph Datamart
    fnd_mgt_co_prfl
    fnd_mgt_co_fnd_lst
    fnd_mgt_co_ctr_lst
  end
  FMS_SECURITIES --> Fund_Management_Company
  FMS_FUNDS --> Investment_Fund
  FMS_RPTVALUES --> Report_Import_Value
  FMS_RANK --> Member_Rating
  FMS_RATINGPD --> Member_Rating_Period
  FMS_INVESACC --> Discretionary_Investment_Account
  FMS_INVES --> Discretionary_Investment_Investor
  Fund_Management_Company --> fnd_mgt_co_prfl
  Report_Import_Value --> fnd_mgt_co_prfl
  Member_Rating --> fnd_mgt_co_prfl
  Member_Rating_Period --> fnd_mgt_co_prfl
  Fund_Management_Company --> fnd_mgt_co_fnd_lst
  Investment_Fund --> fnd_mgt_co_fnd_lst
  Report_Import_Value --> fnd_mgt_co_fnd_lst
  Fund_Management_Company --> fnd_mgt_co_ctr_lst
  Discretionary_Investment_Account --> fnd_mgt_co_ctr_lst
  Discretionary_Investment_Investor --> fnd_mgt_co_ctr_lst
```

**Mục đích:** Cung cấp bảng tác nghiệp hồ sơ tổng hợp từng công ty quản lý quỹ cùng hai bảng con phục vụ drill-down danh sách quỹ và hợp đồng UTDM, phục vụ Tab TỔNG QUAN CTQLQ — Nhóm 3.

**Mô tả luồng Staging → Atomic:**

- **Fund Management Company:** Bảng lưu thông tin công ty quản lý quỹ lấy thông tin từ bảng FMS.SECURITIES
- **Investment Fund:** Bảng lưu thông tin quỹ đầu tư lấy thông tin từ bảng FMS.FUNDS
- **Report Import Value:** Bảng lưu giá trị các chỉ tiêu báo cáo định kỳ lấy thông tin từ bảng FMS.RPTVALUES
- **Member Rating:** Bảng lưu kết quả xếp loại CAMEL của thành viên lấy thông tin từ bảng FMS.RANK
- **Member Rating Period:** Bảng lưu thông tin kỳ đánh giá xếp loại lấy thông tin từ bảng FMS.RATINGPD
- **Discretionary Investment Account:** Bảng lưu thông tin tài khoản hợp đồng ủy thác danh mục đầu tư lấy thông tin từ bảng FMS.INVESACC
- **Discretionary Investment Investor:** Bảng lưu thông tin nhà đầu tư ủy thác danh mục lấy thông tin từ bảng FMS.INVES

**Mô tả luồng Atomic → Datamart:**

- **fnd_mgt_co_prfl:** Bảng tác nghiệp lưu danh sách công ty quản lý quỹ ở trạng thái mới nhất với đầy đủ thông tin hồ sơ, AUM, xếp loại CAMEL và số liệu tổng hợp
- **fnd_mgt_co_fnd_lst:** Bảng tác nghiệp lưu danh sách quỹ đầu tư theo từng công ty quản lý quỹ phục vụ popup drill-down
- **fnd_mgt_co_ctr_lst:** Bảng tác nghiệp lưu danh sách hợp đồng ủy thác danh mục đầu tư theo từng công ty quản lý quỹ phục vụ popup drill-down

---

#### 3.2.1.2.4 Nhóm thông tin NAV quỹ theo kỳ và chỉ tiêu kinh tế vĩ mô

```mermaid
flowchart LR
  subgraph Staging_FMS["Staging (FMS)"]
    FMS_RPTMEMBER["FMS.RPTMEMBER"]
    FMS_RPTVALUES["FMS.RPTVALUES"]
    FMS_FUNDS["FMS.FUNDS"]
    FMS_SECURITIES["FMS.SECURITIES"]
  end
  subgraph Staging_QLRR["Staging (QLRR)"]
    QLRR_risk_indicator["QLRR.risk_indicator"]
    QLRR_risk_indicator_value["QLRR.risk_indicator_value"]
  end
  subgraph Staging_ECAT["Staging (ECAT)"]
    ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
  end
  subgraph Atomic
    Member_Periodic_Report
    Report_Import_Value
    Investment_Fund
    Fund_Management_Company
    Risk_Indicator
    Risk_Indicator_Value
    Calendar_Date
  end
  subgraph Datamart
    fct_ivsm_fnd_nav_snpst
    ivsm_fnd_dim
    fnd_mgt_co_dim
    cdr_dt_dim
  end
  FMS_RPTMEMBER --> Member_Periodic_Report
  FMS_RPTVALUES --> Report_Import_Value
  FMS_FUNDS --> Investment_Fund
  FMS_SECURITIES --> Fund_Management_Company
  QLRR_risk_indicator --> Risk_Indicator
  QLRR_risk_indicator_value --> Risk_Indicator_Value
  ECAT_ECAT_29_HolidayInfo --> Calendar_Date
  Member_Periodic_Report --> fct_ivsm_fnd_nav_snpst
  Report_Import_Value --> fct_ivsm_fnd_nav_snpst
  Risk_Indicator_Value --> fct_ivsm_fnd_nav_snpst
  Investment_Fund --> ivsm_fnd_dim
  Fund_Management_Company --> fnd_mgt_co_dim
  Calendar_Date --> cdr_dt_dim
  ivsm_fnd_dim --> fct_ivsm_fnd_nav_snpst
  fnd_mgt_co_dim --> fct_ivsm_fnd_nav_snpst
  cdr_dt_dim --> fct_ivsm_fnd_nav_snpst
```

**Mục đích:** Cung cấp bảng sự kiện NAV quỹ và phân bổ tài sản theo từng quỹ và kỳ báo cáo, kết hợp chỉ tiêu kinh tế vĩ mô GDP, VN-Index, lãi suất liên ngân hàng từ cross-module QLRR, phục vụ Tab QUỸ ĐẦU TƯ — Nhóm 4, 5, 6, 9.

**Mô tả luồng Staging → Atomic:**

- **Member Periodic Report:** Bảng lưu thông tin kỳ báo cáo định kỳ của thành viên lấy thông tin từ bảng FMS.RPTMEMBER
- **Report Import Value:** Bảng lưu giá trị các chỉ tiêu báo cáo định kỳ lấy thông tin từ bảng FMS.RPTVALUES
- **Investment Fund:** Bảng lưu thông tin quỹ đầu tư lấy thông tin từ bảng FMS.FUNDS
- **Fund Management Company:** Bảng lưu thông tin công ty quản lý quỹ lấy thông tin từ bảng FMS.SECURITIES
- **Risk Indicator:** Bảng lưu thông tin danh mục chỉ tiêu rủi ro lấy thông tin từ bảng QLRR.risk_indicator
- **Risk Indicator Value:** Bảng lưu giá trị các chỉ tiêu rủi ro và kinh tế vĩ mô (GDP, VN-Index, lãi suất liên ngân hàng) lấy thông tin từ bảng QLRR.risk_indicator_value
- **Calendar Date:** Bảng lưu thông tin lịch ngày lấy thông tin từ bảng ECAT.ECAT_29_HolidayInfo

**Mô tả luồng Atomic → Datamart:**

- **fct_ivsm_fnd_nav_snpst:** Bảng sự kiện tổng hợp thông tin NAV, phân bổ tài sản của từng quỹ đầu tư theo kỳ báo cáo, kết hợp chỉ tiêu GDP, VN-Index và lãi suất liên ngân hàng qua đêm từ cross-module QLRR
- **ivsm_fnd_dim:** Bảng lưu thông tin quỹ đầu tư phục vụ tra cứu và lọc theo chiều quỹ
- **fnd_mgt_co_dim:** Bảng lưu thông tin công ty quản lý quỹ phục vụ tra cứu và lọc theo chiều CTQLQ
- **cdr_dt_dim:** Bảng lưu thông tin thời gian phục vụ slicer tháng/năm trên dashboard

---

#### 3.2.1.2.5 Nhóm thông tin Số lượng quỹ theo loại hình

```mermaid
flowchart LR
  subgraph Staging
    FMS_FUNDS["FMS.FUNDS"]
    ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
  end
  subgraph Atomic
    Investment_Fund
    Calendar_Date
  end
  subgraph Datamart
    fct_ivsm_fnd_cnt_snpst
    cdr_dt_dim
  end
  FMS_FUNDS --> Investment_Fund
  ECAT_ECAT_29_HolidayInfo --> Calendar_Date
  Investment_Fund --> fct_ivsm_fnd_cnt_snpst
  Calendar_Date --> cdr_dt_dim
  cdr_dt_dim --> fct_ivsm_fnd_cnt_snpst
```

**Mục đích:** Cung cấp bảng sự kiện đếm số lượng quỹ đầu tư theo từng loại hình theo năm, phục vụ Tab QUỸ ĐẦU TƯ — Nhóm 7 với biểu đồ xu hướng số lượng quỹ qua các năm.

**Mô tả luồng Staging → Atomic:**

- **Investment Fund:** Bảng lưu thông tin quỹ đầu tư lấy thông tin từ bảng FMS.FUNDS
- **Calendar Date:** Bảng lưu thông tin lịch ngày lấy thông tin từ bảng ECAT.ECAT_29_HolidayInfo

**Mô tả luồng Atomic → Datamart:**

- **fct_ivsm_fnd_cnt_snpst:** Bảng sự kiện tổng hợp số lượng quỹ đầu tư theo từng loại hình (quỹ mở, ETF, đóng, thành viên, bất động sản, TTTTT, trái phiếu hạ tầng, hưu trí) theo năm
- **cdr_dt_dim:** Bảng lưu thông tin thời gian phục vụ slicer năm trên dashboard

---

#### 3.2.1.2.6 Nhóm thông tin Số lượng chứng chỉ quỹ lưu hành

```mermaid
flowchart LR
  subgraph Staging
    FMS_FUNDS["FMS.FUNDS"]
    FMS_TRANSFERMBF["FMS.TRANSFERMBF"]
    ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
  end
  subgraph Atomic
    Investment_Fund
    Investment_Fund_Certificate_Transfer
    Calendar_Date
  end
  subgraph Datamart
    fct_ivsm_fnd_ccq_snpst
    ivsm_fnd_dim
    cdr_dt_dim
  end
  FMS_FUNDS --> Investment_Fund
  FMS_TRANSFERMBF --> Investment_Fund_Certificate_Transfer
  ECAT_ECAT_29_HolidayInfo --> Calendar_Date
  Investment_Fund --> fct_ivsm_fnd_ccq_snpst
  Investment_Fund_Certificate_Transfer --> fct_ivsm_fnd_ccq_snpst
  Investment_Fund --> ivsm_fnd_dim
  Calendar_Date --> cdr_dt_dim
  ivsm_fnd_dim --> fct_ivsm_fnd_ccq_snpst
  cdr_dt_dim --> fct_ivsm_fnd_ccq_snpst
```

**Mục đích:** Cung cấp bảng sự kiện số lượng chứng chỉ quỹ lưu hành theo từng quỹ và tháng snapshot, phục vụ Tab QUỸ ĐẦU TƯ — Nhóm 8 với biểu đồ tăng trưởng CCQ lưu hành theo loại hình quỹ.

**Mô tả luồng Staging → Atomic:**

- **Investment Fund:** Bảng lưu thông tin quỹ đầu tư lấy thông tin từ bảng FMS.FUNDS
- **Investment Fund Certificate Transfer:** Bảng lưu thông tin giao dịch chuyển nhượng chứng chỉ quỹ (mua/bán) lấy thông tin từ bảng FMS.TRANSFERMBF
- **Calendar Date:** Bảng lưu thông tin lịch ngày lấy thông tin từ bảng ECAT.ECAT_29_HolidayInfo

**Mô tả luồng Atomic → Datamart:**

- **fct_ivsm_fnd_ccq_snpst:** Bảng sự kiện tổng hợp số lượng chứng chỉ quỹ lưu hành per quỹ theo tháng snapshot, tính bằng tổng mua trừ tổng bán từ lịch sử giao dịch chuyển nhượng
- **ivsm_fnd_dim:** Bảng lưu thông tin quỹ đầu tư phục vụ tra cứu và lọc theo chiều quỹ
- **cdr_dt_dim:** Bảng lưu thông tin thời gian phục vụ slicer tháng/năm trên dashboard

---

#### 3.2.1.2.7 Nhóm thông tin Hồ sơ quỹ đầu tư

```mermaid
flowchart LR
  subgraph Staging
    FMS_FUNDS["FMS.FUNDS"]
    FMS_SECURITIES["FMS.SECURITIES"]
    FMS_RPTMEMBER["FMS.RPTMEMBER"]
    FMS_RPTVALUES["FMS.RPTVALUES"]
  end
  subgraph Atomic
    Investment_Fund
    Fund_Management_Company
    Member_Periodic_Report
    Report_Import_Value
  end
  subgraph Datamart
    ivsm_fnd_prfl
  end
  FMS_FUNDS --> Investment_Fund
  FMS_SECURITIES --> Fund_Management_Company
  FMS_RPTMEMBER --> Member_Periodic_Report
  FMS_RPTVALUES --> Report_Import_Value
  Investment_Fund --> ivsm_fnd_prfl
  Fund_Management_Company --> ivsm_fnd_prfl
  Member_Periodic_Report --> ivsm_fnd_prfl
  Report_Import_Value --> ivsm_fnd_prfl
```

**Mục đích:** Cung cấp bảng tác nghiệp hồ sơ tổng hợp từng quỹ đầu tư với thông tin NAV, lợi nhuận YTD và số lượng CCQ lưu hành, phục vụ Tab QUỸ ĐẦU TƯ — Nhóm 10 với danh sách các quỹ đầu tư.

**Mô tả luồng Staging → Atomic:**

- **Investment Fund:** Bảng lưu thông tin quỹ đầu tư lấy thông tin từ bảng FMS.FUNDS
- **Fund Management Company:** Bảng lưu thông tin công ty quản lý quỹ lấy thông tin từ bảng FMS.SECURITIES
- **Member Periodic Report:** Bảng lưu thông tin kỳ báo cáo định kỳ của thành viên lấy thông tin từ bảng FMS.RPTMEMBER
- **Report Import Value:** Bảng lưu giá trị các chỉ tiêu báo cáo định kỳ lấy thông tin từ bảng FMS.RPTVALUES

**Mô tả luồng Atomic → Datamart:**

- **ivsm_fnd_prfl:** Bảng tác nghiệp lưu danh sách quỹ đầu tư ở trạng thái mới nhất với thông tin NAV, lợi nhuận YTD và số lượng CCQ lưu hành tại tháng slicer

---

#### 3.2.1.2.8 Nhóm thông tin Pass-through báo cáo định kỳ

```mermaid
flowchart LR
  subgraph Staging
    FMS_RPTVALUES["FMS.RPTVALUES"]
    FMS_RPTMEMBER["FMS.RPTMEMBER"]
    FMS_SECURITIES["FMS.SECURITIES"]
    FMS_FUNDS["FMS.FUNDS"]
  end
  subgraph Atomic
    Report_Import_Value
    Member_Periodic_Report
    Fund_Management_Company
    Investment_Fund
  end
  subgraph Datamart
    rpt_pass_thru_view
  end
  FMS_RPTVALUES --> Report_Import_Value
  FMS_RPTMEMBER --> Member_Periodic_Report
  FMS_SECURITIES --> Fund_Management_Company
  FMS_FUNDS --> Investment_Fund
  Report_Import_Value --> rpt_pass_thru_view
  Member_Periodic_Report --> rpt_pass_thru_view
  Fund_Management_Company --> rpt_pass_thru_view
  Investment_Fund --> rpt_pass_thru_view
```

**Mục đích:** Cung cấp bảng tác nghiệp pass-through toàn bộ nội dung báo cáo định kỳ từ hệ thống FMS, phục vụ Tab DATA EXPLORER — Nhóm 12 đến 16 bao gồm BCTC, báo cáo ATTC, QLĐMDT, báo cáo định kỳ CTQLQ và báo cáo theo loại quỹ.

**Mô tả luồng Staging → Atomic:**

- **Report Import Value:** Bảng lưu giá trị các chỉ tiêu báo cáo định kỳ lấy thông tin từ bảng FMS.RPTVALUES
- **Member Periodic Report:** Bảng lưu thông tin kỳ báo cáo định kỳ của thành viên lấy thông tin từ bảng FMS.RPTMEMBER
- **Fund Management Company:** Bảng lưu thông tin công ty quản lý quỹ lấy thông tin từ bảng FMS.SECURITIES
- **Investment Fund:** Bảng lưu thông tin quỹ đầu tư lấy thông tin từ bảng FMS.FUNDS

**Mô tả luồng Atomic → Datamart:**

- **rpt_pass_thru_view:** Bảng tác nghiệp lưu toàn bộ dữ liệu báo cáo dạng flat theo từng công ty quản lý quỹ hoặc quỹ, biểu mẫu báo cáo, kỳ báo cáo và dòng chỉ tiêu — phục vụ 63 tab pass-through và 19 tab phức tạp trên DataExplorer

---

#### 3.2.1.2.9 Nhóm thông tin Báo cáo giao dịch nhân viên công ty quản lý quỹ

```mermaid
flowchart LR
  subgraph Staging_FMS["Staging (FMS)"]
    FMS_TLProfiles["FMS.TLProfiles"]
    FMS_SECURITIES["FMS.SECURITIES"]
  end
  subgraph Staging_GSGD["Staging (GSGD)"]
    GSGD_investor_account["GSGD.investor_account"]
  end
  subgraph Atomic
    Fund_Management_Company_Key_Person
    Involved_Party_Alternative_Identification
    Fund_Management_Company
    Investor_Trading_Account
  end
  subgraph Datamart
    fnd_mgt_co_stf_trd_rpt
  end
  FMS_TLProfiles --> Fund_Management_Company_Key_Person
  FMS_TLProfiles --> Involved_Party_Alternative_Identification
  FMS_SECURITIES --> Fund_Management_Company
  GSGD_investor_account --> Investor_Trading_Account
  Fund_Management_Company_Key_Person --> fnd_mgt_co_stf_trd_rpt
  Involved_Party_Alternative_Identification --> fnd_mgt_co_stf_trd_rpt
  Fund_Management_Company --> fnd_mgt_co_stf_trd_rpt
  Investor_Trading_Account --> fnd_mgt_co_stf_trd_rpt
```

**Mục đích:** Cung cấp bảng tác nghiệp báo cáo giao dịch chứng khoán của nhân viên công ty quản lý quỹ thông qua cross-module FMS và GSGD, phục vụ Tab BÁO CÁO / CÔNG TY QLQ — Nhóm 11.

**Mô tả luồng Staging → Atomic:**

- **Fund Management Company Key Person:** Bảng lưu thông tin nhân viên chủ chốt của công ty quản lý quỹ lấy thông tin từ bảng FMS.TLProfiles
- **Involved Party Alternative Identification:** Bảng lưu thông tin định danh thay thế (CCCD/Hộ chiếu) của bên liên quan lấy thông tin từ bảng FMS.TLProfiles, kết hợp thông tin tài khoản giao dịch chứng khoán từ các bảng FMS.SECURITIES, GSGD.investor_account
- **Fund Management Company:** Bảng lưu thông tin công ty quản lý quỹ lấy thông tin từ bảng FMS.SECURITIES
- **Investor Trading Account:** Bảng lưu thông tin tài khoản giao dịch chứng khoán của nhà đầu tư lấy thông tin từ bảng GSGD.investor_account

**Mô tả luồng Atomic → Datamart:**

- **fnd_mgt_co_stf_trd_rpt:** Bảng tác nghiệp lưu danh sách nhân viên công ty quản lý quỹ ở trạng thái mới nhất kèm thông tin tài khoản giao dịch chứng khoán, phục vụ giám sát giao dịch chứng khoán của nhân viên CTQLQ