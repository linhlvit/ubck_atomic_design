# QLKD — Rà soát thiết kế còn thiếu trên Atomic (12/10/2026, bản đính chính)

> **Draft cần human review.** Bản đầu trong ngày sai ở nhóm "ngoài scope" (xem Mục 0). Căn cứ: `Datamart/index/kpi_index.csv`, `DTM_QLKD_Detail_Mapping.csv`, `DTM_QLKD_HLD.md` (Open Issues), LLD per-table QLKD, Gate 0 `check_references.py --module QLKD`, Atomic ở commit ff7d9ac4. Số liệu Nhóm 13 do Data Modeler chạy truy vấn Atomic/SCMS UAT ngày 12/10. Không có dữ liệu thật.

## 0. Phương pháp tra Atomic và chỗ bản đầu sai

Một thực thể/cột được coi là **đã thiết kế** nếu có ở **bất kỳ** lớp nào dưới đây (tra theo *bảng nguồn*, không chỉ theo tên vật lý):

| Lớp | File | Ghi chú |
|---|---|---|
| 1 | `DataModel/Atomic/*/dm_atm_*.yaml` (+ `dm_manifest.yaml`) | Đã promote |
| 2 | `DataModel/working/Atomic/lld/*/lld_*.yaml` | LLD working |
| 3 | `DataModel/working/Atomic/lld/manifest.yaml` | Có entry nhưng **49/491 `lld_file` không tồn tại trong repo** |
| 4 | `DataModel/working/Atomic/hld/atomic_entities.yaml` + `aggregate/atomic_attributes.yaml` | HLD + danh sách cột |

`DataModel/working/Atomic/hld/atomic_out_of_scope.yaml` **không dùng làm bằng chứng** — file này lỗi thời: vẫn ghi `BANK_PERIODIC_REPORT`, `FORM_REPORT_DEEP_CONFIG` là ngoài scope trong khi hai bảng đã được thiết kế ở lớp 3–4 từ commit 6bbbeb2a (08/10/2026).
Bản đầu chỉ tra lớp 1–2 + `atomic_out_of_scope.yaml` → xếp nhầm `BANK_PERIODIC_REPORT`, nhóm chi nhánh nước ngoài, `sc_profile_change` và "mã sheet" vào "Atomic thiếu".

## 1. Tóm tắt (đã đính chính)

| Hạng mục | Số liệu |
|---|---|
| KPI QLKD (Detail Mapping) | 8.067 KPI / 8.235 dòng; Data Explorer 7.838 dòng |
| KPI các tab ngoài Data Explorer | 192 KPI: 189 READY, 3 PENDING (K_QLKD_178–180, Nhóm 36) |
| Data Explorer chưa nối Mart | **6.977 / 7.838 dòng** (134 STT) |
| — còn thiếu ở Atomic | **6.201** (FORMULA + `SCMS_MAP_CT`) |
| — Atomic đã thiết kế, Datamart chưa dùng | **269** = 104 (CN/VPĐD nước ngoài) + 83 (ngân hàng) + 82 (chào bán/phát hành) |
| — chờ BA | 507 |
| Bảng Atomic QLKD đọc | 37 bảng: 6 approved, 23 draft, 8 không có ở `DataModel/Atomic/` |
| Gate 0 QLKD | 12 CRITICAL + 9 WARNING, đều ở nhóm THANHTRA (Mục 4) |

## 2. A — Atomic còn thiếu (sau khi tra đủ 4 lớp)

| # | Thiếu gì | Bằng chứng | Ảnh hưởng | Issue |
|---|---|---|---|---|
| A1 | **Khóa nối tên chỉ tiêu ↔ giá trị ô.** BRD `FORM_SHEET_CELL` có `FORMULA`, `FORMULA_TEXT`, `SUM_FORMULA` nhưng `sc_report_sheet_cell` không mang sang (LLD không ghi lý do loại); `SCMS_MAP_CT` (CELLID, SHEETID, FORM_REPORT_ID → ROW_NAME/COLUMN_NAME) không có trong BRD lẫn Atomic. BA lấy tên chỉ tiêu qua hai thứ này. **Mã sheet đã được giải quyết:** `sc_report_deep_config` có `sheet_id`, `sheet_code` (xem B3) | `brd_SCMS_FORM_SHEET_CELL.yaml` dòng 132–142; aggregate `sc_report_sheet_cell` (40 cột, không có formula); tìm `MAP_CT` trong `DataModel/`, `BRD/Source/`: 0 kết quả. *Chưa kiểm chứng bằng dữ liệu* rằng `cell_id` của giá trị không trùng trực tiếp `FORM_SHEET_CELL.ID` — BA dùng FORMULA + MAP_CT nên giữ nhận định | **6.201 dòng Data Explorer** (Mã/Tên chỉ tiêu + chỉ tiêu cơ sở) | O_QLKD_35 |
| A2 | **Nhóm 13 (K_QLKD_66–72):** (1) `created_tms` (CREATED_AT) cho `sc_disclosure_securities_offering` (BA 12/10 đổi trục thành `COALESCE(DOCUMENT_DATE, CREATED_AT)`; Atomic có 3/84 dòng CP/TP ACTIVE thiếu `document_dt`, truy vấn theo tháng ra rỗng); (2) mã `loaiChaoBan` (từ `PLAN_JSON`) cho mọi dòng; (3) giải thích Atomic 98 dòng vs nguồn 532 | Nguồn SCMS: `OFFERING_METHOD` chỉ có giá trị ở **42/532 dòng (8%)**, luôn khớp `loaiChaoBan` khi có; theo `loaiChaoBan`: CC 130 dòng/12 có tiền, riêng lẻ 105/5, còn lại 297/17. Atomic: `offering_method` có mã 6/84, `offering_tp_code` NULL 100%, `result_rpt_dt` NULL 84/84. Aggregate `sc_disclosure_securities_offering` không có cột tương ứng | Phân loại bằng `offering_method` chỉ bắt 14/34 dòng có tiền (mất 59%) | O_QLKD_39 |
| A3 | **Nhóm 36:** ETL resolve `alert_entity_code` cho `ENTITY_TYPE IN (BRANCH, TRANSACTION_OFFICE, REP_OFFICE)` → `sc_organization_unit`. Comment Atomic chỉ nêu CTCK / CN_NUOC_NGOAI / VPDD_NUOC_NGOAI; giá trị `ENTITY_TYPE` thực tế chưa xác nhận | Comment `alert_entity_code` trong `dm_atm_sc_alert_violation-…yaml` và aggregate: "Pending — polymorphic FK" | K_QLKD_178–180 (3 KPI PENDING) | O_QLKD_7 |
| A4 | `inspection_team_target` **không có** `citizen_id` / `business_registration_nbr` (`examination_team_target` có đủ + `legal_rep_*`) | aggregate, yaml hai entity | Nhánh Inspection của K_QLKD_197 chưa nối theo định danh | O_QLKD_13 |
| A5 | Xác nhận giả định ETL: (1) `sc_ou_x_cl_sc_firm_service_relationship` / `cl_securities_company_firm_service` không có `record_status_code` (BA lọc `RECORD_STATUS = 1`), thiết kế giả định ETL chỉ nạp bản ghi hoạt động; (3) `sc_ou_code` bảng cầu trùng `sc_organization_unit.sc_ou_code`. (2) đã xong — hai entity đã vào `dm_manifest.yaml` | `dm_manifest.yaml`, yaml hai entity | K_QLKD_165–177, 183 | O_QLKD_32 |
| A6 | Nguồn tỷ lệ sở hữu người liên quan: BA ghi VSDC, Atomic chỉ có SCMS tự khai | HLD | K_QLKD_209 | O_QLKD_15 |
| A7 | **Tài liệu Atomic mâu thuẫn:** `atomic_out_of_scope.yaml`, `SCMS_HLD_Overview.md` (dòng 315) và comment `sheet_id/section_id/cell_id` của `sc_report_input_value` vẫn ghi `FORM_REPORT_DEEP_CONFIG`/`BANK_PERIODIC_REPORT` ngoài scope; manifest có entry nhưng `lld_SCMS_BANK_PERIODIC_REPORT.yaml`, `lld_SCMS_FORM_REPORT_DEEP_CONFIG.yaml` (và 47 entry khác) **không có trong repo** — Datamart chỉ kiểm được cột qua aggregate, Gate 0 theo quy trình hai nguồn không thấy | Mục 0 | Hai entity chưa dùng được theo quy trình; cần Atomic commit LLD hoặc xác nhận aggregate là nguồn hợp lệ | — |

## 3. B — Atomic ĐÃ thiết kế, Datamart chưa dùng (không phải thiếu Atomic)

| # | Entity Atomic (draft, lớp 3–4) | Việc phía Datamart | Ảnh hưởng |
|---|---|---|---|
| B1 | `sc_bank_periodic` (nguồn `BANK_PERIODIC_REPORT`, 23 cột, FK `sc_bank_id`, `sc_rpt_id`) + `sc_bank` (19 cột) | Mở rộng `opr_securities_company_report_data` thêm nhánh báo cáo ngân hàng; liên kết giá trị qua `sc_report_input_submission.ref_tp_code` + `ref_id` (FK đa hình). Lưu ý `sc_bank_periodic` không có `rpt_submission_status_code`, `sent_tms` như `sc_periodic_report` — cần chốt BA cần kỳ/đơn vị nào | 83 dòng (STT 176–178) |
| B2 | `sc_foreign_branch_periodic_report` + `sc_foreign_representative_office_periodic_report` (32 cột, FK `sc_foreign_branch_id` / `sc_foreign_representative_office_id`, không có `sc_id`) | Thêm nhánh; **quyết định khóa CTCK cho chi nhánh/VPĐD nước ngoài** | 104 dòng (STT 148–173) |
| B3 | `sc_report_deep_config` (`sc_rpt_id`, `sheet_id`, `sheet_code`) | Nối `sc_report_input_value.sheet_id` ↔ `sc_report_deep_config.sheet_id` để thêm `sheet_code` vào Fact và `report_indicator_dim` → **gỡ rủi ro cộng lẫn sheet** của Nhóm 19 (K_QLKD_102–106, O_QLKD_34 mục 3) | K_QLKD_102–106 |
| B4 | `sc_profile_change` (`event_tp_nm`, `document_reference_nbr`) | Fact/Operational riêng cho dòng "Số giấy chứng nhận" | STT 49/50 |
| B5 | `sc_disclosure_securities_offering` | Fact/Operational tổng hợp theo đợt — nên làm sau khi chốt A2 | 82 dòng (STT 45–46) |
| B6 | `sc_related_person` (approved), `sc_major_shareholder_relation` (draft) | Thiết kế lại `opr_individual_related_party_network` / `opr_individual_listed_company_role` theo BA | K_QLKD_206–211 (O_QLKD_38) |

## 4. D — Lệch phía Datamart (Gate 0 THANHTRA)

12 CRITICAL + 9 WARNING đều ở `opr_securities_company_compliance_hist` (Inspection + Examination) và `opr_individual_violation_hist`. Trước đây ghi "cần Atomic" (O_QLKD_30); đối chiếu cho thấy phần lớn do tên/quy ước Atomic đã đổi:

| # | Hiện tượng | Thực tế Atomic | Hướng sửa (cần duyệt) | KPI |
|---|---|---|---|---|
| D1 | `penalty_decision`, `penalty_decision_subject` "không tìm thấy" | `entity_physical_name` là **`pd`** và **`pd_subject`** (approved trong working LLD; `pd_subject` có trong `DataModel/Atomic/Event/`; cả hai có trong aggregate) | Đổi tên bảng/cột tham chiếu trong etl_logic và `atomic_table` | K_QLKD_188, 196–202, 219–223 |
| D2 | `examination_team.deleted`, `inspection_team.deleted`, `*_team_target.deleted`, `pd_subject_behavior.deleted` (5 cột CRITICAL) | Atomic loại `VERSION/DELETED` khỏi **toàn bộ phân hệ THANHTRA** (ghi trong `lld_THANHTRA_*`, theo `pending_design.yaml`) | Bỏ filter `deleted = 0`, **hoặc** xác nhận Atomic ETL chỉ nạp bản ghi chưa xóa (SCD4A `ds_rcrd_st = 'ACTIVE'`). Chưa xác nhận Atomic có lọc bản ghi đã xóa trước khi nạp | K_QLKD_196–202 |
| D3 | `securities_company.tax_code` (CRITICAL) | Mã số thuế ở `ip_alternative_identification` (`identification_tp_code = 'TAX_CODE'`) | Nối qua entity đó | K_QLKD_196–202 |

## 5. Phía BA — 507 dòng Data Explorer

303 "Báo cáo thường niên, DB cũ không thấy biểu mẫu"; 177 "Loại dữ liệu = Không cấu hình"; 11 "Done nhưng Bảng nguồn/SQL trống"; 15 Pending; 1 chiều chưa có quy tắc (O_QLKD_36, O_QLKD_35). Ngoài ra O_QLKD_1/5 (K_QLKD_12–13), O_QLKD_24/25 (Nhóm 1) chờ BA.

## 6. Ghi chú cũ trong thiết kế QLKD đã lỗi thời (cần sửa nếu duyệt)

- Detail Mapping (`ghi_chu`, 83 dòng STT 176–178) và HLD (bảng STT, O_QLKD_37): "BANK_PERIODIC_REPORT ngoài scope Atomic".
- HLD O_QLKD_35 và O_QLKD_34 mục (3): "`FORM_REPORT_DEEP_CONFIG` ngoài scope" / "`sheet_id` không có mã sheet".
- Detail Mapping 6.139 + 62 dòng: lý do "thiếu FORMULA … và `SCMS_MAP_CT`" vẫn đúng, nhưng cần bỏ ngụ ý thiếu mã sheet.

## 7. Rủi ro nền

23/37 bảng Atomic QLKD đọc còn `draft`, gồm `securities_company` (7 bảng Datamart), `sc_periodic_report` (5), `sc_report` (4), `sc_report_input_value` (5), `sc_senior_personnel` (3), `sc_organization_unit` (2), `market_index_snapshot` (2). Đổi tên/cột khi duyệt sẽ lặp lại kiểu lệch D1–D3.

## 8. Ưu tiên đề xuất

1. **D1–D3** — sửa phía Datamart, gỡ 12 CRITICAL (riêng D2 cần xác nhận Atomic).
2. **B1–B3** — Atomic đã sẵn sàng: mở rộng Report Data cho ngân hàng/CN nước ngoài, thêm `sheet_code`; gỡ 187 dòng Data Explorer + rủi ro Nhóm 19. Cần A7 (commit LLD) để Gate 0 kiểm được cột.
3. **A1** (6.201 dòng) — vẫn là gap Atomic lớn nhất: FORMULA + `SCMS_MAP_CT`.
4. **A2** — hạ K_QLKD_66–72 PENDING cho tới khi Atomic có `created_tms` và `loaiChaoBan`.
5. A3, A4, A5 — gap nhỏ, rõ phạm vi.
