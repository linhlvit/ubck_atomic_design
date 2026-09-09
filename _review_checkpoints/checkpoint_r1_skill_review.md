# CHECKPOINT R1 — ĐÁNH GIÁ TOÀN DIỆN SKILL.MD VÀ QUY TRÌNH REVIEW
## Dự án: Review và Chuẩn hóa Skill `datamart-review` (UBCKNN Atomic Design)

- **Mã tài liệu:** `CHECKPOINT-R1-SKILL-REVIEW`
- **Phiên bản:** 1.0 (Chính thức)
- **Ngày lập:** 2026-09-09
- **Đối tượng khảo sát:** `.claude/skills/datamart-review/SKILL.md` (1013 dòng, ~86KB) và 3 tài liệu tham chiếu (`review_checklist.md`, `issue_classification.md`, `ba_source_profile.md`).
- **Trạng thái:** Hoàn thành rà soát R1, sẵn sàng cho công tác chuẩn hóa & refactor.

---

## (A) TÓM TẮT FINDINGS CHI TIẾT

Qua quá trình rà soát độc lập, đối soát từng dòng (line-by-line) giữa `SKILL.md` và 3 tài liệu tham chiếu, ghi nhận 4 nhóm phát hiện kỹ thuật cốt lõi:

---

### 1. Chi tiết 8 Điểm Mâu Thuẫn Nội Tại (Internal Contradictions)

#### Mâu thuẫn 1: Delimiter & Cách thức Parse file BA CSV (Gán cứng `;` vs Dò động `,` và `;`)
- **Vị trí 1 (Gán cứng `;`):** `SKILL.md`, dòng 370–385 (Bước 1 — Đọc BA):
  > `> **Lưu ý kỹ thuật — delimiter:**`  
  > `> - **BA CSV** (BA_analyst_*.csv): dùng delimiter=';'`  
  > `with open('BRD/BA/BA_analyst_{MODULE}_partN.csv', encoding='utf-8-sig') as f:`  
  > `    reader = csv.reader(f, delimiter=';')`
- **Vị trí 2 (Tự động dò cả 2 loại):** `SKILL.md`, dòng 49 (Tài nguyên đi kèm), dòng 189 (Bước 0), dòng 401–403 (Bước 1):
  > Dòng 49: `"...phân bổ delimiter (6 file ',' và 5 file ';')..."`  
  > Dòng 189: `"Dò delimiter (',' hoặc ';'), encoding utf-8-sig/BOM, và header row."`  
  > Dòng 401–403: `"Bắt buộc: đọc reference/ba_source_profile.md và dùng hàm read_ba() trong đó — resolve cột theo tên header, không theo vị trí."`
- **Phân tích xung đột logic:**
  Đoạn code mẫu tại dòng 382–385 trực tiếp chỉ thị Reviewer dùng `delimiter=';'` và đọc file theo mẫu cũ `_partN.csv`. Trong thực tế repo và tài liệu `reference/ba_source_profile.md`, có **6 phân hệ dùng dấu phẩy `,`** (`QLCB`, `GSĐC`, `PTTT`, `GSTT`, `QLKD`, `TKNB`) và chỉ có 5 phân hệ dùng `;`. Đồng thời, các file `partN.csv` của GSĐC đã bị xóa và thay bằng file gộp `BA_analyst_GSĐC.csv`. Nếu Reviewer sao chép đoạn code ở dòng 382–385 để đọc file của GSĐC hay GSTT, `csv.reader` với `;` sẽ coi toàn bộ dòng là 1 cột duy nhất, làm sập hoàn toàn quy trình phân tích.
- **Giải pháp xử lý dứt điểm:**
  Xóa bỏ hoàn toàn đoạn văn bản và code mẫu gán cứng `;` tại dòng 370–385. Thay bằng hướng dẫn chuẩn hóa: Sử dụng trực tiếp script `scripts/datamart_progress_analyzer.py` hoặc snippet `read_ba()` từ `reference/ba_source_profile.md` có tích hợp hàm `detect_delimiter_and_header()`.

---

#### Mâu thuẫn 2: Vị trí Dòng Header của file `BA_analyst_GSĐC.csv` (Dòng 0 vs Dòng 1)
- **Vị trí 1 (Bảo dòng 0):** `SKILL.md`, dòng 397–399 (Bước 1 — Lưu ý chỉ số cột):
  > `> 🔴 KHÔNG hard-code chỉ số cột. Khảo sát 2026-08-22 cho thấy 13 file BA có 8 biến thể số cột khác nhau (23→31 cột), header nằm ở dòng 0 với GSDC nhưng dòng 1 với 10 file còn lại...`
- **Vị trí 2 (Khẳng định dòng 1 cho toàn bộ 11 file):** `SKILL.md`, dòng 49 và `reference/ba_source_profile.md`, dòng 13–18:
  > Dòng 49: `"...cấu trúc THẬT của BRD/BA/*.csv: header nằm dòng nào (dòng 1 cho cả 11 file)..."`  
  > `ba_source_profile.md` dòng 15: `"Toàn bộ 11 file hiện hành (FMS, GSTT, GSĐC, NDTNN, NHNCK, PTTT, QLCB, QLKD, TKNB, TT, VP) | Dòng 1 (0-indexed: index 1) | Dòng 2 (index 2)"`
- **Phân tích xung đột logic:**
  Dòng 398 của `SKILL.md` vẫn giữ tàn dư mô tả cũ khi GSĐC còn là 3 file `part1/2/3.csv` (dòng 0 là header). Sau đợt chuẩn hóa gộp thành `BA_analyst_GSĐC.csv`, dòng 0 của file gộp là ô merge Excel tiêu đề báo cáo, header thật đã chuyển xuống **dòng 1** (khớp với 10 file còn lại). Dòng 49 trong SKILL.md đã ghi nhận điều này, nhưng dòng 398 chưa được đồng bộ, gây hoang mang cho Reviewer.
- **Giải pháp xử lý dứt điểm:**
  Sửa dòng 398 của `SKILL.md`: Khẳng định 100% file BA hiện hành có header nằm ở **dòng 1** (0-indexed: index 1). Dòng 0 là tiêu đề Excel/merge cells cần bỏ qua.

---

#### Mâu thuẫn 3: Số Lớp Review trong Tiêu đề Bước 2 ("3 LỚP" vs Thực tế 4 Lớp + 1b + 2b)
- **Vị trí 1 (Ghi 3 lớp):** `SKILL.md`, dòng 438, dòng 783, dòng 790, dòng 798:
  > Dòng 438: `"## BƯỚC 2 — REVIEW TỪNG NHÓM (3 LỚP)"`  
  > Dòng 790: `"[BẮT BUỘC: Chạy review lại 3 lớp ngay sau khi READY]"`  
  > Dòng 798: `"...Review 3 lớp sau khi READY là bước bắt buộc..."`
- **Vị trí 2 (Định nghĩa 4 lớp chi tiết):** `SKILL.md`, dòng 11–12, dòng 47, dòng 137–146, dòng 633–675:
  > Dòng 11: `"Micro-Review (Chi tiết kỹ thuật từng nhóm): Đi sâu 4 lớp (HLD → Attributes → Detail Mapping → Registry)"`  
  > Dòng 141–146: `"Lớp 1: HLD ... Lớp 2: Attributes ... Lớp 3: Detail Mapping ... Lớp 4: datamart_model.yaml"`  
  > Dòng 633: `"### Lớp 4: Review datamart_model.yaml (Registry cross-module)"`
- **Phân tích xung đột logic:**
  Tiêu đề Bước 2 ghi `(3 LỚP)`, nhưng nội dung bên dưới triển khai chi tiết 4 lớp: Lớp 1 (HLD), Lớp 2 (Attributes), Lớp 3 (Detail Mapping), Lớp 4 (`datamart_model.yaml`). Chưa kể, bên dưới Bước 2 còn chèn thêm Lớp 1b (dòng 465) và Lớp 2b (dòng 497). Tại dòng 783–802 (Quy tắc PENDING → READY), văn bản ghi "Chạy review lại 3 lớp" nhưng chỉ liệt kê Lớp 2 và Lớp 3, hoàn toàn bỏ quên Lớp 4 (Registry).
- **Giải pháp xử lý dứt điểm:**
  Đổi tiêu đề dòng 438 thành: `## BƯỚC 2 — MICRO-REVIEW CHI TIẾT TỪNG NHÓM (4 LỚP CHUẨN)`. Cập nhật dòng 790 thành: "Chạy review lại cả 3 lớp LLD (Lớp 2: Attributes, Lớp 3: Detail Mapping, Lớp 4: Registry)".

---

#### Mâu thuẫn 4: Vị trí của Lớp 1b và Lớp 2b (Bước 0c cấp Toàn Module vs Bước 2 Lặp từng Nhóm)
- **Vị trí 1 (Thuộc Macro-Review Bước 0c, chạy 1 lần trước khi duyệt kế hoạch):** `SKILL.md`, dòng 132 (Sơ đồ tổng thể):
  > Dòng 132: `"Bước 0c: [1 lần/module] Chạy Lớp 1b (13 mục Bước 5B) + Lớp 2b (10 TC Phase 1 + Validate Date FK)"` (Nằm trọn vẹn trong khung Macro-Review, trước mũi tên "Human duyệt kế hoạch").
- **Vị trí 2 (Bị đặt bên trong Bước 2 - Micro-Review từng nhóm):** `SKILL.md`, dòng 465–494 và dòng 497–533:
  > Nằm dưới `## BƯỚC 2 — REVIEW TỪNG NHÓM (3 LỚP)`:  
  > Dòng 465: `"### Lớp 1b: Chạy lại 13 mục Bước 5B của datamart-hld-design (bắt buộc, 1 lần/module)"`  
  > Dòng 497: `"### Lớp 2b: Chạy lại 10 TC Phase 1 của datamart-lld-design (bắt buộc, 1 lần/module)"`
- **Phân tích xung đột logic:**
  Sơ đồ tổng thể định vị Lớp 1b và Lớp 2b là `Bước 0c` thuộc Chế độ 1 (Macro-Review), được chạy 1 lần duy nhất cho toàn module trước khi Gate Rule 0b chặn lại chờ human phê duyệt. Tuy nhiên, trong phần thuyết minh từng bước, hoàn toàn không có đề mục `## BƯỚC 0c`. Thay vào đó, Lớp 1b và Lớp 2b lại bị đặt nằm lọt thỏm bên trong `Bước 2` (vòng lặp từng nhóm). Vị trí này mâu thuẫn trực tiếp với bản chất của Lớp 1b và 2b (quét Section 1, Section 3 của HLD và master Attributes), khiến Reviewer bối rối không biết nên chạy ở Bước 0 hay chờ vào Bước 2 mới chạy.
- **Giải pháp xử lý dứt điểm:**
  Tách hẳn Lớp 1b và Lớp 2b ra khỏi Bước 2, tạo thành mục chuẩn hóa: `## BƯỚC 0c — KIỂM ĐỊNH TOÀN DIỆN CẤP TOÀN MODULE (HLD 13 MỤC & LLD 10 TC)` nằm ngay sau Bước 0b trong Chế độ 1.

---

#### Mâu thuẫn 5: Quyền Sửa File Trực tiếp ở Lớp 4 (Cấm tuyệt đối Edit trực tiếp vs Hướng dẫn tự sửa Registry)
- **Vị trí 1 (Cấm tuyệt đối tự Edit file trực tiếp):** `SKILL.md`, dòng 38, 108–114, 725, 779:
  > Dòng 38: `"QUYẾT ĐỊNH CỨNG: Claude TUYỆT ĐỐI KHÔNG tự Edit trực tiếp vào file HLD, LLD (Attributes.csv, Detail_Mapping.csv) hay Model Registry (datamart_model.yaml)..."`  
  > Dòng 108: `"Kịch bản C cũng đi qua skill con (chốt 2026-08-22) — trước đây C được phép 'sửa tay trực tiếp', nay KHÔNG còn..."`  
  > Dòng 779: `"Claude KHÔNG ĐƯỢC tự sửa file — kể cả lỗi nhỏ (Info), phải hỏi human trước và gọi skill con"`
- **Vị trí 2 (Trực tiếp chỉ thị Claude sửa file `datamart_model.yaml`):** `SKILL.md`, dòng 668 và dòng 676–682:
  > Dòng 668: `"Bước D: Sửa registry theo Attributes (nguồn hiện tại luôn là Attributes detail — registry chỉ tổng hợp)"`  
  > Dòng 676–682: `"Sau khi sửa registry — verify YAML còn hợp lệ: import yaml ... with open('Datamart/datamart_model.yaml') ..."`
- **Phân tích xung đột logic:**
  Toàn bộ các nguyên tắc cốt lõi của skill đều khẳng định `datamart-review` là **Read-Only Explorer**, tuyệt đối không được tự ý sửa bất kỳ file nào (kể cả lỗi kỹ thuật Kịch bản C), mọi việc sửa phải thông qua skill con `datamart-lld-design`. Nhưng tại dòng 668 và 676 ở Lớp 4, tài liệu lại viết: "Bước D: Sửa registry theo Attributes... Sau khi sửa registry — verify YAML còn hợp lệ". Đây là tàn dư cũ chưa được làm sạch khi đổi quy tắc ngày 2026-08-22, tạo tiền lệ để AI tự ý chỉnh sửa file registry ngoài tầm kiểm soát.
- **Giải pháp xử lý dứt điểm:**
  Sửa dòng 668 thành: "Bước D: Trình bày action đề xuất đồng bộ registry cụ thể (entity, attribute, type cũ → mới) → DỪNG chờ human phê duyệt → Gọi `datamart-lld-design` để cập nhật registry". Sửa dòng 676 thành: "Sau khi `datamart-lld-design` hoàn tất cập nhật registry — Reviewer chạy script verify YAML còn hợp lệ".

---

#### Mâu thuẫn 6: Công thức Đối soát Số lượng BA ↔ HLD (False Alarm do Trạng thái PENDING)
- **Vị trí 1 (Số dòng BA chỉ đếm Done/Doing):** `SKILL.md`, dòng 247 (Bước 0b.3):
  > `Số dòng BA = COUNT(dòng BA trong nhóm, Phân loại ∈ {Chiều, Chỉ tiêu cơ sở, Chỉ tiêu phái sinh}, Trạng thái mapping ∈ {Done, Doing})`
- **Vị trí 2 (Số dòng HLD đếm toàn bộ KPI_ID trong bảng 7 cột gồm cả PENDING):** `SKILL.md`, dòng 220, dòng 234–235, dòng 248:
  > Dòng 220: `"Đếm số dòng KPI_ID trong bảng KPI của nhóm đó (loại trừ dòng _YOY/derived thuần...)"`  
  > Dòng 234–235: `"Chuẩn 7 cột thay thế hoàn toàn format cũ... Dòng READY và PENDING nằm CHUNG 1 bảng, phân biệt bằng cột Trạng thái."`  
  > Dòng 248: `"Số dòng KPI HLD = COUNT(KPI_ID trong bảng KPI của nhóm, loại trừ _YOY/derived thuần trong cùng bảng)"`
- **Phân tích xung đột logic:**
  Từ ngày 2026-07-23, chuẩn thiết kế HLD đã gộp toàn bộ các chỉ tiêu PENDING vào chung bảng KPI 7 cột (có cột `Trạng thái = PENDING`). Công thức tại dòng 248 đếm TỔNG SỐ dòng `KPI_ID` trong bảng HLD (bao gồm cả dòng READY lẫn dòng PENDING). Tuy nhiên, công thức đếm `Số dòng BA` ở dòng 247 lại chỉ lọc các dòng có `Trạng thái mapping ∈ {Done, Doing}` (loại bỏ hoàn toàn các dòng Pending của BA). Hậu quả: Nếu một nhóm trong BA có 10 chỉ tiêu Done và 4 chỉ tiêu Pending, HLD thiết kế đúng chuẩn sẽ có đủ 14 KPI_ID (10 READY + 4 PENDING). Khi áp dụng công thức 0b.3: `Số dòng BA` = 10, nhưng `Số dòng HLD` = 14 -> **Hệ thống luôn luôn báo "🔴 Lệch số lượng" sai thực tế (False Alarm)**!
- **Giải pháp xử lý dứt điểm:**
  Chuẩn hóa lại công thức đối soát số lượng 0b.3 thành 2 chế độ đối soát song song:
  1. **Đối soát Tổng thể (Total Scope):**  
     `Số dòng BA Tổng = COUNT(BA có Phân loại hợp lệ và Trạng thái ≠ Delete)`  
     `Số dòng HLD Tổng = COUNT(Mọi KPI_ID trong bảng 7 cột, loại trừ _YOY)`  
     -> Bắt buộc khớp 1-1 (bao gồm cả PENDING).
  2. **Đối soát Khả dụng (Ready Scope):**  
     `Số dòng BA Done/Doing` khớp với `Số dòng HLD có Trạng thái = READY`.

---

#### Mâu thuẫn 7: Mức độ Nghiêm trọng của Thiếu Section 4 Reuse Analysis (Critical vs Warning)
- **Vị trí 1 (Xếp loại 🔴 Critical):** `SKILL.md`, dòng 232 (Bước 0b.2) và dòng 477 (Lớp 1b Mục #0):
  > Dòng 232: `"Thiếu hẳn Section 4 Reuse Analysis, hoặc 'Vấn đề mở' đang chiếm nhầm vị trí Section 4 → 🔴 Critical cấp toàn module..."`  
  > Dòng 477: `"Mục 0: Cấu trúc 5 Section đúng chuẩn section_structure.md → 🔴 Critical"`
- **Vị trí 2 (Xếp loại 🟡 Warning):** `SKILL.md`, dòng 698 (Bảng chi tiết vấn đề mẫu):
  > Dòng 698: `"| 5 | Toàn module | HLD | 🟡 Warning | Thiếu Section 4 Reuse Analysis, heading Cụm sai cấp | C | Trình action đề xuất → gọi datamart-hld-design chuẩn hóa cấu trúc HLD.md |"`
- **Phân tích xung đột logic:**
  Cùng một hành vi "Thiếu Section 4 Reuse Analysis", ở bước kiểm tra cấu trúc (dòng 232 và 477) khẳng định là lỗi **🔴 Critical cấp toàn module**, nhưng trong bảng tổng hợp mẫu (dòng 698) lại hạ xuống mức **🟡 Warning**. Sự không nhất quán này dẫn đến việc áp dụng tùy tiện: Critical thì phải chặn Gate, Warning thì có thể bỏ qua.
- **Giải pháp xử lý dứt điểm:**
  Thống nhất: Thiếu hẳn Section 4 hoặc phá vỡ cấu trúc 5 Section chuẩn là **🔴 Critical** (vì vi phạm chuẩn tài liệu PTTK/TKCSLD). Chỉ xếp **🟡 Warning** khi Section 4 đã tồn tại nhưng thiếu sót một vài dòng bảng Fact/Dim.

---

#### Mâu thuẫn 8: Cú pháp Mệnh đề JOIN Date FK giữa Attributes và Detail Mapping
- **Vị trí 1 (Attributes JOIN theo giá trị ngày nghiệp vụ):** `SKILL.md`, dòng 984:
  > `ETL Logic: LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt = <driving_table>.ds_snpst_dt`
- **Vị trí 2 (Detail Mapping JOIN theo khóa Surrogate Key):** `SKILL.md`, dòng 1010:
  > `Detail Mapping: ...mệnh đề JOIN LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt_dim_id = <fact>.<role>_dt_dim_id`
- **Vị trí 3 (Quy tắc kiểm tra vế trái lookup):** `SKILL.md`, dòng 551:
  > `"lookup_dim/join_atomic — vế trái phải là cột Datamart thật... Với mọi dòng etl_logic_type ∈ {lookup_dim, join_atomic} viết dạng LOOKUP {dim_table} ON {dim_table}.{col} = ... {col} phải là 1 datamart_column thật trong Attributes của chính {dim_table} đó..."`
- **Phân tích xung đột logic:**
  Trong Lớp 2 (Attributes), `etl_logic` mô tả quá trình ETL từ Atomic lên Datamart: bảng Fact tra cứu vào Dimension ngày bằng trường ngày tự nhiên (`cdr_dt = driving.date`) để lấy ra surrogate key `<role>_dt_dim_id`. Trong Lớp 3 (Detail Mapping), `logic` mô tả truy vấn báo cáo từ Datamart: bảng Fact kết nối với Dimension ngày bằng chính surrogate key (`cdr_dt_dim_id = fact.<role>_dt_dim_id`). Do tài liệu ở dòng 551 không giải thích rõ ngữ cảnh phân tầng, Reviewer thường áp dụng nhầm quy tắc của Detail Mapping vào Attributes, dẫn đến việc bắt bẻ sai `cdr_dt` (cho rằng vế trái phải là `cdr_dt_dim_id`).
- **Giải pháp xử lý dứt điểm:**
  Tách bạch rõ ràng trong hướng dẫn:
  - Tại **Attributes (Lớp 2)**: Vế trái của `LOOKUP cdr_dt_dim` là cột ngày tự nhiên `cdr_dt`.
  - Tại **Detail Mapping (Lớp 3)**: Vế trái của `LOOKUP cdr_dt_dim` là khóa chính `cdr_dt_dim_id`.

---

### 2. Chi tiết 7 Cụm Trùng Lặp Lớn & Đề Xuất Canonical Location

| STT | Quy tắc / Nội dung Trùng lặp | Các Vị trí Xuất hiện trong SKILL.md (Line numbers) | Nội dung Trích dẫn Tóm tắt | Đề xuất Canonical Location (SSOT duy nhất) |
|:---:|---|---|---|---|
| **1** | **Quy tắc Role-Playing Date FK trên Fact** | - Dòng 45 (Tài nguyên)<br>- Dòng 101 (Kịch bản C)<br>- Dòng 519–532 (Lớp 2b)<br>- Dòng 555 (Lớp 2)<br>- Dòng 972–1013 (Mục riêng) | Cấm `cdr_dt_dim_id` trên Fact; Fact Snapshot bắt buộc `snpst_dt_dim_id`; Fact Event dùng `<role>_dt_dim_id`; chạy script date checker; mã lỗi `L2-DATE-FK-ROLE-PLAYING`. | **Chuyển thành `reference/role_playing_date_fk_guide.md`.** Tại Lớp 2 và Lớp 2b của `SKILL.md` chỉ giữ 1 dòng Anchor Summary và dẫn link tham chiếu. |
| **2** | **Nguồn tra cứu Atomic hợp lệ & Cấm `Atomic_LinhLV`** | - Dòng 25–26 (Input)<br>- Dòng 563–566 (Lớp 2 Bước B)<br>- Dòng 844–849 (Lưu ý)<br>- Dòng 897 (Verify YAML) | Nguồn 1: `DataModel/Atomic/**/*.yaml` (ưu tiên cao nhất); Nguồn 2: `DataModel/working/Atomic/lld/**/*.yaml`; Cấm tuyệt đối `Atomic_LinhLV/` (track cũ đã revert). | **Định nghĩa tại `reference/technical_review_rules.md` (hoặc Lớp 2 Bước B).** Tất cả các vị trí khác chỉ ghi "2 nguồn Atomic chuẩn, cấm LinhLV [xem Technical Rules]". |
| **3** | **Flatten hoàn toàn xuống Atomic (Cấm dùng cột mart)** | - Dòng 101 (Kịch bản C)<br>- Dòng 549–550 (Bảng Lớp 2)<br>- Dòng 854–883 (Mục riêng) | `etl_logic` không được dùng `fct_*.col`, phải inline xuống Atomic; đếm `atomic_table` distinct; thiếu `join_atomic` là Critical. | **`reference/technical_review_rules.md` (kèm đoạn mã kiểm tra missing join).** Tại bảng kiểm tra Lớp 2 dòng 549 chỉ cần dẫn link tham chiếu. |
| **4** | **Verify Atomic YAML approved thật trước khi READY** | - Dòng 77–78 (Nguyên tắc)<br>- Dòng 547 (Bảng Lớp 2)<br>- Dòng 889–904 (Mục riêng) | Không tin Attributes ghi gì; mở YAML approved đếm attribute thật; kiểm tra physical_name thật; tránh suy diễn tên hợp lý. | **`reference/technical_review_rules.md`.** Rút gọn dòng 77–78 thành nguyên tắc ngắn gọn dẫn link xuống mục chi tiết. |
| **5** | **Gate Rule & Quy trình Xử lý Kịch bản C** | - Dòng 38 (Quy ước cứng)<br>- Dòng 101, 108–114 (Mục 4)<br>- Dòng 156–168 (Gate Rule)<br>- Dòng 725 (Bước 4)<br>- Dòng 730–772 (Gate Control) | Cấm tự Edit file; trình bày action đề xuất; Claude DỪNG chờ human phê duyệt; gọi skill con thực hiện. | **Mục QUY TRÌNH TỔNG THỂ & GATE CONTROL trong `SKILL.md`.** Xóa bỏ các đoạn giải thích dài dòng lặp lại ở dòng 108–114 và các bước con. |
| **6** | **Đọc sâu SQL BA & Temporal Financial Metrics (TTM)** | - Dòng 345–356 (Bước 0-ALT)<br>- Dòng 457 (Bảng Lớp 1)<br>- Dòng 604–613 (Lớp 3)<br>- Dòng 920–935 (Lưu ý TTM) | Trích xuất logic temporal ẩn: TTM 4 quý, rolling N phiên, rn=1, gate count=4, BCTC ưu tiên HN>TH>ME>RI; Flow metric vs Stock metric. | **`reference/technical_review_rules.md` (Mục Phân biệt Flow vs Stock Metric).** Các vị trí ở Lớp 1, Lớp 3 chỉ giữ tiêu chí kiểm tra tóm tắt. |
| **7** | **Cấu trúc 5 Section HLD & Bảng KPI 7 Cột** | - Dòng 101 (Kịch bản C)<br>- Dòng 224–236 (Bước 0b.2)<br>- Dòng 477, 485 (Lớp 1b) | HLD đủ 5 Section (Lineage, Tổng quan, Mô hình, Reuse, Vấn đề mở); bảng KPI đúng 7 cột có cột Trạng thái; cấm tách block READY/PENDING. | **Bước 0b.2 trong `SKILL.md`.** Lớp 1b chỉ cần liệt kê mục kiểm tra #0 mà không cần diễn giải lại định nghĩa 5 Section. |

---

### 3. Chi tiết 7 Lỗ Hổng / Thiếu Sót Lớn (Gaps & Impact Assessment)

#### Gap 1: Hoàn toàn Thiếu Cơ chế Kiểm tra Chỉ tiêu bị Xóa (`Delete` / `DELETED` / `Xóa`) trong SKILL.md
- **Mô tả chi tiết:**  
  Trong thực tế phân tích nghiệp vụ, BA thường xuyên cập nhật trạng thái `Delete`, `DELETED`, `Xóa` cho các chỉ tiêu không còn sử dụng hoặc bị hủy bỏ. Tài liệu `reference/issue_classification.md` (dòng 29) và `reference/review_checklist.md` (dòng 81, 189, 228) xếp việc chỉ tiêu Delete còn tồn tại trong Datamart là **"🔴 Vi phạm cấm kỵ" (Critical)**. Tuy nhiên, trong `SKILL.md`:
  - Mục Ma trận đối soát (dòng 81–84) và Bước 1 (dòng 413) **hoàn toàn không có từ `Delete` nào**.
  - Bước 0b.3 và Lớp 1/2/3 không hề có bước quét chủ động: "Lấy danh sách các chỉ tiêu BA có status = Delete để verify rằng chúng đã bị xóa triệt để khỏi HLD, Attributes và Detail Mapping".
- **Đánh giá tác động (Impact Assessment):** 🔴 **HIGH**  
  Gây lãng phí tài nguyên phát triển ETL, sinh ra các bảng/cột rác mồ côi trong DWH, và nguy hiểm nhất là làm sai lệch số liệu báo cáo nếu báo cáo vẫn lấy dữ liệu từ chỉ tiêu đã bị nghiệp vụ bãi bỏ.
- **Đề xuất bổ sung:**  
  Bổ sung trạng thái `Delete` vào Ma trận đối soát tại Mục 2 của `SKILL.md`. Thêm bước kiểm tra bắt buộc tại Lớp 1, Lớp 2 và Lớp 3: Quét tập hợp các chỉ tiêu `Delete` từ BA, xác nhận không có bất kỳ KPI_ID, Attribute hay Detail Mapping nào tồn tại cho các chỉ tiêu này.

---

#### Gap 2: Thiếu Quy tắc Kiểm tra Trường Kỹ thuật SCD4A và JOIN Active Filter trên Lớp 2 trong SKILL.md
- **Mô tả chi tiết:**  
  Toàn bộ kho dữ liệu Atomic và Datamart của dự án vận hành theo chuẩn SCD4A. Trong `reference/review_checklist.md` (dòng 168–176), có 2 mục kiểm định sống còn:
  1. `L2-SCD4A-TECH-FIELD`: Bảng Dimension/Operational phải có đủ bộ trường kỹ thuật (`ds_rcrd_st`, `ds_rcrd_isrt_dt`, `ds_rcrd_udt_dt`, `ds_etl_pcs_tms`, và `ds_snpst_dt` đối với history).
  2. `L2-SCD4A-JOIN-FILTER`: Mọi mệnh đề JOIN tới bảng Fundamental Atomic bắt buộc phải có điều kiện `AND <atomic_table>.ds_rcrd_st = 'ACTIVE'`.  
  Tuy nhiên, trong bảng kiểm tra Lớp 2 của `SKILL.md` (dòng 543–557), **hoàn toàn không có 2 tiêu chí này**.
- **Đánh giá tác động (Impact Assessment):** 🔴 **HIGH**  
  Nếu thiếu điều kiện `ds_rcrd_st = 'ACTIVE'`, câu lệnh JOIN Atomic sẽ bị nhân đôi số dòng (fanout duplicate) do bảng nguồn chứa cả bản ghi lịch sử lẫn bản ghi active. Lỗi này làm sai lệch toàn bộ các chỉ tiêu đo lường (Measure) trên Fact.
- **Đề xuất bổ sung:**  
  Bổ sung ngay 2 tiêu chí `L2-SCD4A-TECH-FIELD` và `L2-SCD4A-JOIN-FILTER` vào bảng kiểm tra Lớp 2 trong `SKILL.md`.

---

#### Gap 3: Thiếu Tiêu chí Phân định giữa Role-Playing Date FK và Degenerate Date Attribute
- **Mô tả chi tiết:**  
  `SKILL.md` (dòng 972–1013) quy định rất gắt gao về việc cấm `cdr_dt_dim_id` và bắt buộc Fact phải dùng `<role>_dt_dim_id`. Tuy nhiên, tài liệu **không hề đưa ra tiêu chí phân biệt** khi nào một trường ngày là FK kết nối Calendar Date Dimension, và khi nào là một thuộc tính ngày thoái hóa (Degenerate Date Attribute — như `decision_signed_dt`, `violation_record_dt`, `license_granted_dt`).
- **Đánh giá tác động (Impact Assessment):** 🟡 **MEDIUM - HIGH**  
  Reviewer máy móc sẽ ép buộc mọi trường ngày trên Fact phải biến thành Dimension FK (`_dim_id`), gây bùng nổ quan hệ thừa, làm phức tạp hóa mô hình dữ liệu và tăng chi phí JOIN trong ETL mà không đem lại giá trị phân tích thời gian.
- **Đề xuất bổ sung:**  
  Bổ sung định nghĩa chuẩn:
  - **Role-Playing Date FK:** Áp dụng cho trục thời gian phân tích chính (Primary Grain Date, Snapshot Date, Transaction/Trade Date, Effective Date). Bắt buộc có hậu tố `_dim_id` và trỏ tới `cdr_dt_dim`.
  - **Degenerate Date Attribute:** Áp dụng cho các ngày mô tả nghiệp vụ chi tiết mang tính chất pass-through (ngày ký quyết định, ngày lập biên bản). Giữ nguyên kiểu `date`, không có hậu tố `_dim_id`, không tạo quan hệ FK.

---

#### Gap 4: Thiếu Cơ chế Xử lý Ngoại lệ Hợp lệ trong Đối soát Số lượng (False Alarm Handling)
- **Mô tả chi tiết:**  
  Bước 0b.3 (dòng 253) quy định: "Số lượng lệch (dù chỉ 1 dòng, theo cả 2 chiều thừa/thiếu) → Claude bắt buộc dừng, đối chiếu TỪNG DÒNG". Trong thực tế, có các trường hợp lệch số lượng **hoàn toàn hợp lệ và có chủ đích**:
  1. Chỉ tiêu phái sinh nội tại: HLD tự bổ sung thêm các chỉ tiêu phân tích so sánh (`_YOY`, `_MOM`, `_GROWTH`) mà BA không ghi thành dòng riêng.
  2. BA có các dòng phân nhóm rỗng hoặc dòng tổng hợp cha/con (`a`, `b`).
  3. Một chỉ tiêu BA phức tạp được tách thành 2 measure vật lý trên Fact.  
  Hiện tại chưa có cơ chế "Giải trình độ lệch hợp lệ" (Reconciled Delta).
- **Đánh giá tác động (Impact Assessment):** 🟡 **MEDIUM**  
  Reviewer liên tục bị dừng tiến độ vô lý ở Bước 0b, tạo ra sự mệt mỏi cho Human Operator khi phải giải thích lại những điểm lệch đã được phê duyệt.
- **Đề xuất bổ sung:**  
  Thêm khái niệm "Độ lệch đã giải trình" (`Reconciled Delta`): Cho phép vượt qua Gate 0b nếu độ lệch số lượng nằm trong danh mục ngoại lệ hợp lệ đã được ghi chú rõ ràng trong HLD.

---

#### Gap 5: Thiếu Kiểm tra Bảng Mồ côi / Artifact Draft (Orphan Draft Artifacts) trong SKILL.md
- **Mô tả chi tiết:**  
  Trong quá trình thiết kế lặp, một số bảng Fact/Dim draft từng được tạo ra trong `Datamart/lld/{MODULE}/` nhưng sau đó bị loại bỏ trong HLD và Flat Table SQL. Mã lỗi `L2-ORPHAN-DRAFT-ARTIFACT` đã được định nghĩa trong `reference/review_checklist.md` (dòng 177) nhưng bị bỏ quên trong `SKILL.md`.
- **Đánh giá tác động (Impact Assessment):** 🟡 **MEDIUM**  
  Tồn đọng file rác trong source code, làm các công cụ quét tự động (như analyzer hoặc date checker) bị quét nhầm file cũ và báo lỗi sai.
- **Đề xuất bổ sung:**  
  Đưa quy trình All-Tier Cleanup Protocol vào Lớp 2b của `SKILL.md`.

---

#### Gap 6: Thiếu Quy định Bảo vệ Schema Dùng chung (SHARED Dimension) ở Lớp 4
- **Mô tả chi tiết:**  
  Dòng 668 hướng dẫn: "Bước D: Sửa registry theo Attributes (nguồn hiện tại luôn là Attributes detail — registry chỉ tổng hợp)". Điều này chỉ đúng với entity riêng của module (`module: "{MODULE}"`). Đối với các Dimension dùng chung toàn hệ thống (`module: "SHARED"` — như `cdr_dt_dim`, `org_dim`, `securities_dim`), nếu Attributes của một module đang thiết kế bị thiếu cột hoặc sai type mà lại tự ý ghi đè lên `datamart_model.yaml`, sẽ **phá vỡ toàn bộ thiết kế của các module khác đang dùng chung Dimension đó**.
- **Đánh giá tác động (Impact Assessment):** 🔴 **HIGH**  
  Gây lỗi dây chuyền (cross-module regression) trên toàn bộ dự án Data Warehouse.
- **Đề xuất bổ sung:**  
  Quy định rõ ràng: Với entity `SHARED`, nguồn sự thật là Registry approved; nếu Attributes bị lệch thì phải sửa Attributes theo Registry, tuyệt đối không được ghi đè Registry theo Attributes của một module lẻ.

---

#### Gap 7: Thiếu Hướng dẫn Đối soát Chiều Ngược từ Flat Table SQL về LLD
- **Mô tả chi tiết:**  
  Chuỗi truy vết ở dòng 60–70 và Bước 0-ALT (dòng 320) có nhắc đến Tầng 5: Flat Table SQL (`Datamart/flat-table/{MODULE}/*.sql`). Tuy nhiên, trong quy trình Micro-Review tuần tự 4 lớp (Bước 2), hoàn toàn không có bước nào kiểm tra xem DDL và DML của Flat Table SQL có phản ánh đúng các thay đổi của Attributes và Detail Mapping hay không.
- **Đánh giá tác động (Impact Assessment):** 🟡 **MEDIUM**  
  Thiết kế LLD có thể đã được sửa đúng, nhưng code SQL triển khai bên dưới vẫn dùng tên cột hoặc logic cũ, dẫn đến việc báo cáo thực tế vẫn chạy sai.
- **Đề xuất bổ sung:**  
  Thêm một tiểu mục kiểm tra đối soát nhanh giữa LLD và Flat Table SQL ở cuối Lớp 3.

---

### 4. Bảng Đối Chiếu Nhất Quán Giữa SKILL.md và 3 Reference Files (10 Tiêu Chí)

```
┌────┬──────────────────────────────────────┬───────────────────────────────┬───────────────────────────────┬───────────────────────────────┐
│ STT│ Tiêu chí Đối soát                    │ SKILL.md                      │ Reference Files               │ Đánh giá Đồng bộ              │
├────┼──────────────────────────────────────┼───────────────────────────────┼───────────────────────────────┼───────────────────────────────┤
│ 1  │ Delimiter đọc BA CSV                 │ Ghi cứng ';' (dòng 373, 383)  │ 6 file ',', 5 file ';'        │ ❌ LỆCH NGHIÊM TRỌNG          │
│    │                                      │                               │ (ba_source_profile.md: 81)    │                               │
├────┼──────────────────────────────────────┼───────────────────────────────┼───────────────────────────────┼───────────────────────────────┤
│ 2  │ Dòng Header file BA GSĐC             │ Ghi 'dòng 0' (dòng 398)       │ Ghi 'dòng 1' cho cả 11 file   │ ❌ LỆCH (Tàn dư cũ)          │
│    │                                      │                               │ (ba_source_profile.md: 15)    │                               │
├────┼──────────────────────────────────────┼───────────────────────────────┼───────────────────────────────┼───────────────────────────────┤
│ 3  │ Trạng thái BA = 'Delete'             │ Hoàn toàn không nhắc tới      │ Có trong Ma trận & Checklist  │ ❌ THIẾU TRONG SKILL.MD       │
│    │                                      │ (dòng 81, 247, 413)           │ (issue_class: 29; check: 81)  │                               │
├────┼──────────────────────────────────────┼───────────────────────────────┼───────────────────────────────┼───────────────────────────────┤
│ 4  │ Mã lỗi L2-SCD4A-TECH-FIELD           │ Không có trong bảng Lớp 2     │ Có trong Checklist Lớp 2      │ ❌ THIẾU TRONG SKILL.MD       │
│    │                                      │ (dòng 543-557)                │ (review_checklist.md: 170)    │                               │
├────┼──────────────────────────────────────┼───────────────────────────────┼───────────────────────────────┼───────────────────────────────┤
│ 5  │ Mã lỗi L2-SCD4A-JOIN-FILTER          │ Không có trong bảng Lớp 2     │ Có trong Checklist Lớp 2      │ ❌ THIẾU TRONG SKILL.MD       │
│    │                                      │ (dòng 543-557)                │ (review_checklist.md: 175)    │                               │
├────┼──────────────────────────────────────┼───────────────────────────────┼───────────────────────────────┼───────────────────────────────┤
│ 6  │ Mã lỗi L2-ORPHAN-DRAFT-ARTIFACT      │ Không có trong SKILL.md       │ Có trong Checklist & Phân loại│ ❌ THIẾU TRONG SKILL.MD       │
│    │                                      │                               │ (check: 180; issue_class: 121)│                               │
├────┼──────────────────────────────────────┼───────────────────────────────┼───────────────────────────────┼───────────────────────────────┤
│ 7  │ Cây 6 Nhánh Nguyên nhân PENDING      │ Có 6 nhánh (dòng 87-94)       │ Có 6 nhánh chi tiết (Mục 2)   │ ✅ KHỚP HOÀN TOÀN             │
├────┼──────────────────────────────────────┼───────────────────────────────┼───────────────────────────────┼───────────────────────────────┤
│ 8  │ 5 Kịch bản Vấn đề (A, B, C, D, E)    │ Có đủ 5 kịch bản (dòng 97-104)│ Có đủ 5 kịch bản (Mục 3)      │ ✅ KHỚP HOÀN TOÀN             │
├────┼──────────────────────────────────────┼───────────────────────────────┼───────────────────────────────┼───────────────────────────────┤
│ 9  │ Đặc tả L2-DATE-FK-ROLE-PLAYING       │ Trình bày tự do (dòng 972)    │ Bảng chuẩn hóa (dòng 131)     │ ⚠️ TRÙNG LẶP & LỆCH FORMAT    │
├────┼──────────────────────────────────────┼───────────────────────────────┼───────────────────────────────┼───────────────────────────────┤
│ 10 │ Vị trí kiểm tra Date FK CLI          │ Đặt ở Lớp 2b (dòng 519)       │ Đặt ở Macro-Review Bước 0b    │ ❌ LỆCH THỨ TỰ THỰC HIỆN      │
│    │                                      │                               │ (review_checklist.md: 55)     │                               │
└────┴──────────────────────────────────────┴───────────────────────────────┴───────────────────────────────┴───────────────────────────────┘
```

---

### 5. Bảng & Sơ Đồ Quy Trình Review: Before vs After (3 Giai Đoạn Chuẩn Hóa)

#### Sơ Đồ Quy Trình Hiện Tại (BEFORE FLOW):
```
[Bước 0: Xác định Scope] 
       │
       ▼
[Bước 0a: Chạy CLI datamart_progress_analyzer.py]
       │
       ▼
[Bước 0b: Lập KH + Đối soát số lượng 0b.3 + Check 5 Section HLD]
       │
       ▼ ⛔ GATE 0b: DỪNG chờ Human duyệt kế hoạch
       │
[Bước 2: Review Từng Nhóm (3 LỚP ?)] ◄─── (Bắt đầu vòng lặp nhóm)
       │
       ├─► Lớp 1: HLD nhóm N
       ├─► Lớp 1b: [1 lần/module] 13 mục Bước 5B HLD ──┐ (Bị nhét vào vòng lặp)
       ├─► Lớp 2b: [1 lần/module] 10 TC Phase 1 LLD  ──┤ (Bị nhét vào vòng lặp)
       │           + Chạy script Date FK Checker      ──┘
       ├─► Lớp 2: Attributes nhóm N
       ├─► Lớp 3: Detail Mapping nhóm N
       └─► Lớp 4: Registry datamart_model.yaml
               │
               ▼ ⛔ GATE Nhóm: DỪNG hỏi human (a/b/c)
[Bước 3: Tổng hợp Vấn đề] ──► [Bước 4: Chờ Xác nhận Gọi Skill Con]
```

#### Sơ Đồ Chuẩn Hóa Đề Xuất (AFTER FLOW — 3 Giai Đoạn Chuẩn):
```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                   GIAI ĐOẠN 1: MACRO-AUDIT & SANITY CHECK (TOÀN MODULE)                │
│                                                                                        │
│ Bước 1.1: File Resolution động (Dò delimiter ',' hoặc ';', Header dòng 1, UTF-8 BOM)  │
│ Bước 1.2: Chạy CLI tự động hóa:                                                       │
│           - python scripts/datamart_progress_analyzer.py --module [MODULE]            │
│             → Xuất Ma trận Đối soát Tiến độ (BA Status ↔ Datamart Status)             │
│             → Phân loại 100% PENDING theo Cây 6 Nhánh Nguyên nhân                     │
│           - python scripts/datamart_date_fk_checker.py --module [MODULE]              │
│             → Quét sớm 100% Fact table, phát hiện ngay lỗi L2-DATE-FK-ROLE-PLAYING     │
│ Bước 1.3: Fast Sanity Checks cấp Toàn Module (Chạy 1 lần duy nhất):                    │
│           - Chạy 13 mục kiểm tra HLD (kế thừa Bước 5B datamart-hld-design)            │
│           - Chạy 10 TC Phase 1 LLD master (kế thừa Bước 4 datamart-lld-design)        │
│           - Quét toàn bộ chỉ tiêu BA = Delete (chặn đứng vi phạm cấm kỵ)              │
│           - Quét Orphan Draft Artifacts (LLD CSV vs Flat Table SQL)                   │
│ Bước 1.4: Đối soát Số lượng Chỉ tiêu per-nhóm (Có tính Reconciled Delta cho Sub-KPIs) │
│                                                                                        │
│ ⛔ GATE 1 (Macro Checkpoint): Claude DỪNG, xuất Báo cáo Tiến độ + Danh sách Blocker,  │
│                               chờ Human duyệt kế hoạch và thứ tự Micro-Review.         │
└───────────────────────────────────────────┬────────────────────────────────────────────┘
                                            │
                                            ▼ (Human phê duyệt kế hoạch)
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                   GIAI ĐOẠN 2: MICRO-REVIEW CHI TIẾT TỪNG NHÓM (4 LỚP CHUẨN)           │
│                                                                                        │
│ Vòng lặp tuần tự từng nhóm (Nhóm 1 → N) theo kế hoạch đã duyệt:                       │
│   ├── Lớp 1: HLD Alignment                                                            │
│   │     - Coverage 2 chiều (BA ↔ HLD), Grain, Công thức/Mô tả dòng reuse              │
│   │     - Đọc sâu SQL tham khảo BA (Temporal window, TTM, gate condition, BCTC priority)│
│   │     - Nhất quán giữa KPI phái sinh và KPI cơ sở phụ thuộc                         │
│   ├── Lớp 2: Attributes Verification (Atomic → Datamart)                              │
│   │     - Verify YAML approved thật (Nguồn 1 DataModel/Atomic/, Nguồn 2 lld, cấm LinhLV)│
│   │     - Kiểm tra bắt buộc: Đủ bộ trường SCD4A + filter ds_rcrd_st = 'ACTIVE'        │
│   │     - Flatten hoàn toàn xuống Atomic (cấm tham chiếu cột mart khác)                │
│   │     - Vế trái LOOKUP là cột Datamart thật; Naming exceptions; Role-Playing Date FK│
│   ├── Lớp 3: Detail Mapping Verification (Datamart → Report)                          │
│   │     - Trace logic BA (đọc full SQL + Note); Inline DERIVED (cấm dùng KPI_ID)       │
│   │     - Trace ngược mart_table.mart_column lên Attributes; column_role chuẩn        │
│   └── Lớp 4: Model Registry Synchronization (datamart_model.yaml)                     │
│         - Đồng bộ 1-1 cột với Attributes; domain Boolean vs Indicator Y/N             │
│         - BẢO VỆ SHARED DIM: Entity riêng sync theo Attr; Entity SHARED sync theo YAML│
│                                                                                        │
│ ⛔ GATE 2 (Group Checkpoint):                                                          │
│   - Nếu 4 lớp = OK → Tự động in "✅ Nhóm N — OK" và chuyển ngay sang Nhóm N+1         │
│   - Nếu có vấn đề:                                                                    │
│       + Lỗi Info nhỏ 🔵 → Tự động ghi vào Backlog, KHÔNG dừng, tiếp tục nhóm N+1      │
│       + Lỗi Critical 🔴 / Warning 🟡 → DỪNG hỏi human: (a) Sửa ngay, (b) Ghi nhận,    │
│         (c) Dừng.                                                                     │
└───────────────────────────────────────────┬────────────────────────────────────────────┘
                                            │
                                            ▼ (Hoàn tất toàn bộ nhóm trong scope)
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                   GIAI ĐOẠN 3: TỔNG HỢP, REMEDIATION & HANDOFF                         │
│                                                                                        │
│ Bước 3.1: Xuất Bảng Tổng hợp Scorecard Toàn Module & Bảng Action Items theo ưu tiên   │
│ Bước 3.2: Bàn giao Sửa đổi qua Skill Con (Kịch bản A/D → HLD; B/C → LLD)              │
│           (Claude tuyệt đối không tự Edit trực tiếp vào file HLD/LLD/Registry)        │
│ Bước 3.3: Lập Handoff Checkpoint Document cho ca làm việc kế tiếp                    │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## (B) DANH SÁCH DECISIONS ĐÃ CHỐT

1. **Xóa bỏ hoàn toàn code gán cứng `delimiter=';'`** trong `SKILL.md` (dòng 370–385). Thống nhất 100% việc đọc file BA phải thông qua parser động (`ba_source_profile.md` hoặc script analyzer).
2. **Đồng bộ hóa vị trí header file BA**: Khẳng định header của cả 11 file BA hiện hành (kể cả file gộp `BA_analyst_GSĐC.csv`) đều nằm ở **Dòng 1** (0-indexed: index 1).
3. **Đổi tên và chuẩn hóa cấu trúc Bước 2**: Đổi từ "(3 LỚP)" thành `(4 LỚP CHUẨN)`: Lớp 1 (HLD), Lớp 2 (Attributes), Lớp 3 (Detail Mapping), Lớp 4 (Model Registry).
4. **Tái cấu trúc vị trí Lớp 1b, Lớp 2b và CLI Date FK Checker**: Đưa toàn bộ các kiểm tra cấp toàn module ra khỏi vòng lặp Bước 2, định vị thành **Bước 1.3 thuộc Giai đoạn 1 (Macro-Audit)**. Date FK Checker được chạy ngay tại Bước 1.2 để phát hiện blocker sớm trong vòng 2 giây.
5. **Khóa chặt quyền Edit trực tiếp file ở Lớp 4**: Xóa bỏ hướng dẫn "Bước D: Sửa registry theo Attributes". Mọi thao tác sửa registry bắt buộc phải lập Action Plan trình Human và ủy quyền cho `datamart-lld-design` thực hiện.
6. **Chuẩn hóa công thức đối soát số lượng 0b.3 thành 2 chế độ**:
   - Đối soát Tổng thể (Total Scope: kể cả PENDING).
   - Đối soát Khả dụng (Ready Scope: chỉ tính DONE/DOING và READY).
   - Cho phép cơ chế `Reconciled Delta` cho các sub-KPI phái sinh nội tại (`_YOY`).
7. **Bổ sung bắt buộc quy trình kiểm tra Chỉ tiêu bị Xóa (`Delete`)**: Đưa `Delete` vào ma trận đối soát và thiết lập chốt chặn cấm tiệt chỉ tiêu Delete tồn tại trong Datamart.
8. **Bổ sung kiểm tra SCD4A vào Lớp 2**: Bắt buộc kiểm tra 4–5 trường kỹ thuật trên Dimension và điều kiện `ds_rcrd_st = 'ACTIVE'` khi JOIN Atomic.
9. **Cơ chế bảo vệ Entity SHARED Dimension ở Lớp 4**: Entity riêng cập nhật theo Attributes; Entity `SHARED` cập nhật theo approved Registry, nghiêm cấm ghi đè bừa bãi.
10. **Tối ưu hóa Gate Control**: Lỗi `Info 🔵` tự động gom vào Backlog và đi tiếp; chỉ dừng xin ý kiến với lỗi `Critical 🔴` hoặc `Warning 🟡`.

---

## (C) DANH SÁCH OPEN ITEMS CHƯA HOÀN THÀNH (CẦN Ý KIẾN LEAD / BA)

1. **Tiêu chuẩn Reconciled Delta hợp lệ cho từng phân hệ:**
   - *Vấn đề:* Module `GSĐC` chia 3 loại hình doanh nghiệp (nhân 3 số lượng dòng); Module `GSTT` có nhiều chỉ tiêu YoY tự sinh trong HLD.
   - *Cần Lead/BA chốt:* Thiết lập bảng danh mục ngoại lệ (Whitelist) chính thức cho từng phân hệ để tích hợp vào script CLI và tài liệu hướng dẫn.
2. **Ranh giới Degenerate Date vs Role-Playing Date FK cho các trường ngày văn bản:**
   - *Vấn đề:* Các trường ngày như `decision_signed_dt`, `violation_record_dt`, `license_granted_dt` có cần tạo Role-Playing FK trỏ về `cdr_dt_dim` hay giữ kiểu `DATE` thuần?
   - *Cần Lead/BA chốt:* Quy định khung danh mục trường ngày nào bắt buộc Role-Playing FK, trường nào được coi là Degenerate Date.
3. **Phê duyệt thời điểm chỉnh sửa chính thức `SKILL.md`:**
   - *Vấn đề:* Theo ràng buộc R4 và nguyên tắc bảo toàn hệ thống, toàn bộ findings R1 chỉ dừng ở mức Báo cáo và Đề xuất.
   - *Cần Lead chốt:* Phê duyệt Kế hoạch Refactor (R2) trước khi thực hiện chỉnh sửa thực tế trên file `SKILL.md`.

---

## (D) HƯỚNG DẪN CỤ THỂ CHO AGENT SESSION MỚI TIẾP TỤC

Khi một Agent mới tiếp nhận nhiệm vụ chuẩn hóa nội dung `SKILL.md` dựa trên Checkpoint R1, hãy thực hiện theo quy trình sau:

1. **Bước 1 — Nạp Ngữ Cảnh:**
   - Đọc kỹ tài liệu này (`checkpoint_r1_skill_review.md`).
   - Đọc tiếp `checkpoint_r2_structure_refactor.md` để nắm cấu trúc phân rã file mục tiêu.
2. **Bước 2 — Sửa chữa 8 Mâu Thuẫn Nội Tại:**
   - Mở `SKILL.md`, xác định chính xác các dòng đã nêu trong Phần (A).1.
   - Thay thế các đoạn code mẫu cũ (dòng 370–385) bằng chỉ dẫn gọi `detect_delimiter_and_header()`.
   - Cập nhật định vị Header GSĐC (dòng 398) thành dòng 1.
   - Sửa tiêu đề Bước 2 thành "4 LỚP CHUẨN".
   - Sửa hướng dẫn Lớp 4 (dòng 668): Bỏ lệnh tự sửa, thay bằng lệnh trình Action qua skill con.
3. **Bước 3 — Bổ sung các Quy tắc còn Thiếu (Gaps):**
   - Thêm trạng thái `Delete` vào Mục 2 (Ma trận đối soát) và Bước 1.
   - Bổ sung 2 tiêu chí `L2-SCD4A-TECH-FIELD` và `L2-SCD4A-JOIN-FILTER` vào bảng kiểm tra Lớp 2.
   - Bổ sung quy định bảo vệ SHARED Dimension vào Lớp 4.
4. **Bước 4 — Di chuyển các Bước Cấp Toàn Module:**
   - Cắt Lớp 1b (dòng 465–495) và Lớp 2b (dòng 496–533) ra khỏi Bước 2.
   - Ghép thành Bước 0c / Bước 1.3 trong Macro-Review.
5. **Bước 5 — Kiểm định Tính Toàn Vẹn:**
   - Đảm bảo các liên kết tham chiếu giữa `SKILL.md` và 3 reference files không bị đứt gãy.
   - Ghi nhận tiến độ vào `progress.md` và lập handoff bàn giao.
