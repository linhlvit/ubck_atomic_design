# NHNCK — Silver Layer Relationship Diagram

> **Phiên bản:** Thiết kế mới dựa trên hệ thống nguồn mới (`qlnhn`, MySQL Server, ~48 bảng).
>
> **Source system:** NHNCK (Phân hệ Quản lý giám sát người hành nghề chứng khoán)
>
> **Tài liệu tham chiếu:** `NHNCK_Source_Tables_New.xlsx`, `NHNCK_GAP_Analysis_Old_vs_New_Source.md`
>
> **Domain prefix:** Tất cả Silver entity trong nhóm NHN dùng chung prefix **"Securities Practitioner"** (theo quy tắc [Domain Prefix] + [BCV Term]).

---

## Nhóm A — Hồ sơ đăng ký CCHN (Practitioner License Application)

### Source (NHNCK)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef pattern fill:#e2e8f0,stroke:#64748b,color:#1e293b
    classDef outscope fill:#fef9c3,stroke:#ca8a04,color:#713f12

    Applications["**Applications**\nHồ sơ đăng ký chứng chỉ\nhành nghề"]:::src
    ApplicationSpecializations["**ApplicationSpecializations**\nChuyên môn liên quan đến hồ sơ"]:::src
    ApplicationDocuments["**ApplicationDocuments**\nTài liệu đính kèm trong hồ sơ"]:::src
    ApplicationLogs["**ApplicationLogs**\nNhật ký log của hồ sơ\n[Activity Log]"]:::pattern
    ApplicationFees["**ApplicationFees**\nPhí thanh toán liên quan đến hồ sơ"]:::src
    VerifyApplicationStatuses["**VerifyApplicationStatuses**\nYêu cầu phê duyệt lãnh đạo cho hồ sơ"]:::src

    Professionals["**Professionals**\nNgười hành nghề\n(Nhóm B)"]:::outscope
    CertificateRecords["**CertificateRecords**\nChứng chỉ hành nghề\n(Nhóm B)"]:::outscope
    ExamSessions["**ExamSessions**\nĐợt thi sát hạch\n(Nhóm C)"]:::outscope
    Users["**Users**\nNgười dùng hệ thống\n(Nhóm E)"]:::outscope

    ApplicationSpecializations -->|ApplicationId| Applications
    ApplicationDocuments -->|ApplicationId| Applications
    ApplicationLogs -.->|ApplicationId - Activity of| Applications
    ApplicationFees -->|ApplicationId| Applications
    VerifyApplicationStatuses -->|ApplicationId| Applications

    Applications -->|ProfessionalId| Professionals
    Applications -->|CertificateRecordId| CertificateRecords
    Applications -->|ExamSessionId| ExamSessions
    Applications -->|AssigneeId| Users
    Applications -->|InfoVerifyId| VerifyApplicationStatuses
    VerifyApplicationStatuses -->|VerifyBy| Users
```

### Silver — Proposed Model (Nhóm A)

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef pattern fill:#e2e8f0,stroke:#64748b,color:#1e293b
    classDef outscope fill:#fef9c3,stroke:#ca8a04,color:#713f12

    APP["**Securities Practitioner\nLicense Application**\n[Documentation] Gov. Registration Document\nHồ sơ đăng ký CCHN"]:::silver
    TRAINING["**Securities Practitioner\nLicense Application\nEducation Certificate Document**\n[Documentation] Education Certificate\nChuyên môn đào tạo trong hồ sơ"]:::silver
    DOCATTACH["**Securities Practitioner\nLicense Application\nDocument Attachment**\n[Documentation] Supporting Documentation\nTài liệu đính kèm hồ sơ"]:::silver
    ACTLOG["**Securities Practitioner\nLicense Application\nProcessing Activity Log**\n[Business Activity] Business Activity\n[Activity Log]"]:::pattern
    APPFEE["**Securities Practitioner\nLicense Application Fee**\n[Event] Transaction\nPhí thực tế áp dụng cho hồ sơ"]:::silver
    VERIFY["**Securities Practitioner\nLicense Application\nVerification Status**\n[Business Activity] Approval Activity\nPhê duyệt đa cấp LĐCM → LĐUB"]:::silver

    PRACTITIONER["**Securities Practitioner**\n(Nhóm B)"]:::outscope
    CERTDOC["**Securities Practitioner\nLicense Certificate Document**\n(Nhóm B)"]:::outscope
    EXAM["**Securities Practitioner\nQualification Examination Assessment**\n(Nhóm C)"]:::outscope
    OFFICER["**Regulatory Authority Officer**\n(Nhóm E)"]:::outscope

    TRAINING -->|FK: Application Identifier| APP
    DOCATTACH -->|FK: Application Identifier| APP
    ACTLOG -.->|Activity of| APP
    APPFEE -->|FK: Application Identifier| APP
    VERIFY -->|FK: Application Identifier| APP

    APP -->|Practitioner Identifier| PRACTITIONER
    APP -->|License Certificate Identifier| CERTDOC
    APP -->|Examination Assessment Identifier| EXAM
    APP -->|Assignee Officer Identifier| OFFICER
    VERIFY -->|Verify Officer Identifier| OFFICER
```

---

## Nhóm B — Chứng chỉ & Người hành nghề (Certificate & Practitioner)

### Source (NHNCK)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef pattern fill:#e2e8f0,stroke:#64748b,color:#1e293b
    classDef outscope fill:#fef9c3,stroke:#ca8a04,color:#713f12

    Professionals["**Professionals**\nThông tin người hành nghề CK\n(master entity)"]:::src
    CertificateRecords["**CertificateRecords**\nChứng chỉ hành nghề được cấp"]:::src
    CertificateRecordGroups["**CertificateRecordGroups**\nNhóm chứng chỉ hành nghề"]:::src
    CertificateRecordGroupMembers["**CertificateRecordGroupMembers**\nThành viên trong nhóm chứng chỉ hành nghề"]:::src
    CertificateRecordStatusHistories["**CertificateRecordStatusHistories**\nLịch sử trạng thái chứng chỉ hành nghề"]:::pattern
    CertificateRecordLogs["**CertificateRecordLogs**\nNhật ký chứng chỉ hành nghề\n[Activity Log]"]:::pattern
    ProfessionalWorkHistories["**ProfessionalWorkHistories**\nLịch sử làm việc của người hành nghề"]:::src
    ProfessionalRelationships["**ProfessionalRelationships**\nThông tin quan hệ gia đình/xã hội\ncủa người hành nghề"]:::src
    ProfessionalHistories["**ProfessionalHistories**\nLịch sử thay đổi định danh cá nhân\ncủa người hành nghề\n[Audit Log]"]:::pattern
    Violations["**Violations**\nThông tin vi phạm của người hành nghề"]:::src
    OrganizationReports["**OrganizationReports**\nBáo cáo về người hành nghề từ tổ chức"]:::src
    IdentityInfoC06s["**IdentityInfoC06s**\nLịch sử kiểm tra xác thực với C06"]:::src

    Decisions["**Decisions**\nDanh mục quyết định\n(Nhóm E)"]:::outscope
    Organizations["**Organizations**\nTổ chức tham gia TTCK\n(Nhóm E)"]:::outscope

    CertificateRecords -->|ProfessionalId| Professionals
    CertificateRecords -->|DecisionId| Decisions
    CertificateRecords -->|RevocationDecisionId| Decisions
    CertificateRecordGroups -->|DecisionId| Decisions
    CertificateRecordGroupMembers -->|GroupId| CertificateRecordGroups
    CertificateRecordGroupMembers -->|CertificateRecordId| CertificateRecords
    CertificateRecordStatusHistories -.->|CertificateRecordId - History of| CertificateRecords
    CertificateRecordLogs -.->|CertificateRecordId - Activity of| CertificateRecords
    ProfessionalWorkHistories -->|ProfessionalId| Professionals
    ProfessionalRelationships -->|ProfessionalId| Professionals
    ProfessionalHistories -.->|ProfessionalId - Audit Log of| Professionals
    Violations -->|ProfessionalId| Professionals
    Violations -->|DecisionId| Decisions
    OrganizationReports -->|ProfessionalId| Professionals
    OrganizationReports -->|OrganizationId| Organizations
    OrganizationReports -->|ParentReportId - self ref| OrganizationReports
    IdentityInfoC06s -->|ProfessionalId| Professionals
```

### Silver — Proposed Model (Nhóm B)

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef pattern fill:#e2e8f0,stroke:#64748b,color:#1e293b
    classDef outscope fill:#fef9c3,stroke:#ca8a04,color:#713f12

    PRACTITIONER["**Securities Practitioner**\n[Involved Party] Individual\nNgười hành nghề CK (master entity)"]:::silver
    CERTDOC["**Securities Practitioner\nLicense Certificate Document**\n[Documentation] Gov. Registration Document\nChứng chỉ hành nghề"]:::silver
    CERTGROUP["**Securities Practitioner\nLicense Certificate Group Document**\n[Documentation] Gov. Registration Document\nNhóm cấp/thu hồi/hủy chứng chỉ"]:::silver
    CERTGROUPMEM["**Securities Practitioner\nLicense Certificate Group Member**\nJunction: Certificate ↔ Group"]:::silver
    CERTSTATHIST["**Securities Practitioner\nLicense Certificate Document\nStatus History**\n[Business Activity] Business Activity\n[Activity Log]"]:::pattern
    CERTLOG["**Securities Practitioner\nLicense Certificate Document\nActivity Log**\n[Business Activity] Business Activity\n[Activity Log]"]:::pattern
    EMPSTATUS["**Securities Practitioner\nEmployment Status**\n[Involved Party] Individual Employment Status\nLịch sử làm việc"]:::silver
    RELPARTY["**Securities Practitioner\nRelated Party**\n[Involved Party] Involved Party Relationship\nQuan hệ gia đình/xã hội"]:::silver
    PRACAUDIT["**Securities Practitioner\nAudit Log**\nAudit Log of Securities Practitioner\n[Audit Log]"]:::pattern
    VIOLATION["**Securities Practitioner\nConduct Violation**\n[Business Activity] Conduct Violation\nVi phạm người hành nghề"]:::silver
    EMPHRPT["**Securities Practitioner\nOrganization Employment Report**\n[Documentation] Employer Registration\nBáo cáo tổ chức về NHN"]:::silver
    IDVERIFY["**Securities Practitioner\nIdentity Verification Record**\n[Communication] Verification\nXác thực danh tính C06"]:::silver

    DECISION["**Securities Practitioner\nLicense Decision Document**\n(Nhóm E)"]:::outscope
    ORG["**Securities Organization Reference**\n(Nhóm E)"]:::outscope

    CERTDOC -->|Practitioner Identifier| PRACTITIONER
    CERTDOC -->|Issuance Decision Identifier| DECISION
    CERTDOC -->|Revocation Decision Identifier| DECISION
    CERTGROUP -->|Decision Identifier| DECISION
    CERTGROUPMEM -->|License Certificate Group Identifier| CERTGROUP
    CERTGROUPMEM -->|License Certificate Identifier| CERTDOC
    CERTSTATHIST -.->|History of| CERTDOC
    CERTLOG -.->|Activity of| CERTDOC
    EMPSTATUS -->|Practitioner Identifier| PRACTITIONER
    RELPARTY -->|Practitioner Identifier| PRACTITIONER
    PRACAUDIT -.->|Audit Log of| PRACTITIONER
    VIOLATION -->|Practitioner Identifier| PRACTITIONER
    VIOLATION -->|Decision Identifier| DECISION
    EMPHRPT -->|Practitioner Identifier| PRACTITIONER
    EMPHRPT -->|Organization Identifier| ORG
    EMPHRPT -->|Parent Report Identifier - self ref| EMPHRPT
    IDVERIFY -->|Practitioner Identifier| PRACTITIONER
```

---

## Nhóm C — Đào tạo & Thi sát hạch (Training & Examination)

### Source (NHNCK)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    classDef outscope fill:#fef9c3,stroke:#ca8a04,color:#713f12

    Professionals["**Professionals**\nNgười hành nghề\n(Nhóm B)"]:::outscope
    Decisions["**Decisions**\nDanh mục quyết định\n(Nhóm E)"]:::outscope
    Applications["**Applications**\nHồ sơ đăng ký\n(Nhóm A)"]:::outscope

    SpecializationCourses["**SpecializationCourses**\nDanh mục khóa học chuyên môn"]:::src
    SpecializationCourseDetails["**SpecializationCourseDetails**\nChi tiết người tham gia khóa học chuyên môn"]:::src
    ExamSessions["**ExamSessions**\nDanh mục các đợt thi sát hạch"]:::src
    ExamDetails["**ExamDetails**\nKết quả các kỳ thi sát hạch"]:::src
    ExamSessionFees["**ExamSessionFees**\nPhí thi sát hạch"]:::src

    SpecializationCourseDetails -->|SpecializationCourseId| SpecializationCourses
    SpecializationCourseDetails -->|ProfessionalId| Professionals
    ExamDetails -->|ExamSessionId| ExamSessions
    ExamDetails -->|ProfessionalId| Professionals
    ExamDetails -->|ApplicationId| Applications
    ExamSessions -->|DecisionId| Decisions
    ExamSessionFees -->|ExamSessionId| ExamSessions
```

### Silver — Proposed Model (Nhóm C)

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef outscope fill:#fef9c3,stroke:#ca8a04,color:#713f12

    PRACTITIONER["**Securities Practitioner**\n(Nhóm B)"]:::outscope
    DECISION["**Securities Practitioner\nLicense Decision Document**\n(Nhóm E)"]:::outscope
    APP["**Securities Practitioner\nLicense Application**\n(Nhóm A)"]:::outscope

    TRAINCLASS["**Securities Practitioner\nProfessional Training Class**\n[Event] Training Course\nKhóa đào tạo chuyên môn CCHN"]:::silver
    ENROLLMENT["**Securities Practitioner\nProfessional Training Class Enrollment**\n[Business Activity] Business Activity\nĐăng ký học viên + kết quả"]:::silver
    EXAM["**Securities Practitioner\nQualification Examination Assessment**\n[Communication] Assessment\nĐợt thi sát hạch CCHN"]:::silver
    EXAMRESULT["**Securities Practitioner\nQualification Examination\nAssessment Result**\n[Communication] Assessment\nKết quả thí sinh"]:::silver
    EXAMFEE["**Securities Practitioner\nQualification Examination\nAssessment Fee**\n[Condition] Financial Charge\nBiểu phí thi sát hạch theo đợt + loại chứng chỉ"]:::silver

    ENROLLMENT -->|Training Class Identifier| TRAINCLASS
    ENROLLMENT -->|Practitioner Identifier| PRACTITIONER
    EXAMRESULT -->|Examination Assessment Identifier| EXAM
    EXAMRESULT -->|Practitioner Identifier| PRACTITIONER
    EXAMRESULT -->|Application Identifier| APP
    EXAM -->|Decision Identifier| DECISION
    EXAMFEE -->|Examination Assessment Identifier| EXAM
```

---

## Nhóm E — Danh mục & Tham chiếu (Reference Data)

### Source (NHNCK)

```mermaid
graph LR
    classDef src fill:#dbeafe,stroke:#2563eb,color:#1e3a5f

    Organizations["**Organizations**\nThông tin các tổ chức\n(CTCK, QLQ, Ngân hàng, ...)"]:::src
    Decisions["**Decisions**\nDanh mục các quyết định hành chính"]:::src
    Units["**Units**\nDanh mục đơn vị"]:::src
    Departments["**Departments**\nDanh mục phòng ban"]:::src
    Users["**Users**\nThông tin người dùng hệ thống"]:::src

    Departments -->|UnitId| Units
    Users -->|UnitId| Units
    Users -->|DepartmentId| Departments
```

### Silver — Proposed Model (Nhóm E)

```mermaid
graph LR
    classDef silver fill:#dcfce7,stroke:#16a34a,color:#14532d

    SECORG["**Securities Organization Reference**\n[Involved Party] Organization\nTổ chức tham gia TTCK"]:::silver
    REGDECISION["**Securities Practitioner\nLicense Decision Document**\n[Documentation] Gov. Registration Document\nQuyết định cơ quan nhà nước"]:::silver
    REGORGUNIT["**Regulatory Authority\nOrganization Unit**\n[Involved Party] Organization\nĐơn vị + Phòng ban UBCKNN (gộp)"]:::silver
    OFFICER["**Regulatory Authority Officer**\n[Involved Party] Individual\nCán bộ xử lý UBCKNN"]:::silver

    REGORGUNIT -->|Parent Organization Unit Identifier - self ref| REGORGUNIT
    OFFICER -->|Organization Unit Identifier| REGORGUNIT
```

> **Lưu ý Nhóm E:**
> - **Classification Value** (7 danh mục): `EducationLevels`, `ApplicationStatuses`, `Certificates`, `Specializations`, `Documents`, `ApplicationSources`, `Positions` — bảng danh mục đơn giản (code-name). ETL load vào `Silver.Classification_Value` với scheme tương ứng. Không xuất hiện trong diagram theo quy tắc HLD.
> - **`Positions` → Classification Value scheme "Employment Position Type"**: Theo định nghĩa BCV, Employment Position là một vị trí việc làm cụ thể trong tổ chức (instance có người đảm nhận). Bảng `Positions` trong NHNCK chỉ chứa danh sách chức danh (Chuyên viên, Trưởng phòng...) — đây là **Employment Position Type** (reference data set), không phải Employment Position entity. Do đó map vào Classification Value, không tạo Silver entity riêng.
> - **Securities Organization Reference** (`Organizations`): entity nghiệp vụ phong phú (CharterCapital, LicenseNumber, Website...), được FK từ nhiều bảng → tạo Silver entity riêng.
> - **Securities Practitioner License Decision Document** (`Decisions`): entity nghiệp vụ thực (TypeId, SoQuyetDinh, NgayKy, NguoiKy...), được FK từ Nhóm A, B, C → tạo Silver entity riêng.
> - **Regulatory Authority Organization Unit** (`Units` + `Departments` gộp): cơ cấu tổ chức UBCKNN, cấu trúc tương tự, số trường ít → gộp thành 1 entity dạng cây (self-referencing) với Classification Value phân biệt cấp (Unit / Department). Dùng làm dimension cho báo cáo.
> - **Regulatory Authority Officer** (`Users`): cán bộ xử lý hồ sơ UBCKNN. Được FK từ Nhóm A (AssigneeId, VerifyBy) và nhiều bảng khác (CreatedBy). FK → Organization Unit. Trường chức vụ dùng Classification Value "Employment Position Type Code" (không FK entity riêng). Không bao gồm thông tin xác thực (PasswordHash) trên Silver.
> - **Bảng không lên Silver:** `UserRoles`, `Roles`, `Permissions`, `PermissionRoles`, `DepartmentAccess`, `ActionLogs`, `SystemParameters`, `DigitalCertificates`, `DigitalCertificateUsers`, `CertificateDocuments`, `CertificateSpecializations`, `CertificateDepartments`, `CertificateNumberTemplates` — operational / system data.

---

## Tổng quan theo BCV Concept (NHNCK — Tất cả nhóm)

### Nhóm A — Hồ sơ đăng ký CCHN (Practitioner License Application)

| BCV Concept | Source Tables | Mô tả bảng nguồn | Silver Entities |
|---|---|---|---|
| **[Documentation] Government Registration Document** | Applications | Hồ sơ đăng ký chứng chỉ hành nghề | Securities Practitioner License Application |
| **[Documentation] Education Certificate** | ApplicationSpecializations | Chuyên môn liên quan đến hồ sơ | Securities Practitioner License Application Education Certificate Document |
| **[Documentation] Supporting Documentation** | ApplicationDocuments | Tài liệu đính kèm trong hồ sơ | Securities Practitioner License Application Document Attachment |
| **ETL Pattern — Business Activity Log** | ApplicationLogs | Nhật ký log của hồ sơ | Securities Practitioner License Application Processing Activity Log |
| **[Event] Transaction** | ApplicationFees | Phí thanh toán liên quan đến hồ sơ | Securities Practitioner License Application Fee |
| **[Business Activity] Approval Activity** | VerifyApplicationStatuses | Yêu cầu phê duyệt lãnh đạo cho hồ sơ | Securities Practitioner License Application Verification Status |

### Nhóm B — Chứng chỉ & Người hành nghề (Certificate & Practitioner)

| BCV Concept | Source Tables | Mô tả bảng nguồn | Silver Entities |
|---|---|---|---|
| **[Involved Party] Individual** | Professionals | Thông tin người hành nghề chứng khoán | Securities Practitioner |
| **[Documentation] Gov. Registration Document** | CertificateRecords | Chứng chỉ hành nghề được cấp | Securities Practitioner License Certificate Document |
| **[Documentation] Gov. Registration Document** | CertificateRecordGroups | Nhóm chứng chỉ hành nghề | Securities Practitioner License Certificate Group Document |
| **Junction** | CertificateRecordGroupMembers | Thành viên trong nhóm chứng chỉ hành nghề | Securities Practitioner License Certificate Group Member |
| **ETL Pattern — Activity Log** | CertificateRecordStatusHistories | Lịch sử trạng thái chứng chỉ hành nghề | Securities Practitioner License Certificate Document Status History |
| **ETL Pattern — Activity Log** | CertificateRecordLogs | Nhật ký chứng chỉ hành nghề | Securities Practitioner License Certificate Document Activity Log |
| **[Involved Party] Individual Employment Status** | ProfessionalWorkHistories | Lịch sử làm việc của người hành nghề | Securities Practitioner Employment Status |
| **[Involved Party] Involved Party Relationship** | ProfessionalRelationships | Thông tin quan hệ gia đình/xã hội của người hành nghề | Securities Practitioner Related Party |
| **ETL Pattern — Audit Log** | ProfessionalHistories | Lịch sử thay đổi định danh cá nhân của người hành nghề | Securities Practitioner Audit Log |
| **[Business Activity] Conduct Violation** | Violations | Thông tin vi phạm của người hành nghề | Securities Practitioner Conduct Violation |
| **[Documentation] Employer Registration** | OrganizationReports | Báo cáo về người hành nghề từ tổ chức | Securities Practitioner Organization Employment Report |
| **[Communication] Verification** | IdentityInfoC06s | Lịch sử kiểm tra xác thực với C06 | Securities Practitioner Identity Verification Record |

### Nhóm C — Đào tạo & Thi sát hạch (Training & Examination)

| BCV Concept | Source Tables | Mô tả bảng nguồn | Silver Entities |
|---|---|---|---|
| **[Event] Training Course** | SpecializationCourses | Danh mục khóa học chuyên môn | Securities Practitioner Professional Training Class |
| **[Business Activity] Business Activity** | SpecializationCourseDetails | Chi tiết người tham gia khóa học chuyên môn | Securities Practitioner Professional Training Class Enrollment |
| **[Communication] Assessment** | ExamSessions | Danh mục các đợt thi sát hạch | Securities Practitioner Qualification Examination Assessment |
| **[Communication] Assessment** | ExamDetails | Kết quả các kỳ thi sát hạch | Securities Practitioner Qualification Examination Assessment Result |
| **[Condition] Financial Charge** | ExamSessionFees | Phí thi sát hạch | Securities Practitioner Qualification Examination Assessment Fee |

### Nhóm E — Danh mục & Tham chiếu (Reference Data)

**Classification Value** (load vào `Silver.Classification_Value`):

| Source Tables | Mô tả bảng nguồn | Classification Scheme | Ghi chú BCV |
|---|---|---|---|
| EducationLevels | Danh mục trình độ học vấn | Education Level | |
| ApplicationStatuses | Định nghĩa các trạng thái của hồ sơ | Application Status | |
| Certificates | Danh mục các loại chứng chỉ hành nghề | Certificate Type | |
| Specializations | Danh mục chuyên môn/chứng chỉ chuyên môn | Specialization | |
| Documents | Danh mục tài liệu liên quan đến hồ sơ hoặc chứng chỉ | Document Type | |
| ApplicationSources | Hình thức nộp hồ sơ | Application Source | |
| Positions | Danh mục chức vụ | Employment Position Type | BCV reference data set: "Distinguishes between Employment Positions according to the nature of the position which may be the specific label or job title assigned to an incumbent" |

**Silver Entities:**

| BCV Concept | Source Tables | Mô tả bảng nguồn | Silver Entities |
|---|---|---|---|
| **[Involved Party] Organization** | Organizations | Thông tin các tổ chức (CTCK, QLQ, Ngân hàng, ...) | Securities Organization Reference |
| **[Documentation] Gov. Registration Document** | Decisions | Danh mục các quyết định hành chính | Securities Practitioner License Decision Document |
| **[Involved Party] Organization** | Units + Departments | Đơn vị + Phòng ban UBCKNN (gộp — cấu trúc tương tự, số trường ít) | Regulatory Authority Organization Unit |
| **[Involved Party] Individual** | Users | Thông tin người dùng hệ thống | Regulatory Authority Officer |

### Shared Entities

| BCV Concept | Source Tables | Mô tả bảng nguồn | Silver Entities |
|---|---|---|---|
| **Shared Entities** | (nhiều bảng) | *(suy luận: tách từ Professionals và các bảng liên quan)* | Involved Party Postal Address, Electronic Address, Alternative Identification |
