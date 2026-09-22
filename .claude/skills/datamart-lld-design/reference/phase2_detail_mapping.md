# Phase 2 — Detail Mapping CSV Reference

## Header

```
kpi_id,tab,nhom,kpi_name,tinh_chat,source_module,mart_table,mart_column,column_role,logic,ghi_chu
```

Export encoding: **UTF-8 BOM** (`utf-8-sig`).

---

## Phạm vi xử lý

**Nguồn sự thật:** `BRD/BA/BA_analyst_{MODULE}.csv`

| Trạng thái BA | Xử lý |
|---|---|
| `Done` | Đưa vào Detail Mapping đầy đủ |
| `Doing` | Đưa vào Detail Mapping, `ghi_chu = "Doing — chờ BA xác nhận"` |
| `Pending` | Đưa vào Detail Mapping đầy đủ |
| `NaN` / trống | Xác nhận với BA trước khi map — không tự điền |

**KPI PENDING từ HLD** (block PENDING Section 2 hoặc KPI PENDING đơn lẻ do thiếu nguồn) — cũng đưa vào Detail Mapping (áp dụng triệt để Quy tắc L4):

| Cột | Giá trị |
|---|---|
| `kpi_id` | K_{MODULE}_N — tham chiếu từ HLD |
| `kpi_name` | Tên KPI từ bảng KPI trong HLD |
| `mart_table` | *(để trống)* |
| `mart_column` | *(để trống)* |
| `column_role` | *(để trống)* |
| `logic` | *(để trống)* |
| `ghi_chu` | `Pending - [Nhóm 1-5]: <lý do chi tiết>` |

> **Quy tắc L4 mở rộng:** Áp dụng cho cả nhóm PENDING toàn bộ lẫn KPI PENDING đơn lẻ nằm trong nhóm READY. Bắt buộc để trống cả 4 cột (`mart_table`, `mart_column`, `column_role`, `logic`). Blocker phải được phân loại rõ theo 1 trong 5 nhóm nguyên nhân chuẩn hóa.

❌ Không bỏ qua dòng `Phân loại = Chiều`.
❌ Không bỏ qua dòng `Trạng thái = Doing`.
❌ Không bỏ qua chiều lặp lại giữa các nhóm — mỗi nhóm phải có đủ SLICER/FILTER.

---

## column_role

| `column_role` | Khi nào dùng |
|---|---|
| `MEASURE` | KPI Base — phép tính aggregate trực tiếp trên mart |
| `FILTER` | Điều kiện lọc có giá trị cố định |
| `SLICER` | Chiều phân tích — user chọn giá trị tại runtime |
| `GROUP_BY` | Chiều nhóm trong aggregate |
| `JOIN_KEY` | FK dùng để join |
| `DERIVED` | KPI Phái sinh — tính tại presentation layer |
| `DEPRECATED` | Chỉ tiêu đã bãi bỏ sau thống nhất với BA — không sinh cột/slicer |

**Mapping từ Phân loại BA / Tính chất HLD:**

| Phân loại BA / Tính chất HLD | column_role |
|---|---|
| `Chiều` | `SLICER` / `FILTER` / `GROUP_BY` |
| `Chỉ tiêu cơ sở` | `MEASURE` |
| `Chỉ tiêu phái sinh` | `DERIVED` (ưu tiên) hoặc `MEASURE` nếu lưu trong mart |
| `Attribute` (KPI tác nghiệp trên Operational) | `SLICER` — column hiển thị / filter trực tiếp, không aggregate |
| `Deprecated` / `Bãi bỏ` / `Loại bỏ` | `DEPRECATED` — giữ dòng đối soát, không sinh cột |

**Lưu ý `tinh_chat` cho dòng FILTER/SLICER của KPI Base:**
Dòng FILTER/SLICER thuộc cùng KPI Base (cùng `kpi_id`) kế thừa `tinh_chat = "Base"` từ KPI cha — không để trống.

---

## Quy tắc từng column_role

**MEASURE:**
- Chỉ khai báo phép tính thuần: `COUNT`, `SUM`, `AVG`
- Không nhúng `WHERE` condition vào MEASURE — tách thành FILTER/SLICER row riêng
- Ngoại lệ: aggregate nhiều nhánh không thể tách (VD: CASE WHEN trong SUM)

**DERIVED:**
- `mart_table` và `mart_column` để **trống**
- `logic` chứa formula đầy đủ dùng physical name
- ❌ `logic` của DERIVED không được refer KPI ID (`K_{MODULE}_N`) — ngoại lệ duy nhất: YoY không biểu diễn được bằng mart column → `ghi_chu = "Refer KPI ID vì YoY — cần presentation layer resolve"`

**Chỉ số / Bộ chỉ số thị trường:**
- `mart_column = scr_tdg_snpst_dim.idx_codes`
- `column_role = FILTER`
- `logic = ARRAY_CONTAINS(scr_tdg_snpst_dim.idx_codes, :selected_index)`

---

## Quy ước tên cột

| Cột | Kiểu tên | Ví dụ |
|---|---|---|
| `mart_table` | **Logical** | `Fact Fund Management Company Snapshot` |
| `mart_column` | **Logical** | `Investment Fund Count` |
| `logic` | **Physical** — tra từ Attributes CSV | `SUM(fct_fnd_mgt_co_snpst.ivsm_fnd_cnt)` |

❌ `logic` dùng logical name (Title Case) — phải là physical `table.column`.
❌ `tinh_chat` trong Detail Mapping khác với `Tính chất` trong HLD bảng KPI.

---

## Quy Chuẩn Điền Cột Cho 4 Trường Hợp Đặc Biệt

Trong Detail Mapping, việc để trống hay điền giá trị tại các cột kỹ thuật (`mart_table`, `mart_column`, `column_role`, `logic`) quyết định trực tiếp đến quá trình sinh Flat Table DDL/DML và kiểm thử đối soát. Dưới đây là quy chuẩn bắt buộc cho 4 trường hợp đặc biệt:

### 1. DERIVED (Chỉ tiêu Phái Sinh Tính Toán Tại Presentation Layer)
- **Bản chất:** Chỉ tiêu không được lưu trữ vật lý thành một cột riêng trên bảng Fact/Dim của Datamart, mà được tính toán động (dynamically computed) tại tầng báo cáo/BI (PowerBI, Superset, v.v.) dựa trên các thuộc tính/measure vật lý sẵn có.
- **Quy tắc bắt buộc:**
  + `mart_table`: **Bắt buộc để trống** (`""`).
  + `mart_column`: **Bắt buộc để trống** (`""`). Tuyệt đối **CẤM** gán cột ảo, cột phái sinh tự tạo (như `P/E Ratio`, `Market Cap`), hoặc cột generic của bảng báo cáo (như `item_value` trong các bảng Report denormalized).
  + `column_role`: Điền `DERIVED`.
  + `logic`: Chứa **công thức vật lý đầy đủ** bằng tên physical (`table.column`), không dùng logical name. Cấm tham chiếu mã KPI chéo (`K_{MODULE}_N`) trừ trường hợp ngoại lệ YoY.
  + `ghi_chu`: Ghi rõ nguồn gốc các cột cấu thành và lưu ý tính tại presentation layer.

### 2. PENDING (Quy tắc L4: Chưa Có Nguồn Hoặc Nhóm PENDING)
- **Bản chất:** Chỉ tiêu còn hiệu lực nghiệp vụ nhưng tạm thời chưa thể thiết kế/triển khai do thiếu nguồn Atomic, chờ BA phân tích, hoặc Datamart chưa thiết kế bảng.
- **Phạm vi áp dụng:** Áp dụng cho **CẢ 2 TRƯỜNG HỢP**:
  1. Toàn bộ nhóm HLD ở trạng thái PENDING (do thiếu nguồn toàn nhóm).
  2. KPI PENDING đơn lẻ nằm xen kẽ trong một nhóm HLD đã READY.
- **Quy tắc bắt buộc (Nguyên tắc vàng L4):**
  + **BẮT BUỘC ĐỂ TRỐNG CẢ 4 CỘT:** `mart_table`, `mart_column`, `column_role`, `logic`.
  + Tuyệt đối không điền tên bảng/cột dự kiến, không điền role `MEASURE` hay `PENDING`, không điền logic giả định.
  + `ghi_chu`: Bắt buộc ghi rõ lý do blocker thuộc **1 trong 5 nhóm nguyên nhân chuẩn hóa**:
    * **[Nhóm 1 - BA Pending]:** BA chưa phân tích xong / chờ BA confirm mapping.
    * **[Nhóm 2 - Chưa có mapping nguồn từ BA]:** Nguồn trống / N/A / Chưa có CSDL nguồn.
    * **[Nhóm 3 - Thiếu nguồn Atomic / Ngoại lai]:** Chưa có bảng/cột Atomic tương ứng (ghi rõ tên entity thiếu và Open Issue ID, ví dụ: `O_{MODULE}_{N}`).
    * **[Nhóm 4 - Join đa nguồn phức tạp]:** Cần kết nối liên hệ thống chưa chuẩn hóa mô hình dữ liệu.
    * **[Nhóm 5 - Datamart Pending]:** Atomic đã có sẵn, Datamart đang chờ thiết kế bảng Fact/Dim.

### 3. REUSE (Tái Sử Dụng Chỉ Tiêu Giữa Các Nhóm)
Khi một chỉ tiêu ở nhóm sau sử dụng lại dữ liệu của nhóm trước, phải phân định dứt khoát 2 trường hợp:

#### Case 1: Tái Sử Dụng Measure/Dim Vật Lý Đã Có Sẵn (Physical Measure/Dim Reuse)
- **Bản chất:** Chỉ tiêu sử dụng trực tiếp một measure hoặc dimension attribute đã được thiết kế và lưu trữ vật lý trên bảng Fact hoặc Dim ở nhóm trước.
- **Quy tắc bắt buộc:**
  + `mart_table`: **BẮT BUỘC ĐIỀN ĐỦ** tên bảng logical tương ứng.
  + `mart_column`: **BẮT BUỘC ĐIỀN ĐỦ** tên cột logical tương ứng. Tuyệt đối **KHÔNG ĐƯỢC ĐỂ TRỐNG** nếu Fact/Dim đã có cột. Để trống sẽ khiến Phase 3 Flat Table SQL không sinh được cột trong SELECT list.
  + `column_role`: Điền `MEASURE` (nếu là aggregate) hoặc `SLICER`/`FILTER` (nếu là dimension attribute).
  + `logic`: Điền công thức vật lý tương ứng (`SUM(table.col)`, v.v.).
  + `ghi_chu`: Ghi rõ `Reuse từ Nhóm X (K_{MODULE}_Y) — measure có sẵn trên Fact/Dim <Table>`.

#### Case 2: Tái Sử Dụng Chỉ Tiêu Hiển Thị BI / Phái Sinh (Presentation / Derived Reuse)
- **Bản chất:** Chỉ tiêu hiển thị lại thuần túy qua BI layer hoặc phái sinh từ các measure có sẵn mà không có cột vật lý riêng trên Fact/Dim.
- **Quy tắc bắt buộc:**
  + `mart_table`: **BẮT BUỘC ĐỂ TRỐNG** (`""`).
  + `mart_column`: **BẮT BUỘC ĐỂ TRỐNG** (`""`). Cấm tự tạo tên cột ảo vì sẽ gây lỗi TC4/TC7 do cột không có trong `datamart_attributes.csv`.
  + `column_role`: Điền `DERIVED`.
  + `logic`: Viết lại công thức vật lý đầy đủ từ các cột cấu thành (chú ý kiểm tra đúng grain hiển thị của nhóm reuse theo Quy tắc L14).
  + `ghi_chu`: Ghi rõ `Reuse từ Nhóm X (K_{MODULE}_Y) — tính toán tại presentation layer, không lưu cột riêng trên Fact`.

### 4. DEPRECATED / LOẠI BỎ (Đã Thống Nhất Bãi Bỏ Với BA)
- **Bản chất:** Chỉ tiêu hoặc chiều đã từng được định danh trong HLD hoặc scope ban đầu, nhưng trong quá trình thiết kế chi tiết/review đã được BA và Data Modeler thống nhất bãi bỏ vĩnh viễn (terminal state).
- **Quy tắc bắt buộc:**
  + `column_role`: **BẮT BUỘC ĐIỀN `DEPRECATED`**.
  + `mart_table`: **Bắt buộc để trống** (`""`).
  + `mart_column`: **Bắt buộc để trống** (`""`).
  + `logic`: Điền cố định: `"Đã loại bỏ — không tạo cột/slicer"`.
  + `tinh_chat`: Điền `Deprecated`.
  + `ghi_chu`: Ghi rõ ngày thống nhất, lý do loại bỏ và căn cứ/biên bản thống nhất với BA (ví dụ: `Resolved YYYY-MM-DD (Deprecated) — ...`).
- **Phân biệt 3 khái niệm quan trọng:**
  1. **Delete từ BA (`Trạng thái mapping = Delete` trong file BA analyst ban đầu):** Loại bỏ 100% ngay từ đầu, KHÔNG sinh dòng trong HLD, **KHÔNG sinh dòng trong Detail Mapping**, KHÔNG tạo cột trong Attributes. Đưa vào Detail Mapping là vi phạm L1/L2-DELETE-VIOLATION.
  2. **DEPRECATED trong Datamart (`column_role = 'DEPRECATED'`):** Chỉ tiêu đã có KPI_ID trong HLD nhưng sau đó thống nhất hủy. **BẮT BUỘC GIỮ DÒNG** trong Detail Mapping để bảo toàn đối soát số lượng HLD (TC5), nhưng đánh dấu tường minh để loại khỏi ETL active.
  3. **PENDING trong Datamart (4 cột để trống):** Chỉ tiêu còn nhu cầu triển khai trong tương lai, chỉ tạm thời tắc nghẽn nguồn. **TUYỆT ĐỐI KHÔNG ĐÁNH TRÁO DEPRECATED THÀNH PENDING** vì sẽ làm phình to backlog và báo cáo sai lệch.

---

## Bảng Đối Chiếu Ví Dụ Đúng vs Sai Cho 5 Kịch Bản (Right vs Wrong Examples)

Dưới đây là bảng đối chiếu cụ thể theo đúng cấu trúc 11 cột của Detail Mapping:
`kpi_id,tab,nhom,kpi_name,tinh_chat,source_module,mart_table,mart_column,column_role,logic,ghi_chu`

### 1. Kịch Bản DERIVED (Chỉ tiêu Phái Sinh)

| Thuộc tính | Cột | Ví dụ ĐÚNG ✅ | Ví dụ SAI ❌ | Phân tích lỗi sai |
|---|---|---|---|---|
| Mã KPI | `kpi_id` | `K_GSTT_12` | `K_GSTT_12` | |
| Tab | `tab` | `TỔNG QUAN` | `TỔNG QUAN` | |
| Nhóm | `nhom` | `Nhóm 1 — Thị trường cổ phiếu` | `Nhóm 1 — Thị trường cổ phiếu` | |
| Tên KPI | `kpi_name` | `% Thay đổi giá` | `% Thay đổi giá` | |
| Tính chất | `tinh_chat` | `Phái sinh` | `Phái sinh` | |
| Phân hệ nguồn | `source_module` | `GSTT` | `GSTT` | |
| **Bảng Mart** | `mart_table` | *(để trống)* | `Security Trading Snapshot Dimension` | ❌ **SAI:** Điền tên bảng vật lý cho chỉ tiêu DERIVED |
| **Cột Mart** | `mart_column` | *(để trống)* | `Price Change Percentage` | ❌ **SAI:** Tự bịa tên cột vật lý không có trong schema Attributes |
| **Vai trò cột** | `column_role` | `DERIVED` | `DERIVED` (hoặc `MEASURE`) | Nếu đổi thành MEASURE càng sai vì mart không lưu trữ cột này |
| **Công thức** | `logic` | `security_trading_snpst_dim.price_change / security_trading_snpst_dim.reference_price * 100` | `(K_GSTT_11 - K_GSTT_9) / K_GSTT_9 * 100` | ❌ **SAI:** Tham chiếu chéo mã KPI thay vì công thức cột vật lý |
| Ghi chú | `ghi_chu` | `Tính tại presentation layer từ 2 cột Dimension` | `Chỉ tiêu phái sinh` | |

*Dạng dòng CSV hợp lệ:*
```csv
"K_GSTT_12","TỔNG QUAN","Nhóm 1 — Thị trường cổ phiếu","% Thay đổi giá","Phái sinh","GSTT","","","DERIVED","security_trading_snpst_dim.price_change / security_trading_snpst_dim.reference_price * 100","Tính tại presentation layer từ 2 cột Dimension"
```

*Lưu ý lỗi cột generic:* Với các bảng báo cáo dạng Report denormalized (như HNX03, HNX04), tuyệt đối không gán `mart_column = "Item Value"` cho dòng DERIVED. Nếu chỉ tiêu tính ở presentation layer thì phải để trống bảng/cột; nếu nạp trực tiếp vào bảng report thì `column_role` phải là `MEASURE`.

---

### 2. Kịch Bản PENDING (Quy Tắc L4: Để Trống Cả 4 Cột)

| Thuộc tính | Cột | Ví dụ ĐÚNG ✅ | Ví dụ SAI ❌ | Phân tích lỗi sai |
|---|---|---|---|---|
| Mã KPI | `kpi_id` | `K_QLKD_3039` | `K_QLKD_3039` | |
| Tab | `tab` | `CHI TIẾT` | `CHI TIẾT` | |
| Nhóm | `nhom` | `Nhóm 23 — Báo cáo tài chính` | `Nhóm 23 — Báo cáo tài chính` | |
| Tên KPI | `kpi_name` | `Doanh thu hoạt động môi giới` | `Doanh thu hoạt động môi giới` | |
| Tính chất | `tinh_chat` | `Base` | `Base` | |
| Phân hệ nguồn | `source_module` | `QLKD` | `QLKD` | |
| **Bảng Mart** | `mart_table` | *(để trống)* | `Fact Financial Report Snapshot` | ❌ **SAI L4:** Điền tên bảng dự kiến khi chưa thiết kế |
| **Cột Mart** | `mart_column` | *(để trống)* | `Brokerage Revenue` | ❌ **SAI L4:** Điền tên cột dự kiến khi chưa có nguồn |
| **Vai trò cột** | `column_role` | *(để trống)* | `MEASURE` | ❌ **SAI L4:** Điền vai trò cột khi chỉ tiêu đang PENDING |
| **Công thức** | `logic` | *(để trống)* | `SUM(fct_fin_rpt.brokerage_rev)` | ❌ **SAI L4:** Điền công thức giả định chưa kiểm chứng |
| **Ghi chú** | `ghi_chu` | `Pending - [Nhóm 3 - Thiếu nguồn Atomic]: gap Atomic REPORT_CELL_VALUE, xem O_QLKD_23` | `Pending - chưa thiết kế nguồn` | Điền đủ 4 cột trên làm script audit hiểu nhầm là READY, gây lỗi khi sinh flat table |

*Dạng dòng CSV hợp lệ:*
```csv
"K_QLKD_3039","CHI TIẾT","Nhóm 23 — Báo cáo tài chính","Doanh thu hoạt động môi giới","Base","QLKD","","","","","Pending - [Nhóm 3 - Thiếu nguồn Atomic]: gap Atomic REPORT_CELL_VALUE, xem O_QLKD_23"
```

---

### 3. Kịch Bản REUSE Case 1 (Tái Sử Dụng Measure/Dim Vật Lý)

| Thuộc tính | Cột | Ví dụ ĐÚNG ✅ | Ví dụ SAI ❌ | Phân tích lỗi sai |
|---|---|---|---|---|
| Mã KPI | `kpi_id` | `K_GSTT_13` | `K_GSTT_13` | |
| Tab | `tab` | `GIAO DỊCH` | `GIAO DỊCH` | |
| Nhóm | `nhom` | `Nhóm 7 — Top giao dịch cổ phiếu` | `Nhóm 7 — Top giao dịch cổ phiếu` | |
| Tên KPI | `kpi_name` | `Khối lượng giao dịch khớp lệnh` | `Khối lượng giao dịch khớp lệnh` | |
| Tính chất | `tinh_chat` | `Base` | `Base` | |
| Phân hệ nguồn | `source_module` | `GSTT` | `GSTT` | |
| **Bảng Mart** | `mart_table` | `Fact Stock Portfolio Snapshot` | *(để trống)* | ❌ **SAI NGHIÊM TRỌNG:** Fact đã có bảng nhưng lại để trống |
| **Cột Mart** | `mart_column` | `Total Matched Volume` | *(để trống)* | ❌ **SAI NGHIÊM TRỌNG:** Fact đã có cột nhưng lại để trống (lưu ý: phải dùng Total Matched Volume theo đúng SQL tham khảo BA, không dùng Total Volume gộp thỏa thuận) |
| **Vai trò cột** | `column_role` | `MEASURE` | `MEASURE` (hoặc để trống) | |
| **Công thức** | `logic` | `SUM(fct_stock_portfolio_snpst.total_matched_vol)` | `SUM(fct_stock_portfolio_snpst.total_vol)` | |
| **Ghi chú** | `ghi_chu` | `Reuse từ Nhóm 1 (K_GSTT_13) — measure có sẵn trên Fact Stock Portfolio Snapshot` | `Reuse từ Nhóm 1` | Để trống bảng/cột làm Phase 3 Flat Table không lấy được cột vào SELECT list |

*Dạng dòng CSV hợp lệ:*
```csv
"K_GSTT_13","GIAO DỊCH","Nhóm 7 — Top giao dịch cổ phiếu","Khối lượng giao dịch khớp lệnh","Base","GSTT","Fact Stock Portfolio Snapshot","Total Matched Volume","MEASURE","SUM(fct_stock_portfolio_snpst.total_matched_vol)","Reuse từ Nhóm 1 (K_GSTT_13) — measure có sẵn trên Fact Stock Portfolio Snapshot"
```

---

### 4. Kịch Bản REUSE Case 2 (Chỉ Tiêu Hiển Thị BI / Phái Sinh Không Có Cột Riêng)

| Thuộc tính | Cột | Ví dụ ĐÚNG ✅ | Ví dụ SAI ❌ | Phân tích lỗi sai |
|---|---|---|---|---|
| Mã KPI | `kpi_id` | `K_GSTT_58` | `K_GSTT_58` | |
| Tab | `tab` | `ĐỊNH GIÁ` | `ĐỊNH GIÁ` | |
| Nhóm | `nhom` | `Nhóm 7 — Top cổ phiếu theo P/E` | `Nhóm 7 — Top cổ phiếu theo P/E` | |
| Tên KPI | `kpi_name` | `Chỉ số P/E` | `Chỉ số P/E` | |
| Tính chất | `tinh_chat` | `Phái sinh` | `Phái sinh` | |
| Phân hệ nguồn | `source_module` | `GSTT` | `GSTT` | |
| **Bảng Mart** | `mart_table` | *(để trống)* | `Fact Stock Portfolio Snapshot` | ❌ **SAI:** Fact không lưu trữ cột P/E, gán bảng gây nhầm lẫn |
| **Cột Mart** | `mart_column` | *(để trống)* | `P/E Ratio` | ❌ **SAI:** Cột không có trong Attributes CSV, gây FAIL TC4/TC7 |
| **Vai trò cột** | `column_role` | `DERIVED` | `MEASURE` | ❌ **SAI:** Không phải measure vật lý aggregate |
| **Công thức** | `logic` | `security_trading_snpst_dim.close_price / (fct_stock_portfolio_snpst.net_profit_after_tax_ttm / fct_stock_portfolio_snpst.outstanding_share_quantity)` | `AVG(fct_stock_portfolio_snpst.pe_ratio)` | Công thức tính từ các cột vật lý có sẵn |
| **Ghi chú** | `ghi_chu` | `Reuse từ Nhóm 6 (K_GSTT_58) — tính toán tại presentation layer, không lưu cột riêng trên Fact` | `Reuse từ Nhóm 6` | |

*Dạng dòng CSV hợp lệ:*
```csv
"K_GSTT_58","ĐỊNH GIÁ","Nhóm 7 — Top cổ phiếu theo P/E","Chỉ số P/E","Phái sinh","GSTT","","","DERIVED","security_trading_snpst_dim.close_price / (fct_stock_portfolio_snpst.net_profit_after_tax_ttm / fct_stock_portfolio_snpst.outstanding_share_quantity)","Reuse từ Nhóm 6 (K_GSTT_58) — tính toán tại presentation layer, không lưu cột riêng trên Fact"
```

---

### 5. Kịch Bản DEPRECATED / LOẠI BỎ (Đã Thống Nhất Bãi Bỏ Với BA)

| Thuộc tính | Cột | Ví dụ ĐÚNG ✅ | Ví dụ SAI 1 (Nhầm PENDING) ❌ | Ví dụ SAI 2 (Xóa mất dòng) ❌ |
|---|---|---|---|---|
| Mã KPI | `kpi_id` | `K_GSTT_6` | `K_GSTT_6` | *(Xóa mất dòng khỏi file)* |
| Tab | `tab` | `PHÂN TÍCH` | `PHÂN TÍCH` | |
| Nhóm | `nhom` | `Nhóm 1 — Bảng số liệu` | `Nhóm 1 — Bảng số liệu` | |
| Tên KPI | `kpi_name` | `Phương thức khớp lệnh (thỏa thuận)` | `Phương thức khớp lệnh (thỏa thuận)` | |
| Tính chất | `tinh_chat` | `Deprecated` | `Base` | |
| Phân hệ nguồn | `source_module` | `GSTT` | `GSTT` | |
| **Bảng Mart** | `mart_table` | *(để trống)* | *(để trống)* | |
| **Cột Mart** | `mart_column` | *(để trống)* | *(để trống)* | |
| **Vai trò cột** | `column_role` | `DEPRECATED` | *(để trống)* | ❌ Để trống role làm hệ thống hiểu nhầm là PENDING |
| **Công thức** | `logic` | `Đã loại bỏ — không tạo cột/slicer` | *(để trống)* | |
| **Ghi chú** | `ghi_chu` | `Resolved 2026-09-08 (Deprecated) — Loại bỏ khỏi danh mục Chiều/Slicer vì không có giá trị khai thác độc lập. Nghiệp vụ hiển thị trực tiếp 4 cột measure riêng biệt: Khớp lệnh (K_GSTT_13/14) và Thỏa thuận (K_GSTT_17/18).` | `Pending - chưa thiết kế nguồn` ❌ **CỰC KỲ NGUY HIỂM:** Gây hiểu nhầm là thiếu nguồn, phát sinh blocker ảo! | ❌ **LỖI:** Xóa mất dòng làm lệch số lượng HLD ↔ Detail Mapping, gây FAIL TC5! |

*Dạng dòng CSV hợp lệ:*
```csv
"K_GSTT_6","PHÂN TÍCH","Nhóm 1 — Bảng số liệu","Phương thức khớp lệnh (thỏa thuận)","Deprecated","GSTT","","","DEPRECATED","Đã loại bỏ — không tạo cột/slicer","Resolved 2026-09-08 (Deprecated) — Loại bỏ khỏi danh mục Chiều/Slicer vì không có giá trị khai thác độc lập. Nghiệp vụ hiển thị trực tiếp 4 cột measure riêng biệt: Khớp lệnh (K_GSTT_13/14) và Thỏa thuận (K_GSTT_17/18)."
```

---

## Lưu ý từ thực tế review — lỗi tái diễn (bắt buộc kiểm tra trước khi giao file)

Các lỗi dưới đây được tổng hợp từ review module PTTT. Mỗi lỗi có pattern cụ thể để kiểm tra nhanh.

### L1 — K_PTTT_41 / Chiều thời gian bị copy-paste sai bảng

**Pattern:** Nhóm có nhiều bảng Fact/Operational; khi copy SLICER/FILTER của K_PTTT_41 từ nhóm trước, `mart_table` và `logic` vẫn trỏ về bảng của nhóm cũ.

**Kiểm tra:** Với mỗi nhóm, xác nhận SLICER `logic` của K_PTTT_41 (hoặc bất kỳ KPI Chiều thời gian tương đương) trỏ đúng `physical_table` của nhóm đó — không phải bảng nhóm khác.

❌ `fct_mkt_rsk_snpst.snpst_dt` xuất hiện ở nhóm dùng `fct_mbr_sfty_per_mbr_snpst` → sai.

---

### L2 — Cột trong `logic` không tồn tại trong Attributes.csv

**Pattern:** Điền `logic = <table>.<column>` nhưng cột đó không có trong `DTM_{MODULE}_Attributes.csv` — thường do đoán tên hoặc copy từ bảng khác.

**Kiểm tra:** Với mọi `physical_table.physical_column` trong cột `logic`, tra tên cột trong Attributes.csv của bảng tương ứng trước khi giao file.

❌ `scr_co_dim.scr_co_code` → không tồn tại; đúng là `scr_co_dim.mbr_code`.

---

### L3 — Operational table bị gán FILTER `cdr_dt_dim`

**Pattern:** Bảng `opr_*` (Operational) không có FK `snpst_dt_dim_id` → không thể JOIN `cdr_dt_dim`. Dòng FILTER date dim không có nghĩa với Operational.

**Quy tắc:**
- Fact Snapshot → cần SLICER `snpst_dt` + FILTER `JOIN cdr_dt_dim ON ... snpst_dt_dim_id`
- Operational → chỉ SLICER trực tiếp cột date (`rpt_dt`, `snpst_dt`...) — không có FILTER `cdr_dt_dim`

❌ Thêm FILTER `cdr_dt_dim` cho bảng `opr_mbr_sfty_monitor` → sai.

---

### L4 — PENDING rule: nhóm HLD PENDING hoặc KPI PENDING còn điền `column_role`/`mart_table`/`logic`

**Pattern:** HLD nhóm = PENDING hoặc KPI đơn lẻ = PENDING nhưng Detail Mapping vẫn điền `column_role`, `mart_table`, `mart_column`, `logic` (thường do copy từ nhóm khác hoặc điền dự kiến).

**Quy tắc cứng:** Dòng PENDING (bất kể do cả nhóm PENDING hay KPI PENDING đơn lẻ do thiếu nguồn) → **toàn bộ 4 cột: `mart_table`, `mart_column`, `column_role`, `logic` PHẢI ĐỂ TRỐNG TUYỆT ĐỐI (`""`)**. Chỉ được điền `kpi_id`, `kpi_name`, `tab`, `nhom`, `tinh_chat`, `source_module`, `ghi_chu`. Cột `ghi_chu` phải ghi rõ blocker thuộc 1 trong 5 nhóm nguyên nhân chuẩn hóa.

❌ Nhóm 26–37 (HLD PENDING / FDS blocker) còn MEASURE/SLICER/FILTER → vi phạm.
❌ KPI PENDING đơn lẻ điền `mart_table = "Fact Financial Report Snapshot"`, `column_role = "MEASURE"` → vi phạm.

---

### L5 — `kpi_name` sai ngữ cảnh khi nhóm được copy từ nhóm tương tự

**Pattern:** Nhiều nhóm có cùng cấu trúc (VD: nhóm VN30/VN100/TPCP) — khi copy nhóm VN30 sang VN100, `kpi_name` vẫn ghi "VN30" thay vì "VN100".

**Kiểm tra:** Với mọi nhóm được tạo bằng cách copy từ nhóm khác, scan toàn bộ `kpi_name` để đảm bảo không còn tên ngữ cảnh cũ.

❌ `kpi_name = "KLGD HĐTL VN30 ngày t"` trong nhóm VN100 → sai.

---

### L6 — Logic sai nguồn dữ liệu — tham chiếu bảng không thuộc nhóm

**Pattern:** `logic` trong một nhóm tham chiếu `physical_table` của nhóm khác — thường do copy-paste hoặc dùng tên bảng tương tự mà không kiểm tra.

**Kiểm tra:** Với mỗi dòng MEASURE/SLICER/FILTER, xác nhận `physical_table` trong `logic` là bảng được thiết kế cho nhóm đó (có trong HLD section của nhóm và trong Attributes.csv).

❌ `SUM(fct_mbr_sfty_per_mbr_snpst.mrgn_dbt_bil_vnd)` xuất hiện ở nhóm dùng `fct_indx_tdg_snpst` → sai.

---

### L7 — Dòng duplicate FILTER trong nhóm PENDING

**Pattern:** Một KPI_ID có 2 dòng FILTER (do copy từ nhiều nguồn). Với nhóm PENDING, các dòng này đều phải xóa về 1 dòng PENDING duy nhất.

**Kiểm tra:** Với nhóm PENDING, mỗi `kpi_id` chỉ được có 1 dòng trong Detail Mapping.

❌ K_PTTT_111 có 2 dòng trong nhóm 37 PENDING → vi phạm.

---

### L8 — Placeholder `<TBD>` trong cột `logic`

**Pattern:** Điền `logic = fct_xxx.col_<TBD>` khi chưa biết tên cột — placeholder bị để lại trong file giao.

**Quy tắc:** `logic` phải là physical name xác định hoặc để trống. Nếu chưa xác định được → chuyển về PENDING (xóa `column_role`/`mart_table`/`logic`, ghi `ghi_chu` rõ blocker).

❌ `logic = fct_mkt_cap_expl_snpst.gdp_<TBD>` → không hợp lệ.

---

### L9 — Cột `nhom` thiếu tên đầy đủ theo HLD

**Pattern:** Cột `nhom` chỉ ghi `"Nhóm 1a"` thay vì tên đầy đủ theo HLD heading Section 2 — mất ngữ nghĩa khi xem file CSV độc lập.

**Quy tắc:**
- Lấy tên từ heading HLD Section 2: `#### Nhóm Xa — [Phân hệ] — [Tên ngắn]`
- Nếu heading có 3 phần → bỏ phần giữa (phân hệ nghiệp vụ, thường trùng với Tab): `Nhóm Xa — [Tên ngắn]`
- Nếu heading có 2 phần → giữ nguyên: `Nhóm X — [Tên ngắn]`

| HLD heading | `nhom` đúng |
|---|---|
| `Nhóm 1a — Chứng chỉ hành nghề — Thống kê tổng hợp (KPI thẻ CCHN)` | `Nhóm 1a — Thống kê tổng hợp (KPI thẻ CCHN)` |
| `Nhóm 1b — Người hành nghề — Thống kê tổng hợp (KPI thẻ NHN)` | `Nhóm 1b — Thống kê tổng hợp (KPI thẻ NHN)` |
| `Nhóm 2 — Biểu đồ Trình độ chuyên môn` | `Nhóm 2 — Biểu đồ Trình độ chuyên môn` |
| `Nhóm 5 — Dashboard Tra cứu hồ sơ 360° — Thông tin chung của NHNCK` | `Nhóm 5 — Thông tin chung của NHNCK` |

❌ `nhom = "Nhóm 1a"` → thiếu tên ngắn, không hợp lệ.

---

### L10 — DERIVED YoY logic refer KPI_ID thay vì công thức physical

**Pattern:** Ghi `logic = (K_NHNCK_2[Y] - K_NHNCK_2[Y-1]) / K_NHNCK_2[Y-1] * 100` — refer KPI_ID thay vì viết công thức bằng physical column.

**Quy tắc:** DERIVED _YOY phải viết công thức rút gọn theo dạng:
```
( COUNT/SUM(fct_xxx.col | <filter_conditions> | snpst yr=:Y) - COUNT/SUM(fct_xxx.col | <filter_conditions> | snpst yr=:Y-1) ) / NULLIF( COUNT/SUM(fct_xxx.col | <filter_conditions> | snpst yr=:Y-1) , 0) * 100
```

**Ký hiệu `|` trong YoY formula** = ngăn cách điều kiện filter (pseudo-SQL, dùng trong cột `logic` để tránh dấu phẩy phá cấu trúc CSV). `ghi_chu` ghi `"YoY % tăng trưởng — presentation layer resolve 2 năm"`.

Ví dụ K_NHNCK_2_YOY (CCHN cấp mới YTD):
```
( COUNT(DISTINCT fct_prac_license_ctf_snpst.license_ctf_doc_code | ctf_issu_dt IN :Y | snpst yr=:Y) - COUNT(DISTINCT fct_prac_license_ctf_snpst.license_ctf_doc_code | ctf_issu_dt IN :Y-1 | snpst yr=:Y-1) ) / NULLIF( COUNT(DISTINCT fct_prac_license_ctf_snpst.license_ctf_doc_code | ctf_issu_dt IN :Y-1 | snpst yr=:Y-1) , 0) * 100
```

❌ `logic = (K_NHNCK_2[Y] - K_NHNCK_2[Y-1]) / K_NHNCK_2[Y-1] * 100` → refer KPI_ID không hợp lệ.

---

### L11 — Thiếu row FILTER `src_stm_code` cho Operational table

**Pattern:** Bảng `opr_*` (Operational) có `src_stm_code` nhưng Detail Mapping không có dòng FILTER để lọc nguồn — khi Atomic table nhận thêm nguồn mới, presentation layer khai thác dữ liệu lẫn nguồn.

**Quy tắc:**
- **Operational table** có `src_stm_code`: bắt buộc có 1 row `column_role = FILTER` với `logic = "src_stm_code = '<VALUE>'"`, `ghi_chu = 'Forward-compat: lọc đúng nguồn khi bảng có nhiều src_stm_code'`. Đặt ngay sau row `JOIN_KEY` đầu tiên của bảng đó trong Detail Mapping.
- **Dimension table**: KHÔNG cần row FILTER `src_stm_code` — Surrogate Key đã encode nguồn (SK = hash(natural_key + src_stm_code)), JOIN từ Fact sang Dim qua SK đã đảm bảo đúng nguồn.
- Ngoại lệ không áp dụng: `cv` (Classification Value) và `cdr_dt_dim` (Calendar Date) — conformed/shared tables.

**Kiểm tra:** Với mỗi Operational table trong Detail Mapping, tìm row `column_role = FILTER` có `logic` chứa `src_stm_code`. Nếu thiếu → thêm row.

❌ `opr_prac_360_profile` không có FILTER `src_stm_code = 'NHNCK_PROFESSIONALS'` → sai.
✅ `opr_prac_360_profile` có 1 dòng `column_role = FILTER`, `logic = "src_stm_code = 'NHNCK_PROFESSIONALS'"`.

---

### L12 — Thứ tự nhóm trong file không tăng dần theo số

**Pattern:** Detail Mapping được sinh qua nhiều đợt (VD: đợt 1 xử lý các nhóm có bảng READY theo Phase 0 Plan, đợt 2 bổ sung nhóm PENDING toàn bộ bị bỏ sót) — mỗi đợt append vào cuối file mà không sắp xếp lại, dẫn đến cột `nhom` không theo thứ tự 1, 2, 3... tăng dần (VD: Nhóm 1..41 xong lại quay về Nhóm 7, 11, 13...).

**Nguyên nhân gốc:** Phase 0 Plan chỉ liệt kê nhóm có bảng cần thiết kế mới — nhóm PENDING toàn bộ (không có bảng) bị xử lý riêng ở một đợt sau, append cuối file thay vì chèn đúng vị trí theo số nhóm.

**Kiểm tra:** Duyệt cột `nhom` theo thứ tự dòng trong file, parse số nhóm bằng regex — thứ tự nhóm-xuất-hiện-lần-đầu phải là 1, 2, ..., N_max liên tục, không được giảm ở bất kỳ điểm nào.

❌ Dòng thứ i có Nhóm 11, dòng thứ i+50 có Nhóm 2 → sai (11 xuất hiện trước 2).
✅ Mọi nhóm xuất hiện theo đúng thứ tự số tăng dần từ 1 đến N_max.

---

### L13 — Thiếu cả một nhóm trong Detail Mapping (không chỉ thiếu vài dòng)

**Pattern:** TC2 (KPI_ID hợp lệ) chỉ kiểm tra chiều Detail Mapping → HLD (không lọt ID lạ), không bắt được trường hợp NGƯỢC LẠI: một nhóm PENDING toàn bộ trong HLD không có bất kỳ dòng nào trong Detail Mapping vì nhóm đó không xuất hiện trong Phase 0 Plan (do không cần bảng Attributes) nên bị bỏ qua hoàn toàn khỏi loop Phase 2.

**Nguyên nhân gốc:** Vòng lặp Phase 2 "làm Nhóm N+1 → hết Nhóm cuối" chỉ lặp theo danh sách nhóm trong Phase 0 Plan, không đối chiếu lại với tổng số nhóm thực tế trong HLD Section 2.

**Kiểm tra:** Sau khi Phase 2 xử lý xong toàn bộ nhóm trong Plan, đối chiếu tập hợp số nhóm trong Detail Mapping với tập hợp số nhóm trong HLD Section 2 — báo danh sách nhóm bị thiếu hoàn toàn (0 dòng).

❌ HLD có 41 nhóm, Detail Mapping chỉ có 21 nhóm (20 nhóm PENDING toàn bộ bị bỏ sót hoàn toàn) → sai, dù mỗi nhóm có mặt đều đúng logic.

---

### L14 — Reuse KPI "Vốn hóa"/measure tổng hợp nhưng khác grain hiển thị với nhóm gốc (copy nhầm ngữ nghĩa)

**Pattern:** Một KPI aggregate (VD: "Vốn hóa" = SUM/MAX theo 1 chiều nhóm cụ thể) được thiết kế đúng ở Nhóm gốc, rồi các Nhóm khác ghi `ghi_chu = "Reuse từ Nhóm X"` và copy nguyên `logic` — nhưng Nhóm mới có **grain hiển thị khác hẳn** (VD: Nhóm gốc là dashboard theo rổ chỉ số — 1 dòng = 1 chỉ số, còn Nhóm reuse là bảng Top-N theo mã CK — 1 dòng = 1 mã CK). Cùng tên KPI ("Vốn hóa") và cùng ý nghĩa nghiệp vụ ở mức khái niệm, nhưng SAI grain tính toán khi đặt cạnh các cột khác của Nhóm mới (VD: đặt cạnh "Số CP lưu hành" của riêng 1 mã mà lại hiển thị Vốn hóa gộp CẢ RỔ CHỈ SỐ).

**Vì sao dễ lọt qua review thông thường:** KPI_ID giống nhau, `kpi_name` giống nhau, `logic` hợp lệ về mặt cú pháp (chạy được, không lỗi kỹ thuật), Attributes/Atomic parity đều PASS — lỗi chỉ lộ ra khi đối chiếu NGỮ CẢNH HIỂN THỊ (mockup/cột lân cận) của Nhóm reuse với Nhóm gốc, không phải lỗi cú pháp hay lỗi nguồn Atomic.

**Quy tắc bắt buộc khi gặp `ghi_chu` chứa "Reuse từ Nhóm X" trên bất kỳ dòng MEASURE/DERIVED nào có GROUP BY hoặc aggregate theo 1 chiều cụ thể (Index Code, Symbol, Company Code...):**
1. Mở mockup (hoặc bảng KPI) của CẢ Nhóm gốc VÀ Nhóm đang reuse.
2. Xác định grain hiển thị thật của Nhóm đang reuse: mỗi dòng kết quả tương ứng với 1 đơn vị gì? (1 mã CK? 1 chỉ số? 1 công ty?) — nhìn vào cột liền kề (VD: nếu đứng cạnh "Số CP lưu hành"/"Mã CK" của 1 dòng cụ thể → grain là mã CK, không phải chỉ số).
3. Xác nhận `GROUP BY`/`PARTITION BY` trong `logic` của dòng reuse khớp ĐÚNG với đơn vị đó — không mặc định giữ nguyên `GROUP BY` của Nhóm gốc chỉ vì đang "reuse công thức".
4. Nếu Nhóm gốc và Nhóm reuse có grain khác nhau (dù cùng tên KPI) → **không copy nguyên logic** — viết lại đúng theo đơn vị của Nhóm reuse (đổi `GROUP BY Index Code` → `GROUP BY Symbol` khi cần), giữ nguyên số liệu nguồn (Atomic) nhưng đổi mức tổng hợp.

**Kiểm tra:** Với mọi dòng có `ghi_chu` chứa "Reuse từ Nhóm" và `logic` có `GROUP BY`/`PARTITION BY`/`SUM`/`MAX` theo 1 chiều — bắt buộc trả lời được câu hỏi "1 dòng kết quả của Nhóm này = 1 [đơn vị] gì?" và đối chiếu với `GROUP BY` thực tế trong `logic`.

❌ **Case thật (GSTT, 2026-09-14):** `K_GSTT_61` ("Vốn hóa") ở Nhóm 6 ("Định giá thị trường" — mockup ghi rõ cột là "Vốn hóa TT (**theo Chỉ số**)", đúng vì đây là dashboard theo chỉ số) được reuse nguyên `logic` (`GROUP BY Index Code`) sang 8 Nhóm khác (7, 9, 11, 13, 19, 21, 32, 33 — toàn bộ là bảng Top-N **theo mã CK**, mockup đặt "Vốn hóa" ngay cạnh "Số CP lưu hành" của riêng 1 mã, không ghi "theo Chỉ số"). Kết quả: mọi mã CK trong cùng 1 rổ chỉ số hiển thị CÙNG 1 con số Vốn hóa (của cả rổ), thay vì vốn hóa riêng của từng mã. Lỗi cùng bản chất đã từng bị bắt riêng lẻ cho Nhóm 23 trước đó (2026-09-12, "GROUP BY index_constituent_dim.index_code là sai — copy nhầm ngữ nghĩa") nhưng không được tổng quát hóa thành rule để rà lại toàn bộ các Nhóm reuse khác — dẫn đến lỗi lặp lại ở quy mô 8 Nhóm, chỉ được phát hiện khi Data Modeler hỏi trực tiếp "tại sao nhóm tính theo mã CK lại lấy từ Fact của bộ chỉ số". Sửa: đổi `logic` thành `MAX(Giá đóng cửa × Số CP lưu hành) GROUP BY Symbol, Trade Date` cho cả 8 Nhóm + đồng bộ lại Nhóm 23 (HLD prose bị lệch so với Detail Mapping).

---

### L15 — REUSE sai quy cách: để trống cột (Case 1) hoặc gán cột ảo (Case 2)

**Pattern:**
- **Case 1 (Physical Measure/Dim):** Tái sử dụng measure/dim vật lý đã có sẵn trên Fact/Dim của nhóm trước nhưng lại để trống `mart_column` (hoặc cả `mart_table`) trong khi ghi chú có "Reuse" (ví dụ thực tế tại GSTT: `K_GSTT_100` để trống cột, `K_GSTT_90`, `91` để trống cột). Hậu quả: generator Phase 3 không xác định được cột SELECT, gây khuyết tật metadata Flat Table.
- **Case 2 (BI Presentation / Derived):** Tái sử dụng chỉ tiêu phái sinh/hiển thị BI nhưng lại tự bịa tên cột vật lý (ví dụ: gán cột `P/E Ratio` cho `K_GSTT_58`, `Market Cap` cho `K_GSTT_61`). Hậu quả: gây lỗi TC4/TC7 vì cột không tồn tại trong `datamart_attributes.csv`.

**Quy tắc:**
- **Case 1 (Physical Measure/Dim):** BẮT BUỘC điền đủ `mart_table` và `mart_column` (tên logical), `column_role` = `MEASURE`/`SLICER`, `logic` = phép tính physical.
- **Case 2 (BI Presentation / Derived):** BẮT BUỘC để trống `mart_table` và `mart_column`, `column_role` = `DERIVED`, `logic` = công thức physical đầy đủ.

**Kiểm tra:** Quét toàn bộ các dòng có `ghi_chu` chứa từ "Reuse":
- Nếu `column_role` in ('MEASURE', 'SLICER', 'FILTER') → kiểm tra `mart_table` và `mart_column` không được rỗng.
- Nếu `column_role` == 'DERIVED' → kiểm tra `mart_table` và `mart_column` bắt buộc phải rỗng.

❌ `K_GSTT_100` ghi "Reuse từ Nhóm 1" nhưng `mart_column` để trống → vi phạm L15 Case 1.
❌ `K_GSTT_58` role DERIVED nhưng điền `mart_table = "Fact Stock Portfolio Snapshot"`, `mart_column = "P/E Ratio"` → vi phạm L15 Case 2.

---

### L16 — Đánh tráo DEPRECATED thành PENDING gây phình to blocker

**Pattern:** Chỉ tiêu hoặc chiều phân tích đã được BA và Data Modeler thống nhất bãi bỏ vĩnh viễn (như `K_GSTT_6`, hoặc KPI phụ thuộc bảng draft bị hủy trong Cleanup Protocol) nhưng người thiết kế lại ghi nhận thành `PENDING` (để trống `column_role` hoặc ghi `ghi_chu = "Pending - chưa thiết kế nguồn"`).

**Hậu quả:** Làm sai lệch báo cáo tiến độ và KPI Reconciliation, biến chỉ tiêu đã được duyệt bỏ thành blocker ảo tồn đọng vô thời hạn.

**Quy tắc:**
- Chỉ tiêu bãi bỏ sau thống nhất BA → BẮT BUỘC ghi `column_role = 'DEPRECATED'`, `mart_table = ""`, `mart_column = ""`, `logic = "Đã loại bỏ — không tạo cột/slicer"`, `tinh_chat = "Deprecated"`, `ghi_chu` ghi rõ ngày + căn cứ/biên bản bãi bỏ.
- Phân biệt với BA Delete: Dòng BA có `Trạng thái mapping = Delete` ban đầu thì loại bỏ 100% (0 dòng trong Detail Mapping). Còn dòng DEPRECATED trong Datamart là chỉ tiêu từng có trong HLD/scope nay bãi bỏ (phải giữ dòng để bảo toàn số lượng đối soát HLD TC5).

**Kiểm tra:**
- Quét các dòng `column_role == 'DEPRECATED'`: phải đảm bảo `mart_table` và `mart_column` để trống, `logic` đúng chuẩn, và `ghi_chu` có căn cứ bãi bỏ.
- Quét các dòng PENDING: kiểm tra xem có dòng nào thực chất đã được thống nhất bãi bỏ không để chuyển sang `DEPRECATED`.

❌ Bãi bỏ chiều khớp lệnh `K_GSTT_6` nhưng để trống role và ghi `Pending - chưa thiết kế nguồn` → vi phạm L16.
❌ Xóa mất dòng `K_GSTT_6` khỏi Detail Mapping làm thiếu KPI so với HLD (FAIL TC5) → sai quy trình.
✅ Giữ dòng `K_GSTT_6` với `column_role = 'DEPRECATED'`, `mart_table = ""`, `mart_column = ""`, `logic = "Đã loại bỏ — không tạo cột/slicer"`.

---

### L17 — Bắt buộc bám sát Câu lệnh tham khảo (Reference SQL) & Điều kiện chung trong file BA

**Pattern:** 
File BA analyst (`BRD/BA/BA_analyst_{MODULE}.csv`) cung cấp các cột kỹ thuật rất chi tiết: `Câu lệnh tham khảo` (SQL mẫu), `Điều kiện chung`, `Bảng nguồn`, `Trường nguồn`, và `Note`.
Khi thiết kế Detail Mapping, nếu người thiết kế chỉ đọc tên chỉ tiêu (`Thông tin`) và `Phân loại` mà bỏ qua `Câu lệnh tham khảo` thì sẽ mắc các lỗi nghiêm trọng:
1. **Bỏ sót các điều kiện lọc tĩnh (`WHERE` clause):** Trong SQL tham khảo có điều kiện lọc sàn (`FloorCode IN ('10','02','04')`), loại trừ chứng khoán (`StockType NOT IN (1,4)`), phân loại bảng lệnh (`Board Type IN ('T1','T2','T3','T4','T6','R1')`), trạng thái hoạt động (`active_flg = 1`), hoặc phân loại nhà đầu tư (`Buyer/Seller Foreign Investor Type IN ('10','20')`). Nếu Detail Mapping không sinh các dòng `column_role = FILTER` tương ứng (hoặc Fact/Dim chưa nhúng trong ETL), dữ liệu tầng báo cáo sẽ bị lẫn tạp chất.
2. **Nhầm lẫn giữa các biến thể số đo (Measure Misalignment):**
   - **Khớp lệnh vs Thỏa thuận:** Khớp lệnh thuần (`Board Type NOT IN ('T1','T2','T3','T4','T6','R1')`) phải map sang `Total Matched Volume` / `total_matched_vol` và `Total Matched Value` / `total_matched_val`. TUYỆT ĐỐI KHÔNG map nhầm sang `Total Volume` / `total_vol` (vốn là số gộp cả thỏa thuận). Thỏa thuận phải map sang `Total Negotiated Volume` / `total_negotiated_vol`.
   - **Mua vs Bán vs Ròng:** Chỉ tiêu Mua / Bán / Ròng (NĐTNN, Tự doanh) phải đối chiếu đúng công thức trong SELECT của SQL tham khảo (ví dụ: `SUM(kl_nn_mua) - SUM(kl_nn_ban)` ➔ `foreign_net_vol`).
3. **Bỏ sót logic tính toán phái sinh (Window / Rolling / Lag / TTM):**
   - Các chỉ tiêu KLGDTB X ngày, Tỷ lệ KLGD / KLGDTB, Đỉnh/Đáy cũ X tháng, LNST 4 quý gần nhất (TTM) có logic rolling window chi tiết trong CTE / subquery của SQL tham khảo. Cần đọc SQL để viết đúng công thức trong cột `logic` và ghi chú rõ grain tính toán.

**Quy tắc bắt buộc:**
1. **Đọc trọn vẹn SQL tham khảo:** Trước khi thiết kế bất kỳ KPI nào, BẮT BUỘC mở file BA đọc cột `Câu lệnh tham khảo` + `Điều kiện chung` + `Note`.
2. **Bóc tách 4 thành phần:**
   - `SELECT` ➔ Đối chiếu số đo (`mart_column`, phép tính `SUM`/`COUNT`/`AVG` trong `logic`).
   - `WHERE` ➔ Tách thành các dòng `column_role = FILTER` explicit trong Detail Mapping (nếu Fact chưa lọc sẵn tại ETL).
   - `FROM/JOIN` ➔ Kiểm tra đủ Dimension và FK liên kết.
   - `GROUP BY` ➔ Đối chiếu grain của bảng Fact/Operational và các dòng `SLICER`/`GROUP_BY`.
3. **Ghi chú đối soát:** Nếu một điều kiện lọc trong SQL tham khảo đã được xử lý ngầm ở tầng ETL (ví dụ: Fact table chỉ nạp giao dịch khớp lệnh), cột `ghi_chu` của Detail Mapping phải ghi rõ: `"Đã lọc sẵn tại ETL Fact theo SQL tham khảo BA: <điều kiện>"`.

**Kiểm tra:**
- Với mọi chỉ tiêu có SQL tham khảo trong BA: kiểm tra xem mọi điều kiện `WHERE` đã được ánh xạ thành dòng `FILTER` hoặc ghi nhận trong ETL chưa.
- Kiểm tra `mart_column` và `logic` có phản ánh đúng biểu thức trong mệnh đề `SELECT` của SQL tham khảo không.

❌ BA SQL có `Board Type NOT IN ('T1','T2','T3','T4','T6','R1')` (khớp lệnh thuần) nhưng Detail Mapping lại map vào `Total Volume` / `SUM(total_vol)` (gộp thỏa thuận) → vi phạm L17.
❌ BA SQL có `FloorCode IN ('10','02','04') AND StockType NOT IN (1,4)` nhưng Detail Mapping không có dòng FILTER Stock Type Code tương ứng → vi phạm L17.
✅ Phản ánh đầy đủ dòng FILTER `Stock Type Code`, và map đúng `Total Matched Volume` / `SUM(total_matched_vol)` cho chỉ tiêu khớp lệnh.

---

### Checklist bổ sung — kiểm tra trước khi giao file Phase 2

```
□ L1: Mọi SLICER/FILTER Chiều thời gian → logic trỏ đúng physical_table của nhóm đó (không phải bảng nhóm khác)
□ L2: Mọi physical_table.physical_column trong logic → tồn tại trong Attributes.csv của bảng tương ứng
□ L3: Operational table → không có dòng FILTER cdr_dt_dim (chỉ SLICER date column trực tiếp)
□ L4: HLD nhóm PENDING hoặc KPI PENDING đơn lẻ → toàn bộ 4 cột mart_table/mart_column/column_role/logic trống; ghi_chu phân loại theo 5 nhóm chuẩn hóa
□ L5: Nhóm copy từ nhóm khác → scan kpi_name kiểm tra không còn tên ngữ cảnh cũ
□ L6: Mọi physical_table trong logic → là bảng thuộc nhóm đó (không phải bảng nhóm khác)
□ L7: Nhóm PENDING → mỗi kpi_id chỉ có 1 dòng (không duplicate)
□ L8: Không có giá trị <TBD> hoặc placeholder chưa xác định trong cột logic
□ L9: Cột nhom → tên đầy đủ theo HLD (không chỉ "Nhóm X" — phải có phần tên ngắn)
□ L10: DERIVED _YOY → logic viết bằng physical column theo template rút gọn (không refer KPI_ID)
□ L11: Mỗi Operational table (opr_*) có src_stm_code → có đúng 1 dòng FILTER logic="src_stm_code = '<VALUE>'" ngay sau JOIN_KEY đầu tiên; Dimension table → không thêm FILTER này
□ L12: Cột nhom theo thứ tự dòng trong file → số nhóm xuất hiện lần đầu phải tăng dần 1, 2, ..., N_max (parse bằng regex, không so sánh string) — nếu phát hiện lệch, sắp xếp lại toàn file
□ L13: Tổng số nhóm trong Detail Mapping (cột nhom, unique) = tổng số nhóm trong HLD Section 2 (kể cả nhóm PENDING toàn bộ không có bảng Attributes nào) — không dùng danh sách nhóm từ Phase 0 Plan để xác định "đã xong"
□ L14: Mọi dòng `ghi_chu` chứa "Reuse từ Nhóm X" mà `logic` có GROUP BY/PARTITION BY/SUM/MAX theo 1 chiều cụ thể → xác định grain hiển thị thật của Nhóm đang reuse (nhìn cột lân cận trong mockup: 1 dòng = 1 mã CK hay 1 chỉ số hay 1 công ty?) và đối chiếu đúng với GROUP BY trong logic — KHÔNG mặc định giữ nguyên GROUP BY của Nhóm gốc chỉ vì đang copy công thức
□ L15: Mọi dòng REUSE Case 1 (measure/dim vật lý) → điền đầy đủ mart_table và mart_column; Mọi dòng REUSE Case 2 (presentation/derived) → để trống mart_table và mart_column, column_role = DERIVED (không tạo cột ảo)
□ L16: Mọi chỉ tiêu đã thống nhất bãi bỏ với BA → column_role = DEPRECATED, mart_table/mart_column để trống, logic = 'Đã loại bỏ — không tạo cột/slicer' — TUYỆT ĐỐI KHÔNG đánh tráo thành PENDING
□ L17: Bám sát Câu lệnh tham khảo (Reference SQL) & Điều kiện chung trong file BA: đọc trọn vẹn SQL tham khảo, bóc tách WHERE clause thành dòng FILTER, ánh xạ đúng số đo trong SELECT (khớp lệnh vs thỏa thuận, mua vs bán vs ròng, rolling window), ghi rõ vào ghi_chu nếu đã lọc ngầm ở ETL Fact
```

> **L12 và L13 là 2 testcase module-level** (chạy 1 lần sau khi TOÀN BỘ nhóm đã xử lý, tương ứng TC6 và TC5 trong `SKILL.md`) — khác với L1–L11 vốn kiểm tra trong phạm vi từng nhóm/dòng riêng lẻ.

---

## Quy trình đối chiếu BA trước khi sinh

**Bước 0 — Cross-check BA ↔ HLD ↔ Detail Mapping (BẮT BUỘC — thực hiện trước bước 1):**

**0.a — Kiểm tra độ phủ BA → HLD:**
1. Với mỗi dòng BA có `Trạng thái mapping ∈ {Done, Doing, Pending}` (kể cả `Phân loại = Chiều`):
   - ⛔ **LOẠI BỎ CHỈ TIÊU DELETE:** Nếu dòng BA có `Trạng thái mapping` là `Delete` (hoặc `DELETE`, `Xóa`, `Xoá`, `DELETED`) → **TUYỆT ĐỐI KHÔNG ĐƯỢC ĐƯA VÀO DETAIL MAPPING**, không kiểm tra KPI_ID, không sinh dòng mapping.
   - Tìm KPI_ID tương ứng trong bảng KPI của nhóm đó trong HLD
   - Nếu KPI_ID chưa có trong HLD → **DỪNG**, báo cáo danh sách thiếu theo nhóm
2. ❌ Không tự sinh KPI_ID mới — KPI_ID mới phải được khai sinh trong HLD trước
3. ❌ Không bỏ qua dòng `Phân loại = Chiều` — Chiều cũng cần KPI_ID riêng
4. ❌ Không dùng shorthand "xem nhóm khác" — mỗi nhóm phải có đủ KPI_ID explicit trong output
5. Chỉ tiếp tục bước 0.b khi **tất cả** dòng Done/Doing/Pending từ BA đều đã có KPI_ID trong HLD

**0.b — Kiểm tra số lượng (đếm và báo cáo trước khi sinh):**
1. Đếm **tổng dòng BA** có `Trạng thái ∈ {Done, Doing, Pending}` (TUYỆT ĐỐI LOẠI BỎ các dòng có `Trạng thái = Delete / DELETED / Xóa`; kể cả dòng bị đánh dấu trùng trong cột `Đánh giá`) → gọi là **N_BA**
2. Đếm số dòng BA **unique** sau khi loại trùng theo cột `Đánh giá` → gọi là **N_KPI** (= số KPI_ID cần có trong HLD)
3. Báo cáo cho user trước khi sinh:
   > "BA có **N_BA** dòng cần mapping, trong đó **N_KPI** KPI unique (sau loại trùng theo cột Đánh giá). Detail Mapping output sẽ có tối thiểu N_BA dòng và đúng N_KPI KPI_ID unique."
4. Sau khi sinh xong → kiểm tra:
   - Số dòng trong Detail Mapping ≥ N_BA (≥ vì 1 dòng BA có thể sinh nhiều dòng MEASURE/FILTER/SLICER)
   - Nếu có dòng BA nào không tìm thấy trong output → báo danh sách trước khi giao file

**0.c — Kiểm tra tính hợp lệ Detail Mapping → HLD (sau khi sinh):**
1. Lấy danh sách KPI_ID unique trong Detail Mapping output
2. Số KPI_ID unique phải = **N_KPI**
3. Đối chiếu từng KPI_ID với bảng KPI trong HLD — nếu có KPI_ID nào không tìm thấy → **báo cáo danh sách** và yêu cầu khai sinh trong HLD trước khi giao file
4. ❌ Không giao file Detail Mapping khi còn KPI_ID chưa được khai trong HLD

**Bước 1 — Lọc và chuẩn bị:**

1. Lọc Done/Doing/Pending từ BA file (LOẠI TRỪ 100% dòng có `Trạng thái mapping = Delete / DELETED / Xóa`)
2. Xác định `mart_table` + `mart_column` từ Attributes.csv cho từng dòng
3. Nếu không tìm được → `ghi_chu = "Thiếu cột trong mart — cần bổ sung Attributes"`
4. Tra bảng KPI trong HLD (`Tính chất` + `Công thức`) trước khi điền `column_role`:
   - `Phái sinh` → bắt buộc `DERIVED`; mart_table/mart_column để trống
   - Công thức có `RANK()`, `ROW_NUMBER()`, tham chiếu KPI ID → bắt buộc `DERIVED`

---

## Ví dụ đại diện

```csv
"kpi_id","tab","nhom","kpi_name","tinh_chat","source_module","mart_table","mart_column","column_role","logic","ghi_chu"
"K_GSTT_1","TỔNG QUAN","Nhóm 1 — Thị trường cổ phiếu","Số mã chứng khoán niêm yết","Base","GSTT","Fact Stock Portfolio Snapshot","Listed Stock Count","MEASURE","COUNT(fct_stock_portfolio_snpst.scr_code)",""
"K_GSTT_1","TỔNG QUAN","Nhóm 1 — Thị trường cổ phiếu","Số mã chứng khoán niêm yết","Base","GSTT","Fact Stock Portfolio Snapshot","Snapshot Date Dimension Id","FILTER","JOIN cdr_dt_dim ON cdr_dt_dim.cdr_dt_dim_id = fct_stock_portfolio_snpst.snpst_dt_dim_id WHERE cdr_dt_dim.yr = :Y AND cdr_dt_dim.mo = :M",""
"K_GSTT_5","TỔNG QUAN","Nhóm 1 — Thị trường cổ phiếu","Sàn giao dịch","Base","GSTT","Stock Exchange Dimension","Stock Exchange Code","SLICER","stock_exch_dim.exch_code",""
"K_GSTT_12","TỔNG QUAN","Nhóm 1 — Thị trường cổ phiếu","% Thay đổi giá","Phái sinh","GSTT","","","DERIVED","security_trading_snpst_dim.price_change / security_trading_snpst_dim.reference_price * 100","Tính tại presentation layer từ 2 cột Dimension"
"K_GSTT_13","GIAO DỊCH","Nhóm 7 — Top giao dịch cổ phiếu","Khối lượng giao dịch khớp lệnh","Base","GSTT","Fact Stock Portfolio Snapshot","Total Volume","MEASURE","SUM(fct_stock_portfolio_snpst.total_vol)","Reuse từ Nhóm 1 (K_GSTT_13) — measure có sẵn trên Fact Stock Portfolio Snapshot"
"K_GSTT_58","ĐỊNH GIÁ","Nhóm 7 — Top cổ phiếu theo P/E","Chỉ số P/E","Phái sinh","GSTT","","","DERIVED","security_trading_snpst_dim.close_price / (fct_stock_portfolio_snpst.net_profit_after_tax_ttm / fct_stock_portfolio_snpst.outstanding_share_quantity)","Reuse từ Nhóm 6 (K_GSTT_58) — tính toán tại presentation layer, không lưu cột riêng trên Fact"
"K_GSTT_6","PHÂN TÍCH","Nhóm 1 — Bảng số liệu","Phương thức khớp lệnh (thỏa thuận)","Deprecated","GSTT","","","DEPRECATED","Đã loại bỏ — không tạo cột/slicer","Resolved 2026-09-08 (Deprecated) — Loại bỏ khỏi danh mục Chiều/Slicer vì không có giá trị khai thác độc lập. Nghiệp vụ hiển thị trực tiếp 4 cột measure riêng biệt: Khớp lệnh (K_GSTT_13/14) và Thỏa thuận (K_GSTT_17/18)."
"K_QLKD_3039","CHI TIẾT","Nhóm 23 — Báo cáo tài chính","Doanh thu hoạt động môi giới","Base","QLKD","","","","","Pending - [Nhóm 3 - Thiếu nguồn Atomic]: gap Atomic REPORT_CELL_VALUE, xem O_QLKD_23"
```
