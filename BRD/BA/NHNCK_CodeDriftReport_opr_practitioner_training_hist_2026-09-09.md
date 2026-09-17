# Code Drift Report — Operational Practitioner Training History (Nhóm 11)

**Ngày:** 2026-09-09
**Người phân tích:** nam.tranhoai@fssc.com.vn
**Phạm vi:** So khớp code lakehouse hiện tại (ground truth) với tài liệu thiết kế (LLD Datamart CSV + flat-table ClickHouse SQL). Báo cáo thuần tuý — KHÔNG tự sửa file thiết kế.

**Nguồn code đối chiếu (ground truth, sửa 2026-09-09 bởi duc.luxuan — theo BA SQL mới nhóm 11):**
- `/home/duxn/lakehouse_ubck/lakehouse_ubck_v1/dbt/models/datamart/NHNCK/dtm_opr_practitioner_training_hist.sql`
- `/home/duxn/lakehouse_ubck/lakehouse_ubck_v1/dbt/models/clickhouse/NHNCK/nhnck_opr_practitioner_training_hist_flat.sql`

**Tài liệu thiết kế đối chiếu (nghi ngờ stale, dated 2026-08):**
- `Datamart/lld/NHNCK/DTM_NHNCK_opr_practitioner_training_hist_NHNCK_SPECIALIZATION_COURSE_DETAILS.csv`
- `Datamart/flat-table/NHNCK/01_create_nhnck_flat_tables.sql` (dòng 289-309)
- `Datamart/flat-table/NHNCK/02_populate_nhnck_flat_tables.sql` (dòng 273-291)

---

## 1. Tóm tắt thay đổi trong code (2026-09-09)

- Bỏ join tới `NHNCK_SPECIALIZATION_COURSE_DETAILS` (qua atomic `sp_professional_training_class_enrollment`) — cột `exam_score` bị xoá hoàn toàn.
- `exam_result_code`, `exam_result_nm` không còn là JOIN phụ fan-out qua `sp_code` + denormalize `cl_value` — mà lấy **trực tiếp trên driving row** từ `sp_post_certification_training_result.training_result_status_code` và `training_cl_result_code`.
- Tên cột output giữ nguyên (`exam_result_code`, `exam_result_nm`) dù nguồn dữ liệu đã đổi — tên cột không còn phản ánh đúng bản chất (không phải "điểm thi" nữa mà là kết quả bồi dưỡng).

## 2. Diff: Mart — Code vs LLD CSV

| Attribute | LLD CSV ghi (2026-08, cũ) | Code thực tế (2026-09-09) | Cần sửa gì trong LLD |
|---|---|---|---|
| `exam_score` | Row #10: JOIN phụ qua `sp_code` tới `sp_professional_training_class_enrollment` (nguồn SPECIALIZATION_COURSE_DETAILS), fan-out | **Cột đã bị xoá hoàn toàn khỏi Mart** | Xoá row #10 |
| `exam_result_code` | Row #11: đổi tên từ Training Result Code, JOIN phụ qua `sp_code` tới `sp_professional_training_class_enrollment.training_result_code`, scheme `EXAM_RESULT` (-1/0/1) | Lấy **trực tiếp trên driving row** `sp_po_ce_tr_re.training_result_status_code` (atomic: `atm_sp_post_certification_training_result.training_result_status_code`) — không còn join phụ, không fan-out | Sửa `etl_logic`/`source_entity`/`atomic_table`/`atomic_column` → direct từ `sp_post_certification_training_result.training_result_status_code`; đổi `etl_logic_type` join_atomic → direct; scheme `EXAM_RESULT` → scheme mới cho `RESULT_STATUS` |
| `exam_result_nm` | Row #12: ETL-derived, denormalize từ `cl_value` (scheme `EXAM_RESULT`) qua `training_result_code` | Lấy **trực tiếp** `sp_po_ce_tr_re.training_cl_result_code` (atomic: `training_cl_result_code`, nguồn `CLASSIFICATION_RESULT`) — không còn join `cl_value` | Sửa `etl_logic`/`atomic_table`/`atomic_column` → direct từ `sp_post_certification_training_result.training_cl_result_code`; đổi `etl_logic_type` join_atomic → direct; `source_entity` đổi `Classification Value` → `Securities Practitioner Post Certification Training Result` |
| Filename gốc `..._NHNCK_SPECIALIZATION_COURSE_DETAILS.csv` | Tên file gắn với nguồn SPECIALIZATION_COURSE_DETAILS | Nguồn này không còn xuất hiện ở bất kỳ attribute nào trong bảng | Cân nhắc đổi tên file — không còn phản ánh đúng nguồn |
| Practitioner Code, Training Result Code (PK), Training Class Code/Name, Start/End Date, Training Hours, Hours Sufficiency, Source System Code | — | Không đổi | Không cần sửa |

## 3. Diff: ClickHouse — Code (dbt) vs `Datamart/flat-table/NHNCK/`

`01_create_nhnck_flat_tables.sql` và `02_populate_nhnck_flat_tables.sql` là script tạo bảng/populate riêng, tách biệt với dbt clickhouse model — lệch nghiêm trọng hơn:

| Điểm | `01_create...sql` / `02_populate...sql` (cũ) | Code dbt hiện tại | Vấn đề |
|---|---|---|---|
| `exam_score` | DDL khai báo cột `Nullable(Decimal(5,2))`; populate script `SELECT o.exam_score ... FROM datamart.opr_practitioner_training_hist` | Cột **không còn tồn tại** ở Mart nguồn (`dtm_opr_practitioner_training_hist`) | **Sẽ vỡ khi chạy `02_populate`** — `o.exam_score` reference tới cột không còn tồn tại trên bảng nguồn `datamart.opr_practitioner_training_hist`. Cần xoá cột này khỏi cả DDL (`01_create`) và SELECT (`02_populate`) |
| `exam_result_code` comment | "scheme: EXAM_RESULT, JOIN phụ qua sp_code (fan-out, đổi tên từ training_result_code)" | Lấy trực tiếp từ `training_result_status_code` trên driving row, không fan-out | Comment DDL sai — cần sửa lại mô tả |
| `exam_result_nm` comment | "(đổi tên từ training_result_nm)" | Lấy trực tiếp từ `training_cl_result_code` | Comment DDL sai — cần sửa lại mô tả |
| Tên cột, PK, ORDER BY, PARTITION BY | `practitioner_code`, `training_result_code` (PK), partition theo `training_start_dt` | Khớp code Mart | Không đổi |


