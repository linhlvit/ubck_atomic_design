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

□ Kiểm tra chỉ tiêu Delete từ BA:
  → Xác nhận không có cột nào trong Attributes được thiết kế cho chỉ tiêu BA có Trạng thái mapping = Delete / DELETED / Xóa (nếu có → 🔴 Critical, yêu cầu xóa khỏi Attributes)
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

□ Kiểm tra chỉ tiêu Delete từ BA:
  → Xác nhận TUYỆT ĐỐI không có dòng nào trong Detail Mapping sinh ra từ chỉ tiêu BA có Trạng thái mapping = Delete / DELETED / Xóa
```

---

### Lớp 4: Model Registry (`datamart_model.yaml`) & Master Registry (`datamart_attributes.csv`)

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
```

---

## PHẦN 3: NGUYÊN TẮC AN TOÀN & GATE CONTROL

1. **GATE 1 (Sau Bước 0b/0c — Stop & Report):** Sau khi chạy Macro-Review, Claude bắt buộc DỪNG và trình bày bảng kế hoạch + ma trận đối soát cho human, chờ human xác nhận thứ tự review. CHẶN CỨNG không vào Micro-Review nếu phát hiện Orphan 3 chiều, lệch etl_logic Parity, sai Role-Playing Date FK hoặc chỉ tiêu Delete còn tồn tại.
2. **GATE 2 (Group Checkpoint — Sau Mỗi Nhóm Micro-Review):**
   - Nếu nhóm có vấn đề (Critical 🔴 / Warning 🟡): Bao gồm cả vi phạm Parity `L2-ETL-LOGIC-PARITY-MISMATCH` hay Orphan 3 chiều `L2-ORPHAN-3WAY-*` → Claude DỪNG, hỏi human muốn (a) sửa ngay qua skill con, (b) ghi nhận vào Backlog và đi tiếp, hay (c) dừng.
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

