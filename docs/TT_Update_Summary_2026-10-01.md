# BÁO CÁO CẬP NHẬT THIẾT KẾ DATAMART PHÂN HỆ THANH TRA (TT)
## ĐỒNG BỘ MAPPING BA & 2 YÊU CẦU DEV (2026-10-01)

- **Mã tài liệu:** `DTM-TT-UPDATE-20261001`  
- **Cơ quan/Đơn vị chủ quản:** Ủy ban Chứng khoán Nhà nước (UBCKNN) — Dự án Thiết kế Datamart  
- **Phân hệ:** Datamart Thanh tra (TT — Thanh tra, Kiểm tra, Xử phạt & Đơn thư)  
- **Ngày cập nhật:** 01/10/2026  
- **Phạm vi cập nhật:** Nhóm 1 đến Nhóm 19 (Nhóm 20 giữ nguyên)  
- **Trạng thái kiểm tra Quality Gates:** Gate 0, 1, 2, 3, 4, 6, 7, 8 **PASS 100%**  

---

## 1. TỔNG QUAN YÊU CẦU & BỐI CẢNH CẬP NHẬT

Đợt cập nhật ngày 01/10/2026 của phân hệ **Thanh tra (TT)** được thực hiện nhằm đồng bộ 100% giữa thiết kế Datamart với các yêu cầu mới nhất từ Business Analyst (BA) tại [`BRD/BA/BA_analyst_TT.csv`](file:///c:/Workspace/Design_DW/ubck_atomic_design/BRD/BA/BA_analyst_TT.csv) (dòng 1–147) và giải quyết triệt để 2 bài toán kỹ thuật từ đội ngũ Data Engineer/Dev:

1. **Chuẩn hóa công thức đếm loại trừ trùng lặp (`COUNT(DISTINCT ID)`):**
   - Loại bỏ triệt để hiện tượng nhân đôi/nhân ba số liệu vụ việc, đoàn kiểm tra, quyết định xử phạt và đơn thư do quan hệ 1-N / N-N với thành phần đoàn, hành vi vi phạm và đối tượng.
2. **Yêu cầu Dev #1 (Nhóm 13 — Cơ cấu xử phạt theo hành vi):**
   - Xử lý bài toán một Quyết định xử phạt có nhiều hành vi vi phạm vi phạm khác nhau. Bổ sung trường gom nhóm `violation_behavior_group_nm` để đếm chính xác Quyết định tại tất cả các nhóm hành vi liên quan.
3. **Yêu cầu Dev #2 (Nhóm 16, 17, 18, 19 — Phân hệ Đơn thư):**
   - Thay đổi khóa chính thực thể `Operational Petition List` từ `petition_code` sang `petition_id` do phát hiện 161 đơn thư lịch sử có mã đơn bị NULL, gây lỗi mất dữ liệu khi ETL.
   - Bổ sung phân loại đơn mới `MULTI_CONTENT` ("Đơn có nhiều nội dung") và giải quyết tạm thời cột Đối tượng đơn thư (`target_nm`) trong khi chờ Atomic hoàn thiện LLD cho `Petition Target`.

---

## 2. MA TRẬN CHI TIẾT THAY ĐỔI THEO TỪNG CỤM NGHIỆP VỤ

### 2.1. Cụm 1: Thống kê chung & Xu hướng thời gian (Nhóm 1, 2, 6, 7, 11, 12, 16, 17)

- **Chuẩn hóa Measure:** Chuyển toàn bộ các biểu thức tính toán từ `COUNT(ID)` / `COUNT(CODE)` sang `COUNT(DISTINCT ID)` (hoặc `COUNT(DISTINCT code)` ở Dimension cha).
- **Bổ sung 5 KPI Chiều "Thời gian" (SLICER/GROUP_BY):**
  - **`K_TT_87`** (Nhóm 2 — STT 2): Thời gian thống kê số vụ việc thanh tra theo tháng.
  - **`K_TT_88`** (Nhóm 7 — STT 7): Thời gian xu hướng số cuộc kiểm tra theo tháng.
  - **`K_TT_89`** (Nhóm 12 — STT 12): Thời gian thống kê xử phạt vi phạm theo tháng.
  - **`K_TT_90`** (Nhóm 17 — STT 17): Thời gian thống kê tình hình xử lý đơn thư theo tháng.
  - **`K_TT_91`** (Nhóm 18 — STT 18): Thời gian phân tích cơ cấu loại đơn thư theo tháng.

### 2.2. Cụm 2: Hoạt động Thanh tra & Kiểm tra theo Hành vi (Nhóm 3, Nhóm 8)

- **Bỏ nhãn 'Khác':** BA xác nhận loại bỏ nhóm 'Khác' và các dòng có tên hành vi NULL.
- **Xử lý kỹ thuật:** 
  - Trường `violation_behavior_nm` được thiết lập `nullable: true` trên cả 2 dimension: `Inspection Team Violation Behavior Dimension` và `Examination Team Violation Behavior Dimension`.
  - Các KPI liên quan thêm điều kiện lọc tường minh `WHERE violation_behavior_nm IS NOT NULL`.

### 2.3. Cụm 3: Cơ cấu & Danh sách vụ việc theo Đối tượng (Nhóm 4, 5, 9, 10)

- **Nhóm 4 (Cơ cấu vi phạm theo đối tượng — Thanh tra):**
  - Chuẩn hóa 6 nhãn đối tượng: `CTCK`, `CTQLQ`, `CTĐC`, `CÁ NHÂN`, `TỔ CHỨC PHTP`, `KHÁC`.
  - Thực thể `Fact Inspection Team Target Activity` chuyển sang driving từ `inspection_team` và `LEFT JOIN` với bảng đối tượng (FK `inspection_team_target_dim_id` trở thành `nullable: true`). Đoàn thanh tra chưa gán đối tượng vẫn lên đủ 1 dòng thống kê.
- **Nhóm 5 (Danh sách vụ việc Thanh tra):** Đồng bộ hiển thị 6 nhãn đối tượng tương ứng.
- **Nhóm 9 & 10 (Cơ cấu & Danh sách vụ việc Kiểm tra):**
  - Giữ nguyên `INNER JOIN` theo xác nhận của BA.
  - Hiển thị 8 nhãn đối tượng IN HOA chuẩn mực: `CTCK`, `CTQLQ`, `CTĐC`, `TỔ CHỨC PHTP`, `TỔ CHỨC`, `CTKT`, `CÁ NHÂN`, `KHÁC`.

### 2.4. Cụm 4: Xử lý vi phạm & Quyết định xử phạt (Nhóm 13, 14, 15 — Dev #1)

- **Nhóm 13 (Cơ cấu xử phạt theo hành vi — Yêu cầu Dev #1):**
  - Bổ sung cột mới **`violation_behavior_group_nm`** trên thực thể `Fact Penalty Decision Subject Behavior`.
  - *Logic:* Ưu tiên lấy tên hành vi cụ thể của dòng xử phạt (`COALESCE`), fallback về tên hành vi đại diện của Quyết định khi dòng chi tiết không có nhánh chính. Quyết định có N hành vi sẽ được phân bổ và đếm đủ ở N nhóm.
  - Flat table ClickHouse: Bổ sung cột `violation_behavior_group_nm` ở cuối bảng và áp dụng `LEFT JOIN`.
- **Nhóm 14 (Cơ cấu xử phạt theo đối tượng):**
  - Đo lường chính xác bằng `COUNT(DISTINCT penalty_decision_dim_id)`.
  - Thực thể `Fact Penalty Decision Subject` chuyển sang driving từ `penalty_decision` + `LEFT JOIN` đối tượng (FK `penalty_decision_subject_dim_id` nullable), hiển thị 3 nhóm: `Tổ chức`, `Cá nhân`, `Khác`.
- **Nhóm 15 (Danh sách Quyết định xử phạt):** Dọn dẹp câu lệnh SQL tham khảo, bỏ các cột thừa trong CTE `rk`.

### 2.5. Cụm 5: Giám sát Đơn thư khiếu nại, tố cáo (Nhóm 16, 17, 18, 19 — Dev #2)

- **Tái cấu trúc Khóa chính (Primary Key Migration):**
  - Thực thể `Operational Petition List` (`opr_petition_list`) chính thức đổi PK từ `petition_code` sang **`petition_id`** (driving: `petition.petition_id`).
  - Cột `petition_code` chuyển thành thuộc tính hiển thị thông thường (`nullable: true`), bảo toàn 100% dữ liệu đối với 161 đơn thư cũ không có mã đơn.
- **Nhóm 18 (Cơ cấu theo loại đơn):**
  - Bổ sung loại đơn mới trong danh mục: `MULTI_CONTENT` $\to$ **"Đơn có nhiều nội dung"**.
  - Mẫu số tính tỷ lệ % được mở rộng bao quát toàn bộ các loại đơn thư tiếp nhận trong kỳ.
- **Nhóm 19 (Danh sách đơn thư chi tiết & Đối tượng):**
  - Chuẩn hóa nhãn hiển thị loại đơn và trạng thái xử lý (`Đã tiếp nhận`, `Đã xử lý`).
  - **Chỉ tiêu Đối tượng (`K_TT_68`):** Bổ sung cột mới **`target_nm`** trên `opr_petition_list`, tạm thời ánh xạ từ `petition.target_nm` (hoặc `CONTENT`) trong khi chờ giải quyết Open Issue **`O_TT_22`** (chờ Atomic bổ sung LLD cho bảng `THANHTRA_UAT.PETITION_TARGET`).

---

## 3. TÁI TẠO BẢNG PHẲNG CLICKHOUSE (FLAT TABLES RECREATION)

Do một số bảng phẳng thay đổi cấu trúc khóa sắp xếp (`ORDER BY`), chuyển đổi thuộc tính `Nullable` và bổ sung cột vật lý mới không thể thực hiện qua lệnh `ALTER TABLE` thông thường trên ClickHouse ReplicatedReplacingMergeTree, script tái tạo chuyên dụng đã được sinh ra:

📁 [`Datamart/flat-table/TT/00_recreate_tt_flat_tables_20261001.sql`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/flat-table/TT/00_recreate_tt_flat_tables_20261001.sql)

**4 Bảng phẳng cần Drop & Recreate khi triển khai môi trường:**
1. `tt_fct_inspection_team_target_activity_flat` (FK đối tượng nullable, ORDER BY thêm `inspection_team_code`).
2. `tt_fct_penalty_decision_subject_behavior_flat` (Bổ sung cột `violation_behavior_group_nm` ở cuối, FK nullable, ORDER BY mới).
3. `tt_fct_penalty_decision_subject_flat` (FK đối tượng nullable, ORDER BY mới).
4. `tt_opr_petition_list_flat` (PK `petition_id`, `petition_code` nullable, thêm cột `target_nm`).

---

## 4. DANH MỤC TỆP TIN THAY ĐỔI & TRẠNG THÁI GIT

| STT | Tệp tin thay đổi | Trạng thái | Nội dung chính |
| :---: | :--- | :---: | :--- |
| 1 | [`BRD/BA/BA_analyst_TT.csv`](file:///c:/Workspace/Design_DW/ubck_atomic_design/BRD/BA/BA_analyst_TT.csv) | Modified | Đồng bộ 28 dòng mapping và SQL tham khảo từ BA |
| 2 | [`Datamart/datamart_model.yaml`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/datamart_model.yaml) | Modified | Đăng ký cột mới `target_nm`, `violation_behavior_group_nm`, đổi PK `petition_id` |
| 3 | [`Datamart/hld/DTM_TT_HLD.md`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/hld/DTM_TT_HLD.md) | Modified | Cập nhật HLD Nhóm 1–19, dải KPI mới K_TT_87–91, ghi nhận O_TT_19–22 |
| 4 | [`Datamart/hld/DTM_TT_Entities.csv`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/hld/DTM_TT_Entities.csv) | Modified | Cập nhật định nghĩa và quan hệ thực thể HLD |
| 5 | [`Datamart/lld/DTM_TT_Detail_Mapping.csv`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/DTM_TT_Detail_Mapping.csv) | Modified | Cập nhật 110 dòng mapping chi tiết, COUNT DISTINCT và 5 KPI thời gian |
| 6 | [`Datamart/lld/TT/DTM_TT_opr_petition_list_THANHTRA_PETITION.csv`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/TT/DTM_TT_opr_petition_list_THANHTRA_PETITION.csv) | Modified | Chuyển PK sang `petition_id`, thêm `target_nm` |
| 7 | [`Datamart/lld/TT/DTM_TT_fct_penalty_decision_subject_behavior.csv`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/TT/DTM_TT_fct_penalty_decision_subject_behavior.csv) | Modified | Bổ sung thuộc tính `violation_behavior_group_nm` |
| 8 | [`Datamart/lld/TT/DTM_TT_fct_inspection_team_target_activity.csv`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/TT/DTM_TT_fct_inspection_team_target_activity.csv) | Modified | Chuyển driving sang `inspection_team`, FK đối tượng nullable |
| 9 | [`Datamart/lld/TT/DTM_TT_fct_penalty_decision_subject.csv`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/TT/DTM_TT_fct_penalty_decision_subject.csv) | Modified | Chuyển driving sang `penalty_decision`, FK đối tượng nullable |
| 10 | [`Datamart/lld/TT/DTM_TT_inspection_team_violation_behavior_dim_THANHTRA_VIOLATION_RECORD_BEHAVIOR.csv`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/TT/DTM_TT_inspection_team_violation_behavior_dim_THANHTRA_VIOLATION_RECORD_BEHAVIOR.csv) | Modified | `violation_behavior_nm` nullable: true |
| 11 | [`Datamart/lld/TT/DTM_TT_examination_team_violation_behavior_dim_THANHTRA_VIOLATION_RECORD_BEHAVIOR.csv`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/TT/DTM_TT_examination_team_violation_behavior_dim_THANHTRA_VIOLATION_RECORD_BEHAVIOR.csv) | Modified | `violation_behavior_nm` nullable: true |
| 12 | [`Datamart/lld/datamart_attributes.csv`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/datamart_attributes.csv) | Modified | Cập nhật từ điển thuộc tính master toàn hệ thống |
| 13 | [`Datamart/flat-table/TT/01_create_tt_flat_tables.sql`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/flat-table/TT/01_create_tt_flat_tables.sql) | Modified | Cập nhật DDL 4 bảng phẳng ClickHouse |
| 14 | [`Datamart/flat-table/TT/02_populate_tt_flat_tables.sql`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/flat-table/TT/02_populate_tt_flat_tables.sql) | Modified | Cập nhật DML nạp dữ liệu Flat Table |
| 15 | [`Datamart/flat-table/TT/00_recreate_tt_flat_tables_20261001.sql`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/flat-table/TT/00_recreate_tt_flat_tables_20261001.sql) | **New** | Script DROP phục vụ tái tạo bảng Flat Table |
| 16 | [`docs/changelog_2026-10-01.md`](file:///c:/Workspace/Design_DW/ubck_atomic_design/docs/changelog_2026-10-01.md) | Modified | Bổ sung Phần 2 ghi nhận toàn diện cập nhật phân hệ TT |
| 17 | [`docs/TT_Update_Summary_2026-10-01.md`](file:///c:/Workspace/Design_DW/ubck_atomic_design/docs/TT_Update_Summary_2026-10-01.md) | **New** | Báo cáo chi tiết chuyên đề cập nhật phân hệ TT |

---

## 5. KẾT QUẢ KIỂM THỬ QUALITY GATES

Chạy kiểm thử tự động qua lệnh:  
`python .claude/skills/datamart-review/scripts/run_quality_gates.py --module TT`

- ✅ **Gate 0 — Reference Integrity:** PASS
- ✅ **Gate 1 — Role-Playing Date FK Sanity:** PASS
- ✅ **Gate 2 — Attribute & ETL Logic Parity:** PASS
- ✅ **Gate 3 — 3-Way Orphan Entity:** PASS
- ✅ **Gate 4 — Flat Table Delivery:** PASS
- ✅ **Gate 6 — Context Budget:** PASS
- ✅ **Gate 7 — LLD Self-Check (TC4–TC7):** PASS
- ✅ **Gate 8 — Design Lint:** PASS
- ℹ️ **Gate 5 (HLD Structure):** 4 cảnh báo kế thừa từ bản phát hành gốc (HEAD) không ảnh hưởng tới logic nghiệp vụ mới.
