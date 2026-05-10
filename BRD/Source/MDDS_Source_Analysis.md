# MDDS — Tài liệu khảo sát nguồn và ánh xạ Atomic

**Phân hệ:** MDDS (Market Data Distribution System)  
**Mục đích:** Tài liệu tham chiếu cho thiết kế Atomic layer — tổng hợp nghiệp vụ nguồn, quan hệ bảng, và ánh xạ Atomic entity theo từng nhóm chức năng.  
**Nguồn tài liệu:**
- Cấu trúc dữ liệu nguồn: `MDDS_PriceBoardAPI.xlsx` (9 sheet, phân tích từ API spec)
- HLD: `MDDS_HLD_Overview.md`
- Atomic entities: `atomic_entities.csv`
- Classification Value registry: `ref_shared_entity_classifications.csv`

---

## Bảng quy ước — Ký hiệu cột Ánh xạ Atomic

| Ký hiệu | Ý nghĩa |
|---|---|
| 🟢 Tên entity | Atomic entity được thiết kế |
| 🟢 `CV: SCHEME_CODE` | Classification Value — danh mục mã hóa (tra từ `ref_shared_entity_classifications.csv`) |
| 🟢 ↳ denormalize vào *Entity* | Junction table flatten vào entity chính |
| 🔴 (Out of scope) *lý do* | Ngoài scope Atomic |

---

## Mục lục

- [UID-01 — Thị trường và chỉ số tổng hợp](#uid-01--thị-trường-và-chỉ-số-tổng-hợp)
  - [1.1 Snapshot trạng thái sàn giao dịch](#11-snapshot-trạng-thái-sàn-giao-dịch)
  - [1.2 Snapshot chỉ số thị trường](#12-snapshot-chỉ-số-thị-trường)
  - [1.3 Thành phần rổ chỉ số](#13-thành-phần-rổ-chỉ-số)
- [UID-02 — Bảng giá chứng khoán và khớp lệnh](#uid-02--bảng-giá-chứng-khoán-và-khớp-lệnh)
  - [2.1 Snapshot bảng giá chứng khoán](#21-snapshot-bảng-giá-chứng-khoán)
  - [2.2 Log khớp lệnh tick-by-tick (cổ phiếu)](#22-log-khớp-lệnh-tick-by-tick-cổ-phiếu)
- [UID-03 — Trái phiếu doanh nghiệp](#uid-03--trái-phiếu-doanh-nghiệp)
  - [3.1 Snapshot bảng giá trái phiếu doanh nghiệp](#31-snapshot-bảng-giá-trái-phiếu-doanh-nghiệp)
  - [3.2 Log khớp lệnh tick-by-tick (trái phiếu DN)](#32-log-khớp-lệnh-tick-by-tick-trái-phiếu-dn)
- [Phụ lục: Danh mục Classification Value](#phụ-lục-danh-mục-classification-value)

---

## UID-01 — Thị trường và chỉ số tổng hợp

Nhóm chức năng này cung cấp dữ liệu tổng hợp về trạng thái các sàn giao dịch (HOSE, HNX, UPCOM) và các chỉ số thị trường (VN-Index, HNX-Index, VN30, HNX30...). Dữ liệu được broadcast theo thời gian thực từ MDDS, phục vụ giám sát thanh khoản thị trường tổng thể, theo dõi biến động chỉ số intraday, và phân tích cơ cấu rổ chỉ số.

---

### 1.1 Snapshot trạng thái sàn giao dịch

**Nghiệp vụ:** Mỗi khi trạng thái thị trường thay đổi (điểm chỉ số, tổng khối lượng, số mã tăng/giảm...), MDDS phát một bản tin `MarketInfor` cho từng sàn/chỉ số tổng hợp. Bản tin mang `marketId` xác định sàn (10=HOSE, 02=HNX, 04=UPCOM) hoặc chỉ số phức hợp (VN30, HNX30...). Nguồn dữ liệu: sàn HOSE/HNX broadcast qua ActiveMQ. Không có vai trò người dùng trực tiếp — dữ liệu tự động từ sở.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `MarketInfor` | Snapshot tổng hợp trạng thái sàn/chỉ số tại một thời điểm — điểm chỉ số, tổng KL/GT, số mã tăng/giảm/trần/sàn, trạng thái phiên, giao dịch thỏa thuận | 🟢 Market Snapshot |
| &nbsp;&nbsp;├── `marketId` | Mã sàn hoặc chỉ số tổng hợp (grain của snapshot) | 🟢 `CV: MDDS_MARKET_ID` |
| &nbsp;&nbsp;└── `marketStatus` | Trạng thái phiên giao dịch tại thời điểm snapshot | 🟢 `CV: MDDS_MARKET_STATUS` |

---

### 1.2 Snapshot chỉ số thị trường

**Nghiệp vụ:** `IDXInfor` cung cấp thông tin đầy đủ hơn `MarketInfor` cho từng mã chỉ số: bao gồm OHLC (giá trị cao nhất/thấp nhất/đóng cửa), phân loại loại chỉ số (thị trường/ngành/top), và thống kê đầy đủ số mã trong rổ. Grain là (IndexCode × thời điểm) — chi tiết đến từng mã chỉ số, khác với `MarketInfor` grain theo sàn. Nguồn: broadcast từ sàn HNX/HOSE qua MDDS.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `IDXInfor` | Snapshot đầy đủ của một chỉ số thị trường: giá trị, OHLC trong ngày, thống kê mã trong rổ, phân loại loại chỉ số | 🟢 Market Index Snapshot |
| &nbsp;&nbsp;├── `TypeIndex` | Loại chỉ số: 0=Toàn thị trường, 1=Bảng, 2=Phức hợp, 3=Ngành, 4=Top | 🟢 `CV: MDDS_INDEX_TYPE` |
| &nbsp;&nbsp;└── `CurrentStatus` | Trạng thái chỉ số | 🟢 `CV: MDDS_INDEX_STATUS` |

---

### 1.3 Thành phần rổ chỉ số

**Nghiệp vụ:** `CSIDXInfor` mô tả quan hệ thành phần giữa chỉ số và mã chứng khoán trong rổ. Mỗi bản tin là một cặp (IndexCode, Symbol) kèm tỷ trọng (`Weighted`) và ngày vào rổ (`AddDate`). Đây là dữ liệu nền tảng để tính toán đóng góp của từng mã vào biến động chỉ số (index attribution). Grain: (IndexCode × Symbol × ngày giao dịch).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `IDXInfor` | Chỉ số cha của constituent (xem [1.2](#12-snapshot-chỉ-số-thị-trường)) | 🟢 Market Index Snapshot *(xem 1.2)* |
| `StockInfor` | Mã chứng khoán trong rổ (xem [2.1](#21-snapshot-bảng-giá-chứng-khoán)) | 🟢 Security Trading Snapshot *(xem 2.1)* |
| &nbsp;&nbsp;└── `CSIDXInfor` | Thành phần rổ chỉ số: tỷ trọng (Weighted), ngày vào rổ (AddDate), tổng KL ngày. Không phải pure junction vì có attribute nghiệp vụ riêng. | 🟢 Index Constituent Snapshot |

---

## UID-02 — Bảng giá chứng khoán và khớp lệnh

Nhóm chức năng cốt lõi của MDDS: cung cấp snapshot bảng giá và lịch sử từng lần khớp lệnh cho toàn bộ chứng khoán niêm yết (cổ phiếu, CCQ, chứng quyền, phái sinh) trên HOSE, HNX, UPCOM. Đây là dữ liệu có tần suất cao nhất và độ chi tiết lớn nhất trong hệ thống.

---

### 2.1 Snapshot bảng giá chứng khoán

**Nghiệp vụ:** Mỗi khi có thay đổi lệnh hoặc khớp lệnh, MDDS broadcast bản tin `StockInfor` cho mã tương ứng. Bản tin chứa đầy đủ: giá tham chiếu/trần/sàn, sổ lệnh 3 bước giá mua/bán, giá khớp gần nhất, tổng tích lũy KL/GT từ đầu ngày, thông tin nhà đầu tư nước ngoài (room/mua/bán), và thông tin đặc thù theo loại chứng khoán (open interest cho phái sinh, giá thực hiện/tỷ lệ chuyển đổi/ngày đáo hạn cho chứng quyền). `StockType` kết hợp `FloorCode` xác định loại instrument. Trường `Status` dạng pipe-separated cần parse riêng theo sàn.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `StockInfor` | Snapshot bảng giá đa loại instrument tại một thời điểm — giá, sổ lệnh, tổng tích lũy, NĐTNN, đặc thù derivative/warrant | 🟢 Security Trading Snapshot |
| &nbsp;&nbsp;├── `FloorCode` | Sàn giao dịch: 02=HNX, 04=UPCOM, 10=HOSE, 03=FDS, 06=Corp Bond | 🟢 `CV: MDDS_FLOOR_CODE` |
| &nbsp;&nbsp;├── `StockType` | Loại chứng khoán — phân loại theo sàn (HNX: BO/ST/MF/FU/OP/EF; HOSE: B/S/U/E/D/W). Cần parse kết hợp `FloorCode`. | 🟢 `CV: MDDS_STOCK_TYPE` |
| &nbsp;&nbsp;├── `tradingSessionID` | Mã phiên giao dịch (ATO, Continuous, ATC...) | 🟢 `CV: MDDS_TRADING_SESSION` |
| &nbsp;&nbsp;├── `CoveredWarrantType` | Loại chứng quyền — chỉ có giá trị khi StockType=W | 🟢 `CV: MDDS_COVERED_WARRANT_TYPE` |
| &nbsp;&nbsp;└── `underlyingSymbol` | Mã tài sản cơ sở (tự tham chiếu) — lưu denormalized dạng code, không tạo FK surrogate do Snapshot không có surrogate ổn định qua thời gian | 🟢 Security Trading Snapshot *(self-ref — denormalized code)* |

---

### 2.2 Log khớp lệnh tick-by-tick (cổ phiếu)

**Nghiệp vụ:** Mỗi lần khớp lệnh phát sinh một bản tin `TransLog`. Đây là dữ liệu chi tiết nhất: ghi nhận giá khớp, khối lượng, chiều chủ động (`lastColor`: B=Mua chủ động, S=Bán chủ động, O=ATO, C=ATC), và tích lũy KL/GT từ đầu ngày. Trường `totalBuyVol` và `totalSellVol` tích lũy theo chiều giúp tính Buy Pressure Ratio. `sequenceMsg` tăng đơn điệu trong ngày (reset mỗi ngày), đảm bảo thứ tự xử lý. **Lưu ý semantics:** B/S trong MDDS là chiều bên đặt lệnh đối ứng — ngược với quy ước bảng giá thông thường; giữ nguyên giá trị nguồn và document rõ tại LLD.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `StockInfor` | Mã chứng khoán được khớp lệnh (xem [2.1](#21-snapshot-bảng-giá-chứng-khoán)) | 🟢 Security Trading Snapshot *(xem 2.1)* |
| &nbsp;&nbsp;└── `TransLog` | Log tick-by-tick từng lần khớp lệnh: giá khớp, KL khớp, chiều chủ động, tích lũy KL/GT, tổng mua/bán chủ động. Insert-only, không update. | 🟢 Security Match Log |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── `lastColor` | Chiều giao dịch chủ động: B, S, O, C | 🟢 `CV: MDDS_MATCH_DIRECTION` |

---

## UID-03 — Trái phiếu doanh nghiệp

Nhóm chức năng phục vụ thị trường trái phiếu doanh nghiệp niêm yết trên HNX (FloorCode=06). Cơ chế giao dịch chủ yếu là thỏa thuận Outright, khác biệt hoàn toàn so với khớp lệnh thông thường — có order book riêng (PT_Best*, PT_Total*). UBCKNN theo dõi để giám sát rủi ro tín dụng và thanh khoản thị trường TPDN.

---

### 3.1 Snapshot bảng giá trái phiếu doanh nghiệp

**Nghiệp vụ:** `CorpBondInfor` là tương đương của `StockInfor` cho thị trường TPDN. Ngoài thông tin giao dịch thông thường (giá, KL tích lũy), bản tin còn mang đầy đủ đặc thù trái phiếu: kỳ hạn gốc và kỳ hạn còn lại (`BOND_PERIOD`, `PERIOD_REMAIN`), lãi suất danh nghĩa (`INTEREST_RATE`), loại lãi suất cố định/thả nổi, kiểu coupon, phương thức trả lãi, mệnh giá, ngày phát hành/đáo hạn. Order book thỏa thuận Outright riêng biệt (`PT_Best*`, `PT_Max/Min`). Tổ chức phát hành (`IssuerName`) có thể map đến `Public Company` trong IDS.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `CorpBondInfor` | Snapshot bảng giá TPDN: giá, order book thỏa thuận Outright (PT_*), đặc thù bond (kỳ hạn, lãi suất, coupon, mệnh giá, ngày phát hành/đáo hạn). FloorCode=06, StockType=12 cố định. | 🟢 Corporate Bond Trading Snapshot |
| &nbsp;&nbsp;├── `PERIOD_UNIT` | Đơn vị kỳ hạn: 1=Ngày, 2=Tuần, 3=Tháng, 4=Năm | 🟢 `CV: MDDS_PERIOD_UNIT` |
| &nbsp;&nbsp;├── `INTEREST_TYPE` | Loại hình lãi suất: 1=Coupon, 2=Zero Coupon | 🟢 `CV: MDDS_BOND_INTEREST_TYPE` |
| &nbsp;&nbsp;├── `INTERESTRATE_TYPE` | Loại lãi suất: 1=Cố định, 2=Thả nổi | 🟢 `CV: MDDS_INTEREST_RATE_TYPE` |
| &nbsp;&nbsp;├── `INTEREST_COUPON_TYPE` | Kiểu coupon: 1=Standard, 2=Long Coupon, 3=Short Coupon, 4=Khác | 🟢 `CV: MDDS_COUPON_TYPE` |
| &nbsp;&nbsp;├── `INTEREST_PAYMENT_TYPE` | Phương thức trả lãi: 1=Định kỳ cuối kỳ, 2=Định kỳ đầu kỳ | 🟢 `CV: MDDS_INTEREST_PAYMENT_TYPE` |
| &nbsp;&nbsp;├── `securityTradingStatus` | Trạng thái trái phiếu (0=Bình thường, ngừng GD, hạn chế GD...) | 🟢 `CV: MDDS_SECURITY_TRADING_STATUS` |
| &nbsp;&nbsp;├── `tradSesStatus` | Trạng thái phiên TPDN | 🟢 `CV: MDDS_TRAD_SES_STATUS` |
| &nbsp;&nbsp;└── `IssuerName` | Mã tổ chức phát hành — FK đến Public Company (IDS). Cặp `issuer_public_company_id` (FK surrogate) + `issuer_name` (denormalized). Cần xác nhận join key tại LLD. | 🟢 Corporate Bond Trading Snapshot *(FK → IDS Public Company)* |

---

### 3.2 Log khớp lệnh tick-by-tick (trái phiếu DN)

**Nghiệp vụ:** `CorpBondMatch` là tương đương của `TransLog` cho thị trường TPDN. Ghi nhận từng lần khớp lệnh theo thứ tự `ConfirmNoCorpBond` (thay cho `sequenceMsg`). Tần suất thấp hơn cổ phiếu nhưng giá trị mỗi giao dịch lớn hơn đáng kể. `marketId` luôn = 06. Cùng semantics `lastColor` (B/S/O/C) với `TransLog`.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `CorpBondInfor` | Mã trái phiếu được khớp lệnh (xem [3.1](#31-snapshot-bảng-giá-trái-phiếu-doanh-nghiệp)) | 🟢 Corporate Bond Trading Snapshot *(xem 3.1)* |
| &nbsp;&nbsp;└── `CorpBondMatch` | Log tick-by-tick từng lần khớp lệnh TPDN: giá khớp, KL khớp, chiều chủ động, tích lũy KL/GT. Insert-only. Dùng ConfirmNoCorpBond làm số thứ tự. | 🟢 Corporate Bond Match Log |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── `lastColor` | Chiều giao dịch chủ động (cùng scheme với TransLog) | 🟢 `CV: MDDS_MATCH_DIRECTION` |

---

## Phụ lục: Danh mục Classification Value

Các Classification Value scheme của MDDS được đăng ký trong `ref_shared_entity_classifications.csv`. Tất cả đều có `source_type = source_table` (values load từ bảng nguồn).

| Scheme Code | Ý nghĩa | Sử dụng bởi | Nguồn |
|---|---|---|---|
| `MDDS_MARKET_ID` | Mã sàn/chỉ số tổng hợp (10=HOSE, 02=HNX, 04=UPCOM...) | Market Snapshot | `MDDS.MarketInfor.marketId` |
| `MDDS_MARKET_STATUS` | Trạng thái phiên giao dịch (ATO, Continuous, ATC, Closed...) | Market Snapshot | `MDDS.MarketInfor.marketStatus` |
| `MDDS_INDEX_TYPE` | Loại chỉ số (0=Toàn thị trường, 1=Bảng, 2=Phức hợp, 3=Ngành, 4=Top) | Market Index Snapshot | `MDDS.IDXInfor.TypeIndex` |
| `MDDS_INDEX_STATUS` | Trạng thái chỉ số | Market Index Snapshot | `MDDS.IDXInfor.CurrentStatus` |
| `MDDS_FLOOR_CODE` | Mã sàn giao dịch (02=HNX, 04=UPCOM, 10=HOSE, 03=FDS, 06=Corp Bond) | Security Trading Snapshot | `MDDS.StockInfor.FloorCode` |
| `MDDS_STOCK_TYPE` | Loại chứng khoán — parse kết hợp FloorCode (HNX: BO/ST/MF/FU/OP/EF; HOSE: B/S/U/E/D/W) | Security Trading Snapshot | `MDDS.StockInfor.StockType` |
| `MDDS_TRADING_SESSION` | Mã phiên giao dịch (ATO, Continuous, ATC...) | Security Trading Snapshot | `MDDS.StockInfor.tradingSessionID` |
| `MDDS_COVERED_WARRANT_TYPE` | Loại chứng quyền — chỉ áp dụng khi StockType=W | Security Trading Snapshot | `MDDS.StockInfor.CoveredWarrantType` |
| `MDDS_MATCH_DIRECTION` | Chiều giao dịch chủ động: B=Mua chủ động, S=Bán chủ động, O=ATO, C=ATC | Security Match Log, Corporate Bond Match Log | `MDDS.TransLog.lastColor`, `MDDS.CorpBondMatch.lastColor` |
| `MDDS_PERIOD_UNIT` | Đơn vị kỳ hạn: 1=Ngày, 2=Tuần, 3=Tháng, 4=Năm | Corporate Bond Trading Snapshot | `MDDS.CorpBondInfor.PERIOD_UNIT`, `INTEREST_PERIOD_UNIT` |
| `MDDS_BOND_INTEREST_TYPE` | Loại hình lãi suất: 1=Coupon, 2=Zero Coupon | Corporate Bond Trading Snapshot | `MDDS.CorpBondInfor.INTEREST_TYPE` |
| `MDDS_INTEREST_RATE_TYPE` | Loại lãi suất: 1=Cố định, 2=Thả nổi | Corporate Bond Trading Snapshot | `MDDS.CorpBondInfor.INTERESTRATE_TYPE` |
| `MDDS_COUPON_TYPE` | Kiểu coupon: 1=Standard, 2=Long Coupon, 3=Short Coupon, 4=Khác | Corporate Bond Trading Snapshot | `MDDS.CorpBondInfor.INTEREST_COUPON_TYPE` |
| `MDDS_INTEREST_PAYMENT_TYPE` | Phương thức trả lãi: 1=Định kỳ cuối kỳ, 2=Định kỳ đầu kỳ | Corporate Bond Trading Snapshot | `MDDS.CorpBondInfor.INTEREST_PAYMENT_TYPE` |
| `MDDS_SECURITY_TRADING_STATUS` | Trạng thái trái phiếu (0=Bình thường, 2=Ngừng GD, 10=Tạm ngừng, 11=Hạn chế, 25=Đặc biệt) | Corporate Bond Trading Snapshot | `MDDS.CorpBondInfor.securityTradingStatus` |
| `MDDS_TRAD_SES_STATUS` | Trạng thái phiên TPDN (1=Đang nhận lệnh, 2=Tạm dừng, 13=Kết thúc, 90=Chờ, 97=Đóng cửa) | Corporate Bond Trading Snapshot | `MDDS.CorpBondInfor.tradSesStatus` |

---

## Verify

**Tổng bảng nguồn được đề cập trong file:** `MarketInfor`, `IDXInfor`, `CSIDXInfor`, `StockInfor`, `TransLog`, `CorpBondInfor`, `CorpBondMatch` = **7 bảng** ✅ (khớp master list)

**Tổng CV scheme:** 16 scheme ✅ (khớp `ref_shared_entity_classifications.csv`)

**Tổng Atomic entity được ánh xạ:** Market Snapshot, Market Index Snapshot, Index Constituent Snapshot, Security Trading Snapshot, Security Match Log, Corporate Bond Trading Snapshot, Corporate Bond Match Log = **7 entities** ✅ (khớp `atomic_entities.csv`)
