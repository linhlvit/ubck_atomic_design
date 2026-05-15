# CƠ SỞ DỮ LIỆU (OLTP)


## OrderTrade — 

### Các mô hình quan hệ dữ liệu

![Mô hình quan hệ dữ liệu OrderTrade](OrderTrade/fragments/OrderTrade_diagram.png)

**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | scr_ordr | Sự kiện trong vòng đời lệnh giao dịch chứng khoán trên sàn HOSE và HNX — lệnh mới/sửa/hủy từ hệ thống KRX. Mỗi dòng = 1 event. Gộp 2 sàn phân biệt bằng market_id. |
| 2 | scr_trd | Giao dịch khớp lệnh chứng khoán thực tế trên sàn HOSE và HNX — ghi nhận giá khớp/khối lượng/giá trị và thông tin bên mua/bán. Mỗi dòng = 1 lần khớp. FK đến Securities Order (x2). |




### Bảng scr_ordr



#### Từ OrderTrade.Order_HOSE

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_ordr_id | STRING |  | X | P |  | Khóa đại diện cho sự kiện lệnh giao dịch chứng khoán. |
| 2 | scr_ordr_code | STRING |  |  |  |  | Mã định danh logic của lệnh (17 ký tự). BK chính. |
| 3 | ordr_acpt_nbr | STRING |  |  |  |  | Số thứ tự lệnh do KRX cấp trong ngày theo từng mã chứng khoán. Reset mỗi ngày mới. |
| 4 | src_stm_code | STRING |  |  |  | 'OrderTrade.Order_HOSE' | Mã hệ thống nguồn. |
| 5 | trd_dt | DATE |  |  |  |  | Ngày giao dịch theo thị trường chứng khoán (yyyymmdd). |
| 6 | ordr_dt | DATE | X |  |  |  | Ngày đặt lệnh của người thực hiện giao dịch (yyyymmdd). |
| 7 | ordr_tm | STRING | X |  |  |  | Thời gian đặt lệnh (hh24miss). |
| 8 | mkt_id_code | STRING |  |  |  |  | Mã thị trường: STO/BDO/RPO (HOSE). |
| 9 | symb_code | STRING |  |  | F |  | Mã chứng khoán (ISIN hoặc mã sàn). |
| 10 | ccy_code | STRING |  |  | F |  | Đơn vị tiền tệ (VND). |
| 11 | board_tp_code | STRING |  |  |  |  | Loại bảng giao dịch: G1 Main / G2 ATO / G3 ATC / G4 Odd lot / G7 Buy-in / G8 Sell-out / T1-T6 Thỏa thuận / R1 Repo. |
| 12 | ssn_code | STRING |  |  |  |  | Phiên giao dịch: 00 Pre-market / 10 ATO / 20/40 Continuous / 30 ATC / 80 Odd lot / 90 Halt / 99 Close. |
| 13 | ordr_actn_tp_code | STRING |  |  |  |  | Loại action lệnh: N=Lệnh mới / M=Sửa / C=Hủy. |
| 14 | side_code | STRING |  |  |  |  | Chiều lệnh: B=Buy (Mua) / S=Sell (Bán). |
| 15 | ordr_tp_code | STRING |  |  |  |  | Loại lệnh theo giá: 1=Market / 2=Limit / 3=Stop Market / 4=Stop Limit. |
| 16 | ordr_cd_code | STRING | X |  |  |  | Điều kiện khớp lệnh: 0=FAS / 1=GTC / 2=ATO / 3=FAK / 4=FOK / 6=GTD / 7=ATC / 9=MTL. |
| 17 | ordr_st_code | STRING | X |  |  |  | Trạng thái lệnh: 0=New / 1=Partial Fill / 2=Filled / 3=Cancelled / 4=Rejected / 5=Expired / 6=Pending Cancel / 7=Pending Replace / 8=Replaced. |
| 18 | clnt_hs_tp_code | STRING |  |  |  |  | Phân loại giao dịch: 10=Client trade (khách hàng) / 30=House trade (tự doanh CTCK). |
| 19 | ivsr_tp_code | STRING | X |  |  |  | Phân loại nhà đầu tư: 8000=Cá nhân / 7000=NĐT nước ngoài / 3000=Quỹ / 4000=Ngân hàng / 5000=CTCK. |
| 20 | frgn_ivsr_tp_code | STRING | X |  |  |  | Phân loại nhà đầu tư nước ngoài: 00=Trong nước / 10=NN cư trú / 20=NN không cư trú. |
| 21 | shrt_sell_tp_code | STRING | X |  |  |  | Phân loại bán khống: 00=Bình thường / 10=Lệnh bán khống. |
| 22 | mkt_maker_ordr_ind | STRING | X |  |  |  | Cờ lệnh nhà tạo lập thị trường: Y=Có / N=Không. |
| 23 | ordr_prc | DECIMAL(23,2) | X |  |  |  | Giá đặt lệnh. 0 nếu Market order hoặc lệnh hủy. |
| 24 | ordr_vol | INT |  |  |  |  | Khối lượng đặt lệnh. |
| 25 | matched_vol | INT | X |  |  |  | Tổng khối lượng đã khớp của lệnh (tích lũy đến thời điểm event này). |
| 26 | rman_vol | INT | X |  |  |  | Khối lượng còn lại chưa khớp. Bằng Order VOL − Matched VOL − Cancelled VOL. |
| 27 | imm_matched_vol | INT | X |  |  |  | Khối lượng khớp ngay tại thời điểm hệ thống ghi nhận lệnh. |
| 28 | exec_prc | DECIMAL(23,2) | X |  |  |  | Giá khớp lệnh thực tế snapshot tại thời điểm event lệnh. |
| 29 | last_trdd_prc | DECIMAL(23,2) | X |  |  |  | Last Traded Price — giá khớp gần nhất trên thị trường tại thời điểm đặt lệnh. |
| 30 | ordr_prc_vs_ltp | DECIMAL(23,2) | X |  |  |  | Chênh lệch giữa giá đặt và LTP tại thời điểm đặt lệnh (Order Price − LTP). |
| 31 | buy_up_sell_down_amt | DECIMAL(23,2) | X |  |  |  | Mức tăng/giảm giá so với giá tham chiếu theo giá trị tiền. |
| 32 | buy_up_sell_down_tick | INT | X |  |  |  | Mức tăng/giảm theo số bước giá (tick). |
| 33 | matched_rto | DECIMAL(5,2) | X |  |  |  | Tỷ lệ khớp lệnh = Matched VOL / Order VOL. |
| 34 | new_high_low_prc_ind | STRING | X |  |  |  | Đánh dấu nếu lệnh tạo giá cao/thấp mới trong ngày theo mã chứng khoán. |
| 35 | expc_exec_prc | DECIMAL(23,2) | X |  |  |  | Giá khớp dự kiến dựa trên thị trường hiện tại (estimated — không phải confirmed). |
| 36 | expc_exec_vol | INT | X |  |  |  | Khối lượng khớp dự kiến (estimated — không phải confirmed). |
| 37 | icd_bug_qty | INT | X |  |  |  | Khối lượng điều chỉnh lỗi trong hệ thống giao dịch KRX (operational). |
| 38 | mbr_code | STRING |  |  | F |  | Mã công ty chứng khoán (thành viên giao dịch). Ví dụ: 003=SSI / 011=HSC. |
| 39 | mbr_nm | STRING | X |  |  |  | Tên công ty chứng khoán (derived từ mã CTCK). |
| 40 | ac_nbr | STRING |  |  | F |  | Mã số tài khoản giao dịch của nhà đầu tư tại CTCK. |
| 41 | ac_hldr_nm | STRING | X |  |  |  | Tên nhà đầu tư / chủ tài khoản. |
| 42 | ac_pin_code | STRING | X |  |  |  | Mã PIN của tài khoản giao dịch tại CTCK. |
| 43 | orig_scr_ordr_code | STRING | X |  | F |  | Order ID của lệnh gốc khi sửa/hủy (17 ký tự). Trống nếu là lệnh mới. |
| 44 | orig_ordr_acpt_nbr | STRING | X |  |  |  | Số thứ tự lệnh gốc trước khi sửa/hủy. Trống nếu là lệnh mới. |
| 45 | trdr_code | STRING | X |  |  |  | Mã định danh người thực hiện giao dịch tại CTCK. |
| 46 | trdr_nm | STRING | X |  |  |  | Tên người thực hiện giao dịch tại CTCK. |
| 47 | refr_seq_nbr | STRING | X |  |  |  | Số tham chiếu thứ tự giao dịch trong luồng dữ liệu. |
| 48 | ordr_rjct_rsn_code | STRING | X |  |  |  | Mã lý do từ chối lệnh (chỉ có giá trị khi bị Reject). |
| 49 | pblc_vol | INT | X |  |  |  | Khối lượng hiển thị công khai của Iceberg order (nhỏ hơn hoặc bằng Order Volume). |
| 50 | cd_prc | DECIMAL(23,2) | X |  |  |  | Giá kích hoạt của Stop order. |
| 51 | orig_ordr_tp_code | STRING | X |  |  |  | Loại lệnh của lệnh gốc trước khi sửa. |
| 52 | qte_rqs_tp_code | STRING | X |  |  |  | Loại yêu cầu báo giá RFQ: 1=Request / 2=Cancel / 3=Confirm / 4=Reject. |
| 53 | auto_cncl_rsn_code | STRING | X |  |  |  | Lý do tự động hủy lệnh: 0=n/a / 1=Condition / 2=Batch / 3=Kill Switch / 4=Disconnect / 5=Price limit. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_ordr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ccy_code | ccy | ccy_code |



**Index:** N/A

**Trigger:** N/A


#### Từ OrderTrade.Order_HNX

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_ordr_id | STRING |  | X | P |  | Khóa đại diện cho sự kiện lệnh giao dịch chứng khoán. |
| 2 | scr_ordr_code | STRING |  |  |  |  | Mã định danh logic của lệnh (17 ký tự). BK chính. |
| 3 | ordr_acpt_nbr | STRING |  |  |  |  | Số định danh lệnh tại KRX tại thời điểm tiếp nhận. Tăng dần — unique trong ngày. |
| 4 | src_stm_code | STRING |  |  |  | 'OrderTrade.Order_HNX' | Mã hệ thống nguồn. |
| 5 | trd_dt | DATE |  |  |  |  | Ngày giao dịch (yyyymmdd). |
| 6 | ordr_dt | DATE | X |  |  |  | Ngày ghi nhận lệnh (yyyymmdd). |
| 7 | ordr_tm | STRING | X |  |  |  | Thời điểm KRX matching engine tiếp nhận lệnh (hh24misss — 9 ký tự kể cả phần trăm giây). |
| 8 | mkt_id_code | STRING |  |  |  |  | Mã thị trường HNX: STX/UPX/BDX/DVX/HCX. |
| 9 | symb_code | STRING |  |  | F |  | Mã định danh chứng khoán (ISIN hoặc mã sàn). |
| 10 | ccy_code | STRING |  |  | F |  | Đơn vị tiền tệ (VND). |
| 11 | board_tp_code | STRING |  |  |  |  | Loại bảng giao dịch (G1/G2/.../T1.../R1). |
| 12 | ssn_code | STRING |  |  |  |  | Phiên giao dịch (00/10/20/30/40/80/90/99...). |
| 13 | ordr_actn_tp_code | STRING |  |  |  |  | Loại action lệnh: 1=New / 2=Replace / 3=Cancel. |
| 14 | side_code | STRING |  |  |  |  | Chiều lệnh: 1=Sell / 2=Buy / 3=Sell/Buy. |
| 15 | ordr_tp_code | STRING |  |  |  |  | Loại lệnh theo giá: 1=Market / 2=Limit / 3=Stop Market / 4=Stop Limit / X=Same side limit / Y=Contrary side limit. |
| 16 | ordr_cd_code | STRING | X |  |  |  | Điều kiện khớp lệnh: 0=FAS / 1=GTC / 2=ATO / 3=FAK / 4=FOK / 6=GTD / 7=ATC / 9=MTL. |
| 17 | ordr_st_code | STRING | X |  |  |  | Trạng thái lệnh: 0=New / 1=Partial Fill / 2=Filled / 3=Cancelled / 4=Rejected / 5=Expired / 6=Pending Cancel / 7=Pending Replace / 8=Replaced. |
| 18 | clnt_hs_tp_code | STRING |  |  |  |  | Phân loại giao dịch: 10=Client trade / 30=House trade. |
| 19 | ivsr_tp_code | STRING | X |  |  |  | Phân loại nhà đầu tư theo chuẩn KRX: 1000=CTCK / 2000=BH / 3000=Quỹ / 4000=Ngân hàng / 7100=Tổ chức / 8000=Cá nhân. |
| 20 | frgn_ivsr_tp_code | STRING | X |  |  |  | Phân loại nhà đầu tư nước ngoài: 00=Không / 10=NN cư trú / 20=NN không cư trú. |
| 21 | shrt_sell_tp_code | STRING | X |  |  |  | Phân loại bán khống: 00=Bình thường / 10=Lệnh bán khống. |
| 22 | mkt_maker_ordr_ind | STRING | X |  |  |  | Cờ lệnh nhà tạo lập thị trường: Y=Có / N=Không. |
| 23 | ordr_prc | DECIMAL(23,2) | X |  |  |  | Giá đặt lệnh (0 nếu Market order hoặc lệnh hủy). |
| 24 | ordr_vol | INT |  |  |  |  | Khối lượng đặt lệnh. |
| 25 | matched_vol | INT | X |  |  |  | Tổng khối lượng đã khớp của lệnh (tích lũy đến thời điểm event này). |
| 26 | rman_vol | INT | X |  |  |  | Khối lượng còn lại chưa khớp. |
| 27 | imm_matched_vol | INT | X |  |  |  | Khối lượng khớp ngay tại thời điểm hệ thống ghi nhận lệnh. |
| 28 | exec_prc | DECIMAL(23,2) | X |  |  |  | Giá khớp lệnh thực tế snapshot tại thời điểm event lệnh. |
| 29 | last_trdd_prc | DECIMAL(23,2) | X |  |  |  | Last Traded Price — giá khớp gần nhất trên thị trường tại thời điểm đặt lệnh. |
| 30 | ordr_prc_vs_ltp | DECIMAL(23,2) | X |  |  |  | Chênh lệch giữa giá đặt và LTP tại thời điểm đặt lệnh (Order Price − LTP). |
| 31 | buy_up_sell_down_amt | DECIMAL(23,2) | X |  |  |  | Mức tăng/giảm giá so với giá tham chiếu theo giá trị tiền. |
| 32 | buy_up_sell_down_tick | INT | X |  |  |  | Mức tăng/giảm theo số bước giá (tick). |
| 33 | matched_rto | DECIMAL(5,2) | X |  |  |  | Tỷ lệ khớp lệnh = Matched VOL / Order VOL. |
| 34 | new_high_low_prc_ind | STRING | X |  |  |  | Đánh dấu nếu lệnh tạo giá cao/thấp mới trong ngày theo mã chứng khoán. |
| 35 | expc_exec_prc | DECIMAL(23,2) | X |  |  |  | Giá khớp dự kiến dựa trên thị trường hiện tại (estimated — không phải confirmed). |
| 36 | expc_exec_vol | INT | X |  |  |  | Khối lượng khớp dự kiến (estimated — không phải confirmed). |
| 37 | icd_bug_qty | INT | X |  |  |  | Khối lượng điều chỉnh lỗi trong hệ thống giao dịch KRX (operational). |
| 38 | mbr_code | STRING |  |  | F |  | Mã thành viên giao dịch (CTCK) do Sở cấp. |
| 39 | mbr_nm | STRING | X |  |  |  | Tên công ty chứng khoán (derived từ mã CTCK). |
| 40 | ac_nbr | STRING |  |  | F |  | Mã tài khoản giao dịch của nhà đầu tư tại CTCK. |
| 41 | ac_hldr_nm | STRING | X |  |  |  | Tên nhà đầu tư / chủ tài khoản. |
| 42 | ac_pin_code | STRING | X |  |  |  | Mã PIN của tài khoản giao dịch tại CTCK. |
| 43 | orig_scr_ordr_code | STRING | X |  |  |  | Order ID của lệnh gốc khi sửa/hủy (17 ký tự). Trống nếu là lệnh mới. |
| 44 | orig_ordr_acpt_nbr | STRING | X |  |  |  | Order Reception Number của lệnh gốc khi sửa/hủy. Trống nếu là lệnh mới. |
| 45 | trdr_code | STRING | X |  |  |  | Mã định danh người thực hiện giao dịch tại CTCK. |
| 46 | trdr_nm | STRING | X |  |  |  | Tên người thực hiện giao dịch tại CTCK. |
| 47 | refr_seq_nbr | STRING | X |  |  |  | Số thứ tự message trong luồng dữ liệu HNX (tăng dần từ 1). |
| 48 | ordr_rjct_rsn_code | STRING | X |  |  |  | Mã lý do từ chối lệnh (chỉ có giá trị khi bị Reject). |
| 49 | pblc_vol | INT | X |  |  |  | Khối lượng hiển thị công khai của Iceberg order (nhỏ hơn hoặc bằng Order Volume). |
| 50 | cd_prc | DECIMAL(23,2) | X |  |  |  | Giá kích hoạt của Stop order. |
| 51 | orig_ordr_tp_code | STRING | X |  |  |  | Loại lệnh của lệnh gốc trước khi sửa. |
| 52 | qte_rqs_tp_code | STRING | X |  |  |  | Loại yêu cầu báo giá RFQ: 1=Request / 2=Cancel / 3=Confirm / 4=Reject. |
| 53 | auto_cncl_rsn_code | STRING | X |  |  |  | Lý do tự động hủy lệnh: 0=n/a / 1=Condition / 2=Batch / 3=Kill Switch / 4=Disconnect / 5=Price limit. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_ordr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ccy_code | ccy | ccy_code |



**Index:** N/A

**Trigger:** N/A





### Bảng scr_trd



#### Từ OrderTrade.Trade_HOSE

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_trd_id | STRING |  | X | P |  | Khóa đại diện cho giao dịch khớp lệnh chứng khoán. |
| 2 | scr_trd_code | STRING |  |  |  |  | Số thứ tự giao dịch khớp do KRX cấp trong ngày theo từng mã chứng khoán. BK chính. |
| 3 | src_stm_code | STRING |  |  |  | 'OrderTrade.Trade_HOSE' | Mã hệ thống nguồn. |
| 4 | trd_dt | DATE |  |  |  |  | Ngày giao dịch (yyyymmdd). |
| 5 | trd_tm | STRING |  |  |  |  | Thời điểm xảy ra giao dịch khớp (hh24miss). |
| 6 | mkt_id_code | STRING |  |  |  |  | Mã thị trường: STO/BDO/RPO (HOSE). |
| 7 | symb_code | STRING |  |  | F |  | Mã chứng khoán. |
| 8 | ccy_code | STRING |  |  | F |  | Đơn vị tiền tệ. |
| 9 | board_tp_code | STRING |  |  |  |  | Loại bảng giao dịch. |
| 10 | ssn_code | STRING |  |  |  |  | Phiên giao dịch lúc khớp. |
| 11 | exec_prc | DECIMAL(23,2) |  |  |  |  | Giá khớp thực tế của giao dịch. |
| 12 | exec_vol | INT |  |  |  |  | Khối lượng khớp. |
| 13 | exec_val | DECIMAL(23,2) |  |  |  |  | Tổng giá trị giao dịch khớp = Exec Price × Exec Volume. |
| 14 | exec_ltp | DECIMAL(23,2) | X |  |  |  | Last Traded Price của mã chứng khoán ngay trước khi có Trade này. |
| 15 | exec_prc_vs_ltp | DECIMAL(23,2) | X |  |  |  | Chênh lệch giữa giá khớp và LTP trước đó (Exec Price − LTP). |
| 16 | exec_new_high_low_prc_ind | STRING | X |  |  |  | Đánh dấu nếu Trade tạo giá cao/thấp mới trong ngày. |
| 17 | buy_scr_ordr_id | STRING | X |  | F |  | FK đến lệnh mua trong Securities Order. |
| 18 | buy_scr_ordr_code | STRING | X |  |  |  | Số thứ tự lệnh mua tại KRX. |
| 19 | buy_ordr_dt | DATE | X |  | F |  | Ngày đặt lệnh mua (yyyymmdd). |
| 20 | buy_ordr_tm | STRING | X |  |  |  | Thời gian đặt lệnh mua (hh24miss). |
| 21 | buy_mbr_code | STRING |  |  | F |  | Mã công ty chứng khoán bên mua. |
| 22 | buy_mbr_nm | STRING | X |  |  |  | Tên công ty chứng khoán bên mua. |
| 23 | buy_ac_nbr | STRING |  |  | F |  | Tài khoản nhà đầu tư bên mua. |
| 24 | buy_ac_hldr_nm | STRING | X |  |  |  | Tên nhà đầu tư bên mua. |
| 25 | buy_ac_pin_code | STRING | X |  |  |  | Mã PIN tài khoản bên mua. |
| 26 | buy_clnt_hs_tp_code | STRING |  |  |  |  | Phân loại lệnh mua: 10=Client / 30=House. |
| 27 | buy_ivsr_tp_code | STRING | X |  |  |  | Loại hình nhà đầu tư bên mua. |
| 28 | buy_frgn_ivsr_tp_code | STRING | X |  |  |  | Phân loại nhà đầu tư nước ngoài bên mua: 00/10/20. |
| 29 | buy_ordr_prc | DECIMAL(23,2) | X |  |  |  | Giá đặt lệnh mua gốc. |
| 30 | buy_ordr_vol | INT | X |  |  |  | Khối lượng đặt mua gốc. |
| 31 | buy_trdr_code | STRING | X |  |  |  | Mã người thực hiện đặt mua. |
| 32 | buy_trdr_nm | STRING | X |  |  |  | Tên người thực hiện đặt mua. |
| 33 | buy_refr_seq_nbr | STRING | X |  |  |  | Số tham chiếu thứ tự đặt mua trong luồng dữ liệu. |
| 34 | sell_scr_ordr_id | STRING | X |  | F |  | FK đến lệnh bán trong Securities Order. |
| 35 | sell_scr_ordr_code | STRING | X |  |  |  | Số thứ tự lệnh bán tại KRX. |
| 36 | sell_ordr_dt | DATE | X |  |  |  | Ngày đặt lệnh bán (yyyymmdd). |
| 37 | sell_ordr_tm | STRING | X |  |  |  | Thời gian đặt lệnh bán (hh24miss). |
| 38 | sell_mbr_code | STRING |  |  | F |  | Mã công ty chứng khoán bên bán. |
| 39 | sell_mbr_nm | STRING | X |  |  |  | Tên công ty chứng khoán bên bán. |
| 40 | sell_ac_nbr | STRING |  |  | F |  | Tài khoản nhà đầu tư bên bán. |
| 41 | sell_ac_hldr_nm | STRING | X |  |  |  | Tên nhà đầu tư bên bán. |
| 42 | sell_ac_pin_code | STRING | X |  |  |  | Mã PIN tài khoản bên bán. |
| 43 | sell_clnt_hs_tp_code | STRING |  |  |  |  | Phân loại lệnh bán: 10=Client / 30=House. |
| 44 | sell_ivsr_tp_code | STRING | X |  |  |  | Loại hình nhà đầu tư bên bán. |
| 45 | sell_frgn_ivsr_tp_code | STRING | X |  |  |  | Phân loại nhà đầu tư nước ngoài bên bán: 00/10/20. |
| 46 | sell_ordr_prc | DECIMAL(23,2) | X |  |  |  | Giá đặt lệnh bán gốc. |
| 47 | sell_ordr_vol | INT | X |  |  |  | Khối lượng đặt bán gốc. |
| 48 | sell_trdr_code | STRING | X |  |  |  | Mã người thực hiện đặt bán. |
| 49 | sell_trdr_nm | STRING | X |  |  |  | Tên người thực hiện đặt bán. |
| 50 | sell_refr_seq_nbr | STRING | X |  |  |  | Số tham chiếu thứ tự đặt bán trong luồng dữ liệu. |
| 51 | exec_prc_sprd_frst | DECIMAL(23,2) | X |  |  |  | Giá khớp của Leg 1 trong Spread trade (phái sinh/repo 2 vế). |
| 52 | exec_prc_sprd_scd | DECIMAL(23,2) | X |  |  |  | Giá khớp của Leg 2 trong Spread trade. |
| 53 | buy_ordr_tp_code | STRING | X |  |  |  | Loại lệnh mua tại thời điểm khớp. |
| 54 | buy_ordr_cd_code | STRING | X |  |  |  | Điều kiện lệnh mua tại thời điểm khớp. |
| 55 | buy_ordr_actn_tp_code | STRING | X |  |  |  | Loại action của lệnh mua tại thời điểm khớp: 1=New / 2=Replace / 3=Cancel. |
| 56 | buy_qte_rqs_tp_code | STRING | X |  |  |  | Loại yêu cầu báo giá RFQ bên mua: 1=Request / 2=Cancel / 3=Confirm / 4=Reject. |
| 57 | sell_ordr_tp_code | STRING | X |  |  |  | Loại lệnh bán tại thời điểm khớp. |
| 58 | sell_ordr_cd_code | STRING | X |  |  |  | Điều kiện lệnh bán tại thời điểm khớp. |
| 59 | sell_ordr_actn_tp_code | STRING | X |  |  |  | Loại action của lệnh bán tại thời điểm khớp: 1=New / 2=Replace / 3=Cancel. |
| 60 | sell_qte_rqs_tp_code | STRING | X |  |  |  | Loại yêu cầu báo giá RFQ bên bán: 1=Request / 2=Cancel / 3=Confirm / 4=Reject. |
| 61 | refr_seq_nbr | STRING | X |  |  |  | Số thứ tự message trong luồng dữ liệu HNX. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_trd_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ccy_code | ccy | ccy_code |
| buy_scr_ordr_id | scr_ordr | scr_ordr_id |
| sell_scr_ordr_id | scr_ordr | scr_ordr_id |



**Index:** N/A

**Trigger:** N/A


#### Từ OrderTrade.Trade_HNX

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_trd_id | STRING |  | X | P |  | Khóa đại diện cho giao dịch khớp lệnh chứng khoán. |
| 2 | scr_trd_code | STRING |  |  |  |  | ID của giao dịch khớp — unique key trong ngày. BK chính. |
| 3 | src_stm_code | STRING |  |  |  | 'OrderTrade.Trade_HNX' | Mã hệ thống nguồn. |
| 4 | trd_dt | DATE |  |  |  |  | Ngày giao dịch (yyyymmdd). |
| 5 | trd_tm | STRING |  |  |  |  | Thời điểm giao dịch xảy ra (hh24misss — 9 ký tự kể cả phần trăm giây). |
| 6 | mkt_id_code | STRING |  |  |  |  | Mã thị trường HNX: STX/UPX/BDX/DVX/HCX. |
| 7 | symb_code | STRING |  |  | F |  | Mã chứng khoán. |
| 8 | ccy_code | STRING |  |  | F |  | Đơn vị tiền tệ. |
| 9 | board_tp_code | STRING |  |  |  |  | Loại bảng giao dịch. |
| 10 | ssn_code | STRING |  |  |  |  | Phiên giao dịch lúc khớp. |
| 11 | exec_prc | DECIMAL(23,2) |  |  |  |  | Giá khớp thực tế của giao dịch. |
| 12 | exec_vol | INT |  |  |  |  | Khối lượng giao dịch khớp. |
| 13 | exec_val | DECIMAL(23,2) |  |  |  |  | Tổng giá trị giao dịch khớp = Exec Price × Exec Volume. |
| 14 | exec_ltp | DECIMAL(23,2) | X |  |  |  | Last Traded Price của mã chứng khoán ngay trước khi có Trade này. |
| 15 | exec_prc_vs_ltp | DECIMAL(23,2) | X |  |  |  | Chênh lệch giữa giá khớp và LTP trước đó (Exec Price − LTP). |
| 16 | exec_new_high_low_prc_ind | STRING | X |  |  |  | Đánh dấu nếu Trade tạo giá cao/thấp mới trong ngày. |
| 17 | buy_scr_ordr_id | STRING | X |  | F |  | FK đến lệnh mua trong Securities Order. |
| 18 | buy_scr_ordr_code | STRING | X |  |  |  | Order Reception Number của lệnh mua tại KRX. |
| 19 | buy_ordr_dt | DATE | X |  | F |  | Ngày đặt lệnh mua (yyyymmdd). |
| 20 | buy_ordr_tm | STRING | X |  |  |  | Thời gian đặt lệnh mua (hh24miss). |
| 21 | buy_mbr_code | STRING |  |  | F |  | Mã CTCK bên mua. |
| 22 | buy_mbr_nm | STRING | X |  |  |  | Tên công ty chứng khoán bên mua. |
| 23 | buy_ac_nbr | STRING |  |  | F |  | Tài khoản nhà đầu tư bên mua. |
| 24 | buy_ac_hldr_nm | STRING | X |  |  |  | Tên nhà đầu tư bên mua. |
| 25 | buy_ac_pin_code | STRING | X |  |  |  | Mã PIN tài khoản bên mua. |
| 26 | buy_clnt_hs_tp_code | STRING |  |  |  |  | Phân loại lệnh mua: 10=Client / 30=House. |
| 27 | buy_ivsr_tp_code | STRING | X |  |  |  | Loại hình nhà đầu tư bên mua theo chuẩn KRX. |
| 28 | buy_frgn_ivsr_tp_code | STRING | X |  |  |  | Phân loại nhà đầu tư nước ngoài bên mua: 00/10/20. |
| 29 | buy_ordr_prc | DECIMAL(23,2) | X |  |  |  | Giá đặt lệnh mua gốc. |
| 30 | buy_ordr_vol | INT | X |  |  |  | Khối lượng đặt mua gốc. |
| 31 | buy_trdr_code | STRING | X |  |  |  | Mã người thực hiện đặt mua. |
| 32 | buy_trdr_nm | STRING | X |  |  |  | Tên người thực hiện đặt mua. |
| 33 | buy_refr_seq_nbr | STRING | X |  |  |  | Số tham chiếu thứ tự đặt mua trong luồng dữ liệu. |
| 34 | sell_scr_ordr_id | STRING | X |  | F |  | FK đến lệnh bán trong Securities Order. |
| 35 | sell_scr_ordr_code | STRING | X |  |  |  | Order Reception Number của lệnh bán tại KRX. |
| 36 | sell_ordr_dt | DATE | X |  |  |  | Ngày đặt lệnh bán (yyyymmdd). |
| 37 | sell_ordr_tm | STRING | X |  |  |  | Thời gian đặt lệnh bán (hh24miss). |
| 38 | sell_mbr_code | STRING |  |  | F |  | Mã CTCK bên bán. |
| 39 | sell_mbr_nm | STRING | X |  |  |  | Tên công ty chứng khoán bên bán. |
| 40 | sell_ac_nbr | STRING |  |  | F |  | Tài khoản nhà đầu tư bên bán. |
| 41 | sell_ac_hldr_nm | STRING | X |  |  |  | Tên nhà đầu tư bên bán. |
| 42 | sell_ac_pin_code | STRING | X |  |  |  | Mã PIN tài khoản bên bán. |
| 43 | sell_clnt_hs_tp_code | STRING |  |  |  |  | Phân loại lệnh bán: 10=Client / 30=House. |
| 44 | sell_ivsr_tp_code | STRING | X |  |  |  | Loại hình nhà đầu tư bên bán theo chuẩn KRX. |
| 45 | sell_frgn_ivsr_tp_code | STRING | X |  |  |  | Phân loại nhà đầu tư nước ngoài bên bán: 00/10/20. |
| 46 | sell_ordr_prc | DECIMAL(23,2) | X |  |  |  | Giá đặt lệnh bán gốc. |
| 47 | sell_ordr_vol | INT | X |  |  |  | Khối lượng đặt bán gốc. |
| 48 | sell_trdr_code | STRING | X |  |  |  | Mã người thực hiện đặt bán. |
| 49 | sell_trdr_nm | STRING | X |  |  |  | Tên người thực hiện đặt bán. |
| 50 | sell_refr_seq_nbr | STRING | X |  |  |  | Số tham chiếu thứ tự đặt bán trong luồng dữ liệu. |
| 51 | exec_prc_sprd_frst | DECIMAL(23,2) | X |  |  |  | Giá khớp của Leg 1 trong Spread trade (phái sinh/repo 2 vế). |
| 52 | exec_prc_sprd_scd | DECIMAL(23,2) | X |  |  |  | Giá khớp của Leg 2 trong Spread trade. |
| 53 | buy_ordr_tp_code | STRING | X |  |  |  | Loại lệnh mua tại thời điểm khớp. |
| 54 | buy_ordr_cd_code | STRING | X |  |  |  | Điều kiện lệnh mua tại thời điểm khớp. |
| 55 | buy_ordr_actn_tp_code | STRING | X |  |  |  | Loại action của lệnh mua tại thời điểm khớp: 1=New / 2=Replace / 3=Cancel. |
| 56 | buy_qte_rqs_tp_code | STRING | X |  |  |  | Loại yêu cầu báo giá RFQ bên mua: 1=Request / 2=Cancel / 3=Confirm / 4=Reject. |
| 57 | sell_ordr_tp_code | STRING | X |  |  |  | Loại lệnh bán tại thời điểm khớp. |
| 58 | sell_ordr_cd_code | STRING | X |  |  |  | Điều kiện lệnh bán tại thời điểm khớp. |
| 59 | sell_ordr_actn_tp_code | STRING | X |  |  |  | Loại action của lệnh bán tại thời điểm khớp: 1=New / 2=Replace / 3=Cancel. |
| 60 | sell_qte_rqs_tp_code | STRING | X |  |  |  | Loại yêu cầu báo giá RFQ bên bán: 1=Request / 2=Cancel / 3=Confirm / 4=Reject. |
| 61 | refr_seq_nbr | STRING | X |  |  |  | Số thứ tự message trong luồng dữ liệu HNX. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_trd_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ccy_code | ccy | ccy_code |
| buy_scr_ordr_id | scr_ordr | scr_ordr_id |
| sell_scr_ordr_id | scr_ordr | scr_ordr_id |



**Index:** N/A

**Trigger:** N/A





### Stored Procedure/Function

N/A

### Package

N/A


