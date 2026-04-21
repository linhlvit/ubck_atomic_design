# Skill: Thiết kế LLD (Low-Level Design)

Đọc file này TRƯỚC KHI bắt đầu thiết kế LLD cho bất kỳ bảng nguồn nào.

## ĐIỀU KIỆN TIÊN QUYẾT

- HLD đã được duyệt cho source system đang thiết kế.
- File HLD nằm tại `docs/approved/<project>/Silver/hld/`.

## QUY TRÌNH THIẾT KẾ LLD

### Bước 1 — Đọc context

**Bắt buộc đọc TRƯỚC KHI thiết kế:**

1. **File HLD Overview** (`<SOURCE_SYSTEM>_HLD_Overview.md`) → hiểu tổng quan toàn bộ entity, quan hệ, BCV Concept đã thống nhất cho source system.
2. **File HLD Tier tương ứng** (`<SOURCE_SYSTEM>_HLD_Tier<N>.md`) → đọc chi tiết entity và quan hệ của Tier đang thiết kế.
3. **File cấu trúc bảng nguồn** (`*_Tables`, `*_Columns` trong `Source/`) → lấy danh sách cột, data type, mô tả.
4. **Tất cả file LLD đã có** trong cùng source system (`docs/approved/.../lld/<SOURCE_SYSTEM>/`) → nắm:
   - Entity đã thiết kế và cấu trúc attribute
   - Pattern FK đã dùng (tên trường, data domain)
   - Shared entity đã có những trường nào
5. **LLD entity tương đồng từ source khác (nếu có):** Nếu entity đang thiết kế có kiểu tương đồng với entity đã thiết kế ở source khác (cùng BCV Concept, hoặc cùng loại shared entity), đọc ít nhất 1 file LLD tương ứng từ source đó. Mục đích: lấy đúng pattern tên attribute, format nullable, format source_columns, FK comment.
   - Ví dụ: thiết kế IP Postal Address cho FMS → đọc `lld/NHNCK/attr_NHNCK_Professionals_IP_Postal_Address.csv`.
   - Ví dụ: thiết kế entity [Involved Party] Organization → đọc `lld/DCST/attr_DCST_THONG_TIN_DK_THUE.csv`.
6. **File `ref_shared_entity_classifications.csv`** → kiểm tra Classification Value đã chuẩn hóa.
7. **File `manifest.csv`** → biết file LLD nào đã có.

### Bước 2 — Xác định Silver entity target và Tier

Từ HLD đã duyệt, xác định:
- Bảng nguồn này map về Silver entity nào?
- BCV Concept và Category đã gán?
- Quan hệ FK với entity nào?
- Entity này thuộc **Tier mấy**?

**Thứ tự thiết kế theo Tier:** Thiết kế và hoàn thành LLD Tier N trước khi bắt đầu Tier N+1. Entity Tier sau có FK đến entity Tier trước — cần LLD Tier trước để lấy đúng tên attribute FK.

### Bước 3 — Thiết kế attribute-level

Với mỗi trường trong bảng nguồn, quyết định:

#### 3a. Mô tả (description)
- Ghép 2 phần: **mô tả gốc từ CSDL nguồn (giữ nguyên)** + mô tả bổ sung trên model (nếu có).
- Không bỏ mô tả nguồn, không viết lại theo cách hiểu riêng.

#### 3b. Data Domain
Dùng đúng 1 trong 12 Data Domain chuẩn:

| Data Domain | Dùng cho |
|---|---|
| Text | Chuỗi ký tự thông thường |
| Date | Ngày (không có giờ) |
| Timestamp | Ngày + giờ |
| Currency Amount | Giá trị tiền tệ (KHÔNG viết tắt "Amount") |
| Interest Rate | Lãi suất |
| Exchange Rate | Tỷ giá |
| Percentage | Phần trăm |
| Surrogate Key | Khóa đại diện (FK Id) |
| Classification Value | Mã phân loại (FK Code đến Classification Value hoặc Currency) |
| Indicator | Cờ đánh dấu (Y/N, 0/1) |
| Boolean | True/False |
| Small Counter | Số đếm nhỏ |
| Array\<Text\> | Mảng chuỗi — dùng cho junction chỉ chứa code/text |
| Array\<Struct\> | Mảng struct — dùng cho junction chứa cặp Id + Code. Ghi schema struct vào comment: `Struct: {field1: Domain1; field2: Domain2}` |

#### 3c. FK đến Fundamental entity
- **Luôn tạo cặp [Entity] Id + [Entity] Code** — kể cả khi nullable.
- Id: data domain = Surrogate Key.
- Code: data domain = Text.
- Nếu Code = NULL thì Id cũng = NULL → cặp nhất quán.

#### 3d. Classification Value
- **Chỉ 1 trường Code** (data domain = Classification Value). KHÔNG tạo cặp Id + Code.
- Áp dụng cho: Classification Value, Currency, Calendar Date, mọi bảng danh mục SCD1 không có surrogate key.

#### 3e. PK nguồn và BK
- PK bảng nguồn (VD: ID) → map vào **Entity Code (BK)**, không đưa vào technical field.
- Mã nghiệp vụ khác có tính unique (VD: MA_SO_THUE) → trường nghiệp vụ riêng, không phải BK.

#### 3f. Source System Code
- Mô tả chi tiết đến mức tên bảng nguồn: `DCST.THONG_TIN_DK_THUE`, không chỉ ghi `DCST`.

#### 3g. Metadata nguồn
- Trường metadata truyền nhận (VD: GOI_TIN_ID) → trường nghiệp vụ bình thường, không đưa vào nhóm ds_.

#### 3h. Trường denormalized
- Trường chứa thông tin entity khác nhưng không có cơ chế link → giữ dạng text denormalized. Không đề xuất "map ở entity khác" nếu không có link thực tế.

#### 3i. Bảng junction denormalized theo HLD

Nếu HLD đã quyết định denormalize 1 bảng junction thành ARRAY trên entity cha:
- Thêm attribute vào file LLD của entity cha (không tạo file LLD riêng, không thêm vào manifest).
- `data_domain` = `Array<Text>` (junction chỉ có code) hoặc `Array<Struct>` (junction có cặp Id + Code)
- `source_columns` = FK phía bên kia của junction (VD: `FMS.SECBUSINES.BuId`)
- `comment`: tên bảng junction gốc + tham chiếu HLD + schema struct nếu là `Array<Struct>`. Mẫu: `Pure junction {TABLE} → denormalize thành ARRAY. Struct: {field1: Domain1; field2: Domain2}. HLD decision: {file HLD}.`
- Tên attribute: danh từ số nhiều phản ánh nội dung phần tử (VD: `Business Type Codes`, `Distribution Agent Ids`).

#### 3j. Merge entity từ 2 bảng nguồn 1-1 — xử lý cột duplicate

Khi 1 Silver entity gộp từ 2 bảng nguồn quan hệ 1-1 (VD: Public Company = company_profiles + company_detail), thường có các cột trùng giá trị (name VI/EN, business_reg_no, ticker, audit fields).

**Quy tắc:**
1. **Chọn 1 bảng làm primary source** cho các cột trùng — map `source_columns` từ bảng đó.
2. **Các cột trùng của bảng kia** phải document trong `pending_design.csv`:
   - `reason`: "Giá trị 1-1 với {primary_table}.{col}. Map primary từ {primary_table}."
   - `action`: "Đã capture qua {primary_table} (1-1)"
3. **KHÔNG** ghi `"X.col1, Y.col2"` trong `source_columns`. Script `post_check_silver.py` C5 kiểm tra format đúng 3 phần `SOURCE.table.column` → sẽ báo lỗi.
4. **PK kỹ thuật của bảng phụ** (VD: company_detail.id) cũng document pending: "PK kỹ thuật riêng của bảng detail, không phải BK của entity."
5. Nếu đây là entity shared giữa nhiều source system, xem xét HLD Tier tương ứng cho quy tắc merge tương tự.

### Bước 4 — Rà soát shared entity

Nếu bảng nguồn có grain = 1 Involved Party:
- Trường địa chỉ → **IP Postal Address**
- Trường liên lạc → **IP Electronic Address**
- Trường giấy tờ → **IP Alt Identification**

**Involved Party bao gồm cả cá nhân lẫn tổ chức.** Không phân biệt loại IP — chỉ cần entity chính đang mô tả 1 IP (cá nhân, tổ chức, công ty, chi nhánh...) là phải tách shared entity. Ví dụ: Securities Company Senior Personnel (cá nhân), Securities Company (tổ chức), Securities Company Organization Unit (chi nhánh) — đều phải tách địa chỉ/liên lạc sang shared entity.

Quy tắc grain = Involved Party luôn áp dụng, không phụ thuộc HLD Tier có liệt kê shared entity hay không. Nếu HLD Tier chưa có shared entity tương ứng, đồng bộ tài liệu sau khi thiết kế LLD:
1. Thêm dòng vào `manifest.csv`: `<SOURCE>,<table>,Involved Party {Postal Address|Electronic Address|Alternative Identification},<Tier>,<lld_file>`.
2. Cập nhật `source_table` trong HLD Overview và HLD Tier tương ứng.
3. Ghi 1 dòng vào "Điểm cần xác nhận" của HLD Tier mô tả quyết định tách shared entity.

Kiểm tra `ref_shared_entity_classifications.csv` để dùng đúng Code đã chuẩn hóa. Nếu có giá trị mới chưa có → thêm vào ref file ngay, không để lại.

Schema shared entity cố định — chỉ chứa các trường liệt kê trong bảng tên trường chuẩn bên dưới. Shared entity không có PK surrogate riêng (chỉ FK về entity chính), không có audit fields, không có business flag. Cột nguồn không map được vào schema chuẩn (PK kỹ thuật của bảng nguồn, audit fields, business flag như `primary_flg`, `is_active`...) document trong `pending_design.csv`:
- PK kỹ thuật: "Shared entity không có PK surrogate riêng — chỉ FK về entity chính."
- Audit fields: "Shared entity schema chuẩn không có audit fields."
- Business flag: "Cân nhắc tính tại Gold hoặc bổ sung schema shared entity (ảnh hưởng mọi nguồn)."

---

**Tên trường chuẩn cho IP Alt Identification** — bắt buộc dùng đúng tên này:

| Trường | Tên chuẩn | Data Domain |
|---|---|---|
| FK chính | `Involved Party Id` | Surrogate Key |
| FK BK | `Involved Party Code` | Text |
| Nguồn | `Source System Code` | Classification Value |
| Loại giấy tờ | `Identification Type Code` | Classification Value |
| Số giấy tờ | `Identification Number` | Text |
| Ngày cấp | `Issue Date` | Date |
| Nơi cấp | `Issuing Authority Name` | Text |

**Tên trường chuẩn cho IP Postal Address** — bắt buộc dùng đúng tên này:

| Trường | Tên chuẩn | Data Domain |
|---|---|---|
| FK chính | `Involved Party Id` | Surrogate Key |
| FK BK | `Involved Party Code` | Text |
| Nguồn | `Source System Code` | Classification Value |
| Loại địa chỉ | `Address Type Code` | Classification Value |
| Địa chỉ text | `Address Value` | Text |
| FK địa lý (có lookup) | `{Semantic Prefix} Id` | Surrogate Key |
| Mã địa lý (có lookup) | `{Semantic Prefix} Code` | Text |
| Quận/huyện text | `District Name` | Text |
| Mã quận/huyện | `District Code` | Text |
| Phường/xã text | `Ward Name` | Text |
| Mã phường/xã | `Ward Code` | Text |
| Tỉnh/thành text | `Province Name` | Text |
| Mã tỉnh text | `Province Code` | Text |

> Không phải mọi source đều có đủ các trường trên — chỉ map những trường có dữ liệu nguồn. FK địa lý (có lookup) dùng khi source có bảng lookup tường minh; `Province/District/Ward Name/Code` dùng khi nguồn lưu text denormalized không có lookup.
>
> **Quy tắc đặt tên `{Semantic Prefix}`**: Dùng prefix ngữ nghĩa cụ thể theo vai trò của trường địa lý trong entity — **KHÔNG** dùng "Geographic Area" trong tên attribute. Ví dụ: `Province Id/Code` (tỉnh/thành trong địa chỉ), `Nationality Id/Code` (quốc tịch cá nhân), `Country of Registration Id/Code` (quốc gia đăng ký tổ chức), `Country of Residence Id/Code` (quốc gia cư trú). Tên "Geographic Area" là tên kỹ thuật của Silver entity — không lộ ra trong tên attribute của entity khác.

---

**Tên trường chuẩn cho IP Electronic Address** — bắt buộc dùng đúng tên này:

| Trường | Tên chuẩn | Data Domain |
|---|---|---|
| FK chính | `Involved Party Id` | Surrogate Key |
| FK BK | `Involved Party Code` | Text |
| Nguồn | `Source System Code` | Classification Value |
| Loại kênh | `Electronic Address Type Code` | Classification Value |
| Giá trị | `Electronic Address Value` | Text |

> Mỗi loại kênh (PHONE, FAX, EMAIL, WEBSITE, EMAIL_DISCLOSURE...) là 1 cặp `Electronic Address Type Code` + `Electronic Address Value` riêng trong file.

---

**Quy tắc `classification_context` cho shared entity:**

Mọi attribute trong file shared entity bắt buộc có `classification_context` với format `SCHEME=VALUE` — không để bare. Bare context khiến aggregate mất mapping silent khi shared entity merge từ nhiều source.

Chọn value theo nguồn:
- Nguồn có cột type động qua lookup (VD: `identity_type_cd` → CMND/CCCD/Hộ chiếu/GPKD) → dùng placeholder `(source)`: `IP_ALT_ID_TYPE=(source)`. ETL map value runtime.
- Nguồn cố định 1 loại (VD: chỉ có cột `phone_no` = PHONE) → hardcode: `IP_ELEC_ADDR_TYPE=PHONE`.

Scheme áp dụng: `IP_ADDR_TYPE` (IP Postal Address), `IP_ELEC_ADDR_TYPE` (IP Electronic Address), `IP_ALT_ID_TYPE` (IP Alt Identification).

Ví dụ shared entity type động:
```csv
Identification Type Code,...,Classification Value,false,false,draft,IDS.identity.identity_type_cd,"Scheme: IP_ALT_ID_TYPE. ETL map từ scheme nguồn sang scheme chuẩn.",IP_ALT_ID_TYPE=(source),
Identification Number,...,Text,true,false,draft,IDS.identity.identity_no,,IP_ALT_ID_TYPE=(source),
Issue Date,...,Date,true,false,draft,IDS.identity.identity_issued_date,,IP_ALT_ID_TYPE=(source),
```

Trường hợp nguồn có `identity_no` nhưng không có cột type phân biệt: dùng `IP_ALT_ID_TYPE=NATIONAL_ID` làm default. Document trong `pending_design.csv` (`reason="Nguồn không phân biệt loại giấy tờ"`, `action="Cần profile data nguồn để xác định loại giấy tờ thực tế"`) và thêm 1 điểm xác nhận vào HLD Tier tương ứng.

Nếu grain KHÔNG phải Involved Party → **KHÔNG tách**, giữ denormalized. Ví dụ: snapshot tờ khai thuế, quyết định hành chính, log kỹ thuật — địa chỉ trong các entity này là denormalized hợp lệ.

#### 4a. Quy tắc trường địa lý (quốc gia / tỉnh / huyện / xã)

Trường chứa mã địa lý có 3 cách xử lý — chọn theo bối cảnh nguồn:

| Bối cảnh | Xử lý | Ví dụ |
|---|---|---|
| Bảng nguồn có bảng lookup địa lý rõ ràng trong cùng hệ thống (VD: FIMS.NATIONAL) | **FK pair** đến Silver entity **Geographic Area** — đặt tên theo ngữ nghĩa (xem quy tắc bên dưới) | FIMS: NaId → `Nationality Id/Code`; SCMS: TINH_THANH_ID → `Province Id/Code` |
| Dữ liệu phản hồi từ API ngoài (C06, VNPT...) hoặc nguồn không có bảng lookup trong scope | **Classification Value** với scheme riêng, ghi rõ `(no_lookup)` trong ref — không tạo FK | NHNCK: COUNTRY, PROVINCE, DISTRICT |
| Nguồn có bảng lookup (provinces/countries) nhưng HLD chưa thiết kế lookup đó vào Silver Geographic Area trong cùng Tier | **Text** denormalized với comment ghi rõ "provinces/countries là reference data set chưa map vào shared Geographic Area trong scope {SOURCE}" | IDS: `head_office_prov`, `nationality` |
| Trường địa lý trong địa chỉ, nguồn ghi kèm cả Name (không resolve được) | **Text** denormalized — giữ cả Code lẫn Name | DCST IP_Postal_Address: Province Code/Name |

**Geographic Area là Silver entity** ([Location] Geographic Area) — chứa danh mục khu vực địa lý đa cấp (quốc gia/vùng/tỉnh/huyện/xã). Chỉ tạo FK đến đây khi có bảng lookup tường minh trong scope thiết kế.

**Quy tắc đặt tên FK đến Geographic Area**: Dùng prefix ngữ nghĩa cụ thể — **KHÔNG** dùng "Geographic Area" trong tên attribute. Tham chiếu comment vẫn ghi `FK target: Geographic Area.Geographic Area Id`.

| Ngữ nghĩa | Tên Id | Tên Code |
|---|---|---|
| Quốc tịch cá nhân | `Nationality Id` | `Nationality Code` |
| Quốc gia đăng ký tổ chức | `Country of Registration Id` | `Country of Registration Code` |
| Quốc gia cư trú | `Country of Residence Id` | `Country of Residence Code` |
| Tỉnh/thành phố | `Province Id` | `Province Code` |
| Quận/huyện (có lookup) | `District Id` | `District Code` |
| Các ngữ nghĩa khác | `{Vai trò cụ thể} Id` | `{Vai trò cụ thể} Code` |

### Bước 5 — Viết comment

Thứ tự: tag automation trước, notes sau.

**FK đến Fundamental entity:**
- Id: `FK target: {Silver Entity Name}.{Target Attribute Name}. {notes}`
- Code: `FK target: {Silver Entity Name}.{Target Attribute Name}. Pair with {Id field name}. {notes}`
- Currency Code: `FK target: Currency.Currency Code. {notes}`

**Classification Value:**
- `Scheme: {SCHEME_CODE}. {notes}`
- Scheme Code = UPPER_SNAKE_CASE, nhất quán với `ref_shared_entity_classifications.csv`.
- KHÔNG dùng cả `FK target:` và `Scheme:` cho cùng 1 trường.
- **Bắt buộc cross-check**: Mọi Scheme Code dùng trong LLD phải tồn tại trong `ref_shared_entity_classifications.csv`. Nếu chưa có → thêm vào ref file ngay trong cùng lượt thiết kế, trước khi xuất attr file.

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
- [ ] Tên attribute cùng ý nghĩa với LLD source khác đã có → dùng đúng tên đó (ví dụ: `Charter Capital Amount`, `Life Cycle Status Code`...)?
- [ ] **Entity dùng chung nhiều source**: attribute tên công ty/tên tắt/tên tiếng Anh phải dùng **prefix entity** nhất quán giữa mọi source (VD: `Fund Management Company Name`, `Custodian Bank Short Name`) — KHÔNG dùng `Full Name` / `Abbreviation` / `English Name` cho entity shared?
- [ ] Format nullable nhất quán: `true`/`false` — không dùng `Yes`/`No`?
- [ ] Format source_columns nhất quán: fully qualified `SOURCE_SYSTEM.schema.Table.Column`?
- [ ] Shared entity: FK dùng `Involved Party Id` / `Involved Party Code` — không dùng tên entity cha?
- [ ] Bảng junction denormalized theo HLD → attribute ARRAY đã thêm vào entity cha, không có trong manifest?
- [ ] **Cross-check scheme**: Mọi `Scheme: XYZ` trong cột comment và mọi `XYZ=` trong cột classification_context đều có trong `ref_shared_entity_classifications.csv`? Nếu thiếu → thêm vào ref trước khi kết thúc.
- [ ] **Trường địa lý**: mã quốc gia/tỉnh/huyện/xã được xử lý đúng theo bối cảnh nguồn (FK Geographic Area / Classification Value no_lookup / Text denormalized)?
- [ ] **Shared entity type động**: Nếu nguồn có cột type qua lookup_values (identity_type_cd, v.v.) → đã dùng `SCHEME=(source)` placeholder chưa? Không để bare context (gây mất mapping silent).
- [ ] **Shared entity — cột không map**: PK kỹ thuật / audit fields / business flag của bảng nguồn shared đã được document trong `pending_design.csv`?
- [ ] **Merge entity 1-1**: source_columns KHÔNG dùng format comma-separated `"X.col1, Y.col2"` — chỉ 1 bảng primary, bảng còn lại document pending?
- [ ] **Manifest encoding**: `manifest.csv` không có BOM (strip trước khi chạy aggregate)?
- [ ] **Post-check**: Sau khi chạy aggregate, chạy `post_check_silver.py` và xử lý mọi warning trước khi kết thúc Tier?
- [ ] **Source coverage**: chạy `post_check_source_coverage.py --source <SOURCE>` — mọi bảng đã thiết kế đều có 100% cột map (hoặc pending với reason rõ)?

## OUTPUT

### File LLD (.csv)

**Tên file:** `attr_<SOURCE_SYSTEM>_<SourceTableName>.csv`
**Mỗi file = 1 bảng nguồn.**

**Cấu trúc cột — non-shared entity:**
```
attribute_name,description,data_domain,nullable,is_primary_key,status,source_columns,comment,classification_context,etl_derived_value
```
- `etl_derived_value`: để rỗng nếu không có giá trị ETL-derived cố định.

**Cấu trúc cột — shared entity (IP Postal Address / IP Electronic Address / IP Alt Identification):**

Grain: **1 dòng = 1 silver_attribute × 1 classification_context**. Attribute lặp lại nếu có nhiều context.

- `classification_context` — format nội bộ trong attr_*.csv: `SCHEME=VALUE`. VD: `IP_ADDR_TYPE=HEAD_OFFICE`, `SOURCE_SYSTEM=FMS.SECURITIES`. Script `aggregate_silver.py` tự convert sang format output `Field Name = 'VALUE'` khi ghi vào `silver_attributes.csv` — người thiết kế chỉ cần viết format nội bộ.
- `etl_derived_value`: giá trị cố định ETL-derived (không từ cột nguồn). VD: `UBCKNN`.

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
Involved Party Id,FK đến Securities Practitioner.,Surrogate Key,false,false,draft,NHNCK.qlnhn.Professionals.Id,FK target: ...,,
Involved Party Code,Mã người hành nghề.,Text,false,false,draft,NHNCK.qlnhn.Professionals.Id,FK target: ...,,
Source System Code,Mã nguồn dữ liệu.,Classification Value,false,false,draft,,,SOURCE_SYSTEM=NHNCK.Professionals,
Electronic Address Type Code,Loại kênh liên lạc — điện thoại.,Classification Value,false,false,draft,,,IP_ELEC_ADDR_TYPE=PHONE,
Electronic Address Value,Số điện thoại.,Text,true,false,draft,NHNCK.qlnhn.Professionals.Phone,,IP_ELEC_ADDR_TYPE=PHONE,
Electronic Address Type Code,Loại kênh liên lạc — email.,Classification Value,false,false,draft,,,IP_ELEC_ADDR_TYPE=EMAIL,
Electronic Address Value,Email.,Text,true,false,draft,NHNCK.qlnhn.Professionals.Email,,IP_ELEC_ADDR_TYPE=EMAIL,
```

### Cập nhật manifest.csv

1. Đọc toàn bộ `lld/manifest.csv` hiện tại.
2. Thêm dòng mới cho file LLD vừa tạo.
3. Xuất **1 file duy nhất** tên `manifest.csv` chứa toàn bộ cũ + mới.

**Cấu trúc:** `source_system,source_table,silver_entity,group,lld_file`

- `silver_entity`: tên Silver entity đích — phải khớp với `silver_entities.csv`.
- `group`: tier nhóm (`T1`, `T2`, `T3`, `T4`).
- `lld_file`: tên file attr_*.csv tương ứng.

**Encoding:** `manifest.csv` phải là UTF-8 không BOM. Nếu chạy aggregate gặp `KeyError: 'source_system'`, kiểm tra và strip BOM trước khi chạy lại.

### Cập nhật ref_shared_entity_classifications.csv

1. Đọc toàn bộ file hiện tại.
2. Bổ sung scheme/giá trị mới phát sinh.
3. Xuất **1 file duy nhất** chứa toàn bộ cũ + mới.

**Cấu trúc:** `scheme_code,code,name,source_type,source_table,used_in_entities`

**3 loại source_type:**
- `etl_derived`: team tự định nghĩa → liệt kê đầy đủ code + name.
- `source_table`: values load từ bảng danh mục nguồn → ghi `(source)` ở cột code, ghi source table.
- `modeler_defined`: trường text nguồn cần chuẩn hóa, chưa profile → ghi `(to_define)`.

### Cập nhật silver_attributes.csv và silver_entities.csv

**KHÔNG ghi thủ công vào 2 file này.** Sau khi hoàn thành toàn bộ attr_*.csv và manifest.csv của Tier, chạy script:

```bash
cd <workspace_root>
python Silver/lld/scripts/aggregate_silver.py
```

Script tự động:
- Đọc `manifest.csv` → biết toàn bộ entity và file LLD
- Đọc `Silver/hld/silver_entities.csv` → lấy `bcv_core_object` cho mỗi entity
- Đọc từng `attr_*.csv` → thu thập attributes
- Gộp shared entities (IP Alt Identification, IP Postal Address, IP Electronic Address) từ mọi source → 1 dòng duy nhất mỗi attribute, source_column merge
- Sort: `bcv_core_object` (A→Z) → `silver_entity` (A→Z) → thứ tự attribute giữ nguyên
- Preserve description đã điền thủ công trong `silver_entities.csv`
- Ghi đè cả 2 file output

**Kiểm tra sau khi chạy:** Script in ra số rows — báo cáo con số này cho người thiết kế xác nhận.

### Bước 7 — Post-check sau khi aggregate

Chạy script để phát hiện lỗi thiết kế trong `silver_attributes.csv`:

```bash
python Silver/lld/scripts/post_check_silver.py
```

Script kiểm tra 5 tiêu chí và in báo cáo — không sửa file nào.

**Bảng xử lý kết quả:**

| Check | Mô tả | Nguyên nhân phổ biến | Hành động |
|---|---|---|---|
| C1 | Source không map được attr nào | Source mới thêm vào manifest chưa có file attr | Tạo file attr cho source đó, chạy lại aggregate |
| C2 | Thông tin liên lạc/địa chỉ trong entity chính | Quên tách shared entity ở Bước 4 | Tách trường sang IP Postal/Electronic Address, xóa khỏi entity chính |
| C3 | Cùng tên attr nhưng data_domain khác nhau giữa các entity | Typo hoặc copy sai data domain từ entity khác | Sửa domain về giá trị chuẩn trong 12 Data Domain |
| C4 | PK có nullable=true | Copy sai từ trường khác | Đặt `nullable=false` cho PK |
| C5 | source_column không đúng 3 phần | Thừa schema (VD: `SCMS.scms.table.col`) hoặc thiếu source prefix | Sửa về đúng `SOURCE.table.column` |

---

### Bước 7b — Post-check phủ sóng cột nguồn

Kiểm tra cột nguồn chưa được map vào Silver cho các bảng đã thiết kế:

```bash
# Kiểm tra tất cả nguồn
python Silver/lld/scripts/post_check_source_coverage.py

# Chỉ kiểm tra 1 nguồn
python Silver/lld/scripts/post_check_source_coverage.py --source SCMS

# Chỉ kiểm tra 1 bảng
python Silver/lld/scripts/post_check_source_coverage.py --table CTCK_THONG_TIN
```

Script đọc `Source/<SOURCE>_Columns.csv` (danh sách cột thực tế của nguồn), so sánh với `silver_attributes.csv`, báo cáo cột chưa map — không sửa file nào. Bỏ qua group=pending trong manifest và bỏ qua các cột kỹ thuật/audit tự động.

**Bảng xử lý kết quả:**

| Loại cột báo cáo | Nguyên nhân phổ biến | Hành động |
|---|---|---|
| Cột nghiệp vụ thực sự chưa map | Bỏ sót khi thiết kế | Tạo/cập nhật attr file, chạy lại aggregate |
| Cột liên lạc/địa chỉ (DIEN_THOAI, EMAIL, DIA_CHI...) | Chưa tạo shared entity | Tạo file IP Postal/Electronic Address, thêm vào manifest |
| FK đến bảng khác (ID, *_ID) | FK thuần — giá trị đã capture qua entity cha | Bỏ qua, ghi chú "FK only" nếu cần |
| Cột out-of-scope theo business | Cố ý không map | Thêm vào `SKIP_COLUMNS` trong script HOẶC ghi rõ lý do bỏ qua |
| Cột audit/kỹ thuật chưa có trong SKIP_COLUMNS | Pattern mới của nguồn | Thêm vào `SKIP_COLUMNS` trong script |

### Quy tắc output

- **Mọi attr file đều phải là file CSV, encoding UTF-8 BOM (`utf-8-sig`).** Excel trên Windows mở trực tiếp không bị lỗi ký tự. Không tạo file md hay text tóm tắt kèm theo.
- Ghi attr file vào `Silver/lld/<SOURCE_SYSTEM>/`.
- Nếu `manifest.csv` hoặc `ref_shared_entity_classifications.csv` bị cắt ngắn khi đọc → đọc lại cho đến khi có đủ toàn bộ nội dung trước khi tạo file output.
- `silver_attributes.csv` và `silver_entities.csv` **không cần đọc** trước khi chạy script — script tự xử lý.

## QUY TẮC ĐẶT TÊN ATTRIBUTE

### Prefix nhất quán trong nhóm trường
Nhiều trường cùng nhóm thông tin → dùng chung prefix.
- VD: Reporting Period Type Code, Reporting Period, Reporting Period Start Date, Reporting Period End Date.

### Prefix chủ thể
Entity chứa nhóm trường mô tả chủ thể khác (không phải chủ thể chính) → thêm prefix chỉ rõ.
- VD: entity "Related Party" → `Related Individual Full Name`, `Related Individual Birth Year`.
- KHÔNG áp dụng cho snapshot từ entity cha đã có FK.

### Scope entity
Không giả định scope từ tên bảng. Đọc kỹ mô tả nguồn trước.
- VD: THONG_TIN_DK_THUE = "thông tin đăng ký thuế" (tổ chức, DN, hộ KD) → không gắn prefix "Organization".
