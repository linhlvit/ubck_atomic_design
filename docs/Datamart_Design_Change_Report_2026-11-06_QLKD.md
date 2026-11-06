# Báo cáo Thay đổi Thiết kế Datamart Phân hệ QLKD (2026-11-06)

> **Ngày lập báo cáo:** 2026-11-06  
> **Phân hệ:** **QLKD** (Quản lý Kinh doanh)  
> **Người thực hiện / Data Modeler:** Vương Ngô (`vuongjune2@gmail.com`)  
> **Mục theo dõi liên quan:** `O_QLKD_60` (tiểu mục `(i)` và Schema Drift tầng Atomic ngày 2026-11-05)  

---

## 1. Mục đích và Bối cảnh

Trong quá trình rà soát và đối soát tầng Atomic với tầng Datamart ngày 06/11/2026, nhóm thiết kế Datamart QLKD đã tiếp nhận xác nhận kỹ thuật từ Data Modeler và xử lý 2 nội dung quan trọng liên quan đến dữ liệu nhân sự cấp cao công ty chứng khoán (`SCMS_SC_FIRM_SENIOR_PERSONNEL`):

1. **Đảo chiều xử lý loại giấy tờ định danh (CCCD/CMND - `O_QLKD_60(i)`):**  
   - *Trước đây (26/10/2026):* Do thông tin sơ bộ cho rằng Atomic sẽ map riêng `NATIONAL_ID`, thiết kế LLD đã dùng `LEFT JOIN` 2 lần vào `ip_alternative_identification` (ưu tiên `NATIONAL_ID`, dự phòng `IDENTIFICATION`) kèm hàm `COALESCE`.  
   - *Thực tế xác nhận (06/11/2026):* Data Modeler xác nhận Atomic không sinh loại `NATIONAL_ID`; toàn bộ `NATIONAL_ID` (CCCD/CMND hiện hành) từ nguồn `SC_FIRM_SENIOR_PERSONNEL` đã được chuyển vào dòng có `identification_tp_code = 'IDENTIFICATION'`.  
   - *Giải pháp:* Tinh gọn logic ETL, loại bỏ nhánh join `NATIONAL_ID`, chỉ còn join trực tiếp duy nhất 1 lần vào `IDENTIFICATION` trên cả 4 bảng Operational nhân sự CTCK.

2. **Khắc phục Schema Drift Atomic về mã chức vụ (`sc_senior_personnel`):**  
   - *Hiện tượng:* Tầng Atomic cập nhật bảng `sc_senior_personnel` chỉ còn khóa ngoại `cl_sc_position_id`, đã loại bỏ cột `cl_sc_position_code`.  
   - *Giải pháp:* Điều chỉnh toàn bộ quan hệ JOIN từ `cl_sc_position_code` sang `cl_sc_position_id` nối bảng danh mục `cl_securities_company_position`, trích xuất mã chức vụ `cl_sc_position_code` và tên chức vụ `cl_sc_position_nm`.

---

## 2. Chi tiết các tệp và bảng được cập nhật

### 2.1. Danh sách bảng Operational và Logic điều chỉnh

| Bảng Datamart | Cột điều chỉnh | Logic ETL cũ | Logic ETL mới (2026-11-06) | Ghi chú |
|---|---|---|---|---|
| **`opr_individual_listed_company_role`** | `listed_company_role_id` (PK), `individual_identification_nbr` | `LEFT JOIN` 2 lần (`NATIONAL_ID` & `IDENTIFICATION`) + `COALESCE` | `LEFT JOIN ip_alternative_identification ON ip_id = sc_senior_personnel_id AND identification_tp_code = 'IDENTIFICATION' AND src_stm_code = 'SCMS_SC_FIRM_SENIOR_PERSONNEL'` | Nhánh nhân sự CTCK; không cần nạp lại Fact do giá trị hash PK không đổi |
| **`opr_individual_listed_company_role`** | `role_nm` | Nối danh mục qua `cl_sc_position_code` | `LEFT JOIN cl_securities_company_position ON cl_sc_position_id = sc_senior_personnel.cl_sc_position_id -> cl_sc_position_nm` | Khớp schema Atomic |
| **`opr_individual_profile`** | `identification_nbr` | `LEFT JOIN` 2 lần (`NATIONAL_ID` & `IDENTIFICATION`) + `COALESCE` | `LEFT JOIN ip_alternative_identification ON ip_id = sc_senior_personnel_id AND identification_tp_code = 'IDENTIFICATION'` | Bảng hồ sơ cá nhân |
| **`opr_individual_related_party_network`** | `individual_identification_nbr` | `LEFT JOIN` 2 lần (`NATIONAL_ID` & `IDENTIFICATION`) + `COALESCE` | `LEFT JOIN ip_alternative_identification ON ip_id = sc_senior_personnel_id AND identification_tp_code = 'IDENTIFICATION'` | Nhánh người nội bộ `SCMS_SC_FIRM_INSIDER_RELATION` |
| **`opr_individual_work_hist`** | `individual_identification_nbr` | `LEFT JOIN` 2 lần (`NATIONAL_ID` & `IDENTIFICATION`) + `COALESCE` | `LEFT JOIN ip_alternative_identification ON ip_id = sc_senior_personnel_id AND identification_tp_code = 'IDENTIFICATION'` | Nhánh lịch sử công tác |
| **`opr_securities_company_personnel_profile`** | `cl_sc_position_code`, `position_nm` | `direct` từ `sc_senior_personnel.cl_sc_position_code` | `join_atomic` qua `cl_securities_company_position` bằng `cl_sc_position_id` | Lấy mã & tên chức vụ từ bảng danh mục |

### 2.2. Đồng bộ các tầng tài liệu

- **HLD:** Cập nhật mục `O_QLKD_60` trong [`Datamart/hld/DTM_QLKD_HLD.md`](file:///C:/Workspace/Design_DW/ubck_atomic_design/Datamart/hld/DTM_QLKD_HLD.md) ghi nhận nội dung đảo chiều ngày 2026-11-06 và hướng dẫn cho đội ETL/Dev.
- **LLD (5 bảng Operational):**  
  - [`DTM_QLKD_opr_individual_listed_company_role_SCMS_SC_FIRM_SENIOR_PERSONNEL.csv`](file:///C:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/QLKD/DTM_QLKD_opr_individual_listed_company_role_SCMS_SC_FIRM_SENIOR_PERSONNEL.csv)
  - [`DTM_QLKD_opr_individual_profile_SCMS_SC_FIRM_SENIOR_PERSONNEL.csv`](file:///C:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/QLKD/DTM_QLKD_opr_individual_profile_SCMS_SC_FIRM_SENIOR_PERSONNEL.csv)
  - [`DTM_QLKD_opr_individual_related_party_network_SCMS_SC_FIRM_INSIDER_RELATION.csv`](file:///C:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/QLKD/DTM_QLKD_opr_individual_related_party_network_SCMS_SC_FIRM_INSIDER_RELATION.csv)
  - [`DTM_QLKD_opr_individual_work_hist_SCMS_SC_FIRM_SENIOR_PERSONNEL.csv`](file:///C:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/QLKD/DTM_QLKD_opr_individual_work_hist_SCMS_SC_FIRM_SENIOR_PERSONNEL.csv)
  - [`DTM_QLKD_opr_securities_company_personnel_profile_SCMS_SC_FIRM_SENIOR_PERSONNEL.csv`](file:///C:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/QLKD/DTM_QLKD_opr_securities_company_personnel_profile_SCMS_SC_FIRM_SENIOR_PERSONNEL.csv)
- **Attribute Master Registry & Model YAML:**
  - Đồng bộ logic và mô tả cột vào [`Datamart/lld/datamart_attributes.csv`](file:///C:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/datamart_attributes.csv) và [`Datamart/datamart_model.yaml`](file:///C:/Workspace/Design_DW/ubck_atomic_design/Datamart/datamart_model.yaml).
- **Quy tắc Kiểm định Lint:**
  - Gỡ bỏ mục ngoại lệ D16 cho `SCMS_SC_FIRM_SENIOR_PERSONNEL|NATIONAL_ID` trong [`.claude/skills/datamart-review/reference/atomic_literal_exceptions.yaml`](file:///C:/Workspace/Design_DW/ubck_atomic_design/.claude/skills/datamart-review/reference/atomic_literal_exceptions.yaml) (không còn bảng nào sử dụng literal này).

---

## 3. Kết quả Kiểm định Chất lượng (Quality Gates)

| Bộ kiểm tra | Lệnh thực thi | Kết quả | Trạng thái |
|---|---|---|:---:|
| **Design Lint QLKD** | `python .claude/skills/datamart-review/scripts/check_design_lint.py --module QLKD` | 0 ERROR, 2 WARNING (baseline cũ), 2 INFO | **PASS** |
| **Harness Guards V2** | `pytest tests/test_harness_v2_guards.py` | 8/8 passed | **PASS** |
| **Data Model Edit Guards** | `pytest tests/test_dm_guard_r6.py tests/test_dm_edit.py` | 20/20 passed | **PASS** |
| **Flat Table Checker QLKD** | `audit_module_flat_table(REPO_ROOT, 'QLKD')` | Critical: 0, Warning: 0 (22/22 bảng) | **PASS** |

---

## 4. Tác động và Khuyến nghị đối với Đội Kỹ thuật (ETL & BI)

1. **Đội ETL:**
   - Cập nhật câu lệnh trích xuất cho 4 bảng Operational nhân sự CTCK theo logic mới (chỉ join `IDENTIFICATION`).
   - Đổi phép JOIN trích xuất chức vụ sang `cl_sc_position_id`.
   - Do giá trị số giấy tờ lấy từ `IDENTIFICATION` trùng khớp với giá trị fallback trước đây, mã băm PK (`listed_company_role_id`) không bị biến động $\rightarrow$ **Không yêu cầu nạp lại toàn bộ dữ liệu lịch sử**.
2. **Đội BA / Dashboard:**
   - Bộ lọc số CCCD/CMND trên dashboard 360 nhân sự (`AND sp.NATIONAL_ID = :cccd`) hoạt động chuẩn xác với trường `individual_identification_nbr` được nạp từ trường `IDENTIFICATION` của Atomic.
