---
name: source-survey
description: |
  Khảo sát cấu trúc CSDL nguồn từ file schema (Source/DDL UAT*/*_schema.txt, tra qua
  cột schema_file trong Source/source_systems.csv), sinh BRD Source YAML
  (BRD/Source/brd_{SOURCE}.yaml + BRD/Source/{SOURCE}/ columns files) và tạo ER Diagram
  HTML tương tác. Không còn dùng Source/{SOURCE}_Tables.csv / {SOURCE}_Columns.csv.
  Sử dụng khi: cần khảo sát source mới, cập nhật BRD sau khi schema UAT thay đổi
  (chế độ reconcile), gợi ý FK/mô tả còn thiếu, hoặc tạo lại ER diagram cho source đã có.
  Yêu cầu: file schema của source đã có trong Source/ và đã khai ở source_systems.csv.
  Parser dùng chung: scripts/schema_reader.py.
  Lưu ý: scope_status KHÔNG được đánh trong skill này — bảng mới khởi tạo với
  scope_status: pending. Việc đánh in_scope do skill atomic-lld-design thực hiện sau LLD.
---

# Skill: Source Survey — Khảo sát CSDL nguồn

Đọc file này TRƯỚC KHI bắt đầu. Skill này thực thi đủ các giai đoạn theo thứ tự, tuỳ theo MODE.

## Nguồn sự thật

| Thông tin | Nơi lưu |
|---|---|
| Cấu trúc CSDL nguồn (bảng, cột, kiểu, null, PK, FK ở DB, comment) | File schema `Source/DDL UAT*/…_schema.txt` — **chỉ đọc, không sửa** |
| Ánh xạ SOURCE → file schema | `Source/source_systems.csv`, cột `schema_file` (đường dẫn **tính từ `Source/`**) |
| Danh sách bảng, ý nghĩa bảng, phạm vi thiết kế | `BRD/Source/brd_{SOURCE}.yaml` — `content.table_meaning`, `content.scope_status` |
| Cột đã duyệt: mô tả, FK | `BRD/Source/{SOURCE}/brd_{SOURCE}_{TABLE}.yaml` |

`Source/{SOURCE}_Tables.csv` và `{SOURCE}_Columns.csv` **không còn là đầu vào**. Không tạo mới, không đọc.
Danh sách bảng cần thiết kế = các entry có `content.scope_status: in_scope` trong `brd_{SOURCE}.yaml`
(`pending` = chưa thiết kế, `out_of_scope` = loại).

Source không có `schema_file` (hiện: DCST, GSGD, MDDS; IAM/ORDERTRADE chưa có dòng trong
`source_systems.csv`) → skill này không chạy được cho source đó; YAML là bản gốc, sửa tay.

## Parser: `scripts/schema_reader.py`

```bash
python scripts/schema_reader.py --source NHNCK                     # tóm tắt: số bảng/cột/FK, WARN
python scripts/schema_reader.py --source NHNCK --table APPLICATIONS  # chi tiết 1 bảng
python scripts/schema_reader.py --source NHNCK --infer-fk          # FK gợi ý (inferred)
python scripts/schema_reader.py --source NHNCK --missing-desc      # bảng/cột thiếu mô tả
python scripts/schema_reader.py --source NHNCK --json              # toàn bộ (tables + fks + warnings)
```

Dùng như thư viện trong script tạm: `from schema_reader import load_source, db_fks, infer_fks, missing_descriptions`
(thêm `scripts/` vào `sys.path`). Script tạm để ở scratchpad, không commit vào repo.

**Đọc `warnings` trong output trước khi làm tiếp.** Trường hợp đã gặp: file `GMS_IDS_UAT_schema.txt` khai báo 13 bảng
2 lần (VD `USERS`); parser giữ khối nhiều cột hơn — người thiết kế phải xác nhận khối nào đúng.
Có nhiều file cùng source (VD `SCMS_UAT_schema.txt` và `SCMS_UAT_schema_20261015.txt`) → chỉ file khai ở
`schema_file` được dùng; hỏi người dùng nếu không chắc file nào là bản chuẩn.

## Quy tắc nguồn gốc dữ liệu (provenance) — BẮT BUỘC

Mỗi giá trị có thể là `curated` / `schema` / `db` / `inferred`. Trường nguồn gốc là tuỳ chọn trong YAML
(`schemas/brd_source.schema.json`, `schemas/brd_source_columns.schema.json`):

| Giá trị | Trường nguồn gốc | Ý nghĩa |
|---|---|---|
| Mô tả bảng | `content.table_meaning_src` | `schema` / `inferred` / (vắng = `curated`) |
| Mô tả cột | `columns[].description_src` | `schema` / `inferred` / (vắng = `curated`) |
| FK | `columns[].fk_src` | `db` / `inferred` / (vắng = `curated`) |

**Vắng trường = `curated`** — toàn bộ YAML đã có từ trước coi là đã duyệt, không cần migrate.

Độ ưu tiên khi ghi/cập nhật (cao → thấp):

| Thông tin | Thứ tự |
|---|---|
| Kiểu dữ liệu, PK | Luôn lấy từ schema, ghi đè |
| FK (`key`, `fk_note`) | `curated` > `db` (cột "Lien ket" trong schema) > `inferred` |
| Mô tả bảng / cột | `curated` > `schema` (comment trong file) > `inferred` > để trống |

- Giá trị `curated` **không bao giờ bị ghi đè** khi chạy lại.
- Giá trị `schema` / `db` / `inferred` được tính lại mỗi lần chạy. `inferred` bị thay nếu sau đó schema có giá trị thật.
- Khi data_type của schema khác YAML hiện có → cập nhật theo schema và nêu số cột đổi trong báo cáo (không im lặng).
- Không bịa: mô tả `inferred` chỉ dựa trên tên bảng/cột/kiểu/FK, không suy diễn nghiệp vụ cụ thể.

## Đầu vào cần xác nhận với người dùng

| Tham số | Mô tả | Ví dụ |
|---|---|---|
| `SOURCE` | Tên source system viết HOA, phải có `schema_file` | `THANHTRA`, `NHNCK`, `FIMS` |
| `MODE` | Chế độ chạy (tuỳ chọn, mặc định tự chọn theo bên dưới) | `full` / `reconcile` |

Chọn MODE: nếu `BRD/Source/brd_{SOURCE}.yaml` **chưa tồn tại** → `full`. Đã tồn tại → `reconcile`
(hỏi xác nhận trước khi chạy `full` đè lên YAML đã có).

---

## Luồng thực thi theo MODE

| MODE | Giai đoạn chạy | Ghi YAML |
|---|---|---|
| `full` (source mới) | 1 → 2 → 4 → 3 | Tạo mới toàn bộ |
| `reconcile` (YAML đã có) | 1 → 1b → 2 → 4 → (3 nếu cần) | Chỉ thêm bảng/cột mới + cập nhật theo bảng ưu tiên ở trên; **không xoá** |

---

## Giai đoạn 1 — Đọc schema

1. Tra `schema_file` của SOURCE trong `Source/source_systems.csv`; mở file bằng `schema_reader.py --source {SOURCE}` để xem tóm tắt + warnings.
2. Báo người dùng: số bảng, số cột, số FK (DB), số FK gợi ý (inferred), số bảng/cột thiếu mô tả, các WARN.
3. Với bảng hệ thống/không liên quan nghiệp vụ (`flyway_schema_history`, `DYNAMIC*`, bảng `*_BK*`/`*_BAK_*`, `*_CLONE`) → **hỏi người dùng** có đưa vào BRD không (nếu đưa: `scope_status: pending`, về sau chuyển `out_of_scope` ở HLD/LLD).

Tên Oracle không phân biệt hoa/thường: luôn so sánh `.upper()` (cả tên bảng lẫn tên cột).

---

## Giai đoạn 1b — Đối chiếu schema vs BRD YAML *(chỉ chạy khi MODE=reconcile)*

Mục tiêu: nhận diện chênh lệch giữa file schema mới và YAML hiện có, **không ghi đè giá trị curated**.

### Bước 1b.1 — Đối chiếu danh sách bảng

So sánh tên bảng trong schema với `content.table` của `brd_{SOURCE}.yaml` (sau `.upper()`):

| Phân loại | Xử lý |
|---|---|
| `only_in_schema` | Bảng mới — thêm entry (`scope_status: pending`) + file cột ở Giai đoạn 4 |
| `only_in_yaml` | Bảng bị bỏ/đổi tên trên schema — **không xoá**, chỉ báo cáo (nghi đổi tên: gợi ý bảng `only_in_schema` có cột trùng ≥ 80%) |
| `matched` | Đối chiếu cột ở bước 1b.2 |

### Bước 1b.2 — Đối chiếu cột và FK (với bảng `matched`)

| Trường hợp | Xử lý |
|---|---|
| Cột chỉ có trong schema | Thêm vào file cột (thứ tự theo schema) |
| Cột chỉ có trong YAML | Báo cáo (nghi đổi tên/bỏ cột); không xoá |
| `data_type` khác | Cập nhật theo schema, ghi vào báo cáo |
| FK `db` trùng `fk_note` curated | Giữ curated (không đổi `fk_src`) |
| FK `db` khác `fk_note` curated (ref khác) | **Conflict** — giữ curated, ghi vào báo cáo để người thiết kế quyết |
| FK `db` mà YAML chưa có FK | Thêm: `key: FK`, `fk_note: "FK → T.C"`, `fk_src: db` |
| Cột có FK `inferred` mà YAML chưa có FK | Thêm theo Giai đoạn 2 |

### Bước 1b.3 — Báo cáo cho người thiết kế

Trình bày ngắn: (1) bảng matched / only_in_schema / only_in_yaml; (2) cột thêm / cột chỉ có ở YAML / đổi kiểu;
(3) FK mới từ DB / conflict; (4) khuyến nghị điểm cần làm rõ trước LLD.
Không tạo file `*_Reconcile_Issues.csv` mới (đã bỏ); nếu người dùng cần lưu, ghi vào `Datamart/context/` hoặc scratchpad.

---

## Giai đoạn 2 — Suy luận FK và mô tả

Chạy cho cột/bảng mà schema **không có** thông tin. Mọi giá trị suy luận phải gắn cờ `inferred`.

### 2.1 — Gợi ý FK (script, xác định được)

Lấy từ `schema_reader.infer_fks(doc)` (hoặc `--infer-fk`). Quy tắc của hàm:

- Chỉ xét cột có hậu tố `_ID` (hoặc `Id` kiểu PascalCase), chưa có FK ở DB, không phải PK đơn của chính bảng.
- Phần gốc (`stem`) phải **khớp tên một bảng có trong schema** (số ít / số nhiều: `S`, `ES`, `IES`).
- Bỏ dần từ đầu của stem (`PREVIOUS_CERTIFICATE_ID` → `CERTIFICATES`) → `confidence: medium`; khớp đuôi tên bảng có tiền tố (`COMPANY_TYPE_ID` → `CAT_COMPANY_TYPE`) → `medium`; khớp nguyên stem → `high`.
- Chỉ gợi ý khi khớp **duy nhất**; mơ hồ hoặc không khớp thì bỏ qua — **người thiết kế bổ sung ở LLD**, skill không cố đoán thêm.
- Bảng đích phải có PK; cột đích = PK đơn (hoặc cột `ID`). Không tự khớp với chính bảng.

Ghi vào file cột: `key: FK` (hoặc `PK/FK`), `fk_note: "FK → T.C"`, `fk_src: inferred`. Báo người dùng số FK inferred theo mức tin cậy để duyệt.
FK `inferred` **chưa chắc đúng** — skill `atomic-lld-design` không được coi là đã xác nhận khi lập hash comment (xem lưu ý cuối file).

### 2.2 — Suy luận mô tả (2 bước, có duyệt)

1. **Lúc sinh YAML (Giai đoạn 4):**
   - Có comment trong schema → `description` = comment, `description_src: schema`.
   - Cột không có comment → `description: null`, **chưa suy luận** (không gắn `description_src`).
   - Bảng không có comment → `table_meaning: null` (nguồn không cung cấp; không bắt buộc, không suy luận lúc sinh YAML).
2. **Bước riêng "Đề xuất mô tả"** (chạy khi người dùng yêu cầu, sau khi sinh YAML):
   - Lấy danh sách bằng `schema_reader.py --source {SOURCE} --missing-desc` (hoặc quét YAML có `description: null`/`""`).
   - Soạn mô tả tiếng Việt ngắn dựa **chỉ** trên tên bảng, tên cột, kiểu dữ liệu, FK (VD `STATUS_ID` FK → `APPLICATION_STATUSES`: "Trạng thái hồ sơ" — được; thêm quy tắc nghiệp vụ không có trong tên — không được).
   - Ghi `description_src: inferred`, rồi trình bảng đề xuất theo từng bảng để Data Modeler duyệt hàng loạt.
   - Bảng nhiều cột (>30 cột thiếu mô tả): làm từng bảng, không dồn cả schema vào 1 lượt.
   - Khi người thiết kế duyệt → **xoá** `description_src` (thành `curated`); sửa lại → ghi giá trị mới và xoá `description_src`.
   - Chưa duyệt thì giữ `inferred`; LLD coi đây là gợi ý, không phải căn cứ chính.

---

## Giai đoạn 3 — Tạo ER Diagram HTML

Dùng Python script sinh file `docs/output/{SOURCE}/{SOURCE}_ER_Diagram.html`.

**Lưu ý:** Giai đoạn 3 chạy **sau** Giai đoạn 4 (đã có YAML hoàn chỉnh). Mọi thông tin lấy từ YAML — không đọc file schema hay CSV nữa.

### 3.1 — Nguồn dữ liệu cho diagram

Đọc `BRD/Source/brd_{SOURCE}.yaml` (bảng, nhóm, scope) và `BRD/Source/{SOURCE}/brd_{SOURCE}_*.yaml` (cột, PK/FK):

- **Badge in-scope (BRD)**: bảng có `scope_status: in_scope` → `"brd": true` trong data JS
- **Nhóm nghiệp vụ**: lấy từ `functional_group` của mỗi entry → dùng làm `group` trong data JS
- **Màu nhóm**: map từ `functional_group` string sang màu hex. Dùng palette mặc định nếu group chưa được định nghĩa sẵn:

```python
import yaml

with open(f'BRD/Source/brd_{SOURCE}.yaml', encoding='utf-8') as f:
    doc = yaml.safe_load(f)

# Build lookup: table_name → {group, scope}
table_meta = {}
for entry in doc['brd_entries']:
    c = entry['content']
    table_meta[c['table']] = {
        'group': c.get('functional_group', 'other'),
        'brd': c.get('scope_status') == 'in_scope',
    }

# Auto-assign màu cho các group chưa có sẵn
PALETTE = ['#4f46e5','#059669','#dc2626','#7c3aed','#d97706','#0891b2','#6b7280','#0d9488']
group_colors = {}
for meta in table_meta.values():
    g = meta['group']
    if g not in group_colors:
        group_colors[g] = PALETTE[len(group_colors) % len(PALETTE)]
```

### 3.2 — Cấu trúc data JS nhúng vào HTML

```json
{
  "tables": [
    {
      "name": "TABLE_NAME",
      "comment": "Ý nghĩa bảng",
      "group": "inspection",
      "brd": true,
      "fk_linked": false,
      "cols": [
        {"name": "ID", "desc": "", "key": "PK", "fk": "", "brd": true},
        {"name": "FK_COL", "desc": "", "key": "FK", "fk": "FK → REF.ID", "brd": false}
      ]
    }
  ],
  "fks": [
    {"ft": "FROM_TABLE", "fc": "FROM_COL", "tt": "TO_TABLE", "tc": "TO_COL", "inferred": false}
  ]
}
```

`inferred: true` khi `fk_src: inferred` — vẽ đường FK nét đứt để phân biệt với FK đã xác nhận (`db`/`curated`).

### 3.3 — Tính năng bắt buộc của HTML

- **Light theme** (bg `#f0f2f7`, surface `#fff`)
- **Sidebar**: search, danh sách nhóm, stats (đang hiện / BRD / FK)
- **Canvas**: zoom wheel, pan drag, transform-origin 0 0
- **Layout**: connected-component force-directed + shelf packing (isolated nodes không bị đẩy ra xa)
- **Interaction**:
  - Click nhóm → hiện bảng nhóm đó, auto-layout + fit
  - Click bảng → highlight bảng + FK neighbors, dim còn lại; **không** re-layout
  - Click canvas trắng → bỏ chọn
  - Nút ⟳ Auto layout (re-run force trên bảng đang visible)
- **Cards**: badge BRD (nếu có), badge nhóm, tên bảng, comment, danh sách cột (PK🔑 FK🔗 BRD●)
- **FK lines**: SVG curved path, hover tooltip `TABLE.COL → REF.COL`, highlight khi bảng được chọn
- **Drag & drop card**: cập nhật `positions`, redraw lines live, save layout
- **Layout persistence**: `localStorage` (served) hoặc in-memory + Export/Import JSON (file://)
- **Copy text**: cho phép select/copy tên bảng, comment, tên cột

### 3.4 — Kiểm tra sau khi tạo

1. Mở HTML trong browser → sidebar hiện đủ nhóm nghiệp vụ
2. Click 1 nhóm → bảng hiện, không có bảng bị lạc ra xa
3. Click 1 bảng → highlight đúng, FK lines đổi màu
4. Click canvas trắng → bỏ chọn
5. Kéo card → vị trí lưu lại, không mất khi click bảng khác
6. (Nếu có BRD) 12+ bảng có badge BRD, cột BRD được highlight

---

## Giai đoạn 4 — Sinh BRD Source YAML

Sinh 2 loại file YAML theo schema `schemas/brd_source.schema.json` và `schemas/brd_source_columns.schema.json`
bằng **`scripts/gen_brd_source.py`** — script làm trọn Giai đoạn 1b + 2.1 + 4 (không viết script tạm):

```bash
python scripts/gen_brd_source.py --source NHNCK                     # chạy thử: chỉ in báo cáo
python scripts/gen_brd_source.py --source NHNCK --exclude "*_BK*,*_BAK_*" --apply
python scripts/gen_brd_source.py --source XXX --description "Mô tả source" --apply   # source mới
```

Script mặc định **chạy thử**; luôn chạy thử trước, đọc báo cáo với người dùng, rồi mới `--apply`. Việc script làm:

| Việc | Chi tiết |
|---|---|
| Đối chiếu (1b) | Bảng khớp / mới / chỉ có ở YAML; cột mới / chỉ có ở YAML; đổi kiểu; FK conflict; gợi ý đổi tên bảng (≥ 80% cột trùng) |
| Bảng mới | Thêm entry `scope_status: pending`, `functional_group: CHƯA PHÂN NHÓM` (**người thiết kế điền sau**), `table_meaning` từ comment schema (không có thì `null`), `ingestion` theo quy tắc 4.1 |
| Cột | Thêm cột mới; cập nhật PK/`data_type`; FK `curated > db > inferred`; mô tả lấy từ comment schema khi cột chưa có |
| `related_tables` | Chỉ thêm quan hệ còn thiếu từ FK; không xoá |
| An toàn | Không xoá bảng/cột/entry; không ghi đè curated; chỉ ghi khi không phát sinh lỗi JSON schema **mới**; entry không đổi giữ nguyên từng byte; chạy lại lần 2 phải báo "không có thay đổi" |

Script **không** làm: chọn bảng loại khỏi BRD (dùng `--exclude`, script cảnh báo bảng nghi backup/hệ thống), điền
`functional_group`, duyệt mô tả/FK `inferred`, đề xuất mô tả cột (bước 2.2.2), rebuild `_summary.csv` (4.3).

`data_type` luôn lấy **đúng chuỗi trong file schema** (quyết định của Data Modeler), kể cả khi khác bản YAML cũ
(VD `NVARCHAR2(50 CHAR)` → `NVARCHAR2(100)`); báo cáo chỉ nêu số cột bị đổi.

Các điều sau vẫn đúng khi sửa YAML bằng tay hoặc mở rộng script: ghi file theo cách giữ nguyên entry/cột `curated`,
không dựng lại cả file từ đầu khi MODE=reconcile.

### 4.1 — File tổng hợp: `BRD/Source/brd_{SOURCE}.yaml`

Mỗi bảng trong schema (đã qua bước hỏi ở Giai đoạn 1) → 1 entry trong `brd_entries`. Entry đã có thì giữ nguyên
các trường curated; chỉ bổ sung các trường còn thiếu. Cần điền đầy đủ:

**`brd_id`:** `BRD-SRC-{SOURCE}-{TABLE_NAME}` — tên bảng theo convention nguồn (Oracle = UPPER_SNAKE_CASE).

**`content.table_meaning`:** comment bảng trong schema (`table_meaning_src: schema`); nếu nguồn không có → `null`.
Không có rule bắt buộc `table_meaning` / `description` cột (nhiều nguồn không cung cấp); bổ sung sau theo 2.2 khi cần.

**`functional_group`:**
Suy luận từ tên bảng + mô tả. Hỏi người dùng xác nhận nhóm chức năng nếu không rõ.

**`scope_status` và `scope_reason`:**
Bảng mới luôn khởi tạo với `scope_status: pending` và `scope_reason: null`.
Không suy luận in_scope/out_of_scope tại đây — scope sẽ được cập nhật tự động bởi
skill `atomic-lld-design` sau khi thiết kế LLD xong. **Không đổi `scope_status` của entry đã có.**

**`related_tables`** — điền cho **tất cả bảng** (kể cả out_of_scope), dựa trên FK (`db` + `inferred`) của file cột:
- Bảng hiện tại có FK trỏ ra ngoài: `relation: "FK cha — <ý nghĩa bảng cha>"`
- Bảng khác có FK trỏ vào bảng này: `relation: "1-N — <ý nghĩa bảng con>"`
- Không có FK cả 2 chiều → `related_tables: null`
- Tên bảng trong `related_tables[].table` phải theo convention nguồn (Oracle = UPPER_SNAKE_CASE)
- Entry đã có: chỉ **thêm** quan hệ còn thiếu, không xoá quan hệ đã có.

**`ingestion`** — điền cho **tất cả bảng** (kể cả out_of_scope):

Xác định `data_change_mode` theo 2 bước:

*Bước 1 — Pattern matching trên tên cột* (từ schema):

| Nhóm keyword (kiểm tra tên cột, case-insensitive, bỏ `_`) | Kết quả |
|---|---|
| Có cột chứa `updated` / `modified` / `last_update` / `last_sync` / `sync_updated` | `Update` (filter_logic=null, filter_note=null) |
| Chỉ có cột chứa `created` / `insert` / `create` — không có nhóm "cập nhật" | `Append` (filter theo cột đó — tên cột có thể là bất kỳ, không bắt buộc `created_at`) |
| Không có cột nào thuộc cả 2 nhóm | → Bước 2 |

*Bước 2 — Reasoning theo nghĩa bảng* (nếu Bước 1 không xác định được):
- Bảng lịch sử/log bản chất append-only (VD: bảng có cột date nghiệp vụ như `ChangeDate`, `IssueDate`) → `Append` với cột date phù hợp nhất
- Bảng danh mục/link table không có timestamp → `Update`
- Không xác định được → `Update` (safe default)

⚠ **Luôn đọc tên cột từ schema hiện tại** — không dùng kết quả cache từ lần chạy trước. Tên cột có thể đã thay đổi (PascalCase → UPPER_SNAKE_CASE) dẫn đến sai kết quả pattern matching.

**Lý do quy tắc:** `UpdatedAt` tồn tại → DB track thay đổi sau insert → Append sẽ bỏ sót. Chỉ có `CreatedAt` → row không thay đổi sau tạo → Append an toàn.

Entry đã có `ingestion`: không ghi đè (đã duyệt).

**Lưu ý Oracle UPPER_SNAKE_CASE:**
- `filter_logic` dùng tên cột lowercase với đủ 2 điều kiện: `created_at >= {etl_date} AND created_at < {etl_date} + 1` (tên cột có thể khác `created_at`, VD: `update_dt`, `append_at`; không phải `CreatedAt`)
- Dùng `to_upper_snake()` để convert: `re.sub(r'([a-z\d])([A-Z])', r'\1_\2', col).upper().lower()`

### 4.2 — Files cột: `BRD/Source/{SOURCE}/brd_{SOURCE}_{TABLE}.yaml`

Tạo cho **tất cả bảng** (kể cả out_of_scope). Mỗi file có cấu trúc:

```yaml
schema_type: brd_source_columns
schema_version: '1.0'
source: {SOURCE}
table: {TABLE_NAME}
brd_ref: BRD-SRC-{SOURCE}-{TABLE_NAME}
columns:
  - name: COL_NAME
    data_type: VARCHAR2(100)   # lấy từ schema
    description: "Mô tả"       # null nếu chưa có (xem 2.2)
    description_src: schema    # tuỳ chọn: schema | inferred; vắng = curated
    key: PK                    # PK / FK / PK/FK / null
    fk_note: "FK → REF_TABLE.REF_COL"  # null nếu không có
    fk_src: db                 # tuỳ chọn: db | inferred; vắng = curated
```

- Cột `key`: đúng enum `PK` / `FK` / `PK/FK` / `null` — không ghi giá trị khác.
- Một cột vừa PK vừa FK → `key: PK/FK`, `fk_note` ghi FK.
- `fk_note` (và `key: FK`) lấy từ cột "Lien ket" của schema (`fk_src: db`) hoặc gợi ý Giai đoạn 2.1 (`fk_src: inferred`).
- File đã có: thêm cột mới, cập nhật `data_type` khi khác; **giữ nguyên** `description`/`fk_note` curated. Không xoá cột chỉ có ở YAML.

### 4.3 — Cập nhật `BRD/Source/_summary.csv`

Sau khi sinh xong YAML, chạy script có sẵn để rebuild summary:

```bash
python scripts/generate_brd_summary.py
```

Script này scan toàn bộ `BRD/Source/brd_*.yaml` và ghi lại `_summary.csv` từ đầu.

### 4.4 — Kiểm tra sau khi sinh

```bash
# 1. Số entries đúng với số bảng trong schema (cộng bảng only_in_yaml giữ lại, trừ bảng người dùng loại)
grep "brd_id:" BRD/Source/brd_{SOURCE}.yaml | wc -l
python scripts/schema_reader.py --source {SOURCE}      # dòng "Bảng: N"

# 2. Không còn PascalCase trong cột table (với Oracle source)
grep "^    table:" BRD/Source/brd_{SOURCE}.yaml | grep "[A-Z][a-z]"  # → 0 kết quả

# 3. Tất cả bảng đều có ingestion (kể cả out_of_scope)
python -c "
import yaml
doc = yaml.safe_load(open('BRD/Source/brd_{SOURCE}.yaml', encoding='utf-8'))
missing = [e['brd_id'] for e in doc['brd_entries'] if 'ingestion' not in e['content']]
print('Missing ingestion:', missing)
"

# 4. Mỗi bảng có đúng 1 file cột
ls BRD/Source/{SOURCE}/ | wc -l

# 5. Validate theo JSON schema (cả file tổng hợp lẫn file cột)
python -c "
import json, glob, yaml, jsonschema
s1 = json.load(open('schemas/brd_source.schema.json', encoding='utf-8'))
s2 = json.load(open('schemas/brd_source_columns.schema.json', encoding='utf-8'))
jsonschema.validate(yaml.safe_load(open('BRD/Source/brd_{SOURCE}.yaml', encoding='utf-8')), s1)
for p in glob.glob('BRD/Source/{SOURCE}/*.yaml'):
    jsonschema.validate(yaml.safe_load(open(p, encoding='utf-8')), s2)
print('schema OK')
"
```

---

## Lưu ý

- **Thêm source mới:** đặt file schema vào `Source/DDL UAT*/`, thêm dòng vào `Source/source_systems.csv`
  (`source_system,description,schema_file`) rồi chạy MODE=full. Không cần MCP hay CSV trung gian.
- **Cập nhật khi schema UAT đổi:** thay file schema, cập nhật `schema_file` nếu đổi tên, chạy MODE=reconcile.
- Các skill/script hạ nguồn đọc cột nguồn từ `BRD/Source/{SOURCE}/brd_{SOURCE}_{TABLE}.yaml`,
  không từ `Source/*_Columns.csv`.
- **FK `fk_src: inferred` chưa xác nhận:** `atomic-lld-design` (Bước 5, hash comment) cần người thiết kế
  xác nhận FK này trước khi dùng `FK_SOURCE`. Người thiết kế được phép bổ sung/sửa FK ở bước LLD; khi sửa thì
  xoá `fk_src` (thành `curated`).
