# BA Source Profile — Cấu trúc Thật của `BRD/BA/BA_analyst_*.csv`

Hồ sơ này khảo sát và chuẩn hóa trực tiếp toàn bộ 11 file BA hiện hành (cập nhật mới nhất sau đợt gộp `BA_analyst_GSĐC.csv` thay thế 3 part cũ, và nâng cấp QLKD v4.3, GSTT v4.5, TKNB, GSĐC). 
Dùng để đọc BA **đúng cột, đúng giá trị** thay vì giả định chỉ số cột cố định — vì các file BA export từ Excel ở nhiều thời điểm khác nhau và **không có 2 file nào giống nhau hoàn toàn về số cột và delimiter**.

> ⚠️ **Không hard-code chỉ số cột.** Luôn resolve theo tên header (xem thuật toán bên dưới).
> Chỉ số cột trong tài liệu này là kết quả khảo sát thực tế trên repository để đối chiếu, không phải để gán cứng index trong code.

---

## 1. Header nằm ở dòng nào — Khảo sát Hiện trạng Repo

| Nhóm file | Header thật | Data bắt đầu | Ghi chú |
|---|---|---|---|
| **Toàn bộ 11 file hiện hành** (`FMS`, `GSTT`, `GSĐC`, `NDTNN`, `NHNCK`, `PTTT`, `QLCB`, `QLKD`, `TKNB`, `TT`, `VP`) | **Dòng 1** (0-indexed: index 1) | **Dòng 2** (index 2) | Dòng 0 là ô gộp Excel trống hoặc chứa tiêu đề báo cáo, không chứa đủ tên cột |
| *File cũ trong `Old versions/` (`BA_analyst_GSDC_part1/2/3.csv`)* | *Dòng 0* | *Dòng 1* | *Đã lưu trữ vào `Old versions/`, được thay thế bởi file gộp `BA_analyst_GSĐC.csv`* |

Ở tất cả file BA hiện hành, dòng 0 là header gộp ô của Excel — chỉ có 1–2 ô có chữ (`Khai thác nguồn`, `Review design`, hoặc tên báo cáo), phần lớn còn lại rỗng. Lấy dòng 0 làm header sẽ làm hỏng toàn bộ việc nhận diện cột.

**Thuật toán xác định header động (bắt buộc dùng, không đoán dòng):**

```python
import csv, io
from collections import Counter

def detect_delimiter_and_header(raw_content: str):
    """Tự động dò delimiter (',' hoặc ';') bằng mode & consistency analysis và header row bằng chấm điểm từ khóa."""
    raw_content = raw_content.lstrip("\ufeff")
    delim_scores = {}

    # 1. Mode & consistency analysis trên 15 dòng đầu tiên
    for delim in (";", ","):
        try:
            reader = csv.reader(io.StringIO(raw_content), delimiter=delim)
            row_lens = [
                len(r) for idx, r in enumerate(reader)
                if idx < 15 and any(c.strip() for c in r) and not (r and r[0].strip().startswith("#"))
            ]
            if not row_lens:
                continue
            mode_len = Counter(row_lens).most_common(1)[0][0]
            consistency = sum(1 for l in row_lens if l == mode_len) / len(row_lens)
            effective_cols = mode_len if mode_len >= 2 else 0
            delim_scores[delim] = (effective_cols, consistency)
        except Exception:
            pass

    best_delim = max(
        delim_scores.keys(),
        key=lambda d: (delim_scores[d][0] >= 15, delim_scores[d][0], delim_scores[d][1])
    ) if delim_scores else ";"

    # 2. Đọc toàn bộ với delimiter tối ưu (hỗ trợ fallback QUOTE_NONE nếu unquoted)
    try:
        reader = csv.reader(io.StringIO(raw_content), delimiter=best_delim)
        all_rows = list(reader)
    except csv.Error:
        reader = csv.reader(io.StringIO(raw_content), delimiter=best_delim, quoting=csv.QUOTE_NONE)
        all_rows = list(reader)

    if not all_rows:
        return best_delim, 0, [], []

    # 3. Quét tối đa 10 dòng đầu để chấm điểm từ khóa header đặc trưng
    best_hdr_idx = 0
    best_score = -1
    for idx in range(min(10, len(all_rows))):
        row = all_rows[idx]
        non_empty = sum(1 for x in row if x.strip())
        row_str = " ".join(x.lower() for x in row)
        score = non_empty
        if "stt" in row_str or "tt" in row_str:
            score += 5
        if "thông tin" in row_str or "chỉ tiêu" in row_str or "tên" in row_str:
            score += 5
        if "phân loại" in row_str:
            score += 5
        if "trạng thái" in row_str:
            score += 5
        if "bảng nguồn" in row_str or "nguồn" in row_str or "khai thác" in row_str:
            score += 5
        if "loại dữ liệu" in row_str or "điều kiện" in row_str or "mô tả" in row_str:
            score += 3
        if score > best_score:
            best_score = score
            best_hdr_idx = idx

    hdr_idx = best_hdr_idx
    header = [x.strip() for x in all_rows[hdr_idx]]
    data_rows = all_rows[hdr_idx + 1:]
    return best_delim, hdr_idx, header, data_rows
```

---

## 2. Phân bổ Delimiter & Số Cột theo từng Phân hệ

> **Nguồn sự thật hiện nay là `system/rules/ba_column_profile.yaml`**, không phải bảng dưới đây.
> Script đọc BA (`datamart_common/ba_parser.py`) lấy delimiter / dòng header / dòng legend / cột STT
> từ file YAML đó và **kiểm chứng lại với header thật**; lệch thì dừng và báo lỗi, không đoán tiếp.
> Bảng dưới đây giữ lại để đối chiếu bằng mắt.

Đo lại trực tiếp ngày 2026-09-18 trên cả 11 file: **8 phân hệ dùng dấu phẩy (`,`)** và
**3 phân hệ dùng dấu chấm phẩy (`;`)** — bản khảo sát trước ghi 6/5 là **SAI**, đã xếp nhầm
NHNCK, NĐTNN, VP sang nhóm `;`.

| Delimiter | Phân hệ | Số cột | Cột STT | Tên file BA |
|---|---|---|---|---|
| `,` | **QLCB** | 23 | STT | `BA_analyst_QLCB.csv` |
| `,` | **GSĐC** | 24 | STT | `BA_analyst_GSĐC.csv` (file gộp thay thế 3 part) |
| `,` | **PTTT** | 26 | STT | `BA_analyst_PTTT.csv` |
| `,` | **GSTT** | 27 | STT | `BA_analyst_GSTT.csv` |
| `,` | **QLKD** | 28 | STT | `BA_analyst_QLKD.csv` |
| `,` | **TKNB** | 29 | STT | `BA_analyst_TKNB.csv` |
| `,` | **NĐTNN** | 31 | STT | `BA_analyst_NDTNN.csv` |
| `,` | **NHNCK** | 31 | STT | `BA_analyst_NHNCK.csv` |
| `;` | **TT** | 26 | STT | `BA_analyst_TT.csv` |
| `;` | **VP** | 27 | **`TT`** | `BA_analyst_VP.csv` — phân hệ DUY NHẤT không đặt tên cột là `STT` |
| `;` | **FMS** | 31 | STT | `BA_analyst_FMS.csv` |

**Cả 11 file đều có dòng legend ở index 2** ("Tên chiều/chỉ tiêu/thuộc tính", "Dễ: lấy 1:1 từ nguồn"…)
— phải bỏ, không phải dòng dữ liệu.

**Cột trùng tên** (parser phải dùng index, không dùng dict tên cột): FMS có 2 cột `Note` (19, 30),
NĐTNN có 2 cột `Note` (19, 30), NHNCK có 2 cột `Kết quả` (26, 29). PTTT (index 20) và VP (index 26)
có cột tên rỗng.

---

## 3. Quy tắc Tra cứu Cột Động theo Tên (Dynamic Column Mapping)

Tuyệt đối không dùng index cứng (như `row[3]`, `row[13]`). Mỗi file có tên cột tương đồng nhưng có thể khác nhau đôi chút:

| Thông tin cần lấy | Danh sách tên cột ứng viên (Case-insensitive) | Ghi chú đặc thù |
|---|---|---|
| **Số nhóm (STT)** | `STT`, `TT` | Module `VP` dùng tên cột là `TT`, 10 module khác dùng `STT` |
| **Mã Dashboard / BC** | `Mã`, `Mã dashboard/BC`, `Mã dashboard/BC`, `PIC` | QLKD có cột `PIC` ở vị trí 1, TKNB/QLCB có `Mã dashboard/BC` |
| **Tên Dashboard** | `Dashboard/báo cáo`, `Dashboard >> báo cáo`, `Dashboard/BC` | FMS dùng dấu `>>` |
| **Tên chỉ tiêu** | `Thông tin`, `Thông tin (chỉ tiêu)`, `Tên chỉ tiêu`, `Chỉ tiêu` | TKNB dùng `Thông tin (chỉ tiêu)`, các file khác dùng `Thông tin` |
| **Mô tả nghiệp vụ** | `Mô tả` | Diễn giải logic của chỉ tiêu |
| **Nhóm yêu cầu** | `Nhóm yêu cầu` | Phân loại báo cáo / màn hình |
| **Phân loại** | `Phân loại` | Bắt buộc kiểm tra: `Chỉ tiêu cơ sở`, `Chỉ tiêu phái sinh`, `Chiều` |
| **Đánh giá** | `Đánh giá` | `Dễ`, `TB`, `Khó`, `Trùng` (căn cứ reuse KPI_ID) |
| **Trạng thái mapping** | `Trạng thái mapping`, `Trạng thái` | Trạng thái phân tích của BA: `Done`, `Doing`, `Pending` |
| **Bảng nguồn** | `Bảng nguồn`, `Nguồn`, `Khai thác nguồn`, `Nguồn chi tiết` | Tên bảng nguồn (IDS, SCMS, MSS, v.v.) |
| **Trường nguồn** | `Trường nguồn` | Tên cột trong bảng nguồn |
| **Loại dữ liệu** | `Loại dữ liệu` | Gating `Dữ liệu động`, `Dữ liệu tĩnh`, `Chưa có CSDL - Map biểu mẫu`, v.v. |
| **Điều kiện dữ liệu** | `Điều kiện`, `Điều kiện chung`, `Điều kiện dữ liệu` | Điều kiện lọc nghiệp vụ |
| **Câu lệnh SQL** | `Câu lệnh tham khảo`, `Câu lệnh SQL`, `Câu lệnh update SIT` | SQL mẫu chứa logic ngầm (TTM, join, rolling) |
| **Ghi chú** | `Note` | Ghi chú bổ sung của BA |

---

## 4. Chuẩn hóa Tập Giá trị Dữ liệu Thực tế

### 4.1. `Phân loại` — 3 giá trị chuẩn và biến thể

Khảo sát 11.289 dòng dữ liệu hợp lệ:
- **`Chỉ tiêu cơ sở`** (~6.034 dòng): Chỉ tiêu đo lường trực tiếp hoặc tổng hợp cấp 1 từ nguồn.
- **`Chiều`** (~1.396 dòng): Dimension, slicer, filter hiển thị hoặc lọc dữ liệu.
- **`Chỉ tiêu phái sinh`** (~1.128 dòng): Chỉ tiêu tính toán từ các chỉ tiêu khác (tỷ lệ, phần trăm, chênh lệch YoY).
- **Biến thể multi-value / hoa-thường**:
  - `Chiều/Chỉ tiêu cơ sở/Chỉ tiêu phái sinh` (10 dòng)
  - `cHIỀU` / `CHIỀU` (biến thể chữ hoa - chữ thường)
  - `Chỉ tiêu` (thiếu hậu tố)

> 🔴 **Quy tắc bắt buộc:** Luôn chuẩn hóa bằng `.strip().lower()`. Dùng `'chỉ tiêu' in v` và `v.startswith('chiều')` để bao quát toàn bộ biến thể. Tuyệt đối không filter bằng `== 'Cơ sở'` hay `== 'Phái sinh'` (sẽ cho ra 0 dòng).

### 4.2. `Trạng thái mapping` — Tập giá trị BA

- **`Done`** (hoặc `Hoàn thành`): Chiếm đa số (~10.999 dòng).
- **`Pending`** (hoặc `Chờ BA`): ~105 dòng.
- **`Doing`**: Đang xem xét (chú thích).
- **`Delete`** (hoặc `DELETED`, `Xóa`, `Xoá`): Chỉ tiêu đã bị hủy bỏ/loại bỏ từ phía BA/nghiệp vụ. **QUY TẮC BẮT BUỘC:** Tuyệt đối KHÔNG đưa vào thiết kế Datamart (cả HLD lẫn LLD). Loại bỏ ngay từ bước đọc parser, không cấp KPI_ID, không map Detail Mapping, không đếm vào số dòng BA hợp lệ.

### 4.3. `Loại dữ liệu` — Gating Trạng thái Datamart

- **`Dữ liệu động`** (~6.386 dòng): Dữ liệu giao dịch biến động theo ngày/phiên. Datamart: PENDING cho đến khi có cơ chế snapshot/SCD.
- **`Dữ liệu tĩnh`** (~1.428 dòng): Danh mục, thông tin tổ chức/cá nhân ít biến đổi. Datamart: READY (nếu Atomic đã approved).
- **`Chưa có CSDL - Map biểu mẫu`** (~1.837 dòng): Biểu mẫu nghiệp vụ chưa có bảng CSDL tương ứng. Datamart: PENDING (nhóm "Chưa có mapping nguồn từ BA").
- **`Map biểu mẫu`** (~46 dòng): Biến thể của nhóm trên. Datamart: PENDING.
- **`Dữ liệu tĩnh - Chưa có CSDL`** (~88 dòng): Datamart: PENDING.
- **Tổ hợp nhiều giá trị** (phân cách bằng dấu phẩy, ví dụ `Dữ liệu tĩnh, Dữ liệu động`): Áp dụng **mức gating thấp nhất** trong tập hợp (tức PENDING).

### 4.4. `Đánh giá` — Căn cứ Dedup và Reuse

- `Dễ`: Lấy 1:1 từ nguồn.
- `TB`: Có tính toán tổng hợp cơ bản.
- `Khó`: Logic phức tạp, kết hợp nhiều mốc thời gian.
- **`Trùng`**: Đã có tính thông tin này trong phạm vi phân hệ khác hoặc nhóm khác -> Căn cứ reuse `KPI_ID` hiện hữu.

---

## 5. Các Bẫy Parse Cần Tránh

1. **Bẫy Newline trong Ô Quoted:**
   Cột SQL tham khảo hoặc Mô tả chứa nhiều ký tự xuống dòng `\n`. Không bao giờ đọc dòng thô bằng `readline()` hay `splitlines()`. Luôn dùng `csv.reader` với `open(..., newline='')` để Python tự quản lý unescape.
2. **Bẫy Encoding & BOM:**
   Các file CSV export từ Excel tiếng Việt thường có UTF-8 BOM (`\xef\xbb\xbf`). Luôn mở với `encoding='utf-8-sig'`.
3. **Bẫy Tên File Tiếng Việt (`GSĐC` vs `GSDC`):**
   File BA trên đĩa tên là `BA_analyst_GSĐC.csv` (có chữ `Đ`), trong khi Datamart LLD/HLD dùng `GSDC` (`DTM_GSDC_HLD.md`). Parser và script phải tự động chuyển đổi qua lại giữa `GSĐC` và `GSDC`.
4. **Bẫy Header Lặp trong Data:**
   Nhiều file BA có dòng header thứ 2 nằm ngay ở dòng data đầu tiên (chứa chữ `Phân loại` hoặc `STT`). Luôn loại bỏ các dòng này trước khi đếm hoặc phân tích:
   `if row[pl_idx].strip().lower() == 'phân loại': continue`.
5. **Bẫy Delimiter Không Cố Định:**
   Không bao giờ giả định file BA dùng `;`. Phải chạy hàm tự động dò delimiter như mô tả ở Mục 1.

---

## 6. Snippet Chuẩn Đọc BA — Sử dụng cho Script và Review

**Không viết lại parser nữa.** Toàn bộ logic đọc BA nằm ở `datamart_common/ba_parser.py`:

```python
from datamart_common.ba_parser import (parse_ba_file, profile_for, group_ba_items,
                                       resolve_ba_path, list_ba_modules)

path  = resolve_ba_path(root, "QLKD")          # xử lý FMS, GSĐC/GSDC, NĐTNN/NDTNN
prof  = profile_for(root, "QLKD")              # đọc system/rules/ba_column_profile.yaml
items, meta = parse_ba_file(path, prof)        # -> (List[BAItem], BAFileMeta)
groups = group_ba_items(items)                 # -> OrderedDict[khoá Nhóm, List[BAItem]]
```

- `BAItem` có `line_num` (truy vết về dòng gốc), `stt` (**chính là khoá Nhóm**, đã áp dụng logic
  suy ra từ `STT`/`Mã`), `raw_row`, và 13 trường nghiệp vụ đã resolve qua `COLUMN_ALIASES`.
- `BAFileMeta` có `delimiter`, `header_row`, `legend_rows`, `header`, `profile_source`
  (`"yaml"` khi dùng profile, `"heuristic"` khi phân hệ chưa khai trong YAML), `warnings`.
- Profile lệch với file thật → ném `BaProfileMismatch`. **Không bắt ngoại lệ này để đi tiếp** —
  nó có nghĩa file BA đã đổi cấu trúc và profile phải được cập nhật trước.
- Muốn lát cắt sẵn dùng cho ngữ cảnh, gọi CLI thay vì tự render:
  `python .claude/skills/datamart-review/scripts/ba_slice.py --module QLKD --nhom 8 --print`

Bản dò động cũ (`_legacy_detect`) vẫn còn trong `ba_parser.py` nhưng **chỉ chạy khi phân hệ chưa
có trong profile**, và luôn kèm cảnh báo. Đừng gọi trực tiếp.

---


## 7. Con số Kỳ vọng Khảo sát Toàn bộ 11 Phân hệ

Dùng để đối chiếu và kiểm tra tính toàn vẹn khi chạy parser:

| Phân hệ | File BA | Delimiter | Dòng Header | Số cột | Số dòng CSV thô | Số chỉ tiêu hợp lệ |
|---|---|---|---|---|---|---|
| **QLKD** | `BA_analyst_QLKD.csv` | `,` | Dòng 1 | 28 | 4.292 | **4.276** |
| **FMS** | `BA_analyst_FMS.csv` | `;` | Dòng 1 | 31 | 2.672 | **2.671** |
| **TKNB** | `BA_analyst_TKNB.csv` | `,` | Dòng 1 | 29 | 1.198 | **1.197** |
| **GSĐC** | `BA_analyst_GSĐC.csv` | `,` | Dòng 1 | 24 | 1.048 | **1.047** |
| **VP** | `BA_analyst_VP.csv` | `;` | Dòng 1 | 27 | 536 | **535** |
| **GSTT** | `BA_analyst_GSTT.csv` | `,` | Dòng 1 | 27 | 492 | **491** |
| **PTTT** | `BA_analyst_PTTT.csv` | `,` | Dòng 1 | 26 | 456 | **455** |
| **NDTNN** | `BA_analyst_NDTNN.csv` | `;` | Dòng 1 | 30 | 260 | **259** |
| **TT** | `BA_analyst_TT.csv` | `;` | Dòng 1 | 26 | 166 | **165** |
| **NHNCK** | `BA_analyst_NHNCK.csv` | `;` | Dòng 1 | 29 | 106 | **106** |
| **QLCB** | `BA_analyst_QLCB.csv` | `,` | Dòng 1 | 23 | 67 | **66** |
| **Tổng** | **11 file** | | | | **11.293** | **11.268** |
