# DTM_QLKD_Entities — Star Schema per Nhóm báo cáo
**Module:** QLKD — Quản lý kinh doanh (Hoạt động CTCK)
**Phiên bản:** 5.0 — 11/09/2026 (đồng bộ theo `DTM_QLKD_HLD.md` v5.0 — redesign cột T thay cột S; STT33/34/35 hạ PENDING; O_QLKD_20 Superseded → O_QLKD_26 mở rộng; loại bỏ toàn bộ entity PENDING 100% khỏi Entities.csv theo `phase2_entities.md`)

---

## Tab TỔNG QUAN

### Nhóm 1 — Chỉ tiêu thống kê chung (K_QLKD_1–11)

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Securities_Company_Status_Snapshot : " "
    Securities_Company_Dimension ||--o{ Fact_Securities_Company_Status_Snapshot : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Securities Company Status Snapshot | Fact Snapshot | new | Tình trạng CTCK theo trạng thái pháp lý | 1 CTCK × 1 ngày snapshot | K_QLKD_1–11 (K_QLKD_12–13 PENDING, xem O_QLKD_1) |
| Securities Company Dimension | Dimension | new | CTCK — mã, tên, loại hình, trạng thái | 1 CTCK (SCD4A) | — |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày | 1 ngày | — |

### Nhóm 5/6/7 — Duy trì điều kiện cấp phép (GPHL / KDCKPS / BTTT) (K_QLKD_30–40)

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Securities_Company_License_Condition_Snapshot : " "
    Securities_Company_Dimension ||--o{ Fact_Securities_Company_License_Condition_Snapshot : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Securities Company License Condition Snapshot | Fact Snapshot | new | Duy trì điều kiện cấp phép — dùng chung 3 nhóm, phân biệt bằng Indicator_Code | 1 CTCK × 1 loại giấy phép × 1 ngày snapshot | K_QLKD_30–40 |
| Securities Company Dimension | Dimension | new | CTCK — mã, tên, loại hình, trạng thái | 1 CTCK (SCD4A) | — |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày | 1 ngày | — |

### Nhóm 13 — Nguồn vốn tăng thêm (K_QLKD_66–72)

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Securities_Company_Capital_Raising_Event : " "
    Offering_Form_Dimension ||--o{ Fact_Securities_Company_Capital_Raising_Event : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Securities Company Capital Raising Event | Fact Event | new | Nguồn vốn tăng thêm từ chào bán/phát hành — toàn thị trường theo tháng | 1 đợt chào bán/phát hành hợp lệ (aggregated theo tháng × hình thức tăng vốn) | K_QLKD_66–72 |
| Offering Form Dimension | Dimension | new | Hình thức tăng vốn — ETL-derived (5 giá trị) | 1 hình thức (SCD4A) | — |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày (role: Result Report Date) | 1 ngày | — |

### Nhóm 16 — Diễn biến thị trường (K_QLKD_88–91)

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Market_Index_Snapshot : " "
    Market_Index_Dimension ||--o{ Fact_Market_Index_Snapshot : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Market Index Snapshot | Fact Snapshot | new | Chỉ số thị trường VN-Index/HNX/UPCOM/VN30 | 1 chỉ số (market_code) × 1 ngày (bản ghi cuối phiên) | K_QLKD_88–91 |
| Market Index Dimension | Dimension | new | Mã/loại index/sản phẩm giao dịch/trạng thái phiên. Dùng chung với NDTNN | 1 combo Market Id + Market Code (SCD4A current-state) | — |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày | 1 ngày | — |

> **Nhóm 2/3/4 (Biểu đồ Nghiệp vụ/Dịch vụ/Dịch vụ phái sinh, K_QLKD_14–29) — 100% PENDING**, không vẽ Star Schema. Xem bảng "Bảng PENDING" cuối file.
> **Nhóm 8/9 + Sub-tab Giám sát hoạt động (Nhóm 11/12/14/15/17/18) + Nhóm 19–27 (K_QLKD_41–65, 73–87, 92–141, trừ K_QLKD_88–91 đã ở Nhóm 16) — 100% PENDING**, không vẽ Star Schema. Xem bảng "Bảng PENDING" cuối file.

---

## Tab GIÁM SÁT

### Sub-tab GIÁM SÁT TUÂN THỦ — Nhóm 10 (K_QLKD_53–58, K_QLKD_4261–4264)

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Securities_Company_Compliance_Report_Snapshot : " "
    Securities_Company_Dimension ||--o{ Fact_Securities_Company_Compliance_Report_Snapshot : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Securities Company Compliance Report Snapshot | Fact Snapshot | new | Tuân thủ nộp báo cáo — UNION 2 nguồn độc lập `sc_adhoc_report` (đột xuất) + `sc_periodic_report` (định kỳ), phân biệt bằng Report Type Code | 1 CTCK × 1 loại báo cáo × 1 kỳ/ngày sự vụ | K_QLKD_53–58, K_QLKD_4261–4264 |
| Securities Company Dimension | Dimension | new | CTCK — mã, tên, loại hình, trạng thái | 1 CTCK (SCD4A) | — |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày | 1 ngày | — |

---

## Tab HỒ SƠ CTCK 360

### Sub-tab Nhân sự — Nhóm 31 (K_QLKD_155–160)

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Operational Securities Company Personnel Profile | Tác nghiệp | new | HĐQT/HĐTV/BKS/BĐH | 1 nhân sự cao cấp × 1 CTCK (latest state) | K_QLKD_155–160 |

### Sub-tab Tuân thủ — Nhóm 38/39/40 (K_QLKD_186–202) — Partial READY

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Operational Securities Company Compliance History | Tác nghiệp | new | BC nộp + quyết định xử phạt hành chính (Nhóm 38, một phần READY) + thanh tra/kiểm tra (Nhóm 40, phần lớn READY, trừ Chiều ngày PENDING) | 1 CTCK × 1 sự kiện | K_QLKD_188, 196–202 READY; K_QLKD_186–187, 189–195 PENDING (gating dữ liệu động, Nhóm 38/39) |

### Sub-tab CN, PGD, VPĐD — Nhóm 32–37 (K_QLKD_161–185) — Partial READY

```mermaid
erDiagram
    Securities_Company_Dimension ||--o{ Operational_Securities_Company_Organization_Unit_Profile : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Operational Securities Company Organization Unit Profile | Tác nghiệp | new | CN/PGD/VPĐD — số lượng theo loại (Nhóm 32, READY), Tên/Địa chỉ/Ngày thành lập/Giám đốc (Nhóm 37, READY) | 1 đơn vị × 1 CTCK | K_QLKD_161–164, 181–182, 184–185 READY; K_QLKD_165–180, 183 PENDING (Nhóm 33/34/35/36 toàn bộ + Nhóm 37 cột Nghiệp vụ — xem O_QLKD_26/O_QLKD_7) |

---

## Tab TRA CỨU CÁ NHÂN

### Nhóm 41a — Mạng lưới quan hệ 360° (K_QLKD_203–210)

```mermaid
erDiagram
    Operational_Individual_Profile ||--o{ Operational_Individual_Related_Party_Network : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Operational Individual Profile | Tác nghiệp | new | Merge Securities Company Senior Personnel (SCMS) + Securities Practitioner (NHNCK) theo CCCD — landing page tìm kiếm/chọn cá nhân | 1 cá nhân × 1 CTCK (latest state) | K_QLKD_204–205 |
| Operational Individual Related Party Network | Tác nghiệp | new | Self-reference Securities Company Insider Related Person | 1 người liên quan × 1 cá nhân chính | K_QLKD_206–210 READY; K_QLKD_203 (Chiều ngày) PENDING |

### Nhóm 41b — Hồ sơ và danh mục (K_QLKD_210–212)

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Operational Individual Listed Company Role | Tác nghiệp | new | Vai trò + số CP nắm giữ tại tổ chức khác | 1 vai trò × 1 CTCK × 1 cá nhân | K_QLKD_210–211 |
| Operational Individual Related Party Network | Tác nghiệp | reuse (Nhóm 41a) | Mạng lưới người liên quan chi tiết — dùng chung entity với Nhóm 41a | 1 người liên quan × 1 cá nhân chính | K_QLKD_206–209 (reuse) |
| Operational Individual Trading Account | Tác nghiệp | new | Tài khoản giao dịch — bao gồm cả tài khoản người liên quan | 1 tài khoản giao dịch × 1 CTCK × 1 cá nhân | K_QLKD_212 |

### Nhóm 41c — Quá trình hành nghề: Lịch sử công tác (K_QLKD_213–217)

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Operational Individual Work History | Tác nghiệp | new | Lịch sử bổ nhiệm — tên công ty, chức vụ, thời gian, trạng thái | 1 lần bổ nhiệm × 1 CTCK × 1 cá nhân | K_QLKD_214–217 READY; K_QLKD_213 (Chiều ngày) PENDING |

### Nhóm 41d — Lịch sử vi phạm & xử phạt cá nhân (K_QLKD_218–223)

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Operational Individual Violation History | Tác nghiệp | new | Quyết định xử phạt hành chính cá nhân — schema INSPECT | 1 quyết định xử phạt × 1 cá nhân | K_QLKD_219–223 READY; K_QLKD_218 (Chiều ngày) PENDING |

---

## Tab DATA EXPLORER

### Nhóm 42-145 — Tra cứu báo cáo biểu mẫu định kỳ (K_QLKD_224–4260) — 100% PENDING

> Toàn bộ PENDING dù cột T đổi nguồn tham khảo — gap là thiếu Atomic entity (họ bảng EAV `FORM_REPORT`/`REPORT_INPUT_CELL_VALUE`, xác nhận **out-of-scope** trong `atomic_out_of_scope.yaml`) + gating `Loại dữ liệu = Dữ liệu động`, không phải do câu SQL tham khảo — không vẽ Star Schema. Xem bảng "Bảng PENDING" cuối file và Section 2 HLD (bảng chi tiết theo nhóm loại báo cáo).

---

## Bảng PENDING (không thiết kế trong Phase 2)

Các bảng sau **100% KPI/Nhóm dùng đều PENDING** — theo quy tắc `phase2_entities.md`, không đưa vào `Entities.csv` (tránh Phase 1 LLD map nhầm cột vào Atomic entity/attribute chưa tồn tại). Sẽ đưa vào CSV khi có KPI/Nhóm đầu tiên chuyển READY.

| Datamart Entity | Lý do PENDING | Issue |
|---|---|---|
| ~~Business Line Dimension~~ | Superseded 11/09/2026 — gap gốc `LNK_SC_FIRM_BUSINESS_LINE` không còn đúng theo cột T, bỏ khỏi mô hình hoàn toàn (không chỉ PENDING) | O_QLKD_20 (Superseded) → O_QLKD_26 |
| Securities Service Classification Dimension | Nguồn `CAT_SERVICE_LEGAL_CAPITAL` chưa có Atomic entity — phục vụ Nhóm 2/3/4 (100% PENDING) | O_QLKD_26 |
| Report Indicator Dimension | ETL-derived, chờ Atomic entity thay thế `REPORT_CELL_VALUE`/`REPORT_INPUT_CELL_VALUE` (out-of-scope) | O_QLKD_23 / O_QLKD_27 |
| Fact Securities Company Financial Structure Snapshot | Toàn bộ Nhóm 8/9/11/12/14–27 dùng chung Fact này — `REPORT_INPUT_CELL_VALUE` xác nhận out-of-scope trong `atomic_out_of_scope.yaml` (cascade từ `MEMBER_REPORT` đã loại) | O_QLKD_23 / O_QLKD_27 |
| Securities Company Financial Report History | Lịch sử BCTC (Nhóm 26/27) — cùng gap nguồn với Fact trên | O_QLKD_23 / O_QLKD_27 |
| Securities Company Practitioner Profile | Người hành nghề CK (Nhóm 28/29/30) — đổi nguồn sang `REPORT_CELL_VALUE`/`FORM_REPORT` family, Nhóm 30 re-verify cột T phát hiện nguồn khác biệt hơn nữa (`FORM_REPORT`/`REPORT_INPUT_CELL_VALUE`, report `BCHDPS`), chưa kết luận cuối cùng | O_QLKD_23 / O_QLKD_27 / O_QLKD_28 |
| Securities Company Report Data | EAV báo cáo biểu mẫu định kỳ — Nhóm 42-145, 104 STT / 4036 chỉ tiêu, 100% PENDING | O_QLKD_23 / O_QLKD_27 |
