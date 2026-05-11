# Technical Fields trên Atomic

Technical fields có prefix `ds_` được ETL framework tự động thêm vào khi implement database.
**Không thiết kế trong file LLD (attr_*.csv).**

| Technical Field | Data Type | Nullable | Mô tả | ETL Pattern áp dụng |
|---|---|---|---|---|
| `ds_etl_pcs_tms` | Timestamp | false | Thời gian xử lý ETL | Tất cả |
| `ds_rcrd_st` | string | false | Trạng thái bản ghi trên Atomic (ACTIVE / INACTIVE) | SCD4A, SCD2 |
| `ds_snpst_dt` | Date | false | Ngày dữ liệu | SCD4A, Fact Snapshot |
| `ds_rcrd_eff_dt` | Date | false | Ngày hiệu lực của bản ghi | SCD2 |
| `ds_rcrd_end_dt` | Date | false | Ngày hết hiệu lực của bản ghi | SCD2 |
| `ds_rcrd_isrt_dt` | Date | false | Thời điểm ETL insert bản ghi vào Atomic lần đầu | SCD4A |
| `ds_rcrd_udt_dt` | Date | false | Thời điểm ETL cập nhật bản ghi gần nhất | SCD4A |
