# OrderTrade — Tài liệu khảo sát nguồn và ánh xạ Atomic

**Phân hệ:** OrderTrade (Sổ lệnh & Sổ khớp — HOSE & HNX)  
**Mục đích:** Tài liệu tham chiếu thiết kế Atomic layer — tổng hợp nghiệp vụ nguồn, quan hệ bảng, và ánh xạ Atomic entity  
**Nguồn tài liệu:**
- Spec: `order_trade_hose_hnx_spec.xlsx` — 4 feeds: Order_HOSE, Trade_HOSE, Order_HNX, Trade_HNX
- HLD: `OrderTrade_HLD_Overview.md`
- CV registry: `ref_shared_entity_classifications.csv`
- Atomic attributes: `atomic_attributes.csv`

---

## Quy ước ký hiệu cột Ánh xạ Atomic

| Ký hiệu | Ý nghĩa |
|---|---|
| 🟢 `Tên entity` | Atomic entity được thiết kế |
| 🟢 `CV: SCHEME_CODE` | Classification Value scheme — cả bảng nguồn map thành CV |
| 🔴 (Out of scope) *lý do* | Ngoài scope Atomic |

---

## Mục lục

1. [UID-01 — Lệnh giao dịch (Order Lifecycle)](#uid-01--lệnh-giao-dịch-order-lifecycle)
2. [UID-02 — Khớp lệnh (Trade Execution)](#uid-02--khớp-lệnh-trade-execution)
3. [Phụ lục: Classification Value dùng chung](#phụ-lục-classification-value-dùng-chung)

---

## UID-01 — Lệnh giao dịch (Order Lifecycle)

Ghi nhận toàn bộ vòng đời của một lệnh giao dịch từ khi đặt vào hệ thống KRX đến khi kết thúc (Filled / Cancelled / Expired / Rejected). Mỗi bản ghi là một **event** — lệnh mới, sửa, hoặc hủy — không phải snapshot. Nguồn dữ liệu gồm Order_HOSE (sàn HOSE) và Order_HNX (sàn HNX/UPCOM/phái sinh); hai nguồn được gộp thành một entity Atomic theo quyết định thiết kế D-01 (>80% trường trùng, cùng BCV concept, phân biệt sàn bằng `market_id`).

### 1.1 Lệnh mới và định danh lệnh

**Nghiệp vụ:** Nhà đầu tư đặt lệnh qua CTCK (broker); CTCK gửi lên KRX. KRX tiếp nhận và cấp số thứ tự (`Order Accept #` / `Order Reception Number`). Lệnh được ghi vào sổ lệnh với trạng thái New (Status = 0). Tại thời điểm này hệ thống ghi nhận đầy đủ: thị trường, mã CK, chiều (mua/bán), giá, khối lượng, loại lệnh, điều kiện, thông tin NĐT và broker.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `Order_HOSE` | Sổ lệnh HOSE — event lệnh mới/sửa/hủy trên sàn HOSE | 🟢 Securities Order |
| `Order_HNX` | Sổ lệnh HNX — tương đương Order_HOSE cho sàn HNX/UPCOM/phái sinh | 🟢 Securities Order *(gộp chung — phân biệt bằng market_id)* |

**Trường định danh lệnh:**

| Trường nguồn | HOSE | HNX | Vai trò trong Atomic |
|---|---|---|---|
| ID vật lý (seq) | `Order Accept #` | `Order Reception Number` | BK phụ — unique trong ngày+Symbol |
| ID logic | `Order ID` | `order ID` | BK chính — stable, 17 ký tự |
| ID lệnh gốc | `Orig Order Accept #` | `Original Order Reception Number` | Self-FK — chuỗi sửa lệnh |
| ID logic gốc | `Orig Order ID` | `Original order ID` | Self-FK logic |

> ⚠️ `Order Accept #` và `Order Reception Number` chỉ unique trong phạm vi **ngày + Symbol**. Khi ETL cần tạo surrogate key `ds_order_id` để tránh collision cross-ngày.

### 1.2 Phân loại lệnh và điều kiện khớp

**Nghiệp vụ:** Hệ thống phân loại lệnh theo nhiều chiều — loại giá (Market/Limit/Stop), điều kiện khớp (FAS/FOK/FAK/ATO/ATC...), phiên giao dịch, loại bảng. Các trường này là Classification Value; mỗi chiều là một CV scheme riêng. HNX có thêm 2 loại lệnh đặc thù (Same side limit, Contrary side limit) và điều kiện Iceberg (`Public quantity`), Stop order (`Condition price`).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `Order_HOSE` | Chứa các trường phân loại: `Order Type`, `Order Condition`, `Board Type`, `Session`, `Market ID`, `Side`, `Modify/Cancel` | 🟢 Securities Order |
| `Order_HNX` | Tương đương HOSE + thêm: `Order Type Code` X/Y, `Public quantity` (Iceberg), `Condition price` (Stop), `Replace/cancel classification code` (1/2/3) | 🟢 Securities Order *(nullable fields cho tính năng HNX-only)* |

**CV schemes áp dụng tại UID-01:**

| Trường | CV Scheme | Ghi chú |
|---|---|---|
| `Market ID` | 🟢 `CV: ORDERTRADE_MARKET_ID` | STO/BDO/RPO/STX/UPX/BDX/DVX/HCX |
| `Board Type` / `Board ID` | 🟢 `CV: ORDERTRADE_BOARD_TYPE` | G1-G8, T1-T6, R1 |
| `Session` / `Session ID` | 🟢 `CV: ORDERTRADE_SESSION` | 00/10/20/30/40/80/90/99 |
| `Modify/Cancel` (HOSE) / `Replace/cancel classification code` (HNX) | 🟢 `CV: ORDERTRADE_ORDER_ACTION_TYPE` | HOSE: N/M/C → HNX: 1/2/3 — cần map về cùng scheme |
| `Order Type` / `Order Type Code` | 🟢 `CV: ORDERTRADE_ORDER_TYPE` | 1=Market / 2=Limit / 3=Stop Market / 4=Stop Limit |
| `Order Condition` / `Order Condition Code` | 🟢 `CV: ORDERTRADE_ORDER_CONDITION` | 0=FAS / 2=ATO / 3=FAK / 4=FOK / 6=GTD / 7=ATC / 9=MTL |
| `Side` / `Sell/Buy Classification Code` | Attribute trực tiếp | HOSE: B/S → HNX: 1=Sell / 2=Buy — map về cùng giá trị |

### 1.3 Thông tin nhà đầu tư và broker

**Nghiệp vụ:** Mỗi lệnh gắn với một tài khoản giao dịch (`Acct No`) tại một CTCK (`BRK #`). Ngoài định danh, hệ thống lưu phân loại NĐT (cá nhân/tổ chức/nước ngoài...) và phân loại giao dịch (Client/House). Các trường phân loại này là CV; tên broker là derived từ mã. Dữ liệu NĐT (tên, PIN) là PII cần cân nhắc scope.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `Order_HOSE` | Chứa: `BRK #`, `BRK`, `PIN`, `Acct No`, `Name`, `Trader No`, `Trader Name`, `Client/House`, `Invest Type`, `Foreigner Investor type`, `Market Maker Order`, `Short Sell Indicator` | 🟢 Securities Order |
| `Order_HNX` | Chứa: `Member ID`, `Account Number`, `Client/House Classification Code`, `Investor Classification Code`, `Foreign Investor Type Code`, `Quote Request Type`, `Automated Cancel Processing Classification` | 🟢 Securities Order *(gộp — `Member ID` map sang `member_code`; `Account Number` map sang `account_no`)* |

**CV schemes tại mục này:**

| Trường | CV Scheme | Ghi chú |
|---|---|---|
| `Client/House Classification Code` | 🟢 `CV: ORDERTRADE_CLIENT_HOUSE_TYPE` | 10=Client / 30=House |
| `Invest Type` / `Investor Classification Code` | 🟢 `CV: ORDERTRADE_INVESTOR_TYPE` | ⚠️ Hai scheme không tương đương (xem 7e-#2 trong HLD) |
| `Foreigner Investor type` / `Foreign Investor Type Code` | 🟢 `CV: ORDERTRADE_FOREIGN_INVESTOR_TYPE` | 00=Trong nước / 10=NN cư trú / 20=NN không cư trú |
| `Short Sell Indicator` | 🟢 `CV: ORDERTRADE_SHORT_SELL_TYPE` | 00=Bình thường / 10=Bán khống — HOSE only |
| `Automated Cancel Processing Classification` | 🟢 `CV: ORDERTRADE_AUTO_CANCEL_REASON` | 0-5 — HNX only; nullable với HOSE records |
| `Quote Request Type` | 🟢 `CV: ORDERTRADE_QUOTE_REQUEST_TYPE` | 1=Request/2=Cancel/3=Confirm/4=Reject — HNX only |

### 1.4 Trạng thái lệnh và kết quả khớp

**Nghiệp vụ:** Trong suốt vòng đời, lệnh cập nhật trạng thái (`Order Status`) và tích lũy khối lượng khớp (`Matched VOL`). Khối lượng còn lại (`Order Rqty`) = Order VOL − Matched VOL − khối lượng hủy. Lệnh kết thúc khi đạt Status 2 (Filled), 3 (Cancelled), 4 (Rejected), hoặc 5 (Expired). Status 4 xảy ra trước khi lệnh vào order book; Status 5 xảy ra sau khi hết phiên với phần chưa khớp.

> **Lưu ý ETL quan trọng:** HNX không có trường `Order Status` tường minh (xem 7e-#3 trong HLD). Cần ETL derive từ `Replace/cancel classification code` + `Automated Cancel Classification` + logic khớp.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `Order_HOSE` | Chứa: `Order Status`, `Matched VOL`, `Immed. Matched VOL`, `Order Rqty`, `Execution Price`, `LTP`, `Order Reject Reason Code` *(trường này có trong HNX)* | 🟢 Securities Order |
| `Order_HNX` | Chứa: `Order Remaining Quantity`, `Order Reject Reason Code`. Không có `Order Status` tường minh — ETL derive. | 🟢 Securities Order |

**CV scheme:**

| Trường | CV Scheme | Ghi chú |
|---|---|---|
| `Order Status` | 🟢 `CV: ORDERTRADE_ORDER_STATUS` | 0=New/1=Partial/2=Filled/3=Cancelled/4=Rejected/5=Expired/6-7=Pending/8=Replaced — HOSE only, HNX ETL derived |

**Trường không lưu vào Atomic (derived/operational):**

| Trường | Lý do |
|---|---|
| `Order Price - LTP` | Derived = Order Price − LTP — quyết định D-04 |
| `Matched Ratio` | Derived = Matched VOL / Order VOL — quyết định D-04 |
| `Buy Up/Sell Down Amt` | Derived từ Price + Reference price |
| `Buy Up/Sell Down Tick` | Derived từ Price + bước giá |
| `Expected execution price` | Estimated — không phải confirmed data |
| `Expected execution volume` | Estimated — không phải confirmed data |
| `New High/Low Price` | Operational/derived — tính được từ price history |
| `Icd-Bug Qty` | Operational/system field |
| `BRK` (tên CTCK) | Derived từ BRK # — lookup từ bảng master |

---

## UID-02 — Khớp lệnh (Trade Execution)

Ghi nhận từng sự kiện khớp lệnh thành công. Mỗi bản ghi `Trade` là một giao dịch bất biến — không cập nhật sau khi tạo. Điểm đặc trưng: **một bản ghi chứa thông tin cả bên mua lẫn bên bán**, khác hoàn toàn với Order (chỉ một phía). Nguồn gồm Trade_HOSE và Trade_HNX; gộp thành một Atomic entity theo quyết định D-02, với các trường đặc thù HNX (Spread legs) là nullable.

### 2.1 Sự kiện khớp và định danh giao dịch

**Nghiệp vụ:** Khi hai lệnh đối nhau (mua ≥ giá bán) trong order book, KRX tự động khớp và sinh một bản ghi Trade. Giá khớp (`Exec Price`), khối lượng (`Exec Volume`), và thời điểm (`Time`) là thông tin confirmed. Với HOSE, `Exec Value` = Exec Price × Exec Volume được cung cấp sẵn; với HNX cần tính lại. Trade # là khóa trong ngày+Symbol, cần surrogate key `ds_trade_id` khi ETL.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `Trade_HOSE` | Sổ khớp HOSE — mỗi bản ghi = 1 lần khớp thành công, chứa Buy side + Sell side + Exec info | 🟢 Securities Trade |
| `Trade_HNX` | Sổ khớp HNX — tương đương Trade_HOSE + thêm `Execution Price of Spread First/Second` cho Spread trade | 🟢 Securities Trade *(gộp chung — Spread legs nullable với HOSE records)* |

**Trường join Trade → Order:**

| Trường Trade | HOSE | HNX | FK đến |
|---|---|---|---|
| Buy side | `Buy - Order Accept #` | `Buy Order Reception Number` | `Order_HOSE/HNX.Order Accept #` → Atomic: `ds_buy_order_id` |
| Sell side | `Sell - Order Accept #` | `Sell Order Reception Number` | `Order_HOSE/HNX.Order Accept #` → Atomic: `ds_sell_order_id` |

> Theo quyết định D-03: Securities Trade denormalize trực tiếp `member_code` + `account_no` của cả hai phía (buy + sell) thay vì chỉ giữ FK Order. Hai FK `ds_buy_order_id` và `ds_sell_order_id` có thể nullable khi Order không resolve được (xem 7e-#5).

### 2.2 Thông tin bên mua và bên bán

**Nghiệp vụ:** Sổ khớp lưu song song thông tin của cả hai phía giao dịch trong cùng một dòng. Với mỗi phía (Buy/Sell) có đầy đủ: CTCK (`BRK #`), tài khoản (`Acct No`), loại hình NĐT, phân loại Client/House. Tên NĐT (`Name`) là PII — cân nhắc scope. Các trường loại hình NĐT và Client/House dùng chung CV scheme với Order.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `Trade_HOSE` | Buy side: `Buy - BRK #`, `Buy - Acct No`, `Buy - Name`, `Buy - Client/House`, `Buy - Invest Type`, `Buy - Foreigner Investor type`, `Buy - Order Price`, `Buy - Order VOL`, `Buy - Trader No/Name` | 🟢 Securities Trade *(denormalize buy side trực tiếp)* |
| `Trade_HOSE` | Sell side: mirror của Buy side với prefix `Sell -` | 🟢 Securities Trade *(denormalize sell side trực tiếp)* |
| `Trade_HNX` | Buy side: `Buy member number`, `Buy account number`, `Buy client/house classification`, `Buy investor classification code`, `Buy order type code`, `Buy order condition code`, `Buy Quote Request Code`, `Buy Foreign Investor Type Code` | 🟢 Securities Trade *(gộp — nullable fields cho HNX-only)* |
| `Trade_HNX` | Sell side: mirror với prefix `Sell` | 🟢 Securities Trade |

**Trường không lưu vào Atomic:**

| Trường | Lý do |
|---|---|
| `Buy - BRK` / `Sell - BRK` (tên CTCK) | Derived từ BRK # — lookup từ bảng master |
| `Buy - Name` / `Sell - Name` | PII — cân nhắc scope |
| `Buy - Trader Name` / `Sell - Trader Name` | PII |
| `Execution - Exec Price - LTP` | Derived — quyết định D-04 *(xem 7e-#6: exec_price_vs_ltp có thể thêm nếu cần giám sát thị trường)* |
| `Execution - New High/Low Price` | Operational/derived |

### 2.3 Spread trade (HNX-only)

**Nghiệp vụ:** Với một số giao dịch phái sinh và repo trên HNX, một Trade có thể gồm hai vế (Spread trade). Leg 1 và Leg 2 có giá khớp riêng biệt (`Execution Price of Spread First/Second`). Trường này nullable với mọi bản ghi HOSE và Trade HNX không phải Spread.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `Trade_HNX` | `Execution Price of Spread First` — giá khớp Leg 1 của Spread trade | 🟢 Securities Trade *(nullable — HNX Spread only)* |
| `Trade_HNX` | `Execution Price of Spread Second` — giá khớp Leg 2 của Spread trade | 🟢 Securities Trade *(nullable — HNX Spread only)* |

---

## Phụ lục: Classification Value dùng chung

Các CV scheme sau được tham chiếu bởi cả Securities Order và Securities Trade, và đã được đăng ký trong `ref_shared_entity_classifications.csv` với `source_table` chứa `OrderTrade.`:

| CV Scheme | Bảng nguồn | Sử dụng bởi | Ghi chú |
|---|---|---|---|
| `ORDERTRADE_MARKET_ID` | Order_HOSE, Order_HNX, Trade_HOSE, Trade_HNX | Securities Order, Securities Trade | 8 giá trị: STO/BDO/RPO/STX/UPX/BDX/DVX/HCX |
| `ORDERTRADE_BOARD_TYPE` | Order_HOSE, Order_HNX, Trade_HOSE, Trade_HNX | Securities Order, Securities Trade | G1-G8, T1-T6, R1 — 12 giá trị |
| `ORDERTRADE_SESSION` | Order_HOSE, Order_HNX, Trade_HOSE, Trade_HNX | Securities Order, Securities Trade | 14 giá trị từ 00 đến 99 |
| `ORDERTRADE_CLIENT_HOUSE_TYPE` | Order_HOSE, Order_HNX, Trade_HOSE, Trade_HNX | Securities Order, Securities Trade | 10=Client / 30=House |
| `ORDERTRADE_INVESTOR_TYPE` | Order_HOSE, Order_HNX, Trade_HOSE, Trade_HNX | Securities Order, Securities Trade | ⚠️ Hai scheme HOSE vs HNX cần map trước khi dùng chung |
| `ORDERTRADE_FOREIGN_INVESTOR_TYPE` | Order_HOSE, Order_HNX, Trade_HOSE, Trade_HNX | Securities Order, Securities Trade | 00/10/20 |
| `ORDERTRADE_ORDER_ACTION_TYPE` | Order_HOSE, Order_HNX | Securities Order | HOSE N/M/C ↔ HNX 1/2/3 — cần mapping |
| `ORDERTRADE_ORDER_TYPE` | Order_HOSE, Order_HNX | Securities Order | 1/2/3/4 + HNX: X/Y |
| `ORDERTRADE_ORDER_CONDITION` | Order_HOSE, Order_HNX | Securities Order | 0/1/2/3/4/6/7/9 |
| `ORDERTRADE_ORDER_STATUS` | Order_HOSE | Securities Order | HOSE only — HNX ETL derived |
| `ORDERTRADE_SHORT_SELL_TYPE` | Order_HOSE | Securities Order | HOSE only — 00/10 |
| `ORDERTRADE_AUTO_CANCEL_REASON` | Order_HNX | Securities Order | HNX only — 0-5; nullable với HOSE |
| `ORDERTRADE_QUOTE_REQUEST_TYPE` | Order_HNX, Trade_HNX | Securities Order, Securities Trade | HNX only — 1/2/3/4; nullable với HOSE |
