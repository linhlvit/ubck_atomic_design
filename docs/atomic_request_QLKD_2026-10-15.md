# Yêu cầu bổ sung / xác nhận trên Atomic — module QLKD (phạm vi Dashboard)

- **Ngày lập:** 2026-10-15
- **Người lập:** Data Modeler Datamart QLKD (soạn cùng Claude — đây là draft, cần Data Modeler duyệt trước khi gửi Atomic Team)
- **Phạm vi:** chỉ các nhóm **Dashboard** của QLKD = Nhóm 1–44 (tab TỔNG QUAN, GIÁM SÁT, HỒ SƠ CTCK 360, HỒ SƠ CTCK 360 (NHNCK), TRA CỨU CÁ NHÂN). **Không gồm Data Explorer (Nhóm 45–178)** — các yêu cầu chỉ phục vụ Data Explorer (công thức ô `FORMULA`, bảng `SCMS_MAP_CT`, JSON của `SC_FIRM_PROFILE_CHANGE`, báo cáo định kỳ chi nhánh nước ngoài/ngân hàng lưu ký) đã loại khỏi tài liệu này.
- **Căn cứ:** rà soát LLD `Datamart/lld/QLKD/` (Gate 0), các mục Open O_QLKD_13/30/32/34/39/42/43 trong `Datamart/hld/DTM_QLKD_HLD.md`, đối chiếu trực tiếp `DataModel/Atomic/` (`dm_manifest.yaml`), `DataModel/working/Atomic/lld/`, `BRD/Source/`.
- **Nguyên tắc:** mỗi yêu cầu đã kiểm lại với file Atomic hiện hành. Điểm từng ghi là "thiếu Atomic" nhưng thực tế đã có, hoặc là lỗi mapping phía Datamart, được tách ở mục 3.

## 1. Tóm tắt

| ID | Entity Atomic | Cần bổ sung / xác nhận | Ưu tiên | Nhóm Dashboard bị ảnh hưởng |
|---|---|---|---|---|
| AQ-01 | `sc_disclosure_securities_offering` | Thêm `created_tms`; nạp `loaiChaoBan` cho mọi dòng | Cao | Nhóm 13 — Nguồn vốn tăng thêm (K_QLKD_66–72) |
| AQ-02 | 6 entity THANHTRA (`examination_team`, `examination_team_target`, `inspection_team`, `inspection_team_target`, `pd_subject`, `pd_subject_behavior`) | Xác nhận đã loại bản ghi `DELETED = 1`, hoặc thêm cờ xóa | Cao | Nhóm 40 — Lịch sử xử phạt thanh tra kiểm tra (K_QLKD_195–202); Nhóm 44 — Lịch sử vi phạm xử phạt cá nhân (K_QLKD_218–223) |
| AQ-03 | `sc_report_deep_config` (+ `sc_report_input_value`) | Duyệt `draft` → `approved`; xác nhận `sheet_id` khớp và quy ước `cell_id` | Cao | Nhóm 8, 9, 11, 12, 15, 16, 19 (KPI lọc theo `cell_id`: K_QLKD_42–47, 49–52, 60–63, 65, 79–85, 87, 102–106) |
| AQ-04 | `sc_ou_x_cl_sc_firm_service_relationship`, `cl_securities_company_firm_service` | Xác nhận 3 giả định (không có `record_status`, giá trị `sc_ou_code`, phạm vi bản ghi) | Trung bình | Nhóm 33, 34, 35, 37 (K_QLKD_165–177, 181–185) |

## 2. Chi tiết

### AQ-01 — `sc_disclosure_securities_offering`: thiếu ngày tạo bản ghi và mã hình thức chào bán

**Đề xuất**
1. Thêm `created_tms` (timestamp) ← `SCMS.DISCLOSURE_SECURITIES_OFFERING.CREATED_AT` (cột có trong `BRD/Source/SCMS/brd_SCMS_DISCLOSURE_SECURITIES_OFFERING.yaml`).
2. Với mọi dòng, nạp `loaiChaoBan` (từ `PLAN_JSON.$[0].loaiChaoBan`) vào `offering_method` (hoặc cột mới `offering_form_code`).

**Lý do cần ở Atomic**
- BA STT 13 (ghi chú "Sửa 12/10") đổi trục thời gian thành `COALESCE(DOCUMENT_DATE, CREATED_AT)` và lọc `CREATED_AT IS NOT NULL`. Atomic chưa có `CREATED_AT` nên Datamart không thể đổi trục theo BA.
- Dữ liệu `atm_sc_disclosure_securities_offering` (kiểm 12/10, 84 dòng CP/TP đang hiệu lực): `result_rpt_dt` NULL 84/84; `document_dt` NULL 3/84; `proceeds_collected_amt` chỉ có 2/84 dòng và nhiều khả năng nằm trong 3 dòng thiếu `document_dt` — chỉ cứu được nếu có `created_tms`. Nguồn SCMS: 18/532 dòng thiếu `DOCUMENT_DATE`, cả 18 dòng có `CREATED_AT`.
- `offering_method` hiện chứa mã (`CHAO_BAN_RIENG_LE` 3, `CHAO_BAN_RA_CONG_CHUNG` 2, `TRA_CO_TUC_BANG_CP` 1, **trống 78/84**) nên 78/84 dòng không phân loại được hình thức chào bán. Datamart đã chuyển sang phân loại theo mã nhưng không thể bù dữ liệu thiếu.
- Cần xác nhận thêm: nguồn có 532 dòng CP/TP có `PLAN_JSON` nhưng `RECORD_STATUS = 1` chỉ 42; Atomic chỉ có 98 dòng — Atomic đang lọc theo tiêu chí nào?

**Datamart sẽ làm khi có:** đổi trục thời gian của Fact `fct_securities_company_capital_raising_event` thành `COALESCE(document_dt, created_tms)` và phân loại đủ 84 dòng. Tham chiếu: O_QLKD_39.

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

## 3. Đã kiểm chứng KHÔNG phải thiếu ở Atomic (không cần Atomic xử lý)

| Điểm từng ghi là gap | Thực tế | Xử lý |
|---|---|---|
| `securities_company.tax_code` không tồn tại | Mã số thuế CTCK nằm ở `ip_alternative_identification` (`src_stm_code = 'SCMS_SC_FIRM_INFO'`, `identification_tp_code = 'TAX_ID'`) | **Đã sửa ở Datamart 2026-10-15** (`sc_code` nhánh Examination/Inspection — Nhóm 40) |
| Entity `penalty_decision` không có | Entity tên vật lý là `pd` (`decision_nbr`, `issued_dt` có sẵn — `DataModel/working/Atomic/lld/THANHTRA/lld_THANHTRA_PENALTY_DECISION.yaml`) | **Đã sửa ở Datamart 2026-10-15** (`penalty_decision` → `pd`, `penalty_decision_subject` → `pd_subject`) |
| `row_no`, `item_val`, `label` | Tên Atomic là `row_index`, `cell_val`, `label_nm` | **Đã sửa ở Datamart 2026-10-15** |

## 4. Việc không thuộc Atomic (cần chủ nguồn / BA / Datamart)

- **Định danh đối tượng của đợt thanh tra (Nhóm 40):** BRD `INSPECTION_TEAM_TARGET` không có `CITIZEN_ID`, `BUSINESS_REGISTRATION_NUMBER` hay `LEGAL_REP_CITIZEN_ID` (khác `EXAMINATION_TEAM_TARGET` có đủ). Atomic không thể bổ sung cột mà nguồn không có. Nhánh Inspection của `compliance_hist` vì vậy chỉ nối được theo tên (`target_nm = subject_nm`) hoặc `target_reference_id`. Cần chủ nguồn THANHTRA bổ sung cột ở nguồn, hoặc BA chốt cách nối cho nhánh này (O_QLKD_13).
- **8 cột khóa PK** ghi "Generated" nhưng `etl_logic` trống (`market_index_dim_id`, `offering_form_dim_id`, `securities_company_dim_id`, `securities_service_cl_dim_id`, `organization_unit_service_id` ×2, …): việc của Data Modeler Datamart (cần công thức hash BK), không phải của Atomic.

## 5. Kiểm tra lại sau khi Atomic cập nhật

Chạy `python .claude/skills/datamart-review/scripts/run_quality_gates.py --module QLKD --strict`. Gate 0 (QLKD) hiện 0 CRITICAL / 0 WARNING; các điểm AQ-01…AQ-04 là giả định hoặc dữ liệu thiếu mà Gate 0 không phát hiện được vì không nằm trong tên bảng/cột đã tham chiếu.
