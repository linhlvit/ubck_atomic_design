# BA Source Profile — cấu trúc thật của `BRD/BA/BA_analyst_*.csv`

Hồ sơ này khảo sát trực tiếp toàn bộ 13 file BA (2026-08-22), **cập nhật 2026-08-24** cho `BA_analyst_QLCB.csv` bản mới (đổi delimiter `;` → `,`). Dùng để đọc BA **đúng cột, đúng giá trị**
thay vì giả định chỉ số cột cố định — vì các file BA export từ Excel ở nhiều thời điểm khác nhau và
**không có 2 file nào giống nhau về số cột**.

> ⚠️ **Không hard-code chỉ số cột.** Luôn resolve theo tên header (xem thuật toán bên dưới).
> Chỉ số cột trong bảng này là kết quả khảo sát để đối chiếu/kiểm tra, không phải để copy vào script.

---

## 1. Header nằm ở dòng nào — KHÔNG đồng nhất

| Nhóm file | Header thật | Data bắt đầu |
|---|---|---|
| `BA_analyst_GSDC_part1/2/3.csv` | **dòng 0** | dòng 1 |
| 10 file còn lại (FMS, GSTT, NDTNN, NHNCK, PTTT, QLCB, QLKD, TKNB, TT, VP) | **dòng 1** | dòng 2 |

Ở 10 file kia, dòng 0 là header gộp ô của Excel — chỉ có 1–2 ô có chữ (`Khai thác nguồn`, `Review design`),
phần còn lại rỗng. Lấy dòng 0 làm header sẽ hỏng toàn bộ mapping cột.

**Thuật toán xác định header (bắt buộc dùng, không đoán):**

```python
import csv, io
raw = open(path, encoding='utf-8-sig').read()
# Dò delimiter — KHÔNG hard-code ';' (xem mục 5, bẫy "Delimiter không cố định")
best = max((max(len(r) for r in list(csv.reader(io.StringIO(raw), delimiter=d))[:5]), d)
           for d in (';', ','))
rows = list(csv.reader(io.StringIO(raw), delimiter=best[1]))
hdr_idx = 0 if sum(1 for h in rows[0] if h.strip()) >= sum(1 for h in rows[1] if h.strip()) else 1
header, data = rows[hdr_idx], rows[hdr_idx + 1:]
col = {h.strip(): i for i, h in enumerate(header) if h.strip()}
```

---

## 2. Số cột mỗi file — 8 biến thể khác nhau

| Số cột | File |
|---|---|
| 23 | QLCB (delimiter `,` từ bản 2026-08-24 — xem mục 5) |
| 24 | GSDC (3 part) |
| 26 | GSTT, PTTT, TT |
| 27 | QLKD, VP |
| 28 | TKNB |
| 29 | NHNCK |
| 30 | NDTNN |
| 31 | FMS |

---

## 3. Vị trí thật của các cột then chốt (đã khảo sát)

| Cột | Vị trí | Ghi chú |
|---|---|---|
| `STT` | **0** ở mọi file | Số nhóm; mỗi STT = 1 Nhóm duy nhất |
| `Phân loại` | **6** ở mọi file — **trừ NHNCK = 5** | |
| `Trạng thái mapping` | **13** ở mọi file — **trừ NHNCK = 12** | |
| `Khai thác nguồn` | **14** (NHNCK) / **15** (GSTT, NDTNN, PTTT, QLCB, QLKD, TT, VP) / **16** (FMS) / **20** (TKNB) / GSDC dùng tên `Bảng nguồn` ở cột 15 | |
| `Loại dữ liệu` | **20** (QLCB) / **21** (GSDC) / **23** (NHNCK, QLKD, TT) / **24** (GSTT, NDTNN) / **25** (FMS, PTTT, VP) / **26** (TKNB) | Không có vị trí chung — bắt buộc resolve theo tên |

**Header đầy đủ (chỉ GSDC có, dùng làm từ điển tên cột chuẩn):**

```
0 STT              6 Phân loại        12 DL lịch sử?          18 Câu lệnh SQL
1 Mã               7 Đánh giá         13 Trạng thái mapping   19 Câu lệnh update SIT
2 Dashboard/báo cáo 8 Độ chi tiết     14 Mapping (nghiệp vụ)  20 Note
3 Thông tin        9 Nguồn            15 Bảng nguồn           21 Hoàn thành DEV
4 Mô tả           10 Cần phân tích?   16 Trường nguồn         22 Loại dữ liệu
5 Nhóm yêu cầu    11 Cần test?        17 Điều kiện dữ liệu    23 Kết quả SIT
```

---

## 4. Giá trị THẬT của các cột gating (khảo sát toàn bộ 13 file)

### `Phân loại` — 3 giá trị chính

| Giá trị | Số dòng |
|---|---|
| `Chỉ tiêu cơ sở` | 6.091 |
| `Chiều` | 1.438 |
| `Chỉ tiêu phái sinh` | 1.199 |
| `Chiều/Chỉ tiêu cơ sở/Chỉ tiêu phái sinh` (multi-value 1 ô) | 12 |
| `CHIỀU` / `cHIỀU` (lệch hoa-thường) | 4 |
| `Chỉ tiêu` (thiếu hậu tố) | 1 |

> 🔴 **Bẫy thường gặp:** giá trị thật là **`Chỉ tiêu cơ sở`** và **`Chỉ tiêu phái sinh`** —
> KHÔNG phải `Cơ sở` / `Phái sinh`. Filter `== 'Cơ sở'` khớp **0 dòng**.
> Luôn so bằng `.strip().lower()` và dùng `in`/`startswith` để bắt cả biến thể hoa-thường và multi-value.

### `Trạng thái mapping` — thực tế chỉ 2 giá trị

| Giá trị | Số dòng |
|---|---|
| `Done` | 11.184 |
| `Pending` | 105 |

> 🔴 `Doing` và `failed` **không xuất hiện lần nào** trong dữ liệu — chúng chỉ nằm trong 3 ô chú giải
> (`"Done: đã map xong / doing: đang xem xét / failed: đã xem nhưng chưa maping"`).
> Vẫn giữ `Doing` trong điều kiện lọc để phòng BA cập nhật sau, nhưng **không được coi việc thiếu `Doing`
> là bất thường**, và phải biết `failed` là trạng thái thứ 4 hợp lệ theo chú giải dù chưa dùng.

### `Loại dữ liệu` — 11+ giá trị, nhiều hơn 3 giá trị mà `datamart-hld-design` mô tả

| Giá trị | Số dòng | Gating |
|---|---|---|
| `Dữ liệu động` | 4.804 | PENDING |
| `Dữ liệu tĩnh` | 1.444 | READY (nếu Atomic READY) |
| `Chưa có CSDL - Map biểu mẫu` | 1.226 | PENDING |
| `Map biểu mẫu` | 115 | PENDING — biến thể rút gọn |
| `Dữ liệu tĩnh - Chưa có CSDL` | 80 | PENDING — **nối bằng dấu gạch, KHÔNG phải dấu phẩy** |
| `Lý do khác` | 40 | ⚠️ chưa có rule — hỏi BA |
| `Done` | 264 | ⚠️ giá trị sai cột (lẫn từ `Trạng thái mapping`) — hỏi BA, không tự suy |
| Tổ hợp nhiều giá trị cách bởi dấu phẩy | ~250 | Áp **mức thấp nhất** trong tập |

> 🔴 `datamart-hld-design` Bước 2 chỉ liệt kê 3 giá trị + quy tắc "nhiều giá trị cách bởi dấu phẩy".
> 4 giá trị còn lại (`Map biểu mẫu`, `Dữ liệu tĩnh - Chưa có CSDL`, `Lý do khác`, `Done`) **chưa có rule**.
> Khi review gặp chúng → ghi nhận 🟡 Warning "Loại dữ liệu ngoài enum đã chuẩn hoá", không tự quyết READY/PENDING.

### `Đánh giá` (cột 7) — dùng cho rule dedup KPI

| Giá trị | Số dòng |
|---|---|
| `Dễ` | 3.523 |
| `TB` | 3.311 |
| **`Trùng`** | **1.609** |
| `Khó` | 113 |

`Trùng` là ngoại lệ duy nhất cho phép reuse KPI_ID đã có thay vì khai sinh ID mới
(xem checklist `datamart-hld-design`). Với 1.609 dòng, đây là nhánh phổ biến — không phải ca hiếm.

---

## 5. Bẫy parse — bắt buộc xử lý

| Bẫy | Chi tiết | Cách xử lý |
|---|---|---|
| **Delimiter không cố định** | Khảo sát 2026-08-22 ghi "BA dùng `;`" — **không còn đúng cho mọi file**. `BA_analyst_QLCB.csv` bản 2026-08-24 export lại bằng `,` (vẫn 23 cột, 67 dòng logic). Đọc bằng `delimiter=';'` cho ra 1 cột/dòng và **im lặng** trả về kết quả sai: `col` chỉ có 1 key, mọi `g('Nguồn')`/`g('Bảng nguồn')` trả về `''`, dễ bị kết luận nhầm là "BA chưa map nguồn" | **Dò delimiter, không hard-code** — thử cả `;` và `,`, chọn cái cho số cột lớn nhất ở 5 dòng đầu (xem snippet mục 1 và mục 6). Attributes/Detail Mapping vẫn luôn `,` |
| **Closure trong `g = lambda`** | Nếu lưu `g` lại để dùng **sau** vòng lặp (VD: `out.append({'g': g})` rồi lặp `out` ở ngoài), `r` bị bắt theo tham chiếu → **mọi row trả về giá trị của dòng cuối cùng**. Rất khó phát hiện vì script chạy không lỗi, chỉ ra dữ liệu giống nhau ở mọi dòng | Bind theo tham số mặc định: `g = lambda name, r=r: ...`. Snippet mục 6 đã sửa. Chỉ an toàn khi gọi `g()` ngay trong vòng lặp |
| **Ô multi-line** | SQL/mô tả dài chứa xuống dòng → đọc raw line cho số dòng sai (VD GSTT: 452 chỉ tiêu nhưng 7.358 dòng vật lý) | Bắt buộc `csv.reader`, cấm `awk`/`split` |
| **Header lẫn trong data** | 10/13 file có **1 dòng header lặp lại ngay tại dòng data đầu tiên** (giá trị cột `Phân loại` = literal `"Phân loại"`) | Loại mọi dòng có `Phân loại == 'Phân loại'` trước khi đếm |
| **BOM** | Có ở đầu file | `encoding='utf-8-sig'` |
| **GSDC lệch cột** | Ở GSDC, `Note` (col 20) chứa 381 giá trị `Done`, `Hoàn thành DEV` (col 21) chứa 334 `Dữ liệu động` + 47 `Dữ liệu tĩnh`, còn `Loại dữ liệu` (col 22) chỉ có 94+25 — dữ liệu bị **dịch trái 1 cột** ở phần đuôi | Với GSDC: gom giá trị `Loại dữ liệu` từ cả col 21 và col 22; ghi nhận 🟡 Warning về lệch cột nguồn |
| **Part file** | GSDC có 3 part; nhóm STT lớn nằm ở part sau | Đọc hết mọi part, ghép theo STT trước khi review |

---

## 6. Snippet chuẩn — dùng nguyên, không viết lại

```python
import csv, io, glob

def _rows(raw):
    """Dò delimiter thay vì hard-code ';' — QLCB 2026-08-24 đã đổi sang ','."""
    best = None
    for d in (';', ','):
        rows = list(csv.reader(io.StringIO(raw), delimiter=d))
        width = max(len(r) for r in rows[:5])
        if best is None or width > best[0]:
            best = (width, rows)
    return best[1]

def read_ba(module):
    out = []
    for p in sorted(glob.glob(f'BRD/BA/BA_analyst_{module}*.csv')):
        rows = _rows(open(p, encoding='utf-8-sig').read())
        h = 0 if sum(1 for x in rows[0] if x.strip()) >= sum(1 for x in rows[1] if x.strip()) else 1
        header = [x.strip() for x in rows[h]]
        col = {name: i for i, name in enumerate(header) if name}
        for r in rows[h + 1:]:
            # r=r bắt buộc: nếu bind theo tham chiếu, mọi row sẽ trả về giá trị dòng cuối
            g = lambda name, r=r: r[col[name]].strip() if name in col and len(r) > col[name] else ''
            if g('Phân loại') == 'Phân loại':      # dòng header lặp trong data
                continue
            if not any(x.strip() for x in r):       # dòng rỗng
                continue
            out.append({'file': p, 'stt': r[0].strip(), 'raw': r, 'g': g,
                        'phan_loai': g('Phân loại'), 'trang_thai': g('Trạng thái mapping'),
                        'loai_du_lieu': g('Loại dữ liệu'), 'danh_gia': g('Đánh giá')})
    return out

def is_chieu(v):      return v.strip().lower().startswith('chiều')
def is_chi_tieu(v):   return 'chỉ tiêu' in v.strip().lower()
def in_scope(ts):     return ts.strip() in ('Done', 'Doing')
```

---

## 7. Đối chiếu số lượng — con số kỳ vọng

Dùng để tự kiểm script đọc BA có đúng không (số dòng logic sau khi loại header lặp và dòng rỗng):

Số dòng `read_ba()` trả về (đã loại dòng header lặp và dòng rỗng) — **đã kiểm chứng 2026-08-22**:

| Module | Dòng | Module | Dòng |
|---|---|---|---|
| QLKD | 4.272 | GSDC (3 part) | 1.050 |
| FMS | 2.672 | PTTT | 456 |
| TKNB | 1.187 | NDTNN | 260 |
| GSTT | 661 | TT | 166 |
| VP | 536 | NHNCK | 106 |
| | | QLCB | 67 |

- GSDC = 1.050 đúng bằng tổng dòng thô vì header ở dòng 0 và **không có** dòng header lặp.
- 10 module còn lại thấp hơn tổng dòng thô đúng 1 — đó là dòng header lặp đã bị loại. Nếu script của bạn
  ra đúng bằng tổng dòng thô → chưa lọc header lặp, mọi phép đếm sẽ lệch +1.
- Lệch nhiều hơn 1 → script đọc sai (thường do lấy nhầm dòng header hoặc đọc raw line thay vì `csv.reader`).
- `read_ba()` đã được chạy thử trên cả 13 file: **resolve đủ 4/4 cột** (`Phân loại`, `Trạng thái mapping`,
  `Loại dữ liệu`, `Đánh giá`) cho mọi module.
