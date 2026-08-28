## 3.1.6 LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO Giám sát Thị trường

### 3.1.6.1 Thông tin chung luồng đồng bộ

- Tên job:
- Nguồn dữ liệu (Hệ thống nguồn): MDDS, OrderTrade, IDS, ECAT
- Cách thức truy xuất đồng bộ dữ liệu:
- Tần suất đồng bộ dữ liệu:
- Dung lượng dữ liệu sẽ thực hiện đồng bộ:
- Thời gian lưu trữ dữ liệu:
- Thư mục lưu trữ dữ liệu trên kho dữ liệu:

### 3.1.6.2 Luồng nghiệp vụ

#### 3.1.6.2.1 Nhóm thông tin Security Daily Market

```mermaid
flowchart LR
    subgraph Staging
        MDDS_StockInfor["MDDS.StockInfor"]
        OrderTrade_Trade_HOSE["OrderTrade.Trade_HOSE"]
        OrderTrade_Trade_HNX["OrderTrade.Trade_HNX"]
        IDS_data_BCTC["IDS.data_BCTC"]
        ECAT_Security["ECAT.Security"]
        IDS_company_profiles["IDS.company_profiles"]
    end
    subgraph Atomic
        Security_Trading_Snapshot["Security Trading Snapshot"]
        Securities_Trade["Securities Trade"]
        Public_Company_Financial_Report_Value["Public Company Financial Report Value"]
        Security["Security"]
        Public_Company["Public Company"]
    end
    subgraph Datamart
        fct_sec_dly_mkt_smy["Fact Security Daily Market Summary"]
        sec_tdg_snpst_dim["Security Trading Snapshot Dimension"]
        pblc_co_dim["Public Company Dimension"]
        cdr_dt_dim["Calendar Date Dimension"]
    end
    MDDS_StockInfor --> Security_Trading_Snapshot
    OrderTrade_Trade_HOSE --> Securities_Trade
    OrderTrade_Trade_HNX --> Securities_Trade
    IDS_data_BCTC --> Public_Company_Financial_Report_Value
    ECAT_Security --> Security
    IDS_company_profiles --> Public_Company
    Security_Trading_Snapshot --> fct_sec_dly_mkt_smy
    Securities_Trade --> fct_sec_dly_mkt_smy
    Public_Company_Financial_Report_Value --> fct_sec_dly_mkt_smy
    Security --> sec_tdg_snpst_dim
    Public_Company --> pblc_co_dim
    sec_tdg_snpst_dim --> fct_sec_dly_mkt_smy
    pblc_co_dim --> fct_sec_dly_mkt_smy
    cdr_dt_dim --> fct_sec_dly_mkt_smy
```

**Mục đích:** Cung cấp dữ liệu thị trường chứng khoán cuối ngày (EOD) theo mã CK và ngày giao dịch, phục vụ bảng `Fact Security Daily Market Summary` dùng cho toàn bộ các nhóm báo cáo cổ phiếu (Nhóm 1, 3, 6–27 và STT 49).

**Mô tả luồng:**

Staging → Atomic:
- **Security Trading Snapshot:** Bảng lưu thông tin thị trường chứng khoán cuối ngày (giá, khối lượng, trạng thái) lấy thông tin từ bảng MDDS.StockInfor
- **Securities Trade:** Bảng lưu chi tiết từng lệnh khớp giao dịch chứng khoán lấy thông tin từ bảng OrderTrade.Trade_HOSE, kết hợp dữ liệu khớp lệnh sàn HNX từ bảng OrderTrade.Trade_HNX
- **Public Company Financial Report Value:** Bảng lưu giá trị từng chỉ tiêu báo cáo tài chính của công ty đại chúng lấy thông tin từ bảng IDS.data_BCTC
- **Security:** Bảng lưu thông tin định danh chứng khoán lấy thông tin từ bảng ECAT.Security
- **Public Company:** Bảng lưu thông tin công ty đại chúng (ngành, mã cổ phiếu) lấy thông tin từ bảng IDS.company_profiles

Atomic → Datamart:
- **Security Trading Snapshot Dimension:** Bảng lưu thông tin mã chứng khoán phục vụ slicer Mã CK, Sàn, Loại CK và Chỉ số. Áp dụng SCD2.
- **Public Company Dimension:** Bảng lưu thông tin phân loại ngành kinh tế của cổ phiếu (10 ngành IDS cấp 1) phục vụ slicer Ngành. Áp dụng SCD2.
- **Calendar Date Dimension:** Bảng lưu thông tin lịch ngày giao dịch phục vụ slicer Ngày, Tháng, Quý, Năm.
- **Fact Security Daily Market Summary:** Bảng sự kiện tổng hợp thông tin thị trường chứng khoán cuối ngày theo mã CK và ngày giao dịch, bao gồm giá, khối lượng, giá trị giao dịch, giao dịch nước ngoài, phái sinh và chỉ tiêu tài chính.

---

#### 3.1.6.2.2 Nhóm thông tin Corporate Bond Daily Market

```mermaid
flowchart LR
    subgraph Staging
        MDDS_CorpBondInfor["MDDS.CorpBondInfor"]
        OrderTrade_Trade_HOSE_BDO["OrderTrade.Trade_HOSE_BDO"]
        IDS_company_profiles["IDS.company_profiles"]
    end
    subgraph Atomic
        Corporate_Bond_Trading_Snapshot["Corporate Bond Trading Snapshot"]
        Securities_Trade["Securities Trade"]
        Public_Company["Public Company"]
    end
    subgraph Datamart
        fct_cb_dly_mkt_smy["Fact Corporate Bond Daily Market Summary"]
        cb_tdg_snpst_dim["Corporate Bond Trading Snapshot Dimension"]
        cb_tdg_snpst_idy_dim["Corporate Bond Trading Snapshot Industry Dimension"]
        cdr_dt_dim["Calendar Date Dimension"]
    end
    MDDS_CorpBondInfor --> Corporate_Bond_Trading_Snapshot
    OrderTrade_Trade_HOSE_BDO --> Securities_Trade
    IDS_company_profiles --> Public_Company
    Corporate_Bond_Trading_Snapshot --> fct_cb_dly_mkt_smy
    Securities_Trade --> fct_cb_dly_mkt_smy
    Public_Company --> cb_tdg_snpst_dim
    Public_Company --> cb_tdg_snpst_idy_dim
    cb_tdg_snpst_dim --> fct_cb_dly_mkt_smy
    cb_tdg_snpst_idy_dim --> fct_cb_dly_mkt_smy
    cdr_dt_dim --> fct_cb_dly_mkt_smy
```

**Mục đích:** Cung cấp dữ liệu thị trường trái phiếu doanh nghiệp niêm yết cuối ngày theo mã TP và ngày giao dịch, phục vụ bảng `Fact Corporate Bond Daily Market Summary` dùng cho Nhóm 2 (Bảng số liệu Trái phiếu DN).

**Mô tả luồng:**

Staging → Atomic:
- **Corporate Bond Trading Snapshot:** Bảng lưu thông tin thị trường trái phiếu doanh nghiệp cuối ngày (giá tham chiếu, giá đóng cửa) lấy thông tin từ bảng MDDS.CorpBondInfor
- **Securities Trade:** Bảng lưu chi tiết khớp lệnh giao dịch trái phiếu DN (market = BDO) lấy thông tin từ bảng OrderTrade.Trade_HOSE_BDO
- **Public Company:** Bảng lưu thông tin công ty đại chúng gồm ngành kinh tế và mã trái phiếu lấy thông tin từ bảng IDS.company_profiles

Atomic → Datamart:
- **Corporate Bond Trading Snapshot Dimension:** Bảng lưu thông tin tổ chức phát hành trái phiếu DN phục vụ slicer Mã TP và Tên nhà phát hành. Áp dụng SCD2.
- **Corporate Bond Trading Snapshot Industry Dimension:** Bảng lưu thông tin phân loại ngành kinh tế của tổ chức phát hành TPDN (10 ngành IDS cấp 1) phục vụ slicer Ngành TPDN. Áp dụng SCD2.
- **Calendar Date Dimension:** Bảng lưu thông tin lịch ngày giao dịch phục vụ slicer Ngày, Tháng, Quý, Năm.
- **Fact Corporate Bond Daily Market Summary:** Bảng sự kiện tổng hợp thông tin thị trường trái phiếu doanh nghiệp cuối ngày theo mã TP và ngày giao dịch, bao gồm giá, khối lượng, giá trị giao dịch và doanh thu thuần.

---

#### 3.1.6.2.3 Nhóm thông tin Stock Holder Ownership

```mermaid
flowchart LR
    subgraph Staging
        IDS_stock_holders["IDS.stock_holders"]
        IDS_stock_controls["IDS.stock_controls"]
    end
    subgraph Atomic
        Stock_Holder["Stock Holder"]
        Stock_Control["Stock Control"]
    end
    subgraph Datamart
        stk_hld_own_prfl["Stock Holder Ownership Profile"]
    end
    IDS_stock_holders --> Stock_Holder
    IDS_stock_controls --> Stock_Control
    Stock_Holder --> stk_hld_own_prfl
    Stock_Control --> stk_hld_own_prfl
```

**Mục đích:** Cung cấp thông tin sở hữu cổ đông và người nội bộ theo từng công ty đại chúng, phục vụ bảng `Stock Holder Ownership Profile` dùng cho STT 47 (Sở hữu và giao dịch nội bộ).

**Mô tả luồng:**

Staging → Atomic:
- **Stock Holder:** Bảng lưu thông tin từng cổ đông (tên, loại, tỷ lệ sở hữu, cờ nước ngoài, cờ người nội bộ) lấy thông tin từ bảng IDS.stock_holders
- **Stock Control:** Bảng lưu thông tin hạn chế chuyển nhượng cổ phần lấy thông tin từ bảng IDS.stock_controls

Atomic → Datamart:
- **Stock Holder Ownership Profile:** Bảng tác nghiệp lưu danh sách cổ đông và thông tin sở hữu của từng công ty đại chúng ở trạng thái mới nhất, phục vụ tra cứu sở hữu nội bộ và cổ đông lớn.
