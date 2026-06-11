# Review Checklist — 3 Lớp

Checklist chi tiết dùng trong Bước 2 của skill `datamart-review`.

---

## Lớp 1: HLD

```
□ Nhóm có tồn tại trong HLD không?
  → Nếu không: Gap Critical — cần thiết kế HLD (Kịch bản A)

□ Trạng thái nhóm trong HLD vs BA:
  → HLD = PENDING + BA = Done → Kịch bản A (gọi datamart-hld-design)
  → HLD = PENDING + BA = Pending → OK (đúng tình trạng)
  → HLD = READY + BA = Done → tiếp tục review Lớp 2 và 3
  → HLD = READY + BA có KPI mới chưa có trong HLD → Gap (cần cập nhật HLD)

□ KPI coverage BA → HLD: mọi KPI Done/Doing trong BA có KPI_ID trong bảng KPI HLD?
  → Sót KPI → Warning hoặc Critical tuỳ mức độ

□ KPI Pending: tất cả KPI Pending trong BA có được ghi nhận trong block PENDING?
  → Thiếu → Warning

□ Chiều (Slicer/Filter): mọi dòng BA Phân loại = "Chiều" có KPI_ID?
  → Thiếu → Warning

□ KPI coverage HLD → BA (chiều ngược — bắt buộc): mọi KPI_ID trong HLD phải
  có thể truy về ít nhất 1 dòng trong BA analyst (theo tên KPI hoặc mô tả).
  → KPI_ID trong HLD không tìm thấy trong BA → KPI dư, cần xác nhận với BA
  → Nếu BA confirm không có → xóa khỏi HLD và Detail Mapping
  → Không được giả định KPI hợp lệ chỉ vì nó đã có trong HLD

□ Grain: mô tả grain rõ ràng, khớp với logic BA?
  → Grain mơ hồ → Warning

□ Bảng Fact/Dim đủ để phản ánh tất cả dimension trong BA?
  → Thiếu Dim → Critical nếu ảnh hưởng aggregate, Warning nếu chỉ là filter
```

---

## Lớp 2: Attributes (Atomic → Datamart)

```
□ Bảng Fact/Dim của nhóm có trong Attributes không?
  → Không có → Critical (LLD chưa thiết kế)

□ Mọi KPI Done trong BA có cột tương ứng trong Attributes?
  → Thiếu cột → Critical

□ source_entity + atomic_table + atomic_column điền đầy đủ?
  → Trống với etl_logic_type ≠ pending → Warning

□ Trace BA → Atomic → Attributes (bắt buộc mọi KPI Done):
  → Lấy tên bảng nguồn BA ghi (VD: IDS.data) → tra atomic_attributes.csv
  → atomic_table + atomic_column trong Attributes có khớp kết quả tra không?
  → Không khớp → Critical (map sai Atomic entity/column)
  → Không tìm thấy trong atomic_attributes.csv → Gap Atomic (ghi nhận riêng)

□ etl_logic nội dung đúng với BA:
  → JOIN đúng bảng?
  → Filter condition khớp BA (VD: row_code = 'X', entp_tp_code = 'dn')?
  → Aggregation đúng phép tính?
  → Sai/thiếu → Critical/Warning tuỳ ảnh hưởng

□ Data domain / data_type khớp tính chất KPI:
  → Số tiền → Currency Amount / float
  → Tỷ lệ → Percentage / float
  → Đếm → Small Counter / int
  → Text → Text / string
  → Sai → Warning

□ Key constraints:
  → FK nullable = false?
  → PK/NK/BK nullable = false?
  → Cột từ LEFT JOIN nullable = true?
  → Vi phạm → Warning

□ src_stm_code cho Dim/Operational:
  → Thiếu → Warning
  → Có nhưng thiếu WHERE filter → Info (forward-compat)

□ Fact No-Driving-Table không có src_stm_code?
  → Có thừa → Info
```

---

## Lớp 3: Detail Mapping (Datamart → Báo cáo)

```
□ Mọi KPI_ID trong HLD (Done/Doing) có dòng trong Detail Mapping?
  → Thiếu → Critical

□ KPI Pending: có dòng trong Detail Mapping với mart_table/mart_column/logic trống?
  → Thiếu → Warning

□ Trace BA → Detail Mapping (bắt buộc mọi KPI Done):
  → Lấy công thức/filter BA (aggregation, điều kiện lọc, derived formula)
  → Đối chiếu với logic trong Detail Mapping:
      Aggregation: BA ghi SUM → logic phải SUM (không được COUNT)
      Filter: BA ghi "loại hình BCTC = Kiểm toán" → logic phải có WHERE tương ứng
      Derived: BA ghi "A/B" → column_role = DERIVED, mart_table/mart_column trống
  → Sai/thiếu → Critical/Warning tuỳ mức độ ảnh hưởng kết quả báo cáo

□ Phân tầng filter BA → Attributes vs Detail Mapping:
  → Filter xác định GRAIN của Fact/Dim (entp_tp_code, report_cd LIKE..., src_stm_code)
    → nằm ở Attributes etl_logic — KHÔNG cần lặp lại trong Detail Mapping logic
  → Filter phân biệt KPI trong cùng 1 bảng (row_dsc_clmn_code, clmn_code, loại giao dịch...)
    → phải có trong Detail Mapping logic
  → Khi BA filter không thấy trong DM: tra Attributes xem đã được áp ở etl_logic chưa
    → Đã có trong Attributes → OK (phân tầng đúng)
    → Không có ở cả 2 nơi → Critical (filter bị mất)

□ Trace ngược Detail Mapping → Attributes:
  → mart_table.mart_column trong logic có tồn tại trong Attributes không?
  → Không tồn tại → Critical

□ column_role đúng:
  → MEASURE: phép tính thuần (không lẫn condition)
  → SLICER: dimension hiển thị để group by
  → FILTER: dimension dùng lọc không hiển thị
  → DERIVED: công thức tính từ MEASURE khác, mart_table/mart_column trống
  → Sai → Warning

□ mart_table dùng tên logical (không phải physical)?
  → Physical name trong logic → Warning

□ Chiều lặp lại giữa các nhóm: mỗi nhóm có explicit SLICER/FILTER riêng?
  → Dùng shorthand "xem nhóm X" → Warning

□ Không có KPI_ID chưa được khai sinh trong HLD?
  → Có → Critical (vi phạm gate rule)
```

---

## Tổng hợp mức độ vấn đề

| Mức | Ký hiệu | Định nghĩa | Ví dụ |
|---|---|---|---|
| Critical | 🔴 | Logic sai, thiếu thiết kế — ảnh hưởng trực tiếp kết quả báo cáo | Thiếu bảng Fact, sai công thức aggregate, KPI không có trong LLD |
| Warning | 🟡 | Logic thiếu hoặc không đầy đủ — báo cáo có thể chạy nhưng sai số hoặc thiếu chiều | Thiếu filter condition, thiếu Dim cho nhóm KPI |
| Info | 🔵 | Không ảnh hưởng logic, cần cải thiện kỹ thuật | Thiếu WHERE filter src_stm_code, tên không nhất quán |
