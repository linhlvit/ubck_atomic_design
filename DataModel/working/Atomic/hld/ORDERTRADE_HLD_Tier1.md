# ORDERTRADE HLD — Tier 1

**Tier:** 1 — Independent Entities (không FK đến entity nghiệp vụ khác trong scope ORDERTRADE)
**Source system:** ORDERTRADE
**Entities trong Tier này:** Securities Order

---

## 6a. Danh sách entities

| Entity | BCV Core Object | BCV Concept | Table Type | Source Table(s) |
|---|---|---|---|---|
| Securities Order | Communication | [Communication] Financial Market Order | Fact Append | ORDERTRADE.ORDER_BOOK_HOSE, ORDERTRADE.ORDER_BOOK_HNX |

---

## 6b. Mô tả chi tiết từng entity

### Securities Order

**Mô tả:** Toàn bộ lifecycle của từng lệnh giao dịch chứng khoán trên HOSE và HNX. Mỗi dòng = 1 event lệnh (new/modify/cancel). Gộp ORDER_BOOK_HOSE + ORDER_BOOK_HNX, phân biệt qua `market_id_code` và `src_stm_code`.

**Grain:** 1 dòng = 1 event lệnh — mỗi lần đặt mới, sửa, hoặc hủy lệnh tạo ra 1 bản ghi mới (Fact Append, insert-only).

**Ingestion:** Append theo ngày giao dịch (`order_date = {etl_date}`).

**Outbound FK:** Không có FK đến entity nghiệp vụ trong scope → Tier 1.

**Inbound FK:** `Securities Trade.buy_scr_ordr_code` và `Securities Trade.sell_scr_ordr_code` → trỏ về entity này (xem Tier 2).

**Self-reference:** `orig_scr_ordr_code` và `orig_ordr_acpt_nbr` → tham chiếu lệnh gốc trước khi sửa/hủy (không tạo FK surrogate — resolve trong cùng batch ngày+Symbol).

---

## 6c. Gap phân tích HOSE vs HNX

| Nhóm field | HOSE | HNX | Xử lý trên entity gộp |
|---|---|---|---|
| **Field chung — có cả 2 sàn** | | | |
| Trade Date, Order Date, Order Time | ✓ | ✓ | Dùng chung |
| Market ID, Symbol, Currency, Board Type, Session | ✓ | ✓ | Dùng chung; Session code giống nhau |
| Side (B/S) | S/B | 1=Sell / 2=Buy | ETL chuẩn hóa HNX → B/S (Indicator domain) |
| Order Type | 1/2/3/4 | 1/2/3/4/X/Y | HNX có thêm X, Y → scheme chung `ORDERTRADE_ORDER_TYPE` |
| Order Condition | 0/1/2/3/4/6/7/9 | 0/1/2/3/4/6/7/9 | Giống nhau |
| Order Action (Modify/Cancel) | N/M/C | 1=New / 2=Replace / 3=Cancel | ETL chuẩn hóa → N/M/C scheme chung |
| Client/House, Investor Type, Foreign Investor Type | ✓ | ✓ | Dùng chung scheme; Investor Type giữ raw, phân biệt qua src_stm_code |
| Market Maker Order, Short Sell | ✓ | nullable | HNX không có tường minh → nullable |
| Order Price, Order Volume | ✓ | ✓ | Dùng chung |
| Member Code/Name, Account Number, Account Pin, Account Holder Name | BRK #, BRK, Acct No, PIN, Name | Member ID, Account Number | Unify → mbr_code, mbr_nm, ac_nbr, ac_pin_code, ac_hldr_nm |
| Trader Code/Name | Trader No, Trader Name | không có tường minh | nullable trên HNX |
| Order Accept # (BK phụ) | Order Accept # | Order Reception Number | Unify → ordr_acpt_nbr |
| Order ID (BK chính) | Order ID | order ID | Unify → scr_ordr_code |
| Orig Order ID, Orig Order Accept # | ✓ | ✓ | Unify → orig_scr_ordr_code, orig_ordr_acpt_nbr |
| Reference Sequence | Reference Sequence No. | Message Sequence | Unify → refr_seq_nbr |
| **Field HOSE-only** | | | |
| Order Status | 0–8 tường minh | không có | nullable trên HNX; ETL có thể derive |
| Execution Price | ✓ | nullable | nullable trên HNX |
| Last Traded Price, Order Price vs LTP | ✓ | nullable | nullable trên HNX |
| Buy Up/Sell Down Amount, Tick | ✓ | nullable | nullable trên HNX |
| Matched Ratio | ✓ | nullable | nullable trên HNX |
| New High/Low Price | ✓ | nullable | nullable trên HNX |
| Expected Execution Price/Volume | ✓ | nullable | nullable trên HNX |
| Icd-Bug Quantity | ✓ | nullable | nullable trên HNX |
| Matched Volume, Immediate Matched Volume, Remaining Volume | ✓ | Remaining tường minh; Matched không rõ | HNX: matched_vol = nullable; rman_vol = tường minh |
| **Field HNX-only** | | | |
| Public Volume (Iceberg) | nullable | ✓ | nullable trên HOSE |
| Condition Price (Stop order) | nullable | ✓ | nullable trên HOSE |
| Original Order Type Code | nullable | ✓ | nullable trên HOSE |
| Order Reject Reason Code | nullable | ✓ | nullable trên HOSE |
| Quote Request Type (RFQ) | nullable | ✓ | nullable trên HOSE |
| Automated Cancel Processing | nullable | ✓ | nullable trên HOSE |

---

## 6d. Attributes tổng hợp — Securities Order

| # | Logical Name | Physical Name | Domain | Nullable | PK/BK | Source HOSE | Source HNX | Ghi chú |
|---|---|---|---|---|---|---|---|---|
| 1 | Securities Order Id | scr_ordr_id | Surrogate Key | N | PK | — | — | Surrogate |
| 2 | Securities Order Code | scr_ordr_code | Text | N | BK | Order ID | order ID | BK chính — Order ID 17 ký tự, unique trong toàn bộ luồng KRX |
| 3 | Order Accept Number | ordr_acpt_nbr | Text | N | BK phụ | Order Accept # | Order Reception Number | Unique trong (Trade Date + Symbol). Dùng để join về Trade |
| 4 | Source System Code | src_stm_code | Classification Value | N | — | hardcode | hardcode | Scheme: SOURCE_SYSTEM |
| 5 | Trade Date | trd_dt | Date | N | — | Trade Date | Trade date | Nguồn Character(8) yyyymmdd |
| 6 | Order Date | ordr_dt | Date | Y | — | Order Date | Order Date | Ngày đặt lệnh |
| 7 | Order Time | ordr_tm | Text | Y | — | Order Time | order accept time | HNX có độ phân giải cao hơn (hh24misss 9 ký tự vs hh24miss 6 ký tự) |
| 8 | Market Id Code | mkt_id_code | Classification Value | N | — | Market ID | Market ID | Scheme: ORDERTRADE_MARKET_ID |
| 9 | Symbol Code | symb_code | Text | N | — | Symbol | Issue Code | FK suy luận đến Instrument ngoài scope |
| 10 | Currency Code | ccy_code | Classification Value | N | — | Currency | — | FK target: Currency |
| 11 | Board Type Code | board_tp_code | Classification Value | N | — | Board Type | Board ID | Scheme: ORDERTRADE_BOARD_TYPE |
| 12 | Session Code | ssn_code | Classification Value | N | — | Session | Session ID | Scheme: ORDERTRADE_SESSION |
| 13 | Order Action Type Code | ordr_actn_tp_code | Classification Value | N | — | Modify/Cancel (N/M/C) | Replace/cancel (1/2/3) | ETL chuẩn hóa → N/M/C. Scheme: ORDERTRADE_ORDER_ACTION_TYPE |
| 14 | Side Code | side_code | Indicator | N | — | Side (S/B) | Sell/Buy Classification (1/2) | ETL chuẩn hóa HNX → B/S |
| 15 | Order Type Code | ordr_tp_code | Classification Value | N | — | Order Type | Order Type Code | Scheme: ORDERTRADE_ORDER_TYPE |
| 16 | Order Condition Code | ordr_cd_code | Classification Value | Y | — | Order Condition | Order Condition Code | Scheme: ORDERTRADE_ORDER_CONDITION |
| 17 | Order Status Code | ordr_st_code | Classification Value | Y | — | Order Status | (derive) | Tường minh HOSE; HNX cần ETL derive. Scheme: ORDERTRADE_ORDER_STATUS |
| 18 | Client House Type Code | clnt_hs_tp_code | Classification Value | N | — | Client/House Classification Code | Client/House Classification Code | Scheme: ORDERTRADE_CLIENT_HOUSE_TYPE |
| 19 | Investor Type Code | ivsr_tp_code | Classification Value | Y | — | Invest Type | Investor Classification Code | Scheme: ORDERTRADE_INVESTOR_TYPE. Raw từng sàn, phân biệt qua src_stm_code |
| 20 | Foreign Investor Type Code | frgn_ivsr_tp_code | Classification Value | Y | — | Foreigner Investor type | Foreign Investor Type Code | Scheme: ORDERTRADE_FOREIGN_INVESTOR_TYPE |
| 21 | Short Sell Type Code | shrt_sell_tp_code | Classification Value | Y | — | Short Sell Indicator | nullable (HNX) | HOSE-only; nullable trên HNX. Scheme: ORDERTRADE_SHORT_SELL_TYPE |
| 22 | Market Maker Order Indicator | mkt_maker_ordr_ind | Indicator | Y | — | Market Maker Order (Y/N) | nullable (HNX) | HOSE-only; nullable trên HNX |
| 23 | Order Price | ordr_prc | Currency Amount | Y | — | Order Price | Order Price | 0 nếu Market order — ETL có thể chuẩn hóa 0 → NULL |
| 24 | Order Volume | ordr_vol | Small Counter | N | — | Order VOL | Order Quantity | Khối lượng đặt |
| 25 | Matched Volume | matched_vol | Small Counter | Y | — | Matched VOL | nullable (HNX) | Tích lũy đến thời điểm event; HOSE-only tường minh |
| 26 | Immediate Matched Volume | imm_matched_vol | Small Counter | Y | — | Immed. Matched VOL | nullable (HNX) | Khớp ngay tại event; HOSE-only |
| 27 | Remaining Volume | rman_vol | Small Counter | Y | — | Order Rqty | Order Remaining Quantity | Còn lại chưa khớp; có cả 2 sàn |
| 28 | Execution Price | exec_prc | Currency Amount | Y | — | Execution Price | nullable (HNX) | Snapshot giá khớp tại event lệnh — HOSE-only |
| 29 | Last Traded Price | last_trdd_prc | Currency Amount | Y | — | LTP | nullable (HNX) | Giá khớp gần nhất thị trường — HOSE-only |
| 30 | Order Price Vs Ltp | ordr_prc_vs_ltp | Currency Amount | Y | — | Order Price-LTP | nullable (HNX) | Chênh lệch giá đặt vs LTP — HOSE-only |
| 31 | Buy Up Sell Down Amount | buy_up_sell_down_amt | Currency Amount | Y | — | Buy Up/Sell Down Amt | nullable (HNX) | Mức tăng/giảm giá vs tham chiếu — HOSE-only |
| 32 | Buy Up Sell Down Tick | buy_up_sell_down_tick | Small Counter | Y | — | Buy Up/Sell Down Tick | nullable (HNX) | Bước giá — HOSE-only |
| 33 | Matched Ratio | matched_rto | Percentage | Y | — | Matched Ratio | nullable (HNX) | ETL verify đơn vị 0–1 hay 0–100 — HOSE-only |
| 34 | New High Low Price Indicator | new_high_low_prc_ind | Indicator | Y | — | New High/Low Price | nullable (HNX) | Giá cao/thấp mới trong ngày — HOSE-only |
| 35 | Expected Execution Price | expc_exec_prc | Currency Amount | Y | — | Expected execution price | nullable (HNX) | Giá khớp dự kiến — HOSE-only |
| 36 | Expected Execution Volume | expc_exec_vol | Small Counter | Y | — | Expected execution volume | nullable (HNX) | KL khớp dự kiến — HOSE-only |
| 37 | Icd Bug Quantity | icd_bug_qty | Small Counter | Y | — | Icd-Bug Qty | nullable (HNX) | KL điều chỉnh lỗi KRX — HOSE-only |
| 38 | Member Code | mbr_code | Text | N | — | BRK # | Member ID | CTCK/Thành viên giao dịch. Denormalized — không FK |
| 39 | Member Name | mbr_nm | Text | Y | — | BRK | nullable (HNX) | Tên CTCK — denormalized snapshot |
| 40 | Account Number | ac_nbr | Text | N | — | Acct No | Account Number | Số tài khoản NĐT — denormalized |
| 41 | Account Holder Name | ac_hldr_nm | Text | Y | — | Name | nullable (HNX) | Tên NĐT — denormalized snapshot |
| 42 | Account Pin Code | ac_pin_code | Text | Y | — | PIN | nullable (HNX) | Mã PIN tài khoản — cần masking |
| 43 | Trader Code | trdr_code | Text | Y | — | Trader No | nullable (HNX) | Mã trader — HOSE-only tường minh |
| 44 | Trader Name | trdr_nm | Text | Y | — | Trader Name | nullable (HNX) | Tên trader — HOSE-only tường minh |
| 45 | Orig Securities Order Code | orig_scr_ordr_code | Text | Y | — | Orig Order ID | Original order ID | Self-ref lệnh gốc trước sửa/hủy |
| 46 | Orig Order Accept Number | orig_ordr_acpt_nbr | Text | Y | — | Orig Order Accept # | Original Order Reception Number | BK phụ lệnh gốc |
| 47 | Reference Sequence Number | refr_seq_nbr | Text | Y | — | Reference Sequence No. | Message Sequence | Metadata luồng dữ liệu — audit/trace |
| 48 | Order Reject Reason Code | ordr_rjct_rsn_code | Text | Y | — | nullable (HOSE) | Order Reject Reason Code | HNX-only. Text vì chưa profile bộ giá trị đầy đủ |
| 49 | Public Volume | pblc_vol | Small Counter | Y | — | nullable (HOSE) | Public quantity | HNX Iceberg — phần KL công khai |
| 50 | Condition Price | cond_prc | Currency Amount | Y | — | nullable (HOSE) | Condition price | HNX Stop order — giá kích hoạt |
| 51 | Orig Order Type Code | orig_ordr_tp_code | Classification Value | Y | — | nullable (HOSE) | Original Order Type Code | HNX — loại lệnh gốc trước sửa. Scheme: ORDERTRADE_ORDER_TYPE |
| 52 | Quote Request Type Code | qte_rqs_tp_code | Classification Value | Y | — | nullable (HOSE) | Quote Request Type | HNX RFQ flow. Scheme: ORDERTRADE_QUOTE_REQUEST_TYPE |
| 53 | Auto Cancel Reason Code | auto_cncl_rsn_code | Classification Value | Y | — | nullable (HOSE) | Automated Cancel Processing Classification | HNX auto cancel. Scheme: ORDERTRADE_AUTO_CANCEL_REASON |

**Tổng: 53 attributes**

---

## 6e. Điểm cần xác nhận (Tier 1)

| # | Câu hỏi | Ảnh hưởng |
|---|---|---|
| T1-01 | `Order Status Code` HNX: xác nhận ETL derive từ `Order Action Type + Remaining Volume` hay để nullable? | ETL logic HNX side |
| T1-02 | `Investor Type Code` HOSE vs HNX: profile thực tế có conflict không? (HOSE 1000=Individual; HNX 1000=Securities company per spec) | Nếu conflict → cần normalize; hiện tại giữ raw + src_stm_code |
| T1-03 | `Account Pin Code`: masking tại ETL pipeline hay để raw Atomic và control ở lớp truy cập? | Data governance |
| T1-04 | HOSE-only market snapshot fields (exec_prc, last_trdd_prc, ordr_prc_vs_ltp, buy_up_sell_down_*): xác nhận giữ tất cả trên entity gộp (nullable HNX)? | Nếu bỏ → đơn giản hơn nhưng mất dữ liệu phân tích HOSE |
| T1-05 | Các trường derived HOSE (`matched_rto`, `ordr_prc_vs_ltp`, `buy_up_sell_down_*`): giữ nguyên từ nguồn hay bỏ (có thể tính lại từ các trường gốc)? | Trade-off: giữ = đủ dữ liệu; bỏ = schema gọn hơn |

---

## 6f. Bảng ngoài scope (Tier 1)

*(Không có bảng ngoài scope tại Tier 1 — tất cả 4 bảng nguồn đều in_scope theo BRD)*
