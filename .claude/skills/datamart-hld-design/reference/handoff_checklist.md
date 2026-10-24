# Checklist trước khi bàn giao — HLD Datamart

Rà theo từng Section trước khi mở GATE Phase 1, và phần Phase 2 trước khi bàn giao Entities.

## Mục lục

- CHECKLIST TRƯỚC KHI BÀN GIAO
  - Section 1 — Data Lineage
  - Section 2 — Tổng quan báo cáo
  - Section 3 — Mô hình tổng thể
  - Section 4 — Reuse Analysis & Deprecation
  - Section 5 — Vấn đề mở
  - erDiagram
  - Quy ước chung
  - Phase 2 — Entities Files

## CHECKLIST TRƯỚC KHI BÀN GIAO

### Section 1 — Data Lineage
- [ ] **Mỗi Cụm chỉ 1 bảng Datamart duy nhất** — 1 Fact hoặc 1 bảng Tác nghiệp, không gộp nhiều Fact chung 1 Cụm dù cùng Atomic entity cha. Tách thành nhiều Cụm riêng (1a, 1b, 1c...), chấp nhận lặp lại node Atomic entity cha ở nhiều flowchart. Xem `reference/flowchart_rules.md` mục "Mỗi Cụm chỉ 1 bảng Datamart"
- [ ] Mỗi flowchart có đủ 3 subgraph: `SRC["Staging"]` / `SIL["Atomic"]` / `GOLD["Datamart"]`
- [ ] Staging: 1 subgraph duy nhất, prefix table name thể hiện nguồn (VD: `FMS.RPTVALUES`)
- [ ] Mọi Cụm có Fact: `ECAT.ECAT_29_HolidayInfo` trong Staging + `Calendar Date` trong Atomic + `Calendar Date Dimension` trong Datamart
- [ ] Node Staging dùng `ID["label"]` — ID không có dấu chấm
- [ ] Node Atomic dùng `ID["label"]` — ID dùng `_`, label bỏ `_`
- [ ] Node Datamart dùng `ID["label"]` — **ID = tên logical nối bằng `_`** (KHÔNG phải physical snake_case), label = tên logical đầy đủ có dấu cách. Cùng quy ước với node Atomic — xem `reference/flowchart_rules.md`
- [ ] Dim xuất hiện trong subgraph Datamart; link `Dim → Fact` (không phải `Fact → Dim`)
- [ ] Dimension seed từ Classification Value: chỉ vẽ node `Classification Value` trong Atomic
- [ ] **Mọi Dimension trong GOLD phải có Atomic entity nguồn trong SIL với edge đầy đủ** — duyệt từng node Dim trong subgraph GOLD, kiểm tra có ít nhất 1 Atomic entity trong SIL nối vào. Thiếu edge = thiếu nguồn → tự sửa trước khi xuất file. Ví dụ lỗi: `Securities Practitioner Dimension` xuất hiện trong GOLD nhưng không có node `Securities Practitioner` trong SIL + edge `Securities Practitioner → Securities Practitioner Dimension`.
- [ ] **Mọi Atomic entity dùng ETL join vào Fact phải có edge riêng vào Fact** — nếu Atomic entity A được dùng để enrich/join khi populate Fact (không chỉ qua Dim), phải có edge `A → Fact` trong flowchart. Ví dụ lỗi: `Securities Practitioner` dùng để join lấy CCHN của NHN có `Practice_Status_Code='3'` → cần edge `Securities Practitioner → fct_prac_license_ctf_snpst`, không chỉ `Securities Practitioner → scr_prac_dim`.

### Section 2 — Tổng quan báo cáo
- [ ] Hierarchy: `### Tab` → `#### Nhóm` (KHÔNG có header con `##### READY`/`##### PENDING`) — quy tắc đặt tên:
  - **Tên Tab** (`### Tab`): lấy phần TRƯỚC dấu `/` trong cột **Dashboard/báo cáo** của BA (VD: `Dashboard Giám sát rủi ro`)
  - **Tên Nhóm** (`#### Nhóm`): lấy phần SAU dấu `/`, kèm **số STT từ BA** — format: `#### Nhóm {STT} - {tên sau dấu /}`. Số nhóm = STT trong BA, KHÔNG tự đánh số lại
  - Ví dụ đúng: BA ghi `Dashboard Giám sát rủi ro/ Chỉ số rủi ro hệ thống`, STT=1 → Tab: `### Tab Dashboard Giám sát rủi ro`, Nhóm: `#### Nhóm 1 - Chỉ số rủi ro hệ thống`
  - Ví dụ đúng: BA ghi `Dashboard Giám sát rủi ro/ Phân tích đóng góp rủi ro`, STT=2 → Nhóm: `#### Nhóm 2 - Phân tích đóng góp rủi ro`
  - Sai: `#### Nhóm Thanh khoản thị trường` (thiếu số STT); sai: `#### Nhóm 1` (thiếu tên)
- [ ] **Cấm tự chẻ 1 STT BA thành nhiều Nhóm HLD** — dù mockup/screenshot của cùng 1 STT có nhiều khối UI trực quan khác nhau (VD: 4 KPI Card + 1 biểu đồ donut trên cùng màn hình), vẫn phải gộp vào **đúng 1 Nhóm** theo đúng STT gốc — không tự quyết định tách thành "Nhóm N" và "Nhóm N+1" theo cảm nhận trình bày. Nếu 1 STT có nhiều dạng mockup, liệt kê nhiều mockup con (a), (b)... trong cùng 1 Nhóm, dùng chung 1 bảng KPI. Vi phạm rule này còn kéo theo lệch số toàn bộ các Nhóm STT phía sau (dồn +1 tính từ điểm bị chẻ) — lỗi thực tế đã xảy ra ở QLCB Nhóm 5 (BA STT=5 duy nhất, 4 dòng, bị tách thành "Nhóm 5 KPI Cards" + "Nhóm 6 donut", đẩy lệch toàn bộ BA STT 6-10 thành "Nhóm 7"-"Nhóm 11" trong HLD).
- [ ] **Mỗi Nhóm chỉ có 1 bảng KPI duy nhất (7 cột: KPI ID / Tên KPI / Đơn vị / Tính chất / Công thức / Ghi chú / Trạng thái)** — chứa cả dòng READY lẫn dòng PENDING, phân biệt bằng cột Trạng thái. KHÔNG tách thành 2 block riêng theo header `##### READY`/`##### PENDING`, KHÔNG dùng 2 cấu trúc cột khác nhau cho READY (6 cột) và PENDING (4 cột) — đây là thay đổi thiết kế (2026-07-23, theo yêu cầu user) thay thế hoàn toàn format "Block READY/Block PENDING tách biệt" trước đó.
- [ ] Nhóm có ít nhất 1 dòng READY → có đủ: Phân loại / Atomic / Mockup / Source / Bảng KPI / Star Schema / Lineage Mart → Báo cáo / Bảng grain. Nhóm 100% PENDING → chỉ cần Phân loại / Atomic / Mockup / Bảng KPI (bỏ Source/Star Schema/Lineage/Bảng grain)
- [ ] **Dòng KPI PENDING trong bảng KPI chung:** Cột Đơn vị/Công thức để trống hoặc ghi "TBD — chờ Atomic"; cột Ghi chú bắt buộc chứa đủ cấu trúc chuẩn: tiền tố `[Nhóm 1-5 - <Tên nhóm>]`, mô tả blocker cụ thể (ref mã `O_{MODULE}_{N}` nếu có), Atomic cần bổ sung, và Mart dự kiến (tên bảng + grain)
- [ ] **Bảng mapping nguồn (Atomic Placeholder)** — chỉ thêm khi Nhóm có ít nhất 1 dòng PENDING, đặt sau Bảng grain (hoặc sau Bảng KPI nếu Nhóm 100% PENDING); mỗi dòng = 1 Atomic entity, điền đủ Bảng nguồn BA + Atomic entity dự kiến + Atomic table dự kiến (TBD nếu chưa rõ); chỉ liệt kê KPI đang PENDING, không lặp lại KPI READY
- [ ] **Mỗi cột trong Fact phải trace được về KPI/mockup của Nhóm đó** — sau khi viết xong bảng KPI, rà lại từng cột trong Fact block: cột nào không xuất hiện trong bất kỳ công thức KPI nào → loại khỏi Star Schema, trừ khi là FK trục thời gian/dimension chính hoặc là điều kiện ETL filter SCD4A đã ghi chú riêng bằng text (xem `reference/erdiagram_rules.md`). Không đưa nguyên attribute còn lại của Atomic entity nguồn vào Fact "cho đủ"
- [ ] **Bảng KPI chỉ có 1 bảng duy nhất cho toàn Nhóm** — KHÔNG tách thành `*KPI mới:*` và `*KPI reuse:*` thành 2 bảng riêng, KHÔNG tách theo trạng thái READY/PENDING. Reuse được liệt kê cùng bảng với KPI mới; cột "Ghi chú" đánh dấu nguồn gốc reuse
- [ ] **Lineage Mart → Báo cáo chỉ vẽ nếu Nhóm có ít nhất 1 dòng READY, chỉ vẽ từ Datamart lên báo cáo** — KHÔNG vẽ Atomic entities trong flowchart này. Node bắt đầu phải là bảng Fact/Dim/Operational (physical name trong GOLD layer), không phải Atomic entity
- [ ] **Lineage Mart → Báo cáo gộp 1 report node duy nhất cho toàn bộ Nhóm** — KHÔNG tách report node riêng theo từng Chiều/KPI/measure. Ghi dạng `"K_{MODULE}_N-M,X,Y: {Tên Nhóm}"` liệt kê dải/danh sách KPI ID **đang READY** trong 1 node duy nhất (không đưa ID PENDING vào node báo cáo) (xem ví dụ đúng/sai trong `reference/section_structure.md`)
- [ ] **KPI Done (sub-component) đã khai sinh ở Nhóm trước → reuse vào cùng bảng KPI, đánh dấu Trạng thái theo đúng trạng thái thật** (READY nếu Atomic sẵn sàng, PENDING nếu chưa) — không tách riêng theo vị trí bảng
- [ ] Dòng KPI PENDING không có Star Schema, erDiagram, Lineage flowchart riêng
- [ ] **Liên kết Open Issue cho KPI PENDING:** Các blocker lớn thuộc Nhóm 3 (Gap Atomic / ngoại lai), Nhóm 4 (Join đa nguồn), Nhóm 5 (Datamart pending) BẮT BUỘC tạo Open Issue tại Section 5 (`O_{MODULE}_{N}`) để phân định rõ trách nhiệm tháo gỡ (BA, Data Architecture / Atomic, Atomic Modeling, hay Datamart Modeling). Xóa bỏ triệt để quy định cấm cũ
- [ ] **Tên attribute trong cột Nguồn phải là logical name chính xác từ YAML** — đọc `attribute.name` trong file YAML của entity đó. KHÔNG tự đặt tên theo cảm tính. Ví dụ sai: `Date Of Birth` khi YAML ghi `Birth Date`.
- [ ] **Giá trị Classification Value trong công thức KPI phải lấy từ BA, KHÔNG tự suy đoán** — đọc full ô Mô tả + Mapping nghiệp vụ của từng dòng BA. Ví dụ sai: dùng `= 'PROP'` thay vì `= '30'`; dùng `= 'FI'` thay vì `<> '00'`. Sau khi lấy code từ BA → verify với `DataModel/working/Atomic/lld/classification_schemes.yaml`.
- [ ] **KPI có nguồn từ entity phụ (join/shared entity)** → ghi rõ tên entity phụ + điều kiện join trong cột Nguồn. KHÔNG ghi nhầm vào entity chính. Ví dụ đúng: "`Involved Party Alternative Identification`.Identification Number — join qua ip_id, filter Identification Type Code = CCCD/PASSPORT".
- [ ] KPI ID đã được khai sinh trong Section 2 trước khi xuất hiện ở file khác
- [ ] Mọi dòng BA `Phân loại = "Chiều"` phải có KPI_ID trong bảng KPI của nhóm tương ứng — không được bỏ qua
- [ ] Chiều dùng như ETL filter nội bộ (không hiển thị UI) → ghi rõ trong cột Ghi chú: "dùng trong formula KPI K_X_N" — vẫn phải có KPI_ID
- [ ] Cấm dùng shorthand "xem Nhóm N" thay thế bảng KPI — nếu nhóm reuse KPI từ nhóm khác, liệt kê explicit từng KPI_ID kèm ghi chú nguồn gốc: "Reuse từ Nhóm N"
- [ ] Đọc toàn bộ BA file trước khi viết bảng KPI — đảm bảo không sót dòng nào có `Trạng thái mapping ∈ {Done, Doing, Pending}`, ĐỒNG THỜI loại bỏ 100% các dòng có `Trạng thái mapping = Delete` (hoặc DELETE, Xóa) khỏi thiết kế HLD
- [ ] **Mọi dòng Done không note "Trùng" → bắt buộc có KPI_ID trong nhóm:** Nếu concept đã khai ở nhóm khác → reuse explicit trong bảng KPI nhóm này, không được im lặng bỏ qua
- [ ] **Dòng Done là sub-component của KPI phức tạp → vẫn cấp KPI_ID riêng:** Không gộp im lặng sub-component vào KPI cha. Ngoại lệ duy nhất: cột Đánh giá ghi "Trùng" → reuse ID đã có
- [ ] **Cấm thêm KPI không có dòng BA tương ứng:** Bảng KPI chỉ chứa KPI có dòng BA trong nhóm đó (mới hoặc reuse). Không thêm KPI từ suy luận nghiệp vụ dù hợp lý. **Ngoại lệ có kiểm soát (H17):** cột output có trong SELECT cuối của SQL BA chính thức hoặc trong danh sách yêu cầu nghiệp vụ do user/BA cung cấp thì được thêm KPI (ghi nguồn ở Ghi chú) kèm Open Issue "BA CSV thiếu dòng"; chỉ suy luận nghiệp vụ thì vẫn cấm
- [ ] **Dedup KPI giữa các Nhóm trong cùng Tab:** Trước khi cấp ID mới cho Nhóm N, kiểm tra toàn bộ KPI đã khai sinh ở Nhóm 1→(N-1). Nếu trùng nội dung → reuse ID cũ, KHÔNG cấp ID mới. Liệt kê reuse **trong cùng bảng KPI 7 cột duy nhất** — điền cột Ghi chú = "Reuse từ Nhóm X". KHÔNG tạo bảng reuse riêng.
- [ ] **Đối chiếu SỐ LƯỢNG BA ↔ HLD theo công thức chuẩn hóa (bắt buộc cho mỗi Nhóm ngay khi viết xong bảng KPI):**
  - Đếm `BA_Valid = COUNT(dòng BA hợp lệ của Nhóm, loại bỏ dòng banner rỗng / template / dòng Delete)`
  - Đếm `HLD_Base = COUNT(KPI Base/1-1 của Nhóm, loại trừ KPI Derived _YOY/_GROWTH/tỷ lệ nội bộ và sub-component a/b đã giải trình)`
  - Xác nhận `BA_Valid == HLD_Base` khớp chính xác 1-1. Nếu lệch: đối chiếu từng dòng BA để phát hiện dòng bị gộp nhầm hoặc bỏ sót (đặc biệt là các chiều slicer phụ). Mọi KPI dôi dư phải được giải trình rõ trong cột Ghi chú.
  - Ví dụ lỗi thực tế (QLCB Nhóm 4): 2 dòng BA độc lập "Thông tin doanh nghiệp" (nguồn `COMPANY_NAME_VN`) và "Mã chứng khoán" (nguồn `equity_ticker`) bị viết gộp thành 1 dòng KPI "Thông tin doanh nghiệp (Mã CK, Tên DN)" — BA 12 dòng nhưng HLD chỉ có 11 KPI, không bị rule cũ nào bắt được vì dòng KPI đó "vẫn có ID, vẫn có dòng BA tương ứng".
  - **Số lượng khớp chưa đủ, phải khớp cả nội dung (H9):** chạy thêm `ba_hld_sync_check.py --module {MODULE} --nhom {N}` và xử lý từng cảnh báo S4/S5.
  - **Bắt buộc xác nhận lại bằng script, không chỉ tự đếm bằng mắt:** chạy `python .claude/skills/datamart-review/scripts/datamart_progress_analyzer.py --module {MODULE}`, tìm đúng dòng của (các) Nhóm vừa viết/sửa trong bảng delta (dạng `| Nhóm N | ... | BA | HLD | LLD | Δ | ... | 🔴/✅ |`), xác nhận `Δ = 0` hoặc lệch đã giải trình rõ. **TUYỆT ĐỐI KHÔNG được xem output qua `| tail -N` / `| head -N` rồi kết luận "sạch"** — bảng delta nằm ở vị trí cố định giữa output đầy đủ (không phải cuối), cắt bớt output rất dễ bỏ lỡ đúng dòng Nhóm cần xem; nếu cần giới hạn dung lượng, dùng `grep` đích danh `"Nhóm {N} "` thay vì `tail`/`head`. Sự cố thực tế (GSTT Nhóm 28, 2026-09-22): script đã in đúng `🔴 Lệch số lượng` cho Nhóm 28 (thiếu 2 KPI reuse: "Giá mở cửa" → K_GSTT_27, "Thay đổi" → K_GSTT_11 — cả 2 đều có dòng BA rõ ràng, cột Đánh giá = "Trùng") nhưng bị bỏ sót vì agent chỉ xem qua `| tail -30`, cắt mất đúng đoạn bảng delta — chỉ phát hiện ra khi user tự đọc lại BA và hỏi lại.
- [ ] **Kiểm soát Cấp Độ Hạt (Iso-Grain Rule):** Presentation Grain của Mockup ở Section 2 phải $\le$ Fact Storage Grain ở Section 3. Tuân thủ Thang 6 bậc hạt. Không copy công thức aggregate khi nhóm reuse có cấp hạt khác nhóm gốc (Case K_GSTT_61).
- [ ] **Phân biệt Reuse Case 1 vs Case 2:** Case 1 (Physical measure/dim) ghi rõ bảng/cột đích và đồng bộ Entities.csv; Case 2 (Presentation / Derived) role DERIVED và để trống bảng/cột.
- [ ] **Alias SELECT cuối + danh sách yêu cầu nghiệp vụ đều có KPI (H17):** liệt kê và đối chiếu; cột thiếu → KPI (có bằng chứng) + Open Issue "BA CSV thiếu dòng", hoặc chỉ Open Issue khi cần quyết định nghiệp vụ
- [ ] **Câu cũ mâu thuẫn trong Nhóm đã được sửa/gắn nhãn Lịch sử (H16):** `grep -n "PENDING\|TBD\|chưa có\|chưa gắn\|HẠ xuống"` trong Nhóm vừa sửa; mỗi câu còn lại phải khớp trạng thái/công thức hiện tại — sửa tại chỗ nếu ở ô bảng, gắn `*(Lịch sử — đã thay thế bởi cập nhật YYYY-MM-DD)*` nếu là khối `[CẬP NHẬT]` cũ
- [ ] **Bảng "Bảng mapping nguồn" đúng 4 ô** (`Tên KPI | Bảng nguồn (BA) | Atomic entity | Atomic table`), không dán công thức/ghi chú KPI vào dòng mapping, KPI READY không còn "TBD" — Gate 8 D14 `L1-HLD-MAPPING-ROW-CELLS`
- [ ] **`bảng.cột` trong công thức bảng KPI tồn tại thật (A24):** Gate 8 D13 `L0-DM-LOGIC-COLUMN-NOT-FOUND`; cột đứng một mình (VD `active_status_flag`) tra bằng grep YAML Atomic / Attributes CSV (H5)

### Section 3 — Mô hình tổng thể
- [ ] Không bao gồm PENDING
- [ ] Bảng Phân tích: chỉ liệt kê Fact (không liệt kê Dimension)
- [ ] Bảng Dimension: chỉ liệt kê Dimension, có ghi chú "Tất cả Dimension áp dụng SCD Type 4A"
- [ ] Cột Conformed điền đúng (Có/Không)
- [ ] **Mọi measure trên Fact có grain N (kết quả của N-way join) đã qua grain-matching (BƯỚC 4B)** — measure không copy thẳng từ driving table cha có grain thô hơn Fact; nếu measure lệch grain, công thức SUM ở Section 2 phải pre-aggregate theo đúng cấp grain của measure, không SUM trực tiếp trên Fact
- [ ] **Lưu trữ chuỗi thời gian lookback:** Mọi chỉ tiêu lookback N phiên / Window Functions phải lưu trên Fact Periodic Snapshot theo ngày (`fct_*_snpst`). CẤM tính Window Function trên Dimension SCD4A current-state (`L2-WINDOW-STORAGE-INVALID`).

### Section 4 — Reuse Analysis & Deprecation
- [ ] Có bảng với 4 cột: Datamart Entity / datamart_table / reuse_status / Ghi chú
- [ ] Mỗi bảng đích trong Section 3 đều có 1 dòng trong Section 4
- [ ] `reuse_status` đã được human xác nhận (không tự gán nếu có khả năng reuse)
- [ ] Ghi chú ghi rõ lý do reuse/partial/DEPRECATED
- [ ] **Tuân thủ Giao thức Bãi bỏ Bảng 5 tầng:** Khi bãi bỏ bảng Fact/Dim, đồng bộ trên LLD CSV, Master attributes, Detail Mapping, Model registry, và HLD Section 3/4 + Flat Table SQL.

### Section 5 — Vấn đề mở
- [ ] Bảng Open Issues có định danh `O_{MODULE}_{N}`, liệt kê đầy đủ KPI liên quan
- [ ] Các blocker lớn thuộc Nhóm 3 (Gap Atomic/ngoại lai), Nhóm 4 (Join đa nguồn), Nhóm 5 (Datamart pending) đã được tạo Open Issue theo dõi và gán đúng trách nhiệm giải quyết (BA, Atomic, Datamart)

### erDiagram
- [ ] Mở bằng ` ```mermaid ` — KHÔNG phải ` ```erDiagram `
- [ ] Types chỉ dùng: `int` / `float` / `decimal` / `string` / `varchar` / `boolean` / `date` / `datetime` — `decimal` viết TRẦN, dùng cho trường tiền tệ/tỷ lệ tài chính cần độ chính xác cao (xem `reference/erdiagram_rules.md`). Chỉ cấm dạng có ngoặc `decimal(23,2)` vì gây parse error Mermaid
- [ ] Chỉ dùng label `PK` và `FK` — không có BK/DD
- [ ] `FK` chỉ xuất hiện trong Fact entity block và phải có `||--o{` tương ứng
- [ ] Tên entity dùng underscore (không dấu cách)
- [ ] Tên cột dùng Title_Case_With_Underscore
- [ ] Không thiết kế `Effective Date` / `Expiry Date` / `Population Date` / `Snapshot Date`
- [ ] **Scan toàn bộ erDiagram đã viết trong file trước khi xuất:** không có trường `Population_Date` / `Effective_Date` / `Expiry_Date` / `Snapshot_Date` trong bất kỳ entity block nào
- [ ] **Role-Playing Date FK trên Fact:** Tuyệt đối không có trường `Calendar_Date_Dimension_Id` trên bất kỳ Fact block nào (`Calendar_Date_Dimension_Id` chỉ là PK của `Calendar_Date_Dimension`). Fact Snapshot bắt buộc có `Snapshot_Date_Dimension_Id FK`. Fact Event bắt buộc có `<Role>_Date_Dimension_Id FK`. Phân định rõ với Degenerate Date (kiểu `date`, không gắn nhãn `FK`, không hậu tố `_Dimension_Id`).
- [ ] Toàn file HLD: mỗi bảng có số trường và tên trường giống hệt nhau ở mọi erDiagram
- [ ] **Tên trường trong erDiagram entity block phải khớp với `attribute.name` trong YAML Atomic entity tương ứng** — đọc YAML trước khi viết. Ví dụ sai: `Date_Of_Birth` khi YAML ghi `Birth_Date`; `Certificate_Type_Code` khi entity thực ra là FK surrogate + unique_key pair
- [ ] **Fact entity block trong erDiagram không chứa trường nào phản ánh trạng thái kỹ thuật nguồn** (VD: `Record_Status`, `Certificate_Status_Code` từ `record_status`) nếu staging đã lọc bản ghi hiệu lực — các trường này không có giá trị phân tích ở Datamart layer
- [ ] **Mọi entity xuất hiện trong quan hệ (`||--o{`, `}o--||`...) phải có block `{ ... }` định nghĩa field NGAY TRONG CÙNG khối `erDiagram`** — kể cả khi ghi chú "reuse/kế thừa từ Nhóm khác, không định nghĩa lại". Mỗi khối `erDiagram` là 1 render độc lập, không tự nhớ block đã vẽ ở khối khác. Xem `reference/erdiagram_rules.md` mục "Mọi entity xuất hiện trong quan hệ phải có block định nghĩa"

### Quy ước chung
- [ ] Chỉ dùng tên logical — không có physical name (snake_case) ở bất kỳ vị trí nào
- [ ] Node label trong flowchart và graph TB không dùng `\n`
- [ ] Nội dung nghiệp vụ bằng tiếng Việt có dấu; tên bảng/cột/entity giữ tiếng Anh

### Phase 2 — Entities Files

```
□ Đọc Section 3 HLD — không đọc Section 2 hay erDiagram từng nhóm
□ Đọc Section 4 HLD — lấy reuse_status cho từng bảng
□ Danh sách entity đầy đủ: tất cả fact + dim + operational trong Section 3 — TRỪ bảng PENDING toàn bộ (100% KPI/Nhóm dùng bảng đó PENDING, không có ngoại lệ) — loại khỏi CSV, liệt kê riêng trong Entities.md mục "Bảng PENDING"
□ table_type khớp với phân loại trong Section 3 (fact/dim/operational)
□ reuse_status lấy từ Section 4 — bắt buộc có cho mọi row
□ description + Grain lấy từ cột Grain/Mô tả của Section 3 — không tự suy luận
□ source_table tra từ dm_manifest.yaml (physical_name) — không đoán
□ FKs: chỉ điền cho fact, trống cho dim/operational
□ FKs: trích từ graph TB Section 3, format "{Dim Entity}.{FK Attribute Name}" (với Calendar Date Dimension: bắt buộc dùng role-playing như "{Calendar Date Dimension}.{Snapshot Date Dimension Id}" cho Fact Snapshot hoặc "{Calendar Date Dimension}.{<Role> Date Dimension Id}" cho Fact Event; TUYỆT ĐỐI CẤM "{Calendar Date Dimension}.{Calendar Date Dimension Id}")
□ status = draft toàn bộ rows
□ Thứ tự: Dimension → Fact → Operational
□ Export UTF-8 BOM (utf-8-sig)
□ Entities.md: erDiagram chỉ vẽ relationship lines — không vẽ attribute block
□ Entities.md: bảng entity tóm tắt có cột Datamart Entity / Loại / Reuse / Mô tả / Grain / KPI
```
