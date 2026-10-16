# Yêu cầu bổ sung / xác nhận trên Atomic — module QLKD (phạm vi Dashboard)

- **Ngày lập:** 2026-10-15
- **Người lập:** Data Modeler Datamart QLKD (soạn cùng Claude — đây là draft, cần Data Modeler duyệt trước khi gửi Atomic Team)
- **Phạm vi:** chỉ các nhóm **Dashboard** của QLKD = Nhóm 1–44 (tab TỔNG QUAN, GIÁM SÁT, HỒ SƠ CTCK 360, HỒ SƠ CTCK 360 (NHNCK), TRA CỨU CÁ NHÂN). **Không gồm Data Explorer (Nhóm 45–178)** — các yêu cầu chỉ phục vụ Data Explorer (công thức ô `FORMULA`, bảng `SCMS_MAP_CT`, JSON của `SC_FIRM_PROFILE_CHANGE`, báo cáo định kỳ chi nhánh nước ngoài/ngân hàng lưu ký) đã loại khỏi tài liệu này.
- **Căn cứ:** rà soát LLD `Datamart/lld/QLKD/` (Gate 0), các mục Open O_QLKD_13/30/32/34/39/42/43 trong `Datamart/hld/DTM_QLKD_HLD.md`, đối chiếu trực tiếp `DataModel/Atomic/` (`dm_manifest.yaml`), `DataModel/working/Atomic/lld/`, `BRD/Source/`.
- **Nguyên tắc:** mỗi yêu cầu đã kiểm lại với file Atomic hiện hành. Điểm từng ghi là "thiếu Atomic" nhưng thực tế đã có, hoặc là lỗi mapping phía Datamart, được tách ở mục 3.

## 1. Tóm tắt

| ID | Entity Atomic | Cần bổ sung / xác nhận | Ưu tiên | Nhóm Dashboard bị ảnh hưởng |
|---|---|---|---|---|
| AQ-01 | `sc_disclosure_securities_offering` | Thêm `created_tms`; kiểm tra ETL nạp `offering_tp_code` (Loại chào bán, đang NULL 100%) | Cao | Nhóm 13 — Nguồn vốn tăng thêm (K_QLKD_66–72) |
| AQ-02 | 6 entity THANHTRA (`examination_team`, `examination_team_target`, `inspection_team`, `inspection_team_target`, `pd_subject`, `pd_subject_behavior`) | Xác nhận đã loại bản ghi `DELETED = 1`, hoặc thêm cờ xóa | Cao | Nhóm 40 — Lịch sử xử phạt thanh tra kiểm tra (K_QLKD_195–202); Nhóm 44 — Lịch sử vi phạm xử phạt cá nhân (K_QLKD_218–223) |
| AQ-03 | `sc_report_deep_config` (+ `sc_report_input_value`) | Duyệt `draft` → `approved`; xác nhận `sheet_id` khớp và quy ước `cell_id` | Cao | Nhóm 8, 9, 11, 12, 15, 16, 19 (KPI lọc theo `cell_id`: K_QLKD_42–47, 49–52, 60–63, 65, 79–85, 87, 102–106) |
| AQ-04 | `sc_ou_x_cl_sc_firm_service_relationship`, `cl_securities_company_firm_service` | Xác nhận 3 giả định (không có `record_status`, giá trị `sc_ou_code`, phạm vi bản ghi) | Trung bình | Nhóm 33, 34, 35, 37 (K_QLKD_165–177, 181–185) |
| AQ-05 | `ip_alternative_identification` (SCMS.SC_FIRM_BRANCH) và `sc_organization_unit` | Map `DECISION_DATE` của chi nhánh; xác nhận lọc `RECORD_STATUS` | Cao | Nhóm 32–35, 37 (K_QLKD_162–164, 166–177, 181–185) |
| AQ-06 | `sc_alert_violation` (SCMS.SC_FIRM_ALERT_VIOLATION) | Resolve `alert_entity_code` cho CN/PGD/VPĐD; xác nhận giá trị `ENTITY_TYPE` | Cao | Nhóm 36 — Duy trì điều kiện cấp phép (K_QLKD_178–180, đang PENDING) |

## 2. Chi tiết

### AQ-01 — `sc_disclosure_securities_offering`: thiếu ngày tạo bản ghi; `offering_tp_code` (Loại chào bán) chưa có dữ liệu

**Đề xuất**
1. Thêm `created_tms` (timestamp) ← `SCMS.DISCLOSURE_SECURITIES_OFFERING.CREATED_AT` (cột có trong `BRD/Source/SCMS/brd_SCMS_DISCLOSURE_SECURITIES_OFFERING.yaml`).
2. Kiểm tra ETL nạp `offering_tp_code` ← `SCMS.DISCLOSURE_SECURITIES_OFFERING.OFFERING_TYPE`. Theo model Atomic, `offering_tp_code` chính là **Loại chào bán** (BRD: 1 = Chào bán ra công chúng, 2 = Cổ phiếu thưởng, 3 = Trả cổ tức bằng CP, 4 = CTLC NLĐ trên 100 người, 5 = CTLC NLĐ dưới 100 người, 6 = Đấu giá, 7 = Chào bán riêng lẻ, 8 = Khác, 9 = Phát hành CP hoán đổi, 10 = CB cổ đông lớn). Không cần nạp thêm `loaiChaoBan` vào `offering_method`.

**Lý do cần ở Atomic**
- BA STT 13 (ghi chú "Sửa 12/10") đổi trục thời gian thành `COALESCE(DOCUMENT_DATE, CREATED_AT)` và lọc `CREATED_AT IS NOT NULL`. Atomic chưa có `CREATED_AT` nên Datamart không thể đổi trục theo BA.
- Dữ liệu `atm_sc_disclosure_securities_offering` (kiểm 12/10, 84 dòng CP/TP đang hiệu lực): `result_rpt_dt` NULL 84/84; `document_dt` NULL 3/84; `proceeds_collected_amt` chỉ có 2/84 dòng và nhiều khả năng nằm trong 3 dòng thiếu `document_dt` — chỉ cứu được nếu có `created_tms`. Nguồn SCMS: 18/532 dòng thiếu `DOCUMENT_DATE`, cả 18 dòng có `CREATED_AT`.
- `offering_tp_code` (Loại chào bán) hiện **NULL 100%** trên Atomic (kiểm 12/10). Datamart đã chuyển sang phân loại theo `offering_tp_code` (2026-10-15) và tạm dự phòng bằng `offering_method` — cột này chỉ có mã ở 6/84 dòng (`CHAO_BAN_RIENG_LE` 3, `CHAO_BAN_RA_CONG_CHUNG` 2, `TRA_CO_TUC_BANG_CP` 1, trống 78/84) — nên 78/84 dòng vẫn chưa phân loại được cho tới khi `offering_tp_code` có dữ liệu.
- Cần xác nhận thêm: nguồn có 532 dòng CP/TP có `PLAN_JSON` nhưng `RECORD_STATUS = 1` chỉ 42; Atomic chỉ có 98 dòng — Atomic đang lọc theo tiêu chí nào?

**Datamart sẽ làm khi có:** đổi trục thời gian của Fact `fct_securities_company_capital_raising_event` thành `COALESCE(document_dt, created_tms)`; bỏ dự phòng `offering_method` khỏi `offering_form_dim` khi `offering_tp_code` đã có dữ liệu. Tham chiếu: O_QLKD_39.

### AQ-02 — THANHTRA: Atomic không có cột xóa mềm

**Hiện trạng đã kiểm**
- BRD của 6 bảng nguồn đều có cột `DELETED`: `EXAMINATION_TEAM`, `EXAMINATION_TEAM_TARGET`, `INSPECTION_TEAM`, `INSPECTION_TEAM_TARGET`, `PENALTY_DECISION_SUBJECT`, `PENALTY_DECISION_SUBJECT_BEHAVIOR`.
- Các entity Atomic tương ứng **không có** cột `deleted` hay cờ tương đương.

**Đề xuất:** (a) xác nhận ETL Atomic đã loại bản ghi `DELETED = 1` trước khi nạp; hoặc (b) thêm `deleted_ind` (Indicator) cho các entity trên.

**Lý do cần ở Atomic:** Datamart không thể tự lọc cột không tồn tại. Datamart đã bỏ điều kiện `*.deleted = 0` khỏi `etl_logic` (2026-10-15) dựa trên giả định (a). Nếu giả định sai, lịch sử thanh tra/kiểm tra (Nhóm 40) và lịch sử xử phạt cá nhân (Nhóm 44) trong `opr_securities_company_compliance_hist` / `opr_individual_violation_hist` sẽ chứa cả bản ghi đã bị xóa. Tham chiếu: O_QLKD_30(1).

### AQ-03 — Phân biệt sheet cho các KPI Dashboard lọc theo `cell_id`

**Hiện trạng đã kiểm**
- `sc_report_input_value` chỉ có tọa độ `sheet_id`, `section_id`, `cell_id`, `row_index`; Atomic ghi rõ "không FK đến family FORM_SHEET*". Cùng `cell_id` mang nghĩa khác nhau giữa các sheet (TS001 = "Tổng số người lao động" ở sheet TTC_T nhưng "Vốn điều lệ" ở TTC_Q) nên mọi `WHERE cell_id = 'TSxxx'` có nguy cơ cộng lẫn nhiều sheet (O_QLKD_34).
- `sc_report_deep_config` (`sc_rpt_id`, `sheet_id`, `sheet_code`) **đã có** trong `dm_manifest.yaml` nhưng ở trạng thái `draft`.

**Đề xuất**
1. Duyệt `sc_report_deep_config` (`draft` → `approved`).
2. Xác nhận `sc_report_input_value.sheet_id` khớp `sc_report_deep_config.sheet_id` (cùng `sc_rpt_id` qua submission → report).
3. Xác nhận quy ước `cell_id` (kiểu `TS001`) so với `cell_code` (kiểu `A1`, `B2`) của `sc_report_sheet_cell`.

**Lý do cần ở Atomic:** các KPI Dashboard ở Nhóm 8, 9, 11, 12, 15, 16, 19 lọc theo danh sách `cell_id` do BA chỉ định (kèm mã báo cáo và, ở các ô trùng như TS001, mã sheet). Khi `sheet_code` có thể tra được, Datamart bổ sung nó vào `report_indicator_dim` và thêm bộ lọc sheet cho các KPI này; hiện KPI chỉ lọc `cell_id` nên có rủi ro cộng lẫn sheet (K_QLKD_105 dựa vào kỳ `THANG` để phân biệt với K_QLKD_106). Datamart đã thiết kế lại `report_indicator_dim` thành chiều tọa độ (rpt_code × sheet_id × cell_id) — O_QLKD_42.

### AQ-04 — Hai entity dịch vụ: xác nhận giả định

Hai entity `sc_ou_x_cl_sc_firm_service_relationship` và `cl_securities_company_firm_service` **đã có** trong `DataModel/Atomic/dm_manifest.yaml` (phần đăng ký manifest của O_QLKD_32 đã xong). Còn cần Atomic Team xác nhận:
1. Cả hai không có `RECORD_STATUS`, trong khi SQL BA lọc `RECORD_STATUS = 1` — Datamart giả định ETL chỉ nạp bản ghi đang hoạt động.
2. `sc_ou_x_cl_sc_firm_service_relationship.sc_ou_code` trùng `sc_organization_unit.sc_ou_code` của bộ Phòng giao dịch (cả hai là ID nguồn `SC_FIRM_TRANSACTION_OFFICE`).

**Lý do:** nếu giả định (1) sai, dịch vụ đã ngừng vẫn được đếm vào Nhóm 33/34/35/37; nếu (2) sai, bảng cầu không nối được. Tham chiếu: O_QLKD_32.

### AQ-05 — Đơn vị trực thuộc (CN/PGD/VPĐD): ngày quyết định của chi nhánh và lọc `RECORD_STATUS`

**Hiện trạng đã kiểm**
- Atomic (commit `dc0ce1db`, 14/10/2026) bỏ `sc_organization_unit.decision_dt` và `record_status_code`; ngày quyết định chuyển sang `ip_alternative_identification.identification_issue_dt` (`identification_tp_code = 'ESTABLISHMENT_OPERATION_LICENSE'`).
- PGD (`SC_FIRM_TRANSACTION_OFFICE`) và VPĐD (`SC_FIRM_REP_OFFICE`) map đúng `DECISION_DATE`. **Chi nhánh (`SC_FIRM_BRANCH`) chỉ map `LICENSE_DATE`**, dù BRD nguồn `SC_FIRM_BRANCH` có cả `DECISION_DATE` và `LICENSE_DATE`.
- BRD cả 3 bảng đều có `RECORD_STATUS`; Atomic không có cột tương đương trên `sc_organization_unit` và ghi rõ nó khác `BRANCH_STATUS`.

**Đề xuất:** (1) với chi nhánh, map thêm `DECISION_DATE` (hoặc xác nhận `LICENSE_DATE` là ngày đúng cho trục "Chiều thời gian theo ngày"); (2) xác nhận ETL Atomic chỉ nạp bản ghi `RECORD_STATUS = 1`, hoặc thêm cột trạng thái bản ghi.

**Lý do cần ở Atomic:** SQL BA lọc `RECORD_STATUS = 1` và dùng `DECISION_DATE` làm trục ngày cho CN/PGD/VPĐD. Datamart đang dùng `LICENSE_DATE` cho chi nhánh và bỏ lọc `RECORD_STATUS` theo giả định; nếu Atomic có nạp bản ghi `RECORD_STATUS = 0` thì số CN/PGD/VPĐD bị đếm dư, nếu `DECISION_DATE` ≠ `LICENSE_DATE` thì số liệu theo ngày của chi nhánh lệch. Tham chiếu: O_QLKD_41.

### AQ-06 — `sc_alert_violation`: chưa resolve đối tượng cảnh báo cho CN/PGD/VPĐD

**Hiện trạng đã kiểm**
- `sc_alert_violation.alert_entity_code` (← `ENTITY_ID`) ghi "Pending — ETL cần resolve theo ENTITY_TYPE": mới mô tả CTCK, chi nhánh CTCK nước ngoài, VPĐD CTCK nước ngoài.
- BRD `SC_FIRM_ALERT_VIOLATION.ENTITY_TYPE` chỉ liệt kê `CTCK`, `CN_NUOC_NGOAI`, `VPDD_NUOC_NGOAI`; còn BA Nhóm 36 lọc `ENTITY_TYPE IN ('BRANCH', 'TRANSACTION_OFFICE', 'REP_OFFICE')` (BA tự ghi "Xác nhận giá trị ENTITY_TYPE", chưa chốt).

**Đề xuất:** (1) kiểm tra dữ liệu thật: các giá trị `ENTITY_TYPE` nào đang có trong `SC_FIRM_ALERT_VIOLATION`; (2) nếu có cảnh báo cho chi nhánh/PGD/VPĐD trong nước, resolve `alert_entity_code` sang `sc_organization_unit` (theo `alert_entity_tp_code`).

**Lý do cần ở Atomic:** 3 KPI Nhóm 36 (K_QLKD_178–180: số CN/PGD/VPĐD duy trì tốt / gần giới hạn / không duy trì) đang PENDING vì không nối được mức vi phạm (`severity_level` 1/2/3) với từng đơn vị. Nếu dữ liệu chỉ có 3 giá trị của BRD thì cần BA xác nhận lại nguồn của Nhóm 36. Tham chiếu: O_QLKD_7, HLD Nhóm 36.

## 3. Đã kiểm chứng KHÔNG phải thiếu ở Atomic (không cần Atomic xử lý)

| Điểm từng ghi là gap | Thực tế | Xử lý |
|---|---|---|
| `securities_company.tax_code` không tồn tại | Mã số thuế CTCK nằm ở `ip_alternative_identification` (`src_stm_code = 'SCMS_SC_FIRM_INFO'`, `identification_tp_code = 'TAX_ID'`) | **Đã sửa ở Datamart 2026-10-15** (`sc_code` nhánh Examination/Inspection — Nhóm 40) |
| Entity `penalty_decision` không có | Entity tên vật lý là `pd` (`decision_nbr`, `issued_dt` có sẵn — `DataModel/working/Atomic/lld/THANHTRA/lld_THANHTRA_PENALTY_DECISION.yaml`) | **Đã sửa ở Datamart 2026-10-15** (`penalty_decision` → `pd`, `penalty_decision_subject` → `pd_subject`) |
| `row_no`, `item_val`, `label` | Tên Atomic là `row_index`, `cell_val`, `label_nm` | **Đã sửa ở Datamart 2026-10-15** |

## 4. Việc không thuộc Atomic (cần chủ nguồn / BA / Datamart)

- **Định danh đối tượng của đợt thanh tra (Nhóm 40):** BRD `INSPECTION_TEAM_TARGET` không có `CITIZEN_ID`, `BUSINESS_REGISTRATION_NUMBER` hay `LEGAL_REP_CITIZEN_ID` (khác `EXAMINATION_TEAM_TARGET` có đủ). Atomic không thể bổ sung cột mà nguồn không có. Nhánh Inspection của `compliance_hist` vì vậy chỉ nối được theo tên (`target_nm = subject_nm`) hoặc `target_reference_id`. Cần chủ nguồn THANHTRA bổ sung cột ở nguồn, hoặc BA chốt cách nối cho nhánh này (O_QLKD_13).
- **Chưa chốt quy tắc từ BA (không phải Atomic):** K_QLKD_12–13 (số tài khoản phát sinh giao dịch, số dư tiền gửi — nguồn báo cáo động, chưa chọn ô); K_QLKD_209 (VSDC hay SCMS); O_QLKD_24/25 (giá trị filter trạng thái, ý nghĩa `END_DATE`); O_QLKD_6/33 (xác nhận mã `CATALOG_CODE` dịch vụ qua data profiling).
- **Việc Datamart tự làm:** Nhóm 41/42 (O_QLKD_38 — nối chức vụ người liên quan, nhánh cổ đông lớn liên quan; `sc_major_shareholder_relation` hiện `draft` nên cần Atomic duyệt khi thêm nhánh này).
- **8 cột khóa PK** ghi "Generated" nhưng `etl_logic` trống (`market_index_dim_id`, `offering_form_dim_id`, `securities_company_dim_id`, `securities_service_cl_dim_id`, `organization_unit_service_id` ×2, …): việc của Data Modeler Datamart (cần công thức hash BK), không phải của Atomic.

## 5. Kiểm tra lại sau khi Atomic cập nhật

Chạy `python .claude/skills/datamart-review/scripts/run_quality_gates.py --module QLKD --strict`. Gate 0 (QLKD) hiện 0 CRITICAL / 0 WARNING; các điểm AQ-01…AQ-06 là giả định hoặc dữ liệu thiếu mà Gate 0 không phát hiện được vì không nằm trong tên bảng/cột đã tham chiếu.
