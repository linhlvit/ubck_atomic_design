## 2.1 MDDS — Hệ thống dữ liệu giao dịch thị trường từ các SGDCK

### 2.1.1 Các mô hình quan hệ dữ liệu

- DBML tổng hợp (tất cả bảng): [`MDDS.dbml`](MDDS.dbml) — paste vào https://dbdiagram.io để render.
- Diagram theo mảng nghiệp vụ:
  - **UID01 — Thị trường và chỉ số tổng hợp**: [`MDDS_UID01.dbml`](MDDS_UID01.dbml)


**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | mkt_snpst | Snapshot trạng thái tổng hợp toàn sàn giao dịch (HOSE/HNX/UPCOM) tại mỗi thời điểm: điểm chỉ số sàn |
| 2 | mkt_indx_snpst | Snapshot thông tin chỉ số thị trường chứng khoán (VN30/VNINDEX/HNX30...) tại thời điểm phát sinh: giá trị chỉ số |




### 2.1.2 Bảng mkt_snpst



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


#### 2.1.2.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_snpst_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### 2.1.2.2 Index

N/A

#### 2.1.2.3 Trigger

N/A




### 2.1.3 Bảng mkt_indx_snpst



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


#### 2.1.3.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| mkt_indx_snpst_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### 2.1.3.2 Index

N/A

#### 2.1.3.3 Trigger

N/A




### 2.1.4 Stored Procedure/Function

N/A

### 2.1.5 Package

N/A
