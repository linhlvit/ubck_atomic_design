# Key Constraints — Ràng buộc key × loại bảng

## Bảng tổng hợp

| key | Dimension | Fact | Operational |
|---|---|---|---|
| `PK` | ✅ Surrogate key | ❌ | ✅ Surrogate key |
| `NK` | ✅ Business key join anchor | ❌ | ❌ |
| `BK` | ❌ | ❌ | ✅ Business key |
| `FK → <Dim>` | ❌ | ✅ Surrogate dim key | ❌ |
| `DD` | ❌ | ✅ Degenerate dimension | ❌ |
| (trống) | ✅ Mọi attribute thường | ✅ Measure, date, metadata | ✅ Mọi attribute thường |

---

## Ràng buộc nullable

| key | nullable |
|---|---|
| `PK` | `false` — bắt buộc |
| `NK` | `false` — bắt buộc |
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

## Ví dụ đúng — Dimension

```csv
datamart_entity,key,data_domain,nullable
"Fund Management Company Dimension","PK","Surrogate Key","false"     ← surrogate key
"Fund Management Company Dimension","NK","Text","false"              ← business join anchor
"Fund Management Company Dimension","","Text","false"                ← attribute thường not null
"Fund Management Company Dimension","","Classification Value","true" ← danh mục nullable
"Fund Management Company Dimension","","Text","true"                 ← attribute thường nullable
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

### Vi phạm 2 — NK trên Operational

```
❌ Sai:
"Foreign Investor 360 Profile","NK","Text","false"

Vấn đề: NK chỉ dùng trên Dimension — Operational dùng BK.

✅ Fix: đổi key = BK
"Foreign Investor 360 Profile","BK","Text","false"
```

### Vi phạm 3 — FK trên Dimension

```
❌ Sai:
"Fund Management Company Dimension","FK → Calendar Date Dimension","Surrogate Dimension Key","false"

Vấn đề: FK chỉ trên Fact. Dimension không join sang Dimension khác.

✅ Fix: Nếu Dimension cần date → lưu date field trực tiếp, không join sang Calendar Date Dim.
"Fund Management Company Dimension","","Date","true"
```

### Vi phạm 4 — Classification Value có key

```
❌ Sai:
"Fund Management Company Dimension","NK","Classification Value","false"

Vấn đề: data_domain = Classification Value không được có key — không join qua Classification Value.

✅ Fix: trống key
"Fund Management Company Dimension","","Classification Value","false"
```

### Vi phạm 5 — nullable = true cho FK

```
❌ Sai:
"Fact FMS Snapshot","FK → Calendar Date Dimension","Surrogate Dimension Key","true"

Vấn đề: FK không được nullable — mọi Fact row phải có date dimension.

✅ Fix: nullable = false
"Fact FMS Snapshot","FK → Calendar Date Dimension","Surrogate Dimension Key","false"
```
