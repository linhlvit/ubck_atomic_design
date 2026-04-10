# Skill: Thiết kế HLD (High-Level Design)

Đọc file này TRƯỚC KHI bắt đầu thiết kế HLD cho bất kỳ source system nào.

## QUY TRÌNH THIẾT KẾ HLD

### Bước 1 — Thu thập input

1. Đọc file cấu trúc CSDL nguồn trong `Source/` — file `*_Tables` và `*_Columns`.
2. Xác định danh sách bảng nguồn trong scope.
3. Đọc các file HLD đã có trong `docs/approved/` (nếu có source system liên quan).

### Bước 2 — Phân tầng (Tiered Design)

Thiết kế nền móng trước, xây dựng quan hệ sau. Mỗi tầng = 1 file md riêng.

**Phân tầng:**
- **Tầng 1 — Main Entities**: Bảng có ý nghĩa độc lập, không FK đến bảng nghiệp vụ khác (chỉ FK đến bảng danh mục). Thiết kế và thống nhất trước.
- **Tầng 2 — Phụ thuộc Tầng 1**: Bảng có FK đến main entity (Tầng 1).
- **Tầng 3+ — Phụ thuộc tầng trước**: Bảng có FK đến entity Tầng 2 trở lên.
- **Tầng ETL Pattern**: Snapshot / Audit Log — luôn phụ thuộc entity chính.

**Xác định ngoài scope:**
- Bảng **thực sự isolated** (không FK đến và không FK từ bất kỳ bảng nghiệp vụ nào trong scope) → ngoài scope Silver.
- Bảng có FK đến main entity nhưng không có entity nào phụ thuộc → vẫn trong scope (leaf entity).
- Bảng **chưa có cấu trúc trường** (không có thông tin cột) → **không thiết kế**, ghi nhận vào file đầu ra để theo dõi.

### Bước 3 — Trace dependency cho mỗi bảng

Với mỗi bảng trong tầng đang thiết kế:
1. **Outbound FK**: Bảng này trỏ đến đâu?
2. **Inbound FK**: Bảng nào trỏ đến bảng này?
3. Xác định FK đến bảng nào là bảng nghiệp vụ (→ dependency), bảng nào là danh mục (→ Classification Value).

### Bước 4 — Tra BCV và đề xuất Silver entity

**BẮT BUỘC tra cứu BCV trước khi gán concept.** Không suy luận từ tên bảng nguồn.

Quy trình tra BCV:
1. Đọc mô tả bảng nguồn → xác định ý nghĩa nghiệp vụ.
2. Dùng `grep -i "<keyword>" knowledge/terms.csv` để tìm term phù hợp.
3. Kiểm tra `grep "<term_name>" knowledge/term_relationships.csv` để hiểu quan hệ.
4. Xác định Core Object và Category.

**Xác định BCV Concept từ nội dung term, không từ category:**
Một BCV term có thể nằm trong category không trùng với Data Concept thực sự của entity (ví dụ: term mô tả quan hệ Involved Party nhưng xếp vào category Group). Khi đó, đọc nội dung mô tả của term để xác định Data Concept — chọn concept chi tiết nhất phù hợp với nội dung. Ví dụ: "Involved Party Rating" (category Group) mô tả quan hệ Rating Scale áp dụng cho Involved Party → BCV Concept = **[Involved Party]**, không phải [Group].

**Kiểm tra concept bằng cấu trúc trường — KHÔNG chỉ dựa vào tên bảng:**

Sau khi tìm được BCV term candidate, đọc lại danh sách cột của bảng nguồn và tự hỏi: *"Các trường này mô tả thực thể thuộc loại gì?"* Tên bảng khớp với BCV term không đồng nghĩa concept khớp — cấu trúc trường mới là căn cứ quyết định.

**Phân biệt entity concept vs reference data set:**
- Bảng có instance data (người đảm nhận, ngày bắt đầu, trạng thái lifecycle) → entity concept → Silver entity.
- Bảng chỉ có Code + Name, không có instance data → reference data set → Classification Value.
- Kiểm tra: `grep -i "<term>" knowledge/reference_data_sets.csv` — nếu có reference data set tương ứng → Classification Value.

**Pure junction table giữa entity và Classification Value:**
Bảng chỉ có 2 trường nghiệp vụ — 1 trỏ đến entity chính, 1 trỏ đến bảng danh mục (các trường kỹ thuật như CreatedBy, DateCreated bỏ qua khi đánh giá) — không có attribute nghiệp vụ riêng → **không tạo Silver entity**. Denormalize thành trường `ARRAY<Classification Value Code>` trên entity chính. Data domain = **Classification Value**, data type = `Array`.

**Đặt tên Silver entity:** Pattern [Domain Prefix] + [BCV Term].
- Tất cả entity cùng nhóm nghiệp vụ phải dùng chung prefix.
- Entity con phải chứa đầy đủ tên entity cha (substring liên tục).
- Khi bảng nguồn chứa nhiều loại đơn vị (VD: CN + VPĐD, CN + PGD), dùng BCV Term chung thay vì tên loại cụ thể từ bảng nguồn. Ví dụ: bảng chứa cả CN lẫn VPĐD → đặt hậu tố "Organization Unit", không đặt "Branch".

### Bước 5 — Rà soát shared entity

Với mỗi entity thuộc concept [Involved Party], kiểm tra:
- Có trường địa chỉ? → IP Postal Address
- Có trường liên lạc (phone, email, fax)? → IP Electronic Address
- Có trường giấy tờ định danh (CCCD, giấy phép)? → IP Alt Identification

**Điều kiện grain:**
- Grain = 1 Involved Party (1 dòng = 1 tổ chức/cá nhân) → **bắt buộc tách** ra shared entity.
- Grain không phải Involved Party (1 dòng = 1 báo cáo, 1 hồ sơ, 1 giao dịch) → **giữ denormalized**, không tách.

### Bước 6 — Xuất file HLD

**Tên file:** `<SOURCE_SYSTEM>_HLD_Tier<N>.md`

**Nội dung bắt buộc:**

#### 6a. Bảng tổng quan BCV Concept

Cấu trúc tối thiểu:

| BCV Concept | Category | Source Table | Mô tả bảng nguồn | Silver Entity | Ghi chú |
|---|---|---|---|---|---|

- Cột "Mô tả bảng nguồn" lấy từ tài liệu thiết kế CSDL nguồn — không tự viết lại.
- Chỉ liệt kê entity mới của tầng đang thiết kế, không lặp entity tầng trước.
- Classification Value không xuất hiện ở đây — ghi riêng trong mục Danh mục & Tham chiếu.
- Cột "BCV Term" viết đủ 3 phần: (1) term candidate tìm được và BCV mô tả gì, (2) đánh giá cấu trúc trường bảng nguồn nói gì, (3) lý do chọn term cuối. Nếu term candidate không khớp với cấu trúc trường → nêu rõ tại sao không dùng và chọn term nào thay thế.

#### 6b. Diagram Source (Mermaid)

Thể hiện quan hệ FK giữa các bảng nguồn trong scope. Không mô tả bảng Classification Value.

#### 6c. Diagram Silver (Mermaid)

Thể hiện Silver entities và quan hệ. Entity từ tầng trước xuất hiện dạng **node tham chiếu** (chỉ ghi tên, không mô tả lại). Không mô tả bảng Classification Value.

#### 6d. Mục Danh mục & Tham chiếu (Reference Data)

Liệt kê các bảng nguồn được propose thiết kế vào Classification Value, kèm Scheme Code dự kiến.

#### 6e. Bảng chờ thiết kế

Liệt kê các bảng trong scope nghiệp vụ nhưng chưa có cấu trúc trường — chưa thể thiết kế Silver entity. Cấu trúc tối thiểu:

| Source Table | Mô tả bảng nguồn | Lý do chưa thiết kế |
|---|---|---|
| ... | ... | Chưa có thông tin cột |

#### 6f. Điểm cần xác nhận

Ghi rõ các vấn đề cần review: entity chưa chắc chắn, scope mờ, dependency chéo tầng...

**Quy tắc trình bày:**
- Không so sánh version (không ghi "so với v1", "thay đổi so với v1").
- Nếu cần ghi chú → ghi dạng fact, không đặt trong ngữ cảnh so sánh.

## FILE HLD TỔNG HỢP

Sau khi tất cả tầng đã thống nhất, tạo 1 file tổng hợp:
- Tên: `<SOURCE_SYSTEM>_relationship_diagram.md`
- Gộp toàn bộ nội dung từ các file Tier.
- Đây là bản chính thức (official).

## QUY TẮC REFERENCE GIỮA CÁC TẦNG

- Diagram Silver ở tầng N: entity tầng trước = node tham chiếu (chỉ tên).
- Bảng BCV Concept ở tầng N: chỉ entity mới.
- Phát hiện cần điều chỉnh tầng trước → ghi "Điểm cần xác nhận", không tự sửa.
