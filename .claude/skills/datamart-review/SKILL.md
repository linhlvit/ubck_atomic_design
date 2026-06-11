---
name: datamart-review
description: |
  Review cross-check tài liệu BA analyst ↔ thiết kế Datamart (HLD + LLD) cho một module.
  Mục đích: đảm bảo chuỗi Source → Atomic → Datamart → Báo cáo/Dashboard/DataExplorer
  phản ánh đúng logic nghiệp vụ theo BA.

  Sử dụng khi: cần review toàn bộ hoặc một nhóm cụ thể trong một module Datamart.
  Gọi tay: /datamart-review [MODULE] [nhóm N] (nhóm N tuỳ chọn — bỏ qua để review toàn module)

  Input bắt buộc: BA_analyst_{MODULE}.csv + DTM_{MODULE}_HLD.md +
                  DTM_{MODULE}_Attributes.csv + DTM_{MODULE}_Detail_Mapping.csv
---

# Skill: Review Cross-check Datamart

Đọc file này TRƯỚC KHI bắt đầu review bất kỳ module nào.

## Tài nguyên đi kèm

- **Reference:**
  - [`reference/review_checklist.md`](reference/review_checklist.md) — checklist chi tiết 3 lớp HLD/Attributes/Detail Mapping
  - [`reference/issue_classification.md`](reference/issue_classification.md) — phân loại vấn đề và hành động tương ứng
- **Skills liên quan (gọi khi cần):**
  - `datamart-hld-design` — gọi khi nhóm HLD = PENDING nhưng BA = Done (cần thiết kế mới)
  - `datamart-lld-design` — gọi khi logic BA thay đổi (cần cập nhật Attributes hoặc Detail Mapping)

---

## NGUYÊN TẮC CỐT LÕI

### Chuỗi truy vết đầy đủ

```
BA analyst (logic nghiệp vụ)
    ↓
Source (bảng nguồn IDS/T24/MSS...)
    ↓  [1:1 thông tin]
Atomic (chuẩn hoá, entity Atomic)
    ↓  [Attributes.csv mô tả mapping này]
Datamart (Fact/Dim/Operational)
    ↓  [Detail_Mapping.csv mô tả mapping này]
Báo cáo / Dashboard / DataExplorer
```

**Quy tắc then chốt:** BA mô tả trực tiếp từ bảng nguồn (VD: `IDS.data.field_x`).
Khi review, cần tìm trường tương ứng trên Atomic vì Source → Atomic là 1:1 thông tin.
Không so sánh BA trực tiếp với Datamart mà bỏ qua lớp Atomic.

### Phân biệt 3 kịch bản phát hiện vấn đề

| Kịch bản | Dấu hiệu | Hành động |
|---|---|---|
| **A — HLD thiếu / PENDING, BA đã Done** | HLD status = PENDING hoặc nhóm chưa có trong HLD, BA = Done với nguồn đầy đủ | Gọi `datamart-hld-design` để thiết kế/cập nhật |
| **B — Logic BA thay đổi** | BA cập nhật công thức/nguồn/filter mới, Attributes hoặc Detail Mapping chưa phản ánh | Gọi `datamart-lld-design` để sửa LLD |
| **C — Lỗi thiết kế** | Attributes/Detail Mapping sai về kỹ thuật (sai type, sai key, thiếu cột...) không liên quan BA thay đổi | Sửa trực tiếp file LLD tương ứng |

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
> 2. Sau mỗi nhóm: DỪNG, không tự chuyển sang nhóm tiếp theo khi chưa có lệnh từ user
> 3. Trước mọi sửa đổi file: DỪNG, không sửa khi chưa được user xác nhận rõ ràng
>
> **Câu hỏi kết thúc mỗi nhóm (bắt buộc):**
> "Nhóm N đã review xong. Bạn muốn: **(a)** sửa [vấn đề X] ngay, **(b)** ghi nhận và sang nhóm N+1, hay **(c)** dừng tại đây?"

---

## BƯỚC 0 — XÁC ĐỊNH SCOPE

1. Đọc tham số user cung cấp: MODULE + (tuỳ chọn) số nhóm cụ thể
2. Resolve đường dẫn file:
   - BA: `BRD/BA/BA_analyst_{MODULE}_part*.csv` (có thể nhiều part)
   - HLD: `Datamart/hld/DTM_{MODULE}_HLD.md`
   - Attributes: `Datamart/lld/DTM_{MODULE}_Attributes.csv`
   - Detail Mapping: `Datamart/lld/DTM_{MODULE}_Detail_Mapping.csv`
3. Kiểm tra file tồn tại — báo cáo file nào thiếu, không dừng nếu chỉ thiếu 1 lớp LLD
4. Thông báo scope và danh sách file sẽ review

---

## BƯỚC 0b — LẬP KẾ HOẠCH REVIEW

> Bước này thực hiện **một lần duy nhất** trước khi bắt đầu review chi tiết bất kỳ nhóm nào.
> Mục đích: cho user thấy toàn cảnh trước khi đi vào từng nhóm.

### 0b.1 — Đọc nhanh toàn bộ BA

Dùng Python `csv.reader` đọc toàn bộ part file. Với mỗi nhóm (STT), tổng hợp:
- Tên nhóm (Col 2)
- Tổng KPI, số Done, số Doing, số Pending
- Bảng nguồn xuất hiện (Col 15) — để đánh giá có Atomic sẵn không

**Xác định trạng thái BA per-nhóm:**
- `ALL_DONE`: 100% Done/Doing — nguồn đầy đủ
- `PARTIAL`: có Done/Doing + còn Pending
- `ALL_PENDING`: 100% Pending hoặc trống — chưa có nguồn

### 0b.2 — Đọc nhanh HLD

Với mỗi nhóm trong BA, kiểm tra trong HLD:
- Nhóm có section trong HLD không?
- Trạng thái HLD: `READY` / `PENDING` / `Chưa có`

### 0b.3 — Xuất bảng kế hoạch tổng thể

| Nhóm | Tên nhóm | BA Status | HLD Status | Ưu tiên | Action dự kiến |
|---|---|---|---|---|---|
| 1 | Dashboard chấm điểm CTDC | ALL_PENDING | PENDING | ⬜ Thấp | Giữ nguyên — chờ nguồn |
| 6 | GSTT thống kê niêm yết | ALL_DONE | READY | 🟢 Review | Review 3 lớp |
| 25 | BCTC DN bảo hiểm | ALL_DONE | PENDING | 🔴 Cao | Thiết kế HLD mới (Kịch bản A) |

**Mức ưu tiên:**
- 🔴 Cao: BA Done nhưng HLD PENDING hoặc LLD trống — cần thiết kế mới
- 🟡 Trung: HLD READY, có thể có delta từ BA cập nhật — cần xác nhận
- 🟢 Review: HLD READY, BA Done, cần cross-check đảm bảo không lệch
- ⬜ Thấp: BA ALL_PENDING — chưa có gì để review, giữ nguyên

### 0b.4 — ⛔ DỪNG, hỏi user

Sau khi trình bày bảng kế hoạch, hỏi:

> "Đây là kế hoạch review [N] nhóm của module [MODULE]. Bạn muốn:
> - Review **theo thứ tự trên** (ưu tiên 🔴 trước)?
> - Review **tuần tự 1→N** theo số nhóm?
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

# Attributes và Detail Mapping — delimiter comma
attr_rows = []
with open('Datamart/lld/DTM_{MODULE}_Attributes.csv', encoding='utf-8-sig') as f:
    reader = csv.reader(f, delimiter=',')
    for row in reader:
        attr_rows.append(row)
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
| **KPI coverage BA→HLD** | Mọi KPI Done/Doing trong BA phải có KPI_ID trong HLD; KPI Pending phải ghi nhận PENDING |
| **KPI coverage HLD→BA (chiều ngược)** | Mọi KPI_ID trong HLD phải truy về được ít nhất 1 dòng trong BA analyst — nếu không tìm thấy → KPI dư, hỏi BA xác nhận trước khi xóa |
| **Grain** | Grain mô tả rõ ràng, đúng với logic BA |
| **Bảng Fact/Dim** | Fact/Dim đủ để phản ánh dimension filter/slicer trong BA |
| **Chiều (Slicer/Filter)** | Mọi dòng BA `Phân loại = Chiều` phải có KPI_ID trong HLD |

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
| **ETL logic — trace từ BA** | Với mỗi KPI Done: lấy tên bảng/trường nguồn BA ghi → tra `atomic_attributes.csv` → xác nhận `atomic_table.atomic_column` trong Attributes có khớp không |
| **ETL logic — nội dung đúng** | `etl_logic` đúng với logic BA: JOIN đúng bảng, filter condition đúng (VD: `row_code`, `entp_tp_code`), aggregation đúng phép tính |
| **Data domain / type** | Khớp với tính chất KPI (số tiền, tỷ lệ, đếm...) |
| **Key constraints** | FK đúng, nullable đúng với business rule |
| **src_stm_code** | Dim/Operational có `src_stm_code`, Fact No-Driving-Table không có |

**Quy trình trace BA → Atomic → Datamart (bắt buộc với mọi KPI Done):**

```
Bước A: Đọc BA — xác định tên bảng nguồn và tên trường (VD: IDS.data, cột row_value lọc theo row_code)
Bước B: Tra atomic_attributes.csv — tìm source_table khớp với bảng nguồn BA
         → Lấy atomic_table + atomic_column tương ứng
         → Nếu không tìm thấy → Gap Atomic (ghi nhận, không phải lỗi LLD)
Bước C: Kiểm tra Attributes — atomic_table + atomic_column trong Attributes có khớp kết quả Bước B?
         → Không khớp → 🔴 Critical (map sai Atomic entity/column)
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
| **column_role** | MEASURE / SLICER / FILTER / DERIVED đúng tính chất |
| **mart_table/mart_column** | Dùng tên logical, tồn tại trong HLD và Attributes |
| **KPI Pending** | Có dòng trong Detail Mapping với `mart_table`/`mart_column`/`logic` trống |
| **Chiều lặp lại** | Mỗi nhóm có explicit SLICER/FILTER — không dùng shorthand "xem nhóm X" |

**Quy trình trace BA → Detail Mapping (bắt buộc với mọi KPI Done):**

```
Bước A: Đọc BA — xác định công thức KPI: aggregation (COUNT/SUM/AVG), filter condition, derived formula
Bước B: Đọc Detail Mapping — logic của KPI_ID tương ứng
Bước C: Đối chiếu từng thành phần:
         → Aggregation: BA ghi SUM → logic phải là SUM (không được COUNT)
         → Filter: BA ghi "loại hình BCTC = Kiểm toán" → logic phải có WHERE tương ứng
         → Derived: BA ghi "A/B" → logic phải là DERIVED với mart_table/mart_column trống
         → Sai/thiếu → 🔴 Critical nếu ảnh hưởng kết quả, 🟡 Warning nếu thiếu một phần
Bước D: Kiểm tra mart_table.mart_column → trace ngược lên Attributes → xác nhận cột tồn tại và đúng
```

Output lớp 3:
```
Detail Mapping | [OK / GAP / WARN] | Mô tả vấn đề nếu có (kèm: BA ghi gì → Detail Mapping dùng gì → delta nếu có)
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
3. **Gọi skill tương ứng** khi action = Kịch bản A hoặc B:
   - Kịch bản A → `/datamart-hld-design` với context nhóm cụ thể
   - Kịch bản B → `/datamart-lld-design` với context thay đổi cụ thể
4. **Sửa file trực tiếp** chỉ với Kịch bản C sau khi user xác nhận

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
   │ → Hỏi: "Tiếp tục nhóm N+1?"  │
   └────────────────────────────────┘
   ┌────────────────────────────────┐
   │ User chọn (b)                 │
   │ → Ghi nhận vào backlog        │
   │ → Chuyển sang review nhóm N+1 │
   └────────────────────────────────┘
   ┌────────────────────────────────┐
   │ User chọn (c)                 │
   │ → Tổng hợp backlog đã ghi nhận│
   │ → Xuất bảng action items cuối │
   └────────────────────────────────┘
```

### Quy tắc cứng

- **KHÔNG tự chuyển nhóm** — luôn phải có lệnh từ user
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

BA hay ghi công thức dạng `IDS.data.field` thay vì tên Atomic.
Cần tìm Atomic entity/column tương ứng qua `atomic_attributes.csv`.
Nếu không tìm thấy → ghi nhận là gap Atomic (cần bổ sung Atomic trước khi thiết kế Datamart).

### Khi Detail Mapping trống (nhóm chưa thiết kế)

Nếu nhóm BA = Done nhưng Detail Mapping hoàn toàn trống → đây là Gap lớn (Critical).
Cần thiết kế LLD từ đầu — gọi `datamart-lld-design`.
