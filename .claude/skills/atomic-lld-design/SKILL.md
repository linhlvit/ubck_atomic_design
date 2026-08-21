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

## QUY TẮC CỨNG — KHÔNG GENERATE KHI CÒN LLD/ENTITY CHƯA APPROVED

**Áp dụng cho MỌI lần chạy `generate_entity_consolidation.py`, `generate_dm_yaml.py`,
`gen_summary_and_model.py`** (Bước 9, 10, 11) — kể cả khi chỉ cần regenerate lại để phản ánh 1
comment/1 attribute vừa sửa, và kể cả khi thao tác giữa hội thoại không đi qua đủ Bước 0–9 từ đầu.

**Vì sao phải tự kiểm tra thủ công, không được ỷ lại script:** `aggregate_atomic.py` và
`generate_dm_yaml.py` **KHÔNG filter theo `design_status`** — đọc source 2 script này xác nhận
không có bất kỳ điều kiện nào lọc `draft`/`reviewed` trước khi ghi output; chúng generate từ MỌI
`lld_*.yaml`/`entity_*.yaml` tìm thấy, bất kể trạng thái duyệt. Nếu AI không tự chặn trước khi gọi
lệnh, không có gì chặn cả — dữ liệu chưa qua review con người sẽ lọt thẳng vào
`DataModel/Atomic/`.

**Thực tế đã xảy ra (2026-07-29, sửa comment FK crosswalk module NHNCK/SCMS/IDS):** đã chạy
`generate_dm_yaml.py --source IDS` trong khi `lld_IDS_COMPANY_PROFILES_IP_Postal_Address.yaml`
còn `design_status: draft` — sinh `dm_atm_ip_postal_address-IDS.COMPANY_PROFILES.yaml` từ dữ liệu
chưa approved mà không có cảnh báo nào dừng lại đúng lúc.

**Quy trình bắt buộc trước khi chạy BẤT KỲ lệnh nào trong Bước 9, 10, 11:**

1. Xác định phạm vi bị ảnh hưởng bởi lệnh sắp chạy:
   - `generate_dm_yaml.py --source X` → toàn bộ `lld_*.yaml` của source X, **cộng thêm** mọi
     source khác đóng góp vào shared entity (`entity_*.yaml`) mà X là 1 nguồn trong đó.
   - `generate_entity_consolidation.py --entity Y` (hoặc chạy không kèm `--entity`) → toàn bộ
     `lld_*.yaml` liệt kê trong `sources:` của entity Y (hoặc mọi entity nếu chạy full).
   - `gen_summary_and_model.py` → toàn bộ dự án.
2. Với từng file trong phạm vi đó, đọc `design_status` (hoặc `consolidation_status` với entity
   file) — dùng `grep design_status` trực tiếp trên từng file hoặc `manifest.yaml`, không suy đoán.
3. Nếu **còn bất kỳ file nào `draft` hoặc `reviewed`** (chưa `approved`):
   - **DỪNG — KHÔNG chạy `--source`/full generate trực tiếp.**
   - Liệt kê rõ danh sách file/bảng chưa approved cho người dùng.
   - Hỏi xác nhận tường minh (AskUserQuestion hoặc tương đương), ưu tiên theo thứ tự:
     (a) **approved-only regen** (xem kỹ thuật bên dưới) — mặc định đề xuất trước tiên, an toàn
     nhất, không cần user tự đi approve thủ công trước;
     (b) approve các file còn lại trước rồi quay lại chạy full;
     (c) chấp nhận generate luôn dù còn draft (rủi ro trộn dữ liệu chưa duyệt vào Atomic output);
     (d) hủy thao tác. **AI không được tự ý chọn (c) thay người dùng.**
4. Chỉ chạy lệnh khi mọi file trong phạm vi đã `approved`, đã lọc approved-only theo kỹ thuật dưới
   đây, hoặc người dùng đã tường minh xác nhận chấp nhận rủi ro ở bước 3.

**Kỹ thuật approved-only regen (đã dùng thành công cho SCMS 2026-07-27 và FMS 2026-07-28 — AN
TOÀN, KHÔNG bao giờ ghi đè `manifest.yaml`):** viết 1 script wrapper `importlib` module
`aggregate_atomic.py` trực tiếp, gọi `load_manifest()` bình thường rồi **lọc list kết quả trong
Python** (giữ nguyên mọi entry không thuộc phạm vi đang generate; với source/entity đang xét chỉ
giữ entry có `design_status: approved` trong file LLD tương ứng), sau đó gọi thẳng
`build_entities()`/`build_attributes()`/`write_*_yaml()` của module gốc với list đã lọc. File
`manifest.yaml` trên đĩa **không bao giờ** bị mở ở chế độ ghi — chỉ `atomic_attributes.yaml`/
`atomic_entities.yaml` (working file, được phép ghi đè) bị ảnh hưởng tạm thời. Sau khi
`generate_dm_yaml.py --source {SOURCE}` + `validate_dm_yaml.py --source {SOURCE}` xong với dữ
liệu đã lọc, chạy lại `aggregate_atomic.py` **KHÔNG filter** (bản gốc, đầy đủ) để phục hồi 2 file
working về trạng thái đầy đủ toàn bộ manifest. KHÔNG sửa trực tiếp `manifest.yaml` để loại entry
draft rồi phục hồi sau — cách này từng bị chặn và rủi ro hỏng file nguồn quan trọng nhất của
pipeline.

Rule này áp dụng **bất kể** có gọi qua Skill tool đầy đủ từ đầu hay không.

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

### Bước 2c — Kiểm tra bộ trường audit/system chuẩn (technical bundle)

Trước khi thiết kế attribute, kiểm tra danh sách cột của bảng nguồn đang xét với bộ 9 cột sau
(không phân biệt hoa/thường):

`STATUS, DELETED, CREATED_AT, UPDATED_AT, CREATED_BY_ID, CREATED_BY_NAME, UPDATED_BY_ID, UPDATED_BY_NAME, VERSION`

| Tình huống | Hành động |
|---|---|
| Bảng nguồn có **ĐỦ CẢ 9 cột** | **Loại trừ hoàn toàn** — KHÔNG thiết kế Atomic attribute cho 9 cột này. Ghi **9 dòng riêng** (1 dòng/cột, không gộp comma-list) vào `pending_design.yaml`. |
| Bảng nguồn có **MỘT PHẦN** bộ 9 cột (thiếu ≥1 cột) | KHÔNG tự loại trừ. Thiết kế attribute bình thường cho các cột đang có, đồng thời ghi 1 dòng vào mục "Điểm cần xác nhận" của HLD Tier tương ứng: liệt kê cột nào có/thiếu, đề nghị Data Modeler xác nhận đây có phải business field thật (VD: `STATUS` có thể là trạng thái nghiệp vụ) hay chỉ là audit bundle không đầy đủ. |

**Mẫu ghi `pending_design.yaml` khi loại trừ đủ bộ (lặp lại cho từng cột trong 9 cột):**

```yaml
  - source_system: "{SOURCE}"
    source_table: "{TABLE}"
    source_column: "STATUS"
    description: "Cột trạng thái bản ghi (technical bundle)"
    reason: "Đủ bộ 9 cột audit/soft-delete/optimistic-locking chuẩn (STATUS, DELETED, CREATED_AT, UPDATED_AT, CREATED_BY_ID, CREATED_BY_NAME, UPDATED_BY_ID, UPDATED_BY_NAME, VERSION) — loại trừ theo quy tắc Bước 2c."
    action: "Excluded — standard technical bundle. Không thiết kế Atomic attribute."
```

**Phân biệt với Bước 3k (Audit block chuẩn):** Bước 3k áp dụng cho pattern T24/legacy
(`CREATED_AT/CREATED_BY/UPDATED_AT/UPDATED_BY` — 1 field BY dùng chung cho cả Id/Name, MAP vào 6
attribute chuẩn có FK hash). Bước 2c áp dụng cho pattern app hiện đại, tách riêng
`..._BY_ID`/`..._BY_NAME`, kèm `STATUS`/`DELETED`/`VERSION` — khi đủ bộ thì KHÔNG map, không phải
map-rồi-derive-FK. Hai bước không xung đột: nếu bảng chỉ có
`CREATED_AT/CREATED_BY/UPDATED_AT/UPDATED_BY` (không có `..._BY_ID/..._BY_NAME`, không có
`STATUS/DELETED/VERSION`) → vẫn dùng Bước 3k như cũ.

### Bước 3 — Thiết kế attribute-level

Copy [`templates/lld_main_entity.yaml`](templates/lld_main_entity.yaml) làm starting point. Replace placeholder, điền từng attribute theo quy tắc dưới. Sinh `physical_name` cho mỗi attribute theo quy tắc B (join full word + file ngoại lệ) tại mục **[QUY TẮC ĐẶT `physical_name`](#quy-tắc-đặt-physical_name)** bên dưới. `data_type` để trống — `transform_physical_names.py` sẽ tự điền dựa vào `data_domain`.

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
- Số đếm/version → `Small Counter`
- Ý nghĩa là mã phân loại → `Classification Value`; FK surrogate → `Surrogate Key`
- Không thuộc các loại trên → `Text`

**`Boolean` vs `Classification Value` cho cột cờ/trạng thái nguồn dạng số:** KHÔNG mặc định dùng
`Boolean` cho mọi cờ True/False. Đối chiếu domain đã chọn với **data type nguồn** (đây là ngoại lệ
so với nguyên tắc "ưu tiên ngữ nghĩa" ở trên):
- Nguồn là kiểu boolean/bit thật (`BIT`, `BOOLEAN`) không kèm mã nghiệp vụ → `Boolean`.
- Nguồn là `NUMBER`/mã số có ý nghĩa nghiệp vụ gắn với từng giá trị cụ thể (kể cả chỉ 2 giá trị,
  VD `STATUS: 1=Đang hoạt động, 0=Không hoạt động`) → `Classification Value`, đăng ký scheme, dù
  bản chất là cờ 2 trạng thái. Lý do: nhất quán với các trường cùng hình dạng đã thiết kế trong dự án
  (`STATUS_WORK`, `STATUS_ACCOUNT`, `GENDER`... đều là `NUMBER` 2 giá trị nhưng dùng `Classification
  Value`, không dùng `Boolean`) — tránh 2 domain khác nhau cho cùng 1 hình dạng dữ liệu nguồn.

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
  | `SOURCE_SYSTEM=SRC.TABLE` | Điền literal `SRC_TABLE` — **gạch dưới, KHÔNG dùng dấu chấm** (VD: `SOURCE_SYSTEM=NHNCK.PROFESSIONALS` → `NHNCK_PROFESSIONALS`). `classification_context` vẫn giữ dấu chấm như cũ — chỉ đổi giá trị lưu ở `etl_derived_value`. |
  | `SCHEME` (không có `=VALUE`, dynamic — VD: `IP_ADDR_TYPE`) | **Luôn để null** — KHÔNG ghi expression mapping CODE=VALUE. Toàn bộ mapping Code→Value của Classification Value đã được quản lý tập trung tại `classification_schemes.yaml` (và bảng Fundamental `cl_value`) — không lặp lại ở `etl_derived_value` từng attribute. |
  | Không có `classification_context` | Để null |

  > **Lưu ý quan trọng — IP Postal Address:** Nếu bảng nguồn **chỉ có 1 loại địa chỉ cụ thể** (VD: chỉ có `PERMANENT_ADDRESS`, không có cột address_type), KHÔNG dùng bare `IP_ADDR_TYPE` — phải hardcode: `IP_ADDR_TYPE=PERMANENT`. Bare context khiến aggregate bỏ sót `Address Type Code` khi merge nhiều source. Chỉ dùng `IP_ADDR_TYPE` (bare/dynamic) khi nguồn thực sự có cột type động qua lookup.

#### 3e. PK nguồn và BK
- PK kỹ thuật bảng nguồn (VD: `ID` auto-increment/UUID) **KHÔNG map vào Atomic** — loại khỏi model hoàn toàn, không giữ lại dưới bất kỳ hình thức nào (kể cả technical field).
- Mã nghiệp vụ duy nhất của bảng nguồn (VD: `CODE`, `MA_CTCK`, `MA_SO_THUE`) → `{Entity} Code` — **BK duy nhất** của entity, data domain `Text`, `nullable: false`. **KHÔNG** đặt tên generic kiểu `Organization Code`.
- `{Entity} Id` (surrogate) hash **từ chính `{Entity} Code`**: `hash_id('SRC.TABLE', CODE_COLUMN)` — không hash từ ID kỹ thuật.
- **Bảng nguồn có cả `ID` và `CODE`**: chỉ map `CODE` → `{Entity} Code`; bỏ qua `ID` hoàn toàn (không tạo cặp Code kỹ thuật + Unique Key như trước đây).
- Không còn pattern `{Entity} Unique Key` — đã gộp vào `{Entity} Code` duy nhất (quyết định 2026-07-13, thay thế pattern Id+Code+Unique Key cũ).
- Pattern tham khảo (`lld_THANHTRA_VIOLATION_CASE.yaml`): `Violation Case Id` (surrogate, hash từ CODE) + `Violation Case Code` (từ `CODE` nguồn — mã hồ sơ VPHC tự sinh, BK duy nhất).
- FK trỏ đến entity khác trong 15 core objects cũng phải hash theo Code của entity đích: nếu cột FK nguồn lưu ID kỹ thuật của bảng cha, phải `join FK_COL → TARGET_TABLE.ID` để lấy `CODE` rồi mới `hash_id('TARGET_TABLE', code)` — không hash trực tiếp theo FK ID.
- Nếu mã nghiệp vụ nguồn hiện đang nullable, cần ghi chú yêu cầu profile dữ liệu xác nhận NOT NULL/unique trước go-live (Code nay đóng vai trò BK).

**Entity dạng link/relationship thuần (tên có `_x_`, VD: `Investment Fund X Fund Distribution Agent Relationship`, `Penalty Decision X Violation Record`) — KHÔNG thiết kế cặp `{Entity} Id` + `{Entity} Code` riêng cho entity** (quyết định Data Modeler 2026-08-13, thay thế cách làm cũ dùng surrogate Id + BK composite text như `lld_FMS_AGEN_FUNDS.yaml`/`lld_FMS_FUND_TL_PRO.yaml`/`lld_FMS_JOB_TL_PRO.yaml` trước đó). Thay vào đó:
- PK = **composite 2 FK Id** của 2 entity được liên kết — đánh `is_primary_key: true` trên cả 2 attribute `{Parent A} Id` và `{Parent B} Id`.
- Vẫn giữ đủ 2 cặp FK Id + Code (theo Bước 3c) và `Source System Code`.
- Ghi chú `"Composite PK cùng {Parent khác} Id."` vào comment của mỗi FK Id.
- Áp dụng cho entity thực sự là pure link (bảng nguồn chỉ có 2 FK, không có PK/ID kỹ thuật riêng, không có business attribute nào khác ngoài 2 FK) — không áp dụng cho entity `_x_` có thêm business attribute riêng (trường hợp đó vẫn cần Id/Code riêng vì entity có identity độc lập ngoài cặp FK).

#### 3f. Source System Code

Format bắt buộc — **cả 2 trường phải nhất quán:**

| Trường | Giá trị bắt buộc |
|---|---|
| `classification_context` | `SOURCE_SYSTEM=NHNCK.TABLE_NAME` (giữ dấu chấm) |
| `etl_derived_value` | `NHNCK_TABLE_NAME` — **gạch dưới**, thay dấu `.` bằng `_` từ phần VALUE sau dấu `=` của `classification_context` |

`TABLE_NAME` = tên bảng nguồn cụ thể (không phải chỉ tên source system).

**Vì sao 2 trường khác định dạng dấu phân cách:** `classification_context` là scheme identifier cho con người/tool tra cứu, giữ dấu chấm cho dễ đọc (namespace SOURCE.TABLE). `etl_derived_value` là giá trị literal thực sự sẽ được hardcode/lưu vào cột dữ liệu — dùng gạch dưới để tránh nhầm với ký hiệu path/namespace ở phía ETL.

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
| `Created By [Entity] Id` | `Surrogate Key` | `*.CREATED_BY` | `FK target: {entity_physical_name}.{entity_physical_name}_id.` |
| `Created By [Entity] Code` | `Text` | `*.CREATED_BY` | `Lookup pair: {entity_physical_name}.{entity_physical_name}_code. Pair with Created By [Entity] Id.` |
| `Updated By [Entity] Id` | `Surrogate Key` | `*.UPDATED_BY` | `FK target: {entity_physical_name}.{entity_physical_name}_id.` |
| `Updated By [Entity] Code` | `Text` | `*.UPDATED_BY` | `Lookup pair: {entity_physical_name}.{entity_physical_name}_code. Pair with Updated By [Entity] Id.` |

**Quy tắc:**
- `[Entity]` = tên ngắn của Atomic entity đích dùng trong tên attribute (ví dụ: `Officer` khi FK target là `Regulatory Authority Officer`).
- `{entity_physical_name}` = physical_name viết thường của Atomic entity đích (VD: `ra_officer` cho `Regulatory Authority Officer`) — **không phải** tên rút gọn dùng trong tên attribute (`Officer`), cũng không phải Title Case business name.
  - Đúng: `FK target: ra_officer.ra_officer_id.`
  - Sai: `FK target: Regulatory Authority Officer.Officer Id.` (vừa sai casing, vừa dùng tên rút gọn thay vì tên đầy đủ của entity đích)
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
  `FK target: {entity_physical_name}.{entity_physical_name}_id. {notes}`
  → `atomic-gen-docs` parse prefix `FK target:` và đưa vào bảng Constraint của tài liệu CSDL.

  **Casing — physical_name viết thường LUÔN LUÔN**, cho mọi FK target (không phân biệt FK bình
  thường/Shared entity/crosswalk). Đây không phải ngoại lệ riêng cho crosswalk — mọi `FK target:`/
  `Lookup pair:` đều dùng `{entity_physical_name}.{attribute_physical_name}` viết thường, không
  dùng Title Case Atomic Entity Name. `generate_dm_yaml.py::normalize_comment()` tự động convert
  Title Case còn sót ở LLD (nếu designer lỡ viết) sang physical_name khi sinh output Atomic — nhưng
  không nên dựa vào auto-convert này, viết đúng physical_name ngay từ LLD.

  **Hash comment — bắt buộc bổ sung cho ETL:** ETL hash surrogate Id từ 2 input:
  `(source_system_code, business_key)`. FK_SOURCE = source table của **target entity**,
  xác định từ `Source/{SOURCE}_Columns.csv` cột "Ghi chú (FK suy luận)".

  | Case | source_columns | Hash comment |
  |---|---|---|
  | FK bình thường | `[SRC.TABLE.FK_COL]` | `Hash: hash_id('SRC.TARGET_TABLE', FK_COL).` |
  | Shared entity (IP sub-table, dùng PK parent) | `[SRC.PARENT_TABLE.ID]` | `Hash: hash_id('SRC.PARENT_TABLE', ID).` |
  | FK luôn NULL | `[]` (rỗng) | Không thêm hash, không ghi lý do NULL — để `comment: null`. |

  Ví dụ:
  - Normal: `"FK target: securities_practitioner.securities_practitioner_id. Hash: hash_id('NHNCK.PROFESSIONALS', PROFESSIONAL_ID)."`
  - Shared entity: `"FK target: securities_organization_reference.securities_organization_reference_id. Shared entity. Hash: hash_id('NHNCK.ORGANIZATIONS', ID)."`
  - Always null: `comment: null` (source_columns rỗng → không giữ lại "FK target:"/"Lookup pair:" hay lý do NULL nào trong comment, kể cả khi lý do đó đúng và ngắn gọn).

  **FK cần crosswalk sang bảng danh mục nguồn để lấy Code (không hash trực tiếp theo ID kỹ
  thuật):** Áp dụng khi cột FK nguồn lưu ID kỹ thuật nội bộ của 1 bảng danh mục/lookup — trong
  cùng phân hệ (join nội bộ, xác định chắc chắn) hoặc khác phân hệ (crosswalk sang danh mục
  chuẩn hóa như ECAT, value set có thể chưa khớp 100%) — nên ETL phải join qua bảng đó trước để
  lấy Code, rồi mới `hash_id()` theo Code đó, thay vì hash trực tiếp theo ID kỹ thuật của FK. Đây
  là lỗi thường gặp: bảng main hash surrogate Id của chính nó từ Code (đúng theo Bước 3e), nhưng
  bảng con lại hash FK trỏ tới main bằng chính giá trị ID kỹ thuật thay vì Code — khiến 2 giá trị
  hash không bao giờ khớp nhau.

  Cú pháp:
  ```
  FK target: {target_entity_physical_name}.{target_attribute_physical_name} ({filter_attribute_physical_name} = {FILTER_VALUE}, nếu cần lọc). Cần ETL crosswalk sang {SOURCE_SYSTEM}.{LOOKUP_TABLE}: {SOURCE_TABLE}.{FK_COLUMN} = {LOOKUP_TABLE}.{LOOKUP_PK_COLUMN} để xác nhận {CODE_COLUMN} sau đó hash_id('{TARGET_SOURCE_SYSTEM}.{TARGET_TABLE}', {CODE_COLUMN}) | {notes khác, ví dụ cảnh báo cần profile dữ liệu}
  ```

  - `{SOURCE_SYSTEM}.{LOOKUP_TABLE}`, `{SOURCE_TABLE}.{FK_COLUMN}`, `{LOOKUP_PK_COLUMN}`,
    `{CODE_COLUMN}` giữ nguyên tên vật lý nguồn (viết hoa/snake theo CSDL gốc — không đổi).
    `{FILTER_VALUE}` viết theo chuẩn SQL literal, bọc dấu nháy đơn: `'COUNTRY'`.
  - `{target_entity_physical_name}.{target_attribute_physical_name}` và điều kiện lọc dùng
    physical_name viết thường — cùng quy tắc chung áp dụng cho mọi `FK target:` (xem đầu mục Id
    ở trên), không phải cú pháp riêng của crosswalk.
  - Dấu `|` ngăn cách phần **format chuẩn hóa** (`FK target: ...` đến hết `hash_id(...)`) với phần
    **free-text notes** phía sau (cảnh báo profile dữ liệu, ghi chú lịch sử fix, snapshot...). Nếu
    không có note nào thêm thì bỏ luôn dấu `|`.
  - **Crosswalk khác phân hệ, value set chưa chắc khớp** (VD Geographic Area/COUNTRY qua ECAT):
    bắt buộc thêm cảnh báo sau `|`: `"Chưa xác nhận value set khớp danh mục {TARGET} — cần
    profile dữ liệu trước go-live."`
  - **Crosswalk cùng phân hệ, join theo PK kỹ thuật thật** (VD bảng con trong cùng source hash
    nhầm theo FK ID thay vì Code của bảng cha): không cần cảnh báo profile (không có rủi ro sai
    lệch chuẩn mã) — có thể ghi note lịch sử fix thay thế, VD: `"Trước đây hash trực tiếp theo
    {FK_COLUMN} (ID kỹ thuật) gây sai lệch với Id của bảng main (hash từ {CODE_COLUMN}) — đã sửa
    sang crosswalk {ngày}."`
  - Trường hợp đặc biệt — nguồn **không có bảng danh mục nội bộ** để crosswalk (free-text, ví dụ
    GSGD `NATIONALITY`): bỏ mệnh đề "Cần ETL crosswalk sang..." (không có bảng để join), mô tả
    đối chiếu trực tiếp giá trị text với Code của entity đích, vẫn giữ `hash_id(...)` và cảnh báo
    profile dữ liệu nếu cross-system.

  Ví dụ (crosswalk khác phân hệ, NHNCK.PROFESSIONALS.NATIONALITY_ID → Geographic Area, Type Code
  = COUNTRY):
  `"FK target: geographic_area.geographic_area_id (geographic_area_tp_code = 'COUNTRY'). Cần ETL
  crosswalk sang NHNCK.COUNTRIES: PROFESSIONALS.NATIONALITY_ID = COUNTRIES.ID để xác nhận
  COUNTRY_CODE sau đó hash_id('ECAT.COUNTRY', COUNTRY_CODE) | Chưa xác nhận value set khớp danh
  mục ECAT — cần profile dữ liệu trước go-live."`

  Ví dụ (crosswalk cùng phân hệ, sửa lỗi hash-mismatch):
  `"FK target: sp_professional_training_class.sp_professional_training_class_id. Cần ETL
  crosswalk sang NHNCK.SPECIALIZATION_COURSES: SPECIALIZATION_COURSE_DETAILS.SPECIALIZATION_COURSE_ID
  = SPECIALIZATION_COURSES.ID để xác nhận COURSE_CODE sau đó hash_id('NHNCK.SPECIALIZATION_COURSES',
  COURSE_CODE) | Trước đây hash trực tiếp theo SPECIALIZATION_COURSE_ID (ID kỹ thuật) gây sai
  lệch với Id của bảng main (hash từ COURSE_CODE) — đã sửa sang crosswalk 2026-07-27."`

  **Vòng đời comment — sau khi Data Modeler xác nhận** (profile dữ liệu xong, value set khớp danh
  mục đích, không còn rủi ro crosswalk): bỏ hẳn mệnh đề cảnh báo + dấu `|`, thu gọn về dạng Hash
  comment chuẩn (case "FK bình thường" ở trên) — phần `FK target:` vẫn dùng physical_name viết
  thường như mọi FK khác (không có gì đặc biệt cần "giữ lại" — đây luôn là casing chuẩn, không
  phải trạng thái tạm thời của riêng crosswalk):
  `"FK target: {entity_physical_name}.{entity_physical_name}_id ({điều kiện lọc nếu có}). Hash: hash_id('{TARGET_SRC}.{TARGET_TABLE}', {CODE_COLUMN})."`

- **Code** — denormalized lookup (KHÔNG phải FK constraint, chỉ là copy giá trị business key cho tiện query):
  `Lookup pair: {entity_physical_name}.{entity_physical_name}_code. Pair with {Id field name}. {notes}`
  → `atomic-gen-docs` KHÔNG đưa Code vào bảng Constraint. Chỉ Id mới sinh constraint.
  → Casing: physical_name viết thường, cùng quy tắc như Id — KHÔNG dùng Title Case Atomic Entity
    Name (kể cả khi Id cặp cùng nó là FK bình thường không cần crosswalk).

  **`source_columns` của Code khi Id đi kèm là case crosswalk (xem mục "FK cần crosswalk sang
  bảng danh mục nguồn để lấy Code" ở trên) — lỗi thường gặp cần tránh:** Code **KHÔNG** được map
  `source_columns` bằng chính `{SOURCE_TABLE}.{FK_COLUMN}` (ID kỹ thuật) giống Id — đó là lỗi sai
  bản chất, vì giá trị Atomic lưu vào Code là kết quả **sau khi** ETL join qua bảng danh mục, không
  phải ID kỹ thuật. `source_columns` của Code phải là:
  ```
  {SOURCE_SYSTEM}.{LOOKUP_TABLE}.{CODE_COLUMN}
  ```
  (đúng 3 thành phần đã dùng trong comment `Cần ETL crosswalk sang {SOURCE_SYSTEM}.{LOOKUP_TABLE}:
  ... để xác nhận {CODE_COLUMN}` của Id — lấy lại y nguyên, không tự suy ra tên khác).

  Comment của Code trong case này giữ nguyên cú pháp `Lookup pair:` ở trên — **quan trọng: `{entity_physical_name}.{entity_physical_name}_code` phải tra đúng physical_name attribute Code thật của target entity trong file LLD/entity của nó, KHÔNG tự suy ra bằng cách ghép `{target_entity_physical_name}` (tên bảng) + `"_code"`.** 2 giá trị này không phải luôn giống nhau — VD entity `cl_fms_event_type` (bảng) nhưng attribute Code thật của chính entity đó lại là `cl_fms_event_tp_code` (viết tắt "Type"→"tp" ở cấp attribute, khác với tên bảng). Nếu không chắc, giữ nguyên nguyên văn phần `Lookup pair: X.Y.` đã có sẵn trong file (do lượt thiết kế trước đã tra đúng), chỉ bổ sung 1 câu ngắn dẫn về nguồn crosswalk vào cuối (không lặp lại toàn bộ chi tiết join — đã có ở comment của Id):
  ```
  {Lookup pair: X.Y. Pair with {Id attribute name}.} Giá trị lấy từ {SOURCE_SYSTEM}.{LOOKUP_TABLE}.{CODE_COLUMN} sau ETL crosswalk — chi tiết xem comment {Id attribute name}.
  ```

  Ví dụ (khớp với case Id ở mục crosswalk khác phân hệ trên — NHNCK PROFESSIONALS.NATIONALITY_ID):
  ```yaml
  - attribute_name: "Nationality Id"
    source_columns:
    - "NHNCK.PROFESSIONALS.NATIONALITY_ID"
    comment: "FK target: geographic_area.geographic_area_id (geographic_area_tp_code = 'COUNTRY'). Cần ETL crosswalk sang NHNCK.COUNTRIES: PROFESSIONALS.NATIONALITY_ID = COUNTRIES.ID để xác nhận COUNTRY_CODE sau đó hash_id('ECAT.COUNTRY', COUNTRY_CODE) | Chưa xác nhận value set khớp danh mục ECAT — cần profile dữ liệu trước go-live."

  - attribute_name: "Nationality Code"
    source_columns:
    - "NHNCK.COUNTRIES.COUNTRY_CODE"
    comment: "Lookup pair: geographic_area.geographic_area_code. Pair with Nationality Id. Giá trị lấy từ NHNCK.COUNTRIES.COUNTRY_CODE sau ETL crosswalk — chi tiết xem comment Nationality Id."
  ```
  Trái lại, với **FK bình thường (không crosswalk)** — `FK_COLUMN` đã chính là business code lưu
  trực tiếp ở bảng nguồn, không cần join qua bảng danh mục nào — Code's `source_columns` vẫn dùng
  đúng `{SOURCE_TABLE}.{FK_COLUMN}` như trước, KHÔNG áp dụng thay đổi này.

- **Currency Code** (Classification Value pattern, không có Id surrogate):
  `FK target: currency.currency_code. {notes}`
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
- [ ] **FK hash comment** (xem Bước 5): Mọi FK Id có `source_columns` không rỗng → comment phải có `Hash: hash_id('SRC.TARGET_TABLE', COL).` (FK_SOURCE tra từ `Source/{SOURCE}_Columns.csv`). FK với `source_columns: []` → không thêm hash, `comment: null` (không ghi lý do NULL).
- [ ] **FK cần crosswalk qua bảng danh mục** (xem Bước 5): Nếu `COL` dùng trong `hash_id()` là ID kỹ thuật của bảng đích chứ không phải Code thật (đối chiếu `"{Entity} Code"` attribute của chính entity đích) → phải dùng cú pháp `FK target: {entity}.{attribute} (...). Cần ETL crosswalk sang ...` (physical_name viết thường), KHÔNG hash trực tiếp theo ID kỹ thuật.
- [ ] **Code đi kèm Id crosswalk** (xem Bước 5): Khi Id là case crosswalk, Code's `source_columns` phải là `{SOURCE_SYSTEM}.{LOOKUP_TABLE}.{CODE_COLUMN}` (cột Code thật ở bảng danh mục, lấy đúng từ comment crosswalk của Id) — KHÔNG lặp lại `{SOURCE_TABLE}.{FK_COLUMN}` (ID kỹ thuật) giống Id.
- [ ] **Audit block** (xem Bước 3k): Bảng nguồn có `CREATED_AT / CREATED_BY / UPDATED_AT / UPDATED_BY` → đủ 6 attribute chuẩn. Comment FK target dùng **tên attribute đầy đủ** (có prefix entity). Self-reference vẫn có cặp Id + Code.
- [ ] **Technical bundle** (xem Bước 2c): Nếu bảng nguồn có đủ 9 cột audit/soft-delete/optimistic-locking chuẩn (`STATUS, DELETED, CREATED_AT, UPDATED_AT, CREATED_BY_ID, CREATED_BY_NAME, UPDATED_BY_ID, UPDATED_BY_NAME, VERSION`) → đã loại trừ và ghi 9 dòng `pending_design.yaml` chưa? Nếu chỉ có một phần → đã ghi "Điểm cần xác nhận" trong HLD Tier chưa?
- [ ] **ID + CODE pattern** (xem Bước 3e): PK kỹ thuật nguồn (`ID`) loại khỏi model — mã nghiệp vụ (`CODE`) map vào `{Entity} Code` duy nhất (không đặt tên generic như `Organization Code`, không còn `{Entity} Unique Key`), và Id hash từ chính `{Entity} Code`?
- [ ] Format `source_columns` nhất quán: fully qualified `SOURCE_SYSTEM.schema.Table.Column`.
- [ ] Shared entity: FK dùng `Involved Party Id` / `Involved Party Code` — không dùng tên entity cha.
- [ ] Bảng junction denormalized theo HLD → attribute ARRAY đã thêm vào entity cha, không có trong manifest.
- [ ] **Cross-check scheme:** Mọi `Scheme: XYZ` trong cột comment và mọi `XYZ=` trong cột `classification_context` đều có trong `classification_schemes.yaml`.
- [ ] **Trường địa lý:** mã quốc gia/tỉnh/huyện/xã được xử lý đúng theo bối cảnh nguồn (xem [`reference/shared_entity_schemas.md`](reference/shared_entity_schemas.md)).
- [ ] **Shared entity type động:** Nếu nguồn có cột type qua lookup_values (`identity_type_cd`...) → đã dùng `SCHEME=(source)` placeholder chưa? Không để bare context.
- [ ] **Shared entity — cột không map:** PK kỹ thuật / audit fields / business flag của bảng nguồn shared đã được document trong `pending_design.yaml`?
- [ ] **Merge entity 1-1:** `source_columns` KHÔNG dùng format comma-separated `"X.col1, Y.col2"` — chỉ 1 bảng primary, bảng còn lại document pending.
- [ ] **scope_status sync:** Sau khi lưu LLD file → chạy sync script (xem section "Cập nhật scope_status trong BRD Source YAML") → kiểm tra tất cả source_tables (metadata + source_columns) đã là `in_scope` trong `brd_{SOURCE}.yaml`.
- [ ] **Encoding:** mọi file CSV ghi UTF-8 with BOM (`utf-8-sig`) — xem [`reference/file_layout.md`](reference/file_layout.md).
- [ ] **`etl_derived_value` cho Classification Value:** Mọi row có `classification_context = SCHEME=VALUE` → `etl_derived_value = VALUE`. Mọi row `SOURCE_SYSTEM=SRC.TABLE` → `etl_derived_value = SRC_TABLE` (**gạch dưới**, không dùng dấu chấm). Dynamic context (không có `=VALUE`) → **luôn null**, KHÔNG ghi expression mapping CODE=VALUE (mapping đã có trong `classification_schemes.yaml` / bảng `cl_value`).
- [ ] **Source System Code:** `classification_context = SOURCE_SYSTEM=NHNCK.TABLE_NAME` (không free-text, không bare, không trống — giữ dấu chấm); `etl_derived_value = NHNCK_TABLE_NAME` (bắt buộc, không trống, **gạch dưới**).
- [ ] **Post-check C7 + C8 + C9:** Sau aggregate, chạy `post_check_atomic.py` — C7 kiểm tra mọi `Classification Value` có context `SCHEME=VALUE` đều có `etl_derived_value`; C8 kiểm tra riêng `Source System Code` (format gạch dưới); C9 kiểm tra không còn sót expression mapping CODE=VALUE trên context dynamic.
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
  entity_physical_name: securities_practitioner
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
    physical_name: securities_practitioner_id
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
    physical_name: securities_practitioner_code
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
    etl_derived_value: NHNCK_PROFESSIONALS
```

**Physical name:** Sinh `physical_name` theo quy tắc B trong section **[QUY TẮC ĐẶT `physical_name`](#quy-tắc-đặt-physical_name)** ở cuối file. `entity_physical_name` lấy từ cột tương ứng trong `atomic_entities.yaml` (quy tắc A), không tự tính lại. `data_type` để trống — `transform_physical_names.py` tự patch sau.

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

### Cập nhật scope_status trong BRD Source YAML

Sau khi lưu LLD file (hoặc sau khi hoàn thành cả Tier), chạy sync scope cho toàn bộ
LLD đã có của source. Đây là bước đánh `in_scope` chính thức — thay thế hoàn toàn
Giai đoạn 4b của source-survey.

**Thu thập source tables từ toàn bộ LLD của source:**
1. `metadata.source_table` — bảng chính của mỗi LLD file
2. Pattern `"{SOURCE}.TABLE.COL"` trong `source_columns` — bảng phụ/join được reference

Tất cả bảng tìm được → đánh `scope_status: in_scope`, kể cả bảng hiện đang `out_of_scope`.

```python
import re, glob, sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

SOURCE = "{SOURCE}"  # thay bằng source đang thiết kế

lld_tables = set()
for f in glob.glob(f"DataModel/working/Atomic/lld/{SOURCE}/lld_{SOURCE}_*.yaml"):
    content = open(f, encoding='utf-8').read()
    m = re.search(r'source_table:\s+"([^"]+)"', content)
    if m:
        lld_tables.add(m.group(1))
    for ref in re.findall(rf'"{SOURCE}\.([A-Z_]+)\.[A-Z_]+"', content):
        lld_tables.add(ref)

print(f"Tables to mark in_scope ({len(lld_tables)}): {sorted(lld_tables)}")

with open(f'BRD/Source/brd_{SOURCE}.yaml', encoding='utf-8') as f:
    brd_content = f.read()

changed = []

def patch(m):
    block = m.group(0)
    tm = re.search(r'^    table:\s+(\S+)', block, re.MULTILINE)
    if not tm or tm.group(1) not in lld_tables:
        return block
    for old_status in ('pending', 'out_of_scope'):
        if f'scope_status: {old_status}' in block:
            changed.append(tm.group(1))
            return block.replace(f'scope_status: {old_status}', 'scope_status: in_scope')
    return block  # đã là in_scope

patched = re.sub(
    r'(?s)(^- brd_id:.*?)(?=^- brd_id:|\Z)',
    patch, brd_content, flags=re.MULTILINE
)
open(f'BRD/Source/brd_{SOURCE}.yaml', 'w', encoding='utf-8').write(patched)
print(f"Đã đánh in_scope ({len(changed)} bảng): {sorted(changed)}")
```

Sau khi patch: `python scripts/generate_brd_summary.py`

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

**Trước khi chạy lệnh dưới đây, thực hiện gate ở mục "QUY TẮC CỨNG — KHÔNG GENERATE KHI CÒN LLD/ENTITY CHƯA APPROVED" ở đầu file.**

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

**⛔ BẮT BUỘC chạy gate ở mục "QUY TẮC CỨNG — KHÔNG GENERATE KHI CÒN LLD/ENTITY CHƯA APPROVED" ở
đầu file TRƯỚC lệnh dưới đây** — `--source {SOURCE}` generate cho TOÀN BỘ `lld_*.yaml` của
source đó (và mọi source khác đóng góp vào shared entity liên quan), không chỉ bảng bạn vừa sửa.
Kiểm tra `design_status` của tất cả các file trong phạm vi trước khi chạy, không giả định đã approved.

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

**Trước khi chạy lệnh này, thực hiện gate ở mục "QUY TẮC CỨNG — KHÔNG GENERATE KHI CÒN LLD/ENTITY CHƯA APPROVED" ở đầu file** — lệnh này ảnh hưởng TOÀN BỘ dự án, không chỉ source đang thao tác.

**KHÔNG dùng `--source`** — flag này **destructively truncate** `dm_manifest.yaml` xuống chỉ còn rows của source đó (đã tái diễn 3 lần: ThanhTra 2 lần + KNT 2026-07-27). Luôn chạy không kèm flag để rebuild toàn bộ manifest từ tất cả source:

```bash
python DataModel/gen_summary_and_model.py
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
| **Gate trước Phase 4/5** | Kiểm tra thủ công `design_status`/`consolidation_status` của TOÀN BỘ file trong phạm vi (xem "QUY TẮC CỨNG" đầu file) | **0 file draft/reviewed** trong phạm vi, hoặc user đã xác nhận chấp nhận rủi ro |
| 4 — Generate YAML | `generate_dm_yaml.py --source {SOURCE}` | Số file đúng; 0 file thiếu `layer: Atomic` |
| 4b — Validate YAML | `validate_dm_yaml.py --source {SOURCE}` | **Failed: 0** |
| 5 — Consolidate | `gen_summary_and_model.py` (KHÔNG `--source` — xem Bước 11) | `dm_manifest.yaml` đủ N dòng của TẤT CẢ source; `atomic_model.yaml` parse được |

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

## QUY TẮC ĐẶT `physical_name`

Physical name của **table** và **column** dùng 2 thuật toán **tách biệt** — không còn dùng
`system/rules/rule_transform_logical_name.csv` (file đó chỉ còn phục vụ `datamart-gen-docs` cho
Gold/Datamart layer, ngoài phạm vi Atomic).

### A. Physical name của ENTITY (table)

```
entity_physical_name = abbreviate_domain_prefix(Domain Prefix) + "_" + full_words(BCV Term)
```

- **Domain Prefix**: phần đầu tên entity dùng chung cho 1 nhóm entity cùng nghiệp vụ — quyết định
  ở HLD Bước 4 (xem `atomic-hld-design/SKILL.md`), lưu tường minh tại cột `domain_prefix` trong
  `atomic_entities.yaml`.
  - **Chuẩn hoá bắt buộc (2026-08-07)**: `domain_prefix` chỉ được là chuỗi **rỗng `""`** hoặc
    khớp **đúng nguyên văn** 1 giá trị `Name` trong
    [`system/rules/rule_domain_prefix_abbreviations.csv`](../../../system/rules/rule_domain_prefix_abbreviations.csv)
    — không còn tự ghép chuỗi dài tuỳ ý (VD `"Public Company Evaluation"`,
    `"Securities Company Risk Indicator"`). Nếu Domain Prefix mong muốn dài hơn 1 giá trị curated
    (VD `"Public Company Evaluation Criterion"`), cắt về đúng giá trị curated đứng đầu
    (`"Public Company"`), phần dư đẩy xuống BCV Term.
- **abbreviate_domain_prefix()** = áp dụng danh sách cụm từ **curated**
  [`system/rules/rule_domain_prefix_abbreviations.csv`](../../../system/rules/rule_domain_prefix_abbreviations.csv)
  lên Domain Prefix theo thuật toán longest-match-first (duyệt trái sang phải, mỗi vị trí thử
  match cụm dài nhất có trong CSV tại word boundary; match → thay bằng `Abbreviation`; không
  match → **giữ nguyên cả từ** đó, viết thường). KHÔNG lấy chữ cái đầu của mọi từ một cách mù
  quáng — chỉ cụm từ có tên trong CSV mới bị rút gọn, phần còn lại của Domain Prefix giữ nguyên
  full word để người đọc hiểu được.
  - File CSV là danh sách **mở, bổ sung dần** — phát sinh cụm mới cần viết tắt toàn dự án thì
    thêm 1 dòng CSV, **không** viết thêm bảng abbreviation trong SKILL.md này.
  - VD: `Securities Company` → `sc` (có trong CSV); `Qualification Examination Assessment` →
    giữ nguyên `qualification_examination_assessment` (không có trong CSV).
- **full_words()** = viết thường toàn bộ, nối bằng `_`, **giữ nguyên đầy đủ từ — KHÔNG viết tắt**.
- **BCV Term** = phần còn lại của `atomic_entity` sau khi bỏ Domain Prefix.
- **Domain Prefix rỗng** (entity không có sibling nào cùng nhóm nghiệp vụ, hoặc Domain Prefix mong
  muốn không khớp cụm curated nào nên bị chuẩn hoá về rỗng) →
  `entity_physical_name = abbreviate_domain_prefix(atomic_entity)` — vẫn quét **toàn bộ** tên entity
  qua danh sách curated (không chỉ full_words trơ) để bắt cụm curated nằm ở giữa/cuối tên, không chỉ
  ở đầu. VD `"Foreign Fund Management Organization Unit"` (Domain Prefix rỗng vì không bắt đầu bằng
  cụm curated nào) → `foreign_fm_ou` (bắt được `Fund Management`→`fm` và `Organization Unit`→`ou`
  nằm giữa chuỗi), không phải `foreign_fund_management_organization_unit`.
- **BCV Term rỗng** (entity chính là "gốc" của cả nhóm — tên entity trùng khớp Domain Prefix) →
  `entity_physical_name = full_words(Domain Prefix)` (KHÔNG dùng abbreviation trơ trụi như `sc` —
  quá ngắn, dễ trùng giữa các nhóm khác nhau).

**Ví dụ:**

| Domain Prefix | BCV Term | atomic_entity | entity_physical_name |
|---|---|---|---|
| Securities Company | Practitioner | Securities Company Practitioner | `sc_practitioner` |
| Involved Party | Postal Address | Involved Party Postal Address | `ip_postal_address` |
| Securities Company | (rỗng) | Securities Company | `securities_company` |
| (rỗng — không sibling) | — | Geographic Area | `geographic_area` |
| Securities Practitioner Qualification Examination Assessment | Result | Securities Practitioner Qualification Examination Assessment Result | `sp_qualification_examination_assessment_result` |
| Securities Company Administrative | Sanction | Securities Company Administrative Sanction | `sc_administrative_sanction` |
| Securities Company Alert | Violation | Securities Company Alert Violation | `sc_alert_violation` |
| Penalty Decision Subject | Behavior | Penalty Decision Subject Behavior | `penalty_decision_subject_behavior` |

Hai dòng cuối cùng minh họa lý do đổi thuật toán: `Securities Company Administrative` và
`Securities Company Alert` trước đây đều rút gọn về initials `sca` (đụng độ, không phân biệt
được) — nay tách rõ `sc_administrative_*` / `sc_alert_*` vì chỉ `Securities Company` được viết
tắt, phần `Administrative`/`Alert` giữ nguyên. `Penalty Decision Subject` không chứa cụm nào
trong CSV nên giữ nguyên full words thay vì rút gọn mù quáng thành `pds`.

`entity_physical_name` phải **giống hệt nhau** trên mọi `lld_*.yaml` map cùng 1 `atomic_entity`
(kể cả khi entity đến từ nhiều source system). Nguồn giá trị chuẩn duy nhất: cột
`entity_physical_name` tương ứng trong `DataModel/working/Atomic/hld/atomic_entities.yaml` — copy
lại y nguyên, KHÔNG tự tính lại ở LLD nếu entity đã có sẵn trong file đó.

### B. Physical name của ATTRIBUTE (column)

Toàn bộ logical name được tokenize bằng **1 dictionary hợp nhất duy nhất** (longest-match-first,
cùng thuật toán `apply_dictionary()` dùng cho Rule A), gộp từ 3 nguồn:

1. **Entity-prefix dict** (tự build từ `atomic_entities.yaml`): `{atomic_entity đã đăng ký (lower)
   → entity_physical_name}` — **đúng giá trị đã dùng cho table (rule A)**, không tính lại. Chỉ
   entity nào thực sự bị viết tắt (`entity_physical_name` khác full-word) mới được đưa vào — entity
   "root" (nơi `atomic_entity == domain_prefix`, VD "Securities Practitioner") không có gì để thay.
   Xử lý pattern `[Entity] Id` / `[Entity] Code` / `[Entity] Name` khi logical name **bắt đầu bằng
   đúng tên đầy đủ** 1 Atomic Entity đã đăng ký.
2. **Domain-prefix abbreviations**
   [`system/rules/rule_domain_prefix_abbreviations.csv`](../../../system/rules/rule_domain_prefix_abbreviations.csv)
   — áp dụng **trực tiếp**, cụm từ (VD `Involved Party`, `Organization Unit`, `Securities Company`)
   được viết tắt ở **bất kỳ vị trí nào** trong logical name, không chỉ khi đứng ở đầu và không chỉ
   khi trùng khớp đúng 1 `atomic_entity` đã đăng ký. Đây là điểm khác biệt với (1): (1) chỉ khớp
   toàn bộ tên entity (có thể nhiều từ hơn Domain Prefix, VD "Securities Practitioner Related
   Party"), còn (2) khớp thẳng cụm Domain Prefix dù nó chỉ là 1 phần của attribute name (VD
   "Organization Unit Type Code" không phải tên 1 entity nào nhưng vẫn chứa cụm "Organization
   Unit").
3. **Exceptions**
   [`system/rules/rule_physical_name_exceptions.csv`](../../../system/rules/rule_physical_name_exceptions.csv)
   — từ đơn lẻ dùng chung, áp dụng cho phần còn lại sau khi (1)/(2) đã khớp (VD `Id`, `Name`,
   `Date`, `Address`→`adr`, `Type`→`tp`).

Cả 3 nguồn được gộp thành 1 list `(phrase, abbreviation)` rồi sort lại longest-match-first trước
khi tokenize — nhờ vậy 1 lượt quét duy nhất xử lý được cả prefix entity, cụm domain-prefix giữa
chừng, và từ đơn lẻ, không cần logic đặc biệt riêng cho từng loại. Phần không khớp bất kỳ dictionary
nào thì giữ nguyên full word (viết thường).

- Cả 2 file CSV là danh sách **mở, bổ sung dần** — phát sinh viết tắt chuẩn mới cần áp dụng toàn
  dự án thì thêm 1 dòng vào CSV tương ứng, **không** viết thêm bảng abbreviation trong SKILL.md này.
- **Không phải "không bao giờ viết tắt như table":** phiên bản trước của tài liệu này ghi sai rằng
  physical column name luôn giữ đầy đủ từ của entity kể cả khi entity đó bị viết tắt ở rule A
  (VD từng ghi `Securities Company Alert Financial Indicator Id → securities_company_alert_financial_indicator_id`).
  Đây là bug đã sửa — physical_name của Id/Code/Name... phải nhất quán với `entity_physical_name`
  dùng cho table, không tách biệt 2 giá trị cho cùng 1 entity.

**Ví dụ (xem CSV để có danh sách ngoại lệ mới nhất):**

| Logical name | Khớp qua nguồn nào | physical_name |
|---|---|---|
| Securities Company Alert Financial Indicator Id | (1) Entity-prefix (`sc_alert_financial_indicator`) | `sc_alert_financial_indicator_id` |
| Securities Company Alert Financial Indicator Name | (1) Entity-prefix (`sc_alert_financial_indicator`) | `sc_alert_financial_indicator_nm` |
| Securities Practitioner Related Party Id (FK) | (1) Entity-prefix (`sp_related_party`) | `sp_related_party_id` |
| Involved Party Id (FK, dùng trong shared entity) | (2) Domain-prefix trực tiếp (`Involved Party`→`ip`) — "Involved Party" không phải tên riêng 1 entity đã đăng ký nên không qua (1) | `ip_id` |
| Organization Unit Type Code | (2) Domain-prefix trực tiếp (`Organization Unit`→`ou`) + (3) exceptions (`Type`→`tp`) | `ou_tp_code` |
| Address Type Code | (3) Exceptions (`Address`→`adr`, `Type`→`tp`) | `adr_tp_code` |
| Securities Practitioner Full Name | Không khớp gì — root entity, giữ full word | `securities_practitioner_full_nm` |
| Source System Code | (3) Exceptions | `src_stm_code` |
| Created Timestamp | (3) Exceptions | `created_tms` |
| Full Name | (3) Exceptions | `full_nm` |
| Issue Date | (3) Exceptions | `issue_dt` |

### C. `transform_physical_names.py`

Script tự động recompute (B) cho mọi attribute trong mọi `lld_*.yaml` (luôn tính lại, không chỉ
điền khi trống), và điền (A) bằng cách tra `entity_physical_name` từ `atomic_entities.yaml`
(không tự transform lại tên entity). Chạy sau mỗi lần sửa LLD.

Với (B), `merge_column_dict()` gộp 3 nguồn theo đúng thứ tự mô tả ở trên: `exceptions` (từ
`rule_physical_name_exceptions.csv`) + `domain_prefix` (từ `rule_domain_prefix_abbreviations.csv`,
load qua `_domain_prefix_dict()` — dùng chung với Rule A) + entity-prefix dict tự build từ
`atomic_entities.yaml` (`build_entity_prefix_dict()`), rồi sort lại thành 1 dictionary duy nhất
trước khi chạy longest-match-first — nhờ vậy cả 3 loại match (prefix entity, cụm domain-prefix
giữa chừng, từ đơn lẻ) chạy trong cùng 1 lượt tokenize, không cần logic đặc biệt riêng cho Id/Code.

