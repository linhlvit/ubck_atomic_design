# Skill: Thiết kế HLD (High-Level Design)

Đọc file này TRƯỚC KHI bắt đầu thiết kế HLD cho bất kỳ source system nào.

## QUY TRÌNH THIẾT KẾ HLD

### Bước 1 — Thu thập input

1. Đọc file cấu trúc CSDL nguồn trong `Source/` — file `*_Tables` và `*_Columns`.
2. Xác định danh sách bảng nguồn trong scope.
3. Đọc các file HLD đã có trong `docs/approved/` (nếu có source system liên quan).
4. **Đọc `Silver/hld/silver_entities.csv`** — lọc theo source system đang thiết kế (cột `source_table`), ghi nhận tất cả dòng có `status=approved`. Đây là **tên đã confirmed và LOCKED** — không được đặt lại tên khác cho entity đó. Nếu entity đã có `status=approved` trong `silver_entities.csv` → dùng đúng tên đó trong HLD, không tự sinh tên mới. Dòng `status=draft` → đang thiết kế, có thể điều chỉnh tên khi cần.

### Bước 1b — Xác định Table Type

Mỗi Silver entity phải có `table_type` trong bảng 6a. Dùng bảng sau để phân loại:

| table_type | Khi nào dùng | ETL pattern |
|---|---|---|
| `Fundamental` | Entity độc lập, Tier 1, có lifecycle riêng, không FK đến entity nghiệp vụ khác | SCD2, upsert theo surrogate key |
| `Relative` | Entity phụ thuộc Fundamental (FK), mô tả trạng thái hoặc thuộc tính bổ sung | SCD1 hoặc SCD2 tùy case |
| `Fact Append` | Log hoạt động, giao dịch, sự kiện — mỗi dòng là 1 occurrence không bị xóa/sửa | Insert-only, append, không update |
| `Snapshot` | Chụp toàn bộ trạng thái tại 1 thời điểm — load định kỳ (hàng ngày / hàng kỳ) | Full replace theo partition ngày |

**Dấu hiệu nhận biết nhanh:**
- Tên entity chứa "Activity Log", "Status Log", "Status History" → `Fact Append`
- bcv_concept chứa "ETL Pattern" → `Fact Append`
- bcv_core_object = Transaction → `Fact Append`
- Tên entity chứa "Snapshot" → `Snapshot`
- Tier 1, không phải log/snapshot → `Fundamental`
- Tier 2+ không phải log/snapshot → `Relative`

### Bước 2 — Phân tầng (Tiered Design)

Thiết kế nền móng trước, xây dựng quan hệ sau. Mỗi tầng = 1 file md riêng.

**Phân tầng:**
- **Tầng 1 — Main Entities**: Bảng có ý nghĩa độc lập, không FK đến bảng nghiệp vụ khác (chỉ FK đến bảng danh mục). Thiết kế và thống nhất trước.
- **Tầng 2 — Phụ thuộc Tầng 1**: Bảng có FK đến main entity (Tầng 1).
- **Tầng 3+ — Phụ thuộc tầng trước**: Bảng có FK đến entity Tầng 2 trở lên.
- **Tầng ETL Pattern**: Snapshot / Audit Log — luôn phụ thuộc entity chính.

**Quy tắc đánh số Tier:**
- Luôn đánh số theo **dependency** (Tier 1, Tier 2, Tier 3, ...) — không phân theo nhóm nghiệp vụ, không dùng tên nghiệp vụ làm tên Tier.
- Nếu source system đã có cách đặt tên Tier sẵn (ví dụ: Tier A/B/C/E từ tài liệu nghiệp vụ) → vẫn **phải phân tích lại dependency** và đánh số thứ tự 1, 2, 3, ... cho từng file HLD. Tên nghiệp vụ chỉ là gợi ý, không phải căn cứ để bỏ qua bước phân tích.
- Nhiều entity có cùng mức dependency → gộp vào cùng 1 Tier.
- **Circular reference trong cùng Tier:** Khi 2 entity trong cùng Tier có FK lẫn nhau (VD: Application.InfoVerifyId → VerifyApplicationStatus, và VerifyApplicationStatus.ApplicationId → Application) → giữ nguyên trong cùng Tier, ghi vào mục 6f "Điểm cần xác nhận" để người thiết kế quyết định xử lý. Không tách thêm Tier chỉ để tránh circular.

**Xác định ngoài scope:**
- Bảng **thực sự isolated** (không FK đến và không FK từ bất kỳ bảng nghiệp vụ nào trong scope) → ngoài scope Silver.
- Bảng có FK đến main entity nhưng không có entity nào phụ thuộc → vẫn trong scope (leaf entity).
- Bảng **chưa có cấu trúc trường** (không có thông tin cột) → **không thiết kế**, ghi nhận vào file đầu ra để theo dõi.
- Bảng **Audit Log nguồn** (nhận biết qua cột PrevValue/ValueChange hoặc OldValue/NewValue + Action + DateChange): đây là cơ chế ghi lịch sử đặc thù của source system → **ngoài scope Silver**. Nếu cần dữ liệu lịch sử trên Silver thì thiết kế job parsing riêng để đẩy vào entity Silver có cột tường minh.

  **Phân biệt Audit Log nguồn vs ETL Pattern — Activity/Status Log trên Silver:**
  - **Audit Log nguồn** = bảng source system ghi mọi thay đổi field dạng generic (FieldName + OldValue + NewValue) → **ngoài scope Silver**.
  - **ETL Pattern — Activity/Status Log** = Silver entity ghi nhận sự kiện nghiệp vụ có cột tường minh (VD: trạng thái trước/sau, lý do thay đổi, timestamp) → **trong scope Silver**, tạo entity riêng.
  - Dấu hiệu nhận biết Audit Log nguồn: có cặp `OldValue`/`NewValue` (hoặc `PrevValue`/`ValueChange`) kèm cột `FieldName` — tức là 1 dòng mô tả 1 field thay đổi bất kỳ, không phải 1 sự kiện nghiệp vụ cụ thể.
- Bảng **Snapshot nguồn** (nhận biết qua cột IsBefore + blob data như SecData/TLData): cùng lý do với Audit Log nguồn → **ngoài scope Silver**.

### Bước 3 — Trace dependency cho mỗi bảng

Với mỗi bảng trong tầng đang thiết kế:
1. **Outbound FK**: Bảng này trỏ đến đâu?
2. **Inbound FK**: Bảng nào trỏ đến bảng này?
3. Xác định FK đến bảng nào là bảng nghiệp vụ (→ dependency), bảng nào là danh mục (→ Classification Value).

### Bước 4 — Tra BCV và đề xuất Silver entity

**BẮT BUỘC tra cứu BCV trước khi gán concept.** Không suy luận từ tên bảng nguồn.

Quy trình tra BCV:
1. Đọc mô tả bảng nguồn → xác định ý nghĩa nghiệp vụ.
2. Dùng `grep -i "<keyword>" knowledge/terms.csv` để tìm term phù hợp.
3. Kiểm tra `grep "<term_name>" knowledge/term_relationships.csv` để hiểu quan hệ.
4. Xác định Core Object và Category.

**Xác định BCV Concept từ nội dung term, không từ category:**
Một BCV term có thể nằm trong category không trùng với Data Concept thực sự của entity (ví dụ: term mô tả quan hệ Involved Party nhưng xếp vào category Group). Khi đó, đọc nội dung mô tả của term để xác định Data Concept — chọn concept chi tiết nhất phù hợp với nội dung. Ví dụ: "Involved Party Rating" (category Group) mô tả quan hệ Rating Scale áp dụng cho Involved Party → BCV Concept = **[Involved Party]**, không phải [Group].

**Kiểm tra concept bằng cấu trúc trường — KHÔNG chỉ dựa vào tên bảng:**

Sau khi tìm được BCV term candidate, đọc lại danh sách cột của bảng nguồn và tự hỏi: *"Các trường này mô tả thực thể thuộc loại gì?"* Tên bảng khớp với BCV term không đồng nghĩa concept khớp — cấu trúc trường mới là căn cứ quyết định.

**Phân biệt entity concept vs reference data set:**
- Bảng có instance data (người đảm nhận, ngày bắt đầu, trạng thái lifecycle) → entity concept → Silver entity.
- Bảng chỉ có Code + Name, không có instance data → reference data set → Classification Value.
- Kiểm tra: `grep -i "<term>" knowledge/reference_data_sets.csv` — nếu có reference data set tương ứng → Classification Value.
- **Ngoại lệ — Geographic Area**: Bảng lưu danh mục khu vực địa lý (tỉnh, thành phố, quốc gia...) dù chỉ có Code + Name → **Silver entity [Location] Geographic Area**, không phải Classification Value. Lý do: BCV có Data Concept riêng là **Location**, Geographic Area là thực thể có thể là FK nghiệp vụ từ nhiều entity khác (địa chỉ, đơn vị hành chính).

**Pure junction table giữa entity và Classification Value:**
Bảng chỉ có 2 trường nghiệp vụ — 1 trỏ đến entity chính, 1 trỏ đến bảng danh mục (các trường kỹ thuật như CreatedBy, DateCreated bỏ qua khi đánh giá) — không có attribute nghiệp vụ riêng → **không tạo Silver entity**. Denormalize thành trường `ARRAY<Classification Value Code>` trên entity chính. Data domain = **Classification Value**, data type = `Array`.

**Pure junction table giữa 2 Silver entity:**
Bảng chỉ có 2 trường nghiệp vụ đều là FK đến Silver entity (các trường kỹ thuật bỏ qua khi đánh giá) — không có attribute nghiệp vụ riêng → **không tạo Silver entity**. Xác định bên "Many" trong quan hệ → denormalize thành trường `ARRAY<STRUCT>` trên entity bên Many, mỗi phần tử gồm **2 thành phần**: surrogate key (dùng join) + business code (lưu dư thừa, dễ khai thác). Ví dụ: `distribution_agents ARRAY<STRUCT<agent_id BIGINT, agent_code STRING>>`.

**Đặt tên Silver entity:** Pattern [Domain Prefix] + [BCV Term].
- Tất cả entity cùng nhóm nghiệp vụ phải dùng chung prefix.
- Entity con phải chứa đầy đủ tên entity cha (substring liên tục).
- Khi bảng nguồn chứa nhiều loại đơn vị (VD: CN + VPĐD, CN + PGD), dùng BCV Term chung thay vì tên loại cụ thể từ bảng nguồn. Ví dụ: bảng chứa cả CN lẫn VPĐD → đặt hậu tố "Organization Unit", không đặt "Branch".

### Bước 5 — Rà soát shared entity

Với mỗi entity thuộc concept [Involved Party], kiểm tra:
- Có trường địa chỉ? → IP Postal Address
- Có trường liên lạc (phone, email, fax)? → IP Electronic Address
- Có trường giấy tờ định danh (CCCD, giấy phép)? → IP Alt Identification

**Điều kiện grain:**
- Grain = 1 Involved Party (1 dòng = 1 tổ chức/cá nhân) → **bắt buộc tách** ra shared entity.
- Grain không phải Involved Party (1 dòng = 1 báo cáo, 1 hồ sơ, 1 giao dịch) → **giữ denormalized**, không tách.

### Bước 6 — Xuất file HLD

**Tên file:** `<SOURCE_SYSTEM>_HLD_Tier<N>.md`

**Nội dung bắt buộc:**

#### 6a. Bảng tổng quan BCV Concept

Cấu trúc tối thiểu:

| BCV Core Object | BCV Concept | Category | Source Table | Mô tả bảng nguồn | Silver Entity | BCV Term |
|---|---|---|---|---|---|---|

- Cột "BCV Core Object": 1 trong 15 Core Object của BCV (Involved Party, Location, Condition, Arrangement, Product, Transaction, Communication, Event, Business Activity, Documentation, Property, Business Direction, Common, Group, Accounting).
- Cột "Mô tả bảng nguồn" lấy từ tài liệu thiết kế CSDL nguồn — không tự viết lại.
- Chỉ liệt kê entity mới của tầng đang thiết kế, không lặp entity tầng trước.
- Classification Value không xuất hiện ở đây — ghi riêng trong mục Danh mục & Tham chiếu.
- Cột "BCV Term" viết đủ 3 phần: (1) term candidate tìm được và BCV mô tả gì, (2) đánh giá cấu trúc trường bảng nguồn nói gì, (3) lý do chọn term cuối. Nếu term candidate không khớp với cấu trúc trường → nêu rõ tại sao không dùng và chọn term nào thay thế.

#### 6b. Diagram Source (Mermaid)

Thể hiện quan hệ FK giữa các bảng nguồn trong scope. Không mô tả bảng Classification Value.

#### 6c. Diagram Silver (Mermaid)

Thể hiện Silver entities và quan hệ. Entity từ tầng trước xuất hiện dạng **node tham chiếu** (chỉ ghi tên, không mô tả lại). Không mô tả bảng Classification Value.

#### 6d. Mục Danh mục & Tham chiếu (Reference Data)

Liệt kê các bảng nguồn được propose thiết kế vào Classification Value, kèm Scheme Code dự kiến.

**Quy tắc bắt buộc:**
- Cột Scheme Code **không được để trống (`—`)** — phải đặt tên scheme ngay tại bước HLD. Dùng UPPER_SNAKE_CASE, thêm prefix source system để tránh trùng (VD: `FMS_BUSINESS_TYPE`, `NHNCK_APPLICATION_STATUS`).
- Nếu values load từ bảng nguồn → `source_type = source_table`. Nếu team tự định nghĩa → `source_type = etl_derived`. Nếu chưa profile data → `source_type = modeler_defined`.
- **Sau khi xác định Scheme Code → bắt buộc đăng ký ngay vào `Silver/lld/ref_shared_entity_classifications.csv`**, kể cả khi chưa có danh sách giá trị cụ thể (ghi `(source)` hoặc `(to_define)` ở cột code). Không để scheme chỉ tồn tại trong file HLD mà thiếu trong file chuẩn hóa.
- **Encoding khi ghi file `ref_shared_entity_classifications.csv`: bắt buộc dùng UTF-8 with BOM** (`utf-8-sig` trong Python). Excel và các tool Windows cần BOM để nhận diện đúng tiếng Việt — nếu ghi UTF-8 thuần sẽ bị lỗi encoding khi mở.

#### 6e. Bảng chờ thiết kế

Liệt kê các bảng trong scope nghiệp vụ nhưng chưa có cấu trúc trường — chưa thể thiết kế Silver entity. Cấu trúc tối thiểu:

| Source Table | Mô tả bảng nguồn | Lý do chưa thiết kế |
|---|---|---|
| ... | ... | Chưa có thông tin cột |

#### 6f. Điểm cần xác nhận

Ghi rõ các vấn đề cần review: entity chưa chắc chắn, scope mờ, dependency chéo tầng...

**Quy tắc trình bày:**
- Không so sánh version (không ghi "so với v1", "thay đổi so với v1").
- Nếu cần ghi chú → ghi dạng fact, không đặt trong ngữ cảnh so sánh.

## Bước 7 — Tạo file HLD Overview

Thực hiện **sau khi hoàn thành thiết kế Tier cuối cùng**. Quản lý lịch sử thay đổi qua Git — chỉ cần 1 file duy nhất.

**Tên file:** `<SOURCE_SYSTEM>_HLD_Overview.md`

**Nội dung bắt buộc:**

#### 7a. Bảng tổng quan Silver entities

Gộp 6a của tất cả Tier, thêm cột Tier. Giữ nguyên cấu trúc cột như file Tier, chỉ thêm cột Tier ở đầu:

| Tier | BCV Core Object | BCV Concept | Category | Source Table | Mô tả bảng nguồn | Silver Entity | BCV Term |
|---|---|---|---|---|---|---|---|

#### 7b. Diagram Silver tổng (Mermaid)

1 diagram duy nhất thể hiện toàn bộ Silver entities và quan hệ giữa chúng — không phân tầng, nhìn như 1 data model hoàn chỉnh. Dùng cùng ký hiệu màu với các file Tier.

#### 7c. Bảng Classification Value

Gộp tất cả bảng danh mục thuần túy từ các Tier. Giữ nguyên cấu trúc cột như file Tier:

| Source Table | Mô tả | BCV Term | Xử lý Silver |
|---|---|---|---|

#### 7d. Junction Tables

Gộp tất cả junction table từ các Tier và cách denormalize. Cấu trúc tối thiểu:

| Source Table | Mô tả | Entity chính | Xử lý trên Silver |
|---|---|---|---|

#### 7e. Điểm cần xác nhận

Gộp tất cả điểm cần xác nhận còn mở từ các Tier. Thêm cột Tier để dễ trace:

| # | Tier | Câu hỏi | Ảnh hưởng |
|---|---|---|---|

#### 7f. Bảng ngoài scope

Gộp tất cả bảng ngoài scope từ các Tier thành 1 bảng duy nhất. Thêm cột Nhóm để phân loại thay vì dùng sub-heading:

| Nhóm | Source Table | Mô tả bảng nguồn | Lý do ngoài scope |
|---|---|---|---|

**Quy tắc viết cột "Lý do ngoài scope":**
- Mô tả **lý do quan hệ / cấu trúc** — tại sao bảng này không thuộc Silver về mặt thiết kế data model.
- **Không** mô tả nội dung bảng (ví dụ: "Chỉ có Code + Name" không phải lý do ngoài scope — đó là mô tả dữ liệu).
- Các lý do chuẩn:

| Tình huống | Lý do viết |
|---|---|
| Không FK đến/từ bất kỳ bảng nghiệp vụ nào | `Không có quan hệ FK đến bảng nghiệp vụ nào trong scope` |
| Bảng danh mục thuần túy (Code + Name) | `Không có FK inbound từ bảng nghiệp vụ — xử lý thành Classification Value` |
| Dữ liệu thu thập tại source gốc khác | `Dữ liệu gốc tại [SOURCE] — thu thập tại source gốc, không qua DCST` |
| Hạ tầng IT / phân quyền / config | `Operational/system data — không có giá trị nghiệp vụ` |
| Audit Log nguồn (OldValue/NewValue) | `Audit Log nguồn — cơ chế ghi lịch sử đặc thù source system, không phải sự kiện nghiệp vụ` |
| Snapshot nguồn (IsBefore + blob) | `Snapshot nguồn — không phải entity nghiệp vụ Silver` |

**Cập nhật:** Khi có thay đổi ở bất kỳ Tier nào → cập nhật cả file Tier lẫn file Overview.

## Bước 8 — Cập nhật silver_entities.csv và silver_out_of_scope.csv

Thực hiện **sau khi hoàn thành HLD mỗi Tier**. Hai file này là bảng tổng hợp toàn dự án — tích lũy qua tất cả source system và tất cả Tier.

**Encoding bắt buộc:** Cả `silver_entities.csv` và `silver_out_of_scope.csv` đều phải ghi **UTF-8 with BOM** (`utf-8-sig` trong Python). Script `aggregate_silver.py` và `aggregate_out_of_scope.py` đã xử lý đúng — không ghi tay bằng `utf-8` thuần.

**Vị trí file:** `Silver/hld/silver_entities.csv`

**Cấu trúc:**
```
bcv_core_object,bcv_concept,silver_entity,table_type,status,description,source_table
```

**Quy tắc từng cột:**
- `bcv_core_object`: 1 trong 15 BCV Core Object (Involved Party, Location, Condition, Arrangement, Product, Transaction, Communication, Event, Business Activity, Documentation, Property, Business Direction, Common, Group, Accounting). Lưu ý: Business Activity là Core Object độc lập, không phải sub-type của Event.
- `bcv_concept`: BCV Concept đã gán cho Silver entity (ví dụ: `[Involved Party] Portfolio Fund Management Company`).
- `silver_entity`: Tên Silver entity đầy đủ (ví dụ: `Fund Management Company`).
- `description`: Mô tả ý nghĩa Silver entity — kết hợp nội dung BCV Term và ý nghĩa nghiệp vụ bảng nguồn. Viết bằng tiếng Việt, súc tích, đủ để người đọc hiểu entity dùng để lưu gì.
- `source_table`: Bảng nguồn map vào entity này, dạng `SOURCE_SYSTEM.TABLE`. Nếu nhiều bảng → phân cách bằng dấu phẩy (ví dụ: `FMS.SECURITIES, FMS.FORBRCH`). Shared entity có thể có nhiều source table từ nhiều entity cha.

**Quy tắc cập nhật:**
- Đọc toàn bộ file hiện tại trước khi ghi.
- Thêm dòng mới cho entity mới trong Tier vừa thiết kế.
- Nếu entity đã có (shared entity từ source khác) → **bổ sung** source_table mới vào dòng hiện có, không tạo dòng trùng.
- **Sắp xếp** toàn bộ nội dung theo thứ tự: `bcv_core_object` (A→Z), sau đó `silver_entity` (A→Z).
- Xuất 1 file duy nhất chứa toàn bộ cũ + mới.

**Approved lock — bắt buộc tuân thủ khi re-design source đã có:**

| Cột | status=draft | status=approved |
|---|---|---|
| `silver_entity` | Có thể sửa | **LOCKED** — không được đổi tên |
| `table_type` | Có thể sửa | **LOCKED** — không được thay đổi |
| `bcv_core_object` | Có thể sửa | **LOCKED** — không được thay đổi |
| `bcv_concept` | Có thể sửa | **LOCKED** — không được thay đổi |
| `description` | Có thể sửa | Có thể bổ sung / làm giàu thêm |
| `source_table` | Có thể sửa | Có thể bổ sung source mới |

Nếu cần thay đổi cột LOCKED của entity approved → đổi `status → draft` trước, sửa, rồi quyết định có approve lại không.

### silver_out_of_scope.csv

**Vị trí file:** `Silver/hld/silver_out_of_scope.csv`

**Cấu trúc:** `source_system, source_table, description, group, reason`

**Nguồn dữ liệu:** Mục 7f trong tất cả `*_HLD_Overview.md` — script đọc bảng Markdown và tổng hợp.

**Sinh file sau mỗi lần hoàn thành HLD Overview:**

```bash
python Silver/lld/scripts/aggregate_out_of_scope.py
```

Hoặc chỉ rebuild 1 source:

```bash
python Silver/lld/scripts/aggregate_out_of_scope.py --source FMS
```

**Lưu ý:** File này do script sinh ra từ HLD — không sửa trực tiếp. Muốn thay đổi nội dung → sửa mục 7f trong `*_HLD_Overview.md` rồi chạy lại script.

## QUY TẮC REFERENCE GIỮA CÁC TẦNG

- Diagram Silver ở tầng N: entity tầng trước = node tham chiếu (chỉ tên).
- Bảng BCV Concept ở tầng N: chỉ entity mới.
- Phát hiện cần điều chỉnh tầng trước → ghi "Điểm cần xác nhận", không tự sửa.
