# Technical Fields trên Atomic

Technical fields có prefix `ds_` là field kỹ thuật do ETL framework quản lý — **không map 1:1 từ
1 cột nguồn cụ thể** (`source_column: null`). Nhưng khác với quy ước cũ, các field này **PHẢI được
khai báo tường minh trong `attributes:` của entity YAML** (`DataModel/Atomic/{BCV}/dm_atm_*.yaml`,
Nguồn 1) cho mọi entity thuộc `table_type` áp dụng.

> **[SỬA 2026-09-07]** Trước đây rule ghi "LLD không bao gồm technical fields (ds_*)" — coi các
> field này là ẩn, do ETL framework tự thêm khi implement database, không cần thiết kế tường minh.
> Đã đảo ngược sau khi phát hiện gap thực tế (module GSDC, K_GSDC_1389/1390, Nhóm 31): entity
> `pc_state_capital` (`table_type: Fundamental`) thực tế có nguồn chứa `ds_snpst_dt` (staging
> `uat_ids_stg.state_capital`, xác nhận qua BA SQL — CTE `loaiky` dùng `MAX(ds_snpst_dt)` theo
> `YEAR/MONTH`), nhưng vì field không được liệt kê trong entity YAML nên Datamart designer không có
> cách nào biết field đó tồn tại — dẫn tới báo PENDING sai (kết luận nhầm "thiếu audit field
> created_date/update_dated" trong khi thực chất chỉ là field chưa được khai báo tường minh trên
> Atomic). Nguyên tắc mới: Atomic entity phải tự mô tả đầy đủ (self-describing) để skill Datamart
> HLD/LLD tra cứu trực tiếp bằng `attribute.physical_name`, không cần biết ngầm quy ước ETL framework.

## Bộ 5 field chuẩn SCD4A (`table_type: Fundamental`, `etl_pattern: SCD4A`)

| Technical Field | Data Type | Nullable | Mô tả | Áp dụng |
|---|---|---|---|---|
| `ds_rcrd_st` | string | false | Trạng thái bản ghi (`ACTIVE` = Active, `INACTIVE` = Deleted) | Active + History |
| `ds_rcrd_isrt_dt` | Date | false | Ngày insert lần đầu | Active + History |
| `ds_rcrd_udt_dt` | Date | false | Ngày update gần nhất | Active + History |
| `ds_etl_pcs_tms` | Timestamp | false | Timestamp xử lý ETL | Active + History |
| `ds_snpst_dt` | Date | false | Ngày snapshot | **Chỉ History** — không khai báo trên bảng Active |

**Bắt buộc:** Mọi entity `table_type: Fundamental` (etl_pattern `SCD4A`) PHẢI khai báo 4 field đầu
(`ds_rcrd_st`, `ds_rcrd_isrt_dt`, `ds_rcrd_udt_dt`, `ds_etl_pcs_tms`) trong `attributes:`. Nếu entity
có phần History riêng (giữ nhiều kỳ, không overwrite) → bảng/biến thể History khai báo thêm
`ds_snpst_dt`. Entity `table_type: Fact Snapshot` (không phải cặp Active/History mà bản thân là
snapshot theo kỳ) khai báo `ds_snpst_dt` + `ds_etl_pcs_tms` (không cần `ds_rcrd_st`/`isrt_dt`/`udt_dt`
vì mỗi dòng là 1 lần chụp bất biến, không có khái niệm "update tại chỗ").

**Mẫu khai báo (ví dụ `ds_snpst_dt` trên entity History/Fact Snapshot):**

```yaml
  - name: Snapshot Date
    physical_name: ds_snpst_dt
    business_meaning: Ngày chụp snapshot của bản ghi (kỳ nạp dữ liệu).
    data_domain: Date
    data_type: date
    nullable: false
    is_primary_key: false
    source_system: "{SOURCE}"
    source_table: "{TABLE}"
    source_column: null
    comment: "Technical field (prefix ds_) — do ETL framework quản lý, không map 1:1 từ cột nguồn."
    classification_context: null
    etl_derived_value: null
```

## Field SCD2 (`table_type: Relative`, `etl_pattern: SCD2`)

| Technical Field | Data Type | Nullable | Mô tả | ETL Pattern áp dụng |
|---|---|---|---|---|
| `ds_etl_pcs_tms` | Timestamp | false | Thời gian xử lý ETL | Tất cả |
| `ds_rcrd_eff_dt` | Date | false | Ngày hiệu lực của bản ghi | SCD2 |
| `ds_rcrd_end_dt` | Date | false | Ngày hết hiệu lực của bản ghi | SCD2 |

## Field khác (`Fact Append`, `Classification`)

| Technical Field | Data Type | Nullable | Mô tả | ETL Pattern áp dụng |
|---|---|---|---|---|
| `ds_etl_pcs_tms` | Timestamp | false | Thời gian xử lý ETL | Tất cả |

`Fact Append` không có khái niệm update/snapshot theo kỳ (insert-only, mỗi dòng 1 occurrence) nên
chỉ cần `ds_etl_pcs_tms`.
