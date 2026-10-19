# Phase 1 — SELF-REVIEW TC1–TC12 — LLD Datamart

Chạy sau khi sinh xong mỗi file Attributes, trước khi trình bày cho human. Báo đủ 12 dòng PASS/FAIL.

## Mục lục

- Bước 4 — SELF-REVIEW trước khi trình bày kết quả
  - TC1 — Số cột khớp HLD
  - TC2 — etl_logic_type hợp lệ
  - TC2b — `key` hợp lệ theo loại bảng (bắt buộc, dùng bảng `examples/key_constraints.md`)
  - TC3 — Đầy đủ prefix table_name.column_name + thứ tự JOIN đúng
  - Sub-check TC3b — Cú pháp `LOOKUP <dim> ON ...` bắt buộc cho mọi lookup FK sang Dimension (bắt buộc)
  - TC4 — Lọc src_stm_code đầy đủ
  - TC5 — Cấu trúc CSV hợp lệ (bắt buộc dùng Bash tool)
  - TC6 — Physical name khớp tất định với logical name (bắt buộc dùng Bash tool)
  - TC7 — Tên bảng/cột đồng nhất xuyên suốt các nguồn output (bắt buộc dùng Bash tool)
  - TC8 — Tiền tố/hậu tố `datamart_table` khớp `table_type` (bắt buộc dùng Bash tool)
  - TC9 — `description` không lẫn KPI_ID/chi tiết ETL (bắt buộc dùng Bash tool)
  - TC10 — Đầy đủ trường kỹ thuật SCD4A trên Dimension / Operational (bắt buộc dùng Bash tool)
  - TC11 — Lọc `ds_rcrd_st = 'ACTIVE'` khi JOIN bảng Atomic SCD4A (bắt buộc dùng Bash tool)
  - TC12 — Giới hạn ngày bảng Atomic snapshot/event (A19, bắt buộc dùng Bash tool)

### Bước 4 — SELF-REVIEW trước khi trình bày kết quả

**Bắt buộc thực hiện sau khi sinh xong mỗi file, trước khi trình bày cho human duyệt.** Chạy **đủ 12 testcase**: TC1, TC2, TC2b, TC3 (gồm sub-check TC3b), TC4 (gồm sub-check A/B/C/D), TC5, TC6, TC7, TC8, TC9, TC10, TC11, TC12 — báo kết quả đủ 12 dòng PASS/FAIL, không gộp, không bỏ mục:

**TC1 — Số cột khớp HLD:**
- Đếm số attribute trong file CSV vừa sinh (theo `datamart_attribute` unique, không đếm multi-source row).
- Đối chiếu với bảng entity tương ứng trong `DTM_{MODULE}_HLD.md` (Section 3) — số cột trong bảng HLD.
- Báo: `✅ TC1 PASS: X cột — khớp HLD` hoặc `❌ TC1 FAIL: CSV có X cột, HLD có Y cột — Chênh: [danh sách cột thừa/thiếu]`.
- Nếu FAIL → sửa trước khi trình bày.

**TC2 — etl_logic_type hợp lệ:**
- Kiểm tra mọi row không phải PK: `etl_logic_type` không được trống (BK vẫn phải điền).
- **Sub-check bắt buộc:** Với mỗi row có `etl_logic_type ∈ {direct, computed}`: kiểm tra `atomic_table` của row đó có phải driving table không. Nếu `atomic_table` khác driving table → phải đổi thành `join_atomic`. Ngoại lệ: `lookup_dim`, `lookup_date`, `pivot`, `pending` không áp dụng sub-check này.
- Kiểm tra đặc biệt: khi file CSV có nhiều `atomic_table` khác nhau (ký hiệu ` / ` hoặc nhiều row khác nhau) → bảng nào không phải driving phải dùng `join_atomic`.
- Báo: `✅ TC2 PASS` hoặc `❌ TC2 FAIL: [danh sách row sai etl_logic_type — ghi rõ atomic_table và driving table]`.
- Nếu FAIL → sửa trước khi trình bày.

**TC2b — `key` hợp lệ theo loại bảng (bắt buộc, dùng bảng `examples/key_constraints.md`):**
- Xác định loại bảng (`fact` / `dim` / `operational`) từ `datamart_entity`/tên file.
- **Fact:** không được có bất kỳ row nào `key = PK`. Chỉ `FK → <Dim>` / `DD` / (trống) hợp lệ.
- **Dimension:** `key ∈ {PK, BK, (trống)}` — cấm `FK`, `DD`. Bắt buộc có ít nhất 1 `PK` và ít nhất 1 `BK`.
- **Operational:** `key ∈ {PK, BK, (trống)}` — cấm `FK`, `DD`. Bắt buộc có đúng 1 `PK` (thường là `_code` đóng vai trò PK, không tạo `_id` riêng).
- Với mọi row `key = BK`: `etl_logic` và `etl_logic_type` không được trống (BK là business key thật, map từ Atomic — không phải surrogate generated).
- Với mọi row `key = PK`: `description` không được lẫn chữ "BK" hoặc ngược lại — token trong `description` (nếu có nhắc lại key) phải khớp đúng giá trị cột `key` của chính dòng đó.
- **Sub-check bắt buộc — format `etl_logic`/4 cột source của dòng `key = PK` trên Dimension/Operational:** Dòng PK phải có ĐÚNG format: `etl_logic` = trống, `etl_logic_type = Generated`, `source_entity = Generated`, và cả 3 cột `atomic_table`/`source_attribute`/`atomic_column` = trống. Vi phạm khi: (a) `etl_logic` chứa literal chuỗi `"Generated"` thay vì để trống (VD `etl_logic = Generated, etl_logic_type = direct` — sai cả 2: `etl_logic` không được có giá trị, và `etl_logic_type` phải là `Generated` chứ không phải `direct`); (b) bất kỳ cột nào trong `atomic_table`/`source_attribute`/`atomic_column` có giá trị `"Generated"` thay vì để trống — chỉ riêng `source_entity` mới được ghi `Generated`.
  - Bài học thực tế (rà soát 2026-07-27): 3 file (`foreign_investor_dim`, `securities_dim`, `market_index_dim` — cả bản gốc lẫn master `datamart_attributes.csv`) đều ghi dòng PK dạng `...,Generated,direct,Generated,Generated,Generated,Generated` (tổng 6 ô cuối: `etl_logic`, `etl_logic_type`, rồi 4 cột source đều dính literal `Generated` hoặc `direct` sai) — trong khi các Dimension khác cùng dự án (`cl_dim`, `securities_practitioner_dim`, `sp_license_certificate_type_dim`) đã làm đúng: `etl_logic` trống, `etl_logic_type = Generated`, chỉ `source_entity = Generated`, 3 cột sau trống. Xem ví dụ đúng ở `examples/key_constraints.md` dòng "Inspection Team Dimension","PK",...,"","Generated".
  - Báo: `✅ TC2b-PK-format PASS` hoặc `❌ TC2b-PK-format FAIL: [tên bảng] dòng PK có etl_logic='[giá trị]' (phải trống) hoặc cột source='[giá trị]' (phải trống, trừ source_entity)`.
- Báo: `✅ TC2b PASS` hoặc `❌ TC2b FAIL: [danh sách row vi phạm — ghi rõ key hiện tại, loại bảng, và vi phạm cụ thể]`.
- Nếu FAIL → sửa trước khi trình bày (Dim/Operational thiếu etl_logic cho BK → điền đầy đủ).
- **Fact có `key = PK` → XÓA HẲN TOÀN BỘ DÒNG (row) khỏi CSV — không phải chỉ đổi giá trị cột `key` thành trống và giữ nguyên dòng.** Bài học thực tế (module GSDC, 2026-07-22): đã từng chỉ đổi `key: PK` → `key: ''` mà giữ nguyên dòng `fct_..._id`, khiến cột surrogate thừa vẫn tồn tại trong Attributes/registry/SQL sau khi báo "đã fix" — human phải tự phát hiện lại. Trước khi xóa, kiểm tra cột đó có được tham chiếu ở nơi khác không (`grep` trong `Detail_Mapping.csv` và `HLD.md`): nếu KHÔNG có tham chiếu nào → xóa hẳn dòng; nếu có bằng chứng ETL cần cột đó cho merge/upsert kỹ thuật → giữ dòng nhưng `key` để trống (ngoại lệ hiếm, cần nêu rõ lý do). Khi xóa, đồng bộ đủ 4 nơi: (1) file Attributes detail, (2) master `datamart_attributes.csv` — sinh lại bằng `build_registry.py`, (3) `datamart_model.yaml` — sinh lại khối `columns` bằng `build_model_yaml.py`, KHÔNG dùng `yaml.dump`, (4) file SQL Phase 3 đã sinh nếu có (`01_create_*.sql` dòng CREATE, `02_populate_*.sql` dòng SELECT).
- **Sub-check Date FK trên Fact table (Role-Playing Date Dimension — bắt buộc):**
  - Mọi Fact table (`table_type: "fact"` hoặc bảng bắt đầu bằng `fct_`):
    - **CẤM TUYỆT ĐỐI** cột có tên `datamart_column = 'cdr_dt_dim_id'` hoặc `datamart_attribute = 'Calendar Date Dimension Id'`. Cột `cdr_dt_dim_id` CHỈ ĐƯỢC PHÉP là PK của chính bảng `cdr_dt_dim`.
    - Mọi FK trỏ tới `cdr_dt_dim` trên Fact PHẢI mang tên theo vai trò nghiệp vụ (Role):
      - Nếu là Fact Snapshot (tên bảng có hậu tố `_snpst`): Cột snapshot date bắt buộc là `datamart_attribute: "Snapshot Date Dimension Id"`, `datamart_column: "snpst_dt_dim_id"`.
      - Nếu là Fact Transaction/Event/khác: Bắt buộc dùng `<Role> Date Dimension Id` → `<role>_dt_dim_id` (ví dụ `issue_dt_dim_id`, `trade_dt_dim_id`, `submission_dt_dim_id`, `evaluation_dt_dim_id`, `effective_dt_dim_id`...).
    - Nếu phát hiện `cdr_dt_dim_id` trên Fact table → báo FAIL ngay lập tức và yêu cầu đổi tên theo vai trò nghiệp vụ.
  - **Script kiểm tra tự động (bắt buộc dùng Bash tool):**
    ```bash
    python -c "
    import csv, sys
    sys.stdout.reconfigure(encoding='utf-8')
    files = ['<path_to_attributes_file>']  # file Attributes CSV vừa sinh
    BANNED = {'cdr_dt_dim_id', 'calendar_dt_dim_id'}
    BANNED_LOGICAL = {'Calendar Date Dimension Id'}
    violations = []
    for fpath in files:
        with open(fpath, encoding='utf-8-sig') as f:
            reader = csv.DictReader(f)
            for i, row in enumerate(reader, 2):
                tbl = row.get('datamart_table','')
                col = row.get('datamart_column','')
                attr = row.get('datamart_attribute','')
                # Skip the cdr_dt_dim table itself (PK is valid there)
                if tbl == 'cdr_dt_dim':
                    continue
                if tbl.startswith('fct_') or 'fact' in row.get('table_type','').lower():
                    if col in BANNED or attr in BANNED_LOGICAL:
                        violations.append(f'  Row {i}: {tbl}.{col} ({attr})')
    if violations:
        print('❌ TC2b-DATE-FK FAIL:')
        for v in violations: print(v)
    else:
        print('✅ TC2b-DATE-FK PASS')
    "
    ```

**TC3 — Đầy đủ prefix table_name.column_name + thứ tự JOIN đúng:**
- Kiểm tra mọi column reference trong `etl_logic` có dạng `<table>.<col>`.
- Ngoại lệ không cần prefix: literal values, SQL functions (`YEAR(...)`, `COUNT(...)`), NULL, ETL runtime parameter (`:etl_date` — không dùng `{etl_date}`).
- **Sub-check thứ tự JOIN (bắt buộc):** Với mọi row có `etl_logic_type ∈ {join_atomic, lookup_dim, lookup_date}` mà `etl_logic` chứa từ khóa `JOIN`: kiểm tra `etl_logic` có chứa dấu `→` (hoặc `->`), và toàn bộ JOIN clause phải nằm TRƯỚC dấu `→`, cột giá trị nằm SAU. Vi phạm khi: (a) có `JOIN` nhưng không có `→`/`->`, hoặc (b) cột giá trị xuất hiện trước từ khóa `JOIN` đầu tiên trong chuỗi.
- Báo: `✅ TC3 PASS` hoặc `❌ TC3 FAIL: [danh sách etl_logic thiếu prefix hoặc sai thứ tự JOIN — ghi rõ loại lỗi]`.
- Nếu FAIL → sửa trước khi trình bày.

**Sub-check TC3b — Cú pháp `LOOKUP <dim> ON ...` bắt buộc cho mọi lookup FK sang Dimension (bắt buộc):**
- Bài học thực tế (module QLCB, 2026-07-23): sub-check thứ tự JOIN ở trên chỉ kích hoạt khi `etl_logic` chứa từ khóa `JOIN` — 4/6 file LLD của QLCB dùng dạng `<dim>.<col> WHERE <dim>.<col> = <driving>.<col>` (không có `JOIN` keyword, chỉ có `WHERE`) hoặc multi-hop `INNER JOIN ... WHERE <dim>.<col> = ... → <dim>.<col>` (JOIN đúng thứ tự trước `→`, nhưng hop lookup cuối vẫn dùng `WHERE` thay vì `LOOKUP...ON`) — cả 2 pattern đều PASS sub-check thứ tự JOIN vì không vi phạm quy tắc "JOIN trước, giá trị sau `→`", nhưng vẫn sai format chuẩn. Xem `examples/etl_logic_wrong.md` mục SAI 9.
- Với mọi row có `etl_logic_type ∈ {lookup_dim, lookup_date}`: kiểm tra hop lookup (không JOIN clause phía trước thì là toàn bộ `etl_logic`; có JOIN clause phía trước thì là phần sau dấu `→`) phải khớp cú pháp `LOOKUP <dim_table> ON <dim_table>.<col> = <table>.<col>` — bắt đầu bằng từ khóa `LOOKUP`, có `ON`, không chứa `WHERE` value-first trong chính hop đó.
- Vi phạm khi: (a) toàn bộ `etl_logic` là `<dim>.<col> WHERE <dim>.<col> = ...` (thiếu `LOOKUP`, giá trị đặt trước điều kiện); (b) có JOIN clause hợp lệ trước `→` nhưng phần sau `→` là `<dim>.<col>` trần hoặc dùng `WHERE` thay vì `LOOKUP <dim> ON ...`.
- Khi phát hiện vi phạm (b), kiểm tra thêm: `etl_logic_type` của row đó có đang để `join_atomic` thay vì `lookup_dim`/`lookup_date` không — nếu hop cuối là lookup dimension thì bắt buộc đổi `etl_logic_type` cho khớp.
- Báo: `✅ TC3b PASS` hoặc `❌ TC3b FAIL: [danh sách attribute thiếu LOOKUP...ON — ghi rõ pattern (a) hay (b), và etl_logic_type có cần đổi không]`.
- Nếu FAIL → sửa trước khi trình bày.

**TC4 — Lọc src_stm_code đầy đủ:**

Sub-check A — `src_stm_code` attribute của bảng dim/operational:
- Với mỗi bảng `dim` và `operational`: kiểm tra attribute `src_stm_code` có `etl_logic` chứa điều kiện `WHERE <table>.src_stm_code = '...'` hoặc `WHERE <table>.src_stm_code IN (...)`.
- Báo fail nếu thiếu: `❌ TC4A FAIL: [tên bảng] thiếu WHERE filter trên src_stm_code`.

Sub-check B — JOIN sang bảng Atomic khác driving table:
- Với mọi row có `etl_logic_type ∈ {join_atomic, lookup_dim, lookup_date}`: nếu bảng đích (`atomic_table`) là Atomic entity có cột `src_stm_code` (xác định bằng cách kiểm tra `etl_logic` có tham chiếu bảng đó không), thì `etl_logic` phải chứa `AND <atomic_table>.src_stm_code = '<VALUE>'` trong điều kiện JOIN.
- Ngoại lệ không áp dụng sub-check B: `cv` (Classification Value) và `cdr_dt_dim` (Calendar Date) — 2 bảng này là conformed/shared, không có phân biệt nguồn.
- Lý do (forward-compatibility): khi Atomic table sau này nhận thêm nguồn mới, ETL join không bị nhân bản dữ liệu sai nguồn.
- Báo fail nếu thiếu: `❌ TC4B FAIL: [attribute] — join sang [atomic_table] thiếu AND src_stm_code filter`.

Sub-check C — Giá trị `src_stm_code` đúng format (không chép theo tên file Atomic):
- Giá trị `src_stm_code` là data value (dùng dấu `_` nối module + table, VD `NHNCK_CERTIFICATES`) — **khác** với tên file Atomic YAML (dùng dấu `.`, VD `dm_atm_..._-NHNCK.CERTIFICATES.yaml`). Đây là 2 thứ khác nhau; nhầm lẫn giữa chúng là lỗi đã từng xảy ra thực tế (2026-07-21, module NHNCK/QLCB/QLKD).
- Regex kiểm tra: mọi giá trị trong `src_stm_code = '...'` hoặc `src_stm_code IN (...)` **không được chứa dấu `.`** giữa 2 khối chữ hoa (pattern lỗi: `'[A-Z][A-Z0-9_]*\.[A-Z][A-Z0-9_]*'`).
- Nếu phát hiện dấu chấm → tra lại `classification_context` của attribute "Source System Code" trong Atomic YAML tương ứng (theo quy trình tra cứu Atomic ở đầu `SKILL.md`) để lấy giá trị đúng, KHÔNG tự suy ra bằng cách thay `.` → `_`.
- Áp dụng luôn cho tên file dim/operational: `DTM_{MODULE}_{mart_table}_{src_stm_code}.csv` — phần `{src_stm_code}` trong tên file cũng phải dùng dấu `_`, không dùng dấu `.`.
- Báo fail nếu phát hiện: `❌ TC4C FAIL: [file/attribute] — src_stm_code = '[giá trị sai]' dùng dấu chấm, đúng phải là '[giá trị đúng]'`.

Sub-check D — Giá trị `src_stm_code` khớp đúng module nguồn thật của bảng đích (không suy diễn theo tên module đang thiết kế):
- TC4B chỉ kiểm tra "có filter `src_stm_code` hay không"; TC4C chỉ kiểm tra "định dạng gạch dưới hay dấu chấm". Cả 2 đều **không** verify bản thân giá trị filter có đúng thật không — đây là lỗi đã xảy ra thực tế (module NHNCK, 2026-07-21): `etl_logic` JOIN tới `geographic_area` (Atomic entity thuộc phân hệ **ECAT**, không phải NHNCK) nhưng viết `AND geographic_area.src_stm_code = 'NHNCK_COUNTRIES'` — đúng định dạng gạch dưới (qua TC4C), có mặt điều kiện lọc (qua TC4B), nhưng sai hoàn toàn giá trị vì tự suy diễn theo tên module đang thiết kế (NHNCK) thay vì tra cứu module nguồn thật của bảng đích (`geographic_area` luôn thuộc ECAT dù được dùng bởi bất kỳ module nào).
- Quy tắc: mọi khi `etl_logic_type ∈ {join_atomic, lookup_dim, lookup_date}` JOIN sang 1 **shared/cross-module Atomic entity** (entity dùng chung nhiều module — dấu hiệu nhận biết: entity nằm trong BCV Core Object `Location`/`Involved Party`/`Common`/`Classification`, hoặc tên entity không có prefix module cụ thể, VD `geographic_area`, `ip_alternative_identification`, `ip_postal_address`) — **không được suy diễn giá trị `src_stm_code` từ tên module đang thiết kế**. Bắt buộc mở đúng file Atomic YAML của bảng đích (`grep -rl "entity_physical_name: \"<atomic_table>\"" DataModel/Atomic/**/*.yaml DataModel/working/Atomic/**/*.yaml`), đọc `classification_context`/`etl_derived_value` của attribute "Source System Code" trong CHÍNH FILE ĐÓ (không phải file của driving table module đang thiết kế) để lấy giá trị thật.
- Ví dụ cụ thể: bảng `geographic_area` luôn có nguồn `dm_atm_geographic_area-ECAT.COUNTRY.yaml` (hoặc `.REGION`/`.PROVINCE_NEW`/... tùy cấp hành chính) — giá trị `src_stm_code` đúng luôn có prefix `ECAT_`, bất kể module Datamart nào (NHNCK, QLCB, GSDC...) đang JOIN tới nó để lấy tên quốc gia/tỉnh/thành.
- Cách kiểm tra bằng script: với mỗi giá trị `src_stm_code = 'X'` xuất hiện trong `etl_logic`, tách phần trước dấu `_` đầu tiên trong `X` — nếu phần đó KHÔNG khớp `source_system` thật của Atomic YAML chứa `atomic_table` đang JOIN (tra bằng `grep "source_system:" <file>.yaml` ngay dưới attribute Source System Code) → nghi vấn sai, cần xác nhận thủ công bằng cách đọc `classification_context`/`etl_derived_value`.
- Báo fail nếu phát hiện: `❌ TC4D FAIL: [attribute] — join sang [atomic_table] dùng src_stm_code = '[giá trị nghi sai]', nhưng Atomic YAML của [atomic_table] ghi source_system=[X] → giá trị đúng phải là '[giá trị đúng theo classification_context]'`.

Báo tổng: `✅ TC4 PASS` (A, B, C, D đều pass) hoặc liệt kê từng lỗi A/B/C/D.
Nếu FAIL → sửa trước khi trình bày.

**TC5 — Cấu trúc CSV hợp lệ (bắt buộc dùng Bash tool):**
- Sau khi Write file, chạy lệnh sau bằng Bash tool:
  ```bash
  python -c "
  import csv, sys
  sys.stdout.reconfigure(encoding='utf-8')
  # auto-detect delimiter
  with open('<path_to_file>', encoding='utf-8-sig') as sniff_f:
      dialect = csv.Sniffer().sniff(sniff_f.read(2048))
  with open('<path_to_file>', encoding='utf-8-sig') as f:
      rows = list(csv.reader(f, delimiter=dialect.delimiter))
  bad = [i for i,r in enumerate(rows) if len(r) != 15]
  print(f'Rows: {len(rows)-1} data rows')
  print('Bad rows:', bad if bad else 'none')
  "
  ```
- Báo: `✅ TC5 PASS: N rows × 15 cols` hoặc `❌ TC5 FAIL: row [i] có X cột — [nội dung row]`.
- Nếu FAIL → sửa (thường do dấu `"` thiếu trong ô trống hoặc dấu phẩy trong etl_logic chưa được quote) → chạy lại TC5 → báo kết quả.

**TC6 — Physical name khớp tất định với logical name (bắt buộc dùng Bash tool):**

- Mục đích: TC6 bản đầu (chỉ "tự nhìn bằng mắt") đã được kiểm chứng là **không phát hiện được gì** — khi áp dụng thử thuật toán tất định bên dưới lên `datamart_attributes.csv`/`datamart_model.yaml` hiện có (2026-07-16), phát hiện thực tế 2 lỗi cùng loại đã lọt từ trước: "Practitioner" → viết tắt `prac` (9 bảng NHNCK) và "Securities Company" → viết tắt `sc` (4 bảng NHNCK) — cả hai đều không có trong exceptions. TC6 phải **tính toán, không đoán**.
- Thuật toán: với mỗi `datamart_entity` (logical name), tính **physical name kỳ vọng** bằng cách áp dụng đúng PHYSICAL NAMING RULE (tách từng từ theo khoảng trắng/gạch ngang, tra `rule_physical_name_exceptions_datamart.csv`, giữ full word nếu không có exception, nối bằng `_`) — rồi so với `datamart_table` thực tế trong **toàn bộ** `datamart_attributes.csv` (mọi module, không chỉ module đang thiết kế — bắt cả trường hợp entity conformed/shared bị đặt tên lệch giữa các module).
- Chạy script sau **trên toàn bộ master sau khi sinh lại bằng `build_registry.py`** (không chỉ file vừa sinh — vì lỗi có thể đã tồn tại từ trước, TC6 phải quét lại toàn bộ mỗi lần có thay đổi):
  ```bash
  python -c "
  import csv, re, sys
  sys.stdout.reconfigure(encoding='utf-8')

  # Whitelist ngoại lệ đã xác nhận là quy ước riêng, không phải lỗi — cập nhật khi có ca mới được human duyệt
  # CẢNH BÁO: KHÔNG thêm entry vào đây chỉ vì "có vẻ là quy ước riêng" — phải xác minh bằng chứng cụ thể
  # (VD: rule_physical_name_exceptions_datamart.csv, tài liệu quyết định, hoặc human xác nhận trực tiếp).
  # Bài học 2026-07: 'cls_dim' từng bị thêm vào đây với lý do tự suy diễn "quy ước 3-ký-tự cho bảng conformed"
  # — không có căn cứ nào cả, chỉ là lỗi gõ tay (thừa chữ 's') trong datamart_model.yaml. Việc thêm exception
  # đã che giấu lỗi thật khỏi TC6/TC7 trong nhiều tháng dù cả 2 TC vẫn chạy đúng và báo đúng mismatch mỗi lần —
  # vấn đề nằm ở người đọc kết quả tự nhận định "known exception" mà không truy nguyên gốc.
  KNOWN_EXCEPTIONS = {
      'fct_public_company_nonfinancial_score_snpst',  # "Non-Financial" viết liền không gạch dưới ở tên bảng (naive split coi "Non"/"Financial" là 2 từ riêng) — nhưng LƯU Ý: cột non_financial_m_score trong Fact Risk Score Snapshot lại giữ gạch dưới → không nhất quán thật giữa 2 bảng, cân nhắc thống nhất khi rà soát GSDC
  }

  exceptions = {}
  with open('system/rules/rule_physical_name_exceptions_datamart.csv', encoding='utf-8-sig') as f:
      reader = csv.reader(f)
      next(reader)
      for row in reader:
          if len(row) >= 2:
              exceptions[row[0].strip().lower()] = row[1].strip().lower()

  def expected_physical(logical_name):
      words = re.findall(r\"[A-Za-z0-9']+\", logical_name)  # tách cả từ ghép có gạch ngang (Non-Financial -> Non, Financial)
      tokens = [exceptions.get(w.lower(), w.lower()) for w in words]
      return '_'.join(tokens)

  with open('Datamart/lld/datamart_attributes.csv', encoding='utf-8-sig') as f:
      rows = list(csv.reader(f))
  header = rows[0]
  ent_idx, tbl_idx = header.index('datamart_entity'), header.index('datamart_table')

  pairs = set((r[ent_idx], r[tbl_idx]) for r in rows[1:])
  fails = []
  for ent, tbl in sorted(pairs):
      if tbl in KNOWN_EXCEPTIONS:
          continue
      exp = expected_physical(ent)
      if exp != tbl:
          fails.append((ent, tbl, exp))

  print(f'Tổng entity: {len(pairs)} | Mismatch: {len(fails)}')
  for ent, tbl, exp in fails:
      print(f'  ❌ {ent!r} actual={tbl!r} expected={exp!r}')
  "
  ```
- **Lưu ý xử lý kết quả — không phải mọi mismatch đều là lỗi:**
  - Nếu `actual` là viết tắt tùy tiện không có trong exceptions (VD: `prac`, `sc`, `pc`, `pblc_co`) → **lỗi thật**, phải sửa theo Kịch bản C.
  - Nếu `actual` giữ full word dù từ đó CÓ trong exceptions (VD: `history` thay vì `hist` dù "History" có exception) → **lỗi thật khác chiều** (thiếu áp dụng exception có sẵn), cũng phải sửa.
  - Nếu mismatch chỉ do thuật toán tách từ ghép ngây thơ (VD: "Non-Financial" tách thành `non_financial` nhưng bảng dùng liền `nonfinancial`) → kiểm tra xem cách viết liền có nhất quán ở nơi khác cùng module không; nếu có tiền lệ nhất quán → thêm vào `KNOWN_EXCEPTIONS`, không phải lỗi.
  - Nếu là bảng conformed/shared có vẻ theo "quy ước riêng" → **KHÔNG tự kết luận là hợp lệ**. Bắt buộc tìm bằng chứng cụ thể (exceptions CSV, tài liệu quyết định) trước khi thêm vào `KNOWN_EXCEPTIONS` — không suy diễn quy ước không có căn cứ. Nếu không tìm được bằng chứng → mismatch là lỗi thật, sửa theo Kịch bản C.
- Báo: `✅ TC6 PASS: N entity, 0 mismatch` hoặc `❌ TC6 FAIL: [danh sách entity | actual | expected]` — với mỗi FAIL, phân loại rõ là lỗi thật hay cần thêm KNOWN_EXCEPTIONS trước khi kết luận.
- Nếu là lỗi thật → sửa theo Kịch bản C (mục "Khi review/detect lỗi" trong [`physical_naming.md`](physical_naming.md)) → chạy lại TC6 trên toàn bộ master → báo kết quả.
- **Áp dụng cho cả `datamart_column`** (không chỉ `datamart_table`): với mỗi `datamart_attribute` (logical) trong cùng 1 `datamart_entity`, tính expected tương tự và so với `datamart_column` thực tế.

**TC7 — Tên bảng/cột đồng nhất xuyên suốt các nguồn output (bắt buộc dùng Bash tool):**

- Mục đích: TC6 chỉ kiểm tra 1 file (`datamart_attributes.csv`) có tự nhất quán với chính nó không. TC7 kiểm tra **giữa các nguồn khác nhau** có cùng dùng 1 tên hay không — bài học NHNCK 2026-07-16: `datamart_model.yaml` và `datamart_attributes.csv` tồn tại song song 2 tên khác nhau cho cùng 13 entity (`scr_prac` vs `securities_practitioner`) trong nhiều tháng mà không ai phát hiện, vì mỗi file được review độc lập.
- **Phạm vi tự động hóa — chỉ 4 nguồn có cấu trúc trường rõ ràng, đối chiếu tất định (không đoán):**
  1. `datamart_attributes.csv` (master) — **anchor set**, nguồn sự thật duy nhất
  2. `Datamart/lld/{MODULE}/DTM_{MODULE}_*.csv` (Attributes detail) — cùng cấu trúc cột, so trực tiếp
  3. `Datamart/datamart_model.yaml` — so `logical_name`↔`datamart_table` (entity), `columns[].logical_name`↔`columns[].physical_name` (cột)
  4. `Datamart/lld/DTM_{MODULE}_Detail_Mapping.csv` — `mart_table`/`mart_column` (logical) phải resolve đúng `datamart_table`/`datamart_column` (physical) trong anchor, và cột `logic` phải chứa đúng chuỗi `<physical_table>.<physical_column>` tương ứng
  5. `Datamart/hld/DTM_{MODULE}_Entities.csv` — `datamart_entity` (logical) phải tồn tại trong anchor set
- **KHÔNG tự động hóa cho `HLD.md`** — free-text + mermaid, regex bắt token dễ false positive (node ID, alias biến, tên Atomic lẫn trong công thức). Khi TC7 FAIL ở bất kỳ nguồn nào trong 5 nguồn trên, bước sửa lỗi (Kịch bản C) đã yêu cầu `grep -rn "tên_cũ" Datamart/` — lệnh này tự nhiên quét luôn HLD.md, nên HLD vẫn được rà soát nhưng qua cơ chế sửa lỗi thủ công, không qua TC7 tự động.
- Chạy script (xây anchor set 1 lần, đối chiếu cả 4 nguồn còn lại):
  ```bash
  python .claude/skills/datamart-review/scripts/lld_selfcheck.py --module {MODULE} --tc 7
  ```
  Dán nguyên output vào báo cáo. Script tách **lỗi cứng** (`entity_not_found`, `column_not_found`,
  lệch tên giữa module file / model / Entities.csv) khỏi **cảnh báo** (`logic_missing_ref`).

- **Sub-check E — NỘI DUNG `etl_logic`/`description` khớp giữa master và module file (bắt buộc, không chỉ tên bảng/cột):**
  - **Mục đích:** 4 script trên (entity_map/column_map) chỉ so khớp **tên vật lý** (`datamart_table`, `datamart_column`) — hoàn toàn KHÔNG so nội dung `etl_logic`. Một bug fix sửa **logic JOIN/filter** (không đổi tên bảng/cột nào) tại `Datamart/lld/{MODULE}/DTM_{MODULE}_*.csv` sẽ **PASS** Sub-check A-D dù `datamart_attributes.csv` (anchor) vẫn giữ nguyên logic SAI/CŨ — che giấu hoàn toàn tình trạng lệch.
  - **Bài học thực tế (module GSTT, 2026-09-11):** Qua `datamart-review` phát hiện + sửa 2 bug join-key (HNX/UPCOM/FDS phải join `securities_trade` qua `isin_code` thay vì `symbol`; filter "thỏa thuận" thiếu `market_id_code`) trực tiếp vào `Datamart/lld/GSTT/DTM_GSTT_fct_stock_portfolio_snpst.csv` và `..._fct_foreign_trading_min_snpst.csv` — sửa đúng, chạy TC5 (cấu trúc CSV) PASS, báo cáo hoàn tất. **Nhưng quên đồng bộ `datamart_attributes.csv`** — file master vẫn giữ y nguyên 2 bug đó suốt nhiều lượt hội thoại sau, chỉ bị phát hiện khi user chủ động hỏi lại "flat table không sửa gì à" và Data Modeler tự rà soát chéo. TC7 (bản cũ, chỉ Sub-check A-D) đã chạy nhưng **không hề bắt được** vì tên bảng/cột không đổi — chỉ nội dung `etl_logic` khác.
  - **Quy tắc:** Với mọi `(datamart_entity, datamart_attribute)` unique xuất hiện ở CẢ `datamart_attributes.csv` (anchor) VÀ file Attributes detail module — `etl_logic` (và nên kèm `description`) của 2 bên PHẢI **giống hệt ký tự** (byte-for-byte sau khi trim whitespace 2 đầu). Khác nhau dù chỉ 1 điều kiện `AND` là FAIL, không có khái niệm "khác nhỏ chấp nhận được".
  - Chạy script (mở rộng Nguồn 2 ở script TC7 chính — thêm so sánh `etl_logic`):
    ```bash
    python -c "
    import csv, glob, sys
    sys.stdout.reconfigure(encoding='utf-8')
    with open('Datamart/lld/datamart_attributes.csv', encoding='utf-8-sig') as f:
        rows = list(csv.reader(f)); header = rows[0]; idx = {h:i for i,h in enumerate(header)}
    etl_map = {(r[idx['datamart_entity']], r[idx['datamart_attribute']]): r[idx['etl_logic']].strip() for r in rows[1:]}
    fails = []
    for fp in glob.glob('Datamart/lld/{MODULE}/DTM_{MODULE}_*.csv'):
        with open(fp, encoding='utf-8-sig') as f:
            rows2 = list(csv.reader(f)); h2 = rows2[0]; i2 = {h:i for i,h in enumerate(h2)}
        for r in rows2[1:]:
            key = (r[i2['datamart_entity']], r[i2['datamart_attribute']])
            mod_logic = r[i2['etl_logic']].strip()
            if key in etl_map and etl_map[key] != mod_logic:
                fails.append((fp, key, 'MASTER_STALE_OR_MODULE_STALE'))
    print(f'Tổng lệch etl_logic: {len(fails)}')
    for f_ in fails: print(' ', f_)
    "
    ```
  - Nếu FAIL → file per-module là nguồn sự thật: sửa file per-module nếu chính nó đang sai, rồi sinh lại master bằng `build_registry.py --check` → ghi thật. KHÔNG chép chuỗi `etl_logic` vào master bằng tay. `build_registry.py --check` cũng báo đúng loại lệch này ("Bảng có dòng mới/đổi ở per-module chưa lên master").
  - **BẮT BUỘC chạy Sub-check E này ngay sau MỌI lần Edit vào 1 file Attributes detail đã tồn tại — không phân biệt lý do sửa (bug fix qua `datamart-review`, sửa trực tiếp giữa hội thoại theo yêu cầu tức thời của user, đổi tên theo Kịch bản C, hay bất kỳ Edit nào khác) và không phân biệt file đó được sinh mới hay đã có từ trước.** Đây là quy tắc riêng, không phụ thuộc "đang ở Phase 1 sinh file mới" — khác với TC1-TC6/TC8/TC9 vốn chủ yếu áp dụng khi *sinh file mới*.
- Báo: `✅ TC7 PASS: 0 issue giữa 5 nguồn (bao gồm Sub-check E — etl_logic khớp)` hoặc `❌ TC7 FAIL: [danh sách issue theo nguồn]` — phân loại rõ nguồn nào lệch, giá trị nào đúng (anchor = `datamart_attributes.csv` sinh từ file per-module; anchor lệch nghĩa là master chưa được sinh lại — xem Sub-check E).
- Nếu FAIL → xác định nguồn đang sai (không mặc định anchor luôn đúng nếu vừa phát hiện qua Sub-check E rằng module file mới sửa còn anchor thì chưa) → sửa theo Kịch bản C → **đồng thời `grep -rn "tên_cũ" Datamart/hld/DTM_{MODULE}_HLD.md` để rà soát HLD thủ công** (không tự động qua TC7) → chạy lại TC7 (đủ cả Sub-check A-E) → báo kết quả.

**TC8 — Tiền tố/hậu tố `datamart_table` khớp `table_type` (bắt buộc dùng Bash tool):**

- Mục đích: TC6 chỉ kiểm tra physical name có đúng thuật toán tách-từ + exceptions của **logical name** không (VD "Practitioner" → `prac`) — không kiểm tra bảng có đúng **tiền tố/hậu tố theo loại bảng** hay không. Bài học thực tế (module QLKD, 2026-07-24): entity `Market Index Snapshot` là Fact (`table_type: "fact"`, có FK Dimension, measure, đúng grain Fact Snapshot) nhưng được đặt tên `market_index_snpst` — thiếu hẳn tiền tố `fct_`, khác biệt với 4/5 Fact khác cùng module QLKD đều có `fct_`. TC6 không bắt được lỗi này vì thuật toán tách-từ của TC6 chỉ áp dụng cho phần logical name sau tiền tố (TC6 coi "Fact" là 1 token thường không có trong `datamart_entity` gốc nếu người thiết kế quên thêm), lỗi lọt qua nhiều vòng review cho tới khi so sánh chéo với 1 Fact khác cùng nguồn Atomic ở module NDTNN mới lộ ra.
- Quy tắc tiền tố/hậu tố chuẩn theo `table_type` (tra từ `datamart_model.yaml` thực tế, không suy đoán):
  - `table_type: "fact"` → `datamart_table` PHẢI bắt đầu bằng tiền tố `fct_`.
  - `table_type: "operational"` → `datamart_table` PHẢI bắt đầu bằng tiền tố `opr_`.
  - `table_type: "dim"` → `datamart_table` PHẢI kết thúc bằng hậu tố `_dim` (ngoại lệ: `cdr_dt_dim` và `cl_dim` vẫn theo đúng hậu tố này, không phải ngoại lệ thật).
  - Không áp dụng cho bảng Classification Value dùng chung (`cl_dim`) nếu đã có exception ghi nhận riêng — nhưng mặc định coi là lỗi thật cho tới khi tìm được bằng chứng ngoại lệ cụ thể (cùng nguyên tắc thận trọng như TC6).
  - **Ngoại lệ — nhóm Fact dạng "report" (quyết định 2026-07-24, module NDTNN `foreign_investor_trading_statistics_rpt`/`foreign_investor_trading_detail_rpt`):** Fact phục vụ báo cáo đóng gói cố định theo kỳ (ETL append-only theo Report Date, không SCD4A, thường denormalize hoàn toàn không FK Dimension) dùng **hậu tố `_rpt`** làm dấu hiệu nhận diện thay cho tiền tố `fct_` — bảng loại này KHÔNG cần (và không nên) có cả tiền tố `fct_` lẫn hậu tố `_rpt` cùng lúc, chỉ `_rpt` là đủ. Áp dụng đồng thời cho `logical_name` — cũng KHÔNG mang tiền tố "Fact" (VD: `"Foreign Investor Trading Statistics Report"`, không phải `"Fact Foreign Investor Trading Statistics Report"`), dù `table_type` đăng ký là `"fact"`. Tiêu chí phân biệt Fact vs Operational khi quyết định table_type: **Fact = append theo thời gian** (mỗi lần ETL chạy thêm dòng cho kỳ mới, không update dòng cũ); **Operational = SCD4A** (giữ current-state, ETL update/replace theo latest) — không dùng "có denormalize hay không" làm tiêu chí phân loại table_type (denormalize là thuộc tính độc lập, áp dụng được cho cả Fact lẫn Operational).
- Chạy script sau **trên toàn bộ `datamart_model.yaml`** (không chỉ entity vừa thiết kế — vì đây là lỗi loại "thiếu nhất quán với quy ước module", chỉ lộ ra khi so sánh chéo với các entity cùng `table_type` khác, giống cách TC7 phải quét toàn bộ thay vì chỉ file đang sửa):
  ```bash
  python -c "
  import re, sys
  sys.stdout.reconfigure(encoding='utf-8')

  with open('Datamart/datamart_model.yaml', encoding='utf-8') as f:
      content = f.read()

  blocks = re.split(r'\n  - id: ', content)
  fails = []
  for b in blocks[1:]:
      tbl_m = re.search(r'datamart_table: \"([^\"]+)\"', b)
      tt_m = re.search(r'table_type: \"([^\"]+)\"', b)
      logical_m = re.search(r'logical_name: \"([^\"]+)\"', b)
      if not (tbl_m and tt_m):
          continue
      table, ttype, logical = tbl_m.group(1), tt_m.group(1), logical_m.group(1) if logical_m else '?'
      is_report = table.endswith('_rpt')
      if ttype == 'fact' and is_report:
          # Nhóm Fact-report: bắt buộc _rpt, cấm cả tiền tố fct_ lẫn logical_name có tiền tố \"Fact\"
          if table.startswith('fct_'):
              fails.append((logical, table, ttype, 'Fact-report không được có cả tiền tố fct_ lẫn hậu tố _rpt — chỉ giữ _rpt'))
          if logical.startswith('Fact '):
              fails.append((logical, table, ttype, 'Fact-report — logical_name không được mang tiền tố \"Fact\"'))
      elif ttype == 'fact' and not table.startswith('fct_'):
          fails.append((logical, table, ttype, 'thiếu tiền tố fct_'))
      elif ttype == 'operational' and not table.startswith('opr_'):
          fails.append((logical, table, ttype, 'thiếu tiền tố opr_'))
      elif ttype == 'dim' and not table.endswith('_dim'):
          fails.append((logical, table, ttype, 'thiếu hậu tố _dim'))

  print(f'Tổng lỗi: {len(fails)}')
  for logical, table, ttype, reason in fails:
      print(f'  ❌ {logical!r} | datamart_table={table!r} | table_type={ttype!r} | {reason}')
  "
  ```
- Báo: `✅ TC8 PASS: 0 mismatch tiền tố/hậu tố` hoặc `❌ TC8 FAIL: [danh sách logical_name | datamart_table | table_type | lý do]`.
- Nếu FAIL → đổi tên theo Kịch bản C (sửa file Attributes detail, Detail Mapping, SQL Phase 3, HLD.md, `datamart_model.yaml`; sinh lại master `datamart_attributes.csv` bằng `build_registry.py` — dùng `grep -rn "tên_cũ" Datamart/` để tìm hết vị trí cần sửa) → chạy lại TC8 → báo kết quả.
- **Lưu ý:** nếu entity dùng chung nhiều module (`modules_using` có >1 giá trị), việc đổi tên ảnh hưởng tới mọi module đang reuse — phải rà cả Detail Mapping và HLD của các module khác trong `modules_using`, không chỉ module đang thiết kế.

**TC9 — `description` không lẫn KPI_ID/chi tiết ETL (bắt buộc dùng Bash tool):**

- Mục đích: `description` chỉ mô tả ý nghĩa nghiệp vụ thuần của cột — không phải chỗ chứa KPI_ID hay chi tiết vận hành ETL (những thứ này thuộc `etl_logic`, hoặc thuộc HLD/Detail Mapping). Bài học thực tế: lỗi này lọt qua review 2 lần trước khi bị TC hóa — module GSDC (2026-07-22, description dạng `"K_GSDC_702 (...) — dùng để COUNT(*) WHERE ... GROUP BY ..."`, 44+48 dòng phải sửa lại) và module GSTT (2026-07-28, Nhóm 1 `fct_stock_portfolio_snpst`, description dạng `"K_GSTT_13 — Tổng KL. Pre-aggregate GROUP BY Symbol/Trade Date, broadcast trên mọi row Index Constituent..."`) — cả 2 lần đều do human tự đọc file và phát hiện lại, không có TC nào tự động bắt trước khi trình bày.
- Quy tắc: cột `description` không được chứa:
  1. **KPI_ID** — pattern `K_[A-Z0-9]+_\d+` (VD: `K_GSTT_13`, `K_GSDC_702`).
  2. **Từ khóa ETL/vận hành** — `GROUP BY`, `pre-aggregate`, `broadcast`, `JOIN`, `WHERE`, `driving table` (không phân biệt hoa/thường).
  - **Ngoại lệ duy nhất:** dòng `key = PK` được phép giữ cụm ngắn gọn `"PK — Driving: {table}"` (yêu cầu tường minh của Bước 1 — ghi rõ Driving Table trong description của PK/BK) — nhưng không được kèm thêm giải thích SCD/grain/logic dài dòng phía sau trong cùng ô. Dòng `key = BK` không có ngoại lệ này — description của BK chỉ mô tả ý nghĩa khóa nghiệp vụ, không nhắc driving table hay KPI dùng nó.
- Chạy script sau trên **từng file vừa sinh** (không cần quét toàn master — đây là lỗi cục bộ theo file, khác TC6/TC7/TC8 vốn cần đối chiếu chéo):
  ```bash
  python -c "
  import csv, re, sys
  sys.stdout.reconfigure(encoding='utf-8')

  files = ['<path_file_1>', '<path_file_2>', ...]  # danh sách file vừa sinh trong batch này

  kpi_pattern = re.compile(r'K_[A-Z0-9]+_\d+')
  etl_pattern = re.compile(r'GROUP BY|pre-aggregate|broadcast|JOIN|WHERE|driving table', re.IGNORECASE)

  fails = []
  for fp in files:
      with open(fp, encoding='utf-8-sig') as f:
          rows = list(csv.DictReader(f))
      for r in rows:
          desc = r['description']
          key = r['key']
          if kpi_pattern.search(desc):
              fails.append((fp, r['datamart_attribute'], 'chứa KPI_ID', desc))
              continue
          # Ngoại lệ: dòng PK được phép có 'PK — Driving: X' — bỏ qua phần này rồi mới check ETL keyword
          check_str = desc
          if key == 'PK' and check_str.startswith('PK — Driving:'):
              check_str = check_str.split('.', 1)[-1] if '.' in check_str else ''
          if etl_pattern.search(check_str):
              fails.append((fp, r['datamart_attribute'], 'chứa từ khóa ETL', desc))

  print(f'Tổng lỗi: {len(fails)}')
  for fp, attr, reason, desc in fails:
      print(f'  ❌ {fp} | {attr} | {reason} | description={desc!r}')
  "
  ```
- Báo: `✅ TC9 PASS: 0 description vi phạm` hoặc `❌ TC9 FAIL: [danh sách file | attribute | lý do | description hiện tại]`.
- Nếu FAIL → rút gọn `description` chỉ còn phần mô tả nghiệp vụ thuần (bỏ KPI_ID, bỏ toàn bộ vế sau chứa logic ETL) → chạy lại TC9 → báo kết quả.

**TC10 — Đầy đủ trường kỹ thuật SCD4A trên Dimension / Operational (bắt buộc dùng Bash tool):**
- Mục đích: Đảm bảo mọi bảng Dimension và Operational tuân thủ chuẩn SCD4A của Lakehouse Datamart, có đủ các trường kỹ thuật mặc định (`ds_rcrd_st`, `ds_rcrd_isrt_dt`, `ds_rcrd_udt_dt`, `ds_etl_pcs_tms`), và bảng History companion có thêm `ds_snpst_dt`.
- Chạy script kiểm tra file vừa sinh nếu là Dimension hoặc Operational:
  ```bash
  python -c "
  import csv, sys
  sys.stdout.reconfigure(encoding='utf-8')
  REQUIRED_ACTIVE = {'ds_rcrd_st', 'ds_rcrd_isrt_dt', 'ds_rcrd_udt_dt', 'ds_etl_pcs_tms'}
  fp = '{FILE_PATH}'
  with open(fp, 'r', encoding='utf-8-sig') as f:
      reader = csv.DictReader(f)
      cols = {row['datamart_column'].strip() for row in reader}
  missing = REQUIRED_ACTIVE - cols
  if missing:
      print(f'❌ TC10 FAIL: {fp} thiếu trường kỹ thuật SCD4A: {sorted(list(missing))}')
  else:
      print(f'✅ TC10 PASS: {fp} đầy đủ trường kỹ thuật SCD4A')
  "
  ```
- Báo: `✅ TC10 PASS: Đầy đủ trường kỹ thuật SCD4A` hoặc `❌ TC10 FAIL: [tên bảng/file] thiếu trường kỹ thuật SCD4A: [danh sách trường thiếu]`.
- Nếu FAIL → bổ sung các trường kỹ thuật mặc định theo bảng chuẩn trong `reference/phase1_attributes.md`.

**TC11 — Lọc `ds_rcrd_st = 'ACTIVE'` khi JOIN bảng Atomic SCD4A (bắt buộc dùng Bash tool):**
- Mục đích: Ngăn chặn lỗi lẫn bản ghi INACTIVE hoặc fanout nhân đôi dữ liệu khi JOIN sang bảng Atomic Fundamental (SCD4A).
- Kiểm tra file vừa sinh: mọi dòng có `etl_logic` chứa `JOIN` vào bảng Atomic Fundamental (SCD4A) phải có điều kiện lọc bản ghi active (`AND <atomic_table>.ds_rcrd_st = 'ACTIVE'`). Nếu JOIN bảng History (`_hstr`): phải có `ds_snpst_dt` và `ds_rcrd_st = 'ACTIVE'`.
- Chạy script kiểm tra:
  ```bash
  python -c "
  import csv, sys, re
  sys.stdout.reconfigure(encoding='utf-8')
  fp = '{FILE_PATH}'
  fails = []
  with open(fp, 'r', encoding='utf-8-sig') as f:
      for idx, row in enumerate(csv.DictReader(f), 1):
          logic = row.get('etl_logic', '')
          # Kiểm tra nếu JOIN bảng atomic mà thiếu ds_rcrd_st
          joins = re.findall(r'JOIN\s+([a-zA-Z0-9_]+)\s+ON\s+([^→\n]+)', logic, re.IGNORECASE)
          for tbl, on_cond in joins:
              if tbl not in ('cv', 'cdr_dt_dim') and not tbl.endswith('_dim'):
                  if 'ds_rcrd_st' not in on_cond and not tbl.endswith('_flat'):
                      fails.append((row['datamart_column'], tbl, on_cond))
  if fails:
      print(f'❌ TC11 FAIL: Có {len(fails)} biểu thức JOIN bảng Atomic thiếu ds_rcrd_st = \'ACTIVE\'')
      for col, tbl, cond in fails:
          print(f'   - Cột {col}: JOIN {tbl} ON {cond.strip()}')
  else:
      print('✅ TC11 PASS: Lọc SCD4A đầy đủ trên các mệnh đề JOIN')
  "
  ```
- Báo: `✅ TC11 PASS: Lọc SCD4A đầy đủ` hoặc `❌ TC11 FAIL: [danh sách cột/biểu thức thiếu filter ds_rcrd_st='ACTIVE']`.

**TC12 — Giới hạn ngày bảng Atomic snapshot/event (A19, bắt buộc dùng Bash tool):**
- Mục đích: không để `etl_logic` đọc `securities_trade`/`securities_order`/`*_snapshot`/History trên toàn lịch sử (bài học GSTT 2026-10-14: 55 cell / 8 bảng).
- Áp dụng cho file có `atomic_table` hoặc `etl_logic` chứa bảng Atomic snapshot/event/History. File chỉ đọc Fundamental/Relative: ghi `⏭ TC12 N/A`.
- Chạy:
  ```bash
  python .claude/skills/datamart-review/scripts/check_date_bound.py --module {MODULE} --file {mart_table}
  ```
- Đọc từng phát hiện, phân loại: sửa (R1 thiếu khóa ngày ở dòng lookup_date; R3 subquery chưa khóa ngày bên trong; R4 "mới nhất" toàn lịch sử; R6 LAG liên ngày trên bảng khóa 1 ngày)
  / báo thừa (đã chặn gián tiếp, ghi lý do) / ngoại lệ có truy vết (`[DATE-BOUND-REVIEWED ...]` + Open Issue).
- Báo: `✅ TC12 PASS: 0 phát hiện` hoặc `❌ TC12 FAIL: [file/cột/mã R1–R6]`. Không được báo PASS khi còn phát hiện chưa phân loại.

> **Quy tắc SELF-REVIEW:** Chỉ trình bày file cho human sau khi cả 12 TC (TC1, TC2, TC2b, TC3 gồm cả TC3b, TC4, TC5, TC6, TC7, TC8, TC9, TC10, TC11, TC12) đều PASS. Nếu có TC FAIL → sửa → chạy lại TC đó → báo kết quả cuối cùng kèm tóm tắt "Đã sửa X lỗi" trước khi trình bày file.
