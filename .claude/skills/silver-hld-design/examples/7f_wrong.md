# Mục 7f — Các pattern sai cần tránh

## SAI 1 — Heading sai cấp / sai tiền tố

```markdown
## Bảng out-of-scope (không thiết kế Silver)
```

**Vấn đề:** Cấp `##` thay vì `####`, thiếu tiền tố "7f.". Script `aggregate_out_of_scope.py` parse regex `^#{2,3}\s+7f\b` → không match → bỏ qua section, output csv không có data của source này.

**Đúng:**
```markdown
#### 7f. Bảng ngoài scope
```

## SAI 2 — Bảng thiếu cột "Nhóm"

```markdown
| Source Table | Lý do |
|---|---|
| company_data | Bảng trung gian |
```

**Vấn đề:** Chỉ có 2 cột thay vì 4. Script đọc số cột không đủ → bỏ qua dòng.

**Đúng:** 4 cột `Nhóm | Source Table | Mô tả bảng nguồn | Lý do ngoài scope`.

## SAI 3 — Gộp nhiều bảng vào 1 ô "Source Table"

```markdown
| Cascade drop | data, data_values | ... | Cascade drop từ company_data |
| System | logins, users | ... | Bảng hệ thống |
```

**Vấn đề:** Output csv lấy grain `(source_system, source_table)`. Gộp nhiều bảng = 1 dòng csv với `source_table = "data, data_values"` — vi phạm key uniqueness, không tra cứu được.

**Đúng:** Tách thành dòng riêng cho mỗi bảng:

```markdown
| Cascade drop | data | BCTC cell values (FK company_data) | Cascade drop từ company_data |
| Cascade drop | data_values | Form field values (FK company_data) | Cascade drop từ company_data |
| Operational / System | logins | Tài khoản đăng nhập hệ thống | Bảng hệ thống — không có giá trị nghiệp vụ Silver |
| Operational / System | users | Người dùng hệ thống | Bảng hệ thống — không có giá trị nghiệp vụ Silver |
```

## SAI 4 — Group ad-hoc không có trong danh sách chuẩn

```markdown
| ABC123 | logins | ... | ... |
| Misc | users | ... | ... |
```

**Vấn đề:** Group không nhất quán giữa các source — khó query/group_by trong silver_out_of_scope.csv.

**Đúng:** Dùng group từ `reference/group_classification.md`. Nếu phát sinh group mới → bổ sung vào file reference đó trước khi dùng.

## SAI 5 — Cột "Lý do" mô tả nội dung bảng thay vì lý do

```markdown
| Reference Data | categories | Ngành nghề công ty | Chỉ có Code + Name |
```

**Vấn đề:** "Chỉ có Code + Name" là mô tả dữ liệu, không phải lý do ngoài scope.

**Đúng:** Mô tả lý do quan hệ/cấu trúc:

```markdown
| Reference Data | categories | Ngành nghề công ty | Không có FK inbound từ bảng nghiệp vụ — xử lý thành Classification Value |
```
