# QLRR — Tài liệu khảo sát nguồn & ánh xạ Silver

**Phân hệ:** QLRR — Quản lý rủi ro về thị trường chứng khoán
**Mục đích:** Tổng hợp nghiệp vụ nguồn, quan hệ bảng CSDL, và ánh xạ Silver entity theo từng nhóm chức năng (UID) — làm tham chiếu cho thiết kế Silver layer.
**Nguồn tài liệu:**
- Đặc tả yêu cầu: `New_UBCKNN_Dac_ta_yeu_cau_QLRR_09_03_2026.docx`
- Thiết kế CSDL: `New_UBCKNN_Thiet_ke_co_so_du_lieu_QLRR_02_04_2026.docx`
- HLD Silver Overview: `RISK_HLD_Overview.md` (phần 7a, 7c, 7d, 7f)
- Classification registry: `ref_shared_entity_classifications.csv`

---

## Bảng quy ước

| Ký hiệu | Ý nghĩa |
|---|---|
| 🟢 **Tên entity** | Silver entity được thiết kế (xem HLD 7a) |
| 🟢 `CV: SCHEME_CODE` | Classification Value — danh mục mã hóa (xem HLD 7c và registry CSV) |
| 🟢 ↳ denormalize vào *Entity* | Junction table flatten vào entity chính (QLRR không có — xem HLD 7d) |
| 🔴 (Out of scope) *lý do* | Ngoài scope Silver (xem HLD 7f) |
| ├── └── | Quan hệ FK cha-con theo tree |
| *(xem X.X)* | Bảng đã mô tả ở sub-section khác — tránh lặp |

**Lưu ý riêng cho QLRR:** Phân hệ không có bảng `DM_*` dictionary riêng — các giá trị danh mục (bộ chỉ tiêu, tần suất, đơn vị, trạng thái, loại sự kiện, kênh thông báo…) lưu dưới dạng enum/code inline trong bảng nghiệp vụ. Các enum này được chuẩn hóa thành **17 Classification Value schemes** trong Silver (xem Phụ lục).

---

## Mục lục

- [QLRR001 — Khai thác Dashboard](#qlrr001--khai-thác-dashboard)
- [QLRR002 — Khai thác Báo cáo](#qlrr002--khai-thác-báo-cáo)
- [QLRR003 — Khai thác Chỉ tiêu tài chính trong nước](#qlrr003--khai-thác-chỉ-tiêu-tài-chính-trong-nước)
- [QLRR004 — Khai thác Chỉ tiêu tài chính quốc tế](#qlrr004--khai-thác-chỉ-tiêu-tài-chính-quốc-tế)
- [QLRR005 — Quản lý Cảnh báo](#qlrr005--quản-lý-cảnh-báo)
- [QLRR006 — Khai thác Phân quyền dữ liệu](#qlrr006--khai-thác-phân-quyền-dữ-liệu)
- [QLRR007 — Quản lý tích hợp](#qlrr007--quản-lý-tích-hợp)
- [Phụ lục — Danh mục dùng chung & Classification Values](#phụ-lục--danh-mục-dùng-chung--classification-values)

---

## QLRR001 — Khai thác Dashboard

**Mô tả nghiệp vụ tổng quan:** Cho phép Lãnh đạo và Chuyên viên Ban Phát triển thị trường (LĐPTTT, CVPTTT) khai thác biểu đồ các chỉ tiêu tài chính quan trọng — tăng trưởng kinh tế, lạm phát, tỷ giá, lãi suất, các chỉ số thị trường chứng khoán (VN-Index, HNX-Index, VN30…), cơ cấu nhà đầu tư, huy động vốn — cùng số lượng cảnh báo phát sinh. Dashboard là điểm tổng hợp, không tạo mới dữ liệu — chỉ đọc từ các bảng chỉ tiêu và cảnh báo.

### 1.1. Khai thác biểu đồ tổng hợp chỉ tiêu và cảnh báo

**Nghiệp vụ:** Hiển thị biểu đồ xu hướng các chỉ tiêu theo kỳ (ngày/tháng/quý/năm) với nhóm lọc theo `category_code`, hiển thị giá trị hiện tại và kỳ trước, kèm số lượng cảnh báo đang phát sinh. Các giá trị mã hóa (bộ chỉ tiêu, tần suất, đơn vị) được chuẩn hóa thành CV: `RISK_INDICATOR_SET`, `RISK_PERIOD_TYPE`, `RISK_UNIT`.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `risk_indicator_category` | Nhóm chỉ tiêu — dùng để filter biểu đồ theo nhóm (vĩ mô, tiền tệ, cổ phiếu…) | 🟢 **Risk Indicator Category** |
| └── `risk_indicator` | Master chỉ tiêu — FK `category_id` → category | 🟢 **Risk Indicator** |
| &nbsp;&nbsp;&nbsp;&nbsp;├── `risk_indicator_value` | Giá trị hiện tại theo kỳ — nguồn dữ liệu của biểu đồ | 🟢 **Risk Indicator Value** |
| &nbsp;&nbsp;&nbsp;&nbsp;└── `risk_indicator_value_history` | Lịch sử giá trị — dùng để vẽ xu hướng theo thời gian | 🟢 **Risk Indicator Value Change** |
| `risk_alert` | Đếm cảnh báo phát sinh hiển thị trên dashboard | 🟢 **Risk Alert** *(xem 5.2)* |

*Classification Values liên quan:* `RISK_INDICATOR_SET`, `RISK_PERIOD_TYPE`, `RISK_UNIT`, `RISK_ALERT_STATUS`.

---

## QLRR002 — Khai thác Báo cáo

**Mô tả nghiệp vụ tổng quan:** LĐPTTT, CVPTTT tổng hợp dữ liệu chỉ tiêu thành các báo cáo đầu ra theo biểu mẫu quy định (Báo cáo nhanh hàng tháng, Báo cáo chi tiết theo chiến lược phát triển ngành chứng khoán). Luồng gồm: chọn loại báo cáo → chọn tham số kỳ → phân hệ dùng cấu hình placeholder để trích dữ liệu từ chỉ tiêu → xuất file → upload file gốc. Ứng với **BP1 — Quy trình tổng hợp báo cáo** trong đặc tả.

### 2.1. Khai thác loại báo cáo và template

**Nghiệp vụ:** Quản lý danh mục loại báo cáo và template kèm placeholder `{{CODE}}`. Cấu hình placeholder định nghĩa mỗi placeholder trỏ đến cột dữ liệu nào trong CSDL nguồn hoặc công thức. Cấu hình này là thông tin kỹ thuật runtime, không lưu xuống Silver.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `risk_report_type` | Danh mục loại báo cáo + template content | 🟢 **Risk Report Type** |
| └── `risk_report_placeholder_config` | Cấu hình mapping placeholder ↔ nguồn dữ liệu | 🔴 (Out of scope) *Config kỹ thuật — operational/system data* |

### 2.2. Tổng hợp và upload báo cáo kết quả

**Nghiệp vụ:** Người dùng chọn loại báo cáo + kỳ báo cáo (`report_date`), phân hệ tổng hợp dữ liệu chỉ tiêu và xuất file. Mỗi lượt xuất tạo một batch; mỗi batch có thể gồm nhiều file (DOCX, XLSX, PDF…). CV liên quan: `RISK_FILE_TYPE`.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `risk_report_type` | Loại báo cáo được tổng hợp | 🟢 **Risk Report Type** *(xem 2.1)* |
| └── `risk_report_upload_batch` | Lượt tổng hợp/upload — 1 lần xuất = 1 batch | 🟢 **Risk Report Upload Batch** |
| &nbsp;&nbsp;&nbsp;&nbsp;└── `risk_report_file` | File kết quả (nhiều file/batch) | 🟢 **Risk Report File** |
| `risk_indicator` | Nguồn chỉ tiêu được tổng hợp vào báo cáo | 🟢 **Risk Indicator** *(xem 3.1)* |
| `risk_indicator_value` | Số liệu đưa vào báo cáo | 🟢 **Risk Indicator Value** *(xem 3.1)* |

*Classification Values liên quan:* `RISK_FILE_TYPE`.

---

## QLRR003 — Khai thác Chỉ tiêu tài chính trong nước

**Mô tả nghiệp vụ tổng quan:** LĐPTTT, CVPTTT xem thông tin các chỉ tiêu tài chính trong nước theo **10 nhóm**: (I) Yếu tố vĩ mô (GDP, CPI, FDI, Vốn FDI), (II) Yếu tố tiền tệ và tín dụng (thu/chi ngân sách, tỷ giá VND/USD, lãi suất liên ngân hàng, lãi suất TPCP, CAR, tỷ lệ nợ xấu), (III.1) Thị trường cổ phiếu (VN-Index, HNX-Index, Upcom-Index, VN100, VN30, số lượng niêm yết, vốn hóa, khối lượng giao dịch, P/E, tỷ lệ margin), (III.2) Phái sinh (HĐTL VN30, HĐTL TPCP, Open Interest, Basis), (III.3) TPCP, (III.4) TPDN, (III.5) Thị trường quỹ (CTQLQ, quỹ đóng/mở/ETF/BĐS, AUM), (III.6) Dòng vốn NĐTNN, (III.7) Tỷ lệ sở hữu NĐTNN, (III.8) Cơ cấu NĐT, (III.9) CTCK (số lượng, tổng tài sản, VCSH, CAR, margin), (III.10) Huy động vốn cổ phần, (IV) Chỉ tiêu khác (ROA/ROE ngành, thanh tra-vi phạm, ngân hàng lưu ký/thanh toán). Cả 10 nhóm này **chia sẻ cùng schema dữ liệu** — chỉ khác filter `set_code = 1 (Trong nước)` và `category_id`.

### 3.1. Khai thác danh mục chỉ tiêu trong nước và số liệu theo kỳ

**Nghiệp vụ:** Mỗi chỉ tiêu có các thuộc tính: mã, tên, nhóm, tần suất (ngày/tháng/quý/năm), đơn vị, nguồn, giá trị kỳ trước/hiện tại/chênh lệch. Người dùng có thể tạo chỉ tiêu tự tạo (`risk_indicator_custom`) — được gộp chung với chỉ tiêu hệ thống thành entity `Risk Indicator` duy nhất trong Silver, phân biệt qua CV `RISK_INDICATOR_TYPE` (1=hệ thống, 2=tự tạo). Dữ liệu đến từ 2 nguồn: API đồng bộ (CSDL tập trung) hoặc người dùng chỉnh sửa thủ công — phân biệt qua CV `RISK_DATA_ORIGIN`.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `risk_indicator_category` | Nhóm chỉ tiêu (`set_code=1` = Trong nước; `category_code`: MACRO, MONETARY, STOCK_MARKET, DERIVATIVES, GOV_BOND, CORP_BOND, FUND, FOREIGN_INVESTOR, SECURITIES_FIRM…) | 🟢 **Risk Indicator Category** |
| └── `risk_indicator` | Master chỉ tiêu hệ thống — FK `category_id` | 🟢 **Risk Indicator** |
| &nbsp;&nbsp;&nbsp;&nbsp;├── `risk_indicator_value` | Số liệu hiện tại theo kỳ | 🟢 **Risk Indicator Value** |
| &nbsp;&nbsp;&nbsp;&nbsp;└── `risk_indicator_value_history` | Lịch sử thay đổi số liệu (SYNC/UPDATE) | 🟢 **Risk Indicator Value Change** |
| `risk_indicator_custom` | Chỉ tiêu tự tạo bởi người dùng | 🟢 **Risk Indicator** *(gộp cùng entity — phân biệt qua CV `RISK_INDICATOR_TYPE`)* |

*Classification Values liên quan:* `RISK_INDICATOR_SET`, `RISK_INDICATOR_TYPE`, `RISK_UNIT`, `RISK_DATA_SOURCE`, `RISK_PERIOD_TYPE`, `RISK_DATA_ORIGIN`, `RISK_INDICATOR_CHANGE_TYPE`.

---

## QLRR004 — Khai thác Chỉ tiêu tài chính quốc tế

**Mô tả nghiệp vụ tổng quan:** LĐPTTT, CVPTTT xem các chỉ số kinh tế-thị trường quốc tế: Lạm phát Mỹ, Chỉ số DXY, Shanghai Composite (SSE), FTSE 100, Nikkei 225, KOSPI, BSE Sensex, S&P 500, PSEi, FTSE Bursa Malaysia, IDX Composite, STI, SET, GDP Mỹ/EU/Nhật Bản/Trung Quốc. Nguồn dữ liệu ưu tiên: Investing. Tần suất mặc định: tháng.

### 4.1. Khai thác danh mục chỉ tiêu quốc tế và số liệu theo kỳ

**Nghiệp vụ:** Cùng schema với chỉ tiêu trong nước — chỉ khác filter `set_code = 2 (Quốc tế)` và `source_code = 1 (Investing)` là mặc định. Việc phân biệt trong nước / quốc tế hoàn toàn ở tầng Silver thông qua CV `RISK_INDICATOR_SET`, không cần entity riêng.

**Quan hệ dữ liệu:** Bảng và quan hệ **giống hệt mục 3.1** — chỉ khác giá trị `set_code`.

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `risk_indicator_category` | Nhóm chỉ tiêu quốc tế (`set_code=2`) | 🟢 **Risk Indicator Category** *(xem 3.1)* |
| └── `risk_indicator` | Master chỉ tiêu quốc tế | 🟢 **Risk Indicator** *(xem 3.1)* |
| &nbsp;&nbsp;&nbsp;&nbsp;├── `risk_indicator_value` | Số liệu theo kỳ | 🟢 **Risk Indicator Value** *(xem 3.1)* |
| &nbsp;&nbsp;&nbsp;&nbsp;└── `risk_indicator_value_history` | Lịch sử thay đổi | 🟢 **Risk Indicator Value Change** *(xem 3.1)* |
| `risk_indicator_custom` | Chỉ tiêu tự tạo (dùng chung với trong nước) | 🟢 **Risk Indicator** *(xem 3.1)* |

*Classification Values liên quan:* giống 3.1 — phân biệt qua `RISK_INDICATOR_SET = 2`.

---

## QLRR005 — Quản lý Cảnh báo

**Mô tả nghiệp vụ tổng quan:** Theo dõi các chỉ tiêu đã thiết lập ngưỡng, phát hiện khi vượt ngưỡng, đánh giá, xử lý và lưu vết. Các chỉ tiêu được giám sát gồm: Tỷ giá trung tâm VND/USD, VnIndex, Giá trị mua-bán ròng NĐTNN, HĐTL VN30, Huy động vốn cổ phần qua TTCK, ROA/ROE ngành, Tổng tài sản/VCSH/dư nợ ký quỹ của hệ thống CTCK. Ứng với **BP2 — Quy trình cảnh báo và xử lý cảnh báo**. Luồng gồm 4 giai đoạn: (1) cấu hình ngưỡng, (2) phát sinh cảnh báo khi rà soát, (3) xử lý cảnh báo, (4) thông báo.

### 5.1. Thiết lập cấu hình cảnh báo

**Nghiệp vụ:** LĐPTTT, CVPTTT thiết lập cấu hình cảnh báo cho mỗi chỉ tiêu gồm: chiều ngưỡng (tăng/giảm/cả hai), giá trị ngưỡng, đơn vị, số kỳ so sánh, template nội dung cảnh báo, người xử lý chính, và các kênh thông báo (toast/bell/email). Cấu hình áp dụng cho cả chỉ tiêu hệ thống (`indicator_id`) và chỉ tiêu tự tạo (`custom_indicator_id`) — phân biệt qua trường `indicator_type`.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `risk_alert_config` | Cấu hình ngưỡng cảnh báo + người xử lý | 🟢 **Risk Alert Config** |
| &nbsp;&nbsp;*FK →* `risk_indicator` | Chỉ tiêu hệ thống được giám sát (khi `indicator_type=1`) | 🟢 **Risk Indicator** *(xem 3.1)* |
| &nbsp;&nbsp;*FK →* `risk_indicator_custom` | Chỉ tiêu tự tạo được giám sát (khi `indicator_type=2`) | 🟢 **Risk Indicator** *(gộp — xem 3.1)* |

*Classification Values liên quan:* `RISK_ALERT_THRESHOLD_DIRECTION`, `RISK_UNIT`, `RISK_INDICATOR_TYPE`.

### 5.2. Phát sinh cảnh báo

**Nghiệp vụ:** Định kỳ (chạy theo job — xem 7.1), hệ thống tự động rà soát giá trị chỉ tiêu so với ngưỡng đã cấu hình. Khi vượt ngưỡng, tạo bản ghi cảnh báo lưu giá trị hiện tại/kỳ trước/chênh lệch, nội dung cảnh báo (render từ template), thời điểm phát sinh, job trigger, và trạng thái ban đầu (`status=0` — Chưa xử lý). Hỗ trợ cả kích hoạt tự động và thủ công — `triggered_by_job_id` nullable.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `risk_alert_config` | Cấu hình gốc sinh ra cảnh báo | 🟢 **Risk Alert Config** *(xem 5.1)* |
| └── `risk_alert` | Bản ghi cảnh báo thực tế — FK `alert_config_id` | 🟢 **Risk Alert** |
| &nbsp;&nbsp;*FK →* `risk_indicator` / `risk_indicator_custom` | Chỉ tiêu bị cảnh báo | 🟢 **Risk Indicator** *(xem 3.1)* |
| &nbsp;&nbsp;*FK →* `risk_indicator_schedule` | Job trigger (nullable — null nếu kích hoạt thủ công) | 🟢 **Risk Indicator Schedule** *(xem 7.1)* |

*Classification Values liên quan:* `RISK_ALERT_STATUS`, `RISK_ALERT_THRESHOLD_DIRECTION`, `RISK_UNIT`.

### 5.3. Xử lý cảnh báo

**Nghiệp vụ:** Quản trị/người được giao kiểm tra cảnh báo và phân loại: cần xử lý (Detailed — đính kèm báo cáo giải trình) hoặc không cần xử lý (Quick — bỏ qua). Với loại Detailed, người dùng nhập nội dung giải trình và upload file báo cáo xử lý. Phân hệ cập nhật trạng thái cảnh báo sang "Đã xử lý" và lưu toàn bộ lịch sử dòng thời gian (phát sinh → xử lý).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `risk_alert` | Cảnh báo được xử lý | 🟢 **Risk Alert** *(xem 5.2)* |
| ├── `risk_alert_resolution` | Bản ghi xử lý — Quick / Detailed | 🟢 **Risk Alert Resolution** |
| │&nbsp;&nbsp;&nbsp;└── `risk_alert_resolution_file` | File giải trình đính kèm (Detailed only) | 🟢 **Risk Alert Resolution File** |
| └── `risk_alert_history` | Log sự kiện theo dòng thời gian — FK cả `alert_id` và `resolution_id` (resolution_id nullable) | 🟢 **Risk Alert History** |

*Classification Values liên quan:* `RISK_ALERT_RESOLUTION_TYPE`, `RISK_ALERT_EVENT_TYPE`, `RISK_ALERT_STATUS`, `RISK_FILE_TYPE`.

### 5.4. Thông báo cảnh báo

**Nghiệp vụ:** Phát hành thông báo cho người dùng qua 3 kênh: toast (pop-up trên UI), bell (chuông thông báo trong app), email (gửi cho `handler_user_id`). Lưu trạng thái gửi (thành công/thất bại, lỗi nếu có) và trạng thái đọc của người nhận.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `risk_alert` | Cảnh báo nguồn phát thông báo | 🟢 **Risk Alert** *(xem 5.2)* |
| └── `risk_notification` | Thông báo gửi đi (toast/bell/email) | 🟢 **Risk Alert Notification** |

*Classification Values liên quan:* `RISK_NOTIFICATION_TYPE`, `RISK_NOTIFICATION_SEND_STATUS`, `RISK_NOTIFICATION_READ_STATUS`.

---

## QLRR006 — Khai thác Phân quyền dữ liệu

**Mô tả nghiệp vụ tổng quan:** Cấu hình phân quyền dữ liệu các chỉ tiêu theo nhóm quyền: mỗi nhóm quyền chứa tập người dùng và tập chỉ tiêu được phép xem. Cho phép tìm kiếm cấu hình theo mã/tên chỉ tiêu. Luồng này hoàn toàn là **thao tác vận hành hệ thống** — không tạo dữ liệu nghiệp vụ.

### 6.1. Cấu hình nhóm quyền và phân quyền dữ liệu

**Nghiệp vụ:** Quản trị phân hệ tạo/sửa/xóa nhóm quyền, thêm người dùng vào nhóm, gán tập chỉ tiêu mà nhóm được phép xem. Phân hệ filter dữ liệu chỉ tiêu theo cấu hình khi user truy cập.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `permission_group` | Nhóm quyền | 🔴 (Out of scope) *Operational/system data — không có giá trị nghiệp vụ* |
| ├── `permission_group_user` | Gán user vào nhóm | 🔴 (Out of scope) *Operational/system data* |
| └── `permission_group_indicator` | Gán chỉ tiêu được phép xem | 🔴 (Out of scope) *Operational/system data* |
| `risk_indicator` | Đối tượng được phân quyền | 🟢 **Risk Indicator** *(xem 3.1)* |

*Ghi chú:* Cả 3 bảng phân quyền đều **ngoài scope Silver** theo HLD 7f — quyền xem dữ liệu là tầng ứng dụng, không phải tầng dữ liệu phân tích.

---

## QLRR007 — Quản lý tích hợp

**Mô tả nghiệp vụ tổng quan:** Đồng bộ dữ liệu chỉ tiêu với Phân hệ Danh mục điện tử dùng chung của UBCKNN qua API. Cấu hình lịch chạy job (tần suất: giờ/ngày/tháng/quý/năm hoặc cron expression), theo dõi lịch sử chạy (thành công/thất bại, lỗi, số lần chạy).

### 7.1. Cấu hình và thực thi job đồng bộ chỉ tiêu

**Nghiệp vụ:** Mỗi chỉ tiêu có thể cấu hình 1 job đồng bộ (quan hệ 1-1 giữa `risk_indicator` và `risk_indicator_schedule`). Job lấy dữ liệu từ Danh mục điện tử dùng chung và ghi vào `risk_indicator_value` (đồng thời tạo bản ghi `risk_indicator_value_history` với `change_type = SYNC`). Khi job phát hiện chỉ tiêu vượt ngưỡng, tạo bản ghi cảnh báo với `triggered_by_job_id` (xem 5.2).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `risk_indicator` | Chỉ tiêu cần đồng bộ | 🟢 **Risk Indicator** *(xem 3.1)* |
| └── `risk_indicator_schedule` | Cấu hình + trạng thái job (1-1 với chỉ tiêu) | 🟢 **Risk Indicator Schedule** |
| `risk_indicator_value` | Đích ghi dữ liệu đồng bộ | 🟢 **Risk Indicator Value** *(xem 3.1)* |
| `risk_indicator_value_history` | Log thay đổi khi sync (`change_type = SYNC`) | 🟢 **Risk Indicator Value Change** *(xem 3.1)* |
| `risk_indicator_category` | Nhóm chỉ tiêu được đồng bộ | 🟢 **Risk Indicator Category** *(xem 3.1)* |

*Classification Values liên quan:* `RISK_JOB_FREQUENCY_TYPE`, `RISK_JOB_RUN_STATUS`, `RISK_INDICATOR_CHANGE_TYPE`, `RISK_DATA_SOURCE`.

---

## Phụ lục — Danh mục dùng chung & Classification Values

### A. Bảng dùng chung xuyên suốt nhiều UID

QLRR **không có bảng `DM_*` dictionary riêng**. Các bảng sau đóng vai trò master được tham chiếu xuyên UID:

| Bảng | Ý nghĩa | Sử dụng bởi | Ánh xạ Silver |
|---|---|---|---|
| `risk_indicator_category` | Nhóm chỉ tiêu (vĩ mô, tiền tệ, cổ phiếu…) | QLRR001, QLRR003, QLRR004, QLRR007 | 🟢 **Risk Indicator Category** |
| `risk_indicator` | Master chỉ tiêu hệ thống | QLRR001, QLRR002, QLRR003, QLRR004, QLRR005, QLRR006, QLRR007 | 🟢 **Risk Indicator** |
| `risk_indicator_custom` | Chỉ tiêu tự tạo | QLRR003, QLRR004, QLRR005 | 🟢 **Risk Indicator** *(gộp)* |
| `risk_indicator_value` | Số liệu theo kỳ | QLRR001, QLRR002, QLRR003, QLRR004, QLRR005, QLRR007 | 🟢 **Risk Indicator Value** |
| `risk_indicator_value_history` | Lịch sử thay đổi số liệu | QLRR001, QLRR003, QLRR004, QLRR007 | 🟢 **Risk Indicator Value Change** |

### B. Classification Values (17 schemes — tra từ `ref_shared_entity_classifications.csv`)

Các giá trị danh mục trong QLRR được chuẩn hóa thành Classification Value thay vì bảng dictionary riêng.

| Scheme Code | Mô tả | Nguồn cột | Dùng bởi entity Silver |
|---|---|---|---|
| `RISK_INDICATOR_SET` | Bộ chỉ tiêu (1=Trong nước, 2=Quốc tế) | `risk_indicator.set_code` | Risk Indicator, Risk Indicator Category |
| `RISK_INDICATOR_TYPE` | Loại chỉ tiêu (1=hệ thống, 2=tự tạo — derived) | `risk_indicator` / `risk_indicator_custom` | Risk Indicator |
| `RISK_UNIT` | Đơn vị đo lường (1=%…10=Đơn vị tính) | `risk_indicator.unit_code` | Risk Indicator, Risk Indicator Value, Risk Alert Config, Risk Alert |
| `RISK_DATA_SOURCE` | Nguồn dữ liệu (1=Investing…6=VSDC) | `risk_indicator.source_code` | Risk Indicator, Risk Indicator Value, Risk Indicator Value Change |
| `RISK_PERIOD_TYPE` | Tần suất kỳ (1=Ngày…4=Năm) | `risk_indicator.period_type` | Risk Indicator, Risk Indicator Value, Risk Indicator Schedule |
| `RISK_DATA_ORIGIN` | Nguồn gốc giá trị (1=API, 2=User) | `risk_indicator_value.data_origin` | Risk Indicator Value, Risk Indicator Value Change |
| `RISK_JOB_FREQUENCY_TYPE` | Tần suất job (1=Giờ…5=Năm) | `risk_indicator_schedule.frequency_type` | Risk Indicator Schedule |
| `RISK_JOB_RUN_STATUS` | Kết quả chạy job (SUCCESS/FAILED) | `risk_indicator_schedule.last_status` | Risk Indicator Schedule |
| `RISK_ALERT_THRESHOLD_DIRECTION` | Chiều ngưỡng (1=Tăng, 2=Giảm, 3=Tăng/Giảm) | `risk_alert_config.threshold_direction` | Risk Alert Config, Risk Alert |
| `RISK_INDICATOR_CHANGE_TYPE` | Loại thay đổi giá trị (SYNC/UPDATE) | `risk_indicator_value_history.change_type` | Risk Indicator Value Change |
| `RISK_ALERT_STATUS` | Trạng thái cảnh báo (0=Chưa xử lý…3=Đã huỷ) | `risk_alert.status` | Risk Alert |
| `RISK_FILE_TYPE` | Loại file (DOCX/XLSX/PDF…) — cần profile | `risk_report_file.file_type`, `risk_alert_resolution_file.file_type` | Risk Report File, Risk Alert Resolution File |
| `RISK_ALERT_RESOLUTION_TYPE` | Loại xử lý cảnh báo (1=Quick, 2=Detailed) | `risk_alert_resolution.resolution_type` | Risk Alert Resolution |
| `RISK_ALERT_EVENT_TYPE` | Loại sự kiện cảnh báo (1=Xảy ra…3=Xử lý có giải trình) | `risk_alert_history.event_type` | Risk Alert History |
| `RISK_NOTIFICATION_TYPE` | Kênh thông báo (1=Toast, 2=Bell, 3=Email) | `risk_notification.notification_type` | Risk Alert Notification |
| `RISK_NOTIFICATION_SEND_STATUS` | Trạng thái gửi (1=SENT, 2=FAILED) | `risk_notification.send_status` | Risk Alert Notification |
| `RISK_NOTIFICATION_READ_STATUS` | Trạng thái đọc (0=Chưa đọc, 1=Đã đọc) | `risk_notification.read_status` | Risk Alert Notification |

### C. Bảng ngoài scope Silver

| Bảng | Lý do ngoài scope |
|---|---|
| `risk_report_placeholder_config` | Config kỹ thuật — operational/system data |
| `permission_group` | Operational/system data — phân quyền tầng ứng dụng |
| `permission_group_user` | Operational/system data — phân quyền tầng ứng dụng |
| `permission_group_indicator` | Operational/system data — phân quyền tầng ứng dụng |

---

## Tổng kết ánh xạ

- **Tổng số bảng nguồn:** 19
- **Bảng trong scope Silver:** 15 (risk_indicator + risk_indicator_custom gộp thành 1 entity)
- **Số Silver entity:** 14
- **Bảng out of scope:** 4 (1 config kỹ thuật + 3 phân quyền)
- **Số Classification Value schemes:** 17
- **Số junction table:** 0 *(QLRR không có pure junction)*
