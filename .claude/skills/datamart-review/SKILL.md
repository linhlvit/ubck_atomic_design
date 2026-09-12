---
name: datamart-review
description: |
  Master Quality Gatekeeper: Review cross-check BA analyst ↔ Datamart (HLD + LLD).
  Hỗ trợ Macro-Review (tiến độ toàn phân hệ), Micro-Review (chi tiết 4 lớp từng nhóm),
  và Issue Trace 5 tầng (Kịch bản E). Đảm bảo chuẩn Kimball, SCD4A và tính toàn vẹn DWH.
triggers:
  - /datamart-review [MODULE]
  - /datamart-review [MODULE] [nhóm N]
---

# Skill: Review Cross-check Datamart (Master Orchestrator)

## 1. QUY ƯỚC AN TOÀN & NGUYÊN TẮC BẤT KHẢ XÂM PHẠM

1. **Vai Trò Độc Lập:** Claude đóng vai trò Data Model Reviewer độc lập (Read-Only Explorer). Human là người quyết định và phê duyệt tối cao.
2. **CẤM TUYỆT ĐỐI Tự Sửa File Trực Tiếp:** Claude **TUYỆT ĐỐI KHÔNG** tự Edit trực tiếp vào file HLD (`.md`), LLD (`Attributes.csv`, `Detail_Mapping.csv`) hay Model Registry (`datamart_model.yaml`, `datamart_attributes.csv`). Mọi sửa đổi phải lập Action Proposal, xin phê duyệt và ủy quyền cho skill con (`datamart-hld-design`, `datamart-lld-design`) thực hiện.
3. **READ-ONLY Trên Thư Mục Atomic:** Tuyệt đối không tạo, sửa, xóa file trong `DataModel/Atomic/`.
4. **Tuân Thủ Tuyệt Đối GATE RULES & CƠ CHẾ CHẶN CỨNG (BLOCKING GATES):**
   - Bắt buộc dừng tại **GATE 1** (sau Bước 0b/0c Macro-Audit) và **GATE 2** (sau mỗi nhóm Micro-Review có lỗi Critical/Warning).
   - Áp dụng cơ chế **BLOCKING HOÀN TOÀN** quy trình bàn giao hoặc chuyển nhóm khi phát hiện:
     - Lệch nội dung `etl_logic` giữa file module attributes và master registry `datamart_attributes.csv` (vi phạm Parity).
     - Vi phạm Orphan 3 chiều (LLD Attributes ↔ HLD Entities ↔ Flat Table SQL DDL) chưa được phân định và xử lý theo Nhánh A (Hoàn tất) hoặc Nhánh B (Dọn dẹp).
   - Không tự ý vượt Gate khi chưa có lệnh xác nhận từ Human.

---

## 2. MA TRẬN TÀI NGUYÊN & TRIGGER HƯỚNG DẪN (HUB & SPOKES)

| Phân Hệ / Tác Vụ Review | Tài Liệu Reference Bắt Buộc | Công Cụ CLI Tự Động Hóa |
|---|---|---|
| **Cấu trúc File BA & Dò Delimiter** | `reference/ba_source_profile.md` | `python scripts/datamart_progress_analyzer.py` |
| **Phân Loại Lỗi & Cây 6 Nhánh PENDING** | `reference/issue_classification.md` | `scripts/datamart_progress_analyzer.py` |
| **Đối Soát Số Lượng KPI 2 Chế Độ** | `reference/kpi_reconciliation_rules.md` | `scripts/datamart_progress_analyzer.py --module [M]` |
| **Quy Chuẩn Role-Playing Date FK** | `reference/role_playing_date_fk_guide.md` | `python scripts/check_date_fk.py --module [M]` |
| **Orphan Check 3 Chiều (Nhánh A & B)** | `reference/technical_review_rules.md` (Mục 8) | `python scripts/check_orphan.py --module [M]` |
| **Bảo Vệ Master Registry & Parity etl_logic** | `reference/technical_review_rules.md` (Mục 9) | `python scripts/check_parity.py --module [M]` |
| **Quy Tắc Kỹ Thuật Sâu Lớp 2 & Lớp 4** | `reference/technical_review_rules.md` | — |
| **Checklist Đánh Giá Nhanh 4 Lớp** | `reference/review_checklist.md` | — |

---

## 3. NGUYÊN TẮC CỐT LÕI & ĐỊNH TUYẾN 5 KỊCH BẢN

Chuỗi truy vết 5 tầng: **BA Analyst ➔ Nguồn Thực (Source) ➔ Atomic DWH ➔ Datamart (HLD/LLD) ➔ Báo Cáo**.
Chuẩn hóa **BA Status:** `Done` / `Doing` / `Pending` / `Delete`.

### Ma Trận Định Tuyến Xử Lý 5 Kịch Bản Chuẩn Hóa (A — E):
| Kịch Bản | Dấu Hiệu Nhận Biết Cốt Lõi | Cơ Chế Phân Loại & Đơn Vị Chủ Trì | Định Tuyến Kỹ Thuật & Cổng Kiểm Soát (Skill Con) |
|:---:|---|---|---|
| **A** | Nghiệp vụ BA đổi / HLD thiếu / Chưa có nguồn Atomic | BA Pending (Nhánh 1-4) → BA / Atomic Team / DM Architect | Bàn giao BA hoặc gọi `datamart-hld-design` cập nhật HLD Section 1-5 |
| **B** | Đã có nguồn Atomic nhưng chưa thiết kế LLD | Datamart Pending (Nhánh 5) → DM Modeling | Trình đề xuất → Gọi `datamart-lld-design` (Phase 2 Entities + Phase 3 Flat Table) |
| **C** | Lỗi kỹ thuật LLD (Date FK, SCD4A, Naming, Flatten, Orphan 3-way, Parity Desync) | Lỗi thiết kế mô hình / out-of-sync → DM Modeling | Trình action proposal → Dừng chờ duyệt → Gọi `datamart-lld-design`. **BẮT BUỘC:** Chạy `check_parity.py` và `check_orphan.py` đạt 0 lỗi trước khi nghiệm thu! |
| **D** | Lỗi kiến trúc HLD (Grain, Flowchart, 5 Section, Atomic cũ) | Lỗi phân tích cấp cao → DM Architect | Trình action proposal → Dừng chờ duyệt → Gọi `datamart-hld-design` tái thiết kế |
| **E** | Bug report người dùng / Số liệu báo cáo sai | Issue Trace 5 tầng → Reviewer / Lead | Quy trình rẽ nhánh Bước 0-ALT (trace ngược 5 tầng, kiểm tra parity logic và orphan) |

---

## 4. QUY TRÌNH ĐIỀU PHỐI TỔNG THỂ & GATE CONTROL

```
[Chế độ 1: MACRO-AUDIT (Toàn Module)]
  Bước 0: File Resolution động & Chạy Progress Analyzer
  Bước 0b: Check Cấu trúc HLD 5 Section & Đối soát Số lượng 2 Chế độ (Total/Ready)
  Bước 0c: [1 lần/module] Bộ 3 CLI Sanity Check:
           - Quét Date FK: python scripts/check_date_fk.py --module [M]
           - Quét Orphan 3 Chiều: python scripts/check_orphan.py --module [M]
           - Quét etl_logic Parity: python scripts/check_parity.py --module [M]
           + 13 mục HLD + 10 TC LLD + Quét Delete/Retired
  └── ⛔ GATE 1 (STOP & REPORT): DỪNG, xuất báo cáo tổng thể, CHẶN CỨNG nếu có Orphan hoặc Parity Mismatch, chờ Human phê duyệt kế hoạch.
        ↓ (Human duyệt)
[Chế độ 2: MICRO-REVIEW (Tuần Tự Từng Nhóm)]
  Vòng lặp Nhóm 1 → N:
    Bước 1: Đọc BA nhóm N theo reference/ba_source_profile.md
    Bước 2: Review 4 Lớp Kỹ Thuật Chuẩn:
      - Lớp 1: HLD Alignment (Coverage, Grain, Bảng 7 cột, Temporal SQL)
      - Lớp 2: Attributes Verification (Atomic YAML, SCD4A, Flatten, Role-Playing Date FK, Parity Master Sync, 3-Way Orphan)
      - Lớp 3: Detail Mapping Verification (Inline DERIVED, Trace logic, Date FK JOIN)
      - Lớp 4: Model & Master Registry Synchronization (datamart_model.yaml & datamart_attributes.csv)
    └── ⛔ GATE 2 (Group Checkpoint):
          * OK ➔ Tự động in "✅ Nhóm N — OK" và sang Nhóm N+1.
          * Info 🔵 ➔ Ghi nhận vào Backlog, tiếp tục sang Nhóm N+1.
          * Critical 🔴 / Warning 🟡 ➔ DỪNG hỏi human: (a) Sửa ngay qua skill con, (b) Ghi nhận, (c) Dừng.
        ↓ (Hoàn tất toàn bộ nhóm)
[Giai đoạn 3: TỔNG HỢP & BÀN GIAO]
  Bước 3: Xuất Bảng Tổng hợp Scorecard & Action Items theo Kịch bản A-E.
  Bước 4: Bàn giao sang skill con & ⛔ CỔNG CHẶN BÀN GIAO (Bắt buộc verify 0 mismatch parity & 0 orphan).
```

---

## 5. GIAI ĐOẠN 1: BƯỚC 0, 0b & 0c — MACRO-AUDIT TIẾN ĐỘ & SANITY CHECK

### Bước 0: File Resolution Động & Phân Tích Tiến Độ
1. Nhận diện module, resolve file: hỗ trợ cả file thường và file gộp (như `BA_analyst_GSĐC.csv`).
2. Chạy script phân tích tiến độ tự động:
   ```bash
   python scripts/datamart_progress_analyzer.py --module [MODULE]
   ```
   Xuất Ma trận Tiến độ Chéo (Cross-status Matrix) và phân loại PENDING theo Cây 6 Nhánh (xem `reference/issue_classification.md`).

### Bước 0b: Kiểm Tra Cấu Trúc HLD & Đối Soát Số Lượng 2 Chế Độ
1. **Kiểm tra 5 Section HLD:** Bắt buộc có đủ: Section 1 Lineage, Section 2 Tổng quan, Section 3 Mô hình 3 tầng, Section 4 Reuse Analysis, Section 5 Vấn đề mở.
   - Thiếu hẳn Section 4 Reuse Analysis: Đánh giá **🔴 Critical cấp toàn module**.
   - Có Section 4 nhưng thiếu một vài dòng bảng Fact/Dim: Đánh giá **🟡 Warning**.
2. **Đối soát số lượng KPI 2 Chế độ:** Áp dụng `reference/kpi_reconciliation_rules.md`:
   - *Chế độ 1 (Total Scope):* `Total_BA` (loại trừ Delete) bắt buộc khớp 1-1 với `Total_HLD` (mọi KPI_ID, kể cả PENDING, loại trừ `_YOY`).
   - *Chế độ 2 (Ready Scope):* `Ready_BA` (Done/Doing) bắt buộc khớp với `Ready_HLD` (READY) và `Ready_DM`.
   - *Reconciled Delta:* Cho phép lệch hợp lệ nếu do chỉ tiêu phái sinh nội tại (`_YOY`), chia tách loại hình doanh nghiệp (GSĐC), hoặc tách measure vật lý đã có ghi chú schema trong HLD.

### Bước 0c: Kiểm Định Toàn Diện Cấp Toàn Module (Chạy 1 Lần Duy Nhất)
1. **Quét Role-Playing Date FK:**
   ```bash
   python scripts/check_date_fk.py --module [MODULE]
   ```
   Phát hiện ngay lập tức vi phạm `cdr_dt_dim_id` trên Fact hoặc Fact Snapshot thiếu `snpst_dt_dim_id`.
2. **Quét Orphan Check 3 Chiều Toàn Module (LLD ↔ Entities ↔ Flat Table):**
   ```bash
   python scripts/check_orphan.py --module [MODULE]
   ```
   Đối soát ma trận 3 chiều: LLD Attributes CSV (`Datamart/lld/{MODULE}/*.csv`) ↔ HLD Entities (`Datamart/hld/DTM_{MODULE}_Entities.csv` & `.md`) ↔ Flat Table SQL DDL (`Datamart/flat-table/{MODULE}/01_create_*.sql`).
   Phân loại chính xác 2 nhánh xử lý:
   - **Nhánh A (Hoàn tất phần còn thiếu — Incomplete Implementation):** Bảng còn giá trị / có ≥1 KPI READY trong HLD/Detail Mapping nhưng thiếu trong Entities hoặc Flat Table SQL → Gán mã lỗi `🔴 Critical: [L2-ORPHAN-3WAY-INCOMPLETE]`. Bắt buộc hoàn tất Phase 2 Entities và Phase 3 Flat Table, **TUYỆT ĐỐI KHÔNG ĐƯỢC XÓA**.
   - **Nhánh B (Dọn dẹp toàn diện nếu entity bị hủy — Abandoned Entity):** Bảng thực sự bị hủy / 0 KPI READY nhưng còn sót lại trong LLD CSV, Entities.csv hoặc Flat Table SQL → Gán mã lỗi `🟡 Warning / 🔴 Critical: [L2-ORPHAN-3WAY-ABANDONED]`. Kích hoạt All-Tier Cleanup Protocol 5 bước để dọn dẹp sạch sẽ cả 3 tầng.
3. **Kiểm Tra etl_logic Content Parity & Bảo Vệ Master Registry:**
   ```bash
   python scripts/check_parity.py --module [MODULE]
   ```
   So khớp từng dòng `(datamart_table, datamart_column)` và `(datamart_entity, datamart_attribute)` giữa file module attributes `Datamart/lld/{MODULE}/*.csv` và master registry `Datamart/lld/datamart_attributes.csv`. Bất kỳ sự sai lệch chuỗi `etl_logic` (sau khi strip whitespace) hoặc thiếu/thừa dòng thuộc tính → Gán mã lỗi **🔴 Critical (`[L2-ETL-LOGIC-PARITY-MISMATCH]` / `[L4-MASTER-REGISTRY-OUT-OF-SYNC]`)**.
4. **Sanity 13 Mục Bước 5B HLD & 10 TC Phase 1 LLD:** Thực thi kiểm tra cấu trúc erDiagram, node flowchart Staging, và 10 tiêu chuẩn bảng Attributes master.
5. **Quét Chỉ tiêu bị XÓA (`Delete` / `DELETED` / `Xóa`):** Đối chiếu danh sách chỉ tiêu bị xóa từ BA với HLD và LLD.
   - Nếu phát hiện chỉ tiêu bị XÓA còn tồn tại trong Datamart → Gán lỗi vi phạm cấm kỵ **🔴 CRITICAL VIOLATION (`[L1/L2-DELETE-VIOLATION]`)**.
   - Áp dụng quy trình loại bỏ `DEPRECATED / RETIRED`: gỡ khỏi mapping active, set `ds_rcrd_st = 'INACTIVE'`.

> ⛔ **GATE 1 (STOP & REPORT — CHẶN CỨNG BẮT BUỘC):**
> Claude bắt buộc DỪNG LẠI, xuất Báo cáo Tiến độ Toàn Module + Danh sách Blocker, và **CHẶN CỨNG TUYỆT ĐỐI** không cho phép chuyển sang Micro-Review nếu phát hiện:
> 1. Có vi phạm Orphan Check 3 chiều (Nhánh A chưa hoàn tất hoặc Nhánh B chưa dọn sạch).
> 2. Có sai lệch `etl_logic` Content Parity giữa file module và master registry `datamart_attributes.csv`.
> 3. Có vi phạm `cdr_dt_dim_id` trên Fact table.
> 4. Có chỉ tiêu BA = Delete còn lọt vào thiết kế Datamart.
> Reviewer phải chờ Human phê duyệt kế hoạch remediation hoặc xác nhận ngoại lệ Whitelist trước khi mở Gate 1.

---

## 6. BƯỚC 0-ALT: REVIEW THEO ISSUE / BUG REPORT (KỊCH BẢN E)

Khi người dùng yêu cầu điều tra một lỗi cụ thể (sai số liệu báo cáo, thiếu trường, lệch grain):
1. **Trace ngược 5 tầng:** Báo cáo ➔ Datamart Flat SQL ➔ Detail Mapping ➔ Attributes (Module CSV & Master Registry) ➔ Atomic YAML ➔ BA/Source.
2. Xuất bảng trạng thái per-tầng (`✅ Khớp` / `⚠️ Lệch logic` / `❌ Mất dấu vết`).
3. Đọc sâu SQL tham khảo BA: Nhận diện các bẫy lọc thời gian (TTM 4 quý, rolling N phiên, `rn=1`, mức ưu tiên BCTC HN > TH > ME > RI).
4. Kiểm tra đối soát `etl_logic` parity giữa module CSV và master registry để loại trừ lỗi drift logic ngầm.
5. Xác định tầng gốc rễ gây lỗi (Root Cause), lập Action Plan và chờ phê duyệt.

---

## 7. GIAI ĐOẠN 2: BƯỚC 1 & 2 — MICRO-REVIEW CHI TIẾT TỪNG NHÓM (4 LỚP CHUẨN)

### Bước 1: Đọc BA Nhóm N
- **TUYỆT ĐỐI KHÔNG gán cứng delimiter=';' hay delimiter=','** khi đọc file BA. Bắt buộc dùng hàm dò delimiter động `detect_delimiter_and_header()`.
- Header nằm ở **dòng 1 với TOÀN BỘ 11 file hiện hành** (0-indexed: index 1). Dòng 0 là tiêu đề merge Excel.
- Đọc file BA theo quy chuẩn `reference/ba_source_profile.md`. Lọc bỏ các chỉ tiêu Delete.

### Bước 2: Kiểm Định Chi Tiết 4 Lớp Kỹ Thuật Chuẩn

#### 🔹 Lớp 1: HLD Alignment (Khớp Thiết Kế Khái Niệm)
- **Tiêu chí:** Coverage 2 chiều BA ↔ HLD; Đúng Grain phân tích; Bảng KPI chuẩn 7 cột; Phân định rõ Financial Flow (TTM) vs Stock (Latest Quarter); Nhất quán giữa KPI phái sinh và cơ sở phụ thuộc; Tuyệt đối không chứa chỉ tiêu BA = Delete.
- *Tra cứu chi tiết:* `reference/review_checklist.md` (Mục Lớp 1).

#### 🔹 Lớp 2: Attributes Verification (Atomic ➔ Datamart)
- 📌 **Deterministic Trigger:** Trước khi đánh giá Lớp 2, BẮT BUỘC dùng tool `view_file` đọc `reference/technical_review_rules.md` (đặc biệt Mục 8 & 9) và `reference/role_playing_date_fk_guide.md`.
- ⚓ **Anchor Summaries (Quy tắc sống còn):**
  1. *Flatten hoàn toàn:* `etl_logic` tham chiếu trực tiếp Atomic, **cấm dùng cột mart** (`fct_*.col`). Thiếu `join_atomic` là 🔴 Critical.
  2. *Verify Atomic YAML thật:* Tra cứu 2 nguồn approved (Ưu tiên 1 `DataModel/Atomic/`, Ưu tiên 2 `DataModel/working/Atomic/lld/`). **CẤM TUYỆT ĐỐI `Atomic_LinhLV/`**. Đếm attribute thật trong YAML.
  3. *Quy chuẩn SCD4A (`L2-SCD4A-TECH-FIELD` & `L2-SCD4A-JOIN-FILTER`):* Bảng Fact/Dim phải đủ 5 trường kỹ thuật (`ds_rcrd_st`, `ds_eff_start_dt`, `ds_eff_end_dt`, `ds_cdc_opr_cd`, `ds_load_ts`). Mệnh đề JOIN Atomic bắt buộc có `AND <atomic_table>.ds_rcrd_st = 'ACTIVE'`.
  4. *Role-Playing Date FK (`L2-DATE-FK-ROLE-PLAYING`):* Fact Periodic Snapshot bắt buộc `snpst_dt_dim_id`; Fact Event bắt buộc `<role>_dt_dim_id`. Cấm tuyệt đối `cdr_dt_dim_id` trên Fact. Cú pháp ETL Attributes tra cứu theo ngày tự nhiên: `LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt = <driving_table>.ds_snpst_dt`.
  5. *Physical Naming:* Tra cứu `system/rules/rule_physical_name_exceptions_datamart.csv`. Chỉ viết tắt từ trong exceptions, cấm mở rộng hoặc đổi từ đồng nghĩa.
  6. *Kiểm tra etl_logic Content Parity (`L2-ETL-LOGIC-PARITY-MISMATCH`):* Mọi dòng thuộc tính trong nhóm phải khớp 100% byte-for-byte với dòng tương ứng trong master registry `Datamart/lld/datamart_attributes.csv`. Lệch chuỗi logic là 🔴 Critical.
  7. *Orphan Check 3 Chiều theo Entity (`L2-ORPHAN-3WAY-*`):* Bảng Fact/Dim chứa thuộc tính nhóm đang review phải tồn tại đồng bộ ở cả 3 tầng. Nếu thiếu tầng, lập tức xác định Nhánh A (Hoàn tất, cấm xóa) vs Nhánh B (Dọn dẹp All-Tier).

#### 🔹 Lớp 3: Detail Mapping Verification (Datamart ➔ Báo Cáo)
- ⚓ **Anchor Summaries (Quy tắc sống còn):**
  1. *Trace logic BA:* Đọc full câu lệnh SQL và ghi chú của BA để chuyển hóa trọn vẹn vào `logic`.
  2. *Inline DERIVED:* Cột phái sinh bắt buộc inline toàn bộ công thức tính toán từ Atomic/Mart, **cấm tham chiếu mã KPI_ID khác** (như `K_01 + K_02`).
  3. *Trace cột LLD:* Cột `mart_table` và `mart_column` phải tồn tại thực tế và khớp 1-1 với Attributes.
  4. *Cú pháp JOIN Date FK:* Truy vấn Detail Mapping kết nối sang Dimension ngày theo khóa surrogate key: `LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt_dim_id = <fact>.<role>_dt_dim_id`.

#### 🔹 Lớp 4: Model & Master Registry Synchronization (`datamart_model.yaml` & `datamart_attributes.csv`)
- ⚓ **Anchor Summaries (Quy tắc sống còn):**
  1. *Khớp 1-1 Song Song:* Đồng bộ 100% tên bảng, cột và kiểu dữ liệu với file module Attributes VÀ master registry `datamart_attributes.csv`.
  2. *Domain Chuẩn:* Phân biệt Boolean direct (`boolean`) vs Indicator computed (`string` Y/N).
  3. *Bảo vệ SHARED Dimension:* Với Entity riêng (`module: "{MODULE}"`), đồng bộ theo Attributes. Với Entity `module: "SHARED"`, **Model Registry là nguồn sự thật** — bắt buộc sửa Attributes theo Registry, nghiêm cấm ghi đè Registry.
  4. *Bảo vệ Master Registry CSV (`datamart_attributes.csv`):* File master registry là nguồn sự thật tối cao cho toàn bộ thuộc tính Datamart. Nghiêm cấm chỉ sửa file module Attributes mà quên cập nhật master registry (`L4-MASTER-REGISTRY-OUT-OF-SYNC`).
  5. *Khóa Quyền Sửa File:* Reviewer TUYỆT ĐỐI KHÔNG tự sửa file registry. Lập Action Proposal (Kịch bản C), dừng chờ duyệt và ủy quyền cho `datamart-lld-design` cập nhật registry. Sau khi datamart-lld-design hoàn tất — Reviewer chạy script verify YAML parse và parity check.

> ⛔ **GATE 2 (GROUP CHECKPOINT):**
> - 4 Lớp = OK ➔ In "✅ Nhóm N — OK", tự động chuyển sang Nhóm N+1.
> - Lỗi Info 🔵 ➔ Ghi vào Backlog tạm, không dừng, tiếp tục Nhóm N+1.
> - Lỗi Critical 🔴 / Warning 🟡 ➔ DỪNG hỏi human: (a) Sửa ngay qua skill con, (b) Ghi nhận vào Backlog và đi tiếp, (c) Dừng review.

---

## 8. GIAI ĐOẠN 3: BƯỚC 3 & 4 — TỔNG HỢP VẤN ĐỀ, BACKLOG & BÀN GIAO

### Bước 3: Tổng Hợp Báo Cáo Scorecard & Danh Mục Vấn Đề
1. Xuất Bảng Chi tiết Vấn đề (Mã, Nhóm, Lớp, Mức độ Critical/Warning/Info, Mô tả, Kịch bản A-E, Action đề xuất).
2. Xuất Bảng Action Items theo nhóm ưu tiên (P0 Blocker ➔ P1 High ➔ P2 Medium ➔ P3 Low).

### Quy Tắc Bắt Buộc Khi Chuyển Trạng Thái: PENDING ➔ READY
Khi một chỉ tiêu được giải quyết nguồn hoặc thiết kế xong HLD:
> 🔴 **BẮT BUỘC:** Chạy review lại **cả 3 lớp LLD** (Lớp 2: Attributes, Lớp 3: Detail Mapping, Lớp 4: Model & Master Registry) ngay lập tức. Tuyệt đối không được chuyển READY chỉ dựa trên HLD mà bỏ qua kiểm tra LLD thực tế.

### Bước 4: Chuyển Giao Thực Hiện Qua Skill Con & Cổng Chặn Bàn Giao (Handover Blocking Gate)
- Claude tổng hợp lệnh gọi chuẩn xác:
  - Vấn đề Kịch bản A / D ➔ Chuyển giao `datamart-hld-design`.
  - Vấn đề Kịch bản B / C ➔ Chuyển giao `datamart-lld-design`.
- Dừng quy trình review và xuất Handoff Report cho ca làm việc kế tiếp.

### ⛔ CƠ CHẾ CẢNH BÁO & CỔNG CHẶN BÀN GIAO KỊCH BẢN C (HANDOVER BLOCKING GATE)
*(Chuẩn hóa từ bài học thực tế hệ thống GSTT 2026-09-11: sửa file module attributes mà quên đồng bộ master registry `datamart_attributes.csv`, và sót Fact đã READY khỏi Entities.csv/Flat Table)*

**QUY ĐỊNH BẮT BUỘC TRƯỚC KHI TỔNG KẾT VÀ BÀN GIAO (CLAIM DONE):**
Bất kể Kịch bản C được thực hiện qua lời gọi `datamart-lld-design` hay qua Action Proposal được Human phê duyệt thực thi trực tiếp, NGAY SAU khi chỉnh sửa file Attributes module (`Datamart/lld/{MODULE}/*.csv`), Reviewer/Developer BẮT BUỘC thực hiện quy trình kiểm định 3 bước:

1. **Đồng bộ Master Registry:** Cập nhật chính xác từng dòng tương ứng vào `Datamart/lld/datamart_attributes.csv`.
2. **Chạy Parity Check CLI (Kiểm tra lệch logic):**
   ```bash
   python scripts/check_parity.py --module [MODULE] --strict
   ```
   Bắt buộc xác nhận **0 mismatch**. Nếu có bất kỳ dòng nào lệch `etl_logic` hoặc thiếu dòng trong master CSV → **REJECT / BLOCK BÀN GIAO NGAY LẬP TỨC**.
3. **Chạy 3-Way Orphan Check CLI (Kiểm tra mồ côi 3 chiều):**
   ```bash
   python scripts/check_orphan.py --module [MODULE] --strict
   ```
   Bắt buộc xác nhận **0 orphan**. Nếu phát hiện bảng mồ côi, xử lý chuẩn xác theo:
   - **Nhánh A (Bảng còn giá trị / có ≥1 KPI READY):** Hoàn tất Phase 2 Entities và Phase 3 Flat Table SQL DDL/DML, **TUYỆT ĐỐI KHÔNG ĐƯỢC XÓA**.
   - **Nhánh B (Bảng đã bị hủy / 0 KPI READY):** Kích hoạt All-Tier Cleanup Protocol dọn dẹp sạch cả 3 tầng.

> 🚫 **LỆNH CẤM:** Nghiêm cấm mọi hành vi kết luận "Đã hoàn thành" (Claim Done), tạo Pull Request hoặc bàn giao sang giai đoạn tiếp theo khi chưa chạy hoặc chưa PASS 100% cả 2 script `check_parity.py --strict` và `check_orphan.py --strict`. Thiếu bước này chính là nguyên nhân trực tiếp gây sai lệch dữ liệu toàn hệ thống.
