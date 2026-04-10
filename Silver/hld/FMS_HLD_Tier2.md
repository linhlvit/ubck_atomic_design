# FMS — HLD Tầng 2: Phụ thuộc Main Entities

> **Nguồn:** Thiết kế CSDL FMS — Phân hệ quản lý giám sát công ty chứng khoán và quỹ đầu tư chứng khoán (20/03/2026)
>
> **Phạm vi:** Bảng có FK đến ít nhất 1 main entity Tầng 1 (SECURITIES, FORBRCH, BANKMONI, AGENCIES, INVES, RPTPERIOD, RATINGPD).
>
> **Entity tham chiếu (Tầng 1):** Fund Management Company, Foreign Fund Management Organization Unit, Custodian Bank, Fund Distribution Agent, Discretionary Investment Investor, Reporting Period, Member Rating Period.
>
> **Ký hiệu:**
> - 🔵 Xanh dương: bảng nguồn FMS
> - 🟢 Xanh lá: entity Silver mới (Tầng 2)
> - ⬜ Xám: entity Silver tham chiếu (Tầng 1 — chỉ ghi tên)
> - 🟣 Tím: Shared entity

---

## 1. FUNDS — FMS Investment Fund

### Source (FMS)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef ref fill:#f3f4f6,stroke:#9ca3af,color:#6b7280

    SECURITIES["**SECURITIES**\nCông ty QLQ (Tầng 1)"]:::ref
    STATUS["STATUS (Danh mục)"]:::ref
    FUNDS["**FUNDS**\nDanh sách quỹ đầu tư\nchứng khoán (17 trường)"]:::src

    FUNDS -->|SecId| SECURITIES
    FUNDS -->|Status| STATUS
```

**Trường chính:** FundName, FundShortName, FundEnName, SecId (FK→SECURITIES), FundCapital, FundType, Status (FK→STATUS), DecisionDate, ActiveDate, StopDate.

### Silver — Proposed Model

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef shared fill:#fae8ff,stroke:#9333ea,color:#4a044e
    classDef refnode fill:#f3f4f6,stroke:#9ca3af,color:#6b7280

    FMC["Fund Management Company (Tầng 1)"]:::refnode
    FUND["**FMS Investment Fund**\nQuỹ đầu tư chứng khoán"]:::silver
    ALTID["**IP Alt Identification**\nGP thành lập quỹ (dùng chung)"]:::shared

    FUND -->|FK| FMC
    FUND --> ALTID
```

| Hạng mục | Nội dung |
|---|---|
| Silver Entity | FMS Investment Fund |
| BCV Concept | [Involved Party] Organization |
| Model Table Type | Fundamental (SCD4A) |
| Grain | 1 dòng = 1 quỹ đầu tư chứng khoán (pháp nhân) |
| FK đến Tầng 1 | Fund Management Company (SecId) |
| Shared Entities | IP Alt Identification (DecisionDate — GP thành lập quỹ) |

> **Lưu ý:** FundType → Classification Value. FUNDS không có Address/Phone/Email → không tách IP Postal/Electronic Address. Entity trung tâm Tầng 2 — được MBFUND, AGENFUNDS, FNDSBMN, REPRESENT, RPTMEMBER, VIOLT reference.

---

## 2. BRANCHES — FMS Fund Management Company Organization Unit

### Source (FMS)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef ref fill:#f3f4f6,stroke:#9ca3af,color:#6b7280

    SECURITIES["**SECURITIES**\nCông ty QLQ (Tầng 1)"]:::ref
    TL_ref["**TLProfiles**\nNhân sự QLQ (Tầng 2)"]:::ref
    STATUS["STATUS (Danh mục)"]:::ref
    BRANCHES["**BRANCHES**\nDanh sách CN/VPĐD\ncông ty QLQ trong nước (25 trường)"]:::src

    BRANCHES -->|SecId| SECURITIES
    BRANCHES -->|TLId| TL_ref
    BRANCHES -->|Status| STATUS
```

**Trường chính:** SecId (FK→SECURITIES), Name, Address, Telephone, Fax, BrType (1=CN; 4=VPĐD), BrIdowner (CN/VPĐD cha), Decision (GP thành lập), DecisionDate, Status, StopDate, TLId (FK→TLProfiles), VoucherNo, VoucherDate.

> **Dependency nội bộ Tầng 2:** BRANCHES có FK đến TLProfiles — thiết kế TLProfiles trước (mục 3).

### Silver — Proposed Model

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef shared fill:#fae8ff,stroke:#9333ea,color:#4a044e
    classDef refnode fill:#f3f4f6,stroke:#9ca3af,color:#6b7280

    FMC["Fund Management Company (Tầng 1)"]:::refnode
    KP["FMS Fund Company Key Person (Tầng 2)"]:::refnode
    OU["**FMS Fund Management Company\nOrganization Unit**\nCN/VPĐD công ty QLQ trong nước"]:::silver
    ADDR["**IP Postal Address** (dùng chung)"]:::shared
    EADDR["**IP Electronic Address** (dùng chung)"]:::shared
    ALTID["**IP Alt Identification**\nGP thành lập CN/VPĐD (dùng chung)"]:::shared

    OU -->|FK| FMC
    OU -->|FK người đại diện| KP
    OU -->|self-FK cha/con| OU
    OU --> ADDR
    OU --> EADDR
    OU --> ALTID
```

| Hạng mục | Nội dung |
|---|---|
| Silver Entity | FMS Fund Management Company Organization Unit |
| BCV Concept | [Involved Party] Organization Unit |
| Model Table Type | Fundamental (SCD4A) |
| Grain | 1 dòng = 1 đơn vị trực thuộc công ty QLQ trong nước (CN hoặc VPĐD) |
| FK đến Tầng 1 | Fund Management Company (SecId) |
| FK đến Tầng 2 | FMS Fund Company Key Person (TLId — người đại diện) |
| Self-FK | BrIdowner → FMS Fund Management Company Organization Unit (đơn vị cha) |
| Shared Entities | IP Postal Address (Address), IP Electronic Address (Telephone, Fax), IP Alt Identification (Decision) |

> **Lưu ý:** BrType (1=CN; 4=VPĐD) → Classification Value. Bảng chứa nhiều loại đơn vị → đặt hậu tố "Organization Unit" thay vì "Branch".

---

## 3. TLProfiles — FMS Fund Company Key Person

### Source (FMS)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef ref fill:#f3f4f6,stroke:#9ca3af,color:#6b7280

    SECURITIES["**SECURITIES**\nCông ty QLQ (Tầng 1)"]:::ref
    NATIONAL["NATIONAL (Danh mục)"]:::ref
    JOBTYPE["JOBTYPE (Danh mục)"]:::ref
    TLProfiles["**TLProfiles**\nDanh sách nhân sự\ncông ty QLQ (13 trường)"]:::src

    TLProfiles -->|SecId| SECURITIES
    TLProfiles -->|NatId| NATIONAL
    TLProfiles -->|JobTypeId| JOBTYPE
```

**Trường chính:** SecId (FK→SECURITIES), FullName, BirthDate, NatId (FK→NATIONAL), IdNo, JobTypeId (FK→JOBTYPE), IsLegal, IsCBTT.

### Silver — Proposed Model

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef shared fill:#fae8ff,stroke:#9333ea,color:#4a044e
    classDef refnode fill:#f3f4f6,stroke:#9ca3af,color:#6b7280

    FMC["Fund Management Company (Tầng 1)"]:::refnode
    KP["**FMS Fund Company Key Person**\nNhân sự chủ chốt công ty QLQ"]:::silver
    ALTID["**IP Alt Identification**\nCMND/CCCD/Hộ chiếu (dùng chung)"]:::shared

    KP -->|FK| FMC
    KP --> ALTID
```

| Hạng mục | Nội dung |
|---|---|
| Silver Entity | FMS Fund Company Key Person |
| BCV Concept | [Involved Party] Individual |
| Model Table Type | Fundamental (SCD4A) |
| Grain | 1 dòng = 1 cá nhân nhân sự chủ chốt của công ty QLQ |
| FK đến Tầng 1 | Fund Management Company (SecId) |
| Shared Entities | IP Alt Identification (IdNo — CMND/CCCD/Hộ chiếu) |

> **Lưu ý:** JobTypeId → Classification Value. IsLegal, IsCBTT là Indicator, giữ nguyên trên Silver.

---

## 4. AGENCIESBRA — FMS Fund Distribution Agent Organization Unit

### Source (FMS)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef ref fill:#f3f4f6,stroke:#9ca3af,color:#6b7280

    AGENCIES["**AGENCIES**\nĐại lý quỹ (Tầng 1)"]:::ref
    AGENCIESBRA["**AGENCIESBRA**\nDanh sách CN/PGD\nđại lý quỹ đầu tư (8 trường)"]:::src

    AGENCIESBRA -->|AgnId| AGENCIES
```

**Trường chính:** AgnId (FK→AGENCIES), Name, Address, Status.

### Silver — Proposed Model

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef shared fill:#fae8ff,stroke:#9333ea,color:#4a044e
    classDef refnode fill:#f3f4f6,stroke:#9ca3af,color:#6b7280

    FDA["Fund Distribution Agent (Tầng 1)"]:::refnode
    AGOU["**FMS Fund Distribution Agent\nOrganization Unit**\nCN/PGD đại lý phân phối quỹ"]:::silver
    ADDR["**IP Postal Address** (dùng chung)"]:::shared

    AGOU -->|FK| FDA
    AGOU --> ADDR
```

| Hạng mục | Nội dung |
|---|---|
| Silver Entity | FMS Fund Distribution Agent Organization Unit |
| BCV Concept | [Involved Party] Organization Unit |
| Model Table Type | Fundamental (SCD4A) |
| Grain | 1 dòng = 1 đơn vị trực thuộc đại lý phân phối quỹ (CN hoặc PGD) |
| FK đến Tầng 1 | Fund Distribution Agent (AgnId) |
| Shared Entities | IP Postal Address (Address) |

> **Lưu ý:** Bảng chứa cả CN lẫn PGD → đặt hậu tố "Organization Unit" thay vì "Branch".

---

## 5. INVESACC — FMS Discretionary Investment Account

### Source (FMS)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef ref fill:#f3f4f6,stroke:#9ca3af,color:#6b7280

    INVES["**INVES**\nNhà đầu tư ủy thác (Tầng 1)"]:::ref
    INVESACC["**INVESACC**\nDanh sách tài khoản\nnhà đầu tư ủy thác (10 trường)"]:::src

    INVESACC -->|InvesId| INVES
```

**Trường chính:** InvesId (FK→INVES), Account, AccPlace, ContractNo, ActScale, AdScale, ManagerFee, Status, DateReport.

### Silver — Proposed Model

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef refnode fill:#f3f4f6,stroke:#9ca3af,color:#6b7280

    DII["Discretionary Investment Investor (Tầng 1)"]:::refnode
    IACC["**FMS Discretionary Investment Account**\nHợp đồng ủy thác quản lý danh mục"]:::silver

    IACC -->|FK| DII
```

| Hạng mục | Nội dung |
|---|---|
| Silver Entity | FMS Discretionary Investment Account |
| BCV Concept | [Arrangement] Financial Portfolio Management Arrangement |
| Model Table Type | Fundamental (SCD4A) |
| Grain | 1 dòng = 1 hợp đồng ủy thác quản lý danh mục của 1 NĐT |
| FK đến Tầng 1 | Discretionary Investment Investor (InvesId) |

> **Lưu ý:** ManagerFee là phí theo điều khoản hợp đồng — không phải phí thực tế phát sinh (Transaction). AccPlace (nơi lưu ký) → cần xác nhận có FK đến Custodian Bank không.

---

## 6. RANK — FMS Member Rating

### Source (FMS)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef ref fill:#f3f4f6,stroke:#9ca3af,color:#6b7280

    SECURITIES["**SECURITIES**\nCông ty QLQ (Tầng 1)"]:::ref
    RATINGPD["**RATINGPD**\nKỳ đánh giá (Tầng 1)"]:::ref
    RANK["**RANK**\nBảng xếp hạng\ntheo kỳ đánh giá (8 trường)"]:::src

    RANK -->|SecId| SECURITIES
    RANK -->|RatingPdId| RATINGPD
```

**Trường chính:** SecId (FK→SECURITIES), RatingPdId (FK→RATINGPD), TotalScore, RankValue, RankClass.

### Silver — Proposed Model

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef refnode fill:#f3f4f6,stroke:#9ca3af,color:#6b7280

    FMC["Fund Management Company (Tầng 1)"]:::refnode
    MRP["Member Rating Period (Tầng 1)"]:::refnode
    RATING["**FMS Member Rating**\nKết quả xếp hạng thành viên theo kỳ"]:::silver

    RATING -->|FK| FMC
    RATING -->|FK| MRP
```

| Hạng mục | Nội dung |
|---|---|
| Silver Entity | FMS Member Rating |
| BCV Concept | [Involved Party] Involved Party Rating |
| Model Table Type | Fundamental (SCD1) |
| Grain | 1 dòng = 1 kết quả xếp hạng của 1 công ty QLQ trong 1 kỳ đánh giá |
| FK đến Tầng 1 | Fund Management Company (SecId) + Member Rating Period (RatingPdId) |

---

## 7. RNKFACTOR — FMS Rating Criterion

### Source (FMS)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f

    RNKFACTOR["**RNKFACTOR**\nBảng chấm điểm đánh giá xếp loại\n(nhân tố cha/con) (7 trường)"]:::src
    RNKFACTOR -->|ParentId self-FK| RNKFACTOR
```

**Trường chính:** Name, ParentId (self-FK), MaxScore, Weight, IsActive.

### Silver — Proposed Model

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d

    RC["**FMS Rating Criterion**\nNhân tố chấm điểm đánh giá\n(cây cha/con)"]:::silver
    RC -->|self-FK cha| RC
```

| Hạng mục | Nội dung |
|---|---|
| Silver Entity | FMS Rating Criterion |
| BCV Concept | [Condition] Criterion |
| Model Table Type | Fundamental (SCD1) |
| Grain | 1 dòng = 1 nhân tố chấm điểm (cha hoặc con) |
| Self-FK | ParentId → FMS Rating Criterion (nhân tố cha) |

> **Lưu ý:** Không FK đến entity Tầng 1, nhưng được RNKGRFTOR (Tầng 3) reference — đặt Tầng 2 để Tầng 3 có thể tham chiếu. ParentId trên Silver là self-FK surrogate.

---

## 8. SECBUSINES & FGBUSINESS — Pure Junction Table (không tạo entity Silver)

SECBUSINES = (SecId, BuId) và FGBUSINESS = (FrBchId, BuId) — mỗi bảng chỉ có 2 trường nghiệp vụ: 1 FK đến entity chính, 1 FK đến bảng danh mục BUSINESS (Classification Value). Không có attribute nghiệp vụ riêng.

→ Áp dụng quy tắc pure junction table: **không tạo Silver entity**. Denormalize thành trường `Array` trên entity chính.

| Source Table | Entity chính | Xử lý trên Silver |
|---|---|---|
| SECBUSINES | Fund Management Company | Thêm trường `business_type_codes ARRAY<STRING>` — danh sách mã ngành nghề kinh doanh |
| FGBUSINESS | Foreign Fund Management Organization Unit | Thêm trường `business_type_codes ARRAY<STRING>` — danh sách mã ngành nghề kinh doanh |

---

## 6a. Tổng quan BCV Concept — Tầng 2

| BCV Concept | Category | Source Table | Mô tả bảng nguồn | Silver Entity | BCV Term |
|---|---|---|---|---|---|
| [Involved Party] Organization | Involved Party | FUNDS | Danh sách quỹ đầu tư chứng khoán | FMS Investment Fund | Candidate: Mutual Fund (id 10089, Group) — *"collective investment scheme that pools money."* Tuy nhiên FundCapital (vốn điều lệ), DecisionDate (GP thành lập), ActiveDate, StopDate mang đặc tính pháp nhân — quỹ VN có tư cách pháp lý độc lập. BCV Mutual Fund mô tả góc nhìn tài sản, không khớp cấu trúc. Chọn Organization (id 10894): *"Identifies an Involved Party that may stand alone in an operational or legal context."* |
| [Involved Party] Organization Unit | Involved Party | BRANCHES | Danh sách CN/VPĐD công ty QLQ trong nước | FMS Fund Management Company Organization Unit | Candidate: Organization Unit (id 11192) — *"A component or subdivision of an Organization established for the purpose of performing discrete functional responsibilities. For example, Branch Office #24."* Cấu trúc trường: có Address/Telephone/Fax riêng, GP riêng (Decision), vòng đời riêng (StopDate), FK đến tổ chức cha (SecId). Khớp chính xác. Tên dùng hậu tố Organization Unit vì bảng chứa cả CN lẫn VPĐD. |
| [Involved Party] Individual | Involved Party | TLProfiles | Danh sách nhân sự công ty QLQ | FMS Fund Company Key Person | Candidate: Individual (id 10902) — *"Identifies an Involved Party who is a natural person."* Cấu trúc trường: FullName, BirthDate, IdNo — đặc trưng thể nhân. Khớp chính xác. |
| [Involved Party] Organization Unit | Involved Party | AGENCIESBRA | Danh sách CN/PGD của đại lý quỹ đầu tư | FMS Fund Distribution Agent Organization Unit | Candidate: Organization Unit (id 11192) — cùng pattern với BRANCHES. Cấu trúc trường: Name, Address, FK đến đại lý cha (AgnId). Khớp chính xác. Tên dùng hậu tố Organization Unit vì bảng chứa cả CN lẫn PGD. |
| [Arrangement] Financial Portfolio Management Arrangement | Arrangement | INVESACC | Danh sách tài khoản nhà đầu tư ủy thác | FMS Discretionary Investment Account | Candidate: Financial Portfolio Management Arrangement — *"Identifies a service of managing of financial portfolio."* Cấu trúc trường: ContractNo (số HĐ), ActScale/AdScale (quy mô vốn cam kết và thực tế), ManagerFee (phí theo HĐ), Status (còn/hết hiệu lực) — đặc trưng hợp đồng dịch vụ. Khớp chính xác. |
| [Involved Party] Involved Party Rating | Involved Party | RANK | Bảng xếp hạng theo kỳ đánh giá | FMS Member Rating | Candidate ban đầu: Performance Rating (id 10096, Group) — *"Identifies a Rating Scale."* Tuy nhiên cấu trúc trường: TotalScore, RankValue, RankClass là kết quả cụ thể gán cho từng QLQ theo kỳ — không phải định nghĩa thang đo. Chọn Involved Party Rating (id 10360): *"Identifies a relationship in which a Rating Scale applies to an Involved Party."* Term này nằm trong category Group nhưng nội dung mô tả quan hệ với Involved Party → BCV Concept = [Involved Party], không phải [Group]. |
| [Condition] Criterion | Condition | RNKFACTOR | Bảng chấm điểm đánh giá xếp loại (nhân tố cha/con) | FMS Rating Criterion | Candidate ban đầu: Arrangement Performance Criterion — gắn với đánh giá thực hiện nghĩa vụ của Arrangement cụ thể. Cấu trúc trường: Name, MaxScore, Weight, IsActive — tiêu chí và trọng số tĩnh, không gắn Arrangement nào. Chọn Criterion (id 8945): *"Identifies a Condition that specifies a characteristic used as a basis of judgment."* Khớp chính xác. |

---

## 6b. Diagram Source — Tầng 2

```mermaid
graph TD
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef ref fill:#f3f4f6,stroke:#9ca3af,color:#6b7280
    classDef dim fill:#fef9c3,stroke:#ca8a04,color:#713f12

    SECURITIES["SECURITIES (Tầng 1)"]:::ref
    FORBRCH["FORBRCH (Tầng 1)"]:::ref
    AGENCIES["AGENCIES (Tầng 1)"]:::ref
    INVES["INVES (Tầng 1)"]:::ref
    RATINGPD["RATINGPD (Tầng 1)"]:::ref

    STATUS["STATUS (Danh mục)"]:::dim
    NATIONAL["NATIONAL (Danh mục)"]:::dim
    JOBTYPE["JOBTYPE (Danh mục)"]:::dim
    BUSINESS["BUSINESS (Danh mục)"]:::dim

    FUNDS["**FUNDS**\nQuỹ đầu tư"]:::src
    BRANCHES["**BRANCHES**\nCN/VPĐD QLQ trong nước"]:::src
    TLProfiles["**TLProfiles**\nNhân sự QLQ"]:::src
    AGENCIESBRA["**AGENCIESBRA**\nCN/PGD đại lý quỹ"]:::src
    INVESACC["**INVESACC**\nTK NĐT ủy thác"]:::src
    RANK["**RANK**\nBảng xếp hạng"]:::src
    RNKFACTOR["**RNKFACTOR**\nNhân tố chấm điểm"]:::src
    SECBUSINES["SECBUSINES (bridge)"]:::src
    FGBUSINESS["FGBUSINESS (bridge)"]:::src

    FUNDS -->|SecId| SECURITIES
    FUNDS -->|Status| STATUS
    BRANCHES -->|SecId| SECURITIES
    BRANCHES -->|TLId| TLProfiles
    BRANCHES -->|Status| STATUS
    TLProfiles -->|SecId| SECURITIES
    TLProfiles -->|NatId| NATIONAL
    TLProfiles -->|JobTypeId| JOBTYPE
    AGENCIESBRA -->|AgnId| AGENCIES
    INVESACC -->|InvesId| INVES
    RANK -->|SecId| SECURITIES
    RANK -->|RatingPdId| RATINGPD
    RNKFACTOR -->|ParentId| RNKFACTOR
    SECBUSINES -->|SecId| SECURITIES
    SECBUSINES -->|BuId| BUSINESS
    FGBUSINESS -->|FrBchId| FORBRCH
    FGBUSINESS -->|BuId| BUSINESS
```

---

## 6c. Diagram Silver — Tầng 2

```mermaid
graph TD
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef shared fill:#fae8ff,stroke:#9333ea,color:#4a044e
    classDef refnode fill:#f3f4f6,stroke:#9ca3af,color:#6b7280

    FMC["Fund Management Company"]:::refnode
    FDA["Fund Distribution Agent"]:::refnode
    DII["Discretionary Investment Investor"]:::refnode
    MRP["Member Rating Period"]:::refnode

    ADDR["IP Postal Address"]:::shared
    EADDR["IP Electronic Address"]:::shared
    ALTID["IP Alt Identification"]:::shared

    FUND["**FMS Investment Fund**"]:::silver
    OU["**FMS Fund Management Company\nOrganization Unit**"]:::silver
    KP["**FMS Fund Company Key Person**"]:::silver
    AGOU["**FMS Fund Distribution Agent\nOrganization Unit**"]:::silver
    IACC["**FMS Discretionary Investment Account**"]:::silver
    RATING["**FMS Member Rating**"]:::silver
    RC["**FMS Rating Criterion**"]:::silver

    FUND -->|FK| FMC
    OU -->|FK| FMC
    KP -->|FK| FMC
    AGOU -->|FK| FDA
    IACC -->|FK| DII
    RATING -->|FK| FMC
    RATING -->|FK| MRP

    OU -->|FK người đại diện| KP
    OU -->|self-FK cha/con| OU
    RC -->|self-FK cha| RC

    FUND --> ALTID
    OU --> ADDR
    OU --> EADDR
    OU --> ALTID
    AGOU --> ADDR
    KP --> ALTID
```

---

## 6d. Danh mục & Tham chiếu (Reference Data → Classification Value)

| Source Table | Mô tả | Xử lý Silver |
|---|---|---|
| JOBTYPE | Danh sách loại chức vụ | → Classification Value |
| BUSINESS | Danh mục ngành nghề kinh doanh | → Classification Value |
| LOCATION | Danh sách tỉnh/thành phố | → Classification Value |
| PARVALUE | Danh sách mệnh giá cổ phần | → Classification Value (nếu cần trong scope) |

---

## 6e. Bảng chờ thiết kế

| Source Table | Mô tả bảng nguồn | Lý do chưa thiết kế |
|---|---|---|
| FNDBUP | Bản ghi chi tiết lịch sử quỹ đầu tư | Chưa có thông tin cột |
| RNKGRFTOR | Bảng trung gian Ranks và RNKFACTOR | Chưa có thông tin cột |
| RNKFACTHISTORY | Lưu kết quả các lần lưu bảng tổng hợp đánh giá | Chưa có thông tin cột |

---

## 6f. Điểm cần xác nhận

| # | Câu hỏi | Ảnh hưởng |
|---|---|---|
| 1 | INVESACC.AccPlace (nơi lưu ký) — có phải FK đến BANKMONI không? | Nếu có → thêm FK từ FMS Discretionary Investment Account đến Custodian Bank (Tầng 1) |
| 2 | BRANCHES.BrIdowner — giá trị là Id nguồn hay text? | Ảnh hưởng thiết kế self-FK surrogate trên Silver |
| 3 | TLProfiles — nhân sự có thể thuộc nhiều công ty QLQ qua thời gian không? | Nếu có → grain cần review, có thể cần tách role khỏi entity |
