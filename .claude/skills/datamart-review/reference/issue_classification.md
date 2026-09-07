# Phân loại Vấn đề, Ma trận Đối soát Tiến độ & Cây Phân loại PENDING

Tài liệu này định nghĩa hệ thống phân loại vấn đề trong quy trình review Datamart, bao gồm:
1. Ma trận đối soát tiến độ chéo (Cross-status Matrix: BA Status ↔ Datamart Status).
2. Cây phân loại 6 nhánh chuyên sâu nguyên nhân PENDING.
3. 5 Kịch bản phát hiện vấn đề kỹ thuật (Kịch bản A, B, C, D, E) và quy trình xử lý qua skill con.

---

## 1. Ma trận Đối soát Tiến độ Chéo (Cross-status Matrix)

Ma trận đối soát chéo là công cụ then chốt trong **Macro-Review**, đối chiếu trực tiếp giữa trạng thái phân tích của BA (`Trạng thái mapping`) và trạng thái thiết kế của Datamart:

```
                          ┌───────────────────────────┬───────────────────────────┬───────────────────────────┐
                          │   Datamart READY (Xong)   │  Datamart PENDING (Chờ)   │ Chưa có trong Datamart    │
┌─────────────────────────┼───────────────────────────┼───────────────────────────┼───────────────────────────┤
│ BA = Done               │ 🟢 Khớp hoàn hảo          │ 🔴 Datamart nghẽn         │ 🔴 Thiếu thiết kế         │
│ (Đã phân tích xong)     │ (Đạt chuẩn khai thác)     │ (Cần phân loại nguyên     │ (HLD/LLD chưa tạo dòng)   │
│                         │                           │  nhân PENDING bên dưới)   │                           │
├─────────────────────────┼───────────────────────────┼───────────────────────────┼───────────────────────────┤
│ BA = Doing              │ 🟡 Lệch tiến độ           │ 🟡 Đúng tiến độ           │ ⚪ Đang chờ BA             │
│ (Đang xem xét)          │ (Datamart đi trước BA)    │ (Cả 2 bên đang xử lý)     │ (Chưa thiết kế là đúng)   │
├─────────────────────────┼───────────────────────────┼───────────────────────────┼───────────────────────────┤
│ BA = Pending            │ ⚠️ Bất thường logic       │ 🟢 Khớp tiến độ           │ 🟢 Đúng tình trạng         │
│ (Chưa xác định nguồn)   │ (BA chưa có nhưng DM READY│ (Chờ BA hoàn thành nguồn) │ (Không phát sinh nợ)      │
│                         │  → Cần kiểm tra lại nguồn)│                           │                           │
├─────────────────────────┼───────────────────────────┼───────────────────────────┼───────────────────────────┤
│ Chưa có trong BA        │ ⚠️ KPI phát sinh kỹ thuật │ ⚠️ KPI kỹ thuật PENDING   │ —                         │
│ (Có trong DM, thiếu BA) │ (Cần xác nhận với BA)     │ (Cần rà soát loại bỏ)     │                           │
└─────────────────────────┴───────────────────────────┴───────────────────────────┴───────────────────────────┘
```

---

## 2. Cây Phân loại Chuyên sâu 6 Nhánh Nguyên nhân PENDING

Mọi chỉ tiêu ở trạng thái **PENDING** trong Datamart bắt buộc phải được phân loại chính xác 100% vào đúng 1 trong 6 nhóm nguyên nhân dưới đây để phân định trách nhiệm và hành động tháo gỡ rõ ràng:

```
                            [CHỈ TIÊU PENDING]
                                    │
          ┌─────────────────────────┴─────────────────────────┐
          │ Trạng thái mapping của BA có phải là 'Done'?       │
          └─────────────────────────┬─────────────────────────┘
                       KHÔNG        │         CÓ
         ┌──────────────────────────┘         └──────────────────────────┐
         ▼                                                               ▼
[1. BA Pending]                                  ┌────────────────────────────────────────────────┐
(BA chưa phân tích xong /                        │ Cột nguồn BA có trống, N/A, 'chưa có',         │
 chưa xác nhận nguồn)                            │ hoặc Loại dữ liệu = 'Map biểu mẫu / Chưa CSDL'?│
                                                 └───────────────────────┬────────────────────────┘
                                                              CÓ         │         KHÔNG
                                                ┌────────────────────────┘         └─────────────────────────┐
                                                ▼                                                            ▼
                              [2. Chưa có mapping nguồn BA]                       ┌─────────────────────────────────────┐
                              (Thiếu CSDL nguồn, biểu mẫu                         │ Nguồn có chứa hệ thống ngoại lai    │
                               chưa được số hóa)                                  │ (UAT_VSDC, VSD, SCMS, SBV, v.v.)?   │
                                                                                  └──────────────────┬──────────────────┘
                                                                                       CÓ            │         KHÔNG
                                                                         ┌───────────────────────────┘         └──────────────────────────┐
                                                                         ▼                                                                ▼
                                                       [3. Thiếu nguồn dữ liệu ngoại lai]                     ┌──────────────────────────────────────┐
                                                       (Cần ingest dữ liệu từ ngoài vào DWH)                  │ Nguồn yêu cầu join đa hệ thống       │
                                                                                                              │ phức tạp chưa chuẩn hóa ở Atomic?     │
                                                                                                              └──────────────────┬───────────────────┘
                                                                                                                   CÓ            │         KHÔNG
                                                                                                     ┌───────────────────────────┘         └──────────────────────────┐
                                                                                                     ▼                                                                ▼
                                                                                   [4. Join đa nguồn phức tạp]                        ┌──────────────────────────────────────┐
                                                                                   (Cần Atomic bridge / cross-module)                 │ Có lệch số lượng KPI BA ↔ HLD        │
                                                                                                                                      │ hoặc trỏ Atomic chưa approved?       │
                                                                                                                                      └──────────────────┬───────────────────┘
                                                                                                                                           CÓ            │         KHÔNG
                                                                                                                             ┌───────────────────────────┘         └──────────────────────────┐
                                                                                                                             ▼                                                                ▼
                                                                                                           [6. Lệch số lượng / Schema out of sync]            [5. Datamart Pending]
                                                                                                           (Lệch dòng KPI / Atomic entity lỗi thời)           (Có nguồn nội bộ đầy đủ,
                                                                                                                                                               Datamart chưa thiết kế Fact/Dim)
```

### Chi tiết từng nhánh nguyên nhân:

| Nhóm nguyên nhân | Dấu hiệu nhận biết | Đơn vị chủ trì | Hành động tháo gỡ cụ thể |
|---|---|---|---|
| **1. BA Pending** | BA `Trạng thái mapping` ≠ `Done` (`Pending`, `Doing`, `failed`, hoặc ô trạng thái trống). | **BA Team** | Yêu cầu BA ưu tiên phân tích, xác định quy tắc tính và nguồn dữ liệu. |
| **2. Chưa có mapping nguồn từ BA** | BA đánh `Done`, nhưng `Bảng nguồn` trống, `N/A`, ghi chú "chưa có CSDL", hoặc `Loại dữ liệu` ghi `Chưa có CSDL - Map biểu mẫu`, `Map biểu mẫu`, `Dữ liệu tĩnh - Chưa có CSDL`. | **BA Team** | Đề nghị BA làm rõ nguồn dữ liệu thực tế trong CSDL; nếu là biểu mẫu giấy/báo cáo chưa số hóa thì ghi nhận vào backlog chờ số hóa. |
| **3. Thiếu nguồn dữ liệu ngoại lai** | Bảng nguồn hoặc mô tả tham chiếu các hệ thống bên ngoài: `UAT_VSDC`, `VSD`, `VSDC`, `SCMS_UAT`, `SBV`, `HOSE`, `HNX`, hoặc các chỉ tiêu thị phần, lưu ký chưa có kết nối trực tiếp. | **Data Architecture / Ingestion** | Lập danh mục nguồn ngoại lai cần tích hợp, thiết lập pipeline ingestion đưa dữ liệu vào Data Lake / Staging / Atomic. |
| **4. Join đa nguồn phức tạp** | Yêu cầu kết hợp dữ liệu giữa nhiều hệ thống chưa được chuẩn hóa ở Atomic (ví dụ: `NHNCK` kết hợp `SCMS`, hoặc `IDS` kết hợp `VSDC`). | **Atomic Modeling** | Thiết kế bảng quan hệ kết nối (Bridge / Relationship Entity) tại tầng Atomic trước khi kéo lên Datamart. |
| **5. Datamart Pending** | BA đã `Done`, nguồn dữ liệu nội tại đầy đủ và rõ ràng (IDS, MSS, T24), nhưng Datamart chưa thiết kế Fact/Dim hoặc Detail Mapping còn để trống `mart_table` / ghi chú `pending`. | **Datamart Team** | Gọi `datamart-hld-design` và `datamart-lld-design` để hoàn thành thiết kế Fact/Dim và Detail Mapping. |
| **6. Lệch số lượng / Schema out of sync** | Số lượng dòng KPI trong bảng KPI HLD không khớp với số chỉ tiêu BA của nhóm (thừa/thiếu), hoặc HLD/LLD tham chiếu bảng Atomic đã deprecated / chưa approved trong YAML. | **Datamart Review / HLD** | Chạy đối chiếu từng dòng (0b.3), loại bỏ KPI dư thừa hoặc bổ sung KPI thiếu; cập nhật lại model theo YAML approved hiện hành. |

---

## 3. 5 Kịch bản Phát hiện Vấn đề Kỹ thuật (Micro-Review)

Khi đi sâu vào review kỹ thuật từng nhóm (Micro-Review), các vấn đề phát hiện được phân vào 5 kịch bản sau:

### Kịch bản A — HLD thiếu / PENDING, BA đã Done
- **Dấu hiệu:** HLD không có section cho nhóm này, hoặc HLD ghi `PENDING`, trong khi BA analyst trạng thái = Done với nguồn nội bộ đầy đủ.
- **Hành động:** Gọi skill `datamart-hld-design` để thiết kế section mới hoặc cập nhật HLD.
- **Nguyên tắc:** Không tự viết thêm vào HLD — skill con chịu trách nhiệm đảm bảo cấu trúc 5 Section và bảng KPI 7 cột.

### Kịch bản B — Logic BA thay đổi
- **Dấu hiệu:** BA cập nhật công thức tính KPI (thêm/bớt filter, thay đổi aggregation, đổi grain), thêm bảng nguồn mới, hoặc đổi chiều slicer/filter mà Attributes hoặc Detail Mapping chưa phản ánh.
- **Hành động:** Gọi skill `datamart-lld-design` để cập nhật Attributes.csv và Detail_Mapping.csv.
- **Nguyên tắc:** Không tự ý sửa file — việc sửa đổi logic nghiệp vụ thuộc trách nhiệm của `datamart-lld-design`.

### Kịch bản C — Lỗi kỹ thuật thiết kế
- **Dấu hiệu:** Lỗi không do BA thay đổi logic:
  - Sai `data_domain` hoặc `data_type` (ví dụ: số tiền dùng `float` thay vì `decimal`).
  - Thiếu `WHERE` filter trong `src_stm_code`.
  - `nullable` sai với business rule (FK để nullable = true).
  - Tên cột không nhất quán giữa physical và logical (vi phạm `rule_physical_name_exceptions_datamart.csv`).
  - `etl_logic` tham chiếu trực tiếp cột mart khác (`fct_*.col`) thay vì flatten xuống Atomic.
  - Thiếu bộ 4-5 trường kỹ thuật mặc định SCD4A trên bảng Dimension / Operational (`ds_rcrd_st`, `ds_rcrd_isrt_dt`, `ds_rcrd_udt_dt`, `ds_etl_pcs_tms`, `ds_snpst_dt`).
  - Mệnh đề JOIN vào bảng Atomic Fundamental (SCD4A) thiếu điều kiện lọc bản ghi active `ds_rcrd_st = 'ACTIVE'`.
  - Tồn tại bảng/artifact mồ côi (Orphan Draft Artifact): Bảng Fact/Dim draft từng tạo ở LLD nhưng nay bị loại bỏ khỏi `flat-table` và HLD mà chưa được dọn dẹp sạch sẽ ở `Datamart/lld/`.
  - Bảng KPI HLD thiếu cột (chưa đủ chuẩn 7 cột có cột `Trạng thái`).
  - HLD thiếu Section 4 Reuse Analysis.
- **Hành động:**
  1. Trình bày action đề xuất cụ thể: file, dòng/cột, giá trị cũ → mới, lý do.
  2. Claude DỪNG và chờ human xác nhận rõ ràng.
  3. **Gọi skill con thực hiện** — HLD → `datamart-hld-design`; Attributes / Detail Mapping / `datamart_model.yaml` → `datamart-lld-design`.
- ❌ **Tuyệt đối KHÔNG tự Edit trực tiếp.** Claude chỉ phát hiện, phân loại và đề xuất — việc sửa thuộc skill con.

### Kịch bản D — HLD sai do thiết kế/nguồn Atomic lỗi thời
- **Dấu hiệu:** HLD đã tồn tại, đánh READY, nhưng trỏ nhầm nguồn Atomic đã deprecated/tái cấu trúc, sai grain, sai entity, hoặc logic nghiệp vụ không còn khớp Atomic hiện hành.
- **Hành động:** Gọi `datamart-hld-design` để thiết kế lại — cung cấp đầy đủ bằng chứng đã điều tra (entity Atomic cũ vs mới) để skill con cập nhật đúng.

### Kịch bản E — Review theo issue/bug report
- **Dấu hiệu:** Human hoặc BA báo một vấn đề/lỗi cụ thể trên hệ thống (ví dụ: "thiếu TRADINGTIME", "P/E tính sai") thay vì yêu cầu review toàn module.
- **Hành động:** Chạy quy trình **BƯỚC 0-ALT** (trace đủ 5 tầng: Source → Atomic → HLD → LLD → Flat Table).

---

## 4. Bảng Quyết định Nhanh theo Luồng Review

```
[BẮT ĐẦU REVIEW]
        │
        ├─► [MACRO-REVIEW] Chạy scripts/datamart_progress_analyzer.py
        │         ├─ Xuất Ma trận Đối soát Tiến độ (BA Status ↔ Datamart Status)
        │         ├─ Phân loại 100% PENDING theo Cây 6 Nhánh Nguyên nhân
        │         ├─ Xuất Ma trận Đối soát Số lượng Chỉ tiêu theo Nhóm
        │         └─ Liệt kê Danh sách Blocker & Action Items
        │
        └─► [MICRO-REVIEW] Review chi tiết Nhóm N (4 Lớp)
                  ├─ Lớp 1 (HLD): Kiểm tra 5 Section, bảng 7 cột, số dòng khớp 0b.3
                  │         └─ Có lỗi → Kịch bản A/C/D → Trình đề xuất → Gọi datamart-hld-design
                  ├─ Lớp 2 (Attributes): Trace BA → Atomic YAML approved → Attributes
                  │         └─ Có lỗi → Kịch bản B/C → Trình đề xuất → Gọi datamart-lld-design
                  ├─ Lớp 3 (Detail Mapping): Trace logic, full SQL, inline DERIVED
                  │         └─ Có lỗi → Kịch bản B/C → Trình đề xuất → Gọi datamart-lld-design
                  └─ Lớp 4 (Registry datamart_model.yaml): Đồng bộ 1-1 cột, type, status
                            └─ Có lỗi → Kịch bản C → Trình đề xuất → Gọi datamart-lld-design
```
