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

> **[SỬA 2026-10-28 — BA VP cập nhật Nhóm 1/2: phạm vi 'cổ phiếu, Chứng chỉ quỹ' (bỏ chứng quyền)]** BA đổi Mô tả (bỏ 'chứng quyền'), Độ chi tiết (thêm 'Loại chứng khoán'), Nguồn/Bảng nguồn (thêm MDDS `jad_stockinfor`) và Điều kiện: lấy `jad_stockinfor` bản ghi cuối mỗi `symbol` với `stocktype IN ('2','3','6')`, nối giao dịch `s.symbol = t.symbol` (HOSE) / `s.symbol = h.issue_code` (HNX); SQL đổi CTE `stock_daily_eod` (theo ngày) thành `stock_portfolio` (bản ghi cuối — loại CK không đổi theo ngày). Thiết kế: KPI Nhóm này lọc `Security Trading Snapshot Dimension.Stock Type Code IN ('2','3','6')` qua FK `security_trading_snpst_dim_id` của `Fact Investor Group Trading Snapshot` (HNX/UPCOM: 2 Cổ phiếu, 3 CCQ, 6 ETF; HOSE: 2 Cổ phiếu, 3 CCQ/ETF) — không đổi Fact. **O_VP_4 đã đóng** (trước đây Mô tả/Điều kiện không lọc loại CK còn SQL lọc `stocktype = '2'`). Khác BA: HNX nối theo `isin_code` (ISSUE_CODE HNX lưu ISIN, A17) — **O_VP_33**.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Case 1 — reuse Calendar Date Dimension (cdr_dt_dim); kỳ = tham số lọc tại presentation layer | READY |
| K_VP_2 | Sàn | — | Chiều | HOSE / HNX / UPCOM / Toàn thị trường. Chỉ số: Market Index Dimension.Market Code ('HOSE','HNX','UPCOM'); giao dịch: Fact Investor Group Trading Snapshot.Market Id Code (HOSE = 'STK', HNX = 'STX', UPCOM = 'UPX') | Tham số lọc Sàn; ánh xạ HOSE→STK, HNX→STX, UPCOM→UPX theo Điều kiện BA | READY |
| K_VP_3 | Chỉ số | — | Chiều | Market Index Dimension.Index Name với Market Code IN ('HOSE','HNX','UPCOM'); Sàn = 'Toàn thị trường' lấy cả 3 chỉ số | Case 1 — reuse Market Index Dimension (QLKD) | READY |
| K_VP_4 | Giá trị chỉ số | Điểm | Cơ sở | Fact Market Index Snapshot.Market Index Value tại ngày giao dịch cuối cùng của kỳ (Fact giữ bản ghi cuối ngày: Index Time DESC, Sequence DESC) | Case 1 — reuse Fact Market Index Snapshot (QLKD); chọn chỉ số theo Market Code, không theo Index Name (H14) | READY |
| K_VP_5 | GT mua/bán ròng NĐTNN | VND | Phái sinh | SUM(Buy Value − Sell Value) trên Fact Investor Group Trading Snapshot với Investor Group Code = 'FOREIGN', Market Id Code theo Sàn và `Security Trading Snapshot Dimension.Stock Type Code IN ('2','3','6')` (cổ phiếu + CCQ, bỏ chứng quyền), trong kỳ | NĐTNN = ký tự thứ 4 của số tài khoản ∈ (E, F). [!] Nguồn Securities Trade — O_VP_1; phạm vi loại CK: Stock Type Code ∈ ('2','3','6') theo BA 2026-10-28 (O_VP_4 đã đóng); độ chi tiết 'Loại chứng khoán' = Stock Type Code/Name. Case 2 — tính tại presentation layer từ Buy Value / Sell Value | READY |
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
        string Industry_Dimension_Id FK
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

> **[SỬA 2026-10-28 — BA VP cập nhật Nhóm 1/2: phạm vi 'cổ phiếu, Chứng chỉ quỹ' (bỏ chứng quyền)]** BA đổi Mô tả (bỏ 'chứng quyền'), Độ chi tiết (thêm 'Loại chứng khoán'), Nguồn/Bảng nguồn (thêm MDDS `jad_stockinfor`) và Điều kiện: lấy `jad_stockinfor` bản ghi cuối mỗi `symbol` với `stocktype IN ('2','3','6')`, nối giao dịch `s.symbol = t.symbol` (HOSE) / `s.symbol = h.issue_code` (HNX); SQL đổi CTE `stock_daily_eod` (theo ngày) thành `stock_portfolio` (bản ghi cuối — loại CK không đổi theo ngày). Thiết kế: KPI Nhóm này lọc `Security Trading Snapshot Dimension.Stock Type Code IN ('2','3','6')` qua FK `security_trading_snpst_dim_id` của `Fact Investor Group Trading Snapshot` (HNX/UPCOM: 2 Cổ phiếu, 3 CCQ, 6 ETF; HOSE: 2 Cổ phiếu, 3 CCQ/ETF) — không đổi Fact. **O_VP_4 đã đóng** (trước đây Mô tả/Điều kiện không lọc loại CK còn SQL lọc `stocktype = '2'`). Khác BA: HNX nối theo `isin_code` (ISSUE_CODE HNX lưu ISIN, A17) — **O_VP_33**.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Reuse từ Nhóm 1 (K_VP_1) — Case 1: measure vật lý có sẵn trên Fact/Dim | READY |
| K_VP_2 | Sàn | — | Chiều | HOSE / HNX / UPCOM / Toàn thị trường. Chỉ số: Market Index Dimension.Market Code ('HOSE','HNX','UPCOM'); giao dịch: Fact Investor Group Trading Snapshot.Market Id Code (HOSE = 'STK', HNX = 'STX', UPCOM = 'UPX') | Reuse từ Nhóm 1 (K_VP_2) — Case 1: measure vật lý có sẵn trên Fact/Dim | READY |
| K_VP_3 | Chỉ số | — | Chiều | Market Index Dimension.Index Name với Market Code IN ('HOSE','HNX','UPCOM'); Sàn = 'Toàn thị trường' lấy cả 3 chỉ số | Reuse từ Nhóm 1 (K_VP_3) — Case 1: measure vật lý có sẵn trên Fact/Dim | READY |
| K_VP_4 | Giá trị chỉ số | Điểm | Cơ sở | Fact Market Index Snapshot.Market Index Value tại ngày giao dịch cuối cùng của kỳ (Fact giữ bản ghi cuối ngày: Index Time DESC, Sequence DESC) | Reuse từ Nhóm 1 (K_VP_4) — Case 1: measure vật lý có sẵn trên Fact/Dim | READY |
| K_VP_13 | GT mua/bán ròng Tự doanh | VND | Cơ sở | SUM(Buy Value − Sell Value) trên Fact Investor Group Trading Snapshot với Investor Group Code = 'PROPRIETARY', Market Id Code theo Sàn và `Security Trading Snapshot Dimension.Stock Type Code IN ('2','3','6')` (cổ phiếu + CCQ, bỏ chứng quyền), trong kỳ | Tự doanh = ký tự thứ 4 của số tài khoản ∈ (P, E, A) theo BA; GSTT chỉ dùng (P, E) — O_VP_2. [!] Nguồn Securities Trade — O_VP_1; phạm vi loại CK: Stock Type Code ∈ ('2','3','6') theo BA 2026-10-28 (O_VP_4 đã đóng); độ chi tiết 'Loại chứng khoán' = Stock Type Code/Name. Case 2 — tính tại presentation layer | READY |
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
        string Industry_Dimension_Id FK
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
        string Industry_Dimension_Id FK
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
        string Industry_Dimension_Id FK
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
        string Industry_Dimension_Id FK
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

**[CẬP NHẬT 2026-11-08 — BA đổi trường ngày của `listed_securities_list`]** BA dòng 127 (SQL Kỳ) và dòng 133 (KL TP đang lưu hành) đổi khóa ngày của `uat_hnx_stg.listed_securities_list` từ `report_date` sang `MAKE_DATE(report_year, report_month, report_day)`; dòng 132 (Số mã TP niêm yết) sửa tên cột ngày của `jad_stockinfor` trong Điều kiện (`s.report_date` → `s.tradingdate`, ngữ nghĩa không đổi). Fact Listed Corporate Bond Snapshot đã nối Atomic Listed Share Information theo `make_date(rpt_year, rpt_month, rpt_day)` từ trước nên LLD và công thức KPI không đổi — chỉ đồng bộ ghi chú (O_VP_65).

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
| K_VP_83 | Số mã TP niêm yết | Mã | Cơ sở | COUNT(DISTINCT Security Symbol Code) trên Fact Listed Corporate Bond Snapshot với Listed Indicator = TRUE và Snapshot Date ≤ ngày cuối kỳ (mỗi mã tính 1 lần theo bản ghi mới nhất không quá ngày cuối kỳ, gồm cả mã đã đáo hạn; bản tin MDDS Stock Type Code = '1') | Reuse từ Nhóm 7 (K_VP_83) — Case 1: measure vật lý có sẵn trên Fact/Dim. Nhóm 8 gom theo (Ngành, Kỳ hạn phát hành) tại ngày cuối kỳ; BA 'Trùng' nhưng SQL nối INNER Listed Securities List — O_VP_20; Điều kiện BA dòng 132 sửa tên cột ngày thành `tradingdate` (2026-11-08) — O_VP_65 | READY |
| K_VP_88 | KL TP đang lưu hành | Trái phiếu | Cơ sở | SUM(Outstanding Bond Quantity) theo (Ngành, Kỳ hạn phát hành) tại ngày giao dịch cuối cùng có bản tin trong kỳ | Case 1 — measure Outstanding Bond Quantity (Listed Share Information HNX nối theo Ticker Symbol và ngày báo cáo MAKE_DATE(Report Year, Report Month, Report Day) = Trading Date); BA ghi Mapping nghiệp vụ VSDC nhưng Bảng nguồn HNX — theo Bảng nguồn, O_VP_20; khóa Atomic — O_VP_15 | READY |

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
| K_VP_100 | Số mã TP ĐKGD | Mã | Cơ sở | COUNT(DISTINCT Bond Code) trên Fact Private Corporate Bond Registration Snapshot với Maturity Date > ngày cuối kỳ, tại tháng báo cáo được chọn theo loại kỳ: Tháng = chính tháng đó; Quý / Năm = tháng báo cáo mới nhất có dữ liệu trong quý/năm (Snapshot Date lớn nhất trong kỳ); Ngày = tháng của ngày tra cứu nếu là ngày cuối tháng, ngược lại tháng liền trước | Case 1 — COUNT(DISTINCT Bond Code) trên Fact Private Corporate Bond Registration Snapshot (mỗi dòng = 1 mã đăng ký giao dịch của 1 tháng báo cáo; từ 2026-11-08 có thêm measure KL/giá trị ĐKGD, O_VP_68); số thời điểm tại ngày cuối kỳ; BA ghi Loại dữ liệu 'Chưa có CSDL - Map biểu mẫu' nhưng SQL đọc `private_corp_bond_registration` (Atomic có) — READY, O_VP_29; khóa Atomic chỉ băm Bond Code — O_VP_26; FK ngày = ngày cuối tháng báo cáo — O_VP_27 | READY |
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
        bigint Registered_Trading_Bond_Quantity
        bigint Par_Value
        decimal Registered_Trading_Value
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

#### Nhóm 17 - Niêm yết >> Chỉ tiêu tổng hợp

> Phân loại: **Phân tích**
> Atomic: tái dùng `Fact Listed Equity Snapshot`, `Fact Government Bond Listing Snapshot`, `Fact Private Corporate Bond Registration Snapshot` (quy mô niêm yết/ĐKGD; mở rộng Fact theo O_VP_68) và `Fact Listing Status Change Snapshot` (HNX/HOSE LISTING_STATUS_CHANGE, sự kiện niêm yết mới/bổ sung/hủy của cổ phiếu, CCQ, ETF, chứng quyền, TPDN niêm yết); thêm 2 Fact sự kiện mới — `Fact Government Bond Listing Change Snapshot` (HNX.GOV_BOND_ADDITIONAL_LISTING) và `Fact Private Corporate Bond Registration Status Snapshot` (HNX.REGISTRATION_STATUS_CHANGE) — **READY**; phụ thuộc dev ETL + flat + nạp lại lịch sử (O_VP_68, O_VP_71)

> **[GHI CHÚ 2026-11-08 — BA VP mapping Nhóm 17]** BA Nhóm 17 gồm 16 dòng (178–193: 2 Chiều — Kỳ, Loại chứng khoán; 7 chỉ tiêu cơ sở — số mã, KL, GT niêm yết/ĐKGD, số mã niêm yết mới, KL mới/bổ sung, số mã hủy, KL hủy; mỗi chỉ tiêu kèm 1 dòng '% so với kỳ trước'; 9 'TB' + 7 'Trùng'). 7 dòng 'Trùng' (% so với kỳ trước) KHÔNG nêu trùng với chỉ tiêu nào → thiết kế đủ 15 KPI mới (K_VP_375–389) và reuse K_VP_1; Δ số lượng BA ↔ HLD ở Gate 10 là CÓ CHỦ Ý. Quy mô niêm yết đọc 3 Fact theo loại chứng khoán (MDDS / TPCP / TPDN riêng lẻ); sự kiện mới/bổ sung/hủy đọc `Fact Listing Status Change Snapshot` (cổ phiếu…), Fact TPCP sự kiện mới và Fact TPDN riêng lẻ trạng thái đăng ký (số lũy kế từ đầu năm → phát sinh tháng bằng LAG ở Detail Mapping). Giả định/lệch BA (kỳ Ngày, mệnh giá chứng quyền, TPDN riêng lẻ không lọc ngày đáo hạn, Điều kiện dòng 192 ghi nhầm nhãn) ghi ở O_VP_71.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (Tháng / Quý / Năm) · Kỳ tra cứu

| Loại chứng khoán | Số mã NY/ĐKGD | % so với kỳ trước | KL NY/ĐKGD | % | GT NY/ĐKGD | % | Số mã mới | % | KL mới/bổ sung | % | Số mã hủy | % | KL hủy | % |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Cổ phiếu / CCQ / ETF / Chứng quyền / TPCP / TPDN niêm yết / TPDN riêng lẻ | … | … | … | … | … | … | … | … | … | … | … | … | … | … |

> ⚠️ Presentation Grain: 1 dòng = 1 Loại chứng khoán (7 loại) tại 1 kỳ tra cứu, kèm giá trị kỳ trước và % thay đổi. Storage Grain: 1 mã chứng khoán × 1 ngày giao dịch (quy mô MDDS), 1 mã TPCP / TPDN riêng lẻ × 1 tháng báo cáo (quy mô), 1 sự kiện thay đổi niêm yết (cổ phiếu…, TPCP) hoặc 1 mã × 1 trạng thái × 1 tháng báo cáo lũy kế (TPDN riêng lẻ) — xem Bảng grain.

**Source:** `Fact Listed Equity Snapshot`, `Fact Government Bond Listing Snapshot`, `Fact Private Corporate Bond Registration Snapshot`, `Fact Listing Status Change Snapshot`, `Fact Government Bond Listing Change Snapshot`, `Fact Private Corporate Bond Registration Status Snapshot` → `Calendar Date Dimension`, `Security Trading Snapshot Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date trong kỳ (M/Q/Y) từ ngày đầu kỳ đến ngày cuối kỳ | Reuse K_VP_1 (Nhóm 1, 7, 19, 20, 22) — Case 1; BA dòng 178 — 1 kỳ duy nhất; Mô tả có kỳ Ngày nhưng SQL chỉ M/Q/Y — O_VP_71 | READY |
| K_VP_375 | Loại chứng khoán | — | Chiều | Cổ phiếu / CCQ / ETF / Chứng quyền / TPDN niêm yết từ Stock Type Code + Fund Type Code; TPCP và TPDN riêng lẻ theo Fact tương ứng | Case 1 — BA dòng 179 'TB'; cùng định nghĩa K_VP_348 (Nhóm 18) nhưng phủ cả nguồn sự kiện; loại 1/4 và Fund Type Code mở rộng Fact (O_VP_68) | READY |
| K_VP_376 | Số mã niêm yết/ĐKGD | Mã | Cơ sở | COUNT(Ticker Symbol) tại ngày giao dịch cuối kỳ (Fact Listed Equity Snapshot) + COUNT(Bond Code) TPCP và TPDN riêng lẻ tại tháng báo cáo mới nhất trong kỳ | Case 2 — hợp 3 Fact theo Loại chứng khoán; BA dòng 180 'TB'; TPDN riêng lẻ không lọc ngày đáo hạn (khác K_VP_100) | READY |
| K_VP_377 | Số mã niêm yết/ĐKGD - % so với kỳ trước | % | Phái sinh | (K_VP_376 kỳ này − K_VP_376 kỳ trước) / K_VP_376 kỳ trước × 100 | Case 2 — BA dòng 181 'Trùng' không nêu chỉ tiêu trùng | READY |
| K_VP_378 | KL niêm yết/ĐKGD | Cổ phiếu/CCQ/trái phiếu | Cơ sở | SUM(Listed Share Quantity) tại ngày giao dịch cuối kỳ + SUM(Listed Bond Quantity) TPCP + SUM(Registered Trading Bond Quantity) TPDN riêng lẻ tại tháng báo cáo mới nhất trong kỳ | Case 2 — hợp 3 Fact theo Loại chứng khoán; BA dòng 182 'TB' | READY |
| K_VP_379 | KL niêm yết/ĐKGD - % so với kỳ trước | % | Phái sinh | (K_VP_378 kỳ này − K_VP_378 kỳ trước) / K_VP_378 kỳ trước × 100 | Case 2 — BA dòng 183 'Trùng' | READY |
| K_VP_380 | Giá trị niêm yết/ĐKGD | VND | Cơ sở | SUM(Listed Share Value) + SUM(Listed Bond Value) + SUM(Registered Trading Value) theo Loại chứng khoán tại ngày/tháng chốt kỳ | Case 2 — hợp 3 Fact; BA dòng 184 'TB'; mệnh giá chứng quyền Mô tả 'để trống' nhưng SQL 10000 — O_VP_71 | READY |
| K_VP_381 | Giá trị niêm yết/ĐKGD - % so với kỳ trước | % | Phái sinh | (K_VP_380 kỳ này − K_VP_380 kỳ trước) / K_VP_380 kỳ trước × 100 | Case 2 — BA dòng 185 'Trùng' | READY |
| K_VP_382 | Số mã niêm yết/ĐKGD mới | Mã | Cơ sở | Số mã có new_listed_shares > 0 (Fact Listing Status Change Snapshot, kỳ theo effective_date) + số mã 'Niêm yết mới' (TPCP) + phát sinh tháng của số mã 'Đăng ký giao dịch' (TPDN riêng lẻ) | Case 2 — hợp 3 Fact theo Loại chứng khoán; BA dòng 186 'TB'; 2 Fact sự kiện mới (O_VP_71) | READY |
| K_VP_383 | Số mã niêm yết/ĐKGD mới - % so với kỳ trước | % | Phái sinh | (K_VP_382 kỳ này − K_VP_382 kỳ trước) / K_VP_382 kỳ trước × 100 | Case 2 — BA dòng 187 'Trùng' | READY |
| K_VP_384 | KL niêm yết/ĐKGD mới/bổ sung | Cổ phiếu/CCQ/trái phiếu | Cơ sở | SUM(new_listed_shares) + SUM(additional_listed_shares) + KL 'Niêm yết mới' và 'Niêm yết bổ sung' (TPCP) + phát sinh tháng của KL 'Đăng ký giao dịch' (TPDN riêng lẻ) | Case 2 — hợp 3 Fact theo Loại chứng khoán; BA dòng 188 'TB' | READY |
| K_VP_385 | KL niêm yết/ĐKGD mới/bổ sung - % so với kỳ trước | % | Phái sinh | (K_VP_384 kỳ này − K_VP_384 kỳ trước) / K_VP_384 kỳ trước × 100 | Case 2 — BA dòng 189 'Trùng' | READY |
| K_VP_386 | Số mã hủy niêm yết/ĐKGD | Mã | Cơ sở | Số mã có delisted_shares > 0 (Fact Listing Status Change Snapshot) + số mã 'Đáo hạn' (TPCP) + phát sinh tháng của số mã 'Hủy đăng ký giao dịch' (TPDN riêng lẻ) | Case 2 — hợp 3 Fact theo Loại chứng khoán; BA dòng 190 'TB' | READY |
| K_VP_387 | Số mã hủy niêm yết/ĐKGD - % so với kỳ trước | % | Phái sinh | (K_VP_386 kỳ này − K_VP_386 kỳ trước) / K_VP_386 kỳ trước × 100 | Case 2 — BA dòng 191 'Trùng' | READY |
| K_VP_388 | KL hủy niêm yết/ĐKGD | Cổ phiếu/CCQ/trái phiếu | Cơ sở | SUM(delisted_shares) + KL 'Đáo hạn' (TPCP) + phát sinh tháng của KL 'Hủy đăng ký giao dịch' (TPDN riêng lẻ) | Case 2 — hợp 3 Fact theo Loại chứng khoán; BA dòng 192 'TB' | READY |
| K_VP_389 | KL hủy niêm yết/ĐKGD - % so với kỳ trước | % | Phái sinh | (K_VP_388 kỳ này − K_VP_388 kỳ trước) / K_VP_388 kỳ trước × 100 | Case 2 — BA dòng 193 'Trùng'; Mô tả ghi 'Giá trị' hiểu là KL hủy | READY |

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
    Fact_Listed_Equity_Snapshot {
        string Listed_Equity_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Industry_Dimension_Id FK
        string Ticker_Symbol
        string Floor_Code
        string Stock_Type_Code
        string Fund_Type_Code
        bigint Outstanding_Share_Quantity
        bigint Listed_Share_Quantity
        decimal Listed_Share_Value
        decimal Close_Price
        decimal Reference_Price
        bigint Next_Day_Volume_Weighted_Average_Price
        decimal Market_Price
        decimal Market_Cap_Value
        string Source_System_Code
    }
    Fact_Listing_Status_Change_Snapshot {
        string Listing_Status_Change_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Security_Trading_Snapshot_Dimension_Id FK
        string Ticker_Symbol
        string Decision_Number
        date Decision_Date
        date Effective_Date
        date Listing_Last_Trading_Date
        bigint Delisted_Share_Quantity
        decimal Delisted_Share_Value
        bigint New_Listed_Share_Quantity
        bigint Additional_Listed_Share_Quantity
        decimal Listed_Share_Value
        decimal Additional_Listed_Share_Value
        string Exchange_Transfer
        string Delist_Transfer_Reason
        string Listing_Floor_Code
        string Source_System_Code
    }
    Fact_Government_Bond_Listing_Snapshot {
        string Government_Bond_Listing_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Bond_Code
        int Report_Year
        int Report_Month
        bigint Listed_Bond_Quantity
        decimal Listed_Bond_Value
    }
    Fact_Government_Bond_Listing_Change_Snapshot {
        string Government_Bond_Listing_Change_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Bond_Code
        string Listing_Status_Name
        bigint Additional_Bond_Quantity
    }
    Fact_Private_Corporate_Bond_Registration_Snapshot {
        string Private_Corporate_Bond_Registration_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Bond_Code
        string Report_Year
        string Report_Month
        date Maturity_Date
        bigint Registered_Trading_Bond_Quantity
        bigint Par_Value
        decimal Registered_Trading_Value
    }
    Fact_Private_Corporate_Bond_Registration_Status_Snapshot {
        string Private_Corporate_Bond_Registration_Status_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Bond_Code
        string Trading_Registration_Status_Name
        bigint Registered_Trading_Bond_Quantity
    }
    Calendar_Date_Dimension ||--o{ Fact_Listed_Equity_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Listing_Status_Change_Snapshot : " "
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Listing_Status_Change_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Government_Bond_Listing_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Government_Bond_Listing_Change_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Private_Corporate_Bond_Registration_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Private_Corporate_Bond_Registration_Status_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Security_Trading_Snapshot_Dimension["Security Trading Snapshot Dimension"]
        Fact_Listed_Equity_Snapshot["Fact Listed Equity Snapshot"]
        Fact_Listing_Status_Change_Snapshot["Fact Listing Status Change Snapshot"]
        Fact_Government_Bond_Listing_Snapshot["Fact Government Bond Listing Snapshot"]
        Fact_Government_Bond_Listing_Change_Snapshot["Fact Government Bond Listing Change Snapshot"]
        Fact_Private_Corporate_Bond_Registration_Snapshot["Fact Private Corporate Bond Registration Snapshot"]
        Fact_Private_Corporate_Bond_Registration_Status_Snapshot["Fact Private Corporate Bond Registration Status Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 17"]
        R1["K_VP_1,375,376,377,378,379,380,381,382,383,384,385,386,387,388,389: Niêm yết >> Chỉ tiêu tổng hợp"]
    end
    Calendar_Date_Dimension --> R1
    Security_Trading_Snapshot_Dimension --> R1
    Fact_Listed_Equity_Snapshot --> R1
    Fact_Listing_Status_Change_Snapshot --> R1
    Fact_Government_Bond_Listing_Snapshot --> R1
    Fact_Government_Bond_Listing_Change_Snapshot --> R1
    Fact_Private_Corporate_Bond_Registration_Snapshot --> R1
    Fact_Private_Corporate_Bond_Registration_Status_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Listed Equity Snapshot | 1 mã chứng khoán niêm yết/đăng ký giao dịch (cổ phiếu, chứng chỉ quỹ/ETF, chứng quyền, TPDN niêm yết — stock_tp_code 1/2/3/4/6, không gồm phái sinh) × 1 ngày giao dịch (bản tin cuối ngày MDDS JAD_STOCKINFOR); PK Listed Equity Snapshot Id = hash (Snapshot Date Dimension Id, Ticker Symbol, Source System Code) (Dạng B, A22) |
| Security Trading Snapshot Dimension | 1 mã chứng khoán / hợp đồng phái sinh (SCD4A current-state); sở hữu bởi GSTT |
| Fact Listing Status Change Snapshot | 1 quyết định thay đổi niêm yết × 1 mã × 1 Sở (HNX gồm UPCoM, HOSE); PK Listing Status Change Snapshot Id = id dòng Atomic `listing_status_change`; kỳ theo ngày hiệu lực (Effective Date) |
| Fact Government Bond Listing Snapshot | 1 mã trái phiếu Chính phủ niêm yết × 1 tháng báo cáo (Report Year, Report Month; Atomic `gov_bond_listing` ← HNX.GOV_BOND_LISTED_LIST); PK Government Bond Listing Snapshot Id = hash (Bond Code, Report Year, Report Month, Source System Code) (Dạng B, A22); khóa ngày = ngày cuối tháng báo cáo |
| Fact Private Corporate Bond Registration Snapshot | 1 mã trái phiếu (Bond Code) × 1 tháng báo cáo (Report Year, Report Month); PK Private Corporate Bond Registration Snapshot Id = hash (Bond Code, Report Year, Report Month) (Dạng B, A22) |
| Fact Government Bond Listing Change Snapshot | 1 sự kiện thay đổi niêm yết của 1 mã trái phiếu Chính phủ (niêm yết mới / niêm yết bổ sung / đáo hạn) trong danh sách bổ sung HNX; PK Government Bond Listing Change Snapshot Id = id dòng Atomic `additional_gov_bond_listing_id` (Dạng A, A22) |
| Fact Private Corporate Bond Registration Status Snapshot | 1 mã trái phiếu doanh nghiệp riêng lẻ × 1 trạng thái đăng ký giao dịch (Đăng ký giao dịch / Hủy đăng ký giao dịch) × 1 tháng báo cáo HNX, số liệu lũy kế từ đầu năm; PK Private Corporate Bond Registration Status Snapshot Id = id dòng Atomic `bond_trading_registration_status_id` (Dạng A, A22) |

#### Nhóm 18 - Biểu đồ Khối lượng chứng khoán niêm yết

> Phân loại: **Phân tích**
> Atomic: tái dùng 3 Fact VP — `Fact Listed Equity Snapshot` (MDDS.JAD_STOCKINFOR: cổ phiếu, CCQ, ETF, chứng quyền, TPDN niêm yết), `Fact Government Bond Listing Snapshot` (HNX.GOV_BOND_LISTED_LIST: TPCP) và `Fact Private Corporate Bond Registration Snapshot` (HNX.PRIVATE_CORP_BOND_REGISTRATION: TPDN riêng lẻ) — **READY**; mở rộng Fact (loại chứng quyền/TPDN niêm yết, cột `Fund Type Code`, KL đăng ký giao dịch TPDN riêng lẻ) phụ thuộc dev ETL + ALTER + nạp lại lịch sử (O_VP_68)

> **[GHI CHÚ 2026-11-08 — BA VP mapping Nhóm 18]** BA Nhóm 18 gồm 13 dòng (194–206: 3 Chiều — Kỳ, Loại chứng khoán, Sàn; 10 chỉ tiêu cơ sở — KL niêm yết/ĐKGD tổng và theo từng loại: cổ phiếu HOSE/HNX/UPCOM, TPDN niêm yết, TPDN riêng lẻ, TPCP, CCQ, ETF, chứng quyền; 1 'TB' + 12 'Trùng'). 12 dòng 'Trùng' KHÔNG nêu trùng với chỉ tiêu nào (cùng định nghĩa KL niêm yết/ĐKGD của Nhóm 17 nhưng là chuỗi kỳ Từ kỳ — Đến kỳ) → thiết kế đủ 12 KPI mới (K_VP_348–359) và reuse K_VP_1; Δ số lượng BA ↔ HLD ở Gate 10 là CÓ CHỦ Ý. KL niêm yết đọc `Listed Share Quantity` (MDDS `listedshare`), TPCP đọc `Listed Bond Quantity`, TPDN riêng lẻ đọc `Registered Trading Bond Quantity`. Giả định/lệch BA (kỳ Ngày có trong Mô tả nhưng SQL chỉ M/Q/Y, cổ phiếu mới chia theo sàn, TPDN riêng lẻ không lọc ngày đáo hạn) ghi ở O_VP_69.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (Tháng / Quý / Năm) · Từ kỳ · Đến kỳ

| Kỳ | Loại chứng khoán | Sàn | KL niêm yết/ĐKGD |
|---|---|---|---|
| (từng kỳ trong khoảng) | Cổ phiếu | HOSE / HNX / UPCOM | … |
| | Chứng chỉ quỹ, ETF, Chứng quyền, TPDN niêm yết, TPDN riêng lẻ, TPCP | — | … |

> ⚠️ Presentation Grain: 1 dòng = 1 Loại chứng khoán (cổ phiếu tách thêm theo Sàn) × 1 kỳ trong [Từ kỳ, Đến kỳ]. Storage Grain: 1 mã chứng khoán × 1 ngày giao dịch (`Fact Listed Equity Snapshot`), 1 mã TPCP × 1 tháng báo cáo, 1 mã TPDN riêng lẻ × 1 tháng báo cáo — xem Bảng grain.

**Source:** `Fact Listed Equity Snapshot`, `Fact Government Bond Listing Snapshot`, `Fact Private Corporate Bond Registration Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date từ ngày đầu Từ kỳ đến ngày cuối Đến kỳ, nhóm theo loại kỳ (M/Q/Y) | Reuse K_VP_1 (Nhóm 1, 7, 15, 16, 19, 21) — Case 1; BA dòng 194 'Trùng' — Từ kỳ — Đến kỳ; Mô tả có kỳ Ngày nhưng SQL chỉ M/Q/Y — O_VP_69 | READY |
| K_VP_348 | Loại chứng khoán | — | Chiều | Cổ phiếu / CCQ / ETF / Chứng quyền / TPDN niêm yết từ Stock Type Code + Fund Type Code của Fact Listed Equity Snapshot; TPCP và TPDN riêng lẻ theo Fact Government Bond Listing / Private Corporate Bond Registration | Case 1 — BA dòng 195 'Trùng' không nêu chỉ tiêu trùng; loại 1/4 và cột Fund Type Code là phần mở rộng Fact (O_VP_68) | READY |
| K_VP_349 | Sàn | — | Chiều | Floor Code trên Fact Listed Equity Snapshot, chỉ với Stock Type Code = '2' (cổ phiếu): 10 = HOSE, 02 = HNX, 04 = UPCOM | Case 1 — BA dòng 196 'TB' (chỉ thống kê theo sàn đối với cổ phiếu); cùng cách K_VP_239/342 nhưng giới hạn cổ phiếu | READY |
| K_VP_350 | Khối lượng niêm yết/ĐKGD | Cổ phiếu/CCQ/trái phiếu | Cơ sở | Hợp theo Loại chứng khoán: SUM(Listed Share Quantity) tại ngày giao dịch cuối mỗi kỳ + SUM(Listed Bond Quantity) và SUM(Registered Trading Bond Quantity) tại tháng báo cáo mới nhất trong kỳ | Case 2 — hợp 3 Fact ở presentation layer; BA dòng 197 'Trùng' (Chỉ tiêu cơ sở nhưng đọc 3 nguồn) | READY |
| K_VP_351 | Khối lượng niêm yết/ĐKGD - Cổ phiếu - HOSE | Cổ phiếu | Cơ sở | SUM(Listed Share Quantity) trên Fact Listed Equity Snapshot với Stock Type Code = '2', Floor Code = '10' tại ngày giao dịch cuối mỗi kỳ | Case 1 — BA dòng 198 'Trùng' | READY |
| K_VP_352 | Khối lượng niêm yết/ĐKGD - Cổ phiếu - HNX | Cổ phiếu | Cơ sở | SUM(Listed Share Quantity) trên Fact Listed Equity Snapshot với Stock Type Code = '2', Floor Code = '02' tại ngày giao dịch cuối mỗi kỳ | Case 1 — BA dòng 199 'Trùng' | READY |
| K_VP_353 | Khối lượng niêm yết/ĐKGD - Cổ phiếu - UPCOM | Cổ phiếu | Cơ sở | SUM(Listed Share Quantity) trên Fact Listed Equity Snapshot với Stock Type Code = '2', Floor Code = '04' tại ngày giao dịch cuối mỗi kỳ | Case 1 — BA dòng 200 'Trùng' | READY |
| K_VP_354 | Khối lượng niêm yết/ĐKGD - TPDN niêm yết | Trái phiếu | Cơ sở | SUM(Listed Share Quantity) trên Fact Listed Equity Snapshot với Stock Type Code = '1' (TPDN niêm yết) tại ngày giao dịch cuối mỗi kỳ | Case 1 — BA dòng 201 'Trùng'; loại 1 là phần mở rộng Fact (O_VP_68) | READY |
| K_VP_355 | Khối lượng niêm yết/ĐKGD - TPDN riêng lẻ | Trái phiếu | Cơ sở | SUM(Registered Trading Bond Quantity) trên Fact Private Corporate Bond Registration Snapshot tại tháng báo cáo mới nhất trong kỳ | Case 1 — BA dòng 202 'Trùng'; cột Registered Trading Bond Quantity mới (O_VP_68); không lọc ngày đáo hạn (khác K_VP_100) | READY |
| K_VP_356 | Khối lượng niêm yết/ĐKGD - TPCP | Trái phiếu | Cơ sở | SUM(Listed Bond Quantity) trên Fact Government Bond Listing Snapshot tại tháng báo cáo mới nhất trong kỳ | Case 1 — BA dòng 203 'Trùng'; cùng cách K_VP_271 (Nhóm 30), khóa Atomic O_VP_62 | READY |
| K_VP_357 | Khối lượng niêm yết/ĐKGD - Chứng chỉ quỹ | Chứng chỉ quỹ | Cơ sở | SUM(Listed Share Quantity) trên Fact Listed Equity Snapshot với Stock Type Code ∈ (3, 6), Fund Type Code = 'M' tại ngày giao dịch cuối mỗi kỳ | Case 1 — BA dòng 204 'Trùng'; cột Fund Type Code mới (O_VP_68) | READY |
| K_VP_358 | Khối lượng niêm yết/ĐKGD - ETF | Chứng chỉ quỹ | Cơ sở | SUM(Listed Share Quantity) trên Fact Listed Equity Snapshot với Stock Type Code ∈ (3, 6), Fund Type Code = 'E' tại ngày giao dịch cuối mỗi kỳ | Case 1 — BA dòng 205 'Trùng' | READY |
| K_VP_359 | Khối lượng niêm yết/ĐKGD - Chứng quyền | Chứng quyền | Cơ sở | SUM(Listed Share Quantity) trên Fact Listed Equity Snapshot với Stock Type Code = '4' (chứng quyền) tại ngày giao dịch cuối mỗi kỳ | Case 1 — BA dòng 206 'Trùng'; loại 4 là phần mở rộng Fact (O_VP_68) | READY |

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
    Fact_Listed_Equity_Snapshot {
        string Listed_Equity_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Industry_Dimension_Id FK
        string Ticker_Symbol
        string Floor_Code
        string Stock_Type_Code
        string Fund_Type_Code
        bigint Outstanding_Share_Quantity
        bigint Listed_Share_Quantity
        decimal Listed_Share_Value
        decimal Close_Price
        decimal Reference_Price
        bigint Next_Day_Volume_Weighted_Average_Price
        decimal Market_Price
        decimal Market_Cap_Value
        string Source_System_Code
    }
    Fact_Government_Bond_Listing_Snapshot {
        string Government_Bond_Listing_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Bond_Code
        int Report_Year
        int Report_Month
        bigint Listed_Bond_Quantity
        decimal Listed_Bond_Value
    }
    Fact_Private_Corporate_Bond_Registration_Snapshot {
        string Private_Corporate_Bond_Registration_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Bond_Code
        string Report_Year
        string Report_Month
        date Maturity_Date
        bigint Registered_Trading_Bond_Quantity
        bigint Par_Value
        decimal Registered_Trading_Value
    }
    Calendar_Date_Dimension ||--o{ Fact_Listed_Equity_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Government_Bond_Listing_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Private_Corporate_Bond_Registration_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Listed_Equity_Snapshot["Fact Listed Equity Snapshot"]
        Fact_Government_Bond_Listing_Snapshot["Fact Government Bond Listing Snapshot"]
        Fact_Private_Corporate_Bond_Registration_Snapshot["Fact Private Corporate Bond Registration Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 18"]
        R1["K_VP_1,348,349,350,351,352,353,354,355,356,357,358,359: Niêm yết >> Biểu đồ Khối lượng chứng khoán niêm yết"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Listed_Equity_Snapshot --> R1
    Fact_Government_Bond_Listing_Snapshot --> R1
    Fact_Private_Corporate_Bond_Registration_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Listed Equity Snapshot | 1 mã chứng khoán niêm yết/đăng ký giao dịch (cổ phiếu, chứng chỉ quỹ/ETF, chứng quyền, TPDN niêm yết — stock_tp_code 1/2/3/4/6, không gồm phái sinh) × 1 ngày giao dịch (bản tin cuối ngày MDDS JAD_STOCKINFOR); PK Listed Equity Snapshot Id = hash (Snapshot Date Dimension Id, Ticker Symbol, Source System Code) (Dạng B, A22) |
| Fact Government Bond Listing Snapshot | 1 mã trái phiếu Chính phủ niêm yết × 1 tháng báo cáo (Report Year, Report Month; Atomic `gov_bond_listing` ← HNX.GOV_BOND_LISTED_LIST); PK Government Bond Listing Snapshot Id = hash (Bond Code, Report Year, Report Month, Source System Code) (Dạng B, A22); khóa ngày = ngày cuối tháng báo cáo |
| Fact Private Corporate Bond Registration Snapshot | 1 mã trái phiếu (Bond Code) × 1 tháng báo cáo (Report Year, Report Month); PK Private Corporate Bond Registration Snapshot Id = hash (Bond Code, Report Year, Report Month) (Dạng B, A22) |

#### Nhóm 19 - Chỉ tiêu tổng hợp - Vốn hóa cổ phiếu

> Phân loại: **Phân tích**
> Atomic: tái dùng `Fact Listed Equity Snapshot` (VP; MDDS.JAD_STOCKINFOR bản tin cuối ngày + VSDC.OUTSTANDING_SHARES) cho vốn hóa và `Fact Macro Indicator Snapshot` (PTTT; MRMS.RISK_INDICATOR_VALUE, GDP_VN kèm Unit Type Code; dùng lại Fact PTTT vì cùng grain, O_VP_41) cho GDP năm — **READY**; phụ thuộc dev PTTT bổ sung PK macro_indicator_val_id và unit_tp_code vào model + flat PTTT (O_VP_41, O_PTTT_57)

**[GHI CHÚ 2026-11-02 — BA VP mapping Nhóm 19]** BA Nhóm 19 gồm 17 dòng (2 Chiều: Kỳ — dòng mới 255, Sàn; 4 'TB' + 13 'Trùng'); dòng 259 cũ 'Tỷ lệ Vốn hóa/GDP' đã được BA thay bằng 3 dòng 260–262. Cả 13 dòng 'Trùng' (258, 259, 261–271) KHÔNG nêu trùng với chỉ tiêu nào (K_VP_172–175 của Nhóm 55 chỉ trùng ý nghĩa, khác tham số kỳ và chiều Sàn) → thiết kế đủ 16 KPI mới (K_VP_239–254) và reuse K_VP_1; Δ số lượng BA ↔ HLD ở Gate 10 là CÓ CHỦ Ý. Vốn hóa đọc `Fact Listed Equity Snapshot` (K_VP_172, O_VP_40), GDP đọc `Fact Macro Indicator Snapshot` (K_VP_174, O_VP_41). Mâu thuẫn/lỗi BA (mẫu số dòng 258, thiếu ×100 ở dòng 261–262, lỗi cú pháp SQL, tên sàn trong Điều kiện, GDP cố định ds_snpst_dt) ghi ở O_VP_48.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (Ngày / Tháng / Quý / Năm) · Kỳ báo cáo

| Sàn | Vốn hóa | % so với kỳ trước | % so với cuối năm trước | Tỷ lệ Vốn hóa/GDP (%) | So với kỳ trước (điểm %) | So với cuối năm trước (điểm %) |
|---|---|---|---|---|---|---|
| Tổng | … | … | … | … | … | … |
| HOSE | … | … | … | — | — | — |
| HNX | … | … | … | — | — | — |
| UPCOM | … | … | … | — | — | — |

> ⚠️ Presentation Grain: 1 dòng = 1 Sàn (HOSE / HNX / UPCOM / Tổng) tại 1 kỳ báo cáo (vốn hóa tính tại ngày giao dịch gần nhất ≤ ngày cuối kỳ); tỷ lệ Vốn hóa/GDP chỉ dòng Tổng. Storage Grain: 1 mã cổ phiếu × 1 ngày giao dịch (`Fact Listed Equity Snapshot`) và 1 chỉ tiêu vĩ mô × 1 kỳ công bố (`Fact Macro Indicator Snapshot`) — xem Bảng grain.

**Source:** `Fact Listed Equity Snapshot`, `Fact Macro Indicator Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date trong kỳ (D/M/Q/Y) từ ngày đầu kỳ đến ngày cuối kỳ | Reuse K_VP_1 (Nhóm 1, 7) — Case 1; BA dòng 255 (mới) — 1 kỳ duy nhất, loại kỳ D/M/Q/Y | READY |
| K_VP_239 | Sàn | — | Chiều | Floor Code trên Fact Listed Equity Snapshot: 10 = HOSE, 02 = HNX, 04 = UPCOM; dòng 'Tổng' = không lọc sàn (ROLLUP) | Case 1 — Floor Code lưu trên Fact (như K_VP_172); BA dòng 256 — O_VP_48 | READY |
| K_VP_240 | Tổng vốn hóa thị trường cổ phiếu | VND | Cơ sở | SUM(Market Cap Value) trên Fact Listed Equity Snapshot với Stock Type Code = '2' (cổ phiếu), Floor Code ∈ (02, 04, 10) tại :d_cur (ngày giao dịch gần nhất <= ngày cuối kỳ) | Case 1 — measure Market Cap Value (UPCoM: VWAP T+1, O_VP_40); BA dòng 257 | READY |
| K_VP_241 | Tổng vốn hóa thị trường cổ phiếu - So với kỳ trước (%) | % | Phái sinh | (Σ Market Cap Value tại :d_cur − Σ tại :d_prev) / Σ tại :d_prev × 100, cổ phiếu, 3 sàn | Case 2 — từ K_VP_240 tại 2 mốc ngày; mẫu số theo SQL/tên dòng (kỳ trước), Mô tả BA ghi 'cuối năm trước' — O_VP_48 | READY |
| K_VP_242 | Tổng vốn hóa thị trường cổ phiếu - So với cuối năm trước (%) | % | Phái sinh | (Σ Market Cap Value tại :d_cur − Σ tại :d_py) / Σ tại :d_py × 100, cổ phiếu, 3 sàn | Case 2 — từ K_VP_240; cùng công thức K_VP_173 nhưng mốc theo kỳ báo cáo; BA dòng 259 — O_VP_48 | READY |
| K_VP_243 | Tỷ lệ Vốn hóa/GDP (%) | % | Phái sinh | Σ Market Cap Value tại :d_cur / GDP năm (năm của ngày cuối kỳ − 1, VND) × 100; chỉ dòng 'Tổng' | Case 2 — từ K_VP_240 và K_VP_174; BA dòng 260 — O_VP_41, O_VP_48 | READY |
| K_VP_244 | Tỷ lệ Vốn hóa/GDP (%) - So với kỳ trước (điểm %) | điểm % | Phái sinh | Tỷ lệ Vốn hóa/GDP tại :d_cur − Tỷ lệ tại :d_prev (mỗi tỷ lệ = Σ Market Cap Value / GDP năm tương ứng × 100) | Case 2 — hiệu hai tỷ lệ K_VP_243; SQL BA thiếu ×100 — O_VP_48 | READY |
| K_VP_245 | Tỷ lệ Vốn hóa/GDP (%) - So với cuối năm trước (điểm %) | điểm % | Phái sinh | Tỷ lệ Vốn hóa/GDP tại :d_cur − Tỷ lệ tại :d_py (GDP năm tương ứng, × 100) | Case 2 — hiệu hai tỷ lệ K_VP_243; SQL BA thiếu ×100 — O_VP_48 | READY |
| K_VP_246 | Vốn hóa HOSE | VND | Cơ sở | SUM(Market Cap Value) trên Fact Listed Equity Snapshot với Stock Type Code = '2', Floor Code = '10' (HOSE) tại :d_cur | Case 1 — K_VP_240 lọc sàn HOSE; BA dòng 263 'Trùng' | READY |
| K_VP_247 | Vốn hóa HOSE - So với kỳ trước (%) | % | Phái sinh | (Σ Market Cap Value sàn HOSE tại :d_cur − Σ tại :d_prev) / Σ tại :d_prev × 100 | Case 2 — từ K_VP_246; BA dòng 264 'Trùng' | READY |
| K_VP_248 | Vốn hóa HOSE - So với cuối năm trước (%) | % | Phái sinh | (Σ Market Cap Value sàn HOSE tại :d_cur − Σ tại :d_py) / Σ tại :d_py × 100 | Case 2 — từ K_VP_246; BA dòng 265 'Trùng' — O_VP_48 | READY |
| K_VP_249 | Vốn hóa HNX | VND | Cơ sở | SUM(Market Cap Value) trên Fact Listed Equity Snapshot với Stock Type Code = '2', Floor Code = '02' (HNX) tại :d_cur | Case 1 — K_VP_240 lọc sàn HNX; BA dòng 266 'Trùng' | READY |
| K_VP_250 | Vốn hóa HNX - So với kỳ trước (%) | % | Phái sinh | (Σ Market Cap Value sàn HNX tại :d_cur − Σ tại :d_prev) / Σ tại :d_prev × 100 | Case 2 — từ K_VP_249; BA dòng 267 'Trùng' | READY |
| K_VP_251 | Vốn hóa HNX - So với cuối năm trước (%) | % | Phái sinh | (Σ Market Cap Value sàn HNX tại :d_cur − Σ tại :d_py) / Σ tại :d_py × 100 | Case 2 — từ K_VP_249; BA dòng 268 'Trùng' — O_VP_48 | READY |
| K_VP_252 | Vốn hóa UPCOM | VND | Cơ sở | SUM(Market Cap Value) trên Fact Listed Equity Snapshot với Stock Type Code = '2', Floor Code = '04' (UPCOM) tại :d_cur | Case 1 — K_VP_240 lọc sàn UPCOM; BA dòng 269 'Trùng' — UPCoM VWAP T+1, O_VP_40 | READY |
| K_VP_253 | Vốn hóa UPCOM - So với kỳ trước (%) | % | Phái sinh | (Σ Market Cap Value sàn UPCOM tại :d_cur − Σ tại :d_prev) / Σ tại :d_prev × 100 | Case 2 — từ K_VP_252; BA dòng 270 'Trùng' | READY |
| K_VP_254 | Vốn hóa UPCOM - So với cuối năm trước (%) | % | Phái sinh | (Σ Market Cap Value sàn UPCOM tại :d_cur − Σ tại :d_py) / Σ tại :d_py × 100 | Case 2 — từ K_VP_252; BA dòng 271 'Trùng' — O_VP_48 | READY |

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
    Fact_Listed_Equity_Snapshot {
        string Listed_Equity_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Industry_Dimension_Id FK
        string Ticker_Symbol
        string Floor_Code
        string Stock_Type_Code
        string Fund_Type_Code
        bigint Outstanding_Share_Quantity
        bigint Listed_Share_Quantity
        decimal Listed_Share_Value
        decimal Close_Price
        decimal Reference_Price
        bigint Next_Day_Volume_Weighted_Average_Price
        decimal Market_Price
        decimal Market_Cap_Value
        string Source_System_Code
    }
    Fact_Macro_Indicator_Snapshot {
        string Macro_Indicator_Value_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Macro_Indicator_Code
        string Macro_Indicator_Name
        string Period_Type_Code
        string Period_Label
        decimal Indicator_Val
        string Unit_Type_Code
        decimal Prev_Period_Val
        decimal Pct_Change
        decimal Yoy_Pct_Change
        decimal Ma_N_Val
        string Source_System_Code
    }
    Calendar_Date_Dimension ||--o{ Fact_Listed_Equity_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Macro_Indicator_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Listed_Equity_Snapshot["Fact Listed Equity Snapshot"]
        Fact_Macro_Indicator_Snapshot["Fact Macro Indicator Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 19"]
        R1["K_VP_1,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254: Vốn hóa thị trường >> Chỉ tiêu tổng hợp - Vốn hóa cổ phiếu"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Listed_Equity_Snapshot --> R1
    Fact_Macro_Indicator_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Listed Equity Snapshot | 1 mã chứng khoán niêm yết/đăng ký giao dịch (cổ phiếu, chứng chỉ quỹ/ETF, chứng quyền, TPDN niêm yết — stock_tp_code 1/2/3/4/6, không gồm phái sinh) × 1 ngày giao dịch (bản tin cuối ngày MDDS JAD_STOCKINFOR); PK Listed Equity Snapshot Id = hash (Snapshot Date Dimension Id, Ticker Symbol, Source System Code) (Dạng B, A22) |
| Fact Macro Indicator Snapshot | 1 chỉ tiêu vĩ mô × 1 kỳ công bố (PK Macro Indicator Value Id = id dòng Atomic `cl_risk_indicator_value`, Dạng A, A22); PTTT sở hữu, VP dùng lại (O_VP_41) |

#### Nhóm 20 - Chỉ tiêu tổng hợp - Giá trị niêm yết trái phiếu

> Phân loại: **Phân tích**
> Atomic: tái dùng `Fact Listed Equity Snapshot` (MDDS.JAD_STOCKINFOR: TPDN niêm yết, Stock Type Code = '1'), `Fact Government Bond Listing Snapshot` (HNX.GOV_BOND_LISTED_LIST: TPCP), `Fact Private Corporate Bond Registration Snapshot` (HNX.PRIVATE_CORP_BOND_REGISTRATION: TPDN riêng lẻ) và `Fact Macro Indicator Snapshot` (PTTT; MRMS GDP_VN, O_VP_41) — **READY**; mở rộng Fact (loại TPDN niêm yết, KL/mệnh giá/giá trị đăng ký giao dịch TPDN riêng lẻ) phụ thuộc dev ETL + ALTER + nạp lại lịch sử (O_VP_68); GDP phụ thuộc dev PTTT bổ sung PK + unit_tp_code (O_VP_41, O_PTTT_57)

> **[GHI CHÚ 2026-11-08 — BA VP mapping Nhóm 20]** BA Nhóm 20 gồm 16 dòng (224–239: 2 Chiều — Kỳ, Loại chứng khoán; Tổng GT niêm yết TP + 2 dòng so sánh; GDP; Quy mô TP/GDP; GT niêm yết theo từng loại TPDN niêm yết / TPDN riêng lẻ / TPCP × (giá trị + so với kỳ trước + so với năm trước); 6 'TB' + 10 'Trùng'). 10 dòng 'Trùng' (225, 231–239) KHÔNG nêu trùng với chỉ tiêu nào → thiết kế đủ 15 KPI mới (K_VP_360–374) và reuse K_VP_1; Δ số lượng BA ↔ HLD ở Gate 10 là CÓ CHỦ Ý. GT niêm yết đọc `Listed Share Value` (TPDN niêm yết), `Listed Bond Value` (TPCP), `Registered Trading Value` (TPDN riêng lẻ); GDP đọc `Fact Macro Indicator Snapshot` (cùng K_VP_174, O_VP_41). Mâu thuẫn/lỗi BA (mẫu số 'cuối năm trước' của dòng so sánh kỳ trước, SQL không có nhánh so với năm trước, CTE TPDNNY lọc stocktype = '2', GDP cố định ds_snpst_dt, cột output chưa có dòng BA) ghi ở O_VP_70.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (Ngày / Tháng / Quý / Năm) · Kỳ báo cáo

| Loại chứng khoán | Giá trị niêm yết | So với kỳ trước (%) | So với năm trước (%) | Quy mô TP/GDP (%) |
|---|---|---|---|---|
| Tổng | … | … | … | … |
| TPCP | … | … | … | — |
| TPDN niêm yết | … | … | … | — |
| TPDN riêng lẻ | … | … | … | — |

> ⚠️ Presentation Grain: 1 dòng = 1 Loại chứng khoán (TPCP / TPDN niêm yết / TPDN riêng lẻ / Tổng) tại 1 kỳ báo cáo; Quy mô TP/GDP chỉ dòng Tổng. Storage Grain: 1 mã chứng khoán × 1 ngày giao dịch (`Fact Listed Equity Snapshot`), 1 mã TPCP / TPDN riêng lẻ × 1 tháng báo cáo, 1 chỉ tiêu vĩ mô × 1 kỳ công bố — xem Bảng grain.

**Source:** `Fact Listed Equity Snapshot`, `Fact Government Bond Listing Snapshot`, `Fact Private Corporate Bond Registration Snapshot`, `Fact Macro Indicator Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date trong kỳ (D/M/Q/Y) từ ngày đầu kỳ đến ngày cuối kỳ | Reuse K_VP_1 (Nhóm 1, 7, 19, 22) — Case 1; BA dòng 224 — 1 kỳ duy nhất, loại kỳ D/M/Q/Y; TPCP/TPDN riêng lẻ lấy tháng báo cáo của kỳ | READY |
| K_VP_360 | Loại chứng khoán | — | Chiều | TPDN niêm yết (Stock Type Code = '1' của Fact Listed Equity Snapshot) / TPCP (Fact Government Bond Listing) / TPDN riêng lẻ (Fact Private Corporate Bond Registration) / dòng Tổng (ROLLUP) | Case 1 — BA dòng 225 'Trùng' không nêu chỉ tiêu trùng; loại 1 là phần mở rộng Fact (O_VP_68) | READY |
| K_VP_361 | Tổng giá trị niêm yết TP | VND | Cơ sở | SUM(Listed Share Value) của TPDN niêm yết + SUM(Listed Bond Value) của TPCP + SUM(Registered Trading Value) của TPDN riêng lẻ tại ngày cuối kỳ | Case 2 — hợp 3 Fact ở presentation layer; BA dòng 226 'TB' (Chỉ tiêu cơ sở nhưng đọc 3 nguồn); SQL BA lọc stocktype = '2' trong CTE TPDNNY — theo Điều kiện stocktype = '1', O_VP_70 | READY |
| K_VP_362 | Tổng giá trị niêm yết TP - So sánh với kỳ trước (%) | % | Phái sinh | (K_VP_361 kỳ này − K_VP_361 kỳ trước) / K_VP_361 kỳ trước × 100 | Case 2 — từ K_VP_361 tại 2 mốc; Mô tả BA ghi mẫu số 'cuối năm trước', tên dòng và SQL dùng kỳ trước — O_VP_70 | READY |
| K_VP_363 | Tổng giá trị niêm yết TP - So sánh với năm trước (%) | % | Phái sinh | (K_VP_361 kỳ này − K_VP_361 cuối năm trước) / K_VP_361 cuối năm trước × 100 | Case 2 — từ K_VP_361; SQL BA không có nhánh này — O_VP_70 | READY |
| K_VP_364 | GDP | VND | Phái sinh | GDP danh nghĩa năm (năm của ngày cuối kỳ − 1) trên Fact Macro Indicator Snapshot, ưu tiên kỳ Năm hơn Quý (đủ 4 quý), quy đổi VND theo Unit Type Code | Case 1 — cùng logic K_VP_174 (Nhóm 55); BA dòng 229 'TB'; O_VP_41, O_VP_70 | READY |
| K_VP_365 | Quy mô thị trường TP/GDP | % | Cơ sở | K_VP_361 / K_VP_364 × 100; chỉ dòng 'Tổng' | Case 2 — từ K_VP_361 và K_VP_364; BA dòng 230; cột gt_ny_gdp_kytruoc/gt_ny_gdp_chenhlech của SQL BA chưa có dòng BA — O_VP_70 | READY |
| K_VP_366 | Giá trị niêm yết - TPDN niêm yết | VND | Cơ sở | SUM(Listed Share Value) trên Fact Listed Equity Snapshot với Stock Type Code = '1' tại ngày giao dịch gần nhất <= ngày cuối kỳ | Case 1 — BA dòng 231 'Trùng'; mệnh giá suy ngược từ giá tham chiếu; loại 1 mở rộng Fact (O_VP_68) | READY |
| K_VP_367 | Giá trị niêm yết - TPDN niêm yết - So sánh với kỳ trước (%) | % | Phái sinh | (K_VP_366 kỳ này − K_VP_366 kỳ trước) / K_VP_366 kỳ trước × 100 | Case 2 — BA dòng 232 'Trùng'; mẫu số kỳ trước (không phải cuối năm trước) — O_VP_70 | READY |
| K_VP_368 | Giá trị niêm yết - TPDN niêm yết - So sánh với năm trước (%) | % | Phái sinh | (K_VP_366 kỳ này − K_VP_366 cuối năm trước) / K_VP_366 cuối năm trước × 100 | Case 2 — BA dòng 233 'Trùng'; SQL BA không có nhánh này — O_VP_70 | READY |
| K_VP_369 | Giá trị niêm yết - TPDN riêng lẻ | VND | Cơ sở | SUM(Registered Trading Value) trên Fact Private Corporate Bond Registration Snapshot tại tháng báo cáo của kỳ | Case 1 — BA dòng 234 'Trùng'; cột Registered Trading Value mới (O_VP_68); không lọc ngày đáo hạn | READY |
| K_VP_370 | Giá trị niêm yết - TPDN riêng lẻ - So sánh với kỳ trước (%) | % | Phái sinh | (K_VP_369 kỳ này − K_VP_369 kỳ trước) / K_VP_369 kỳ trước × 100 | Case 2 — BA dòng 235 'Trùng' — O_VP_70 | READY |
| K_VP_371 | Giá trị niêm yết - TPDN riêng lẻ - So sánh với năm trước (%) | % | Phái sinh | (K_VP_369 kỳ này − K_VP_369 cuối năm trước) / K_VP_369 cuối năm trước × 100 | Case 2 — BA dòng 236 'Trùng' — O_VP_70 | READY |
| K_VP_372 | Giá trị niêm yết - TPCP | VND | Cơ sở | SUM(Listed Bond Value) trên Fact Government Bond Listing Snapshot tại tháng báo cáo của kỳ | Case 1 — BA dòng 237 'Trùng'; cùng K_VP_257 (Nhóm 49), khóa Atomic O_VP_62 | READY |
| K_VP_373 | Giá trị niêm yết - TPCP - So sánh với kỳ trước (%) | % | Phái sinh | (K_VP_372 kỳ này − K_VP_372 kỳ trước) / K_VP_372 kỳ trước × 100 | Case 2 — BA dòng 238 'Trùng' — O_VP_70 | READY |
| K_VP_374 | Giá trị niêm yết - TPCP - So sánh với năm trước (%) | % | Phái sinh | (K_VP_372 kỳ này − K_VP_372 cuối năm trước) / K_VP_372 cuối năm trước × 100 | Case 2 — BA dòng 239 'Trùng' — O_VP_70 | READY |

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
    Fact_Listed_Equity_Snapshot {
        string Listed_Equity_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Industry_Dimension_Id FK
        string Ticker_Symbol
        string Floor_Code
        string Stock_Type_Code
        string Fund_Type_Code
        bigint Outstanding_Share_Quantity
        bigint Listed_Share_Quantity
        decimal Listed_Share_Value
        decimal Close_Price
        decimal Reference_Price
        bigint Next_Day_Volume_Weighted_Average_Price
        decimal Market_Price
        decimal Market_Cap_Value
        string Source_System_Code
    }
    Fact_Government_Bond_Listing_Snapshot {
        string Government_Bond_Listing_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Bond_Code
        int Report_Year
        int Report_Month
        bigint Listed_Bond_Quantity
        decimal Listed_Bond_Value
    }
    Fact_Private_Corporate_Bond_Registration_Snapshot {
        string Private_Corporate_Bond_Registration_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Bond_Code
        string Report_Year
        string Report_Month
        date Maturity_Date
        bigint Registered_Trading_Bond_Quantity
        bigint Par_Value
        decimal Registered_Trading_Value
    }
    Fact_Macro_Indicator_Snapshot {
        string Macro_Indicator_Value_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Macro_Indicator_Code
        string Macro_Indicator_Name
        string Period_Type_Code
        string Period_Label
        decimal Indicator_Val
        string Unit_Type_Code
        decimal Prev_Period_Val
        decimal Pct_Change
        decimal Yoy_Pct_Change
        decimal Ma_N_Val
        string Source_System_Code
    }
    Calendar_Date_Dimension ||--o{ Fact_Listed_Equity_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Government_Bond_Listing_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Private_Corporate_Bond_Registration_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Macro_Indicator_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Listed_Equity_Snapshot["Fact Listed Equity Snapshot"]
        Fact_Government_Bond_Listing_Snapshot["Fact Government Bond Listing Snapshot"]
        Fact_Private_Corporate_Bond_Registration_Snapshot["Fact Private Corporate Bond Registration Snapshot"]
        Fact_Macro_Indicator_Snapshot["Fact Macro Indicator Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 20"]
        R1["K_VP_1,360,361,362,363,364,365,366,367,368,369,370,371,372,373,374: Vốn hóa thị trường >> Chỉ tiêu tổng hợp - Giá trị niêm yết trái phiếu"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Listed_Equity_Snapshot --> R1
    Fact_Government_Bond_Listing_Snapshot --> R1
    Fact_Private_Corporate_Bond_Registration_Snapshot --> R1
    Fact_Macro_Indicator_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Listed Equity Snapshot | 1 mã chứng khoán niêm yết/đăng ký giao dịch (cổ phiếu, chứng chỉ quỹ/ETF, chứng quyền, TPDN niêm yết — stock_tp_code 1/2/3/4/6, không gồm phái sinh) × 1 ngày giao dịch (bản tin cuối ngày MDDS JAD_STOCKINFOR); PK Listed Equity Snapshot Id = hash (Snapshot Date Dimension Id, Ticker Symbol, Source System Code) (Dạng B, A22) |
| Fact Government Bond Listing Snapshot | 1 mã trái phiếu Chính phủ niêm yết × 1 tháng báo cáo (Report Year, Report Month; Atomic `gov_bond_listing` ← HNX.GOV_BOND_LISTED_LIST); PK Government Bond Listing Snapshot Id = hash (Bond Code, Report Year, Report Month, Source System Code) (Dạng B, A22); khóa ngày = ngày cuối tháng báo cáo |
| Fact Private Corporate Bond Registration Snapshot | 1 mã trái phiếu (Bond Code) × 1 tháng báo cáo (Report Year, Report Month); PK Private Corporate Bond Registration Snapshot Id = hash (Bond Code, Report Year, Report Month) (Dạng B, A22) |
| Fact Macro Indicator Snapshot | 1 chỉ tiêu vĩ mô × 1 kỳ công bố (PK Macro Indicator Value Id = id dòng Atomic `cl_risk_indicator_value`, Dạng A, A22); PTTT sở hữu, VP dùng lại (O_VP_41) |

#### Nhóm 21 - Biểu đồ Giá trị vốn hóa thị trường cổ phiếu

> Phân loại: **Phân tích**
> Atomic: tái dùng `Fact Listed Equity Snapshot` (VP; MDDS.JAD_STOCKINFOR bản tin cuối ngày + VSDC.OUTSTANDING_SHARES, đã dùng cho Nhóm 19/22/55) cho vốn hóa và `Fact Macro Indicator Snapshot` (PTTT; MRMS.RISK_INDICATOR_VALUE, GDP_VN kèm Unit Type Code; dùng lại Fact PTTT vì cùng grain, O_VP_41) cho GDP năm — **READY**; phụ thuộc dev PTTT bổ sung PK macro_indicator_val_id và unit_tp_code vào model + flat PTTT (O_VP_41, O_PTTT_57)

> **[GHI CHÚ 2026-11-08 — BA VP mapping Nhóm 21]** BA Nhóm 21 gồm 7 dòng (240–246: 2 Chiều — Kỳ, Sàn; 5 chỉ tiêu cơ sở — Vốn hóa thị trường, HOSE, HNX, UPCOM, Tỷ lệ Vốn hóa/GDP; 1 'TB' + 6 'Trùng'). Cả 6 dòng 'Trùng' (241–246) KHÔNG nêu trùng với chỉ tiêu nào — cùng ý nghĩa Nhóm 19 (K_VP_239–254) nhưng Nhóm 21 là chuỗi kỳ Từ kỳ — Đến kỳ, mỗi kỳ chốt tại ngày giao dịch cuối kỳ và GDP theo năm của từng kỳ — nên thiết kế đủ 6 KPI mới (K_VP_342–347) và reuse K_VP_1; Δ số lượng BA ↔ HLD ở Gate 10 là CÓ CHỦ Ý. Vốn hóa đọc `Fact Listed Equity Snapshot` (K_VP_172, O_VP_40), GDP đọc `Fact Macro Indicator Snapshot` (K_VP_174, O_VP_41). Mâu thuẫn/lỗi BA (Mô tả UPCOM ghi giá đóng cửa trong khi Điều kiện/SQL dùng VWAP, tên sàn trong Điều kiện, tỷ lệ Vốn hóa/GDP SQL tính cho từng sàn còn Mô tả ghi 'Tổng vốn hóa', GDP cố định ds_snpst_dt, cột output gdp/gdp_year chưa có dòng BA) ghi ở O_VP_67.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (Ngày / Tháng / Quý / Năm) · Từ kỳ · Đến kỳ

| Kỳ | Sàn | Vốn hóa | Tỷ lệ Vốn hóa/GDP (%) |
|---|---|---|---|
| (từng kỳ trong khoảng) | HOSE | … | … |
| | HNX | … | … |
| | UPCOM | … | … |
| | Tổng | … | … |

> ⚠️ Presentation Grain: 1 dòng = 1 Sàn (HOSE / HNX / UPCOM / Tổng) × 1 kỳ trong [Từ kỳ, Đến kỳ] (vốn hóa tính tại ngày giao dịch gần nhất ≤ ngày cuối kỳ). Storage Grain: 1 mã cổ phiếu × 1 ngày giao dịch (`Fact Listed Equity Snapshot`) và 1 chỉ tiêu vĩ mô × 1 kỳ công bố (`Fact Macro Indicator Snapshot`) — xem Bảng grain.

**Source:** `Fact Listed Equity Snapshot`, `Fact Macro Indicator Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date từ ngày đầu Từ kỳ đến ngày cuối Đến kỳ, nhóm theo loại kỳ (D/M/Q/Y) | Reuse K_VP_1 (Nhóm 1, 7, 15, 16, 19) — Case 1; BA dòng 240 — Từ kỳ — Đến kỳ; vốn hóa chốt tại ngày giao dịch cuối mỗi kỳ (kỳ Ngày chỉ lấy ngày giao dịch) | READY |
| K_VP_342 | Sàn | — | Chiều | Floor Code trên Fact Listed Equity Snapshot: 10 = HOSE, 02 = HNX, 04 = UPCOM; dòng 'Tổng' = không lọc sàn (ROLLUP) | Case 1 — Floor Code lưu trên Fact, cùng cách K_VP_239 (Nhóm 19); BA dòng 241 'Trùng' không nêu chỉ tiêu trùng | READY |
| K_VP_343 | Vốn hóa thị trường | VND | Cơ sở | SUM(Market Cap Value) trên Fact Listed Equity Snapshot với Stock Type Code = '2' (cổ phiếu), Floor Code ∈ (02, 04, 10) tại ngày giao dịch cuối mỗi kỳ trong [Từ kỳ, Đến kỳ] | Case 1 — measure Market Cap Value (cùng K_VP_240 nhưng chuỗi kỳ; UPCoM: VWAP T+1, O_VP_40; phiên mới nhất UPCoM = NULL); BA dòng 242 'Trùng' | READY |
| K_VP_344 | Vốn hóa thị trường - HOSE | VND | Cơ sở | SUM(Market Cap Value) trên Fact Listed Equity Snapshot với Stock Type Code = '2', Floor Code = '10' (HOSE) tại ngày giao dịch cuối mỗi kỳ | Case 1 — K_VP_343 lọc sàn HOSE; BA dòng 243 'Trùng' | READY |
| K_VP_345 | Vốn hóa thị trường - HNX | VND | Cơ sở | SUM(Market Cap Value) trên Fact Listed Equity Snapshot với Stock Type Code = '2', Floor Code = '02' (HNX) tại ngày giao dịch cuối mỗi kỳ | Case 1 — K_VP_343 lọc sàn HNX; BA dòng 244 'Trùng' | READY |
| K_VP_346 | Vốn hóa thị trường - UPCOM | VND | Cơ sở | SUM(Market Cap Value) trên Fact Listed Equity Snapshot với Stock Type Code = '2', Floor Code = '04' (UPCOM) tại ngày giao dịch cuối mỗi kỳ | Case 1 — K_VP_343 lọc sàn UPCOM; BA dòng 245 'Trùng' — Mô tả ghi giá đóng cửa nhưng Điều kiện/SQL dùng VWAP T+1, O_VP_67, O_VP_40 | READY |
| K_VP_347 | Tỷ lệ Vốn hóa/GDP (%) | % | Phái sinh | Σ Market Cap Value tại ngày giao dịch cuối kỳ / GDP năm (năm của ngày cuối kỳ − 1, VND) × 100, theo từng Sàn và dòng Tổng | Case 2 — từ K_VP_343 và K_VP_174; BA dòng 246 'Trùng' (Chỉ tiêu cơ sở nhưng là tỷ số) — O_VP_41, O_VP_67 | READY |

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
    Fact_Listed_Equity_Snapshot {
        string Listed_Equity_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Industry_Dimension_Id FK
        string Ticker_Symbol
        string Floor_Code
        string Stock_Type_Code
        string Fund_Type_Code
        bigint Outstanding_Share_Quantity
        bigint Listed_Share_Quantity
        decimal Listed_Share_Value
        decimal Close_Price
        decimal Reference_Price
        bigint Next_Day_Volume_Weighted_Average_Price
        decimal Market_Price
        decimal Market_Cap_Value
        string Source_System_Code
    }
    Fact_Macro_Indicator_Snapshot {
        string Macro_Indicator_Value_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Macro_Indicator_Code
        string Macro_Indicator_Name
        string Period_Type_Code
        string Period_Label
        decimal Indicator_Val
        string Unit_Type_Code
        decimal Prev_Period_Val
        decimal Pct_Change
        decimal Yoy_Pct_Change
        decimal Ma_N_Val
        string Source_System_Code
    }
    Calendar_Date_Dimension ||--o{ Fact_Listed_Equity_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Macro_Indicator_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Listed_Equity_Snapshot["Fact Listed Equity Snapshot"]
        Fact_Macro_Indicator_Snapshot["Fact Macro Indicator Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 21"]
        R1["K_VP_1,342,343,344,345,346,347: Vốn hóa thị trường >> Biểu đồ Giá trị vốn hóa thị trường cổ phiếu"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Listed_Equity_Snapshot --> R1
    Fact_Macro_Indicator_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Listed Equity Snapshot | 1 mã chứng khoán niêm yết/đăng ký giao dịch (cổ phiếu, chứng chỉ quỹ/ETF, chứng quyền, TPDN niêm yết — stock_tp_code 1/2/3/4/6, không gồm phái sinh) × 1 ngày giao dịch (bản tin cuối ngày MDDS JAD_STOCKINFOR); PK Listed Equity Snapshot Id = hash (Snapshot Date Dimension Id, Ticker Symbol, Source System Code) (Dạng B, A22) |
| Fact Macro Indicator Snapshot | 1 chỉ tiêu vĩ mô × 1 kỳ công bố (PK Macro Indicator Value Id = id dòng Atomic `cl_risk_indicator_value`, Dạng A, A22); PTTT sở hữu, VP dùng lại (O_VP_41) |

#### Nhóm 22 - Biểu đồ Cơ cấu vốn hóa cổ phiếu theo ngành

> Phân loại: **Phân tích**
> Atomic: tái dùng `Fact Listed Equity Snapshot` (VP; MDDS.JAD_STOCKINFOR bản tin cuối ngày + VSDC.OUTSTANDING_SHARES, đã dùng cho Nhóm 19/55) và `Industry Dimension` (GSDC; IDS.CATEGORIES) — **READY**; thêm cột FK `Industry Dimension Id` vào Fact (không đổi grain/PK), phụ thuộc dev ETL + ALTER + nạp lại lịch sử (O_VP_66)

> **[GHI CHÚ 2026-11-08 — BA VP mapping Nhóm 22]** BA Nhóm 22 gồm 4 dòng (247–250: 2 Chiều — Kỳ, Ngành; 'Chỉ tiêu cơ sở' Vốn hóa theo ngành; 'Chỉ tiêu phái sinh' Tỷ trọng vốn hóa ngành; 2 'TB' + 2 'Trùng'). Cả 2 dòng 'Trùng' (248, 250) KHÔNG nêu trùng với chỉ tiêu nào → thiết kế đủ 3 KPI mới (K_VP_339–341) và reuse K_VP_1; Δ số lượng BA ↔ HLD ở Gate 10 là CÓ CHỦ Ý. Vốn hóa đọc `Fact Listed Equity Snapshot` (cùng K_VP_240/K_VP_172); chiều Ngành qua cột mới `Industry Dimension Id` của Fact (cùng cách Nhóm 8 và Nhóm 35, O_VP_66). Giả định/lệch BA (ngành theo hồ sơ hiện hành thay vì snapshot cố định, cột `thieu_von_hoa_upcom` thừa trong SQL BA, cột `so_ma_cp` chưa có dòng BA) ghi ở O_VP_66.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (Ngày / Tháng / Quý / Năm) · Kỳ báo cáo

| Ngành | Vốn hóa | Tỷ trọng (%) |
|---|---|---|
| (từng ngành cấp 1; 'Chưa phân ngành' cho mã không xác định được ngành) | … | … |
| Tổng tất cả ngành | … | 100 |

> ⚠️ Presentation Grain: 1 dòng = 1 Ngành (cấp 1) tại 1 kỳ báo cáo (vốn hóa tính tại ngày giao dịch gần nhất ≤ ngày cuối kỳ), thêm dòng 'Tổng tất cả ngành'. Storage Grain: 1 mã cổ phiếu × 1 ngày giao dịch (`Fact Listed Equity Snapshot`) — Ngành lấy qua `Industry Dimension Id` của Fact; xem Bảng grain.

**Source:** `Fact Listed Equity Snapshot` → `Calendar Date Dimension`, `Industry Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date trong kỳ (D/M/Q/Y) từ ngày đầu kỳ đến ngày cuối kỳ | Reuse K_VP_1 (Nhóm 1, 7, 19) — Case 1; BA dòng 247 — 1 kỳ duy nhất, loại kỳ D/M/Q/Y; :d_cur = phiên giao dịch gần nhất <= ngày cuối kỳ | READY |
| K_VP_339 | Ngành | — | Chiều | Industry Dimension.Industry Code / Industry Name qua FK Industry Dimension Id của Fact Listed Equity Snapshot; mã không xác định được ngành → nhóm 'NA' (Chưa phân ngành) | Case 1 — cột mới industry_dim_id của Fact (O_VP_66), cùng cách K_VP_84 (Nhóm 8) và K_VP_142 (Nhóm 35); BA dòng 248 'Trùng' không nêu chỉ tiêu trùng; CTCK/CTQLQ đại chúng = 07000 | READY |
| K_VP_340 | Vốn hóa theo ngành | VND | Cơ sở | SUM(Market Cap Value) trên Fact Listed Equity Snapshot với Stock Type Code = '2' (cổ phiếu), Floor Code ∈ (02, 04, 10) tại :d_cur, GROUP BY Industry (qua Industry Dimension Id của Fact) | Case 1 — measure Market Cap Value (UPCoM: VWAP T+1, O_VP_40; phiên mới nhất UPCoM = NULL); BA dòng 249 | READY |
| K_VP_341 | Tỷ trọng vốn hóa ngành | % | Phái sinh | Vốn hóa ngành (K_VP_340) / Σ vốn hóa mọi ngành × 100 tại :d_cur | Case 2 — tính tại presentation layer; BA dòng 250 'Trùng' không nêu chỉ tiêu trùng; dòng 'Tổng tất cả ngành' = ROLLUP | READY |

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
    Fact_Listed_Equity_Snapshot {
        string Listed_Equity_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Industry_Dimension_Id FK
        string Ticker_Symbol
        string Floor_Code
        string Stock_Type_Code
        string Fund_Type_Code
        bigint Outstanding_Share_Quantity
        bigint Listed_Share_Quantity
        decimal Listed_Share_Value
        decimal Close_Price
        decimal Reference_Price
        bigint Next_Day_Volume_Weighted_Average_Price
        decimal Market_Price
        decimal Market_Cap_Value
        string Source_System_Code
    }
    Industry_Dimension {
        string Industry_Dimension_Id PK
        string Industry_Code
        string Industry_Name
        string Source_System_Code
    }
    Calendar_Date_Dimension ||--o{ Fact_Listed_Equity_Snapshot : " "
    Industry_Dimension ||--o{ Fact_Listed_Equity_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Industry_Dimension["Industry Dimension"]
        Fact_Listed_Equity_Snapshot["Fact Listed Equity Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 22"]
        R1["K_VP_1,339,340,341: Vốn hóa thị trường >> Biểu đồ Cơ cấu vốn hóa cổ phiếu theo ngành"]
    end
    Calendar_Date_Dimension --> R1
    Industry_Dimension --> R1
    Fact_Listed_Equity_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Industry Dimension | 1 ngành nghề kinh doanh cấp 1 hiện hành (SCD4A current-state); sở hữu bởi GSDC |
| Fact Listed Equity Snapshot | 1 mã chứng khoán niêm yết/đăng ký giao dịch (cổ phiếu, chứng chỉ quỹ/ETF, chứng quyền, TPDN niêm yết — stock_tp_code 1/2/3/4/6, không gồm phái sinh) × 1 ngày giao dịch (bản tin cuối ngày MDDS JAD_STOCKINFOR); PK Listed Equity Snapshot Id = hash (Snapshot Date Dimension Id, Ticker Symbol, Source System Code) (Dạng B, A22); Industry Dimension Id là cột phụ thuộc hàm vào mã chứng khoán, không đổi grain/PK |

#### Nhóm 30 - Huy động vốn >> TPCP >> Chỉ tiêu tổng hợp

> Phân loại: **Phân tích**
> Atomic: `Gov Bond Bidding Result` ← HNX.GOV_BOND_OFFERING (Fact `Fact Government Bond Bidding Result Snapshot`) — **READY** (GT phát hành, kỳ hạn và lãi suất bình quân, % so với kỳ trước); `Gov Bond Listing` ← HNX.GOV_BOND_LISTED_LIST (Fact mới `Fact Government Bond Listing Snapshot`) — **READY** (Tổng dư nợ TPCP và % so với kỳ trước; Atomic đã có năm báo cáo từ 2026-11-04, khóa Atomic xem O_VP_62); nguồn HNX, KHÔNG phụ thuộc Securities Trade

**[GHI CHÚ 2026-11-03 — BA VP mapping Nhóm 30]** BA Nhóm 30 (Dashboard Huy động vốn >> TPCP >> Chỉ tiêu tổng hợp) gồm 9 dòng 'Done' (357 Kỳ — Chiều; 358–359 Tổng dư nợ TPCP và % so với kỳ trước; 360–361 GT phát hành và %; 362–363 Kỳ hạn bình quân và %; 364–365 Lãi suất bình quân và %). Phần phát hành đọc `Fact Government Bond Bidding Result Snapshot` (Nhóm 47/48) theo kỳ tháng/quý/năm của ngày phát hành; kỳ hạn quy đổi năm đã có ở cột Issue Term Years. **Tổng dư nợ TPCP (K_VP_271–272) READY từ 2026-11-05**: đọc Fact mới `Fact Government Bond Listing Snapshot` (grain 1 mã TPCP × 1 tháng báo cáo) vì Atomic `gov_bond_listing` đã có `rpt_year`; khóa Atomic chưa có tháng — O_VP_62. *(Lịch sử: PENDING [Nhóm 3] 2026-11-03 đến 2026-11-04 vì Atomic thiếu năm báo cáo — O_VP_50.)* Kỳ dùng lại K_VP_1. Các dòng 'Trùng' (359, 360, 361, 363, 365) vẫn có KPI riêng nên Δ số lượng BA ↔ HLD ở Gate 10 là CÓ CHỦ Ý. Giả định/lỗi BA ở O_VP_56.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (M/Q/Y) · Kỳ

| Chỉ tiêu | Kỳ báo cáo | % so với kỳ trước |
|---|---|---|
| Tổng dư nợ TPCP | … | … |
| GT phát hành | … | … |
| Kỳ hạn bình quân (năm) | … | … |
| Lãi suất bình quân (%/năm) | … | … |

> ⚠️ Presentation Grain: 1 dòng = 1 chỉ tiêu × 1 Kỳ (tháng/quý/năm), toàn thị trường TPCP. Storage Grain: 1 dòng kết quả đấu thầu phát hành TPCP (ngày phát hành × mã × đợt) — mịn hơn kỳ, đạt Iso-Grain; dư nợ: Fact Government Bond Listing Snapshot = 1 mã TPCP × 1 tháng báo cáo — mịn hơn kỳ, đạt Iso-Grain, xem Bảng grain.

**Source:** `Fact Government Bond Bidding Result Snapshot`, `Fact Government Bond Listing Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → tháng/quý/năm; Loại kỳ (M/Q/Y) và Kỳ là tham số lọc | Reuse từ Nhóm 14 (K_VP_1) — Case 1; BA dòng 357; Nhóm 30 chỉ có loại kỳ M/Q/Y | READY |
| K_VP_271 | Tổng dư nợ TPCP | VND | Cơ sở | SUM(Listed Bond Quantity) × 100.000 đồng (mệnh giá TPCP) tại tháng báo cáo mới nhất có dữ liệu trong kỳ tra cứu | Case 1 — measure Listed Bond Quantity, nhân mệnh giá 100.000 đúng công thức BA dòng 358 (`SUM(listed_volume) * 100000`); Atomic `gov_bond_listing` đã có `rpt_year` — khóa Atomic chưa có tháng, O_VP_62 | READY |
| K_VP_272 | Tổng dư nợ TPCP - So với kỳ trước (%) | % | Phái sinh | (Tổng dư nợ kỳ này − Tổng dư nợ kỳ trước) / Tổng dư nợ kỳ trước × 100 | Case 2 — từ K_VP_271 tại 2 kỳ; COALESCE tử số như SQL BA; BA dòng 359 'Trùng' — O_VP_62 | READY |
| K_VP_273 | GT phát hành | VND | Cơ sở | SUM(Winning Value) trên Fact Government Bond Bidding Result Snapshot trong kỳ (ngày phát hành thuộc kỳ), COALESCE 0 | Case 1 — measure Winning Value; GT phát hành = giá trị trúng thầu; BA dòng 360 'Trùng' với Nhóm 31 dòng 368 (dùng chung); đơn vị giả định VND — O_VP_56 | READY |
| K_VP_274 | GT phát hành - So với kỳ trước (%) | % | Phái sinh | (K_VP_273 kỳ này − K_VP_273 kỳ trước) / K_VP_273 kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_275 | Kỳ hạn bình quân (năm) | Năm | Phái sinh | Σ (Issue Term Years × Winning Value) / Σ Winning Value trên Fact Government Bond Bidding Result Snapshot trong kỳ, làm tròn 2 chữ số | Case 2 — bình quân gia quyền tại presentation layer; cùng cách tính K_VP_255 nhưng theo kỳ T/Q/Y; kỳ hạn quy đổi năm tại ETL — O_VP_49 | READY |
| K_VP_276 | Kỳ hạn bình quân (năm) - % so với kỳ trước | % | Phái sinh | (K_VP_275 kỳ này − K_VP_275 kỳ trước) / K_VP_275 kỳ trước × 100 (giá trị chưa làm tròn) | Case 2 — tính tại presentation layer; cột Điều kiện BA ghi nhầm công thức lãi suất — O_VP_56 | READY |
| K_VP_277 | Lãi suất bình quân (%/năm) | % | Phái sinh | Σ (Winning Interest Rate × Winning Value) / Σ Winning Value trên Fact Government Bond Bidding Result Snapshot trong kỳ, làm tròn 4 chữ số | Case 2 — bình quân gia quyền tại presentation layer; cùng cách tính K_VP_256 nhưng theo kỳ T/Q/Y — O_VP_49 | READY |
| K_VP_278 | Lãi suất bình quân (%/năm) - % thay đổi so với kỳ trước | % | Phái sinh | (K_VP_277 kỳ này − K_VP_277 kỳ trước) / K_VP_277 kỳ trước × 100 (giá trị chưa làm tròn) | Case 2 — tính tại presentation layer; % thay đổi tương đối, không phải chênh lệch điểm % | READY |

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
    Government_Bond_Term_Dimension {
        string Government_Bond_Term_Dimension_Id PK
        string Bond_Term
        decimal Bond_Term_Years
        string Bond_Term_Unit
        string Source_System_Code
    }
    Fact_Government_Bond_Bidding_Result_Snapshot {
        string Government_Bond_Bidding_Result_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Government_Bond_Term_Dimension_Id FK
        int Report_Year
        int Report_Month
        string Bidding_Session
        string Bond_Code
        string Bond_Term
        decimal Issue_Term_Years
        decimal Calling_Value
        decimal Winning_Value
        decimal Winning_Interest_Rate
        string Source_System_Code
    }
    Fact_Government_Bond_Listing_Snapshot {
        string Government_Bond_Listing_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Bond_Code
        int Report_Year
        int Report_Month
        bigint Listed_Bond_Quantity
        decimal Listed_Bond_Value
    }
    Calendar_Date_Dimension ||--o{ Fact_Government_Bond_Bidding_Result_Snapshot : " "
    Government_Bond_Term_Dimension ||--o{ Fact_Government_Bond_Bidding_Result_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Government_Bond_Listing_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Government_Bond_Bidding_Result_Snapshot["Fact Government Bond Bidding Result Snapshot"]
        Fact_Government_Bond_Listing_Snapshot["Fact Government Bond Listing Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 30"]
        R1["K_VP_1,271-278: Huy động vốn >> TPCP >> Chỉ tiêu tổng hợp"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Government_Bond_Bidding_Result_Snapshot --> R1
    Fact_Government_Bond_Listing_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Government Bond Bidding Result Snapshot | 1 dòng kết quả đấu thầu phát hành trái phiếu Chính phủ (id dòng Atomic `gov_bond_bidding_result`; HNX.GOV_BOND_OFFERING); PK Government Bond Bidding Result Snapshot Id = id dòng Atomic (Dạng A, A22); kỳ theo ngày phát hành |
| Fact Government Bond Listing Snapshot | 1 mã trái phiếu Chính phủ niêm yết × 1 tháng báo cáo (Report Year, Report Month; Atomic `gov_bond_listing` ← HNX.GOV_BOND_LISTED_LIST); PK Government Bond Listing Snapshot Id = hash (Bond Code, Report Year, Report Month, Source System Code) (Dạng B, A22); khóa ngày = ngày cuối tháng báo cáo |

#### Nhóm 31 - Huy động vốn >> TPCP >> Biểu đồ Giá trị trúng thầu TPCP

> Phân loại: **Phân tích**
> Atomic: Fact `Fact Government Bond Bidding Result Snapshot` ← HNX.GOV_BOND_OFFERING (Atomic `Gov Bond Bidding Result`, draft) — **READY**; nguồn HNX, KHÔNG phụ thuộc Securities Trade

**[GHI CHÚ 2026-11-03 — BA VP mapping Nhóm 31]** BA Nhóm 31 gồm 4 dòng 'Done' (366 Kỳ — Chiều, Từ kỳ — Đến kỳ; 367 Giá trị gọi thầu; 368 Giá trị trúng thầu — 'Trùng'; 369 Tỷ lệ trúng thầu — 'Trùng'). Dùng chung `Fact Government Bond Bidding Result Snapshot` với Nhóm 30/47/48; **thêm cột Calling Value** (Atomic `calling_val`) vào Fact — cần dev ALTER + nạp lại (O_VP_56). Giá trị trúng thầu dùng lại K_VP_273 (cùng Σ Winning Value với 'GT phát hành' Nhóm 30). Tỷ lệ trúng thầu theo SQL/Mô tả mới = trúng / gọi × 100 (BA bản trước ghi chiều ngược). Kỳ dùng lại K_VP_1 dạng khoảng như Nhóm 15. Δ số lượng BA ↔ HLD ở Gate 10 (dòng 'Trùng') là CÓ CHỦ Ý.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (M/Q/Y) · Từ kỳ · Đến kỳ

| Kỳ | Giá trị gọi thầu | Giá trị trúng thầu | Tỷ lệ trúng thầu (%) |
|---|---|---|---|
| … | … | … | … |

> ⚠️ Presentation Grain: 1 điểm biểu đồ = 1 Kỳ (tháng/quý/năm) trong khoảng Từ kỳ — Đến kỳ, toàn thị trường TPCP. Storage Grain: 1 dòng kết quả đấu thầu phát hành TPCP — mịn hơn kỳ, đạt Iso-Grain — xem Bảng grain.

**Source:** `Fact Government Bond Bidding Result Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → tháng/quý/năm; Loại kỳ (M/Q/Y), Từ kỳ — Đến kỳ là tham số lọc | Reuse từ Nhóm 15 (K_VP_1) — Case 1; BA dòng 366; tên tham số BA lệch giữa SQL và Điều kiện — O_VP_56 | READY |
| K_VP_279 | Giá trị gọi thầu | VND | Cơ sở | SUM(Calling Value) trên Fact Government Bond Bidding Result Snapshot, GROUP BY kỳ | Case 1 — measure Calling Value (cột MỚI trên Fact, Atomic `calling_val`) — O_VP_56; đơn vị giả định VND | READY |
| K_VP_273 | Giá trị trúng thầu | VND | Cơ sở | SUM(Winning Value) trên Fact Government Bond Bidding Result Snapshot, GROUP BY kỳ | Reuse từ Nhóm 30 (K_VP_273, GT phát hành) — Case 1; BA dòng 368 'Trùng' | READY |
| K_VP_280 | Tỷ lệ trúng thầu (%) | % | Phái sinh | Σ Winning Value / Σ Calling Value × 100 trên Fact Government Bond Bidding Result Snapshot, GROUP BY kỳ | Case 2 — tính tại presentation layer; mẫu số NULLIF 0 như SQL BA; chiều công thức theo bản BA 2026-11-03 — O_VP_56 | READY |

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
    Government_Bond_Term_Dimension {
        string Government_Bond_Term_Dimension_Id PK
        string Bond_Term
        decimal Bond_Term_Years
        string Bond_Term_Unit
        string Source_System_Code
    }
    Fact_Government_Bond_Bidding_Result_Snapshot {
        string Government_Bond_Bidding_Result_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Government_Bond_Term_Dimension_Id FK
        int Report_Year
        int Report_Month
        string Bidding_Session
        string Bond_Code
        string Bond_Term
        decimal Issue_Term_Years
        decimal Calling_Value
        decimal Winning_Value
        decimal Winning_Interest_Rate
        string Source_System_Code
    }
    Calendar_Date_Dimension ||--o{ Fact_Government_Bond_Bidding_Result_Snapshot : " "
    Government_Bond_Term_Dimension ||--o{ Fact_Government_Bond_Bidding_Result_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Government_Bond_Bidding_Result_Snapshot["Fact Government Bond Bidding Result Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 31"]
        R1["K_VP_1,273,279,280: Huy động vốn >> TPCP >> Biểu đồ Giá trị trúng thầu TPCP"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Government_Bond_Bidding_Result_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Government Bond Bidding Result Snapshot | 1 dòng kết quả đấu thầu phát hành trái phiếu Chính phủ (id dòng Atomic `gov_bond_bidding_result`; HNX.GOV_BOND_OFFERING); PK Government Bond Bidding Result Snapshot Id = id dòng Atomic (Dạng A, A22); kỳ theo ngày phát hành |

#### Nhóm 32 - Mua/Bán ròng NĐTNN >> Chỉ tiêu tổng hợp

> Phân loại: **Phân tích**
> Atomic: tái dùng Fact VP đã thiết kế (Nhóm 1–16): `Fact Investor Group Trading Snapshot` (cổ phiếu/CCQ/chứng quyền/phái sinh — Sổ lệnh HNX/HOSE, **[!] O_VP_1**), `Fact Listed Corporate Bond Snapshot`, `Fact Private Corporate Bond Trading Snapshot`, `Fact Government Bond Trading Snapshot` — KHÔNG thêm bảng/cột Fact mới

> **[GHI CHÚ 2026-10-28 — BA 'Trùng' theo tên ≠ trùng ngữ nghĩa]** BA đánh 'Trùng' 6 dòng (365–368, 370, 378: GT mua/bán ròng NĐTNN, % thay đổi, YTD, % mua/bán) vì cùng TÊN với chỉ tiêu ở Nhóm 1/33, nhưng phạm vi khác: Nhóm 1 chỉ cổ phiếu + CCQ (K_VP_5), Nhóm 32 là Σ 6 loại tài sản (cổ phiếu, chứng quyền, CCQ, TPDN niêm yết, TPDN riêng lẻ, TPCP). Dùng lại K_VP_5 sẽ thiếu 3 loại trái phiếu → thiết kế KPI riêng (K_VP_115–134); vì vậy Δ số lượng BA ↔ HLD = +6 ở Gate 10 là CÓ CHỦ Ý. Thiết kế dùng lại Fact VP Nhóm 1–16, không thêm Fact/cột; sổ lệnh cổ phiếu/CCQ/chứng quyền vẫn chờ Atomic (O_VP_1); dòng BA 382–384 lỗi copy phía mua — O_VP_34.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (D/M/Q/Y) · Kỳ

| Chỉ tiêu | Kỳ báo cáo | Kỳ trước | % thay đổi |
|---|---|---|---|
| GT mua/bán ròng NĐTNN | … | … | … |
| GT mua/bán ròng NĐTNN (YTD) | … | … | … |
| GT mua NĐTNN | … | … | … |
| GT bán NĐTNN | … | … | … |

> ⚠️ Presentation Grain: 1 dòng = 1 chỉ tiêu × 1 Kỳ, toàn thị trường, nhóm NĐT nước ngoài (Level 1); chiều 'Loại chứng khoán' chỉ cắt theo `Stock Type Name` (cổ phiếu) hoặc theo Fact (trái phiếu). Storage Grain: xem Bảng grain.

**Source:** `Fact Investor Group Trading Snapshot`, `Fact Listed Corporate Bond Snapshot`, `Fact Private Corporate Bond Trading Snapshot`, `Fact Government Bond Trading Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Reuse từ Nhóm 1 (K_VP_1) — Case 1 | READY |
| K_VP_115 | GT mua/bán ròng NĐTNN | VND | Phái sinh | Σ GT mua NĐTNN − Σ GT bán NĐTNN của 6 loại tài sản trong kỳ | Case 2 — tính tại presentation layer từ 12 chỉ tiêu cơ sở theo loại. [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền) — O_VP_1 | READY |
| K_VP_116 | GT mua/bán ròng NĐTNN - % thay đổi so với kỳ trước | % | Phái sinh | (GT ròng kỳ báo cáo − GT ròng kỳ trước) / GT ròng kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_117 | GT mua/bán ròng NĐTNN (YTD) | VND | Phái sinh | Σ GT mua/bán ròng NĐTNN từ đầu năm đến cuối kỳ báo cáo | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_118 | GT mua/bán ròng NĐTNN (YTD) - % thay đổi so với cùng kỳ năm trước | % | Phái sinh | (GT ròng YTD kỳ báo cáo − GT ròng YTD cùng kỳ năm trước) / GT ròng YTD cùng kỳ năm trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_119 | GT mua NĐTNN | VND | Phái sinh | Σ giá trị mua NĐTNN của 6 loại tài sản trong kỳ | Case 2 — cộng 6 chỉ tiêu cơ sở theo loại; BA ghi 'Chỉ tiêu cơ sở' nhưng Mô tả là Σ → Phái sinh. [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền) — O_VP_1 | READY |
| K_VP_120 | GT mua NĐTNN - % thay đổi so với kỳ trước | % | Phái sinh | (GT mua NĐTNN kỳ báo cáo − kỳ trước) / kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_121 | GT mua NĐTNN - Cổ phiếu | VND | Cơ sở | SUM(Buy Value) trên Fact Investor Group Trading Snapshot với Investor Group Code = 'FOREIGN', Stock Type Name = 'Cổ phiếu' (Security Trading Snapshot Dimension), Market Id Code ∈ (STK, STX, UPX), trong kỳ | Case 1 — measure Buy Value; cùng measure nền với K_VP_5 (Nhóm 1); [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền) — O_VP_1 | READY |
| K_VP_122 | GT mua NĐTNN - Chứng quyền | VND | Cơ sở | SUM(Buy Value) trên Fact Investor Group Trading Snapshot với Investor Group Code = 'FOREIGN', Stock Type Name = 'Chứng quyền' (Security Trading Snapshot Dimension), Market Id Code ∈ (STK, STX, UPX), trong kỳ | Case 1 — measure Buy Value; cùng measure nền với K_VP_5 (Nhóm 1); [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền) — O_VP_1 | READY |
| K_VP_123 | GT mua NĐTNN - Chứng chỉ quỹ | VND | Cơ sở | SUM(Buy Value) trên Fact Investor Group Trading Snapshot với Investor Group Code = 'FOREIGN', Stock Type Name = 'Chứng chỉ quỹ', 'ETF' (Security Trading Snapshot Dimension), Market Id Code ∈ (STK, STX, UPX), trong kỳ | Case 1 — measure Buy Value; cùng measure nền với K_VP_5 (Nhóm 1); [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền) — O_VP_1 | READY |
| K_VP_124 | GT mua NĐTNN - TPDN niêm yết | VND | Cơ sở | SUM(Foreign Buy Value) trên Fact Listed Corporate Bond Snapshot trong kỳ; Foreign Buy Value = Σ giá trị lệnh có ký tự thứ 4 của số tài khoản mua ∈ ('E','F') | Case 1 — measure Foreign Buy Value; cùng measure nền với K_VP_77/79 (Nhóm 7) | READY |
| K_VP_125 | GT mua NĐTNN - TPDN riêng lẻ | VND | Cơ sở | SUM(Foreign Buy Value) trên Fact Private Corporate Bond Trading Snapshot trong kỳ; Foreign Buy Value = Σ giá trị lệnh có ký tự thứ 4 của số tài khoản mua ∈ ('E','F') | Case 1 — measure Foreign Buy Value; cùng measure nền với K_VP_94/96 (Nhóm 11) | READY |
| K_VP_126 | GT mua NĐTNN - TPCP | VND | Cơ sở | SUM(Foreign Buy Value) trên Fact Government Bond Trading Snapshot trong kỳ; Foreign Buy Value = Σ giá trị lệnh có ký tự thứ 4 của số tài khoản mua ∈ ('E','F') | Case 1 — measure Foreign Buy Value; cùng measure nền với K_VP_106/108 (Nhóm 14) | READY |
| K_VP_127 | GT bán NĐTNN | VND | Phái sinh | Σ giá trị bán NĐTNN của 6 loại tài sản trong kỳ | Case 2 — cộng 6 chỉ tiêu cơ sở theo loại; BA ghi 'Chỉ tiêu cơ sở' nhưng Mô tả là Σ → Phái sinh. [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền) — O_VP_1 | READY |
| K_VP_128 | GT bán NĐTNN - % thay đổi so với kỳ trước | % | Phái sinh | (GT bán NĐTNN kỳ báo cáo − kỳ trước) / kỳ trước × 100 | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_129 | GT bán NĐTNN - Cổ phiếu | VND | Cơ sở | SUM(Sell Value) trên Fact Investor Group Trading Snapshot với Investor Group Code = 'FOREIGN', Stock Type Name = 'Cổ phiếu' (Security Trading Snapshot Dimension), Market Id Code ∈ (STK, STX, UPX), trong kỳ | Case 1 — measure Sell Value; cùng measure nền với K_VP_5 (Nhóm 1); [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền) — O_VP_1 | READY |
| K_VP_130 | GT bán NĐTNN - Chứng quyền | VND | Cơ sở | SUM(Sell Value) trên Fact Investor Group Trading Snapshot với Investor Group Code = 'FOREIGN', Stock Type Name = 'Chứng quyền' (Security Trading Snapshot Dimension), Market Id Code ∈ (STK, STX, UPX), trong kỳ | Case 1 — measure Sell Value; cùng measure nền với K_VP_5 (Nhóm 1); [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền) — O_VP_1 | READY |
| K_VP_131 | GT bán NĐTNN - Chứng chỉ quỹ | VND | Cơ sở | SUM(Sell Value) trên Fact Investor Group Trading Snapshot với Investor Group Code = 'FOREIGN', Stock Type Name = 'Chứng chỉ quỹ', 'ETF' (Security Trading Snapshot Dimension), Market Id Code ∈ (STK, STX, UPX), trong kỳ | Case 1 — measure Sell Value; cùng measure nền với K_VP_5 (Nhóm 1); [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền) — O_VP_1 | READY |
| K_VP_132 | GT bán NĐTNN - TPDN niêm yết | VND | Cơ sở | SUM(Foreign Sell Value) trên Fact Listed Corporate Bond Snapshot trong kỳ; Foreign Sell Value = Σ giá trị lệnh có ký tự thứ 4 của số tài khoản bán ∈ ('E','F') | Case 1 — measure Foreign Sell Value; cùng measure nền với K_VP_77/79 (Nhóm 7) BA lỗi copy: điều kiện dòng này ghi theo phía MUA (`h.buy_account_number`) dù chỉ tiêu là GT bán — thiết kế theo ý định bán (O_VP_34). | READY |
| K_VP_133 | GT bán NĐTNN - TPDN riêng lẻ | VND | Cơ sở | SUM(Foreign Sell Value) trên Fact Private Corporate Bond Trading Snapshot trong kỳ; Foreign Sell Value = Σ giá trị lệnh có ký tự thứ 4 của số tài khoản bán ∈ ('E','F') | Case 1 — measure Foreign Sell Value; cùng measure nền với K_VP_94/96 (Nhóm 11) BA lỗi copy: điều kiện dòng này ghi theo phía MUA (row_path '…GIÁ TRỊ MUA') dù chỉ tiêu là GT bán — thiết kế theo ý định bán (O_VP_34). | READY |
| K_VP_134 | GT bán NĐTNN - TPCP | VND | Cơ sở | SUM(Foreign Sell Value) trên Fact Government Bond Trading Snapshot trong kỳ; Foreign Sell Value = Σ giá trị lệnh có ký tự thứ 4 của số tài khoản bán ∈ ('E','F') | Case 1 — measure Foreign Sell Value; cùng measure nền với K_VP_106/108 (Nhóm 14) BA lỗi copy: điều kiện dòng này ghi theo phía MUA (`buying_account_no`) dù chỉ tiêu là GT bán — thiết kế theo ý định bán (O_VP_34). | READY |

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
        string Industry_Dimension_Id FK
        string Security_Symbol_Code
        string Market_Id_Code
        string Investor_Group_Code
        bigint Buy_Volume
        decimal Buy_Value
        bigint Sell_Volume
        decimal Sell_Value
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
    Fact_Government_Bond_Trading_Snapshot {
        string Government_Bond_Trading_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Order_Book_Type_Code
        bigint Trading_Volume
        decimal Trading_Value
        decimal Foreign_Buy_Value
        decimal Foreign_Sell_Value
    }
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Listed_Corporate_Bond_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Private_Corporate_Bond_Trading_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Government_Bond_Trading_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Security_Trading_Snapshot_Dimension["Security Trading Snapshot Dimension"]
        Fact_Investor_Group_Trading_Snapshot["Fact Investor Group Trading Snapshot"]
        Fact_Listed_Corporate_Bond_Snapshot["Fact Listed Corporate Bond Snapshot"]
        Fact_Private_Corporate_Bond_Trading_Snapshot["Fact Private Corporate Bond Trading Snapshot"]
        Fact_Government_Bond_Trading_Snapshot["Fact Government Bond Trading Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 32"]
        R1["K_VP_1,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134: Mua/Bán ròng NĐTNN >> Chỉ tiêu tổng hợp"]
    end
    Calendar_Date_Dimension --> R1
    Security_Trading_Snapshot_Dimension --> R1
    Fact_Investor_Group_Trading_Snapshot --> R1
    Fact_Listed_Corporate_Bond_Snapshot --> R1
    Fact_Private_Corporate_Bond_Trading_Snapshot --> R1
    Fact_Government_Bond_Trading_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Security Trading Snapshot Dimension | 1 mã chứng khoán / hợp đồng phái sinh (SCD4A current-state); sở hữu bởi GSTT |
| Fact Investor Group Trading Snapshot | 1 mã chứng khoán / hợp đồng × 1 ngày giao dịch × 1 sàn (Market Id Code) × 1 nhóm NĐT (ALL / FOREIGN / PROPRIETARY); PK Investor Group Trading Snapshot Id = hash toàn bộ cột grain (Dạng B, A22) |
| Fact Listed Corporate Bond Snapshot | 1 mã trái phiếu (ISIN — Security Symbol Code) × 1 ngày giao dịch; PK Listed Corporate Bond Snapshot Id = hash (Snapshot Date Dimension Id, Security Symbol Code) (Dạng B, A22) |
| Fact Private Corporate Bond Trading Snapshot | 1 ngày báo cáo HNX09 (báo cáo ngày TPDN riêng lẻ, nguồn nộp ICP); PK Private Corporate Bond Trading Snapshot Id = hash (Snapshot Date Dimension Id) (Dạng B, A22) |
| Fact Government Bond Trading Snapshot | 1 ngày giao dịch × 1 loại sổ lệnh (Order Book Type Code ∈ OUTRIGHT, REPO); PK Government Bond Trading Snapshot Id = hash (Snapshot Date Dimension Id, Order Book Type Code) (Dạng B, A22) |

#### Nhóm 33 - Mua/Bán ròng NĐTNN >> Chi tiết giao dịch

> Phân loại: **Phân tích**
> Atomic: tái dùng Fact VP đã thiết kế (Nhóm 1–16): `Fact Investor Group Trading Snapshot` (cổ phiếu/CCQ/chứng quyền/phái sinh — Sổ lệnh HNX/HOSE, **[!] O_VP_1**), `Fact Listed Corporate Bond Snapshot`, `Fact Private Corporate Bond Trading Snapshot`, `Fact Government Bond Trading Snapshot` — KHÔNG thêm bảng/cột Fact mới

**[CẬP NHẬT 2026-11-08]** BA chuyển dòng 'GT bán NĐTNN - Cổ phiếu' (K_VP_129) từ Nhóm 34 sang Nhóm 33 (BA dòng 358, cuối Nhóm); KPI dùng lại K_VP_129 của Nhóm 32 (Case 1), không thêm bảng/cột Fact. Nhóm 33 có 13 dòng BA, Nhóm 34 còn 6 dòng.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (D/M/Q/Y) · Kỳ

| Chỉ tiêu | Kỳ báo cáo | Kỳ trước | % thay đổi |
|---|---|---|---|
| GT mua/bán ròng NĐTNN theo Loại chứng khoán | … | … | … |
| GT mua NĐTNN theo Loại chứng khoán | … | … | … |
| GT bán NĐTNN theo Loại chứng khoán | … | … | … |

> ⚠️ Presentation Grain: 1 dòng = 1 chỉ tiêu × 1 Kỳ, toàn thị trường, nhóm NĐT nước ngoài (Level 1); chiều 'Loại chứng khoán' chỉ cắt theo `Stock Type Name` (cổ phiếu) hoặc theo Fact (trái phiếu). Storage Grain: xem Bảng grain.

**Source:** `Fact Investor Group Trading Snapshot`, `Fact Listed Corporate Bond Snapshot`, `Fact Private Corporate Bond Trading Snapshot`, `Fact Government Bond Trading Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_135 | Loại chứng khoán | — | Chiều | Security Trading Snapshot Dimension.Stock Type Name (Cổ phiếu / Chứng quyền / Chứng chỉ quỹ·ETF / Phái sinh) + nhãn Fact trái phiếu | Chiều — O_VP_35 | READY |
| K_VP_136 | GT mua/bán ròng NĐTNN | VND | Phái sinh | (Σ GT mua − Σ GT bán) NĐTNN theo từng Loại chứng khoán trong kỳ | Case 2 — tính tại presentation layer. [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền/phái sinh) — O_VP_1 | READY |
| K_VP_137 | GT mua/bán ròng NĐTNN - % thay đổi so với kỳ trước | % | Phái sinh | (GT ròng kỳ báo cáo − kỳ trước) / kỳ trước × 100 theo Loại chứng khoán | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_138 | GT mua NĐTNN - % thay đổi so với kỳ trước | % | Phái sinh | (GT mua kỳ báo cáo − kỳ trước) / kỳ trước × 100 theo Loại chứng khoán | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_139 | GT bán NĐTNN - % thay đổi so với kỳ trước | % | Phái sinh | (GT bán kỳ báo cáo − kỳ trước) / kỳ trước × 100 theo Loại chứng khoán | Case 2 — tính tại presentation layer; kỳ trước — O_VP_5 | READY |
| K_VP_121 | GT mua NĐTNN - Cổ phiếu | VND | Cơ sở | SUM(Buy Value) trên Fact Investor Group Trading Snapshot với Investor Group Code = 'FOREIGN', Stock Type Name = 'Cổ phiếu' (Security Trading Snapshot Dimension), Market Id Code ∈ (STK, STX, UPX), trong kỳ | Reuse từ Nhóm 32 (K_VP_121) — Case 1; Case 1 — measure Buy Value; cùng measure nền với K_VP_5 (Nhóm 1); [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền) — O_VP_1 | READY |
| K_VP_122 | GT mua NĐTNN - Chứng quyền | VND | Cơ sở | SUM(Buy Value) trên Fact Investor Group Trading Snapshot với Investor Group Code = 'FOREIGN', Stock Type Name = 'Chứng quyền' (Security Trading Snapshot Dimension), Market Id Code ∈ (STK, STX, UPX), trong kỳ | Reuse từ Nhóm 32 (K_VP_122) — Case 1; Case 1 — measure Buy Value; cùng measure nền với K_VP_5 (Nhóm 1); [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền) — O_VP_1 | READY |
| K_VP_123 | GT mua NĐTNN - Chứng chỉ quỹ | VND | Cơ sở | SUM(Buy Value) trên Fact Investor Group Trading Snapshot với Investor Group Code = 'FOREIGN', Stock Type Name = 'Chứng chỉ quỹ', 'ETF' (Security Trading Snapshot Dimension), Market Id Code ∈ (STK, STX, UPX), trong kỳ | Reuse từ Nhóm 32 (K_VP_123) — Case 1; Case 1 — measure Buy Value; cùng measure nền với K_VP_5 (Nhóm 1); [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền) — O_VP_1 | READY |
| K_VP_124 | GT mua NĐTNN - TPDN niêm yết | VND | Cơ sở | SUM(Foreign Buy Value) trên Fact Listed Corporate Bond Snapshot trong kỳ; Foreign Buy Value = Σ giá trị lệnh có ký tự thứ 4 của số tài khoản mua ∈ ('E','F') | Reuse từ Nhóm 32 (K_VP_124) — Case 1; Case 1 — measure Foreign Buy Value; cùng measure nền với K_VP_77/79 (Nhóm 7) | READY |
| K_VP_125 | GT mua NĐTNN - TPDN riêng lẻ | VND | Cơ sở | SUM(Foreign Buy Value) trên Fact Private Corporate Bond Trading Snapshot trong kỳ; Foreign Buy Value = Σ giá trị lệnh có ký tự thứ 4 của số tài khoản mua ∈ ('E','F') | Reuse từ Nhóm 32 (K_VP_125) — Case 1; Case 1 — measure Foreign Buy Value; cùng measure nền với K_VP_94/96 (Nhóm 11) | READY |
| K_VP_126 | GT mua NĐTNN - TPCP | VND | Cơ sở | SUM(Foreign Buy Value) trên Fact Government Bond Trading Snapshot trong kỳ; Foreign Buy Value = Σ giá trị lệnh có ký tự thứ 4 của số tài khoản mua ∈ ('E','F') | Reuse từ Nhóm 32 (K_VP_126) — Case 1; Case 1 — measure Foreign Buy Value; cùng measure nền với K_VP_106/108 (Nhóm 14) | READY |
| K_VP_140 | GT mua NĐTNN - Giao dịch phái sinh | VND | Cơ sở | SUM(Buy Value) trên Fact Investor Group Trading Snapshot với Investor Group Code = 'FOREIGN', Market Id Code = 'DVX', Stock Type Name = 'Phái sinh', trong kỳ | Case 1 — measure Buy Value (K_VP_23/33… dùng Buy Volume cho phái sinh ở Nhóm 3). [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền/phái sinh) — O_VP_1; cách tính GT phái sinh — O_VP_36 | READY |
| K_VP_129 | GT bán NĐTNN - Cổ phiếu | VND | Cơ sở | SUM(Sell Value) trên Fact Investor Group Trading Snapshot với Investor Group Code = 'FOREIGN', Stock Type Name = 'Cổ phiếu' (Security Trading Snapshot Dimension), Market Id Code ∈ (STK, STX, UPX), trong kỳ | Reuse từ Nhóm 32 (K_VP_129) — Case 1; Case 1 — measure Sell Value; cùng measure nền với K_VP_5 (Nhóm 1); [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền) — O_VP_1; BA chuyển từ Nhóm 34 sang Nhóm 33 (BA dòng 358, 2026-11-08) | READY |

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
        string Industry_Dimension_Id FK
        string Security_Symbol_Code
        string Market_Id_Code
        string Investor_Group_Code
        bigint Buy_Volume
        decimal Buy_Value
        bigint Sell_Volume
        decimal Sell_Value
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
    Fact_Government_Bond_Trading_Snapshot {
        string Government_Bond_Trading_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Order_Book_Type_Code
        bigint Trading_Volume
        decimal Trading_Value
        decimal Foreign_Buy_Value
        decimal Foreign_Sell_Value
    }
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Listed_Corporate_Bond_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Private_Corporate_Bond_Trading_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Government_Bond_Trading_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Security_Trading_Snapshot_Dimension["Security Trading Snapshot Dimension"]
        Fact_Investor_Group_Trading_Snapshot["Fact Investor Group Trading Snapshot"]
        Fact_Listed_Corporate_Bond_Snapshot["Fact Listed Corporate Bond Snapshot"]
        Fact_Private_Corporate_Bond_Trading_Snapshot["Fact Private Corporate Bond Trading Snapshot"]
        Fact_Government_Bond_Trading_Snapshot["Fact Government Bond Trading Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 33"]
        R1["K_VP_135,136,137,138,139,121,122,123,124,125,126,140: Mua/Bán ròng NĐTNN >> Chi tiết giao dịch"]
    end
    Calendar_Date_Dimension --> R1
    Security_Trading_Snapshot_Dimension --> R1
    Fact_Investor_Group_Trading_Snapshot --> R1
    Fact_Listed_Corporate_Bond_Snapshot --> R1
    Fact_Private_Corporate_Bond_Trading_Snapshot --> R1
    Fact_Government_Bond_Trading_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Security Trading Snapshot Dimension | 1 mã chứng khoán / hợp đồng phái sinh (SCD4A current-state); sở hữu bởi GSTT |
| Fact Investor Group Trading Snapshot | 1 mã chứng khoán / hợp đồng × 1 ngày giao dịch × 1 sàn (Market Id Code) × 1 nhóm NĐT (ALL / FOREIGN / PROPRIETARY); PK Investor Group Trading Snapshot Id = hash toàn bộ cột grain (Dạng B, A22) |
| Fact Listed Corporate Bond Snapshot | 1 mã trái phiếu (ISIN — Security Symbol Code) × 1 ngày giao dịch; PK Listed Corporate Bond Snapshot Id = hash (Snapshot Date Dimension Id, Security Symbol Code) (Dạng B, A22) |
| Fact Private Corporate Bond Trading Snapshot | 1 ngày báo cáo HNX09 (báo cáo ngày TPDN riêng lẻ, nguồn nộp ICP); PK Private Corporate Bond Trading Snapshot Id = hash (Snapshot Date Dimension Id) (Dạng B, A22) |
| Fact Government Bond Trading Snapshot | 1 ngày giao dịch × 1 loại sổ lệnh (Order Book Type Code ∈ OUTRIGHT, REPO); PK Government Bond Trading Snapshot Id = hash (Snapshot Date Dimension Id, Order Book Type Code) (Dạng B, A22) |

#### Nhóm 34 - Mua/Bán ròng NĐTNN >> Chỉ tiêu tổng hợp

> Phân loại: **Phân tích**
> Atomic: tái dùng Fact VP đã thiết kế (Nhóm 1–16): `Fact Investor Group Trading Snapshot` (cổ phiếu/CCQ/chứng quyền/phái sinh — Sổ lệnh HNX/HOSE, **[!] O_VP_1**), `Fact Listed Corporate Bond Snapshot`, `Fact Private Corporate Bond Trading Snapshot`, `Fact Government Bond Trading Snapshot` — KHÔNG thêm bảng/cột Fact mới

**[CẬP NHẬT 2026-11-08]** BA bỏ dòng 'GT bán NĐTNN - Cổ phiếu' khỏi Nhóm 34 và chuyển sang Nhóm 33 (BA dòng 358); Nhóm 34 còn 6 chỉ tiêu bán (K_VP_130–134, 141); K_VP_129 vẫn là KPI của Nhóm 32.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (D/M/Q/Y) · Kỳ

| Chỉ tiêu | Kỳ báo cáo | Kỳ trước | % thay đổi |
|---|---|---|---|
| GT bán NĐTNN theo Loại chứng khoán | … | … | … |

> ⚠️ Presentation Grain: 1 dòng = 1 chỉ tiêu × 1 Kỳ, toàn thị trường, nhóm NĐT nước ngoài (Level 1); chiều 'Loại chứng khoán' chỉ cắt theo `Stock Type Name` (cổ phiếu) hoặc theo Fact (trái phiếu). Storage Grain: xem Bảng grain.

**Source:** `Fact Investor Group Trading Snapshot`, `Fact Listed Corporate Bond Snapshot`, `Fact Private Corporate Bond Trading Snapshot`, `Fact Government Bond Trading Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_130 | GT bán NĐTNN - Chứng quyền | VND | Cơ sở | SUM(Sell Value) trên Fact Investor Group Trading Snapshot với Investor Group Code = 'FOREIGN', Stock Type Name = 'Chứng quyền' (Security Trading Snapshot Dimension), Market Id Code ∈ (STK, STX, UPX), trong kỳ | Reuse từ Nhóm 32 (K_VP_130) — Case 1; Case 1 — measure Sell Value; cùng measure nền với K_VP_5 (Nhóm 1); [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền) — O_VP_1 | READY |
| K_VP_131 | GT bán NĐTNN - Chứng chỉ quỹ | VND | Cơ sở | SUM(Sell Value) trên Fact Investor Group Trading Snapshot với Investor Group Code = 'FOREIGN', Stock Type Name = 'Chứng chỉ quỹ', 'ETF' (Security Trading Snapshot Dimension), Market Id Code ∈ (STK, STX, UPX), trong kỳ | Reuse từ Nhóm 32 (K_VP_131) — Case 1; Case 1 — measure Sell Value; cùng measure nền với K_VP_5 (Nhóm 1); [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền) — O_VP_1 | READY |
| K_VP_132 | GT bán NĐTNN - TPDN niêm yết | VND | Cơ sở | SUM(Foreign Sell Value) trên Fact Listed Corporate Bond Snapshot trong kỳ; Foreign Sell Value = Σ giá trị lệnh có ký tự thứ 4 của số tài khoản bán ∈ ('E','F') | Reuse từ Nhóm 32 (K_VP_132) — Case 1; Case 1 — measure Foreign Sell Value; cùng measure nền với K_VP_77/79 (Nhóm 7) BA lỗi copy: điều kiện dòng này ghi theo phía MUA (`h.buy_account_number`) dù chỉ tiêu là GT bán — thiết kế theo ý định bán (O_VP_34). | READY |
| K_VP_133 | GT bán NĐTNN - TPDN riêng lẻ | VND | Cơ sở | SUM(Foreign Sell Value) trên Fact Private Corporate Bond Trading Snapshot trong kỳ; Foreign Sell Value = Σ giá trị lệnh có ký tự thứ 4 của số tài khoản bán ∈ ('E','F') | Reuse từ Nhóm 32 (K_VP_133) — Case 1; Case 1 — measure Foreign Sell Value; cùng measure nền với K_VP_94/96 (Nhóm 11) BA lỗi copy: điều kiện dòng này ghi theo phía MUA (row_path '…GIÁ TRỊ MUA') dù chỉ tiêu là GT bán — thiết kế theo ý định bán (O_VP_34). | READY |
| K_VP_134 | GT bán NĐTNN - TPCP | VND | Cơ sở | SUM(Foreign Sell Value) trên Fact Government Bond Trading Snapshot trong kỳ; Foreign Sell Value = Σ giá trị lệnh có ký tự thứ 4 của số tài khoản bán ∈ ('E','F') | Reuse từ Nhóm 32 (K_VP_134) — Case 1; Case 1 — measure Foreign Sell Value; cùng measure nền với K_VP_106/108 (Nhóm 14) BA lỗi copy: điều kiện dòng này ghi theo phía MUA (`buying_account_no`) dù chỉ tiêu là GT bán — thiết kế theo ý định bán (O_VP_34). | READY |
| K_VP_141 | GT bán NĐTNN - Giao dịch phái sinh | VND | Cơ sở | SUM(Sell Value) trên Fact Investor Group Trading Snapshot với Investor Group Code = 'FOREIGN', Market Id Code = 'DVX', Stock Type Name = 'Phái sinh', trong kỳ | Case 1 — measure Sell Value. [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền/phái sinh) — O_VP_1; cách tính GT phái sinh — O_VP_36 | READY |

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
        string Industry_Dimension_Id FK
        string Security_Symbol_Code
        string Market_Id_Code
        string Investor_Group_Code
        bigint Buy_Volume
        decimal Buy_Value
        bigint Sell_Volume
        decimal Sell_Value
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
    Fact_Government_Bond_Trading_Snapshot {
        string Government_Bond_Trading_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Order_Book_Type_Code
        bigint Trading_Volume
        decimal Trading_Value
        decimal Foreign_Buy_Value
        decimal Foreign_Sell_Value
    }
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Listed_Corporate_Bond_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Private_Corporate_Bond_Trading_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Government_Bond_Trading_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Security_Trading_Snapshot_Dimension["Security Trading Snapshot Dimension"]
        Fact_Investor_Group_Trading_Snapshot["Fact Investor Group Trading Snapshot"]
        Fact_Listed_Corporate_Bond_Snapshot["Fact Listed Corporate Bond Snapshot"]
        Fact_Private_Corporate_Bond_Trading_Snapshot["Fact Private Corporate Bond Trading Snapshot"]
        Fact_Government_Bond_Trading_Snapshot["Fact Government Bond Trading Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 34"]
        R1["K_VP_129,130,131,132,133,134,141: Mua/Bán ròng NĐTNN >> Chỉ tiêu tổng hợp"]
    end
    Calendar_Date_Dimension --> R1
    Security_Trading_Snapshot_Dimension --> R1
    Fact_Investor_Group_Trading_Snapshot --> R1
    Fact_Listed_Corporate_Bond_Snapshot --> R1
    Fact_Private_Corporate_Bond_Trading_Snapshot --> R1
    Fact_Government_Bond_Trading_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Security Trading Snapshot Dimension | 1 mã chứng khoán / hợp đồng phái sinh (SCD4A current-state); sở hữu bởi GSTT |
| Fact Investor Group Trading Snapshot | 1 mã chứng khoán / hợp đồng × 1 ngày giao dịch × 1 sàn (Market Id Code) × 1 nhóm NĐT (ALL / FOREIGN / PROPRIETARY); PK Investor Group Trading Snapshot Id = hash toàn bộ cột grain (Dạng B, A22) |
| Fact Listed Corporate Bond Snapshot | 1 mã trái phiếu (ISIN — Security Symbol Code) × 1 ngày giao dịch; PK Listed Corporate Bond Snapshot Id = hash (Snapshot Date Dimension Id, Security Symbol Code) (Dạng B, A22) |
| Fact Private Corporate Bond Trading Snapshot | 1 ngày báo cáo HNX09 (báo cáo ngày TPDN riêng lẻ, nguồn nộp ICP); PK Private Corporate Bond Trading Snapshot Id = hash (Snapshot Date Dimension Id) (Dạng B, A22) |
| Fact Government Bond Trading Snapshot | 1 ngày giao dịch × 1 loại sổ lệnh (Order Book Type Code ∈ OUTRIGHT, REPO); PK Government Bond Trading Snapshot Id = hash (Snapshot Date Dimension Id, Order Book Type Code) (Dạng B, A22) |

#### Nhóm 35 - Mua/Bán ròng NĐTNN >> Biểu đồ Giá trị mua/bán ròng cổ phiếu NĐTNN theo nhóm ngành

> Phân loại: **Phân tích**
> Atomic: tái dùng Fact VP đã thiết kế (Nhóm 1–16): `Fact Investor Group Trading Snapshot` (cổ phiếu/CCQ/chứng quyền/phái sinh — Sổ lệnh HNX/HOSE, **[!] O_VP_1**), `Fact Listed Corporate Bond Snapshot`, `Fact Private Corporate Bond Trading Snapshot`, `Fact Government Bond Trading Snapshot` — KHÔNG thêm bảng/cột Fact mới

> **[GHI CHÚ 2026-10-28 — O_VP_37, phương án thêm FK]** Fact Investor Group Trading Snapshot có thêm cột `Industry Dimension Id` (FK nullable, chỉ dòng cổ phiếu có ngành; CTCK/CTQLQ đại chúng = 07000) — không đổi grain/PK; flat denormalize `industry_code`/`industry_nm` như Fact TPDN niêm yết. Dev cần ETL + ALTER + nạp lại lịch sử.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (D/M/Q/Y) · Kỳ

| Chỉ tiêu | Kỳ báo cáo | Kỳ trước | % thay đổi |
|---|---|---|---|
| GT mua/bán ròng NĐTNN - Cổ phiếu theo Ngành | … | … | … |

> ⚠️ Presentation Grain: 1 dòng = 1 chỉ tiêu × 1 Kỳ, toàn thị trường, nhóm NĐT nước ngoài (Level 1); chiều 'Loại chứng khoán' chỉ cắt theo `Stock Type Name` (cổ phiếu) hoặc theo Fact (trái phiếu). Storage Grain: xem Bảng grain.

**Source:** `Fact Investor Group Trading Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Reuse từ Nhóm 1 (K_VP_1) — Case 1 | READY |
| K_VP_142 | Ngành | — | Chiều | Industry Dimension.Industry Code / Industry Name qua FK Industry Dimension Id của Fact nhóm NĐT; dòng không phải cổ phiếu hoặc không xác định được ngành → nhóm 'NA' (Chưa phân ngành) | Chiều — cột mới industry_dim_id của Fact (O_VP_37); cùng cách K_VP_84 (Nhóm 8) | READY |
| K_VP_143 | GT mua/bán ròng NĐTNN - Cổ phiếu | VND | Phái sinh | SUM(Buy Value) − SUM(Sell Value) trên Fact Investor Group Trading Snapshot với Investor Group Code = 'FOREIGN', Stock Type Name = 'Cổ phiếu', GROUP BY Industry (qua Industry Dimension Id của Fact) và kỳ | Case 2 — tính tại presentation layer; BA ghi 'Chỉ tiêu cơ sở' nhưng là mua − bán. [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền/phái sinh) — O_VP_1 | READY |

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
        string Industry_Dimension_Id FK
        string Security_Symbol_Code
        string Market_Id_Code
        string Investor_Group_Code
        bigint Buy_Volume
        decimal Buy_Value
        bigint Sell_Volume
        decimal Sell_Value
    }
    Industry_Dimension {
        string Industry_Dimension_Id PK
        string Industry_Code
        string Industry_Name
        string Source_System_Code
    }
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
    Industry_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Security_Trading_Snapshot_Dimension["Security Trading Snapshot Dimension"]
        Industry_Dimension["Industry Dimension"]
        Fact_Investor_Group_Trading_Snapshot["Fact Investor Group Trading Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 35"]
        R1["K_VP_1,142,143: Mua/Bán ròng NĐTNN >> Biểu đồ Giá trị mua/bán ròng cổ phiếu NĐTNN theo nhóm ngành"]
    end
    Calendar_Date_Dimension --> R1
    Security_Trading_Snapshot_Dimension --> R1
    Industry_Dimension --> R1
    Fact_Investor_Group_Trading_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Security Trading Snapshot Dimension | 1 mã chứng khoán / hợp đồng phái sinh (SCD4A current-state); sở hữu bởi GSTT |
| Industry Dimension | 1 ngành nghề kinh doanh cấp 1 hiện hành (SCD4A current-state); sở hữu bởi GSDC |
| Fact Investor Group Trading Snapshot | 1 mã chứng khoán / hợp đồng × 1 ngày giao dịch × 1 sàn (Market Id Code) × 1 nhóm NĐT (ALL / FOREIGN / PROPRIETARY); PK Investor Group Trading Snapshot Id = hash toàn bộ cột grain (Dạng B, A22) |

#### Nhóm 36 - Mua/Bán ròng NĐTNN >> Biểu đồ Giá trị giao dịch Cổ phiếu của NĐTNN

> Phân loại: **Phân tích**
> Atomic: tái dùng Fact VP đã thiết kế (Nhóm 1–16): `Fact Investor Group Trading Snapshot` (cổ phiếu/CCQ/chứng quyền/phái sinh — Sổ lệnh HNX/HOSE, **[!] O_VP_1**), `Fact Listed Corporate Bond Snapshot`, `Fact Private Corporate Bond Trading Snapshot`, `Fact Government Bond Trading Snapshot` — KHÔNG thêm bảng/cột Fact mới

> **[CẬP NHẬT 2026-10-29 — BA VP cập nhật SQL Nhóm 36, O_VP_43]** CTE `stock_daily_eod` (bản ghi cuối theo ngày) đổi thành `stock_portfolio` (bản ghi cuối mỗi symbol trong khoảng kỳ, `stocktype = '2'`), HNX nối `h.issue_code = s.symbolisin`. Mô tả BA và SQL đều chỉ **cổ phiếu** → K_VP_144–146 lọc `Stock Type Code` = '2'; thiết kế 2026-10-28 gộp thêm Chứng quyền / Chứng chỉ quỹ / ETF theo `Stock Type Name` là SAI phạm vi và đã bỏ.

> **[CẬP NHẬT 2026-11-02 — BA VP Nhóm 36, O_VP_54]** BA bổ sung `uat_mdds_stg.jad_stockinfor` vào Bảng nguồn dòng 412–414 và mô tả điều kiện loại chứng khoán (`stocktype = '2'`, bản ghi mới nhất mỗi symbol, nối `s.symbol = t.symbol` / `s.symbolisin = h.issue_code`) — đã có trong thiết kế theo O_VP_43; KHÔNG đổi KPI, công thức hay Fact. Số dòng BA đổi từ 407–410 sang 411–414. SQL tham khảo BA có lỗi (thiếu `UNION ALL` giữa 2 SELECT HOSE/HNX; nhãn quý dùng cột `period_fromdate` không tồn tại) — O_VP_54.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (D/M/Q/Y) · Kỳ

| Chỉ tiêu | Kỳ báo cáo | Kỳ trước | % thay đổi |
|---|---|---|---|
| GT mua NĐTNN | … | … | … |
| GT bán NĐTNN | … | … | … |
| GT ròng NĐTNN | … | … | … |

> ⚠️ Presentation Grain: 1 dòng = 1 chỉ tiêu × 1 Kỳ, toàn thị trường, nhóm NĐT nước ngoài (Level 1); phạm vi chỉ CỔ PHIẾU (`Stock Type Code` = '2'), không cắt thêm loại chứng khoán khác. Storage Grain: xem Bảng grain.

**Source:** `Fact Investor Group Trading Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Reuse từ Nhóm 1 (K_VP_1) — Case 1 | READY |
| K_VP_144 | GT mua NĐTNN | VND | Cơ sở | SUM(Buy Value) trên Fact Investor Group Trading Snapshot với Investor Group Code = 'FOREIGN', Stock Type Code = '2' (Cổ phiếu), GROUP BY kỳ | Case 1 — measure Buy Value; khác K_VP_119 (Nhóm 32: Σ 6 loại, Tại kỳ) ở phạm vi (chỉ cổ phiếu) và chuỗi kỳ. [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền/phái sinh) — O_VP_1 | READY |
| K_VP_145 | GT bán NĐTNN | VND | Cơ sở | SUM(Sell Value) trên Fact Investor Group Trading Snapshot với Investor Group Code = 'FOREIGN', Stock Type Code = '2' (Cổ phiếu), GROUP BY kỳ | Case 1 — measure Sell Value. [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền/phái sinh) — O_VP_1 | READY |
| K_VP_146 | GT ròng NĐTNN | VND | Phái sinh | Σ Buy Value − Σ Sell Value với Stock Type Code = '2' (Cổ phiếu), theo kỳ | Case 2 — tính tại presentation layer. [!] Nguồn Securities Trade (cổ phiếu/CCQ/chứng quyền/phái sinh) — O_VP_1 | READY |

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
        string Industry_Dimension_Id FK
        string Security_Symbol_Code
        string Market_Id_Code
        string Investor_Group_Code
        bigint Buy_Volume
        decimal Buy_Value
        bigint Sell_Volume
        decimal Sell_Value
    }
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Security_Trading_Snapshot_Dimension["Security Trading Snapshot Dimension"]
        Fact_Investor_Group_Trading_Snapshot["Fact Investor Group Trading Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 36"]
        R1["K_VP_1,144,145,146: Mua/Bán ròng NĐTNN >> Biểu đồ Giá trị giao dịch Cổ phiếu của NĐTNN"]
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

#### Nhóm 37 - Mua/Bán ròng NĐTNN >> Biểu đồ Giá trị giao dịch Trái phiếu của NĐTNN

> Phân loại: **Phân tích**
> Atomic: tái dùng Fact VP đã thiết kế (Nhóm 1–16): `Fact Investor Group Trading Snapshot` (cổ phiếu/CCQ/chứng quyền/phái sinh — Sổ lệnh HNX/HOSE, **[!] O_VP_1**), `Fact Listed Corporate Bond Snapshot`, `Fact Private Corporate Bond Trading Snapshot`, `Fact Government Bond Trading Snapshot` — KHÔNG thêm bảng/cột Fact mới

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (D/M/Q/Y) · Kỳ

| Chỉ tiêu | Kỳ báo cáo | Kỳ trước | % thay đổi |
|---|---|---|---|
| GT mua/bán ròng NĐTNN theo loại trái phiếu | … | … | … |
| GT mua/bán ròng NĐTNN - Tổng TP | … | … | … |

> ⚠️ Presentation Grain: 1 dòng = 1 chỉ tiêu × 1 Kỳ, toàn thị trường, nhóm NĐT nước ngoài (Level 1); chiều 'Loại chứng khoán' chỉ cắt theo `Stock Type Name` (cổ phiếu) hoặc theo Fact (trái phiếu). Storage Grain: xem Bảng grain.

**Source:** `Fact Listed Corporate Bond Snapshot`, `Fact Private Corporate Bond Trading Snapshot`, `Fact Government Bond Trading Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_1 | Kỳ | — | Chiều | Calendar Date Dimension: Calendar Date → ngày/tháng/quý/năm; Loại kỳ (D/M/Q/Y) và Từ kỳ — Đến kỳ là tham số lọc | Reuse từ Nhóm 1 (K_VP_1) — Case 1 | READY |
| K_VP_147 | Loại chứng khoán | — | Chiều | Nhãn theo Fact nguồn: TPDN niêm yết / TPDN riêng lẻ / TPCP (Tổng TP = không lọc loại) | Chiều suy từ Fact nguồn — O_VP_35; BA dòng 418 (Done): stocktype = '1' → TPDN niêm yết, báo cáo HNX09 → TPDN riêng lẻ, sổ lệnh outright/repo → TPCP | READY |
| K_VP_148 | GT mua NĐTNN - TPDN niêm yết | VND | Cơ sở | SUM(Foreign Buy Value) trên Fact Listed Corporate Bond Snapshot trong kỳ; Foreign Buy Value = Σ giá trị lệnh có ký tự thứ 4 của số tài khoản mua ∈ ('E','F') và GROUP BY kỳ | Case 1 — measure Foreign Buy Value; cùng measure nền với K_VP_77/79 (Nhóm 7), khác chuỗi kỳ | READY |
| K_VP_149 | GT bán NĐTNN - TPDN niêm yết | VND | Cơ sở | SUM(Foreign Sell Value) trên Fact Listed Corporate Bond Snapshot trong kỳ; Foreign Sell Value = Σ giá trị lệnh có ký tự thứ 4 của số tài khoản bán ∈ ('E','F') và GROUP BY kỳ | Case 1 — measure Foreign Sell Value; cùng measure nền với K_VP_77/79 (Nhóm 7), khác chuỗi kỳ | READY |
| K_VP_150 | GT ròng NĐTNN - TPDN niêm yết | VND | Phái sinh | Σ Foreign Buy Value − Σ Foreign Sell Value trên Fact Listed Corporate Bond Snapshot theo kỳ | Case 2 — tính tại presentation layer từ K_VP_148/K_VP_149 | READY |
| K_VP_151 | GT mua NĐTNN - TPDN riêng lẻ | VND | Cơ sở | SUM(Foreign Buy Value) trên Fact Private Corporate Bond Trading Snapshot trong kỳ; Foreign Buy Value = Σ giá trị lệnh có ký tự thứ 4 của số tài khoản mua ∈ ('E','F') và GROUP BY kỳ | Case 1 — measure Foreign Buy Value; cùng measure nền với K_VP_94/96 (Nhóm 11), khác chuỗi kỳ | READY |
| K_VP_152 | GT bán NĐTNN - TPDN riêng lẻ | VND | Cơ sở | SUM(Foreign Sell Value) trên Fact Private Corporate Bond Trading Snapshot trong kỳ; Foreign Sell Value = Σ giá trị lệnh có ký tự thứ 4 của số tài khoản bán ∈ ('E','F') và GROUP BY kỳ | Case 1 — measure Foreign Sell Value; cùng measure nền với K_VP_94/96 (Nhóm 11), khác chuỗi kỳ | READY |
| K_VP_153 | GT ròng NĐTNN - TPDN riêng lẻ | VND | Phái sinh | Σ Foreign Buy Value − Σ Foreign Sell Value trên Fact Private Corporate Bond Trading Snapshot theo kỳ | Case 2 — tính tại presentation layer từ K_VP_151/K_VP_152 | READY |
| K_VP_154 | GT mua NĐTNN - TPCP | VND | Cơ sở | SUM(Foreign Buy Value) trên Fact Government Bond Trading Snapshot trong kỳ; Foreign Buy Value = Σ giá trị lệnh có ký tự thứ 4 của số tài khoản mua ∈ ('E','F') và GROUP BY kỳ | Case 1 — measure Foreign Buy Value; cùng measure nền với K_VP_106/108 (Nhóm 14), khác chuỗi kỳ | READY |
| K_VP_155 | GT bán NĐTNN - TPCP | VND | Cơ sở | SUM(Foreign Sell Value) trên Fact Government Bond Trading Snapshot trong kỳ; Foreign Sell Value = Σ giá trị lệnh có ký tự thứ 4 của số tài khoản bán ∈ ('E','F') và GROUP BY kỳ | Case 1 — measure Foreign Sell Value; cùng measure nền với K_VP_106/108 (Nhóm 14), khác chuỗi kỳ | READY |
| K_VP_156 | GT ròng NĐTNN - TPCP | VND | Phái sinh | Σ Foreign Buy Value − Σ Foreign Sell Value trên Fact Government Bond Trading Snapshot theo kỳ | Case 2 — tính tại presentation layer từ K_VP_154/K_VP_155 | READY |
| K_VP_157 | GT mua NĐTNN - Tổng TP | VND | Phái sinh | Σ GT mua NĐTNN của 3 loại trái phiếu theo kỳ (Σ Foreign Buy/Sell Value của 3 Fact trái phiếu) | Case 2 — cộng 3 chỉ tiêu cơ sở theo loại; tính tại presentation layer | READY |
| K_VP_158 | GT bán NĐTNN - Tổng TP | VND | Phái sinh | Σ GT bán NĐTNN của 3 loại trái phiếu theo kỳ (Σ Foreign Buy/Sell Value của 3 Fact trái phiếu) | Case 2 — cộng 3 chỉ tiêu cơ sở theo loại; tính tại presentation layer | READY |
| K_VP_159 | GT ròng NĐTNN - Tổng TP | VND | Phái sinh | GT mua − GT bán NĐTNN của 3 loại trái phiếu theo kỳ (Σ Foreign Buy/Sell Value của 3 Fact trái phiếu) | Case 2 — cộng 3 chỉ tiêu cơ sở theo loại; tính tại presentation layer | READY |

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
    Fact_Government_Bond_Trading_Snapshot {
        string Government_Bond_Trading_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Order_Book_Type_Code
        bigint Trading_Volume
        decimal Trading_Value
        decimal Foreign_Buy_Value
        decimal Foreign_Sell_Value
    }
    Calendar_Date_Dimension ||--o{ Fact_Listed_Corporate_Bond_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Private_Corporate_Bond_Trading_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Government_Bond_Trading_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Listed_Corporate_Bond_Snapshot["Fact Listed Corporate Bond Snapshot"]
        Fact_Private_Corporate_Bond_Trading_Snapshot["Fact Private Corporate Bond Trading Snapshot"]
        Fact_Government_Bond_Trading_Snapshot["Fact Government Bond Trading Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 37"]
        R1["K_VP_1,147,148,149,150,151,152,153,154,155,156,157,158,159: Mua/Bán ròng NĐTNN >> Biểu đồ Giá trị giao dịch Trái phiếu của NĐTNN"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Listed_Corporate_Bond_Snapshot --> R1
    Fact_Private_Corporate_Bond_Trading_Snapshot --> R1
    Fact_Government_Bond_Trading_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Listed Corporate Bond Snapshot | 1 mã trái phiếu (ISIN — Security Symbol Code) × 1 ngày giao dịch; PK Listed Corporate Bond Snapshot Id = hash (Snapshot Date Dimension Id, Security Symbol Code) (Dạng B, A22) |
| Fact Private Corporate Bond Trading Snapshot | 1 ngày báo cáo HNX09 (báo cáo ngày TPDN riêng lẻ, nguồn nộp ICP); PK Private Corporate Bond Trading Snapshot Id = hash (Snapshot Date Dimension Id) (Dạng B, A22) |
| Fact Government Bond Trading Snapshot | 1 ngày giao dịch × 1 loại sổ lệnh (Order Book Type Code ∈ OUTRIGHT, REPO); PK Government Bond Trading Snapshot Id = hash (Snapshot Date Dimension Id, Order Book Type Code) (Dạng B, A22) |

#### Nhóm 38 - Dòng tiền NĐTNN >> Chỉ tiêu tổng hợp

> Phân loại: **Phân tích**
> Atomic: `Foreign Investor Report Value` (`fir_value`) + `Foreign Investor Report Structure` (`fir_structure`) + `Foreign Investor Report` (`foreign_investor_report`) ← FIMS báo cáo IBOU9 (PLIV-TT51), dòng 'Tổng= (1) + (2)' — **READY** (Fact mới `Fact Foreign Capital Flow Summary Snapshot`; không phụ thuộc Securities Trade)

**[GHI CHÚ 2026-11-05 — BA VP mapping Nhóm 38/39 từ FIMS IBOU9]** BA chuyển Nhóm 38 (8 dòng, 431–438) và Nhóm 39 (4 dòng, 439–442) sang báo cáo FIMS `IBOU9` — 'Báo cáo hoạt động chu chuyển vốn của NĐTNN' (PLIV-TT51/2021/TT-BTC), `uat_fims_ods.fir_value`, dòng `row_path = 'Tổng= (1) + (2)'`, 3 cột USD (vào ròng (+/-), ngoại tệ đổi sang VND, VND đổi ra ngoại tệ), kỳ nửa tháng (`period_type = 'NUA_THANG'`), lấy bản nộp mới nhất của từng TVLK trong kỳ. Data Modeler chọn 2026-11-05: Fact VP mới `Fact Foreign Capital Flow Summary Snapshot` (grain 1 TVLK × 1 kỳ nửa tháng, khử trùng ở ETL) — không dùng `fct_foreign_investor_report_value` (NDTNN, thiếu `reporting_entity_code` nên không khử trùng theo TVLK được) và không dùng `fct_foreign_investor_capital_flow_snpst` (Data Explorer, bỏ dòng tổng, chỉ 1 chỉ tiêu). Giả định cần dev xác nhận: O_VP_60.

**[CẬP NHẬT 2026-11-08 — BA đổi quy tắc kỳ nửa tháng]** ODS `uat_fims_ods.fir_value` đổi giá trị `period_value` của kỳ `NUA_THANG`; BA (dòng 386 Nhóm 38, dòng 394 Nhóm 39) đổi cách xác định nửa đầu/nửa cuối tháng: nửa đầu `SUBSTR(period_value, 1, 2) = 'DT'`, nửa cuối `SUBSTR(period_value, 1, 2) = 'CT'` (trước đó `SUBSTR(period_value, 3, 2) <= 15` theo định dạng NT01..NT31); nhãn HM = `yyyy-MM` của ngày báo cáo + `-H1`/`-H2` (không đổi). Đã cập nhật K_VP_288 (Detail Mapping) và mô tả `period_val` của Fact. `period_value` mới có dạng 'DT'/'CT' + 'MM/YYYY' (vd `DT04/2026`) nên đã mang tháng và năm của kỳ; đã kiểm trên ODS 2026-11-08: 16 giá trị cho 10 tháng, tháng trong `period_value` luôn trùng tháng của `day_report`, 135 khóa (`reporting_entity_code`, `rpt_year`, `period_val`) không khóa nào gộp nhiều tháng và Fact đã nạp 135 dòng. Khóa khử trùng và PK của Fact theo quyết định 2026-11-05 vì vậy đủ phân biệt kỳ — giữ nguyên, không thêm tháng của `rpt_day` vào khóa — O_VP_65.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (Nửa tháng / Tháng / Quý / Năm) · Kỳ

| Chỉ tiêu | Kỳ tra cứu | % so với kỳ trước | YTD |
|---|---|---|---|
| Vào ròng/Rút ròng (USD) | … | … | … |
| Dòng tiền vào (USD) | … | … | — |
| Dòng tiền ra (USD) | … | … | — |

> ⚠️ Presentation Grain: 1 dòng = 1 chỉ tiêu (vào ròng, dòng tiền vào, dòng tiền ra) tại 1 kỳ (nửa tháng / tháng / quý / năm), toàn thị trường. Storage Grain: xem Bảng grain — mịn hơn (TVLK × kỳ nửa tháng), đạt Iso-Grain.

**Source:** `Fact Foreign Capital Flow Summary Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_288 | Kỳ | — | Chiều | Calendar Date Dimension + Period Value: nhãn kỳ theo loại kỳ HM / M / Q / Y (nửa tháng yyyy-MM-H1/H2, tháng yyyy-MM, quý yyyy-Qn, năm yyyy) | BA dòng 431 (Tại kỳ; có thêm loại Nửa tháng) — Case 1, dùng lại Calendar Date Dimension; H1/H2 suy từ `period_val` như BA: `SUBSTR(period_val, 1, 2)` = 'DT' → H1, 'CT' → H2 (quy tắc mới 2026-11-08) — O_VP_60, O_VP_65 | READY |
| K_VP_289 | Vào ròng/Rút ròng YTD (USD) | USD | Cơ sở | SUM(Capital Flow Net Value) các kỳ từ kỳ đầu năm đến hết kỳ tra cứu | Case 1 — measure Capital Flow Net Value; BA dòng 432 'Trùng'; ô nguồn `Giá trị dòng vốn vào trong kỳ báo cáo (+/-) (đơn vị USD)` | READY |
| K_VP_290 | Vào ròng/Rút ròng (USD) | USD | Cơ sở | SUM(Capital Flow Net Value) của kỳ tra cứu | Case 1 — đọc nguyên ô (+/−) của báo cáo IBOU9 (không tính vào − ra); BA dòng 433 | READY |
| K_VP_291 | Vào ròng/Rút ròng - % thay đổi so với kỳ trước | % | Phái sinh | (Vào ròng/Rút ròng kỳ này − kỳ trước) / kỳ trước × 100 | Case 2 — từ K_VP_290 tại 2 kỳ; mẫu số có thể âm, theo BA không lấy trị tuyệt đối — O_VP_60; BA dòng 434 'Trùng' | READY |
| K_VP_292 | Dòng tiền vào (USD) | USD | Cơ sở | SUM(Capital Inflow Value) của kỳ tra cứu | Case 1 — ô `Tổng giá trị ngoại tệ đổi sang VND trong kỳ báo cáo (đơn vị USD)`; BA dòng 435 | READY |
| K_VP_293 | Dòng tiền vào - % thay đổi so với kỳ trước | % | Phái sinh | (Dòng tiền vào kỳ này − kỳ trước) / kỳ trước × 100 | Case 2 — từ K_VP_292 tại 2 kỳ; BA dòng 436 'Trùng' | READY |
| K_VP_294 | Dòng tiền ra (USD) | USD | Cơ sở | SUM(Capital Outflow Value) của kỳ tra cứu | Case 1 — ô `Tổng giá trị VND đổi ra ngoại tệ và chuyển ra trong kỳ báo cáo (đơn vị USD)`; BA dòng 437 | READY |
| K_VP_295 | Dòng tiền ra - % thay đổi so với kỳ trước | % | Phái sinh | (Dòng tiền ra kỳ này − kỳ trước) / kỳ trước × 100 | Case 2 — từ K_VP_294 tại 2 kỳ; BA dòng 438 'Trùng' | READY |

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
    Fact_Foreign_Capital_Flow_Summary_Snapshot {
        string Foreign_Capital_Flow_Summary_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Reporting_Entity_Code
        string Period_Value
        int Report_Year
        decimal Capital_Flow_Net_Value
        decimal Capital_Inflow_Value
        decimal Capital_Outflow_Value
    }
    Calendar_Date_Dimension ||--o{ Fact_Foreign_Capital_Flow_Summary_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Foreign_Capital_Flow_Summary_Snapshot["Fact Foreign Capital Flow Summary Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 38"]
        R1["K_VP_288–295: Dòng tiền NĐTNN: chỉ tiêu tổng hợp"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Foreign_Capital_Flow_Summary_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Foreign Capital Flow Summary Snapshot | 1 TVLK nộp báo cáo IBOU9 (Reporting Entity Code) × 1 kỳ báo cáo nửa tháng (Period Value, Report Year); PK Foreign Capital Flow Summary Snapshot Id = hash (Reporting Entity Code, Period Value, Report Year, Source System Code) (Dạng B, A22); bản nộp mới nhất của kỳ ghi đè |

#### Nhóm 39 - Dòng tiền NĐTNN >> Biểu đồ thống kê dòng tiền vào/ra của NĐTNN theo thời gian

> Phân loại: **Phân tích**
> Atomic: `Foreign Investor Report Value` + `Foreign Investor Report Structure` + `Foreign Investor Report` ← FIMS IBOU9 — **READY** (dùng lại `Fact Foreign Capital Flow Summary Snapshot` của Nhóm 38, Case 1)

**[GHI CHÚ 2026-11-05 — BA VP mapping Nhóm 39]** BA 439–442 (4 dòng: Kỳ + 3 chỉ tiêu) cùng nguồn và quy tắc khử trùng với Nhóm 38 (FIMS IBOU9, dòng 'Tổng= (1) + (2)'), theo chuỗi kỳ 'Từ kỳ - Đến kỳ'; cả 4 dòng 'Đánh giá: Trùng' theo tên Nhóm 38 nhưng khác ngữ nghĩa thời gian → KPI riêng. Giả định: O_VP_60.

**[CẬP NHẬT 2026-11-08]** Nhãn H1/H2 của Kỳ theo quy tắc mới như Nhóm 38: `SUBSTR(period_value, 1, 2)` = 'DT' (nửa đầu) / 'CT' (nửa cuối), BA dòng 394 đổi cùng đợt vì ODS `fir_value` đổi `period_value` kỳ NUA_THANG — O_VP_65.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (Nửa tháng / Tháng / Quý / Năm) · Từ kỳ — Đến kỳ

| Kỳ | Vào ròng/Rút ròng (USD) | Dòng tiền vào (USD) | Dòng tiền ra (USD) |
|---|---|---|---|
| 2026-09-H1 | … | … | … |
| 2026-09-H2 | … | … | … |

> ⚠️ Presentation Grain: 1 điểm biểu đồ = 1 kỳ (nửa tháng / tháng / quý / năm), toàn thị trường. Storage Grain: xem Bảng grain — mịn hơn (TVLK × kỳ nửa tháng), đạt Iso-Grain.

**Source:** `Fact Foreign Capital Flow Summary Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_296 | Kỳ | — | Chiều | Calendar Date Dimension + Period Value: chuỗi kỳ HM / M / Q / Y trong khoảng Từ kỳ — Đến kỳ | Tham số lọc 'Từ kỳ - Đến kỳ' (BA dòng 439, 'Trùng' theo tên K_VP_288 nhưng khác 'Tại kỳ'); Case 1 reuse Calendar Date Dimension; nhãn H1/H2 theo quy tắc DT/CT mới của K_VP_288 — O_VP_60, O_VP_65 | READY |
| K_VP_297 | Vào ròng/Rút ròng (USD) | USD | Cơ sở | SUM(Capital Flow Net Value) theo từng kỳ trong khoảng Từ kỳ — Đến kỳ | Case 1 — như K_VP_290 nhưng theo chuỗi kỳ; BA dòng 440 'Trùng' | READY |
| K_VP_298 | Dòng tiền vào (USD) | USD | Cơ sở | SUM(Capital Inflow Value) theo từng kỳ trong khoảng Từ kỳ — Đến kỳ | Case 1 — như K_VP_292 nhưng theo chuỗi kỳ; BA dòng 441 'Trùng' | READY |
| K_VP_299 | Dòng tiền ra (USD) | USD | Cơ sở | SUM(Capital Outflow Value) theo từng kỳ trong khoảng Từ kỳ — Đến kỳ | Case 1 — như K_VP_294 nhưng theo chuỗi kỳ; BA dòng 442 'Trùng' | READY |

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
    Fact_Foreign_Capital_Flow_Summary_Snapshot {
        string Foreign_Capital_Flow_Summary_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Reporting_Entity_Code
        string Period_Value
        int Report_Year
        decimal Capital_Flow_Net_Value
        decimal Capital_Inflow_Value
        decimal Capital_Outflow_Value
    }
    Calendar_Date_Dimension ||--o{ Fact_Foreign_Capital_Flow_Summary_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Foreign_Capital_Flow_Summary_Snapshot["Fact Foreign Capital Flow Summary Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 39"]
        R1["K_VP_296–299: Dòng tiền NĐTNN: biểu đồ theo thời gian"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Foreign_Capital_Flow_Summary_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Foreign Capital Flow Summary Snapshot | 1 TVLK nộp báo cáo IBOU9 (Reporting Entity Code) × 1 kỳ báo cáo nửa tháng (Period Value, Report Year); PK Foreign Capital Flow Summary Snapshot Id = hash (Reporting Entity Code, Period Value, Report Year, Source System Code) (Dạng B, A22); bản nộp mới nhất của kỳ ghi đè |

#### Nhóm 40 - Chỉ tiêu tổng hợp - Thị trường cơ sở

> Phân loại: **Phân tích**
> Atomic: `Open Investor Account` ← VSDC.OPEN_INVESTORS, `Closed Investor Account` ← VSDC.CLOSED_INVESTORS — **READY** (Fact mới `Fact Investor Account Movement Snapshot`; nguồn VSDC, KHÔNG phụ thuộc Securities Trade)

**[GHI CHÚ 2026-10-29 — BA VP mapping cụm Tài khoản giao dịch (Nhóm 40, 42, 43) từ VSDC]** Nguồn `VSDC.OPEN_INVESTORS` / `VSDC.CLOSED_INVESTORS` (Atomic `open_investor_account` / `closed_investor_account`): Fact mới `Fact Investor Account Movement Snapshot` gộp 2 nguồn theo (ngày phát sinh, loại NĐT) với số TK mở và số TK đóng; số TK lũy kế = Σ mở − Σ đóng đến ngày (đúng công thức BA `COUNT(o.trading_account_no) − COUNT(c.trading_account_no)`). BA 'Trùng' ở một số dòng không nêu trùng với chỉ tiêu nào; các KPI Nhóm 42/43 trùng TÊN với Nhóm 40 nhưng khác ngữ nghĩa thời gian (chuỗi kỳ chứ không phải một kỳ) nên KPI riêng — Δ số lượng BA ↔ HLD ở Gate 10 là CÓ CHỦ Ý. Giả định và mâu thuẫn BA ở O_VP_46; Nhóm 41/44 (tài khoản phái sinh từ biểu mẫu BM 45_TTLK_01) BA chưa mapping — O_VP_47.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (D/M/Q/Y) · Kỳ báo cáo

| Chỉ tiêu | Tổng | Cá nhân trong nước | Cá nhân nước ngoài | Tổ chức trong nước | Tổ chức nước ngoài |
|---|---|---|---|---|---|
| Tổng số tài khoản (+ % so với cuối kỳ trước, % so với cuối năm trước) | … | … | … | … | … |
| SL TK mới (+ % so với kỳ trước, % so với cùng kỳ năm trước) | … | | | | |
| SL TK đóng (+ % so với kỳ trước, % so với cùng kỳ năm trước) | … | | | | |

> ⚠️ Presentation Grain: 1 ô = 1 chỉ tiêu × 1 loại NĐT × 1 kỳ báo cáo (Level 2). Storage Grain: Fact Investor Account Movement Snapshot = 1 ngày phát sinh × 1 loại NĐT (Level 2) — mịn hơn kỳ, đạt Iso-Grain.

**Source:** `Fact Investor Account Movement Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_212 | Kỳ | — | Chiều | Calendar Date Dimension: ngày/tháng/quý/năm của kỳ báo cáo; kỳ trước, cùng kỳ năm trước và cuối năm trước suy từ tham số kỳ | Tham số lọc 'Tại kỳ' — loại kỳ D/M/Q/Y + kỳ báo cáo (BA dòng 436) | READY |
| K_VP_213 | Loại nhà đầu tư | — | Chiều | Fact Investor Account Movement Snapshot.Investor Type Code → nhãn: 3 Cá nhân trong nước, 4 Cá nhân nước ngoài, 5 Pháp nhân trong nước, 6 Pháp nhân nước ngoài, 7 Nhà nước, khác → 'Khác' | Chiều Loại NĐT; BA chỉ có KPI cho 4 loại (không có Nhà nước) | READY |
| K_VP_214 | Tổng số tài khoản | TK | Cơ sở | Σ Open Account Count − Σ Close Account Count trên Fact Investor Account Movement Snapshot với ngày ≤ ngày cuối kỳ báo cáo (mọi loại NĐT) | Case 2 — lũy kế từ mở − đóng (O_VP_46) | READY |
| K_VP_215 | Tổng số tài khoản - % so với cuối kỳ trước | % | Phái sinh | (Tổng số TK cuối kỳ báo cáo − Tổng số TK cuối kỳ trước) / Tổng số TK cuối kỳ trước × 100 | Case 2 — BA Mô tả ghi 'cuối tháng trước', SQL dùng cuối kỳ trước (theo SQL) | READY |
| K_VP_216 | Tổng số tài khoản - % so với cuối năm trước | % | Phái sinh | (Tổng số TK cuối kỳ báo cáo − Tổng số TK ngày 31/12 năm trước) / Tổng số TK ngày 31/12 năm trước × 100 | Case 2 | READY |
| K_VP_217 | SL TK mới | TK | Cơ sở | SUM(Open Account Count) trên Fact Investor Account Movement Snapshot với ngày trong kỳ báo cáo (mọi loại NĐT) | Case 1 — measure Open Account Count | READY |
| K_VP_218 | SL TK mới - % so với kỳ trước | % | Cơ sở | (SL TK mới kỳ báo cáo − SL TK mới kỳ trước) / SL TK mới kỳ trước × 100 | Case 2 | READY |
| K_VP_219 | SL TK mới - % so với cùng kỳ năm trước | % | Cơ sở | (SL TK mới kỳ báo cáo − SL TK mới cùng kỳ năm trước) / SL TK mới cùng kỳ năm trước × 100 | Case 2 | READY |
| K_VP_220 | SL TK đóng | TK | Cơ sở | SUM(Close Account Count) trên Fact Investor Account Movement Snapshot với ngày trong kỳ báo cáo (mọi loại NĐT) | Case 1 — measure Close Account Count | READY |
| K_VP_221 | SL TK đóng - % so với kỳ trước | % | Cơ sở | (SL TK đóng kỳ báo cáo − SL TK đóng kỳ trước) / SL TK đóng kỳ trước × 100 | Case 2 | READY |
| K_VP_222 | SL TK đóng - % so với cùng kỳ năm trước | % | Cơ sở | (SL TK đóng kỳ báo cáo − SL TK đóng cùng kỳ năm trước) / SL TK đóng cùng kỳ năm trước × 100 | Case 2 | READY |
| K_VP_223 | Tổng số tài khoản - Cá nhân trong nước | TK | Cơ sở | Σ Open Account Count − Σ Close Account Count với Investor Type Code = '3' (Cá nhân trong nước), ngày ≤ ngày cuối kỳ báo cáo | Case 2 — K_VP_214 lọc loại NĐT | READY |
| K_VP_224 | Tổng số tài khoản - Cá nhân trong nước - % so với cuối kỳ trước | % | Phái sinh | % thay đổi số TK Cá nhân trong nước so với cuối kỳ trước | Case 2 — K_VP_215 lọc loại NĐT | READY |
| K_VP_225 | Tổng số tài khoản - Cá nhân trong nước - % so với cuối năm trước | % | Phái sinh | % thay đổi số TK Cá nhân trong nước so với cuối năm trước | Case 2 — K_VP_216 lọc loại NĐT | READY |
| K_VP_226 | Tổng số tài khoản - Cá nhân nước ngoài | TK | Cơ sở | Σ Open Account Count − Σ Close Account Count với Investor Type Code = '4' (Cá nhân nước ngoài), ngày ≤ ngày cuối kỳ báo cáo | Case 2 — K_VP_214 lọc loại NĐT | READY |
| K_VP_227 | Tổng số tài khoản - Cá nhân nước ngoài - % so với cuối kỳ trước | % | Phái sinh | % thay đổi số TK Cá nhân nước ngoài so với cuối kỳ trước | Case 2 — K_VP_215 lọc loại NĐT | READY |
| K_VP_228 | Tổng số tài khoản - Cá nhân nước ngoài - % so với cuối năm trước | % | Phái sinh | % thay đổi số TK Cá nhân nước ngoài so với cuối năm trước | Case 2 — K_VP_216 lọc loại NĐT | READY |
| K_VP_229 | Tổng số tài khoản - Tổ chức trong nước | TK | Cơ sở | Σ Open Account Count − Σ Close Account Count với Investor Type Code = '5' (Tổ chức trong nước), ngày ≤ ngày cuối kỳ báo cáo | Case 2 — K_VP_214 lọc loại NĐT | READY |
| K_VP_230 | Tổng số tài khoản - Tổ chức trong nước - % so với cuối kỳ trước | % | Phái sinh | % thay đổi số TK Tổ chức trong nước so với cuối kỳ trước | Case 2 — K_VP_215 lọc loại NĐT | READY |
| K_VP_231 | Tổng số tài khoản - Tổ chức trong nước - % so với cuối năm trước | % | Phái sinh | % thay đổi số TK Tổ chức trong nước so với cuối năm trước | Case 2 — K_VP_216 lọc loại NĐT | READY |
| K_VP_232 | Tổng số tài khoản - Tổ chức nước ngoài | TK | Cơ sở | Σ Open Account Count − Σ Close Account Count với Investor Type Code = '6' (Tổ chức nước ngoài), ngày ≤ ngày cuối kỳ báo cáo | Case 2 — K_VP_214 lọc loại NĐT | READY |
| K_VP_233 | Tổng số tài khoản - Tổ chức nước ngoài - % so với cuối kỳ trước | % | Phái sinh | % thay đổi số TK Tổ chức nước ngoài so với cuối kỳ trước | Case 2 — K_VP_215 lọc loại NĐT | READY |
| K_VP_234 | Tổng số tài khoản - Tổ chức nước ngoài - % so với cuối năm trước | % | Phái sinh | % thay đổi số TK Tổ chức nước ngoài so với cuối năm trước | Case 2 — K_VP_216 lọc loại NĐT | READY |

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
    Fact_Investor_Account_Movement_Snapshot {
        string Investor_Account_Movement_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Investor_Type_Code
        int Open_Account_Count
        int Close_Account_Count
    }
    Calendar_Date_Dimension ||--o{ Fact_Investor_Account_Movement_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Investor_Account_Movement_Snapshot["Fact Investor Account Movement Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 40"]
        R1["K_VP_212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234: Tài khoản giao dịch: chỉ tiêu tổng hợp thị trường cơ sở"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Investor_Account_Movement_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Investor Account Movement Snapshot | 1 ngày phát sinh (ngày mở hoặc ngày đóng tài khoản) × 1 loại NĐT VSDC (3–7, NA); PK Investor Account Movement Snapshot Id = hash (Snapshot Date Dimension Id, Investor Type Code) (Dạng B, A22); dựng lại toàn bộ mỗi lần chạy |

#### Nhóm 41 - Chỉ tiêu tổng hợp - Thị trường phái sinh

> Phân loại: **Phân tích**
> Atomic: `Internal Statistical Report` (`internal_statistical_report`) ← ISS báo cáo `TTLK01_1` (Tài khoản phái sinh, `uat_iss_ods.flat_report`) — **READY** một phần (Fact mới `Fact Derivatives Account Snapshot`; 11/30 dòng BA có nguồn, 19 dòng 'không có dữ liệu' PENDING Nhóm 2)

**[GHI CHÚ 2026-11-05 — BA VP mapping Nhóm 41 (Thị trường phái sinh)]** BA đóng O_VP_47: Nhóm 41 từ 8 lên 30 dòng (BA 466–495), nguồn chuyển từ biểu mẫu VSDC 'BM 45_TTLK_01' sang ISS `TTLK01_1`; 11 dòng có nguồn (Kỳ, Phân loại trong nước / nước ngoài, Tổng số TK, Trong nước, Nước ngoài và các dòng % của chúng), 19 dòng 'Không có dữ liệu, trên chart hiển thị N/A' (Loại nhà đầu tư, TK mới/đóng, Trong nước/Nước ngoài × Cá nhân/Tổ chức) — mỗi dòng có KPI riêng PENDING [Nhóm 2] (O_VP_59). Các dòng % mang 'Đánh giá: Trùng' nhưng không nêu trùng với chỉ tiêu nào → thiết kế KPI riêng khớp từng dòng BA (như Nhóm 19/40). Fact mới `Fact Derivatives Account Snapshot` (grain 1 dòng báo cáo × 1 tháng, Data Modeler chọn 2026-11-05); giả định cần dev xác nhận: O_VP_58.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (Tháng / Quý / Năm) · Kỳ

| Chỉ tiêu | Tổng | Trong nước | Nước ngoài |
|---|---|---|---|
| Số TK phái sinh cuối kỳ | … | … | … |
| % so với kỳ trước | … | … | … |
| % so với cuối năm trước | … | … | … |
| SL TK mới / đóng; Cá nhân / Tổ chức | N/A | N/A | N/A |

> ⚠️ Presentation Grain: 1 dòng = 1 chỉ tiêu (tổng / trong nước / nước ngoài) tại 1 kỳ (tháng / quý / năm). Storage Grain: xem Bảng grain — 1 dòng báo cáo × 1 tháng, mịn hơn hoặc bằng, đạt Iso-Grain.

**Source:** `Fact Derivatives Account Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_300 | Kỳ | — | Chiều | Calendar Date Dimension: kỳ tra cứu M / Q / Y (kỳ Ngày không có dữ liệu) | BA dòng 466 ('Tại kỳ'); Case 1 reuse Calendar Date Dimension — O_VP_58 | READY |
| K_VP_301 | Phân loại trong nước / nước ngoài | — | Chiều | Trong nước ↔ Domestic Account Quantity (cột `SỐ LƯỢNG CUỐI KỲ > TRONG NƯỚC`); Nước ngoài ↔ Foreign Account Quantity (cột `SỐ LƯỢNG CUỐI KỲ > NƯỚC NGOÀI`) | BA dòng 467; chiều biểu diễn bằng 2 cột đo của Fact (mỗi giá trị chiều ↔ 1 cột), không có cột phân loại — O_VP_58 | READY |
| K_VP_302 | Loại nhà đầu tư | — | Chiều | Nhãn Cá nhân / Tổ chức | **Lý do pending:** [Nhóm 2 - Chưa có mapping nguồn từ BA]: BA dòng 468 'Trạng thái mapping = Done' nhưng Trường nguồn NULL, Điều kiện 'Không có dữ liệu, trên chart hiển thị N/A'; TTLK01_1 chỉ có 3 cột TỔNG CỘNG / TRONG NƯỚC / NƯỚC NGOÀI, xem O_VP_59. **Atomic cần bổ sung:** TBD. **Mart dự kiến:** Fact Derivatives Account Snapshot — thêm cột phân loại hoặc cột đo theo loại NĐT | PENDING [Nhóm 2 - Chưa có mapping nguồn từ BA] |
| K_VP_303 | Tổng số tài khoản phái sinh | TK | Cơ sở | Total Account Quantity tại tháng báo cáo mới nhất có dữ liệu trong kỳ tra cứu | Case 1 — measure Total Account Quantity; BA dòng 469; ô `TỔNG CỘNG` của TTLK01_1 — O_VP_58 | READY |
| K_VP_304 | Tổng số tài khoản phái sinh - % so với kỳ trước | % | Phái sinh | (K_VP_303 kỳ tra cứu − K_VP_303 cuối kỳ trước) / K_VP_303 cuối kỳ trước × 100 | Case 2 — từ K_VP_303 tại 2 mốc; BA dòng 470 'Trùng' | READY |
| K_VP_305 | Tổng số tài khoản phái sinh - % so với cuối năm trước | % | Phái sinh | (K_VP_303 kỳ tra cứu − K_VP_303 cuối năm trước) / K_VP_303 cuối năm trước × 100 | Case 2 — từ K_VP_303 tại 2 mốc; BA dòng 471 'Trùng' | READY |
| K_VP_306 | SL TK phái sinh mới | TK | Cơ sở | Số TK phái sinh mở mới trong kỳ | **Lý do pending:** [Nhóm 2 - Chưa có mapping nguồn từ BA]: BA dòng 472 'Trạng thái mapping = Done' nhưng Trường nguồn NULL, Điều kiện 'Không có dữ liệu, trên chart hiển thị N/A'; TTLK01_1 chỉ có 3 cột TỔNG CỘNG / TRONG NƯỚC / NƯỚC NGOÀI, xem O_VP_59. **Atomic cần bổ sung:** TBD. **Mart dự kiến:** Fact Derivatives Account Snapshot — thêm cột TK mở trong kỳ | PENDING [Nhóm 2 - Chưa có mapping nguồn từ BA] |
| K_VP_307 | SL TK phái sinh mới - % so với kỳ trước | % | Phái sinh | (SL TK mới kỳ này − kỳ trước) / kỳ trước × 100 | **Lý do pending:** phái sinh từ K_VP_306, cùng blocker O_VP_59 (BA dòng 473: không có dữ liệu, chart hiển thị N/A) | PENDING [Nhóm 2 - Chưa có mapping nguồn từ BA] |
| K_VP_308 | SL TK phái sinh mới - % so với cùng kỳ năm trước | % | Phái sinh | (SL TK mới kỳ này − cùng kỳ năm trước) / cùng kỳ năm trước × 100 | **Lý do pending:** phái sinh từ K_VP_306, cùng blocker O_VP_59 (BA dòng 474: không có dữ liệu, chart hiển thị N/A) | PENDING [Nhóm 2 - Chưa có mapping nguồn từ BA] |
| K_VP_309 | SL TK phái sinh đóng | TK | Cơ sở | Số TK phái sinh đóng trong kỳ | **Lý do pending:** [Nhóm 2 - Chưa có mapping nguồn từ BA]: BA dòng 475 'Trạng thái mapping = Done' nhưng Trường nguồn NULL, Điều kiện 'Không có dữ liệu, trên chart hiển thị N/A'; TTLK01_1 chỉ có 3 cột TỔNG CỘNG / TRONG NƯỚC / NƯỚC NGOÀI, xem O_VP_59. **Atomic cần bổ sung:** TBD. **Mart dự kiến:** Fact Derivatives Account Snapshot — thêm cột TK đóng trong kỳ | PENDING [Nhóm 2 - Chưa có mapping nguồn từ BA] |
| K_VP_310 | SL TK phái sinh đóng - % so với kỳ trước | % | Phái sinh | (SL TK đóng kỳ này − kỳ trước) / kỳ trước × 100 | **Lý do pending:** phái sinh từ K_VP_309, cùng blocker O_VP_59 (BA dòng 476: không có dữ liệu, chart hiển thị N/A) | PENDING [Nhóm 2 - Chưa có mapping nguồn từ BA] |
| K_VP_311 | SL TK phái sinh đóng - % so với cùng kỳ năm trước | % | Phái sinh | (SL TK đóng kỳ này − cùng kỳ năm trước) / cùng kỳ năm trước × 100 | **Lý do pending:** phái sinh từ K_VP_309, cùng blocker O_VP_59 (BA dòng 477: không có dữ liệu, chart hiển thị N/A) | PENDING [Nhóm 2 - Chưa có mapping nguồn từ BA] |
| K_VP_312 | Tổng số TK phái sinh - Trong nước | TK | Cơ sở | Domestic Account Quantity tại tháng báo cáo mới nhất có dữ liệu trong kỳ tra cứu | Case 1 — measure Domestic Account Quantity; BA dòng 478; ô `SỐ LƯỢNG CUỐI KỲ > TRONG NƯỚC` của TTLK01_1 — O_VP_58 | READY |
| K_VP_313 | Tổng số TK phái sinh - Trong nước - % so với kỳ trước | % | Phái sinh | (K_VP_312 kỳ tra cứu − K_VP_312 cuối kỳ trước) / K_VP_312 cuối kỳ trước × 100 | Case 2 — từ K_VP_312 tại 2 mốc; BA dòng 479 'Trùng' | READY |
| K_VP_314 | Tổng số TK phái sinh - Trong nước - % so với năm trước | % | Phái sinh | (K_VP_312 kỳ tra cứu − K_VP_312 cuối năm trước) / K_VP_312 cuối năm trước × 100 | Case 2 — từ K_VP_312 tại 2 mốc; BA dòng 480 'Trùng' | READY |
| K_VP_315 | Tổng số TK phái sinh - Trong nước - Cá nhân | TK | Cơ sở | Số TK phái sinh NĐT cá nhân trong nước | **Lý do pending:** [Nhóm 2 - Chưa có mapping nguồn từ BA]: BA dòng 481 'Trạng thái mapping = Done' nhưng Trường nguồn NULL, Điều kiện 'Không có dữ liệu, trên chart hiển thị N/A'; TTLK01_1 chỉ có 3 cột TỔNG CỘNG / TRONG NƯỚC / NƯỚC NGOÀI, xem O_VP_59. **Atomic cần bổ sung:** TBD. **Mart dự kiến:** Fact Derivatives Account Snapshot — thêm cột theo loại NĐT | PENDING [Nhóm 2 - Chưa có mapping nguồn từ BA] |
| K_VP_316 | Tổng số TK phái sinh - Trong nước - Cá nhân - % so với kỳ trước | % | Phái sinh | (kỳ này − kỳ trước) / kỳ trước × 100 | **Lý do pending:** phái sinh từ K_VP_315, cùng blocker O_VP_59 (BA dòng 482: không có dữ liệu, chart hiển thị N/A) | PENDING [Nhóm 2 - Chưa có mapping nguồn từ BA] |
| K_VP_317 | Tổng số TK phái sinh - Trong nước - Cá nhân - % so với năm trước | % | Phái sinh | (kỳ này − cuối năm trước) / cuối năm trước × 100 | **Lý do pending:** phái sinh từ K_VP_315, cùng blocker O_VP_59 (BA dòng 483: không có dữ liệu, chart hiển thị N/A) | PENDING [Nhóm 2 - Chưa có mapping nguồn từ BA] |
| K_VP_318 | Tổng số TK phái sinh - Trong nước - Tổ chức | TK | Cơ sở | Số TK phái sinh NĐT tổ chức trong nước | **Lý do pending:** [Nhóm 2 - Chưa có mapping nguồn từ BA]: BA dòng 484 'Trạng thái mapping = Done' nhưng Trường nguồn NULL, Điều kiện 'Không có dữ liệu, trên chart hiển thị N/A'; TTLK01_1 chỉ có 3 cột TỔNG CỘNG / TRONG NƯỚC / NƯỚC NGOÀI, xem O_VP_59. **Atomic cần bổ sung:** TBD. **Mart dự kiến:** Fact Derivatives Account Snapshot — thêm cột theo loại NĐT | PENDING [Nhóm 2 - Chưa có mapping nguồn từ BA] |
| K_VP_319 | Tổng số TK phái sinh - Trong nước - Tổ chức - % so với kỳ trước | % | Phái sinh | (kỳ này − kỳ trước) / kỳ trước × 100 | **Lý do pending:** phái sinh từ K_VP_318, cùng blocker O_VP_59 (BA dòng 485: không có dữ liệu, chart hiển thị N/A) | PENDING [Nhóm 2 - Chưa có mapping nguồn từ BA] |
| K_VP_320 | Tổng số TK phái sinh - Trong nước - Tổ chức - % so với năm trước | % | Phái sinh | (kỳ này − cuối năm trước) / cuối năm trước × 100 | **Lý do pending:** phái sinh từ K_VP_318, cùng blocker O_VP_59 (BA dòng 486: không có dữ liệu, chart hiển thị N/A) | PENDING [Nhóm 2 - Chưa có mapping nguồn từ BA] |
| K_VP_321 | Tổng số TK phái sinh - Nước ngoài | TK | Cơ sở | Foreign Account Quantity tại tháng báo cáo mới nhất có dữ liệu trong kỳ tra cứu | Case 1 — measure Foreign Account Quantity; BA dòng 487; ô `SỐ LƯỢNG CUỐI KỲ > NƯỚC NGOÀI` của TTLK01_1 — O_VP_58 | READY |
| K_VP_322 | Tổng số TK phái sinh - Nước ngoài - % so với kỳ trước | % | Phái sinh | (K_VP_321 kỳ tra cứu − K_VP_321 cuối kỳ trước) / K_VP_321 cuối kỳ trước × 100 | Case 2 — từ K_VP_321 tại 2 mốc; BA dòng 488 'Trùng' | READY |
| K_VP_323 | Tổng số TK phái sinh - Nước ngoài - % so với năm trước | % | Phái sinh | (K_VP_321 kỳ tra cứu − K_VP_321 cuối năm trước) / K_VP_321 cuối năm trước × 100 | Case 2 — từ K_VP_321 tại 2 mốc; BA dòng 489 'Trùng' | READY |
| K_VP_324 | Tổng số TK phái sinh - Nước ngoài - Cá nhân | TK | Cơ sở | Số TK phái sinh NĐT cá nhân nước ngoài | **Lý do pending:** [Nhóm 2 - Chưa có mapping nguồn từ BA]: BA dòng 490 'Trạng thái mapping = Done' nhưng Trường nguồn NULL, Điều kiện 'Không có dữ liệu, trên chart hiển thị N/A'; TTLK01_1 chỉ có 3 cột TỔNG CỘNG / TRONG NƯỚC / NƯỚC NGOÀI, xem O_VP_59. **Atomic cần bổ sung:** TBD. **Mart dự kiến:** Fact Derivatives Account Snapshot — thêm cột theo loại NĐT | PENDING [Nhóm 2 - Chưa có mapping nguồn từ BA] |
| K_VP_325 | Tổng số TK phái sinh - Nước ngoài - Cá nhân - % so với kỳ trước | % | Phái sinh | (kỳ này − kỳ trước) / kỳ trước × 100 | **Lý do pending:** phái sinh từ K_VP_324, cùng blocker O_VP_59 (BA dòng 491: không có dữ liệu, chart hiển thị N/A) | PENDING [Nhóm 2 - Chưa có mapping nguồn từ BA] |
| K_VP_326 | Tổng số TK phái sinh - Nước ngoài - Cá nhân - % so với năm trước | % | Phái sinh | (kỳ này − cuối năm trước) / cuối năm trước × 100 | **Lý do pending:** phái sinh từ K_VP_324, cùng blocker O_VP_59 (BA dòng 492: không có dữ liệu, chart hiển thị N/A) | PENDING [Nhóm 2 - Chưa có mapping nguồn từ BA] |
| K_VP_327 | Tổng số TK phái sinh - Nước ngoài - Tổ chức | TK | Cơ sở | Số TK phái sinh NĐT tổ chức nước ngoài | **Lý do pending:** [Nhóm 2 - Chưa có mapping nguồn từ BA]: BA dòng 493 'Trạng thái mapping = Done' nhưng Trường nguồn NULL, Điều kiện 'Không có dữ liệu, trên chart hiển thị N/A'; TTLK01_1 chỉ có 3 cột TỔNG CỘNG / TRONG NƯỚC / NƯỚC NGOÀI, xem O_VP_59. **Atomic cần bổ sung:** TBD. **Mart dự kiến:** Fact Derivatives Account Snapshot — thêm cột theo loại NĐT | PENDING [Nhóm 2 - Chưa có mapping nguồn từ BA] |
| K_VP_328 | Tổng số TK phái sinh - Nước ngoài - Tổ chức - % so với kỳ trước | % | Phái sinh | (kỳ này − kỳ trước) / kỳ trước × 100 | **Lý do pending:** phái sinh từ K_VP_327, cùng blocker O_VP_59 (BA dòng 494: không có dữ liệu, chart hiển thị N/A) | PENDING [Nhóm 2 - Chưa có mapping nguồn từ BA] |
| K_VP_329 | Tổng số TK phái sinh - Nước ngoài - Tổ chức - % so với năm trước | % | Phái sinh | (kỳ này − cuối năm trước) / cuối năm trước × 100 | **Lý do pending:** phái sinh từ K_VP_327, cùng blocker O_VP_59 (BA dòng 495: không có dữ liệu, chart hiển thị N/A) | PENDING [Nhóm 2 - Chưa có mapping nguồn từ BA] |

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
    Fact_Derivatives_Account_Snapshot {
        string Derivatives_Account_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        int Row_Number
        int Total_Account_Quantity
        int Domestic_Account_Quantity
        int Foreign_Account_Quantity
    }
    Calendar_Date_Dimension ||--o{ Fact_Derivatives_Account_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Derivatives_Account_Snapshot["Fact Derivatives Account Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 41"]
        R1["K_VP_300–329: Tài khoản giao dịch: chỉ tiêu tổng hợp thị trường phái sinh"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Derivatives_Account_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Derivatives Account Snapshot | 1 dòng báo cáo TTLK01_1 (Row Number) × 1 tháng báo cáo (ngày cuối tháng); PK Derivatives Account Snapshot Id = hash (Snapshot Date Dimension Id, Row Number, Source System Code) (Dạng B, A22); nạp lại cùng tháng ghi đè |

#### Nhóm 42 - Biểu đồ Tổng số tài khoản theo thời gian

> Phân loại: **Phân tích**
> Atomic: `Open Investor Account` ← VSDC.OPEN_INVESTORS, `Closed Investor Account` ← VSDC.CLOSED_INVESTORS — **READY** (Fact mới `Fact Investor Account Movement Snapshot`; nguồn VSDC, KHÔNG phụ thuộc Securities Trade)

**[GHI CHÚ 2026-10-29 — BA VP mapping cụm Tài khoản giao dịch (Nhóm 40, 42, 43) từ VSDC]** Nguồn `VSDC.OPEN_INVESTORS` / `VSDC.CLOSED_INVESTORS` (Atomic `open_investor_account` / `closed_investor_account`): Fact mới `Fact Investor Account Movement Snapshot` gộp 2 nguồn theo (ngày phát sinh, loại NĐT) với số TK mở và số TK đóng; số TK lũy kế = Σ mở − Σ đóng đến ngày (đúng công thức BA `COUNT(o.trading_account_no) − COUNT(c.trading_account_no)`). BA 'Trùng' ở một số dòng không nêu trùng với chỉ tiêu nào; các KPI Nhóm 42/43 trùng TÊN với Nhóm 40 nhưng khác ngữ nghĩa thời gian (chuỗi kỳ chứ không phải một kỳ) nên KPI riêng — Δ số lượng BA ↔ HLD ở Gate 10 là CÓ CHỦ Ý. Giả định và mâu thuẫn BA ở O_VP_46; Nhóm 41/44 (tài khoản phái sinh từ biểu mẫu BM 45_TTLK_01) BA chưa mapping — O_VP_47.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (D/M/Q/Y) · Từ kỳ — Đến kỳ

| Kỳ | Tổng số tài khoản |
|---|---|
| 2026-08 | … |
| 2026-09 | … |

> ⚠️ Presentation Grain: 1 điểm biểu đồ = 1 kỳ (Level 1), toàn thị trường, mọi loại NĐT. Storage Grain: xem Bảng grain — mịn hơn (ngày × loại NĐT), đạt Iso-Grain.

**Source:** `Fact Investor Account Movement Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_235 | Kỳ | — | Chiều | Calendar Date Dimension: chuỗi kỳ (D/M/Q/Y) từ Từ kỳ đến Đến kỳ | Tham số lọc 'Từ kỳ - Đến kỳ' (BA dòng 467); kỳ trống vẫn hiển thị | READY |
| K_VP_236 | Tổng số tài khoản | TK | Cơ sở | Σ Open Account Count − Σ Close Account Count lũy kế đến ngày cuối mỗi kỳ trong khoảng Từ kỳ — Đến kỳ (số dư đầu kỳ + phát sinh lũy kế) | Case 2 — chuỗi lũy kế theo kỳ; khác K_VP_214 (một kỳ); BA 'Trùng' theo tên (O_VP_46) | READY |

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
    Fact_Investor_Account_Movement_Snapshot {
        string Investor_Account_Movement_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Investor_Type_Code
        int Open_Account_Count
        int Close_Account_Count
    }
    Calendar_Date_Dimension ||--o{ Fact_Investor_Account_Movement_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Investor_Account_Movement_Snapshot["Fact Investor Account Movement Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 42"]
        R1["K_VP_235,236: Tài khoản giao dịch: biểu đồ tổng số tài khoản theo thời gian"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Investor_Account_Movement_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Investor Account Movement Snapshot | 1 ngày phát sinh (ngày mở hoặc ngày đóng tài khoản) × 1 loại NĐT VSDC (3–7, NA); PK Investor Account Movement Snapshot Id = hash (Snapshot Date Dimension Id, Investor Type Code) (Dạng B, A22); dựng lại toàn bộ mỗi lần chạy |

#### Nhóm 43 - Biểu đồ Số lượng tài khoản mới theo thời gian

> Phân loại: **Phân tích**
> Atomic: `Open Investor Account` ← VSDC.OPEN_INVESTORS, `Closed Investor Account` ← VSDC.CLOSED_INVESTORS — **READY** (Fact mới `Fact Investor Account Movement Snapshot`; nguồn VSDC, KHÔNG phụ thuộc Securities Trade)

**[GHI CHÚ 2026-10-29 — BA VP mapping cụm Tài khoản giao dịch (Nhóm 40, 42, 43) từ VSDC]** Nguồn `VSDC.OPEN_INVESTORS` / `VSDC.CLOSED_INVESTORS` (Atomic `open_investor_account` / `closed_investor_account`): Fact mới `Fact Investor Account Movement Snapshot` gộp 2 nguồn theo (ngày phát sinh, loại NĐT) với số TK mở và số TK đóng; số TK lũy kế = Σ mở − Σ đóng đến ngày (đúng công thức BA `COUNT(o.trading_account_no) − COUNT(c.trading_account_no)`). BA 'Trùng' ở một số dòng không nêu trùng với chỉ tiêu nào; các KPI Nhóm 42/43 trùng TÊN với Nhóm 40 nhưng khác ngữ nghĩa thời gian (chuỗi kỳ chứ không phải một kỳ) nên KPI riêng — Δ số lượng BA ↔ HLD ở Gate 10 là CÓ CHỦ Ý. Giả định và mâu thuẫn BA ở O_VP_46; Nhóm 41/44 (tài khoản phái sinh từ biểu mẫu BM 45_TTLK_01) BA chưa mapping — O_VP_47.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (D/M/Q/Y) · Từ kỳ — Đến kỳ

| Kỳ | Số lượng TK mới |
|---|---|
| 2026-08 | … |
| 2026-09 | … |

> ⚠️ Presentation Grain: 1 điểm biểu đồ = 1 kỳ (Level 1), toàn thị trường, mọi loại NĐT. Storage Grain: xem Bảng grain — mịn hơn (ngày × loại NĐT), đạt Iso-Grain.

**Source:** `Fact Investor Account Movement Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_237 | Kỳ | — | Chiều | Calendar Date Dimension: chuỗi kỳ (D/M/Q/Y) từ Từ kỳ đến Đến kỳ | Tham số lọc 'Từ kỳ - Đến kỳ' (BA dòng 469) | READY |
| K_VP_238 | Số lượng TK mới | TK | Cơ sở | SUM(Open Account Count) trên Fact Investor Account Movement Snapshot, GROUP BY kỳ trong khoảng Từ kỳ — Đến kỳ | Case 1 — measure Open Account Count; khác K_VP_217 (một kỳ) (O_VP_46) | READY |

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
    Fact_Investor_Account_Movement_Snapshot {
        string Investor_Account_Movement_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Investor_Type_Code
        int Open_Account_Count
        int Close_Account_Count
    }
    Calendar_Date_Dimension ||--o{ Fact_Investor_Account_Movement_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Investor_Account_Movement_Snapshot["Fact Investor Account Movement Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 43"]
        R1["K_VP_237,238: Tài khoản giao dịch: biểu đồ số lượng tài khoản mới theo thời gian"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Investor_Account_Movement_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Investor Account Movement Snapshot | 1 ngày phát sinh (ngày mở hoặc ngày đóng tài khoản) × 1 loại NĐT VSDC (3–7, NA); PK Investor Account Movement Snapshot Id = hash (Snapshot Date Dimension Id, Investor Type Code) (Dạng B, A22); dựng lại toàn bộ mỗi lần chạy |

#### Nhóm 44 - Biểu đồ Tổng số tài khoản phái sinh theo thời gian

> Phân loại: **Phân tích**
> Atomic: `Internal Statistical Report` (`internal_statistical_report`) ← ISS báo cáo `TTLK01_1` — **READY** (dùng lại `Fact Derivatives Account Snapshot` của Nhóm 41, Case 1)

**[GHI CHÚ 2026-11-05 — BA VP mapping Nhóm 44]** BA đóng O_VP_47 cho Nhóm 44: thêm dòng Kỳ (500), nguồn chuyển sang ISS `TTLK01_1` (`uat_iss_ods.flat_report`, ô `TỔNG CỘNG`); cả 2 dòng 'Đánh giá: Trùng' theo tên K_VP_300/K_VP_303 (Nhóm 41) nhưng khác ngữ nghĩa (chuỗi kỳ 'Từ kỳ - Đến kỳ' thay vì một kỳ) → KPI riêng, như K_VP_235–236 so với K_VP_212–214 (O_VP_46). Giả định cần dev xác nhận: O_VP_58.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (Tháng / Quý / Năm) · Từ kỳ — Đến kỳ

| Kỳ | Tổng số tài khoản phái sinh |
|---|---|
| 2026-08 | … |
| 2026-09 | … |

> ⚠️ Presentation Grain: 1 điểm biểu đồ = 1 kỳ (tháng / quý / năm), toàn thị trường phái sinh. Storage Grain: xem Bảng grain — mịn hơn (dòng báo cáo × tháng), đạt Iso-Grain.

**Source:** `Fact Derivatives Account Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_330 | Kỳ | — | Chiều | Calendar Date Dimension: chuỗi kỳ M / Q / Y từ Từ kỳ đến Đến kỳ | Tham số lọc 'Từ kỳ - Đến kỳ' (BA dòng 500, 'Trùng' theo tên K_VP_300 nhưng khác 'Tại kỳ'); chỉ kỳ có dữ liệu — O_VP_58 | READY |
| K_VP_331 | Tổng số tài khoản phái sinh | TK | Cơ sở | Total Account Quantity tại tháng báo cáo mới nhất có dữ liệu của từng kỳ trong khoảng Từ kỳ — Đến kỳ | Case 1 — như K_VP_303 nhưng theo chuỗi kỳ; BA dòng 501 'Trùng' theo tên — O_VP_58 | READY |

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
    Fact_Derivatives_Account_Snapshot {
        string Derivatives_Account_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        int Row_Number
        int Total_Account_Quantity
        int Domestic_Account_Quantity
        int Foreign_Account_Quantity
    }
    Calendar_Date_Dimension ||--o{ Fact_Derivatives_Account_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Derivatives_Account_Snapshot["Fact Derivatives Account Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 44"]
        R1["K_VP_330–331: Tài khoản giao dịch: biểu đồ tổng số tài khoản phái sinh theo thời gian"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Derivatives_Account_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Derivatives Account Snapshot | 1 dòng báo cáo TTLK01_1 (Row Number) × 1 tháng báo cáo (ngày cuối tháng); PK Derivatives Account Snapshot Id = hash (Snapshot Date Dimension Id, Row Number, Source System Code) (Dạng B, A22); nạp lại cùng tháng ghi đè |

#### Nhóm 45 - Tổng quan thị trường >> Biểu đồ Tổng giá trị cổ phần bán được qua đấu giá

> Phân loại: **Phân tích**
> Atomic: Fact mới `Fact Share Auction Result Snapshot` ← ISS.INTERNAL_STATISTICAL_REPORT (Atomic `Internal Statistical Report`, biểu mẫu HNX05 + HSX03, nguồn nộp ICP) — **READY** (có giả định row_num ≡ row_index, O_VP_55); KHÔNG phụ thuộc Securities Trade

**[GHI CHÚ 2026-11-03 — BA VP mapping Nhóm 45]** BA Nhóm 45 gồm 8 dòng 'Done' (479 Kỳ (Năm) — Chiều; 480 Nhóm loại hình đấu giá — Chiều; 481 Số phiên đấu giá; 482 Giá trị trúng giá; 483–486 Giá trị theo 4 nhóm — 'Trùng'). Nguồn BA đổi sang `uat_iss_ods.flat_report` (eForm HNX05 của HNX, HSX03 của HOSE); Atomic tương ứng `internal_statistical_report` (cùng cách VP đọc HNX09 và TKNB đọc TTLK01). Fact mới `Fact Share Auction Result Snapshot` (Data Modeler xác nhận 2026-11-03): 1 dòng biểu mẫu = 1 đợt đấu giá của 1 tổ chức, FK ngày = ngày cuối tháng báo cáo, **nhóm loại hình tính tại ETL** (IPO / Thoái vốn / Phát hành ra công chúng - quyền mua / Khác), Số phiên và Giá trị trúng giá cộng theo năm tại Detail Mapping. Kỳ (Năm) dùng lại K_VP_160. Các dòng 'Trùng' (483–486) vẫn có KPI riêng nên Δ số lượng BA ↔ HLD ở Gate 10 là CÓ CHỦ Ý. Giả định và lỗi BA ở O_VP_55.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Từ năm · Đến năm

| Năm | Nhóm loại hình đấu giá | Số phiên đấu giá | Giá trị trúng giá |
|---|---|---|---|
| … | IPO / Thoái vốn / Phát hành ra công chúng - quyền mua / Khác / Tổng | … | … |

> ⚠️ Presentation Grain: 1 điểm biểu đồ = 1 Năm × 1 nhóm loại hình đấu giá (và dòng Tổng), toàn thị trường. Storage Grain: 1 đợt đấu giá của 1 tổ chức (dòng biểu mẫu HNX05/HSX03) — mịn hơn năm × nhóm, đạt Iso-Grain — xem Bảng grain.

**Source:** `Fact Share Auction Result Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_160 | Kỳ (Năm) | — | Chiều | Calendar Date Dimension: Year (từ năm — đến năm) trên ngày cuối tháng báo cáo | Reuse K_VP_160 (Nhóm 47–51) — Case 1; BA dòng 479; **[SỬA 2026-11-05]** BA đã sửa Điều kiện và Trường nguồn dòng 479 thành `report_year` (khớp thiết kế) — O_VP_55(e) | READY |
| K_VP_281 | Nhóm loại hình đấu giá | — | Chiều | Auction Type Group Name trên Fact Share Auction Result Snapshot (IPO, Thoái vốn, Phát hành ra công chúng - quyền mua, Khác), kèm dòng Tổng | Nhóm tính tại ETL theo danh sách chuỗi 'LOẠI HÌNH ĐẤU GIÁ' của BA; chuỗi ngoài danh sách → Khác; BA bản trước có chiều 'Loại hình đấu giá' đã bỏ | READY |
| K_VP_282 | Số phiên đấu giá | Phiên | Cơ sở | COUNT(dòng) trên Fact Share Auction Result Snapshot, GROUP BY năm | Case 1 — mỗi dòng biểu mẫu là 1 đợt đấu giá; HNX05 + HSX03 cộng chung; BA row_num ≡ Atomic row_index (giả định) — O_VP_55 | READY |
| K_VP_283 | Giá trị trúng giá | VND | Phái sinh | SUM(Domestic Winning Value) + SUM(Foreign Winning Value) trên Fact Share Auction Result Snapshot, GROUP BY năm | Case 2 — BA ghi 'Chỉ tiêu cơ sở' nhưng là tổng 2 cột nhà đầu tư trong nước + nước ngoài → Phái sinh | READY |
| K_VP_284 | Giá trị nhóm loại hình IPO | VND | Phái sinh | K_VP_283 lọc Auction Type Group Name = 'IPO' | Case 2 — BA dòng 483 'Trùng' công thức K_VP_283 | READY |
| K_VP_285 | Giá trị nhóm loại hình Thoái vốn | VND | Phái sinh | K_VP_283 lọc Auction Type Group Name = 'Thoái vốn' | Case 2 — BA dòng 484 'Trùng' công thức K_VP_283 | READY |
| K_VP_286 | Giá trị nhóm loại hình Phát hành ra công chúng / quyền mua | VND | Phái sinh | K_VP_283 lọc Auction Type Group Name = 'Phát hành ra công chúng / quyền mua' | Case 2 — BA dòng 485 'Trùng' công thức K_VP_283 | READY |
| K_VP_287 | Giá trị nhóm loại hình Khác | VND | Phái sinh | K_VP_283 lọc Auction Type Group Name = 'Khác' | Case 2 — BA dòng 486 'Trùng'; Mô tả BA chép nhầm của nhóm Phát hành ra công chúng — O_VP_55 | READY |

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
    Fact_Share_Auction_Result_Snapshot {
        string Share_Auction_Result_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Report_Code
        int Row_Number
        string Auction_Type_Name
        string Auction_Type_Group_Name
        decimal Domestic_Winning_Value
        decimal Foreign_Winning_Value
        string Source_System_Code
    }
    Calendar_Date_Dimension ||--o{ Fact_Share_Auction_Result_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Share_Auction_Result_Snapshot["Fact Share Auction Result Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 45"]
        R1["K_VP_160,281-287: Tổng quan thị trường >> Biểu đồ Tổng giá trị cổ phần bán được qua đấu giá"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Share_Auction_Result_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Share Auction Result Snapshot | 1 dòng biểu mẫu đấu giá cổ phần (HNX05 của HNX hoặc HSX03 của HOSE) = 1 đợt đấu giá của 1 tổ chức; PK Share Auction Result Snapshot Id = hash(Snapshot Date Dimension Id, Report Code, Row Number, Source System Code) (Dạng B, A22); kỳ theo ngày cuối tháng báo cáo |

#### Nhóm 47 - Tổng quan thị trường >> Biểu đồ Kỳ hạn phát hành bình quân TPCP

> Phân loại: **Phân tích**
> Atomic: Fact mới `Fact Government Bond Bidding Result Snapshot` ← HNX.GOV_BOND_OFFERING (Atomic `Gov Bond Bidding Result`, draft) — **READY**; nguồn HNX, KHÔNG phụ thuộc Securities Trade

**[GHI CHÚ 2026-11-02 — BA VP mapping Nhóm 47]** BA Nhóm 47 gồm 2 dòng (496 Kỳ (Năm) — Chiều; 497 Kỳ hạn phát hành bình quân TPCP — Cơ sở), đều 'Done'. Nhóm 47 và Nhóm 48 dùng chung SQL BA (đặt ở dòng 496, nguồn `uat_hnx_stg.gov_bond_offering`). Fact mới `Fact Government Bond Bidding Result Snapshot` (Data Modeler xác nhận 2026-11-02): 1 dòng kết quả đấu thầu, FK ngày = ngày phát hành, kỳ hạn quy đổi năm tại ETL, bình quân gia quyền theo giá trị trúng thầu tại Detail Mapping. Kỳ reuse K_VP_160. Giả định/khóa Atomic ở O_VP_49, lỗi BA ở O_VP_51.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Từ năm · Đến năm

| Chỉ tiêu | Năm 1 | Năm 2 | … |
|---|---|---|---|
| Kỳ hạn phát hành bình quân TPCP (năm) | … | … | … |

> ⚠️ Presentation Grain: 1 điểm biểu đồ = 1 Năm (Từ năm — Đến năm), toàn thị trường TPCP. Storage Grain: 1 dòng kết quả đấu thầu phát hành TPCP (ngày phát hành × mã × đợt) — mịn hơn năm, đạt Iso-Grain — xem Bảng grain.

**Source:** `Fact Government Bond Bidding Result Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_160 | Kỳ (Năm) | — | Chiều | Calendar Date Dimension: Year (từ năm — đến năm) trên ngày phát hành | Reuse K_VP_160 (Nhóm 50, 51) — Case 1; BA dòng 496 | READY |
| K_VP_255 | Kỳ hạn phát hành bình quân TPCP | Năm | Phái sinh | Σ (Issue Term Years × Winning Value) / Σ Winning Value trên Fact Government Bond Bidding Result Snapshot, GROUP BY Calendar Date Dimension.Year | Case 2 — bình quân gia quyền (trọng số giá trị trúng thầu) tính tại presentation layer; BA ghi 'Chỉ tiêu cơ sở'; kỳ hạn quy đổi năm tại ETL — O_VP_49, O_VP_51 | READY |

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
    Government_Bond_Term_Dimension {
        string Government_Bond_Term_Dimension_Id PK
        string Bond_Term
        decimal Bond_Term_Years
        string Bond_Term_Unit
        string Source_System_Code
    }
    Fact_Government_Bond_Bidding_Result_Snapshot {
        string Government_Bond_Bidding_Result_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Government_Bond_Term_Dimension_Id FK
        int Report_Year
        int Report_Month
        string Bidding_Session
        string Bond_Code
        string Bond_Term
        decimal Issue_Term_Years
        decimal Calling_Value
        decimal Winning_Value
        decimal Winning_Interest_Rate
        string Source_System_Code
    }
    Calendar_Date_Dimension ||--o{ Fact_Government_Bond_Bidding_Result_Snapshot : " "
    Government_Bond_Term_Dimension ||--o{ Fact_Government_Bond_Bidding_Result_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Government_Bond_Bidding_Result_Snapshot["Fact Government Bond Bidding Result Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 47"]
        R1["K_VP_160,255: Tổng quan thị trường >> Biểu đồ Kỳ hạn phát hành bình quân TPCP"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Government_Bond_Bidding_Result_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Government Bond Bidding Result Snapshot | 1 dòng kết quả đấu thầu phát hành trái phiếu Chính phủ (id dòng Atomic `gov_bond_bidding_result`; HNX.GOV_BOND_OFFERING); PK Government Bond Bidding Result Snapshot Id = id dòng Atomic (Dạng A, A22); kỳ theo ngày phát hành |

#### Nhóm 48 - Tổng quan thị trường >> Biểu đồ Lãi suất phát hành bình quân TPCP

> Phân loại: **Phân tích**
> Atomic: Fact mới `Fact Government Bond Bidding Result Snapshot` ← HNX.GOV_BOND_OFFERING (Atomic `Gov Bond Bidding Result`, draft) — **READY**; nguồn HNX, KHÔNG phụ thuộc Securities Trade

**[GHI CHÚ 2026-11-02 — BA VP mapping Nhóm 48]** BA Nhóm 48 gồm 2 dòng (498 Kỳ (Năm) — Chiều; 499 Lãi suất phát hành bình quân TPCP — Cơ sở), đều 'Done'; dùng chung SQL và Fact với Nhóm 47 (`Fact Government Bond Bidding Result Snapshot`). Kỳ reuse K_VP_160. Giả định ở O_VP_49, lỗi BA ở O_VP_51.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Từ năm · Đến năm

| Chỉ tiêu | Năm 1 | Năm 2 | … |
|---|---|---|---|
| Lãi suất phát hành bình quân TPCP (%) | … | … | … |

> ⚠️ Presentation Grain: 1 điểm biểu đồ = 1 Năm (Từ năm — Đến năm), toàn thị trường TPCP. Storage Grain: 1 dòng kết quả đấu thầu phát hành TPCP (ngày phát hành × mã × đợt) — mịn hơn năm, đạt Iso-Grain — xem Bảng grain.

**Source:** `Fact Government Bond Bidding Result Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_160 | Kỳ (Năm) | — | Chiều | Calendar Date Dimension: Year (từ năm — đến năm) trên ngày phát hành | Reuse K_VP_160 (Nhóm 50, 51) — Case 1; BA dòng 498 | READY |
| K_VP_256 | Lãi suất phát hành bình quân TPCP | % | Phái sinh | Σ (Winning Interest Rate × Winning Value) / Σ Winning Value trên Fact Government Bond Bidding Result Snapshot, GROUP BY Calendar Date Dimension.Year | Case 2 — bình quân gia quyền (trọng số giá trị trúng thầu) tính tại presentation layer; BA ghi 'Chỉ tiêu cơ sở' — O_VP_49, O_VP_51 | READY |

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
    Government_Bond_Term_Dimension {
        string Government_Bond_Term_Dimension_Id PK
        string Bond_Term
        decimal Bond_Term_Years
        string Bond_Term_Unit
        string Source_System_Code
    }
    Fact_Government_Bond_Bidding_Result_Snapshot {
        string Government_Bond_Bidding_Result_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Government_Bond_Term_Dimension_Id FK
        int Report_Year
        int Report_Month
        string Bidding_Session
        string Bond_Code
        string Bond_Term
        decimal Issue_Term_Years
        decimal Calling_Value
        decimal Winning_Value
        decimal Winning_Interest_Rate
        string Source_System_Code
    }
    Calendar_Date_Dimension ||--o{ Fact_Government_Bond_Bidding_Result_Snapshot : " "
    Government_Bond_Term_Dimension ||--o{ Fact_Government_Bond_Bidding_Result_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Government_Bond_Bidding_Result_Snapshot["Fact Government Bond Bidding Result Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 48"]
        R1["K_VP_160,256: Tổng quan thị trường >> Biểu đồ Lãi suất phát hành bình quân TPCP"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Government_Bond_Bidding_Result_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Government Bond Bidding Result Snapshot | 1 dòng kết quả đấu thầu phát hành trái phiếu Chính phủ (id dòng Atomic `gov_bond_bidding_result`; HNX.GOV_BOND_OFFERING); PK Government Bond Bidding Result Snapshot Id = id dòng Atomic (Dạng A, A22); kỳ theo ngày phát hành |

#### Nhóm 49 - Tổng quan thị trường >> Biểu đồ Quy mô niêm yết và giao dịch TPCP

> Phân loại: **Phân tích**
> Atomic: `Bond Order Book` ← HNX (Outright, Repo) — **READY** (GTGD Outright/Repos, dùng chung `Fact Government Bond Trading Snapshot` với Nhóm 14–16); `Gov Bond Listing` ← HNX.GOV_BOND_LISTED_LIST (Fact mới `Fact Government Bond Listing Snapshot`) — **READY** (giá trị niêm yết TPCP; Atomic đã có năm báo cáo từ 2026-11-04, khóa Atomic xem O_VP_62)

**[GHI CHÚ 2026-11-02 — BA VP mapping Nhóm 49]** BA Nhóm 49 gồm 4 dòng (500 Kỳ (Năm) — Chiều; 501 Giá trị niêm yết TPCP — 'Trùng'; 502 GTGD Outright; 503 GTGD Repos). GTGD Outright/Repos đọc `Fact Government Bond Trading Snapshot` tách theo Order Book Type Code (Atomic `Bond Order Book` thay `outright_order_book` / `repo_order_book` của BA — O_VP_32). **Giá trị niêm yết TPCP (K_VP_257) READY từ 2026-11-05**: Atomic `gov_bond_listing` đã có `rpt_year` (2026-11-04) nên đọc Fact mới `Fact Government Bond Listing Snapshot`; khóa Atomic chưa có tháng — O_VP_62. *(Lịch sử: PENDING [Nhóm 3] 2026-11-02 đến 2026-11-04 vì Atomic thiếu năm báo cáo — O_VP_50.)* Dòng 501 'Đánh giá: Trùng' nhưng không nêu trùng chỉ tiêu nào (Nhóm 55 dòng 601 cùng nguồn) → KPI riêng; Δ số lượng BA ↔ HLD ở Gate 10 là CÓ CHỦ Ý. Lỗi BA ở O_VP_51.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Từ năm · Đến năm

| Chỉ tiêu | Năm 1 | Năm 2 | … |
|---|---|---|---|
| GTGD Outright | … | … | … |
| GTGD Repos | … | … | … |
| Giá trị niêm yết TPCP | … | … | … |

> ⚠️ Presentation Grain: 1 điểm biểu đồ = 1 Năm (Từ năm — Đến năm), toàn thị trường TPCP. Storage Grain: Fact Government Bond Trading Snapshot = 1 ngày giao dịch × 1 loại sổ lệnh — mịn hơn năm, đạt Iso-Grain; giá trị niêm yết: Fact Government Bond Listing Snapshot = 1 mã TPCP × 1 tháng báo cáo — mịn hơn năm, đạt Iso-Grain, xem Bảng grain.

**Source:** `Fact Government Bond Trading Snapshot`, `Fact Government Bond Listing Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_160 | Kỳ (Năm) | — | Chiều | Calendar Date Dimension: Year (từ năm — đến năm) trên ngày giao dịch | Reuse K_VP_160 (Nhóm 50, 51) — Case 1; BA dòng 500 | READY |
| K_VP_257 | Giá trị niêm yết TPCP | VND | Cơ sở | SUM(Listed Bond Value) tại tháng báo cáo mới nhất có dữ liệu của từng năm trong khoảng Từ năm — Đến năm | Case 1 — measure Listed Bond Value; BA dòng 528 'Trùng' nhưng không nêu chỉ tiêu trùng (K_VP_266 Nhóm 55 cùng nguồn, khác tham số kỳ) → KPI riêng — O_VP_62 | READY |
| K_VP_258 | GTGD Outright | VND | Cơ sở | SUM(Trading Value) trên Fact Government Bond Trading Snapshot với Order Book Type Code = 'OUTRIGHT', GROUP BY Calendar Date Dimension.Year | Case 1 — measure Trading Value tách theo Order Book Type Code; BA dòng 502; literal 'ĐTH' — O_VP_32 | READY |
| K_VP_259 | GTGD Repos | VND | Cơ sở | SUM(Trading Value) trên Fact Government Bond Trading Snapshot với Order Book Type Code = 'REPO' (giá trị thanh toán lần 1), GROUP BY Calendar Date Dimension.Year | Case 1 — measure Trading Value (REPO = GT thanh toán lần 1); BA dòng 503 — O_VP_51 | READY |

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
    Fact_Government_Bond_Listing_Snapshot {
        string Government_Bond_Listing_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Bond_Code
        int Report_Year
        int Report_Month
        bigint Listed_Bond_Quantity
        decimal Listed_Bond_Value
    }
    Calendar_Date_Dimension ||--o{ Fact_Government_Bond_Trading_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Government_Bond_Listing_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Government_Bond_Trading_Snapshot["Fact Government Bond Trading Snapshot"]
        Fact_Government_Bond_Listing_Snapshot["Fact Government Bond Listing Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 49"]
        R1["K_VP_160,257,258,259: Tổng quan thị trường >> Biểu đồ Quy mô niêm yết và giao dịch TPCP"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Government_Bond_Trading_Snapshot --> R1
    Fact_Government_Bond_Listing_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Government Bond Trading Snapshot | 1 ngày giao dịch × 1 loại sổ lệnh (Order Book Type Code ∈ OUTRIGHT, REPO); PK Government Bond Trading Snapshot Id = hash (Snapshot Date Dimension Id, Order Book Type Code) (Dạng B, A22) |
| Fact Government Bond Listing Snapshot | 1 mã trái phiếu Chính phủ niêm yết × 1 tháng báo cáo (Report Year, Report Month; Atomic `gov_bond_listing` ← HNX.GOV_BOND_LISTED_LIST); PK Government Bond Listing Snapshot Id = hash (Bond Code, Report Year, Report Month, Source System Code) (Dạng B, A22); khóa ngày = ngày cuối tháng báo cáo |

#### Nhóm 50 - Tổng quan thị trường >> Biểu đồ Thống kê cổ phiếu niêm yết mới

> Phân loại: **Phân tích**
> Atomic: `Listing Status Change` ← HNX.LISTING_STATUS_CHANGE / HOSE.LISTING_STATUS_CHANGE — **READY** (dùng chung `Fact Listing Status Change Snapshot` với Nhóm 51, thêm 4 cột niêm yết mới/bổ sung; nguồn riêng, KHÔNG phụ thuộc Securities Trade); loại chứng khoán lấy từ `Security Trading Snapshot Dimension` (GSTT); mã sàn TẠI NGÀY SỰ KIỆN lấy từ cột Listing Floor Code của Fact (Dimension là current-state, O_VP_53)

**[GHI CHÚ 2026-10-29 — BA VP mapping Nhóm 50]** BA đánh 'Trùng' 4 dòng KL (499–501) và dòng 498 nhưng không nêu trùng với chỉ tiêu nào (Chỉ tiêu gốc 'KL cổ phiếu niêm yết lần đầu, niêm yết bổ sung' chưa có Nhóm nào) → thiết kế đủ 5 KPI (Kỳ reuse K_VP_160) nên Δ số lượng BA ↔ HLD ở Gate 10 là CÓ CHỦ Ý. Kỳ lọc theo `effective_date` (như Nhóm 51); mâu thuẫn BA (công thức dòng 498 lặp bảng a, Trường nguồn giá trị vs công thức khối lượng, nối MDDS tại ngày hiệu lực) ghi ở O_VP_44, O_VP_45.

> **[CẬP NHẬT 2026-11-02 — BA VP Nhóm 50/51, O_VP_53]** BA đổi: (1) Nhóm 50 dòng 506 (HOSE) thêm `s.floorcode = '10'`; (2) cả 2 Nhóm viết lại cách nối MDDS: NY/ĐKGD MỚI nối `first_trading_date = s_new.tradingdate`, NY/ĐKGD BỔ SUNG và HỦY nối PHIÊN GIAO DỊCH GẦN NHẤT <= `effective_date` (Nhóm 51 trước đó `effective_date = tradingdate`); (3) SQL BA nhóm theo sàn = `MAP(...)[IF(new_listed_shares > 0, s_new.floorcode, s_add.floorcode)]` — mã sàn là sàn TẠI NGÀY SỰ KIỆN. **Sửa:** Fact thêm cột Listing Floor Code (tính tại ETL đúng quy tắc trên; phiên gần nhất <= ngày hiệu lực KHÔNG giới hạn dưới, đúng SQL BA) và K_VP_209–211, K_VP_162–164 lọc theo cột này thay `Security Trading Snapshot Dimension.Floor Code` (current-state: mã đã chuyển sàn mang sàn hiện tại nên đếm sai sàn khi BA đã BỎ điều kiện loại chuyển sàn). Các câu 'khớp 100%' / 'tách theo mã sàn của Dimension' ở trên là *(Lịch sử — không đúng ở phần mã sàn)*. Dev cần ALTER + nạp lại Fact và flat `vp_fct_listing_status_change_snpst_flat`.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Từ năm · Đến năm

| Chỉ tiêu | Năm 1 | Năm 2 | … |
|---|---|---|---|
| SL mã cổ phiếu NY/ĐKGD mới (theo năm) | … | … | … |
| KL CP NY mới/bổ sung trên HOSE | … | … | … |
| KL CP NY mới/bổ sung trên HNX | … | … | … |
| KL CP ĐKGD mới/bổ sung trên UPCoM | … | … | … |

> ⚠️ Presentation Grain: 1 điểm biểu đồ = 1 Năm (Từ năm — Đến năm), toàn thị trường; chỉ tiêu KL tách theo sàn (HOSE / HNX / UPCoM). Storage Grain: 1 quyết định thay đổi niêm yết × 1 mã × 1 Sở — xem Bảng grain.

**Source:** `Fact Listing Status Change Snapshot` → `Calendar Date Dimension`, `Security Trading Snapshot Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_160 | Kỳ (Năm) | — | Chiều | Calendar Date Dimension: Year (từ năm — đến năm) trên NGÀY HIỆU LỰC của quyết định | Reuse K_VP_160 (Nhóm 51) — năm của ngày hiệu lực (BA 2026-10-29) | READY |
| K_VP_208 | Số lượng mã CP NY/ĐKGD mới | Mã | Cơ sở | COUNT(Ticker Symbol) trên Fact Listing Status Change Snapshot với Stock Type Code = '2' (Security Trading Snapshot Dimension), New Listed Share Quantity > 0, GROUP BY Calendar Date Dimension.Year | Case 1 — đếm quyết định niêm yết/ĐKGD mới của cổ phiếu (cả HNX, UPCoM, HOSE); BA công thức lặp bảng a — O_VP_44 | READY |
| K_VP_209 | KL CP NY mới/bổ sung trên HOSE | CP | Cơ sở | SUM(New Listed Share Quantity) + SUM(Additional Listed Share Quantity) trên Fact Listing Status Change Snapshot với Source System Code = 'HOSE_LISTING_STATUS_CHANGE', Listing Floor Code = '10' (HOSE — sàn tại ngày sự kiện), Stock Type Code = '2' (Security Trading Snapshot Dimension), (New Listed Share Quantity > 0 hoặc Additional Listed Share Quantity > 0), GROUP BY Calendar Date Dimension.Year | Case 1 — measure New/Additional Listed Share Quantity; nguồn HOSE, sàn tại ngày sự kiện = '10' (Listing Floor Code — O_VP_53). Mâu thuẫn Trường nguồn giá trị/khối lượng — O_VP_45 | READY |
| K_VP_210 | KL CP NY mới/bổ sung trên HNX | CP | Cơ sở | SUM(New Listed Share Quantity) + SUM(Additional Listed Share Quantity) trên Fact Listing Status Change Snapshot với Source System Code = 'HNX_LISTING_STATUS_CHANGE' và Listing Floor Code = '02' (HNX — sàn tại ngày sự kiện), Stock Type Code = '2' (Security Trading Snapshot Dimension), (New Listed Share Quantity > 0 hoặc Additional Listed Share Quantity > 0), GROUP BY Calendar Date Dimension.Year | Case 1 — measure New/Additional Listed Share Quantity; HNX và UPCoM cùng nguồn HNX, tách theo mã sàn TẠI NGÀY SỰ KIỆN (Listing Floor Code của Fact — O_VP_53). Mâu thuẫn Trường nguồn giá trị/khối lượng — O_VP_45 | READY |
| K_VP_211 | KL CP ĐKGD mới/bổ sung trên UPCoM | CP | Cơ sở | SUM(New Listed Share Quantity) + SUM(Additional Listed Share Quantity) trên Fact Listing Status Change Snapshot với Source System Code = 'HNX_LISTING_STATUS_CHANGE' và Listing Floor Code = '04' (UPCoM — sàn tại ngày sự kiện), Stock Type Code = '2' (Security Trading Snapshot Dimension), (New Listed Share Quantity > 0 hoặc Additional Listed Share Quantity > 0), GROUP BY Calendar Date Dimension.Year | Case 1 — measure New/Additional Listed Share Quantity; HNX và UPCoM cùng nguồn HNX, tách theo mã sàn TẠI NGÀY SỰ KIỆN (Listing Floor Code của Fact — O_VP_53). Mâu thuẫn Trường nguồn giá trị/khối lượng — O_VP_45 | READY |

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
    Fact_Listing_Status_Change_Snapshot {
        string Listing_Status_Change_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Security_Trading_Snapshot_Dimension_Id FK
        string Ticker_Symbol
        string Decision_Number
        date Decision_Date
        date Effective_Date
        date Listing_Last_Trading_Date
        bigint Delisted_Share_Quantity
        decimal Delisted_Share_Value
        bigint New_Listed_Share_Quantity
        bigint Additional_Listed_Share_Quantity
        decimal Listed_Share_Value
        decimal Additional_Listed_Share_Value
        string Exchange_Transfer
        string Delist_Transfer_Reason
        string Listing_Floor_Code
        string Source_System_Code
    }
    Calendar_Date_Dimension ||--o{ Fact_Listing_Status_Change_Snapshot : " "
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Listing_Status_Change_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Security_Trading_Snapshot_Dimension["Security Trading Snapshot Dimension"]
        Fact_Listing_Status_Change_Snapshot["Fact Listing Status Change Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 50"]
        R1["K_VP_160,208,209,210,211: Tổng quan thị trường >> Biểu đồ Thống kê cổ phiếu niêm yết mới"]
    end
    Calendar_Date_Dimension --> R1
    Security_Trading_Snapshot_Dimension --> R1
    Fact_Listing_Status_Change_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Security Trading Snapshot Dimension | 1 mã chứng khoán / hợp đồng phái sinh (SCD4A current-state); sở hữu bởi GSTT |
| Fact Listing Status Change Snapshot | 1 quyết định thay đổi niêm yết × 1 mã × 1 Sở (HNX gồm UPCoM, HOSE); PK Listing Status Change Snapshot Id = id dòng Atomic `listing_status_change`; kỳ theo ngày hiệu lực (Effective Date) |

#### Nhóm 51 - Tổng quan thị trường >> Biểu đồ Thống kê cổ phiếu hủy niêm yết

> Phân loại: **Phân tích**
> Atomic: `Listing Status Change` ← HNX.LISTING_STATUS_CHANGE / HOSE.LISTING_STATUS_CHANGE — **READY** (Fact mới `Fact Listing Status Change Snapshot`; nguồn riêng, KHÔNG phụ thuộc Securities Trade); loại chứng khoán lấy từ `Security Trading Snapshot Dimension` (GSTT); mã sàn TẠI NGÀY SỰ KIỆN lấy từ cột Listing Floor Code của Fact (Dimension là current-state, O_VP_53)

> **[GHI CHÚ 2026-10-28 — BA 'Trùng' và mâu thuẫn BA]** BA đánh 'Trùng' 4 dòng (nay là dòng 510–513; số cũ 484–487) nhưng không nêu trùng với chỉ tiêu nào (dòng 485–487 có 'Chỉ tiêu gốc: KL cổ phiếu hủy niêm yết/ĐKGD' — các Nhóm Báo cáo thường niên khác chưa mapping); thiết kế đủ 5 KPI nên Δ số lượng BA ↔ HLD ở Gate 10 là CÓ CHỦ Ý. Mâu thuẫn BA ghi ở O_VP_38 (công thức dòng 484 lặp bảng a; dòng 487 nhãn '04 --> HNX'; Kỳ lọc `report_year` vs năm `last_trading_date`); quy tắc ETL/khóa của Fact ở O_VP_39.

> **[CẬP NHẬT 2026-10-29 — BA VP cập nhật Nhóm 51, O_VP_44]** BA đổi: (1) Kỳ lọc `effective_date` (trước `report_year` / `last_trading_date`) → khóa kỳ `snpst_dt_dim_id` của Fact đổi sang `effective_dt`; (2) BỎ điều kiện `exchange_transfer NOT LIKE 'Có%'`; (3) nối MDDS cuối ngày TẠI ngày hiệu lực (`effective_date = tradingdate`) *(Lịch sử — từ 2026-11-02 BA nối phiên giao dịch gần nhất <= ngày hiệu lực, xem [CẬP NHẬT 2026-11-02])*, Nguồn thêm HOSE/MDDS; (4) nhãn '04 --> UPCOM' đã sửa. Fact thêm 4 cột niêm yết mới/bổ sung cho Nhóm 50 (K_VP_208–211). Công thức dòng 503 vẫn lặp bảng a.

> **[CẬP NHẬT 2026-11-02 — BA VP Nhóm 50/51, O_VP_53]** BA đổi: (1) Nhóm 50 dòng 506 (HOSE) thêm `s.floorcode = '10'`; (2) cả 2 Nhóm viết lại cách nối MDDS: NY/ĐKGD MỚI nối `first_trading_date = s_new.tradingdate`, NY/ĐKGD BỔ SUNG và HỦY nối PHIÊN GIAO DỊCH GẦN NHẤT <= `effective_date` (Nhóm 51 trước đó `effective_date = tradingdate`); (3) SQL BA nhóm theo sàn = `MAP(...)[IF(new_listed_shares > 0, s_new.floorcode, s_add.floorcode)]` — mã sàn là sàn TẠI NGÀY SỰ KIỆN. **Sửa:** Fact thêm cột Listing Floor Code (tính tại ETL đúng quy tắc trên; phiên gần nhất <= ngày hiệu lực KHÔNG giới hạn dưới, đúng SQL BA) và K_VP_209–211, K_VP_162–164 lọc theo cột này thay `Security Trading Snapshot Dimension.Floor Code` (current-state: mã đã chuyển sàn mang sàn hiện tại nên đếm sai sàn khi BA đã BỎ điều kiện loại chuyển sàn). Các câu 'khớp 100%' / 'tách theo mã sàn của Dimension' ở trên là *(Lịch sử — không đúng ở phần mã sàn)*. Dev cần ALTER + nạp lại Fact và flat `vp_fct_listing_status_change_snpst_flat`.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Từ năm · Đến năm

| Chỉ tiêu | Năm 1 | Năm 2 | … |
|---|---|---|---|
| SL mã cổ phiếu hủy niêm yết/ĐKGD (theo năm) | … | … | … |
| KL cổ phiếu hủy niêm yết trên HOSE | … | … | … |
| KL cổ phiếu hủy niêm yết trên HNX | … | … | … |
| KL cổ phiếu hủy ĐKGD trên UPCoM | … | … | … |

> ⚠️ Presentation Grain: 1 điểm biểu đồ = 1 Năm (Từ năm — Đến năm), toàn thị trường; chỉ tiêu KL tách theo sàn (HOSE / HNX / UPCoM). Storage Grain: 1 quyết định thay đổi niêm yết × 1 mã × 1 Sở — xem Bảng grain.

**Source:** `Fact Listing Status Change Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_160 | Kỳ (Năm) | — | Chiều | Calendar Date Dimension: Year (từ năm — đến năm) trên NGÀY HIỆU LỰC (Effective Date) của quyết định | Chiều — năm của ngày hiệu lực (BA 2026-10-29; O_VP_44) | READY |
| K_VP_161 | SL mã cổ phiếu hủy niêm yết/ĐKGD | Mã | Cơ sở | COUNT(Ticker Symbol) trên Fact Listing Status Change Snapshot với Stock Type Code = '2' (Security Trading Snapshot Dimension), Delisted Share Quantity > 0, GROUP BY Calendar Date Dimension.Year | Case 1 — đếm quyết định hủy niêm yết/ĐKGD của cổ phiếu (cả HNX, UPCoM, HOSE); BA công thức lặp bảng a — O_VP_38. Sổ lệnh không liên quan — nguồn Atomic `listing_status_change` (HNX/HOSE), READY. | READY |
| K_VP_162 | KL cổ phiếu hủy niêm yết trên HOSE | CP | Cơ sở | SUM(Delisted Share Quantity) trên Fact Listing Status Change Snapshot với Source System Code = 'HOSE_LISTING_STATUS_CHANGE', Listing Floor Code = '10' (HOSE — sàn tại ngày sự kiện), Stock Type Code = '2' (Security Trading Snapshot Dimension), Delisted Share Quantity > 0, GROUP BY Calendar Date Dimension.Year | Case 1 — measure Delisted Share Quantity; HNX và UPCoM cùng nguồn HNX, tách theo mã sàn TẠI NGÀY SỰ KIỆN (Listing Floor Code của Fact — O_VP_53), không dùng mã sàn current-state của Security Trading Snapshot Dimension. | READY |
| K_VP_163 | KL cổ phiếu hủy niêm yết trên HNX | CP | Cơ sở | SUM(Delisted Share Quantity) trên Fact Listing Status Change Snapshot với Source System Code = 'HNX_LISTING_STATUS_CHANGE' và Listing Floor Code = '02' (HNX — sàn tại ngày sự kiện), Stock Type Code = '2' (Security Trading Snapshot Dimension), Delisted Share Quantity > 0, GROUP BY Calendar Date Dimension.Year | Case 1 — measure Delisted Share Quantity; HNX và UPCoM cùng nguồn HNX, tách theo mã sàn TẠI NGÀY SỰ KIỆN (Listing Floor Code của Fact — O_VP_53), không dùng mã sàn current-state của Security Trading Snapshot Dimension. | READY |
| K_VP_164 | KL cổ phiếu hủy ĐKGD trên UPCoM | CP | Cơ sở | SUM(Delisted Share Quantity) trên Fact Listing Status Change Snapshot với Source System Code = 'HNX_LISTING_STATUS_CHANGE' và Listing Floor Code = '04' (UPCoM — sàn tại ngày sự kiện), Stock Type Code = '2' (Security Trading Snapshot Dimension), Delisted Share Quantity > 0, GROUP BY Calendar Date Dimension.Year | Case 1 — measure Delisted Share Quantity; HNX và UPCoM cùng nguồn HNX, tách theo mã sàn TẠI NGÀY SỰ KIỆN (Listing Floor Code của Fact — O_VP_53), không dùng mã sàn current-state của Security Trading Snapshot Dimension. BA 2026-10-29 đã sửa nhãn thành '04 --> UPCOM' (khớp thiết kế). | READY |

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
    Fact_Listing_Status_Change_Snapshot {
        string Listing_Status_Change_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Security_Trading_Snapshot_Dimension_Id FK
        string Ticker_Symbol
        string Decision_Number
        date Decision_Date
        date Effective_Date
        date Listing_Last_Trading_Date
        bigint Delisted_Share_Quantity
        decimal Delisted_Share_Value
        bigint New_Listed_Share_Quantity
        bigint Additional_Listed_Share_Quantity
        decimal Listed_Share_Value
        decimal Additional_Listed_Share_Value
        string Exchange_Transfer
        string Delist_Transfer_Reason
        string Listing_Floor_Code
        string Source_System_Code
    }
    Calendar_Date_Dimension ||--o{ Fact_Listing_Status_Change_Snapshot : " "
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Listing_Status_Change_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Security_Trading_Snapshot_Dimension["Security Trading Snapshot Dimension"]
        Fact_Listing_Status_Change_Snapshot["Fact Listing Status Change Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 51"]
        R1["K_VP_160,161,162,163,164: Tổng quan thị trường >> Biểu đồ Thống kê cổ phiếu hủy niêm yết"]
    end
    Calendar_Date_Dimension --> R1
    Security_Trading_Snapshot_Dimension --> R1
    Fact_Listing_Status_Change_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Security Trading Snapshot Dimension | 1 mã chứng khoán / hợp đồng phái sinh (SCD4A current-state); sở hữu bởi GSTT |
| Fact Listing Status Change Snapshot | 1 quyết định thay đổi niêm yết × 1 mã chứng khoán × 1 Sở (HNX gồm UPCoM, HOSE); PK Listing Status Change Snapshot Id = id dòng Atomic `listing_status_change_id` (Dạng A, direct); kỳ theo ngày hiệu lực (Effective Date) |

#### Nhóm 54 - Data Explorer Tài khoản giao dịch

> Phân loại: **Phân tích**
> Atomic: `Open Investor Account` / `Closed Investor Account` ← VSDC (dùng lại `Fact Investor Account Movement Snapshot`, Nhóm 40/42/43) và `Internal Statistical Report` ← ISS `TTLK01_1` (dùng lại `Fact Derivatives Account Snapshot`, Nhóm 41/44) — **READY** (Case 1/Case 2, không Fact mới)

**[GHI CHÚ 2026-11-05 — BA VP mapping Nhóm 54 (Data Explorer Tài khoản giao dịch)]** BA 550–556: thêm dòng Kỳ, Phân loại Trong nước / Nước ngoài, Loại nhà đầu tư; SQL ghép 2 thị trường — CO_SO (VSDC `open_investors`/`closed_investors`, chiều phân loại theo `investor_type` 3–6) và PHAI_SINH (ISS `TTLK01_1`, chỉ dòng tổng, `origin_type`/`investor_kind` NULL). Cả 2 nhánh đã có Fact: không thêm Fact/Dimension; nhãn Thị trường gán theo Fact nguồn. SL TK mới/đóng chỉ có thị trường cơ sở. Chi tiết O_VP_61. *(Số dòng BA cũ 595–601 đã đổi sang 550–556 ngày 2026-11-09 do BA dịch dòng.)*

**[CẬP NHẬT 2026-11-09 — đối chiếu SQL BA Nhóm 54 (kiểm kê điều kiện)]** Cơ sở: sự kiện mở/đóng theo ngày × loại NĐT <= cuối Đến kỳ; số dư đầu kỳ = Σ(mở − đóng) < đầu Từ kỳ; SL TK lũy kế = số dư + cộng dồn (mở − đóng) theo kỳ — thiết kế tính bằng Σ mở − Σ đóng <= cuối kỳ (cùng kết quả cho nhóm có nhãn). Loại NĐT '7'/'NA' (nhãn NULL): BA nối số dư đầu kỳ bằng '=' trên cột NULL nên MẤT số dư đầu kỳ, thiết kế không mất (O_VP_61). Phái sinh: bộ lọc TTLK01_1 (ICP, SUBMITTED/LATE_SUBMITTED, MONTHLY, cột 'TỔNG CỘNG') nằm trong etl_logic của Fact; kỳ M/Q/Y lấy tháng báo cáo mới nhất trong kỳ, kỳ D không có; Phân loại và Loại NĐT luôn NULL (WHERE của BA chỉ giữ 'TỔNG CỘNG'). `report_year BETWEEN` ('Lọc tạm giới hạn năm') chỉ là tối ưu, thay bằng lọc ngày.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Loại kỳ (Ngày / Tháng / Quý / Năm) · Từ kỳ — Đến kỳ

| Kỳ | Thị trường | Phân loại TN/NN | Loại NĐT | Số lượng tài khoản | SL TK mới | SL TK đóng |
|---|---|---|---|---|---|---|
| 2026-09 | Cơ sở | TRONG_NUOC | CA_NHAN | … | … | … |
| 2026-09 | Phái sinh | — | — | … | — | — |

> ⚠️ Presentation Grain: 1 dòng = 1 kỳ × 1 thị trường × (cơ sở: 1 phân loại trong nước / nước ngoài × 1 loại NĐT). Storage Grain: xem Bảng grain — mịn hơn (ngày × loại NĐT; dòng báo cáo × tháng), đạt Iso-Grain.

**Source:** `Fact Investor Account Movement Snapshot`, `Fact Derivatives Account Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_332 | Kỳ | — | Chiều | Calendar Date Dimension: chuỗi kỳ D / M / Q / Y từ Từ kỳ đến Đến kỳ | Tham số lọc 'Từ kỳ - Đến kỳ' (BA dòng 550); kỳ Ngày chỉ có thị trường cơ sở — O_VP_61 | READY |
| K_VP_333 | Thị trường | — | Chiều | 'Cơ sở' (dòng của Fact Investor Account Movement Snapshot) / 'Phái sinh' (dòng của Fact Derivatives Account Snapshot) | BA dòng 551; nhãn cố định theo Fact nguồn, không có cột thị trường (SQL BA xuất thẻ CO_SO / PHAI_SINH) — O_VP_61 | READY |
| K_VP_334 | Phân loại Trong nước / Nước ngoài | — | Chiều | Investor Type Code: 3, 5 → TRONG_NUOC; 4, 6 → NUOC_NGOAI; thị trường phái sinh = NULL | BA dòng 552; Case 1 — Investor Type Code của Fact Investor Account Movement Snapshot | READY |
| K_VP_335 | Loại nhà đầu tư | — | Chiều | Investor Type Code: 3, 4 → CA_NHAN; 5, 6 → TO_CHUC; thị trường phái sinh = NULL | BA dòng 553; Case 1 — Investor Type Code | READY |
| K_VP_336 | Số lượng tài khoản | TK | Cơ sở | Cơ sở: Σ Open Account Count − Σ Close Account Count lũy kế đến cuối kỳ; Phái sinh: Total Account Quantity tại tháng báo cáo mới nhất có dữ liệu trong kỳ (chỉ dòng tổng) | Case 2 — gộp 2 Fact (VSDC mở/đóng + ISS TTLK01_1); như K_VP_214 và K_VP_303 theo chiều của Data Explorer; nhóm nhãn NULL (loại NĐT '7'/'NA') lệch BA do nối '=' trên NULL — O_VP_61 | READY |
| K_VP_337 | Số lượng tài khoản mới | TK | Cơ sở | Σ Open Account Count trong kỳ (chỉ thị trường cơ sở) | Case 1 — measure Open Account Count; phái sinh không có (BA SQL chỉ nhánh cơ sở) — O_VP_61 | READY |
| K_VP_338 | Số lượng tài khoản đóng | TK | Cơ sở | Σ Close Account Count trong kỳ (chỉ thị trường cơ sở) | Case 1 — measure Close Account Count; phái sinh không có — O_VP_61 | READY |

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
    Fact_Investor_Account_Movement_Snapshot {
        string Investor_Account_Movement_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Investor_Type_Code
        int Open_Account_Count
        int Close_Account_Count
    }
    Fact_Derivatives_Account_Snapshot {
        string Derivatives_Account_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        int Row_Number
        int Total_Account_Quantity
        int Domestic_Account_Quantity
        int Foreign_Account_Quantity
    }
    Calendar_Date_Dimension ||--o{ Fact_Investor_Account_Movement_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Derivatives_Account_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Fact_Investor_Account_Movement_Snapshot["Fact Investor Account Movement Snapshot"]
        Fact_Derivatives_Account_Snapshot["Fact Derivatives Account Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 54"]
        R1["K_VP_332–338: Data Explorer: tài khoản giao dịch"]
    end
    Calendar_Date_Dimension --> R1
    Fact_Investor_Account_Movement_Snapshot --> R1
    Fact_Derivatives_Account_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Fact Investor Account Movement Snapshot | 1 ngày phát sinh (ngày mở hoặc ngày đóng tài khoản) × 1 loại NĐT VSDC (3–7, NA); PK Investor Account Movement Snapshot Id = hash (Snapshot Date Dimension Id, Investor Type Code) (Dạng B, A22); dựng lại toàn bộ mỗi lần chạy |
| Fact Derivatives Account Snapshot | 1 dòng báo cáo TTLK01_1 (Row Number) × 1 tháng báo cáo (ngày cuối tháng); PK Derivatives Account Snapshot Id = hash (Snapshot Date Dimension Id, Row Number, Source System Code) (Dạng B, A22); nạp lại cùng tháng ghi đè |

#### Nhóm 55 - Báo cáo VP_TK02 – TTCK bất thường

> Phân loại: **Phân tích**
> Atomic: Fact mới `Fact Listed Equity Snapshot` ← MDDS.JAD_STOCKINFOR (bản tin cuối ngày) + VSDC.OUTSTANDING_SHARES — **READY** (vốn hóa, số mã/giá trị niêm yết); tái dùng `Fact Market Index Snapshot` (QLKD); `Fact Macro Indicator Snapshot` (PTTT, MRMS.RISK_INDICATOR_VALUE kèm Unit Type Code; dùng lại Fact PTTT vì cùng grain, O_VP_41; phụ thuộc dev PTTT bổ sung PK và unit_tp_code — O_PTTT_57), `Fact Investor Group Trading Snapshot` (GTGD/KLGD cổ phiếu-CCQ, chứng quyền, HĐTL VN30; GT NĐTNN — Sổ lệnh HNX/HOSE, **[!] O_VP_1**), `Fact Derivative Contract Snapshot` (OI VN30, VSDC), `Fact Government Bond Trading Snapshot` (GT NĐTNN TPCP; 55c: GTGD bình quân TPCP), `Fact Investor Account Movement Snapshot` (55d: số tài khoản NĐT, VSDC); Fact mới `Fact Government Bond Listing Snapshot` ← Atomic `Gov Bond Listing` (55c niêm yết TPCP, **READY** từ 2026-11-05, O_VP_62)

> **[TIẾN ĐỘ 2026-10-28 — Nhóm 55 thiết kế theo 4 lô]** BA Nhóm 55 gồm 54 dòng (1 Chiều, 26 Cơ sở, 27 Phái sinh): **55a** (dòng 548, 592–601: ngày báo cáo, VN-Index/HNX-Index, vốn hóa, GDP) và **55b** (dòng 602–611, 621–642: GTGD bình quân cổ phiếu-CCQ, số mã/giá trị niêm yết, HĐTL VN30, chứng quyền, GT NĐTNN ròng) ĐÃ thiết kế — khối này; **55c** (TPCP, dòng 612–620) và **55d** (số tài khoản NĐT, dòng 643–644) chưa làm *(Lịch sử 2026-10-28 — đã thiết kế 2026-11-02, xem khối [TIẾN ĐỘ 2026-11-02] bên dưới)*. Ghi chú BA: dòng 601 'Đánh giá: Trùng' nhưng không nêu trùng với chỉ tiêu nào (thiết kế mới); dòng 549–591 của file BA là phần SQL tham khảo của dòng 548 bị tách dòng do quote lỗi trong CSV (không phải chỉ tiêu). Giả định/mâu thuẫn ở O_VP_40 (vốn hóa, ngày báo cáo), O_VP_41 (GDP — đóng, chọn thêm cột Unit Type Code vào Fact Macro Indicator Snapshot) và O_VP_42 (55b).

> **[TIẾN ĐỘ 2026-11-02 — Nhóm 55c, 55d]** BA VP sửa lại ô SQL dòng 574 (trước đó bị tách dòng do quote lỗi, sinh các 'Nhóm' giả) nên 54 dòng BA đã đủ; bổ sung 11 KPI còn thiếu (K_VP_260–270): **55c TPCP** — GTGD bình quân tháng/năm + % thay đổi (dòng 595–599, K_VP_260–264, READY, đọc `Fact Government Bond Trading Snapshot`, số phiên theo Is Trading Date — O_VP_52); niêm yết TPCP (BA dòng 665–668 hiện nay, K_VP_265–268) **READY từ 2026-11-05** — Atomic `Gov Bond Listing` đã có `rpt_year` (2026-11-04), đọc Fact mới `Fact Government Bond Listing Snapshot`, khóa Atomic chưa có tháng (O_VP_62) *(Lịch sử: PENDING [Nhóm 3] 2026-11-02 đến 2026-11-04 — O_VP_50)*; **55d tài khoản NĐT** — dòng 626–627, K_VP_269–270, READY, đọc `Fact Investor Account Movement Snapshot` (O_VP_46, O_VP_47). Δ số lượng BA ↔ HLD ở Gate 10 còn CÓ CHỦ Ý (các dòng 'Trùng'). Dòng 668 'Đánh giá: Trùng' không nêu chỉ tiêu trùng — KPI riêng.

**Mockup (suy từ BA — chưa có screenshot):**

Tham số: Ngày báo cáo

| Chỉ tiêu | Ngày báo cáo / bình quân kỳ | % so với kỳ trước | % so với cùng kỳ / cuối năm trước |
|---|---|---|---|
| Chỉ số VNIndex, HNX-Index | … | … | … |
| Vốn hóa thị trường cổ phiếu (Nghìn tỷ đồng) | … | — | … |
| GDP năm, Tỷ lệ vốn hóa/GDP năm | … | — | — |
| Cổ phiếu, CCQ - GTGD bình quân tháng / năm (Tỷ đồng) | … | … | … |
| Số mã niêm yết HNX, HOSE / ĐKGD UPCoM; Tổng giá trị niêm yết | … | — | … |
| TPCP - GTGD bình quân tháng / năm (Tỷ đồng) | … | … | … |
| TPCP - Số mã, giá trị niêm yết | … | — | … |
| HĐTL VN30 - KLGD bình quân tháng / năm; OI | … | … | … |
| CW - KLGD, GTGD bình quân tháng / năm | … | … | … |
| GT NĐTNN mua/bán ròng cổ phiếu-CCQ, TPCP tháng / năm (Tỷ đồng) | … | — | — |
| Số lượng tài khoản NĐT | … | — | … |

> ⚠️ Presentation Grain: 1 dòng = 1 chỉ tiêu tại 1 Ngày báo cáo (toàn thị trường). Storage Grain: chỉ số = 1 chỉ số × 1 ngày; vốn hóa/niêm yết = 1 mã × 1 ngày; GTGD/KLGD = 1 mã × 1 ngày × 1 sàn × 1 nhóm NĐT — xem Bảng grain. Mốc ngày và số phiên suy từ Ngày báo cáo tại presentation layer.

**Source:** `Fact Market Index Snapshot`, `Fact Listed Equity Snapshot`, `Fact Macro Indicator Snapshot`, `Fact Investor Group Trading Snapshot`, `Fact Derivative Contract Snapshot`, `Fact Government Bond Trading Snapshot`, `Fact Investor Account Movement Snapshot`, `Fact Government Bond Listing Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_VP_165 | Ngày báo cáo | — | Chiều | Calendar Date Dimension: Calendar Date = :report_date; mốc dẫn xuất :d_cur (ngày giao dịch gần nhất <= ngày báo cáo), :d_pm / :d_py (ngày giao dịch cuối cùng tháng/năm trước), :month_start, :pm_start/:pm_end, :lym_start/:lym_end, :year_start, :py_start/:py_end (mốc lịch) | Chiều — tham số báo cáo; mốc dẫn xuất tại presentation layer (O_VP_40) | READY |
| K_VP_166 | Chỉ số VNIndex | Điểm | Cơ sở | argMax(Market Index Value, Calendar Date) trên Fact Market Index Snapshot với Market Code = 'HOSE' tại :d_cur | Case 1 — measure Market Index Value (reuse QLKD, như K_VP_6); điểm tại :d_cur | READY |
| K_VP_167 | Chỉ số VNIndex - % so với cuối tháng trước | % | Phái sinh | (Market Index Value tại :d_cur − tại :d_pm) / tại :d_pm × 100, Market Code = 'HOSE' | Case 2 — tính tại presentation layer từ K_VP_166 tại 2 mốc ngày | READY |
| K_VP_168 | Chỉ số VNIndex - % so với cuối năm trước | % | Phái sinh | (Market Index Value tại :d_cur − tại :d_py) / tại :d_py × 100, Market Code = 'HOSE' | Case 2 — tính tại presentation layer từ K_VP_166 tại 2 mốc ngày | READY |
| K_VP_169 | Chỉ số HNX-Index | Điểm | Cơ sở | argMax(Market Index Value, Calendar Date) trên Fact Market Index Snapshot với Market Code = 'HNX' tại :d_cur | Case 1 — measure Market Index Value (reuse QLKD, như K_VP_7); điểm tại :d_cur | READY |
| K_VP_170 | Chỉ số HNX-Index - % so với cuối tháng trước | % | Phái sinh | (Market Index Value tại :d_cur − tại :d_pm) / tại :d_pm × 100, Market Code = 'HNX' | Case 2 — tính tại presentation layer từ K_VP_169 tại 2 mốc ngày | READY |
| K_VP_171 | Chỉ số HNX-Index - % so với cuối năm trước | % | Phái sinh | (Market Index Value tại :d_cur − tại :d_py) / tại :d_py × 100, Market Code = 'HNX' | Case 2 — tính tại presentation layer từ K_VP_169 tại 2 mốc ngày | READY |
| K_VP_172 | Vốn hóa thị trường cổ phiếu (Nghìn tỷ đồng) | Nghìn tỷ đồng | Cơ sở | SUM(Market Cap Value) trên Fact Listed Equity Snapshot với Stock Type Code = '2' (cổ phiếu), Floor Code ∈ (02, 04, 10) tại :d_cur | Case 1 — measure Market Cap Value (UPCoM: VWAP T+1, xem O_VP_40); lưu VND, hiển thị Nghìn tỷ đồng | READY |
| K_VP_173 | Vốn hóa thị trường cổ phiếu - % so với cuối năm trước | % | Phái sinh | (Σ Market Cap Value tại :d_cur − Σ tại :d_py) / Σ tại :d_py × 100, cổ phiếu, 3 sàn | Case 2 — tính tại presentation layer từ K_VP_172 tại 2 mốc ngày | READY |
| K_VP_174 | GDP năm | VND | Cơ sở | GDP năm (năm báo cáo − 1): ưu tiên kỳ Năm hơn Quý (Quý phải đủ 4 kỳ, cộng 4 quý), mỗi giá trị nhân hệ số đơn vị (mã 3 ×1e9, 8 ×1, 23 ×1e6) về VND | Case 1 — Indicator Value × hệ số đơn vị (Unit Type Code); đọc Fact Macro Indicator Snapshot (PTTT, dùng lại; cần Unit Type Code) — O_VP_41 | READY |
| K_VP_175 | Tỷ lệ vốn hóa/GDP năm | % | Phái sinh | Σ Market Cap Value tại :d_cur / GDP năm (VND) × 100 | Case 2 — tính tại presentation layer từ K_VP_172 và K_VP_174 | READY |
| K_VP_176 | Cổ phiếu, CCQ - Giá trị giao dịch bình quân tháng báo cáo (Tỷ đồng) | Tỷ đồng | Phái sinh | Σ giá trị khớp (Buy Value, nhóm ALL) cổ phiếu + CCQ trên HOSE, HNX, UPCoM / số phiên giao dịch (tháng báo cáo (từ đầu tháng đến ngày báo cáo)); số phiên = số ngày cdr_dt_dim.is_trading_date = 'Y' có dữ liệu | Case 2 — Σ / số phiên tại presentation layer; BA ghi 'Chỉ tiêu cơ sở'. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_177 | Cổ phiếu, CCQ - Giá trị giao dịch bình quân tháng báo cáo - % thay đổi so với bình quân tháng trước | % | Phái sinh | (bình quân/phiên kỳ báo cáo − bình quân/phiên tháng trước) / bình quân/phiên tháng trước × 100 | Case 2 — tính tại presentation layer từ K_VP_176 tại 2 kỳ. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_178 | Cổ phiếu, CCQ - Giá trị giao dịch bình quân tháng báo cáo - % so với bình quân cùng tháng năm trước | % | Phái sinh | (bình quân/phiên kỳ báo cáo − bình quân/phiên cùng tháng năm trước) / bình quân/phiên cùng tháng năm trước × 100 | Case 2 — tính tại presentation layer từ K_VP_176 tại 2 kỳ. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_179 | Cổ phiếu, CCQ - Giá trị giao dịch bình quân năm báo cáo | Tỷ đồng | Phái sinh | Σ giá trị khớp (Buy Value, nhóm ALL) cổ phiếu + CCQ trên HOSE, HNX, UPCoM / số phiên giao dịch (năm báo cáo (từ đầu năm đến ngày báo cáo)); số phiên = số ngày cdr_dt_dim.is_trading_date = 'Y' có dữ liệu | Case 2 — Σ / số phiên tại presentation layer; BA ghi 'Chỉ tiêu cơ sở'. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_180 | Cổ phiếu, CCQ - Giá trị giao dịch bình quân năm báo cáo - % thay đổi so với bình quân năm trước | % | Phái sinh | (bình quân/phiên kỳ báo cáo − bình quân/phiên năm trước) / bình quân/phiên năm trước × 100 | Case 2 — tính tại presentation layer từ K_VP_179 tại 2 kỳ. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_181 | Cổ phiếu, CCQ - Số mã niêm yết trên HNX, HOSE | Mã | Cơ sở | COUNT(Ticker Symbol) trên Fact Listed Equity Snapshot với Floor Code ∈ (02, 10), Stock Type Code ∈ (2, 3, 6) tại :d_cur | Case 1 — đếm mã trên Fact Listed Equity Snapshot tại :d_cur | READY |
| K_VP_182 | Cổ phiếu - Số mã cổ phiếu ĐKGD trên UPCoM | Mã | Cơ sở | COUNT(Ticker Symbol) trên Fact Listed Equity Snapshot với Floor Code = '04', Stock Type Code = '2' tại :d_cur | Case 1 — đếm mã cổ phiếu UPCoM tại :d_cur | READY |
| K_VP_183 | Cổ phiếu, CCQ - Tổng giá trị niêm yết, ĐKGD (Nghìn tỷ đồng) | Nghìn tỷ đồng | Cơ sở | SUM(Listed Share Value) trên Fact Listed Equity Snapshot với Stock Type Code ∈ (2, 3, 6) tại :d_cur | Case 1 — measure Listed Share Value = Listed Share Quantity × 10.000 | READY |
| K_VP_184 | Cổ phiếu, CCQ - Tổng giá trị niêm yết, ĐKGD - % so với cuối năm trước | % | Phái sinh | (Σ Listed Share Value tại :d_cur − tại :d_py) / tại :d_py × 100 | Case 2 — tính tại presentation layer từ K_VP_183 tại 2 mốc ngày | READY |
| K_VP_185 | Cổ phiếu, CCQ - Tổng giá trị niêm yết, ĐKGD - % so với GDP năm | % | Phái sinh | Σ Listed Share Value tại :d_cur / GDP năm (VND) × 100 | Case 2 — tính tại presentation layer từ K_VP_183 và K_VP_174; BA ghi 'Chỉ tiêu cơ sở' | READY |
| K_VP_260 | TPCP - GTGD bình quân tháng báo cáo (Tỷ đồng) | Tỷ đồng | Phái sinh | Σ Trading Value (OUTRIGHT + REPO) trên Fact Government Bond Trading Snapshot trong tháng báo cáo (từ đầu tháng đến ngày báo cáo) / số phiên giao dịch | Case 2 — Σ / số phiên tại presentation layer; BA ghi 'Chỉ tiêu cơ sở'; số phiên theo Is Trading Date (proxy) — O_VP_52 | READY |
| K_VP_261 | TPCP - GTGD bình quân tháng báo cáo - % so với bình quân tháng trước | % | Phái sinh | (GTGD TPCP bình quân/phiên tháng báo cáo − bình quân/phiên tháng trước) / bình quân/phiên tháng trước × 100 | Case 2 — từ K_VP_260 tại 2 khoảng ngày; BA dòng 596 | READY |
| K_VP_262 | TPCP - GTGD bình quân tháng báo cáo - % so với bình quân tháng cùng kỳ năm trước | % | Phái sinh | (GTGD TPCP bình quân/phiên tháng báo cáo − bình quân/phiên cùng tháng năm trước) / bình quân/phiên cùng tháng năm trước × 100 | Case 2 — từ K_VP_260 tại 2 khoảng ngày; BA dòng 597 — O_VP_52 | READY |
| K_VP_263 | TPCP - GTGD bình quân năm báo cáo (Tỷ đồng) | Tỷ đồng | Phái sinh | Σ Trading Value (OUTRIGHT + REPO) trên Fact Government Bond Trading Snapshot từ đầu năm đến ngày báo cáo / số phiên giao dịch | Case 2 — Σ / số phiên tại presentation layer; BA ghi 'Chỉ tiêu cơ sở'; BA dòng 598 — O_VP_52 | READY |
| K_VP_264 | TPCP - GTGD bình quân năm báo cáo - % so với bình quân năm trước | % | Phái sinh | (GTGD TPCP bình quân/phiên năm báo cáo − bình quân/phiên năm trước) / bình quân/phiên năm trước × 100 | Case 2 — từ K_VP_263 tại 2 khoảng ngày; BA dòng 599 | READY |
| K_VP_265 | TPCP - Số mã trái phiếu niêm yết | Mã | Cơ sở | COUNT(Bond Code) trên Fact Government Bond Listing Snapshot của tháng báo cáo chứa ngày báo cáo | Case 1 — đếm Bond Code của tháng báo cáo (năm và tháng của ngày báo cáo); BA dòng 665 — O_VP_62 | READY |
| K_VP_266 | TPCP - Giá trị niêm yết trái phiếu (Nghìn tỷ đồng) | Nghìn tỷ đồng | Cơ sở | SUM(Listed Bond Value) của tháng báo cáo chứa ngày báo cáo | Case 1 — measure Listed Bond Value; Fact lưu VND, chia 1e12 ở presentation layer; BA dòng 666 — O_VP_62 | READY |
| K_VP_267 | TPCP - Giá trị niêm yết trái phiếu - % so với cuối năm trước | % | Phái sinh | (GT niêm yết tháng báo cáo − GT niêm yết tháng cuối năm trước) / GT niêm yết tháng cuối năm trước × 100 | Case 2 — từ K_VP_266 tại 2 mốc (tháng của ngày báo cáo, tháng 12 năm trước); BA dòng 667 — O_VP_62 | READY |
| K_VP_268 | TPCP - Giá trị niêm yết trái phiếu - % so với GDP năm | % | Phái sinh | GT niêm yết TPCP tháng báo cáo / GDP năm gần nhất × 100 (GDP theo K_VP_174) | Case 2 — từ K_VP_266 và K_VP_174 (2 Fact khác nhau, ghép ở presentation layer); BA dòng 668 'Trùng' nhưng không nêu chỉ tiêu trùng → KPI riêng — O_VP_62 | READY |
| K_VP_186 | HĐTL VN30 - KLGD bình quân/phiên tháng báo cáo | HĐ | Phái sinh | Σ khối lượng khớp (Buy Volume, nhóm ALL) của mọi HĐTL chỉ số VN30 (sàn 03, loại 4, tài sản cơ sở VN30) / số phiên giao dịch (tháng báo cáo (từ đầu tháng đến ngày báo cáo)); số phiên = số ngày cdr_dt_dim.is_trading_date = 'Y' có dữ liệu | Case 2 — Σ / số phiên tại presentation layer; BA ghi 'Chỉ tiêu cơ sở'. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_187 | HĐTL VN30 - KLGD bình quân tháng báo cáo - % so với bình quân tháng trước | % | Phái sinh | (bình quân/phiên kỳ báo cáo − bình quân/phiên tháng trước) / bình quân/phiên tháng trước × 100 | Case 2 — tính tại presentation layer từ K_VP_186 tại 2 kỳ. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_188 | HĐTL VN30 - KLGD bình quân tháng báo cáo - % so với bình quân tháng cùng kỳ năm trước | % | Phái sinh | (bình quân/phiên kỳ báo cáo − bình quân/phiên cùng tháng năm trước) / bình quân/phiên cùng tháng năm trước × 100 | Case 2 — tính tại presentation layer từ K_VP_186 tại 2 kỳ. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_189 | HĐTL VN30 - KLGD bình quân năm báo cáo | HĐ | Phái sinh | Σ khối lượng khớp (Buy Volume, nhóm ALL) của mọi HĐTL chỉ số VN30 (sàn 03, loại 4, tài sản cơ sở VN30) / số phiên giao dịch (năm báo cáo (từ đầu năm đến ngày báo cáo)); số phiên = số ngày cdr_dt_dim.is_trading_date = 'Y' có dữ liệu | Case 2 — Σ / số phiên tại presentation layer; BA ghi 'Chỉ tiêu cơ sở'. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_190 | HĐTL VN30 - KLGD bình quân năm báo cáo - % so với bình quân năm trước | % | Phái sinh | (bình quân/phiên kỳ báo cáo − bình quân/phiên năm trước) / bình quân/phiên năm trước × 100 | Case 2 — tính tại presentation layer từ K_VP_189 tại 2 kỳ. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_191 | HĐTL VN30 - Khối lượng mở (OI) ngày báo cáo | HĐ | Cơ sở | SUM(Open Interest Quantity) trên Fact Derivative Contract Snapshot với hợp đồng VN30 (Floor Code = '03', Stock Type Code = '4', Underlying Symbol = 'VN30') tại :d_cur | Case 1 — measure Open Interest Quantity (reuse Nhóm Fact phái sinh VP) | READY |
| K_VP_192 | HĐTL VN30 - Khối lượng mở (OI) - % so với cuối tháng trước | % | Phái sinh | (OI tại :d_cur − OI tại :d_pm) / OI tại :d_pm × 100, HĐTL VN30 | Case 2 — tính tại presentation layer từ K_VP_191 tại 2 mốc ngày | READY |
| K_VP_193 | HĐTL VN30 - Khối lượng mở (OI) - % so với cuối năm trước | % | Phái sinh | (OI tại :d_cur − OI tại :d_py) / OI tại :d_py × 100, HĐTL VN30 | Case 2 — tính tại presentation layer từ K_VP_191 tại 2 mốc ngày | READY |
| K_VP_194 | CW - KLGD bình quân tháng báo cáo | CW | Phái sinh | Σ khối lượng khớp (Buy Volume, nhóm ALL) chứng quyền HOSE / số phiên giao dịch (tháng báo cáo (từ đầu tháng đến ngày báo cáo)); số phiên = số ngày cdr_dt_dim.is_trading_date = 'Y' có dữ liệu | Case 2 — Σ / số phiên tại presentation layer; BA ghi 'Chỉ tiêu cơ sở'. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_195 | CW - KLGD bình quân tháng báo cáo - % so với bình quân tháng trước | % | Phái sinh | (bình quân/phiên kỳ báo cáo − bình quân/phiên tháng trước) / bình quân/phiên tháng trước × 100 | Case 2 — tính tại presentation layer từ K_VP_194 tại 2 kỳ. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_196 | CW - KLGD bình quân tháng báo cáo - % so với bình quân tháng cùng kỳ năm trước | % | Phái sinh | (bình quân/phiên kỳ báo cáo − bình quân/phiên cùng tháng năm trước) / bình quân/phiên cùng tháng năm trước × 100 | Case 2 — tính tại presentation layer từ K_VP_194 tại 2 kỳ. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_197 | CW - GTGD bình quân tháng báo cáo (Tỷ đồng) | Tỷ đồng | Phái sinh | Σ giá trị khớp (Buy Value, nhóm ALL) chứng quyền HOSE / số phiên giao dịch (tháng báo cáo (từ đầu tháng đến ngày báo cáo)); số phiên = số ngày cdr_dt_dim.is_trading_date = 'Y' có dữ liệu | Case 2 — Σ / số phiên tại presentation layer; BA ghi 'Chỉ tiêu cơ sở'. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_198 | CW - GTGD bình quân tháng báo cáo - % so với bình quân tháng trước | % | Phái sinh | (bình quân/phiên kỳ báo cáo − bình quân/phiên tháng trước) / bình quân/phiên tháng trước × 100 | Case 2 — tính tại presentation layer từ K_VP_197 tại 2 kỳ. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_199 | CW - GTGD bình quân tháng báo cáo - % so với bình quân tháng cùng kỳ năm trước | % | Phái sinh | (bình quân/phiên kỳ báo cáo − bình quân/phiên cùng tháng năm trước) / bình quân/phiên cùng tháng năm trước × 100 | Case 2 — tính tại presentation layer từ K_VP_197 tại 2 kỳ. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_200 | CW - KLGD bình quân năm báo cáo (Tỷ đồng) | CW | Phái sinh | Σ khối lượng khớp (Buy Volume, nhóm ALL) chứng quyền HOSE / số phiên giao dịch (năm báo cáo (từ đầu năm đến ngày báo cáo)); số phiên = số ngày cdr_dt_dim.is_trading_date = 'Y' có dữ liệu | Case 2 — Σ / số phiên tại presentation layer; BA ghi 'Chỉ tiêu cơ sở'. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_201 | CW - KLGD bình quân năm báo cáo - % so với bình quân năm trước | % | Phái sinh | (bình quân/phiên kỳ báo cáo − bình quân/phiên năm trước) / bình quân/phiên năm trước × 100 | Case 2 — tính tại presentation layer từ K_VP_200 tại 2 kỳ. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_202 | CW - GTGD bình quân năm báo cáo (Tỷ đồng) | Tỷ đồng | Phái sinh | Σ giá trị khớp (Buy Value, nhóm ALL) chứng quyền HOSE / số phiên giao dịch (năm báo cáo (từ đầu năm đến ngày báo cáo)); số phiên = số ngày cdr_dt_dim.is_trading_date = 'Y' có dữ liệu | Case 2 — Σ / số phiên tại presentation layer; BA ghi 'Chỉ tiêu cơ sở'. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_203 | CW - GTGD bình quân năm báo cáo - % so với bình quân năm trước | % | Phái sinh | (bình quân/phiên kỳ báo cáo − bình quân/phiên năm trước) / bình quân/phiên năm trước × 100 | Case 2 — tính tại presentation layer từ K_VP_202 tại 2 kỳ. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_204 | GT NĐTNN mua/bán ròng cổ phiếu, CCQ tháng báo cáo (Tỷ đồng) | Tỷ đồng | Phái sinh | Σ Buy Value − Σ Sell Value trên Fact Investor Group Trading Snapshot với Investor Group Code = 'FOREIGN', Stock Type Code ∈ (2, 3, 6), Market Id Code ∈ (STK, STX, UPX), trong tháng báo cáo | Case 2 — mua − bán tại presentation layer; BA ghi 'Chỉ tiêu cơ sở'. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_205 | GT NĐTNN mua/bán ròng cổ phiếu, CCQ năm báo cáo (Tỷ đồng) | Tỷ đồng | Phái sinh | Σ Buy Value − Σ Sell Value trên Fact Investor Group Trading Snapshot với Investor Group Code = 'FOREIGN', Stock Type Code ∈ (2, 3, 6), Market Id Code ∈ (STK, STX, UPX), trong năm báo cáo | Case 2 — mua − bán tại presentation layer; BA ghi 'Chỉ tiêu cơ sở'. [!] Nguồn Securities Trade (sổ lệnh khớp) — O_VP_1 | READY |
| K_VP_206 | GT NĐTNN mua/bán ròng trái phiếu (TPCP) tháng báo cáo (Tỷ đồng) | Tỷ đồng | Phái sinh | Σ Foreign Buy Value − Σ Foreign Sell Value trên Fact Government Bond Trading Snapshot trong tháng báo cáo | Case 2 — mua − bán tại presentation layer; BA ghi 'Chỉ tiêu cơ sở' | READY |
| K_VP_207 | GT NĐTNN mua/bán ròng trái phiếu (TPCP) năm báo cáo (Tỷ đồng) | Tỷ đồng | Phái sinh | Σ Foreign Buy Value − Σ Foreign Sell Value trên Fact Government Bond Trading Snapshot trong năm báo cáo | Case 2 — mua − bán tại presentation layer; BA ghi 'Chỉ tiêu cơ sở' | READY |
| K_VP_269 | Số lượng tài khoản NĐT | TK | Phái sinh | Σ Open Account Count − Σ Close Account Count trên Fact Investor Account Movement Snapshot với ngày ≤ ngày báo cáo (mọi loại NĐT) | Case 2 — lũy kế mở − đóng, như K_VP_214 (Nhóm 40); BA ghi 'Chỉ tiêu cơ sở' — O_VP_46 | READY |
| K_VP_270 | Số lượng tài khoản của NĐT - % so với cuối năm trước | % | Phái sinh | (Số TK lũy kế đến ngày báo cáo − số TK lũy kế đến ngày cuối năm trước) / số TK lũy kế đến ngày cuối năm trước × 100 | Case 2 — từ K_VP_269 tại 2 mốc ngày; BA dòng 627 — O_VP_46 | READY |

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
    Fact_Listed_Equity_Snapshot {
        string Listed_Equity_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Industry_Dimension_Id FK
        string Ticker_Symbol
        string Floor_Code
        string Stock_Type_Code
        string Fund_Type_Code
        bigint Outstanding_Share_Quantity
        bigint Listed_Share_Quantity
        decimal Listed_Share_Value
        decimal Close_Price
        decimal Reference_Price
        bigint Next_Day_Volume_Weighted_Average_Price
        decimal Market_Price
        decimal Market_Cap_Value
        string Source_System_Code
    }
    Fact_Macro_Indicator_Snapshot {
        string Macro_Indicator_Value_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Macro_Indicator_Code
        string Macro_Indicator_Name
        string Period_Type_Code
        string Period_Label
        decimal Indicator_Val
        string Unit_Type_Code
        decimal Prev_Period_Val
        decimal Pct_Change
        decimal Yoy_Pct_Change
        decimal Ma_N_Val
        string Source_System_Code
    }
    Fact_Investor_Group_Trading_Snapshot {
        string Investor_Group_Trading_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Security_Trading_Snapshot_Dimension_Id FK
        string Industry_Dimension_Id FK
        string Security_Symbol_Code
        string Market_Id_Code
        string Investor_Group_Code
        bigint Buy_Volume
        decimal Buy_Value
        bigint Sell_Volume
        decimal Sell_Value
    }
    Fact_Derivative_Contract_Snapshot {
        string Derivative_Contract_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Security_Trading_Snapshot_Dimension_Id FK
        string Ticker_Symbol
        bigint Open_Interest_Quantity
        decimal Close_Price
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
    Fact_Investor_Account_Movement_Snapshot {
        string Investor_Account_Movement_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Investor_Type_Code
        int Open_Account_Count
        int Close_Account_Count
    }
    Fact_Government_Bond_Listing_Snapshot {
        string Government_Bond_Listing_Snapshot_Id PK
        string Snapshot_Date_Dimension_Id FK
        string Bond_Code
        int Report_Year
        int Report_Month
        bigint Listed_Bond_Quantity
        decimal Listed_Bond_Value
    }
    Calendar_Date_Dimension ||--o{ Fact_Market_Index_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Listed_Equity_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Macro_Indicator_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Derivative_Contract_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Government_Bond_Trading_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Investor_Account_Movement_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Government_Bond_Listing_Snapshot : " "
    Market_Index_Dimension ||--o{ Fact_Market_Index_Snapshot : " "
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Investor_Group_Trading_Snapshot : " "
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Derivative_Contract_Snapshot : " "
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        Calendar_Date_Dimension["Calendar Date Dimension"]
        Market_Index_Dimension["Market Index Dimension"]
        Security_Trading_Snapshot_Dimension["Security Trading Snapshot Dimension"]
        Fact_Market_Index_Snapshot["Fact Market Index Snapshot"]
        Fact_Listed_Equity_Snapshot["Fact Listed Equity Snapshot"]
        Fact_Macro_Indicator_Snapshot["Fact Macro Indicator Snapshot"]
        Fact_Investor_Group_Trading_Snapshot["Fact Investor Group Trading Snapshot"]
        Fact_Derivative_Contract_Snapshot["Fact Derivative Contract Snapshot"]
        Fact_Government_Bond_Trading_Snapshot["Fact Government Bond Trading Snapshot"]
        Fact_Investor_Account_Movement_Snapshot["Fact Investor Account Movement Snapshot"]
        Fact_Government_Bond_Listing_Snapshot["Fact Government Bond Listing Snapshot"]
    end
    subgraph RPT["Báo cáo — Nhóm 55"]
        R1["K_VP_165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,260,261,262,263,264,265,266,267,268,269,270: Báo cáo VP_TK02 – TTCK bất thường"]
    end
    Calendar_Date_Dimension --> R1
    Market_Index_Dimension --> R1
    Security_Trading_Snapshot_Dimension --> R1
    Fact_Market_Index_Snapshot --> R1
    Fact_Listed_Equity_Snapshot --> R1
    Fact_Macro_Indicator_Snapshot --> R1
    Fact_Investor_Group_Trading_Snapshot --> R1
    Fact_Derivative_Contract_Snapshot --> R1
    Fact_Government_Bond_Trading_Snapshot --> R1
    Fact_Investor_Account_Movement_Snapshot --> R1
    Fact_Government_Bond_Listing_Snapshot --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Calendar Date Dimension | 1 ngày dương lịch (Conformed Dimension) |
| Market Index Dimension | 1 tổ hợp Market Id + Market Code (SCD4A current-state); sở hữu bởi QLKD |
| Security Trading Snapshot Dimension | 1 mã chứng khoán / hợp đồng phái sinh (SCD4A current-state); sở hữu bởi GSTT |
| Fact Market Index Snapshot | 1 chỉ số (Market Code) × 1 ngày giao dịch — bản ghi cuối ngày; sở hữu bởi QLKD |
| Fact Listed Equity Snapshot | 1 mã chứng khoán niêm yết/đăng ký giao dịch (cổ phiếu, chứng chỉ quỹ/ETF, chứng quyền, TPDN niêm yết — stock_tp_code 1/2/3/4/6, không gồm phái sinh) × 1 ngày giao dịch (bản tin cuối ngày MDDS JAD_STOCKINFOR); PK Listed Equity Snapshot Id = hash (Snapshot Date Dimension Id, Ticker Symbol, Source System Code) (Dạng B, A22) |
| Fact Macro Indicator Snapshot | 1 chỉ tiêu vĩ mô × 1 kỳ công bố (PK Macro Indicator Value Id = id dòng Atomic `cl_risk_indicator_value`, Dạng A, A22); PTTT sở hữu, VP dùng lại (O_VP_41) |
| Fact Investor Group Trading Snapshot | 1 mã chứng khoán / hợp đồng × 1 ngày giao dịch × 1 sàn (Market Id Code) × 1 nhóm NĐT (ALL / FOREIGN / PROPRIETARY); PK Investor Group Trading Snapshot Id = hash toàn bộ cột grain (Dạng B, A22) |
| Fact Derivative Contract Snapshot | 1 mã hợp đồng phái sinh × 1 ngày giao dịch; PK Derivative Contract Snapshot Id = hash (Snapshot Date, Ticker Symbol) (Dạng B, A22) |
| Fact Government Bond Trading Snapshot | 1 ngày giao dịch × 1 loại sổ lệnh (Order Book Type Code ∈ OUTRIGHT, REPO); PK Government Bond Trading Snapshot Id = hash (Snapshot Date Dimension Id, Order Book Type Code) (Dạng B, A22) |
| Fact Investor Account Movement Snapshot | 1 ngày phát sinh (ngày mở hoặc ngày đóng tài khoản) × 1 loại NĐT VSDC (3–7, NA); PK Investor Account Movement Snapshot Id = hash (Snapshot Date Dimension Id, Investor Type Code) (Dạng B, A22); dựng lại toàn bộ mỗi lần chạy |
| Fact Government Bond Listing Snapshot | 1 mã trái phiếu Chính phủ niêm yết × 1 tháng báo cáo (Report Year, Report Month; Atomic `gov_bond_listing` ← HNX.GOV_BOND_LISTED_LIST); PK Government Bond Listing Snapshot Id = hash (Bond Code, Report Year, Report Month, Source System Code) (Dạng B, A22); khóa ngày = ngày cuối tháng báo cáo |

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
| O_VP_4 | Nhóm 1 - BA chưa mapping xong (mâu thuẫn BA) | [ĐÃ ĐÓNG 2026-10-28 — BA cập nhật Nhóm 1/2: Mô tả bỏ chứng quyền, Điều kiện + SQL lọc stocktype IN ('2','3','6'); thiết kế lọc Stock Type Code IN ('2','3','6') ở K_VP_5, 9–17] (Lịch sử) Nhóm 1–2: Mô tả/Điều kiện ghi thị trường cổ phiếu bao gồm cổ phiếu, chứng chỉ quỹ, chứng quyền (chỉ lọc market_id); SQL tham khảo lọc thêm `stocktype = '2'` (chỉ cổ phiếu) qua CTE stock_daily_eod. | Theo Mô tả/Điều kiện: không lọc Stock Type Code. Nếu BA chọn SQL: thêm Stock Type Code = '2' qua Security Trading Snapshot Dimension. | K_VP_5,9-17 | BA Team | Closed 2026-10-28 |
| O_VP_5 | Nhóm 1 - BA chưa mapping xong (mâu thuẫn BA) | Loại kỳ 'D': SQL BA lấy kỳ trước = ngày lịch liền trước (`DATE_SUB(startdate, 1)`), không phải phiên giao dịch liền trước — Thứ Hai so với Chủ nhật cho kết quả NULL. | Thiết kế % thay đổi đúng SQL BA; BA xác nhận có đổi sang phiên giao dịch liền trước không. | K_VP_20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,72,74,78,80,82,91,95,97,99,101,103,105,107,109,111,114 | BA Team | Open |
| O_VP_6 | Nhóm 1 - BA chưa mapping xong (lỗi nhập liệu BA CSV) | (a) Dòng 43/53/63/73 (KLGD % thay đổi từng sản phẩm) ghi bảng nguồn OI VSDC thay vì Sổ lệnh; (b) cột Chỉ tiêu gốc dòng 75–79 lệch hàng; (c) dòng 92/93 (Nhóm 5) nhãn 'HĐTL VN100' nhưng điều kiện `productgrpid = 'FBX'` (TPCP); (d) dòng 110 (Nhóm 6) Mô tả ghi 'HĐTL TPCP' cho Toàn thị trường; (e) % thay đổi KL ròng: dòng 39 chia ABS(kỳ trước), dòng 49/59/69/79 không dùng ABS. | Thiết kế theo Mô tả/Điều kiện từng dòng, bỏ qua ô lệch; (e) giữ nguyên công thức từng dòng. BA sửa CSV và xác nhận ABS. | K_VP_22,28,32,38,42,48-49,51-52,58,62-68 | BA Team | Open |
| O_VP_7 | Nhóm 5 - Datamart chưa thiết kế Fact/Dim | Security Trading Snapshot Dimension (GSTT) thiếu Product Group Id (Atomic `product_group_id`) để nhận diện HĐTL TPCP (`productgrpid = 'FBX'`). | reuse chuyển thành partial: thêm cột Product Group Id (nullable) vào Dimension; khi sửa LLD phải grep mọi KPI GSTT/PTTT/NDTNN dùng dimension này (H11). | K_VP_18-70 | Datamart Modeling Team | Open |
| O_VP_8 | Kỹ thuật Kiến trúc HLD | Chưa có screenshot Dashboard VP; Mockup mọi Nhóm suy từ BA. | Mockup chỉ minh họa; Presentation Grain xác định theo cột Độ chi tiết của BA. | K_VP_1-114 | BA Team / Datamart Modeling Team | Open |
| O_VP_9 | Kỹ thuật Kiến trúc HLD | Phạm vi HLD hiện tại: Lô 1 = Nhóm 1–10 (Nhóm 1–6 duyệt 2026-10-25; Nhóm 7–10 TPDN niêm yết/riêng lẻ bổ sung 2026-10-25); Lô 2 = Nhóm 11–16 (TPDN riêng lẻ Nhóm 11–13, TPCP Nhóm 14–16) bổ sung 2026-10-25. Nhóm 32–37 (Done) bổ sung ở Lô 3; Nhóm 17–31 và 38–55 chưa có mapping (Trạng thái mapping trống) sẽ vào PENDING [Nhóm 1 - BA chưa mapping xong] *(Lịch sử 2026-10-25 — từ 2026-11-02 Nhóm 19, 47–49 đã Done và được thiết kế ở Lô 4 cùng phần 55c/55d; Nhóm 17, 18, 20–31, 38, 39, 41, 44–46, 52–54 vẫn chưa Done)*. Thiết kế VP cũ bị thay hoàn toàn; BA CSV đổi cấu trúc (delimiter ',', 25 cột; từ 2026-11-02 26 cột — BA thêm lại cột đầu 'UC' = tên use case) — đã cập nhật `ba_column_profile.yaml`. 9 dòng BA 415–423 thuộc Nhóm 37 (Trái phiếu NĐTNN) có cột TT trống nên parser gán khóa '?' — xử lý khi thiết kế Nhóm 37 (S2). Quy ước đánh số KPI: K_VP_1–114 đã dùng hết, không còn ID trống. K_VP_91–111 cấp cho Lô 2 (Nhóm 11 = K_VP_91–101, Nhóm 14 = K_VP_102–111; Nhóm 12, 13, 15, 16 chỉ reuse); K_VP_112–114 cấp cuối dải cho dòng BA CSV còn thiếu của Nhóm 7 (H17, O_VP_18). Lô 3 (Nhóm 32–37) cấp ID mới tiếp sau K_VP_114. | Làm tuần tự theo đợt (giới hạn 6 Nhóm/phiên). | — | Datamart Modeling Team | Open |
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
| O_VP_33 | Nhóm 1 - BA chưa mapping xong (mâu thuẫn BA) | Nhóm 1–2 (BA 2026-10-28): điều kiện nối sổ lệnh HNX với danh sách cổ phiếu viết `s.symbol = h.issue_code`, trong khi Atomic/Gate A17: ISSUE_CODE của sổ lệnh HNX lưu mã ISIN (không phải ticker) — nối theo symbol sẽ rơi giao dịch HNX/UPCOM. | Thiết kế nối `Security Trading Snapshot Dimension.isin_code = issue_code` cho HNX (đã là cách Fact đang tra `security_trading_snpst_dim_id`); cần BA xác nhận `issue_code` HNX là ISIN hay symbol. | K_VP_5, 9–17 | BA Team | Open |
| O_VP_34 | Nhóm 32 - BA lỗi copy / mâu thuẫn BA | Nhóm 32 (BA 2026-10-28): (a) dòng 382 (GT bán NĐTNN - TPDN niêm yết) công thức dùng `h.buy_account_number` (phía mua) cho 'GTGD NĐTNN Bán'; dòng 383 (TPDN riêng lẻ) lọc `row_path = '…GIÁ TRỊ MUA'`; dòng 384 (TPCP) ghi 'GT NĐTNN mua' với `buying_account_no` — đều là bản sao điều kiện phía MUA; (b) dòng 369/377 (GT mua/bán NĐTNN tổng) Phân loại 'Chỉ tiêu cơ sở' nhưng Mô tả là Σ 6 loại tài sản. | (a) Thiết kế theo ý định phía bán (sell_account_number / 'GIÁ TRỊ BÁN' / selling_account_no) — dùng `sell_val` / `foreign_sell_val` của Fact; (b) Tính chất Phái sinh (cùng O_VP_31(b)). Cần BA xác nhận (a). | K_VP_115–134 | BA Team | Open |
| O_VP_35 | Nhóm 33/37 - Chiều 'Loại chứng khoán' của trái phiếu | Nhóm 33 (dòng 385) và Nhóm 37 (dòng 412): chiều 'Loại chứng khoán' nối `jad_stockinfor` và `flat_report` nhưng BA không liệt kê tập giá trị cho trái phiếu; 3 Fact trái phiếu VP không có cột loại trái phiếu. | Thiết kế: cổ phiếu/CCQ/chứng quyền/phái sinh lấy từ Security Trading Snapshot Dimension.Stock Type Name; trái phiếu dùng nhãn cố định theo Fact nguồn (TPDN niêm yết / TPDN riêng lẻ / TPCP). Cần BA xác nhận tập giá trị (có tách TPCP theo kỳ hạn/loại không). **[CẬP NHẬT 2026-11-05: BA dòng 418 (Nhóm 37) đã Done với tập giá trị TPCP / TPDN niêm yết / TPDN riêng lẻ / Tổng TP, khớp nhãn theo Fact nguồn → K_VP_147 READY; Nhóm 33 (K_VP_135) dùng cùng nhãn, chờ BA xác nhận tương tự.]** | K_VP_135, K_VP_147 | BA Team | Open |
| O_VP_36 | Nhóm 33/34 - Giá trị giao dịch phái sinh của NĐTNN | Nhóm 33 dòng 396 / Nhóm 34 dòng 403 'GT mua/bán NĐTNN - Giao dịch phái sinh': BA chỉ ghi nguồn sổ lệnh (trade_book) + jad_stockinfor, không nêu công thức GT (giá × KL × hệ số nhân hợp đồng?) và không ghi mã sàn DVX. | Thiết kế dùng Buy Value / Sell Value của Fact Investor Group Trading Snapshot với Market Id Code = 'DVX', Stock Type Name = 'Phái sinh' (cùng nguồn Sổ lệnh — O_VP_1); cần BA xác nhận công thức GT phái sinh và cách nhận diện NĐTNN (ký tự 4 tài khoản) cho HĐTL. | K_VP_140, K_VP_141 | BA Team | Open |
| O_VP_37 | Nhóm 35 - Đường nối ngành của cổ phiếu | Nhóm 35 dòng 405 'Ngành' (Trùng theo tên với Nhóm 8): BA lấy ngành cổ phiếu qua IDS (jad_stockinfor stocktype = '2' → company_profiles → categories; CTCK/CTQLQ đại chúng mặc định 07000). Fact Investor Group Trading Snapshot không có FK ngành (chỉ Fact TPDN niêm yết có industry_dim_id). | [ĐÃ ĐÓNG 2026-10-28 — Vuong chọn thêm FK] Fact Investor Group Trading Snapshot thêm cột Industry Dimension Id (nullable, chỉ dòng cổ phiếu có ngành; CTCK/CTQLQ = 07000), flat denormalize industry_code/industry_nm; không đổi grain/PK; dev cần ETL + ALTER TABLE + nạp lại lịch sử. (Lịch sử: phương án nối qua Operational Security Reference không dùng.) | K_VP_142, K_VP_143 | Data Modeler | Closed 2026-10-28 |
| O_VP_38 | Nhóm 51 - Mâu thuẫn BA | Nhóm 51 (BA 2026-10-28): (a) dòng 484 công thức 'COUNT(a.ticker_symbol) + COUNT(a.ticker_symbol)' lặp bảng a (HNX), thiếu bảng b (HOSE); Trường nguồn ghi alias n/o không khớp a/b; (b) dòng 487 (UPCoM) ghi `s.floorcode = '04' --> HNX` — mã sàn 04 là UPCoM; (c) [ĐÃ ĐÓNG 2026-10-29 — BA đổi sang `effective_date`, xem O_VP_44] dòng 483 Kỳ lọc `report_year` của 2 bảng nguồn còn các chỉ tiêu lọc năm của `last_trading_date`; (d) dòng 484–487 'Đánh giá: Trùng' nhưng không nêu trùng với chỉ tiêu nào. | (a) Đếm mọi quyết định của cả 2 Sở; (b) UPCoM = Floor Code '04'; (c) dùng năm của `last_trading_date` (khóa ngày của Fact); (d) giữ đủ 5 KPI. Cần BA xác nhận (a), (c). | K_VP_160–164 | BA Team | Open |
| O_VP_39 | Nhóm 51 - Quy tắc ETL / khóa Fact hủy niêm yết | Fact Listing Status Change Snapshot ← Atomic `listing_status_change` (HNX, HOSE): (a) PK Atomic = hash(số quyết định, ngày quyết định, mã) KHÔNG có src_stm_code — trùng giữa 2 Sở coi là không xảy ra; (b) Atomic có `rpt_month` (báo cáo tháng) nhưng chưa rõ định dạng/độ trễ — thiết kế nạp đủ lịch sử theo `decision_dt <= :etl_date` (upsert PK) thay vì theo tháng báo cáo; (c) `exchange_transfer` (bắt đầu bằng 'Có' = chuyển sàn) chưa kiểm giá trị thật; NULL bị loại bởi `NOT LIKE 'Có%'` như SQL BA; (d) *(Lịch sử — từ 2026-10-29 FK ngày = `effective_dt`)* FK ngày = `last_trading_dt`, để trống nếu chưa có/ chưa nằm trong lịch ngày; flat INNER JOIN lịch nên dòng không có ngày không vào flat. | Dev kiểm (a) trùng khóa, (c) tập giá trị `exchange_transfer`; Data Modeler xác nhận (b). | Fact Listing Status Change Snapshot, K_VP_160–164 | Dev / Data Modeler | Open |
| O_VP_40 | Nhóm 55a - Vốn hóa cổ phiếu & ngày báo cáo (giả định/lệch BA) | Fact Listed Equity Snapshot (mới, grain 1 mã × 1 ngày) + K_VP_165–173: (1) UPCoM tính vốn hóa theo VWAP ngày T lấy ở bản tin MDDS ngày giao dịch liền sau (BA dòng 598); Atomic `vol_weighted_average_price` (MDDS VWAP, bigint) có chú thích YAML 'tên/diễn giải suy từ tên cột, cần MDDS xác nhận' và nguồn là FLOAT cast bigint; (2) dòng ngày T chỉ đầy đủ `next_day_vol_weighted_average_price`/`market_price`/`market_cap_val` khi đã có bản tin T+1 → ETL mỗi ngày upsert dòng D và D-1; flat DML chuẩn (Gate 4) chỉ làm mới `cdr_dt = :etl_date` nên dev cần chạy lại DML với ngày giao dịch liền trước; (3) khối lượng lưu hành nối ĐÚNG ngày VSDC `transaction_dt = trading_dt` theo BA, khác Fact Stock Portfolio Snapshot (GSTT) lùi về bản ghi gần nhất — nếu VSDC không gửi hằng ngày thì vốn hóa NULL; (4) BA lấy lịch ngày giao dịch từ sổ lệnh HNX trade_book ∪ jad_marketinfor, Datamart dùng `cdr_dt_dim.is_trading_date` (UNION Market Index/Security Trading/Securities Trade); (5) không dùng `total_market_cap_vsdc` của Fact Market Risk Snapshot (PTTT): grain theo ngày, UPCoM dùng giá đóng cửa, KL lưu hành lùi ngày; (6) VN-Index lọc `market_code = 'HOSE'` (CLAUDE.md mục 9, không đổi sang index_nm); (7) file BA CSV: dòng 549–591 là phần câu lệnh tham khảo của dòng 548 bị tách thành dòng do quote lỗi, không phải chỉ tiêu. | (1) Dùng `vol_weighted_average_price` như VWAP của bản tin T+1; NULL khi chưa có T+1 → vốn hóa UPCoM không cộng (như BA); (2) dev upsert D-1 + chạy lại flat DML; (3) giữ nối đúng ngày theo BA, báo lệch với GSTT; (4) dùng `is_trading_date`; mốc :d_cur/:d_pm/:d_py tính tại presentation layer. Data Modeler/MDDS xác nhận (1), (3); BA xác nhận (4) và sửa CSV (7); dev xác nhận (2). | K_VP_165–173, Fact Listed Equity Snapshot | Data Modeler / MDDS / Dev / BA | Open |
| O_VP_41 | Nhóm 55a - GDP năm thiếu cột đơn vị (PENDING K_VP_174–175) | BA dòng 600–601: GDP năm gần nhất (năm báo cáo − 1) từ MRMS `risk_indicator_value` (`GDP_VN`), ưu tiên kỳ Năm hơn Quý (đủ 4 quý), quy đổi VND theo `unit_code` ('3' Tỷ VND ×1e9, '8' VND ×1, '23' Triệu VND ×1e6); Fact Macro Indicator Snapshot (PTTT) chỉ có `indicator_val`, không có cột đơn vị dù Atomic `cl_risk_indicator_value.unit_tp_code` (MRMS UNIT_CODE) có. Câu lệnh tham khảo BA cố định `ds_snpst_dt = '2026-10-23'` (bản chụp ngày cố định, lỗi BA) và lọc `deleted = '0'`; dòng 601 'Đánh giá: Trùng' nhưng không nêu trùng với chỉ tiêu nào. | [ĐÃ ĐÓNG 2026-10-28 — Vuong chọn (a); ĐỔI HƯỚNG 2026-11-03 lần 1 — dev PTTT bỏ `unit_tp_code` khỏi `fct_macro_indicator_snpst` (model 11 cột) nên VP đã tách `fct_macro_indicator_unit_snpst`; ĐỔI HƯỚNG LẦN 2 2026-11-03 (Data Modeler: dùng lại Fact PTTT nếu cùng grain hoặc không lệch SUM — đã kiểm: cùng grain 1 chỉ tiêu × 1 kỳ công bố, PK = id dòng Atomic `cl_risk_indicator_value`, cùng nguồn MRMS, bảng VP chỉ là tập con 7/13 cột) → BỎ Fact VP, dùng lại `fct_macro_indicator_snpst` (phương án A, O_PTTT_57); các câu dưới về 'thêm cột vào Fact PTTT / khối ER PTTT / flat PTTT / ALTER flat PTTT' ÁP DỤNG LẠI] Fact Macro Indicator Snapshot (PTTT) thêm cột Unit Type Code (`unit_tp_code` ← MRMS UNIT_CODE; LLD per-table + 4 khối ER HLD PTTT + flat PTTT); K_VP_174/175 và K_VP_185 READY: GDP quy đổi VND theo mã đơn vị, ưu tiên Năm > Quý đủ 4 kỳ. Dev PTTT cần thêm `macro_indicator_val_id` và `unit_tp_code` vào model dtm_fct_macro_indicator_snpst + flat pttt_fct_macro_indicator_snpst_flat (ALTER flat PTTT); VP không có model/flat riêng; mã đơn vị 23 (Triệu VND) trong câu lệnh BA không có trong danh sách mô tả của Atomic (1–10) — Data Modeler/MRMS xác nhận; QLQ Nhóm 7 có thể dùng cột mới để đóng O_QLQ_44 (chưa sửa). (Lịch sử: K_VP_174/175 PENDING. Đề xuất (a) thêm `unit_tp_code` vào `fct_macro_indicator_snpst` (PTTT) + flat PTTT, KPI quy đổi theo đơn vị và ưu tiên Năm > Quý — khuyến nghị, đồng thời đóng O_QLQ_44 (giả định Tỷ VND ×1e9 của QLQ Nhóm 7); (b) giữ giả định Tỷ VND ×1e9 cho cả VP, đặt READY. Chờ Data Modeler chọn (a)/(b). | K_VP_174, K_VP_175, Fact Macro Indicator Snapshot (PTTT) | Data Modeler / BA / Dev PTTT | Open — chờ dev PTTT thêm 2 cột (mở lại 2026-11-03) |
| O_VP_42 | Nhóm 55b - Giả định/mâu thuẫn BA (K_VP_176–207) | (1) GTGD/KLGD bình quân, GT NĐTNN ròng cổ phiếu-CCQ, chứng quyền, HĐTL VN30 đọc Fact Investor Group Trading Snapshot (nhóm ALL = tổng khớp; FOREIGN = NĐTNN) — nguồn Sổ lệnh (Securities Trade) bị gỡ khỏi Atomic, phụ thuộc O_VP_1; (2) số phiên = số ngày Is Trading Date = 'Y' có dữ liệu (proxy như O_VP_30), BA dùng COUNT(trade_date) của sổ lệnh ∪ MDDS; (3) BA lọc đúng ngày báo cáo ở dòng 607 và 626 (số mã niêm yết, OI) — thiết kế dùng :d_cur (ngày giao dịch gần nhất <= ngày báo cáo) như dòng 609; (4) dòng 608 Mô tả 'Cổ phiếu + CCQ' nhưng SQL/tên chỉ tiêu chỉ stocktype 2 → theo SQL; (5) lỗi copy/nhãn BA: dòng 606, 636, 638 Mô tả ghi 'tháng báo cáo' thay 'năm'; dòng 631, 634 ghi 'HĐTL VN30' cho chứng quyền; dòng 635 nhãn '(Tỷ đồng)' cho khối lượng; (6) giá trị niêm yết dùng mệnh giá cố định 10.000 đồng (BA) — chứng chỉ quỹ/ETF cũng 10.000; (7) HĐTL VN30 nhận diện bằng Security Trading Snapshot Dimension (Floor Code = '03', Stock Type Code = '4', Underlying Symbol = 'VN30'), chứng quyền bằng Floor Code = '10' + Stock Type Code = '4' — dimension current-state nên hợp đồng/chứng quyền đã hết hạn giữ thuộc tính cuối; (8) GT NĐTNN ròng TPCP đọc Fact Government Bond Trading Snapshot (outright + repo lần 1, như K_VP_106–108); BA dòng 641–642 ghi `buying_investor_account IN ('E','F')` — thiết kế nhận diện theo ký tự thứ 4 số tài khoản như Fact; (9) Fact Listed Equity Snapshot thêm 2 cột Listed Share Quantity, Listed Share Value — dev cần ETL + ALTER flat + nạp lại lịch sử. | Theo từng điểm ở cột Vấn đề; (1) READY có điều kiện O_VP_1 như Nhóm 1–16, 32–37. Data Modeler/BA xác nhận (2), (3), (4), (6); BA sửa (5). | K_VP_176–207, Fact Listed Equity Snapshot | Data Modeler / BA / Dev | Open |
| O_VP_43 | Quy chuẩn LLD | Nhóm 36 (BA 2026-10-29 cập nhật SQL: CTE `stock_daily_eod` → `stock_portfolio`, `stocktype = '2'`, HNX nối `h.issue_code = s.symbolisin`): thiết kế 2026-10-28 gộp Cổ phiếu / Chứng quyền / Chứng chỉ quỹ / ETF theo `Stock Type Name` trong khi Mô tả BA ('Tổng GTGD mua/bán cổ phiếu của NĐTNN') và SQL chỉ lấy CỔ PHIẾU. | Đã sửa 2026-10-29: K_VP_144–146 lọc `Security Trading Snapshot Dimension.Stock Type Code` = '2' (Cổ phiếu), GROUP BY kỳ; bỏ chiều Stock Type Name. Đối soát với staging nên chạy lại khoảng Từ kỳ - Đến kỳ để thấy số thay đổi. | K_VP_144–146 | Datamart Modeling Team | Resolved |
| O_VP_44 | Nhóm 50/51 - BA cập nhật 2026-10-30 | BA VP cung cấp SQL chính thức cho Nhóm 50 & 51 (Báo cáo thường niên): (a) Kỳ theo NGÀY HIỆU LỰC (`effective_date`); (b) Đã bỏ điều kiện `exchange_transfer NOT LIKE 'Có%'`; (c) Đã sửa lỗi mất mã khi nối MDDS bằng cách dùng `s_new` (tại `first_trading_date`) và `s_add` (giao dịch gần nhất $\le$ `effective_date`); (d) Đã sửa lỗi đếm lặp bảng bằng `COUNT(IF(...))` trên bảng union `ls` cả HOSE và HNX. | Thiết kế Datamart khớp hoàn toàn: dùng Fact `fct_listing_status_change_snpst` liên kết `cdr_dt_dim` (theo `effective_dt`), `security_trading_snpst_dim` (lọc `stock_tp_code = '2'`). Đã chốt và đóng item *(Cập nhật 2026-11-02: phần mã sàn KHÔNG khớp — Dimension là current-state; đã sửa bằng cột Listing Floor Code của Fact, xem O_VP_53)*. | K_VP_160–164, K_VP_208–211 | Datamart Modeling Team | Resolved |
| O_VP_45 | Nhóm 50 - Mâu thuẫn BA | Nhóm 50: Trước đây BA mâu thuẫn giữa Trường nguồn ghi GIÁ TRỊ (`listed_value`) và Mô tả ghi KHỐI LƯỢNG (`new_listed_shares`). | SQL chính thức 2026-10-30 của BA đã CHỐT sử dụng KHỐI LƯỢNG (`SUM(ls.new_listed_shares)`, `SUM(ls.additional_listed_shares)`). Khớp 100% với thiết kế của Datamart. Đã đóng item. | K_VP_208–211 | Datamart Modeling Team | Resolved |
| O_VP_46 | Nhóm 40/42/43 - Fact mới và giả định | Cụm Tài khoản giao dịch (BA 2026-10-29, VSDC): Fact mới `Fact Investor Account Movement Snapshot` (1 ngày phát sinh × 1 loại NĐT; cột `open_account_count`, `close_account_count`) gộp Atomic `open_investor_account` + `closed_investor_account`. Giả định / điểm cần chốt: (1) số TK lũy kế = Σ mở − Σ đóng đến ngày (đúng công thức BA) — không bắt trạng thái mở lại sau đóng; (2) lịch ngày `cdr_dt_dim` phải phủ ngày mở sớm nhất của VSDC, sự kiện ngoài lịch có FK trống làm lệch số lũy kế; (3) Fact dựng lại TOÀN BỘ mỗi lần chạy (sự kiện đóng/mở khai báo lùi ngày), flat TRUNCATE + INSERT; (4) loại NĐT: 3 CN trong nước, 4 CN nước ngoài, 5 Pháp nhân trong nước, 6 Pháp nhân nước ngoài, 7 Nhà nước, khác → 'NA'; BA dòng 456 'Tổ chức nước ngoài' ghi `investor_type = '5'` (gõ nhầm, SQL BA dùng '6'); 'Tổ chức trong nước' chỉ gồm '5' (Nhà nước '7' không có KPI riêng nhưng nằm trong tổng); (5) BA Mô tả dòng 439 'so với cuối THÁNG trước' còn SQL dùng cuối KỲ trước — theo SQL; (6) dòng 468/470 'Loại dữ liệu: Chưa có CSDL - Map biểu mẫu' mâu thuẫn Nguồn VSDC + bảng `open/closed_investors`; (7) Atomic `investor_tp_code` mô tả 'Cá nhân/Tổ chức' nhưng giá trị là mã 3–7 theo BA; (8) KPI Nhóm 42/43 trùng TÊN với Nhóm 40 nhưng là chuỗi kỳ (khác ngữ nghĩa) nên KPI riêng. | Theo công thức BA; ghi vào K_VP_212–238. [YÊU CẦU DEV] tạo bảng + flat `vp_fct_investor_account_movement_snpst_flat` (TRUNCATE + INSERT) và nạp; kiểm phạm vi `cdr_dt_dim`. | K_VP_212–238 | BA Team / Dev | Open |
| O_VP_47 | Nhóm 41/44/55d - BA chưa mapping xong | Nhóm 41 (8 dòng) và Nhóm 44 (2 dòng) — tài khoản giao dịch thị trường PHÁI SINH: BA cấu trúc lại (thêm dòng Kỳ, đổi tên dòng % thành 'so với kỳ trước/cùng kỳ năm trước', thêm Nhóm 43/44) nhưng 'Mapping (nghiệp vụ)' = #NAME?, Trạng thái mapping để trống, nguồn là biểu mẫu VSDC 'BM 45_TTLK_01 — Báo cáo về tình hình đóng mở tài khoản' >> Sheet2 chưa có Atomic. Nhóm 55 'Số lượng tài khoản NĐT' (BA 643–644) nay công thức giản lược COUNT(open_investors) − COUNT(closed_investors) với ngày ≤ ngày báo cáo — cùng nguồn Fact tài khoản mới (O_VP_46), lô 55d chưa thiết kế *(Lịch sử — đã thiết kế 2026-11-02: K_VP_269–270, O_VP_52)*. | **[ĐÃ ĐÓNG 2026-11-05 — BA mapping Nhóm 41/44 xong, nguồn ISS `TTLK01_1`: thiết kế K_VP_300–331, giả định ở O_VP_58–59]** *(Lịch sử — giữ PENDING Nhóm 41/44 chờ BA mapping và Atomic cho biểu mẫu;)* Nhóm 55d (K_VP_269–270) đã đọc `Fact Investor Account Movement Snapshot` (Σ mở − Σ đóng đến ngày báo cáo / cuối năm trước) từ 2026-11-02. | K_VP_300–331 (Nhóm 41, 44); K_VP_269–270 (Nhóm 55d) | BA Team | Resolved |
| O_VP_48 | Nhóm 19 - Mâu thuẫn BA | Nhóm 19 (BA 2026-11-02, vốn hóa cổ phiếu): (a) dòng 258 Mô tả ghi mẫu số 'vốn hóa tại ngày cuối NĂM trước' trong khi tên dòng ('so với KỲ trước'), SQL (`/ marketcap_prev`) và dòng 264/267/270 dùng cuối KỲ trước; dòng 259 Mô tả 'vốn hóa tại ngày cuối năm này' (SQL dùng marketcap_cur tại ngày giao dịch cuối kỳ); dòng 265/268/271 Mô tả ghi tử số '− Vốn hóa kỳ trước' nhưng mẫu số 'năm trước' (lẫn kỳ trước / cuối năm trước); (b) dòng 261–262 (đơn vị điểm %) SQL `marketcap_cur/gdp_cur − marketcap_prev/gdp_prev` KHÔNG nhân 100 trong khi dòng 260 nhân 100; (c) SQL tham khảo lỗi: CTE `params` thiếu dấu phẩy trước `YEAR(q.period_end) - 1 AS gdp_year_cur`, `GROUPING SETS ((e.period_tag, e.san), …)` dùng alias `san` không tồn tại (cột là `floorcode`); (d) dòng 263/266 Điều kiện `s.floorcode = 'HOSE'`/'HNX' (tên sàn) nhưng MDDS lưu mã 10/02 (dòng 256, 269 dùng mã); (e) SQL GDP cố định `ds_snpst_dt = '2026-10-23'` và `deleted = '0'` (cùng O_VP_41); (f) lịch ngày giao dịch trong SQL = ngày có Sổ lệnh HNX (`trade_book`) ∪ bản tin `jad_marketinfor`, thiết kế dùng Is Trading Date của Calendar Date Dimension (cùng O_VP_30); (g) 13 dòng 'Đánh giá: Trùng' (258, 259, 261–271) không nêu trùng với chỉ tiêu nào. | Theo tên dòng + SQL: (a) mẫu số = vốn hóa kỳ trước (dòng 258, 264, 267, 270) / cuối năm trước (dòng 259, 265, 268, 271), tử số = vốn hóa tại ngày giao dịch cuối kỳ; (b) nhân 100 (điểm %); (c) hiểu theo ý định, không chép lỗi cú pháp; (d) dùng mã sàn 10/02/04; (e) như O_VP_41; (f) Is Trading Date làm proxy; (g) thiết kế KPI riêng từng dòng. BA sửa Mô tả/SQL và xác nhận (a), (b). | K_VP_239–254 | BA Team | Open |
| O_VP_49 | Nhóm 47/48 - Thiếu nguồn Atomic / Ngoại lai (khóa, định dạng kỳ hạn) | Fact mới `Fact Government Bond Bidding Result Snapshot` ← Atomic `gov_bond_bidding_result` (HNX.GOV_BOND_OFFERING, draft): (a) khóa thay thế `gov_bond_bidding_result_id` chỉ băm từ `BIDDING_SESSION` (BK = đợt đấu thầu) trong khi 1 đợt có nhiều mã trái phiếu/kỳ hạn — nếu loader upsert theo khóa này thì mỗi đợt chỉ còn 1 dòng và bình quân gia quyền K_VP_255–256 sai; (b) `bond_term` là chuỗi tự do ('10 năm', '26 tuần', '6 tháng'): ETL quy đổi tuần/52, tháng/12, còn lại là năm theo CASE của BA, chưa kiểm tập giá trị thật (chuỗi không có số → NULL: loại khỏi tử số nhưng giá trị trúng thầu vẫn nằm trong mẫu số như SQL BA); (c) HNX gửi theo báo cáo tháng (`rpt_month`) nên đợt có ngày phát hành trong quá khứ đến muộn: Fact nạp đủ lịch sử theo PK (`issue_dt <= :etl_date`), flat TRUNCATE + INSERT (không lọc `cdr_dt = :etl_date`); (d) SQL BA không lọc trạng thái/loại trái phiếu: mọi dòng `gov_bond_offering` (kể cả đợt không trúng thầu, `winning_value` = 0 hoặc NULL) đều vào tử/mẫu. | Giữ theo BA. Atomic team bổ sung `bond_code` (và phương thức đấu thầu) vào BK; dev xác nhận tập giá trị `bond_term` trên UAT. [YÊU CẦU DEV] tạo bảng `fct_government_bond_bidding_result_snpst` + flat `vp_fct_government_bond_bidding_result_snpst_flat` (TRUNCATE + INSERT) và nạp lịch sử. | K_VP_160,255–256 | Data Architecture / Atomic Team, Dev | Open |
| O_VP_50 | Nhóm 49/55 - Thiếu nguồn Atomic / Ngoại lai (danh mục TPCP niêm yết) | KPI niêm yết TPCP (Nhóm 49 dòng 501; Nhóm 55 dòng 600–603): SQL BA lọc `report_year` và `report_month` của `uat_hnx_stg.gov_bond_listed_list` (tháng mới nhất trong năm / tháng của ngày báo cáo / tháng cuối năm trước), nhưng schema UAT (`Source/HNX_UAT_schema.txt`), BRD (`brd_HNX_gov_bond_listed_list.yaml`) và Atomic `gov_bond_listing` chỉ có `report_month` (string), KHÔNG có năm; khóa thay thế `gov_bond_listing_id` chỉ băm từ `BOND_CODE` nên mỗi mã chỉ còn dòng tháng mới nhất — mất lịch sử theo tháng cần cho 'cuối năm trước' và 'tháng của ngày báo cáo' (cùng dạng O_VP_12/15/26). | **[ĐÃ MỞ 2026-11-05: Atomic `gov_bond_listing` đã có `rpt_year`, `rpt_month`, `rpt_day` (int) từ 2026-11-04 nên K_VP_257, 265–268, 271–272 READY, Fact mới `Fact Government Bond Listing Snapshot`; phần khóa/BK chưa gồm tháng chuyển sang O_VP_62]** *(Lịch sử — yêu cầu ban đầu của Data Modeler 2026-11-02, không giả định định dạng `rpt_month`:)* Atomic bổ sung năm báo cáo (`rpt_year` hoặc `rpt_month` dạng yyyyMM) và đưa tháng báo cáo vào khóa/BK `gov_bond_listing`; sau đó thiết kế `Fact Government Bond Listing Snapshot` (grain 1 mã TPCP × 1 tháng báo cáo; Listed Bond Quantity, Listed Bond Value = KL × 100.000 đ) và mở K_VP_257, 265–268. Dev xác nhận UAT có cột `report_year` hay không. | K_VP_257,265–268,271–272 | Data Architecture / Atomic Team | Resolved một phần |
| O_VP_51 | Nhóm 47–49 - Mâu thuẫn/lỗi BA | (a) Nhóm 47 và 48 dùng chung SQL BA (đặt ở dòng 496), SQL xuất cả `lai_suat_phat_hanh_bq_tpcp` và `ky_han_phat_hanh_bq_tpcp`; Điều kiện dòng 496/498 ghi `CAST(DATE_FORMAT(issue_date, 'yyyy')` (thiếu đóng ngoặc), Trường nguồn ghi `g.issue_date` trong khi bảng nguồn là `o`; (b) Nhóm 49 dòng 503 (GTGD Repos) Điều kiện ghi `o.trading_date` và nhãn 'GTGD Outright = SUM(r.first_settlement_value)' (chép từ dòng 502; SQL dùng `r.trading_date`); (c) dòng 501 (Giá trị niêm yết TPCP) 'Đánh giá: Trùng' nhưng không nêu trùng chỉ tiêu nào (Nhóm 55 dòng 601 cùng nguồn); (d) dòng 502/503 và SQL Nhóm 49 đọc 2 bảng staging `outright_order_book` / `repo_order_book`, thiết kế đọc Atomic `Bond Order Book` (O_VP_32); (e) SQL Nhóm 49 chọn 'tháng mới nhất của năm' bằng `DENSE_RANK() ... ORDER BY report_month DESC, ds_snpst_dt DESC`, Điều kiện dòng 501 bỏ `ds_snpst_dt`. | Theo Mô tả/Điều kiện/SQL: (a) bỏ qua lỗi cú pháp; (b) GTGD Repos = Σ `first_settlement_val` của sổ lệnh REPO, lọc năm theo ngày giao dịch của sổ lệnh REPO; (c) KPI riêng; (d) như O_VP_32; (e) K_VP_257 đã READY từ 2026-11-05 (Fact Government Bond Listing Snapshot, O_VP_62) nên điều kiện này áp dụng được. BA sửa CSV và xác nhận. | K_VP_160,255–259 | BA Team | Open |
| O_VP_52 | Nhóm 55c/55d - Giả định và lỗi BA (K_VP_260–270) | (1) TPCP GTGD bình quân (K_VP_260–264): GTGD = Σ Outright + Σ Repo (thanh toán lần 1) đọc `Fact Government Bond Trading Snapshot`; BA đếm số phiên bằng số ngày có Sổ lệnh HNX `trade_book` hoặc bản tin MDDS `jad_marketinfor` ('do không đủ dữ liệu sổ lệnh TPCP'), thiết kế dùng `cdr_dt_dim.is_trading_date` (cùng O_VP_30/42); (2) dòng 597 Mô tả ghi nhãn 'so với bình quân tháng trước' nhưng là cùng tháng năm trước (lỗi copy); dòng 598 Điều kiện tham chiếu 'GTGD bình tháng năm báo cáo' (gõ lệch tên chỉ tiêu) và nhãn '(Tỷ đồng)' trong khi SQL xuất VND; dòng 596, 597, 599 SQL chia ABS(mẫu số), Mô tả không dùng; (3) dòng 595, 598, 626 ghi 'Chỉ tiêu cơ sở' nhưng là Σ / số phiên hoặc hiệu 2 Σ → thiết kế Phái sinh; (4) dòng 603 'Đánh giá: Trùng' không nêu chỉ tiêu trùng; (5) tài khoản NĐT (dòng 626–627) đọc `Fact Investor Account Movement Snapshot`, giả định như O_VP_46. | Theo tên dòng + Điều kiện + SQL: (1) Is Trading Date làm proxy số phiên; (2) cùng kỳ năm trước cho dòng 597, VND ở Fact; (3) Tính chất Phái sinh (Case 2); (4) KPI riêng (K_VP_265–268 đã READY từ 2026-11-05 — O_VP_50 mở, khóa Atomic xem O_VP_62); (5) như O_VP_46. BA sửa CSV và xác nhận. | K_VP_260–264,269–270 | BA Team / Datamart Modeling Team | Open |
| O_VP_53 | Nhóm 50/51 - Mã sàn tại ngày sự kiện (sửa thiết kế) | SQL BA Nhóm 50–51 (BA 2026-11-02) lấy mã sàn từ `jad_stockinfor` TẠI NGÀY SỰ KIỆN: niêm yết mới = bản tin cuối ngày tại `first_trading_date` (`s_new`), bổ sung / hủy = phiên giao dịch gần nhất <= `effective_date` (`s_add`), sàn = `IF(new_listed_shares > 0, s_new.floorcode, s_add.floorcode)`, nhóm theo năm × sàn. Thiết kế 2026-10-30 lọc sàn bằng `Security Trading Snapshot Dimension.Floor Code` (current-state) và O_VP_44 ghi 'khớp hoàn toàn' — SAI ở phần mã sàn: mã đã chuyển sàn (VD UPCoM → HNX/HOSE, hủy ở sàn này để niêm yết ở sàn khác) mang sàn hiện tại nên bị đếm sai sàn hoặc rơi khỏi cả 3 cột sàn; BA đã BỎ điều kiện loại chuyển sàn nên các trường hợp này nay nằm trong số liệu. Điểm cần chốt khi sửa: (a) phiên gần nhất <= ngày hiệu lực KHÔNG giới hạn dưới — BA chủ ý (SQL BA không có cận dưới), ghi marker DATE-BOUND-REVIEWED ở cột Listing Floor Code theo A19 R4; (b) dòng không có bản tin MDDS tại ngày sự kiện: Listing Floor Code NULL → vẫn vào K_VP_208/161 (tổng mọi sàn, như O_VP_44; BA loại dòng này) nhưng không vào cột sàn nào (BA cũng vậy); (c) HOSE: BA 2026-11-02 thêm `s.floorcode = '10'` — giữ cả `Source System Code = 'HOSE_LISTING_STATUS_CHANGE'` và Listing Floor Code = '10' (chỉ khác SQL BA, vốn nhóm theo sàn bất kể nguồn, khi sàn tại ngày ≠ Sở nguồn). | Đã sửa 2026-11-02: Fact `fct_listing_status_change_snpst` thêm cột Listing Floor Code (tên có tiền tố để không trùng `floor_code` của Dimension trên flat), K_VP_209–211 và K_VP_162–164 lọc theo cột này. [YÊU CẦU DEV] ALTER TABLE `fct_listing_status_change_snpst` và `vp_fct_listing_status_change_snpst_flat` ADD COLUMN `listing_floor_code` (String, nullable); cập nhật ETL (LEFT JOIN `security_trading_snapshot` theo `first_trading_dt` và phiên giao dịch gần nhất <= `effective_dt`, không cận dưới); nạp lại toàn bộ lịch sử. BA/Data Modeler xác nhận cách đếm dòng không có bản tin MDDS. | K_VP_160–164,208–211 | Datamart Modeling Team / Dev | Open |
| O_VP_54 | Nhóm 36 - Lỗi SQL BA | Nhóm 36 (BA 2026-11-02): SQL tham khảo dòng 411 có (a) thiếu `UNION ALL` giữa SELECT HOSE (`GROUP BY t.trade_date`) và SELECT HNX; (b) nhãn quý dùng `month(period_fromdate)` — cột không tồn tại ở subquery (nên là `trade_date`); (c) `stock_portfolio` chỉ giữ mã có bản tin MDDS trong khoảng Từ kỳ — Đến kỳ (bản ghi mới nhất mỗi symbol) rồi INNER JOIN với sổ lệnh, còn thiết kế dùng Security Trading Snapshot Dimension current-state không giới hạn khoảng kỳ (chỉ khác khi mã có giao dịch mà không có bản tin MDDS trong kỳ). | (a), (b) hiểu theo ý định (gộp 2 sàn; nhãn quý theo ngày giao dịch), không chép lỗi; (c) giữ Dimension current-state. BA sửa SQL và xác nhận. | K_VP_1,144–146 | BA Team | Open |
| O_VP_55 | Nhóm 45 - Thiếu nguồn Atomic / Ngoại lai (eForm đấu giá cổ phần) | **[MỚI 2026-11-03]** Nhóm 45 (BA 2026-11-03) đọc `uat_iss_ods.flat_report` (HNX05 của HNX, HSX03 của HOSE); thiết kế đọc Atomic `internal_statistical_report` (cùng cách VP đọc HNX09, TKNB đọc TTLK01) và dựng `Fact Share Auction Result Snapshot` (1 dòng biểu mẫu = 1 đợt đấu giá của 1 tổ chức). (a) `flat_report` không có trong `BRD/Source/ISS`; BA `row_num` ≡ Atomic `row_index` (ROW_INDEX) là GIẢ ĐỊNH chưa kiểm — nếu dev xác nhận khác thì khóa dòng của Fact phải đổi; (b) khóa Atomic `internal_statistical_report` chưa gồm nguồn nộp/trạng thái nộp (như O_VP_21): nộp lại biểu mẫu cùng tháng có thể tạo dòng lặp, SQL BA cũng không khử lặp; (c) SQL BA ghim `ds_snpst_dt = '2026-10-22'` (bản test) → bản hiện hành `ds_rcrd_st = 'ACTIVE'` như O_VP_20; (d) phân nhóm loại hình so khớp CHÍNH XÁC sau TRIM theo danh sách chuỗi của BA — chuỗi mới hoặc biến thể chính tả rơi vào 'Khác'; (e) lỗi BA: dòng 479 Điều kiện ghi `report_month` (SQL lọc `report_year`) **[ĐÃ SỬA 2026-11-05: BA đổi Điều kiện và Trường nguồn sang `report_year`; BA cũng sửa lỗi gõ `colum_path` → `column_path` ở 7 dòng 503–509]**, dòng 486 Mô tả chép của nhóm Phát hành ra công chúng, dòng 483–486 Điều kiện chép chung một câu, BA bỏ chiều 'Loại hình đấu giá' từng loại. | (a) READY với giả định row_num ≡ row_index; (b)(d) giữ như SQL BA; (c) dùng `ds_rcrd_st = 'ACTIVE'`; (e) theo SQL và tên chỉ tiêu. Dev xác nhận row_index và cách khử trùng khi nộp lại; BA sửa dòng 479/486. | K_VP_160,281–287 | Dev / BA Team | Open |
| O_VP_56 | Nhóm 30/31 - Giả định và lỗi BA (TPCP theo kỳ) | **[MỚI 2026-11-03]** (1) Nhóm 30/31 (BA 2026-11-03) đọc `uat_hnx_stg.gov_bond_offering`; thiết kế đọc `Fact Government Bond Bidding Result Snapshot` (Nhóm 47/48) và THÊM cột `calling_val` (Atomic `gov_bond_bidding_result.calling_val`) cho Nhóm 31 — dev ALTER `fct_government_bond_bidding_result_snpst_flat` ADD COLUMN `calling_val` (Decimal(23,2), nullable) và nạp lại; (2) Tổng dư nợ TPCP (K_VP_271–272) READY từ 2026-11-05 (Atomic đã có `rpt_year`; O_VP_50 mở, khóa Atomic xem O_VP_62) — BA Nhóm 30 lấy tháng báo cáo MỚI NHẤT trong kỳ (DENSE_RANK theo report_month) nên Fact Government Bond Listing Snapshot có grain 1 mã × 1 tháng; (3) lỗi/giả định BA: dòng 363 (Kỳ hạn bình quân % so với kỳ trước) Điều kiện ghi nhầm công thức Lãi suất; SQL Nhóm 31 dùng `:period_from/:period_to` còn Điều kiện ghi `:from_period/:to_period`; SQL Nhóm 30 chỉ có loại kỳ M/Q/Y (không D); Tỷ lệ trúng thầu BA đổi chiều từ gọi/trúng sang trúng/gọi; BA không ghi đơn vị của `winning_value`/`calling_value`; (4) các dòng 'Trùng' (Nhóm 30: 359, 360, 361, 363, 365; Nhóm 31: 368, 369) vẫn có KPI riêng nên Δ Gate 10 là CÓ CHỦ Ý. | (1) thêm cột, flat đồng bộ theo A20; (2) giữ PENDING; (3) theo Mô tả và SQL, đơn vị giả định VND; (4) KPI riêng. BA xác nhận tên tham số và đơn vị; dev xác nhận ALTER + nạp lại. | K_VP_1,271–280 | Dev / BA Team | Open |
| O_VP_57 | BA VP 2026-11-03 - Lỗi file BA (xuất từ Excel) | **[MỚI 2026-11-03]** `BA_analyst_VP.csv` (chuẩn hóa còn 18 cột) có 2 lỗi xuất file: (a) Nhóm 17 dòng 201 và 204 (TPCP: Số mã niêm yết hiện tại; KL niêm yết/ĐKGD hiện tại) cột Điều kiện = `#NAME?` (Excel hiểu chuỗi bắt đầu bằng '- TPCP:' là công thức; bản trước ghi nguồn HNX BM 23 danh sách TPCP niêm yết); (b) Nhóm 55 ô SQL của dòng 'Ngày báo cáo' (BA dòng 577) bị cắt ngay sau `'TPCP ` ở dòng 21 của khối `VALUES` (chèn dấu `"`), phần còn lại (danh sách tên chỉ tiêu) tràn thành 36 dòng giả (khóa '2'–'6' ở ba_diff và ba_hld_sync_check S2); logic SQL (CTE, 514 dòng đầu) giống hệt bản 2026-11-02. | Thiết kế KHÔNG đổi: dòng Nhóm 17 là 'Trùng' và mapping trống; Nhóm 55 chỉ mất phần đuôi hiển thị. Cảnh báo S2 khóa '2'–'6' ở Gate 10 do lỗi file này. BA xuất lại file (escape dấu `"` trong ô SQL, ép ô Điều kiện dạng văn bản). | — (Nhóm 17 chưa thiết kế; Nhóm 55 không đổi) | BA Team | Closed 2026-11-03 — bỏ qua theo Data Modeler (Nhóm 17 chưa thiết kế xong, Nhóm 55 không đổi) |
| O_VP_58 | Nhóm 41/44/54 - Fact mới `Fact Derivatives Account Snapshot` (ISS TTLK01_1) — giả định cần dev xác nhận | BA 2026-11-05 chuyển Nhóm 41/44/54 sang báo cáo ISS `TTLK01_1` ('Tài khoản phái sinh', `uat_iss_ods.flat_report`, MONTHLY, nguồn nộp ICP, SUBMITTED/LATE_SUBMITTED). Thiết kế (Data Modeler chọn 2026-11-05): Fact mới `fct_derivatives_account_snpst`, grain 1 dòng báo cáo (`row_index`) × 1 tháng báo cáo, PK Dạng B hash(snpst_dt_dim_id, row_nbr, src_stm_code), 3 cột đo đọc nguyên ô `TỔNG CỘNG` / `SỐ LƯỢNG CUỐI KỲ > TRONG NƯỚC` / `SỐ LƯỢNG CUỐI KỲ > NƯỚC NGOÀI`. Repo không có tài liệu về cấu trúc dòng của TTLK01_1 nên còn 5 điểm chưa chắc: (1) số dòng mỗi kỳ — BA mô tả `SUM(field_value)` (Nhóm 41 dòng 469, Nhóm 44 dòng 501) nhưng SQL dùng `PIVOT (MAX(val))`; Detail Mapping dùng SUM theo mô tả BA (đúng cả khi báo cáo chỉ có 1 dòng, sai nếu có thêm dòng tổng riêng); (2) `period_tp_code = 'MONTHLY'` suy từ BA `date_type = 'MONTHLY'`; (3) BA chọn snapshot mới nhất theo `ds_snpst_dt` (DENSE_RANK) — Atomic ISS nạp lại ghi đè theo BK nên Fact không khử trùng; (4) SQL BA Nhóm 41 đặt trùng alias `sl_tk_phaisinh_so_ky_truoc_pct` cho cả % so với kỳ trước lẫn % so với cuối năm trước; (5) kỳ Ngày không có dữ liệu vì báo cáo chỉ theo tháng. | Dev chạy `SELECT DISTINCT column_path, row_index FROM internal_statistical_report WHERE rpt_code = 'TTLK01_1'` để xác nhận số dòng/kỳ và có dòng tổng riêng hay không; nếu có dòng tổng thì lọc khỏi Fact hoặc đổi Detail Mapping sang MAX. | K_VP_300, 301, 303–305, 312–314, 321–323, 330–331, 332–338 | Dev ETL / Data Modeler | Open |
| O_VP_59 | Nhóm 41 - 19 dòng BA 'Không có dữ liệu, trên chart hiển thị N/A' | 19 dòng Nhóm 41 (BA 468, 472–477, 481–486, 490–495) có 'Trạng thái mapping = Done' nhưng Bảng nguồn trống, Trường nguồn NULL, Điều kiện 'Không có dữ liệu, trên chart hiển thị N/A': Loại nhà đầu tư, SL TK phái sinh mới/đóng, Trong nước/Nước ngoài × Cá nhân/Tổ chức, kể cả các dòng % của chúng. BA chỉ nêu 3 cột `TỔNG CỘNG` / `TRONG NƯỚC` / `NƯỚC NGOÀI` của TTLK01_1 và ghi 'không có dữ liệu' cho phần còn lại; chưa kiểm chứng TTLK01_1 thực tế có thêm cột mở/đóng/cá nhân/tổ chức hay không — Atomic `internal_statistical_report` là EAV nên đọc được mọi ô đã nạp (như TKNB đọc TTLK01), không phải thiếu Atomic. Mỗi dòng có KPI riêng (K_VP_302, 306–311, 315–320, 324–329) trạng thái PENDING [Nhóm 2 - Chưa có mapping nguồn từ BA], không gắn cột Fact; UI hiển thị N/A theo BA. | Dev chạy `SELECT DISTINCT column_path FROM internal_statistical_report WHERE rpt_code = 'TTLK01_1'`: nếu có cột SỐ LƯỢNG MỞ/ĐÓNG TRONG KỲ hoặc phân loại CN/TC thì đọc ngay (cùng mẫu K_TKNB_821–842) và nâng READY; nếu không có thì BA xác nhận giữ N/A hoặc bổ sung nguồn (VD biểu mẫu VSDC chi tiết, TK mở/đóng phái sinh); khi có nguồn thì thêm cột vào `fct_derivatives_account_snpst` hoặc Fact mới và nâng READY (đủ 5 tầng + flat). | K_VP_302, 306–311, 315–320, 324–329 | BA Team | Open |
| O_VP_60 | Nhóm 38/39 - Fact mới `Fact Foreign Capital Flow Summary Snapshot` (FIMS IBOU9) — giả định cần dev xác nhận | BA 2026-11-05 chuyển Nhóm 38/39 sang FIMS `IBOU9` (PLIV-TT51), dòng `row_path = 'Tổng= (1) + (2)'`, 3 cột USD, kỳ `NUA_THANG`, lấy bản nộp mới nhất của từng TVLK (`object_name`) mỗi kỳ. Data Modeler chọn 2026-11-05: Fact VP mới `fct_foreign_capital_flow_summary_snpst` (grain 1 TVLK × 1 kỳ nửa tháng, PK Dạng B hash(reporting_entity_code, period_val, rpt_year, src_stm_code), bản nộp mới nhất ghi đè); không dùng `fct_foreign_investor_report_value` (NDTNN, thiếu `reporting_entity_code`) và `fct_foreign_investor_capital_flow_snpst` (bỏ dòng tổng, 1 chỉ tiêu). Giả định: (1) `object_name` (BA) ≡ Atomic `reporting_entity_code` (FIMS OBJECT_ID); (2) lọc thêm `sheet_nm = 'I'` như NDTNN (BA không nêu sheet); (3) `period_tp_code = 'NUA_THANG'` theo BA; (4) BA khử trùng còn chia theo tháng của ngày báo cáo (`DATE_FORMAT(day_report, 'yyyy-MM')`) — PK không có thành phần này vì `period_val` mới ('DT'/'CT' + 'MM/YYYY') đã mang tháng và năm của kỳ (đã kiểm ODS 2026-11-08, O_VP_65), nên `period_val` + `rpt_year` đủ phân biệt kỳ nửa tháng; (5) nửa đầu/nửa cuối tháng theo biểu thức BA: từ 2026-11-08 `SUBSTR(period_val, 1, 2)` = 'DT' (nửa đầu) / 'CT' (nửa cuối); trước đó `SUBSTR(period_val, 3, 2) <= 15` theo định dạng NT01..NT31 — xem O_VP_65; kỳ Năm lấy `rpt_year` (BA Nhóm 38 dòng 431 và Nhóm 39 dùng `year_value`, SQL Nhóm 38 dùng `YEAR(day_report)`); (6) % so với kỳ trước chia cho giá trị kỳ trước có thể âm (Vào ròng/Rút ròng) nên dấu % đảo, đúng theo BA. | Dev xác nhận 6 giả định và dựng bảng/flat `fct_foreign_capital_flow_summary_snpst`; BA xác nhận có cần ABS ở mẫu số. | K_VP_288–299 | Dev ETL / Data Modeler | Open |
| O_VP_61 | Nhóm 54 - Data Explorer Tài khoản giao dịch: ghép 2 thị trường, phái sinh chỉ có tổng | BA 550–556 (trước 2026-11-09 ghi 595–601 do BA dịch dòng): SQL ghép thị trường cơ sở (VSDC `open_investors`/`closed_investors`) và phái sinh (ISS `TTLK01_1`). Không thêm Fact/Dimension: cơ sở đọc `Fact Investor Account Movement Snapshot`, phái sinh đọc `Fact Derivatives Account Snapshot`; nhãn Thị trường (CO_SO/PHAI_SINH) gán theo Fact nguồn. Điểm cần lưu ý: (1) phái sinh chỉ có Số lượng tài khoản dòng tổng (origin_type, investor_kind NULL), không có SL TK mới/đóng; (2) kỳ Ngày chỉ có cơ sở; (3) loại NĐT '7' (Nhà nước) và 'NA' không có nhãn Trong nước/Nước ngoài hay Cá nhân/Tổ chức (BA MAP trả NULL); (4) BA lọc năm của TTLK01_1 bằng `report_year BETWEEN` năm Từ kỳ và năm Đến kỳ ('Lọc tạm giới hạn năm'); (5) kế thừa giả định O_VP_46 (ngày sự kiện ngoài lịch làm lệch số lũy kế) và O_VP_58; (6) SQL BA nối số dư đầu kỳ bằng '=' trên origin_type/investor_kind (NULL ≠ NULL) nên nhóm loại NĐT '7' (Nhà nước) và 'NA' (nhãn NULL) mất số dư đầu kỳ (NVL → 0), chỉ cộng dồn từ Từ kỳ; (7) phái sinh: BA xuất field_value của từng dòng, Fact có 1 dòng/row_index nên thiết kế dùng SUM — khác BA nếu cột 'TỔNG CỘNG' có nhiều dòng mỗi tháng. | Data Modeler xác nhận cách trình bày thị trường phái sinh (chỉ dòng tổng) với BA; không cần Atomic/Fact mới. Nhóm nhãn NULL (loại NĐT '7'/'NA'): thiết kế giữ số lũy kế đủ (Σ mở − Σ đóng <= cuối kỳ), khác BA — BA xác nhận có chủ ý mất số dư đầu kỳ hay không. | K_VP_332–338 | Data Modeler / BA Team | Open |
| O_VP_62 | Nhóm 30/49/55 - Fact mới `Fact Government Bond Listing Snapshot`: khóa Atomic chưa có tháng | Atomic `gov_bond_listing` (HNX.GOV_BOND_LISTED_LIST) đã có `rpt_year`, `rpt_month`, `rpt_day` (int, 2026-11-04) nhưng khóa `gov_bond_listing_id` vẫn = hash_id('HNX_GOV_BOND_LISTED_LIST', BOND_CODE), không có tháng báo cáo — cùng dạng O_VP_12/15/26. Thiết kế (mở O_VP_50): Fact `fct_government_bond_listing_snpst`, grain 1 mã TPCP × 1 tháng báo cáo, PK Dạng B hash(bond_code, rpt_year, rpt_month, src_stm_code), khóa ngày = ngày cuối tháng báo cáo, Listed Bond Value = KL niêm yết × 100.000 (mệnh giá theo BA); ETL lọc `LAST_DAY(MAKE_DATE(rpt_year, rpt_month, 1)) = :etl_date` như Fact đăng ký TPDN riêng lẻ. Nếu loader upsert theo khóa Atomic thì mỗi mã chỉ còn tháng mới nhất: Tổng dư nợ (K_VP_271) vẫn tính được cho tháng mới nhất, còn kỳ trước (K_VP_272), cuối năm trước (K_VP_267) và các năm cũ (K_VP_257) có thể thiếu dữ liệu. | Báo Atomic team đưa tháng báo cáo vào khóa/BK `gov_bond_listing` trước khi nạp lịch sử; dev xác nhận cách loader nạp và mệnh giá 100.000 đồng. | K_VP_257, 265–268, 271–272 | Data Architecture / Atomic Team | Open |
| O_VP_63 | Quy chuẩn LLD | **[MỚI 2026-11-06 — đồng bộ Atomic commit 0075c3a2 (04/11), cùng đợt O_GSTT_79]** Atomic THÊM entity `securities_trade`/`securities_order` (HNX, HOSE) và đổi tên cột. Gate 0 VP trước đó báo 147 CRITICAL ở 4 file LLD (`fct_listed_corporate_bond_snpst`, `fct_investor_group_trading_snpst`, `fct_derivative_contract_snpst`, `fct_government_bond_trading_snpst`). | **Đã sửa LLD + ghi chú Detail Mapping K_VP_71 (giữ nguyên tên cột Mart):** (1) cột Atomic cũ → mới theo `source_column` YAML Atomic (`security_symbol_code`→`ticker_symbol`, `market_id_code`→`market_code`, `execution_val`→`match_amt`, `execution_vol`→`match_quantity`, `bond_order_book.order_bond_quantity`→`order_bond_vol`); (2) literal `src_stm_code` `ORDERTRADE_TRADE_BOOK_HOSE`/`_HNX` → `HOSE_TRADE_BOOK`/`HNX_TRADE_BOOK` (Gate 0 không bắt lệch literal này — nếu không đổi thì Fact rỗng); (3) `listed_share_information.rpt_dt` và `end_of_day_open_interest.rpt_dt` → `make_date(rpt_year, rpt_month, rpt_day)` (Atomic tách ngày thành 3 cột int). Gate 0 VP: 147 → 0 CRITICAL; Gate 0–10 VP PASS. **Cần dev:** cột Mart `src_stm_code` (direct) nay mang giá trị mới — API/ClickHouse đang lọc theo giá trị cũ phải đổi và flat nạp lại; cột `execution_val` ở nhánh HNX lấy cột vật lý `match_amt` (YAML Atomic chỉ khai nguồn HOSE; Data Modeler xác nhận 2026-11-06). | K_VP (Fact Listed Corporate Bond, Investor Group Trading, Derivative Contract, Government Bond Trading) | Dev / Datamart Modeling Team | Open |
| O_VP_64 | Nhóm 30/31/47/48 - TKNB thêm cột vào Fact kết quả đấu thầu TPCP (phụ thuộc xuyên module) | **[MỚI 2026-11-06]** TKNB Nhóm 5 (HNX06) reuse `Fact Government Bond Bidding Result Snapshot` và thêm 3 cột cuối: `rpt_year`, `rpt_month` (kỳ báo cáo HNX BM 25 — HNX06 lọc theo `report_month`, không theo `issue_dt`) và `government_bond_term_dim_id` (FK → `Government Bond Term Dimension`, sở hữu TKNB). Grain/PK không đổi; KPI VP (K_VP_160, 255–256, 271–280) không đổi, vẫn dùng `bond_term`/`issue_term_years`/`winning_val`/`calling_val`. Flat `vp_fct_government_bond_bidding_result_snpst_flat` đã thêm 3 cột + `bond_term_years`/`bond_term_unit` (denormalize từ Dimension, LEFT JOIN `ds_rcrd_st = 'ACTIVE'`); flat vẫn INNER JOIN `cdr_dt_dim` theo ngày phát hành nên dòng `issue_dt` NULL/ngoài lịch bị loại | Giữ thiết kế; [YÊU CẦU DEV] ALTER ADD COLUMN `rpt_year`, `rpt_month`, `government_bond_term_dim_id`, `bond_term_years`, `bond_term_unit` trên flat đã triển khai và nạp lại; tạo `government_bond_term_dim`; Atomic xác nhận kiểu `rpt_month` (YAML int, mapping md string). Chi tiết: Section 5 mục 48 `DTM_TKNB_HLD.md` | K_TKNB_472–496 (TKNB Nhóm 5) | Dev / TKNB Data Modeler | Open |
| O_VP_65 | Nhóm 8, 38, 39 - ODS đổi định dạng `period_value` kỳ NUA_THANG và trường ngày danh mục niêm yết HNX (BA 2026-11-08) | Tracker 2026-11-08: (1) Nhóm 38, 39 — `uat_fims_ods.fir_value` đổi `period_value` của kỳ `NUA_THANG`; BA đổi quy tắc nửa đầu/nửa cuối tháng sang `SUBSTR(period_value, 1, 2) = 'DT'` / `'CT'` (trước đó `SUBSTR(period_value, 3, 2) <= 15`, định dạng NT01..NT31); (2) Nhóm 8 — `uat_hnx_stg.listed_securities_list` đổi trường ngày từ `report_date` sang `MAKE_DATE(report_year, report_month, report_day)` (BA dòng 127, 133); dòng 132 chỉ sửa tên cột ngày của `jad_stockinfor` trong Điều kiện thành `tradingdate`. Cùng loại thay đổi lặp ở Nhóm 8, 38–39 (luật H11). | (1) Đã đổi công thức K_VP_288 (Detail Mapping và HLD) và mô tả `period_val` của Fact `fct_foreign_capital_flow_summary_snpst`; K_VP_296 dùng lại K_VP_288. NDTNN không đổi vì không tách chuỗi `period_val`. (2) Fact `fct_listed_corporate_bond_snpst` đã nối Atomic Listed Share Information theo `make_date(rpt_year, rpt_month, rpt_day)` từ trước nên LLD không đổi, chỉ đồng bộ ghi chú K_VP_1, K_VP_83, K_VP_88. **Đã kiểm trên ODS 2026-11-08 (test O_VP_65):** (a) `period_value` mới = 'DT'/'CT' + 'MM/YYYY' (vd `DT04/2026`, 9 ký tự), 16 giá trị cho 10 tháng, tháng trong `period_value` luôn trùng tháng của `day_report`; 135 khóa (`reporting_entity_code`, `rpt_year`, `period_val`), không khóa nào gộp nhiều tháng; Fact đã nạp 135 dòng — PK và khóa khử trùng của Fact giữ nguyên, không thêm tháng của `rpt_day` vào khóa; Nhóm 8: `MAKE_DATE(report_year, report_month, report_day)` trùng `report_date` ở cả 3.366 dòng, không trùng khóa (`ticker_symbol`, ngày). **BA xác nhận:** (b) BA Nhóm 38 mô tả khử trùng theo `year_value` ở cột Điều kiện nhưng SQL theo `DATE_FORMAT(day_report, 'yyyy-MM')` — BA thống nhất một cách. | K_VP_1, K_VP_83, K_VP_88, K_VP_288, K_VP_296 | Dev ETL / BA Team / Data Modeler | Open |
| O_VP_66 | Nhóm 22 - Giả định và lệch BA (vốn hóa cổ phiếu theo ngành) | **[MỚI 2026-11-08]** BA Nhóm 22 (dòng 247–250): (1) Fact Listed Equity Snapshot chưa có FK ngành. (2) SQL BA lấy hồ sơ ngành IDS/SCMS/FMS tại các ngày chụp cố định (ds_snpst_dt = '2026-10-17' / '2026-08-22' / '2026-10-21'). (3) Dòng 248 'Ngành' và dòng 250 'Tỷ trọng vốn hóa ngành' ghi 'Trùng' nhưng không nêu trùng với chỉ tiêu nào. (4) SELECT cuối của SQL BA có cột so_ma_cp (Số mã cổ phiếu theo ngành), tradedate, marketcap_ty_dong và dòng 'Tổng tất cả ngành' mà BA CSV không có dòng riêng (H17). (5) SQL BA lỗi: SELECT con tham chiếu cột thieu_von_hoa_upcom không tồn tại ở CTE industry_agg. (6) Lịch ngày của SQL BA ghép trade_book HNX ∪ jad_marketinfor. (7) UPCoM tính vốn hóa theo VWAP ngày T lấy ở bản tin T+1. | (1) ĐÃ THIẾT KẾ cột industry_dim_id (FK nullable, chỉ cổ phiếu; CTCK/CTQLQ đại chúng = 07000) trên Fact — cùng cách O_VP_23/O_VP_37, không đổi grain/PK, flat denormalize industry_code/industry_nm. **Dev cần**: ETL cột mới + ALTER TABLE vp_fct_listed_equity_snpst_flat ADD COLUMN industry_dim_id/industry_code/industry_nm + nạp lại lịch sử (MERGE/UPSERT theo PK sẵn có); chưa nạp thì Nhóm 22 chỉ ra nhóm 'NA'. (2) Dùng hồ sơ ngành hiện hành (ds_rcrd_st = 'ACTIVE') tại thời điểm nạp, không cố định ngày chụp; lịch sử đổi ngành của công ty không tái hiện — Data Modeler xác nhận nếu cần ngành theo từng ngày. (3) Thiết kế KPI riêng K_VP_339 (Ngành) và K_VP_341 (Tỷ trọng); Δ số lượng BA ↔ HLD ở Gate 10 là CÓ CHỦ Ý. (4) CHƯA thêm KPI 'Số mã cổ phiếu theo ngành' (cần quyết định có hiển thị hay không): nếu BA xác nhận thì thêm KPI Case 1 = COUNT(Ticker Symbol) theo ngành trên cùng Fact (đã đủ cột); 'Tổng tất cả ngành' = ROLLUP, marketcap_ty_dong = đổi đơn vị, tradedate = :d_cur ở presentation layer. (5) Bỏ qua cột thừa — BA dọn SQL. (6) Dùng cdr_dt_dim.is_trading_date thay lịch BA (như O_VP_48). (7) Như O_VP_40: kỳ kết thúc ở phiên mới nhất thì vốn hóa UPCoM = NULL, ngành/tỷ trọng chỉ gồm HOSE + HNX. | K_VP_1, K_VP_339, K_VP_340, K_VP_341 | Dev / BA / Data Modeler | Open |
| O_VP_67 | Nhóm 21 - Giả định và lệch BA (chuỗi vốn hóa theo sàn và Tỷ lệ Vốn hóa/GDP) | **[MỚI 2026-11-08]** BA Nhóm 21 (dòng 240–246): (1) 6 dòng 'Trùng' (241–246) không nêu trùng với chỉ tiêu nào; cùng ý nghĩa Nhóm 19 nhưng là chuỗi kỳ Từ kỳ — Đến kỳ. (2) Dòng 245 UPCOM: Mô tả ghi 'Σ (Giá đóng cửa × KL lưu hành)' nhưng Điều kiện và SQL BA dùng VWAP ngày T lấy ở T+1. (3) Dòng 243/244 Điều kiện ghi s.floorcode = 'HOSE'/'HNX' (tên sàn) trong khi bản tin MDDS lưu mã 10/02. (4) Dòng 246 Tỷ lệ Vốn hóa/GDP: Mô tả 'Tổng vốn hóa / GDP * 100' nhưng SQL BA tính marketcap / gdp cho MỌI dòng sàn (HOSE/HNX/UPCOM/Tổng). (5) SQL BA cố định ds_snpst_dt = '2026-10-23' cho GDP (MRMS). (6) SELECT cuối của SQL BA có cột gdp, gdp_year, tradedate, marketcap_ty_dong, exchange mà BA CSV không có dòng riêng (H17). (7) Lịch ngày SQL BA ghép trade_book HNX ∪ jad_marketinfor. | (1) Thiết kế đủ KPI mới K_VP_342–347 (cùng cách Nhóm 19/O_VP_48); Δ số lượng BA ↔ HLD ở Gate 10 là CÓ CHỦ Ý. (2) Theo Điều kiện/SQL: UPCoM = VWAP T+1 (VWAP = 0 → giá tham chiếu; chưa có T+1 → NULL, như O_VP_40) — BA sửa Mô tả. (3) Dùng mã sàn 10/02/04 (như O_VP_48). (4) K_VP_347 đặt dưới slicer Sàn: dòng từng sàn = vốn hóa sàn / GDP (khớp SQL), dòng Tổng = tổng vốn hóa / GDP (khớp Mô tả) — BA xác nhận có hiển thị tỷ lệ theo từng sàn không; nếu chỉ cần dòng Tổng thì giới hạn ở presentation layer, không đổi thiết kế. (5) Fact Macro Indicator Snapshot chỉ nạp bản ghi hiệu lực, không cố định ngày chụp (O_VP_41). (6) CHƯA thêm KPI GDP/GDP năm cho Nhóm 21 (cần quyết định có hiển thị cạnh tỷ lệ hay không): nếu cần thì dùng lại K_VP_174 (GDP năm, Nhóm 55); marketcap_ty_dong = đổi đơn vị, tradedate = :d_p, exchange = nhãn của Floor Code ở presentation layer. (7) Dùng cdr_dt_dim.is_trading_date thay lịch BA (như O_VP_48); kỳ D chỉ lấy ngày giao dịch. Phụ thuộc dev PTTT bổ sung PK + unit_tp_code cho Fact Macro Indicator (O_VP_41, O_PTTT_57). | K_VP_1, K_VP_342, K_VP_343, K_VP_344, K_VP_345, K_VP_346, K_VP_347 | Dev / BA / Data Modeler | Open |
| O_VP_68 | Nhóm 17/18/20 - Mở rộng Fact quy mô niêm yết (chứng quyền, TPDN niêm yết, ETF/CCQ, TPDN riêng lẻ) | **[MỚI 2026-11-08]** BA Nhóm 17/18/20 cần quy mô niêm yết/ĐKGD (số mã, KL, GT) của 7 loại chứng khoán: cổ phiếu, CCQ, ETF, chứng quyền, TPDN niêm yết (MDDS JAD_STOCKINFOR, floorcode <> '03'), TPCP (HNX GOV_BOND_LISTED_LIST), TPDN riêng lẻ (HNX PRIVATE_CORP_BOND_REGISTRATION). Fact Listed Equity Snapshot chỉ nạp loại 2/3/6 và sàn 02/04/10, không có loại quỹ; Fact TPDN riêng lẻ không có KL/mệnh giá. | (1) MỞ RỘNG Fact Listed Equity Snapshot (không đổi PK): nạp stock_tp_code 1/2/3/4/6 + floor_code <> '03' (đúng SQL BA Nhóm 17), thêm cột fund_tp_code (M = CCQ, E = ETF), listed_share_val theo mệnh giá (TPDN niêm yết suy ngược từ giá tham chiếu; chứng quyền 10000 theo SQL BA — Mô tả BA ghi chứng quyền 'để trống' nên BA xác nhận). Mọi KPI vốn hóa/số mã Nhóm 19/21/22/55 đều lọc stock_tp_code tường minh nên không đổi kết quả. Tên 'Equity' giữ nguyên (nợ tên). (2) Fact TPDN riêng lẻ thêm registered_trading_bond_quantity, par_val, registered_trading_val (Atomic registered_trading_bond_quantity, par_val); không đổi grain/PK. (3) Dev: ETL loại/cột mới + ALTER TABLE vp_fct_listed_equity_snpst_flat ADD COLUMN fund_tp_code và vp_fct_private_corporate_bond_registration_snpst_flat ADD COLUMN registered_trading_bond_quantity/par_val/registered_trading_val + nạp lại lịch sử (PK không đổi, MERGE đủ). (4) Câu 'factless' ở HLD Section 1 (Fact TPDN riêng lẻ) và Section 4 chưa sửa tại chỗ (không có công cụ ghi 2 phần này) — đã lỗi thời, đọc theo mục (2). | Nhóm 17, 18, 20 | Dev / Data Modeler | Open |
| O_VP_69 | Nhóm 18 - Giả định và lệch BA (chuỗi KL niêm yết theo loại chứng khoán) | **[MỚI 2026-11-08]** BA Nhóm 18 (dòng 194–206): (1) 12 dòng 'Trùng' không nêu trùng với chỉ tiêu nào; cùng định nghĩa KL niêm yết/ĐKGD của Nhóm 17 nhưng là chuỗi kỳ Từ kỳ — Đến kỳ. (2) Dòng 194 Mô tả liệt kê kỳ Ngày/Tháng/Quý/Năm nhưng SQL BA chỉ nhận :period_type M/Q/Y. (3) Dòng 196 'Sàn' chỉ áp dụng cho cổ phiếu (CASE WHEN stocktype = '2'). (4) SQL BA Nhóm 18 lấy ngày giao dịch cuối CHỈ trong khoảng [Từ kỳ, Đến kỳ] (không lùi sang kỳ trước), khác Nhóm 21 (ngày gần nhất <= ngày cuối kỳ). (5) TPDN riêng lẻ (dòng 202) không lọc ngày đáo hạn, khác K_VP_100 (Nhóm 11). (6) Dòng 206 chứng quyền: BA ghi 'hoặc đổi sang SUBSTR(productid, 6, 2) = EW'. (7) SELECT cuối của SQL BA chỉ có ky, loai_ck, san, kl_ny_dkgd — không có KL theo kỳ trước/% thay đổi. | (1) Thiết kế đủ KPI mới K_VP_348–359 (cùng cách Nhóm 19/21); Δ số lượng BA ↔ HLD ở Gate 10 là CÓ CHỦ Ý. (2) Theo SQL: kỳ M/Q/Y; kỳ Ngày chưa hỗ trợ — BA xác nhận có cần kỳ Ngày không (nếu cần thì thêm nhánh D như Nhóm 21). (3) K_VP_349 chỉ lấy Floor Code khi Stock Type Code = '2'. (4) :d_p = ngày giao dịch cuối cùng thuộc kỳ p (kỳ không có phiên → không có dòng). (5) Giữ theo SQL BA (không lọc Maturity Date); BA xác nhận có cần lọc mã đã đáo hạn như Nhóm 11 không. (6) Giữ stocktype = '4' (đúng Điều kiện BA, SQL dùng stocktype). (7) KL theo kỳ trước/% thay đổi của Nhóm 17 không áp dụng cho Nhóm 18. Phụ thuộc mở rộng Fact (O_VP_68) và khóa Atomic gov_bond_listing (O_VP_62). | K_VP_1, K_VP_348, K_VP_349, K_VP_350, K_VP_351, K_VP_352, K_VP_353, K_VP_354, K_VP_355, K_VP_356, K_VP_357, K_VP_358, K_VP_359 | Dev / BA / Data Modeler | Open |
| O_VP_70 | Nhóm 20 - Giả định và lệch BA (giá trị niêm yết trái phiếu, GDP) | **[MỚI 2026-11-08]** BA Nhóm 20 (dòng 224–239): (1) 10 dòng 'Trùng' (225, 231–239) không nêu trùng với chỉ tiêu nào. (2) Dòng 227/232/235/238 'So sánh với kỳ trước (%)': Mô tả ghi mẫu số 'giá trị niêm yết tại ngày cuối NĂM trước' nhưng tên dòng và SQL BA (`(c.gt_ny_dkgd - p.gt_ny_dkgd) / p.gt_ny_dkgd`, p = kỳ liền trước) dùng cuối KỲ trước. (3) Dòng 228/233/236/239 'So sánh với năm trước (%)': SQL BA không có nhánh này; Mô tả '(cuối năm này − cuối năm trước) / cuối năm trước'. (4) CTE stock_eod của SQL BA lọc `s.stocktype = '2'` (chú thích 'TPDN niêm yết') trong khi loai_ck = 'TPDNNY' chỉ khi stocktype = '1' và Điều kiện dòng 226/231 ghi stocktype = '1'. (5) SQL BA cố định ds_snpst_dt = '2026-10-23' cho GDP (MRMS). (6) SELECT cuối của SQL BA có cột so_ma_ny_dkgd, kl_ny_dkgd (kèm kỳ trước và %), gt_ny_dkgd_kytruoc, gt_ny_gdp_kytruoc, gt_ny_gdp_chenhlech (điểm %) mà BA CSV không có dòng riêng (H17); alias gt_ny_dkgd_pct viết 2 lần. (7) TPDN riêng lẻ không lọc ngày đáo hạn (khác K_VP_100, Nhóm 11). (8) Kỳ Ngày với TPCP/TPDN riêng lẻ: ngày tra cứu < ngày cuối tháng thì dùng tháng liền trước. | (1) Thiết kế đủ KPI mới K_VP_360–374 (cùng cách Nhóm 19/21); Δ số lượng BA ↔ HLD ở Gate 10 là CÓ CHỦ Ý. (2) Theo SQL/tên dòng: mẫu số kỳ trước (như O_VP_48). (3) Thiết kế (kỳ này − cuối năm trước) / cuối năm trước, mốc 'kỳ này' = cuối kỳ báo cáo, :d_py/:m_py = cuối năm trước (như K_VP_242 Nhóm 19) — BA xác nhận. (4) Theo Điều kiện: TPDN niêm yết = stocktype = '1'. (5) Fact Macro Indicator chỉ nạp bản ghi hiệu lực, không cố định ngày chụp (O_VP_41). (6) CHƯA thêm KPI cho số mã, KL, GT niêm yết/GDP kỳ trước và chênh lệch điểm % (cần quyết định hiển thị; SQL dùng chung khung với Nhóm 17): nếu BA xác nhận thì thêm cùng khuôn K_VP_244 (Nhóm 19) và K_VP_362; K_VP_365 chỉ dòng 'Tổng' đúng SQL. (7) Giữ theo SQL BA (không lọc Maturity Date); BA xác nhận. (8) Dùng cùng quy tắc chọn tháng báo cáo của K_VP_100 (Nhóm 11). Phụ thuộc mở rộng Fact (O_VP_68), khóa Atomic gov_bond_listing (O_VP_62), PK + unit_tp_code của Fact Macro Indicator (O_VP_41, O_PTTT_57). | K_VP_1, K_VP_360, K_VP_361, K_VP_362, K_VP_363, K_VP_364, K_VP_365, K_VP_366, K_VP_367, K_VP_368, K_VP_369, K_VP_370, K_VP_371, K_VP_372, K_VP_373, K_VP_374 | Dev / BA / Data Modeler | Open |
| O_VP_71 | Nhóm 17 - Giả định và lệch BA (chỉ tiêu tổng hợp niêm yết/ĐKGD) và 2 Fact sự kiện mới | **[MỚI 2026-11-08]** BA Nhóm 17 (dòng 178–193): (1) 7 dòng '% so với kỳ trước' ghi 'Trùng' nhưng không nêu trùng với chỉ tiêu nào. (2) Dòng 178 Mô tả liệt kê kỳ Ngày/Tháng/Quý/Năm nhưng SQL BA :period_type chỉ M/Q/Y. (3) Dòng 184 Mô tả: mệnh giá chứng quyền 'để trống do không có thông tin' trong khi SQL/Điều kiện dùng 10000 cho stocktype 4. (4) TPDN riêng lẻ (dòng 180–184): SQL không lọc ngày đáo hạn (khác K_VP_100, Nhóm 11). (5) Dòng 192 Điều kiện mục TPDN riêng lẻ ghi nhầm nhãn 'Số mã NY/ĐKGD mới' (công thức là kl_huy_ytd); dòng 193 Mô tả '% thay đổi = (Giá trị …)' cho KL hủy. (6) Nguồn sự kiện TPCP (HNX.GOV_BOND_ADDITIONAL_LISTING) và TPDN riêng lẻ (HNX.REGISTRATION_STATUS_CHANGE, số LŨY KẾ từ đầu năm) chưa có Fact VP. (7) SQL BA chỉ nạp snapshot mới nhất của từng tháng báo cáo (DENSE_RANK theo ds_snpst_dt). | (1) Thiết kế đủ KPI mới K_VP_375–389 (cùng cách Nhóm 19/21); Δ số lượng BA ↔ HLD ở Gate 10 là CÓ CHỦ Ý. (2) Theo SQL: kỳ M/Q/Y; BA xác nhận có cần kỳ Ngày không. (3) Theo SQL/Điều kiện: chứng quyền 10000 (O_VP_68) — BA xác nhận GT niêm yết chứng quyền có hiển thị không. (4) Giữ theo SQL BA; BA xác nhận. (5) Theo công thức; BA sửa nhãn. (6) THÊM 2 Fact mới, Dạng A (PK = id dòng Atomic): Fact Government Bond Listing Change Snapshot (Atomic additional_gov_bond_listing: bond_code, listing_status, additional_bond_vol, listing_change_dt) và Fact Private Corporate Bond Registration Status Snapshot (Atomic bond_trading_registration_status: bond_code, trading_registration_status, registered_trading_bond_quantity, rpt_year/rpt_month; FK ngày = ngày cuối tháng báo cáo); phát sinh tháng TPDN riêng lẻ = lũy kế tháng này − lũy kế tháng liền trước cùng năm (LAG ở Detail Mapping, A31). Sự kiện cổ phiếu/CCQ/ETF/chứng quyền/TPDN niêm yết dùng lại Fact Listing Status Change Snapshot + Security Trading Snapshot Dimension hiện hành (INNER JOIN như BA stock_portfolio). Dev: ETL 2 Fact mới + tạo 2 bảng flat vp_fct_government_bond_listing_change_snpst_flat, vp_fct_private_corporate_bond_registration_status_snpst_flat và nạp lịch sử. (7) Atomic giữ 1 dòng hiện hành cho mỗi khóa; nếu loader giữ nhiều snapshot cùng tháng thì cần chọn bản mới nhất — dev xác nhận (cùng O_VP_62). | K_VP_1, K_VP_375, K_VP_376, K_VP_377, K_VP_378, K_VP_379, K_VP_380, K_VP_381, K_VP_382, K_VP_383, K_VP_384, K_VP_385, K_VP_386, K_VP_387, K_VP_388, K_VP_389 | Dev / BA / Data Modeler | Open |
