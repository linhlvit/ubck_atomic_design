# Bước 5B — Review cuối toàn file — HLD Datamart

Diễn giải 14 mục #0–#13 của `check_hld_5b.py`, bộ lệnh CLI chạy lẻ và bảng exit code. Lệnh chính và GATE nằm trong `SKILL.md`.

## Mục lục

- BƯỚC 5B — REVIEW CUỐI TOÀN FILE (bắt buộc, sau khi viết xong toàn bộ HLD, TRƯỚC GATE Phase 1)
  - Cách chạy: DÙNG SCRIPT, KHÔNG ĐỌC MẮT
  - Tích Hợp Bộ Công Cụ Kiểm Định CLI Tự Động Vào Bước 5B

## BƯỚC 5B — REVIEW CUỐI TOÀN FILE (bắt buộc, sau khi viết xong toàn bộ HLD, TRƯỚC GATE Phase 1)

> **Vì sao cần bước riêng:** Checklist "TRƯỚC KHI BÀN GIAO" (`reference/handoff_checklist.md`) được áp dụng per-Nhóm trong lúc thiết kế — nhưng một số lỗi chỉ lộ ra khi nhìn **toàn file cùng lúc** (VD: 1 entity được định nghĩa đầy đủ ở Nhóm 1 nhưng bị tham chiếu rỗng ở Nhóm 2/3/6 vì mỗi khối `erDiagram`/`flowchart` là 1 render độc lập, không tự nhớ nội dung khối khác). Bước này quét lại toàn bộ file sau khi đã viết xong, dùng script thay vì đọc mắt để không bỏ sót.

> **Áp dụng cả khi CHỈNH SỬA/ĐIỀU CHỈNH một phần của HLD đã tồn tại** (không chỉ khi thiết kế mới từ đầu) — kể cả khi phạm vi yêu cầu chỉ là "sửa lại Nhóm N". Vì các mục kiểm tra dưới đây quét **toàn file**, một thay đổi cục bộ (thêm/sửa 1 Nhóm) vẫn có thể làm lộ ra hoặc để sót lỗi cấu trúc đã tồn tại từ trước ở phần không đụng tới — bỏ qua Bước 5B chỉ vì "task chỉ yêu cầu sửa 1 Nhóm" đã gây sót lỗi thực tế (TT — sửa lại Nhóm 1 theo Atomic schema mới nhưng không chạy mục #0 nên bỏ sót toàn bộ file thiếu Section 4 — Reuse Analysis, heading Cụm sai cấp, bảng KPI thiếu cột Ghi chú, vốn có từ bản gốc 20260427 và không liên quan gì đến thay đổi đang làm).

### Cách chạy: DÙNG SCRIPT, KHÔNG ĐỌC MẮT

14 mục dưới đây đã được tự động hoá. **Bắt buộc chạy lệnh này**, không tự viết lại checker
và không tự đánh giá bằng mắt:

```bash
python .claude/skills/datamart-review/scripts/check_hld_5b.py --module {MODULE}
```

Script in đủ 14 dòng `#0`–`#13` kèm mã lỗi. Mục `MANUAL` (#9, #10, #12) chuyển sang
`check_references.py` và `datamart_progress_analyzer.py` — vẫn phải chạy, không được bỏ.
Dán nguyên output vào báo cáo cho human.

> **Vì sao bắt buộc dùng script:** trước khi có `check_hld_5b.py`, 14 mục này chỉ là checklist chữ.
> Thực tế agent bỏ qua hoặc tự đánh giá "đã xong" mà không phát hiện: 18 khối erDiagram thiếu
> `Source_System_Code`, 36 Fact dùng `Snapshot_Date_Id` thay vì `Snapshot_Date_Dimension_Id`,
> 17 heading `### Cụm` sai cấp, Section 3 còn giữ Fact đã bãi bỏ trong khi Section 1 & 5 đã ghi Resolved.

Diễn giải chi tiết từng mục (khớp 1-1 với tiêu chuẩn **Lớp 1b của `datamart-review`**):

0. **Cấu trúc Section & Bảng KPI 7 Cột (`[L1-SECTION-STRUCTURE]`):**
   - Đếm số Section (`## Section N`) — **phải đúng 5**, theo thứ tự cố định: `Data Lineage` / `Tổng quan báo cáo` / `Mô hình tổng thể` / `Reuse Analysis` / `Vấn đề mở`. Không còn biến thể 4 Section. Thiếu bất kỳ Section nào, hoặc "Vấn đề mở" không nằm ở vị trí Section 5 $\implies$ Báo lỗi cấu trúc. Module đầu tiên (`datamart_model.yaml` rỗng) vẫn phải có Section 4 với toàn bộ bảng `reuse_status = new`.
   - Heading Cụm trong Section 1 phải đúng cấp `##### Cụm N: ...` (5 dấu `#`).
   - Mọi bảng KPI của mỗi Nhóm phải đủ **chuẩn 7 cột**: `KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái` (1 bảng duy nhất chứa cả dòng READY lẫn PENDING, không tách 2 bảng/2 block theo header `##### READY`/`##### PENDING`). Dòng PENDING bắt buộc chứa tiền tố `[Nhóm 1-5]`.
   - Mỗi bảng Fact/Dim/Operational trong Section 3 phải có đúng 1 dòng tương ứng trong Section 4 — Reuse Analysis (và ngược lại).
1. **erDiagram — Entity trong quan hệ phải có block định nghĩa (`[L1-ERD-MISSING-ENTITY-BLOCK]`):**
   Với mỗi khối ` ```mermaid\nerDiagram `, mọi entity xuất hiện trong quan hệ (`A ||--o{ B`, `A }o--|| B`...) bắt buộc phải có block định nghĩa `{ ... }` trong chính khối mermaid đó. Quét per-block để tránh nhầm ranh giới giữa các khối.
2. **erDiagram — Cấm Fact-to-Fact reference (`[L1-FACT-TO-FACT-RELATION]`):**
   Với mỗi dòng quan hệ `A ||--o{ B`, entity A (vế trái) **tuyệt đối không được** có tên bắt đầu bằng `Fact_`/`Fact ` — vế trái luôn phải là Dimension. Nếu cần quan hệ, bắt buộc tách Dimension chứa business key độc lập.
3. **erDiagram — Mọi Dimension/Operational có `Source_System_Code` (`[L1-MISSING-SOURCE-SYSTEM-CODE]`):**
   Mọi block `{ ... }` có tên kết thúc bằng `_Dimension` hoặc là bảng Operational bắt buộc phải chứa dòng `string Source_System_Code`. `Calendar_Date_Dimension` cũng bắt buộc, không có ngoại lệ.
4. **Section 1 Flowchart — 3 Subgraph chuẩn (`[L1-FLOWCHART-3-SUBGRAPHS]`):**
   Mọi khối flowchart trong Section 1 bắt buộc có đúng 3 subgraph chuẩn: `SRC["Staging"]` / `SIL["Atomic"]` / `GOLD["Datamart"]`.
5. **Section 1 Flowchart — Mỗi Cụm đúng 1 bảng Datamart (`[L1-CLUSTER-MULTIPLE-MARTS]`):**
   Đếm số node bảng trong subgraph `GOLD` (loại trừ Dimension) — **phải đúng bằng 1**.
6. **Node ID Staging không chứa dấu chấm (`[L1-STAGING-NODE-DOT-SYNTAX]`):**
   Node ID của mermaid Staging không được chứa dấu chấm `.` (`\w+\.\w+\[` gây lỗi cú pháp render mermaid).
7. **Code Fence cân bằng (`[L1-UNBALANCED-CODE-FENCE]`):**
   Tổng số dòng code fence markdown (```` ``` ````) trong toàn file bắt buộc phải là số chẵn.
8. **KPI_ID liên tục, không trùng lặp (`[L1-DUPLICATE-KPI-ID]`):**
   Trích toàn bộ `K_{MODULE}_\d+`, kiểm tra dải số liên tục từ 1 đến max, không có ID nào xuất hiện ở $\ge 2$ dòng bảng KPI khai sinh khác nhau (trừ dòng ghi chú "Reuse từ Nhóm X").
9. **Nguồn Atomic tồn tại thật trong repo approved (`[L1-ATOMIC-SOURCE-NOT-FOUND]`):**
   Mọi node Atomic dùng làm nguồn Dimension/Fact phải tồn tại thật trong `DataModel/Atomic/` (Ưu tiên 1) hoặc `DataModel/working/Atomic/` (Ưu tiên 2). **TUYỆT ĐỐI CẤM `DataModel/working/Atomic_LinhLV/`**. Ngoại lệ: `Classification Value` (`cl_value`).
10. **Đối soát số lượng BA ↔ HLD chuẩn hóa (`[L1-COUNT-DELTA-MISMATCH]` & `[L1-DELETE-VIOLATION]`):**
    - $HLD\_Base == BA\_Valid$ (khớp tuyệt đối 1-1).
    - $BA\_Valid$: chỉ tính dòng có `Trạng thái mapping ∈ {Done, Doing, Pending}`, **loại bỏ 100% dòng `Delete / DELETED / Xóa / Bãi bỏ`** (vi phạm gán mã `L1-DELETE-VIOLATION`).
    - Chênh lệch $\Delta = HLD\_Total - BA\_Valid > 0$ chỉ cho phép khi toàn bộ là phái sinh nội tại (`_YOY`, `_GROWTH`, %) hoặc sub-component (`a`, `b`) có giải trình rõ tại Ghi chú.
11. **erDiagram của cùng 1 Fact/Dim phải giống hệt nhau ở mọi Nhóm (`[L1-INCONSISTENT-ENTITY-BLOCKS]`):**
    Trích toàn bộ block `{tên_entity} { ... }` theo tên entity, so khớp tập hợp trường giữa mọi khối cùng tên xuất hiện trong toàn file. Khác nhau $\implies$ hợp nhất (union) toàn bộ field READY thành 1 schema chuẩn và cập nhật toàn file. Bỏ hậu tố đơn vị (`_Bil_VND`) khỏi tên field.
12. **Mỗi KPI READY có measure phải có mặt trong erDiagram (`[L1-READY-MEASURE-MISSING-FROM-ERD]`):**
    Mọi dòng KPI READY có Tính chất `Cơ sở`/`Phái sinh` (không phải sub-component/reuse) phải tìm thấy $\ge 1$ field tương ứng trong khối erDiagram của Fact/Dim nó thuộc về.
13. **Chuẩn Role-Playing Date Dimension (`[L1-DATE-FK-VIOLATION]`) & Kiểm Soát Cấp Độ Hạt (`[L1-GRAIN-MISMATCH]`):**
    - **A. Role-Playing Date Dimension trên Fact Table (`[L1-DATE-FK-VIOLATION]` / `[L2-DATE-FK-ROLE-PLAYING]`):**
      + **CẤM TUYỆT ĐỐI:** Block Fact chứa trường `Calendar_Date_Dimension_Id FK` hoặc `Calendar_Date_Dimension_Id`. `Calendar_Date_Dimension_Id` CHỈ được phép là PK của `Calendar_Date_Dimension`. *(Cảnh báo: mẫu tham chiếu cũ tại DTM_QLKD_HLD.md dòng 1201 chứa `int Calendar_Date_Dimension_Id FK` là vi phạm nghiêm trọng, tuyệt đối không làm theo!)*.
      + **Fact Periodic Snapshot:** Bắt buộc có trường `Snapshot_Date_Dimension_Id FK` (kiểu `string` hoặc `int`) và quan hệ `Calendar_Date_Dimension ||--o{ <Fact_Snapshot> : " "`.
      + **Fact Event / Fact khác:** Bắt buộc có `<Role>_Date_Dimension_Id FK` (ví dụ: `Trade_Date_Dimension_Id FK`, `Issue_Date_Dimension_Id FK`, `Decision_Date_Dimension_Id FK`...) và quan hệ tương ứng.
      + **Degenerate Date:** Các ngày mô tả nghiệp vụ phụ (ngày ký, ngày biên bản, ngày sinh) thiết kế kiểu `date`, Title_Case_With_Underscore, KHÔNG tag `FK`, KHÔNG suffix `_Dimension_Id`.
      + **Whitelist:** `Calendar_Date_Dimension` có `Calendar_Date_Dimension_Id PK` là hợp lệ 100%.
    - **B. Kiểm soát Cấp Độ Hạt & Ngăn ngừa Grain Mismatch (`[L1-GRAIN-MISMATCH]`):**
      + Bắt buộc xác nhận cấp độ hạt Mockup (Presentation Grain ở Section 2) $\le$ cấp độ hạt lưu trữ Fact (Storage Grain ở Section 3).
      + Tuân thủ nghiêm ngặt Thang 6 bậc hạt: `Sàn -> Chỉ số -> Ngành -> Mã CK -> CTCK -> Giao dịch`.
      + Cấm sao chép công thức giữa các nhóm lệch grain (bài học thực tế K_GSTT_61: cấm copy vốn hóa rổ chỉ số Level 2 sang danh sách Top-N mã CK Level 4).


---

### Tích Hợp Bộ Công Cụ Kiểm Định CLI Tự Động Vào Bước 5B

Trước khi mở GATE Phase 1, Designer **bắt buộc chạy bộ lệnh audit** từ thư mục gốc của repository.
Cách nhanh nhất là chạy runner hợp nhất (bao trùm Gate 0 → Gate 5):

```bash
python .claude/skills/datamart-review/scripts/run_quality_gates.py --module {MODULE} --strict
```

Hoặc chạy lẻ khi cần xem chi tiết:

```bash
# 0. Reference Integrity — cột Atomic/Mart có tồn tại thật không, CSV có vỡ cột không,
#    trạng thái KPI giữa HLD và Detail Mapping có lệch nhau không (Exit 0 = PASS):
python .claude/skills/datamart-review/scripts/check_references.py --module {MODULE} --strict

# 1. Cấu trúc HLD — Bước 5B, 14 mục #0–#13 (Exit 0 = PASS):
python .claude/skills/datamart-review/scripts/check_hld_5b.py --module {MODULE}

# 2. Kiểm tra chéo BA, phân loại 5 nhóm PENDING và lint quy chuẩn Detail Mapping (Exit 0 = PASS):
python .claude/skills/datamart-review/scripts/check_ba_mapping.py --module {MODULE} --strict

# 3. Kiểm tra chuẩn Role-Playing Date FK trên toàn bộ Fact tables (Exit 0 = PASS):
python .claude/skills/datamart-review/scripts/check_date_fk.py --module {MODULE} --strict

# 4. Phân tích tiến độ 3 chiều BA ↔ HLD ↔ LLD và quét các chỉ tiêu bị xóa Delete:
python .claude/skills/datamart-review/scripts/datamart_progress_analyzer.py --module {MODULE}

# 5. Đối soát CẤU TRÚC + NỘI DUNG BA ↔ HLD ↔ Detail Mapping (H6–H9): file bị cắt/xóa, STT BA dùng
#    chung/gán nhầm, lệch số Nhóm, dòng BA không có KPI, lệch loại measure GT/KL:
python .claude/skills/datamart-review/scripts/ba_hld_sync_check.py --module {MODULE} --nhom {N...}
```

> `ba_hld_sync_check.py`: lỗi ❌ (S1/S2/S3/S5) phải xử lý hoặc có Open Issue trước khi mở GATE.
> Cảnh báo 🟡 S4 phải xử lý **từng dòng**: bổ sung KPI hoặc ghi giải trình vào Ghi chú. Không được
> bỏ qua vì "so tên mờ hay báo nhầm".

#### Bảng Tra Cứu Exit Code & Xử Lý Vi Phạm:

| Script | Exit Code | Trạng Thái | Ý Nghĩa Kỹ Thuật & Hành Động Bắt Buộc |
|---|:---:|:---:|---|
| `check_ba_mapping.py` | `0` | **PASS** | 100% chỉ tiêu PENDING, REUSE, DERIVED, DEPRECATED tuân thủ quy chuẩn. Cho phép tiến hành review tiếp. |
| `check_ba_mapping.py` | `1` | **FAIL** | Có vi phạm CRITICAL: vi phạm Rule L4, REUSE thiếu cột vật lý, hoặc DERIVED điền bảng mart. **Bắt buộc sửa file CSV/HLD đến khi đạt Exit 0.** |
| `check_date_fk.py` | `0` | **PASS** | Toàn bộ Fact table tuân thủ chuẩn Role-Playing Date FK. Zero false positive trên `cdr_dt_dim`. |
| `check_date_fk.py` | `1` | **FAIL** | Fact table vi phạm `cdr_dt_dim_id` hoặc Fact Snapshot thiếu `snpst_dt_dim_id`. **Bắt buộc sửa tên FK sang `<role>_dt_dim_id` hoặc `snpst_dt_dim_id`.** |
| `datamart_progress_analyzer.py` | `0` | **PASS** | Số lượng chỉ tiêu khớp hoàn toàn hoặc các chênh lệch nằm trong Whitelist đã duyệt. |
| `datamart_progress_analyzer.py` | `1` | **WARN** | Có sự lệch số lượng chưa giải trình giữa BA và HLD. Kiểm tra các nhóm bị đánh dấu đỏ và bổ sung giải trình delta. |
| `datamart_progress_analyzer.py` | `2` | **BLOCKER** | **L1/L2-DELETE-VIOLATION**: Phát hiện chỉ tiêu bị BA xóa (`Delete`) vẫn đưa vào thiết kế. **Bắt buộc xóa bỏ ngay khỏi HLD/LLD.** |

> **Quy Tắc Chặn GATE:** Nếu bất kỳ script nào trả về Exit Code $\ne 0$ (hoặc phát hiện vi phạm CRITICAL), Designer **TUYỆT ĐỐI KHÔNG ĐƯỢC MỞ GATE** hỏi duyệt Phase 1. Bắt buộc sửa toàn bộ lỗi trực tiếp trong file HLD/LLD và chạy lại script đến khi toàn bộ trả về Exit 0.

> **GATE — bắt buộc dừng:** Sau khi xuất file, hoàn tất Bước 5B và kiểm tra sạch bằng CLI audit (Exit Code 0), đặt câu hỏi: "HLD.md đã được tạo tại [đường dẫn], đã chạy review cuối Bước 5B và bộ công cụ audit đạt chuẩn 100%. Bạn xác nhận để chuyển sang Phase 2?"
> ❌ **KHÔNG được tự chuyển sang Phase 2** khi chưa có xác nhận của human.
