# Changelog — Cập nhật thiết kế GSTT & PTTT (2026-09-30)

> **Ngày cập nhật:** 2026-09-30  
> **Nhánh:** `main`  
> **Commit message:** `feat(GSTT/PTTT): cap nhat thiet ke Nhom 35 (So huu noi bo), bo sung Fact Security Trading Daily, re-numbering nhom 28-46, chinh sua PTTT HLD/LLD`

---

## 1. Tổng quan thay đổi

| Thống kê | Giá trị |
|---|---|
| Tổng file thay đổi (modified) | 19 |
| File mới (untracked) | 2 |
| Tổng dòng thêm/xóa | +2.210 / −1.957 |
| Module ảnh hưởng | **GSTT** (chính), **PTTT** (phụ) |

---

## 2. Thay đổi chính — Module GSTT

### 2.1. Entity mới: `Fact Security Trading Daily` (Nhóm 34 — Biểu đồ kỹ thuật)

- **File mới:** `Datamart/lld/GSTT/DTM_GSTT_fct_security_trading_daily.csv`
- **Mục đích:** Biểu đồ kỹ thuật cổ phiếu (nến giá OHLCV theo NGÀY) — dùng khi khung thời gian lọc **từ 1 tháng trở lên**.
- **Nguồn Atomic:** `market_price_snapshot` (MDDS.JAD_TRADINGVIEWHISTORY1DAY)
- **Grain:** 1 row / mã CK (Symbol) / ngày giao dịch
- **5 KPI mới:** K_GSTT_349 → K_GSTT_353 (Daily Open/High/Low/Close Price, Daily Volume)
- **Đăng ký:** Đã thêm entity `DTM-fct_security_trading_daily` vào `datamart_model.yaml`

### 2.2. Cập nhật `Fact Major Shareholder Ownership Snapshot` (Nhóm 35 — Sở hữu & giao dịch nội bộ)

- **Bỏ 2 cột:** `Current_Foreign_Holding_Quantity` và `Domestic_Holding_Quantity` (cấp công ty, gây lặp theo cổ đông)
- **Thay bằng REUSE:** `Fact Public Company Foreign Ownership Snapshot` (từ module NDTNN) — theo quyết định O_GSTT_50
- **Cập nhật LLD:** `DTM_GSTT_fct_major_shareholder_ownership_snpst.csv` (26 dòng thay đổi)
- **Thêm cột mới:** `Closing Ownership Ratio` phục vụ K_GSTT_178 (tổng tỷ lệ sở hữu cổ đông lớn)

### 2.3. Re-numbering toàn bộ nhóm GSTT từ Nhóm 28 trở đi

Chèn thêm **Nhóm 28 mới** (Bản đồ nhiệt GTNN theo chỉ số) → đẩy tất cả nhóm cũ lên +1:

| Nhóm cũ | Nhóm mới | Tên nhóm |
|:---:|:---:|---|
| 28 | **29** | Xu hướng dòng tiền — Giao dịch tự doanh |
| 29 | **30** | GD theo phân loại NĐT (biểu đồ GT ròng theo chỉ số) |
| 30 | **31** | GD theo phân loại NĐT (GT ròng theo mã CK) |
| 31 | **32** | GD theo phân loại NĐT (bản đồ nhiệt GT mua/bán theo mã CK) |
| 32 | **33** | GD theo phân loại NĐT (bản đồ nhiệt GT mua/bán theo chỉ số) |
| 33 | **34** | Biểu đồ phân tích kỹ thuật |
| 34 | **35** | Sở hữu và giao dịch nội bộ |
| 35 | **36** | Báo cáo Thống kê định giá TTCK Việt Nam (BM021_MSS) |
| 36 | **37** | Data Explorer: Giao dịch & thanh khoản |
| 37 | **38** | Data Explorer: Số cổ phiếu sở hữu |
| 38 | **39** | Data Explorer: Chỉ số |
| 39 | **40** | Data Explorer: Điểm đóng góp chỉ số |
| 40 | **41** | Data Explorer: Giao dịch trái phiếu |
| 41 | **42** | Data Explorer: Giao dịch phái sinh |
| 42 | **43** | Data Explorer: Kết xuất sổ lệnh — HOSE (Trade) |
| 43 | **44** | Data Explorer: Kết xuất sổ lệnh — HNX (Trade) |
| 44 | **45** | Data Explorer: Kết xuất sổ lệnh — HNX (Order) |
| 45 | **46** | Data Explorer: Kết xuất sổ lệnh — HOSE (Order) |

### 2.4. Cập nhật GSTT Entities

- **DTM_GSTT_Entities.csv:** Thêm `Fact Security Trading Daily`, `Fact Public Company Foreign Ownership Snapshot` (REUSE từ NDTNN), cập nhật mô tả các entity theo re-numbering mới
- **DTM_GSTT_Entities.md:** Cập nhật ER diagram, bổ sung entity mới, bỏ 2 cột sở hữu NN/trong nước khỏi ER diagram Major Shareholder

### 2.5. Cập nhật GSTT HLD

- **DTM_GSTT_HLD.md:** +386/−238 dòng — Re-numbering toàn bộ section từ Nhóm 28, thêm Nhóm 28 mới (bản đồ nhiệt GTNN theo chỉ số), cập nhật mô tả Nhóm 35 (sở hữu nội bộ)

### 2.6. Cập nhật GSTT LLD

| File LLD | Thay đổi |
|---|---|
| `DTM_GSTT_Detail_Mapping.csv` | +5 KPI nến ngày (K_GSTT_349-353), re-numbering nhóm, cập nhật mapping |
| `DTM_GSTT_fct_index_constituent_snpst.csv` | Chỉnh sửa nhỏ |
| `DTM_GSTT_fct_major_shareholder_ownership_snpst.csv` | Bỏ 2 cột sở hữu NN/trong nước, thêm `closing_ownership_ratio` |
| `DTM_GSTT_fct_stock_portfolio_snpst.csv` | Chỉnh sửa nhỏ |
| `DTM_GSTT_security_trading_snpst_dim_MDDS_JAD_STOCKINFOR.csv` | Cập nhật dim mapping |

### 2.7. Cập nhật flat-table SQL

- `01_create_gstt_flat_tables.sql` — Thêm DDL cho `fct_security_trading_daily`
- `02_populate_gstt_flat_tables.sql` — Thêm INSERT logic cho entity mới

### 2.8. Cập nhật BA Analyst

- `BRD/BA/BA_analyst_GSTT.csv` — +1.059 dòng thay đổi: bổ sung mapping BA cho nhóm mới và re-numbering

---

## 3. Thay đổi phụ — Module PTTT

| File | Thay đổi |
|---|---|
| `Datamart/hld/DTM_PTTT_HLD.md` | +80/−160 dòng — Refactor mô tả HLD |
| `Datamart/lld/DTM_PTTT_Detail_Mapping.csv` | Chỉnh sửa mapping |
| `DTM_PTTT_fct_market_risk_snpst.csv` | Cập nhật 28 dòng |
| `DTM_PTTT_fct_market_statistics_snpst.csv` | Cập nhật 14 dòng |
| `DTM_PTTT_fct_order_size_snpst.csv` | Cập nhật 12 dòng |

---

## 4. Thay đổi cross-module

| File | Thay đổi |
|---|---|
| `Datamart/datamart_model.yaml` | +1 entity mới (`fct_security_trading_daily`), cập nhật schema cột của các entity GSTT |
| `Datamart/index/kpi_index.csv` | +5 KPI mới (K_GSTT_349-353), re-numbering |
| `Datamart/lld/datamart_attributes.csv` | +109 dòng thay đổi — đồng bộ attributes |

---

## 5. File mới (Untracked)

| File | Mô tả |
|---|---|
| `Datamart/lld/GSTT/DTM_GSTT_fct_security_trading_daily.csv` | LLD Detail Mapping cho Fact Security Trading Daily (nến ngày TradingView) |
| `GSTT_Review_Report.md` | Báo cáo thẩm định tổng hợp kiến trúc GSTT (teamwork review) |

---

## 6. Quyết định thiết kế đáng chú ý (Open Items resolved)

| ID | Quyết định |
|---|---|
| **O_GSTT_50** | Sở hữu NN/trong nước (cấp công ty) — chuyển sang REUSE `Fact Public Company Foreign Ownership Snapshot` (NDTNN), bỏ khỏi `Fact Major Shareholder Ownership Snapshot` để tránh lặp theo cổ đông |
| **O_GSTT_51** | Biểu đồ kỹ thuật cổ phiếu — tách Fact mới `fct_security_trading_daily` cho nến ngày (từ 1 tháng trở lên), giữ nguyên `Security Trading Snapshot Dimension` cho ngày đơn lẻ và `Fact Security Trading Intraday` cho intraday |
