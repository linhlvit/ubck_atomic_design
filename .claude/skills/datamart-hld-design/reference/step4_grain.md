# Bước 4 — Phân loại bảng và kiểm soát cấp độ hạt — HLD Datamart

Loại bảng Phân tích / Tác nghiệp, iso-grain, thang 6 bậc hạt, chuỗi thời gian theo số phiên, tỷ số tài chính.

## Mục lục

- BƯỚC 4 — PHÂN LOẠI BẢNG DATAMART
  - BƯỚC 4B — KIỂM SOÁT CẤP ĐỘ HẠT (ISO-GRAIN RULE), CHỐNG LỆCH HẠT & LƯU TRỮ CHUỖI THỜI GIAN

## BƯỚC 4 — PHÂN LOẠI BẢNG DATAMART

| Loại | Khi nào | Pattern |
|---|---|---|
| **Phân tích** | KPI aggregate nhiều đối tượng / nhiều kỳ | Star Schema — Fact + Dim |
| **Tác nghiệp** | Lookup 1 đối tượng cụ thể | Denormalized Table — 1 row per đối tượng |

### BƯỚC 4B — KIỂM SOÁT CẤP ĐỘ HẠT (ISO-GRAIN RULE), CHỐNG LỆCH HẠT & LƯU TRỮ CHUỖI THỜI GIAN

> **Bài học kinh nghiệm thực tế sâu sắc (Case K_GSTT_61 & Fanout Measure):**
> 1. *Fanout measure khi SUM:* Measure (số đo, cột định lượng) bị fanout khi đặt lên Fact có grain mịn hơn cấp phát sinh (VD: `Fact Penalty Decision Subject Behavior` mang `Total_Fine_Amount` của cấp Quyết định $\implies$ SUM bị nhân đôi/nhân ba).
> 2. *Grain Mismatch khi Reuse (Case K_GSTT_61):* Chỉ tiêu "Vốn hóa" tại Nhóm 6 (Dashboard cấp Rổ chỉ số VN30/HNX30) có công thức `MAX(idx_market_cap) GROUP BY index_code`. Khi thiết kế 8 nhóm Top-N mã chứng khoán (Nhóm 7, 9, 11, 13, 19, 21, 32, 33), người thiết kế ghi `Reuse từ Nhóm 6` và copy nguyên công thức $\implies$ Cổ phiếu VCB hiển thị vốn hóa 3.2 triệu tỷ VNĐ của cả rổ VN30 thay vì vốn hóa riêng của VCB (~450 nghìn tỷ VNĐ)!

#### 1. Nguyên Tắc Đồng Hạt (Iso-Grain Rule)
- **Presentation Grain (Cấp độ hạt trình diễn):** Xác định từ Mockup báo cáo ở Section 2: *"Một dòng kết quả hiển thị đại diện cho 1 đối tượng nghiệp vụ gì?"*. Nhìn vào các cột dimension định danh đứng liền kề (Mã CK vs Tên rổ chỉ số vs Mã CTCK vs Tên sàn).
- **Fact Storage Grain (Cấp độ hạt lưu trữ):** Định nghĩa grain lưu trữ vật lý của bảng Fact ở Section 3: *"Một dòng bản ghi trong Fact lưu trữ trạng thái của đối tượng gì tại mốc thời gian nào?"*.
- **Ràng buộc Iso-Grain:** Cấp độ hạt trình diễn trên báo cáo phải tương thích và không được mịn hơn cấp độ hạt của Fact lưu trữ ($Presentation\_Grain \le Fact\_Storage\_Grain$). Tuyệt đối cấm ánh xạ trực tiếp báo cáo cấp Cổ phiếu vào Fact cấp Rổ chỉ số/Sàn nếu không có bảng cầu nối (Bridge table) hợp lệ (`L1-GRAIN-MISMATCH`).

#### 2. Thang 6 Bậc Phân Cấp Hạt Kinh Doanh (Grain Hierarchy)
Khi phân tích và đối soát grain, bắt buộc tuân theo thứ bậc từ thô đến mịn:
- **Level 1 (Sàn GDCK):** `floor_code` (HOSE, HNX, UPCOM)
- **Level 2 (Rổ Chỉ Số):** `index_code` (VN-Index, VN30, HNX30)
- **Level 3 (Ngành / Lĩnh Vực):** `industry_code` (Ngân hàng, Bất động sản...)
- **Level 4 (Mã Chứng Khoán / Doanh Nghiệp):** `symbol` / `public_company_id`
- **Level 5 (Định Chế / CTCK / Thành Viên):** `member_code` / `sc_firm_id`
- **Level 6 (Tài Khoản / Giao Dịch Chi Tiết):** `account_number`, `order_id`

*Quy tắc chống Grain Mismatch khi Reuse:* Nếu nhóm reuse có Presentation Grain ở cấp độ hạt khác nhóm gốc (ví dụ gốc Level 2, reuse Level 4) $\implies$ **CẤM copy nguyên công thức aggregate**. Bắt buộc viết lại logic aggregate theo đúng khóa định danh của nhóm reuse (ví dụ: `MAX(close_price * outstanding_share_quantity) GROUP BY symbol`).

#### 3. Chuẩn Hóa Lưu Trữ Chuỗi Thời Gian & Quy Đổi Số Phiên Giao Dịch
Đối với các chỉ tiêu phân tích kỹ thuật và chuỗi thời gian lookback (Đỉnh/Đáy 52 tuần, 6 tháng, 3 tháng, 1 tháng, MA20, MA10, MA5):
1. **Quy đổi số phiên giao dịch chuẩn (Trading Sessions):**
   Thị trường chứng khoán nghỉ thứ Bảy, Chủ nhật và ngày lễ, tạo ra các khoảng trống lịch tự nhiên.
   - **CẤM:** Sử dụng ngày lịch `INTERVAL '52' WEEK` hoặc `INTERVAL '6' MONTH`.
   - **BẮT BUỘC:** Quy đổi sang số phiên giao dịch thực tế và dùng khung cửa sổ hàng (`ROWS BETWEEN (N-1) PRECEDING AND CURRENT ROW`) trên chuỗi sắp xếp `ORDER BY <date> ASC`:
     + **52 tuần (~1 năm):** Đúng **260 phiên** (`ROWS BETWEEN 259 PRECEDING AND CURRENT ROW`).
     + **6 tháng (~26 tuần):** Đúng **130 phiên** (`ROWS BETWEEN 129 PRECEDING AND CURRENT ROW`).
     + **3 tháng (~13 tuần):** Đúng **65 phiên** (`ROWS BETWEEN 64 PRECEDING AND CURRENT ROW`).
     + **1 tháng / 4 tuần:** Đúng **20 phiên** (`ROWS BETWEEN 19 PRECEDING AND CURRENT ROW`).
     + **Đường MA20 / MA10 / MA5:** Tương ứng 20 phiên (`19 PRECEDING`), 10 phiên (`9 PRECEDING`), 5 phiên (`4 PRECEDING`).
   - *Xử lý cổ phiếu mới niêm yết:* Chuỗi dữ liệu lịch sử chưa đủ 260 phiên thì mệnh đề `ROWS BETWEEN 259 PRECEDING AND CURRENT ROW` tự động lấy từ phiên đầu tiên có sẵn đến hiện tại, không gây lỗi SQL và không trả về NULL.
2. **Cấu trúc phân đoạn bắt buộc:** Mọi Window Function phải có `PARTITION BY <entity_id>` (như `PARTITION BY symbol`) và `ORDER BY <date_col> ASC` để không trộn lẫn chuỗi giá của các thực thể khác nhau.
3. **Lựa chọn trường giá:**
   - Bắt buộc dùng **`close_price`** (Giá đóng cửa) cho 100% các báo cáo thống kê định giá chính thức của UBCKNN / Sở GDCK (mẫu `BM021_MSS`) và đỉnh/đáy 52 tuần.
   - Chỉ dùng `high_price` / `low_price` khi BA yêu cầu tường minh phân tích nến cực trị trong phiên (Intraday Extremes).

#### 4. Nền Tảng Lưu Trữ Bắt Buộc: Fact Periodic Snapshot theo ngày (`fct_*_snpst`)
- **LỆNH CẤM TUYỆT ĐỐI (`L2-WINDOW-STORAGE-INVALID`):** CẤM thiết kế tính toán Window Function lịch sử trên Dimension SCD4A current-state (như `security_trading_snpst_dim`).
- *Lý do:* Bảng Dimension SCD4A current-state chỉ lưu **duy nhất 1 bản ghi hiện hành** của ngày hôm nay cho mỗi thực thể. Chạy Window Function trên 1 dòng duy nhất sẽ luôn trả về chính giá ngày hôm nay, làm mất hoàn toàn giá trị lịch sử!
- **Kiến trúc chuẩn:** Mọi chỉ tiêu chuỗi thời gian lookback bắt buộc phải được thiết kế lưu trữ trên **Fact Periodic Snapshot theo ngày** (`fct_*_snpst`) với Grain `1 row / entity / trade_date`.

#### 5. Tính Nhất Quán Chu Kỳ Trong Tỷ Số Tài Chính (Financial Ratio Period Consistency)
- **Nguyên tắc Ghép Cặp:** Tử số và Mẫu số của các chỉ số tài chính (P/E, P/B, EPS, BVPS, ROE, ROA) bắt buộc phải nằm trên **cùng một hệ quy chiếu thời gian**:
  + P/E Năm (TTM): Tử số = `close_price`, Mẫu số = `EPS TTM` (LNST lũy kế 4 quý gần nhất chia cho Số CP bình quân 4 quý).
  + P/E Quý: Phải nhân 4 quy năm (`EPS Quý × 4`). Tuyệt đối không lấy Giá chia cho EPS 1 quý mà không quy năm.
- **LỆNH CẤM CỘNG DỒN BIẾN SỐ SỐ DƯ (STOCK SUMMATION BAN):**
  + **TUYỆT ĐỐI CẤM:** Dùng `SUM(owner_equity)` hoặc `SUM(total_assets)` qua 4 quý trong mẫu số. Vốn chủ sở hữu và Tổng tài sản là biến số số dư thời điểm (BCDKT). Phải lấy số dư quý gần nhất hoặc tính bình quân đầu/cuối kỳ: `(Đầu kỳ + Cuối kỳ) / 2`.
- **Quy Tắc Xử Lý Thiếu BCTC:** Nếu doanh nghiệp thiếu BCTC của bất kỳ quý nào trong chuỗi 4 quý TTM $\implies$ Chỉ tiêu `net_profit_after_tax_ttm`, `EPS TTM`, `P/E` bắt buộc trả về `NULL`, nghiêm cấm việc cộng 2-3 quý rồi tự ý chia bình quân nội suy.
