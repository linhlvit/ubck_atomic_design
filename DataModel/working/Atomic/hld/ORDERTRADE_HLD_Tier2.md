# OrderTrade HLD — Tier 2

**Tier:** 2 — Phụ thuộc Tier 1 (FK về Securities Order)
**Source system:** OrderTrade
**Entities trong Tier này:** Securities Trade

---

## 6a. Danh sách entities

| Entity | BCV Core Object | BCV Concept | Table Type | Source Table(s) |
|---|---|---|---|---|
| Securities Trade | Transaction | [Transaction] Financial Market Transaction | Fact Append | OrderTrade.HOSE_TRADE_BOOK, OrderTrade.HNX_TRADE_BOOK |

---

## 6b. Mô tả chi tiết từng entity

### Securities Trade

**Mô tả:** Từng lần khớp lệnh thành công trên HOSE và HNX. Mỗi dòng = 1 Trade ID do KRX cấp. Lưu đồng thời thông tin execution, bên mua (Buy side) và bên bán (Sell side) trong cùng 1 row. Gộp HOSE_TRADE_BOOK + HNX_TRADE_BOOK, phân biệt qua `market_id_code` và `src_stm_code`.

**Grain:** 1 dòng = 1 lần khớp lệnh thành công (1 Trade ID từ KRX). 1 Securities Order có thể tạo ra nhiều Securities Trade (khớp dần).

**Ingestion:** Append theo ngày giao dịch (`trade_date = {etl_date}`).

**Outbound FK:**
- `buy_scr_ordr_code` → `Securities Order.scr_ordr_code` (FK-BK, không surrogate — join qua BK tại Gold)
- `buy_scr_ordr_id` → `Securities Order.scr_ordr_id` (FK surrogate — resolve nếu có thể trong ETL window ngày)
- `sell_scr_ordr_code` → `Securities Order.scr_ordr_code` (FK-BK)
- `sell_scr_ordr_id` → `Securities Order.scr_ordr_id` (FK surrogate)

**Inbound FK:** Không có entity nào FK vào Securities Trade trong scope OrderTrade.

---

## 6c. Gap phân tích HOSE_TRADE_BOOK vs HNX_TRADE_BOOK

| Nhóm field | HOSE_TRADE_BOOK | HNX_TRADE_BOOK | Xử lý trên entity gộp |
|---|---|---|---|
| **Field chung** | | | |
| Trade Date, Trade Time | ✓ | ✓ | Dùng chung |
| Market ID, Symbol, Currency, Board Type, Session | ✓ | ✓ | Dùng chung |
| Exec Price, Exec Volume | ✓ | ✓ | Dùng chung |
| Exec LTP, Exec Price vs LTP | ✓ | Exec Price - LTP | Dùng chung → exec_ltp, exec_prc_vs_ltp |
| Exec New High/Low Price | ✓ | ✓ | Dùng chung |
| Buy/Sell: Member Code, Account Number, Investor Type, Foreign Investor Type, Client/House, Order Price, Order Volume, Order Type, Order Condition | ✓ | ✓ | Dùng chung |
| **FK về Securities Order** | | | |
| Buy Order Accept # | Buy - Order Accept # | Buy Order Reception Number | Unify → buy_scr_ordr_code (via BK) + buy_ordr_acpt_nbr |
| Sell Order Accept # | Sell - Order Accept # | Sell Order Reception Number | Unify → sell_scr_ordr_code (via BK) + sell_ordr_acpt_nbr |
| **Field HOSE-only** | | | |
| Exec Value (giá trị giao dịch) | ✓ | nullable | nullable trên HNX |
| Buy/Sell: Order Date, Order Time | ✓ | nullable | nullable trên HNX |
| Buy/Sell: Member Name | ✓ | nullable | nullable trên HNX |
| Buy/Sell: Account Holder Name, Account Pin | ✓ | nullable | nullable trên HNX |
| Buy/Sell: Trader Code, Trader Name | ✓ | nullable | nullable trên HNX |
| Buy/Sell: Reference Sequence Number | ✓ | ✓ | có cả 2 sàn |
| Buy/Sell: Order Action Type | nullable (HOSE) | Buy/Sell Replace/cancel | ETL unify → buy/sell_ordr_actn_tp_code |
| Buy/Sell: Quote Request Type | nullable (HOSE) | Buy/Sell Quote Request Code | HNX-only — nullable trên HOSE |
| **Field HNX-only** | | | |
| Exec Price Spread First/Second | nullable (HOSE) | ✓ | HNX Spread legs — nullable trên HOSE |

---

## 6d. Attributes tổng hợp — Securities Trade

### Execution fields (chung cả 2 sàn)

| # | Logical Name | Physical Name | Domain | Nullable | Source HOSE | Source HNX | Ghi chú |
|---|---|---|---|---|---|---|---|
| 1 | Securities Trade Id | scr_trd_id | Surrogate Key | N | — | — | PK surrogate |
| 2 | Securities Trade Code | scr_trd_code | Text | N | Trade # | Trade number | BK. Unique trong (Trade Date + Symbol). ETL: Number → string |
| 3 | Source System Code | src_stm_code | Classification Value | N | hardcode | hardcode | Scheme: SOURCE_SYSTEM |
| 4 | Trade Date | trd_dt | Date | N | Trade Date | Trade date | Nguồn Character(8) |
| 5 | Trade Time | trd_tm | Text | N | Time | Trade time | Lưu Text — không có ngày kèm |
| 6 | Market Id Code | mkt_id_code | Classification Value | N | Market ID | Market ID | Scheme: ORDERTRADE_MARKET_ID |
| 7 | Symbol Code | symb_code | Text | N | Symbol | Issue Code | Denormalized |
| 8 | Currency Code | ccy_code | Classification Value | N | Currency | — | FK target: Currency |
| 9 | Board Type Code | board_tp_code | Classification Value | N | Board Type | Board ID | Scheme: ORDERTRADE_BOARD_TYPE |
| 10 | Session Code | ssn_code | Classification Value | N | Session | Session ID | Scheme: ORDERTRADE_SESSION |
| 11 | Exec Price | exec_prc | Currency Amount | N | Execution - Exec Price | Trade price | Giá khớp xác nhận |
| 12 | Exec Volume | exec_vol | Small Counter | N | Execution - Volume | Trade quantity | Khối lượng khớp |
| 13 | Exec Value | exec_val | Currency Amount | Y | Execution - Value | nullable (HNX) | Giá trị giao dịch — HOSE-only tường minh |
| 14 | Exec Ltp | exec_ltp | Currency Amount | Y | Execution - LTP | nullable (HNX) | LTP tại thời điểm khớp |
| 15 | Exec Price Vs Ltp | exec_prc_vs_ltp | Currency Amount | Y | Execution - Exec Price - LTP | nullable (HNX) | Chênh lệch exec vs LTP |
| 16 | Exec New High Low Price Indicator | exec_new_high_low_prc_ind | Indicator | Y | Execution - New High/Low Price | Execution - New High/Low Price | Giá cao/thấp mới |
| 17 | Exec Price Spread First | exec_prc_sprd_frst | Currency Amount | Y | nullable (HOSE) | Execution Price of Spread First | HNX Spread leg 1 |
| 18 | Exec Price Spread Second | exec_prc_sprd_scd | Currency Amount | Y | nullable (HOSE) | Execution Price of Spread Second | HNX Spread leg 2 |
| 19 | Reference Sequence Number | refr_seq_nbr | Text | Y | nullable (HOSE) | Message Sequence | Metadata luồng dữ liệu |

### Buy side fields

| # | Logical Name | Physical Name | Domain | Nullable | Source HOSE | Source HNX | Ghi chú |
|---|---|---|---|---|---|---|---|
| 20 | Buy Securities Order Id | buy_scr_ordr_id | Surrogate Key | Y | (resolve từ BK) | (resolve từ BK) | FK surrogate → Securities Order |
| 21 | Buy Securities Order Code | buy_scr_ordr_code | Text | Y | Buy - Order Accept # | Buy Order Reception Number | FK-BK → Securities Order. Join qua (trd_dt + symb_code + buy_scr_ordr_code) |
| 22 | Buy Order Date | buy_ordr_dt | Date | Y | Buy - Order Date | nullable (HNX) | HOSE-only tường minh |
| 23 | Buy Order Time | buy_ordr_tm | Text | Y | Buy - Order Time | nullable (HNX) | HOSE-only tường minh |
| 24 | Buy Member Code | buy_mbr_code | Text | N | Buy - BRK # | Buy member number | Mã CTCK bên mua — denormalized |
| 25 | Buy Member Name | buy_mbr_nm | Text | Y | Buy - BRK | nullable (HNX) | HOSE-only tường minh |
| 26 | Buy Account Number | buy_ac_nbr | Text | N | Buy - Acct No | Buy account number | TK mua — denormalized |
| 27 | Buy Account Holder Name | buy_ac_hldr_nm | Text | Y | Buy - Name | nullable (HNX) | HOSE-only tường minh |
| 28 | Buy Account Pin Code | buy_ac_pin_code | Text | Y | Buy - PIN | nullable (HNX) | HOSE-only; cần masking |
| 29 | Buy Client House Type Code | buy_clnt_hs_tp_code | Classification Value | N | Buy - Client/House Classification Code | Buy client/house classification | Scheme: ORDERTRADE_CLIENT_HOUSE_TYPE |
| 30 | Buy Investor Type Code | buy_ivsr_tp_code | Classification Value | Y | Buy - Invest Type | Buy investor classification code | Scheme: ORDERTRADE_INVESTOR_TYPE |
| 31 | Buy Foreign Investor Type Code | buy_frgn_ivsr_tp_code | Classification Value | Y | Buy - Foreigner Investor type | Buy Foreign Investor Type Code | Scheme: ORDERTRADE_FOREIGN_INVESTOR_TYPE |
| 32 | Buy Order Price | buy_ordr_prc | Currency Amount | Y | Buy - Order Price | Buy order price | Giá đặt mua |
| 33 | Buy Order Volume | buy_ordr_vol | Small Counter | Y | Buy - Order VOL | Buy order quantity | KL đặt mua |
| 34 | Buy Trader Code | buy_trdr_code | Text | Y | Buy - Trader No | nullable (HNX) | HOSE-only tường minh |
| 35 | Buy Trader Name | buy_trdr_nm | Text | Y | Buy - Trader Name | nullable (HNX) | HOSE-only tường minh |
| 36 | Buy Reference Sequence Number | buy_refr_seq_nbr | Text | Y | Buy - Reference Sequence No. | Buy Order Reception Number | Metadata luồng |
| 37 | Buy Order Type Code | buy_ordr_tp_code | Classification Value | Y | nullable (HOSE) | Buy order type code | Scheme: ORDERTRADE_ORDER_TYPE |
| 38 | Buy Order Condition Code | buy_ordr_cd_code | Classification Value | Y | nullable (HOSE) | Buy order condition code | Scheme: ORDERTRADE_ORDER_CONDITION |
| 39 | Buy Order Action Type Code | buy_ordr_actn_tp_code | Classification Value | Y | nullable (HOSE) | Buy Replace/cancel classification code | HNX-only tường minh. Scheme: ORDERTRADE_ORDER_ACTION_TYPE |
| 40 | Buy Quote Request Type Code | buy_qte_rqs_tp_code | Classification Value | Y | nullable (HOSE) | Buy Quote Request Code | HNX RFQ. Scheme: ORDERTRADE_QUOTE_REQUEST_TYPE |

### Sell side fields

| # | Logical Name | Physical Name | Domain | Nullable | Source HOSE | Source HNX | Ghi chú |
|---|---|---|---|---|---|---|---|
| 41 | Sell Securities Order Id | sell_scr_ordr_id | Surrogate Key | Y | (resolve từ BK) | (resolve từ BK) | FK surrogate → Securities Order |
| 42 | Sell Securities Order Code | sell_scr_ordr_code | Text | Y | Sell - Order Accept # | Sell Order Reception Number | FK-BK → Securities Order |
| 43 | Sell Order Date | sell_ordr_dt | Date | Y | Sell - Order Date | nullable (HNX) | HOSE-only |
| 44 | Sell Order Time | sell_ordr_tm | Text | Y | Sell - Order Time | nullable (HNX) | HOSE-only |
| 45 | Sell Member Code | sell_mbr_code | Text | N | Sell - BRK # | Sell member number | Mã CTCK bên bán — denormalized |
| 46 | Sell Member Name | sell_mbr_nm | Text | Y | Sell - BRK | nullable (HNX) | HOSE-only |
| 47 | Sell Account Number | sell_ac_nbr | Text | N | Sell - Acct No | Sell account number | TK bán — denormalized |
| 48 | Sell Account Holder Name | sell_ac_hldr_nm | Text | Y | Sell - Name | nullable (HNX) | HOSE-only |
| 49 | Sell Account Pin Code | sell_ac_pin_code | Text | Y | Sell - PIN | nullable (HNX) | HOSE-only; cần masking |
| 50 | Sell Client House Type Code | sell_clnt_hs_tp_code | Classification Value | N | Sell - Client/House Classification Code | Sell client/house classification | Scheme: ORDERTRADE_CLIENT_HOUSE_TYPE |
| 51 | Sell Investor Type Code | sell_ivsr_tp_code | Classification Value | Y | Sell - Invest Type | Sell investor classification code | Scheme: ORDERTRADE_INVESTOR_TYPE |
| 52 | Sell Foreign Investor Type Code | sell_frgn_ivsr_tp_code | Classification Value | Y | Sell - Foreigner Investor type | Sell Foreign Investor Type Code | Scheme: ORDERTRADE_FOREIGN_INVESTOR_TYPE |
| 53 | Sell Order Price | sell_ordr_prc | Currency Amount | Y | Sell - Order Price | Sell order price | Giá đặt bán |
| 54 | Sell Order Volume | sell_ordr_vol | Small Counter | Y | Sell - Order VOL | Sell order quantity | KL đặt bán |
| 55 | Sell Trader Code | sell_trdr_code | Text | Y | Sell - Trader No | nullable (HNX) | HOSE-only |
| 56 | Sell Trader Name | sell_trdr_nm | Text | Y | Sell - Trader Name | nullable (HNX) | HOSE-only |
| 57 | Sell Reference Sequence Number | sell_refr_seq_nbr | Text | Y | Sell - Reference Sequence No. | Sell Order Reception Number | Metadata luồng |
| 58 | Sell Order Type Code | sell_ordr_tp_code | Classification Value | Y | nullable (HOSE) | Sell order type code | Scheme: ORDERTRADE_ORDER_TYPE |
| 59 | Sell Order Condition Code | sell_ordr_cd_code | Classification Value | Y | nullable (HOSE) | Sell order condition code | Scheme: ORDERTRADE_ORDER_CONDITION |
| 60 | Sell Order Action Type Code | sell_ordr_actn_tp_code | Classification Value | Y | nullable (HOSE) | Sell Replace/cancel classification code | HNX-only. Scheme: ORDERTRADE_ORDER_ACTION_TYPE |
| 61 | Sell Quote Request Type Code | sell_qte_rqs_tp_code | Classification Value | Y | nullable (HOSE) | Sell Quote Request Code | HNX RFQ. Scheme: ORDERTRADE_QUOTE_REQUEST_TYPE |

**Tổng: 61 attributes**

---

## 6e. Điểm cần xác nhận (Tier 2)

| # | Câu hỏi | Ảnh hưởng |
|---|---|---|
| T2-01 | `Buy/Sell Securities Order Id` (surrogate FK): ETL có thể resolve trong cùng batch ngày không (lookup Securities Order đã load cùng ngày)? Nếu không → để nullable và chỉ dùng FK-BK | ETL pipeline design — surrogate FK resolve phụ thuộc ordering trong pipeline |
| T2-02 | `Exec Value` (giá trị giao dịch): HNX không có tường minh — ETL có thể tính `exec_prc × exec_vol` cho HNX không? | Nếu tính được → cập nhật nullable=N; nếu không → giữ nullable=Y |
| T2-03 | `Buy/Sell Account Pin Code`: scope masking tương tự T1-03 | Data governance |
| T2-04 | `Buy/Sell Reference Sequence Number` trên HNX: source là `Buy/Sell Order Reception Number` — có ổn không hay cần field riêng? | Ngữ nghĩa khác nhau: HOSE là số thứ tự message; HNX field này chứa Order Reception Number. Cần xác nhận reuse có đúng ý nghĩa không |

---

## 6f. Bảng ngoài scope (Tier 2)

*(Không có bảng ngoài scope tại Tier 2)*
