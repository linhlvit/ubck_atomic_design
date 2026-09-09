# CHECKPOINT R2 — PHÂN TÍCH CẤU TRÚC VÀ ĐỀ XUẤT REFACTOR SKILL.MD
## Dự án: Review và Chuẩn hóa Skill `datamart-review` (UBCKNN Atomic Design)

- **Mã tài liệu:** `CHECKPOINT-R2-STRUCTURE-REFACTOR`
- **Phiên bản:** 1.0 (Chính thức)
- **Ngày lập:** 2026-09-09
- **Đối tượng khảo sát:** `SKILL.md` (1013 dòng, ~86KB) và kiến trúc thư mục `.claude/skills/datamart-review/`.
- **Trạng thái:** Hoàn thành phân tích R2, sẵn sàng cho công tác phê duyệt kiến trúc và chia tách module.

---

## (A) TÓM TẮT FINDINGS CHI TIẾT

---

### 1. Bản Đồ Nội Dung Toàn Diện (Content Map) của SKILL.md Hiện Tại (19 Sections)

Toàn bộ **1013 dòng** của `SKILL.md` hiện tại được phân rã chi tiết thành **19 sections/subsections logic** độc lập, phản ánh 100% độ phủ nội dung:

| STT | Tên Section / Heading | Phạm vi Dòng (Start - End) | Số dòng (Count) | Tỷ lệ % (trên 1013 dòng) | Tóm tắt Nội dung chính & Vai trò của Section |
|:---:|---|:---:|:---:|:---:|---|
| **1** | **YAML Frontmatter & Triggers** (`---`) | 1 – 27 | 27 | 2.67% | Khai báo metadata: tên skill (`datamart-review`), mô tả 3 chế độ (Macro, Micro, Issue Trace), cú pháp gọi tay, danh mục input bắt buộc. Entrypoint cho Claude Code. |
| **2** | **Title, Quy ước Claude Code & Tài nguyên** (`# Skill: ...`) | 28 – 54 | 27 | 2.67% | Định vị vai trò Claude (Reviewer độc lập). Đặt 2 nguyên tắc cấm kỵ cứng: **TUYỆT ĐỐI KHÔNG tự edit trực tiếp** vào HLD/LLD/Registry, và **READ-ONLY trên `DataModel/`**. Liệt kê tài nguyên kèm theo. |
| **3** | **Nguyên tắc Cốt lõi & 5 Kịch bản** (`## NGUYÊN TẮC CỐT LÕI`) | 55 – 115 | 61 | 6.02% | Định nghĩa chuỗi 5 tầng truy vết (BA ➔ Source ➔ Atomic ➔ DM ➔ Báo cáo); Giới thiệu Ma trận đối soát & Cây 6 nhánh PENDING; Bảng phân biệt 5 Kịch bản A–E và routing qua skill con. |
| **4** | **Quy trình Tổng thể & Gate Rules** (`## QUY TRÌNH TỔNG THỂ`) | 116 – 169 | 54 | 5.33% | Sơ đồ ASCII quy trình 2 chế độ (Macro vs Micro); Định nghĩa các **GATE RULES bắt buộc**: Dừng sau Bước 0b, Dừng khi có lỗi sau mỗi nhóm, Tự động chuyển tiếp khi OK. |
| **5** | **Bước 0: Xác định Scope & Macro-Review** (`## BƯỚC 0`) | 170 – 195 | 26 | 2.57% | Nhận diện tham số module, resolve file path (hỗ trợ file gộp `GSĐC` có dấu); Kiểm tra file tồn tại; Lệnh chạy CLI `datamart_progress_analyzer.py` xuất ma trận tiến độ. |
| **6** | **Bước 0b: Đối soát Ma trận & Kế hoạch** (`## BƯỚC 0b`) | 196 – 294 | 99 | 9.77% | 5 bước con: 0b.1 Đọc BA bằng parser động; 0b.2 Đọc HLD, check 5 Section và bảng 7 cột; 0b.3 Đối chiếu số lượng 1-1; 0b.4 Xuất ma trận tiến độ; 0b.5 **GATE Dừng chờ human duyệt KH**. |
| **7** | **Bước 0-ALT: Review theo Issue/Bug Report** (`## BƯỚC 0-ALT`) | 295 – 368 | 74 | 7.31% | Quy trình rẽ nhánh Kịch bản E: trace nhanh 5 tầng cho lỗi cụ thể, xuất bảng trạng thái per-tầng (✅/⚠️/❌), đọc sâu SQL BA (TTM, rolling, dedup), phân tích root cause, Gate chờ phê duyệt. |
| **8** | **Bước 1: Đọc BA, Dò Parser & Lập Nhóm** (`## BƯỚC 1`) | 369 – 436 | 68 | 6.71% | Hướng dẫn kỹ thuật đọc BA CSV (chứa code mẫu cứng `;`); Cảnh báo không hardcode cột; Bảng 11 cột BA cần lấy; Cảnh báo giá trị cột `Phân loại`; Cách gom nhóm và gán trạng thái nhóm. |
| **9** | **Bước 2 / Lớp 1: Review HLD** (`### Lớp 1: Review HLD`) | 437 – 464 | 28 | 2.76% | Bảng kiểm tra 11 tiêu chí HLD: Coverage 2 chiều, Grain, Công thức/Mô tả dòng reuse, Chiều slicer, Cột Fact thừa, Đọc sâu SQL khi PENDING, Nhất quán KPI phái sinh vs cơ sở. Output format Lớp 1. |
| **10** | **Bước 2 / Lớp 1b: 13 Mục Bước 5B HLD** (`### Lớp 1b: ...`) | 465 – 495 | 31 | 3.06% | Bảng liệt kê 13 mục kiểm tra (#0 – #12) kế thừa từ `datamart-hld-design` Bước 5B (erDiagram syntax, quan hệ Fact-to-Fact, Flowchart 3 subgraph, Node ID Staging...). Chạy 1 lần/module. |
| **11** | **Bước 2 / Lớp 2b: 10 TC Phase 1 LLD & Date FK** (`### Lớp 2b: ...`) | 496 – 533 | 38 | 3.75% | Bảng liệt kê 10 TC Phase 1 LLD; Lệnh chạy CLI `datamart_date_fk_checker.py`; Kiểm tra cấm `cdr_dt_dim_id` trên Fact, bắt buộc `snpst_dt_dim_id` trên Fact Snapshot; Mã lỗi `L2-DATE-FK-ROLE-PLAYING`. |
| **12** | **Bước 2 / Lớp 2: Review Attributes** (`### Lớp 2: Review Attributes`) | 534 – 582 | 49 | 4.84% | Bảng 10 tiêu chí kiểm tra Attributes: Mapping completeness, Atomic source, Flatten hoàn toàn, `join_atomic` coverage, lookup vế trái là cột DM thật, `src_stm_code`, Key constraints, Role-Playing Date FK. |
| **13** | **Bước 2 / Lớp 3: Review Detail Mapping** (`### Lớp 3: ...`) | 583 – 632 | 50 | 4.94% | Bảng 8 tiêu chí Detail Mapping: Trace logic BA, Cột logic dùng physical name, Bắt buộc **Inline DERIVED (cấm dùng KPI_ID khác)**, `column_role`, mart_table/mart_column; Đọc FULL SQL tham khảo BA. |
| **14** | **Bước 2 / Lớp 4: Review datamart_model.yaml** (`### Lớp 4: ...`) | 633 – 684 | 52 | 5.13% | Bảng 7 tiêu chí Model Registry: Khớp 1-1 cột với Attributes, Type match, Atomic YAML verify; Phân biệt **Boolean hợp lệ vs Indicator Y/N**; Đoạn mã verify YAML parse hợp lệ. |
| **15** | **Bước 3 & Bước 4: Tổng hợp Vấn đề & Action Items** (`## BƯỚC 3`, `## BƯỚC 4`) | 685 – 729 | 45 | 4.44% | Mẫu Bảng chi tiết vấn đề (7 cột) và Bảng Action Items tổng hợp (4 cột); Định nghĩa 3 mức độ (Critical, Warning, Info); Quy trình chờ xác nhận và routing sang skill con theo Kịch bản A, B, C, D. |
| **16** | **Review Tuần tự — Gate Control & PENDING ➔ READY** (`## REVIEW NHÓM TUẦN TỰ`) | 730 – 817 | 88 | 8.69% | Sơ đồ luồng xử lý sau mỗi nhóm (ASCII flow); 6 quy tắc cứng về chuyển tiếp/dừng chờ; **Quy tắc bắt buộc PENDING ➔ READY** (review lại 3 lớp LLD ngay sau khi hoàn tất HLD). |
| **17** | **Lưu ý Đặc biệt: Kỹ thuật Kiểm tra Chuyên sâu** (`## LƯU Ý ĐẶC BIỆT`) | 818 – 936 | 119 | 11.75% | Bẫy kỹ thuật sâu: Tra cứu 2 nguồn Atomic approved (cấm `Atomic_LinhLV`); **Flatten hoàn toàn** (kèm code quét missing join); **Verify Atomic YAML thật**; **Verify toàn vẹn CSV sau edit**; **Phân biệt TTM vs Stock Metric**. |
| **18** | **Kiểm tra Physical Naming** (`### Kiểm tra Physical Naming`) | 937 – 970 | 34 | 3.36% | Nguồn sự thật duy nhất `system/rules/rule_physical_name_exceptions_datamart.csv`; Nguyên tắc derive từ logical name; Lệnh grep regex phát hiện viết tắt trái phép; Quy trình Kịch bản C. |
| **19** | **Quy tắc Role-Playing Date Dimension** (`### Quy tắc Role-Playing...`) | 971 – 1013 | 43 | 4.24% | Chuyên đề Kimball về Date FK trên Fact; Bài học sự cố GSĐC; Quy tắc đặt tên Fact Snapshot (`snpst_dt_dim_id`) vs Fact khác (`<role>_dt_dim_id`); Cấm `cdr_dt_dim_id` trên Fact; Remediation Protocol 4 tầng. |
| **TỔNG** | **Toàn bộ tài liệu SKILL.md** | **1 – 1013** | **1013** | **100.0%** | **Độ phủ tuyệt đối 100% (19 sections rõ ràng, không sót dòng nào).** |

---

### 2. Kiến Trúc Tái Cấu Trúc Hub & Spokes

Để giải quyết triệt để tình trạng phình to dung lượng (~86KB / ~22.000 tokens), kiến trúc mới phân tách rõ ràng giữa **Tài liệu Điều phối Trung tâm (Master Orchestrator - Hub)** và **Các Sổ tay Chuyên môn Sâu (Deep-dive Reference Manuals - Spokes)**:

```
.claude/skills/datamart-review/
├── SKILL.md                                 [HUB] Master Orchestrator (~320 dòng, ~27KB)
├── reference/
│   ├── review_checklist.md                  [EXISTING - NÂNG CẤP] Checklist vận hành 2 chế độ
│   ├── issue_classification.md              [EXISTING - NÂNG CẤP] SSOT Ma trận đối soát & 6 nhánh PENDING
│   ├── ba_source_profile.md                 [EXISTING - NÂNG CẤP] SSOT Cấu trúc 11 file BA & Parser
│   ├── role_playing_date_fk_guide.md        [NEW 1] Chuyên đề Kimball Date FK & Remediation
│   ├── technical_review_rules.md            [NEW 2] Quy tắc kỹ thuật chuyên sâu (Atomic YAML, Flatten, CSV)
│   └── kpi_reconciliation_rules.md          [NEW 3] Thuật toán đối soát số lượng BA ↔ HLD ↔ Detail Mapping
└── scripts/
    ├── datamart_progress_analyzer.py        CLI Phân tích tiến độ & đối soát số lượng
    └── datamart_date_fk_checker.py          CLI Quét vi phạm Role-Playing Date FK
```

#### Chi tiết 3 Reference Files Mới:
1. **`reference/role_playing_date_fk_guide.md` (New Reference 1):**
   - Tách Section 19 (`SKILL.md` dòng 971–1013) và phần kiểm tra Date FK tại Lớp 2b.
   - Nội dung: Lý thuyết Ralph Kimball về Role-Playing Date Dimension; Phân định Role-Playing Date FK vs Degenerate Date Attribute; Quy tắc đặt tên chuẩn Fact Snapshot vs Fact Event; Hướng dẫn chạy CLI `datamart_date_fk_checker.py`; Remediation Protocol 4 tầng (Attributes, Detail Mapping, Registry, Flat SQL).
2. **`reference/technical_review_rules.md` (New Reference 2):**
   - Tách Section 17 (Lưu ý đặc biệt, dòng 818–936) và Section 18 (Physical Naming, dòng 937–970).
   - Nội dung: Quy tắc Flatten hoàn toàn xuống Atomic (cấm cột mart) kèm code mẫu quét missing `join_atomic`; Giao thức Verify Atomic YAML approved (2 nguồn chuẩn, cấm `Atomic_LinhLV`); Giao thức bảo đảm toàn vẹn CSV khi batch edit; Chuẩn phân biệt Financial Flow Metric (TTM 4 quý) vs Stock Metric (Latest Quarter rn=1); Quy tắc tra cứu Physical Naming Exceptions; Quy tắc bộ trường kỹ thuật SCD4A và điều kiện `ds_rcrd_st = 'ACTIVE'`.
3. **`reference/kpi_reconciliation_rules.md` (New Reference 3):**
   - Tách và mở rộng Bước 0b.3 (dòng 240–257) và Lớp 1 (dòng 449–452).
   - Nội dung: Thuật toán đối soát 3 chiều: BA hợp lệ ↔ HLD KPI ↔ Detail Mapping; Công thức lọc 2 tầng (Total Scope vs Ready Scope); Cơ chế xử lý độ lệch hợp lệ (`Reconciled Delta`) cho sub-KPIs YoY và trường hợp chia loại hình doanh nghiệp; Quy trình quét và loại bỏ triệt để chỉ tiêu BA = Delete.

---

### 3. Phân Tích Đánh Giá Toàn Diện Trade-Off (Token vs Context Loss) & Chiến Lược Phòng Thủ 2 Tầng

| Tiêu chí Đánh giá | Monolithic Hiện tại (SKILL.md 1013 dòng) | Kiến trúc Đề xuất (SKILL.md ~320 dòng + References) | Đánh giá Trade-Off & Rủi ro | Chiến lược Phòng thủ & Giảm thiểu Rủi ro |
|---|---|---|---|---|
| **Mức tiêu thụ Token & Context Window** | **Rất cao (~22.000 tokens/lần nạp).** Gây nghẽn context khi review lặp qua nhiều nhóm, dễ dẫn đến hiện tượng context truncation hoặc trôi mất prompt. | **Tối ưu hóa mạnh (~6.000–8.000 tokens/lần nạp).** Tiết kiệm ~65% token đầu vào. Dành dung lượng cho việc suy luận nghiệp vụ. | 🟢 **Lợi ích vượt trội:** Tăng tốc độ phản hồi của Claude Code, giảm chi phí API, duy trì khả năng suy luận sắc bén qua nhiều nhóm. | Không cần giảm thiểu (đây là mục tiêu cải tiến chính). |
| **Tính Dễ bảo trì & SSOT** | **Rất kém.** Cùng 1 quy tắc (Date FK, Delimiter, PENDING tree) được chép ở 4–7 vị trí khác nhau. Sửa một chỗ rất dễ quên các chỗ khác, gây mâu thuẫn nội tại. | **Xuất sắc.** Mỗi quy tắc kỹ thuật chỉ nằm tại đúng 1 file quy chuẩn duy nhất. Khi cập nhật chính sách thiết kế, chỉ cần sửa 1 nơi. | 🟢 **Lợi ích cốt lõi:** Loại bỏ triệt để nguy cơ "lệch đồng bộ" (sync drift) giữa các tài liệu hướng dẫn. | Thiết lập quy định kiểm tra chéo trong CI/CD hoặc audit định kỳ giữa các file reference. |
| **Nguy cơ Mất Ngữ cảnh (Context Loss / "Out-of-Sight, Out-of-Mind")** | **Thấp.** Tất cả mọi quy tắc, bẫy lỗi, lưu ý đều hiển thị ngay trong tầm mắt của Claude khi đọc SKILL.md. | **Trung bình – Cao.** Claude có xu hướng bỏ qua việc đọc file reference nếu không được chỉ dẫn nghiêm ngặt, dẫn tới việc bỏ lọt các quy tắc chi tiết. | 🔴 **Rủi ro lớn nhất:** Agent có thể kết luận một nhóm là READY trong khi vi phạm quy tắc kỹ thuật nằm trong reference file chưa được nạp. | **ÁP DỤNG CHIẾN LƯỢC PHÒNG THỦ 2 TẦNG:**<br>1. **Tầng 1 — Anchor Summaries trong SKILL.md:** Giữ lại 2–3 dòng tóm tắt quy tắc cốt lõi ngay tại bảng checklist của SKILL.md (VD: *"Fact cấm cdr_dt_dim_id, Fact Snapshot bắt buộc snpst_dt_dim_id"*).<br>2. **Tầng 2 — Deterministic Triggers:** Chỉ dẫn hành động tất định bằng câu lệnh: *"Trước khi đánh giá Lớp 2, BẮT BUỘC dùng tool `view_file` đọc `reference/technical_review_rules.md`"*. |
| **Chi phí Tool Call & Độ trễ (Latency Overhead)** | **Thấp (0 tool call đọc thêm).** Toàn bộ tri thức đã nạp sẵn từ đầu. | **Phát sinh 1–3 tool calls (`view_file`).** Agent phải tốn thêm roundtrips để đọc các reference files khi cần. | 🟡 **Rủi ro nhỏ:** Tăng thời gian phản hồi ở các bước chuyển tiếp giữa các phase do phải đọc file phụ. | Gom nhóm reference theo phase: Ở Bước 0b chỉ đọc `ba_source_profile.md`; Ở Bước 2 Lớp 2 chỉ đọc `technical_review_rules.md`. Không yêu cầu đọc toàn bộ reference cùng lúc. |
| **Khả năng Tuân thủ Quy trình (Instruction Following)** | **Bị phân tán.** Do tài liệu quá dài, chứa nhiều bảng kiểm tra và code script đan xen, Agent dễ bị "nhiễu thông tin", bỏ qua các Gate Rules quan trọng. | **Tập trung cao độ.** SKILL.md chỉ tập trung vào luồng điều phối, Gate Rules nổi bật rõ ràng, không bị chìm trong các chi tiết kỹ thuật thứ yếu. | 🟢 **Lợi ích lớn:** Agent tuân thủ nghiêm ngặt các điểm dừng Gate, không tự ý sửa file trực tiếp, kiểm soát tiến độ chuẩn xác hơn. | Giữ cấu trúc Gate Rules bằng các icon cảnh báo trực quan (`⛔ GATE RULE: DỪNG`). |
| **Tự động hóa qua Script CLI vs Đọc Text** | **Phụ thuộc vào đọc text.** Các đoạn regex grep phức tạp được mô tả bằng text dễ bị Agent chạy sai hoặc bỏ sót. | **Chuyển dịch sang CLI Tooling.** Các quy tắc kỹ thuật phức tạp được đóng gói vào Python script (`datamart_date_fk_checker.py`, `datamart_progress_analyzer.py`). | 🟢 **Độ chính xác tuyệt đối:** Script chạy bằng máy đảm bảo 100% không false positive/negative, không phụ thuộc vào trí nhớ ngữ cảnh của Agent. | SKILL.md hướng dẫn Agent ưu tiên chạy lệnh CLI trước khi thực hiện review thủ công bằng mắt. |

---

### 4. Ma Trận Triệt Tiêu 10 Khối Trùng Lặp Theo Nguyên Tắc Single Source of Truth (SSOT)

```
┌────┬───────────────────────────────────────────────────┬─────────────────────────────────────────────────────────┬─────────────────────────────────────────────────┬────────────────────────────────────────────────────────┐
│ STT│ Khối Nội dung Trùng lặp (Duplicate Block)         │ Các vị trí xuất hiện hiện tại trong SKILL.md/Refs        │ File Quy Chuẩn Duy Nhất (Canonical File)        │ Giải pháp Tinh gọn & Hành động Cụ thể                  │
├────┼───────────────────────────────────────────────────┼─────────────────────────────────────────────────────────┼─────────────────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ 1  │ Quy tắc Role-Playing Date FK trên Fact            │ - SKILL.md: Line 45, 101, 519-531, 555, 971-1013 (5 chỗ)│ reference/role_playing_date_fk_guide.md         │ Thu hồi toàn bộ lý thuyết, bài học GSĐC, mã lỗi và     │
│    │ (Cấm cdr_dt_dim_id, bắt buộc snpst_dt_dim_id...)   │ - review_checklist.md: Lines 55-59, 182-188 (2 chỗ)     │ (File mới)                                      │ remediation protocol về file mới. Trong SKILL.md chỉ   │
│    │                                                   │ - issue_classification.md: Lines 122, 131-143 (2 chỗ)   │                                                 │ giữ 2 dòng Anchor Summary và lệnh gọi checker script.  │
├────┼───────────────────────────────────────────────────┼─────────────────────────────────────────────────────────┼─────────────────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ 2  │ Ma trận Đối soát Tiến độ Chéo (Cross-status)     │ - SKILL.md: Lines 8-10, 79-84, 261-262 (3 chỗ)          │ reference/issue_classification.md (Mục 1)       │ Xóa bảng diễn giải dài trong SKILL.md. SKILL.md chỉ    │
│    │ (BA Status ↔ Datamart Status: Done, Pending...)   │ - review_checklist.md: Lines 21-25 (1 chỗ)              │                                                 │ giữ 1 câu định nghĩa và lệnh chạy script analyzer.     │
│    │                                                   │ - issue_classification.md: Lines 10-35 (1 chỗ)          │                                                 │ Toàn bộ bảng ASCII chuẩn quy về issue_classification.  │
├────┼───────────────────────────────────────────────────┼─────────────────────────────────────────────────────────┼─────────────────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ 3  │ Cây Phân loại 6 Nhánh Nguyên nhân PENDING         │ - SKILL.md: Lines 10, 85-94, 263-269 (3 chỗ)            │ reference/issue_classification.md (Mục 2)       │ Giữ danh sách 6 gạch đầu dòng tên nhánh tại Bước 0b;   │
│    │ (BA Pending, Chưa có map, Thiếu ngoại lai...)     │ - review_checklist.md: Lines 26-33 (1 chỗ)              │                                                 │ Mọi mô tả dấu hiệu, đơn vị chủ trì, hành động tháo gỡ  │
│    │                                                   │ - issue_classification.md: Lines 39-95 (1 chỗ)          │                                                 │ đưa về issue_classification.md làm nơi chuẩn duy nhất. │
├────┼───────────────────────────────────────────────────┼─────────────────────────────────────────────────────────┼─────────────────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ 4  │ Phân loại 5 Kịch bản Phát hiện Vấn đề (A-E)       │ - SKILL.md: Lines 95-114, 721-726 (2 chỗ)               │ reference/issue_classification.md (Mục 3)       │ Trong SKILL.md chỉ giữ Bảng ma trận định tuyến 4 cột   │
│    │ (Dấu hiệu nhận biết, routing skill con)           │ - issue_classification.md: Lines 98-152 (1 chỗ)         │                                                 │ tinh gọn. Phần giải thích sâu từng ca thực tế đưa về   │
│    │                                                   │                                                         │                                                 │ file issue_classification.                             │
├────┼───────────────────────────────────────────────────┼─────────────────────────────────────────────────────────┼─────────────────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ 5  │ Kỹ thuật Đọc BA, Dò Delimiter & Bảng Cột          │ - SKILL.md: Lines 369-425 (Bước 1 - chứa code và bảng)  │ reference/ba_source_profile.md                  │ Xóa bỏ hoàn toàn code Python và bảng cột trong         │
│    │ (Delimiter, Dòng 1 header, hàm read_ba()...)      │ - ba_source_profile.md: Lines 11-76, 80-97, 100-286     │                                                 │ SKILL.md Bước 1. Chỉ thị gọi read_ba() từ reference.   │
│    │                                                   │   (toàn bộ file)                                        │                                                 │ Tiết kiệm ngay ~55 dòng.                               │
├────┼───────────────────────────────────────────────────┼─────────────────────────────────────────────────────────┼─────────────────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ 6  │ Quy tắc An toàn Gate Control & Dừng chờ Phê duyệt │ - SKILL.md: Lines 33-40, 131, 156-168, 282-293, 730-782│ SKILL.md (Mục Quy trình Tổng thể & Gate)        │ Chuẩn hóa quy định Gate Control tại SKILL.md (vì đây   │
│    │ (Gate 0b, Gate sau nhóm, cấm tự sửa file...)      │   (6 chỗ)                                               │                                                 │ là điều phối cốt lõi). Xóa các đoạn diễn giải lặp lại  │
│    │                                                   │ - review_checklist.md: Lines 64, 262-276 (2 chỗ)        │                                                 │ ở các bước con; reference checklist chỉ dẫn link về.   │
├────┼───────────────────────────────────────────────────┼─────────────────────────────────────────────────────────┼─────────────────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ 7  │ Verify Atomic YAML Thật & 2 Nguồn Approved        │ - SKILL.md: Lines 25-26, 77, 563-568, 834-850, 897-903  │ reference/technical_review_rules.md             │ Quy trình grep đếm attribute thật và lệnh cấm LinhLV   │
│    │ (Nguồn 1 Atomic/, Nguồn 2 lld/, cấm LinhLV)       │   (5 chỗ)                                               │ (File mới)                                      │ đưa vào reference mới. SKILL.md chỉ giữ 1 nguyên tắc   │
│    │                                                   │ - review_checklist.md: Lines 133-140 (1 chỗ)            │                                                 │ ngắn gọn.                                              │
├────┼───────────────────────────────────────────────────┼─────────────────────────────────────────────────────────┼─────────────────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ 8  │ Quy tắc Flatten hoàn toàn xuống Atomic            │ - SKILL.md: Lines 101, 549, 854-883 (3 chỗ)             │ reference/technical_review_rules.md             │ SKILL.md Lớp 2 chỉ ghi 1 dòng yêu cầu flatten; Toàn bộ │
│    │ (Cấm fct_*.col, code quét missing join_atomic)    │ - review_checklist.md: Lines 147-150 (1 chỗ)            │ (File mới)                                      │ ví dụ, phân loại và code Python kiểm tra missing join   │
│    │                                                   │ - issue_classification.md: Line 118 (1 chỗ)             │                                                 │ chuyển sang technical_review_rules.md.                 │
├────┼───────────────────────────────────────────────────┼─────────────────────────────────────────────────────────┼─────────────────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ 9  │ Quy chuẩn Physical Naming Exceptions              │ - SKILL.md: Lines 117, 652, 937-970 (3 chỗ)             │ reference/technical_review_rules.md             │ Chuyển hướng dẫn regex và nguyên tắc derive sang       │
│    │ (rule_physical_name_exceptions_datamart.csv...)   │ - review_checklist.md: Lines 164-166, 254 (2 chỗ)       │ (File mới)                                      │ reference mới. SKILL.md chỉ nhắc tên file CSV quy chuẩn│
│    │                                                   │ - issue_classification.md: Line 117 (1 chỗ)             │                                                 │ duy nhất.                                              │
├────┼───────────────────────────────────────────────────┼─────────────────────────────────────────────────────────┼─────────────────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ 10 │ Chép lại 13 Mục Bước 5B HLD và 10 TC Phase 1 LLD  │ - SKILL.md: Lines 465-495 (13 mục), Lines 496-518 (10 TC│ File SKILL.md gốc của datamart-hld-design      │ Thay vì chép lại 2 bảng biểu chiếm gần 60 dòng,        │
│    │ (Bảng kiểm tra kế thừa nguyên văn từ skill khác)  │   (2 chỗ chiếm 60 dòng)                                 │ và datamart-lld-design                          │ SKILL.md chỉ ghi lời gọi thực thi và danh mục mã lỗi   │
│    │                                                   │                                                         │                                                 │ fail nghiêm trọng cần chặn.                            │
└────┴───────────────────────────────────────────────────┴─────────────────────────────────────────────────────────┴─────────────────────────────────────────────────┴────────────────────────────────────────────────────────┘
```

---

### 5. Khung Phác Thảo Cấu Trúc SKILL.md Mới (Target Layout ~320 Dòng)

```markdown
---
name: datamart-review
description: |
  Master Quality Gatekeeper: Review cross-check BA analyst ↔ Datamart (HLD + LLD).
  Hỗ trợ Macro-Review (tiến độ toàn phân hệ), Micro-Review (chi tiết 4 lớp từng nhóm),
  và Issue Trace 5 tầng (Kịch bản E).
triggers:
  - /datamart-review [MODULE]
  - /datamart-review [MODULE] [nhóm N]
---

# Skill: Review Cross-check Datamart (Master Orchestrator)

## 1. QUY ƯỚC AN TOÀN & NGUYÊN TẮC BẤT KHẢ XÂM PHẠM (~30 dòng)
- Claude là Data Model Reviewer độc lập; Human là người phê duyệt tối cao.
- TUYỆT ĐỐI KHÔNG tự Edit trực tiếp HLD/LLD/Registry — Mọi sửa đổi phải qua skill con.
- READ-ONLY trên DataModel/Atomic/ — Tuyệt đối cấm tạo hoặc sửa file Atomic.
- Bắt buộc tuân thủ GATE RULES: Dừng sau Bước 0b, dừng khi có lỗi sau mỗi nhóm.

## 2. MA TRẬN TÀI NGUYÊN & TRIGGER HƯỚNG DẪN (~25 dòng)
| Phân hệ / Tác vụ | Tài liệu Reference bắt buộc | Công cụ CLI tự động hóa |
|---|---|---|
| Khảo sát BA & Tiến độ | reference/ba_source_profile.md | python scripts/datamart_progress_analyzer.py |
| Phân loại Lỗi & Kịch bản | reference/issue_classification.md | — |
| Đối soát Số lượng KPI | reference/kpi_reconciliation_rules.md | scripts/datamart_progress_analyzer.py --detail |
| Kiểm tra Date Dimension FK | reference/role_playing_date_fk_guide.md | python scripts/datamart_date_fk_checker.py |
| Kiểm tra Kỹ thuật Sâu Lớp 2 | reference/technical_review_rules.md | — |
| Checklist Đánh giá Nhanh | reference/review_checklist.md | — |

## 3. NGUYÊN TẮC CỐT LÕI & ĐỊNH TUYẾN 5 KỊCH BẢN (~35 dòng)
- Chuỗi 5 tầng: BA ➔ Source ➔ Atomic ➔ Datamart ➔ Báo cáo.
- Ma trận định tuyến Kịch bản A, B, C, D, E (Bảng 4 cột tinh gọn).
- Quy định bắt buộc: Kịch bản C phải trình bày action đề xuất ➔ Dừng chờ duyệt ➔ Gọi skill con.

## 4. QUY TRÌNH ĐIỀU PHỐI TỔNG THỂ & GATE CONTROL (~40 dòng)
- Sơ đồ ASCII luồng 2 chế độ (Macro vs Micro).
- Chi tiết Gate Rules: Điều kiện DỪNG vs Điều kiện TỰ ĐỘNG CHUYỂN TIẾP.

## 5. BƯỚC 0, 0b & 0c: MACRO-AUDIT TIẾN ĐỘ & LẬP KẾ HOẠCH (~45 dòng)
- Bước 0: File resolution động & chạy CLI progress analyzer.
- Bước 0b: Kiểm tra cấu trúc HLD (5 Section chuẩn, Bảng KPI 7 cột); Đối soát số lượng 1-1 theo reference/kpi_reconciliation_rules.md.
- Bước 0c: Chạy sớm Date FK checker toàn module + 13 mục HLD + 10 TC LLD + Quét chỉ tiêu Delete.
- ⛔ GATE 1: DỪNG chờ Human duyệt kế hoạch review.

## 6. BƯỚC 0-ALT: REVIEW THEO ISSUE/BUG REPORT (KỊCH BẢN E) (~30 dòng)
- Trace nhanh 5 tầng cho lỗi cụ thể.
- Xuất bảng trạng thái per-tầng & xác định root cause blocker.

## 7. BƯỚC 1 & 2: MICRO-REVIEW CHI TIẾT TỪNG NHÓM (4 LỚP CHUẨN) (~65 dòng)
- Đọc BA nhóm N theo reference/ba_source_profile.md.
- Lớp 1 (HLD): Coverage 2 chiều, Grain, Bảng 7 cột, Temporal SQL.
- Lớp 2 (Attributes): Trace BA ➔ Atomic YAML approved ➔ Attributes.
  * Anchor Summary: Cấm cột mart trong etl_logic; Kiểm tra Role-Playing Date FK (reference/role_playing_date_fk_guide.md); Tra cứu kỹ thuật tại reference/technical_review_rules.md.
- Lớp 3 (Detail Mapping): Inline DERIVED (cấm dùng KPI_ID khác); Trace full SQL.
- Lớp 4 (Registry): Khớp 1-1 cột; Phân biệt Boolean direct vs Indicator computed Y/N.
  * Anchor Summary: Entity riêng sync theo Attr; Entity SHARED sync theo YAML approved.

## 8. BƯỚC 3 & 4: TỔNG HỢP VẤN ĐỀ, BACKLOG & CHUYỂN GIAO (~30 dòng)
- Xuất Bảng chi tiết vấn đề & Bảng Action items.
- Quy tắc PENDING ➔ READY (bắt buộc review lại 3 lớp ngay).
- Chuyển giao sang skill con (`datamart-hld-design`, `datamart-lld-design`).
```

---

### 6. Lộ Trình Triển Khai Refactor (4 Giai Đoạn Chuẩn)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       LỘ TRÌNH REFACTOR SKILL.MD                            │
├─────────────────────────────────────────────────────────────────────────────┤
│ Giai đoạn 1: Chuẩn bị & Tạo mới 3 Reference Files                           │
│   - Tạo `reference/role_playing_date_fk_guide.md`                           │
│   - Tạo `reference/technical_review_rules.md`                               │
│   - Tạo `reference/kpi_reconciliation_rules.md`                             │
│   - Cập nhật bổ sung `issue_classification.md` & `ba_source_profile.md`     │
├─────────────────────────────────────────────────────────────────────────────┤
│ Giai đoạn 2: Biên tập Bản thảo Tinh gọn `SKILL_v2.md`                       │
│   - Soạn thảo `SKILL_v2.md` theo khung phác thảo Mục 5                      │
│   - Thiết lập các Anchor Summaries và Deterministic Triggers                │
│   - Rà soát tính đầy đủ của các Gate Rules                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│ Giai đoạn 3: Kiểm định Độc lập & Dry-Run (Audit & Testing)                  │
│   - Chạy thử nghiệm review trên 2 module thực tế (1 module có file gộp      │
│     như GSĐC và 1 module phân tách delimiter như GSTT/NHNCK)                │
│   - Đánh giá khả năng điều hướng tool call của Claude Code khi đọc reference│
├─────────────────────────────────────────────────────────────────────────────┤
│ Giai đoạn 4: Đóng gói & Release Chính thức                                  │
│   - Backup `SKILL.md` cũ thành `SKILL_backup_20260909.md`                   │
│   - Đổi tên `SKILL_v2.md` thành `SKILL.md` chính thức                       │
│   - Cập nhật tài liệu hướng dẫn và thông báo cho toàn đội ngũ               │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## (B) DANH SÁCH DECISIONS ĐÃ CHỐT

1. **Phê duyệt Kiến trúc Hub & Spokes**: Tinh giản `SKILL.md` đóng vai trò Master Orchestrator (~320 dòng, ~27KB), tách các tri thức kỹ thuật tra cứu tĩnh ra thư mục `reference/`.
2. **Quyết định tạo 3 Reference Files mới**:
   - `reference/role_playing_date_fk_guide.md`
   - `reference/technical_review_rules.md`
   - `reference/kpi_reconciliation_rules.md`
3. **Quyết định giữ lại trong `SKILL.md`**:
   - Toàn bộ các nguyên tắc an toàn cốt lõi (Cấm tự edit, Read-only Atomic).
   - Quy trình điều phối các bước (0, 0b, 0c, 0-ALT, 1, 2, 3, 4).
   - Hệ thống Gate Control (điều kiện Dừng vs Tự động chuyển tiếp).
   - Bảng tóm tắt 4 lớp kiểm tra tại Bước 2 kèm Anchor Summaries.
4. **Phê duyệt Chiến lược Phòng thủ 2 Tầng chống mất ngữ cảnh**:
   - Tầng 1: Anchor Summaries (2–3 dòng tóm tắt quy tắc sống còn ngay tại SKILL.md).
   - Tầng 2: Deterministic Triggers (yêu cầu Agent gọi tool `view_file` đọc reference trước khi đánh giá Lớp).
5. **Triệt tiêu 10 khối trùng lặp theo ma trận SSOT**: Không sao chép các đoạn code parser, bảng 13 mục HLD, 10 TC LLD hay lý thuyết Kimball vào nhiều nơi; mỗi quy tắc chỉ được lưu trữ tại một file quy chuẩn duy nhất.

---

## (C) DANH SÁCH OPEN ITEMS CHƯA HOÀN THÀNH (CẦN Ý KIẾN LEAD / BA)

1. **Phê duyệt chính thức của Tech Lead về việc tách file:**
   - *Nội dung:* Xác nhận cấu trúc 3 reference files mới và ngân sách dòng ~320 dòng cho `SKILL.md`.
2. **Quy định về việc lưu trữ các đoạn mã Python mẫu trong Reference:**
   - *Nội dung:* Các đoạn mã Python (quét missing `join_atomic`, verify YAML parse, verify CSV len) nên tiếp tục để dạng Markdown code block trong `technical_review_rules.md` hay nên đóng gói hẳn thành các hàm utility trong thư mục `scripts/`?
3. **Thứ tự ưu tiên triển khai refactor:**
   - *Nội dung:* Tiến hành refactor `SKILL.md` trước hay vá các bugs trong 2 Python scripts (R3) trước?

---

## (D) HƯỚNG DẪN CỤ THỂ CHO AGENT SESSION MỚI TIẾP TỤC

Khi nhận lệnh triển khai tái cấu trúc skill sau khi được phê duyệt, Agent kế tiếp hãy tuân thủ nghiêm ngặt 4 bước sau:

1. **Bước 1 — Tạo 3 Reference Files Mới (Không đụng vào SKILL.md hiện tại):**
   - Tạo file `reference/role_playing_date_fk_guide.md`: Cắt nội dung từ Section 19 của `SKILL.md` (dòng 971–1013), bổ sung chuẩn Degenerate Date.
   - Tạo file `reference/technical_review_rules.md`: Cắt nội dung từ Section 17 & 18 (dòng 818–970), bổ sung 2 tiêu chí SCD4A (`ds_rcrd_st = 'ACTIVE'`).
   - Tạo file `reference/kpi_reconciliation_rules.md`: Cắt và chuẩn hóa thuật toán đối soát 2 tầng từ Bước 0b.3.
2. **Bước 2 — Cập nhật 3 Reference Files Hiện Hữu:**
   - Bổ sung trạng thái `Delete` và ma trận đối soát ASCII vào `reference/issue_classification.md`.
   - Chuẩn hóa vị trí header dòng 1 và hàm `read_ba()` trong `reference/ba_source_profile.md`.
   - Cập nhật checklist 4 lớp trong `reference/review_checklist.md` khớp 100% với các reference mới.
3. **Bước 3 — Soạn thảo `SKILL_v2.md`:**
   - Viết file nháp `SKILL_v2.md` tuân thủ đúng khung cấu trúc ~320 dòng tại Mục (A).5.
   - Nhúng đầy đủ Anchor Summaries và Deterministic Triggers tại Bước 2.
4. **Bước 4 — Chạy Thử Nghiệm & Hoán Đổi (Dry-Run & Release):**
   - Chạy thử nghiệm lệnh review trên module `GSĐC` và `GSTT`.
   - Khi kết quả kiểm định đạt yêu cầu: Lưu backup `SKILL.md` cũ và đổi tên `SKILL_v2.md` thành `SKILL.md`.
