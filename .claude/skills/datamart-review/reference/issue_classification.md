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
│ BA = Delete             │ 🔴 Vi phạm cấm kỵ         │ 🔴 Vi phạm cấm kỵ         │ 🟢 Đúng chuẩn             │
│ (Đã bị hủy/xóa từ BA)   │ (Phải xóa ngay khỏi DM)   │ (Phải xóa ngay khỏi DM)   │ (Tuyệt đối không thiết kế)│
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
  - Thiếu bộ 5 trường kỹ thuật mặc định SCD4A trên bảng Dimension / Operational (`ds_rcrd_st`, `ds_eff_start_dt`, `ds_eff_end_dt`, `ds_cdc_opr_cd`, `ds_load_ts`, và `ds_snpst_dt` đối với History/Snapshot) (mã: `L2-SCD4A-TECH-FIELD`).
  - Mệnh đề JOIN vào bảng Atomic Fundamental (SCD4A) thiếu điều kiện lọc bản ghi active `ds_rcrd_st = 'ACTIVE'` (mã: `L2-SCD4A-JOIN-FILTER`).
  - Vi phạm Orphan Check 3 chiều (LLD Attributes ↔ HLD Entities ↔ Flat Table SQL DDL):
    - *Nhánh A (Incomplete Implementation):* Bảng còn giá trị / có ≥1 KPI READY nhưng thiếu trong HLD Entities hoặc Flat Table SQL DDL (`L2-ORPHAN-3WAY-INCOMPLETE`).
    - *Nhánh B (Abandoned Entity):* Bảng đã bị hủy / 0 KPI READY nhưng còn sót lại artifact trong LLD CSV, Entities.csv hoặc Flat Table SQL (`L2-ORPHAN-3WAY-ABANDONED`).
  - Vi phạm đồng bộ Master Registry `datamart_attributes.csv` & Parity:
    - Lệch nội dung biểu thức `etl_logic` giữa file module attributes và master registry (`L2-ETL-LOGIC-PARITY-MISMATCH`).
    - Thiếu hoặc thừa thuộc tính trong master registry so với module CSV (`L4-MASTER-REGISTRY-OUT-OF-SYNC`).
  - Vi phạm thiết kế Role-Playing Date Dimension trên Fact table (mã: `L2-DATE-FK-ROLE-PLAYING`): Sử dụng `Calendar Date Dimension Id` (`cdr_dt_dim_id` hoặc `calendar_dt_dim_id`) trên bảng Fact thay vì đặt tên theo vai trò (`snpst_dt_dim_id` cho Fact Snapshot hoặc `<role>_dt_dim_id` cho các Fact khác).
  - Vi phạm quy chuẩn điền Detail Mapping:
    - Vi phạm Quy tắc L4 đối với dòng PENDING: để sót giá trị trong 4 cột `mart_table`, `mart_column`, `column_role`, `logic` (mã: `L3-PENDING-RULE-L4-VIOLATION`).
    - Vi phạm quy cách REUSE (Quy tắc L15): để trống cột ở Case 1 hoặc gán cột ảo ở Case 2 (mã: `L3-REUSE-INVALID`).
    - Đánh tráo chỉ tiêu DEPRECATED thành PENDING (Quy tắc L16) làm phình to blocker (mã: `L3-DEPRECATED-AS-PENDING`).
  - Vi phạm kiểm soát Grain, Window Storage và Tỷ số tài chính:
    - Lệch cấp độ hạt giữa ngữ cảnh hiển thị và công thức (`L1-GRAIN-MISMATCH`, `L3-GRAIN-MISMATCH`).
    - Sử dụng Dimension current-state thay vì Fact Periodic Snapshot cho Window Functions (`L2-WINDOW-STORAGE-INVALID`).
    - Cấu hình sai số phiên hoặc trường giá trong Window Functions (`L3-FORMULA-WINDOW-MISMATCH`).
    - Lệch chu kỳ thời gian giữa tử số và mẫu số của tỷ số tài chính (`L3-FINANCIAL-PERIOD-INCONSISTENT`).
  - Vi phạm đồng bộ Flat Table SQL (DDL & DML):
    - Thiếu cột Fact/Operational hoặc Dimension joined trong DDL (mã: `L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING`).
    - Lệch số lượng, thứ tự hoặc alias giữa CREATE TABLE và INSERT INTO ... SELECT (mã: `L4-FLAT-TABLE-PROJECTION-MISALIGNMENT`).
    - Trôi lệch cột giữa Flat Table SQL, Attributes CSV và Detail Mapping (mã: `L4-FLAT-TABLE-COLUMN-DRIFT`).
    - Sai cú pháp tham số lọc ngày ETL, không dùng `:etl_date` (mã: `L4-FLAT-TABLE-PARAMETER-INCONSISTENT`).
  - Bảng KPI HLD thiếu cột (chưa đủ chuẩn 7 cột có cột `Trạng thái`).
  - HLD thiếu Section 4 Reuse Analysis.
- **Hành động:**
  1. Trình bày action đề xuất cụ thể: file, dòng/cột, giá trị cũ → mới, lý do.
  2. Claude DỪNG và chờ human xác nhận rõ ràng.
  3. **Gọi skill con thực hiện** — HLD → `datamart-hld-design`; Attributes / Detail Mapping / `datamart_model.yaml` / `datamart_attributes.csv` → `datamart-lld-design`.
- ❌ **Tuyệt đối KHÔNG tự Edit trực tiếp.** Claude chỉ phát hiện, phân loại và đề xuất — việc sửa thuộc skill con.
- ⛔ **CỔNG CHẶN BÀN GIAO KỊCH BẢN C (HANDOVER BLOCKING GATE):** Bất kể Kịch bản C được thực hiện qua kênh nào, NGAY SAU khi sửa đổi file Attributes, Reviewer/Developer BẮT BUỘC chạy `python scripts/check_parity.py --module [MODULE] --strict` và `python scripts/check_orphan.py --module [MODULE] --strict`. Bắt buộc đạt 0 lỗi mới được phép nghiệm thu bàn giao.

---

### Danh Mục Đặc Tả Chi Tiết Các Mã Lỗi Kỹ Thuật (Lớp 1, Lớp 2, Lớp 3 & Lớp 4)

#### 1. Đặc tả Mã lỗi: `L2-DATE-FK-ROLE-PLAYING`

| Thuộc tính | Chi tiết đặc tả |
|---|---|
| **Mã lỗi (Error Code)** | `L2-DATE-FK-ROLE-PLAYING` |
| **Tên lỗi (Issue Name)** | Vi phạm thiết kế Role-Playing Date Dimension Key trên Fact table |
| **Phân loại kịch bản** | **Kịch bản C — Lỗi kỹ thuật thiết kế** |
| **Mức độ (Severity)** | 🔴 **Critical** (Ngăn chặn hoàn tất review, chặn code-gen flat table/ETL) |
| **Mô tả (Description)** | Bảng thuộc loại Fact (`table_type == 'fact'` hoặc prefix `fct_`) chứa cột khóa ngoại trỏ tới Calendar Date Dimension nhưng đặt tên generic `Calendar Date Dimension Id` (`cdr_dt_dim_id` hoặc `calendar_dt_dim_id`) thay vì đặt tên phản ánh vai trò nghiệp vụ (Role-Playing). `cdr_dt_dim_id` chỉ được phép là PK của bảng Dimension `cdr_dt_dim`. Trên Fact Snapshot (`fct_*_snpst`), cột ngày snapshot kỳ bắt buộc là `Snapshot Date Dimension Id` (`snpst_dt_dim_id`). Trên Fact khác, bắt buộc là `<Role> Date Dimension Id` (`<role>_dt_dim_id`). |
| **Phương pháp chẩn đoán & phát hiện** | 1. Chạy CLI: `python scripts/check_date_fk.py --module [MODULE]` (hoặc `--module all`).<br>2. Quét regex trên Attributes CSV: Nhận diện mọi dòng thuộc bảng `fct_*` có `datamart_column == 'cdr_dt_dim_id'` hoặc `calendar_dt_dim_id`, hoặc `datamart_attribute == 'Calendar Date Dimension Id'`.<br>3. Kiểm tra Fact Snapshot (`_snpst`): thiếu cột `snpst_dt_dim_id`.<br>4. Đảm bảo loại trừ bảng Dimension `cdr_dt_dim` (nơi `cdr_dt_dim_id` là PK) để không false positive. |
| **Chuẩn đặt tên thay thế** | - Fact Snapshot kỳ: `Snapshot Date Dimension Id` → `snpst_dt_dim_id`<br>- Ngày phát hành: `Issue Date Dimension Id` → `issue_dt_dim_id`<br>- Ngày giao dịch: `Trade Date Dimension Id` → `trade_dt_dim_id`<br>- Ngày nộp: `Submission Date Dimension Id` → `submission_dt_dim_id`<br>- Ngày đánh giá: `Evaluation Date Dimension Id` → `evaluation_dt_dim_id`<br>- Ngày hiệu lực: `Effective Date Dimension Id` → `effective_dt_dim_id` |
| **Remediation Protocol kết nối `datamart-lld-design`** | **Bước 1 (Reviewer):** Liệt kê bảng vi phạm, file LLD CSV, vị trí dòng, cột sai (`cdr_dt_dim_id`) và cột đề xuất thay thế (`snpst_dt_dim_id` hoặc `<role>_dt_dim_id`).<br>**Bước 2 (Gate):** Claude DỪNG và chờ Human phê duyệt đề xuất.<br>**Bước 3 (Chuyển giao):** Gọi skill `datamart-lld-design` (Phase 1 field rename sync) để thực hiện đồng bộ 4 tầng:<br>  *(a) LLD Attributes detail CSV + master `datamart_attributes.csv`* (sửa logical và physical name).<br>  *(b) Detail Mapping CSV* (sửa `mart_column` và mệnh đề `LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt_dim_id = <fact>.<role>_dt_dim_id` trong cột `logic`).<br>  *(c) Model Registry `datamart_model.yaml`* (sửa tên attribute và column trong entity Fact tương ứng).<br>  *(d) Flat Table SQL `01_create_*.sql` & `02_populate_*.sql`* (sửa DDL và câu lệnh JOIN nếu đã sinh SQL).<br>**Bước 4 (Verify):** Chạy lại `check_date_fk.py` và `check_parity.py` xác nhận sạch 100%. |

#### 2. Đặc tả Mã lỗi: `L2-ORPHAN-3WAY-INCOMPLETE` (Orphan Nhánh A)

| Thuộc tính | Chi tiết đặc tả |
|---|---|
| **Mã lỗi (Error Code)** | `L2-ORPHAN-3WAY-INCOMPLETE` |
| **Tên lỗi (Issue Name)** | Thực thể dữ liệu mồ côi Nhánh A — Thiếu định nghĩa HLD Entities hoặc Flat Table SQL (Incomplete Implementation) |
| **Phân loại kịch bản** | **Kịch bản C — Lỗi kỹ thuật thiết kế & Thiếu artifact chuyển tiếp** |
| **Mức độ (Severity)** | 🔴 **Critical** (Chặn hoàn tất review, chặn nghiệm thu bàn giao) |
| **Mô tả (Description)** | Bảng Fact hoặc Operational đã có file LLD Attributes CSV (`Datamart/lld/{MODULE}/*.csv`) và có ≥1 KPI READY trong HLD / Detail Mapping (bảng mang giá trị khai thác nghiệp vụ thực tế), nhưng bị bỏ sót khỏi danh mục `DTM_{MODULE}_Entities.csv` (HLD Tier B) hoặc chưa được sinh câu lệnh DDL/DML trong `Datamart/flat-table/{MODULE}/` (Tier C). |
| **Phương pháp chẩn đoán & phát hiện** | 1. Chạy CLI: `python scripts/check_orphan.py --module [MODULE] [--strict]`.<br>2. Đối soát ma trận 3 chiều: Bảng tồn tại ở Tier A (LLD) nhưng vắng mặt ở Tier B (Entities) hoặc Tier C (Flat Table SQL), đồng thời số lượng KPI READY của bảng > 0.<br>3. Kiểm tra ngoại lệ: Loại trừ các Dimension dùng chung (`SHARED`), Dimension denormalized, và bảng reuse từ module khác. |
| **Nguyên tắc xử lý cốt lõi** | **TUYỆT ĐỐI KHÔNG ĐƯỢC XÓA TỆP TIN LLD HAY CÁC DÒNG THUỘC TÍNH CỦA BẢNG!** Bảng có giá trị nghiệp vụ, phải hoàn tất các tầng còn thiếu. |
| **Remediation Protocol** | **Bước 1 (Reviewer):** Xác định tầng bị thiếu (HLD Entities hay Flat Table SQL), lập danh sách KPI READY phụ thuộc.<br>**Bước 2 (Gate):** Dừng tại Gate 1 hoặc Gate 2, báo cáo Human và trình Action Proposal hoàn tất artifact.<br>**Bước 3 (Chuyển giao):**<br>  *(a) Nếu thiếu HLD Entities:* Gọi `datamart-hld-design` bổ sung dòng entity vào `DTM_{MODULE}_Entities.csv` và cập nhật Section 3, Section 4 Reuse Analysis trong `DTM_{MODULE}_HLD.md`.<br>  *(b) Nếu thiếu Flat Table SQL:* Gọi `datamart-lld-design` (Phase 3) sinh `CREATE TABLE` trong `01_create_*.sql` và `INSERT INTO ... SELECT` trong `02_populate_*.sql`.<br>**Bước 4 (Verify):** Chạy lại `python scripts/check_orphan.py --module [MODULE] --strict` xác nhận 0 orphan. |

#### 3. Đặc tả Mã lỗi: `L2-ORPHAN-3WAY-ABANDONED` (Orphan Nhánh B)

| Thuộc tính | Chi tiết đặc tả |
|---|---|
| **Mã lỗi (Error Code)** | `L2-ORPHAN-3WAY-ABANDONED` |
| **Tên lỗi (Issue Name)** | Thực thể dữ liệu mồ côi Nhánh B — Tồn dư artifact của bảng đã bị hủy/thay thế (Abandoned Entity Residue) |
| **Phân loại kịch bản** | **Kịch bản C — Lỗi kỹ thuật tồn dư rác thiết kế** |
| **Mức độ (Severity)** | 🟡 **Warning** (nếu là draft cũ chưa phát sinh nợ) / 🔴 **Critical** (nếu liên quan tới chỉ tiêu BA = Delete) |
| **Mô tả (Description)** | Tệp tin LLD Attributes CSV, dòng trong `DTM_{MODULE}_Entities.csv`, hoặc Flat Table SQL DDL còn tồn tại đối với một thực thể đã bị hủy bỏ, thay thế hoặc có 0 KPI READY (tất cả chỉ tiêu liên quan đã chuyển bảng khác hoặc bị bãi bỏ từ BA). Điển hình: `fct_public_company_shareholding` của GSTT sót lại trong Entities.csv. |
| **Phương pháp chẩn đoán & phát hiện** | 1. Chạy CLI: `python scripts/check_orphan.py --module [MODULE] [--strict]`.<br>2. Đối soát ma trận 3 chiều: Bảng xuất hiện ở một số tầng nhưng có 0 KPI READY, hoặc bảng đã bị xóa khỏi Flat Table/HLD nhưng vẫn còn sót file trong `Datamart/lld/{MODULE}/` hoặc dòng trong `datamart_attributes.csv`. |
| **Remediation Protocol (All-Tier Cleanup Protocol 5 Bước)** | **Bước 1 (Reviewer):** Lập danh mục toàn bộ artifact tàn dư của bảng trên cả 3 tầng.<br>**Bước 2 (Gate):** Claude DỪNG và chờ Human phê duyệt đề xuất dọn dẹp sạch sẽ.<br>**Bước 3 (Chuyển giao thực thi All-Tier Cleanup):**<br>  *(a) LLD Module:* Xóa file `Datamart/lld/{MODULE}/DTM_{MODULE}_{table}.csv`.<br>  *(b) Master Registry CSV:* Purge toàn bộ dòng thuộc tính của bảng khỏi `Datamart/lld/datamart_attributes.csv`.<br>  *(c) Detail Mapping:* Gỡ bỏ các dòng mapping của bảng trong `DTM_{MODULE}_Detail_Mapping.csv`.<br>  *(d) Model Registry YAML:* Purge entity khỏi `Datamart/datamart_model.yaml` (trừ SHARED Dim).<br>  *(e) HLD Entities & Reuse:* Xóa dòng trong `DTM_{MODULE}_Entities.csv` và Section 4 Reuse Analysis trong `DTM_{MODULE}_HLD.md`.<br>**Bước 4 (Verify):** Chạy lại `check_orphan.py` và `check_parity.py` xác nhận sạch 100%. |

#### 4. Đặc tả Mã lỗi: `L2-ETL-LOGIC-PARITY-MISMATCH`

| Thuộc tính | Chi tiết đặc tả |
|---|---|
| **Mã lỗi (Error Code)** | `L2-ETL-LOGIC-PARITY-MISMATCH` |
| **Tên lỗi (Issue Name)** | Lệch nội dung biểu thức etl_logic giữa file module Attributes và Master Registry |
| **Phân loại kịch bản** | **Kịch bản C — Lỗi kỹ thuật mất đồng bộ dữ liệu (Logic Drift Desynchronization)** |
| **Mức độ (Severity)** | 🔴 **Critical** (Chặn mở Gate 1/2, chặn Pull Request, từ chối nghiệm thu bàn giao) |
| **Mô tả (Description)** | Cùng một thuộc tính `(datamart_table, datamart_column)` hoặc `(datamart_entity, datamart_attribute)` có mặt ở cả file module `Datamart/lld/{MODULE}/*.csv` và master registry `Datamart/lld/datamart_attributes.csv`, nhưng biểu thức `etl_logic` có nội dung khác nhau (sau khi strip khoảng trắng). Nguyên nhân: sửa bug ở file module nhưng quên cập nhật master registry, khiến mã ETL sinh từ master registry chạy logic cũ sai lệch. |
| **Phương pháp chẩn đoán & phát hiện** | 1. Chạy CLI: `python scripts/check_parity.py --module [MODULE] [--strict]` (hoặc `--module all`).<br>2. So khớp từng dòng: Nếu `module_logic.strip() != master_logic.strip()`, báo cáo chi tiết: tên bảng, tên cột, file nguồn, nội dung khác biệt (diff), và chỉ báo nguồn chuẩn cần sửa. |
| **Remediation Protocol** | **Bước 1 (Reviewer):** Xác định phiên bản logic đúng (thông thường là file module vừa được sửa đúng nghiệp vụ). Trích xuất chính xác chuỗi `etl_logic` chuẩn.<br>**Bước 2 (Gate):** Dừng báo cáo tại Gate 1/2 hoặc Cổng Bàn Giao Kịch bản C.<br>**Bước 3 (Chuyển giao):** Gọi `datamart-lld-design` (hoặc thực thi Action Proposal đã duyệt) ghi đè chuỗi `etl_logic` chuẩn vào dòng tương ứng trong `Datamart/lld/datamart_attributes.csv`.<br>**Bước 4 (Verify):** Chạy `python scripts/check_parity.py --module [MODULE] --strict` xác nhận 0 mismatch. |

#### 5. Đặc tả Mã lỗi: `L4-MASTER-REGISTRY-OUT-OF-SYNC`

| Thuộc tính | Chi tiết đặc tả |
|---|---|
| **Mã lỗi (Error Code)** | `L4-MASTER-REGISTRY-OUT-OF-SYNC` |
| **Tên lỗi (Issue Name)** | Mất đồng bộ danh mục thuộc tính trong Master Registry `datamart_attributes.csv` |
| **Phân loại kịch bản** | **Kịch bản C — Lỗi kỹ thuật tầng Master Registry** |
| **Mức độ (Severity)** | 🔴 **Critical** (Chặn nghiệm thu và bàn giao) |
| **Mô tả (Description)** | Master registry `Datamart/lld/datamart_attributes.csv` bị thiếu các thuộc tính đã tồn tại trong file module Attributes, hoặc master registry chứa các thuộc tính mồ côi của bảng đã bị xóa/hủy bỏ ở module. |
| **Phương pháp chẩn đoán & phát hiện** | 1. Chạy CLI: `python scripts/check_parity.py --module [MODULE] [--strict]`.<br>2. Phát hiện danh sách `missing_in_master` hoặc `missing_in_module`. |
| **Remediation Protocol** | **Bước 1:** Liệt kê các thuộc tính bị lệch danh mục.<br>**Bước 2:** Gọi `datamart-lld-design` đồng bộ bổ sung vào master CSV nếu thiếu, hoặc purge khỏi master CSV nếu là thuộc tính bảng đã hủy.<br>**Bước 3 (Verify):** Chạy lại `check_parity.py --strict` xác nhận 0 missing. |

#### 6. Đặc tả Mã lỗi: `L1/L3-GRAIN-MISMATCH`

| Thuộc tính | Chi tiết đặc tả |
|---|---|
| **Mã lỗi (Error Code)** | `L1-GRAIN-MISMATCH` (HLD) / `L3-GRAIN-MISMATCH` (Detail Mapping) |
| **Tên lỗi (Issue Name)** | Lệch cấp độ hạt giữa ngữ cảnh hiển thị báo cáo và công thức đo lường |
| **Phân loại kịch bản** | **Kịch bản C — Lỗi kỹ thuật thiết kế & Logic nghiệp vụ (Lớp 1 & Lớp 3)** |
| **Mức độ (Severity)** | 🔴 **Critical** (Chặn mở Gate 2, sai lệch hoàn toàn số liệu hiển thị trên giao diện) |
| **Mô tả (Description)** | Một chỉ tiêu đo lường trong bảng KPI HLD hoặc Detail Mapping có cấp độ hạt trong công thức tính toán (`GROUP BY`, `PARTITION BY`, hoặc Grain của Fact nguồn) không khớp với cấp độ hạt của đối tượng hiển thị trên báo cáo/mockup. Điển hình: Copy công thức Vốn hóa cấp Rổ chỉ số (`Index`) sang các bảng hiển thị cấp Mã chứng khoán (`Symbol`), khiến mọi mã chứng khoán trong rổ hiển thị cùng một con số vốn hóa của cả rổ (case thực tế `K_GSTT_61`). |
| **Phương pháp chẩn đoán & phát hiện** | 1. Mở mockup giao diện hoặc bảng KPI của nhóm: Xác định đơn vị của 1 dòng kết quả (Mã CK, Chỉ số, CTCK, Ngành).<br>2. So sánh với các trường trong mệnh đề `GROUP BY` / `PARTITION BY` trong cột `logic` của Detail Mapping.<br>3. Kiểm tra các dòng có `ghi_chu` chứa `"Reuse từ Nhóm X"`: Nếu Nhóm X và nhóm hiện tại có đơn vị dòng khác nhau mà công thức giữ nguyên `GROUP BY` cũ $\implies$ Gắn cờ vi phạm. |
| **Remediation Protocol** | **Bước 1:** Xác định đúng đơn vị dòng của nhóm hiện tại.<br>**Bước 2:** Điều chỉnh lại công thức trong HLD Section 3 và cột `logic` trong Detail Mapping: Thay đổi khóa gom nhóm (`GROUP BY symbol` thay vì `GROUP BY index_code`), sử dụng đúng trường measure cấp mã.<br>**Bước 3:** Chạy đối soát lại `check_parity.py --strict` nếu có sửa đổi Attributes liên quan. |

#### 7. Đặc tả Mã lỗi: `L2-WINDOW-STORAGE-INVALID`

| Thuộc tính | Chi tiết đặc tả |
|---|---|
| **Mã lỗi (Error Code)** | `L2-WINDOW-STORAGE-INVALID` |
| **Tên lỗi (Issue Name)** | Sử dụng Dimension SCD4A current-state thay vì Fact Periodic Snapshot cho Window Functions chuỗi thời gian |
| **Phân loại kịch bản** | **Kịch bản C — Lỗi kỹ thuật kiến trúc lưu trữ (Lớp 2)** |
| **Mức độ (Severity)** | 🔴 **Critical** (Chặn mở Gate 1/2, vô hiệu hóa hoàn toàn ý nghĩa lịch sử của chỉ tiêu) |
| **Mô tả (Description)** | Một chỉ tiêu dạng chuỗi thời gian (Rolling N phiên, Đỉnh/Đáy 52 tuần, 6 tháng, 3 tháng, đường MA) được thiết kế trỏ nguồn vào bảng Dimension SCD4A current-state (như `security_trading_snpst_dim`) thay vì Fact Periodic Snapshot. Vì Dimension current-state chỉ chứa duy nhất 1 bản ghi phiên gần nhất của ngày hôm nay, hàm Window Function chỉ chạy trên 1 dòng duy nhất và trả về chính giá ngày hôm nay, không thể truy vết được lịch sử. |
| **Phương pháp chẩn đoán & phát hiện** | 1. Quét Detail Mapping cột `logic` tìm các hàm `OVER (...)`.<br>2. Kiểm tra bảng nguồn của trường giá/chỉ tiêu: nếu là `*_dim` hoặc bảng Dimension SCD4A (thay vì `fct_*_snpst`) $\implies$ Báo lỗi `L2-WINDOW-STORAGE-INVALID`.<br>3. Kiểm tra file Attributes của bảng Fact: xác minh Fact có cột snapshot theo ngày (ví dụ `close_price` theo ngày giao dịch). |
| **Remediation Protocol** | **Bước 1:** Kiểm tra bảng Fact Periodic Snapshot của nhóm (`fct_*_snpst`). Nếu chưa có trường đo lường theo ngày (`close_price`, `total_matched_vol`), gọi `datamart-lld-design` bổ sung cột snapshot vào Fact table.<br>**Bước 2:** Đồng bộ master registry `datamart_attributes.csv` và `datamart_model.yaml`.<br>**Bước 3:** Sửa Detail Mapping cột `logic` trỏ trường giá vào bảng Fact Periodic Snapshot.<br>**Bước 4 (Verify):** Chạy `check_parity.py --strict`. |

#### 8. Đặc tả Mã lỗi: `L3-FORMULA-WINDOW-MISMATCH`

| Thuộc tính | Chi tiết đặc tả |
|---|---|
| **Mã lỗi (Error Code)** | `L3-FORMULA-WINDOW-MISMATCH` |
| **Tên lỗi (Issue Name)** | Cấu hình sai Window Function, sai số phiên giao dịch hoặc sai trường giá cơ sở |
| **Phân loại kịch bản** | **Kịch bản C — Lỗi kỹ thuật tầng Detail Mapping (Lớp 3)** |
| **Mức độ (Severity)** | 🔴 **Critical** (Chặn mở Gate 2, sai lệch chuỗi thời gian phân tích) |
| **Mô tả (Description)** | Công thức tính toán chỉ tiêu chuỗi thời gian (đỉnh/đáy 52 tuần, 6 tháng, 3 tháng, đường MA):<br>(1) Dùng sai trường giá cơ sở (dùng `high_price`/`low_price` trong khi tài liệu BA quy định dùng `close_price` cho báo cáo định giá BM021_MSS);<br>(2) Dùng sai số phiên giao dịch quy ước (dùng ngày lịch `INTERVAL '52' WEEK` hoặc sai số phiên 260/130/65/20);<br>(3) Thiếu mệnh đề `PARTITION BY <entity_id>` dẫn đến trộn lẫn chuỗi giá của nhiều mã cổ phiếu khác nhau;<br>(4) Thiếu `ORDER BY <date_col> ASC`. |
| **Phương pháp chẩn đoán & phát hiện** | 1. Quét cột `logic` trong Detail Mapping tìm các hàm `OVER (...)`.<br>2. Kiểm tra xem có đủ 3 mệnh đề bắt buộc: `PARTITION BY <entity_id>`, `ORDER BY <date_col> ASC`, và `ROWS BETWEEN (N-1) PRECEDING AND CURRENT ROW`.<br>3. Kiểm tra số phiên lookback theo bảng chuẩn: 52 tuần = 259 preceding; 6 tháng = 129 preceding; 3 tháng = 64 preceding; 1 tháng = 19 preceding.<br>4. Đối chiếu tài liệu BA để xác nhận trường giá (`close_price` vs `high_price`/`low_price`). |
| **Remediation Protocol** | **Bước 1:** Chuẩn hóa lại mệnh đề `logic` trong Detail Mapping theo đúng template chuẩn:<br>`MAX/MIN(fct_table.close_price) OVER (PARTITION BY dim.symbol ORDER BY cdr_dt_dim.cdr_dt ASC ROWS BETWEEN N PRECEDING AND CURRENT ROW)`.<br>**Bước 2:** Cập nhật lại HLD Section 3 nếu có mô tả sai công thức.<br>**Bước 3:** Chạy đối soát lại Detail Mapping. |

#### 9. Đặc tả Mã lỗi: `L3-FINANCIAL-PERIOD-INCONSISTENT`

| Thuộc tính | Chi tiết đặc tả |
|---|---|
| **Mã lỗi (Error Code)** | `L3-FINANCIAL-PERIOD-INCONSISTENT` |
| **Tên lỗi (Issue Name)** | Lệch chu kỳ thời gian giữa tử số và mẫu số của tỷ số tài chính |
| **Phân loại kịch bản** | **Kịch bản C — Lỗi kỹ thuật tính toán chỉ số tài chính (Lớp 3)** |
| **Mức độ (Severity)** | 🔴 **Critical** (Sai lệch nghiêm trọng các hệ số định giá thị trường P/E, P/B, EPS, ROE, ROA) |
| **Mô tả (Description)** | Phép tính tỷ số tài chính kết hợp giữa biến số Dòng tiền (Flow - BCKQKD) và biến số Thời điểm (Stock - BCDKT) hoặc biến số Khối lượng cổ phiếu không cùng một chu kỳ thời gian. Điển hình:<br>(1) Lấy Giá thị trường chia cho EPS của riêng 1 quý mà không nhân 4 quy năm (khiến P/E bị thổi phồng ~4 lần);<br>(2) Lấy LNST 4 quý (TTM) chia cho số CP lưu hành của riêng 1 quý;<br>(3) Thực hiện phép cộng dồn (`SUM`) vốn chủ sở hữu (`owner_equity`) hoặc tổng tài sản qua 4 quý trong công thức mẫu số (vi phạm nghiêm trọng nguyên lý kế toán BCDKT);<br>(4) Không bẫy giá trị `NULL` khi thiếu 1 trong 4 quý BCTC liên tiếp của TTM. |
| **Phương pháp chẩn đoán & phát hiện** | 1. Kiểm tra công thức các chỉ số: `P/E`, `P/B`, `EPS`, `BVPS`, `ROE`, `ROA` trong Detail Mapping và HLD.<br>2. Kiểm tra tính đồng bộ chu kỳ giữa tử số và mẫu số theo Ma Trận Đối Soát Nhất Quán (Mục 12 Technical Review Rules).<br>3. Quét tìm các biểu thức sai lầm dạng `SUM(owner_equity)` hoặc `SUM(total_assets)` qua nhiều kỳ.<br>4. Kiểm tra điều kiện xử lý dữ liệu thiếu (bắt buộc trả về `NULL` khi thiếu quý BCTC). |
| **Remediation Protocol** | **Bước 1:** Xác định rõ yêu cầu BA là đo lường theo Quý (1Q) hay theo Năm (TTM 4Q).<br>**Bước 2:** Viết lại công thức DERIVED: Đồng bộ chu kỳ tử số và mẫu số theo đúng Ma trận Nhất quán Thời gian Tài chính (Mục 12 trong Technical Review Rules). Nếu là P/E Quý thì nhân 4 quy năm; nếu là P/E chuẩn thì chia cho EPS TTM.<br>**Bước 3:** Tuyệt đối loại bỏ mọi phép tính `SUM(owner_equity)` qua 4 quý, thay bằng giá trị quý gần nhất hoặc tính bình quân đầu/cuối kỳ.<br>**Bước 4:** Cập nhật HLD và Detail Mapping. |

#### 10. Đặc tả Mã lỗi: `L3-PENDING-RULE-L4-VIOLATION`

| Thuộc tính | Chi tiết đặc tả |
|---|---|
| **Mã lỗi (Error Code)** | `L3-PENDING-RULE-L4-VIOLATION` |
| **Tên lỗi (Issue Name)** | Vi phạm Quy tắc L4 — Dòng chỉ tiêu PENDING không để trống hoàn toàn 4 cột kỹ thuật |
| **Phân loại kịch bản** | **Kịch bản C — Lỗi kỹ thuật tầng Detail Mapping (Lớp 3)** |
| **Mức độ (Severity)** | 🔴 **Critical** (Chặn mở Gate 2, vi phạm quy chuẩn cấu trúc Detail Mapping) |
| **Mô tả (Description)** | Dòng chỉ tiêu mang trạng thái PENDING (chưa thiết kế Fact/Dim hoặc chờ nguồn BA/Atomic) nhưng không tuân thủ Quy tắc L4: Bắt buộc toàn bộ 4 cột `mart_table`, `mart_column`, `column_role`, `logic` PHẢI ĐỂ TRỐNG HOÀN TOÀN (`""`). Lỗi vi phạm điển hình: Điền giá trị giả định vào `column_role` (như điền `'PENDING'`, `'MEASURE'`, `'DERIVED'`), điền ghi chú hoặc biểu thức tạm vào `logic`, hoặc điền tên bảng/cột dự kiến vào `mart_table`/`mart_column`. Nguyên nhân gốc của blocker phải được ghi nhận duy nhất tại cột `ghi_chu` với tiền tố chuẩn `Pending - [Nhóm 1-5]`. |
| **Phương pháp chẩn đoán & phát hiện** | 1. Quét cột `ghi_chu` trong Detail Mapping tìm các dòng bắt đầu bằng `"Pending"` (hoặc đối chiếu danh sách KPI PENDING từ BA/HLD).<br>2. Kiểm tra 4 cột: nếu bất kỳ cột nào trong `mart_table`, `mart_column`, `column_role`, `logic` khác rỗng (`!= ""`) $\implies$ Báo lỗi `L3-PENDING-RULE-L4-VIOLATION`.<br>3. Chạy CLI: `python scripts/datamart_ba_cross_checker.py --module [MODULE] --lint-detail-mapping`. |
| **Remediation Protocol** | **Bước 1:** Trích xuất toàn bộ nội dung mô tả blocker hoặc công thức nháp đang để sai chỗ.<br>**Bước 2:** Chuyển toàn bộ lý do blocker và nhóm phân loại chuẩn vào cột `ghi_chu` theo cú pháp: `Pending - [Nhóm X: Tên nhóm] - [Lý do chi tiết & Action plan]`.<br>**Bước 3:** Xóa trắng tuyệt đối (`""`) cả 4 cột `mart_table`, `mart_column`, `column_role`, `logic`.<br>**Bước 4 (Verify):** Chạy lại linter xác nhận dòng PENDING tuân thủ 100% Quy tắc L4. |

#### 11. Đặc tả Mã lỗi: `L3-REUSE-INVALID` (Quy tắc L15)

| Thuộc tính | Chi tiết đặc tả |
|---|---|
| **Mã lỗi (Error Code)** | `L3-REUSE-INVALID` |
| **Tên lỗi (Issue Name)** | Vi phạm quy cách khai báo chỉ tiêu REUSE trong Detail Mapping (Quy tắc L15) |
| **Phân loại kịch bản** | **Kịch bản C — Lỗi kỹ thuật tầng Detail Mapping (Lớp 3)** |
| **Mức độ (Severity)** | 🔴 **Critical** (Chặn mở Gate 2, sai lệch ánh xạ vật lý hoặc gán cột ảo không tồn tại) |
| **Mô tả (Description)** | Vi phạm một trong hai trường hợp chuẩn hóa của chỉ tiêu REUSE:<br>(1) **Case 1 (Tái sử dụng Measure/Dimension vật lý đã có sẵn trên Fact/Dim):** Dòng chỉ tiêu tái sử dụng measure/slicer từ nhóm trước nhưng để trống `mart_table` hoặc `mart_column` (lầm tưởng là DERIVED). Quy định bắt buộc: Phải điền đầy đủ tên bảng vật lý `mart_table` và cột vật lý `mart_column`, `column_role` phải là `MEASURE`, `SLICER` hoặc `FILTER`, `ghi_chu` ghi rõ `"Reuse từ Nhóm X: mart_table.mart_column"`.<br>(2) **Case 2 (Tái sử dụng thuần túy qua BI Layer / Phái sinh không có cột vật lý riêng):** Tái sử dụng một chỉ tiêu phái sinh hoặc hiển thị lại mà không có cột vật lý trên Fact, nhưng lại tự ý gán tên cột ảo hoặc gán bảng mà Fact không có cột đó. Quy định bắt buộc: `mart_table` và `mart_column` bắt buộc để trống (`""`), `column_role` là `DERIVED`, `logic` viết công thức phái sinh inline xuống physical table, `ghi_chu` ghi rõ `"Reuse qua BI layer / DERIVED từ Nhóm X"`. |
| **Phương pháp chẩn đoán & phát hiện** | 1. Quét cột `ghi_chu` trong Detail Mapping tìm các dòng chứa từ khóa `"Reuse"`, `"tái sử dụng"`, `"lấy từ nhóm"`.<br>2. Nếu là Case 1 (Fact/Dim đã có cột vật lý): Kiểm tra nếu `mart_table == ""` hoặc `mart_column == ""` $\implies$ Báo lỗi `L3-REUSE-INVALID`.<br>3. Nếu là Case 2 (chỉ tiêu phái sinh / BI layer): Kiểm tra nếu `mart_table != ""` hoặc `mart_column != ""` mà cột đó không có trong Attributes của bảng $\implies$ Báo lỗi `L3-REUSE-INVALID`.<br>4. Chạy CLI: `python scripts/datamart_ba_cross_checker.py --module [MODULE] --lint-detail-mapping`. |
| **Remediation Protocol** | **Bước 1:** Xác định rõ chỉ tiêu thuộc REUSE Case 1 hay Case 2.<br>**Bước 2:** Nếu là Case 1: Điền đúng tên bảng vật lý vào `mart_table`, tên cột vào `mart_column`, đặt `column_role` phù hợp (`MEASURE`/`SLICER`/`FILTER`).<br>**Bước 3:** Nếu là Case 2: Xóa bỏ tên bảng/cột ảo trong `mart_table`/`mart_column` (để trống `""`), chuyển `column_role` thành `DERIVED`, viết công thức inline vào `logic`.<br>**Bước 4 (Verify):** Chạy lại script linter Detail Mapping xác nhận 0 vi phạm. |

#### 12. Đặc tả Mã lỗi: `L3-DEPRECATED-AS-PENDING` (Quy tắc L16)

| Thuộc tính | Chi tiết đặc tả |
|---|---|
| **Mã lỗi (Error Code)** | `L3-DEPRECATED-AS-PENDING` |
| **Tên lỗi (Issue Name)** | Đánh tráo chỉ tiêu DEPRECATED (Bãi bỏ) thành PENDING trong Detail Mapping (Quy tắc L16) |
| **Phân loại kịch bản** | **Kịch bản C — Lỗi kỹ thuật phân loại trạng thái chỉ tiêu (Lớp 3)** |
| **Mức độ (Severity)** | 🔴 **Critical** (Thổi phồng giả tạo nợ tồn đọng Blocker, gây sai lệch báo cáo tiến độ dự án) |
| **Mô tả (Description)** | Chỉ tiêu đã có thống nhất chính thức với BA/PO về việc bãi bỏ/không triển khai (do trùng lặp, không khả thi, hoặc đã gộp vào chỉ tiêu khác), nhưng Designer lại gắn nhãn `Pending - [Nhóm 1-5]` trong `ghi_chu` và để trống theo dạng PENDING thay vì đánh dấu đúng trạng thái `DEPRECATED`. Quy định bắt buộc: Chỉ tiêu bãi bỏ sau HLD phải đặt `column_role = 'DEPRECATED'`, `mart_table = ""`, `mart_column = ""`, `logic = 'Đã loại bỏ — không tạo cột/slicer'`, `ghi_chu` ghi rõ lý do và ngày thống nhất với BA (`"Bãi bỏ sau thống nhất BA YYYY-MM-DD: [Lý do]"`). |
| **Phương pháp chẩn đoán & phát hiện** | 1. Quét cột `ghi_chu` và `logic` tìm các dòng có chứa `"không làm"`, `"bãi bỏ"`, `"hủy bỏ"`, `"không triển khai"`, `"đã loại bỏ"`, `"bỏ qua"`.<br>2. Nếu `ghi_chu` bắt đầu bằng `"Pending - "` hoặc `column_role` để trống/khác `'DEPRECATED'` $\implies$ Báo lỗi `L3-DEPRECATED-AS-PENDING`.<br>3. Đối soát với BA Analyst: Nếu BA đánh dấu Delete/Bãi bỏ nhưng Detail Mapping lại để PENDING $\implies$ Báo lỗi.<br>4. Chạy CLI: `python scripts/datamart_ba_cross_checker.py --module [MODULE] --lint-detail-mapping`. |
| **Remediation Protocol** | **Bước 1:** Xác minh biên bản thống nhất với BA/PO về việc bãi bỏ chỉ tiêu.<br>**Bước 2:** Cập nhật dòng Detail Mapping: Đặt `column_role = 'DEPRECATED'`, để trống `mart_table` và `mart_column`, đặt `logic = 'Đã loại bỏ — không tạo cột/slicer'`, ghi rõ cơ sở bãi bỏ tại `ghi_chu`.<br>**Bước 3:** Đảm bảo không tạo bất kỳ cột vật lý nào trong Attributes CSV, `datamart_model.yaml` hoặc Flat Table SQL.<br>**Bước 4 (Verify):** Chạy lại linter và progress analyzer xác nhận chỉ tiêu được phân loại đúng vào nhóm DEPRECATED, không làm phình to blocker PENDING. |

#### 13. Đặc tả Mã lỗi: `L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING`

| Thuộc tính | Chi tiết đặc tả |
|---|---|
| **Mã lỗi (Error Code)** | `L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING` |
| **Tên lỗi (Issue Name)** | Thiếu cột Fact/Operational hoặc Dimension joined trong Flat Table DDL (01_create_*.sql) |
| **Phân loại kịch bản** | **Kịch bản C — Lỗi kỹ thuật đồng bộ Flat Table SQL (Lớp 4)** |
| **Mức độ (Severity)** | 🔴 **Critical** (Chặn nghiệm thu bàn giao Gate 4, Flat Table thiếu dữ liệu phục vụ báo cáo) |
| **Mô tả (Description)** | Bảng Flat Table trong file DDL `01_create_{module}_flat_tables.sql` bị bỏ sót các cột thuộc tính bắt buộc:<br>(1) Thiếu cột Fact / Operational từ Attributes module (`DTM_{MODULE}_{table}.csv`), trừ các trường kỹ thuật audit hệ thống (`ds_batch_date`, `ds_population_timestamp`).<br>(2) Thiếu cột thuộc tính nghiệp vụ của các Dimension được JOIN (theo khóa ngoại FK trên Fact), ngoại trừ PK surrogate, `src_stm_code` và các trường audit SCD4A (`ds_rcrd_st`, `ds_rcrd_isrt_dt`, `ds_rcrd_udt_dt`, `ds_etl_pcs_tms`, `ds_snpst_dt`).<br>(3) Thiếu cột Calendar Date `cdr_dt` (theo alias vai trò ngày: `snpst_cdr_dt`, `issue_cdr_dt`, `trade_cdr_dt`...) từ `cdr_dt_dim`. |
| **Phương pháp chẩn đoán & phát hiện** | 1. Phân tích DDL `01_create_{module}_flat_tables.sql`: Trích xuất danh sách cột của khối `CREATE TABLE datamart.{module}_{table}_flat`.<br>2. Đối chiếu với file Attributes module `DTM_{MODULE}_{table}.csv`: Kiểm tra xem có cột Fact nào vắng mặt trong DDL.<br>3. Đối chiếu với các Dimension tham gia JOIN: Kiểm tra các cột nghiệp vụ của Dim đã được đưa vào DDL chưa.<br>4. Kiểm tra sự hiện diện của cột ngày Calendar Date tương ứng. |
| **Remediation Protocol** | **Bước 1 (Reviewer):** Liệt kê danh sách cột bị thiếu trong DDL (cột Fact, cột Dim, hoặc cột Calendar Date).<br>**Bước 2 (Chuyển giao):** Gọi `datamart-lld-design` (Phase 3) bổ sung các cột còn thiếu vào khối `CREATE TABLE` trong `01_create_{module}_flat_tables.sql` với kiểu ClickHouse chuẩn (`Nullable(...)`) và COMMENT rõ ràng.<br>**Bước 3:** Bổ sung tương ứng vào mệnh đề `SELECT` trong `02_populate_{module}_flat_tables.sql` để bảo đảm 1-1 Projection Alignment.<br>**Bước 4 (Verify):** Đối soát lại danh sách cột giữa Attributes CSV và DDL SQL, xác nhận độ bao phủ đạt 100%. |

#### 14. Đặc tả Mã lỗi: `L4-FLAT-TABLE-PROJECTION-MISALIGNMENT`

| Thuộc tính | Chi tiết đặc tả |
|---|---|
| **Mã lỗi (Error Code)** | `L4-FLAT-TABLE-PROJECTION-MISALIGNMENT` |
| **Tên lỗi (Issue Name)** | Lệch số lượng, sai thứ tự hoặc không khớp tên cột giữa DDL (CREATE TABLE) và DML (INSERT INTO ... SELECT) |
| **Phân loại kịch bản** | **Kịch bản C — Lỗi kỹ thuật đồng bộ Flat Table SQL (Lớp 4)** |
| **Mức độ (Severity)** | 🔴 **Critical** (Chặn nghiệm thu bàn giao Gate 4, gây lỗi runtime SQL hoặc nạp nhầm giá trị chéo cột) |
| **Mô tả (Description)** | Không khớp 1-1 giữa câu lệnh `CREATE TABLE` trong `01_create_{module}_flat_tables.sql` và câu lệnh `INSERT INTO ... SELECT` trong `02_populate_{module}_flat_tables.sql`:<br>(1) Tổng số cột trong `CREATE TABLE` khác tổng số biểu thức được chiếu trong `SELECT`.<br>(2) Thứ tự các cột trong `CREATE TABLE` không khớp tuần tự với thứ tự các biểu thức trong mệnh đề `SELECT` (ví dụ: cột Fact và cột Dim bị tráo đổi, khiến dữ liệu cột A bị nạp vào cột B).<br>(3) Tên alias trong mệnh đề `SELECT (... AS col_name)` không khớp chính xác 100% với tên cột định nghĩa trong `CREATE TABLE`. |
| **Phương pháp chẩn đoán & phát hiện** | 1. Trích xuất danh sách cột tuần tự từ `CREATE TABLE` trong `01_create_*.sql`.<br>2. Trích xuất danh sách alias tuần tự từ `SELECT ... AS` trong `02_populate_*.sql`.<br>3. So sánh độ dài danh sách (`len`) và so khớp từng cặp index `(create_col[i] == select_alias[i])`.<br>4. Nếu `len(create_cols) != len(select_cols)` hoặc tồn tại vị trí `i` có tên không khớp $\implies$ Báo lỗi `L4-FLAT-TABLE-PROJECTION-MISALIGNMENT`. |
| **Remediation Protocol** | **Bước 1:** Xác định vị trí và danh sách các cột bị lệch số lượng, sai thứ tự hoặc sai alias.<br>**Bước 2:** Chuẩn hóa thứ tự khối cột theo quy chuẩn 3 khối bắt buộc: (1) Fact/Operational columns, (2) Calendar Date columns, (3) Joined Dimension columns.<br>**Bước 3:** Điều chỉnh lại câu lệnh `CREATE TABLE` hoặc `SELECT` để đảm bảo số lượng cột bằng nhau, thứ tự trùng khớp từng dòng, và alias khớp 100%.<br>**Bước 4 (Verify):** Chạy kiểm tra khớp 1-1 tự động giữa 2 file SQL. |

#### 15. Đặc tả Mã lỗi: `L4-FLAT-TABLE-COLUMN-DRIFT`

| Thuộc tính | Chi tiết đặc tả |
|---|---|
| **Mã lỗi (Error Code)** | `L4-FLAT-TABLE-COLUMN-DRIFT` |
| **Tên lỗi (Issue Name)** | Trôi lệch cột giữa Flat Table SQL, Master Registry datamart_attributes.csv và Detail Mapping |
| **Phân loại kịch bản** | **Kịch bản C — Lỗi kỹ thuật mất đồng bộ dữ liệu (Lớp 4)** |
| **Mức độ (Severity)** | 🔴 **Critical** (Chặn nghiệm thu bàn giao Gate 4, xuất hiện cột mồ côi hoặc bỏ sót chỉ tiêu khai thác) |
| **Mô tả (Description)** | Phát hiện trôi lệch cột giữa các tầng định nghĩa:<br>(1) Có cột xuất hiện trong Flat Table SQL nhưng vắng mặt trong master `datamart_attributes.csv` (cột ma, chưa qua chuẩn hóa).<br>(2) Có cột Fact trong Detail Mapping được khai thác bởi các KPI nhưng bị bỏ sót khỏi Flat Table SQL.<br>(3) Có cột trong phần Fact/Operational của câu lệnh `CREATE TABLE` mà không tồn tại trong file Attributes CSV (cột mồ côi/cột thừa do copy-paste từ module khác hoặc tàn dư cũ chưa dọn). |
| **Phương pháp chẩn đoán & phát hiện** | 1. So khớp tập hợp cột Fact trong `01_create_*.sql` với tập hợp cột trong `Datamart/lld/{MODULE}/DTM_{MODULE}_{table}.csv` và `datamart_attributes.csv`.<br>2. Kiểm tra Detail Mapping: Trích xuất mọi `mart_column` của bảng Fact đang xét, xác minh tất cả đều có mặt trong Flat Table.<br>3. Quét tìm các cột thừa (cột có trong SQL nhưng không có trong Attributes). |
| **Remediation Protocol** | **Bước 1:** Liệt kê các cột trôi lệch (cột thừa trong SQL hoặc cột thiếu từ Detail Mapping/Attributes).<br>**Bước 2:** Với cột thừa mồ côi trong SQL: Xóa bỏ khỏi cả `01_create_*.sql` và `02_populate_*.sql`.<br>**Bước 3:** Với cột thiếu trong SQL mà Detail Mapping đang dùng: Bổ sung cột vào DDL và DML theo đúng quy trình Column Coverage.<br>**Bước 4:** Nếu cột mới phát sinh từ nghiệp vụ: Bổ sung vào Attributes CSV, đồng bộ master `datamart_attributes.csv`, rồi mới đưa vào Flat Table SQL.<br>**Bước 5 (Verify):** Xác nhận tập hợp cột Fact trong Flat Table khớp 100% với Attributes và master CSV. |

#### 16. Đặc tả Mã lỗi: `L4-FLAT-TABLE-PARAMETER-INCONSISTENT`

| Thuộc tính | Chi tiết đặc tả |
|---|---|
| **Mã lỗi (Error Code)** | `L4-FLAT-TABLE-PARAMETER-INCONSISTENT` |
| **Tên lỗi (Issue Name)** | Không nhất quán tham số lọc ngày ETL (:etl_date) trong Flat Table DML (02_populate_*.sql) |
| **Phân loại kịch bản** | **Kịch bản C — Lỗi kỹ thuật chuẩn hóa câu lệnh ETL (Lớp 4)** |
| **Mức độ (Severity)** | 🔴 **Critical** (Chặn nghiệm thu bàn giao Gate 4, gây lỗi khi orchestrator lập lịch nạp dữ liệu) |
| **Mô tả (Description)** | Các mệnh đề lọc ngày chạy ETL trong file `02_populate_{module}_flat_tables.sql` không tuân thủ cú pháp tham số chuẩn `:etl_date`. Điển hình: Sử dụng cú pháp không tương thích như `{etl_date}`, `$etl_date`, `?`, hoặc hardcode chuỗi ngày cố định (ví dụ `WHERE snpst_cal.cdr_dt = '2026-09-14'`), khiến job ETL định kỳ hàng ngày không thể truyền tham số động hoặc luôn nạp đè dữ liệu của một ngày cố định. |
| **Phương pháp chẩn đoán & phát hiện** | 1. Quét regex trên toàn bộ file `02_populate_*.sql`: tìm các mệnh đề `WHERE` lọc theo bảng Calendar Date (ví dụ `WHERE snpst_cal.cdr_dt = ...`, `WHERE evnt_cal.cdr_dt = ...`).<br>2. Kiểm tra biểu thức sau dấu `=`: Bắt buộc phải là `:etl_date`.<br>3. Gắn cờ vi phạm nếu xuất hiện: `{etl_date}`, `$etl_date`, `%(etl_date)s`, `?`, chuỗi ngày `'YYYY-MM-DD'`, hoặc các biến thể khác. |
| **Remediation Protocol** | **Bước 1:** Xác định tất cả các dòng câu lệnh chứa mệnh đề lọc ngày không chuẩn trong `02_populate_*.sql`.<br>**Bước 2:** Thay thế toàn bộ mệnh đề lọc ngày bằng cú pháp chuẩn mực duy nhất: `WHERE snpst_cal.cdr_dt = :etl_date` (đối với Fact Snapshot) hoặc `WHERE evnt_cal.cdr_dt = :etl_date` (đối với Fact Event).<br>**Bước 3 (Verify):** Chạy regex quét lại toàn bộ file xác nhận 100% mệnh đề lọc ngày đều sử dụng `:etl_date`, 0 trường hợp hardcode hoặc cú pháp sai. |

---

### Kịch bản D — HLD sai do thiết kế/nguồn Atomic lỗi thời
- **Dấu hiệu:** HLD đã tồn tại, đánh READY, nhưng trỏ nhầm nguồn Atomic đã deprecated/tái cấu trúc, sai grain, sai entity, hoặc logic nghiệp vụ không còn khớp Atomic hiện hành.
- **Hành động:** Gọi `datamart-hld-design` để thiết kế lại — cung cấp đầy đủ bằng chứng đã điều tra (entity Atomic cũ vs mới) để skill con cập nhật đúng.

### Kịch bản E — Review theo issue/bug report
- **Dấu hiệu:** Human hoặc BA báo một vấn đề/lỗi cụ thể trên hệ thống (ví dụ: "thiếu TRADINGTIME", "P/E tính sai") thay vì yêu cầu review toàn module.
- **Hành động:** Chạy quy trình **BƯỚC 0-ALT** (trace đủ 5 tầng: Source → Atomic → HLD → LLD Module CSV & Master Registry → Flat Table), kiểm tra parity logic và orphan.

---

## 4. Bảng Quyết định Nhanh theo Luồng Review

```
[BẮT ĐẦU REVIEW]
        │
        ├─► [MACRO-REVIEW] Bộ công cụ CLI Sanity toàn module:
        │         ├─ datamart_progress_analyzer.py: Ma trận đối soát chéo & Phân loại 6 nhánh PENDING
        │         ├─ check_date_fk.py: Quét vi phạm cdr_dt_dim_id trên Fact
        │         ├─ check_orphan.py: Quét Orphan 3 chiều (Nhánh A Incomplete vs Nhánh B Abandoned)
        │         ├─ check_parity.py: So khớp etl_logic parity giữa Module CSV & Master Registry
        │         └─ ⛔ GATE 1 (Stop & Report): DỪNG, Chặn cứng nếu có vi phạm, chờ Human duyệt
        │
        └─► [MICRO-REVIEW] Review chi tiết Nhóm N (4 Lớp Chuẩn)
                  ├─ Lớp 1 (HLD): 5 Section, bảng 7 cột, số dòng khớp 0b.3 (Kịch bản A/C/D)
                  ├─ Lớp 2 (Attributes): Atomic YAML, SCD4A, Flatten, Role Date FK, Parity, Orphan (Kịch bản B/C)
                  ├─ Lớp 3 (Detail Mapping): Trace BA, full SQL, inline DERIVED, Date FK JOIN (Kịch bản B/C)
                  ├─ Lớp 4 (Registry): Đồng bộ 1-1 datamart_model.yaml VÀ datamart_attributes.csv (Kịch bản C)
                  ├─ ⛔ GATE 2 (Group Checkpoint): DỪNG nếu có Critical/Warning, tự động đi tiếp nếu OK
                  │
                  └─► [GIAI ĐOẠN 3: TỔNG HỢP & BÀN GIAO]
                            ├─ Báo cáo Scorecard & Action Items theo Kịch bản A-E
                            └─ ⛔ CỔNG CHẶN BÀN GIAO KỊCH BẢN C:
                                  Bắt buộc chạy check_parity.py --strict & check_orphan.py --strict (0 lỗi)
                                  mới được phép cấp chứng nhận READY và bàn giao!
```

---

## 5. Quy tắc Kiểm tra và Xử lý Chỉ tiêu Bị XÓA (`Delete` / `DELETED`)

### 5.1. Nhận diện Chỉ tiêu Bị XÓA từ BA
Chỉ tiêu bị XÓA là bất kỳ dòng chỉ tiêu nào trong tài liệu BA analyst có cột `Trạng thái mapping` (hoặc `Trạng thái`) mang một trong các giá trị sau (không phân biệt hoa thường):
- `Delete`, `Deleted`, `DELETE`, `DELETED`
- `Xóa`, `Xoá`, `XOA`, `XÓA`, `Đã xóa`, `Bãi bỏ`, `Hủy bỏ`

### 5.2. Nguyên tắc Bất khả xâm phạm (Golden Rules)
1. **Tuyệt đối KHÔNG thiết kế mới:** 
   - Cấm cấp phát `KPI_ID` hoặc đưa vào bảng KPI của HLD.
   - Cấm tạo thuộc tính (Attribute) trong `Attributes.csv` và master `datamart_attributes.csv`.
   - Cấm tạo dòng mapping trong `Detail_Mapping.csv`.
   - Cấm khai báo trong Model Registry `datamart_model.yaml`.
2. **Xử lý Chỉ tiêu đã lỡ thiết kế trong Datamart (Retirement Protocol & All-Tier Cleanup Protocol):**
   - Nếu qua rà soát phát hiện chỉ tiêu mang trạng thái Delete từ BA nhưng đã tồn tại trong Datamart cũ:
     - Xếp loại mức độ nghiêm trọng: **🔴 Critical (Vi phạm cấm kỵ `[L1/L2-DELETE-VIOLATION]`)**.
     - Đánh dấu gắn cờ cảnh báo: `DEPRECATED / RETIRED`.
     - Kích hoạt Giao thức Dọn dẹp Toàn diện All-Tier Cleanup Protocol 5 Bước (nhất quán với Orphan Nhánh B):
       - **Tầng HLD:** Gọi `datamart-hld-design` xóa bỏ dòng KPI khỏi bảng KPI 7 cột, đồng thời xóa dòng entity liên quan trong `DTM_{MODULE}_Entities.csv` và Section 4 Reuse Analysis nếu bảng bị hủy toàn bộ.
       - **Tầng LLD (Attributes & Detail Mapping):** Gọi `datamart-lld-design` xóa sạch các dòng thuộc tính trong file module CSV, xóa file LLD nếu bảng bị hủy, purge toàn bộ thuộc tính khỏi master registry `datamart_attributes.csv`, và xóa bỏ hoặc chuyển `RETIRED` trong `Detail_Mapping.csv`.
       - **Tầng Registry (`datamart_model.yaml`):** Purge thuộc tính và entity khỏi Model Registry nếu không còn bảng nào sử dụng.
       - **Tầng Flat Table SQL:** Loại bỏ cột hoặc bảng khỏi `01_create_*.sql` và `02_populate_*.sql` để tránh sinh code và tiêu tốn tài nguyên ETL vô ích.
       - **Verify:** Chạy `check_orphan.py --strict` và `check_parity.py --strict` xác nhận hệ thống hoàn toàn sạch bóng các tàn dư mồ côi.
