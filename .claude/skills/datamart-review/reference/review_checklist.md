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
  □ Đối soát 2 Chế độ Song song (theo reference/kpi_reconciliation_rules.md):
      - Chế độ 1 (Total Scope): Total_BA (loại trừ Delete) == Total_HLD (loại trừ _YOY)
      - Chế độ 2 (Ready Scope): Ready_BA (Done/Doing) == Ready_HLD (READY) == Ready_DM
  □ Kiểm tra Cơ chế Whitelist Ngoại lệ (Reconciled Delta theo reference/datamart_review_whitelist.yaml):
      - Nhóm có trong Whitelist (GSĐC 21-30 nhân bản 3x, GSTT 1-4 YoY/MoM, NHNCK 1, 2, 7 split measure, QLKD 1, 19 banner, TKNB 1, 2, 3) được công nhận "🟢 Khớp (Theo Whitelist)"
      - Chỉ bật cờ cảnh báo "🔴 Lệch số lượng" khi nhóm có độ lệch chưa có trong Whitelist hoặc chưa có giải trình Reconciled Delta hợp lệ

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

□ Kiểm tra nhanh Role-Playing Date Dimension toàn module (CLI script):
  □ Chạy: python scripts/check_date_fk.py --module {MODULE}
  □ Xác nhận 100% Fact table không có cột generic cdr_dt_dim_id / calendar_dt_dim_id
  □ Xác nhận 100% Fact Snapshot có đủ cột snpst_dt_dim_id

□ Kiểm tra Orphan Check 3 Chiều toàn module (CLI script):
  □ Chạy: python scripts/check_orphan.py --module {MODULE}
  □ Đối soát ma trận 3 chiều: LLD Attributes CSV ↔ HLD Entities ↔ Flat Table SQL DDL
  □ Phân định rõ 2 nhánh xử lý:
      - Nhánh A (Incomplete): Bảng còn giá trị / có ≥1 KPI READY → Yêu cầu hoàn tất Phase 2 Entities & Phase 3 Flat Table, TUYỆT ĐỐI KHÔNG XÓA
      - Nhánh B (Abandoned): Bảng bị hủy / 0 KPI READY → Kích hoạt All-Tier Cleanup Protocol 5 bước dọn dẹp sạch cả 3 tầng
  □ Xác nhận 0 bảng mồ côi chưa được phân loại và giải quyết

□ Kiểm tra etl_logic Content Parity & Master Registry Sync (CLI script):
  □ Chạy: python scripts/check_parity.py --module {MODULE}
  □ Xác nhận 100% thuộc tính của module CSV có mặt đầy đủ trong master registry `Datamart/lld/datamart_attributes.csv`
  □ Xác nhận nội dung etl_logic khớp byte-for-byte (sau strip whitespace) giữa module CSV và master registry
  □ Xác nhận 0 mismatch logic, 0 missing attribute

□ Xuất Báo cáo Tiến độ & Danh sách Blocker:
  □ Bảng tổng hợp Markdown trực quan
  □ Danh sách chỉ tiêu cần BA Team giải quyết (Nhánh 1, 2, 3)
  □ Danh sách chỉ tiêu cần Datamart Team giải quyết (Nhánh 4, 5, 6)
  □ GATE 1 (Sau Bước 0b/0c — Stop & Report):
      - Claude BẮT BUỘC DỪNG xuất Báo cáo Tiến độ Toàn Module + Danh sách Blocker
      - CHẶN CỨNG TUYỆT ĐỐI không cho phép chuyển sang Micro-Review nếu phát hiện:
        • Vi phạm Orphan 3 chiều (Nhánh A chưa hoàn tất hoặc Nhánh B chưa dọn sạch)
        • Lệch etl_logic Content Parity hoặc thiếu thuộc tính trong master registry
        • Vi phạm cdr_dt_dim_id trên Fact table
        • Chỉ tiêu BA = Delete còn sót lại trong Datamart
        • Lệch cấp độ hạt kiến trúc nghiêm trọng (L1-GRAIN-MISMATCH) hoặc lưu trữ chuỗi thời gian sai lầm trên Dimension SCD4A (L2-WINDOW-STORAGE-INVALID)
      - Chờ Human phê duyệt kế hoạch trước khi vào Micro-Review
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
  → BA có Trạng thái mapping = Delete / DELETED / Xóa → Xác nhận KHÔNG có mặt trong HLD (nếu vẫn tồn tại trong HLD → 🔴 Critical, yêu cầu xóa bỏ khỏi HLD)
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

□ Reuse aggregate measure (GROUP BY/PARTITION BY/SUM/MAX theo 1 chiều) — KHÔNG được tin "Reuse từ Nhóm X" là đủ:
  → Với mọi KPI aggregate (VD: Vốn hóa, Tổng KL/GT theo 1 nhóm...) ghi "Reuse từ Nhóm X": mở mockup của CẢ Nhóm gốc và Nhóm đang review, xác định "1 dòng kết quả = 1 [đơn vị] gì?" ở Nhóm đang review (nhìn cột lân cận: đứng cạnh "Số CP lưu hành"/"Mã CK" → grain là mã CK; có ghi rõ "(theo Chỉ số)" → grain là chỉ số)
  → Đối chiếu GROUP BY/PARTITION BY thực tế trong `logic` — phải khớp đúng đơn vị đó, không phải đơn vị của Nhóm gốc
  → Lệch (VD: Nhóm gốc theo Index, Nhóm reuse cần theo Symbol nhưng logic vẫn GROUP BY Index Code) → 🔴 Critical (mã: L1-GRAIN-MISMATCH, xem `datamart-lld-design/reference/phase2_detail_mapping.md` mục L14) — case thật: K_GSTT_61 "Vốn hóa" copy nguyên từ Nhóm 6 (đúng theo Chỉ số) sang 8 Nhóm Top-N theo mã CK (2026-09-14)
  → Đây là lỗi KHÔNG bị bắt bởi Attributes/Atomic parity hay orphan check — chỉ lộ ra khi đối chiếu ngữ cảnh hiển thị, nên phải chủ động kiểm tra riêng, không dựa vào các script PASS để kết luận "đã đúng"

□ Kiểm tra Khớp Cấp độ Hạt Kiến Trúc (Architectural Grain Alignment):
  → Xác định rõ 2 cấp độ Grain của nhóm:
      (1) Grain bảng Fact nguồn (VD: 1 row / symbol / trade_date)
      (2) Grain hiển thị trên báo cáo/mockup (VD: 1 row / symbol / trade_date, hoặc 1 row / index / trade_date)
  → Kiểm tra tính tương thích giữa Grain hiển thị và Grain nguồn:
      - Nhóm hiển thị cấp Cổ phiếu (Symbol) → Fact bắt buộc phải có Grain cấp Cổ phiếu hoặc chi tiết hơn. CẤM dùng Fact có Grain cấp Rổ chỉ số (Index) hay cấp Sàn (Floor) để map trực tiếp mà không có Bridge/Unnest hợp lệ.
      - Nhóm hiển thị cấp Rổ chỉ số (Index) → Fact cấp Cổ phiếu phải có phép tổng hợp (SUM/AVG) nhóm theo `index_code`.
  → Vi phạm lệch hạt kiến trúc → 🔴 Critical (mã: L1-GRAIN-MISMATCH)

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

□ Đầy đủ trường kỹ thuật mặc định SCD4A trên Dimension / Operational:
  → Bảng Dimension và Operational phải có đủ 5 trường kỹ thuật SCD4A: `ds_rcrd_st`, `ds_eff_start_dt`, `ds_eff_end_dt`, `ds_cdc_opr_cd`, `ds_load_ts` (History có thêm `ds_snpst_dt`)
  → Thiếu trường kỹ thuật → Warning / Critical (mã: L2-SCD4A-TECH-FIELD)

□ Lọc trạng thái bản ghi `ds_rcrd_st = 'ACTIVE'` khi JOIN Atomic SCD4A:
  → Mọi JOIN clause tham chiếu tới Atomic table Fundamental (SCD4A) phải có `AND <atomic_table>.ds_rcrd_st = 'ACTIVE'`
  → Bảng History Atomic (`_hstr`) phải có `ds_snpst_dt = :etl_date AND ds_rcrd_st = 'ACTIVE'`
  → Thiếu filter → Warning (mã: L2-SCD4A-JOIN-FILTER, nguy cơ sai số hoặc duplicate fanout)

□ Orphan Entity & Table Check 3 Chiều (LLD ↔ HLD Entities ↔ Flat Table SQL):
  → Đối soát ma trận 3 chiều: Datamart/lld/{MODULE}/*.csv ↔ Datamart/hld/DTM_{MODULE}_Entities.csv (.md) ↔ Datamart/flat-table/{MODULE}/01_create_*.sql
  → Mọi bảng Fact/Operational (trừ Dimension dùng chung SHARED) phải có mặt đồng bộ ở cả 3 tầng
  → Khi phát hiện thực thể thiếu tầng, BẮT BUỘC phân loại chính xác theo 2 nhánh:
      • Nhánh A (Incomplete Implementation): Bảng còn giá trị / có ≥1 KPI READY trong HLD/Detail Mapping → 🔴 Critical (mã: L2-ORPHAN-3WAY-INCOMPLETE). Yêu cầu bổ sung HLD Entities và sinh Flat Table SQL DDL/DML. TUYỆT ĐỐI CẤM XÓA BẢNG/ATTRIBUTES!
      • Nhánh B (Abandoned Entity): Bảng thực sự bị hủy / thay thế / 0 KPI READY → 🟡 Warning / 🔴 Critical (mã: L2-ORPHAN-3WAY-ABANDONED). Kích hoạt All-Tier Cleanup Protocol 5 bước để dọn dẹp sạch cả 3 tầng.

□ etl_logic Content Parity Check với Master Registry `datamart_attributes.csv`:
  → So khớp chuỗi `etl_logic` của từng thuộc tính trong nhóm đang review với dòng tương ứng trong `Datamart/lld/datamart_attributes.csv`
  → Bắt buộc khớp 100% byte-for-byte sau khi strip whitespace (chuẩn hóa \r\n thành \n)
  → Lệch logic (cắt cụt cú pháp, thiếu WHERE, sai JOIN, sai công thức) hoặc thiếu dòng trong master CSV → 🔴 Critical (mã: L2-ETL-LOGIC-PARITY-MISMATCH / L4-MASTER-REGISTRY-OUT-OF-SYNC)
  → Nghiêm cấm tình trạng sửa file module nhưng quên cập nhật master registry

□ Role-Playing Date Dimension Key trên Fact table (CẤM cdr_dt_dim_id trên Fact):
  → Chạy script kiểm tra: python scripts/check_date_fk.py --module {MODULE}
  → Tuyệt đối cấm sử dụng `Calendar Date Dimension Id` / `cdr_dt_dim_id` trên bất kỳ Fact table nào (`cdr_dt_dim_id` chỉ là PK của riêng bảng Dimension `cdr_dt_dim`)
  → Với Fact Snapshot (`fct_*_snpst`): Cột ngày snapshot kỳ bắt buộc là `Snapshot Date Dimension Id` → `snpst_dt_dim_id`
  → Với các Fact khác: Cột khóa ngoại ngày bắt buộc đặt theo vai trò nghiệp vụ `<Role> Date Dimension Id` → `<role>_dt_dim_id` (`issue_dt_dim_id`, `trade_dt_dim_id`, `submission_dt_dim_id`, `evaluation_dt_dim_id`, `effective_dt_dim_id`...)
  → Vi phạm → 🔴 Critical (mã: L2-DATE-FK-ROLE-PLAYING, phân loại Kịch bản C — Lỗi kỹ thuật, yêu cầu chuyển giao sang datamart-lld-design để đồng bộ field rename)

□ Kiểm định Nền tảng Lưu trữ Dữ liệu Chuỗi Thời Gian cho Window Functions:
  → Nếu nhóm có chỉ tiêu dạng chuỗi thời gian (Rolling N phiên, Đỉnh/Đáy 52 tuần, 3 tháng, 6 tháng, MA5, MA10, MA20):
      - BẮT BUỘC trường dữ liệu đo lường (như `close_price`, `total_matched_vol`) phải được lưu trữ trên bảng Fact Periodic Snapshot (`table_type: fact`, prefix `fct_*_snpst`) với Grain theo từng ngày giao dịch.
      - TUYỆT ĐỐI CẤM sử dụng trường từ Dimension SCD4A Current-State (như `security_trading_snpst_dim`) làm nguồn cho Window Function lịch sử (vì Dimension current-state chỉ chứa 1 bản ghi duy nhất của ngày hiện tại).
      - Vi phạm → 🔴 Critical (mã: L2-WINDOW-STORAGE-INVALID)

□ Kiểm tra chỉ tiêu Delete từ BA:
  → Xác nhận không có cột nào trong Attributes được thiết kế cho chỉ tiêu BA có Trạng thái mapping = Delete / DELETED / Xóa (nếu có → 🔴 Critical, yêu cầu xóa khỏi Attributes)
```

---

### Lớp 3: Detail Mapping (Datamart → Báo cáo)

```
□ Mọi KPI_ID trong HLD (Done/Doing) có dòng trong Detail Mapping?
  → Thiếu → Critical

□ KPI Pending: tuân thủ Quy tắc L4 — bắt buộc CẢ 4 CỘT mart_table, mart_column, column_role, logic ĐỀU PHẢI ĐỂ TRỐNG TUYỆT ĐỐI ("")?
  → Chỉ điền kpi_id, kpi_name, tab, nhom, tinh_chat, source_module, và ghi_chu (bắt đầu bằng "Pending - [Nhóm 1-5]")
  → Vi phạm (để sót giá trị ở bất kỳ cột nào trong 4 cột trên) → 🔴 Critical (mã: L3-PENDING-RULE-L4-VIOLATION)

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
  → DEPRECATED: chỉ tiêu bãi bỏ sau thống nhất BA — mart_table/mart_column để trống, logic = 'Đã loại bỏ — không tạo cột/slicer'

□ Kiểm tra Quy cách Chỉ tiêu REUSE (Quy tắc L15):
  → Phân biệt rõ hai trường hợp REUSE:
      • Case 1 (Tái sử dụng Measure/Dim vật lý đã có sẵn trên Fact/Dim): BẮT BUỘC điền đủ mart_table và mart_column; column_role là MEASURE, SLICER hoặc FILTER; ghi_chu ghi rõ "Reuse từ Nhóm X: mart_table.mart_column". CẤM để trống mart_table hoặc mart_column.
      • Case 2 (Tái sử dụng qua BI layer / phái sinh không có cột vật lý riêng): BẮT BUỘC để trống mart_table và mart_column (""); column_role là DERIVED; logic viết công thức inline xuống physical table; ghi_chu ghi rõ "Reuse qua BI layer / DERIVED từ Nhóm X". CẤM tự ý gán tên cột ảo vào mart_table/mart_column.
  → Vi phạm (để trống cột ở Case 1 hoặc gán cột ảo ở Case 2) → 🔴 Critical (mã: L3-REUSE-INVALID)

□ Kiểm tra Phân định DEPRECATED vs PENDING (Quy tắc L16):
  → Chỉ tiêu đã thống nhất bãi bỏ với BA/PO: BẮT BUỘC đánh dấu đúng column_role = 'DEPRECATED', để trống mart_table và mart_column, logic = 'Đã loại bỏ — không tạo cột/slicer', ghi rõ lý do và ngày bãi bỏ tại ghi_chu.
  → TUYỆT ĐỐI CẤM đánh tráo chỉ tiêu bãi bỏ/không triển khai thành nhãn PENDING (gắn "Pending - [Nhóm 1-5]") làm phình to blocker giả tạo.
  → Vi phạm đánh tráo DEPRECATED thành PENDING → 🔴 Critical (mã: L3-DEPRECATED-AS-PENDING)

□ Kiểm tra Khớp Cấp độ Hạt Công thức (Formula Grain & Group By Verification):
  → Với MỌI dòng MEASURE hoặc DERIVED có chứa hàm tổng hợp (`SUM`, `MAX`, `AVG`) hoặc `GROUP BY` / `PARTITION BY`:
      - Đọc mockup giao diện: "1 dòng kết quả trên bảng/biểu đồ = 1 đối tượng gì?" (Mã CK, Chỉ số, CTCK, hay Ngành?).
      - Đối chiếu danh sách cột trong mệnh đề `GROUP BY` / `PARTITION BY` trong cột `logic`: Bắt buộc phải chứa đúng khóa định danh của đối tượng đó.
      - Cấm tuyệt đối việc copy công thức từ nhóm khác có grain khác (như copy Vốn hóa rổ chỉ số `idx_market_cap` sang bảng Top-N mã CK — điển hình case K_GSTT_61).
      - Vi phạm → 🔴 Critical (mã: L3-GRAIN-MISMATCH)

□ Kiểm định Cấu hình Window Functions & Chuẩn hóa Khung Thời Gian:
  → Với các chỉ tiêu đỉnh/đáy, giá cao nhất/thấp nhất, MA:
      - Kiểm tra trường giá cơ sở: Đối chiếu tài liệu BA xem quy định dùng `close_price` (chuẩn báo cáo định giá, BM021_MSS) hay `high_price`/`low_price` (biểu đồ nến kỹ thuật). Sai trường giá → 🔴 Critical.
      - Kiểm tra số phiên lookback (Trading Sessions):
          • 52 tuần gần nhất: Đúng 260 phiên (`ROWS BETWEEN 259 PRECEDING AND CURRENT ROW`). CẤM dùng `INTERVAL '52' WEEK`.
          • 6 tháng gần nhất: Đúng 130 phiên (`ROWS BETWEEN 129 PRECEDING AND CURRENT ROW`).
          • 3 tháng gần nhất: Đúng 65 phiên (`ROWS BETWEEN 64 PRECEDING AND CURRENT ROW`).
          • 1 tháng / 4 tuần: Đúng 20 phiên (`ROWS BETWEEN 19 PRECEDING AND CURRENT ROW`).
      - Kiểm tra cấu trúc phân đoạn: Bắt buộc có `PARTITION BY <entity_id>` (như `symbol`) và `ORDER BY <date_col> ASC`. Thiếu `PARTITION BY` → 🔴 Critical (gây trộn lẫn chuỗi giá của mọi cổ phiếu).
      - Vi phạm → 🔴 Critical (mã: L3-FORMULA-WINDOW-MISMATCH)

□ Kiểm tra Nhất Quán Chu Kỳ Thời Gian Trong Tỷ Số Tài Chính (Financial Ratio Consistency):
  → Với các chỉ số tài chính (P/E, P/B, EPS, BVPS, ROE, ROA):
      - Nhất quán Chu kỳ Tử số & Mẫu số:
          • EPS Quý gần nhất = LNST Quý / Số CP bình quân Quý.
          • EPS TTM (4 quý) = LNST TTM 4 quý / Số CP bình quân 4 quý.
          • P/E Chuẩn = Giá đóng cửa / EPS TTM (4 quý). Nếu dùng EPS Quý phải nhân 4 quy năm.
          • ROE = LNST TTM / VCSH bình quân (Đầu kỳ + Cuối kỳ)/2.
      - Cấm Cộng Dồn Chỉ tiêu BCDKT: Cấm `SUM` vốn chủ sở hữu (`owner_equity`) hay tổng tài sản qua 4 quý (chỉ được lấy số dư quý gần nhất hoặc tính bình quân).
      - Vi phạm → 🔴 Critical (mã: L3-FINANCIAL-PERIOD-INCONSISTENT)

□ mart_table / mart_column dùng tên LOGICAL; cột `logic` bắt buộc dùng tên PHYSICAL:
  → Ngược lại → Warning

□ Chiều lặp lại giữa các nhóm: mỗi nhóm có explicit SLICER/FILTER riêng (không dùng "xem nhóm X")

□ Kiểm tra chỉ tiêu Delete từ BA:
  → Xác nhận TUYỆT ĐỐI không có dòng nào trong Detail Mapping sinh ra từ chỉ tiêu BA có Trạng thái mapping = Delete / DELETED / Xóa
```

---

### Lớp 4: Model Registry (`datamart_model.yaml`), Master Registry & Flat Tables

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

□ Master Registry CSV Synchronization (Datamart/lld/datamart_attributes.csv):
  → 100% thuộc tính của file module Attributes phải có mặt đầy đủ trong master registry (không thiếu dòng)
  → Cặp định danh (datamart_table, datamart_column) và (datamart_entity, datamart_attribute) khớp chính xác 1-1
  → Biểu thức etl_logic khớp byte-for-byte với file module (sau strip whitespace, chuẩn hóa CRLF)
  → Master registry không chứa dòng mồ côi của các bảng đã bị loại bỏ/hủy (Nhánh B)
  → Chạy script verify: python scripts/check_parity.py --module {MODULE} --strict

□ Kiểm tra Đồng bộ Flat Table (Flat Table Synchronization Check):
  □ Column Coverage Check (Độ bao phủ cột Fact + Dim):
    → 100% cột Fact và Operational trong Attributes module (trừ các trường kỹ thuật audit ds_batch_date, ds_population_timestamp) phải có mặt trong DDL 01_create_*.sql
    → 100% cột giá trị nghiệp vụ của các Dimension được JOIN (theo FKs) phải có mặt trong DDL (bỏ qua PK surrogate, src_stm_code và các trường kỹ thuật audit SCD4A ds_rcrd_st, ds_rcrd_isrt_dt, ds_rcrd_udt_dt, ds_etl_pcs_tms, ds_snpst_dt)
    → Đảm bảo có mặt đầy đủ cột ngày từ cdr_dt_dim (theo alias vai trò ngày: snpst_cdr_dt, issue_cdr_dt, trade_cdr_dt...)
    → Thiếu cột → 🔴 Critical (mã: L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING)
  □ 1-1 Projection Alignment Check (Khớp thứ tự & số lượng chiếu):
    → Tổng số cột khai báo trong lệnh CREATE TABLE (01_create_*.sql) phải bằng chính xác tổng số biểu thức cột được chiếu trong SELECT của INSERT INTO (02_populate_*.sql)
    → Thứ tự các cột trong câu lệnh CREATE TABLE phải khớp tuần tự 1-1 với thứ tự trong mệnh đề SELECT
    → Tên alias trong SELECT (... AS col_name) khớp chính xác 100% với tên cột định nghĩa trong CREATE TABLE
    → Lệch số lượng hoặc sai thứ tự cột → 🔴 Critical (mã: L4-FLAT-TABLE-PROJECTION-MISALIGNMENT)
  □ Column Drift Check (Chống trôi lệch cột):
    → Không có bất kỳ cột nào xuất hiện trong Flat Table SQL mà thiếu trong master datamart_attributes.csv
    → Không có cột Fact nào có KPI khai thác trong Detail Mapping mà bị bỏ sót khỏi Flat Table
    → Không có cột nào trong CREATE TABLE (fact/operational section) mà không tồn tại trong Attributes.csv (cột mồ côi/cột thừa phải xóa)
    → Phát hiện trôi lệch cột → 🔴 Critical (mã: L4-FLAT-TABLE-COLUMN-DRIFT)
  □ Parameter Consistency Check (Thống nhất tham số ETL):
    → Toàn bộ các mệnh đề lọc ngày chạy ETL trong file 02_populate_*.sql bắt buộc sử dụng thống nhất tham số :etl_date (WHERE snpst_cal.cdr_dt = :etl_date / WHERE evnt_cal.cdr_dt = :etl_date)
    → Tuyệt đối cấm dùng {etl_date}, $etl_date, ?, hoặc hardcode chuỗi ngày
    → Sai cú pháp tham số → 🔴 Critical (mã: L4-FLAT-TABLE-PARAMETER-INCONSISTENT)
  □ Common Dimensions ClickHouse Sync Check (Kiểm tra Chiều dùng chung):
    → Đối với chiều ngày lịch dùng chung: bắt buộc có script DDL và DML tạo bảng phẳng datamart.cdr_dt_flat (nguồn datamart.cdr_dt_dim) trong Datamart/flat-table/Common/ (01_create_common_flat_tables.sql và 02_populate_common_flat_tables.sql) phục vụ khai thác trực tiếp trên ClickHouse
    → Đảm bảo đủ 9 cột kể cả cờ is_trading_date (phục vụ lọc ngày giao dịch và đếm phiên lookback)
    → Thiếu script Common Flat Table trên ClickHouse khi có yêu cầu khai thác → 🔴 Critical (mã: L4-COMMON-DIM-CLICKHOUSE-MISSING)
```


---

## PHẦN 3: NGUYÊN TẮC AN TOÀN & GATE CONTROL

1. **GATE 1 (Sau Bước 0b/0c — Stop & Report):** Sau khi chạy Macro-Review, Claude bắt buộc DỪNG và trình bày bảng kế hoạch + ma trận đối soát cho human, chờ human xác nhận thứ tự review. CHẶN CỨNG không vào Micro-Review nếu phát hiện Orphan 3 chiều, lệch etl_logic Parity, sai Role-Playing Date FK, chỉ tiêu Delete còn tồn tại, hoặc lệch cấp độ hạt kiến trúc / sai nền tảng lưu trữ chuỗi thời gian.
2. **GATE 2 (Group Checkpoint — Sau Mỗi Nhóm Micro-Review):**
   - Nếu nhóm có vấn đề (Critical 🔴 / Warning 🟡): Bao gồm cả vi phạm Parity `L2-ETL-LOGIC-PARITY-MISMATCH`, Orphan 3 chiều `L2-ORPHAN-3WAY-*`, lệch Grain `L1/L3-GRAIN-MISMATCH`, sai cấu hình Window Functions `L3-FORMULA-WINDOW-MISMATCH`, sai lưu trữ `L2-WINDOW-STORAGE-INVALID`, lệch chu kỳ tỷ số tài chính `L3-FINANCIAL-PERIOD-INCONSISTENT`, hoặc vi phạm Detail Mapping (`L3-PENDING-RULE-L4-VIOLATION`, `L3-REUSE-INVALID`, `L3-DEPRECATED-AS-PENDING`) → Claude DỪNG, hỏi human muốn (a) sửa ngay qua skill con, (b) ghi nhận vào Backlog và đi tiếp, hay (c) dừng.
   - Nếu nhóm không có vấn đề (4 Lớp OK): Tự động in "✅ Nhóm N — OK" và chuyển sang nhóm kế tiếp. Lỗi Info 🔵 ghi vào Backlog tạm, tiếp tục.
3. **Nguyên Tắc Không Tự Ý Sửa File Trực Tiếp:**
   - Mọi thay đổi nội dung nghiệp vụ HLD (Fact/Dim, grain, nguồn, bảng KPI) → gọi `datamart-hld-design`.
   - Mọi thay đổi nội dung LLD (Attributes, Detail Mapping, Registry) → gọi `datamart-lld-design`.
   - Kịch bản C (lỗi kỹ thuật): Trình bày action đề xuất → Claude chờ human xác nhận → gọi skill con tương ứng để thực hiện. Claude tuyệt đối không tự Edit trực tiếp vào file HLD/LLD.
4. **Nguyên Tắc Bất Khả Xâm Phạm — Tuyệt Đối Cấm Sửa Atomic:**
   - Skill Datamart Review (và các skill thiết kế Datamart) chỉ có quyền **READ-ONLY** trên thư mục `DataModel/Atomic/` và `DataModel/working/Atomic/`.
   - Tuyệt đối không được tạo file mới hay sửa đổi bất kỳ file YAML nào trong `DataModel/`.
   - Reviewer phải xác minh trong git status / diff rằng không có bất kỳ file Atomic nào bị sửa đổi trong suốt quá trình làm việc với Datamart. Nếu phát hiện thiếu nguồn Atomic, chỉ kết luận `PENDING` và ghi nhận Open Issue, không tự ý can thiệp vào Atomic.
5. **Cổng Kiểm Soát Bàn Giao Kịch Bản C (Handover Blocking Gate):**
   - Bất kể Kịch bản C được thực hiện qua skill con hay qua Action Proposal được Human duyệt, NGAY SAU khi chỉnh sửa file Attributes module, Reviewer/Developer BẮT BUỘC:
     (1) Đồng bộ dòng tương ứng vào `Datamart/lld/datamart_attributes.csv`.
     (2) Chạy `python scripts/check_parity.py --module {MODULE} --strict` xác nhận 0 mismatch.
     (3) Chạy `python scripts/check_orphan.py --module {MODULE} --strict` xác nhận 0 orphan (Nhánh A đã hoàn tất, Nhánh B đã dọn dẹp sạch).
   - **LỆNH CẤM:** Nghiêm cấm mọi hành vi kết luận "Đã hoàn thành" hoặc bàn giao khi chưa pass 100% cả 2 script trên.
6. **GATE 4 (Flat Table Synchronization & Delivery Gate — Cổng Kiểm Định Đồng Bộ Flat Table):**
   - Reviewer BẮT BUỘC thực hiện kiểm định toàn diện bộ script Flat Table (`01_create_*_flat_tables.sql` và `02_populate_*_flat_tables.sql`) trước khi ký duyệt nghiệm thu bàn giao:
     • **Column Coverage:** 100% cột Fact/Operational và thuộc tính nghiệp vụ của Dim được JOIN có mặt trong DDL.
     • **1-1 Projection Alignment:** Khớp 1-1 chính xác tuyệt đối về số lượng và thứ tự cột giữa câu lệnh `CREATE TABLE` và mệnh đề `SELECT`.
     • **Column Drift:** 0 cột thừa/thiếu giữa Flat Table SQL, master `datamart_attributes.csv`, và Detail Mapping.
     • **Parameter Consistency:** 100% mệnh đề lọc ngày chạy ETL dùng biến chuẩn `:etl_date`.
   - **LỆNH CẤM:** Nghiêm cấm mọi hành vi bỏ qua Gate 4 hoặc phê duyệt bàn giao khi Flat Table SQL chưa được đồng bộ đầy đủ theo 4 tiêu chí trên.


