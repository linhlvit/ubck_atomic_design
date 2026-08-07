# DTM_NHNCK_HLD — High Level Design
**Module:** NHNCK — Người hành nghề chứng khoán  
**Phiên bản:** 6.3  
**Ngày:** 27/04/2026  
**Phạm vi:** Tab THỐNG KÊ CHUNG + Tab TRA CỨU HỒ SƠ 360° + Tab DATA EXPLORER

---

## Section 1 — Data Lineage: Source → Atomic → Data Mart

##### Cụm 1: Chứng chỉ hành nghề — Thống kê tổng hợp (`Fact Practitioner License Certificate Snapshot`)

Phục vụ **Tab THỐNG KÊ CHUNG** — Nhóm 1a (KPI thẻ đếm CCHN theo trạng thái) và Nhóm 3 (Cơ cấu theo loại hình CCHN).

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        NHNCK_CertificateRecords["NHNCK.CertificateRecords"]
        NHNCK_Decisions["NHNCK.Decisions"]
        NHNCK_Professionals["NHNCK.Professionals"]
        NHNCK_ProfessionalHistories["NHNCK.ProfessionalHistories"]
        NHNCK_Certificates["NHNCK.Certificates"]
        ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end

    subgraph SIL["Atomic"]
        Securities_Practitioner_License_Certificate_Document["Securities Practitioner License Certificate Document"]
        Securities_Practitioner_License_Decision_Document["Securities Practitioner License Decision Document"]
        Securities_Practitioner["Securities Practitioner"]
        Calendar_Date["Calendar Date"]
        SP_License_Certificate_Type["SP License Certificate Type"]
    end

    subgraph GOLD["Datamart"]
        fct_practitioner_license_certificate_snpst["Fact Practitioner License Certificate Snapshot"]
        securities_practitioner_dim["Securities Practitioner Dimension"]
        cdr_dt_dim["Calendar Date Dimension"]
        sp_license_certificate_type_dim["SP License Certificate Type Dimension"]
    end

    NHNCK_CertificateRecords --> Securities_Practitioner_License_Certificate_Document
    NHNCK_Decisions --> Securities_Practitioner_License_Decision_Document
    NHNCK_Professionals --> Securities_Practitioner
    NHNCK_ProfessionalHistories --> Securities_Practitioner
    NHNCK_Certificates --> SP_License_Certificate_Type
    ECAT_ECAT_29_HolidayInfo --> Calendar_Date

    Securities_Practitioner_License_Certificate_Document --> fct_practitioner_license_certificate_snpst
    Securities_Practitioner_License_Decision_Document --> fct_practitioner_license_certificate_snpst
    Securities_Practitioner --> securities_practitioner_dim
    Calendar_Date --> cdr_dt_dim
    SP_License_Certificate_Type --> sp_license_certificate_type_dim

    securities_practitioner_dim --> fct_practitioner_license_certificate_snpst
    cdr_dt_dim --> fct_practitioner_license_certificate_snpst
    sp_license_certificate_type_dim --> fct_practitioner_license_certificate_snpst
```

**(Sửa 2026-08)** `Is Reissue Indicator`/`Certificate Issue Date` nay lấy từ `Securities Practitioner License Certificate Document`/`Securities Practitioner License Decision Document` (join qua `issue_sp_license_decision_document_id`, filter Decision Type Code = '1' Cấp mới / '3' Cấp lại) — không còn qua `Securities Practitioner License Application` (xem O_NHNCK_20, O_NHNCK_29).

---

##### Cụm 2: Người hành nghề — Thống kê tổng hợp (`Fact Practitioner Daily Snapshot`)

Phục vụ **Tab THỐNG KÊ CHUNG** — Nhóm 1b (Tổng NHN, Cảnh báo NHNCK), Nhóm 2 (Trình độ chuyên môn), Nhóm 4 (Phân bổ độ tuổi).

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        NHNCK_Professionals["NHNCK.Professionals"]
        NHNCK_ProfessionalHistories["NHNCK.ProfessionalHistories"]
        NHNCK_Violations["NHNCK.Violations"]
        ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end

    subgraph SIL["Atomic"]
        Securities_Practitioner["Securities Practitioner"]
        Securities_Practitioner_Conduct_Violation["Securities Practitioner Conduct Violation"]
        Calendar_Date["Calendar Date"]
    end

    subgraph GOLD["Datamart"]
        fct_practitioner_daily_snpst["Fact Practitioner Daily Snapshot"]
        securities_practitioner_dim["Securities Practitioner Dimension"]
        cdr_dt_dim["Calendar Date Dimension"]
    end

    NHNCK_Professionals --> Securities_Practitioner
    NHNCK_ProfessionalHistories --> Securities_Practitioner
    NHNCK_Violations --> Securities_Practitioner_Conduct_Violation
    ECAT_ECAT_29_HolidayInfo --> Calendar_Date

    Securities_Practitioner --> fct_practitioner_daily_snpst
    Securities_Practitioner --> securities_practitioner_dim
    Securities_Practitioner_Conduct_Violation --> fct_practitioner_daily_snpst
    Calendar_Date --> cdr_dt_dim

    securities_practitioner_dim --> fct_practitioner_daily_snpst
    cdr_dt_dim --> fct_practitioner_daily_snpst
```

---

##### Cụm 3: Tra cứu NHN 360° — Danh sách & Header (`Operational Practitioner 360 Profile`)

Phục vụ **Tab TRA CỨU HỒ SƠ 360°** — Nhóm 5 (màn hình danh sách tra cứu và header thông tin tổng quát của từng NHN).

```mermaid
flowchart LR
    subgraph SRC["Source NHNCK (MySQL)"]
        S1["NHNCK.Professionals"]
        S2["NHNCK.ProfessionalHistories"]
        S3["NHNCK.CertificateRecords"]
    end

    subgraph SIL["Atomic"]
        SV1["Securities Practitioner"]
        SV2["Securities Practitioner License Certificate Document"]
    end

    subgraph Datamart["Datamart"]
        G1["Operational Practitioner 360 Profile"]
    end

    S1 --> SV1
    S2 --> SV1
    S3 --> SV2

    SV1 --> G1
    SV2 --> G1
```

---

##### Cụm 4: Mạng lưới người liên quan (`Operational Practitioner Related Party Profile`)

Phục vụ **Tab TRA CỨU HỒ SƠ 360°** — Nhóm 6 (Mạng lưới người liên quan).

```mermaid
flowchart LR
    subgraph SRC["Source NHNCK (MySQL)"]
        S1["NHNCK.ProfessionalRelationships"]
    end

    subgraph SIL["Atomic"]
        SV1["Securities Practitioner Related Party"]
    end

    subgraph Datamart["Datamart"]
        G1["Operational Practitioner Related Party Profile"]
    end

    S1 --> SV1
    SV1 --> G1
```

---

##### Cụm 5: Vai trò tại DN niêm yết (`Operational Practitioner Listed Company Role`)

Phục vụ **Tab TRA CỨU HỒ SƠ 360°** — Nhóm 7 (Vai trò tại DN niêm yết/UPCOM, Tài khoản cross-broker PENDING).

```mermaid
flowchart LR
    subgraph SRC["Source NHNCK (MySQL)"]
        S1["NHNCK.OrganizationReports"]
        S2["NHNCK.Organizations"]
    end

    subgraph SIL["Atomic"]
        SV1["Securities Practitioner Organization Employment Report"]
        SV2["Securities Organization Reference"]
    end

    subgraph Datamart["Datamart"]
        G1["Operational Practitioner Listed Company Role"]
    end

    S1 --> SV1
    S2 --> SV2

    SV1 --> G1
    SV2 --> G1
```

---

##### Cụm 6: Lịch sử cấp CCHN (`Operational Practitioner Certificate History`)

Phục vụ **Tab TRA CỨU HỒ SƠ 360°** — Nhóm 9 (sub-tab Lịch sử cấp chứng chỉ hành nghề).

```mermaid
flowchart LR
    subgraph SRC["Source NHNCK (MySQL)"]
        S1["NHNCK.CertificateRecords"]
        S2["NHNCK.Decisions"]
    end

    subgraph SIL["Atomic"]
        SV1["Securities Practitioner License Certificate Document"]
        SV2["Securities Practitioner License Decision Document"]
    end

    subgraph Datamart["Datamart"]
        G1["Operational Practitioner Certificate History"]
    end

    S1 --> SV1
    S2 --> SV2

    SV1 --> G1
    SV2 --> G1
```

---

##### Cụm 7: Quá trình hành nghề (`Operational Practitioner Employment History`)

Phục vụ **Tab TRA CỨU HỒ SƠ 360°** — Nhóm 8 (sub-tab Quá trình hành nghề).

```mermaid
flowchart LR
    subgraph SRC["Source NHNCK (MySQL)"]
        S1["NHNCK.OrganizationReports"]
        S2["NHNCK.Organizations"]
    end

    subgraph SIL["Atomic"]
        SV1["Securities Practitioner Organization Employment Report"]
        SV2["Securities Organization Reference"]
    end

    subgraph Datamart["Datamart"]
        G1["Operational Practitioner Employment History"]
    end

    S1 --> SV1
    S2 --> SV2

    SV1 --> G1
    SV2 --> G1
```

> **Ghi chú Cụm 7:** Nguồn chính từ `NHNCK.OrganizationReports`; join thêm `Securities Organization Reference` để lấy tên tổ chức và phân loại. Không có Atomic entity từ `ProfessionalWorkHistories` trong scope này.

---

##### Cụm 8: Lịch sử vi phạm & xử phạt (`Operational Practitioner Violation History`)

Phục vụ **Tab TRA CỨU HỒ SƠ 360°** — Nhóm 12 (sub-tab Lịch sử vi phạm & xử phạt hành chính).

```mermaid
flowchart LR
    subgraph SRC["Source NHNCK (MySQL)"]
        S1["NHNCK.Violations"]
        S2["NHNCK.Decisions"]
    end

    subgraph SIL["Atomic"]
        SV1["Securities Practitioner Conduct Violation"]
        SV2["Securities Practitioner License Decision Document"]
    end

    subgraph Datamart["Datamart"]
        G1["Operational Practitioner Violation History"]
    end

    S1 --> SV1
    S2 --> SV2

    SV1 --> G1
    SV2 --> G1
```

---

##### Cụm 9: Đợt thi sát hạch (`Operational Practitioner Exam History`)

Phục vụ **Tab TRA CỨU HỒ SƠ 360°** — Nhóm 10 (sub-tab Đợt thi sát hạch).

```mermaid
flowchart LR
    subgraph SRC["Source NHNCK (MySQL)"]
        S1["NHNCK.ExamSessions"]
        S2["NHNCK.ExamDetails"]
        S3["NHNCK.Decisions"]
    end

    subgraph SIL["Atomic"]
        SV1["Securities Practitioner Qualification Examination Assessment"]
        SV2["Securities Practitioner Qualification Examination Assessment Result"]
        SV3["Securities Practitioner License Decision Document"]
    end

    subgraph Datamart["Datamart"]
        G1["Operational Practitioner Exam History"]
    end

    S1 --> SV1
    S2 --> SV2
    S3 --> SV3

    SV1 --> G1
    SV2 --> G1
    SV3 --> G1
```

---

##### Cụm 10: Cập nhật kiến thức hành nghề (`Operational Practitioner Training History`)

Phục vụ **Tab TRA CỨU HỒ SƠ 360°** — Nhóm 11 (sub-tab Cập nhật kiến thức hành nghề).

```mermaid
flowchart LR
    subgraph SRC["Source NHNCK (MySQL)"]
        S1["NHNCK.PostCertTrainingResults"]
        S2["NHNCK.PostCertTrainingCourses"]
        S3["NHNCK.SpecializationCourseDetails"]
    end

    subgraph SIL["Atomic"]
        SV1["Securities Practitioner Post Certification Training Result"]
        SV2["Securities Practitioner Post Certification Training Course"]
        SV3["Securities Practitioner Professional Training Class Enrollment"]
    end

    subgraph Datamart["Datamart"]
        G1["Operational Practitioner Training History"]
    end

    S1 --> SV1
    S2 --> SV2
    S3 --> SV3

    SV1 --> G1
    SV2 --> G1
    SV3 --> G1
```

**(Sửa 2026-08)** Driving đổi từ `Securities Practitioner Professional Training Class Enrollment` sang `Securities Practitioner Post Certification Training Result` — theo BA SQL tham khảo mới (xem O_NHNCK_9). Enrollment nay chỉ còn là JOIN phụ qua `sp_code` (fan-out) để lấy Exam Score/Kết quả kiểm tra.

---

##### Cụm 11: Data Explorer — Tra cứu danh sách CCHN (`Operational Practitioner Data Explorer`)

Phục vụ **Tab DATA EXPLORER** — Nhóm 13 (bảng tra cứu flat toàn bộ CCHN theo filter Loại chứng chỉ và Trạng thái). Lấy trực tiếp từ Atomic, không khai thác qua Fact/Dim.

```mermaid
flowchart LR
    subgraph SRC["Source NHNCK (MySQL)"]
        S1["NHNCK.CertificateRecords"]
        S2["NHNCK.Professionals"]
        S3["NHNCK.ProfessionalHistories"]
        S4["NHNCK.OrganizationReports"]
    end

    subgraph SIL["Atomic"]
        SV1["Securities Practitioner License Certificate Document"]
        SV2["Securities Practitioner"]
        SV3["Securities Practitioner Organization Employment Report"]
    end

    subgraph Datamart["Datamart"]
        G1["Operational Practitioner Data Explorer"]
    end

    S1 --> SV1
    S2 --> SV2
    S3 --> SV2
    S4 --> SV3

    SV1 --> G1
    SV2 --> G1
    SV3 --> G1
```

---

## Section 2 — Tổng quan báo cáo

### Tab: THỐNG KÊ CHUNG

**Slicer chung:** Năm (Year) — lấy từ `Calendar Date Dimension`. KPI lũy kế tính đến cuối năm đã chọn; KPI YTD (năm hiện tại) tính từ 01/01 đến today; KPI năm quá khứ tính đến 31/12/Y.

---

#### Nhóm 1a — Chứng chỉ hành nghề — Thống kê tổng hợp (KPI thẻ CCHN)

> Phân loại: **Phân tích**
> Atomic: `Securities Practitioner License Certificate Document` ← NHNCK.CertificateRecords — **READY**
> Atomic: `Securities Practitioner License Decision Document` ← NHNCK.Decisions — **READY**
> Atomic: `Securities Practitioner` ← NHNCK.Professionals / NHNCK.ProfessionalHistories — **READY** (dùng cho K_NHNCK_7)
> Atomic: `SP License Certificate Type` ← NHNCK.CERTIFICATES — **READY**
> Ghi chú: FK đến `SP License Certificate Type Dimension` qua surrogate Id `Certificate_Type_Dimension_Id` — không lưu `Certificate_Type_Code` dư thừa trên Fact (đã xoá 2026-08, filter/display theo loại CCHN phải join Dimension). Certificate Status không lưu trong Fact — staging đã lọc chỉ bản ghi hiệu lực.

**Mockup:**

| KPI thẻ | Giá trị | So sánh cùng kỳ |
|---|---|---|
| Chứng chỉ cấp mới (YTD) | 1,580 CCHN (Cấp mới: 1,290 / Cấp lại: 290) | +13.7% |
| Bị thu hồi | 95 CCHN | +8% |
| CCHN đang hoạt động | 20,180 CCHN | +7.7% |
| Thu hồi thuộc trường hợp được cấp lại | 312 CCHN | -12.2% |
| Thu hồi thuộc trường hợp không được cấp lại | 98 CCHN | +11.4% |
| CCHN Đã bị hủy | 750 CCHN | -5% |

**Source:** `Fact Practitioner License Certificate Snapshot` → `Securities Practitioner Dimension`, `Calendar Date Dimension`, `SP License Certificate Type Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú |
|---|---|---|---|---|---|
| K_NHNCK_2 | Chứng chỉ cấp mới (YTD) | CCHN | Phái sinh | COUNT(DISTINCT Certificate Number) WHERE Decision Type = '1' (Cấp mới) AND Issue Date trong năm chọn + COUNT(DISTINCT Certificate Number) WHERE Decision Type = '3' (Cấp lại) AND Issue Date trong năm chọn (= K_NHNCK_2a + K_NHNCK_2b) | (Sửa 2026-08) Đổi nguồn phân loại Cấp mới/Cấp lại từ Application Type sang Decision Type — đúng theo BA join Certificate_Records.REVOCATION_DECISION_ID = DECISIONS.ID, filter DECISION_TYPE_ID. Application Type đo hồ sơ nộp, không phải quyết định đã cấp — có thể lệch khi hồ sơ bị từ chối hoặc đổi loại giữa quy trình xử lý. (Sửa 2026-07-30) Tổng 2 COUNT(DISTINCT...) tách theo nhánh cấp mới/cấp lại — đảm bảo luôn bằng đúng 2a+2b kể cả khi 1 CCHN vừa cấp mới vừa cấp lại trong cùng năm. (Sửa 2026-08 — review `/datamart-review`) BA đổi lại join key từ `REVOCATION_DECISION_ID` sang `ISSUE_DECISION_ID` — xem O_NHNCK_29. Xem O_NHNCK_19, O_NHNCK_20, O_NHNCK_29. Lưu ý khi viết Detail Mapping: viết đủ công thức physical theo 2 nhánh, KHÔNG refer trực tiếp KPI_ID K_NHNCK_2a/2b trong cột `logic` (vi phạm quy tắc DERIVED của datamart-lld-design) |
| K_NHNCK_2a | Cấp mới (lần đầu) | CCHN | Phái sinh | COUNT(DISTINCT Certificate Number) WHERE Decision Type = '1' (Cấp mới) AND Issue Date trong năm chọn | Sub-component của K_NHNCK_2 — đếm số CCHN khác nhau có ít nhất 1 lần cấp mới trong năm |
| K_NHNCK_2b | Cấp lại | CCHN | Phái sinh | COUNT(DISTINCT Certificate Number) WHERE Decision Type = '3' (Cấp lại) AND Issue Date trong năm chọn | Sub-component của K_NHNCK_2 — đếm số CCHN khác nhau có ít nhất 1 lần cấp lại trong năm. Lưu ý: 1 CCHN vừa cấp mới vừa cấp lại trong cùng năm được đếm ở CẢ 2a và 2b (không loại trừ lẫn nhau) — theo thiết kế K_NHNCK_2 = 2a + 2b |
| K_NHNCK_2_YOY | So sánh cùng kỳ — CCHN cấp mới YTD | % | Phái sinh | (K_NHNCK_2[Y] − K_NHNCK_2[Y−1]) / K_NHNCK_2[Y−1] × 100% | |
| K_NHNCK_3 | Bị thu hồi (lũy kế) | CCHN | Phái sinh | COUNT(DISTINCT Certificate Number) WHERE Decision Type = '2' (Thu hồi) AND Revocation Date ≤ 31/12/Y (quá khứ) hoặc ≤ MAX(Snapshot Date) trong Y (hiện tại) | Nguồn: Certificate_Records JOIN DECISIONS |
| K_NHNCK_3_YOY | So sánh cùng kỳ — Bị thu hồi | % | Phái sinh | (K_NHNCK_3[Y] − K_NHNCK_3[Y−1]) / K_NHNCK_3[Y−1] × 100% | |
| K_NHNCK_5 | CCHN đang hoạt động (lũy kế) | CCHN | Phái sinh | COUNT(DISTINCT Certificate Number) của các NHN có Practice Status Code = '1' (STATUS_WORK=1) AND Snapshot Date = 31/12/Y (quá khứ) hoặc MAX(Snapshot Date) trong Y (hiện tại) | (Sửa 2026-07-17) Bổ sung filter Practice Status Code — ghi chú cũ "staging đã lọc chỉ bản ghi hiệu lực" không đúng, staging/ODS không filter RECORD_STATUS |
| K_NHNCK_5_YOY | So sánh cùng kỳ — CCHN đang hoạt động | % | Phái sinh | (K_NHNCK_5[Y] − K_NHNCK_5[Y−1]) / K_NHNCK_5[Y−1] × 100% | |
| K_NHNCK_6 | Thu hồi thuộc trường hợp được cấp lại (lũy kế) | CCHN | Phái sinh | COUNT(DISTINCT Certificate Number) của các NHN có Practice Status Code = '2' (STATUS_WORK=2) AND Decision Type = '2' AND Revocation Date ≤ 31/12/Y (quá khứ) hoặc ≤ MAX(Snapshot Date) trong Y (hiện tại) | (Sửa 2026-07-20) Đổi tên theo BA mới — "CCHN Thu hồi 3 năm" là tên diễn giải cũ, dễ gây hiểu lầm về thời hạn cụ thể; tên mới bám sát đúng định nghĩa STATUS_WORK=2 (Thu hồi có cấp lại). Logic không đổi |
| K_NHNCK_6_YOY | So sánh cùng kỳ — Thu hồi thuộc trường hợp được cấp lại | % | Phái sinh | (K_NHNCK_6[Y] − K_NHNCK_6[Y−1]) / K_NHNCK_6[Y−1] × 100% | |
| K_NHNCK_7 | Thu hồi thuộc trường hợp không được cấp lại (lũy kế) | CCHN | Phái sinh | COUNT(DISTINCT Certificate Number) của các NHN có Practice Status Code = '3' (STATUS_WORK=3) AND Decision Type = '2' AND Snapshot Date = 31/12/Y (quá khứ) hoặc MAX(Snapshot Date) trong Y (hiện tại) | (Sửa 2026-07-20) Đổi tên theo BA mới — "CCHN Thu hồi vĩnh viễn" là tên diễn giải cũ; tên mới bám sát đúng định nghĩa STATUS_WORK=3 (Thu hồi không cấp lại). Logic không đổi |
| K_NHNCK_7_YOY | So sánh cùng kỳ — Thu hồi thuộc trường hợp không được cấp lại | % | Phái sinh | (K_NHNCK_7[Y] − K_NHNCK_7[Y−1]) / K_NHNCK_7[Y−1] × 100% | |
| K_NHNCK_8 | CCHN Đã bị hủy (lũy kế) | CCHN | Phái sinh | COUNT(DISTINCT Certificate Number) WHERE Decision Type = '6' (Hủy CCHN) AND Revocation Date ≤ 31/12/Y (quá khứ) hoặc ≤ MAX(Snapshot Date) trong Y (hiện tại) | Nguồn: Certificate_Records JOIN DECISIONS |
| K_NHNCK_8_YOY | So sánh cùng kỳ — Đã bị hủy | % | Phái sinh | (K_NHNCK_8[Y] − K_NHNCK_8[Y−1]) / K_NHNCK_8[Y−1] × 100% | |

> **Ghi chú KPI:** K_NHNCK_7 đếm **CCHN** (không phải NHN) — nguồn `Professionals.STATUS_WORK='3'` nhưng đếm Certificate_Number. ETL join `securities_practitioner (Practice_Status_Code='3') → sp_license_certificate_document` để lấy danh sách CCHN của các NHN thuộc trường hợp thu hồi không được cấp lại. K_NHNCK_15 và K_NHNCK_16 không sử dụng — gap do điều chỉnh phân loại, không re-number.

**Star Schema — Nhóm 1a (Fact Practitioner License Certificate Snapshot):**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Practitioner_License_Certificate_Snapshot : " "
    Securities_Practitioner_Dimension ||--o{ Fact_Practitioner_License_Certificate_Snapshot : " "
    SP_License_Certificate_Type_Dimension ||--o{ Fact_Practitioner_License_Certificate_Snapshot : " "

    Fact_Practitioner_License_Certificate_Snapshot {
        string Practitioner_Dimension_Id FK
        string Issue_Date_Dimension_Id FK
        string Snapshot_Date_Dimension_Id FK
        string Certificate_Type_Dimension_Id FK
        varchar License_Certificate_Document_Code
        varchar Certificate_Number
        varchar Is_Reissue_Indicator
        date Certificate_Issue_Date
        date Revocation_Date
        string Decision_Type_Code
    }

    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        varchar Holiday_Flag
        string Source_System_Code
    }

    Securities_Practitioner_Dimension {
        string Securities_Practitioner_Dimension_Id PK
        varchar Practitioner_Code
        varchar Full_Name
        varchar Education_Level_Code
        varchar Education_Level_Name
        varchar Nationality_Code
        date Birth_Date
        varchar Practice_Status_Code
        varchar Practice_Status_Name
        string Source_System_Code
    }

    SP_License_Certificate_Type_Dimension {
        string Certificate_Type_Dimension_Id PK
        varchar Certificate_Type_Code
        varchar Certificate_Type_Name
        string Source_System_Code
    }
```

> **Ghi chú erDiagram:** Fact có FK đến `SP_License_Certificate_Type_Dimension` qua `Certificate_Type_Dimension_Id` — (Sửa 2026-08) đã xoá `Certificate_Type_Code` dư thừa khỏi Fact; filter/display theo loại CCHN (K_NHNCK_17–22) phải JOIN Dimension, không đọc trực tiếp trên Fact. Certificate Status không lưu trong Fact — staging đã lọc chỉ bản ghi hiệu lực. `License_Certificate_Document_Code` là DD — business key của **bản ghi** `CERTIFICATE_RECORDS` (1 dòng Fact = 1 lần cấp/cấp lại), KHÔNG phải business key của CCHN — 1 CCHN có thể có nhiều `License_Certificate_Document_Code` khác nhau qua các lần cấp/thu hồi/cấp lại. `Certificate_Number` (Sửa 2026-08, review `/datamart-review` — phát hiện BA đếm `COUNT(DISTINCT Certificate_Number)` trong khi Fact trước đó chỉ có `License_Certificate_Document_Code`) — số CCHN nghiệp vụ thật, `direct` từ `Securities Practitioner License Certificate Document.Certificate Number` (`certificate_nbr`); đây mới là DD dùng để `COUNT(DISTINCT ...)` cho mọi KPI đếm số CCHN (K_NHNCK_2/2a/2b/3/5/6/7/8/17/18/19) — `License_Certificate_Document_Code` giữ vai trò PK/degenerate key của Fact, không dùng làm đơn vị đếm nữa. `Is_Reissue_Indicator` — (Sửa 2026-08, review `/datamart-review`) ETL-derived từ Decision Type (JOIN `Securities Practitioner License Decision Document` qua `issue_sp_license_decision_document_id` — đổi từ `revocation_sp_license_decision_document_id`, xem O_NHNCK_29): Y nếu Decision Type Code = '3' (Cấp lại), N nếu = '1' (Cấp mới), NULL nếu chưa có quyết định — không còn dựa trên Application Type, xem O_NHNCK_20. `Certificate_Issue_Date`/`Issue_Date_Dimension_Id` — (Sửa 2026-08) lấy trực tiếp từ `Securities Practitioner License Certificate Document.Issue Date`, không còn qua Application. `Decision_Type_Code` — Classification Value (scheme: LICENSE_CERTIFICATE_DECISION_TYPE: 2=Thu hồi, 6=Hủy CCHN), NULL nếu chưa có quyết định — phục vụ filter K_NHNCK_3, K_NHNCK_6, K_NHNCK_7, K_NHNCK_8. Fact có 2 FK date: `Issue_Date_Dimension_Id` (ngày cấp) và `Snapshot_Date_Dimension_Id` (ngày chụp trạng thái) — cả 2 đều trỏ về `Calendar_Date_Dimension`. (Sửa 2026-07-17) `Allow_Reissue_Indicator` đã loại khỏi schema — K_NHNCK_6 đổi sang dùng `Practice_Status_Code` (join `Securities_Practitioner_Dimension`), xem O_NHNCK_1 (revised).

**Lineage Mart → Báo cáo — Nhóm 1a:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        fct_practitioner_license_certificate_snpst["Fact Practitioner License Certificate Snapshot"]
        securities_practitioner_dim["Securities Practitioner Dimension"]
        cdr_dt_dim["Calendar Date Dimension"]
        sp_license_ctf_tp_dim["SP License Certificate Type Dimension"]
    end
    subgraph RPT["Bao cao - Nhom 1a"]
        R1["K_NHNCK_2/2a/2b: CCHN cap moi YTD"]
        R2["K_NHNCK_3: Bi thu hoi"]
        R3["K_NHNCK_5: CCHN dang hoat dong"]
        R4["K_NHNCK_6: Thu hoi 3 nam"]
        R5["K_NHNCK_7: Thu hoi vinh vien"]
        R6["K_NHNCK_8: Da bi huy"]
    end
    fct_practitioner_license_certificate_snpst --> R1
    fct_practitioner_license_certificate_snpst --> R2
    fct_practitioner_license_certificate_snpst --> R3
    fct_practitioner_license_certificate_snpst --> R4
    fct_practitioner_license_certificate_snpst --> R5
    fct_practitioner_license_certificate_snpst --> R6
    securities_practitioner_dim --> fct_practitioner_license_certificate_snpst
    cdr_dt_dim --> fct_practitioner_license_certificate_snpst
    sp_license_ctf_tp_dim --> fct_practitioner_license_certificate_snpst
```

**Bảng grain — Nhóm 1a:**

| Tên bảng | Grain |
|---|---|
| `Fact Practitioner License Certificate Snapshot` | 1 CCHN × 1 tháng snapshot (cuối tháng) |
| `Securities Practitioner Dimension` | 1 NHN per SCD4A (current state) |
| `Calendar Date Dimension` | 1 ngày |
| `SP License Certificate Type Dimension` | 1 loại CCHN per SCD4A (current state) |

---

#### Nhóm 1b — Người hành nghề — Thống kê tổng hợp (KPI thẻ NHN)

> Phân loại: **Phân tích**
> Atomic: `Securities Practitioner` ← NHNCK.Professionals / NHNCK.ProfessionalHistories — **READY**
> Atomic: `Securities Practitioner Conduct Violation` ← NHNCK.Violations — **READY**

**Mockup:**

| KPI thẻ | Giá trị | So sánh cùng kỳ |
|---|---|---|
| Tổng người hành nghề | 21,340 NHN | +7.7% |
| Cảnh báo NHNCK | 148 NHN | +8.8% |

**Source:** `Fact Practitioner Daily Snapshot` → `Securities Practitioner Dimension`, `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú |
|---|---|---|---|---|---|
| K_NHNCK_1 | Tổng người hành nghề | NHN | Phái sinh | COUNT(DISTINCT Practitioner Code) WHERE Snapshot Date = 31/12/Y (quá khứ) hoặc MAX(Snapshot Date) trong Y (hiện tại) | Nguồn: Professionals. (Xác nhận 2026-07-17) Bám sát SQL BA gốc — không filter, đếm mọi NHN trong `Professionals`. BA Mô tả ghi "có ít nhất 1 CCHN" nhưng SQL tham khảo không JOIN `Certificate_Records` — giữ nguyên theo SQL, không tự suy diễn thêm điều kiện |
| K_NHNCK_1_YOY | So sánh cùng kỳ — Tổng NHN | % | Phái sinh | (K_NHNCK_1[Y] − K_NHNCK_1[Y−1]) / K_NHNCK_1[Y−1] × 100% | |
| K_NHNCK_4 | Cảnh báo NHNCK | NHN | Phái sinh | COUNT(DISTINCT Practitioner Code) WHERE Has Active Violation = 'Y' AND Snapshot Date = 31/12/Y (quá khứ) hoặc MAX(Snapshot Date) trong Y (hiện tại) | (Sửa 2026-07-21) Nguồn: `Professionals JOIN Violations` — SQL BA gốc chỉ JOIN kiểm tra tồn tại bản ghi vi phạm (`JOIN Violations v ON a.ID = v.Professional_Id`), không có điều kiện lọc trạng thái. Ghi chú công thức trước đây nhắc `Violation_Status_Code=1 (ACTIVE)` không khớp SQL BA — đã bỏ, xem O_NHNCK_5 |
| K_NHNCK_4_YOY | So sánh cùng kỳ — Cảnh báo | % | Phái sinh | (K_NHNCK_4[Y] − K_NHNCK_4[Y−1]) / K_NHNCK_4[Y−1] × 100% | |

**Star Schema — Nhóm 1b (Fact Practitioner Daily Snapshot):**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Practitioner_Daily_Snapshot : " "
    Securities_Practitioner_Dimension ||--o{ Fact_Practitioner_Daily_Snapshot : " "

    Fact_Practitioner_Daily_Snapshot {
        string Practitioner_Dimension_Id FK
        string Snapshot_Date_Dimension_Id FK
        int Age
        varchar Has_Active_Violation
    }

    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        varchar Holiday_Flag
        string Source_System_Code
    }

    Securities_Practitioner_Dimension {
        string Securities_Practitioner_Dimension_Id PK
        varchar Practitioner_Code
        varchar Full_Name
        varchar Education_Level_Code
        varchar Education_Level_Name
        varchar Nationality_Code
        date Birth_Date
        varchar Practice_Status_Code
        varchar Practice_Status_Name
        string Source_System_Code
    }
```

> **Ghi chú erDiagram:**
> - `Has_Active_Violation` = ETL-derived Indicator (Y/N): Y nếu NHN có ít nhất 1 bản ghi `Conduct Violation` (bất kỳ), N nếu không có — bám sát SQL BA gốc (`JOIN Violations`, không filter trạng thái). Phục vụ K_NHNCK_4 (filter = 'Y'). (Sửa 2026-07-17: đổi từ boolean sang Y/N cho đúng data domain Indicator; Sửa 2026-07-21: bỏ mô tả "đang active" — Atomic `sp_conduct_violation` không có field trạng thái vi phạm và SQL BA cũng không yêu cầu lọc, xem O_NHNCK_5)
> - `Age` = ETL-derived: Year(Snapshot_Date) − Year(Birth_Date). Phục vụ Nhóm 4.

**Lineage Mart → Báo cáo — Nhóm 1b:**

```mermaid
flowchart LR
    subgraph GOLD["Datamart"]
        fct_practitioner_daily_snpst["Fact Practitioner Daily Snapshot"]
        securities_practitioner_dim["Securities Practitioner Dimension"]
        cdr_dt_dim["Calendar Date Dimension"]
    end
    subgraph RPT["Bao cao - Nhom 1b"]
        R1["K_NHNCK_1: Tong NHN"]
        R2["K_NHNCK_4: Canh bao NHNCK"]
    end
    fct_practitioner_daily_snpst --> R1
    fct_practitioner_daily_snpst --> R2
    securities_practitioner_dim --> fct_practitioner_daily_snpst
    cdr_dt_dim --> fct_practitioner_daily_snpst
```

**Bảng grain — Nhóm 1b:**

| Tên bảng | Grain |
|---|---|
| `Fact Practitioner Daily Snapshot` | 1 NHN × 1 ngày snapshot |
| `Securities Practitioner Dimension` | 1 NHN per SCD4A (current state) |
| `Calendar Date Dimension` | 1 ngày |

---

#### Nhóm 2 — Biểu đồ Trình độ chuyên môn

> Phân loại: **Phân tích**
> Atomic: `Securities Practitioner` ← NHNCK.Professionals / NHNCK.ProfessionalHistories — **READY**

**Source:** `Fact Practitioner Daily Snapshot` → `Securities Practitioner Dimension`, `Calendar Date Dimension`

**Mockup:**

| Trình độ | Số NHN | Tỷ lệ |
|---|---|---|
| Tiến sĩ | 450 | 2.1% |
| Thạc sĩ | 5,200 | 24.4% |
| Đại học | 15,690 | 73.5% |

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú |
|---|---|---|---|---|---|
| K_NHNCK_9 | Số lượng NHN Tiến sĩ | Người | Base | COUNT(DISTINCT Dim.Practitioner Code) WHERE Dim.Education Level Code = 'Tiến sĩ' AND Snapshot_Date = 31/12/Y (quá khứ) hoặc MAX(Snapshot_Date) trong Y (hiện tại) | (Sửa 2026-08) Đổi code từ 'DOCTORATE' (bịa, không tồn tại) sang giá trị thật 'Tiến sĩ' — Atomic lưu cl_code trực tiếp bằng tiếng Việt, không phải code tiếng Anh. Xem O_NHNCK_21 |
| K_NHNCK_10 | Số lượng NHN Thạc sĩ | Người | Base | COUNT(DISTINCT Dim.Practitioner Code) WHERE Dim.Education Level Code = 'Thạc sĩ' AND Snapshot_Date = 31/12/Y (quá khứ) hoặc MAX(Snapshot_Date) trong Y (hiện tại) | (Sửa 2026-08) Đổi code từ 'MASTER' (bịa) sang giá trị thật 'Thạc sĩ'. Xem O_NHNCK_21 |
| K_NHNCK_11 | Số lượng NHN Đại học | Người | Base | COUNT(DISTINCT Dim.Practitioner Code) WHERE Dim.Education Level Code = 'Đại học' AND Snapshot_Date = 31/12/Y (quá khứ) hoặc MAX(Snapshot_Date) trong Y (hiện tại) | (Sửa 2026-08) Đổi code từ 'BACHELOR' (bịa) sang giá trị thật 'Đại học'. CHỈ tính đúng giá trị 'Đại học', KHÔNG gộp 'Cử nhân' (giá trị riêng, cùng tồn tại trong scheme EDUCATIONAL_LEVEL nhưng BA không đề cập) — xem O_NHNCK_21 |
| K_NHNCK_12 | Tỷ lệ Tiến sĩ | % | Derived | K_NHNCK_9 / K_NHNCK_1 × 100% | |
| K_NHNCK_13 | Tỷ lệ Thạc sĩ | % | Derived | K_NHNCK_10 / K_NHNCK_1 × 100% | |
| K_NHNCK_14 | Tỷ lệ Đại học | % | Derived | K_NHNCK_11 / K_NHNCK_1 × 100% | |

**Star Schema — Nhóm 2 (Fact Practitioner Daily Snapshot):**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Practitioner_Daily_Snapshot : " "
    Securities_Practitioner_Dimension ||--o{ Fact_Practitioner_Daily_Snapshot : " "

    Fact_Practitioner_Daily_Snapshot {
        string Practitioner_Dimension_Id FK
        string Snapshot_Date_Dimension_Id FK
        int Age
        varchar Has_Active_Violation
    }

    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        varchar Holiday_Flag
        string Source_System_Code
    }

    Securities_Practitioner_Dimension {
        string Securities_Practitioner_Dimension_Id PK
        varchar Practitioner_Code
        varchar Full_Name
        varchar Education_Level_Code
        varchar Education_Level_Name
        varchar Nationality_Code
        date Birth_Date
        varchar Practice_Status_Code
        varchar Practice_Status_Name
        string Source_System_Code
    }
```

> **Ghi chú Fact Practitioner Daily Snapshot:**
> - Grain ngày: ETL append 1 row per NHN mỗi ngày. Slicer "chọn năm Y" = filter `Snapshot_Date = 31/12/Y` (năm quá khứ) hoặc `Snapshot_Date = MAX(Snapshot_Date) WHERE Year = Y` (năm hiện tại = ngày mới nhất có dữ liệu).
> - `Age` = ETL-derived int = Year(Snapshot_Date) − Year(Birth_Date), tính từ `ProfessionalHistories.BirthDate`. Presentation layer tự nhóm thành age bands.
> - `Has_Active_Violation` = ETL-derived Indicator (Y/N): Y nếu NHN có ít nhất 1 bản ghi `Conduct Violation` (bất kỳ), N nếu không có — bám sát SQL BA gốc (`JOIN Violations`, không filter trạng thái). Xem O_NHNCK_5. Phục vụ K_NHNCK_4 (filter = 'Y'). (Sửa 2026-07-17: đổi từ boolean sang Y/N; Sửa 2026-07-21: bỏ mô tả "Violation_Status_Code=1 (ACTIVE)" — Atomic không có field này và SQL BA cũng không yêu cầu lọc trạng thái)
> - Thông tin Education_Level_Code/Name, Nationality_Code, Practitioner_Code, Practice_Status_Code/Name đọc qua JOIN `Securities Practitioner Dimension`. (Bổ sung 2026-08) `Education_Level_Name`/`Practice_Status_Name` — ETL-derived, denormalize từ Classification tại thời điểm populate Dimension; không gắn KPI riêng, chỉ là metadata mô tả bổ sung theo coverage rule cho Dimension.

**Lineage Mart → Báo cáo — Nhóm 2:**

```mermaid
flowchart LR
    subgraph Datamart["Datamart"]
        G1["Fact Practitioner Daily Snapshot"]
        G2["Securities Practitioner Dimension"]
        G3["Calendar Date Dimension"]
    end
    subgraph RPT["Bao cao - Nhom 2"]
        R1["K_NHNCK_9-11: So luong NHN theo trinh do"]
        R2["K_NHNCK_12-14: Ty le trinh do"]
    end
    G1 --> R1
    G1 --> R2
    G2 --> G1
    G3 --> G1
```

**Bảng grain — Nhóm 2:**

| Tên bảng | Grain |
|---|---|
| `Fact Practitioner Daily Snapshot` | 1 NHN × 1 ngày snapshot |
| `Securities Practitioner Dimension` | 1 NHN per SCD4A (current state) |
| `Calendar Date Dimension` | 1 ngày |

---

#### Nhóm 3 — Biểu đồ cơ cấu theo loại hình CCHN

> Phân loại: **Phân tích**
> Atomic: `Securities Practitioner License Certificate Document` ← NHNCK.CertificateRecords — **READY**
> Ghi chú: Dùng chung `Fact Practitioner License Certificate Snapshot` với Nhóm 1 — không thiết kế bảng mới.

**Source:** `Fact Practitioner License Certificate Snapshot` → `Securities Practitioner Dimension`, `Calendar Date Dimension`, `SP License Certificate Type Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú |
|---|---|---|---|---|---|
| K_NHNCK_17 | Số lượng CCHN là Môi giới | CCHN | Base | COUNT(DISTINCT Certificate Number) WHERE (JOIN SP License Certificate Type Dimension qua Certificate Type Dimension Id) Certificate Type Code = 'MGCK' AND Snapshot Date = 31/12/Y (quá khứ) hoặc MAX(Snapshot_Date) trong Y (hiện tại) — staging đã lọc bản ghi hiệu lực | (Sửa 2026-08) Filter qua Dimension, không đọc trực tiếp Certificate Type Code trên Fact (cột đã xoá) |
| K_NHNCK_18 | Số lượng CCHN là Phân tích | CCHN | Base | COUNT(DISTINCT Certificate Number) WHERE (JOIN SP License Certificate Type Dimension qua Certificate Type Dimension Id) Certificate Type Code = 'PTTC' AND Snapshot Date = 31/12/Y (quá khứ) hoặc MAX(Snapshot_Date) trong Y (hiện tại) — staging đã lọc bản ghi hiệu lực | (Sửa 2026-08) Filter qua Dimension, không đọc trực tiếp Certificate Type Code trên Fact (cột đã xoá) |
| K_NHNCK_19 | Số lượng CCHN là QLQ | CCHN | Base | COUNT(DISTINCT Certificate Number) WHERE (JOIN SP License Certificate Type Dimension qua Certificate Type Dimension Id) Certificate Type Code = 'QLQ' AND Snapshot Date = 31/12/Y (quá khứ) hoặc MAX(Snapshot_Date) trong Y (hiện tại) — staging đã lọc bản ghi hiệu lực | (Sửa 2026-08) Filter qua Dimension, không đọc trực tiếp Certificate Type Code trên Fact (cột đã xoá) |
| K_NHNCK_20 | Tỷ lệ CCHN Môi giới | % | Derived | K_NHNCK_17 / K_NHNCK_5 × 100% | |
| K_NHNCK_21 | Tỷ lệ CCHN Phân tích | % | Derived | K_NHNCK_18 / K_NHNCK_5 × 100% | |
| K_NHNCK_22 | Tỷ lệ CCHN QLQ | % | Derived | K_NHNCK_19 / K_NHNCK_5 × 100% | |

**Star Schema — Nhóm 3 (Fact Practitioner License Certificate Snapshot):**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Practitioner_License_Certificate_Snapshot : " "
    Securities_Practitioner_Dimension ||--o{ Fact_Practitioner_License_Certificate_Snapshot : " "
    SP_License_Certificate_Type_Dimension ||--o{ Fact_Practitioner_License_Certificate_Snapshot : " "

    Fact_Practitioner_License_Certificate_Snapshot {
        string Practitioner_Dimension_Id FK
        string Issue_Date_Dimension_Id FK
        string Snapshot_Date_Dimension_Id FK
        string Certificate_Type_Dimension_Id FK
        varchar License_Certificate_Document_Code
        varchar Certificate_Number
        varchar Is_Reissue_Indicator
        date Certificate_Issue_Date
        date Revocation_Date
        string Decision_Type_Code
    }

    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        varchar Holiday_Flag
        string Source_System_Code
    }

    Securities_Practitioner_Dimension {
        string Securities_Practitioner_Dimension_Id PK
        varchar Practitioner_Code
        varchar Full_Name
        varchar Education_Level_Code
        varchar Education_Level_Name
        varchar Nationality_Code
        date Birth_Date
        varchar Practice_Status_Code
        varchar Practice_Status_Name
        string Source_System_Code
    }

    SP_License_Certificate_Type_Dimension {
        string Certificate_Type_Dimension_Id PK
        varchar Certificate_Type_Code
        varchar Certificate_Type_Name
        string Source_System_Code
    }
```

> **Ghi chú erDiagram Nhóm 3:** Dùng chung schema với Nhóm 1a. Fact có FK đến `SP_License_Certificate_Type_Dimension` (không dùng `Classification_Dimension`): `Certificate_Type_Dimension_Id` — chiều lọc chính cho KPI K_NHNCK_17–22, JOIN Dimension để lấy `Certificate_Type_Code` (Sửa 2026-08: đã xoá khỏi Fact, không còn lưu dư thừa). Không có trường trạng thái CCHN — staging đã lọc chỉ bản ghi hiệu lực. `Certificate_Number` (Sửa 2026-08, xem ghi chú Nhóm 1a) — DD dùng để `COUNT(DISTINCT ...)` cho K_NHNCK_17/18/19, thay cho `License_Certificate_Document_Code` (chỉ là PK/degenerate key của bản ghi, không phải business key của CCHN).

**Lineage Mart → Báo cáo — Nhóm 3:**

```mermaid
flowchart LR
    subgraph Datamart["Datamart"]
        G1["Fact Practitioner License Certificate Snapshot"]
        G2["Securities Practitioner Dimension"]
        G3["Calendar Date Dimension"]
        G4["SP License Certificate Type Dimension"]
    end
    subgraph RPT["Bao cao - Nhom 3"]
        R1["K_NHNCK_17-19: So luong CCHN theo loai hinh"]
        R2["K_NHNCK_20-22: Ty le CCHN theo loai hinh"]
    end
    G1 --> R1
    G1 --> R2
    G2 --> G1
    G3 --> G1
    G4 --> G1
```

**Bảng grain — Nhóm 3:**

| Tên bảng | Grain |
|---|---|
| `Fact Practitioner License Certificate Snapshot` | 1 CCHN × 1 tháng snapshot (cuối tháng) — dùng chung với Nhóm 1 |
| `SP License Certificate Type Dimension` | 1 loại CCHN per SCD4A (current state) |

---

#### Nhóm 4 — Biểu đồ Phân bổ độ tuổi

> Phân loại: **Phân tích**
> Atomic: `Securities Practitioner` ← NHNCK.Professionals / NHNCK.ProfessionalHistories — **READY**

**Source:** `Fact Practitioner Daily Snapshot` → `Securities Practitioner Dimension`, `Calendar Date Dimension`

**Mockup:**

| Nhóm tuổi | Quốc tịch VN | Nước ngoài |
|---|---|---|
| 18–21 | 120 | 5 |
| 22–30 | 4,500 | 85 |
| 31–40 | 9,800 | 210 |
| 41–50 | 5,200 | 180 |
| 50+ | 1,200 | 40 |

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú |
|---|---|---|---|---|---|
| K_NHNCK_23 | Số NHN 18–21 quốc tịch VN | Người | Base | COUNT(DISTINCT Dim.Practitioner Code) WHERE Age BETWEEN 18 AND 21 AND Dim.Nationality Code = 'VN' AND Snapshot_Date = 31/12/Y (quá khứ) hoặc MAX(Snapshot_Date) trong Y (hiện tại) |  |
| K_NHNCK_24 | Số NHN 22–30 quốc tịch VN | Người | Base | COUNT(DISTINCT Dim.Practitioner Code) WHERE Age BETWEEN 22 AND 30 AND Dim.Nationality Code = 'VN' AND Snapshot_Date = 31/12/Y (quá khứ) hoặc MAX(Snapshot_Date) trong Y (hiện tại) |  |
| K_NHNCK_25 | Số NHN 31–40 quốc tịch VN | Người | Base | COUNT(DISTINCT Dim.Practitioner Code) WHERE Age BETWEEN 31 AND 40 AND Dim.Nationality Code = 'VN' AND Snapshot_Date = 31/12/Y (quá khứ) hoặc MAX(Snapshot_Date) trong Y (hiện tại) |  |
| K_NHNCK_26 | Số NHN 41–50 quốc tịch VN | Người | Base | COUNT(DISTINCT Dim.Practitioner Code) WHERE Age BETWEEN 41 AND 50 AND Dim.Nationality Code = 'VN' AND Snapshot_Date = 31/12/Y (quá khứ) hoặc MAX(Snapshot_Date) trong Y (hiện tại) |  |
| K_NHNCK_27 | Số NHN 50+ quốc tịch VN | Người | Base | COUNT(DISTINCT Dim.Practitioner Code) WHERE Age > 50 AND Dim.Nationality Code = 'VN' AND Snapshot_Date = 31/12/Y (quá khứ) hoặc MAX(Snapshot_Date) trong Y (hiện tại) |  |
| K_NHNCK_28 | Số NHN 18–21 nước ngoài | Người | Base | COUNT(DISTINCT Dim.Practitioner Code) WHERE Age BETWEEN 18 AND 21 AND Dim.Nationality Code != 'VN' AND Snapshot_Date = 31/12/Y (quá khứ) hoặc MAX(Snapshot_Date) trong Y (hiện tại) |  |
| K_NHNCK_29 | Số NHN 22–30 nước ngoài | Người | Base | COUNT(DISTINCT Dim.Practitioner Code) WHERE Age BETWEEN 22 AND 30 AND Dim.Nationality Code != 'VN' AND Snapshot_Date = 31/12/Y (quá khứ) hoặc MAX(Snapshot_Date) trong Y (hiện tại) |  |
| K_NHNCK_30 | Số NHN 31–40 nước ngoài | Người | Base | COUNT(DISTINCT Dim.Practitioner Code) WHERE Age BETWEEN 31 AND 40 AND Dim.Nationality Code != 'VN' AND Snapshot_Date = 31/12/Y (quá khứ) hoặc MAX(Snapshot_Date) trong Y (hiện tại) |  |
| K_NHNCK_31 | Số NHN 41–50 nước ngoài | Người | Base | COUNT(DISTINCT Dim.Practitioner Code) WHERE Age BETWEEN 41 AND 50 AND Dim.Nationality Code != 'VN' AND Snapshot_Date = 31/12/Y (quá khứ) hoặc MAX(Snapshot_Date) trong Y (hiện tại) |  |
| K_NHNCK_32 | Số NHN 50+ nước ngoài | Người | Base | COUNT(DISTINCT Dim.Practitioner Code) WHERE Age > 50 AND Dim.Nationality Code != 'VN' AND Snapshot_Date = 31/12/Y (quá khứ) hoặc MAX(Snapshot_Date) trong Y (hiện tại) |  |

**Star Schema — Nhóm 4 (Fact Practitioner Daily Snapshot):**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Practitioner_Daily_Snapshot : " "
    Securities_Practitioner_Dimension ||--o{ Fact_Practitioner_Daily_Snapshot : " "

    Fact_Practitioner_Daily_Snapshot {
        string Practitioner_Dimension_Id FK
        string Snapshot_Date_Dimension_Id FK
        int Age
        varchar Has_Active_Violation
    }

    Calendar_Date_Dimension {
        string Calendar_Date_Dimension_Id PK
        date Calendar_Date
        int Year
        int Quarter
        int Month
        varchar Holiday_Flag
        string Source_System_Code
    }

    Securities_Practitioner_Dimension {
        string Securities_Practitioner_Dimension_Id PK
        varchar Practitioner_Code
        varchar Full_Name
        varchar Education_Level_Code
        varchar Education_Level_Name
        varchar Nationality_Code
        date Birth_Date
        varchar Practice_Status_Code
        varchar Practice_Status_Name
        string Source_System_Code
    }
```

> **Ghi chú Fact Practitioner Daily Snapshot:**
> - Grain ngày: ETL append 1 row per NHN mỗi ngày. Slicer "chọn năm Y" = filter `Snapshot_Date = 31/12/Y` (năm quá khứ) hoặc `Snapshot_Date = MAX(Snapshot_Date) WHERE Year = Y` (năm hiện tại = ngày mới nhất có dữ liệu).
> - `Age` = ETL-derived int = Year(Snapshot_Date) − Year(Birth_Date), tính từ `ProfessionalHistories.BirthDate`. Presentation layer tự nhóm thành age bands.
> - `Has_Active_Violation` = ETL-derived Indicator (Y/N): Y nếu NHN có ít nhất 1 bản ghi `Conduct Violation` (bất kỳ), N nếu không có — bám sát SQL BA gốc (`JOIN Violations`, không filter trạng thái). Xem O_NHNCK_5. Phục vụ K_NHNCK_4 (filter = 'Y'). (Sửa 2026-07-17: đổi từ boolean sang Y/N; Sửa 2026-07-21: bỏ mô tả "Violation_Status_Code=1 (ACTIVE)" — Atomic không có field này và SQL BA cũng không yêu cầu lọc trạng thái)
> - Thông tin Education_Level_Code/Name, Nationality_Code, Practitioner_Code, Practice_Status_Code/Name đọc qua JOIN `Securities Practitioner Dimension`. (Bổ sung 2026-08) `Education_Level_Name`/`Practice_Status_Name` — ETL-derived, denormalize từ Classification tại thời điểm populate Dimension; không gắn KPI riêng, chỉ là metadata mô tả bổ sung theo coverage rule cho Dimension.

**Lineage Mart → Báo cáo — Nhóm 4:**

```mermaid
flowchart LR
    subgraph Datamart["Datamart"]
        G1["Fact Practitioner Daily Snapshot"]
        G2["Securities Practitioner Dimension"]
        G3["Calendar Date Dimension"]
    end
    subgraph RPT["Bao cao - Nhom 4"]
        R1["K_NHNCK_23-32: Phan bo do tuoi VN va nuoc ngoai"]
    end
    G1 --> R1
    G2 --> G1
    G3 --> G1
```

**Bảng grain — Nhóm 4:**

| Tên bảng | Grain |
|---|---|
| `Fact Practitioner Daily Snapshot` | 1 NHN × 1 ngày snapshot |
| `Securities Practitioner Dimension` | 1 NHN per SCD4A (current state) |
| `Calendar Date Dimension` | 1 ngày |

---

### Tab: TRA CỨU HỒ SƠ 360°

**Slicer:** Tìm kiếm theo Tên, Số CCHN, Nơi công tác. Filter Loại chứng chỉ. Không có slicer thời gian.

---

#### Nhóm 5 — Dashboard Tra cứu hồ sơ 360° — Thông tin chung của NHNCK

> Phân loại: **Tác nghiệp**
> STT BA: 5
> Atomic: `Securities Practitioner` ← NHNCK.Professionals / NHNCK.ProfessionalHistories — **READY**
> Atomic: `Securities Practitioner License Certificate Document` ← NHNCK.CertificateRecords — **READY**

**Mockup — Danh sách:**

| Tên | Tuổi | Quốc tịch | Loại CCHN | Số CCHN | Nơi công tác | Trạng thái |
|---|---|---|---|---|---|---|
| Nguyễn Văn A | 34 tuổi | Việt Nam | Môi giới | CCHN-2023-001 | TESLA | Đang hoạt động |
| Lê Thị Thu B | 37 tuổi | Việt Nam | Phân tích | CCHN-2024-045 | META | Đang hoạt động |
| Trần Minh C | 42 tuổi | Nhật | Quản lý quỹ | CCHN-QLQ-2019-112 | GOOGLE | Đang hoạt động |

**Mockup — Header chi tiết NHN:**

```
[Avatar] Nguyễn Văn A  ● Môi giới chứng khoán
15/03/1991 (34y) | Việt Nam | 001091003456 | TESLA | ĐANG HOẠT ĐỘNG
```

**Source:** `Operational Practitioner 360 Profile` (Tác nghiệp — trực tiếp từ Atomic)

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Nguồn | Ghi chú |
|---|---|---|---|---|---|
| K_NHNCK_33 | Họ tên NHN | Text | Base | `Securities Practitioner`.Full Name |  |
| K_NHNCK_34 | Ngày sinh | Date | Base | `Securities Practitioner`.Birth Date — dùng `birth_dt`; nếu null thì fallback `Birth Year` (`birth_year`) |  |
| K_NHNCK_35 | Tuổi | Int | Derived | ETL-derived: `COALESCE(YEAR(birth_dt), CAST(birth_year AS INT))` → tính `YEAR(CURRENT_DATE) − giá_trị_đó` khi populate bảng |  |
| K_NHNCK_36 | Quốc tịch | Text | Base | (Sửa 2026-08) `Geographic Area`.Geographic Area Code/Name — tự JOIN `geographic_area` qua `securities_practitioner.nationality_id`, filter `geographic_area_tp_code = 'COUNTRY'`; không dùng cột denormalized `securities_practitioner.nationality_code` cũ (chưa xác nhận đã populate đúng) |  |
| K_NHNCK_37 | Số định danh / Hộ chiếu | Text | Base | (Sửa 2026-08) `Involved Party Alternative Identification`.Identification Number — join qua `ip_id = securities_practitioner_id`, map thẳng theo BA (`PROFESSIONALS.IDENTITY_NUMBER`), KHÔNG lọc `Identification Type Code` | Xem O_NHNCK_23 |
| K_NHNCK_38 | Nơi công tác hiện tại | Text | Base | (Sửa 2026-08) `Securities Practitioner`.Workplace Name (`PROFESSIONALS.WORKPLACE`) — đổi lại theo đúng BA, không qua Organization Employment Report như quyết định 2026-07-20 |  |
| K_NHNCK_39 | Loại CCHN hiện tại | Text | Base | (Sửa 2026-08) `Securities Practitioner License Certificate Document` JOIN `SP License Certificate Type` — lấy bản ghi Certificate Document có Issue Date mới nhất per NHN (tránh fan-out khi 1 NHN có nhiều Certificate Records); đổi từ Organization Employment Report theo BA chốt lấy CERTIFICATE_RECORDS |  |
| K_NHNCK_40 | Số CCHN hiện tại | Text | Base | (Sửa 2026-08) `Securities Practitioner License Certificate Document`.Certificate Number — cùng bản ghi Issue Date mới nhất với K_NHNCK_39, đồng bộ nguồn |  |
| K_NHNCK_41 | Trạng thái NHNCK | Text | Base | `Securities Practitioner`.Practice Status Code — ETL denormalize Practice Status Name; 0=Chưa HN, 1=Đang HN, 2=Thu hồi cấp lại, 3=Thu hồi không cấp lại, 4=Có thời hạn |  |

**Schema bảng tác nghiệp:**

```mermaid
erDiagram
    Operational_Practitioner_360_Profile {
        varchar Practitioner_Code PK
        varchar Full_Name
        date Birth_Date
        int Age
        varchar Nationality_Code
        varchar Nationality_Name
        varchar Identification_Number
        varchar Education_Level_Code
        varchar Education_Level_Name
        varchar Workplace
        varchar Practice_Status_Code
        varchar Practice_Status_Name
        varchar Active_Certificate_Type_Code
        varchar Active_Certificate_Type_Name
        varchar Active_Certificate_Number
        string Source_System_Code

    }
```

> **Ghi chú schema:** `Practice_Status_Name` là ETL-derived — denormalize từ Classification tại thời điểm populate bảng, không join ở query time. (Sửa 2026-08) `Nationality_Code/Name`: tự JOIN `geographic_area` qua `securities_practitioner.nationality_id`, filter `geographic_area_tp_code = 'COUNTRY'` — không dùng cột denormalized `securities_practitioner.nationality_code` cũ (chưa xác nhận đã populate đúng ở tầng Atomic). (Sửa 2026-08) `Workplace` (K_NHNCK_38): đổi lại về `Securities Practitioner`.Workplace Name (`PROFESSIONALS.WORKPLACE`), không qua Organization Employment Report như quyết định 2026-07-20 — đúng theo BA. (Sửa 2026-08) `Active_Certificate_Type_Code/Name`, `Active_Certificate_Number` (K_NHNCK_39/40): đổi từ `Securities Practitioner Organization Employment Report` sang JOIN trực tiếp `Securities Practitioner License Certificate Document` (bản ghi có Issue Date mới nhất per NHN, tránh fan-out khi có nhiều Certificate Records) → `SP License Certificate Type` — theo BA chốt nguồn CERTIFICATE_RECORDS (xem O_NHNCK_20). `Education_Level_Code/Name` (Sửa 2026-07-22) — ETL denormalize từ Classification (scheme EDUCATION_LEVEL) tại thời điểm populate, cùng pattern với `Practice_Status_Name`. Không có KPI riêng ở Nhóm 5 (BA không yêu cầu hiển thị trên dashboard 360°) — cột này tồn tại để phục vụ JOIN từ Nhóm 13 (Data Explorer), nơi khai sinh K_NHNCK_106.

**Lineage Mart → Báo cáo — Nhóm 5:**

```mermaid
flowchart LR
    subgraph Datamart["Datamart"]
        G1["Operational Practitioner 360 Profile"]
    end
    subgraph RPT["Bao cao - Nhom 5"]
        R1["K_NHNCK_33-41: Thong tin chung NHN 360"]
    end
    G1 --> R1
```

**Bảng grain — Nhóm 5:**

| Tên bảng | Grain |
|---|---|
| `Operational Practitioner 360 Profile` | 1 NHN (latest state) |

---

#### Nhóm 6 — Sub-tab Mạng lưới người liên quan

> Phân loại: **Tác nghiệp**
> Atomic: `Securities Practitioner Related Party` ← NHNCK.ProfessionalRelationships — **READY**
> Atomic: `Securities Practitioner Organization Employment Report` ← NHNCK.OrganizationReports — **READY** (reuse từ Nhóm 7 — chỉ K_NHNCK_81, 82)
> Ghi chú: Phục vụ phần "Mạng lưới người liên quan" trong sub-tab Hồ sơ. Mỗi row = 1 người liên quan của NHN (vợ/chồng, con, bố/mẹ...). K_NHNCK_81, K_NHNCK_82 khai sinh ở Nhóm 7 — reuse vào bảng này để hiển thị vai trò NHN tại DN niêm yết trong cùng màn hình mạng lưới.

**Mockup:**

| Họ và tên | Mối quan hệ | Nghề nghiệp | Nơi làm việc |
|---|---|---|---|
| Lê Thị Hồng A | Vợ | Kinh doanh tự do | — |
| Nguyễn Thế B | Con trai | Du học sinh | — |
| Trần Văn C | Em rể | Giám đốc DN tư nhân | — |

**Source:** `Operational Practitioner Related Party Profile` (Tác nghiệp — trực tiếp từ Atomic)

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Nguồn | Ghi chú |
|---|---|---|---|---|---|
| K_NHNCK_75 | Họ và tên người liên quan | Text | Base | `Securities Practitioner Related Party`.Related Individual Full Name | |
| K_NHNCK_76 | Mối quan hệ | Text | Base | `Securities Practitioner Related Party`.Relationship Type Code — ETL denormalize Relationship Type Name (scheme: RELATIONSHIP_TYPE) khi populate bảng | |
| K_NHNCK_77 | Nghề nghiệp người liên quan | Text | Base | `Securities Practitioner Related Party`.Related Individual Occupation | |
| K_NHNCK_78 | Nơi làm việc người liên quan | Text | Base | `Securities Practitioner Related Party`.Related Individual Workplace | |
| K_NHNCK_79 | CCCD/CMND người liên quan | Text | Base | (Sửa 2026-08) `Securities Practitioner Related Party`.Related Individual Identity Number — direct từ `PROFESSIONAL_RELATIONSHIPS.IDENTITY_ID`, không crosswalk qua `IDENTITY_INFO_C06S`. Đóng O_NHNCK_11 |
| K_NHNCK_80 | Quốc tịch người liên quan | Text | Base | (Sửa 2026-08) `Geographic Area`.Geographic Area Code/Name — tự JOIN qua `sp_related_party.country_id`, filter `geographic_area_tp_code = 'COUNTRY'`; không dùng cột denormalized `sp_related_party.country_code` cũ (Atomic chưa xác nhận value set khớp danh mục ECAT) | Xem O_NHNCK_24 |
| K_NHNCK_86 | Địa chỉ người liên quan | Text | Base | `Securities Practitioner Related Party`.Related Individual Address | |
| K_NHNCK_81 | Tên DN niêm yết/UPCOM (NHN tham gia) | Text | Base | `Securities Practitioner Organization Employment Report`.Practitioner Workplace At Report | Reuse từ Nhóm 7 |
| K_NHNCK_82 | Vai trò NHN tại DN niêm yết/UPCOM | Text | Base | `Securities Practitioner Organization Employment Report`.Practitioner Position At Report | Reuse từ Nhóm 7 |

**Schema bảng tác nghiệp:**

```mermaid
erDiagram
    Operational_Practitioner_Related_Party_Profile {
        varchar Practitioner_Code PK
        varchar Securities_Practitioner_Related_Party_Code PK
        varchar Related_Individual_Full_Name
        varchar Relationship_Type_Code
        varchar Relationship_Type_Name
        varchar Related_Individual_Occupation
        varchar Related_Individual_Workplace
        varchar Related_Individual_Identity_Number
        varchar Country_Code
        varchar Country_Name
        varchar Related_Individual_Address
        string Source_System_Code

    }
```

> **Ghi chú schema Nhóm 6:** `Relationship_Type_Name` ETL-derived — denormalize từ Classification (scheme: RELATIONSHIP_TYPE). (Sửa 2026-08) `Country_Code/Name`: tự JOIN `geographic_area` qua `sp_related_party.country_id`, filter `geographic_area_tp_code = 'COUNTRY'` — không dùng cột denormalized `sp_related_party.country_code` cũ (Atomic chưa xác nhận value set khớp danh mục ECAT, xem O_NHNCK_24). K_NHNCK_81, K_NHNCK_82 phục vụ hiển thị bổ sung trong màn hình mạng lưới — đọc trực tiếp từ `Operational Practitioner Listed Company Role` (Nhóm 7), không gộp vào `Operational Practitioner Related Party Profile`.

**Lineage Mart → Báo cáo — Nhóm 6:**

```mermaid
flowchart LR
    subgraph Datamart["Datamart"]
        G1["Operational Practitioner Related Party Profile"]
        G2["Operational Practitioner Listed Company Role"]
    end
    subgraph RPT["Bao cao - Nhom 6"]
        R1["K_NHNCK_75-82,86: Mang luoi nguoi lien quan"]
    end
    G1 --> R1
    G2 --> R1
```

**Bảng grain — Nhóm 6:**

| Tên bảng | Grain |
|---|---|
| `Operational Practitioner Related Party Profile` | 1 người liên quan per NHN (toàn bộ) |
| `Operational Practitioner Listed Company Role` | Reuse từ Nhóm 7 — 1 vai trò per NHN per DN niêm yết |

---

#### Nhóm 7 — Dashboard Hồ sơ & Danh mục của NHNCK

> Phân loại: **Tác nghiệp** (2 bảng tác nghiệp riêng biệt)
> Atomic chính: `Securities Practitioner Organization Employment Report` (`sp_organization_employment_report`) ← NHNCK.ORGANIZATION_REPORTS — **READY**
> Atomic phụ: `Securities Organization Reference` (`securities_organization_reference`) ← NHNCK.ORGANIZATIONS — join để lấy tên tổ chức và lọc loại hình CTCK
> Atomic phụ (K_NHNCK_85): `Securities Company Shareholder` (`sc_shareholder`) ← SCMS.SC_FIRM_SHAREHOLDER — **READY**; `Involved Party Alternative Identification` (`ip_alternative_identification`, nguồn NHNCK.PROFESSIONALS và nguồn SCMS.SC_FIRM_SHAREHOLDER) — **READY**, dùng làm cầu nối xác định đúng NHN theo CCCD giữa 2 hệ nguồn, có FK trực tiếp (`ip_id`) tới `sc_shareholder`. (Sửa 2026-07-20) Đã bỏ `Sc Insider Related Person` khỏi chuỗi join — entity này không có FK trực tiếp tới `sc_shareholder`, join qua `sc_id` (CTCK) chỉ đảm bảo cùng công ty chứng khoán, không xác định đúng người và gây fan-out
> Atomic phụ (K_NHNCK_87/88/89/103 — Sửa 2026-08-07, ngoại lệ đã xác nhận với user): `open_investors` (VSDC/MSS) và `major_shareholder` (VSDC) — chưa có thiết kế Atomic LLD chính thức (chưa qua `atomic-lld-design`, không có YAML trong `DataModel/Atomic/`). Theo xác nhận của user, coi tên bảng/cột BA ghi (tiếng Việt, physical name thô) là Atomic entity/column thật luôn — tương tự ngoại lệ `rsk_wgt_cfg` (module PTTT). Không tự áp dụng ngoại lệ này cho case khác nếu chưa được xác nhận riêng.
> Ghi chú: Panel "Vai trò tại DN niêm yết" và panel "Mạng lưới người liên quan" là 2 bảng tác nghiệp độc lập. K_NHNCK_85 "Số lượng cổ phiếu sở hữu" đã xác nhận nguồn thật là SCMS (không phải VSDC) — chuyển READY, xem O_NHNCK_6. Sửa tên attribute: `Workplace Name` → `Practitioner Workplace At Report`; `Position Name` → `Practitioner Position At Report` (theo YAML `sp_organization_employment_report`). **(Sửa 2026-08-07)** Panel "Tài khoản & Số dư" (K_NHNCK_87/88/89/103) chuyển từ PENDING sang READY — BA đã bổ sung tên bảng/cột nguồn cụ thể (`open_investors.ma_tkgd`, `open_investors.ten_khach_hang`, `major_shareholder.ma_ck`, `major_shareholder.so_luong_ck_cuoi_ky`), coi là Atomic thật theo xác nhận user (xem Atomic phụ ở trên). Xem O_NHNCK_6.

**Bảng KPI:**

| KPI ID | Tên KPI | Tính chất | Trạng thái | Nguồn | Ghi chú |
|---|---|---|---|---|---|
| K_NHNCK_81 | Tên DN niêm yết/UPCOM | Base | READY | `Securities Practitioner Organization Employment Report`.Practitioner Workplace At Report | Khai sinh tại Nhóm 7 |
| K_NHNCK_82 | Vai trò tại DN | Base | READY | `Securities Practitioner Organization Employment Report`.Practitioner Position At Report | Khai sinh tại Nhóm 7 |
| K_NHNCK_83 | Trạng thái vai trò | Derived | READY | Derived: `Termination Date IS NULL → "Hiện tại"`, có giá trị → "Đã kết thúc" | |
| K_NHNCK_84 | Mã CTCK | Base | READY | `Securities Practitioner Organization Employment Report`.Securities Organization Reference Code — join `Securities Organization Reference` filter `Organization Type Code = 'CTCK'` | |
| K_NHNCK_85 | Số lượng cổ phiếu sở hữu | Base | READY | `Securities Company Shareholder`.Shares Held — xác định đúng NHN qua `Involved Party Alternative Identification` (NHNCK, `identification_nbr`=CCCD NHN) = `Involved Party Alternative Identification` (SCMS nguồn SC_FIRM_SHAREHOLDER, `identification_nbr`=ID_NUMBER), FK trực tiếp (`ip_id`) tới `Securities Company Shareholder` | (Sửa 2026-07-20) Nguồn thật là SCMS `SC_FIRM_SHAREHOLDER`, không phải VSDC như thiết kế trước — xem O_NHNCK_6. Đã fix gap join: bỏ `Sc Insider Related Person` (không có FK trực tiếp, join qua `sc_id` sai người/fan-out) |
| K_NHNCK_75 | Họ và tên người liên quan | Base | READY | `Securities Practitioner Related Party`.Related Individual Full Name | Reuse từ Nhóm 6 |
| K_NHNCK_76 | Mối quan hệ | Base | READY | `Securities Practitioner Related Party`.Relationship Type Code — ETL denormalize Relationship Type Name (scheme: RELATIONSHIP_TYPE) khi populate bảng | Reuse từ Nhóm 6 |
| K_NHNCK_77 | Nghề nghiệp người liên quan | Base | READY | `Securities Practitioner Related Party`.Related Individual Occupation | Reuse từ Nhóm 6 |
| K_NHNCK_79 | CCCD/CMND người liên quan | Base | READY | `Securities Practitioner Related Party`.Related Individual Identity Number | (Sửa 2026-08) Reuse từ Nhóm 6 — đóng O_NHNCK_11 |
| K_NHNCK_87 | Số tài khoản | Base | READY | `open_investors`.`ma_tkgd` | (Sửa 2026-08-07) PENDING → READY — Atomic VSDC/MSS chưa có thiết kế LLD chính thức, coi tên bảng/cột BA ghi là Atomic thật theo xác nhận của user (ngoại lệ, tương tự `rsk_wgt_cfg`/PTTT), không qua `atomic-lld-design` |
| K_NHNCK_88 | Tên chủ tài khoản | Base | READY | `open_investors`.`ten_khach_hang` | (Sửa 2026-08-07) PENDING → READY — xem ghi chú K_NHNCK_87 |
| K_NHNCK_89 | Mã CK nắm giữ chính | Base | READY | `major_shareholder`.`ma_ck` | (Sửa 2026-08-07) PENDING → READY — xem ghi chú K_NHNCK_87 |
| K_NHNCK_103 | Số lượng chứng khoán VSDC sở hữu (Cuối kỳ) | Base | READY | `major_shareholder`.`so_luong_ck_cuoi_ky` | (Thêm 2026-07-20) BA row 60, cùng nguồn `VSDC_BM 8` với K_NHNCK_89 — BA quên điền tên KPI ở cột "Thông tin", đã bổ sung theo "Trường nguồn". (Sửa 2026-08-07) PENDING → READY — xem ghi chú K_NHNCK_87 |

**Schema bảng tác nghiệp:**

```mermaid
erDiagram
    Operational_Practitioner_Listed_Company_Role {
        varchar Practitioner_Code PK
        varchar Organization_Employment_Report_Code PK
        varchar Practitioner_Workplace_At_Report
        varchar Practitioner_Position_At_Report
        varchar Organization_Type_Code
        varchar Securities_Organization_Reference_Code
        varchar Employment_Status
        date Hire_Date
        date Termination_Date
        int Shares_Held
        varchar Account_Number
        varchar Account_Holder_Name
        varchar Main_Held_Securities_Code
        int Vsdc_Held_Securities_Volume
        string Source_System_Code

    }
```

> **Ghi chú schema Nhóm 7:** `Shares_Held` (K_NHNCK_85) ETL-populate từ `Securities Company Shareholder.Shares Held` (SCMS) — không phải từ `Securities Practitioner Organization Employment Report` như các cột còn lại. ETL xác định đúng NHN bằng cách đối chiếu CCCD: `Involved Party Alternative Identification` (nguồn NHNCK, `identification_nbr`) so khớp với `Involved Party Alternative Identification` (nguồn SCMS `SC_FIRM_SHAREHOLDER`, `identification_nbr` ← `SC_FIRM_SHAREHOLDER.ID_NUMBER`), entity này có FK trực tiếp (`ip_id`) tới `Securities Company Shareholder` — lấy `Shares_Held` trực tiếp, không qua bảng trung gian nào. NULL nếu NHN không phải cổ đông của DN niêm yết đang xét. (Sửa 2026-07-20) Đã fix gap: chuỗi join cũ đi qua `Sc Insider Related Person` rồi join `sc_id` (CTCK) tới `Securities Company Shareholder` — entity này KHÔNG có FK trực tiếp tới `Securities Company Shareholder`, join theo `sc_id` chỉ đảm bảo cùng 1 CTCK (nhiều insider × nhiều shareholder cùng công ty) → sai người + fan-out nhân dòng. **(Sửa 2026-08-07)** `Account_Number`/`Account_Holder_Name` (K_NHNCK_87/88) direct từ `open_investors` (`ma_tkgd`/`ten_khach_hang`); `Main_Held_Securities_Code`/`Vsdc_Held_Securities_Volume` (K_NHNCK_89/103) direct từ `major_shareholder` (`ma_ck`/`so_luong_ck_cuoi_ky`) — cả 2 bảng nguồn coi là Atomic thật theo ngoại lệ đã xác nhận (xem ghi chú đầu Nhóm 7), không qua `join_atomic` chuẩn vì chưa có YAML entity chính thức để xác nhận FK/join key.

**Lineage Mart → Báo cáo — Nhóm 7:**

```mermaid
flowchart LR
    subgraph Datamart["Datamart"]
        G1["Operational Practitioner Listed Company Role"]
        G2["Operational Practitioner Related Party Profile (Reuse Nhóm 6)"]
    end
    subgraph RPT["Bao cao - Nhom 7"]
        R1["K_NHNCK_75-89: Ho so va Danh muc NHNCK"]
    end
    G1 --> R1
    G2 --> R1
```

**Bảng grain — Nhóm 7:**

| Tên bảng | Grain | Trạng thái |
|---|---|---|
| `Operational Practitioner Listed Company Role` | 1 lần báo cáo tổ chức per NHN (tất cả lịch sử, filter type=CTCK/DN niêm yết) | new |
| `Operational Practitioner Related Party Profile` | Reuse từ Nhóm 6 | reuse |

---

#### Nhóm 8 — Sub-tab Quá trình hành nghề

> Phân loại: **Tác nghiệp**
> Atomic chính: `Securities Practitioner Organization Employment Report` (`sp_organization_employment_report`) ← NHNCK.OrganizationReports — **READY**
> Atomic phụ: `Securities Organization Reference` (`securities_organization_reference`) ← NHNCK.Organizations — join để lấy tên tổ chức và phân loại tổ chức
> Ghi chú: Nguồn là `NHNCK.OrganizationReports` — không phải `ProfessionalWorkHistories`. Tên tổ chức và phân loại ETL-derived qua join `securities_organization_reference` theo `securities_organization_reference_code`.

**Mockup:**

| Tổ chức | Phân loại | Vị trí | Phòng ban | Từ tháng | Đến tháng | Trạng thái |
|---|---|---|---|---|---|---|
| Tesla | CTCK | Môi giới chứng khoán | Phòng Môi giới | 12/05/2023 | Hiện nay | Hiện tại |
| Công ty CP Chứng khoán AAA | CTCK | Trưởng phòng Môi giới | Phòng Môi giới | 12/01/2018 | 11/05/2023 | Quá khứ |
| Vụ Giám sát TTCK - UBCKNN | Khác | Chuyên viên chính | — | 30/10/2012 | 11/01/2018 | Quá khứ |

**Source:** `Operational Practitioner Employment History` (Tác nghiệp)

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Nguồn | Ghi chú |
|---|---|---|---|---|---|
| K_NHNCK_49 | Tên tổ chức | Text | Base | `Securities Practitioner Organization Employment Report`.Securities Organization Reference Code — ETL join `Securities Organization Reference`.Securities Organization Reference Name theo `securities_organization_reference_code` khi populate bảng | Khai sinh tại Nhóm 8 |
| K_NHNCK_90 | Phân loại tổ chức | Text | Base | `Securities Organization Reference`.Organization Type Code — ETL join `securities_organization_reference` theo `securities_organization_reference_code`, denormalize Organization Type Name (scheme: ORGANIZATION_TYPE) khi populate bảng | Khai sinh tại Nhóm 8 |
| K_NHNCK_50 | Vị trí công tác | Text | Base | `Securities Practitioner Organization Employment Report`.Practitioner Position At Report | Khai sinh tại Nhóm 8 |
| K_NHNCK_91 | Phòng ban | Text | Base | `Securities Practitioner Organization Employment Report`.Practitioner Department At Report | Khai sinh tại Nhóm 8 |
| K_NHNCK_51 | Từ tháng | Date | Base | `Securities Practitioner Organization Employment Report`.Hire Date | Khai sinh tại Nhóm 8 |
| K_NHNCK_52 | Đến tháng | Date | Base | `Securities Practitioner Organization Employment Report`.Termination Date — NULL hiển thị "Hiện nay" tại presentation layer | Khai sinh tại Nhóm 8 |
| K_NHNCK_53 | Trạng thái làm việc | Text | Derived | Derived: `Termination Date IS NULL → "Hiện tại"`, có giá trị → "Quá khứ" — derive tại presentation layer | |

**Schema bảng tác nghiệp:**

```mermaid
erDiagram
    Operational_Practitioner_Employment_History {
        varchar Practitioner_Code PK
        varchar Organization_Employment_Report_Code PK
        varchar Securities_Organization_Reference_Code
        varchar Securities_Organization_Name
        varchar Organization_Type_Code
        varchar Organization_Type_Name
        varchar Practitioner_Position_At_Report
        varchar Practitioner_Department_At_Report
        date Hire_Date
        date Termination_Date
        string Source_System_Code

    }
```

> **Ghi chú schema Nhóm 8:** `Securities_Organization_Name` ETL-derived — join `securities_organization_reference.securities_organization_reference_nm` theo `securities_organization_reference_code`. `Organization_Type_Name` ETL-derived — denormalize từ Classification (scheme: ORGANIZATION_TYPE) tại thời điểm populate. Presentation layer đọc trực tiếp, không join Atomic ở query time.

**Lineage Mart → Báo cáo — Nhóm 8:**

```mermaid
flowchart LR
    subgraph Datamart["Datamart"]
        G1["Operational Practitioner Employment History"]
    end
    subgraph RPT["Bao cao - Nhom 8"]
        R1["K_NHNCK_49,50,51,52,53,90,91: Qua trinh hanh nghe"]
    end
    G1 --> R1
```

**Bảng grain — Nhóm 8:**

| Tên bảng | Grain |
|---|---|
| `Operational Practitioner Employment History` | 1 lần công tác per NHN (toàn bộ lịch sử) |

---

#### Nhóm 9 — Sub-tab Lịch sử cấp chứng chỉ hành nghề

> Phân loại: **Tác nghiệp**
> Atomic chính: `Securities Practitioner License Certificate Document` (`sp_license_certificate_document`) ← NHNCK.CertificateRecords — **READY**
> Atomic phụ: `Securities Practitioner License Decision Document` (`sp_license_decision_document`) ← NHNCK.Decisions — join để lấy số quyết định cấp và thu hồi
> Atomic phụ (K_NHNCK_43 — Sửa 2026-07-20): `Securities Practitioner Organization Employment Report` (`sp_organization_employment_report`) ← NHNCK.OrganizationReports — join qua FK `Securities Practitioner License Certificate Document Id` để lấy Certificate Number denormalized tại báo cáo gần nhất, theo đúng BA v2
> Ghi chú: Cột "Trạng thái" trong Mockup (K_NHNCK_48) — (Sửa 2026-08) READY, xem O_NHNCK_16.

**Mockup:**

| Số CCHN | Loại hình | Ngày cấp | Ngày thu hồi | Quyết định cấp | Quyết định thu hồi | Trạng thái |
|---|---|---|---|---|---|---|
| CCHN-2023-001 | Môi giới chứng khoán | 12/05/2023 | — | 145/QĐ-UBCK | — | Đang hiệu lực |
| CCHN-2020-045 | Phân tích chứng khoán | 20/10/2020 | 20/10/2023 | 89/QĐ-UBCK | 91/QĐ-UBCK | Thu hồi trong 3 năm |
| CCHN-2017-012 | Môi giới chứng khoán | 15/01/2017 | 15/01/2020 | 12/QĐ-UBCK | 15/QĐ-UBCK | Thu hồi vĩnh viễn |

**Source:** `Operational Practitioner Certificate History` (Tác nghiệp)

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Nguồn | Ghi chú |
|---|---|---|---|---|---|
| K_NHNCK_43 | Số CCHN | Text | Base | (Sửa 2026-07-20 — BA v2) `Securities Practitioner Organization Employment Report`.Certificate Number At Report — bản ghi báo cáo gần nhất theo Report Date CỦA CHÍNH CCHN đang xét (join qua FK Certificate Document Id trên ORGANIZATION_REPORTS, không phải gần nhất của NHN) | Khai sinh tại Nhóm 9 |
| K_NHNCK_44 | Loại hình hành nghề | Text | Base | `Securities Practitioner License Certificate Document`.Certificate Type Code — ETL join `SP License Certificate Type` (Fundamental entity), denormalize Certificate Type Name khi populate bảng | Khai sinh tại Nhóm 9 |
| K_NHNCK_45 | Ngày cấp | Date | Base | `Securities Practitioner License Certificate Document`.Issue Date | Khai sinh tại Nhóm 9 |
| K_NHNCK_46 | Ngày thu hồi | Date | Base | `Securities Practitioner License Certificate Document`.Revocation Date — NULL nếu chưa thu hồi | Khai sinh tại Nhóm 9 |
| K_NHNCK_47 | Số quyết định cấp | Text | Base | (Sửa 2026-08) `Securities Practitioner License Certificate Document`.Issue Securities Practitioner License Decision Document Id — ETL join `Securities Practitioner License Decision Document`.Decision Number theo `issue_sp_license_decision_document_id` khi populate bảng | Khai sinh tại Nhóm 9 |
| K_NHNCK_92 | Số quyết định thu hồi | Text | Base | (Sửa 2026-08) `Securities Practitioner License Certificate Document`.Revocation Securities Practitioner License Decision Document Id — ETL join `Securities Practitioner License Decision Document`.Decision Number theo `revocation_sp_license_decision_document_id` khi populate bảng; NULL nếu chưa thu hồi | Khai sinh tại Nhóm 9 |
| K_NHNCK_48 | Trạng thái CCHN | Text | Base | (Sửa 2026-08) `Securities Practitioner License Certificate Status Change History`.New Certificate Status Code (scheme CERTIFICATE_STATUS: 0-5: Chưa sử dụng/Đang sử dụng/Thu hồi có cấp lại/Thu hồi không cấp lại/Đã hủy/Hết hiệu lực) — lấy bản ghi mới nhất theo BK tăng dần. Đóng O_NHNCK_16 |

**Schema bảng tác nghiệp:**

```mermaid
erDiagram
    Operational_Practitioner_Certificate_History {
        varchar Practitioner_Code PK
        varchar License_Certificate_Document_Code PK
        varchar Certificate_Number
        varchar Certificate_Type_Code
        varchar Certificate_Type_Name
        date Issue_Date
        date Revocation_Date
        varchar Issuance_Decision_Number
        varchar Revocation_Decision_Number
        varchar Certificate_Status_Code
        varchar Certificate_Status_Name
        string Source_System_Code

    }
```

> **Ghi chú schema Nhóm 9:** `Certificate_Type_Name` là ETL-derived — denormalize từ Classification tại thời điểm populate bảng Tác nghiệp. `Revocation_Decision_Number` NULL nếu CCHN chưa bị thu hồi. Presentation layer đọc trực tiếp từ bảng này, không join Classification ở query time. (Sửa 2026-08) `Certificate_Status_Code/Name` (K_NHNCK_48) — ETL-derived: LEFT JOIN `Securities Practitioner License Certificate Status Change History` lấy bản ghi mới nhất (BK tăng dần), denormalize `New_Certificate_Status_Code` (scheme CERTIFICATE_STATUS: 0-5) rồi qua Classification lấy Name. Thay cho `Process_Status_Code`/`Process_Status_Name` (đã loại khỏi schema từ trước — khác ý nghĩa, không dùng). Đóng O_NHNCK_16.

**Lineage Mart → Báo cáo — Nhóm 9:**

```mermaid
flowchart LR
    subgraph Datamart["Datamart"]
        G1["Operational Practitioner Certificate History"]
    end
    subgraph RPT["Bao cao - Nhom 9"]
        R1["K_NHNCK_43-48,92: Lich su cap CCHN"]
    end
    G1 --> R1
```

**Bảng grain — Nhóm 9:**

| Tên bảng | Grain |
|---|---|
| `Operational Practitioner Certificate History` | 1 CCHN per NHN (toàn bộ lịch sử) |

---

#### Nhóm 10 — Sub-tab Đợt thi sát hạch

> Phân loại: **Tác nghiệp**
> Atomic chính: `Securities Practitioner Qualification Examination Assessment Result` (`sp_qualification_examination_assessment_result`) ← NHNCK.ExamDetails — **READY**
> Atomic phụ: `Securities Practitioner Qualification Examination Assessment` (`sp_qualification_examination_assessment`) ← NHNCK.ExamSessions — join để lấy tên đợt thi, ngày thi, số quyết định công bố
> Atomic phụ: `Securities Practitioner License Decision Document` (`sp_license_decision_document`) ← NHNCK.Decisions — join qua `License Decision Code` để lấy số quyết định và ngày ký

**Mockup:**

| Đợt thi | Ngày bắt đầu thi | Ngày kết thúc thi | Điểm luật | KQ luật | Điểm CM | KQ CM | Số quyết định công bố | Trạng thái |
|---|---|---|---|---|---|---|---|---|
| Đợt 1/2025 | 15/03/2025 | 16/03/2025 | 82 | Đạt | 78 | Đạt | 45/QĐ-UBCK · 20/03/2025 | Đạt |
| Đợt 2/2024 | 10/09/2023 | 11/09/2023 | 45 | Không đạt | 40 | Không đạt | — | Không đạt |
| Đợt 1/2023 | 18/03/2023 | 19/03/2023 | 75 | Đạt | 70 | Đạt | 28/QĐ-UBCK · 25/03/2023 | Đạt |

**Source:** `Operational Practitioner Exam History` (Tác nghiệp)

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Nguồn | Ghi chú |
|---|---|---|---|---|---|
| K_NHNCK_59 | Tên đợt thi | Text | Base | `Securities Practitioner Qualification Examination Assessment`.Assessment Name | Khai sinh tại Nhóm 10 |
| K_NHNCK_102 | Kỳ thi | Text | Derived | `Securities Practitioner Qualification Examination Assessment`.Report Year + Examination Session Number — ETL concat thành chuỗi hiển thị (VD: "2025_1") khi populate bảng | Khai sinh tại Nhóm 10 |
| K_NHNCK_60 | Ngày bắt đầu thi | Date | Base | `Securities Practitioner Qualification Examination Assessment`.Examination Start Date | (Sửa 2026-08-07) Đổi tên từ "Ngày thi" — BA tách rõ 2 mốc ngày, xem K_NHNCK_118. Khai sinh tại Nhóm 10 |
| K_NHNCK_118 | Ngày kết thúc thi | Date | Base | `Securities Practitioner Qualification Examination Assessment`.Examination End Date | (Thêm 2026-08-07) BA bổ sung yêu cầu hiển thị — field đã có sẵn trên schema (join cùng pattern K_NHNCK_60) nhưng trước đây chưa có KPI riêng. Khai sinh tại Nhóm 10 |
| K_NHNCK_61 | Điểm thi luật | Text | Base | `Securities Practitioner Qualification Examination Assessment Result`.Law Score | Khai sinh tại Nhóm 10 |
| K_NHNCK_94 | Kết quả thi luật | Text | Base | `Securities Practitioner Qualification Examination Assessment Result`.Law Result Code — ETL denormalize Law Result Name (scheme: EXAM_RESULT: -1=Không thi, 0=Không đạt, 1=Đạt) khi populate bảng | Khai sinh tại Nhóm 10 |
| K_NHNCK_119 | Điểm thi chuyên môn | Text | Base | `Securities Practitioner Qualification Examination Assessment Result`.Specialization Score | (Thêm 2026-08-07) BA bổ sung — cùng entity với K_NHNCK_61 (Điểm thi luật). Khai sinh tại Nhóm 10 |
| K_NHNCK_95 | Kết quả thi chuyên môn | Text | Base | `Securities Practitioner Qualification Examination Assessment Result`.Specialization Result Code — ETL denormalize Specialization Result Name (scheme: EXAM_RESULT) khi populate bảng | Khai sinh tại Nhóm 10 |
| K_NHNCK_62 | Số quyết định công bố | Text | Base | (Sửa 2026-08) `Securities Practitioner Qualification Examination Assessment`.Securities Practitioner License Decision Document Id — ETL join `Securities Practitioner License Decision Document`.Decision Number theo `sp_license_decision_document_id` khi populate bảng; INNER JOIN — chỉ giữ lại lần thi đã có quyết định công bố kết quả | Khai sinh tại Nhóm 10 |
| K_NHNCK_63 | Trạng thái Đạt/Không đạt | Text | Base | `Securities Practitioner Qualification Examination Assessment Result`.Overall Result Code — ETL denormalize Overall Result Name (scheme: EXAM_RESULT: -1=Không thi, 0=Không đạt, 1=Đạt) khi populate bảng | Khai sinh tại Nhóm 10 |

**Schema bảng tác nghiệp:**

```mermaid
erDiagram
    Operational_Practitioner_Exam_History {
        varchar Practitioner_Code PK
        varchar Examination_Assessment_Result_Code PK
        varchar Assessment_Name
        int Report_Year
        int Examination_Session_Number
        varchar Examination_Period
        date Examination_Start_Date
        date Examination_End_Date
        varchar Law_Score
        varchar Law_Result_Code
        varchar Law_Result_Name
        varchar Specialization_Score
        varchar Specialization_Result_Code
        varchar Specialization_Result_Name
        varchar Overall_Result_Code
        varchar Overall_Result_Name
        varchar Decision_Number
        date Decision_Signed_Date
        string Source_System_Code

    }
```

> **Ghi chú schema Nhóm 10:** `Law_Result_Name`, `Specialization_Result_Name`, `Overall_Result_Name` là ETL-derived — denormalize từ Classification (scheme: EXAM_RESULT, giá trị: -1=Không thi, 0=Không đạt, 1=Đạt) tại thời điểm populate bảng. `Decision_Number` NULL nếu đợt thi chưa có quyết định công bố. Presentation layer đọc trực tiếp, không join ở query time. `Examination_End_Date` (Sửa 2026-07-22) — direct từ Atomic driving-phụ `sp_qualification_examination_assessment`, cùng pattern JOIN với `Examination_Start_Date`. **(Sửa 2026-08-07)** BA cập nhật tách "Ngày thi" thành 2 cột riêng (Ngày bắt đầu/Ngày kết thúc) — khai sinh KPI K_NHNCK_118 cho `Examination_End_Date`, không còn là cột chỉ phục vụ JOIN nội bộ. `Specialization_Score` (Thêm 2026-08-07) — direct từ `sp_qualification_examination_assessment_result`, cùng entity với `Law_Score`, khai sinh K_NHNCK_119.

**Lineage Mart → Báo cáo — Nhóm 10:**

```mermaid
flowchart LR
    subgraph Datamart["Datamart"]
        G1["Operational Practitioner Exam History"]
    end
    subgraph RPT["Bao cao - Nhom 10"]
        R1["K_NHNCK_59-63,94-95,102,118-119: Dot thi sat hach"]
    end
    G1 --> R1
```

**Bảng grain — Nhóm 10:**

| Tên bảng | Grain |
|---|---|
| `Operational Practitioner Exam History` | 1 lần thi per NHN (toàn bộ lịch sử) |

---

#### Nhóm 11 — Sub-tab Cập nhật kiến thức hành nghề

> Phân loại: **Tác nghiệp**
> Atomic chính: `Securities Practitioner Post Certification Training Result` (`sp_post_certification_training_result`) ← NHNCK.POST_CERT_TRAINING_RESULTS — **READY** (đưa vào scope 2026-07-24)
> Atomic phụ: `Securities Practitioner Post Certification Training Course` (`sp_post_certification_training_course`) ← NHNCK.POST_CERT_TRAINING_COURSES — join lấy mã/tên khóa bồi dưỡng
> Atomic phụ (fan-out): `Securities Practitioner Professional Training Class Enrollment` (`sp_professional_training_class_enrollment`) ← NHNCK.SPECIALIZATION_COURSE_DETAILS — join qua `sp_code` lấy Exam Score/Kết quả kiểm tra
> Ghi chú: **(Sửa 2026-08)** Đối chiếu lại BA cập nhật (BA_analyst_NHNCK.csv, Nhóm 11) — driving đổi từ `sp_professional_training_class_enrollment` (SPECIALIZATION_COURSE_DETAILS) sang `sp_post_certification_training_result` (POST_CERT_TRAINING_RESULTS), theo đúng SQL tham khảo BA (`FROM POST_CERT_TRAINING_RESULTS R JOIN Professionals P JOIN POST_CERT_TRAINING_COURSES C JOIN SPECIALIZATION_COURSE_DETAILS SD ON SD.PROFESSIONAL_ID = P.ID`). Grain đổi từ "1 enrollment per NHN" sang "1 lần bồi dưỡng per NHN". Mã/tên khóa học đổi nguồn từ SPECIALIZATION_COURSES sang POST_CERT_TRAINING_COURSES. Exam Score/Kết quả kiểm tra chuyển thành JOIN phụ qua `sp_code` (chấp nhận fan-out — không ràng buộc theo năm/khóa cụ thể, đúng ý BA). `Training_Hours`/`Is_Hours_Sufficient` (K_NHNCK_67) nay có sẵn trên driving — đóng O_NHNCK_9.

**Mockup — Màn hình:**

| Năm | Số giờ | Kết quả | Trạng thái |
|---|---|---|---|
| 2024 | 10/8h | Loại A | Đã đủ 8h |
| 2023 | 5/8h | Chưa kiểm tra | Chưa đủ 8h |
| 2022 | 0/8h | N/A | Chưa đủ 8h |
| 2021 | 8/8h | Loại B | Đã đủ 8h |

**Source:** `Operational Practitioner Training History` (Tác nghiệp)

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Nguồn | Ghi chú |
|---|---|---|---|---|---|
| K_NHNCK_100 | Mã khóa học chuyên môn | Text | Base | (Sửa 2026-08) `Securities Practitioner Post Certification Training Course`.Training Course Code — LEFT JOIN qua `sp_post_certification_training_course_id`, đổi nguồn từ SPECIALIZATION_COURSES | Khai sinh tại Nhóm 11 |
| K_NHNCK_96 | Tên khóa học | Text | Base | (Sửa 2026-08) `Securities Practitioner Post Certification Training Course`.Training Course Name — đổi nguồn từ SPECIALIZATION_COURSES | Khai sinh tại Nhóm 11 |
| K_NHNCK_97 | Ngày bắt đầu bồi dưỡng | Date | Base | (Sửa 2026-08) `Securities Practitioner Post Certification Training Result`.Training Start Date — direct trên driving mới, thay Exam Start Date (SPECIALIZATION_COURSES) | Khai sinh tại Nhóm 11 |
| K_NHNCK_98 | Ngày kết thúc bồi dưỡng | Date | Base | (Sửa 2026-08) `Securities Practitioner Post Certification Training Result`.Training End Date — direct trên driving mới, thay Exam End Date (SPECIALIZATION_COURSES); không còn kiểu Text | Khai sinh tại Nhóm 11 |
| K_NHNCK_99 | Điểm thi | Percentage | Base | (Sửa 2026-08) `Securities Practitioner Professional Training Class Enrollment`.Exam Score — chuyển thành JOIN phụ qua `sp_code` (fan-out), không còn trên driving; kiểu decimal(5,2); nullable | Khai sinh tại Nhóm 11 |
| K_NHNCK_66 | Kết quả thi / Kết quả kiểm tra, phân loại | Text | Base | (Sửa 2026-08) Đổi tên cột từ Training Result Code → Exam Result Code — cùng nguồn `sp_professional_training_class_enrollment.training_result_code` (scheme: EXAM_RESULT: -1=Không thi, 0=Không đạt, 1=Đạt), chuyển thành JOIN phụ qua `sp_code` (fan-out) | Khai sinh tại Nhóm 11 — (Sửa 2026-07-17) BA có 2 dòng mô tả trùng cùng 1 cột vật lý (row 86 "Kết quả kiểm tra, phân loại" + row 93 "Kết quả thi"); reuse chung 1 KPI_ID K_NHNCK_66, đã xóa K_NHNCK_101 (cũ, xem O_NHNCK_12) |
| K_NHNCK_67 | Trạng thái đủ 8h | Text | Phái sinh | (Sửa 2026-08) `Securities Practitioner Post Certification Training Result`.Training Hours (direct) + Hours Sufficiency Indicator (ETL-derived: Y nếu >= 8, N nếu < 8). Đóng O_NHNCK_9 | |

**Schema bảng tác nghiệp:**

```mermaid
erDiagram
    Operational_Practitioner_Training_History {
        varchar Practitioner_Code PK
        varchar Training_Result_Code PK
        varchar Training_Class_Code
        varchar Training_Class_Name
        date Training_Start_Date
        date Training_End_Date
        int Training_Hours
        varchar Hours_Sufficiency_Indicator
        decimal Exam_Score
        varchar Exam_Result_Code
        varchar Exam_Result_Name
        string Source_System_Code

    }
```

> **Ghi chú schema Nhóm 11:** **(Sửa 2026-08)** Driving đổi sang `sp_post_certification_training_result` — PK đổi từ `Training_Class_Enrollment_Code` sang `Training_Result_Code` (BK của driving mới), grain: 1 lần bồi dưỡng per NHN. `Training_Class_Code/Name` ETL-derived — join `sp_post_certification_training_course` (đổi nguồn từ SPECIALIZATION_COURSES). `Training_Hours`/`Hours_Sufficiency_Indicator` (K_NHNCK_67) direct/ETL-derived trên driving mới — đóng O_NHNCK_9. `Exam_Score`/`Exam_Result_Code/Name` (đổi tên từ `Training_Result_Code/Name`) chuyển thành JOIN phụ qua `sp_code` (fan-out, chấp nhận theo BA SQL tham khảo JOIN SPECIALIZATION_COURSE_DETAILS SD ON SD.PROFESSIONAL_ID = P.ID — không ràng buộc theo năm/khóa cụ thể). `Academic_Year` đã loại khỏi schema (thuộc SPECIALIZATION_COURSES, không còn join trực tiếp trên driving mới).

**Lineage Mart → Báo cáo — Nhóm 11:**

```mermaid
flowchart LR
    subgraph Datamart["Datamart"]
        G1["Operational Practitioner Training History"]
    end
    subgraph RPT["Bao cao - Nhom 11"]
        R1["K_NHNCK_66,67,96-100: Cap nhat kien thuc hanh nghe"]
    end
    G1 --> R1
```

**Bảng grain — Nhóm 11:**

| Tên bảng | Grain |
|---|---|
| `Operational Practitioner Training History` | (Sửa 2026-08) 1 lần bồi dưỡng per NHN (driving `sp_post_certification_training_result`) — không còn GROUP BY theo Academic_Year (cột đã loại khỏi schema) |

---

#### Nhóm 12 — Sub-tab Lịch sử vi phạm & xử phạt hành chính

> Phân loại: **Tác nghiệp**
> Atomic: `Securities Practitioner Conduct Violation` ← NHNCK.Violations — **READY**
> Atomic: `Securities Practitioner License Decision Document` ← NHNCK.Decisions — **READY**

**Mockup:**

| Ngày quyết định | Số quyết định | Nội dung vi phạm | Hình thức xử phạt | Trạng thái |
|---|---|---|---|---|
| 15/10/2023 | 142/QĐ-XPHC | Thao túng giá chứng khoán | 550,000,000 VND | Đã thực thi |
| 05/02/2021 | 24/QĐ-UBCK | Chậm công bố thông tin sở hữu | Cảnh cáo | Đã ban hành |
| 12/11/2019 | BC-0012/CTCK | Vi phạm quy trình mở tài khoản | Đình chỉ hành nghề 3 tháng | Đang thực thi |

**Source:** `Operational Practitioner Violation History` (Tác nghiệp)

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Nguồn | Ghi chú |
|---|---|---|---|---|---|
| K_NHNCK_54 | Số quyết định xử phạt | Text | Base | `Securities Practitioner License Decision Document`.Decision Number (`decision_nbr`) ← DECISIONS.DECISION_NUMBER | |
| K_NHNCK_55 | Ngày quyết định | Date | Base | `Securities Practitioner License Decision Document`.Decision Signed Date (`decision_signed_dt`) ← DECISIONS.SIGNED_DATE | |
| K_NHNCK_56 | Nội dung vi phạm | Text | Base | `Securities Practitioner Conduct Violation`.Note (`note`) ← VIOLATIONS.Note | nullable |
| K_NHNCK_57 | Hình thức xử phạt | Text | Base | (Sửa 2026-08) `Securities Practitioner Conduct Violation`.Violation Type Code — Atomic đã có `violation_tp_code` (scheme VIOLATION_TYPE: 1=Hành chính/ADMINISTRATIVE, 2=Pháp luật/LEGAL). Đóng O_NHNCK_17. | |
| K_NHNCK_58 | Trạng thái vi phạm | Text | Base | (Sửa 2026-08) `Securities Practitioner Conduct Violation`.Violation Status Code — Atomic đã có `violation_status_code` (scheme VIOLATION_STATUS: 1=ACTIVE, 0=INACTIVE, -1=DELETED). Đóng O_NHNCK_15. | BA xác nhận lại (đã hỏi Liên - Tinh Vân): chỉ 3 mức kỹ thuật, KHÔNG phải 6 trạng thái "thực thi quyết định" như mô tả KPI ban đầu |

**Schema bảng tác nghiệp:**

```mermaid
erDiagram
    Operational_Practitioner_Violation_History {
        varchar Practitioner_Code PK
        varchar Conduct_Violation_Code PK
        varchar Violation_Type_Code
        varchar Violation_Type_Name
        varchar Note
        varchar Violation_Status_Code
        varchar Violation_Status_Name
        varchar Decision_Number
        date Decision_Signed_Date
        string Source_System_Code

    }
```

> **Ghi chú schema Nhóm 12:** (Sửa 2026-08) `Violation_Type_Code/Name` (K_NHNCK_57) và `Violation_Status_Code/Name` (K_NHNCK_58) đã đưa lại vào schema — Atomic `sp_conduct_violation` đã bổ sung `violation_tp_code`/`violation_status_code`, đóng O_NHNCK_17 và O_NHNCK_15. Đổi tên từ `Record_Type_Code`/`Record_Status_Code` để khớp đúng physical field Atomic. `Decision_Signed_Date` lấy từ `Securities Practitioner License Decision Document`.Decision Signed Date (`decision_signed_dt`). Presentation đọc trực tiếp.

**Lineage Mart → Báo cáo — Nhóm 12:**

```mermaid
flowchart LR
    subgraph Datamart["Datamart"]
        G1["Operational Practitioner Violation History"]
    end
    subgraph RPT["Bao cao - Nhom 12"]
        R1["K_NHNCK_54-58: Lich su vi pham"]
    end
    G1 --> R1
```

**Bảng grain — Nhóm 12:**

| Tên bảng | Grain |
|---|---|
| `Operational Practitioner Violation History` | 1 vi phạm per NHN (toàn bộ lịch sử) |

---

### Tab: DATA EXPLORER

**Slicer:** Loại chứng chỉ (Mọi loại / MGCK / PTTC / QLQ) + Trạng thái (Đang hoạt động / Thu hồi / Đã hủy). Hiển thị "KẾT QUẢ: N NHN" góc phải. Hỗ trợ export file.

---

#### Nhóm 13 — Operational Practitioner Data Explorer (bảng tra cứu tổng hợp)

> Phân loại: **Tác nghiệp**
> Atomic: `Securities Practitioner License Certificate Document` ← NHNCK.CertificateRecords — **READY**
> Atomic: `Securities Practitioner` ← NHNCK.Professionals / NHNCK.ProfessionalHistories — **READY**
> Atomic: `Securities Practitioner Organization Employment Report` ← NHNCK.OrganizationReports — **READY**
> Ghi chú: Bảng flat denormalized ETL trực tiếp từ Atomic — không khai thác qua Fact/Dim. (Sửa 2026-07-20) Grain = 1 CCHN per NHN — **toàn bộ CCHN** (không lọc chỉ CCHN active), giống Nhóm 9. Lý do: 1 NHN có thể có nhiều CCHN đồng thời (Môi giới + Phân tích + QLQ) — nếu gộp về 1 dòng/NHN, slicer "Loại hình" sẽ không hiển thị đúng khi NHN có nhiều loại CCHN. BA không có điều kiện lọc `revocation_dt`/active nào cho Nhóm này. Slicer Loại chứng chỉ và Trạng thái filter trực tiếp trên `Certificate_Type_Code` và `Practice_Status_Code` trong bảng này.
> **(Sửa 2026-07-22 — BA bổ sung nhóm Người hành nghề/Đợt thi/Vi phạm, tương tự dữ liệu Tab TRA CỨU HỒ SƠ 360°):** Không denormalize toàn bộ trường mới vào cùng 1 bảng flat này. Các trường 1-1 với NHN (ngày sinh, số định danh, học vấn, tuổi, quốc tịch) đã có sẵn ở `Operational Practitioner 360 Profile` — chỉ Education Level là gap thật, bổ sung trực tiếp vào bảng đó (xem Nhóm 5). Các trường 1-N với NHN (đợt thi, vi phạm) đã có sẵn ở `Operational Practitioner Exam History` (Nhóm 10) và `Operational Practitioner Violation History` (Nhóm 12) — **không** đưa vào Data Explorer để tránh fan-out phá vỡ grain 1 CCHN/NHN của bảng chính. Bước Datamart → Chỉ tiêu báo cáo sẽ JOIN `Operational Practitioner Data Explorer` với 3 bảng trên theo `Practitioner Code` tại query time — chấp nhận fan-out (1 NHN có N đợt thi × M vi phạm sẽ nhân dòng khi hiển thị đồng thời cả 2 lịch sử). Riêng `Practice Status Name` (tên hiển thị của `Practice_Status_Code` đã có sẵn) bổ sung trực tiếp vào chính bảng này (1-1, không fan-out).

**Mockup:**

| Tên cán bộ | Ngày sinh | Số định danh/Hộ chiếu | Học vấn | Tuổi | Quốc tịch | Số CCHN | Loại hình | Trạng thái CCHN | Công ty | Ngày cấp |
|---|---|---|---|---|---|---|---|---|---|---|
| Nguyễn Văn A | 12/05/1985 | 001085012345 | Đại học | 40 | Việt Nam | CCHN-2023-001 | Môi giới chứng khoán | Đang hành nghề | TESLA | 12/05/2023 |
| Lê Thị Thu B | 20/10/1990 | 001190067890 | Thạc sĩ | 35 | Việt Nam | CCHN-2024-045 | Phân tích chứng khoán | Đang hành nghề | META | 20/10/2022 |

> Đợt thi sát hạch và Vi phạm (nếu có) hiển thị dạng bảng con khi drill-down 1 dòng NHN — xem Mockup Nhóm 10 / Nhóm 12.

**Source:** `Operational Practitioner Data Explorer` (Tác nghiệp — trực tiếp từ Atomic) JOIN `Operational Practitioner 360 Profile` + `Operational Practitioner Exam History` + `Operational Practitioner Violation History` theo `Practitioner Code` (JOIN thực hiện tại bước Chỉ tiêu báo cáo, không denormalize vật lý)

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Nguồn | Ghi chú |
|---|---|---|---|---|---|
| K_NHNCK_68 | Tên cán bộ | Text | Base | `Securities Practitioner`.Full Name |  |
| K_NHNCK_69 | Số CCHN | Text | Base | `Securities Practitioner License Certificate Document`.Certificate Number |  |
| K_NHNCK_70 | Loại hình hành nghề | Text | Base | `Securities Practitioner License Certificate Document`.Certificate Type Code — ETL denormalize Certificate Type Name khi populate bảng |  |
| K_NHNCK_71 | Công ty (nơi công tác hiện tại) | Text | Base | `Securities Practitioner Organization Employment Report` → `Securities Organization Reference`.Securities Organization Reference Name (`current_organization_nm`) — bản report mới nhất có Termination Date = NULL |  |
| K_NHNCK_72 | Ngày cấp CCHN | Date | Base | `Securities Practitioner License Certificate Document`.Certificate Issue Date |  |
| K_NHNCK_73 | Trạng thái NHN | Text | Base | `Securities Practitioner`.Practice Status Code (`securities_practitioner_dim.practice_status_code`) ← `PROFESSIONALS.STATUS_WORK` (scheme: 0=Chưa hành nghề, 1=Đang hành nghề, 2=Thu hồi có cấp lại, 3=Thu hồi không cấp lại) |  |
| K_NHNCK_74 | Tổng số kết quả (NHN) | Int | Phái sinh | COUNT(DISTINCT Practitioner Code) sau khi áp slicer — hiển thị "KẾT QUẢ: N NHN" |  |
| K_NHNCK_101 | Mã định danh | Text | Base | (Sửa 2026-08) `Involved Party Alternative Identification`.Identification Type Code (Classification Value, scheme: IP_ALT_ID_TYPE — giá trị string thật: NATIONAL_ID=CMND, CITIZEN_ID=CCCD, PASSPORT=Hộ chiếu; trước đây ghi sai code số 1/2/3 chưa từng được Atomic derive) ← `PROFESSIONALS.IDENTITY_TYPE` | Xem O_NHNCK_25 |
| K_NHNCK_104 | Ngày sinh | Date | Base | `Operational Practitioner 360 Profile`.Birth Date — JOIN theo Practitioner Code | (Sửa 2026-07-22) Khai sinh tại Nhóm 13, reuse cột có sẵn Nhóm 5 |
| K_NHNCK_105 | Số định danh/Hộ chiếu | Text | Base | `Operational Practitioner 360 Profile`.Identification Number — JOIN theo Practitioner Code | (Sửa 2026-07-22) Khai sinh tại Nhóm 13, reuse cột có sẵn Nhóm 5. Khác K_NHNCK_101 (Identification Type Code — loại giấy tờ) |
| K_NHNCK_106 | Trình độ học vấn | Text | Base | `Operational Practitioner 360 Profile`.Education Level Name — JOIN theo Practitioner Code | (Sửa 2026-07-22) Khai sinh tại Nhóm 13. Gap cột vật lý — bổ sung `Education Level Code/Name` vào schema bảng `Operational Practitioner 360 Profile` (Nhóm 5, chỉ để phục vụ JOIN, không có KPI riêng ở Nhóm 5) vì trước đây chưa có ở bất kỳ bảng operational nào, chỉ có ở `securities_practitioner_dim` |
| K_NHNCK_107 | Tuổi | Int | Derived | `Operational Practitioner 360 Profile`.Age — JOIN theo Practitioner Code | (Sửa 2026-07-22) Khai sinh tại Nhóm 13, reuse cột có sẵn Nhóm 5 |
| K_NHNCK_108 | Quốc tịch | Text | Base | `Operational Practitioner 360 Profile`.Nationality Name — JOIN theo Practitioner Code | (Sửa 2026-07-22) Khai sinh tại Nhóm 13, reuse cột có sẵn Nhóm 5 |
| K_NHNCK_109 | Trạng thái CCHN | Text | Base | `Operational Practitioner Data Explorer`.Practice Status Name — denormalize từ `Practice_Status_Code` đã có sẵn trong chính bảng này | (Sửa 2026-07-22) Gap nhỏ — bổ sung cặp Name cho cột Code đã có |
| K_NHNCK_110 | Đợt thi | Text | Base | `Operational Practitioner Exam History`.Assessment Name — JOIN theo Practitioner Code | (Sửa 2026-07-22) 1-N — hiển thị toàn bộ lịch sử, fan-out khi kết hợp Nhóm vi phạm |
| K_NHNCK_111 | Kỳ thi | Text | Derived | `Operational Practitioner Exam History`.Examination Period — JOIN theo Practitioner Code | (Sửa 2026-07-22) 1-N, cùng dòng fan-out với K_NHNCK_110 |
| K_NHNCK_112 | Ngày bắt đầu thi | Date | Base | `Operational Practitioner Exam History`.Examination Start Date — JOIN theo Practitioner Code | (Sửa 2026-07-22) 1-N, cùng dòng fan-out với K_NHNCK_110 |
| K_NHNCK_113 | Ngày kết thúc thi | Date | Base | `Operational Practitioner Exam History`.Examination End Date — JOIN theo Practitioner Code | (Sửa 2026-07-22) Khai sinh tại Nhóm 13. Gap cột vật lý — bổ sung `examination_end_dt` vào schema bảng `Operational Practitioner Exam History` (Nhóm 10, chỉ để phục vụ JOIN, không có KPI riêng ở Nhóm 10) vì Atomic có sẵn nhưng chưa đưa vào Mart |
| K_NHNCK_114 | Kết quả thi | Text | Base | `Operational Practitioner Exam History`.Overall Result Name — JOIN theo Practitioner Code | (Sửa 2026-07-22) 1-N, cùng dòng fan-out với K_NHNCK_110 |
| K_NHNCK_115 | Số QĐ vi phạm | Text | Base | `Operational Practitioner Violation History`.Decision Number — JOIN theo Practitioner Code | (Sửa 2026-07-22) 1-N — hiển thị toàn bộ lịch sử, fan-out khi kết hợp Nhóm đợt thi |
| K_NHNCK_116 | Ngày QĐ vi phạm | Date | Base | `Operational Practitioner Violation History`.Decision Signed Date — JOIN theo Practitioner Code | (Sửa 2026-07-22) 1-N, cùng dòng fan-out với K_NHNCK_115 |
| K_NHNCK_117 | Nội dung vi phạm | Text | Base | `Operational Practitioner Violation History`.Note — JOIN theo Practitioner Code | (Sửa 2026-07-22) 1-N, cùng dòng fan-out với K_NHNCK_115 |

**Schema bảng tác nghiệp:**

```mermaid
erDiagram
    Operational_Practitioner_Data_Explorer {
        varchar Practitioner_Code PK
        varchar License_Certificate_Document_Code PK
        varchar Full_Name
        varchar Certificate_Number
        varchar Certificate_Type_Code
        varchar Certificate_Type_Name
        varchar Practice_Status_Code
        varchar Practice_Status_Name
        date Certificate_Issue_Date
        varchar Current_Organization_Name
        varchar Identification_Type_Code
        string Source_System_Code

    }
```

> **Ghi chú schema:** Grain = 1 CCHN per NHN. Slicer "Loại hình" filter trên `Certificate_Type_Code`; slicer "Trạng thái" filter trên `Practice_Status_Code` — cả hai filter tại query time, không pre-filter khi ETL populate. `Practice_Status_Code` phục vụ đồng thời K_NHNCK_73 (hiển thị) và slicer Trạng thái (filter) — 1 cột duy nhất, không tạo cột riêng cho slicer. `Practice_Status_Name` (K_NHNCK_109, Sửa 2026-07-22) ETL-denormalized từ Classification (scheme PRACTITIONER_PRACTICE_STATUS) khi populate — cặp Code/Name cho cùng 1 cột, không phải slicer riêng. `Certificate_Type_Name` ETL-denormalized từ Classification khi populate — presentation không join ở query time. `Current_Organization_Name` ETL-derived từ `Organization Employment Report` mới nhất có Termination Date = NULL. `Identification_Type_Code` (K_NHNCK_101, Sửa 2026-08) lấy từ `ip_alternative_identification.identification_tp_code` join qua `sp_id` — scheme IP_ALT_ID_TYPE giá trị string thật (NATIONAL_ID/CITIZEN_ID/PASSPORT), xem O_NHNCK_25.
> **(Sửa 2026-07-22)** K_NHNCK_104–108 (Ngày sinh, Số định danh, Học vấn, Tuổi, Quốc tịch) và K_NHNCK_110–117 (Đợt thi, Vi phạm) **không phải cột vật lý của bảng này** — lấy bằng JOIN sang `Operational Practitioner 360 Profile` / `Operational Practitioner Exam History` / `Operational Practitioner Violation History` theo `Practitioner Code` tại bước Chỉ tiêu báo cáo, do đó không xuất hiện trong mermaid schema trên. Xem Detail Mapping để biết logic JOIN đầy đủ.

**Lineage Mart → Báo cáo — Nhóm 13:**

```mermaid
flowchart LR
    subgraph Datamart["Datamart"]
        G1["Operational Practitioner Data Explorer"]
        G2["Operational Practitioner 360 Profile"]
        G3["Operational Practitioner Exam History"]
        G4["Operational Practitioner Violation History"]
    end
    subgraph RPT["Bao cao - Nhom 13"]
        R1["K_NHNCK_68-74,101,109: Bang tra cuu CCHN"]
        R2["K_NHNCK_104-108: Thong tin NHN"]
        R3["K_NHNCK_110-114: Dot thi sat hach"]
        R4["K_NHNCK_115-117: Vi pham"]
    end
    G1 --> R1
    G2 -- "JOIN theo Practitioner Code" --> R2
    G3 -- "JOIN theo Practitioner Code, fan-out" --> R3
    G4 -- "JOIN theo Practitioner Code, fan-out" --> R4
```

**Bảng grain — Nhóm 13:**

| Tên bảng | Grain |
|---|---|
| `Operational Practitioner Data Explorer` | 1 CCHN per NHN (toàn bộ trạng thái — slicer filter tại query time) |

> Grain hiển thị thực tế tại bước Chỉ tiêu báo cáo có thể lớn hơn 1 CCHN/NHN khi JOIN đồng thời Exam History và Violation History (N đợt thi × M vi phạm) — xem ghi chú JOIN ở đầu Nhóm 13.

---

## Section 3 — Mô hình tổng thể (READY only)

```mermaid
graph TB
    classDef dim fill:#E6F1FB,stroke:#185FA5,color:#0C447C
    classDef fact fill:#FAECE7,stroke:#993C1D,color:#4A1B0C
    classDef oper fill:#E8F5E9,stroke:#2E7D32,color:#1B5E20

    DIM_DATE["Calendar Date Dimension"]:::dim
    DIM_PRAC["Securities Practitioner Dimension"]:::dim
    DIM_CTFTP["SP License Certificate Type Dimension"]:::dim

    FACT_CERT["Fact Practitioner License Certificate Snapshot"]:::fact
    FACT_ANN["Fact Practitioner Daily Snapshot"]:::fact

    OPR1["Operational Practitioner 360 Profile"]:::oper
    OPR2["Operational Practitioner Certificate History"]:::oper
    OPR3["Operational Practitioner Employment History"]:::oper
    OPR4["Operational Practitioner Violation History"]:::oper
    OPR5["Operational Practitioner Exam History"]:::oper
    OPR6["Operational Practitioner Training History"]:::oper
    OPR7["Operational Practitioner Related Party Profile"]:::oper
    OPR8["Operational Practitioner Data Explorer"]:::oper

    DIM_DATE --> FACT_CERT
    DIM_DATE --> FACT_ANN
    DIM_PRAC --> FACT_CERT
    DIM_PRAC --> FACT_ANN
    DIM_CTFTP --> FACT_CERT
```

**Bảng Phân tích (Star Schema):**

| Bảng | Pattern | Grain | KPI | Trạng thái |
|---|---|---|---|---|
| `Fact Practitioner License Certificate Snapshot` | Periodic Snapshot | 1 CCHN × 1 lần cấp/cấp lại × 1 tháng | K_NHNCK_2, 2a, 2b, 3, 5, 6, 7, 8, 17–22 (Nhóm 1a, 3) | READY |
| `Fact Practitioner Daily Snapshot` | Periodic Snapshot | 1 NHN × 1 ngày | K_NHNCK_1, 4, 9–14, 23–32 (Nhóm 1b, 2, 4) | READY |

**Bảng Tác nghiệp (Denormalized):**

| Bảng | Grain | KPI | Trạng thái |
|---|---|---|---|
| `Operational Practitioner 360 Profile` | 1 NHN (latest state) | K_NHNCK_33–41 (Nhóm 5) | READY |
| `Operational Practitioner Certificate History` | 1 CCHN per NHN | K_NHNCK_43–48 READY; K_NHNCK_92 (Số quyết định thu hồi) READY | READY |
| `Operational Practitioner Employment History` | 1 lần công tác per NHN | K_NHNCK_49–53, K_NHNCK_90 (Phân loại tổ chức), K_NHNCK_91 (Phòng ban) | READY |
| `Operational Practitioner Violation History` | 1 vi phạm per NHN | K_NHNCK_54, K_NHNCK_55, K_NHNCK_56, K_NHNCK_57, K_NHNCK_58 READY (Sửa 2026-08 — đóng O_NHNCK_17, O_NHNCK_15) | READY |
| `Operational Practitioner Exam History` | 1 lần thi per NHN | K_NHNCK_59–63 READY; K_NHNCK_94 (KQ luật), K_NHNCK_95 (KQ CM), K_NHNCK_102 (Kỳ thi) READY. (Sửa 2026-07-20) K_NHNCK_93 (Điểm CM) đã xóa — BA v2 không còn yêu cầu field này. **(Sửa 2026-08-07)** BA bổ sung lại yêu cầu điểm thi chuyên môn — khai sinh ID mới K_NHNCK_119 (không tái dùng K_NHNCK_93 đã gap). Thêm K_NHNCK_118 (Ngày kết thúc thi) | READY |
| `Operational Practitioner Training History` | (Sửa 2026-08) 1 lần bồi dưỡng per NHN | K_NHNCK_100, K_NHNCK_96, K_NHNCK_97, K_NHNCK_98, K_NHNCK_99, K_NHNCK_66, K_NHNCK_67 READY (đóng O_NHNCK_9) | READY |
| `Operational Practitioner Related Party Profile` | 1 người liên quan per NHN | K_NHNCK_75–80 READY; K_NHNCK_86 (Địa chỉ) READY | READY |
| `Operational Practitioner Listed Company Role` | 1 vai trò per NHN per DN niêm yết | K_NHNCK_81–85 READY; K_NHNCK_87–89, K_NHNCK_103 READY (Sửa 2026-08-07, ngoại lệ VSDC/MSS — xem O_NHNCK_6) | READY |
| `Operational Practitioner Data Explorer` | 1 CCHN per NHN (slicer filter tại query time) | K_NHNCK_68–74 READY; K_NHNCK_101 (Mã định danh) READY | READY |

**Bảng Dimension:**

| Dimension | Loại | Mô tả | Scheme | Trạng thái |
|---|---|---|---|---|
| `Calendar Date Dimension` | Conformed | Lịch ngày — năm/quý/tháng/ngày | — | READY |
| `Securities Practitioner Dimension` | Reference per module (SCD4A) | NHN — định danh, trình độ, quốc tịch, ngày sinh, trạng thái | — | READY |
| `SP License Certificate Type Dimension` | Reference per module (SCD4A) | Loại CCHN (Môi giới, Phân tích, QLQ...) — Fundamental entity riêng, nguồn `NHNCK.CERTIFICATES` (Atomic: `sp_license_certificate_type`). Không còn là Classification Value scheme (scheme `CERTIFICATE_TYPE`/`NHNCK_CERTIFICATE_TYPE` đã bị xóa khỏi `classification_schemes.yaml` từ 2026-07-07) | — | READY |

---

## Section 4 — Reuse Analysis

| Datamart Entity | datamart_table | reuse_status | Ghi chú |
|---|---|---|---|
| Calendar Date Dimension | cdr_dt_dim | new | Module đầu tiên — NHNCK thiết kế bảng này. Conformed Dim (SHARED), module khác có thể reuse |
| Securities Practitioner Dimension | securities_practitioner_dim | new | Đã có trong datamart_model.yaml |
| SP License Certificate Type Dimension | sp_license_certificate_type_dim | new | Đã có trong datamart_model.yaml. Atomic nguồn `sp_license_certificate_type` (`DataModel/working/Atomic`) coi là READY theo quy ước Datamart |
| Fact Practitioner License Certificate Snapshot | fct_practitioner_license_certificate_snpst | new | Đã có trong datamart_model.yaml |
| Fact Practitioner Daily Snapshot | fct_practitioner_daily_snpst | new | Đã có trong datamart_model.yaml |
| Operational Practitioner 360 Profile | opr_practitioner_360_profile | new | Đã có trong datamart_model.yaml |
| Operational Practitioner Certificate History | opr_practitioner_certificate_hist | new | Đã có trong datamart_model.yaml |
| Operational Practitioner Employment History | opr_practitioner_employment_hist | new | Đã có trong datamart_model.yaml |
| Operational Practitioner Violation History | opr_practitioner_violation_hist | new | Đã có trong datamart_model.yaml |
| Operational Practitioner Exam History | opr_practitioner_exam_hist | new | Đã có trong datamart_model.yaml |
| Operational Practitioner Training History | opr_practitioner_training_hist | new | Đã có trong datamart_model.yaml |
| Operational Practitioner Related Party Profile | opr_practitioner_related_party_profile | new | Đã có trong datamart_model.yaml |
| Operational Practitioner Listed Company Role | opr_practitioner_list_company_role | new | Đã có trong datamart_model.yaml |
| Operational Practitioner Data Explorer | opr_practitioner_data_explorer | new | Đã có trong datamart_model.yaml |

---

## Section 5 — Vấn đề mở

| ID | Vấn đề | Giả định hiện tại | KPI liên quan | Trạng thái |
|---|---|---|---|---|
| O_NHNCK_1 | (Revised 2026-07-17) Phân biệt Thu hồi 3 năm vs Thu hồi vĩnh viễn. Quyết định trước đó (dùng `Reissuance_Allowed_Count` trên `sp_license_certificate_document`, cấp CCHN) đã được xem xét lại: BA gốc thực chất yêu cầu filter theo `PROFESSIONALS.STATUS_WORK` (cấp NHN) — Atomic `securities_practitioner.practice_status_code` chính là source column trực tiếp của `STATUS_WORK` nên đã sẵn sàng dùng, không cần đổi field. K_NHNCK_6 revert về `Practice_Status_Code='2'` (JOIN `Securities_Practitioner_Dimension`), khớp đúng BA gốc và nhất quán với K_NHNCK_7 (`Practice_Status_Code='3'`). Cột `Allow_Reissue_Indicator`/`Reissuance_Allowed_Count` không còn dùng — đã loại khỏi Fact schema. K_NHNCK_7 cũng bổ sung thêm filter `Decision_Type_Code='2'` (trước đó thiếu). K_NHNCK_5 bổ sung filter `Practice_Status_Code='1'` (trước đó không filter gì, ghi chú "staging đã lọc chỉ bản ghi hiệu lực" không đúng vì staging/ODS không filter RECORD_STATUS). | K_NHNCK_5, K_NHNCK_6, K_NHNCK_7 | Closed |
| O_NHNCK_2 | `Nationality_Code` nguồn từ `ProfessionalHistories.NationalityCode`. | Đã xác nhận — có trên Atomic. | K_NHNCK_23–32 | Closed |
| O_NHNCK_3 | Logic YTD: năm hiện tại đến today; năm quá khứ đến 31/12/Y. | Đã xác nhận. | K_NHNCK_2, 2a, 2b | Closed |
| O_NHNCK_4 | Tuổi tính từ `Birth_Date` (date) từ `ProfessionalHistories.BirthDate`. | `Age = Year(Snapshot_Date) − Year(Birth_Date)`. Đã xác nhận. | K_NHNCK_23–32, K_NHNCK_35 | Closed |
| O_NHNCK_5 | (Sửa 2026-07-21 — review datamart-review) `Has_Active_Violation`: thiết kế trước đó (2026-07-17) ghi công thức `Violation_Status_Code = 1 (ACTIVE)` — cột này không tồn tại trong Atomic `sp_conduct_violation` (chỉ 10 attribute: Id/Code, Source System Code, Practitioner Id/Code, License Decision Document Id/Code, Practitioner Name/Birth Date/Identity Number At Violation, Violation Record Date, Note). Đối chiếu lại SQL BA gốc (`SELECT COUNT(DISTINCT t.Certificate_Number) FROM Certificate_Records t JOIN Professionals a ON t.PROFESSIONAL_ID = a.ID JOIN Violations v ON a.ID = v.Professional_Id`) xác nhận BA **không có điều kiện lọc trạng thái** — chỉ cần tồn tại ít nhất 1 bản ghi vi phạm. Kết luận: `Has_Active_Violation = 'Y'` nếu NHN có ít nhất 1 `Conduct Violation` (bất kỳ, không phân biệt trạng thái), `'N'` nếu không có — khớp đúng SQL BA, không phải gap Atomic. Attributes/Detail Mapping (`IS NOT NULL`) đã triển khai đúng ngay từ đầu; chỉ có Ghi chú công thức trong HLD (Nhóm 1b/2/4) mô tả sai — đã sửa khớp BA. | Đã xác nhận khớp SQL BA gốc — không cần bổ sung Atomic. K_NHNCK_4 giữ READY. | K_NHNCK_4 | Closed |
| O_NHNCK_6 | (Cập nhật v6.5) K_NHNCK_81–84 đã READY. K_NHNCK_84 (Mã CTCK): `sp_organization_employment_report.securities_organization_reference_code` JOIN `securities_organization_reference` filter `Organization Type Code = 'CTCK'` — xác nhận Atomic có attribute này. Tên DN: `Practitioner Workplace At Report` (đã fix từ "Workplace Name"). (Cập nhật 2026-07-17) **K_NHNCK_85 reopen review — chuyển READY**: nguồn thật là SCMS (`SC_FIRM_SHAREHOLDER.SHARES_HELD`), không phải VSDC như ghi nhận trước đó — người thiết kế đã xác nhận qua kiểm tra Atomic. (Sửa 2026-07-20) **Fix gap logic join (2 lỗi)**: (1) chuỗi ban đầu đi qua `Sc Insider Related Person` rồi join `sc_id` (CTCK) tới `Securities Company Shareholder` — 2 entity này KHÔNG có FK trực tiếp, join theo `sc_id` chỉ đảm bảo cùng 1 CTCK (nhiều insider × nhiều shareholder) → sai người + fan-out; (2) driving-placeholder sai — `Securities Practitioner` không phải bảng nguồn khai báo của mapping này, phải bắt cầu qua `sp_id` có sẵn trên driving table `Securities Practitioner Organization Employment Report` (FK trực tiếp tới `Securities Practitioner`). Join đúng đã xác nhận: `Securities Practitioner Organization Employment Report`.sp_id (driving) → `Involved Party Alternative Identification` (NHNCK, CCCD) = `Involved Party Alternative Identification` (SCMS nguồn `SC_FIRM_SHAREHOLDER`, `ID_NUMBER`) → FK trực tiếp (`ip_id`) → `Securities Company Shareholder`.Shares Held — không qua `Sc Insider Related Person`. Cả 3 entity Atomic trong chuỗi join đều đã approved — không còn gap. PENDING trước đây: K_NHNCK_87/88/89 (Tài khoản cross-broker — VSDC/MSS, nguồn dạng biểu mẫu thủ công, chưa có CSDL). **(Sửa 2026-08-07)** BA bổ sung tên bảng/cột nguồn cụ thể (`open_investors.ma_tkgd`/`ten_khach_hang`, `major_shareholder.ma_ck`/`so_luong_ck_cuoi_ky`) — user xác nhận coi đây là Atomic thật, không chờ thiết kế Atomic LLD chính thức (ngoại lệ, tương tự `rsk_wgt_cfg`/PTTT). K_NHNCK_87/88/89/103 chuyển PENDING → READY. | K_NHNCK_81–85 READY. K_NHNCK_87–89, K_NHNCK_103 READY (2026-08-07). | K_NHNCK_81–89, K_NHNCK_103 | Closed |
| O_NHNCK_7 | Counter "N N/Quan": nguồn `Securities Practitioner Related Party` (NHNCK) READY. Cần BA xác nhận filter loại quan hệ: toàn bộ hay chỉ một số loại (vợ/chồng, con, bố/mẹ...)? Counter "N Doanh nghiệp": PENDING chờ Atomic SGDCK. | K_NHNCK_42 đã bị xóa khỏi BA analyst — KPI không còn tồn tại trong scope. Issue tự đóng. | K_NHNCK_42 | Closed |
| O_NHNCK_8 | Logic Đạt/Không đạt trong `Operational Practitioner Exam History`: Atomic `ExamDetails` có `Examination_Result_Code` (scheme: EXAMINATION_RESULT — 1: Đạt, 0: Không đạt) — đã có sẵn, không cần derive. | Dùng `Examination_Result_Code` trực tiếp từ Atomic. Đã xác nhận. | K_NHNCK_63 | Closed |
| O_NHNCK_9 | **[ĐÃ XỬ LÝ 2026-08]** (Sửa 2026-07-17) `POST_CERT_TRAINING_RESULTS` chưa có Atomic entity — blocking K_NHNCK_67 "Trạng thái đủ 8h". Atomic đã bổ sung entity `sp_post_certification_training_result` (2026-07-24). Đối chiếu lại BA đã cập nhật (BA_analyst_NHNCK.csv, Nhóm 11) xác nhận: driving Operational Practitioner Training History đổi hẳn sang `sp_post_certification_training_result` (grain: 1 lần bồi dưỡng per NHN, không còn 1 enrollment); tên/mã khóa học đổi nguồn sang `POST_CERT_TRAINING_COURSES` (không còn `SPECIALIZATION_COURSES`); Exam Score/Result Code trở thành JOIN phụ qua `sp_code` (chấp nhận fan-out, đúng SQL BA JOIN SPECIALIZATION_COURSE_DETAILS SD ON SD.PROFESSIONAL_ID = P.ID). | K_NHNCK_67 READY — `training_hours`/`hours_sufficiency_indicator` trên driving mới. K_NHNCK_96–100, K_NHNCK_66 cập nhật nguồn theo driving mới. | K_NHNCK_66, K_NHNCK_67, K_NHNCK_96, K_NHNCK_97, K_NHNCK_98, K_NHNCK_99, K_NHNCK_100 | Closed |
| O_NHNCK_10 | **[SUPERSEDED bởi O_NHNCK_20]** `Is_Reissue_Indicator` (Indicator Y/N) trên Fact Certificate Snapshot: ETL-derived bằng cách join `CertificateRecords → Applications` lấy `Application_Type_Code` (scheme: APPLICATION_TYPE). BA v2 xác nhận scheme APPLICATION_TYPE có 4 giá trị: (1) "Hồ sơ cấp mới" → `Is_Reissue_Indicator = 'N'`; (2) "Hồ sơ cấp lại do thu hồi", (3) "Hồ sơ cấp lại do hỏng mất", (4) "Hồ sơ cấp lại do thay đổi thông tin" → `Is_Reissue_Indicator = 'Y'`. ETL logic: nếu Application_Type_Code thuộc nhóm (2)/(3)/(4) thì 'Y', chỉ (1) là 'N'. K_NHNCK_2b đếm tất cả 3 loại cấp lại gộp chung. | `Is_Reissue_Indicator = 'Y'` nếu ApplicationType ∈ {cấp lại do thu hồi, do hỏng mất, do thay đổi thông tin}. Đã xác nhận logic với BA v2. **(2026-08) Logic này đã bị thay bằng Decision Type — xem O_NHNCK_20.** | K_NHNCK_2a, K_NHNCK_2b | Superseded |
| O_NHNCK_11 | **[ĐÃ XỬ LÝ 2026-08]** (Cập nhật review 2026-07-16) K_NHNCK_79 (CCCD/CMND) reopen PENDING vì `PROFESSIONAL_RELATIONSHIPS.IDENTITY_ID` chỉ là FK trỏ `IDENTITY_INFO_C06S.ID`, không phải số CMND/CCCD thật. Atomic entity `sp_related_party` (DataModel/Atomic, nguồn ưu tiên 1) thực tế đã có sẵn field `related_individual_identity_nbr` (direct từ `PROFESSIONAL_RELATIONSHIPS.IDENTITY_ID`, không crosswalk qua `individual`). Theo quyết định Data Modeler (2026-08), dùng trực tiếp field này — không chờ crosswalk `IDENTITY_INFO_C06S`. | K_NHNCK_75–80, 86 READY. K_NHNCK_79 dùng `sp_related_party.related_individual_identity_nbr` trực tiếp. | K_NHNCK_75–80, K_NHNCK_86 | Closed |
| O_NHNCK_12 | (Sửa 2026-07-17) K_NHNCK_101 (cũ) "Kết quả kiểm tra, phân loại" (BA row 86, Nhóm 11) và K_NHNCK_66 "Kết quả thi" (BA row 93, Nhóm 11) là 2 dòng mô tả BA khác câu chữ nhưng cùng trỏ về 1 nguồn vật lý duy nhất: `NHNCK.SPECIALIZATION_COURSE_DETAILS.RESULT` → Atomic `sp_professional_training_class_enrollment.trn_rslt_code` (scheme EXAM_RESULT) → cùng cột `training_result_code`/`training_result_nm` trên `opr_practitioner_training_hist`. Không giữ 2 KPI_ID song song cho cùng 1 cột vật lý (gây trùng slicer khi Detail Mapping join) → xóa K_NHNCK_101 (cũ), reuse thẳng K_NHNCK_66. **[Lưu ý 2026-08]** Tên cột vật lý `training_result_code`/`training_result_nm` trong ghi chú lịch sử này đã đổi thành `exam_result_code`/`exam_result_nm` (xem O_NHNCK_9) — driving `opr_practitioner_training_hist` đổi sang `sp_post_certification_training_result`, cột kết quả kiểm tra chuyển thành JOIN phụ qua `sp_code` (fan-out). (Renumber 2026-07-17: sau khi xóa, các ID phía sau dịch chuyển — K_NHNCK_102 (cũ, Mã định danh) → **K_NHNCK_101 (mới)**; K_NHNCK_103 (cũ, Kỳ thi) → **K_NHNCK_102 (mới)**. Số "K_NHNCK_101" trong toàn bộ ghi chú lịch sử từ đây trở về trước luôn chỉ ID cũ đã xóa, KHÔNG phải "Mã định danh".) | K_NHNCK_101 (cũ) đã xóa — reuse K_NHNCK_66. ID phía sau renumber lùi 1. | K_NHNCK_66, K_NHNCK_101 (cũ, removed), K_NHNCK_101/102 (mới, renumbered) | Closed |
| O_NHNCK_13 | K_NHNCK_57 "Hình thức xử phạt": BA (STT 12, row 406) ghi nguồn `Violations.RECORD_TYPE` → Atomic `record_tp_code` (scheme RECORD_TYPE: 1=Hành chính, 2=Pháp luật). Màn hình mockup hiển thị nội dung xử phạt chi tiết ("550,000,000 VND", "Cảnh cáo"...) nhưng đây là **dữ liệu giả lập** — không phải nguồn sự thật. Mapping `record_tp_code` theo BA là đúng. **[Lưu ý 2026-08]** Tên cột vật lý `record_tp_code` trong ghi chú lịch sử này đã lỗi thời — xem O_NHNCK_17: Atomic field thật là `violation_tp_code` (nguồn `VIOLATIONS.TYPE`), không phải `record_tp_code`. | Đã xác nhận — mapping theo BA. | K_NHNCK_57 | Closed |
| O_NHNCK_14 | K_NHNCK_73 "Trạng thái": BA ghi `PROFESSIONALS.RECORD_STATUS`; người thiết kế xác nhận đây là **trạng thái NHN** (không phải trạng thái CCHN). Đã đổi nguồn → `securities_practitioner_dim.practice_status_code` ← `PROFESSIONALS.STATUS_WORK` (scheme: 0=Chưa hành nghề, 1=Đang hành nghề, 2=Thu hồi có cấp lại, 3=Thu hồi không cấp lại). Tên KPI đổi từ "Trạng thái CCHN" → "Trạng thái NHN". | Đã xác nhận — mapping cập nhật về `practice_status_code`. | K_NHNCK_73 | Closed |
| O_NHNCK_15 | **[ĐÃ XỬ LÝ 2026-08]** (Sửa 2026-07-17) K_NHNCK_58 "Trạng thái vi phạm": BA mapping về `VIOLATIONS.STATUS` — chỉ có 2 giá trị kỹ thuật ghi nhận trước đó (1=Đang hoạt động/Hiệu lực, 0=Không hoạt động), không khớp 6 trạng thái nghiệp vụ BA yêu cầu ban đầu ("thực thi quyết định"). BA cập nhật lại (BA_analyst_NHNCK.csv, Nhóm 12, đã hỏi Liên - Tinh Vân) xác nhận: STATUS thực tế có **3 mức kỹ thuật** 1=ACTIVE, 0=INACTIVE, -1=DELETED — đây chính là ý nghĩa đúng, không phải 6 trạng thái thực thi. Đã bổ sung giá trị DELETED vào scheme `VIOLATION_STATUS`, đổi tên KPI hiển thị cho khớp ý nghĩa thật. | K_NHNCK_58 READY — dùng `sp_conduct_violation.violation_status_code`, đổi tên cột `record_status_code` → `violation_status_code`. | K_NHNCK_58 | Closed |
| O_NHNCK_16 | **[ĐÃ XỬ LÝ 2026-08]** (Phát hiện review 2026-07-16) K_NHNCK_48 "Trạng thái CCHN" (Nhóm 9): BA ghi nguồn `CERTIFICATE_RECORD_STATUS_HISTORIES.NEW_STATUS`, nhưng bảng này trước đây out-of-scope Atomic. Atomic đã đưa `CERTIFICATE_RECORD_STATUS_HISTORIES` vào scope (2026-07-24), entity `sp_license_certificate_status_change_history`, field `new_certificate_status_code` (scheme CERTIFICATE_STATUS: 0-5). Lấy bản ghi mới nhất theo BK tăng dần (entity là Fact Append, không có cột ngày — chấp nhận rủi ro nếu ID không đúng thứ tự thời gian tuyệt đối, xử lý sau nếu phát sinh). | K_NHNCK_48 READY — đổi tên cột `process_status_code` (sai ý nghĩa, đã loại khỏi schema) thành `certificate_status_code`, join `sp_license_certificate_status_change_history`. | K_NHNCK_48 | Closed |
| O_NHNCK_17 | **[ĐÃ XỬ LÝ 2026-08]** (Phát hiện review 2026-07-17) K_NHNCK_57 "Hình thức xử phạt" (Nhóm 12): Atomic `sp_conduct_violation` trước đây không có field cho `VIOLATIONS.TYPE`. Atomic đã bổ sung field `violation_tp_code` (scheme VIOLATION_TYPE: 1=Hành chính/ADMINISTRATIVE, 2=Pháp luật/LEGAL — đã xác nhận với BA). | K_NHNCK_57 READY — dùng `sp_conduct_violation.violation_tp_code`, đổi tên cột `record_tp_code` → `violation_tp_code`. | K_NHNCK_57 | Closed |
| O_NHNCK_18 | (Phát hiện review 2026-07-20) `SP License Certificate Type Dimension` — Atomic nguồn `sp_license_certificate_type` (NHNCK.CERTIFICATES, `DataModel/working/Atomic`) đã đổi pattern Id+Code+Unique Key → Id+Code (2026-07-13; Code nay = `sp_license_certificate_type_code` thay ID cũ) — coi là READY theo quy ước Datamart (working = đã review, chỉ chờ designer sign-off hành chính). Dimension đã có mermaid/grain trong HLD Section 3 nhưng chưa được khai sinh chính thức trong Entities.csv/datamart_model.yaml — đã bổ sung (2026-07-20). 5 dòng Attributes (`opr_practitioner_certificate_hist`, `opr_practitioner_data_explorer`, `opr_practitioner_360_profile` x2, `fct_practitioner_license_certificate_snpst`) đang tham chiếu `sp_license_certificate_type_unique_key` — cột không tồn tại trong Atomic YAML, đã sửa về `sp_license_certificate_type_code`. **[Lưu ý 2026-08]** Tên cột vật lý `sp_license_certificate_type_code` trong ghi chú lịch sử này đã lỗi thời — xem O_NHNCK_22: physical_name thật trong Atomic là `sp_license_certificate_tp_code` (không có đầy đủ "type", chỉ "tp"). | Đã khai sinh Dimension + sửa Attributes map đúng cột. K_NHNCK_17/18/19/39/44/70 READY. | K_NHNCK_17, K_NHNCK_18, K_NHNCK_19, K_NHNCK_39, K_NHNCK_44, K_NHNCK_70 | Closed |
| O_NHNCK_22 | (Phát hiện review `/datamart-review` 2026-08) Toàn bộ Attributes/registry NHNCK tham chiếu Atomic entity `sp_license_certificate_type`/`sp_license_certificate_document` qua tên cột `sp_license_certificate_type_code`/`sp_license_certificate_type_id` — nhưng physical_name thật trong Atomic YAML (`dm_atm_sp_license_certificate_type-NHNCK.CERTIFICATES.yaml`, `dm_atm_sp_license_certificate_document-NHNCK.CERTIFICATE_RECORDS.yaml`) là `sp_license_certificate_tp_code`/`sp_license_certificate_tp_id` (không có đầy đủ "type", chỉ viết tắt "tp"). Lỗi field-name thuần, không ảnh hưởng ý nghĩa/giá trị/logic join — đã tồn tại từ 2026-07-20 (O_NHNCK_18) qua nhiều lượt review mà không bị phát hiện vì tên cột "nghe hợp lý", không ai đối chiếu ngược lại chuỗi ký tự chính xác trong YAML. Ảnh hưởng 6 file: `fct_practitioner_license_certificate_snpst`, `sp_license_certificate_type_dim`, `opr_practitioner_certificate_hist`, `opr_practitioner_data_explorer`, `datamart_attributes.csv`, `datamart_model.yaml`. Đồng thời xác nhận giá trị filter Certificate Type Code cho K_NHNCK_17/18/19 (Nhóm 3) = 'MGCK'/'PTTC'/'QLQ' theo BA gốc (JOIN CERTIFICATE_RECORDS→CERTIFICATES, filter CERTIFICATE_CODE) — giữ nguyên, không đổi. Comment ví dụ trong YAML Atomic ("VD: QLQY, PTDT, MTCK") không khớp giá trị BA thật — đã sửa lại ví dụ cho khớp. | Đã sửa `sp_license_certificate_type_code`→`sp_license_certificate_tp_code`, `sp_license_certificate_type_id`→`sp_license_certificate_tp_id` ở toàn bộ 6 file trên. Giá trị filter 'MGCK'/'PTTC'/'QLQ' giữ nguyên — đã đúng. | K_NHNCK_17, K_NHNCK_18, K_NHNCK_19, K_NHNCK_39, K_NHNCK_44, K_NHNCK_70 | Closed |
| O_NHNCK_19 | (Phát hiện 2026-07-30) K_NHNCK_2 trước đây tự tính `COUNT(DISTINCT License Certificate Document Code)` độc lập trên toàn bộ Application Type IN ('0','1','2','3') — không đảm bảo luôn khớp `K_NHNCK_2a + K_NHNCK_2b` như định nghĩa BA (2 = 2a + 2b), vì DISTINCT tính theo 2 filter riêng (is_reissue='N' cho 2a, ='Y' cho 2b) có thể cho tổng khác với DISTINCT tính trên toàn bộ tập hợp (VD: 1 CCHN vừa cấp mới vừa cấp lại trong cùng năm — DISTINCT toàn cục đếm 1, nhưng 2a+2b đếm 2). Fix: K_NHNCK_2 đổi thành DERIVED = tổng 2 `COUNT(DISTINCT License Certificate Document Code)` tách theo nhánh `is_reissue_indicator = 'N'` và `= 'Y'` (viết đầy đủ công thức physical theo cả 2 nhánh trong Detail Mapping, KHÔNG refer trực tiếp KPI_ID `K_NHNCK_2a`/`K_NHNCK_2b` trong cột `logic` — vi phạm quy tắc DERIVED của `datamart-lld-design`, ngoại lệ refer KPI_ID chỉ áp dụng cho công thức YoY). K_NHNCK_2a/2b giữ nguyên `COUNT(DISTINCT License Certificate Document Code)` — mỗi CCHN chỉ đếm 1 lần trong từng nhóm dù có nhiều lần cấp lại/cấp mới cùng loại trong năm (người thiết kế xác nhận đây là ngữ nghĩa đúng, không đếm theo số sự kiện/application). Lưu ý: 1 CCHN vừa cấp mới vừa cấp lại trong cùng năm được đếm ở CẢ 2a và 2b — do đó K_NHNCK_2 (=2a+2b) có thể lớn hơn số CCHN khác nhau thực tế trong năm đó, đây là hành vi đã xác nhận đúng ý BA, không phải bug. Grain Fact xác nhận thực tế = 1 CCHN × 1 lần cấp/cấp lại × 1 tháng (mỗi lần cấp sinh 1 dòng Fact riêng qua join `sp_license_application`, dù cùng document_code) — đã cập nhật Entities.csv/Section 3 khớp thực tế ETL. | K_NHNCK_2/2a/2b đã sửa công thức. Vẫn READY. | K_NHNCK_2, K_NHNCK_2a, K_NHNCK_2b | Closed |
| O_NHNCK_20 | (Phát hiện review 2026-08) Đối chiếu lại BA gốc (STT 1, dòng SQL tham khảo `Certificate_Records t JOIN DECISIONS d ON d.ID = t.REVOCATION_DECISION_ID WHERE d.DECISION_TYPE_ID = '1'/'3'`) xác nhận nguồn phân loại Cấp mới/Cấp lại là **Decision Type** (`DECISIONS.DECISION_TYPE_ID`, join qua field `REVOCATION_DECISION_ID` — tên cột nguồn gây nhiễu nhưng BA dùng chung cho mọi loại quyết định, không riêng thu hồi), KHÔNG phải Application Type (`Applications.APPLICATION_TYPE`) như O_NHNCK_10. Application Type đo hồ sơ nộp (có thể bị từ chối/đổi loại giữa xử lý), Decision Type đo quyết định đã ban hành — hai KPI khác bản chất dù cùng tên "Cấp mới/Cấp lại". Đồng thời sửa `Certificate_Issue_Date`/`Issue_Date_Dimension_Id` lấy trực tiếp từ `Securities Practitioner License Certificate Document.Issue Date` (cùng bảng, có sẵn — trước đây lấy nhầm từ Application), và xoá cột `Certificate_Type_Code` dư thừa khỏi Fact (đã có FK `Certificate_Type_Dimension_Id` — K_NHNCK_17–22 đổi filter sang JOIN Dimension). Cùng đợt: `Nationality_Code/Name` (Nhóm 5, K_NHNCK_36) đổi sang tự JOIN `Geographic Area` filter `COUNTRY` (không dùng cột denormalized cũ); `Active_Certificate_Type_Code/Name`/`Active_Certificate_Number` (K_NHNCK_39/40) đổi từ Organization Employment Report sang JOIN trực tiếp Certificate Document (bản ghi Issue Date mới nhất per NHN) theo BA chốt nguồn CERTIFICATE_RECORDS; `Workplace` (K_NHNCK_38) đổi lại về `PROFESSIONALS.WORKPLACE` đúng theo BA, không qua Organization Employment Report như quyết định 2026-07-20. | `Is_Reissue_Indicator` derive từ Decision Type Code ('3'=Y Cấp lại, '1'=N Cấp mới, NULL nếu chưa có quyết định) qua JOIN `Securities Practitioner License Decision Document` bằng `revocation_sp_license_decision_document_id`. Cố ý dùng LEFT JOIN (không INNER JOIN như SQL tham khảo BA) vì cột nằm trên Fact dùng chung nhiều KPI khác — filter `is_reissue_indicator = 'N'`/`'Y'` tại K_NHNCK_2a/2b tự loại NULL, tương đương INNER JOIN đúng tại 2 KPI cần. Tất cả đã cập nhật `datamart_model.yaml`, LLD CSV, Detail Mapping, Entities.csv. | K_NHNCK_2, K_NHNCK_2a, K_NHNCK_2b, K_NHNCK_17–22, K_NHNCK_36, K_NHNCK_38, K_NHNCK_39, K_NHNCK_40 | Closed |
| O_NHNCK_21 | (Phát hiện review `/datamart-review` 2026-08) K_NHNCK_9/10/11 (Nhóm 2, Trình độ chuyên môn) filter `Education Level Code = 'DOCTORATE'/'MASTER'/'BACHELOR'` — 3 code tiếng Anh này **không tồn tại** trong Atomic: scheme `EDUCATION_LEVEL` (`classification_schemes.yaml`) có `values: []`, chưa từng enum hóa. User bổ sung dữ liệu `cl_value` export thật (src_stm_code=NHNCK_EDUCATION_LEVELS) xác nhận: (1) tên scheme đúng phải là `EDUCATIONAL_LEVEL` (không phải `EDUCATION_LEVEL`, thiếu "AL"); (2) `cl_code` lưu trực tiếp bằng tiếng Việt, không phải code tiếng Anh; (3) có **4 giá trị thật**: "Đại học", "Cử nhân", "Thạc sĩ", "Tiến sĩ" — nhiều hơn 3 dòng BA liệt kê (không có "Cử nhân"). Người thiết kế đã chốt: K_NHNCK_11 "Đại học" CHỈ filter đúng `= 'Đại học'`, KHÔNG gộp `'Cử nhân'` — "Cử nhân" hiện không có KPI riêng nào trong scope BA. Nếu sau này cần đo riêng "Cử nhân" hoặc gộp chung "trình độ Đại học" theo nghĩa rộng — cần hỏi lại BA trước khi thêm KPI mới. | `EDUCATIONAL_LEVEL` đã bổ sung đủ 4 giá trị vào `classification_schemes.yaml`. K_NHNCK_9/10/11/12/13/14 đổi filter sang giá trị tiếng Việt thật. Attributes/Detail Mapping/registry đã đồng bộ. | K_NHNCK_9, K_NHNCK_10, K_NHNCK_11, K_NHNCK_12, K_NHNCK_13, K_NHNCK_14 | Open (chờ BA xác nhận có cần KPI riêng cho "Cử nhân" hay không) |
| O_NHNCK_23 | (Phát hiện review `/datamart-review` 2026-08) K_NHNCK_37 (Nhóm 5, Số định danh/Hộ chiếu) filter `identification_tp_code IN ('CCCD','PASSPORT')` — Atomic field `ip_alternative_identification.identification_tp_code` (nguồn NHNCK.PROFESSIONALS) có comment rõ "PENDING — Data Modeler sẽ profile dữ liệu thực tế trước khi xác nhận mapping ETL... tạm thời KHÔNG derive giá trị (mapping cũ 1=NATIONAL_ID;2=CITIZEN_ID;3=PASSPORT chưa được xác nhận, tạm gỡ)" — `etl_derived_value: null`. Đồng thời scheme dùng chung `IP_ALT_ID_TYPE` không có giá trị `'CCCD'`, chỉ có `CITIZEN_ID` (=CCCD) và `PASSPORT` — filter cũ dùng sai cả tên code. Đối chiếu lại BA gốc (STT 5) xác nhận: BA chỉ map thẳng `PROFESSIONALS.IDENTITY_NUMBER`, KHÔNG có điều kiện lọc loại giấy tờ nào — filter `IN (...)` là suy diễn thừa không có cơ sở BA. Người thiết kế xác nhận: bỏ hẳn filter, lấy trực tiếp `identification_nbr` không lọc loại giấy tờ. | Đã bỏ điều kiện `identification_tp_code IN (...)` khỏi `etl_logic` — JOIN chỉ còn filter `ip_id`/`src_stm_code`. Attributes/registry đã đồng bộ. | K_NHNCK_37 | Closed |
| O_NHNCK_24 | (Phát hiện review `/datamart-review` 2026-08) K_NHNCK_80 (Nhóm 6, Quốc tịch người liên quan) dùng cột denormalized `sp_related_party.country_code` trực tiếp — nhưng Atomic field `country_id` cùng entity có comment "Chưa xác nhận value set khớp danh mục ECAT — cần profile dữ liệu trước go-live", giống hệt case `nationality_code` đã sửa ở O_NHNCK_20 (Nhóm 1/5). Người thiết kế xác nhận sửa theo cùng pattern. Cùng lúc phát hiện lỗi phụ: `source_atomic` list của entity `opr_practitioner_related_party_profile` trong `datamart_model.yaml` ghi `"geo"` (viết tắt tùy tiện, không nhất quán với các entity khác đều dùng đầy đủ `"geographic_area"`) — đã sửa. | Đổi sang tự JOIN `geographic_area` qua `country_id`, filter `geographic_area_tp_code='COUNTRY'`, lấy `geographic_area_code` thay cột denormalized cũ. Attributes/registry đã đồng bộ, `source_atomic` list đã sửa `"geo"`→`"geographic_area"`. | K_NHNCK_80 | Closed |
| O_NHNCK_25 | (Phát hiện review `/datamart-review` 2026-08) K_NHNCK_101 (Nhóm 13, Mã định danh — Identification Type Code) ghi giá trị code số giả định `1=CMND, 2=CCCD, 3=PASSPORT` — nhưng Atomic field `ip_alternative_identification.identification_tp_code` có `etl_derived_value: null`, comment "PENDING — Data Modeler sẽ profile dữ liệu thực tế... mapping cũ 1=NATIONAL_ID;2=CITIZEN_ID;3=PASSPORT chưa được xác nhận, tạm gỡ" — giống hệt case K_NHNCK_37/O_NHNCK_23, nhưng khác chỗ KPI này chính là hiển thị loại giấy tờ (không thể bỏ qua giá trị code như O_NHNCK_23). Scheme dùng chung `IP_ALT_ID_TYPE` đã enum hóa đầy đủ dạng string, không phải số: `NATIONAL_ID`=CMND, `CITIZEN_ID`=CCCD, `PASSPORT`=Hộ chiếu (cũng có `LEGACY_NATIONAL_ID`=CMND cũ hệ thống legacy, không dùng ở đây). Người thiết kế xác nhận: sửa hiển thị sang giá trị string thật, không chờ profile thêm. | Đổi mô tả/comment từ code số 1/2/3 sang string thật NATIONAL_ID/CITIZEN_ID/PASSPORT. Attributes/registry/Detail Mapping đã đồng bộ. | K_NHNCK_101 | Closed |
| O_NHNCK_29 | (Phát hiện review `/datamart-review` 2026-08) BA cập nhật lại cột SQL tham khảo cho K_NHNCK_2a "Cấp mới" và K_NHNCK_2b "Cấp lại" (BA_analyst_NHNCK.csv, STT 1, dòng 4/5) — đổi join key từ `Certificate_Records.REVOCATION_DECISION_ID` (dùng ở O_NHNCK_20) sang `Certificate_Records.ISSUE_DECISION_ID`. Người thiết kế xác nhận `ISSUE_DECISION_ID` hợp lý nghiệp vụ hơn: xác định CCHN là "Cấp mới" hay "Cấp lại" phải dựa trên quyết định CẤP chính thức (Issue Decision), không phải quyết định thu hồi (Revocation Decision) — tên field `REVOCATION_DECISION_ID` ở O_NHNCK_20 vốn đã bị nghi ngờ "gây nhiễu" nhưng trước đó BA dùng chung cho mọi loại quyết định; nay BA tự sửa lại đúng field ngữ nghĩa. Lưu ý: cột SQL test thực thi trên DB thật (NHNCK_UAT/UAT_NHNCK_STG) trong cùng dòng BA chưa được cập nhật theo (vẫn còn `REVOCATION_DECISION_ID`) — người thiết kế xác nhận ưu tiên SQL tham khảo, bỏ qua chênh lệch này. Atomic field `issue_sp_license_decision_document_id` (Issue Securities Practitioner License Decision Document Id) đã có sẵn trên `sp_license_certificate_document` — không cần bổ sung Atomic. Chỉ đổi nguồn của `Is_Reissue_Indicator` (phục vụ K_NHNCK_2/2a/2b) — `Decision_Type_Code` trên Fact (phục vụ K_NHNCK_3/6/7/8) tiếp tục dùng `revocation_sp_license_decision_document_id`/`cancellation_sp_license_decision_document_id` như cũ, không đổi. | `Is_Reissue_Indicator` đổi JOIN `Securities Practitioner License Decision Document` qua `issue_sp_license_decision_document_id` (thay vì `revocation_sp_license_decision_document_id`) — CASE WHEN Decision Type Code = '3' THEN 'Y' WHEN = '1' THEN 'N' ELSE NULL giữ nguyên. HLD (bảng KPI + ghi chú erDiagram) đã cập nhật. Attributes/Detail Mapping/registry cập nhật ở bước tiếp theo (`datamart-lld-design`). | K_NHNCK_2, K_NHNCK_2a, K_NHNCK_2b | Closed |
| O_NHNCK_30 | (Phát hiện review `/datamart-review` 2026-08 — user báo BA đang `COUNT(DISTINCT Certificate_Number)` có vẻ lệch với mapping hiện tại) Toàn bộ 10 KPI đếm số CCHN của Nhóm 1a + Nhóm 3 (K_NHNCK_2/2a/2b/3/5/6/7/8/17/18/19) dùng công thức `COUNT(DISTINCT License_Certificate_Document_Code)` — nhưng `License_Certificate_Document_Code` là business key của **bản ghi** `CERTIFICATE_RECORDS` (nguồn `CERTIFICATE_RECORDS.ID`), KHÔNG phải business key của CCHN (`CERTIFICATE_RECORDS.CERTIFICATE_NUMBER`). O_NHNCK_19 đã tự xác nhận grain Fact thực tế là "1 CCHN × 1 lần cấp/cấp lại × 1 tháng — mỗi lần cấp sinh 1 dòng Fact riêng" và BA Row 3 (STT 1) ghi rõ bằng chứng thực tế "Sai vì cấp mới = cấp mới + cấp lại" — xác nhận 1 `Certificate_Number` có thể trải nhiều bản ghi `CERTIFICATE_RECORDS` (nhiều `ID`/nhiều `License_Certificate_Document_Code`) qua các lần cấp mới/thu hồi/cấp lại. Do đó `COUNT(DISTINCT License_Certificate_Document_Code)` thực chất đếm số **bản ghi/sự kiện cấp**, không đếm số **CCHN duy nhất** như BA SQL gốc `COUNT(DISTINCT Certificate_Number)` — có thể đếm cao hơn thực tế khi 1 CCHN phát sinh nhiều bản ghi trong cùng điều kiện lọc. Atomic `sp_license_certificate_document` đã có sẵn attribute `Certificate Number` (`certificate_nbr`, `direct` từ `CERTIFICATE_RECORDS.CERTIFICATE_NUMBER`) — không cần bổ sung Atomic, chỉ cần thêm cột vào Fact. Người thiết kế xác nhận: KHÔNG thay thế `License_Certificate_Document_Code` (vẫn giữ làm PK/degenerate key của Fact — đang dùng làm PK ở cả `opr_practitioner_certificate_hist` và `opr_practitioner_data_explorer`), mà THÊM MỚI cột `Certificate_Number` vào Fact và đổi toàn bộ 10 công thức KPI sang đếm DISTINCT trên cột mới. | Đã thêm field `Certificate_Number` (varchar) vào `Fact_Practitioner_License_Certificate_Snapshot` — cả 2 khối erDiagram (Nhóm 1a, Nhóm 3), `direct` từ `Securities Practitioner License Certificate Document.Certificate Number` (`certificate_nbr`). Đổi công thức 10 KPI (K_NHNCK_2, 2a, 2b, 3, 5, 6, 7, 8, 17, 18, 19) từ `COUNT(DISTINCT License Certificate Document Code)` sang `COUNT(DISTINCT Certificate Number)`. Attributes/Detail Mapping/registry cập nhật ở bước tiếp theo (`datamart-lld-design`). | K_NHNCK_2, K_NHNCK_2a, K_NHNCK_2b, K_NHNCK_3, K_NHNCK_5, K_NHNCK_6, K_NHNCK_7, K_NHNCK_8, K_NHNCK_17, K_NHNCK_18, K_NHNCK_19 | Closed |
| O_NHNCK_26 | (Phát hiện sau khi Closed O_NHNCK_21) Người thiết kế chỉ ra việc sửa O_NHNCK_21 chưa triệt để — chỉ đổi *giá trị* code Education Level (DOCTORATE/MASTER/BACHELOR → tiếng Việt thật) nhưng chưa xét việc `securities_practitioner_dim` (Nhóm 1a/2/3/4) **thiếu hẳn cột `Education Level Name`** — trong khi mục đích thật của người thiết kế là cần hiển thị tên trình độ học vấn trên dashboard. Đối chiếu thêm phát hiện `Practice Status Code` trên cùng Dimension cũng thiếu cặp Name tương ứng (dù `opr_practitioner_360_profile`/`opr_practitioner_data_explorer` đã có đủ cặp Code/Name cho cả 2 field này) — không nhất quán giữa Dimension và Operational cùng module. Người thiết kế xác nhận bổ sung cả 2 cột theo pattern denormalize-tại-populate đã có sẵn (JOIN `cv` lấy `cl_nm` theo đúng `scm_code`), và xác nhận không cần gắn KPI_ID riêng — đây là metadata mô tả bổ sung cho Dimension theo coverage rule (Dimension được phép kéo dư thừa attribute mô tả dù KPI hiện tại chưa dùng tới), khác quy tắc "no dư thừa" chỉ áp dụng cho Fact. | Đã thêm `Education Level Name` (`education_level_nm`) và `Practice Status Name` (`practice_status_nm`) vào `securities_practitioner_dim` — join_atomic qua `cv`, denormalize tại thời điểm populate. Đồng bộ đủ: file Attributes detail, `datamart_attributes.csv`, `datamart_model.yaml` (source_atomic thêm `"cv"`), và cả 5 khối erDiagram `Securities_Practitioner_Dimension` trong HLD (Nhóm 1a/2/3/4). Nhân tiện sửa 2 lỗi nhỏ đi kèm: tên field logical `Date Of Birth`→`Birth Date` ở `datamart_attributes.csv`/`datamart_model.yaml` (đã đổi ở HLD từ trước nhưng bỏ sót 2 file này) để nhất quán toàn bộ. **[Lưu ý 2026-08]** Tên bảng vật lý `cv` và tên cột `scm_code` trong ghi chú lịch sử này đã lỗi thời — xem O_NHNCK_27 (đổi `cv`→`cl_value`) và O_NHNCK_28 (đổi `scm_code`→`schema_code`, bổ sung cấu trúc đầy đủ 11 cột). | — | Closed |
| O_NHNCK_27 | (Yêu cầu người thiết kế 2026-08) Atomic entity `cv` (Classification Value) đổi tên vật lý sang `cl_value` (`DataModel/working/Atomic/lld/entities/entity_cv.yaml`, `physical_name`) — toàn bộ mọi nơi lookup/JOIN trực tiếp tới bảng này trong module NHNCK phải cập nhật theo. Đã grep xác nhận: chỉ ảnh hưởng NHNCK (14 vị trí trong 9 file Attributes detail + `datamart_attributes.csv`) và `Classification Dimension` conformed (`cl_dim`, 5 cột — hiện `modules_using` chỉ có NHNCK, chưa module nào khác reuse). Detail Mapping và 2 file SQL flat-table không tham chiếu `cv` trực tiếp (denormalize đã có sẵn ở tầng Attributes) — không cần sửa. | Đổi `cv`→`cl_value` tại: Atomic YAML (`physical_name`), 9 file Attributes detail NHNCK, `datamart_attributes.csv` (14 dòng NHNCK + 5 dòng `cl_dim`), `Common/DTM_NHNCK_cl_dim.csv`, `datamart_model.yaml` (29 vị trí: `source_atomic` list + `source_atomic_table` + `source_atomic_column` + description). Verify: không còn literal `cv` nào sót (trừ tên logical "Classification Value" — không đổi) và YAML/CSV vẫn hợp lệ sau khi sửa. | — | Closed |
| O_NHNCK_28 | (Yêu cầu người thiết kế 2026-08, sau khi rà soát các module khác GSTT/GSDC/NDTNN/QLKD/TT/PTTT — chỉ QLCB có dùng `cl_value` nhưng qua tên cột khác) Người thiết kế cung cấp cấu trúc thật của bảng `cl_value` Atomic (export `cl_value_202608051133.md`) — 11 cột: `cl_code`, `schema_code`, `schema_nm`, `src_stm_code`, `cl_nm`, `cl_nm_english`, `cl_description`, `ds_rcrd_st`, `ds_rcrd_eff_dt`, `ds_rcrd_end_dt`, `ds_etl_pcs_tms`. Khác với `entity_cv.yaml` cũ (5 cột, đặt tên `scm_code`/`scm_nm`) — tên cột đúng là `schema_code`/`schema_nm`, không phải `scm_code`/`scm_nm`. File `DataModel/working/Atomic/lld/classification_schemes.yaml` được xác nhận không còn dùng (out of date). Cũng xác nhận `cl_code` là data_type string, chấp nhận cả dạng số-viết-dưới-text (VD: SO_OFFERING_METHOD dùng '1'..'10') và text thuần (VD: EDUCATIONAL_LEVEL dùng 'Đại học'...) tùy theo scheme. | Cập nhật `entity_cv.yaml` đủ 11 attribute theo cấu trúc thật. Đổi `scm_code`→`schema_code`, `scm_nm`→`schema_nm` tại: 9 file Attributes detail NHNCK (16 vị trí JOIN condition + 4 vị trí `atomic_table` sót "cv" ở `securities_practitioner_dim`), `Common/DTM_NHNCK_cl_dim.csv`, `datamart_attributes.csv` (19 dòng), `datamart_model.yaml` (entity `cl_dim`), `DTM_NHNCK_Entities.csv`/`.md`. Bổ sung 2 cột mới vào `cl_dim` theo coverage rule Dimension: `Classification Name English` (`cl_nm_english`), `Classification Description` (`cl_description`) — không đưa 4 audit field `ds_*` vào Dimension vì là technical field thuần, không phục vụ báo cáo. Đã rà soát các module khác (GSTT/GSDC/NDTNN/QLKD/TT/PTTT) — không module nào tham chiếu `scm_code`/`schema_code` ngoài NHNCK và QLCB; QLCB đã dùng đúng tên `schema_code` từ đầu, không cần sửa. | — | Closed |
