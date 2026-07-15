---
name: atomic-hld-design
description: |
  Thiết kế High-Level Design (HLD) cho Atomic source system trong kiến trúc Medallion.
  Sử dụng khi: thiết kế HLD cho 1 source mới (DCST/FIMS/FMS/GSGD/IDS/NHNCK/SCMS/QLRR/ThanhTra...),
  phân tầng Tier dependency, tra BCV, rà soát shared entity, xuất file
  {SOURCE}_HLD_Tier{N}.md hoặc {SOURCE}_HLD_Overview.md trong DataModel/working/Atomic/hld/.
  Cũng dùng khi cập nhật mục 7f (bảng ngoài scope), điều chỉnh source_table cho
  shared entity, hoặc cần chạy aggregate_atomic.py / aggregate_out_of_scope.py.
  Yêu cầu: source_system phải có thư mục BRD/Source/{SOURCE}/ chứa các file
  brd_{SOURCE}_{TABLE}.yaml per-table (schema_type: brd_source_columns).
---

# Skill: Thiết kế HLD (High-Level Design)

Đọc file này TRƯỚC KHI bắt đầu thiết kế HLD cho bất kỳ source system nào.

## Tài nguyên đi kèm

- **Templates** (copy + replace placeholder):
  - [`templates/HLD_Tier.md`](templates/HLD_Tier.md) — skeleton 6a–6f cho 1 Tier.
  - [`templates/HLD_Overview.md`](templates/HLD_Overview.md) — skeleton 7a–7f cho Overview.
- **Reference** (rule chuẩn dùng chung dự án):
  - [`reference/group_classification.md`](reference/group_classification.md) — 13 group chuẩn cho mục 7f + lý do chuẩn.
  - [`reference/file_layout.md`](reference/file_layout.md) — vị trí + encoding tất cả file HLD/LLD.
- **Examples** (so sánh format):
  - [`examples/7f_correct.md`](examples/7f_correct.md) — format mục 7f đúng.
  - [`examples/7f_wrong.md`](examples/7f_wrong.md) — 5 pattern sai cần tránh.

## QUY TRÌNH THIẾT KẾ HLD

### Bước 1 — Thu thập input

1. **Đọc cấu trúc cột từ `BRD/Source/{SOURCE}/`** — mỗi bảng có 1 file `brd_{SOURCE}_{TABLE}.yaml`
   (schema_type: `brd_source_columns`). Đây là nguồn input bắt buộc và duy nhất về cấu trúc CSDL nguồn.
   - Danh sách bảng = tất cả file `.yaml` trong thư mục đó.
   - Scope status (in_scope / out_of_scope) đọc từ `BRD/Source/brd_{SOURCE}.yaml` (file tổng hợp).
   - Cấu trúc cột (tên cột, kiểu dữ liệu, FK) đọc từ file per-table.
2. Xác định danh sách bảng trong scope từ `brd_{SOURCE}.yaml` (cột `scope_status: in_scope`).
   Khi thiết kế lại source đã có HLD trước đó: ưu tiên tái sử dụng phân tích cũ cho các bảng
   giữ nguyên cấu trúc — không bắt buộc phải trùng khớp với danh sách in_scope của BRD.
   Một khi bảng nguồn đã được thiết kế Atomic → cập nhật scope_status thành in_scope.
3. Đọc các file HLD đã có trong `docs/approved/` (nếu có source system liên quan).
4. **Đọc `DataModel/working/Atomic/lld/manifest.yaml`** — lọc theo source system đang thiết kế (cột `source_system`),
   ghi nhận tất cả entity đã có. Tên entity trong manifest là **LOCKED** — dùng đúng tên đó trong HLD,
   không tự sinh tên mới.

### Bước 1b — Xác định Table Type

| table_type | Khi nào dùng | ETL pattern |
|---|---|---|
| `Fundamental` | Entity độc lập, có lifecycle riêng, không FK đến entity nghiệp vụ khác | SCD4A |
| `Relative` | Entity phụ thuộc Fundamental (FK), mô tả trạng thái hoặc thuộc tính bổ sung | SCD2 |
| `Fact Append` | Log hoạt động, giao dịch, sự kiện — mỗi dòng là 1 occurrence không bị xóa/sửa | Insert-only, append, không update |
| `Fact Snapshot` | Chụp trạng thái tại 1 thời điểm/kỳ — giữ lịch sử nhiều kỳ, không overwrite | Insert-only theo partition ngày/kỳ, giữ lịch sử |
| `Classification` | Thông tin danh mục phân loại — có thể lấy từ nguồn hoặc tự định nghĩa. Mặc định cho tất cả entity có `bcv_core_object = Common` | Upsert |

**Phân biệt `Fact Append` vs `Fact Snapshot`:**
- `Fact Append`: grain = 1 event/occurrence (tick khớp lệnh, log hoạt động). Mỗi dòng là 1 sự kiện xảy ra.
- `Fact Snapshot`: grain = 1 trạng thái tại 1 thời điểm/kỳ (bảng giá cuối ngày, danh mục theo kỳ). Mỗi dòng là 1 lần chụp — có thể nhiều dòng cùng key nghiệp vụ qua các kỳ khác nhau.

**Dấu hiệu nhận biết nhanh:**
- Tên entity chứa "Activity Log", "Status Log", "Status History" → `Fact Append`
- bcv_concept chứa "ETL Pattern" → `Fact Append`
- bcv_core_object = Transaction → `Fact Append`
- Tên entity chứa "Snapshot" → `Fact Snapshot`
- bcv_core_object = Common → `Classification` (mặc định; điều chỉnh cá biệt theo quy trình status draft → approved trong atomic_entities.yaml)
- Không thuộc các trường hợp trên, không phụ thuộc Fundamental → `Fundamental`
- Không thuộc các trường hợp trên, có FK đến Fundamental → `Relative`

### Bước 2 — Phân tầng (Tiered Design)

Thiết kế nền móng trước, xây dựng quan hệ sau. Mỗi tầng = 1 file md riêng.

**Phân tầng:**
- **Tầng 1 — Main Entities**: Bảng có ý nghĩa độc lập, không FK đến bảng nghiệp vụ khác (chỉ FK đến bảng danh mục). Thiết kế và thống nhất trước.
- **Tầng 2 — Phụ thuộc Tầng 1**: Bảng có FK đến main entity (Tầng 1).
- **Tầng 3+ — Phụ thuộc tầng trước**: Bảng có FK đến entity Tầng 2 trở lên.
- **Tầng ETL Pattern**: Snapshot / Audit Log — luôn phụ thuộc entity chính.

**Quy tắc đánh số Tier:**
- Đánh số theo **dependency** (Tier 1, Tier 2, Tier 3, ...) — không phân theo nhóm nghiệp vụ, không dùng tên nghiệp vụ làm tên Tier.
- Nếu source system có cách đặt tên Tier sẵn (Tier A/B/C/E từ tài liệu nghiệp vụ) → vẫn phân tích lại dependency và đánh số 1, 2, 3, ... cho từng file HLD.
- Nhiều entity cùng mức dependency → gộp vào cùng 1 Tier.
- **Circular reference trong cùng Tier:** 2 entity FK lẫn nhau → giữ nguyên trong cùng Tier, ghi vào mục 6f "Điểm cần xác nhận". Không tách thêm Tier chỉ để tránh circular.

**Xác định ngoài scope:**
- Bảng **isolated** (không FK đến và không FK từ bất kỳ bảng nghiệp vụ nào trong scope) → ngoài scope Atomic.
- Bảng có FK đến main entity nhưng không có entity nào phụ thuộc → vẫn trong scope (leaf entity).
- Bảng **chưa có cấu trúc trường** (không có thông tin cột) → không thiết kế, ghi nhận vào mục 7f để theo dõi.
- Bảng **Audit Log nguồn** (cột PrevValue/ValueChange hoặc OldValue/NewValue + Action + DateChange): cơ chế ghi lịch sử đặc thù source system → ngoài scope Atomic. Nếu cần dữ liệu lịch sử trên Atomic → thiết kế job parsing riêng để đẩy vào entity Atomic có cột tường minh.

  **Phân biệt Audit Log nguồn vs ETL Pattern — Activity/Status Log trên Atomic:**
  - **Audit Log nguồn** = bảng source system ghi mọi thay đổi field dạng generic (FieldName + OldValue + NewValue) → ngoài scope Atomic.
  - **ETL Pattern — Activity/Status Log** = Atomic entity ghi nhận sự kiện nghiệp vụ có cột tường minh (trạng thái trước/sau, lý do thay đổi, timestamp) → trong scope Atomic, tạo entity riêng.
  - Dấu hiệu Audit Log nguồn: có cặp `OldValue`/`NewValue` (hoặc `PrevValue`/`ValueChange`) kèm cột `FieldName` — 1 dòng mô tả 1 field thay đổi bất kỳ.
- Bảng **Snapshot nguồn** (cột IsBefore + blob data như SecData/TLData): cùng lý do với Audit Log nguồn → ngoài scope Atomic.
- Bảng **File Attachment** (bảng chỉ lưu con trỏ file: tên file, đường dẫn, loại file) — không có attribute nghiệp vụ độc lập ngoài metadata file → ngoài scope Atomic. Thông tin loại tài liệu đã có trên entity chính hoặc entity classification. VD: `APPLICATION_DOCUMENTS` chỉ lưu FILE_NAME + FILE_PATH + DOCUMENT_TYPE_ID → ngoài scope.
- Bảng **Batch Processing Metadata** (bảng chỉ theo dõi danh sách thành viên của một nhóm xử lý tập thể tại nguồn, không phản ánh instance nghiệp vụ độc lập): ngoài scope Atomic.

  **Dấu hiệu nhận biết:**
  - Tên bảng dạng `*_GROUP_MEMBERS`, `*_BATCH_MEMBERS`, `*_LOT_MEMBERS` — chỉ lưu danh sách thành viên của một batch/group đã có entity Atomic.
  - Bảng chỉ có 2 FK: FK đến bảng group + FK đến bảng nghiệp vụ chính. Không có attribute nghiệp vụ riêng (không có trạng thái, ngày tháng, số tiền...).
  - Mục đích = tổ chức xử lý tập thể tại phía ứng dụng nguồn (bulk operation), không phản ánh quan hệ nghiệp vụ dài hạn cần phân tích.

  **Phân biệt với entity nghiệp vụ thực sự — kiểm tra 2 điều kiện:**
  1. Attribute trên bảng group có thể đọc từ entity đã thiết kế không? Nếu có → ngoài scope.
     VD: CERTIFICATE_RECORD_GROUPS có DECISION_ID, nhưng DECISIONS đã là entity Tier 1 — không cần thêm entity group để truy cập thông tin quyết định.
  2. Attribute trên bảng members có thuộc về instance nghiệp vụ chính không? Nếu có → ghi thẳng lên entity chính.
     VD: CERTIFICATE_RECORD_GROUP_MEMBERS có REVOCATION_REASON — thông tin này thuộc về CERTIFICATE_RECORDS, không phải thuộc về quan hệ thành viên.
  - Bảng group chỉ trong scope khi nó đại diện cho một **entity nghiệp vụ độc lập** mà không thể suy ra từ entity đã có (VD: đợt thi EXAM_SESSIONS có ngày thi, địa điểm, quyết định — không thể suy ra từ DECISIONS đơn thuần).

### Bước 3 — Trace dependency cho mỗi bảng

Với mỗi bảng trong tầng đang thiết kế:
1. **Outbound FK**: Bảng này trỏ đến đâu?
2. **Inbound FK**: Bảng nào trỏ đến bảng này?
3. Xác định FK đến bảng nào là bảng nghiệp vụ (→ dependency), bảng nào là danh mục (→ Classification Value).

### Bước 4 — Tra BCV và đề xuất Atomic entity

**BẮT BUỘC tra cứu BCV trước khi gán concept.** Không suy luận từ tên bảng nguồn.

Quy trình tra BCV:
1. Đọc mô tả bảng nguồn → xác định ý nghĩa nghiệp vụ.
2. `grep -i "{keyword}" knowledge/terms.csv` → tìm term phù hợp.
3. `grep "{term_name}" knowledge/term_relationships.csv` → hiểu quan hệ.
4. Xác định Core Object và Category.

**Xác định BCV Concept từ nội dung term, không từ category:** Một BCV term có thể nằm trong category không trùng với Data Concept thực sự của entity. Đọc nội dung mô tả của term để xác định Data Concept — chọn concept chi tiết nhất phù hợp với nội dung. Ví dụ: "Involved Party Rating" (category Group) mô tả quan hệ Rating Scale áp dụng cho Involved Party → BCV Concept = `[Involved Party]`, không phải `[Group]`.

**Kiểm tra concept bằng cấu trúc trường — KHÔNG chỉ dựa vào tên bảng:** Sau khi tìm được BCV term candidate, đọc lại danh sách cột của bảng nguồn và tự hỏi: *"Các trường này mô tả thực thể thuộc loại gì?"* Tên bảng khớp với BCV term không đồng nghĩa concept khớp — cấu trúc trường mới là căn cứ quyết định.

**Phân biệt entity concept vs reference data set:**
- Bảng có instance data (người đảm nhận, ngày bắt đầu, trạng thái lifecycle) → entity concept → Atomic entity.
- Bảng chỉ có Code + Name, không có instance data → reference data set → Classification Value.
- `grep -i "{term}" knowledge/reference_data_sets.csv` — nếu có reference data set tương ứng → Classification Value.
- **Ngoại lệ — Geographic Area**: Bảng lưu danh mục khu vực địa lý (tỉnh, thành phố, quốc gia...) dù chỉ có Code + Name → **Atomic entity [Location] Geographic Area**, không phải Classification Value. Lý do: BCV có Data Concept riêng là Location.
  - **Table Type = Fundamental** (không phải Classification) — entity địa lý có lifecycle riêng, được FK từ nhiều entity nghiệp vụ, là nền tảng toàn dự án.
  - **Pattern gộp nhiều cấp vào 1 entity**: nếu source system có nhiều bảng địa lý (COUNTRIES, PROVINCES, DISTRICTS) → gộp vào 1 Atomic entity `Geographic Area`, phân biệt bằng `Geographic Area Type Code` (ETL-derived: COUNTRY / PROVINCE / DISTRICT). Quan hệ self-referencing: DISTRICT → PROVINCE → COUNTRY → NULL. Không tạo 3 entity riêng biệt.

**Pure junction table giữa entity và Classification Value:** Bảng chỉ có 2 trường nghiệp vụ — 1 trỏ đến entity chính, 1 trỏ đến bảng danh mục — không có attribute nghiệp vụ riêng → **không tạo Atomic entity**. Denormalize thành trường `ARRAY<Classification Value Code>` trên entity chính.

**Pure junction table giữa 2 Atomic entity:** Bảng chỉ có 2 trường nghiệp vụ đều là FK đến Atomic entity — không có attribute nghiệp vụ riêng → **không tạo Atomic entity**. Xác định bên "Many" trong quan hệ → denormalize thành trường `ARRAY<STRUCT>` trên entity bên Many: surrogate key (dùng join) + business code (lưu dư thừa). Ví dụ: `distribution_agents ARRAY<STRUCT<agent_id BIGINT, agent_code STRING>>`.

**Đặt tên Atomic entity:** Pattern `[Domain Prefix] + [BCV Term]`.
- Tất cả entity cùng nhóm nghiệp vụ phải dùng chung prefix.
- Entity con phải chứa đầy đủ tên entity cha (substring liên tục).
- Khi bảng nguồn chứa nhiều loại đơn vị (VD: CN + VPĐD, CN + PGD), dùng BCV Term chung thay vì tên loại cụ thể từ bảng nguồn.
- **Xác định Domain Prefix tường minh:** Ghi rõ giá trị Domain Prefix đã chọn (không chỉ ngầm hiểu
  qua việc lặp từ đầu) — Domain Prefix dùng để sinh `entity_physical_name` (xem
  `atomic-lld-design/SKILL.md` mục "QUY TẮC ĐẶT `physical_name`").
  - Entity không có sibling nào cùng nhóm nghiệp vụ → Domain Prefix = rỗng.
  - Shared entity dùng chung toàn dự án (IP Postal Address, IP Electronic Address, IP Alt
    Identification) → Domain Prefix cố định = `Involved Party`.
  - **Entity Classification (bảng thật, promote từ Classification Value)** → Domain Prefix =
    `Classification` (trần, KHÔNG chèn tên nguồn). VD: `Classification Business Line`,
    `Classification Application Status`, `Classification Firm Status`. Physical name:
    `cl_[term]` (VD: `cl_business_line`).
    Nếu phát sinh trùng bare name giữa 2 source nhưng khác BCV concept → KHÔNG chèn lại tên nguồn để
    né trùng. Xử lý bằng cách: (a) chọn BCV Term chi tiết hơn, phản ánh đúng concept riêng của từng
    bên, hoặc (b) nếu thực chất cùng 1 concept → gộp thành 1 shared entity, bổ sung `source_table` thứ
    2 vào cùng dòng `atomic_entities.yaml` thay vì tạo entity trùng.
  - Ghi giá trị này vào `atomic_entities.yaml` cột `domain_prefix` ở Bước 8.

### Bước 5 — Rà soát shared entity

Với mỗi entity thuộc concept `[Involved Party]`, kiểm tra:
- Có trường địa chỉ? → IP Postal Address
- Có trường liên lạc (phone, email, fax)? → IP Electronic Address
- Có trường giấy tờ định danh (CCCD, giấy phép)? → IP Alt Identification

**Điều kiện grain:**
- Grain = 1 Involved Party (1 dòng = 1 tổ chức/cá nhân) → **bắt buộc tách** ra shared entity.
- Grain không phải Involved Party (1 dòng = 1 báo cáo, 1 hồ sơ, 1 giao dịch) → giữ denormalized, không tách.

### Bước 6 — Xuất file HLD Tier

**Tên file:** `DataModel/working/Atomic/hld/{SOURCE_SYSTEM}_HLD_Tier{N}.md`

Copy [`templates/HLD_Tier.md`](templates/HLD_Tier.md) làm starting point. Replace placeholder, điền nội dung 6 mục:

| Mục | Nội dung |
|---|---|
| 6a | Bảng tổng quan BCV Concept — chỉ liệt kê entity mới của tầng đang thiết kế |
| 6b | Diagram Source (Mermaid) — quan hệ FK giữa các bảng nguồn trong scope, không vẽ Classification Value |
| 6c | Diagram Atomic (Mermaid) — entity từ tầng trước hiện dạng node tham chiếu (chỉ tên), không vẽ Classification Value |
| 6d | Mục Danh mục & Tham chiếu (Reference Data) |
| 6e | Bảng chờ thiết kế |
| 6f | Điểm cần xác nhận |

**Cấu trúc bảng mục 6a — 9 cột bắt buộc:**

| BCV Core Object | BCV Concept | Category | Source Table | Source Table Change Mode | Mô tả bảng nguồn | Atomic Entity | Table Type | BCV Term |

- **Source Table Change Mode**: lấy từ `BRD/Source/brd_{SOURCE}.yaml` → `content.ingestion.data_change_mode`. Giá trị: `Update` / `Append` / `N/A` (chưa định nghĩa).
- **Table Type**: table_type Atomic đã xác định ở Bước 1b.

**Mục đích cột Source Table Change Mode:** Hỗ trợ human review cross-check cơ chế cập nhật nguồn ↔ ETL pattern Atomic:

| Source Change Mode | Table Type Atomic | Nhận xét |
|---|---|---|
| `Append` | `Fact Append` | Phù hợp — nguồn chỉ thêm, Atomic insert-only. |
| `Update` | `Fundamental` / `Relative` | Bình thường — SCD4A/SCD2 xử lý update. |
| `Update` | `Fact Append` | Cần review — nguồn có update nhưng Atomic insert-only. ETL có drop & reload không? |
| `Append` | `Fundamental` | Cần review — nguồn không update nhưng Atomic dùng SCD4A. Business rule là gì? |

**Quy tắc cột "BCV Term" (mục 6a):** Viết đủ 3 phần:
1. Term candidate tìm được + BCV mô tả gì.
2. Đánh giá cấu trúc trường bảng nguồn nói gì.
3. Lý do chọn term cuối.

Nếu term candidate không khớp với cấu trúc trường → nêu rõ tại sao không dùng và chọn term nào thay thế.

**Quy tắc mục 6d — Reference Data:**
- Cột `Scheme Code` **không được để trống** — đặt tên scheme ngay tại bước HLD. Dùng `UPPER_SNAKE_CASE` + prefix source system (VD: `FMS_BUSINESS_TYPE`, `NHNCK_APPLICATION_STATUS`).
- `source_type`: `source_table` (values load từ bảng nguồn) / `etl_derived` (team tự định nghĩa) / `modeler_defined` (chưa profile).
- **Sau khi xác định Scheme Code → đăng ký ngay vào `DataModel/working/Atomic/lld/classification_schemes.yaml`**, kể cả khi chưa có giá trị cụ thể (để `values: []` hoặc liệt kê sơ bộ).

**Quy tắc mục 6f — Điểm cần xác nhận:**
- Ghi rõ vấn đề cần review: entity chưa chắc chắn, scope mờ, dependency chéo tầng.
- Ghi dạng fact, không so sánh version.

**Tier file KHÔNG chứa section Entities.** Grain, attributes chính, và phân tích BCV Term nằm trong mục 6a BCV Term column — đó là tài liệu phân tích thiết kế.

## Bước 7 — Tạo file HLD Overview

Thực hiện **sau khi hoàn thành thiết kế Tier cuối cùng**. Quản lý lịch sử thay đổi qua Git — chỉ cần 1 file duy nhất.

**Tên file:** `DataModel/working/Atomic/hld/{SOURCE_SYSTEM}_HLD_Overview.md`

Copy [`templates/HLD_Overview.md`](templates/HLD_Overview.md) làm starting point.

### FORMAT BẮT BUỘC

Format dưới đây là contract giữa HLD Overview và các script aggregate (`aggregate_out_of_scope.py`, `aggregate_atomic.py`) — script parse bằng regex trên heading và cấu trúc bảng Markdown.

**Heading bắt buộc** (chính xác từng ký tự, đúng cấp `####`, đúng tiền tố `7a.`...`7f.`):

| Section | Heading | Cấu trúc |
|---|---|---|
| 7a | `#### 7a. Bảng tổng quan Atomic entities` | 10 cột: `Tier \| BCV Core Object \| BCV Concept \| Category \| Source Table \| Source Table Change Mode \| Mô tả bảng nguồn \| Atomic Entity \| Table Type \| BCV Term` |
| 7b | `#### 7b. Diagram Atomic tổng (Mermaid)` | 1 mermaid diagram |
| 7c | `#### 7c. Bảng Classification Value` | 4 cột: `Source Table \| Mô tả \| BCV Term \| Xử lý Atomic` |
| 7d | `#### 7d. Junction Tables` | 4 cột: `Source Table \| Mô tả \| Entity chính \| Xử lý trên Atomic` |
| 7e | `#### 7e. Điểm cần xác nhận` | 4 cột: `# \| Tier \| Câu hỏi \| Ảnh hưởng` |
| 7f | `#### 7f. Bảng ngoài scope` | 4 cột: `Nhóm \| Source Table \| Mô tả bảng nguồn \| Lý do ngoài scope` |
| Entities | `## Entities` | 1 section per entity: `### N.` + `**Description:**` |

**Grain:** Mỗi dòng bảng = 1 record. Mục 7f bắt buộc grain `(source_system, source_table)` — không gộp nhiều bảng vào 1 ô.

### Section Entities — source of truth cho `atomic_entities.yaml`

Đặt **sau mục 7f**, cuối file Overview. `aggregate_atomic.py` parse section này để lấy `description`.

Format bắt buộc cho mỗi entity:

```markdown
### N. {Atomic Entity Name}
**Tier:** {1/2/3/...} | **Source:** `{SOURCE_TABLE}` | **BCV Concept:** {[Concept] Term} | **BCO:** {Core Object} | **Table Type:** {Fundamental/...}
**Domain Prefix:** {giá trị Domain Prefix đã chọn, hoặc "(none)" nếu entity không có sibling}
**Description:** {1–2 câu tiếng Việt — BCV Term + ý nghĩa nghiệp vụ bảng nguồn}
```

- `**Description:**` phải nằm trong **500 ký tự đầu tiên** sau heading `### N.` — script dừng tìm sau đó.
- Viết tiếng Việt **có dấu đầy đủ** (Unicode UTF-8). Không viết tắt, không viết không dấu.
- Thứ tự entities trong section = thứ tự Tier (T1 trước, T4 sau), trong cùng Tier = alphabetical.
- Khi có thay đổi entity (tên, description, table_type) → cập nhật section này, rồi chạy `aggregate_atomic.py`.

### Mục 7f — Bảng ngoài scope

- **Format đúng:** xem [`examples/7f_correct.md`](examples/7f_correct.md).
- **Pattern sai cần tránh:** xem [`examples/7f_wrong.md`](examples/7f_wrong.md).
- **Cột "Nhóm":** dùng group từ [`reference/group_classification.md`](reference/group_classification.md). Nếu phát sinh group mới → bổ sung vào file reference đó trước khi dùng.
- **Cột "Mô tả bảng nguồn":** mô tả ngắn gọn nội dung bảng (1 câu), KHÔNG nhắc lại lý do.
- **Cột "Lý do ngoài scope":** mô tả lý do quan hệ/cấu trúc, KHÔNG mô tả nội dung. Lý do chuẩn xem [`reference/group_classification.md`](reference/group_classification.md).

**Cập nhật:** Khi có thay đổi ở bất kỳ Tier nào → cập nhật mục 7f trong Overview, chạy lại `aggregate_out_of_scope.py --source {SOURCE}`.

## Bước 8 — Cập nhật atomic_entities.yaml và atomic_out_of_scope.yaml

Hai file này là bảng tổng hợp toàn dự án. Encoding + workflow xem [`reference/file_layout.md`](reference/file_layout.md).

**Source-of-truth:** HLD Overview — mục 7f cho `atomic_out_of_scope.yaml`, section Entities cho `atomic_entities.yaml`. Hai file aggregate luôn được sinh bằng script.

### atomic_entities.yaml

**Cấu trúc:**
```
bcv_core_object,bcv_concept,atomic_entity,table_type,domain_prefix,entity_physical_name,status,description,source_table
```

**Quy tắc cột:**
- `bcv_core_object`: 1 trong 15 BCV Core Object (Involved Party, Location, Condition, Arrangement, Product, Transaction, Communication, Event, Business Activity, Documentation, Property, Business Direction, Common, Group, Accounting). Business Activity là Core Object độc lập, không phải sub-type của Event.
- `bcv_concept`: BCV Concept đã gán (ví dụ: `[Involved Party] Portfolio Fund Management Company`).
- `atomic_entity`: Tên Atomic entity đầy đủ (ví dụ: `Fund Management Company`).
- `domain_prefix`: Phần đầu tên entity dùng chung cho cả nhóm nghiệp vụ (xem Bước 4). Rỗng nếu entity không có sibling nào.
- `entity_physical_name`: Tính theo quy tắc A tại `atomic-lld-design/SKILL.md` mục "QUY TẮC ĐẶT `physical_name`" — `abbreviate_domain_prefix(domain_prefix) + "_" + full_words(BCV Term)` (chỉ viết tắt cụm từ có trong curated list `system/rules/rule_domain_prefix_abbreviations.csv`, không lấy initials mù quáng).
- `description`: Tiếng Việt **CÓ DẤU đầy đủ** (Unicode UTF-8), súc tích, kết hợp BCV Term + ý nghĩa nghiệp vụ bảng nguồn. Không viết Việt-không-dấu, không viết tắt. Hiển thị trực tiếp trong tài liệu Word handover (`atomic-gen-docs`).
- `source_table`: Bảng nguồn dạng `SOURCE_SYSTEM.TABLE`. Nhiều bảng → phân cách bằng dấu phẩy.

**Quy tắc cập nhật:** Thêm dòng entity mới qua `aggregate_atomic.py`. Shared entity từ source khác → bổ sung source_table vào dòng hiện có, không tạo dòng trùng. Sort: `bcv_core_object` (A→Z) → `atomic_entity` (A→Z).

**Approved lock:**

| Cột | status=draft | status=approved |
|---|---|---|
| `atomic_entity` | Có thể sửa | **LOCKED** — không được đổi tên |
| `table_type` | Có thể sửa | **LOCKED** |
| `bcv_core_object` | Có thể sửa | **LOCKED** |
| `bcv_concept` | Có thể sửa | **LOCKED** |
| `domain_prefix` | Có thể sửa | **LOCKED** — đổi kéo theo phải rename `entity_physical_name` và toàn bộ downstream |
| `entity_physical_name` | Có thể sửa | **LOCKED** |
| `description` | Có thể sửa | Có thể bổ sung / làm giàu thêm |
| `source_table` | Có thể sửa | Có thể bổ sung source mới |

Cần thay đổi cột LOCKED → đổi `status → draft` trước, sửa, rồi quyết định approve lại.

### atomic_out_of_scope.yaml

**Cấu trúc cột:** `source_system,source_table,description,group,reason`.

**Workflow sau mỗi lần update HLD Overview:**

1. Sửa nội dung mục 7f trong `{SOURCE}_HLD_Overview.md` theo format trên.
2. Chạy aggregate (chỉ source vừa sửa):
   ```bash
   python Atomic/lld/scripts/aggregate_out_of_scope.py --source {SOURCE}
   ```
3. Verify số dòng source trong output yaml = số dòng mục 7f của HLD Overview:
   ```bash
   grep "source_system: \"{SOURCE}\"" DataModel/working/Atomic/hld/atomic_out_of_scope.yaml | wc -l
   ```
   Nếu lệch → check lại format mục 7f theo Bước 7.

## Verify HLD Overview trước khi commit

- [ ] **6 heading section đúng chính xác:** `#### 7a.` … `#### 7f.` (không thiếu, không sai cấp).
- [ ] **Mục 7f bảng đúng 4 cột:** `Nhóm | Source Table | Mô tả bảng nguồn | Lý do ngoài scope`.
- [ ] **Mục 7f grain đúng:** mỗi dòng đúng 1 bảng nguồn, không gộp `table1, table2`.
- [ ] **Group dùng đúng danh sách chuẩn** (xem `reference/group_classification.md`). Nếu phát sinh group mới → bổ sung vào reference đó trước.
- [ ] **Chạy aggregate verify:** `python Atomic/lld/scripts/aggregate_out_of_scope.py --source {SOURCE}` không có WARN, output có đủ số dòng.
- [ ] **Chạy aggregate atomic entities:** `python Atomic/lld/scripts/aggregate_atomic.py` thành công, không có entity lock vi phạm.
- [ ] **Cross-check số liệu:** số entity Atomic trong mục 7a Overview = số entity trong tất cả mục 6a các Tier.
- [ ] **Source Table Change Mode đã điền:** tất cả dòng mục 7a và 6a có giá trị `Update` / `Append` / `N/A` — không để trống. Lấy từ `BRD/Source/brd_{SOURCE}.yaml → content.ingestion.data_change_mode`.
- [ ] **Cross-check Change Mode ↔ Table Type:** dòng nào có `(Update, Fact Append)` hoặc `(Append, Fundamental/Relative)` → ghi vào mục 7e "Điểm cần xác nhận" với câu hỏi về ETL pattern.

## QUY TẮC REFERENCE GIỮA CÁC TẦNG

- Diagram Atomic ở tầng N: entity tầng trước = node tham chiếu (chỉ tên).
- Bảng BCV Concept ở tầng N: chỉ entity mới.
- Phát hiện cần điều chỉnh tầng trước → ghi "Điểm cần xác nhận", không tự sửa.
