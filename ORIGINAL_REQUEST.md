# Original User Request

## 2026-09-11T08:54:09Z

Nâng cấp toàn diện skill datamart-review tại .claude/skills/datamart-review/ nhằm hoàn thiện quy trình kiểm soát chất lượng Datamart (BA ↔ HLD ↔ LLD ↔ Flat Table), tích hợp các bài học thực tế (Orphan Check 3 chiều, etl_logic content parity, bảo vệ master registry datamart_attributes.csv) và nâng cấp bộ công cụ script tự động hóa kiểm tra.

Working directory: C:\Workspace\Design_DW\ubck_atomic_design\.claude\skills\datamart-review
Integrity mode: development

## Requirements

### R1. Chuẩn hóa Quy trình và Checklist trong SKILL.md & Reference
- Rà soát và cập nhật SKILL.md và toàn bộ các tài liệu trong reference/ (technical_review_rules.md, review_checklist.md, issue_classification.md, kpi_reconciliation_rules.md, v.v.).
- Bổ sung quy định bắt buộc về:
  1. Orphan Check 3 chiều (LLD Attributes ↔ HLD Entities ↔ Flat Table SQL) với 2 nhánh xử lý rõ ràng (Nhánh A: hoàn tất phần còn thiếu nếu entity còn giá trị; Nhánh B: dọn dẹp nếu entity bị hủy).
  2. Kiểm tra etl_logic content parity giữa file Attributes của từng module (Datamart/lld/{MODULE}/*.csv) và master registry (Datamart/lld/datamart_attributes.csv).
  3. Cơ chế cảnh báo và chặn vi phạm khi phát hiện sửa file module mà quên đồng bộ master registry.
- Đảm bảo tính nhất quán tuyệt đối giữa SKILL.md và các tài liệu tham chiếu con, loại bỏ các chỉ dẫn mâu thuẫn hoặc cú pháp lỗi thời.

### R2. Nâng cấp và Mở rộng Bộ Công cụ Tự Động Hóa (Scripts)
- Cập nhật các script hiện có trong scripts/ (datamart_progress_analyzer.py, datamart_date_fk_checker.py).
- Bổ sung chức năng CLI tự động hóa (trong script hiện có hoặc tạo script kiểm tra mới):
  1. Tự động quét và phát hiện Orphan Entity 3 chiều cho một module cụ thể hoặc toàn bộ các module.
  2. Tự động so khớp nội dung etl_logic giữa file module Attributes và master datamart_attributes.csv, xuất danh sách dòng/cột bị lệch kèm chỉ báo nguồn cần sửa.
- Đảm bảo toàn bộ scripts chạy tương thích với Python trên môi trường Windows, xử lý chuẩn mã hóa UTF-8 và hỗ trợ phân tách delimiter động (, hoặc ;).

### R3. Kiểm chứng Độc lập trên Dữ liệu Thực tế
- Chạy kiểm thử các công cụ script và quy trình đã nâng cấp trên ít nhất 2 phân hệ thực tế trong kho lưu trữ (ví dụ: GSTT, QLCB, TKNB).
- Đảm bảo kết quả audit phát hiện đúng các trạng thái thực tế, không sinh false positives, và cung cấp báo cáo rõ ràng, dễ hành động cho reviewer.

## Acceptance Criteria

### Tính Toàn vẹn & Nhất quán Tài liệu
- [ ] SKILL.md mô tả đầy đủ các Gate kiểm soát, các kịch bản A-E, và tích hợp bài học thực tế mới nhất vào quy trình chính thức.
- [ ] Tất cả các file trong reference/ được cập nhật đồng bộ, không có liên kết đứt gãy hoặc mâu thuẫn tiêu chí với SKILL.md.
- [ ] Quy trình Orphan Check 3 chiều và etl_logic parity được định nghĩa cụ thể với điều kiện kích hoạt rõ ràng (trigger) và hành động xử lý chuẩn hóa.

### Bộ Script Tự Động Hóa
- [ ] Script kiểm tra Orphan 3 chiều và etl_logic parity chạy thành công từ command line mà không có lỗi runtime/encoding.
- [ ] Các script CLI hiện tại (datamart_progress_analyzer.py, datamart_date_fk_checker.py) tiếp tục hoạt động chính xác, bảo toàn các tham số dòng lệnh hiện có.
- [ ] Output của script hiển thị rõ ràng: số lượng pass/fail, vị trí file và tên entity/cột vi phạm nếu có.

### Kiểm thử & Nghiệm thu
- [ ] Chạy thành công kiểm tra thực tế trên ít nhất 2 module (GSTT và QLCB hoặc TKNB), ghi nhận kết quả đối soát khớp với hiện trạng của repo.
- [ ] Không làm gián đoạn hoặc phá vỡ các quy ước hiện hành của hệ thống Datamart.

## 2026-09-12T02:48:25Z

Thực hiện rà soát, kiểm định toàn diện thiết kế mới của phân hệ QLKD (Quản lý Kinh doanh) trên cả 4 lớp kỹ thuật (BA ↔ HLD ↔ LLD ↔ Flat Table) theo đúng chuẩn mực Kimball, SCD4A, và quy trình `datamart-review` đã được nâng cấp, kết hợp bộ công cụ CLI tự động hóa.

Working directory: C:\Workspace\Design_DW\ubck_atomic_design
Integrity mode: development

## Requirements

### R1. Macro-Audit & Đối Soát Số Lượng Cấp Module (Bước 0, 0b, 0c)
- Thực thi toàn bộ bộ công cụ phân tích tự động:
  + `python .claude/skills/datamart-review/scripts/datamart_progress_analyzer.py --module QLKD`
  + `python .claude/skills/datamart-review/scripts/check_orphan.py --module QLKD --strict`
  + `python .claude/skills/datamart-review/scripts/check_parity.py --module QLKD --strict`
  + `python .claude/skills/datamart-review/scripts/datamart_date_fk_checker.py --module QLKD`
- Kiểm tra cấu trúc HLD 5 Section (`Datamart/hld/DTM_QLKD_HLD.md`) và đối soát số lượng KPI 2 chế độ (Total Scope & Ready Scope) giữa `BRD/BA/BA_analyst_QLKD.csv`, HLD và LLD.
- Quét các chỉ tiêu bị XÓA (`Delete` / `DELETED`) từ BA và kiểm tra xem có vi phạm L1/L2-DELETE-VIOLATION hay không.
- Rà soát đặc biệt tình trạng các bảng vừa bị xóa/thay đổi (`DTM_QLKD_fct_securities_company_financial_snpst.csv`, `DTM_QLKD_fct_securities_company_service_registration.csv`, `DTM_QLKD_service_tp_dim_SCMS_CAT_SERVICE.csv`) nhằm đảm bảo đã được dọn dẹp triệt để theo Quy trình Deprecation 5 tầng (LLD, master attributes, datamart_model.yaml, Entities.csv/.md, Flat Table SQL) hay còn sót orphan (Nhánh B).

### R2. Micro-Review 4 Lớp Kỹ Thuật Chi Tiết Từng Nhóm Chỉ Tiêu
- **Lớp 1 (HLD Alignment):** Kiểm tra Coverage 2 chiều BA ↔ HLD, đúng Grain phân tích, Bảng KPI chuẩn 7 cột, phân định rõ Financial Flow (TTM) vs. Stock (Latest Quarter), logic temporal SQL.
- **Lớp 2 (LLD Attributes):** Verify Atomic YAML (tra cứu nguồn approved `DataModel/Atomic/`), tuân thủ chuẩn SCD4A (5 trường kỹ thuật + `ds_rcrd_st = 'ACTIVE'` trong mệnh đề JOIN), Role-Playing Date FK (`snpst_dt_dim_id` cho Fact Snapshot, `<role>_dt_dim_id` cho Fact Event, cấm `cdr_dt_dim_id` trên Fact), và kiểm tra naming theo `rule_physical_name_exceptions_datamart.csv`.
- **Lớp 3 (Detail Mapping):** Kiểm tra trace logic BA, inline DERIVED không tham chiếu mã KPI chéo, đối soát `mart_table`/`mart_column` khớp 1-1 với Attributes, cú pháp LOOKUP Date FK.
- **Lớp 4 (Model Registry & Flat Tables):** Khớp 1-1 với `datamart_model.yaml` và master `datamart_attributes.csv`, kiểm tra cấu trúc bảng Flat Table (`01_create_qlkd_flat_tables.sql` và `02_populate_qlkd_flat_tables.sql`).

### R3. Tổng Hợp Báo Cáo Scorecard & Danh Mục Action Items
- Phân loại toàn bộ các phát hiện theo 5 Kịch bản (A: Nguồn Atomic/BA; B: Datamart Pending; C: Lỗi kỹ thuật LLD; D: Kiến trúc HLD; E: Lệch logic).
- Xuất Bảng Scorecard đánh giá hiện trạng module QLKD (số lượng PASS / WARN / CRITICAL theo từng lớp), danh sách Blocker P0/P1 và Action Items cụ thể để bàn giao cho các skill thiết kế (`datamart-hld-design`, `datamart-lld-design`).

## Acceptance Criteria

### Đối Soát Số Lượng & Macro Audit
- [ ] Báo cáo số lượng KPI 2 chế độ (Total Scope, Ready Scope) chỉ rõ reconciled delta giữa BA ↔ HLD ↔ LLD.
- [ ] Báo cáo kết quả chạy 4 công cụ CLI (`datamart_progress_analyzer.py`, `check_orphan.py`, `check_parity.py`, `datamart_date_fk_checker.py`) với đầy đủ số liệu và log phát hiện.
- [ ] Xác nhận tình trạng của các bảng vừa bị xóa/thay đổi trong LLD: kiểm tra tính nhất quán 5 tầng (không còn tham chiếu mồ côi hoặc ghi nhận đúng trạng thái deprecation).

### Kiểm Định 4 Lớp Kỹ Thuật
- [ ] Bảng đánh giá chi tiết 4 Lớp (Lớp 1 HLD, Lớp 2 Attributes, Lớp 3 Detail Mapping, Lớp 4 Registry/Flat Table) cho toàn bộ các nhóm chỉ tiêu QLKD.
- [ ] Tất cả vi phạm về SCD4A, Role-Playing Date FK, Inline DERIVED, và Flatten etl_logic được phân loại chính xác theo mã lỗi chuẩn (`L2-SCD4A-TECH-FIELD`, `L2-DATE-FK-VIOLATION`, `L2-ORPHAN-3WAY-*`, `L2-ETL-LOGIC-PARITY-MISMATCH`, v.v.).

### Báo Cáo Tổng Hợp & Đề Xuất Xử Lý
- [ ] Bảng tổng hợp Scorecard thể hiện rõ tỷ lệ đạt chuẩn của module QLKD.
- [ ] Danh sách Action Items phân loại theo mức độ ưu tiên P0/P1/P2 kèm phân định kịch bản A/B/C/D rõ lượng để bàn giao thực hiện.

