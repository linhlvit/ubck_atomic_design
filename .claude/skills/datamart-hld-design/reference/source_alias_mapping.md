# Source Alias Mapping — BA → Atomic

## Mục đích

BA file thường ghi tên nguồn theo tên nghiệp vụ hoặc tên hệ thống cũ. Atomic LLD dùng tên hệ thống kỹ thuật. Bảng này giúp tự map khi BA ghi tên không khớp với thư mục/prefix trong `Atomic/lld/`.

**Tra bảng này TRƯỚC KHI kết luận PENDING vì không tìm được Atomic entity.**

---

## Bảng alias

| Tên trong BA | Tên Atomic (thực tế) | Ghi chú |
|---|---|---|
| `MSS` | `GSDC` | Market Surveillance System — hệ thống giám sát giao dịch; Source Analysis: `GSDC_Source_Analysis.md` |
| `GSRR` | `QLRR` | Tên gọi cũ của hệ thống quản lý rủi ro; Source Analysis: `QLRR_Source_Analysis.md` |
| `QLRR` | `QLRR` | Tên hiện tại — khớp trực tiếp |
| `NDTNN` | `FIMS` | Tên nghiệp vụ (Nhà đầu tư nước ngoài) → hệ thống FIMS; Source Analysis: `FIMS_Source_Analysis.md` |
| `FIMS` | `FIMS` | Tên kỹ thuật — khớp trực tiếp |
| `OrderTrade` | `MDDS` | Nhóm bảng lệnh/khớp lệnh trong BA → hệ thống MDDS; Source Analysis: `MDDS_Source_Analysis.md` |

---

## Quy trình áp dụng

```
BA ghi nguồn X
    → Tìm trong Atomic/lld/ với prefix X  →  Tìm thấy → dùng trực tiếp
    → Không tìm thấy
        → Tra bảng alias trên
            → Có alias Y → tìm lại với prefix Y → tiếp tục thiết kế bình thường
            → Không có alias → ghi PENDING, nêu lý do "chưa xác định Atomic source cho X"
```

---

## Lưu ý

- Bảng này chỉ bao gồm alias **đã xác nhận** từ thực tế thiết kế. Không suy luận alias mới khi chưa được xác nhận.
- Khi phát hiện alias mới trong quá trình thiết kế → **cập nhật bảng này ngay**.
- `SCMS` — khớp trực tiếp, không có alias.
- `ECAT` — khớp trực tiếp, không có alias.
- `FMS` — khớp trực tiếp, không có alias.
- `IDS` — khớp trực tiếp, không có alias.
