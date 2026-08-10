# Shared Entity Schemas — Tên trường chuẩn

Schema shared entity cố định toàn dự án. Bảng nguồn nào map vào shared entity phải dùng đúng tên trường này.

## IP Alt Identification

| Trường | Tên chuẩn | Data Domain |
|---|---|---|
| FK chính | `Involved Party Id` | Surrogate Key |
| FK BK | `Involved Party Code` | Text |
| Nguồn | `Source System Code` | Classification Value |
| Loại giấy tờ | `Identification Type Code` | Classification Value |
| Số giấy tờ | `Identification Number` | Text |
| Ngày cấp | `Identification Issue Date` | Date |
| Nơi cấp | `Identification Issue Place` | Text |

**Trường hợp đặc biệt:** Nguồn có `identity_no` nhưng không có cột type phân biệt → dùng `IP_ALT_ID_TYPE=NATIONAL_ID` làm default. Document trong `pending_design.yaml` (`reason="Nguồn không phân biệt loại giấy tờ"`, `action="Cần profile data nguồn để xác định loại giấy tờ thực tế"`) và thêm 1 điểm xác nhận vào HLD Tier tương ứng.

## IP Postal Address

Thứ tự cột chuẩn — **theo thứ bậc địa lý từ lớn đến nhỏ** (Quốc gia → Tỉnh/thành → Quận/huyện
→ Phường/xã), khớp cách các file đang triển khai thực tế. Mỗi cấp có thể là FK-with-lookup
(`{Level} Id` + `{Level} Code`) hoặc denormalized text (`{Level} Name` + `{Level} Code`) tùy
theo nguồn có lookup trong scope hay không — không dùng cả 2 dạng cho cùng 1 cấp trong cùng 1
file.

| Trường | Tên chuẩn | Data Domain |
|---|---|---|
| FK chính | `Involved Party Id` | Surrogate Key |
| FK BK | `Involved Party Code` | Text |
| Nguồn | `Source System Code` | Classification Value |
| Loại địa chỉ | `Address Type Code` | Classification Value |
| Địa chỉ text | `Address Value` | Text |
| FK quốc gia (có lookup) | `Country Id` | Surrogate Key |
| Mã quốc gia (có lookup) | `Country Code` | Text |
| FK tỉnh/thành (có lookup) | `Province Id` | Surrogate Key |
| Mã tỉnh/thành (có lookup) | `Province Code` | Text |
| Tỉnh/thành text (không lookup) | `Province Name` | Text |
| FK quận/huyện (có lookup) | `District Id` | Surrogate Key |
| Mã quận/huyện (có lookup) | `District Code` | Text |
| Quận/huyện text (không lookup) | `District Name` | Text |
| FK phường/xã (có lookup) | `Ward Id` | Surrogate Key |
| Mã phường/xã (có lookup) | `Ward Code` | Text |
| Phường/xã text (không lookup) | `Ward Name` | Text |

> Không phải mọi source đều có đủ trường — chỉ map những trường có dữ liệu nguồn. Trong 1 file,
> mỗi cấp địa lý chỉ chọn 1 dạng (FK Id+Code hoặc text Name+Code), không dùng cả 2.

**Quy tắc đặt tên `{Semantic Prefix}`:** Dùng prefix ngữ nghĩa cụ thể theo vai trò trường địa lý — KHÔNG dùng "Geographic Area" trong tên attribute.

| Ngữ nghĩa | Tên Id | Tên Code |
|---|---|---|
| Quốc tịch cá nhân | `Nationality Id` | `Nationality Code` |
| Quốc gia đăng ký tổ chức | `Country of Registration Id` | `Country of Registration Code` |
| Quốc gia cư trú | `Country of Residence Id` | `Country of Residence Code` |
| Quốc gia (địa chỉ, có lookup) | `Country Id` | `Country Code` |
| Tỉnh/thành phố | `Province Id` | `Province Code` |
| Quận/huyện (có lookup) | `District Id` | `District Code` |
| Phường/xã (có lookup) | `Ward Id` | `Ward Code` |
| Các ngữ nghĩa khác | `{Vai trò cụ thể} Id` | `{Vai trò cụ thể} Code` |

Comment vẫn tham chiếu đúng entity đích `geographic_area` (physical_name viết thường — xem quy tắc casing chung tại Bước 5 SKILL.md): `FK target: geographic_area.geographic_area_id` cho trường Id; trường Code ghi `Lookup pair: geographic_area.geographic_area_code. Pair with {Id field}.` — chỉ tên attribute (Province Id, Nationality Id...) mới đổi theo Semantic Prefix, còn tên entity đích trong comment luôn là physical_name (xem Bước 5 SKILL.md cho phân biệt FK target vs Lookup pair).

## IP Electronic Address

| Trường | Tên chuẩn | Data Domain |
|---|---|---|
| FK chính | `Involved Party Id` | Surrogate Key |
| FK BK | `Involved Party Code` | Text |
| Nguồn | `Source System Code` | Classification Value |
| Loại kênh | `Electronic Address Type Code` | Classification Value |
| Giá trị | `Electronic Address Value` | Text |

> Mỗi loại kênh (PHONE, FAX, EMAIL, WEBSITE, EMAIL_DISCLOSURE...) là 1 cặp `Electronic Address Type Code` + `Electronic Address Value` riêng trong file. `Involved Party Id` / `Involved Party Code` / `Source System Code` chỉ xuất hiện **đúng 1 lần** trong file (header dùng chung) — KHÔNG lặp lại 3 trường này cho mỗi kênh liên lạc.

## Quy tắc `classification_context` — BẮT BUỘC

Mọi attribute trong file shared entity phải có `classification_context` với format `SCHEME=VALUE` — không để bare. Bare context khiến aggregate mất mapping silent khi shared entity merge từ nhiều source.

Chọn value theo nguồn:
- **Nguồn có cột type động qua lookup** (VD: `identity_type_cd` → CMND/CCCD/Hộ chiếu/GPKD) → dùng placeholder `(source)`: `IP_ALT_ID_TYPE=(source)`. ETL map value runtime.
- **Nguồn cố định 1 loại** (VD: chỉ có cột `phone_no` = PHONE) → hardcode: `IP_ELEC_ADDR_TYPE=PHONE`.
- **Nguồn chỉ có 1 loại địa chỉ cụ thể** (VD: chỉ có `PERMANENT_ADDRESS`, không có cột address_type) → hardcode loại đó: `IP_ADDR_TYPE=PERMANENT`. **KHÔNG dùng bare `IP_ADDR_TYPE`** — aggregate sẽ bỏ sót `Address Type Code` khi merge nhiều source.

Scheme áp dụng:
- `IP_ADDR_TYPE` (IP Postal Address)
- `IP_ELEC_ADDR_TYPE` (IP Electronic Address)
- `IP_ALT_ID_TYPE` (IP Alt Identification)

## Quy tắc `etl_derived_value` cho Classification Value — BẮT BUỘC

| `classification_context` | `etl_derived_value` | Ví dụ |
|---|---|---|
| `SCHEME=VALUE` (giá trị cố định) | Điền literal VALUE | `IP_ELEC_ADDR_TYPE=PHONE` → `PHONE` |
| `SOURCE_SYSTEM=SRC.TABLE` | Điền literal `SRC_TABLE` (**gạch dưới**, không dùng dấu chấm) | `SOURCE_SYSTEM=NHNCK.PROFESSIONALS` → `NHNCK_PROFESSIONALS` |
| `SCHEME` (dynamic — nguồn thực sự có cột type lookup) | Luôn null | `IP_ALT_ID_TYPE=(source)` → null |
| `SCHEME=(source)` (lookup từ nguồn) | Luôn null — KHÔNG ghi expression mapping CODE=VALUE, mapping đã có trong `classification_schemes.yaml` | `NHNCK_IDENTITY_TYPE` → null |

**Lý do:** ETL engineer đọc `etl_derived_value` để biết giá trị nào cần hardcode vào cột này mà không cần parse `classification_context`. Bỏ trống = ETL phải đoán.

## Cột nguồn không map được vào schema chuẩn

Schema shared entity cố định — không có PK surrogate riêng (chỉ FK về entity chính), không có audit fields, không có business flag. Cột nguồn không map document trong `pending_design.yaml`:

| Loại cột | Lý do (ghi vào pending_design.yaml) |
|---|---|
| PK kỹ thuật | "Shared entity không có PK surrogate riêng — chỉ FK về entity chính." |
| Audit fields | "Shared entity schema chuẩn không có audit fields." |
| Business flag (Primary Flag, IsActive...) | "Cân nhắc tính tại Gold hoặc bổ sung schema shared entity (ảnh hưởng mọi nguồn)." |

## Quy tắc trường địa lý (quốc gia / tỉnh / huyện / xã)

Chọn 1 trong 4 cách xử lý:

| Bối cảnh | Xử lý | Ví dụ |
|---|---|---|
| Bảng nguồn có lookup địa lý rõ ràng trong cùng hệ thống (VD: FIMS.NATIONAL) | **FK pair** đến Atomic entity **Geographic Area** — đặt tên theo ngữ nghĩa | FIMS: NaId → `Nationality Id/Code`; SCMS: TINH_THANH_ID → `Province Id/Code` |
| Dữ liệu phản hồi từ API ngoài (C06, VNPT...) hoặc nguồn không có lookup trong scope | **Classification Value** với scheme riêng, ghi `(no_lookup)` trong ref — không tạo FK | NHNCK: COUNTRY, PROVINCE, DISTRICT |
| Nguồn có lookup (provinces/countries) nhưng HLD chưa thiết kế lookup vào Atomic Geographic Area trong cùng Tier | **Text** denormalized với comment ghi rõ "provinces/countries là reference data set chưa map vào shared Geographic Area trong scope {SOURCE}" | IDS: `head_office_prov`, `nationality` |
| Trường địa lý trong địa chỉ, nguồn ghi kèm cả Name (không resolve được) | **Text** denormalized — giữ cả Code lẫn Name | DCST IP_Postal_Address: Province Code/Name |

**Geographic Area là Atomic entity** ([Location] Geographic Area) — chứa danh mục khu vực địa lý đa cấp. Chỉ tạo FK đến đây khi có lookup tường minh trong scope thiết kế.
