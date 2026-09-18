---
name: datamart-review
description: |
  Master Quality Gatekeeper: Review cross-check BA analyst ↔ Datamart (HLD + LLD ↔ Flat Table).
  Hỗ trợ Macro-Review (tiến độ toàn phân hệ), Micro-Review (chi tiết 4 lớp từng nhóm),
  và Issue Trace 5 tầng (Kịch bản E). Đảm bảo chuẩn Kimball, SCD4A, 4 Control Gates và tính toàn vẹn DWH.
triggers:
  - /datamart-review [MODULE]
  - /datamart-review [MODULE] [nhóm N]
---

# Skill: Review Cross-check Datamart (Master Orchestrator)

## 1. QUY ƯỚC AN TOÀN & NGUYÊN TẮC BẤT KHẢ XÂM PHẠM

1. **Vai Trò Độc Lập:** Claude đóng vai trò Data Model Reviewer độc lập (Read-Only Explorer). Human là người quyết định và phê duyệt tối cao.
2. **CẤM TUYỆT ĐỐI Tự Sửa File Trực Tiếp:** Claude **TUYỆT ĐỐI KHÔNG** tự Edit trực tiếp vào file HLD (`.md`), LLD (`Attributes.csv`, `Detail_Mapping.csv`), Model Registry (`datamart_model.yaml`, `datamart_attributes.csv`), hay Flat Table SQL (`01_create_*.sql`, `02_populate_*.sql`). Mọi sửa đổi phải lập Action Proposal, xin phê duyệt và ủy quyền cho skill con (`datamart-hld-design`, `datamart-lld-design`) thực hiện.
3. **READ-ONLY Trên Thư Mục Atomic:** Tuyệt đối không tạo, sửa, xóa file trong `DataModel/Atomic/` và `DataModel/working/Atomic/`.
4. **Tuân Thủ Tuyệt Đối 6 CỔNG KIỂM SOÁT (6 CONTROL GATES):**
   - **GATE 0 (Reference Integrity):** chặn cứng khi có tham chiếu tới thứ không tồn tại — cột Atomic sai tên (`L0-ATOMIC-COLUMN-NOT-FOUND`), cột mart không có trong Attributes (`L0-MART-COLUMN-NOT-FOUND`), file CSV vỡ cột (`L0-CSV-STRUCTURE-BROKEN`), hoặc trạng thái KPI lệch giữa HLD và Detail Mapping (`L0-HLD-LLD-STATUS-DESYNC`). Chạy `check_references.py`.
   - **GATE 1 (Sanity Stop):** Dừng bắt buộc sau Bước 0b/0c Macro-Audit; chặn cứng nếu phát hiện Orphan 3 chiều, Parity mismatch, Role Date FK violation, Delete sót, hoặc Grain Mismatch kiến trúc (`L1-GRAIN-MISMATCH`) / Window Storage trên Dimension (`L2-WINDOW-STORAGE-INVALID`).
   - **GATE 2 (Group Checkpoint):** Dừng kiểm tra sau mỗi nhóm Micro-Review có lỗi Critical 🔴 hoặc Warning 🟡; chỉ tự động đi tiếp khi 4 Lớp đều PASS (OK).
   - **GATE 3 (HLD/LLD Parity Gate — Handover Blocking Gate):** Cổng chặn cứng kiểm định tính đồng nhất giữa HLD và LLD trước khi chuyển giao hoặc sinh mã Flat Table: bắt buộc 0 parity mismatch (`check_parity.py --strict`), 0 orphan (`check_orphan.py --strict`), 0 linter violation (Detail Mapping Rule L4, L15, L16), và 0 Date FK violation.
   - **GATE 4 (Flat Table Delivery Gate):** Cổng kiểm định chất lượng phân phối Flat Table ClickHouse với 5 tiêu chí cốt lõi: Coverage, 1-1 Projection Alignment, Column Drift, Parameter Consistency (`:etl_date`), Common Dimensions Sync (`datamart.cdr_dt_flat`).
   - **LỆNH CẤM:** Nghiêm cấm mọi hành vi tự ý vượt Gate hoặc tuyên bố hoàn thành (Claim Done) khi chưa có lệnh xác nhận từ Human và chưa PASS 100% các công cụ kiểm tra tự động.

---

## 2. MA TRẬN TÀI NGUYÊN & TRIGGER HƯỚNG DẪN (HUB & SPOKES)

| Phân Hệ / Tác Vụ Review | Tài Liệu Reference Bắt Buộc | Công Cụ CLI Tự Động Hóa |
|---|---|---|
| **Cấu trúc File BA & Dò Delimiter** | `reference/ba_source_profile.md` | `python scripts/datamart_progress_analyzer.py` |
| **Phân Loại Lỗi & Cây 5 Nhóm PENDING** | `reference/issue_classification.md` | `scripts/datamart_progress_analyzer.py` / `scripts/check_ba_mapping.py` |
| **Đối Soát Số Lượng KPI 2 Chế Độ** | `reference/kpi_reconciliation_rules.md` | `scripts/datamart_progress_analyzer.py --module [M]` |
| **Quy Chuẩn Role-Playing Date FK** | `reference/role_playing_date_fk_guide.md` | `python scripts/check_date_fk.py --module [M]` |
| **Orphan Check 3 Chiều (Nhánh A & B)** | `reference/technical_review_rules.md` (Mục 8) | `python scripts/check_orphan.py --module [M] --strict` |
| **Bảo Vệ Master Registry & Parity etl_logic** | `reference/technical_review_rules.md` (Mục 9) | `python scripts/check_parity.py --module [M] --strict` |
| **Quy Tắc Kỹ Thuật Sâu Lớp 1–4 & Gate 4 SQL** | `reference/technical_review_rules.md` | `python scripts/check_flat_table.py --module [M] --strict` |
| **Linter Detail Mapping (L4, L15, L16, L17)** | `reference/technical_review_rules.md` (Mục 8B) | `python scripts/datamart_ba_cross_checker.py --module [M]` |
| **Bộ Điều Phối Chất Lượng 6 Gate Hợp Nhất** | `reference/technical_review_rules.md` (Mục 14) | `python scripts/run_quality_gates.py --module [M] [--strict]` |
| **Reference Integrity (Gate 0)** | mục A1–A4 trong `datamart-lld-design/SKILL.md` | `python scripts/check_references.py --module [M] --strict` |
| **Cấu trúc HLD Bước 5B (Gate 5)** | Bước 5B trong `datamart-hld-design/SKILL.md` | `python scripts/check_hld_5b.py --module [M]` |
| **Checklist Đánh Giá Nhanh 4 Lớp & 4 Gates** | `reference/review_checklist.md` | — |

---

## 3. NGUYÊN TẮC CỐT LÕI & ĐỊNH TUYẾN 5 KỊCH BẢN

Chuỗi truy vết 5 tầng: **BA Analyst ➔ Nguồn Thực (Source) ➔ Atomic DWH ➔ Datamart (HLD/LLD) ➔ Flat Table / Báo Cáo**.  
Chuẩn hóa **BA Status:** `Done` / `Doing` / `Pending` / `Delete`.

### Ma Trận Định Tuyến Xử Lý 5 Kịch Bản Chuẩn Hóa (A — E):
| Kịch Bản | Dấu Hiệu Nhận Biết Cốt Lõi | Cơ Chế Phân Loại & Đơn Vị Chủ Trì | Định Tuyến Kỹ Thuật & Cổng Kiểm Soát (Skill Con) |
|:---:|---|---|---|
| **A** | Nghiệp vụ BA đổi / HLD thiếu / Chưa có nguồn Atomic | BA Pending (Nhóm 1–4) → BA / Atomic Team / DM Architect | Bàn giao BA hoặc gọi `datamart-hld-design` cập nhật HLD Section 1–5 |
| **B** | Đã có nguồn Atomic approved nhưng chưa thiết kế LLD | Datamart Pending (Nhóm 5) → DM Modeling | Trình đề xuất → Gọi `datamart-lld-design` (Phase 2 Entities + Phase 3 Flat Table) |
| **C** | Lỗi kỹ thuật LLD (Date FK, SCD4A, Naming, Flatten, Orphan 3-way, Parity Desync, Detail Mapping L4/L15/L16, Flat Table SQL) | Lỗi thiết kế mô hình / out-of-sync → DM Modeling | Trình action proposal → Dừng chờ duyệt → Gọi `datamart-lld-design`. **BẮT BUỘC:** Chạy `check_parity.py`, `check_orphan.py`, `check_flat_table.py` đạt 0 lỗi trước khi nghiệm thu! Chặn tại **Gate 3** và **Gate 4**. |
| **D** | Lỗi kiến trúc HLD (Grain Mismatch, Flowchart, 5 Section, Atomic cũ, Periodic Snapshot) | Lỗi phân tích cấp cao → DM Architect | Trình action proposal → Dừng chờ duyệt → Gọi `datamart-hld-design` tái thiết kế. Chặn tại **Gate 1** và **Gate 2**. |
| **E** | Bug report người dùng / Số liệu báo cáo sai | Issue Trace 5 tầng → Reviewer / Lead | Quy trình rẽ nhánh Bước 0-ALT (trace ngược 5 tầng, kiểm tra parity logic, orphan và flat projection) |

---

## 4. QUY TRÌNH ĐIỀU PHỐI TỔNG THỂ & GATE CONTROL (3 GIAI ĐOẠN — 4 GATES)

```
[Giai đoạn 1: MACRO-AUDIT (Toàn Module)]
  Bước 0: File Resolution động & Chạy Progress Analyzer (Phân loại Cây 5 Nhóm PENDING)
  Bước 0b: Check Cấu trúc HLD 5 Section & Đối soát Số lượng 2 Chế độ (Total Scope / Ready Scope)
  Bước 0c: [1 lần/module] Bộ 3 CLI Sanity Check:
           - Quét Date FK: python scripts/check_date_fk.py --module [M]
           - Quét Orphan 3 Chiều: python scripts/check_orphan.py --module [M] --strict
           - Quét etl_logic Parity: python scripts/check_parity.py --module [M] --strict
           - Bước 5B cấu trúc HLD 14 mục: python scripts/check_hld_5b.py --module [M]
           - Reference Integrity: python scripts/check_references.py --module [M] --strict
           + 14 mục HLD + 10 TC LLD + Quét Delete/Retired + Quét Grain Kiến trúc (L1) & Window Storage (L2)
  └── ⛔ GATE 1 (SANITY STOP): DỪNG, xuất báo cáo tổng thể, CHẶN CỨNG nếu có Orphan, Parity Mismatch, Date FK,
        Delete sót, Grain Mismatch kiến trúc (L1), hoặc Window Storage sai trên SCD4A (L2), chờ Human phê duyệt kế hoạch.
        ↓ (Human duyệt thông qua)
[Giai đoạn 2: MICRO-REVIEW (Tuần Tự Từng Nhóm)]
  Vòng lặp Nhóm 1 → N:
    Bước 1: Đọc BA nhóm N theo reference/ba_source_profile.md (dò delimiter động, đọc dòng header index 1)
    Bước 2: Review 4 Lớp Kỹ Thuật Chuẩn:
      - Lớp 1: HLD Alignment (Coverage 2 chiều, Iso-Grain Rule L1-GRAIN-MISMATCH, Bảng 7 cột, Temporal SQL)
      - Lớp 2: Attributes Verification (Atomic YAML thật, SCD4A, Flatten, Role-Playing Date FK, Parity Master Sync,
               3-Way Orphan Nhánh A/B, Time-Series Storage L2-WINDOW-STORAGE-INVALID)
      - Lớp 3: Detail Mapping Verification (Rule L4 PENDING L3-PENDING-RULE-L4-VIOLATION, Rule L15 REUSE L3-REUSE-INVALID,
               Rule L16 DEPRECATED L3-DEPRECATED-AS-PENDING, Formula Grain L3-GRAIN-MISMATCH, Window Functions 260/130/65/20
               L3-FORMULA-WINDOW-MISMATCH, Financial Horizon TTM vs 1Q & cấm SUM VCSH L3-FINANCIAL-PERIOD-INCONSISTENT)
      - Lớp 4: Model Registry (datamart_model.yaml), Master Registry (datamart_attributes.csv) & Flat Tables
    └── ⛔ GATE 2 (Group Checkpoint):
          * OK ➔ Tự động in "✅ Nhóm N — OK" và sang Nhóm N+1.
          * Info 🔵 ➔ Ghi nhận vào Backlog, tiếp tục sang Nhóm N+1.
          * Critical 🔴 / Warning 🟡 ➔ DỪNG hỏi human: (a) Sửa ngay qua skill con, (b) Ghi nhận, (c) Dừng.
        ↓ (Hoàn tất toàn bộ nhóm)
[Giai đoạn 3: TỔNG HỢP & BÀN GIAO]
  Bước 3: Xuất Bảng Tổng hợp Scorecard & Action Items theo Kịch bản A-E.
  └── ⛔ GATE 3 (HLD/LLD PARITY GATE — HANDOVER BLOCKING GATE):
        * Parity Content: 0 mismatch giữa Module CSV và master datamart_attributes.csv (check_parity.py --strict).
        * 3-Way Orphan: 0 orphan giữa LLD, Entities và Flat Table SQL (check_orphan.py --strict).
        * Detail Mapping Linter: 0 vi phạm Rule L4 (PENDING), Rule L15 (REUSE), Rule L16 (DEPRECATED).
        * Role-Playing Date FK: 0 vi phạm generic cdr_dt_dim_id trên Fact table.
        * LỆNH CẤM: Chặn tuyệt đối bàn giao sang Phase Flat Table hoặc Claim Done nếu Gate 3 chưa PASS!
        ↓ (Gate 3 PASS)
  Bước 4: Bàn giao sang skill con & Kiểm định Flat Table SQL:
  └── ⛔ GATE 4 (FLAT TABLE DELIVERY GATE):
        * Criterion 1 (Coverage): 100% cột Fact/Operational & Dim joined có mặt trong DDL (01_create_*.sql).
        * Criterion 2 (Projection): Khớp 1-1 tuyệt đối số lượng, thứ tự 3 khối & alias giữa DDL và DML.
        * Criterion 3 (Column Drift): 0 cột thừa/thiếu giữa Flat Table SQL, Master CSV & Detail Mapping.
        * Criterion 4 (Parameter): 100% mệnh đề lọc ngày ETL dùng đúng tham số chuẩn :etl_date.
        * Criterion 5 (Common Dim Sync): Bảng phẳng chiều datamart.cdr_dt_flat đủ 9 trường kể cả cờ is_trading_date.
        * LỆNH CẤM: Chặn cứng bàn giao ClickHouse SQL nếu chưa PASS 100% cả 5 tiêu chí trên (check_flat_table.py --strict)!
```

---

## 5. GIAI ĐOẠN 1: BƯỚC 0, 0b & 0c — MACRO-AUDIT TIẾN ĐỘ & SANITY CHECK

### Bước 0: File Resolution Động & Phân Tích Tiến Độ
1. Nhận diện module, resolve file: hỗ trợ cả file thường và file gộp (như `BA_analyst_GSĐC.csv`).
2. Chạy script phân tích tiến độ tự động:
   ```bash
   python scripts/datamart_progress_analyzer.py --module [MODULE]
   ```
   Xuất Ma trận Tiến độ Chéo (Cross-status Matrix) và phân loại 100% chỉ tiêu PENDING theo **Cây 5 Nhóm Nguyên Nhân Chuẩn Hóa** (xem `reference/issue_classification.md`):
   - Nhóm 1: BA chưa mapping xong.
   - Nhóm 2: Chưa có mapping nguồn từ BA.
   - Nhóm 3: Thiếu nguồn dữ liệu / Atomic entity ngoài scope.
   - Nhóm 4: Cần join phức tạp đa nguồn.
   - Nhóm 5: Datamart chưa thiết kế Fact/Dim.

### Bước 0b: Kiểm Tra Cấu Trúc HLD & Đối Soát Số Lượng 2 Chế Độ
1. **Kiểm tra 5 Section HLD:** Bắt buộc có đủ: Section 1 Lineage, Section 2 Tổng quan, Section 3 Mô hình 3 tầng, Section 4 Reuse Analysis, Section 5 Vấn đề mở.
   - Thiếu hẳn Section 4 Reuse Analysis: Đánh giá **🔴 Critical cấp toàn module**.
   - Có Section 4 nhưng thiếu một vài dòng bảng Fact/Dim: Đánh giá **🟡 Warning**.
2. **Đối soát số lượng KPI 2 Chế độ:** Áp dụng `reference/kpi_reconciliation_rules.md`:
   - *Chế độ 1 (Total Scope):* `Total_BA` (loại trừ Delete) bắt buộc khớp 1-1 với `Total_HLD` (mọi KPI_ID, kể cả PENDING, loại trừ `_YOY`).
   - *Chế độ 2 (Ready Scope):* `Ready_BA` (Done/Doing) bắt buộc khớp với `Ready_HLD` (READY) và `Ready_DM`.
   - *Reconciled Delta:* Cho phép lệch hợp lệ nếu do chỉ tiêu phái sinh nội tại (`_YOY`), chia tách loại hình doanh nghiệp (GSĐC), hoặc tách measure vật lý đã có ghi chú schema trong HLD / Whitelist.

### Bước 0c: Kiểm Định Toàn Diện Cấp Toàn Module (Chạy 1 Lần Duy Nhất)
1. **Quét Role-Playing Date FK:**
   ```bash
   python scripts/check_date_fk.py --module [MODULE]
   ```
   Phát hiện ngay lập tức vi phạm `cdr_dt_dim_id` trên Fact hoặc Fact Snapshot thiếu `snpst_dt_dim_id`.
2. **Quét Orphan Check 3 Chiều Toàn Module (LLD ↔ Entities ↔ Flat Table):**
   ```bash
   python scripts/check_orphan.py --module [MODULE] --strict
   ```
   Đối soát ma trận 3 chiều: LLD Attributes CSV (`Datamart/lld/{MODULE}/*.csv`) ↔ HLD Entities (`Datamart/hld/DTM_{MODULE}_Entities.csv` & `.md`) ↔ Flat Table SQL DDL (`Datamart/flat-table/{MODULE}/01_create_*.sql`).
   Phân loại chính xác 2 nhánh xử lý:
   - **Nhánh A (Incomplete Implementation):** Bảng còn giá trị / có ≥1 KPI READY trong HLD/Detail Mapping nhưng thiếu trong Entities hoặc Flat Table SQL → Gán mã lỗi `🔴 Critical: [L2-ORPHAN-3WAY-INCOMPLETE]`. Bắt buộc hoàn tất Phase 2 Entities và Phase 3 Flat Table, **TUYỆT ĐỐI KHÔNG ĐƯỢC XÓA**.
   - **Nhánh B (Abandoned Entity Residue):** Bảng thực sự bị hủy / 0 KPI READY nhưng còn sót lại trong LLD CSV, Entities.csv hoặc Flat Table SQL → Gán mã lỗi `🟡 Warning / 🔴 Critical: [L2-ORPHAN-3WAY-ABANDONED]`. Kích hoạt All-Tier Cleanup Protocol 5 bước để dọn dẹp sạch sẽ cả 5 tầng.
3. **Kiểm Tra etl_logic Content Parity & Bảo Vệ Master Registry:**
   ```bash
   python scripts/check_parity.py --module [MODULE] --strict
   ```
   So khớp từng dòng `(datamart_table, datamart_column)` và `(datamart_entity, datamart_attribute)` giữa file module attributes `Datamart/lld/{MODULE}/*.csv` và master registry `Datamart/lld/datamart_attributes.csv`. Bất kỳ sự sai lệch chuỗi `etl_logic` (sau khi strip whitespace) hoặc thiếu/thừa dòng thuộc tính → Gán mã lỗi **🔴 Critical (`[L2-ETL-LOGIC-PARITY-MISMATCH]` / `[L4-MASTER-REGISTRY-OUT-OF-SYNC]`)**.
4. **Sanity 13 Mục Bước 5B HLD & 10 TC Phase 1 LLD:** Thực thi kiểm tra cấu trúc erDiagram, node flowchart Staging, và 10 tiêu chuẩn bảng Attributes master.
5. **Quét Chỉ tiêu bị XÓA (`Delete` / `DELETED` / `Xóa`):** Đối chiếu danh sách chỉ tiêu bị xóa từ BA với HLD và LLD.
   - Nếu phát hiện chỉ tiêu bị XÓA còn tồn tại trong Datamart → Gán lỗi vi phạm cấm kỵ **🔴 CRITICAL VIOLATION (`[L1/L2-DELETE-VIOLATION]`)**.
   - Áp dụng quy trình loại bỏ `DEPRECATED / RETIRED`: gỡ khỏi mapping active, set `ds_rcrd_st = 'INACTIVE'`.
6. **Kiểm Soát Kiến Trúc Hạt & Nền Tảng Lưu Trữ:**
   - Quét phát hiện lệch cấp độ hạt kiến trúc (`L1-GRAIN-MISMATCH`).
   - Quét phát hiện thiết kế Window Function trên Dimension SCD4A current-state (`L2-WINDOW-STORAGE-INVALID`).

> ⛔ **GATE 1 (SANITY STOP — CHẶN CỨNG BẮT BUỘC):**  
> Claude bắt buộc DỪNG LẠI, xuất Báo cáo Tiến độ Toàn Module + Danh sách Blocker, và **CHẶN CỨNG TUYỆT ĐỐI** không cho phép chuyển sang Micro-Review nếu phát hiện:  
> 1. Có vi phạm Orphan Check 3 chiều (Nhánh A chưa hoàn tất hoặc Nhánh B chưa dọn sạch).  
> 2. Có sai lệch `etl_logic` Content Parity giữa file module và master registry `datamart_attributes.csv`.  
> 3. Có vi phạm `cdr_dt_dim_id` trên Fact table.  
> 4. Có chỉ tiêu BA = Delete còn lọt vào thiết kế Datamart.  
> 5. Có vi phạm lệch cấp độ hạt kiến trúc (`L1-GRAIN-MISMATCH`) hoặc sai nền tảng lưu trữ chuỗi thời gian trên Dimension SCD4A (`L2-WINDOW-STORAGE-INVALID`).  
> Reviewer phải chờ Human phê duyệt kế hoạch remediation hoặc xác nhận ngoại lệ Whitelist trước khi mở Gate 1.

---

## 6. BƯỚC 0-ALT: REVIEW THEO ISSUE / BUG REPORT (KỊCH BẢN E)

Khi người dùng yêu cầu điều tra một lỗi cụ thể (sai số liệu báo cáo, thiếu trường, lệch grain):
1. **Trace ngược 5 tầng:** Báo cáo ➔ Datamart Flat SQL ➔ Detail Mapping ➔ Attributes (Module CSV & Master Registry) ➔ Atomic YAML ➔ BA/Source.
2. Xuất bảng trạng thái per-tầng (`✅ Khớp` / `⚠️ Lệch logic` / `❌ Mất dấu vết`).
3. Đọc sâu SQL tham khảo BA: Nhận diện các bẫy lọc thời gian (TTM 4 quý, rolling N phiên, `rn=1`, mức ưu tiên BCTC HN > TH > ME > RI).
4. Kiểm tra đối soát `etl_logic` parity giữa module CSV và master registry để loại trừ lỗi drift logic ngầm.
5. Kiểm tra tính toàn vẹn và khớp chiếu trên Flat Table SQL (`01_create_*.sql` vs `02_populate_*.sql`).
6. Xác định tầng gốc rễ gây lỗi (Root Cause), lập Action Plan và chờ phê duyệt.

---

## 7. GIAI ĐOẠN 2: BƯỚC 1 & 2 — MICRO-REVIEW CHI TIẾT TỪNG NHÓM (4 LỚP CHUẨN)

### Bước 1: Đọc BA Nhóm N
- **TUYỆT ĐỐI KHÔNG gán cứng delimiter=';' hay delimiter=','** khi đọc file BA. Bắt buộc dùng hàm dò delimiter động `detect_delimiter_and_header()`.
- Header nằm ở **dòng 1 với TOÀN BỘ 11 file hiện hành** (0-indexed: index 1). Dòng 0 là tiêu đề merge Excel.
- Đọc file BA theo quy chuẩn `reference/ba_source_profile.md`. Lọc bỏ các chỉ tiêu Delete.

### Bước 2: Kiểm Định Chi Tiết 4 Lớp Kỹ Thuật Chuẩn

#### 🔹 Lớp 1: HLD Alignment (Khớp Thiết Kế Khái Niệm)
- **Tiêu chí:** Coverage 2 chiều BA ↔ HLD; Đúng Grain phân tích & Architectural Grain Alignment (`L1-GRAIN-MISMATCH`, tuân thủ nghiêm ngặt Iso-Grain Rule, đối chiếu mockup dòng kết quả đại diện cho đối tượng gì, tuyệt đối không copy công thức tổng hợp giữa các bảng khác grain như Index vs Symbol); Bảng KPI chuẩn 7 cột; Phân định rõ Financial Flow (TTM) vs Stock (Latest Quarter); Nhất quán giữa KPI phái sinh và cơ sở phụ thuộc; Tuyệt đối không chứa chỉ tiêu BA = Delete.
- *Tra cứu chi tiết:* `reference/review_checklist.md` (Mục Lớp 1) và `reference/technical_review_rules.md` (Mục 10).

#### 🔹 Lớp 2: Attributes Verification (Atomic ➔ Datamart)
- 📌 **Deterministic Trigger:** Trước khi đánh giá Lớp 2, BẮT BUỘC dùng tool `view_file` đọc `reference/technical_review_rules.md` (đặc biệt Mục 3, 8 & 9) và `reference/role_playing_date_fk_guide.md`.
- ⚓ **Anchor Summaries (Quy tắc sống còn):**
  1. *Flatten hoàn toàn:* `etl_logic` tham chiếu trực tiếp Atomic, **cấm dùng cột mart** (`fct_*.col`). Thiếu `join_atomic` là 🔴 Critical.
  2. *Verify Atomic YAML thật:* Tra cứu 2 nguồn approved (Ưu tiên 1 `DataModel/Atomic/`, Ưu tiên 2 `DataModel/working/Atomic/lld/`). **CẤM TUYỆT ĐỐI `Atomic_LinhLV/`**. Đếm attribute thật trong YAML.
  3. *Quy chuẩn SCD4A (`L2-SCD4A-TECH-FIELD` & `L2-SCD4A-JOIN-FILTER`):* Bảng Dimension và Operational phải đủ 5 trường kỹ thuật (`ds_rcrd_st`, `ds_eff_start_dt`, `ds_eff_end_dt`, `ds_cdc_opr_cd`, `ds_load_ts`). Mệnh đề JOIN Atomic bắt buộc có `AND <atomic_table>.ds_rcrd_st = 'ACTIVE'`.
  4. *Role-Playing Date FK (`L2-DATE-FK-ROLE-PLAYING`):* Fact Periodic Snapshot bắt buộc `snpst_dt_dim_id`; Fact Event bắt buộc `<role>_dt_dim_id`. Cấm tuyệt đối generic `cdr_dt_dim_id` trên Fact. Cú pháp ETL Attributes tra cứu theo ngày tự nhiên: `LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt = <driving_table>.ds_snpst_dt`.
  5. *Physical Naming:* Tra cứu `system/rules/rule_physical_name_exceptions_datamart.csv`. Chỉ viết tắt từ trong exceptions, cấm mở rộng hoặc đổi từ đồng nghĩa.
  6. *Kiểm tra etl_logic Content Parity (`L2-ETL-LOGIC-PARITY-MISMATCH`):* Mọi dòng thuộc tính trong nhóm phải khớp 100% byte-for-byte với dòng tương ứng trong master registry `Datamart/lld/datamart_attributes.csv`. Lệch chuỗi logic là 🔴 Critical.
  7. *Orphan Check 3 Chiều theo Entity (`L2-ORPHAN-3WAY-*`):* Bảng Fact/Dim chứa thuộc tính nhóm đang review phải tồn tại đồng bộ ở cả 3 tầng. Nếu thiếu tầng, lập tức xác định Nhánh A (Hoàn tất, cấm xóa) vs Nhánh B (Dọn dẹp All-Tier).
  8. *Kiểm định Lưu trữ Chuỗi Thời Gian (`L2-WINDOW-STORAGE-INVALID`):* Mọi trường dữ liệu đo lường phục vụ Window Function lịch sử (giá đóng cửa `close_price`, khối lượng...) bắt buộc phải được lưu trữ trên Fact Periodic Snapshot (`fct_*_snpst`) theo từng ngày giao dịch. CẤM TUYỆT ĐỐI trỏ Window Function vào Dimension SCD4A current-state (như `security_trading_snpst_dim` chỉ có 1 bản ghi hiện tại).

#### 🔹 Lớp 3: Detail Mapping Verification (Datamart ➔ Báo Cáo)
- 📌 **Deterministic Trigger:** Trước khi đánh giá Lớp 3, BẮT BUỘC dùng tool `view_file` đọc `reference/technical_review_rules.md` (đặc biệt Mục 8B, 10, 11, 12).
- ⚓ **Anchor Summaries (Quy tắc sống còn):**
  1. *Trace logic BA:* Đọc full câu lệnh SQL, điều kiện chung và ghi chú của BA để chuyển hóa trọn vẹn vào `logic`.
  2. *Quy tắc L4 đối với dòng PENDING (`L3-PENDING-RULE-L4-VIOLATION`):* Mọi dòng PENDING (cả nhóm PENDING lẫn KPI PENDING đơn lẻ) bắt buộc để trống tuyệt đối cả 4 cột: `mart_table`, `mart_column`, `column_role`, `logic`. Blocker ghi tại `ghi_chu` theo cú pháp `Pending - [Nhóm 1-5]: ...`.
  3. *Quy tắc L15 đối với dòng REUSE (`L3-REUSE-INVALID`):* Phân biệt dứt khoát: Case 1 (Measure vật lý có sẵn) $\implies$ điền đủ `mart_table` và `mart_column`; Case 2 (Chỉ tiêu BI phái sinh) $\implies$ để trống `mart_table`/`mart_column`, `column_role = 'DERIVED'`.
  4. *Quy tắc L16 phân định DEPRECATED vs PENDING (`L3-DEPRECATED-AS-PENDING`):* Chỉ tiêu đã thống nhất bãi bỏ với BA bắt buộc đặt `column_role = 'DEPRECATED'`, để trống 2 cột mart, `logic = 'Đã loại bỏ — không tạo cột/slicer'`, ghi rõ căn cứ tại `ghi_chu`. Cấm đánh tráo thành PENDING.
  5. *Quy tắc L17 Bám sát Câu lệnh tham khảo & Điều kiện chung BA (`L3-REFERENCE-SQL-MISALIGNMENT`):* Bắt buộc bóc tách 4 thành phần SQL tham khảo của BA: (a) SELECT: khớp đúng số đo (khớp lệnh thuần `total_matched_vol/val` vs thỏa thuận `total_negotiated_vol/val` vs gộp tổng `total_vol/val`; mua vs bán vs ròng `foreign_net_vol`); (b) WHERE: toàn bộ điều kiện lọc tĩnh (sàn `FloorCode`, loại CK `StockType`, loại bảng lệnh `Board Type`, cờ hiệu lực, loại NĐT) phải sinh thành dòng `column_role = FILTER` tương ứng HOẶC ghi rõ trong `ghi_chu` là đã lọc sẵn tại ETL Fact; (c) FROM/JOIN: đủ Dimension và FK liên kết; (d) GROUP BY/Window: đúng grain hiển thị và công thức cửa sổ rolling.
  6. *Inline DERIVED:* Cột phái sinh bắt buộc inline toàn bộ công thức tính toán từ Atomic/Mart, **cấm tham chiếu mã KPI_ID khác** (như `K_01 + K_02`).
  7. *Trace cột LLD:* Cột `mart_table` và `mart_column` phải tồn tại thực tế và khớp 1-1 với Attributes.
  8. *Cú pháp JOIN Date FK:* Truy vấn Detail Mapping kết nối sang Dimension ngày theo khóa surrogate key: `LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt_dim_id = <fact>.<role>_dt_dim_id`.
  9. *Formula Grain & Group By Verification (`L3-GRAIN-MISMATCH`):* Đọc mockup "1 dòng kết quả = 1 đối tượng gì"; đối chiếu danh sách cột trong mệnh đề `GROUP BY` / `PARTITION BY` trong `logic` bắt buộc khớp đúng khóa định danh đối tượng đó. Cấm tuyệt đối copy công thức từ nhóm khác lệch grain (điển hình case `K_GSTT_61` copy vốn hóa Index `idx_market_cap` sang Top-N mã CK).
  10. *Chuẩn hóa Window Functions & Time Horizon (`L3-FORMULA-WINDOW-MISMATCH`):* Đếm số phiên giao dịch chuẩn (52W = 260 phiên `ROWS BETWEEN 259 PRECEDING AND CURRENT ROW`, 6M = 130 phiên, 3M = 65 phiên, 1M = 20 phiên); CẤM dùng `INTERVAL` ngày lịch; Phân định chuẩn `close_price` (báo cáo định giá/BM021_MSS) vs `high_price`/`low_price` (intraday nến kỹ thuật); Bắt buộc đủ `PARTITION BY <entity_id>` và `ORDER BY <date_col> ASC` (tránh lẫn chuỗi giá nhiều mã).
  11. *Nhất quán Chu kỳ Tỷ số Tài chính (`L3-FINANCIAL-PERIOD-INCONSISTENT`):* Tử số và mẫu số cùng một hệ quy chiếu thời gian (TTM 4 quý vs 1 quý quy năm cho P/E, P/B, EPS, BVPS, ROE, ROA); CẤM TUYỆT ĐỐI `SUM(owner_equity)` hoặc `SUM(total_assets)` qua 4 quý trong mẫu số; bắt buộc trả về `NULL` khi thiếu bất kỳ quý BCTC nào của chuỗi TTM.

#### 🔹 Lớp 4: Model Registry (datamart_model.yaml), Master Registry & Flat Tables
- ⚓ **Anchor Summaries (Quy tắc sống còn):**
  1. *Khớp 1-1 Song Song:* Đồng bộ 100% tên bảng, cột và kiểu dữ liệu với file module Attributes VÀ master registry `datamart_attributes.csv`.
  2. *Domain Chuẩn:* Phân biệt Boolean direct (`boolean`) vs Indicator computed (`string` Y/N).
  3. *Bảo vệ SHARED Dimension trong Registry:* Với Entity riêng (`module: "{MODULE}"`), đồng bộ theo Attributes. Với Entity `module: "SHARED"`, **Model Registry là nguồn sự thật** — bắt buộc sửa Attributes theo Registry, nghiêm cấm ghi đè Registry.
  4. *Bảo vệ Master Registry CSV (`datamart_attributes.csv`):* File master registry là nguồn sự thật tối cao cho toàn bộ thuộc tính Datamart. Nghiêm cấm chỉ sửa file module Attributes mà quên cập nhật master registry (`L4-MASTER-REGISTRY-OUT-OF-SYNC`).
  5. *Trường kỹ thuật SCD4A trong Registry:* Đảm bảo các trường kỹ thuật SCD4A (`ds_rcrd_st`, `ds_eff_start_dt`, `ds_eff_end_dt`, `ds_cdc_opr_cd`, `ds_load_ts`) được định nghĩa đúng kiểu dữ liệu trong Registry.
  6. *Khóa Quyền Sửa File:* Reviewer TUYỆT ĐỐI KHÔNG tự sửa file registry. Lập Action Proposal (Kịch bản C), dừng chờ duyệt và ủy quyền cho `datamart-lld-design` cập nhật registry. Sau khi datamart-lld-design hoàn tất cập nhật registry — Reviewer chạy script verify YAML parse và parity check.
  7. *Đồng bộ Flat Table SQL (DDL & DML):* Kiểm soát 5 tiêu chí Gate 4 bắt buộc trước khi bàn giao: 100% Column Coverage, 1-1 Projection Alignment, Column Drift Control, Parameter Consistency (`:etl_date`), và Common Dimensions ClickHouse Sync (`datamart.cdr_dt_flat`).

> ⛔ **GATE 2 (GROUP CHECKPOINT):**  
> - 4 Lớp = OK ➔ In "✅ Nhóm N — OK", tự động chuyển sang Nhóm N+1.  
> - Lỗi Info 🔵 ➔ Ghi vào Backlog tạm, không dừng, tiếp tục Nhóm N+1.  
> - Lỗi Critical 🔴 / Warning 🟡 ➔ DỪNG hỏi human: (a) Sửa ngay qua skill con, (b) Ghi nhận vào Backlog và đi tiếp, (c) Dừng review. (Bao gồm các vi phạm Critical: `L1/L3-GRAIN-MISMATCH`, `L2-WINDOW-STORAGE-INVALID`, `L3-FORMULA-WINDOW-MISMATCH`, `L3-FINANCIAL-PERIOD-INCONSISTENT`, `L3-PENDING-RULE-L4-VIOLATION`, `L3-REUSE-INVALID`, `L3-DEPRECATED-AS-PENDING`, `L3-REFERENCE-SQL-MISALIGNMENT`).

---

## 8. GIAI ĐOẠN 3: BƯỚC 3 & 4 — TỔNG HỢP VẤN ĐỀ, CỔNG CHẶN BÀN GIAO & GATE 4

### Bước 3: Tổng Hợp Báo Cáo Scorecard & Danh Mục Vấn Đề
1. Xuất Bảng Chi tiết Vấn đề (Mã lỗi, Nhóm, Lớp, Mức độ Critical/Warning/Info, Mô tả, Kịch bản A-E, Action đề xuất).
2. Xuất Bảng Action Items theo nhóm ưu tiên (P0 Blocker ➔ P1 High ➔ P2 Medium ➔ P3 Low).

### Quy Tắc Bắt Buộc Khi Chuyển Trạng Thái: PENDING ➔ READY
Khi một chỉ tiêu được giải quyết nguồn hoặc thiết kế xong HLD:
> 🔴 **BẮT BUỘC:** Chạy review lại **cả 3 lớp LLD** (Lớp 2: Attributes, Lớp 3: Detail Mapping, Lớp 4: Model & Master Registry) ngay lập tức. Tuyệt đối không được chuyển READY chỉ dựa trên HLD mà bỏ qua kiểm tra LLD thực tế.

---

### ⛔ GATE 3 — CỔNG KIỂM ĐỊNH TÍNH ĐỒNG NHẤT HLD/LLD (HLD/LLD PARITY GATE)
*(Handover Blocking Gate — Chuẩn hóa từ bài học thực tế hệ thống GSTT: sửa file module attributes mà quên đồng bộ master registry `datamart_attributes.csv`, và sót Fact đã READY khỏi Entities.csv/Flat Table)*

**QUY ĐỊNH BẮT BUỘC TRƯỚC KHI BÀN GIAO HOẶC CHUYỂN SANG FLAT TABLE (CLAIM DONE):**  
Bất kể Kịch bản C được thực hiện qua lời gọi `datamart-lld-design` hay qua Action Proposal được Human phê duyệt thực thi trực tiếp, NGAY SAU khi hoàn tất thiết kế LLD, Reviewer/Developer BẮT BUỘC thực hiện kiểm định 4 chặng Gate 3:

1. **Đồng bộ Master Registry & Parity Check:**
   ```bash
   python scripts/check_parity.py --module [MODULE] --strict
   ```
   Bắt buộc xác nhận **0 mismatch, 0 missing attribute**. Nếu có bất kỳ dòng nào lệch `etl_logic` hoặc thiếu dòng trong master CSV → **REJECT / BLOCK BÀN GIAO NGAY LẬP TỨC**.
2. **3-Way Orphan Check CLI (Kiểm tra mồ côi 3 chiều):**
   ```bash
   python scripts/check_orphan.py --module [MODULE] --strict
   ```
   Bắt buộc xác nhận **0 orphan**. Nếu phát hiện bảng mồ côi, xử lý chuẩn xác theo:
   - **Nhánh A (Bảng còn giá trị / có ≥1 KPI READY):** Hoàn tất Phase 2 Entities và Phase 3 Flat Table SQL DDL/DML, **TUYỆT ĐỐI KHÔNG ĐƯỢC XÓA**.
   - **Nhánh B (Bảng đã bị hủy / 0 KPI READY):** Kích hoạt All-Tier Cleanup Protocol 5 bước dọn dẹp sạch cả 5 tầng.
3. **Detail Mapping Linter Check:**
   Xác nhận 0 vi phạm Quy tắc L4 (PENDING để trống 4 cột kỹ thuật), Quy tắc L15 (REUSE Case 1 vs Case 2), Quy tắc L16 (DEPRECATED phân định rõ ràng), và Quy tắc L17 (Reference SQL alignment — không lệch số đo, không thiếu FILTER). Chạy CLI:
   ```bash
   python scripts/datamart_ba_cross_checker.py --module [MODULE]
   ```
4. **Role-Playing Date FK Verification:**
   ```bash
   python scripts/check_date_fk.py --module [MODULE]
   ```
   Xác nhận 0 bảng Fact chứa generic `cdr_dt_dim_id`, 100% Fact Snapshot có `snpst_dt_dim_id`.

> 🚫 **LỆNH CẤM:** Nghiêm cấm mọi hành vi kết luận "Đã hoàn thành" (Claim Done), tạo Pull Request hoặc bàn giao sang Phase 3 Flat Table khi chưa chạy hoặc chưa PASS 100% Gate 3.

---

### Bước 4: Bàn Giao Sang Skill Con & Kiểm Định Flat Table (Gate 4)
- Claude tổng hợp lệnh gọi chuẩn xác:
  - Vấn đề Kịch bản A / D ➔ Chuyển giao `datamart-hld-design`.
  - Vấn đề Kịch bản B / C ➔ Chuyển giao `datamart-lld-design`.
- Thực hiện kiểm định nghiệm thu Flat Table ClickHouse qua **GATE 4**.

---

### ⛔ GATE 4 — CỔNG KIỂM ĐỊNH PHÂN PHỐI FLAT TABLE (FLAT TABLE DELIVERY GATE)
Trước khi ký duyệt nghiệm thu và bàn giao bộ script Flat Table (`01_create_*_flat_tables.sql` và `02_populate_*_flat_tables.sql`), Reviewer BẮT BUỘC thực hiện kiểm định toàn diện 5 tiêu chí cốt lõi bằng công cụ tự động:

```bash
python scripts/check_flat_table.py --module [MODULE] --strict
```

Hoặc chạy runner hợp nhất:
```bash
python scripts/run_quality_gates.py --module [MODULE] --strict
```

#### 5 Tiêu Chí Nghiệm Thu Gate 4:
1. **Flat Table Column Coverage Check (`L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING`):** 100% cột Fact/Operational và thuộc tính nghiệp vụ của Dim joined có mặt trong DDL `01_create_*.sql`.
2. **1-1 Projection Alignment Check (`L4-FLAT-TABLE-PROJECTION-MISALIGNMENT`):** Khớp 1-1 chính xác tuyệt đối số lượng, thứ tự 3 khối cột (Fact ➔ Date ➔ Dim) và alias giữa `CREATE TABLE` trong file `01` và `SELECT` trong file `02`.
3. **Column Drift Check (`L4-FLAT-TABLE-COLUMN-DRIFT`):** 0 cột thừa trong Flat Table SQL; không bỏ sót cột Fact có KPI khai thác trong Detail Mapping; 100% cột Fact có trong master `datamart_attributes.csv`.
4. **Parameter Consistency Check (`L4-FLAT-TABLE-PARAMETER-INCONSISTENT`):** 100% mệnh đề lọc ngày chạy ETL trong `02_populate_*.sql` dùng biến tham số chuẩn duy nhất `:etl_date`.
5. **Common Dimensions ClickHouse Sync Check (`L4-COMMON-DIM-CLICKHOUSE-MISSING`):** Kiểm tra sự hiện diện và tính đầy đủ của bảng phẳng chiều dùng chung `datamart.cdr_dt_flat` (nguồn `datamart.cdr_dt_dim`) tại `Datamart/flat-table/Common/` với đầy đủ 9 trường thuộc tính kể cả cờ `is_trading_date` phục vụ lọc ngày giao dịch và đếm phiên lookback trên ClickHouse.

> 🚫 **LỆNH CẤM:** Nghiêm cấm mọi hành vi bỏ qua Gate 4 hoặc phê duyệt bàn giao khi Flat Table SQL chưa được đồng bộ đạt 100% cả 5 tiêu chí trên!
