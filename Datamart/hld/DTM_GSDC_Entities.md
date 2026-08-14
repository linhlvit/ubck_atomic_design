# DTM_GSDC_Entities — Phase 2

## Màn hình 1 — Phân loại & Xếp hạng Rủi ro CTDC (Nhóm 1-5, 32-36)

```mermaid
erDiagram
    Public_Company_Dimension ||--o{ Fact_Public_Company_Risk_Score_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Public_Company_Risk_Score_Snapshot : " "
    Public_Company_Dimension ||--o{ Fact_Public_Company_Compliance_Score_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Public_Company_Compliance_Score_Snapshot : " "
    Public_Company_Dimension ||--o{ Fact_Public_Company_Issuance_Score_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Public_Company_Issuance_Score_Snapshot : " "
    Public_Company_Dimension ||--o{ Fact_Public_Company_Financial_Score_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Public_Company_Financial_Score_Snapshot : " "
    Public_Company_Dimension ||--o{ Fact_Public_Company_Non_Financial_Score_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Public_Company_Non_Financial_Score_Snapshot : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Public Company Risk Score Snapshot | Fact Snapshot | new | Điểm chấm & xếp loại — Risk Score | 1 CTDC × 1 ngày snapshot ETL | K_GSDC_1-6 (Nhóm 1); K_GSDC_1391-1396 (Nhóm 32, KPI riêng — dùng chung Fact) |
| Fact Public Company Compliance Score Snapshot | Fact Snapshot | new | Điểm chấm & xếp loại — Compliance Score | 1 CTDC × 1 ngày snapshot ETL | K_GSDC_9-23 (Nhóm 2); K_GSDC_1399-1415 (Nhóm 33, KPI riêng — dùng chung Fact) |
| Fact Public Company Issuance Score Snapshot | Fact Snapshot | new | Điểm chấm & xếp loại — Issuance Score | 1 CTDC × 1 ngày snapshot ETL | K_GSDC_24-31 (Nhóm 3); K_GSDC_1429-1438 (Nhóm 35, KPI riêng — dùng chung Fact) |
| Fact Public Company Financial Score Snapshot | Fact Snapshot | new | Điểm chấm & xếp loại — Financial Score | 1 CTDC × 1 ngày snapshot ETL | K_GSDC_32-42 (Nhóm 4); K_GSDC_1416-1428 (Nhóm 34, KPI riêng — dùng chung Fact) |
| Fact Public Company Non-Financial Score Snapshot | Fact Snapshot | new | Điểm chấm & xếp loại — Non-Financial Score & M-Score | 1 CTDC × 1 ngày snapshot ETL | K_GSDC_43-45 (Nhóm 5); K_GSDC_1439-1443 (Nhóm 36, KPI riêng — dùng chung Fact) |

---

## Màn hình 2 — Giám sát Tổng hợp (Nhóm 6-18, 37) & Màn hình 3 — Data Explorer BCTC (Nhóm 19-30)

```mermaid
erDiagram
    Public_Company_Dimension ||--o{ Fact_Violation_Report_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Violation_Report_Snapshot : " "
    Public_Company_Dimension ||--o{ Fact_Public_Company_Financial_Report_Value : " "
    Financial_Report_Catalog_Dimension ||--o{ Fact_Public_Company_Financial_Report_Value : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Violation Report Snapshot | Fact Event | new | Nghĩa vụ báo cáo & nộp báo cáo (tỷ lệ nộp BCTC, số DN báo lãi) | 1 row/công ty/kỳ (Report_Year + Report_Quarter)/ngày ETL snapshot | K_GSDC_48/49 (Nhóm 6/10/12/14/16) |
| Fact Public Company Financial Report Value | Fact Event | new | Chi tiết BCTC từng CTDC theo dòng/cột — dùng chung Màn hình 2 (tổng hợp/theo ngành/theo sàn) và Màn hình 3 (Data Explorer) | 1 CTĐC × 1 kỳ × Row_Code × Column_Code | K_GSDC_50-92+YOY (Nhóm 7/8/11/13/15/17); K_GSDC_1444-1456 (Nhóm 37, KPI riêng — dùng chung Fact); K_GSDC_762-1380 (Nhóm 19-30, MH3 Data Explorer, KPI riêng) |
| Financial Report Catalog Dimension | Dimension | new | Template BCTC — báo cáo/dòng/cột | 1 row/báo cáo × dòng × cột | — |
| Public Company Dimension | Dimension | reuse | Mã CK, Tên DN, Sàn, Ngành | 1 row/công ty đại chúng (current state) | — |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày — Conformed toàn hệ thống | 1 row/ngày | — |

---

## Màn hình 4 — Báo cáo giám sát CTDC (Nhóm 38-41)

```mermaid
erDiagram
```

> 4 bảng Fact-report của Màn hình 4 KHÔNG có FK Dimension — đúng đặc tính Fact-report (đóng gói cố định theo kỳ, denormalize hoàn toàn, ETL populate batch trực tiếp từ Atomic). Không có quan hệ nào để vẽ trong erDiagram relationship-only.

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Public Company Regulatory Compliance Report | Fact-report | new | Báo cáo vĩ mô theo sàn (BC01.1) | 1 row/sàn NY-ĐKGD/kỳ (Report_Year + Report_Quarter) | K_GSDC_700-708 (Nhóm 38) |
| Public Company Industry Financial Report | Fact-report | new | Báo cáo vĩ mô theo ngành (BC01.2) | 1 row/ngành/năm báo cáo (kèm cột N-1) | K_GSDC_709-717 (Nhóm 39) |
| Public Company Multi-Period Financial Report | Fact-report | new | Báo cáo vĩ mô đa kỳ N/N-1/N-2 (BC01.3) | 1 row DUY NHẤT/năm báo cáo (kèm cột N-1/N-2), toàn thị trường không group-by | K_GSDC_718-739 (Nhóm 40) |
| Public Company Exchange Financial Summary Report | Fact-report | new | Tổng hợp tài chính theo sàn kèm YoY (BC22) | 1 row/sàn NY-ĐKGD/kỳ (Report_Year + Report_Quarter) | K_GSDC_740-751+YOY (Nhóm 41) |

---

## Bảng PENDING (không thiết kế trong Phase 2)

| Datamart Entity | Lý do PENDING | Issue |
|---|---|---|
| Fact Public Company Listing Info Snapshot | Nguồn MSS chưa có Atomic entity (MH5, DB33 — K_GSDC_1381-1390, Nhóm 31) | — |
