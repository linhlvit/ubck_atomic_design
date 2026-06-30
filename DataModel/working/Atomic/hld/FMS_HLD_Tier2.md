# FMS — HLD Tier 2: Phụ thuộc Tier 1

> **Phụ thuộc Tier 1:** Fund Management Company, Custodian Bank, Fund Distribution Agent, Member Rating Period, Reporting Period
>
> **Thiết kế theo:** [FMS_HLD_Overview.md](FMS_HLD_Overview.md)

---

## 6a. Bảng tổng quan BCV Concept

| BCV Core Object | BCV Concept | Category | Source Table | Source Table Change Mode | Mô tả bảng nguồn | Atomic Entity | Table Type | BCV Term |
|---|---|---|---|---|---|---|---|---|
| Involved Party | [Involved Party] Organization | Organization | BRANCHS | Update | Danh sách CN/VPĐD của công ty QLQ trong nước | Fund Management Company Organization Unit | Fundamental | (1) Term candidate: `Organization` — BCV mô tả đơn vị thuộc tổ chức, FK đến entity cha là Fund Management Company. (2) Cấu trúc trường: BRANCHS có tên, địa chỉ, phone, email, FK đến SECURITIES (SEC_ID) → entity con của Fund Management Company. Grain = 1 CN/VPĐD. (3) Chọn `Organization` — đơn vị địa lý trực thuộc CTQLQ trong nước. |
| Involved Party | [Involved Party] Organization | Organization | FOR_BRCH | Update | Danh sách VPĐD/CN công ty QLQ nước ngoài tại VN | Foreign Fund Management Organization Unit | Fundamental | (1) Term candidate: `Organization` — BCV mô tả đơn vị tổ chức nước ngoài có pháp nhân tại VN. (2) Cấu trúc trường: FOR_BRCH có tên, địa chỉ, phone, FK tự quản, không FK đến SECURITIES → entity độc lập tuy nhiên có STF_FG_BRCH (nhân sự) và FG_BUSINESS (ngành nghề) phụ thuộc. (3) Chọn `Organization` — tổ chức QLQ nước ngoài có hiện diện tại VN. Lưu ý: FOR_BRCH không có FK đến SECURITIES → ở Tier 1 xét về độc lập; tuy nhiên vì nhóm nghiệp vụ thành viên QLQ → đặt Tier 2 cùng BRANCHS để gộp phân tích. |
| Involved Party | [Involved Party] Individual Employment Status | Employment Status | TL_PROFILES | Update | Danh sách nhân sự chủ chốt công ty QLQ | Fund Management Company Key Person | Fundamental | (1) Term candidate: `Individual Employment Status` — BCV mô tả cá nhân đang giữ vị trí trong tổ chức. (2) Cấu trúc trường: TL_PROFILES có họ tên, ngày sinh, giới tính, CCCD, chức vụ (JOB_TYPE FK), ngày bổ nhiệm, ngày thôi → entity nhân sự với lifecycle bổ nhiệm/thôi chức. IP Alt Identification từ CCCD/Hộ chiếu. (3) Chọn `Individual Employment Status`. |
| Arrangement | [Arrangement] Investment Fund | Investment Fund | FUNDS | Update | Danh sách quỹ đầu tư chứng khoán | Investment Fund | Fundamental | (1) Term candidate: `Investment Fund` — BCV mô tả quỹ đầu tư được thành lập và quản lý bởi công ty QLQ. (2) Cấu trúc trường: FUNDS có tên quỹ, mã CCQ (CER_CODE), loại quỹ (FTYPE_ID), vốn điều lệ, NAV, NAV/CCQ, ngày niêm yết, FK đến SECURITIES (công ty QLQ) + BANK_MONI (NH LKGS) → arrangement giữa CTQLQ và NĐT. (3) Chọn `Investment Fund`. |
| Involved Party | [Involved Party] Individual | Individual | INVES | Update | Danh sách nhà đầu tư ủy thác | Discretionary Investment Investor | Fundamental | (1) Term candidate: `Individual` — BCV mô tả cá nhân/tổ chức là nhà đầu tư ủy thác. (2) Cấu trúc trường: INVES có họ tên, CCCD, địa chỉ, FK đến SECURITIES (công ty QLQ nhận ủy thác) → entity NĐT ủy thác với thông tin cá nhân đầy đủ; tách IP Alt Identification. (3) Chọn `Individual`. |
| Involved Party | [Involved Party] Organization | Organization | AGENCIES_BRA | Update | Danh sách CN/PGD của đại lý quỹ đầu tư | Fund Distribution Agent Organization Unit | Fundamental | (1) Term candidate: `Organization` — đơn vị trực thuộc Fund Distribution Agent. (2) Cấu trúc trường: AGENCIES_BRA có tên, địa chỉ, FK đến AGENCIES (đại lý cha) → entity con của Fund Distribution Agent. Có trường địa chỉ → tách IP Postal Address. (3) Chọn `Organization`. |
| Business Activity | [Business Activity] Business Activity | Business Activity | RANK | Append | Bảng xếp hạng theo kỳ đánh giá (1 dòng = 1 kết quả xếp hạng/kỳ) | Member Rating | Fact Append | (1) Term candidate: `Conduct Violation` không phù hợp. Tra lại: kết quả xếp hạng = outcome của một đợt đánh giá — gần `Assessment Result` hơn. (2) Cấu trúc trường: RANK có SEC_ID (FK SECURITIES), RT_PD_ID (FK kỳ đánh giá), TOTAL_SCORE, RANK_INDEX, RANK_TYPE → mỗi dòng = 1 kết quả xếp hạng của 1 CTQLQ trong 1 kỳ, append theo kỳ. (3) Chọn `Business Activity` → Table Type `Fact Append`. |
| Documentation | [Documentation] Gov. Registration Document | Government Registration Document | RPT_MEMBER | Append | Báo cáo định kỳ của thành viên thị trường nộp lên UBCK | Member Periodic Report | Fact Append | (1) Term candidate: `Gov. Registration Document` — báo cáo thành viên nộp theo quy định là tài liệu pháp lý bắt buộc. (2) Cấu trúc trường: RPT_MEMBER có FK đến SECURITIES/FUNDS/BANK_MONI/FOR_BRCH (thành viên nộp), FK RPT_PERIOD (kỳ báo cáo), trạng thái, ngày nộp → mỗi lần nộp là 1 event insert-only. (3) Chọn `Gov. Registration Document` → Fact Append. |

---

## 6b. Diagram Source (Mermaid)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef outscope fill:#fef9c3,stroke:#ca8a04,color:#713f12

    BRANCHS["**BRANCHS**\nCN/VPĐD công ty QLQ trong nước"]:::src
    FOR_BRCH["**FOR_BRCH**\nVPĐD/CN QLQ nước ngoài tại VN"]:::src
    TL_PROFILES["**TL_PROFILES**\nNhân sự chủ chốt QLQ"]:::src
    FUNDS["**FUNDS**\nQuỹ đầu tư chứng khoán"]:::src
    INVES["**INVES**\nNhà đầu tư ủy thác"]:::src
    AGENCIES_BRA["**AGENCIES_BRA**\nCN/PGD đại lý quỹ"]:::src
    RANK["**RANK**\nKết quả xếp hạng"]:::src
    RPT_MEMBER["**RPT_MEMBER**\nBáo cáo định kỳ thành viên"]:::src

    SECURITIES["**SECURITIES** (Tier 1)"]:::outscope
    BANK_MONI["**BANK_MONI** (Tier 1)"]:::outscope
    AGENCIES["**AGENCIES** (Tier 1)"]:::outscope
    RATING_PD["**RATING_PD** (Tier 1)"]:::outscope
    RPT_PERIOD["**RPT_PERIOD** (Tier 1)"]:::outscope

    BRANCHS -->|"SEC_ID"| SECURITIES
    TL_PROFILES -->|"SEC_ID"| SECURITIES
    FUNDS -->|"SEC_ID"| SECURITIES
    FUNDS -->|"BANK_ID"| BANK_MONI
    INVES -->|"SEC_ID"| SECURITIES
    AGENCIES_BRA -->|"AGENCIES_ID"| AGENCIES
    RANK -->|"SEC_ID"| SECURITIES
    RANK -->|"RT_PD_ID"| RATING_PD
    RPT_MEMBER -->|"SEC_ID (nullable)"| SECURITIES
    RPT_MEMBER -->|"FUND_ID (nullable)"| FUNDS
    RPT_MEMBER -->|"BANK_ID (nullable)"| BANK_MONI
    RPT_MEMBER -->|"RPT_PD_ID"| RPT_PERIOD
```

---

## 6c. Diagram Atomic (Mermaid)

```mermaid
graph TD
    classDef atomic fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef shared fill:#fae8ff,stroke:#9333ea,color:#4a044e
    classDef pattern fill:#e2e8f0,stroke:#64748b,color:#1e293b
    classDef outscope fill:#fef9c3,stroke:#ca8a04,color:#713f12

    FMCOU["**Fund Management Company Organization Unit**\n[Involved Party] Organization\nBRANCHES"]:::atomic
    FFMOU["**Foreign Fund Management Organization Unit**\n[Involved Party] Organization\nFORBRCH"]:::atomic
    KP["**Fund Management Company Key Person**\n[Involved Party] Individual Employment Status\nTLProfiles"]:::atomic
    IF["**Investment Fund**\n[Arrangement] Investment Fund\nFUNDS"]:::atomic
    DII["**Discretionary Investment Investor**\n[Involved Party] Individual\nINVES"]:::atomic
    FDAOU["**Fund Distribution Agent Organization Unit**\n[Involved Party] Organization\nAGENCIESBRA"]:::atomic
    MR["**Member Rating**\n[Business Activity] Business Activity\nRANK"]:::pattern
    MPR["**Member Periodic Report**\n[Documentation] Gov. Registration Document\nRPTMEMBER"]:::pattern

    FMC["**Fund Management Company** (Tier 1)"]:::outscope
    CB["**Custodian Bank** (Tier 1)"]:::outscope
    FDA["**Fund Distribution Agent** (Tier 1)"]:::outscope
    MRP_ENT["**Member Rating Period** (Tier 1)"]:::outscope
    RP["**Reporting Period** (Tier 1)"]:::outscope

    ADDR["IP Postal Address"]:::shared
    EADDR["IP Electronic Address"]:::shared
    ALTID["IP Alt Identification"]:::shared

    FMCOU -->|"Fund Management Company FK"| FMC
    ADDR -.->|"shared"| FMCOU
    EADDR -.->|"shared"| FMCOU
    ALTID -.->|"shared"| FMCOU
    ADDR -.->|"shared"| FFMOU
    EADDR -.->|"shared"| FFMOU
    ALTID -.->|"shared"| FFMOU
    KP -->|"Fund Management Company FK"| FMC
    ALTID -.->|"shared"| KP
    IF -->|"Fund Management Company FK"| FMC
    IF -->|"Custodian Bank FK"| CB
    DII -->|"Fund Management Company FK"| FMC
    ALTID -.->|"shared"| DII
    FDAOU -->|"Fund Distribution Agent FK"| FDA
    ADDR -.->|"shared"| FDAOU
    MR -->|"Fund Management Company FK"| FMC
    MR -->|"Member Rating Period FK"| MRP_ENT
    MPR -->|"Fund Management Company FK (nullable)"| FMC
    MPR -->|"Investment Fund FK (nullable)"| IF
    MPR -->|"Custodian Bank FK (nullable)"| CB
    MPR -->|"Reporting Period FK"| RP
```

---

## 6d. Danh mục & Tham chiếu

| Source Table | Mô tả | Scheme Code dự kiến | Ghi chú |
|---|---|---|---|
| FUNDS.FTYPE_ID → FUND_TYPE | Loại quỹ đầu tư | `FMS_FUND_TYPE` | source_table — Values load từ FUND_TYPE.CODE + ITEM_NAME; bảng FUND_TYPE status=pending. |
| RANK.RANK_TYPE | Loại xếp hạng: 1=Cuối năm, 2=Giữa năm | `FMS_RATING_PERIOD_TYPE` | etl_derived — Đã đăng ký Tier 1; tham chiếu lại. |
| RPT_MEMBER.STATUS_ID | Trạng thái báo cáo thành viên | `FMS_REPORT_STATUS` | source_table — FK đến STATUS; dùng chung scheme FMS_OPERATION_STATUS hoặc tạo riêng FMS_REPORT_STATUS. |

---

## 6e. Bảng chờ thiết kế

| Source Table | Mô tả bảng nguồn | Lý do chưa thiết kế |
|---|---|---|
| FOR_BRCH | Danh sách VPĐD/CN công ty QLQ NN tại VN | Tạm đặt Tier 2 — thực tế không FK đến SECURITIES. Cần xác nhận: FOR_BRCH có FK nghiệp vụ nào đến entity Tier 1 không? Nếu không → chuyển về Tier 1. |

---

## 6f. Điểm cần xác nhận

| # | Câu hỏi | Ảnh hưởng |
|---|---|---|
| T2-01 | FOR_BRCH — thực tế không có FK đến SECURITIES trong BRD per-table. FOR_BRCH là entity độc lập (VPĐD/CN QLQ nước ngoài tại VN, không có quan hệ pháp lý FK với SECURITIES trong nước). Xác nhận có nên chuyển lên Tier 1 không? | **Chờ xác nhận.** Nếu FOR_BRCH hoàn toàn không FK đến SECURITIES → chuyển Tier 1. Thiết kế hiện tại giữ Tier 2 để gộp phân tích nhóm thành viên QLQ. |
| T2-02 | RPT_MEMBER FK đến SECURITIES (CTQLQ), FUNDS (quỹ), BANK_MONI (NH LKGS), FOR_BRCH (VPĐD NN) — xác nhận chỉ 1 trong 4 FK này not-null tại 1 thời điểm hay có thể nhiều not-null? | **Chờ xác nhận.** Thiết kế hiện tại cho phép nullable FK để linh hoạt — cần xác nhận nghiệp vụ. |
| T2-03 | MEMBER_PERIODIC_REPORT — BCV Concept `Gov. Registration Document` (báo cáo pháp lý) vs `Business Activity` (hoạt động gửi báo cáo). Cần xác nhận concept phù hợp hơn. | **Chờ xác nhận.** Tạm dùng `Gov. Registration Document` — báo cáo định kỳ theo quy định pháp luật là tài liệu pháp lý. |
| T2-04 | MEMBER_RATING — BCV Concept tạm dùng `Business Activity`. Cần tra lại BCV term chính xác cho kết quả xếp hạng tổ chức giám sát. | **Chờ xác nhận.** Xem xét `Assessment Result` hay `Business Activity`. |
| T2-05 | FG_BUSINESS (ngành nghề FOR_BRCH) và SEC_BUSINESS (ngành nghề SECURITIES) — đều là junction denormalize vào entity cha. Xác nhận: chỉ lưu mảng BUSINESS_TYPE_CODE hay cần thêm ngày hiệu lực? | **Chờ xác nhận.** Nếu chỉ Code → denormalize thành `ARRAY<string>` trên entity cha. Nếu có ngày hiệu lực → cần entity Relative riêng. |
