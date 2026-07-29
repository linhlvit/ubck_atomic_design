---
name: datamart-hld-design
description: |
  Thiết kế High-Level Design (HLD) cho Datamart layer — Phase 1 và Phase 2 trong workflow thiết kế Datamart UBCKNN.
  Sử dụng khi: bắt đầu thiết kế mới hoặc cập nhật HLD cho một module Datamart
  (TT/NHNCK/NDTNN/QLCB/FMS/GSTT/GSDC/QLKD/...).

  Output:
    Datamart/hld/DTM_{MODULE}_HLD.md                  (Phase 1)
    Datamart/hld/DTM_{MODULE}_Entities.csv             (Phase 2)
    Datamart/hld/DTM_{MODULE}_Entities.md              (Phase 2)
  Input bắt buộc: BA_analyst_{MODULE}.csv + Screenshot báo cáo + DataModel/Atomic/dm_manifest.yaml
---

# Skill: Thiết kế HLD Datamart

Đọc file này TRƯỚC KHI bắt đầu thiết kế HLD cho bất kỳ module nào.

## Tài nguyên đi kèm

- **Reference:**
  - [`reference/section_structure.md`](reference/section_structure.md) — 4 section cố định, format bảng KPI gộp READY+PENDING (Phase 1)
  - [`reference/flowchart_rules.md`](reference/flowchart_rules.md) — subgraph syntax, Calendar Date, node ID (Phase 1)
  - [`reference/erdiagram_rules.md`](reference/erdiagram_rules.md) — types hợp lệ, PK/FK only, naming (Phase 1)
  - [`reference/naming_conventions.md`](reference/naming_conventions.md) — tên bảng Fact/Dim/Operational, KPI ID (Phase 1)
  - [`reference/source_alias_mapping.md`](reference/source_alias_mapping.md) — bảng alias tên nguồn BA → Atomic (tra TRƯỚC KHI kết luận PENDING) (Phase 1)
  - [`reference/phase2_entities.md`](reference/phase2_entities.md) — Entities.csv + Entities.md format (Phase 2)
- **Examples:**
  - [`examples/erdiagram_correct.md`](examples/erdiagram_correct.md) — erDiagram đúng
  - [`examples/erdiagram_wrong.md`](examples/erdiagram_wrong.md) — 5 pattern sai erDiagram
  - [`examples/flowchart_correct.md`](examples/flowchart_correct.md) — flowchart đúng
  - [`examples/flowchart_wrong.md`](examples/flowchart_wrong.md) — pattern sai flowchart

## Điều kiện tiên quyết

- [ ] `BRD/BA/BA_analyst_{MODULE}.csv` tồn tại
- [ ] Screenshot báo cáo đã được upload
- [ ] `DataModel/Atomic/dm_manifest.yaml` tồn tại — entry point tra cứu Atomic entities (Nguồn 1, ưu tiên cao nhất)
- [ ] `DataModel/working/Atomic/lld/manifest.yaml` tồn tại — entry point tra cứu Atomic entities draft (Nguồn 2, chỉ tra khi Nguồn 1 không có)
- [ ] `DataModel/datamart_model.yaml` tồn tại — registry schema cross-module (có thể rỗng `entities: []` nếu module đầu tiên)

> **Cấm dùng `DataModel/working/Atomic_LinhLV/`** — track cũ đã revert, out of date. Xem chi tiết thứ tự ưu tiên 2 nguồn ở Bước 1 mục 3.

---

## QUY TRÌNH (BẮT BUỘC)

```
Phase 1:  Claude đọc input → check datamart_model.yaml → hỏi human phương án reuse
          → DỪNG chờ human xác nhận reuse_status từng bảng
          → thiết kế → xuất DTM_{MODULE}_HLD.md (gồm Section 4 Reuse Analysis)
          → DỪNG chờ human duyệt HLD.md

Phase 2:  Sau khi Phase 1 duyệt → đọc Section 3 + Section 4 HLD → xuất Entities.csv + Entities.md
          → DỪNG chờ human duyệt Entities.csv + Entities.md
```

> **GATE RULE — BẮT BUỘC TUYỆT ĐỐI:**
> - Claude **KHÔNG ĐƯỢC** tự bỏ qua bất kỳ GATE nào, dù không có khả năng reuse, dù kết quả có vẻ hiển nhiên.
> - Tại mỗi GATE: **DỪNG hoàn toàn**, đặt câu hỏi xác nhận rõ ràng, **chờ human trả lời** trước khi tiếp tục bất kỳ hành động nào.
> - Human chưa trả lời = chưa được phép tiếp tục. Không được suy diễn "im lặng = đồng ý".
> - Sau khi Phase 2 duyệt → chuyển sang skill `datamart-lld-design`.

---

## BƯỚC 1 — ĐỌC INPUT (thứ tự bắt buộc)

1. **BA file** (`BRD/BA/BA_analyst_{MODULE}.csv`) — extract toàn bộ dòng có `Trạng thái mapping ∈ {Done, Doing, Pending}`:

   > ⚠️ **Đọc CSV đúng cách:** File BA chứa cell multi-line (SQL, mô tả dài) — mỗi newline trong cell tạo thêm dòng vật lý. Đọc raw lines sẽ cho số dòng sai (VD: 452 chỉ tiêu nhưng 7358 dòng vật lý). **Bắt buộc dùng `csv.reader` với `delimiter=';'`** để parse đúng quoted multiline cells. STT trong file là số thứ tự nhóm/tab — mỗi STT = 1 nhóm duy nhất.
   >
   > ```python
   > import csv, io
   > with open('BA_analyst_{MODULE}.csv', encoding='utf-8-sig') as f:
   >     content = f.read()
   > reader = csv.reader(io.StringIO(content), delimiter=';')
   > rows = list(reader)
   > ```
   - `Phân loại = Chiều` → slicer/filter dimension — **phải có KPI_ID**, không được bỏ qua
   - `Phân loại = Cơ sở` + `Phái sinh` → KPI chỉ tiêu
   - Ghi nhận `Trạng thái mapping` — phân biệt Done/Doing/Pending
   - Ghi nhận cột **`Loại dữ liệu`** (`Dữ liệu tĩnh` / `Dữ liệu động`) cho từng dòng — dùng ở Bước 2 (Scope Gating) để quyết định READY/PENDING, độc lập với gating theo Atomic
   - ❌ Không bỏ qua dòng `Phân loại = Chiều` — đây là phần của bảng KPI, không chỉ là gợi ý thiết kế

2. **Screenshot** — xác định scope boundary (tab, nhóm, loại thông tin hiển thị)

3. **Tra cứu Atomic — 2 nguồn theo thứ tự ưu tiên (BẮT BUỘC theo đúng thứ tự này):**

   | Ưu tiên | Nguồn | Manifest | Coi là |
   |---|---|---|---|
   | **1 — luôn tra trước** | `DataModel/Atomic/` | `DataModel/Atomic/dm_manifest.yaml` | READY |
   | **2 — chỉ tra khi Nguồn 1 không có entry** | `DataModel/working/Atomic/` | `DataModel/working/Atomic/lld/manifest.yaml` | READY (draft đang hoàn thiện, nhưng vẫn dùng được cho Datamart) |

   - **Bước a:** Mở `DataModel/Atomic/dm_manifest.yaml` → tìm entry `physical_name` khớp. Có entry (bất kể `status: approved` hay `draft`) → **READY**, dùng nguồn này, KHÔNG cần tra tiếp Nguồn 2.
   - **Bước b:** Không có entry ở Nguồn 1 → tra `DataModel/working/Atomic/lld/manifest.yaml` (schema `lld_manifest`, field `source_system`/`source_table`/`atomic_entity`/`lld_file`) tìm entry khớp `atomic_entity`/`source_table` → có entry → **READY**, mở file `DataModel/working/Atomic/lld/{source_system}/{lld_file}`.
   - Không có entry ở cả 2 nguồn → **PENDING**.
   - Nếu tên nguồn trong BA không tìm thấy ở Nguồn 1 → tra [`reference/source_alias_mapping.md`](reference/source_alias_mapping.md) trước khi thử Nguồn 2 hoặc kết luận PENDING.
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
- [ ] **Đọc full SQL/công thức tham khảo của MỌI dòng BA trước khi kết luận nguồn Atomic** — không suy diễn tên bảng/cột nguồn chỉ từ tên KPI hoặc khái niệm nghiệp vụ. Bắt buộc mở nguyên văn ô Công thức/Mô tả (thường chứa SQL tham khảo) và trích đúng: tên bảng JOIN, tên cột, điều kiện filter/LIKE — rồi mới tra sang Atomic. KHÔNG được giả định "chắc dùng entity X" vì nhóm trước cùng module đã dùng X cho khái niệm nghiệp vụ tương tự.
- [ ] **Không copy pattern nguồn từ Nhóm trước khi chưa tự đọc SQL của chính dòng BA đang xét** — kể cả khi Nhóm N-1 đã xác nhận Atomic entity Y là nguồn đúng cho 1 khái niệm (VD: "Dư nợ margin"), Nhóm N nhắc lại đúng khái niệm đó KHÔNG được mặc định dùng lại Y. Phải tự đọc SQL riêng của Nhóm N — nếu BA đổi bảng/report code/sheet khác thì đó là nguồn khác, không reuse. Đây là nguyên nhân đã gây sai lặp lại nhiều lần trong thực tế (QLKD: hàng loạt Nhóm giả định dùng chung 1 entity EAV suy diễn theo tên, trong khi BA SQL thực tế của từng Nhóm chỉ ra các report_code/sheet_name/cột LIKE khác nhau hoàn toàn — phải re-verify từng Nhóm riêng lẻ mới phát hiện ra).

---

## BƯỚC 2 — SCOPE GATING

| KPI | Hành xử |
|---|---|
| Atomic READY + `Trang thai mapping = Done/Doing` | In-scope — thiết kế đầy đủ (READY) |
| Atomic READY + `Trang thai mapping = Pending` | PENDING — Atomic có nhưng Mart chưa sẵn sàng |
| Atomic READY + `Trang thai mapping = blank` | PENDING — xử lý như Pending |
| Atomic PENDING | PENDING — placeholder + lý do + Atomic cần bổ sung |
| Không tìm được Atomic | Out-of-scope — ghi nhận, KHÔNG thiết kế |

> **Rule quan trọng (từ thực tế thiết kế PTTT):** `Trang thai mapping = blank` **KHÔNG phải Out-of-scope** — xử lý như **Pending**. Out-of-scope chỉ áp dụng khi không tìm được Atomic entity phù hợp.

> **Pattern "Fact thiếu FK":** Atomic entity nguồn đã READY nhưng Fact hiện tại thiếu FK đến một chiều cần bổ sung (VD: `Member Report Indicator Value` đã có nhưng cần thêm `Securities Company Dimension` để breakdown per-CTCK) → vẫn là **PENDING**, lý do ghi là "Fact cần bổ sung FK đến [Dimension]", Atomic cần bổ sung ghi tên Fact + chiều cần thêm.

❌ Không reuse fact/dim từ module khác để lấp KPI thiếu Atomic.

### Gating bổ sung theo cột "Loại dữ liệu" (mọi Nhóm yêu cầu)

BA file có cột **"Loại dữ liệu"** với 2 giá trị: `Dữ liệu tĩnh` và `Dữ liệu động`. Đây là lớp gating **độc lập, áp dụng SAU** bảng gating theo Atomic ở trên — kể cả khi Atomic đã READY và `Trạng thái mapping = Done`, vẫn phải kiểm tra thêm cột này. Áp dụng cho **mọi Nhóm yêu cầu** (Dashboard, Data Explorer, ...), không chỉ riêng Dashboard.

| Loại dữ liệu | Ý nghĩa | Hành xử |
|---|---|---|
| `Dữ liệu tĩnh` | BA đã chốt logic mapping/nguồn cụ thể (bảng nguồn + trường nguồn + SQL tham khảo rõ ràng, không còn ghi chú "xác nhận lại") | Thiết kế **READY** theo đúng logic mapping BA cung cấp (nếu Atomic tương ứng cũng READY) |
| `Dữ liệu động` | Nguồn dữ liệu là báo cáo định kỳ/số liệu do phân hệ khác nộp — logic khai thác (bảng, cột, điều kiện lọc) **chưa được thống nhất**, dù BA có kèm SQL tham khảo. Dấu hiệu nhận biết: SQL có comment "xác nhận lại", "hỏi bên phân hệ xem lưu ở bảng nào" | **PENDING** — không đưa vào ETL/mapping chính thức đợt này, lý do ghi "Dữ liệu động — chưa thống nhất quy tắc khai thác" |
| `Chưa có CSDL - Map biểu mẫu` | Biến thể khác của `Dữ liệu động` — nguồn là báo cáo/biểu mẫu giấy định kỳ (VD: "BM 1_Báo cáo về khối lượng chứng khoán đang lưu hành", "BM 8_Danh sách cổ đông lớn") mà hệ thống **chưa có CSDL lưu trữ**, BA chỉ tham chiếu tên biểu mẫu chứ chưa xác định được bảng/cột thật | **PENDING** — xử lý giống hệt `Dữ liệu động`, lý do ghi "Chưa có CSDL - Map biểu mẫu — báo cáo giấy chưa tích hợp hệ thống" (GSTT, 2026-07-28: gặp ở "Số cổ phiếu lưu hành"/"Vốn hóa"/"P/E"/"P/B" nguồn VSDC BM1/BM8) |
| Cell chứa **nhiều giá trị cách nhau bởi dấu phẩy** (VD: `Dữ liệu tĩnh, Chưa có CSDL - Map biểu mẫu`) | Measure tổng hợp từ nhiều nguồn con có mức độ sẵn sàng khác nhau (VD: "Vốn hóa" = Giá đóng cửa (tĩnh) × Số cổ phiếu lưu hành (chưa có CSDL)) | Áp dụng **mức thấp nhất** trong tập giá trị — có bất kỳ thành phần nào `Dữ liệu động`/`Chưa có CSDL - Map biểu mẫu` → cả dòng PENDING, dù có thành phần khác đã tĩnh |

> **Lưu ý — không tự suy diễn từ tên cột:** Đừng cho rằng "Chiều" luôn tĩnh và "Chỉ tiêu" luôn động. Trong 1 nhóm, cả Chiều lẫn Chỉ tiêu đều có thể là `Dữ liệu động` (VD: "Chiều thời gian theo ngày" lấy từ bảng báo cáo định kỳ `MEMBER_REPORT.DATA_DATE` → động, trong khi cùng nhóm đó "Chiều Trạng thái công ty" lấy từ danh mục hệ thống → tĩnh). Đọc đúng giá trị cột "Loại dữ liệu" của từng dòng, không suy đoán theo `Phân loại`.

> **Ví dụ thực tế (QLKD Nhóm 1 — Chỉ tiêu thống kê chung, 13/07/2026):** K_QLKD_1–9 (tổng CTCK + 7 trạng thái) đánh `Dữ liệu tĩnh` — nguồn `SC_FIRM_INFO` + `CAT_SC_FIRM_STATUS` (danh mục hệ thống, logic rõ ràng) → READY. K_QLKD_10–11 (số TK phát sinh GD, số dư tiền gửi) đánh `Dữ liệu động` — nguồn `REPORT_CELL_VALUE`/`CAT_INDICATOR` (báo cáo định kỳ), SQL kèm note "Hỏi bên phân hệ xem lưu ở bảng nào, cột nào, dòng nào?" → PENDING dù Atomic `Member Report Indicator Value` đã READY.

> **Trong 1 Nhóm có cả tĩnh lẫn động (rất phổ biến):** Cả 2 loại dòng KPI nằm CHUNG 1 bảng KPI duy nhất (7 cột: KPI ID/Tên/Đơn vị/Tính chất/Công thức/Ghi chú/Trạng thái) — theo đúng Bước 2 Scope Gating: dòng tĩnh đánh Trạng thái = READY (điền đủ Đơn vị/Công thức), dòng động đánh Trạng thái = PENDING (Đơn vị/Công thức để trống hoặc "TBD — chờ Atomic", cột Ghi chú chứa Lý do pending/Atomic cần bổ sung/Mart dự kiến). KHÔNG tách thành 2 block/2 bảng riêng theo trạng thái. Nếu measure động vốn được thiết kế nằm chung Fact với các measure tĩnh (VD: cùng `Fact X Snapshot`), ghi rõ trong Ghi chú của dòng đó: "measure này KHÔNG lưu trên [Fact] ở giai đoạn hiện tại — bổ sung khi thống nhất xong".
>
> **Nếu measure "động" là cột điều kiện snapshot/grain (VD: Calendar Date dùng để so sánh `<= ngày`)** — không thể pending cả Fact chỉ vì 1 cột ngày động. Trước khi kết luận PENDING, kiểm tra xem BA có chỉ định nguồn ngày thay thế (một cột ngày khác, đã tĩnh, cùng ý nghĩa nghiệp vụ) hay không — nếu có, dùng nguồn thay thế đó và ghi chú lý do đổi nguồn; chỉ pending nếu không có nguồn thay thế nào tĩnh.

## BƯỚC 3 — CHECK REUSE (DATAMART MODEL)

**Mục tiêu:** Tối đa hóa tái sử dụng bảng đã có trong `datamart_model.yaml` trước khi đề xuất bảng mới. Thực hiện theo 4 lớp kiểm tra theo thứ tự — **dừng ngay khi đã xác định được reuse_status**, không kiểm tra lớp tiếp theo.

**Thực hiện:** Đọc toàn bộ `Datamart/datamart_model.yaml` một lần duy nhất trước khi bắt đầu phân tích — không đọc lại từng lần.

---

### Lớp 1 — Conformed Dimension Whitelist (không phụ thuộc source match)

Một số Dimension được thiết kế dùng chung toàn hệ thống. **Bất kể module nào, bất kể BA ghi nguồn gì** — nếu nhóm thông tin cần các chiều dưới đây thì **luôn reuse**, không tạo mới:

| Datamart table | Logical name | Khi nào reuse |
|---|---|---|
| `cdr_dt_dim` | Calendar Date Dimension | Mọi Fact có chiều thời gian |
| `cl_dim` | Classification Dimension | Mọi chiều phân loại có nguồn từ Classification Value (CV) Atomic — xem Lớp 2 |

> ❌ **KHÔNG tạo `Calendar Date Dimension` mới** dù không tìm thấy trong source match. Luôn reuse `cdr_dt_dim`.

---

### Lớp 2 — Classification Value → cl_dim (filter theo scheme)

**Áp dụng khi:** Nhóm thông tin cần một chiều phân loại dạng danh mục (ngành nghề, loại hình, trạng thái...) mà nguồn Atomic là `Classification Value` (bảng `cv`).

**Quy trình:**
1. Xác định scheme CV cần dùng (VD: `IDS_INDUSTRY_CATEGORY`, `CERTIFICATE_TYPE`...)
2. **Kiểm tra `ldm.physical_name` trong YAML Atomic entity nguồn:**
   - `physical_name = cv` → dữ liệu phân loại lưu trong bảng CV → **reuse `cl_dim`**
   - `physical_name ≠ cv` (entity riêng) → Atomic thiết kế entity này độc lập → **tạo Dimension riêng**, KHÔNG reuse `cl_dim`
3. Trong thiết kế reuse `cl_dim`: ghi rõ FK tên `Classification Dimension Id` + ghi chú scheme trong cột Ghi chú / Bảng grain

**Lý do quan trọng:** `cl_dim` chỉ là projection của bảng `cv` Atomic. Nếu Atomic không lưu thông tin đó trong `cv` thì `cl_dim` không có dữ liệu đó — không thể reuse.

> ❌ **KHÔNG tạo Dimension mới** khi `cl_dim` đã tồn tại và Atomic lưu dữ liệu trong `cv`.
> ❌ **KHÔNG reuse `cl_dim`** khi Atomic lưu dữ liệu trong entity riêng (`physical_name ≠ cv`) — dù tên scheme nghe có vẻ là "phân loại".

**Ví dụ đúng:**
- BA cần chiều "Ngành nghề kinh tế cấp 1" từ `IDS.categories` → tra YAML → `physical_name = cv` (scheme `IDS_INDUSTRY_CATEGORY`) → reuse `cl_dim`
- BA cần chiều "Loại CCHN" từ `NHNCK.CERTIFICATES` → tra YAML → `physical_name = sp_license_certificate_type` → tạo `sp_license_ctf_tp_dim` mới, KHÔNG reuse `cl_dim`

---

### Lớp 3 — Source Match (cùng nguồn Atomic)

**Áp dụng khi:** Bảng đích không thuộc Lớp 1 hoặc Lớp 2.

**Bước 3a — Xác định Atomic source** từ BA analyst (cột Nguồn):
- Đọc cột Nguồn tại từng nhóm thông tin → tra `dm_manifest.yaml` lấy `physical_name` (= `atomic_table` vật lý)
- Nếu BA ghi tên nguồn chung (VD: "NHNCK") → đọc tất cả entry trong manifest có `source` khớp, lấy tất cả `physical_name` liên quan

**Bước 3b — Tìm trong `datamart_model.yaml`** theo `source_atomic`:
- Duyệt qua `entities` → tìm entry có `source_atomic` chứa `physical_name` đang xét
- Không tìm thấy → `new`, chuyển sang Lớp 4 để kiểm tra Fact partial

**Bước 3c — Nếu tìm thấy** (cùng nguồn Atomic đã được dùng):
- Lấy `datamart_table` + `table_type` + số cột hiện có (`columns` list) từ model
- So sánh `table_type` + grain mục đích:

| Điều kiện | Hành xử |
|---|---|
| `table_type` khác nhau | `new` |
| `table_type` giống, grain/mục đích giống | → Lớp 4 kiểm tra partial |
| `table_type` giống, grain/mục đích khác hẳn | `new` |

---

### Lớp 4 — Fact/Dim Partial (thêm cột vào bảng hiện có)

**Áp dụng khi:** Đã tìm thấy bảng cùng loại + cùng grain từ Lớp 3, hoặc cần bổ sung measure/attribute vào Fact đã có.

**Câu hỏi kiểm tra:**
- Fact hiện có đủ các measure/FK cần thiết cho nhóm này chưa?
- Nếu thiếu measure → `partial` (thêm cột, không tạo Fact mới)
- Nếu thiếu FK đến Dimension mới → vẫn `partial` (thêm FK + Dimension)
- Nếu grain thực sự khác → `new`

**Báo cáo human khi phát hiện khả năng reuse (Lớp 3 hoặc 4):**

```
Phát hiện khả năng reuse:
  Nguồn Atomic: [atomic_table]
  Bảng đã có trong datamart_model.yaml: [datamart_table] (table_type: dim/fact/operational, N cột hiện có)
  Bảng đang thiết kế: [tên mới đề xuất]
  Grain hiện tại: [grain bảng đã có]
  Grain cần thiết: [grain nhóm này]

Đề xuất:
  (a) reuse — tái sử dụng toàn bộ [datamart_table] hiện có (không thêm cột)
  (b) partial — thêm cột/FK vào [datamart_table] hiện có
  (c) new — tạo bảng mới (grain/mục đích thực sự khác)

→ Human chọn phương án
```

---

### Tổng hợp và hỏi human (GATE — bắt buộc dừng)

Sau khi chạy qua 4 lớp cho **tất cả bảng** trong module, trình bày bảng tóm tắt:

```
Kết quả phân tích reuse (4 lớp):

| Datamart Entity | datamart_table | Lớp phát hiện | reuse_status đề xuất | Lý do |
|---|---|---|---|---|
| Calendar Date Dimension | cdr_dt_dim | L1 — Whitelist | reuse | Conformed Dim toàn hệ thống |
| Classification Dimension | cl_dim | L2 — CV scheme | reuse | scheme IDS_INDUSTRY_CATEGORY đã có trong cl_dim |
| Fact Listed Bond Snapshot | fct_lst_bnd_snpst | L3 — source match | partial | Cùng nguồn scr_trd, cần thêm cột OTC_Bond_Trading_Value |
| Fact New Fact | fct_new | L3 — source match | new | Chưa có trong master |

→ Xác nhận reuse_status từng bảng để tiến hành thiết kế?
```

> ❌ **KHÔNG được tự tiếp tục thiết kế** khi chưa có xác nhận của human — dù toàn bộ bảng đều là `new`.

**Ghi kết quả vào Section 4 HLD.md** (xem format bên dưới)

> **Lưu ý:** `datamart_model.yaml` rỗng (`entities: []`, module đầu tiên) → toàn bộ bảng là `new`, vẫn phải trình bày bảng tóm tắt và chờ human xác nhận.

---

### Áp dụng reuse khi thiết kế từng nhóm (Section 2)

**Bước kiểm tra bắt buộc TRƯỚC KHI đề xuất bảng đích cho mỗi nhóm:**

1. Chiều thời gian → Lớp 1: luôn là `cdr_dt_dim`
2. Chiều phân loại/danh mục → Lớp 2: kiểm tra CV scheme → nếu có thì `cl_dim`
3. Fact/Dim khác → Lớp 3: match source → Lớp 4: kiểm tra partial

**Trong bảng KPI (cột Ghi chú) và Bảng grain:** ghi rõ reuse_status và scheme/filter khi áp dụng Lớp 1 hoặc Lớp 2. Ví dụ:
- `Calendar Date Dimension — reuse (cdr_dt_dim)`
- `Classification Dimension — reuse cl_dim, filter scheme = 'IDS_INDUSTRY_CATEGORY'`

### Section 4 — Reuse Analysis trong HLD.md

Thêm section này vào cuối file HLD, sau Section 3:

```markdown
## Section 4 — Reuse Analysis

| Datamart Entity | datamart_table | reuse_status | Ghi chú |
|---|---|---|---|
| Calendar Date Dimension | cdr_dt_dim | reuse | Đã có trong master — không thêm nguồn mới |
| Branch Dimension | dim_branch | partial | Đã có nguồn FLEX. Module này thêm nguồn NHNCK |
| Fact ATM Transaction | fct_atm_txn | new | Chưa có trong master |
```

> Section 4 là nguồn sự thật cho Phase 2 — Entities: cột `reuse_status` trong Entities.csv đọc trực tiếp từ đây.

---

## BƯỚC 4 — PHÂN LOẠI BẢNG DATAMART

| Loại | Khi nào | Pattern |
|---|---|---|
| **Phân tích** | KPI aggregate nhiều đối tượng / nhiều kỳ | Star Schema — Fact + Dim |
| **Tác nghiệp** | Lookup 1 đối tượng cụ thể | Denormalized Table — 1 row per đối tượng |

### BƯỚC 4B — GRAIN-MATCHING CHO MEASURE (bắt buộc, trước khi đặt bất kỳ measure nào lên Fact)

> **Bài học (module TT, 2026-07-21):** Đã quen kiểm tra fanout cho **key/business code** khi tách Fact grain N (Nhóm 4/9/13/14 — degenerate key của bảng cha bị lặp lại per-row, phải tách Dimension riêng có BK per-row unique). Nhưng **measure (số đo, cột định lượng) cũng bị fanout y hệt khi SUM**, và lỗi này KHÔNG bị bất kỳ TC nào ở trên bắt được vì nó không liên quan đến key — nó nằm ở việc chọn sai **cấp grain của con số**. Phát hiện thực tế: `Fact Penalty Decision Subject Behavior` (grain 1 QĐ × 1 đối tượng × 1 hành vi) gắn `Total_Fine_Amount` lấy từ driving table `Penalty Decision` (grain 1 QĐ) — khi 1 QĐ có nhiều đối tượng/hành vi, Fact sinh nhiều dòng đều mang cùng 1 số tiền của QĐ đó, khiến `SUM(Total_Fine_Amount)` ở Nhóm dùng chung (Nhóm 20 — Báo cáo) đếm lặp gấp nhiều lần số tiền phạt thật.

**Nguyên tắc:** 1 measure chỉ được đặt lên Fact có grain **đúng bằng** grain phát sinh ra số đó — không mịn hơn (finer). Nếu Fact có grain mịn hơn cấp phát sinh của con số (do 4-way join, N:1 join...), measure đó **không được copy thẳng từ driving table cha** vào Fact.

**Quy trình bắt buộc khi thiết kế Fact có measure:**

1. Với mỗi measure định lượng (Currency Amount, số đo cộng dồn...) định đưa vào Fact: xác định measure đó phát sinh ở **Atomic entity nào**, và entity đó có grain gì (1 dòng đại diện cho gì).
2. So sánh grain của measure với grain của Fact đang thiết kế:
   - Grain measure = grain Fact → đặt measure trực tiếp lên Fact, an toàn.
   - Grain measure **thô hơn** grain Fact (Fact có thêm N lớp join so với entity chứa measure) → **KHÔNG đặt measure đó lên Fact này**. Xử lý một trong các cách:
     - Tìm measure cùng ý nghĩa nghiệp vụ nhưng lưu ở đúng cấp grain hơn (VD: Atomic có sẵn cả `Penalty_Decision.Total_Fine_Amount` (per-QĐ) VÀ `Penalty_Decision_Subject.Total_Fine_Amount` (per-đối tượng) — ưu tiên cái khớp gần nhất với grain Fact).
     - Nếu vẫn còn lệch grain sau khi đổi nguồn (VD: measure per-đối tượng nhưng Fact per-đối tượng×hành vi) → **không SUM trực tiếp trên Fact**; công thức KPI phải pre-aggregate (GROUP BY/DISTINCT theo key ở đúng cấp grain của measure) trước khi SUM ở tầng ngoài. Ghi rõ công thức pre-aggregate này trong Ghi chú Nhóm, không chỉ ghi "SUM(measure)" trơn.
     - Nếu không tìm được nguồn nào khớp — tách 1 Fact riêng đúng grain của measure đó (như đã làm cho key ở Bước tách Dimension), không gộp chung với Fact đang thiết kế.
3. Trường hợp measure ở cấp grain thô hơn không thể chia tách chính xác về cấp mịn hơn khi 1 bản ghi cha có nhiều bản ghi con thuộc **các nhóm phân loại khác nhau** (VD: 1 đối tượng có 2 hành vi thuộc 2 nhóm "Loại hình xử lý" khác nhau, nhưng chỉ có 1 số tiền phạt chung cho cả đối tượng) — đây là giới hạn dữ liệu nguồn, không phải lỗi thiết kế. Ghi nhận rõ trong Ghi chú Nhóm (không phải Open Issue) để BA/nghiệp vụ biết và chấp nhận.
4. **Không tự tin measure "chắc an toàn" chỉ vì đang COUNT, không SUM`** — quy tắc này áp dụng cho MỌI measure định lượng cộng dồn, độc lập với việc Fact đó có đang bị lỗi fanout key (COUNT/DISTINCT) hay không. 2 vấn đề (key fanout khi COUNT, measure fanout khi SUM) độc lập nhau và phải kiểm tra riêng.

## BƯỚC 5 — THIẾT KẾ VÀ XUẤT FILE

Đọc [`reference/section_structure.md`](reference/section_structure.md) để biết format 4 section.
Đọc [`reference/flowchart_rules.md`](reference/flowchart_rules.md) trước khi vẽ Lineage.
Đọc [`reference/erdiagram_rules.md`](reference/erdiagram_rules.md) trước khi vẽ Star Schema.
Đọc [`reference/naming_conventions.md`](reference/naming_conventions.md) trước khi đặt tên bảng/KPI.

**Output:** `Datamart/hld/DTM_{MODULE}_HLD.md`

Tạo thư mục nếu chưa có. Thông báo đường dẫn file.

## BƯỚC 5B — REVIEW CUỐI TOÀN FILE (bắt buộc, sau khi viết xong toàn bộ HLD, TRƯỚC GATE Phase 1)

> **Vì sao cần bước riêng:** Checklist "TRƯỚC KHI BÀN GIAO" ở dưới được áp dụng per-Nhóm trong lúc thiết kế — nhưng một số lỗi chỉ lộ ra khi nhìn **toàn file cùng lúc** (VD: 1 entity được định nghĩa đầy đủ ở Nhóm 1 nhưng bị tham chiếu rỗng ở Nhóm 2/3/6 vì mỗi khối `erDiagram`/`flowchart` là 1 render độc lập, không tự nhớ nội dung khối khác). Bước này quét lại toàn bộ file sau khi đã viết xong, dùng script thay vì đọc mắt để không bỏ sót.

> **Áp dụng cả khi CHỈNH SỬA/ĐIỀU CHỈNH một phần của HLD đã tồn tại** (không chỉ khi thiết kế mới từ đầu) — kể cả khi phạm vi yêu cầu chỉ là "sửa lại Nhóm N". Vì các mục kiểm tra dưới đây quét **toàn file**, một thay đổi cục bộ (thêm/sửa 1 Nhóm) vẫn có thể làm lộ ra hoặc để sót lỗi cấu trúc đã tồn tại từ trước ở phần không đụng tới — bỏ qua Bước 5B chỉ vì "task chỉ yêu cầu sửa 1 Nhóm" đã gây sót lỗi thực tế (TT — sửa lại Nhóm 1 theo Atomic schema mới nhưng không chạy mục #0 nên bỏ sót toàn bộ file thiếu Section 4 — Reuse Analysis, heading Cụm sai cấp, bảng KPI thiếu cột Ghi chú, vốn có từ bản gốc 20260427 và không liên quan gì đến thay đổi đang làm).

Chạy các kiểm tra sau (Python/grep) trên toàn file `DTM_{MODULE}_HLD.md` vừa xuất/vừa sửa:

0. **Cấu trúc Section đúng chuẩn `reference/section_structure.md`** — chạy TRƯỚC các mục kỹ thuật bên dưới, vì đây là kiểm tra cấp cao nhất:
   - Đếm số Section (`## Section N`) — phải là 4 (`Data Lineage`/`Tổng quan báo cáo`/`Mô hình tổng thể`/`Vấn đề mở`) hoặc 5 nếu đủ điều kiện biến thể (`... + Reuse Analysis` trước `Vấn đề mở`). Thiếu hẳn 1 Section, hoặc "Vấn đề mở" nằm sai vị trí (không phải Section cuối) → lỗi cấu trúc, phải sửa trước khi hỏi GATE.
   - Heading Cụm trong Section 1 phải đúng cấp `##### Cụm N: ...` (5 dấu `#`) — không phải `###`/`####`.
   - Mọi bảng KPI của mỗi Nhóm phải đủ 7 cột theo `section_structure.md` (`KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái`) — 1 bảng duy nhất chứa cả dòng READY lẫn PENDING, không tách 2 bảng/2 block theo header `##### READY`/`##### PENDING`.
   - Nếu dùng biến thể 5-Section: mỗi bảng Fact/Dim/Operational trong Section 3 phải có ít nhất 1 dòng tương ứng trong Section 4 — Reuse Analysis.
1. **erDiagram — entity trong quan hệ phải có block định nghĩa cùng khối:** Với mỗi khối ` ```mermaid\nerDiagram `, liệt kê entity xuất hiện trong quan hệ (`A ||--o{ B`, `A }o--|| B`...) và entity có block `{ ... }` — báo lỗi nếu có entity ở quan hệ mà không có block. Đây là lỗi thực tế đã xảy ra (QLCB Nhóm 2/3/6, TT Nhóm 4/9/13/14 — xem `reference/erdiagram_rules.md`). Viết script quét **per-block** (tách từng khối erDiagram trước khi tìm entity bên trong) — quét bằng 1 regex `[^}]*` chạy xuyên suốt toàn file sẽ nhầm ranh giới khi ≥2 entity nằm trong cùng khối, cho kết quả false positive/negative.
2. **erDiagram — không có Fact-to-Fact reference:** với mỗi dòng quan hệ `A ||--o{ B`, entity A (vế trái) không được có tên bắt đầu bằng `Fact_`/`Fact ` — vế trái luôn phải là Dimension (xem `reference/erdiagram_rules.md`, mục "Cấm Fact-to-Fact reference"). Nếu phát hiện `Fact_X ||--o{ Fact_Y`, đây là lỗi thiết kế thật (đã xảy ra ở TT — Fact-to-Fact reference thay vì tách Dimension riêng), không phải lỗi cú pháp — phải quay lại BƯỚC 4B đánh giá tách Dimension cho entity X.
3. **erDiagram — mọi Dimension/Operational entity có `Source_System_Code`:** với mỗi block `{ ... }` có tên kết thúc bằng `_Dimension` (trừ `Calendar_Date_Dimension`, có schema cố định riêng — xem mục "Calendar Date Dimension — schema chuẩn bắt buộc") hoặc là bảng Operational, phải chứa dòng `string Source_System_Code`. Thiếu cột này ở 1 Dimension mới tách ra giữa chừng (không qua flow BƯỚC 4B đầy đủ) là lỗi thực tế đã xảy ra ở TT (5 Dimension mới tách thiếu `Source_System_Code` dù rule đã có sẵn ở `erdiagram_rules.md`) — nguyên nhân: rule tồn tại ở reference nhưng không nằm trong checklist tự động này, nên bị bỏ sót khi chỉnh sửa cục bộ thay vì generate lại từ đầu.
4. **Section 1 flowchart — subgraph label đúng chuẩn:** mọi khối flowchart trong Section 1 phải có đúng 3 subgraph `SRC["Staging"]` / `SIL["Atomic"]` / `GOLD["Datamart"]`.
5. **Section 1 flowchart — mỗi Cụm đúng 1 bảng Datamart:** đếm entry trong subgraph GOLD trừ Dimension — phải bằng 1 (xem `reference/flowchart_rules.md`).
6. **Node ID Staging không chứa dấu chấm** (`\w+\.\w+\[` trong node ID là lỗi parse mermaid).
7. **Code fence cân bằng:** đếm số dòng ` ``` ` trong toàn file — phải là số chẵn.
8. **KPI_ID liên tục, không trùng lặp:** trích toàn bộ `K_{MODULE}_\d+`, kiểm tra dải số liên tục từ 1 đến max, không có ID nào xuất hiện ở ≥2 dòng bảng KPI khác nhau (trừ dòng ghi chú "Reuse từ Nhóm X" — đó là tham chiếu, không phải khai sinh trùng).
9. **Mọi node Atomic dùng làm nguồn Dimension/Fact có tồn tại thật trong `DataModel/Atomic/` (ưu tiên 1) hoặc `DataModel/working/Atomic/` (ưu tiên 2)** — **KHÔNG bao gồm `DataModel/working/Atomic_LinhLV/`** (out of date, cấm dùng dù entity tồn tại ở đó). Không suy diễn theo tên nghe hợp lý (VD: "Classification Value" — nếu module không có entity Atomic nào tên này ở 2 nguồn hợp lệ, không được vẽ node đó dù nghe đúng khái niệm nghiệp vụ; xem case thực tế QLCB `Offering Method Dimension` — code nằm trực tiếp trên `Public Company Securities Offering Plan.offering_method_code`, không có bảng CV riêng).
10. **Số lượng dòng con BA khớp số dòng KPI trong bảng KPI của từng Nhóm** — với mỗi Nhóm (1 STT), đếm chính xác số dòng con (sub-row) BA thuộc STT đó bằng `csv.reader` (không đọc raw line), rồi đếm số dòng trong bảng KPI của Nhóm đó (kể cả dòng PENDING). Hai số này phải khớp 1-1: mỗi dòng con BA → đúng 1 dòng bảng KPI, dù dòng đó là khai sinh KPI mới, reuse KPI đã có (ghi "Reuse từ Nhóm X"), hay trùng lặp với 1 KPI khác (ghi rõ "trùng KPI Y, không khai KPI mới" trong cột Ghi chú — nhưng KHÔNG được lược bỏ hẳn dòng khỏi bảng KPI). Nếu 2 số lệch nhau → rà lại từng dòng con BA để tìm dòng bị bỏ sót (thường là chỉ tiêu ít nổi bật như 1 chiều slicer phụ, VD "theo giờ trong ngày") trước khi báo Nhóm đó hoàn tất. Lỗi thực tế đã xảy ra (GSTT Nhóm 5 — 23 dòng con BA nhưng chỉ 22 dòng KPI, thiếu chiều "Theo giờ trong ngày"; chỉ phát hiện được vì user tự đếm thủ công, không phải do self-check).

Nếu phát hiện lỗi ở bất kỳ mục nào trên — sửa ngay trong file, chạy lại kiểm tra đến khi sạch, rồi mới tiếp tục tới GATE bên dưới.

> **Bắt buộc chạy lại Bước 5B sau MỖI lần chỉnh sửa cục bộ giữa hội thoại** (thêm/sửa 1 Nhóm, tách 1 Dimension, đổi FK...), không chỉ 1 lần duy nhất sau khi viết xong toàn bộ HLD lần đầu. Lý do thực tế: 1 chuỗi sửa liên tiếp trên module TT (đánh giá measure fanout → tách Dimension → phát hiện Fact-to-Fact sai → sửa lại lần 2) chỉ chạy self-check thủ công một phần (chỉ mục #1, bỏ sót mục #3 vì lúc đó chưa tồn tại trong checklist) — mỗi lần chỉnh sửa cục bộ là 1 điểm có thể lộ lỗi mới hoặc để sót lỗi cũ, không đợi đến "xong hẳn" mới quét 1 lần.

> **GATE — bắt buộc dừng:** Sau khi xuất file và hoàn tất Bước 5B, đặt câu hỏi: "HLD.md đã được tạo tại [đường dẫn], đã chạy review cuối (Bước 5B). Bạn xác nhận để chuyển sang Phase 2?"
> ❌ **KHÔNG được tự chuyển sang Phase 2** khi chưa có xác nhận của human.

---

## PHASE 2 — ENTITIES FILES

Đọc [`reference/phase2_entities.md`](reference/phase2_entities.md) đầy đủ trước khi bắt đầu.

### Điều kiện tiên quyết Phase 2

- [ ] `Datamart/hld/DTM_{MODULE}_HLD.md` đã được user duyệt (Phase 1 hoàn thành)
- [ ] `DataModel/Atomic/dm_manifest.yaml` tồn tại

### Nguồn sự thật: Section 3 + Section 4 HLD

**Thông tin cho Entities nằm trong Section 3 và Section 4 của `DTM_{MODULE}_HLD.md`** — không cần đọc Section 2 hay erDiagram từng nhóm.

| Cột Entities | Lấy từ đâu |
|---|---|
| `datamart_entity` | Section 3 — tên bảng trong bảng Phân tích / Tác nghiệp / Dimension |
| `table_type` | Section 3 — `fact` (Phân tích), `operational` (Tác nghiệp), `dim` (Dimension) |
| `reuse_status` | **Section 4** — cột `reuse_status` đã được human xác nhận |
| `status` | Luôn `draft` |
| `description` + Grain | Section 3 — cột Grain / Mô tả |
| `source_table` | Section 3 — cột "Nguồn Atomic chính" → tra `dm_manifest.yaml` lấy `physical_name` (`atomic_table`) |
| `FKs` | Section 3 — graph TB (`DIM_X --> FACT_Y`) |

### Rule trích xuất `FKs` từ graph TB

Graph TB trong Section 3 dùng mũi tên `DIM_X --> FACT_Y`. Với mỗi mũi tên:
1. Xác định tên Dimension entity (node nguồn) và Fact entity (node đích)
2. Tên FK attribute = `{Dim Entity Name} Id` — ví dụ: `Calendar Date Dimension` → FK = `Calendar Date Dimension Id`
3. Format cột `FKs`: `{Dim Entity Name}.{FK Attribute Name}`, nhiều FK nối bằng ` | `

> `FKs` chỉ điền cho bảng `fact` — để trống cho `dim` và `operational`.

### Output Phase 2

- `Datamart/hld/DTM_{MODULE}_Entities.csv`
- `Datamart/hld/DTM_{MODULE}_Entities.md`

> **GATE — bắt buộc dừng:** Sau khi xuất 2 file, đặt câu hỏi: "Entities.csv và Entities.md đã được tạo tại [đường dẫn]. Bạn xác nhận để chuyển sang skill `datamart-lld-design`?"
> ❌ **KHÔNG được tự chuyển sang LLD** khi chưa có xác nhận của human.

---

## CHECKLIST TRƯỚC KHI BÀN GIAO

### Section 1 — Data Lineage
- [ ] **Mỗi Cụm chỉ 1 bảng Datamart duy nhất** — 1 Fact hoặc 1 bảng Tác nghiệp, không gộp nhiều Fact chung 1 Cụm dù cùng Atomic entity cha. Tách thành nhiều Cụm riêng (1a, 1b, 1c...), chấp nhận lặp lại node Atomic entity cha ở nhiều flowchart. Xem `reference/flowchart_rules.md` mục "Mỗi Cụm chỉ 1 bảng Datamart"
- [ ] Mỗi flowchart có đủ 3 subgraph: `SRC["Staging"]` / `SIL["Atomic"]` / `GOLD["Datamart"]`
- [ ] Staging: 1 subgraph duy nhất, prefix table name thể hiện nguồn (VD: `FMS.RPTVALUES`)
- [ ] Mọi Cụm có Fact: `ECAT.ECAT_29_HolidayInfo` trong Staging + `Calendar Date` trong Atomic + `Calendar Date Dimension` trong Datamart
- [ ] Node Staging dùng `ID["label"]` — ID không có dấu chấm
- [ ] Node Atomic dùng `ID["label"]` — ID dùng `_`, label bỏ `_`
- [ ] Node Datamart dùng `ID["label"]` — ID = physical name, label = logical name
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
- [ ] **Dòng KPI PENDING trong bảng KPI chung:** cột Đơn vị/Công thức để trống hoặc ghi "TBD — chờ Atomic"; cột Ghi chú chứa đủ 3 phần súc tích — Lý do pending / Atomic cần bổ sung / Mart dự kiến (chỉ tên bảng + grain)
- [ ] **Bảng mapping nguồn (Atomic Placeholder)** — chỉ thêm khi Nhóm có ít nhất 1 dòng PENDING, đặt sau Bảng grain (hoặc sau Bảng KPI nếu Nhóm 100% PENDING); mỗi dòng = 1 Atomic entity, điền đủ Bảng nguồn BA + Atomic entity dự kiến + Atomic table dự kiến (TBD nếu chưa rõ); chỉ liệt kê KPI đang PENDING, không lặp lại KPI READY
- [ ] **Mỗi cột trong Fact phải trace được về KPI/mockup của Nhóm đó** — sau khi viết xong bảng KPI, rà lại từng cột trong Fact block: cột nào không xuất hiện trong bất kỳ công thức KPI nào → loại khỏi Star Schema, trừ khi là FK trục thời gian/dimension chính hoặc là điều kiện ETL filter SCD4A đã ghi chú riêng bằng text (xem `reference/erdiagram_rules.md`). Không đưa nguyên attribute còn lại của Atomic entity nguồn vào Fact "cho đủ"
- [ ] **Bảng KPI chỉ có 1 bảng duy nhất cho toàn Nhóm** — KHÔNG tách thành `*KPI mới:*` và `*KPI reuse:*` thành 2 bảng riêng, KHÔNG tách theo trạng thái READY/PENDING. Reuse được liệt kê cùng bảng với KPI mới; cột "Ghi chú" đánh dấu nguồn gốc reuse
- [ ] **Lineage Mart → Báo cáo chỉ vẽ nếu Nhóm có ít nhất 1 dòng READY, chỉ vẽ từ Datamart lên báo cáo** — KHÔNG vẽ Atomic entities trong flowchart này. Node bắt đầu phải là bảng Fact/Dim/Operational (physical name trong GOLD layer), không phải Atomic entity
- [ ] **Lineage Mart → Báo cáo gộp 1 report node duy nhất cho toàn bộ Nhóm** — KHÔNG tách report node riêng theo từng Chiều/KPI/measure. Ghi dạng `"K_{MODULE}_N-M,X,Y: {Tên Nhóm}"` liệt kê dải/danh sách KPI ID **đang READY** trong 1 node duy nhất (không đưa ID PENDING vào node báo cáo) (xem ví dụ đúng/sai trong `reference/section_structure.md`)
- [ ] **KPI Done (sub-component) đã khai sinh ở Nhóm trước → reuse vào cùng bảng KPI, đánh dấu Trạng thái theo đúng trạng thái thật** (READY nếu Atomic sẵn sàng, PENDING nếu chưa) — không tách riêng theo vị trí bảng
- [ ] Dòng KPI PENDING không có Star Schema, erDiagram, Lineage flowchart riêng
- [ ] KPI đang PENDING không tạo Open Issue (Section 4/5) về grain/schema/logic — chỉ ghi nhận Atomic cần bổ sung trong cột Ghi chú
- [ ] **Tên attribute trong cột Nguồn phải là logical name chính xác từ YAML** — đọc `attribute.name` trong file YAML của entity đó. KHÔNG tự đặt tên theo cảm tính. Ví dụ sai: `Date Of Birth` khi YAML ghi `Birth Date`.
- [ ] **Giá trị Classification Value trong công thức KPI phải lấy từ BA, KHÔNG tự suy đoán** — đọc full ô Mô tả + Mapping nghiệp vụ của từng dòng BA. Ví dụ sai: dùng `= 'PROP'` thay vì `= '30'`; dùng `= 'FI'` thay vì `<> '00'`. Sau khi lấy code từ BA → verify với `DataModel/working/Atomic/lld/classification_schemes.yaml`.
- [ ] **KPI có nguồn từ entity phụ (join/shared entity)** → ghi rõ tên entity phụ + điều kiện join trong cột Nguồn. KHÔNG ghi nhầm vào entity chính. Ví dụ đúng: "`Involved Party Alternative Identification`.Identification Number — join qua ip_id, filter Identification Type Code = CCCD/PASSPORT".
- [ ] KPI ID đã được khai sinh trong Section 2 trước khi xuất hiện ở file khác
- [ ] Mọi dòng BA `Phân loại = "Chiều"` phải có KPI_ID trong bảng KPI của nhóm tương ứng — không được bỏ qua
- [ ] Chiều dùng như ETL filter nội bộ (không hiển thị UI) → ghi rõ trong cột Ghi chú: "dùng trong formula KPI K_X_N" — vẫn phải có KPI_ID
- [ ] Cấm dùng shorthand "xem Nhóm N" thay thế bảng KPI — nếu nhóm reuse KPI từ nhóm khác, liệt kê explicit từng KPI_ID kèm ghi chú nguồn gốc: "Reuse từ Nhóm N"
- [ ] Đọc toàn bộ BA file trước khi viết bảng KPI — đảm bảo không sót dòng nào có `Trạng thái mapping ∈ {Done, Doing, Pending}`
- [ ] **Mọi dòng Done không note "Trùng" → bắt buộc có KPI_ID trong nhóm:** Nếu concept đã khai ở nhóm khác → reuse explicit trong bảng KPI nhóm này, không được im lặng bỏ qua
- [ ] **Dòng Done là sub-component của KPI phức tạp → vẫn cấp KPI_ID riêng:** Không gộp im lặng sub-component vào KPI cha. Ngoại lệ duy nhất: cột Đánh giá ghi "Trùng" → reuse ID đã có
- [ ] **Cấm thêm KPI không có dòng BA tương ứng:** Bảng KPI chỉ chứa KPI có dòng BA trong nhóm đó (mới hoặc reuse). Không thêm KPI từ suy luận nghiệp vụ dù hợp lý
- [ ] **Dedup KPI giữa các Nhóm trong cùng Tab:** Trước khi cấp ID mới cho Nhóm N, kiểm tra toàn bộ KPI đã khai sinh ở Nhóm 1→(N-1). Nếu trùng nội dung → reuse ID cũ, KHÔNG cấp ID mới. Liệt kê reuse **trong cùng bảng KPI 7 cột duy nhất** — điền cột Ghi chú = "Reuse từ Nhóm X". KHÔNG tạo bảng reuse riêng.
- [ ] **Đối chiếu SỐ LƯỢNG tuyệt đối BA ↔ KPI, không chỉ kiểm tra tồn tại (bắt buộc cho mỗi Nhóm ngay khi viết xong bảng KPI):** Đếm `Số dòng BA = COUNT(dòng BA của Nhóm/STT này, Phân loại ∈ {Chiều, Cơ sở, Phái sinh}, Trạng thái mapping ∈ {Done, Doing})` và so với `Số dòng KPI HLD = COUNT(KPI_ID trong bảng KPI của Nhóm, loại trừ KPI Derived thuần suy ra từ các KPI khác CÙNG bảng — VD `_YOY`, tổng/hiệu 2 KPI cơ sở)`. Hai số này phải khớp tuyệt đối — không chỉ kiểm tra "mọi dòng Chiều có ID chưa" (rule 398) hay "KPI có dòng BA chưa" (rule 405), vì 2 rule đó vẫn PASS ngay cả khi N dòng BA độc lập bị gộp nhầm vào 1 KPI_ID (tỷ lệ ánh xạ sai N:1 thay vì N:N). Nếu lệch — dừng lại, đối chiếu từng dòng BA với từng KPI theo tên/mô tả/nguồn để tìm dòng bị gộp nhầm hoặc bỏ sót, tách lại đúng 1 KPI_ID cho mỗi dòng BA độc lập trước khi coi Nhóm là hoàn tất.
  - Ví dụ lỗi thực tế (QLCB Nhóm 4): 2 dòng BA độc lập "Thông tin doanh nghiệp" (nguồn `COMPANY_NAME_VN`) và "Mã chứng khoán" (nguồn `equity_ticker`) bị viết gộp thành 1 dòng KPI "Thông tin doanh nghiệp (Mã CK, Tên DN)" — BA 12 dòng nhưng HLD chỉ có 11 KPI, không bị rule cũ nào bắt được vì dòng KPI đó "vẫn có ID, vẫn có dòng BA tương ứng".
- [ ] **Gating theo "Loại dữ liệu":** Với mọi dòng BA (mọi Nhóm yêu cầu), kiểm tra cột `Loại dữ liệu` — `Dữ liệu động` → dòng KPI đó đánh Trạng thái PENDING dù Atomic đã READY/Trạng thái mapping = Done (lý do ghi trong Ghi chú: "chưa thống nhất quy tắc khai thác"); `Dữ liệu tĩnh` → theo gating Atomic bình thường. KHÔNG suy đoán tĩnh/động theo `Phân loại` (Chiều/Cơ sở/Phái sinh) — đọc đúng giá trị cột này
- [ ] **Nhóm có cả tĩnh lẫn động:** Cả 2 loại dòng KPI nằm CHUNG 1 bảng KPI duy nhất, chỉ khác cột Trạng thái (READY cho dòng tĩnh, PENDING cho dòng động) — không tách 2 block/2 bảng riêng

### Section 3 — Mô hình tổng thể
- [ ] Không bao gồm PENDING
- [ ] Bảng Phân tích: chỉ liệt kê Fact (không liệt kê Dimension)
- [ ] Bảng Dimension: chỉ liệt kê Dimension, có ghi chú "Tất cả Dimension áp dụng SCD Type 4A"
- [ ] Cột Conformed điền đúng (Có/Không)
- [ ] **Mọi measure trên Fact có grain N (kết quả của N-way join) đã qua grain-matching (BƯỚC 4B)** — measure không copy thẳng từ driving table cha có grain thô hơn Fact; nếu measure lệch grain, công thức SUM ở Section 2 phải pre-aggregate theo đúng cấp grain của measure, không SUM trực tiếp trên Fact

### Section 4 — Reuse Analysis
- [ ] Có bảng với 4 cột: Datamart Entity / datamart_table / reuse_status / Ghi chú
- [ ] Mỗi bảng đích trong Section 3 đều có 1 dòng trong Section 4
- [ ] `reuse_status` đã được human xác nhận (không tự gán nếu có khả năng reuse)
- [ ] Ghi chú ghi rõ lý do reuse/partial (module cũ, nguồn đã có...)

### erDiagram
- [ ] Mở bằng ` ```mermaid ` — KHÔNG phải ` ```erDiagram `
- [ ] Types chỉ dùng: `int` / `float` / `string` / `varchar` / `boolean` / `date` / `datetime`
- [ ] Chỉ dùng label `PK` và `FK` — không có BK/DD
- [ ] `FK` chỉ xuất hiện trong Fact entity block và phải có `||--o{` tương ứng
- [ ] Tên entity dùng underscore (không dấu cách)
- [ ] Tên cột dùng Title_Case_With_Underscore
- [ ] Không thiết kế `Effective Date` / `Expiry Date` / `Population Date` / `Snapshot Date`
- [ ] **Scan toàn bộ erDiagram đã viết trong file trước khi xuất:** không có trường `Population_Date` / `Effective_Date` / `Expiry_Date` / `Snapshot_Date` trong bất kỳ entity block nào
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
□ FKs: trích từ graph TB Section 3, format "{Dim Entity}.{Dim Entity Id}"
□ status = draft toàn bộ rows
□ Thứ tự: Dimension → Fact → Operational
□ Export UTF-8 BOM (utf-8-sig)
□ Entities.md: erDiagram chỉ vẽ relationship lines — không vẽ attribute block
□ Entities.md: bảng entity tóm tắt có cột Datamart Entity / Loại / Reuse / Mô tả / Grain / KPI
```
