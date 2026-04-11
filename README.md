# UBCK Data Model — Silver Layer Design Repository

> **Mục đích:** Lưu trữ và quản lý thiết kế HLD và LLD cho Silver layer trên kiến trúc Medallion (Bronze / Silver / Gold), phục vụ dự án Lakehouse của UBCKNN.

---

## Cấu trúc thư mục

```
ubck_atomic_design/
├── Silver/
│   ├── hld/                                      # HLD — thiết kế mức entity
│   │   ├── <SYSTEM>_HLD_Tier<N>.md               # Thiết kế theo Tier dependency
│   │   ├── <SYSTEM>_HLD_Overview.md              # Tổng quan toàn bộ source system
│   │   └── silver_entities.csv                   # Tổng hợp tất cả Silver entities (auto-gen)
│   └── lld/
│       ├── DCST/                                 # Source system: DCST
│       │   └── attr_DCST_<TABLE>.csv
│       ├── FMS/                                  # Source system: FMS
│       │   └── attr_FMS_<TABLE>.csv
│       ├── NHNCK/                                # Source system: NHNCK
│       │   └── attr_NHNCK_<TABLE>.csv
│       ├── scripts/
│       │   └── aggregate_silver.py               # Script tổng hợp attributes + entities
│       ├── manifest.csv                          # Danh sách tất cả LLD files + entity mapping
│       ├── ref_shared_entity_classifications.csv # Chuẩn hóa Classification Value scheme/code
│       └── silver_attributes.csv                 # Tổng hợp tất cả attributes (auto-gen)
├── Source/                                       # Cấu trúc CSDL nguồn
│   ├── <SYSTEM>_Source_Tables.*
│   └── <SYSTEM>_Source_Columns.*
├── knowledge/                                    # BCV knowledge base
│   ├── terms.csv
│   ├── term_relationships.csv
│   └── reference_data_sets.csv
└── .claude/
    └── skills/
        ├── SKILL_HLD.md                          # Quy trình thiết kế HLD
        └── SKILL_LLD.md                          # Quy trình thiết kế LLD
```

---

## Quy trình thiết kế

### Giai đoạn 1 — HLD (High-Level Design)

**Mục tiêu:** Xác định Silver entities, BCV Concept, và quan hệ giữa entities. Chưa đi vào chi tiết từng cột.

#### Input

| Loại | Vị trí |
|---|---|
| Cấu trúc CSDL nguồn | `Source/*_Tables.*`, `*_Columns.*` |
| BCV knowledge base | `knowledge/terms.csv`, `term_relationships.csv`, `reference_data_sets.csv` |
| HLD source system liên quan (nếu có) | `Silver/hld/*.md` |

#### Phương pháp

**Phân tầng theo dependency — không theo nhóm nghiệp vụ:**

| Tier | Định nghĩa |
|---|---|
| Tier 1 | Không FK đến bảng nghiệp vụ nào (chỉ FK đến danh mục) |
| Tier 2 | FK đến entity Tier 1 |
| Tier N | FK đến entity Tier N-1 |

Quy tắc bổ sung:
- Nhiều entity cùng mức dependency → gộp vào 1 Tier
- Circular reference trong cùng Tier → giữ nguyên, ghi vào mục 6f
- Nếu source system đã có cách đặt tên Tier riêng → vẫn phải phân tích lại dependency từ đầu

**Phân loại bảng nguồn:**

| Loại | Xử lý |
|---|---|
| Bảng có instance data | → Silver entity |
| Bảng chỉ có Code + Name | → Classification Value (không tạo entity) |
| Junction chỉ 2 trường FK | → Denormalize thành ARRAY trên entity cha |
| Audit Log / Snapshot nguồn | → Ngoài scope Silver |
| Bảng chưa có cột | → Ghi vào 6e, chờ thông tin |

**Tra BCV bắt buộc** trước khi gán Concept — grep trên `knowledge/`, kiểm tra bằng cấu trúc trường thực tế, không suy luận từ tên bảng.

#### Output mỗi Tier — `<SYSTEM>_HLD_Tier<N>.md`

| Mục | Nội dung |
|---|---|
| **6a** | Bảng tổng quan BCV Concept — entity mới của Tier kèm lý do chọn BCV Term |
| **6b** | Diagram Source (Mermaid) — FK giữa các bảng nguồn |
| **6c** | Diagram Silver (Mermaid) — Silver entities và quan hệ |
| **6d** | Danh mục & Tham chiếu — bảng nguồn map thành Classification Value |
| **6e** | Bảng chờ thiết kế — bảng chưa có cột |
| **6f** | Điểm cần xác nhận — câu hỏi mở cần người thiết kế quyết định |

#### Output sau Tier cuối — `<SYSTEM>_HLD_Overview.md`

| Mục | Nội dung |
|---|---|
| **7a** | Bảng tổng quan tất cả Silver entities (gộp 6a mọi Tier, thêm cột Tier) |
| **7b** | Diagram Silver tổng — 1 diagram toàn bộ data model |
| **7c** | Toàn bộ Classification Value |
| **7d** | Toàn bộ junction table và cách denormalize |
| **7e** | Toàn bộ điểm cần xác nhận còn mở |
| **7f** | Toàn bộ bảng ngoài scope |

Sau HLD Overview → cập nhật `Silver/hld/silver_entities.csv`.

---

### Giai đoạn 2 — LLD (Low-Level Design)

**Mục tiêu:** Thiết kế chi tiết từng attribute — tên, data domain, FK target, nullable, source column mapping.

**Điều kiện tiên quyết:** HLD đã được duyệt.

#### Input

| Loại | Vị trí |
|---|---|
| HLD Overview + HLD Tier tương ứng | `Silver/hld/*.md` |
| Cấu trúc CSDL nguồn | `Source/*_Columns.*` |
| LLD đã có cùng source system | `Silver/lld/<SYSTEM>/attr_*.csv` |
| LLD entity tương đồng source khác | `Silver/lld/<OTHER>/attr_*.csv` |
| Classification Value đã chuẩn hóa | `Silver/lld/ref_shared_entity_classifications.csv` |
| Danh sách entity đã có | `Silver/lld/manifest.csv` |

#### Quy tắc mapping cột nguồn

| Loại trường | Quy tắc |
|---|---|
| PK bảng nguồn | → Entity Code (BK), data domain = `Text` |
| FK đến Fundamental entity | → Cặp `[Entity] Id` (`Surrogate Key`) + `[Entity] Code` (`Text`) |
| FK đến Classification Value / danh mục | → 1 trường Code duy nhất, data domain = `Classification Value` |
| Địa chỉ / liên lạc / giấy tờ (grain = 1 IP) | → Tách ra file shared entity riêng |

**12 Data Domain chuẩn:** Text, Date, Timestamp, Currency Amount, Interest Rate, Exchange Rate, Percentage, Surrogate Key, Classification Value, Indicator, Boolean, Small Counter.

#### Output mỗi entity — `attr_<SYSTEM>_<SourceTable>.csv`

Cấu trúc 10 cột:

| Cột | Mô tả |
|---|---|
| `attribute_name` | Tên attribute trên Silver (tiếng Anh) |
| `description` | Mô tả gốc nguồn + mô tả bổ sung model |
| `data_domain` | 1 trong 12 Data Domain chuẩn |
| `nullable` | `true` / `false` |
| `is_primary_key` | `true` / `false` |
| `status` | `draft` / `reviewed` / `approved` |
| `source_columns` | Fully qualified: `SYSTEM.schema.Table.Column` |
| `comment` | FK target, Scheme code, lý do thiết kế |
| `classification_context` | Shared entity: `SCHEME=VALUE` (1 dòng / 1 context) |
| `etl_derived_value` | Giá trị ETL-derived cố định (không lấy từ cột nguồn) |

Sau mỗi file attr → cập nhật `manifest.csv` và `ref_shared_entity_classifications.csv`.

#### Bước tổng hợp cuối

```bash
cd <workspace_root>
python Silver/lld/scripts/aggregate_silver.py
```

Script tự động sinh:
- `Silver/lld/silver_attributes.csv` — toàn bộ attributes (13 cột)
- `Silver/hld/silver_entities.csv` — toàn bộ entities (5 cột)

---

## Trạng thái thiết kế

| Status | Ý nghĩa |
|---|---|
| `draft` | Mới thiết kế, chưa review |
| `reviewed` | Đã review với team, có thể còn điểm xác nhận SME |
| `approved` | Đã duyệt, sẵn sàng chuyển Engineer |

---

## Source systems hiện tại

### NHNCK — Người Hành Nghề Chứng Khoán

| Tier | Số entities | HLD file |
|---|---|---|
| Tier 1 | 4 entities | `NHNCK_HLD_Tier1.md` |
| Tier 2 | 4 entities | `NHNCK_HLD_Tier2.md` |
| Tier 3 | 12 entities | `NHNCK_HLD_Tier3.md` |
| Tier 4 | 7 entities | `NHNCK_HLD_Tier4.md` |

LLD: 34 files trong `Silver/lld/NHNCK/` — tất cả `draft`.

### DCST — Dữ liệu Cơ quan Thuế

| Tier | Số entities | HLD file |
|---|---|---|
| Tier 1 | 3 entities | `DCST_HLD_Tier1.md` |
| Tier 2 | 6 entities | `DCST_HLD_Tier2.md` |
| Tier 3 | 2 entities | `DCST_HLD_Tier3.md` |

LLD: 14 files trong `Silver/lld/DCST/` — tất cả `draft`.

### FMS — Quản lý Giám sát Quỹ và Công ty Chứng khoán

| Tier | Số entities | HLD file |
|---|---|---|
| Tier 1 | 7 entities | `FMS_HLD_Tier1.md` |
| Tier 2 | 7 entities | `FMS_HLD_Tier2.md` |
| Tier 3 | 5 entities | `FMS_HLD_Tier3.md` |
| Tier 4 | 3 entities | `FMS_HLD_Tier4.md` |

LLD: 38 files trong `Silver/lld/FMS/` — tất cả `draft`.

---

## Tham chiếu nhanh

| Tài liệu | Vị trí |
|---|---|
| Quy trình thiết kế HLD | `.claude/skills/SKILL_HLD.md` |
| Quy trình thiết kế LLD | `.claude/skills/SKILL_LLD.md` |
| HLD files | `Silver/hld/` |
| LLD files | `Silver/lld/<SYSTEM>/` |
| Tổng hợp entities | `Silver/hld/silver_entities.csv` |
| Tổng hợp attributes | `Silver/lld/silver_attributes.csv` |
| Manifest | `Silver/lld/manifest.csv` |
| Shared Entity Classifications | `Silver/lld/ref_shared_entity_classifications.csv` |
| BCV knowledge base | `knowledge/` |
