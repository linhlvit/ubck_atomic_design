# Review Checklist — 4 Lớp

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

□ KPI Pending: tất cả KPI Pending trong BA có dòng trong bảng KPI với
  cột Trạng thái = PENDING?
  → Thiếu → Warning
  → LƯU Ý: KHÔNG tìm "block PENDING" riêng — chuẩn hiện hành gộp READY và PENDING
    vào CÙNG 1 bảng KPI, phân biệt bằng cột Trạng thái (đổi 2026-07-23)

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

□ Nhóm reuse toàn bộ Fact/KPI từ Nhóm khác (VD nhóm Data Explorer) vẫn phải có
  **Bảng KPI** markdown đầy đủ 7 cột:
    KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái
  (cột Ghi chú ghi "Reuse từ Nhóm X"), không được thay bằng 1 dòng văn xuôi
  liệt kê ID.
  → Chỉ Star Schema / Lineage / Bảng grain được phép rút gọn thành "giống Nhóm X"
    khi Fact/Dim thực sự dùng chung 100% với Nhóm gốc — Bảng KPI thì KHÔNG được
    rút gọn vì đây là căn cứ duy nhất để trace KPI Done trong BA → KPI_ID trong HLD.
  → Thiếu Bảng KPI (chỉ có câu văn liệt kê) → Warning — yêu cầu bổ sung Bảng KPI
    đầy đủ, giữ nguyên phần Star Schema/Lineage/Bảng grain dạng refer
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
  → Lấy tên bảng nguồn BA ghi (VD: IDS.data) → tra theo ĐÚNG 2 nguồn chuẩn,
    theo thứ tự ưu tiên (giống SKILL.md — không dùng nguồn nào khác):
      Nguồn 1 (luôn tra trước) : DataModel/Atomic/**/*.yaml
      Nguồn 2 (chỉ khi N1 trống): DataModel/working/Atomic/lld/**/*.yaml
      ❌ KHÔNG tra DataModel/working/Atomic_LinhLV/ (track cũ đã revert)
      ❌ KHÔNG tra DataModel/working/Atomic/aggregate/atomic_attributes.yaml
         (nằm ngoài 2 nguồn chuẩn)
  → atomic_table + atomic_column trong Attributes có khớp kết quả tra không?
  → Không khớp → Critical (map sai Atomic entity/column)
  → Không tìm thấy ở cả 2 nguồn → Gap Atomic (ghi nhận riêng)

□ etl_logic nội dung đúng với BA:
  → JOIN đúng bảng?
  → Filter condition khớp BA (VD: row_code = 'X', entp_tp_code = 'dn')?
  → Aggregation đúng phép tính?
  → Sai/thiếu → Critical/Warning tuỳ ảnh hưởng

□ Data domain / data_type khớp tính chất KPI:
  → Số tiền → Currency Amount / decimal  (chốt 2026-08-22 — KHÔNG dùng float
     cho tiền tệ: float là dấu phẩy động nhị phân, gây sai số làm tròn khi cộng dồn.
     Hiện master còn 28 dòng dùng float — nợ kỹ thuật, xem ghi chú cuối mục)
  → Tỷ lệ → Percentage / decimal
  → Đếm → Small Counter / int  (KHÔNG dùng decimal cho số đếm)
  → Text → Text / string
  → Sai → Warning

  ⚠️ Độ chính xác decimal(p,s) CHƯA có chuẩn chốt — master đang dùng lẫn
     decimal(23,2) (109 dòng) / decimal(20,2) (13) cho Currency Amount, và
     decimal(5,2) (43) / decimal(9,4) (40) cho Percentage. Khi review chỉ kiểm
     "có phải decimal không", KHÔNG bắt lỗi độ chính xác cho tới khi chuẩn được chốt.

□ Key constraints:
  → FK nullable = false?
  → PK/BK nullable = false?
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

□ mart_table / mart_column dùng tên LOGICAL?
  → Physical name (snake_case) trong mart_table hoặc mart_column → Warning
  → LƯU Ý: cột `logic` thì NGƯỢC LẠI — bắt buộc dùng physical
    (physical_table.physical_column). Physical name trong `logic` là ĐÚNG chuẩn,
    không phải lỗi. Tên logical trong `logic` → Warning

□ Chiều lặp lại giữa các nhóm: mỗi nhóm có explicit SLICER/FILTER riêng?
  → Dùng shorthand "xem nhóm X" → Warning

□ Không có KPI_ID chưa được khai sinh trong HLD?
  → Có → Critical (vi phạm gate rule)
```

---

## Lớp 4: datamart_model.yaml (Registry cross-module)

```
□ Entity của bảng đang review có tồn tại trong datamart_model.yaml?
  → Không có → Critical (registry thiếu entity — cần bổ sung, không chỉ ghi nhận rồi bỏ qua)

□ Mọi cột trong Attributes detail có mặt 1-1 trong registry (columns của entity)?
  → Thiếu cột trong registry (Attributes có, registry không) → Critical
  → Thừa cột trong registry (đã xóa khỏi Attributes nhưng registry còn) → Critical
    (dấu hiệu hay gặp nhất: cột bị loại bỏ do đổi logic KPI nhưng quên dọn registry)

□ data_domain + data_type của từng cột khớp Attributes?
  → Registry ghi Boolean/boolean trong khi Attributes đã đổi Indicator/string (hoặc ngược lại)
    → Critical — type mismatch ảnh hưởng code-gen/ETL từ registry

□ Cột data_domain = Boolean — có thực sự hợp lệ hay cần đổi Indicator (Y/N)?
  → Tra etl_logic_type: "direct" copy 1-1 từ Atomic column đã là Boolean thật (verify YAML approved,
    thường có comment kiểu "NUMBER(1) — ETL cần convert sang boolean") → Boolean hợp lệ, KHÔNG sửa
  → "computed" bằng biểu thức so sánh/CASE tại tầng Datamart (IN (...), IS NOT NULL, điều kiện...)
    → PHẢI đổi Indicator (Y/N) — biểu thức trả kết quả so sánh runtime, không phải giá trị đã lưu sẵn
  → Không suy luận từ tên cột ("Is X", "Has Y") — luôn tra etl_logic_type trước khi kết luận

□ source_atomic_table/source_atomic_column khớp Attributes VÀ khớp Atomic YAML thật?
  → Không khớp Attributes → Critical (registry lỗi thời)
  → Khớp Attributes nhưng field đó không có thật trong Atomic YAML approved → Critical
    (registry kế thừa lỗi từ Attributes — vẫn phải verify độc lập, không tin theo Attributes)

□ Cột PENDING (gap Atomic) trong Attributes có phản ánh đúng trong registry?
  → source_atomic_table/column phải = null, description ghi rõ PENDING + lý do
  → Registry vẫn trỏ tới Atomic column không tồn tại dù Attributes đã chuyển pending → Critical

□ source_atomic list (đầu entity block) liệt kê đủ mọi Atomic entity dùng trong columns?
  → Thiếu entity phụ (VD: cross-module JOIN) → Warning

□ Physical name nhất quán với Attributes (không viết tắt lỗi thời, không lệch full-word)?
  → Áp dụng quy tắc Physical Naming — registry giữ tên cũ khác Attributes hiện tại → Warning

□ Sau khi sửa registry — YAML còn parse hợp lệ?
  → python3 -c "import yaml; yaml.safe_load(open('Datamart/datamart_model.yaml'))"
  → Lỗi cú pháp → phải sửa ngay, không được để lại
```

---

## Tổng hợp mức độ vấn đề

| Mức | Ký hiệu | Định nghĩa | Ví dụ |
|---|---|---|---|
| Critical | 🔴 | Logic sai, thiếu thiết kế — ảnh hưởng trực tiếp kết quả báo cáo | Thiếu bảng Fact, sai công thức aggregate, KPI không có trong LLD |
| Warning | 🟡 | Logic thiếu hoặc không đầy đủ — báo cáo có thể chạy nhưng sai số hoặc thiếu chiều | Thiếu filter condition, thiếu Dim cho nhóm KPI |
| Info | 🔵 | Không ảnh hưởng logic, cần cải thiện kỹ thuật | Thiếu WHERE filter src_stm_code, tên không nhất quán |
