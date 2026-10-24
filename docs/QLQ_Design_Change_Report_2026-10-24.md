# Báo cáo Thay đổi Thiết kế Datamart Phân hệ QLQ (Quản lý Quỹ)

> **Ngày lập báo cáo:** 2026-10-24  
> **Phân hệ:** Quản lý Quỹ (QLQ)  
> **Phạm vi:** 28 Nhóm Dashboard (K_QLQ_1 → K_QLQ_181)  
> **Người thực hiện / Data Modeler:** Vương Ngô (`vuongjune2@gmail.com`)  
> **Các commit liên quan:** `576f001c`, `7164d9ca`, `0bfdb1ed`, `9b3bf506`

---

## 1. Mục đích và Bối cảnh

Trong phiên làm việc ngày 24/10/2026, thiết kế Datamart phân hệ **QLQ** đã được cập nhật toàn diện nhằm đáp ứng 3 yêu cầu trọng yếu:

1. **Đồng bộ với cập nhật mới nhất từ lớp Atomic:**  
   Atomic đã bổ sung trường `record_status_code` vào entity `fmr_submission` (nguồn `FMS.RPT_MEMBER.RECORD_STATUS`, commit `4b0991de` & `1e373c66`), giúp Datamart có thể lọc chính xác trạng thái phê duyệt báo cáo của thành viên thay vì dựa vào giả định ngầm.
2. **Áp dụng Quy tắc chuẩn hóa A23 & A24 (Skills & Governance):**  
   - **Luật A23:** Chuẩn hóa khóa chính (PK) của Dimension mang trực tiếp ID Atomic driving khi có các cột khác trong module carry ID đó.
   - **Luật A24 (Gate 8 - D13):** Kiểm soát nghiêm ngặt tính toàn vẹn của tên cột viết trong trường `logic` của Detail Mapping và công thức HLD.
   - **Luật D14 (Gate 8):** Chuẩn hóa số ô của bảng "Bảng mapping nguồn" trong HLD (chính xác 4 cột).
3. **Rà soát 28 Nhóm Dashboard theo tài liệu BA hiện hành & SQL tham khảo:**  
   Đối chiếu chi tiết giữa mô tả BA (`BRD/BA/BA_analyst_QLQ.csv`) và logic SQL tham khảo thực tế của từng nhóm chỉ tiêu từ Nhóm 1 đến Nhóm 28 để loại bỏ các điểm vênh logic và bổ sung các Open Issues (O_QLQ_44..47).

---

## 2. Chi tiết các thay đổi thiết kế trọng yếu

### 2.1. Chuẩn hóa Khóa chính Dimension theo Quy tắc A23
* **Vấn đề trước đây:** PK của 4 bảng Dimension (`investment_fund_dim`, `fund_management_company_dim`, `foreign_fund_management_organization_unit_dim`, `custodian_bank_dim`) được định nghĩa là `Generated` (tự băm từ Business Key ở tầng Datamart). Tuy nhiên, các bảng con/profile trong cùng module lại mang trực tiếp surrogate key của Atomic (`fmc_id`, `investment_fund_id`, `foreign_fm_ou_id`, `custodian_bank_id`), khiến việc JOIN Fact/Profile sang Dim bị vênh mã băm.
* **Giải pháp đã thực hiện:** Chuyển PK của 4 Dimension sang `etl_logic_type = direct`, lấy trực tiếp từ PK của entity driving ở Atomic:
  - `fund_management_company_dim.fmc_id` ← `fund_management_company.fmc_id`
  - `investment_fund_dim.investment_fund_id` ← `investment_fund.investment_fund_id`
  - `foreign_fund_management_organization_unit_dim.foreign_fm_ou_id` ← `foreign_fm_ou.foreign_fm_ou_id`
  - `custodian_bank_dim.custodian_bank_id` ← `custodian_bank.custodian_bank_id`

### 2.2. Tích hợp trường trạng thái báo cáo `record_status_code` (FMS RPT_MEMBER)
* Tận dụng trường `record_status_code` mới được Atomic đưa vào `fmr_submission`:
  - Bổ sung điều kiện lọc `ms.record_status_code IN ('2','3','5','10')` vào mệnh đề `EXISTS` lọc báo cáo hợp lệ tại 2 bảng danh sách hợp đồng:
    - `opr_foreign_fund_management_organization_unit_contract_list_FMS_RPT_VALUES.csv`
    - `opr_fund_management_company_contract_list_FMS_RPT_VALUES.csv`
  - Cập nhật mô tả nghiệp vụ tại bảng Fact `fct_fund_management_rpt_cell_val.csv`.

### 2.3. Rà soát nghiệp vụ 28 Nhóm Dashboard (Chi tiết HLD & LLD)

| Nhóm | Chỉ tiêu / Bảng liên quan | Chi tiết thay đổi logic & Đồng bộ BA/SQL |
|:---|:---|:---|
| **Nhóm 1** | K_QLQ_2 (Số quỹ đầu tư) | Đổi nguồn ngày cấp phép thành lập sang `FUNDS.ID_DATE` (Atomic: `ip_alternative_identification.identification_issue_dt`, loại `ESTABLISHMENT_OPERATION_LICENSE`) thay vì `DEC_DATE`. Logic lọc lũy kế `identification_issue_dt <= cuối tháng`. |
| **Nhóm 1** | K_QLQ_5 (Số CTQLQ đang hoạt động) | Sử dụng ngày bắt đầu hoạt động thực tế `actual_operation_commencement_dt` (REAL_ACTIVE_DATE) thay cho ngày hoạt động trên giấy phép `operation_commencement_dt` (ACTIVE_DATE). |
| **Nhóm 1** | K_QLQ_6, 8, 9, 10 (VPĐD CTQLQ nước ngoài) | Chuẩn hóa điều kiện lọc chi nhánh/VPĐD theo `ou_tp_code = '1'` (BRANCH_FLAG), trạng thái quản lý theo `cl_fms_status_id` (FMS.STATUS), lọc ngày hoạt động `effective_start_dt` và ngày kết thúc `effective_end_dt`. |
| **Nhóm 1** | K_QLQ_11 (Số ngân hàng giám sát) | Đếm trực tiếp các ngân hàng giám sát đang hoạt động từ `custodian_bank` (`FMS.BANK_MONI`). |
| **Nhóm 2** | K_QLQ_12 (Thời gian kỳ báo cáo) | Chuyển sang đọc `period_tp_code`, `period_val`, `rpt_year` từ `fmr_submission`, xử lý cả định dạng chữ (`Q1/2024`, `T03/2024`) và số cho kỳ bán niên (`5`). |
| **Nhóm 7** | K_QLQ_47, 48 (NAV / GDP) | **O_QLQ_44:** Chọn GDP hàng năm theo `period_tp_code DESC` trên `fct_macro_indicator_snpst`. Ghi nhận lưu ý về hệ số đơn vị giữa NAV (VND) và GDP (nghìn tỷ VND). |
| **Nhóm 13** | K_QLQ_96 (Ngân hàng giám sát) | **O_QLQ_47:** Giữ trường tên đầy đủ `custodian_bank_full_nm` theo mô tả BA (ghi chú sẵn khả năng đổi sang tên viết tắt `custodian_bank_short_nm` theo SQL tham khảo). |
| **Nhóm 17 & 22** | K_QLQ_117, 142 (ĐLPP) | **O_QLQ_46:** Chuẩn hóa việc xử lý `termination_dt` của đại lý phân phối chứng chỉ quỹ; cờ `active_status_flag = (termination_dt IS NULL)`. |
| **Nhóm 24** | K_QLQ_160, 161 (Chi nhánh CTQLQ NN) | **O_QLQ_45:** Bổ sung điều kiện loại các chi nhánh đã đóng cửa (`effective_end_dt IS NULL OR effective_end_dt > cuối kỳ`). |

---

## 3. Quản trị Chất lượng & Kết quả Quality Gates

Sau khi thực hiện các thay đổi, toàn bộ bộ công cụ Quality Gates của Datamart đã được chạy kiểm tra:

1. **Gate 8 (Design Lint) — PASS:**
   - Bắt đầu áp dụng rule **D13 (Luật A24)**: Quét toàn bộ cột trong `logic` Detail Mapping và công thức HLD. Module QLQ đạt **0 lỗi** (sạch 100%).
   - Bắt đầu áp dụng rule **D14**: Kiểm soát định dạng bảng mapping nguồn HLD. Sửa lỗi dán nhầm 7 ô ở K_QLQ_35 về chuẩn 4 ô.
2. **Gate 4 (Flat Table Coverage) — PASS:**
   - Toàn bộ 19 bảng LLD của QLQ đã được đồng bộ 100% sang Flat Table ClickHouse (`01_create_qlq_flat_tables.sql` và `02_populate_qlq_flat_tables.sql`).
   - 0 cột thiếu trong DDL và DML.
3. **Derived Files Freshness:**
   - [kpi_index.csv](file:///C:/Workspace/Design_DW/ubck_atomic_design/Datamart/index/kpi_index.csv) đã được tái đồng bộ (14,302 KPI hệ thống, khớp hoàn toàn).
   - [datamart_model.yaml](file:///C:/Workspace/Design_DW/ubck_atomic_design/Datamart/datamart_model.yaml) và [datamart_attributes.csv](file:///C:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/datamart_attributes.csv) đồng bộ 205 entity toàn hệ thống.

---

## 4. Danh mục tài liệu và mã nguồn thay đổi

| Loại tài liệu | Đường dẫn file | Nội dung thay đổi |
|:---|:---|:---|
| **Kiến trúc HLD** | `Datamart/hld/DTM_QLQ_HLD.md` | Bổ sung quyết định rà soát 28 Nhóm, cập nhật O_QLQ_44..47, chuẩn hóa bảng mapping nguồn K_QLQ_35 |
| **Detail Mapping** | `Datamart/lld/DTM_QLQ_Detail_Mapping.csv` | Chuẩn hóa 181 KPI QLQ, sửa logic tham chiếu bảng/cột chuẩn Atomic |
| **Tầng LLD (CSV)** | `Datamart/lld/QLQ/*.csv` (11 files) | Cập nhật PK Dimension `direct`, tích hợp `record_status_code`, cập nhật subqueries |
| **Flat Table ClickHouse** | `Datamart/flat-table/QLQ/01_create_qlq_flat_tables.sql`<br>`Datamart/flat-table/QLQ/02_populate_qlq_flat_tables.sql` | Đồng bộ DDL & DML ClickHouse theo LLD mới |
| **Mô hình Master** | `Datamart/datamart_model.yaml` | Đồng bộ entity và thuộc tính phân hệ QLQ |
| **Từ điển Thuộc tính** | `Datamart/lld/datamart_attributes.csv` | Đồng bộ danh mục cột Datamart |
| **Chỉ mục KPI** | `Datamart/index/kpi_index.csv` | Rebuild chỉ mục 14,302 KPI |
| **Governance Scripts** | `.claude/skills/datamart-review/scripts/check_design_lint.py`<br>`dm_logic_column_baseline.yaml` | Thêm rule D13 (A24), D14 và file baseline nợ |

---

## 5. Các điểm cần lưu ý & Kế hoạch tiếp theo

1. **Phối hợp Dev xác nhận dữ liệu thực tế (O_QLQ_32 & O_QLQ_44):**
   - Cần chạy query kiểm tra dữ liệu mẫu của `period_val` trên bảng `atm_fmr_submission` (xác nhận chuỗi dạng `'Q1/2024'` hay dạng số nguyên).
   - Xác nhận thang đo `period_tp_code` của chỉ tiêu GDP Việt Nam trên bảng `cl_risk_indicator_value` và đơn vị hiển thị NAV/GDP.
2. **Kế hoạch Phase tiếp theo:**
   - Tiếp tục theo dõi phản hồi từ BA cho các nhóm chỉ tiêu PENDING (Nhóm 29 → Nhóm 91) khi có bổ sung thông tin từ các hệ thống báo cáo định kỳ EAV.
