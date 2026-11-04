## MDDS — Phân hệ quản lí giao dịch thị trường từ các SGDCK

### Các mô hình quan hệ dữ liệu

![Mô hình quan hệ dữ liệu MDDS](MDDS/fragments/MDDS_diagram.png)

**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | security_match_log | Log từng lần khớp lệnh (tick-by-tick) của cổ phiếu niêm yết trong ngày giao dịch, bao gồm giá khớp, khối lượng khớp, chiều giao dịch chủ động, và lũy kế khối lượng/giá trị từ đầu ngày. |
| 2 | corporate_bond_trading_snapshot | Snapshot trạng thái giao dịch của trái phiếu doanh nghiệp niêm yết tại sàn HNX tại một thời điểm, bao gồm giá khớp, order book thỏa thuận Outright, thông tin đặc thù trái phiếu (kỳ hạn, lãi suất, coupon, mệnh giá, ngày phát hành/đáo hạn). |
| 3 | index_constituent_snapshot | Snapshot thành phần rổ chỉ số thị trường theo ngày giao dịch — mỗi dòng ghi nhận một cặp mã chỉ số và mã chứng khoán có mặt trong rổ chỉ số tại ngày giao dịch tương ứng. |
| 4 | market_index_snapshot | Snapshot trạng thái của một chỉ số thị trường (VNINDEX, HNX-Index, UPCOM-Index) tại một thời điểm trong ngày, bao gồm điểm chỉ số, tổng khối lượng/giá trị, thống kê mã tăng/giảm/trần/sàn, trạng thái phiên giao dịch. |
| 5 | market_price_snapshot | Nến giá OHLCV (mở/cao/thấp/đóng cửa, khối lượng khớp) của một mã (chứng khoán hoặc chỉ số) theo kỳ phút hoặc ngày, phục vụ biểu đồ TradingView. Gộp từ 2 bảng nguồn cấu trúc gần như giống hệt nhau, phân biệt qua src_stm_code. |
| 6 | security_trading_snapshot | Snapshot trạng thái giao dịch của một công cụ tài chính (cổ phiếu, chứng quyền, hợp đồng phái sinh, chứng chỉ quỹ) tại một thời điểm trong ngày giao dịch, bao gồm giá, sổ lệnh, NĐTNN và thông tin đặc thù theo loại instrument. |




### Bảng security_match_log



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | security_match_log_id | STRING |  | X | P |  | Khóa đại diện (surrogate key). |
| 2 | security_match_log_code | STRING |  |  |  |  | Bản ghi log khớp lệnh — PK bảng nguồn (KID). |
| 3 | src_stm_code | STRING |  |  |  | 'MDDS.JAD_TRANSLOG' | Mã hệ thống nguồn dữ liệu. |
| 4 | board_id | STRING | X |  |  |  | Board của mã, mặc định G1. |
| 5 | change_color_code | STRING | X |  |  |  | Màu sắc thể hiện trạng thái biến động của khoảng tăng/giảm giá (Change) so với phiên trước. |
| 6 | accumulated_val | DECIMAL(23,2) |  |  |  |  | Tổng giá trị khớp lũy kế trong ngày (lô chẵn). |
| 7 | accumulated_vol | BIGINT |  |  |  |  | Tổng khối lượng khớp lũy kế trong ngày (lô chẵn). |
| 8 | price_change | DECIMAL(23,2) |  |  |  |  | Giá trị chênh lệch tuyệt đối giữa mức giá hiện tại (giá khớp lệnh cuối cùng) so với giá tham chiếu của ngày hôm đó. |
| 9 | match_price | DECIMAL(23,2) |  |  |  |  | Giá khớp. |
| 10 | match_time | STRING | X |  |  |  | Thời gian khớp. |
| 11 | match_vol | BIGINT |  |  |  |  | Khối lượng khớp. |
| 12 | trade_direction_code | STRING | X |  |  |  | Màu sắc thể hiện trạng thái tăng, giảm hoặc đứng giá của mức giá khớp lệnh gần đây nhất (Last Price) so với giá tham chiếu. |
| 13 | sequence_message | STRING | X |  |  |  | Sequence tín hiệu của sở. |
| 14 | ticker_symbol | STRING | X |  | F |  | Mã chứng khoán. |
| 15 | total_buy_vol | BIGINT |  |  |  |  | Tổng khối lượng mua chủ động. |
| 16 | total_sell_vol | BIGINT |  |  |  |  | Tổng khối lượng bán chủ động. |
| 17 | trading_dt | DATE | X |  |  |  | Ngày giao dịch. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| security_match_log_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng corporate_bond_trading_snapshot



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | corporate_bond_trading_snpst_id | STRING |  | X | P |  | Khóa đại diện (surrogate key). |
| 2 | corporate_bond_trading_snpst_code | STRING |  |  |  |  | Mã trái phiếu — PK bảng nguồn (SYMBOL). BK của Snapshot entity. |
| 3 | src_stm_code | STRING |  |  |  | 'MDDS.JAD_CORPBONDINFOR' | Mã hệ thống nguồn dữ liệu. |
| 4 | ticker_symbol | STRING |  |  |  |  | Mã chứng khoán trái phiếu. |
| 5 | period | STRING | X |  |  |  | Kỳ hạn trái phiếu. |
| 6 | exchange_code | STRING | X |  |  |  | Mã sàn: 06 (corp-bond HNX). |
| 7 | full_nm | STRING | X |  |  |  | Tên đầy đủ của trái phiếu. |
| 8 | interest_rate_tp_code | STRING | X |  |  |  | Loại lãi suất: Cố định/Thả nổi/Khác. |
| 9 | coupon_tp_code | STRING | X |  |  |  | Kiểu trả lãi: Standard/Long/Short/Zero Coupon. |
| 10 | interest_payment_tp_code | STRING | X |  |  |  | Phương thức trả lãi. |
| 11 | interest_period | STRING | X |  |  |  | Kỳ hạn trả lãi. |
| 12 | interest_period_unit_code | STRING | X |  |  |  | Đơn vị kỳ hạn trả lãi. |
| 13 | interest_rate | DECIMAL(8,5) | X |  |  |  | Lãi suất danh nghĩa. |
| 14 | interest_tp_code | STRING | X |  |  |  | Loại hình trả lãi (Định kỳ cuối kỳ / đầu kỳ / khác). |
| 15 | issue_dt | DATE | X |  |  |  | Ngày phát hành trái phiếu. |
| 16 | issuer_nm | STRING | X |  |  |  | Tên tổ chức phát hành. |
| 17 | maturity_dt | DATE | X |  |  |  | Ngày đáo hạn trái phiếu. |
| 18 | period_remain_days | INT | X |  |  |  | Kỳ hạn còn lại tính bằng ngày. |
| 19 | period_unit | STRING | X |  |  |  | Đơn vị kỳ hạn (Ngày/Tuần/Tháng/Năm). |
| 20 | pt_best_bid_price | DECIMAL(23,2) |  |  |  |  | Giá chào mua cao nhất GD thỏa thuận Outright. |
| 21 | pt_best_bid_quantity | BIGINT |  |  |  |  | Khối lượng chào mua ở mức giá cao nhất GD thỏa thuận Outright. |
| 22 | pt_best_offer_price | DECIMAL(23,2) |  |  |  |  | Giá chào bán thấp nhất GD thỏa thuận Outright. |
| 23 | pt_best_offer_quantity | BIGINT |  |  |  |  | Khối lượng chào bán ở mức giá thấp nhất GD thỏa thuận Outright. |
| 24 | pt_match_price | DECIMAL(23,2) |  |  |  |  | Giá thực hiện gần nhất GD thỏa thuận Outright. |
| 25 | pt_match_quantity | BIGINT |  |  |  |  | Khối lượng thực hiện gần nhất GD thỏa thuận Outright. |
| 26 | pt_max_price | DECIMAL(23,2) |  |  |  |  | Giá thực hiện cao nhất GD thỏa thuận Outright. |
| 27 | pt_max_quantity | BIGINT |  |  |  |  | Khối lượng giao dịch tối đa quy định cho một lệnh giao dịch thỏa thuận Outright. |
| 28 | pt_min_price | DECIMAL(23,2) |  |  |  |  | Giá thực hiện thấp nhất GD thỏa thuận Outright. |
| 29 | pt_min_quantity | BIGINT |  |  |  |  | Khối lượng giao dịch tối thiểu quy định cho một lệnh giao dịch thỏa thuận Outright. |
| 30 | pt_total_traded_quantity | BIGINT |  |  |  |  | Tổng khối lượng GD thỏa thuận Outright. |
| 31 | pt_total_traded_val | DECIMAL(23,2) |  |  |  |  | Tổng giá trị GD thỏa thuận Outright. |
| 32 | pt_total_bid_quantity | BIGINT |  |  |  |  | Tổng khối lượng chào mua GD thỏa thuận Outright. |
| 33 | pt_total_offer_quantity | BIGINT |  |  |  |  | Tổng khối lượng chào bán GD thỏa thuận Outright. |
| 34 | stock_tp_code | STRING | X |  |  |  | Loại CK. |
| 35 | total_listing_vol | BIGINT |  |  |  |  | Khối lượng niêm yết. |
| 36 | average_price | DECIMAL(23,2) |  |  |  |  | Giá trung bình. |
| 37 | ceiling_price | DECIMAL(23,2) |  |  |  |  | Giá trần khớp lệnh. |
| 38 | price_change | DECIMAL(23,2) |  |  |  |  | Thay đổi giá khớp gần nhất so với giá tham chiếu. |
| 39 | bond_characteristics | STRING | X |  |  |  | Đặc điểm trái phiếu. |
| 40 | close_price | DECIMAL(23,2) |  |  |  |  | Giá đóng cửa ngày. |
| 41 | close_vol | BIGINT |  |  |  |  | Khối lượng giao dịch phiên đóng cửa. |
| 42 | floor_price | DECIMAL(23,2) |  |  |  |  | Giá sàn khớp lệnh. |
| 43 | foreign_remain_quantity | BIGINT |  |  |  |  | Số lượng chứng khoán còn lại mà nhà đầu tư nước ngoài được phép tiếp tục mua vào tại mã chứng khoán (phần room còn trống). |
| 44 | high_price | DECIMAL(23,2) |  |  |  |  | Giá thực hiện cao nhất GD khớp lệnh. |
| 45 | low_price | DECIMAL(23,2) |  |  |  |  | Giá thực hiện thấp nhất GD khớp lệnh. |
| 46 | open_price | DECIMAL(23,2) |  |  |  |  | Giá mở cửa. |
| 47 | par_val | DECIMAL(23,2) | X |  |  |  | Mệnh giá trái phiếu. |
| 48 | reference_price | DECIMAL(23,2) |  |  |  |  | Giá tham chiếu. |
| 49 | security_trading_status_code | STRING | X |  |  |  | Trạng thái trái phiếu. |
| 50 | total_trading_vol | BIGINT |  |  |  |  | Tổng khối lượng giao dịch. |
| 51 | total_trading_val | DECIMAL(23,2) |  |  |  |  | Tổng giá trị giao dịch. |
| 52 | trading_session_status | STRING | X |  |  |  | Trạng thái phiên giao dịch. |
| 53 | trading_session_id | STRING | X |  |  |  | Trạng thái phiên giao dịch HNX. |
| 54 | trading_time | STRING | X |  |  |  | Thời gian giao dịch. |
| 55 | trading_dt | DATE | X |  |  |  | Ngày giao dịch format dd/mm/yyyy. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| corporate_bond_trading_snpst_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng index_constituent_snapshot



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | index_constituent_snpst_id | STRING |  | X | P |  | Khóa đại diện (surrogate key). |
| 2 | index_constituent_snpst_code | STRING |  |  |  |  | GUID — PK của bảng nguồn. BK. |
| 3 | src_stm_code | STRING |  |  |  | 'MDDS.JAD_CSIDXINFOR' | Mã hệ thống nguồn dữ liệu. |
| 4 | add_dt | DATE | X |  |  |  | Ngày thêm vào chỉ số. |
| 5 | floor_code | STRING | X |  |  |  | Mã sở giao dịch CK. |
| 6 | index_code | STRING | X |  | F |  | Mã chỉ số (FK đến MarketInfor / IDXInfor). |
| 7 | index_id | STRING |  |  |  |  | ID nội bộ của chỉ số. |
| 8 | stock_nbr | STRING | X |  |  |  | Số hiệu mã chứng khoán trong rổ chỉ số. |
| 9 | ticker_symbol | STRING | X |  |  |  | Mã chứng khoán trong rổ (FK đến StockInfor). |
| 10 | total_quantity | BIGINT | X |  |  |  | Tổng khối lượng cổ phiếu lưu hành. |
| 11 | trading_dt | DATE | X |  |  |  | Ngày giao dịch dạng dd/MM/yyyy. |
| 12 | constituent_weight_percentage | DECIMAL(5,2) | X |  |  |  | Tỷ trọng của mã trong rổ chỉ số. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| index_constituent_snpst_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng market_index_snapshot



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | market_index_snpst_id | STRING |  | X | P |  | Khóa đại diện (surrogate key). |
| 2 | market_index_snpst_code | STRING |  |  |  |  | ID unique để lưu lịch sử — PK thực tế của bảng. BK của Snapshot entity. |
| 3 | src_stm_code | STRING |  |  |  | 'MDDS.JAD_MARKETINFOR' | Mã hệ thống nguồn dữ liệu. |
| 4 | average_index_change | DECIMAL(23,2) |  |  |  |  | Mức thay đổi chỉ số bình quân. |
| 5 | average_market_index_val | DECIMAL(23,2) |  |  |  |  | Giá trị chỉ số thị trường bình quân. |
| 6 | average_index_percent_change | DECIMAL(5,2) |  |  |  |  | Phần trăm thay đổi chỉ số bình quân. |
| 7 | average_prior_index | DECIMAL(23,2) |  |  |  |  | Giá trị chỉ số liền trước bình quân. |
| 8 | previous_prior_market_index | DECIMAL(23,2) |  |  |  |  | Index cuối cùng của phiên trước đó. |
| 9 | pt_total_quantity | BIGINT |  |  |  |  | Tổng khối lượng giao dịch thỏa thuận. |
| 10 | pt_total_trade_count | BIGINT |  |  |  |  | Tổng số giao dịch thỏa thuận. |
| 11 | pt_total_val | DECIMAL(23,2) |  |  |  |  | Tổng giá trị giao dịch thỏa thuận. |
| 12 | advances_count | INT |  |  |  |  | Số lượng mã tăng. |
| 13 | advances_vol | BIGINT |  |  |  |  | Tổng khối lượng khớp của các mã tăng giá. Advances + Declines + No Change Volume = tổng khối lượng khớp toàn thị trường. |
| 14 | declines_count | INT |  |  |  |  | Số lượng mã giảm. |
| 15 | declines_vol | BIGINT |  |  |  |  | Tổng khối lượng khớp của các mã giảm giá. Advances + Declines + No Change Volume = tổng khối lượng khớp toàn thị trường. |
| 16 | halt_reason_code | STRING | X |  |  |  | Lý do thị trường bị halt. |
| 17 | high_index | DECIMAL(23,2) |  |  |  |  | Index cao nhất tính đến thời điểm hiện tại. |
| 18 | index_change | DECIMAL(23,2) |  |  |  |  | Giá trị index thay đổi so với index cuối ngày hôm trước. |
| 19 | index_color | STRING | X |  |  |  | Màu sắc thể hiện trạng thái biến động của một chỉ số chứng khoán (VN-Index, HNX-Index, VN30...) tại thời điểm hiện tại so với mức điểm tham chiếu (điểm đóng cửa phiên trước). |
| 20 | index_nm | STRING | X |  |  |  | Tên của index. |
| 21 | index_percent_change | DECIMAL(5,2) |  |  |  |  | % index thay đổi so với index cuối ngày hôm trước. |
| 22 | index_time | STRING | X |  |  |  | Thời gian ghi nhận chỉ số. |
| 23 | index_tp_code | STRING | X |  |  |  | Loại index — mã Sở quy định. |
| 24 | low_index | DECIMAL(23,2) |  |  |  |  | Index thấp nhất tính đến thời điểm hiện tại. |
| 25 | market_code | STRING | X |  |  |  | Mã thị trường — FSS tự quy định. |
| 26 | market_id | STRING | X |  |  |  | ID thị trường — FSS tự quy định. |
| 27 | market_index_val | DECIMAL(23,2) |  |  |  |  | Giá trị index tại thời điểm ghi nhận. |
| 28 | market_status | STRING | X |  |  |  | Trạng thái phiên giao dịch. |
| 29 | no_change_count | INT |  |  |  |  | Số lượng mã không tăng/giảm. |
| 30 | no_change_vol | BIGINT |  |  |  |  | Tổng khối lượng khớp của các mã đứng giá. Advances + Declines + No Change Volume = tổng khối lượng khớp toàn thị trường. |
| 31 | ceiling_count | INT |  |  |  |  | Số lượng mã đang trần. |
| 32 | floor_count | INT |  |  |  |  | Số lượng mã đang sàn. |
| 33 | odd_lot_total_val | DECIMAL(23,2) |  |  |  |  | Tổng giá trị giao dịch lô lẻ. |
| 34 | odd_lot_total_vol | BIGINT |  |  |  |  | Khối lượng khớp lô lẻ — chỉ tiêu báo cáo riêng, không nằm trong bộ ba phân loại tăng/giảm/đứng giá. |
| 35 | open_index | DECIMAL(23,2) |  |  |  |  | Index mở cửa. |
| 36 | previous_market_status_code | STRING | X |  |  |  | Trạng thái phiên giao dịch liền trước. |
| 37 | sequence | BIGINT |  |  |  |  | Đánh thứ tự update của từng Index. |
| 38 | sequence_message | STRING | X |  |  |  | Sequence tín hiệu của sở. |
| 39 | total_trade_count | BIGINT |  |  |  |  | Tổng số giao dịch. |
| 40 | total_val | DECIMAL(23,2) |  |  |  |  | Tổng giá trị đã khớp. |
| 41 | total_vol | BIGINT |  |  |  |  | Tổng khối lượng đã khớp. |
| 42 | trading_dt | DATE | X |  |  |  | Ngày giao dịch. |
| 43 | tsc_product_group_id | STRING | X |  |  |  | Mã sản phẩm giao dịch (hose/hnx/upcom). |
| 44 | exchange_code | STRING | X |  |  |  | Mã sàn giao dịch. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| market_index_snpst_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng market_price_snapshot



#### Từ MDDS.JAD_TVHISTORY1M

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | market_price_snpst_id | STRING |  | X | P |  | Khóa đại diện (surrogate key). |
| 2 | market_price_snpst_code | STRING |  |  |  |  | Định danh. PK bảng nguồn. BK của Snapshot entity. |
| 3 | src_stm_code | STRING |  |  |  | 'MDDS.JAD_TVHISTORY1M' | Mã hệ thống nguồn dữ liệu. |
| 4 | close_price | DECIMAL(23,2) |  |  |  |  | Giá đóng cửa trong phút. |
| 5 | high_price | DECIMAL(23,2) |  |  |  |  | Giá cao nhất trong phút. |
| 6 | low_price | DECIMAL(23,2) |  |  |  |  | Giá thấp nhất trong phút. |
| 7 | processing_time | STRING | X |  |  |  | Giờ tính toán (HH:mm). |
| 8 | open_price | DECIMAL(23,2) |  |  |  |  | Giá mở cửa trong phút. |
| 9 | ticker_symbol | STRING | X |  | F |  | Mã (gồm cả chứng khoán và index). |
| 10 | trading_dt | DATE | X |  |  |  | Ngày tính toán (dd/MM/yyyy). |
| 11 | vol | BIGINT |  |  |  |  | Tổng khối lượng khớp trong phút. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| market_price_snpst_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


**Index:** N/A

**Trigger:** N/A


#### Từ MDDS.JAD_TVHISTORY1D

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | market_price_snpst_id | STRING |  | X | P |  | Khóa đại diện (surrogate key). |
| 2 | market_price_snpst_code | STRING |  |  |  |  | Định danh. PK bảng nguồn. BK của Snapshot entity. |
| 3 | src_stm_code | STRING |  |  |  | 'MDDS.JAD_TVHISTORY1D' | Mã hệ thống nguồn dữ liệu. |
| 4 | close_price | DECIMAL(23,2) |  |  |  |  | Giá đóng cửa trong ngày. |
| 5 | high_price | DECIMAL(23,2) |  |  |  |  | Giá cao nhất trong ngày. |
| 6 | low_price | DECIMAL(23,2) |  |  |  |  | Giá thấp nhất trong ngày. |
| 7 | open_price | DECIMAL(23,2) |  |  |  |  | Giá mở cửa trong ngày. |
| 8 | ticker_symbol | STRING | X |  | F |  | Mã (gồm cả chứng khoán và index). |
| 9 | trading_dt | DATE | X |  |  |  | Ngày tính toán (dd/MM/yyyy). |
| 10 | vol | BIGINT |  |  |  |  | Tổng khối lượng khớp trong ngày. |


**Khóa chính (Primary Key):**

| Tên trường |
|---|
| market_price_snpst_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


**Index:** N/A

**Trigger:** N/A





### Bảng security_trading_snapshot



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | security_trading_snpst_id | STRING |  | X | P |  | Khóa đại diện (surrogate key). |
| 2 | security_trading_snpst_code | STRING |  |  |  |  | ID unique cho từng dòng lịch sử — PK bảng nguồn. BK của Snapshot entity. |
| 3 | src_stm_code | STRING |  |  |  | 'MDDS.JAD_STOCKINFOR' | Mã hệ thống nguồn dữ liệu. |
| 4 | covered_warrant_tp_code | STRING | X |  |  |  | Kiểu chứng quyền. |
| 5 | exercise_price | DECIMAL(23,2) | X |  |  |  | Giá thực hiện CW. |
| 6 | exercise_ratio | STRING | X |  |  |  | Tỉ lệ thực hiện CW. |
| 7 | floor_code | STRING | X |  |  |  | Mã sàn: 02-HNX, 04-UPCOM, 10-HOSE, 03-FDS. |
| 8 | full_nm | STRING | X |  |  |  | Tên chứng khoán (tiếng Việt). |
| 9 | fund_tp_code | STRING | X |  |  |  | Loại quỹ. |
| 10 | issuer_nm | STRING | X |  |  |  | Tổ chức phát hành. |
| 11 | listed_share_count | BIGINT | X |  |  |  | Khối lượng CK niêm yết. |
| 12 | maturity_dt | DATE | X |  |  |  | Ngày đáo hạn. |
| 13 | prior_price | DECIMAL(23,2) | X |  |  |  | Giá của phiên liền trước. |
| 14 | pt_match_price | DECIMAL(23,2) |  |  |  |  | Giá khớp thỏa thuận gần nhất. |
| 15 | pt_match_quantity | BIGINT |  |  |  |  | Khối lượng khớp thỏa thuận gần nhất. |
| 16 | pt_total_traded_quantity | BIGINT |  |  |  |  | Tổng khối lượng khớp thỏa thuận từ đầu ngày. |
| 17 | pt_total_traded_val | DECIMAL(23,2) |  |  |  |  | Tổng giá trị khớp thỏa thuận từ đầu ngày. |
| 18 | status_code | STRING | X |  |  |  | Trạng thái sự kiện quyền của CK. |
| 19 | stock_id | STRING | X |  |  |  | ID của chứng khoán trong hệ thống Sở. |
| 20 | stock_tp_code | STRING | X |  |  |  | Loại chứng khoán (ST/BO/MF/FU/OP/EF/W...). |
| 21 | total_bid_quantity | BIGINT |  |  |  |  | Tổng khối lượng đặt mua chưa khớp toàn bảng giá. |
| 22 | total_offer_quantity | BIGINT |  |  |  |  | Tổng khối lượng đặt bán chưa khớp toàn bảng giá. |
| 23 | total_listing_vol | BIGINT | X |  |  |  | Khối lượng CK niêm yết. |
| 24 | average_price | DECIMAL(23,2) |  |  |  |  | Giá khớp trung bình. |
| 25 | bid_price_1 | DECIMAL(23,2) |  |  |  |  | Giá mua top 1. |
| 26 | bid_price_2 | DECIMAL(23,2) |  |  |  |  | Giá mua top 2. |
| 27 | bid_price_3 | DECIMAL(23,2) |  |  |  |  | Giá mua top 3. |
| 28 | bid_vol_1 | BIGINT |  |  |  |  | Khối lượng (số lượng) cổ phiếu đang đặt chờ mua ở mức giá cao nhất (tốt nhất) hiện tại. |
| 29 | bid_vol_2 | BIGINT |  |  |  |  | Khối lượng (số lượng) cổ phiếu đang đặt chờ mua ở mức giá cao thứ 2 hiện tại. |
| 30 | bid_vol_3 | BIGINT |  |  |  |  | Khối lượng (số lượng) cổ phiếu đang đặt chờ mua ở mức giá cao thứ 3 hiện tại. |
| 31 | board_id | STRING | X |  |  |  | Board của mã CK (mặc định G1). |
| 32 | ceiling_price | DECIMAL(23,2) |  |  |  |  | Giá trần. |
| 33 | price_change | DECIMAL(23,2) |  |  |  |  | Thay đổi giữa giá khớp gần nhất và giá tham chiếu. |
| 34 | close_price | DECIMAL(23,2) |  |  |  |  | Giá đóng cửa. |
| 35 | close_vol | BIGINT |  |  |  |  | Khối lượng giao dịch phiên đóng cửa. |
| 36 | contract_multiplier | STRING | X |  |  |  | Hệ số nhân HĐTL. |
| 37 | coupon_rate | DECIMAL(8,5) | X |  |  |  | Lãi suất trái phiếu. |
| 38 | exercise_style_code | STRING | X |  |  |  | Kiểu thực hiện phái sinh: A/E/B/Z. |
| 39 | first_trading_dt | DATE | X |  |  |  | Ngày giao dịch đầu tiên — dành cho phái sinh/CW. |
| 40 | floor_price | DECIMAL(23,2) |  |  |  |  | Giá sàn. |
| 41 | foreign_buy_vol | BIGINT |  |  |  |  | Khối lượng NĐTNN mua. |
| 42 | foreign_buy_val | DECIMAL(23,2) |  |  |  |  | Giá trị NĐTNN mua. |
| 43 | foreign_remain_quantity | BIGINT |  |  |  |  | Số lượng chứng khoán còn lại mà nhà đầu tư nước ngoài được phép tiếp tục mua vào tại mã chứng khoán (phần room còn trống). |
| 44 | foreign_room_quantity | BIGINT |  |  |  |  | Tổng khối lượng chứng khoán tối đa mà nhà đầu tư nước ngoài được phép nắm giữ tại mã chứng khoán theo quy định pháp luật hoặc điều lệ công ty (tổng room). |
| 45 | foreign_sell_vol | BIGINT |  |  |  |  | Khối lượng NĐTNN bán. |
| 46 | foreign_sell_val | DECIMAL(23,2) |  |  |  |  | Giá trị NĐTNN bán. |
| 47 | high_price | DECIMAL(23,2) |  |  |  |  | Giá khớp cao nhất tính đến thời điểm. |
| 48 | issue_dt | DATE | X |  |  |  | Ngày phát hành. |
| 49 | jadapter_id | STRING | X |  |  |  | ID của mã do jadapter tự sinh. |
| 50 | last_color | STRING | X |  |  |  | Màu sắc thể hiện trạng thái tăng, giảm hoặc đứng giá của mức giá khớp lệnh gần đây nhất (Last Price) so với giá tham chiếu. |
| 51 | last_trading_dt | DATE | X |  |  |  | Ngày giao dịch cuối cùng — dành cho phái sinh/CW. |
| 52 | listing_dt | DATE | X |  |  |  | Ngày niêm yết sản phẩm phái sinh. |
| 53 | low_price | DECIMAL(23,2) |  |  |  |  | Giá khớp thấp nhất tính đến thời điểm. |
| 54 | exchange_code | STRING | X |  |  |  | Mã sàn theo Sở. |
| 55 | maturity_month_year | STRING | X |  |  |  | Năm tháng đáo hạn HĐTL. |
| 56 | offer_price_1 | DECIMAL(23,2) |  |  |  |  | Giá bán top 1. |
| 57 | offer_price_2 | DECIMAL(23,2) |  |  |  |  | Giá bán top 2. |
| 58 | offer_price_3 | DECIMAL(23,2) |  |  |  |  | Giá bán top 3. |
| 59 | offer_vol_1 | BIGINT |  |  |  |  | Khối lượng (số lượng) cổ phiếu đang đặt chờ bán ở mức giá thấp nhất (tốt nhất) hiện tại. |
| 60 | offer_vol_2 | BIGINT |  |  |  |  | Khối lượng (số lượng) cổ phiếu đang đặt chờ bán ở mức giá thấp thứ 2 hiện tại. |
| 61 | offer_vol_3 | BIGINT |  |  |  |  | Khối lượng (số lượng) cổ phiếu đang đặt chờ bán ở mức giá thấp thứ 3 hiện tại. |
| 62 | open_price | DECIMAL(23,2) |  |  |  |  | Giá mở cửa. |
| 63 | open_interest | BIGINT | X |  |  |  | Khối lượng mở (open interest) của phái sinh. |
| 64 | open_interest_change | BIGINT | X |  |  |  | Thay đổi khối lượng mở (open interest) của phái sinh. |
| 65 | price_one | DECIMAL(23,2) | X |  |  |  | Giá một (PRICEONE). |
| 66 | price_two | DECIMAL(23,2) | X |  |  |  | Giá hai (PRICETWO). |
| 67 | product_group_id | STRING | X |  |  |  | Mã sản phẩm của CK theo Sở. |
| 68 | product_id | STRING | X |  |  |  | Tag 20003 của Sở — xác định CK thuộc bộ sản phẩm nào. |
| 69 | put_or_call_code | STRING | X |  |  |  | Loại quyền phái sinh: P/C. |
| 70 | reference_price | DECIMAL(23,2) |  |  |  |  | Giá tham chiếu. |
| 71 | sequence | BIGINT |  |  |  |  | Số thứ tự cập nhật bản tin. |
| 72 | settlement_price | DECIMAL(23,2) | X |  |  |  | Giá tham chiếu cho ngày giao dịch tiếp theo của HĐTL. |
| 73 | ticker_symbol | STRING | X |  |  |  | Mã chứng khoán. |
| 74 | isin_code | STRING | X |  |  |  | Mã ISIN của CK. |
| 75 | symbol_status_code | STRING | X |  |  |  | Trạng thái mã CK. |
| 76 | total_buy_vol | BIGINT | X |  |  |  | Tổng khối lượng mua đã khớp. |
| 77 | total_sell_vol | BIGINT | X |  |  |  | Tổng khối lượng bán đã khớp. |
| 78 | total_trading_vol | BIGINT |  |  |  |  | Tổng khối lượng khớp từ đầu ngày. |
| 79 | total_trading_val | DECIMAL(23,2) |  |  |  |  | Tổng giá trị khớp từ đầu ngày. |
| 80 | trading_session_status_code | STRING | X |  |  |  | Trạng thái phiên tại thời điểm chụp. |
| 81 | trading_time | STRING | X |  |  |  | Thời gian ghi nhận snapshot. |
| 82 | trading_dt | DATE | X |  |  |  | Ngày giao dịch format dd/mm/yyyy. ETL cần parse sang Date. |
| 83 | underlying_symbol | STRING | X |  |  |  | Chứng khoán cơ sở — dành cho CW/phái sinh. |
| 84 | yield | DECIMAL(8,5) | X |  |  |  | YTM (Yield to Maturity). |
| 85 | vol_weighted_average_price | BIGINT | X |  |  |  | Giá bình quân gia quyền theo khối lượng (VWAP). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| security_trading_snpst_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Stored Procedure/Function

N/A

### Package

N/A
