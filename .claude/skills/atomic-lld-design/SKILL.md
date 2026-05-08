---
name: atomic-lld-design
description: |
  Thiết kế Low-Level Design (LLD) cho từng bảng nguồn trong Atomic source system.
  Sử dụng khi: thiết kế attribute-level cho 1 bảng/Tier, map source columns sang
  Atomic attributes, tách shared entity (IP Postal Address / IP Electronic Address /
  IP Alt Identification), xuất file attr_{SOURCE}_{table}.csv trong Atomic/lld/{SOURCE}/.
  Cũng dùng khi cập nhật manifest.csv, ref_shared_entity_classifications.csv,
  pending_design.csv; chạy aggregate_atomic.py, post_check_atomic.py,
  post_check_source_coverage.py.
  Yêu cầu: HLD đã duyệt cho source_system tương ứng.
---

# Skill: Thiết kế LLD (Low-Level Design)

Đọc file này TRƯỚC KHI bắt đầu thiết kế LLD cho bất kỳ bảng nguồn nào.

## Tài nguyên đi kèm

- **Templates** (copy + replace placeholder):
  - [`templates/attr_main_entity.csv`](templates/attr_main_entity.csv) — skeleton cho entity chính (PK + BK + FK + audit).
  - [`templates/attr_shared_IP_Postal.csv`](templates/attr_shared_IP_Postal.csv) — IP Postal Address với context HEAD_OFFICE.
  - [`templates/attr_shared_IP_Electronic.csv`](templates/attr_shared_IP_Electronic.csv) — IP Electronic Address với 4 context (PHONE/FAX/EMAIL/WEBSITE).
  - [`templates/attr_shared_IP_Alt_Identification.csv`](templates/attr_shared_IP_Alt_Identification.csv) — IP Alt Identification với context `(source)`.
- **Reference** (rule chuẩn dùng chung dự án):
  - [`reference/data_domains.md`](reference/data_domains.md) — 12 Data Domain chuẩn + 2 mở rộng.
  - [`reference/shared_entity_schemas.md`](reference/shared_entity_schemas.md) — tên trường chuẩn 3 shared entity, quy tắc `classification_context`, trường địa lý.
  - [`reference/post_check_codes.md`](reference/post_check_codes.md) — chi tiết C1–C5 và source coverage check.
  - [`reference/file_layout.md`](reference/file_layout.md) — vị trí + encoding + cấu trúc tất cả file LLD.

## ĐIỀU KIỆN TIÊN QUYẾT

- HLD đã được duyệt cho source system đang thiết kế.
- File HLD nằm tại `Atomic/hld/{SOURCE}_HLD_Overview.md` và `{SOURCE}_HLD_Tier{N}.md`.

## QUY TRÌNH THIẾT KẾ LLD

### Bước 1 — Đọc context

**Đọc TRƯỚC KHI thiết kế:**

1. **HLD Overview** (`{SOURCE}_HLD_Overview.md`) → tổng quan entity, quan hệ, BCV Concept đã thống nhất.
2. **HLD Tier tương ứng** (`{SOURCE}_HLD_Tier{N}.md`) → chi tiết entity và quan hệ Tier đang thiết kế.
3. **Source columns** (`Source/{SOURCE}_Tables.csv`, `{SOURCE}_Columns.csv`) → cột, data type, mô tả gốc.
4. **Tất cả file LLD đã có** trong cùng source system (`Atomic/lld/{SOURCE}/`):
   - Entity đã thiết kế và cấu trúc attribute.
   - Pattern FK đã dùng (tên trường, data domain).
   - Shared entity đã có những trường nào.
5. **LLD entity tương đồng từ source khác** (nếu có): Nếu entity đang thiết kế có kiểu tương đồng với entity ở source khác (cùng BCV Concept, hoặc cùng loại shared entity), đọc ít nhất 1 file LLD tương ứng từ source đó. Mục đích: lấy đúng pattern tên attribute, format nullable, format source_columns, FK comment.
   - Ví dụ: thiết kế IP Postal Address cho FMS → đọc `Atomic/lld/NHNCK/attr_NHNCK_Professionals_IP_Postal_Address.csv`.
   - Ví dụ: thiết kế entity `[Involved Party] Organization` → đọc `Atomic/lld/DCST/attr_DCST_THONG_TIN_DK_THUE.csv`.
6. **`Atomic/lld/ref_shared_entity_classifications.csv`** → kiểm tra Classification Value đã chuẩn hóa.
7. **`Atomic/lld/manifest.csv`** → biết file LLD nào đã có.

### Bước 2 — Xác định Atomic entity target và Tier

Từ HLD đã duyệt, xác định:
- Bảng nguồn này map về Atomic entity nào?
- BCV Concept và Category đã gán?
- Quan hệ FK với entity nào?
- Entity này thuộc Tier mấy?

**Thứ tự thiết kế theo Tier:** Hoàn thành LLD Tier N trước khi bắt đầu Tier N+1. Entity Tier sau có FK đến entity Tier trước — cần LLD Tier trước để lấy đúng tên attribute FK.

### Bước 3 — Thiết kế attribute-level

Copy [`templates/attr_main_entity.csv`](templates/attr_main_entity.csv) làm starting point. Replace placeholder, điền từng attribute theo quy tắc dưới.

#### 3a. Mô tả (description)
- Ghép 2 phần: **mô tả gốc từ CSDL nguồn (giữ nguyên)** + mô tả bổ sung trên model (nếu có).
- Không bỏ mô tả nguồn, không viết lại theo cách hiểu riêng.
- **Tiếng Việt PHẢI có dấu đầy đủ** (Unicode UTF-8). Không viết Việt-không-dấu, không viết tắt. Hiển thị trực tiếp trong tài liệu Word handover (`atomic-gen-docs`). Nếu mô tả gốc từ CSDL nguồn không có dấu → bổ sung dấu khi copy.

#### 3b. Data Domain
Dùng đúng 1 trong 12 Data Domain chuẩn (chi tiết xem [`reference/data_domains.md`](reference/data_domains.md)). 2 Data Domain mở rộng cho junction denormalized: `Array<Text>`, `Array<Struct>`.

#### 3c. FK đến Fundamental entity
- **Luôn tạo cặp `[Entity] Id` + `[Entity] Code`** — kể cả khi nullable.
- Id: data domain = `Surrogate Key`.
- Code: data domain = `Text`.
- Nếu Code = NULL thì Id cũng = NULL → cặp nhất quán.

#### 3d. Classification Value
- **Chỉ 1 trường Code** (data domain = `Classification Value`). KHÔNG tạo cặp Id + Code.
- Áp dụng cho: Classification Value, Currency, Calendar Date, mọi bảng danh mục SCD1 không có surrogate key.

#### 3e. PK nguồn và BK
- PK bảng nguồn (VD: `ID`) → map vào **Entity Code (BK)**, không đưa vào technical field.
- Mã nghiệp vụ khác có tính unique (VD: `MA_SO_THUE`) → trường nghiệp vụ riêng, không phải BK.

#### 3f. Source System Code
- Mô tả chi tiết đến mức tên bảng nguồn: `DCST.THONG_TIN_DK_THUE`, không chỉ ghi `DCST`.

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
2. **Cột trùng của bảng kia** document trong `pending_design.csv`:
   - `reason`: "Giá trị 1-1 với {primary_table}.{col}. Map primary từ {primary_table}."
   - `action`: "Đã capture qua {primary_table} (1-1)"
3. **KHÔNG** ghi `"X.col1, Y.col2"` trong `source_columns`. Script `post_check_atomic.py` C5 kiểm tra format đúng 3 phần `SOURCE.table.column`.
4. **PK kỹ thuật của bảng phụ** (VD: `company_detail.id`) cũng document pending: "PK kỹ thuật riêng của bảng detail, không phải BK của entity."

### Bước 4 — Rà soát shared entity

Nếu bảng nguồn có grain = 1 Involved Party:
- Trường địa chỉ → **IP Postal Address** ([`templates/attr_shared_IP_Postal.csv`](templates/attr_shared_IP_Postal.csv))
- Trường liên lạc → **IP Electronic Address** ([`templates/attr_shared_IP_Electronic.csv`](templates/attr_shared_IP_Electronic.csv))
- Trường giấy tờ → **IP Alt Identification** ([`templates/attr_shared_IP_Alt_Identification.csv`](templates/attr_shared_IP_Alt_Identification.csv))

**Involved Party bao gồm cả cá nhân lẫn tổ chức.** Không phân biệt loại IP — chỉ cần entity chính đang mô tả 1 IP (cá nhân, tổ chức, công ty, chi nhánh...) là phải tách shared entity.

Quy tắc grain = Involved Party luôn áp dụng, không phụ thuộc HLD Tier có liệt kê shared entity hay không. Nếu HLD Tier chưa có shared entity tương ứng, đồng bộ tài liệu sau khi thiết kế LLD:
1. Thêm dòng vào `manifest.csv`: `{SOURCE},{table},Involved Party {Postal Address|Electronic Address|Alternative Identification},{Tier},{lld_file}`.
2. Cập nhật `source_table` trong HLD Overview và HLD Tier tương ứng.
3. Ghi 1 dòng vào "Điểm cần xác nhận" của HLD Tier mô tả quyết định tách shared entity.

**Tên trường + schema chuẩn cho 3 shared entity:** xem [`reference/shared_entity_schemas.md`](reference/shared_entity_schemas.md). File này chứa:
- Bảng tên trường chuẩn cho IP Postal / IP Electronic / IP Alt Identification.
- Quy tắc `classification_context` (`SCHEME=VALUE` bắt buộc, pattern `(source)` cho type động).
- Quy tắc trường địa lý (4 cách xử lý theo bối cảnh nguồn).
- Cột nguồn không map được vào schema chuẩn → document trong `pending_design.csv`.

Nếu grain KHÔNG phải Involved Party → **KHÔNG tách**, giữ denormalized. Ví dụ: snapshot tờ khai thuế, quyết định hành chính, log kỹ thuật — địa chỉ trong các entity này là denormalized hợp lệ.

### Bước 5 — Viết comment

Thứ tự: tag automation trước, notes sau.

**FK đến Fundamental entity:**

Phân biệt **Id** (FK constraint thực sự) vs **Code** (denormalized lookup, không phải FK constraint):

- **Id** — FK constraint duy nhất (Surrogate Key):
  `FK target: {Atomic Entity Name}.{Atomic Entity Name} Id. {notes}`
  → `atomic-gen-docs` parse prefix `FK target:` và đưa vào bảng Constraint của tài liệu CSDL.

- **Code** — denormalized lookup (KHÔNG phải FK constraint, chỉ là copy giá trị business key cho tiện query):
  `Lookup pair: {Atomic Entity Name}.{Atomic Entity Name} Code. Pair with {Id field name}. {notes}`
  → `atomic-gen-docs` KHÔNG đưa Code vào bảng Constraint. Chỉ Id mới sinh constraint.

- **Currency Code** (Classification Value pattern, không có Id surrogate):
  `FK target: Currency.Currency Code. {notes}`
  → vẫn dùng `FK target:` vì đây là FK constraint trực tiếp đến Currency entity (không có cặp Id+Code).

**Tại sao tách syntax:** parser của `atomic-gen-docs` đơn giản hoá — chỉ scan `FK target:` để build Constraint. Code có comment `Lookup pair:` → tự động không match → không bị duplicate trong Constraint table (đúng chuẩn DBA: 1 FK = 1 constraint, không lặp lại Code).

**Classification Value:**
- `Scheme: {SCHEME_CODE}. {notes}`
- Scheme Code = `UPPER_SNAKE_CASE`, nhất quán với `ref_shared_entity_classifications.csv`.
- KHÔNG dùng cả `FK target:` và `Scheme:` cho cùng 1 trường.
- **Bắt buộc cross-check:** Mọi Scheme Code dùng trong LLD phải tồn tại trong `ref_shared_entity_classifications.csv`. Nếu chưa có → thêm vào ref file ngay trong cùng lượt thiết kế.

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
- [ ] LLD không bao gồm technical fields (Record Status, Record Insert Date, ETL Timestamp...)?
- [ ] Tên attribute cùng ý nghĩa với LLD source khác đã có → dùng đúng tên đó (`Charter Capital Amount`, `Life Cycle Status Code`...)?
- [ ] **Entity dùng chung nhiều source:** attribute tên công ty/tên tắt/tên tiếng Anh phải dùng **prefix entity** nhất quán (`Fund Management Company Name`, `Custodian Bank Short Name`) — KHÔNG dùng `Full Name` / `Abbreviation` / `English Name` cho entity shared.
- [ ] Format `nullable` nhất quán: `true`/`false` — không dùng `Yes`/`No`.
- [ ] **FK comment** (xem Bước 5): Id ghi `FK target: ...`, Code ghi `Lookup pair: ... Pair with {Id field}` — KHÔNG ghi `FK target:` cho cả Id+Code. Currency Code (Classification Value pattern, không có Id) ghi `FK target:`.
- [ ] Format `source_columns` nhất quán: fully qualified `SOURCE_SYSTEM.schema.Table.Column`.
- [ ] Shared entity: FK dùng `Involved Party Id` / `Involved Party Code` — không dùng tên entity cha.
- [ ] Bảng junction denormalized theo HLD → attribute ARRAY đã thêm vào entity cha, không có trong manifest.
- [ ] **Cross-check scheme:** Mọi `Scheme: XYZ` trong cột comment và mọi `XYZ=` trong cột `classification_context` đều có trong `ref_shared_entity_classifications.csv`.
- [ ] **Trường địa lý:** mã quốc gia/tỉnh/huyện/xã được xử lý đúng theo bối cảnh nguồn (xem [`reference/shared_entity_schemas.md`](reference/shared_entity_schemas.md)).
- [ ] **Shared entity type động:** Nếu nguồn có cột type qua lookup_values (`identity_type_cd`...) → đã dùng `SCHEME=(source)` placeholder chưa? Không để bare context.
- [ ] **Shared entity — cột không map:** PK kỹ thuật / audit fields / business flag của bảng nguồn shared đã được document trong `pending_design.csv`?
- [ ] **Merge entity 1-1:** `source_columns` KHÔNG dùng format comma-separated `"X.col1, Y.col2"` — chỉ 1 bảng primary, bảng còn lại document pending.
- [ ] **Encoding:** mọi file CSV ghi UTF-8 with BOM (`utf-8-sig`) — xem [`reference/file_layout.md`](reference/file_layout.md).
- [ ] **Post-check:** Sau khi chạy aggregate, chạy `post_check_atomic.py` (xem [`reference/post_check_codes.md`](reference/post_check_codes.md)) và xử lý mọi warning trước khi kết thúc Tier.
- [ ] **Source coverage:** Chạy `post_check_source_coverage.py --source {SOURCE}` — mọi bảng đã thiết kế đều có 100% cột map (hoặc pending với reason rõ).

## OUTPUT

### File LLD (.csv)

**Tên file:** `attr_{SOURCE_SYSTEM}_{SourceTableName}.csv`. **Mỗi file = 1 bảng nguồn.** Ghi vào `Atomic/lld/{SOURCE_SYSTEM}/`.

**Cấu trúc + encoding:** xem [`reference/file_layout.md`](reference/file_layout.md).

**Ví dụ non-shared:**
```csv
attribute_name,description,data_domain,nullable,is_primary_key,status,source_columns,comment,classification_context,etl_derived_value
Securities Practitioner Id,Khóa đại diện cho NHN.,Surrogate Key,false,true,approved,,,,
Securities Practitioner Code,"Mã NHN do UBCKNN cấp. Map từ PK bảng nguồn.",Text,false,false,approved,Professionals.ID,"BCV Term: Individual Identifier. BK của entity.",,
Source System Code,Mã hệ thống nguồn.,Classification Value,false,false,approved,,,SOURCE_SYSTEM=NHNCK.Professionals,
```

**Ví dụ shared entity (IP Electronic Address với 2 context):**
```csv
attribute_name,description,data_domain,nullable,is_primary_key,status,source_columns,comment,classification_context,etl_derived_value
Involved Party Id,FK đến Securities Practitioner.,Surrogate Key,false,false,draft,NHNCK.qlnhn.Professionals.Id,FK target: Securities Practitioner.Securities Practitioner Id.,,
Involved Party Code,Mã người hành nghề.,Text,false,false,draft,NHNCK.qlnhn.Professionals.Id,Lookup pair: Securities Practitioner.Securities Practitioner Code. Pair with Involved Party Id.,,
Source System Code,Mã nguồn dữ liệu.,Classification Value,false,false,draft,,,SOURCE_SYSTEM=NHNCK.Professionals,
Electronic Address Type Code,Loại kênh liên lạc — điện thoại.,Classification Value,false,false,draft,,,IP_ELEC_ADDR_TYPE=PHONE,
Electronic Address Value,Số điện thoại.,Text,true,false,draft,NHNCK.qlnhn.Professionals.Phone,,IP_ELEC_ADDR_TYPE=PHONE,
Electronic Address Type Code,Loại kênh liên lạc — email.,Classification Value,false,false,draft,,,IP_ELEC_ADDR_TYPE=EMAIL,
Electronic Address Value,Email.,Text,true,false,draft,NHNCK.qlnhn.Professionals.Email,,IP_ELEC_ADDR_TYPE=EMAIL,
```

### Cập nhật manifest.csv

1. Đọc toàn bộ `Atomic/lld/manifest.csv` hiện tại.
2. Thêm dòng mới cho file LLD vừa tạo.
3. Xuất 1 file duy nhất chứa toàn bộ cũ + mới (UTF-8 with BOM).

Cấu trúc + encoding xem [`reference/file_layout.md`](reference/file_layout.md).

### Cập nhật ref_shared_entity_classifications.csv

1. Đọc toàn bộ file hiện tại.
2. Bổ sung scheme/giá trị mới phát sinh.
3. Xuất 1 file duy nhất chứa toàn bộ cũ + mới.

Cấu trúc xem [`reference/file_layout.md`](reference/file_layout.md).

### Aggregate atomic_attributes.csv và atomic_entities.csv

**KHÔNG ghi thủ công vào 2 file này.** Sau khi hoàn thành toàn bộ `attr_*.csv` và `manifest.csv` của Tier:

```bash
python Atomic/lld/scripts/aggregate_atomic.py
```

Script tự động:
- Đọc `manifest.csv` → biết toàn bộ entity và file LLD.
- Đọc `Atomic/hld/atomic_entities.csv` → lấy `bcv_core_object` cho mỗi entity.
- Đọc từng `attr_*.csv` → thu thập attributes.
- Gộp shared entities (IP Alt Identification, IP Postal Address, IP Electronic Address) từ mọi source → 1 dòng duy nhất mỗi attribute, source_column merge.
- Sort: `bcv_core_object` (A→Z) → `atomic_entity` (A→Z) → thứ tự attribute giữ nguyên.
- Preserve description đã điền thủ công trong `atomic_entities.csv`.
- Ghi đè cả 2 file output.

Script in ra số rows — báo cáo con số này cho người thiết kế xác nhận.

### Bước 7 — Post-check sau khi aggregate

Chạy 2 script post-check (chi tiết C1–C5 và Source Coverage xem [`reference/post_check_codes.md`](reference/post_check_codes.md)):

```bash
python Atomic/lld/scripts/post_check_atomic.py
python Atomic/lld/scripts/post_check_source_coverage.py --source {SOURCE}
```

Xử lý mọi warning trước khi kết thúc Tier.

### Bước 8 — Sinh physical name

```bash
python Atomic/lld/scripts/transform_physical_names.py
```

Script bổ sung cột physical name trực tiếp vào 2 file output (idempotent — chạy nhiều lần không duplicate):
- `atomic_attributes.csv`: thêm `atomic_table` (ngay sau `atomic_entity`) và `atomic_column` (ngay sau `atomic_attribute`).
- `attr_Classification_Value.csv`: thêm `atomic_column` (ngay sau `attribute_name`).

Tra 1 tên cụ thể để kiểm tra:
```bash
python Atomic/lld/scripts/transform_physical_names.py --name "Fund Management Company Code"
```

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
