# Thống kê trường trùng nghĩa HNX ↔ HOSE — ORDER_BOOK, TRADE_BOOK

**Mục đích:** để Data Modeler quyết định gộp các cột cùng ý nghĩa thành 1 attribute Atomic (mỗi sàn trỏ về 1 cột nguồn riêng trong `source_columns`) cho entity `Securities Order` / `Securities Trade`.
**Căn cứ:** DDL mới (`ddl hnx, hose, vsdc.txt`), mô tả cột đã cập nhật trong `BRD/Source/{HNX,HOSE}/brd_*_{ORDER,TRADE}_BOOK.yaml`. Chỉ tính cột nghiệp vụ (bỏ `REPORT_YEAR/MONTH/DAY`, `DS_SNPST_DT`, `DS_ETL_PCS_TMS`).
**Trạng thái:** đề xuất để duyệt — chưa sửa LLD. Mọi mức "Cần xác nhận" là suy luận từ định nghĩa, không phải kiểm chứng trên dữ liệu thật.

Ký hiệu mức tương đương: **A** = cùng ý nghĩa, cùng bộ mã · **B** = cùng ý nghĩa, khác bộ mã/định dạng (cần normalize hoặc giữ raw theo `src_stm_code`) · **C** = gần nghĩa, cần xác nhận trước khi gộp.

## 1. Tổng hợp

| Bảng | Cột nghiệp vụ HOSE | Cột nghiệp vụ HNX | Cặp trùng nghĩa | Trong đó A / B / C | Chỉ HOSE | Chỉ HNX |
|---|---|---|---|---|---|---|
| ORDER_BOOK | 45 | 30 | 24 | 11 / 10 / 3 | 21 | 6 |
| TRADE_BOOK | 46 | 36 | 25 | 14 / 10 / 1 | 21 | 11 |

Nếu gộp toàn bộ cặp A+B: entity `Securities Order` còn 24 + 21 + 6 = **51** attribute nghiệp vụ (thay vì 75 nếu giữ tách theo tên cột nguồn); `Securities Trade` còn 25 + 21 + 11 = **57** (thay vì 82).

## 2. ORDER_BOOK — 24 cặp trùng nghĩa

| # | Attribute Atomic đề xuất | HOSE (kiểu DDL) | HNX (kiểu DDL) | Mức | Ghi chú |
|---|---|---|---|---|---|
| 1 | Trade Date | TRADE_DATE (DATE) | TRADE_DATE (STRING yyyymmdd) | B | HNX cần cast sang Date |
| 2 | Market Id | MARKET_ID (STRING) | MARKET_ID (STRING) | A | Cùng bộ mã STO/BDO/RPO/STX/UPX/BDX/DVX/HCX |
| 3 | Security Symbol | SYMBOL (STRING) | ISSUE_CODE (STRING) | C | HNX: thường là ISIN, riêng Repo do Sở tự định nghĩa; HOSE: mã giao dịch. Cần xác nhận cùng định dạng giá trị |
| 4 | Board Id | BOARD_TYPE (STRING) | BOARD_ID (STRING) | A | Cùng bộ G1…G8, T1…T6, R1 |
| 5 | Session Id | SESSION (STRING) | SESSION_ID (STRING) | A | Cùng bộ 00…99 |
| 6 | Side | SIDE (B/S) | SELL_BUY_CLASSIFICATION_CODE (1 Sell/2 Buy/3 Sell-Buy) | B | Khác mã (B/S ↔ 1/2); HNX có thêm giá trị 3 và SPACE cho lệnh hủy |
| 7 | Order Action | MODIFY_CANCEL (N/M/C) | REPLACE_CANCEL (1 New/2 Replace/3 Cancel) | B | Khác mã |
| 8 | Member/Broker Id | BRK_ID (STRING) | MEMBER_ID (STRING) | A | Mã công ty chứng khoán/thành viên |
| 9 | Account No | ACCT_NO (STRING) | ACCOUNT_NUMBER (STRING) | A | |
| 10 | Client House Classification Code | CLIENT_HOUSE_CLASSIFICATION_CODE (STRING) | CLIENT_HOUSE_CLASSIFICATION_CODE (STRING) | A | 10 Client / 30 House |
| 11 | Investor Classification Code | INVEST_TYPE (STRING) | INVESTOR_CLASSIFICATION_CODE (STRING) | B | Cùng khái niệm nhưng bộ mã khác (HOSE có 1100/1200/2100/…/9000; HNX 1000…8000) |
| 12 | Foreign Investor Type Code | FOREIGNER_INVESTOR_TYPE (STRING) | FOREIGN_INVESTOR_TYPE_CODE (STRING) | A | 00/10/20 |
| 13 | Order Type Code | ORDER_TYPE (STRING) | ORDER_TYPE_CODE (STRING) | B | HNX thêm X, Y |
| 14 | Order Condition Code | ORDER_CONDITION (STRING) | ORDER_CONDITION_CODE (STRING) | B | Mã 1: HOSE "lệnh thường", HNX "GTC" |
| 15 | Order Price | ORDER_PRICE (DECIMAL(38,4)) | ORDER_PRICE (STRING) | B | HNX cần cast sang số |
| 16 | Order Quantity | ORDER_VOL (BIGINT) | ORDER_QUANTITY (STRING) | B | HNX cần cast sang số |
| 17 | Order Remaining Quantity | ORDER_RQTY (BIGINT) | ORDER_REMAINING_QUANTITY (STRING) | B | HNX cần cast sang số |
| 18 | Order Date | ORDER_DATE (DATE) | ORDER_DATE (STRING) | B | HOSE: ngày đặt lệnh; HNX: ngày ghi nhận theo ngày giao dịch của hệ thống. HNX cần cast |
| 19 | Order Time | ORDER_TIME (STRING) | ORDER_ACCEPT_TIME (STRING) | C | HOSE: lúc người dùng đặt lệnh; HNX: lúc KRX core chấp nhận lệnh, không phải lúc đặt. Nên giữ 2 attribute riêng nếu không xác nhận được |
| 20 | Order Reception Number | ORDER_ACCEPT_ID (STRING) | ORDER_RECEPTION_NUMBER (STRING) | A | BK phụ; HOSE: số thứ tự theo ngày/mã; HNX: theo market+board+issue |
| 21 | Original Order Reception Number | ORIG_ORDER_ACCEPT_ID (STRING) | ORIGINAL_ORDER_RECEPTION_NUMBER (STRING) | A | |
| 22 | Order Code (BK chính) | ORDER_ID (STRING) | ORDER_ID (STRING) | A | |
| 23 | Original Order Code | ORIG_ORDER_ID (STRING) | ORIGINAL_ORDER_ID (STRING) | A | |
| 24 | Reference/Message Sequence | REFERENCE_SEQUENCE_NO (STRING) | MESSAGE_SEQUENCE (STRING) | C | HOSE: số tham chiếu theo thứ tự giao dịch; HNX: số thứ tự message trong luồng dữ liệu. Có thể là cùng vai trò sắp thứ tự, cần xác nhận |

**Chỉ HOSE (21):** CURRENCY, BRK, PIN, NAME, MARKET_MAKER_ORDER, LTP, EXECUTION_PRICE, IMMED_MATCHED_VOL, MATCHED_VOL, ORDER_PRICE_LTP, MATCHED_RATIO, BUY_UP_SELL_DOWN_AMT, BUY_UP_SELL_DOWN_TICK, NEW_HIGH_LOW_PRICE, ORDER_STATUS, ICD_BUG_QTY, EXPECTED_EXECUTION_PRICE, EXPECTED_EXECUTION_VOLUME, SHORT_SELL_INDICATOR, TRADER_NO, TRADER_NAME.

**Chỉ HNX (6):** ORDER_REJECT_REASON_CODE, PUBLIC_QUANTITY, CONDITION_PRICE, ORIGINAL_ORDER_TYPE_CODE, AUTOMATED_CANCEL, QUOTE_REQUEST_TYPE.

## 3. TRADE_BOOK — 25 cặp trùng nghĩa

| # | Attribute Atomic đề xuất | HOSE (kiểu DDL) | HNX (kiểu DDL) | Mức | Ghi chú |
|---|---|---|---|---|---|
| 1 | Trade Date | TRADE_DATE (DATE) | TRADE_DATE (STRING) | B | HNX cast Date |
| 2 | Market Id | MARKET_ID (STRING) | MARKET_ID (STRING) | A | |
| 3 | Security Symbol | SYMBOL (STRING) | ISSUE_CODE (STRING) | C | Xem ghi chú ORDER #3 — cùng câu hỏi định dạng giá trị (ticker ↔ ISIN) |
| 4 | Board Id | BOARD_TYPE (STRING) | BOARD_ID (STRING) | A | |
| 5 | Session Id | SESSION (BIGINT) | SESSION_ID (STRING) | B | HOSE Order là STRING nhưng Trade là BIGINT — lệch kiểu ngay trong HOSE |
| 6 | Trade Code (BK) | TRADE_NO (BIGINT) | TRADE_NUMBER (BIGINT) | A | |
| 7 | Trade Time | TIME (STRING) | TRADE_TIME (STRING) | A | |
| 8 | Execution Price | EXECUTION_EXEC_PRICE (DECIMAL(38,4)) | TRADE_PRICE (DECIMAL(38,4)) | A | |
| 9 | Execution Quantity | EXECUTION_VOLUME (BIGINT) | TRADE_QUANTITY (BIGINT) | A | |
| 10/18 | Buy/Sell Order Reception Number | BUY/SELL_ORDER_ACCEPT_NO (BIGINT) | BUY/SELL_ORDER_RECEPTION_NUMBER (DECIMAL(20,0)) | B | Khóa liên kết về Order; lệch kiểu số |
| 11/19 | Buy/Sell Member Id | BUY/SELL_BRK_NO (STRING) | BUY/SELL_MEMBER_NUMBER (STRING) | A | |
| 12/20 | Buy/Sell Account No | BUY/SELL_ACCT_NO (STRING) | BUY/SELL_ACCOUNT_NUMBER (STRING) | A | |
| 13/21 | Buy/Sell Client House Classification Code | …_CLIENT_HOUSE_CLASSIFICATION_CODE (BIGINT) | …_CLIENT_HOUSE_CLASSIFICATION (STRING) | B | Lệch kiểu; HOSE Order lại là STRING |
| 14/22 | Buy/Sell Investor Classification Code | …_INVEST_TYPE (BIGINT) | …_INVESTOR_CLASSIFICATION_CODE (STRING) | B | Lệch kiểu và bộ mã |
| 15/23 | Buy/Sell Foreign Investor Type Code | …_FOREIGNER_INVESTOR_TYPE (STRING) | …_FOREIGN_INVESTOR_TYPE_CODE (STRING) | A | |
| 16/24 | Buy/Sell Order Price | …_ORDER_PRICE (DECIMAL(38,4)) | …_ORDER_PRICE (DECIMAL(38,4)) | A | |
| 17/25 | Buy/Sell Order Quantity | …_ORDER_VOL (BIGINT) | …_ORDER_QUANTITY (DECIMAL(20,0)) | B | Lệch kiểu số |

(Dòng 10–17 là phía Mua, 18–25 là phía Bán — mỗi dòng gộp tương ứng 2 cột. Tổng 9 + 16 = 25 cặp.)

**Chỉ HOSE (21):** CURRENCY, EXECUTION_EXEC_PRICE_LTP, EXECUTION_VALUE, EXECUTION_LTP, EXECUTION_NEW_HIGH_LOW_PRICE; mỗi phía mua/bán 8 cột: ORDER_DATE, ORDER_TIME, BRK, PIN, NAME, TRADER_NO, TRADER_NAME, REFERENCE_SEQUENCE_NO (16 cột).

**Chỉ HNX (11):** MESSAGE_SEQUENCE; mỗi phía 4 cột: REPLACE_CANCEL_CLASSIFICATION_CODE, ORDER_TYPE_CODE, ORDER_CONDITION_CODE, QUOTE_REQUEST_CODE (8 cột); EXECUTION_PRICE_OF_SPREAD_FIRST, EXECUTION_PRICE_OF_SPREAD_SECOND.

## 4. Trùng nội bộ trong mỗi sàn (ORDER_BOOK ↔ TRADE_BOOK)

| Sàn | Header giống nhau | Cột bên mua/bán trong trade trùng thông tin lệnh | Cột riêng của lần khớp |
|---|---|---|---|
| HOSE | 5: TRADE_DATE, MARKET_ID, SYMBOL, CURRENCY, BOARD_TYPE (+ SESSION lệch kiểu) | 32/46 (16/bên) | 8 |
| HNX | 6: TRADE_DATE, MARKET_ID, BOARD_ID, ISSUE_CODE, SESSION_ID, MESSAGE_SEQUENCE | 24/36 (12/bên) | 6 |

Lưu ý khi cân nhắc bỏ các cột này khỏi Trade: `order_book` là event-level (mới/sửa/hủy), nên thông tin lệnh trong trade là trạng thái lúc khớp, không join ngược 1-1 được nếu lệnh đã sửa. Nội dung này là lập luận của D-08, chưa kiểm chứng trên dữ liệu.

## 5. Điểm cần Data Modeler quyết định

1. Chấp nhận gộp các cặp **A** vào 1 attribute chung?
2. Các cặp **B**: gộp và giữ raw theo `src_stm_code`, hay normalize mã về 1 bộ chung (SIDE, MODIFY/REPLACE, ORDER_TYPE…)? HLD D-08 hiện chọn normalize cho Side; các cột còn lại giữ raw.
3. Các cặp **C** (SYMBOL↔ISSUE_CODE, ORDER_TIME↔ORDER_ACCEPT_TIME, REFERENCE_SEQUENCE_NO↔MESSAGE_SEQUENCE): gộp hay giữ riêng?
4. Quy ước đặt tên 2026-11-02 (physical_name giữ nguyên tên cột nguồn) mâu thuẫn với việc gộp: attribute gộp phải có tên chung. Áp dụng quy tắc B của SKILL (full word + từ điển viết tắt) cho các attribute gộp?
5. Kiểu dữ liệu HNX là STRING cho số/ngày: domain đích là Date/Currency Amount/Small Counter, cần ghi conversion risk (ETL cast).
6. Cột lệch kiểu ngay trong HOSE (SESSION, CLIENT_HOUSE_CLASSIFICATION_CODE, INVEST_TYPE: STRING ở Order, BIGINT ở Trade): chọn 1 domain chung (đề xuất Text).
7. Mô tả trong `Securities Order/Trade` hiện còn dấu vết DDL cũ ("HNX dùng order_qty/sell_member_no", "Nguồn bigint", "decimal(18,4)", "buy/sell_scr_ordr_code") — sẽ viết lại toàn bộ khi thiết kế lại.

## 6. Trả lời
#	Attribute Atomic đề xuất	HOSE (kiểu DDL)	HNX (kiểu DDL)	Mức	Ghi chú	Chốt phương án
1	Trade Date	TRADE_DATE (DATE)	TRADE_DATE (STRING yyyymmdd)	B	HNX cần cast sang Date	trade_dt, HNX cần cast sang Date
2	Market Id	MARKET_ID (STRING)	MARKET_ID (STRING)	A	Cùng bộ mã STO/BDO/RPO/STX/UPX/BDX/DVX/HCX	market_code
3	Security Symbol	SYMBOL (STRING)	ISSUE_CODE (STRING)	C	HNX: thường là ISIN, riêng Repo do Sở tự định nghĩa; HOSE: mã giao dịch. Cần xác nhận cùng định dạng giá trị	ticker_symbol
4	Board Id	BOARD_TYPE (STRING)	BOARD_ID (STRING)	A	Cùng bộ G1…G8, T1…T6, R1	board_tp_code
5	Session Id	SESSION (STRING)	SESSION_ID (STRING)	A	Cùng bộ 00…99	session_code
6	Side	SIDE (B/S)	SELL_BUY_CLASSIFICATION_CODE (1 Sell/2 Buy/3 Sell-Buy)	B	Khác mã (B/S ↔ 1/2); HNX có thêm giá trị 3 và SPACE cho lệnh hủy	side
7	Order Action	MODIFY_CANCEL (N/M/C)	REPLACE_CANCEL (1 New/2 Replace/3 Cancel)	B	Khác mã	order_action_tp_code
8	Member/Broker Id	BRK_ID (STRING)	MEMBER_ID (STRING)	A	Mã công ty chứng khoán/thành viên	member_code
9	Account No	ACCT_NO (STRING)	ACCOUNT_NUMBER (STRING)	A		account_nbr
10	Client House Classification Code	CLIENT_HOUSE_CLASSIFICATION_CODE (STRING)	CLIENT_HOUSE_CLASSIFICATION_CODE (STRING)	A	10 Client / 30 House	account_tp_code
11	Investor Classification Code	INVEST_TYPE (STRING)	INVESTOR_CLASSIFICATION_CODE (STRING)	B	Cùng khái niệm nhưng bộ mã khác (HOSE có 1100/1200/2100/…/9000; HNX 1000…8000)	investor_tp_code
12	Foreign Investor Type Code	FOREIGNER_INVESTOR_TYPE (STRING)	FOREIGN_INVESTOR_TYPE_CODE (STRING)	A	00/10/20	foreign_investor_tp_code
13	Order Type Code	ORDER_TYPE (STRING)	ORDER_TYPE_CODE (STRING)	B	HNX thêm X, Y	order_tp_code
14	Order Condition Code	ORDER_CONDITION (STRING)	ORDER_CONDITION_CODE (STRING)	B	Mã 1: HOSE "lệnh thường", HNX "GTC"	order_condition_tp_code
15	Order Price	ORDER_PRICE (DECIMAL(38,4))	ORDER_PRICE (STRING)	B	HNX cần cast sang số	order_price, HNX cần cast sang số
16	Order Quantity	ORDER_VOL (BIGINT)	ORDER_QUANTITY (STRING)	B	HNX cần cast sang số	order_quantity, HNX cần cast sang số
17	Order Remaining Quantity	ORDER_RQTY (BIGINT)	ORDER_REMAINING_QUANTITY (STRING)	B	HNX cần cast sang số	order_remaining_quantity, HNX cần cast sang số
18	Order Date	ORDER_DATE (DATE)	ORDER_DATE (STRING)	B	HOSE: ngày đặt lệnh; HNX: ngày ghi nhận theo ngày giao dịch của hệ thống. HNX cần cast	order_dt. HNX cần cast
19	Order Time	ORDER_TIME (STRING)	ORDER_ACCEPT_TIME (STRING)	C	HOSE: lúc người dùng đặt lệnh; HNX: lúc KRX core chấp nhận lệnh, không phải lúc đặt. Nên giữ 2 attribute riêng nếu không xác nhận được	order_time
20	Order Reception Number	ORDER_ACCEPT_ID (STRING)	ORDER_RECEPTION_NUMBER (STRING)	A	BK phụ; HOSE: số thứ tự theo ngày/mã; HNX: theo market+board+issue	order_reception_code
21	Original Order Reception Number	ORIG_ORDER_ACCEPT_ID (STRING)	ORIGINAL_ORDER_RECEPTION_NUMBER (STRING)	A		original_order_reception_code
22	Order Code (BK chính)	ORDER_ID (STRING)	ORDER_ID (STRING)	A		order_code
23	Original Order Code	ORIG_ORDER_ID (STRING)	ORIGINAL_ORDER_ID (STRING)	A		original_order_code
24	Reference/Message Sequence	REFERENCE_SEQUENCE_NO (STRING)	MESSAGE_SEQUENCE (STRING)	C	HOSE: số tham chiếu theo thứ tự giao dịch; HNX: số thứ tự message trong luồng dữ liệu. Có thể là cùng vai trò sắp thứ tự, cần xác nhận	sequence_nbr

#	Attribute Atomic đề xuất	HOSE (kiểu DDL)	HNX (kiểu DDL)	Mức	Ghi chú	
1	Trade Date	TRADE_DATE (DATE)	TRADE_DATE (STRING)	B	HNX cast Date	trade_dt, HNX cast Date
2	Market Id	MARKET_ID (STRING)	MARKET_ID (STRING)	A		market_code
3	Security Symbol	SYMBOL (STRING)	ISSUE_CODE (STRING)	C	Xem ghi chú ORDER #3 — cùng câu hỏi định dạng giá trị (ticker ↔ ISIN)	ticker_symbol
4	Board Id	BOARD_TYPE (STRING)	BOARD_ID (STRING)	A		board_tp_code
5	Session Id	SESSION (BIGINT)	SESSION_ID (STRING)	B	HOSE Order là STRING nhưng Trade là BIGINT — lệch kiểu ngay trong HOSE	session_code, kiểu dữ liệu là string
6	Trade Code (BK)	TRADE_NO (BIGINT)	TRADE_NUMBER (BIGINT)	A		trade_code
7	Trade Time	TIME (STRING)	TRADE_TIME (STRING)	A		trade_time
8	Execution Price	EXECUTION_EXEC_PRICE (DECIMAL(38,4))	TRADE_PRICE (DECIMAL(38,4))	A		match_price
9	Execution Quantity	EXECUTION_VOLUME (BIGINT)	TRADE_QUANTITY (BIGINT)	A		match_quantity
10/18	Buy/Sell Order Reception Number	BUY/SELL_ORDER_ACCEPT_NO (BIGINT)	BUY/SELL_ORDER_RECEPTION_NUMBER (DECIMAL(20,0))	B	Khóa liên kết về Order; lệch kiểu số	(buy/sell)_order_reception_code, kiểu dữ liệu là bigint
11/19	Buy/Sell Member Id	BUY/SELL_BRK_NO (STRING)	BUY/SELL_MEMBER_NUMBER (STRING)	A		(buy/sell)_member_code
12/20	Buy/Sell Account No	BUY/SELL_ACCT_NO (STRING)	BUY/SELL_ACCOUNT_NUMBER (STRING)	A		(buy/sell)_account_nbr
13/21	Buy/Sell Client House Classification Code	…_CLIENT_HOUSE_CLASSIFICATION_CODE (BIGINT)	…_CLIENT_HOUSE_CLASSIFICATION (STRING)	B	Lệch kiểu; HOSE Order lại là STRING	(buy/sell)_account_tp_code, kiểu dữ liệu là string, tôi sẽ insert dữ liệu vào bảng cl_value
14/22	Buy/Sell Investor Classification Code	…_INVEST_TYPE (BIGINT)	…_INVESTOR_CLASSIFICATION_CODE (STRING)	B	Lệch kiểu và bộ mã	(buy/sell)_investor_tp_code, kiểu dữ liệu là string, tôi sẽ insert dữ liệu vào bảng cl_value
15/23	Buy/Sell Foreign Investor Type Code	…_FOREIGNER_INVESTOR_TYPE (STRING)	…_FOREIGN_INVESTOR_TYPE_CODE (STRING)	A		(buy/sell)_foreign_investor_tp_code
16/24	Buy/Sell Order Price	…_ORDER_PRICE (DECIMAL(38,4))	…_ORDER_PRICE (DECIMAL(38,4))	A		(buy/sell)_order_price
17/25	Buy/Sell Order Quantity	…_ORDER_VOL (BIGINT)	…_ORDER_QUANTITY (DECIMAL(20,0))	B	Lệch kiểu số	(buy/sell)_order_quantity, kiểu dữ liệu là bigint


4. Quy ước đặt tên 2026-11-02 (physical_name giữ nguyên tên cột nguồn) mâu thuẫn với việc gộp: attribute gộp phải có tên chung. Áp dụng quy tắc B của SKILL (full word + từ điển viết tắt) cho các attribute gộp?
-> rule này tôi chỉ áp dụng cho 1 bảng cụ thể, không phải rule chung, nếu rule này thêm vào skill thì xoá đi cho tôi
5. Kiểu dữ liệu HNX là STRING cho số/ngày: domain đích là Date/Currency Amount/Small Counter, cần ghi conversion risk (ETL cast).
-> tôi đã trả lời bên trên
6. Cột lệch kiểu ngay trong HOSE (SESSION, CLIENT_HOUSE_CLASSIFICATION_CODE, INVEST_TYPE: STRING ở Order, BIGINT ở Trade): chọn 1 domain chung (đề xuất Text).
-> tôi đã trả lời bên trên
7. Mô tả trong `Securities Order/Trade` hiện còn dấu vết DDL cũ ("HNX dùng order_qty/sell_member_no", "Nguồn bigint", "decimal(18,4)", "buy/sell_scr_ordr_code") — sẽ viết lại toàn bộ khi thiết kế lại.
-> gen lại theo mô tả mới cho tôi

## 7. Đề xuất tên cho cột chỉ có ở 1 sàn (chờ duyệt)

Cùng phong cách tên đã chốt ở mục 6 (`_code`, `_tp_code`, `_nm`, `_nbr`, `_dt`, `_quantity`, `_price`). Cột có bộ mã → Classification Value (schema_code Data Modeler tự đánh sau).

### 7a. ORDER_BOOK

| Sàn | Cột nguồn | Tên Atomic đề xuất | Domain |
|---|---|---|---|
| HOSE | CURRENCY | currency_code | Text |
| HOSE | BRK | member_nm | Text |
| HOSE | PIN | pin_code | Text |
| HOSE | NAME | account_nm | Text |
| HOSE | MARKET_MAKER_ORDER | market_maker_order_ind | Indicator |
| HOSE | LTP | last_traded_price | Currency Amount |
| HOSE | EXECUTION_PRICE | execution_price | Currency Amount |
| HOSE | IMMED_MATCHED_VOL | immediate_matched_quantity | Small Counter |
| HOSE | MATCHED_VOL | matched_quantity | Small Counter |
| HOSE | ORDER_PRICE_LTP | order_price_ltp_difference | Currency Amount |
| HOSE | MATCHED_RATIO | matched_ratio | Percentage |
| HOSE | BUY_UP_SELL_DOWN_AMT | buy_up_sell_down_amount | Currency Amount |
| HOSE | BUY_UP_SELL_DOWN_TICK | buy_up_sell_down_tick | Small Counter |
| HOSE | NEW_HIGH_LOW_PRICE | new_high_low_price_tp_code | Classification Value |
| HOSE | ORDER_STATUS | order_status_code | Classification Value |
| HOSE | ICD_BUG_QTY | icd_bug_quantity | Small Counter |
| HOSE | EXPECTED_EXECUTION_PRICE | expected_execution_price | Currency Amount |
| HOSE | EXPECTED_EXECUTION_VOLUME | expected_execution_quantity | Small Counter |
| HOSE | SHORT_SELL_INDICATOR | short_sell_tp_code | Classification Value |
| HOSE | TRADER_NO | trader_nbr | Text |
| HOSE | TRADER_NAME | trader_nm | Text |
| HNX | ORDER_REJECT_REASON_CODE | order_reject_reason_code | Classification Value |
| HNX | PUBLIC_QUANTITY | public_quantity | Small Counter |
| HNX | CONDITION_PRICE | condition_price | Currency Amount |
| HNX | ORIGINAL_ORDER_TYPE_CODE | original_order_tp_code | Classification Value |
| HNX | AUTOMATED_CANCEL | automated_cancel_tp_code | Classification Value |
| HNX | QUOTE_REQUEST_TYPE | quote_request_tp_code | Classification Value |

### 7b. TRADE_BOOK

| Sàn | Cột nguồn | Tên Atomic đề xuất | Domain |
|---|---|---|---|
| HOSE | CURRENCY | currency_code | Classification Value |
| HOSE | EXECUTION_EXEC_PRICE_LTP | match_price_ltp_difference | Currency Amount |
| HOSE | EXECUTION_VALUE | match_amount | Currency Amount |
| HOSE | EXECUTION_LTP | last_traded_price | Currency Amount |
| HOSE | EXECUTION_NEW_HIGH_LOW_PRICE | new_high_low_price_tp_code | Classification Value |
| HOSE | (BUY/SELL)_ORDER_DATE | (buy/sell)_order_dt | Date |
| HOSE | (BUY/SELL)_ORDER_TIME | (buy/sell)_order_time | Text |
| HOSE | (BUY/SELL)_BRK | (buy/sell)_member_nm | Text |
| HOSE | (BUY/SELL)_PIN | (buy/sell)_pin_code | Text |
| HOSE | (BUY/SELL)_NAME | (buy/sell)_account_nm | Text |
| HOSE | (BUY/SELL)_TRADER_NO | (buy/sell)_trader_nbr | Text |
| HOSE | (BUY/SELL)_TRADER_NAME | (buy/sell)_trader_nm | Text |
| HOSE | (BUY/SELL)_REFERENCE_SEQUENCE_NO | (buy/sell)_sequence_nbr | Text |
| HNX | MESSAGE_SEQUENCE | sequence_nbr | Text (nguồn DECIMAL(20,0) → cast string) |
| HNX | (BUY/SELL)_REPLACE_CANCEL_CLASSIFICATION_CODE | (buy/sell)_order_action_tp_code | Classification Value |
| HNX | (BUY/SELL)_ORDER_TYPE_CODE | (buy/sell)_order_tp_code | Classification Value |
| HNX | (BUY/SELL)_ORDER_CONDITION_CODE | (buy/sell)_order_condition_tp_code | Classification Value |
| HNX | (BUY/SELL)_QUOTE_REQUEST_CODE | (buy/sell)_quote_request_tp_code | Classification Value |
| HNX | EXECUTION_PRICE_OF_SPREAD_FIRST | match_price_spread_first | Currency Amount (nguồn STRING → cast) |
| HNX | EXECUTION_PRICE_OF_SPREAD_SECOND | match_price_spread_second | Currency Amount (nguồn STRING → cast) |

Ghi nhận từ câu trả lời mục 6: BK giữ `securities_order_code` / `securities_trade_code` (không tạo thêm `order_code` / `trade_code`); gen lại mô tả theo BRD mới.
