# FMS — Relationship Diagram: Source vs Silver Proposed Model

> **Render:** Mở file này trong VS Code với extension **Markdown Preview Mermaid Support**, hoặc dán từng block vào [mermaid.live](https://mermaid.live).
>
> **Ký hiệu:**
> - `──►` (mũi tên liền): quan hệ FK (Many → One)
> - `-.->` (mũi tên đứt): quan hệ ETL pattern (SCD / Audit Log of)
> - 🔵 Xanh dương: bảng nguồn FMS (Master)
> - 🟢 Xanh lá: entity Silver / Proposed Model
> - ⬜ Xám: ETL pattern — Snapshot hoặc Audit Log
> - 🟡 Vàng: bảng ngoài scope
> - 🟣 Tím: Shared entity (dùng chung cho mọi Involved Party)

---

## Nhóm 1 — Fund Management Company & cổ đông, bên liên quan

### Source (FMS)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef pattern fill:#e2e8f0,stroke:#64748b,color:#1e293b

    SECURITIES["**SECURITIES**\nDanh sách công ty quản lý quỹ"]:::src
    SECBUP["**SECBUP**\nLịch sử chi tiết công ty QLQ\n[SCD]"]:::pattern
    SECHISTORY["**SECHISTORY**\nLịch sử thay đổi công ty QLQ\nvà chi nhánh\n[Audit Log]"]:::pattern
    INSIDER["**INSIDER**\nCổ đông công ty QLQ"]:::src
    INSDERRELA["**INSDERRELA**\nNgười liên quan của cổ đông"]:::src
    INSDERRPRST["**INSDERRPRST**\nNgười đại diện cổ đông"]:::src
    INSIDCHANGE["**INSIDCHANGE**\nLịch sử thay đổi vốn góp cổ đông"]:::src
    STAKE["**STAKE**\nCác bên liên quan công ty QLQ"]:::src

    INSIDER -->|ScId| SECURITIES
    INSDERRELA -->|InsderId| INSIDER
    INSDERRPRST -->|InsdrId| INSIDER
    INSIDCHANGE -->|InsdrId| INSIDER
    STAKE -->|SecurityId| SECURITIES
    SECHISTORY -->|SecId| SECURITIES
    SECBUP -->|SecHsId| SECHISTORY
```

### Silver — Proposed Model

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef pattern fill:#e2e8f0,stroke:#64748b,color:#1e293b
    classDef shared fill:#fae8ff,stroke:#9333ea,color:#4a044e

    FMC["**Fund Management Company**\nCông ty quản lý quỹ đầu tư"]:::silver
    FMC_SNAP["**Fund Management Company Snapshot**\nẢnh chụp toàn trạng thái\ncông ty QLQ [SCD]"]:::pattern
    FMC_ORG_AL["**FMC Organization Unit Audit Log**\nLịch sử thay đổi công ty QLQ\nhoặc chi nhánh QLQ [Audit Log]"]:::pattern
    FMC_SHR["**FMC Shareholder**\nCổ đông nắm vốn góp\ntrong công ty QLQ"]:::silver
    FMC_SHR_REL["**FMC Shareholder Relationship**\nQuan hệ liên quan của cổ đông QLQ"]:::silver
    FMC_SHR_REPR["**FMC Shareholder Representative**\nNgười đại diện ủy quyền\ncổ đông QLQ"]:::silver
    FMC_SHR_OWN["**FMC Shareholder Ownership Change**\nLịch sử biến động vốn góp\ncổ đông QLQ"]:::silver
    FMC_ORG_REL["**FMC Organization Relationship**\nQuan hệ bên liên quan / liên đới\ncông ty QLQ"]:::silver
    ADDR["**Involved Party Postal Address**\nĐịa chỉ bưu chính\n(dùng chung)"]:::shared
    EADDR["**Involved Party Electronic Address**\nĐiện thoại / Fax / Email / Website\n(dùng chung)"]:::shared
    ALTID["**Involved Party Alternative Identification**\nGiấy phép / ĐKDN / CMND / ...\n(dùng chung)"]:::shared

    FMC_SHR --> FMC
    FMC_SHR_REL --> FMC_SHR
    FMC_SHR_REPR --> FMC_SHR
    FMC_SHR_OWN --> FMC_SHR
    FMC_ORG_REL --> FMC
    FMC_SNAP -.->|SCD of| FMC
    FMC_ORG_AL -.->|Audit Log of| FMC
    FMC --> ADDR
    FMC --> EADDR
    FMC --> ALTID
    FMC_SHR --> ALTID
```

> **Shared Entities (tím):** `Involved Party Postal Address`, `Involved Party Electronic Address`, `Involved Party Alternative Identification` — dùng chung cho mọi Involved Party entity (FMC, FMC Org Unit, Custodian Bank, ...).
>
> **Phân luồng ETL:** `SECURITIES.ForeignType = NULL` → `Fund Management Company`; `ForeignType IN ('B','O')` → `Foreign Fund Management Organization Unit` (Nhóm 8).

---

## Nhóm 2 — FMC Organization Unit (Chi nhánh / VPĐD QLQ trong nước)

### Source (FMS)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef pattern fill:#e2e8f0,stroke:#64748b,color:#1e293b

    SECURITIES2["**SECURITIES**\nCông ty quản lý quỹ"]:::src
    TLProfiles2["**TLProfiles**\nNhân sự công ty QLQ"]:::src
    BRANCHS["**BRANCHS**\nChi nhánh / VPĐD\ncông ty QLQ trong nước"]:::src
    BRCHBUP["**BRCHBUP**\nLưu lịch sử chi tiết CN/VPĐD\ncông ty QLQ trong nước [SCD]"]:::pattern
    SECHISTORY2["**SECHISTORY**\nLịch sử thay đổi\ncông ty QLQ / chi nhánh [Audit Log]"]:::pattern

    BRANCHS -->|SecId| SECURITIES2
    BRANCHS -->|TLId - người đại diện| TLProfiles2
    SECHISTORY2 -->|BrId| BRANCHS
    BRCHBUP -.->|SCD via SecHsId| SECHISTORY2
```

### Silver — Proposed Model

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef pattern fill:#e2e8f0,stroke:#64748b,color:#1e293b
    classDef shared fill:#fae8ff,stroke:#9333ea,color:#4a044e

    FMC_S2["**Fund Management Company**\nCông ty quản lý quỹ đầu tư"]:::silver
    FMC_EMP_S2["**FMC Employee**\nNhân sự công ty QLQ\n(người đại diện)"]:::silver
    FMC_OU["**FMC Organization Unit**\nChi nhánh / VPĐD công ty QLQ"]:::silver
    FMC_OU_AL["**FMC Organization Unit Audit Log**\nLịch sử thay đổi chi nhánh QLQ [Audit Log]"]:::pattern
    FMC_OU_SNAP["**FMC Organization Unit Snapshot**\nẢnh chụp trạng thái\nchi nhánh QLQ [SCD]"]:::pattern
    ADDR2["**Involved Party Postal Address**\n(dùng chung)"]:::shared
    EADDR2["**Involved Party Electronic Address**\n(dùng chung)"]:::shared
    ALTID2["**Involved Party Alternative Identification**\nGiấy phép thành lập CN\n(dùng chung)"]:::shared

    FMC_OU --> FMC_S2
    FMC_OU --> FMC_EMP_S2
    FMC_OU_AL -.->|Audit Log of| FMC_OU
    FMC_OU_SNAP -.->|SCD of| FMC_OU
    FMC_OU --> ADDR2
    FMC_OU --> EADDR2
    FMC_OU --> ALTID2
```

> **Lưu ý:** `BRANCHS.BrIdowner` (chi nhánh cha/con) → self-reference trong `FMC Organization Unit`. `BRCHBUP` là Snapshot của chi nhánh, không FK trực tiếp đến BRANCHS mà qua SECHISTORY.

---

## Nhóm 3 — FMC Employee (Nhân sự QLQ)

### Source (FMS)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef pattern fill:#e2e8f0,stroke:#64748b,color:#1e293b

    BRANCHS3["**BRANCHS**\nChi nhánh / VPĐD QLQ"]:::src
    INSIDER3["**INSIDER**\nCổ đông công ty QLQ"]:::src
    FUNDS3["**FUNDS**\nQuỹ đầu tư"]:::src
    TLProfiles["**TLProfiles**\nNhân sự công ty quản lý quỹ"]:::src
    TLPRHISTORY["**TLPRHISTORY**\nLịch sử thay đổi nhân sự QLQ\n[Audit Log]"]:::pattern
    TLPROBUP["**TLPROBUP**\nLịch sử chi tiết nhân sự QLQ\n[SCD]"]:::pattern
    FUNDTLPRO["**FUNDTLPRO**\nNhân sự điều hành quỹ\n(assignment)"]:::src

    TLProfiles -->|BranchId| BRANCHS3
    TLProfiles -->|InsderId| INSIDER3
    TLPRHISTORY -->|TlId| TLProfiles
    TLPROBUP -->|TlHsId| TLPRHISTORY
    FUNDTLPRO -->|TLPrId| TLProfiles
    FUNDTLPRO -->|FundId| FUNDS3
```

### Silver — Proposed Model

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef pattern fill:#e2e8f0,stroke:#64748b,color:#1e293b
    classDef shared fill:#fae8ff,stroke:#9333ea,color:#4a044e

    FMC_OU_S3["**FMC Organization Unit**\nChi nhánh / VPĐD QLQ"]:::silver
    FMC_SHR_S3["**FMC Shareholder**\nCổ đông công ty QLQ"]:::silver
    FUND_S3["**Fund Instrument**\nSản phẩm quỹ đầu tư"]:::silver
    FMC_EMP["**FMC Employee**\nNhân sự công ty QLQ\n(bao gồm người điều hành quỹ)"]:::silver
    FMC_EMP_AL["**FMC Employee Audit Log**\nLịch sử thay đổi\nthông tin nhân sự [Audit Log]"]:::pattern
    FMC_EMP_SNAP["**FMC Employee Snapshot**\nẢnh chụp trạng thái\nnhân sự [SCD]"]:::pattern
    ADDR3["**Involved Party Postal Address**\n(dùng chung)"]:::shared
    EADDR3["**Involved Party Electronic Address**\n(dùng chung)"]:::shared
    ALTID3["**Involved Party Alternative Identification**\nCMND/CCCD/Hộ chiếu/CCHN\n(dùng chung)"]:::shared

    FMC_EMP --> FMC_OU_S3
    FMC_EMP --> FMC_SHR_S3
    FMC_EMP --> FUND_S3
    FMC_EMP_AL -.->|Audit Log of| FMC_EMP
    FMC_EMP_SNAP -.->|SCD of| FMC_EMP
    FMC_EMP --> ADDR3
    FMC_EMP --> EADDR3
    FMC_EMP --> ALTID3
```

> **Lưu ý:** `FUNDTLPRO` (assignment) không tạo entity riêng trong Silver — được thể hiện qua quan hệ `FMC Employee → Fund Instrument`.
>
> `TLPROFILES` có cả địa chỉ thường trú, địa chỉ làm việc → 2 dòng trong `Involved Party Postal Address` với Address Type khác nhau (HOME / WORK).
>
> Định danh cá nhân: CMND/CCCD/Hộ chiếu (IdNo+IdDate+IdAdd) → `Involved Party Alternative Identification`. Chứng chỉ hành nghề (CertNo+CertDate+CertType) → `Involved Party Alternative Identification` với Type = "Professional Certificate".

---

## Nhóm 4 — Fund Instrument (Quỹ đầu tư) & các bảng liên quan

### Source (FMS)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef pattern fill:#e2e8f0,stroke:#64748b,color:#1e293b

    BANKMONI4["**BANKMONI**\nNgân hàng lưu ký / giám sát"]:::src
    FUNDS["**FUNDS**\nQuỹ đầu tư"]:::src
    FUNDHISTO["**FUNDHISTO**\nLịch sử thay đổi quỹ\n[Audit Log]"]:::pattern
    FUNDBUP["**FUNDBUP**\nChi tiết lịch sử quỹ\n[SCD]"]:::pattern
    REPRESENT["**REPRESENT**\nBan đại diện / HĐQT quỹ"]:::src
    MBFUND["**MBFUND**\nNhà đầu tư quỹ"]:::src
    MBCHANGE["**MBCHANGE**\nLịch sử thay đổi\nvốn góp NĐT quỹ"]:::src
    TRANSFERMBF["**TRANSFERMBF**\nGiao dịch chứng chỉ quỹ\n(chuyển nhượng CCQ)"]:::src

    FUNDS -->|BankId| BANKMONI4
    FUNDHISTO -->|FundId| FUNDS
    FUNDBUP -->|FunHsId| FUNDHISTO
    REPRESENT -->|FundId| FUNDS
    MBFUND -->|FundId| FUNDS
    MBCHANGE -->|MBFId| MBFUND
    TRANSFERMBF -->|FundId| FUNDS
```

### Silver — Proposed Model

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef pattern fill:#e2e8f0,stroke:#64748b,color:#1e293b
    classDef shared fill:#fae8ff,stroke:#9333ea,color:#4a044e

    CBANK_S4["**Custodian Bank**\nNgân hàng lưu ký\ngiám sát tài sản quỹ"]:::silver
    FUND["**Fund Instrument**\nSản phẩm quỹ đầu tư"]:::silver
    FUND_AL["**Fund Instrument Audit Log**\nLịch sử thay đổi thông tin quỹ\n[Audit Log]"]:::pattern
    FUND_SNAP["**Fund Instrument Snapshot**\nẢnh chụp trạng thái quỹ\n[SCD]"]:::pattern
    BOARD["**Fund Board Member**\nThành viên Ban đại diện\n/ HĐQT quỹ"]:::silver
    FIA["**Fund Investment Arrangement**\nQuan hệ đầu tư của NĐT vào quỹ"]:::silver
    FIA_CHG["**Fund Investment Arrangement Change**\nLịch sử biến động vốn góp\ntrong quan hệ đầu tư vào quỹ"]:::silver
    FUND_TXN["**Fund Unit Transfer Transaction**\nGiao dịch chuyển nhượng\nchứng chỉ quỹ"]:::silver
    ALTID4["**Involved Party Alternative Identification**\nCMND/CCCD/Hộ chiếu NĐT\n(dùng chung)"]:::shared

    FUND --> CBANK_S4
    FUND_AL -.->|Audit Log of| FUND
    FUND_SNAP -.->|SCD of| FUND
    BOARD --> FUND
    FIA --> FUND
    FIA_CHG --> FIA
    FUND_TXN --> FUND
    FUND --> ALTID4
    FIA --> ALTID4
    BOARD --> ALTID4
```

> **Lưu ý:** `REPRESENT` (Fund Board Member) có CMND/CCCD, `MBFUND` (NĐT quỹ) có CMND/CCCD/ĐKKD — đều route sang `Involved Party Alternative Identification`.
>
> `MBFUND.RepresentName / RepresentJob` → denormalized attributes trong `Fund Investment Arrangement` (không tạo entity riêng cho người đại diện vốn góp nếu chưa có thêm thông tin).

---

## Nhóm 5 — Discretionary Investment Investor (Nhà đầu tư ủy thác)

### Source (FMS)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f

    SECURITIES5["**SECURITIES**\nCông ty quản lý quỹ"]:::src
    INVES["**INVES**\nNhà đầu tư ủy thác"]:::src
    INVESACC["**INVESACC**\nTài khoản nhà đầu tư ủy thác"]:::src

    INVES -->|SecId| SECURITIES5
    INVESACC -->|InvesId| INVES
```

### Silver — Proposed Model

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef shared fill:#fae8ff,stroke:#9333ea,color:#4a044e

    FMC_S5["**Fund Management Company**\nCông ty quản lý quỹ đầu tư"]:::silver
    DII["**Discretionary Investment Investor**\nNhà đầu tư ủy thác\nquản lý tài sản"]:::silver
    DIA["**Discretionary Investment Account**\nTài khoản / hợp đồng đầu tư ủy thác"]:::silver
    ADDR5["**Involved Party Postal Address**\n(dùng chung)"]:::shared
    ALTID5["**Involved Party Alternative Identification**\nCMND/CCCD/Hộ chiếu/ĐKKD NĐT ủy thác\n(dùng chung)"]:::shared

    DII --> FMC_S5
    DIA --> DII
    DII --> ADDR5
    DII --> ALTID5
```

> **Lưu ý:** `INVES.IdType` phân biệt loại giấy tờ (CMND vs ĐKKD) → ánh xạ thành `Identification Type` trong `Involved Party Alternative Identification`.
>
> `INVESACC` tương ứng với `Discretionary Investment Account` — có `ContractNo` (Số hợp đồng), `Account` (Tài khoản lưu ký), `ManagerFee` (Phí quản lý).

---

## Nhóm 6 — Fund Distribution Agent (Đại lý phân phối quỹ)

### Source (FMS)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f

    AGENCIES["**AGENCIES**\nĐại lý phân phối quỹ đầu tư\n(không FK ra ngoài)"]:::src
    AGENCIESBRA["**AGENCIESBRA**\nChi nhánh / Phòng giao dịch\ncủa đại lý"]:::src

    AGENCIESBRA -->|AgenId| AGENCIES
```

### Silver — Proposed Model

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef shared fill:#fae8ff,stroke:#9333ea,color:#4a044e

    FDA["**Fund Distribution Agent**\nTổ chức đại lý được ủy quyền\nphân phối quỹ"]:::silver
    FDAB["**Fund Distribution Agent Branch**\nChi nhánh / phòng giao dịch\ncủa đại lý phân phối"]:::silver
    ADDR6["**Involved Party Postal Address**\n(dùng chung)"]:::shared
    EADDR6["**Involved Party Electronic Address**\n(dùng chung)"]:::shared
    ALTID6["**Involved Party Alternative Identification**\nGiấy phép / ĐKKD đại lý\n(dùng chung)"]:::shared

    FDAB --> FDA
    FDA --> ADDR6
    FDA --> EADDR6
    FDA --> ALTID6
    FDAB --> ADDR6
    FDAB --> ALTID6
```

---

## Nhóm 7 — Custodian Bank (Ngân hàng lưu ký, giám sát)

### Source (FMS)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f

    BANKMONI["**BANKMONI**\nNgân hàng lưu ký\nvà giám sát quỹ"]:::src
    BANKEMPLOY["**BANKEMPLOY**\nNhân sự ngân hàng\nlưu ký / giám sát"]:::src
    FUNDS7["**FUNDS**\nQuỹ đầu tư"]:::src

    BANKEMPLOY -->|BankId| BANKMONI
    FUNDS7 -->|BankId - quỹ chỉ định\nngân hàng lưu ký| BANKMONI
```

### Silver — Proposed Model

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef shared fill:#fae8ff,stroke:#9333ea,color:#4a044e

    FUND_S7["**Fund Instrument**\nSản phẩm quỹ đầu tư"]:::silver
    CBANK["**Custodian Bank**\nNgân hàng lưu ký\ngiám sát tài sản quỹ"]:::silver
    CBANK_EMP["**Custodian Bank Employee**\nNhân sự ngân hàng\nlưu ký / giám sát"]:::silver
    ADDR7["**Involved Party Postal Address**\n(dùng chung)"]:::shared
    EADDR7["**Involved Party Electronic Address**\n(dùng chung)"]:::shared
    ALTID7["**Involved Party Alternative Identification**\nGiấy phép thành lập NH / CMND nhân sự\n(dùng chung)"]:::shared

    FUND_S7 --> CBANK
    CBANK_EMP --> CBANK
    CBANK --> ADDR7
    CBANK --> EADDR7
    CBANK --> ALTID7
    CBANK_EMP --> ALTID7
```

> **Lưu ý:** `BANKMONI.Type` (1: Giám sát / 2: Lưu ký / 3: LKGS) → Silver vẫn là một entity `Custodian Bank`, phân biệt bằng attribute `Custodian Bank Type`.
>
> `BANKEMPLOY` có chứng chỉ nghề nghiệp (CertNo, CertAudit, CertLaw) → route sang `Involved Party Alternative Identification` với các Identification Type khác nhau.

---

## Nhóm 8 — Foreign Fund Management Organization Unit (VPĐD / Chi nhánh QLQ nước ngoài)

> **Lưu ý:** `FORBRCH` không có FK đến `SECURITIES` — entity **độc lập**, không liên kết với FMC trong nước. UBCKNN chỉ quản lý VPĐD/chi nhánh tại VN, không quản lý công ty mẹ ở nước ngoài.

### Source (FMS)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef pattern fill:#e2e8f0,stroke:#64748b,color:#1e293b

    FORBRCH["**FORBRCH**\nVPĐD / Chi nhánh công ty QLQ\nnước ngoài tại VN\n(không FK → SECURITIES)"]:::src
    FGBRHISTORY["**FGBRHISTORY**\nLịch sử thay đổi\nVPĐD / Chi nhánh NN [Audit Log]"]:::pattern
    FGBRBUP["**FGBRBUP**\nChi tiết lịch sử\nVPĐD / Chi nhánh NN [SCD]"]:::pattern
    STFFGBRCH["**STFFGBRCH**\nNhân sự VPĐD / Chi nhánh\nQLQ NN tại VN"]:::src

    FGBRHISTORY -->|FgBrId| FORBRCH
    FGBRBUP -->|FgHisId| FGBRHISTORY
    STFFGBRCH -->|ForBrchId| FORBRCH
```

### Silver — Proposed Model

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef pattern fill:#e2e8f0,stroke:#64748b,color:#1e293b
    classDef shared fill:#fae8ff,stroke:#9333ea,color:#4a044e

    FFMOU["**Foreign Fund Management Organization Unit**\nVPĐD / Chi nhánh công ty QLQ\nnước ngoài tại Việt Nam"]:::silver
    FFMOU_AL["**Foreign Fund Mgmt Org Unit Audit Log**\nLịch sử thay đổi thông tin\nchi nhánh QLQ nước ngoài [Audit Log]"]:::pattern
    FFMOU_SN["**Foreign Fund Mgmt Org Unit Snapshot**\nẢnh chụp trạng thái\nchi nhánh QLQ nước ngoài [SCD]"]:::pattern
    FFMOU_EMP["**Foreign Fund Mgmt Org Unit Employee**\nNhân sự VPĐD / Chi nhánh\ncông ty QLQ nước ngoài"]:::silver
    ADDR8["**Involved Party Postal Address**\n(dùng chung)"]:::shared
    EADDR8["**Involved Party Electronic Address**\n(dùng chung)"]:::shared
    ALTID8["**Involved Party Alternative Identification**\nGiấy phép hoạt động tại VN\n(dùng chung)"]:::shared

    FFMOU_AL -.->|Audit Log of| FFMOU
    FFMOU_SN -.->|SCD of| FFMOU
    FFMOU_EMP --> FFMOU
    FFMOU --> ADDR8
    FFMOU --> EADDR8
    FFMOU --> ALTID8
```

> **Phân luồng ETL:** `SECURITIES.ForeignType IN ('B','O')` → route sang `Foreign Fund Management Organization Unit`, không vào `Fund Management Company`.

---

## Nhóm 9 — Insider Share Transfer (Giao dịch chuyển nhượng cổ phần)

### Source (FMS)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f

    SECURITIES9["**SECURITIES**\nCông ty quản lý quỹ"]:::src
    INSIDER9_F["**INSIDER**\nCổ đông chuyển nhượng\n(InFrmId)"]:::src
    INSIDER9_T["**INSIDER**\nCổ đông nhận chuyển nhượng\n(InToId)"]:::src
    TRSFERINDER["**TRSFERINDER**\nGiao dịch chuyển nhượng\ncổ phần cổ đông QLQ"]:::src

    TRSFERINDER -->|ScId| SECURITIES9
    TRSFERINDER -->|InFrmId - người chuyển| INSIDER9_F
    TRSFERINDER -->|InToId - người nhận| INSIDER9_T
```

### Silver — Proposed Model

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d

    FMC_S9["**Fund Management Company**\nCông ty quản lý quỹ đầu tư"]:::silver
    SHR_FROM["**FMC Shareholder**\nCổ đông chuyển nhượng"]:::silver
    SHR_TO["**FMC Shareholder**\nCổ đông nhận chuyển nhượng"]:::silver
    ISTT["**Insider Share Transfer Transaction**\nGiao dịch chuyển nhượng cổ phần\ngiữa các cổ đông QLQ"]:::silver

    ISTT --> FMC_S9
    ISTT --> SHR_FROM
    ISTT --> SHR_TO
    SHR_FROM --> FMC_S9
    SHR_TO --> FMC_S9
```

---

## Nhóm 10 — Report Submission & Report Values (Báo cáo thành viên thị trường)

> **Multi-way FK:** `RPTMEMBER` có 4 FK subject (SecId / BkMId / FrBrId / FndId) — chỉ một non-null theo `Type`. `RPTVALUES` mirror cùng 4 FK. Silver resolve thành quan hệ đa subject.

### Source (FMS)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef outscope fill:#fef9c3,stroke:#ca8a04,color:#713f12

    SECURITIES10["**SECURITIES**\nCông ty QLQ"]:::src
    BANKMONI10["**BANKMONI**\nNgân hàng lưu ký"]:::src
    FORBRCH10["**FORBRCH**\nVPĐD / CN QLQ NN"]:::src
    FUNDS10["**FUNDS**\nQuỹ đầu tư"]:::src
    RPTPRIOD["**RPTPRIOD**\nKỳ báo cáo\n(ngoài scope)"]:::outscope
    RPTTEMP["**RPTTEMP / SHEET**\nMẫu báo cáo / Sheet\n(ngoài scope)"]:::outscope
    RPTMEMBER["**RPTMEMBER**\nBáo cáo thành viên thị trường"]:::src
    RPTVALUES["**RPTVALUES**\nGiá trị báo cáo import\n(EAV fact)"]:::src

    RPTMEMBER -->|SecId - theo Type| SECURITIES10
    RPTMEMBER -->|BkMId - theo Type| BANKMONI10
    RPTMEMBER -->|FrBrId - theo Type| FORBRCH10
    RPTMEMBER -->|FndId - theo Type| FUNDS10
    RPTMEMBER -->|PrdId| RPTPRIOD
    RPTMEMBER -->|RptId| RPTTEMP
    RPTVALUES -->|MebId| RPTMEMBER
    RPTVALUES -->|RptId / SheetId| RPTTEMP
    RPTVALUES -->|PrdId| RPTPRIOD
    RPTVALUES -->|SecId / BkMId / FrBrId / FndId - mirror FK| SECURITIES10
```

### Silver — Proposed Model

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef outscope fill:#fef9c3,stroke:#ca8a04,color:#713f12

    FMC_S10["**Fund Management Company**\n(subject theo Type=2)"]:::silver
    CB_S10["**Custodian Bank**\n(subject theo Type=3)"]:::silver
    FFMOU_S10["**Foreign Fund Mgmt Org Unit**\n(subject theo Type=4,5)"]:::silver
    FI_S10["**Fund Instrument**\n(subject theo Type=7)"]:::silver
    OUTSCOPE10["**Reporting Period / Template / Sheet**\n(ngoài scope 34 bảng)"]:::outscope
    MRS["**Member Report Submission**\nHồ sơ nộp báo cáo\ncủa thành viên thị trường"]:::silver
    RIV["**Report Item Value**\nGiá trị từng ô báo cáo\n(1 dòng = 1 giá trị 1 ô)"]:::silver

    MRS --> FMC_S10
    MRS --> CB_S10
    MRS --> FFMOU_S10
    MRS --> FI_S10
    MRS -.-> OUTSCOPE10
    RIV --> MRS
    RIV -.-> OUTSCOPE10
```

---

## Tổng quan theo BCV Concept

| BCV Concept | Source Tables | Silver Entities |
|---|---|---|
| **Involved Party — Portfolio Fund Management Company** | SECURITIES (ForeignType=NULL) | Fund Management Company |
| **Involved Party — Organization Unit** | BRANCHS, AGENCIESBRA | FMC Organization Unit, Fund Distribution Agent Branch |
| **Involved Party — Agent** | AGENCIES | Fund Distribution Agent |
| **Involved Party — Organization (Foreign)** | FORBRCH | Foreign Fund Management Organization Unit |
| **Involved Party — Custodian** | BANKMONI | Custodian Bank |
| **Involved Party — Investor (Discretionary)** | INVES | Discretionary Investment Investor |
| **Involved Party — Employment Position** | REPRESENT | Fund Board Member |
| **Involved Party — Employee** | TLProfiles, BANKEMPLOY, STFFGBRCH, FUNDTLPRO | FMC Employee, Custodian Bank Employee, Foreign Fund Mgmt Org Unit Employee |
| **Involved Party — Organization Ownership** | INSIDER, INSIDCHANGE | FMC Shareholder, FMC Shareholder Ownership Change |
| **Involved Party — Relationship** | STAKE, INSDERRELA, INSDERRPRST | FMC Organization Relationship, FMC Shareholder Relationship, FMC Shareholder Representative |
| **Product — Fund Instrument** | FUNDS | Fund Instrument |
| **Arrangement — Fund Investment Arrangement** | MBFUND, MBCHANGE | Fund Investment Arrangement, Fund Investment Arrangement Change |
| **Arrangement — Discretionary Investment Account** | INVESACC | Discretionary Investment Account |
| **Transaction — Fund Unit Transfer** | TRANSFERMBF | Fund Unit Transfer Transaction |
| **Transaction — Insider Share Transfer** | TRSFERINDER | Insider Share Transfer Transaction |
| **Documentation — Reported Information** | RPTMEMBER, RPTVALUES | Member Report Submission, Report Item Value |
| **ETL Pattern — SCD Snapshot** | SECBUP, BRCHBUP, TLPROBUP, FUNDBUP, FGBRBUP | \*Snapshot entities (5 bảng) |
| **ETL Pattern — Audit Log** | SECHISTORY, TLPRHISTORY, FUNDHISTO, FGBRHISTORY | \*Audit Log entities (4 bảng) |
| **Location — Postal Address** *(shared)* | SECURITIES, BRANCHS, AGENCIES, AGENCIESBRA, INVES, BANKMONI, TLProfiles, FORBRCH, ... | Involved Party Postal Address |
| **Location — Electronic Address** *(shared)* | SECURITIES, BRANCHS, AGENCIES, BANKMONI, FORBRCH, REPRESENT, ... | Involved Party Electronic Address |
| **Involved Party — Alternative Identification** *(shared)* | SECURITIES, BRANCHS, INSIDER, TLProfiles, MBFUND, REPRESENT, INVES, BANKEMPLOY, FORBRCH, AGENCIES, ... | Involved Party Alternative Identification |
