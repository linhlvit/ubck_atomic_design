# Mục 7f — Format đúng

```markdown
#### 7f. Bảng ngoài scope

| Nhóm | Source Table | Mô tả bảng nguồn | Lý do ngoài scope |
|---|---|---|---|
| Intermediate | company_data | Bảng trung gian lưu forms thuộc company_profiles | Intermediate linking table — không có business lifecycle độc lập |
| Junction | noti_config_apply | Junction giữa noti_config và company_profiles | Pure junction table — không có business attribute |
| Cascade drop | data | BCTC cell values (FK company_data) | Cascade drop từ company_data |
| Cascade drop | data_values | Form field values (FK company_data) | Cascade drop từ company_data |
| Operational / System | logins | Tài khoản đăng nhập hệ thống | Bảng hệ thống — không có giá trị nghiệp vụ Silver |
| Operational / System | users | Người dùng hệ thống | Bảng hệ thống — không có giá trị nghiệp vụ Silver |
| Audit Log nguồn | company_profiles_his | Lịch sử thay đổi company_profiles | Bảng lịch sử kỹ thuật — SCD2 Silver tự track |
| Reference Data | categories | Ngành nghề 2 cấp công ty đại chúng | Reference data set — Classification Value scheme IDS_INDUSTRY_CATEGORY |
```

**Đặc điểm format đúng:**
- Heading chính xác: `#### 7f. Bảng ngoài scope` (4 dấu `#`, đúng tiền tố "7f.").
- Bảng đúng 4 cột: `Nhóm | Source Table | Mô tả bảng nguồn | Lý do ngoài scope`.
- Mỗi dòng 1 bảng nguồn (grain `(source_system, source_table)`).
- Group dùng từ danh sách chuẩn (xem `reference/group_classification.md`).
- Lý do mô tả quan hệ/cấu trúc, không mô tả nội dung bảng.
