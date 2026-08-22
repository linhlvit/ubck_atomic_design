---
name: datamart-review
description: |
  Review cross-check tài liệu BA analyst ↔ thiết kế Datamart (HLD + LLD) cho một module.
  Mục đích: đảm bảo chuỗi Source → Atomic → Datamart → Báo cáo/Dashboard/DataExplorer
  phản ánh đúng logic nghiệp vụ theo BA.

  Sử dụng khi: cần review toàn bộ hoặc một nhóm cụ thể trong một module Datamart.
  Gọi tay: /datamart-review [MODULE] [nhóm N] (nhóm N tuỳ chọn — bỏ qua để review toàn module)

  Input bắt buộc: BA_analyst_{MODULE}.csv + DTM_{MODULE}_HLD.md +
                  Datamart/lld/datamart_attributes.csv (summary) hoặc Datamart/lld/{MODULE}/*.csv (detail) +
                  DTM_{MODULE}_Detail_Mapping.csv +
                  Datamart/datamart_model.yaml (registry schema cross-module — review Lớp 4) +
                  DataModel/Atomic/**/*.yaml (Nguồn 1, ưu tiên cao nhất — tra cứu khi review Lớp 2) +
                  DataModel/working/Atomic/lld/**/*.yaml (Nguồn 2, chỉ tra khi Nguồn 1 không có — KHÔNG bao gồm DataModel/working/Atomic_LinhLV/, out of date, cấm dùng)
---

# Skill: Review Cross-check Datamart

Đọc file này TRƯỚC KHI bắt đầu review bất kỳ module nào.

## Tài nguyên đi kèm

- **Reference:**
  - [`reference/review_checklist.md`](reference/review_checklist.md) — checklist chi tiết 3 lớp HLD/Attributes/Detail Mapping
  - [`reference/issue_classification.md`](reference/issue_classification.md) — phân loại vấn đề và hành động tương ứng
- **Skills liên quan (gọi khi cần):**
  - `datamart-hld-design` — gọi khi nhóm HLD = PENDING nhưng BA = Done (cần thiết kế mới), HOẶC khi HLD đã tồn tại nhưng sai do thiết kế/nguồn Atomic lỗi thời (Kịch bản D) — mọi thay đổi nội dung nghiệp vụ của HLD đều qua skill này, không tự Edit trực tiếp
  - `datamart-lld-design` — gọi khi logic BA thay đổi (cần cập nhật Attributes hoặc Detail Mapping), HOẶC bất kỳ thay đổi nội dung nào vào Attributes/Detail Mapping/`datamart_model.yaml` (registry) — không tự Edit trực tiếp

---

## NGUYÊN TẮC CỐT LÕI

### Chuỗi truy vết đầy đủ

```
BA analyst (logic nghiệp vụ)
    ↓
Source (bảng nguồn IDS/T24/MSS...)
    ↓  [1:1 thông tin]
Atomic (chuẩn hoá, entity Atomic — nguồn sự thật duy nhất, xem YAML approved)
    ↓  [Attributes.csv mô tả mapping này]
Datamart (Fact/Dim/Operational)
    ↓  [Detail_Mapping.csv mô tả mapping này — logic khai thác cho báo cáo]
    ↓  [datamart_model.yaml mô tả registry schema cross-module — PHẢI khớp Attributes]
Báo cáo / Dashboard / DataExplorer
```

**Quy tắc then chốt:** BA mô tả trực tiếp từ bảng nguồn (VD: `IDS.data.field_x`).
Khi review, cần tìm trường tương ứng trên Atomic vì Source → Atomic là 1:1 thông tin.
Không so sánh BA trực tiếp với Datamart mà bỏ qua lớp Atomic.

**Quy tắc bổ sung — không tin theo Attributes ghi gì, phải verify Atomic YAML thật:** Attributes ghi `atomic_table.atomic_column` không có nghĩa là field đó thực sự tồn tại trong Atomic approved. Một KPI có thể bị đánh dấu READY suốt nhiều tuần dù field tham chiếu chưa từng có trong YAML — vì không ai đối chiếu ngược lại approved YAML mà chỉ tin theo những gì Attributes/Detail Mapping đã ghi. Khi review Lớp 2, **luôn mở YAML approved và đếm số attribute thật** trước khi chấp nhận 1 cột Done/READY là đúng — không suy luận từ tên cột "nghe hợp lý" (VD: `record_tp_code`, `record_status_code` nghe rất hợp lý cho 1 entity Violation nhưng có thể chưa từng được thiết kế).

### Phân biệt 4 kịch bản phát hiện vấn đề

| Kịch bản | Dấu hiệu | Hành động |
|---|---|---|
| **A — HLD thiếu / PENDING, BA đã Done** | HLD status = PENDING hoặc nhóm chưa có trong HLD, BA = Done với nguồn đầy đủ | Gọi `datamart-hld-design` để thiết kế/cập nhật |
| **B — Logic BA thay đổi** | BA cập nhật công thức/nguồn/filter mới, Attributes hoặc Detail Mapping chưa phản ánh | Gọi `datamart-lld-design` để sửa LLD |
| **C — Lỗi kỹ thuật** | Lỗi không do BA đổi logic — thiếu Section, heading sai cấp, bảng KPI thiếu cột, CSV lệch cột do sed/replace_all, sai `data_domain`/`data_type`/`nullable`, thiếu `src_stm_code`, physical name sai chuẩn, `etl_logic` tham chiếu cột mart... (Attributes/Detail Mapping/registry HOẶC HLD) | **Trình bày action đề xuất → chờ user xác nhận → gọi skill con để sửa.** KHÔNG tự Edit trực tiếp |
| **D — HLD sai do thiết kế/nguồn Atomic lỗi thời** | HLD đã tồn tại, đánh READY, nhưng trỏ nhầm nguồn Atomic đã deprecated/tái cấu trúc, sai grain, sai entity, hoặc logic nghiệp vụ không còn khớp Atomic hiện hành — khác Kịch bản A (không phải PENDING) và khác Kịch bản C (đây là lỗi nội dung/logic, không phải lỗi kỹ thuật thuần cấu trúc) | Gọi `datamart-hld-design` để thiết kế lại — KHÔNG tự sửa tay nội dung HLD (Fact, grain, nguồn Atomic, bảng KPI) dù đã xác định rõ hướng sửa |

> **Nguyên tắc tổng quát — bắt buộc, áp dụng cho MỌI thay đổi nội dung (không chỉ 4 kịch bản trên):**
> - Bất kỳ thay đổi nào chạm vào **nội dung nghiệp vụ/thiết kế của HLD** (thêm/sửa Nhóm, đổi nguồn Atomic, đổi Fact/Dimension/grain, đổi công thức KPI, thêm Cụm Data Lineage...) → luôn qua `datamart-hld-design`, dù đã tự xác định rõ cách sửa qua quá trình review. Không tự Edit trực tiếp các phần này.
> - Bất kỳ thay đổi nào chạm vào **Attributes / Detail Mapping / `datamart_model.yaml` (registry)** — nội dung mapping, `etl_logic`, `column_role`, cột registry... → luôn qua `datamart-lld-design`.
> - **Kịch bản C cũng đi qua skill con** (chốt 2026-08-22) — trước đây C được phép "sửa tay trực tiếp", nay KHÔNG còn. Quy trình bắt buộc cho C:
>   1. **Trình bày action đề xuất cụ thể**: file nào, dòng/cột nào, giá trị cũ → giá trị mới, lý do.
>   2. **Chờ user xác nhận.**
>   3. **Gọi skill con thực hiện** — HLD → `datamart-hld-design`; Attributes/Detail Mapping/`datamart_model.yaml` → `datamart-lld-design`.
>   Lý do bỏ "sửa tay": trước đây C được định nghĩa 4 kiểu khác nhau ở 4 chỗ trong skill này (thuần cấu trúc / lỗi thiết kế / physical naming / sai data_domain), dẫn tới cùng 1 lỗi mà lúc thì tự Edit, lúc thì gọi skill con. Thống nhất 1 đường đi duy nhất để không còn phải phân định ranh giới "có đổi ý nghĩa hay không".
> - **KHÔNG có ngoại lệ nào được Edit trực tiếp** vào HLD/Attributes/Detail Mapping/registry trong skill này. `datamart-review` chỉ phát hiện, phân loại, đề xuất — việc sửa thuộc skill con.

---

## QUY TRÌNH (BẮT BUỘC)

```
Bước 0:  Xác định scope (module + nhóm cụ thể nếu có) + kiểm tra file tồn tại
Bước 0b: Lập kế hoạch — đọc nhanh toàn BA + HLD → bảng kế hoạch tổng thể
         ⛔ DỪNG — chờ user xác nhận thứ tự review trước khi đi vào chi tiết
Bước 1:  [Lặp lại cho từng nhóm theo kế hoạch]
         Đọc BA chi tiết nhóm N → review 3 lớp (HLD → Attributes → Detail Mapping)
         → Trình bày kết quả nhóm N + danh sách vấn đề + đề xuất action
         ⛔ DỪNG — chờ user quyết định:
            (a) Sửa ngay → thực hiện action → sau đó hỏi tiếp tục nhóm N+1
            (b) Ghi nhận, sang nhóm N+1 → tiếp tục review
            (c) Dừng tại đây
Bước 2:  Tổng hợp cuối — sau khi review xong toàn scope
         Bảng action items tổng hợp theo ưu tiên
```

> **GATE RULE — BẮT BUỘC:**
> 1. Sau Bước 0b: DỪNG, không bắt đầu review chi tiết cho đến khi user xác nhận kế hoạch
> 2. Sau mỗi nhóm:
>    - **Có vấn đề (Critical/Warning/Info):** DỪNG, hỏi user muốn (a) sửa ngay, (b) ghi nhận sang nhóm N+1, hay (c) dừng
>    - **Không có vấn đề (tất cả 3 lớp = OK):** Tự động chuyển sang nhóm N+1 trong plan — KHÔNG dừng chờ xác nhận
> 3. Trước mọi sửa đổi file: DỪNG, không sửa khi chưa được user xác nhận rõ ràng
>
> **Câu hỏi kết thúc mỗi nhóm CÓ vấn đề (bắt buộc):**
> "Nhóm N đã review xong. Bạn muốn: **(a)** sửa [vấn đề X] ngay, **(b)** ghi nhận và sang nhóm N+1, hay **(c)** dừng tại đây?"
>
> **Khi nhóm N không có vấn đề:** Tự động in "✅ Nhóm N — OK (không phát hiện vấn đề). Chuyển sang Nhóm N+1..." và bắt đầu review ngay.

---

## BƯỚC 0 — XÁC ĐỊNH SCOPE

1. Đọc tham số user cung cấp: MODULE + (tuỳ chọn) số nhóm cụ thể
2. Resolve đường dẫn file:
   - BA: `BRD/BA/BA_analyst_{MODULE}_part*.csv` (có thể nhiều part)
   - HLD: `Datamart/hld/DTM_{MODULE}_HLD.md`
   - Attributes (summary): `Datamart/lld/datamart_attributes.csv` — lọc theo `datamart_table` của module
   - Attributes (detail): `Datamart/lld/{MODULE}/DTM_{MODULE}_{table}_{source}.csv` — 1 file per bảng mart
   - Detail Mapping: `Datamart/lld/DTM_{MODULE}_Detail_Mapping.csv`
   - Model registry: `Datamart/datamart_model.yaml` — lọc entity theo `module: "{MODULE}"` hoặc `module: "SHARED"` (Dim dùng chung); nếu thiếu file này, ghi nhận Critical cấp toàn module (không dừng nếu chỉ 1-2 nhóm dùng SHARED Dim chưa có trong review scope)
3. Kiểm tra file tồn tại — báo cáo file nào thiếu, không dừng nếu chỉ thiếu 1 lớp LLD
4. Thông báo scope và danh sách file sẽ review

---

## BƯỚC 0b — LẬP KẾ HOẠCH REVIEW

> Bước này thực hiện **một lần duy nhất** trước khi bắt đầu review chi tiết bất kỳ nhóm nào.
> Mục đích: đọc toàn bộ BA để có danh sách nhóm chính xác, sau đó dừng chờ user xác nhận.

### 0b.1 — Đọc toàn bộ BA (bắt buộc đọc hết, không đọc lướt)

Dùng Python `csv.reader` đọc **toàn bộ** tất cả part file (`part1`, `part2`, `part3`...).
Với mỗi nhóm (STT), tổng hợp đầy đủ:
- Tên nhóm (Col 2)
- Tổng KPI, số Done, số Doing, số Pending
- Bảng nguồn xuất hiện (Col 15)

**Xác định trạng thái BA per-nhóm:**
- `ALL_DONE`: 100% Done/Doing — nguồn đầy đủ
- `PARTIAL`: có Done/Doing + còn Pending
- `ALL_PENDING`: 100% Pending hoặc trống — chưa có nguồn

### 0b.2 — Đọc HLD

Với mỗi nhóm trong BA, kiểm tra trong HLD:
- Nhóm có section trong HLD không?
- Trạng thái HLD: `READY` / `PENDING` / `Chưa có`
- **Đếm số dòng KPI_ID trong bảng KPI của nhóm đó** (loại trừ dòng `_YOY`/derived thuần suy ra từ KPI khác trong cùng nhóm — chỉ đếm KPI có nguồn/công thức riêng)

**Kiểm tra cấu trúc tài liệu (1 lần duy nhất, cấp toàn HLD — không lặp lại mỗi nhóm):**

Đối chiếu `DTM_{MODULE}_HLD.md` với 5 Section cố định theo `datamart-hld-design/reference/section_structure.md`:
```
Section 1 — Data Lineage
Section 2 — Tổng quan báo cáo
Section 3 — Mô hình tổng thể
Section 4 — Reuse Analysis   (4 cột: Datamart Entity / datamart_table / reuse_status / Ghi chú)
Section 5 — Vấn đề mở
```
- Thiếu hẳn Section 4 Reuse Analysis, hoặc "Vấn đề mở" đang chiếm nhầm vị trí Section 4 → 🔴 Critical cấp toàn module (không chỉ riêng 1 nhóm) — ghi nhận 1 lần trong bảng vấn đề tổng hợp, action đề xuất: bổ sung Section 4 đúng chuẩn (đẩy "Vấn đề mở" xuống Section 5), liệt kê `reuse_status` cho mọi bảng Fact/Dim đã có trong Section 3.
- Section 4 tồn tại nhưng thiếu dòng cho 1 bảng Fact/Dim nào đó trong Section 3 → 🟡 Warning, bổ sung dòng thiếu.
- Cũng kiểm tra: heading `##### Cụm N` đúng cấp (không phải `###`/`####`), và **mỗi Nhóm chỉ có ĐÚNG 1 bảng KPI duy nhất, đủ 7 cột** theo chuẩn hiện hành: `KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái`. Đây đều là lỗi cấu trúc cấp toàn module, gộp chung nhóm Critical/Warning với Section 4 ở trên, không tách issue riêng.
  - ⚠️ **Chuẩn 7 cột thay thế hoàn toàn format cũ "block READY 6 cột / block PENDING 4 cột" (đổi 2026-07-23).** Dòng READY và PENDING nằm CHUNG 1 bảng, phân biệt bằng cột `Trạng thái`. Nếu HLD còn tách `##### READY` / `##### PENDING` thành 2 block, hoặc bảng chỉ có 6 cột (thiếu `Trạng thái`) → 🟡 Warning cấu trúc, đề xuất gộp về 1 bảng 7 cột.
  - ❌ **KHÔNG báo lỗi ngược lại** — bảng 7 cột có cột `Trạng thái` là ĐÚNG chuẩn, không phải "thừa cột". Đây là lỗi đã xảy ra khi review chạy theo bản checklist cũ.
- Không tự suy ra `reuse_status` — nếu chưa rõ, hỏi user xác nhận (theo GATE RULE của `datamart-hld-design`), không tự gán "reuse" hay "new" khi chưa chắc chắn.

> **⚠️ Không được để kết quả kiểm tra cấu trúc "chìm" khi có việc khác chen ngang (bắt buộc):** Nếu quá trình review 0b phát sinh một phát hiện lớn hơn giữa chừng (VD: Critical gap Atomic khiến phải tạm dừng lập kế hoạch để điều tra, hoặc phải gọi `datamart-hld-design`/`datamart-lld-design` để sửa ngay một phần trước khi tiếp tục) — kết quả kiểm tra cấu trúc tài liệu ở bước này (Section/heading/cột) VẪN PHẢI được nêu lại tường minh trong bảng 0b.4 và câu hỏi gate 0b.5, không được để trôi mất trong lúc xử lý việc phát sinh. Lý do: gate 0b.5 mặc định chỉ hỏi "thứ tự review nhóm nào", không tự nhắc lại phát hiện cấu trúc — nếu người thực hiện bị cuốn theo nhánh phát sinh (điều tra gap Atomic, chuyển sang skill khác để sửa 1 Nhóm cụ thể) mà không chủ động quay lại, phát hiện cấu trúc dễ bị bỏ sót hoàn toàn cho đến khi user tự phát hiện và hỏi lại (case thực tế: module TT — phát hiện Critical gap Atomic THANHTRA schema cũ/mới ngay sau 0b, chuyển hướng gọi `datamart-hld-design` sửa Nhóm 1, nhưng bỏ luôn việc báo cáo thiếu Section 4/heading Cụm sai cấp/bảng KPI thiếu cột Ghi chú — dù các lỗi này đã có sẵn từ bản gốc và không liên quan gì đến nhánh phát sinh đang xử lý).

### 0b.3 — Đối chiếu SỐ LƯỢNG dòng BA ↔ số dòng KPI HLD (bắt buộc, không chỉ kiểm tra tồn tại)

> **Đây là bước riêng biệt với "KPI coverage" ở Bước 2 Lớp 1** — KPI coverage kiểm tra kiểu tồn tại
> (KPI Done có ID chưa), còn bước này đối chiếu **số lượng tuyệt đối 1-1**, phát hiện các trường hợp
> KPI coverage kiểu tồn tại bỏ lọt: BA đổi nội dung 1 dòng nhưng vẫn giữ tổng số dòng (VD: BA thay
> "Tỷ lệ TP vi phạm nghĩa vụ thanh toán" bằng "Xếp hạng tín nhiệm", KPI coverage vẫn PASS vì mọi dòng
> đều có ID, nhưng nội dung đã sai); hoặc BA bớt/thêm 1 dòng làm tổng số lệch mà không ai để ý vì
> không có bước đếm-so-sánh tường minh.

Với mỗi nhóm, tính:
```
Số dòng BA = COUNT(dòng BA trong nhóm, Phân loại ∈ {Chiều, Cơ sở}, Trạng thái mapping ∈ {Done, Doing})
Số dòng KPI HLD = COUNT(KPI_ID trong bảng KPI của nhóm, loại trừ _YOY/derived thuần trong cùng bảng)
```

- **Số lượng khớp** → tiếp tục Bước 2 Lớp 1 bình thường (kiểm tra coverage/nội dung).
- **Số lượng lệch (dù chỉ 1 dòng, theo cả 2 chiều thừa/thiếu)** → **bắt buộc dừng, đối chiếu TỪNG DÒNG** giữa BA và bảng KPI HLD theo tên/mô tả/điều kiện lọc (criterion_cd, row_code...) để xác định chính xác:
  - KPI nào BA đã bỏ → đề xuất loại khỏi HLD (xác nhận với user trước khi xóa)
  - KPI nào BA thêm mới → đề xuất cấp ID mới, đánh liền mạch theo max hiện có
  - KPI nào BA đổi nội dung nhưng giữ nguyên vị trí/số lượng → đề xuất đổi tên/nguồn, giữ nguyên ID (ghi rõ lý do đổi trong HLD)
- **Không được kết luận nhóm "OK" ở Lớp 1 chỉ vì mọi KPI Done đều tìm thấy ID** — số lượng phải khớp tuyệt đối trước khi coi Lớp 1 pass.

Thêm 2 cột vào bảng danh sách nhóm ở 0b.4 để lộ diện lệch số lượng ngay từ bước lập kế hoạch.

### 0b.4 — Xuất bảng danh sách nhóm theo thứ tự tăng dần

Liệt kê **toàn bộ nhóm**, sắp xếp theo số nhóm từ nhỏ đến lớn (nhóm 1 → nhóm N):

| Nhóm | Tên nhóm | Tổng KPI BA | Done | Doing | Pending | Số dòng KPI HLD | Lệch số lượng? | BA Status | HLD Status |
|---|---|---|---|---|---|---|---|---|---|
| 1 | Dashboard chấm điểm CTDC | 5 | 0 | 0 | 5 | 0 | Không | ALL_PENDING | PENDING |
| 2 | ... | ... | ... | ... | ... | ... | ... | ... | ... |
| 3 | Top CTDC theo chỉ tiêu phát hành | 8 | 8 | 0 | 0 | 8 | **Có — cần đối chiếu từng dòng** | ALL_DONE | READY |
| 6 | GSTT thống kê niêm yết | 8 | 8 | 0 | 0 | 8 | Không | ALL_DONE | READY |

> Thứ tự review sẽ tuần tự từ nhóm 1 đến nhóm N — không sắp xếp lại theo ưu tiên.
> Nhóm có cột "Lệch số lượng?" = Có → ưu tiên đối chiếu từng dòng ngay khi vào Bước 2 Lớp 1 của nhóm đó.

### 0b.5 — ⛔ DỪNG, hỏi user

Sau khi trình bày bảng danh sách, hỏi:

> "Đây là danh sách [N] nhóm của module [MODULE]. Thứ tự review sẽ tuần tự nhóm 1 → [N].
> Bạn muốn:
> - Bắt đầu review **từ nhóm 1** (theo thứ tự trên)?
> - Chỉ review **một số nhóm cụ thể** (nhóm nào)?
> - Bỏ qua nhóm nào (VD: nhóm ALL_PENDING)?"

**Không bắt đầu review chi tiết bất kỳ nhóm nào cho đến khi user trả lời.**

---

## BƯỚC 1 — ĐỌC BA, LẬP DANH SÁCH NHÓM

> **Lưu ý kỹ thuật — delimiter:**
> - **BA CSV** (`BA_analyst_*.csv`): dùng `delimiter=';'`
> - **Attributes CSV** (`DTM_*_Attributes.csv`): dùng `delimiter=','`
> - **Detail Mapping CSV** (`DTM_*_Detail_Mapping.csv`): dùng `delimiter=','`
> - KHÔNG dùng awk hay split đơn giản — tất cả file đều có ô multi-line (quoted).

```python
import csv
# BA CSV — delimiter semicolon
rows = []
with open('BRD/BA/BA_analyst_{MODULE}_partN.csv', encoding='utf-8-sig') as f:
    reader = csv.reader(f, delimiter=';')
    for row in reader:
        rows.append(row)

# Attributes (summary) — delimiter comma; lọc theo datamart_table cần review
attr_rows = []
with open('Datamart/lld/datamart_attributes.csv', encoding='utf-8-sig') as f:
    reader = csv.reader(f, delimiter=',')
    for row in reader:
        attr_rows.append(row)
# Hoặc đọc trực tiếp file detail per bảng:
# Datamart/lld/{MODULE}/DTM_{MODULE}_{table}_{source}.csv
```

Với mỗi part file, extract:
- **Col 0 (STT):** Số nhóm
- **Col 2 (Tên dashboard/báo cáo):** Tên nhóm
- **Col 3 (Tên KPI):** Tên chỉ tiêu
- **Col 4 (Công thức/mô tả):** Mô tả logic/nguồn
- **Col 13 (Trạng thái mapping):** Done / Doing / Pending / (trống)
- **Col 15 (Bảng nguồn):** Tên bảng nguồn BA tham chiếu

Tổng hợp per-nhóm:
```
Nhóm N | Tên nhóm | Tổng KPI | Done | Doing | Pending | (trống)
```

**Xác định trạng thái nhóm:**
- `BA_ALL_DONE`: 100% KPI = Done (kể cả Doing)
- `BA_PARTIAL`: có mix Done/Doing + Pending
- `BA_ALL_PENDING`: 100% KPI = Pending hoặc trống

---

## BƯỚC 2 — REVIEW TỪNG NHÓM (3 LỚP)

Thực hiện tuần tự cho từng nhóm trong scope. Với mỗi nhóm:

### Lớp 1: Review HLD

Đọc section nhóm tương ứng trong `DTM_{MODULE}_HLD.md`.

| Kiểm tra | Chi tiết |
|---|---|
| **Trạng thái HLD vs BA** | HLD = PENDING nhưng BA = Done → Kịch bản A |
| **Đối chiếu số lượng (0b.3)** | Số dòng BA (Chiều/Cơ sở, Done/Doing) khớp tuyệt đối với số dòng KPI HLD của nhóm? Lệch → bắt buộc đối chiếu từng dòng trước khi kết luận Lớp 1, xem 0b.3 |
| **KPI coverage BA→HLD** | Mọi KPI Done/Doing trong BA phải có KPI_ID trong HLD; KPI Pending phải ghi nhận PENDING |
| **KPI coverage HLD→BA (chiều ngược)** | Mọi KPI_ID trong HLD phải truy về được ít nhất 1 dòng trong BA analyst — nếu không tìm thấy → KPI dư, hỏi BA xác nhận trước khi xóa |
| **Cột Công thức/Mô tả — đầy đủ cho mọi dòng, kể cả reuse** | Bảng KPI HLD phải có cột Công thức (hoặc tương đương: Atomic Entity/Table/Column + ghi chú tính toán) cho MỌI dòng. Dòng KPI mới → điền công thức/nguồn thật. Dòng KPI reuse → không được để trống hay chỉ ghi tên nhóm nguồn suông; phải ghi rõ "Reuse từ Nhóm X" NGAY TRONG cột Công thức/Atomic Entity theo đúng `section_structure.md`, kèm mô tả ngắn cách tính nếu nhóm hiện tại dùng khác điều kiện lọc so với nhóm gốc | 
| **Grain** | Grain mô tả rõ ràng, đúng với logic BA |
| **Bảng Fact/Dim** | Fact/Dim đủ để phản ánh dimension filter/slicer trong BA |
| **Chiều (Slicer/Filter)** | Mọi dòng BA `Phân loại = Chiều` phải có KPI_ID trong HLD |
| **Cột Fact thừa (không trace được về KPI)** | Với mỗi cột trong Fact block (erDiagram), kiểm tra có xuất hiện trong công thức của ít nhất 1 KPI trong bảng KPI của nhóm đó không. Không trace được và không phải FK trục thời gian/dimension chính → cột thừa, có thể do copy nguyên attribute entity nguồn vào Fact. Ngoại lệ: cột đã ghi chú rõ là "ETL filter khi populate Fact" (SCD4A current-state) — không cần xuất hiện trong công thức KPI |

Output lớp 1:
```
HLD | [OK / GAP] | Mô tả vấn đề nếu có
```

### Lớp 2: Review Attributes (Atomic → Datamart)

> **BẮT BUỘC:** Luôn kiểm tra Lớp 2 và Lớp 3 cho MỌI nhóm, kể cả nhóm HLD = PENDING.
> Lý do: Attributes và Detail Mapping có thể đã có dữ liệu (dòng PENDING trống, hoặc KPI reuse từ nhóm khác)
> dù HLD chưa READY. Không được giả định "PENDING thì LLD trống" — phải kiểm tra thực tế.

Đọc các dòng Attributes tương ứng với bảng Fact/Dim của nhóm đang review.

| Kiểm tra | Chi tiết |
|---|---|
| **Mapping completeness** | Mọi KPI Done trong BA có cột tương ứng trong Attributes |
| **Atomic source** | `source_entity` + `atomic_table` + `atomic_column` tồn tại, không để trống với `etl_logic_type ≠ pending` |
| **ETL logic — trace từ BA** | Với mỗi KPI Done: lấy tên bảng nguồn BA ghi → tra approved YAML trong `DataModel/Atomic/` → xác nhận `atomic_table.atomic_column` trong Attributes có khớp không |
| **ETL logic — nội dung đúng** | `etl_logic` đúng với logic BA: JOIN đúng bảng, filter condition đúng (VD: `row_code`, `entp_tp_code`), aggregation đúng phép tính |
| **ETL logic — không tham chiếu cột mart** | `etl_logic` KHÔNG được tham chiếu cột mart khác (`fct_*.col`) dù cột đó đã tính sẵn trong cùng bảng fact — phải flatten hoàn toàn xuống Atomic. Cột CASE WHEN hay derived formula tính từ cột join_atomic → bản thân cũng phải là `join_atomic`, repeat lại JOIN clause và tính lại formula trực tiếp từ Atomic |
| **join_atomic coverage** | Đếm số `atomic_table` distinct trong toàn bộ cột của bảng (bỏ qua driving table và `rsk_wgt_cfg`/lookup). Nếu có ≥2 atomic_table khác nhau mà **không có dòng nào** `etl_logic_type = join_atomic` → 🔴 Critical: các bảng phụ chưa được khai báo JOIN, Attributes đang sai. Gọi `datamart-lld-design` để sửa. |
| **`lookup_dim`/`join_atomic` — vế trái phải là cột Datamart thật, không phải tên cột Atomic** | Với mọi dòng `etl_logic_type ∈ {lookup_dim, join_atomic}` viết dạng `LOOKUP {dim_table} ON {dim_table}.{col} = ...` hoặc `JOIN {dim_table} ON {dim_table}.{col} = ...`: `{col}` phải là 1 `datamart_column` **thật** trong Attributes của chính `{dim_table}` đó — không phải copy nguyên tên cột Atomic nguồn. Đây là lỗi độc lập với việc kiểm tra `atomic_table.atomic_column` tồn tại (mục "Atomic source" ở trên) — mục đó chỉ verify vế phải (nguồn Atomic), không verify vế trái (đích Datamart Dimension). Cách kiểm tra: mở Attributes CSV của `{dim_table}`, liệt kê toàn bộ `datamart_column`, đối chiếu `{col}` có nằm trong danh sách đó không. Case thực tế (module NHNCK, `fct_practitioner_license_certificate_snpst.certificate_tp_dim_id`): `etl_logic` viết `LOOKUP sp_license_certificate_type_dim ON sp_license_certificate_type_dim.sp_license_certificate_type_code = ...` nhưng bảng đích `sp_license_certificate_type_dim` chỉ có cột `certificate_tp_code` (không có `sp_license_certificate_type_code`) — lỗi lọt qua nhiều vòng review vì quy trình chỉ trace BA→Atomic (vế phải), không trace ngược Fact→Dimension (vế trái) do đây là kiểm tra self-consistency nội bộ Datamart, khác hẳn kiểm tra Datamart↔Atomic. |
| **`src_stm_code` filter trong JOIN sang shared/cross-module entity — giá trị phải đúng module nguồn thật của bảng đích, không suy diễn theo module đang review** | Với mọi dòng `etl_logic_type ∈ {join_atomic, lookup_dim, lookup_date}` có `AND {atomic_table}.src_stm_code = '{VALUE}'` trong `etl_logic`: nếu `{atomic_table}` là 1 **shared/cross-module Atomic entity** (dùng chung nhiều module — dấu hiệu: BCV Core Object `Location`/`Involved Party`/`Common`/`Classification`, hoặc tên entity không mang prefix module cụ thể, VD `geographic_area`, `ip_alternative_identification`, `ip_postal_address`), KHÔNG được mặc định `{VALUE}` có prefix trùng với module đang review. Bắt buộc mở đúng file Atomic YAML của `{atomic_table}` (`grep -rl "entity_physical_name: \"{atomic_table}\"" DataModel/Atomic/**/*.yaml DataModel/working/Atomic/**/*.yaml`), đọc `source_system`/`classification_context`/`etl_derived_value` của attribute "Source System Code" trong CHÍNH FILE ĐÓ để xác nhận giá trị thật — không suy ra bằng cách ghép `{tên module đang review}_{tên bảng}`. Case thực tế (module NHNCK, 2 cột `nationality_nm`/`country_nm` join tới `geographic_area`): `etl_logic` viết `AND geographic_area.src_stm_code = 'NHNCK_COUNTRIES'`, nhưng `geographic_area` (nguồn quốc gia) luôn thuộc phân hệ **ECAT** (`dm_atm_geographic_area-ECAT.COUNTRY.yaml`, `classification_context: "Source System Code = 'ECAT_COUNTRY'"`) bất kể module Datamart nào đang JOIN tới nó — giá trị đúng phải là `ECAT_COUNTRY`. Lỗi có định dạng hợp lệ (đúng dấu gạch dưới, có mặt điều kiện lọc) nên dễ bị bỏ qua nếu chỉ kiểm tra cú pháp mà không tra ngược Atomic YAML của chính bảng đích. |
| **Data domain / type** | Khớp với tính chất KPI (số tiền, tỷ lệ, đếm...) |
| **Key constraints** | FK đúng, nullable đúng với business rule |
| **src_stm_code** | Dim/Operational có `src_stm_code`, Fact No-Driving-Table không có |

**Quy trình trace BA → Atomic → Datamart (bắt buộc với mọi KPI Done):**

```
Bước A: Đọc BA — xác định tên bảng nguồn và tên trường
         VD: "NHNCK.CERTIFICATE_RECORDS, cột CERTIFICATE_NUMBER"
Bước B: Tra Atomic YAML theo thứ tự ưu tiên 2 nguồn — tìm YAML có source khớp bảng BA
         Nguồn 1 (ưu tiên cao nhất): DataModel/Atomic/**/*.yaml (toàn bộ thư mục, tất cả subdirectory)
         Nguồn 2 (chỉ tra khi Nguồn 1 không có): DataModel/working/Atomic/lld/**/*.yaml
         ❌ KHÔNG tra DataModel/working/Atomic_LinhLV/ — track cũ đã revert, out of date, cấm dùng dưới mọi hình thức
         Ngoại lệ: entity cv (Classification Value) — dùng trực tiếp, không cần YAML
         Cách tìm: grep "NHNCK.CERTIFICATE_RECORDS" DataModel/Atomic/**/*.yaml DataModel/working/Atomic/lld/**/*.yaml
         → Lấy physical_name (atomic_table) + tên cột (physical_name trong columns)
         → Nếu không tìm thấy YAML nào ở cả 2 nguồn hợp lệ → Gap Atomic (ghi nhận, không phải lỗi LLD)
Bước C: Kiểm tra Attributes — atomic_table + atomic_column trong Attributes có khớp Bước B?
         → Không khớp (tên bảng cũ, tên cột cũ) → 🔴 Critical (map sai Atomic entity/column)
Bước D: Kiểm tra etl_logic — filter condition trong etl_logic có phản ánh đúng điều kiện lọc BA mô tả?
         → VD: BA ghi "lấy chỉ tiêu X theo row_code = 'ABC'" → etl_logic phải có WHERE row_code = 'ABC'
         → Thiếu hoặc sai → 🔴 Critical / 🟡 Warning tuỳ mức độ ảnh hưởng
```

Output lớp 2:
```
Attributes | [OK / GAP / WARN] | Mô tả vấn đề nếu có (kèm: BA ghi gì → Atomic tìm được gì → Attributes dùng gì)
```

### Lớp 3: Review Detail Mapping (Datamart → Báo cáo)

Đọc các dòng Detail Mapping có `tab`/`nhom` khớp với nhóm đang review.

> **Lưu ý kỹ thuật — lọc cột `nhom` trong Detail Mapping:**
> Cột `nhom` lưu tên đầy đủ dạng `"Nhóm 25 - DN bảo hiểm — Bảng cân đối kế toán"` — **KHÔNG phải số**.
> Lọc đúng: `'Nhóm 25' in r[nhom_col]` — **KHÔNG dùng** `r[nhom_col].strip() == '25'`.

| Kiểm tra | Chi tiết |
|---|---|
| **KPI coverage** | Mọi KPI_ID trong HLD (Done/Doing) phải có dòng trong Detail Mapping |
| **Logic trace từ BA** | Với mỗi KPI Done: lấy công thức/filter BA → đối chiếu với `logic` trong Detail Mapping — filter condition, aggregation, derived formula có khớp không |
| **Logic nội dung đúng** | `logic` dùng đúng `physical_table.physical_column`, filter đủ điều kiện BA mô tả |
| **Logic DERIVED — không tham chiếu KPI_ID khác** | `logic` của DERIVED **KHÔNG ĐƯỢC** viết dạng `(K_XXX_N - K_XXX_M) / NULLIF(K_XXX_M,0)`. Phải inline toàn bộ logic xuống `physical_table.physical_column` với đầy đủ filter condition. Lý do: KPI_ID là định danh nghiệp vụ, không phải biến SQL — ETL engine không resolve được. |
| **column_role** | MEASURE / SLICER / FILTER / DERIVED đúng tính chất |
| **mart_table/mart_column** | Dùng tên logical, tồn tại trong HLD và Attributes |
| **KPI Pending** | Có dòng trong Detail Mapping với `mart_table`/`mart_column`/`logic` trống |
| **Chiều lặp lại** | Mỗi nhóm có explicit SLICER/FILTER — không dùng shorthand "xem nhóm X" |

**Quy trình trace BA → Detail Mapping (bắt buộc với mọi KPI Done):**

> **Bắt buộc đọc FULL SQL tham khảo, không chỉ cột "Điều kiện" tóm tắt.** Cột "Điều kiện" trong BA CSV
> thường chỉ tóm tắt 1 điều kiện chính, trong khi cột SQL tham khảo (Câu lệnh tham khảo) chứa đầy đủ
> mọi JOIN + WHERE kết hợp — kể cả điều kiện AND giữa 2-3 bảng khác nhau. Case thực tế: BA ghi "Điều
> kiện" chỉ là `DECISION_TYPE_ID='2'`, nhưng SQL đầy đủ có thêm `AND a.STATUS_WORK='3'` (join bảng
> Professionals) — nếu chỉ đọc cột tóm tắt, Detail Mapping sẽ thiếu hẳn điều kiện thứ 2, kết quả đếm
> sai mà không ai phát hiện vì KPI vẫn có công thức, vẫn trace được, vẫn "trông đúng".
> Với MỌI KPI Done — đọc cả cột Điều kiện, Câu lệnh tham khảo, VÀ Note trước khi kết luận Detail
> Mapping đã đủ điều kiện lọc. Nếu SQL tham khảo có JOIN thêm bảng nào ngoài bảng chính — kiểm tra
> WHERE của bảng đó có được đưa vào `logic` không.

```
Bước A: Đọc BA — xác định công thức KPI: aggregation (COUNT/SUM/AVG), filter condition, derived formula
Bước B: Đọc Detail Mapping — logic của KPI_ID tương ứng
Bước C: Đối chiếu từng thành phần:
         → Aggregation: BA ghi SUM → logic phải là SUM (không được COUNT)
         → Filter: BA ghi "loại hình BCTC = Kiểm toán" → logic phải có WHERE tương ứng
         → Derived: BA ghi "A/B" → logic phải là DERIVED với mart_table/mart_column trống
         → Derived formula: KHÔNG được dùng KPI_ID (VD: `K_XXX_N - K_XXX_M`) trong cột `logic`
           — phải inline toàn bộ xuống `physical_table.physical_column` kèm filter condition đầy đủ
           — VD đúng: `(fct_X.val WHERE ind_code='A' AND prd_dt=:t) - (fct_X.val WHERE ind_code='A' AND prd_dt=(SELECT MAX...))`
         → Sai/thiếu → 🔴 Critical nếu ảnh hưởng kết quả, 🟡 Warning nếu thiếu một phần
Bước D: Kiểm tra mart_table.mart_column → trace ngược lên Attributes → xác nhận cột tồn tại và đúng
```

Output lớp 3:
```
Detail Mapping | [OK / GAP / WARN] | Mô tả vấn đề nếu có (kèm: BA ghi gì → Detail Mapping dùng gì → delta nếu có)
```

### Lớp 4: Review datamart_model.yaml (Registry cross-module)

> **BẮT BUỘC — dễ bị bỏ quên vì không nằm trong luồng BA→Atomic→Datamart→Báo cáo trực tiếp.**
> `datamart_model.yaml` là **registry schema riêng**, tự nhận là "nguồn sự thật duy nhất về schema"
> cross-module. Nó KHÔNG tự động đồng bộ khi Attributes/Detail Mapping/HLD được sửa — mọi thay đổi
> cột (thêm/xóa/đổi kiểu/đổi logic) phải được tay động cập nhật riêng vào file này.
> Bỏ qua Lớp 4 đồng nghĩa: sửa xong 3 lớp kia nhưng registry vẫn giữ dữ liệu cũ — lần review sau
> (hoặc module khác dùng chung SHARED Dim) sẽ đọc registry lỗi thời mà không biết.

Đọc entity tương ứng trong `Datamart/datamart_model.yaml` (lọc theo `datamart_table`, `module: "{MODULE}"` hoặc `"SHARED"`).

| Kiểm tra | Chi tiết |
|---|---|
| **Cột tồn tại 1-1 với Attributes** | Mọi `logical_name`/`physical_name` trong Attributes detail phải có mặt trong `columns` của entity tương ứng trong registry, và ngược lại — không thừa, không thiếu |
| **data_domain/data_type khớp Attributes** | So từng cột: registry ghi `Boolean/boolean` trong khi Attributes đã đổi `Indicator/string` (hoặc ngược lại) → 🔴 Critical, type mismatch sẽ gây lỗi ETL hoặc sai kết quả khi code-gen từ registry |
| **source_atomic_table/source_atomic_column khớp Atomic YAML thật** | Cũng phải verify lại approved YAML — registry có thể ghi sai/lỗi thời giống hệt Attributes; đừng chỉ đối chiếu Attributes↔Registry mà bỏ qua bước xác nhận với Atomic gốc |
| **Cột đã xóa khỏi Attributes có còn sót trong registry không** | Khi 1 cột bị loại khỏi Attributes/HLD (đổi logic, gộp field...), kiểm tra registry đã xóa cột đó chưa — đây là lỗi hay gặp nhất vì registry dễ bị quên khi dọn dẹp cột thừa |
| **Cột PENDING (gap Atomic) có phản ánh đúng trong registry** | Khi Attributes chuyển 1 cột sang `pending` (gap Atomic), registry phải đồng bộ: `source_atomic_table`/`source_atomic_column` = `null`, mô tả ghi rõ PENDING + lý do — không được để registry vẫn trỏ tới Atomic column không tồn tại |
| **modules_using / source_atomic list đầy đủ** | Khi bổ sung cột mới cần JOIN thêm Atomic entity (VD: cross-module NHNCK↔SCMS), entity's `source_atomic` list ở đầu block phải liệt kê đủ mọi Atomic entity dùng trong `columns`, không chỉ driving table |
| **Physical name nhất quán với Attributes** | Registry có thể giữ physical name cũ/viết tắt khác Attributes hiện tại (VD: `yr` vs `year`, `hol_f` vs `holiday_flag`) — áp dụng cùng quy tắc Physical Naming ở cuối skill này |

**Quy tắc phân biệt Boolean hợp lệ vs Boolean cần đổi Y/N (Indicator):** không phải mọi cột `data_domain: Boolean` đều là lỗi cần sửa sang `Indicator` (Y/N). Phân biệt theo NGUỒN GỐC giá trị, không theo tên cột:

- **Boolean hợp lệ, KHÔNG sửa:** cột `direct` copy nguyên 1-1 từ 1 Atomic column đã là `data_domain: Boolean` thật sự (kiểm tra YAML approved — nếu Atomic đã tự convert nguồn thô sang boolean, VD comment "NUMBER(1) — ETL cần convert sang boolean", thì Datamart kế thừa boolean là đúng, không phải lỗi).
- **Boolean cần đổi Indicator (Y/N), PHẢI sửa:** cột **tự tính bằng biểu thức tại tầng Datamart** — so sánh (`IN (1,7)`, `IS NOT NULL`), CASE ngầm định, hay bất kỳ công thức nào KHÔNG phải lấy trực tiếp 1 cột Atomic có sẵn kiểu Boolean. Các công thức này trả về kết quả so sánh (TRUE/FALSE của ngôn ngữ truy vấn), không phải giá trị đã lưu sẵn trong database — khi ETL ghi xuống bảng vật lý phải quy về `Y`/`N` string để nhất quán với các Indicator khác trong cùng bảng, tránh mỗi ETL engine biểu diễn TRUE/FALSE khác nhau (1/0, 't'/'f', true/false...).

Case thực tế (module NHNCK): `Is_Weekend`/`Holiday_Flag`/`Has_Active_Violation` đều tự tính bằng biểu thức tại Datamart → phải Y/N. `Is_Listed_Indicator` (module khác) là `direct` copy từ Atomic đã là Boolean thật → giữ nguyên Boolean, không sửa. Khi gặp field domain Boolean, luôn tra `etl_logic_type` (`direct` vs `computed`) trước khi kết luận có cần đổi hay không — không suy luận từ tên cột.

**Quy trình đối chiếu (bắt buộc cho MỌI cột đã sửa ở Lớp 2/3 trong lượt review này hoặc lượt trước):**

```
Bước A: Tìm entity trong datamart_model.yaml theo datamart_table
Bước B: Với mỗi cột đã sửa (thêm/xóa/đổi type/đổi logic) ở Lớp 2/3 — tìm cột cùng logical_name trong registry
Bước C: Đối chiếu: physical_name, data_domain, data_type, source_atomic_table/column, description
         → Registry KHÔNG khớp Attributes hiện tại → 🔴 Critical: registry lỗi thời, cần đồng bộ ngay
Bước D: Sửa registry theo Attributes (nguồn hiện tại luôn là Attributes detail — registry chỉ tổng hợp)
```

Output lớp 4:
```
datamart_model.yaml | [OK / GAP / WARN] | Mô tả vấn đề nếu có (kèm: Attributes ghi gì → registry đang ghi gì)
```

**Sau khi sửa registry — verify YAML còn hợp lệ:**
```python
import yaml
with open('Datamart/datamart_model.yaml', encoding='utf-8') as f:
    data = yaml.safe_load(f)
print(len(data['entities']), 'entities')  # phải parse thành công, không lỗi cú pháp
```

---

## BƯỚC 3 — TỔNG HỢP VẤN ĐỀ

Sau khi review tất cả nhóm trong scope, tổng hợp thành 2 bảng:

### Bảng chi tiết vấn đề

| # | Nhóm | Lớp | Mức độ | Mô tả vấn đề | Kịch bản | Action đề xuất |
|---|---|---|---|---|---|---|
| 1 | Nhóm 25 | HLD | 🔴 Critical | HLD = PENDING nhưng BA 100% Done với nguồn IDS | A | Gọi datamart-hld-design thiết kế nhóm 25 |
| 2 | Nhóm 21 | Detail Mapping | 🟡 Warning | Formula K_GSDC_45 chưa phản ánh filter `entp_tp_code = 'dn'` | B | Gọi datamart-lld-design cập nhật Detail Mapping |
| 3 | Nhóm 7 | Attributes | 🔵 Info | Cột `src_stm_code` thiếu WHERE filter (forward-compat) | C | Sửa trực tiếp Attributes.csv |
| 4 | Nhóm 1 | HLD | 🔴 Critical | Fact dùng nguồn Atomic `TT_HO_SO`/`TT_QUYET_DINH` đã deprecated, schema THANHTRA đã tái cấu trúc sang `INSPECTION_TEAM` | D | Gọi datamart-hld-design thiết kế lại Nhóm 1 theo Atomic mới |
| 5 | Toàn module | HLD | 🟡 Warning | Thiếu Section 4 Reuse Analysis, heading Cụm sai cấp | C | Sửa trực tiếp cấu trúc HLD.md (không đổi nội dung nghiệp vụ) |

**Mức độ:**
- 🔴 Critical: logic sai, thiếu thiết kế — báo cáo không chạy được
- 🟡 Warning: logic thiếu/không đầy đủ — báo cáo chạy nhưng sai số
- 🔵 Info: không ảnh hưởng logic, cần cải thiện kỹ thuật

### Bảng action items tổng hợp

| Action | Nhóm liên quan | Skill/Tool | Ưu tiên |
|---|---|---|---|
| Gọi `datamart-hld-design` | 25, 26, 27, 28, 29, 30, 31, 32 | datamart-hld-design | 🔴 High |
| Gọi `datamart-lld-design` cập nhật Detail Mapping | 21, 22, 23, 24 | datamart-lld-design | 🟡 Medium |
| Sửa Attributes.csv | 7, 11 | Edit trực tiếp | 🔵 Low |

---

## BƯỚC 4 — CHỜ XÁC NHẬN

Sau khi trình bày bảng tổng hợp:

1. **Hỏi user** muốn thực hiện action nào trước
2. **Chỉ thực hiện** khi user xác nhận rõ ràng
3. **Gọi skill tương ứng** khi action = Kịch bản A, B hoặc D:
   - Kịch bản A → `/datamart-hld-design` với context nhóm cụ thể (HLD thiếu/PENDING)
   - Kịch bản B → `/datamart-lld-design` với context thay đổi cụ thể (BA đổi logic)
   - Kịch bản D → `/datamart-hld-design` với context nhóm cụ thể (HLD sai do thiết kế/nguồn Atomic lỗi thời) — cung cấp đầy đủ bằng chứng đã điều tra (entity Atomic cũ vs mới, nguồn deprecated...) để skill con không phải lặp lại việc tra cứu
4. **Kịch bản C** → trình bày action đề xuất (file / dòng / giá trị cũ → mới) → chờ user xác nhận → **gọi skill con để sửa** (HLD → `datamart-hld-design`; Attributes/Detail Mapping/registry → `datamart-lld-design`). ❌ Không tự Edit trực tiếp
5. **Không tự ý hạ cấp D/A/B xuống C để sửa nhanh** — nếu việc sửa chạm vào nội dung nghiệp vụ (nguồn Atomic, Fact/grain, công thức KPI, etl_logic, mapping) dù đã biết rõ hướng sửa, vẫn phải gọi đúng skill con tương ứng, không tự Edit trực tiếp

---

## REVIEW NHÓM TUẦN TỰ — GATE CONTROL

### Flow sau mỗi nhóm (BẮT BUỘC)

```
[Review nhóm N — 3 lớp]
        ↓
[Trình bày kết quả nhóm N]
  - Bảng vấn đề phát hiện (HLD / Attributes / Detail Mapping)
  - Phân loại: Critical 🔴 / Warning 🟡 / Info 🔵
  - Đề xuất action cụ thể cho từng vấn đề
        ↓
   ┌──────────────────────────────────────┐
   │ KHÔNG có vấn đề (tất cả 3 lớp = OK) │
   │ → In: "✅ Nhóm N — OK"              │
   │ → Tự động chuyển sang nhóm N+1      │
   │ → Bắt đầu review nhóm N+1 ngay      │
   └──────────────────────────────────────┘
        ↓ (nếu có vấn đề)
⛔ DỪNG — Hỏi user:
"Nhóm N xong. Bạn muốn:
  (a) Sửa [vấn đề X] ngay
  (b) Ghi nhận, sang nhóm N+1
  (c) Dừng tại đây"
        ↓
   ┌────────────────────────────────┐
   │ User chọn (a)                 │
   │ → Xác nhận lại action cụ thể  │
   │ → Thực hiện (Edit / gọi skill)│
   │ → Báo cáo hoàn thành          │
   │ → Tự động chuyển nhóm N+1     │
   └────────────────────────────────┘
   ┌────────────────────────────────┐
   │ User chọn (b)                 │
   │ → Ghi nhận vào backlog        │
   │ → Tự động chuyển nhóm N+1     │
   └────────────────────────────────┘
   ┌────────────────────────────────┐
   │ User chọn (c)                 │
   │ → Tổng hợp backlog đã ghi nhận│
   │ → Xuất bảng action items cuối │
   └────────────────────────────────┘
```

### Quy tắc cứng

- **Tự động chuyển nhóm** khi nhóm N = OK (không có vấn đề) — không cần lệnh từ user
- **Tự động chuyển nhóm** sau khi user chọn (a) xong hoặc chọn (b) — không hỏi lại "tiếp tục không?"
- **DỪNG chờ user** chỉ khi nhóm N có vấn đề cần quyết định
- **KHÔNG tự sửa file** — kể cả lỗi nhỏ (Info), phải hỏi trước
- **KHÔNG gộp review nhiều nhóm** trừ khi user nói rõ "review nhanh nhóm X-Y"
- **Nếu user nói "tiếp tục"** mà không chỉ định nhóm → hiểu là nhóm tiếp theo trong kế hoạch đã duyệt ở Bước 0b

### Quy tắc PENDING → READY (BẮT BUỘC)

Khi xử lý Kịch bản A (PENDING → READY) cho một nhóm:

```
[Thiết kế bổ sung HLD — PENDING → READY]
        ↓
[BẮT BUỘC: Chạy review lại 3 lớp ngay sau khi READY]
  - Lớp 2: Attributes — etl_logic, data_type, key constraints, src_stm_code
  - Lớp 3: Detail Mapping — logic, column_role, mart_table/mart_column
        ↓
[Báo cáo kết quả review + gate như bình thường]
```

> **Lý do:** Cập nhật HLD từ PENDING → READY chưa đảm bảo LLD (Attributes + Detail Mapping)
> đã được thiết kế đúng hoặc đầy đủ. Review 3 lớp sau khi READY là bước bắt buộc
> để xác nhận chuỗi BA → Atomic → Datamart → Báo cáo nhất quán.
>
> **KHÔNG** bỏ qua Lớp 2 + 3 với lý do "cùng pattern" hay "reuse fact table từ nhóm trước"
> — vẫn phải kiểm tra thực tế, kể cả khi nhiều nhóm dùng cùng fact table.

### Ghi nhận backlog giữa các nhóm

Khi user chọn (b) — ghi nhận và sang nhóm tiếp — tích luỹ backlog:

```
Backlog tạm thời (cập nhật liên tục):
| Nhóm | Lớp | Mức | Vấn đề | Action |
|------|-----|-----|--------|--------|
| ...  | ... | ... | ...    | ...    |
```

Sau khi review hết scope, xuất backlog đầy đủ thành bảng action items tổng hợp.

---

## LƯU Ý ĐẶC BIỆT

### Khi BA có nhiều part file

Module có thể có `BA_analyst_{MODULE}_part1.csv`, `part2.csv`, `part3.csv`...
Đọc toàn bộ các part, ghép lại theo STT nhóm trước khi bắt đầu review.
Nhóm số lớn hơn thường nằm ở part sau — không bỏ sót.

### Khi nhóm BA map vào nhiều bảng Datamart

Một nhóm BA có thể dùng nhiều Fact/Dim. Review Attributes phải bao phủ
**tất cả bảng** liên quan đến nhóm, không chỉ Fact chính.

### Khi BA ghi nguồn trực tiếp (không qua Atomic)

BA hay ghi công thức dạng `NHNCK.CERTIFICATE_RECORDS.FIELD` hoặc `IDS.data.field` thay vì tên Atomic.
Cần tìm Atomic entity/column tương ứng bằng cách grep, theo đúng thứ tự ưu tiên 2 nguồn:

```bash
grep -rl "CERTIFICATE_RECORDS" DataModel/Atomic/
# Không có ở Nguồn 1 → thử Nguồn 2:
grep -rl "CERTIFICATE_RECORDS" DataModel/working/Atomic/lld/
# → tìm được YAML → đọc physical_name của entity và column tương ứng
```

| Ưu tiên | Nguồn |
|---|---|
| 1 (luôn tra trước) | `DataModel/Atomic/` (toàn bộ thư mục, tất cả subdirectory) |
| 2 (chỉ tra khi Nguồn 1 không có) | `DataModel/working/Atomic/lld/` |

❌ **Không bao giờ tra `DataModel/working/Atomic_LinhLV/`** — track cũ đã revert, out of date. Entity ở đây không được coi là nguồn hợp lệ dù cấu trúc thư mục giống hệt `DataModel/Atomic/`.

Entity `cv` (Classification Value) là ngoại lệ — dùng trực tiếp, không có YAML.
Nếu không tìm thấy YAML nào ở cả 2 nguồn hợp lệ → ghi nhận là gap Atomic (cần bổ sung Atomic trước khi thiết kế Datamart).

### Flatten hoàn toàn xuống Atomic — không tham chiếu cột mart trong etl_logic

Mọi `etl_logic` trong Attributes phải tham chiếu trực tiếp Atomic table/column — **không được** dùng `fct_*.col` hay `dim_*.col` làm input, kể cả khi cột đó đã được tính sẵn trong cùng bảng mart.

**Dấu hiệu lỗi 1 — tham chiếu cột mart:** `etl_logic` chứa `fct_<table>.<col>` hoặc `dim_<table>.<col>` → sai.

**Dấu hiệu lỗi 2 — thiếu join_atomic:** Đếm số `atomic_table` distinct trong toàn bộ cột của 1 bảng mart (loại trừ driving table). Nếu có bảng Atomic phụ nào xuất hiện trong `atomic_table` mà **không có dòng nào** `etl_logic_type = join_atomic` tương ứng → các bảng phụ đó chưa được khai báo JOIN SQL đúng cách. Cách kiểm tra nhanh:
```python
import csv
with open('Datamart/lld/datamart_attributes.csv') as f:
    rows = list(csv.reader(f))
tbl = 'fct_xxx'  # bảng cần kiểm tra
driving = 'yyy'  # driving table
atomic_tables = set(r[12] for r in rows[1:] if r[1]==tbl and r[12] and r[12]!=driving)
join_atomic_tables = set(r[12] for r in rows[1:] if r[1]==tbl and r[10]=='join_atomic')
missing = atomic_tables - join_atomic_tables
# missing != empty → Critical
```

**Trường hợp hay gặp:**
- Cột CASE WHEN phân loại (status/label) dựa trên giá trị đã tính → phải lặp lại toàn bộ JOIN + formula gốc trong CASE WHEN
- Cột % thay đổi (pct_chg) tính từ 2 cột measure khác → phải tính cả 2 giá trị trực tiếp từ Atomic bằng CASE WHEN/subquery
- Bất kỳ cột nào `etl_logic_type = computed` mà `etl_logic` dùng cột mart → đổi về `join_atomic` và flatten

**Quy tắc phân loại:**
- Có JOIN sang bảng Atomic khác driving (dù kết hợp với driving) → `join_atomic`
- `computed` chỉ dùng khi toàn bộ `etl_logic` chỉ tham chiếu driving table hoặc literal/function thuần

**Action khi phát hiện lỗi này:** **Kịch bản C** — trình bày action đề xuất (danh sách cột vi phạm, `etl_logic_type` cũ → mới) → chờ user xác nhận → gọi `datamart-lld-design` để sửa. Không sửa tay trực tiếp vì cần đảm bảo format chuẩn `join_atomic` (INNER/LEFT JOIN ... → ...).

### Khi Detail Mapping trống (nhóm chưa thiết kế)

Nếu nhóm BA = Done nhưng Detail Mapping hoàn toàn trống → đây là Gap lớn (Critical).
Cần thiết kế LLD từ đầu — gọi `datamart-lld-design`.

### Verify Atomic YAML thật trước khi chấp nhận 1 cột là READY — không suy luận từ tên

Một cột Datamart có thể tồn tại đầy đủ trong Attributes + Detail Mapping + HLD (đều báo READY, đều có `etl_logic`, đều trace được về KPI) mà **field Atomic nó tham chiếu chưa từng được thiết kế** — vì không có bước nào trong review buộc phải mở YAML approved và đếm số attribute thật.

Dấu hiệu để nghi ngờ (không phải để bỏ qua, mà để soi kỹ hơn):
- Tên cột "nghe rất hợp lý" cho 1 entity nhưng bạn chưa từng thấy nó trong YAML khi review case khác cùng entity (VD: entity Violation "chắc phải có" Type/Status, nhưng thực tế YAML chỉ ghi nhận field khi source thật có)
- `etl_logic` chỉ có 1 dòng `direct` từ `atomic_table.column`, không có JOIN nào khác để verify chéo

**Bước bắt buộc:** với mỗi Fact/Operational table đang review lần đầu (hoặc đã lâu chưa review), mở YAML của **driving entity** (Nguồn 1 `DataModel/Atomic/` trước, chỉ fallback Nguồn 2 `DataModel/working/Atomic/lld/` nếu không có ở Nguồn 1 — không bao giờ dùng `Atomic_LinhLV`) và **đếm số attribute thật**:
```bash
grep -c "^  - name:" DataModel/Atomic/**/dm_atm_{entity}-*.yaml
# nếu không tìm thấy, fallback:
grep -c "^  - name:" DataModel/working/Atomic/lld/**/lld_*{entity}*.yaml
```
Rồi liệt kê toàn bộ `physical_name` trong YAML, đối chiếu 1-1 với `atomic_column` mà Attributes đang tham chiếu cho entity đó. Bất kỳ `atomic_column` nào trong Attributes không xuất hiện trong danh sách physical_name thật → 🔴 Critical, dù cột đó đang báo READY — chuyển ngay về PENDING, không chờ báo cáo chạy sai mới phát hiện.

### Verify toàn vẹn CSV sau MỌI lần sửa hàng loạt (sed / Edit trên nhiều dòng)

Khi sửa Detail Mapping hoặc Attributes bằng `sed`/`replace_all` để cập nhật nội dung text (ghi chú, mô tả, công thức) hàng loạt trên nhiều dòng, dấu phẩy trong nội dung mới thêm **sẽ phá vỡ cấu trúc CSV** nếu không được bọc trong dấu ngoặc kép — vì các công cụ này không tự escape như CSV writer. Hậu quả: dòng bị tách quá số cột header, dữ liệu ở các cột sau bị lệch/mất mà không có lỗi hiển thị ngay lập tức (Python `csv.reader` vẫn đọc được, chỉ dữ liệu sai vị trí).

**Bắt buộc chạy sau MỌI lần sửa CSV bằng sed/Edit hàng loạt** (không chỉ 1 lần cuối review — chạy ngay sau từng thao tác sửa):
```python
import csv
with open('path/to/file.csv', encoding='utf-8-sig') as f:
    rows = list(csv.reader(f, delimiter=','))
header_len = len(rows[0])
bad = [i for i,r in enumerate(rows) if len(r) != header_len]
print('so dong loi:', len(bad), bad)  # phải rỗng
```
Nếu phát hiện dòng lệch — sửa lại bằng cách bọc phần text có dấu phẩy trong `"..."`, không chỉ sửa nội dung mà bỏ qua việc escape.

---

### Kiểm tra Physical Naming (Lớp 2 + Lớp 3)

**Nguồn sự thật:** `system/rules/rule_physical_name_exceptions_datamart.csv`

**Quy tắc:** Chỉ những từ trong file exceptions mới được viết tắt trong tên physical (`datamart_column`). Mọi từ khác phải dùng full word.

> ⛔ **KHÔNG chép bảng exceptions vào file này.** Danh sách chỉ tồn tại ở đúng 1 nơi là CSV trên — mọi bản sao nhúng đều sẽ lệch theo thời gian (bản sao cũ trong skill từng thiếu entry `Calendar → cdr`, gây ra 2 tên song song `calendar_dt_dim_id` / `cdr_dt_dim_id` trong master).

**Bắt buộc đọc CSV trước khi kết luận 1 tên là sai:**

```bash
cat system/rules/rule_physical_name_exceptions_datamart.csv
```

**Nguyên tắc derive tên physical từ logical (bắt buộc kiểm tra):**
- Physical name phải derive trực tiếp từ **tên logical** — KHÔNG được thay token bằng từ đồng nghĩa hay dạng mở rộng khác
- Quy tắc chỉ cho phép **viết tắt** các từ trong exceptions, KHÔNG cho phép **mở rộng** hay **đổi từ**
- Ví dụ vi phạm điển hình: logical "Exam Score" → `examination_score` ❌ (mở rộng "exam" → "examination") — đúng phải là `exam_score` ✅
- Cách phát hiện: với mỗi `datamart_column`, trace ngược lên `datamart_attribute` (tên logical) → tokenize → kiểm tra từng token có khớp không

**Khi review Lớp 2 (Attributes):** Kiểm tra `datamart_column` trong từng file Attributes detail — nếu có token viết tắt không thuộc exceptions, hoặc token bị đổi/mở rộng so với tên logical → 🔵 Info (naming inconsistency), phân loại **Kịch bản C**.

**Khi review Lớp 3 (Detail Mapping):** Kiểm tra `mart_column` trong cột `logic` — phải khớp với `datamart_column` trong Attributes. Nếu Detail Mapping vẫn dùng tên cũ (viết tắt) trong khi Attributes đã đổi → 🔴 Critical (logic reference sai).

**Cách phát hiện nhanh:**
```bash
# Tìm token viết tắt phổ biến không phải exception trong datamart_attributes.csv
grep -E "\b(ctf|prac|trn|rcrd|org|nat|cty|dcsn|rslt|ases|issu|pcs|ovrl|scor|vln|actv|clss|dept|pos|emp|doc|ind)\b" Datamart/lld/datamart_attributes.csv
```

**Action khi phát hiện:** **Kịch bản C** — trình bày action đề xuất (bảng: tên cũ → tên mới, danh sách file/dòng bị ảnh hưởng từ `grep -rn` toàn `Datamart/`) → chờ user xác nhận → gọi `datamart-lld-design` thực hiện field-rename-sync trên toàn bộ file output rồi verify sạch. ❌ Không tự Edit trực tiếp.
