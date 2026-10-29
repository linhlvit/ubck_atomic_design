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

## Vị trí nhãn trong `column_label_nm` tùy sheet; tên cột trong SQL BA là alias theo vị trí (2026-10-29, O_QLQ_57/58)
- `column_label_nm` nối mọi nhãn phủ cột của ô bằng `' >> '` từ hàng 0 xuống. **Đừng chọn `[1]` hay `[-1]` theo thói quen** — đếm trước (exact / phần tử đầu / phần tử cuối / bất kỳ) cho đúng (sheet, mã dòng, nhãn):
  - sheet có tên mục hoặc ô gộp phủ cả bảng ở hàng trên (`TinhHinhGiaoDichCCQ_06268`: `II. Tình hình hoạt động đại lý phân phối >> Kỳ báo cáo`) → nhãn tiêu đề ở phần tử CUỐI; `[1]` luôn sai (Datamart trả 0 dòng cho Nhóm 17–21);
  - sheet có nhãn cha đứng đầu (BCTaiSan, BCDanhMucDauTu: `Kỳ báo cáo >> …`) → phần tử ĐẦU đúng; `[-1]` bỏ sót (R7 UAT: 3.288/3.373 và 1.867/3.225).
  Khi chưa kiểm được: `has(arrayMap(x -> trimBoth(x), splitByString(' >> ', ifNull(col, ''))), 'nhãn')` (khớp bất kỳ phần tử).
- **Tên cột trong SQL BA (`AS "Tổng"`, `AS "Số lượng hợp đồng"`, `AS "Kỳ báo cáo"`) là alias theo VỊ TRÍ** (`max(CASE WHEN col_idx = N THEN vl END) AS "…"`), không phải chữ tiêu đề trong sheet. Đọc `col_idx` trong khung BA rồi đối chiếu Atomic `column_index` (đánh số từ 0). Khung BA Nhóm 1/24 có vẻ đánh số từ 1 (STT = 1), khung tester Nhóm 17–21 từ 0 — kiểm bằng cột của nhãn 'STT'/'Mã chỉ tiêu' trong `fmr_sheet`. Sự cố: K_QLQ_4/7 so chữ 'Tổng'/'Số lượng hợp đồng' → 0 dòng trên UAT.
- Nhãn dòng: `row_label_nm` nối cả nhãn bên trái (kể cả cột STT); BA thường lọc `LOWER("Chỉ tiêu") LIKE '%…%'` — so bằng chính xác dễ không khớp. Mọi giả định bố cục phải có hit count trên UAT (số dòng khớp > 0) trước khi ghi READY.
