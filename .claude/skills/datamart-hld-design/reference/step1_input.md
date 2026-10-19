# Bước 1 — Đọc input và Bước 1B — HLD Datamart

Đọc BA theo lát cắt, tra Atomic theo 2 nguồn ưu tiên, self-review tên attribute trước khi viết bảng KPI.

## Mục lục

- BƯỚC 1 — ĐỌC INPUT (thứ tự bắt buộc)
- BƯỚC 1B — SELF-REVIEW ATOMIC ATTRIBUTE NAMES (thực hiện TRƯỚC khi viết bảng KPI)

## BƯỚC 1 — ĐỌC INPUT (thứ tự bắt buộc)

1. **BA file** (`BRD/BA/BA_analyst_{MODULE}.csv`) — extract toàn bộ dòng có `Trạng thái mapping ∈ {Done, Doing, Pending}` (TUYỆT ĐỐI LOẠI BỎ các dòng có `Trạng thái mapping` là `Delete`/`DELETED`/`Xóa`, không đưa vào thiết kế):

   > ⚠️ **KHÔNG Read thẳng file BA.** `BA_analyst_QLKD.csv` là 998K token — một mình đã vượt
   > trần ngữ cảnh 500K. Đơn vị công việc là MỘT Nhóm, và Nhóm nặng nhất toàn repo chỉ ~66K token.
   >
   > **Bước 1a — nạp bản đồ Nhóm (một lần mỗi phiên, ~0,3–7K token):**
   > ```bash
   > python .claude/skills/datamart-review/scripts/ba_slice.py --module {MODULE} --index
   > ```
   > Sinh `Datamart/context/ba/BA_index_{MODULE}.csv`: mỗi Nhóm một dòng — số chỉ tiêu,
   > đếm Done/Doing/Pending, đếm Chiều/Cơ sở/Phái sinh, token ước tính. Dùng nó để chọn Nhóm
   > và lập todo list, KHÔNG dùng để thiết kế.
   >
   > **Bước 1b — nạp lát cắt Nhóm đang làm:**
   > ```bash
   > python .claude/skills/datamart-review/scripts/ba_slice.py --module {MODULE} --nhom {N} --print
   > ```
   > Lát cắt giữ **nguyên văn mọi ô nghiệp vụ** của Nhóm đó (đã kiểm chứng trên cả 11 phân hệ:
   > không mất dòng, không mất ô). Chỉ bỏ cột theo dõi dự án và cột SQL; thêm `--with-sql` khi
   > cần SQL (Phase 2 LLD). File gốc trong `BRD/BA/` KHÔNG bị sửa.
   >
   > Delimiter / dòng header / cột STT của từng phân hệ khai trong `system/rules/ba_column_profile.yaml`
   > — **đã kiểm chứng, không dò động nữa**. Ba phân hệ dùng `;` (FMS, TT, VP), VP đặt tên cột số
   > thứ tự là `TT` chứ không phải `STT`, và cả 11 file đều có dòng legend ở index 2 phải bỏ.
   > File BA lệch với profile → script dừng và báo lỗi, KHÔNG đoán tiếp.
   > *(Mẹo: Designer có thể chạy trực tiếp CLI audit `python .claude/skills/datamart-review/scripts/check_ba_mapping.py --module {MODULE} --strict` để kiểm tra chéo tự động cấu trúc BA).*
   - `Phân loại = Chiều` → slicer/filter dimension — **phải có KPI_ID**, không được bỏ qua
   - `Phân loại = Cơ sở` + `Phái sinh` → KPI chỉ tiêu
   - Ghi nhận `Trạng thái mapping` — phân biệt Done/Doing/Pending
   - ❌ Không bỏ qua dòng `Phân loại = Chiều` — đây là phần của bảng KPI, không chỉ là gợi ý thiết kế
   - ⛔ **QUY TẮC BẮT BUỘC — CHỈ TIÊU TRẠNG THÁI MAPPING = "Delete":**
     Nếu chỉ tiêu trong file BA có `Trạng thái mapping` là **`Delete`** (hoặc `DELETE`, `Xóa`, `Xoá`, `DELETED`):
     - **TUYỆT ĐỐI KHÔNG ĐƯỢC ĐƯA VÀO THIẾT KẾ** (không đưa vào Section 1 Data Lineage, không cấp KPI ID, không đưa vào bảng KPI Section 2, không tạo Fact/Dimension/Operational trong Section 3/4, và không xuất hiện trong `Entities.csv`).
     - Dòng này được coi là yêu cầu đã bị hủy/xóa bỏ từ phía BA/nghiệp vụ, loại bỏ ngay từ bước đọc input BA (`valid_kpis`).
     - Không đếm vào mẫu số đối soát số lượng chỉ tiêu hợp lệ ($BA\_Valid$) ở Bước 5B.

2. **Screenshot** — xác định scope boundary (tab, nhóm, loại thông tin hiển thị)

3. **Tra cứu Atomic — 2 nguồn theo thứ tự ưu tiên (BẮT BUỘC theo đúng thứ tự này):**

   | Ưu tiên | Nguồn | Manifest | Coi là |
   |---|---|---|---|
   | **1 — luôn tra trước** | `DataModel/Atomic/` | `DataModel/Atomic/dm_manifest.yaml` | READY |
   | **2 — chỉ tra khi Nguồn 1 không có entry** | `DataModel/working/Atomic/` | `DataModel/working/Atomic/lld/manifest.yaml` | READY (draft đang hoàn thiện, nhưng vẫn dùng được cho Datamart) |

   - **Bước a:** Mở `DataModel/Atomic/dm_manifest.yaml` → tìm entry `physical_name` khớp. Có entry (bất kể `status: approved` hay `draft`) → **READY**, dùng nguồn này, KHÔNG cần tra tiếp Nguồn 2.
   - **Bước b:** Không có entry ở Nguồn 1 → tra `DataModel/working/Atomic/lld/manifest.yaml` (schema `lld_manifest`, field `source_system`/`source_table`/`atomic_entity`/`lld_file`) tìm entry khớp `atomic_entity`/`source_table` → có entry → **READY**, mở file `DataModel/working/Atomic/lld/{source_system}/{lld_file}`.
   - Không có entry ở cả 2 nguồn → **PENDING**.
   - Nếu tên nguồn trong BA không tìm thấy ở Nguồn 1 → tra [`reference/source_alias_mapping.md`](source_alias_mapping.md) trước khi thử Nguồn 2 hoặc kết luận PENDING.
   - Mỗi `physical_name`/`atomic_entity` có thể có nhiều entry (nhiều source table) — tra tất cả entry cùng tên, không dừng ở entry đầu tiên.
   - Khi cùng 1 entity/physical_name xuất hiện ở CẢ 2 nguồn (VD: đã approved ở `DataModel/Atomic/` nhưng vẫn còn bản draft cũ ở `working/Atomic/`) → **luôn ưu tiên `DataModel/Atomic/`**, bỏ qua bản draft.
   - **❌ TUYỆT ĐỐI KHÔNG dùng `DataModel/working/Atomic_LinhLV/`** — đây là track cũ đã revert, out of date. Dù cấu trúc thư mục giống hệt `DataModel/Atomic/` (cùng BCV folder), entity ở đây KHÔNG được coi là READY dưới bất kỳ hình thức nào, kể cả khi không tìm thấy entity đó ở 2 nguồn hợp lệ trên — trường hợp đó vẫn kết luận PENDING.
   - **Cấm gán READY cho 1 entity chỉ vì "nghe quen"/đã dùng ở nhóm khác trong cùng module** — mọi entity dùng làm nguồn PHẢI có bằng chứng grep trực tiếp: `grep -rl "{physical_name}" DataModel/Atomic/**/*.yaml DataModel/working/Atomic/lld/**/*.yaml` (loại trừ `Atomic_LinhLV`) hoặc entry trong 1 trong 2 manifest trên. Không tìm thấy = PENDING, kể cả khi tên entity trùng khớp hợp lý với khái niệm nghiệp vụ (VD: đã có nhiều lần thiết kế giả định tồn tại 1 entity EAV kiểu "Member Report Indicator Value" cho báo cáo định kỳ CTCK, nhưng entity đó chưa từng có LLD approved trong track hiện hành — chỉ tồn tại ở track cũ đã revert `Atomic_LinhLV`).
   - Khi 1 Nhóm định dùng lại đúng entity nguồn đã xác nhận READY ở Nhóm trước (cùng module) — vẫn phải tự chạy lại bước grep/tra manifest cho Nhóm này, không suy diễn "đã xác nhận rồi thì chắc vẫn đúng". BA có thể đổi nguồn giữa các Nhóm dùng chung khái niệm nghiệp vụ.

4. **Entity YAML files** — xác nhận tên entity/attribute khi cần (không đoán):
   - Nguồn 1: `DataModel/Atomic/{BCV_Folder}/dm_atm_{physical_name}-{SOURCE}.{TABLE}.yaml` — đọc `ldm.physical_name` = `atomic_table`, `attribute.physical_name` = `atomic_column`.
   - Nguồn 2 (chỉ khi không có ở Nguồn 1): `DataModel/working/Atomic/lld/{SOURCE}/lld_{SOURCE}_{TABLE}.yaml`.

5. **HLD hiện tại** (nếu có) — append thêm, không viết lại

## BƯỚC 1B — SELF-REVIEW ATOMIC ATTRIBUTE NAMES (thực hiện TRƯỚC khi viết bảng KPI)

- [ ] Mọi tên attribute dùng trong cột Nguồn/KPI → tra file YAML entity đó, lấy đúng `attribute.name` (field `name:` trong YAML, không phải `physical_name`). KHÔNG tự suy tên từ nghĩa nghiệp vụ.
- [ ] Attribute không tìm thấy trong driving entity → kiểm tra entity liên quan (joined/shared entity), không kết luận PENDING trước khi tra entity phụ. Ví dụ: số định danh CCCD/Hộ chiếu nằm ở `Involved Party Alternative Identification`, không phải `Securities Practitioner`.
- [ ] Attribute dạng ngày tháng có 2 trường tách biệt (VD: `Birth Date` + `Birth Year`) → ghi rõ cả 2 và công thức `COALESCE` trong ETL formula của KPI Derived. KHÔNG chỉ ghi 1 trường.
- [ ] **KPI có điều kiện lọc theo Classification Value (code phân loại)** → bắt buộc đọc full nội dung ô **Mô tả** và **Mapping nghiệp vụ** của dòng BA đó để lấy giá trị code cụ thể. KHÔNG tự suy đoán code (VD: đừng giả định `'PROP'` hay `'FI'` khi chưa đọc BA).
  - Sau khi lấy code từ BA → cross-check với `DataModel/working/Atomic/lld/classification_schemes.yaml` để xác nhận scheme tồn tại.
  - Chỉ tạo Open Issue khi BA **thực sự không cung cấp** giá trị code. Nếu BA đã ghi rõ → dùng thẳng, không tạo issue thừa.
  - Ví dụ thực tế (VP module): BA ghi `Buy/Sell Client House Classification Code = '30'` → Tự doanh; `Foreign Investor Type Code <> '00'` → NĐTNN (negative filter). Sai nếu dùng `'PROP'` hay `= 'FI'` mà không đọc BA.
- [ ] **Đọc full SQL/công thức tham khảo của MỌI dòng BA trong Nhóm đang xét trước khi kết luận nguồn Atomic** — lấy bằng `ba_slice.py --module {MODULE} --nhom {N} --with-sql --print` (phạm vi là Nhóm đang xét, KHÔNG phải cả phân hệ — cả phân hệ thì vượt trần ngữ cảnh). Không suy diễn tên bảng/cột nguồn chỉ từ tên KPI hoặc khái niệm nghiệp vụ. Bắt buộc mở nguyên văn ô Công thức/Mô tả (thường chứa SQL tham khảo) và trích đúng: tên bảng JOIN, tên cột, điều kiện filter/LIKE — rồi mới tra sang Atomic. KHÔNG được giả định "chắc dùng entity X" vì nhóm trước cùng module đã dùng X cho khái niệm nghiệp vụ tương tự.
- [ ] **Không copy pattern nguồn từ Nhóm trước khi chưa tự đọc SQL của chính dòng BA đang xét** — kể cả khi Nhóm N-1 đã xác nhận Atomic entity Y là nguồn đúng cho 1 khái niệm (VD: "Dư nợ margin"), Nhóm N nhắc lại đúng khái niệm đó KHÔNG được mặc định dùng lại Y. Phải tự đọc SQL riêng của Nhóm N — nếu BA đổi bảng/report code/sheet khác thì đó là nguồn khác, không reuse. Đây là nguyên nhân đã gây sai lặp lại nhiều lần trong thực tế (QLKD: hàng loạt Nhóm giả định dùng chung 1 entity EAV suy diễn theo tên, trong khi BA SQL thực tế của từng Nhóm chỉ ra các report_code/sheet_name/cột LIKE khác nhau hoàn toàn — phải re-verify từng Nhóm riêng lẻ mới phát hiện ra).
- [ ] **Ghi chú "Reuse từ Nhóm X" / "BA STT Y thêm dòng '...'" PHẢI trích nguyên văn tên dòng BA** (copy đúng string cột tên chỉ tiêu trong lát cắt `ba_slice.py --nhom {N} --with-sql --print`), **KHÔNG diễn giải/tóm tắt lại theo trí nhớ** — đặc biệt khi tóm tắt nội dung 1 Nhóm để chuyển giao (viết prompt cho Skill/subagent khác, hoặc thuật lại sau khi đã đọc BA ở lượt trước trong hội thoại). Bản tóm tắt dễ đánh mất chi tiết phân biệt khi tên đích nghe giống 1 KPI đã có sẵn ở Nhóm khác. Sự cố thực tế (GSTT Nhóm 28/29, 2026-09-22): 3 dòng BA **"Giá trị mua/bán/ròng theo phân loại nhà đầu tư LOẠI KHỚP LỆNH"** (dòng 412–414/424–426) bị tóm tắt nhầm thành **"Giá trị mua RÒNG/bán RÒNG theo phân loại nhà đầu tư"** khi đối chiếu với 2 KPI đã có tên gần giống (K_GSTT_93/94 — dùng cho khái niệm tách dấu dương/âm hoàn toàn khác, vốn cũng chưa từng có dòng BA nào làm căn cứ) — gán reuse sai thay vì khai 3 KPI mới, tồn tại qua nhiều lượt sửa cho tới khi user tự đọc lại BA và phát hiện. Quy tắc khắc phục: mọi câu "khớp 1-1 công thức với dòng BA '...'" trong Ghi chú bắt buộc là nguyên văn copy-paste, không gõ lại theo trí nhớ hay theo tên KPI đích.
- [ ] **Khi CHỈNH SỬA một Nhóm đã tồn tại (không phải thiết kế mới), KHÔNG tin ghi chú "Ghi chú tái sử dụng"/lịch sử SỬA cũ là đúng — luôn tự đếm lại từ BA hiện tại.** Một ghi chú cũ khẳng định "không có dòng X" hoặc "đã đủ N dòng" có thể sai hoặc lỗi thời (BA cập nhật thêm dòng, hoặc bản thân ghi chú đó vốn đã sai từ đầu). Trước khi coi 1 Nhóm là "đã đủ", chạy lại `ba_slice.py --nhom {N} --with-sql --print` và liệt kê thủ công từng dòng ↔ từng KPI ID, không suy diễn từ prose cũ.
