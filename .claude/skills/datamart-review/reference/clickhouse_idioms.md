# Idiom ClickHouse trong Detail Mapping (QLQ & module viết `logic` kiểu ClickHouse) — luật A33

Nguồn: phiên QLQ 2026-10-28 (SQL dev Nhóm 6/7, kiểm trên flat `qlq_fct_fund_management_rpt_cell_val_flat`). Máy kiểm: Gate 8 D20/D21.

| Oracle/pseudo-SQL (BA) | ClickHouse (dev, Detail Mapping) | Vì sao |
|---|---|---|
| `LOWER(x) LIKE '%hoạt động%'` | `lowerUTF8(x) LIKE '%hoạt động%'` | `lower` của ClickHouse chỉ hạ chữ ASCII; 'HOẠT ĐỘNG' không khớp |
| `col = 'Kỳ báo cáo'` (nhãn cột eForm) | `trimBoth(splitByString(' >> ', ifNull(col, ''))[1]) = 'Kỳ báo cáo'` | nhãn thật có khoảng trắng thừa hoặc dạng `'… >> Kỳ báo cáo'` (so khớp chính xác chỉ lấy 18/131 quỹ BCTaiSan) |
| `ROW_NUMBER() OVER (PARTITION BY a,b ORDER BY submitted_dt DESC) = 1` trong WHERE | `ORDER BY submitted_dt DESC LIMIT 1 BY a, b` | cùng ngữ nghĩa, đúng cú pháp |
| `GROUP BY year, month` của dim ngày | `GROUP BY toStartOfMonth(rpt_period_end_cdr_dt)` + lọc `:date_from`–`:date_to` | trục tháng không cần LOOKUP dim |
| `LAST_DAY(d)` | `toLastDayOfMonth(d)` | |
| `SUM(x)` (Decimal) | `toFloat64(sum(x))` hoặc `toFloat64(round(sum(toDecimal256(x, 10)), 2))` | theo SQL dev của từng Nhóm — không tự thống nhất |
| `ROW_NUMBER() … ORDER BY d ASC = 1` (kỳ sớm nhất) | `argMin(v, d)` | |
| `NULLIF(a,0)` | `nullIf(a, 0)` | |

## Truy vấn chẩn đoán nhãn cột — chạy trên flat TRƯỚC khi đổi Nhóm khác (Nhóm 1, 17–21, 24 còn so khớp chính xác)

```sql
SELECT fmr_sheet_nm, record_tp,
       countIf(column_label_nm = 'Kỳ báo cáo') AS exact_cnt,
       countIf(trimBoth(splitByString(' >> ', ifNull(column_label_nm, ''))[1]) = 'Kỳ báo cáo') AS prefix_cnt
FROM default.qlq_fct_fund_management_rpt_cell_val_flat
WHERE period_tp_code = '3'
GROUP BY fmr_sheet_nm, record_tp
HAVING prefix_cnt > exact_cnt
ORDER BY prefix_cnt - exact_cnt DESC
```
Dòng nào hiện ra là sheet mà so khớp chính xác đang bỏ sót. Nhóm 8 dùng nhãn `'Tổng giá trị'` (sheet BCDanhMucDauTu): thay `'Kỳ báo cáo'` bằng nhãn đó và kiểm thêm **quỹ có > 1 ô khớp mỗi tháng** (nhãn cha nhiều cột con làm prefix khớp nhiều ô).

## Bẫy khi nhận SQL từ dev
- Dev có thể dán nhầm bản cũ (QLQ Nhóm 7, 2026-10-28: 2 lần). Nếu SQL mới **mâu thuẫn** điều đã kiểm cùng ngày ở Nhóm anh em → hỏi bản nào mới nhất trước khi ghi.
- Ngày cố định trong truy vấn thử (`date'2026-01-01'`) = tham số `:date_from`/`:date_to` trong Detail Mapping.
- 'BA cũng làm vậy' (hệ số ×1e9 GDP): đối chiếu `ba_slice.py --with-sql`; BA không có → ghi 'BA chưa có'.
