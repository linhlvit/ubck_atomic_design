# Phase 2 — Quy trình Detail Mapping — LLD Datamart

Input/Output, cách ghi file, Checklist và SELF-REVIEW Phase 2. Đọc cùng `phase2_detail_mapping.md` (`column_role`, 4 trường hợp đặc biệt, lỗi tái diễn L1–L18).

## Mục lục

- PHASE 2 — DETAIL MAPPING CSV
  - Checklist Phase 2
  - BƯỚC 0 — TODO LIST TOÀN MODULE
  - PRE-CHECK
  - OUTPUT CHECK
  - SELF-REVIEW Phase 2 — mỗi nhóm
  - TC1 — Mô tả khớp chỉ tiêu
  - TC1b — Bám sát Câu lệnh tham khảo (Reference SQL Alignment Check — Quy tắc L17)
  - TC2 — KPI_ID hợp lệ (thuộc HLD, kể cả Chiều và Pending)
  - TC3 — Logic dùng tên physical (snake_case), đủ prefix table_name.column_name
  - TC4 — Trường/bảng trong Detail Mapping tồn tại trong datamart_model.yaml
  - GATE CUỐI NHÓM
  - SELF-REVIEW Phase 2 — module-level
  - TC5 + TC6 — chạy bằng script, KHÔNG tự đọc cả file

## PHASE 2 — DETAIL MAPPING CSV

Đọc [`reference/phase2_detail_mapping.md`](phase2_detail_mapping.md) đầy đủ trước khi bắt đầu.

**Nguồn sự thật:** `BRD/BA/BA_analyst_{MODULE}.csv` — mọi dòng `Trạng thái mapping ∈ {Done, Doing, Pending}` đều phải map.
Đọc qua lát cắt kèm SQL: `python .claude/skills/datamart-review/scripts/ba_slice.py --module {MODULE} --nhom {N} --with-sql --print`.

> ⛔ **QUY TẮC BẮT BUỘC — LOẠI BỎ CHỈ TIÊU DELETE:**
> Nếu chỉ tiêu trong file BA có `Trạng thái mapping` là **`Delete`** (hoặc `DELETE`, `Xóa`, `Xoá`, `DELETED`):
> - **TUYỆT ĐỐI KHÔNG ĐƯỢC ĐƯA VÀO THIẾT KẾ** (không sinh dòng mapping trong Detail Mapping CSV, không thiết kế cột/thuộc tính trong Phase 1 Attributes, không đưa vào Flat Table Phase 3).
> - Chỉ tiêu Delete được coi là đã bị hủy bỏ bởi BA/nghiệp vụ, bị loại trừ 100% khỏi phạm vi Datamart.

**Input bổ sung Phase 2:** Các file `Datamart/lld/{MODULE}/DTM_{MODULE}_*.csv` đã duyệt (Phase 1) — đọc tất cả file trong thư mục `{MODULE}/`.

**Output:** Ghi block KPI của nhóm N vào `Datamart/lld/DTM_{MODULE}_Detail_Mapping.csv` bằng
`python .claude/skills/datamart-review/scripts/apply_patch.py --module {MODULE} --target dm --nhom {N} --from <file rows>` — không tạo file riêng từng nhóm.
**KHÔNG append mù và KHÔNG Edit tay file này** (QLKD 552K token): append chỉ đúng khi viết mới, sai khi
sửa lại một Nhóm đã có — sinh Nhóm trùng và phá thứ tự TC6. `apply_patch.py --target dm` thay THẾ
NGUYÊN bộ dòng của Nhóm N nếu đã tồn tại (phải đưa đủ toàn bộ dòng của Nhóm, không chỉ dòng mới),
hoặc chèn đúng vị trí theo số nhóm tăng dần nếu là Nhóm mới; luôn chạy `--dry-run` trước.

**Chỉ thêm/sửa 1 KPI vào Nhóm đã có sẵn nhiều dòng khác** (không soạn lại cả Nhóm): dùng
`apply_kpi_patch.py -m {MODULE} --nhom {N} --json spec.json --dry-run` — patch đồng thời cả 3 tầng
HLD/Detail Mapping/Attributes trong 1 lệnh, upsert đúng 1 dòng theo `kpi_id`, không đụng các dòng
khác của Nhóm (xem docstring script để biết cấu trúc JSON).

Header:
```
kpi_id,tab,nhom,kpi_name,tinh_chat,source_module,mart_table,mart_column,column_role,logic,ghi_chu
```

Export encoding: **UTF-8 BOM** (`utf-8-sig`).

### Checklist Phase 2

```
BƯỚC 0 — TODO LIST TOÀN MODULE (bắt buộc, chạy 1 lần trước khi vào loop nhóm):
□ Đối chiếu lại danh sách nhóm bằng `python .claude/skills/datamart-review/scripts/lld_selfcheck.py --module {MODULE} --tc 5`
  (Nhóm 1 → Nhóm N_max) — ĐỘC LẬP với Phase 0 Plan, KHÔNG Read lại cả file HLD,
  không copy danh sách nhóm từ Plan (Plan có thể đã lược bỏ nhóm PENDING toàn bộ vì không cần
  bảng Attributes ở Phase 1)
□ Lập bảng todo list: Nhóm | Tên nhóm | Trạng thái HLD (READY/READY thu hẹp/PENDING toàn bộ) |
  Đã xử lý Phase 2? (chưa)
□ Tổng số dòng todo list PHẢI bằng tổng số nhóm xuất hiện trong HLD Section 2 — kể cả nhóm
  PENDING toàn bộ không có bảng nào ở Phase 1
□ Trình bày todo list cho human → DỪNG chờ xác nhận trước khi bắt đầu Nhóm 1
□ Cập nhật cột "Đã xử lý Phase 2?" ngay sau khi mỗi nhóm được human duyệt block KPI — dùng
  bảng này để xác định "Nhóm cuối" thay vì suy đoán theo Plan Phase 0

PRE-CHECK (trước khi sinh — bắt buộc, chỉ cho KPI của nhóm đang xử lý):
□ Chạy `ba_hld_sync_check.py --module {MODULE} --nhom {N}` (A11 + H6–H9): S1 file nguyên vẹn, S2/S3 số Nhóm khớp STT BA và không có STT dùng chung, S4 từng dòng BA có KPI, S5 loại measure GT/KL khớp Trường nguồn
□ Cross-check BA ↔ HLD: mọi dòng Done/Doing/Pending (kể cả Chiều) của nhóm N đều có KPI_ID trong HLD
□ Lọc bỏ 100% dòng BA có Trạng thái mapping là Delete / DELETED / Xóa — KHÔNG map, KHÔNG sinh dòng Detail Mapping
□ Nếu dòng BA nào (hợp lệ, không phải Delete) chưa có KPI_ID → DỪNG, báo cáo danh sách gap → ❌ KHÔNG sinh block khi chưa có xác nhận của human về cách xử lý gap
□ Không tự sinh KPI_ID mới trong Phase 2 — KPI_ID mới phải được khai sinh trong HLD trước
□ Đọc kỹ `Câu lệnh tham khảo`, `Điều kiện chung`, `Bảng nguồn`, `Trường nguồn`, và `Note` của toàn bộ chỉ tiêu nhóm đang xử lý (theo Quy tắc L17) — lấy bằng `python .claude/skills/datamart-review/scripts/ba_slice.py --module {MODULE} --nhom {N} --with-sql --print`. Lưu ý: với QLKD, BA đã gộp 2 cột SQL thành 1 vào 2026-09-18 — cột sống duy nhất là `Câu lệnh tham khảo (SIT)` (cột S)
□ Đếm N_BA(nhóm) (chỉ tính dòng hợp lệ, ĐÃ LOẠI TRỪ dòng Delete) và N_KPI(nhóm) → báo cáo 2 con số → DỪNG chờ human xác nhận trước khi sinh

OUTPUT CHECK (chỉ kiểm tra block KPI của nhóm đang xử lý):
□ Số dòng block ≥ N_BA(nhóm) — báo danh sách dòng BA bị bỏ sót nếu thiếu
□ Số KPI_ID unique trong block = N_KPI(nhóm) — báo cáo nếu lệch
□ Không có KPI_ID trong block mà chưa được khai sinh trong HLD — báo danh sách nếu vi phạm
□ KPI PENDING (Quy tắc L4): bắt buộc để trống cả 4 cột mart_table, mart_column, column_role, logic; ghi rõ lý do blocker theo 5 nhóm chuẩn hóa vào ghi_chu
□ Bám sát Câu lệnh tham khảo (Quy tắc L17):
  - Mọi điều kiện WHERE trong SQL tham khảo (sàn, loại CK, loại bảng lệnh, loại NĐT, cờ hiệu lực...) PHẢI nằm trong `WHERE` của `logic` dòng MEASURE (KPI không có MEASURE: sinh dòng `column_role = FILTER`) HOẶC ghi rõ trong `ghi_chu` là đã lọc sẵn tại ETL Fact.
  - Số đo trong `mart_column` và `logic` phải bám sát biểu thức `SELECT` trong SQL tham khảo: phân biệt rạch ròi Khớp lệnh (`total_matched_*`) vs Thỏa thuận (`total_negotiated_*`) vs Tổng (`total_*`); Mua vs Bán vs Ròng; Rolling window...
□ Mốc ngày của KPI (A19, phạm vi Phase 2) — KPI trên `fct_*_snpst`/fact event mà BA lọc theo Từ ngày–Đến ngày hoặc ngày tra cứu:
  - Flow (KL/GT/tổng khoảng) → `SUM(...) WHERE cdr_dt_dim.cdr_dt BETWEEN :from_date AND :to_date`.
  - Stock / giá tại Đến ngày (VCSH, số CP lưu hành, LNST kỳ gần nhất, giá đóng cửa) → as-of Đến ngày (`argMax(..., cdr_dt_dim.cdr_dt)`, cận trên `:to_date`); CẤM `SUM` Stock qua nhiều ngày (cộng lặp ×N).
  - Cửa sổ N phiên (`ROWS BETWEEN`) → ghi trong `ghi_chu` rằng truy vấn phải nạp thêm N phiên TRƯỚC Từ ngày, nếu không window chỉ thấy 1 ngày.
  - Giá/Thay đổi/% thay đổi đọc từ Dimension current-state (`*_dim.close_price`, `.price_change`…) KHÔNG phải giá "tại Đến ngày" — dùng cột Fact theo ngày; đọc `ghi_chu` + Open Issue của KPI trước khi chọn (GSTT: O_GSTT_65).
  - Dùng tham số đã có trong module (`:from_date`, `:to_date`, `:p_date`); chưa có chuẩn chung → không tự đặt tên mới, mở Open Issue.
□ Không bỏ qua dòng Phân loại = Chiều
□ Không bỏ qua dòng Trạng thái = Doing
□ Không bỏ qua chiều lặp lại giữa các nhóm — nhóm đang xử lý có đủ SLICER/FILTER explicit (không dùng shorthand "xem nhóm X")
□ tinh_chat khớp với Tính chất trong HLD bảng KPI
□ mart_table dùng tên logical; mart_column dùng tên logical
□ logic dùng tên physical (physical_table.physical_column)
□ DERIVED: mart_table và mart_column bắt buộc để trống; logic chứa công thức vật lý (không gán cột ảo/generic)
□ REUSE Case 1 (Physical): bắt buộc điền đủ mart_table và mart_column khớp 1-1 với Attributes, role = MEASURE/SLICER
□ REUSE Case 2 (Presentation/Derived): bắt buộc để trống mart_table và mart_column, column_role = DERIVED
□ DEPRECATED: column_role = DEPRECATED, mart_table/mart_column để trống, logic = "Đã loại bỏ — không tạo cột/slicer", ghi rõ căn cứ bãi bỏ
□ MEASURE (Quy tắc L18): 1 KPI Base = 1 dòng; `logic` = `[JOIN] → AGG(...) WHERE ... GROUP BY ...` — KHÔNG tách dòng FILTER/GROUP_BY cho KPI có MEASURE (chiều dùng chung khai 1 lần bằng KPI SLICER)
□ NaN/trống trong cột Trạng thái mapping → ghi chú, xác nhận với BA
□ Append đúng THỨ TỰ SỐ NHÓM TĂNG DẦN — xem TC6; nếu file hiện tại đã append lệch thứ tự từ
  trước, KHÔNG tự ý append tiếp theo thứ tự sai đó, báo cho human trước
□ Sau khi human duyệt block: ghi bằng `python .claude/skills/datamart-review/scripts/apply_patch.py --module {MODULE} --target dm --nhom {N} --from <file rows> --dry-run` → xem diff → chạy lại bỏ `--dry-run` → báo "Đã ghi N dòng nhóm [N] vào Detail Mapping"

SELF-REVIEW Phase 2 — mỗi nhóm (bắt buộc trước khi trình bày — chạy 5 testcase, báo kết quả):

TC1 — Mô tả khớp chỉ tiêu:
□ Kiểm tra cột `kpi_name` trong Detail Mapping khớp với tên KPI trong HLD bảng KPI (Section 2)
□ Kiểm tra cột `logic` mô tả đúng bản chất chỉ tiêu — không mâu thuẫn với mô tả trong BA_analyst
□ Báo: ✅ TC1 PASS hoặc ❌ TC1 FAIL: [danh sách kpi_id có kpi_name hoặc logic không khớp]
□ Nếu FAIL → sửa trước khi trình bày

TC1b — Bám sát Câu lệnh tham khảo (Reference SQL Alignment Check — Quy tắc L17):
□ Với mọi chỉ tiêu có `Câu lệnh tham khảo` hoặc `Điều kiện chung` trong BA:
  - Kiểm tra các điều kiện lọc trong mệnh đề WHERE đã nằm trong `logic` MEASURE (KPI không có MEASURE: dòng `column_role = FILTER`) hoặc đã ghi nhận lọc sẵn trong ETL Fact chưa.
  - Quy tắc L18: mỗi `kpi_id` có dòng MEASURE chỉ được có đúng 1 dòng (đếm số dòng/kpi_id; có FILTER/GROUP_BY cùng kpi_id → FAIL).
  - Kiểm tra `mart_column` và biểu thức tổng hợp trong `logic` có phản ánh đúng mệnh đề SELECT (khớp lệnh vs thỏa thuận vs tổng; mua vs bán vs ròng; rolling/window...) không.
□ Báo: ✅ TC1b PASS hoặc ❌ TC1b FAIL: [danh sách kpi_id bị lệch số đo hoặc thiếu filter so với SQL tham khảo]
□ Nếu FAIL → sửa trước khi trình bày

TC2 — KPI_ID hợp lệ (thuộc HLD, kể cả Chiều và Pending):
□ Lấy toàn bộ KPI_ID từ HLD (Section KPI + Chiều + Pending)
□ Kiểm tra mọi kpi_id trong Detail Mapping ∈ tập KPI_ID HLD — không có ID ngoài HLD
□ KPI_ID xuất hiện trong Detail Mapping nhưng chưa khai sinh trong HLD → DỪNG, báo danh sách, chờ human phê duyệt quyết định trước khi tiếp tục
□ Báo: ✅ TC2 PASS hoặc ❌ TC2 FAIL: [danh sách kpi_id chưa khai sinh trong HLD]

TC3 — Logic dùng tên physical (snake_case), đủ prefix table_name.column_name:
□ Kiểm tra cột `logic`: tên bảng và cột phải là tên physical/snake_case (ví dụ "fct_mkt_rsk_snpst.compliance_score", "cdr_dt_dim.cdr_dt") — không phải tên logical ("Fact Market Risk Snapshot", "Inspection Date")
□ Báo: ✅ TC3 PASS hoặc ❌ TC3 FAIL: [danh sách kpi_id có logic dùng tên logical thay vì physical]
□ Nếu FAIL → sửa trước khi trình bày

TC4 — Trường/bảng trong Detail Mapping tồn tại trong datamart_model.yaml:

```bash
python .claude/skills/datamart-review/scripts/lld_selfcheck.py --module {MODULE} --tc 4
```

Script bỏ qua dòng `DERIVED`/`PENDING`/`DEPRECATED` có `mart_table`/`mart_column` trống (Quy tắc L4),
và chấp nhận **cả tên logical lẫn tên physical** — thực tế repo ghi `mart_table` logical
("Calendar Date Dimension") nhưng `mart_column` physical ("cdr_dt"); chỉ so một kiểu sẽ gây
false positive hàng loạt.

□ FAIL → xác định model thiếu cột (Phase 1 chưa ghi đủ) hay Detail Mapping dùng sai tên → sửa tương ứng
□ Tất cả 5 TC đều PASS (TC1, TC1b, TC2, TC3, TC4) → trình bày block KPI nhóm N cho human
□ Sau khi xuất block: DỪNG chờ human duyệt block → append vào Detail Mapping khi được approve

GATE CUỐI NHÓM:
□ Phase 1 (Attributes) + Phase 2 (Detail Mapping block) của nhóm N đã được human duyệt
□ Cập nhật todo list Bước 0: đánh dấu Nhóm N = đã xử lý
→ Báo: "Nhóm [N] — [Tên nhóm] hoàn thành. Tiếp tục Nhóm [N+1] — [Tên nhóm N+1]?"
→ DỪNG chờ human xác nhận → ❌ KHÔNG tự bắt đầu nhóm tiếp theo
→ "Nhóm cuối" = nhóm cuối trong todo list Bước 0 (toàn bộ HLD), KHÔNG phải nhóm cuối trong
  Phase 0 Plan — nếu Plan Phase 0 không liệt kê hết nhóm HLD, vẫn phải tiếp tục xử lý các nhóm
  còn thiếu trong todo list trước khi coi là hoàn thành

SELF-REVIEW Phase 2 — module-level (bắt buộc, chạy 1 lần sau khi TẤT CẢ nhóm trong todo list
đã xử lý, TRƯỚC KHI báo "Tất cả nhóm hoàn thành"):

TC5 + TC6 — chạy bằng script, KHÔNG tự đọc cả file:

```bash
python .claude/skills/datamart-review/scripts/lld_selfcheck.py --module {MODULE} --tc 5,6
```

- **TC5** đối chiếu tập Nhóm và tập KPI_ID giữa HLD Section 2 ↔ Detail Mapping, báo danh sách
  Nhóm/KPI_ID có trong HLD nhưng THIẾU trong Detail Mapping.
- **TC6** kiểm tra thứ tự nhóm-xuất-hiện-lần-đầu tăng dần theo **SỐ** nhóm (không so chuỗi —
  string sort xếp "Nhóm 11" trước "Nhóm 2" là SAI). FAIL → `--tc 6 --fix-order` sắp lại toàn file,
  giữ nguyên nội dung và thứ tự dòng trong từng nhóm. **Báo cho human trước khi chạy `--fix-order`**,
  vì đây là thay đổi toàn file chứ không phải append.

Lý do dùng script: cả hai TC đều cần đọc TOÀN BỘ Detail Mapping — với QLKD là 552K token, vượt
trần ngữ cảnh. Dán nguyên output vào báo cáo, không diễn giải lại.

□ TC5 + TC6 đều PASS → báo "Tất cả nhóm hoàn thành. Chuyển sang Phase 3?"
→ DỪNG chờ human xác nhận chuyển Phase 3
```
