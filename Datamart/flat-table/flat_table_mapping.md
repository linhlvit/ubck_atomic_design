# Flat Table Mapping — Toàn bộ phân hệ

_Auto-generated: 2026-05-27 09:25:59_

Tài liệu mô tả từng bảng flat: nguồn fact/dim, quan hệ FK → PK, và các nhóm KPI sử dụng.

## Mục lục phân hệ

- [FMS](#fms)
- [GSDC](#gsdc)
- [GSTT](#gstt)
- [NDTNN](#ndtnn)
- [NHNCK](#nhnck)
- [QLCB](#qlcb)
- [QLKD](#qlkd)
- [TT](#tt)

---

## FMS

**11 bảng flat** · **966 KPI unique**

---

### `datamart.fms_fact_fund_management_company_snapshot_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Fund Management Company Snapshot |
| **Bảng fact/operational** | `datamart.fms_fact_fund_management_company_snapshot` |
| **PK** | `—` |
| **Số dim join** | 1 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.fms_calendar_date_dimension` | `snapshot_date_dimension_id` | `calendar_date_dimension_id` | ✗ |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 1 — Thống kê chung | 9 |
| Nhóm 2 — Số liệu hợp đồng ủy thác danh mục | 4 |
| Nhóm 3 — Danh sách các Công ty quản lý quỹ | 1 |
| Nhóm 4 — Biểu đồ Tổng NAV Quỹ và Tỷ lệ NAV/GDP | 3 |
| Nhóm 5 — Biểu đồ Phân bổ tài sản của Quỹ đầu tư | 6 |
| Nhóm 6 — Sự biến động về NAV của các Quỹ ĐTCK | 2 |
| Nhóm 9 — Tỷ lệ tăng trưởng NAV/CCQ so với VN-Index và Lãi suất LNH | 4 |
| Nhóm 11 — Báo cáo giao dịch nhân viên CTQLQ | 5 |
| Nhóm — Thống kê chung | 7 |
| Nhóm — Tổng số tài khoản giao dịch chứng chỉ chỉ quỹ | 3 |
| Nhóm — Số tài khoản nắm giữ chứng chỉ chỉ quỹ | 3 |
| Nhóm — Giá trị chứng chỉ quỹ | 3 |
| Nhóm — Giao dịch thông qua Đại lý phân phối | 2 |
| Nhóm — Danh sách Đại lý phân phối | 22 |
| Nhóm — Số liệu hợp đồng uỷ thác danh mục | 6 |
| Nhóm — Danh sách các Chi nhánh CTQLQ nước ngoài tại Việt Nam | 10 |
| Nhóm — BCTC-Bảng cân đối kế toán | 110 |
| Nhóm — BCTC-Báo cáo kết quả hoạt động kinh doanh | 17 |
| Nhóm — BCTC-BCLCTT_TrucTiep | 30 |
| Nhóm — BCTC-BCLCTT_GianTiep | 40 |
| Nhóm — BCTC-BCTinhHinhBienDongVCSH | 11 |
| Nhóm — Báo cáo về tình hình quản lý danh mục đầu tư | 436 |
| Nhóm — Báo cáo tỷ lệ an toàn tài chính | 156 |

---

### `datamart.fms_fact_discretionary_investment_contract_snapshot_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Discretionary Investment Contract Snapshot |
| **Bảng fact/operational** | `datamart.fms_fact_discretionary_investment_contract_snapshot` |
| **PK** | `—` |
| **Số dim join** | 2 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.fms_calendar_date_dimension` | `report_date_dimension_id` | `calendar_date_dimension_id` | ✗ |
| Fund Management Company Dimension | `datamart.fms_fund_management_company_dimension` | `fund_management_company_dimension_id` | `fund_management_company_dimension_id` | ✗ |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 2 — Số liệu hợp đồng ủy thác danh mục | 6 |
| Nhóm 14 — DataExplorer Báo cáo QLĐMDT | 2 |

---

### `datamart.fms_fact_investment_fund_nav_snapshot_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Investment Fund NAV Snapshot |
| **Bảng fact/operational** | `datamart.fms_fact_investment_fund_nav_snapshot` |
| **PK** | `—` |
| **Số dim join** | 3 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.fms_calendar_date_dimension` | `report_date_dimension_id` | `calendar_date_dimension_id` | ✗ |
| Investment Fund Dimension | `datamart.fms_investment_fund_dimension` | `investment_fund_dimension_id` | `investment_fund_dimension_id` | ✗ |
| Fund Management Company Dimension | `datamart.fms_fund_management_company_dimension` | `fund_management_company_dimension_id` | `fund_management_company_dimension_id` | ✗ |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 4 — Biểu đồ Tổng NAV Quỹ và Tỷ lệ NAV/GDP | 3 |
| Nhóm 5 — Biểu đồ Phân bổ tài sản của Quỹ đầu tư | 8 |
| Nhóm 6 — Sự biến động về NAV của các Quỹ ĐTCK | 1 |
| Nhóm 9 — Tỷ lệ tăng trưởng NAV/CCQ so với VN-Index và Lãi suất LNH | 2 |

---

### `datamart.fms_fact_investment_fund_count_snapshot_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Investment Fund Count Snapshot |
| **Bảng fact/operational** | `datamart.fms_fact_investment_fund_count_snapshot` |
| **PK** | `—` |
| **Số dim join** | 1 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.fms_calendar_date_dimension` | `snapshot_date_dimension_id` | `calendar_date_dimension_id` | ✗ |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 7 — Số lượng quỹ đầu tư chứng khoán | 7 |

---

### `datamart.fms_fact_investment_fund_ccq_snapshot_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Investment Fund CCQ Snapshot |
| **Bảng fact/operational** | `datamart.fms_fact_investment_fund_ccq_snapshot` |
| **PK** | `—` |
| **Số dim join** | 2 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.fms_calendar_date_dimension` | `report_date_dimension_id` | `calendar_date_dimension_id` | ✗ |
| Investment Fund Dimension | `datamart.fms_investment_fund_dimension` | `investment_fund_dimension_id` | `investment_fund_dimension_id` | ✗ |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 8 — Tăng trưởng số lượng CCQ lưu hành | 10 |
| Nhóm 10 — Danh sách các quỹ đầu tư | 1 |

---

### `datamart.fms_fund_management_company_profile_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Fund Management Company Profile |
| **Bảng fact/operational** | `datamart.fms_fund_management_company_profile` |
| **PK** | `fund_management_company_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 3 — Danh sách các Công ty quản lý quỹ | 10 |

---

### `datamart.fms_fund_management_company_fund_list_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Fund Management Company Fund List |
| **Bảng fact/operational** | `datamart.fms_fund_management_company_fund_list` |
| **PK** | `fund_management_company_id, investment_fund_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 3 — Danh sách các Công ty quản lý quỹ | 2 |

---

### `datamart.fms_fund_management_company_contract_list_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Fund Management Company Contract List |
| **Bảng fact/operational** | `datamart.fms_fund_management_company_contract_list` |
| **PK** | `discretionary_investment_account_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 3 — Danh sách các Công ty quản lý quỹ | 2 |

---

### `datamart.fms_investment_fund_profile_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Investment Fund Profile |
| **Bảng fact/operational** | `datamart.fms_investment_fund_profile` |
| **PK** | `investment_fund_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 10 — Danh sách các quỹ đầu tư | 5 |

---

### `datamart.fms_report_passthrough_view_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Report Pass-through View |
| **Bảng fact/operational** | `datamart.fms_report_passthrough_view` |
| **PK** | `fund_management_company_id, investment_fund_id, report_template_code, reporting_period_code, row_code` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 12 — DataExplorer BCTC | 5 |
| Nhóm 13 — DataExplorer Báo cáo tỷ lệ ATTC | 2 |
| Nhóm 14 — DataExplorer Báo cáo QLĐMDT | 1 |
| Nhóm 15 — DataExplorer Báo cáo định kỳ CTQLQ | 1 |
| Nhóm 16 — DataExplorer Báo cáo theo loại quỹ và đơn vị đặc thù | 3 |

---

### `datamart.fms_fund_management_company_staff_trade_report_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Fund Management Company Staff Trade Report |
| **Bảng fact/operational** | `datamart.fms_fund_management_company_staff_trade_report` |
| **PK** | `fund_management_company_id, fund_management_company_key_person_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 11 — Báo cáo giao dịch nhân viên CTQLQ | 5 |

---

## GSDC

**2 bảng flat** · **1213 KPI unique**

---

### `datamart.gsdc_fact_public_company_financial_summary_snapshot_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Public Company Financial Summary Snapshot |
| **Bảng fact/operational** | `datamart.gsdc_fact_public_company_financial_summary_snapshot` |
| **PK** | `—` |
| **Số dim join** | 1 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Public Company Dimension | `datamart.gsdc_public_company_dimension` | `public_company_dimension_id` | `public_company_dimension_id` | ✗ |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 1 - Tổng hợp chấm điểm phân loại CTDC | 7 |
| Nhóm 2 - Top CTDC theo chỉ tiêu tuân thủ | 14 |
| Nhóm 3 - Top CTDC theo chỉ tiêu phát hành | 8 |
| Nhóm 4 - Top CTDC theo chỉ tiêu tài chính | 12 |
| Nhóm 5 - Top CTDC theo chỉ tiêu phi tài chính & M-Score | 4 |
| Nhóm 1 - Tổng hợp chấm điểm phân loại CTDC (chiều READY) | 3 |
| Nhóm 6 - Thống kê toàn thị trường theo sàn niêm yết | 5 |
| Nhóm 7 - Tổng hợp chỉ tiêu tài chính toàn thị trường | 40 |
| Nhóm 8 - Tổng hợp CTTC theo ngành (Tổng TS, NPT, VCSH, VĐL) | 9 |
| Nhóm 9 - Tổng hợp CTTC theo ngành (LNST) | 1 |
| Nhóm 10 - Tổng hợp CTTC theo ngành (ROA, ROE, HTK, DT, YTD, Phải thu, Tiền, Nợ/Vốn) | 8 |
| Nhóm 11 - Giám sát tổng hợp — CTDC chưa niêm yết | 2 |
| Nhóm 12 - Giám sát tổng hợp theo sàn HNX — Thống kê niêm yết | 7 |
| Nhóm 13 - Giám sát tổng hợp theo sàn HNX — Tổng hợp CTTC & ngành | 57 |
| Nhóm 14 - Giám sát tổng hợp theo sàn HOSE — Thống kê niêm yết | 7 |
| Nhóm 15 - Giám sát tổng hợp theo sàn HOSE — Tổng hợp CTTC & ngành | 54 |
| Nhóm 16 - Giám sát tổng hợp theo sàn UPCOM — Thống kê niêm yết | 7 |
| Nhóm 17 - Giám sát tổng hợp theo sàn UPCOM — Tổng hợp CTTC & ngành | 64 |
| Nhóm 18 - Giám sát tổng hợp theo sàn OTC — Thống kê niêm yết | 7 |
| Nhóm 19 - Giám sát tổng hợp theo sàn OTC — Tổng hợp CTTC & ngành | 64 |
| Nhóm 39 - Hệ số tài chính cơ bản | 9 |
| Nhóm 33 - Dữ liệu về thông tin niêm yết | 10 |
| Nhóm 40 - BC01.1 Báo cáo vĩ mô theo sàn | 14 |
| Nhóm 41 - BC01.2 Báo cáo vĩ mô theo ngành | 18 |
| Nhóm 42 - BC01.3 Báo cáo vĩ mô đa kỳ (N / N-1 / N-2) | 43 |
| Nhóm 43 - BC22 Tổng hợp tình hình tài chính CTDC theo sàn | 38 |
| Dữ liệu tài chính về doanh nghiệp thông thường chi tiết - Bá | 3 |
| Dữ liệu tài chính doanh nghiệp bảo hiểm chi tiết - Báo cáo l | 6 |
| Dữ liệu tài chính tổ chức tín dụng chi tiết - Báo cáo lưu ch | 4 |

---

### `datamart.gsdc_fact_public_company_financial_report_value_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Public Company Financial Report Value |
| **Bảng fact/operational** | `datamart.gsdc_fact_public_company_financial_report_value` |
| **PK** | `—` |
| **Số dim join** | 2 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Public Company Dimension | `datamart.gsdc_public_company_dimension` | `public_company_dimension_id` | `public_company_dimension_id` | ✗ |
| Financial Report Catalog Dimension | `datamart.gsdc_financial_report_catalog_dimension` | `public_company_dimension_id` | `financial_report_catalog_dimension_id` | ✗ |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 20 - Dữ liệu tài chính doanh nghiệp — Metadata BCTC | 6 |
| Nhóm 21 - DN thông thường — Bảng cân đối kế toán | 154 |
| Nhóm 22 - DN thông thường — Báo cáo KQKD | 39 |
| Nhóm 23 - DN thông thường — Báo cáo LCTT trực tiếp | 48 |
| Nhóm 24 - DN thông thường — Báo cáo LCTT gián tiếp | 70 |
| Nhóm 39 - Hệ số tài chính cơ bản | 8 |
| Dữ liệu tài chính về doanh nghiệp thông thường chi tiết - Bá | 1 |
| Nhóm 25 - DN bảo hiểm — Bảng cân đối kế toán | 83 |
| Nhóm 26 - DN bảo hiểm — Báo cáo KQKD | 16 |
| Nhóm 27 - DN bảo hiểm — Báo cáo LCTT trực tiếp | 28 |
| Dữ liệu tài chính doanh nghiệp bảo hiểm chi tiết - Báo cáo l | 1 |
| Nhóm 28 - DN bảo hiểm — Báo cáo LCTT gián tiếp | 32 |
| Dữ liệu tài chính tổ chức tín dụng chi tiết - Bảng cân đối k | 2 |
| Nhóm 29 - Tổ chức tín dụng — Bảng cân đối kế toán | 78 |
| Nhóm 30 - Tổ chức tín dụng — Báo cáo KQKD | 23 |
| Nhóm 31 - Tổ chức tín dụng — Báo cáo LCTT trực tiếp | 45 |
| Dữ liệu tài chính tổ chức tín dụng chi tiết - Báo cáo lưu ch | 4 |
| Nhóm 32 - Tổ chức tín dụng — Báo cáo LCTT gián tiếp | 50 |

---

## GSTT

**3 bảng flat** · **135 KPI unique**

---

### `datamart.gstt_fact_security_daily_market_summary_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Security Daily Market Summary |
| **Bảng fact/operational** | `datamart.gstt_fact_security_daily_market_summary` |
| **PK** | `—` |
| **Số dim join** | 2 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Security Trading Snapshot Dimension | `datamart.gstt_security_trading_snapshot_dimension` | `security_trading_snapshot_dimension_id` | `security_trading_snapshot_dimension_id` | ✗ |
| Public Company Dimension | `datamart.gstt_public_company_dimension` | `security_trading_snapshot_dimension_id` | `public_company_dimension_id` | ✗ |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Biểu đồ kỹ thuật — OHLCV Candlestick | 10 |
| Nhóm 26 — Bản Đồ Nhiệt | 14 |
| Nhóm 1 — Bảng số liệu Cổ phiếu | 27 |
| Nhóm 2 — Bảng số liệu Trái phiếu DN niêm yết | 5 |
| Nhóm 3 — Biểu đồ kỹ thuật Cổ phiếu | 7 |
| Data Explorer — KL Thỏa Thuận | 20 |
| Nhóm 14 — Top Giá trị Toàn thị trường (Bảng số liệu) | 4 |
| Nhóm 15 — Top Giá trị theo Sàn / Chỉ số (Bảng số liệu) | 4 |
| Nhóm 16 — Top Giá trị Toàn thị trường (Bảng số liệu) | 6 |
| Nhóm 17 — Top Giá trị Toàn thị trường (Biểu đồ kỹ thuật) | 4 |
| Nhóm 6 — Top Khối lượng Toàn thị trường (Bảng số liệu) | 10 |
| Nhóm 7 — Top Khối lượng Toàn thị trường (Biểu đồ kỹ thuật) | 9 |
| Nhóm 8 — Top Khối lượng theo Sàn / Chỉ số (Bảng số liệu) | 8 |
| Nhóm 9 — Top Khối lượng theo Sàn / Chỉ số (Biểu đồ kỹ thuật) | 11 |
| Nhóm 24 — Top NDTNN (Bảng số liệu) | 15 |
| Nhóm 25 — Top NDTNN (Biểu đồ kỹ thuật) | 14 |
| Nhóm 34 — Top NDTNN theo Sàn / Chỉ số (Bảng số liệu) | 7 |
| Nhóm 35 — Top NDTNN theo Sàn / Chỉ số (Biểu đồ kỹ thuật) | 4 |
| Nhóm 36 — Top NDTNN theo Sàn / Chỉ số (Bảng số liệu) | 9 |
| Nhóm 37 — Top NDTNN theo Sàn / Chỉ số (Biểu đồ kỹ thuật) | 6 |
| Nhóm 16 — Top Tăng Giá (Bảng số liệu) | 4 |
| Nhóm 17 — Top Tăng Giá (Biểu đồ kỹ thuật) | 7 |
| Nhóm 18 — Top Giảm Giá (Bảng số liệu) | 7 |
| Nhóm 19 — Top Giảm Giá (Biểu đồ kỹ thuật) | 9 |
| Nhóm 27 — Top Tăng Giá (Biểu đồ kỹ thuật) | 4 |
| Nhóm 30 — Top Tăng Giá (Bảng số liệu) | 6 |
| Nhóm 31 — Top Tăng Giá (Biểu đồ kỹ thuật) | 4 |
| Nhóm 32 — Top Tăng Giá theo Sàn / Chỉ số (Bảng số liệu) | 8 |
| Nhóm 33 — Top Tăng Giá theo Sàn / Chỉ số (Biểu đồ kỹ thuật) | 5 |
| Nhóm 20 — Top Vượt Đỉnh (Bảng số liệu) | 9 |
| Nhóm 21 — Top Vượt Đỉnh (Biểu đồ kỹ thuật) | 10 |
| Nhóm 22 — Top Thùng Đáy (Bảng số liệu) | 9 |
| Nhóm 23 — Top Thùng Đáy (Biểu đồ kỹ thuật) | 10 |
| Nhóm 28 — Top Thùng Đáy theo Sàn / Chỉ số (Bảng số liệu) | 9 |
| Nhóm 29 — Top Thùng Đáy theo Sàn / Chỉ số (Biểu đồ kỹ thuật) | 6 |
| Nhóm 10 — Top Đột phá Toàn thị trường (Bảng số liệu) | 13 |
| Nhóm 11 — Top Đột phá Toàn thị trường (Biểu đồ kỹ thuật) | 15 |
| Nhóm 12 — Top Đột phá theo Sàn / Chỉ số (Bảng số liệu) | 14 |
| Nhóm 13 — Top Đột phá theo Sàn / Chỉ số (Biểu đồ kỹ thuật) | 16 |
| Nhóm 14 — Top Đột phá theo Sàn / Chỉ số (Bảng số liệu) | 6 |
| Nhóm 15 — Top Đột phá theo Sàn / Chỉ số (Biểu đồ kỹ thuật) | 3 |
| Nhóm 27a — Sub-tab Tổng Quan / Biểu đồ cột (STT 40) | 6 |
| Nhóm 27b — Sub-tab Nước Ngoài / Biểu đồ GTNN (STT 41) | 8 |
| Nhóm 27b_heatmap — Sub-tab Nước Ngoài / Bản đồ nhiệt KLNN (STT 42) | 6 |
| Nhóm 27c — Sub-tab Tự Doanh (STT 43) | 7 |
| Nhóm 27d — Sub-tab Phân Loại Nhà Đầu Tư / Biểu đồ GT ròng (STT 44) | 15 |
| Nhóm 27d_heatmap — Sub-tab Phân Loại Nhà Đầu Tư / Bản đồ nhiệt GT ròng (STT 45) | 17 |
| Nhóm 27b — Sub-tab Nước Ngoài / Biểu đồ GTNN intraday (bổ sung) | 6 |
| Nhóm — Dashboard Chỉ số thị trường (bổ sung) | 17 |
| Nhóm — Dashboard Định giá thị trường (bổ sung) | 5 |
| Nhóm — Báo cáo BM021 Thống kê Định giá (bổ sung) | 17 |
| Data Explorer — KL Thỏa Thuận (bổ sung) | 8 |
| Biểu đồ kỹ thuật — OHLCV Candlestick (bổ sung) | 2 |

---

### `datamart.gstt_fact_corporate_bond_daily_market_summary_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Corporate Bond Daily Market Summary |
| **Bảng fact/operational** | `datamart.gstt_fact_corporate_bond_daily_market_summary` |
| **PK** | `—` |
| **Số dim join** | 2 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Corporate Bond Trading Snapshot Dimension | `datamart.gstt_corporate_bond_trading_snapshot_dimension` | `corporate_bond_trading_snapshot_dimension_id` | `corporate_bond_trading_snapshot_dimension_id` | ✗ |
| Corporate Bond Trading Snapshot Industry Dimension | `datamart.gstt_corporate_bond_trading_snapshot_industry_dimension` | `corporate_bond_trading_snapshot_dimension_id` | `bond_issuer_public_company_dimension_id` | ✗ |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Biểu đồ kỹ thuật — OHLCV Candlestick | 1 |
| Nhóm 26 — Bản Đồ Nhiệt | 2 |
| Nhóm 1 — Bảng số liệu Cổ phiếu | 1 |
| Nhóm 2 — Bảng số liệu Trái phiếu DN niêm yết | 7 |
| Nhóm 3 — Biểu đồ kỹ thuật Cổ phiếu | 1 |
| Data Explorer — KL Thỏa Thuận | 1 |
| Nhóm 16 — Top Giá trị Toàn thị trường (Bảng số liệu) | 1 |
| Nhóm 17 — Top Giá trị Toàn thị trường (Biểu đồ kỹ thuật) | 1 |
| Nhóm 6 — Top Khối lượng Toàn thị trường (Bảng số liệu) | 1 |
| Nhóm 8 — Top Khối lượng theo Sàn / Chỉ số (Bảng số liệu) | 1 |
| Nhóm 9 — Top Khối lượng theo Sàn / Chỉ số (Biểu đồ kỹ thuật) | 1 |
| Nhóm 24 — Top NDTNN (Bảng số liệu) | 1 |
| Nhóm 25 — Top NDTNN (Biểu đồ kỹ thuật) | 1 |
| Nhóm 34 — Top NDTNN theo Sàn / Chỉ số (Bảng số liệu) | 1 |
| Nhóm 36 — Top NDTNN theo Sàn / Chỉ số (Bảng số liệu) | 1 |
| Nhóm 37 — Top NDTNN theo Sàn / Chỉ số (Biểu đồ kỹ thuật) | 1 |
| Nhóm 18 — Top Giảm Giá (Bảng số liệu) | 1 |
| Nhóm 19 — Top Giảm Giá (Biểu đồ kỹ thuật) | 1 |
| Nhóm 27 — Top Tăng Giá (Biểu đồ kỹ thuật) | 1 |
| Nhóm 30 — Top Tăng Giá (Bảng số liệu) | 1 |
| Nhóm 31 — Top Tăng Giá (Biểu đồ kỹ thuật) | 1 |
| Nhóm 32 — Top Tăng Giá theo Sàn / Chỉ số (Bảng số liệu) | 1 |
| Nhóm 33 — Top Tăng Giá theo Sàn / Chỉ số (Biểu đồ kỹ thuật) | 1 |
| Nhóm 20 — Top Vượt Đỉnh (Bảng số liệu) | 1 |
| Nhóm 21 — Top Vượt Đỉnh (Biểu đồ kỹ thuật) | 1 |
| Nhóm 22 — Top Thùng Đáy (Bảng số liệu) | 1 |
| Nhóm 23 — Top Thùng Đáy (Biểu đồ kỹ thuật) | 1 |
| Nhóm 28 — Top Thùng Đáy theo Sàn / Chỉ số (Bảng số liệu) | 1 |
| Nhóm 29 — Top Thùng Đáy theo Sàn / Chỉ số (Biểu đồ kỹ thuật) | 1 |

---

### `datamart.gstt_stock_holder_ownership_profile_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Stock Holder Ownership Profile |
| **Bảng fact/operational** | `datamart.gstt_stock_holder_ownership_profile` |
| **PK** | `stock_holder_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 28 — Thông tin sở hữu và người nội bộ | 6 |

---

## NDTNN

**7 bảng flat** · **328 KPI unique**

---

### `datamart.ndtnn_fact_foreign_investor_registration_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Foreign Investor Registration |
| **Bảng fact/operational** | `datamart.ndtnn_fact_foreign_investor_registration` |
| **PK** | `—` |
| **Số dim join** | 2 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.ndtnn_calendar_date_dimension` | `registration_date_dimension_id` | `date_dimension_id` | ✗ |
| Foreign Investor Dimension | `datamart.ndtnn_foreign_investor_dimension` | `investor_dimension_id` | `investor_dimension_id` | ✗ |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 1 — Tăng trưởng NĐT mới | 4 |
| Nhóm 3 — Tỷ trọng GD NĐTNN | 5 |
| Nhóm 3 — Dòng tiền vào / ra / ròng | 1 |
| Nhóm 4 — Tương quan Net Flow | 2 |
| Nhóm 5 — Dòng vốn đầu tư gián tiếp | 3 |
| Nhóm 6 — Tổng giá trị danh mục | 3 |
| Nhóm 9 — ROOM sở hữu NĐTNN | 2 |
| Sub-tab B — Biến động tài sản | 2 |
| Nhóm 11a — Dòng vốn ròng | 1 |
| Nhóm 11b — Tổng GTDM | 1 |
| Nhóm 12 — Pass-through TT51 | Metadata điều hướng | 7 |
| Nhóm — Giao dịch | 23 |
| Nhóm — Giám sát dòng vốn | 16 |
| Nhóm — Danh mục | 22 |
| Nhóm — NĐT 360 | 11 |
| Nhóm — Báo cáo thống kê tình hình giao dịch | 12 |
| Nhóm — Báo cáo thống kê biểu chi tiết | 6 |
| Nhóm — Dòng vốn ròng của NĐTNN | 5 |
| Nhóm — Tổng giá trị danh mục của NĐTNN | 4 |

---

### `datamart.ndtnn_fact_foreign_investor_capital_flow_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Foreign Investor Capital Flow |
| **Bảng fact/operational** | `datamart.ndtnn_fact_foreign_investor_capital_flow` |
| **PK** | `—` |
| **Số dim join** | 3 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.ndtnn_calendar_date_dimension` | `report_date_dimension_id` | `date_dimension_id` | ✗ |
| Foreign Investor Dimension | `datamart.ndtnn_foreign_investor_dimension` | `investor_dimension_id` | `investor_dimension_id` | ✗ |
| Geographic Area Dimension | `datamart.ndtnn_geographic_area_dimension` | `country_dimension_id` | `geographic_area_dimension_id` | ✗ |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 3 — Dòng tiền vào / ra / ròng | 2 |
| Nhóm 4 — Tương quan Net Flow | 1 |
| Nhóm 5 — Dòng vốn đầu tư gián tiếp | 8 |
| Nhóm 11a — Dòng vốn ròng | 2 |

---

### `datamart.ndtnn_fact_foreign_investor_portfolio_snapshot_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Foreign Investor Portfolio Snapshot |
| **Bảng fact/operational** | `datamart.ndtnn_fact_foreign_investor_portfolio_snapshot` |
| **PK** | `—` |
| **Số dim join** | 5 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.ndtnn_calendar_date_dimension` | `snapshot_date_dimension_id` | `date_dimension_id` | ✗ |
| Foreign Investor Dimension | `datamart.ndtnn_foreign_investor_dimension` | `investor_dimension_id` | `investor_dimension_id` | ✗ |
| Geographic Area Dimension | `datamart.ndtnn_geographic_area_dimension` | `country_dimension_id` | `geographic_area_dimension_id` | ✗ |
| Asset Category Dimension | `datamart.ndtnn_asset_category_dimension` | `asset_category_dimension_id` | `asset_category_dimension_id` | ✗ |
| Industry Category Dimension | `datamart.ndtnn_industry_category_dimension` | `industry_category_dimension_id` | `industry_category_dimension_id` | ✗ |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 6 — Tổng giá trị danh mục | 6 |
| Nhóm 7 — Cơ cấu danh mục theo loại tài sản | 5 |
| Nhóm 8 — Bản đồ nhiệt phân ngành | 1 |
| Sub-tab B — Biến động tài sản | 2 |
| Nhóm 11b — Tổng GTDM | 1 |

---

### `datamart.ndtnn_fact_foreign_ownership_snapshot_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Foreign Ownership Snapshot |
| **Bảng fact/operational** | `datamart.ndtnn_fact_foreign_ownership_snapshot` |
| **PK** | `—` |
| **Số dim join** | 2 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.ndtnn_calendar_date_dimension` | `snapshot_date_dimension_id` | `date_dimension_id` | ✗ |
| Public Company Dimension | `datamart.ndtnn_public_company_dimension` | `public_company_dimension_id` | `public_company_dimension_id` | ✗ |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 9 — ROOM sở hữu NĐTNN | 4 |

---

### `datamart.ndtnn_foreign_investor_360_profile_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Foreign Investor 360 Profile |
| **Bảng fact/operational** | `datamart.ndtnn_foreign_investor_360_profile` |
| **PK** | `foreign_investor_profile_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Danh sách tìm kiếm NĐT | 4 |
| Sub-tab A — Hồ sơ định danh | 5 |

---

### `datamart.ndtnn_investor_compliance_history_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Investor Compliance History |
| **Bảng fact/operational** | `datamart.ndtnn_investor_compliance_history` |
| **PK** | `enforcement_decision_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Sub-tab C — Lịch sử tuân thủ | 5 |

---

### `datamart.ndtnn_ndtnn_regulatory_report_store_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | NDTNN Regulatory Report Store |
| **Bảng fact/operational** | `datamart.ndtnn_ndtnn_regulatory_report_store` |
| **PK** | `report_value_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 12 — Pass-through TT51 | CTQLQ, CN CTQLQ nước ngoài tại VN | 6 |
| Nhóm 12 — Pass-through TT51 | CTCK | 12 |
| Nhóm 12 — Pass-through TT51 | Ngân hàng lưu ký | 24 |
| Nhóm 12 — Pass-through TT51 | Đại diện CBTT | 36 |
| Nhóm 12 — Pass-through TT51 | Đại diện giao dịch | 6 |
| Nhóm 12 — Pass-through TT51 | NĐTNN | 36 |
| Nhóm 12 — Pass-through TT51 | SGDCK | 6 |
| Nhóm 12 — Pass-through TT51 | VSDC | 30 |

---

## NHNCK

**11 bảng flat** (2 fact + 9 operational) · **121 KPI unique**

*(Sửa 2026-08) Đồng bộ lại toàn bộ theo `Datamart/flat-table/NHNCK/01_create_nhnck_flat_tables.sql` + `Datamart/lld/DTM_NHNCK_Detail_Mapping.csv` hiện tại — bản trước lệch tên bảng/cột và thiếu 1 bảng so với SQL thực tế.*

---

### `datamart.nhnck_fct_practitioner_license_certificate_snpst_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Practitioner License Certificate Snapshot |
| **Bảng fact/operational** | `datamart.fct_practitioner_license_certificate_snpst` |
| **PK** | `—` |
| **Số dim join** | 3 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.cdr_dt_dim` | `issue_dt_dim_id` | `cdr_dt_dim_id` | SCD4A |
| Calendar Date Dimension | `datamart.cdr_dt_dim` | `snpst_dt_dim_id` | `cdr_dt_dim_id` | SCD4A |
| Securities Practitioner Dimension | `datamart.securities_practitioner_dim` | `practitioner_dim_id` | `securities_practitioner_dim_id` | SCD4A |
| SP License Certificate Type Dimension | `datamart.sp_license_certificate_type_dim` | `certificate_tp_dim_id` | `certificate_tp_dim_id` | SCD4A |

*(Sửa 2026-08) `Is Reissue Indicator`/`Certificate Issue Date` nay lấy từ Certificate Document/Decision Document (không còn qua Application). Cột `certificate_tp_code` dư thừa đã xoá khỏi Fact — chỉ giữ FK `certificate_tp_dim_id`.*

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 1a — Thống kê tổng hợp (KPI thẻ CCHN) | 7 |
| Nhóm 3 — Biểu đồ cơ cấu theo loại hình CCHN | 3 |

---

### `datamart.nhnck_fct_practitioner_daily_snpst_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Practitioner Daily Snapshot |
| **Bảng fact/operational** | `datamart.fct_practitioner_daily_snpst` |
| **PK** | `—` |
| **Số dim join** | 2 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.cdr_dt_dim` | `snpst_dt_dim_id` | `cdr_dt_dim_id` | SCD4A |
| Securities Practitioner Dimension | `datamart.securities_practitioner_dim` | `practitioner_dim_id` | `securities_practitioner_dim_id` | SCD4A |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 1b — Thống kê tổng hợp (KPI thẻ NHN) | 2 |
| Nhóm 2 — Biểu đồ Trình độ chuyên môn | 3 |
| Nhóm 4 — Biểu đồ Phân bổ độ tuổi | 10 |

---

### `datamart.nhnck_opr_practitioner_360_profile_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Operational Practitioner 360 Profile |
| **Bảng fact/operational** | `datamart.opr_practitioner_360_profile` |
| **PK** | `practitioner_code` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

*(Sửa 2026-08) `Nationality_Code/Name` tự JOIN Geographic Area filter COUNTRY. `Active_Certificate_Type_Code/Name`/`Active_Certificate_Number` JOIN trực tiếp Certificate Document (bản ghi Issue Date mới nhất per NHN), không còn qua Organization Employment Report. `Workplace` về lại PROFESSIONALS.WORKPLACE.*

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 5 — Thông tin chung của NHNCK | 9 |
| Nhóm 13 — Practitioner Data Explorer | 5 |

---

### `datamart.nhnck_opr_practitioner_related_party_profile_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Operational Practitioner Related Party Profile |
| **Bảng fact/operational** | `datamart.opr_practitioner_related_party_profile` |
| **PK** | `practitioner_code, related_party_code` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 6 — Sub-tab Mạng lưới người liên quan | 6 |
| Nhóm 7 — Dashboard Hồ sơ & Danh mục của NHNCK | 3 |

---

### `datamart.nhnck_opr_practitioner_list_company_role_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Operational Practitioner Listed Company Role |
| **Bảng fact/operational** | `datamart.opr_practitioner_list_company_role` |
| **PK** | `practitioner_code, organization_employment_rpt_code` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 6 — Sub-tab Mạng lưới người liên quan | 2 |
| Nhóm 7 — Dashboard Hồ sơ & Danh mục của NHNCK | 5 |

---

### `datamart.nhnck_opr_practitioner_certificate_hist_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Operational Practitioner Certificate History |
| **Bảng fact/operational** | `datamart.opr_practitioner_certificate_hist` |
| **PK** | `practitioner_code, license_certificate_document_code` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table). `certificate_tp_code/nm` giữ nguồn Certificate Document trực tiếp — không thuộc phạm vi đổi nguồn 2026-08 (khác `opr_practitioner_360_profile`)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 9 — Sub-tab Lịch sử cấp chứng chỉ hành nghề | 6 |

---

### `datamart.nhnck_opr_practitioner_employment_hist_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Operational Practitioner Employment History |
| **Bảng fact/operational** | `datamart.opr_practitioner_employment_hist` |
| **PK** | `practitioner_code, organization_employment_rpt_code` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 8 — Sub-tab Quá trình hành nghề | 7 |

---

### `datamart.nhnck_opr_practitioner_violation_hist_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Operational Practitioner Violation History |
| **Bảng fact/operational** | `datamart.opr_practitioner_violation_hist` |
| **PK** | `practitioner_code, conduct_violation_code` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 12 — Sub-tab Lịch sử vi phạm & xử phạt hành chính | 4 |
| Nhóm 13 — Practitioner Data Explorer | 3 |

---

### `datamart.nhnck_opr_practitioner_exam_hist_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Operational Practitioner Exam History |
| **Bảng fact/operational** | `datamart.opr_practitioner_exam_hist` |
| **PK** | `practitioner_code, examination_assessment_result_code` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 10 — Sub-tab Đợt thi sát hạch | 8 |
| Nhóm 13 — Practitioner Data Explorer | 5 |

---

### `datamart.nhnck_opr_practitioner_training_hist_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Operational Practitioner Training History |
| **Bảng fact/operational** | `datamart.opr_practitioner_training_hist` |
| **PK** | `practitioner_code, enrollment_code` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 11 — Sub-tab Cập nhật kiến thức hành nghề | 7 |

---

### `datamart.nhnck_opr_practitioner_data_explorer_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Operational Practitioner Data Explorer |
| **Bảng fact/operational** | `datamart.opr_practitioner_data_explorer` |
| **PK** | `practitioner_code, license_certificate_document_code` |
| **Số dim join** | 0 |

_Không có dim join — nhưng (Sửa 2026-07-22) LEFT JOIN thêm Practitioner 360 Profile (1-1), Practitioner Exam History (1-N, fan-out), Practitioner Violation History (1-N, fan-out). Grain thực tế = 1 CCHN × 1 đợt thi × 1 vi phạm._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 13 — Practitioner Data Explorer (bảng tra cứu tổng hợp) | 9 |

---

## QLCB

**3 bảng flat** · **66 KPI unique**

---

### `datamart.qlcb_fact_securities_offering_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Securities Offering |
| **Bảng fact/operational** | `datamart.qlcb_fact_securities_offering` |
| **PK** | `—` |
| **Số dim join** | 3 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.qlcb_calendar_date_dimension` | `ssc_official_document_date_dimension_id` | `date_dimension_id` | ✗ |
| Public Company Dimension | `datamart.qlcb_public_company_dimension` | `public_company_dimension_id` | `public_company_dimension_id` | ✗ |
| Industry Category Dimension | `datamart.qlcb_industry_category_dimension` | `industry_category_dimension_id` | `industry_category_dimension_id` | ✗ |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 1 — Tình hình chào bán | 6 |
| Nhóm 2 — Cấp phép theo loại hình | 7 |
| Nhóm 3 — Huy động theo loại hình | 6 |
| Nhóm 4 — Bảng chi tiết | 1 |
| Nhóm 10 — Cấp phép chào bán | 1 |
| Nhóm 11 — Kết quả chào bán | 1 |
| Nhóm 5 — KPI Cards | 5 |
| Nhóm 6 — Biểu đồ donut | 2 |
| Nhóm 7 — Bảng chi tiết hồ sơ | 7 |

---

### `datamart.qlcb_fact_securities_offering_application_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Securities Offering Application |
| **Bảng fact/operational** | `datamart.qlcb_fact_securities_offering_application` |
| **PK** | `—` |
| **Số dim join** | 2 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.qlcb_calendar_date_dimension` | `submission_date_dimension_id` | `date_dimension_id` | ✗ |
| Offering Type Dimension | `datamart.qlcb_offering_type_dimension` | `offering_type_dimension_id` | `offering_type_dimension_id` | ✗ |

_Chưa có KPI mapping vào bảng flat này._

---

### `datamart.qlcb_securities_offering_360_profile_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Securities Offering 360 Profile |
| **Bảng fact/operational** | `datamart.qlcb_securities_offering_360_profile` |
| **PK** | `securities_offering_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 4 — Bảng chi tiết | 10 |
| Nhóm 8 — Thông tin cơ sở | 6 |
| Nhóm 9 — Công văn cấp phép | 5 |
| Nhóm 10 — Cấp phép chào bán | 5 |
| Nhóm 11 — Kết quả chào bán | 4 |

---

## QLKD

**18 bảng flat** · **3175 KPI unique**

---

### `datamart.qlkd_fact_securities_company_status_snapshot_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Securities Company Status Snapshot |
| **Bảng fact/operational** | `datamart.qlkd_fact_securities_company_status_snapshot` |
| **PK** | `—` |
| **Số dim join** | 2 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.qlkd_calendar_date_dimension` | `snapshot_date_dimension_id` | `calendar_date_dimension_id` | ✗ |
| Securities Company Dimension | `datamart.qlkd_securities_company_dimension` | `securities_company_dimension_id` | `securities_company_dimension_id` | ✗ |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 1 — Chỉ tiêu thống kê chung | 13 |
| Nhóm 8 — Cơ cấu tài sản | 3 |
| Nhóm 9 — Cơ cấu nguồn vốn | 3 |
| Sub-tab GIÁM SÁT HOẠT ĐỘNG — Nhóm GS-1 | 2 |
| Sub-tab GIÁM SÁT HOẠT ĐỘNG — Nhóm GS-7 | 2 |
| Sub-tab GIÁM SÁT TUÂN THỦ — Nhóm GS-9 | 5 |
| Nhóm 360-2→5 — Biểu đồ tài chính per CTCK | 5 |
| Nhóm 360-6 — Lịch sử BCTC | 10 |
| Nhóm 360-7 — NHNCK | 4 |
| Nhóm 5/6/7 — Duy trì điều kiện cấp phép | 12 |
| Nhóm 2 — Biểu đồ Nghiệp vụ | 2 |
| Nhóm 3 — Biểu đồ Dịch vụ CK | 2 |
| Nhóm 4 — Biểu đồ Dịch vụ Phái sinh | 5 |
| Sub-tab GIÁM SÁT HOẠT ĐỘNG — Nhóm GS-6 | 9 |
| Sub-tab GIÁM SÁT HOẠT ĐỘNG — Nhóm GS-2 | 1 |
| Sub-tab GIÁM SÁT HOẠT ĐỘNG — Nhóm GS-3 | 1 |
| Sub-tab GIÁM SÁT HOẠT ĐỘNG — Nhóm GS-4 | 4 |
| Sub-tab GIÁM SÁT HOẠT ĐỘNG — Nhóm GS-8 | 3 |
| Nhóm 360-10 — CN, PGD, VPĐD | 18 |
| Nhóm 360-1 — Banner tổng quan CTCK | 2 |
| Nhóm 360-9 — Tuân thủ & Vi phạm | 10 |
| Nhóm TCA-2 — Mạng lưới 360° (graph) | 6 |
| Nhóm TCA-3 — Vai trò tại DN niêm yết | 1 |
| Nhóm TCA-4 — Người liên quan chi tiết | 1 |
| Nhóm TCA-5 — Quá trình hành nghề | 1 |
| Nhóm TCA-6 — Lịch sử vi phạm & xử phạt | 3 |
| Nhóm DE-1 — STT 42 — Chào bán phát hành | 3 |
| Nhóm DE-1 — STT 43 — Chào bán phát hành | 3 |
| Nhóm DE-1 — STT 44 — Báo cáo giám sát | 3 |
| Nhóm DE-1 — STT 45 — Báo cáo giám sát | 3 |
| Nhóm DE-1 — STT 46 — Báo cáo giám sát | 3 |
| Nhóm DE-1 — STT 47 — Báo cáo giám sát | 3 |
| Nhóm DE-1 — STT 48 — Báo cáo giám sát | 3 |
| Nhóm DE-1 — STT 49 — Báo cáo chứng quyền có đảm bảo | 3 |
| Nhóm DE-1 — STT 50 — Báo cáo chứng quyền có đảm bảo | 3 |
| Nhóm DE-1 — STT 51 — Báo cáo chứng quyền có đảm bảo | 3 |
| Nhóm DE-1 — STT 52 — Báo cáo chứng quyền có đảm bảo | 3 |
| Nhóm DE-1 — STT 53 — Báo cáo chứng quyền có đảm bảo | 3 |
| Nhóm DE-1 — STT 54 — Báo cáo chứng quyền có đảm bảo | 3 |
| Nhóm DE-1 — STT 55 — Báo cáo chứng quyền có đảm bảo | 3 |
| Nhóm DE-1 — STT 56 — Báo cáo chứng quyền có đảm bảo | 3 |
| Nhóm DE-1 — STT 57 — Hoạt động phái sinh | 3 |
| Nhóm DE-1 — STT 58 — Hoạt động phái sinh | 3 |
| Nhóm DE-1 — STT 59 — Hoạt động phái sinh | 3 |
| Nhóm DE-1 — STT 60 — Hoạt động phái sinh | 3 |
| Nhóm DE-1 — STT 61 — Hoạt động phái sinh | 3 |
| Nhóm DE-1 — STT 62 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 63 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 64 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 65 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 66 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 67 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 68 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 69 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 70 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 71 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 72 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 73 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 74 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 75 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 76 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 77 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 78 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 79 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 80 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 81 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 82 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 83 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 84 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 85 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 86 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 87 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 88 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 89 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 90 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 91 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 92 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 93 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 94 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 95 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 96 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 97 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 98 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 99 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 100 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 101 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 102 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 103 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 104 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 105 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 106 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 107 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 108 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 109 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 110 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 111 — Báo cáo giám sát quản trị công ty | 3 |
| Nhóm DE-1 — STT 112 — Báo cáo giám sát quản trị công ty | 3 |
| Nhóm DE-1 — STT 113 — Báo cáo giám sát quản trị công ty | 3 |
| Nhóm DE-1 — STT 114 — Báo cáo giám sát quản trị công ty | 3 |
| Nhóm DE-1 — STT 115 — Báo cáo giám sát quản trị công ty | 3 |
| Nhóm DE-1 — STT 116 — Báo cáo giám sát quản trị công ty | 3 |
| Nhóm DE-1 — STT 117 — Báo cáo NPF | 3 |
| Nhóm DE-1 — STT 118 — Báo cáo thường niên | 4 |
| Nhóm DE-1 — STT 119 — Báo cáo liên quan đến trái phiếu doanh n | 3 |
| Nhóm DE-1 — STT 120 — Báo cáo tình hình hoạt động tháng - Chi | 3 |
| Nhóm DE-1 — STT 121 — Báo cáo tình hình hoạt động năm - Chi nh | 3 |
| Nhóm DE-1 — STT 122 — Báo cáo tài chính quý, soát xét bán niên | 3 |
| Nhóm DE-1 — STT 123 — Báo cáo tài chính quý, soát xét bán niên | 3 |
| Nhóm DE-1 — STT 124 — Báo cáo tài chính quý, soát xét bán niên | 3 |
| Nhóm DE-1 — STT 125 — Báo cáo tài chính quý, soát xét bán niên | 3 |
| Nhóm DE-1 — STT 126 — Báo cáo tài chính quý, soát xét bán niên | 3 |
| Nhóm DE-1 — STT 127 — Báo cáo tài chính quý, soát xét bán niên | 3 |
| Nhóm DE-1 — STT 128 — Báo cáo tài chính quý, soát xét bán niên | 3 |
| Nhóm DE-1 — STT 129 — Báo cáo tài chính quý, soát xét bán niên | 3 |
| Nhóm DE-1 — STT 130 — Báo cáo tài chính quý, soát xét bán niên | 3 |
| Nhóm DE-1 — STT 131 — Báo cáo tỷ lệ an toàn tài chính - Chi nh | 3 |
| Nhóm DE-1 — STT 132 — Báo cáo tỷ lệ an toàn tài chính - Chi nh | 3 |
| Nhóm DE-1 — STT 133 — Báo cáo tỷ lệ an toàn tài chính - Chi nh | 3 |
| Nhóm DE-1 — STT 134 — Báo cáo tỷ lệ an toàn tài chính - Chi nh | 3 |
| Nhóm DE-1 — STT 135 — Báo cáo tỷ lệ an toàn tài chính - Chi nh | 3 |
| Nhóm DE-1 — STT 136 — Báo cáo tỷ lệ an toàn tài chính - Chi nh | 3 |
| Nhóm DE-1 — STT 137 — Báo cáo tỷ lệ an toàn tài chính - Chi nh | 3 |
| Nhóm DE-1 — STT 138 — Báo cáo tỷ lệ an toàn tài chính - Chi nh | 3 |
| Nhóm DE-1 — STT 139 — Báo cáo tỷ lệ an toàn tài chính - Chi nh | 3 |
| Nhóm DE-1 — STT 140 — Báo cáo tình hình hoạt động quý/năm - VP | 3 |
| Nhóm DE-1 — STT 141 | 9 |
| Nhóm DE-1 — STT 142 | 17 |
| Nhóm DE-1 — STT 143 | 39 |

---

### `datamart.qlkd_fact_securities_company_business_type_snapshot_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Securities Company Business Type Snapshot |
| **Bảng fact/operational** | `datamart.qlkd_fact_securities_company_business_type_snapshot` |
| **PK** | `—` |
| **Số dim join** | 3 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.qlkd_calendar_date_dimension` | `snapshot_date_dimension_id` | `calendar_date_dimension_id` | ✗ |
| Securities Company Dimension | `datamart.qlkd_securities_company_dimension` | `securities_company_dimension_id` | `securities_company_dimension_id` | ✗ |
| Business Type Dimension | `datamart.qlkd_business_type_dimension` | `business_type_dimension_id` | `business_type_dimension_id` | ✗ |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 2 — Biểu đồ Nghiệp vụ | 4 |

---

### `datamart.qlkd_fact_securities_company_service_registration_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Securities Company Service Registration |
| **Bảng fact/operational** | `datamart.qlkd_fact_securities_company_service_registration` |
| **PK** | `—` |
| **Số dim join** | 3 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.qlkd_calendar_date_dimension` | `registration_date_dimension_id` | `calendar_date_dimension_id` | ✗ |
| Securities Company Dimension | `datamart.qlkd_securities_company_dimension` | `securities_company_dimension_id` | `securities_company_dimension_id` | ✗ |
| Service Type Dimension | `datamart.qlkd_service_type_dimension` | `service_type_dimension_id` | `service_type_dimension_id` | ✗ |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 3 — Biểu đồ Dịch vụ CK | 3 |
| Nhóm 4 — Biểu đồ Dịch vụ Phái sinh | 3 |

---

### `datamart.qlkd_fact_securities_company_financial_structure_snapshot_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Securities Company Financial Structure Snapshot |
| **Bảng fact/operational** | `datamart.qlkd_fact_securities_company_financial_structure_snapshot` |
| **PK** | `—` |
| **Số dim join** | 3 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.qlkd_calendar_date_dimension` | `report_date_dimension_id` | `calendar_date_dimension_id` | ✗ |
| Securities Company Dimension | `datamart.qlkd_securities_company_dimension` | `securities_company_dimension_id` | `securities_company_dimension_id` | ✗ |
| Report Indicator Dimension | `datamart.qlkd_report_indicator_dimension` | `report_indicator_dimension_id` | `report_indicator_dimension_id` | ✗ |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 8 — Cơ cấu tài sản | 5 |
| Nhóm 9 — Cơ cấu nguồn vốn | 3 |
| Sub-tab GIÁM SÁT HOẠT ĐỘNG — Nhóm GS-1 | 3 |
| Sub-tab GIÁM SÁT HOẠT ĐỘNG — Nhóm GS-2 | 1 |
| Sub-tab GIÁM SÁT HOẠT ĐỘNG — Nhóm GS-3 | 5 |
| Sub-tab GIÁM SÁT HOẠT ĐỘNG — Nhóm GS-4 | 3 |
| Sub-tab GIÁM SÁT HOẠT ĐỘNG — Nhóm GS-5 | 7 |
| Sub-tab GIÁM SÁT HOẠT ĐỘNG — Nhóm GS-6 | 1 |
| Sub-tab GIÁM SÁT HOẠT ĐỘNG — Nhóm GS-7 | 1 |
| Sub-tab GIÁM SÁT HOẠT ĐỘNG — Nhóm GS-8 | 2 |
| Nhóm 360-2→5 — Biểu đồ tài chính per CTCK | 7 |

---

### `datamart.qlkd_fact_securities_company_report_compliance_snapshot_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Securities Company Report Compliance Snapshot |
| **Bảng fact/operational** | `datamart.qlkd_fact_securities_company_report_compliance_snapshot` |
| **PK** | `—` |
| **Số dim join** | 2 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.qlkd_calendar_date_dimension` | `snapshot_date_dimension_id` | `calendar_date_dimension_id` | ✗ |
| Securities Company Dimension | `datamart.qlkd_securities_company_dimension` | `securities_company_dimension_id` | `securities_company_dimension_id` | ✗ |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Sub-tab GIÁM SÁT TUÂN THỦ — Nhóm GS-9 | 3 |

---

### `datamart.qlkd_securities_company_financial_report_history_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Securities Company Financial Report History |
| **Bảng fact/operational** | `datamart.qlkd_securities_company_financial_report_history` |
| **PK** | `financial_report_history_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 360-6 — Lịch sử BCTC | 2 |

---

### `datamart.qlkd_securities_company_personnel_profile_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Securities Company Personnel Profile |
| **Bảng fact/operational** | `datamart.qlkd_securities_company_personnel_profile` |
| **PK** | `personnel_profile_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 360-1 — Banner tổng quan CTCK | 5 |
| Nhóm 360-8 — Nhân sự & Cổ đông | 2 |
| Nhóm 360-10 — CN, PGD, VPĐD | 2 |

---

### `datamart.qlkd_securities_company_practitioner_profile_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Securities Company Practitioner Profile |
| **Bảng fact/operational** | `datamart.qlkd_securities_company_practitioner_profile` |
| **PK** | `practitioner_profile_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 360-7 — NHNCK | 2 |

---

### `datamart.qlkd_securities_company_compliance_hist_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Securities Company Compliance History |
| **Bảng fact/operational** | `datamart.qlkd_securities_company_compliance_hist` |
| **PK** | `compliance_history_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 360-9 — Tuân thủ & Vi phạm | 4 |

---

### `datamart.qlkd_securities_company_organization_unit_profile_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Securities Company Organization Unit Profile |
| **Bảng fact/operational** | `datamart.qlkd_securities_company_organization_unit_profile` |
| **PK** | `organization_unit_profile_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

_Chưa có KPI mapping vào bảng flat này._

---

### `datamart.qlkd_individual_profile_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Individual Profile |
| **Bảng fact/operational** | `datamart.qlkd_individual_profile` |
| **PK** | `individual_profile_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm TCA-1 — Landing page danh sách cá nhân | 1 |
| Nhóm TCA-2 — Mạng lưới 360° (graph) | 1 |

---

### `datamart.qlkd_individual_related_party_network_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Individual Related Party Network |
| **Bảng fact/operational** | `datamart.qlkd_individual_related_party_network` |
| **PK** | `related_party_network_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm TCA-2 — Mạng lưới 360° (graph) | 1 |
| Nhóm TCA-4 — Người liên quan chi tiết | 5 |

---

### `datamart.qlkd_individual_listed_company_role_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Individual Listed Company Role |
| **Bảng fact/operational** | `datamart.qlkd_individual_listed_company_role` |
| **PK** | `listed_company_role_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm TCA-3 — Vai trò tại DN niêm yết | 2 |

---

### `datamart.qlkd_individual_trading_account_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Individual Trading Account |
| **Bảng fact/operational** | `datamart.qlkd_individual_trading_account` |
| **PK** | `trading_account_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm TCA-4b — Tài khoản giao dịch | 1 |

---

### `datamart.qlkd_individual_work_hist_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Individual Work History |
| **Bảng fact/operational** | `datamart.qlkd_individual_work_hist` |
| **PK** | `work_history_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm TCA-5 — Quá trình hành nghề | 4 |

---

### `datamart.qlkd_individual_violation_hist_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Individual Violation History |
| **Bảng fact/operational** | `datamart.qlkd_individual_violation_hist` |
| **PK** | `violation_history_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm TCA-6 — Lịch sử vi phạm & xử phạt | 5 |

---

### `datamart.qlkd_securities_company_report_data_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Securities Company Report Data |
| **Bảng fact/operational** | `datamart.qlkd_securities_company_report_data` |
| **PK** | `report_data_id` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm DE-1 — Tra cứu báo cáo biểu mẫu định kỳ | 1 |
| Nhóm DE-1 — STT 42 — Chào bán phát hành | 95 |
| Nhóm DE-1 — STT 43 — Chào bán phát hành | 73 |
| Nhóm DE-1 — STT 44 — Báo cáo giám sát | 19 |
| Nhóm DE-1 — STT 45 — Báo cáo giám sát | 27 |
| Nhóm DE-1 — STT 46 — Báo cáo giám sát | 19 |
| Nhóm DE-1 — STT 47 — Báo cáo giám sát | 19 |
| Nhóm DE-1 — STT 48 — Báo cáo giám sát | 191 |
| Nhóm DE-1 — STT 49 — Báo cáo chứng quyền có đảm bảo | 11 |
| Nhóm DE-1 — STT 50 — Báo cáo chứng quyền có đảm bảo | 13 |
| Nhóm DE-1 — STT 51 — Báo cáo chứng quyền có đảm bảo | 14 |
| Nhóm DE-1 — STT 52 — Báo cáo chứng quyền có đảm bảo | 16 |
| Nhóm DE-1 — STT 53 — Báo cáo chứng quyền có đảm bảo | 17 |
| Nhóm DE-1 — STT 54 — Báo cáo chứng quyền có đảm bảo | 16 |
| Nhóm DE-1 — STT 55 — Báo cáo chứng quyền có đảm bảo | 18 |
| Nhóm DE-1 — STT 56 — Báo cáo chứng quyền có đảm bảo | 9 |
| Nhóm DE-1 — STT 57 — Hoạt động phái sinh | 24 |
| Nhóm DE-1 — STT 58 — Hoạt động phái sinh | 22 |
| Nhóm DE-1 — STT 59 — Hoạt động phái sinh | 7 |
| Nhóm DE-1 — STT 60 — Hoạt động phái sinh | 23 |
| Nhóm DE-1 — STT 61 — Hoạt động phái sinh | 9 |
| Nhóm DE-1 — STT 62 — Báo cáo theo Thông tư 121/2020/TT-BTC | 22 |
| Nhóm DE-1 — STT 63 — Báo cáo theo Thông tư 121/2020/TT-BTC | 18 |
| Nhóm DE-1 — STT 64 — Báo cáo theo Thông tư 121/2020/TT-BTC | 54 |
| Nhóm DE-1 — STT 65 — Báo cáo theo Thông tư 121/2020/TT-BTC | 28 |
| Nhóm DE-1 — STT 66 — Báo cáo theo Thông tư 121/2020/TT-BTC | 22 |
| Nhóm DE-1 — STT 67 — Báo cáo theo Thông tư 121/2020/TT-BTC | 17 |
| Nhóm DE-1 — STT 68 — Báo cáo theo Thông tư 121/2020/TT-BTC | 15 |
| Nhóm DE-1 — STT 69 — Báo cáo theo Thông tư 121/2020/TT-BTC | 41 |
| Nhóm DE-1 — STT 70 — Báo cáo theo Thông tư 121/2020/TT-BTC | 20 |
| Nhóm DE-1 — STT 71 — Báo cáo theo Thông tư 121/2020/TT-BTC | 17 |
| Nhóm DE-1 — STT 72 — Báo cáo theo Thông tư 121/2020/TT-BTC | 17 |
| Nhóm DE-1 — STT 73 — Báo cáo theo Thông tư 121/2020/TT-BTC | 9 |
| Nhóm DE-1 — STT 74 — Báo cáo theo Thông tư 121/2020/TT-BTC | 9 |
| Nhóm DE-1 — STT 75 — Báo cáo theo Thông tư 121/2020/TT-BTC | 4 |
| Nhóm DE-1 — STT 76 — Báo cáo theo Thông tư 121/2020/TT-BTC | 18 |
| Nhóm DE-1 — STT 77 — Báo cáo theo Thông tư 121/2020/TT-BTC | 12 |
| Nhóm DE-1 — STT 78 — Báo cáo theo Thông tư 121/2020/TT-BTC | 89 |
| Nhóm DE-1 — STT 79 — Báo cáo theo Thông tư 121/2020/TT-BTC | 10 |
| Nhóm DE-1 — STT 80 — Báo cáo theo Thông tư 121/2020/TT-BTC | 11 |
| Nhóm DE-1 — STT 81 — Báo cáo theo Thông tư 121/2020/TT-BTC | 16 |
| Nhóm DE-1 — STT 82 — Báo cáo theo Thông tư 121/2020/TT-BTC | 14 |
| Nhóm DE-1 — STT 83 — Báo cáo theo Thông tư 121/2020/TT-BTC | 9 |
| Nhóm DE-1 — STT 84 — Báo cáo theo Thông tư 121/2020/TT-BTC | 14 |
| Nhóm DE-1 — STT 85 — Báo cáo theo Thông tư 121/2020/TT-BTC | 9 |
| Nhóm DE-1 — STT 86 — Báo cáo theo Thông tư 121/2020/TT-BTC | 9 |
| Nhóm DE-1 — STT 87 — Báo cáo theo Thông tư 121/2020/TT-BTC | 8 |
| Nhóm DE-1 — STT 88 — Báo cáo theo Thông tư 121/2020/TT-BTC | 8 |
| Nhóm DE-1 — STT 89 — Báo cáo theo Thông tư 121/2020/TT-BTC | 8 |
| Nhóm DE-1 — STT 90 — Báo cáo theo Thông tư 121/2020/TT-BTC | 10 |
| Nhóm DE-1 — STT 91 — Báo cáo theo Thông tư 121/2020/TT-BTC | 8 |
| Nhóm DE-1 — STT 92 — Báo cáo theo Thông tư 121/2020/TT-BTC | 7 |
| Nhóm DE-1 — STT 93 — Báo cáo theo Thông tư 121/2020/TT-BTC | 128 |
| Nhóm DE-1 — STT 94 — Báo cáo theo Thông tư 121/2020/TT-BTC | 46 |
| Nhóm DE-1 — STT 95 — Báo cáo theo Thông tư 121/2020/TT-BTC | 71 |
| Nhóm DE-1 — STT 96 — Báo cáo theo Thông tư 121/2020/TT-BTC | 43 |
| Nhóm DE-1 — STT 97 — Báo cáo theo Thông tư 121/2020/TT-BTC | 35 |
| Nhóm DE-1 — STT 98 — Báo cáo theo Thông tư 121/2020/TT-BTC | 75 |
| Nhóm DE-1 — STT 99 — Báo cáo theo Thông tư 121/2020/TT-BTC | 38 |
| Nhóm DE-1 — STT 100 — Báo cáo theo Thông tư 121/2020/TT-BTC | 23 |
| Nhóm DE-1 — STT 101 — Báo cáo theo Thông tư 121/2020/TT-BTC | 4 |
| Nhóm DE-1 — STT 102 — Báo cáo theo Thông tư 121/2020/TT-BTC | 4 |
| Nhóm DE-1 — STT 103 — Báo cáo theo Thông tư 121/2020/TT-BTC | 2 |
| Nhóm DE-1 — STT 104 — Báo cáo theo Thông tư 121/2020/TT-BTC | 8 |
| Nhóm DE-1 — STT 105 — Báo cáo theo Thông tư 121/2020/TT-BTC | 4 |
| Nhóm DE-1 — STT 106 — Báo cáo theo Thông tư 121/2020/TT-BTC | 4 |
| Nhóm DE-1 — STT 107 — Báo cáo theo Thông tư 121/2020/TT-BTC | 4 |
| Nhóm DE-1 — STT 108 — Báo cáo theo Thông tư 121/2020/TT-BTC | 2 |
| Nhóm DE-1 — STT 109 — Báo cáo theo Thông tư 121/2020/TT-BTC | 3 |
| Nhóm DE-1 — STT 110 — Báo cáo theo Thông tư 121/2020/TT-BTC | 5 |
| Nhóm DE-1 — STT 111 — Báo cáo giám sát quản trị công ty | 23 |
| Nhóm DE-1 — STT 112 — Báo cáo giám sát quản trị công ty | 18 |
| Nhóm DE-1 — STT 113 — Báo cáo giám sát quản trị công ty | 19 |
| Nhóm DE-1 — STT 114 — Báo cáo giám sát quản trị công ty | 29 |
| Nhóm DE-1 — STT 115 — Báo cáo giám sát quản trị công ty | 23 |
| Nhóm DE-1 — STT 116 — Báo cáo giám sát quản trị công ty | 29 |
| Nhóm DE-1 — STT 117 — Báo cáo NPF | 27 |
| Nhóm DE-1 — STT 118 — Báo cáo thường niên | 60 |
| Nhóm DE-1 — STT 119 — Báo cáo liên quan đến trái phiếu doanh n | 16 |
| Nhóm DE-1 — STT 120 — Báo cáo tình hình hoạt động tháng - Chi | 38 |
| Nhóm DE-1 — STT 121 — Báo cáo tình hình hoạt động năm - Chi nh | 65 |
| Nhóm DE-1 — STT 122 — Báo cáo tài chính quý, soát xét bán niên | 7 |
| Nhóm DE-1 — STT 123 — Báo cáo tài chính quý, soát xét bán niên | 128 |
| Nhóm DE-1 — STT 124 — Báo cáo tài chính quý, soát xét bán niên | 46 |
| Nhóm DE-1 — STT 125 — Báo cáo tài chính quý, soát xét bán niên | 71 |
| Nhóm DE-1 — STT 126 — Báo cáo tài chính quý, soát xét bán niên | 43 |
| Nhóm DE-1 — STT 127 — Báo cáo tài chính quý, soát xét bán niên | 35 |
| Nhóm DE-1 — STT 128 — Báo cáo tài chính quý, soát xét bán niên | 75 |
| Nhóm DE-1 — STT 129 — Báo cáo tài chính quý, soát xét bán niên | 38 |
| Nhóm DE-1 — STT 130 — Báo cáo tài chính quý, soát xét bán niên | 23 |
| Nhóm DE-1 — STT 131 — Báo cáo tỷ lệ an toàn tài chính - Chi nh | 4 |
| Nhóm DE-1 — STT 132 — Báo cáo tỷ lệ an toàn tài chính - Chi nh | 4 |
| Nhóm DE-1 — STT 133 — Báo cáo tỷ lệ an toàn tài chính - Chi nh | 2 |
| Nhóm DE-1 — STT 134 — Báo cáo tỷ lệ an toàn tài chính - Chi nh | 8 |
| Nhóm DE-1 — STT 135 — Báo cáo tỷ lệ an toàn tài chính - Chi nh | 4 |
| Nhóm DE-1 — STT 136 — Báo cáo tỷ lệ an toàn tài chính - Chi nh | 4 |
| Nhóm DE-1 — STT 137 — Báo cáo tỷ lệ an toàn tài chính - Chi nh | 4 |
| Nhóm DE-1 — STT 138 — Báo cáo tỷ lệ an toàn tài chính - Chi nh | 2 |
| Nhóm DE-1 — STT 139 — Báo cáo tỷ lệ an toàn tài chính - Chi nh | 3 |
| Nhóm DE-1 — STT 140 — Báo cáo tình hình hoạt động quý/năm - VP | 52 |

---

## TT

_Cập nhật 2026-07-22: thiết kế lại theo `DTM_TT_HLD.md` hiện hành (redesign Phương án B — 6 nhóm GROUP BY động) — nội dung bảng dưới đây thay thế hoàn toàn bản cũ (5 bảng, tên/cấu trúc không còn khớp thiết kế)._

**11 bảng flat** · **84 KPI unique**

---

### `datamart.tt_fct_inspection_team_activity_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Inspection Team Activity |
| **Bảng fact/operational** | `datamart.fct_inspection_team_activity` |
| **PK** | `—` |
| **Số dim join** | 2 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.cdr_dt_dim` | `calendar_dt_dim_id` | `cdr_dt_dim_id` | ✗ |
| Inspection Team Dimension | `datamart.inspection_team_dim` | `inspection_team_dim_id` | `inspection_team_dim_id` | ✗ (SCD4A) |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 1 — KPI cards Thống kê chung | 7 |
| Nhóm 2 — Biểu đồ Thống kê số vụ việc theo tháng | 3 |
| Nhóm 3 — Cơ cấu vi phạm theo loại hành vi | 2 |

---

### `datamart.tt_fct_examination_team_activity_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Examination Team Activity |
| **Bảng fact/operational** | `datamart.fct_examination_team_activity` |
| **PK** | `—` |
| **Số dim join** | 2 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.cdr_dt_dim` | `calendar_dt_dim_id` | `cdr_dt_dim_id` | ✗ |
| Examination Team Dimension | `datamart.examination_team_dim` | `examination_team_dim_id` | `examination_team_dim_id` | ✗ (SCD4A) |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 6 — KPI cards Thống kê chung Kiểm tra | 7 |
| Nhóm 7 — Biểu đồ xu hướng số cuộc kiểm tra theo tháng | 3 |
| Nhóm 8 — Cơ cấu kiểm tra theo loại hành vi | 2 |

---

### `datamart.tt_fct_inspection_team_target_activity_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Inspection Team Target Activity |
| **Bảng fact/operational** | `datamart.fct_inspection_team_target_activity` |
| **PK** | `—` |
| **Số dim join** | 3 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.cdr_dt_dim` | `calendar_dt_dim_id` | `cdr_dt_dim_id` | ✗ |
| Inspection Team Target Dimension | `datamart.inspection_team_target_dim` | `inspection_team_target_dim_id` | `inspection_team_target_dim_id` | ✗ |
| Inspection Team Dimension (cha) | `datamart.inspection_team_dim` | `inspection_team_dim_id` | `inspection_team_dim_id` | ✗ (SCD4A) |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 4 — Cơ cấu vi phạm theo đối tượng | 2 |

---

### `datamart.tt_fct_examination_team_target_activity_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Examination Team Target Activity |
| **Bảng fact/operational** | `datamart.fct_examination_team_target_activity` |
| **PK** | `—` |
| **Số dim join** | 3 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.cdr_dt_dim` | `calendar_dt_dim_id` | `cdr_dt_dim_id` | ✗ |
| Examination Team Target Dimension | `datamart.examination_team_target_dim` | `examination_team_target_dim_id` | `examination_team_target_dim_id` | ✗ |
| Examination Team Dimension (cha) | `datamart.examination_team_dim` | `examination_team_dim_id` | `examination_team_dim_id` | ✗ (SCD4A) |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 9 — Cơ cấu kiểm tra theo đối tượng | 2 |

---

### `datamart.tt_fct_penalty_decision_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Penalty Decision |
| **Bảng fact/operational** | `datamart.fct_penalty_decision` |
| **PK** | `—` |
| **Số dim join** | 2 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.cdr_dt_dim` | `calendar_dt_dim_id` | `cdr_dt_dim_id` | ✗ |
| Penalty Decision Dimension | `datamart.penalty_decision_dim` | `penalty_decision_dim_id` | `penalty_decision_dim_id` | ✗ |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 11 — KPI cards Thống kê chung Xử phạt | 5 |
| Nhóm 12 — Biểu đồ thống kê xử phạt theo tháng | 2 |

---

### `datamart.tt_fct_penalty_decision_subject_behavior_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Penalty Decision Subject Behavior |
| **Bảng fact/operational** | `datamart.fct_penalty_decision_subject_behavior` |
| **PK** | `—` |
| **Số dim join** | 4 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.cdr_dt_dim` | `calendar_dt_dim_id` | `cdr_dt_dim_id` | ✗ |
| Penalty Decision Subject Behavior Dimension | `datamart.penalty_decision_subject_behavior_dim` | `penalty_decision_subject_behavior_dim_id` | `penalty_decision_subject_behavior_dim_id` | ✗ |
| Penalty Decision Dimension | `datamart.penalty_decision_dim` | `penalty_decision_dim_id` | `penalty_decision_dim_id` | ✗ |
| Penalty Decision Subject Dimension | `datamart.penalty_decision_subject_dim` | `penalty_decision_subject_dim_id` | `penalty_decision_subject_dim_id` | ✗ |

> `Total_Fine_Amount` KHÔNG có trên bảng này (grain per-hành vi mịn hơn per-đối tượng — đặt measure sẽ fanout khi SUM). Xem Nhóm 20 / `tt_opr_penalty_decision_list_flat` để lấy đúng số tiền per-subject.

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 13 — Cơ cấu xử phạt theo loại hành vi | 2 |
| Nhóm 20 — Báo cáo hoạt động vi phạm trên TTCK (reuse) | 15 |

---

### `datamart.tt_fct_penalty_decision_subject_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `fact` |
| **Entity nguồn** | Fact Penalty Decision Subject |
| **Bảng fact/operational** | `datamart.fct_penalty_decision_subject` |
| **PK** | `—` |
| **Số dim join** | 3 |

**Joins (FK → PK)**

| Dimension Entity | Bảng Dim | FK (Fact) | PK (Dim) | SCD2 |
|-----------------|----------|-----------|----------|:----:|
| Calendar Date Dimension | `datamart.cdr_dt_dim` | `calendar_dt_dim_id` | `cdr_dt_dim_id` | ✗ |
| Penalty Decision Subject Dimension | `datamart.penalty_decision_subject_dim` | `penalty_decision_subject_dim_id` | `penalty_decision_subject_dim_id` | ✗ |
| Penalty Decision Dimension | `datamart.penalty_decision_dim` | `penalty_decision_dim_id` | `penalty_decision_dim_id` | ✗ |

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 14 — Cơ cấu xử phạt theo đối tượng | 2 |

---

### `datamart.tt_opr_inspection_case_list_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Operational Inspection Case List |
| **Bảng fact/operational** | `datamart.opr_inspection_case_list` |
| **PK** | `inspection_team_target_code` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 5 — Danh sách vụ việc Thanh tra | 5 |

---

### `datamart.tt_opr_examination_case_list_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Operational Examination Case List |
| **Bảng fact/operational** | `datamart.opr_examination_case_list` |
| **PK** | `examination_team_target_code` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 10 — Danh sách vụ việc Kiểm tra | 5 |

---

### `datamart.tt_opr_penalty_decision_list_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Operational Penalty Decision List |
| **Bảng fact/operational** | `datamart.opr_penalty_decision_list` |
| **PK** | `pd_subject_code` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 15 — Danh sách quyết định xử phạt | 5 |

---

### `datamart.tt_opr_petition_list_flat`

| Thuộc tính | Giá trị |
|------------|---------|
| **Loại** | `operational` |
| **Entity nguồn** | Operational Petition List |
| **Bảng fact/operational** | `datamart.opr_petition_list` |
| **PK** | `petition_code` |
| **Số dim join** | 0 |

_Không có dim join (operational / self-contained table). Serve cả KPI aggregate (Nhóm 16–18) lẫn danh sách chi tiết (Nhóm 19)._

**Nhóm KPI**

| Nhóm | Số KPI unique |
|------|:-------------:|
| Nhóm 16 — KPI card Tổng số đơn đã xử lý | 3 |
| Nhóm 17 — Biểu đồ Thống kê tình hình xử lý đơn thư | 1 |
| Nhóm 18 — Biểu đồ Cơ cấu theo loại đơn thư | 7 |
| Nhóm 19 — Danh sách đơn thư chi tiết | 4 |
