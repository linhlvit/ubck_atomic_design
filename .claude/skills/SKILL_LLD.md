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
5. **File `ref_shared_entity_classifications.csv`** → kiểm tra Classification Value đã chuẩn hóa.
6. **File `manifest.csv`** → biết file LLD nào đã có.

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

### Bước 4 — Rà soát shared entity

Nếu bảng nguồn có grain = 1 Involved Party:
- Trường địa chỉ → **IP Postal Address**
- Trường liên lạc → **IP Electronic Address**
- Trường giấy tờ → **IP Alt Identification**

Kiểm tra `ref_shared_entity_classifications.csv` để dùng đúng Code đã chuẩn hóa. Nếu có giá trị mới chưa có → **ghi rõ trong output** danh sách cần bổ sung.

Shared entity **không có PK surrogate riêng** — chỉ FK trỏ về entity chính.

Nếu grain KHÔNG phải Involved Party → **KHÔNG tách**, giữ denormalized.

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

## OUTPUT

### File LLD (.csv)

**Tên file:** `attr_<SOURCE_SYSTEM>_<SourceTableName>.csv`
**Mỗi file = 1 bảng nguồn.**

**Cấu trúc cột:**
```
attribute_name,description,data_domain,nullable,is_primary_key,status,source_columns,comment
```

**Ví dụ:**
```csv
attribute_name,description,data_domain,nullable,is_primary_key,status,source_columns,comment
Securities Practitioner Id,Khóa đại diện cho NHN.,Surrogate Key,No,Yes,approved,,
Securities Practitioner Code,"Mã NHN do UBCKNN cấp. Map từ PK bảng nguồn.",Text,No,No,approved,Professionals.ID,"BCV Term: Individual Identifier. BK của entity."
Source System Code,"Mã hệ thống nguồn. TOMIC.Professionals",Classification Value,No,No,approved,,"Scheme: SOURCE_SYSTEM."
```

### Cập nhật manifest.csv

1. Đọc toàn bộ `lld/manifest.csv` hiện tại.
2. Thêm dòng mới cho file LLD vừa tạo.
3. Xuất **1 file duy nhất** tên `manifest.csv` chứa toàn bộ cũ + mới.

**Cấu trúc:** `source_system,source_table,silver_entity,bcv_concept,group,lld_file,status`

### Cập nhật ref_shared_entity_classifications.csv

1. Đọc toàn bộ file hiện tại.
2. Bổ sung scheme/giá trị mới phát sinh.
3. Xuất **1 file duy nhất** chứa toàn bộ cũ + mới.

**Cấu trúc:** `scheme_code,code,name,source_type,source_table,used_in_entities`

**3 loại source_type:**
- `etl_derived`: team tự định nghĩa → liệt kê đầy đủ code + name.
- `source_table`: values load từ bảng danh mục nguồn → ghi `(source)` ở cột code, ghi source table.
- `modeler_defined`: trường text nguồn cần chuẩn hóa, chưa profile → ghi `(to_define)`.

### Quy tắc output

- **Mọi output đều phải là file CSV.** Không tạo file md hay text tóm tắt kèm theo.
- Ghi file vào `docs/approved/<project>/Silver/lld/<SOURCE_SYSTEM>/`.
- Nếu `manifest.csv` hoặc `ref_shared_entity_classifications.csv` bị cắt ngắn khi đọc → đọc lại với cách khác cho đến khi có đủ toàn bộ nội dung trước khi tạo file output.

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
