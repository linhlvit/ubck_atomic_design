# Note logic cot ODS TMS_REPORT / TMS_REPORT_VALUE (de design Atomic)

ODS: `ods.uat_TMS_ods.tms_report`, `tms_report_value` (model `ods_tms_report`, `ods_tms_report_value`). Strategy append, khong partition -> moi lan chay truncate + insert toan bo bang, khong co `ds_snpst_dt`; chi co `ds_etl_pcs_tms`. Nguon: cac stg_tms_compliance_report_* cua ngay etl_date (loai deleted = 0). Phai chay `ods_tms_report` truoc `ods_tms_report_value`.

Luu y: moi lan chay ODS chi chua du lieu snapshot cua dung etl_date (stg lat cat theo ngay) -> Atomic tu quyet dinh SCD/upsert theo khoa nghiep vu.

## 1. ods_tms_report - 1 dong = 1 chi tieu cua 1 template bao cao
Nguon: `stg_tms_compliance_report_form_template` ft LEFT JOIN `stg_tms_compliance_report_template` tpl (tpl.id = ft.template_id, deleted = 0), LATERAL VIEW OUTER posexplode(from_json(ft.table_header_layout, headerRows)[0]) -> chi lay dong header DAU TIEN (headerRows[0]); loai dong columnCode IS NULL.
Khoa de xuat: (report_template_id, indicator_code).

| # | Cot | Kieu | Logic |
|---|---|---|---|
| 1 | report_template_id | string | ft.id |
| 2 | template_group_id | string | ft.template_id |
| 3 | report_code | string | ft.form_code (vd PL01_W_F01) |
| 4 | report_name | string | ft.form_name |
| 5 | report_description | string | ft.description |
| 6 | is_mandatory | int | ft.is_mandatory |
| 7 | display_order | int | ft.display_order |
| 8 | status | int | ft.status |
| 9 | version | bigint | ft.version |
| 10 | aggregation_mode | string | ft.aggregation_mode |
| 11 | require_signature | int | ft.require_signature |
| 12 | approval_type | string | ft.approval_type |
| 13 | key_columns | string | ft.key_columns |
| 14 | indicator_order | int | vi tri (posexplode, bat dau 0) cua cot trong headerRows[0] |
| 15 | indicator_code | string | ind.columnCode (COL_xx) |
| 16 | indicator_label | string | ind.label |
| 17 | created_at | timestamp | ft.created_at |
| 18 | updated_at | timestamp | ft.updated_at |
| 19 | _source_system | string | hang so compliance_report_form_template |
| 20 | template_code | string | tpl.template_code |
| 21 | ds_etl_pcs_tms | timestamp | current_timestamp() |

## 2. ods_tms_report_value - 1 dong = 1 chi tieu (1 o) cua 1 dong du lieu trong 1 lan nop
Nguon: `stg_tms_compliance_report_data` d JOIN `..._form` f (f.id = d.report_form_id) JOIN `..._master` m (m.id = f.report_master_id) JOIN `..._form_template` ft (ft.id = f.form_template_id); deleted = 0 o d, f, m. LATERAL VIEW explode(from_json(d.row_data, map<string,string>)) -> moi key (COL_xx) 1 dong.
Khoa de xuat: (submission_id, indicator_code).

| # | Cot | Kieu | Logic |
|---|---|---|---|
| 1 | report_code | string | ft.form_code |
| 2 | indicator_code | string | key cua ROW_DATA (COL_xx) |
| 3 | indicator_label | string | COALESCE(layout.column_label, layout.business_key, ods_tms_report.indicator_label); layout theo DUNG report_form_id |
| 4 | indicator_value | string | COALESCE(get_json_object(cell, $.value), cell) - o co the la JSON {"value":...} hoac text |
| 5 | data_date | date | CAST(m.submission_date AS date) - ngay nop bao cao |
| 6 | row_index | bigint | d.row_index |
| 7 | submission_id | string | d.id (id dong du lieu goc) |
| 8 | _source_system | string | hang so compliance_report_data |
| 9 | report_form_id | string | f.id (lan nop) |
| 10 | period_type | string | f.period_type |
| 11 | period_value | int | f.period_value |
| 12 | period_year | int | f.period_year |
| 13 | submitter_type | string | f.submitter_type |
| 14 | upload_date | timestamp | f.upload_date |
| 15 | file_name | string | f.file_name |
| 16 | row_date_key | string | gia tri COL_01 cua cung dong (MAX(...) OVER PARTITION BY d.report_form_id, d.row_index); lay $.value neu la JSON |
| 17 | indicator_business_key | string | COALESCE(layout.business_key, layout.column_label, ods_tms_report.indicator_label) |
| 18 | ds_etl_pcs_tms | timestamp | current_timestamp() |

### Layout theo report_form_id (CTE form_layout)
- layout_dynamic: table_header_layout.dynamicBlocks.*.columns[*] cua `..._form` (columnCode, businessKey, columnLabel).
- layout_fixed: table_header_layout.headerRows[*][*] (columnCode, label); rieng COL_01 gan nhan co dinh "Ngay/ ma chung khoan" (co dau trong code) cho ca business_key va column_label.
- Gop: uu tien dynamic (src=1), thieu thi fixed (src=2); 1 dong / (report_form_id, column_code).
- Join vao dong gia tri theo (report_form_id, indicator_code = column_code). `ods_tms_report` chi la fallback nhan khi layout cua lan nop khong co cot do (join theo report_template_id + indicator_code).

## Diem can Atomic/BA chu y
- indicator_value dang text; da BO cot indicator_value_number (theo BA 2026-11-11) - Atomic tu cast neu can.
- Dung chung dinh danh report_code giua 2 bang (deu lay tu form_template.form_code).
- Chua kiem tra: business_key co the trung nhau giua cac COL_xx khac nhau trong 1 form dynamic.
