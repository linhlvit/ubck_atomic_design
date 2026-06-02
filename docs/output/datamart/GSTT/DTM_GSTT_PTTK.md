## 3.2.3 Luồng đồng bộ dữ liệu cho nhóm báo cáo Giám sát thị trường

### 3.2.3.1 Thông tin chung luồng đồng bộ

- Tên job:
- Nguồn dữ liệu (hệ thống nguồn): MDDS, OrderTrade, IDS, ECAT
- Cách thức truy xuất đồng bộ dữ liệu:
- Tần suất đồng bộ dữ liệu:
- Dung lượng dữ liệu sẽ thực hiện đồng bộ:
- Thời gian lưu trữ dữ liệu:
- Thư mục lưu trữ dữ liệu trên kho dữ liệu:

### 3.2.3.2 Luồng nghiệp vụ

#### 3.2.3.2.1 Nhóm thông tin Security Daily Market

**Mục đích:** Cung cấp dữ liệu thị trường chứng khoán cuối ngày (EOD) theo mã CK và ngày giao dịch, phục vụ bảng `Fact Security Daily Market Summary` dùng cho toàn bộ các nhóm báo cáo cổ phiếu (Nhóm 1, 3, 6–27 và STT 49).

```mermaid
flowchart LR
    subgraph Staging
        MDDS_StockInfor["MDDS StockInfor"]
        OrderTrade_Trade_HOSE["OrderTrade Trade HOSE"]
        OrderTrade_Trade_HNX["OrderTrade Trade HNX"]
        IDS_data_BCTC["IDS data BCTC"]
        ECAT_Security["ECAT Security"]
        IDS_company_profiles["IDS company profiles"]
    end
    subgraph Atomic
        A1A["Security Trading Snapshot"]
        A1B["Securities Trade"]
        A1C["Public Company Financial Report Value"]
        A1D["Security"]
        A1E["Public Company"]
    end
    subgraph Datamart
        D1["Security Trading Snapshot Dimension"]
        D2["Public Company Dimension"]
        D5["Calendar Date Dimension"]
        F1["Fact Security Daily Market Summary"]
        D1 --> F1
        D2 --> F1
        D5 --> F1
    end
    MDDS_StockInfor --> A1A
    OrderTrade_Trade_HOSE --> A1B
    OrderTrade_Trade_HNX --> A1B
    IDS_data_BCTC --> A1C
    ECAT_Security --> A1D
    IDS_company_profiles --> A1E
    A1A --> F1
    A1B --> F1
    A1C --> F1
    A1D --> D1
    A1E --> D2
```

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

#### 3.2.3.2.2 Nhóm thông tin Corporate Bond Daily Market

**Mục đích:** Cung cấp dữ liệu thị trường trái phiếu doanh nghiệp niêm yết cuối ngày theo mã TP và ngày giao dịch, phục vụ bảng `Fact Corporate Bond Daily Market Summary` dùng cho Nhóm 2 (Bảng số liệu Trái phiếu DN).

```mermaid
flowchart LR
    subgraph Staging
        MDDS_CorpBondInfor["MDDS CorpBondInfor"]
        OrderTrade_Trade_HOSE_BDO["OrderTrade Trade HOSE BDO"]
        IDS_company_profiles["IDS company profiles"]
    end
    subgraph Atomic
        A2A["Corporate Bond Trading Snapshot"]
        A2B["Securities Trade"]
        A2C["Public Company"]
    end
    subgraph Datamart
        D3["Corporate Bond Trading Snapshot Dimension"]
        D4["Corporate Bond Trading Snapshot Industry Dimension"]
        D5["Calendar Date Dimension"]
        F2["Fact Corporate Bond Daily Market Summary"]
        D3 --> F2
        D4 --> F2
        D5 --> F2
    end
    MDDS_CorpBondInfor --> A2A
    OrderTrade_Trade_HOSE_BDO --> A2B
    IDS_company_profiles --> A2C
    A2A --> F2
    A2B --> F2
    A2C --> D3
    A2C --> D4
```

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

#### 3.2.3.2.3 Nhóm thông tin Stock Holder Ownership

**Mục đích:** Cung cấp thông tin sở hữu cổ đông và người nội bộ theo từng công ty đại chúng, phục vụ bảng `Stock Holder Ownership Profile` dùng cho STT 47 (Sở hữu và giao dịch nội bộ).

```mermaid
flowchart LR
    subgraph Staging
        IDS_stock_holders["IDS stock_holders"]
        IDS_stock_controls["IDS stock_controls"]
    end
    subgraph Atomic
        A4A["Stock Holder"]
        A4B["Stock Control"]
    end
    subgraph Datamart
        O1["Stock Holder Ownership Profile"]
    end
    IDS_stock_holders --> A4A
    IDS_stock_controls --> A4B
    A4A --> O1
    A4B --> O1
```

**Mô tả luồng:**

Staging → Atomic:
- **Stock Holder:** Bảng lưu thông tin từng cổ đông (tên, loại, tỷ lệ sở hữu, cờ nước ngoài, cờ người nội bộ) lấy thông tin từ bảng IDS.stock_holders
- **Stock Control:** Bảng lưu thông tin hạn chế chuyển nhượng cổ phần lấy thông tin từ bảng IDS.stock_controls

Atomic → Datamart:
- **Stock Holder Ownership Profile:** Bảng tác nghiệp lưu danh sách cổ đông và thông tin sở hữu của từng công ty đại chúng ở trạng thái mới nhất, phục vụ tra cứu sở hữu nội bộ và cổ đông lớn.
