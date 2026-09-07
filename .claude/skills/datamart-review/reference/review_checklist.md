# Review Checklist — Macro-Review & Micro-Review (4 Lớp)

Tài liệu checklist chuẩn hóa cho 2 chế độ review của skill `datamart-review`:
- **Chế độ 1: Macro-Review (Tiến độ & Trạng thái toàn phân hệ)** — Quét nhanh đối soát chéo BA ↔ HLD ↔ Detail Mapping, xác định blocker tiến độ và phân loại nguyên nhân PENDING.
- **Chế độ 2: Micro-Review (Chi tiết kỹ thuật từng nhóm)** — Đi sâu 4 lớp (HLD → Attributes → Detail Mapping → Registry) cho từng nhóm cụ thể.

---

## PHẦN 1: CHECKLIST MACRO-REVIEW (TIẾN ĐỘ & TRẠNG THÁI TOÀN PHÂN HỆ)

Thực hiện ở **Bước 0b** (trước khi đi vào chi tiết bất kỳ nhóm nào), có thể chạy tự động bằng script `scripts/datamart_progress_analyzer.py`:

```
□ Khảo sát file nguồn và kiểm tra khả năng đọc:
  □ Tìm đúng file BA tương ứng (hỗ trợ cả BA_analyst_GSĐC.csv và các module khác)
  □ Tự động dò đúng delimiter (',' với QLCB, GSĐC, GSTT, QLKD, TKNB, PTTT; ';' với các file còn lại)
  □ Xử lý chuẩn xác encoding utf-8-sig / BOM và các ô có newline
  □ Nhận diện đúng dòng header (dòng 1 đối với toàn bộ 11 file hiện hành)
  □ Resolve tên cột động (STT/TT, Dashboard, Thông tin, Phân loại, Trạng thái mapping, Bảng nguồn, Loại dữ liệu)

□ Thiết lập Ma trận Đối soát Tiến độ (Cross-status Matrix):
  □ Lập bảng đối chiếu giữa BA Status (Done, Doing, Pending, Chưa có trong BA) ↔ Datamart Status (READY, PENDING, Chưa có)
  □ Xác định tổng số chỉ tiêu khai thác (Dashboard/Report)
  □ Tính tỷ lệ % READY và % PENDING tổng thể

□ Phân loại 100% Chỉ tiêu PENDING theo Cây 6 Nhánh Nguyên nhân:
  □ Nhánh 1: BA Pending (BA chưa phân tích xong / chưa xác nhận nguồn)
  □ Nhánh 2: Chưa có mapping nguồn từ BA (Nguồn trống / N/A / Chưa có CSDL / Map biểu mẫu)
  □ Nhánh 3: Thiếu nguồn dữ liệu ngoại lai (VSDC, VSD, SCMS, SBV, v.v.)
  □ Nhánh 4: Join đa nguồn phức tạp (NHNCK & SCMS, đa hệ thống chưa chuẩn hóa ở Atomic)
  □ Nhánh 5: Datamart Pending (Có nguồn nội bộ đầy đủ, Datamart chưa thiết kế Fact/Dim/Detail Mapping)
  □ Nhánh 6: Lệch số lượng / Schema out of sync (Lệch dòng KPI / Atomic entity lỗi thời)

□ Đối soát Số lượng Chỉ tiêu theo Nhóm (BA ↔ HLD ↔ Detail Mapping):
  □ Đếm số dòng BA hợp lệ trong nhóm (Phân loại ∈ {Chiều, Chỉ tiêu cơ sở, Chỉ tiêu phái sinh}, Trạng thái ∈ {Done, Doing})
  □ Đếm số dòng KPI HLD của nhóm (loại trừ dòng derived thuần/YoY trong cùng bảng)
  □ Đếm số dòng Detail Mapping của nhóm
  □ Tính độ lệch (Delta): BA ↔ HLD và HLD ↔ Detail Mapping
  □ Bật cờ cảnh báo "🔴 Lệch số lượng" cho mọi nhóm có chênh lệch dù chỉ 1 dòng

□ Kiểm tra Cấu trúc Toàn Module trong HLD (DTM_{MODULE}_HLD.md):
  □ Đủ 5 Section chuẩn:
      Section 1 — Data Lineage
      Section 2 — Tổng quan báo cáo
      Section 3 — Mô hình tổng thể
      Section 4 — Reuse Analysis (4 cột: Datamart Entity / datamart_table / reuse_status / Ghi chú)
      Section 5 — Vấn đề mở
  □ Thiếu Section 4 Reuse Analysis hoặc đặt nhầm chỗ → 🔴 Critical cấp toàn module
  □ Bảng KPI từng nhóm đúng chuẩn 7 cột hiện hành:
      KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái
    (KHÔNG còn format cũ tách riêng 2 block READY 6 cột / PENDING 4 cột)
  □ Heading Cụm đúng cấp (##### Cụm N)
  □ Đối chiếu danh sách entity và reuse_status giữa DTM_{MODULE}_Entities.csv ↔ Section 3 & 4 của HLD.md

□ Xuất Báo cáo Tiến độ & Danh sách Blocker:
  □ Bảng tổng hợp Markdown trực quan
  □ Danh sách chỉ tiêu cần BA Team giải quyết (Nhánh 1, 2, 3)
  □ Danh sách chỉ tiêu cần Datamart Team giải quyết (Nhánh 4, 5, 6)
  □ GATE 0b: Claude DỪNG chờ human xác nhận kế hoạch và thứ tự review trước khi vào Micro-Review
```

---

## PHẦN 2: CHECKLIST MICRO-REVIEW (CHI TIẾT KỸ THUẬT 4 LỚP TỪNG NHÓM)

### Lớp 1: HLD (High-Level Design)

```
□ Nhóm có tồn tại trong HLD không?
  → Nếu không: Gap Critical — cần thiết kế HLD (Kịch bản A → gọi datamart-hld-design)

□ Trạng thái nhóm trong HLD vs BA:
  → HLD = PENDING + BA = Done → Kịch bản A (gọi datamart-hld-design)
  → HLD = PENDING + BA = Pending → OK (đúng tình trạng)
  → HLD = READY + BA = Done → tiếp tục review Lớp 2, 3, 4
  → HLD = READY + BA có KPI mới chưa có trong HLD → Gap (cần cập nhật HLD)

□ KPI coverage BA → HLD: mọi KPI Done/Doing trong BA có KPI_ID trong bảng KPI HLD?
  → Sót KPI → Warning hoặc Critical tuỳ mức độ

□ KPI Pending: tất cả KPI Pending trong BA có dòng trong bảng KPI với cột Trạng thái = PENDING?
  → Thiếu → Warning
  → LƯU Ý: Chuẩn hiện hành gộp READY và PENDING vào CÙNG 1 bảng KPI 7 cột

□ Chiều (Slicer/Filter): mọi dòng BA Phân loại = "Chiều" có KPI_ID?
  → Thiếu → Warning
  → Giá trị thật của cột Phân loại: "Chiều" / "Chỉ tiêu cơ sở" / "Chỉ tiêu phái sinh"
    (KHÔNG phải "Cơ sở"/"Phái sinh" — so bằng .strip().lower() + in/startswith)

□ KPI coverage HLD → BA (chiều ngược — bắt buộc): mọi KPI_ID trong HLD phải truy về được ít nhất 1 dòng trong BA analyst.
  → KPI_ID trong HLD không tìm thấy trong BA → KPI dư, cần xác nhận với BA
  → Không được giả định KPI hợp lệ chỉ vì nó đã có trong HLD

□ Đối chiếu SỐ LƯỢNG dòng tuyệt đối (0b.3):
  → Số dòng BA khớp chính xác số dòng KPI HLD?
  → Lệch → Bắt buộc dừng đối chiếu từng dòng trước khi kết luận Lớp 1 pass

□ Cột Công thức/Mô tả — đầy đủ cho mọi dòng, kể cả dòng reuse:
  → Dòng KPI reuse phải ghi rõ "Reuse từ Nhóm X" ngay trong cột Công thức/Ghi chú

□ Grain: mô tả grain rõ ràng, khớp với logic BA?

□ Bảng Fact/Dim đủ để phản ánh tất cả dimension trong BA?

□ Đọc sâu SQL tham khảo BA khi KPI ở trạng thái PENDING:
  → Trích xuất logic temporal ẩn (TTM 4 quý, rolling N phiên, snapshot rn=1, gate count=4)
  → Kiểm tra HLD có đặc tả đủ logic này chưa

□ Tính nhất quán giữa KPI phái sinh và KPI cơ sở:
  → Kiểm tra KPI cơ sở có đặc tả đủ rõ để phục vụ tất cả KPI phái sinh phụ thuộc không
```

---

### Lớp 2: Attributes (Atomic → Datamart)

```
□ Bảng Fact/Dim của nhóm có trong Attributes không?
  → Không có → Critical (LLD chưa thiết kế → gọi datamart-lld-design)

□ Mọi KPI Done trong BA có cột tương ứng trong Attributes?
  → Thiếu cột → Critical

□ source_entity + atomic_table + atomic_column điền đầy đủ?
  → Trống với etl_logic_type ≠ pending → Warning

□ VERIFY ATOMIC YAML THẬT TRƯỚC KHI CHẤP NHẬN READY (BẮT BUỘC):
  → Tra cứu approved YAML theo đúng thứ tự 2 nguồn chuẩn:
      Nguồn 1 (luôn tra trước): DataModel/Atomic/**/*.yaml
      Nguồn 2 (chỉ khi N1 trống): DataModel/working/Atomic/lld/**/*.yaml
      ❌ CẤM TRA: DataModel/working/Atomic_LinhLV/ (track cũ đã revert)
  → Đếm số attribute thật và kiểm tra physical_name thật trong YAML approved
  → Không tin theo Attributes ghi gì mà phải verify đối chiếu ngược lại YAML
  → Nếu không tìm thấy YAML ở cả 2 nguồn → Gap Atomic (ghi nhận riêng)

□ etl_logic nội dung đúng với BA:
  → JOIN đúng bảng?
  → Filter condition khớp BA (VD: row_code = 'X', entp_tp_code = 'dn')?
  → Aggregation đúng phép tính?

□ Flatten hoàn toàn xuống Atomic — KHÔNG tham chiếu cột mart trong etl_logic:
  → etl_logic chứa fct_*.col hoặc dim_*.col → Sai (phải inline xuống Atomic)
  → Có ≥2 atomic_table khác driving table mà không có dòng etl_logic_type = join_atomic → 🔴 Critical

□ lookup_dim / join_atomic:
  → Vế trái phải là datamart_column THẬT của Dimension đích, không copy tên cột Atomic
  → src_stm_code trong JOIN sang shared entity phải dùng mã module nguồn thật (VD: ECAT_COUNTRY)

□ Data domain / data_type khớp tính chất KPI:
  → Số tiền → Currency Amount / decimal (KHÔNG dùng float)
  → Tỷ lệ → Percentage / decimal
  → Đếm → Small Counter / int
  → Text → Text / string

□ Key constraints:
  → FK nullable = false, PK/BK nullable = false, LEFT JOIN nullable = true

□ Physical Naming (system/rules/rule_physical_name_exceptions_datamart.csv):
  → Chỉ những từ trong file exceptions mới được viết tắt, các từ khác phải full-word
  → Derive đúng từ logical name, không đổi từ / mở rộng từ
```

---

### Lớp 3: Detail Mapping (Datamart → Báo cáo)

```
□ Mọi KPI_ID trong HLD (Done/Doing) có dòng trong Detail Mapping?
  → Thiếu → Critical

□ KPI Pending: có dòng trong Detail Mapping với mart_table/mart_column/logic trống?
  → Thiếu → Warning

□ Trace BA → Detail Mapping (bắt buộc mọi KPI Done):
  → Aggregation: BA ghi SUM → logic phải SUM (không được COUNT)
  → Filter: Phải đọc cả cột Điều kiện, Câu lệnh tham khảo VÀ Note trong BA
  → Phân tầng filter: Filter xác định Grain nằm ở Attributes etl_logic; Filter phân biệt KPI nằm ở Detail Mapping logic
  → Thiếu/sai filter → Critical/Warning tuỳ mức độ

□ Logic DERIVED — không tham chiếu KPI_ID khác:
  → Logic của DERIVED KHÔNG ĐƯỢC viết dạng (K_XXX_N - K_XXX_M) / NULLIF(...)
  → Phải inline toàn bộ xuống physical_table.physical_column với đầy đủ điều kiện lọc

□ Trace ngược Detail Mapping → Attributes:
  → mart_table.mart_column trong logic có tồn tại thật trong Attributes không?

□ column_role đúng tính chất:
  → MEASURE: phép tính thuần
  → SLICER: dimension hiển thị group by
  → FILTER: dimension dùng lọc không hiển thị
  → DERIVED: công thức tính từ measure khác, mart_table/mart_column trống

□ mart_table / mart_column dùng tên LOGICAL; cột `logic` bắt buộc dùng tên PHYSICAL:
  → Ngược lại → Warning

□ Chiều lặp lại giữa các nhóm: mỗi nhóm có explicit SLICER/FILTER riêng (không dùng "xem nhóm X")
```

---

### Lớp 4: datamart_model.yaml (Registry Cross-Module)

```
□ Entity của bảng đang review có tồn tại trong datamart_model.yaml?
  → Không có → Critical (registry thiếu entity)

□ Mọi cột trong Attributes detail có mặt 1-1 trong registry (columns của entity)?
  → Thiếu hoặc thừa cột trong registry → Critical

□ data_domain + data_type của từng cột khớp Attributes?
  → Type mismatch → Critical

□ Cột data_domain = Boolean — phân biệt hợp lệ vs cần đổi Indicator (Y/N):
  → "direct" từ Atomic column đã là Boolean thật → Boolean hợp lệ, GIỮ NGUYÊN
  → "computed" bằng biểu thức so sánh/CASE tại Datamart (IN, IS NOT NULL) → PHẢI đổi Indicator (Y/N)

□ source_atomic_table / source_atomic_column khớp Attributes VÀ khớp Atomic YAML thật?

□ Cột PENDING (gap Atomic) trong Attributes có phản ánh đúng trong registry (trỏ null)?

□ Physical name nhất quán với Attributes?

□ Verify registry YAML parse hợp lệ sau khi cập nhật:
  → python -c "import yaml; yaml.safe_load(open('Datamart/datamart_model.yaml', encoding='utf-8'))"
```

---

## PHẦN 3: NGUYÊN TẮC AN TOÀN & GATE CONTROL

1. **Gate Rule Bước 0b:** Sau khi chạy Macro-Review, Claude bắt buộc DỪNG và trình bày bảng kế hoạch + ma trận đối soát cho human, chờ human xác nhận thứ tự review. Human chưa duyệt = chưa được review chi tiết.
2. **Gate Rule Sau Mỗi Nhóm (Micro-Review):**
   - Nếu nhóm có vấn đề (Critical/Warning/Info): Claude DỪNG, hỏi human muốn (a) sửa ngay, (b) ghi nhận sang nhóm tiếp, hay (c) dừng.
   - Nếu nhóm không có vấn đề (4 lớp OK): Tự động chuyển sang nhóm kế tiếp.
3. **Nguyên Tắc Không Tự Ý Sửa File Trực Tiếp:**
   - Mọi thay đổi nội dung nghiệp vụ HLD (Fact/Dim, grain, nguồn, bảng KPI) → gọi `datamart-hld-design`.
   - Mọi thay đổi nội dung LLD (Attributes, Detail Mapping, Registry) → gọi `datamart-lld-design`.
   - Kịch bản C (lỗi kỹ thuật): Trình bày action đề xuất → Claude chờ human xác nhận → gọi skill con tương ứng để thực hiện. Claude tuyệt đối không tự Edit trực tiếp vào file HLD/LLD.
