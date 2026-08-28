## 3.1.5 LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO Giám sát Công ty Đại chúng

### 3.1.5.1 Thông tin chung luồng đồng bộ

- Tên job:
- Nguồn dữ liệu (Hệ thống nguồn): IDS
- Cách thức truy xuất đồng bộ dữ liệu:
- Tần suất đồng bộ dữ liệu:
- Dung lượng dữ liệu sẽ thực hiện đồng bộ:
- Thời gian lưu trữ dữ liệu:
- Thư mục lưu trữ dữ liệu trên kho dữ liệu:

### 3.1.5.2 Luồng nghiệp vụ

#### 3.1.5.2.1 Nhóm thông tin Báo cáo tài chính & Nộp báo cáo

```mermaid
flowchart LR
    subgraph Staging
        IDS_company_data["IDS.company_data"]
        IDS_data["IDS.data"]
        IDS_report_catalog["IDS.report_catalog"]
        IDS_rrow["IDS.rrow"]
        IDS_rcol["IDS.rcol"]
    end
    subgraph Atomic
        Public_Company_Report_Submission["Public Company Report Submission"]
        Public_Company_Financial_Report_Value["Public Company Financial Report Value"]
        Financial_Report_Catalog["Financial Report Catalog"]
        Financial_Report_Row_Template["Financial Report Row Template"]
        Financial_Report_Column_Template["Financial Report Column Template"]
    end
    subgraph Datamart
        fct_pblc_co_fnc_sumry_snpst["Fact Public Company Financial Summary Snapshot"]
        pblc_co_dim["Public Company Dimension"]
        cdr_dt_dim["Calendar Date Dimension"]
    end
    IDS_company_data --> Public_Company_Report_Submission
    IDS_data --> Public_Company_Financial_Report_Value
    IDS_report_catalog --> Financial_Report_Catalog
    IDS_rrow --> Financial_Report_Row_Template
    IDS_rcol --> Financial_Report_Column_Template
    Public_Company_Report_Submission --> fct_pblc_co_fnc_sumry_snpst
    Public_Company_Financial_Report_Value --> fct_pblc_co_fnc_sumry_snpst
    pblc_co_dim --> fct_pblc_co_fnc_sumry_snpst
    cdr_dt_dim --> fct_pblc_co_fnc_sumry_snpst
```

**Mục đích:** Cung cấp bảng sự kiện tổng hợp tài chính theo kỳ báo cáo cho Màn hình 2 (Giám sát Tổng hợp) và Màn hình 4 (Báo cáo giám sát CTDC). Mỗi dòng tổng hợp 13 chỉ tiêu tài chính chính của một doanh nghiệp trong một kỳ (năm × quý).

**Mô tả luồng:**

Staging → Atomic:
- **Public Company Report Submission:** Bảng lưu thông tin lần nộp báo cáo của từng công ty đại chúng — kỳ báo cáo, ngày nộp, hạn nộp — lấy thông tin từ bảng IDS.company_data.
- **Public Company Financial Report Value:** Bảng lưu giá trị từng ô chỉ tiêu trong báo cáo tài chính theo định dạng tall (1 dòng / 1 ô) — lấy thông tin từ bảng IDS.data.
- **Financial Report Catalog:** Bảng lưu danh mục biểu mẫu BCTC (tên, loại hình DN, chiều) — lấy thông tin từ bảng IDS.report_catalog.
- **Financial Report Row Template:** Bảng lưu template dòng chỉ tiêu của biểu mẫu BCTC — lấy thông tin từ bảng IDS.rrow.
- **Financial Report Column Template:** Bảng lưu template cột của biểu mẫu BCTC — lấy thông tin từ bảng IDS.rcol.

Atomic → Datamart:
- **Fact Public Company Financial Summary Snapshot:** Bảng sự kiện tổng hợp tài chính dạng Periodic Snapshot — pivot 13 chỉ tiêu tài chính chính (tổng tài sản, nợ, VCSH, lợi nhuận...) từ định dạng tall Atomic sang wide, phục vụ phân tích tổng hợp và so sánh theo sàn, ngành, kỳ.
- **Public Company Dimension:** Bảng lưu thông tin chiều công ty đại chúng theo dạng SCD2, cho phép tra cứu doanh nghiệp theo thời điểm.
- **Calendar Date Dimension:** Bảng lưu thông tin thời gian.

---

#### 3.1.5.2.2 Nhóm thông tin Chi tiết BCTC từng CTDC & Danh mục template

```mermaid
flowchart LR
    subgraph Staging
        IDS_company_data["IDS.company_data"]
        IDS_data["IDS.data"]
        IDS_report_catalog["IDS.report_catalog"]
        IDS_rrow["IDS.rrow"]
        IDS_rcol["IDS.rcol"]
    end
    subgraph Atomic
        Public_Company_Report_Submission["Public Company Report Submission"]
        Public_Company_Financial_Report_Value["Public Company Financial Report Value"]
        Financial_Report_Catalog["Financial Report Catalog"]
        Financial_Report_Row_Template["Financial Report Row Template"]
        Financial_Report_Column_Template["Financial Report Column Template"]
    end
    subgraph Datamart
        fct_pblc_co_fnc_rpt_val["Fact Public Company Financial Report Value"]
        fnc_rpt_ctlg_dim["Financial Report Catalog Dimension"]
        pblc_co_dim["Public Company Dimension"]
        cdr_dt_dim["Calendar Date Dimension"]
    end
    IDS_company_data --> Public_Company_Report_Submission
    IDS_data --> Public_Company_Financial_Report_Value
    IDS_report_catalog --> Financial_Report_Catalog
    IDS_rrow --> Financial_Report_Row_Template
    IDS_rcol --> Financial_Report_Column_Template
    Public_Company_Financial_Report_Value --> fct_pblc_co_fnc_rpt_val
    Public_Company_Report_Submission --> fct_pblc_co_fnc_rpt_val
    Financial_Report_Catalog --> fnc_rpt_ctlg_dim
    Financial_Report_Row_Template --> fnc_rpt_ctlg_dim
    Financial_Report_Column_Template --> fnc_rpt_ctlg_dim
    pblc_co_dim --> fct_pblc_co_fnc_rpt_val
    cdr_dt_dim --> fct_pblc_co_fnc_rpt_val
    fnc_rpt_ctlg_dim --> fct_pblc_co_fnc_rpt_val
```

**Mục đích:** Cung cấp bảng sự kiện chi tiết BCTC theo từng chỉ tiêu (1 dòng / CTDC / kỳ / dòng chỉ tiêu / cột) và bảng chiều danh mục BCTC phục vụ Data Explorer tra cứu giá trị từng ô BCTC của từng doanh nghiệp (Màn hình 3, STT 21–32 + STT 39).

**Mô tả luồng:**

Staging → Atomic:
- **Public Company Report Submission:** Bảng lưu thông tin lần nộp báo cáo của từng công ty đại chúng — kỳ báo cáo, ngày nộp, hạn nộp — lấy thông tin từ bảng IDS.company_data.
- **Public Company Financial Report Value:** Bảng lưu giá trị từng ô chỉ tiêu trong báo cáo tài chính theo định dạng tall (1 dòng / 1 ô) — lấy thông tin từ bảng IDS.data.
- **Financial Report Catalog:** Bảng lưu danh mục biểu mẫu BCTC (tên, loại hình DN, chiều) — lấy thông tin từ bảng IDS.report_catalog.
- **Financial Report Row Template:** Bảng lưu template dòng chỉ tiêu của biểu mẫu BCTC — lấy thông tin từ bảng IDS.rrow.
- **Financial Report Column Template:** Bảng lưu template cột của biểu mẫu BCTC — lấy thông tin từ bảng IDS.rcol.

Atomic → Datamart:
- **Fact Public Company Financial Report Value:** Bảng sự kiện chi tiết BCTC giữ nguyên định dạng tall từ Atomic — 1 dòng cho mỗi tổ hợp CTDC × kỳ × dòng chỉ tiêu × cột, phục vụ tra cứu toàn bộ chỉ tiêu BCTC trong Data Explorer.
- **Financial Report Catalog Dimension:** Bảng lưu thông tin danh mục BCTC dạng cross-tab — mỗi dòng tương ứng một tổ hợp (biểu mẫu × dòng chỉ tiêu × cột), cung cấp tên và thứ tự hiển thị cho Data Explorer.
- **Public Company Dimension:** Bảng lưu thông tin chiều công ty đại chúng theo dạng SCD2, cho phép tra cứu doanh nghiệp theo thời điểm.
- **Calendar Date Dimension:** Bảng lưu thông tin thời gian.
