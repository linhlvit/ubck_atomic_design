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
| Ngày cấp | `Issue Date` | Date |
| Nơi cấp | `Issuing Authority Name` | Text |

**Trường hợp đặc biệt:** Nguồn có `identity_no` nhưng không có cột type phân biệt → dùng `IP_ALT_ID_TYPE=NATIONAL_ID` làm default. Document trong `pending_design.csv` (`reason="Nguồn không phân biệt loại giấy tờ"`, `action="Cần profile data nguồn để xác định loại giấy tờ thực tế"`) và thêm 1 điểm xác nhận vào HLD Tier tương ứng.

## IP Postal Address

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

> Không phải mọi source đều có đủ trường — chỉ map những trường có dữ liệu nguồn.

**Quy tắc đặt tên `{Semantic Prefix}`:** Dùng prefix ngữ nghĩa cụ thể theo vai trò trường địa lý — KHÔNG dùng "Geographic Area" trong tên attribute.

| Ngữ nghĩa | Tên Id | Tên Code |
|---|---|---|
| Quốc tịch cá nhân | `Nationality Id` | `Nationality Code` |
| Quốc gia đăng ký tổ chức | `Country of Registration Id` | `Country of Registration Code` |
| Quốc gia cư trú | `Country of Residence Id` | `Country of Residence Code` |
| Tỉnh/thành phố | `Province Id` | `Province Code` |
| Quận/huyện (có lookup) | `District Id` | `District Code` |
| Các ngữ nghĩa khác | `{Vai trò cụ thể} Id` | `{Vai trò cụ thể} Code` |

Comment vẫn ghi `FK target: Geographic Area.Geographic Area Id` — chỉ tên attribute mới đổi.

## IP Electronic Address

| Trường | Tên chuẩn | Data Domain |
|---|---|---|
| FK chính | `Involved Party Id` | Surrogate Key |
| FK BK | `Involved Party Code` | Text |
| Nguồn | `Source System Code` | Classification Value |
| Loại kênh | `Electronic Address Type Code` | Classification Value |
| Giá trị | `Electronic Address Value` | Text |

> Mỗi loại kênh (PHONE, FAX, EMAIL, WEBSITE, EMAIL_DISCLOSURE...) là 1 cặp `Electronic Address Type Code` + `Electronic Address Value` riêng trong file.

## Quy tắc `classification_context` — BẮT BUỘC

Mọi attribute trong file shared entity phải có `classification_context` với format `SCHEME=VALUE` — không để bare. Bare context khiến aggregate mất mapping silent khi shared entity merge từ nhiều source.

Chọn value theo nguồn:
- **Nguồn có cột type động qua lookup** (VD: `identity_type_cd` → CMND/CCCD/Hộ chiếu/GPKD) → dùng placeholder `(source)`: `IP_ALT_ID_TYPE=(source)`. ETL map value runtime.
- **Nguồn cố định 1 loại** (VD: chỉ có cột `phone_no` = PHONE) → hardcode: `IP_ELEC_ADDR_TYPE=PHONE`.

Scheme áp dụng:
- `IP_ADDR_TYPE` (IP Postal Address)
- `IP_ELEC_ADDR_TYPE` (IP Electronic Address)
- `IP_ALT_ID_TYPE` (IP Alt Identification)

## Cột nguồn không map được vào schema chuẩn

Schema shared entity cố định — không có PK surrogate riêng (chỉ FK về entity chính), không có audit fields, không có business flag. Cột nguồn không map document trong `pending_design.csv`:

| Loại cột | Lý do (ghi vào pending_design.csv) |
|---|---|
| PK kỹ thuật | "Shared entity không có PK surrogate riêng — chỉ FK về entity chính." |
| Audit fields | "Shared entity schema chuẩn không có audit fields." |
| Business flag (Primary Flag, IsActive...) | "Cân nhắc tính tại Gold hoặc bổ sung schema shared entity (ảnh hưởng mọi nguồn)." |

## Quy tắc trường địa lý (quốc gia / tỉnh / huyện / xã)

Chọn 1 trong 4 cách xử lý:

| Bối cảnh | Xử lý | Ví dụ |
|---|---|---|
| Bảng nguồn có lookup địa lý rõ ràng trong cùng hệ thống (VD: FIMS.NATIONAL) | **FK pair** đến Silver entity **Geographic Area** — đặt tên theo ngữ nghĩa | FIMS: NaId → `Nationality Id/Code`; SCMS: TINH_THANH_ID → `Province Id/Code` |
| Dữ liệu phản hồi từ API ngoài (C06, VNPT...) hoặc nguồn không có lookup trong scope | **Classification Value** với scheme riêng, ghi `(no_lookup)` trong ref — không tạo FK | NHNCK: COUNTRY, PROVINCE, DISTRICT |
| Nguồn có lookup (provinces/countries) nhưng HLD chưa thiết kế lookup vào Silver Geographic Area trong cùng Tier | **Text** denormalized với comment ghi rõ "provinces/countries là reference data set chưa map vào shared Geographic Area trong scope {SOURCE}" | IDS: `head_office_prov`, `nationality` |
| Trường địa lý trong địa chỉ, nguồn ghi kèm cả Name (không resolve được) | **Text** denormalized — giữ cả Code lẫn Name | DCST IP_Postal_Address: Province Code/Name |

**Geographic Area là Silver entity** ([Location] Geographic Area) — chứa danh mục khu vực địa lý đa cấp. Chỉ tạo FK đến đây khi có lookup tường minh trong scope thiết kế.
