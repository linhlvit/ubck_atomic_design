---
name: source-survey
description: |
  Khảo sát cấu trúc CSDL nguồn qua MCP Oracle, xuất 2 file CSV chuẩn
  (Source/{SOURCE}_Tables.csv và Source/{SOURCE}_Columns.csv), tạo ER Diagram
  HTML tương tác, và sinh BRD Source YAML (BRD/Source/brd_{SOURCE}.yaml +
  BRD/Source/{SOURCE}/ columns files).
  Sử dụng khi: cần khảo sát source mới, cập nhật CSV sau khi schema thay đổi,
  tạo lại ER diagram cho source đã có, hoặc đối chiếu CSV tài liệu thiết kế
  với CSDL thực tế (chế độ reconcile).
  Yêu cầu: MCP server tương ứng với CSDL nguồn đã được cấu hình và kết nối.
  Mỗi CSDL nguồn có 1 MCP server riêng — schema được hardcode trong script MCP,
  không cần truyền thêm tham số SCHEMA.
  Chế độ reconcile: đã có sẵn {SOURCE}_Tables.csv + {SOURCE}_Columns.csv từ
  tài liệu thiết kế — chỉ chạy Giai đoạn 1 + 1b để đối chiếu, không ghi đè CSV.
---

# Skill: Source Survey — Khảo sát CSDL nguồn

Đọc file này TRƯỚC KHI bắt đầu. Skill này thực thi đủ các giai đoạn theo thứ tự, tuỳ theo MODE.

## MCP Server theo CSDL nguồn

Mỗi CSDL nguồn có 1 MCP server riêng, cấu hình trong `.claude/settings.json`:

| SOURCE | MCP Server | Script |
|---|---|---|
| `ThanhTra` | `oracle-thanhtra` | `~/.claude/oracle_mcp_server.py` |
| `NHNCK` | `oracle-nhnck` | `~/.claude/oracle_mcp_nhnck.py` |

Khi thêm source mới: tạo script MCP mới (copy từ script hiện có, đổi connection info + tên server),
sau đó thêm entry vào `mcpServers` trong `.claude/settings.json`. Schema tự xác định theo
user đang login — các script dùng `user_*` views, không cần truyền `SCHEMA` riêng.

**Trước khi bắt đầu:** xác nhận MCP server của source đang làm đã kết nối thành công
bằng cách gọi thử `list_tables` qua tool `mcp__{MCP_SERVER}__list_tables`.

**Fallback nếu MCP không load** (tool không xuất hiện trong deferred tools hoặc lỗi `ModuleNotFoundError: oracledb`):
1. Cài module nếu thiếu: `/opt/homebrew/bin/python3.12 -m pip install oracledb --break-system-packages`
2. Query trực tiếp qua Python — lấy connection info từ script `~/.claude/oracle_mcp_{source}.py` (biến `ORACLE_DSN`, `ORACLE_USER`, `ORACLE_PASSWORD`), rồi chạy các query của Giai đoạn 1 bằng `oracledb.connect(...)` thay vì qua MCP tool.

## Đầu vào cần xác nhận với người dùng

| Tham số | Mô tả | Ví dụ |
|---|---|---|
| `SOURCE` | Tên source system viết HOA | `ThanhTra`, `NHNCK`, `FIMS` |
| `MCP_SERVER` | Tên MCP server tương ứng | `oracle-thanhtra`, `oracle-nhnck` |
| `MODE` | Chế độ chạy (tuỳ chọn, mặc định `full`) | `full` / `reconcile` |
| `BRD_FILE` | Đường dẫn file BRD Excel (tuỳ chọn) | `BRD/Report/BRD_ThanhTra.xlsx` |
| `BRD_SHEET` | Tên sheet chứa SQL (tuỳ chọn) | `TT` |
| `BRD_SQL_COL` | Header cột chứa SQL (tuỳ chọn) | `Câu lệnh tham khảo` |
| `BRD_STATUS_COL` | Header cột trạng thái (tuỳ chọn) | `Trạng thái mapping` |
| `BRD_STATUS_VAL` | Giá trị filter (tuỳ chọn) | `Done` |

Nếu không có BRD → bỏ qua highlight, tạo diagram không có BRD layer.

---

## Luồng thực thi theo MODE

| MODE | Giai đoạn chạy | Ghi đè CSV gốc |
|---|---|---|
| `full` (mặc định) | 1 → 2 → 3 → 4 → 4b | Có (tạo mới hoàn toàn) |
| `reconcile` | 1 → 1b → 4 → 4b | Không — chỉ cập nhật cột Ghi chú và tạo Reconcile file |

Giai đoạn 4 (sinh BRD YAML) luôn chạy ở cả hai mode sau khi có CSV hoàn chỉnh.
Giai đoạn 4b (cập nhật scope từ BRD Excel) chỉ chạy khi `BRD_FILE` được cung cấp **và** cột "Bảng nguồn" đã được điền — bỏ qua nếu chưa có.

Nếu người dùng đã có CSV tài liệu thiết kế và chỉ muốn đối chiếu → hỏi xác nhận
MODE trước khi chạy, tránh ghi đè dữ liệu tài liệu.

---

## Giai đoạn 1 — Khảo sát CSDL qua MCP Oracle

Dùng tool `mcp__{MCP_SERVER}__query_oracle` để chạy các query bên dưới.
Các query dùng `user_*` views — tự giới hạn trong schema của user đang login,
không cần truyền `owner` hay `SCHEMA`.

### Bước 1.1 — Liệt kê bảng + comment

```sql
SELECT t.table_name, c.comments
FROM user_tables t
LEFT JOIN user_tab_comments c ON c.table_name = t.table_name
ORDER BY t.table_name
```

### Bước 1.2 — Lấy cột + comment + data type

```sql
SELECT c.table_name, c.column_name, c.data_type,
       c.data_length, c.data_precision, c.data_scale,
       c.nullable, cc.comments
FROM user_tab_columns c
LEFT JOIN user_col_comments cc
  ON cc.table_name = c.table_name AND cc.column_name = c.column_name
ORDER BY c.table_name, c.column_id
```

⚠ Nếu kết quả quá lớn (MCP lưu vào file): đọc file bằng `python3 -c "import json; ..."`.

### Bước 1.3 — Lấy PK + FK constraints

```sql
SELECT ac.table_name, acc.column_name,
       ac.constraint_type,
       ac.r_constraint_name,
       rc.table_name  AS ref_table,
       rcc.column_name AS ref_col
FROM user_constraints ac
JOIN user_cons_columns acc
  ON acc.constraint_name = ac.constraint_name AND acc.position = 1
LEFT JOIN user_constraints rc
  ON rc.constraint_name = ac.r_constraint_name
LEFT JOIN user_cons_columns rcc
  ON rcc.constraint_name = rc.constraint_name AND rcc.position = 1
WHERE ac.constraint_type IN ('P','R')
ORDER BY ac.table_name, acc.column_name
```

---

## Giai đoạn 1b — Đối chiếu CSV tài liệu thiết kế vs. CSDL *(chỉ chạy khi MODE=reconcile)*

Điều kiện: đã có `Source/{SOURCE}_Tables.csv` và `Source/{SOURCE}_Columns.csv`
từ tài liệu thiết kế. Mục tiêu: nhận diện chênh lệch trước khi thiết kế LLD,
**không ghi đè file gốc**.

### Bước 1b.1 — Đối chiếu danh sách bảng

**Oracle không phân biệt hoa/thường cho tên object** — luôn normalize `.upper()` trước khi so sánh,
cả tên bảng lẫn tên cột. Không báo mismatch chỉ vì `flyway_schema_history` vs `FLYWAY_SCHEMA_HISTORY`.

So sánh (sau khi đã `.upper()` cả hai phía):
- Bảng có trong CSV nhưng **không có trên DB** → ghi nhận `only_in_doc`
- Bảng có trên DB nhưng **không có trong CSV** → ghi nhận `only_in_db`
- Bảng khớp → `matched`

### Bước 1b.2 — Đối chiếu FK constraints

Với mỗi bảng `matched`, so sánh FK:

| Trường hợp | Phân loại | Xử lý |
|---|---|---|
| FK trong CSV + có DB constraint khớp ref_table | `confirmed` | Cập nhật ghi chú CSV: "FK đã xác nhận qua khảo sát DB" |
| FK trong CSV + **không có** DB constraint | `doc_only` | Ghi nhận — thường là intentional (app-level FK) |
| FK trong CSV + có DB constraint nhưng **ref_table khác** | `conflict` | Ghi vào Reconcile Issues |
| FK có DB constraint + **không có** trong CSV | `db_only` | Ghi nhận — bổ sung vào CSV nếu không xung đột |

### Bước 1b.3 — Cập nhật CSV (không xung đột)

Chỉ cập nhật cột **Ghi chú (FK suy luận)** trong `{SOURCE}_Columns.csv`:
- `confirmed`: đổi "FK suy luận" → "FK đã xác nhận qua khảo sát DB"
- `db_only` rõ ràng: thêm dòng cột mới với ghi chú "Phát hiện qua khảo sát DB"
- **Không** thay đổi cột Khóa, Mô tả, hoặc bất kỳ thông tin nào từ tài liệu thiết kế

### Bước 1b.4 — Xuất báo cáo đối chiếu

Xuất `Source/{SOURCE}_Reconcile_Issues.csv` cho các trường hợp cần làm rõ:

```
STT,Bảng,Cột,Loại vấn đề,Mô tả trong tài liệu thiết kế,Thực tế trên CSDL,Câu hỏi cần làm rõ,Trạng thái
```

- Chỉ ghi nhận `conflict` và `only_in_doc` / `only_in_db` đáng chú ý
- Mỗi issue kèm câu hỏi cụ thể soạn sẵn để làm rõ với nguồn
- Trạng thái mặc định: `Chờ xác nhận`

### Bước 1b.5 — Tóm tắt báo cáo cho người thiết kế

Trình bày ngắn gọn:
1. Số bảng: matched / only_in_doc / only_in_db
2. FK confirmed / doc_only / db_only / conflict
3. Danh sách issue đã ghi vào Reconcile file
4. Khuyến nghị: điểm nào cần làm rõ với nguồn trước khi bắt đầu LLD

---

## Giai đoạn 2 — Xuất 2 file CSV

Dùng Python script để tổng hợp kết quả từ Giai đoạn 1.

### `Source/{SOURCE}_Tables.csv`

```
STT,Tên bảng,Ý nghĩa bảng
1,TABLE_NAME,"Comment từ Oracle (để trống nếu null)"
```

- Encoding: `utf-8-sig` (BOM, để Excel mở đúng tiếng Việt)
- Thứ tự: theo `table_name` alphabetical hoặc theo `object_id` nếu có
- Bỏ qua bảng hệ thống: `flyway_schema_history`, `DYNAMIC*` nếu không liên quan nghiệp vụ (hỏi người dùng)

### `Source/{SOURCE}_Columns.csv`

```
Tên bảng,Tên trường,Mô tả,Khóa,Ghi chú (FK suy luận)
TABLE_NAME,COL_NAME,"Comment Oracle",PK,
TABLE_NAME,FK_COL,"Comment Oracle",FK,FK → REF_TABLE.REF_COL
```

- Cột **Khóa**: `PK` / `FK` / (trống)
- Cột **Ghi chú**: `FK → REF_TABLE.REF_COL` cho FK columns
- Một cột có thể vừa PK vừa FK → ghi `PK` ưu tiên, FK note vào Ghi chú
- Mô tả: lấy từ Oracle column comment; để trống nếu null (không bịa)

---

## Giai đoạn 3 — Tạo ER Diagram HTML

Dùng Python script sinh file `docs/output/{SOURCE}/{SOURCE}_ER_Diagram.html`.

**Lưu ý:** Giai đoạn 3 chạy **sau** Giai đoạn 4 (đã có `brd_{SOURCE}.yaml` hoàn chỉnh). Mọi thông tin cần thiết lấy từ YAML — không đọc BRD Excel thêm.

### 3.1 — Nguồn dữ liệu cho diagram

Đọc `BRD/Source/brd_{SOURCE}.yaml` để lấy:

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
    {"ft": "FROM_TABLE", "fc": "FROM_COL", "tt": "TO_TABLE", "tc": "TO_COL"}
  ]
}
```

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

Sau khi có CSV hoàn chỉnh (`Source/{SOURCE}_Tables.csv` và `Source/{SOURCE}_Columns.csv`),
sinh 2 loại file YAML theo schema `schemas/brd_source.schema.json` và `schemas/brd_source_columns.schema.json`.

### 4.1 — File tổng hợp: `BRD/Source/brd_{SOURCE}.yaml`

Mỗi bảng trong `{SOURCE}_Tables.csv` → 1 entry trong `brd_entries`. Cần điền đầy đủ:

**`brd_id`:** `BRD-SRC-{SOURCE}-{TABLE_NAME}` — tên bảng theo convention nguồn (Oracle = UPPER_SNAKE_CASE).

**`functional_group` và `scope_status`/`scope_reason`:**
Suy luận từ tên bảng + mô tả. Hỏi người dùng xác nhận nhóm chức năng nếu không rõ.
Tiêu chí out_of_scope phổ biến: audit log, config/system parameters, PKI/digital cert operational, backup, queue.

**`related_tables`** — điền cho **tất cả bảng** (kể cả out_of_scope), dựa trên FK trong `{SOURCE}_Columns.csv`:
- Cột "Khóa" = `FK`, cột "Ghi chú" = `FK → TargetTable.TargetCol`
- Bảng hiện tại có FK trỏ ra ngoài: `relation: "FK cha — <ý nghĩa bảng cha>"`
- Bảng khác có FK trỏ vào bảng này: `relation: "1-N — <ý nghĩa bảng con>"`
- Không có FK cả 2 chiều → `related_tables: null`
- Tên bảng trong `related_tables[].table` phải theo convention nguồn (Oracle = UPPER_SNAKE_CASE)

**`ingestion`** — điền cho **tất cả bảng** (kể cả out_of_scope):

Xác định `data_change_mode` theo 2 bước:

*Bước 1 — Pattern matching trên tên cột* (từ `{SOURCE}_Columns.csv`):

| Nhóm keyword (kiểm tra tên cột, case-insensitive, bỏ `_`) | Kết quả |
|---|---|
| Có cột chứa `updated` / `modified` / `last_update` / `last_sync` / `sync_updated` | `Update` (filter_logic=null, filter_note=null) |
| Chỉ có cột chứa `created` / `insert` / `create` — không có nhóm "cập nhật" | `Append` (filter theo cột đó) |
| Không có cột nào thuộc cả 2 nhóm | → Bước 2 |

*Bước 2 — Reasoning theo nghĩa bảng* (nếu Bước 1 không xác định được):
- Bảng lịch sử/log bản chất append-only (VD: bảng có cột date nghiệp vụ như `ChangeDate`, `IssueDate`) → `Append` với cột date phù hợp nhất
- Bảng danh mục/link table không có timestamp → `Update`
- Không xác định được → `Update` (safe default)

⚠ **Luôn đọc từ CSV hiện tại** — không dùng kết quả cache từ lần chạy trước. Tên cột có thể đã thay đổi (PascalCase → UPPER_SNAKE_CASE) dẫn đến sai kết quả pattern matching.

**Lý do quy tắc:** `UpdatedAt` tồn tại → DB track thay đổi sau insert → Append sẽ bỏ sót. Chỉ có `CreatedAt` → row không thay đổi sau tạo → Append an toàn.

**Lưu ý Oracle UPPER_SNAKE_CASE:**
- `filter_logic` dùng tên cột lowercase: `created_at >= {data_date}` (không phải `CreatedAt`)
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
    data_type: VARCHAR2(100)   # hoặc NUMBER, DATE, v.v.
    description: "Mô tả từ CSV"
    key: PK                    # PK / FK / PK/FK / null
    fk_note: "FK → REF_TABLE.REF_COL"  # null nếu không có
```

Cột `key`: đúng enum `PK` / `FK` / `PK/FK` / `null` — không ghi giá trị khác.

### 4.3 — Cập nhật `BRD/Source/_summary.csv`

Sau khi sinh xong YAML, chạy script có sẵn để rebuild summary:

```bash
/opt/homebrew/bin/python3.12 scripts/generate_brd_summary.py
```

Script này scan toàn bộ `BRD/Source/brd_*.yaml` và ghi lại `_summary.csv` từ đầu.

### 4.4 — Kiểm tra sau khi sinh

```bash
# 1. Số entries đúng với số bảng trong Tables.csv
grep "brd_id:" BRD/Source/brd_{SOURCE}.yaml | wc -l

# 2. Không còn PascalCase trong cột table (với Oracle source)
grep "^  table:" BRD/Source/brd_{SOURCE}.yaml | grep "[A-Z][a-z]"  # → 0 kết quả

# 3. Tất cả bảng đều có ingestion (kể cả out_of_scope)
python3 -c "
import yaml
doc = yaml.safe_load(open('BRD/Source/brd_{SOURCE}.yaml'))
missing = [e['brd_id'] for e in doc['brd_entries']
           if 'ingestion' not in e['content']]
print('Missing ingestion:', missing)
"

# 4. Số columns files = tổng số bảng (Tables.csv)
ls BRD/Source/{SOURCE}/ | wc -l
```

---

## Giai đoạn 4b — Cập nhật scope_status từ BRD Excel

**Điều kiện chạy:** `BRD_FILE` được cung cấp **và** cột "Bảng nguồn" trong BRD Excel đã được điền (thường sau khi đã chạy Giai đoạn 3 + xác nhận bảng nguồn). Nếu cột chưa điền → bỏ qua giai đoạn này.

**Tham số bổ sung** (thêm vào bảng đầu vào khi có BRD):

| Tham số | Mô tả | Ví dụ NHNCK |
|---|---|---|
| `BRD_SOURCE_COL` | Header cột "Bảng nguồn" đã điền | `Bảng nguồn` |
| `BRD_NGUON_COL` | Header cột lọc source system | `Nguồn` |
| `BRD_NGUON_VAL` | Giá trị filter (tên source) | `NHNCK` |

### Logic extract bảng từ Excel

```python
import openpyxl

wb = openpyxl.load_workbook(BRD_FILE, data_only=True)
ws = wb[BRD_SHEET]

header = [str(c.value or '').strip() for c in ws[2]]  # header ở row 2
col_nguon  = next(i for i,h in enumerate(header) if h == BRD_NGUON_COL)
col_bang_p = next(i for i,h in enumerate(header) if h == BRD_SOURCE_COL)

brd_tables = set()
for row in ws.iter_rows(min_row=3, values_only=True):
    if not any(row): continue
    if str(row[col_nguon] or '').strip() != BRD_NGUON_VAL: continue
    val = str(row[col_bang_p] or '').strip()
    for t in val.split(','):
        t = t.strip()
        if t:
            brd_tables.add(t)
```

### Cập nhật brd_{SOURCE}.yaml

- Bảng có tên trong `brd_tables` → `scope_status: in_scope`
- Bảng không có trong `brd_tables` → `scope_status: out_of_scope`
- Dùng regex patch text-level (không parse/dump YAML để giữ nguyên format + comments):

```python
import re

with open(f'BRD/Source/brd_{SOURCE}.yaml', encoding='utf-8') as f:
    content = f.read()

changed = 0

def patch_entry(m):
    global changed
    entry_text = m.group(0)
    tm = re.search(r'^    table:\s+(\S+)', entry_text, re.MULTILINE)
    if not tm:
        return entry_text
    table_name = tm.group(1)
    desired = 'in_scope' if table_name in brd_tables else 'out_of_scope'
    current = 'in_scope' if 'scope_status: in_scope' in entry_text else 'out_of_scope'
    if desired != current:
        entry_text = entry_text.replace(
            f'scope_status: {current}', f'scope_status: {desired}'
        )
        changed += 1
    return entry_text

patched = re.sub(
    r'(?s)(^- brd_id:.*?)(?=^- brd_id:|\Z)',
    patch_entry,
    content,
    flags=re.MULTILINE
)

with open(f'BRD/Source/brd_{SOURCE}.yaml', 'w', encoding='utf-8') as f:
    f.write(patched)

print(f"Đã cập nhật {changed} bảng")
```

### Sau khi patch

Rebuild `_summary.csv`:
```bash
/opt/homebrew/bin/python3.12 scripts/generate_brd_summary.py
```

### Kiểm tra

```bash
grep "scope_status:" BRD/Source/brd_{SOURCE}.yaml | sort | uniq -c
# → in_scope count phải bằng len(brd_tables)
```

---

## Lưu ý khi áp dụng cho source mới

- **Thêm source mới**: tạo script MCP mới tại `~/.claude/oracle_mcp_{source}.py`
  (copy từ script hiện có, đổi `ORACLE_USER`, `ORACLE_PASSWORD`, `ORACLE_DSN` nếu cần,
  đổi tên `Server("oracle-{source}")`), sau đó thêm entry vào `mcpServers` trong
  `.claude/settings.json` và restart session để kích hoạt
- **Xác nhận kết nối** trước khi chạy: gọi `mcp__{MCP_SERVER}__list_tables` — nếu trả về
  danh sách bảng là kết nối thành công
- Nếu BRD có nhiều sheet → hỏi người dùng sheet nào chứa SQL mapping
- Cột SQL trong BRD có thể có tên khác → tìm theo keyword "câu lệnh" hoặc "SQL"
- Sau khi xuất CSV, xác nhận số bảng/cột hợp lý với người dùng trước khi tạo diagram
- Nếu đã có CSV từ tài liệu thiết kế → ưu tiên dùng `MODE=reconcile` thay vì `full`,
  để không mất thông tin mô tả đã được dịch/bổ sung thủ công trong CSV gốc
