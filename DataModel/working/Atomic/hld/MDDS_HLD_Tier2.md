# MDDS HLD — Tier 2

**Source system:** MDDS (Hệ thống phân phối dữ liệu thị trường — Bảng giá, sổ khớp, chỉ số realtime)
**Tier 2:** Phụ thuộc Tier 1 — Log khớp lệnh tick-by-tick và thành phần rổ chỉ số

---

## 6a. Bảng tổng quan BCV Concept

| BCV Core Object | BCV Concept | Category | Source Table | Source Table Change Mode | Mô tả bảng nguồn | Atomic Entity | Table Type | BCV Term |
|---|---|---|---|---|---|---|---|---|
| Transaction | [Transaction] Financial Market Transaction | Financial Markets Trading | TransLog | Append | Log tick-by-tick từng lần khớp lệnh cổ phiếu: giá khớp, KL khớp, chiều chủ động, tích lũy KL/GT | Security Match Log | Fact Append | (1) BCV term: **Financial Market Transaction** (Transaction) — *"transaction that represents the adjustment of a holding in a Financial Market Instrument; for example, equity purchase"*. (2) Cấu trúc trường: `Id` (PK unique), `symbol`, `tradingdate`, `formattedTime`, `formattedMatchPrice`, `formattedVol`, `lastColor` (chiều chủ động), `formattedAccVol/Val` (lũy kế). Mỗi dòng = 1 lần khớp lệnh thực tế (1 tick). BRD ghi `Append` — không có update/delete. (3) Chọn term này: mỗi tick khớp lệnh = 1 Financial Market Transaction của instrument. Table type = Fact Append (insert-only, grain = 1 tick khớp). |
| Group | [Group] Share Index | Financial Markets | CSIDXInfor | Update | Thành phần rổ chỉ số: cặp (IndexCode × Symbol) với KL và ngày vào rổ | Index Constituent Snapshot | Fact Snapshot | (1) BCV term candidate: **Share Index** (Group) — đã dùng cho MarketInfor. CSIDXInfor là thành phần (constituent) của 1 share index. BCV có quan hệ "Group Contains Product" phản ánh đúng quan hệ index chứa instrument. (2) Cấu trúc trường: `id` (PK), `indexcode` (FK đến index/MarketInfor), `symbol` (FK đến StockInfor), `adddate` (ngày vào rổ), `tradingdate`. 1 dòng = 1 cặp (index, symbol, tradingdate). Đây là Snapshot thành phần rổ theo ngày — cùng symbol có thể xuất hiện nhiều ngày khác nhau. (3) Chọn **Share Index** với sub-entity "Index Constituent": bảng mô tả quan hệ cặp (index, instrument) trong rổ chỉ số. Table type = Fact Snapshot vì grain = 1 cặp (indexcode, symbol, tradingdate) — chụp thành phần rổ theo ngày. |

---

## 6b. Diagram Source (Mermaid)

```mermaid
erDiagram
    JAD_STOCKINFOR {
        varchar historyid PK
        varchar symbol
        varchar tradingdate
    }

    JAD_MARKETINFOR {
        varchar historyid PK
        varchar marketcode
        varchar tradingdate
    }

    JAD_TRANSLOG {
        varchar Id PK
        varchar symbol
        varchar tradingdate
        varchar formattedTime
        double formattedMatchPrice
        bigint formattedVol
        varchar lastColor
    }

    JAD_CSIDXINFOR {
        varchar id PK
        varchar indexcode
        varchar symbol
        varchar tradingdate
        varchar adddate
    }

    JAD_STOCKINFOR ||--o{ JAD_TRANSLOG : "symbol + tradingdate"
    JAD_MARKETINFOR ||--o{ JAD_CSIDXINFOR : "indexcode ref marketcode"
    JAD_STOCKINFOR ||--o{ JAD_CSIDXINFOR : "symbol"
```

---

## 6c. Diagram Atomic (Mermaid)

```mermaid
erDiagram
    Security_Trading_Snapshot {
        bigint ds_snapshot_id PK
    }

    Market_Index_Snapshot {
        bigint ds_snapshot_id PK
    }

    Security_Match_Log {
        bigint ds_match_id PK
        varchar symbol
        date trading_date
        timestamp match_time
        decimal match_price
        bigint match_volume
        varchar trade_direction_code
        bigint acc_volume
        decimal acc_value
        varchar source_id
    }

    Index_Constituent_Snapshot {
        bigint ds_constituent_id PK
        varchar index_code
        varchar symbol
        date trading_date
        date add_date
        varchar floor_code
    }

    Security_Trading_Snapshot ||--o{ Security_Match_Log : "symbol + trading_date"
    Market_Index_Snapshot ||--o{ Index_Constituent_Snapshot : "index_code ref market_code"
    Security_Trading_Snapshot ||--o{ Index_Constituent_Snapshot : "symbol"
```

> Entity Tier 1 hiển thị dạng node tham chiếu.

---

## 6d. Mục Danh mục & Tham chiếu (Reference Data)

| Source Field / Bảng | Mô tả | Scheme Code | source_type | Ghi chú |
|---|---|---|---|---|
| TransLog.lastColor | Chiều mua/bán chủ động: Buy/Sell indicator | `MDDS_TRADE_DIRECTION` | source_table | Cùng scheme với StockInfor.lastcolor — đăng ký 1 lần tại Tier 1 |
| CSIDXInfor.floorcode | Mã sở giao dịch | `MDDS_FLOOR_CODE` | source_table | Cùng scheme với StockInfor.floorcode — đã đăng ký Tier 1 |

---

## 6e. Bảng chờ thiết kế

*(Để trống — tất cả bảng Tier 2 đã thiết kế)*

---

## 6f. Điểm cần xác nhận

| # | Câu hỏi | Kết quả |
|---|---|---|
| T2-01 | **CSIDXInfor table type**: BRD ghi `data_change_mode: Update` nhưng bảng có `tradingdate` — có thể vừa update vừa có lịch sử nhiều ngày. Fact Snapshot (chụp theo ngày) hay Relative (SCD2, phụ thuộc MarketInfor)? | Đề xuất **Fact Snapshot**: grain = (indexcode, symbol, tradingdate) — 1 cặp per ngày. ETL insert-only theo partition ngày. Nếu chỉ cần trạng thái hiện tại → Relative. Cần xác nhận use case. |
| T2-02 | **Security_Match_Log FK**: TransLog join với StockInfor qua `(symbol, tradingdate)` — không có surrogate key FK trực tiếp. Trên Atomic, có tạo FK `ds_instrument_snapshot_id` trỏ về Security Trading Snapshot không? | Đề xuất: lưu `symbol` + `trading_date` dạng denormalized (không tạo FK surrogate sang snapshot) vì TransLog là Fact Append, join sẽ thực hiện tại Gold layer. Cần xác nhận với ETL team. |
| T2-03 | **CSIDXInfor.totalqtty**: Là tổng KL khớp lệnh của symbol trong ngày — trùng với StockInfor.totaltrading. Có cần giữ không? | Giữ nguyên theo nguyên tắc mapping 1-1 từ nguồn. Ghi chú tại LLD. |
