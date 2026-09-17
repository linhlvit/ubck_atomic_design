# MASTER EXECUTIVE SUMMARY & COMPREHENSIVE ROADMAP
## Báo Cáo Tổng Hợp Độc Lập Dự Án Review & Nâng Cấp Skill `datamart-review`
### Kho Dữ Liệu Thị Trường Chứng Khoán (UBCKNN Atomic Data Warehouse)

- **Mã tài liệu:** `CHECKPOINT-FINAL-MASTER-SUMMARY`
- **Phiên bản:** 1.0 (Chính thức)
- **Ngày phát hành:** 2026-09-09
- **Cơ quan chủ quản:** Kiến trúc Kho dữ liệu & Đảm bảo Chất lượng Thiết kế (DWH Architecture & QA Team)
- **Tập tài liệu tham chiếu:**
  1. `_review_checkpoints/checkpoint_r1_skill_review.md` (Chi tiết R1 — Rà soát SKILL.md & Quy trình)
  2. `_review_checkpoints/checkpoint_r2_structure_refactor.md` (Chi tiết R2 — Phân rã cấu trúc & Hub & Spokes)
  3. `_review_checkpoints/checkpoint_r3_scripts_audit.md` (Chi tiết R3 — Audit mã nguồn 2 Python scripts)

---

## 1. TỔNG QUAN ĐIỀU HÀNH (EXECUTIVE SUMMARY)

### 1.1. Vai trò Gatekeeper Cốt lõi của Skill `datamart-review`
Trong kiến trúc xây dựng Kho Dữ Liệu Trung Tâm (DWH) cho Ủy ban Chứng khoán Nhà nước (UBCKNN), luồng dữ liệu nghiệp vụ trải qua chuỗi chuyển hóa 5 tầng:
```
[1. BA Analyst] ──► [2. Source Hệ thống] ──► [3. Atomic DWH] ──► [4. Datamart (HLD/LLD)] ──► [5. Flat Table / Báo cáo]
   (Nghiệp vụ)       (IDS / T24 / MSS)        (Chuẩn hóa 3NF)       (Star Schema Kimball)          (Trực quan hóa BI)
```
Skill `datamart-review` đóng vai trò là **"Người gác cổng chất lượng tối cao" (Master Quality Gatekeeper)**, bảo đảm rằng:
1. Mọi chỉ tiêu phân tích nghiệp vụ của BA được chuyển hóa đầy đủ 100% sang Datamart (không sót, không thừa, không lệch grain).
2. Toàn bộ các bảng Fact/Dimension tuân thủ nghiêm ngặt phương pháp luận thiết kế Kimball (đặc biệt là chuẩn Role-Playing Date FK cho Fact và cơ chế quản lý lịch sử SCD4A).
3. Không một trường kỹ thuật sai lệch hay chỉ tiêu bãi bỏ (`Delete`) nào được phép lọt qua tầng thiết kế để vào code phát triển ETL.

### 1.2. Hiện trạng và Lý do Thực hiện Đợt Rà soát Tổng thể
Trải qua quá trình đồng hành cùng nhiều phân hệ lớn (GSĐC, GSTT, NHNCK, QLKD, PTTT, TT), bộ công cụ `datamart-review` hiện có quy mô đồ sộ:
- **`SKILL.md`:** 1013 dòng (~86KB, tiêu tốn xấp xỉ ~22.000 tokens mỗi lần nạp vào context).
- **Thư mục Reference:** 3 tài liệu quy chuẩn (`review_checklist.md`, `issue_classification.md`, `ba_source_profile.md`).
- **Thư mục Scripts:** 2 công cụ CLI chủ lực (`datamart_progress_analyzer.py` - 1328 dòng; `datamart_date_fk_checker.py` - 935 dòng).

Do được cập nhật chắp vá qua nhiều giai đoạn thay đổi chuẩn (chuyển sang bảng HLD 7 cột tháng 07/2026, chuẩn hóa Kịch bản C và file BA gộp GSĐC tháng 08/2026, nâng cấp Role-Playing Date FK tháng 09/2026), hệ thống đã bộc lộ những điểm nghẽn nghiêm trọng:
- **Quá tải context:** Tốn ~22.000 tokens ngay khi nạp skill, gây hiện tượng context truncation khi review các module lớn.
- **Mâu thuẫn nội tại:** Lệnh hardcode xung đột với chỉ dẫn tự động dò; cấm sửa file nhưng lại có dòng hướng dẫn tự sửa; công thức đếm số lượng gây báo động đỏ giả.
- **Trùng lặp & Phân mảnh:** Nhiều quy tắc kỹ thuật bị sao chép ở 4–7 nơi; các bước kiểm tra toàn module bị nhét vào vòng lặp từng nhóm.
- **Bugs trong scripts:** Thuật toán dò delimiter bị gãy khi gặp SQL; regex vỡ cột bảng HLD; gán nhầm nguyên nhân PENDING.

Đợt audit toàn diện và đề xuất tái cấu trúc này được thực hiện nhằm dọn sạch triệt để nợ kỹ thuật, chuẩn hóa tài liệu theo kiến trúc **Hub & Spokes**, vá sạch 11 bugs trong code CLI, và nâng cao năng lực tự động hóa kiểm định DWH.

---

## 2. TỔNG HỢP FINDINGS CHÍNH QUA 3 TRỤ CỘT (R1, R2, R3)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                 BẢNG TỔNG HỢP PHÁT HIỆN QUA 3 TRỤ CỘT                                   │
├──────────────────────────┬────────────────────────────────────────────────────────┬─────────────────────┤
│ Trụ cột Khảo sát         │ Số lượng & Bản chất Phát hiện                          │ Mức độ Nghiêm trọng │
├──────────────────────────┼────────────────────────────────────────────────────────┼─────────────────────┤
│ **R1: Nội dung & Logic** │ - 8 điểm Mâu thuẫn nội tại (Delimiter, Header, Lớp...) │ 🔴 CRITICAL         │
│ (SKILL.md & References)  │ - 7 cụm Trùng lặp nội dung lớn (Date FK, Atomic YAML...)│                     │
│                          │ - 7 Lỗ hổng / Thiếu sót lớn (Delete, SCD4A, Shared Dim)│                     │
│                          │ - 10 Tiêu chí đối chiếu lệch chuẩn với 3 Reference     │                     │
│                          │ - Tái cấu trúc Flow: Before vs After (3 Giai đoạn)     │                     │
├──────────────────────────┼────────────────────────────────────────────────────────┼─────────────────────┤
│ **R2: Cấu trúc & Token** │ - Bản đồ nội dung 19 Sections trên 1013 dòng (~86KB)   │ 🔴 CRITICAL         │
│ (Architecture Refactor)  │ - Kiến trúc Hub & Spokes: SKILL.md ~320 dòng (-68%)    │                     │
│                          │ - Đề xuất tạo 3 Reference Files mới chuyên sâu         │                     │
│                          │ - Chiến lược phòng vệ 2 tầng: Anchor Summaries + Trig  │                     │
│                          │ - Ma trận triệt tiêu 10 khối trùng lặp SSOT            │                     │
├──────────────────────────┼────────────────────────────────────────────────────────┼─────────────────────┤
│ **R3: Mã nguồn Scripts** │ - 7 bugs trong `datamart_progress_analyzer.py`          │ 🔴 CRITICAL         │
│ (Python CLI Tools)       │ - 4 bugs trong `datamart_date_fk_checker.py`           │                     │
│                          │ - Ma trận đối chiếu 5 quy tắc: 2 thiếu, 2 lệch, 1 tốt  │                     │
│                          │ - 0% Test Coverage trên progress analyzer              │                     │
│                          │ - Đề xuất tách `datamart_common` và hỗ trợ JSON export │                     │
└──────────────────────────┴────────────────────────────────────────────────────────┴─────────────────────┘
```

### 2.1. Trụ Cột R1 — Rà Soát SKILL.md và Quy Trình Review
- **8 Điểm Mâu thuẫn nội tại:**
  1. *Delimiter BA:* Đoạn code mẫu gán cứng `delimiter=';'` (dòng 370–385) mâu thuẫn trực tiếp với chỉ dẫn tự động dò `,` và `;` (dòng 49, 189).
  2. *Header GSĐC:* Ghi header nằm ở dòng 0 (dòng 398) mâu thuẫn với khẳng định dòng 1 cho toàn bộ 11 file hiện hành (dòng 49).
  3. *Số lớp Bước 2:* Tiêu đề ghi "(3 LỚP)" nhưng nội dung triển khai 4 lớp + 1b + 2b.
  4. *Vị trí Lớp 1b/2b:* Sơ đồ tổng thể xếp vào Bước 0c (Macro-Review), nhưng nội dung chi tiết lại bị nhét vào Bước 2 (vòng lặp nhóm).
  5. *Quyền sửa file:* Khẳng định cấm tự Edit trực tiếp (dòng 38, 779), nhưng Lớp 4 lại chỉ thị Claude tự sửa `datamart_model.yaml` (dòng 668, 676).
  6. *Đối soát số lượng 0b.3:* Đếm tổng số dòng HLD (gồm cả PENDING) nhưng chỉ đếm dòng BA có trạng thái Done/Doing -> Luôn báo lệch số lượng giả (False Alarm).
  7. *Mức độ nghiêm trọng:* Cùng một lỗi thiếu Section 4 HLD, Bước 0b xếp là Critical 🔴 nhưng bảng mẫu lại xếp là Warning 🟡.
  8. *Cú pháp JOIN Date FK:* Lớp 2 dùng cột tự nhiên `cdr_dt = driving.date`, Lớp 3 dùng surrogate key `cdr_dt_dim_id = fact.date_dim_id` nhưng không phân định ngữ cảnh.
- **7 Lỗ hổng lớn:** Thiếu hoàn toàn kiểm tra chỉ tiêu bị Xóa (`Delete`); thiếu kiểm tra trường kỹ thuật SCD4A và điều kiện `ds_rcrd_st = 'ACTIVE'`; thiếu tiêu chí phân định Degenerate Date vs Role-Playing Date FK; thiếu cơ chế `Reconciled Delta`; thiếu dọn dẹp Orphan Draft Artifacts; thiếu quy định bảo vệ SHARED Dimension; thiếu đối soát ngược từ Flat Table SQL về LLD.
- **Chuẩn hóa Flow 3 Giai đoạn:** Giai đoạn 1 (Macro-Audit & Fast Sanity toàn module); Giai đoạn 2 (Micro-Review chi tiết 4 lớp từng nhóm); Giai đoạn 3 (Tổng hợp, Remediation qua skill con & Handoff).

### 2.2. Trụ Cột R2 — Tái Cấu Trúc Kiến Trúc Hub & Spokes
- **Bản đồ phân rã 19 Sections:** Phân định rõ ràng vai trò từng đoạn của 1013 dòng. Nhóm tri thức tra cứu tĩnh chiếm gần ~40% dung lượng đang bị gắn cứng vào file instruction.
- **Kiến trúc Hub & Spokes:** Tinh giản `SKILL.md` xuống còn **~320 dòng (~27KB)**, đóng vai trò Master Orchestrator. Tách 3 Reference Files mới:
  1. `reference/role_playing_date_fk_guide.md`: Chuyên đề Kimball Date FK, Degenerate Date và Remediation 4 tầng.
  2. `reference/technical_review_rules.md`: Quy tắc kỹ thuật sâu (Atomic YAML approved, Flatten, CSV integrity, Financial TTM metrics, SCD4A).
  3. `reference/kpi_reconciliation_rules.md`: Thuật toán đối soát số lượng 2 tầng, Reconciled Delta và quét chỉ tiêu Delete.
- **Chiến lược Phòng thủ 2 Tầng:** Kết hợp **Anchor Summaries** (2–3 dòng tóm tắt quy tắc sống còn ngay tại SKILL.md) và **Deterministic Triggers** (yêu cầu Agent gọi tool `view_file` đọc reference trước khi đánh giá Lớp) nhằm triệt tiêu hoàn toàn rủi ro mất ngữ cảnh.

### 2.3. Trụ Cột R3 — Kiểm Định Mã Nguồn Scripts CLI
- **11 Bugs kỹ thuật & Edge cases:**
  - `datamart_progress_analyzer.py` (7 bugs): Thuật toán dò delimiter bị lừa bởi câu lệnh SQL chứa phẩy (PA-01); Parser Detail Mapping không có logic dò delimiter (PA-02); Regex split `|` làm vỡ cột và sai trạng thái khi công thức chứa pipe hoặc logic OR (PA-03); Regex header nhóm bỏ sót số mục BRD 3.2.2.x và dấu chấm (PA-04); Cây PENDING gán nhầm sang Nhánh 6 do cờ bao trùm `has_count_mismatch` (PA-05); Khớp nhầm KPI do substring quá ngắn (PA-06); Bỏ qua ô trạng thái trống trong BA (PA-07).
  - `datamart_date_fk_checker.py` (4 bugs): Dò delimiter chỉ đọc 1 dòng đầu tiên (DFK-01); Quét toàn bộ file master attributes gây ô nhiễm kết quả khi lọc `--module` (DFK-02); Lọt lưới Rule 2 khi bảng Snapshot hoàn toàn không có Date FK nào (DFK-03); Thiếu kiểm tra Fact Event hoàn toàn không có Date FK (DFK-04).
- **Code Quality & Testing:** Analyzer có 0% test coverage; lạm dụng silent exception `except Exception: pass`; thiếu module dùng chung dẫn đến duplicate code xử lý I/O và delimiter giữa 2 scripts.

---

## 3. MASTER ACTION ITEM LIST (BẢNG ĐẦU VIỆC TOÀN DIỆN)

Toàn bộ các nhiệm vụ cần thực thi được phân loại theo ma trận ưu tiên chuẩn quốc tế (P0 – P3):
- **P0 (Critical Blocker):** Phải làm ngay lập tức, ảnh hưởng trực tiếp đến tính đúng đắn của quy trình và khả năng chạy của công cụ.
- **P1 (High Priority):** Cần hoàn thành sớm, ngăn chặn các lỗi kiến trúc và lỗ hổng dữ liệu lớn.
- **P2 (Medium Priority):** Tối ưu hóa hiệu năng, refactor kiến trúc và nâng cao độ bao phủ test.
- **P3 (Low / Tech Debt):** Dọn dẹp tài liệu, xóa bỏ mã trùng lặp, cải thiện trải nghiệm dòng lệnh (UX).

```
┌─────┬──────────┬──────────────────────────────────────────────────┬─────────────────────────────┬──────────┬──────────────────┐
│ STT │ Priority │ Mô tả Đầu việc Cần Thực hiện                     │ File / Khu vực Ảnh hưởng    │ Effort   │ Vai trò Phụ trách│
├─────┼──────────┼──────────────────────────────────────────────────┼─────────────────────────────┼──────────┼──────────────────┤
│ 1   │ **P0**   │ Vá Bug PA-01 & DFK-01: Thay thuật toán delimiter │ `scripts/datamart_progress  │ 0.5 day  │ Python Developer │
│     │          │ bằng mode & consistency analysis chống gãy SQL   │ _analyzer.py`, `...date...` │          │                  │
├─────┼──────────┼──────────────────────────────────────────────────┼─────────────────────────────┼──────────┼──────────────────┤
│ 2   │ **P0**   │ Vá Bug PA-03: Trích xuất status từ đuôi mảng để  │ `scripts/datamart_progress  │ 0.5 day  │ Python Developer │
│     │          │ không bị vỡ cột khi formula chứa ký tự pipe '|'  │ _analyzer.py`               │          │                  │
├─────┼──────────┼──────────────────────────────────────────────────┼─────────────────────────────┼──────────┼──────────────────┤
│ 3   │ **P0**   │ Vá Bug DFK-02 & DFK-03: Lọc table theo module và │ `scripts/datamart_date_fk   │ 0.5 day  │ Python Developer │
│     │          │ chặn đứng Fact Snapshot thiếu hoàn toàn Date FK  │ _checker.py`                │          │                  │
├─────┼──────────┼──────────────────────────────────────────────────┼─────────────────────────────┼──────────┼──────────────────┤
│ 4   │ **P0**   │ Sửa Mâu thuẫn 1 & 2 trong SKILL.md: Xóa code gán │ `.claude/skills/datamart    │ 0.25 day │ Skill Architect  │
│     │          │ cứng delimiter=';' và chuẩn hóa header Dòng 1    │ -review/SKILL.md`           │          │                  │
├─────┼──────────┼──────────────────────────────────────────────────┼─────────────────────────────┼──────────┼──────────────────┤
│ 5   │ **P0**   │ Khóa quyền Edit trực tiếp file ở Lớp 4 (Mâu      │ `.claude/skills/datamart    │ 0.25 day │ Skill Architect  │
│     │          │ thuẫn 5): Bắt buộc chuyển giao qua skill con     │ -review/SKILL.md`           │          │                  │
├─────┼──────────┼──────────────────────────────────────────────────┼─────────────────────────────┼──────────┼──────────────────┤
│ 6   │ **P1**   │ Vá Bug PA-04 & PA-07: Hỗ trợ tiêu đề nhóm BRD    │ `scripts/datamart_progress  │ 0.5 day  │ Python Developer │
│     │          │ 3.2.2.x và xử lý trạng thái BA rỗng vào Nhánh 1  │ _analyzer.py`               │          │                  │
├─────┼──────────┼──────────────────────────────────────────────────┼─────────────────────────────┼──────────┼──────────────────┤
│ 7   │ **P1**   │ Vá Bug PA-05: Tách điều kiện Nhánh 6 khỏi        │ `scripts/datamart_progress  │ 0.5 day  │ Python Developer │
│     │          │ has_count_mismatch để trả về đúng Nhánh 5        │ _analyzer.py`               │          │                  │
├─────┼──────────┼──────────────────────────────────────────────────┼─────────────────────────────┼──────────┼──────────────────┤
│ 8   │ **P1**   │ Bổ sung kiểm tra bắt buộc chỉ tiêu bị XÓA        │ `SKILL.md`, `reference/     │ 0.5 day  │ QA / Architect   │
│     │          │ (`Delete` / `DELETED`) vào SKILL.md và scripts   │ issue_classification.md`    │          │                  │
├─────┼──────────┼──────────────────────────────────────────────────┼─────────────────────────────┼──────────┼──────────────────┤
│ 9   │ **P1**   │ Bổ sung quy tắc SCD4A (`ds_rcrd_st = 'ACTIVE'`)  │ `SKILL.md`, `reference/     │ 0.5 day  │ QA / Architect   │
│     │          │ và bảo vệ SHARED Dimension vào Lớp 2 & Lớp 4     │ technical_review_rules.md`  │          │                  │
├─────┼──────────┼──────────────────────────────────────────────────┼─────────────────────────────┼──────────┼──────────────────┤
│ 10  │ **P1**   │ Tạo 3 Reference Files mới theo kiến trúc R2      │ `reference/*.md`            │ 1.0 day  │ Skill Architect  │
│     │          │ (date_fk_guide, technical_rules, reconciliation) │                             │          │                  │
├─────┼──────────┼──────────────────────────────────────────────────┼─────────────────────────────┼──────────┼──────────────────┤
│ 11  │ **P2**   │ Tinh giản SKILL.md xuống ~320 dòng theo mô hình  │ `.claude/skills/datamart    │ 1.0 day  │ Skill Architect  │
│     │          │ Hub & Spokes, nhúng 2 tầng phòng ngự ngữ cảnh    │ -review/SKILL.md`           │          │                  │
├─────┼──────────┼──────────────────────────────────────────────────┼─────────────────────────────┼──────────┼──────────────────┤
│ 12  │ **P2**   │ Xây dựng bộ Unit Test toàn diện cho script       │ `tests/test_datamart        │ 1.0 day  │ QA Automation    │
│     │          │ `datamart_progress_analyzer.py` (Coverage > 75%) │ _progress_analyzer.py`      │          │                  │
├─────┼──────────┼──────────────────────────────────────────────────┼─────────────────────────────┼──────────┼──────────────────┤
│ 13  │ **P2**   │ Tách module dùng chung `scripts/datamart_common/`│ `scripts/datamart_common/`  │ 1.0 day  │ Python Developer │
│     │          │ (encoding, csv_utils, module_resolver, models)   │                             │          │                  │
├─────┼──────────┼──────────────────────────────────────────────────┼─────────────────────────────┼──────────┼──────────────────┤
│ 14  │ **P2**   │ Nâng cấp script hỗ trợ xuất đồng thời JSON & MD  │ `scripts/datamart_progress  │ 0.5 day  │ Python Developer │
│     │          │ và chuẩn hóa Exit Codes (0, 1, 2) cho CI/CD      │ _analyzer.py`               │          │                  │
├─────┼──────────┼──────────────────────────────────────────────────┼─────────────────────────────┼──────────┼──────────────────┤
│ 15  │ **P3**   │ Tạo file Whitelist ngoại lệ lệch số lượng hợp lệ │ `system/rules/datamart      │ 0.5 day  │ BA / Architect   │
│     │          │ (`datamart_review_whitelist.yaml`)              │ _review_whitelist.yaml`     │          │                  │
├─────┼──────────┼──────────────────────────────────────────────────┼─────────────────────────────┼──────────┼──────────────────┤
│ 16  │ **P3**   │ Xóa bỏ bản sao script trùng lặp tại `scripts/`   │ `scripts/`, `.claude/...`   │ 0.25 day │ Repository Admin │
│     │          │ chỉ giữ lại một bản duy nhất trong skill         │                             │          │                  │
└─────┴──────────┴──────────────────────────────────────────────────┴─────────────────────────────┴──────────┴──────────────────┘
```

---

## 4. TỔNG HỢP CÁC QUYẾT ĐỊNH KIẾN TRÚC (ARCHITECTURAL DECISIONS)

Dưới đây là các quyết định kiến trúc bất khả biến đã được thống nhất:

### ADR-01: Chuyển dịch Kiến trúc sang Mô hình Hub & Spokes
- **Quyết định:** Tách `SKILL.md` nguyên khối 1013 dòng thành Master Orchestrator (~320 dòng) kết hợp với 6 Reference Files chuyên sâu.
- **Lý do:** Tiết kiệm ~65% token đầu vào, chống tràn context, ngăn ngừa trôi prompt khi review qua nhiều nhóm, đồng thời đạt chuẩn Single Source of Truth (SSOT).
- **Hệ quả:** Bắt buộc áp dụng 2 tầng phòng ngự (Anchor Summaries + Deterministic Triggers) để chống mất ngữ cảnh đối với Agent.

### ADR-02: Nguyên Tắc Bất Khả Xâm Phạm Về Quyền Hạn (Read-Only Explorer)
- **Quyết định:** Skill `datamart-review` là công cụ điều tra, phân tích và kiểm định độc lập (Read-Only). Claude TUYỆT ĐỐI KHÔNG tự sửa file HLD, LLD hay Registry.
- **Lý do:** Đảm bảo tính khách quan và kiểm soát phiên bản; mọi hành động sửa đổi phải đi qua các skill chuyên trách (`datamart-hld-design`, `datamart-lld-design`) sau khi có sự phê duyệt rõ ràng từ Human Operator.

### ADR-03: Chuẩn Hóa Kiểm Tra Date FK Theo Ralph Kimball
- **Quyết định:** Cấm tuyệt đối `cdr_dt_dim_id` trên Fact table. Fact Snapshot bắt buộc là `snpst_dt_dim_id`. Fact Event bắt buộc là `<role>_dt_dim_id`.
- **Phân định:** Trục thời gian phân tích chính dùng Role-Playing Date FK (`_dim_id`); trường ngày mô tả nghiệp vụ pass-through giữ kiểu `DATE` thuần (Degenerate Date).

### ADR-04: Đối Soát Số Lượng Hai Tầng (Two-Tier Reconciliation)
- **Quyết định:** Phân tách rõ ràng giữa:
  1. *Total Scope Reconciliation:* Tổng BA hợp lệ (loại bỏ `Delete`) khớp 1-1 với Tổng KPI HLD (kể cả PENDING).
  2. *Ready Scope Reconciliation:* BA Done/Doing khớp 1-1 với HLD READY.
- **Lý do:** Loại bỏ hoàn toàn các cảnh báo đỏ giả (False Alarm) tại Bước 0b khi mô hình chứa các chỉ tiêu PENDING hợp lệ.

### ADR-05: Cơ Chế Bảo Vệ SHARED Dimension Schema
- **Quyết định:** Đối với entity `SHARED`, nguồn sự thật duy nhất là approved Registry (`datamart_model.yaml`). LLD của các phân hệ lẻ phải tuân theo Registry, cấm tự ý ghi đè làm phá vỡ schema dùng chung của toàn hệ thống.

---

## 5. HƯỚNG DẪN TIẾP NHẬN & BÀN GIAO (ONBOARDING & NEXT STEPS)

Tài liệu này được thiết kế theo nguyên tắc **tự chứa hoàn toàn (self-contained)**. Bất kỳ kỹ sư, tech lead hoặc AI Agent mới nào khi tiếp nhận dự án chỉ cần đọc tài liệu này là có thể nắm bắt ngay bức tranh toàn cảnh và bắt tay vào thực hiện các bước tiếp theo.

### 5.1. Tóm Tắt Nhanh Bản Chất Dự Án Cho Thành Viên Mới
- **Bạn đang ở đâu?** Bạn đang tham gia vào dự án xây dựng Kho Dữ Liệu Thị Trường Chứng Khoán UBCKNN.
- **Skill `datamart-review` làm gì?** Đây là bộ công cụ tự động hóa và hướng dẫn kiểm tra chéo giữa file nghiệp vụ BA (`BRD/BA/*.csv`), tài liệu thiết kế HLD (`Datamart/hld/*.md`), bảng thuộc tính LLD (`Datamart/lld/*_Attributes.csv`), bảng ánh xạ chi tiết (`Datamart/lld/*_Detail_Mapping.csv`) và từ điển thực thể (`Datamart/datamart_model.yaml`).
- **Nhiệm vụ của đợt này là gì?** Không chỉnh sửa thiết kế dữ liệu, mà là **rà soát, phát hiện lỗi và đề xuất nâng cấp chính bộ công cụ review này** (cả tài liệu hướng dẫn lẫn script Python).
- **Trạng thái hiện tại:** Đã hoàn thành 100% việc khảo sát R1, R2, R3 và xuất bản 4 tài liệu Checkpoint chuẩn hóa trong thư mục `_review_checkpoints/`.

### 5.2. Các Bước Hành Động Cụ Thể Tiếp Theo (Execution Steps)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          LỘ TRÌNH THỰC THI TIẾP THEO                         │
├─────────────────────────────────────────────────────────────────────────────┤
│ BƯỚC 1: XIN PHÊ DUYỆT TỪ HUMAN LEAD                                         │
│   - Trình nộp 4 file Checkpoint trong `_review_checkpoints/`.               │
│   - Xin phê duyệt về Master Action Item List và Kế hoạch Refactor.          │
├─────────────────────────────────────────────────────────────────────────────┤
│ BƯỚC 2: TRIỂN KHAI VÁ BUGS PYTHON SCRIPTS (Ưu tiên P0 & P1)                │
│   - Tạo branch/task mới: `task/datamart-review-scripts-patch`.             │
│   - Áp dụng 11 bản vá code đã được cung cấp tại Checkpoint R3.              │
│   - Viết bộ unit test `tests/test_datamart_progress_analyzer.py` và chạy    │
│     kiểm thử toàn bộ bằng lệnh `pytest tests/`.                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ BƯỚC 3: TRIỂN KHAI TÁI CẤU TRÚC SKILL.MD (Ưu tiên P1 & P2)                 │
│   - Tạo 3 Reference Files mới trong `.claude/skills/datamart-review/reference`│
│   - Soạn thảo `SKILL_v2.md` (~320 dòng) theo mẫu Checkpoint R2.             │
│   - Thực hiện kiểm tra dry-run trên module `GSĐC` và `GSTT`.                │
│   - Backup và phát hành `SKILL.md` chính thức.                              │
├─────────────────────────────────────────────────────────────────────────────┤
│ BƯỚC 4: NGHIỆM THU TOÀN DIỆN & ĐÓNG DỰ ÁN                                   │
│   - Chạy kiểm tra tự động toàn bộ 11 phân hệ bằng scripts mới.              │
│   - Đối chiếu báo cáo với các tiêu chuẩn kiểm định của UBCKNN.              │
│   - Bàn giao hệ thống cho đội ngũ vận hành DWH.                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. KẾT LUẬN

Tập 4 tài liệu Checkpoint tại thư mục `_review_checkpoints/` đã phản ánh đầy đủ, trung thực, sâu sắc và độc lập toàn bộ các góc cạnh của skill `datamart-review`:
1. `checkpoint_r1_skill_review.md`: Làm sạch các mâu thuẫn nghiệp vụ và chuẩn hóa quy trình review 3 giai đoạn.
2. `checkpoint_r2_structure_refactor.md`: Cung cấp giải pháp kiến trúc module hóa Hub & Spokes bền vững, giải phóng 68% dung lượng token.
3. `checkpoint_r3_scripts_audit.md`: Cung cấp mã nguồn sửa chữa chính xác cho 11 bugs trong công cụ tự động hóa.
4. `checkpoint_final_summary.md`: Bức tranh tổng hợp hoàn chỉnh, định vị lộ trình hành động rõ ràng và sẵn sàng cho việc triển khai thực tế.

Toàn bộ quá trình khảo sát tuân thủ nghiêm ngặt nguyên tắc **READ-ONLY**, bảo toàn nguyên trạng mã nguồn và tài liệu hiện hành của dự án.
