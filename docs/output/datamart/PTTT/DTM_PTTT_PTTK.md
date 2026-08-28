## 3.1.9 LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO Phân tích thị trường

### 3.1.9.1 Thông tin chung luồng đồng bộ

- Tên job:
- Nguồn dữ liệu (Hệ thống nguồn): MDDS, MSS, QLRR, IDS, SCMS, FMS, ECAT
- Cách thức truy xuất đồng bộ dữ liệu:
- Tần suất đồng bộ dữ liệu:
- Dung lượng dữ liệu sẽ thực hiện đồng bộ:
- Thời gian lưu trữ dữ liệu:
- Thư mục lưu trữ dữ liệu trên kho dữ liệu:

### 3.1.9.2 Luồng nghiệp vụ

#### 3.1.9.2.1 Nhóm thông tin Rủi ro thị trường

```mermaid
flowchart LR
    subgraph Staging
        MDDS_MarketInfor["MDDS.MarketInfor"]
        MDDS_StockInfor["MDDS.StockInfor"]
        MDDS_IDXInfor["MDDS.IDXInfor"]
        MSS_Trade_HOSE["MSS.Trade_HOSE"]
        MSS_Trade_HNX["MSS.Trade_HNX"]
        QLRR_RISK_INDICATOR["QLRR.RISK_INDICATOR"]
        QLRR_RISK_INDICATOR_VALUE["QLRR.RISK_INDICATOR_VALUE"]
        IDS_SECURITIES_OFFERING["IDS.SECURITIES_OFFERING"]
        IDS_SECURITIES_OFFERING_PLAN["IDS.SECURITIES_OFFERING_PLAN"]
        IDS_SECURITIES_OFFERING_RESULT["IDS.SECURITIES_OFFERING_RESULT"]
        SCMS_DISCLOSURE_SECURITIES_OFFERING["SCMS.DISCLOSURE_SECURITIES_OFFERING"]
        FMS_OFFERING["FMS.OFFERING"]
        ECAT_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end
    subgraph Atomic
        Market_Index_Snapshot["Market Index Snapshot"]
        Security_Trading_Snapshot["Security Trading Snapshot"]
        Security_Match_Log["Security Match Log"]
        Risk_Indicator["Risk Indicator"]
        Risk_Indicator_Value["Risk Indicator Value"]
        Public_Company_Securities_Offering["Public Company Securities Offering"]
        Public_Company_Securities_Offering_Plan["Public Company Securities Offering Plan"]
        Public_Company_Securities_Offering_Result["Public Company Securities Offering Result"]
        Securities_Company_Disclosure_Securities_Offering["Securities Company Disclosure Securities Offering"]
        Fund_Management_Company_Securities_Offering["Fund Management Company Securities Offering"]
        Calendar_Date["Calendar Date"]
    end
    subgraph Datamart
        fct_market_risk_snpst["Fact Market Risk Snapshot"]
        cdr_dt_dim["Calendar Date Dimension"]
    end
    MDDS_MarketInfor --> Market_Index_Snapshot
    MDDS_IDXInfor --> Market_Index_Snapshot
    MDDS_StockInfor --> Security_Trading_Snapshot
    MSS_Trade_HOSE --> Security_Match_Log
    MSS_Trade_HNX --> Security_Match_Log
    QLRR_RISK_INDICATOR --> Risk_Indicator
    QLRR_RISK_INDICATOR_VALUE --> Risk_Indicator_Value
    IDS_SECURITIES_OFFERING --> Public_Company_Securities_Offering
    IDS_SECURITIES_OFFERING_PLAN --> Public_Company_Securities_Offering_Plan
    IDS_SECURITIES_OFFERING_RESULT --> Public_Company_Securities_Offering_Result
    SCMS_DISCLOSURE_SECURITIES_OFFERING --> Securities_Company_Disclosure_Securities_Offering
    FMS_OFFERING --> Fund_Management_Company_Securities_Offering
    ECAT_HolidayInfo --> Calendar_Date
    Market_Index_Snapshot --> fct_market_risk_snpst
    Security_Trading_Snapshot --> fct_market_risk_snpst
    Security_Match_Log --> fct_market_risk_snpst
    Risk_Indicator --> fct_market_risk_snpst
    Risk_Indicator_Value --> fct_market_risk_snpst
    Public_Company_Securities_Offering --> fct_market_risk_snpst
    Public_Company_Securities_Offering_Plan --> fct_market_risk_snpst
    Public_Company_Securities_Offering_Result --> fct_market_risk_snpst
    Securities_Company_Disclosure_Securities_Offering --> fct_market_risk_snpst
    Fund_Management_Company_Securities_Offering --> fct_market_risk_snpst
    Calendar_Date --> cdr_dt_dim
    cdr_dt_dim --> fct_market_risk_snpst
```

**Mục đích:** Cung cấp dữ liệu chỉ số rủi ro hệ thống toàn thị trường (Systemic Risk Index) theo ngày snapshot, phục vụ Dashboard Giám sát rủi ro (Nhóm 1 & Nhóm 2).

**Mô tả luồng:**

Staging → Atomic:
- **Market Index Snapshot:** Bảng lưu thông tin chỉ số thị trường cuối ngày lấy thông tin từ bảng MDDS.MarketInfor và MDDS.IDXInfor
- **Security Trading Snapshot:** Bảng lưu thông tin thị trường chứng khoán cuối ngày lấy thông tin từ bảng MDDS.StockInfor
- **Security Match Log:** Bảng lưu chi tiết các lệnh khớp giao dịch lấy thông tin từ bảng MSS.Trade_HOSE và MSS.Trade_HNX
- **Risk Indicator:** Bảng lưu định nghĩa chỉ số rủi ro lấy thông tin từ bảng QLRR.RISK_INDICATOR
- **Risk Indicator Value:** Bảng lưu giá trị các chỉ số rủi ro lấy thông tin từ bảng QLRR.RISK_INDICATOR_VALUE
- **Public Company Securities Offering:** Bảng lưu thông tin đợt chào bán chứng khoán công ty đại chúng lấy thông tin từ bảng IDS.SECURITIES_OFFERING
- **Public Company Securities Offering Plan:** Bảng lưu phương án chào bán chứng khoán lấy thông tin từ bảng IDS.SECURITIES_OFFERING_PLAN
- **Public Company Securities Offering Result:** Bảng lưu kết quả chào bán chứng khoán lấy thông tin từ bảng IDS.SECURITIES_OFFERING_RESULT
- **Securities Company Disclosure Securities Offering:** Bảng lưu công bố thông tin chào bán chứng khoán CTCK lấy thông tin từ bảng SCMS.DISCLOSURE_SECURITIES_OFFERING
- **Fund Management Company Securities Offering:** Bảng lưu thông tin chào bán CCQ của công ty quản lý quỹ lấy thông tin từ bảng FMS.OFFERING
- **Calendar Date:** Bảng lưu thông tin lịch ngày lấy thông tin từ bảng ECAT.ECAT_29_HolidayInfo

Atomic → Datamart:
- **Fact Market Risk Snapshot:** Bảng sự kiện tổng hợp chỉ số rủi ro hệ thống toàn thị trường theo ngày snapshot, bao gồm các hệ số đóng góp rủi ro và biến động vĩ mô.
- **Calendar Date Dimension:** Bảng lưu thông tin thời gian.

---

#### 3.1.9.2.2 Nhóm thông tin Rủi ro ngành

```mermaid
flowchart LR
    subgraph Staging
        MDDS_StockInfor["MDDS.StockInfor"]
        MSS_Trade_HOSE["MSS.Trade_HOSE"]
        MSS_Trade_HNX["MSS.Trade_HNX"]
        IDS_data["IDS.data"]
        IDS_report_catalog["IDS.report_catalog"]
        IDS_company_data["IDS.company_data"]
        IDS_company_detail["IDS.company_detail"]
        IDS_categories["IDS.categories"]
        ECAT_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end
    subgraph Atomic
        Security_Trading_Snapshot["Security Trading Snapshot"]
        Security_Match_Log["Security Match Log"]
        Public_Company_Financial_Report_Value["Public Company Financial Report Value"]
        Public_Company["Public Company"]
        Calendar_Date["Calendar Date"]
    end
    subgraph Datamart
        fct_sector_risk_snpst["Fact Sector Risk Snapshot"]
        cdr_dt_dim["Calendar Date Dimension"]
        industry_dim["Industry Dimension"]
    end
    MDDS_StockInfor --> Security_Trading_Snapshot
    MSS_Trade_HOSE --> Security_Match_Log
    MSS_Trade_HNX --> Security_Match_Log
    IDS_data --> Public_Company_Financial_Report_Value
    IDS_report_catalog --> Public_Company_Financial_Report_Value
    IDS_company_data --> Public_Company_Financial_Report_Value
    IDS_company_detail --> Public_Company
    IDS_categories --> Public_Company
    ECAT_HolidayInfo --> Calendar_Date
    Security_Trading_Snapshot --> fct_sector_risk_snpst
    Security_Match_Log --> fct_sector_risk_snpst
    Public_Company_Financial_Report_Value --> fct_sector_risk_snpst
    Public_Company --> fct_sector_risk_snpst
    Public_Company --> industry_dim
    Calendar_Date --> cdr_dt_dim
    cdr_dt_dim --> fct_sector_risk_snpst
    industry_dim --> fct_sector_risk_snpst
```

**Mục đích:** Cung cấp dữ liệu rủi ro và áp lực theo từng nhóm ngành kinh tế (Sector Stress), phục vụ Dashboard Sức khỏe thị trường và vĩ mô (Nhóm 7).

**Mô tả luồng:**

Staging → Atomic:
- **Security Trading Snapshot:** Bảng lưu thông tin giao dịch chứng khoán cuối ngày lấy thông tin từ bảng MDDS.StockInfor
- **Security Match Log:** Bảng lưu chi tiết lệnh khớp lấy thông tin từ bảng MSS.Trade_HOSE và MSS.Trade_HNX
- **Public Company Financial Report Value:** Bảng lưu giá trị chỉ tiêu báo cáo tài chính lấy thông tin từ các bảng IDS.data, IDS.report_catalog, IDS.company_data
- **Public Company:** Bảng lưu thông tin công ty đại chúng và phân loại ngành lấy thông tin từ bảng IDS.company_detail và IDS.categories
- **Calendar Date:** Bảng lưu thông tin lịch ngày lấy thông tin từ bảng ECAT.ECAT_29_HolidayInfo

Atomic → Datamart:
- **Fact Sector Risk Snapshot:** Bảng sự kiện tổng hợp rủi ro ngành theo ngày, gồm chỉ số định giá P/E, P/B, áp lực nợ và thanh khoản theo ngành.
- **Industry Dimension:** Bảng lưu danh mục phân ngành kinh tế.
- **Calendar Date Dimension:** Bảng lưu thông tin thời gian.

---

#### 3.1.9.2.3 Nhóm thông tin Quy mô lệnh per mã CK

```mermaid
flowchart LR
    subgraph Staging
        MSS_Trade_HOSE["MSS.Trade_HOSE"]
        MSS_Trade_HNX["MSS.Trade_HNX"]
        ECAT_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end
    subgraph Atomic
        Security_Match_Log["Security Match Log"]
        Calendar_Date["Calendar Date"]
    end
    subgraph Datamart
        fct_order_size_snpst["Fact Order Size Snapshot"]
        cdr_dt_dim["Calendar Date Dimension"]
    end
    MSS_Trade_HOSE --> Security_Match_Log
    MSS_Trade_HNX --> Security_Match_Log
    ECAT_HolidayInfo --> Calendar_Date
    Security_Match_Log --> fct_order_size_snpst
    Calendar_Date --> cdr_dt_dim
    cdr_dt_dim --> fct_order_size_snpst
```

**Mục đích:** Cung cấp dữ liệu phân bổ thanh khoản theo quy mô lệnh giao dịch (lệnh lớn, vừa, nhỏ) của từng mã chứng khoán, phục vụ Dashboard Thanh khoản và đòn bẩy (Nhóm 11).

**Mô tả luồng:**

Staging → Atomic:
- **Security Match Log:** Bảng lưu chi tiết từng lệnh khớp chứng khoán lấy thông tin từ bảng MSS.Trade_HOSE và MSS.Trade_HNX
- **Calendar Date:** Bảng lưu thông tin lịch ngày lấy thông tin từ bảng ECAT.ECAT_29_HolidayInfo

Atomic → Datamart:
- **Fact Order Size Snapshot:** Bảng sự kiện phân tích cấu trúc quy mô lệnh khớp theo mã chứng khoán và ngày giao dịch.
- **Calendar Date Dimension:** Bảng lưu thông tin thời gian.

---

#### 3.1.9.2.4 Nhóm thông tin Dòng tiền nhà đầu tư

```mermaid
flowchart LR
    subgraph Staging
        MSS_Trade_HOSE["MSS.Trade_HOSE"]
        MSS_Trade_HNX["MSS.Trade_HNX"]
        ECAT_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end
    subgraph Atomic
        Security_Match_Log["Security Match Log"]
        Calendar_Date["Calendar Date"]
    end
    subgraph Datamart
        fct_investor_flow_snpst["Fact Investor Flow Snapshot"]
        investor_group_dim["Investor Group Dimension"]
        cdr_dt_dim["Calendar Date Dimension"]
    end
    MSS_Trade_HOSE --> Security_Match_Log
    MSS_Trade_HNX --> Security_Match_Log
    ECAT_HolidayInfo --> Calendar_Date
    Security_Match_Log --> fct_investor_flow_snpst
    Security_Match_Log --> investor_group_dim
    Calendar_Date --> cdr_dt_dim
    cdr_dt_dim --> fct_investor_flow_snpst
    investor_group_dim --> fct_investor_flow_snpst
```

**Mục đích:** Cung cấp dữ liệu dòng tiền theo từng nhóm nhà đầu tư (cá nhân trong nước, tổ chức trong nước, cá nhân nước ngoài, tổ chức nước ngoài, tự doanh), phục vụ Dashboard Dòng tiền và cơ cấu nhà đầu tư (Nhóm 13, 14, 15).

**Mô tả luồng:**

Staging → Atomic:
- **Security Match Log:** Bảng lưu chi tiết khớp lệnh chứng khoán theo loại tài khoản nhà đầu tư lấy thông tin từ bảng MSS.Trade_HOSE và MSS.Trade_HNX
- **Calendar Date:** Bảng lưu thông tin lịch ngày lấy thông tin từ bảng ECAT.ECAT_29_HolidayInfo

Atomic → Datamart:
- **Fact Investor Flow Snapshot:** Bảng sự kiện tổng hợp giá trị và khối lượng giao dịch mua/bán theo nhóm nhà đầu tư theo ngày.
- **Investor Group Dimension:** Bảng lưu danh mục phân nhóm nhà đầu tư.
- **Calendar Date Dimension:** Bảng lưu thông tin thời gian.

---

#### 3.1.9.2.5 Nhóm thông tin Top giao dịch NĐTNN per mã CK

```mermaid
flowchart LR
    subgraph Staging
        MSS_Trade_HOSE["MSS.Trade_HOSE"]
        MSS_Trade_HNX["MSS.Trade_HNX"]
        ECAT_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end
    subgraph Atomic
        Security_Match_Log["Security Match Log"]
        Calendar_Date["Calendar Date"]
    end
    subgraph Datamart
        fct_foreign_net_trade_snpst["Fact Foreign Net Trade Snapshot"]
        cdr_dt_dim["Calendar Date Dimension"]
    end
    MSS_Trade_HOSE --> Security_Match_Log
    MSS_Trade_HNX --> Security_Match_Log
    ECAT_HolidayInfo --> Calendar_Date
    Security_Match_Log --> fct_foreign_net_trade_snpst
    Calendar_Date --> cdr_dt_dim
    cdr_dt_dim --> fct_foreign_net_trade_snpst
```

**Mục đích:** Cung cấp bảng xếp hạng top mua ròng, bán ròng của nhà đầu tư nước ngoài theo từng mã chứng khoán, phục vụ Dashboard Dòng tiền và cơ cấu nhà đầu tư (Nhóm 16).

**Mô tả luồng:**

Staging → Atomic:
- **Security Match Log:** Bảng lưu chi tiết giao dịch khớp lệnh của nhà đầu tư nước ngoài lấy thông tin từ bảng MSS.Trade_HOSE và MSS.Trade_HNX
- **Calendar Date:** Bảng lưu thông tin lịch ngày lấy thông tin từ bảng ECAT.ECAT_29_HolidayInfo

Atomic → Datamart:
- **Fact Foreign Net Trade Snapshot:** Bảng sự kiện tổng hợp giá trị mua ròng, bán ròng và khối lượng giao dịch của khối ngoại theo từng mã CK và ngày.
- **Calendar Date Dimension:** Bảng lưu thông tin thời gian.

---

#### 3.1.9.2.6 Nhóm thông tin Top giao dịch tự doanh per mã CK

```mermaid
flowchart LR
    subgraph Staging
        MSS_Trade_HOSE["MSS.Trade_HOSE"]
        MSS_Trade_HNX["MSS.Trade_HNX"]
        ECAT_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end
    subgraph Atomic
        Security_Match_Log["Security Match Log"]
        Calendar_Date["Calendar Date"]
    end
    subgraph Datamart
        fct_proprietary_net_trade_snpst["Fact Proprietary Net Trade Snapshot"]
        cdr_dt_dim["Calendar Date Dimension"]
    end
    MSS_Trade_HOSE --> Security_Match_Log
    MSS_Trade_HNX --> Security_Match_Log
    ECAT_HolidayInfo --> Calendar_Date
    Security_Match_Log --> fct_proprietary_net_trade_snpst
    Calendar_Date --> cdr_dt_dim
    cdr_dt_dim --> fct_proprietary_net_trade_snpst
```

**Mục đích:** Cung cấp bảng xếp hạng top mua ròng, bán ròng của khối tự doanh CTCK theo từng mã chứng khoán, phục vụ Dashboard Dòng tiền và cơ cấu nhà đầu tư (Nhóm 17).

**Mô tả luồng:**

Staging → Atomic:
- **Security Match Log:** Bảng lưu chi tiết giao dịch khớp lệnh tự doanh CTCK lấy thông tin từ bảng MSS.Trade_HOSE và MSS.Trade_HNX
- **Calendar Date:** Bảng lưu thông tin lịch ngày lấy thông tin từ bảng ECAT.ECAT_29_HolidayInfo

Atomic → Datamart:
- **Fact Proprietary Net Trade Snapshot:** Bảng sự kiện tổng hợp giá trị mua ròng, bán ròng và khối lượng giao dịch của khối tự doanh theo từng mã CK và ngày.
- **Calendar Date Dimension:** Bảng lưu thông tin thời gian.

---

#### 3.1.9.2.7 Nhóm thông tin Cơ cấu nợ vay trái phiếu theo ngành

```mermaid
flowchart LR
    subgraph Staging
        MSS_Trade_HOSE["MSS.Trade_HOSE"]
        MDDS_StockInfor["MDDS.StockInfor"]
        IDS_categories["IDS.categories"]
        IDS_company_profiles["IDS.company_profiles"]
        ECAT_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end
    subgraph Atomic
        Corp_Bond_Match_Log["Corporate Bond Match Log"]
        Corp_Bond_Trading_Snapshot["Corporate Bond Trading Snapshot"]
        Public_Company["Public Company"]
        Calendar_Date["Calendar Date"]
    end
    subgraph Datamart
        fct_corporate_bond_sector_snpst["Fact Corporate Bond Sector Snapshot"]
        corp_bond_industry_dim["Corp Bond Industry Dimension"]
        cdr_dt_dim["Calendar Date Dimension"]
    end
    MSS_Trade_HOSE --> Corp_Bond_Match_Log
    MDDS_StockInfor --> Corp_Bond_Trading_Snapshot
    IDS_categories --> Public_Company
    IDS_company_profiles --> Public_Company
    ECAT_HolidayInfo --> Calendar_Date
    Corp_Bond_Match_Log --> fct_corporate_bond_sector_snpst
    Corp_Bond_Trading_Snapshot --> fct_corporate_bond_sector_snpst
    Public_Company --> fct_corporate_bond_sector_snpst
    Public_Company --> corp_bond_industry_dim
    Calendar_Date --> cdr_dt_dim
    corp_bond_industry_dim --> fct_corporate_bond_sector_snpst
    cdr_dt_dim --> fct_corporate_bond_sector_snpst
```

**Mục đích:** Cung cấp dữ liệu tổng hợp cơ cấu nợ vay trái phiếu doanh nghiệp, áp lực đáo hạn và lãi suất theo ngành kinh tế, phục vụ Dashboard Trái phiếu doanh nghiệp (Nhóm 18, 19, 20).

**Mô tả luồng:**

Staging → Atomic:
- **Corporate Bond Match Log:** Bảng lưu chi tiết khớp lệnh trái phiếu doanh nghiệp lấy thông tin từ bảng MSS.Trade_HOSE
- **Corporate Bond Trading Snapshot:** Bảng lưu thông tin giao dịch TPDN cuối ngày lấy thông tin từ bảng MDDS.StockInfor
- **Public Company:** Bảng lưu thông tin tổ chức phát hành và phân ngành lấy thông tin từ bảng IDS.categories và IDS.company_profiles
- **Calendar Date:** Bảng lưu thông tin lịch ngày lấy thông tin từ bảng ECAT.ECAT_29_HolidayInfo

Atomic → Datamart:
- **Fact Corporate Bond Sector Snapshot:** Bảng sự kiện tổng hợp quy mô nợ vay trái phiếu, dư nợ theo ngành và kỳ đáo hạn.
- **Corp Bond Industry Dimension:** Bảng lưu danh mục ngành nghề của tổ chức phát hành TPDN.
- **Calendar Date Dimension:** Bảng lưu thông tin thời gian.

---

#### 3.1.9.2.8 Nhóm thông tin Danh mục tổ chức phát hành cần giám sát tín dụng

```mermaid
flowchart LR
    subgraph Staging
        MDDS_StockInfor["MDDS.StockInfor"]
        IDS_company_profiles["IDS.company_profiles"]
        IDS_categories["IDS.categories"]
        IDS_data["IDS.data"]
        IDS_report_catalog["IDS.report_catalog"]
        IDS_company_data["IDS.company_data"]
    end
    subgraph Atomic
        Corp_Bond_Trading_Snapshot["Corporate Bond Trading Snapshot"]
        Public_Company["Public Company"]
        Public_Company_Financial_Report_Value["Public Company Financial Report Value"]
    end
    subgraph Datamart
        opr_corporate_bond_issuer_credit_monitor["Operational Corporate Bond Issuer Credit Monitor"]
    end
    MDDS_StockInfor --> Corp_Bond_Trading_Snapshot
    IDS_company_profiles --> Public_Company
    IDS_categories --> Public_Company
    IDS_data --> Public_Company_Financial_Report_Value
    IDS_report_catalog --> Public_Company_Financial_Report_Value
    IDS_company_data --> Public_Company_Financial_Report_Value
    Corp_Bond_Trading_Snapshot --> opr_corporate_bond_issuer_credit_monitor
    Public_Company --> opr_corporate_bond_issuer_credit_monitor
    Public_Company_Financial_Report_Value --> opr_corporate_bond_issuer_credit_monitor
```

**Mục đích:** Cung cấp bảng danh sách theo dõi sức khỏe tài chính và rủi ro tín dụng của các tổ chức phát hành trái phiếu doanh nghiệp, phục vụ Dashboard Trái phiếu doanh nghiệp (Nhóm 21).

**Mô tả luồng:**

Staging → Atomic:
- **Corporate Bond Trading Snapshot:** Bảng lưu thông tin giao dịch trái phiếu doanh nghiệp lấy thông tin từ bảng MDDS.StockInfor
- **Public Company:** Bảng lưu thông tin công ty đại chúng phát hành trái phiếu lấy thông tin từ bảng IDS.company_profiles và IDS.categories
- **Public Company Financial Report Value:** Bảng lưu chỉ tiêu tài chính (hệ số nợ, khả năng thanh toán) lấy thông tin từ các bảng IDS.data, IDS.report_catalog, IDS.company_data

Atomic → Datamart:
- **Operational Corporate Bond Issuer Credit Monitor:** Bảng tác nghiệp lưu danh sách các tổ chức phát hành trái phiếu có dấu hiệu rủi ro tín dụng ở trạng thái mới nhất.

---

#### 3.1.9.2.9 Nhóm thông tin Bộ chỉ tiêu an toàn CTCK

```mermaid
flowchart LR
    subgraph Staging
        SCMS_BC_BAO_CAO_GT["SCMS.BC_BAO_CAO_GT"]
        SCMS_DM_CHI_TIEU["SCMS.DM_CHI_TIEU"]
        SCMS_BC_THANH_VIEN["SCMS.BC_THANH_VIEN"]
        SCMS_BM_BAO_CAO["SCMS.BM_BAO_CAO"]
        SCMS_BM_BAO_CAO_HANG["SCMS.BM_BAO_CAO_HANG"]
        SCMS_BM_BAO_CAO_COT["SCMS.BM_BAO_CAO_COT"]
        ECAT_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end
    subgraph Atomic
        Member_Report_Indicator_Value["Member Report Indicator Value"]
        Securities_Company["Securities Company"]
        Calendar_Date["Calendar Date"]
    end
    subgraph Datamart
        fct_mbr_sfty_snpst["Fact Member Safety Snapshot"]
        cdr_dt_dim["Calendar Date Dimension"]
    end
    SCMS_BC_BAO_CAO_GT --> Member_Report_Indicator_Value
    SCMS_DM_CHI_TIEU --> Member_Report_Indicator_Value
    SCMS_BC_THANH_VIEN --> Member_Report_Indicator_Value
    SCMS_BM_BAO_CAO --> Member_Report_Indicator_Value
    SCMS_BM_BAO_CAO_HANG --> Member_Report_Indicator_Value
    SCMS_BM_BAO_CAO_COT --> Member_Report_Indicator_Value
    SCMS_BC_THANH_VIEN --> Securities_Company
    ECAT_HolidayInfo --> Calendar_Date
    Member_Report_Indicator_Value --> fct_mbr_sfty_snpst
    Securities_Company --> fct_mbr_sfty_snpst
    Calendar_Date --> cdr_dt_dim
    cdr_dt_dim --> fct_mbr_sfty_snpst
```

**Mục đích:** Cung cấp dữ liệu tổng hợp các chỉ tiêu an toàn tài chính và tỷ lệ an toàn vốn khả dụng toàn hệ thống CTCK, phục vụ Dashboard An toàn CTCK (Nhóm 22, 23, 24).

**Mô tả luồng:**

Staging → Atomic:
- **Member Report Indicator Value:** Bảng lưu giá trị các chỉ tiêu báo cáo định kỳ của CTCK lấy thông tin từ các bảng SCMS.BC_BAO_CAO_GT, SCMS.DM_CHI_TIEU, SCMS.BC_THANH_VIEN, SCMS.BM_BAO_CAO, SCMS.BM_BAO_CAO_HANG, SCMS.BM_BAO_CAO_COT
- **Securities Company:** Bảng lưu thông tin công ty chứng khoán lấy thông tin từ bảng SCMS.BC_THANH_VIEN
- **Calendar Date:** Bảng lưu thông tin lịch ngày lấy thông tin từ bảng ECAT.ECAT_29_HolidayInfo

Atomic → Datamart:
- **Fact Member Safety Snapshot:** Bảng sự kiện tổng hợp chỉ tiêu an toàn tài chính toàn hệ thống CTCK theo kỳ snapshot.
- **Calendar Date Dimension:** Bảng lưu thông tin thời gian.

---

#### 3.1.9.2.10 Nhóm thông tin Chỉ tiêu an toàn per CTCK

```mermaid
flowchart LR
    subgraph Staging
        SCMS_BC_BAO_CAO_GT["SCMS.BC_BAO_CAO_GT"]
        SCMS_DM_CHI_TIEU["SCMS.DM_CHI_TIEU"]
        SCMS_BC_THANH_VIEN["SCMS.BC_THANH_VIEN"]
        ECAT_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end
    subgraph Atomic
        Member_Report_Indicator_Value["Member Report Indicator Value"]
        Securities_Company["Securities Company"]
        Calendar_Date["Calendar Date"]
    end
    subgraph Datamart
        fct_mbr_sfty_per_mbr_snpst["Fact Member Safety Per Member Snapshot"]
        scr_co_dim["Securities Company Dimension"]
        cdr_dt_dim["Calendar Date Dimension"]
    end
    SCMS_BC_BAO_CAO_GT --> Member_Report_Indicator_Value
    SCMS_DM_CHI_TIEU --> Member_Report_Indicator_Value
    SCMS_BC_THANH_VIEN --> Member_Report_Indicator_Value
    SCMS_BC_THANH_VIEN --> Securities_Company
    ECAT_HolidayInfo --> Calendar_Date
    Member_Report_Indicator_Value --> fct_mbr_sfty_per_mbr_snpst
    Securities_Company --> fct_mbr_sfty_per_mbr_snpst
    Securities_Company --> scr_co_dim
    Calendar_Date --> cdr_dt_dim
    scr_co_dim --> fct_mbr_sfty_per_mbr_snpst
    cdr_dt_dim --> fct_mbr_sfty_per_mbr_snpst
```

**Mục đích:** Cung cấp dữ liệu chi tiết các chỉ tiêu an toàn tài chính, tỷ lệ an toàn vốn khả dụng và dư nợ margin của từng CTCK, phục vụ Dashboard An toàn CTCK (Nhóm 25).

**Mô tả luồng:**

Staging → Atomic:
- **Member Report Indicator Value:** Bảng lưu giá trị chỉ tiêu an toàn tài chính lấy thông tin từ các bảng SCMS.BC_BAO_CAO_GT, SCMS.DM_CHI_TIEU, SCMS.BC_THANH_VIEN
- **Securities Company:** Bảng lưu thông tin định danh CTCK lấy thông tin từ bảng SCMS.BC_THANH_VIEN
- **Calendar Date:** Bảng lưu thông tin lịch ngày lấy thông tin từ bảng ECAT.ECAT_29_HolidayInfo

Atomic → Datamart:
- **Fact Member Safety Per Member Snapshot:** Bảng sự kiện lưu chỉ tiêu an toàn tài chính chi tiết của từng công ty chứng khoán theo kỳ snapshot.
- **Securities Company Dimension:** Bảng lưu thông tin chiều công ty chứng khoán.
- **Calendar Date Dimension:** Bảng lưu thông tin thời gian.
