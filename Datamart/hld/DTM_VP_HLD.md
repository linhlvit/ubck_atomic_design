# DTM_VP — HLD Datamart: Thống kê thị trường chứng khoán (VP)

> Thiết kế lại từ đầu phân hệ VP ngày 2026-10-25 theo BA hiện hành (`BRD/BA/BA_analyst_VP.csv`, MD5 `45CC9091E46ABFBDC499228E05BDEF2F`, mtime 2026-10-25 10:57). Phạm vi hiện tại: Lô 1 + Lô 2 = Nhóm 1–16 — xem O_VP_9.

## Section 1 — Data Lineage

##### Cụm 1: Giao dịch theo nhóm nhà đầu tư (NĐTNN / Tự doanh / Toàn bộ) (Fact Investor Group Trading Snapshot)

Grain: 1 mã chứng khoán/hợp đồng × 1 ngày × 1 sàn × 1 nhóm NĐT. Nhóm NĐT xác định theo ký tự thứ 4 của số tài khoản mua/bán, mỗi phía (mua, bán) xét độc lập: FOREIGN ∈ (E, F); PROPRIETARY ∈ (P, E, A); ALL = mọi giao dịch khớp (Buy = Sell = tổng khớp). **Các nhóm không loại trừ nhau** (tài khoản 'E' thuộc cả FOREIGN và PROPRIETARY) — cấm cộng xuyên nhóm. Giá trị = Execution Value dùng chung cho HOSE và HNX (đồng nhất GSTT; Vuong chốt 2026-10-25). Fact lấy Securities Trade làm bảng dẫn, nối bản tin cuối ngày MDDS theo SQL BA: sàn cổ phiếu (STK/STX/UPX) nối trong (INNER — chỉ giữ giao dịch có bản tin MDDS cùng ngày), phái sinh (DVX) nối ngoài (LEFT — giao dịch không có bản tin vẫn được tính vào 'Toàn thị trường'); khóa nối: HOSE Security Symbol Code = Ticker Symbol; HNX Security Symbol Code (Issue Code) = ISIN Code (SQL BA `h.issue_code = s.symbolisin`). Khóa mã chứng khoán/hợp đồng ở Fact là Security Symbol Code (HOSE = mã giao dịch, HNX = Issue Code); khóa ngoại Security Trading Snapshot Dimension cho phép NULL khi mã chưa từng có trong dimension. Bản tin cuối ngày MDDS: `ROW_NUMBER() OVER (PARTITION BY ticker_symbol, trading_dt ORDER BY trading_time DESC, sequence DESC) = 1`. Nguồn Securities Trade (Sổ lệnh cấp tài khoản) chờ Atomic — O_VP_1.

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        ORDERTRADE_TRADE_BOOK_HOSE["ORDERTRADE.TRADE_BOOK_HOSE"]
        ORDERTRADE_TRADE_BOOK_HNX["ORDERTRADE.TRADE_BOOK_HNX"]
        MDDS_JAD_STOCKINFOR["MDDS.JAD_STOCKINFOR"]
        ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end
    subgraph SIL["Atomic"]
        Securities_Trade["Securities Trade"]
        Security_Trading_Snapshot["Security Trading Snapshot"]
        Calendar_Date["Calendar Date"]
    end
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Security_Trading_Snapshot_Dimension["Security Trading Snapshot Dimension"]
        Fact_Investor_Group_Trading_Snapshot["Fact Investor Group Trading Snapshot"]
    end
    ORDERTRADE_TRADE_BOOK_HOSE --> Securities_Trade
    ORDERTRADE_TRADE_BOOK_HNX --> Securities_Trade
    MDDS_JAD_STOCKINFOR --> Security_Trading_Snapshot
    ECAT_ECAT_29_HolidayInfo --> Calendar_Date
    Securities_Trade --> Fact_Investor_Group_Trading_Snapshot
    Security_Trading_Snapshot --> Security_Trading_Snapshot_Dimension
    Calendar_Date --> Calendar_Date_Dimension
    Calendar_Date_Dimension --> Fact_Investor_Group_Trading_Snapshot
    Security_Trading_Snapshot_Dimension --> Fact_Investor_Group_Trading_Snapshot
```

##### Cụm 2: Chỉ số thị trường cuối ngày (reuse Fact của QLKD) (Fact Market Index Snapshot)

Reuse nguyên Fact Market Index Snapshot (sở hữu QLKD, dùng chung NDTNN/GSTT/TKNB): 1 chỉ số (Market Code) × 1 ngày, giữ bản ghi cuối ngày. VP chỉ đọc Market Index Value; chọn chỉ số theo Market Code ('HOSE', 'HNX', 'UPCOM') — không theo Index Name (H14, quyết định 2026-10-21).

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        MDDS_JAD_MARKETINFOR["MDDS.JAD_MARKETINFOR"]
        ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end
    subgraph SIL["Atomic"]
        Market_Index_Snapshot["Market Index Snapshot"]
        Calendar_Date["Calendar Date"]
    end
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Market_Index_Dimension["Market Index Dimension"]
        Fact_Market_Index_Snapshot["Fact Market Index Snapshot"]
    end
    MDDS_JAD_MARKETINFOR --> Market_Index_Snapshot
    ECAT_ECAT_29_HolidayInfo --> Calendar_Date
    Market_Index_Snapshot --> Fact_Market_Index_Snapshot
    Market_Index_Snapshot --> Market_Index_Dimension
    Calendar_Date --> Calendar_Date_Dimension
    Calendar_Date_Dimension --> Fact_Market_Index_Snapshot
    Market_Index_Dimension --> Fact_Market_Index_Snapshot
```

##### Cụm 3: Hợp đồng phái sinh theo ngày (khối lượng mở và giá) (Fact Derivative Contract Snapshot)

Grain: 1 mã hợp đồng phái sinh × 1 ngày giao dịch. Open Interest Quantity từ VSDC (Ticker Symbol = mã hợp đồng, Report Date); Close Price từ bản tin cuối ngày MDDS với Floor Code = '03'. Hai nguồn nối FULL OUTER JOIN theo (mã hợp đồng, ngày) để giữ OI của hợp đồng chưa có bản tin MDDS — BA SQL tính 'Toàn thị trường' trên toàn bộ OI VSDC (kể cả hợp đồng không nối được sản phẩm). Sản phẩm phái sinh (HĐTL VN30/VN100/TPCP) suy ra từ Stock Type Code, Underlying Symbol, Product Group Id của Security Trading Snapshot Dimension. Fact giữ Ticker Symbol (mã hợp đồng) làm cột định danh vì khóa ngoại Security Trading Snapshot Dimension cho phép NULL (hợp đồng có OI VSDC nhưng chưa từng có bản tin MDDS).

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        VSDC_END_OF_DAY_OPEN_INTEREST["VSDC.END_OF_DAY_OPEN_INTEREST"]
        MDDS_JAD_STOCKINFOR["MDDS.JAD_STOCKINFOR"]
        ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end
    subgraph SIL["Atomic"]
        End_Of_Day_Open_Interest["End Of Day Open Interest"]
        Security_Trading_Snapshot["Security Trading Snapshot"]
        Calendar_Date["Calendar Date"]
    end
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Security_Trading_Snapshot_Dimension["Security Trading Snapshot Dimension"]
        Fact_Derivative_Contract_Snapshot["Fact Derivative Contract Snapshot"]
    end
    VSDC_END_OF_DAY_OPEN_INTEREST --> End_Of_Day_Open_Interest
    MDDS_JAD_STOCKINFOR --> Security_Trading_Snapshot
    ECAT_ECAT_29_HolidayInfo --> Calendar_Date
    End_Of_Day_Open_Interest --> Fact_Derivative_Contract_Snapshot
    Security_Trading_Snapshot --> Fact_Derivative_Contract_Snapshot
    Security_Trading_Snapshot --> Security_Trading_Snapshot_Dimension
    Calendar_Date --> Calendar_Date_Dimension
    Calendar_Date_Dimension --> Fact_Derivative_Contract_Snapshot
    Security_Trading_Snapshot_Dimension --> Fact_Derivative_Contract_Snapshot
```

##### Cụm 4: TPDN niêm yết theo mã và ngày (giao dịch, ngành, kỳ hạn, lưu hành) (Fact Listed Corporate Bond Snapshot)

Grain: 1 mã trái phiếu (ISIN = Security Symbol Code) × 1 ngày giao dịch. Hàng của Fact là FULL OUTER JOIN theo (ISIN, ngày) giữa (a) giao dịch TPDN niêm yết của Securities Trade (HNX, Market Id Code = 'HCX') gom theo mã × ngày và (b) bản tin cuối ngày MDDS của trái phiếu (Stock Type Code = '1'): giữ giao dịch không có bản tin cùng ngày (Ngành = 'NA', không có kỳ hạn) và giữ mã có bản tin nhưng không giao dịch (phục vụ Số mã, Kỳ hạn còn lại, KL lưu hành); Listed Indicator = TRUE khi mã có bản tin MDDS cùng ngày. Khóa nối giao dịch ↔ bản tin: Security Symbol Code (Issue Code) = ISIN Code và Trade Date = Trading Date (SQL BA Nhóm 8/10: `h.issue_code = s.symbolisin AND to_date(h.trade_date, 'yyyyMMdd') = s.tradingdate`). Bản tin cuối ngày MDDS: `ROW_NUMBER() OVER (PARTITION BY ticker_symbol, trading_dt ORDER BY trading_time DESC, sequence DESC) = 1`. KL lưu hành lấy từ Listed Share Information (HNX), nối bản tin theo Ticker Symbol và Report Date = Trading Date (SQL BA Nhóm 8: `s.tradingdate = ls.report_date AND s.symbol = ls.ticker_symbol`). Ngành xác định theo tổ chức phát hành, qua bản tin cùng ngày: 3 ký tự đầu của Ticker Symbol = Equity Ticker Symbol của Public Company (bỏ hồ sơ bị từ chối) → Business Line Level 1 Code → Industry Dimension; nếu 3 ký tự đầu trùng Securities Code của Securities Company (CTCK) hoặc Stock Ticker Code của Fund Management Company (CTQLQ) thì ngành mặc định '07000' (Tài chính ngân hàng) — SQL BA Nhóm 8/10. Mệnh giá = 100000 × 10^ROUND(LOG10(Reference Price / 100000)) (tính ngược từ giá tham chiếu); Bond Outstanding Value (dư nợ) = KL lưu hành × mệnh giá. Nguồn Securities Trade (Sổ lệnh cấp tài khoản) chờ Atomic — O_VP_1.

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        ORDERTRADE_TRADE_BOOK_HNX["ORDERTRADE.TRADE_BOOK_HNX"]
        MDDS_JAD_STOCKINFOR["MDDS.JAD_STOCKINFOR"]
        HNX_LISTED_SECURITIES_LIST["HNX.LISTED_SECURITIES_LIST"]
        IDS_COMPANY_PROFILES["IDS.COMPANY_PROFILES"]
        SCMS_SC_FIRM_INFO["SCMS.SC_FIRM_INFO"]
        FMS_SECURITIES["FMS.SECURITIES"]
        IDS_CATEGORIES["IDS.CATEGORIES"]
        ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end
    subgraph SIL["Atomic"]
        Securities_Trade["Securities Trade"]
        Security_Trading_Snapshot["Security Trading Snapshot"]
        Listed_Share_Information["Listed Share Information"]
        Public_Company["Public Company"]
        Securities_Company["Securities Company"]
        Fund_Management_Company["Fund Management Company"]
        Classification_IDS_Business_Line["Classification IDS Business Line"]
        Calendar_Date["Calendar Date"]
    end
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Industry_Dimension["Industry Dimension"]
        Fact_Listed_Corporate_Bond_Snapshot["Fact Listed Corporate Bond Snapshot"]
    end
    ORDERTRADE_TRADE_BOOK_HNX --> Securities_Trade
    MDDS_JAD_STOCKINFOR --> Security_Trading_Snapshot
    HNX_LISTED_SECURITIES_LIST --> Listed_Share_Information
    IDS_COMPANY_PROFILES --> Public_Company
    SCMS_SC_FIRM_INFO --> Securities_Company
    FMS_SECURITIES --> Fund_Management_Company
    IDS_CATEGORIES --> Classification_IDS_Business_Line
    ECAT_ECAT_29_HolidayInfo --> Calendar_Date
    Securities_Trade --> Fact_Listed_Corporate_Bond_Snapshot
    Security_Trading_Snapshot --> Fact_Listed_Corporate_Bond_Snapshot
    Listed_Share_Information --> Fact_Listed_Corporate_Bond_Snapshot
    Public_Company --> Fact_Listed_Corporate_Bond_Snapshot
    Securities_Company --> Fact_Listed_Corporate_Bond_Snapshot
    Fund_Management_Company --> Fact_Listed_Corporate_Bond_Snapshot
    Classification_IDS_Business_Line --> Industry_Dimension
    Calendar_Date --> Calendar_Date_Dimension
    Calendar_Date_Dimension --> Fact_Listed_Corporate_Bond_Snapshot
    Industry_Dimension --> Fact_Listed_Corporate_Bond_Snapshot
```

##### Cụm 5: TPDN riêng lẻ — giao dịch theo ngày báo cáo HNX09 (Fact Private Corporate Bond Trading Snapshot)

Grain: 1 ngày báo cáo HNX09 (báo cáo ngày TPDN riêng lẻ). Nguồn Internal Statistical Report (dữ liệu mức ô báo cáo): lọc Report Code = 'HNX09', Sheet Name = 'sheet 1', Column Path = 'GIÁ TRỊ', Period Type Code = 'DAILY', Report Submission System Code = 'ICP' (chỉ lấy nguồn từ Sở, không lấy CDW/KDL), Submission Status Code IN ('SUBMITTED', 'LATE_SUBMITTED'). Ngày báo cáo = ngày tạo từ Report Year / Report Month / Report Day. Pivot theo Row Path: 'GIÁ TRỊ GIAO DỊCH' → Trading Value; 'GIÁ TRỊ GIAO DỊCH NHÀ ĐẦU TƯ NƯỚC NGOÀI - GIÁ TRỊ MUA' → Foreign Buy Value; '… - GIÁ TRỊ BÁN' → Foreign Sell Value; Cell Value chỉ ép số khi Data Type Code ∈ (CURRENCY, PERCENTAGE, NUMBER). Nhóm 9 dùng Trading Value (K_VP_89); Nhóm 11–13 dùng thêm Foreign Buy Value (K_VP_94) và Foreign Sell Value (K_VP_96) của cùng báo cáo — Lô 2 chỉ bổ sung KPI, không đổi grain/PK/cột. Khóa ô Atomic không có nguồn nộp — O_VP_21.

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        ISS_INTERNAL_STATISTICAL_REPORT["ISS.INTERNAL_STATISTICAL_REPORT"]
        ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end
    subgraph SIL["Atomic"]
        Internal_Statistical_Report["Internal Statistical Report"]
        Calendar_Date["Calendar Date"]
    end
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Private_Corporate_Bond_Trading_Snapshot["Fact Private Corporate Bond Trading Snapshot"]
    end
    ISS_INTERNAL_STATISTICAL_REPORT --> Internal_Statistical_Report
    ECAT_ECAT_29_HolidayInfo --> Calendar_Date
    Internal_Statistical_Report --> Fact_Private_Corporate_Bond_Trading_Snapshot
    Calendar_Date --> Calendar_Date_Dimension
    Calendar_Date_Dimension --> Fact_Private_Corporate_Bond_Trading_Snapshot
```

##### Cụm 6: TPDN riêng lẻ — số mã đăng ký giao dịch theo tháng báo cáo (Fact Private Corporate Bond Registration Snapshot)

Grain: 1 mã trái phiếu (Bond Code) × 1 tháng báo cáo (Report Year, Report Month). Fact không có measure (factless): mỗi dòng = 1 mã TPDN riêng lẻ đăng ký giao dịch trong báo cáo tháng của HNX; Maturity Date giữ để loại mã đã đáo hạn. Số mã ĐKGD = COUNT(DISTINCT Bond Code) với Maturity Date > ngày cuối kỳ, tại tháng báo cáo chọn theo loại kỳ (SQL BA Nhóm 11): Tháng = chính tháng đó; Quý / Năm = tháng báo cáo mới nhất có dữ liệu trong kỳ; Ngày = tháng của ngày tra cứu nếu là ngày cuối tháng, ngược lại tháng liền trước (báo cáo tháng chưa có). Khóa ngoại ngày Snapshot Date Dimension Id = ngày cuối tháng báo cáo (giả định — O_VP_27); Report Year / Report Month giữ nguyên dạng chuỗi của Atomic và ngày cuối tháng được suy ra bằng ép kiểu số, không phụ thuộc đệm số 0. Không reuse/partial Fact TKNB `fct_private_corporate_bond_issuance_snpst` (cùng Atomic nhưng khác grain/mục đích — Section 4). Khóa Atomic chỉ băm Bond Code (lịch sử tháng có thể bị ghi đè) — O_VP_26.

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        HNX_PRIVATE_CORP_BOND_REGISTRATION["HNX.PRIVATE_CORP_BOND_REGISTRATION"]
        ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end
    subgraph SIL["Atomic"]
        Private_Corp_Bond_Registration["Private Corp Bond Registration"]
        Calendar_Date["Calendar Date"]
    end
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Private_Corporate_Bond_Registration_Snapshot["Fact Private Corporate Bond Registration Snapshot"]
    end
    HNX_PRIVATE_CORP_BOND_REGISTRATION --> Private_Corp_Bond_Registration
    ECAT_ECAT_29_HolidayInfo --> Calendar_Date
    Private_Corp_Bond_Registration --> Fact_Private_Corporate_Bond_Registration_Snapshot
    Calendar_Date --> Calendar_Date_Dimension
    Calendar_Date_Dimension --> Fact_Private_Corporate_Bond_Registration_Snapshot
```

##### Cụm 7: TPCP — giao dịch theo ngày và loại sổ lệnh (Outright, Repo) (Fact Government Bond Trading Snapshot)

Grain: 1 ngày giao dịch × 1 loại sổ lệnh (Order Book Type Code ∈ OUTRIGHT, REPO). Nguồn Atomic `Bond Order Book` (HNX; mỗi dòng = 1 lệnh), BA đọc 2 bảng staging `outright_order_book` và `repo_order_book`; không đọc REPO2. Chỉ lấy lệnh Order Status = 'ĐTH' cho mọi chỉ tiêu (SQL BA — giá trị literal chưa kiểm, O_VP_32). Trading Volume = Σ Order Bond Quantity; Trading Value = Σ Trading Val (OUTRIGHT) hoặc Σ First Settlement Val (REPO) (Atomic `trading_val` NULL với REPO); Foreign Buy Value / Foreign Sell Value = cùng giá trị lệnh nhưng chỉ lệnh có ký tự thứ 4 của Buying / Selling Account Nbr ∈ ('E','F'). BA không lọc loại trái phiếu: coi toàn bộ sổ lệnh outright/repo HNX là TPCP — O_VP_32. Không reuse Fact module khác — Section 4.

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        HNX_OUTRIGHT_ORDER_BOOK["HNX.OUTRIGHT_ORDER_BOOK"]
        HNX_REPO_ORDER_BOOK["HNX.REPO_ORDER_BOOK"]
        ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end
    subgraph SIL["Atomic"]
        Bond_Order_Book["Bond Order Book"]
        Calendar_Date["Calendar Date"]
    end
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Government_Bond_Trading_Snapshot["Fact Government Bond Trading Snapshot"]
    end
    HNX_OUTRIGHT_ORDER_BOOK --> Bond_Order_Book
    HNX_REPO_ORDER_BOOK --> Bond_Order_Book
    ECAT_ECAT_29_HolidayInfo --> Calendar_Date
    Bond_Order_Book --> Fact_Government_Bond_Trading_Snapshot
    Calendar_Date --> Calendar_Date_Dimension
    Calendar_Date_Dimension --> Fact_Government_Bond_Trading_Snapshot
```

## Section 2 — Tổng quan báo cáo

> Quy ước chung: Loại kỳ D/M/Q/Y là tham số lọc; các Fact lưu theo ngày (riêng Fact Private Corporate Bond Registration Snapshot theo tháng báo cáo), tổng hợp theo kỳ và so sánh kỳ trước tính tại presentation layer (Case 2). Kỳ trước của loại kỳ 'D' theo SQL BA là ngày lịch liền trước (O_VP_5). Chỉ tiêu YTD của Nhóm 7 và Nhóm 11 (GTGD YTD, GTGD bình quân phiên YTD) so với CẢ NĂM TRƯỚC (01/01–31/12), không phải kỳ trước. Quy ước đánh số KPI: K_VP_1–114 đã dùng hết; Lô 3 (Nhóm 32–37) cấp ID mới tiếp sau K_VP_114 — O_VP_9.

### Tab Dashboard Thống kê thị trường

#### Nhóm 1 - Cổ phiếu >> Biều đồ Giá trị mua/bán ròng NĐTNN và chỉ số Index

> Phân loại: **Phân tích**
> Atomic: `Market Index Snapshot` ← MDDS.JAD_MARKETINFOR — **READY**; `Securities Trade` ← ORDERTRADE.TRADE_BOOK_HOSE / TRADE_BOOK_HNX — **READY** (nguồn Sổ lệnh chờ Atomic, O_VP_1); `Security Trading Snapshot` ← MDDS.JAD_STOCKINFOR — **READY**

**Mockup (suy từ BA — chưa có screenshot, O_VP_8):**

Tham số: Sàn (HOSE / HNX / UPCOM / Toàn thị trường) · Loại kỳ (D/M/Q/Y) · Từ kỳ — Đến kỳ

| Kỳ | VN-Index | HNX-Index | UPCoM-Index | GT mua/bán ròng NĐTNN |
|---|---|---|---|---|
| 2026-09 | … | … | … | … |

> ⚠️ Presentation Grain: 1 điểm biểu đồ = 1 Kỳ × 1 Sàn (Level 1), kèm điểm chỉ số của sàn (Level 2). Storage Grain: Fact Market Index Snapshot = 1 chỉ số × 1 ngày (Level 2); Fact Investor Group Trading Snapshot = 1 mã × 1 ngày × 1 sàn × 1 nhóm NĐT (Level 4) — presentation thô hơn storage, đạt Iso-Grain.

**Source:** `Fact Market Index Snapshot` → `Calendar Date Dimension`, `Market Index Dimension`; `Fact Investor Group Trading Snapshot` → `Calendar Date Dimension`, `Security Trading Snapshot Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Case 1 — reuse Calendar Date Dimension (cdr_dt_dim); kỳ = tham số lọc tại presentation layer | READY |
| K_VP_2 | Sàn | — | Chiều | HOSE / HNX / UPCOM / Toàn thị trường. Chỉ số: Market Index Dimension.Market Code ('HOSE','HNX','UPCOM'); giao dịch: Fact Investor Group Trading Snapshot.Market Id Code (HOSE = 'STK', HNX = 'STX', UPCOM = 'UPX') | Tham số lọc Sàn; ánh xạ HOSE→STK, HNX→STX, UPCOM→UPX theo Điều kiện BA | READY |
| K_VP_3 | Chỉ số | — | Chiều | Market Index Dimension.Index Name với Market Code IN ('HOSE','HNX','UPCOM'); Sàn = 'Toàn thị trường' lấy cả 3 chỉ số | Case 1 — reuse Market Index Dimension (QLKD) | READY |
| K_VP_4 | Giá trị chỉ số | Điểm | Cơ sở | Fact Market Index Snapshot.Market Index Value tại ngày giao dịch cuối cùng của kỳ (Fact giữ bản ghi cuối ngày: Index Time DESC, Sequence DESC) | Case 1 — reuse Fact Market Index Snapshot (QLKD); chọn chỉ số theo Market Code, không theo Index Name (H14) | READY |
| K_VP_5 | GT mua/bán ròng NĐTNN | VND | Phái sinh | SUM(Buy Value − Sell Value) trên Fact Investor Group Trading Snapshot với Investor Group Code = 'FOREIGN' và Market Id Code theo Sàn, trong kỳ | NĐTNN = ký tự thứ 4 của số tài khoản ∈ (E, F). [!] Nguồn Securities Trade — O_VP_1; phạm vi loại CK — O_VP_4. Case 2 — tính tại presentation layer từ Buy Value / Sell Value | READY |
| K_VP_6 | Giá trị chỉ số - VN-Index | Điểm | Cơ sở | K_VP_4 với Market Code = 'HOSE' (VN-Index) | Case 2 — K_VP_4 lọc Market Code; tính tại presentation layer | READY |
| K_VP_7 | Giá trị chỉ số - HNX-Index | Điểm | Cơ sở | K_VP_4 với Market Code = 'HNX' (HNX-Index) | Case 2 — K_VP_4 lọc Market Code; tính tại presentation layer | READY |
| K_VP_8 | Giá trị chỉ số - UPCoM-Index | Điểm | Cơ sở | K_VP_4 với Market Code = 'UPCOM' (UPCoM-Index) | Case 2 — K_VP_4 lọc Market Code; tính tại presentation layer | READY |
| K_VP_9 | GT mua/bán ròng NĐTNN - HOSE | VND | Cơ sở | K_VP_5 với Market Id Code = 'STK' (HOSE) | Case 2 — K_VP_5 lọc Market Id Code; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_10 | GT mua/bán ròng NĐTNN - HNX | VND | Cơ sở | K_VP_5 với Market Id Code = 'STX' (HNX) | Case 2 — K_VP_5 lọc Market Id Code; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_11 | GT mua/bán ròng NĐTNN - UPCoM | VND | Cơ sở | K_VP_5 với Market Id Code = 'UPX' (UPCoM) | Case 2 — K_VP_5 lọc Market Id Code; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_12 | GT mua/bán ròng NĐTNN - Toàn thị trường | VND | Cơ sở | K_VP_5 với Market Id Code IN ('STK','STX','UPX') (toàn thị trường) | Case 2 — K_VP_5 lọc Market Id Code; [!] Nguồn Securities Trade — O_VP_1 | READY |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }
    Market_Index_Dimension {
        string Market_Index_Dimension_Id PK
        string Market_Id
        string Market_Code
        string Index_Name
        string Index_Type_Code
        string TSC_Product_Group_Id
        string Market_Status_Code
        string Source_System_Code
    }
    Security_Trading_Snapshot_Dimension {
        string Security_Trading_Snapshot_Dimension_Id PK
        string Symbol
        string Security_Full_Name
        string Floor_Code
        string Stock_Type_Code
        string Stock_Type_Name
        string Underlying_Symbol
        string ISIN_Code
        string Issuer_Name
        bigint Listed_Share_Count
        date First_Trading_Date
        date Last_Trading_Date
        date Issue_Date
        date Maturity_Date
        string Fund_Type_Code
        string Covered_Warrant_Type_Code
        decimal Exercise_Price
        string Exercise_Ratio
        string Exercise_Style_Code
        string Put_Or_Call_Code
        string Contract_Multiplier
        string Maturity_Month_Year
        decimal Coupon_Rate
        decimal Yield
        decimal Open_Price
        decimal High_Price
        decimal Low_Price
        decimal Ceiling_Price
        decimal Floor_Price
        decimal Reference_Price
        decimal Close_Price
        decimal Price_Change
        string Product_Group_Id
        string Source_System_Code
    }
    Fact_Market_Index_Snapshot {
        string Snapshot_Date_Dimension_Id FK
        string Market_Index_Dimension_Id FK
        decimal Market_Index_Value
        decimal Open_Index
        decimal High_Index
        decimal Low_Index
        decimal Prior_Index
        decimal Index_Change
        decimal Index_Percent_Change
        int Advances_Count
        int Declines_Count
        int No_Change_Count
        int Ceiling_Count
        int Floor_Count
    }
    Fact_Investor_Group_Trading_Snapshot {
        string Investor_Group_Trading_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Security_Trading_Snapshot_Dimension_Id FK
        string Security_Symbol_Code
        string Market_Id_Code
        string Investor_Group_Code
        bigint Buy_Volume
        decimal Buy_Value
        bigint Sell_Volume
        decimal Sell_Value
    }
    Calendar_Date_Dimension ||--o{ Fact_Market_Index_Snapshot : " "
    Market_Index_Dimension ||--o{ Fact_Market_Index_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Market_Index_Dimension["Market Index Dimension"]
        Security_Trading_Snapshot_Dimension["Security Trading Snapshot Dimension"]
        Fact_Market_Index_Snapshot["Fact Market Index Snapshot"]
        Fact_Investor_Group_Trading_Snapshot["Fact Investor Group Trading Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 1"]
        R1["K_VP_1-12: Cổ phiếu: chỉ số và GT mua/bán ròng NĐTNN"]
    end
    Calendar_Date_Dimension --> R1
    Market_Index_Dimension --> R1
    Security_Trading_Snapshot_Dimension --> R1
    Fact_Market_Index_Snapshot --> R1
    Fact_Investor_Group_Trading_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Market Index Dimension | 1 tổ hợp Market Id + Market Code (SCD4A current-state); sở hữu bởi QLKD |
| Security Trading Snapshot Dimension | 1 mã chứng khoán / hợp đồng phái sinh (SCD4A current-state); sở hữu bởi GSTT |
| Fact Market Index Snapshot | 1 chỉ số (Market Code) × 1 ngày giao dịch — bản ghi cuối ngày; sở hữu bởi QLKD |
| Fact Investor Group Trading Snapshot | 1 mã chứng khoán / hợp đồng × 1 ngày giao dịch × 1 sàn (Market Id Code) × 1 nhóm NĐT (ALL / FOREIGN / PROPRIETARY); PK Investor Group Trading Snapshot Id = hash toàn bộ cột grain (Dạng B, A22) |

#### Nhóm 2 - Cổ phiếu >> Biều đồ Giá trị mua/bán ròng Tự doanh và chỉ số Index

> Phân loại: **Phân tích**
> Atomic: `Market Index Snapshot` ← MDDS.JAD_MARKETINFOR — **READY**; `Securities Trade` ← ORDERTRADE.TRADE_BOOK_HOSE / TRADE_BOOK_HNX — **READY** (nguồn Sổ lệnh chờ Atomic, O_VP_1); `Security Trading Snapshot` ← MDDS.JAD_STOCKINFOR — **READY**

**Mockup (suy từ BA — chưa có screenshot, O_VP_8):**

Tham số: Sàn (HOSE / HNX / UPCOM / Toàn thị trường) · Loại kỳ (D/M/Q/Y) · Từ kỳ — Đến kỳ

| Kỳ | VN-Index | HNX-Index | UPCoM-Index | GT mua/bán ròng Tự doanh |
|---|---|---|---|---|
| 2026-09 | … | … | … | … |

> ⚠️ Presentation Grain: 1 điểm biểu đồ = 1 Kỳ × 1 Sàn (Level 1), kèm điểm chỉ số của sàn (Level 2). Storage Grain: Fact Market Index Snapshot = 1 chỉ số × 1 ngày (Level 2); Fact Investor Group Trading Snapshot = 1 mã × 1 ngày × 1 sàn × 1 nhóm NĐT (Level 4) — presentation thô hơn storage, đạt Iso-Grain.

**Source:** `Fact Market Index Snapshot` → `Calendar Date Dimension`, `Market Index Dimension`; `Fact Investor Group Trading Snapshot` → `Calendar Date Dimension`, `Security Trading Snapshot Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Reuse từ Nhóm 1 (K_VP_1) — Case 1: measure vật lý có sẵn trên Fact/Dim | READY |
| K_VP_2 | Sàn | — | Chiều | HOSE / HNX / UPCOM / Toàn thị trường. Chỉ số: Market Index Dimension.Market Code ('HOSE','HNX','UPCOM'); giao dịch: Fact Investor Group Trading Snapshot.Market Id Code (HOSE = 'STK', HNX = 'STX', UPCOM = 'UPX') | Reuse từ Nhóm 1 (K_VP_2) — Case 1: measure vật lý có sẵn trên Fact/Dim | READY |
| K_VP_3 | Chỉ số | — | Chiều | Market Index Dimension.Index Name với Market Code IN ('HOSE','HNX','UPCOM'); Sàn = 'Toàn thị trường' lấy cả 3 chỉ số | Reuse từ Nhóm 1 (K_VP_3) — Case 1: measure vật lý có sẵn trên Fact/Dim | READY |
| K_VP_4 | Giá trị chỉ số | Điểm | Cơ sở | Fact Market Index Snapshot.Market Index Value tại ngày giao dịch cuối cùng của kỳ (Fact giữ bản ghi cuối ngày: Index Time DESC, Sequence DESC) | Reuse từ Nhóm 1 (K_VP_4) — Case 1: measure vật lý có sẵn trên Fact/Dim | READY |
| K_VP_13 | GT mua/bán ròng Tự doanh | VND | Cơ sở | SUM(Buy Value − Sell Value) trên Fact Investor Group Trading Snapshot với Investor Group Code = 'PROPRIETARY' và Market Id Code theo Sàn, trong kỳ | Tự doanh = ký tự thứ 4 của số tài khoản ∈ (P, E, A) theo BA; GSTT chỉ dùng (P, E) — O_VP_2. [!] Nguồn Securities Trade — O_VP_1; phạm vi loại CK — O_VP_4. Case 2 — tính tại presentation layer | READY |
| K_VP_6 | Giá trị chỉ số - VN-Index | Điểm | Cơ sở | K_VP_4 với Market Code = 'HOSE' (VN-Index) | Reuse từ Nhóm 1 (K_VP_6) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact | READY |
| K_VP_7 | Giá trị chỉ số - HNX-Index | Điểm | Cơ sở | K_VP_4 với Market Code = 'HNX' (HNX-Index) | Reuse từ Nhóm 1 (K_VP_7) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact | READY |
| K_VP_8 | Giá trị chỉ số - UPCoM-Index | Điểm | Cơ sở | K_VP_4 với Market Code = 'UPCOM' (UPCoM-Index) | Reuse từ Nhóm 1 (K_VP_8) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact | READY |
| K_VP_14 | GT mua/bán ròng Tự doanh - HOSE | VND | Cơ sở | K_VP_13 với Market Id Code = 'STK' (HOSE) | Case 2 — K_VP_13 lọc Market Id Code; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_15 | GT mua/bán ròng Tự doanh - HNX | VND | Cơ sở | K_VP_13 với Market Id Code = 'STX' (HNX) | Case 2 — K_VP_13 lọc Market Id Code; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_16 | GT mua/bán ròng Tự doanh - UPCOM | VND | Cơ sở | K_VP_13 với Market Id Code = 'UPX' (UPCoM) | Case 2 — K_VP_13 lọc Market Id Code; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_17 | GT mua/bán ròng Tự doanh - Toàn thị trường | VND | Cơ sở | K_VP_13 với Market Id Code IN ('STK','STX','UPX') (toàn thị trường) | Case 2 — K_VP_13 lọc Market Id Code; [!] Nguồn Securities Trade — O_VP_1 | READY |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }
    Market_Index_Dimension {
        string Market_Index_Dimension_Id PK
        string Market_Id
        string Market_Code
        string Index_Name
        string Index_Type_Code
        string TSC_Product_Group_Id
        string Market_Status_Code
        string Source_System_Code
    }
    Security_Trading_Snapshot_Dimension {
        string Security_Trading_Snapshot_Dimension_Id PK
        string Symbol
        string Security_Full_Name
        string Floor_Code
        string Stock_Type_Code
        string Stock_Type_Name
        string Underlying_Symbol
        string ISIN_Code
        string Issuer_Name
        bigint Listed_Share_Count
        date First_Trading_Date
        date Last_Trading_Date
        date Issue_Date
        date Maturity_Date
        string Fund_Type_Code
        string Covered_Warrant_Type_Code
        decimal Exercise_Price
        string Exercise_Ratio
        string Exercise_Style_Code
        string Put_Or_Call_Code
        string Contract_Multiplier
        string Maturity_Month_Year
        decimal Coupon_Rate
        decimal Yield
        decimal Open_Price
        decimal High_Price
        decimal Low_Price
        decimal Ceiling_Price
        decimal Floor_Price
        decimal Reference_Price
        decimal Close_Price
        decimal Price_Change
        string Product_Group_Id
        string Source_System_Code
    }
    Fact_Market_Index_Snapshot {
        string Snapshot_Date_Dimension_Id FK
        string Market_Index_Dimension_Id FK
        decimal Market_Index_Value
        decimal Open_Index
        decimal High_Index
        decimal Low_Index
        decimal Prior_Index
        decimal Index_Change
        decimal Index_Percent_Change
        int Advances_Count
        int Declines_Count
        int No_Change_Count
        int Ceiling_Count
        int Floor_Count
    }
    Fact_Investor_Group_Trading_Snapshot {
        string Investor_Group_Trading_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Security_Trading_Snapshot_Dimension_Id FK
        string Security_Symbol_Code
        string Market_Id_Code
        string Investor_Group_Code
        bigint Buy_Volume
        decimal Buy_Value
        bigint Sell_Volume
        decimal Sell_Value
    }
    Calendar_Date_Dimension ||--o{ Fact_Market_Index_Snapshot : " "
    Market_Index_Dimension ||--o{ Fact_Market_Index_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Market_Index_Dimension["Market Index Dimension"]
        Security_Trading_Snapshot_Dimension["Security Trading Snapshot Dimension"]
        Fact_Market_Index_Snapshot["Fact Market Index Snapshot"]
        Fact_Investor_Group_Trading_Snapshot["Fact Investor Group Trading Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 2"]
        R1["K_VP_1-4,6-8,13-17: Cổ phiếu: chỉ số và GT mua/bán ròng Tự doanh"]
    end
    Calendar_Date_Dimension --> R1
    Market_Index_Dimension --> R1
    Security_Trading_Snapshot_Dimension --> R1
    Fact_Market_Index_Snapshot --> R1
    Fact_Investor_Group_Trading_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Market Index Dimension | 1 tổ hợp Market Id + Market Code (SCD4A current-state); sở hữu bởi QLKD |
| Security Trading Snapshot Dimension | 1 mã chứng khoán / hợp đồng phái sinh (SCD4A current-state); sở hữu bởi GSTT |
| Fact Market Index Snapshot | 1 chỉ số (Market Code) × 1 ngày giao dịch — bản ghi cuối ngày; sở hữu bởi QLKD |
| Fact Investor Group Trading Snapshot | 1 mã chứng khoán / hợp đồng × 1 ngày giao dịch × 1 sàn (Market Id Code) × 1 nhóm NĐT (ALL / FOREIGN / PROPRIETARY); PK Investor Group Trading Snapshot Id = hash toàn bộ cột grain (Dạng B, A22) |

#### Nhóm 3 - Phái sinh >> Chỉ tiêu tổng hợp

> Phân loại: **Phân tích**
> Atomic: `End Of Day Open Interest` ← VSDC.END_OF_DAY_OPEN_INTEREST — **READY**; `Security Trading Snapshot` ← MDDS.JAD_STOCKINFOR — **READY**; `Securities Trade` ← ORDERTRADE.TRADE_BOOK_HNX — **READY** (nguồn Sổ lệnh chờ Atomic, O_VP_1)

**Mockup (suy từ BA — chưa có screenshot, O_VP_8):**

Tham số: Sản phẩm phái sinh (HĐTL VN30 / HĐTL VN100 / HĐTL TPCP / Toàn thị trường) · Loại kỳ (D/M/Q/Y) · Kỳ

| Chỉ tiêu | Kỳ báo cáo | Kỳ trước | Thay đổi | % thay đổi |
|---|---|---|---|---|
| Khối lượng mở (OI) | … | … | … | … |
| KLGD | … | … | … | … |
| KL mua NĐTNN | … | … | … | … |
| KL bán NĐTNN | … | … | … | … |
| KL mua/bán ròng NĐTNN | … | … | … | … |

> ⚠️ Presentation Grain: 1 dòng = 1 chỉ tiêu × 1 Sản phẩm phái sinh × 1 Kỳ (nhóm hợp đồng cùng sản phẩm). Storage Grain: 1 mã hợp đồng × 1 ngày (Level 4) — presentation thô hơn storage, đạt Iso-Grain.

**Source:** `Fact Derivative Contract Snapshot` → `Calendar Date Dimension`, `Security Trading Snapshot Dimension`; `Fact Investor Group Trading Snapshot` → `Calendar Date Dimension`, `Security Trading Snapshot Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Reuse từ Nhóm 1 (K_VP_1) — Case 1: measure vật lý có sẵn trên Fact/Dim | READY |
| K_VP_18 | Sản phẩm phái sinh | — | Chiều | Sản phẩm phái sinh = CONCAT(CASE Stock Type Code WHEN '4' THEN 'HĐTL' WHEN '5' THEN 'HĐ quyền chọn' END, ' ', CASE WHEN Product Group Id = 'FBX' THEN 'TPCP' ELSE Underlying Symbol END) trên Security Trading Snapshot Dimension với Floor Code = '03'; giá trị hiển thị: HĐTL VN30, HĐTL VN100, HĐTL TPCP, Toàn thị trường | Chiều dẫn xuất từ Security Trading Snapshot Dimension (partial — thêm Product Group Id, O_VP_7) | READY |
| K_VP_19 | Khối lượng mở (OI) | Hợp đồng | Cơ sở | SUM(Open Interest Quantity) trên Fact Derivative Contract Snapshot tại ngày giao dịch cuối cùng của kỳ, theo Sản phẩm phái sinh | Atomic End Of Day Open Interest (VSDC) nối Security Trading Snapshot theo Ticker Symbol = Symbol AND Report Date = Trading Date. Số thời điểm — tại ngày cuối kỳ | READY |
| K_VP_20 | Khối lượng mở (OI) - % thay đổi so với kỳ trước | % | Phái sinh | (K_VP_19 kỳ báo cáo − K_VP_19 kỳ trước) / K_VP_19 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_21 | KLGD | Hợp đồng | Cơ sở | SUM(Buy Volume) với Investor Group Code = 'ALL' và Market Id Code = 'DVX' trong kỳ, theo Sản phẩm phái sinh (mỗi giao dịch khớp tính 1 lần ở phía mua) | [!] Nguồn Securities Trade — O_VP_1 (HNX.TRADE_BOOK, market_id = 'DVX') nối Security Trading Snapshot theo Issue Code = ISIN Code. Số tổng trong kỳ | READY |
| K_VP_22 | KLGD - % thay đổi so với kỳ trước | % | Phái sinh | (K_VP_21 kỳ báo cáo − K_VP_21 kỳ trước) / K_VP_21 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5; BA ghi nhầm bảng nguồn OI — O_VP_6 | READY |
| K_VP_23 | KL mua NĐTNN | Hợp đồng | Cơ sở | SUM(Buy Volume) với Investor Group Code = 'FOREIGN' và Market Id Code = 'DVX' trong kỳ, theo Sản phẩm phái sinh | NĐTNN = ký tự thứ 4 số tài khoản ∈ (E, F) theo Điều kiện/SQL BA; Mô tả BA ghi Foreign Investor Type Code <> '00' — O_VP_3. [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_24 | KL mua NĐTNN - % thay đổi so với kỳ trước | % | Phái sinh | (K_VP_23 kỳ báo cáo − K_VP_23 kỳ trước) / K_VP_23 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_25 | KL bán NĐTNN | Hợp đồng | Cơ sở | SUM(Sell Volume) với Investor Group Code = 'FOREIGN' và Market Id Code = 'DVX' trong kỳ, theo Sản phẩm phái sinh | NĐTNN = ký tự thứ 4 số tài khoản ∈ (E, F) theo Điều kiện/SQL BA — O_VP_3. [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_26 | KL bán NĐTNN - % thay đổi so với kỳ trước | % | Phái sinh | (K_VP_25 kỳ báo cáo − K_VP_25 kỳ trước) / K_VP_25 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_27 | KL mua/bán ròng NĐTNN | Hợp đồng | Phái sinh | K_VP_23 − K_VP_25 | Case 2 — tính tại presentation layer từ Buy Volume / Sell Volume; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_28 | KL mua/bán ròng NĐTNN - % thay đổi so với kỳ trước | % | Phái sinh | (K_VP_27 kỳ báo cáo − K_VP_27 kỳ trước) / ABS(K_VP_27 kỳ trước) × 100 | Case 2 — tính tại presentation layer; BA dòng 39 chia ABS(kỳ trước) trong khi dòng 49/59/69/79 không dùng ABS — O_VP_6; kỳ trước — O_VP_5 | READY |
| K_VP_29 | Khối lượng mở (OI) - HĐTL VN30 | Hợp đồng | Cơ sở | K_VP_19 lọc Sản phẩm phái sinh = 'HĐTL VN30' (Stock Type Code = '4' AND Underlying Symbol = 'VN30') | Case 2 — K_VP_19 lọc theo Sản phẩm phái sinh; tính tại presentation layer | READY |
| K_VP_30 | Khối lượng mở (OI) - % thay đổi so với kỳ trước - HĐTL VN30 | % | Phái sinh | (K_VP_29 kỳ báo cáo − K_VP_29 kỳ trước) / K_VP_29 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_31 | KLGD - HĐTL VN30 | Hợp đồng | Cơ sở | K_VP_21 lọc Sản phẩm phái sinh = 'HĐTL VN30' (Stock Type Code = '4' AND Underlying Symbol = 'VN30') | Case 2 — K_VP_21 lọc theo Sản phẩm phái sinh; tính tại presentation layer; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_32 | KLGD - HĐTL VN30 - % thay đổi so với kỳ trước - HĐTL VN30 | % | Phái sinh | (K_VP_31 kỳ báo cáo − K_VP_31 kỳ trước) / K_VP_31 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_33 | KL mua NĐTNN - HĐTL VN30 | Hợp đồng | Cơ sở | K_VP_23 lọc Sản phẩm phái sinh = 'HĐTL VN30' (Stock Type Code = '4' AND Underlying Symbol = 'VN30') | Case 2 — K_VP_23 lọc theo Sản phẩm phái sinh; tính tại presentation layer; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_34 | KL mua NĐTNN - HĐTL VN30 - % thay đổi so với kỳ trước - HĐTL VN30 | % | Phái sinh | (K_VP_33 kỳ báo cáo − K_VP_33 kỳ trước) / K_VP_33 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_35 | KL bán NĐTNN - HĐTL VN30 | Hợp đồng | Cơ sở | K_VP_25 lọc Sản phẩm phái sinh = 'HĐTL VN30' (Stock Type Code = '4' AND Underlying Symbol = 'VN30') | Case 2 — K_VP_25 lọc theo Sản phẩm phái sinh; tính tại presentation layer; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_36 | KL bán NĐTNN - HĐTL VN30 - % thay đổi so với kỳ trước - HĐTL VN30 | % | Phái sinh | (K_VP_35 kỳ báo cáo − K_VP_35 kỳ trước) / K_VP_35 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_37 | KL mua/bán ròng NĐTNN - HĐTL VN30 | Hợp đồng | Cơ sở | K_VP_27 lọc Sản phẩm phái sinh = 'HĐTL VN30' (Stock Type Code = '4' AND Underlying Symbol = 'VN30') | Case 2 — K_VP_27 lọc theo Sản phẩm phái sinh; tính tại presentation layer; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_38 | KL mua/bán ròng NĐTNN - HĐTL VN30 - % thay đổi so với kỳ trước - HĐTL VN30 | % | Phái sinh | (K_VP_37 kỳ báo cáo − K_VP_37 kỳ trước) / K_VP_37 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5; BA không dùng ABS (khác dòng 39) — O_VP_6 | READY |
| K_VP_39 | Khối lượng mở (OI) - HĐTL VN100 | Hợp đồng | Cơ sở | K_VP_19 lọc Sản phẩm phái sinh = 'HĐTL VN100' (Stock Type Code = '4' AND Underlying Symbol = 'VN100') | Case 2 — K_VP_19 lọc theo Sản phẩm phái sinh; tính tại presentation layer | READY |
| K_VP_40 | Khối lượng mở (OI) - % thay đổi so với kỳ trước - HĐTL VN100 | % | Phái sinh | (K_VP_39 kỳ báo cáo − K_VP_39 kỳ trước) / K_VP_39 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_41 | KLGD - HĐTL VN100 | Hợp đồng | Cơ sở | K_VP_21 lọc Sản phẩm phái sinh = 'HĐTL VN100' (Stock Type Code = '4' AND Underlying Symbol = 'VN100') | Case 2 — K_VP_21 lọc theo Sản phẩm phái sinh; tính tại presentation layer; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_42 | KLGD - HĐTL VN100 - % thay đổi so với kỳ trước - HĐTL VN100 | % | Phái sinh | (K_VP_41 kỳ báo cáo − K_VP_41 kỳ trước) / K_VP_41 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_43 | KL mua NĐTNN - HĐTL VN100 | Hợp đồng | Cơ sở | K_VP_23 lọc Sản phẩm phái sinh = 'HĐTL VN100' (Stock Type Code = '4' AND Underlying Symbol = 'VN100') | Case 2 — K_VP_23 lọc theo Sản phẩm phái sinh; tính tại presentation layer; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_44 | KL mua NĐTNN - HĐTL VN100 - % thay đổi so với kỳ trước - HĐTL VN100 | % | Phái sinh | (K_VP_43 kỳ báo cáo − K_VP_43 kỳ trước) / K_VP_43 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_45 | KL bán NĐTNN - HĐTL VN100 | Hợp đồng | Cơ sở | K_VP_25 lọc Sản phẩm phái sinh = 'HĐTL VN100' (Stock Type Code = '4' AND Underlying Symbol = 'VN100') | Case 2 — K_VP_25 lọc theo Sản phẩm phái sinh; tính tại presentation layer; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_46 | KL bán NĐTNN - HĐTL VN100 - % thay đổi so với kỳ trước - HĐTL VN100 | % | Phái sinh | (K_VP_45 kỳ báo cáo − K_VP_45 kỳ trước) / K_VP_45 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_47 | KL mua/bán ròng NĐTNN - HĐTL VN100 | Hợp đồng | Cơ sở | K_VP_27 lọc Sản phẩm phái sinh = 'HĐTL VN100' (Stock Type Code = '4' AND Underlying Symbol = 'VN100') | Case 2 — K_VP_27 lọc theo Sản phẩm phái sinh; tính tại presentation layer; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_48 | KL mua/bán ròng NĐTNN - HĐTL VN100 - % thay đổi so với kỳ trước - HĐTL VN100 | % | Phái sinh | (K_VP_47 kỳ báo cáo − K_VP_47 kỳ trước) / K_VP_47 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5; BA không dùng ABS (khác dòng 39) — O_VP_6 | READY |
| K_VP_49 | Khối lượng mở (OI) - HĐTL TPCP | Hợp đồng | Cơ sở | K_VP_19 lọc Sản phẩm phái sinh = 'HĐTL TPCP' (Stock Type Code = '4' AND Product Group Id = 'FBX') | Case 2 — K_VP_19 lọc theo Sản phẩm phái sinh; tính tại presentation layer | READY |
| K_VP_50 | Khối lượng mở (OI) - % thay đổi so với kỳ trước - HĐTL TPCP | % | Phái sinh | (K_VP_49 kỳ báo cáo − K_VP_49 kỳ trước) / K_VP_49 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_51 | KLGD - HĐTL TPCP | Hợp đồng | Cơ sở | K_VP_21 lọc Sản phẩm phái sinh = 'HĐTL TPCP' (Stock Type Code = '4' AND Product Group Id = 'FBX') | Case 2 — K_VP_21 lọc theo Sản phẩm phái sinh; tính tại presentation layer; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_52 | KLGD - HĐTL TPCP - % thay đổi so với kỳ trước - HĐTL TPCP | % | Phái sinh | (K_VP_51 kỳ báo cáo − K_VP_51 kỳ trước) / K_VP_51 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_53 | KL mua NĐTNN - HĐTL TPCP | Hợp đồng | Cơ sở | K_VP_23 lọc Sản phẩm phái sinh = 'HĐTL TPCP' (Stock Type Code = '4' AND Product Group Id = 'FBX') | Case 2 — K_VP_23 lọc theo Sản phẩm phái sinh; tính tại presentation layer; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_54 | KL mua NĐTNN - HĐTL TPCP - % thay đổi so với kỳ trước - HĐTL TPCP | % | Phái sinh | (K_VP_53 kỳ báo cáo − K_VP_53 kỳ trước) / K_VP_53 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_55 | KL bán NĐTNN - HĐTL TPCP | Hợp đồng | Cơ sở | K_VP_25 lọc Sản phẩm phái sinh = 'HĐTL TPCP' (Stock Type Code = '4' AND Product Group Id = 'FBX') | Case 2 — K_VP_25 lọc theo Sản phẩm phái sinh; tính tại presentation layer; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_56 | KL bán NĐTNN - HĐTL TPCP - % thay đổi so với kỳ trước - HĐTL TPCP | % | Phái sinh | (K_VP_55 kỳ báo cáo − K_VP_55 kỳ trước) / K_VP_55 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_57 | KL mua/bán ròng NĐTNN - HĐTL TPCP | Hợp đồng | Cơ sở | K_VP_27 lọc Sản phẩm phái sinh = 'HĐTL TPCP' (Stock Type Code = '4' AND Product Group Id = 'FBX') | Case 2 — K_VP_27 lọc theo Sản phẩm phái sinh; tính tại presentation layer; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_58 | KL mua/bán ròng NĐTNN - HĐTL TPCP - % thay đổi so với kỳ trước - HĐTL TPCP | % | Phái sinh | (K_VP_57 kỳ báo cáo − K_VP_57 kỳ trước) / K_VP_57 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5; BA không dùng ABS (khác dòng 39) — O_VP_6 | READY |
| K_VP_59 | Khối lượng mở (OI) - Toàn thị trường | Hợp đồng | Cơ sở | K_VP_19 lọc Sản phẩm phái sinh = 'Toàn thị trường' (mọi hợp đồng phái sinh (Floor Code = '03'), không lọc sản phẩm) | Case 2 — K_VP_19 lọc theo Sản phẩm phái sinh; tính tại presentation layer | READY |
| K_VP_60 | Khối lượng mở (OI) - % thay đổi so với kỳ trước - Toàn thị trường | % | Phái sinh | (K_VP_59 kỳ báo cáo − K_VP_59 kỳ trước) / K_VP_59 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_61 | KLGD - Toàn thị trường | Hợp đồng | Cơ sở | K_VP_21 lọc Sản phẩm phái sinh = 'Toàn thị trường' (mọi hợp đồng phái sinh (Floor Code = '03'), không lọc sản phẩm) | Case 2 — K_VP_21 lọc theo Sản phẩm phái sinh; tính tại presentation layer; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_62 | KLGD - Toàn thị trường - % thay đổi so với kỳ trước - Toàn thị trường | % | Phái sinh | (K_VP_61 kỳ báo cáo − K_VP_61 kỳ trước) / K_VP_61 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_63 | KL mua NĐTNN - Toàn thị trường | Hợp đồng | Cơ sở | K_VP_23 lọc Sản phẩm phái sinh = 'Toàn thị trường' (mọi hợp đồng phái sinh (Floor Code = '03'), không lọc sản phẩm) | Case 2 — K_VP_23 lọc theo Sản phẩm phái sinh; tính tại presentation layer; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_64 | KL mua NĐTNN - Toàn thị trường - % thay đổi so với kỳ trước - Toàn thị trường | % | Phái sinh | (K_VP_63 kỳ báo cáo − K_VP_63 kỳ trước) / K_VP_63 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_65 | KL bán NĐTNN - Toàn thị trường | Hợp đồng | Cơ sở | K_VP_25 lọc Sản phẩm phái sinh = 'Toàn thị trường' (mọi hợp đồng phái sinh (Floor Code = '03'), không lọc sản phẩm) | Case 2 — K_VP_25 lọc theo Sản phẩm phái sinh; tính tại presentation layer; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_66 | KL bán NĐTNN - Toàn thị trường - % thay đổi so với kỳ trước - Toàn thị trường | % | Phái sinh | (K_VP_65 kỳ báo cáo − K_VP_65 kỳ trước) / K_VP_65 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_67 | KL mua/bán ròng NĐTNN - Toàn thị trường | Hợp đồng | Cơ sở | K_VP_27 lọc Sản phẩm phái sinh = 'Toàn thị trường' (mọi hợp đồng phái sinh (Floor Code = '03'), không lọc sản phẩm) | Case 2 — K_VP_27 lọc theo Sản phẩm phái sinh; tính tại presentation layer; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_68 | KL mua/bán ròng NĐTNN - Toàn thị trường - % thay đổi so với kỳ trước - Toàn thị trường | % | Phái sinh | (K_VP_67 kỳ báo cáo − K_VP_67 kỳ trước) / K_VP_67 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5; BA không dùng ABS (khác dòng 39) — O_VP_6 | READY |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }
    Security_Trading_Snapshot_Dimension {
        string Security_Trading_Snapshot_Dimension_Id PK
        string Symbol
        string Security_Full_Name
        string Floor_Code
        string Stock_Type_Code
        string Stock_Type_Name
        string Underlying_Symbol
        string ISIN_Code
        string Issuer_Name
        bigint Listed_Share_Count
        date First_Trading_Date
        date Last_Trading_Date
        date Issue_Date
        date Maturity_Date
        string Fund_Type_Code
        string Covered_Warrant_Type_Code
        decimal Exercise_Price
        string Exercise_Ratio
        string Exercise_Style_Code
        string Put_Or_Call_Code
        string Contract_Multiplier
        string Maturity_Month_Year
        decimal Coupon_Rate
        decimal Yield
        decimal Open_Price
        decimal High_Price
        decimal Low_Price
        decimal Ceiling_Price
        decimal Floor_Price
        decimal Reference_Price
        decimal Close_Price
        decimal Price_Change
        string Product_Group_Id
        string Source_System_Code
    }
    Fact_Derivative_Contract_Snapshot {
        string Derivative_Contract_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Security_Trading_Snapshot_Dimension_Id FK
        string Ticker_Symbol
        bigint Open_Interest_Quantity
        decimal Close_Price
    }
    Fact_Investor_Group_Trading_Snapshot {
        string Investor_Group_Trading_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Security_Trading_Snapshot_Dimension_Id FK
        string Security_Symbol_Code
        string Market_Id_Code
        string Investor_Group_Code
        bigint Buy_Volume
        decimal Buy_Value
        bigint Sell_Volume
        decimal Sell_Value
    }
    Calendar_Date_Dimension ||--o{ Fact_Derivative_Contract_Snapshot : " "
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Derivative_Contract_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Security_Trading_Snapshot_Dimension["Security Trading Snapshot Dimension"]
        Fact_Derivative_Contract_Snapshot["Fact Derivative Contract Snapshot"]
        Fact_Investor_Group_Trading_Snapshot["Fact Investor Group Trading Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 3"]
        R1["K_VP_1,18-68: Phái sinh: chỉ tiêu tổng hợp"]
    end
    Calendar_Date_Dimension --> R1
    Security_Trading_Snapshot_Dimension --> R1
    Fact_Derivative_Contract_Snapshot --> R1
    Fact_Investor_Group_Trading_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Security Trading Snapshot Dimension | 1 mã chứng khoán / hợp đồng phái sinh (SCD4A current-state); sở hữu bởi GSTT |
| Fact Derivative Contract Snapshot | 1 mã hợp đồng phái sinh × 1 ngày giao dịch; PK Derivative Contract Snapshot Id = hash (Snapshot Date, Ticker Symbol) (Dạng B, A22) |
| Fact Investor Group Trading Snapshot | 1 mã chứng khoán / hợp đồng × 1 ngày giao dịch × 1 sàn (Market Id Code) × 1 nhóm NĐT (ALL / FOREIGN / PROPRIETARY); PK Investor Group Trading Snapshot Id = hash toàn bộ cột grain (Dạng B, A22) |

#### Nhóm 4 - Phái sinh >> Giá HĐTL

> Phân loại: **Phân tích**
> Atomic: `Security Trading Snapshot` ← MDDS.JAD_STOCKINFOR — **READY**

**Mockup (suy từ BA — chưa có screenshot, O_VP_8):**

Tham số: Sản phẩm phái sinh · Loại kỳ (D/M/Q/Y) · Kỳ

| Sản phẩm phái sinh | Tháng đáo hạn | Giá |
|---|---|---|
| HĐTL VN30 | 2611 | … |

> ⚠️ Presentation Grain: 1 dòng = 1 Sản phẩm phái sinh × 1 Tháng đáo hạn (= 1 mã hợp đồng) tại ngày cuối kỳ. Storage Grain: 1 mã hợp đồng × 1 ngày (Level 4) — đạt Iso-Grain.

**Source:** `Fact Derivative Contract Snapshot` → `Calendar Date Dimension`, `Security Trading Snapshot Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Reuse từ Nhóm 1 (K_VP_1) — Case 1: measure vật lý có sẵn trên Fact/Dim | READY |
| K_VP_18 | Sản phẩm phái sinh | — | Chiều | Sản phẩm phái sinh = CONCAT(CASE Stock Type Code WHEN '4' THEN 'HĐTL' WHEN '5' THEN 'HĐ quyền chọn' END, ' ', CASE WHEN Product Group Id = 'FBX' THEN 'TPCP' ELSE Underlying Symbol END) trên Security Trading Snapshot Dimension với Floor Code = '03'; giá trị hiển thị: HĐTL VN30, HĐTL VN100, HĐTL TPCP, Toàn thị trường | Reuse từ Nhóm 3 (K_VP_18) — Case 1: measure vật lý có sẵn trên Fact/Dim | READY |
| K_VP_69 | Tháng đáo hạn | — | Cơ sở | Security Trading Snapshot Dimension.Maturity Month Year của hợp đồng phái sinh | Case 1 — thuộc tính Dimension (Maturity Month Year) | READY |
| K_VP_70 | Giá | Giá HĐ | Cơ sở | Fact Derivative Contract Snapshot.Close Price (giá đóng cửa, bản ghi cuối ngày) của từng mã hợp đồng tại ngày giao dịch cuối cùng có dữ liệu trong kỳ | Atomic Security Trading Snapshot (MDDS.JAD_STOCKINFOR, Floor Code = '03'); không phụ thuộc Securities Trade | READY |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }
    Security_Trading_Snapshot_Dimension {
        string Security_Trading_Snapshot_Dimension_Id PK
        string Symbol
        string Security_Full_Name
        string Floor_Code
        string Stock_Type_Code
        string Stock_Type_Name
        string Underlying_Symbol
        string ISIN_Code
        string Issuer_Name
        bigint Listed_Share_Count
        date First_Trading_Date
        date Last_Trading_Date
        date Issue_Date
        date Maturity_Date
        string Fund_Type_Code
        string Covered_Warrant_Type_Code
        decimal Exercise_Price
        string Exercise_Ratio
        string Exercise_Style_Code
        string Put_Or_Call_Code
        string Contract_Multiplier
        string Maturity_Month_Year
        decimal Coupon_Rate
        decimal Yield
        decimal Open_Price
        decimal High_Price
        decimal Low_Price
        decimal Ceiling_Price
        decimal Floor_Price
        decimal Reference_Price
        decimal Close_Price
        decimal Price_Change
        string Product_Group_Id
        string Source_System_Code
    }
    Fact_Derivative_Contract_Snapshot {
        string Derivative_Contract_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Security_Trading_Snapshot_Dimension_Id FK
        string Ticker_Symbol
        bigint Open_Interest_Quantity
        decimal Close_Price
    }
    Calendar_Date_Dimension ||--o{ Fact_Derivative_Contract_Snapshot : " "
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Derivative_Contract_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Security_Trading_Snapshot_Dimension["Security Trading Snapshot Dimension"]
        Fact_Derivative_Contract_Snapshot["Fact Derivative Contract Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 4"]
        R1["K_VP_1,18,69-70: Phái sinh: giá hợp đồng tương lai"]
    end
    Calendar_Date_Dimension --> R1
    Security_Trading_Snapshot_Dimension --> R1
    Fact_Derivative_Contract_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Security Trading Snapshot Dimension | 1 mã chứng khoán / hợp đồng phái sinh (SCD4A current-state); sở hữu bởi GSTT |
| Fact Derivative Contract Snapshot | 1 mã hợp đồng phái sinh × 1 ngày giao dịch; PK Derivative Contract Snapshot Id = hash (Snapshot Date, Ticker Symbol) (Dạng B, A22) |

#### Nhóm 5 - Phái sinh >> Biểu đồ Diễn biến giao dịch thị trường phái sinh

> Phân loại: **Phân tích**
> Atomic: `End Of Day Open Interest` ← VSDC.END_OF_DAY_OPEN_INTEREST — **READY**; `Security Trading Snapshot` ← MDDS.JAD_STOCKINFOR — **READY**; `Securities Trade` ← ORDERTRADE.TRADE_BOOK_HNX — **READY** (nguồn Sổ lệnh chờ Atomic, O_VP_1)

**Mockup (suy từ BA — chưa có screenshot, O_VP_8):**

Tham số: Sản phẩm phái sinh · Loại kỳ (D/M/Q/Y) · Từ kỳ — Đến kỳ

| Kỳ | KLGD | Khối lượng mở (OI) |
|---|---|---|
| 2026-09 | … | … |

> ⚠️ Presentation Grain: 1 điểm biểu đồ = 1 Kỳ × 1 Sản phẩm phái sinh. Storage Grain: 1 mã hợp đồng × 1 ngày (Level 4) — đạt Iso-Grain.

**Source:** `Fact Derivative Contract Snapshot` → `Calendar Date Dimension`, `Security Trading Snapshot Dimension`; `Fact Investor Group Trading Snapshot` → `Calendar Date Dimension`, `Security Trading Snapshot Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Reuse từ Nhóm 1 (K_VP_1) — Case 1: measure vật lý có sẵn trên Fact/Dim | READY |
| K_VP_18 | Sản phẩm phái sinh | — | Chiều | Sản phẩm phái sinh = CONCAT(CASE Stock Type Code WHEN '4' THEN 'HĐTL' WHEN '5' THEN 'HĐ quyền chọn' END, ' ', CASE WHEN Product Group Id = 'FBX' THEN 'TPCP' ELSE Underlying Symbol END) trên Security Trading Snapshot Dimension với Floor Code = '03'; giá trị hiển thị: HĐTL VN30, HĐTL VN100, HĐTL TPCP, Toàn thị trường | Reuse từ Nhóm 3 (K_VP_18) — Case 1: measure vật lý có sẵn trên Fact/Dim | READY |
| K_VP_21 | KLGD | Hợp đồng | Cơ sở | SUM(Buy Volume) với Investor Group Code = 'ALL' và Market Id Code = 'DVX' trong kỳ, theo Sản phẩm phái sinh (mỗi giao dịch khớp tính 1 lần ở phía mua) | Reuse từ Nhóm 3 (K_VP_21) — Case 1: measure vật lý có sẵn trên Fact/Dim | READY |
| K_VP_19 | Khối lượng mở (OI) | Hợp đồng | Cơ sở | SUM(Open Interest Quantity) trên Fact Derivative Contract Snapshot tại ngày giao dịch cuối cùng của kỳ, theo Sản phẩm phái sinh | Reuse từ Nhóm 3 (K_VP_19) — Case 1: measure vật lý có sẵn trên Fact/Dim | READY |
| K_VP_31 | KLGD - HĐTL VN30 | Hợp đồng | Cơ sở | K_VP_21 lọc Sản phẩm phái sinh = 'HĐTL VN30' (Stock Type Code = '4' AND Underlying Symbol = 'VN30') | Reuse từ Nhóm 3 (K_VP_31) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact | READY |
| K_VP_29 | Khối lượng mở (OI) - HĐTL VN30 | Hợp đồng | Cơ sở | K_VP_19 lọc Sản phẩm phái sinh = 'HĐTL VN30' (Stock Type Code = '4' AND Underlying Symbol = 'VN30') | Reuse từ Nhóm 3 (K_VP_29) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact | READY |
| K_VP_41 | KLGD - HĐTL VN100 | Hợp đồng | Cơ sở | K_VP_21 lọc Sản phẩm phái sinh = 'HĐTL VN100' (Stock Type Code = '4' AND Underlying Symbol = 'VN100') | Reuse từ Nhóm 3 (K_VP_41) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact | READY |
| K_VP_39 | Khối lượng mở (OI) - HĐTL VN100 | Hợp đồng | Cơ sở | K_VP_19 lọc Sản phẩm phái sinh = 'HĐTL VN100' (Stock Type Code = '4' AND Underlying Symbol = 'VN100') | Reuse từ Nhóm 3 (K_VP_39) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact | READY |
| K_VP_51 | KLGD - HĐTL TPCP | Hợp đồng | Cơ sở | K_VP_21 lọc Sản phẩm phái sinh = 'HĐTL TPCP' (Stock Type Code = '4' AND Product Group Id = 'FBX') | Reuse từ Nhóm 3 (K_VP_51) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact. BA nhãn 'HĐTL VN100' nhưng điều kiện Product Group Id = 'FBX' (TPCP) — O_VP_6 | READY |
| K_VP_49 | Khối lượng mở (OI) - HĐTL TPCP | Hợp đồng | Cơ sở | K_VP_19 lọc Sản phẩm phái sinh = 'HĐTL TPCP' (Stock Type Code = '4' AND Product Group Id = 'FBX') | Reuse từ Nhóm 3 (K_VP_49) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact. BA nhãn 'HĐTL VN100' nhưng điều kiện Product Group Id = 'FBX' (TPCP) — O_VP_6 | READY |
| K_VP_61 | KLGD - Toàn thị trường | Hợp đồng | Cơ sở | K_VP_21 lọc Sản phẩm phái sinh = 'Toàn thị trường' (mọi hợp đồng phái sinh (Floor Code = '03'), không lọc sản phẩm) | Reuse từ Nhóm 3 (K_VP_61) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact | READY |
| K_VP_59 | Khối lượng mở (OI) - Toàn thị trường | Hợp đồng | Cơ sở | K_VP_19 lọc Sản phẩm phái sinh = 'Toàn thị trường' (mọi hợp đồng phái sinh (Floor Code = '03'), không lọc sản phẩm) | Reuse từ Nhóm 3 (K_VP_59) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact | READY |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }
    Security_Trading_Snapshot_Dimension {
        string Security_Trading_Snapshot_Dimension_Id PK
        string Symbol
        string Security_Full_Name
        string Floor_Code
        string Stock_Type_Code
        string Stock_Type_Name
        string Underlying_Symbol
        string ISIN_Code
        string Issuer_Name
        bigint Listed_Share_Count
        date First_Trading_Date
        date Last_Trading_Date
        date Issue_Date
        date Maturity_Date
        string Fund_Type_Code
        string Covered_Warrant_Type_Code
        decimal Exercise_Price
        string Exercise_Ratio
        string Exercise_Style_Code
        string Put_Or_Call_Code
        string Contract_Multiplier
        string Maturity_Month_Year
        decimal Coupon_Rate
        decimal Yield
        decimal Open_Price
        decimal High_Price
        decimal Low_Price
        decimal Ceiling_Price
        decimal Floor_Price
        decimal Reference_Price
        decimal Close_Price
        decimal Price_Change
        string Product_Group_Id
        string Source_System_Code
    }
    Fact_Derivative_Contract_Snapshot {
        string Derivative_Contract_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Security_Trading_Snapshot_Dimension_Id FK
        string Ticker_Symbol
        bigint Open_Interest_Quantity
        decimal Close_Price
    }
    Fact_Investor_Group_Trading_Snapshot {
        string Investor_Group_Trading_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Security_Trading_Snapshot_Dimension_Id FK
        string Security_Symbol_Code
        string Market_Id_Code
        string Investor_Group_Code
        bigint Buy_Volume
        decimal Buy_Value
        bigint Sell_Volume
        decimal Sell_Value
    }
    Calendar_Date_Dimension ||--o{ Fact_Derivative_Contract_Snapshot : " "
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Derivative_Contract_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Security_Trading_Snapshot_Dimension["Security Trading Snapshot Dimension"]
        Fact_Derivative_Contract_Snapshot["Fact Derivative Contract Snapshot"]
        Fact_Investor_Group_Trading_Snapshot["Fact Investor Group Trading Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 5"]
        R1["K_VP_1,18-19,21,29,31,39,41,49,51,59,61: Phái sinh: diễn biến KLGD và khối lượng mở"]
    end
    Calendar_Date_Dimension --> R1
    Security_Trading_Snapshot_Dimension --> R1
    Fact_Derivative_Contract_Snapshot --> R1
    Fact_Investor_Group_Trading_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Security Trading Snapshot Dimension | 1 mã chứng khoán / hợp đồng phái sinh (SCD4A current-state); sở hữu bởi GSTT |
| Fact Derivative Contract Snapshot | 1 mã hợp đồng phái sinh × 1 ngày giao dịch; PK Derivative Contract Snapshot Id = hash (Snapshot Date, Ticker Symbol) (Dạng B, A22) |
| Fact Investor Group Trading Snapshot | 1 mã chứng khoán / hợp đồng × 1 ngày giao dịch × 1 sàn (Market Id Code) × 1 nhóm NĐT (ALL / FOREIGN / PROPRIETARY); PK Investor Group Trading Snapshot Id = hash toàn bộ cột grain (Dạng B, A22) |

#### Nhóm 6 - Phái sinh >> Biểu đồ Khối lượng mua/bán ròng của NĐTNN

> Phân loại: **Phân tích**
> Atomic: `Securities Trade` ← ORDERTRADE.TRADE_BOOK_HNX — **READY** (nguồn Sổ lệnh chờ Atomic, O_VP_1); `Security Trading Snapshot` ← MDDS.JAD_STOCKINFOR — **READY**

**Mockup (suy từ BA — chưa có screenshot, O_VP_8):**

Tham số: Sản phẩm phái sinh · Loại kỳ (D/M/Q/Y) · Từ kỳ — Đến kỳ

| Kỳ | KLGD mua NĐTNN | KLGD bán NĐTNN | KL mua/bán ròng NĐTNN |
|---|---|---|---|
| 2026-09 | … | … | … |

> ⚠️ Presentation Grain: 1 điểm biểu đồ = 1 Kỳ × 1 Sản phẩm phái sinh. Storage Grain: 1 mã hợp đồng × 1 ngày × 1 sàn × 1 nhóm NĐT (Level 4) — đạt Iso-Grain.

**Source:** `Fact Investor Group Trading Snapshot` → `Calendar Date Dimension`, `Security Trading Snapshot Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Reuse từ Nhóm 1 (K_VP_1) — Case 1: measure vật lý có sẵn trên Fact/Dim | READY |
| K_VP_18 | Sản phẩm phái sinh | — | Chiều | Sản phẩm phái sinh = CONCAT(CASE Stock Type Code WHEN '4' THEN 'HĐTL' WHEN '5' THEN 'HĐ quyền chọn' END, ' ', CASE WHEN Product Group Id = 'FBX' THEN 'TPCP' ELSE Underlying Symbol END) trên Security Trading Snapshot Dimension với Floor Code = '03'; giá trị hiển thị: HĐTL VN30, HĐTL VN100, HĐTL TPCP, Toàn thị trường | Reuse từ Nhóm 3 (K_VP_18) — Case 1: measure vật lý có sẵn trên Fact/Dim | READY |
| K_VP_23 | KLGD mua NĐTNN | Hợp đồng | Cơ sở | SUM(Buy Volume) với Investor Group Code = 'FOREIGN' và Market Id Code = 'DVX' trong kỳ, theo Sản phẩm phái sinh | Reuse từ Nhóm 3 (K_VP_23) — Case 1: measure vật lý có sẵn trên Fact/Dim | READY |
| K_VP_25 | KLGD bán NĐTNN | Hợp đồng | Cơ sở | SUM(Sell Volume) với Investor Group Code = 'FOREIGN' và Market Id Code = 'DVX' trong kỳ, theo Sản phẩm phái sinh | Reuse từ Nhóm 3 (K_VP_25) — Case 1: measure vật lý có sẵn trên Fact/Dim | READY |
| K_VP_27 | KL mua/bán ròng NĐTNN | Hợp đồng | Phái sinh | K_VP_23 − K_VP_25 | Reuse từ Nhóm 3 (K_VP_27) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact | READY |
| K_VP_33 | KLGD mua NĐTNN - HĐTL VN30 | Hợp đồng | Cơ sở | K_VP_23 lọc Sản phẩm phái sinh = 'HĐTL VN30' (Stock Type Code = '4' AND Underlying Symbol = 'VN30') | Reuse từ Nhóm 3 (K_VP_33) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact | READY |
| K_VP_35 | KLGD bán NĐTNN - HĐTL VN30 | Hợp đồng | Cơ sở | K_VP_25 lọc Sản phẩm phái sinh = 'HĐTL VN30' (Stock Type Code = '4' AND Underlying Symbol = 'VN30') | Reuse từ Nhóm 3 (K_VP_35) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact | READY |
| K_VP_37 | KL mua/bán ròng NĐTNN - HĐTL VN30 | Hợp đồng | Cơ sở | K_VP_27 lọc Sản phẩm phái sinh = 'HĐTL VN30' (Stock Type Code = '4' AND Underlying Symbol = 'VN30') | Reuse từ Nhóm 3 (K_VP_37) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact | READY |
| K_VP_43 | KLGD mua NĐTNN - HĐTL VN100 | Hợp đồng | Cơ sở | K_VP_23 lọc Sản phẩm phái sinh = 'HĐTL VN100' (Stock Type Code = '4' AND Underlying Symbol = 'VN100') | Reuse từ Nhóm 3 (K_VP_43) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact | READY |
| K_VP_45 | KLGD bán NĐTNN - HĐTL VN100 | Hợp đồng | Cơ sở | K_VP_25 lọc Sản phẩm phái sinh = 'HĐTL VN100' (Stock Type Code = '4' AND Underlying Symbol = 'VN100') | Reuse từ Nhóm 3 (K_VP_45) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact | READY |
| K_VP_47 | KL mua/bán ròng NĐTNN - HĐTL VN100 | Hợp đồng | Cơ sở | K_VP_27 lọc Sản phẩm phái sinh = 'HĐTL VN100' (Stock Type Code = '4' AND Underlying Symbol = 'VN100') | Reuse từ Nhóm 3 (K_VP_47) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact | READY |
| K_VP_53 | KLGD mua NĐTNN - HĐTL TPCP | Hợp đồng | Cơ sở | K_VP_23 lọc Sản phẩm phái sinh = 'HĐTL TPCP' (Stock Type Code = '4' AND Product Group Id = 'FBX') | Reuse từ Nhóm 3 (K_VP_53) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact | READY |
| K_VP_55 | KLGD bán NĐTNN - HĐTL TPCP | Hợp đồng | Cơ sở | K_VP_25 lọc Sản phẩm phái sinh = 'HĐTL TPCP' (Stock Type Code = '4' AND Product Group Id = 'FBX') | Reuse từ Nhóm 3 (K_VP_55) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact | READY |
| K_VP_57 | KL mua/bán ròng NĐTNN - HĐTL TPCP | Hợp đồng | Cơ sở | K_VP_27 lọc Sản phẩm phái sinh = 'HĐTL TPCP' (Stock Type Code = '4' AND Product Group Id = 'FBX') | Reuse từ Nhóm 3 (K_VP_57) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact | READY |
| K_VP_63 | KLGD mua NĐTNN - Toàn thị trường | Hợp đồng | Cơ sở | K_VP_23 lọc Sản phẩm phái sinh = 'Toàn thị trường' (mọi hợp đồng phái sinh (Floor Code = '03'), không lọc sản phẩm) | Reuse từ Nhóm 3 (K_VP_63) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact. BA Mô tả ghi 'HĐTL TPCP' cho dòng Toàn thị trường; thiết kế theo Điều kiện (không lọc sản phẩm) — O_VP_6 | READY |
| K_VP_65 | KLGD bán NĐTNN - Toàn thị trường | Hợp đồng | Cơ sở | K_VP_25 lọc Sản phẩm phái sinh = 'Toàn thị trường' (mọi hợp đồng phái sinh (Floor Code = '03'), không lọc sản phẩm) | Reuse từ Nhóm 3 (K_VP_65) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact | READY |
| K_VP_67 | KL mua/bán ròng NĐTNN - Toàn thị trường | Hợp đồng | Cơ sở | K_VP_27 lọc Sản phẩm phái sinh = 'Toàn thị trường' (mọi hợp đồng phái sinh (Floor Code = '03'), không lọc sản phẩm) | Reuse từ Nhóm 3 (K_VP_67) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact | READY |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }
    Security_Trading_Snapshot_Dimension {
        string Security_Trading_Snapshot_Dimension_Id PK
        string Symbol
        string Security_Full_Name
        string Floor_Code
        string Stock_Type_Code
        string Stock_Type_Name
        string Underlying_Symbol
        string ISIN_Code
        string Issuer_Name
        bigint Listed_Share_Count
        date First_Trading_Date
        date Last_Trading_Date
        date Issue_Date
        date Maturity_Date
        string Fund_Type_Code
        string Covered_Warrant_Type_Code
        decimal Exercise_Price
        string Exercise_Ratio
        string Exercise_Style_Code
        string Put_Or_Call_Code
        string Contract_Multiplier
        string Maturity_Month_Year
        decimal Coupon_Rate
        decimal Yield
        decimal Open_Price
        decimal High_Price
        decimal Low_Price
        decimal Ceiling_Price
        decimal Floor_Price
        decimal Reference_Price
        decimal Close_Price
        decimal Price_Change
        string Product_Group_Id
        string Source_System_Code
    }
    Fact_Investor_Group_Trading_Snapshot {
        string Investor_Group_Trading_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Security_Trading_Snapshot_Dimension_Id FK
        string Security_Symbol_Code
        string Market_Id_Code
        string Investor_Group_Code
        bigint Buy_Volume
        decimal Buy_Value
        bigint Sell_Volume
        decimal Sell_Value
    }
    Calendar_Date_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Security_Trading_Snapshot_Dimension["Security Trading Snapshot Dimension"]
        Fact_Investor_Group_Trading_Snapshot["Fact Investor Group Trading Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 6"]
        R1["K_VP_1,18,23,25,27,33,35,37,43,45,47,53,55,57,63,65,67: Phái sinh: KL mua/bán ròng NĐTNN"]
    end
    Calendar_Date_Dimension --> R1
    Security_Trading_Snapshot_Dimension --> R1
    Fact_Investor_Group_Trading_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Security Trading Snapshot Dimension | 1 mã chứng khoán / hợp đồng phái sinh (SCD4A current-state); sở hữu bởi GSTT |
| Fact Investor Group Trading Snapshot | 1 mã chứng khoán / hợp đồng × 1 ngày giao dịch × 1 sàn (Market Id Code) × 1 nhóm NĐT (ALL / FOREIGN / PROPRIETARY); PK Investor Group Trading Snapshot Id = hash toàn bộ cột grain (Dạng B, A22) |

#### Nhóm 7 - TPDN niêm yết >> Chỉ tiêu tổng hợp

> Phân loại: **Phân tích**
> Atomic: `Securities Trade` ← ORDERTRADE.TRADE_BOOK_HNX — **READY** (nguồn Sổ lệnh chờ Atomic, O_VP_1); `Security Trading Snapshot` ← MDDS.JAD_STOCKINFOR — **READY**

**Mockup (suy từ BA — chưa có screenshot, O_VP_8):**

Tham số: Loại kỳ (D/M/Q/Y) · Kỳ

| Chỉ tiêu | Kỳ báo cáo | Kỳ trước (GTGD YTD và GTGD bình quân phiên YTD: cả năm trước) | Thay đổi | % thay đổi |
|---|---|---|---|---|
| KLGD | … | … | … | … |
| GTGD | … | … | … | … |
| GTGD YTD | … | … | … | … |
| GTGD bình quân phiên (YTD) | … | … | … | … |
| Giá trị mua NĐTNN | … | … | … | … |
| Giá trị bán NĐTNN | … | … | … | … |
| Giá trị mua/bán ròng NĐTNN | … | … | … | … |
| Số mã TP niêm yết | … | … | … | … |

> ⚠️ Presentation Grain: 1 dòng = 1 chỉ tiêu × 1 Kỳ, toàn thị trường TPDN niêm yết (Level 1). Storage Grain: Fact Listed Corporate Bond Snapshot = 1 mã trái phiếu × 1 ngày giao dịch (Level 4) — presentation thô hơn storage, đạt Iso-Grain. Chỉ tiêu YTD (GTGD YTD, GTGD bình quân phiên YTD) so với CẢ NĂM TRƯỚC (01/01–31/12); các chỉ tiêu còn lại so với kỳ trước (SQL BA).

**Source:** `Fact Listed Corporate Bond Snapshot` → `Calendar Date Dimension`, `Industry Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Reuse từ Nhóm 1 (K_VP_1) — Case 1: measure vật lý có sẵn trên Fact/Dim. BA ghi Phân loại 'Chỉ tiêu cơ sở' nhưng là Chiều thời gian — O_VP_20 | READY |
| K_VP_71 | Tổng KLGD | Trái phiếu | Cơ sở | SUM(Trading Volume) trên Fact Listed Corporate Bond Snapshot trong kỳ (giao dịch TPDN niêm yết: Market Id Code = 'HCX') | Case 1 — measure Trading Volume; [!] Nguồn Securities Trade — O_VP_1; giá trị 'HCX' chưa kiểm — O_VP_16 | READY |
| K_VP_72 | Tổng KLGD - % thay đổi (So sánh với kỳ trước) | % | Phái sinh | (K_VP_71 kỳ báo cáo − K_VP_71 kỳ trước) / K_VP_71 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_73 | Tổng GTGD | VND | Cơ sở | SUM(Trading Value) trên Fact Listed Corporate Bond Snapshot trong kỳ; Trading Value = Σ (KLGD × Giá khớp) = Execution Value của Sổ lệnh HNX với Market Id Code = 'HCX' | Case 1 — measure Trading Value; [!] Nguồn Securities Trade — O_VP_1; giá trị 'HCX' chưa kiểm — O_VP_16 | READY |
| K_VP_74 | Tổng GTGD - % thay đổi (So sánh với kỳ trước) | % | Phái sinh | (K_VP_73 kỳ báo cáo − K_VP_73 kỳ trước) / K_VP_73 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_112 | GTGD YTD | VND | Phái sinh | K_VP_73 lấy trên khoảng từ 01/01 của năm chứa kỳ báo cáo đến ngày cuối kỳ (YTD); kỳ so sánh = CẢ NĂM TRƯỚC (01/01–31/12 năm trước), không phải cùng kỳ năm trước | Case 2 — tính tại presentation layer; BA CSV thiếu dòng (alias gtgd_ytd của SQL BA dòng 113, H17) — O_VP_18; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_113 | GTGD YTD - % thay đổi (So sánh với năm trước) | % | Phái sinh | (K_VP_112 kỳ báo cáo − K_VP_112 cả năm trước) / K_VP_112 cả năm trước × 100 | Case 2 — tính tại presentation layer; BA CSV thiếu dòng (change_percent của gtgd_ytd trong SQL BA dòng 113, H17) — O_VP_18; so với cả năm trước — O_VP_20 | READY |
| K_VP_75 | GTGD bình quân phiên (YTD) | VND | Phái sinh | K_VP_112 / Số phiên giao dịch YTD; Số phiên = COUNT(DISTINCT Snapshot Date) trên Fact Listed Corporate Bond Snapshot với Trading Value IS NOT NULL (ngày có giao dịch TPDN niêm yết) từ 01/01 đến ngày cuối kỳ; kỳ so sánh = cả năm trước (01/01–31/12) | Case 2 — tính tại presentation layer; số phiên theo định nghĩa Nhóm 7 (ngày có giao dịch TPDN niêm yết) — O_VP_22 | READY |
| K_VP_76 | GTGD bình quân phiên YTD - % thay đổi (So sánh với GTGD BQ YTD năm trước) | % | Phái sinh | (K_VP_75 kỳ báo cáo − K_VP_75 cả năm trước) / K_VP_75 cả năm trước × 100 | Case 2 — tính tại presentation layer; nhãn BA 'YTD năm trước' nhưng SQL/Điều kiện dòng 118 so với cả năm trước — O_VP_20 | READY |
| K_VP_77 | Giá trị mua NĐTNN | VND | Cơ sở | SUM(Foreign Buy Value) trên Fact Listed Corporate Bond Snapshot trong kỳ; Foreign Buy Value = Σ Execution Value của giao dịch có ký tự thứ 4 của số tài khoản mua ∈ ('E','F') | Case 1 — measure Foreign Buy Value; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_78 | Giá trị mua NĐTNN - % thay đổi (So sánh với kỳ trước) | % | Phái sinh | (K_VP_77 kỳ báo cáo − K_VP_77 kỳ trước) / K_VP_77 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_79 | Giá trị bán NĐTNN | VND | Cơ sở | SUM(Foreign Sell Value) trên Fact Listed Corporate Bond Snapshot trong kỳ; Foreign Sell Value = Σ Execution Value của giao dịch có ký tự thứ 4 của số tài khoản bán ∈ ('E','F') | Case 1 — measure Foreign Sell Value; BA dòng 122 chép công thức của dòng mua (buy_account_number) — dùng số tài khoản bán theo Mô tả/SQL, O_VP_20; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_80 | Giá trị bán NĐTNN - % thay đổi (So sánh với kỳ trước) | % | Phái sinh | (K_VP_79 kỳ báo cáo − K_VP_79 kỳ trước) / K_VP_79 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_81 | Giá trị mua/bán ròng NĐTNN | VND | Phái sinh | K_VP_77 − K_VP_79 | Case 2 — tính tại presentation layer từ Foreign Buy Value / Foreign Sell Value; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_82 | Giá trị mua/bán ròng NĐTNN - % thay đổi (So sánh với kỳ trước) | % | Phái sinh | (K_VP_81 kỳ báo cáo − K_VP_81 kỳ trước) / K_VP_81 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5; BA không dùng ABS (kỳ trước âm đảo dấu) — O_VP_20 | READY |
| K_VP_83 | Số mã TP niêm yết | Mã | Cơ sở | COUNT(DISTINCT Security Symbol Code) trên Fact Listed Corporate Bond Snapshot với Listed Indicator = TRUE và Snapshot Date ≤ ngày cuối kỳ (mỗi mã tính 1 lần theo bản ghi mới nhất không quá ngày cuối kỳ, gồm cả mã đã đáo hạn; bản tin MDDS Stock Type Code = '1') | Case 1 — Listed Indicator trên Fact Listed Corporate Bond Snapshot; số thời điểm tại ngày cuối kỳ; Stock Type Code '1' gồm cả TPCP — O_VP_17; theo Điều kiện BA (Vuong chốt 2026-10-25): bản ghi mới nhất của từng mã ≤ ngày cuối kỳ, nên đếm cả mã đã đáo hạn; SQL BA đếm tại ngày giao dịch cuối trong kỳ — O_VP_20 | READY |
| K_VP_114 | Số mã TP niêm yết - % thay đổi (So sánh với kỳ trước) | % | Phái sinh | (K_VP_83 kỳ báo cáo − K_VP_83 kỳ trước) / K_VP_83 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5; BA CSV thiếu dòng (change_percent của sl_ma_niemyet trong SQL BA dòng 113, H17) — O_VP_18 | READY |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }
    Industry_Dimension {
        string Industry_Dimension_Id PK
        string Industry_Code
        string Industry_Name
        string Source_System_Code
    }
    Fact_Listed_Corporate_Bond_Snapshot {
        string Listed_Corporate_Bond_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Industry_Dimension_Id FK
        string Security_Symbol_Code
        boolean Listed_Indicator
        decimal Issue_Term_Years
        decimal Remaining_Term_Years
        bigint Trading_Volume
        decimal Trading_Value
        decimal Foreign_Buy_Value
        decimal Foreign_Sell_Value
        bigint Outstanding_Bond_Quantity
        decimal Bond_Outstanding_Value
    }
    Calendar_Date_Dimension ||--o{ Fact_Listed_Corporate_Bond_Snapshot : " "
    Industry_Dimension ||--o{ Fact_Listed_Corporate_Bond_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Industry_Dimension["Industry Dimension"]
        Fact_Listed_Corporate_Bond_Snapshot["Fact Listed Corporate Bond Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 7"]
        R1["K_VP_1,71-83,112-114: TPDN niêm yết: chỉ tiêu tổng hợp"]
    end
    Calendar_Date_Dimension --> R1
    Industry_Dimension --> R1
    Fact_Listed_Corporate_Bond_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Industry Dimension | 1 ngành nghề kinh doanh cấp 1 hiện hành (SCD4A current-state); sở hữu bởi GSDC |
| Fact Listed Corporate Bond Snapshot | 1 mã trái phiếu (ISIN — Security Symbol Code) × 1 ngày giao dịch; PK Listed Corporate Bond Snapshot Id = hash (Snapshot Date Dimension Id, Security Symbol Code) (Dạng B, A22) |

#### Nhóm 8 - TPDN niêm yết >> Thống kê giao dịch TPDN niêm yết theo ngành

> Phân loại: **Phân tích**
> Atomic: `Securities Trade` ← ORDERTRADE.TRADE_BOOK_HNX — **READY** (nguồn Sổ lệnh chờ Atomic, O_VP_1); `Security Trading Snapshot` ← MDDS.JAD_STOCKINFOR — **READY**; `Listed Share Information` ← HNX.LISTED_SECURITIES_LIST — **READY**; `Public Company` ← IDS.COMPANY_PROFILES — **READY**; `Securities Company` ← SCMS.SC_FIRM_INFO — **READY**; `Fund Management Company` ← FMS.SECURITIES — **READY**; `Classification IDS Business Line` ← IDS.CATEGORIES — **READY**

**Mockup (suy từ BA — chưa có screenshot, O_VP_8):**

Tham số: Loại kỳ (D/M/Q/Y) · Kỳ

| Ngành | Kỳ hạn phát hành (năm) | GTGD | Số mã TP niêm yết | KL TP đang lưu hành | Kỳ hạn còn lại bình quân (năm) |
|---|---|---|---|---|---|
| Tài chính ngân hàng | 5,00 | … | … | … | … |

> ⚠️ Presentation Grain: 1 dòng = 1 Ngành × 1 Kỳ hạn phát hành trong 1 Kỳ (Level 3 × kỳ hạn). Storage Grain: Fact Listed Corporate Bond Snapshot = 1 mã trái phiếu × 1 ngày giao dịch (Level 4) — presentation thô hơn storage, đạt Iso-Grain.

**Source:** `Fact Listed Corporate Bond Snapshot` → `Calendar Date Dimension`, `Industry Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Reuse từ Nhóm 1 (K_VP_1) — Case 1: measure vật lý có sẵn trên Fact/Dim. BA ghi Phân loại 'Chỉ tiêu cơ sở' nhưng là Chiều thời gian — O_VP_20 | READY |
| K_VP_84 | Ngành | — | Chiều | Industry Dimension.Industry Code / Industry Name theo Industry Dimension Id của Fact Listed Corporate Bond Snapshot; Industry Dimension Id NULL → nhóm 'NA' / 'Chưa phân ngành' | Case 1 — reuse Industry Dimension (GSDC). Ngành của tổ chức phát hành: 3 ký tự đầu mã trái phiếu = Equity Ticker Symbol của Public Company (bỏ hồ sơ bị từ chối); CTCK / CTQLQ → '07000' (SQL BA dòng 128) — O_VP_23 | READY |
| K_VP_85 | Kỳ hạn phát hành | Năm | Chiều | Issue Term Years = ROUND(MONTHS_BETWEEN(Maturity Date, Issue Date) / 12, 2) của bản tin cuối ngày MDDS (Stock Type Code = '1') trên Fact Listed Corporate Bond Snapshot | Case 1 — cột Issue Term Years trên Fact Listed Corporate Bond Snapshot; NULL khi giao dịch không có bản tin cùng ngày | READY |
| K_VP_86 | Tổng GTGD TPDN niêm yết | VND | Cơ sở | SUM(Trading Value) theo (Ngành, Kỳ hạn phát hành) trong kỳ (Market Id Code = 'HCX'); giao dịch không có bản tin MDDS cùng ngày thuộc nhóm Ngành 'NA' và Kỳ hạn phát hành NULL | Case 1 — measure Trading Value; nối Sổ lệnh ↔ bản tin MDDS theo Issue Code = ISIN Code và ngày (SQL BA dòng 127/130); [!] Nguồn Securities Trade — O_VP_1; O_VP_16 | READY |
| K_VP_87 | Kỳ hạn còn lại bình quân | Năm | Phái sinh | SUM(Remaining Term Years × Bond Outstanding Value) / SUM(Bond Outstanding Value) theo (Ngành, Kỳ hạn phát hành) tại ngày giao dịch cuối cùng có bản tin trong kỳ, làm tròn 2 chữ số thập phân | Case 2 — tính tại presentation layer từ Remaining Term Years và Bond Outstanding Value. Remaining Term Years = MONTHS_BETWEEN(Maturity Date, Trading Date) / 12 (không làm tròn); Bond Outstanding Value = Outstanding Bond Quantity × mệnh giá, mệnh giá = 100000 × 10^ROUND(LOG10(Reference Price / 100000)); SQL/Điều kiện BA dòng 131 sai — O_VP_20; khóa Atomic Listed Share Information — O_VP_15 | READY |
| K_VP_83 | Số mã TP niêm yết | Mã | Cơ sở | COUNT(DISTINCT Security Symbol Code) trên Fact Listed Corporate Bond Snapshot với Listed Indicator = TRUE và Snapshot Date ≤ ngày cuối kỳ (mỗi mã tính 1 lần theo bản ghi mới nhất không quá ngày cuối kỳ, gồm cả mã đã đáo hạn; bản tin MDDS Stock Type Code = '1') | Reuse từ Nhóm 7 (K_VP_83) — Case 1: measure vật lý có sẵn trên Fact/Dim. Nhóm 8 gom theo (Ngành, Kỳ hạn phát hành) tại ngày cuối kỳ; BA 'Trùng' nhưng SQL nối INNER Listed Securities List — O_VP_20 | READY |
| K_VP_88 | KL TP đang lưu hành | Trái phiếu | Cơ sở | SUM(Outstanding Bond Quantity) theo (Ngành, Kỳ hạn phát hành) tại ngày giao dịch cuối cùng có bản tin trong kỳ | Case 1 — measure Outstanding Bond Quantity (Listed Share Information HNX nối theo Ticker Symbol và Report Date = Trading Date); BA ghi Mapping nghiệp vụ VSDC nhưng Bảng nguồn HNX — theo Bảng nguồn, O_VP_20; khóa Atomic — O_VP_15 | READY |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }
    Industry_Dimension {
        string Industry_Dimension_Id PK
        string Industry_Code
        string Industry_Name
        string Source_System_Code
    }
    Fact_Listed_Corporate_Bond_Snapshot {
        string Listed_Corporate_Bond_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Industry_Dimension_Id FK
        string Security_Symbol_Code
        boolean Listed_Indicator
        decimal Issue_Term_Years
        decimal Remaining_Term_Years
        bigint Trading_Volume
        decimal Trading_Value
        decimal Foreign_Buy_Value
        decimal Foreign_Sell_Value
        bigint Outstanding_Bond_Quantity
        decimal Bond_Outstanding_Value
    }
    Calendar_Date_Dimension ||--o{ Fact_Listed_Corporate_Bond_Snapshot : " "
    Industry_Dimension ||--o{ Fact_Listed_Corporate_Bond_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Industry_Dimension["Industry Dimension"]
        Fact_Listed_Corporate_Bond_Snapshot["Fact Listed Corporate Bond Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 8"]
        R1["K_VP_1,83-88: TPDN niêm yết: thống kê giao dịch theo ngành và kỳ hạn"]
    end
    Calendar_Date_Dimension --> R1
    Industry_Dimension --> R1
    Fact_Listed_Corporate_Bond_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Industry Dimension | 1 ngành nghề kinh doanh cấp 1 hiện hành (SCD4A current-state); sở hữu bởi GSDC |
| Fact Listed Corporate Bond Snapshot | 1 mã trái phiếu (ISIN — Security Symbol Code) × 1 ngày giao dịch; PK Listed Corporate Bond Snapshot Id = hash (Snapshot Date Dimension Id, Security Symbol Code) (Dạng B, A22) |

#### Nhóm 9 - TPDN niêm yết >> Biểu đồ Thống kê GTGD TPDN niêm yết và TPDN riêng lẻ

> Phân loại: **Phân tích**
> Atomic: `Securities Trade` ← ORDERTRADE.TRADE_BOOK_HNX — **READY** (nguồn Sổ lệnh chờ Atomic, O_VP_1); `Security Trading Snapshot` ← MDDS.JAD_STOCKINFOR — **READY**; `Internal Statistical Report` ← ISS.INTERNAL_STATISTICAL_REPORT — **READY**

**Mockup (suy từ BA — chưa có screenshot, O_VP_8):**

Tham số: Loại kỳ (D/M/Q/Y) · Từ kỳ — Đến kỳ

| Kỳ | GTGD TPDN niêm yết | GTGD TPDN riêng lẻ |
|---|---|---|
| 2026-09 | … | … |

> ⚠️ Presentation Grain: 1 điểm biểu đồ = 1 Kỳ × 1 loại trái phiếu (niêm yết / riêng lẻ), toàn thị trường (Level 1). Storage Grain: Fact Listed Corporate Bond Snapshot = 1 mã × 1 ngày (Level 4); Fact Private Corporate Bond Trading Snapshot = 1 ngày báo cáo HNX09, toàn thị trường TPDN riêng lẻ (Level 1) — đạt Iso-Grain.

**Source:** `Fact Listed Corporate Bond Snapshot` → `Calendar Date Dimension`, `Industry Dimension`; `Fact Private Corporate Bond Trading Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Reuse từ Nhóm 1 (K_VP_1) — Case 1: measure vật lý có sẵn trên Fact/Dim. BA ghi Phân loại 'Chỉ tiêu cơ sở' nhưng là Chiều thời gian (Từ kỳ — Đến kỳ) — O_VP_20 | READY |
| K_VP_73 | GTGD TPDN niêm yết | VND | Cơ sở | SUM(Trading Value) trên Fact Listed Corporate Bond Snapshot trong kỳ; Trading Value = Σ (KLGD × Giá khớp) = Execution Value của Sổ lệnh HNX với Market Id Code = 'HCX' | Reuse từ Nhóm 7 (K_VP_73) — Case 1: measure vật lý có sẵn trên Fact/Dim. Nhóm 9 gom theo kỳ trong khoảng Từ kỳ — Đến kỳ; [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_89 | GTGD TPDN riêng lẻ | VND | Cơ sở | SUM(Trading Value) trên Fact Private Corporate Bond Trading Snapshot trong kỳ; Trading Value = Cell Value (ép số) của ô Row Path = 'GIÁ TRỊ GIAO DỊCH' báo cáo HNX09 | Case 1 — measure Trading Value; Atomic Internal Statistical Report lọc Report Code = 'HNX09', Sheet Name = 'sheet 1', Column Path = 'GIÁ TRỊ', Period Type Code = 'DAILY', Report Submission System Code = 'ICP', Submission Status Code IN ('SUBMITTED','LATE_SUBMITTED'); dữ liệu TPDN riêng lẻ không nằm trong sổ lệnh; BA ghi Mapping nghiệp vụ '#NAME?' — O_VP_20; khóa Atomic — O_VP_21 | READY |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }
    Industry_Dimension {
        string Industry_Dimension_Id PK
        string Industry_Code
        string Industry_Name
        string Source_System_Code
    }
    Fact_Listed_Corporate_Bond_Snapshot {
        string Listed_Corporate_Bond_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Industry_Dimension_Id FK
        string Security_Symbol_Code
        boolean Listed_Indicator
        decimal Issue_Term_Years
        decimal Remaining_Term_Years
        bigint Trading_Volume
        decimal Trading_Value
        decimal Foreign_Buy_Value
        decimal Foreign_Sell_Value
        bigint Outstanding_Bond_Quantity
        decimal Bond_Outstanding_Value
    }
    Fact_Private_Corporate_Bond_Trading_Snapshot {
        string Private_Corporate_Bond_Trading_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        decimal Trading_Value
        decimal Foreign_Buy_Value
        decimal Foreign_Sell_Value
    }
    Calendar_Date_Dimension ||--o{ Fact_Listed_Corporate_Bond_Snapshot : " "
    Industry_Dimension ||--o{ Fact_Listed_Corporate_Bond_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Private_Corporate_Bond_Trading_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Industry_Dimension["Industry Dimension"]
        Fact_Listed_Corporate_Bond_Snapshot["Fact Listed Corporate Bond Snapshot"]
        Fact_Private_Corporate_Bond_Trading_Snapshot["Fact Private Corporate Bond Trading Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 9"]
        R1["K_VP_1,73,89: TPDN: GTGD niêm yết và riêng lẻ theo kỳ"]
    end
    Calendar_Date_Dimension --> R1
    Industry_Dimension --> R1
    Fact_Listed_Corporate_Bond_Snapshot --> R1
    Fact_Private_Corporate_Bond_Trading_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Industry Dimension | 1 ngành nghề kinh doanh cấp 1 hiện hành (SCD4A current-state); sở hữu bởi GSDC |
| Fact Listed Corporate Bond Snapshot | 1 mã trái phiếu (ISIN — Security Symbol Code) × 1 ngày giao dịch; PK Listed Corporate Bond Snapshot Id = hash (Snapshot Date Dimension Id, Security Symbol Code) (Dạng B, A22) |
| Fact Private Corporate Bond Trading Snapshot | 1 ngày báo cáo HNX09 (báo cáo ngày TPDN riêng lẻ, nguồn nộp ICP); PK Private Corporate Bond Trading Snapshot Id = hash (Snapshot Date Dimension Id) (Dạng B, A22) |

#### Nhóm 10 - TPDN niêm yết >> Biểu đồ Giá trị giao dịch TPDN theo ngành

> Phân loại: **Phân tích**
> Atomic: `Securities Trade` ← ORDERTRADE.TRADE_BOOK_HNX — **READY** (nguồn Sổ lệnh chờ Atomic, O_VP_1); `Security Trading Snapshot` ← MDDS.JAD_STOCKINFOR — **READY**; `Public Company` ← IDS.COMPANY_PROFILES — **READY**; `Securities Company` ← SCMS.SC_FIRM_INFO — **READY**; `Fund Management Company` ← FMS.SECURITIES — **READY**; `Classification IDS Business Line` ← IDS.CATEGORIES — **READY**

**Mockup (suy từ BA — chưa có screenshot, O_VP_8):**

Tham số: Loại kỳ (D/M/Q/Y) · Kỳ

| Ngành | GTGD | Tỷ trọng GTGD (%) |
|---|---|---|
| Tài chính ngân hàng | … | … |

> ⚠️ Presentation Grain: 1 dòng = 1 Ngành trong 1 Kỳ (Level 3). Storage Grain: Fact Listed Corporate Bond Snapshot = 1 mã trái phiếu × 1 ngày giao dịch (Level 4) — presentation thô hơn storage, đạt Iso-Grain.

**Source:** `Fact Listed Corporate Bond Snapshot` → `Calendar Date Dimension`, `Industry Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Reuse từ Nhóm 1 (K_VP_1) — Case 1: measure vật lý có sẵn trên Fact/Dim | READY |
| K_VP_84 | Ngành | — | Chiều | Industry Dimension.Industry Code / Industry Name theo Industry Dimension Id của Fact Listed Corporate Bond Snapshot; Industry Dimension Id NULL → nhóm 'NA' / 'Chưa phân ngành' | Reuse từ Nhóm 8 (K_VP_84) — Case 1: measure vật lý có sẵn trên Fact/Dim | READY |
| K_VP_86 | GTGD trái phiếu từng ngành | VND | Cơ sở | SUM(Trading Value) theo (Ngành, Kỳ hạn phát hành) trong kỳ (Market Id Code = 'HCX'); giao dịch không có bản tin MDDS cùng ngày thuộc nhóm Ngành 'NA' và Kỳ hạn phát hành NULL | Reuse từ Nhóm 8 (K_VP_86) — Case 1: measure vật lý có sẵn trên Fact/Dim. Nhóm 10 gom theo Ngành (cộng Trading Value qua các Kỳ hạn phát hành); [!] Nguồn Securities Trade — O_VP_1 | READY |
| K_VP_90 | Tỷ trọng GTGD theo ngành | % | Phái sinh | K_VP_86 của từng Ngành / SUM(K_VP_86 của mọi Ngành trong kỳ, kể cả nhóm 'NA') × 100, làm tròn 2 chữ số thập phân | Case 2 — tính tại presentation layer; mẫu số = tổng GTGD toàn thị trường TPDN niêm yết gồm cả giao dịch chưa phân ngành (SQL BA dòng 137) | READY |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }
    Industry_Dimension {
        string Industry_Dimension_Id PK
        string Industry_Code
        string Industry_Name
        string Source_System_Code
    }
    Fact_Listed_Corporate_Bond_Snapshot {
        string Listed_Corporate_Bond_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Industry_Dimension_Id FK
        string Security_Symbol_Code
        boolean Listed_Indicator
        decimal Issue_Term_Years
        decimal Remaining_Term_Years
        bigint Trading_Volume
        decimal Trading_Value
        decimal Foreign_Buy_Value
        decimal Foreign_Sell_Value
        bigint Outstanding_Bond_Quantity
        decimal Bond_Outstanding_Value
    }
    Calendar_Date_Dimension ||--o{ Fact_Listed_Corporate_Bond_Snapshot : " "
    Industry_Dimension ||--o{ Fact_Listed_Corporate_Bond_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Industry_Dimension["Industry Dimension"]
        Fact_Listed_Corporate_Bond_Snapshot["Fact Listed Corporate Bond Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 10"]
        R1["K_VP_1,84,86,90: TPDN niêm yết: GTGD và tỷ trọng theo ngành"]
    end
    Calendar_Date_Dimension --> R1
    Industry_Dimension --> R1
    Fact_Listed_Corporate_Bond_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Industry Dimension | 1 ngành nghề kinh doanh cấp 1 hiện hành (SCD4A current-state); sở hữu bởi GSDC |
| Fact Listed Corporate Bond Snapshot | 1 mã trái phiếu (ISIN — Security Symbol Code) × 1 ngày giao dịch; PK Listed Corporate Bond Snapshot Id = hash (Snapshot Date Dimension Id, Security Symbol Code) (Dạng B, A22) |

#### Nhóm 11 - TPDN riêng lẻ >> Chỉ tiêu tổng hợp

> Phân loại: **Phân tích**
> Atomic: `Internal Statistical Report` ← ISS.INTERNAL_STATISTICAL_REPORT — **READY**; `Private Corp Bond Registration` ← HNX.PRIVATE_CORP_BOND_REGISTRATION — **READY**

**Mockup (suy từ BA — chưa có screenshot, O_VP_8):**

Tham số: Loại kỳ (D/M/Q/Y) · Kỳ

| Chỉ tiêu | Kỳ báo cáo | Kỳ trước (GTGD bình quân phiên YTD: cả năm trước) | Thay đổi | % thay đổi |
|---|---|---|---|---|
| GTGD | … | … | … | … |
| GTGD bình quân phiên (YTD) | … | … | … | … |
| Giá trị mua NĐTNN | … | … | … | … |
| Giá trị bán NĐTNN | … | … | … | … |
| Giá trị mua/bán ròng NĐTNN | … | … | … | … |
| Số mã TP ĐKGD | … | … | … | … |

> ⚠️ Presentation Grain: 1 dòng = 1 chỉ tiêu × 1 Kỳ, toàn thị trường TPDN riêng lẻ (Level 1). Storage Grain: Fact Private Corporate Bond Trading Snapshot = 1 ngày báo cáo HNX09, toàn thị trường (Level 1 × ngày); Fact Private Corporate Bond Registration Snapshot = 1 mã trái phiếu × 1 tháng báo cáo (Level 4 × tháng) — presentation thô hơn storage, đạt Iso-Grain. Số mã ĐKGD là số thời điểm: loại kỳ Ngày chọn tháng báo cáo theo quy tắc BA (ngày cuối tháng → tháng đó, ngược lại tháng liền trước), không phải Grain Mismatch. Chỉ tiêu GTGD bình quân phiên (YTD) so với CẢ NĂM TRƯỚC (01/01–31/12); các chỉ tiêu còn lại so với kỳ trước (SQL BA).

**Source:** `Fact Private Corporate Bond Trading Snapshot` → `Calendar Date Dimension`; `Fact Private Corporate Bond Registration Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Reuse từ Nhóm 1 (K_VP_1) — Case 1: measure vật lý có sẵn trên Fact/Dim. BA ghi Phân loại 'Chỉ tiêu cơ sở' nhưng là Chiều thời gian — O_VP_29 | READY |
| K_VP_89 | GTGD TPDN riêng lẻ | VND | Cơ sở | SUM(Trading Value) trên Fact Private Corporate Bond Trading Snapshot trong kỳ; Trading Value = Cell Value (ép số) của ô Row Path = 'GIÁ TRỊ GIAO DỊCH' báo cáo HNX09 | Reuse từ Nhóm 9 (K_VP_89) — Case 1: measure vật lý có sẵn trên Fact/Dim. Nhóm 11 gom theo kỳ (Σ Trading Value trong kỳ) | READY |
| K_VP_91 | GTGD TPDN riêng lẻ - So sánh với kỳ trước (% thay đổi) | % | Phái sinh | (K_VP_89 kỳ báo cáo − K_VP_89 kỳ trước) / K_VP_89 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5; BA đánh giá 'Trùng' nhưng Nhóm 9 chỉ có K_VP_89 (không có % thay đổi) nên khai sinh K_VP_91 — O_VP_29 | READY |
| K_VP_92 | GTGD bình quân phiên (YTD) | VND | Phái sinh | SUM(Trading Value) trên Fact Private Corporate Bond Trading Snapshot từ 01/01 của năm chứa kỳ báo cáo đến ngày cuối kỳ / Số phiên giao dịch cùng khoảng; Số phiên = COUNT(ngày trong Calendar Date Dimension có Is Trading Date = 'Y' trong khoảng 01/01 – ngày cuối kỳ) | Case 2 — tính tại presentation layer từ Trading Value (Fact Private Corporate Bond Trading Snapshot) và Calendar Date Dimension; BA đếm số phiên theo mọi ngày có Sổ lệnh HNX (`trade_book`) — dùng Is Trading Date làm proxy, lệch BA nhẹ — O_VP_30; BA ghi Điều kiện 'GTGD kỳ / Số phiên' nhưng Mô tả/SQL dùng Σ GTGD từ đầu năm — O_VP_29 | READY |
| K_VP_93 | GTGD bình quân phiên (YTD) - % thay đổi (So sánh với GTGD BQ phiên YTD năm trước) | % | Phái sinh | (K_VP_92 kỳ báo cáo − K_VP_92 cả năm trước (01/01–31/12 năm trước)) / K_VP_92 cả năm trước × 100 | Case 2 — tính tại presentation layer; nhãn BA 'YTD năm trước' nhưng SQL dòng 141 so với CẢ NĂM TRƯỚC; bảng nguồn dòng 145 ghi `hose.trade_book` — theo dòng 144/SQL (HNX) — O_VP_29 | READY |
| K_VP_94 | Giá trị mua NĐTNN | VND | Cơ sở | SUM(Foreign Buy Value) trên Fact Private Corporate Bond Trading Snapshot trong kỳ; Foreign Buy Value = Cell Value (ép số) của ô Row Path = 'GIÁ TRỊ GIAO DỊCH NHÀ ĐẦU TƯ NƯỚC NGOÀI - GIÁ TRỊ MUA' báo cáo HNX09 | Case 1 — measure Foreign Buy Value; lọc nguồn HNX09 như K_VP_89 (ICP, đã nộp) — O_VP_21; BA ghi Mapping nghiệp vụ '#NAME?' — O_VP_29 | READY |
| K_VP_95 | Giá trị mua NĐTNN - So sánh với kỳ trước (% thay đổi) | % | Phái sinh | (K_VP_94 kỳ báo cáo − K_VP_94 kỳ trước) / K_VP_94 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_96 | Giá trị bán NĐTNN | VND | Cơ sở | SUM(Foreign Sell Value) trên Fact Private Corporate Bond Trading Snapshot trong kỳ; Foreign Sell Value = Cell Value (ép số) của ô Row Path = 'GIÁ TRỊ GIAO DỊCH NHÀ ĐẦU TƯ NƯỚC NGOÀI - GIÁ TRỊ BÁN' báo cáo HNX09 | Case 1 — measure Foreign Sell Value; lọc nguồn HNX09 như K_VP_89 (ICP, đã nộp) — O_VP_21 | READY |
| K_VP_97 | Giá trị bán NĐTNN - So sánh với kỳ trước (% thay đổi) | % | Phái sinh | (K_VP_96 kỳ báo cáo − K_VP_96 kỳ trước) / K_VP_96 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_98 | Giá trị mua/bán ròng NĐTNN | VND | Phái sinh | K_VP_94 − K_VP_96 | Case 2 — tính tại presentation layer từ Foreign Buy Value / Foreign Sell Value | READY |
| K_VP_99 | Giá trị mua/bán ròng NĐTNN - So sánh với kỳ trước (% thay đổi) | % | Phái sinh | (K_VP_98 kỳ báo cáo − K_VP_98 kỳ trước) / ABS(K_VP_98 kỳ trước) × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5; Mô tả và SQL dòng 151 chia ABS(kỳ trước) trong khi dòng 125 (Nhóm 7) và dòng 170 (Nhóm 14) không dùng ABS — O_VP_29 | READY |
| K_VP_100 | Số mã TP ĐKGD | Mã | Cơ sở | COUNT(DISTINCT Bond Code) trên Fact Private Corporate Bond Registration Snapshot với Maturity Date > ngày cuối kỳ, tại tháng báo cáo được chọn theo loại kỳ: Tháng = chính tháng đó; Quý / Năm = tháng báo cáo mới nhất có dữ liệu trong quý/năm (Snapshot Date lớn nhất trong kỳ); Ngày = tháng của ngày tra cứu nếu là ngày cuối tháng, ngược lại tháng liền trước | Case 1 — COUNT(DISTINCT Bond Code) trên Fact Private Corporate Bond Registration Snapshot (factless, mỗi dòng = 1 mã đăng ký giao dịch của 1 tháng báo cáo); số thời điểm tại ngày cuối kỳ; BA ghi Loại dữ liệu 'Chưa có CSDL - Map biểu mẫu' nhưng SQL đọc `private_corp_bond_registration` (Atomic có) — READY, O_VP_29; khóa Atomic chỉ băm Bond Code — O_VP_26; FK ngày = ngày cuối tháng báo cáo — O_VP_27 | READY |
| K_VP_101 | Số mã TP ĐKGD - So sánh với kỳ trước (% thay đổi) | % | Phái sinh | (K_VP_100 kỳ báo cáo − K_VP_100 kỳ trước) / K_VP_100 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước chọn tháng báo cáo theo cùng quy tắc K_VP_100 — O_VP_5; SQL BA chia ABS(kỳ trước) — vô nghĩa với số đếm ≥ 0, giữ theo Mô tả | READY |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }
    Fact_Private_Corporate_Bond_Trading_Snapshot {
        string Private_Corporate_Bond_Trading_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        decimal Trading_Value
        decimal Foreign_Buy_Value
        decimal Foreign_Sell_Value
    }
    Fact_Private_Corporate_Bond_Registration_Snapshot {
        string Private_Corporate_Bond_Registration_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Bond_Code
        string Report_Year
        string Report_Month
        date Maturity_Date
    }
    Calendar_Date_Dimension ||--o{ Fact_Private_Corporate_Bond_Trading_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Private_Corporate_Bond_Registration_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Private_Corporate_Bond_Trading_Snapshot["Fact Private Corporate Bond Trading Snapshot"]
        Fact_Private_Corporate_Bond_Registration_Snapshot["Fact Private Corporate Bond Registration Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 11"]
        R1["K_VP_1,89,91-101: TPDN riêng lẻ: chỉ tiêu tổng hợp"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Private_Corporate_Bond_Trading_Snapshot --> R1
    Fact_Private_Corporate_Bond_Registration_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Private Corporate Bond Trading Snapshot | 1 ngày báo cáo HNX09 (báo cáo ngày TPDN riêng lẻ, nguồn nộp ICP); PK Private Corporate Bond Trading Snapshot Id = hash (Snapshot Date Dimension Id) (Dạng B, A22) |
| Fact Private Corporate Bond Registration Snapshot | 1 mã trái phiếu (Bond Code) × 1 tháng báo cáo (Report Year, Report Month); PK Private Corporate Bond Registration Snapshot Id = hash (Bond Code, Report Year, Report Month) (Dạng B, A22) |

#### Nhóm 12 - TPDN riêng lẻ >> Biểu đồ Diễn biến giao dịch thị trường TPDN riêng lẻ

> Phân loại: **Phân tích**
> Atomic: `Internal Statistical Report` ← ISS.INTERNAL_STATISTICAL_REPORT — **READY**

**Mockup (suy từ BA — chưa có screenshot, O_VP_8):**

Tham số: Loại kỳ (D/M/Q/Y) · Từ kỳ — Đến kỳ

| Kỳ | GTGD TPDN riêng lẻ |
|---|---|
| 2026-09 | … |

> ⚠️ Presentation Grain: 1 điểm biểu đồ = 1 Kỳ, toàn thị trường TPDN riêng lẻ (Level 1). Storage Grain: Fact Private Corporate Bond Trading Snapshot = 1 ngày báo cáo HNX09, toàn thị trường (Level 1 × ngày) — presentation thô hơn hoặc bằng storage, đạt Iso-Grain.

**Source:** `Fact Private Corporate Bond Trading Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Reuse từ Nhóm 1 (K_VP_1) — Case 1: measure vật lý có sẵn trên Fact/Dim. BA ghi Chiều thời gian (Từ kỳ — Đến kỳ), Đánh giá 'Trùng' | READY |
| K_VP_89 | GTGD TPDN riêng lẻ | VND | Cơ sở | SUM(Trading Value) trên Fact Private Corporate Bond Trading Snapshot trong kỳ; Trading Value = Cell Value (ép số) của ô Row Path = 'GIÁ TRỊ GIAO DỊCH' báo cáo HNX09 | Reuse từ Nhóm 9 (K_VP_89) — Case 1: measure vật lý có sẵn trên Fact/Dim. Nhóm 12 gom theo kỳ trong khoảng Từ kỳ — Đến kỳ; Nhóm 12 và Nhóm 13 dùng chung SQL BA (dòng 154) — O_VP_29 | READY |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }
    Fact_Private_Corporate_Bond_Trading_Snapshot {
        string Private_Corporate_Bond_Trading_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        decimal Trading_Value
        decimal Foreign_Buy_Value
        decimal Foreign_Sell_Value
    }
    Calendar_Date_Dimension ||--o{ Fact_Private_Corporate_Bond_Trading_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Private_Corporate_Bond_Trading_Snapshot["Fact Private Corporate Bond Trading Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 12"]
        R1["K_VP_1,89: TPDN riêng lẻ: GTGD theo kỳ"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Private_Corporate_Bond_Trading_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Private Corporate Bond Trading Snapshot | 1 ngày báo cáo HNX09 (báo cáo ngày TPDN riêng lẻ, nguồn nộp ICP); PK Private Corporate Bond Trading Snapshot Id = hash (Snapshot Date Dimension Id) (Dạng B, A22) |

#### Nhóm 13 - TPDN riêng lẻ >> Giá trị mua/bán ròng NĐTNN trên thị trường TPDN riêng lẻ

> Phân loại: **Phân tích**
> Atomic: `Internal Statistical Report` ← ISS.INTERNAL_STATISTICAL_REPORT — **READY**

**Mockup (suy từ BA — chưa có screenshot, O_VP_8):**

Tham số: Loại kỳ (D/M/Q/Y) · Từ kỳ — Đến kỳ

| Kỳ | GTGD mua NĐTNN | GTGD bán NĐTNN | GTGD mua/bán ròng NĐTNN |
|---|---|---|---|
| 2026-09 | … | … | … |

> ⚠️ Presentation Grain: 1 điểm biểu đồ = 1 Kỳ, toàn thị trường TPDN riêng lẻ (Level 1). Storage Grain: Fact Private Corporate Bond Trading Snapshot = 1 ngày báo cáo HNX09, toàn thị trường (Level 1 × ngày) — đạt Iso-Grain.

**Source:** `Fact Private Corporate Bond Trading Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Reuse từ Nhóm 1 (K_VP_1) — Case 1: measure vật lý có sẵn trên Fact/Dim. BA ghi Chiều thời gian (Từ kỳ — Đến kỳ), Đánh giá 'Trùng' | READY |
| K_VP_94 | GTGD mua NĐTNN | VND | Cơ sở | SUM(Foreign Buy Value) trên Fact Private Corporate Bond Trading Snapshot trong kỳ; Foreign Buy Value = Cell Value (ép số) của ô Row Path = 'GIÁ TRỊ GIAO DỊCH NHÀ ĐẦU TƯ NƯỚC NGOÀI - GIÁ TRỊ MUA' báo cáo HNX09 | Reuse từ Nhóm 11 (K_VP_94) — Case 1: measure vật lý có sẵn trên Fact/Dim. Nhóm 13 gom theo kỳ trong khoảng Từ kỳ — Đến kỳ; BA đặt tên 'GTGD mua NĐTNN' | READY |
| K_VP_96 | GTGD bán NĐTNN | VND | Cơ sở | SUM(Foreign Sell Value) trên Fact Private Corporate Bond Trading Snapshot trong kỳ; Foreign Sell Value = Cell Value (ép số) của ô Row Path = 'GIÁ TRỊ GIAO DỊCH NHÀ ĐẦU TƯ NƯỚC NGOÀI - GIÁ TRỊ BÁN' báo cáo HNX09 | Reuse từ Nhóm 11 (K_VP_96) — Case 1: measure vật lý có sẵn trên Fact/Dim. Nhóm 13 gom theo kỳ trong khoảng Từ kỳ — Đến kỳ; BA đặt tên 'GTGD bán NĐTNN' | READY |
| K_VP_98 | GTGD mua/bán ròng NĐTNN | VND | Phái sinh | K_VP_94 − K_VP_96 | Reuse từ Nhóm 11 (K_VP_98) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact. Nhóm 13 gom theo kỳ trong khoảng Từ kỳ — Đến kỳ; BA đặt tên 'GTGD mua/bán ròng NĐTNN' | READY |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }
    Fact_Private_Corporate_Bond_Trading_Snapshot {
        string Private_Corporate_Bond_Trading_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        decimal Trading_Value
        decimal Foreign_Buy_Value
        decimal Foreign_Sell_Value
    }
    Calendar_Date_Dimension ||--o{ Fact_Private_Corporate_Bond_Trading_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Private_Corporate_Bond_Trading_Snapshot["Fact Private Corporate Bond Trading Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 13"]
        R1["K_VP_1,94,96,98: TPDN riêng lẻ: GTGD mua/bán ròng NĐTNN theo kỳ"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Private_Corporate_Bond_Trading_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Private Corporate Bond Trading Snapshot | 1 ngày báo cáo HNX09 (báo cáo ngày TPDN riêng lẻ, nguồn nộp ICP); PK Private Corporate Bond Trading Snapshot Id = hash (Snapshot Date Dimension Id) (Dạng B, A22) |

#### Nhóm 14 - TPCP >> Chỉ tiêu tổng hợp

> Phân loại: **Phân tích**
> Atomic: `Bond Order Book` ← HNX.OUTRIGHT_ORDER_BOOK / HNX.REPO_ORDER_BOOK — **READY** (Order Book Type Code ∈ OUTRIGHT, REPO; không đọc REPO2; không phụ thuộc Securities Trade `[!]`)

**Mockup (suy từ BA — chưa có screenshot, O_VP_8):**

Tham số: Loại kỳ (D/M/Q/Y) · Kỳ

| Chỉ tiêu | Kỳ báo cáo | Kỳ trước | Thay đổi | % thay đổi |
|---|---|---|---|---|
| KLGD TPCP | … | … | … | … |
| GTGD TPCP | … | … | … | … |
| Giá trị mua NĐTNN | … | … | … | … |
| Giá trị bán NĐTNN | … | … | … | … |
| Giá trị mua/bán ròng NĐTNN | … | … | … | … |

> ⚠️ Presentation Grain: 1 dòng = 1 chỉ tiêu × 1 Kỳ, toàn thị trường TPCP (Level 1; cộng gộp OUTRIGHT + REPO theo SQL BA). Storage Grain: Fact Government Bond Trading Snapshot = 1 ngày giao dịch × 1 loại sổ lệnh (OUTRIGHT / REPO) (Level 1 × ngày × phương thức) — presentation thô hơn storage, đạt Iso-Grain.

**Source:** `Fact Government Bond Trading Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Reuse từ Nhóm 1 (K_VP_1) — Case 1: measure vật lý có sẵn trên Fact/Dim. BA ghi Chiều thời gian, Đánh giá 'TB' | READY |
| K_VP_102 | KLGD TPCP | Trái phiếu | Cơ sở | SUM(Trading Volume) trên Fact Government Bond Trading Snapshot trong kỳ (gộp Order Book Type Code OUTRIGHT và REPO); Trading Volume = Σ Order Bond Quantity (VOLUME) của lệnh có Order Status = 'ĐTH' | Case 1 — measure Trading Volume; `Bond Order Book` (Atomic) thay cho 2 bảng staging `outright_order_book` / `repo_order_book` của BA; Order Status 'ĐTH' (đã thực hiện) áp cho mọi chỉ tiêu — SQL BA; literal chưa kiểm — O_VP_32; Điều kiện BA ghi `volumne` (typo) — O_VP_31 | READY |
| K_VP_103 | KLGD TPCP - So sánh với kỳ trước | % | Phái sinh | (K_VP_102 kỳ báo cáo − K_VP_102 kỳ trước) / K_VP_102 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_104 | GTGD TPCP | VND | Cơ sở | SUM(Trading Value) trên Fact Government Bond Trading Snapshot trong kỳ; Trading Value = Σ Trading Val của lệnh OUTRIGHT + Σ First Settlement Val của lệnh REPO (Order Status = 'ĐTH') | Case 1 — measure Trading Value; Atomic `trading_val` chỉ có ở OUTRIGHT (NULL với REPO) nên REPO dùng `first_settlement_val` theo BA; `Bond Order Book` (Atomic) thay cho 2 bảng staging `outright_order_book` / `repo_order_book` của BA; Order Status 'ĐTH' (đã thực hiện) áp cho mọi chỉ tiêu — SQL BA; literal chưa kiểm — O_VP_32 | READY |
| K_VP_105 | GTGD TPCP - So sánh với kỳ trước | % | Phái sinh | (K_VP_104 kỳ báo cáo − K_VP_104 kỳ trước) / K_VP_104 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_106 | Giá trị mua NĐTNN | VND | Cơ sở | SUM(Foreign Buy Value) trên Fact Government Bond Trading Snapshot trong kỳ; Foreign Buy Value = Σ giá trị lệnh (Trading Val với OUTRIGHT, First Settlement Val với REPO) có ký tự thứ 4 của Buying Account Nbr ∈ ('E','F') và Order Status = 'ĐTH' | Case 1 — measure Foreign Buy Value; NĐTNN = ký tự thứ 4 của số tài khoản ∈ (E, F) theo Mô tả BA; Buying Account Nbr có ở Atomic `Bond Order Book`, không phụ thuộc Securities Trade; `Bond Order Book` (Atomic) thay cho 2 bảng staging `outright_order_book` / `repo_order_book` của BA; Order Status 'ĐTH' (đã thực hiện) áp cho mọi chỉ tiêu — SQL BA; literal chưa kiểm — O_VP_32 | READY |
| K_VP_107 | Giá trị mua NĐTNN - So sánh với kỳ trước | % | Phái sinh | (K_VP_106 kỳ báo cáo − K_VP_106 kỳ trước) / K_VP_106 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_108 | Giá trị bán NĐTNN | VND | Cơ sở | SUM(Foreign Sell Value) trên Fact Government Bond Trading Snapshot trong kỳ; Foreign Sell Value = Σ giá trị lệnh (Trading Val với OUTRIGHT, First Settlement Val với REPO) có ký tự thứ 4 của Selling Account Nbr ∈ ('E','F') và Order Status = 'ĐTH' | Case 1 — measure Foreign Sell Value; NĐTNN = ký tự thứ 4 của số tài khoản ∈ (E, F) theo Mô tả BA; `Bond Order Book` (Atomic) thay cho 2 bảng staging `outright_order_book` / `repo_order_book` của BA; Order Status 'ĐTH' (đã thực hiện) áp cho mọi chỉ tiêu — SQL BA; literal chưa kiểm — O_VP_32 | READY |
| K_VP_109 | Giá trị bán NĐTNN - So sánh với kỳ trước | % | Phái sinh | (K_VP_108 kỳ báo cáo − K_VP_108 kỳ trước) / K_VP_108 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_110 | Giá trị mua/bán ròng NĐTNN | VND | Phái sinh | K_VP_106 − K_VP_108 | Case 2 — tính tại presentation layer từ Foreign Buy Value / Foreign Sell Value; BA ghi Phân loại 'Chỉ tiêu cơ sở' nhưng Mô tả là mua − bán → Tính chất Phái sinh — O_VP_31 | READY |
| K_VP_111 | Giá trị mua/bán ròng NĐTNN - So sánh với kỳ trước | % | Phái sinh | (K_VP_110 kỳ báo cáo − K_VP_110 kỳ trước) / K_VP_110 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5; Mô tả BA không dùng ABS (kỳ trước âm đảo dấu) trong khi SQL chia ABS(kỳ trước) — theo Mô tả như K_VP_82 — O_VP_31 | READY |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }
    Fact_Government_Bond_Trading_Snapshot {
        string Government_Bond_Trading_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Order_Book_Type_Code
        bigint Trading_Volume
        decimal Trading_Value
        decimal Foreign_Buy_Value
        decimal Foreign_Sell_Value
    }
    Calendar_Date_Dimension ||--o{ Fact_Government_Bond_Trading_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Government_Bond_Trading_Snapshot["Fact Government Bond Trading Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 14"]
        R1["K_VP_1,102-111: TPCP: chỉ tiêu tổng hợp"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Government_Bond_Trading_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Government Bond Trading Snapshot | 1 ngày giao dịch × 1 loại sổ lệnh (Order Book Type Code ∈ OUTRIGHT, REPO); PK Government Bond Trading Snapshot Id = hash (Snapshot Date Dimension Id, Order Book Type Code) (Dạng B, A22) |

#### Nhóm 15 - TPCP >> Biểu đồ Diễn biến giao dịch thị trường

> Phân loại: **Phân tích**
> Atomic: `Bond Order Book` ← HNX.OUTRIGHT_ORDER_BOOK / HNX.REPO_ORDER_BOOK — **READY** (Order Book Type Code ∈ OUTRIGHT, REPO; không đọc REPO2; không phụ thuộc Securities Trade `[!]`)

**Mockup (suy từ BA — chưa có screenshot, O_VP_8):**

Tham số: Loại kỳ (D/M/Q/Y) · Từ kỳ — Đến kỳ

| Kỳ | KLGD TPCP | GTGD TPCP |
|---|---|---|
| 2026-09 | … | … |

> ⚠️ Presentation Grain: 1 điểm biểu đồ = 1 Kỳ, toàn thị trường TPCP (Level 1; cộng gộp OUTRIGHT + REPO). Storage Grain: Fact Government Bond Trading Snapshot = 1 ngày giao dịch × 1 loại sổ lệnh (Level 1 × ngày × phương thức) — presentation thô hơn storage, đạt Iso-Grain.

**Source:** `Fact Government Bond Trading Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Reuse từ Nhóm 1 (K_VP_1) — Case 1: measure vật lý có sẵn trên Fact/Dim. BA ghi Chiều thời gian (Từ kỳ — Đến kỳ), Đánh giá 'TB' | READY |
| K_VP_102 | KLGD TPCP | Trái phiếu | Cơ sở | SUM(Trading Volume) trên Fact Government Bond Trading Snapshot trong kỳ (gộp Order Book Type Code OUTRIGHT và REPO); Trading Volume = Σ Order Bond Quantity (VOLUME) của lệnh có Order Status = 'ĐTH' | Reuse từ Nhóm 14 (K_VP_102) — Case 1: measure vật lý có sẵn trên Fact/Dim. Nhóm 15 gom theo kỳ trong khoảng Từ kỳ — Đến kỳ; Điều kiện BA ghi `volumne` (typo) — O_VP_31 | READY |
| K_VP_104 | GTGD TPCP | VND | Cơ sở | SUM(Trading Value) trên Fact Government Bond Trading Snapshot trong kỳ; Trading Value = Σ Trading Val của lệnh OUTRIGHT + Σ First Settlement Val của lệnh REPO (Order Status = 'ĐTH') | Reuse từ Nhóm 14 (K_VP_104) — Case 1: measure vật lý có sẵn trên Fact/Dim. Nhóm 15 gom theo kỳ trong khoảng Từ kỳ — Đến kỳ | READY |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }
    Fact_Government_Bond_Trading_Snapshot {
        string Government_Bond_Trading_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Order_Book_Type_Code
        bigint Trading_Volume
        decimal Trading_Value
        decimal Foreign_Buy_Value
        decimal Foreign_Sell_Value
    }
    Calendar_Date_Dimension ||--o{ Fact_Government_Bond_Trading_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Government_Bond_Trading_Snapshot["Fact Government Bond Trading Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 15"]
        R1["K_VP_1,102,104: TPCP: KLGD và GTGD theo kỳ"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Government_Bond_Trading_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Government Bond Trading Snapshot | 1 ngày giao dịch × 1 loại sổ lệnh (Order Book Type Code ∈ OUTRIGHT, REPO); PK Government Bond Trading Snapshot Id = hash (Snapshot Date Dimension Id, Order Book Type Code) (Dạng B, A22) |

#### Nhóm 16 - TPCP >> Biểu đồ Giá trị mua/bán ròng NĐTNN

> Phân loại: **Phân tích**
> Atomic: `Bond Order Book` ← HNX.OUTRIGHT_ORDER_BOOK / HNX.REPO_ORDER_BOOK — **READY** (Order Book Type Code ∈ OUTRIGHT, REPO; không đọc REPO2; không phụ thuộc Securities Trade `[!]`)

**Mockup (suy từ BA — chưa có screenshot, O_VP_8):**

Tham số: Loại kỳ (D/M/Q/Y) · Từ kỳ — Đến kỳ

| Kỳ | GTGD mua NĐTNN | GTGD bán NĐTNN | GTGD mua/bán ròng NĐTNN |
|---|---|---|---|
| 2026-09 | … | … | … |

> ⚠️ Presentation Grain: 1 điểm biểu đồ = 1 Kỳ, toàn thị trường TPCP (Level 1; SQL BA cộng gộp OUTRIGHT + REPO). Storage Grain: Fact Government Bond Trading Snapshot = 1 ngày giao dịch × 1 loại sổ lệnh (Level 1 × ngày × phương thức) — presentation thô hơn storage, đạt Iso-Grain; nếu BA cần tách 'Loại CK / Thị trường' thì dùng Order Book Type Code (đã có trong grain) — O_VP_31.

**Source:** `Fact Government Bond Trading Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Reuse từ Nhóm 1 (K_VP_1) — Case 1: measure vật lý có sẵn trên Fact/Dim. BA ghi Chiều thời gian (Từ kỳ — Đến kỳ), Đánh giá 'TB' | READY |
| K_VP_106 | GTGD mua NĐTNN | VND | Cơ sở | SUM(Foreign Buy Value) trên Fact Government Bond Trading Snapshot trong kỳ; Foreign Buy Value = Σ giá trị lệnh (Trading Val với OUTRIGHT, First Settlement Val với REPO) có ký tự thứ 4 của Buying Account Nbr ∈ ('E','F') và Order Status = 'ĐTH' | Reuse từ Nhóm 14 (K_VP_106) — Case 1: measure vật lý có sẵn trên Fact/Dim. Nhóm 16 gom theo kỳ trong khoảng Từ kỳ — Đến kỳ; BA ghi Độ chi tiết 'Loại CK / Thị trường, Ngày' nhưng SQL (dùng chung Nhóm 15) cộng gộp OUTRIGHT + REPO; Mô tả/Điều kiện/Đánh giá như dòng 165 — O_VP_31 | READY |
| K_VP_108 | GTGD bán NĐTNN | VND | Cơ sở | SUM(Foreign Sell Value) trên Fact Government Bond Trading Snapshot trong kỳ; Foreign Sell Value = Σ giá trị lệnh (Trading Val với OUTRIGHT, First Settlement Val với REPO) có ký tự thứ 4 của Selling Account Nbr ∈ ('E','F') và Order Status = 'ĐTH' | Reuse từ Nhóm 14 (K_VP_108) — Case 1: measure vật lý có sẵn trên Fact/Dim. Nhóm 16 gom theo kỳ trong khoảng Từ kỳ — Đến kỳ; Độ chi tiết 'Loại CK / Thị trường, Ngày' — O_VP_31 | READY |
| K_VP_110 | GTGD mua/bán ròng NĐTNN | VND | Phái sinh | K_VP_106 − K_VP_108 | Reuse từ Nhóm 14 (K_VP_110) — Case 2: tính toán tại presentation layer, không lưu cột riêng trên Fact. Nhóm 16 gom theo kỳ trong khoảng Từ kỳ — Đến kỳ; Độ chi tiết 'Loại CK / Thị trường, Ngày' — O_VP_31 | READY |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }
    Fact_Government_Bond_Trading_Snapshot {
        string Government_Bond_Trading_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Order_Book_Type_Code
        bigint Trading_Volume
        decimal Trading_Value
        decimal Foreign_Buy_Value
        decimal Foreign_Sell_Value
    }
    Calendar_Date_Dimension ||--o{ Fact_Government_Bond_Trading_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Government_Bond_Trading_Snapshot["Fact Government Bond Trading Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 16"]
        R1["K_VP_1,106,108,110: TPCP: GTGD mua/bán ròng NĐTNN theo kỳ"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Government_Bond_Trading_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Government Bond Trading Snapshot | 1 ngày giao dịch × 1 loại sổ lệnh (Order Book Type Code ∈ OUTRIGHT, REPO); PK Government Bond Trading Snapshot Id = hash (Snapshot Date Dimension Id, Order Book Type Code) (Dạng B, A22) |

## Section 3 — Mô hình tổng thể

### 3.1 Graph TB

```mermaid
graph TB
    classDef dim fill:#E6F1FB,stroke:#185FA5,color:#0C447C
    classDef fact fill:#FAECE7,stroke:#993C1D,color:#4A1B0C
    classDef oper fill:#E8F5E9,stroke:#2E7D32,color:#1B5E20

    Calendar_Date_Dimension["Calendar Date Dimension"]:::dim
    Market_Index_Dimension["Market Index Dimension"]:::dim
    Security_Trading_Snapshot_Dimension["Security Trading Snapshot Dimension"]:::dim
    Industry_Dimension["Industry Dimension"]:::dim
    Fact_Market_Index_Snapshot["Fact Market Index Snapshot"]:::fact
    Fact_Investor_Group_Trading_Snapshot["Fact Investor Group Trading Snapshot"]:::fact
    Fact_Derivative_Contract_Snapshot["Fact Derivative Contract Snapshot"]:::fact
    Fact_Listed_Corporate_Bond_Snapshot["Fact Listed Corporate Bond Snapshot"]:::fact
    Fact_Private_Corporate_Bond_Trading_Snapshot["Fact Private Corporate Bond Trading Snapshot"]:::fact
    Fact_Private_Corporate_Bond_Registration_Snapshot["Fact Private Corporate Bond Registration Snapshot"]:::fact
    Fact_Government_Bond_Trading_Snapshot["Fact Government Bond Trading Snapshot"]:::fact

    Calendar_Date_Dimension --> Fact_Market_Index_Snapshot
    Market_Index_Dimension --> Fact_Market_Index_Snapshot
    Calendar_Date_Dimension --> Fact_Investor_Group_Trading_Snapshot
    Security_Trading_Snapshot_Dimension --> Fact_Investor_Group_Trading_Snapshot
    Calendar_Date_Dimension --> Fact_Derivative_Contract_Snapshot
    Security_Trading_Snapshot_Dimension --> Fact_Derivative_Contract_Snapshot
    Calendar_Date_Dimension --> Fact_Listed_Corporate_Bond_Snapshot
    Industry_Dimension --> Fact_Listed_Corporate_Bond_Snapshot
    Calendar_Date_Dimension --> Fact_Private_Corporate_Bond_Trading_Snapshot
    Calendar_Date_Dimension --> Fact_Private_Corporate_Bond_Registration_Snapshot
    Calendar_Date_Dimension --> Fact_Government_Bond_Trading_Snapshot
```

### 3.2 Bảng Phân tích

| Bảng | Pattern | Grain | KPI | Trạng thái |
|---|---|---|---|---|
| Fact Market Index Snapshot | Periodic Snapshot | 1 chỉ số (Market Code) × 1 ngày giao dịch — bản ghi cuối ngày; sở hữu bởi QLKD | K_VP_4,6-8 (Nhóm 1, 2) | READY (reuse QLKD) |
| Fact Investor Group Trading Snapshot | Periodic Snapshot | 1 mã chứng khoán / hợp đồng × 1 ngày giao dịch × 1 sàn (Market Id Code) × 1 nhóm NĐT (ALL / FOREIGN / PROPRIETARY); PK Investor Group Trading Snapshot Id = hash toàn bộ cột grain (Dạng B, A22) | K_VP_5,9-17,21-28,31-38,41-48,51-58,61-68 (Nhóm 1, 2, 3, 5, 6) | READY (Atomic draft — chưa approved; nguồn Securities Trade chờ Atomic cung cấp Sổ lệnh cấp tài khoản, O_VP_1) |
| Fact Derivative Contract Snapshot | Periodic Snapshot | 1 mã hợp đồng phái sinh × 1 ngày giao dịch; PK Derivative Contract Snapshot Id = hash (Snapshot Date, Ticker Symbol) (Dạng B, A22) | K_VP_19-20,29-30,39-40,49-50,59-60,70 (Nhóm 3, 4, 5) | READY |
| Fact Listed Corporate Bond Snapshot | Periodic Snapshot | 1 mã trái phiếu (ISIN — Security Symbol Code) × 1 ngày giao dịch; PK Listed Corporate Bond Snapshot Id = hash (Snapshot Date Dimension Id, Security Symbol Code) (Dạng B, A22) | K_VP_71-88,90,112-114 (Nhóm 7, 8, 9, 10) | READY (Atomic draft — chưa approved; nguồn Securities Trade chờ Atomic cung cấp Sổ lệnh cấp tài khoản, O_VP_1) |
| Fact Private Corporate Bond Trading Snapshot | Periodic Snapshot | 1 ngày báo cáo HNX09 (báo cáo ngày TPDN riêng lẻ, nguồn nộp ICP); PK Private Corporate Bond Trading Snapshot Id = hash (Snapshot Date Dimension Id) (Dạng B, A22) | K_VP_89,91-99 (Nhóm 9, 11, 12, 13) | READY |
| Fact Private Corporate Bond Registration Snapshot | Periodic Snapshot | 1 mã trái phiếu (Bond Code) × 1 tháng báo cáo (Report Year, Report Month); PK Private Corporate Bond Registration Snapshot Id = hash (Bond Code, Report Year, Report Month) (Dạng B, A22) | K_VP_100-101 (Nhóm 11) | READY (Atomic draft — chưa approved; khóa Atomic chỉ băm Bond Code, O_VP_26) |
| Fact Government Bond Trading Snapshot | Periodic Snapshot | 1 ngày giao dịch × 1 loại sổ lệnh (Order Book Type Code ∈ OUTRIGHT, REPO); PK Government Bond Trading Snapshot Id = hash (Snapshot Date Dimension Id, Order Book Type Code) (Dạng B, A22) | K_VP_102-111 (Nhóm 14, 15, 16) | READY (Atomic draft — chưa approved; giá trị literal Order Status / Order Book Type chưa kiểm, O_VP_32) |
| Fact Securities Market Index Snapshot | Periodic Snapshot | — | — | DEPRECATED (thiết kế VP cũ bị thay hoàn toàn 2026-10-25, xem Section 4) |
| Fact Derivatives Trading Snapshot | Periodic Snapshot | — | — | DEPRECATED (thiết kế VP cũ bị thay hoàn toàn 2026-10-25, xem Section 4) |
| Fact Derivatives Price Snapshot | Periodic Snapshot | — | — | DEPRECATED (thiết kế VP cũ bị thay hoàn toàn 2026-10-25, xem Section 4) |
| Fact Listed Corporate Bond Industry Term Snapshot | Periodic Snapshot | — | — | DEPRECATED (thiết kế VP cũ bị thay hoàn toàn 2026-10-25, xem Section 4) |
| Fact OTC Bond Snapshot | Periodic Snapshot | — | — | DEPRECATED (thiết kế VP cũ bị thay hoàn toàn 2026-10-25, xem Section 4) |
| Fact Share Auction Snapshot | Periodic Snapshot | — | — | DEPRECATED (thiết kế VP cũ bị thay hoàn toàn 2026-10-25, xem Section 4) |

### 3.3 Bảng Tác nghiệp

Không có.

### 3.4 Bảng Dimension

*Tất cả Dimension áp dụng SCD Type 4A (trừ Calendar Date Dimension).*

| Dimension | Loại | Mô tả | Scheme | Trạng thái |
|---|---|---|---|---|
| Calendar Date Dimension | Conformed | Lịch ngày dùng chung toàn Datamart | — | READY |
| Market Index Dimension | Conformed | Danh mục chỉ số thị trường (Market Id + Market Code); sở hữu QLKD, reuse GSTT/NDTNN/TKNB | — | READY |
| Security Trading Snapshot Dimension | Conformed | Hồ sơ chứng khoán / hợp đồng phái sinh (1 dòng/mã); sở hữu GSTT; VP thêm Product Group Id (partial, O_VP_7) | — | READY |
| Industry Dimension | Conformed | Danh mục ngành nghề kinh doanh cấp 1 (Classification IDS Business Line); sở hữu GSDC, reuse PTTT/GSTT; VP dùng làm khóa ngoại ngành cho Fact TPDN niêm yết | — | READY |

## Section 4 — Reuse Analysis

| Datamart Entity | datamart_table | reuse_status | Ghi chú |
|---|---|---|---|
| Calendar Date Dimension | cdr_dt_dim | reuse | Conformed Dim toàn hệ thống — không thêm nguồn mới |
| Market Index Dimension | market_index_dim | reuse | Cùng nguồn Market Index Snapshot, grain 1 Market Id + Market Code; sở hữu QLKD — human xác nhận 2026-10-25 |
| Fact Market Index Snapshot | fct_market_index_snpst | reuse | Grain 1 chỉ số × 1 ngày (bản ghi cuối ngày) đúng nhu cầu Nhóm 1–2; sở hữu QLKD — human xác nhận 2026-10-25; thay Fact VP cũ `fct_scr_mkt_indx_snpst` |
| Security Trading Snapshot Dimension | security_trading_snpst_dim | partial | Đã xác nhận reuse 2026-10-25; phát sinh partial vì thiếu Product Group Id để nhận diện HĐTL TPCP (O_VP_7) — human xác nhận partial 2026-10-25; không thêm cột tĩnh khác vào dimension GSTT (thay đổi thêm làm ở phía VP nếu cần) |
| Fact Investor Group Trading Snapshot | fct_investor_group_trading_snpst | new | Grain mã × ngày × sàn × nhóm NĐT; không partial `fct_investor_category_trading_snpst` (GSTT) vì khác định nghĩa Tự doanh (P/E/A so với P/E) và khác phạm vi sàn (phái sinh, TPDN) — O_VP_2 |
| Fact Derivative Contract Snapshot | fct_derivative_contract_snpst | new | Grain mã hợp đồng × ngày (OI + giá đóng cửa); PTTT `fct_futures_*` chỉ HĐTL chỉ số, không có OI TPCP/toàn thị trường |
| Industry Dimension | industry_dim | reuse | Cùng nguồn Classification IDS Business Line, grain 1 ngành cấp 1 hiện hành; sở hữu GSDC (đang dùng bởi PTTT, GSTT); VP dùng làm khóa ngoại ngành cho Fact TPDN niêm yết, không thêm cột/nguồn — human xác nhận 2026-10-25 (Lô 1: Nhóm 7–10) |
| Fact Listed Corporate Bond Snapshot | fct_listed_corporate_bond_snpst | new | Grain mã trái phiếu (ISIN) × ngày: giao dịch TPDN niêm yết (Sổ lệnh HNX, Market Id Code 'HCX') FULL OUTER bản tin cuối ngày MDDS (Stock Type Code '1') + KL lưu hành HNX; phục vụ Nhóm 7–10. Không reuse Fact module khác — lệch quy tắc BA: NDTNN `foreign_investor_trading_statistics_rpt` (grain 1 ngày × nhóm loại CK, không theo mã/ngành), PTTT `fct_corporate_bond_*` (tổng thị trường hoặc theo ngành TCPH, loại TPCP theo tiền tố mã, không có kỳ hạn × lưu hành theo mã), GSTT `fct_hnx_securities_trade` (grain 1 giao dịch khớp, có PII) / `opr_security_ref` (danh mục current-state), TKNB. Thay Fact VP cũ cùng tên logic (vật lý cũ `fct_lst_crp_bnd_snpst`, DEPRECATED 2026-10-25 — gộp 1 dòng với bảng mới). Bảng được human xác nhận 2026-10-25 (Lô 1); danh sách cột là kết quả rà measure theo BA, chờ duyệt HLD: thêm Listed Indicator (đếm Số mã) và Issue Term Years (Chiều Kỳ hạn phát hành), bỏ Par Value (chỉ là trung gian tính Bond Outstanding Value) |
| Fact Private Corporate Bond Trading Snapshot | fct_private_corporate_bond_trading_snpst | new | Grain 1 ngày báo cáo HNX09 (Internal Statistical Report, daily/ICP/đã nộp), pivot theo Row Path; Nhóm 9 (Lô 1) dùng Trading Value; Nhóm 11–13 (Lô 2) dùng thêm Foreign Buy Value / Foreign Sell Value — thiết kế Lô 1 đã đủ ba measure nên Lô 2 không đổi grain/PK/cột; thay Fact VP cũ `fct_otc_bnd_snpst` (DEPRECATED); không reuse NDTNN `foreign_investor_trading_statistics_rpt` (nhóm loại CK, không phải báo cáo HNX09 daily) — human xác nhận bảng 2026-10-25 (Lô 1) |
| Fact Private Corporate Bond Registration Snapshot | fct_private_corporate_bond_registration_snpst | new | Grain mã trái phiếu (Bond Code) × tháng báo cáo (Report Year, Report Month): TPDN riêng lẻ đăng ký giao dịch theo báo cáo tháng HNX (Atomic `Private Corp Bond Registration`), factless, phục vụ Số mã TP ĐKGD (Nhóm 11). Không reuse/partial Fact module khác: TKNB `fct_private_corporate_bond_issuance_snpst` đọc cùng Atomic nhưng là số lũy kế phát hành (KL/GT phát hành), nối Dimension TKNB `private_corporate_bond_dim` (nguồn Private Corp Bond Offering, tập mã khác) và FK ngày theo ngày chạy ETL — thêm Maturity Date/đếm mã chưa đáo hạn sẽ đổi số TKNB (H11); VP `fct_private_corporate_bond_trading_snpst` grain 1 ngày báo cáo HNX09 (nguồn ISS), không cùng grain. Human xác nhận bảng 2026-10-25 (Lô 2: Nhóm 11–16); danh sách cột (Report Year/Month, Maturity Date) là kết quả rà theo BA, chờ duyệt HLD; FK ngày = ngày cuối tháng báo cáo (giả định — O_VP_27) |
| Fact Government Bond Trading Snapshot | fct_government_bond_trading_snpst | new | Grain 1 ngày giao dịch × 1 loại sổ lệnh (OUTRIGHT / REPO) từ Atomic `Bond Order Book` (HNX), chỉ lệnh Order Status = 'ĐTH'; phục vụ Nhóm 14–16 (KLGD, GTGD, GT mua/bán/ròng NĐTNN TPCP). Không reuse Fact module khác — lệch quy tắc BA: NDTNN `foreign_investor_trading_statistics_rpt` (grain 1 ngày × nhóm loại CK, gộp 7 nhóm trong đó BOND_GOVT; chỉ có giá trị Buy / Sell / Total Market Value, không có KLGD, không tách OUTRIGHT/REPO; Detail Mapping NDTNN không lọc Order Status = 'ĐTH'), PTTT `fct_corporate_bond_*` (TPDN, không phải TPCP), TKNB (báo cáo tháng). Human xác nhận bảng 2026-10-25 (Lô 2: Nhóm 11–16); danh sách cột là kết quả rà measure theo BA, chờ duyệt HLD |
| Fact Securities Market Index Snapshot | fct_scr_mkt_indx_snpst | DEPRECATED | Thiết kế VP cũ (Atomic_LinhLV `scr_trd`/`scr_tdg_snpst`) bị thay hoàn toàn theo yêu cầu thiết kế lại phân hệ VP ngày 2026-10-25; dọn 5 tầng (LLD, registry, Detail Mapping, model yaml, flat) ở bước LLD |
| Fact Derivatives Trading Snapshot | fct_derv_tdg_snpst | DEPRECATED | Thiết kế VP cũ (Atomic_LinhLV `scr_trd`/`scr_tdg_snpst`) bị thay hoàn toàn theo yêu cầu thiết kế lại phân hệ VP ngày 2026-10-25; dọn 5 tầng (LLD, registry, Detail Mapping, model yaml, flat) ở bước LLD |
| Fact Derivatives Price Snapshot | fct_derv_prc_snpst | DEPRECATED | Thiết kế VP cũ (Atomic_LinhLV `scr_trd`/`scr_tdg_snpst`) bị thay hoàn toàn theo yêu cầu thiết kế lại phân hệ VP ngày 2026-10-25; dọn 5 tầng (LLD, registry, Detail Mapping, model yaml, flat) ở bước LLD |
| Fact Listed Corporate Bond Industry Term Snapshot | fct_lst_crp_bnd_indy_trm_snpst | DEPRECATED | Thiết kế VP cũ (Atomic_LinhLV `scr_trd`/`scr_tdg_snpst`) bị thay hoàn toàn theo yêu cầu thiết kế lại phân hệ VP ngày 2026-10-25; dọn 5 tầng (LLD, registry, Detail Mapping, model yaml, flat) ở bước LLD |
| Fact OTC Bond Snapshot | fct_otc_bnd_snpst | DEPRECATED | Thiết kế VP cũ (Atomic_LinhLV `scr_trd`/`scr_tdg_snpst`) bị thay hoàn toàn theo yêu cầu thiết kế lại phân hệ VP ngày 2026-10-25; dọn 5 tầng (LLD, registry, Detail Mapping, model yaml, flat) ở bước LLD |
| Fact Share Auction Snapshot | fct_share_auction_snpst | DEPRECATED | Thiết kế VP cũ (Atomic_LinhLV `scr_trd`/`scr_tdg_snpst`) bị thay hoàn toàn theo yêu cầu thiết kế lại phân hệ VP ngày 2026-10-25; dọn 5 tầng (LLD, registry, Detail Mapping, model yaml, flat) ở bước LLD |

### Phân Định Reuse Case 1 vs Case 2:
1. **Case 1 (Physical Measure/Dim Reuse):** dùng measure/attribute vật lý có sẵn trên Fact/Dim — ghi `mart_table` + `mart_column` trong Detail Mapping.
2. **Case 2 (Presentation / Derived Reuse):** lọc theo chiều, % thay đổi, hiệu mua − bán tính tại presentation layer — `column_role = 'DERIVED'`, để trống `mart_table`/`mart_column`.

### Giao Thức Bãi Bỏ Bảng Đồng Bộ 5 Tầng (All-Tier Deprecation):
6 bảng VP cũ đã đánh dấu DEPRECATED ở Section 3/4 (bảng cũ thứ 7 `fct_lst_crp_bnd_snpst` được thay bằng Fact Listed Corporate Bond Snapshot mới cùng tên logic, tên vật lý `fct_listed_corporate_bond_snpst`). Các tầng 1–4 và flat table (xóa file LLD, sinh lại registry bằng `build_registry.py`, chuyển Detail Mapping, xóa block `datamart_model.yaml`, xóa DDL/DML) thực hiện ở bước `datamart-lld-design` ngay sau khi HLD được duyệt.

## Section 5 — Vấn đề mở

| ID | Phân loại Blocker | Vấn đề | Giả định hiện tại | KPI liên quan | Đơn vị chủ trì | Trạng thái |
|---|---|---|---|---|---|---|
| O_VP_1 | Nhóm 3 - Thiếu nguồn Atomic / Ngoại lai | Entity Atomic `Securities Trade` (nguồn ORDERTRADE.TRADE_BOOK_HOSE / TRADE_BOOK_HNX) bị gỡ khỏi `DataModel/Atomic` ở commit `bd91cc0a` (2026-10-14); toàn bộ HLD/LLD/entity/BRD phân tích của nguồn ORDERTRADE bị xóa tiếp ở `fbe95329` (2026-10-21, "update brd") — gỡ CÓ CHỦ ĐÍCH, không phải xóa nhầm. Atomic hiện có `Security Match Log` (MDDS.JAD_TRANSLOG, tick khớp lệnh cổ phiếu, KHÔNG có số tài khoản mua/bán), `Bond Order Book` (HNX, có `buying/selling_account_nbr`) và `Private Corp Bond Trading Summary`; BRD MDDS.JAD_ODDLOTTRANSLOG đã có nhưng chưa có entity Atomic. Chưa entity nào thay thế được Sổ lệnh cấp tài khoản (HOSE/HNX `trade_book`) mà BA dùng để nhận diện NĐTNN/Tự doanh theo ký tự thứ 4 của số tài khoản. | Giữ tham chiếu entity và tên cột như GSTT/PTTT/NDTNN (Trade Date, Market Id Code, Security Symbol Code, Execution Volume, Execution Value dùng chung HOSE/HNX, Buy/Sell Account Number); KPI vẫn READY, Gate 0 official hiển thị `[!]`; chờ Atomic team cung cấp nguồn Sổ lệnh cấp tài khoản (hoặc BA đổi nguồn sang `Bond Order Book` cho phần trái phiếu) — Vuong quyết. | K_VP_5,9-17,21-28,31-38,41-48,51-58,61-68,71-82,86,90,112-113 | Data Architecture / Atomic Team | Open |
| O_VP_2 | Quy chuẩn LLD | Định nghĩa Tự doanh khác GSTT: BA VP Nhóm 2 = ký tự thứ 4 số tài khoản ∈ (P, E, A) ('A' = tự doanh thành viên lưu ký trong nước); GSTT Investor Category 'TU_DOANH' = (P, E). | Tạo Fact riêng cho VP, không partial Fact của GSTT (tránh đổi số GSTT — H11). BA xác nhận nên thống nhất (P, E, A) hay (P, E). | K_VP_13-17 | BA Team / Datamart Modeling Team | Open |
| O_VP_3 | Nhóm 1 - BA chưa mapping xong (mâu thuẫn BA) | BA dòng 34, 36 (Nhóm 3): Mô tả định nghĩa NĐTNN phái sinh = Buy/Sell Foreign Investor Type Code <> '00'; Điều kiện và SQL = ký tự thứ 4 số tài khoản ∈ (E, F). | Thiết kế theo Điều kiện/SQL (thống nhất với cổ phiếu). Nếu BA chọn phương án Mô tả: dùng Buy/Sell Foreign Investor Type Code của Securities Trade, đổi quy tắc phân nhóm FOREIGN cho dòng phái sinh. | K_VP_23,25,33,35,43,45,53,55,63,65 | BA Team | Open |
| O_VP_4 | Nhóm 1 - BA chưa mapping xong (mâu thuẫn BA) | Nhóm 1–2: Mô tả/Điều kiện ghi thị trường cổ phiếu bao gồm cổ phiếu, chứng chỉ quỹ, chứng quyền (chỉ lọc market_id); SQL tham khảo lọc thêm `stocktype = '2'` (chỉ cổ phiếu) qua CTE stock_daily_eod. | Theo Mô tả/Điều kiện: không lọc Stock Type Code. Nếu BA chọn SQL: thêm Stock Type Code = '2' qua Security Trading Snapshot Dimension. | K_VP_5,9-17 | BA Team | Open |
| O_VP_5 | Nhóm 1 - BA chưa mapping xong (mâu thuẫn BA) | Loại kỳ 'D': SQL BA lấy kỳ trước = ngày lịch liền trước (`DATE_SUB(startdate, 1)`), không phải phiên giao dịch liền trước — Thứ Hai so với Chủ nhật cho kết quả NULL. | Thiết kế % thay đổi đúng SQL BA; BA xác nhận có đổi sang phiên giao dịch liền trước không. | K_VP_20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,72,74,78,80,82,91,95,97,99,101,103,105,107,109,111,114 | BA Team | Open |
| O_VP_6 | Nhóm 1 - BA chưa mapping xong (lỗi nhập liệu BA CSV) | (a) Dòng 43/53/63/73 (KLGD % thay đổi từng sản phẩm) ghi bảng nguồn OI VSDC thay vì Sổ lệnh; (b) cột Chỉ tiêu gốc dòng 75–79 lệch hàng; (c) dòng 92/93 (Nhóm 5) nhãn 'HĐTL VN100' nhưng điều kiện `productgrpid = 'FBX'` (TPCP); (d) dòng 110 (Nhóm 6) Mô tả ghi 'HĐTL TPCP' cho Toàn thị trường; (e) % thay đổi KL ròng: dòng 39 chia ABS(kỳ trước), dòng 49/59/69/79 không dùng ABS. | Thiết kế theo Mô tả/Điều kiện từng dòng, bỏ qua ô lệch; (e) giữ nguyên công thức từng dòng. BA sửa CSV và xác nhận ABS. | K_VP_22,28,32,38,42,48-49,51-52,58,62-68 | BA Team | Open |
| O_VP_7 | Nhóm 5 - Datamart chưa thiết kế Fact/Dim | Security Trading Snapshot Dimension (GSTT) thiếu Product Group Id (Atomic `product_group_id`) để nhận diện HĐTL TPCP (`productgrpid = 'FBX'`). | reuse chuyển thành partial: thêm cột Product Group Id (nullable) vào Dimension; khi sửa LLD phải grep mọi KPI GSTT/PTTT/NDTNN dùng dimension này (H11). | K_VP_18-70 | Datamart Modeling Team | Open |
| O_VP_8 | Kỹ thuật Kiến trúc HLD | Chưa có screenshot Dashboard VP; Mockup mọi Nhóm suy từ BA. | Mockup chỉ minh họa; Presentation Grain xác định theo cột Độ chi tiết của BA. | K_VP_1-114 | BA Team / Datamart Modeling Team | Open |
| O_VP_9 | Kỹ thuật Kiến trúc HLD | Phạm vi HLD hiện tại: Lô 1 = Nhóm 1–10 (Nhóm 1–6 duyệt 2026-10-25; Nhóm 7–10 TPDN niêm yết/riêng lẻ bổ sung 2026-10-25); Lô 2 = Nhóm 11–16 (TPDN riêng lẻ Nhóm 11–13, TPCP Nhóm 14–16) bổ sung 2026-10-25. Nhóm 32–37 (Done) bổ sung ở Lô 3; Nhóm 17–31 và 38–55 chưa có mapping (Trạng thái mapping trống) sẽ vào PENDING [Nhóm 1 - BA chưa mapping xong]. Thiết kế VP cũ bị thay hoàn toàn; BA CSV đổi cấu trúc (delimiter ',', 25 cột) — đã cập nhật `ba_column_profile.yaml`. 9 dòng BA 415–423 thuộc Nhóm 37 (Trái phiếu NĐTNN) có cột TT trống nên parser gán khóa '?' — xử lý khi thiết kế Nhóm 37 (S2). Quy ước đánh số KPI: K_VP_1–114 đã dùng hết, không còn ID trống. K_VP_91–111 cấp cho Lô 2 (Nhóm 11 = K_VP_91–101, Nhóm 14 = K_VP_102–111; Nhóm 12, 13, 15, 16 chỉ reuse); K_VP_112–114 cấp cuối dải cho dòng BA CSV còn thiếu của Nhóm 7 (H17, O_VP_18). Lô 3 (Nhóm 32–37) cấp ID mới tiếp sau K_VP_114. | Làm tuần tự theo đợt (giới hạn 6 Nhóm/phiên). | — | Datamart Modeling Team | Open |
| O_VP_10 | Quy chuẩn LLD | SQL BA nối Sổ lệnh với bản tin MDDS khác nhau theo thị trường: cổ phiếu (Nhóm 1–2) nối trong, phái sinh (Nhóm 3/5/6) nối ngoài (LEFT JOIN `stock_daily_eod`). | Vuong chốt 2026-10-25: theo BA. Fact lấy Securities Trade làm bảng dẫn, INNER với STK/STX/UPX và LEFT với DVX; khóa ngoại Security Trading Snapshot Dimension cho phép NULL, thêm cột Security Symbol Code (Fact giao dịch) và Ticker Symbol (Fact hợp đồng phái sinh) để định danh dòng. | K_VP_5,9-17,21-28,31-38,41-48,51-58,61-68 | Datamart Modeling Team | Resolved |
| O_VP_11 | Quy chuẩn LLD | SQL BA Nhóm 1–2 dùng `SUM(CASE … END)` không `ELSE` (NULL khi nhóm không có giao dịch; hiệu mua − bán NULL làm rơi cả ngày); LLD dùng `ELSE 0`. | Vuong chấp nhận 2026-10-25: giữ `ELSE 0` — kết quả khác BA chỉ ở ô không có giao dịch (0 thay vì NULL). | K_VP_5,9-17 | Datamart Modeling Team | Resolved |
| O_VP_12 | Nhóm 3 - Thiếu nguồn Atomic / Ngoại lai | Atomic `End Of Day Open Interest` (VSDC): khóa thay thế `end_of_day_open_interest_id` chỉ băm từ CONTRACT_CODE (không có REPORT_DATE) và cột DS_SNPST_DT của BRD chưa được map. Nếu loader upsert theo khóa này thì lịch sử khối lượng mở theo ngày bị ghi đè. | Datamart giữ nguyên thiết kế Fact theo (mã hợp đồng, ngày báo cáo); báo Atomic team bổ sung ngày báo cáo vào khóa/BK trước khi nạp lịch sử. | K_VP_19-20,29-30,39-40,49-50,59-60 | Data Architecture / Atomic Team | Open |
| O_VP_13 | Quy chuẩn LLD | SQL BA nhận diện 'Sản phẩm phái sinh' (HĐTL VN30/VN100/TPCP) từ bản tin MDDS cuối ngày CÙNG ngày giao dịch (CTE `stock_daily_eod`); Detail Mapping lấy từ Security Trading Snapshot Dimension (current-state) qua khóa ngoại. Hai cách chỉ khác nhau khi hợp đồng không có bản tin MDDS đúng ngày giao dịch (BA: sản phẩm NULL, chỉ vào 'Toàn thị trường'). | Theo dimension current-state (Stock Type Code, Underlying Symbol, Product Group Id là thuộc tính tĩnh theo mã); dòng có khóa ngoại NULL vẫn được tính vào 'Toàn thị trường'. BA xác nhận có cần giữ đúng bản tin cùng ngày không. | K_VP_19-68 | BA Team / Datamart Modeling Team | Open |
| O_VP_14 | Quy chuẩn LLD | K_VP_70 (Giá HĐTL) cần 'ngày cuối cùng có dữ liệu trong kỳ' (BA: `MAX(tradingdate)` với `floorcode = '03'`); Fact Derivative Contract Snapshot không phân biệt 'có bản tin MDDS' với 'giá đóng cửa NULL'. | Detail Mapping dùng ngày lớn nhất trong kỳ có `close_price IS NOT NULL`; lệch BA chỉ khi cả ngày có bản tin nhưng giá đóng cửa NULL. | K_VP_70 | Datamart Modeling Team | Open |
| O_VP_15 | Nhóm 3 - Thiếu nguồn Atomic / Ngoại lai | Atomic `Listed Share Information` (HNX.LISTED_SECURITIES_LIST): khóa thay thế `listed_share_information_id` chỉ băm từ TICKER_SYMBOL (không có REPORT_DATE `rpt_dt`). Nếu loader upsert theo khóa này thì lịch sử khối lượng lưu hành theo ngày bị ghi đè (cùng dạng O_VP_12). | Datamart giữ thiết kế theo (mã, ngày báo cáo) và nối bản tin MDDS theo ngày; báo Atomic team bổ sung ngày báo cáo vào khóa/BK trước khi nạp lịch sử. | K_VP_87-88 | Data Architecture / Atomic Team | Open |
| O_VP_16 | Nhóm 3 - Thiếu nguồn Atomic / Ngoại lai | Giá trị `Market Id Code` = 'HCX' (Sổ lệnh HNX, TPDN niêm yết) và `Stock Type Code` = '1' (trái phiếu, MDDS.JAD_STOCKINFOR) lấy theo literal BA; chưa kiểm được giá trị thật vì Sổ lệnh cấp tài khoản không còn ở Atomic (O_VP_1) và chưa có dữ liệu mẫu. PTTT/NDTNN cũng dùng 'HCX' nhưng chưa ai đối chiếu dữ liệu thật. | Giữ literal BA ('HCX', '1'); Atomic/dev xác nhận giá trị khi có nguồn Sổ lệnh. | K_VP_71-88,90,112-114 | Data Architecture / Atomic Team | Open |
| O_VP_17 | Nhóm 1 - BA chưa mapping xong (mâu thuẫn BA) | Phạm vi TPDN niêm yết của các chỉ tiêu lấy từ bản tin MDDS (Số mã, Ngành, Kỳ hạn, Kỳ hạn còn lại, KL lưu hành): BA chỉ lọc `stocktype = '1'` (Trái phiếu), không loại TPCP/chứng khoán nợ khác. PTTT loại TPCP khỏi Stock Type Code '1' bằng bộ lọc tiền tố mã (fct_corporate_bond_market_snpst); GSTT cũng có loại (theo Data Modeler). | Theo BA literal: không loại TPCP khỏi Stock Type Code = '1'. GTGD (Sổ lệnh Market Id Code 'HCX') không bị ảnh hưởng; các chỉ tiêu từ bản tin MDDS có thể đếm thêm trái phiếu không phải TPDN. BA xác nhận có cần loại TPCP không. | K_VP_83-85,87-88,114 | BA Team | Open |
| O_VP_18 | Nhóm 1 - BA chưa mapping xong (BA CSV thiếu dòng) | Nhóm 7: SQL BA (dòng 113) xuất `gtgd_ytd`, `change_percent` của `gtgd_ytd` và `change_percent` của `sl_ma_niemyet` nhưng BA CSV không có dòng 'GTGD YTD', 'GTGD YTD - % thay đổi', 'Số mã TP niêm yết - % thay đổi' (H17). | Đã thêm K_VP_112–114 theo alias SQL BA; BA bổ sung dòng vào BA CSV và xác nhận tên/phân loại. | K_VP_112-114 | BA Team | Open |
| O_VP_19 | Nhóm 1 - BA chưa mapping xong (cần quyết định nghiệp vụ) | Nhóm 7–9: cột SQL BA không có dòng BA và chưa rõ có hiển thị: (a) Nhóm 8 `duno` (Dư nợ TP = KL lưu hành × mệnh giá); (b) Nhóm 9 dòng `loaitraiphieu = 'TPDN'` (tổng TPDN niêm yết + riêng lẻ); (c) Nhóm 7 `change_value` (thay đổi tuyệt đối kỳ báo cáo − kỳ trước của mọi chỉ tiêu). | Chưa thêm KPI (cần quyết định nghiệp vụ, H17). Bond Outstanding Value đã có trên Fact; 'TPDN' tổng và thay đổi tuyệt đối tính được tại presentation layer từ K_VP_73 + K_VP_89 và các KPI hiện có. BA xác nhận có hiển thị không. | K_VP_71,73,75,77,79,81,83,88,89,112 | BA Team | Open |
| O_VP_20 | Nhóm 1 - BA chưa mapping xong (mâu thuẫn BA) | Nhóm 7–10: (a) dòng 122 (Giá trị bán NĐTNN) chép công thức của dòng mua (`buy_account_number`); (b) dòng 118/119 nhãn 'YTD năm trước' nhưng SQL/Điều kiện so với CẢ NĂM TRƯỚC (01/01–31/12), không phải cùng kỳ năm trước; (c) dòng 113/127/134 (Kỳ) ghi Phân loại 'Chỉ tiêu cơ sở'; (d) dòng 126/132 (Số mã TP niêm yết): Điều kiện `PARTITION BY symbol` (bản ghi mới nhất theo mã) khác SQL (đếm mã theo ngày, lấy ngày cuối cùng trong kỳ); dòng 132 đánh giá 'Trùng' nhưng SQL nối INNER `listed_securities_list` (chỉ tính mã có danh mục HNX cùng ngày); (e) dòng 131 (Kỳ hạn còn lại bình quân): SQL dùng `TO_DATE(tradingdate,'dd/MM/yyyy')` trên cột kiểu DATE và Điều kiện dùng `MAX(s.report_date …)` (cột không tồn tại); (f) dòng 133 Mapping nghiệp vụ ghi VSDC nhưng Bảng nguồn HNX `listed_securities_list`; (g) dòng 125 (% ròng) không dùng ABS; (h) dòng 136 Mapping nghiệp vụ = '#NAME?' (lỗi Excel); (i) SQL BA cứng `ds_snpst_dt` không đồng nhất (IDS '2026-10-17', SCMS '2026-08-22', FMS '2026-10-21', ISS '2026-09-22'). | Thiết kế theo Mô tả/Điều kiện/SQL: (a) dùng số tài khoản bán; (b) so cả năm trước; (c) Chiều, reuse K_VP_1; (d) đếm Listed Indicator tại ngày cuối cùng có bản tin ≤ ngày cuối kỳ; (e) (Maturity Date − Trading Date)/12 theo công thức dòng; (f) theo Bảng nguồn HNX; (g) giữ theo dòng BA; (i) dùng bản hiện hành (`ds_rcrd_st` = 'ACTIVE'). BA sửa CSV/SQL và xác nhận. | K_VP_1,75-76,79,82-83,87-89 | BA Team | Open |
| O_VP_21 | Nhóm 3 - Thiếu nguồn Atomic / Ngoại lai | Atomic `Internal Statistical Report` (ISS): khóa BK ô = (Report Code, Sheet Name, Cell Code, Row Index, Period Value), không gồm Report Submission System Code (nguồn nộp ICP/CDW/KDL) và Submission Status Code. Nếu cùng ô/kỳ có nhiều nguồn hoặc nộp lại thì bản ghi sau ghi đè bản trước, trong khi BA chỉ lấy ICP + SUBMITTED/LATE_SUBMITTED. | Datamart giữ bộ lọc ICP + SUBMITTED/LATE_SUBMITTED như BA; Atomic team xác nhận cách lưu nhiều nguồn/lần nộp (hoặc đưa nguồn nộp vào BK) trước khi nạp lịch sử. | K_VP_89,91-99 | Data Architecture / Atomic Team | Open |
| O_VP_22 | Quy chuẩn LLD | Số phiên giao dịch (mẫu số GTGD bình quân phiên YTD) định nghĩa khác nhau theo Nhóm: Nhóm 7 (dòng 118) = số ngày có giao dịch TPDN niêm yết (`COUNT(DISTINCT trade_date)` với `market_id = 'HCX'`); Nhóm 11 (dòng 144) = số ngày có Sổ lệnh HNX (mọi `trade_book`), thiết kế dùng Is Trading Date của Calendar Date Dimension làm proxy — O_VP_30. | Giữ đúng định nghĩa từng Nhóm: K_VP_75 đếm ngày có Trading Value trên Fact Listed Corporate Bond Snapshot; K_VP_92 (Nhóm 11) đếm ngày Is Trading Date = 'Y' — O_VP_30. BA xác nhận định nghĩa thống nhất. | K_VP_75-76,92-93 | BA Team / Datamart Modeling Team | Open |
| O_VP_23 | Quy chuẩn LLD | Ngành của TPDN niêm yết: Fact dùng khóa ngoại Industry Dimension (GSDC) thay vì sao chép mã/tên ngành; ngành xác định qua tổ chức phát hành (3 ký tự đầu mã trái phiếu = mã cổ phiếu; SQL BA dòng 128) và CTCK/CTQLQ mặc định '07000'. Industry Dimension chưa xác nhận có dòng '07000' (O_GSTT_37 (1a)). | Nếu thiếu '07000' thì Industry Dimension Id NULL → nhóm 'NA'; dev xác nhận value set IDS ↔ Industry Dimension. | K_VP_84,86,90 | Datamart Modeling Team | Open |
| O_VP_24 | Nhóm 3 - Thiếu nguồn Atomic / Ngoại lai | Kiểm tra nguồn thay thế `Securities Trade` cho Sổ lệnh TPDN niêm yết (Vuong yêu cầu 2026-10-25 — kiểm rồi chuyển). Đối chiếu ngoại tuyến (Atomic YAML, BRD, `HNX_UAT_schema.txt`, `mapping_vsdc_ods_atm.md`): `Bond Order Book` (HNX outright/repo/repo2) có `buying/selling_account_nbr` nhưng KHÔNG tài liệu nào có value set của `instrument_tp`/`bond_code` (chỉ ghi 'Loại hàng hóa', 'Mã TP'), BA VP/NDTNN dùng nó cho TPCP, còn TPDN niêm yết dùng Sổ lệnh market 'HCX' ⇒ chưa chứng minh được `Bond Order Book` chứa TPDN niêm yết. `Corporate Bond Trading Snapshot` (MDDS.JAD_CORPBONDINFOR) thay được KLGD/GTGD/số mã/kỳ hạn nhưng KHÔNG có NĐTNN mua/bán. `Security Match Log` không có tài khoản và không có trái phiếu. | Chưa chuyển nguồn (không đủ bằng chứng) — giữ `Securities Trade` kèm `[!]` (O_VP_1). Dev chạy giúp trên UAT: (1) `SELECT instrument_tp, order_book_tp, COUNT(*), COUNT(DISTINCT bond_code), MIN(bond_code), MAX(bond_code) FROM bond_order_book GROUP BY instrument_tp, order_book_tp`; (2) số `bond_code` của `Bond Order Book` khớp `ticker_symbol` hoặc `isin_code` của `Security Trading Snapshot` với `stock_tp_code = '1'`. Nếu khớp phần lớn mã TPDN niêm yết: chuyển K_VP_71–82, 86, 90, 112–113 sang `Bond Order Book` (OUTRIGHT: `trading_val`; NĐTNN theo ký tự thứ 4 tài khoản, lọc `order_status = 'ĐTH'`); nếu không: giữ như hiện tại hoặc BA đổi nguồn. | K_VP_71-82,86,90,112-113 | Data Architecture / Atomic Team | Open |
| O_VP_25 | Quy chuẩn LLD | Ngành TPDN niêm yết (SQL BA dòng 128/138): BA lọc `delete_flg <> '1'` (IDS), `deleted = '0'` (SCMS), `deleted = 0` (FMS); Atomic không còn các cột cờ xóa này. | Thay bằng `ds_rcrd_st = 'ACTIVE'` (viết trần, không kèm tên bảng) theo tiền lệ GSDC/QLCB/PTTT/GSTT; hồ sơ IDS `approval_status_code = 'REJECTED'` vẫn loại như BA. Giả định theo tiền lệ — BA/dev xác nhận. | K_VP_84,86,90 | BA Team / Datamart Modeling Team | Open |
| O_VP_26 | Nhóm 3 - Thiếu nguồn Atomic / Ngoại lai | Atomic `Private Corp Bond Registration` (HNX): khóa thay thế `private_corp_bond_registration_id` chỉ băm từ BOND_CODE, không có tháng báo cáo (`rpt_year`, `rpt_month`, `rpt_day`). Nếu loader upsert theo khóa này thì mỗi mã chỉ còn bản ghi của tháng báo cáo mới nhất và lịch sử số mã đăng ký giao dịch theo tháng bị ghi đè (cùng dạng O_VP_12, O_VP_15). | Datamart giữ grain mã × tháng báo cáo (Fact Private Corporate Bond Registration Snapshot); báo Atomic team bổ sung tháng báo cáo vào khóa/BK trước khi nạp lịch sử. Nếu khóa không đổi: chỉ tính được số mã ĐKGD của tháng báo cáo mới nhất, kỳ trước (K_VP_101) có thể không có dữ liệu. | K_VP_100-101 | Data Architecture / Atomic Team | Open |
| O_VP_27 | Quy chuẩn LLD | Fact Private Corporate Bond Registration Snapshot: (a) Atomic không có ngày snapshot — khóa ngoại ngày được suy ra từ `rpt_year`/`rpt_month`, BA SQL bỏ qua `rpt_day`; (b) `rpt_year`/`rpt_month` kiểu string, chưa kiểm có đệm số 0 — SQL BA `CONCAT(report_year, report_month)` dùng như chuỗi yyyyMM và so sánh/`MAX` theo chuỗi, sai nếu tháng 1–9 không đệm; (c) LLD nạp Fact theo ngày với điều kiện ngày cuối tháng báo cáo = ngày ETL (`:etl_date`) — dòng tháng M chỉ được nạp khi ETL chạy đúng ngày cuối tháng M (flat cùng điều kiện), nên báo cáo HNX đến muộn phải chạy bù. | Snapshot Date Dimension Id = ngày cuối tháng báo cáo (ép kiểu số từ rpt_year/rpt_month, không phụ thuộc đệm số 0); chọn tháng báo cáo mới nhất và so sánh theo ngày thay vì chuỗi. Giả định — dev xác nhận định dạng thật của `rpt_month`, BA xác nhận không cần `rpt_day`. (c) Giữ điều kiện ngày cuối tháng = `:etl_date` theo cách BA coi báo cáo tháng M đã có tại ngày cuối tháng; phương án thay thế là cửa sổ lookback 1 tháng (đổi WHERE ở LLD và flat) — dev/BA chọn. | K_VP_100-101 | Datamart Modeling Team | Open |
| O_VP_28 | Nhóm 1 - BA chưa mapping xong (cần quyết định nghiệp vụ) | SQL BA Nhóm 11 và Nhóm 14 xuất cột không có dòng BA (H17): (a) Nhóm 11 — `gtgd_pct_thaydoi` (alias đặt nhầm: giá trị là hiệu tuyệt đối GTGD kỳ này − kỳ trước, còn `gtgd_pct_thaydoi_pt` mới là %), `gtgd_bq_ytd_thaydoi`, `gtgd_ndtnn_mua_thaydoi`, `gtgd_ndtnn_ban_thaydoi`, `gtgd_ndtnn_rong_thaydoi`, `so_ma_dkgd_thaydoi` (thay đổi tuyệt đối) và `gtgd_bq_ytd_namtruoc` (GTGD bình quân phiên của cả năm trước); (b) Nhóm 14 — `klgd_thaydoi`, `gtgd_thaydoi`, `gtgd_ndtnn_mua_thaydoi`, `gtgd_ndtnn_ban_thaydoi`, `gtgd_ndtnn_rong_thaydoi`, `kytruoc` (mã kỳ trước). Cùng dạng O_VP_19(c) của Nhóm 7 (`change_value`). | Chưa thêm KPI (cần quyết định nghiệp vụ có hiển thị cột 'Thay đổi' tuyệt đối không, H17). Hiệu tuyệt đối và giá trị kỳ trước tính được tại presentation layer từ KPI hiện có ở kỳ báo cáo và kỳ trước. BA xác nhận; nếu hiển thị thì bổ sung dòng BA CSV. | K_VP_89,92,94,96,98,100,102,104,106,108,110 | BA Team | Open |
| O_VP_29 | Nhóm 1 - BA chưa mapping xong (mâu thuẫn BA) | Nhóm 11–13: (a) dòng 141 (Kỳ) Phân loại 'Chỉ tiêu cơ sở' nhưng là Chiều thời gian (cùng dạng O_VP_20(c)); (b) dòng 142–143, 146–151 và 154–159 Mapping nghiệp vụ = '#NAME?' (lỗi Excel, cùng dạng O_VP_20(h)); (c) dòng 143 (GTGD TPDN riêng lẻ — % thay đổi) Đánh giá 'Trùng' nhưng Nhóm 9 chỉ có K_VP_89, chưa có KPI % thay đổi; (d) dòng 144/145 nhãn 'YTD năm trước' nhưng SQL so với CẢ NĂM TRƯỚC (01/01–31/12), và Điều kiện dòng 144 ghi 'GTGD kỳ / Số phiên' trong khi Mô tả và SQL dùng Σ GTGD từ 01/01 đến ngày cuối kỳ; (e) dòng 145 Bảng nguồn ghi `uat_hose_stg.trade_book` (HOSE) trong khi dòng 144 và SQL dùng `uat_hnx_stg.trade_book` (HNX); (f) dòng 151 chia ABS(kỳ trước) (Mô tả + SQL) trong khi dòng 125 (Nhóm 7) và dòng 170 (Nhóm 14) không dùng ABS; (g) dòng 152–153 Loại dữ liệu 'Chưa có CSDL - Map biểu mẫu' nhưng SQL đọc `private_corp_bond_registration` (Atomic có); (h) SQL Nhóm 11 cứng `ds_snpst_dt = '2026-10-22'`, SQL Nhóm 12 cứng `'2026-09-04'` (cùng dạng O_VP_20(i)); (i) Nhóm 12 và Nhóm 13 dùng chung SQL (đặt ở dòng 154), SQL xuất cả `gtgd_ndtnn_*` thuộc Nhóm 13. | Thiết kế theo Mô tả/Điều kiện/SQL: (a) Chiều, reuse K_VP_1; (c) khai sinh K_VP_91; (d) Σ GTGD từ 01/01 đến cuối kỳ, so với cả năm trước; (e) HNX; (f) giữ ABS theo dòng 151; (g) READY (Atomic có); (h) dùng bản hiện hành `ds_rcrd_st = 'ACTIVE'`. BA sửa CSV/SQL và xác nhận. | K_VP_1,89,91-101 | BA Team | Open |
| O_VP_30 | Quy chuẩn LLD | Số phiên giao dịch (mẫu số GTGD bình quân phiên YTD, dòng 144 Nhóm 11) theo BA = số ngày có dữ liệu Sổ lệnh HNX (`COUNT(DISTINCT trade_date)` trên `hnx.trade_book`); Securities Trade bị gỡ khỏi Atomic (O_VP_1) nên không dựng được từ Sổ lệnh. | Dùng Calendar Date Dimension.Is Trading Date = 'Y' (GSTT, O_GSTT_62 — UNION 4 nguồn: Market Index Snapshot, Security Trading Snapshot, Securities Trade nhánh HOSE và HNX) làm proxy cho 'ngày có Sổ lệnh HNX'. Lệch BA nhẹ: ngày chỉ có dữ liệu HOSE/MDDS mà không có Sổ lệnh HNX vẫn được tính. KPI không phụ thuộc trực tiếp Securities Trade. BA xác nhận chấp nhận proxy. | K_VP_92-93 | BA Team / Datamart Modeling Team | Open |
| O_VP_31 | Nhóm 1 - BA chưa mapping xong (mâu thuẫn BA) | Nhóm 14–16: (a) dòng 161/163 (KLGD/GTGD TPCP) không ghi bộ lọc `order_status` nhưng SQL (dòng 160) lọc `order_status = 'ĐTH'` cho mọi chỉ tiêu (dòng 165/167 ghi rõ); (b) dòng 169 (Giá trị mua/bán ròng NĐTNN) Phân loại 'Chỉ tiêu cơ sở' nhưng Mô tả là mua − bán; (c) dòng 175–177 (Nhóm 16) Độ chi tiết 'Loại CK / Thị trường, Ngày' và Đánh giá 'TB' nhưng SQL dùng chung Nhóm 15 cộng gộp OUTRIGHT + REPO, Mô tả/Điều kiện giống dòng 165/167/169; (d) dòng 161/172 Điều kiện ghi `o.volumne` (typo của `volume`); (e) dòng 170 (% ròng): Mô tả không dùng ABS, SQL chia ABS(kỳ trước); (f) dòng 160/171/174 (Kỳ) Đánh giá 'TB' nhưng cùng định nghĩa Kỳ của Nhóm 1. | (a) lọc 'ĐTH' cho mọi chỉ tiêu theo SQL; (b) Tính chất Phái sinh; (c) reuse K_VP_106/108/110 (Case 2) — Order Book Type Code nằm trong grain nên tách được 'Loại CK / Thị trường' nếu BA cần; (d) `volume`; (e) theo Mô tả (không ABS) như K_VP_82; (f) reuse K_VP_1. BA sửa CSV/SQL và xác nhận. | K_VP_1,102-111 | BA Team | Open |
| O_VP_32 | Nhóm 3 - Thiếu nguồn Atomic / Ngoại lai | Atomic `Bond Order Book` (HNX; dùng cho Nhóm 14–16 thay 2 bảng staging `outright_order_book` / `repo_order_book` của BA): (a) literal `order_status = 'ĐTH'` và `order_book_tp` ∈ ('OUTRIGHT', 'REPO') lấy theo BA / Atomic (`etl_derived_value`), chưa kiểm giá trị thật; (b) BA không lọc loại trái phiếu — coi mọi lệnh outright/repo HNX là TPCP, trong khi chưa có value set của `instrument_tp`/`bond_code` (O_VP_24 nghi ngờ bảng chứa cả TPDN); (c) `trading_val` chỉ có ở OUTRIGHT (NULL với REPO) nên REPO dùng `first_settlement_val` (GTTT lần 1) theo BA, REPO2 loại khỏi Fact vì BA không đọc; (d) BA không dùng `order_side`: giả định mỗi dòng đã thực hiện mang đủ số tài khoản mua và bán, không bị nhân đôi theo phía; (e) `foreign_buy_val` / `foreign_sell_val` của Fact TPCP để NULL khi ngày không có lệnh NĐTNN (đúng `SUM(CASE ...)` của BA), khác Fact TPDN niêm yết dùng `ELSE 0` (O_VP_11). | Giữ theo BA; dev xác nhận giá trị `order_status`, value set `order_book_tp`/`instrument_tp` (cùng truy vấn (1) của O_VP_24) và (d) trên UAT. Nếu bảng chứa cả TPDN: thêm bộ lọc loại trái phiếu và mở lại Nhóm 14–16. | K_VP_102-111 | Data Architecture / Atomic Team | Open |
