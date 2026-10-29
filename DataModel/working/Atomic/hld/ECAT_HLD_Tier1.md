# ECAT HLD — Tier 1

**Source system:** ECAT (Dịch vụ đồng bộ danh mục dùng chung từ HTTT)
**Tier 1:** Nhóm danh mục địa lý hành chính (Geographic Area) — Fundamental, chỉ tự tham chiếu (self-join), không FK đến entity nghiệp vụ nào khác. Phạm vi tier này: 7 bảng COUNTRY, REGION, PROVINCE_NEW, PROVINCE_OLD, DISTRICT_OLD, WARD_NEW, WARD_OLD (2 entity: Geographic Area, Geographic Area Old) bảng DEPARTMENT (entity Classification ECAT Department — Tier 1 vì không FK đến entity nghiệp vụ nào, bổ sung 2026-10-22) và bảng ADMINISTRATIVE_PROCEDURE (entity Classification ECAT Administrative Procedure — Tier 1, chỉ FK suy luận đến CURRENCY là Classification Value, bổ sung 2026-10-29) — khớp LLD `lld/ECAT/`. Các bảng ECAT khác chưa có LLD — xem 7f Overview (nhóm `Chưa có LLD`).

> **Lưu ý nguồn:** `brd_ECAT.yaml` đặt tên 7 bảng này theo quy ước `ECAT_0N_TenBang` (VD `ECAT_01_Country`), nhưng khảo sát CSDL thực tế (`Source/ECAT_Tables.csv`, `Source/ECAT_Columns.csv`) dùng tên bảng thực `COUNTRY`, `REGION`, `PROVINCE_NEW`, `PROVINCE_OLD`, `DISTRICT_OLD`, `WARD_NEW`, `WARD_OLD` — khớp với tên user cung cấp. Tier này dùng tên bảng thực từ `Source/ECAT_Columns.csv` làm chuẩn (xem mục 6f-01).

---

## 6a. Bảng tổng quan BCV Concept

| BCV Core Object | BCV Concept | Category | Source Table | Source Table Change Mode | Mô tả bảng nguồn | Atomic Entity | Table Type | BCV Term |
|---|---|---|---|---|---|---|---|---|
| Location | [Location] Geographic Area | Location | COUNTRY | Update | Danh mục Quốc gia | Geographic Area | Fundamental | (1) Term "Geographic Area" (BCV id 11736, category Location): "nơi/khu vực giới hạn được xác định theo bản chất, cơ quan bên ngoài, hoặc mục đích kinh doanh nội bộ". (2) Cấu trúc trường COUNTRY chỉ có CODE + NAME_VN/NAME_EN (+ cờ EFFECTIVE/ACTIVE/DELETED) — nếu theo quy tắc chung đây sẽ là Classification Value, nhưng thuộc **ngoại lệ Geographic Area** của dự án (entity địa lý luôn là Atomic entity Fundamental dù chỉ Code+Name, vì có Data Concept riêng = Location, dùng làm FK nền tảng toàn dự án). (3) Chọn Geographic Area, `geographic_area_tp_code = COUNTRY` (ECAT là nguồn duy nhất của entity theo LLD). |
| Location | [Location] Geographic Area | Location | REGION | Update | Danh mục Vùng/miền | Geographic Area | Fundamental | (1) Cùng Geographic Area term như COUNTRY. (2) REGION có FK `COUNTRY_ID` → COUNTRY.ID — xác nhận Region là con trực tiếp của Country trong phân cấp hành chính (khác với `brd_ECAT.yaml`/`ECAT_Source_Analysis.md` v2 ghi nhận "không có FK giữa Country và Region" — bản khảo sát CSDL thực tế mới hơn cho thấy có FK). (3) Chọn Geographic Area, `geographic_area_type_code = REGION`, `parent_geographic_area_id` trỏ lên COUNTRY. |
| Location | [Location] Geographic Area | Location | PROVINCE_NEW | Update | Danh mục Tỉnh/Thành phố (mới, hiện hành post-sáp nhập 2025) | Geographic Area | Fundamental | (1) Cùng Geographic Area term. (2) PROVINCE_NEW có FK `REGION_ID` → REGION.ID (parent trực tiếp) và `COUNTRY_ID` → COUNTRY.ID (denormalized, suy ra được qua REGION nên không lưu lại trên Atomic). (3) Chọn Geographic Area, `geographic_area_type_code = PROVINCE` (giữ nguyên code đã dùng cho FIMS.LOCATION/SCMS.DM_TINH_THANH — cùng ý nghĩa "tỉnh/thành phố hiện hành"), `parent_geographic_area_id` trỏ lên REGION. |
| Location | [Location] Geographic Area | Location | WARD_NEW | Update | Danh mục Phường/Xã/Thị trấn (mới, hiện hành post-sáp nhập 2025) | Geographic Area | Fundamental | (1) Cùng Geographic Area term. (2) WARD_NEW có FK `PROVINCE_NEW_ID` → PROVINCE_NEW.ID — cấp quận/huyện bị bỏ hoàn toàn trong hiện hành (Ward là con trực tiếp của Province, không qua District). (3) Chọn Geographic Area, `geographic_area_type_code = WARD`, `parent_geographic_area_id` trỏ lên PROVINCE_NEW. |
| Location | [Location] Geographic Area | Location | PROVINCE_OLD | Update | Danh mục Tỉnh/Thành phố (cũ, pre-2025) | **Geographic Area Old** | Fundamental | (1) Cùng term Geographic Area — không có term BCV riêng cho khái niệm "danh mục lịch sử". (2) Cấu trúc trường **khác PROVINCE_NEW**: ngoài REGION_ID/COUNTRY_ID (anchor lên Geographic Area hiện hành), PROVINCE_OLD còn có `PROVINCE_NEW_ID` — FK **successor** trỏ sang tỉnh/thành phố hiện hành tương ứng sau sáp nhập. Cấp bậc phân cấp cũ (3 cấp: Tỉnh cũ → Quận/huyện cũ → Phường/xã cũ) khác cấu trúc mới (2 cấp: Tỉnh mới → Phường/xã mới) — không thể gộp chung 1 entity với cùng field `parent_geographic_area_id` mà không mất thông tin cấp bậc. (3) Theo yêu cầu Data Modeler, **tách riêng entity "Geographic Area Old"** cho toàn bộ dữ liệu lịch sử pre-2025 — giữ nguyên concept `[Location] Geographic Area` nhưng entity riêng để phản ánh đúng cấu trúc 3 cấp và mục đích "chỉ tra cứu lịch sử, không phát sinh instance mới". |
| Location | [Location] Geographic Area | Location | DISTRICT_OLD | Update | Danh mục Quận/Huyện (cũ, pre-2025 — cấp bị bỏ sau sáp nhập) | **Geographic Area Old** | Fundamental | (1) Cùng term Geographic Area. (2) DISTRICT_OLD chỉ có FK `PROVINCE_OLD_ID` — không có field successor (khác PROVINCE_OLD/WARD_OLD) vì cấp quận/huyện bị loại bỏ hoàn toàn trong cấu trúc mới, không có "district mới" tương ứng. (3) Geographic Area Old, `geographic_area_old_type_code = DISTRICT_OLD`, `parent_geographic_area_old_id` trỏ lên PROVINCE_OLD. |
| Location | [Location] Geographic Area | Location | WARD_OLD | Update | Danh mục Phường/Xã/Thị trấn (cũ, pre-2025) | **Geographic Area Old** | Fundamental | (1) Cùng term Geographic Area. (2) WARD_OLD có FK `DISTRICT_OLD_ID` (parent trực tiếp) và `WARD_NEW_ID` — FK successor trỏ sang phường/xã hiện hành tương ứng. (3) Geographic Area Old, `geographic_area_old_type_code = WARD_OLD`, `parent_geographic_area_old_id` trỏ lên DISTRICT_OLD; đồng thời giữ successor link sang Geographic Area (WARD_NEW) — xem mục 6f-02. |

| Common | [Common] Classification | Common | DEPARTMENT | Update | Danh mục Phòng ban | Classification ECAT Department | Relative | (1) Term "Classification" (category Common) — danh mục phân loại dùng chung; theo chỉ đạo Data Modeler 2026-10-22, bảng danh mục được promote thành Atomic entity Classification (Domain Prefix = `Classification`, physical `cl_ecat_department`) giống `Classification IDS Business Line`. (2) Cấu trúc trường: CODE + NAME + DESCRIPTION + PHONE + EMAIL (kèm thông tin liên hệ) nên giữ thành entity thay vì Classification Value đơn thuần. (3) Chọn `[Common] Classification`; BK = CODE. Chỉ map 5 trường: CODE, NAME, DESCRIPTION, PHONE, EMAIL; theo quyết định Data Modeler 2026-10-22 không map quan hệ phòng ban cha (`PARENT_ID`/`PARENT_VERSION_ID`) nên entity không tự tham chiếu. |
| Common | [Common] Classification | Common | ADMINISTRATIVE_PROCEDURE | Update | Danh mục Thủ tục hành chính (TTHC) | Classification ECAT Administrative Procedure | Relative | (1) Term "Classification" (category Common) — danh mục phân loại dùng chung; theo yêu cầu Data Modeler 2026-10-29, bảng danh mục TTHC được promote thành Atomic entity Classification (Domain Prefix = `Classification`, physical `cl_ecat_administrative_procedure`) cùng pattern `Classification ECAT Department`. (2) Cấu trúc trường: CODE + NAME + DESCRIPTION kèm nhiều thuộc tính mô tả TTHC (lĩnh vực, nhóm, mức độ, cách thức/kết quả thực hiện, thời gian giải quyết, lệ phí, cơ quan phối hợp, ngày hiệu lực/hết hiệu lực; người review đã loại 3 cột CLOB `IMPLEMENTATION_SEQUENCE`/`LEGAL_BASIS`/`COMPETENT_AUTHORITY` khỏi LLD, 2026-10-29) — vượt xa Code + Name nên giữ thành entity thay vì Classification Value đơn thuần. (3) Chọn `[Common] Classification`; BK = CODE (không dùng STABLE_ID, theo T1-05). Map toàn bộ cột nghiệp vụ; `FEE_UNIT_CURRENCY_ID` → `Fee Currency Code` (Currency = 1 trường Code, scheme `ECAT_CURRENCY`); `PROCEDURE_LEVEL` → Classification Value (scheme `ECAT_ADMINISTRATIVE_PROCEDURE_LEVEL`). Không map PK kỹ thuật, cột versioning, cờ trạng thái, audit — xem T1-07. Bảng con ADMINISTRATIVE_PROCEDURE_COMPONENT / _COMPONENT_MAPPING / _FIELD vẫn ngoài scope (chưa có LLD). |

---

## 6b. Diagram Source (Mermaid)

```mermaid
erDiagram
    COUNTRY {
        string id PK
        string code
        string name_vn
        string name_en
        number effective
        number active
        number deleted
        string stable_id
    }

    REGION {
        string id PK
        string code
        string name
        string country_id FK
        string stable_id
    }

    PROVINCE_NEW {
        string id PK
        string code
        string name_vn
        string name_en
        string region_id FK
        string country_id FK
        string stable_id
    }

    WARD_NEW {
        string id PK
        string code
        string name_vn
        string name_en
        string category
        string province_new_id FK
        string stable_id
    }

    PROVINCE_OLD {
        string id PK
        string code
        string name_vn
        string name_en
        string region_id FK
        string country_id FK
        string province_new_id FK
        string stable_id
    }

    DISTRICT_OLD {
        string id PK
        string code
        string name
        string province_old_id FK
        string stable_id
    }

    WARD_OLD {
        string id PK
        string code
        string name_vn
        string name_en
        string category
        string district_old_id FK
        string ward_new_id FK
        string stable_id
    }

    DEPARTMENT {
        string id PK
        string code
        string name
        string parent_id
        string parent_version_id
        string description
        string phone
        string email
        string stable_id
    }

    ADMINISTRATIVE_PROCEDURE {
        string id PK
        string code
        string name
        string field_group
        string procedure_group
        string procedure_level
        string fee_unit_currency_id FK
        number fee_amount
        string stable_id
    }

    COUNTRY ||--o{ REGION : "country_id"
    REGION ||--o{ PROVINCE_NEW : "region_id"
    PROVINCE_NEW ||--o{ WARD_NEW : "province_new_id"
    REGION ||--o{ PROVINCE_OLD : "region_id (anchor)"
    PROVINCE_OLD ||--o{ DISTRICT_OLD : "province_old_id"
    DISTRICT_OLD ||--o{ WARD_OLD : "district_old_id"
    PROVINCE_NEW ||--o{ PROVINCE_OLD : "province_new_id (successor, lateral)"
    WARD_NEW ||--o{ WARD_OLD : "ward_new_id (successor, lateral)"
```

> `country_id` trên `PROVINCE_NEW`/`PROVINCE_OLD` là denormalized (suy ra được qua `region_id` → `REGION.country_id`) — không vẽ riêng để tránh rối diagram. Quan hệ `province_new_id` trên `PROVINCE_OLD` và `ward_new_id` trên `WARD_OLD` là **successor mapping** (tỉnh/phường cũ → tỉnh/phường mới sau sáp nhập 2025), không phải quan hệ cha-con — vẽ riêng để phân biệt với FK phân cấp (`region_id`, `province_old_id`, `district_old_id`).

---

## 6c. Diagram Atomic (Mermaid)

```mermaid
erDiagram
    GeographicArea {
        bigint geographic_area_id PK
        string geographic_area_code
        string geographic_area_tp_code
        bigint parent_geographic_area_id FK
    }

    GeographicAreaOld {
        bigint geographic_area_old_id PK
        string geographic_area_old_code
        string geographic_area_old_tp_code
        bigint parent_geographic_area_old_id FK
        bigint region_geographic_area_id FK
        bigint successor_geographic_area_id FK
    }

    ClassificationEcatDepartment {
        bigint cl_ecat_department_id PK
        string cl_ecat_department_code
        string cl_ecat_department_nm
    }

    ClassificationEcatAdministrativeProcedure {
        bigint cl_ecat_administrative_procedure_id PK
        string cl_ecat_administrative_procedure_code
        string cl_ecat_administrative_procedure_nm
        string procedure_level_code
        string fee_currency_code
    }

    GeographicArea ||--o{ GeographicArea : "parent_geographic_area_id (self-join: WARD→PROVINCE→REGION→COUNTRY)"
    GeographicAreaOld ||--o{ GeographicAreaOld : "parent_geographic_area_old_id (self-join: WARD_OLD→DISTRICT_OLD→PROVINCE_OLD)"
    GeographicArea ||--o{ GeographicAreaOld : "region_geographic_area_id (anchor: REGION → PROVINCE_OLD)"
    GeographicArea ||--o{ GeographicAreaOld : "successor_geographic_area_id (PROVINCE/WARD → PROVINCE_OLD/WARD_OLD)"

```

> `GeographicArea` (COUNTRY/REGION/PROVINCE_NEW/WARD_NEW) và `GeographicAreaOld` (PROVINCE_OLD/DISTRICT_OLD/WARD_OLD) khớp LLD `lld/entities/entity_geographic_area*.yaml` — ECAT là nguồn duy nhất của cả 2 entity. `GeographicAreaOld` tách riêng theo yêu cầu Data Modeler.

---

## 6d. Mục Danh mục & Tham chiếu (Reference Data)

| Source Field / Bảng | Mô tả | Scheme Code | source_type | Ghi chú |
|---|---|---|---|---|
| ETL derive từ tên bảng nguồn (COUNTRY/REGION/PROVINCE_NEW/WARD_NEW) | Phân biệt cấp hành chính hiện hành trên entity Geographic Area | `GEOGRAPHIC_AREA_TYPE` | etl_derived | Code: `COUNTRY`, `REGION`, `PROVINCE`, `WARD` (nguồn `ECAT.COUNTRY`/`ECAT.REGION`/`ECAT.PROVINCE_NEW`/`ECAT.WARD_NEW`). |
| ETL derive từ tên bảng nguồn (PROVINCE_OLD/DISTRICT_OLD/WARD_OLD) | Phân biệt cấp hành chính lịch sử (pre-2025) trên entity Geographic Area Old | `GEOGRAPHIC_AREA_OLD_TYPE` | etl_derived | Scheme mới — tách khỏi `GEOGRAPHIC_AREA_TYPE` (3 code `PROVINCE_OLD`/`DISTRICT_OLD`/`WARD_OLD` chuyển từ scheme cũ sang scheme này). |
| `PROCEDURE_LEVEL` (ADMINISTRATIVE_PROCEDURE) | Mức độ dịch vụ công của TTHC (1/2/3/4) | `ECAT_ADMINISTRATIVE_PROCEDURE_LEVEL` | modeler_defined | Scheme mới đăng ký 2026-10-29, 4 giá trị theo mô tả nguồn "Mức độ (1/2/3/4)" — chưa profile. |
| `FEE_UNIT_CURRENCY_ID` (ADMINISTRATIVE_PROCEDURE) | Đơn vị tiền tệ của lệ phí | `ECAT_CURRENCY` | source_table | Scheme đã có (D-03 Overview); ETL join `FEE_UNIT_CURRENCY_ID` → `CURRENCY.ID` lấy `CURRENCY.CODE`; `used_in_entities` cũ "Administrative Procedure" đã đổi thành tên entity thật. |
| `EFFECTIVE` + `ACTIVE` + `DELETED` (cả 7 bảng) | 3 cờ trạng thái nguồn (hiệu lực / đang dùng / xóa mềm) — Atomic gộp thành 1 status code duy nhất | `GEOGRAPHIC_AREA_STATUS` | etl_derived | Scheme đã có sẵn (dùng chung cho `Geographic Area`); bổ sung `Geographic Area Old` vào `used_in_entities`. Logic gộp 3 cờ → 1 status: để LLD xác nhận (mục 6f-04). |

---

## 6e. Bảng chờ thiết kế

*(Không có — 9/9 bảng trong phạm vi tier này đã có đủ cấu trúc cột và đã có LLD.)*

Các bảng ECAT khác chưa có LLD — xem 7f Overview (nhóm `Chưa có LLD`).

---

## 6f. Điểm cần xác nhận

| # | Câu hỏi | Kết quả |
|---|---|---|
| T1-01 | `brd_ECAT.yaml` đặt tên 7 bảng theo quy ước `ECAT_0N_TenBang` (VD `ECAT_01_Country`), không khớp tên bảng thực trong `Source/ECAT_Tables.csv`/`ECAT_Columns.csv` (`COUNTRY`, `REGION`, `PROVINCE_NEW`...). Tương tự, `ECAT_Source_Analysis.md` (v2, working doc) ghi "không có FK giữa Country và Region trong ECAT" — khảo sát CSDL thực tế cho thấy `REGION.COUNTRY_ID` là FK thật. | Chưa xác nhận. Tier này ưu tiên dùng `Source/ECAT_Columns.csv` (khảo sát CSDL thực tế) làm chuẩn. Đề xuất: chạy lại `source-survey` cho ECAT để regenerate `brd_ECAT.yaml` + per-table BRD yaml khớp tên bảng thực, thay vì để 2 nguồn tài liệu lệch nhau. |
| T1-02 | `PROVINCE_OLD.PROVINCE_NEW_ID` và `WARD_OLD.WARD_NEW_ID` là FK "successor" (tỉnh/phường cũ → tỉnh/phường mới tương ứng sau sáp nhập 2025) — cross-entity từ Geographic Area Old sang Geographic Area, khác bản chất với FK phân cấp cha-con (`parent_geographic_area_old_id`). Đặt tên attribute nào cho field này ở LLD? (Đề xuất: `Successor Geographic Area Id` + `Successor Geographic Area Code`.) | Chưa xác nhận — quyết định tại LLD. |
| T1-03 | `PROVINCE_OLD.REGION_ID`/`COUNTRY_ID` là FK "anchor" trỏ từ Geographic Area Old lên Geographic Area (Region/Country dùng chung cho cả 2 hệ phân cấp cũ/mới, không có bản "_OLD" riêng). Đặt tên attribute nào cho field cross-entity này ở LLD? (Đề xuất: `Region Geographic Area Id` + `Region Geographic Area Code`; không lưu `Country Geographic Area Id` riêng vì suy ra được qua Region.) | Chưa xác nhận — quyết định tại LLD. |
| T1-04 | Nguồn có 3 cờ trạng thái riêng biệt trên mỗi bảng: `EFFECTIVE` (hiệu lực/hết hiệu lực), `ACTIVE` (đang dùng/không dùng), `DELETED` (xóa mềm). Atomic có nên gộp cả 3 vào 1 `geographic_area_status_code` (scheme `GEOGRAPHIC_AREA_STATUS`), hay giữ 3 field boolean riêng? | Chưa xác nhận — quyết định tại LLD. |
| T1-05 | Nguồn có cơ chế versioning riêng: `VERSION`, `EFFECTIVE_START_DATE`/`EFFECTIVE_END_DATE`, `STABLE_ID`, `OLD_ID` — gợi ý `ID` là surrogate **theo từng version** (đổi khi record được sửa), còn `STABLE_ID` mới là định danh bền vững xuyên suốt các version. Business Key (BK) cho ETL nên dùng `STABLE_ID` hay `CODE`, không nên dùng `ID`? | Chưa xác nhận — quyết định tại LLD (ảnh hưởng đến cách resolve `parent_code`/FK giữa các version). |
| T1-06 | `ADMINISTRATIVE_PROCEDURE.FEE_UNIT_CURRENCY_ID` là FK **suy luận** (`fk_src: inferred` trong BRD, theo tên cột → CURRENCY.ID), chưa được Data Modeler xác nhận. LLD tạm map thành `Fee Currency Code` (Classification Value, scheme `ECAT_CURRENCY`) qua join `FEE_UNIT_CURRENCY_ID` → `CURRENCY.ID` → `CODE`; `FEE_UNIT_CURRENCY_VERSION_ID` không map. Đồng thời `APPLIED_SUBJECT`/`FIELD_GROUP`/`PROCEDURE_GROUP`/`PROCESSING_TIME_UNIT` là text tự do không có FK — giữ `Text`, chưa chuẩn hóa sang scheme (kể cả `ECAT_APPLIED_SUBJECT`). | Chưa xác nhận — cần Data Modeler xác nhận FK tiền tệ và profile giá trị các cột text trước khi approve LLD. |
| T1-07 | ADMINISTRATIVE_PROCEDURE có 8/9 cột technical bundle (`DELETED`, `CREATED_AT`, `UPDATED_AT`, `CREATED_BY_ID`, `CREATED_BY_NAME`, `UPDATED_BY_ID`, `UPDATED_BY_NAME`, `VERSION`; thiếu `STATUS`) cùng `ACTIVE`/`EFFECTIVE`/`ACTIVE_REASON`/`DELETED_REASON`/`EFFECTIVE_START_DATE`/`EFFECTIVE_END_DATE`/`STABLE_ID`/`OLD_ID`. Theo Bước 2c (bộ chưa đủ 9 cột) phải hỏi Data Modeler thay vì tự loại trừ. LLD tạm loại trừ nhất quán với `Classification ECAT Department` (18 dòng `pending_design.yaml`). Nguồn versioned (ID theo từng version): ETL phải lọc `DELETED = 0`, `EFFECTIVE = 1`, `VERSION` lớn nhất theo `CODE` để mỗi `CODE` chỉ còn 1 dòng. Câu hỏi: có cần map `ACTIVE`/`EFFECTIVE` và audit lên Atomic không? | Chưa xác nhận — nếu cần map, bổ sung attribute vào `lld_ECAT_ADMINISTRATIVE_PROCEDURE.yaml` và gỡ dòng tương ứng khỏi pending_design. |
