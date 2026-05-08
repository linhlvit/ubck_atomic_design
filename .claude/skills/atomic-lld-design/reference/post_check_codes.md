# Post-check codes — chi tiết C1–C5 + Source Coverage

## post_check_atomic.py — C1 đến C5

```bash
python Atomic/lld/scripts/post_check_atomic.py
```

Script kiểm tra 5 tiêu chí và in báo cáo — không sửa file nào.

| Check | Mô tả | Nguyên nhân phổ biến | Hành động |
|---|---|---|---|
| C1 | Source không map được attr nào | Source mới thêm vào manifest chưa có file attr | Tạo file attr cho source đó, chạy lại aggregate |
| C2 | Thông tin liên lạc/địa chỉ trong entity chính | Quên tách shared entity ở Bước 4 | Tách trường sang IP Postal/Electronic Address, xóa khỏi entity chính |
| C3 | Cùng tên attr nhưng data_domain khác nhau giữa các entity | Typo hoặc copy sai data domain từ entity khác | Sửa domain về giá trị chuẩn trong 12 Data Domain |
| C4 | PK có nullable=true | Copy sai từ trường khác | Đặt `nullable=false` cho PK |
| C5 | source_column không đúng 3 phần | Thừa schema (VD: `SCMS.scms.table.col`) hoặc thiếu source prefix | Sửa về đúng `SOURCE.table.column` |

## post_check_source_coverage.py

Kiểm tra cột nguồn chưa được map vào Atomic cho các bảng đã thiết kế:

```bash
# Tất cả nguồn
python Atomic/lld/scripts/post_check_source_coverage.py

# 1 nguồn
python Atomic/lld/scripts/post_check_source_coverage.py --source SCMS

# 1 bảng
python Atomic/lld/scripts/post_check_source_coverage.py --table CTCK_THONG_TIN
```

Script đọc `Source/{SOURCE}_Columns.csv`, so sánh với `atomic_attributes.csv`, báo cáo cột chưa map. Bỏ qua group=pending trong manifest và bỏ qua cột kỹ thuật/audit tự động.

| Loại cột báo cáo | Nguyên nhân phổ biến | Hành động |
|---|---|---|
| Cột nghiệp vụ thực sự chưa map | Bỏ sót khi thiết kế | Tạo/cập nhật attr file, chạy lại aggregate |
| Cột liên lạc/địa chỉ (DIEN_THOAI, EMAIL, DIA_CHI...) | Chưa tạo shared entity | Tạo file IP Postal/Electronic Address, thêm vào manifest |
| FK đến bảng khác (ID, *_ID) | FK thuần — giá trị đã capture qua entity cha | Bỏ qua, ghi chú "FK only" nếu cần |
| Cột out-of-scope theo business | Cố ý không map | Thêm vào `SKIP_COLUMNS` trong script HOẶC document trong `pending_design.csv` |
| Cột audit/kỹ thuật chưa có trong SKIP_COLUMNS | Pattern mới của nguồn | Thêm vào `SKIP_COLUMNS` trong script |
