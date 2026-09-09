# QUY CHUẨN ĐỐI SOÁT KPI VÀ PHÂN TÍCH LỆCH SỐ LƯỢNG
## Dự Án: Data Warehouse UBCKNN — Đối Soát BA Analyst ↔ HLD ↔ Detail Mapping

---

## 1. Nguyên Tắc Đối Soát 3 Chiều

Mỗi yêu cầu phân tích dữ liệu trong dự án phải được liên kết chặt chẽ qua 3 tầng tài liệu:
$$\text{BA Analyst CSV} \iff \text{HLD Section 3 (Bảng 7 Cột)} \iff \text{LLD Detail Mapping CSV}$$

- **Chiều Xuôi (Forward Trace):** Đảm bảo 100% yêu cầu nghiệp vụ của BA được tiếp nhận và thiết kế trong Datamart (không bỏ sót nghiệp vụ).
- **Chiều Ngược (Backward Trace):** Đảm bảo mọi KPI_ID, trường dữ liệu trong Datamart đều có căn cứ xuất xứ từ yêu cầu BA hoặc mục tiêu kiến trúc rõ ràng (không sinh trường mồ côi).

---

## 2. Quy Trình Đối Soát KPI 4 Bước

### Bước 1: Trích Xuất Chỉ Tiêu BA Hợp Lệ Theo Nhóm
- Sử dụng parser động (`detect_delimiter_and_header`):
  - Bỏ qua dòng 0 (tiêu đề merge Excel). Đọc header từ **Dòng 1** (0-indexed: index 1).
  - Bỏ qua các dòng phân nhóm rỗng, dòng chỉ chứa số mục BRD (`3.2.2.x`) hoặc dòng phân nhóm thuần túy không có chỉ tiêu.
  - Loại bỏ các chỉ tiêu có trạng thái `Delete`, `DELETED`, `Xóa`, `Bỏ` khỏi phạm vi thiết kế active (lưu vào danh sách theo dõi vi phạm).
  - Lọc các dòng có cột `Phân loại` thuộc `{Chiều, Chỉ tiêu cơ sở, Chỉ tiêu phái sinh}`.

### Bước 2: Trích Xuất Bảng KPI 7 Cột Trong HLD (Section 3)
- Bảng KPI chuẩn 7 cột trong `DTM_{MODULE}_HLD.md` có cấu trúc:
  `| STT / Mã KPI | Tên chỉ tiêu | Đơn vị tính | Tính chất | Công thức / Thuật toán | Ghi chú / Căn cứ | Trạng thái |`
- Đếm số dòng `KPI_ID` hợp lệ trong nhóm (định dạng `K_{MODULE}_{NUM}` hoặc mã tương đương).
- Tách riêng các dòng `Trạng thái = READY` và `Trạng thái = PENDING`.

### Bước 3: Trích Xuất Detail Mapping Theo Nhóm
- Đọc file `DTM_{MODULE}_Detail_Mapping.csv` theo cột `nhom` hoặc lọc theo danh sách `kpi_id` của nhóm.
- Đếm số lượng dòng mapping đã được định nghĩa logic tính toán (`logic`, `mart_table`, `mart_column`).

### Bước 4: Đối Chiếu 2 Chế Độ Song Song
Áp dụng công thức đối soát chuẩn hóa dưới đây để xác định tính nhất quán.

---

## 3. Công Thức Đối Soát 2 Chế Độ Song Song

> 🔴 **GIẢI PHÁP TRIỆT TIÊU FALSE ALARM (MÂU THUẪN 6):**  
> Trước đây hệ thống chỉ đếm dòng BA `Done/Doing` nhưng lại đếm toàn bộ dòng HLD (cả `READY` lẫn `PENDING`), dẫn tới việc luôn báo lệch số lượng giả. Nay chuẩn hóa thành 2 chế độ đối soát độc lập:

### Chế Độ 1: Đối Soát Tổng Thể (Total Scope - Toàn Bộ Phạm Vi)
Bao gồm cả các chỉ tiêu đang hoàn thiện và các chỉ tiêu đang chờ nguồn:

$$\text{Total\_BA} = \text{COUNT}\left(\text{Dòng BA có Phân loại hợp lệ và Trạng thái} \notin \{\text{Delete, DELETED, Xóa}\}\right)$$

$$\text{Total\_HLD} = \text{COUNT}\left(\text{Mọi KPI\_ID trong bảng 7 cột, loại trừ chỉ tiêu phái sinh thuần } \_YOY\right)$$

- **Quy tắc nghiệm thu:** $\text{Total\_BA} == \text{Total\_HLD}$ (Khớp 1-1 về tổng số lượng yêu cầu).

### Chế Độ 2: Đối Soát Khả Dụng (Ready Scope - Đã Sẵn Sàng Triển Khai)
Chỉ tính các chỉ tiêu đã phân tích xong và sẵn sàng bàn giao:

$$\text{Ready\_BA} = \text{COUNT}\left(\text{Dòng BA có Trạng thái mapping} \in \{\text{Done, Doing, Hoàn thành}\}\right)$$

$$\text{Ready\_HLD} = \text{COUNT}\left(\text{Dòng KPI trong HLD có Trạng thái} = \text{READY}\right)$$

$$\text{Ready\_DM} = \text{COUNT}\left(\text{Dòng trong Detail Mapping có kpi\_id khớp HLD READY và có logic}\right)$$

- **Quy tắc nghiệm thu:** $\text{Ready\_BA} == \text{Ready\_HLD} == \text{Ready\_DM}$.

---

## 4. Ma Trận Đối Soát Tiến Độ Chéo (Cross-Status Matrix)

| Trạng thái BA | Trạng thái HLD | Trạng thái LLD | Phân Loại & Đánh Giá | Hành Động Xử Lý |
|---|---|---|---|---|
| **DONE** | **READY** | **Đầy đủ** | 🟢 **Hoàn tất (Ready to Implement)** | Tiến hành kiểm định chi tiết 4 lớp kỹ thuật. |
| **DONE** | **PENDING** | **Chưa có** | 🟡 **Datamart Pending (Nhánh 5)** | Backlog thiết kế của đội Datamart Modeling. |
| **PENDING** | **PENDING** | **Chưa có** | 🟡 **BA Pending (Nhánh 1-4)** | Phân loại theo 6 nhánh, chờ BA hoàn thiện nguồn. |
| **PENDING** | **READY** | **Đã có** | ⚠️ **Cảnh báo Lệch Trạng Thái** | Kiểm tra lại với BA xem nguồn đã chốt chưa. |
| **DELETE** | **READY** | **Bất kỳ** | 🔴 **CRITICAL VIOLATION (`[L1/L2-DELETE-VIOLATION]`)** | **Vi phạm cấm kỵ:** Bắt buộc gỡ bỏ ngay khỏi HLD và LLD. |
| **DELETE** | **PENDING** | **Bất kỳ** | 🔴 **CRITICAL VIOLATION** | Bắt buộc xóa bỏ khỏi backlog thiết kế. |

---

## 5. Cơ Chế Phân Tích Chênh Lệch Số Lượng Hợp Lệ (`Reconciled Delta`)

Khi $\text{Total\_BA} \ne \text{Total\_HLD}$, Reviewer không vội vàng kết luận là lỗi nghiêm trọng mà kiểm tra 4 trường hợp ngoại lệ hợp lệ sau:

### Trường Hợp 1: Chỉ Tiêu Phái Sinh Nội Tại HLD (`_YOY`, `_MOM`, `_GROWTH`)
- **Đặc điểm:** HLD tự bổ sung thêm các chỉ tiêu phân tích so sánh chuỗi thời gian (ví dụ: `K_GSTT_01_YOY`) để phục vụ biểu đồ trực quan, trong khi BA chỉ yêu cầu 1 chỉ tiêu cơ sở.
- **Quy tắc xử lý:** Loại trừ các mã `_YOY` khỏi công thức đối soát cơ sở, coi đây là phái sinh hợp lệ nếu có ghi chú rõ ràng trong cột Công thức.

### Trường Hợp 2: Nhân Bản Theo Loại Hình Doanh Nghiệp (Phân hệ GSĐC)
- **Đặc điểm:** Phân hệ GSĐC chia 3 loại hình doanh nghiệp: Công ty niêm yết (CTNY), Công ty đại chúng quy mô lớn (CTTG), và Công ty đại chúng thông thường (CTDC). Một dòng chỉ tiêu BA có thể tương ứng với 3 chỉ tiêu đo lường trên Datamart.
- **Quy tắc xử lý:** Chấp nhận tỷ lệ $\text{Total\_HLD} = 3 \times \text{Total\_BA}$ nếu bảng HLD có ghi chú phân rã theo 3 loại hình.

### Trường Hợp 3: Tách Measure Vật Lý
- **Đặc điểm:** Một chỉ tiêu BA phức hợp (như "Tổng dư nợ cho vay") được Datamart tách thành 2 measure vật lý: `margin_loan_principal_amt` (dư nợ gốc) và `margin_loan_interest_amt` (dư nợ lãi).
- **Quy tắc xử lý:** Ghi nhận là Reconciled Delta hợp lệ nếu có giải trình schema (`has_schema_note = True`).

### Trường Hợp 4: Gom Sub-components
- **Đặc điểm:** BA liệt kê các tiểu mục chi tiết (dòng a, dòng b, dòng c), Datamart gom chung vào 1 trường phân loại và 1 measure tổng.
- **Quy tắc xử lý:** Ghi nhận Reconciled Delta nếu tổng thể nghiệp vụ được bảo toàn.

> 🟢 **ĐIỀU KIỆN VƯỢT QUA GATE:** Nếu độ lệch số lượng thuộc một trong 4 trường hợp trên và đã có giải trình trong HLD hoặc file Whitelist (`datamart_review_whitelist.yaml`), Reviewer được phép ghi chú `🟢 Khớp (Reconciled Delta)` và tiếp tục quy trình review mà không bị chặn Gate 0b.

---

## 6. Quy Trình Kiểm Tra Bắt Buộc Chỉ Tiêu Bị Xóa (`Delete`)

1. **Trích xuất Blacklist:**
   Hàm `BAParser.get_deleted_items()` quét toàn bộ file BA và thu thập danh sách các chỉ tiêu có trạng thái: `Delete`, `DELETED`, `Xóa`, `Bỏ`, `Không dùng`.
2. **Quét Đối Soát HLD:**
   Tìm kiếm mã KPI và tên chỉ tiêu bị xóa trong Section 3 HLD. Nếu còn xuất hiện → Báo lỗi `🔴 Critical: Chỉ tiêu bị xóa vẫn còn trong HLD`.
3. **Quét Đối Soát LLD:**
   Tìm kiếm trong file `DTM_{MODULE}_Detail_Mapping.csv` và `datamart_attributes.csv`. Nếu còn ánh xạ → Báo lỗi `🔴 Critical: Chỉ tiêu bị xóa vẫn còn trong LLD Detail Mapping`.
4. **Hành Động Khắc Phục:**
   Áp dụng Retirement Protocol: Đánh dấu bãi bỏ, xóa khỏi mapping active và chuyển trạng thái kỹ thuật `ds_rcrd_st = 'INACTIVE'`.
