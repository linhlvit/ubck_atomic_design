# Phase 3 — Quy trình Flat Table và dọn dẹp bảng — LLD Datamart

Đồng bộ khép kín LLD ↔ flat table, ma trận Trigger, Checklist Phase 3. Đọc cùng `phase3_flat_table.md` (type mapping, ENGINE/PARTITION, pattern SQL). Mục cuối — All-Tier Cleanup khi bỏ một Fact/Dim — dùng được ở mọi Phase.

## Mục lục

- PHASE 3 — FLAT TABLE SQL
  - Quy trình đồng bộ khép kín LLD ↔ Flat Table (Closed-Loop Synchronization)
  - Ma trận 4 Trigger và Hành động đồng bộ (Sync Triggers & Actions Matrix)
  - Checklist Phase 3
  - PRE-CHECK
  - FILE 01 (CREATE)
  - FILE 02 (POPULATE)
  - POST-CHECK (sau khi sinh) & DESIGNER PRE-DELIVERY CHECKLIST
- QUY TRÌNH DEPRECATION VÀ DỌN DẸP ĐỒNG BỘ FACT/DIM DRAFT (ALL-TIER CLEANUP PROTOCOL)

## PHASE 3 — FLAT TABLE SQL

Đọc [`reference/phase3_flat_table.md`](phase3_flat_table.md) đầy đủ trước khi bắt đầu.

**Input Phase 3:**
- `Datamart/hld/DTM_{MODULE}_Entities.csv` — danh sách entity + FKs + reuse_status
- `Datamart/datamart_model.yaml` — data_type, nullable, key, physical_name của từng cột (nguồn sự thật, kể cả bảng reuse)
- Các file `Datamart/lld/{MODULE}/DTM_{MODULE}_*.csv` — chỉ đọc khi cần ETL logic; không cần đọc để lấy schema

**Output:**
```
Datamart/flat-table/{MODULE}/01_create_{module}_flat_tables.sql
Datamart/flat-table/{MODULE}/02_populate_{module}_flat_tables.sql
Datamart/flat-table/Common/01_create_common_flat_tables.sql        (Conformed Flat Tables: cdr_dt_flat [nguồn datamart.cdr_dt_dim])
Datamart/flat-table/Common/02_populate_common_flat_tables.sql      (Conformed Flat Tables: cdr_dt_flat [nguồn datamart.cdr_dt_dim])
```

### Quy trình đồng bộ khép kín LLD ↔ Flat Table (Closed-Loop Synchronization)
Mọi thay đổi tại tầng LLD (thêm/sửa cột Fact/Dim, sửa logic, thêm bảng mới, bãi bỏ bảng) bắt buộc kích hoạt quy trình đồng bộ 3 pha khép kín:
1. **Pha 1 (LLD Update):** Cập nhật file Attributes module và Detail Mapping; sinh lại master `datamart_attributes.csv` (`build_registry.py`) và khối `columns` của `datamart_model.yaml` (`build_model_yaml.py`), luôn `--check` trước.
2. **Pha 2 (Flat Table Sync):** Cập nhật DDL (`01_create_*.sql`), DML (`02_populate_*.sql`), và `flat_table_mapping.md`.
3. **Pha 3 (Quality Gate Review):** Chạy `check_parity.py --strict`, `check_orphan.py --strict`, và đối soát Column Coverage / 1-1 Projection Alignment.

### Ma trận 4 Trigger và Hành động đồng bộ (Sync Triggers & Actions Matrix)
- **Trigger 1 (Thêm cột mới vào Fact/Dim):** Thêm dòng vào Attributes module → sinh lại master + khối `columns` model (`build_registry.py`, `build_model_yaml.py`) → Thêm khai báo cột tương ứng trong DDL `01_create_*.sql` (kiểu ClickHouse, COMMENT) → Bổ sung projection vào `SELECT` của DML `02_populate_*.sql` → Cập nhật `flat_table_mapping.md`. **Dùng `build_flat_tables.py --module {MODULE} --sync-columns [--apply]` cho 2 bước DDL + DML (xem A20 trong [`rules.md`](rules.md)) — không chèn tay; quy tắc này áp dụng cả khi KHÔNG ở Phase 3 (VD thêm KPI vào Nhóm đã có).**
- **Trigger 2 (Sửa công thức / Thay thế cột):** Cập nhật Detail Mapping & Attributes CSV → sinh lại master (`build_registry.py`) → Sửa tên cột/schema trong DDL `01_create_*.sql` → Sửa projection trong DML `02_populate_*.sql` → Ghi log header file SQL (`-- Sửa YYYY-MM-DD: ...`).
- **Trigger 3 (Thêm bảng Fact/Operational mới):** Tạo file Attributes + cập nhật `datamart_model.yaml` + HLD/Entities → Thêm khối `CREATE TABLE` mới trong DDL `01_create_*.sql` → Thêm khối `DELETE/TRUNCATE` + `INSERT INTO ... SELECT` mới trong DML `02_populate_*.sql` → Thêm mục vào `flat_table_mapping.md`.
- **Trigger 4 (Bãi bỏ bảng — Deprecation / Cleanup):** Thực thi All-Tier Cleanup Protocol 5 tầng (LLD, master attributes, detail mapping, model.yaml, HLD) → Xóa/comment khối `CREATE TABLE` trong DDL → Xóa khối DML → Dọn sạch mục trong `flat_table_mapping.md`.
- **Trigger 5 (Khai thác Conformed Dimension trên ClickHouse):** Khi tầng BI/phân tích cần khai thác trực tiếp chiều ngày lịch (`cdr_dt_dim`) trên ClickHouse dưới dạng bảng phẳng `datamart.cdr_dt_flat` → BẮT BUỘC sinh/đồng bộ DDL `01_create_common_flat_tables.sql` và DML `02_populate_common_flat_tables.sql` tại `Datamart/flat-table/Common/` (nguồn nạp từ `datamart.cdr_dt_dim`) → Đảm bảo đầy đủ 9 cột kể cả `is_trading_date` (phục vụ lọc ngày giao dịch và đếm phiên lookback) → Cập nhật mục `Common Dimensions` trong `flat_table_mapping.md`.

### Checklist Phase 3

```
PRE-CHECK (trước khi sinh):
□ Đọc Entities.csv — đếm số fact + operational → báo cáo cho user → DỪNG chờ human xác nhận trước khi sinh
□ ❌ KHÔNG bắt đầu sinh SQL khi chưa có xác nhận số bảng flat
□ Đọc Datamart/datamart_model.yaml — lấy columns (physical_name, data_type, nullable, key) cho từng entity fact/operational/dim liên quan
□ Xác nhận tên thư mục output: Datamart/flat-table/{MODULE}/ (hoặc Datamart/flat-table/Common/ cho conformed dimensions)
□ Xác nhận tên file: 01_create_{module}_flat_tables.sql, 02_populate_{module}_flat_tables.sql

FILE 01 (CREATE):
□ Số bảng CREATE = số fact + số operational (kèm bảng Common conformed dimension cdr_dt_flat nếu thuộc phạm vi khai thác)
□ Naming fact flat: datamart.{module}_{datamart_table}_flat
□ Naming operational flat: datamart.{module}_{datamart_table}_flat (có module prefix — giống fact)
□ Naming common flat: datamart.{entity}_flat (ví dụ: datamart.cdr_dt_flat lấy nguồn từ datamart.cdr_dt_dim)

□ Thứ tự cột: fact columns → Calendar Date columns → dim columns
□ Operational: chỉ operational columns (không có Calendar Date, không có dim)
□ Không có technical metadata (ds_batch_date, ds_population_timestamp) trong flat table
□ Data type dùng ClickHouse types (Nullable wrapper theo nullable=true/false trong Attributes)
□ Calendar Date: chỉ lấy cột cdr_dt (có thể alias theo vai trò: snpst_cdr_dt, issue_cdr_dt, event_cdr_dt)
□ Cột fact/operational: lấy ĐÚNG các cột có trong Attributes.csv — không thêm, không bớt
□ Cột từ dim JOIN: chỉ JOIN dim có FK tương ứng trong Attributes.csv của bảng fact — không JOIN dim không có FK
□ Cột từ dim: bỏ PK surrogate và src_stm_code, giữ các cột giá trị nghiệp vụ còn lại
□ Cột từ dim: COMMENT ghi rõ "— từ {Dim Entity Name}"
□ ENGINE = ReplicatedReplacingMergeTree()
□ PARTITION BY toYYYYMM(<cột DD>)
□ ORDER BY (<cột DD>, <grain_key>)

FILE 02 (POPULATE):
□ Số TRUNCATE + INSERT block = số bảng trong file 01
□ SELECT list đủ cột, đúng thứ tự khớp với CREATE TABLE
□ Đếm cột SELECT = đếm cột CREATE
□ Tên bảng nguồn fact: datamart.{module}_{datamart_table} (có prefix module)
□ Tên bảng nguồn operational: datamart.{datamart_table} (không có prefix module)
□ Calendar Date join: datamart.cdr_dt_dim ON cdr_dt_dim.cdr_dt_dim_id = f.{role_dt_dim_id} (role-playing FK, ví dụ: snpst_dt_dim_id, trade_dt_dim_id)
□ Dim join: alias rõ ràng, ON {dim_pk} = f.{fk_col}
□ Operational: không có LEFT JOIN nào
□ Parameter Consistency: Toàn bộ điều kiện lọc ngày chạy ETL bắt buộc dùng thống nhất tham số :etl_date (WHERE snpst_cal.cdr_dt = :etl_date / WHERE evnt_cal.cdr_dt = :etl_date — cấm {etl_date}, $etl_date, hoặc hardcode date)

POST-CHECK (sau khi sinh) & DESIGNER PRE-DELIVERY CHECKLIST:
□ Flat Table Column Coverage Check:
  - 100% cột Fact và Operational từ Attributes module (trừ technical fields ds_batch_date, ds_population_timestamp) phải có mặt trong CREATE TABLE
  - 100% cột giá trị nghiệp vụ của Dim được JOIN (theo FKs) phải có mặt trong CREATE TABLE (bỏ PK surrogate, src_stm_code và audit fields SCD4A)
  - Có đầy đủ cột Calendar Date cdr_dt (theo alias vai trò ngày: snpst_cdr_dt, ...)
□ 1-1 Projection Alignment Check:
  - Mỗi cột trong CREATE có đúng 1 entry tương ứng trong SELECT của INSERT
  - Khớp 1-1 số lượng và thứ tự cột giữa câu lệnh CREATE TABLE (01_create_*.sql) và mệnh đề SELECT (02_populate_*.sql)
  - Tên alias trong SELECT (... AS col_name) khớp chính xác 100% với tên cột định nghĩa trong CREATE TABLE
□ Column Drift Check (Chống trôi lệch cột):
  - Không có bất kỳ cột nào trong SQL thiếu trong master datamart_attributes.csv
  - Không có cột Fact nào có KPI khai thác trong Detail Mapping mà bị bỏ sót khỏi Flat Table
  - Không có cột nào trong CREATE TABLE (fact/operational section) mà KHÔNG có trong Attributes.csv — cột thừa phải xóa
□ Dim JOIN: mọi dim được JOIN phải có FK tương ứng trong Attributes.csv — dim không có FK thì không JOIN, không lấy cột
□ Orphan Check (LLD ↔ Entities ↔ Flat Table) — 3 CHIỀU, không chỉ LLD↔Flat Table: Đối chiếu danh sách bảng fact/operational xuất hiện ở CẢ 3 nơi: (a) `Datamart/lld/{MODULE}/` (Attributes), (b) `Datamart/hld/DTM_{MODULE}_Entities.csv`/`.md` (Phase 2), (c) `Datamart/flat-table/{MODULE}/01_create_*.sql` (Phase 3). Một bảng có mặt ở (a) nhưng thiếu ở (b) và/hoặc (c) là orphan — dù KPI của nó đã READY trong HLD và có Detail Mapping (Phase 1 + Phase 2 Detail Mapping "xong" KHÔNG đồng nghĩa Phase 2 Entities + Phase 3 cũng đã xong).
  - **Khi phát hiện orphan, xác định đúng 1 trong 2 nhánh trước khi hành động — KHÔNG mặc định là nhánh dọn dẹp:**
    - **Nhánh A — Bảng còn giá trị, chỉ thiếu Phase 2 Entities/Phase 3 (bỏ sót, không phải đã hủy):** dấu hiệu nhận biết — có ≥1 KPI READY trong HLD tham chiếu bảng này, có dòng trong Detail Mapping, `datamart_model.yaml` vẫn có entry. → **HOÀN TẤT các phần còn thiếu** (thêm vào Entities.csv/.md nếu thiếu, sinh CREATE+POPULATE nếu thiếu Phase 3) — KHÔNG xóa gì cả.
    - **Nhánh B — Bảng thật sự đã bị hủy/gộp/thay thế:** dấu hiệu nhận biết — không còn KPI nào READY tham chiếu bảng này trong HLD hiện hành (đã bị deprecate/gộp sang bảng khác theo ghi chú lịch sử). → chạy quy trình **QUY TRÌNH DEPRECATION VÀ DỌN DẸP** bên dưới.
    - **Bài học thực tế (GSTT, phát hiện 2026-09-11):** `Fact Foreign Trading Minute Snapshot` (K_GSTT_78-80, Resolved 2026-09-04/O_GSTT_8) đã có Attributes + Detail Mapping + HLD READY đầy đủ, nhưng bị bỏ sót khỏi Entities.csv/.md VÀ khỏi Phase 3 flat table hơn 1 tuần — không ai phát hiện vì: (1) Orphan Check khi đó chỉ so LLD↔Flat Table (2 chiều, thiếu Entities), (2) Orphan Check chỉ chạy trong POST-CHECK ngay sau khi module vừa sinh SQL Phase 3 batch đầu — module GSTT đã "xong Phase 3" từ trước, nên khi Fact này được thêm SAU đó (để giải quyết 1 Open Issue phát sinh giữa chừng, không qua lại Phase 0→3 đầy đủ), không có điểm kích hoạt nào chạy lại Orphan Check.
  - **Trigger bắt buộc — không chỉ chạy 1 lần sau khi sinh SQL Phase 3 cho cả module:** Bất kỳ khi nào 1 Fact/Dimension MỚI được thêm vào Attributes (`datamart_attributes.csv` + file module) — dù đi qua flow Phase 0→3 đầy đủ từ đầu, hay được bổ sung giữa chừng để giải quyết 1 Open Issue/KPI mới phát sinh sau khi module đã "hoàn tất Phase 3" trước đó — PHẢI chạy ngay Orphan Check 3 chiều cho riêng entity đó, không đợi lần chạy Phase 3 tiếp theo của cả module. "Module đã Phase 3 xong" không miễn trừ khỏi quy tắc này.
□ Sau khi xuất 2 file: DỪNG chờ human duyệt → ❌ KHÔNG tự kết thúc skill khi chưa có xác nhận
```

---

## QUY TRÌNH DEPRECATION VÀ DỌN DẸP ĐỒNG BỘ FACT/DIM DRAFT (ALL-TIER CLEANUP PROTOCOL)

> **NGUYÊN TẮC CỐT LÕI:** Trong quá trình thiết kế, nếu một Fact hoặc Dim draft sau khi tạo ra mà quá trình review / cập nhật xác định **không còn cần nữa** (bị hủy bỏ, gộp bảng, hoặc chuyển thành Dimension thuần):
> Claude **TUYỆT ĐỐI KHÔNG ĐƯỢC** chỉ sửa/xóa bảng trong `Datamart/flat-table/` mà bỏ quên `Datamart/lld/`!
> Tình trạng `flat-table` đã loại bỏ bảng nhưng `Datamart/lld/` vẫn còn lưu file detail, master `datamart_attributes.csv` vẫn còn dòng rác, và `datamart_model.yaml` vẫn còn entity mồ côi (orphaned artifacts) là **LỖI NGHIÊM TRỌNG**.

Bắt buộc thực hiện đủ 5 bước dọn dẹp đồng bộ:
1. **Xóa file LLD detail:** Xóa file `Datamart/lld/{MODULE}/DTM_{MODULE}_{datamart_table}.csv` (và các file biến thể multi-source nếu có).
2. **Master `datamart_attributes.csv`:** sinh lại bằng `build_registry.py` sau khi xóa file LLD; `--allow-drop` chỉ khi human đã duyệt và danh sách "không còn file LLD per-module" của `--check` chỉ gồm bảng đang bỏ (`--allow-drop` xóa mọi bảng mồ côi cùng lúc). Không xóa dòng trong master bằng tay.
3. **Cập nhật `DTM_{MODULE}_Detail_Mapping.csv`:** Rà soát các KPI từng map vào bảng bị loại bỏ:
   - Nếu sáp nhập sang bảng khác: đổi `mart_table` và `mart_column` sang bảng mới.
   - Nếu không còn bảng đáp ứng và thống nhất bãi bỏ chỉ tiêu với BA: chuyển KPI sang `DEPRECATED`, đặt `column_role = 'DEPRECATED'`, để trống `mart_table`/`mart_column`, `logic = "Đã loại bỏ — không tạo cột/slicer"`, `tinh_chat = "Deprecated"`, cập nhật `ghi_chu` nêu rõ ngày bãi bỏ và biên bản thống nhất với BA (TUYỆT ĐỐI KHÔNG chuyển sang PENDING nếu đã xác định không triển khai). Nếu chỉ tạm thời thiếu bảng và vẫn bảo lưu nhu cầu tìm nguồn thay thế: áp dụng Quy tắc L4 để trống cả 4 cột và ghi rõ blocker vào `ghi_chu`.
4. **Xóa khỏi `Datamart/datamart_model.yaml`:** Xóa triệt để block entity `- id: "DTM-{datamart_table}"` khỏi file registry.
5. **Đồng bộ HLD & Flat Table SQL:** Cập nhật `DTM_{MODULE}_HLD.md` (Section 4 Reuse Analysis ghi rõ trạng thái `deprecated/removed`, giải thích lý do) và đảm bảo `01_create_*_flat_tables.sql` + `02_populate_*_flat_tables.sql` không còn DDL/INSERT của bảng đó.
