# Validate Atomic: BRD ↔ LLD ↔ HLD ↔ file tổng hợp (2026-11-07)

Gốc = **LLD** (`DataModel/working/Atomic/lld/*/lld_*.yaml`, 430 file, `design_status` đều approved, 275 entity logic, 18 source).
Đối chiếu: `lld/manifest.yaml`, `hld/atomic_entities.yaml`, `aggregate/atomic_attributes.yaml`, `DataModel/atomic_model.yaml`,
`DataModel/Atomic/dm_manifest.yaml`, 430 file `dm_atm_*.yaml`, `lld/entities/entity_*.yaml`, `pending_design.yaml`, `atomic_out_of_scope.yaml`,
`HLD_Overview` (mục 7a), `BRD/Source`. Draft/AI output — cần human review.

## 1. THIẾU so với LLD — đã bổ sung (6 mục)

| # | File | Lệch | Xử lý |
|---|---|---|---|
| 1 | `lld/manifest.yaml` | `HOSE.BROKERAGE_MARKET_SHARE` và `SCMS.SC_FIRM_ALERT_VIOLATION` còn `design_status: draft`, LLD là `approved` | sửa 2 dòng → approved |
| 2 | `atomic_attributes.yaml` | `SCMS.ALERT_INDICATOR` · `alert_ind_tp_code`: aggregate là `Classification Value`/`string`/có comment scheme; LLD là `Small Counter`/`int` | `aggregate_atomic.py --skip-entities` |
| 3 | `atomic_attributes.yaml` | 5 dòng `src_record_insert_tms` (SCMS: DISCLOSURE_SECURITIES_OFFERING, SC_FIRM_ADHOC_REPORT, SC_FIRM_INSIDER_RELATION, SC_FIRM_MAJOR_SHAREHOLDER_RELATION, SC_FIRM_SHAREHOLDER); LLD/model/dm đều là `src_rcrd_isrt_tms` | sửa tay 5 dòng `atomic_column` |
| 4 | `dm_atm_sc_alert_indicator-SCMS.ALERT_INDICATOR.yaml`, `dm_manifest` | file cũ 26 attr (có `formula`, `sum_formula`, `ind_code`, `ind_nm`, `sort_order`, `record_status_code`…), thiếu `alert_nm`; LLD 20 attr | `generate_dm_yaml.py --source SCMS` |
| 5 | `dm_atm_sc_alert_violation-SCMS.SC_FIRM_ALERT_VIOLATION.yaml`, `dm_manifest` | `table_type` Fact Append (LLD: Relative), `processing_dt` (LLD: `processing_tms`) | như trên |
| 6 | `atomic_model.yaml` | entity `sc_alert_indicator`, `sc_alert_violation` stale như #4–5 | `gen_summary_and_model.py` (không `--source`) |

Nguyên nhân chung: LLD SCMS ALERT_* sửa ở commit `35e52cce` / `dc0ce1db` nhưng không chạy lại chuỗi aggregate → dm → model.

Sau sửa: `git diff --numstat` chỉ chạm 6 file + 2 dm file; `validate_dm_yaml.py` 430/430 OK; `post_check_atomic.py` sạch; script audit chạy lại không còn lệch LLD ↔ file tổng hợp.

**Không chạm:** `dm_atm_cl_value-SCMS.CAT_COMPANY_TYPE.yaml` — generate đổi `status` draft→approved (theo `atomic_entities`: Classification Value = approved, các file dm của entity này đều draft). Đã hoàn tác; xem mục 3.4.

**Rủi ro tái diễn:** `transform_physical_names.py` (chạy trong `aggregate_atomic.py`) tự sinh `src_record_insert_tms` thay vì lấy `physical_name` của LLD → mỗi lần aggregate lại, 5 dòng ở #3 sẽ lệch lại. Cần sửa rule/exception (`system/rules/rule_physical_name_exceptions.csv`: "Source Record Insert Timestamp" → `src_rcrd_isrt_tms`) hoặc cho aggregate ưu tiên LLD.

## 2. THỪA so với LLD — thông tin để bạn quyết định xóa

**Trong 7 lớp file tổng hợp Atomic (atomic_entities, attributes, model, dm_manifest, dm files, manifest, entity_*.yaml): KHÔNG có entity/attribute/file nào thừa** (kiểm tra cả 2 chiều, 0 lệch).
Phần thừa nằm ở BRD / registry:

### 2.1 `atomic_out_of_scope.yaml`: 94 bảng không có trong BRD (không có file cột, không có `brd_entry`)
Có thể là bảng đã đổi tên/bỏ khỏi schema UAT, hoặc bảng khảo sát ngoài BRD. Gợi ý: xóa nếu schema UAT hiện tại không còn.

| Source | SL | Bảng (group) |
|---|---|---|
| ECAT | 1 | SECURITY (Chưa có LLD) |
| FIMS | 19 | AUDIT_LOGS, ERRORLOG, FORM_SCHEMAS, FORM_SCHEMA_VERSIONS, TPOUTHTORY, API_MAPPINGS, DYNAMICCOLUMNS, DYNAMICCONNECTIONS, DYNAMICTABLES, EMAILSENTSYSTEM, MENUS_BU, MENU_CLONE, NOTIFICATION, REFRESHTOKEN, SYSEMAIL, SYSTEMINTEGRATIONCONFIG, SYSTEMINTEGRATIONDATA, USERSMENUS_CLONE, SYSVAR |
| FMS | 35 | FGBRBUP, FUNDHISTORY, SECHISTORY, TLPRHISTORY, GUIDE_FILE, CERTFCATE, PARVALUE, SYSVAR, CONFIG_CONVERT_DATA, DYNAMIC_COLUMNS, DYNAMIC_TABLES, ERROR_LOG, FLAG_RUN_CF, FLYWAY_SCHEMA_HISTORY, INTEGRATION_CONFIG, LOG_CONVERT_DATA(_2), BRCHBUP, FNDBUP, SECBUP, SHEET_OUT_BAK_BMBCDR, TLPROBUP, DTSCBMN, DTSCFND, DTSCFR, DTSCOPE, REFRESHTOKEN, ROLESMENUS, USERRPTO, USERSESSIONS, USERSMENUS, NOTIFICATION, SECURITIESREPORT, SYSEMAIL, TABSINFO |
| NHNCK | 13 | ORGANIZATION_REPORT_LOG_SYNCS, APPLICATION_LOGS, CERTIFICATE_RECORD_LOGS, BACKUP_SCHEDULES, SYSTEM_PARAMETERS, ACTION_LOGS, BACKUPS, DOCUMENT_SIGN_LOGS, EMAIL_LOGS, SEND_AND_RECIEVE_LOGS, SIGNATURE_LOGS, SMS_LOGS, CERTIFICATE_CONVERSION_REQUEST_LOGS |
| SCMS | 22 | SYS_AUDIT_LOG, SMSNEWS, SMSOFFEROFSTOCKS, SMSREPORTDATA, SMSTLLOG, SMSVW_SECURITIES, SMSVW_TLPROFILES, SCMS_SYSTEM_PARAM, SSC_NOTIFICATION(_RECIPIENT), SYS_CONFIG_PARAM, SYS_EXPORT_FULL_01/02, SYS_FUNCTION(_DETAIL), SYS_ORGANIZATION, SYS_USER(_BACKUP/_GROUP/_LOGIN_LOG), SYS_WORKING_CALENDAR, FLYWAY_SCHEMA_HISTORY |
| THANHTRA | 1 | NOTIFICATION |
| TMS | 2 | ACCOUNT_FINANCIAL_SERVICE (Chưa có LLD), ACCOUNT_AUTHORIZATION (Khảo sát sai) |
| VSDC | 1 | ACCOUNT_OPENING_CLOSING_STATUS (Fact Data) |

Ngược lại, BRD ghi `out_of_scope` 810 bảng nhưng registry chỉ có 517 (387 bảng BRD-out_of_scope không có trong registry) — registry sinh từ HLD 7f nên không phải lỗi; chỉ cần biết nếu dùng registry làm danh sách đầy đủ.

### 2.2 BRD `in_scope` nhưng không có LLD (34 bảng) — BRD "thừa" hoặc LLD thiếu?
Phần lớn là bảng nguồn của luồng ODS/flatten hoặc danh mục địa lý đã gộp vào entity khác; HLD đã nhắc. Cần bạn xác nhận: hạ BRD `scope_status` về `out_of_scope`/`pending`, hay thiết kế bổ sung LLD.

| Nhóm | Bảng | Ghi chú |
|---|---|---|
| ODS flatten, có LLD ở bảng ODS | FIMS: RPTTEMP, SHEET, RPTMEMBER, RPTVALUES, TRADINGREPRESENTATIVE, STOCKEXCHANGE, DEPOSITORYCENTER, FUNDCOMPANY, BRANCHS, INFODISCREPRES · ISS: FACT_REPORT_DATA, INPUT_REPORT, INPUT_REPORT_METRIC, INPUT_REPORT_SUBMISSION, INPUT_REPORT_TEMPLATE, INPUT_REPORT_TEMPLATE_SHEET · TTHC: DOCUMENT, CONTENTITEMINDEX | HLD có nhắc (ISS: 1 entity `Internal Statistical Report` flatten từ 6 bảng; FIMS "qua ODS"; TTHC 3 bảng ODS). Không bảng nào có trong `lld/entities/*.yaml` hay manifest `pending` |
| Địa lý | FIMS: NATIONAL, PROVINCE_NEW, WARD_NEW · FMS: NATIONAL, PROVINCE, WARD · IDS: PROVINCES · NHNCK: COUNTRIES, PROVINCES, DISTRICTS · SCMS: CAT_PROVINCE, CAT_DISTRICT, CAT_WARD, CAT_NATIONALITY | `entity_geographic_area*.yaml` chỉ có 4+3 source; HLD IDS ghi "dùng shared Geographic Area từ NHNCK" nhưng HLD NHNCK Overview **không nhắc** PROVINCES/COUNTRIES/DISTRICTS |
| Khác | ECAT.UBCK_STAFF (HLD D-01: chỉ audit FK), NHNCK.USERS (HLD 7f: loại khỏi scope 2026-07-07) | BRD in_scope mâu thuẫn HLD |

### 2.3 Cột BRD chưa map vào LLD
`post_check_source_coverage.py`: 606 cột nguồn chưa map và chưa pending; 576 cột pending. Danh sách đầy đủ: `docs/atomic_validation_2026-11-07_source_coverage.txt`. Hầu hết ghi chú "Không thiết kế ở LLD (commit 660df05b, 2026-10-28)" — quyết định đã duyệt, chỉ xem lại nếu muốn bổ sung.

### 2.4 Status chưa đồng nhất (thông tin)
`Classification Value`: `atomic_entities` approved, nhưng model + dm_manifest đều draft (entity gộp nhiều source; trạng thái entity ≠ trạng thái từng dm file). Vòng đời `status` là review của người thiết kế (65 approved / 210 draft ở `atomic_entities`; 6518/46 attribute draft/approved trong LLD) — không tự đồng bộ.

### 2.5 `pending_design.yaml`: 9 cột trỏ vào cột không có trong BRD
SCMS.SC_FIRM_REP_OFFICE (SO_QUYET_DINH, NGAY_QUYET_DINH), SCMS.SC_FIRM_INSIDER_RELATION.STATUS, SCMS.SC_FIRM_LICENSED_PRACTITIONER.SOCMT, AUDIT.AF_TECHNICAL_AUDIT.LOGIN_PERMISSION_BY_CODE, IDS.REPORT_CATALOG/RROW/RCOL.SYSTEM_CD, FMS.SHEET.DELETED.
Có thể cột đã bị đổi tên/xóa ở schema UAT → xóa dòng pending, hoặc BRD thiếu cột (xem mục 3.2). Ngoài ra 2 attribute `status: pending` không có dòng pending_design: `IAM.USERS.practice_certificate_tp_id`, `NHNCK.CERTIFICATE_RECORD_GROUPS.group_tp_code`.

## 3. BRD / HLD THIẾU so với LLD — cần bạn quyết định cách bổ sung

### 3.1 LLD có bảng nhưng BRD không có entry + file cột (13 bảng; phần lớn là bảng ODS không BRD, theo HLD)
FIMS: CL_FOREIGN_INVESTOR_REPORTING_ENTITY, FIR_STRUCTURE, FIR_VALUE, FOREIGN_INVESTOR_REPORT · FMS: ITEM_LIST, ITEM_VALUE, REPORT_HISTORY, THRESHOLD_CONFIG, WEIGHT_CONFIG · ISS: INTERNAL_STATISTICAL_REPORT · TTHC: AP_DOCUMENT, AP_DOCUMENT_APPLICANT, CLASSIFICATION_VALUE.
FMS/FIMS dynamic report: HLD ghi rõ "không có BRD". Làm thế nào để các bảng ODS có BRD Source (hay chấp nhận ngoại lệ) là quyết định của bạn; mình chưa tạo để tránh bịa cột.

### 3.2 `source_columns` trong LLD trỏ cột không có trong BRD column file (5 LLD)
| LLD | Cột |
|---|---|
| FMS/lld_FMS_SHEET | CELL_ID, COLUMN_INDEX, COLUMN_SPAN, LABEL_NM, ROW_INDEX, ROW_SPAN |
| SCMS/lld_SCMS_FORM_REPORT_DEEP_CONFIG | CELL_ID, SHEET_CODE, SHEET_ID |
| SCMS/lld_SCMS_REPORT_INPUT_CELL_VALUE | DATA_DT |
| SCMS/lld_SCMS_REPORT_INPUT_SUBMISSION | DATA_DT |
| SCMS/lld_SCMS_SC_FIRM_PROFILE_CHANGE | 17 cột (CTCKCHINHANHTEN, DIACHI, TENCTCK, TENDAYDU, VONDIEULE, WEBSITE, PHONE, GIAMDOC, MACHUNGKHOAN, …) |
Chưa kết luận BRD thiếu hay LLD sai: cần đối chiếu `Source/DDL UAT*` (tên cột dạng `*_DT`, viết liền không dấu gạch gợi ý cột do ODS/JSON sinh). Cần bạn xác nhận.

### 3.3 HLD Overview mục 7a thiếu dòng cho entity có LLD (9 entity)
| Source | Entity | Hiện ở đâu |
|---|---|---|
| FMS | Dynamic Report Structure / Submission History / Value, Risk Weight Config, Status Threshold Config | chỉ trong dòng thay đổi [MỚI 2026-11-07] của Overview + Tier1/Tier6; chưa có dòng bảng 7a |
| AUDIT, FMS, IDS, SCMS | Classification Value | HLD xử lý ở mục 7c (hợp lệ, không phải lỗi) |
→ 5 entity FMS cần thêm dòng 7a (cần chạy `atomic-hld-design`; không tự sửa vì HLD của FMS đang có thay đổi 2026-11-07 chưa chốt nội dung).

### 3.4 Mục ghi nhận, không phải lỗi
- 63 LLD có `physical_name` trùng trong cùng file: đều là shared entity `IP_Alt_Identification` / `IP_Electronic_Address` / `IP_Postal_Address` (1 dòng/context) — theo thiết kế.
- `Securities Company Organization Unit`: LLD ghi concept riêng từng bảng; `atomic_entities`/`dm_manifest` ghi gộp "[IP] Branch, [IP] Representative Office" — theo thiết kế entity gộp.
