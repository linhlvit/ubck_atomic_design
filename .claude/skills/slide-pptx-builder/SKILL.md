# Skill: slide-pptx-builder

## MỤC ĐÍCH

Chuyển đổi file Markdown nội dung slide → file PowerPoint `.pptx` theo đúng template VIB/FSS chuẩn.

**Trigger**: Dùng khi user muốn tạo slide PowerPoint từ nội dung Markdown.  
Invoke bằng: `/slide-pptx-builder`

---

## CÁC LOẠI LAYOUT HỖ TRỢ

| Loại | Keyword trong MD | Mô tả |
|---|---|---|
| Cover | `## [cover]` | Trang bìa: tiêu đề lớn, nền tối |
| Table of Contents | `## [toc]` | Mục lục dạng danh sách đánh số |
| Section Divider | `## [section]` | Phân trang chương: số + tên chương |
| Content + Image | `## [content]` | Tiêu đề + nội dung text + placeholder ảnh |
| Content (no image) | `## [content-text]` | Tiêu đề + nội dung text thuần |
| Table | `## [table]` | Tiêu đề + bảng Markdown |
| Closing / Q&A | `## [closing]` | Trang kết: chỉ có 1 dòng text lớn |

---

## MD SCHEMA — CÚ PHÁP CHUẨN

```markdown
---
title: Tên file output (không cần .pptx)
client: Tên dự án / client (hiển thị trên cover)
---

## [cover]
# VIB-EDP | Thiết kế Data Model

## [toc]
- Data Layer
- Phương án tổ chức dữ liệu
- Phương pháp luận thiết kế
- Phương án thực hiện
- Áp dụng triển khai thực tế
- Q&A

## [section]
# 1. Data Layer

## [content]
### 1.1 | Kiến trúc Medallion Architecture
Nội dung mô tả ngắn gọn ở đây.
- Bullet point 1
- Bullet point 2

[image: Mô tả ảnh placeholder — người dùng sẽ thêm ảnh sau]

## [content-text]
### 2.1 | Nguyên lý thiết kế
- Tổ chức thông tin theo hướng nghiệp vụ
- Mô hình hóa độc lập với hệ thống nguồn
- Sử dụng Nine Data Concepts làm nền tảng

## [table]
### 3.1 | Bảng so sánh loại bảng
| Loại bảng | Cơ chế lưu trữ | Ghi chú |
|---|---|---|
| Fundamental | SCD Type 2 | Lưu trữ lịch sử thay đổi |
| Associative | SCD Type 2 | Quan hệ giữa các đối tượng |
| Event | Insert-only | Giao dịch, sự kiện |

## [closing]
Q&A
```

### Quy tắc MD

1. **Frontmatter bắt buộc**: `title` và `client` ở đầu file.
2. **Mỗi slide = 1 `##` block**. Không lồng nhiều layout trong 1 block.
3. **Số slide + tiêu đề**: Trong `[content]` và `[table]`, dùng `### {số} | {tiêu đề}`. Ví dụ: `### 1.1 | Kiến trúc Medallion`.
4. **Placeholder ảnh**: Dùng `[image: mô tả]` — script sẽ vẽ hộp xám với text mô tả.
5. **TOC**: Liệt kê tên chương bằng dấu `-`, không cần đánh số (script tự đánh số).
6. **Section**: Dùng `# {số}. {tên chương}`. Ví dụ: `# 1. Data Layer`.

---

## QUY TRÌNH THỰC HIỆN

### Bước 1 — Nhận yêu cầu

Khi user gọi `/slide-pptx-builder`, hỏi:
1. Nội dung slide (có sẵn MD chưa, hay cần Claude soạn trước?)
2. Tên file output mong muốn
3. Thư mục lưu output (mặc định: `docs/output/slides/`)

### Bước 2 — Soạn nội dung MD (nếu cần)

Nếu user chưa có MD, Claude soạn nội dung theo schema ở trên dựa trên yêu cầu của user.  
Trình bày MD để user review và confirm trước khi chạy converter.

### Bước 3 — Chạy converter

```bash
python3 .claude/skills/slide-pptx-builder/md_to_pptx.py \
  --input <path_to_md_file> \
  --output <output_path.pptx> \
  --template .claude/skills/slide-pptx-builder/template.pptx
```

Hoặc inline (không cần lưu file MD):

```bash
python3 .claude/skills/slide-pptx-builder/md_to_pptx.py \
  --input-text "<md content>" \
  --output docs/output/slides/MySlide.pptx \
  --template .claude/skills/slide-pptx-builder/template.pptx
```

### Bước 4 — Báo kết quả

- Thông báo đường dẫn file output.
- Nhắc user: các slide có `[image: ...]` → mở PowerPoint và thay thế placeholder bằng ảnh thật.
- Nhắc user kiểm tra font (nếu máy chưa cài font Calibri/Arial).

---

## LƯU Ý KỸ THUẬT

- **Template**: File `template.pptx` trong cùng thư mục skill là file VIB mẫu. Script đọc background/theme từ đây.
- **python-pptx**: Script yêu cầu `python-pptx`. Nếu chưa cài: `pip install python-pptx`.
- **Ảnh placeholder**: Màu xám `#CCCCCC`, có text mô tả ở giữa.
- **Font size mặc định**: Cover=64pt, Section=64pt, Title=38pt, Body=17pt, Caption=22pt.
- **Màu brand**: Nền tối `#000000`, text sáng `#F2F2F2`, accent vàng `#E5C243`.
