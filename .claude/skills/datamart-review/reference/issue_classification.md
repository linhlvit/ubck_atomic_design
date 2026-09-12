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
  - Thiếu bộ 5 trường kỹ thuật mặc định SCD4A trên bảng Dimension / Operational (`ds_rcrd_st`, `ds_eff_start_dt`, `ds_eff_end_dt`, `ds_cdc_opr_cd`, `ds_load_ts`, và `ds_snpst_dt` đối với History/Snapshot).
  - Mệnh đề JOIN vào bảng Atomic Fundamental (SCD4A) thiếu điều kiện lọc bản ghi active `ds_rcrd_st = 'ACTIVE'`.
  - Vi phạm Orphan Check 3 chiều (LLD Attributes ↔ HLD Entities ↔ Flat Table SQL DDL):
    - *Nhánh A (Incomplete Implementation):* Bảng còn giá trị / có ≥1 KPI READY nhưng thiếu trong HLD Entities hoặc Flat Table SQL DDL (`L2-ORPHAN-3WAY-INCOMPLETE`).
    - *Nhánh B (Abandoned Entity):* Bảng đã bị hủy / 0 KPI READY nhưng còn sót lại artifact trong LLD CSV, Entities.csv hoặc Flat Table SQL (`L2-ORPHAN-3WAY-ABANDONED`).
  - Vi phạm đồng bộ Master Registry `datamart_attributes.csv` & Parity:
    - Lệch nội dung biểu thức `etl_logic` giữa file module attributes và master registry (`L2-ETL-LOGIC-PARITY-MISMATCH`).
    - Thiếu hoặc thừa thuộc tính trong master registry so với module CSV (`L4-MASTER-REGISTRY-OUT-OF-SYNC`).
  - Vi phạm thiết kế Role-Playing Date Dimension trên Fact table (mã: `L2-DATE-FK-ROLE-PLAYING`): Sử dụng `Calendar Date Dimension Id` (`cdr_dt_dim_id` hoặc `calendar_dt_dim_id`) trên bảng Fact thay vì đặt tên theo vai trò (`snpst_dt_dim_id` cho Fact Snapshot hoặc `<role>_dt_dim_id` cho các Fact khác).
  - Bảng KPI HLD thiếu cột (chưa đủ chuẩn 7 cột có cột `Trạng thái`).
  - HLD thiếu Section 4 Reuse Analysis.
- **Hành động:**
  1. Trình bày action đề xuất cụ thể: file, dòng/cột, giá trị cũ → mới, lý do.
  2. Claude DỪNG và chờ human xác nhận rõ ràng.
  3. **Gọi skill con thực hiện** — HLD → `datamart-hld-design`; Attributes / Detail Mapping / `datamart_model.yaml` / `datamart_attributes.csv` → `datamart-lld-design`.
- ❌ **Tuyệt đối KHÔNG tự Edit trực tiếp.** Claude chỉ phát hiện, phân loại và đề xuất — việc sửa thuộc skill con.
- ⛔ **CỔNG CHẶN BÀN GIAO KỊCH BẢN C (HANDOVER BLOCKING GATE):** Bất kể Kịch bản C được thực hiện qua kênh nào, NGAY SAU khi sửa đổi file Attributes, Reviewer/Developer BẮT BUỘC chạy `python scripts/check_parity.py --module [MODULE] --strict` và `python scripts/check_orphan.py --module [MODULE] --strict`. Bắt buộc đạt 0 lỗi mới được phép nghiệm thu bàn giao.

---

### Danh Mục Đặc Tả Chi Tiết Các Mã Lỗi Kỹ Thuật Lớp 2 & Lớp 4

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
2. **Xử lý Chỉ tiêu đã lỡ thiết kế trong Datamart (Retirement & All-Tier Cleanup Protocol):**
   - Nếu qua rà soát phát hiện chỉ tiêu mang trạng thái Delete từ BA nhưng đã tồn tại trong Datamart cũ:
     - Xếp loại mức độ nghiêm trọng: **🔴 Critical (Vi phạm cấm kỵ `[L1/L2-DELETE-VIOLATION]`)**.
     - Đánh dấu gắn cờ cảnh báo: `DEPRECATED / RETIRED`.
     - Kích hoạt Giao thức Dọn dẹp Toàn diện All-Tier Cleanup Protocol 5 Bước (nhất quán với Orphan Nhánh B):
       - **Tầng HLD:** Gọi `datamart-hld-design` xóa bỏ dòng KPI khỏi bảng KPI 7 cột, đồng thời xóa dòng entity liên quan trong `DTM_{MODULE}_Entities.csv` và Section 4 Reuse Analysis nếu bảng bị hủy toàn bộ.
       - **Tầng LLD (Attributes & Detail Mapping):** Gọi `datamart-lld-design` xóa sạch các dòng thuộc tính trong file module CSV, xóa file LLD nếu bảng bị hủy, purge toàn bộ thuộc tính khỏi master registry `datamart_attributes.csv`, và xóa bỏ hoặc chuyển `RETIRED` trong `Detail_Mapping.csv`.
       - **Tầng Registry (`datamart_model.yaml`):** Purge thuộc tính và entity khỏi Model Registry nếu không còn bảng nào sử dụng.
       - **Tầng Flat Table SQL:** Loại bỏ cột hoặc bảng khỏi `01_create_*.sql` và `02_populate_*.sql` để tránh sinh code và tiêu tốn tài nguyên ETL vô ích.
       - **Verify:** Chạy `check_orphan.py --strict` và `check_parity.py --strict` xác nhận hệ thống hoàn toàn sạch bóng các tàn dư mồ côi.
