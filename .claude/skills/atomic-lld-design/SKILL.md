---
name: atomic-lld-design
description: |
  Thiết kế Low-Level Design (LLD) cho từng bảng nguồn trong Atomic source system.
  Sử dụng khi: thiết kế attribute-level cho 1 bảng/Tier, map source columns sang
  Atomic attributes, tách shared entity (IP Postal Address / IP Electronic Address /
  IP Alt Identification), xuất file lld_{SOURCE}_{TABLE}.yaml trong
  DataModel/working/Atomic/lld/{SOURCE}/.
  Cũng dùng khi: consolidate entity từ nhiều source (Level 2), cập nhật manifest.yaml,
  classification_schemes.yaml, pending_design.yaml;
  chạy validate_lld_yaml.py, aggregate_atomic.py, post_check_atomic.py,
  post_check_source_coverage.py.
  Yêu cầu: HLD đã duyệt cho source_system tương ứng.
---

# Skill: Thiết kế LLD (Low-Level Design)

Đọc file này TRƯỚC KHI bắt đầu thiết kế LLD cho bất kỳ bảng nguồn nào.

## Tài nguyên đi kèm

- **Templates YAML** (copy + replace placeholder — dùng cho thiết kế mới):
  - [`templates/lld_main_entity.yaml`](templates/lld_main_entity.yaml) — skeleton cho entity chính (PK + BK + FK + audit).
  - [`templates/lld_shared_IP_Postal.yaml`](templates/lld_shared_IP_Postal.yaml) — IP Postal Address.
  - [`templates/lld_shared_IP_Electronic.yaml`](templates/lld_shared_IP_Electronic.yaml) — IP Electronic Address (PHONE/FAX/EMAIL/WEBSITE).
  - [`templates/lld_shared_IP_Alt_Identification.yaml`](templates/lld_shared_IP_Alt_Identification.yaml) — IP Alt Identification.
  - [`templates/entity_template.yaml`](templates/entity_template.yaml) — skeleton Level 2 entity consolidation.
- **Templates CSV** (legacy — chỉ dùng nếu cần tham khảo format cũ):
  - [`templates/attr_main_entity.csv`](templates/attr_main_entity.csv)
- **Reference** (rule chuẩn dùng chung dự án):
  - [`reference/data_domains.md`](reference/data_domains.md) — 12 Data Domain chuẩn + 2 mở rộng.
  - [`reference/shared_entity_schemas.md`](reference/shared_entity_schemas.md) — tên trường chuẩn 3 shared entity, quy tắc `classification_context`, trường địa lý.
  - [`reference/post_check_codes.md`](reference/post_check_codes.md) — chi tiết C1–C5 và source coverage check.
  - [`reference/file_layout.md`](reference/file_layout.md) — vị trí + encoding + cấu trúc tất cả file LLD.

## ĐIỀU KIỆN TIÊN QUYẾT

- HLD đã được duyệt cho source system đang thiết kế.
- File HLD nằm tại `DataModel/working/Atomic/hld/{SOURCE}_HLD_Overview.md` và `{SOURCE}_HLD_Tier{N}.md`.

## QUY TRÌNH THIẾT KẾ LLD

### Bước 0 — Pre-flight check

**Trước khi bắt đầu bất kỳ thiết kế nào**, kiểm tra trạng thái file LLD đã có:

1. Đọc `DataModel/working/Atomic/lld/manifest.yaml` → lấy danh sách `lld_file` cho source đang thiết kế.
2. Với mỗi bảng cần thiết kế, kiểm tra file `DataModel/working/Atomic/lld/{SOURCE}/lld_{SOURCE}_{TABLE}.yaml`:

| Trạng thái | Hành động |
|---|---|
| File **không tồn tại** hoặc `design_status: draft` | ✅ Tiếp tục thiết kế |
| File tồn tại, `design_status: reviewed` | ⚠️ Hỏi xác nhận trước khi ghi đè: "File đã reviewed — tạo lại?" |
| File tồn tại, `design_status: approved` | ⛔ **SKIP hoàn toàn** — KHÔNG ghi đè |

**Quy tắc:** `approved` = đã qua review + approval trong App. AI không bao giờ ghi đè file `approved`. Nếu cần sửa file đã approved → người thiết kế phải đổi `design_status` về `reviewed` hoặc `draft` thủ công trong App trước.

### Bước 1 — Đọc context

**Đọc TRƯỚC KHI thiết kế:**

1. **HLD Overview** (`{SOURCE}_HLD_Overview.md`) → tổng quan entity, quan hệ, BCV Concept đã thống nhất.
2. **HLD Tier tương ứng** (`{SOURCE}_HLD_Tier{N}.md`) → chi tiết entity và quan hệ Tier đang thiết kế.
3. **Source columns** (`Source/{SOURCE}_Tables.csv`, `{SOURCE}_Columns.csv`) → cột, data type, mô tả gốc.
   Ghi nhận data type của từng cột nguồn — dùng ở Bước 3b để review conversion risk và ghi chú khi data type nguồn không khai báo rõ ràng.
4. **Tất cả file LLD đã có** trong cùng source system (`DataModel/working/Atomic/lld/{SOURCE}/`):
   - Entity đã thiết kế và cấu trúc attribute.
   - Pattern FK đã dùng (tên trường, data domain).
   - Shared entity đã có những trường nào.
5. **LLD entity tương đồng từ source khác** (nếu có): Nếu entity đang thiết kế có kiểu tương đồng với entity ở source khác (cùng BCV Concept, hoặc cùng loại shared entity), đọc ít nhất 1 file LLD tương ứng từ source đó. Mục đích: lấy đúng pattern tên attribute, format nullable, format source_columns, FK comment.
   - Ví dụ: thiết kế IP Postal Address cho FMS → đọc `DataModel/working/Atomic/lld/NHNCK/lld_NHNCK_PROFESSIONALS_IP_Postal_Address.yaml`.
   - Ví dụ: thiết kế entity `[Involved Party] Organization` → đọc `DataModel/working/Atomic/lld/DCST/lld_DCST_THONG_TIN_DK_THUE.yaml` (nếu đã có).
6. **`Atomic/lld/classification_schemes.yaml`** → kiểm tra Classification Value đã chuẩn hóa.
7. **`DataModel/working/Atomic/lld/manifest.yaml`** → biết file LLD nào đã có và `design_status` tương ứng.

### Bước 2 — Xác định Atomic entity target và Tier

Từ HLD đã duyệt, xác định:
- Bảng nguồn này map về Atomic entity nào?
- BCV Concept và Category đã gán?
- Quan hệ FK với entity nào?
- Entity này thuộc Tier mấy?

**Thứ tự thiết kế theo Tier:** Hoàn thành LLD Tier N trước khi bắt đầu Tier N+1. Entity Tier sau có FK đến entity Tier trước — cần LLD Tier trước để lấy đúng tên attribute FK.

### Bước 3 — Thiết kế attribute-level

Copy [`templates/lld_main_entity.yaml`](templates/lld_main_entity.yaml) làm starting point. Replace placeholder, điền từng attribute theo quy tắc dưới. Nhớ sinh `physical_name` (snake_case) cho mỗi attribute ngay khi thiết kế. `data_type` để trống — `transform_physical_names.py` sẽ tự điền dựa vào `data_domain`.

#### 3a. Mô tả (description)
- Ghép 2 phần: **mô tả gốc từ CSDL nguồn (giữ nguyên)** + mô tả bổ sung trên model (nếu có).
- Không bỏ mô tả nguồn, không viết lại theo cách hiểu riêng.
- **Tiếng Việt PHẢI có dấu đầy đủ** (Unicode UTF-8). Không viết Việt-không-dấu, không viết tắt. Hiển thị trực tiếp trong tài liệu Word handover (`atomic-gen-docs`). Nếu mô tả gốc từ CSDL nguồn không có dấu → bổ sung dấu khi copy.

#### 3b. Data Domain

Dùng Data Domain phù hợp nhất với **ý nghĩa nghiệp vụ** của attribute (chi tiết xem [`reference/data_domains.md`](reference/data_domains.md)). 2 Data Domain mở rộng cho junction denormalized: `Array<Text>`, `Array<Struct>`.

**Bước 1 — Chọn Data Domain theo nghĩa nghiệp vụ (ưu tiên ngữ nghĩa, không ép theo data type nguồn):**
- Ý nghĩa là tiền tệ → `Currency Amount`, dù nguồn lưu `varchar`
- Ý nghĩa là lãi suất → `Interest Rate`; tỷ giá → `Exchange Rate`; phần trăm → `Percentage`
- Ý nghĩa là ngày (không có giờ) → `Date`; ngày + giờ → `Timestamp`
- Ý nghĩa là cờ True/False → `Boolean`; số đếm/version → `Small Counter`
- Ý nghĩa là mã phân loại → `Classification Value`; FK surrogate → `Surrogate Key`
- Không thuộc các loại trên → `Text`

Nếu ý nghĩa nghiệp vụ không ánh xạ được vào bất kỳ Data Domain hiện có nào → **đề xuất Data Domain mới** kèm định nghĩa và data type vật lý dự kiến, ghi vào comment với tag `[PROPOSE NEW DOMAIN]` để reviewer xem xét bổ sung vào `reference/data_domains.md`.

**Bước 2 — Review conversion risk: đối chiếu Data Domain đã chọn với data type nguồn:**

Sau khi chọn xong Data Domain, đọc lại data type của cột nguồn trong Columns.csv và ghi chú nếu có chênh lệch:

| Tình huống | Hành động |
|---|---|
| Data type nguồn khớp tự nhiên với domain (ví dụ: `date` → `Date`, `decimal` → `Currency Amount`) | Không cần ghi chú thêm |
| Data type nguồn hẹp hơn domain nhưng là **widening conversion** (ví dụ: `date` → `Timestamp`, `int` → `decimal`) | Không cần ghi chú — ETL cast tự nhiên, không mất dữ liệu |
| Data type nguồn là `string`/`varchar` nhưng domain chọn là số (`Small Counter`, `Currency Amount`...) | Ghi chú vào comment: `"Nguồn lưu dạng string — ETL cần cast/parse sang [data type vật lý]. Cần validate không có giá trị non-numeric."` |
| Data type nguồn là số (`int`, `decimal`) nhưng domain chọn là `Text` hoặc `Classification Value` | Ghi chú: `"Nguồn lưu dạng số — ETL cần convert sang string. Giữ nguyên leading zeros nếu có."` |
| Data type nguồn không khai báo trong Columns.csv | Ghi chú: `"Data type nguồn không rõ — cần profile trước khi ETL. Domain tạm chọn dựa trên mô tả cột."` |

Mục đích của Bước 2 là **không thay đổi domain đã chọn** mà là **ghi nhận conversion risk** để team ETL biết trước. Chuẩn hóa dữ liệu theo ngữ nghĩa là đúng; ép kiểu cần được thực hiện có kiểm soát.

#### 3c. FK đến Fundamental entity
- **Luôn tạo cặp `[Entity] Id` + `[Entity] Code`** — kể cả khi nullable.
- Id: data domain = `Surrogate Key`.
- Code: data domain = `Text`.
- Nếu Code = NULL thì Id cũng = NULL → cặp nhất quán.

#### 3d. Classification Value
- **Chỉ 1 trường Code** (data domain = `Classification Value`). KHÔNG tạo cặp Id + Code.
- Áp dụng cho: Classification Value, Currency, Calendar Date, mọi bảng danh mục SCD1 không có surrogate key.
- **`etl_derived_value` bắt buộc điền cho Classification Value:**

  | Dạng `classification_context` | `etl_derived_value` |
  |---|---|
  | `SCHEME=VALUE` (cố định, VD: `IP_ELEC_ADDR_TYPE=PHONE`) | Điền literal VALUE: `PHONE` |
  | `SOURCE_SYSTEM=SRC.TABLE` | Điền literal: `SRC.TABLE` |
  | `SCHEME` (không có `=VALUE`, dynamic — VD: `IP_ADDR_TYPE`) | Để **null** hoặc ghi expression mapping ETL (VD: `1=CMND;2=CCCD;3=PASSPORT`) |
  | Không có `classification_context` | Để null |

  > **Lưu ý quan trọng — IP Postal Address:** Nếu bảng nguồn **chỉ có 1 loại địa chỉ cụ thể** (VD: chỉ có `PERMANENT_ADDRESS`, không có cột address_type), KHÔNG dùng bare `IP_ADDR_TYPE` — phải hardcode: `IP_ADDR_TYPE=PERMANENT`. Bare context khiến aggregate bỏ sót `Address Type Code` khi merge nhiều source. Chỉ dùng `IP_ADDR_TYPE` (bare/dynamic) khi nguồn thực sự có cột type động qua lookup.

#### 3e. PK nguồn và BK
- PK bảng nguồn (VD: `ID`) → map vào **Entity Code (BK)**, không đưa vào technical field.
- Mã nghiệp vụ khác có tính unique (VD: `MA_SO_THUE`) → trường nghiệp vụ riêng, không phải BK.

#### 3f. Source System Code

Format bắt buộc — **cả 2 trường phải nhất quán:**

| Trường | Giá trị bắt buộc |
|---|---|
| `classification_context` | `SOURCE_SYSTEM=NHNCK.TABLE_NAME` |
| `etl_derived_value` | `NHNCK.TABLE_NAME` (phần VALUE sau dấu `=`) |

`TABLE_NAME` = tên bảng nguồn cụ thể (không phải chỉ tên source system).

**Pattern sai — KHÔNG dùng:**

| Pattern sai | Lý do |
|---|---|
| `SOURCE_SYSTEM` (bare, thiếu `=VALUE`) | aggregate không derive được etl_derived_value |
| `''` (trống) | aggregate bỏ qua hoàn toàn |
| `'ETL-derived = NHNCK.TABLE'` (free-text) | không đúng format `SCHEME=VALUE` |
| `'SCHEME=SOURCE_SYSTEM'` (key/value đảo ngược) | context không có ý nghĩa |
| `'Scheme: SOURCE_SYSTEM. ...'` (free-text) | không phải machine-readable format |

#### 3g. Metadata nguồn
- Trường metadata truyền nhận (VD: `GOI_TIN_ID`) → trường nghiệp vụ bình thường, không đưa vào nhóm `ds_`.

#### 3h. Trường denormalized
- Trường chứa thông tin entity khác nhưng không có cơ chế link → giữ dạng text denormalized. Không đề xuất "map ở entity khác" nếu không có link thực tế.

#### 3i. Bảng junction denormalized theo HLD

Nếu HLD đã quyết định denormalize 1 bảng junction thành ARRAY trên entity cha:
- Thêm attribute vào file LLD của entity cha (không tạo file LLD riêng, không thêm vào manifest).
- `data_domain` = `Array<Text>` (junction chỉ có code) hoặc `Array<Struct>` (junction có cặp Id + Code).
- `source_columns` = FK phía bên kia của junction (VD: `FMS.SECBUSINES.BuId`).
- `comment`: tên bảng junction gốc + tham chiếu HLD + schema struct nếu là `Array<Struct>`. Mẫu: `Pure junction {TABLE} → denormalize thành ARRAY. Struct: {field1: Domain1; field2: Domain2}. HLD decision: {file HLD}.`
- Tên attribute: danh từ số nhiều phản ánh nội dung phần tử (VD: `Business Type Codes`, `Distribution Agent Ids`).

#### 3j. Merge entity từ 2 bảng nguồn 1-1 — xử lý cột duplicate

Khi 1 Atomic entity gộp từ 2 bảng nguồn quan hệ 1-1 (VD: Public Company = company_profiles + company_detail), thường có cột trùng giá trị (name VI/EN, business_reg_no, ticker, audit fields).

**Quy tắc:**
1. **Chọn 1 bảng làm primary source** cho các cột trùng — map `source_columns` từ bảng đó.
2. **Cột trùng của bảng kia** document trong `pending_design.yaml`:
   - `reason`: "Giá trị 1-1 với {primary_table}.{col}. Map primary từ {primary_table}."
   - `action`: "Đã capture qua {primary_table} (1-1)"
3. **KHÔNG** ghi `"X.col1, Y.col2"` trong `source_columns`. Script `post_check_atomic.py` C5 kiểm tra format đúng 3 phần `SOURCE.table.column`.
4. **PK kỹ thuật của bảng phụ** (VD: `company_detail.id`) cũng document pending: "PK kỹ thuật riêng của bảng detail, không phải BK của entity."

#### 3k. Audit block (Created/Updated)

Khi bảng nguồn có cặp `CREATED_AT / CREATED_BY / UPDATED_AT / UPDATED_BY`, luôn map theo block 6 attribute chuẩn:

| Attribute Name | Data Domain | source_columns | Comment |
|---|---|---|---|
| `Created Timestamp` | `Timestamp` | `*.CREATED_AT` | (trống) |
| `Updated Timestamp` | `Timestamp` | `*.UPDATED_AT` | (trống) |
| `Created By [Entity] Id` | `Surrogate Key` | `*.CREATED_BY` | `FK target: {Entity}.{Entity} Id.` |
| `Created By [Entity] Code` | `Text` | `*.CREATED_BY` | `Lookup pair: {Entity}.{Entity} Code. Pair with Created By [Entity] Id.` |
| `Updated By [Entity] Id` | `Surrogate Key` | `*.UPDATED_BY` | `FK target: {Entity}.{Entity} Id.` |
| `Updated By [Entity] Code` | `Text` | `*.UPDATED_BY` | `Lookup pair: {Entity}.{Entity} Code. Pair with Updated By [Entity] Id.` |

**Quy tắc:**
- `[Entity]` = tên ngắn của Atomic entity đích dùng trong tên attribute (ví dụ: `Officer` khi FK target là `Regulatory Authority Officer`).
- Comment `FK target:` và `Lookup pair:` phải dùng **tên attribute đầy đủ** (có prefix entity) — không dùng tên rút gọn.
  - Đúng: `FK target: Regulatory Authority Officer.Regulatory Authority Officer Id.`
  - Sai: `FK target: Regulatory Authority Officer.Officer Id.`
- **Self-reference** (entity FK về chính nó): vẫn dùng đầy đủ cặp Id + Code — không bỏ Id.
- **Nguồn `DATE` (không có giờ)**: vẫn dùng domain `Timestamp` — widening conversion, không cần ghi chú.
- **FK target chưa xác định** (entity chưa thiết kế): giữ đủ 6 attribute, đặt `status=pending`, comment `Pending — FK target chưa xác định.`

### Bước 4 — Rà soát shared entity

Nếu bảng nguồn có grain = 1 Involved Party:
- Trường địa chỉ → **IP Postal Address** ([`templates/lld_shared_IP_Postal.yaml`](templates/lld_shared_IP_Postal.yaml))
- Trường liên lạc → **IP Electronic Address** ([`templates/lld_shared_IP_Electronic.yaml`](templates/lld_shared_IP_Electronic.yaml))
- Trường giấy tờ → **IP Alt Identification** ([`templates/lld_shared_IP_Alt_Identification.yaml`](templates/lld_shared_IP_Alt_Identification.yaml))

**Involved Party bao gồm cả cá nhân lẫn tổ chức.** Không phân biệt loại IP — chỉ cần entity chính đang mô tả 1 IP (cá nhân, tổ chức, công ty, chi nhánh...) là phải tách shared entity.

Quy tắc grain = Involved Party luôn áp dụng, không phụ thuộc HLD Tier có liệt kê shared entity hay không. Nếu HLD Tier chưa có shared entity tương ứng, đồng bộ tài liệu sau khi thiết kế LLD:
1. Thêm entry vào `DataModel/working/Atomic/lld/manifest.yaml` (block `entries:`).
2. Cập nhật `source_table` trong HLD Overview và HLD Tier tương ứng.
3. Ghi 1 dòng vào "Điểm cần xác nhận" của HLD Tier mô tả quyết định tách shared entity.

**Tên trường + schema chuẩn cho 3 shared entity:** xem [`reference/shared_entity_schemas.md`](reference/shared_entity_schemas.md). File này chứa:
- Bảng tên trường chuẩn cho IP Postal / IP Electronic / IP Alt Identification.
- Quy tắc `classification_context` (`SCHEME=VALUE` bắt buộc, pattern `(source)` cho type động).
- Quy tắc trường địa lý (4 cách xử lý theo bối cảnh nguồn).
- Cột nguồn không map được vào schema chuẩn → document trong `pending_design.yaml`.

Nếu grain KHÔNG phải Involved Party → **KHÔNG tách**, giữ denormalized. Ví dụ: snapshot tờ khai thuế, quyết định hành chính, log kỹ thuật — địa chỉ trong các entity này là denormalized hợp lệ.

### Bước 5 — Viết comment

Thứ tự: tag automation trước, notes sau.

**FK đến Fundamental entity:**

Phân biệt **Id** (FK constraint thực sự) vs **Code** (denormalized lookup, không phải FK constraint):

- **Id** — FK constraint duy nhất (Surrogate Key):
  `FK target: {Atomic Entity Name}.{Atomic Entity Name} Id. {notes}`
  → `atomic-gen-docs` parse prefix `FK target:` và đưa vào bảng Constraint của tài liệu CSDL.

  **Hash comment — bắt buộc bổ sung cho ETL:** ETL hash surrogate Id từ 2 input:
  `(source_system_code, business_key)`. FK_SOURCE = source table của **target entity**,
  xác định từ `Source/{SOURCE}_Columns.csv` cột "Ghi chú (FK suy luận)".

  | Case | source_columns | Hash comment |
  |---|---|---|
  | FK bình thường | `[SRC.TABLE.FK_COL]` | `Hash: hash_id('SRC.TARGET_TABLE', FK_COL).` |
  | Shared entity (IP sub-table, dùng PK parent) | `[SRC.PARENT_TABLE.ID]` | `Hash: hash_id('SRC.PARENT_TABLE', ID).` |
  | FK luôn NULL | `[]` (rỗng) | Không thêm hash — ghi lý do NULL thay thế |

  Ví dụ:
  - Normal: `"FK target: Securities Practitioner.Securities Practitioner Id. Hash: hash_id('NHNCK.PROFESSIONALS', PROFESSIONAL_ID)."`
  - Shared entity: `"FK target: Securities Organization Reference.Securities Organization Reference Id. Shared entity. Hash: hash_id('NHNCK.ORGANIZATIONS', ID)."`
  - Always null: `"FK target: Geographic Area.Geographic Area Id. NULL vì COUNTRIES không có parent."`

- **Code** — denormalized lookup (KHÔNG phải FK constraint, chỉ là copy giá trị business key cho tiện query):
  `Lookup pair: {Atomic Entity Name}.{Atomic Entity Name} Code. Pair with {Id field name}. {notes}`
  → `atomic-gen-docs` KHÔNG đưa Code vào bảng Constraint. Chỉ Id mới sinh constraint.

- **Currency Code** (Classification Value pattern, không có Id surrogate):
  `FK target: Currency.Currency Code. {notes}`
  → vẫn dùng `FK target:` vì đây là FK constraint trực tiếp đến Currency entity (không có cặp Id+Code).

**Tại sao tách syntax:** parser của `atomic-gen-docs` đơn giản hoá — chỉ scan `FK target:` để build Constraint. Code có comment `Lookup pair:` → tự động không match → không bị duplicate trong Constraint table (đúng chuẩn DBA: 1 FK = 1 constraint, không lặp lại Code).

**Classification Value:**
- `Scheme: {SCHEME_CODE}. {notes}`
- Scheme Code = `UPPER_SNAKE_CASE`, nhất quán với `classification_schemes.yaml`.
- KHÔNG dùng cả `FK target:` và `Scheme:` cho cùng 1 trường.
- **Bắt buộc cross-check:** Mọi Scheme Code dùng trong LLD phải tồn tại trong `classification_schemes.yaml`. Nếu chưa có → thêm vào ref file ngay trong cùng lượt thiết kế.

**Trường nghiệp vụ:**
- Ghi BCV Term đã tra cứu được (nếu có) + lý do chọn tên attribute.
- Nếu tên khác BCV Term → giải thích lý do.
- Nếu BCV không có → ghi "BCV: không có term riêng" + cơ sở đặt tên.

**Shared entity:** Ghi note nhất quán với LLD nào đã duyệt.

### Bước 6 — Kiểm tra nhất quán

Trước khi xuất file:
- [ ] FK trỏ về entity đã thiết kế → dùng đúng tên trường từ file LLD đã duyệt?
- [ ] Shared entity đã có cấu trúc → không thiết kế lại, chỉ bổ sung source mapping?
- [ ] Pattern đã dùng (Source System Code, BK, Classification Value) → giữ nguyên?
- [ ] Prefix nhất quán trong nhóm trường liên quan?
- [ ] Prefix chủ thể cho trường mô tả người/đối tượng khác?
- [ ] Mọi trường nguồn đều xuất hiện trong mapping? Không có dòng "không map ở đây"?
- [ ] LLD không bao gồm technical fields (ds_*) — xem danh sách chuẩn tại [`reference/technical_fields.md`](reference/technical_fields.md)?
- [ ] Tên attribute cùng ý nghĩa với LLD source khác đã có → dùng đúng tên đó (`Charter Capital Amount`, `Life Cycle Status Code`...)?
- [ ] **Entity dùng chung nhiều source:** attribute tên công ty/tên tắt/tên tiếng Anh phải dùng **prefix entity** nhất quán (`Fund Management Company Name`, `Custodian Bank Short Name`) — KHÔNG dùng `Full Name` / `Abbreviation` / `English Name` cho entity shared.
- [ ] Format `nullable` nhất quán: `true`/`false` — không dùng `Yes`/`No`.
- [ ] **Conversion risk:** Mọi attribute có Data Domain không khớp tự nhiên với data type nguồn (ví dụ: nguồn `string` → domain `Small Counter`) đã có comment ghi chú conversion risk chưa? Nếu data type nguồn không khai báo → đã ghi "cần profile" trong comment?
- [ ] **Domain mới:** Nếu có attribute dùng tag `[PROPOSE NEW DOMAIN]` → đã tách thành điểm cần xác nhận riêng để reviewer quyết định bổ sung vào `reference/data_domains.md`?
- [ ] **FK comment** (xem Bước 5): Id ghi `FK target: ...`, Code ghi `Lookup pair: ... Pair with {Id field}` — KHÔNG ghi `FK target:` cho cả Id+Code. Currency Code (Classification Value pattern, không có Id) ghi `FK target:`.
- [ ] **FK hash comment** (xem Bước 5): Mọi FK Id có `source_columns` không rỗng → comment phải có `Hash: hash_id('SRC.TARGET_TABLE', COL).` (FK_SOURCE tra từ `Source/{SOURCE}_Columns.csv`). FK với `source_columns: []` → không thêm hash, ghi lý do NULL.
- [ ] **Audit block** (xem Bước 3k): Bảng nguồn có `CREATED_AT / CREATED_BY / UPDATED_AT / UPDATED_BY` → đủ 6 attribute chuẩn. Comment FK target dùng **tên attribute đầy đủ** (có prefix entity). Self-reference vẫn có cặp Id + Code.
- [ ] Format `source_columns` nhất quán: fully qualified `SOURCE_SYSTEM.schema.Table.Column`.
- [ ] Shared entity: FK dùng `Involved Party Id` / `Involved Party Code` — không dùng tên entity cha.
- [ ] Bảng junction denormalized theo HLD → attribute ARRAY đã thêm vào entity cha, không có trong manifest.
- [ ] **Cross-check scheme:** Mọi `Scheme: XYZ` trong cột comment và mọi `XYZ=` trong cột `classification_context` đều có trong `classification_schemes.yaml`.
- [ ] **Trường địa lý:** mã quốc gia/tỉnh/huyện/xã được xử lý đúng theo bối cảnh nguồn (xem [`reference/shared_entity_schemas.md`](reference/shared_entity_schemas.md)).
- [ ] **Shared entity type động:** Nếu nguồn có cột type qua lookup_values (`identity_type_cd`...) → đã dùng `SCHEME=(source)` placeholder chưa? Không để bare context.
- [ ] **Shared entity — cột không map:** PK kỹ thuật / audit fields / business flag của bảng nguồn shared đã được document trong `pending_design.yaml`?
- [ ] **Merge entity 1-1:** `source_columns` KHÔNG dùng format comma-separated `"X.col1, Y.col2"` — chỉ 1 bảng primary, bảng còn lại document pending.
- [ ] **Encoding:** mọi file CSV ghi UTF-8 with BOM (`utf-8-sig`) — xem [`reference/file_layout.md`](reference/file_layout.md).
- [ ] **`etl_derived_value` cho Classification Value:** Mọi row có `classification_context = SCHEME=VALUE` → `etl_derived_value = VALUE`. Mọi row `SOURCE_SYSTEM=SRC.TABLE` → `etl_derived_value = SRC.TABLE`. Dynamic context (không có `=VALUE`) → null hoặc expression mapping.
- [ ] **Source System Code:** `classification_context = SOURCE_SYSTEM=NHNCK.TABLE_NAME` (không free-text, không bare, không trống); `etl_derived_value = NHNCK.TABLE_NAME` (bắt buộc, không trống).
- [ ] **Post-check C7 + C8:** Sau aggregate, chạy `post_check_atomic.py` — C7 kiểm tra mọi `Classification Value` có context `SCHEME=VALUE` đều có `etl_derived_value`; C8 kiểm tra riêng `Source System Code`.
- [ ] **Post-check:** Sau khi chạy aggregate, chạy `post_check_atomic.py` (xem [`reference/post_check_codes.md`](reference/post_check_codes.md)) và xử lý mọi warning trước khi kết thúc Tier.
- [ ] **Source coverage:** Chạy `post_check_source_coverage.py --source {SOURCE}` — mọi bảng đã thiết kế đều có 100% cột map (hoặc pending với reason rõ).

## OUTPUT

### File LLD (.yaml) — Level 1

**Tên file:** `lld_{SOURCE_SYSTEM}_{SOURCE_TABLE}.yaml` (entity chính)
hoặc `lld_{SOURCE_SYSTEM}_{SOURCE_TABLE}_IP_Postal_Address.yaml` v.v. (shared entity).
**Mỗi file = 1 bảng nguồn.** Ghi vào `DataModel/working/Atomic/lld/{SOURCE_SYSTEM}/`.

**`design_status: draft`** khi xuất ra. Human review trong App → đổi thành `reviewed` → `approved`.

**Ví dụ non-shared (entity chính):**
```yaml
schema_type: lld_source_table
schema_version: "2.0"

metadata:
  source_system: NHNCK
  source_table: PROFESSIONALS
  atomic_entity: Securities Practitioner
  entity_physical_name: scr_practitioner
  bcv_core_object: Involved Party
  bcv_concept: "[Involved Party]"
  table_type: Fundamental
  group: T1
  design_status: draft
  version: "1.0"
  designed_by: null
  designed_at: null
  reviewed_by: null
  reviewed_at: null
  approved_by: null
  approved_at: null
  notes: null

attributes:
  - attribute_name: Securities Practitioner Id
    physical_name: scr_practitioner_id
    description: "Khóa đại diện (surrogate key)."
    data_domain: Surrogate Key
    nullable: false
    is_primary_key: true
    status: draft
    source_columns: []
    comment: null
    classification_context: null
    etl_derived_value: null

  - attribute_name: Securities Practitioner Code
    physical_name: scr_practitioner_code
    description: "Mã NHN do UBCKNN cấp. Map từ PK bảng nguồn."
    data_domain: Text
    nullable: false
    is_primary_key: false
    status: draft
    source_columns:
      - NHNCK.qlnhn.PROFESSIONALS.ID
    comment: "BCV Term: Individual Identifier. BK của entity."
    classification_context: null
    etl_derived_value: null

  - attribute_name: Source System Code
    physical_name: src_stm_code
    description: "Mã hệ thống nguồn dữ liệu."
    data_domain: Classification Value
    nullable: false
    is_primary_key: false
    status: draft
    source_columns: []
    comment: "Scheme: SOURCE_SYSTEM."
    classification_context: SOURCE_SYSTEM=NHNCK.PROFESSIONALS
    etl_derived_value: NHNCK.PROFESSIONALS
```

**Physical name (snake_case):** AI sinh sẵn `physical_name` cho mỗi attribute khi thiết kế. `data_type` để trống hoặc null — `transform_physical_names.py` tự patch sau khi lưu file.
- Entity: `[domain_prefix]_[bcv_term]` (VD: `scr_practitioner`, `scr_org_ref`)
- Attribute: `[entity_prefix]_[field]` → viết tắt thông minh, snake_case (VD: `scr_practitioner_id`, `org_full_nm`, `src_stm_code`)

### Cập nhật manifest.yaml

Đọc `DataModel/working/Atomic/lld/manifest.yaml`, thêm entry cho file LLD mới vừa tạo (nếu chưa có):

```yaml
  - source_system: NHNCK
    source_table: PROFESSIONALS
    atomic_entity: Securities Practitioner
    group: T1
    lld_file: NHNCK/lld_NHNCK_PROFESSIONALS.yaml
    design_status: draft
```

### Cập nhật classification_schemes.yaml

1. Đọc toàn bộ file hiện tại.
2. Bổ sung scheme/giá trị mới phát sinh.
3. Xuất 1 file duy nhất chứa toàn bộ cũ + mới.

### Bước 7 — Validate LLD YAML

Sau khi thiết kế xong 1 bảng (hoặc cả Tier), chạy validate:

```bash
python DataModel/working/Atomic/lld/scripts/validate_lld_yaml.py --source {SOURCE}
# Hoặc validate 1 file:
python DataModel/working/Atomic/lld/scripts/validate_lld_yaml.py --file DataModel/working/Atomic/lld/{SOURCE}/lld_{SOURCE}_{TABLE}.yaml
```

**Điều kiện passed**: `Failed: 0`. Xử lý mọi E1–E6 trước khi kết thúc Tier.

Xử lý mọi warning trước khi kết thúc Tier. Sau validate, thông báo cho người thiết kế: **"Tiếp theo: Review trong App → post_check → approve → trigger Consolidate nếu entity đến từ nhiều source."**

### Bước 8 — Post-check (sau khi Human approve Level 1)

Khi đã approve toàn bộ bảng của Tier trong App, chạy post-check từ YAML:

```bash
python DataModel/working/Atomic/lld/scripts/post_check_atomic.py --source {SOURCE}
python DataModel/working/Atomic/lld/scripts/post_check_source_coverage.py --source {SOURCE}
```

Xử lý mọi warning (chi tiết C1–C5 xem [`reference/post_check_codes.md`](reference/post_check_codes.md)) trước khi sang bước tiếp.

### Bước 9 — Entity Consolidation (Level 2, optional)

**Điều kiện:** Entity đến từ nhiều source tables (VD: `Securities Organization Reference` từ cả NHNCK + SCMS).

Khi Human trigger "Consolidate entity X" từ App:

1. AI đọc tất cả `lld_*.yaml` có `design_status: approved` và `atomic_entity = X`.
2. Build union attribute list, flag inconsistency:
   - Data domain mismatch cùng attribute tên giống nhau
   - Attribute name không nhất quán giữa source (VD: "Full Name" vs "Organization Full Name")
   - Attribute thiếu ở một số source → đề xuất `nullable: true` cho source đó
3. Sinh `DataModel/working/Atomic/lld/entities/entity_{PHYSICAL_NAME}.yaml` dùng [`templates/entity_template.yaml`](templates/entity_template.yaml).
4. `consolidation_status: pending` + `consolidation_notes:` liệt kê issues.
5. Human review trong App → resolve issues → set `consolidation_status: approved`.

```bash
# Generate entity_*.yaml từ lld_*.yaml approved:
python DataModel/working/Atomic/lld/scripts/generate_entity_consolidation.py
# Chỉ 1 entity:
python DataModel/working/Atomic/lld/scripts/generate_entity_consolidation.py --entity "Securities Practitioner"
# Xem diff không ghi file:
python DataModel/working/Atomic/lld/scripts/generate_entity_consolidation.py --dry-run

# Validate entity_*.yaml sau khi AI sinh:
python DataModel/working/Atomic/lld/scripts/validate_lld_yaml.py --entities
```

### Bước 10 — Generate YAML (Phase 4)

Sau khi entity_*.yaml đã approved (hoặc entity single-source chỉ cần lld_*.yaml approved):

```bash
python DataModel/generate_dm_yaml.py --source {SOURCE}
```

Output: `DataModel/Atomic/{BCV_Folder}/dm_atm_{table}-{SOURCE}.{SRC_TABLE}.yaml`

**Sub-folder theo BCV Core Object:**
`Arrangement`, `Business_Activity`, `Common`, `Communication`, `Condition`, `Documentation`, `Event`, `Group`, `Involved_Party`, `Location`, `Product`, `Transaction`

**Kiểm tra nhanh sau khi generate:**
```bash
ls DataModel/Atomic/**/*-{SOURCE}.*.yaml | wc -l
grep -rL "layer: Atomic" DataModel/Atomic/ --include="*.yaml" | grep {SOURCE}
```
Dòng 2 phải trả về rỗng.

---

### Bước 10b — Validate YAML (Phase 4b)

```bash
python DataModel/validate_dm_yaml.py --source {SOURCE}
```

**Điều kiện passed**: `Failed: 0`. KHÔNG sang Phase 5 khi còn failed.

---

### Bước 11 — Consolidate (Phase 5)

```bash
python DataModel/gen_summary_and_model.py --source {SOURCE}
```

Output:
- `DataModel/Atomic/dm_manifest.yaml`
- `DataModel/atomic_model.yaml`

---

## CHECKLIST HOÀN THÀNH TOÀN BỘ PIPELINE

| Phase | Bước | Điều kiện passed |
|---|---|---|
| 0 — Pre-flight | Bước 0 | `approved` files không bị ghi đè |
| 1 — LLD Design | Bước 1–6 | Mọi `lld_*.yaml` trong `DataModel/working/Atomic/lld/{SOURCE}/` đã đủ và đúng chuẩn |
| 1b — Validate LLD | `DataModel/working/Atomic/lld/scripts/validate_lld_yaml.py --source {SOURCE}` | **Failed: 0** |
| 2 — Human Review Level 1 | (trong App) | Mọi `lld_*.yaml` cần thiết kế đã `design_status: approved` |
| 3 — Post-check | `DataModel/working/Atomic/lld/scripts/post_check_atomic.py` + `post_check_source_coverage.py --source {SOURCE}` | **0 WARNING** |
| 3b — Consolidation (nếu cần) | `DataModel/working/Atomic/lld/scripts/validate_lld_yaml.py --entities` | **Failed: 0**, `consolidation_status: approved` |
| 4 — Generate YAML | `generate_dm_yaml.py --source {SOURCE}` | Số file đúng; 0 file thiếu `layer: Atomic` |
| 4b — Validate YAML | `validate_dm_yaml.py --source {SOURCE}` | **Failed: 0** |
| 5 — Consolidate | `gen_summary_and_model.py --source {SOURCE}` | `dm_manifest.yaml` đúng N dòng; `atomic_model.yaml` parse được |

---

## QUY TẮC ĐẶT TÊN ATTRIBUTE

### Prefix nhất quán trong nhóm trường
Nhiều trường cùng nhóm thông tin → dùng chung prefix.
- VD: `Reporting Period Type Code`, `Reporting Period`, `Reporting Period Start Date`, `Reporting Period End Date`.

### Prefix chủ thể
Entity chứa nhóm trường mô tả chủ thể khác (không phải chủ thể chính) → thêm prefix chỉ rõ.
- VD: entity "Related Party" → `Related Individual Full Name`, `Related Individual Birth Year`.
- KHÔNG áp dụng cho snapshot từ entity cha đã có FK.

### Scope entity
Không giả định scope từ tên bảng. Đọc kỹ mô tả nguồn trước.
- VD: `THONG_TIN_DK_THUE` = "thông tin đăng ký thuế" (tổ chức, DN, hộ KD) → không gắn prefix "Organization".
