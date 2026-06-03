# Flowchart — Format đúng

## Ví dụ 1: Cụm Fact Snapshot — 2 nguồn, có Calendar Date

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        FMS_RPTVALUES["FMS.RPTVALUES"]
        FMS_SECURITIES["FMS.SECURITIES"]
        ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end
    subgraph SIL["Atomic"]
        Report_Import_Value["Report Import Value"]
        Fund_Management_Company["Fund Management Company"]
        Calendar_Date["Calendar Date"]
    end
    subgraph GOLD["Datamart"]
        fct_fms_snpst["Fact Fund Management Company Snapshot"]
        fnd_mgt_co_dim["Fund Management Company Dimension"]
        cdr_dt_dim["Calendar Date Dimension"]
    end
    FMS_RPTVALUES --> Report_Import_Value
    FMS_SECURITIES --> Fund_Management_Company
    ECAT_ECAT_29_HolidayInfo --> Calendar_Date
    Report_Import_Value --> fct_fms_snpst
    Fund_Management_Company --> fnd_mgt_co_dim
    Calendar_Date --> cdr_dt_dim
    fnd_mgt_co_dim --> fct_fms_snpst
    cdr_dt_dim --> fct_fms_snpst
```

**Đặc điểm đúng:**
- 1 subgraph Staging duy nhất, gộp tất cả nguồn kể cả ECAT
- Node Staging: `FMS_RPTVALUES["FMS.RPTVALUES"]` — ID không dấu chấm, label có dấu chấm
- Node Atomic: `Report_Import_Value["Report Import Value"]` — ID dùng `_`, label bỏ `_`
- Node Datamart: `fct_fms_snpst["Fact Fund Management Company Snapshot"]` — ID physical, label logical
- Calendar Date đủ 3 tầng: Staging → Atomic → Datamart
- Dim link vào Fact: `fnd_mgt_co_dim --> fct_fms_snpst` (không ngược lại)

---

## Ví dụ 2: Cụm Tác nghiệp — không có Fact, không có Calendar Date

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        FIMS_INVESTOR["FIMS.INVESTOR"]
        FIMS_BANKMONI["FIMS.BANKMONI"]
    end
    subgraph SIL["Atomic"]
        Foreign_Investor["Foreign Investor"]
        Custodian_Bank["Custodian Bank"]
    end
    subgraph GOLD["Datamart"]
        frgn_ivsr_360_prfl["Foreign Investor 360 Profile"]
    end
    FIMS_INVESTOR --> Foreign_Investor
    FIMS_BANKMONI --> Custodian_Bank
    Foreign_Investor --> frgn_ivsr_360_prfl
    Custodian_Bank --> frgn_ivsr_360_prfl
```

**Đặc điểm đúng:**
- Cụm Tác nghiệp: không có Fact → không cần Calendar Date Dimension
- Không có link `Dim --> Tác nghiệp` — Tác nghiệp lấy thẳng từ Atomic
- Subgraph label đúng: `SRC["Staging"]`, `SIL["Atomic"]`, `GOLD["Datamart"]`

---

## Ví dụ 3: Classification Dimension seed từ Classification Value

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        FIMS_INVESTOR["FIMS.INVESTOR"]
        ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end
    subgraph SIL["Atomic"]
        Foreign_Investor["Foreign Investor"]
        Classification_Value["Classification Value"]
        Calendar_Date["Calendar Date"]
    end
    subgraph GOLD["Datamart"]
        fct_frgn_ivsr_rgst["Fact Foreign Investor Registration"]
        ivsr_tp_dim["Investor Type Dimension"]
        cdr_dt_dim["Calendar Date Dimension"]
    end
    FIMS_INVESTOR --> Foreign_Investor
    ECAT_ECAT_29_HolidayInfo --> Calendar_Date
    Foreign_Investor --> fct_frgn_ivsr_rgst
    Classification_Value --> ivsr_tp_dim
    Calendar_Date --> cdr_dt_dim
    ivsr_tp_dim --> fct_frgn_ivsr_rgst
    cdr_dt_dim --> fct_frgn_ivsr_rgst
```

**Đặc điểm đúng:**
- `Classification_Value["Classification Value"]` chỉ trong subgraph Atomic — không có node trong Staging
- Không vẽ nguồn Staging cho Classification Value
