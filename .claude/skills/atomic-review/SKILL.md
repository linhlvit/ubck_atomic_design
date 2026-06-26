---
name: atomic-review
description: |
  Review thiết kế Atomic cho 1 source system — kiểm tra tính nhất quán và đúng quy định
  xuyên suốt chuỗi: BRD Source → HLD Overview.
  Sử dụng khi: cần review/validate thiết kế Atomic sau khi hoàn thành HLD Overview.
  Gọi tay: /atomic-review [SOURCE]

  Input bắt buộc:
    BRD/Source/brd_{SOURCE}.yaml
    BRD/Source/{SOURCE}/brd_{SOURCE}_{TABLE}.yaml  (1 file per table, scope = in_scope hoặc pending nếu LLD chưa chạy)
    DataModel/working/Atomic/hld/{SOURCE}_HLD_Overview.md
---

# Skill: Review Atomic HLD

Đọc file này TRƯỚC KHI bắt đầu review bất kỳ source system nào.

---

## QUY TRÌNH REVIEW

### Bước 0 — Xác nhận input tồn tại (lazy — không đọc nội dung)

Chạy 4 shell commands, **không đọc nội dung bất kỳ file nào**:

```bash
# 1. File bắt buộc tồn tại?
ls BRD/Source/brd_{SOURCE}.yaml
ls DataModel/working/Atomic/hld/{SOURCE}_HLD_Overview.md
ls BRD/Source/{SOURCE}/ | wc -l        # đếm số BRD per-table

# 2. Scope dùng in_scope hay pending? + đếm số bảng trong scope
grep -c "scope_status: in_scope" BRD/Source/brd_{SOURCE}.yaml
grep -c "scope_status: pending" BRD/Source/brd_{SOURCE}.yaml

# 3. Đếm nhanh entity 7a và bảng 7f từ HLD Overview (đếm dòng bảng markdown)
grep -c "^| " DataModel/working/Atomic/hld/{SOURCE}_HLD_Overview.md

# 4. File tùy chọn tồn tại?
ls DataModel/working/Atomic/lld/manifest.yaml 2>/dev/null && echo "manifest: có" || echo "manifest: không"
ls DataModel/working/Atomic/hld/atomic_entities.yaml 2>/dev/null && echo "atomic_entities: có" || echo "atomic_entities: không"
```

> **Quy tắc scope:** Nếu `grep -c "in_scope"` trả về 0 → dùng `pending`. Nếu > 0 → dùng `in_scope`. Bảng `out_of_scope` không đưa vào scope review.

> **Sanity check sơ bộ từ grep dòng bảng:** Kết quả grep `^| ` là tổng dòng markdown table trong toàn file (gộp cả 7a, 7c, 7d, 7f và các bảng khác) — dùng để phát hiện file rỗng/bất thường, không phải số chính xác. Số chính xác của 7a và 7f sẽ được đếm khi TC tương ứng chạy.

Dừng ngay nếu file bắt buộc thiếu — báo lỗi cho human.

### Bước 1 — Lập kế hoạch và trình bày human duyệt

Tổng hợp từ output Bước 0, trình bày ngắn gọn — **không đọc thêm file nào**:

```
## Kế hoạch Review — {SOURCE}

Input: BRD tổng ✓ | HLD Overview ✓ | BRD per-table: {N} file
Scope: {in_scope / pending} — {total} bảng | HLD markdown rows: {M} dòng bảng
manifest: {có/không} | atomic_entities: {có/không}

TC-01 Lock status       → {chạy / bỏ qua (thiếu atomic_entities.yaml)}
TC-02 Tên Entity        → {chạy / 2e bỏ qua (thiếu manifest)}
TC-03 Table Type        → chạy
TC-04 Dependency Tier   → chạy
TC-05 7f Coverage       → chạy
TC-06 Junction table    → chạy
TC-07 Classification?   → chạy
TC-08 BCV Concept       → chạy
TC-09 Change Mode       → chạy
TC-10 Đồng bộ Tier files → chạy tự động sau TC-09

Xác nhận chạy toàn bộ? Hoặc chỉ định TC cụ thể.
```

### Bước 2 — Chờ human duyệt

- Human xác nhận chạy toàn bộ → chạy TC-01 đến TC-09 lần lượt, sau đó tự động chạy TC-10.
- Human chỉ định TC cụ thể → chỉ chạy các TC đó, theo đúng thứ tự.
- Human điều chỉnh scope → cập nhật kế hoạch, trình bày lại trước khi chạy.

### Bước 3 — Chạy lần lượt từng TC (lazy per TC)

**Nguyên tắc đọc file:** Mỗi TC chỉ đọc đúng phần cần — dùng `offset` + `limit` hẹp hoặc `grep` thay vì đọc full file. Không giữ raw content trong output — chỉ xuất bảng kết quả đã tổng hợp.

**Nguyên tắc self-review bắt buộc trước khi xuất output mỗi TC:**

Trước khi trình bày kết quả TC cho human, bắt buộc tự hỏi:

> *"Kết quả tôi chuẩn bị flag có đúng với quy tắc trong skill `atomic-hld-design` không?"*

Quy trình self-review (thực hiện trong đầu, không cần xuất ra):

1. **Đọc lại quy tắc liên quan trong skill `atomic-hld-design`** — đặc biệt với các trường hợp ngoại lệ, pattern riêng (Pure Junction, Classification Value, Geographic Area, Batch Processing Metadata, File Attachment...).
2. **Kiểm tra cross-reference với các section khác của HLD Overview** — một bảng nguồn có thể được xử lý hợp lệ tại 7c, 7d, 7e thay vì 7a/7f. Không flag "thiếu" chỉ vì không tìm thấy ở 7a hoặc 7f.
3. **Với mỗi flag lỗi dự kiến: tự đặt câu hỏi phản biện** — "Có quy tắc nào trong skill HLD cho phép thiết kế này không?" Nếu có → hạ xuống `Cần xác nhận`, không flag `Lỗi`.
4. **Chỉ flag `Lỗi` khi có vi phạm rõ ràng** — nếu còn nghi ngờ, luôn ưu tiên `Cần xác nhận` hoặc không flag.

> **Bài học từ lỗi TC-05 (SCMS):** Lớp 3 Coverage check ban đầu flag 23 bảng CAT_/LNK_ là "missing" vì chỉ so sánh với 7a + 7f, bỏ sót mục 7c (Classification Value) và 7d (Junction Tables). Cross-check với skill HLD mới phát hiện 23 bảng đó đã được xử lý đúng — không có lỗi thực sự. Self-review buộc phải kiểm tra đủ 4 section (7a + 7c + 7d + 7f) trước khi kết luận.

Quy tắc sau mỗi TC:

- **TC có lỗi** (Kết quả chứa `Lỗi` / `Sai quy tắc` / `Sai Tier` / `Bỏ sót` / `Vi phạm LOCKED`) → **dừng lại**, trình bày chi tiết lỗi và chờ human xử lý. Chỉ tiếp TC tiếp theo khi human xác nhận.
- **TC pass hoàn toàn** (tất cả dòng `OK` hoặc chỉ `Cần xác nhận` / `Cần xem xét`) → in kết quả ngắn gọn rồi **tự động chuyển sang TC tiếp theo**.

Sau TC cuối cùng: xuất **Báo cáo tổng hợp** theo format chuẩn ở cuối file này.

---

## TEST CASES

### TC-01 — Validate Lock status: entity 7a khớp với approved trong atomic_entities.yaml

**Mục tiêu:** Phát hiện entity trong mục 7a vi phạm LOCKED fields so với `atomic_entities.yaml` — chỉ áp dụng cho entity **đã tồn tại với status=approved** (shared entity từ source khác bổ sung source_table vào HLD hiện tại). Entity hoàn toàn mới chưa có trong `atomic_entities.yaml` → bỏ qua.

> Không trùng TC-02/3e: 3e check fuzzy tên entity qua `manifest.yaml`; TC-01 check toàn bộ 4 cột LOCKED theo `atomic_entities.yaml` chỉ với entity đã approved.

**Chỉ chạy nếu `atomic_entities.yaml` tồn tại.** Bỏ qua TC nếu file chưa có.

**Scope:** Tất cả entity trong mục 7a. Đọc từ:
- HLD Overview mục 7a — cột `Atomic Entity`, `Table Type`, `BCV Core Object`, `BCV Concept`
- `DataModel/working/Atomic/hld/atomic_entities.yaml` — toàn bộ entity + `status`

---

#### Bước 1 — Match entity 7a vào atomic_entities.yaml

Với mỗi entity trong mục 7a, tìm **exact match** tên trong `atomic_entities.yaml`:

| Kết quả tìm kiếm | Hành động |
|---|---|
| Không tìm thấy | Entity mới, chưa aggregate → **bỏ qua** (ngoài scope TC-01) |
| Tìm thấy, `status=draft` | Chưa lock, được phép sửa → **bỏ qua** |
| Tìm thấy, `status=approved` | → Chạy Bước 2 |

#### Bước 2 — Cross-check 4 cột LOCKED

So sánh giá trị trong mục 7a với giá trị đã approved trong `atomic_entities.yaml`:

| Cột LOCKED | Cột trong 7a | Cột trong atomic_entities.yaml |
|---|---|---|
| Tên entity | `Atomic Entity` | `atomic_entity` |
| Table Type | `Table Type` | `table_type` |
| BCV Core Object | `BCV Core Object` | `bcv_core_object` |
| BCV Concept | `BCV Concept` | `bcv_concept` |

Sai bất kỳ cột → **`Vi phạm LOCKED`** — lỗi nghiêm trọng.

> `source_table` và `description` được phép khác (bổ sung thêm khi shared entity) → không kiểm tra.

---

#### Output TC-01

| Atomic Entity | Status | Cột vi phạm | Giá trị 7a | Giá trị LOCKED | Kết quả | Đề xuất |
|---|---|---|---|---|---|---|

- **Kết quả**: `OK` / `Vi phạm LOCKED`
- **Đề xuất**: giá trị đúng cần chỉnh theo approved (nếu vi phạm); hoặc hướng dẫn đổi `status → draft` trước nếu thay đổi có chủ ý

---

### TC-02 — Validate Tên Atomic Entity

**Mục tiêu:** Kiểm tra tên Atomic entity trong mục 7a HLD Overview được đặt đúng quy tắc — bao gồm format tên, tính nhất quán prefix trong nhóm, quan hệ cha-con, và không xung đột với entity đã approved.

**Scope:** Chỉ entity trong mục 7a (Atomic entities). Đọc từ:
- HLD Overview mục 7a — cột `Atomic Entity`, `BCV Concept`, `BCV Core Object`, `Table Type`, `Tier`, `Category`
- `DataModel/working/Atomic/lld/manifest.yaml` — entity đã `status=approved` (input tùy chọn — kiểm tra nếu file tồn tại)

> **⚠️ Nguyên tắc chung TC-02 — đọc trước khi chạy từng điểm kiểm tra:**
> TC-02 kiểm tra **tính nhất quán** của tên, không kiểm tra **sự giống nhau literal với BCV Term**. Thiết kế HLD là sáng tạo có hướng dẫn — người thiết kế được phép dùng tên nghiệp vụ cụ thể hơn BCV Term nếu có giải thích. Trước khi flag bất kỳ lỗi nào ở 2a hoặc 2c:
> - Đọc cột `BCV Term` (2a) hoặc diagram 7b (2c) để lấy context đầy đủ.
> - Chỉ flag khi điều kiện phụ (ghi chú lý do / xác định cha đúng) **không thỏa** — không flag chỉ dựa vào so sánh tên literal.
> - Khi nghi ngờ: ưu tiên **không flag** và ghi `Cần xác nhận` thay vì flag `Lỗi`.

#### Các điểm kiểm tra

**2a — Tên entity phải chứa BCV Term (trừ ngoại lệ)**

BCV Term = phần sau dấu `]` trong cột `BCV Concept` (VD: `[Involved Party] Fund Management Company` → BCV Term = `Fund Management Company`).

Quy tắc cơ bản: `Atomic Entity` phải **chứa** BCV Term đó (substring, case-insensitive).

**Ngoại lệ — bỏ qua 2a, không flag:**

| Trường hợp | Lý do bỏ qua |
|---|---|
| BCV Term trùng với tên BCV Core Object (VD: `Transaction`, `Communication`, `Business Activity`, `Event`, `Documentation`, `Individual`) | Term quá generic — bắt buộc chứa làm tên entity vô nghĩa; hàng chục entity trong dự án chia sẻ cùng Term |
| Entity là shared entity (cột BCV Term trong 7a ghi "Shared Entity" hoặc entity đã có trong `atomic_entities.yaml` với `status=approved`) | Tên LOCKED — không được đổi dù không khớp |
| BCV Term gần bằng Core Object (VD: `Arrangement`, `Condition`, `Property`) và entity đã dùng tên nghiệp vụ cụ thể hơn | Tương tự trường hợp generic |

**Chỉ flag lỗi 2a khi đủ 2 điều kiện:**
1. BCV Term đủ đặc thù — có ít nhất 2 từ, không trùng Core Object, mang nghĩa domain cụ thể (VD: `Broker Dealer`, `Audit Firm`, `Assessment Period`, `Risk Category`, `Alert Rule`)
2. Tên entity dùng từ khác không chứa BCV Term **và** không có ghi chú lý do trong cột `BCV Term` của 7a

Lỗi thực sự: tên entity dùng tên bảng nguồn thô (VD: `RISK_REPORTING_PERIOD`) hoặc tên loại cụ thể hoàn toàn khác nghĩa với BCV Term mà không giải thích.

> **⚠️ Lưu ý thực thi — lỗi hay gặp khi review:**
> Kiểm tra điều kiện 2 TRƯỚC khi flag. Quy trình bắt buộc:
> 1. Đọc nội dung cột `BCV Term` trong 7a cho entity đang xét.
> 2. Nếu cột có ghi chú lý do (dù ngắn) → **bỏ qua, không flag**.
> 3. Chỉ flag khi cột trống hoặc chỉ ghi lại tên BCV Term mà không giải thích tại sao tên entity khác term.
>
> BCV Term là kim chỉ nam chọn concept — tên entity sau đó được đặt theo nghĩa nghiệp vụ cụ thể. Pattern `[Prefix] + [BCV Term]` là default, không phải bắt buộc tuyệt đối. 34/52 entity trong một source system thực tế (SCMS) không chứa BCV Term literal nhưng đều có ghi chú lý do hợp lệ → tất cả pass điều kiện 2.

**2b — Entity cùng nhóm nghiệp vụ phải chung prefix**

Nhóm nghiệp vụ = cột `Category` trong mục 7a (hoặc `functional_group` từ BRD nếu Category trống).

Quy tắc: tất cả entity trong cùng nhóm phải có chung prefix (phần đầu tên trước BCV Term).

Cách kiểm tra: group các entity theo Category → so sánh prefix → flag nếu trong cùng nhóm có 2+ prefix khác nhau.

Lỗi: entity cùng nhóm dùng prefix không nhất quán.

**2c — Tên entity con phải chứa đầy đủ tên entity cha**

Entity cha = entity ở Tier thấp hơn mà entity con có FK **duy nhất hoặc chính** trỏ đến (suy ra từ thứ tự Tier trong mục 7a + Diagram 7b nếu có).

Quy tắc: tên entity con phải chứa **toàn bộ** tên entity cha dưới dạng substring liên tục.

VD: entity cha = `Securities Company` → entity con phải là `Securities Company Branch`, không được là `Branch`.

**Xác định entity cha khi entity có nhiều FK:**
- Entity con có FK đến nhiều entity ở Tier cao hơn → cha là entity mà **tên entity con mô tả trực tiếp** (entity định nghĩa grain của entity con).
- VD: `Securities Company Shareholder Representative` FK đến cả `Securities Company Shareholder` (T2) và `Securities Company` (T1) → cha là `Securities Company Shareholder` vì entity con mô tả "đại diện của cổ đông", không phải "đại diện của CTCK".

**Ngoại lệ — bỏ qua 2c, không flag:**

| Trường hợp | Lý do bỏ qua |
|---|---|
| Entity cha là shared entity từ source khác (VD: `Geographic Area`, `Securities Practitioner`) | Tên cha LOCKED, entity con không nhất thiết embed |
| Entity con FK đến cha nhưng grain entity con là **instance riêng biệt** (không phải sub-record của cha) | VD: entity cha là entity tổ chức (Firm/Branch), entity con là người (Auditor/Personnel) — grain khác loại hoàn toàn; tên entity con không cần embed tên tổ chức cha nếu đã rõ domain qua prefix |

> **Lưu ý ngoại lệ thứ 2:** Áp dụng khi tên entity con đã có prefix domain rõ ràng phân biệt được cha (VD: `Securities Company Audit Firm Auditor` — vẫn phải embed `Audit Firm` vì không có prefix nào khác phân biệt auditor thuộc firm nào). Nếu không có prefix tường minh → vẫn bắt buộc embed tên cha.

Lỗi: tên entity con không chứa tên entity cha **và** không thỏa ngoại lệ nào ở trên.

> **⚠️ Lưu ý thực thi — lỗi hay gặp khi review:**
> Khi entity có nhiều FK (multi-dependency), xác định cha chính xác trước khi flag:
> 1. Đọc diagram 7b để biết tất cả FK của entity con.
> 2. Áp quy tắc: cha = entity mà **tên entity con mô tả trực tiếp** (định nghĩa grain).
> 3. Nếu entity con chứa tên bất kỳ cha nào trong chuỗi dependency → không flag.
> 4. Tên chứa prefix cấp cao (VD: `Securities Company`) là đủ nếu không có cha cấp trung rõ ràng hơn định nghĩa grain.

**2d — BCV Concept format và BCV Core Object hợp lệ**

Kiểm tra 2 điều kiện:
1. `BCV Concept` phải có format `[X] Term` — phần `X` trong ngoặc phải khớp chính xác với `BCV Core Object`.
2. `BCV Core Object` phải thuộc đúng 15 giá trị hợp lệ: `Involved Party`, `Location`, `Condition`, `Arrangement`, `Product`, `Transaction`, `Communication`, `Event`, `Business Activity`, `Documentation`, `Property`, `Business Direction`, `Common`, `Group`, `Accounting`.

Lỗi: format sai, hoặc X trong `[X]` không khớp `BCV Core Object`, hoặc Core Object ngoài 15 giá trị.

**2e — Entity trùng với approved entity → tên phải khớp chính xác (LOCKED)**

Chỉ chạy nếu `DataModel/working/Atomic/lld/manifest.yaml` tồn tại.

Quy tắc: nếu `Atomic Entity` trong HLD Overview trùng tên (hoặc gần trùng) với entity `status=approved` trong manifest → tên phải khớp **chính xác ký tự** — không được đổi tên, thêm bớt chữ.

Cách kiểm tra: so sánh fuzzy giữa tên entity trong 7a với danh sách entity approved trong manifest → flag các cặp gần khớp nhưng không khớp chính xác.

Lỗi: tên khác với entity approved — đây là lỗi nghiêm trọng nhất, ảnh hưởng toàn bộ LLD và mapping downstream.

#### Output TC-02

Bảng báo cáo:

| Atomic Entity | Điểm kiểm tra | Kết quả | Chi tiết lỗi | Đề xuất |
|---|---|---|---|---|

- **Điểm kiểm tra**: `2a` / `2b` / `2c` / `2d` / `2e`
- **Kết quả**: `OK` / `Lỗi`
- **Chi tiết lỗi**: mô tả cụ thể — BCV Term không khớp, prefix lệch nhóm, entity cha không phải substring, format sai, tên lệch approved
- **Đề xuất**: tên entity đúng / format đúng cần chỉnh

---

### TC-03 — Validate Table Type có đúng không

**Mục tiêu:** Kiểm tra `Table Type` trong mục 7a HLD Overview nhất quán với 3 trục: BCV Core Object + tín hiệu tên entity, Tier/FK dependency, và Source Change Mode.

**Scope:** Tất cả entity trong mục 7a. Đọc từ:
- HLD Overview mục 7a — cột `Atomic Entity`, `Table Type`, `BCV Core Object`, `Source Table Change Mode`, `Tier`
- HLD Overview mục 7e — ngoại lệ được ghi rõ (nếu có)

#### Bước 1 — Kiểm tra Table Type nhất quán với BCV Core Object và tín hiệu tên entity

| Tín hiệu | Table Type bắt buộc |
|---|---|
| `BCV Core Object = Common` | `Classification` |
| `BCV Core Object = Transaction` | `Fact Append` |
| Tên entity chứa "Activity Log" / "Status Log" / "Status History" | `Fact Append` |
| Tên entity chứa "Snapshot" | `Fact Snapshot` |

Lỗi: entity thỏa tín hiệu trên nhưng Table Type trong 7a không khớp.

Ngoại lệ: bỏ qua nếu entity đã được ghi rõ lý do ngoại lệ trong mục 7e.

→ Kết quả: `OK` / `Sai quy tắc`

#### Bước 2 — Kiểm tra Table Type nhất quán với Tier/FK dependency

Inference từ cột `Tier` trong mục 7a:

| Tier | Table Type | Nhận xét |
|---|---|---|
| Tier 1 | `Relative` | Nghi ngờ — Relative phải có FK đến Fundamental, thường là Tier 2+ |
| Tier 2+ | `Fundamental` | Nghi ngờ — entity phụ thuộc Tier trước nhưng tự chủ lifecycle |

Đây là flag `Cần xác nhận` — không phải lỗi cứng vì có exception hợp lệ (VD: Geographic Area Tier 1 vẫn là Fundamental do BCV ngoại lệ).

→ Kết quả: `OK` / `Cần xác nhận`

#### Bước 3 — Cross-check Source Change Mode ↔ Table Type

| Source Change Mode | Table Type | Kết quả |
|---|---|---|
| `Update` | `Fundamental` hoặc `Relative` | OK |
| `Append` | `Fact Append` | OK |
| `Update` | `Fact Append` | Cần xác nhận — nguồn có update nhưng Atomic insert-only; ETL có drop & reload không? |
| `Append` | `Fundamental` | Cần xác nhận — nguồn không update nhưng Atomic dùng SCD4A; business rule là gì? |
| `Append` | `Relative` | Cần xác nhận — SCD2 trên Append source bất thường; ETL xử lý thế nào? |
| `N/A` | Bất kỳ | Bỏ qua — chưa xác định mode |

→ Kết quả: `OK` / `Cần xác nhận`

#### Output TC-05

Bảng báo cáo (1 dòng per entity):

| Atomic Entity | Table Type | Source Change Mode | Bước 1 | Bước 2 | Bước 3 | Kết quả | Đề xuất |
|---|---|---|---|---|---|---|---|

- **Bước 1**: `OK` / `Sai quy tắc`
- **Bước 2**: `OK` / `Cần xác nhận (Tier {N} + Relative/Fundamental)`
- **Bước 3**: `OK` / `Cần xác nhận ({Mode} + {Table Type})`
- **Kết quả tổng**: `OK` / `Sai quy tắc` (Bước 1) / `Cần xác nhận` (Bước 2 hoặc 3)
- **Đề xuất**: Table Type đúng hoặc câu hỏi cần xác nhận với người thiết kế

---

### TC-04 — Validate Dependency Tier có đúng không

**Mục tiêu:** Kiểm tra số Tier gán cho từng entity trong mục 7a có đúng với dependency chain thực tế không — dựa vào diagram 7b (không cần đọc BRD per-table).

**Scope:** Tất cả entity trong mục 7a. Đọc từ:
- HLD Overview mục 7a — cột `Atomic Entity`, `Tier`
- HLD Overview mục 7b — diagram Mermaid (quan hệ FK giữa Atomic entities + Tier được gán)
- HLD Overview mục 7e — circular reference đã được ghi nhận (nếu có)

> **Lý do dùng 7b thay vì BRD per-table:** Diagram 7b đã phản ánh quan hệ Atomic entity sau thiết kế — FK đến Classification Value đã được loại bỏ, chỉ còn FK giữa Atomic entity. Đây chính xác là input cần để verify Tier mà không cần đọc lại BRD.

#### Bước 1 — Parse diagram 7b → xây dựng adjacency list

Từ diagram Mermaid trong mục 7b, extract:
- Danh sách entity + Tier được gán (từ comment `%% Tier N` hoặc `subgraph TN[...]`)
- Danh sách arrow `A --> B` = entity A FK đến entity B (A phụ thuộc B)

Kết quả: với mỗi entity, ghi nhận `tier_current` (từ diagram/7a) và `dependencies[]` (danh sách entity được FK đến).

#### Bước 2 — Tính Tier kỳ vọng và so sánh

Công thức:
```
tier_expected(A) = max(tier_current(B) for B in dependencies(A)) + 1
Nếu dependencies(A) rỗng (không FK đến Atomic entity nào) → tier_expected(A) = 1
```

So sánh `tier_expected` với `tier_current` từ mục 7a:
- Khớp → `OK`
- Không khớp → `Sai Tier`

**Xử lý circular reference:** Nếu A → B và B → A (FK lẫn nhau) → không flag lỗi nếu đã được ghi nhận trong mục 7e. Kết quả: `OK (circular — đã ghi 7e)`. Nếu chưa ghi 7e → flag `Thiếu ghi nhận circular`.

**Lưu ý multi-dependency:** Entity có FK đến nhiều entity ở Tier khác nhau → Tier được xác định bởi dependency sâu nhất. VD: A FK đến B (T2) và C (T1) → tier_expected(A) = 3, không phải 2.

#### Bước 3 — Kiểm tra tính nhất quán 7a ↔ 7b

| Trường hợp | Kết quả |
|---|---|
| Entity có trong 7a nhưng không có node tương ứng trong diagram 7b | `Thiếu trong 7b` |
| Node trong diagram 7b trỏ đến entity không có trong mục 7a | `Orphan ref trong 7b` |
| Entity có trong cả 7a và 7b, Tier khớp | `OK` |

#### Output TC-06

Bảng báo cáo:

| Atomic Entity | Tier hiện tại | Tier kỳ vọng | FK đến entity | Kết quả | Đề xuất |
|---|---|---|---|---|---|

- **Tier kỳ vọng**: số tính từ Bước 2, hoặc `—` nếu không có trong diagram 7b
- **FK đến entity**: danh sách entity phụ thuộc (từ diagram 7b), hoặc `(none)` nếu Tier 1
- **Kết quả**: `OK` / `OK (circular — đã ghi 7e)` / `Sai Tier` / `Thiếu trong 7b` / `Orphan ref trong 7b` / `Thiếu ghi nhận circular`
- **Đề xuất**: Tier đúng cần chỉnh / node cần bổ sung vào 7b / circular cần ghi 7e

---

### TC-05 — Review 7f Bảng ngoài scope

**Mục tiêu:** Kiểm tra mục 7f HLD Overview đúng format, phân loại đúng bản chất bảng, và bao phủ đủ toàn bộ bảng in_scope.

**Scope:** Mục 7f HLD Overview + `brd_{SOURCE}.yaml`. Đọc từ:
- HLD Overview mục 7a, 7f — cấu trúc bảng, Source Table, Nhóm, Lý do
- `BRD/Source/brd_{SOURCE}.yaml` — danh sách bảng `scope_status: in_scope` (chỉ Lớp 3)
- `reference/group_classification.md` — 13 group chuẩn + lý do chuẩn

---

#### Lớp 1 — Format (chỉ đọc mục 7f, không cần file khác)

| Check | Quy định | Cách kiểm tra |
|---|---|---|
| **7a** | Heading chính xác `#### 7f. Bảng ngoài scope` — đúng cấp `####`, đúng tiền tố | String match chính xác |
| **7b** | Bảng đúng 4 cột: `Nhóm \| Source Table \| Mô tả bảng nguồn \| Lý do ngoài scope` | Đếm cột header |
| **7c** | Grain đúng — cột Source Table mỗi dòng chỉ chứa 1 tên bảng (không có dấu phẩy) | String check từng dòng |
| **7d** | Group trong cột "Nhóm" phải thuộc 13 group chuẩn trong `reference/group_classification.md` | So sánh từng giá trị |
| **7e** | Cột "Lý do" phải dùng lý do chuẩn từ `group_classification.md` — mỗi Group có keyword chuẩn kỳ vọng | Heuristic: Lý do chứa ít nhất 1 keyword chuẩn của Group tương ứng |
| **7f** | Cột "Mô tả" mô tả nội dung bảng, không nhắc lại lý do — cột "Lý do" mô tả quan hệ/cấu trúc, không mô tả nội dung | Heuristic: Mô tả không bắt đầu bằng keyword lý do chuẩn |

**Keyword chuẩn theo Group** (dùng cho check 7e):

| Group | Keyword kỳ vọng trong Lý do |
|---|---|
| `Audit Log nguồn` | audit, log, OldValue, NewValue, PrevValue, FieldName, history, blob |
| `Snapshot nguồn` | snapshot, IsBefore, blob, SecData, TLData |
| `Junction` | junction, pure junction, denormalize, ARRAY |
| `Cascade drop` | cascade, drop từ |
| `Operational / System` | operational, system, configuration, infrastructure, không có giá trị nghiệp vụ |
| `Reference Data` | Classification Value, reference data |
| `Form Metadata` | form, template, metadata, field, placeholder |
| `Isolated` | isolated, không FK, không có quan hệ |
| `Intermediate` | intermediate, trung gian, lifecycle |
| `Shared Entity` | shared entity, source gốc |
| `Chưa có cột` | chưa có cột, chưa có thông tin |

---

#### Lớp 2 — Phân loại nhất quán (chỉ đọc mục 7f, không cần BRD)

**2a — Group `Audit Log nguồn` phải có dấu hiệu đúng:**

Dấu hiệu Audit Log nguồn theo skill: có cặp `OldValue`/`NewValue` (hoặc `PrevValue`/`ValueChange`) + cột `FieldName`.

Kiểm tra: Group = `Audit Log nguồn` nhưng:
- Tên bảng không có suffix `_HISTORY` / `_LOG` / `_AUDIT` / `_HIS`, **VÀ**
- Cột Lý do không đề cập OldValue/NewValue/blob/FieldName

→ Flag `Cần xem xét` — có thể là Group sai, cần verify cột trong BRD per-table.

**2b — Group `Cascade drop` phải chỉ rõ anchor:**

Kiểm tra 2 điều kiện:
1. Lý do phải chỉ rõ bảng anchor (VD: `Cascade drop từ FORM_REPORT`) — nếu không rõ → `Lỗi`
2. Anchor được chỉ rõ phải có mặt trong mục 7f (không phải 7a) — nếu anchor đang ở 7a → `Lỗi logic cascade` (đang cascade từ entity in-scope)

**2c — Group `Junction` phải phản ánh đúng cấu trúc:**

Lý do phải đề cập "junction", "pure junction", hoặc "denormalize" / "ARRAY". Nếu không → `Cần xem xét`.

---

#### Lớp 3 — Coverage (đọc thêm `brd_{SOURCE}.yaml`)

> **Coverage công thức đầy đủ:** Mỗi bảng `pending`/`in_scope` trong BRD phải xuất hiện ở **một trong bốn** mục: 7a (Atomic entity), 7c (Classification Value), 7d (Junction Table), hoặc 7f (Ngoài scope). Bảng `out_of_scope` trong BRD phải có trong 7f.

**Bước 1 — Sanity check số học (chạy trước, nếu lệch dừng ngay):**

```
total_scope     = count(scope_status: in_scope hoặc pending) từ brd_{SOURCE}.yaml
total_7a        = count(dòng data mục 7a HLD Overview)   ← Source Table — nhiều dòng/1 entity ok
total_7c        = count(dòng data mục 7c HLD Overview)   ← Classification Value
total_7d        = count(dòng data mục 7d HLD Overview)   ← Junction Tables
total_7f        = count(dòng data mục 7f HLD Overview)   ← Ngoài scope
```

Kỳ vọng: `total_scope ≈ unique_source_tables(7a) + total_7c + total_7d + total_7f`

> Lưu ý: 7a có thể có nhiều dòng cho 1 entity (multi-source), nên sanity check đếm unique Source Table, không đếm dòng. Nếu số lệch lớn (>2) → dừng ngay, không cần chạy Bước 2+3.

**Bước 2 — Chi tiết bảng bị sót:**

Với từng bảng `in_scope`/`pending` trong BRD: kiểm tra có xuất hiện trong cột Source Table của **7a, 7c, 7d, hoặc 7f** không.

- Không có ở bất kỳ mục nào → `Bỏ sót` — lỗi nghiêm trọng.
- Chỉ so sánh với 7a + 7f mà bỏ qua 7c/7d là sai phương pháp — sẽ flag false positive.

**Bước 3 — Phân loại chéo:**

Bảng xuất hiện đồng thời ở 2+ mục trong (7a, 7c, 7d, 7f) → `Phân loại chéo` — lỗi nghiêm trọng.

**Bước 4 — Orphan trong 7f:**

Bảng trong 7f không có trong BRD (không tìm thấy ở bất kỳ `scope_status`) → `Không có trong BRD` — kiểm tra có phải nhầm tên bảng không.

---

#### Output TC-07

**Output Lớp 1 + Lớp 2** (gộp, 1 dòng per check vi phạm):

| Lớp | Check | Source Table | Kết quả | Chi tiết |
|---|---|---|---|---|

- **Kết quả**: `OK` / `Lỗi` / `Cần xem xét`

**Output Lớp 3**:

| Source Table | Trạng thái BRD | Vị trí HLD | Kết quả | Đề xuất |
|---|---|---|---|---|

- **Kết quả**: `OK` / `Bỏ sót` / `Phân loại chéo` / `Không có trong BRD`

---

### TC-06 — Validate Junction table xử lý đúng không

**Mục tiêu:** Kiểm tra mục 7d HLD Overview — format đúng, entity chính tồn tại trong 7a, cột "Xử lý trên Atomic" đủ thành phần; và phát hiện bảng pure junction trong BRD bị bỏ sót hoàn toàn.

> Không trùng lặp: TC-02/2e bắt junction bị đặt nhầm vào 7a; TC-07/2c bắt group Junction trong 7f thiếu keyword. TC-08 tập trung vào nội dung xử lý trong 7d và bỏ sót hoàn toàn.

**Phân biệt 2 con đường hợp lệ cho junction:**
- **Con đường A (7d):** Xử lý được → denormalize thành `ARRAY` trên entity chính.
- **Con đường B (7f, group "Junction"):** Ngoài scope Atomic → không xử lý.

**Scope:** Mục 7d HLD Overview (Lớp 1+2) + BRD per-table (Lớp 3). Đọc từ:
- HLD Overview mục 7d — cột `Source Table`, `Entity chính`, `Xử lý trên Atomic`
- HLD Overview mục 7a — danh sách Atomic entity (chỉ Lớp 2)
- HLD Overview mục 7f — bảng ngoài scope (chỉ Lớp 3)
- `BRD/Source/{SOURCE}/brd_{SOURCE}_{TABLE}.yaml` — cấu trúc cột (chỉ Lớp 3)

---

#### Lớp 1 — Format mục 7d (chỉ đọc 7d)

| Check | Quy định | Cách kiểm tra |
|---|---|---|
| **1a** | Heading chính xác `#### 7d. Junction Tables` — đúng cấp `####`, đúng tiền tố | String match chính xác |
| **1b** | Bảng đúng 4 cột: `Source Table \| Mô tả \| Entity chính \| Xử lý trên Atomic` | Đếm cột header |
| **1c** | Grain — cột Source Table mỗi dòng chỉ chứa 1 tên bảng (không có dấu phẩy) | String check từng dòng |

---

#### Lớp 2 — Nhất quán nội dung trong 7d (đọc 7d + 7a)

**2a — "Entity chính" phải tồn tại trong mục 7a:**

Lấy giá trị cột `Entity chính` → so sánh với danh sách `Atomic Entity` trong mục 7a.

Lỗi: tên entity chính không khớp bất kỳ entity nào trong 7a — tham chiếu sai entity, ARRAY sẽ gắn nhầm.

**2b — Cột "Xử lý trên Atomic" phải chứa `ARRAY`:**

Cột `Xử lý trên Atomic` phải chứa ít nhất 1 trong:
- `ARRAY<Classification Value Code>` — cho loại junction entity↔Classification Value
- `ARRAY<STRUCT` — cho loại junction entity↔entity

Lỗi: cột chỉ ghi "denormalize" hoặc mô tả chung, không có `ARRAY<...>`.

**2c — Loại entity↔entity phải ghi rõ bên Many:**

Nếu cột `Xử lý trên Atomic` chứa `ARRAY<STRUCT` → phải chỉ rõ entity nào nhận ARRAY (bên "Many" trong quan hệ).

Dấu hiệu thiếu: không đề cập tên entity nhận hoặc không có từ "trên [Entity]".

→ Flag `Cần xác nhận` nếu thiếu.

---

#### Lớp 3 — Phát hiện junction bị bỏ sót (đọc BRD per-table)

**Bước 1 — Xác định pure junction candidate:**

Với mỗi bảng `in_scope`, đọc `brd_{SOURCE}_{TABLE}.yaml` → đếm cột nghiệp vụ (bỏ qua PK surrogate nếu có).

Candidate = bảng có đúng 2 cột nghiệp vụ đều là FK (`key: FK` hoặc `key: PK/FK`).

**Bước 2 — Phân loại từng candidate:**

| Vị trí HLD | Kết quả |
|---|---|
| Có trong mục 7d | Con đường A — `OK` |
| Có trong mục 7f với group `Junction` | Con đường B — `OK` |
| Có trong mục 7a | Trùng TC-02/2e — không flag lại ở đây |
| Có trong mục 7f với group khác | `Phân loại group sai` — cần xem xét |
| Không có trong 7d, 7a, lẫn 7f | `Bỏ sót hoàn toàn` — lỗi nghiêm trọng |

---

#### Output TC-08

**Output Lớp 1 + Lớp 2** (gộp, 1 dòng per check vi phạm):

| Lớp | Check | Source Table | Kết quả | Chi tiết |
|---|---|---|---|---|

- **Kết quả**: `OK` / `Lỗi` / `Cần xác nhận`

**Output Lớp 3**:

| Source Table | Vị trí HLD | Kết quả | Đề xuất |
|---|---|---|---|

- **Kết quả**: `OK` / `Bỏ sót hoàn toàn` / `Phân loại group sai`

---

### TC-07 — Validate Classification Value hay Entity

**Mục tiêu:** Kiểm tra mỗi bảng `in_scope` được phân loại đúng vị trí trong HLD Overview (7a / 7c / 7d) theo 4 lớp quy định của skill `atomic-hld-design`.

**Scope:** Chỉ bảng `in_scope`. Đọc từ:
- `BRD/Source/{SOURCE}/brd_{SOURCE}_{TABLE}.yaml` — cấu trúc cột + `table_meaning`
- `knowledge/reference_data_sets.csv` — BCV reference data set
- HLD Overview mục 7a, 7c, 7d — vị trí phân loại hiện tại + cột `BCV Core Object`, `Table Type`

#### Các điểm kiểm tra

**7a — Bảng chỉ Code + Name → phải ở 7c, không phải 7a**

Dấu hiệu nhận biết "chỉ Code + Name":
- Tổng số cột nghiệp vụ ≤ 3 (thường là: ID/PK + Code + Name/Description)
- Không có cột timestamp, trạng thái, FK đến entity nghiệp vụ, hay attribute mô tả lifecycle

Lỗi: bảng thỏa điều kiện trên nhưng đang nằm ở mục 7a.

**7b — Bảng có trong `reference_data_sets.csv` → phải ở 7c**

Tra cứu: `grep -i "{table_meaning_keyword}" knowledge/reference_data_sets.csv`

Lỗi: tìm thấy term tương ứng trong `reference_data_sets.csv` nhưng bảng đang nằm ở mục 7a.

**7c — Bảng địa lý → phải ở 7a, Table Type = Fundamental**

Dấu hiệu nhận biết bảng địa lý: `table_meaning` chứa keyword "tỉnh", "thành phố", "quốc gia", "khu vực", "địa lý", "vùng", "province", "country", "district", "region".

Lỗi: bảng địa lý đang nằm ở 7c thay vì 7a, hoặc nằm ở 7a nhưng Table Type ≠ Fundamental.

**7d — BCV Core Object = Common → Table Type phải là Classification**

Đọc từ mục 7a HLD Overview: cột `BCV Core Object` + cột `Table Type`.

Lỗi: dòng có `BCV Core Object = Common` nhưng `Table Type ≠ Classification`.

**7e — Pure junction table → phải ở 7d, không phải 7a**

Dấu hiệu nhận biết pure junction table từ `brd_{SOURCE}_{TABLE}.yaml`:
- Tổng số cột nghiệp vụ = 2 (hoặc 2 + PK surrogate)
- Cả 2 cột đều là FK (`key: FK` hoặc `key: PK/FK`)
- Không có attribute nghiệp vụ riêng (không có timestamp, amount, status, description...)

Lỗi: bảng thỏa điều kiện trên nhưng đang nằm ở mục 7a thay vì 7d.

**7f — Bảng lưu báo cáo đầu vào (submission) → để ở 7f, không phải 7a**

Mỗi phân hệ giám sát quản lý 1 nhóm đối tượng (CTCK, ngân hàng, quỹ...) và có bộ báo cáo định kỳ riêng mà đối tượng đó nộp lên. Các bảng lưu submission này (VD: `SC_FIRM_PERIODIC_REPORT`, `BANK_PERIODIC_REPORT`) **được thiết kế theo phương pháp riêng** — không thiết kế thành Atomic entity theo cách thông thường.

Dấu hiệu nhận biết bảng submission báo cáo:
- FK đến đối tượng giám sát (CTCK, ngân hàng...) + FK đến biểu mẫu (`FORM_REPORT_ID`) hoặc có `PERIOD`/`YEAR`/`QUARTER`
- Có workflow nộp: `SUBMISSION_DEADLINE`, `SENT_AT`, `APPROVED_AT`, `REJECTION_REASON`
- `RECORD_STATUS` phản ánh trạng thái nộp (chưa gửi/đã gửi/đã duyệt/từ chối/hủy)

**Bỏ qua (không flag):** bảng thuộc pattern này đang ở 7f — lý do ngoài scope đúng là "Thiết kế theo phương pháp báo cáo đầu vào" (không phải lý do thiếu thông tin). Lỗi thực sự chỉ là nếu bảng submission đang ở **7a** thay vì 7f.

#### Output TC-07

Bảng báo cáo:

| Source Table | Vị trí hiện tại | Điểm kiểm tra | Kết quả | Đề xuất |
|---|---|---|---|---|

- **Vị trí hiện tại**: `7a` / `7c` / `7d`
- **Điểm kiểm tra**: `7a` / `7b` / `7c` / `7d` / `7e`
- **Kết quả**: `OK` / `Sai vị trí` / `Sai Table Type`
- **Đề xuất**: để trống nếu OK; ghi rõ vị trí đúng / Table Type đúng nếu sai

---

### TC-08 — Validate BCV Concept phù hợp

**Mục tiêu:** Kiểm tra BCV Concept được gán cho mỗi entity trong mục 7a có đúng quy định không — term tồn tại trong BCV, Core Object xác định từ nội dung term (không từ category), concept là chi tiết nhất phù hợp, cấu trúc cột nhất quán với term.

> Lỗi phổ biến cần ưu tiên: *"Gán BCV Concept sai do không tra cứu tool"* (CLAUDE.md lỗi #3).

**Scope:** Tất cả entity trong mục 7a. Đọc từ:
- HLD Overview mục 7a — cột `BCV Concept`, `BCV Core Object`, `Source Table`
- `knowledge/terms.csv` — tra term theo tên + nội dung
- `BRD/Source/{SOURCE}/brd_{SOURCE}_{TABLE}.yaml` — cấu trúc cột (chỉ đọc khi có tín hiệu nghi ngờ từ Bước 1)

**Chiến lược đọc có chọn lọc:** Bước 2 và Bước 3 chỉ chạy cho entity có tín hiệu nghi ngờ từ Bước 1 — tránh đọc toàn bộ terms.csv + cột cho mọi entity.

#### Bước 1 — Xác nhận term tồn tại + lấy metadata

Với mỗi entity trong 7a, lấy BCV Term từ cột `BCV Concept` (phần sau `]`):

```
grep -i "{BCV Term}" knowledge/terms.csv
```

Kết quả cần ghi nhận: `category` và `description` của term tìm được.

| Trường hợp | Hành động |
|---|---|
| Không tìm thấy term | Flag lỗi — term không tồn tại trong BCV; → dừng, không cần Bước 2+3 |
| Tìm thấy, `category` = `BCV Core Object` trong 7a | Ghi nhận OK tạm thời → vẫn chạy Bước 3 |
| Tìm thấy, `category` ≠ `BCV Core Object` trong 7a | Tín hiệu nghi ngờ → chạy Bước 2 |

#### Bước 2 — Đánh giá Core Object đúng từ nội dung term

*(Chỉ chạy khi `category` ≠ `BCV Core Object` từ Bước 1)*

Đọc `description` + `description_vi` của term → tự hỏi: *"Term này mô tả thực thể thuộc Data Concept nào?"*

Quy tắc: Core Object phải xác định từ **nội dung** term, không từ `category` trong terms.csv. Một term có thể nằm ở category khác với Data Concept thực sự.

VD: `Involved Party Rating` nằm trong `category = Group` nhưng nội dung mô tả quan hệ Rating áp dụng cho Involved Party → BCV Concept đúng = `[Involved Party]`, không phải `[Group]`.

| Kết quả đánh giá | Kết luận |
|---|---|
| Nội dung term xác nhận `BCV Core Object` trong 7a là đúng | OK — category lệch nhưng concept đúng |
| Nội dung term cho thấy `BCV Core Object` đúng phải là `category` | Lỗi — Core Object sai |

#### Bước 3 — Đối chiếu cấu trúc trường + kiểm tra concept chi tiết nhất

*(Chạy cho tất cả entity — kể cả entity OK ở Bước 1+2)*

Đọc `brd_{SOURCE}_{TABLE}.yaml` → danh sách cột → đặt câu hỏi:

**3a — Cấu trúc trường nhất quán với BCV term không?**

Tên bảng khớp BCV term không đồng nghĩa concept khớp — cấu trúc trường mới là căn cứ quyết định. Các trường mô tả thực thể thuộc loại gì? Có mâu thuẫn với nội dung BCV term không?

Lỗi: cấu trúc trường mô tả thực thể khác với BCV term được gán.

**3b — Có term chi tiết hơn bị bỏ sót không?**

Trong `terms.csv`, tìm thêm các term có keyword tương tự nhưng chi tiết hơn (scope hẹp hơn, đặc thù hơn với cấu trúc cột thực tế).

Quy tắc: chọn concept **chi tiết nhất** phù hợp — không dùng term cha khi có term con phù hợp hơn.

VD: bảng nhân viên → `Individual` chi tiết hơn `Involved Party`; bảng tài khoản chứng khoán → `Securities Account` chi tiết hơn `Arrangement`.

Lỗi: tồn tại term chi tiết hơn phù hợp với cấu trúc cột nhưng không được gán.

#### Output TC-08

Bảng báo cáo:

| Atomic Entity | BCV Concept hiện tại | Term tồn tại | Core Object đúng | Cấu trúc trường nhất quán | Concept chi tiết nhất | Kết quả | Đề xuất |
|---|---|---|---|---|---|---|---|

- **Term tồn tại**: `Có` / `Không`
- **Core Object đúng**: `OK` / `Lỗi` / `N/A` (không qua Bước 2)
- **Cấu trúc trường nhất quán**: `OK` / `Lỗi`
- **Concept chi tiết nhất**: `OK` / `Có term tốt hơn: {term}`
- **Kết quả**: `OK` / `Lỗi nghiêm trọng` (term không tồn tại / Core Object sai) / `Cần xem xét` (có term chi tiết hơn)
- **Đề xuất**: BCV Concept đúng cần chỉnh (nếu có lỗi)

---

### TC-09 — Validate Source Table Change Mode

**Mục tiêu:** Kiểm tra chuỗi nhất quán:
```
Cột thực tế (brd_{SOURCE}_{TABLE}.yaml)
        ↓  quy tắc 2 bước (source-survey skill)
data_change_mode (brd_{SOURCE}.yaml)          ← Bước A
        ↓  copy vào HLD
Source Table Change Mode (HLD_Overview mục 7a) ← Bước B
```

**Scope:** Chỉ bảng `in_scope`.

#### Bước A — Validate data_change_mode trong BRD

Với mỗi bảng `in_scope`, đọc `BRD/Source/{SOURCE}/brd_{SOURCE}_{TABLE}.yaml` → áp dụng quy tắc 2 bước:

**Bước 1 — Pattern matching trên tên cột** (case-insensitive, bỏ `_`):

| Điều kiện | expected_mode | Ghi chú |
|---|---|---|
| Có cột chứa `updated` / `modified` / `last_update` / `last_sync` / `sync_updated` | `Update` | Ưu tiên kiểm tra nhóm này trước |
| Chỉ có cột chứa `created` / `insert` / `create` — không có nhóm "cập nhật" | `Append` | |
| Không có cột nào thuộc cả 2 nhóm | → Bước 2 | |

**Bước 2 — Reasoning theo `table_meaning`** (khi Bước 1 không xác định được):

| Điều kiện | expected_mode |
|---|---|
| `table_meaning` chứa keyword: "lịch sử", "log", "history", "nhật ký", "theo dõi" | `Append` |
| `table_meaning` chứa keyword: "danh mục", "loại", "link", "danh sách", "tham chiếu" | `Update` |
| Không xác định được | `Update` (safe default) |

So sánh `expected_mode` với `data_change_mode` hiện tại trong `brd_{SOURCE}.yaml`.

#### Bước B — Validate Source Table Change Mode trong HLD Overview

So sánh `data_change_mode` trong `brd_{SOURCE}.yaml` với cột `Source Table Change Mode` trong mục 7a HLD Overview.

Các trường hợp lỗi:
- Giá trị khác nhau (copy nhầm / thiếu sync)
- Ô trống hoặc `N/A` trong khi BRD đã có giá trị

#### Output TC-09

Bảng báo cáo:

| Source Table | Cột xác định mode | Expected Mode | BRD Mode | HLD Mode | Kết quả | Đề xuất |
|---|---|---|---|---|---|---|

- **Cột xác định mode**: tên cột keyword tìm được (Bước 1), hoặc `table_meaning` keyword (Bước 2), hoặc `safe default`
- **Kết quả**: `OK` / `Sai BRD` / `Sai HLD` / `Sai cả hai`
- **Đề xuất**: để trống nếu OK; ghi rõ giá trị cần chỉnh nếu sai

---

### TC-10 — Đồng bộ Tier files với HLD Overview

**Mục tiêu:** Sau khi TC-01→09 hoàn tất và mọi thay đổi đã được áp dụng lên HLD Overview, đảm bảo nội dung các file `{SOURCE}_HLD_Tier{N}.md` khớp chính xác với mục 7a HLD Overview.

> **Nguyên tắc:** HLD Overview mục 7a là source of truth. Tier files là presentation layer — cần đồng bộ theo Overview, không ngược lại.

**Chạy tự động sau TC-09.** Không cần human xác nhận trung gian — TC-10 là bước kết thúc bắt buộc của mỗi review session.

**Scope:** Tất cả file `{SOURCE}_HLD_Tier{N}.md` tồn tại trong `DataModel/working/Atomic/hld/`. Đọc từ:
- HLD Overview mục 7a — danh sách entity hiện tại với Tier, tên, Table Type, BCV Concept, BCV Core Object
- Tất cả file `{SOURCE}_HLD_Tier{N}.md` — mục 6a (bảng tổng quan entity của tầng đó)

---

#### Bước 1 — Liệt kê Tier files hiện có

```bash
ls DataModel/working/Atomic/hld/{SOURCE}_HLD_Tier*.md
```

Ghi nhận danh sách file Tier hiện có. Nếu không có file Tier nào → báo và kết thúc TC-10 (không có gì để đồng bộ).

#### Bước 2 — Build snapshot từ Overview 7a

Từ mục 7a HLD Overview, xây dựng bảng tham chiếu:

| Tier | Atomic Entity | Table Type | BCV Core Object | BCV Concept |
|---|---|---|---|---|

Đây là **trạng thái đúng** cần đồng bộ sang Tier files.

#### Bước 3 — So sánh từng Tier file với snapshot

Với mỗi file `{SOURCE}_HLD_Tier{N}.md`, đọc mục 6a → so sánh với snapshot:

| Loại lệch | Mô tả | Hành động |
|---|---|---|
| **Entity thừa** | Entity trong 6a của TierN nhưng không có trong Overview 7a hoặc Tier đã đổi | Xóa dòng khỏi file Tier cũ; thêm vào file Tier mới nếu Tier đã đổi |
| **Entity thiếu** | Entity trong Overview 7a với Tier=N nhưng không có trong 6a của TierN | Thêm dòng vào file Tier đúng |
| **Cột lệch** | Entity có trong cả hai nhưng tên/Table Type/BCV Concept/BCV Core Object khác | Cập nhật dòng trong Tier file theo Overview |

#### Bước 4 — Kiểm tra Tier file rỗng / Tier file thiếu

- **Tier file rỗng sau bước 3** (mục 6a không còn dòng data): xóa file.
- **Tier mới xuất hiện trong Overview nhưng chưa có file**: tạo file `{SOURCE}_HLD_Tier{N}.md` mới từ template, điền mục 6a với các entity thuộc Tier đó. Các mục 6b–6f để trống hoặc ghi `*(Chưa cập nhật sau review)*`.

#### Bước 5 — Verify số liệu cuối

```
count(entity trong tất cả mục 6a Tier files) = count(dòng data mục 7a Overview)
```

Nếu lệch → kiểm tra lại Bước 3–4, không được kết thúc TC-10 khi số liệu còn lệch.

---

#### Output TC-10

**Bảng thay đổi đã thực hiện:**

| File Tier | Entity | Loại thay đổi | Chi tiết |
|---|---|---|---|

- **Loại thay đổi**: `Thêm mới` / `Xóa` / `Di chuyển (TierA → TierB)` / `Cập nhật cột`
- Nếu không có thay đổi nào: ghi `Không có thay đổi — Tier files đã đồng bộ`.

**Verify cuối:**
```
Tổng entity Overview 7a: {N}
Tổng entity Tier files (sau sync): {N}
Kết quả: Khớp ✓ / Lệch {X} entity ✗
```

---

## BÁO CÁO TỔNG HỢP

Sau khi chạy tất cả Test Case, xuất báo cáo theo format:

```
## Kết quả Review — {SOURCE} — {ngày}

### TC-01: Lock status entity approved
- Tổng entity kiểm tra (chỉ entity approved trong atomic_entities.yaml): {N}
- OK: {X} | Vi phạm LOCKED: {Y}
[bảng chi tiết]

### TC-02: Tên Atomic Entity
- Tổng entity kiểm tra: {N}
- OK: {X} | Lỗi 2a: {Y} | Lỗi 2b: {Z} | Lỗi 2c: {W} | Lỗi 2d: {V} | Lỗi 2e (LOCKED): {U}
[bảng chi tiết]

### TC-03: Table Type có đúng không
- Tổng entity kiểm tra: {N}
- OK: {X} | Sai quy tắc: {Y} | Cần xác nhận: {Z}
[bảng chi tiết]

### TC-04: Dependency Tier có đúng không
- Tổng entity kiểm tra: {N}
- OK: {X} | Sai Tier: {Y} | Thiếu trong 7b: {Z} | Orphan ref: {W} | Thiếu ghi nhận circular: {V}
[bảng chi tiết]

### TC-05: 7f Bảng ngoài scope
- Lớp 1+2 — Format & Phân loại: OK: {X} | Lỗi: {Y} | Cần xem xét: {Z}
- Lớp 3 — Coverage: Sanity check lệch: {D} | Bỏ sót: {E} | Phân loại chéo: {F} | Không có trong BRD: {G}
[bảng chi tiết]

### TC-06: Junction table xử lý đúng không
- Lớp 1+2 — Format & Nội dung: OK: {X} | Lỗi: {Y} | Cần xác nhận: {Z}
- Lớp 3 — Coverage: OK: {A} | Bỏ sót hoàn toàn: {B} | Phân loại group sai: {C}
[bảng chi tiết]

### TC-07: Classification Value hay Entity
- Tổng bảng kiểm tra: {N}
- OK: {X} | Sai vị trí: {Y} | Sai Table Type: {Z}
[bảng chi tiết]

### TC-08: BCV Concept phù hợp
- Tổng entity kiểm tra: {N}
- OK: {X} | Lỗi nghiêm trọng: {Y} | Cần xem xét: {Z}
[bảng chi tiết]

### TC-09: Source Table Change Mode
- Tổng bảng in_scope: {N}
- OK: {X} | Sai BRD: {Y} | Sai HLD: {Z} | Sai cả hai: {W}
[bảng chi tiết]

### TC-10: Đồng bộ Tier files
- Tổng thay đổi: {N} (Thêm mới: {A} | Xóa: {B} | Di chuyển: {C} | Cập nhật cột: {D})
- Verify: Overview {N} entity = Tier files {N} entity — {Khớp ✓ / Lệch ✗}
[bảng chi tiết thay đổi]

### Tổng kết
- Số vấn đề cần xử lý: {tổng}
- Ưu tiên cao (ảnh hưởng cấu trúc): [TC-01 Vi phạm LOCKED, TC-02/2e LOCKED, TC-08 Lỗi nghiêm trọng, TC-05 Bỏ sót / Phân loại chéo, TC-06 Bỏ sót hoàn toàn, TC-04 Sai Tier, TC-07 Sai vị trí, TC-09 Sai BRD]
- Ưu tiên trung bình (sai quy tắc thiết kế): [TC-05 Lỗi logic cascade, TC-06 Lỗi tham chiếu entity / Thiếu ARRAY, TC-03 Sai quy tắc, TC-08 Cần xem xét, TC-02/2a 2b 2c 2d, TC-07 Sai Table Type, TC-04 Thiếu ghi nhận circular]
- Ưu tiên thấp (sync/format): [TC-06 Phân loại group sai / Cần xác nhận, TC-05 Cần xem xét / Không có trong BRD, TC-04 Thiếu trong 7b / Orphan ref, TC-03 Cần xác nhận, TC-09 Sai HLD, TC-10 Cập nhật cột Tier file]
```
