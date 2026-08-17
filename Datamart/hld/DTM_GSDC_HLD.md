# DTM_GSDC_HLD — High Level Design
**Module:** GSDC — Giám sát Công ty Đại chúng
**Phiên bản:** 3.0 — Phase 1 Draft
**Phạm vi:**
- Màn hình 1: **Phân loại & Xếp hạng Rủi ro Doanh nghiệp Đại chúng** (5 tab: Tổng hợp / Tuân thủ / Phát hành / Tài chính / Phi tài chính & M-Score)
- Màn hình 2: **Giám sát Tổng hợp** (5 tab sàn: Tổng hợp / HOSE / HNX / UPCoM / Chưa niêm yết — 3 nhóm nội dung)
- Màn hình 3 *(READY)*: **Data Explorer — Dữ liệu tài chính doanh nghiệp** (DB21–32 + DB39: chi tiết BCTC theo loại hình DN + hệ số tài chính cơ bản — dùng `Fact Public Company Financial Report Value`, Atomic đủ 5 entity Financial Report Value, quy tắc khai thác theo SQL BA áp dụng cho toàn bộ Nhóm 19-30 + 37)
- Màn hình 4: **Báo cáo giám sát CTDC** (DB40–43: BC01.1 / BC01.2 / BC01.3 / BC22 — 4 bảng Fact-report riêng, ETL populate theo batch, không FK Dimension runtime)
- Màn hình 5 *(PENDING)*: **Data Explorer — Dữ liệu thông tin niêm yết** (DB33 — nguồn MSS chưa có Atomic)
- Màn hình 6 *(READY — Atomic draft)*: **Data Explorer — Dữ liệu chấm điểm phân loại CTDC** (DB34–38 — reuse KPI từ Nhóm 1–5)

**Nguồn dữ liệu:** IDS (Information Disclosure System)

---

## Section 1 — Data Lineage

Toàn bộ 5 Nhóm (Tổng hợp, Tuân thủ, Phát hành, Tài chính, Phi tài chính & M-Score) có nguồn từ `IDS.EVALUATIONS` / `EVALUATION_DETAILS` / `EVALUATION_CRITERIA` / `EVALUATION_GROUPS` / `EVALUATION_PERIODS`. Atomic entity tương ứng `design_status: draft`, chưa approved (xem O_GSDC_1). Tách riêng theo từng Fact bên dưới để dễ theo dõi — mọi Fact đều dùng chung `Public Company Dimension` và `Calendar Date Dimension` (xem Cụm 6, Section 4 Reuse Analysis).

##### Cụm 1: Điểm chấm & Xếp loại CTDC (Fact Public Company Risk Score Snapshot) (Nhóm 1)

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        IDS_company_profiles_c1["IDS.company_profiles"]
        IDS_EVALUATIONS_c1["IDS.EVALUATIONS"]
        IDS_EVALUATION_DETAILS_c1["IDS.EVALUATION_DETAILS"]
        IDS_EVALUATION_GROUPS_c1["IDS.EVALUATION_GROUPS"]
        IDS_EVALUATION_PERIODS_c1["IDS.EVALUATION_PERIODS"]
    end
    subgraph SIL["Atomic (draft — chưa approved)"]
        Public_Company_c1["Public Company"]
        Public_Company_Evaluation_c1["Public Company Evaluation"]
        Public_Company_Evaluation_Detail_c1["Public Company Evaluation Detail"]
        Public_Company_Evaluation_Group_c1["Public Company Evaluation Group"]
        Public_Company_Evaluation_Period_c1["Public Company Evaluation Period"]
    end
    subgraph GOLD["Datamart"]
        fct_public_company_risk_score_snpst["Fact Public Company Risk Score Snapshot"]
        public_company_dim_c1["Public Company Dimension"]
        cdr_dt_dim_c1["Calendar Date Dimension"]
    end
    IDS_company_profiles_c1 --> Public_Company_c1
    IDS_EVALUATIONS_c1 --> Public_Company_Evaluation_c1
    IDS_EVALUATION_DETAILS_c1 --> Public_Company_Evaluation_Detail_c1
    IDS_EVALUATION_GROUPS_c1 --> Public_Company_Evaluation_Group_c1
    IDS_EVALUATION_PERIODS_c1 --> Public_Company_Evaluation_Period_c1
    Public_Company_c1 --> public_company_dim_c1
    Public_Company_Evaluation_Period_c1 --> cdr_dt_dim_c1
    Public_Company_Evaluation_c1 --> fct_public_company_risk_score_snpst
    Public_Company_Evaluation_Detail_c1 --> fct_public_company_risk_score_snpst
    Public_Company_Evaluation_Group_c1 --> fct_public_company_risk_score_snpst
    public_company_dim_c1 --> fct_public_company_risk_score_snpst
    cdr_dt_dim_c1 --> fct_public_company_risk_score_snpst
```

##### Cụm 2: Điểm chấm & Xếp loại CTDC (Fact Public Company Compliance Score Snapshot) (Nhóm 2)

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        IDS_company_profiles_c2["IDS.company_profiles"]
        IDS_EVALUATION_DETAILS_c2["IDS.EVALUATION_DETAILS"]
        IDS_EVALUATION_CRITERIA_c2["IDS.EVALUATION_CRITERIA"]
        IDS_EVALUATION_PERIODS_c2["IDS.EVALUATION_PERIODS"]
    end
    subgraph SIL["Atomic (draft — chưa approved)"]
        Public_Company_c2["Public Company"]
        Public_Company_Evaluation_Detail_c2["Public Company Evaluation Detail"]
        Public_Company_Evaluation_Criterion_c2["Public Company Evaluation Criterion"]
        Public_Company_Evaluation_Period_c2["Public Company Evaluation Period"]
    end
    subgraph GOLD["Datamart"]
        fct_public_company_compliance_score_snpst["Fact Public Company Compliance Score Snapshot"]
        public_company_dim_c2["Public Company Dimension"]
        cdr_dt_dim_c2["Calendar Date Dimension"]
    end
    IDS_company_profiles_c2 --> Public_Company_c2
    IDS_EVALUATION_DETAILS_c2 --> Public_Company_Evaluation_Detail_c2
    IDS_EVALUATION_CRITERIA_c2 --> Public_Company_Evaluation_Criterion_c2
    IDS_EVALUATION_PERIODS_c2 --> Public_Company_Evaluation_Period_c2
    Public_Company_c2 --> public_company_dim_c2
    Public_Company_Evaluation_Period_c2 --> cdr_dt_dim_c2
    Public_Company_Evaluation_Detail_c2 --> fct_public_company_compliance_score_snpst
    Public_Company_Evaluation_Criterion_c2 --> fct_public_company_compliance_score_snpst
    public_company_dim_c2 --> fct_public_company_compliance_score_snpst
    cdr_dt_dim_c2 --> fct_public_company_compliance_score_snpst
```

##### Cụm 3: Điểm chấm & Xếp loại CTDC (Fact Public Company Issuance Score Snapshot) (Nhóm 3)

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        IDS_company_profiles_c3["IDS.company_profiles"]
        IDS_EVALUATION_DETAILS_c3["IDS.EVALUATION_DETAILS"]
        IDS_EVALUATION_CRITERIA_c3["IDS.EVALUATION_CRITERIA"]
        IDS_EVALUATION_PERIODS_c3["IDS.EVALUATION_PERIODS"]
    end
    subgraph SIL["Atomic (draft — chưa approved)"]
        Public_Company_c3["Public Company"]
        Public_Company_Evaluation_Detail_c3["Public Company Evaluation Detail"]
        Public_Company_Evaluation_Criterion_c3["Public Company Evaluation Criterion"]
        Public_Company_Evaluation_Period_c3["Public Company Evaluation Period"]
    end
    subgraph GOLD["Datamart"]
        fct_public_company_issuance_score_snpst["Fact Public Company Issuance Score Snapshot"]
        public_company_dim_c3["Public Company Dimension"]
        cdr_dt_dim_c3["Calendar Date Dimension"]
    end
    IDS_company_profiles_c3 --> Public_Company_c3
    IDS_EVALUATION_DETAILS_c3 --> Public_Company_Evaluation_Detail_c3
    IDS_EVALUATION_CRITERIA_c3 --> Public_Company_Evaluation_Criterion_c3
    IDS_EVALUATION_PERIODS_c3 --> Public_Company_Evaluation_Period_c3
    Public_Company_c3 --> public_company_dim_c3
    Public_Company_Evaluation_Period_c3 --> cdr_dt_dim_c3
    Public_Company_Evaluation_Detail_c3 --> fct_public_company_issuance_score_snpst
    Public_Company_Evaluation_Criterion_c3 --> fct_public_company_issuance_score_snpst
    public_company_dim_c3 --> fct_public_company_issuance_score_snpst
    cdr_dt_dim_c3 --> fct_public_company_issuance_score_snpst
```

##### Cụm 4: Điểm chấm & Xếp loại CTDC (Fact Public Company Financial Score Snapshot) (Nhóm 4)

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        IDS_company_profiles_c4["IDS.company_profiles"]
        IDS_EVALUATION_DETAILS_c4["IDS.EVALUATION_DETAILS"]
        IDS_EVALUATION_CRITERIA_c4["IDS.EVALUATION_CRITERIA"]
        IDS_EVALUATION_PERIODS_c4["IDS.EVALUATION_PERIODS"]
    end
    subgraph SIL["Atomic (draft — chưa approved)"]
        Public_Company_c4["Public Company"]
        Public_Company_Evaluation_Detail_c4["Public Company Evaluation Detail"]
        Public_Company_Evaluation_Criterion_c4["Public Company Evaluation Criterion"]
        Public_Company_Evaluation_Period_c4["Public Company Evaluation Period"]
    end
    subgraph GOLD["Datamart"]
        fct_public_company_financial_score_snpst["Fact Public Company Financial Score Snapshot"]
        public_company_dim_c4["Public Company Dimension"]
        cdr_dt_dim_c4["Calendar Date Dimension"]
    end
    IDS_company_profiles_c4 --> Public_Company_c4
    IDS_EVALUATION_DETAILS_c4 --> Public_Company_Evaluation_Detail_c4
    IDS_EVALUATION_CRITERIA_c4 --> Public_Company_Evaluation_Criterion_c4
    IDS_EVALUATION_PERIODS_c4 --> Public_Company_Evaluation_Period_c4
    Public_Company_c4 --> public_company_dim_c4
    Public_Company_Evaluation_Period_c4 --> cdr_dt_dim_c4
    Public_Company_Evaluation_Detail_c4 --> fct_public_company_financial_score_snpst
    Public_Company_Evaluation_Criterion_c4 --> fct_public_company_financial_score_snpst
    public_company_dim_c4 --> fct_public_company_financial_score_snpst
    cdr_dt_dim_c4 --> fct_public_company_financial_score_snpst
```

##### Cụm 5: Điểm chấm & Xếp loại CTDC (Fact Public Company Non-Financial Score Snapshot) (Nhóm 5)

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        IDS_company_profiles_c5["IDS.company_profiles"]
        IDS_EVALUATION_DETAILS_c5["IDS.EVALUATION_DETAILS"]
        IDS_EVALUATION_CRITERIA_c5["IDS.EVALUATION_CRITERIA"]
        IDS_EVALUATION_PERIODS_c5["IDS.EVALUATION_PERIODS"]
    end
    subgraph SIL["Atomic (draft — chưa approved)"]
        Public_Company_c5["Public Company"]
        Public_Company_Evaluation_Detail_c5["Public Company Evaluation Detail"]
        Public_Company_Evaluation_Criterion_c5["Public Company Evaluation Criterion"]
        Public_Company_Evaluation_Period_c5["Public Company Evaluation Period"]
    end
    subgraph GOLD["Datamart"]
        fct_public_company_nonfinancial_score_snpst["Fact Public Company Non-Financial Score Snapshot"]
        public_company_dim_c5["Public Company Dimension"]
        cdr_dt_dim_c5["Calendar Date Dimension"]
    end
    IDS_company_profiles_c5 --> Public_Company_c5
    IDS_EVALUATION_DETAILS_c5 --> Public_Company_Evaluation_Detail_c5
    IDS_EVALUATION_CRITERIA_c5 --> Public_Company_Evaluation_Criterion_c5
    IDS_EVALUATION_PERIODS_c5 --> Public_Company_Evaluation_Period_c5
    Public_Company_c5 --> public_company_dim_c5
    Public_Company_Evaluation_Period_c5 --> cdr_dt_dim_c5
    Public_Company_Evaluation_Detail_c5 --> fct_public_company_nonfinancial_score_snpst
    Public_Company_Evaluation_Criterion_c5 --> fct_public_company_nonfinancial_score_snpst
    public_company_dim_c5 --> fct_public_company_nonfinancial_score_snpst
    cdr_dt_dim_c5 --> fct_public_company_nonfinancial_score_snpst
```

> **Ghi chú `Public Company Evaluation Period`:** Entity Atomic tương ứng `IDS.EVALUATION_PERIODS` (physical name `pc_evaluation_period`, `design_status: draft`) map trực tiếp vào `Calendar Date Dimension` (`cdr_dt_dim`) qua `evaluation_year`/`evaluation_month` — không tạo Dimension riêng, tái sử dụng `Calendar Date Dimension` đã có trong Reuse Analysis (Section 4).

##### Cụm 6: Hồ sơ Công ty Đại chúng (Public Company Dimension)

Phục vụ chiều nhận diện DN trên toàn bộ các màn hình.

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        IDS_company_profiles["IDS.company_profiles"]
        IDS_company_detail["IDS.company_detail"]
    end
    subgraph SIL["Atomic"]
        Public_Company["Public Company"]
    end
    subgraph GOLD["Datamart"]
        public_company_dim["Public Company Dimension"]
    end
    IDS_company_profiles --> Public_Company
    IDS_company_detail --> Public_Company
    Public_Company --> public_company_dim
```

##### Cụm 7: Nghĩa vụ báo cáo & Nộp báo cáo (Fact Violation Report Snapshot) (Nhóm 6)

Phục vụ K_GSDC_48 (tỷ lệ nộp BCTC, Nhóm 6/10/12/14/16) qua `Fact Violation Report Snapshot` — driving `Public Company Dimension` full-scan, filter loại tin định kỳ qua `fr_template.news_tp_code = 'DINH_KY'`. K_GSDC_49 (số DN báo lãi, cùng Nhóm) KHÔNG dùng Fact này — dùng trực tiếp `Fact Public Company Financial Report Value` (Cụm 8/Nhóm 7), xem chi tiết Nhóm 6.

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        IDS_company_profiles["IDS.company_profiles"]
        IDS_company_detail["IDS.company_detail"]
        ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
        IDS_VIOLATION_REPORT["IDS.VIOLATION_REPORT"]
        IDS_FORMS["IDS.FORMS"]
    end
    subgraph SIL["Atomic"]
        Public_Company["Public Company"]
        Calendar_Date["Calendar Date"]
        Violation_Report["Violation Report"]
        Financial_Report_Template["Financial Report Template"]
    end
    subgraph GOLD["Datamart"]
        public_company_dim["Public Company Dimension"]
        cdr_dt_dim["Calendar Date Dimension"]
        fct_violation_rpt_snpst["Fact Violation Report Snapshot"]
    end
    IDS_company_profiles --> Public_Company
    IDS_company_detail --> Public_Company
    ECAT_ECAT_29_HolidayInfo --> Calendar_Date
    IDS_VIOLATION_REPORT --> Violation_Report
    IDS_FORMS --> Financial_Report_Template
    Public_Company --> public_company_dim
    Calendar_Date --> cdr_dt_dim
    public_company_dim --> fct_violation_rpt_snpst
    cdr_dt_dim --> fct_violation_rpt_snpst
    Violation_Report --> fct_violation_rpt_snpst
    Financial_Report_Template --> fct_violation_rpt_snpst
```

> `Fact Violation Report Snapshot` giờ chỉ phục vụ K_GSDC_48 (Report_Due_Count/Report_Submitted_Count) — không còn denormalize `Profitable_Indicator` từ `fr_value` (đã bỏ, xem Nhóm 6). Lineage đầy đủ của `Financial Report Value`/`Financial Report Catalog`/`Row Template`/`Column Template` (dùng cho K_GSDC_49) xem Cụm 8.

##### Cụm 8: Chi tiết BCTC từng CTDC & Danh mục template (Fact Public Company Financial Report Value) (Nhóm 7-30, 37)

Phục vụ toàn bộ KPI tài chính tổng hợp/theo ngành/theo sàn (Màn hình 2) và Data Explorer tra cứu chi tiết BCTC (Màn hình 3) qua `Fact Public Company Financial Report Value` — driving `fr_value`, JOIN `financial_report_catalog`/`fr_row_template`/`fr_column_template` (denormalize vào `Financial Report Catalog Dimension`), `EXISTS pc_report_submission` làm filter tồn tại hồ sơ nộp (không lấy measure). Quy tắc khai thác đầy đủ xem Nhóm 7. Nhóm 38-41 (BC01.1/01.2/01.3/BC22) dùng 4 bảng Fact-report riêng (Cụm 9-12), không dùng Fact/Operational này.

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        IDS_company_profiles_c4["IDS.company_profiles"]
        IDS_company_detail_c4["IDS.company_detail"]
        IDS_company_data_c4["IDS.company_data"]
        IDS_data_c4["IDS.data"]
        IDS_report_catalog_c4["IDS.report_catalog"]
        IDS_rrow_c4["IDS.rrow"]
        IDS_rcol_c4["IDS.rcol"]
        ECAT_ECAT_29_HolidayInfo_c4["ECAT.ECAT_29_HolidayInfo"]
    end
    subgraph SIL["Atomic"]
        Public_Company_c4["Public Company"]
        Public_Company_Report_Submission_c4["Public Company Report Submission"]
        Financial_Report_Value_c4["Financial Report Value"]
        Financial_Report_Catalog_c4["Financial Report Catalog"]
        Financial_Report_Row_Template_c4["Financial Report Row Template"]
        Financial_Report_Column_Template_c4["Financial Report Column Template"]
        Calendar_Date_c4["Calendar Date"]
    end
    subgraph GOLD["Datamart"]
        fct_public_company_financial_rpt_val["Fact Public Company Financial Report Value"]
        financial_rpt_catalog_dim["Financial Report Catalog Dimension"]
        public_company_dim_c4["Public Company Dimension"]
        cdr_dt_dim_c4["Calendar Date Dimension"]
    end
    IDS_company_profiles_c4 --> Public_Company_c4
    IDS_company_detail_c4 --> Public_Company_c4
    IDS_company_data_c4 --> Public_Company_Report_Submission_c4
    IDS_data_c4 --> Financial_Report_Value_c4
    IDS_report_catalog_c4 --> Financial_Report_Catalog_c4
    IDS_rrow_c4 --> Financial_Report_Row_Template_c4
    IDS_rcol_c4 --> Financial_Report_Column_Template_c4
    ECAT_ECAT_29_HolidayInfo_c4 --> Calendar_Date_c4
    Public_Company_c4 --> public_company_dim_c4
    Financial_Report_Value_c4 --> fct_public_company_financial_rpt_val
    Public_Company_Report_Submission_c4 --> fct_public_company_financial_rpt_val
    Financial_Report_Catalog_c4 --> financial_rpt_catalog_dim
    Financial_Report_Row_Template_c4 --> financial_rpt_catalog_dim
    Financial_Report_Column_Template_c4 --> financial_rpt_catalog_dim
    Calendar_Date_c4 --> cdr_dt_dim_c4
    public_company_dim_c4 --> fct_public_company_financial_rpt_val
    cdr_dt_dim_c4 --> fct_public_company_financial_rpt_val
    financial_rpt_catalog_dim --> fct_public_company_financial_rpt_val
```

---

##### Cụm 9: Báo cáo vĩ mô theo sàn (Public Company Regulatory Compliance Report) (Nhóm 38)

Phục vụ K_GSDC_700-708 (BC01.1) qua `Public Company Regulatory Compliance Report` — Fact-report denormalize hoàn toàn, ETL populate theo batch mỗi kỳ (Report_Year + Report_Quarter), không FK Dimension runtime.

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        IDS_company_profiles_c9["IDS.company_profiles"]
        IDS_company_data_c9["IDS.company_data"]
        IDS_data_c9["IDS.data"]
        IDS_report_catalog_c9["IDS.report_catalog"]
        IDS_rrow_c9["IDS.rrow"]
        IDS_rcol_c9["IDS.rcol"]
    end
    subgraph SIL["Atomic"]
        Public_Company_c9["Public Company"]
        Public_Company_Report_Submission_c9["Public Company Report Submission"]
        Financial_Report_Value_c9["Financial Report Value"]
        Financial_Report_Catalog_c9["Financial Report Catalog"]
        Financial_Report_Row_Template_c9["Financial Report Row Template"]
        Financial_Report_Column_Template_c9["Financial Report Column Template"]
    end
    subgraph GOLD["Datamart"]
        public_company_regulatory_compliance_rpt["Public Company Regulatory Compliance Report"]
    end
    IDS_company_profiles_c9 --> Public_Company_c9
    IDS_company_data_c9 --> Public_Company_Report_Submission_c9
    IDS_data_c9 --> Financial_Report_Value_c9
    IDS_report_catalog_c9 --> Financial_Report_Catalog_c9
    IDS_rrow_c9 --> Financial_Report_Row_Template_c9
    IDS_rcol_c9 --> Financial_Report_Column_Template_c9
    Public_Company_c9 --> public_company_regulatory_compliance_rpt
    Public_Company_Report_Submission_c9 --> public_company_regulatory_compliance_rpt
    Financial_Report_Value_c9 --> public_company_regulatory_compliance_rpt
    Financial_Report_Catalog_c9 --> public_company_regulatory_compliance_rpt
    Financial_Report_Row_Template_c9 --> public_company_regulatory_compliance_rpt
    Financial_Report_Column_Template_c9 --> public_company_regulatory_compliance_rpt
```

---

##### Cụm 10: Báo cáo vĩ mô theo ngành (Public Company Industry Financial Report) (Nhóm 39)

Phục vụ K_GSDC_709-717 (BC01.2) qua `Public Company Industry Financial Report` — Fact-report denormalize hoàn toàn, ETL populate theo batch mỗi năm báo cáo, không FK Dimension runtime.

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        IDS_company_profiles_c10["IDS.company_profiles"]
        IDS_data_c10["IDS.data"]
        IDS_report_catalog_c10["IDS.report_catalog"]
        IDS_rrow_c10["IDS.rrow"]
        IDS_rcol_c10["IDS.rcol"]
    end
    subgraph SIL["Atomic"]
        Public_Company_c10["Public Company"]
        Financial_Report_Value_c10["Financial Report Value"]
        Financial_Report_Catalog_c10["Financial Report Catalog"]
        Financial_Report_Row_Template_c10["Financial Report Row Template"]
        Financial_Report_Column_Template_c10["Financial Report Column Template"]
    end
    subgraph GOLD["Datamart"]
        public_company_industry_financial_rpt["Public Company Industry Financial Report"]
    end
    IDS_company_profiles_c10 --> Public_Company_c10
    IDS_data_c10 --> Financial_Report_Value_c10
    IDS_report_catalog_c10 --> Financial_Report_Catalog_c10
    IDS_rrow_c10 --> Financial_Report_Row_Template_c10
    IDS_rcol_c10 --> Financial_Report_Column_Template_c10
    Public_Company_c10 --> public_company_industry_financial_rpt
    Financial_Report_Value_c10 --> public_company_industry_financial_rpt
    Financial_Report_Catalog_c10 --> public_company_industry_financial_rpt
    Financial_Report_Row_Template_c10 --> public_company_industry_financial_rpt
    Financial_Report_Column_Template_c10 --> public_company_industry_financial_rpt
```

---

##### Cụm 11: Báo cáo vĩ mô đa kỳ (Public Company Multi-Period Financial Report) (Nhóm 40)

Phục vụ K_GSDC_718-739 (BC01.3) qua `Public Company Multi-Period Financial Report` — Fact-report denormalize hoàn toàn, aggregate toàn thị trường (không group-by), ETL populate theo batch mỗi năm báo cáo.

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        IDS_data_c11["IDS.data"]
        IDS_report_catalog_c11["IDS.report_catalog"]
        IDS_rrow_c11["IDS.rrow"]
        IDS_rcol_c11["IDS.rcol"]
    end
    subgraph SIL["Atomic"]
        Financial_Report_Value_c11["Financial Report Value"]
        Financial_Report_Catalog_c11["Financial Report Catalog"]
        Financial_Report_Row_Template_c11["Financial Report Row Template"]
        Financial_Report_Column_Template_c11["Financial Report Column Template"]
    end
    subgraph GOLD["Datamart"]
        public_company_multi_period_financial_rpt["Public Company Multi-Period Financial Report"]
    end
    IDS_data_c11 --> Financial_Report_Value_c11
    IDS_report_catalog_c11 --> Financial_Report_Catalog_c11
    IDS_rrow_c11 --> Financial_Report_Row_Template_c11
    IDS_rcol_c11 --> Financial_Report_Column_Template_c11
    Financial_Report_Value_c11 --> public_company_multi_period_financial_rpt
    Financial_Report_Catalog_c11 --> public_company_multi_period_financial_rpt
    Financial_Report_Row_Template_c11 --> public_company_multi_period_financial_rpt
    Financial_Report_Column_Template_c11 --> public_company_multi_period_financial_rpt
```

---

##### Cụm 12: Tổng hợp tài chính theo sàn kèm YoY (Public Company Exchange Financial Summary Report) (Nhóm 41)

Phục vụ K_GSDC_740-751+YOY (BC22) qua `Public Company Exchange Financial Summary Report` — Fact-report denormalize hoàn toàn, ETL populate theo batch mỗi kỳ (Report_Year + Report_Quarter), tính sẵn YoY khi populate.

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        IDS_company_profiles_c12["IDS.company_profiles"]
        IDS_data_c12["IDS.data"]
        IDS_report_catalog_c12["IDS.report_catalog"]
        IDS_rrow_c12["IDS.rrow"]
        IDS_rcol_c12["IDS.rcol"]
    end
    subgraph SIL["Atomic"]
        Public_Company_c12["Public Company"]
        Financial_Report_Value_c12["Financial Report Value"]
        Financial_Report_Catalog_c12["Financial Report Catalog"]
        Financial_Report_Row_Template_c12["Financial Report Row Template"]
        Financial_Report_Column_Template_c12["Financial Report Column Template"]
    end
    subgraph GOLD["Datamart"]
        public_company_exchange_financial_summary_rpt["Public Company Exchange Financial Summary Report"]
    end
    IDS_company_profiles_c12 --> Public_Company_c12
    IDS_data_c12 --> Financial_Report_Value_c12
    IDS_report_catalog_c12 --> Financial_Report_Catalog_c12
    IDS_rrow_c12 --> Financial_Report_Row_Template_c12
    IDS_rcol_c12 --> Financial_Report_Column_Template_c12
    Public_Company_c12 --> public_company_exchange_financial_summary_rpt
    Financial_Report_Value_c12 --> public_company_exchange_financial_summary_rpt
    Financial_Report_Catalog_c12 --> public_company_exchange_financial_summary_rpt
    Financial_Report_Row_Template_c12 --> public_company_exchange_financial_summary_rpt
    Financial_Report_Column_Template_c12 --> public_company_exchange_financial_summary_rpt
```

---

## Section 2 — Tổng quan báo cáo

---

### Màn hình 1 — Phân loại & Xếp hạng Rủi ro CTDC

#### Nhóm 1 — STT 1: Tổng hợp chấm điểm phân loại CTDC

> Phân loại: **Phân tích**
> Atomic: `Public Company` ← IDS.company_profiles — **draft** (chưa approved)
> Atomic: `Public Company Evaluation` ← IDS.EVALUATIONS — **draft** (chưa approved)
> Atomic: `Public Company Evaluation Detail` ← IDS.EVALUATION_DETAILS — **draft** (chưa approved)
> Atomic: `Public Company Evaluation Criterion` ← IDS.EVALUATION_CRITERIA — **draft** (chưa approved)
> Atomic: `Public Company Evaluation Group` ← IDS.EVALUATION_GROUPS — **draft** (chưa approved)
> **Lưu ý go-live:** Các entity Atomic trên đã có LLD tại `DataModel/working/Atomic/lld/IDS/` nhưng `design_status: draft`, chưa qua approve. Datamart chỉ chính thức READY sau khi Atomic được approve — xem [O_GSDC_1] cập nhật bên dưới.

**Mockup:**

| Tên Doanh nghiệp | Mã DN | Tuân thủ | Phát hành | Tài chính | Phi TC | M-Score | Xếp hạng TN | Điểm | Xếp loại |
|---|---|---|---|---|---|---|---|---|---|
| Công ty tập đoàn địa ốc Novaland | NVL | 85 | 90 | 78 | 82 | 88 | Tốt | 84.6 | A |

**Source:** `Fact Public Company Risk Score Snapshot` → `Public Company Dimension`, `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_1 | Tuân thủ | Điểm | Cơ sở | SUM(evaluation_score) WHERE group_code = 'TUAN_THU' | Public Company Evaluation Detail JOIN Criterion → Group | READY |
| K_GSDC_2 | Phát hành | Điểm | Cơ sở | SUM(evaluation_score) WHERE group_code = 'PHAT_HANH' | Public Company Evaluation Detail JOIN Criterion → Group | READY |
| K_GSDC_3 | Tài chính | Điểm | Cơ sở | SUM(evaluation_score) WHERE group_code = 'TAI_CHINH' | Public Company Evaluation Detail JOIN Criterion → Group | READY |
| K_GSDC_4 | Phi tài chính & M-Score | Điểm | Cơ sở | SUM(evaluation_score) WHERE group_code = 'PHI_TAI_CHINH' | Public Company Evaluation Detail JOIN Criterion → Group | READY |
| K_GSDC_5 | Xếp hạng tín nhiệm DN | Điểm | Cơ sở | evaluation_score (trực tiếp, không SUM) WHERE criterion_code = 'PHAT_HANH_TIN_NHIEM' | BA còn trả kèm ed.result (kết quả text) — thừa, không đưa vào KPI | READY |
| K_GSDC_6 | Điểm tổng hợp | Điểm | Cơ sở | total_score_percentage (trực tiếp) | Public Company Evaluation. BA còn trả kèm ev.type (xếp loại) — thừa, không đưa vào KPI | READY |
| K_GSDC_7 | Mã CK doanh nghiệp | Text | Chiều | equity_ticker_symbol (trực tiếp) | Public Company | READY |
| K_GSDC_8 | Tên doanh nghiệp | Text | Chiều | pc_nm (trực tiếp) | Public Company | READY |

**Star Schema:**

```mermaid
erDiagram
    Fact_Public_Company_Risk_Score_Snapshot {
        string Public_Company_Dimension_Id PK
        string Snapshot_Date_Dimension_Id PK
        string Evaluation_Date_Dimension_Id FK
        string Evaluation_Year
        string Evaluation_Month
        float Compliance_Score
        float Issuance_Score
        float Financial_Score
        float NonFinancial_MScore_Score
        float Credit_Rating_Score
        float Total_Score_Percentage
    }

    Public_Company_Dimension {
        string Public_Company_Dimension_Id PK
        string Public_Company_Code
        string Equity_Ticker_Code
        string Public_Company_Name
        string Public_Company_Status_Code
        string Equity_Listing_Exchange_Code
        string Enterprise_Type_Code
        string Business_Line_Level_1_Code
        string Life_Cycle_Status_Code
        date IDS_Registration_Date
        string Source_System_Code
    }

    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }

    Fact_Public_Company_Risk_Score_Snapshot }o--|| Public_Company_Dimension : "Public_Company_Dimension_Id"
    Fact_Public_Company_Risk_Score_Snapshot }o--|| Calendar_Date_Dimension : "Snapshot_Date_Dimension_Id"
    Fact_Public_Company_Risk_Score_Snapshot }o--o| Calendar_Date_Dimension : "Evaluation_Date_Dimension_Id"
```

> **Ghi chú grain & ETL:** Grain = "1 row/CTDC/ngày snapshot ETL" — driving table là `Public Company Dimension` (full-scan toàn bộ CTĐC mỗi ngày, vì không biết trước công ty nào phát sinh kỳ đánh giá mới vào ngày nào). Với mỗi công ty, các measure (Compliance/Issuance/Financial/NonFinancial/Credit Rating/Total Score) carry-forward từ kỳ đánh giá gần nhất (`Evaluation Date <= ngày ETL`, LEFT JOIN, nullable khi công ty chưa từng có kỳ đánh giá). `Snapshot Date Dimension Id` là PK (ngày chạy ETL); `Evaluation Date Dimension Id` là thuộc tính carry-forward (ngày kỳ đánh giá thật, không phải PK) — áp dụng đồng nhất cho cả 5 Fact `Fact Public Company *_Score_Snapshot` (Risk/Compliance/Issuance/Financial/Non-Financial).
>
> **Ghi chú filter kỳ theo tháng:** Màn hình cần filter theo kỳ đánh giá dạng tháng (VD `:p_year`/`:p_month` — xem SQL BA `WHERE ep.year = :p_year AND ep.month = :p_month`), nhưng `Evaluation Date` (ngày chạy đánh giá thực tế) có thể rơi vào tháng khác với kỳ mà nó đại diện (VD kỳ đánh giá tháng 7 nhưng `evaluation_dt` là ngày 06/08) — không thể suy luận kỳ bằng `Month(Evaluation Date)`. Có 2 cột `Evaluation Year` (physical `evaluation_year`) + `Evaluation Month` (physical `evaluation_month`) — cả 2 Text, nullable, cùng tính carry-forward với `Evaluation Date Dimension Id` — lấy trực tiếp (không CONCAT) từ `Public Company Evaluation Period.evaluation_year` / `evaluation_month` — áp dụng đồng nhất cho cả 5 Fact `Fact Public Company *_Score_Snapshot`. UI filter theo tháng dùng `WHERE Evaluation_Year = :p_year AND Evaluation_Month = :p_month`, độc lập với `Evaluation Date Dimension Id`.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    pc_risk_fct["Fact Public Company Risk Score Snapshot"] --> R1["Bảng Xếp hạng — Tuân thủ/Phát hành/Tài chính/Phi TC/Xếp hạng TN/Điểm"]
    public_company_dim["Public Company Dimension"] --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fact Public Company Risk Score Snapshot | 1 row / công ty đại chúng / ngày snapshot ETL (full-scan daily, carry-forward điểm số từ kỳ đánh giá gần nhất) |
| Public Company Dimension | 1 row / công ty đại chúng (SCD4A) |
| Calendar Date Dimension | 1 row / ngày (Conformed) |

---

#### Nhóm 2 — STT 2: Top CTDC theo chỉ tiêu tuân thủ

> Phân loại: **Phân tích**
> Atomic: `Public Company Evaluation Detail` ← IDS.EVALUATION_DETAILS — **draft** (chưa approved)
> Atomic: `Public Company Evaluation Criterion` ← IDS.EVALUATION_CRITERIA — **draft** (chưa approved)
> **Lưu ý go-live:** Atomic entity liên quan chưa qua approve — xem [O_GSDC_1].

**KPI liên quan:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_7 | Mã CK doanh nghiệp | Text | Chiều | equity_ticker_symbol (trực tiếp) | **Reuse từ Nhóm 1** — không tính lại | READY |
| K_GSDC_8 | Tên doanh nghiệp | Text | Chiều | pc_nm (trực tiếp) | **Reuse từ Nhóm 1** — không tính lại | READY |
| K_GSDC_9 | Công bố BCTC | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TUAN_THU_BCTC' | Public Company Evaluation Detail | READY |
| K_GSDC_10 | Công bố BCTN | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TUAN_THU_BCTN' | Public Company Evaluation Detail | READY |
| K_GSDC_11 | Công bố báo cáo tình hình quản trị | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TUAN_THU_BCTHQT' | Public Company Evaluation Detail | READY |
| K_GSDC_12 | Công bố thông tin Thay đổi TGĐ/CTHĐQT | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TUAN_THU_CBTTBT_TDTGD' | Public Company Evaluation Detail | READY |
| K_GSDC_13 | Vi phạm từ UBCKNN | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TUAN_THU_VP_UBCK' | Public Company Evaluation Detail | READY |
| K_GSDC_14 | Vi phạm từ các đơn vị khác | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TUAN_THU_CBTTBT_VPVT' | Public Company Evaluation Detail | READY |
| K_GSDC_15 | Điều lệ Công ty và Các Quy chế hoạt động | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TUAN_THU_QTCT_DLCT' | Public Company Evaluation Detail | READY |
| K_GSDC_16 | Số lượng ĐHĐCĐ thường niên trong 6 tháng đầu năm | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TUAN_THU_QTCT_SLDHDCD' | Public Company Evaluation Detail | READY |
| K_GSDC_17 | Số lượng thành viên HĐQT độc lập | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TUAN_THU_QTCT_SLTVDL' | Public Company Evaluation Detail | READY |
| K_GSDC_18 | Số lượng thành viên HĐQT không điều hành | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TUAN_THU_QTCT_SLTVKDH' | Public Company Evaluation Detail | READY |
| K_GSDC_19 | Tư cách thành viên HĐQT/BKS/Kế toán trưởng | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TUAN_THU_QTCT_TCTV' | Public Company Evaluation Detail | READY |
| K_GSDC_20 | Số lượng thành viên BKS hoặc Ủy ban kiểm toán | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TUAN_THU_QTCT_SLTVBKS' | Public Company Evaluation Detail | READY |
| K_GSDC_21 | Báo cáo tiến độ sử dụng vốn | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TUAN_THU_BCSDV_BCTDSDV' | Public Company Evaluation Detail | READY |
| K_GSDC_22 | Thay đổi phương án sử dụng vốn | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TUAN_THU_BCSDV_TDPASDV' | Public Company Evaluation Detail | READY |
| K_GSDC_23 | Tổng điểm Tuân thủ | Điểm | Cơ sở | SUM(evaluation_score) WHERE group_cd = 'TUAN_THU' | Public Company Evaluation Detail | READY |

**Ghi chú tách KPI:** BA đã tách "Công bố thông tin về vi phạm, quyết định xử phạt" thành 2 tiêu chí riêng biệt trong nguồn (`criterion_cd` khác nhau): "Vi phạm từ UBCKNN" (`TUAN_THU_VP_UBCK`, K_GSDC_13) và "Vi phạm từ các đơn vị khác" (`TUAN_THU_CBTTBT_VPVT`, K_GSDC_14).

**Ghi chú lọc chung:** Mọi KPI Base join `Public Company Evaluation Detail (ed)` → `Public Company Evaluation Criterion (ec)` qua `pc_evaluation_criterion_id`, filter theo `pc_evaluation_criterion_code` tương ứng cột "Điều kiện lọc" ở trên. BA còn trả kèm `ed.result` (kết quả text) cho mỗi dòng — theo xác nhận Nhóm 1, cột này không đưa vào KPI (chỉ dùng `evaluation_score`).

**Source:** `Fact Public Company Compliance Score Snapshot` → `Public Company Dimension`, `Calendar Date Dimension`

**Star Schema:**

```mermaid
erDiagram
    Fact_Public_Company_Compliance_Score_Snapshot {
        string Public_Company_Dimension_Id PK
        string Snapshot_Date_Dimension_Id PK
        string Evaluation_Date_Dimension_Id FK
        string Evaluation_Year
        string Evaluation_Month
        int Disclosure_Bctc_Score
        int Disclosure_Bctn_Score
        int Disclosure_Governance_Report_Score
        int Disclosure_Ceo_Change_Score
        int Violation_Ubck_Score
        int Violation_Other_Score
        int Charter_Regulation_Score
        int Annual_Meeting_Count_Score
        int Independent_Board_Member_Count_Score
        int Non_Executive_Board_Member_Count_Score
        int Board_Member_Qualification_Score
        int Supervisory_Board_Count_Score
        int Capital_Use_Progress_Report_Score
        int Capital_Use_Plan_Change_Score
        int Total_Compliance_Score
    }

    Public_Company_Dimension {
        string Public_Company_Dimension_Id PK
        string Public_Company_Code
        string Equity_Ticker_Code
        string Public_Company_Name
        string Public_Company_Status_Code
        string Equity_Listing_Exchange_Code
        string Enterprise_Type_Code
        string Business_Line_Level_1_Code
        string Life_Cycle_Status_Code
        date IDS_Registration_Date
        string Source_System_Code
    }

    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }

    Fact_Public_Company_Compliance_Score_Snapshot }o--|| Public_Company_Dimension : "Public_Company_Dimension_Id"
    Fact_Public_Company_Compliance_Score_Snapshot }o--|| Calendar_Date_Dimension : "Snapshot_Date_Dimension_Id"
    Fact_Public_Company_Compliance_Score_Snapshot }o--o| Calendar_Date_Dimension : "Evaluation_Date_Dimension_Id"
```

> Grain + carry-forward logic giống hệt `Fact Public Company Risk Score Snapshot` (Nhóm 1) — xem ghi chú chi tiết ở đó. Mỗi criterion (K_GSDC_9–22) là 1 measure riêng trên Fact — pivot từ `pc_evaluation_detail.evaluation_score` theo từng `pc_evaluation_criterion_code` cố định (LEFT JOIN riêng biệt cho mỗi cột); `Total_Compliance_Score` (K_GSDC_23) = `SUM(evaluation_score)` filter `pc_evaluation_group_code = 'TUAN_THU'`.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    pc_compliance_fct["Fact Public Company Compliance Score Snapshot"] --> R2["K_GSDC_7-8,9-23: Top CTDC theo chỉ tiêu tuân thủ"]
    public_company_dim_g2["Public Company Dimension"] --> R2
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fact Public Company Compliance Score Snapshot | 1 row / công ty đại chúng / ngày snapshot ETL (full-scan daily, carry-forward điểm số từ kỳ đánh giá gần nhất) |
| Public Company Dimension | 1 row / công ty đại chúng (SCD4A) |
| Calendar Date Dimension | 1 row / ngày (Conformed) |

---

#### Nhóm 3 — STT 3: Top CTDC theo chỉ tiêu phát hành

> Phân loại: **Phân tích**
> Atomic: `Public Company Evaluation Detail` ← IDS.EVALUATION_DETAILS — **draft** (chưa approved)
> Atomic: `Public Company Evaluation Criterion` ← IDS.EVALUATION_CRITERIA — **draft** (chưa approved)
> **Lưu ý go-live:** Atomic entity liên quan chưa qua approve — xem [O_GSDC_1].

**KPI liên quan:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_7 | Mã doanh nghiệp | Text | Chiều | equity_ticker_symbol (trực tiếp) | **Reuse từ Nhóm 1** — không tính lại | READY |
| K_GSDC_8 | Tên doanh nghiệp | Text | Chiều | pc_nm (trực tiếp) | **Reuse từ Nhóm 1** — không tính lại | READY |
| K_GSDC_24 | Phát hành tăng vốn nhanh | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'PHAT_HANH_TANG_VON_NHANH' | Public Company Evaluation Detail | READY |
| K_GSDC_25 | Số lần chào bán cổ phiếu riêng lẻ | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'PHAT_HANH_SLCBCPRL' | Public Company Evaluation Detail | READY |
| K_GSDC_26 | Số lần chào bán ra công chúng | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'PHAT_HANH_SLCBRCC' | Public Company Evaluation Detail | READY |
| K_GSDC_27 | Số lần phát hành ESOP | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'PHAT_HANH_SLPHES' | Public Company Evaluation Detail | READY |
| K_GSDC_28 | Tỷ lệ phát hành trái phiếu không có TSBĐ | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'PHAT_HANH_TLGTTP' | Public Company Evaluation Detail | READY |
| K_GSDC_29 | Xếp hạng tín nhiệm | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'PHAT_HANH_TIN_NHIEM' | Public Company Evaluation Detail | READY |
| K_GSDC_30 | Dư nợ trái phiếu / Tổng VCSH | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'PHAT_HANH_DNTPTVCSH' | Public Company Evaluation Detail | READY |
| K_GSDC_31 | Tổng điểm Phát hành | Điểm | Cơ sở | SUM(evaluation_score) WHERE group_cd = 'PHAT_HANH' | Public Company Evaluation Detail | READY |

**Ghi chú K_GSDC_29:** Xếp hạng tín nhiệm, `pc_evaluation_criterion_code = PHAT_HANH_TIN_NHIEM`.

**Ghi chú lọc chung:** Mọi KPI Base join `Public Company Evaluation Detail (ed)` → `Public Company Evaluation Criterion (ec)` qua `pc_evaluation_criterion_id`, filter theo `pc_evaluation_criterion_code` tương ứng cột "Điều kiện lọc" ở trên.

**Source:** `Fact Public Company Issuance Score Snapshot` → `Public Company Dimension`, `Calendar Date Dimension`

**Star Schema:**

```mermaid
erDiagram
    Fact_Public_Company_Issuance_Score_Snapshot {
        string Public_Company_Dimension_Id PK
        string Snapshot_Date_Dimension_Id PK
        string Evaluation_Date_Dimension_Id FK
        string Evaluation_Year
        string Evaluation_Month
        int Rapid_Capital_Increase_Score
        int Private_Placement_Count_Score
        int Public_Offering_Count_Score
        int Esop_Issuance_Count_Score
        int Unsecured_Bond_Ratio_Score
        int Credit_Rating_Score_Issuance
        int Bond_Debt_To_Equity_Score
        int Total_Issuance_Score
    }

    Public_Company_Dimension {
        string Public_Company_Dimension_Id PK
        string Public_Company_Code
        string Equity_Ticker_Code
        string Public_Company_Name
        string Public_Company_Status_Code
        string Equity_Listing_Exchange_Code
        string Enterprise_Type_Code
        string Business_Line_Level_1_Code
        string Life_Cycle_Status_Code
        date IDS_Registration_Date
        string Source_System_Code
    }

    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }

    Fact_Public_Company_Issuance_Score_Snapshot }o--|| Public_Company_Dimension : "Public_Company_Dimension_Id"
    Fact_Public_Company_Issuance_Score_Snapshot }o--|| Calendar_Date_Dimension : "Snapshot_Date_Dimension_Id"
    Fact_Public_Company_Issuance_Score_Snapshot }o--o| Calendar_Date_Dimension : "Evaluation_Date_Dimension_Id"
```

> Grain + carry-forward logic giống hệt `Fact Public Company Risk Score Snapshot` (Nhóm 1). Mỗi criterion (K_GSDC_24–30) là 1 measure riêng — pivot từ `pc_evaluation_detail.evaluation_score` theo từng `pc_evaluation_criterion_code` cố định; `Total_Issuance_Score` (K_GSDC_31) = `SUM(evaluation_score)` filter `pc_evaluation_group_code = 'PHAT_HANH'`.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    pc_issuance_fct["Fact Public Company Issuance Score Snapshot"] --> R3["K_GSDC_7-8,24-31: Top CTDC theo chỉ tiêu phát hành"]
    public_company_dim_g3["Public Company Dimension"] --> R3
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fact Public Company Issuance Score Snapshot | 1 row / công ty đại chúng / ngày snapshot ETL (full-scan daily, carry-forward điểm số từ kỳ đánh giá gần nhất) |
| Public Company Dimension | 1 row / công ty đại chúng (SCD4A) |
| Calendar Date Dimension | 1 row / ngày (Conformed) |

---

#### Nhóm 4 — STT 4: Top CTDC theo chỉ tiêu tài chính

> Phân loại: **Phân tích**
> Atomic: `Public Company Evaluation Detail` ← IDS.EVALUATION_DETAILS — **draft** (chưa approved)
> Atomic: `Public Company Evaluation Criterion` ← IDS.EVALUATION_CRITERIA — **draft** (chưa approved)
> **Lưu ý go-live:** Atomic entity liên quan chưa qua approve — xem [O_GSDC_1].

**KPI liên quan:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_7 | Mã doanh nghiệp | Text | Chiều | equity_ticker_symbol (trực tiếp) | **Reuse từ Nhóm 1** — không tính lại | READY |
| K_GSDC_8 | Tên doanh nghiệp | Text | Chiều | pc_nm (trực tiếp) | **Reuse từ Nhóm 1** — không tính lại | READY |
| K_GSDC_32 | Kiểm toán — Ý kiến kiểm toán | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TAI_CHINH_YKKT' | Public Company Evaluation Detail | READY |
| K_GSDC_33 | ROA | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TAI_CHINH_ROA' | Public Company Evaluation Detail | READY |
| K_GSDC_34 | Dòng tiền từ hoạt động kinh doanh | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TAI_CHINH_DTTHDKD' | Public Company Evaluation Detail | READY |
| K_GSDC_35 | Khả năng thanh toán hiện thời | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TAI_CHINH_KNTTHT' | Public Company Evaluation Detail | READY |
| K_GSDC_36 | EBIT / Lãi vay | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TAI_CHINH_EBIT' | Public Company Evaluation Detail | READY |
| K_GSDC_37 | Nợ / VCSH | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TAI_CHINH_NO_VON_CSH' | Public Company Evaluation Detail | READY |
| K_GSDC_38 | VCSH | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TAI_CHINH_VON_CSH' | Public Company Evaluation Detail | READY |
| K_GSDC_39 | ROE | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TAI_CHINH_ROE' | Public Company Evaluation Detail | READY |
| K_GSDC_40 | Doanh thu từ HĐ tài chính / Lợi nhuận sau thuế | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TAI_CHINH_DTHDTC_LNST' | Public Company Evaluation Detail | READY |
| K_GSDC_41 | Doanh thu từ hoạt động khác / Lợi nhuận sau thuế | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'TAI_CHINH_DTHD_KHAC_LNST' | Public Company Evaluation Detail | READY |
| K_GSDC_42 | Tổng điểm Tài chính | Điểm | Cơ sở | SUM(evaluation_score) WHERE group_cd = 'TAI_CHINH' | Public Company Evaluation Detail | READY |

**Ghi chú KPI:**
- **K_GSDC_33** = "ROA" (`criterion_cd = TAI_CHINH_ROA`).
- **K_GSDC_38** = "VCSH" (`criterion_cd = TAI_CHINH_VON_CSH`), STT 4, `Trạng thái mapping = Done`, `Loại dữ liệu = Dữ liệu tĩnh` — giữ nguyên trong bảng KPI và Attributes.

**Ghi chú lọc chung:** Mọi KPI Base join `Public Company Evaluation Detail (ed)` → `Public Company Evaluation Criterion (ec)` qua `pc_evaluation_criterion_id`, filter theo `pc_evaluation_criterion_code` tương ứng cột "Điều kiện lọc" ở trên.

**Source:** `Fact Public Company Financial Score Snapshot` → `Public Company Dimension`, `Calendar Date Dimension`

**Star Schema:**

```mermaid
erDiagram
    Fact_Public_Company_Financial_Score_Snapshot {
        string Public_Company_Dimension_Id PK
        string Snapshot_Date_Dimension_Id PK
        string Evaluation_Date_Dimension_Id FK
        string Evaluation_Year
        string Evaluation_Month
        int Audit_Opinion_Score
        int Roa_Score
        int Operating_Cash_Flow_Score
        int Current_Ratio_Score
        int Ebit_Interest_Coverage_Score
        int Debt_To_Equity_Score
        int Equity_Score
        int Roe_Score
        int Financial_Revenue_To_Profit_Score
        int Other_Revenue_To_Profit_Score
        int Total_Financial_Score
    }

    Public_Company_Dimension {
        string Public_Company_Dimension_Id PK
        string Public_Company_Code
        string Equity_Ticker_Code
        string Public_Company_Name
        string Public_Company_Status_Code
        string Equity_Listing_Exchange_Code
        string Enterprise_Type_Code
        string Business_Line_Level_1_Code
        string Life_Cycle_Status_Code
        date IDS_Registration_Date
        string Source_System_Code
    }

    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }

    Fact_Public_Company_Financial_Score_Snapshot }o--|| Public_Company_Dimension : "Public_Company_Dimension_Id"
    Fact_Public_Company_Financial_Score_Snapshot }o--|| Calendar_Date_Dimension : "Snapshot_Date_Dimension_Id"
    Fact_Public_Company_Financial_Score_Snapshot }o--o| Calendar_Date_Dimension : "Evaluation_Date_Dimension_Id"
```

> Grain + carry-forward logic giống hệt `Fact Public Company Risk Score Snapshot` (Nhóm 1). Mỗi criterion (K_GSDC_32–41) là 1 measure riêng — pivot từ `pc_evaluation_detail.evaluation_score` theo từng `pc_evaluation_criterion_code` cố định; `Total_Financial_Score` (K_GSDC_42) = `SUM(evaluation_score)` filter `pc_evaluation_group_code = 'TAI_CHINH'`.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    pc_financial_fct["Fact Public Company Financial Score Snapshot"] --> R4["K_GSDC_7-8,32-42: Top CTDC theo chỉ tiêu tài chính"]
    public_company_dim_g4["Public Company Dimension"] --> R4
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fact Public Company Financial Score Snapshot | 1 row / công ty đại chúng / ngày snapshot ETL (full-scan daily, carry-forward điểm số từ kỳ đánh giá gần nhất) |
| Public Company Dimension | 1 row / công ty đại chúng (SCD4A) |
| Calendar Date Dimension | 1 row / ngày (Conformed) |

---

#### Nhóm 5 — STT 5: Top CTDC theo chỉ tiêu phi tài chính & M-Score

> Phân loại: **Phân tích**
> Atomic: `Public Company Evaluation Detail` ← IDS.EVALUATION_DETAILS — **draft** (chưa approved)
> Atomic: `Public Company Evaluation Criterion` ← IDS.EVALUATION_CRITERIA — **draft** (chưa approved)
> **Lưu ý go-live:** Atomic entity liên quan chưa qua approve — xem [O_GSDC_1].

**KPI liên quan:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_7 | Mã doanh nghiệp | Text | Chiều | equity_ticker_symbol (trực tiếp) | **Reuse từ Nhóm 1** — không tính lại | READY |
| K_GSDC_8 | Tên doanh nghiệp | Text | Chiều | pc_nm (trực tiếp) | **Reuse từ Nhóm 1** — không tính lại | READY |
| K_GSDC_43 | Tình trạng DN từ Cục Đăng ký kinh doanh | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'PHI_TAI_CHINH_TTHD' | Public Company Evaluation Detail | READY |
| K_GSDC_44 | M-Score | Điểm | Cơ sở | evaluation_score WHERE criterion_code = 'PHI_TAI_CHINH_M_SCORE' | Public Company Evaluation Detail | READY |
| K_GSDC_45 | Tổng điểm Phi tài chính & M-Score | Điểm | Cơ sở | SUM(evaluation_score) WHERE group_cd = 'PHI_TAI_CHINH' | Public Company Evaluation Detail | READY |

**Ghi chú lọc chung:** Mọi KPI Base join `Public Company Evaluation Detail (ed)` → `Public Company Evaluation Criterion (ec)` qua `pc_evaluation_criterion_id`, filter theo `pc_evaluation_criterion_code` tương ứng cột "Điều kiện lọc" ở trên.

**Source:** `Fact Public Company Non-Financial Score Snapshot` → `Public Company Dimension`, `Calendar Date Dimension`

**Star Schema:**

```mermaid
erDiagram
    Fact_Public_Company_NonFinancial_Score_Snapshot {
        string Public_Company_Dimension_Id PK
        string Snapshot_Date_Dimension_Id PK
        string Evaluation_Date_Dimension_Id FK
        string Evaluation_Year
        string Evaluation_Month
        int Business_Registration_Status_Score
        int M_Score
        int Total_NonFinancial_Score
    }

    Public_Company_Dimension {
        string Public_Company_Dimension_Id PK
        string Public_Company_Code
        string Equity_Ticker_Code
        string Public_Company_Name
        string Public_Company_Status_Code
        string Equity_Listing_Exchange_Code
        string Enterprise_Type_Code
        string Business_Line_Level_1_Code
        string Life_Cycle_Status_Code
        date IDS_Registration_Date
        string Source_System_Code
    }

    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }

    Fact_Public_Company_NonFinancial_Score_Snapshot }o--|| Public_Company_Dimension : "Public_Company_Dimension_Id"
    Fact_Public_Company_NonFinancial_Score_Snapshot }o--|| Calendar_Date_Dimension : "Snapshot_Date_Dimension_Id"
    Fact_Public_Company_NonFinancial_Score_Snapshot }o--o| Calendar_Date_Dimension : "Evaluation_Date_Dimension_Id"
```

> Grain + carry-forward logic giống hệt `Fact Public Company Risk Score Snapshot` (Nhóm 1). Mỗi criterion (K_GSDC_43–44) là 1 measure riêng — pivot từ `pc_evaluation_detail.evaluation_score` theo từng `pc_evaluation_criterion_code` cố định; `Total_NonFinancial_Score` (K_GSDC_45) = `SUM(evaluation_score)` filter `pc_evaluation_group_code = 'PHI_TAI_CHINH'`.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    pc_nonfinancial_fct["Fact Public Company Non-Financial Score Snapshot"] --> R5["K_GSDC_7-8,43-45: Top CTDC theo chỉ tiêu phi tài chính & M-Score"]
    public_company_dim_g5["Public Company Dimension"] --> R5
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fact Public Company Non-Financial Score Snapshot | 1 row / công ty đại chúng / ngày snapshot ETL (full-scan daily, carry-forward điểm số từ kỳ đánh giá gần nhất) |
| Public Company Dimension | 1 row / công ty đại chúng (SCD4A) |
| Calendar Date Dimension | 1 row / ngày (Conformed) |

---

### Màn hình 2 — Giám sát Tổng hợp

Màn hình có bộ lọc **Năm / Quý** và 5 tab sàn. Mỗi tab hiển thị cùng cấu trúc 3 nhóm nội dung, chỉ khác filter `Equity_Listing_Exchange_Code`.

#### Nhóm 6 — STT 6: Thống kê niêm yết toàn thị trường

> Phân loại: **Phân tích**
> Atomic: `Public Company` ← IDS.company_profiles — **draft** (chưa approved)
> Atomic: `Violation Report` (`violation_report`) ← IDS.VIOLATION_REPORT — **draft**
> Nhóm 6 tương ứng STT 6. Bảng mapping renumber STT đầy đủ xem Section 4.
> K_GSDC_48 dùng entity `violation_report` (LLD draft `DataModel/working/Atomic/lld/IDS/lld_IDS_VIOLATION_REPORT.yaml`); K_GSDC_49 dùng `Fact Public Company Financial Report Value` (5 entity Financial Report Value, xem Nhóm 7) → cả 2 **READY**.
> `violation_report` mang ngữ nghĩa Fact Event (mỗi công ty × mỗi kỳ phát sinh 1 tập hồ sơ nghĩa vụ báo cáo mới, ETL append theo kỳ, không phải cập nhật current-state) — không phải Operational SCD4A. Grain phải xuống đủ chi tiết để `SUM` đúng ở mọi cấp độ (toàn TT/sàn — Nhóm 10/12/14/16 `GROUP BY` theo sàn cùng measure này), không pre-aggregate theo %. **`Fact Violation Report Snapshot`** — grain 1 row / công ty / kỳ (Report_Year + Report_Quarter) / ngày ETL snapshot, 2 measure đếm: `Report_Due_Count` (số hồ sơ có `deadline_dt <= ngày ETL` trong kỳ) và `Report_Submitted_Count` (số hồ sơ có `actual_submit_dt` không null trong kỳ) — JOIN `Public Company Dimension` để GROUP BY sàn khi cần. Tỷ lệ nộp BCTC = `SUM(Report_Submitted_Count) / SUM(Report_Due_Count)` ở tầng Detail Mapping, đúng tại bất kỳ cấp độ nào (toàn TT ở Nhóm 6, theo sàn ở Nhóm 10/12/14/16) mà không cần Fact riêng cho từng cấp.
> **K_GSDC_49 ĐỘC LẬP HOÀN TOÀN với K_GSDC_48** — không dùng `Fact Violation Report Snapshot`. Sửa lại 2026-08-15 (review phát hiện lỗi): thiết kế trước đó denormalize `Profitable_Indicator` vào `Fact Violation Report Snapshot` bằng cách JOIN `fr_value` theo kỳ lấy từ `violation_report.period_year`/`period_tp_code` — SAI vì `violation_report` (nguồn `IDS.VIOLATION_REPORT.PERIOD_YEAR`) và `company_data`/`pc_report_submission` (nguồn `IDS.COMPANY_DATA.REPORT_YEAR`) là 2 bảng nguồn độc lập, không đảm bảo luôn có bản ghi `violation_report` khớp đúng kỳ khi công ty có báo cáo tài chính — dẫn tới bỏ sót công ty có LNST>0 nhưng không có nghĩa vụ báo cáo khớp kỳ đó. Dùng trực tiếp `Fact Public Company Financial Report Value` (Nhóm 7, đã có sẵn đúng logic dedup `pc_report_submission` theo kỳ tài chính thật) — xem công thức K_GSDC_49 trong Bảng KPI bên dưới. Đúng theo màn hình thực tế: 3 thẻ (Số doanh nghiệp / Tỷ lệ nộp BCTC / Công ty báo lãi) là 3 con số độc lập, không cần chung 1 Fact.
> **Driving Table K_GSDC_48 = `Public Company Dimension`** (full-scan toàn bộ công ty mỗi ngày ETL — không phải `violation_report`, để tránh thiếu công ty không có hồ sơ `violation_report`). Mỗi ngày ETL quét **toàn bộ kỳ đang có nghĩa vụ** trong `violation_report` (không filter theo 1 kỳ cụ thể — tham số `:p_nam`/`:p_quy` trong BA SQL chỉ là điều kiện lọc khi truy vấn, không phải điều kiện giới hạn khi populate Fact) — LEFT JOIN `violation_report` để tính Due/Submitted theo từng kỳ.
> **K_GSDC_48** — BA SQL thực tế (`BA_analyst_GSDC_part1.csv` dòng 58): `FROM violation_report vr JOIN forms f ON f.id = vr.form_id AND f.news_type_cd = 'DINH_KY' WHERE vr.period_year = :p_nam AND (vr.period_quarter = :p_quy OR :p_quy IS NULL) AND vr.deadline_date <= TRUNC(SYSDATE)` → GROUP BY `pc_id`/`period_year`/`period_tp_code`: `Report_Due_Count = COUNT(vr.id) WHERE deadline_dt <= ngày ETL`, `Report_Submitted_Count = COUNT(vr.actual_submit_date)` (không null), JOIN `fr_template` (qua `fr_template_id`) filter `fr_template.news_tp_code = 'DINH_KY'` (← `IDS.FORMS.NEWS_TYPE_CD`, xem `lld_IDS_FORMS.yaml`) áp dụng ở tầng populate Fact (chỉ đếm hồ sơ loại "định kỳ").
> **K_GSDC_49** — BA SQL thực tế (`BA_analyst_GSDC_part1.csv` dòng 59, cùng logic dedup `Company_data_chuan` đã dùng cho `Fact Public Company Financial Report Value`, xem Nhóm 7): `FROM IDS.data d JOIN IDS.report_catalog rc ... JOIN IDS.rrow rr ... JOIN IDS.rcol rc2 ... JOIN ids.company_data cd ... WHERE rc2.col_desc='1' AND rc.report_cd LIKE 'BCKQKD%' AND d.data_value>0 AND ((rc.enterprise_type_cd='dn' AND rr.row_desc='60') OR (rc.enterprise_type_cd='bh' AND rr.row_desc='60') OR (rc.enterprise_type_cd='td' AND rr.row_desc='21'))` → đếm số công ty có ≥1 dòng `fr_value` khớp điều kiện LNST > 0 (`row_description_reference`='60' dn/bh, '21' td; `column_description_reference='1'`; `fr_catalog_code LIKE 'BCKQKD%'`) đúng kỳ `:p_year`/`:p_quarter`.
> `Fact Public Company Financial Summary Snapshot` không tồn tại trong mô hình — K_GSDC_47 tự đủ bằng `COUNT(DISTINCT ...)` trực tiếp trên `Public Company Dimension` (không cần grain snapshot theo kỳ). K_GSDC_46/47 dùng thẳng `Calendar Date Dimension`/`Public Company Dimension`, không qua Fact trung gian.

**Source:** `Public Company Dimension`, `Calendar Date Dimension` (K_GSDC_46/47 — không qua Fact); `Fact Violation Report Snapshot` (K_GSDC_48, driving `Public Company Dimension` full-scan, LEFT JOIN `violation_report`); `Fact Public Company Financial Report Value` + `Financial Report Catalog Dimension` (K_GSDC_49, reuse từ Nhóm 7)

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_46 | Kỳ thống kê (Năm/Quý) | Text | Chiều (Slicer) | — (trực tiếp) | — | **READY** — Tham số `:year`/`:quarter` |
| K_GSDC_47 | Số doanh nghiệp | DN | Phái sinh | ids_registration_dt (trực tiếp) | Public Company | **READY** — COUNT DISTINCT trực tiếp trên Public Company Dimension WHERE ids_registration_dt <= cuối kỳ — xem O_GSDC_2 |
| K_GSDC_48 | Tỷ lệ nộp BCTC | % | Phái sinh | deadline_dt / actual_submit_dt / period_year / period_tp_code (trực tiếp) | Violation Report | **READY** — `SUM(Report_Submitted_Count) / NULLIF(SUM(Report_Due_Count), 0) * 100` trên `Fact Violation Report Snapshot` (toàn thị trường — không filter sàn ở Nhóm này), filter kỳ `Report_Year=:p_nam AND (Report_Quarter=:p_quy OR :p_quy IS NULL)` |
| K_GSDC_49 | Số DN báo lãi | DN | Cơ sở | data_val (trực tiếp) | Financial Report Value | **READY** — `COUNT(DISTINCT Public_Company_Dimension_Id)` trên `Fact Public Company Financial Report Value` (Nhóm 7, JOIN `Financial Report Catalog Dimension`) WHERE `Row_Description_Reference` IN ('60','21') theo Enterprise_Type, `Column_Description_Reference='1'`, `Financial_Report_Catalog_Code LIKE 'BCKQKD%'`, `Data_Value > 0`, `Report_Year=:p_year AND Report_Quarter=:p_quarter` — sửa 2026-08-15, không còn dùng `Fact Violation Report Snapshot` |

> **Ghi chú filter K_GSDC_48:** BA JOIN `forms f ON f.id = vr.form_id AND f.news_type_cd = 'DINH_KY'` để lọc loại báo cáo "định kỳ" — map đúng field `fr_template.news_tp_code` (← `IDS.FORMS.NEWS_TYPE_CD`, `DataModel/working/Atomic/lld/IDS/lld_IDS_FORMS.yaml`), JOIN qua `violation_report.fr_template_id = fr_template.fr_template_id`, filter `fr_template.news_tp_code = 'DINH_KY'` — áp dụng ở tầng ETL populate `Fact Violation Report Snapshot` (chỉ đếm hồ sơ "định kỳ" vào Report_Due_Count/Report_Submitted_Count). Không còn Open Issue.

**Star Schema:**

```mermaid
erDiagram
    Public_Company_Dimension {
        string Public_Company_Dimension_Id PK
        string Public_Company_Code
        string Equity_Ticker_Code
        string Public_Company_Name
        string Public_Company_Status_Code
        string Equity_Listing_Exchange_Code
        string Enterprise_Type_Code
        string Business_Line_Level_1_Code
        string Life_Cycle_Status_Code
        date IDS_Registration_Date
        string Source_System_Code
    }

    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }

    Fact_Violation_Report_Snapshot {
        string Public_Company_Dimension_Id PK
        int Report_Year PK
        int Report_Quarter PK
        string Snapshot_Date_Dimension_Id PK
        int Report_Due_Count
        int Report_Submitted_Count
    }

    Fact_Violation_Report_Snapshot }o--|| Public_Company_Dimension : "Public_Company_Dimension_Id"
    Fact_Violation_Report_Snapshot }o--|| Calendar_Date_Dimension : "Snapshot_Date_Dimension_Id"
```

> **Ghi chú:** K_GSDC_46/47 truy vấn trực tiếp trên `Public Company Dimension`/`Calendar Date Dimension` — không có Fact trung gian. K_GSDC_48 dùng `Fact Violation Report Snapshot` (driving `Public Company Dimension` full-scan, grain 1 row/công ty/kỳ báo cáo/ngày ETL, JOIN `Public Company Dimension` để GROUP BY sàn ở Nhóm 10/12/14/16) — filter "loại tin định kỳ" (`fr_template.news_tp_code = 'DINH_KY'`) áp dụng ở tầng ETL populate Fact cho `Report_Due_Count`/`Report_Submitted_Count`. FK `Snapshot_Date_Dimension_Id` sang `Calendar Date Dimension` lưu ngày ETL chạy job populate Fact (không phải ngày nghiệp vụ trong `violation_report`, `Report_Year`/`Report_Quarter` vẫn giữ nguyên là kỳ báo cáo), theo đúng pattern `Snapshot_Date` đã dùng ở 5 Fact `*_Score_Snapshot` — cho phép full-scan daily và trace đúng thời điểm tính toán tỷ lệ nộp BCTC (VD: tỷ lệ tại ngày 06/08 có thể khác ngày 20/08 cùng kỳ Quý 3 vì có thêm công ty nộp muộn). **K_GSDC_49 (Số DN báo lãi) KHÔNG còn dùng Fact này** (sửa 2026-08-15) — dùng trực tiếp `Fact Public Company Financial Report Value`/`Financial Report Catalog Dimension` đã vẽ ở Nhóm 7, không vẽ lại erDiagram ở đây.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    public_company_dim["Public Company Dimension"] --> R1["Thẻ Số doanh nghiệp"]
    cdr_dt_dim["Calendar Date Dimension"] --> R1
    fct_violation_rpt_snpst_g6["Fact Violation Report Snapshot"] --> R1b["K_GSDC_48: Tỷ lệ nộp BCTC"]
    public_company_dim --> R1b
    cdr_dt_dim --> R1b
    fct_public_company_financial_rpt_val_g6["Fact Public Company Financial Report Value"] --> R1c["K_GSDC_49: Số DN báo lãi"]
    financial_rpt_catalog_dim_g6["Financial Report Catalog Dimension"] --> R1c
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Public Company Dimension | 1 row / công ty đại chúng (SCD4A) |
| Calendar Date Dimension | 1 row / ngày (Conformed) |
| Fact Violation Report Snapshot | 1 row / công ty đại chúng / kỳ (Report Year + Report Quarter) / ngày ETL snapshot — chỉ phục vụ K_GSDC_48 |
| Fact Public Company Financial Report Value | như Nhóm 7 — phục vụ K_GSDC_49 (reuse) |

---

#### Nhóm 7 — STT 7: Tổng hợp chỉ tiêu tài chính toàn thị trường

> Phân loại: **Phân tích**
> Nhóm 7 tương ứng STT 7 (CTTC tổng hợp toàn thị trường, không filter sàn). STT 11/13/15/17 (cùng bộ chỉ tiêu, filter theo sàn HNX/HOSE/UPCOM/OTC + thêm breakdown theo ngành) tách thành Nhóm 11/13/15/17 riêng — xem bên dưới. Bảng mapping renumber STT đầy đủ xem Section 4.
> Atomic đã đủ 5 entity (`fr_value`/IDS.DATA, `financial_report_catalog`/IDS.REPORT_CATALOG, `fr_row_template`/IDS.RROW, `fr_column_template`/IDS.RCOL, `pc_report_submission`/IDS.COMPANY_DATA — `DataModel/working/Atomic/lld/IDS/`), quy tắc khai thác (JOIN key, dedup submission, EXISTS filter) theo đúng SQL BA (`BRD/BA/BA_analyst_GSDC_part1.csv` dòng 1163–1580) → **READY**, không còn Gap Atomic.
> Atomic: `Financial Report Value` (`fr_value`) ← IDS.DATA — **draft** (chưa approved)
> Atomic: `Financial Report Catalog` (`financial_report_catalog`) ← IDS.REPORT_CATALOG — **draft**
> Atomic: `Financial Report Row Template` (`fr_row_template`) ← IDS.RROW — **approved**
> Atomic: `Financial Report Column Template` (`fr_column_template`) ← IDS.RCOL — **approved**
> Atomic: `Public Company Report Submission` (`pc_report_submission`) ← IDS.COMPANY_DATA — **approved** (dùng làm filter tồn tại hồ sơ nộp, không lấy measure)

**Quy tắc khai thác (chốt cùng Data Modeler, 2026-08-06):**
1. **Driving table:** `fr_value` — mỗi dòng = 1 giá trị ô báo cáo (`pc_id` × `fr_catalog_id` × `row_code` × `column_code` × `rpt_year` × `rpt_quarter`).
2. **JOIN `financial_report_catalog`** ON `fr_value.fr_catalog_id = financial_report_catalog.fr_catalog_id` — lấy `fr_catalog_code` (filter `LIKE 'BCDKT%'`/`LIKE 'BCKQKD%'`), `enterprise_tp_code` (filter `'dn'`/`'bh'`/`'td'`).
3. **JOIN `fr_row_template`** ON `fr_row_template.fr_row_template_code = fr_value.row_code AND fr_row_template.fr_catalog_id = fr_value.fr_catalog_id` — lấy `row_description_reference` (mã dòng hiển thị trên biểu mẫu, VD `'270'` — khác `row_code`/`fr_row_template_code` là mã kỹ thuật tự sinh `r+sequence`, dùng để JOIN, không dùng để filter nghiệp vụ).
4. **JOIN `fr_column_template`** ON `fr_column_template.fr_column_template_code = fr_value.column_code AND fr_column_template.fr_catalog_id = fr_value.fr_catalog_id` — lấy `column_description_reference` (VD `'1'` = cuối kỳ, `'2'` = đầu kỳ).
5. **Filter tồn tại hồ sơ nộp hợp lệ** (đúng ý nghĩa `INNER JOIN company_data` trong SQL BA — dùng để lọc, không SELECT field): `EXISTS (SELECT 1 FROM pc_report_submission WHERE pc_id = fr_value.pc_id AND rpt_year = fr_value.rpt_year AND rpt_quarter = fr_value.rpt_quarter)`. Dùng `EXISTS`/semi-join (KHÔNG `INNER JOIN` trực tiếp) để tránh fan-out khi 1 công ty + 1 kỳ có nhiều dòng `pc_report_submission` (nhiều form/bản đính chính) — `INNER JOIN` trực tiếp sẽ nhân dòng `fr_value` lên N lần, làm `SUM(data_val)` sai.
6. **Dedup `pc_report_submission` trước khi filter EXISTS** (nếu cần field khác ngoài phạm vi Nhóm 7): key = `(pc_id, fr_template_id, rpt_year, rpt_quarter, rpt_month)`, `WHERE submission_status_code = 'APPROVED'`, nhiều bản ghi cùng key → lấy `MAX(submission_dt)`.
7. **Grain Fact:** 1 row / CTĐC (`pc_id`) / kỳ (`rpt_year`+`rpt_quarter`) / Row Code / Column Code — đúng placeholder đã ghi ở Section 4 Reuse Analysis.
8. **`Data Value`** giữ riêng cho từng `column_description_reference` (`'1'` cuối kỳ, `'2'` đầu kỳ) — ROA/ROE (K_GSDC_55/56) là KPI Phái sinh, tính ở tầng Detail Mapping bằng cách lấy 2 dòng cùng Row Code khác Column Code (`'1'`/`'2'`) rồi tính trung bình, KHÔNG SUM trực tiếp trên Fact (xem BƯỚC 4B — grain measure = grain Fact, đúng cấp).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_50 | Tổng tài sản | Tỉ đồng | Phái sinh | data_val WHERE row_desc=270/270/300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_50_YOY | Tổng tài sản — YoY | % | Phái sinh | data_val WHERE row_desc=270/270/300, report=BCDKT, col_desc=1 (kỳ N vs N-4 quarter) | fr_value | **READY** |
| K_GSDC_51 | Nợ phải trả | Tỉ đồng | Phái sinh | data_val WHERE row_desc=300/300/400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_51_YOY | Nợ phải trả — YoY | % | Phái sinh | data_val WHERE row_desc=300/300/400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_52 | Vốn CSH | Tỉ đồng | Phái sinh | data_val WHERE row_desc=400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_52_YOY | Vốn CSH — YoY | % | Phái sinh | data_val WHERE row_desc=400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_53 | Vốn điều lệ | Tỉ đồng | Phái sinh | data_val WHERE row_desc=411/411/411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_53_YOY | Vốn điều lệ — YoY | % | Phái sinh | data_val WHERE row_desc=411/411/411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_54 | Lợi nhuận sau thuế | Tỉ đồng | Phái sinh | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_54_YOY | LNST — YoY | % | Phái sinh | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_55 | ROA | % | Phái sinh | data_val WHERE row_desc=270/270/300 (TSBQ) + 60/60/21 (LNST), report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_55_YOY | ROA — YoY | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_55), report=—, col_desc=— | fr_value | **READY** |
| K_GSDC_56 | ROE | % | Phái sinh | data_val WHERE row_desc=400/400/500 (VCSHBQ) + 60/60/21 (LNST), report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_56_YOY | ROE — YoY | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_56), report=—, col_desc=— | fr_value | **READY** |
| K_GSDC_57 | Hàng tồn kho | Tỉ đồng | Phái sinh | data_val WHERE row_desc=140/140/—, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_57_YOY | Hàng tồn kho — YoY | % | Phái sinh | data_val WHERE row_desc=140/140/—, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_58 | Doanh thu thuần | Tỉ đồng | Phái sinh | data_val WHERE row_desc=10/10/03, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_58_YOY | Doanh thu — YoY | % | Phái sinh | data_val WHERE row_desc=10/10/03, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_59 | Lợi nhuận dồn tích YTD | Tỉ đồng | Phái sinh | data_val WHERE row_desc=421/421/— (td không có trong BA SQL), report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_59_YOY | LN YTD — YoY | % | Phái sinh | data_val WHERE row_desc=421/421/— (td không có trong BA SQL), report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_60 | Phải thu | Tỉ đồng | Phái sinh | data_val WHERE row_desc=130+210/130+210/251, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_60_YOY | Phải thu — YoY | % | Phái sinh | data_val WHERE row_desc=130+210/130+210/251, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_61 | Tiền và tương đương tiền | Tỉ đồng | Phái sinh | data_val WHERE row_desc=110/110/110+120, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_61_YOY | Tiền TĐT — YoY | % | Phái sinh | data_val WHERE row_desc=110/110/110+120, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_62 | Nợ / Vốn CSH | Lần (x) | Phái sinh | data_val WHERE row_desc=300/300/400 (Nợ) + 400/400/500 (VCSH), report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_62_YOY | Nợ/Vốn CSH — YoY | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_62), report=—, col_desc=— | fr_value | **READY** |

> **Ghi chú YoY:** BA gọi "so sánh cùng kỳ năm trước" — công thức `(giá_trị_kỳ_này - giá_trị_cùng_kỳ_năm_trước) / giá_trị_cùng_kỳ_năm_trước × 100`, lấy 2 dòng Fact cùng Row/Column Code, khác `rpt_year` (năm nay vs năm trước, cùng `rpt_quarter`) — pre-aggregate ở Detail Mapping, không phải cột riêng trên Fact.

```mermaid
erDiagram
    Fact_Public_Company_Financial_Report_Value {
        string Public_Company_Dimension_Id PK
        string Financial_Report_Catalog_Dimension_Id PK
        int Report_Year PK
        int Report_Quarter PK
        string Row_Code PK
        string Column_Code PK
        string Snapshot_Date_Dimension_Id PK
        float Data_Value
    }

    Public_Company_Dimension {
        string Public_Company_Dimension_Id PK
        string Public_Company_Code
        string Equity_Ticker_Code
        string Public_Company_Name
        string Public_Company_Status_Code
        string Equity_Listing_Exchange_Code
        string Enterprise_Type_Code
        string Business_Line_Level_1_Code
        string Life_Cycle_Status_Code
        date IDS_Registration_Date
        string Source_System_Code
    }

    Financial_Report_Catalog_Dimension {
        string Financial_Report_Catalog_Dimension_Id PK
        string Financial_Report_Catalog_Code
        string Row_Code
        string Column_Code
        string Financial_Report_Catalog_Name
        string Financial_Report_Catalog_Type_Code
        string Enterprise_Type_Code
        string Row_Description_Reference
        string Column_Description_Reference
        string Financial_Report_Row_Template_Name
        int Row_Index
        string Financial_Report_Column_Template_Name
        int Column_Index
        string Source_System_Code
    }

    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        boolean Holiday_Flag
        string Source_System_Code
    }

    Fact_Public_Company_Financial_Report_Value }o--|| Public_Company_Dimension : "Public_Company_Dimension_Id"
    Fact_Public_Company_Financial_Report_Value }o--|| Financial_Report_Catalog_Dimension : "Financial_Report_Catalog_Dimension_Id"
    Fact_Public_Company_Financial_Report_Value }o--|| Calendar_Date_Dimension : "Snapshot_Date_Dimension_Id"
```

> **Ghi chú erDiagram:** `Row_Code`/`Column_Code` trên Fact là mã kỹ thuật (`fr_value.row_code`/`column_code`) dùng làm grain key — `Row_Description_Reference`/`Column_Description_Reference` (mã hiển thị biểu mẫu dùng để filter nghiệp vụ, VD `'270'`/`'1'`) nằm trên `Financial_Report_Catalog_Dimension` (denormalize từ `fr_row_template`/`fr_column_template`, join theo `row_code`/`column_code` + `fr_catalog_id`) — tách khỏi Fact vì đây là thuộc tính mô tả của template, không phải measure. `EXISTS pc_report_submission` là điều kiện filter ETL population, không xuất hiện trên Fact. `Snapshot_Date_Dimension_Id` — FK tới Calendar Date Dimension, ngày chạy ETL populate Fact (full-scan daily) — ETL chạy hàng ngày vì không biết trước công ty nào nộp báo cáo vào ngày nào, mỗi ngày snapshot lại toàn bộ dữ liệu BCTC hiện có của các công ty tại 1 kỳ (giống pattern `Snapshot_Date` đã dùng ở 5 Fact `*_Score_Snapshot` và `Fact Violation Report Snapshot`).

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    fct_pc_fr_val["Fact Public Company Financial Report Value"] --> R1["K_GSDC_50-62,K_GSDC_50_YOY-62_YOY: Tổng hợp chỉ tiêu tài chính toàn thị trường"]
    public_company_dim_g7["Public Company Dimension"] --> R1
    financial_rpt_catalog_dim_g7["Financial Report Catalog Dimension"] --> R1
    cdr_dt_dim_g7["Calendar Date Dimension"] --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fact Public Company Financial Report Value | 1 row / CTĐC / kỳ (Report Year + Report Quarter) / Row Code / Column Code / ngày ETL snapshot (full-scan daily) |
| Public Company Dimension | 1 row / công ty đại chúng (SCD4A) |
| Financial Report Catalog Dimension | 1 row / báo cáo (Catalog) × dòng (Row) × cột (Column) — reference per module (SCD4A) |
| Calendar Date Dimension | 1 row / ngày (Conformed) |

---

#### Nhóm 8 — STT 8: Tổng hợp chỉ tiêu tài chính & thống kê ngành (toàn thị trường)

> Phân loại: **Phân tích**
> Nhóm 8 = 1 STT duy nhất (STT 8, 14 dòng liên tục: K_GSDC_63–76) — dashboard "Tổng hợp CTTC theo ngành toàn thị trường".
> Reuse 100% `Fact Public Company Financial Report Value` + `Financial Report Catalog Dimension` đã thiết kế ở Nhóm 7, chỉ thêm breakdown theo ngành qua `Public Company Dimension.Business_Line_Level_1_Code` (đã có sẵn, không cần cột mới trên Fact).
> **Atomic — Ngành (READY từ trước):** `Public Company` (`public_company`), field `Business Line Level 1 Code` (`business_line_level_1_code`, nguồn `IDS.company_profiles.CATEGORY_L1_ID`, Classification Value scheme `IDS_INDUSTRY_CATEGORY`). SQL BA breakdown ngành dùng `JOIN IDS.company_profiles cdet ON cdet.id = d.company_profile_id` + `GROUP BY cdet.category_l1_id` — đây chính là field trên `public_company` (đã join sẵn qua `pc_id` trên Fact), không phải cột riêng.
> Atomic: `Financial Report Value` (`fr_value`), `Financial Report Catalog` (`financial_report_catalog`), `Financial Report Row Template` (`fr_row_template`), `Financial Report Column Template` (`fr_column_template`), `Public Company Report Submission` (`pc_report_submission`) — xem chi tiết quy tắc khai thác ở Nhóm 7 (dùng chung, không lặp lại).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_63 | Ngành kinh tế | Text | Chiều (Group By) | business_line_level_1_code (xem KPI liên quan cùng công thức) | public_company | **READY** |
| K_GSDC_64 | Tổng tài sản theo ngành | Tỉ đồng | Phái sinh | data_val WHERE row_desc=270/270/300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_65 | Nợ phải trả theo ngành | Tỉ đồng | Phái sinh | data_val WHERE row_desc=300/300/400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_66 | Vốn CSH theo ngành | Tỉ đồng | Phái sinh | data_val WHERE row_desc=400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_67 | Vốn điều lệ theo ngành | Tỉ đồng | Phái sinh | data_val WHERE row_desc=411/411/411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_68 | Lợi nhuận sau thuế theo ngành | Tỉ đồng | Phái sinh | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_69 | ROA theo ngành | % | Phái sinh | data_val WHERE row_desc=270/270/300 (TSBQ) + 60/60/21 (LNST), report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_70 | ROE theo ngành | % | Phái sinh | data_val WHERE row_desc=400/400/500 (VCSHBQ) + 60/60/21 (LNST), report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_71 | Hàng tồn kho theo ngành | Tỉ đồng | Phái sinh | data_val WHERE row_desc=140/140/—, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_72 | Doanh thu thuần theo ngành | Tỉ đồng | Phái sinh | data_val WHERE row_desc=10/10/03, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_73 | Lợi nhuận dồn tích YTD theo ngành | Tỉ đồng | Phái sinh | data_val WHERE row_desc=421/421/— (td không có trong BA SQL), report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_74 | Phải thu theo ngành | Tỉ đồng | Phái sinh | data_val WHERE row_desc=130+210/130+210/251, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_75 | Tiền và tương đương tiền theo ngành | Tỉ đồng | Phái sinh | data_val WHERE row_desc=110/110/110+120, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_76 | Nợ / Vốn CSH theo ngành | Lần (x) | Phái sinh | data_val WHERE row_desc=300/300/400 (Nợ) + 400/400/500 (VCSH), report=BCDKT, col_desc=1 | fr_value | **READY** |

**Star Schema:** dùng chung `Fact Public Company Financial Report Value` + `Public Company Dimension` + `Financial Report Catalog Dimension` với Nhóm 7 (không có erDiagram riêng — xem Nhóm 7). Breakdown ngành = GROUP BY thêm `Public Company Dimension.Business_Line_Level_1_Code` ở tầng Detail Mapping, không thay đổi Fact/Dimension schema.

> **Ghi chú filter Active (K_GSDC_63):** BA gốc lọc danh sách ngành `IDS.categories WHERE active_flg = 1`. Map đúng: JOIN `Public_Company_Dimension.Business_Line_Level_1_Id → cl_business_line.cl_business_line_id`, filter `cl_business_line.active_indicator = 1`.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    fct_pc_fr_val_g8["Fact Public Company Financial Report Value"] --> R8["K_GSDC_63-76: Tổng hợp chỉ tiêu tài chính & thống kê ngành"]
    public_company_dim_g8["Public Company Dimension"] --> R8
    financial_rpt_catalog_dim_g8["Financial Report Catalog Dimension"] --> R8
```

**Bảng grain:** như Nhóm 7 (`Fact Public Company Financial Report Value` — 1 row / CTĐC / kỳ / Row Code / Column Code; `Public Company Dimension` — 1 row / công ty đại chúng SCD4A).

---

#### Nhóm 9 — STT 9: Thống kê CTĐC chưa niêm yết (toàn thị trường)

> Phân loại: **Phân tích**
> Source: `Public Company Dimension` (không qua Fact) — filter `Public Company Status Code = 'APPROVED_PUBLIC'` AND `Equity Listing Exchange Code NOT IN ('HOSE', 'HNX', 'UPCOM')` (bao gồm NULL, OTC)
> Filter: `Public Company Status Code = 'APPROVED_PUBLIC'` (Atomic: `pc_status_code`, nguồn `IDS.COMPANY_PROFILES.STATUS_IDS_CD`) AND `equity_listing_exchange_code NOT IN ('HOSE', 'HNX', 'UPCOM')` — BA định nghĩa "chưa niêm yết" là loại trừ 3 sàn niêm yết/đăng ký giao dịch chính thức (HOSE/HNX/UPCOM); OTC/NULL/giá trị khác đều tính là chưa niêm yết. Cập nhật 2026-08-14 theo SQL BA mới nhất (cột "Câu lệnh update SIT", `BA_analyst_GSDC_part1.csv` STT 9) — bản gốc chỉ loại trừ HOSE/HNX (coi UPCOM là chưa niêm yết), bản cập nhật thêm UPCOM vào danh sách loại trừ (coi UPCOM là đã niêm yết).
> K_GSDC_77 tự đủ bằng COUNT DISTINCT trực tiếp trên `Public Company Dimension`, không cần Fact.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_77 | Số CTDC chưa niêm yết | DN | Phái sinh | ids_registration_dt (trực tiếp) | COUNT(DISTINCT pc_id) WHERE ids_registration_dt <= cuối kỳ AND pc_status_code = 'APPROVED_PUBLIC' AND equity_listing_exchange_code NOT IN ('HOSE', 'HNX', 'UPCOM') | READY |

**Star Schema:**

```mermaid
erDiagram
    Public_Company_Dimension {
        string Public_Company_Dimension_Id PK
        string Public_Company_Code
        string Equity_Ticker_Code
        string Public_Company_Name
        string Public_Company_Status_Code
        string Equity_Listing_Exchange_Code
        string Enterprise_Type_Code
        string Business_Line_Level_1_Code
        string Life_Cycle_Status_Code
        date IDS_Registration_Date
        string Source_System_Code
    }
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    public_company_dim["Public Company Dimension"] --> R9["Thẻ CTDC chưa niêm yết"]
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Public Company Dimension | 1 row / công ty đại chúng (SCD4A) |

---

#### Nhóm 10 — STT 10: Thống kê niêm yết sàn HNX

> Phân loại: **Phân tích**
> Atomic: `Public Company` ← IDS.company_profiles — **draft** (chưa approved)
> Filter: `equity_listing_exchange_code = 'HNX'`
> K_GSDC_48/49 theo đúng logic Nhóm 6, thêm filter `Equity_Listing_Exchange_Code='HNX'` — BA SQL thực tế (`BA_analyst_GSDC_part1.csv` dòng 104-105, JOIN `company_profiles cp`/`company_profiles cdet` filter `= 'HNX'`).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_46 | Ngày thống kê (Năm/Quý) | Text | Chiều (Slicer) | — (trực tiếp) | — | **READY** — Tham số `:year`/`:quarter` |
| K_GSDC_78 | Sàn | Text | Chiều | equity_listing_exchange_code (trực tiếp) | Public Company | **READY** — Filter cố định `= 'HNX'` — Classification Value scheme `IDS_LISTING_TYPE` |
| K_GSDC_47 | Số doanh nghiệp theo từng sàn | DN | Cơ sở | ids_registration_dt (trực tiếp) | Public Company | **READY** — COUNT DISTINCT WHERE ids_registration_dt <= cuối kỳ AND equity_listing_exchange_code = 'HNX' — reuse công thức K_GSDC_47 Nhóm 6, filter thêm theo sàn |
| K_GSDC_48 | Tỷ lệ nộp BCTC theo từng sàn (quý) | % | Phái sinh | deadline_dt / actual_submit_dt / period_year / period_tp_code (trực tiếp) | Violation Report | **READY** — Reuse công thức K_GSDC_48 Nhóm 6, JOIN `Public Company Dimension` filter `Equity_Listing_Exchange_Code='HNX'` |
| K_GSDC_49 | Số DN báo lãi theo từng sàn | DN | Cơ sở | data_val (trực tiếp) | Financial Report Value | **READY** — Reuse công thức K_GSDC_49 Nhóm 6 (`Fact Public Company Financial Report Value`), JOIN `Public Company Dimension` filter `Equity_Listing_Exchange_Code='HNX'` |

**Star Schema, Lineage, Bảng grain:** giống Nhóm 6 — K_GSDC_46/47/48 dùng `Public Company Dimension`, `Calendar Date Dimension`, `Fact Violation Report Snapshot`; K_GSDC_49 dùng `Fact Public Company Financial Report Value`/`Financial Report Catalog Dimension` (Nhóm 7) — chỉ khác filter sàn `= 'HNX'`.

---

#### Nhóm 11 — STT 11: Tổng hợp chỉ tiêu tài chính theo sàn HNX

> Phân loại: **Phân tích**
> Filter: `Equity_Listing_Exchange_Code = 'HNX'` (xem Nhóm 6 K_GSDC_78 "Sàn", reuse KPI_ID) — filter bổ sung trên `Public Company Dimension`, JOIN vào Fact qua `pc_id` như Nhóm 7/8.
> **Ghi chú nội dung:** STT 11 = 26 KPI giống Nhóm 7 (filter thêm sàn HNX) + 14 dòng mới: 1 Chiều "Ngành" + 13 chỉ tiêu "theo ngành" (GROUP BY `Business Line Level 1 Code`, giống Nhóm 8).
> Reuse 100% `Fact Public Company Financial Report Value` + `Financial Report Catalog Dimension` đã thiết kế ở Nhóm 7 — chỉ thêm filter `Equity_Listing_Exchange_Code='HNX'` (qua `Public Company Dimension`) và breakdown ngành (qua `Public Company Dimension.Business_Line_Level_1_Code`, giống Nhóm 8).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_50 | Tổng tài sản (HNX) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=270/270/300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_50_YOY | Tổng tài sản — YoY | % | Phái sinh | data_val WHERE row_desc=270/270/300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_51 | Nợ phải trả (HNX) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=300/300/400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_51_YOY | Nợ phải trả — YoY | % | Phái sinh | data_val WHERE row_desc=300/300/400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_52 | Vốn CSH (HNX) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_52_YOY | Vốn CSH — YoY | % | Phái sinh | data_val WHERE row_desc=400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_53 | Vốn điều lệ (HNX) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=411/411/411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_53_YOY | Vốn điều lệ — YoY | % | Phái sinh | data_val WHERE row_desc=411/411/411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_54 | Lợi nhuận sau thuế (HNX) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_54_YOY | LNST — YoY | % | Phái sinh | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_55 | ROA (HNX) | % | Phái sinh | data_val WHERE row_desc=270/270/300 + 60/60/21, report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_55_YOY | ROA — YoY | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_55), report=—, col_desc=— | fr_value | **READY** |
| K_GSDC_56 | ROE (HNX) | % | Phái sinh | data_val WHERE row_desc=400/400/500 + 60/60/21, report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_56_YOY | ROE — YoY | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_56), report=—, col_desc=— | fr_value | **READY** |
| K_GSDC_57 | Hàng tồn kho (HNX) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=140/140/—, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_57_YOY | Hàng tồn kho — YoY | % | Phái sinh | data_val WHERE row_desc=140/140/—, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_58 | Doanh thu thuần (HNX) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=10/10/03, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_58_YOY | Doanh thu — YoY | % | Phái sinh | data_val WHERE row_desc=10/10/03, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_59 | Lợi nhuận dồn tích YTD (HNX) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=421/421/— (td không có trong BA SQL), report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_59_YOY | LN YTD — YoY | % | Phái sinh | data_val WHERE row_desc=421/421/— (td không có trong BA SQL), report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_60 | Phải thu (HNX) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=130+210/130+210/251, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_60_YOY | Phải thu — YoY | % | Phái sinh | data_val WHERE row_desc=130+210/130+210/251, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_61 | Tiền và tương đương tiền (HNX) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=110/110/110+120, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_61_YOY | Tiền TĐT — YoY | % | Phái sinh | data_val WHERE row_desc=110/110/110+120, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_62 | Nợ / Vốn CSH (HNX) | Lần (x) | Phái sinh | data_val WHERE row_desc=300/300/400 + 400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_62_YOY | Nợ/Vốn CSH — YoY | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_62), report=—, col_desc=— | fr_value | **READY** |
| K_GSDC_79 | Ngành | Text | Chiều | business_line_level_1_code (xem KPI liên quan cùng công thức) | public_company | **READY** |
| K_GSDC_80 | Tổng tài sản — theo ngành (HNX) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=270/270/300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_81 | Nợ phải trả — theo ngành (HNX) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=300/300/400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_82 | Vốn CSH — theo ngành (HNX) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_83 | Vốn điều lệ — theo ngành (HNX) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=411/411/411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_84 | Lợi nhuận sau thuế — theo ngành (HNX) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_85 | ROA — theo ngành (HNX) | % | Phái sinh | data_val WHERE row_desc=270/270/300 + 60/60/21, report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_86 | ROE — theo ngành (HNX) | % | Phái sinh | data_val WHERE row_desc=400/400/500 + 60/60/21, report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_87 | Hàng tồn kho — theo ngành (HNX) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=140/140/—, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_88 | Doanh thu — theo ngành (HNX) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=10/10/03, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_89 | Lợi nhuận dồn tích YTD — theo ngành (HNX) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=421/421/— (td không có trong BA SQL), report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_90 | Phải thu — theo ngành (HNX) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=130+210/130+210/251, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_91 | Tiền và tương đương tiền — theo ngành (HNX) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=110/110/110+120, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_92 | Nợ/Vốn CSH — theo ngành (HNX) | Lần (x) | Phái sinh | data_val WHERE row_desc=300/300/400 + 400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |

**Star Schema:** dùng chung `Fact Public Company Financial Report Value` + `Public Company Dimension` + `Financial Report Catalog Dimension` với Nhóm 7 (không có erDiagram riêng). Filter sàn = `Public Company Dimension.Equity_Listing_Exchange_Code = 'HNX'`, GROUP BY ngành = `Public Company Dimension.Business_Line_Level_1_Code` — cả 2 xử lý ở tầng Detail Mapping.

> **Ghi chú filter Active (K_GSDC_79):** giống K_GSDC_63 Nhóm 8 — filter `cl_business_line.active_indicator = 1` qua JOIN `Business_Line_Level_1_Id`.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    fct_pc_fr_val_g11["Fact Public Company Financial Report Value"] --> R11["K_GSDC_50-62,79-92+YOY: Tổng hợp chỉ tiêu tài chính theo sàn HNX"]
    public_company_dim_g11["Public Company Dimension"] --> R11
    financial_rpt_catalog_dim_g11["Financial Report Catalog Dimension"] --> R11
```

**Bảng grain:** như Nhóm 7.

---

#### Nhóm 12 — STT 12: Thống kê niêm yết sàn HOSE

> Phân loại: **Phân tích**
> Atomic: `Public Company` ← IDS.company_profiles — **draft** (chưa approved)
> Filter: `equity_listing_exchange_code = 'HOSE'`
> K_GSDC_48/49 theo đúng logic Nhóm 6, thêm filter `Equity_Listing_Exchange_Code='HOSE'` (BA SQL dòng 149-150).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_46 | Ngày thống kê (Năm/Quý) | Text | Chiều (Slicer) | — (trực tiếp) | — | **READY** — Tham số `:year` / `:quarter` — reuse K_GSDC_46 |
| K_GSDC_78 | Sàn | Text | Chiều | equity_listing_exchange_code (trực tiếp) | Public Company | **READY** — Filter cố định `= 'HOSE'` — reuse KPI Sàn (K_GSDC_78), khác filter |
| K_GSDC_47 | Số doanh nghiệp theo từng sàn | DN | Cơ sở | ids_registration_dt (trực tiếp) | Public Company | **READY** — COUNT DISTINCT WHERE ids_registration_dt <= cuối kỳ AND equity_listing_exchange_code = 'HOSE' |
| K_GSDC_48 | Tỷ lệ nộp BCTC theo từng sàn (quý) | % | Phái sinh | deadline_dt / actual_submit_dt / period_year / period_tp_code (trực tiếp) | Violation Report | **READY** — Reuse công thức K_GSDC_48 Nhóm 6, filter `Equity_Listing_Exchange_Code='HOSE'` |
| K_GSDC_49 | Số DN báo lãi theo từng sàn | DN | Cơ sở | data_val (trực tiếp) | Financial Report Value | **READY** — Reuse công thức K_GSDC_49 Nhóm 6 (`Fact Public Company Financial Report Value`), filter `Equity_Listing_Exchange_Code='HOSE'` |

**Star Schema, Lineage, Bảng grain:** giống Nhóm 6 — K_GSDC_49 dùng `Fact Public Company Financial Report Value`/`Financial Report Catalog Dimension` (Nhóm 7), không dùng `Fact Violation Report Snapshot` — chỉ khác filter sàn `= 'HOSE'`.

---

#### Nhóm 13 — STT 13: Tổng hợp chỉ tiêu tài chính theo sàn HOSE

> Phân loại: **Phân tích**
> Filter: `Equity_Listing_Exchange_Code = 'HOSE'`. Cấu trúc giống hệt Nhóm 11 (HNX), chỉ khác filter sàn — **reuse KPI_ID** K_GSDC_50–62(+YOY) + K_GSDC_79 (Ngành, reuse từ Nhóm 11) + K_GSDC_80–92 (theo ngành, reuse KPI_ID, chỉ đổi filter sàn). Reuse 100% Fact/Dimension của Nhóm 11.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_50 | Tổng tài sản (HOSE) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=270/270/300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_50_YOY | Tổng tài sản — YoY | % | Phái sinh | data_val WHERE row_desc=270/270/300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_51 | Nợ phải trả (HOSE) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=300/300/400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_51_YOY | Nợ phải trả — YoY | % | Phái sinh | data_val WHERE row_desc=300/300/400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_52 | Vốn CSH (HOSE) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_52_YOY | Vốn CSH — YoY | % | Phái sinh | data_val WHERE row_desc=400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_53 | Vốn điều lệ (HOSE) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=411/411/411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_53_YOY | Vốn điều lệ — YoY | % | Phái sinh | data_val WHERE row_desc=411/411/411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_54 | Lợi nhuận sau thuế (HOSE) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_54_YOY | LNST — YoY | % | Phái sinh | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_55 | ROA (HOSE) | % | Phái sinh | data_val WHERE row_desc=270/270/300 + 60/60/21, report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_55_YOY | ROA — YoY | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_55), report=—, col_desc=— | fr_value | **READY** |
| K_GSDC_56 | ROE (HOSE) | % | Phái sinh | data_val WHERE row_desc=400/400/500 + 60/60/21, report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_56_YOY | ROE — YoY | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_56), report=—, col_desc=— | fr_value | **READY** |
| K_GSDC_57 | Hàng tồn kho (HOSE) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=140/140/—, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_57_YOY | Hàng tồn kho — YoY | % | Phái sinh | data_val WHERE row_desc=140/140/—, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_58 | Doanh thu thuần (HOSE) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=10/10/03, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_58_YOY | Doanh thu — YoY | % | Phái sinh | data_val WHERE row_desc=10/10/03, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_59 | Lợi nhuận dồn tích YTD (HOSE) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=421/421/— (td không có trong BA SQL), report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_59_YOY | LN YTD — YoY | % | Phái sinh | data_val WHERE row_desc=421/421/— (td không có trong BA SQL), report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_60 | Phải thu (HOSE) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=130+210/130+210/251, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_60_YOY | Phải thu — YoY | % | Phái sinh | data_val WHERE row_desc=130+210/130+210/251, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_61 | Tiền và tương đương tiền (HOSE) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=110/110/110+120, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_61_YOY | Tiền TĐT — YoY | % | Phái sinh | data_val WHERE row_desc=110/110/110+120, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_62 | Nợ / Vốn CSH (HOSE) | Lần (x) | Phái sinh | data_val WHERE row_desc=300/300/400 + 400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_62_YOY | Nợ/Vốn CSH — YoY | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_62), report=—, col_desc=— | fr_value | **READY** |
| K_GSDC_79 | Ngành | Text | Chiều | business_line_level_1_code (xem KPI liên quan cùng công thức) | public_company | **READY** |
| K_GSDC_80 | Tổng tài sản — theo ngành (HOSE) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=270/270/300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_81 | Nợ phải trả — theo ngành (HOSE) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=300/300/400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_82 | Vốn CSH — theo ngành (HOSE) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_83 | Vốn điều lệ — theo ngành (HOSE) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=411/411/411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_84 | Lợi nhuận sau thuế — theo ngành (HOSE) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_85 | ROA — theo ngành (HOSE) | % | Phái sinh | data_val WHERE row_desc=270/270/300 + 60/60/21, report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_86 | ROE — theo ngành (HOSE) | % | Phái sinh | data_val WHERE row_desc=400/400/500 + 60/60/21, report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_87 | Hàng tồn kho — theo ngành (HOSE) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=140/140/—, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_88 | Doanh thu — theo ngành (HOSE) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=10/10/03, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_89 | Lợi nhuận dồn tích YTD — theo ngành (HOSE) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=421/421/— (td không có trong BA SQL), report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_90 | Phải thu — theo ngành (HOSE) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=130+210/130+210/251, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_91 | Tiền và tương đương tiền — theo ngành (HOSE) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=110/110/110+120, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_92 | Nợ/Vốn CSH — theo ngành (HOSE) | Lần (x) | Phái sinh | data_val WHERE row_desc=300/300/400 + 400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |

**Star Schema:** dùng chung với Nhóm 7/11 (không có erDiagram riêng). Filter sàn = `Public Company Dimension.Equity_Listing_Exchange_Code = 'HOSE'`.

> **Ghi chú filter Active (K_GSDC_79):** giống K_GSDC_63 Nhóm 8/K_GSDC_79 Nhóm 11 — filter `cl_business_line.active_indicator = 1`.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    fct_pc_fr_val_g13["Fact Public Company Financial Report Value"] --> R13["K_GSDC_50-62,79-92+YOY: Tổng hợp chỉ tiêu tài chính theo sàn HOSE"]
    public_company_dim_g13["Public Company Dimension"] --> R13
    financial_rpt_catalog_dim_g13["Financial Report Catalog Dimension"] --> R13
```

**Bảng grain:** như Nhóm 7.

---

#### Nhóm 14 — STT 14: Thống kê niêm yết sàn UPCoM

> Phân loại: **Phân tích**
> Atomic: `Public Company` ← IDS.company_profiles — **draft** (chưa approved)
> Filter: `equity_listing_exchange_code = 'UPCOM'`
> K_GSDC_48/49 theo đúng logic Nhóm 6, thêm filter `Equity_Listing_Exchange_Code='UPCOM'` (BA SQL dòng 194-195).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_46 | Ngày thống kê (Năm/Quý) | Text | Chiều (Slicer) | — (trực tiếp) | — | **READY** — Tham số `:year` / `:quarter` — reuse K_GSDC_46 |
| K_GSDC_78 | Sàn | Text | Chiều | equity_listing_exchange_code (trực tiếp) | Public Company | **READY** — Filter cố định `= 'UPCOM'` — reuse KPI Sàn (K_GSDC_78), khác filter |
| K_GSDC_47 | Số doanh nghiệp theo từng sàn | DN | Cơ sở | ids_registration_dt (trực tiếp) | Public Company | **READY** — COUNT DISTINCT WHERE ids_registration_dt <= cuối kỳ AND equity_listing_exchange_code = 'UPCOM' |
| K_GSDC_48 | Tỷ lệ nộp BCTC theo từng sàn (quý) | % | Phái sinh | deadline_dt / actual_submit_dt / period_year / period_tp_code (trực tiếp) | Violation Report | **READY** — Reuse công thức K_GSDC_48 Nhóm 6, filter `Equity_Listing_Exchange_Code='UPCOM'` |
| K_GSDC_49 | Số DN báo lãi theo từng sàn | DN | Cơ sở | data_val (trực tiếp) | Financial Report Value | **READY** — Reuse công thức K_GSDC_49 Nhóm 6 (`Fact Public Company Financial Report Value`), filter `Equity_Listing_Exchange_Code='UPCOM'` |

**Star Schema, Lineage, Bảng grain:** giống Nhóm 6 — K_GSDC_49 dùng `Fact Public Company Financial Report Value`/`Financial Report Catalog Dimension` (Nhóm 7), không dùng `Fact Violation Report Snapshot` — chỉ khác filter sàn `= 'UPCOM'`.

---

#### Nhóm 15 — STT 15: Tổng hợp chỉ tiêu tài chính theo sàn UPCOM

> Phân loại: **Phân tích**
> Filter: `Equity_Listing_Exchange_Code = 'UPCOM'`. Cấu trúc giống hệt Nhóm 11 (HNX), chỉ khác filter sàn — **reuse KPI_ID** K_GSDC_50–62(+YOY) + K_GSDC_79 (Ngành, reuse từ Nhóm 11) + K_GSDC_80–92 (theo ngành, reuse KPI_ID, chỉ đổi filter sàn). Reuse 100% Fact/Dimension của Nhóm 11.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_50 | Tổng tài sản (UPCOM) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=270/270/300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_50_YOY | Tổng tài sản — YoY | % | Phái sinh | data_val WHERE row_desc=270/270/300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_51 | Nợ phải trả (UPCOM) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=300/300/400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_51_YOY | Nợ phải trả — YoY | % | Phái sinh | data_val WHERE row_desc=300/300/400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_52 | Vốn CSH (UPCOM) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_52_YOY | Vốn CSH — YoY | % | Phái sinh | data_val WHERE row_desc=400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_53 | Vốn điều lệ (UPCOM) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=411/411/411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_53_YOY | Vốn điều lệ — YoY | % | Phái sinh | data_val WHERE row_desc=411/411/411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_54 | Lợi nhuận sau thuế (UPCOM) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_54_YOY | LNST — YoY | % | Phái sinh | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_55 | ROA (UPCOM) | % | Phái sinh | data_val WHERE row_desc=270/270/300 + 60/60/21, report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_55_YOY | ROA — YoY | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_55), report=—, col_desc=— | fr_value | **READY** |
| K_GSDC_56 | ROE (UPCOM) | % | Phái sinh | data_val WHERE row_desc=400/400/500 + 60/60/21, report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_56_YOY | ROE — YoY | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_56), report=—, col_desc=— | fr_value | **READY** |
| K_GSDC_57 | Hàng tồn kho (UPCOM) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=140/140/—, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_57_YOY | Hàng tồn kho — YoY | % | Phái sinh | data_val WHERE row_desc=140/140/—, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_58 | Doanh thu thuần (UPCOM) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=10/10/03, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_58_YOY | Doanh thu — YoY | % | Phái sinh | data_val WHERE row_desc=10/10/03, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_59 | Lợi nhuận dồn tích YTD (UPCOM) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=421/421/— (td không có trong BA SQL), report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_59_YOY | LN YTD — YoY | % | Phái sinh | data_val WHERE row_desc=421/421/— (td không có trong BA SQL), report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_60 | Phải thu (UPCOM) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=130+210/130+210/251, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_60_YOY | Phải thu — YoY | % | Phái sinh | data_val WHERE row_desc=130+210/130+210/251, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_61 | Tiền và tương đương tiền (UPCOM) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=110/110/110+120, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_61_YOY | Tiền TĐT — YoY | % | Phái sinh | data_val WHERE row_desc=110/110/110+120, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_62 | Nợ / Vốn CSH (UPCOM) | Lần (x) | Phái sinh | data_val WHERE row_desc=300/300/400 + 400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_62_YOY | Nợ/Vốn CSH — YoY | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_62), report=—, col_desc=— | fr_value | **READY** |
| K_GSDC_79 | Ngành | Text | Chiều | business_line_level_1_code (xem KPI liên quan cùng công thức) | public_company | **READY** |
| K_GSDC_80 | Tổng tài sản — theo ngành (UPCOM) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=270/270/300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_81 | Nợ phải trả — theo ngành (UPCOM) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=300/300/400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_82 | Vốn CSH — theo ngành (UPCOM) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_83 | Vốn điều lệ — theo ngành (UPCOM) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=411/411/411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_84 | Lợi nhuận sau thuế — theo ngành (UPCOM) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_85 | ROA — theo ngành (UPCOM) | % | Phái sinh | data_val WHERE row_desc=270/270/300 + 60/60/21, report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_86 | ROE — theo ngành (UPCOM) | % | Phái sinh | data_val WHERE row_desc=400/400/500 + 60/60/21, report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_87 | Hàng tồn kho — theo ngành (UPCOM) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=140/140/—, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_88 | Doanh thu — theo ngành (UPCOM) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=10/10/03, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_89 | Lợi nhuận dồn tích YTD — theo ngành (UPCOM) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=421/421/— (td không có trong BA SQL), report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_90 | Phải thu — theo ngành (UPCOM) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=130+210/130+210/251, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_91 | Tiền và tương đương tiền — theo ngành (UPCOM) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=110/110/110+120, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_92 | Nợ/Vốn CSH — theo ngành (UPCOM) | Lần (x) | Phái sinh | data_val WHERE row_desc=300/300/400 + 400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |

**Star Schema:** dùng chung với Nhóm 7/11 (không có erDiagram riêng). Filter sàn = `Public Company Dimension.Equity_Listing_Exchange_Code = 'UPCOM'`.

> **Ghi chú filter Active (K_GSDC_79):** giống K_GSDC_63 Nhóm 8/K_GSDC_79 Nhóm 11 — filter `cl_business_line.active_indicator = 1`.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    fct_pc_fr_val_g15["Fact Public Company Financial Report Value"] --> R15["K_GSDC_50-62,79-92+YOY: Tổng hợp chỉ tiêu tài chính theo sàn UPCOM"]
    public_company_dim_g15["Public Company Dimension"] --> R15
    financial_rpt_catalog_dim_g15["Financial Report Catalog Dimension"] --> R15
```

**Bảng grain:** như Nhóm 7.

---

#### Nhóm 16 — STT 16: Thống kê niêm yết sàn OTC (chưa niêm yết)

> Phân loại: **Phân tích**
> Atomic: `Public Company` ← IDS.company_profiles — **draft** (chưa approved)
> Filter: `equity_listing_exchange_code = 'OTC'`
> K_GSDC_48/49 theo đúng logic Nhóm 6, thêm filter `Equity_Listing_Exchange_Code='OTC'` (BA SQL dòng 239-240).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_46 | Ngày thống kê (Năm/Quý) | Text | Chiều (Slicer) | — (trực tiếp) | — | **READY** — Tham số `:year` / `:quarter` — reuse K_GSDC_46 |
| K_GSDC_78 | Sàn | Text | Chiều | equity_listing_exchange_code (trực tiếp) | Public Company | **READY** — Filter cố định `= 'OTC'` — reuse KPI Sàn (K_GSDC_78), khác filter |
| K_GSDC_47 | Số doanh nghiệp theo từng sàn | DN | Cơ sở | ids_registration_dt (trực tiếp) | Public Company | **READY** — COUNT DISTINCT WHERE ids_registration_dt <= cuối kỳ AND equity_listing_exchange_code = 'OTC' |
| K_GSDC_48 | Tỷ lệ nộp BCTC theo từng sàn (quý) | % | Phái sinh | deadline_dt / actual_submit_dt / period_year / period_tp_code (trực tiếp) | Violation Report | **READY** — Reuse công thức K_GSDC_48 Nhóm 6, filter `Equity_Listing_Exchange_Code='OTC'` |
| K_GSDC_49 | Số DN báo lãi theo từng sàn | DN | Cơ sở | data_val (trực tiếp) | Financial Report Value | **READY** — Reuse công thức K_GSDC_49 Nhóm 6 (`Fact Public Company Financial Report Value`), filter `Equity_Listing_Exchange_Code='OTC'` |

**Star Schema, Lineage, Bảng grain:** giống Nhóm 6 — K_GSDC_49 dùng `Fact Public Company Financial Report Value`/`Financial Report Catalog Dimension` (Nhóm 7), không dùng `Fact Violation Report Snapshot` — chỉ khác filter sàn `= 'OTC'`.

---

#### Nhóm 17 — STT 17: Tổng hợp chỉ tiêu tài chính theo sàn OTC

> Phân loại: **Phân tích**
> Filter: `Equity_Listing_Exchange_Code = 'OTC'`. Cấu trúc giống hệt Nhóm 11 (HNX), chỉ khác filter sàn — **reuse KPI_ID** K_GSDC_50–62(+YOY) + K_GSDC_79 (Ngành, reuse từ Nhóm 11) + K_GSDC_80–92 (theo ngành, reuse KPI_ID, chỉ đổi filter sàn). Reuse 100% Fact/Dimension của Nhóm 11.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_50 | Tổng tài sản (OTC) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=270/270/300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_50_YOY | Tổng tài sản — YoY | % | Phái sinh | data_val WHERE row_desc=270/270/300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_51 | Nợ phải trả (OTC) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=300/300/400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_51_YOY | Nợ phải trả — YoY | % | Phái sinh | data_val WHERE row_desc=300/300/400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_52 | Vốn CSH (OTC) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_52_YOY | Vốn CSH — YoY | % | Phái sinh | data_val WHERE row_desc=400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_53 | Vốn điều lệ (OTC) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=411/411/411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_53_YOY | Vốn điều lệ — YoY | % | Phái sinh | data_val WHERE row_desc=411/411/411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_54 | Lợi nhuận sau thuế (OTC) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_54_YOY | LNST — YoY | % | Phái sinh | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_55 | ROA (OTC) | % | Phái sinh | data_val WHERE row_desc=270/270/300 + 60/60/21, report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_55_YOY | ROA — YoY | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_55), report=—, col_desc=— | fr_value | **READY** |
| K_GSDC_56 | ROE (OTC) | % | Phái sinh | data_val WHERE row_desc=400/400/500 + 60/60/21, report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_56_YOY | ROE — YoY | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_56), report=—, col_desc=— | fr_value | **READY** |
| K_GSDC_57 | Hàng tồn kho (OTC) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=140/140/—, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_57_YOY | Hàng tồn kho — YoY | % | Phái sinh | data_val WHERE row_desc=140/140/—, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_58 | Doanh thu thuần (OTC) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=10/10/03, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_58_YOY | Doanh thu — YoY | % | Phái sinh | data_val WHERE row_desc=10/10/03, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_59 | Lợi nhuận dồn tích YTD (OTC) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=421/421/— (td không có trong BA SQL), report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_59_YOY | LN YTD — YoY | % | Phái sinh | data_val WHERE row_desc=421/421/— (td không có trong BA SQL), report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_60 | Phải thu (OTC) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=130+210/130+210/251, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_60_YOY | Phải thu — YoY | % | Phái sinh | data_val WHERE row_desc=130+210/130+210/251, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_61 | Tiền và tương đương tiền (OTC) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=110/110/110+120, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_61_YOY | Tiền TĐT — YoY | % | Phái sinh | data_val WHERE row_desc=110/110/110+120, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_62 | Nợ / Vốn CSH (OTC) | Lần (x) | Phái sinh | data_val WHERE row_desc=300/300/400 + 400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_62_YOY | Nợ/Vốn CSH — YoY | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_62), report=—, col_desc=— | fr_value | **READY** |
| K_GSDC_79 | Ngành | Text | Chiều | business_line_level_1_code (xem KPI liên quan cùng công thức) | public_company | **READY** |
| K_GSDC_80 | Tổng tài sản — theo ngành (OTC) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=270/270/300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_81 | Nợ phải trả — theo ngành (OTC) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=300/300/400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_82 | Vốn CSH — theo ngành (OTC) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_83 | Vốn điều lệ — theo ngành (OTC) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=411/411/411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_84 | Lợi nhuận sau thuế — theo ngành (OTC) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_85 | ROA — theo ngành (OTC) | % | Phái sinh | data_val WHERE row_desc=270/270/300 + 60/60/21, report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_86 | ROE — theo ngành (OTC) | % | Phái sinh | data_val WHERE row_desc=400/400/500 + 60/60/21, report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_87 | Hàng tồn kho — theo ngành (OTC) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=140/140/—, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_88 | Doanh thu — theo ngành (OTC) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=10/10/03, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_89 | Lợi nhuận dồn tích YTD — theo ngành (OTC) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=421/421/— (td không có trong BA SQL), report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_90 | Phải thu — theo ngành (OTC) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=130+210/130+210/251, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_91 | Tiền và tương đương tiền — theo ngành (OTC) | Tỉ đồng | Phái sinh | data_val WHERE row_desc=110/110/110+120, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_92 | Nợ/Vốn CSH — theo ngành (OTC) | Lần (x) | Phái sinh | data_val WHERE row_desc=300/300/400 + 400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |

**Star Schema:** dùng chung với Nhóm 7/11 (không có erDiagram riêng). Filter sàn = `Public Company Dimension.Equity_Listing_Exchange_Code = 'OTC'`.

> **Ghi chú filter Active (K_GSDC_79):** giống K_GSDC_63 Nhóm 8/K_GSDC_79 Nhóm 11 — filter `cl_business_line.active_indicator = 1`.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    fct_pc_fr_val_g17["Fact Public Company Financial Report Value"] --> R17["K_GSDC_50-62,79-92+YOY: Tổng hợp chỉ tiêu tài chính theo sàn OTC"]
    public_company_dim_g17["Public Company Dimension"] --> R17
    financial_rpt_catalog_dim_g17["Financial Report Catalog Dimension"] --> R17
```

**Bảng grain:** như Nhóm 7.

---

#### Nhóm 18 — STT 18: Dữ liệu tài chính doanh nghiệp — Metadata BCTC

> Phân loại: **Phân tích**
> Source: `Financial Report Catalog Dimension` — tra cứu danh mục báo cáo/dòng/cột
> `financial_report_catalog`/`fr_row_template`/`fr_column_template` đã có LLD (approved cho row/column template). Mã/Tên báo cáo lấy `financial_report_catalog.fr_catalog_code`/`fr_catalog_nm`, filter `fr_catalog_tp_code = 'i'` (báo cáo loại Input — comment Atomic YAML "I - Báo cáo đầu vào, O - Báo cáo xuất ra") + `active_indicator = 1`; Mã/Tên chỉ tiêu dòng lấy `fr_row_template.fr_row_template_code`/`row_description_reference || ' - ' || fr_row_template_nm`, sắp theo `row_index`; Mã/Tên chỉ tiêu cột tương tự trên `fr_column_template`, sắp theo `column_index`. 4 KPI Chiều dùng chung Dimension (Kỳ báo cáo/Sàn/Ngành/Mã CTĐC-Tên CTĐC) — **READY**.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_752 | Mã báo cáo | Text | Chiều | fr_catalog_code (trực tiếp) | financial_report_catalog, filter fr_catalog_tp_code='i' + active_indicator=1 | READY |
| K_GSDC_753 | Tên báo cáo | Text | Chiều | fr_catalog_nm (trực tiếp) | financial_report_catalog | READY |
| K_GSDC_754 | Mã chỉ tiêu dòng | Text | Chiều | fr_row_template_code (trực tiếp) | fr_row_template | READY |
| K_GSDC_755 | Tên chỉ tiêu dòng | Text | Chiều | row_description_reference \|\| ' - ' \|\| fr_row_template_nm | fr_row_template | READY |
| K_GSDC_756 | Mã chỉ tiêu cột | Text | Chiều | fr_column_template_code (trực tiếp) | fr_column_template | READY |
| K_GSDC_757 | Tên chỉ tiêu cột | Text | Chiều | column_description_reference \|\| ' - ' \|\| fr_column_template_nm | fr_column_template | READY |
| K_GSDC_758 | Kỳ báo cáo | Text | Chiều | (tham số :year/:quarter) | —| READY |
| K_GSDC_759 | Sàn giao dịch | Text | Chiều | equity_listing_exchange_code (trực tiếp) | public_company| READY |
| K_GSDC_760 | Danh mục ngành | Text | Chiều | business_line_level_1_code (trực tiếp) | public_company| READY |
| K_GSDC_761 | Mã CTĐC - Tên CTĐC | Text | Chiều | equity_ticker_symbol / pc_nm (trực tiếp) | public_company| READY |

> **Ghi chú filter:** `fr_catalog_tp_code = 'i'` (báo cáo Input) + `active_indicator = 1` áp dụng cho K_GSDC_752/753; kế thừa filter tương ứng `fr_row_template.active_indicator = 1`/`fr_column_template.active_indicator = 1` cho K_GSDC_754-757 (BA ghi `rc.active_flg = 1`, đã map đúng field `active_indicator` — không có filter Active riêng trên row/column template trong SQL BA, kế thừa qua JOIN `report_catalog_id`).

**Star Schema:** dùng chung `Financial Report Catalog Dimension` với Nhóm 7 (không có erDiagram riêng — Dimension đã đủ field `Row_Description_Reference`/`Column_Description_Reference` cho Nhóm 18 lookup trực tiếp, không qua Fact).

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    financial_rpt_catalog_dim_g18["Financial Report Catalog Dimension"] --> R18["K_GSDC_752-757,758,759,760,761: Metadata BCTC"]
    public_company_dim_g18["Public Company Dimension"] --> R18
```

**Bảng grain:** `Financial Report Catalog Dimension` — 1 row / báo cáo × dòng × cột (như Nhóm 7).

---

### Màn hình 3 — Data Explorer: Dữ liệu tài chính doanh nghiệp

Data Explorer cho phép tra cứu BCTC chi tiết theo từng CTDC, kỳ báo cáo và loại hình DN. Toàn bộ STT 19–30 (Nhóm 19-30, 591 KPI) phục vụ bởi `Fact Public Company Financial Report Value` + `Financial Report Catalog Dimension` — **READY**, xem chi tiết từng Nhóm.

**Ghi chú chung toàn bộ MH3:**
- Tất cả chỉ tiêu lấy trực tiếp `Data Value` (`data_val`) từ `Financial Report Value` (`fr_value`) — filter `Enterprise_Type_Code` ('dn'/'bh'/'td'), `Financial_Report_Catalog_Code LIKE '{BCDKT/BCKQKD/BCLCTT_TT/BCLCTT_GT}%'`, `Report_Year`/`Report_Quarter` theo kỳ
- `row_desc` trong BA SQL chính là giá trị filter trên `Row_Code` (`fr_value.row_code`, denormalized text) — không qua field trung gian nào, join `fr_row_template` chỉ để lấy tên hiển thị (`row_description_reference`)
- `col_desc` tương tự trên `Column_Code` (`fr_value.column_code`), join `fr_column_template` lấy tên hiển thị (`column_description_reference`)
- `col_desc='1'` = cuối kỳ / kỳ hiện tại; `col_desc='2'` = đầu kỳ (dùng cho ROA/ROE bình quân — không áp dụng cho Nhóm 19-30 vì MH3 chỉ tra cứu số liệu thô, không tính phái sinh)

---

#### Nhóm 19 — STT 19: DN thông thường — Bảng cân đối kế toán

> Phân loại: **Phân tích**
> Reuse 100% `Fact Public Company Financial Report Value` + `Financial Report Catalog Dimension` đã thiết kế ở Nhóm 7 — filter `Enterprise_Type_Code = 'dn'` (DN thông thường), `Financial_Report_Catalog_Code LIKE 'BCDKT%'`, `Report_Year = :year AND Report_Quarter = :quarter`, `Column_Description_Reference = '1'` (cuối kỳ).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_762 | A – Tài sản ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=100, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_763 | I – Tiền và các khoản tương đương tiền | Tỉ đồng | Cơ sở | data_val WHERE row_desc=110, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_764 | 1. Tiền | Tỉ đồng | Cơ sở | data_val WHERE row_desc=111, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_765 | 2. Các khoản tương đương tiền | Tỉ đồng | Cơ sở | data_val WHERE row_desc=112, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_766 | II – Đầu tư tài chính ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=120, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_767 | 1. Chứng khoán kinh doanh | Tỉ đồng | Cơ sở | data_val WHERE row_desc=121, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_768 | 2. Dự phòng giảm giá chứng khoán kinh doanh | Tỉ đồng | Cơ sở | data_val WHERE row_desc=122, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_769 | 3. Đầu tư nắm giữ đến ngày đáo hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=123, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_770 | III – Các khoản phải thu ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=130, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_771 | 1. Phải thu ngắn hạn của khách hàng | Tỉ đồng | Cơ sở | data_val WHERE row_desc=131, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_772 | 2. Trả trước cho người bán ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=132, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_773 | 3. Phải thu nội bộ ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=133, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_774 | 4. Phải thu theo tiến độ HĐXD | Tỉ đồng | Cơ sở | data_val WHERE row_desc=134, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_775 | 5. Phải thu về cho vay ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=135, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_776 | 6. Phải thu ngắn hạn khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=136, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_777 | 7. Dự phòng phải thu ngắn hạn khó đòi | Tỉ đồng | Cơ sở | data_val WHERE row_desc=137, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_778 | 8. Tài sản thiếu chờ xử lý | Tỉ đồng | Cơ sở | data_val WHERE row_desc=139, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_779 | IV – Hàng tồn kho | Tỉ đồng | Cơ sở | data_val WHERE row_desc=140, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_780 | 1. Hàng tồn kho | Tỉ đồng | Cơ sở | data_val WHERE row_desc=141, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_781 | 2. Dự phòng giảm giá hàng tồn kho | Tỉ đồng | Cơ sở | data_val WHERE row_desc=149, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_782 | V – Tài sản ngắn hạn khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=150, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_783 | 1. Chi phí trả trước ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=151, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_784 | 2. Thuế GTGT được khấu trừ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=152, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_785 | 3. Thuế và các khoản khác phải thu Nhà nước | Tỉ đồng | Cơ sở | data_val WHERE row_desc=153, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_786 | 4. Giao dịch mua bán lại trái phiếu CP | Tỉ đồng | Cơ sở | data_val WHERE row_desc=154, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_787 | 5. Tài sản ngắn hạn khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=155, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_788 | B – Tài sản dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=200, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_789 | I – Các khoản phải thu dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=210, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_790 | 1. Phải thu dài hạn của khách hàng | Tỉ đồng | Cơ sở | data_val WHERE row_desc=211, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_791 | 2. Trả trước cho người bán dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=212, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_792 | 3. Vốn kinh doanh ở đơn vị trực thuộc | Tỉ đồng | Cơ sở | data_val WHERE row_desc=213, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_793 | 4. Phải thu nội bộ dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=214, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_794 | 5. Phải thu về cho vay dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=215, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_795 | 6. Phải thu dài hạn khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=216, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_796 | 7. Dự phòng phải thu dài hạn khó đòi | Tỉ đồng | Cơ sở | data_val WHERE row_desc=219, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_797 | II – Tài sản cố định | Tỉ đồng | Cơ sở | data_val WHERE row_desc=220, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_798 | 1. TSCĐ hữu hình — Nguyên giá | Tỉ đồng | Cơ sở | data_val WHERE row_desc=221, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_799 | 1. TSCĐ hữu hình — Giá trị còn lại | Tỉ đồng | Cơ sở | data_val WHERE row_desc=222, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_800 | 1. TSCĐ hữu hình — Hao mòn lũy kế | Tỉ đồng | Cơ sở | data_val WHERE row_desc=223, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_801 | 2. TSCĐ thuê tài chính — Nguyên giá | Tỉ đồng | Cơ sở | data_val WHERE row_desc=224, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_802 | 2. TSCĐ thuê tài chính — Giá trị còn lại | Tỉ đồng | Cơ sở | data_val WHERE row_desc=225, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_803 | 2. TSCĐ thuê tài chính — Hao mòn lũy kế | Tỉ đồng | Cơ sở | data_val WHERE row_desc=226, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_804 | 3. TSCĐ vô hình — Nguyên giá | Tỉ đồng | Cơ sở | data_val WHERE row_desc=227, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_805 | 3. TSCĐ vô hình — Giá trị còn lại | Tỉ đồng | Cơ sở | data_val WHERE row_desc=228, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_806 | 3. TSCĐ vô hình — Hao mòn lũy kế | Tỉ đồng | Cơ sở | data_val WHERE row_desc=229, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_807 | III – Bất động sản đầu tư — Nguyên giá | Tỉ đồng | Cơ sở | data_val WHERE row_desc=230, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_808 | III – Bất động sản đầu tư — Giá trị còn lại | Tỉ đồng | Cơ sở | data_val WHERE row_desc=231, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_809 | III – Bất động sản đầu tư — Hao mòn lũy kế | Tỉ đồng | Cơ sở | data_val WHERE row_desc=232, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_810 | IV – Tài sản dở dang dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=240, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_811 | 1. Chi phí SXKD dở dang dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=241, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_812 | 2. Chi phí xây dựng cơ bản dở dang | Tỉ đồng | Cơ sở | data_val WHERE row_desc=242, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_813 | V – Đầu tư tài chính dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=250, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_814 | 1. Đầu tư vào công ty con | Tỉ đồng | Cơ sở | data_val WHERE row_desc=251, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_815 | 2. Đầu tư vào công ty liên doanh, liên kết | Tỉ đồng | Cơ sở | data_val WHERE row_desc=252, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_816 | 3. Đầu tư góp vốn vào đơn vị khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=253, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_817 | 4. Dự phòng đầu tư tài chính dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=254, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_818 | 5. Đầu tư nắm giữ đến ngày đáo hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=255, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_819 | VI – Tài sản dài hạn khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=260, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_820 | 1. Chi phí trả trước dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=261, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_821 | 2. Tài sản thuế thu nhập hoãn lại | Tỉ đồng | Cơ sở | data_val WHERE row_desc=262, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_822 | 3. Thiết bị, vật tư, phụ tùng thay thế dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=263, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_823 | 4. Tài sản dài hạn khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=268, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_824 | 5. Lợi thế thương mại | Tỉ đồng | Cơ sở | data_val WHERE row_desc=269, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_825 | Tổng cộng tài sản | Tỉ đồng | Cơ sở | data_val WHERE row_desc=270, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_826 | C – Nợ phải trả | Tỉ đồng | Cơ sở | data_val WHERE row_desc=300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_827 | I – Nợ ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=310, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_828 | 1. Phải trả người bán ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=311, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_829 | 2. Người mua trả tiền trước ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=312, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_830 | 3. Thuế và các khoản phải nộp Nhà nước | Tỉ đồng | Cơ sở | data_val WHERE row_desc=313, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_831 | 4. Phải trả người lao động | Tỉ đồng | Cơ sở | data_val WHERE row_desc=314, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_832 | 5. Chi phí phải trả ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=315, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_833 | 6. Phải trả nội bộ ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=316, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_834 | 7. Phải trả theo tiến độ HĐXD | Tỉ đồng | Cơ sở | data_val WHERE row_desc=317, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_835 | 8. Doanh thu chưa thực hiện ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=318, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_836 | 9. Phải trả ngắn hạn khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=319, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_837 | 10. Vay và nợ thuê tài chính ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=320, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_838 | 11. Dự phòng phải trả ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=321, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_839 | 12. Quỹ khen thưởng, phúc lợi | Tỉ đồng | Cơ sở | data_val WHERE row_desc=322, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_840 | 13. Quỹ bình ổn giá | Tỉ đồng | Cơ sở | data_val WHERE row_desc=323, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_841 | 14. Giao dịch mua bán lại trái phiếu CP | Tỉ đồng | Cơ sở | data_val WHERE row_desc=324, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_842 | II – Nợ dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=330, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_843 | 1. Phải trả người bán dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=331, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_844 | 2. Người mua trả tiền trước dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=332, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_845 | 3. Chi phí phải trả dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=333, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_846 | 4. Phải trả nội bộ về vốn kinh doanh | Tỉ đồng | Cơ sở | data_val WHERE row_desc=334, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_847 | 5. Phải trả nội bộ dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=335, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_848 | 6. Doanh thu chưa thực hiện dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=336, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_849 | 7. Phải trả dài hạn khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=337, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_850 | 8. Vay và nợ thuê tài chính dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=338, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_851 | 9. Trái phiếu chuyển đổi | Tỉ đồng | Cơ sở | data_val WHERE row_desc=339, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_852 | 10. Cổ phiếu ưu đãi | Tỉ đồng | Cơ sở | data_val WHERE row_desc=340, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_853 | 11. Thuế thu nhập hoãn lại phải trả | Tỉ đồng | Cơ sở | data_val WHERE row_desc=341, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_854 | 12. Dự phòng phải trả dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=342, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_855 | 13. Quỹ phát triển KH&CN | Tỉ đồng | Cơ sở | data_val WHERE row_desc=343, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_856 | D – Vốn chủ sở hữu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_857 | I – Vốn chủ sở hữu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=410, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_858 | 1. Vốn góp của chủ sở hữu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_859 | 1a. Cổ phiếu phổ thông có quyền biểu quyết | Tỉ đồng | Cơ sở | data_val WHERE row_desc=411a, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_860 | 1b. Cổ phiếu ưu đãi | Tỉ đồng | Cơ sở | data_val WHERE row_desc=411b, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_861 | 2. Thặng dư vốn cổ phần | Tỉ đồng | Cơ sở | data_val WHERE row_desc=412, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_862 | 3. Quyền chọn chuyển đổi trái phiếu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=413, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_863 | 4. Vốn khác của chủ sở hữu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=414, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_864 | 5. Cổ phiếu quỹ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=415, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_865 | 6. Chênh lệch đánh giá lại tài sản | Tỉ đồng | Cơ sở | data_val WHERE row_desc=416, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_866 | 7. Chênh lệch tỷ giá hối đoái | Tỉ đồng | Cơ sở | data_val WHERE row_desc=417, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_867 | 8. Quỹ đầu tư phát triển | Tỉ đồng | Cơ sở | data_val WHERE row_desc=418, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_868 | 9. Quỹ hỗ trợ sắp xếp doanh nghiệp | Tỉ đồng | Cơ sở | data_val WHERE row_desc=419, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_869 | 10. Quỹ khác thuộc vốn chủ sở hữu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=420, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_870 | 11. Lợi nhuận sau thuế chưa phân phối | Tỉ đồng | Cơ sở | data_val WHERE row_desc=421, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_871 | 11a. LNST chưa PP lũy kế đến đầu kỳ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=421a, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_872 | 11b. LNST chưa PP kỳ này | Tỉ đồng | Cơ sở | data_val WHERE row_desc=421b, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_873 | 12. Nguồn vốn đầu tư XDCB | Tỉ đồng | Cơ sở | data_val WHERE row_desc=422, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_874 | 13. Lợi ích của cổ đông không kiểm soát | Tỉ đồng | Cơ sở | data_val WHERE row_desc=429, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_875 | II – Nguồn kinh phí và quỹ khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=430, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_876 | 1. Nguồn kinh phí | Tỉ đồng | Cơ sở | data_val WHERE row_desc=431, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_877 | 2. Nguồn kinh phí đã hình thành TSCĐ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=432, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_878 | Tổng cộng nguồn vốn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=440, report=BCDKT, col_desc=1 | fr_value | **READY** |

**Star Schema:** dùng chung `Fact Public Company Financial Report Value` + `Financial Report Catalog Dimension` với Nhóm 7 (không có erDiagram riêng — aggregate 1 CTĐC/kỳ, không group-by, khớp Data Explorer tra cứu chi tiết).

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    fct_pc_fr_val_g19["Fact Public Company Financial Report Value"] --> R19["K_GSDC_762-878: DN thông thường — Bảng cân đối kế toán"]
    financial_rpt_catalog_dim_g19["Financial Report Catalog Dimension"] --> R19
```

**Bảng grain:** như Nhóm 7.

---

#### Nhóm 20 — STT 20: DN thông thường — Báo cáo KQKD

> Phân loại: **Phân tích**
> Filter `Enterprise_Type_Code = 'dn'` (DN thông thường), `Financial_Report_Catalog_Code LIKE 'BCKQKD%'`, `Report_Year = :year AND Report_Quarter = :quarter`, `Column_Description_Reference = '1'` (cuối kỳ).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_879 | 1. Doanh thu bán hàng và cung cấp DV | Tỉ đồng | Cơ sở | data_val WHERE row_desc=01, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_880 | 2. Các khoản giảm trừ doanh thu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=02, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_881 | 3. Doanh thu thuần về bán hàng và cung cấp DV | Tỉ đồng | Cơ sở | data_val WHERE row_desc=10, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_882 | 4. Giá vốn hàng bán | Tỉ đồng | Cơ sở | data_val WHERE row_desc=11, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_883 | 5. Lợi nhuận gộp về bán hàng và cung cấp DV | Tỉ đồng | Cơ sở | data_val WHERE row_desc=20, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_884 | 6. Doanh thu hoạt động tài chính | Tỉ đồng | Cơ sở | data_val WHERE row_desc=21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_885 | 7. Chi phí tài chính | Tỉ đồng | Cơ sở | data_val WHERE row_desc=22, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_886 | 7. Chi phí tài chính — Chi phí lãi vay | Tỉ đồng | Cơ sở | data_val WHERE row_desc=23, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_887 | 8. Phần lãi/lỗ trong công ty liên doanh, LK | Tỉ đồng | Cơ sở | data_val WHERE row_desc=24, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_888 | 9. Chi phí bán hàng | Tỉ đồng | Cơ sở | data_val WHERE row_desc=25, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_889 | 10. Chi phí quản lý doanh nghiệp | Tỉ đồng | Cơ sở | data_val WHERE row_desc=26, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_890 | 11. Lợi nhuận thuần từ HĐKD | Tỉ đồng | Cơ sở | data_val WHERE row_desc=30, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_891 | 12. Thu nhập khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=31, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_892 | 13. Chi phí khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=32, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_893 | 14. Lợi nhuận khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=40, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_894 | 15. Tổng lợi nhuận kế toán trước thuế | Tỉ đồng | Cơ sở | data_val WHERE row_desc=50, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_895 | 16. Chi phí thuế TNDN hiện hành | Tỉ đồng | Cơ sở | data_val WHERE row_desc=51, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_896 | 17. Chi phí thuế TNDN hoãn lại | Tỉ đồng | Cơ sở | data_val WHERE row_desc=52, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_897 | 18. Lợi nhuận sau thuế TNDN | Tỉ đồng | Cơ sở | data_val WHERE row_desc=60, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_898 | 19. LNST của công ty mẹ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=61, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_899 | 20. LNST của cổ đông không kiểm soát | Tỉ đồng | Cơ sở | data_val WHERE row_desc=62, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_900 | 21. Lãi cơ bản trên cổ phiếu (EPS) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=70, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_901 | 22. Lãi suy giảm trên cổ phiếu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=71, report=BCKQKD, col_desc=1 | fr_value | **READY** |

**Star Schema:** dùng chung `Fact Public Company Financial Report Value` + `Financial Report Catalog Dimension` với Nhóm 7 (không có erDiagram riêng — aggregate 1 CTĐC/kỳ, không group-by, khớp Data Explorer tra cứu chi tiết).

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    fct_pc_fr_val_g20["Fact Public Company Financial Report Value"] --> R20["K_GSDC_879-901: DN thông thường — Báo cáo KQKD"]
    financial_rpt_catalog_dim_g20["Financial Report Catalog Dimension"] --> R20
```

**Bảng grain:** như Nhóm 7.

---

#### Nhóm 21 — STT 21: DN thông thường — Báo cáo LCTT trực tiếp

> Phân loại: **Phân tích**
> Filter `Enterprise_Type_Code = 'dn'` (DN thông thường), `Financial_Report_Catalog_Code LIKE 'BCLCTT_TT%'`, `Report_Year = :year AND Report_Quarter = :quarter`, `Column_Description_Reference = '1'` (cuối kỳ).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_902 | I. Lưu chuyển tiền từ hoạt động kinh doanh | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_903 | 1. Tiền thu từ bán hàng, cung cấp DV và DT khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=01, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_904 | 2. Tiền chi trả cho người cung cấp hàng hóa và DV | Tỉ đồng | Cơ sở | data_val WHERE row_desc=02, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_905 | 3. Tiền chi trả cho người lao động | Tỉ đồng | Cơ sở | data_val WHERE row_desc=03, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_906 | 4. Tiền lãi vay đã trả | Tỉ đồng | Cơ sở | data_val WHERE row_desc=04, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_907 | 5. Thuế TNDN đã nộp | Tỉ đồng | Cơ sở | data_val WHERE row_desc=05, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_908 | 6. Tiền thu khác từ HĐKD | Tỉ đồng | Cơ sở | data_val WHERE row_desc=06, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_909 | 7. Tiền chi khác cho HĐKD | Tỉ đồng | Cơ sở | data_val WHERE row_desc=07, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_910 | Lưu chuyển tiền thuần từ HĐKD | Tỉ đồng | Cơ sở | data_val WHERE row_desc=20, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_911 | II. Lưu chuyển tiền từ hoạt động đầu tư | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_912 | 1. Tiền chi mua sắm TSCĐ và TSDH khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=21, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_913 | 2. Tiền thu từ thanh lý, nhượng bán TSCĐ và TSDH | Tỉ đồng | Cơ sở | data_val WHERE row_desc=22, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_914 | 3. Tiền chi cho vay, mua công cụ nợ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=23, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_915 | 4. Tiền thu hồi cho vay, bán lại công cụ nợ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=24, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_916 | 5. Tiền chi đầu tư góp vốn vào đơn vị khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=25, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_917 | 6. Tiền thu hồi đầu tư góp vốn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=26, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_918 | 7. Tiền thu lãi cho vay, cổ tức và LN được chia | Tỉ đồng | Cơ sở | data_val WHERE row_desc=27, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_919 | Lưu chuyển tiền thuần từ HĐ đầu tư | Tỉ đồng | Cơ sở | data_val WHERE row_desc=30, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_920 | III. Lưu chuyển tiền từ hoạt động tài chính | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_921 | 1. Tiền thu từ phát hành CP, nhận vốn góp | Tỉ đồng | Cơ sở | data_val WHERE row_desc=31, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_922 | 2. Tiền trả lại vốn góp, mua lại CP đã phát hành | Tỉ đồng | Cơ sở | data_val WHERE row_desc=32, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_923 | 3. Tiền thu từ đi vay | Tỉ đồng | Cơ sở | data_val WHERE row_desc=33, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_924 | 4. Tiền trả nợ gốc vay | Tỉ đồng | Cơ sở | data_val WHERE row_desc=34, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_925 | 5. Tiền trả nợ gốc thuê tài chính | Tỉ đồng | Cơ sở | data_val WHERE row_desc=35, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_926 | 6. Cổ tức, lợi nhuận đã trả cho chủ sở hữu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=36, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_927 | Lưu chuyển tiền thuần từ HĐ tài chính | Tỉ đồng | Cơ sở | data_val WHERE row_desc=40, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_928 | Lưu chuyển tiền thuần trong kỳ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=50, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_929 | Tiền và tương đương tiền đầu kỳ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=60, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_930 | Ảnh hưởng của thay đổi tỷ giá hối đoái | Tỉ đồng | Cơ sở | data_val WHERE row_desc=61, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_931 | Tiền và tương đương tiền cuối kỳ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=70, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |

**Star Schema:** dùng chung `Fact Public Company Financial Report Value` + `Financial Report Catalog Dimension` với Nhóm 7 (không có erDiagram riêng — aggregate 1 CTĐC/kỳ, không group-by, khớp Data Explorer tra cứu chi tiết).

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    fct_pc_fr_val_g21["Fact Public Company Financial Report Value"] --> R21["K_GSDC_902-931: DN thông thường — Báo cáo LCTT trực tiếp"]
    financial_rpt_catalog_dim_g21["Financial Report Catalog Dimension"] --> R21
```

**Bảng grain:** như Nhóm 7.

---

#### Nhóm 22 — STT 22: DN thông thường — Báo cáo LCTT gián tiếp

> Phân loại: **Phân tích**
> Filter `Enterprise_Type_Code = 'dn'` (DN thông thường), `Financial_Report_Catalog_Code LIKE 'BCLCTT_GT%'`, `Report_Year = :year AND Report_Quarter = :quarter`, `Column_Description_Reference = '1'` (cuối kỳ).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_932 | I. Lưu chuyển tiền từ hoạt động kinh doanh | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_933 | 1. Lợi nhuận trước thuế | Tỉ đồng | Cơ sở | data_val WHERE row_desc=01, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_934 | 2. Điều chỉnh cho các khoản | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_935 | Khấu hao TSCĐ và BĐSĐT | Tỉ đồng | Cơ sở | data_val WHERE row_desc=02, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_936 | Các khoản dự phòng | Tỉ đồng | Cơ sở | data_val WHERE row_desc=03, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_937 | Lãi/lỗ chênh lệch tỷ giá do đánh giá lại | Tỉ đồng | Cơ sở | data_val WHERE row_desc=04, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_938 | Lãi/lỗ từ hoạt động đầu tư | Tỉ đồng | Cơ sở | data_val WHERE row_desc=05, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_939 | Chi phí lãi vay | Tỉ đồng | Cơ sở | data_val WHERE row_desc=06, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_940 | Các khoản điều chỉnh khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=07, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_941 | 3. LN từ HĐKD trước thay đổi vốn lưu động | Tỉ đồng | Cơ sở | data_val WHERE row_desc=8, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_942 | Tăng/giảm các khoản phải thu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=9, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_943 | Tăng/giảm hàng tồn kho | Tỉ đồng | Cơ sở | data_val WHERE row_desc=10, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_944 | Tăng/giảm các khoản phải trả | Tỉ đồng | Cơ sở | data_val WHERE row_desc=11, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_945 | Tăng/giảm chi phí trả trước | Tỉ đồng | Cơ sở | data_val WHERE row_desc=12, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_946 | Tăng/giảm chứng khoán kinh doanh | Tỉ đồng | Cơ sở | data_val WHERE row_desc=13, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_947 | Tiền lãi vay đã trả | Tỉ đồng | Cơ sở | data_val WHERE row_desc=14, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_948 | Thuế TNDN đã nộp | Tỉ đồng | Cơ sở | data_val WHERE row_desc=15, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_949 | Tiền thu khác từ HĐKD | Tỉ đồng | Cơ sở | data_val WHERE row_desc=16, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_950 | Tiền chi khác cho HĐKD | Tỉ đồng | Cơ sở | data_val WHERE row_desc=17, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_951 | Lưu chuyển tiền thuần từ HĐKD | Tỉ đồng | Cơ sở | data_val WHERE row_desc=20, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_952 | II. Lưu chuyển tiền từ hoạt động đầu tư | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_953 | 1. Tiền chi mua sắm TSCĐ và TSDH khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=21, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_954 | 2. Tiền thu từ thanh lý, nhượng bán TSCĐ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=22, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_955 | 3. Tiền chi cho vay, mua công cụ nợ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=23, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_956 | 4. Tiền thu hồi cho vay, bán lại công cụ nợ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=24, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_957 | 5. Tiền chi đầu tư góp vốn vào đơn vị khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=25, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_958 | 6. Tiền thu hồi đầu tư góp vốn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=26, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_959 | 7. Tiền thu lãi cho vay, cổ tức và LN | Tỉ đồng | Cơ sở | data_val WHERE row_desc=27, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_960 | Lưu chuyển tiền thuần từ HĐ đầu tư | Tỉ đồng | Cơ sở | data_val WHERE row_desc=30, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_961 | III. Lưu chuyển tiền từ hoạt động tài chính | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_962 | 1. Tiền thu từ phát hành CP, nhận vốn góp | Tỉ đồng | Cơ sở | data_val WHERE row_desc=31, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_963 | 2. Tiền trả lại vốn góp, mua lại CP | Tỉ đồng | Cơ sở | data_val WHERE row_desc=32, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_964 | 3. Tiền thu từ đi vay | Tỉ đồng | Cơ sở | data_val WHERE row_desc=33, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_965 | 4. Tiền trả nợ gốc vay | Tỉ đồng | Cơ sở | data_val WHERE row_desc=34, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_966 | 5. Tiền trả nợ gốc thuê tài chính | Tỉ đồng | Cơ sở | data_val WHERE row_desc=35, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_967 | 6. Cổ tức, lợi nhuận đã trả cho chủ sở hữu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=36, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_968 | 7. Tiền thu từ vốn góp của CĐKKS | Tỉ đồng | Cơ sở | data_val WHERE row_desc=37, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_969 | Lưu chuyển tiền thuần từ HĐ tài chính | Tỉ đồng | Cơ sở | data_val WHERE row_desc=40, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_970 | Lưu chuyển tiền thuần trong kỳ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=50, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_971 | Tiền và tương đương tiền đầu kỳ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=60, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_972 | Ảnh hưởng của thay đổi tỷ giá hối đoái quy đổi ngoại tệ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=61, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_973 | Tiền và tương đương tiền cuối kỳ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=70, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |

**Star Schema:** dùng chung `Fact Public Company Financial Report Value` + `Financial Report Catalog Dimension` với Nhóm 7 (không có erDiagram riêng — aggregate 1 CTĐC/kỳ, không group-by, khớp Data Explorer tra cứu chi tiết).

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    fct_pc_fr_val_g22["Fact Public Company Financial Report Value"] --> R22["K_GSDC_932-973: DN thông thường — Báo cáo LCTT gián tiếp"]
    financial_rpt_catalog_dim_g22["Financial Report Catalog Dimension"] --> R22
```

**Bảng grain:** như Nhóm 7.

---

#### Nhóm 23 — STT 23: DN bảo hiểm — Bảng cân đối kế toán

> Phân loại: **Phân tích**
> Filter `Enterprise_Type_Code = 'bh'` (DN bảo hiểm), `Financial_Report_Catalog_Code LIKE 'BCDKT%'`, `Report_Year = :year AND Report_Quarter = :quarter`, `Column_Description_Reference = '1'` (cuối kỳ).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_974 | A - Tài sản ngắn hạn (100) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=100, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_975 | I. Tiền và các khoản tương đương tiền | Tỉ đồng | Cơ sở | data_val WHERE row_desc=110, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_976 | 1. Tiền | Tỉ đồng | Cơ sở | data_val WHERE row_desc=111, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_977 | 2. Các khoản tương đương tiền | Tỉ đồng | Cơ sở | data_val WHERE row_desc=112, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_978 | II. Các khoản đầu tư tài chính ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=120, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_979 | 1. Đầu tư ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=121, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_980 | 2. Dự phòng giảm giá đầu tư ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=129, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_981 | III. Các khoản phải thu ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=130, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_982 | 1. Phải thu của khách hàng | Tỉ đồng | Cơ sở | data_val WHERE row_desc=131, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_983 | 1.1 Phải thu về hợp đồng bảo hiểm | Tỉ đồng | Cơ sở | data_val WHERE row_desc=131.1, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_984 | 1.2 Phải thu khác của khách hàng | Tỉ đồng | Cơ sở | data_val WHERE row_desc=131.2, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_985 | 2. Trả trước cho người bán | Tỉ đồng | Cơ sở | data_val WHERE row_desc=132, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_986 | 3. Phải thu nội bộ ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=133, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_987 | 4. Các khoản phải thu khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=135, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_988 | 5. Dự phòng các khoản phải thu khó đòi | Tỉ đồng | Cơ sở | data_val WHERE row_desc=139, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_989 | IV. Hàng tồn kho | Tỉ đồng | Cơ sở | data_val WHERE row_desc=140, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_990 | 1. Hàng tồn kho | Tỉ đồng | Cơ sở | data_val WHERE row_desc=141, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_991 | 2. Dự phòng giảm giá hàng tồn kho | Tỉ đồng | Cơ sở | data_val WHERE row_desc=149, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_992 | V. Tài sản ngắn hạn khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=150, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_993 | 1. Chi phí trả trước ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=151, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_994 | 1.1. Chi phí hoa hồng chưa phân bổ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=151.1, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_995 | 1.2. Chi phí trả trước ngắn hạn khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=151.2, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_996 | 2. Thuế GTGT được khấu trừ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=152, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_997 | 3. Thuế và các khoản khác phải thu Nhà nước | Tỉ đồng | Cơ sở | data_val WHERE row_desc=154, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_998 | 4. Giao dịch mua bán lại trái phiếu Chính phủ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=157, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_999 | 5. Tài sản ngắn hạn khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=158, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1000 | VIII. Tài sản tái bảo hiểm | Tỉ đồng | Cơ sở | data_val WHERE row_desc=190, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1001 | 1. Dự phòng phí nhượng tái bảo hiểm | Tỉ đồng | Cơ sở | data_val WHERE row_desc=191, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1002 | 2. Dự phòng bồi thường nhượng tái bảo hiểm | Tỉ đồng | Cơ sở | data_val WHERE row_desc=192, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1003 | B - Tài sản dài hạn (200) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=200, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1004 | I. Các khoản phải thu dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=210, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1005 | 1. Phải thu dài hạn của khách hàng | Tỉ đồng | Cơ sở | data_val WHERE row_desc=211, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1006 | 2. Vốn kinh doanh của đơn vị trực thuộc | Tỉ đồng | Cơ sở | data_val WHERE row_desc=212, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1007 | 3. Phải thu dài hạn nội bộ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=213, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1008 | 4. Phải thu dài hạn khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=218, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1009 | 4.1. Kí quỹ bảo hiểm | Tỉ đồng | Cơ sở | data_val WHERE row_desc=218.1, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1010 | 4.2. Phải thu dài hạn khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=218.2, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1011 | II. Tài sản cố định | Tỉ đồng | Cơ sở | data_val WHERE row_desc=220, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1012 | 1. Tài sản cố định hữu hình | Tỉ đồng | Cơ sở | data_val WHERE row_desc=221, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1013 | · Nguyên giá | Tỉ đồng | Cơ sở | data_val WHERE row_desc=222, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1014 | · Giá trị hao mòn luỹ kế (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=223, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1015 | 2. Tài sản cố định thuê tài chính | Tỉ đồng | Cơ sở | data_val WHERE row_desc=224, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1016 | · Nguyên giá | Tỉ đồng | Cơ sở | data_val WHERE row_desc=225, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1017 | · Giá trị hao mòn luỹ kế (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=226, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1018 | 3. Tài sản cố định vô hình | Tỉ đồng | Cơ sở | data_val WHERE row_desc=227, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1019 | · Nguyên giá | Tỉ đồng | Cơ sở | data_val WHERE row_desc=228, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1020 | · Giá trị hao mòn luỹ kế (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=229, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1021 | 4. Chi phí xây dựng cơ bản dở dang | Tỉ đồng | Cơ sở | data_val WHERE row_desc=230, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1022 | III. Bất động sản đầu tư | Tỉ đồng | Cơ sở | data_val WHERE row_desc=240, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1023 | · Nguyên giá | Tỉ đồng | Cơ sở | data_val WHERE row_desc=241, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1024 | · Giá trị hao mòn luỹ kế | Tỉ đồng | Cơ sở | data_val WHERE row_desc=242, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1025 | IV. Các khoản đầu tư tài chính dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=250, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1026 | 1. Đầu tư vào công ty con | Tỉ đồng | Cơ sở | data_val WHERE row_desc=251, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1027 | 2. Đầu tư vào công ty liên kết, liên doanh | Tỉ đồng | Cơ sở | data_val WHERE row_desc=252, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1028 | 3. Đầu tư dài hạn khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=258, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1029 | 4. Dự phòng giảm giá đầu tư tài chính dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=259, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1030 | V. Tài sản dài hạn khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=260, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1031 | 1. Chi phí trả trước dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=261, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1032 | Tổng cộng tài sản (270) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=270, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1033 | A - Nợ phải trả (300) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1034 | I. Nợ ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=310, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1035 | 1. Vay và nợ ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=311, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1036 | 2. Phải trả cho người bán | Tỉ đồng | Cơ sở | data_val WHERE row_desc=312, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1037 | 2.1. Phải trả về hợp đồng bảo hiểm | Tỉ đồng | Cơ sở | data_val WHERE row_desc=312.1, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1038 | 2.2. Phải trả khác cho người bán | Tỉ đồng | Cơ sở | data_val WHERE row_desc=312.2, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1039 | 3. Người mua trả tiền trước | Tỉ đồng | Cơ sở | data_val WHERE row_desc=313, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1040 | 4. Thuế và các khoản phải nộp Nhà nước | Tỉ đồng | Cơ sở | data_val WHERE row_desc=314, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1041 | 5. Phải trả người lao động | Tỉ đồng | Cơ sở | data_val WHERE row_desc=315, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1042 | 6. Chi phí phải trả | Tỉ đồng | Cơ sở | data_val WHERE row_desc=316, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1043 | 7. Phải trả nội bộ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=317, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1044 | 8. Doanh thu chưa thực hiện ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=318, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1045 | 9. Các khoản phải trả, phải nộp khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=319, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1046 | 10. Doanh thu hoa hồng chưa được hưởng | Tỉ đồng | Cơ sở | data_val WHERE row_desc=319.1, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1047 | 11. Dự phòng phải trả ngắn hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=320, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1048 | 12. Quỹ khen thưởng, phúc lợi | Tỉ đồng | Cơ sở | data_val WHERE row_desc=323, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1049 | 13. Giao dịch mua bán lại trái phiếu Chính phủ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=327, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1050 | 14. Dự phòng nghiệp vụ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=329, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1051 | 14.1. Dự phòng phí bảo hiểm gốc và nhận TBH | Tỉ đồng | Cơ sở | data_val WHERE row_desc=329.1, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1052 | 14.2. Dự phòng bồi thường bảo hiểm gốc và nhận TBH | Tỉ đồng | Cơ sở | data_val WHERE row_desc=329.2, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1053 | 14.3. Dự phòng dao động lớn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=329.3, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1054 | II. Nợ dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=330, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1055 | 1. Phải trả dài hạn người bán | Tỉ đồng | Cơ sở | data_val WHERE row_desc=331, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1056 | 2. Phải trả dài hạn nội bộ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=332, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1057 | 3. Phải trả dài hạn khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=333, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1058 | 4. Vay và nợ dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=334, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1059 | 5. Thuế thu nhập hoãn lại phải trả | Tỉ đồng | Cơ sở | data_val WHERE row_desc=335, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1060 | 6. Dự phòng trợ cấp mất việc làm | Tỉ đồng | Cơ sở | data_val WHERE row_desc=336, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1061 | 7. Dự phòng phải trả dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=337, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1062 | 8. Doanh thu chưa thực hiện dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=338, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1063 | 9. Quỹ phát triển khoa học và công nghệ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=339, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1064 | B - Vốn chủ sở hữu (400) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1065 | I. Vốn chủ sở hữu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=410, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1066 | 1. Vốn đầu tư của chủ sở hữu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1067 | 2. Thặng dư vốn cổ phần | Tỉ đồng | Cơ sở | data_val WHERE row_desc=412, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1068 | 3. Vốn khác của chủ sở hữu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=413, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1069 | 4. Cổ phiếu quỹ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=414, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1070 | 5. Chênh lệch đánh giá lại tài sản | Tỉ đồng | Cơ sở | data_val WHERE row_desc=415, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1071 | 6. Chênh lệch tỷ giá hối đoái | Tỉ đồng | Cơ sở | data_val WHERE row_desc=416, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1072 | 7. Quỹ đầu tư phát triển | Tỉ đồng | Cơ sở | data_val WHERE row_desc=417, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1073 | 8. Quỹ dự phòng tài chính | Tỉ đồng | Cơ sở | data_val WHERE row_desc=418, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1074 | 9. Quỹ dự trữ bắt buộc | Tỉ đồng | Cơ sở | data_val WHERE row_desc=419, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1075 | 10. Quỹ khác thuộc vốn chủ sở hữu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=420, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1076 | 11. Lợi nhuận sau thuế chưa phân phối | Tỉ đồng | Cơ sở | data_val WHERE row_desc=421, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1077 | Tổng cộng nguồn vốn (440) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=440, report=BCDKT, col_desc=1 | fr_value | **READY** |

**Star Schema:** dùng chung `Fact Public Company Financial Report Value` + `Financial Report Catalog Dimension` với Nhóm 7 (không có erDiagram riêng — aggregate 1 CTĐC/kỳ, không group-by, khớp Data Explorer tra cứu chi tiết).

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    fct_pc_fr_val_g23["Fact Public Company Financial Report Value"] --> R23["K_GSDC_974-1077: DN bảo hiểm — Bảng cân đối kế toán"]
    financial_rpt_catalog_dim_g23["Financial Report Catalog Dimension"] --> R23
```

**Bảng grain:** như Nhóm 7.

---

#### Nhóm 24 — STT 24: DN bảo hiểm — Báo cáo KQKD

> Phân loại: **Phân tích**
> Filter `Enterprise_Type_Code = 'bh'` (DN bảo hiểm), `Financial_Report_Catalog_Code LIKE 'BCKQKD%'`, `Report_Year = :year AND Report_Quarter = :quarter`, `Column_Description_Reference = '1'` (cuối kỳ).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_1078 | 1. Doanh thu thuần hoạt động kinh doanh bảo hiểm | Tỉ đồng | Cơ sở | data_val WHERE row_desc=10, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1079 | 2. Doanh thu kinh doanh bất động sản đầu tư | Tỉ đồng | Cơ sở | data_val WHERE row_desc=11, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1080 | 3. Doanh thu hoạt động tài chính | Tỉ đồng | Cơ sở | data_val WHERE row_desc=12, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1081 | 4. Thu nhập khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=13, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1082 | 5. Tổng chi phí hoạt động kinh doanh bảo hiểm | Tỉ đồng | Cơ sở | data_val WHERE row_desc=20, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1083 | 6. Giá vốn bất động sản đầu tư | Tỉ đồng | Cơ sở | data_val WHERE row_desc=21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1084 | 7. Chi phí hoạt động tài chính | Tỉ đồng | Cơ sở | data_val WHERE row_desc=22, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1085 | 8. Chi phí quản lý doanh nghiệp | Tỉ đồng | Cơ sở | data_val WHERE row_desc=23, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1086 | 9. Chi phí khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=24, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1087 | 10. Tổng lợi nhuận kế toán trước thuế (50=10+11+12+13-20-21-22-23-24) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=50, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1088 | 11. Chi phí thuế TNDN hiện hành | Tỉ đồng | Cơ sở | data_val WHERE row_desc=51, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1089 | 12. Chi phí thuế TNDN hoãn lại | Tỉ đồng | Cơ sở | data_val WHERE row_desc=52, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1090 | 13. Lợi nhuận sau thuế thu nhập doanh nghiệp (60=50-51-52) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=60, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1091 | 14. Lợi ích của cổ đông không kiểm soát | Tỉ đồng | Cơ sở | data_val WHERE row_desc=61, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1092 | 15. Lợi nhuận sau thuế (62=60-61) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=62, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1093 | 16. Lãi cơ bản trên cổ phiếu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=70, report=BCKQKD, col_desc=1 | fr_value | **READY** |

**Star Schema:** dùng chung `Fact Public Company Financial Report Value` + `Financial Report Catalog Dimension` với Nhóm 7 (không có erDiagram riêng — aggregate 1 CTĐC/kỳ, không group-by, khớp Data Explorer tra cứu chi tiết).

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    fct_pc_fr_val_g24["Fact Public Company Financial Report Value"] --> R24["K_GSDC_1078-1093: DN bảo hiểm — Báo cáo KQKD"]
    financial_rpt_catalog_dim_g24["Financial Report Catalog Dimension"] --> R24
```

**Bảng grain:** như Nhóm 7.

---

#### Nhóm 25 — STT 25: DN bảo hiểm — Báo cáo LCTT trực tiếp

> Phân loại: **Phân tích**
> Filter `Enterprise_Type_Code = 'bh'` (DN bảo hiểm), `Financial_Report_Catalog_Code LIKE 'BCLCTT_TT%'`, `Report_Year = :year AND Report_Quarter = :quarter`, `Column_Description_Reference = '1'` (cuối kỳ).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_1094 | I - Lưu chuyển tiền từ hoạt động kinh doanh | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_1095 | 1. Tiền từ thu phí và hoa hồng | Tỉ đồng | Cơ sở | data_val WHERE row_desc=01, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1096 | 2. Tiền thu từ các khoản nợ phí và hoa hồng | Tỉ đồng | Cơ sở | data_val WHERE row_desc=02, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1097 | 3. Tiền thu từ các khoản thu được giảm chi | Tỉ đồng | Cơ sở | data_val WHERE row_desc=03, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1098 | 4. Tiền thu từ các hoạt động kinh doanh khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=04, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1099 | 5. Trả tiền bồi thường bảo hiểm | Tỉ đồng | Cơ sở | data_val WHERE row_desc=05, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1100 | 6. Trả tiền hoa hồng và các khoản nợ khác của kinh doanh bảo hiểm | Tỉ đồng | Cơ sở | data_val WHERE row_desc=06, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1101 | 7. Trả tiền cho người bán, người cung cấp dịch vụ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=07, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1102 | 8. Trả tiền cho cán bộ công nhân viên | Tỉ đồng | Cơ sở | data_val WHERE row_desc=08, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1103 | 9. Trả tiền nộp thuế và các khoản nợ Nhà nước | Tỉ đồng | Cơ sở | data_val WHERE row_desc=09, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1104 | 10. Trả tiền cho các khoản nợ khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=10, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1105 | 11. Tiền tạm ứng cho cán bộ công nhân viên và ứng trước cho người bán | Tỉ đồng | Cơ sở | data_val WHERE row_desc=11, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1106 | Lưu chuyển tiền thuần từ hoạt động kinh doanh | Tỉ đồng | Cơ sở | data_val WHERE row_desc=20, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1107 | II - Lưu chuyển tiền từ hoạt động đầu tư | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_1108 | 1. Tiền thu từ các khoản đầu tư vào đơn vị khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=21, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1109 | 2. Tiền thu lãi đầu tư | Tỉ đồng | Cơ sở | data_val WHERE row_desc=22, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1110 | 3. Tiền thu do bán tài sản cố định | Tỉ đồng | Cơ sở | data_val WHERE row_desc=23, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1111 | 4. Tiền đầu tư vào các đơn vị khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=24, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1112 | 5. Tiền mua tài sản cố định | Tỉ đồng | Cơ sở | data_val WHERE row_desc=25, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1113 | Lưu chuyển tiền thuần từ hoạt động đầu tư | Tỉ đồng | Cơ sở | data_val WHERE row_desc=30, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1114 | III - Lưu chuyển tiền từ hoạt động tài chính | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_1115 | 1. Tiền thu do đi vay | Tỉ đồng | Cơ sở | data_val WHERE row_desc=31, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1116 | 2. Tiền thu do các chủ sở hữu góp vốn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=32, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1117 | 3. Tiền thu từ lãi tiền gửi | Tỉ đồng | Cơ sở | data_val WHERE row_desc=33, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1118 | 4. Tiền đã trả nợ vay | Tỉ đồng | Cơ sở | data_val WHERE row_desc=34, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1119 | 5. Tiền đã hoàn vốn cho các chủ sở hữu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=35, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1120 | 6. Tiền lãi đã trả cho các nhà đầu tư vào doanh nghiệp | Tỉ đồng | Cơ sở | data_val WHERE row_desc=36, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1121 | Lưu chuyển tiền thuần từ hoạt động tài chính | Tỉ đồng | Cơ sở | data_val WHERE row_desc=40, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1122 | Lưu chuyển tiền thuần trong kỳ (50 = 20+30+40) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=50, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1123 | Tiền tồn đầu kỳ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=60, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1124 | Tiền tồn cuối kỳ (70 = 50+60) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=70, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |

**Star Schema:** dùng chung `Fact Public Company Financial Report Value` + `Financial Report Catalog Dimension` với Nhóm 7 (không có erDiagram riêng — aggregate 1 CTĐC/kỳ, không group-by, khớp Data Explorer tra cứu chi tiết).

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    fct_pc_fr_val_g25["Fact Public Company Financial Report Value"] --> R25["K_GSDC_1094-1124: DN bảo hiểm — Báo cáo LCTT trực tiếp"]
    financial_rpt_catalog_dim_g25["Financial Report Catalog Dimension"] --> R25
```

**Bảng grain:** như Nhóm 7.

---

#### Nhóm 26 — STT 26: DN bảo hiểm — Báo cáo LCTT gián tiếp

> Phân loại: **Phân tích**
> Filter `Enterprise_Type_Code = 'bh'` (DN bảo hiểm), `Financial_Report_Catalog_Code LIKE 'BCLCTT_GT%'`, `Report_Year = :year AND Report_Quarter = :quarter`, `Column_Description_Reference = '1'` (cuối kỳ).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_1125 | I. Lưu chuyển tiền từ hoạt động kinh doanh | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_1126 | 1. Lợi nhuận trước thuế | Tỉ đồng | Cơ sở | data_val WHERE row_desc=01, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1127 | 2. Điều chỉnh cho các khoản | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_1128 | · Khấu hao TSCĐ và BĐSĐT | Tỉ đồng | Cơ sở | data_val WHERE row_desc=02, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1129 | · Các khoản dự phòng | Tỉ đồng | Cơ sở | data_val WHERE row_desc=03, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1130 | · Lãi, lỗ chênh lệch tỷ giá hối đoái do đánh giá lại các khoản mục tiền tệ có gốc ngoại tệ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=04, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1131 | · Lãi, lỗ từ hoạt động đầu tư | Tỉ đồng | Cơ sở | data_val WHERE row_desc=05, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1132 | · Chi phí lãi vay | Tỉ đồng | Cơ sở | data_val WHERE row_desc=06, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1133 | · Các khoản điều chỉnh khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=07, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1134 | 3. Lợi nhuận từ hoạt động kinh doanh trước thay đổi vốn lưu động | Tỉ đồng | Cơ sở | data_val WHERE row_desc=08, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1135 | · Tăng, giảm các khoản phải thu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=09, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1136 | · Tăng, giảm hàng tồn kho | Tỉ đồng | Cơ sở | data_val WHERE row_desc=10, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1137 | · Tăng, giảm các khoản phải trả (Không kể lãi vay phải trả, thuế thu nhập doanh nghiệp phải nộp) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=11, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1138 | · Tăng, giảm chi phí trả trước | Tỉ đồng | Cơ sở | data_val WHERE row_desc=12, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1139 | · Tăng, giảm chứng khoán kinh doanh | Tỉ đồng | Cơ sở | data_val WHERE row_desc=13, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1140 | · Tiền lãi vay đã trả | Tỉ đồng | Cơ sở | data_val WHERE row_desc=14, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1141 | · Thuế thu nhập doanh nghiệp đã nộp | Tỉ đồng | Cơ sở | data_val WHERE row_desc=15, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1142 | · Tiền thu khác từ hoạt động kinh doanh | Tỉ đồng | Cơ sở | data_val WHERE row_desc=16, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1143 | · Tiền chi khác cho hoạt động kinh doanh | Tỉ đồng | Cơ sở | data_val WHERE row_desc=17, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1144 | Lưu chuyển tiền thuần từ hoạt động kinh doanh | Tỉ đồng | Cơ sở | data_val WHERE row_desc=20, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1145 | II. Lưu chuyển tiền từ hoạt động đầu tư | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_1146 | 1.Tiền chi để mua sắm, xây dựng TSCĐ và các tài sản dài hạn khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=21, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1147 | 2.Tiền thu từ thanh lý, nhượng bán TSCĐ và các tài sản dài hạn khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=22, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1148 | 3.Tiền chi cho vay, mua các công cụ nợ của đơn vị khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=23, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1149 | 4.Tiền thu hồi cho vay, bán lại các công cụ nợ của đơn vị khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=24, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1150 | 5.Tiền chi đầu tư góp vốn vào đơn vị khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=25, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1151 | 6.Tiền thu hồi đầu tư góp vốn vào đơn vị khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=26, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1152 | 7.Tiền thu lãi cho vay, cổ tức và lợi nhuận được chia | Tỉ đồng | Cơ sở | data_val WHERE row_desc=27, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1153 | Lưu chuyển tiền thuần từ hoạt động đầu tư | Tỉ đồng | Cơ sở | data_val WHERE row_desc=30, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1154 | III. Lưu chuyển tiền từ hoạt động tài chính | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_1155 | 1. Tiền thu từ phát hành cổ phiếu, nhận vốn góp của chủ sở hữu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=31, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1156 | 2. Tiền trả lại vốn góp cho các chủ sở hữu, mua lại cổ phiếu của doanh nghiệp đã phát hành | Tỉ đồng | Cơ sở | data_val WHERE row_desc=32, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1157 | 3. Tiền thu từ đi vay | Tỉ đồng | Cơ sở | data_val WHERE row_desc=33, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1158 | 4. Tiền trả nợ gốc vay | Tỉ đồng | Cơ sở | data_val WHERE row_desc=34, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1159 | 5. Tiền trả nợ gốc thuê tài chính | Tỉ đồng | Cơ sở | data_val WHERE row_desc=35, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1160 | 6. Cổ tức, lợi nhuận đã trả cho chủ sở hữu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=36, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1161 | Lưu chuyển tiền thuần từ hoạt động tài chính | Tỉ đồng | Cơ sở | data_val WHERE row_desc=40, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1162 | Lưu chuyển tiền thuần trong kỳ (50 = 20+30+40) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=50, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1163 | Tiền và tương đương tiền đầu kỳ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=60, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1164 | Ảnh hưởng của thay đổi tỷ giá hối đoái quy đổi ngoại tệ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=61, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1165 | Tiền và tương đương tiền cuối kỳ (70 = 50+60+61) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=70, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |

**Star Schema:** dùng chung `Fact Public Company Financial Report Value` + `Financial Report Catalog Dimension` với Nhóm 7 (không có erDiagram riêng — aggregate 1 CTĐC/kỳ, không group-by, khớp Data Explorer tra cứu chi tiết).

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    fct_pc_fr_val_g26["Fact Public Company Financial Report Value"] --> R26["K_GSDC_1125-1165: DN bảo hiểm — Báo cáo LCTT gián tiếp"]
    financial_rpt_catalog_dim_g26["Financial Report Catalog Dimension"] --> R26
```

**Bảng grain:** như Nhóm 7.

---

#### Nhóm 27 — STT 27: TCTD — Bảng cân đối kế toán

> Phân loại: **Phân tích**
> Filter `Enterprise_Type_Code = 'td'` (TCTD), `Financial_Report_Catalog_Code LIKE 'BCDKT%'`, `Report_Year = :year AND Report_Quarter = :quarter`, `Column_Description_Reference = '1'` (cuối kỳ).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_1166 | A. TÀI SẢN | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_1167 | I. Tiền mặt, vàng bạc, đá quý | Tỉ đồng | Cơ sở | data_val WHERE row_desc=110, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1168 | II. Tiền gửi tại NHNN | Tỉ đồng | Cơ sở | data_val WHERE row_desc=120, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1169 | III. Tiền, vàng gửi tại các TCTD khác và cho vay các TCTD khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=130, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1170 | 1. Tiền, vàng gửi tại các TCTD khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=131, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1171 | 2. Cho vay các TCTD khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=132, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1172 | 3. Dự phòng rủi ro cho vay các TCTD khác (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=139, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1173 | IV. Chứng khoán kinh doanh | Tỉ đồng | Cơ sở | data_val WHERE row_desc=140, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1174 | 1. Chứng khoán kinh doanh (1) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=141, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1175 | 2. Dự phòng giảm giá chứng khoán kinh doanh (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=149, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1176 | V. Các công cụ tài chính phái sinh và các tài sản tài chính khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=150, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1177 | VI. Cho vay khách hàng | Tỉ đồng | Cơ sở | data_val WHERE row_desc=160, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1178 | 1. Cho vay khách hàng | Tỉ đồng | Cơ sở | data_val WHERE row_desc=161, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1179 | 2. Dự phòng rủi ro cho vay khách hàng (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=169, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1180 | VII. Hoạt động mua nợ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=180, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1181 | 1. Mua nợ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=181, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1182 | 2. Dự phòng rủi ro hoạt động mua nợ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=189, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1183 | VIII. Chứng khoán đầu tư | Tỉ đồng | Cơ sở | data_val WHERE row_desc=170, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1184 | 1. Chứng khoán đầu tư sẵn sàng để bán (2) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=171, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1185 | 2. Chứng khoán đầu tư giữ đến ngày đáo hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=172, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1186 | 3. Dự phòng giảm giá chứng khoán đầu tư (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=179, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1187 | IX. Góp vốn, đầu tư dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=210, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1188 | 1. Đầu tư vào công ty con | Tỉ đồng | Cơ sở | data_val WHERE row_desc=211, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1189 | 2. Vốn góp liên doanh | Tỉ đồng | Cơ sở | data_val WHERE row_desc=212, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1190 | 3. Đầu tư vào công ty liên kết | Tỉ đồng | Cơ sở | data_val WHERE row_desc=213, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1191 | 4. Đầu tư dài hạn khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=214, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1192 | 5. Dự phòng giảm giá đầu tư dài hạn (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=219, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1193 | X. Tài sản cố định | Tỉ đồng | Cơ sở | data_val WHERE row_desc=220, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1194 | 1. Tài sản cố định hữu hình | Tỉ đồng | Cơ sở | data_val WHERE row_desc=221, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1195 | a. Nguyên giá TSCĐ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=222, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1196 | b. Hao mòn TSCĐ (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=223, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1197 | 2. Tài sản cố định thuê tài chính | Tỉ đồng | Cơ sở | data_val WHERE row_desc=224, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1198 | a. Nguyên giá TSCĐ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=225, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1199 | b. Hao mòn TSCĐ (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=226, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1200 | 3. Tài sản cố định vô hình | Tỉ đồng | Cơ sở | data_val WHERE row_desc=227, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1201 | a. Nguyên giá TSCĐ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=228, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1202 | b. Hao mòn TSCĐ (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=229, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1203 | XI. Bất động sản đầu tư | Tỉ đồng | Cơ sở | data_val WHERE row_desc=240, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1204 | a. Nguyên giá BĐSĐT | Tỉ đồng | Cơ sở | data_val WHERE row_desc=241, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1205 | b. Hao mòn BĐSĐT (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=242, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1206 | XII. Tài sản Có khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=250, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1207 | 1. Các khoản phải thu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=251, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1208 | 2. Các khoản lãi, phí phải thu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=252, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1209 | 3. Tài sản thuế TNDN hoãn lại | Tỉ đồng | Cơ sở | data_val WHERE row_desc=253, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1210 | 4. Tài sản Có khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=254, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1211 | · Trong đó: Lợi thế thương mại | Tỉ đồng | Cơ sở | data_val WHERE row_desc=255, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1212 | 5. Các khoản dự phòng rủi ro cho các tài sản Có nội bảng khác (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=259, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1213 | Tổng tài sản Có | Tỉ đồng | Cơ sở | data_val WHERE row_desc=300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1214 | B. Nợ phải trả và vốn chủ sở hữu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=NV, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1215 | I. Các khoản nợ Chính phủ và NHNN | Tỉ đồng | Cơ sở | data_val WHERE row_desc=310, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1216 | II. Tiền gửi và vay các TCTD khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=320, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1217 | 1. Tiền gửi của các TCTD khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=321, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1218 | 2. Vay các TCTD khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=322, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1219 | III. Tiền gửi của khách hàng | Tỉ đồng | Cơ sở | data_val WHERE row_desc=330, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1220 | IV. Các công cụ tài chính phái sinh và các khoản nợ tài chính khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=340, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1221 | V. Vốn tài trợ, uỷ thác đầu tư, cho vay TCTD chịu rủi ro | Tỉ đồng | Cơ sở | data_val WHERE row_desc=350, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1222 | VI. Phát hành giấy tờ có giá | Tỉ đồng | Cơ sở | data_val WHERE row_desc=360, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1223 | VII. Các khoản nợ khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=370, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1224 | 1. Các khoản lãi, phí phải trả | Tỉ đồng | Cơ sở | data_val WHERE row_desc=371, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1225 | 2. Thuế TNDN hoãn lại phải trả | Tỉ đồng | Cơ sở | data_val WHERE row_desc=372, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1226 | 3. Các khoản phải trả và công nợ khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=373, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1227 | 4. Dự phòng rủi ro khác (Dự phòng cho công nợ tiềm ẩn và cam kết ngoại bảng) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=379, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1228 | Tổng nợ phải trả | Tỉ đồng | Cơ sở | data_val WHERE row_desc=400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1229 | VIII. Vốn và các quỹ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1230 | 1. Vốn của TCTD | Tỉ đồng | Cơ sở | data_val WHERE row_desc=410, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1231 | a. Vốn điều lệ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1232 | b. Vốn đầu tư XDCB | Tỉ đồng | Cơ sở | data_val WHERE row_desc=412, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1233 | c. Thặng dư vốn cổ phần | Tỉ đồng | Cơ sở | data_val WHERE row_desc=413, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1234 | d. Cổ phiếu quỹ (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=414, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1235 | e. Cổ phiếu ưu đãi | Tỉ đồng | Cơ sở | data_val WHERE row_desc=415, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1236 | g. Vốn khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=416, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1237 | 2. Quỹ của TCTD | Tỉ đồng | Cơ sở | data_val WHERE row_desc=420, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1238 | 3. Chênh lệch tỷ giá hối đoái (3) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=430, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1239 | 4. Chênh lệch đánh giá lại tài sản | Tỉ đồng | Cơ sở | data_val WHERE row_desc=440, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1240 | 5. Lợi nhuận chưa phân phối/ Lỗ lũy kế (3) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=450, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1241 | IX. Lợi ích của cổ đông thiểu số | Tỉ đồng | Cơ sở | data_val WHERE row_desc=700, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1242 | Tổng nợ phải trả và vốn chủ sở hữu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=800, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1243 | CÁC CHỈ TIÊU NGOÀI BẢNG | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_1244 | I.Nghĩa vụ nợ tiềm ẩn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=910, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1245 | 1.Bảo lãnh vay vốn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=911, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1246 | 2.Cam kết trong nghiệp vụ L/C | Tỉ đồng | Cơ sở | data_val WHERE row_desc=912, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1247 | 3.Bảo lãnh khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=913, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1248 | II.Các cam kết đưa ra | Tỉ đồng | Cơ sở | data_val WHERE row_desc=920, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1249 | 1.Cam kết tài trợ cho khách hàng | Tỉ đồng | Cơ sở | data_val WHERE row_desc=921, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_1250 | 2.Cam kết khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=922, report=BCDKT, col_desc=1 | fr_value | **READY** |

**Star Schema:** dùng chung `Fact Public Company Financial Report Value` + `Financial Report Catalog Dimension` với Nhóm 7 (không có erDiagram riêng — aggregate 1 CTĐC/kỳ, không group-by, khớp Data Explorer tra cứu chi tiết).

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    fct_pc_fr_val_g27["Fact Public Company Financial Report Value"] --> R27["K_GSDC_1166-1250: TCTD — Bảng cân đối kế toán"]
    financial_rpt_catalog_dim_g27["Financial Report Catalog Dimension"] --> R27
```

**Bảng grain:** như Nhóm 7.

---

#### Nhóm 28 — STT 28: TCTD — Báo cáo KQKD

> Phân loại: **Phân tích**
> Filter `Enterprise_Type_Code = 'td'` (TCTD), `Financial_Report_Catalog_Code LIKE 'BCKQKD%'`, `Report_Year = :year AND Report_Quarter = :quarter`, `Column_Description_Reference = '1'` (cuối kỳ).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_1251 | 1. Thu nhập lãi và các khoản thu nhập tương tự | Tỉ đồng | Cơ sở | data_val WHERE row_desc=01, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1252 | 2. Chi phí lãi và các chi phí tương tự | Tỉ đồng | Cơ sở | data_val WHERE row_desc=02, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1253 | I. Thu nhập lãi thuần | Tỉ đồng | Cơ sở | data_val WHERE row_desc=03, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1254 | 3. Thu nhập từ hoạt động dịch vụ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=04, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1255 | 4. Chi phí hoạt động dịch vụ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=05, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1256 | II. Lãi/ lỗ thuần từ hoạt động dịch vụ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=06, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1257 | III. Lãi/ lỗ thuần từ hoạt động kinh doanh ngoại hối | Tỉ đồng | Cơ sở | data_val WHERE row_desc=07, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1258 | IV. Lãi/ lỗ thuần từ mua bán chứng khoán kinh doanh | Tỉ đồng | Cơ sở | data_val WHERE row_desc=08, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1259 | V. Lãi/ lỗ thuần từ mua bán chứng khoán đầu tư | Tỉ đồng | Cơ sở | data_val WHERE row_desc=09, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1260 | 5. Thu nhập từ hoạt động khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=10, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1261 | 6. Chi phí hoạt động khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=11, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1262 | Vl. Lãi/ lỗ thuần từ hoạt động khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=12, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1263 | VII. Thu nhập từ góp vốn, mua cổ phần | Tỉ đồng | Cơ sở | data_val WHERE row_desc=13, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1264 | VIII. Chi phí hoạt động | Tỉ đồng | Cơ sở | data_val WHERE row_desc=14, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1265 | IX. Lợi nhuận thuần từ hoạt động kinh doanh trước chi phí dự phòng | Tỉ đồng | Cơ sở | data_val WHERE row_desc=15, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1266 | X. Chi phí dự phòng rủi ro tín dụng | Tỉ đồng | Cơ sở | data_val WHERE row_desc=16, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1267 | XI. Tổng lợi nhuận trước thuế | Tỉ đồng | Cơ sở | data_val WHERE row_desc=17, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1268 | 7. Chi phí thuế TNDN hiện hành | Tỉ đồng | Cơ sở | data_val WHERE row_desc=18, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1269 | 8. Chi phí thuế TNDN hoãn lại | Tỉ đồng | Cơ sở | data_val WHERE row_desc=19, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1270 | XII. Chi phí thuế TNDN | Tỉ đồng | Cơ sở | data_val WHERE row_desc=20, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1271 | XIII. Lợi nhuận sau thuế | Tỉ đồng | Cơ sở | data_val WHERE row_desc=21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1272 | XIV. Lợi ích của cổ đông thiểu số | Tỉ đồng | Cơ sở | data_val WHERE row_desc=22, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_1273 | XV. Lãi cơ bản trên cổ phiếu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=23, report=BCKQKD, col_desc=1 | fr_value | **READY** |

**Star Schema:** dùng chung `Fact Public Company Financial Report Value` + `Financial Report Catalog Dimension` với Nhóm 7 (không có erDiagram riêng — aggregate 1 CTĐC/kỳ, không group-by, khớp Data Explorer tra cứu chi tiết).

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    fct_pc_fr_val_g28["Fact Public Company Financial Report Value"] --> R28["K_GSDC_1251-1273: TCTD — Báo cáo KQKD"]
    financial_rpt_catalog_dim_g28["Financial Report Catalog Dimension"] --> R28
```

**Bảng grain:** như Nhóm 7.

---

#### Nhóm 29 — STT 29: TCTD — Báo cáo LCTT trực tiếp

> Phân loại: **Phân tích**
> Filter `Enterprise_Type_Code = 'td'` (TCTD), `Financial_Report_Catalog_Code LIKE 'BCLCTT_TT%'`, `Report_Year = :year AND Report_Quarter = :quarter`, `Column_Description_Reference = '1'` (cuối kỳ).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_1274 | A. Lưu chuyển tiền từ hoạt động kinh doanh | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_1275 | 1. Thu nhập lãi và các khoản thu nhập tương tự nhận được | Tỉ đồng | Cơ sở | data_val WHERE row_desc=01, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1276 | 2. Chi phí lãi và các chi phí tương tự đã trả (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=02, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1277 | 3. Thu nhập từ hoạt động dịch vụ nhận được | Tỉ đồng | Cơ sở | data_val WHERE row_desc=03, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1278 | 4. Chênh lệch số tiền thực thu/thực chi từ hoạt động kinh doanh | Tỉ đồng | Cơ sở | data_val WHERE row_desc=04, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1279 | 5. Thu nhập khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=05, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1280 | 6. Tiền thu các khoản nợ đã được xử lý xoá, bù đắp bằng nguồn rủi ro | Tỉ đồng | Cơ sở | data_val WHERE row_desc=06, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1281 | 7. Tiền chi trả cho nhân viên và hoạt động quản lý, công vụ (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=07, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1282 | 8. Tiền thuế thu nhập thực nộp trong kỳ (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=08, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1283 | B. Lưu chuyển tiền thuần từ hoạt động kinh doanh trước những thay đổi | Tỉ đồng | Cơ sở | data_val WHERE row_desc=09, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1284 | Những thay đổi về tài sản hoạt động | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_1285 | 9. (Tăng)/ Giảm các khoản tiền, vàng gửi và cho vay các TCTD khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=10, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1286 | 10. (Tăng)/ Giảm các khoản về kinh doanh chứng khoán | Tỉ đồng | Cơ sở | data_val WHERE row_desc=11, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1287 | 11. (Tăng)/ Giảm các công cụ tài chính phái sinh và các tài sản tài chính | Tỉ đồng | Cơ sở | data_val WHERE row_desc=12, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1288 | 12. (Tăng)/ Giảm các khoản cho vay khách hàng | Tỉ đồng | Cơ sở | data_val WHERE row_desc=13, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1289 | 13. Giảm nguồn dự phòng để bù đắp tổn thất các khoản | Tỉ đồng | Cơ sở | data_val WHERE row_desc=14, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1290 | 14. (Tăng)/ Giảm khác về tài sản hoạt động | Tỉ đồng | Cơ sở | data_val WHERE row_desc=15, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1291 | Những thay đổi về công nợ hoạt động | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_1292 | 15. Tăng/ (Giảm) các khoản nợ chính phủ và NHNN | Tỉ đồng | Cơ sở | data_val WHERE row_desc=16, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1293 | 16. Tăng/ (Giảm) các khoản tiền gửi, tiền vay các tổ chức tín dụng | Tỉ đồng | Cơ sở | data_val WHERE row_desc=17, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1294 | 17. Tăng/ (Giảm) tiền gửi của khách hàng (bao gồm cả Kho bạc Nhà nước) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=18, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1295 | 18. Tăng/ (Giảm) phát hành giấy tờ có giá (ngoại trừ giấy tờ có giá dài hạn) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=19, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1296 | 19. Tăng/ (Giảm) vốn tài trợ, uỷ thác đầu tư, cho vay mà TCTD chịu rủi ro | Tỉ đồng | Cơ sở | data_val WHERE row_desc=20, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1297 | 20. Tăng/ (Giảm) các công cụ tài chính phái sinh và các khoản nợ tài chính | Tỉ đồng | Cơ sở | data_val WHERE row_desc=21, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1298 | 21. Tăng/ (Giảm) khác về công nợ hoạt động | Tỉ đồng | Cơ sở | data_val WHERE row_desc=22, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1299 | 22. Chi từ các quỹ của TCTD (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=23, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1300 | I. Lưu chuyển tiền thuần từ hoạt động kinh doanh | Tỉ đồng | Cơ sở | data_val WHERE row_desc=24, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1301 | Lưu chuyển tiền từ hoạt động đầu tư | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_1302 | 1. Mua sắm tài sản cố định (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=25, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1303 | 2. Tiền thu từ thanh lý, nhượng bán TSCĐ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=26, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1304 | 3. Tiền chi từ thanh lý, nhượng bán TSCĐ (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=27, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1305 | 4. Mua sắm bất động sản đầu tư (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=28, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1306 | 5. Tiền thu từ bán, thanh lý bất động sản đầu tư | Tỉ đồng | Cơ sở | data_val WHERE row_desc=29, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1307 | 6. Tiền chi ra do bán, thanh lý bất động sản đầu tư (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=30, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1308 | 7. Tiền chi đầu tư, góp vốn vào các đơn vị khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=31, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1309 | 8. Tiền thu đầu tư, góp vốn vào các đơn vị khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=32, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1310 | 9. Tiền thu cổ tức và lợi nhuận được chia từ các khoản đầu tư, góp vốn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=33, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1311 | II. Lưu chuyển tiền thuần từ hoạt động đầu tư | Tỉ đồng | Cơ sở | data_val WHERE row_desc=34, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1312 | Lưu chuyển tiền từ hoạt động tài chính | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_1313 | 1. Tăng vốn cổ phần từ góp vốn và/hoặc phát hành cổ phiếu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=35, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1314 | 2. Tiền thu từ phát hành giấy tờ có giá dài hạn có đủ điều kiện tính vào vốn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=36, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1315 | 3. Tiền chi thanh toán giấy tờ có giá dài hạn có đủ điều kiện tính vào vốn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=37, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1316 | 4. Cổ tức trả cho cổ đông, lợi nhuận đã chia (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=38, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1317 | 5. Tiền chi ra mua cổ phiếu ngân quỹ (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=39, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1318 | 6. Tiền thu được do bán cổ phiếu ngân quỹ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=40, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1319 | III. Lưu chuyển tiền thuần từ hoạt động tài chính | Tỉ đồng | Cơ sở | data_val WHERE row_desc=41, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1320 | IV. Lưu chuyển tiền thuần trong kỳ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=42, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1321 | V. Tiền và các khoản tương đương tiền tại thời điểm đầu kỳ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=43, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1322 | VI. Điều chỉnh ảnh hưởng của thay đổi tỷ giá | Tỉ đồng | Cơ sở | data_val WHERE row_desc=44, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1323 | VII. Tiền và các khoản tương đương tiền tại thời điểm cuối kỳ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=45, report=BCLCTT (trực tiếp), col_desc=1 | fr_value | **READY** |

**Star Schema:** dùng chung `Fact Public Company Financial Report Value` + `Financial Report Catalog Dimension` với Nhóm 7 (không có erDiagram riêng — aggregate 1 CTĐC/kỳ, không group-by, khớp Data Explorer tra cứu chi tiết).

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    fct_pc_fr_val_g29["Fact Public Company Financial Report Value"] --> R29["K_GSDC_1274-1323: TCTD — Báo cáo LCTT trực tiếp"]
    financial_rpt_catalog_dim_g29["Financial Report Catalog Dimension"] --> R29
```

**Bảng grain:** như Nhóm 7.

---

#### Nhóm 30 — STT 30: TCTD — Báo cáo LCTT gián tiếp

> Phân loại: **Phân tích**
> Filter `Enterprise_Type_Code = 'td'` (TCTD), `Financial_Report_Catalog_Code LIKE 'BCLCTT_GT%'`, `Report_Year = :year AND Report_Quarter = :quarter`, `Column_Description_Reference = '1'` (cuối kỳ).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_1324 | Lưu chuyển tiền từ hoạt động kinh doanh | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_1325 | Lợi nhuận trước thuế | Tỉ đồng | Cơ sở | data_val WHERE row_desc=01, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1326 | Điều chỉnh cho các khoản: | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_1327 | 2. Khấu hao TSCĐ, bất động sản đầu tư | Tỉ đồng | Cơ sở | data_val WHERE row_desc=02, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1328 | 3. Dự phòng rủi ro tín dụng, giảm giá, đầu tư tăng thêm/ (hoàn nhập) trong kỳ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=03, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1329 | 4. Lãi và phí phải thu trong kỳ (thực tế chưa thu) (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=04, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1330 | 5. Lãi và phí phải trả trong kỳ (thực tế chưa trả) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=05, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1331 | 6. (Lãi)/ lỗ do thanh lý TSCĐ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=06, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1332 | 7. (Lãi)/ lỗ do bán, thanh lý bất động sản đầu tư | Tỉ đồng | Cơ sở | data_val WHERE row_desc=07, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1333 | 8. (Lãi)/ lỗ do thanh lý những khoản đầu tư, góp vốn dài hạn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=08, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1334 | 9. Chênh lệch tỷ giá hối đoái chưa thực hiện | Tỉ đồng | Cơ sở | data_val WHERE row_desc=09, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1335 | 10. Các điều chỉnh khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=10, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1336 | Những thay đổi về tài sản và công nợ hoạt động | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_1337 | Những thay đổi về tài sản hoạt động | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_1338 | 11. (Tăng)/ Giảm các khoản tiền, vàng gửi và cho vay các TCTD | Tỉ đồng | Cơ sở | data_val WHERE row_desc=11, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1339 | 12. (Tăng)/ Giảm các khoản về kinh doanh chứng khoán | Tỉ đồng | Cơ sở | data_val WHERE row_desc=12, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1340 | 13. (Tăng)/ Giảm các công cụ tài chính phái sinh và các tài sản tài chính | Tỉ đồng | Cơ sở | data_val WHERE row_desc=13, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1341 | 14. (Tăng)/ Giảm các khoản cho vay khách hàng | Tỉ đồng | Cơ sở | data_val WHERE row_desc=14, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1342 | 15. (Tăng)/ Giảm lãi, phí phải thu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=15, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1343 | 16. (Giảm)/ Tăng nguồn dự phòng để bù đắp tổn thất các khoản | Tỉ đồng | Cơ sở | data_val WHERE row_desc=16, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1344 | 17. (Tăng)/ Giảm khác về tài sản hoạt động | Tỉ đồng | Cơ sở | data_val WHERE row_desc=17, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1345 | Những thay đổi về công nợ hoạt động | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_1346 | 18. Tăng/ (Giảm) các khoản nợ chính phủ và NHNN | Tỉ đồng | Cơ sở | data_val WHERE row_desc=18, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1347 | 19. Tăng/ (Giảm) các khoản tiền gửi và vay các TCTD | Tỉ đồng | Cơ sở | data_val WHERE row_desc=19, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1348 | 20. Tăng/ (Giảm) tiền gửi của khách hàng (bao gồm cả Kho bạc Nhà nước) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=20, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1349 | 21. Tăng/ (Giảm) các công cụ TC phái sinh và các khoản nợ tài chính khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=21, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1350 | 22. Tăng/ (Giảm) vốn tài trợ, uỷ thác đầu tư, cho vay mà TCTD phải chịu rủi ro | Tỉ đồng | Cơ sở | data_val WHERE row_desc=22, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1351 | 23. Tăng/ (Giảm) phát hành giấy tờ có giá (ngoại trừ GTCG được tính vào vốn) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=23, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1352 | 24. Tăng/ (Giảm) lãi, phí phải trả | Tỉ đồng | Cơ sở | data_val WHERE row_desc=24, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1353 | 25. Tăng/(Giảm) khác về công nợ hoạt động | Tỉ đồng | Cơ sở | data_val WHERE row_desc=25, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1354 | Lưu chuyển tiền thuần từ hoạt động kinh doanh trước thuế thu nhập | Tỉ đồng | Cơ sở | data_val WHERE row_desc=26, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1355 | 26. Thuế TNDN đã nộp (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=27, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1356 | 27. Chi từ các quỹ của TCTD (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=28, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1357 | I. Lưu chuyển tiền thuần từ hoạt động kinh doanh | Tỉ đồng | Cơ sở | data_val WHERE row_desc=29, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1358 | Lưu chuyển tiền từ hoạt động đầu tư | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_1359 | 1. Mua sắm TSCĐ (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=30, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1360 | 2. Tiền thu từ thanh lý, nhượng bán TSCĐ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=31, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1361 | 3. Tiền chi từ thanh lý, nhượng bán TSCĐ (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=32, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1362 | 4. Mua sắm bất động sản đầu tư (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=33, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1363 | 5. Tiền thu từ bán, thanh lý bất động sản đầu tư | Tỉ đồng | Cơ sở | data_val WHERE row_desc=34, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1364 | 6. Tiền chi ra do bán, thanh lý bất động sản đầu tư (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=35, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1365 | 7. Tiền chi đầu tư, góp vốn vào các đơn vị khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=36, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1366 | 8. Tiền thu đầu tư, góp vốn vào các đơn vị khác | Tỉ đồng | Cơ sở | data_val WHERE row_desc=37, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1367 | 9. Tiền thu cổ tức và lợi nhuận được chia từ các khoản đầu tư, góp vốn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=38, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1368 | II. Lưu chuyển từ hoạt động đầu tư | Tỉ đồng | Cơ sở | data_val WHERE row_desc=39, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1369 | Lưu chuyển tiền từ hoạt động tài chính | | N/A | — | Section label — không có logic tính toán | READY |
| K_GSDC_1370 | 1. Tăng vốn cổ phần từ góp vốn và/ hoặc phát hành cổ phiếu | Tỉ đồng | Cơ sở | data_val WHERE row_desc=40, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1371 | 2. Tiền thu từ phát hành giấy tờ có giá dài hạn đủ điều kiện tính vào vốn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=41, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1372 | 3. Tiền chi thanh toán giấy tờ có giá dài hạn đủ điều kiện tính vào vốn | Tỉ đồng | Cơ sở | data_val WHERE row_desc=42, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1373 | 4. Cổ tức trả cho cổ đông, lợi nhuận đã chia (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=43, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1374 | 5. Tiền chi ra mua cổ phiếu quỹ (*) | Tỉ đồng | Cơ sở | data_val WHERE row_desc=44, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1375 | 6. Tiền thu được do bán cổ phiếu quỹ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=45, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1376 | III. Lưu chuyển tiền từ hoạt động tài chính | Tỉ đồng | Cơ sở | data_val WHERE row_desc=46, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1377 | IV. Lưu chuyển tiền thuần trong kỳ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=47, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1378 | V. Tiền và các khoản tương đương tiền tại thời điểm đầu kỳ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=48, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1379 | VI. Điều chỉnh ảnh hưởng của thay đổi tỷ giá | Tỉ đồng | Cơ sở | data_val WHERE row_desc=49, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |
| K_GSDC_1380 | VII. Tiền và các khoản tương đương tiền tại thời điểm cuối kỳ | Tỉ đồng | Cơ sở | data_val WHERE row_desc=50, report=BCLCTT (gián tiếp), col_desc=1 | fr_value | **READY** |

**Star Schema:** dùng chung `Fact Public Company Financial Report Value` + `Financial Report Catalog Dimension` với Nhóm 7 (không có erDiagram riêng — aggregate 1 CTĐC/kỳ, không group-by, khớp Data Explorer tra cứu chi tiết).

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    fct_pc_fr_val_g30["Fact Public Company Financial Report Value"] --> R30["K_GSDC_1324-1380: TCTD — Báo cáo LCTT gián tiếp"]
    financial_rpt_catalog_dim_g30["Financial Report Catalog Dimension"] --> R30
```

**Bảng grain:** như Nhóm 7.

---

#### Nhóm 31 — STT 31: Dữ liệu về thông tin niêm yết

> **Rà soát 2026-07-16:** BA ghi Nguồn = "MSS, IDS" (không thuần MSS) và `Loại dữ liệu` phân biệt rõ 2 nhóm: 8 KPI đầu = "Dữ liệu tĩnh - **Chưa có CSDL**" (nguồn là biểu mẫu báo cáo thủ công theo Thông tư 138/2025/TT-BTC hoặc biểu mẫu Ban phát triển thị trường — chưa số hoá thành bảng CSDL); 2 KPI cuối (K_GSDC_1389, K_GSDC_1390) = "Dữ liệu tĩnh" (không có "chưa có CSDL") — BA ghi rõ Bảng nguồn = `state_capital`, Trường nguồn = `owned_share_qty`/`ownership_ratio`, filter `NVL(update_dated, created_date) < cuối tháng` (note: "VSDC ko có, lấy từ IDS"). Khớp Atomic entity `Public Company State Capital` (`pc_state_capital`, từ `lld_IDS_STATE_CAPITAL.yaml`) cho phần business column (`owned_share_quantity`/`ownership_ratio_percentage`).
> **Gap Atomic K_GSDC_1389/1390 (rà soát LLD 2026-07-16):** Entity `pc_state_capital` hiện **không có audit fields** (`created_date`/`update_dated`) — chỉ có business columns, không có timestamp nào để lọc theo tháng như BA yêu cầu (`NVL(update_dated, created_date) < cuối tháng`). Không thể thiết kế Fact snapshot đúng grain "1 row / CTDC / tháng" nếu thiếu cột này. **Giữ PENDING**, khác gap loại của 8 KPI kia (thiếu hẳn bảng nguồn) — 2 KPI này chỉ thiếu 2 audit field trên 1 entity đã tồn tại. Cần bổ sung `created_date`/`update_dated` vào `pc_state_capital` qua `atomic-lld-design` trước khi Datamart có thể thiết kế Attributes.

**KPI liên quan:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_1381 | Khối lượng cổ phiếu đang lưu hành | | Base | (chưa xác định — xem Atomic cần bổ sung) |  | Pending - chưa có CSDL (biểu mẫu TT138/2025) |
| K_GSDC_1382 | Khối lượng cổ phiếu niêm yết | | Base | (chưa xác định — xem Atomic cần bổ sung) |  | Pending - chưa có CSDL (biểu mẫu TT138/2025) |
| K_GSDC_1383 | Khối lượng cổ phiếu quỹ | | Base | (chưa xác định — xem Atomic cần bổ sung) |  | Pending - chưa có CSDL (biểu mẫu TT138/2025) |
| K_GSDC_1384 | Khối lượng cổ phiếu tự do chuyển nhượng (Free Float) | | Base | (chưa xác định — xem Atomic cần bổ sung) |  | Pending - chưa có CSDL (biểu mẫu TT138/2025) |
| K_GSDC_1385 | Khối lượng cổ phiếu khối ngoại sở hữu | | Base | (chưa xác định — xem Atomic cần bổ sung) |  | Pending - chưa có CSDL (biểu mẫu Ban PTTT) |
| K_GSDC_1386 | Tỷ lệ sở hữu nước ngoài hiện tại | | Base | (chưa xác định — xem Atomic cần bổ sung) |  | Pending - chưa có CSDL (biểu mẫu Ban PTTT) |
| K_GSDC_1387 | Tỷ lệ sở hữu nước ngoài tối đa (Foreign Ownership Limit – FOL) | | Base | (chưa xác định — xem Atomic cần bổ sung) |  | Pending - chưa có CSDL (biểu mẫu Ban PTTT) |
| K_GSDC_1388 | Room ngoại còn lại | | Base | (chưa xác định — xem Atomic cần bổ sung) |  | Pending - chưa có CSDL (biểu mẫu Ban PTTT) |
| K_GSDC_1389 | Khối lượng cổ phiếu sở hữu nhà nước | | Base | owned_share_quantity (trực tiếp) | Public Company State Capital | **PENDING** — thiếu audit field `created_date`/`update_dated` để lọc theo tháng |
| K_GSDC_1390 | Tỷ lệ sở hữu nhà nước | | Base | ownership_ratio_percentage (trực tiếp) | Public Company State Capital | **PENDING** — thiếu audit field `created_date`/`update_dated` để lọc theo tháng |

**Lý do PENDING (8 KPI đầu):** Nguồn là biểu mẫu báo cáo thủ công (Thông tư 138/2025/TT-BTC, biểu mẫu Ban phát triển thị trường) — chưa số hoá thành bảng CSDL, cần thiết kế Atomic mới.

**Lý do PENDING (K_GSDC_1389/1390):** Atomic entity `pc_state_capital` đã có business columns cần thiết nhưng thiếu audit fields (`created_date`/`update_dated`) để dựng snapshot theo tháng — cần bổ sung 2 field này vào Atomic LLD trước.

**Atomic cần bổ sung:**
- 8 KPI đầu: Entity lưu thông tin khối lượng chứng khoán lưu hành/niêm yết (từ MSS) và thông tin sở hữu nước ngoài (từ Ban phát triển thị trường).
- K_GSDC_1389/1390: bổ sung `created_date`/`update_dated` vào `pc_state_capital` (`lld_IDS_STATE_CAPITAL.yaml`).

**Mart dự kiến:** `Fact Public Company Listing Info Snapshot` (grain: 1 row / CTDC / tháng) — toàn bộ 10 KPI PENDING, chờ Atomic bổ sung tương ứng.

---

#### Nhóm 32 — STT 32: Dữ liệu tổng hợp chấm điểm phân loại CTDC (Data Explorer)

> Phân loại: **Phân tích**
> 8/8 dòng `Trạng thái mapping = Done`, `Loại dữ liệu = Dữ liệu tĩnh`. Khớp đúng cấu trúc Nhóm 1 (K_GSDC_1397, K_GSDC_1398, K_GSDC_1391–1396). Cùng điều kiện go-live: Atomic Evaluation entity `design_status: draft`, chưa approved — xem O_GSDC_1.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_1391 | Tuân thủ | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1392 | Phát hành | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1393 | Tài chính | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1394 | Phi tài chính & M-Score | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1395 | Xếp hạng tín nhiệm DN | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1396 | Điểm tổng hợp | Điểm | Base | total_score_percentage (trực tiếp) | —| READY |
| K_GSDC_1397 | Mã CK doanh nghiệp | Text | Chiều | equity_ticker_symbol (trực tiếp) | —| READY |
| K_GSDC_1398 | Tên doanh nghiệp | Text | Chiều | pc_nm (trực tiếp) | —| READY |

**Star Schema, Lineage, Bảng grain:** giống Nhóm 1.

**Mart:** `Fact Public Company Risk Score Snapshot` (grain: 1 row / CTDC / ngày snapshot ETL — full-scan daily, carry-forward từ kỳ đánh giá gần nhất)

---

#### Nhóm 33 — STT 33: Phân loại CTDC theo chỉ tiêu tuân thủ (Data Explorer)

> Phân loại: **Phân tích**
> 17/17 dòng `Trạng thái mapping = Done`, `Loại dữ liệu = Dữ liệu tĩnh` — 15 chỉ tiêu Base (gồm "Vi phạm" tách K_GSDC_1405+14) + Tổng điểm = 16, +2 Mã/Tên DN = 17 hàng.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_1399 | Mã CK doanh nghiệp | Text | Chiều | equity_ticker_symbol (trực tiếp) | —| READY |
| K_GSDC_1400 | Tên doanh nghiệp | Text | Chiều | pc_nm (trực tiếp) | —| READY |
| K_GSDC_1401 | Công bố BCTC | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1402 | Công bố BCTN | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1403 | Công bố báo cáo tình hình quản trị | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1404 | Công bố thông tin Thay đổi TGĐ/CTHĐQT | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1405 | Vi phạm từ UBCKNN | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1406 | Vi phạm từ các đơn vị khác | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1407 | Điều lệ Công ty và Các Quy chế hoạt động | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1408 | Số lượng ĐHĐCĐ thường niên trong 6 tháng đầu năm | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1409 | Số lượng thành viên HĐQT độc lập | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1410 | Số lượng thành viên HĐQT không điều hành | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1411 | Tư cách thành viên HĐQT/BKS/Kế toán trưởng | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1412 | Số lượng thành viên BKS hoặc Ủy ban kiểm toán | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1413 | Báo cáo tiến độ sử dụng vốn | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1414 | Thay đổi phương án sử dụng vốn | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1415 | Tổng điểm Tuân thủ | Điểm | Phái sinh | evaluation_score (trực tiếp) | SUM(evaluation_score)| READY |

**Star Schema, Lineage, Bảng grain:** tương tự Nhóm 1 (cùng pattern `Fact_..._Score_Snapshot`), Fact riêng `Fact Public Company Compliance Score Snapshot` — grain: 1 row / CTDC / ngày snapshot ETL (full-scan daily, carry-forward).

**Mart:** `Fact Public Company Compliance Score Snapshot` (grain: 1 row / CTDC / ngày snapshot ETL — full-scan daily, carry-forward)

---

#### Nhóm 34 — STT 34: Phân loại CTDC theo chỉ tiêu tài chính (Data Explorer)

> Phân loại: **Phân tích**
> 13/13 dòng `Trạng thái mapping = Done`, `Loại dữ liệu = Dữ liệu tĩnh` — 10 chỉ tiêu Base (bao gồm K_GSDC_1424 "VCSH") + Tổng điểm = 11, +2 Mã/Tên DN = 13 hàng.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_1416 | Mã CK doanh nghiệp | Text | Chiều | equity_ticker_symbol (trực tiếp) | —| READY |
| K_GSDC_1417 | Tên doanh nghiệp | Text | Chiều | pc_nm (trực tiếp) | —| READY |
| K_GSDC_1418 | Kiểm toán — Ý kiến kiểm toán | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1419 | ROA | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1420 | Dòng tiền từ hoạt động kinh doanh | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1421 | Khả năng thanh toán hiện thời | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1422 | EBIT / Lãi vay | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1423 | Nợ / VCSH | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1424 | VCSH | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1425 | ROE | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1426 | Doanh thu từ HĐ tài chính / Lợi nhuận sau thuế | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1427 | Doanh thu từ hoạt động khác / Lợi nhuận sau thuế | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1428 | Tổng điểm Tài chính | Điểm | Phái sinh | evaluation_score (trực tiếp) | SUM(evaluation_score)| READY |

**Star Schema, Lineage, Bảng grain:** tương tự Nhóm 1 (cùng pattern `Fact_..._Score_Snapshot`), Fact riêng `Fact Public Company Financial Score Snapshot` — grain: 1 row / CTDC / ngày snapshot ETL (full-scan daily, carry-forward).

**Mart:** `Fact Public Company Financial Score Snapshot` (grain: 1 row / CTDC / ngày snapshot ETL — full-scan daily, carry-forward)

---

#### Nhóm 35 — STT 35: Phân loại CTDC theo chỉ tiêu phát hành (Data Explorer)

> Phân loại: **Phân tích**
> 10/10 dòng `Trạng thái mapping = Done`, `Loại dữ liệu = Dữ liệu tĩnh` — 7 chỉ tiêu Base + Tổng điểm = 8, +2 Mã/Tên DN = 10 hàng.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_1429 | Mã doanh nghiệp | Text | Chiều | equity_ticker_symbol (trực tiếp) | —| READY |
| K_GSDC_1430 | Tên doanh nghiệp | Text | Chiều | pc_nm (trực tiếp) | —| READY |
| K_GSDC_1431 | Phát hành tăng vốn nhanh | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1432 | Số lần chào bán cổ phiếu riêng lẻ | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1433 | Số lần chào bán ra công chúng | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1434 | Số lần phát hành ESOP | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1435 | Tỷ lệ phát hành trái phiếu không có TSBĐ | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1436 | Xếp hạng tín nhiệm | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1437 | Dư nợ trái phiếu / Tổng VCSH | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1438 | Tổng điểm Phát hành | Điểm | Phái sinh | evaluation_score (trực tiếp) | SUM(evaluation_score)| READY |

**Star Schema, Lineage, Bảng grain:** tương tự Nhóm 1 (cùng pattern `Fact_..._Score_Snapshot`), Fact riêng `Fact Public Company Issuance Score Snapshot` — grain: 1 row / CTDC / ngày snapshot ETL (full-scan daily, carry-forward).

**Mart:** `Fact Public Company Issuance Score Snapshot` (grain: 1 row / CTDC / ngày snapshot ETL — full-scan daily, carry-forward)

---

#### Nhóm 36 — STT 36: Phân loại CTDC theo chỉ tiêu phi tài chính (Data Explorer)

> Phân loại: **Phân tích**
> 5/5 dòng `Trạng thái mapping = Done`, `Loại dữ liệu = Dữ liệu tĩnh` — 2 chỉ tiêu Base + Tổng điểm = 3, +2 Mã/Tên DN = 5 hàng.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_1439 | Mã doanh nghiệp | Text | Chiều | equity_ticker_symbol (trực tiếp) | —| READY |
| K_GSDC_1440 | Tên doanh nghiệp | Text | Chiều | pc_nm (trực tiếp) | —| READY |
| K_GSDC_1441 | Tình trạng DN từ Cục Đăng ký kinh doanh | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1442 | M-Score | Điểm | Base | evaluation_score (trực tiếp) | —| READY |
| K_GSDC_1443 | Tổng điểm Phi tài chính & M-Score | Điểm | Phái sinh | evaluation_score (trực tiếp) | SUM(evaluation_score)| READY |

**Star Schema, Lineage, Bảng grain:** tương tự Nhóm 1 (cùng pattern `Fact_..._Score_Snapshot`), Fact riêng `Fact Public Company Non-Financial Score Snapshot` — grain: 1 row / CTDC / ngày snapshot ETL (full-scan daily, carry-forward).

**Mart:** `Fact Public Company Non-Financial Score Snapshot` (grain: 1 row / CTDC / ngày snapshot ETL — full-scan daily, carry-forward)

---

#### Nhóm 37 — STT 37: Hệ số tài chính cơ bản

> Phân loại: **Phân tích**
> Toàn bộ KPI ID K_GSDC_1444–1456 dùng chung `Fact Public Company Financial Report Value` + `Financial Report Catalog Dimension` (xem Fact/Dimension gốc ở Nhóm 7), không filter/breakdown bổ sung nào khác — **READY**.

**KPI liên quan:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_1444 | Tổng tài sản | | Cơ sở | SUM(data_val) WHERE row_desc='270', col_desc='1' (Tổng tài sản) | —| **READY** |
| K_GSDC_1445 | Nợ phải trả | | Cơ sở | SUM(data_val) WHERE row_desc='300', col_desc='1' (Nợ phải trả) | —| **READY** |
| K_GSDC_1446 | Vốn CSH | | Cơ sở | SUM(data_val) WHERE row_desc='400', col_desc='1' (Vốn CSH) | —| **READY** |
| K_GSDC_1447 | Vốn điều lệ | | Cơ sở | SUM(data_val) WHERE row_desc='411', col_desc='1' (Vốn điều lệ) | —| **READY** |
| K_GSDC_1448 | Lợi nhuận sau thuế | | Cơ sở | SUM(data_val) WHERE row_desc='60', col_desc='1' (LNST) | —| **READY** |
| K_GSDC_1454 | ROA | | Phái sinh | SUM(data_val, row 60 LNST) / NULLIF(AVG(data_val, row 270 TSBQ đầu+cuối kỳ), 0) * 100 | —| **READY** |
| K_GSDC_1455 | ROE | | Phái sinh | SUM(data_val, row 60 LNST) / NULLIF(AVG(data_val, row 400 VCSHBQ đầu+cuối kỳ), 0) * 100 | —| **READY** |
| K_GSDC_1449 | Hàng tồn kho | | Cơ sở | SUM(data_val) WHERE row_desc='140', col_desc='1' (Hàng tồn kho) | —| **READY** |
| K_GSDC_1450 | Doanh thu thuần | | Cơ sở | SUM(data_val) WHERE row_desc='10', col_desc='1' (Doanh thu thuần) | —| **READY** |
| K_GSDC_1451 | Lợi nhuận dồn tích YTD | | Cơ sở | SUM(data_val) WHERE row_desc='421' (dn/bh), col_desc='1' (LN dồn tích YTD) | td không có trong BA SQL (giống K_GSDC_59 Nhóm 7) | **READY** |
| K_GSDC_1452 | Phải thu | | Cơ sở | SUM(data_val) WHERE row_desc='130+210', col_desc='1' (Phải thu) | —| **READY** |
| K_GSDC_1453 | Tiền và tương đương tiền | | Cơ sở | SUM(data_val) WHERE row_desc='110', col_desc='1' (Tiền và tương đương tiền) | —| **READY** |
| K_GSDC_1456 | Nợ / Vốn CSH | | Phái sinh | SUM(data_val, row 300 Nợ) / NULLIF(SUM(data_val, row 400 VCSH), 0) | —| **READY** |

**Star Schema, Lineage, Bảng grain:** dùng chung `Fact Public Company Financial Report Value` + `Financial Report Catalog Dimension` như Nhóm 7, không filter bổ sung.

---

### Màn hình 4 — Báo cáo giám sát CTDC

#### Nhóm 38 — STT 38: BC01.1 — Báo cáo vĩ mô theo sàn

> Phân loại: **Phân tích**
> Source: `Public Company Regulatory Compliance Report` (`public_company_regulatory_compliance_rpt`) — Fact-report denormalize hoàn toàn, không qua Dimension/Fact trung gian nào khi xem báo cáo.
> Đây là báo cáo BC01.1 cố định theo kỳ (`:p_year`/`:p_quarter`), SQL BA aggregate trực tiếp ra 1 dòng kết quả/sàn (không cần giữ current-state theo công ty) — đúng tiêu chí Fact-report (`naming_conventions.md`: "báo cáo đóng gói cố định theo kỳ — ETL append-only theo Report Date, không SCD4A, thường denormalize hoàn toàn"). Denormalize toàn bộ 9 measure vào 1 bảng phẳng `Public Company Regulatory Compliance Report`, ETL populate theo batch mỗi kỳ (Report_Year + Report_Quarter), không có FK Dimension — `Equity_Listing_Exchange_Code` lưu trực tiếp dạng text (denormalize từ `IDS_LISTING_TYPE`).
> Atomic nguồn (dùng ở tầng ETL populate report, không phải FK runtime): `Public Company` (`public_company`) cho Số DN đăng ký; `Public Company Report Submission` (`pc_report_submission`, approved) cho Số BCTC đến hạn/đã nộp; `Financial Report Value` (`fr_value`) cho Số CTĐC báo lãi.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_700 | Sàn NY/ĐKGD | Text | Chiều (Group By) | equity_listing_exchange_code (trực tiếp) | Denormalize trực tiếp vào cột report — không FK Dimension | READY |
| K_GSDC_701 | Số lượng DN | DN | Phái sinh | ids_registration_dt (trực tiếp) | COUNT DISTINCT WHERE ids_registration_dt <= cuối kỳ GROUP BY sàn — xem O_GSDC_2 | READY |
| K_GSDC_702 | Số lượng BCTC đến hạn nộp | DN | Cơ sở | submission_deadline_dt (trực tiếp) | COUNT(*) WHERE rpt_year/rpt_quarter=kỳ AND submission_deadline_dt <= SYSDATE GROUP BY sàn | READY |
| K_GSDC_703 | Số báo cáo (BCTC) đã nộp | DN | Cơ sở | submission_dt (trực tiếp) | COUNT(CASE WHEN submission_dt IS NOT NULL AND submission_dt <= submission_deadline_dt) cùng điều kiện K_GSDC_702 | READY |
| K_GSDC_704 | Tỷ lệ nộp BCTC (%) | % | Phái sinh | — (trực tiếp) | Phái sinh = K_GSDC_703 / K_GSDC_702 × 100 | READY |
| K_GSDC_705 | Số CTDC báo lãi Năm N | DN | Cơ sở | READY (trực tiếp) | GROUP BY sàn (join `company_profiles`) | READY |
| K_GSDC_706 | Tỷ lệ DN báo lãi Năm N (%) | % | Phái sinh | — (trực tiếp) | Phái sinh = K_GSDC_705 / K_GSDC_701 × 100 | READY |
| K_GSDC_707 | Số CTDC báo lãi Năm N-1 | DN | Cơ sở | READY (trực tiếp) | Cùng công thức K_GSDC_705, đổi `rpt_year = :year - 1` | READY |
| K_GSDC_708 | Tỷ lệ DN báo lãi Năm N-1 (%) | % | Phái sinh | — (trực tiếp) | Phái sinh = K_GSDC_707 / K_GSDC_701 (kỳ N-1) × 100 | READY |

**Star Schema:**

```mermaid
erDiagram
    Public_Company_Regulatory_Compliance_Report {
        string Equity_Listing_Exchange_Code PK
        int Report_Year PK
        int Report_Quarter PK
        int Company_Count
        int Report_Due_Count
        int Report_Submitted_Count
        int Profitable_Company_Count_Year_N
        int Profitable_Company_Count_Year_N1
        string Source_System_Code
    }
```

> **Ghi chú thiết kế:** Bảng report này KHÔNG có FK Dimension — đúng đặc tính Fact-report (đóng gói cố định theo kỳ, denormalize hoàn toàn). `Equity_Listing_Exchange_Code` lưu trực tiếp dạng text. Tỷ lệ (K_GSDC_704/706/708) tính ở tầng Detail Mapping từ 4 measure gốc, không lưu cột riêng trên report. `Source_System_Code` giữ theo quy ước chung (dù không phải Dimension/Operational, vẫn cần để trace nguồn ETL populate — hardcode 'IDS').

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    public_company_regulatory_compliance_rpt_g38["Public Company Regulatory Compliance Report"] --> R38["K_GSDC_700-708: BC01.1 — Báo cáo vĩ mô theo sàn"]
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Public Company Regulatory Compliance Report | 1 row / sàn NY-ĐKGD / kỳ (Report_Year + Report_Quarter) |

---

#### Nhóm 39 — STT 39: BC01.2 — Báo cáo vĩ mô theo ngành

> Phân loại: **Phân tích**
> Source: `Public Company Industry Financial Report` (`public_company_industry_financial_rpt`) — Fact-report denormalize hoàn toàn.
> Field group-by-ngành: đúng tên `Business Line Level 1 Code` (`business_line_level_1_code`), không phải `Industry Category Level1 Code`/`idy_cgy_level1_code`.
> Đây là 1 câu SQL duy nhất (CTE `kqkd`) aggregate trực tiếp `SUM(data_val)`/`AVG` ra kết quả DTT/LNST/ROA/ROE theo ngành, kỳ NĂM (`report_quarter IS NULL`), tính đồng thời Năm N và N-1 bằng `CASE WHEN` trong cùng query — đúng tiêu chí Fact-report (báo cáo cố định theo kỳ, không cần giữ current-state theo từng công ty). Denormalize 8 measure (DTT/LNST/ROA/ROE × N/N-1) vào 1 bảng phẳng `Public Company Industry Financial Report`, ETL populate theo batch mỗi năm báo cáo, không FK Dimension — `Business_Line_Level_1_Code` lưu trực tiếp dạng text.
> Atomic nguồn (dùng ở tầng ETL populate report): `Financial Report Value` (`fr_value`) JOIN `Public Company` (lấy ngành) + `Financial Report Catalog`/`Row Template`/`Column Template` (xác định row/col code).

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_709 | Ngành kinh tế | Text | Chiều (Group By) | business_line_level_1_code (xem KPI liên quan cùng công thức) | public_company | **READY** |
| K_GSDC_710 | DTT Năm N | Tỉ đồng | Cơ sở | data_val WHERE row_desc=10/10/03, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_711 | LNST Năm N | Tỉ đồng | Cơ sở | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_712 | ROA Năm N | % | Phái sinh | data_val WHERE row_desc=270/270/300 (TSBQ) + 60/60/21 (LNST), report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_713 | ROE Năm N | % | Phái sinh | data_val WHERE row_desc=400/400/500 (VCSHBQ) + 60/60/21 (LNST), report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_714 | DTT Năm N-1 | Tỉ đồng | Cơ sở | data_val WHERE row_desc=10/10/03, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_715 | LNST Năm N-1 | Tỉ đồng | Cơ sở | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_716 | ROA Năm N-1 | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_712, `report_year = :year_n - 1`), report=—, col_desc=— | fr_value | **READY** |
| K_GSDC_717 | ROE Năm N-1 | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_713, `report_year = :year_n - 1`), report=—, col_desc=— | fr_value | **READY** |

> **Ghi chú kỳ:** Toàn bộ measure Nhóm 39 filter `Report_Quarter IS NULL AND Report_Year IN (:year_n, :year_n - 1)` — báo cáo kỳ NĂM. Năm N/N-1 denormalize thành 2 cột riêng trên cùng 1 row report (không phải 2 row), khớp đúng pattern SQL BA (`CASE WHEN Report_Year = ...` trong 1 query).

**Star Schema:**

```mermaid
erDiagram
    Public_Company_Industry_Financial_Report {
        string Business_Line_Level_1_Code PK
        string Business_Line_Level_1_Name
        int Report_Year PK
        float Net_Revenue_Amount_Year_N
        float Net_Profit_Amount_Year_N
        float Roa_Percentage_Year_N
        float Roe_Percentage_Year_N
        float Net_Revenue_Amount_Year_N1
        float Net_Profit_Amount_Year_N1
        float Roa_Percentage_Year_N1
        float Roe_Percentage_Year_N1
        string Source_System_Code
    }
```

> **Ghi chú thiết kế:** `Business_Line_Level_1_Code` denormalize trực tiếp dạng text (filter Active áp dụng ở tầng ETL populate report — `cl_business_line.active_indicator = 1`). `Business_Line_Level_1_Name` denormalize dạng text — LOOKUP `cl_business_line` theo `cl_business_line_code = Business_Line_Level_1_Code`, lấy tên hiệu lực tại thời điểm chạy ETL (`effective_start_dt`/`effective_end_dt` so khớp `:etl_date`) — không versioning theo lịch sử SCD2 gốc, khớp cách `Business_Line_Level_1_Code` đang xử lý UPSERT theo khóa nghiệp vụ. `Report_Year` = Năm N; cột N-1 lưu kèm trên cùng row (không tạo thêm PK) — khớp đúng pattern "Năm N/N-1 trong cùng 1 query" của SQL BA. Không FK Dimension — đúng đặc tính Fact-report.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    public_company_industry_financial_rpt_g39["Public Company Industry Financial Report"] --> R39["K_GSDC_709-717: BC01.2 — Báo cáo vĩ mô theo ngành"]
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Public Company Industry Financial Report | 1 row / ngành (Business_Line_Level_1_Code) / năm báo cáo (Report_Year = Năm N, kèm cột N-1) |

---

#### Nhóm 40 — STT 40: BC01.3 — Báo cáo vĩ mô đa kỳ (N / N-1 / N-2)

> Phân loại: **Phân tích**
> Source: `Public Company Multi-Period Financial Report` (`public_company_multi_period_financial_rpt`) — Fact-report denormalize hoàn toàn, K_GSDC_718 là tham số UI thuần (không map bảng nào).
> K_GSDC_718 "Kỳ báo cáo" là tham số UI thuần, không map bảng nào.
> SQL BA (`BA_analyst_GSDC_part3.csv` dòng 204-225) là 1 câu SQL duy nhất (CTE `bcdkt`/`kqkd`) aggregate toàn thị trường (không GROUP BY), trả đồng thời 3 kỳ N/N-1/N-2 — mỗi kỳ 1 dòng giá trị duy nhất, đóng gói cố định theo `:year_n`. Đúng tiêu chí Fact-report — không cần Dimension nào (không group-by công ty/ngành/sàn). Denormalize 21 measure (7 chỉ tiêu × 3 kỳ) vào 1 bảng phẳng `Public Company Multi-Period Financial Report`, grain 1 row DUY NHẤT/năm báo cáo (Năm N), 2 kỳ so sánh (N-1/N-2) lưu kèm cột trên cùng row.
> Atomic nguồn (dùng ở tầng ETL populate report): `Financial Report Value` (`fr_value`) JOIN `Financial Report Catalog`/`Row Template`/`Column Template`.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_718 | Kỳ báo cáo | Text | Chiều (Slicer) | — (xem KPI liên quan cùng công thức) |  | **READY** |
| K_GSDC_719 | Tổng tài sản Năm N | Tỉ đồng | Cơ sở | data_val WHERE row_desc=270/270/300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_720 | Nợ phải trả Năm N | Tỉ đồng | Cơ sở | data_val WHERE row_desc=300/300/400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_721 | Vốn chủ sở hữu Năm N | Tỉ đồng | Cơ sở | data_val WHERE row_desc=400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_722 | Vốn điều lệ Năm N | Tỉ đồng | Cơ sở | data_val WHERE row_desc=411/411/411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_723 | LNST Năm N | Tỉ đồng | Cơ sở | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_724 | ROA Năm N | % | Phái sinh | data_val WHERE row_desc=270/270/300 + 60/60/21, report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_725 | ROE Năm N | % | Phái sinh | data_val WHERE row_desc=400/400/500 + 60/60/21, report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_726 | Tổng tài sản Năm N-1 | Tỉ đồng | Cơ sở | data_val WHERE row_desc=270/270/300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_727 | Nợ phải trả Năm N-1 | Tỉ đồng | Cơ sở | data_val WHERE row_desc=300/300/400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_728 | Vốn chủ sở hữu Năm N-1 | Tỉ đồng | Cơ sở | data_val WHERE row_desc=400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_729 | Vốn điều lệ Năm N-1 | Tỉ đồng | Cơ sở | data_val WHERE row_desc=411/411/411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_730 | LNST Năm N-1 | Tỉ đồng | Cơ sở | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_731 | ROA Năm N-1 | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_724, `report_year=:year_n-1`), report=—, col_desc=— | fr_value | **READY** |
| K_GSDC_732 | ROE Năm N-1 | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_725, `report_year=:year_n-1`), report=—, col_desc=— | fr_value | **READY** |
| K_GSDC_733 | Tổng tài sản Năm N-2 | Tỉ đồng | Cơ sở | data_val WHERE row_desc=270/270/300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_734 | Nợ phải trả Năm N-2 | Tỉ đồng | Cơ sở | data_val WHERE row_desc=300/300/400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_735 | Vốn chủ sở hữu Năm N-2 | Tỉ đồng | Cơ sở | data_val WHERE row_desc=400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_736 | Vốn điều lệ Năm N-2 | Tỉ đồng | Cơ sở | data_val WHERE row_desc=411/411/411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_737 | LNST Năm N-2 | Tỉ đồng | Cơ sở | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_738 | ROA Năm N-2 | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_724, `report_year=:year_n-2`), report=—, col_desc=— | fr_value | **READY** |
| K_GSDC_739 | ROE Năm N-2 | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_725, `report_year=:year_n-2`), report=—, col_desc=— | fr_value | **READY** |

> **Ghi chú kỳ:** Toàn bộ measure filter `Report_Quarter IS NULL AND Report_Year = :year_n` (hoặc `-1`/`-2`) — báo cáo kỳ NĂM, KHÔNG GROUP BY (tổng thị trường, mỗi kỳ 1 dòng giá trị duy nhất, khác Nhóm 39 group theo ngành). 3 kỳ N/N-1/N-2 denormalize thành 3 bộ cột trên cùng 1 row report duy nhất.

**Star Schema:**

```mermaid
erDiagram
    Public_Company_Multi_Period_Financial_Report {
        int Report_Year PK
        float Total_Asset_Amount_Year_N
        float Total_Liability_Amount_Year_N
        float Equity_Amount_Year_N
        float Charter_Capital_Amount_Year_N
        float Net_Profit_Amount_Year_N
        float Roa_Percentage_Year_N
        float Roe_Percentage_Year_N
        float Total_Asset_Amount_Year_N1
        float Total_Liability_Amount_Year_N1
        float Equity_Amount_Year_N1
        float Charter_Capital_Amount_Year_N1
        float Net_Profit_Amount_Year_N1
        float Roa_Percentage_Year_N1
        float Roe_Percentage_Year_N1
        float Total_Asset_Amount_Year_N2
        float Total_Liability_Amount_Year_N2
        float Equity_Amount_Year_N2
        float Charter_Capital_Amount_Year_N2
        float Net_Profit_Amount_Year_N2
        float Roa_Percentage_Year_N2
        float Roe_Percentage_Year_N2
        string Source_System_Code
    }
```

> **Ghi chú thiết kế:** Không có FK Dimension nào — bảng aggregate toàn thị trường (không group-by công ty/ngành/sàn), đúng đặc tính Fact-report. `Report_Year` = Năm N (PK duy nhất), 2 kỳ so sánh (N-1/N-2) lưu kèm cột trên cùng row, không tạo thêm PK.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    public_company_multi_period_financial_rpt_g40["Public Company Multi-Period Financial Report"] --> R40["K_GSDC_718-739: BC01.3 — Báo cáo vĩ mô đa kỳ N/N-1/N-2"]
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Public Company Multi-Period Financial Report | 1 row DUY NHẤT / năm báo cáo (Report_Year = Năm N, kèm cột N-1/N-2) — toàn thị trường, không group-by |

---

#### Nhóm 41 — STT 41: BC22 — Tổng hợp tình hình tài chính CTDC theo sàn

> Phân loại: **Phân tích**
> Source: `Public Company Exchange Financial Summary Report` (`public_company_exchange_financial_summary_rpt`) — Fact-report denormalize hoàn toàn.
> SQL BA (`BA_analyst_GSDC_part3.csv` dòng 226-248) là 1 câu SQL duy nhất (CTE `bcdkt_ht`/`bcdkt_kt`...) GROUP BY sàn (`cp.equity_listing_exch`), trả đồng thời giá trị kỳ hiện tại VÀ % YoY so cùng kỳ năm trước trong cùng row — đóng gói cố định theo kỳ quý (`:year`/`:quarter`). Đúng tiêu chí Fact-report. Denormalize 22 measure (11 chỉ tiêu × giá trị + YoY%) vào 1 bảng phẳng `Public Company Exchange Financial Summary Report`, không FK Dimension — `Equity_Listing_Exchange_Code` lưu trực tiếp dạng text. "Vốn góp của chủ sở hữu" = row `411` (cùng khái niệm Vốn điều lệ, K_GSDC_53 Nhóm 7 — tên hiển thị khác). "LNKT trước thuế" = row `50` (dn/bh) / `17` (td).
> Atomic nguồn (dùng ở tầng ETL populate report): `Financial Report Value` (`fr_value`) JOIN `Public Company` (lấy sàn) + `Financial Report Catalog`/`Row Template`/`Column Template`.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_GSDC_740 | Theo sàn | Text | Chiều (Group By) | equity_listing_exchange_code (xem KPI liên quan cùng công thức) | public_company | **READY** |
| K_GSDC_741 | Tổng tài sản theo sàn | Tỉ đồng | Phái sinh | data_val WHERE row_desc=270/270/300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_741_YOY | Tổng tài sản — YoY theo sàn | % | Phái sinh | data_val WHERE row_desc=270/270/300, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_742 | Hàng tồn kho theo sàn | Tỉ đồng | Phái sinh | data_val WHERE row_desc=140/140/—, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_742_YOY | Hàng tồn kho — YoY theo sàn | % | Phái sinh | data_val WHERE row_desc=140/140/—, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_743 | Nợ phải trả theo sàn | Tỉ đồng | Phái sinh | data_val WHERE row_desc=300/300/400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_743_YOY | Nợ phải trả — YoY theo sàn | % | Phái sinh | data_val WHERE row_desc=300/300/400, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_744 | Vốn chủ sở hữu theo sàn | Tỉ đồng | Phái sinh | data_val WHERE row_desc=400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_744_YOY | VCSH — YoY theo sàn | % | Phái sinh | data_val WHERE row_desc=400/400/500, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_745 | Vốn góp của chủ sở hữu theo sàn | Tỉ đồng | Phái sinh | data_val WHERE row_desc=411/411/411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_745_YOY | VGC — YoY theo sàn | % | Phái sinh | data_val WHERE row_desc=411/411/411, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_746 | LNST chưa phân phối theo sàn | Tỉ đồng | Phái sinh | data_val WHERE row_desc=421/421/450, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_746_YOY | LNST chưa PP — YoY theo sàn | % | Phái sinh | data_val WHERE row_desc=421/421/450, report=BCDKT, col_desc=1 | fr_value | **READY** |
| K_GSDC_747 | Doanh thu thuần theo sàn | Tỉ đồng | Phái sinh | data_val WHERE row_desc=10/10/03, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_747_YOY | DTT — YoY theo sàn | % | Phái sinh | data_val WHERE row_desc=10/10/03, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_748 | LNKT trước thuế theo sàn | Tỉ đồng | Phái sinh | data_val WHERE row_desc=50/50/17, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_748_YOY | LNKT trước thuế — YoY theo sàn | % | Phái sinh | data_val WHERE row_desc=50/50/17, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_749 | LNST theo sàn | Tỉ đồng | Phái sinh | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_749_YOY | LNST — YoY theo sàn | % | Phái sinh | data_val WHERE row_desc=60/60/21, report=BCKQKD, col_desc=1 | fr_value | **READY** |
| K_GSDC_750 | ROA theo sàn | % | Phái sinh | data_val WHERE row_desc=270/270/300 + 60/60/21, report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_750_YOY | ROA — YoY theo sàn | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_750), report=—, col_desc=— | fr_value | **READY** |
| K_GSDC_751 | ROE theo sàn | % | Phái sinh | data_val WHERE row_desc=400/400/500 + 60/60/21, report=BCDKT+BCKQKD, col_desc=1+2 | fr_value | **READY** |
| K_GSDC_751_YOY | ROE — YoY theo sàn | % | Phái sinh | data_val WHERE row_desc=(như K_GSDC_751), report=—, col_desc=— | fr_value | **READY** |

**Star Schema:**

```mermaid
erDiagram
    Public_Company_Exchange_Financial_Summary_Report {
        string Equity_Listing_Exchange_Code PK
        int Report_Year PK
        int Report_Quarter PK
        float Total_Asset_Amount
        float Total_Asset_Yoy_Percentage
        float Inventory_Amount
        float Inventory_Yoy_Percentage
        float Total_Liability_Amount
        float Total_Liability_Yoy_Percentage
        float Equity_Amount
        float Equity_Yoy_Percentage
        float Contributed_Capital_Amount
        float Contributed_Capital_Yoy_Percentage
        float Undistributed_Profit_Amount
        float Undistributed_Profit_Yoy_Percentage
        float Net_Revenue_Amount
        float Net_Revenue_Yoy_Percentage
        float Pre_Tax_Profit_Amount
        float Pre_Tax_Profit_Yoy_Percentage
        float Net_Profit_Amount
        float Net_Profit_Yoy_Percentage
        float Roa_Percentage
        float Roa_Yoy_Difference
        float Roe_Percentage
        float Roe_Yoy_Difference
        string Source_System_Code
    }
```

> **Ghi chú thiết kế:** `Equity_Listing_Exchange_Code` denormalize trực tiếp dạng text — không FK Dimension. Mỗi chỉ tiêu có 2 cột (giá trị kỳ hiện tại + YoY) trên cùng row, khớp đúng pattern SQL BA (1 CTE trả cả giá trị và % so cùng kỳ năm trước). ROA/ROE YoY là hiệu số (percentage point), không phải % tăng/giảm tương đối — theo đúng SQL BA (`roa_yoy_diff`/`roe_yoy_diff`).

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    public_company_exchange_financial_summary_rpt_g41["Public Company Exchange Financial Summary Report"] --> R41["K_GSDC_740-751+YOY: BC22 — Tổng hợp tình hình tài chính theo sàn"]
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Public Company Exchange Financial Summary Report | 1 row / sàn NY-ĐKGD / kỳ (Report_Year + Report_Quarter) |

---

## Section 3 — Mô hình tổng thể

```mermaid
graph TB
    classDef dim fill:#E6F1FB,stroke:#185FA5,color:#0C447C
    classDef fact fill:#FAECE7,stroke:#993C1D,color:#4A1B0C

    DIM_CO["Public Company Dimension"]:::dim
    DIM_DATE["Calendar Date Dimension"]:::dim
    DIM_CTLG["Financial Report Catalog Dimension"]:::dim

    FACT_RISK["Fact Public Company Risk Score Snapshot"]:::fact
    FACT_COMP["Fact Public Company Compliance Score Snapshot"]:::fact
    FACT_ISS["Fact Public Company Issuance Score Snapshot"]:::fact
    FACT_FIN["Fact Public Company Financial Score Snapshot"]:::fact
    FACT_NONFIN["Fact Public Company Non-Financial Score Snapshot"]:::fact
    FACT_RPTVAL["Fact Public Company Financial Report Value"]:::fact
    FACT_LIST["Fact Public Company Listing Info Snapshot"]:::fact
    FACT_VLTREPORT_SNPST["Fact Violation Report Snapshot"]:::fact
    RPT_REGCOMP["Public Company Regulatory Compliance Report"]:::fact
    RPT_INDFIN["Public Company Industry Financial Report"]:::fact
    RPT_MULTIPERIOD["Public Company Multi-Period Financial Report"]:::fact
    RPT_EXCHSUM["Public Company Exchange Financial Summary Report"]:::fact

    DIM_CO --> FACT_RISK
    DIM_DATE --> FACT_RISK
    DIM_CO --> FACT_COMP
    DIM_DATE --> FACT_COMP
    DIM_CO --> FACT_ISS
    DIM_DATE --> FACT_ISS
    DIM_CO --> FACT_FIN
    DIM_DATE --> FACT_FIN
    DIM_CO --> FACT_NONFIN
    DIM_DATE --> FACT_NONFIN
    DIM_CO --> FACT_RPTVAL
    DIM_CTLG --> FACT_RPTVAL
    DIM_CO --> FACT_LIST
    DIM_DATE --> FACT_LIST
    DIM_CO --> FACT_VLTREPORT_SNPST
    DIM_DATE --> FACT_VLTREPORT_SNPST
```

> `Fact Public Company Financial Summary Snapshot` không tồn tại trong mô hình. Các KPI liên quan (Nhóm 6/9/10/12/14/16/38/39/40/41) query trực tiếp `Public Company Dimension`/`Calendar Date Dimension`, không có node Fact riêng trong graph.
>
> `Fact Public Company Financial Report Value` (`FACT_RPTVAL`) không có FK `Calendar Date Dimension` — grain thời gian là `Report Year`/`Report Quarter` dạng thuộc tính DD trực tiếp trên Fact (kỳ báo cáo tài chính, không phải ngày lịch), khác với 5 Fact `*_Score_Snapshot` (dùng Calendar Date Dimension cho ngày snapshot ETL).
>
> `Fact Violation Report Snapshot` (`FACT_VLTREPORT_SNPST`) phục vụ K_GSDC_48 (Nhóm 6/10/12/14/16) — nguồn `violation_report`/IDS.VIOLATION_REPORT. Grain 1 row/công ty/kỳ (Report_Year + Report_Quarter), phát sinh theo kỳ (ETL append) — đúng ngữ nghĩa Fact, không phải Operational SCD4A (dữ liệu này KHÔNG phải current-state, mỗi kỳ có tập hồ sơ mới). Độc lập hoàn toàn với `Fact Public Company Financial Report Value` — không JOIN chéo giữa 2 Fact. K_GSDC_49 (Số DN báo lãi, cùng Nhóm 6/10/12/14/16) KHÔNG dùng Fact này — dùng trực tiếp `Fact Public Company Financial Report Value` (sửa 2026-08-15).
>
> 4 bảng report (`RPT_REGCOMP`/`RPT_INDFIN`/`RPT_MULTIPERIOD`/`RPT_EXCHSUM`) KHÔNG có FK Dimension nào trong graph này — đúng đặc tính Fact-report (đóng gói cố định theo kỳ, denormalize hoàn toàn, ETL populate batch trực tiếp từ Atomic, không cần JOIN runtime tới `Public Company Dimension`/`Calendar Date Dimension`). `Fact Public Company Financial Report Value` không phục vụ Nhóm 38-41 — xem bảng KPI bên dưới.

**Bảng Phân tích (Star Schema):**

| Bảng | Pattern | Grain | KPI | Trạng thái |
|---|---|---|---|---|
| `Fact Public Company Risk Score Snapshot` | Periodic Snapshot | 1 CTDC × 1 ngày snapshot ETL (full-scan daily, carry-forward) | K_GSDC_1–6 (Nhóm 1); K_GSDC_1, 2, 3, 4, 5, 6, 7, 8 (Nhóm 32, reuse) | READY (Atomic draft — chưa approved) |
| `Fact Public Company Compliance Score Snapshot` | Periodic Snapshot | 1 CTDC × 1 ngày snapshot ETL (full-scan daily, carry-forward) | K_GSDC_9–23 (Nhóm 2); reuse toàn bộ (Nhóm 33) | READY (Atomic draft — chưa approved) |
| `Fact Public Company Issuance Score Snapshot` | Periodic Snapshot | 1 CTDC × 1 ngày snapshot ETL (full-scan daily, carry-forward) | K_GSDC_24–31 (Nhóm 3); reuse toàn bộ (Nhóm 35) | READY (Atomic draft — chưa approved) |
| `Fact Public Company Financial Score Snapshot` | Periodic Snapshot | 1 CTDC × 1 ngày snapshot ETL (full-scan daily, carry-forward) | K_GSDC_32–42 (Nhóm 4); reuse toàn bộ (Nhóm 34) | READY (Atomic draft — chưa approved) |
| `Fact Public Company Non-Financial Score Snapshot` | Periodic Snapshot | 1 CTDC × 1 ngày snapshot ETL (full-scan daily, carry-forward) | K_GSDC_43–45 (Nhóm 5); reuse toàn bộ (Nhóm 36) | READY (Atomic draft — chưa approved) |
| `Fact Public Company Financial Report Value` | Event | 1 CTDC × 1 kỳ (Report_Year + Report_Quarter, nullable = kỳ năm) × Row_Code × Column_Code | K_GSDC_50–62+YOY (Nhóm 7); K_GSDC_63-76 (Nhóm 8); K_GSDC_50-62+79-92+YOY (Nhóm 11/13/15/17, reuse ID); K_GSDC_50-62 (Nhóm 37, reuse ID); K_GSDC_99-689 (Nhóm 19-30, MH3 Data Explorer — DN thông thường/bảo hiểm/TCTD × BCĐKT/BCKQKD/LCTT trực tiếp/gián tiếp); K_GSDC_49 (Nhóm 6/10/12/14/16, reuse — Số DN báo lãi) | READY cho toàn bộ Nhóm 7/8/11/13/15/17/19-30/37 (Atomic đủ 5 entity: `fr_value`/`financial_report_catalog`/`fr_row_template`/`fr_column_template`/`pc_report_submission`, xem chi tiết Nhóm 7). K_GSDC_49 (Nhóm 6/10/12/14/16) sửa 2026-08-15 sang dùng Fact này (trước đó dùng `Fact Violation Report Snapshot`, sai vì bắc cầu kỳ qua `violation_report` — xem Nhóm 6). Nhóm 38-41 dùng 4 bảng Fact-report riêng (xem 4 dòng bên dưới), không dùng Fact này. |
| `Fact Violation Report Snapshot` | Event | 1 row / công ty đại chúng / kỳ (Report_Year + Report_Quarter) / ngày ETL snapshot (FK Calendar Date Dimension) | K_GSDC_48 (Nhóm 6/10/12/14/16) — Tỷ lệ nộp BCTC | READY (2026-08-07 — nguồn `violation_report`/draft, sửa lại từ Operational → Fact vì dữ liệu phát sinh theo kỳ, không phải current-state; bổ sung FK Calendar Date Dimension theo ngày ETL; xem Nhóm 6). Sửa 2026-08-15: bỏ cột `Profitable_Indicator`, chỉ còn phục vụ K_GSDC_48. |
| `Fact Public Company Listing Info Snapshot` | Periodic Snapshot | 1 CTDC × 1 ngày | K_GSDC_690–699 (Nhóm 31) | PENDING |
| `Public Company Regulatory Compliance Report` | Fact-report | 1 row / sàn NY-ĐKGD / kỳ (Report_Year + Report_Quarter) | K_GSDC_700-708 (Nhóm 38) — BC01.1 | READY (2026-08-07 — thiết kế lại từ query đa nguồn thành Fact-report denormalize, xem Nhóm 38) |
| `Public Company Industry Financial Report` | Fact-report | 1 row / ngành / năm báo cáo (kèm cột N-1) | K_GSDC_709-717 (Nhóm 39) — BC01.2 | READY (2026-08-07 — thiết kế lại thành Fact-report, xem Nhóm 39) |
| `Public Company Multi-Period Financial Report` | Fact-report | 1 row DUY NHẤT / năm báo cáo (kèm cột N-1/N-2), toàn thị trường không group-by | K_GSDC_718-739 (Nhóm 40) — BC01.3 | READY (2026-08-07 — thiết kế lại thành Fact-report, xem Nhóm 40) |
| `Public Company Exchange Financial Summary Report` | Fact-report | 1 row / sàn NY-ĐKGD / kỳ (Report_Year + Report_Quarter) | K_GSDC_740-751+YOY (Nhóm 41) — BC22 | READY (2026-08-07 — thiết kế lại thành Fact-report, xem Nhóm 41) |

> `Fact Public Company Financial Summary Snapshot` không tồn tại trong mô hình. KPI liên quan (K_GSDC_46–49 Nhóm 6; reuse Nhóm 9/10/12/14/16; K_GSDC_700–708 Nhóm 38; K_GSDC_709–717 Nhóm 39; K_GSDC_718–739 Nhóm 40; K_GSDC_740–751+YOY Nhóm 41) dùng trực tiếp `Public Company Dimension`/`Calendar Date Dimension` (Nhóm 6/9/10/12/14/16), `Fact Violation Report Snapshot` (K_GSDC_48, Nhóm 6), `Fact Public Company Financial Report Value` (K_GSDC_49, Nhóm 6, reuse từ Nhóm 7), hoặc 4 bảng Fact-report riêng (Nhóm 38-41, xem trên).

**Bảng Tác nghiệp:**

Không có bảng Tác nghiệp nào trong module này. `Operational Public Company Report Submission` (thiết kế 2026-08-06) đã bị loại bỏ khi thiết kế lại Nhóm 38 thành Fact-report (2026-08-07) — measure COUNT thật nay được ETL trực tiếp từ Atomic `pc_report_submission` vào `Public Company Regulatory Compliance Report`, không cần bảng Tác nghiệp trung gian.

**Bảng Dimension:**

| Dimension | Loại | Mô tả | Scheme | Trạng thái |
|---|---|---|---|---|
| `Public Company Dimension` | SCD4A | Mã CK, Tên DN, Sàn, Ngành — dùng chung toàn bộ màn hình | IDS_LISTING_TYPE, IDS_INDUSTRY_CATEGORY | READY (Atomic draft — chưa approved) |
| `Calendar Date Dimension` | Conformed | Năm / Quý — shared toàn hệ thống Lakehouse, không chỉ riêng GSDC | — | READY |
| `Financial Report Catalog Dimension` | Reference per module (SCD4A) | Template BCTC — báo cáo / dòng / cột; composite join key (Financial_Report_Catalog_Code + Row_Code + Column_Code); denormalize Row/Column Description Reference từ `fr_row_template`/`fr_column_template` | — | READY (2026-08-06 — nguồn `financial_report_catalog`/draft, `fr_row_template`/approved, `fr_column_template`/approved, dùng cho Fact Public Company Financial Report Value) |

---

## Section 4 — Reuse Analysis

| Datamart Entity | datamart_table | reuse_status | Ghi chú |
|---|---|---|---|
| Fact Public Company Financial Report Value | fct_public_company_financial_rpt_val | new | Fact cho Nhóm 7/8/11/13/15/17/19-30/37 (MH2+MH3, READY) — driving `fr_value`, JOIN `financial_report_catalog`/`fr_row_template`/`fr_column_template` + EXISTS `pc_report_submission`. Không phục vụ Nhóm 38-41 (4 bảng Fact-report riêng) |
| Financial Report Catalog Dimension | financial_rpt_catalog_dim | new | Dimension phụ trợ cho Fact Public Company Financial Report Value (READY 2026-08-06) — nguồn `financial_report_catalog` + denormalize `fr_row_template`/`fr_column_template` |
| Fact Public Company Risk Score Snapshot | fct_public_company_risk_score_snpst | new | Fact mới cho Nhóm 1 (MH1 Tab Tổng hợp) — nguồn Atomic draft |
| Fact Public Company Compliance Score Snapshot | fct_public_company_compliance_score_snpst | new | Fact mới cho Nhóm 2 (MH1 Tab Tuân thủ) — nguồn Atomic draft |
| Fact Public Company Issuance Score Snapshot | fct_public_company_issuance_score_snpst | new | Fact mới cho Nhóm 3 (MH1 Tab Phát hành) — nguồn Atomic draft |
| Fact Public Company Financial Score Snapshot | fct_public_company_financial_score_snpst | new | Fact mới cho Nhóm 4 (MH1 Tab Tài chính) — nguồn Atomic draft |
| Fact Public Company Non-Financial Score Snapshot | fct_public_company_nonfinancial_score_snpst | new | Fact mới cho Nhóm 5 (MH1 Tab Phi TC & M-Score) — nguồn Atomic draft |
| Fact Public Company Listing Info Snapshot | fct_public_company_listing_info_snpst | pending | PENDING — nguồn MSS chưa có Atomic (MH5 DB33) |
| Public Company Dimension | public_company_dim | reuse | Dùng chung toàn bộ Nhóm 1–37 (MH1/MH2/MH3) — 1 Dimension duy nhất cho toàn module (không dùng cho Nhóm 38-41 nữa — xem 4 dòng Fact-report bên dưới) |
| Calendar Date Dimension | cdr_dt_dim | reuse | Dimension Conformed dùng chung toàn hệ thống Lakehouse, không chỉ riêng GSDC |
| Fact Violation Report Snapshot | fct_violation_rpt_snpst | new | Mới 2026-08-06, sửa table_type Operational → Fact + đổi tên thêm hậu tố Snapshot 2026-08-07 (grain 1 row/công ty/kỳ/ngày ETL snapshot, FK Calendar Date Dimension) — nguồn `violation_report`/IDS.VIOLATION_REPORT (draft), phục vụ K_GSDC_48 (Nhóm 6/10/12/14/16). Sửa 2026-08-15: bỏ cột `Profitable_Indicator` (K_GSDC_49 chuyển sang dùng `Fact Public Company Financial Report Value`, xem dòng trên) — lý do: kỳ join `fr_value` trước đó bắc cầu sai qua `violation_report.period_year`, 2 bảng nguồn độc lập không đảm bảo khớp kỳ. |
| Public Company Regulatory Compliance Report | public_company_regulatory_compliance_rpt | new | Mới 2026-08-07, thay thế thiết kế đa nguồn (Public Company Dimension + Operational Public Company Report Submission + Fact Financial Report Value) — Fact-report denormalize cho Nhóm 38 (BC01.1), K_GSDC_700-708, grain 1 row/sàn/kỳ |
| Public Company Industry Financial Report | public_company_industry_financial_rpt | new | Mới 2026-08-07, thay thế reuse Fact Financial Report Value — Fact-report denormalize cho Nhóm 39 (BC01.2), K_GSDC_709-717, grain 1 row/ngành/năm |
| Public Company Multi-Period Financial Report | public_company_multi_period_financial_rpt | new | Mới 2026-08-07, thay thế reuse Fact Financial Report Value — Fact-report denormalize cho Nhóm 40 (BC01.3), K_GSDC_718-739, grain 1 row DUY NHẤT/năm (toàn thị trường) |
| Public Company Exchange Financial Summary Report | public_company_exchange_financial_summary_rpt | new | Mới 2026-08-07, thay thế thiết kế đa nguồn (Public Company Dimension + Fact Financial Report Value) — Fact-report denormalize cho Nhóm 41 (BC22), K_GSDC_740-751+YOY, grain 1 row/sàn/kỳ |

> **Ghi chú KPI reuse (không phải Datamart Entity reuse):** Reuse ở cấp KPI/cột (không phải reuse bảng Fact/Dim) được ghi trực tiếp trong bảng KPI của từng Nhóm (cột Công thức/Ghi chú) — không lặp lại ở đây. Các KPI reuse chính xuyên suốt module: K_GSDC_7/K_GSDC_8 (Mã CK/Tên DN, gốc Nhóm 1) dùng ở mọi Nhóm 2 trở đi; K_GSDC_46/K_GSDC_78 (Kỳ thống kê/Sàn, gốc Nhóm 6) dùng ở Nhóm 10/12/14/16; K_GSDC_50–62+YOY (gốc Nhóm 7) và K_GSDC_79–92 (Ngành, gốc Nhóm 11) dùng ở Nhóm 11/13/15/17; K_GSDC_63 (Ngành, gốc Nhóm 8) dùng ở Nhóm 18; K_GSDC_48/49 (gốc Nhóm 6) dùng ở Nhóm 10/12/14/16.
>
> **Gate rule "Loại dữ liệu":** BA đánh dấu "Dữ liệu động" hoặc "Dữ liệu tĩnh - Chưa có CSDL" → KPI PENDING dù `Trạng thái mapping = Done`. Toàn bộ Nhóm 6/7/8/10/11/12/13/14/15/16/17/18/19-30/37/38/39/40/41 **READY** (Atomic đủ 5 entity Financial Report Value + entity `violation_report`). Không còn Nhóm nào PENDING do gate rule "Loại dữ liệu" trong module GSDC.
>
> **`Public Company Financial Report Value`:** nguồn `IDS.data` + `report_catalog` + `rrow` + `rcol`, dùng cho K_GSDC_49 và toàn bộ Nhóm 7/8/9/10/11/13/15/17/37 — Atomic LLD: `fr_value`/`financial_report_catalog`/`fr_row_template`/`fr_column_template`/`pc_report_submission`, `DataModel/working/Atomic/lld/IDS/`.
>
> **Nhóm 38-41 dùng Fact-report:** cả 4 Nhóm là báo cáo cố định theo kỳ (BC01.1/01.2/01.3/BC22), đúng tiêu chí Fact-report theo `naming_conventions.md` — 4 bảng phẳng riêng biệt, denormalize hoàn toàn, không FK Dimension — xem chi tiết Nhóm 38/39/40/41 và Cụm 9-12 (Section 1).

---

## Section 5 — Vấn đề mở

| ID | Vấn đề | Giả định hiện tại | KPI liên quan | Trạng thái |
|---|---|---|---|---|
| O_GSDC_1 | Nhóm 1–5 (Màn hình 1) có nguồn thật từ `IDS.EVALUATIONS` / `EVALUATION_DETAILS` / `EVALUATION_CRITERIA` / `EVALUATION_GROUPS` / `EVALUATION_PERIODS`. Atomic tương ứng (`Public Company Evaluation` + 4 entity con) đã có LLD tại `DataModel/working/Atomic/lld/IDS/` nhưng `design_status: draft`, chưa approved. K_GSDC_38 "VCSH" (Nhóm 4) vẫn còn trong BA. K_GSDC_33 = "ROA". Nhóm 3 K_GSDC_29 = "Xếp hạng tín nhiệm". K_GSDC_45 = "Tổng điểm Phi tài chính & M-Score" (Nhóm 5). Nhóm 32–36 (Data Explorer) READY (Atomic draft) — logic/công thức giống hệt Nhóm 1–5 tương ứng nhưng **KHÔNG reuse KPI_ID** (quyết định thiết kế: Data Explorer là luồng khai thác độc lập với Dashboard, không dùng chung KPI_ID dù cùng Fact/công thức) — cấp dải KPI_ID riêng K_GSDC_1391–1443 (Nhóm 32: 1391–1398, Nhóm 33: 1399–1415, Nhóm 34: 1416–1428, Nhóm 35: 1429–1438, Nhóm 36: 1439–1443). | Nhóm 1–5 + 32–36: chờ approve Atomic entity draft. | K_GSDC_1–45, K_GSDC_7-8 (Nhóm 1-5, Dashboard); K_GSDC_1391–1443 (Nhóm 32-36, Data Explorer — dải ID riêng, không reuse) | Closed |
| O_GSDC_2 | KPI Số doanh nghiệp (K_GSDC_7, K_GSDC_34) có nguồn từ `IDS.company_detail` với điều kiện `ids_reg_date <= cuối kỳ` — không join qua `company_data` hay `data`. Mọi KPI Số DN (K_GSDC_47/77/701...) tính trực tiếp `COUNT DISTINCT` trên `Public Company Dimension.IDS_Registration_Date`, không qua Fact nào. | Đã tính trực tiếp trên `Public Company Dimension` cho toàn bộ Nhóm 6/9/10/12/14/16 — không cần Fact riêng. | K_GSDC_7, K_GSDC_34 | Closed |
| O_GSDC_3 | BA SQL DB25 xác nhận `rr.row_desc` và `rc2.col_desc` dùng làm mã hiển thị nghiệp vụ và filter điều kiện trong mọi dashboard DB21–32 — map 1-1 (`Row Description Reference`/`row_description_reference` ← `IDS.RROW.ROW_DESC`, `Column Description Reference`/`column_description_reference` ← `IDS.RCOL.COL_DESC`). `fr_value`/`financial_report_catalog`/`fr_row_template`/`fr_column_template`/`pc_report_submission` đã có LLD (row/column template `approved`), dùng làm nền `Fact Public Company Financial Report Value` + `Financial Report Catalog Dimension`, áp dụng cho Nhóm 7/8/11/13/15/17/18/19-30/37 (Nhóm 38-41 đã tách thành Fact-report riêng, xem Nhóm 38-41). | Đã thiết kế `Fact Public Company Financial Report Value` + `Financial Report Catalog Dimension` dựa trên entity Atomic — xem chi tiết Nhóm 7/18. | K_GSDC_33, K_GSDC_D8–D11 | Closed |
| O_GSDC_4 | DB43 BC22 có KPI "Lợi nhuận kế toán trước thuế" (LNKT trước thuế) — cần map đúng row BCTC. | K_GSDC_58 (Nhóm 41: K_GSDC_748, LNKT trước thuế theo sàn) — map `fr_value` row `50`(dn/bh)/`17`(td), `rc.report_cd LIKE 'BCKQKD%'`. | K_GSDC_58 | Closed |
