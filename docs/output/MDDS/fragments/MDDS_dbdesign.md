## MDDS — Hệ thống dữ liệu giao dịch thị trường từ các SGDCK

### Các mô hình quan hệ dữ liệu

![Mô hình quan hệ dữ liệu MDDS](MDDS/fragments/MDDS_diagram.png)

**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | corp_bond_mtch_log | Log tick-by-tick từng lần khớp lệnh trái phiếu doanh nghiệp theo thứ tự ConfirmNoCorpBond. Grain: 1 dòng = 1 lần khớp (symbol × ngày × confirm_no). Insert-only. |
| 2 | scr_mtch_log | Log tick-by-tick từng lần khớp lệnh chứng khoán theo thứ tự sequenceMsg. Grain: 1 dòng = 1 lần khớp (symbol × ngày × sequenceMsg). Insert-only. Chứa chiều giao dịch chủ động (lastColor) và tích lũy KL/GT từ đầu ngày. |
| 3 | corp_bond_tdg_snpst | Snapshot trạng thái giao dịch trái phiếu doanh nghiệp niêm yết HNX tại thời điểm phát sinh thay đổi: giá tham chiếu/trần/sàn/khớp |
| 4 | indx_constituent_snpst | Snapshot thành phần rổ chỉ số thị trường: mã chứng khoán thuộc rổ nào (IndexCode × Symbol × ngày giao dịch). Có attribute nghiệp vụ: tỷ trọng (Weighted) và ngày vào rổ (AddDate). |
| 5 | mkt_indx_snpst | Snapshot thông tin chỉ số thị trường chứng khoán (VN30/VNINDEX/HNX30...) tại thời điểm phát sinh: giá trị chỉ số |
| 6 | mkt_snpst | Snapshot trạng thái tổng hợp toàn sàn giao dịch (HOSE/HNX/UPCOM) tại mỗi thời điểm: điểm chỉ số sàn |
| 7 | scr_tdg_snpst | Snapshot trạng thái giao dịch đa loại chứng khoán (cổ phiếu/CCQ/chứng quyền/phái sinh) tại thời điểm có thay đổi lệnh/khớp lệnh: giá tham chiếu/trần/sàn |




### Bảng corp_bond_mtch_log



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | corp_bond_mtch_log_id | STRING |  | X | P |  | Khóa đại diện cho bản ghi khớp lệnh trái phiếu doanh nghiệp. |
| 2 | corp_bond_mtch_log_code | STRING |  |  |  |  | Định danh duy nhất bản tin (GUID). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'MDDS.CorpBondMatch' | Mã nguồn dữ liệu. |
| 4 | corp_bond_tdg_snpst_id | STRING |  |  | F |  | FK đến bản tin thông tin giao dịch trái phiếu doanh nghiệp tương ứng. |
| 5 | symb | STRING |  |  |  |  | Mã trái phiếu doanh nghiệp. BK. |
| 6 | tdg_dt | DATE |  |  |  |  | Ngày giao dịch. BK. |
| 7 | cfrm_no | INT |  |  |  |  | Số xác nhận/số thứ tự giao dịch TPDN (thay cho sequenceMsg trong TransLog). BK. |
| 8 | mtch_tm | STRING | X |  |  |  | Giờ khớp lệnh (HH:mm:ss). |
| 9 | mtch_drc_code | STRING | X |  |  |  | Chiều giao dịch chủ động: B=Mua chủ động / S=Bán chủ động / O=ATO / C=ATC. |
| 10 | mtch_prc | DECIMAL(23,2) | X |  |  |  | Giá khớp (thường theo % mệnh giá nhân mệnh giá cho TPDN). |
| 11 | mtch_vol | INT | X |  |  |  | Khối lượng khớp của lần khớp này. |
| 12 | prc_chg_val | DECIMAL(23,2) | X |  |  |  | Thay đổi so với giá tham chiếu tại thời điểm khớp. |
| 13 | chg_color | STRING | X |  |  |  | Style hiển thị của giá thay đổi. |
| 14 | acm_vol | INT | X |  |  |  | Tổng khối lượng khớp tích lũy từ đầu ngày. |
| 15 | acm_val | DECIMAL(23,2) | X |  |  |  | Tổng giá trị khớp tích lũy từ đầu ngày (VND). |
| 16 | tot_buy_vol | INT | X |  |  |  | Tổng khối lượng mua chủ động (lastColor=B) tích lũy trong ngày. |
| 17 | tot_sell_vol | INT | X |  |  |  | Tổng khối lượng bán chủ động (lastColor=S) tích lũy trong ngày. |
| 18 | mkt_id | STRING |  |  |  | '06' | ID thị trường — luôn = 06 (trái phiếu doanh nghiệp HNX). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| corp_bond_mtch_log_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| corp_bond_tdg_snpst_id | corp_bond_tdg_snpst | corp_bond_tdg_snpst_id |



#### Index

N/A

#### Trigger

N/A




### Bảng scr_mtch_log



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_mtch_log_id | STRING |  | X | P |  | Khóa đại diện cho bản ghi khớp lệnh chứng khoán. |
| 2 | scr_mtch_log_code | STRING |  |  |  |  | Định danh duy nhất bản tin (GUID). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'MDDS.TransLog' | Mã nguồn dữ liệu. |
| 4 | scr_tdg_snpst_id | STRING |  |  | F |  | FK đến bản tin thông tin giao dịch chứng khoán tương ứng. |
| 5 | symb | STRING |  |  |  |  | Mã chứng khoán. BK. |
| 6 | tdg_dt | DATE |  |  |  |  | Ngày giao dịch. BK. |
| 7 | seq_msg | INT |  |  |  |  | Số thứ tự tăng dần trong ngày — đảm bảo thứ tự xử lý và phát hiện mất gói. BK. |
| 8 | mtch_tm | STRING | X |  |  |  | Giờ khớp lệnh (HH:mm:ss) theo giờ máy chủ sở giao dịch. Nhiều tick có thể cùng timestamp trong ATO/ATC (batch matching). |
| 9 | mtch_drc_code | STRING | X |  |  |  | Chiều giao dịch chủ động: B=Mua chủ động / S=Bán chủ động / O=Khớp phiên ATO / C=Khớp phiên ATC. B/S trong MDDS là chiều của bên đặt lệnh đối ứng — ngược với hiển thị bảng giá thông thường. |
| 10 | mtch_prc | DECIMAL(23,2) | X |  |  |  | Giá khớp lệnh (VND — số nguyên không có dấu phẩy). |
| 11 | mtch_vol | INT | X |  |  |  | Khối lượng khớp của lần khớp này. |
| 12 | prc_chg_val | DECIMAL(23,2) | X |  |  |  | Thay đổi của giá khớp so với giá tham chiếu tại thời điểm khớp (+/-). |
| 13 | chg_color | STRING | X |  |  |  | Style hiển thị của giá thay đổi (tăng/giảm/đứng). |
| 14 | acm_vol | INT | X |  |  |  | Tổng khối lượng khớp tích lũy từ đầu ngày đến thời điểm này (cho mã đó). |
| 15 | acm_val | DECIMAL(23,2) | X |  |  |  | Tổng giá trị khớp tích lũy từ đầu ngày đến thời điểm này (VND). formattedAccVal / formattedAccVol = VWAP tại thời điểm. |
| 16 | tot_buy_vol | INT | X |  |  |  | Tổng khối lượng mua chủ động (lastColor=B) tích lũy trong ngày cho mã đó. |
| 17 | tot_sell_vol | INT | X |  |  |  | Tổng khối lượng bán chủ động (lastColor=S) tích lũy trong ngày cho mã đó. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_mtch_log_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| scr_tdg_snpst_id | scr_tdg_snpst | scr_tdg_snpst_id |



#### Index

N/A

#### Trigger

N/A




### Bảng corp_bond_tdg_snpst



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | corp_bond_tdg_snpst_id | STRING |  | X | P |  | Khóa đại diện cho bản tin thông tin giao dịch trái phiếu doanh nghiệp. |
| 2 | corp_bond_tdg_snpst_code | STRING |  |  |  |  | Định danh duy nhất bản tin (GUID). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'MDDS.CorpBondInfor' | Mã nguồn dữ liệu. |
| 4 | symb | STRING |  |  |  |  | Mã trái phiếu doanh nghiệp (ví dụ: BHB12104). BK. |
| 5 | tdg_dt | DATE |  |  |  |  | Ngày giao dịch (dd/mm/yyyy). BK. |
| 6 | full_nm | STRING | X |  |  |  | Tên đầy đủ của trái phiếu. |
| 7 | flr_code | STRING |  |  |  | '06' | Mã sàn giao dịch — luôn = 06 (thị trường trái phiếu doanh nghiệp HNX). |
| 8 | stk_tp_code | STRING |  |  |  | '12' | Loại chứng khoán — luôn = 12 cho TPDN. |
| 9 | tdg_ssn_id | STRING | X |  |  |  | Mã trạng thái giao dịch theo quy định kết cấu phiên HNX. |
| 10 | scr_tdg_st_code | STRING | X |  |  |  | Trạng thái trái phiếu: 0=Bình thường / 1=Tạm ngừng nghỉ lễ / 2=Ngừng GD / 10=Tạm ngừng GD / 11=Hạn chế GD / 25=GD đặc biệt. |
| 11 | tdg_ssn_st_code | STRING | X |  |  |  | Trạng thái phiên giao dịch: 1=Đang nhận lệnh / 2=Tạm dừng / 13=Kết thúc nhận lệnh / 90=Chờ nhận lệnh / 97=Đóng cửa. |
| 12 | ceiling_prc | DECIMAL(23,2) | X |  |  |  | Giá trần giao dịch khớp lệnh. |
| 13 | flr_prc | DECIMAL(23,2) | X |  |  |  | Giá sàn giao dịch khớp lệnh. |
| 14 | refr_prc | DECIMAL(23,2) | X |  |  |  | Giá tham chiếu. |
| 15 | cls_prc | DECIMAL(23,2) | X |  |  |  | Giá đóng cửa (giá khớp gần nhất). |
| 16 | cls_vol | INT | X |  |  |  | Khối lượng khớp tại lần khớp gần nhất. |
| 17 | prc_chg_val | DECIMAL(23,2) | X |  |  |  | Thay đổi của giá khớp gần nhất so với giá tham chiếu. |
| 18 | opn_prc | DECIMAL(23,2) | X |  |  |  | Giá mở cửa. |
| 19 | high_prc | DECIMAL(23,2) | X |  |  |  | Giá thực hiện cao nhất của giao dịch khớp lệnh trong ngày. |
| 20 | low_prc | DECIMAL(23,2) | X |  |  |  | Giá thực hiện thấp nhất của giao dịch khớp lệnh trong ngày. |
| 21 | av_prc | DECIMAL(23,2) | X |  |  |  | Giá trung bình trong ngày (totalTradingValue / totalTrading). |
| 22 | tot_mtch_vol | INT | X |  |  |  | Tổng khối lượng giao dịch tích lũy. |
| 23 | tot_mtch_val | DECIMAL(23,2) | X |  |  |  | Tổng giá trị giao dịch tích lũy. |
| 24 | pt_mtch_vol | INT | X |  |  |  | Khối lượng thực hiện gần nhất của giao dịch thỏa thuận Outright. |
| 25 | pt_mtch_prc | DECIMAL(23,2) | X |  |  |  | Giá thực hiện gần nhất của giao dịch thỏa thuận Outright. |
| 26 | pt_tot_mtch_vol | INT | X |  |  |  | Tổng khối lượng giao dịch thỏa thuận Outright tích lũy. |
| 27 | pt_tot_mtch_val | DECIMAL(23,2) | X |  |  |  | Tổng giá trị giao dịch thỏa thuận Outright tích lũy. |
| 28 | pt_best_bid_vol | INT | X |  |  |  | Tổng khối lượng chào mua cao nhất trên order book thỏa thuận Outright. |
| 29 | pt_best_bid_prc | DECIMAL(23,2) | X |  |  |  | Giá chào mua cao nhất trên order book thỏa thuận Outright. |
| 30 | pt_best_ofr_vol | INT | X |  |  |  | Tổng khối lượng chào bán thấp nhất trên order book thỏa thuận Outright. |
| 31 | pt_best_ofr_prc | DECIMAL(23,2) | X |  |  |  | Giá chào bán thấp nhất trên order book thỏa thuận Outright. |
| 32 | pt_tot_bid_vol | INT | X |  |  |  | Tổng khối lượng chào mua toàn bộ order book thỏa thuận Outright. |
| 33 | pt_tot_ofr_vol | INT | X |  |  |  | Tổng khối lượng chào bán toàn bộ order book thỏa thuận Outright. |
| 34 | pt_max_vol | INT | X |  |  |  | Tổng khối lượng thực hiện tương ứng với giá cao nhất — giao dịch thỏa thuận Outright. |
| 35 | pt_max_prc | DECIMAL(23,2) | X |  |  |  | Giá thực hiện cao nhất — giao dịch thỏa thuận Outright. |
| 36 | pt_min_vol | INT | X |  |  |  | Tổng khối lượng thực hiện tương ứng với giá thấp nhất — giao dịch thỏa thuận Outright. |
| 37 | pt_min_prc | DECIMAL(23,2) | X |  |  |  | Giá thực hiện thấp nhất — giao dịch thỏa thuận Outright. |
| 38 | frgn_rman_room | INT | X |  |  |  | Số lượng còn lại nhà đầu tư nước ngoài được phép mua. |
| 39 | issur_nm | STRING | X |  | F |  | Mã tổ chức phát hành trái phiếu. |
| 40 | mat_dt | DATE | X |  |  |  | Ngày đáo hạn trái phiếu. |
| 41 | issu_dt | DATE | X |  |  |  | Ngày phát hành trái phiếu. |
| 42 | tot_listing_vol | INT | X |  |  |  | Tổng khối lượng trái phiếu niêm yết. |
| 43 | par_val | DECIMAL(23,2) | X |  |  |  | Mệnh giá trái phiếu (thường 100.000 VND/trái phiếu). |
| 44 | bond_prd | INT | X |  |  |  | Kỳ hạn gốc của trái phiếu. |
| 45 | prd_unit_code | STRING | X |  |  |  | Đơn vị kỳ hạn: 1=Ngày / 2=Tuần / 3=Tháng / 4=Năm. |
| 46 | prd_rman | INT | X |  |  |  | Kỳ hạn còn lại tính bằng ngày (tính toán lại hàng ngày). |
| 47 | bond_int_tp_code | STRING | X |  |  |  | Loại hình lãi suất: 1=Coupon / 2=Zero Coupon. |
| 48 | int_rate | DECIMAL(8,5) | X |  |  |  | Lãi suất danh nghĩa (coupon rate). |
| 49 | dbt_int_tp_code | STRING | X |  |  |  | Loại lãi suất: 1=Cố định / 2=Thả nổi. |
| 50 | int_prd | INT | X |  |  |  | Kỳ hạn trả lãi. |
| 51 | int_prd_unit_code | STRING | X |  |  |  | Đơn vị kỳ hạn trả lãi: 1=Ngày / 2=Tuần / 3=Tháng / 4=Năm. |
| 52 | int_cpn_tp_code | STRING | X |  |  |  | Kiểu coupon: 1=Standard / 2=Long Coupon / 3=Short Coupon / 4=Khác. |
| 53 | int_pymt_tp_code | STRING | X |  |  |  | Phương thức trả lãi: 1=Định kỳ cuối kỳ / 2=Định kỳ đầu kỳ. |
| 54 | char | STRING | X |  |  |  | Đặc điểm của trái phiếu. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| corp_bond_tdg_snpst_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng indx_constituent_snpst



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | indx_constituent_snpst_id | STRING |  | X | P |  | Khóa đại diện cho bản ghi thành phần rổ chỉ số. |
| 2 | indx_constituent_snpst_code | STRING |  |  |  |  | Định danh duy nhất bản tin (GUID). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'MDDS.CSIDXInfor' | Mã nguồn dữ liệu. |
| 4 | mkt_indx_snpst_id | STRING |  |  | F |  | FK đến bản tin thông tin chỉ số tương ứng. |
| 5 | indx_code | STRING |  |  |  |  | Mã chỉ số (VN30 / HNX30 / VNFINSELECT...). BK. |
| 6 | scr_tdg_snpst_id | STRING |  |  | F |  | FK đến bản tin thông tin giao dịch chứng khoán thành viên. |
| 7 | symb | STRING |  |  |  |  | Mã chứng khoán thành viên trong rổ chỉ số. BK. |
| 8 | snpst_tm | STRING |  |  |  |  | Thời điểm snapshot trong ngày. BK. Nguồn ghi là TradingDate nhưng tài liệu gốc mô tả "định dạng HHmmss" — ngữ nghĩa là timestamp nội ngày, không phải ngày giao dịch. Cần xác nhận lại với đội nguồn. |
| 9 | flr_code | STRING | X |  |  |  | Mã sàn giao dịch của mã chứng khoán. |
| 10 | indx_id | STRING | X |  |  |  | ID số của sàn giao dịch. |
| 11 | wght | DECIMAL(5,2) | X |  |  |  | Tỷ trọng (weight) của mã trong rổ chỉ số (dạng thập phân — ví dụ 0.0513 = 5.13%). |
| 12 | add_dt | DATE | X |  |  |  | Ngày mã được thêm vào rổ chỉ số. |
| 13 | stk_ctb | DECIMAL(23,2) | X |  |  |  | Giá trị chỉ số tại thời điểm hiện tại (dùng để tính index contribution). |
| 14 | tot_mtch_vol | INT | X |  |  |  | Tổng khối lượng khớp lệnh của mã này trong ngày (lô chẵn). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| indx_constituent_snpst_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| mkt_indx_snpst_id | mkt_indx_snpst | mkt_indx_snpst_id |
| scr_tdg_snpst_id | scr_tdg_snpst | scr_tdg_snpst_id |



#### Index

N/A

#### Trigger

N/A




### Bảng mkt_indx_snpst



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mkt_indx_snpst_id | STRING |  | X | P |  | Khóa đại diện cho bản tin thông tin chỉ số thị trường. |
| 2 | mkt_indx_snpst_code | STRING |  |  |  |  | Định danh duy nhất bản tin (GUID). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'MDDS.IDXInfor' | Mã nguồn dữ liệu. |
| 4 | indx_code | STRING |  |  |  |  | Mã chỉ số (VNINDEX / HNXINDEX / VN30 / HNX30 / UPCOMINDEX...). BK. |
| 5 | tdg_dt | DATE |  |  |  |  | Ngày giao dịch. BK. |
| 6 | udt_tm | STRING |  |  |  |  | Thời gian cập nhật theo giờ máy chủ. BK. |
| 7 | indx_nm | STRING | X |  |  |  | Tên đầy đủ của chỉ số. |
| 8 | flr_code | STRING | X |  |  |  | Mã sàn giao dịch của chỉ số. |
| 9 | indx_tp_code | STRING | X |  |  |  | Loại chỉ số: 0=Toàn thị trường / 1=Bảng giao dịch / 2=Phức hợp / 3=Ngành / 4=Top ranking. |
| 10 | crn_st_code | STRING | X |  |  |  | Trạng thái chỉ số (=1 bình thường). |
| 11 | indx_id | STRING | X |  |  |  | ID số của sàn giao dịch. |
| 12 | indx_val | DECIMAL(23,2) | X |  |  |  | Giá trị chỉ số hiện tại. |
| 13 | prev_indx_val | DECIMAL(23,2) | X |  |  |  | Giá trị chỉ số tham chiếu (đóng cửa phiên gần nhất). |
| 14 | high_indx_val | DECIMAL(23,2) | X |  |  |  | Giá trị chỉ số cao nhất trong ngày. |
| 15 | lws_indx_val | DECIMAL(23,2) | X |  |  |  | Giá trị chỉ số thấp nhất trong ngày. |
| 16 | cls_indx_val | DECIMAL(23,2) | X |  |  |  | Giá trị chỉ số đóng cửa (cập nhật sau khi kết thúc phiên). |
| 17 | indx_chg_val | DECIMAL(23,2) | X |  |  |  | Thay đổi giá trị chỉ số so với phiên trước (tuyệt đối). |
| 18 | indx_chg_rto | DECIMAL(5,2) | X |  |  |  | Tỷ lệ phần trăm thay đổi so với phiên trước. |
| 19 | tot_mtch_vol | INT | X |  |  |  | Tổng khối lượng khớp lệnh thường (lô chẵn) tích lũy. |
| 20 | tot_mtch_val | DECIMAL(23,2) | X |  |  |  | Tổng giá trị khớp lệnh thường (lô chẵn) tích lũy. |
| 21 | pt_tot_vol | INT | X |  |  |  | Tổng khối lượng khớp lệnh thỏa thuận tích lũy. |
| 22 | pt_tval | DECIMAL(23,2) | X |  |  |  | Tổng giá trị khớp lệnh thỏa thuận tích lũy. |
| 23 | tot_stk_cnt | INT | X |  |  |  | Tổng số mã chứng khoán trong rổ tính chỉ số. |
| 24 | advnc_cnt | INT | X |  |  |  | Tổng số mã chứng khoán tăng giá trong rổ. |
| 25 | decline_cnt | INT | X |  |  |  | Tổng số mã chứng khoán giảm giá trong rổ. |
| 26 | no_chg_cnt | INT | X |  |  |  | Tổng số mã chứng khoán đứng giá trong rổ. |
| 27 | ceiling_cnt | INT | X |  |  |  | Tổng số mã chứng khoán tăng trần trong rổ. |
| 28 | flr_lmt_cnt | INT | X |  |  |  | Tổng số mã chứng khoán giảm sàn trong rổ. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_indx_snpst_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng mkt_snpst



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | mkt_snpst_id | STRING |  | X | P |  | Khóa đại diện cho bản tin tổng quan thị trường. |
| 2 | mkt_snpst_code | STRING |  |  |  |  | Định danh duy nhất bản tin (GUID). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'MDDS.MarketInfor' | Mã nguồn dữ liệu. |
| 4 | mkt_id | STRING |  |  |  |  | ID sàn/chỉ số: 10=HOSE / 02=HNX / 04=UPCOM / 06=Corp Bond / VN30 / HNX30... BK. |
| 5 | mkt_code | STRING | X |  |  |  | Mã chỉ số tương ứng với marketId. |
| 6 | tdg_dt | DATE |  |  |  |  | Ngày giao dịch. |
| 7 | seq_msg | INT |  |  |  |  | Số thứ tự tăng dần trong ngày — đảm bảo thứ tự xử lý bản tin. |
| 8 | indx_tm | STRING | X |  |  |  | Thời gian cập nhật chỉ số. |
| 9 | mkt_st_code | STRING | X |  |  |  | Trạng thái phiên giao dịch (ATO / Continuous / ATC / Closed...). |
| 10 | mkt_indx_val | DECIMAL(23,2) | X |  |  |  | Điểm chỉ số thị trường hiện tại. |
| 11 | indx_chg_val | DECIMAL(23,2) | X |  |  |  | Thay đổi điểm chỉ số so với đầu ngày (tham chiếu). |
| 12 | indx_chg_pct | DECIMAL(5,2) | X |  |  |  | Phần trăm thay đổi điểm chỉ số so với đầu ngày. |
| 13 | indx_color | STRING | X |  |  |  | Màu hiển thị chỉ số (tăng/giảm/đứng). |
| 14 | prev_mkt_indx_val | DECIMAL(23,2) | X |  |  |  | Chỉ số tham chiếu — giá trị đóng cửa phiên giao dịch gần nhất. |
| 15 | av_mkt_indx_val | DECIMAL(23,2) | X |  |  |  | Chỉ số trung bình của thị trường trong phiên. |
| 16 | av_prev_mkt_indx_val | DECIMAL(23,2) | X |  |  |  | Chỉ số trung bình đóng cửa phiên giao dịch gần nhất. |
| 17 | av_indx_chg_val | DECIMAL(23,2) | X |  |  |  | Thay đổi của chỉ số trung bình. |
| 18 | av_indx_chg_pct | DECIMAL(5,2) | X |  |  |  | Phần trăm thay đổi của chỉ số trung bình. |
| 19 | tot_mtch_trd_cnt | INT | X |  |  |  | Tổng số lệnh khớp (FloorCode=02: cổ phiếu; FloorCode=03: trái phiếu). |
| 20 | tot_mtch_vol | INT | X |  |  |  | Tổng khối lượng khớp lệnh thường toàn thị trường. |
| 21 | tot_mtch_val | DECIMAL(23,2) | X |  |  |  | Tổng giá trị khớp lệnh thường toàn thị trường. |
| 22 | advnc_cnt | INT | X |  |  |  | Số mã tăng giá. |
| 23 | decline_cnt | INT | X |  |  |  | Số mã giảm giá. |
| 24 | no_chg_cnt | INT | X |  |  |  | Số mã không đổi giá. |
| 25 | advnc_vol | INT | X |  |  |  | Tổng khối lượng chứng khoán tăng giá (bao gồm giao dịch thỏa thuận). |
| 26 | decline_vol | INT | X |  |  |  | Tổng khối lượng chứng khoán giảm giá (bao gồm giao dịch thỏa thuận). |
| 27 | no_chg_vol | INT | X |  |  |  | Tổng khối lượng chứng khoán đứng giá (bao gồm giao dịch thỏa thuận). |
| 28 | ceiling_cnt | INT | X |  |  |  | Số mã tăng trần. |
| 29 | flr_cnt | INT | X |  |  |  | Số mã giảm sàn. |
| 30 | pt_tot_trd_cnt | INT | X |  |  |  | Tổng số lệnh giao dịch thỏa thuận. |
| 31 | pt_tot_vol | INT | X |  |  |  | Tổng khối lượng giao dịch thỏa thuận. |
| 32 | pt_tval | DECIMAL(23,2) | X |  |  |  | Tổng giá trị giao dịch thỏa thuận. |
| 33 | odd_lot_tot_vol | INT | X |  |  |  | Tổng khối lượng giao dịch lô lẻ. |
| 34 | odd_lot_tval | DECIMAL(23,2) | X |  |  |  | Tổng giá trị giao dịch lô lẻ. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_snpst_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng scr_tdg_snpst



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_tdg_snpst_id | STRING |  | X | P |  | Khóa đại diện cho bản tin thông tin giao dịch chứng khoán. |
| 2 | scr_tdg_snpst_code | STRING |  |  |  |  | Định danh duy nhất bản tin (GUID). BK. |
| 3 | src_stm_code | STRING |  |  |  | 'MDDS.StockInfor' | Mã nguồn dữ liệu. |
| 4 | symb | STRING |  |  |  |  | Mã chứng khoán (VCB / HPG / VNM...). BK. |
| 5 | tdg_dt | DATE |  |  |  |  | Ngày giao dịch (dd/mm/yyyy). BK. |
| 6 | stk_id | STRING | X |  |  |  | ID nội bộ duy nhất của chứng khoán trong hệ thống MDDS. |
| 7 | full_nm | STRING | X |  |  |  | Tên đầy đủ của chứng khoán. |
| 8 | flr_code | STRING |  |  |  |  | Mã sàn giao dịch: 02=HNX / 04=UPCOM / 10=HOSE / 03=FDS (phái sinh) / 06=Corp Bond. |
| 9 | stk_tp_code | STRING | X |  |  |  | Loại chứng khoán theo sàn. HNX: BO/ST/MF/FU/OP/EF. HOSE: B=Trái phiếu / S=Cổ phiếu / U/E=CCQ / D=TP chuyển đổi / W=Chứng quyền. Parse kết hợp FloorCode. |
| 10 | tdg_ssn_id | STRING | X |  |  |  | Mã phiên giao dịch (ATO / Continuous / ATC...). |
| 11 | ceiling_prc | DECIMAL(23,2) | X |  |  |  | Giá trần trong ngày. |
| 12 | flr_prc | DECIMAL(23,2) | X |  |  |  | Giá sàn trong ngày. |
| 13 | refr_prc | DECIMAL(23,2) | X |  |  |  | Giá tham chiếu trong ngày. |
| 14 | cls_prc | DECIMAL(23,2) | X |  |  |  | Giá khớp lệnh gần nhất (giá thị trường hiện tại). |
| 15 | cls_vol | INT | X |  |  |  | Khối lượng khớp tại lần khớp gần nhất. |
| 16 | prc_chg_val | DECIMAL(23,2) | X |  |  |  | Thay đổi của giá khớp gần nhất so với giá tham chiếu (+/-). |
| 17 | prev_prc | DECIMAL(23,2) | X |  |  |  | Giá khớp gần nhất (trước lần cập nhật hiện tại). |
| 18 | opn_prc | DECIMAL(23,2) | X |  |  |  | Giá mở cửa (giá khớp ATO). |
| 19 | high_prc | DECIMAL(23,2) | X |  |  |  | Giá cao nhất trong ngày. |
| 20 | low_prc | DECIMAL(23,2) | X |  |  |  | Giá thấp nhất trong ngày. |
| 21 | av_prc | DECIMAL(23,2) | X |  |  |  | Giá trung bình (VWAP) trong ngày. |
| 22 | bid_prc_1 | DECIMAL(23,2) | X |  |  |  | Giá mua bước 1 (tốt nhất). |
| 23 | bid_vol_1 | INT | X |  |  |  | Khối lượng mua tại bước giá 1. |
| 24 | bid_prc_2 | DECIMAL(23,2) | X |  |  |  | Giá mua bước 2. |
| 25 | bid_vol_2 | INT | X |  |  |  | Khối lượng mua tại bước giá 2. |
| 26 | bid_prc_3 | DECIMAL(23,2) | X |  |  |  | Giá mua bước 3 (xa nhất). |
| 27 | bid_vol_3 | INT | X |  |  |  | Khối lượng mua tại bước giá 3. |
| 28 | ofr_prc_1 | DECIMAL(23,2) | X |  |  |  | Giá bán bước 1 (tốt nhất). |
| 29 | ofr_vol_1 | INT | X |  |  |  | Khối lượng bán tại bước giá 1. |
| 30 | ofr_prc_2 | DECIMAL(23,2) | X |  |  |  | Giá bán bước 2. |
| 31 | ofr_vol_2 | INT | X |  |  |  | Khối lượng bán tại bước giá 2. |
| 32 | ofr_prc_3 | DECIMAL(23,2) | X |  |  |  | Giá bán bước 3 (xa nhất). |
| 33 | ofr_vol_3 | INT | X |  |  |  | Khối lượng bán tại bước giá 3. |
| 34 | tot_bid_vol | INT | X |  |  |  | Tổng khối lượng chào mua cộng dồn. |
| 35 | tot_ofr_vol | INT | X |  |  |  | Tổng khối lượng chào bán cộng dồn. |
| 36 | tot_mtch_vol | INT | X |  |  |  | Tổng khối lượng khớp lệnh tích lũy từ đầu ngày. |
| 37 | tot_mtch_val | DECIMAL(23,2) | X |  |  |  | Tổng giá trị khớp lệnh tích lũy từ đầu ngày. |
| 38 | pt_mtch_vol | INT | X |  |  |  | Tổng khối lượng giao dịch thông thường (không tính thỏa thuận). |
| 39 | pt_mtch_prc | DECIMAL(23,2) | X |  |  |  | Giá thực hiện của lệnh thỏa thuận hiện thời. |
| 40 | pt_tot_mtch_vol | INT | X |  |  |  | Tổng khối lượng giao dịch thỏa thuận tích lũy. |
| 41 | pt_tot_mtch_val | DECIMAL(23,2) | X |  |  |  | Tổng giá trị giao dịch thỏa thuận tích lũy. |
| 42 | frgn_buy_vol | INT | X |  |  |  | Tổng khối lượng mua của nhà đầu tư nước ngoài. |
| 43 | frgn_sell_vol | INT | X |  |  |  | Tổng khối lượng bán của nhà đầu tư nước ngoài. |
| 44 | frgn_rman_room | INT | X |  |  |  | Số lượng còn lại nhà đầu tư nước ngoài được phép mua (cập nhật sau mỗi giao dịch NĐTNN). |
| 45 | frgn_tot_room | INT | X |  |  |  | Tổng room nhà đầu tư nước ngoài được phép mua. |
| 46 | refr_prc_1 | DECIMAL(23,2) | X |  |  |  | Giá tham chiếu phụ 1 (dùng nội bộ bảng giá). |
| 47 | refr_prc_2 | DECIMAL(23,2) | X |  |  |  | Giá tham chiếu phụ 2 (dùng nội bộ bảng giá). |
| 48 | tot_listing_vol | INT | X |  |  |  | Tổng khối lượng niêm yết — dùng cho HNX/UPCOM. |
| 49 | fnd_tp | STRING | X |  |  |  | Loại chứng khoán theo nguyên văn sở trả về (chưa convert). |
| 50 | hnx_listing_st_code | STRING | X |  |  |  | Trạng thái niêm yết HNX/UPCOM: parse từ Status (vị trí 1) — chỉ áp dụng FloorCode=02/04. |
| 51 | hnx_adj_vol | STRING | X |  |  |  | Điều chỉnh khối lượng HNX/UPCOM: parse từ Status (vị trí 2) — chỉ áp dụng FloorCode=02/04. |
| 52 | hnx_refr_st_code | STRING | X |  |  |  | Trạng thái tham chiếu HNX/UPCOM: parse từ Status (vị trí 3) — chỉ áp dụng FloorCode=02/04. |
| 53 | hnx_adj_rate | STRING | X |  |  |  | Tỷ lệ điều chỉnh HNX/UPCOM: parse từ Status (vị trí 4) — chỉ áp dụng FloorCode=02/04. |
| 54 | hnx_dvdn_rate | STRING | X |  |  |  | Tỷ lệ cổ tức HNX/UPCOM: parse từ Status (vị trí 5) — chỉ áp dụng FloorCode=02/04. |
| 55 | hnx_st | STRING | X |  |  |  | Trạng thái tổng hợp HNX/UPCOM: parse từ Status (vị trí 6) — chỉ áp dụng FloorCode=02/04. |
| 56 | hose_delist_f | STRING | X |  |  |  | Cờ hủy niêm yết HOSE: parse từ Status (vị trí 1) — chỉ áp dụng FloorCode=10. |
| 57 | hose_susp_f | STRING | X |  |  |  | Cờ đình chỉ giao dịch HOSE: parse từ Status (vị trí 2) — chỉ áp dụng FloorCode=10. |
| 58 | hose_halt_resume_f | STRING | X |  |  |  | Cờ tạm ngừng/khôi phục HOSE: parse từ Status (vị trí 3) — chỉ áp dụng FloorCode=10. |
| 59 | hose_split_f | STRING | X |  |  |  | Cờ chia tách HOSE: parse từ Status (vị trí 4) — chỉ áp dụng FloorCode=10. |
| 60 | hose_bnft_f | STRING | X |  |  |  | Cờ quyền lợi HOSE: parse từ Status (vị trí 5) — chỉ áp dụng FloorCode=10. |
| 61 | hose_mtg_f | STRING | X |  |  |  | Cờ đại hội cổ đông HOSE: parse từ Status (vị trí 6) — chỉ áp dụng FloorCode=10. |
| 62 | hose_ntc_f | STRING | X |  |  |  | Cờ thông báo HOSE: parse từ Status (vị trí 7) — chỉ áp dụng FloorCode=10. |
| 63 | hose_odd_lot_halt_resume_f | STRING | X |  |  |  | Cờ tạm ngừng/khôi phục lô lẻ HOSE: parse từ Status (vị trí 8) — chỉ áp dụng FloorCode=10. |
| 64 | ulyg_imt_id | STRING | X |  | F |  | FK đến Security Trading Snapshot của tài sản cơ sở — dùng cho phái sinh và chứng quyền. |
| 65 | ulyg_symb | STRING | X |  | F |  | Mã tài sản cơ sở (VN30...) — dùng cho phái sinh và chứng quyền. |
| 66 | opn_int | INT | X |  |  |  | Khối lượng hợp đồng mở (Open Interest) — chỉ dùng cho phái sinh. |
| 67 | opn_int_chg | INT | X |  |  |  | Thay đổi khối lượng hợp đồng mở so với phiên trước. |
| 68 | frst_tdg_dt | DATE | X |  |  |  | Ngày giao dịch đầu tiên — dùng cho phái sinh và chứng quyền. |
| 69 | last_tdg_dt | DATE | X |  |  |  | Ngày giao dịch cuối cùng — dùng cho phái sinh và chứng quyền. |
| 70 | mat_dt | DATE | X |  |  |  | Ngày đáo hạn — dùng cho chứng quyền và phái sinh. |
| 71 | cvrd_wrnt_tp_code | STRING | X |  |  |  | Loại chứng quyền — chỉ áp dụng khi StockType=W. |
| 72 | exrc_prc | DECIMAL(23,2) | X |  |  |  | Giá thực hiện — dùng cho chứng quyền. |
| 73 | exrc_rto | DECIMAL(5,2) | X |  |  |  | Tỷ lệ chuyển đổi — dùng cho chứng quyền. |
| 74 | list_shr | INT | X |  |  |  | Khối lượng chứng quyền niêm yết. |
| 75 | issur_nm | STRING | X |  |  |  | Tên tổ chức phát hành chứng quyền. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_tdg_snpst_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ulyg_imt_id | scr_tdg_snpst | scr_tdg_snpst_id |



#### Index

N/A

#### Trigger

N/A




### Stored Procedure/Function

N/A

### Package

N/A
