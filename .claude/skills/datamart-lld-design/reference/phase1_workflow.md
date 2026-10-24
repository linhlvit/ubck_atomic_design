# Phase 1 — Quy trình Attributes CSV — LLD Datamart

Các bước Phase 1 cho từng Nhóm và Checklist Phase 1. Đọc cùng `phase1_attributes.md` (15 cột, `etl_logic_type`, key), `physical_naming.md` (đặt tên physical) và `phase1_selfreview.md` (TC1–TC14, chạy trước khi trình bày từng file).

## Mục lục

- PHASE 1 — ATTRIBUTES CSV
  - Bước 1 — Xác định Driving Table
  - Bước 1a — Phạm vi cột Dimension (coverage rule — bắt buộc, thiết kế lần đầu VÀ khi partial)
  - Bước 1b — Bổ sung `src_stm_code` cho Dimension và Operational
  - Bước 2 — Tra entity YAML files
  - Bước 3 — Xuất CSV
  - Checklist Phase 1
  - PRE-CHECK
  - OUTPUT CHECK
  - ATTRIBUTES CHECK

## PHASE 1 — ATTRIBUTES CSV

Đọc [`reference/phase1_attributes.md`](phase1_attributes.md) đầy đủ trước khi bắt đầu.

**Input Phase 1:**
- `Datamart/hld/DTM_{MODULE}_Entities.csv` — danh sách entity, table_type, reuse_status, source_table đã duyệt
- `Datamart/lld/datamart_attributes.csv` — master hiện tại (cần cho partial flow)
- `BRD/BA/BA_analyst_{MODULE}.csv` — **đọc qua lát cắt, KHÔNG Read thẳng file**:
  `python .claude/skills/datamart-review/scripts/ba_slice.py --module {MODULE} --nhom {N} --print`
  (file gốc tới 998K token; lát cắt giữ nguyên văn mọi ô nghiệp vụ của Nhóm đó).
  Đối chiếu yêu cầu nghiệp vụ (CHỈ lấy dòng có `Trạng thái mapping ∈ {Done, Doing, Pending}`; **TUYỆT ĐỐI LOẠI BỎ** chỉ tiêu có `Trạng thái mapping = Delete / DELETED / Xóa`, cấm sinh thuộc tính/cột cho chỉ tiêu Delete)

**Bước 0 — Đọc reuse_status từ Entities.csv:**
- `reuse` → bỏ qua hoàn toàn, không sinh file, ghi note: "Bảng [datamart_table] reuse từ master — không thiết kế mới"
- `new` → thiết kế đầy đủ, sinh file
- `partial` → đọc `Datamart/datamart_model.yaml` (entry có `id = DTM-{datamart_table}`), lấy `columns` hiện có làm baseline + xác định `module` sở hữu gốc → so sánh delta → **báo cáo human, DỪNG chờ approve** trước khi sinh file
  > ❌ **KHÔNG được sinh file partial** khi chưa có xác nhận của human về delta.
  > ❌ **KHÔNG tạo file `_delta.csv` hay bất kỳ file Attributes nào trong thư mục module đang thiết kế** (`Datamart/lld/{MODULE}/`) khi bảng thuộc sở hữu module khác — cột mới phải sửa TRỰC TIẾP vào file gốc `Datamart/lld/{MODULE_SỞ_HỮU}/DTM_{MODULE_SỞ_HỮU}_{datamart_table}_....csv`. Xem chi tiết [`reference/phase1_attributes.md`](phase1_attributes.md) mục "Quy trình partial".

**Bước 0b — Trình bày danh sách file sẽ sinh cho nhóm N (GATE — chờ human xác nhận trước khi sinh):**

Trước khi trình bày: với bảng `partial` → đọc `Datamart/datamart_model.yaml` lấy `datamart_table` physical name đã ghi (không đặt lại tên). Sau khi xác định driving table và `src_stm_code` cho từng bảng `new`/`partial` của nhóm N, trình bày bảng tóm tắt:

```
Nhóm [N] — [Tên nhóm]: danh sách file sẽ sinh

| STT | Tên file | table_type | Driving Table | src_stm_code |
|-----|----------|------------|---------------|--------------|
| 1   | DTM_NHNCK_scr_prac_conduct_vln_NHNCK_VIOLATIONS.csv | dim | scr_prac_conduct_vln | NHNCK_VIOLATIONS |
| 2   | DTM_NHNCK_fct_prac_exam_rslt.csv | fact | — | — |
| 3   | ... | ... | ... | ... |

Bảng reuse/bỏ qua nhóm này: [danh sách tên bảng + lý do]

→ Xác nhận để tiến hành sinh file nhóm [N]?
```

> **GATE — bắt buộc dừng:** Chờ human xác nhận danh sách của nhóm trước khi điền 15 cột bất kỳ file nào.
> ❌ **KHÔNG được bắt đầu điền nội dung file** khi chưa có xác nhận của human. Nếu driving table hoặc src_stm_code sai → sửa, trình bày lại bảng, chờ xác nhận lại.

Xem quy trình chi tiết trong [`reference/phase1_attributes.md`](phase1_attributes.md).

### Bước 1 — Xác định Driving Table

Bắt buộc xác định Driving Table trước khi điền `etl_logic`:

| Loại bảng | Driving Table |
|---|---|
| Fact Event / Snapshot | Atomic entity có grain tương đương |
| Tác nghiệp | Atomic entity của đối tượng chính |
| Dimension | Atomic entity tương ứng |

Ghi rõ Driving Table trong `description` của row PK/BK.

**Giới hạn ngày của Driving Table (A19 — bắt buộc khi Driving là Fact Snapshot / Fact Append):** dòng `lookup_date`
(`snpst_dt_dim_id` / `<role>_dt_dim_id`) phải mang điều kiện `<driving>.<cột ngày> = :etl_date`; mọi bảng Atomic snapshot/event khác
trong cùng bảng Datamart phải nối ngày vào Driving hoặc tự khóa ngày; subquery khóa ngày bên trong; cấm "bản ghi mới nhất" trên toàn lịch sử.
Quyết định giới hạn ngày ngay ở bước này (không để Phase 3 / flat SQL "gánh" — flat chỉ lọc Gold, không cứu được Atomic→Gold).

**Driving Table khi Fact không có join key chung (No Driving Table):**
Fact dùng pattern CROSS JOIN scalar subquery (mỗi measure aggregate độc lập từ 1 Atomic table) — không có driving table. Không thêm `src_stm_code` cho loại bảng này.

### Bước 1a — Phạm vi cột Dimension (coverage rule — bắt buộc, thiết kế lần đầu VÀ khi partial)

> **Bài học (module NDTNN, 2026-07-24):** `Public Company Dimension` (dùng chung GSDC/QLCB/NDTNN) ban đầu chỉ chọn 8 cột đủ dùng cho KPI đang thiết kế lúc đó. Sau đó phải quay lại bổ sung 2 lần (7 cột rồi 11 cột) khi rà soát lại entity Atomic gốc — vì cách chọn "đủ dùng cho KPI hiện tại" bỏ sót nhiều attribute mô tả tĩnh có giá trị dùng chung lâu dài cho các module sau. Với Dimension dùng chung nhiều module, thiếu 1 cột không chỉ vá lại 1 lần — mỗi module mới cần thêm lại phải sửa `datamart_attributes.csv` + `datamart_model.yaml` + mọi Detail Mapping đã tham chiếu, tốn công hơn nhiều so với thiết kế đủ ngay từ đầu.

**Quy tắc:** Khi thiết kế Dimension mới (`new`) hoặc mở rộng Dimension đã có (`partial`), đọc **toàn bộ** danh sách attribute của Atomic entity driving table (không dừng ở tập cột cần cho KPI hiện tại) và áp dụng bộ lọc theo **SCD-nature** — bản chất thay đổi chậm/nhanh của chính attribute đó trên Atomic:

| Loại attribute Atomic | Đưa vào Dimension? | Ví dụ |
|---|---|---|
| Đặc điểm/hồ sơ mô tả thực thể (tên, mã, loại hình, ngày đăng ký, tỉnh/thành, cờ cấu trúc sở hữu...) | ✅ Có — kéo dư thừa toàn bộ, kể cả khi KPI hiện tại chưa dùng | `pc_nm`, `enterprise_tp_code`, `head_office_province_nm`, `has_parent_company_indicator` |
| Khóa/liên kết kỹ thuật thuần (PK/FK surrogate nội bộ Atomic không mang ý nghĩa nghiệp vụ độc lập) | ❌ Không | id kỹ thuật không có business meaning riêng |
| Audit/vận hành thuần (created_by, file_name, upload timestamp, ghi chú xử lý nội bộ) | ❌ Không | `attachment_file_nm`, `specialist_note`, `company_login_username` |
| Gắn với 1 giao dịch/sự kiện cụ thể, đổi theo phiên/ngày (giá, khối lượng, số dư, trạng thái tại 1 thời điểm snapshot) | ❌ Không — thuộc về Fact/Snapshot, không phải Dimension | giá khớp lệnh, khối lượng giao dịch, số dư tài khoản theo ngày |

❌ Không áp dụng ngược lại cho Fact — Fact vẫn giữ nguyên rule "chỉ giữ cột trace được về KPI" (xem CLAUDE.md `feedback_fact_no_etl_filter_columns`). Coverage rule này CHỈ áp dụng cho Dimension.

**Khi partial (Dimension đã tồn tại từ module khác):** Trước khi chỉ thêm đúng 1-2 cột module hiện tại cần, chủ động rà lại **toàn bộ** attribute còn lại của Atomic driving table theo bảng phân loại trên — đề xuất bổ sung 1 lần đầy đủ, tránh để module sau lại phải mở lại cùng bảng.

### Bước 1b — Bổ sung `src_stm_code` cho Dimension và Operational

Mọi bảng `dim` và `operational` **phải có** attribute `src_stm_code` (thêm cuối danh sách attribute của bảng).

**Xác định driving table để lấy `src_stm_code`:** Driving table = bảng chính của grain — bảng có PK/BK trong Attributes, các attribute của nó dùng `etl_logic_type = direct`. Bảng phụ (`etl_logic_type = join_atomic`) **không dùng** để xác định `src_stm_code`.

| Trường hợp | ETL Logic | etl_logic_type |
|---|---|---|
| Driving table single-source | `<driving_table>.src_stm_code WHERE <driving_table>.src_stm_code = '<value>'` | `direct` |
| Driving table multi-source (nhiều nguồn, lấy 1 chính thức) | `<driving_table>.src_stm_code WHERE <driving_table>.src_stm_code = '<value>'` | `direct` |
| Driving table multi-source (nhiều nguồn, lấy nhiều) | `<driving_table>.src_stm_code WHERE <driving_table>.src_stm_code IN ('<val1>','<val2>')` | `direct` |
| Multi-source tách bộ (xem bên dưới) | `<atomic_table>.src_stm_code WHERE <partition_key> = '<value>'` | `direct` hoặc `pending` |

**Quy tắc WHERE filter bắt buộc (forward-compatibility):**
Mọi `src_stm_code` attribute **luôn phải có điều kiện lọc** — kể cả khi Atomic driving table hiện chỉ có 1 nguồn. Lý do: nếu sau này Atomic nhận thêm nguồn mới, Datamart ETL không bị ảnh hưởng mà không cần sửa schema.

1. Single-source: `WHERE <driving_table>.src_stm_code = '<giá_trị>'`
2. Multi-source lấy 1 chính thức: `WHERE <driving_table>.src_stm_code = '<giá_trị_chính_thức>'`
3. Multi-source lấy nhiều: `WHERE <driving_table>.src_stm_code IN ('<val1>','<val2>',...)`
4. Vẫn dùng `etl_logic_type = direct` cho tất cả trường hợp trên

**Xử lý multi-source — Tách bộ (UNION/Partition pattern):**
Áp dụng khi bảng Datamart populate từ **nhiều nguồn độc lập** theo 1 trong 2 trường hợp:

| Trường hợp | Mô tả | Ví dụ |
|---|---|---|
| **A — Partition trên 1 Atomic table** | 1 Atomic table chứa nhiều nhóm data phân biệt qua 1 partition key, mỗi nhóm có `src_stm_code` riêng | `cv` phân biệt theo `scm_code` — mỗi scheme có `src_stm_code` khác nhau |
| **B — UNION nhiều Atomic tables** | Datamart populate từ N Atomic tables độc lập, mỗi table có schema/grain riêng | Bảng tổng hợp từ `insp_case` + `surveil_nfrc_case` + ... |

Cách xử lý tách bộ:
1. **Tách thành N bộ attribute** — 1 bộ per partition value (scheme) hoặc per Atomic table
2. **Mỗi bộ** gồm đầy đủ tất cả attribute của bảng (PK/BK + các cột + `src_stm_code`)
3. **`src_stm_code`** của mỗi bộ map từ Atomic source tương ứng
4. Nếu Atomic source chưa xác định → `etl_logic_type = pending` toàn bộ bộ đó
5. **Tên cột** `datamart_column` align với tên cột Atomic source tương ứng

**Trường hợp đặc biệt — Conformed Classification Dimension (`cl_dim`):**
- Tách theo `scm_code` (scheme) — mỗi scheme = 1 bộ 5 dòng
- Tên cột align với Atomic `cv`: `scm_code`, `cl_code`, `cl_nm`
- Scheme load từ `cv` → `etl_logic = cv.<col> WHERE cv.scm_code = '<SCHEME>'`, `etl_logic_type = direct`
- Scheme ETL-generated (không qua `cv`) → `etl_logic_type = pending` toàn bộ bộ
- **Detail Mapping**: tên logical dùng `Scheme Code=` và `Classification Code=` (không phải `Scheme=` / `Code=`)

Spec row `src_stm_code`:
```
nullable=false | data_domain=Classification Value | data_type=string | key=(trống)
source_entity=<tên Atomic entity của driving table / Atomic table tương ứng bộ>
atomic_table=<driving_table> | source_attribute=Source System Code | atomic_column=src_stm_code
```

### Bước 2 — Tra entity YAML files

Với mỗi attribute cần map:
1. **Bảng `partial`:** đọc `Datamart/datamart_model.yaml` → lấy `columns` hiện có làm baseline — chỉ tra entity YAML Atomic cho delta columns mới
2. **Bảng `new` và delta columns:** Tra `dm_manifest.yaml` → tìm entry theo `physical_name` → đọc file YAML tương ứng trong `DataModel/Atomic/{subfolder}/`
3. Lấy `attribute.physical_name` xác nhận tên `atomic_column`
   - **Cột có ở ≥ 2 bảng Atomic cùng nguồn (A25):** `grep -rn "physical_name: {cột}" DataModel/Atomic` — nếu trùng (`period_*`, `record_tp` ở `fmr_value` / `fmr_submission`…) thì chọn bảng ứng với `FROM`/`JOIN` của SQL BA (`ba_slice.py --module {MODULE} --nhom {N} --with-sql --print`), ghi lý do ở `description`; nghi BA ghi sai bảng → mở O_ issue, không tự chọn bảng tiện hơn.
4. Xác định `etl_logic_type` theo rule trong [`reference/phase1_attributes.md`](phase1_attributes.md)
5. Viết `etl_logic` đúng format

### Bước 3 — Xuất CSV

Header 15 cột:
```
datamart_entity,datamart_table,datamart_attribute,datamart_column,nullable,data_domain,data_type,key,description,etl_logic,etl_logic_type,source_entity,atomic_table,source_attribute,atomic_column
```

Export encoding: **UTF-8 BOM** (`utf-8-sig`).
Mọi giá trị trong `etl_logic` và `description` phải được bao double-quote.

**Tên physical — quy tắc bắt buộc:** Xem [`physical_naming.md`](physical_naming.md) (PHYSICAL NAMING RULE) trước khi đặt tên bất kỳ `datamart_table` hay `datamart_column` nào.


### Checklist Phase 1

```
PRE-CHECK (trước khi sinh):
□ Đọc Entities.csv — liệt kê bảng theo reuse_status (new/partial/reuse)
□ Bảng reuse: ghi note bỏ qua, không sinh file
□ Bảng partial: đọc master, báo cáo delta, chờ human approve trước khi sinh
□ Xác định driving table + src_stm_code cho từng bảng new/partial (tra manifest → entity YAML → classification_context)
□ Đối chiếu bảng "Physical name chuẩn" từ Phase 0 Bước P2b — mọi entity dùng chung ≥2 bảng phải dùng đúng token đã duyệt
□ Trình bày bảng tóm tắt: tên file | table_type | Driving Table | src_stm_code → DỪNG chờ human xác nhận trước khi sinh bất kỳ file nào

OUTPUT CHECK:
□ Naming fact: DTM_{MODULE}_{mart_table}.csv (không có src_stm_code)
□ Naming dim/operational: DTM_{MODULE}_{mart_table}_{src_stm_code}.csv
□ src_stm_code: lấy từ classification_context của attribute "Source System Code" trong entity YAML — format "Source System Code = 'VALUE'" → VALUE
□ Thư mục output: Datamart/lld/{MODULE}/ (tạo nếu chưa có)
□ Mọi file partial chứa đầy đủ số cột hiện tại của bảng (không thiếu cột so với schema)
□ Xuất từng file → DỪNG chờ human duyệt từng file riêng lẻ trước khi xuất file tiếp theo
□ Sau khi human approve từng file: sinh lại master bằng `build_registry.py --check` → ghi thật nếu phần lệch chỉ thuộc
  bảng vừa duyệt. KHÔNG append/sửa tay `datamart_attributes.csv` (script tự gộp dòng trùng, giữ dòng multi-source);
  bị chặn vì bảng mồ côi → DỪNG, báo human
□ Cập nhật Datamart/datamart_model.yaml:
    - Entity new: thêm block metadata (id, logical_name, datamart_table, table_type, module, status=draft,
      reuse_status=new, description, source_atomic, modules_using) bằng text, không `yaml.dump` (A9)
    - Khối `columns` (entity new và partial): sinh bằng `build_model_yaml.py --check` → ghi thật, không gõ tay
    - Báo cáo: "Đã cập nhật datamart_model.yaml: [tên entity], [N] cột"
□ ❌ KHÔNG được tự duyệt thay human, KHÔNG được gộp nhiều file vào 1 câu hỏi approve

ATTRIBUTES CHECK:
□ Driving Table ghi rõ trong description của PK/BK — ngắn gọn "PK — Driving: {table}", không kèm giải thích SCD/grain dài dòng
□ description KHÔNG chứa KPI_ID hay từ khóa ETL (GROUP BY/pre-aggregate/broadcast/JOIN/WHERE) — xem TC9
□ Mọi mapping tra từ entity YAML files trong DataModel/Atomic/ — không đoán
□ A25 (TC13): cột Atomic đọc thuộc đúng entity ứng với bảng `FROM`/`JOIN` của SQL BA — cột trùng tên ở ≥ 2 bảng cùng nguồn (`period_*`, `record_tp`…) đã chọn theo BA và ghi lý do
□ A26 (TC13): mọi điều kiện/biểu thức của SQL BA (loại kỳ `PERIOD_TYPE`, loại đối tượng `RECORD_TYPE`/`BRANCH_FLAG`, trạng thái, ngày hiệu lực `ID_DATE`/`START_DATE`, `NULLIF`/`*100`/`COALESCE`/`CASE`) có trong `etl_logic` hoặc ghi lệch ở `description` + O_ issue — bảng Operational/Periodic Snapshot chỉ được thay điều kiện slicer thời gian bằng `:etl_date`
□ A24 (TC14): đổi tên/xóa cột hoặc bảng → đã `grep -rn "<tên cũ>" Datamart/hld Datamart/lld Datamart/flat-table` và sửa Detail Mapping + HLD + yaml + flat trong cùng lượt
□ etl_logic_type điền mọi row — kể cả pending row, trừ PK (BK vẫn phải điền)
□ etl_logic (content) trống chỉ khi key = PK hoặc etl_logic_type = pending — BK KHÔNG được để trống
□ etl_logic có JOIN (join_atomic/lookup_dim/lookup_date): JOIN clause đặt TRƯỚC, cột giá trị SAU dấu → (không được ngược thứ tự)
□ etl_logic: mọi column reference có table_name. prefix
□ etl_logic có dấu phẩy bên trong → đã double-quote trong CSV
□ computed chỉ dùng khi TẤT CẢ input đều từ driving table — nếu dùng bảng khác (kể cả EXISTS, CASE WHEN, aggregate có điều kiện) → đổi thành join_atomic
□ join_atomic: ghi rõ INNER JOIN hay LEFT JOIN
□ Cột từ LEFT JOIN: nullable = true
□ join_atomic: atomic_table khác driving — nếu trùng đổi về direct
□ lookup_dim/lookup_date: source_entity/atomic_table/atomic_column điền join key
□ Pivot: số branch + thứ tự đồng nhất; mọi branch có -- BRANCH_NAME
□ Branch residual (OTHER) flatten hoàn toàn xuống Atomic
□ Operational ≥2 BK: driving = entity con; entity cha lấy direct từ FK trong entity con
□ Mọi Dimension có ≥1 BK (join anchor cho Fact lookup)
□ Mọi Operational dùng trường _code làm PK duy nhất — không tạo surrogate key (_id)
□ Fact có ĐÚNG 1 dòng key = PK (A22), nullable=false, đặt đầu bảng: Dạng A = id dòng Atomic driving (direct) khi grain = 1 dòng nguồn; Dạng B (Fact gộp) = Generated + description liệt kê đủ cột grain
□ Grain trong yaml/Entities/HLD/flat nêu tên cột PK; flat ORDER BY chứa PK
□ Fact TUYỆT ĐỐI KHÔNG có cột cdr_dt_dim_id (Calendar Date Dimension Id) — FK tới Calendar Date Dimension phải đặt theo vai trò nghiệp vụ (Snapshot Date Dimension Id → snpst_dt_dim_id; Fact khác dùng <Role> Date Dimension Id → <role>_dt_dim_id)
□ A19-R1: Driving là Fact Snapshot/Fact Append → dòng lookup_date có `<driving>.<cột ngày> = :etl_date` (không chỉ `src_stm_code`)
□ A19-R2/R3: bảng snapshot/event join thêm nối ngày vào Driving hoặc tự khóa ngày; mọi subquery/CTE khóa ngày BÊN TRONG (theo alias)
□ A19-R4/R5: không có `MAX(trading_dt)` / `ROW_NUMBER ... ORDER BY trading_dt DESC = 1` / `<=` không chặn dưới trên toàn lịch sử; Dimension/Operational current-state khóa `= :etl_date` hoặc lookback có N ghi rõ (bảng TRUNCATE+INSERT: hỏi Data Modeler)
□ A19-R6: LAG/LEAD liên ngày có cửa sổ [phiên T−k, :etl_date] hoặc đọc cột kỳ trước có sẵn — không để LAG trên bảng khóa 1 ngày
□ TC12 (`check_date_bound.py --module {MODULE} --file {mart_table}`) đã chạy, mọi phát hiện đã phân loại
□ Không thiết kế Effective Date / Expiry Date / Population Date
□ Mọi bảng dim/operational có attribute src_stm_code (cuối danh sách)
□ src_stm_code: mọi bảng (kể cả single-source) → luôn có WHERE filter trong etl_logic (forward-compatibility)
□ src_stm_code: multi-source nhiều nguồn dùng cùng lúc → dùng WHERE IN (...)
□ src_stm_code: multi-source tách bộ (partition/UNION) → N bộ × M dòng, mỗi bộ có src_stm_code riêng
□ src_stm_code: bộ chưa xác định Atomic source → etl_logic_type = pending toàn bộ bộ đó
□ src_stm_code: fact No-Driving-Table → không thêm
□ src_stm_code: giá trị dùng dấu `_` (VD NHNCK_CERTIFICATES) — KHÔNG dùng dấu `.` theo tên file Atomic YAML (VD NHNCK.CERTIFICATES); áp dụng cả tên file DTM_{MODULE}_{table}_{src_stm_code}.csv
□ cl_dim: tên cột scm_code / cl_code / cl_nm (align Atomic cv); Detail Mapping dùng Scheme Code= / Classification Code=
□ nullable = false cho PK / BK / FK
□ data_domain = Classification Value → key trống
□ data_domain = Surrogate Dimension Key → key = FK → <Dim>
□ data_domain = Surrogate Key trên Fact chỉ ở dòng key = PK (A22) — cột _id khác là cột dư
□ Export UTF-8 BOM (utf-8-sig)
```
