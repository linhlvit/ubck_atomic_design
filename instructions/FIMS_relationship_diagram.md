# FIMS — Relationship Diagram: Source vs Silver Proposed Model

> **Render:** Mở file này trong VS Code với extension **Markdown Preview Mermaid Support**, hoặc dán từng block vào [mermaid.live](https://mermaid.live).
>
> **Ký hiệu:**
> - `──►` (mũi tên liền): quan hệ FK (Many → One)
> - `-.->` (mũi tên đứt): quan hệ ETL pattern (SCD / Audit Log of)
> - 🔵 Xanh dương: bảng nguồn FIMS (Master)
> - 🟢 Xanh lá: entity Silver / Proposed Model
> - ⬜ Xám: ETL pattern — Snapshot hoặc Audit Log
> - 🟡 Vàng: bảng ngoài scope
> - 🟣 Tím: Shared entity (dùng chung cho mọi Involved Party)

---

## Nhóm 1 — Foreign Investor (Nhà đầu tư nước ngoài)

### Source (FIMS)

> **Multi-way FK (INVESTOR):** `SysObjectType` xác định loại tổ chức nơi NĐT mở TK lưu ký:
> - `SysObjectType=1` → `SecComAddId` (FK → SECURITIESCOMPANY)
> - `SysObjectType=2` → `BankAddId` (FK → BANKMONI)
> Chỉ một trong hai FK non-null tại mỗi bản ghi.

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef outscope fill:#fef9c3,stroke:#ca8a04,color:#713f12

    INVESTOR["**INVESTOR**\nDanh sách Nhà đầu tư nước ngoài"]:::src
    NATIONAL["**NATIONAL**\nQuốc tịch\n(ngoài scope)"]:::outscope
    INVESTORTYPE["**INVESTORTYPE**\nLoại NĐT\n(ngoài scope)"]:::outscope
    SECURITIESCOMPANY["**SECURITIESCOMPANY**\nCông ty chứng khoán\n(ngoài scope)"]:::outscope
    BANKMONI["**BANKMONI**\nNgân hàng lưu ký\n(ngoài scope)"]:::outscope

    INVESTOR -->|NaId| NATIONAL
    INVESTOR -->|InvestorTypeId| INVESTORTYPE
    INVESTOR -->|SecComAddId\nkhi SysObjectType=1| SECURITIESCOMPANY
    INVESTOR -->|BankAddId\nkhi SysObjectType=2| BANKMONI
```

### Silver — Proposed Model

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef shared fill:#fae8ff,stroke:#9333ea,color:#4a044e
    classDef outscope fill:#fef9c3,stroke:#ca8a04,color:#713f12

    FI["**Foreign Investor**\nNhà đầu tư nước ngoài\n(cá nhân hoặc tổ chức)"]:::silver
    ADDR["**Involved Party Postal Address**\nĐịa chỉ bưu chính\n(dùng chung)"]:::shared
    EADDR["**Involved Party Electronic Address**\nĐiện thoại / Fax / Email / Website\n(dùng chung)"]:::shared
    ALTID["**Involved Party Alternative Identification**\nCCCD / Hộ chiếu / GPKD\n(dùng chung)"]:::shared
    NAT["**ref: Nationality**\n(ngoài scope)"]:::outscope
    INVTYPE["**ref: Investor Type**\n(ngoài scope)"]:::outscope

    FI --> ADDR
    FI --> EADDR
    FI --> ALTID
    FI --> NAT
    FI --> INVTYPE
```

> **Shared Entities (tím):** `Involved Party Postal Address`, `Involved Party Electronic Address`, `Involved Party Alternative Identification` — dùng chung cho mọi Involved Party entity trong Silver.
>
> **Multi-way FK normalize:** `SysObjectType + SecComAddId/BankAddId` → ETL chuẩn hóa thành `Custodian Type Code + Custodian Identifier` trong `Foreign Investor`.
>
> **Involved Party Type (ObjectType):** 1=Cá nhân / 2=Tổ chức → map sang INDIVIDUAL / ORGANIZATION. Một số attributes chỉ áp dụng cho một loại (Sex/DateOfBirth → cá nhân; BusinessNumber/Director → tổ chức).

---

## Nhóm 2 — Market Member Report (Báo cáo thành viên thị trường)

### Source (FIMS)

> **Multi-way FK (RPTMEMBER):** `ObjectType` xác định loại tổ chức nộp báo cáo:
> - 1=CTQLQ → `FundId` (FK → FUNDCOMPANY)
> - 2=CTCK → `SecId` (FK → SECURITIESCOMPANY)
> - 3=NHlưuký → `BankId` (FK → BANKMONI)
> - 4=VSDC → `DepId` (FK → DEPOSITORYCENTER)
> - 5=SởGD → `StockId` (FK → STOCKEXCHANGE)
> - 6=CBTT → `InId` (FK → INFODISCREPRES)
> - 7=CN QLQ NN → `BranId` (FK → BRANCHS)
> Chỉ một FK non-null tại mỗi bản ghi.

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef outscope fill:#fef9c3,stroke:#ca8a04,color:#713f12

    RPTMEMBER["**RPTMEMBER**\nDanh sách báo cáo về NĐT NN\ncủa các thành viên thị trường"]:::src
    RPTVALUES["**RPTVALUES**\nGiá trị báo cáo sau import\n(EAV)"]:::src
    RPTTEMP["**RPTTEMP**\nBiểu mẫu báo cáo\n(ngoài scope)"]:::outscope
    RPTPERIOD["**RPTPERIOD**\nKỳ báo cáo\n(ngoài scope)"]:::outscope
    REPORTTYPE["**REPORTTYPE**\nLoại báo cáo\n(ngoài scope)"]:::outscope
    SHEET["**SHEET**\nSheet báo cáo\n(ngoài scope)"]:::outscope
    MEMBERS["**FUNDCOMPANY / SECURITIESCOMPANY\n/ BANKMONI / DEPOSITORYCENTER\n/ STOCKEXCHANGE / INFODISCREPRES / BRANCHS**\n(ngoài scope)"]:::outscope

    RPTVALUES -->|MebId| RPTMEMBER
    RPTMEMBER -->|RptId| RPTTEMP
    RPTMEMBER -->|PrdId| RPTPERIOD
    RPTMEMBER -->|ReportTypeId| REPORTTYPE
    RPTMEMBER -->|FundId/SecId/BankId\nDepId/StockId/InId/BranId\ntheo ObjectType| MEMBERS
    RPTVALUES -->|SheetId| SHEET
```

### Silver — Proposed Model

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef outscope fill:#fef9c3,stroke:#ca8a04,color:#713f12

    MMRS["**Market Member Report Submission**\nMột lần nộp báo cáo của\nthành viên thị trường"]:::silver
    MMRIV["**Market Member Report Item Value**\nGiá trị từng ô báo cáo\n(EAV)"]:::silver
    RPTTEMP["**ref: Regulatory Report Template**\n(ngoài scope)"]:::outscope
    PERIOD["**ref: Reporting Period**\n(ngoài scope)"]:::outscope
    RPTTYPE["**ref: Report Type**\n(ngoài scope)"]:::outscope
    SHEET["**ref: Report Sheet**\n(ngoài scope)"]:::outscope
    MEMBER["**ref: Reporting Member**\n(CTQLQ/CTCK/NH lưu ký/VSDC\n/SởGD/CBTT/CN QLQ NN)"]:::outscope

    MMRIV -->|MebId| MMRS
    MMRS --> RPTTEMP
    MMRS --> PERIOD
    MMRS --> RPTTYPE
    MMRS --> MEMBER
    MMRIV --> SHEET
```

> **Multi-way FK normalize (RPTMEMBER → Silver):**
> ```
> Reporting_Member_Identifier = COALESCE(FundId, SecId, BankId, DepId, StockId, InId, BranId)
> Reporting_Member_Type_Code  = ObjectType
> ```
>
> **Redundant FK trong RPTVALUES:** PrdId, RptId, Type, PeriodType, PeriodValue, FundId...BranId — không đưa vào Silver, lấy qua JOIN với Market Member Report Submission (MebId).
>
> **FIMS-specific EAV metadata:** `TableName / FieldName / Identification / TgtId` — đặc thù FIMS, nullable khi merge với FMS.RPTVALUES ở tầng Gold.

---

## Tổng quan theo BCV Concept

| BCV Concept | Source Tables | Silver Entities |
|---|---|---|
| **[Involved Party] — Investor** | INVESTOR | Foreign Investor |
| **[Involved Party] — Involved Party Type** | INVESTOR.ObjectType | *(attribute của Foreign Investor)* |
| **[Involved Party] — Involved Party Alternative Identification** | INVESTOR (IdNo, IdDate, IdAdd, BusinessNumber) | Involved Party Alternative Identification |
| **[Location] — Postal Address** | INVESTOR.Address | Involved Party Postal Address |
| **[Location] — Electronic Address** | INVESTOR (Telephone, Fax, Email, Website) | Involved Party Electronic Address |
| **[Involved Party] — Involved Party Life Cycle Status** | INVESTOR.StatusId | *(attribute của Foreign Investor)* |
| **[Documentation] — Regulatory Report** | RPTMEMBER | Market Member Report Submission |
| **[Documentation] — Regulatory Report Type** | RPTMEMBER.RptId → RPTTEMP | *(FK attribute)* |
| **[Common] — Reported Status** | RPTMEMBER.Status | *(attribute của Market Member Report Submission)* |
| **[Communication] — Response Deadline Date** | RPTMEMBER.DeadlineSend | *(attribute của Market Member Report Submission)* |
| **[Documentation] — Submission Date** | RPTMEMBER.DateSubmitted | *(attribute của Market Member Report Submission)* |
| **[Common] — Time Period Type** | RPTMEMBER.PeriodType | *(attribute của Market Member Report Submission)* |
| **[Documentation] — Reported Information** | RPTVALUES | Market Member Report Item Value |
| **[Condition] — Format Type** | RPTVALUES.FormatDataType | *(attribute của Market Member Report Item Value)* |
