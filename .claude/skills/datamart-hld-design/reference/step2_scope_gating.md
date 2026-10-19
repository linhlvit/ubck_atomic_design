# Bước 2 — Scope gating và 5 nhóm PENDING — HLD Datamart

Quyết READY / PENDING / out-of-scope cho từng KPI, phân loại nguyên nhân PENDING, cú pháp ghi chú và liên kết Section 5.

## Mục lục

- BƯỚC 2 — SCOPE GATING & CÂY QUYẾT ĐỊNH 5 NHÓM PENDING
  - 2.1. Ma Trận Scope Gating Tổng Thể
  - 2.2. Cây Quyết Định 5 Nhóm Nguyên Nhân PENDING (5-Category PENDING Decision Tree)
  - 2.3. Cú Pháp Ghi Chú Bắt Buộc Trong Bảng KPI 7 Cột (Section 2)
  - 2.4. Liên Kết Bắt Buộc Với Section 5 (Vấn Đề Mở)

## BƯỚC 2 — SCOPE GATING & CÂY QUYẾT ĐỊNH 5 NHÓM PENDING

### 2.1. Ma Trận Scope Gating Tổng Thể

| KPI | Hành xử |
|---|---|
| Atomic READY + `Trang thai mapping = Done/Doing` | In-scope — thiết kế đầy đủ (READY) |
| Atomic READY + `Trang thai mapping = Pending` | PENDING — phân loại vào 1 trong 5 nhóm PENDING bên dưới |
| Atomic READY + `Trang thai mapping = blank` | PENDING — xử lý như Pending |
| Atomic PENDING | PENDING — phân loại vào 1 trong 5 nhóm PENDING bên dưới |
| Không tìm được Atomic | Out-of-scope — ghi nhận, KHÔNG thiết kế |

> **Rule quan trọng (từ thực tế thiết kế PTTT):** `Trang thai mapping = blank` **KHÔNG phải Out-of-scope** — xử lý như **Pending**. Out-of-scope chỉ áp dụng khi không tìm được Atomic entity phù hợp.

> Cột `Loại dữ liệu` của BA (`Dữ liệu tĩnh` / `Dữ liệu động` / `Chưa có CSDL - Map biểu mẫu`) **không** phải căn cứ quyết READY/PENDING — chỉ dựa trên `Trạng thái mapping`, nguồn Atomic có thật (grep manifest/YAML) và grain khớp.

> **Pattern "Fact thiếu FK":** Atomic entity nguồn đã READY nhưng Fact hiện tại thiếu FK đến một chiều cần bổ sung (VD: `Member Report Indicator Value` đã có nhưng cần thêm `Securities Company Dimension` để breakdown per-CTCK) → xếp vào **Nhóm 5 (Datamart Pending)**, lý do ghi là "Fact cần bổ sung FK đến [Dimension]", Atomic cần bổ sung ghi tên Fact + chiều cần thêm.

❌ Không reuse fact/dim từ module khác để lấp KPI thiếu Atomic.

---

### 2.2. Cây Quyết Định 5 Nhóm Nguyên Nhân PENDING (5-Category PENDING Decision Tree)

Mọi chỉ tiêu (hoặc nhóm chỉ tiêu) ở trạng thái PENDING **bắt buộc phải được phân loại vào đúng 1 trong 5 nhóm nguyên nhân chuẩn hóa** (tương thích 100% với bộ phân loại `PendingClassifier` trong `datamart_ba_cross_checker.py` và quy chuẩn LLD):

```
                                [CHỈ TIÊU PENDING]
                                         │
        ┌────────────────────────────────┴────────────────────────────────┐
        ▼                                                                 ▼
[Có yếu tố Ngoại lai / Schema Atomic?]                          [Không có yếu tố Ngoại lai]
  • Nguồn: VSD, VSDC, HOSE, HNX, SBV                                      │
  • Ghi chú: ngoại lai, chưa duyệt Atomic,                                │
    chưa có attribute, eform, contentitem...                              │
        │                                                                 │
        ▼                                                                 ▼
┌─────────────────────────────────┐                      [Có yếu tố Đa nguồn / Liên hệ thống?]
│ NHÓM 3: Thiếu nguồn dữ liệu /   │                         • Nguồn: scms_nhnck, scms_uat
│ Atomic entity ngoài scope       │                         • Ghi chú: join đa nguồn, multi-source,
│ (Trách nhiệm: Data Architecture)│                           liên hệ thống, SCMS + NHNCK
└─────────────────────────────────┘                                        │
                                                                           ├──► [Có] ──► ┌─────────────────────────────────┐
                                                                           │             │ NHÓM 4: Cần join phức tạp đa    │
                                                                           │             │ nguồn                           │
                                                                           │             │ (Trách nhiệm: Atomic Modeling)  │
                                                                           │             └─────────────────────────────────┘
                                                                           ▼
                                                                 [Kiểm tra Trạng thái BA]
                                                                    • Status != Done (Doing, Pending...)
                                                                    • Ghi chú: Chờ BA xác nhận/confirm...
                                                                           │
                                                                           ├──► [Đúng] ─► ┌─────────────────────────────────┐
                                                                           │              │ NHÓM 1: BA chưa mapping xong    │
                                                                           │              │ (Trách nhiệm: BA Team)          │
                                                                           │              └─────────────────────────────────┘
                                                                           ▼
                                                                 [Kiểm tra Nguồn từ BA]
                                                                    • Status = Done nhưng Nguồn trống / N/A
                                                                    • Ghi chú: Chưa có CSDL, chưa số hóa,
                                                                      biểu mẫu giấy, báo cáo bản cứng
                                                                           │
                                                                           ├──► [Đúng] ─► ┌─────────────────────────────────┐
                                                                           │              │ NHÓM 2: Chưa có mapping nguồn   │
                                                                           │              │ từ BA (Trách nhiệm: BA Team)    │
                                                                           │              └─────────────────────────────────┘
                                                                           ▼
                                                                 ┌─────────────────────────────────┐
                                                                 │ NHÓM 5: Datamart chưa thiết kế  │
                                                                 │ Fact/Dim                        │
                                                                 │ (Trách nhiệm: Datamart Modeling)│
                                                                 └─────────────────────────────────┘
```

#### Bảng Quy Chuẩn 5 Nhóm Nguyên Nhân PENDING:

| Nhóm | Tên Nhóm Chuẩn Hóa | Trách Nhiệm Chủ Trì | Dấu Hiệu Nhận Biết & Điều Kiện Kích Hoạt | Hành Động Tháo Gỡ Chuẩn Hóa |
|:---:|---|---|---|---|
| **Nhóm 1** | **BA chưa mapping xong** | **BA Team** | - `Trạng thái mapping` $\notin$ `{Done, Hoàn thành}` (`Doing`, `Pending`, `Draft`, ô trống).<br>- Ghi chú chứa: *"chờ BA xác nhận"*, *"chờ BA confirm"*, *"chờ BA"*, *"BA đang làm"*. | BA Team hoàn tất phân tích nghiệp vụ, quy tắc tính và nguồn dữ liệu chi tiết. |
| **Nhóm 2** | **Chưa có mapping nguồn từ BA** | **BA Team** | - `Trạng thái mapping` = `Done`, nhưng cột `Bảng nguồn` để trống, `N/A`, `(trống)`, `null`.<br>- Ghi chú/Nguồn chứa: *"chưa có CSDL"*, *"chưa có nguồn"*, *"chưa số hóa"*, *"biểu mẫu giấy"*, *"Map biểu mẫu"*, *"báo cáo bản cứng"*. | BA Team xác minh nguồn CSDL; nếu chỉ có hồ sơ giấy thì đưa vào backlog chờ số hóa. |
| **Nhóm 3** | **Thiếu nguồn dữ liệu / Atomic entity ngoài scope** | **Data Architecture / Atomic Team** | - Bảng nguồn hoặc mô tả nhắc tới hệ thống bên ngoài: `VSD`, `VSDC`, `UAT_VSDC`, `SBV`, `HOSE`, `HNX ngoài DW`, `ngoại lai`.<br>- Bảng nguồn hoặc ghi chú ghi nhận thiếu entity/cột Atomic: *"chưa duyệt Atomic"*, *"chưa có attribute"*, *"gap Atomic"*, Open Issue `O_{MODULE}_{N}`.<br>- Các chỉ tiêu thị phần, lưu ký, xử phạt vi phạm hành chính chưa có entity Atomic. | Lập danh mục nguồn ngoại lai cần ingest hoặc thiết kế bổ sung entity/attribute vào kho Atomic DWH. Bắt buộc liên kết Section 5 Open Issue. |
| **Nhóm 4** | **Cần join phức tạp đa nguồn** | **Atomic Modeling Team** | - Yêu cầu kết nối dữ liệu giữa nhiều phân hệ chưa có cấu trúc bảng nối chuẩn tại Atomic.<br>- Từ khóa: `scms_nhnck`, `scms_uat`, `join đa nguồn`, `multi-source`, `liên hệ thống`, `cross-system`, `SCMS và NHNCK`. | Atomic Modeling Team thiết kế bảng quan hệ kết nối (Bridge / Cross-system Entity) tại tầng Atomic trước khi kéo lên Datamart. Bắt buộc liên kết Section 5 Open Issue. |
| **Nhóm 5** | **Datamart chưa thiết kế Fact/Dim** | **Datamart Modeling Team** | - BA đã `Done`, nguồn Atomic nội tại đầy đủ và approved (`dm_manifest.yaml`).<br>- Datamart đang chờ phân tích kiến trúc, chưa thiết kế bảng Fact/Dim hoặc Detail Mapping đang để trống. | Datamart Team thiết kế mô hình 4 tầng (Staging -> ODS -> Atomic -> Datamart) và Detail Mapping. Bắt buộc liên kết Section 5 Open Issue nếu là blocker lớn của nhóm. |

---

### 2.3. Cú Pháp Ghi Chú Bắt Buộc Trong Bảng KPI 7 Cột (Section 2)

Với mọi dòng KPI mang trạng thái `PENDING`, cột `Ghi chú` trong bảng KPI 7 cột **bắt buộc tuân thủ cú pháp chuẩn**:
```markdown
**Lý do pending:** [Nhóm X - <Tên nhóm>]: <mô tả blocker cụ thể, ref O_{MODULE}_{N} nếu có>. **Atomic cần bổ sung:** <tên entity/table>. **Mart dự kiến:** <tên bảng> — grain: <mô tả grain>
```
Hoặc cú pháp ngắn gọn:
```markdown
Pending - [Nhóm 1-5]: <mô tả blocker cụ thể> | <dự kiến bảng mart / cấp độ hạt>
```

**Ví dụ thực tế chuẩn:**
- Nhóm 1: `**Lý do pending:** [Nhóm 1 - BA chưa mapping xong]: Chờ BA confirm quy tắc tính / nguồn dữ liệu chi tiết. **Atomic cần bổ sung:** TBD. **Mart dự kiến:** Fact Securities Trading Snapshot — grain: 1 row / symbol / trade_date`
- Nhóm 2: `**Lý do pending:** [Nhóm 2 - Chưa có mapping nguồn từ BA]: Biểu mẫu giấy BM01_VSDC chưa được số hóa vào CSDL. **Atomic cần bổ sung:** TBD. **Mart dự kiến:** Fact Shareholding Snapshot — grain: 1 row / company / month`
- Nhóm 3: `**Lý do pending:** [Nhóm 3 - Thiếu nguồn Atomic / Ngoại lai]: gap Atomic REPORT_CELL_VALUE, xem O_QLKD_23. **Atomic cần bổ sung:** Member Report Indicator Value. **Mart dự kiến:** Fact Member Financial Snapshot — grain: 1 row / firm / report_period`
- Nhóm 4: `**Lý do pending:** [Nhóm 4 - Cần join phức tạp đa nguồn]: Cần Atomic bridge liên kết SCMS và NHNCK, xem O_NHNCK_05. **Atomic cần bổ sung:** Cross System Practitioner Bridge. **Mart dự kiến:** Fact Practitioner Cross System Snapshot — grain: 1 row / practitioner / license`
- Nhóm 5: `**Lý do pending:** [Nhóm 5 - Datamart chưa thiết kế Fact/Dim]: Atomic approved (scr_mkt_idx_snpst), Datamart đang thiết kế Fact/Dim. **Atomic cần bổ sung:** Đã có đủ. **Mart dự kiến:** Fact Market Index Snapshot — grain: 1 row / index / trade_date`

---

### 2.4. Liên Kết Bắt Buộc Với Section 5 (Vấn Đề Mở)

- **Nguyên tắc liên kết:** Các blocker lớn thuộc **Nhóm 3 (Thiếu nguồn ngoại lai/Atomic ngoài scope)**, **Nhóm 4 (Cần join phức tạp đa nguồn)**, và **Nhóm 5 (Datamart chưa thiết kế Fact/Dim)** **BẮT BUỘC TẠO OPEN ISSUE** trong Section 5 của `DTM_{MODULE}_HLD.md` với mã định danh `O_{MODULE}_{N}`.
- Cột `KPI liên quan` trong bảng Section 5 phải liệt kê đầy đủ các mã `K_{MODULE}_...` chịu ảnh hưởng.
- Cột `Vấn đề` và `Giả định` trong Section 5 phải ghi rõ nhóm nguyên nhân PENDING và đơn vị chịu trách nhiệm xử lý (BA, Data Architecture / Atomic, hay Datamart Team).
- *(Lưu ý: Bãi bỏ quy định cũ từng cấm tạo Open Issue cho KPI PENDING — việc tạo Open Issue là công cụ truy vết trách nhiệm và theo dõi giải tỏa blocker kiến trúc).*
