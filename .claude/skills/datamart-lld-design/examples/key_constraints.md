# Key Constraints — Ràng buộc key × loại bảng

> **Đổi quy ước 2026-07-21:** Gộp `NK` (trước đây chỉ dùng trên Dimension) và `BK` (trước đây chỉ
> dùng trên Operational) thành **1 token duy nhất: `BK`** — dùng cho cả Dimension lẫn Operational.
> Lý do: cả hai đều là business key thật (join anchor trên Dimension, natural key trên Operational)
> — tách 2 tên gây nhầm lẫn (mô tả ghi "BK" nhưng cột `key` ghi "NK", như đã xảy ra thực tế ở module
> TT). Ý nghĩa "join anchor cho Fact lookup" (vai trò cũ của NK) vẫn phải ghi rõ trong `description`,
> không mất đi — chỉ không còn là 1 token `key` riêng.
> Áp dụng hồi tố: mọi entry cũ dùng `NK` (NHNCK, QLKD, QLCB, TT) đã được đổi thành `BK`.

## Bảng tổng hợp

| key | Dimension | Fact | Operational |
|---|---|---|---|
| `PK` | ✅ Surrogate key | ❌ | ✅ Surrogate key |
| `BK` | ✅ Business key join anchor | ❌ | ✅ Business key |
| `FK → <Dim>` | ❌ | ✅ Surrogate dim key | ❌ |
| `DD` | ❌ | ✅ Degenerate dimension | ❌ |
| (trống) | ✅ Mọi attribute thường | ✅ Measure, date, metadata | ✅ Mọi attribute thường |

---

## Ràng buộc nullable

| key | nullable |
|---|---|
| `PK` | `false` — bắt buộc |
| `BK` | `false` — bắt buộc |
| `FK → <Dim>` | `false` — bắt buộc |
| `DD` | Theo business logic (thường `false`) |
| (trống) | Theo business logic |

---

## Ràng buộc data_domain

| data_domain | key bắt buộc | nullable |
|---|---|---|
| `Surrogate Key` | `PK` | `false` |
| `Surrogate Dimension Key` | `FK → <Dim>` | `false` |
| `Classification Value` | **(trống)** — không được có key | Theo business logic |

---

## Ràng buộc etl_logic theo key

| key | etl_logic bắt buộc? |
|---|---|
| `PK` | Trống — `source_entity = Generated` (surrogate sinh mới, không map Atomic) |
| `BK` | **Bắt buộc đầy đủ** như attribute thường — BK lấy giá trị thật từ Atomic (thường `etl_logic_type = direct` từ driving table). ❌ Không được để trống. |
| `FK → <Dim>` | Bắt buộc — `lookup_dim`/`lookup_date` |
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
datamart_entity,key,data_domain,nullable
"Fact FMS Snapshot","FK → Calendar Date Dimension","Surrogate Dimension Key","false"
"Fact FMS Snapshot","FK → Fund Management Company Dimension","Surrogate Dimension Key","false"
"Fact FMS Snapshot","DD","Text","false"                             ← degenerate dim
"Fact FMS Snapshot","","Small Counter","true"                       ← measure nullable
"Fact FMS Snapshot","","Currency Amount","true"                     ← measure nullable
```

> ❌ Fact **KHÔNG có `key = PK`** dù có surrogate key. Fact chỉ có `FK`/`DD`/measure — không có
> dòng nào định danh grain bằng surrogate `_id` riêng (bài học module TT 2026-07-21: 7/7 file Fact
> đều sai thêm dòng PK surrogate). Nếu Fact cần 1 cột surrogate id kỹ thuật cho ETL merge/upsert
> (VD: `fct_x_id`), cột đó vẫn để `key` trống — không gán `PK`.

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

### Vi phạm 1 — PK trên Fact

```
❌ Sai:
"Fact FMS Snapshot","PK","Surrogate Key","false"

Vấn đề: Fact table không có Surrogate Key — không tạo PK cho Fact.

✅ Fix: Xóa dòng này. Fact chỉ có FK và measure.
```

### Vi phạm 2 — FK trên Dimension

```
❌ Sai:
"Fund Management Company Dimension","FK → Calendar Date Dimension","Surrogate Dimension Key","false"

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
"Fact FMS Snapshot","FK → Calendar Date Dimension","Surrogate Dimension Key","true"

Vấn đề: FK không được nullable — mọi Fact row phải có date dimension.

✅ Fix: nullable = false
"Fact FMS Snapshot","FK → Calendar Date Dimension","Surrogate Dimension Key","false"
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
