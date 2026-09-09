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
2. **CẤM TUYỆT ĐỐI Tự Sửa File Trực Tiếp:** Claude **TUYỆT ĐỐI KHÔNG** tự Edit trực tiếp vào file HLD (`.md`), LLD (`Attributes.csv`, `Detail_Mapping.csv`) hay Model Registry (`datamart_model.yaml`). Mọi sửa đổi phải lập Action Proposal, xin phê duyệt và ủy quyền cho skill con (`datamart-hld-design`, `datamart-lld-design`) thực hiện.
3. **READ-ONLY Trên Thư Mục Atomic:** Tuyệt đối không tạo, sửa, xóa file trong `DataModel/Atomic/`.
4. **Tuân Thủ Tuyệt Đối GATE RULES:** Bắt buộc dừng tại **GATE 1** (sau Bước 0b/0c) và **GATE 2** (sau mỗi nhóm có lỗi Critical/Warning). Không tự ý vượt Gate khi chưa có lệnh của Human.

---

## 2. MA TRẬN TÀI NGUYÊN & TRIGGER HƯỚNG DẪN (HUB & SPOKES)

| Phân Hệ / Tác Vụ Review | Tài Liệu Reference Bắt Buộc | Công Cụ CLI Tự Động Hóa |
|---|---|---|
| **Cấu trúc File BA & Dò Delimiter** | `reference/ba_source_profile.md` | `python scripts/datamart_progress_analyzer.py` |
| **Phân Loại Lỗi & Cây 6 Nhánh PENDING** | `reference/issue_classification.md` | `scripts/datamart_progress_analyzer.py` |
| **Đối Soát Số Lượng KPI 2 Chế Độ** | `reference/kpi_reconciliation_rules.md` | `scripts/datamart_progress_analyzer.py --module [M]` |
| **Quy Chuẩn Role-Playing Date FK** | `reference/role_playing_date_fk_guide.md` | `python scripts/datamart_date_fk_checker.py --module [M]` |
| **Quy Tắc Kỹ Thuật Sâu Lớp 2 & Lớp 4** | `reference/technical_review_rules.md` | — |
| **Checklist Đánh Giá Nhanh 4 Lớp** | `reference/review_checklist.md` | — |

---

## 3. NGUYÊN TẮC CỐT LÕI & ĐỊNH TUYẾN 5 KỊCH BẢN

Chuỗi truy vết 5 tầng: **BA Analyst ➔ Nguồn Thực (Source) ➔ Atomic DWH ➔ Datamart (HLD/LLD) ➔ Báo Cáo**.
Chuẩn hóa **BA Status:** `Done` / `Doing` / `Pending` / `Delete`.

### Ma Trận Định Tuyến Xử Lý 5 Kịch Bản (A — E):
| Kịch Bản | Dấu Hiệu Nhận Biết Cốt Lõi | Cơ Chế Phân Loại & Đơn Vị Chủ Trì | Định Tuyến Kỹ Thuật (Skill Con) |
|:---:|---|---|---|
| **A** | Nghiệp vụ BA đổi / Chưa có nguồn Atomic | BA Pending (Nhánh 1-4) → BA / Atomic Team | Bàn giao BA hoặc cập nhật `datamart-hld-design` |
| **B** | Đã có nguồn Atomic nhưng chưa thiết kế LLD | Datamart Pending (Nhánh 5) → DM Modeling | Trình đề xuất → Gọi `datamart-lld-design` (Phase 2/3) |
| **C** | Lỗi kỹ thuật LLD (Date FK, SCD4A, Naming, Flatten) | Lỗi thiết kế mô hình → DM Modeling | Trình action → Dừng chờ duyệt → Gọi `datamart-lld-design` |
| **D** | Lỗi kiến trúc HLD (Grain, Flowchart, 5 Section) | Lỗi phân tích cấp cao → DM Architect | Trình action → Dừng chờ duyệt → Gọi `datamart-hld-design` |
| **E** | Bug report người dùng / Số liệu báo cáo sai | Issue Trace 5 tầng → Reviewer / Lead | Quy trình rẽ nhánh Bước 0-ALT (trace ngược 5 tầng) |

---

## 4. QUY TRÌNH ĐIỀU PHỐI TỔNG THỂ & GATE CONTROL

```
[Chế độ 1: MACRO-AUDIT (Toàn Module)]
  Bước 0: File Resolution động & Chạy Progress Analyzer
  Bước 0b: Check Cấu trúc HLD 5 Section & Đối soát Số lượng 2 Chế độ
  Bước 0c: [1 lần/module] Date FK Checker CLI + 13 mục HLD + 10 TC LLD + Quét Delete
  └── ⛔ GATE 1: DỪNG, xuất báo cáo tổng thể, chờ Human phê duyệt kế hoạch.
        ↓ (Human duyệt)
[Chế độ 2: MICRO-REVIEW (Tuần Tự Từng Nhóm)]
  Vòng lặp Nhóm 1 → N:
    Bước 1: Đọc BA nhóm N theo reference/ba_source_profile.md
    Bước 2: Review 4 Lớp Kỹ Thuật Chuẩn:
      - Lớp 1: HLD Alignment (Coverage, Grain, Bảng 7 cột, Temporal SQL)
      - Lớp 2: Attributes Verification (Atomic YAML, SCD4A, Flatten, Role-Playing Date FK)
      - Lớp 3: Detail Mapping Verification (Inline DERIVED, Trace logic, Date FK JOIN)
      - Lớp 4: Model Registry Synchronization (Sync 1-1, Bảo vệ SHARED Dimension)
    └── ⛔ GATE 2 (Group Checkpoint):
          * OK ➔ Tự động in "✅ Nhóm N — OK" và sang Nhóm N+1.
          * Info 🔵 ➔ Ghi nhận vào Backlog, tiếp tục sang Nhóm N+1.
          * Critical 🔴 / Warning 🟡 ➔ DỪNG hỏi human: (a) Sửa ngay, (b) Ghi nhận, (c) Dừng.
        ↓ (Hoàn tất toàn bộ nhóm)
[Giai đoạn 3: TỔNG HỢP & BÀN GIAO]
  Bước 3: Xuất Bảng Tổng hợp Scorecard & Action Items theo Kịch bản A-D.
  Bước 4: Bàn giao sang skill con (Claude tuyệt đối không tự sửa file).
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
   python scripts/datamart_date_fk_checker.py --module [MODULE]
   ```
   Phát hiện ngay lập tức vi phạm `cdr_dt_dim_id` trên Fact hoặc Fact Snapshot thiếu `snpst_dt_dim_id`.
2. **Sanity 13 Mục Bước 5B HLD & 10 TC Phase 1 LLD:** Thực thi kiểm tra cấu trúc erDiagram, node flowchart Staging, và 10 tiêu chuẩn bảng Attributes master.
3. **Quét Chỉ tiêu bị XÓA (`Delete` / `DELETED` / `Xóa`):** Đối chiếu danh sách chỉ tiêu bị xóa từ BA với HLD và LLD.
   - Nếu phát hiện chỉ tiêu bị XÓA còn tồn tại trong Datamart → Gán lỗi vi phạm cấm kỵ **🔴 CRITICAL VIOLATION (`[L1/L2-DELETE-VIOLATION]`)**.
   - Áp dụng quy trình loại bỏ `DEPRECATED / RETIRED`: gỡ khỏi mapping active, set `ds_rcrd_st = 'INACTIVE'`.

> ⛔ **GATE 1 (DỪNG CHỜ DUYỆT):** Claude dừng lại, xuất Báo cáo Tiến độ Toàn Module + Danh sách Blocker, chờ Human phê duyệt kế hoạch trước khi bước vào Micro-Review.

---

## 6. BƯỚC 0-ALT: REVIEW THEO ISSUE / BUG REPORT (KỊCH BẢN E)

Khi người dùng yêu cầu điều tra một lỗi cụ thể (sai số liệu báo cáo, thiếu trường, lệch grain):
1. **Trace ngược 5 tầng:** Báo cáo ➔ Datamart Flat SQL ➔ Detail Mapping ➔ Attributes ➔ Atomic YAML ➔ BA/Source.
2. Xuất bảng trạng thái per-tầng (`✅ Khớp` / `⚠️ Lệch logic` / `❌ Mất dấu vết`).
3. Đọc sâu SQL tham khảo BA: Nhận diện các bẫy lọc thời gian (TTM 4 quý, rolling N phiên, `rn=1`, mức ưu tiên BCTC HN > TH > ME > RI).
4. Xác định tầng gốc rễ gây lỗi (Root Cause), lập Action Plan và chờ phê duyệt.

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
- 📌 **Deterministic Trigger:** Trước khi đánh giá Lớp 2, BẮT BUỘC dùng tool `view_file` đọc `reference/technical_review_rules.md` và `reference/role_playing_date_fk_guide.md`.
- ⚓ **Anchor Summaries (Quy tắc sống còn):**
  1. *Flatten hoàn toàn:* `etl_logic` tham chiếu trực tiếp Atomic, **cấm dùng cột mart** (`fct_*.col`). Thiếu `join_atomic` là 🔴 Critical.
  2. *Verify Atomic YAML thật:* Tra cứu 2 nguồn approved (Ưu tiên 1 `DataModel/Atomic/`, Ưu tiên 2 `DataModel/working/Atomic/lld/`). **CẤM TUYỆT ĐỐI `Atomic_LinhLV/`**. Đếm attribute thật trong YAML.
  3. *Quy chuẩn SCD4A (`L2-SCD4A-TECH-FIELD` & `L2-SCD4A-JOIN-FILTER`):* Bảng Fact/Dim phải đủ 5 trường kỹ thuật (`ds_rcrd_st`, `ds_eff_start_dt`, `ds_eff_end_dt`, `ds_cdc_opr_cd`, `ds_load_ts`). Mệnh đề JOIN Atomic bắt buộc có `AND <atomic_table>.ds_rcrd_st = 'ACTIVE'`.
  4. *Role-Playing Date FK:* Fact Periodic Snapshot bắt buộc `snpst_dt_dim_id`; Fact Event bắt buộc `<role>_dt_dim_id`. Cấm tuyệt đối `cdr_dt_dim_id` trên Fact. Cú pháp ETL Attributes tra cứu theo ngày tự nhiên: `LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt = <driving_table>.ds_snpst_dt`.
  5. *Physical Naming:* Tra cứu `system/rules/rule_physical_name_exceptions_datamart.csv`. Chỉ viết tắt từ trong exceptions, cấm mở rộng hoặc đổi từ đồng nghĩa.

#### 🔹 Lớp 3: Detail Mapping Verification (Datamart ➔ Báo Cáo)
- ⚓ **Anchor Summaries (Quy tắc sống còn):**
  1. *Trace logic BA:* Đọc full câu lệnh SQL và ghi chú của BA để chuyển hóa trọn vẹn vào `logic`.
  2. *Inline DERIVED:* Cột phái sinh bắt buộc inline toàn bộ công thức tính toán từ Atomic/Mart, **cấm tham chiếu mã KPI_ID khác** (như `K_01 + K_02`).
  3. *Trace cột LLD:* Cột `mart_table` và `mart_column` phải tồn tại thực tế và khớp 1-1 với Attributes.
  4. *Cú pháp JOIN Date FK:* Truy vấn Detail Mapping kết nối sang Dimension ngày theo khóa surrogate key: `LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt_dim_id = <fact>.<role>_dt_dim_id`.

#### 🔹 Lớp 4: Model Registry Synchronization (`datamart_model.yaml`)
- ⚓ **Anchor Summaries (Quy tắc sống còn):**
  1. *Khớp 1-1:* Đồng bộ 100% tên bảng, cột và kiểu dữ liệu với Attributes.
  2. *Domain Chuẩn:* Phân biệt Boolean direct (`boolean`) vs Indicator computed (`string` Y/N).
  3. *Bảo vệ SHARED Dimension trong Registry:* Với Entity riêng (`module: "{MODULE}"`), đồng bộ theo Attributes. Với Entity `module: "SHARED"`, **Registry là nguồn sự thật** — bắt buộc sửa Attributes theo Registry, nghiêm cấm ghi đè Registry.
  4. *Trường kỹ thuật SCD4A trong Registry:* Kiểm tra định nghĩa các trường kỹ thuật SCD4A chuẩn hóa trong metadata registry.
  5. *Khóa Quyền Sửa File:* Reviewer TUYỆT ĐỐI KHÔNG tự sửa file registry. Lập Action Proposal (Kịch bản C), dừng chờ duyệt và ủy quyền cho `datamart-lld-design` cập nhật registry. Sau khi datamart-lld-design hoàn tất cập nhật registry — Reviewer chạy script verify YAML parse.

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
> 🔴 **BẮT BUỘC:** Chạy review lại **cả 3 lớp LLD** (Lớp 2: Attributes, Lớp 3: Detail Mapping, Lớp 4: Model Registry) ngay lập tức. Tuyệt đối không được chuyển READY chỉ dựa trên HLD mà bỏ qua kiểm tra LLD thực tế.

### Bước 4: Chuyển Giao Thực Hiện Qua Skill Con
- Claude tổng hợp lệnh gọi chuẩn xác:
  - Vấn đề Kịch bản A / D ➔ Chuyển giao `datamart-hld-design`.
  - Vấn đề Kịch bản B / C ➔ Chuyển giao `datamart-lld-design`.
- Dừng quy trình review và xuất Handoff Report cho ca làm việc kế tiếp.
