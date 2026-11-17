# Tên module tiếng Việt (A.1)

> **Nguồn sự thật = `scripts/doc_registry.py` (`MODULES`)** — bảng dưới đây là bản đọc cho người, đồng bộ với registry
> theo bản mẫu v1.2 (PTTK `Viettel_Review_UBCKNN_Tai_lieu_phan_tich_thiet_ke_v1.2_202611114.docx`,
> TKCSLD `Viettel_Review_UBCKNN_Thiet_ke_co_so_du_lieu_v1.2_20261112_final.docx`). Khi đổi tên/thứ tự: sửa registry TRƯỚC,
> rồi cập nhật bảng này. Kiểm: `python .claude/skills/datamart-gen-docs/scripts/doc_registry.py`.

| X (3.1.X) | Mã module | Tên trong tiêu đề PTTK (`3.1.X  Luồng đồng bộ dữ liệu cho nhóm báo cáo …`) | Tên trong tiêu đề TKCSLD (`3. KHO DỮ LIỆU (OLAP) — …`) | Tiền tố bảng phẳng ClickHouse |
|---|---|---|---|---|
| 1 | TT | hoạt động thanh tra | Hoạt động Thanh tra | `tt_` |
| 2 | NHNCK | người hành nghề chứng khoán | Người hành nghề | `nhnck_` |
| 3 | NDTNN | nhà đầu tư nước ngoài | Quản lý NĐTNN | `ndtnn_` |
| 4 | QLCB | quản lý chào bán | Quản lý chào bán | `qlcb_` |
| 5 | GSDC | giám sát công ty đại chúng | Giám sát Công ty Đại chúng | `gsdc_` |
| 6 | GSTT | giám sát thị trường | Giám sát Thị trường | `gstt_` |
| 7 | QLQ (mã cũ FMS) | công ty quản lý quỹ (AMC) | Công ty Quản lý Quỹ (AMC) | `qlq_` |
| 8 | QLKD | hoạt động công ty chứng khoán | Hoạt động Công ty Chứng khoán | `qlkd_` |
| 9 | PTTT | phân tích thị trường | Phân tích thị trường | `pttt_` |
| 10 | TKNB | thống kê thị trường | Thống kê Thị trường | `tknb_` |
| 11 | VP | văn phòng | Văn phòng | `vp_` |

## Cách dùng

- Tiêu đề PTTK (Heading 3): **chữ thường**, hai dấu cách sau số mục, đúng như bản mẫu v1.2 — VD `3.1.1  Luồng đồng bộ dữ liệu cho nhóm báo cáo hoạt động thanh tra`. (Bản Q5 cũ viết HOA toàn bộ; bản v1.2 KHÔNG.)
  Script `update_q5_with_datamart_modules.py` tự sinh tiêu đề này từ registry, nên trong `DTM_{M}_PTTK.md` dòng `## 3.1.X …` chỉ cần đúng số mục X.
- Tiêu đề TKCSLD (Heading 1): `# 3. KHO DỮ LIỆU (OLAP) — [Tên TKCSLD]`. Bản mẫu TKCSLD ghi phân hệ VP là "VP" (viết tắt); registry dùng "Văn phòng" cho đồng bộ với PTTK — đổi lại trong registry nếu khách hàng yêu cầu giữ "VP".
- Phân hệ **GSDC** luôn dịch là **Giám sát Công ty Đại chúng** (tuyệt đối không dịch là *Giám sát doanh nghiệp chứng khoán*).
- "Văn phòng" (VP) là phân hệ thống kê thị trường chứng khoán phục vụ báo cáo Lãnh đạo UBCKNN/Bộ Tài chính — khác TKNB (thống kê nội bộ các biểu mẫu thị trường).
- Module chưa có trong bảng → `doc_registry.get_module()` báo lỗi: hỏi Data Modeler số mục X và tên tiếng Việt, thêm vào registry + bảng này rồi mới sinh tài liệu.
