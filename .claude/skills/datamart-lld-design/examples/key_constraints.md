# Key Constraints — Ràng buộc key × loại bảng

> **Đổi quy ước 2026-07-21:** Gộp `NK` (trước đây chỉ dùng trên Dimension) và `BK` (trước đây chỉ
> dùng trên Operational) thành **1 token duy nhất: `BK`** — dùng cho cả Dimension lẫn Operational.
> Lý do: cả hai đều là business key thật (join anchor trên Dimension, natural key trên Operational)
> — tách 2 tên gây nhầm lẫn (mô tả ghi "BK" nhưng cột `key` ghi "NK", như đã xảy ra thực tế ở module
> TT). Ý nghĩa "join anchor cho Fact lookup" (vai trò cũ của NK) vẫn phải ghi rõ trong `description`,
> không mất đi — chỉ không còn là 1 token `key` riêng.
> Áp dụng hồi tố: mọi entry cũ dùng `NK` (NHNCK, QLKD, QLCB, TT) đã được đổi thành `BK`.

> **Đổi quy ước 2026-08-03:** `key` trên Fact chỉ ghi token thuần **`FK`** — KHÔNG kèm tên Dimension
> (`FK → <Dim>` đã lỗi thời). Tên Dimension đích chuyển hoàn toàn vào `description` (VD: "FK —
> Driving Table: Public Company Dimension..." hoặc "FK tới Calendar Date Dimension — ..."). Lý do:
> cột `key` chỉ dùng để phân loại vai trò cấu trúc (PK/BK/FK/DD/trống), không phải nơi diễn giải quan
> hệ — thông tin "trỏ đi đâu" đã có sẵn ở `description` nên lặp lại trong `key` là dư thừa và có thể
> lệch nhau khi 1 trong 2 nơi bị sửa mà quên đồng bộ nơi kia.
> Áp dụng cho thiết kế mới từ 2026-08-03 (GSDC 5 Fact Score Snapshot). Các module cũ (GSTT, QLCB,
> QLKD, TT) vẫn còn dùng `FK -> <Dim>`/`FK → <Dim>` — chưa hồi tố, chỉ sửa khi có yêu cầu riêng.

> **Đổi quy ước 2026-10-23 (A22):** Fact **BẮT BUỘC có đúng 1 `key = PK`** = khóa dòng/khóa MERGE (đảo quy ước 2026-07-21/22 "Fact không có PK"). Dạng A: id dòng Atomic driving
> (`direct`); Dạng B (Fact gộp): hash cột grain (`Generated`, description liệt kê cột grain). Lý do: Fact không khai báo khóa thì grain chỉ là chữ, trôi qua nhiều lần sửa và flat
> ClickHouse `ReplacingMergeTree` gộp mất dòng (sự cố QLKD `fct_securities_company_financial_structure_snpst`). Xem `reference/rules.md` mục A22.

## Bảng tổng hợp

| key | Dimension | Fact | Operational |
|---|---|---|---|
| `PK` | ✅ Surrogate key | ✅ **Bắt buộc, đúng 1** — khóa dòng/khóa MERGE (A22) | ✅ Surrogate key |
| `BK` | ✅ Business key join anchor | ❌ | ✅ Business key |
| `FK` | ❌ | ✅ Surrogate dim key — tên Dimension đích ghi trong `description`, không ghi trong `key` | ❌ |
| `DD` | ❌ | ✅ Degenerate dimension | ❌ |
| (trống) | ✅ Mọi attribute thường | ✅ Measure, date, metadata | ✅ Mọi attribute thường |

---

## Ràng buộc nullable

| key | nullable |
|---|---|
| `PK` | `false` — bắt buộc |
| `BK` | `false` — bắt buộc |
| `FK` | `false` — bắt buộc (trừ trường hợp carry-forward optional, ghi rõ lý do trong `description`) |
| `DD` | Theo business logic (thường `false`) |
| (trống) | Theo business logic |

---

## Ràng buộc data_domain

| data_domain | key bắt buộc | nullable |
|---|---|---|
| `Surrogate Key` | `PK` | `false` |
| `Surrogate Dimension Key` | `FK` | `false` |
| `Classification Value` | **(trống)** — không được có key | Theo business logic |

---

## Ràng buộc etl_logic theo key

| key | etl_logic bắt buộc? |
|---|---|
| `PK` | Dimension/Operational/Fact Dạng B: trống — `source_entity = Generated` (surrogate sinh mới, không map Atomic). **Fact Dạng A (A22): bắt buộc `direct` = id dòng Atomic driving** |
| `BK` | **Bắt buộc đầy đủ** như attribute thường — BK lấy giá trị thật từ Atomic (thường `etl_logic_type = direct` từ driving table). ❌ Không được để trống. |
| `FK` | Bắt buộc — `lookup_dim`/`lookup_date`/`direct` (khi driving table chính là Dimension đích, xem ví dụ Fact bên dưới) |
| `DD` | Bắt buộc — map từ Atomic (thường `direct` hoặc `join_atomic`) |
| (trống) | Bắt buộc, trừ khi `etl_logic_type = pending` |

---

## Ví dụ đúng — Dimension

```csv
datamart_entity,key,data_domain,nullable,etl_logic,etl_logic_type
"Inspection Team Dimension","PK","Surrogate Key","false","","Generated"                                    ← surrogate key, trống hợp lệ
"Inspection Team Dimension","BK","Text","false","inspection_team.inspection_team_code","direct"            ← business join anchor, PHẢI có etl_logic
"Inspection Team Dimension","","Text","false","inspection_team.content","direct"                           ← attribute thường not null
"Inspection Team Dimension","","Classification Value","true","cv.cl_code","direct"                         ← danh mục nullable
"Inspection Team Dimension","","Text","true","inspection_team.remark","direct"                             ← attribute thường nullable
```

---

## Ví dụ đúng — Fact

```csv
datamart_entity,key,data_domain,nullable,description
"Fact FMS Snapshot","PK","Surrogate Key","false","PK — id dòng Atomic driving (direct) = khóa MERGE; grain = 1 dòng Atomic ..."   ← A22 bắt buộc, đầu bảng
"Fact FMS Snapshot","FK","Surrogate Dimension Key","false","FK tới Calendar Date Dimension — ..."
"Fact FMS Snapshot","FK","Surrogate Dimension Key","false","FK tới Fund Management Company Dimension — ..."
"Fact FMS Snapshot","DD","Text","false",""                          ← degenerate dim
"Fact FMS Snapshot","","Small Counter","true",""                    ← measure nullable
"Fact FMS Snapshot","","Currency Amount","true",""                  ← measure nullable
```

> `key` chỉ ghi token `FK` thuần — tên Dimension đích (Calendar Date Dimension, Fund Management
> Company Dimension...) nằm trong `description`, không lặp lại trong `key`.

> ✅ Fact có **đúng 1** `key = PK` (A22) — Dạng A: id dòng Atomic driving, `etl_logic_type = direct`; Dạng B: hash cột grain, `Generated`.
> Ngoài PK, Fact chỉ có `FK`/`DD`/measure; `BK` cấm trên Fact. Cột surrogate `_id` KHÔNG phải PK (key trống) là cột dư — xóa.
> (Lịch sử: TT 2026-07-21 và GSDC 2026-07-22 từng XÓA dòng PK khỏi Fact vì là cột dư; 2026-10-23 đảo lại vì thiếu khóa dòng làm grain trôi và flat mất dòng.)

---

## Quy tắc Date Dimension FK trên Fact table (Role-Playing Date)

**CẤM TUYYỆT ĐỐI** sử dụng `Calendar Date Dimension Id` / `cdr_dt_dim_id` trên Fact table. Cột `cdr_dt_dim_id` CHỈ là PK của bảng `cdr_dt_dim`.

| Loại Fact | Tên bắt buộc (Logical) | Tên bắt buộc (Physical) | Ví dụ |
|---|---|---|---|
| Fact Snapshot (`_snpst`) | `Snapshot Date Dimension Id` | `snpst_dt_dim_id` | `fct_stock_portfolio_snpst` |
| Fact Event/Transaction | `<Role> Date Dimension Id` | `<role>_dt_dim_id` | `trade_dt_dim_id`, `decision_dt_dim_id` |

### Phân biệt với Degenerate Date

Các trường ngày mô tả nghiệp vụ thuần túy (VD: `violation_record_dt`, `first_license_dt`, `birth_dt`) giữ kiểu `date`, `key` để trống, KHÔNG tạo FK và KHÔNG thêm hậu tố `_dim_id`.

---

## Ví dụ đúng — Operational

```csv
datamart_entity,key,data_domain,nullable
"Foreign Investor 360 Profile","PK","Surrogate Key","false"         ← surrogate PK
"Foreign Investor 360 Profile","BK","Text","false"                  ← business key
"Foreign Investor 360 Profile","","Text","true"                     ← attribute thường
"Foreign Investor 360 Profile","","Classification Value","true"     ← danh mục
```

---

## Vi phạm phổ biến và cách fix

### Vi phạm 1 — Fact thiếu PK (A22)

```
❌ Sai:
Fact chỉ có FK / DD / measure, không dòng nào key = PK; grain chỉ ghi bằng chữ trong description.

Vấn đề: không có khóa MERGE/UPSERT; grain trôi qua các lần sửa (thiếu rpt_code, sheet_id, submission…);
flat ReplacingMergeTree ORDER BY (ngày, 1 dim) gộp mất dòng.

✅ Fix: thêm đúng 1 dòng key = PK, nullable = false, data_domain = Surrogate Key, đặt đầu bảng.
  Dạng A: etl_logic = <driving>.<id>, etl_logic_type = direct (VD sc_report_input_value.sc_rpt_input_val_id).
  Dạng B (Fact gộp): Generated, description liệt kê ĐỦ cột grain. Sau đó A20 (flat DDL+DML) và ORDER BY flat chứa PK.
```

### Vi phạm 1b — Cột `_id` surrogate trên Fact nhưng key trống

```
❌ Sai: "fct_x_id","Surrogate Key", key = "" trên Fact
✅ Fix: nếu cột là khóa dòng → gán key = PK (A22); nếu không phải khóa dòng → xóa cột.
```

### Vi phạm 2 — FK trên Dimension

```
❌ Sai:
"Fund Management Company Dimension","FK","Surrogate Dimension Key","false"

Vấn đề: FK chỉ trên Fact. Dimension không join sang Dimension khác.

✅ Fix: Nếu Dimension cần date → lưu date field trực tiếp, không join sang Calendar Date Dim.
"Fund Management Company Dimension","","Date","true"
```

### Vi phạm 3 — Classification Value có key

```
❌ Sai:
"Fund Management Company Dimension","BK","Classification Value","false"

Vấn đề: data_domain = Classification Value không được có key — không join qua Classification Value.

✅ Fix: trống key
"Fund Management Company Dimension","","Classification Value","false"
```

### Vi phạm 4 — nullable = true cho FK

```
❌ Sai:
"Fact FMS Snapshot","FK","Surrogate Dimension Key","true"

Vấn đề: FK không được nullable — mọi Fact row phải có date dimension (trừ carry-forward optional
đã ghi rõ lý do trong description).

✅ Fix: nullable = false
"Fact FMS Snapshot","FK","Surrogate Dimension Key","false"
```

### Vi phạm 5 — BK để trống etl_logic (nhầm với PK)

```
❌ Sai:
"Inspection Team Dimension","BK","Text","false","","",...    ← etl_logic + etl_logic_type trống

Vấn đề: BK là business key THẬT — cần map từ Atomic, không phải surrogate generated như PK.
Để trống etl_logic khiến ETL developer không biết lấy giá trị BK từ đâu.

✅ Fix: điền đầy đủ etl_logic/etl_logic_type như attribute thường
"Inspection Team Dimension","BK","Text","false","inspection_team.inspection_team_code","direct",...
```

### Vi phạm 6 — description dùng token key khác với cột `key` thực tế

```
❌ Sai:
key = "NK", description = "BK — mã hồ sơ đoàn thanh tra..."

Vấn đề: dùng lẫn 2 token khác nhau (NK/BK) cho cùng 1 khái niệm — dấu hiệu quy ước tên chưa rõ ràng.

✅ Fix (sau khi gộp NK+BK thành BK): nhất quán 1 token
key = "BK", description = "BK — mã hồ sơ đoàn thanh tra..."
```

### Vi phạm 7 — PK ghi literal "Generated" vào etl_logic và 4 cột source thay vì để trống

```
❌ Sai (phát hiện thực tế 2026-07-27 — 3 file: foreign_investor_dim, securities_dim, market_index_dim,
cả bản gốc lẫn master datamart_attributes.csv):
"Market Index Dimension","market_index_dim","Market Index Dimension Id","market_index_dim_id","false",
"Surrogate Key","string","PK","PK — Driving: market_index_snapshot",
"Generated","direct","Generated","Generated","Generated","Generated"
                ↑etl_logic  ↑etl_logic_type   ↑source_entity ↑atomic_table ↑source_attribute ↑atomic_column

Vấn đề: PK là surrogate key sinh mới, không map từ Atomic — không có "giá trị SQL" nào cho etl_logic,
và không có atomic_table/source_attribute/atomic_column nào cả. Ghi literal "Generated" vào 5/6 ô này
(kể cả etl_logic_type bị ghi sai thành "direct") là sai định dạng — dù ý nghĩa "đây là PK generated"
không sai, nhưng không khớp convention đã dùng nhất quán ở nơi khác trong cùng dự án.

✅ Đúng (khớp Inspection Team Dimension, Securities Practitioner Dimension đã làm đúng từ đầu):
"Market Index Dimension","market_index_dim","Market Index Dimension Id","market_index_dim_id","false",
"Surrogate Key","string","PK","PK — Driving: market_index_snapshot",
"","Generated","Generated","","",""
     ↑etl_logic TRỐNG  ↑etl_logic_type=Generated  ↑source_entity=Generated  ↑3 cột sau TRỐNG
```

**Quy tắc:** Chỉ 2 ô được điền cho dòng PK: `etl_logic_type = Generated` và `source_entity = Generated`. Mọi ô còn lại liên quan tới "lấy giá trị/cột nguồn từ đâu" (`etl_logic`, `atomic_table`, `source_attribute`, `atomic_column`) phải để trống — vì PK không có nguồn Atomic nào cả.
